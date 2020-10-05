-- DeathKnightUnholy.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local roundUp = ns.roundUp

local PTR = ns.PTR


-- Conduits
-- [x] Convocation of the Dead
-- [-] Embrace Death
-- [x] Eternal Hunger
-- [x] Lingering Plague


if UnitClassBase( "player" ) == "DEATHKNIGHT" then
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
        },      
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
            if k == "actual" then
                local amount = 0

                for i = 1, 6 do
                    if t.expiry[ i ] <= state.query_time then
                        amount = amount + 1
                    end
                end

                return amount

            elseif k == "current" then
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
            
            elseif k == "deficit" then
                return t.max - t.current

            elseif k == "time_to_next" then
                return t[ "time_to_" .. t.current + 1 ]

            elseif k == "time_to_max" then
                return t.current == 6 and 0 or max( 0, t.expiry[6] - state.query_time )


            elseif k == "add" then
                return t.gain

            else
                local amount = k:match( "time_to_(%d+)" )
                amount = amount and tonumber( amount )

                if amount then return state:TimeToResource( t, amount ) end
            end
        end
    } ) )

    spec:RegisterResource( Enum.PowerType.RunicPower, {
        swarming_mist = {
            aura = "swarming_mist",

            last = function ()
                local app = state.debuff.swarming_mist.applied
                local t = state.query_time

                return app + floor( ( t - app ) / class.auras.swarming_mist.tick_time ) * class.auras.swarming_mist.tick_time
            end,

            interval = function () return class.auras.swarming_mist.tick_time end,
            value = function () return min( 15, state.true_active_enemies * 3 ) end,
        },          
    } )


    spec:RegisterStateFunction( "apply_festermight", function( n )
        if azerite.festermight.enabled then
            if buff.festermight.up then
                addStack( "festermight", buff.festermight.remains, n )
            else
                applyBuff( "festermight", nil, n )
            end
        end
    end )

    
    local spendHook = function( amt, resource, noHook )
        if amt > 0 and resource == "runes" and active_dot.shackle_the_unworthy > 0 then
            reduceCooldown( "shackle_the_unworthy", 4 * amt )
        end
    end

    spec:RegisterHook( "spend", spendHook )


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
        soul_reaper = 22526, -- 343294

        spell_eater = 22528, -- 207321
        wraith_walk = 22529, -- 212552
        death_pact = 23373, -- 48743

        pestilence = 22532, -- 277234
        unholy_pact = 22534, -- 319230
        defile = 22536, -- 152280

        army_of_the_damned = 22030, -- 276837
        summon_gargoyle = 22110, -- 49206
        unholy_assault = 22538, -- 207289
    } )


    -- PvP Talents
    spec:RegisterPvpTalents( { 
        cadaverous_pallor = 163, -- 201995
        dark_simulacrum = 41, -- 77606
        decomposing_aura = 3440, -- 199720
        dome_of_ancient_shadow = 5367, -- 328718
        life_and_death = 40, -- 288855
        necromancers_bargain = 3746, -- 288848
        necrotic_aura = 3437, -- 199642
        necrotic_strike = 149, -- 223829
        raise_abomination = 3747, -- 288853
        reanimation = 152, -- 210128
        transfusion = 3748, -- 288977
    } )


    -- Auras
    spec:RegisterAuras( {
        antimagic_shell = {
            id = 48707,
            duration = function () return ( talent.spell_eater.enabled and 10 or 5 ) + ( conduit.reinforced_shell.mod * 0.001 ) end,
            max_stack = 1,
        },
        antimagic_zone = {
            id = 145629,
            duration = 3600,
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
        chains_of_ice = {
            id = 45524,
            duration = 8,
            max_stack = 1,
        },
        dark_command = {
            id = 56222,
            duration = 3,
            max_stack = 1,
        },
        dark_succor = {
            id = 101568,
            duration = 20,
        },
        dark_transformation = {
            id = 63560, 
            duration = function () return 15 + ( conduit.eternal_hunger.mod * 0.001 ) end,
            generate = function( t )
                local cast = class.abilities.dark_transformation.lastCast or 0
                local up = pet.ghoul.up and cast + t.duration > state.query_time

                t.name = t.name or class.abilities.dark_transformation.name
                t.count = up and 1 or 0
                t.expires = up and cast + t.duration or 0
                t.applied = up and cast or 0
                t.caster = "player"
            end,
        },
        death_and_decay = {
            id = 188290,
            duration = 10,
            max_stack = 1,
        },
        death_pact = {
            id = 48743,
            duration = 15,
            max_stack = 1,
        },
        deaths_advance = {
            id = 48265,
            duration = 10,
            max_stack = 1,
        },
        defile = {
            id = 152280,
            duration = 10,
        },
        festering_wound = {
            id = 194310,
            duration = 30,
            max_stack = 6,
            --[[ meta = {
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
            } ]]
        },
        frostbolt = {
            id = 317792,
            duration = 4,
            max_stack = 1,
        },
        gnaw = {
            id = 91800,
            duration = 0.5,
            max_stack = 1,
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
        lichborne = {
            id = 49039,
            duration = 10,
            max_stack = 1,
        },
        on_a_pale_horse = {
            id = 51986,
        },
        path_of_frost = {
            id = 3714,
            duration = 600,
            max_stack = 1,k
        },
        runic_corruption = {
            id = 51460,
            duration = function () return 3 * haste end,
            max_stack = 1,
        },
        soul_reaper = {
            id = 343294,
            duration = 5,
            type = "Magic",
            max_stack = 1,
        },
        sudden_doom = {
            id = 81340,
            duration = 10,
            max_stack = function () return talent.harbinger_of_doom.enabled and 2 or 1 end,
        },
        unholy_assault = {
            id = 207289,
            duration = 12,
            max_stack = 1,
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
            max_stack = 4,
        },
        unholy_pact = {
            id = 319230,
            duration = 15,
            max_stack = 1,
        },
        unholy_strength = {
            id = 53365,
            duration = 15,
            max_stack = 1,
        },
        virulent_plague = {
            id = 191587,
            duration = function () return 27 * ( talent.ebon_fever.enabled and 0.5 or 1 ) end,
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


    spec:RegisterStateTable( "death_and_decay", 
        setmetatable( { onReset = function( self ) end },
        { __index = function( t, k )
            if k == "ticking" then
                return buff.death_and_decay.up

            elseif k == "remains" then
                return buff.death_and_decay.remains

            end

            return false
        end } ) )

    spec:RegisterStateTable( "defile", 
        setmetatable( { onReset = function( self ) end },
        { __index = function( t, k )
            if k == "ticking" then
                return buff.death_and_decay.up

            elseif k == "remains" then
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
        return 3600
        --[[ No timeable wounds mechanic in SL?
        if buff.unholy_frenzy.down then return 3600 end

        local deficit = x - debuff.festering_wound.stack
        local swing, speed = state.swings.mainhand, state.swings.mainhand_speed

        local last = swing + ( speed * floor( query_time - swing ) / swing )
        local fw = last + ( speed * deficit ) - query_time

        if fw > buff.unholy_frenzy.remains then return 3600 end
        return fw ]]
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

        if state:IsKnown( "deaths_due" ) and cooldown.deaths_due.remains then setCooldown( "death_and_decay", cooldown.deaths_due.remains ) end
        if talent.defile.enabled and cooldown.defile.remains then setCooldown( "death_and_decay", cooldown.defile.remains ) end
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

            toggle = "defensives",

            startsCombat = false,
            texture = 136120,

            handler = function ()
                applyBuff( "antimagic_shell" )
            end,
        },


        antimagic_zone = {
            id = 51052,
            cast = 0,
            cooldown = 120,
            gcd = "spell",
            
            toggle = "defensives",

            startsCombat = false,
            texture = 237510,
            
            handler = function ()
                applyBuff( "antimagic_zone" )
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
                    if conduit.convocation_of_the_dead.enabled and cooldown.apocalypse.remains > 0 then
                        reduceCooldown( "apocalypse", 4 * conduit.convocation_of_the_dead.mod * 0.1 )
                    end
                    gain( 12, "runic_power" )
                else                    
                    gain( 3 * debuff.festering_wound.stack, "runic_power" )
                    apply_festermight( debuff.festering_wound.stack )
                    if conduit.convocation_of_the_dead.enabled and cooldown.apocalypse.remains > 0 then
                        reduceCooldown( "apocalypse", debuff.festering_wound.stack * conduit.convocation_of_the_dead.mod * 0.1 )
                    end
                    removeDebuff( "target", "festering_wound" )
                end

                if level > 57 then gain( 2, "runes" ) end

                if pvptalent.necromancers_bargain.enabled then applyDebuff( "target", "crypt_fever" ) end
            end,

            auras = {
                frenzied_monstrosity = {
                    id = 334895,
                    duration = 15,
                    max_stack = 1,
                },
                frenzied_monstrosity_pet = {
                    id = 334896,
                    duration = 15,
                    max_stack = 1
                }
            }
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
                end
            end,

            copy = { 288853, 42650, "army_of_the_dead", "raise_abomination" }
        },


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
                if debuff.festering_wound.up then
                    if debuff.festering_wound.stack > 1 then
                        applyDebuff( "target", "festering_wound", debuff.festering_wound.remains, debuff.festering_wound.stack - 1 )
                    else removeDebuff( "target", "festering_wound" ) end
                    
                    if conduit.convocation_of_the_dead.enabled and cooldown.apocalypse.remains > 0 then
                        reduceCooldown( "apocalypse", conduit.convocation_of_the_dead.mod * 0.1 )
                    end

                    apply_festermight( 1 )
                end
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
                if talent.unholy_pact.enabled then applyBuff( "unholy_pact" ) end

                if legendary.frenzied_monstrosity.enabled then
                    applyBuff( "frenzied_monstrosity" )
                    applyBuff( "frenzied_monstrosity_pet" )
                end
            end,

            auras = {
                frenzied_monstrosity = {
                    id = 334895,
                    duration = 15,
                    max_stack = 1,
                },
                frenzied_monstrosity_pet = {
                    id = 334896,
                    duration = 15,
                    max_stack = 1
                }
            }
        },


        death_and_decay = {
            id = 43265,
            noOverride = 324128,
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

            spend = function () return buff.sudden_doom.up and 0 or ( legendary.deadliest_coil.enabled and 30 or 40 ) end,
            spendType = "runic_power",

            startsCombat = true,
            texture = 136145,

            handler = function ()
                removeStack( "sudden_doom" )
                if cooldown.dark_transformation.remains > 0 then setCooldown( "dark_transformation", max( 0, cooldown.dark_transformation.remains - 1 ) ) end
                if legendary.deadliest_coil.enabled and buff.dark_transformation.up then buff.dark_transformation.expires = buff.dark_transformation.expires + 2 end
                if legendary.deaths_certainty.enabled then
                    local spell = covenant.night_fae and "deaths_due" or ( talent.defile.enabled and "defile" or "death_and_decay" )
                    if cooldown[ spell ].remains > 0 then reduceCooldown( spell, 2 ) end
                end                
            end,
        },


        death_grip = {
            id = 49576,
            cast = 0,
            cooldown = 25,
            gcd = "spell",

            startsCombat = true,
            texture = 237532,

            handler = function ()
                applyDebuff( "target", "death_grip" )
                setDistance( 5 )
                if conduit.unending_grip.enabled then applyDebuff( "target", "unending_grip" ) end
            end,
        },


        death_pact = {
            id = 48743,
            cast = 0,
            cooldown = 120,
            gcd = "spell",

            toggle = "defensives",

            startsCombat = false,
            texture = 136146,

            talent = "death_pact",

            handler = function ()
                gain( health.max * 0.5, "health" )
                applyDebuff( "player", "death_pact" )
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

                if legendary.deaths_certainty.enabled then
                    local spell = conduit.night_fae and "deaths_due" or ( talent.defile.enabled and "defile" or "death_and_decay" )
                    if cooldown[ spell ].remains > 0 then reduceCooldown( spell, 2 ) end
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
                if conduit.fleeting_wind.enabled then applyBuff( "fleeting_wind" ) end
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
                setCooldown( "death_and_decay", 20 )

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
            min_ttd = function () return min( cooldown.death_and_decay.remains + 3, 8 ) end, -- don't try to cycle onto targets that will die too fast to get consumed.

            handler = function ()
                applyDebuff( "target", "festering_wound", nil, debuff.festering_wound.stack + 2 )
            end,
        },


        icebound_fortitude = {
            id = 48792,
            cast = 0,
            cooldown = function () return 180 - ( azerite.cold_hearted.enabled and 15 or 0 ) + ( conduit.chilled_resilience.mod * 0.001 ) end,
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
            id = 49039,
            cast = 0,
            cooldown = 60,
            gcd = "off",

            toggle = "defensives",

            startsCombat = false,
            texture = 136187,

            handler = function ()
                applyBuff( "lichborne" )
                if conduit.hardened_bones.enabled then applyBuff( "hardened_bones" ) end
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
                if conduit.spirit_drain.enabled then gain( conduit.spirit_drain.mod * 0.1, "runic_power" ) end
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

                    if conduit.convocation_of_the_dead.enabled and cooldown.apocalypse.remains > 0 then
                        reduceCooldown( "apocalypse", conduit.convocation_of_the_dead.mod * 0.1 )
                    end

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

            cycle = "virulent_plague",

            handler = function ()
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

                if conduit.lingering_plague.enabled and debuff.virulent_plague.up then
                    debuff.virulent_plague.expires = debuff.virulent_plague.expires + ( conduit.lingering_plague.mod * 0.001 )
                end
            end,
        },


        soul_reaper = {
            id = 343294,
            cast = 0,
            cooldown = 6,
            gcd = "spell",

            spend = 1,
            spendType = "runes",

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


        unholy_assault = {
            id = 207289,
            cast = 0,
            cooldown = 75,
            gcd = "spell",
            
            toggle = "cooldowns",

            startsCombat = true,
            texture = 136224,

            talent = "unholy_assault",
            
            handler = function ()
                applyDebuff( "target", "festering_wound", nil, min( 6, debuff.festering_wound.stack + 4 ) )
                applyBuff( "unholy_frenzy" )
                stat.haste = stat.haste + 0.1
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


        wraith_walk = {
            id = 212552,
            cast = 4,
            channeled = true,
            cooldown = 60,
            gcd = "spell",

            startsCombat = false,
            texture = 1100041,

            talent = "wraith_walk",

            start = function ()
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


    spec:RegisterPack( "Unholy", 20200926, [[dC0IAbqiHIhjePnPenkLGtju6vuLAweLUfaK2fP(LqQHbqoMqyzaONbqzAefUgayBef13aGQXjerNdaI1bafMNqY9GI9rv4GauHfQe6HefPMiau0fjkcTraO0jbOswjuYlbOICtIIi7KQKHcqLAPefr9uqMkvrxLOiyRaurTxu9xugSGdtzXkPhdzYKCzvBwP(mOgnqoTuRgGQEnuQztLBtKDl53Igov1XfIWYr8CKMUIRdvBxO67evJNOi58aA9crnFGA)eMhb3toKYMZ9cGacGacqaiauM1acabWaeGfbhAa6FoKVHW2GphQmPZHKjuGshqoKVb0LMI7jhIM4e05qGMXNcGr0rd3di8vnkLIM2s4oB6SqeBprtBju0COv82naUk(khszZ5EbqabqabiaeakZAabGayacGYmhI6Fe3lacaaKdbQvQx8voK6uehksfbzcfO0bueaW82aseaCQAyqJaRiveGU)CP1tebakZYkcaeqaeqcSeyfPIGmniRGpfadbwrQiaGkcaouQRebzsDPebaSK)iFTaRiveaqfbz6SIFYCLimgb(dR3IaklvpDwurysrGCyCNrebuwQE6SOAbwrQiaGkcYKnuBoA0ayZAeHClcaUt5NicJ8Byt1Cixthk3to0P0xOt5EY9kcUNCOx2Q7k(ICiePNtAJdrWRRNw6SjzricEicWiLiSuei4vJy(P8teHOebzaioKHMoloK0LscqwUzoCuRykYnjkF4EbqUNCOx2Q7k(ICiePNtAJdPUnGywPyQJmG6Pry3fSiagSi4)rB(jIbdkXDAdnD8lclfbdnD8ZEDP(uraJiebhYqtNfhA1LPILB2a6SxxciF4EbyCp5qVSv3v8f5qispN0ghAbraLPtLYlT5NiZb0NEn5swxurikrqMfHLIaktNkLxAJibKLB2a6m1nLMCjRlQi4HiGY0Ps5LgLL6f9kMR3FNe01KlzDrfHyfbWGfbuMovkV0grcil3Sb0zQBkn5swxurikraGIayWIakjeC)PZIQ767TT6oBi4di9lB1DfhYqtNfhcg3iQ2kwUzwKpjhq8H7Lm4EYHEzRUR4lYHqKEoPno0k(ERjhHT7ukBNe014(IayWIWk(ERjhHT7ukBNe0zOeVMt00XqylcrjcrebhYqtNfhAaDgETM4LITtc68H7faW9Kd9YwDxXxKdHi9CsBCOyeb1TbeZkftDKbupnc7UG5qgA6S4q7eHtVIzr(KEoB9MeF4EjZCp5qVSv3v8f5qispN0ghsLJgLf61qS5k22zsNTItkn5swxuraJiaioKHMoloekl0RHyZvSTZKoF4EbGZ9Kd9YwDxXxKdHi9CsBCOyeb1TbeZkftDKbupnc7UG5qgA6S4q(4KEdSly2QZOdF4Efj5EYHEzRUR4lYHqKEoPno0yUxJ2isaz5MnGotzs1v6x2Q7kryPiCk9f664nTZILBM)j7JMolTuxjrewkcR47TgVaLoGm6qEbpG04(IayWIWP0xORJ30olwUz(NSpA6S0sDLeryPi4)rB(jIbdkXDAdnD8lcGblcJ5EnAJibKLB2a6mLjvxPFzRUReHLIG)hT5NigmOe3Pn00XViSueqz6uP8sBejGSCZgqNPUP0KlzDrfbpebzgqIayWIWyUxJ2isaz5MnGotzs1v6x2Q7kryPi4)rBejGmyqjUtBOPJFoKHMoloK8K4uXFxmYPzzf68H7fac3to0lB1DfFroeI0ZjTXHIreu3gqmRum1rgq90iS7cwewkcR47TgVaLoGm6qEbpG04(IWsrigr4u6l01XBANfl3m)t2hnDwAPUsIiSueIregZ9A0grcil3Sb0zktQUs)YwDxjcGblcJrG)ONw6SjzQ(IquIaktNkLxAZprMdOp9AYLSUOCidnDwCi5jXPI)UyKtZYk05d3Riae3to0lB1DfFroeI0ZjTXHIreu3gqmRum1rgq90iS7cMdzOPZIdrAFF3zDXO(g68H7verW9KdzOPZIdrU53fmB7mPt5qVSv3v8f5dF4qQVnC3W9K7veCp5qgA6S4qsDPyBYFKph6LT6UIViF4EbqUNCOx2Q7k(ICO0Ndr)WHm00zXHIBK2wDNdf3C4NdHY0Ps5LMIljLfd2iWjq31KlzDrfHOebaqewkcJ5EnAkUKuwmyJaNaDx)YwDxXHIBewzsNd5NPRly2ojmyJaNaDNpCVamUNCOx2Q7k(ICiePNtAJdrWRgX8t5NOvF3OEebpebzgaeHLIWcIG)hnSrGtGURn00XViagSieJimM71OP4sszXGncCc0D9lB1DLieRiSuei411QVBupIGhyebaGdzOPZIdzeKvNnjH8A4d3lzW9Kd9YwDxXxKdHi9CsBCi)pAyJaNaDxBOPJFramyrigrym3RrtXLKYIbBe4eO76x2Q7koKHMolo0QltfBJtaYhUxaa3to0lB1DfFroeI0ZjTXHwX3BnEbkDazgLA4UrJ7lcGblc(F0Wgbob6U2qth)IayWIWcIWyUxJ2isaz5MnGotzs1v6x2Q7kryPi4)rB(jIbdkXDAdnD8lcXYHm00zXHwpHEc2DbZhUxYm3to0lB1DfFroeI0ZjTXHwqewX3BnEbkDaz0H8cEaPX9fHLIWk(ER3NoNi1WGgn5swxurikmIaaicXkcGblcgA64N96s9PIGhyebakclfHfeHv89wJxGshqgDiVGhqACFramyryfFV17tNtKAyqJMCjRlQiefgraaeHy5qgA6S4qUgg0qzaECfS0RHpCVaW5EYHEzRUR4lYHqKEoPno0cIG)hnSrGtGURn00XViSuegZ9A0uCjPSyWgbob6U(LT6UseIveadwe8)On)eXGbL4oTHMo(5qgA6S4qwHoDiMJHmNJpCVIKCp5qVSv3v8f5qispN0ghYqth)SxxQpve8aJiaqramyrybrGGxxR(Ur9icEGreaaryPiqWRgX8t5NOvF3OEebpWicYmGeHy5qgA6S4qgbz1z(4o65d3laeUNCOx2Q7k(ICiePNtAJdTGi4)rdBe4eO7AdnD8lclfHXCVgnfxsklgSrGtGURFzRUReHyfbWGfb)pAZprmyqjUtBOPJFoKHMolo0UjF1LPIpCVIaqCp5qVSv3v8f5qispN0ghAfFV14fO0bKrhYl4bKg3xewkcgA64N96s9PIagricramyryfFV17tNtKAyqJMCjRlQieLiaJuIWsrWqth)SxxQpveWicrWHm00zXHwnywUzdPryt5d3RiIG7jh6LT6UIVihcr65K24qtlDrWdraGaseadweIreEKaV99Vstmj)UGzMKVRhC1zWnSfpDd7fCxxeadweIreEKaV99VshVPDwSCZuxQPNdzOPZIdHtpRNlr5d3Riai3to0lB1DfFroKHMoloKfzkiJyu2oRHLBMFk)eoeI0ZjTXHwqeoL(cDD8M2zXYnZ)K9rtNL(LT6UsewkcXicJ5EnA8cu6aYmk1WDJ(LT6UseIveadwewqeIreoL(cDnkl1l6vmxV)ojORLmaFseHLIqmIWP0xORJ30olwUz(NSpA6S0VSv3vIqSCOYKohYImfKrmkBN1WYnZpLFcF4EfbGX9Kd9YwDxXxKdzOPZIdzrMcYigLTZAy5M5NYpHdHi9CsBCiuMovkV0MFImhqF61KlzDrfHOeHiKHiSuewqeoL(cDnkl1l6vmxV)ojORLmaFsebWGfHtPVqxhVPDwSCZ8pzF00zPFzRUReHLIWyUxJgVaLoGmJsnC3OFzRUReHy5qLjDoKfzkiJyu2oRHLBMFk)e(W9kczW9Kd9YwDxXxKdzOPZIdzrMcYigLTZAy5M5NYpHdHi9CsBCOPLoBsMQVieLiGY0Ps5L28tK5a6tVMCjRlQi4TiayYGdvM05qwKPGmIrz7SgwUz(P8t4d3RiaaUNCOx2Q7k(ICidnDwCiJckUvNYiwKtcdLeZXHqKEoPnoK6R47TMyrojmusmht9v89wthdHTieLiebhQmPZHmkO4wDkJyrojmusmhF4EfHmZ9Kd9YwDxXxKdzOPZIdzuqXT6ugXICsyOKyooeI0ZjTXH8)OHXnIQTILBMf5tYbK2qth)IWsrW)J28tedguI70gA64NdvM05qgfuCRoLrSiNegkjMJpCVIaaN7jh6LT6UIVihYqtNfhYOGIB1PmIf5KWqjXCCiePNtAJdHY0Ps5L28tK5a6tVMCtbuewkclicNsFHUgLL6f9kMR3FNe01sgGpjIWsryAPZMKP6lcrjcOmDQuEPrzPErVI5693jbDn5swxurWBraGaseadweIreoL(cDnkl1l6vmxV)ojORLmaFseHy5qLjDoKrbf3QtzelYjHHsI54d3RiIKCp5qVSv3v8f5qgA6S4qgfuCRoLrSiNegkjMJdHi9CsBCOPLoBsMQVieLiGY0Ps5L28tK5a6tVMCjRlQi4TiaqaXHkt6CiJckUvNYiwKtcdLeZXhUxraGW9Kd9YwDxXxKdzOPZIdfVPDwSCZuxQPNdHi9CsBCOfebuMovkV0MFImhqF61KBkGIWsrq9v89wVpDoPlyM8eVuA6yiSfbpWicYqewkcNsFHUoEt7Sy5M5FY(OPZs)YwDxjcXkcGblcR47TgVaLoGmJsnC3OX9fbWGfb)pAyJaNaDxBOPJFouzsNdfVPDwSCZuxQPNpCVaiG4EYHEzRUR4lYHm00zXHiMKFxWmtY31dU6m4g2INUH9cURZHqKEoPnoektNkLxAZprMdOp9AYLSUOIquIaafbWGfHXCVgTrKaYYnBaDMYKQR0VSv3vIayWIaXAf7XFnAtPO6UeHOebaGdvM05qetYVlyMj576bxDgCdBXt3WEb315d3lagb3to0lB1DfFroKHMolo0kq4SoB9NzojRmehcr65K24qOmDQuEPP4sszXGncCc0Dn5swxurWdrqMbKiagSieJimM71OP4sszXGncCc0D9lB1DLiSueMw6IGhIaabKiagSieJi8ibE77FLMys(DbZmjFxp4QZGBylE6g2l4UohQmPZHwbcN1zR)mZjzLH4d3lacqUNCOx2Q7k(ICidnDwCia)PmqPC3jCiePNtAJd5)rdBe4eO7AdnD8lcGblcXicJ5EnAkUKuwmyJaNaDx)YwDxjclfHPLUi4HiaqajcGblcXicpsG3((xPjMKFxWmtY31dU6m4g2INUH9cURZHkt6Cia)PmqPC3j8H7fabmUNCOx2Q7k(ICidnDwCiyZDK5CNqzR3WMdHi9CsBCi)pAyJaNaDxBOPJFramyrigrym3RrtXLKYIbBe4eO76x2Q7kryPimT0fbpebaciramyrigr4rc823)knXK87cMzs(UEWvNb3Ww80nSxWDDouzsNdbBUJmN7ekB9g28H7faLb3to0lB1DfFroKHMoloemjlykZN0sMJrm4ZHqKEoPnoebVUiefgraWeHLIWcIW0sxe8qeaiGebWGfHyeHhjWBF)R0etYVlyMj576bxDgCdBXt3WEb31fHy5qLjDoemjlykZN0sMJrm4ZhUxaea4EYHEzRUR4lYHqKEoPnoektNkLxAJibKLB2a6m1nLMCtbueadwe8)OHncCc0DTHMo(fbWGfHv89wJxGshqMrPgUB04(CidnDwCi)C6S4d3lakZCp5qVSv3v8f5qispN0ghsLJoEtWDVgMVZGXVMCjRlQiefgragP4qgA6S4qj(SsUHnF4EbqaCUNCOx2Q7k(ICidnDwCiK5CmdnDwmxthoKRPdRmPZHoL(cDkF4EbWij3to0lB1DfFroKHMoloeYCoMHMolMRPdhY10HvM05qOmDQuEr5d3lacGW9Kd9YwDxXxKdHi9CsBCidnD8ZEDP(urWdmIaa5q0H0OH7veCidnDwCiK5CmdnDwmxthoKRPdRmPZHS88H7fGbiUNCOx2Q7k(ICiePNtAJdzOPJF2Rl1NkcyeHi4q0H0OH7veCidnDwCiK5CmdnDwmxthoKRPdRmPZHGFDsJ4d3lalcUNCOx2Q7k(ICidnDwCO9PZjDbZOdPX(CiePNtAJdP(k(ER3NoN0fmtEIxknDme2IquIGm4qiGi3zJrG)q5EfbF4dhYNCukTAd3tUxrW9KdzOPZId5NtNfh6LT6UIViF4EbqUNCidnDwCiI10Zu3uCOx2Q7k(I8H7fGX9Kd9YwDxXxKdvM05qwKPGmIrz7SgwUz(P8t4qgA6S4qwKPGmIrz7SgwUz(P8t4d3lzW9Kd9YwDxXxKdPUZaYHaihYqtNfhYisaz5MnGotDtXh(WHqz6uP8IY9K7veCp5qgA6S4qgrcil3Sb0zQBko0lB1DfFr(W9cGCp5qVSv3v8f5qispN0ghs9v89wVpDoPlyM8eVuA6yiSfbpWicYqewkclicgA64N96s9PIGhyebakcGblcXicNsFHUoEt7Sy5M5FY(OPZs)YwDxjcGblcXicwKpPNRLmyCkl3Sb0zQBk9lB1DLiagSiCk9f664nTZILBM)j7JMol9lB1DLiSuewqegZ9A04fO0bKzuQH7g9lB1DLiSueqz6uP8sJxGshqMrPgUB0KlzDrfHOWicaMiagSieJimM71OXlqPdiZOud3n6x2Q7kriwriwoKHMoloK5NiZb0NE(W9cW4EYHEzRUR4lYHqKEoPnoumIaXAf7XFnAtPO6lt10HkcGblceRvSh)1OnLIQ7se8qeIaa4qgA6S4qkJGnBiwr3jrYMol(W9sgCp5qVSv3v8f5qispN0ghIGxnI5NYprR(Ur9icrjcridoKHMoloefxsklgSrGtGUZhUxaa3to0lB1DfFroeI0ZjTXHoL(cDD8M2zXYnZ)K9rtNL(LT6Usewkc(F0MFIyWGsCN2qth)IayWIG6R47TEF6CsxWm5jEP00XqylcrjcYqewkcXicNsFHUoEt7Sy5M5FY(OPZs)YwDxjclfHfeHyeblYN0Z1sgmoLLB2a6m1nL(LT6UseadweSiFspxlzW4uwUzdOZu3u6x2Q7kryPi4)rB(jIbdkXDAdnD8lcXYHm00zXHWlqPdiZOud3n8H7LmZ9Kd9YwDxXxKdHi9CsBCidnD8ZEDP(urWdmIaafHLIWcIWcIaktNkLxA1TbeZkftDKbutUK1fveIcJiaJuIWsrigrym3RrR(UDx)YwDxjcXkcGblclicOmDQuEPvF3URjxY6IkcrHreGrkryPimM71OvF3URFzRUReHyfHy5qgA6S4q4fO0bKzuQH7g(W9caN7jh6LT6UIVihcr65K24qJrG)ONw6SjzQ(IGhIqeYGdzOPZIdrbziSDNnGodVKNKbeq(W9ksY9Kd9YwDxXxKdHi9CsBCidnD8ZEDP(urWdraGCidnDwCiBnL6YMolMRLw5d3laeUNCOx2Q7k(ICiePNtAJdzOPJF2Rl1NkcEicaKdzOPZIdrLBePUGzsnD4d3Riae3to0lB1DfFroeI0ZjTXHgJa)rpT0ztYu9fHOeHiPiSuegJa)rpT0ztYu9fbpebzWHm00zXHOjUJrU5FcF4EfreCp5qVSv3v8f5qispN0ghAbrigrGyTI94VgTPuu9LPA6qfbWGfbI1k2J)A0Msr1DjcEicaeqIqSIWsrGGxxeIcJiSGieHiaGkcR47TgVaLoGmJsnC3OX9fHy5qgA6S4q0e3Xi38pHpCVIaGCp5qgA6S4q4fO0bKT6Ayqdh6LT6UIViF4dhYYZ9K7veCp5qVSv3v8f5qispN0ghcLPtLYlT5NiZb0NEn5swxuryPiyOPJFMkh9(05KUGzYt8sjcEicaIdzOPZIdPUnGywPyQJmG8H7fa5EYHEzRUR4lYHqKEoPnoektNkLxAZprMdOp9AYLSUOIWsrWqth)mvo69PZjDbZKN4Lse8qeaehYqtNfhs9D7oF4EbyCp5qVSv3v8f5qispN0ghcLPtLYlT5NiZb0NEn5swxuryPiyOPJFMkh9(05KUGzYt8sjcEicaIdzOPZIdPUnGOmf(5d3lzW9Kd9YwDxXxKdHi9CsBCi1TbeZkftDKbupnc7UGfHLIabVAeZpLFIw9DJ6reIseIqgIWsrigrym3RrVItOtxWmAsov)YwDxjclfHyeH4gPTv31(z66cMTtcd2iWjq35qgA6S4q3VvxQr8H7faW9Kd9YwDxXxKdHi9CsBCi1TbeZkftDKbupnc7UGfHLIWcIqmIG62aIHD1WGg9wEIxQRyJrG)qfHLIWyUxJEfNqNUGz0KCQ(LT6UseIvewkcXicXnsBRUR9Z01fmBNegSrGtGUZHm00zXHUFRUuJ4d3lzM7jh6LT6UIVihcr65K24qQBdiMvkM6idOEAe2DblclfbuMovkV0MFImhqF61KlzDr5qgA6S4quuItGpJoKg7ZhUxa4Cp5qVSv3v8f5qispN0ghsDBaXSsXuhza1tJWUlyryPiGY0Ps5L28tK5a6tVMCjRlkhYqtNfhc5m5DbZOGmvkNYhUxrsUNCOx2Q7k(ICiePNtAJdfJie3iTT6U2ptxxWSDsyWgbob6ohYqtNfh6(T6snIpCVaq4EYHEzRUR4lYHqKEoPno0cIWcIWcIWcIG6R47TEF6CsxWm5jEP00XqylcrjcYqewkcXicR47TgVaLoGmJsnC3OX9fHyfbWGfb1xX3B9(05KUGzYt8sPPJHWweIseamriwryPiGY0Ps5L28tK5a6tVMCjRlQieLiayIqSIayWIG6R47TEF6CsxWm5jEP00XqylcrjcricXkclfHfebuMovkV0grcil3Sb0zQBkn5swxurWdraaeHy5qgA6S4q7tNt6cMrhsJ95d3Riae3to0lB1DfFroeI0ZjTXHwX3BnfxPEXuzkPj3qJiSuei411tlD2KmzicEicWifhYqtNfhsDBaXqz74d3RiIG7jh6LT6UIVihcr65K24qR47TMIRuVyQmL0KBOrewkcXicXnsBRUR9Z01fmBNegSrGtGUlcGblc(F0Wgbob6U2qth)CidnDwCi1TbedLTJpCVIaGCp5qVSv3v8f5qispN0ghIGxnI5NYprR(Ur9icrjcridryPiSGiGY0Ps5L28tK5a6tVMCjRlQi4HiaaIayWIG6R47TEF6CsxWm5jEP00XqylcEicYqeIvewkcXicXnsBRUR9Z01fmBNegSrGtGUZHm00zXHu3gqmu2o(W9kcaJ7jh6LT6UIVihYqtNfhIIsCc8z0H0yFoeI0ZjTXHwqewqeqz6uP8sBejGSCZgqNPUP0KlzDrfbpebaqeadweu3gqmSRgg0Ovn1wDNz5OeHyfHLIWcIaktNkLxAZprMdOp9AYLSUOIGhIaaiclfb1xX3B9(05KUGzYt8sPPJHWwe8qeaKiagSiO(k(ER3NoN0fmtEIxknDme2IGhIGmeHyfHLIWcIW0sNnjt1xeIseqz6uP8sRUnGywPyQJmGAYLSUOIG3IqeaseadweMw6SjzQ(IGhIaktNkLxAZprMdOp9AYLSUOIqSIqSCieqK7SXiWFOCVIGpCVIqgCp5qVSv3v8f5qgA6S4qiNjVlygfKPs5uoeI0ZjTXHwqewqeqz6uP8sBejGSCZgqNPUP0KlzDrfbpebaqeadweu3gqmSRgg0Ovn1wDNz5OeHyfHLIWcIaktNkLxAZprMdOp9AYLSUOIGhIaaiclfb1xX3B9(05KUGzYt8sPPJHWwe8qeaKiagSiO(k(ER3NoN0fmtEIxknDme2IGhIGmeHyfHLIWcIW0sNnjt1xeIseqz6uP8sRUnGywPyQJmGAYLSUOIG3IqeaseadweMw6SjzQ(IGhIaktNkLxAZprMdOp9AYLSUOIqSIqSCieqK7SXiWFOCVIGpCVIaa4EYHEzRUR4lYHqKEoPnoebVAeZpLFIw9DJ6reIseaiGeHLIqmIqCJ02Q7A)mDDbZ2jHbBe4eO7CidnDwCi1TbedLTJpCVIqM5EYHEzRUR4lYHqKEoPno0cIWcIWcIWcIG6R47TEF6CsxWm5jEP00XqylcrjcYqewkcXicR47TgVaLoGmJsnC3OX9fHyfbWGfb1xX3B9(05KUGzYt8sPPJHWweIseamriwryPiGY0Ps5L28tK5a6tVMCjRlQieLiayIqSIayWIG6R47TEF6CsxWm5jEP00XqylcrjcricXkclfHfebuMovkV0grcil3Sb0zQBkn5swxurWdraaebWGfb1Tbed7QHbnAvtTv3zwokriwoKHMolo0(05KUGz0H0yF(W9kcaCUNCOx2Q7k(ICiePNtAJdPUnGywPyQJmG6Pry3fmhYqtNfhIIsCc8z0H0yF(W9kIij3to0lB1DfFroeI0ZjTXHIreIBK2wDx7NPRly2ojmyJaNaDNdzOPZIdPUnGyOSD8HpCi4xN0iUNCVIG7jh6LT6UIVihcr65K24qR47TMIRuVyQmL0KBOrewkce866PLoBsMmebpebyKsewkcXicXnsBRUR9Z01fmBNegSrGtGUlcGblc(F0Wgbob6U2qth)CidnDwCi1TbedLTJpCVai3to0lB1DfFroeI0ZjTXHi4vJy(P8t0QVBupIquIqeYqewkce866PLoBsMmebpebyKsewkcXicXnsBRUR9Z01fmBNegSrGtGUZHm00zXHu3gqmu2o(W9cW4EYHEzRUR4lYHqKEoPnoK6R47TEF6CsxWm5jEP04(CidnDwCikkXjWNrhsJ95d3lzW9Kd9YwDxXxKdHi9CsBCi1xX3B9(05KUGzYt8sPX9fHLIWcIaktNkLxAZprMdOp9AYLSUOIGhIaaicGblcQVIV369PZjDbZKN4LsthdHTi4HiidriwoKHMoloeYzY7cMrbzQuoLpCVaaUNCOx2Q7k(ICiePNtAJdrWRgX8t5NOvF3OEeHOebaciryPieJie3iTT6U2ptxxWSDsyWgbob6ohYqtNfhsDBaXqz74d3lzM7jh6LT6UIVihcr65K24qQVIV369PZjDbZKN4LsthdHTieLiidryPiGY0Ps5L28tK5a6tVMCjRlQieLiayIayWIG6R47TEF6CsxWm5jEP00XqylcrjcrWHm00zXH2NoN0fmJoKg7ZhUxa4Cp5qVSv3v8f5qispN0ghkgriUrAB1DTFMUUGz7KWGncCc0DoKHMoloK62aIHY2Xh(Whou8tODwCVaiGaiGauKeGrsoKCJuDbt5qaUK8tYCLiiZIGHMolrW10HQfyXH8j5UDNdfPIGmHcu6akcayEBajcaovnmOrGvKkcq3FU06jIaaLzzfbaciacibwcSIurqMgKvWNcGHaRiveaqfbahk1vIGmPUuIaawYFKVwGvKkcaOIGmDwXpzUsegJa)H1BraLLQNolQimPiqomUZiIaklvpDwuTaRiveaqfbzYgQnhnAaSznIqUfba3P8teHr(nSPAbwcSIurqMOm1r4ZvIW63j5IakLwTrewpCxuTia4aHU)qfHklauqgrAJ7ebdnDwurilhqTaRivem00zr1(KJsPvBWSDgfBbwrQiyOPZIQ9jhLsR24nMO3zQeyfPIGHMolQ2NCukTAJ3yI2WHLEn20zjWksfbOY8PGYreiwReHv89(krGo2qfH1VtYfbukTAJiSE4UOIGvkrWNCau)CMUGfHMkcQSUwGvKkcgA6SOAFYrP0QnEJjAAz(uq5WOJnubwgA6SOAFYrP0QnEJjA)C6SeyzOPZIQ9jhLsR24nMOjwtptDtjWYqtNfv7tokLwTXBmrJtpRNljBzshJfzkiJyu2oRHLBMFk)ebwgA6SOAFYrP0QnEJjAJibKLB2a6m1nLSQ7mGyaOalbwrQiituM6i85kr4XpbOimT0fHb0fbdnjreAQiyXT2zRURfyzOPZIIrQlfBt(J8fyzOPZI6nMOJBK2wDx2YKog)mDDbZ2jHbBe4eO7Yg3C4hdktNkLxAkUKuwmyJaNaDxtUK1fnkay5yUxJMIljLfd2iWjq31VSv3vcSIurqMSHAZrLveaCnxIkRiyLseYb0jIqcJuubwgA6SOEJjAJGS6SjjKxJS9gdbVAeZpLFIw9DJ6XdzgawUG)hnSrGtGURn00XpyWXmM71OP4sszXGncCc0D9lB1DvSlj411QVBupEGbaeyzOPZI6nMOxDzQyBCcqz7ng)pAyJaNaDxBOPJFWGJzm3RrtXLKYIbBe4eO76x2Q7kbwgA6SOEJj61tONGDxWY2BmR47TgVaLoGmJsnC3OX9bd2)Jg2iWjq31gA64hm4fgZ9A0grcil3Sb0zktQUs)YwDxT0)J28tedguI70gA64pwbwgA6SOEJjAxddAOmapUcw61iBVXSWk(ERXlqPdiJoKxWdinU)Yv89wVpDorQHbnAYLSUOrHbaIfmydnD8ZEDP(upWaWLlSIV3A8cu6aYOd5f8asJ7dg8k(ER3NoNi1WGgn5swx0OWaaXkWYqtNf1BmrBf60HyogYCoz7nMf8)OHncCc0DTHMo(xoM71OP4sszXGncCc0D9lB1DvSGb7)rB(jIbdkXDAdnD8lWYqtNf1BmrBeKvN5J7Ox2EJXqth)SxxQp1dmaem4fi411QVBupEGbawsWRgX8t5NOvF3OE8aJmdOyfyzOPZI6nMO3n5RUmvY2Bml4)rdBe4eO7AdnD8VCm3RrtXLKYIbBe4eO76x2Q7Qybd2)J28tedguI70gA64xGLHMolQ3yIE1Gz5MnKgHnv2EJzfFV14fO0bKrhYl4bKg3FPHMo(zVUuFkMiadEfFV17tNtKAyqJMCjRlAuWi1sdnD8ZEDP(umriWsGvKkcY040jLeHH0f2FOIao1GValdnDwuVXeno9SEUev2EJzAP7babeyWX8ibE77FLMys(DbZmjFxp4QZGBylE6g2l4UoyWX8ibE77FLoEt7Sy5MPUutValdnDwuVXeno9SEUKSLjDmwKPGmIrz7SgwUz(P8tKT3yw4u6l01XBANfl3m)t2hnDw6x2Q7QLXmM71OXlqPdiZOud3n6x2Q7QybdEHyoL(cDnkl1l6vmxV)ojORLmaFswgZP0xORJ30olwUz(NSpA6S0VSv3vXkWYqtNf1BmrJtpRNljBzshJfzkiJyu2oRHLBMFk)ez7nguMovkV0MFImhqF61KlzDrJkczSCHtPVqxJYs9IEfZ17Vtc6AjdWNeWGpL(cDD8M2zXYnZ)K9rtNL(LT6UA5yUxJgVaLoGmJsnC3OFzRURIvGLHMolQ3yIgNEwpxs2YKoglYuqgXOSDwdl3m)u(jY2BmtlD2Kmv)Oqz6uP8sB(jYCa9PxtUK1f1BatgcSm00zr9gt040Z65sYwM0XyuqXT6ugXICsyOKyoz7ng1xX3BnXICsyOKyoM6R47TMogc7OIqGLHMolQ3yIgNEwpxs2YKogJckUvNYiwKtcdLeZjBVX4)rdJBevBfl3mlYNKdiTHMo(x6)rB(jIbdkXDAdnD8lWYqtNf1BmrJtpRNljBzshJrbf3QtzelYjHHsI5KT3yqz6uP8sB(jYCa9PxtUPaUCHtPVqxJYs9IEfZ17Vtc6AjdWNKLtlD2Kmv)Oqz6uP8sJYs9IEfZ17Vtc6AYLSUOEdqabgCmNsFHUgLL6f9kMR3FNe01sgGpjXkWYqtNf1BmrJtpRNljBzshJrbf3QtzelYjHHsI5KT3yMw6SjzQ(rHY0Ps5L28tK5a6tVMCjRlQ3aeqcSm00zr9gt040Z65sYwM0XeVPDwSCZuxQPx2EJzbuMovkV0MFImhqF61KBkGlvFfFV17tNt6cMjpXlLMogcBpWiJLNsFHUoEt7Sy5M5FY(OPZs)YwDxflyWR47TgVaLoGmJsnC3OX9bd2)Jg2iWjq31gA64xGLHMolQ3yIgNEwpxs2YKogIj53fmZK8D9GRodUHT4PByVG76Y2BmOmDQuEPn)ezoG(0RjxY6IgfabdEm3RrBejGSCZgqNPmP6k9lB1DfyWeRvSh)1OnLIQ7kkaqGLHMolQ3yIgNEwpxs2YKoMvGWzD26pZCswziz7nguMovkV0uCjPSyWgbob6UMCjRlQhYmGadoMXCVgnfxsklgSrGtGURFzRURwoT09aGacm4yEKaV99Vstmj)UGzMKVRhC1zWnSfpDd7fCxxGLHMolQ3yIgNEwpxs2YKoga)PmqPC3jY2Bm(F0Wgbob6U2qth)GbhZyUxJMIljLfd2iWjq31VSv3vlNw6EaqabgCmpsG3((xPjMKFxWmtY31dU6m4g2INUH9cURlWYqtNf1BmrJtpRNljBzshdS5oYCUtOS1BylBVX4)rdBe4eO7AdnD8dgCmJ5EnAkUKuwmyJaNaDx)YwDxTCAP7babeyWX8ibE77FLMys(DbZmjFxp4QZGBylE6g2l4UUaldnDwuVXeno9SEUKSLjDmWKSGPmFslzogXGVS9gdbVEuyaSLlmT09aGacm4yEKaV99Vstmj)UGzMKVRhC1zWnSfpDd7fCxpwbwgA6SOEJjA)C6SKT3yqz6uP8sBejGSCZgqNPUP0KBkGGb7)rdBe4eO7AdnD8dg8k(ERXlqPdiZOud3nACFbwrQiitY6ASU6cweaCUj4UxJia42zW4xeAQiyIGpPtspafyzOPZI6nMOt8zLCdBz7ngvo64nb39Ay(odg)AYLSUOrHbgPeyzOPZI6nMOrMZXm00zXCnDKTmPJ5u6l0PcSm00zr9gt0iZ5ygA6SyUMoYwM0XGY0Ps5fvGLHMolQ3yIgzohZqtNfZ10rw6qA0Gjczlt6yS8Y2BmgA64N96s9PEGbGcSm00zr9gt0iZ5ygA6SyUMoYshsJgmriBzshd8RtAKS9gJHMo(zVUuFkMieyzOPZI6nMO3NoN0fmJoKg7llciYD2ye4pumriBVXO(k(ER3NoN0fmtEIxknDme2rjdbwcSIuraWrktuei5ytNLaldnDwuTLhJ62aIzLIPoYakBVXGY0Ps5L28tK5a6tVMCjRl6sdnD8Zu5O3NoN0fmtEIxkpaKaldnDwuTL3BmrR(UDx2EJbLPtLYlT5NiZb0NEn5swx0LgA64NPYrVpDoPlyM8eVuEaibwgA6SOAlV3yIwDBarzk8lBVXGY0Ps5L28tK5a6tVMCjRl6sdnD8Zu5O3NoN0fmtEIxkpaKaldnDwuTL3BmrF)wDPgjBVXOUnGywPyQJmG6Pry3f8scE1iMFk)eT67g1turiJLXmM71OxXj0PlygnjNQFzRURwgtCJ02Q7A)mDDbZ2jHbBe4eO7cSm00zr1wEVXe99B1LAKS9gJ62aIzLIPoYaQNgHDxWlxig1Tbed7QHbn6T8eVuxXgJa)HUCm3RrVItOtxWmAsov)YwDxf7YyIBK2wDx7NPRly2ojmyJaNaDxGLHMolQ2Y7nMOPOeNaFgDin2x2EJrDBaXSsXuhza1tJWUl4LOmDQuEPn)ezoG(0RjxY6IkWYqtNfvB59gt0iNjVlygfKPs5uz7ng1TbeZkftDKbupnc7UGxIY0Ps5L28tK5a6tVMCjRlQaldnDwuTL3BmrF)wDPgjBVXetCJ02Q7A)mDDbZ2jHbBe4eO7cSm00zr1wEVXe9(05KUGz0H0yFz7nMfwyHfuFfFV17tNt6cMjpXlLMogc7OKXYywX3BnEbkDazgLA4UrJ7hlyWQVIV369PZjDbZKN4LsthdHDuawSlrz6uP8sB(jYCa9PxtUK1fnkalwWGvFfFV17tNt6cMjpXlLMogc7OIi2LlGY0Ps5L2isaz5MnGotDtPjxY6I6baeRaldnDwuTL3BmrRUnGyOSDY2BmR47TMIRuVyQmL0KBOzjbVUEAPZMKjdpGrkbwgA6SOAlV3yIwDBaXqz7KT3ywX3BnfxPEXuzkPj3qZYyIBK2wDx7NPRly2ojmyJaNaDhmy)pAyJaNaDxBOPJFbwgA6SOAlV3yIwDBaXqz7KT3yi4vJy(P8t0QVBuprfHmwUaktNkLxAZprMdOp9AYLSUOEaaGbR(k(ER3NoN0fmtEIxknDme2EiJyxgtCJ02Q7A)mDDbZ2jHbBe4eO7cSm00zr1wEVXenfL4e4ZOdPX(YIaICNngb(dfteY2BmlSaktNkLxAJibKLB2a6m1nLMCjRlQhaayWQBdig2vddA0QMARUZSCuXUCbuMovkV0MFImhqF61KlzDr9aawQ(k(ER3NoN0fmtEIxknDme2EaiWGvFfFV17tNt6cMjpXlLMogcBpKrSlxyAPZMKP6hfktNkLxA1TbeZkftDKbutUK1f17iaeyWtlD2KmvFpqz6uP8sB(jYCa9PxtUK1fn2yfyzOPZIQT8EJjAKZK3fmJcYuPCQSiGi3zJrG)qXeHS9gZclGY0Ps5L2isaz5MnGotDtPjxY6I6baagS62aIHD1WGgTQP2Q7mlhvSlxaLPtLYlT5NiZb0NEn5swxupaGLQVIV369PZjDbZKN4LsthdHThacmy1xX3B9(05KUGzYt8sPPJHW2dze7YfMw6SjzQ(rHY0Ps5LwDBaXSsXuhza1KlzDr9ocabg80sNnjt13duMovkV0MFImhqF61KlzDrJnwbwgA6SOAlV3yIwDBaXqz7KT3yi4vJy(P8t0QVBuprbqaTmM4gPTv31(z66cMTtcd2iWjq3fyzOPZIQT8EJj69PZjDbZOdPX(Y2BmlSWclO(k(ER3NoN0fmtEIxknDme2rjJLXSIV3A8cu6aYmk1WDJg3pwWGvFfFV17tNt6cMjpXlLMogc7OaSyxIY0Ps5L28tK5a6tVMCjRlAuawSGbR(k(ER3NoN0fmtEIxknDme2rfrSlxaLPtLYlTrKaYYnBaDM6MstUK1f1daamy1Tbed7QHbnAvtTv3zwoQyfyzOPZIQT8EJjAkkXjWNrhsJ9LT3yu3gqmRum1rgq90iS7cwGLHMolQ2Y7nMOv3gqmu2oz7nMyIBK2wDx7NPRly2ojmyJaNaDxGLaldnDwunktNkLxumgrcil3Sb0zQBkbwgA6SOAuMovkVOEJjAZprMdOp9Y2BmQVIV369PZjDbZKN4LsthdHThyKXYfm00Xp71L6t9adabdoMtPVqxhVPDwSCZ8pzF00zPFzRURadoglYN0Z1sgmoLLB2a6m1nL(LT6Ucm4tPVqxhVPDwSCZ8pzF00zPFzRURwUWyUxJgVaLoGmJsnC3OFzRURwIY0Ps5LgVaLoGmJsnC3OjxY6Igfgadm4ygZ9A04fO0bKzuQH7g9lB1DvSXkWYqtNfvJY0Ps5f1BmrRmc2SHyfDNejB6SKT3yIHyTI94VgTPuu9LPA6qbdMyTI94VgTPuuDxEebaiWYqtNfvJY0Ps5f1BmrtXLKYIbBe4eO7Y2Bme8Qrm)u(jA13nQNOIqgcSm00zr1OmDQuEr9gt04fO0bKzuQH7gz7nMtPVqxhVPDwSCZ8pzF00zPFzRURw6)rB(jIbdkXDAdnD8dgS6R47TEF6CsxWm5jEP00XqyhLmwgZP0xORJ30olwUz(NSpA6S0VSv3vlxiglYN0Z1sgmoLLB2a6m1nL(LT6UcmylYN0Z1sgmoLLB2a6m1nL(LT6UAP)hT5NigmOe3Pn00XFScSm00zr1OmDQuEr9gt04fO0bKzuQH7gz7ngdnD8ZEDP(upWaWLlSaktNkLxA1TbeZkftDKbutUK1fnkmWi1YygZ9A0QVB31VSv3vXcg8cOmDQuEPvF3URjxY6IgfgyKA5yUxJw9D7U(LT6Uk2yfyzOPZIQrz6uP8I6nMOPGme2UZgqNHxYtYacOS9gZye4p6PLoBsMQVhridbwgA6SOAuMovkVOEJjABnL6YMolMRLwLT3ym00Xp71L6t9aGcSm00zr1OmDQuEr9gt0u5grQlyMuthz7ngdnD8ZEDP(upaOaldnDwunktNkLxuVXennXDmYn)tKDmc8hwVXmgb(JEAPZMKP6hvKC5ye4p6PLoBsMQVhYqGLHMolQgLPtLYlQ3yIMM4og5M)jY2BmledXAf7XFnAtPO6lt10HcgmXAf7XFnAtPO6U8aGak2Le86rHzHiaqxX3BnEbkDazgLA4UrJ7hRaldnDwunktNkLxuVXenEbkDazRUgg0iWsGLHMolQ(u6l0PyKUusaYYnZHJAftrUjrLT3yi411tlD2KSi8agPwsWRgX8t5NeLmaKaldnDwu9P0xOt9gt0RUmvSCZgqN96saLT3yu3gqmRum1rgq90iS7cgmy)pAZprmyqjUtBOPJ)LgA64N96s9PyIqGLHMolQ(u6l0PEJjAyCJOARy5Mzr(KCajBVXSaktNkLxAZprMdOp9AYLSUOrjZlrz6uP8sBejGSCZgqNPUP0KlzDr9aLPtLYlnkl1l6vmxV)ojORjxY6IglyWOmDQuEPnIeqwUzdOZu3uAYLSUOrbqWGrjHG7pDwuDxFVTv3zdbFaPFzRUReyzOPZIQpL(cDQ3yIEaDgETM4LITtc6Y2BmR47TMCe2UtPSDsqxJ7dg8k(ERjhHT7ukBNe0zOeVMt00XqyhveriWYqtNfvFk9f6uVXe9or40RywKpPNZwVjjBVXeJ62aIzLIPoYaQNgHDxWcSm00zr1NsFHo1BmrJYc9Ai2CfB7mPlBVXOYrJYc9Ai2CfB7mPZwXjLMCjRlkgajWYqtNfvFk9f6uVXeTpoP3a7cMT6m6iBVXeJ62aIzLIPoYaQNgHDxWcSm00zr1NsFHo1Bmrlpjov83fJCAwwHUS9gZyUxJ2isaz5MnGotzs1v6x2Q7QLNsFHUoEt7Sy5M5FY(OPZsl1vswUIV3A8cu6aYOd5f8asJ7dg8P0xORJ30olwUz(NSpA6S0sDLKL(F0MFIyWGsCN2qth)GbpM71OnIeqwUzdOZuMuDL(LT6UAP)hT5NigmOe3Pn00X)suMovkV0grcil3Sb0zQBkn5swxupKzabg8yUxJ2isaz5MnGotzs1v6x2Q7QL(F0grcidguI70gA64xGLHMolQ(u6l0PEJjA5jXPI)UyKtZYk0LT3yIrDBaXSsXuhza1tJWUl4LR47TgVaLoGm6qEbpG04(lJ5u6l01XBANfl3m)t2hnDwAPUsYYygZ9A0grcil3Sb0zktQUs)YwDxbg8ye4p6PLoBsMQFuOmDQuEPn)ezoG(0RjxY6IkWYqtNfvFk9f6uVXenP99DN1fJ6BOlBVXeJ62aIzLIPoYaQNgHDxWcSm00zr1NsFHo1BmrtU53fmB7mPtfyjWYqtNfvd)6KgHrDBaXqz7KT3ywX3BnfxPEXuzkPj3qZscED90sNnjtgEaJulJjUrAB1DTFMUUGz7KWGncCc0DWG9)OHncCc0DTHMo(fyzOPZIQHFDsJ8gt0QBdigkBNS9gdbVAeZpLFIw9DJ6jQiKXscED90sNnjtgEaJulJjUrAB1DTFMUUGz7KWGncCc0DbwgA6SOA4xN0iVXenfL4e4ZOdPX(Y2BmQVIV369PZjDbZKN4LsJ7lWYqtNfvd)6Kg5nMOrotExWmkitLYPY2BmQVIV369PZjDbZKN4LsJ7VCbuMovkV0MFImhqF61KlzDr9aaadw9v89wVpDoPlyM8eVuA6yiS9qgXkWYqtNfvd)6Kg5nMOv3gqmu2oz7ngcE1iMFk)eT67g1tuaeqlJjUrAB1DTFMUUGz7KWGncCc0DbwgA6SOA4xN0iVXe9(05KUGz0H0yFz7ng1xX3B9(05KUGzYt8sPPJHWokzSeLPtLYlT5NiZb0NEn5swx0OamWGvFfFV17tNt6cMjpXlLMogc7OIqGLHMolQg(1jnYBmrRUnGyOSDY2BmXe3iTT6U2ptxxWSDsyWgbob6ohYWhqjHdb1s4oB6SKPj2E4dF4Ca]] )

end
