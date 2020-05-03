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

            else
                local amount = k:sub(9)
                amount = amount and tonumber( amount )

                if amount then 
                    return state:TimeToResource( t, amount ) 
                else
                    if Hekili.ActiveDebug then Hekili:Debug( "runes %s %d\n%s", k, amount or -1, debugstack() ) end
                end

                return 3600
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


    spec:RegisterPack( "Unholy", 20200426, [[dGu(EbqisQEejQAtcPrrICksOvrcc5vcfZsiClHsPDr4xcrdJe4ysPAzsv5zcL00KQQRrIY2ib13ekvghjQ4CKGO1juQY8KQ4EOs7JKYbfkHwOuLEOqjQjkuQkxuOeyJKGGtsIkLvIk8sHsv1njrLQDku1qjrL0sjrL4PqAQcvUQqjOTscc1Ej1FrmyQ6WuwSu8yOMmkxw1Mb8zignqoTIvtcsVgv0SPYTrv7w0VLmCbDCHsXYb9CIMUsxxGTlL8DsY4fkroVuz9sPmFGA)iTUDDCAuMTxhFFkOpfOG(7tHfTRC6t50EFA0Tl8A0qdZPHCnAA8xJglmbvUonAO15kJPJtJkRai(Auq7gkJ9ImsKzbf0iWfFKYHpWz7ujgAaBKYHhhPgTjyCRYTu3Orz2ED89PG(uGc6Vpfw0UYPpLt7TRrLHhRJVpL1Ngf0Wyp1nAu2LynQYt9XctqLRJ6J9DBbr9X(Zbb0s5q5PEq7gkJ9ImsKzbf0iWfFKYHpWz7ujgAaBKYHhhjLdLN6JfdHJJ67tHJG67tb9PakhuouEQpwgKLixg7r5q5P(yl1hlYyNr9k3NKr9keG)TDbLdLN6JTuFSCLToCpJ6xdI8LmaupUs2StLsQFlQhEKaNbPECLSzNkLckhkp1hBPELlgEmNmsfcvUuFbq9kxlvhs9RQBCkfAu3ixPoon6LYN4l1XPJVDDCA0NwJ7mDVAumC2dhtJcdYl2H)KTiTt9Qr9iyg1hL6Hb5GjHLQdP(EO((vGg1W7uPgL)8fSJuaexaEyeg8gVuV647thNg9P14ot3RgfdN9WX0OSBliILmc7yRtSdMZjrOEWGP(WVclSWeeqvGty4DADQpk1B4DADYZZpxs9CP(21OgENk1OnUQyKcGSGo55570Ro(yvhNg9P14ot3RgfdN9WX0Okr94QCSsvkSWcBUUq5fWZBtkP(EOEfM6Js94QCSsvkmiFhPailOty3yc45TjLuVAupUkhRuLcCLSNYZiUb4afeFb882KsQxrQhmyQhxLJvQsHb57ifazbDc7gtapVnPK67H67J6bdM6XfegeUtLsXKhaWACNSWGfK4P14otJA4DQuJIeyq2yjPaiwBhwli9QJVFDCA0NwJ7mDVAumC2dhtJ2eaaiGhZP7sjbOG4lccPEWGP(Maaab8yoDxkjafeFcUcY9qHCnmNuFpuF7TRrn8ovQrxqNeKnvqYiafeF9QJxz640OpTg3z6E1Oy4ShoMgvDQNDBbrSKryhBDIDWCojIg1W7uPgfOWbYZiwBho7jn341RoEfwhNg9P14ot3RgfdN9WX0OSAf4kXpxOTNraCg)jnbWuapVnPK65s9kqJA4DQuJIRe)CH2EgbWz8xV64JD640OpTg3z6E1Oy4ShoMgvDQNDBbrSKryhBDIDWCojIg1W7uPgnmaoaDtIqACMC1RoELJoon6tRXDMUxnkgo7HJPrxZ9CfgKVJuaKf0jmJppt80ACNr9rP(lLpXx0AKtLKcGeEiWX7uPGFYcs9rP(MaaarqcQCDe5cFISGebHupyWu)LYN4lAnYPssbqcpe44DQuWpzbP(OuF4xHfwyccOkWjm8oTo1dgm1VM75kmiFhPailOtygFEM4P14oJ6Js9HFfwyHjiGQaNWW706uFuQhxLJvQsHb57ifazbDc7gtapVnPK6vJ6vyfq9Gbt9R5EUcdY3rkaYc6eMXNNjEAnUZO(OuF4xHb57iiGQaNWW706AudVtLAuvf0XA9jjWlR0s81RoEfsDCA0NwJ7mDVAumC2dhtJQo1ZUTGiwYiSJToXoyoNeH6Js9nbaaIGeu56iYf(ezbjccP(OuV6u)LYN4lAnYPssbqcpe44DQuWpzbP(OuV6u)AUNRWG8DKcGSGoHz85zINwJ7mQhmyQFniYxXo8NSfHnN67H6Xv5yLQuyHf2CDHYlGN3MuQrn8ovQrvvqhR1NKaVSslXxV64Bxb640OpTg3z6E1Oy4ShoMgvDQNDBbrSKryhBDIDWCojIg1W7uPgfoHHUtMKidn81Ro(2BxhNg1W7uPgfElCsecGZ4VuJ(0ACNP7vV6vJYoGf4wDC64BxhNg1W7uPgLFsgba(321OpTg3z6E1Ro((0XPrFAnUZ09QrRqnQ8Rg1W7uPgTLbhRXDnAlZfCnkUkhRuLczapFLeedIuDUlGN3Mus99q9kJ6Js9R5EUczapFLeedIuDUlEAnUZ0OTmijn(RrdRYnjcbOGeedIuDURxD8XQoon6tRXDMUxnkgo7HJPrHb5GjHLQdfSdm4zPE1OEfwzuFuQxjQp8RaXGivN7cdVtRt9Gbt9Qt9R5EUczapFLeedIuDUlEAnUZOEfP(OupmiVGDGbpl1RgxQxzAudVtLAudIT8KTGWNRE1X3Voon6tRXDMUxnkgo7HJPrd)kqmis15UWW706upyWuV6u)AUNRqgWZxjbXGivN7INwJ7mnQH3PsnAJRkgbia2PxD8kthNg9P14ot3RgfdN9WX0OnbaaIGeu56iaWNT1jccPEWGP(WVcedIuDUlm8oTo1dgm1Re1VM75kmiFhPailOtygFEM4P14oJ6Js9HFfwyHjiGQaNWW706uVIAudVtLA0MdLhY5Ki6vhVcRJtJ(0ACNP7vJIHZE4yAuLO(MaaarqcQCDe5cFISGebHuFuQVjaaqaC5Ei)GaAfWZBtkP(E4s9kJ6vK6bdM6n8oTo555NlPE14s99r9rPELO(MaaarqcQCDe5cFISGebHupyWuFtaaGa4Y9q(bb0kGN3Mus99WL6vg1ROg1W7uPg1niGwjrHgWq4FU6vhFSthNg9P14ot3RgfdN9WX0Okr9HFfigeP6Cxy4DADQpk1VM75kKb88vsqmis15U4P14oJ6vK6bdM6d)kSWctqavboHH3P11OgENk1OwIVCHMJGnNtV64vo640OpTg3z6E1Oy4ShoMg1W706KNNFUK6vJl13h1dgm1Re1ddYlyhyWZs9QXL6vg1hL6Hb5GjHLQdfSdm4zPE14s9kScOEf1OgENk1OgeB5jHbo51RoEfsDCA0NwJ7mDVAumC2dhtJQe1h(vGyqKQZDHH3P1P(Ou)AUNRqgWZxjbXGivN7INwJ7mQxrQhmyQp8RWclmbbuf4egENwxJA4DQuJcmW34QIPxD8TRaDCA0NwJ7mDVAumC2dhtJ2eaaicsqLRJix4tKfKiiK6Js9gENwN888ZLupxQVDQhmyQVjaaqaC5Ei)GaAfWZBtkP(EOEemJ6Js9gENwN888ZLupxQVDnQH3PsnAJHqkaYchmNs9QJV921XPrFAnUZ09QrXWzpCmn6o8N6vJ67tbupyWuV6u)Jnbty4zcOXhojcX4dDZgWobzqSwLBjprM8upyWuV6u)Jnbty4zIwJCQKuae25h51OgENk1ObYtM98s9QJV9(0XPrFAnUZ09Qrn8ovQrT2KGmOjjavUKcGewQouJIHZE4yAuLO(lLpXx0AKtLKcGeEiWX7uP4P14oJ6Js9Qt9R5EUIGeu56iaWNT1jEAnUZOEfPEWGPELOE1P(lLpXxGRK9uEgXnahOG4l4nfAbP(OuV6u)LYN4lAnYPssbqcpe44DQu80ACNr9kQrtJ)AuRnjidAscqLlPaiHLQd1Ro(2JvDCA0NwJ7mDVAudVtLAuRnjidAscqLlPaiHLQd1Oy4ShoMgfxLJvQsHfwyZ1fkVaEEBsj13d13E)uFuQxjQ)s5t8f4kzpLNrCdWbki(cEtHwqQhmyQ)s5t8fTg5ujPaiHhcC8ovkEAnUZO(Ou)AUNRiibvUoca8zBDINwJ7mQxrnAA8xJATjbzqtsaQCjfajSuDOE1X3E)640OpTg3z6E1OgENk1OwBsqg0KeGkxsbqclvhQrXWzpCmn6o8NSfHnN67H6Xv5yLQuyHf2CDHYlGN3Mus9Xq9XA)A004Vg1AtcYGMKau5skasyP6q9QJVDLPJtJ(0ACNP7vJA4DQuJAsqTS8sc0ARGeCbnNgfdN9WX0OS3eaaiGwBfKGlO5iS3eaaiKRH5K67H6BxJMg)1OMeullVKaT2kibxqZPxD8TRW640OpTg3z6E1OgENk1OMeullVKaT2kibxqZPrXWzpCmnA4xbsGbzJLKcGyTDyTGegENwN6Js9HFfwyHjiGQaNWW706A004Vg1KGAz5LeO1wbj4cAo9QJV9yNoon6tRXDMUxnQH3PsnQjb1YYljqRTcsWf0CAumC2dhtJIRYXkvPWclS56cLxaVX6O(OuVsu)LYN4lWvYEkpJ4gGduq8f8McTGuFuQFh(t2IWMt99q94QCSsvkWvYEkpJ4gGduq8fWZBtkP(yO((ua1dgm1Ro1FP8j(cCLSNYZiUb4afeFbVPqli1ROgnn(RrnjOwwEjbATvqcUGMtV64Bx5OJtJ(0ACNP7vJA4DQuJAsqTS8sc0ARGeCbnNgfdN9WX0O7WFYwe2CQVhQhxLJvQsHfwyZ1fkVaEEBsj1hd13Nc0OPXFnQjb1YYljqRTcsWf0C6vhF7kK640OpTg3z6E1OgENk1OTg5ujPaiSZpYRrXWzpCmnQsupUkhRuLclSWMRluEb8gRJ6Js9S3eaaiaUCpCseIQkizc5AyoPE14s99t9rP(lLpXx0AKtLKcGeEiWX7uP4P14oJ6vK6bdM6BcaaebjOY1raGpBRtees9Gbt9HFfigeP6Cxy4DADnAA8xJ2AKtLKcGWo)iVE1X3Nc0XPrFAnUZ09Qrn8ovQrHgF4KieJp0nBa7eKbXAvUL8ezYRrXWzpCmnkUkhRuLclSWMRluEb882KsQVhQVpQhmyQFn3Zvyq(osbqwqNWm(8mXtRXDg1dgm1dTHrERNRWymPysQVhQxzA004VgfA8HtIqm(q3SbStqgeRv5wYtKjVE1X3x7640OpTg3z6E1OgENk1OnDivEsZpXC8wAynkgo7HJPrXv5yLQuid45RKGyqKQZDb882KsQxnQxHva1dgm1Ro1VM75kKb88vsqmis15U4P14oJ6Js97WFQxnQVpfq9Gbt9Qt9p2emHHNjGgF4KieJp0nBa7eKbXAvUL8ezYRrtJ)A0MoKkpP5NyoElnSE1X3xF640OpTg3z6E1OgENk1Ok0ljGkvUd1Oy4ShoMgn8RaXGivN7cdVtRt9Gbt9Qt9R5EUczapFLeedIuDUlEAnUZO(Ou)o8N6vJ67tbupyWuV6u)Jnbty4zcOXhojcX4dDZgWobzqSwLBjprM8A004VgvHEjbuPYDOE1X3xSQJtJ(0ACNP7vJA4DQuJIyUJnN7qjP5gNAumC2dhtJg(vGyqKQZDHH3P1PEWGPE1P(1CpxHmGNVscIbrQo3fpTg3zuFuQFh(t9Qr99PaQhmyQxDQ)XMGjm8mb04dNeHy8HUzdyNGmiwRYTKNitEnAA8xJIyUJnN7qjP5gN6vhFF9RJtJ(0ACNP7vJA4DQuJIaRerscHdV5iqd5AumC2dhtJcdYt99WL6JvQpk1Re1Vd)PE1O((ua1dgm1Ro1)ytWegEMaA8HtIqm(q3SbStqgeRv5wYtKjp1ROgnn(RrrGvIijHWH3CeOHC9QJVpLPJtJ(0ACNP7vJIHZE4yAuCvowPkfgKVJuaKf0jSBmb8gRJ6bdM6d)kqmis15UWW706upyWuFtaaGiibvUoca8zBDIGqnQH3PsnAyTtL6vhFFkSoon6tRXDMUxnkgo7HJPrz1kAnWa3ZLe6mKGlGN3Mus99WL6rWmnQH3PsnAfSnWBCQxD89f70XPrFAnUZ09Qrn8ovQrXMZrm8ovsCJC1OUrUK04Vg9s5t8L6vhFFkhDCA0NwJ7mDVAudVtLAuS5CedVtLe3ixnQBKljn(RrXv5yLQuQxD89PqQJtJ(0ACNP7vJIHZE4yAudVtRtEE(5sQxnUuFFAudVtLAuyqsm8ovsCJC1OUrUK04Vg1QRxD8XQc0XPrFAnUZ09Qrn8ovQrXMZrm8ovsCJC1OUrUK04Vgf55HdwV6vJgcpU4BSvhNo(21XPrn8ovQrdRDQuJ(0ACNP7vV647thNg1W7uPgfAJ8e2nMg9P14ot3RE1XhR640OpTg3z6E1OPXFnQ1MeKbnjbOYLuaKWs1HAudVtLAuRnjidAscqLlPaiHLQd1Ro((1XPrFAnUZ09Qrz3zDA0(0OgENk1OgKVJuaKf0jSBm9QxnkUkhRuLsDC64BxhNg1W7uPg1G8DKcGSGoHDJPrFAnUZ09QxD89PJtJ(0ACNP7vJIHZE4yAu2BcaaeaxUhojcrvfKmHCnmNuVACP((P(OuVsuVH3P1jpp)Cj1RgxQVpQhmyQxDQ)s5t8fTg5ujPaiHhcC8ovkEAnUZOEWGPE1PERTdN9cEdjqskaYc6e2nM4P14oJ6bdM6Vu(eFrRrovskas4HahVtLINwJ7mQpk1Re1VM75kcsqLRJaaF2wN4P14oJ6Js94QCSsvkcsqLRJaaF2wNaEEBsj13dxQpwPEWGPE1P(1CpxrqcQCDea4Z26epTg3zuVIuVIAudVtLAulSWMRluE9QJpw1XPrFAnUZ09QrXWzpCmnQ6up0gg5TEUcJXKIhlnYvs9Gbt9qByK365kmgtkMK6vJ6BxzAudVtLAuMb5KSqlLafK32Ps9QJVFDCA0NwJ7mDVAumC2dhtJcdYbtclvhkyhyWZs99q9T3Vg1W7uPgvgWZxjbXGivN76vhVY0XPrFAnUZ09QrXWzpCmn6LYN4lAnYPssbqcpe44DQu80ACNr9rP(WVclSWeeqvGty4DADQhmyQN9MaaabWL7HtIquvbjtixdZj13d13p1hL6vN6Vu(eFrRrovskas4HahVtLINwJ7mQpk1Re1Ro1BTD4SxWBibssbqwqNWUXepTg3zupyWuV12HZEbVHeijfazbDc7gt80ACNr9rP(WVclSWeeqvGty4DADQxrnQH3PsnAqcQCDea4Z260RoEfwhNg9P14ot3RgfdN9WX0OgENwN888ZLuVACP((O(OuVsuVsupUkhRuLc2TfeXsgHDS1jGN3Mus99WL6rWmQpk1Ro1VM75kyhyCx80ACNr9ks9Gbt9kr94QCSsvkyhyCxapVnPK67Hl1JGzuFuQFn3ZvWoW4U4P14oJ6vK6vuJA4DQuJgKGkxhba(STo9QJp2PJtJ(0ACNP7vJA4DQuJkRahbEl8qnkgo7HJPrxdI8vSd)jBryZP(EOELd1hL6xdI8vSd)jBryZPE1O((1O4oS7K1GiFL64BxV64vo640OpTg3z6E1Oy4ShoMgvjQxDQhAdJ8wpxHXysXJLg5kPEWGPEOnmYB9CfgJjfts9Qr99PaQxrQpk1ddYt99WL6vI6BN6JTuFtaaGiibvUoca8zBDIGqQxrnQH3PsnQScCe4TWd1RoEfsDCAudVtLA0Geu56inUbb0QrFAnUZ09Qx9QrT6640X3Uoon6tRXDMUxnkgo7HJPrXv5yLQuyHf2CDHYlGN3MuQrn8ovQrz3wqelze2XwNE1X3Noon6tRXDMUxnkgo7HJPrXv5yLQuyHf2CDHYlGN3MuQrn8ovQrzhyCxV64JvDCA0NwJ7mDVAumC2dhtJYUTGiwYiSJToXoyoNeH6Js9WGCWKWs1Hc2bg8SuFpuVsuF79t9Xq9SBlicN5GaAfaQQGKDgzniYxj1Rqe1hRuVIuFuQxDQVLbhRXDryvUjriafKGyqKQZDnQH3Psn6dh25hSE1X3Voon6tRXDMUxnkgo7HJPrz3wqelze2XwNyhmNtIq9rPELOE1PE2TfeHZCqaTcavvqYoJSge5RK6Js9R5EUIMaOCNeHil4LINwJ7mQxrQpk1Ro13YGJ14UiSk3KieGcsqmis15Ug1W7uPg9Hd78dwV64vMoon6tRXDMUxnkgo7HJPrz3wqelze2XwNyhmNtIq9rPEyqoysyP6qb7adEwQVhQV9(P(OuV6uFldowJ7IWQCtIqakibXGivN7AudVtLAu2TfebxJtV64vyDCA0NwJ7mDVAumC2dhtJYUTGiwYiSJToXoyoNeH6Js94QCSsvkSWcBUUq5fWZBtk1OgENk1OsCfarorUWHZRxD8XoDCA0NwJ7mDVAumC2dhtJYUTGiwYiSJToXoyoNeH6Js94QCSsvkSWcBUUq5fWZBtk1OgENk1OyNPAseIeKXkvs9QJx5OJtJ(0ACNP7vJIHZE4yAu1P(wgCSg3fHv5MeHauqcIbrQo31OgENk1OpCyNFW6vhVcPoon6tRXDMUxnQH3PsnkWL7HtIqKlC48AumC2dhtJYEtaaGa4Y9WjriQQGKjKRH5K67Hl13h1hL6Xv5yLQuWUTGiwYiSJTob882KsQpk1JRYXkvPWclS56cLxapVnPK6vJ6vg1hL6vI6Xv5yLQuyq(osbqwqNWUXeWZBtkPE1OELr9Gbt9SBlicN5GaAfSrAnUtSAzuVIAuCh2DYAqKVsD8TRxD8TRaDCA0NwJ7mDVAumC2dhtJ2eaaiKbm2tcRkEb8gEP(OupmiVyh(t2I0p1Rg1JGzAudVtLAu2TfebxJtV64BVDDCA0NwJ7mDVAumC2dhtJ2eaaiKbm2tcRkEb8gEP(OuV6uFldowJ7IWQCtIqakibXGivN7upyWuF4xbIbrQo3fgENwxJA4DQuJYUTGi4AC6vhF79PJtJ(0ACNP7vJIHZE4yAuyqoysyP6qb7adEwQVhQV9(P(OuVsupUkhRuLclSWMRluEb882KsQxnQxzupyWup7nbaacGl3dNeHOQcsMqUgMtQxnQVFQxrQpk1Ro13YGJ14UiSk3KieGcsqmis15Ug1W7uPgLDBbrW140Ro(2JvDCA0NwJ7mDVAudVtLAujUcGiNix4W51Oy4ShoMgvjQxjQhxLJvQsHb57ifazbDc7gtapVnPK6vJ6vg1dgm1ZUTGiCMdcOvWgP14oXQLr9ks9rPELOECvowPkfwyHnxxO8c45TjLuVAuVYO(Oup7nbaacGl3dNeHOQcsMqUgMtQxnQxbupyWup7nbaacGl3dNeHOQcsMqUgMtQxnQVFQxrQpk1Re1Vd)jBryZP(EOECvowPkfSBliILmc7yRtapVnPK6JH6BxbupyWu)o8NSfHnN6vJ6Xv5yLQuyHf2CDHYlGN3Mus9ks9kQrXDy3jRbr(k1X3UE1X3E)640OpTg3z6E1OgENk1OyNPAseIeKXkvsnkgo7HJPrvI6vI6Xv5yLQuyq(osbqwqNWUXeWZBtkPE1OELr9Gbt9SBlicN5GaAfSrAnUtSAzuVIuFuQxjQhxLJvQsHfwyZ1fkVaEEBsj1Rg1RmQpk1ZEtaaGa4Y9WjriQQGKjKRH5K6vJ6va1dgm1ZEtaaGa4Y9WjriQQGKjKRH5K6vJ67N6vK6Js9kr97WFYwe2CQVhQhxLJvQsb72cIyjJWo26eWZBtkP(yO(2va1dgm1Vd)jBryZPE1OECvowPkfwyHnxxO8c45TjLuVIuVIAuCh2DYAqKVsD8TRxD8TRmDCA0NwJ7mDVAumC2dhtJcdYbtclvhkyhyWZs99q99PaQpk1Ro13YGJ14UiSk3KieGcsqmis15Ug1W7uPgLDBbrW140Ro(2vyDCA0NwJ7mDVAumC2dhtJQe1Re1Re1Re1ZEtaaGa4Y9WjriQQGKjKRH5K67H67N6Js9Qt9nbaaIGeu56iaWNT1jccPEfPEWGPE2BcaaeaxUhojcrvfKmHCnmNuFpuFSs9ks9rPECvowPkfwyHnxxO8c45TjLuFpuFSs9ks9Gbt9S3eaaiaUCpCseIQkizc5AyoP(EO(2PEfP(OuVsupUkhRuLcdY3rkaYc6e2nMaEEBsj1Rg1RmQhmyQNDBbr4mheqRGnsRXDIvlJ6vuJA4DQuJcC5E4Kie5choVE1X3ESthNg9P14ot3RgfdN9WX0OSBliILmc7yRtSdMZjr0OgENk1OsCfarorUWHZRxD8TRC0XPrFAnUZ09QrXWzpCmnk72cIyjJWo26e7G5CsenQH3Psnk2zQMeHibzSsLuV64BxHuhNg9P14ot3RgfdN9WX0OQt9Tm4ynUlcRYnjcbOGeedIuDURrn8ovQrz3wqeCno9QxnkYZdhSooD8TRJtJ(0ACNP7vJIHZE4yA0MaaaHmGXEsyvXlG3Wl1hL6Hb5f7WFYwK(PE1OEemJ6Js9Qt9Tm4ynUlcRYnjcbOGeedIuDUt9Gbt9HFfigeP6Cxy4DADnQH3Psnk72cIGRXPxD89PJtJ(0ACNP7vJIHZE4yAuyqoysyP6qb7adEwQVhQV9(P(OupmiVyh(t2I0p1Rg1JGzuFuQxDQVLbhRXDryvUjriafKGyqKQZDnQH3Psnk72cIGRXPxD8XQoon6tRXDMUxnkgo7HJPrvI6vI6zVjaaqaC5E4KievvqYebHuFuQxjQhxLJvQsHfwyZ1fkVaEEBsj1Rg1RmQpk1Re1Ro1FP8j(IwJCQKuaKWdboENkfpTg3zupyWuV6u)AUNRiibvUoca8zBDINwJ7mQxrQhmyQ)s5t8fTg5ujPaiHhcC8ovkEAnUZO(Ou)AUNRiibvUoca8zBDINwJ7mQpk1JRYXkvPiibvUoca8zBDc45TjLuVAuVct9ks9ks9Gbt9S3eaaiaUCpCseIQkizc5AyoPE1O((PEfP(OuVsupUkhRuLcdY3rkaYc6e2nMaEEBsj1Rg1RmQhmyQNDBbr4mheqRGnsRXDIvlJ6vuJA4DQuJkXvae5e5choVE1X3Voon6tRXDMUxnkgo7HJPrvI6vI6zVjaaqaC5E4KievvqYebHuFuQxjQhxLJvQsHfwyZ1fkVaEEBsj1Rg1RmQpk1Re1Ro1FP8j(IwJCQKuaKWdboENkfpTg3zupyWuV6u)AUNRiibvUoca8zBDINwJ7mQxrQhmyQ)s5t8fTg5ujPaiHhcC8ovkEAnUZO(Ou)AUNRiibvUoca8zBDINwJ7mQpk1JRYXkvPiibvUoca8zBDc45TjLuVAuVct9ks9ks9Gbt9S3eaaiaUCpCseIQkizc5AyoPE1O((PEfP(OuVsupUkhRuLcdY3rkaYc6e2nMaEEBsj1Rg1RmQhmyQNDBbr4mheqRGnsRXDIvlJ6vuJA4DQuJIDMQjrisqgRuj1RoELPJtJ(0ACNP7vJIHZE4yAuyqoysyP6qb7adEwQVhQVpfq9rPE1P(wgCSg3fHv5MeHauqcIbrQo31OgENk1OSBlicUgNE1XRW640OpTg3z6E1Oy4ShoMgL9MaaabWL7HtIquvbjtixdZj13d13p1hL6vI6Xv5yLQuyHf2CDHYlGN3Mus99q9Xk1hL6vI6vN6Vu(eFrRrovskas4HahVtLINwJ7mQhmyQxDQFn3ZveKGkxhba(SToXtRXDg1dgm1FP8j(IwJCQKuaKWdboENkfpTg3zuFuQFn3ZveKGkxhba(SToXtRXDg1hL6Xv5yLQueKGkxhba(STob882KsQVhQp2r9ks9ks9Gbt9S3eaaiaUCpCseIQkizc5AyoP(EO(2P(OuVsupUkhRuLcdY3rkaYc6e2nMaEEBsj1Rg1RmQhmyQNDBbr4mheqRGnsRXDIvlJ6vuJA4DQuJcC5E4Kie5choVE1Xh70XPrFAnUZ09QrXWzpCmnQ6uFldowJ7IWQCtIqakibXGivN7AudVtLAu2TfebxJtV6vVA0whkNk1X3Nc6tbkO)(uMgvLbZjrKAuLB8HfCpJ6vyQ3W7uj17g5kfuo0OHWcyCxJQ8uFSWeu56O(yF3wquFS)CqaTuouEQh0UHYyViJezwqbncCXhPC4dC2ovIHgWgPC4Xrs5q5P(yXq44O((u4iO((uqFkGYbLdLN6JLbzjYLXEuouEQp2s9XIm2zuVY9jzuVcb4FBxq5q5P(yl1hlxzRd3ZO(1GiFjda1JRKn7uPK63I6HhjWzqQhxjB2PsPGYHYt9XwQx5IHhZjJuHqLl1xauVY1s1Hu)Q6gNsbLdkhkp1hliw64G9mQV5af8upU4BSL6BoYKsb1hlIXpCLuFwzSfKb5bcCuVH3Psj1xPRtq5q5PEdVtLsri84IVXwUaotYjLdLN6n8ovkfHWJl(gBJHBKavXOCO8uVH3PsPieECX3yBmCJ0cq4FU2ovs5q5PE00cLGQL6H2WO(MaaGZOE5ARK6Boqbp1Jl(gBP(MJmPK6TKr9HWhBdRDNeH6hj1ZQ8ckhkp1B4DQukcHhx8n2gd3iLPfkbvlrU2kPCy4DQukcHhx8n2gd3idRDQKYHH3PsPieECX3yBmCJeAJ8e2ngLddVtLsri84IVX2y4gzG8KzpFePXFUwBsqg0KeGkxsbqclvhs5WW7uPuecpU4BSngUrAq(osbqwqNWUXIGDN1XTpkhuouEQpwqS0Xb7zu)BDyh1Vd)P(f0PEdVfK6hj1BTSXznUlOCy4DQuYLFsgba(32PCy4DQugd3iBzWXACpI04p3WQCtIqakibXGivN7r0YCbNlUkhRuLczapFLeedIuDUlGN3Mu2JYIUM75kKb88vsqmis15U4P14oJYHYt9kxm8yozeuVYT98YiOElzuFTGoK6lemts5WW7uPmgUrAqSLNSfe(CJya4cdYbtclvhkyhyWZQMcRSOkf(vGyqKQZDHH3P1bdw91CpxHmGNVscIbrQo3fpTg3zkgfgKxWoWGNvnUkJYHH3PszmCJSXvfJaea7Iya4g(vGyqKQZDHH3P1bdw91CpxHmGNVscIbrQo3fpTg3zuom8ovkJHBKnhkpKZjrIya42eaaicsqLRJaaF2wNiiem4WVcedIuDUlm8oToyWkTM75kmiFhPailOtygFEM4P14olA4xHfwyccOkWjm8oTUIuom8ovkJHBKUbb0kjk0agc)ZnIbGRsnbaaIGeu56iYf(ezbjccJ2eaaiaUCpKFqaTc45TjL9WvzkcgSH3P1jpp)CPAC7lQsnbaaIGeu56iYf(ezbjccbdUjaaqaC5Ei)GaAfWZBtk7HRYuKYHH3PszmCJ0s8Ll0CeS5CrmaCvk8RaXGivN7cdVtRhDn3Zvid45RKGyqKQZDXtRXDMIGbh(vyHfMGaQcCcdVtRt5WW7uPmgUrAqSLNeg4KpIbGRH3P1jpp)CPAC7dmyLGb5fSdm4zvJRYIcdYbtclvhkyhyWZQgxfwbks5WW7uPmgUrcmW34QIfXaWvPWVcedIuDUlm8oTE01CpxHmGNVscIbrQo3fpTg3zkcgC4xHfwyccOkWjm8oToLddVtLYy4gzJHqkaYchmNYigaUnbaaIGeu56iYf(ezbjccJA4DADYZZpxYTDWGBcaaeaxUhYpiGwb882KYEqWSOgENwN888ZLCBNYbLdLN6JLdKBXt9lCso)kP(aPHCkhgENkLXWnYa5jZEEzeda3D4VA9PaWGv)XMGjm8mb04dNeHy8HUzdyNGmiwRYTKNitEWGv)XMGjm8mrRrovskac78J8uom8ovkJHBKbYtM98rKg)5ATjbzqtsaQCjfajSuDyedaxLUu(eFrRrovskas4HahVtLINwJ7SOQVM75kcsqLRJaaF2wN4P14otrWGvs9lLpXxGRK9uEgXnahOG4l4nfAbJQ(LYN4lAnYPssbqcpe44DQu80ACNPiLddVtLYy4gzG8KzpFePXFUwBsqg0KeGkxsbqclvhgXaWfxLJvQsHfwyZ1fkVaEEBszpT3FuLUu(eFbUs2t5ze3aCGcIVG3uOfem4lLpXx0AKtLKcGeEiWX7uP4P14ol6AUNRiibvUoca8zBDINwJ7mfPCy4DQugd3idKNm75Jin(Z1AtcYGMKau5skasyP6WigaU7WFYwe28EWv5yLQuyHf2CDHYlGN3MugtS2pLddVtLYy4gzG8KzpFePXFUMeullVKaT2kibxqZfXaWL9Maaab0ARGeCbnhH9MaaaHCnmN90oLddVtLYy4gzG8KzpFePXFUMeullVKaT2kibxqZfXaWn8RajWGSXssbqS2oSwqcdVtRhn8RWclmbbuf4egENwNYHH3PszmCJmqEYSNpI04pxtcQLLxsGwBfKGlO5Iya4IRYXkvPWclS56cLxaVX6IQ0LYN4lWvYEkpJ4gGduq8f8McTGr3H)KTiS59GRYXkvPaxj7P8mIBaoqbXxapVnPmM(uayWQFP8j(cCLSNYZiUb4afeFbVPqlOIuom8ovkJHBKbYtM98rKg)5AsqTS8sc0ARGeCbnxeda3D4pzlcBEp4QCSsvkSWcBUUq5fWZBtkJPpfq5WW7uPmgUrgipz2ZhrA8NBRrovskac78J8rmaCvcxLJvQsHfwyZ1fkVaEJ1fL9MaaabWL7HtIquvbjtixdZPAC7p6LYN4lAnYPssbqcpe44DQu80ACNPiyWnbaaIGeu56iaWNT1jccbdo8RaXGivN7cdVtRt5WW7uPmgUrgipz2ZhrA8Nl04dNeHy8HUzdyNGmiwRYTKNit(igaU4QCSsvkSWcBUUq5fWZBtk7PpWGxZ9CfgKVJuaKf0jmJppt80ACNbgm0gg5TEUcJXKIj7rzuom8ovkJHBKbYtM98rKg)520Hu5jn)eZXBPHJya4IRYXkvPqgWZxjbXGivN7c45TjLQPWkamy1xZ9CfYaE(kjigeP6Cx80ACNfDh(RwFkamy1FSjycdptan(WjrigFOB2a2jidI1QCl5jYKNYHH3PszmCJmqEYSNpI04pxf6LeqLk3HrmaCd)kqmis15UWW706GbR(AUNRqgWZxjbXGivN7INwJ7SO7WF16tbGbR(Jnbty4zcOXhojcX4dDZgWobzqSwLBjprM8uom8ovkJHBKbYtM98rKg)5IyUJnN7qjP5gNrmaCd)kqmis15UWW706GbR(AUNRqgWZxjbXGivN7INwJ7SO7WF16tbGbR(Jnbty4zcOXhojcX4dDZgWobzqSwLBjprM8uom8ovkJHBKbYtM98rKg)5IaRerscHdV5iqd5rmaCHb57HBSgvPD4VA9PaWGv)XMGjm8mb04dNeHy8HUzdyNGmiwRYTKNitEfPCy4DQugd3idRDQmIbGlUkhRuLcdY3rkaYc6e2nMaEJ1bgC4xbIbrQo3fgENwhm4MaaarqcQCDea4Z26ebHuouEQx5Un5Atojc1Rq8adCpxQx5QZqco1psQ3O(q4uWz7OCy4DQugd3iRGTbEJZigaUSAfTgyG75scDgsWfWZBtk7HlcMr5WW7uPmgUrInNJy4DQK4g5grA8N7LYN4lPCy4DQugd3iXMZrm8ovsCJCJin(ZfxLJvQsjLddVtLYy4gjmijgENkjUrUrKg)5A1Jya4A4DADYZZpxQg3(OCy4DQugd3iXMZrm8ovsCJCJin(Zf55HdMYbLdLN6JfRybupSwBNkPCy4DQukS6Cz3wqelze2XwxedaxCvowPkfwyHnxxO8c45TjLuom8ovkfw9y4gj7aJ7rmaCXv5yLQuyHf2CDHYlGN3Mus5WW7uPuy1JHBKpCyNFWrmaCz3wqelze2XwNyhmNtIefgKdMewQouWoWGNThLAV)yy3wqeoZbb0kauvbj7mYAqKVsfIIvfJQEldowJ7IWQCtIqakibXGivN7uom8ovkfw9y4g5dh25hCedax2TfeXsgHDS1j2bZ5KirvsD2TfeHZCqaTcavvqYoJSge5Rm6AUNROjak3jriYcEP4P14otXOQ3YGJ14UiSk3KieGcsqmis15oLddVtLsHvpgUrYUTGi4ACrmaCz3wqelze2XwNyhmNtIefgKdMewQouWoWGNTN27pQ6Tm4ynUlcRYnjcbOGeedIuDUt5WW7uPuy1JHBKsCfarorUWHZhXaWLDBbrSKryhBDIDWCojsuCvowPkfwyHnxxO8c45TjLuom8ovkfw9y4gj2zQMeHibzSsLmIbGl72cIyjJWo26e7G5CsKO4QCSsvkSWcBUUq5fWZBtkPCy4DQukS6XWnYhoSZp4igaUQ3YGJ14UiSk3KieGcsqmis15oLddVtLsHvpgUrcC5E4Kie5choFe4oS7K1GiFLCBpIbGl7nbaacGl3dNeHOQcsMqUgMZE42xuCvowPkfSBliILmc7yRtapVnPmkUkhRuLclSWMRluEb882Ks1uwuLWv5yLQuyq(osbqwqNWUXeWZBtkvtzGbZUTGiCMdcOvWgP14oXQLPiLddVtLsHvpgUrYUTGi4ACrmaCBcaaeYag7jHvfVaEdVrHb5f7WFYwK(vdbZOCy4DQukS6XWns2TfebxJlIbGBtaaGqgWypjSQ4fWB4nQ6Tm4ynUlcRYnjcbOGeedIuDUdgC4xbIbrQo3fgENwNYHH3PsPWQhd3iz3wqeCnUigaUWGCWKWs1Hc2bg8S90E)rvcxLJvQsHfwyZ1fkVaEEBsPAkdmy2BcaaeaxUhojcrvfKmHCnmNQ1VIrvVLbhRXDryvUjriafKGyqKQZDkhgENkLcREmCJuIRaiYjYfoC(iWDy3jRbr(k52EedaxLucxLJvQsHb57ifazbDc7gtapVnPunLbgm72cIWzoiGwbBKwJ7eRwMIrvcxLJvQsHfwyZ1fkVaEEBsPAklk7nbaacGl3dNeHOQcsMqUgMt1uayWS3eaaiaUCpCseIQkizc5AyovRFfJQ0o8NSfHnVhCvowPkfSBliILmc7yRtapVnPmM2vayW7WFYwe2C1Wv5yLQuyHf2CDHYlGN3MuQOIuom8ovkfw9y4gj2zQMeHibzSsLmcCh2DYAqKVsUThXaWvjLWv5yLQuyq(osbqwqNWUXeWZBtkvtzGbZUTGiCMdcOvWgP14oXQLPyuLWv5yLQuyHf2CDHYlGN3MuQMYIYEtaaGa4Y9WjriQQGKjKRH5unfagm7nbaacGl3dNeHOQcsMqUgMt16xXOkTd)jBryZ7bxLJvQsb72cIyjJWo26eWZBtkJPDfag8o8NSfHnxnCvowPkfwyHnxxO8c45TjLkQiLddVtLsHvpgUrYUTGi4ACrmaCHb5GjHLQdfSdm4z7Ppfev9wgCSg3fHv5MeHauqcIbrQo3PCy4DQukS6XWnsGl3dNeHix4W5Jya4QKskPe7nbaacGl3dNeHOQcsMqUgMZE6pQ6nbaaIGeu56iaWNT1jccvemy2BcaaeaxUhojcrvfKmHCnmN9eRkgfxLJvQsHfwyZ1fkVaEEBszpXQIGbZEtaaGa4Y9WjriQQGKjKRH5SN2vmQs4QCSsvkmiFhPailOty3yc45TjLQPmWGz3wqeoZbb0kyJ0ACNy1YuKYHH3PsPWQhd3iL4kaICICHdNpIbGl72cIyjJWo26e7G5CsekhgENkLcREmCJe7mvtIqKGmwPsgXaWLDBbrSKryhBDIDWCojcLddVtLsHvpgUrYUTGi4ACrmaCvVLbhRXDryvUjriafKGyqKQZDkhuom8ovkf4QCSsvk5Aq(osbqwqNWUXOCy4DQukWv5yLQugd3iTWcBUUq5Jya4YEtaaGa4Y9WjriQQGKjKRH5unU9hvjdVtRtEE(5s142hyWQFP8j(IwJCQKuaKWdboENkfpTg3zGbRU12HZEbVHeijfazbDc7gt80ACNbg8LYN4lAnYPssbqcpe44DQu80ACNfvP1CpxrqcQCDea4Z26epTg3zrXv5yLQueKGkxhba(STob882KYE4gRGbR(AUNRiibvUoca8zBDINwJ7mfvKYHH3PsPaxLJvQszmCJKzqojl0sjqb5TDQmIbGR6qByK365kmgtkES0ixjyWqByK365kmgtkMuT2vgLddVtLsbUkhRuLYy4gPmGNVscIbrQo3Jya4cdYbtclvhkyhyWZ2t79t5WW7uPuGRYXkvPmgUrgKGkxhba(STUigaUxkFIVO1iNkjfaj8qGJ3PsXtRXDw0WVclSWeeqvGty4DADWGzVjaaqaC5E4KievvqYeY1WC2t)rv)s5t8fTg5ujPaiHhcC8ovkEAnUZIQK6wBho7f8gsGKuaKf0jSBmXtRXDgyWwBho7f8gsGKuaKf0jSBmXtRXDw0WVclSWeeqvGty4DADfPCy4DQukWv5yLQugd3idsqLRJaaF2wxedaxdVtRtEE(5s142xuLucxLJvQsb72cIyjJWo26eWZBtk7HlcMfv91Cpxb7aJ7INwJ7mfbdwjCvowPkfSdmUlGN3Mu2dxeml6AUNRGDGXDXtRXDMIks5WW7uPuGRYXkvPmgUrkRahbEl8WiWDy3jRbr(k52Eeda31GiFf7WFYwe28EuorxdI8vSd)jBryZvRFkhgENkLcCvowPkLXWnszf4iWBHhgXaWvj1H2WiV1ZvymMu8yPrUsWGH2WiV1ZvymMumPA9PafJcdY3dxLAp22eaaicsqLRJaaF2wNiiurkhgENkLcCvowPkLXWnYGeu56inUbb0s5GYHH3PsP4s5t8LC5pFb7ifaXfGhgHbVXlJya4cdYl2H)KTiTRgcMffgKdMewQoSN(vaLddVtLsXLYN4lJHBKnUQyKcGSGo5557Iya4YUTGiwYiSJToXoyoNebm4WVclSWeeqvGty4DA9OgENwN888ZLCBNYHH3PsP4s5t8LXWnsKadYgljfaXA7WAbfXaWvjCvowPkfwyHnxxO8c45TjL9OWrXv5yLQuyq(osbqwqNWUXeWZBtkvdxLJvQsbUs2t5ze3aCGcIVaEEBsPIGbJRYXkvPWG8DKcGSGoHDJjGN3Mu2tFGbJlimiCNkLIjpaG14ozHbliXtRXDgLddVtLsXLYN4lJHBKlOtcYMkizeGcIFeda3Maaab8yoDxkjafeFrqiyWnbaac4XC6Uusaki(eCfK7Hc5Ayo7P92PCy4DQukUu(eFzmCJeOWbYZiwBho7jn34Jya4Qo72cIyjJWo26e7G5CsekhgENkLIlLpXxgd3iXvIFUqBpJa4m(hXaWLvRaxj(5cT9mcGZ4pPjaMc45TjLCvaLddVtLsXLYN4lJHBKHbWbOBsesJZKBedax1z3wqelze2XwNyhmNtIq5WW7uPuCP8j(Yy4gPQc6yT(Ke4LvAj(rmaCxZ9CfgKVJuaKf0jmJppt80ACNf9s5t8fTg5ujPaiHhcC8ovk4NSGrBcaaebjOY1rKl8jYcseecg8LYN4lAnYPssbqcpe44DQuWpzbJg(vyHfMGaQcCcdVtRdg8AUNRWG8DKcGSGoHz85zINwJ7SOHFfwyHjiGQaNWW706rXv5yLQuyq(osbqwqNWUXeWZBtkvtHvayWR5EUcdY3rkaYc6eMXNNjEAnUZIg(vyq(occOkWjm8oToLddVtLsXLYN4lJHBKQkOJ16tsGxwPL4hXaWvD2TfeXsgHDS1j2bZ5KirBcaaebjOY1rKl8jYcseegv9lLpXx0AKtLKcGeEiWX7uPGFYcgv91CpxHb57ifazbDcZ4ZZepTg3zGbVge5Ryh(t2IWM3dUkhRuLclSWMRluEb882KskhgENkLIlLpXxgd3iHtyO7KjjYqd)igaUQZUTGiwYiSJToXoyoNeHYHH3PsP4s5t8LXWns4TWjriaoJ)skhuom8ovkfippCWCz3wqeCnUigaUnbaaczaJ9KWQIxaVH3OWG8ID4pzls)QHGzrvVLbhRXDryvUjriafKGyqKQZDWGd)kqmis15UWW706uom8ovkfippCWXWns2TfebxJlIbGlmihmjSuDOGDGbpBpT3FuyqEXo8NSfPF1qWSOQ3YGJ14UiSk3KieGcsqmis15oLddVtLsbYZdhCmCJuIRaiYjYfoC(igaUkPe7nbaacGl3dNeHOQcsMiimQs4QCSsvkSWcBUUq5fWZBtkvtzrvs9lLpXx0AKtLKcGeEiWX7uP4P14odmy1xZ9CfbjOY1raGpBRt80ACNPiyWxkFIVO1iNkjfaj8qGJ3PsXtRXDw01CpxrqcQCDea4Z26epTg3zrXv5yLQueKGkxhba(STob882Ks1uyfvemy2BcaaeaxUhojcrvfKmHCnmNQ1VIrvcxLJvQsHb57ifazbDc7gtapVnPunLbgm72cIWzoiGwbBKwJ7eRwMIuom8ovkfippCWXWnsSZunjcrcYyLkzedaxLuI9MaaabWL7HtIquvbjteegvjCvowPkfwyHnxxO8c45TjLQPSOkP(LYN4lAnYPssbqcpe44DQu80ACNbgS6R5EUIGeu56iaWNT1jEAnUZuem4lLpXx0AKtLKcGeEiWX7uP4P14ol6AUNRiibvUoca8zBDINwJ7SO4QCSsvkcsqLRJaaF2wNaEEBsPAkSIkcgm7nbaacGl3dNeHOQcsMqUgMt16xXOkHRYXkvPWG8DKcGSGoHDJjGN3MuQMYadMDBbr4mheqRGnsRXDIvltrkhgENkLcKNho4y4gj72cIGRXfXaWfgKdMewQouWoWGNTN(uqu1BzWXACxewLBsecqbjigeP6CNYHH3PsPa55HdogUrcC5E4Kie5choFedax2BcaaeaxUhojcrvfKmHCnmN90FuLWv5yLQuyHf2CDHYlGN3Mu2tSgvj1Vu(eFrRrovskas4HahVtLINwJ7mWGvFn3ZveKGkxhba(SToXtRXDgyWxkFIVO1iNkjfaj8qGJ3PsXtRXDw01CpxrqcQCDea4Z26epTg3zrXv5yLQueKGkxhba(STob882KYEIDkQiyWS3eaaiaUCpCseIQkizc5Ayo7P9OkHRYXkvPWG8DKcGSGoHDJjGN3MuQMYadMDBbr4mheqRGnsRXDIvltrkhgENkLcKNho4y4gj72cIGRXfXaWv9wgCSg3fHv5MeHauqcIbrQo31OwWcQGAu0HpWz7uzSm0aw9QxTg]] )

end
