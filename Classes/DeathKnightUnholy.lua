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
                t.expiry[ 1 ] = ( t.expiry[ 4 ] > 0 and t.expiry[ 4 ] or state.query_time ) + t.cooldown
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


    spec:RegisterPack( "Unholy", 20200425, [[dGe4DbqibQhrIsBsinksKtrcTksuqELqXSec3sOsSlc)siAysv1XKQyzsv5zKOY0qbUgkOTjurFtOszCcvsNJevvRtOsL5jf19qr7tGCqHkOfkvPhsIQYefQuLlsIQKnsIcCssufwjk0lfQuv3Kevr7uOQHsIc1sjrH8uenvHsxLevP2kjkO2lL(ludMIdt1ILspgYKr1LvTzaFgHrdKtRy1KOOxtcMnPUnkTBr)wYWf0XfQqlh0ZjA6kDDsA7sHVlGXluboVuz9srMpqTFK22Jnwlj33BJVV(7R)(zqFmu0FCLb91FFwYTl8wYqhPGtClz6S3sQ8obv6olzO3PlNBJ1sklvi6wsq7gkJ7ImsIzbP2kqfBKYHvv77ujc6aBKYHffPLSvD0RYJ02Aj5(EB891FF93pd6JHI(JRmOhgAjLHhzJVpg2NLe0W5pTTws(LilPYsnkVtqLUJAI7DFbrnX9ZHa0szuzPgq7gkJ7ImsIzbP2kqfBKYHvv77ujc6aBKYHffjLrLLAIddHJMA6JHrqn91FF9tzKYOYsnkFG8K4Y4okJkl1exOM4qo)CQr55KCQrza8VPlOmQSutCHAu(QSXH75uZ6qIV4bGAqvYNDQusnBrnWtOQDi1GQKp7uPuqzuzPM4c1OmYrJRLrQmOYLAkaQrzCf4qQzdCxbPWsQh5kTXAjVu(eDPnwB89yJ1s(0B1NB71sIGZE44wsOAEXoShVfUhQjiQHaXPMOudunheoScCi10m1WG(TKoANkTKSNTGD4caRvrdhZH3zL21gFF2yTKp9w952ETKi4ShoULKFFbH9KJ5h5DIDqkmjb1agm1e(v4HfctaQu1chTtJtnrPghTtJJFE25sQHj10JL0r7uPLSvxfhxa4f0XppBNDTXRC2yTKp9w952ETKi4ShoULujQbvLMxbsHhwix3fkVaEwFsj10m1eNutuQbvLMxbsHdz7WfaEbDm)oxapRpPKAcIAqvP5vGuGQK)uEowpahOGOlGN1NusnksnGbtnOQ08kqkCiBhUaWlOJ535c4z9jLutZutFudyWudQGq1WDQukM8aaER(4fQUGep9w95wshTtLwscvhYhpXfa2B6WAbzxB8mWgRL8P3Qp32RLebN9WXTKTQaac4rkOVuIbki6c1qQbmyQPvfaqapsb9LsmqbrhJk1CpuixhPa10m10tpwshTtLwYf0XQzBPMCmqbr3U24zOnwl5tVvFUTxljco7HJBjdMA43xqyp5y(rENyhKctsyjD0ovAjbkKQ8CS30HZEC7Dw7AJpoTXAjF6T6ZT9AjrWzpCCljVwbQs0Zf675yaTZECRkmfWZ6tkPgMut)wshTtLwsuLONl03ZXaAN921gFCZgRL8P3Qp32RLebN9WXTKbtn87liSNCm)iVtSdsHjjSKoANkTKHQWbOBscCR2LRDTXhxTXAjF6T6ZT9AjrWzpCCl566NRWHSD4caVGoM7S55INER(CQjk1CP8j6IgJCQexa4WdboANkfStwqQjk10QcaiutqLUdlx4tIfKqnKAadMAUu(eDrJrovIlaC4HahTtLc2jli1eLAc)k8WcHjavQAHJ2PXPgWGPM11pxHdz7WfaEbDm3zZZfp9w95utuQj8RWdleMauPQfoANgNAIsnOQ08kqkCiBhUaWlOJ535c4z9jLutqutC2p1agm1SU(5kCiBhUaWlOJ5oBEU4P3QpNAIsnHFfoKTdtaQu1chTtJBjD0ovAjduqnVXNedVSspr3U24v(TXAjF6T6ZT9AjrWzpCClzWud)(cc7jhZpY7e7GuyscQjk10QcaiutqLUdlx4tIfKqnKAIsnbtnxkFIUOXiNkXfao8qGJ2Psb7KfKAIsnbtnRRFUchY2Hla8c6yUZMNlE6T6ZPgWGPM1HeFf7WE8wy(CQPzQbvLMxbsHhwix3fkVaEwFsPL0r7uPLmqb18gFsm8Yk9eD7AJVN(TXAjF6T6ZT9AjrWzpCClzWud)(cc7jhZpY7e7GuysclPJ2PsljCcd1hpjwg6OBxB890JnwlPJ2Pslj8E4KeyaTZEPL8P3Qp32RDTRLKFaxvV2yTX3JnwlPJ2Pslj7KCma8VPBjF6T6ZT9AxB89zJ1s(0B1NB71swHws5xlPJ2PslzdhoER(wYgUw9wsuvAEfifsvw2kXeoKO60xapRpPKAAMAyi1eLAwx)Cfsvw2kXeoKO60x80B1NBjB4qC6S3sgwLEscmqbXeoKO603U24voBSwYNER(CBVwseC2dh3scvZbHdRahk4hyqZsnbrnXjdPMOuJsut4xbHdjQo9foANgNAadMAcMAwx)Cfsvw2kXeoKO60x80B1NtnksnrPgOAEb)adAwQjiMuddTKoANkTKoe55XBbHpx7AJNb2yTKp9w952ETKi4ShoULm8RGWHevN(chTtJtnGbtnbtnRRFUcPklBLychsuD6lE6T6ZTKoANkTKT6Q4yavyNDTXZqBSwYNER(CBVwseC2dh3s2QcaiutqLUddaF2uNqnKAadMAc)kiCir1PVWr704udyWuJsuZ66NRWHSD4caVGoM7S55INER(CQjk1e(v4HfctaQu1chTtJtnkAjD0ovAjBpuEOctsyxB8XPnwl5tVvFUTxljco7HJBjvIAAvbaeQjOs3HLl8jXcsOgsnrPMwvaabWL7HSdbOvapRpPKAAMj1WqQrrQbmyQXr7044NNDUKAcIj10h1eLAuIAAvbaeQjOs3HLl8jXcsOgsnGbtnTQaacGl3dzhcqRaEwFsj10mtQHHuJIwshTtLws9qaALyLPkNG95AxB8XnBSwYNER(CBVwseC2dh3sQe1e(vq4qIQtFHJ2PXPMOuZ66NRqQYYwjMWHevN(INER(CQrrQbmyQj8RWdleMauPQfoANg3s6ODQ0s6j6Yf6AmY1A7AJpUAJ1s(0B1NB71sIGZE44wshTtJJFE25sQjiMutFudyWuJsudunVGFGbnl1eetQHHutuQbQMdchwbouWpWGMLAcIj1eN9tnkAjD0ovAjDiYZJdv1YBxB8k)2yTKp9w952ETKi4ShoULujQj8RGWHevN(chTtJtnrPM11pxHuLLTsmHdjQo9fp9w95uJIudyWut4xHhwimbOsvlC0onUL0r7uPLeyGVvxf3U247PFBSwYNER(CBVwseC2dh3s2QcaiutqLUdlx4tIfKqnKAIsnoANgh)8SZLudtQPhQbmyQPvfaqaC5Ei7qaAfWZ6tkPMMPgceNAIsnoANgh)8SZLudtQPhlPJ2PslzRtGla8chKcs7AJVNESXAjF6T6ZT9AjrWzpCCl5oSNAcIA6RFQbmyQjyQ5Xr1jm8Cb0zdNKa7SH6zv5htmeEJsV4NetEQbmyQjyQ5Xr1jm8CrJrovIlam)SJ8wshTtLwsv5XZEwPDTX3tF2yTKp9w952ETKoANkTKEtsqo0LyGkxCbGdRahAjrWzpCClPsuZLYNOlAmYPsCbGdpe4ODQu80B1NtnrPMGPM11pxHAcQ0Dya4ZM6ep9w95uJIudyWuJsutWuZLYNOlqvYFkphRhGduq0fSUYSGutuQjyQ5s5t0fng5ujUaWHhcC0ovkE6T6ZPgfTKPZElP3KeKdDjgOYfxa4WkWH21gFpkNnwl5tVvFUTxlPJ2PslP3KeKdDjgOYfxa4WkWHwseC2dh3sIQsZRaPWdlKR7cLxapRpPKAAMA6HbutuQrjQ5s5t0fOk5pLNJ1dWbki6cwxzwqQbmyQ5s5t0fng5ujUaWHhcC0ovkE6T6ZPMOuZ66NRqnbv6oma8ztDINER(CQrrlz6S3s6njb5qxIbQCXfaoScCODTX3ddSXAjF6T6ZT9AjD0ovAj9MKGCOlXavU4cahwbo0sIGZE44wYDypElmFo10m1GQsZRaPWdlKR7cLxapRpPKAIHAuogyjtN9wsVjjih6smqLlUaWHvGdTRn(EyOnwl5tVvFUTxlPJ2PslPlb1WZlXqVPcIrf01wseC2dh3sYFRkaGa6nvqmQGUgZFRkaGqUosbQPzQPhlz6S3s6sqn88sm0BQGyubDTDTX3tCAJ1s(0B1NB71s6ODQ0s6sqn88sm0BQGyubDTLebN9WXTKHFfeQoKpEIlaS30H1cs4ODACQjk1e(v4HfctaQu1chTtJBjtN9wsxcQHNxIHEtfeJkORTRn(EIB2yTKp9w952ETKoANkTKUeudpVed9MkigvqxBjrWzpCCljQknVcKcpSqUUluEb8oVJAIsnkrnxkFIUavj)P8CSEaoqbrxW6kZcsnrPMDypElmFo10m1GQsZRaPavj)P8CSEaoqbrxapRpPKAIHA6RFQbmyQjyQ5s5t0fOk5pLNJ1dWbki6cwxzwqQrrlz6S3s6sqn88sm0BQGyubDTDTX3tC1gRL8P3Qp32RL0r7uPL0LGA45LyO3ubXOc6Aljco7HJBj3H94TW85utZudQknVcKcpSqUUluEb8S(KsQjgQPV(TKPZElPlb1WZlXqVPcIrf0121gFpk)2yTKp9w952ETKoANkTKng5ujUaW8ZoYBjrWzpCClPsudQknVcKcpSqUUluEb8oVJAIsn83QcaiaUCpCscCGsn5c56ifOMGysnmGAIsnxkFIUOXiNkXfao8qGJ2PsXtVvFo1Oi1agm10QcaiutqLUddaF2uNqnKAadMAc)kiCir1PVWr704wY0zVLSXiNkXfaMF2rE7AJVV(TXAjF6T6ZT9AjD0ovAjHoB4KeyNnupRk)yIHWBu6f)KyYBjrWzpCCljQknVcKcpSqUUluEb8S(KsQPzQPpQbmyQzD9Zv4q2oCbGxqhZD28CXtVvFo1agm1a9HJFJNRW5CPysQPzQHHwY0zVLe6SHtsGD2q9SQ8JjgcVrPx8tIjVDTX3xp2yTKp9w952ETKoANkTKTDevEC7p21SE6iljco7HJBjrvP5vGuivzzRet4qIQtFb8S(KsQjiQjo7NAadMAcMAwx)Cfsvw2kXeoKO60x80B1NtnrPMDyp1ee10x)udyWutWuZJJQty45cOZgojb2zd1ZQYpMyi8gLEXpjM8wY0zVLSTJOYJB)XUM1thzxB891Nnwl5tVvFUTxlPJ2PslPY8smOkG(qljco7HJBjd)kiCir1PVWr704udyWutWuZ66NRqQYYwjMWHevN(INER(CQjk1Sd7PMGOM(6NAadMAcMAECuDcdpxaD2WjjWoBOEwv(XedH3O0l(jXK3sMo7TKkZlXGQa6dTRn((uoBSwYNER(CBVwshTtLwscxFKR1hkXT3vWsIGZE44wYWVcchsuD6lC0ono1agm1em1SU(5kKQSSvIjCir1PV4P3QpNAIsn7WEQjiQPV(PgWGPMGPMhhvNWWZfqNnCscSZgQNvLFmXq4nk9IFsm5TKPZEljHRpY16dL427kyxB89XaBSwYNER(CBVwshTtLwscyLesCiCyDng6e3sIGZE44wsOAEQPzMuJYrnrPgLOMDyp1ee10x)udyWutWuZJJQty45cOZgojb2zd1ZQYpMyi8gLEXpjM8uJIwY0zVLKawjHehchwxJHoXTRn((yOnwl5tVvFUTxljco7HJBjrvP5vGu4q2oCbGxqhZVZfW78oQbmyQj8RGWHevN(chTtJtnGbtnTQaac1euP7WaWNn1judTKoANkTKH1ovAxB89fN2yTKp9w952ETKi4ShoULKxROXav1pxCO2juVaEwFsj10mtQHaXTKoANkTKL62cVRGDTX3xCZgRL8P3Qp32RL0r7uPLe5An2r7ujwpY1sQh5ItN9wYlLprxAxB89fxTXAjF6T6ZT9AjD0ovAjrUwJD0ovI1JCTK6rU40zVLevLMxbsPDTX3NYVnwl5tVvFUTxljco7HJBjD0ono(5zNlPMGysn9zjD0ovAjHQj2r7ujwpY1sQh5ItN9wsVUDTXRC9BJ1s(0B1NB71s6ODQ0sICTg7ODQeRh5Aj1JCXPZEljXZdhKDTRLmeEuX26RnwB89yJ1s6ODQ0sgw7uPL8P3Qp32RDTX3NnwlPJ2Pslj0h5X87Cl5tVvFUTx7AJx5SXAjF6T6ZT9AjtN9wsVjjih6smqLlUaWHvGdTKoANkTKEtsqo0LyGkxCbGdRahAxB8mWgRL8P3Qp32RLKFT3zj7Zs6ODQ0s6q2oCbGxqhZVZTRDTKOQ08kqkTXAJVhBSwshTtLwshY2Hla8c6y(DUL8P3Qp32RDTX3Nnwl5tVvFUTxljco7HJBj5VvfaqaC5E4Ke4aLAYfY1rkqnbXKAya1eLAuIAC0ono(5zNlPMGysn9rnGbtnbtnxkFIUOXiNkXfao8qGJ2PsXtVvFo1agm1em14nD4SxW6eQsCbGxqhZVZfp9w95udyWuZLYNOlAmYPsCbGdpe4ODQu80B1NtnrPgLOM11pxHAcQ0Dya4ZM6ep9w95utuQbvLMxbsHAcQ0Dya4ZM6eWZ6tkPMMzsnkh1agm1em1SU(5kutqLUddaF2uN4P3QpNAuKAu0s6ODQ0s6HfY1DHYBxB8kNnwl5tVvFUTxljco7HJBjdMAG(WXVXZv4CUu84GrUsQbmyQb6dh)gpxHZ5sXKutqutpm0s6ODQ0sYDOc4f6PeOGS(ovAxB8mWgRL8P3Qp32RLebN9WXTKq1Cq4WkWHc(bg0SutZutpmWs6ODQ0skvzzRet4qIQtF7AJNH2yTKp9w952ETKi4ShoUL8s5t0fng5ujUaWHhcC0ovkE6T6ZPMOut4xHhwimbOsvlC0ono1agm1WFRkaGa4Y9WjjWbk1KlKRJuGAAMAya1eLAcMAUu(eDrJrovIlaC4HahTtLINER(CQjk1Oe1em14nD4SxW6eQsCbGxqhZVZfp9w95udyWuJ30HZEbRtOkXfaEbDm)ox80B1NtnrPMWVcpSqycqLQw4ODACQrrlPJ2PslPAcQ0Dya4ZM6SRn(40gRL8P3Qp32RLebN9WXTKoANgh)8SZLutqmPM(OMOuJsuJsudQknVcKc(9fe2toMFK3jGN1NusnnZKAiqCQjk1em1SU(5k4hy0x80B1NtnksnGbtnkrnOQ08kqk4hy0xapRpPKAAMj1qG4utuQzD9ZvWpWOV4P3QpNAuKAu0s6ODQ0sQMGkDhga(SPo7AJpUzJ1s(0B1NB71s6ODQ0sklvngEp8qljco7HJBjxhs8vSd7XBH5ZPMMPM4k1eLAwhs8vSd7XBH5ZPMGOggyjrDi9XRdj(kTX3JDTXhxTXAjF6T6ZT9AjrWzpCClPsutWud0ho(nEUcNZLIhhmYvsnGbtnqF44345kCoxkMKAcIA6RFQrrQjk1avZtnnZKAuIA6HAIlutRkaGqnbv6oma8ztDc1qQrrlPJ2PslPSu1y49WdTRnELFBSwshTtLws1euP7WT6Ha0AjF6T6ZT9Ax7AjjEE4GSXAJVhBSwYNER(CBVwseC2dh3s2QcaiKQC(tmVkwb8oAPMOudunVyh2J3cZaQjiQHaXPMOutWutdhoER(IWQ0tsGbkiMWHevN(udyWut4xbHdjQo9foANg3s6ODQ0sYVVGWOA021gFF2yTKp9w952ETKi4ShoULeQMdchwbouWpWGMLAAMA6HbutuQbQMxSd7XBHza1ee1qG4utuQjyQPHdhVvFryv6jjWafet4qIQtFlPJ2Pslj)(ccJQrBxB8kNnwl5tVvFUTxljco7HJBjvIAuIA4VvfaqaC5E4Ke4aLAYfQHutuQrjQbvLMxbsHhwix3fkVaEwFsj1ee1WqQjk1Oe1em1CP8j6IgJCQexa4WdboANkfp9w95udyWutWuZ66NRqnbv6oma8ztDINER(CQrrQbmyQ5s5t0fng5ujUaWHhcC0ovkE6T6ZPMOuZ66NRqnbv6oma8ztDINER(CQjk1GQsZRaPqnbv6oma8ztDc4z9jLutqutCsnksnksnGbtn83QcaiaUCpCscCGsn5c56ifOMGOggqnksnrPgLOguvAEfifoKTdxa4f0X87Cb8S(KsQjiQHHudyWud)(ccRqoeGwbFKER(yVwo1OOL0r7uPLuIkviXXYfokC7AJNb2yTKp9w952ETKi4ShoULujQrjQH)wvaabWL7HtsGduQjxOgsnrPgLOguvAEfifEyHCDxO8c4z9jLutquddPMOuJsutWuZLYNOlAmYPsCbGdpe4ODQu80B1NtnGbtnbtnRRFUc1euP7WaWNn1jE6T6ZPgfPgWGPMlLprx0yKtL4cahEiWr7uP4P3QpNAIsnRRFUc1euP7WaWNn1jE6T6ZPMOudQknVcKc1euP7WaWNn1jGN1NusnbrnXj1Oi1Oi1agm1WFRkaGa4Y9WjjWbk1KlKRJuGAcIAya1Oi1eLAuIAqvP5vGu4q2oCbGxqhZVZfWZ6tkPMGOggsnGbtn87liSc5qaAf8r6T6J9A5uJIwshTtLwsK2dmjbwcY5vaPDTXZqBSwYNER(CBVwseC2dh3scvZbHdRahk4hyqZsnntn91p1eLAcMAA4WXB1xewLEscmqbXeoKO603s6ODQ0sYVVGWOA021gFCAJ1s(0B1NB71sIGZE44ws(BvbaeaxUhojboqPMCHCDKcutZuddOMOuJsudQknVcKcpSqUUluEb8S(KsQPzQr5OMOuJsutWuZLYNOlAmYPsCbGdpe4ODQu80B1NtnGbtnbtnRRFUc1euP7WaWNn1jE6T6ZPgWGPMlLprx0yKtL4cahEiWr7uP4P3QpNAIsnRRFUc1euP7WaWNn1jE6T6ZPMOudQknVcKc1euP7WaWNn1jGN1NusnntnXnQrrQrrQbmyQH)wvaabWL7HtsGduQjxixhPa10m10d1eLAuIAqvP5vGu4q2oCbGxqhZVZfWZ6tkPMGOggsnGbtn87liSc5qaAf8r6T6J9A5uJIwshTtLwsGl3dNKalx4OWTRn(4Mnwl5tVvFUTxljco7HJBjdMAA4WXB1xewLEscmqbXeoKO603s6ODQ0sYVVGWOA021UwsVUnwB89yJ1s(0B1NB71sIGZE44wsuvAEfifEyHCDxO8c4z9jLwshTtLws(9fe2toMFK3zxB89zJ1s(0B1NB71sIGZE44wsuvAEfifEyHCDxO8c4z9jLwshTtLws(bg9TRnELZgRL8P3Qp32RLebN9WXTK87liSNCm)iVtSdsHjjOMOudunheoScCOGFGbnl10m1Oe10ddOMyOg(9fewHCiaTcGaLAYphVoK4RKAugIAuoQrrQjk1em10WHJ3QViSk9KeyGcIjCir1PVL0r7uPL8Hd)SdYU24zGnwl5tVvFUTxljco7HJBj53xqyp5y(rENyhKctsqnrPgLOMGPg(9fewHCiaTcGaLAYphVoK4RKAIsnRRFUIwvOCNKall4LINER(CQrrQjk1em10WHJ3QViSk9KeyGcIjCir1PVL0r7uPL8Hd)SdYU24zOnwl5tVvFUTxljco7HJBj53xqyp5y(rENyhKctsqnrPgOAoiCyf4qb)adAwQPzQPhgqnrPMGPMgoC8w9fHvPNKaduqmHdjQo9TKoANkTK87limQgTDTXhN2yTKp9w952ETKi4ShoULKFFbH9KJ5h5DIDqkmjb1eLAqvP5vGu4HfY1DHYlGN1NuAjD0ovAjLOsfsCSCHJc3U24JB2yTKp9w952ETKi4ShoULKFFbH9KJ5h5DIDqkmjb1eLAqvP5vGu4HfY1DHYlGN1NuAjD0ovAjrApWKeyjiNxbK21gFC1gRL8P3Qp32RLebN9WXTKbtnnC44T6lcRspjbgOGychsuD6BjD0ovAjF4Wp7GSRnELFBSwYNER(CBVwshTtLwsGl3dNKalx4OWTKi4ShoULK)wvaabWL7HtsGduQjxixhPa10mtQPpQjk1GQsZRaPGFFbH9KJ5h5Dc4z9jLutuQbvLMxbsHhwix3fkVaEwFsj1ee1WqQjk1Oe1GQsZRaPWHSD4caVGoMFNlGN1NusnbrnmKAadMA43xqyfYHa0k4J0B1h71YPgfTKOoK(41HeFL247XU247PFBSwYNER(CBVwseC2dh3s2QcaiKQC(tmVkwb8oAPMOudunVyh2J3cZaQjiQHaXTKoANkTK87limQgTDTX3tp2yTKp9w952ETKi4ShoULSvfaqiv58NyEvSc4D0snrPMGPMgoC8w9fHvPNKaduqmHdjQo9PgWGPMWVcchsuD6lC0onUL0r7uPLKFFbHr1OTRn(E6ZgRL8P3Qp32RLebN9WXTKq1Cq4WkWHc(bg0SutZutpmGAIsnkrnOQ08kqk8Wc56Uq5fWZ6tkPMGOggsnGbtn83QcaiaUCpCscCGsn5c56ifOMGOggqnksnrPMGPMgoC8w9fHvPNKaduqmHdjQo9TKoANkTK87limQgTDTX3JYzJ1s(0B1NB71s6ODQ0skrLkK4y5chfULebN9WXTKkrnkrnOQ08kqkCiBhUaWlOJ535c4z9jLutquddPgWGPg(9fewHCiaTc(i9w9XETCQrrQjk1Oe1GQsZRaPWdlKR7cLxapRpPKAcIAyi1eLA4VvfaqaC5E4Ke4aLAYfY1rkqnbrn9tnGbtn83QcaiaUCpCscCGsn5c56ifOMGOggqnksnrPgLOMDypElmFo10m1GQsZRaPGFFbH9KJ5h5Dc4z9jLutmutp9tnGbtn7WE8wy(CQjiQbvLMxbsHhwix3fkVaEwFsj1Oi1OOLe1H0hVoK4R0gFp21gFpmWgRL8P3Qp32RL0r7uPLeP9atsGLGCEfqAjrWzpCClPsuJsudQknVcKchY2Hla8c6y(DUaEwFsj1ee1WqQbmyQHFFbHvihcqRGpsVvFSxlNAuKAIsnkrnOQ08kqk8Wc56Uq5fWZ6tkPMGOggsnrPg(BvbaeaxUhojboqPMCHCDKcutqut)udyWud)TQaacGl3dNKahOutUqUosbQjiQHbuJIutuQrjQzh2J3cZNtnntnOQ08kqk43xqyp5y(rENaEwFsj1ed10t)udyWuZoShVfMpNAcIAqvP5vGu4HfY1DHYlGN1NusnksnkAjrDi9XRdj(kTX3JDTX3ddTXAjF6T6ZT9AjrWzpCCljunheoScCOGFGbnl10m10x)utuQjyQPHdhVvFryv6jjWafet4qIQtFlPJ2Pslj)(ccJQrBxB89eN2yTKp9w952ETKi4ShoULujQrjQrjQrjQH)wvaabWL7HtsGduQjxixhPa10m1WaQjk1em10QcaiutqLUddaF2uNqnKAuKAadMA4VvfaqaC5E4Ke4aLAYfY1rkqnntnkh1Oi1eLAqvP5vGu4HfY1DHYlGN1Nusnntnkh1Oi1agm1WFRkaGa4Y9WjjWbk1KlKRJuGAAMA6HAuKAIsnkrnOQ08kqkCiBhUaWlOJ535c4z9jLutquddPgWGPg(9fewHCiaTc(i9w9XETCQrrlPJ2PsljWL7HtsGLlCu421gFpXnBSwYNER(CBVwseC2dh3sYVVGWEYX8J8oXoifMKWs6ODQ0skrLkK4y5chfUDTRDTKnouovAJVV(7R)(vU(7XsgWH5KeslPYd2WcUNtnXj14ODQKA0JCLckJwsxDbvqlj5WQQ9DQu5d6aRLmewaJ(wsLLAuENGkDh1e37(cIAI7NdbOLYOYsnG2nug3fzKeZcsTvGk2iLdRQ23Pse0b2iLdlkskJkl1ehgchn10hdJGA6R)(6NYiLrLLAu(a5jXLXDugvwQjUqnXHC(5uJYZj5uJYa4FtxqzuzPM4c1O8vzJd3ZPM1HeFXda1GQKp7uPKA2IAGNqv7qQbvjF2PsPGYOYsnXfQrzKJgxlJuzqLl1uauJY4kWHuZg4UcsbLrkJkl1O8ko4i19CQP9af8udQyB9LAApXKsb1ehIqpCLutwzCbKdzbu1uJJ2Psj1uPUtqzuzPghTtLsri8OIT1xMaAxQaLrLLAC0ovkfHWJk2wFJHzKavXPmQSuJJ2PsPieEuX26BmmJ0vjyFU(ovszuzPgY0dLGQLAG(WPMwvaGZPg56RKAApqbp1Gk2wFPM2tmPKA8KtnHWhxcRDNKGAgj1WR8ckJkl14ODQukcHhvST(gdZiLPhkbvlwU(kPm6ODQukcHhvST(gdZidRDQKYOJ2PsPieEuX26BmmJe6J8y(DoLrhTtLsri8OIT13yygPQ84zpBePZEMEtsqo0LyGkxCbGdRahsz0r7uPuecpQyB9ngMr6q2oCbGxqhZVZJGFT3XSpkJugvwQr5vCWrQ75uZBCyh1Sd7PMf0PghTfKAgj14n8r7T6lOm6ODQuYKDsoga(30Pm6ODQugdZiB4WXB1pI0zpZWQ0tsGbkiMWHevN(r0W1QNjQknVcKcPklBLychsuD6lGN1Nu2mdJUU(5kKQSSvIjCir1PV4P3QpNYOYsnkJC04AzeuJYJ9SYiOgp5utTGoKAkcexsz0r7uPmgMr6qKNhVfe(CJyaycvZbHdRahk4hyqZguCYWOkf(vq4qIQtFHJ2PXbdo411pxHuLLTsmHdjQo9fp9w95kgfQMxWpWGMniMmKYOJ2PszmmJSvxfhdOc7Iyayg(vq4qIQtFHJ2PXbdo411pxHuLLTsmHdjQo9fp9w95ugD0ovkJHzKThkpuHjjIyay2QcaiutqLUddaF2uNqnem4WVcchsuD6lC0onoyWkTU(5kCiBhUaWlOJ5oBEU4P3QppA4xHhwimbOsvlC0onUIugD0ovkJHzK6Ha0kXktvob7ZnIbGPsTQaac1euP7WYf(KybjudJ2QcaiaUCpKDiaTc4z9jLnZKHkcgSJ2PXXpp7Czqm7lQsTQaac1euP7WYf(KybjudbdUvfaqaC5Ei7qaAfWZ6tkBMjdvKYOJ2PszmmJ0t0Ll01yKR1rmamvk8RGWHevN(chTtJhDD9ZvivzzRet4qIQtFXtVvFUIGbh(v4HfctaQu1chTtJtz0r7uPmgMr6qKNhhQQLpIbGPJ2PXXpp7Czqm7dmyLGQ5f8dmOzdIjdJcvZbHdRahk4hyqZgeZ4SFfPm6ODQugdZibg4B1vXJyayQu4xbHdjQo9foANgp666NRqQYYwjMWHevN(INER(Cfbdo8RWdleMauPQfoANgNYOJ2PszmmJS1jWfaEHdsbzedaZwvaaHAcQ0Dy5cFsSGeQHrD0ono(5zNlz2dyWTQaacGl3dzhcqRaEwFszZeiEuhTtJJFE25sM9qzKYOYsnkFQYTyPMfoPcFLuJQ0joLrhTtLYyygPQ84zpRmIbG5oSpO(6hm4GFCuDcdpxaD2WjjWoBOEwv(XedH3O0l(jXKhm4GFCuDcdpx0yKtL4caZp7ipLrhTtLYyygPQ84zpBePZEMEtsqo0LyGkxCbGdRahgXaWuPlLprx0yKtL4cahEiWr7uP4P3QppAWRRFUc1euP7WaWNn1jE6T6ZvemyLc(s5t0fOk5pLNJ1dWbki6cwxzwWObFP8j6IgJCQexa4WdboANkfp9w95ksz0r7uPmgMrQkpE2Zgr6SNP3KeKdDjgOYfxa4WkWHrmamrvP5vGu4HfY1DHYlGN1Nu2CpmiQsxkFIUavj)P8CSEaoqbrxW6kZccg8LYNOlAmYPsCbGdpe4ODQu80B1NhDD9ZvOMGkDhga(SPoXtVvFUIugD0ovkJHzKQYJN9SrKo7z6njb5qxIbQCXfaoScCyedaZDypElmFEZOQ08kqk8Wc56Uq5fWZ6tkJr5yaLrhTtLYyygPQ84zpBePZEMUeudpVed9MkigvqxhXaWK)wvaab0BQGyubDnM)wvaaHCDKcn3dLrhTtLYyygPQ84zpBePZEMUeudpVed9MkigvqxhXaWm8RGq1H8XtCbG9MoSwqchTtJhn8RWdleMauPQfoANgNYOJ2PszmmJuvE8SNnI0zptxcQHNxIHEtfeJkORJyayIQsZRaPWdlKR7cLxaVZ7IQ0LYNOlqvYFkphRhGduq0fSUYSGr3H94TW85nJQsZRaPavj)P8CSEaoqbrxapRpPmM(6hm4GVu(eDbQs(t55y9aCGcIUG1vMfurkJoANkLXWmsv5XZE2isN9mDjOgEEjg6nvqmQGUoIbG5oShVfMpVzuvAEfifEyHCDxO8c4z9jLX0x)ugD0ovkJHzKQYJN9SrKo7z2yKtL4caZp7iFedatLqvP5vGu4HfY1DHYlG35Dr5VvfaqaC5E4Ke4aLAYfY1rkeetge9s5t0fng5ujUaWHhcC0ovkE6T6Zvem4wvaaHAcQ0Dya4ZM6eQHGbh(vq4qIQtFHJ2PXPm6ODQugdZivLhp7zJiD2Ze6SHtsGD2q9SQ8JjgcVrPx8tIjFedatuvAEfifEyHCDxO8c4z9jLn3hyWRRFUchY2Hla8c6yUZMNlE6T6Zbdg6dh)gpxHZ5sXKnZqkJoANkLXWmsv5XZE2isN9mB7iQ842FSRz90rrmamrvP5vGuivzzRet4qIQtFb8S(KYGIZ(bdo411pxHuLLTsmHdjQo9fp9w95r3H9b1x)Gbh8JJQty45cOZgojb2zd1ZQYpMyi8gLEXpjM8ugD0ovkJHzKQYJN9SrKo7zQmVedQcOpmIbGz4xbHdjQo9foANghm4Gxx)Cfsvw2kXeoKO60x80B1NhDh2huF9dgCWpoQoHHNlGoB4KeyNnupRk)yIHWBu6f)KyYtz0r7uPmgMrQkpE2Zgr6SNjHRpY16dL427keXaWm8RGWHevN(chTtJdgCWRRFUcPklBLychsuD6lE6T6ZJUd7dQV(bdo4hhvNWWZfqNnCscSZgQNvLFmXq4nk9IFsm5Pm6ODQugdZivLhp7zJiD2ZKawjHehchwxJHoXJyaycvZ3mtLlQs7W(G6RFWGd(Xr1jm8Cb0zdNKa7SH6zv5htmeEJsV4NetEfPm6ODQugdZidRDQmIbGjQknVcKchY2Hla8c6y(DUaEN3bgC4xbHdjQo9foANghm4wvaaHAcQ0Dya4ZM6eQHugvwQr5Pp56tojb1Om8av1pxQrzS2jup1msQXPMq4uWz7Om6ODQugdZil1TfExHigaM8AfngOQ(5Id1oH6fWZ6tkBMjbItz0r7uPmgMrICTg7ODQeRh5gr6SN5LYNOlPm6ODQugdZirUwJD0ovI1JCJiD2ZevLMxbsjLrhTtLYyygjunXoANkX6rUrKo7z61Jyay6ODAC8ZZoxgeZ(Om6ODQugdZirUwJD0ovI1JCJiD2ZK45HdIYiLrLLAIdlLxudSwFNkPm6ODQuk86m53xqyp5y(rExedatuvAEfifEyHCDxO8c4z9jLugD0ovkfE9yygj)aJ(rmamrvP5vGu4HfY1DHYlGN1Nusz0r7uPu41JHzKpC4NDqrmam53xqyp5y(rENyhKctsefQMdchwbouWpWGMTzL6HbXWVVGWkKdbOvaeOut(541HeFLkdPCkgn4goC8w9fHvPNKaduqmHdjQo9Pm6ODQuk86XWmYho8ZoOigaM87liSNCm)iVtSdsHjjIQuW87liSc5qaAfabk1KFoEDiXxz011pxrRkuUtsGLf8sXtVvFUIrdUHdhVvFryv6jjWafet4qIQtFkJoANkLcVEmmJKFFbHr1OJyayYVVGWEYX8J8oXoifMKikunheoScCOGFGbnBZ9WGOb3WHJ3QViSk9KeyGcIjCir1PpLrhTtLsHxpgMrkrLkK4y5chfEedat(9fe2toMFK3j2bPWKerrvP5vGu4HfY1DHYlGN1Nusz0r7uPu41JHzKiThyscSeKZRaYigaM87liSNCm)iVtSdsHjjIIQsZRaPWdlKR7cLxapRpPKYOJ2PsPWRhdZiF4Wp7GIyaygCdhoER(IWQ0tsGbkiMWHevN(ugD0ovkfE9yygjWL7HtsGLlCu4rG6q6Jxhs8vYSNigaM83QcaiaUCpCscCGsn5c56ifAMzFrrvP5vGuWVVGWEYX8J8ob8S(KYOOQ08kqk8Wc56Uq5fWZ6tkdIHrvcvLMxbsHdz7WfaEbDm)oxapRpPmigcgm)(ccRqoeGwbFKER(yVwUIugD0ovkfE9yygj)(ccJQrhXaWSvfaqiv58NyEvSc4D0gfQMxSd7XBHzqqeioLrhTtLsHxpgMrYVVGWOA0rmamBvbaesvo)jMxfRaEhTrdUHdhVvFryv6jjWafet4qIQtFWGd)kiCir1PVWr704ugD0ovkfE9yygj)(ccJQrhXaWeQMdchwbouWpWGMT5EyquLqvP5vGu4HfY1DHYlGN1NugedbdM)wvaabWL7HtsGduQjxixhPqqmqXOb3WHJ3QViSk9KeyGcIjCir1PpLrhTtLsHxpgMrkrLkK4y5chfEeOoK(41HeFLm7jIbGPskHQsZRaPWHSD4caVGoMFNlGN1NugedbdMFFbHvihcqRGpsVvFSxlxXOkHQsZRaPWdlKR7cLxapRpPmiggL)wvaabWL7HtsGduQjxixhPqq9dgm)TQaacGl3dNKahOutUqUosHGyGIrvAh2J3cZN3mQknVcKc(9fe2toMFK3jGN1Nugtp9dg8oShVfMppiuvAEfifEyHCDxO8c4z9jLkQiLrhTtLsHxpgMrI0EGjjWsqoVciJa1H0hVoK4RKzprmamvsjuvAEfifoKTdxa4f0X87Cb8S(KYGyiyW87liSc5qaAf8r6T6J9A5kgvjuvAEfifEyHCDxO8c4z9jLbXWO83QcaiaUCpCscCGsn5c56ifcQFWG5VvfaqaC5E4Ke4aLAYfY1rkeedumQs7WE8wy(8MrvP5vGuWVVGWEYX8J8ob8S(KYy6PFWG3H94TW85bHQsZRaPWdlKR7cLxapRpPurfPm6ODQuk86XWms(9fegvJoIbGjunheoScCOGFGbnBZ91F0GB4WXB1xewLEscmqbXeoKO60NYOJ2PsPWRhdZibUCpCscSCHJcpIbGPskPKs83QcaiaUCpCscCGsn5c56ifAMbrdUvfaqOMGkDhga(SPoHAOIGbZFRkaGa4Y9WjjWbk1KlKRJuOzLtXOOQ08kqk8Wc56Uq5fWZ6tkBw5uemy(BvbaeaxUhojboqPMCHCDKcn3JIrvcvLMxbsHdz7WfaEbDm)oxapRpPmigcgm)(ccRqoeGwbFKER(yVwUIugD0ovkfE9yygPevQqIJLlCu4rmam53xqyp5y(rENyhKctsqzKYOJ2PsPavLMxbsjthY2Hla8c6y(DoLrhTtLsbQknVcKYyygPhwix3fkFedat(BvbaeaxUhojboqPMCHCDKcbXKbrvYr7044NNDUmiM9bgCWxkFIUOXiNkXfao8qGJ2PsXtVvFoyWb7nD4SxW6eQsCbGxqhZVZfp9w95GbFP8j6IgJCQexa4WdboANkfp9w95rvAD9ZvOMGkDhga(SPoXtVvFEuuvAEfifQjOs3HbGpBQtapRpPSzMkhyWbVU(5kutqLUddaF2uN4P3QpxrfPm6ODQukqvP5vGugdZi5oub8c9ucuqwFNkJyaygm0ho(nEUcNZLIhhmYvcgm0ho(nEUcNZLIjdQhgsz0r7uPuGQsZRaPmgMrkvzzRet4qIQt)igaMq1Cq4WkWHc(bg0Sn3ddOm6ODQukqvP5vGugdZivtqLUddaF2uxedaZlLprx0yKtL4cahEiWr7uP4P3QppA4xHhwimbOsvlC0onoyW83QcaiaUCpCscCGsn5c56ifAMbrd(s5t0fng5ujUaWHhcC0ovkE6T6ZJQuWEtho7fSoHQexa4f0X87CXtVvFoyWEtho7fSoHQexa4f0X87CXtVvFE0WVcpSqycqLQw4ODACfPm6ODQukqvP5vGugdZivtqLUddaF2uxedathTtJJFE25YGy2xuLucvLMxbsb)(cc7jhZpY7eWZ6tkBMjbIhn411pxb)aJ(INER(CfbdwjuvAEfif8dm6lGN1Nu2mtcep666NRGFGrFXtVvFUIksz0r7uPuGQsZRaPmgMrklvngEp8WiqDi9XRdj(kz2tedaZ1HeFf7WE8wy(8MJRrxhs8vSd7XBH5ZdIbugD0ovkfOQ08kqkJHzKYsvJH3dpmIbGPsbd9HJFJNRW5CP4XbJCLGbd9HJFJNRW5CPyYG6RFfJcvZ3mtL6jU0QcaiutqLUddaF2uNqnurkJoANkLcuvAEfiLXWms1euP7WT6Ha0szKYOJ2PsP4s5t0LmzpBb7WfawRIgoMdVZkJyaycvZl2H94TW9eebIhfQMdchwboSzg0pLrhTtLsXLYNOlJHzKT6Q44caVGo(5z7IyayYVVGWEYX8J8oXoifMKam4WVcpSqycqLQw4ODA8OoANgh)8SZLm7HYOJ2PsP4s5t0LXWmscvhYhpXfa2B6WAbfXaWujuvAEfifEyHCDxO8c4z9jLnhNrrvP5vGu4q2oCbGxqhZVZfWZ6tkdcvLMxbsbQs(t55y9aCGcIUaEwFsPIGbJQsZRaPWHSD4caVGoMFNlGN1Nu2CFGbJkiunCNkLIjpaG3QpEHQliXtVvFoLrhTtLsXLYNOlJHzKlOJvZ2sn5yGcIEedaZwvaab8if0xkXafeDHAiyWTQaac4rkOVuIbki6yuPM7Hc56ifAUNEOm6ODQukUu(eDzmmJeOqQYZXEtho7XT3zJyaygm)(cc7jhZpY7e7GuysckJoANkLIlLprxgdZirvIEUqFphdOD2hXaWKxRavj65c99CmG2zpUvfMc4z9jLm7NYOJ2PsP4s5t0LXWmYqv4a0njbUv7YnIbGzW87liSNCm)iVtSdsHjjOm6ODQukUu(eDzmmJmqb18gFsm8Yk9e9igaMRRFUchY2Hla8c6yUZMNlE6T6ZJEP8j6IgJCQexa4WdboANkfStwWOTQaac1euP7WYf(Kybjudbd(s5t0fng5ujUaWHhcC0ovkyNSGrd)k8WcHjavQAHJ2PXbdED9Zv4q2oCbGxqhZD28CXtVvFE0WVcpSqycqLQw4ODA8OOQ08kqkCiBhUaWlOJ535c4z9jLbfN9dg866NRWHSD4caVGoM7S55INER(8OHFfoKTdtaQu1chTtJtz0r7uPuCP8j6YyygzGcQ5n(Ky4Lv6j6rmamdMFFbH9KJ5h5DIDqkmjr0wvaaHAcQ0Dy5cFsSGeQHrd(s5t0fng5ujUaWHhcC0ovkyNSGrdED9Zv4q2oCbGxqhZD28CXtVvFoyWRdj(k2H94TW85nJQsZRaPWdlKR7cLxapRpPKYOJ2PsP4s5t0LXWms4egQpEsSm0rpIbGzW87liSNCm)iVtSdsHjjOm6ODQukUu(eDzmmJeEpCscmG2zVKYiLrhTtLsbXZdhet(9fegvJoIbGzRkaGqQY5pX8QyfW7OnkunVyh2J3cZGGiq8Ob3WHJ3QViSk9KeyGcIjCir1PpyWHFfeoKO60x4ODACkJoANkLcINhoOyygj)(ccJQrhXaWeQMdchwbouWpWGMT5EyquOAEXoShVfMbbrG4rdUHdhVvFryv6jjWafet4qIQtFkJoANkLcINhoOyygPevQqIJLlCu4rmamvsj(BvbaeaxUhojboqPMCHAyuLqvP5vGu4HfY1DHYlGN1NugedJQuWxkFIUOXiNkXfao8qGJ2PsXtVvFoyWbVU(5kutqLUddaF2uN4P3QpxrWGVu(eDrJrovIlaC4HahTtLINER(8ORRFUc1euP7WaWNn1jE6T6ZJIQsZRaPqnbv6oma8ztDc4z9jLbfNkQiyW83QcaiaUCpCscCGsn5c56ifcIbkgvjuvAEfifoKTdxa4f0X87Cb8S(KYGyiyW87liSc5qaAf8r6T6J9A5ksz0r7uPuq88WbfdZirApWKeyjiNxbKrmamvsj(BvbaeaxUhojboqPMCHAyuLqvP5vGu4HfY1DHYlGN1NugedJQuWxkFIUOXiNkXfao8qGJ2PsXtVvFoyWbVU(5kutqLUddaF2uN4P3QpxrWGVu(eDrJrovIlaC4HahTtLINER(8ORRFUc1euP7WaWNn1jE6T6ZJIQsZRaPqnbv6oma8ztDc4z9jLbfNkQiyW83QcaiaUCpCscCGsn5c56ifcIbkgvjuvAEfifoKTdxa4f0X87Cb8S(KYGyiyW87liSc5qaAf8r6T6J9A5ksz0r7uPuq88WbfdZi53xqyun6igaMq1Cq4WkWHc(bg0Sn3x)rdUHdhVvFryv6jjWafet4qIQtFkJoANkLcINhoOyygjWL7HtsGLlCu4rmam5VvfaqaC5E4Ke4aLAYfY1rk0mdIQeQknVcKcpSqUUluEb8S(KYMvUOkf8LYNOlAmYPsCbGdpe4ODQu80B1NdgCWRRFUc1euP7WaWNn1jE6T6Zbd(s5t0fng5ujUaWHhcC0ovkE6T6ZJUU(5kutqLUddaF2uN4P3QppkQknVcKc1euP7WaWNn1jGN1Nu2CCtrfbdM)wvaabWL7HtsGduQjxixhPqZ9evjuvAEfifoKTdxa4f0X87Cb8S(KYGyiyW87liSc5qaAf8r6T6J9A5ksz0r7uPuq88WbfdZi53xqyun6igaMb3WHJ3QViSk9KeyGcIjCir1PVDTR1c]] )

end
