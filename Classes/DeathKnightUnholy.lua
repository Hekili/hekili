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


    local mt_runeforges = {
        __index = function( t, k )
            return false
        end,
    }

    -- Not actively supporting this since we just respond to the player precasting AOTD as they see fit.
    spec:RegisterStateTable( "death_knight", setmetatable( {
        disable_aotd = false,
        delay = 6,
        runeforge = setmetatable( {}, mt_runeforges )
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


    spec:RegisterPack( "Unholy", 20201013, [[dGumAbqiQkEeakBsjmkHItrvvVsO0SikUfaQSlk9lLiddGCmQcldaEgaLPruY1OQITbG4Bai14aOY5ikLADeLIAEuLCpeSpQIoirPilujQhsuQYebqsUiasQncGQCsIsjTseYljkvv3KOuODsvQFcGQYqjkfSuIsv5PGAQuv6QeLsSvauvTxu9xugSGdtAXkPhd1KP4YQ2Ss9zqgnGoTuRgGQEnc1SPYTjYUL8BrdxihNOuz5qEostxX1r02fQ(or14bqIZdK1tvLMpqTFcZ9G7lh2OZ5Edaabaa5bG8aWSacW5h)aaaAo8ak6C4iftScDoCPsNdlBPaMoqC4ifKlvd3xomnjr4ZHbotev28slb1dqYvloLwI2sKoD6SWiDplrBj8sC4vY2nYwl(kh2OZ5Edaabaa5bG8aWSacW5h)aaaWHPrhZ9ga(baCyGTX8IVYHnNI5Wamrq2sbmDGebaQUoafbz)vdbCeebWeba(WtUEKi4bGjJiaaabaajisqeateK9aQf0PYMfebWebaorq2KXCJiiBSlJiaWd973BfebWebaorq2lR4hn3icJIG(W6TiGZY0tNfveMueqhI0PiraNLPNolQvqeatea4ebzFkUvhDjaEznIqUfbzdP8JeHr(vIPwoSRPdL7lh(u6l8PCF5E7b3xo8lD1DdFzomg1ZrTYHrK1TtlD2KmpebpfbiSrewiciYQXSOu(rIGxIGSaehwXtNfhw6sjcel3mhjUnmd6QeLpCVba3xo8lD1DdFzomg1ZrTYHnxhGmTmmZXki70yI7cseadweI(y1OeZGaMKoRINo(fHfIGINo(zVUuFQiqqe8GdR4PZIdV6Y0WYnBaE2RlbIpCVbmUVC4x6Q7g(YCymQNJALdhJiGZ0zs5LvJsS6afrVfDjTlQi4LiaqeHfIaotNjLxwfjbILB2a8mZvJfDjTlQi4PiGZ0zs5LfNL5f9gMR3FNi8TOlPDrfb)fbWGfbCMotkVSkscel3Sb4zMRgl6sAxurWlraaCyfpDwCyisfzATy5MP(9OCaYhU3YI7lh(LU6UHVmhgJ65Ow5WRK7TfDmXUtPSDIW3sgjcGblcRK7TfDmXUtPSDIWNHtYAoYshftSi4Li4HhCyfpDwC4b4zK1Aswg2or4ZhU3(H7lh(LU6UHVmhgJ65Ow5W(icMRdqMwgM5yfKDAmXDbXHv80zXH3jMKEdt97r9C26vj(W9gGW9Ld)sxD3WxMdJr9CuRCytowCw4xdsNByBNkD2kjQSOlPDrfbcIaG4WkE6S4W4SWVgKo3W2ov68H7nan3xo8lD1DdFzomg1ZrTYH9remxhGmTmmZXki70yI7cIdR4PZIdhrI6nOUGyRoLo8H7nGJ7lh(LU6UHVmhgJ65Ow5WJ6EnwfjbILB2a8mJkv3yFPRUBeHfIWP0x4BJ30olwUzrhTpE6SSsDLiryHiSsU3wYcy6aXOd6f0a0sgjcGblcNsFHVnEt7Sy5MfD0(4PZYk1vIeHfIq0hRgLygeWK0zv80XViagSimQ71yvKeiwUzdWZmQuDJ9LU6UrewicrFSAuIzqatsNvXth)IWcraNPZKYlRIKaXYnBaEM5QXIUK2fve8ueaiaseadweg19ASkscel3Sb4zgvQUX(sxD3icleHOpwfjbIbbmjDwfpD8ZHv80zXHLNiNj(7IHonlTWNpCVLT5(YHFPRUB4lZHXOEoQvoSpIG56aKPLHzowbzNgtCxqIWcryLCVTKfW0bIrh0lObOLmsewic(icNsFHVnEt7Sy5MfD0(4PZYk1vIeHfIGpIWOUxJvrsGy5MnapZOs1n2x6Q7gramyryue0h70sNnjZ0xe8seWz6mP8YQrjwDGIO3IUK2fLdR4PZIdlprot83fdDAwAHpF4E7bG4(YHFPRUB4lZHXOEoQvoSpIG56aKPLHzowbzNgtCxqCyfpDwCyuhf5oRlgnsXNpCV9WdUVC4x6Q7g(YCymQNJALd7JiSsU32O25uel3SnkPJLmsewic(icRK7TDfDDaYYnJ2LbPqjvTKrIWcrigryue0hlWRUbilcpIGNeebahGebWGfHrrqFSaV6gGSi8icErqeaaGebWGfHDdbCyOlPDrfbVebz5hrWFoSINolom6AuxqSTtLoLp8HdB(wjDd3xU3EW9LdR4PZIdl1LHTr)(9C4x6Q7g(Y8H7na4(YHFPRUB4lZHZiom9dhwXtNfhoUIAD1DoCC1rEomotNjLxwkPKuwmifbLGC3IUK2fve8se8JiSqeg19ASusjPSyqkckb5U9LU6UHdhxrSsLohoktxxqSDIyqkckb5oF4EdyCF5WV0v3n8L5Wyuph1khgrwnMfLYpYA(UX9icEkcae)icleHyeHOpwifbLGC3Q4PJFramyrWhryu3RXsjLKYIbPiOeK72x6Q7grWFryHiGiRBnF34Eebpjic(HdR4PZIdRiSwNnjc9A4d3BzX9Ld)sxD3WxMdJr9CuRC4OpwifbLGC3Q4PJFramyrWhryu3RXsjLKYIbPiOeK72x6Q7goSINolo8QltdBtIaXhU3(H7lh(LU6UHVmhgJ65Ow5WRK7TLSaMoqmLsvs3yjJebWGfHOpwifbLGC3Q4PJFramyrigryu3RXQijqSCZgGNzuP6g7lD1DJiSqeI(y1OeZGaMKoRINo(fb)5WkE6S4WRhrpI4UG4d3Bac3xo8lD1DdFzomg1ZrTYHJrewj3BlzbmDGy0b9cAaAjJeHfIWk5EB3Nohj1qahl6sAxurWlcIGFeb)fbWGfbfpD8ZEDP(urWtcIaaeHfIqmIWk5EBjlGPdeJoOxqdqlzKiagSiSsU329PZrsneWXIUK2fve8IGi4hrWFoSINoloSRHaougGN0aj9A4d3BaAUVC4x6Q7g(YCymQNJALdhJie9XcPiOeK7wfpD8lcleHrDVglLusklgKIGsqUBFPRUBeb)fbWGfHOpwnkXmiGjPZQ4PJFoSINoloSw4thK6yy154d3Bah3xo8lD1DdFzomg1ZrTYHv80Xp71L6tfbpjicaqeadweIreqK1TMVBCpIGNeeb)iclebez1ywuk)iR57g3Ji4jbraGairWFoSINoloSIWADwePJE(W9w2M7lh(LU6UHVmhgJ65Ow5WXicrFSqkckb5UvXth)IWcryu3RXsjLKYIbPiOeK72x6Q7grWFramyri6JvJsmdcys6SkE64NdR4PZIdVB0xDzA4d3Bpae3xo8lD1DdFzomg1ZrTYHxj3BlzbmDGy0b9cAaAjJeHfIGINo(zVUuFQiqqe8qeadwewj3B7(05iPgc4yrxs7IkcEjcqyJiSqeu80Xp71L6tfbcIGhCyfpDwC4vfILB2GAmXu(W92dp4(YHFPRUB4lZHXOEoQvo80sxe8ueaaGebWGfbFeHl7i7OOBSivkQliMkf56H0CgudPXt3WEb11fbWGfbFeHl7i7OOBSXBANfl3mZLA65WkE6S4WK0Z65su(W92daW9Ld)sxD3WxMdR4PZIdR(LcurkLTZAy5MfLYpIdJr9CuRC4yeHtPVW3gVPDwSCZIoAF80zzFPRUBeHfIGpIWOUxJLSaMoqmLsvs3yFPRUBeb)fbWGfHyebFeHtPVW3IZY8IEdZ17Vte(wjfWNiryHi4JiCk9f(24nTZILBw0r7JNol7lD1DJi4phUuPZHv)sbQiLY2znSCZIs5hXhU3EayCF5WV0v3n8L5WkE6S4WQFPavKsz7SgwUzrP8J4Wyuph1khgNPZKYlRgLy1bkIEl6sAxurWlrWdzjcleHyeHtPVW3IZY8IEdZ17Vte(wjfWNiramyr4u6l8TXBANfl3SOJ2hpDw2x6Q7gryHimQ71yjlGPdetPuL0n2x6Q7grWFoCPsNdR(LcurkLTZAy5MfLYpIpCV9qwCF5WV0v3n8L5WkE6S4WQFPavKsz7SgwUzrP8J4Wyuph1khE3qahg6sAxurWlraNPZKYlRgLy1bkIEl6sAxuriwraWKfhUuPZHv)sbQiLY2znSCZIs5hXhU3E4hUVC4x6Q7g(YCyfpDwCyLcmUwNYqQFtedNi1XHXOEoQvoS5RK7TfP(nrmCIuhZ8vY92shftSi4Li4bhUuPZHvkW4ADkdP(nrmCIuhF4E7baH7lh(LU6UHVmhwXtNfhwPaJR1PmK63eXWjsDCymQNJALdh9XcrQitRfl3m1VhLdqRINo(fHfIq0hRgLygeWK0zv80XphUuPZHvkW4ADkdP(nrmCIuhF4E7ban3xo8lD1DdFzoSINoloSsbgxRtzi1VjIHtK64Wyuph1khgNPZKYlRgLy1bkIEl6QbKiSqeIreoL(cFlolZl6nmxV)or4BLuaFIeHfIWUHaom0L0UOIGxIaotNjLxwCwMx0ByUE)DIW3IUK2fveIveaaGebWGfbFeHtPVW3IZY8IEdZ17Vte(wjfWNirWFoCPsNdRuGX16ugs9BIy4ePo(W92dah3xo8lD1DdFzoSINoloSsbgxRtzi1VjIHtK64Wyuph1khE3qahg6sAxurWlraNPZKYlRgLy1bkIEl6sAxuriwraaaIdxQ05WkfyCToLHu)MigorQJpCV9q2M7lh(LU6UHVmhwXtNfhoEt7Sy5MzUutphgJ65Ow5WXic4mDMuEz1OeRoqr0BrxnGeHfIG5RK7TDF6Cuxqm5jzzS0rXelcEsqeKLiSqeoL(cFB8M2zXYnl6O9XtNL9LU6Ure8xeadwewj3BlzbmDGykLQKUXsgjcGblcrFSqkckb5UvXth)C4sLohoEt7Sy5MzUutpF4EdaaX9Ld)sxD3WxMdR4PZIdJuPOUGyQuKRhsZzqnKgpDd7fuxNdJr9CuRCyCMotkVSAuIvhOi6TOlPDrfbVebaicGblcJ6EnwfjbILB2a8mJkv3yFPRUBebWGfbK2g2J)ASQXqTDjcEjc(HdxQ05WivkQliMkf56H0CgudPXt3WEb115d3Ba4b3xo8lD1DdFzoSINolo8kiOSoB9NPojTumhgJ65Ow5W4mDMuEzPKsszXGueucYDl6sAxurWtraGairamyrWhryu3RXsjLKYIbPiOeK72x6Q7gryHimT0fbpfbaairamyrWhr4YoYok6glsLI6cIPsrUEinNb1qA80nSxqDDoCPsNdVcckRZw)zQtslfZhU3aaaCF5WV0v3n8L5WkE6S4Wa(tzat5UJ4Wyuph1kho6Jfsrqji3TkE64xeadwe8reg19ASusjPSyqkckb5U9LU6UrewictlDrWtraaaseadwe8reUSJSJIUXIuPOUGyQuKRhsZzqnKgpDd7fuxNdxQ05Wa(tzat5UJ4d3BaayCF5WV0v3n8L5WkE6S4WqQ7y15oIYwVsmhgJ65Ow5WrFSqkckb5UvXth)IayWIGpIWOUxJLskjLfdsrqji3TV0v3nIWcryAPlcEkcaaqIayWIGpIWLDKDu0nwKkf1fetLIC9qAodQH04PByVG66C4sLohgsDhRo3ru26vI5d3BailUVC4x6Q7g(YCyfpDwCyiuwquweQLuhdPqNdJr9CuRCyezDrWlcIaGjcleHyeHPLUi4PiaaajcGblc(icx2r2rr3yrQuuxqmvkY1dP5mOgsJNUH9cQRlc(ZHlv6CyiuwquweQLuhdPqNpCVbGF4(YHFPRUB4lZHXOEoQvomotNjLxwfjbILB2a8mZvJfD1aseadweI(yHueucYDRINo(fbWGfHvY92swathiMsPkPBSKrCyfpDwC4OC6S4d3Baaq4(YHFPRUB4lZHXOEoQvoSjhB8gr6EnSiNcrEl6sAxurWlcIae2WHv80zXHtYzfDLy(W9gaa0CF5WV0v3n8L5WkE6S4Wy15ykE6SyUMoCyxthwPsNdFk9f(u(W9gaaoUVC4x6Q7g(YCyfpDwCyS6CmfpDwmxthoSRPdRuPZHXz6mP8IYhU3aq2M7lh(LU6UHVmhgJ65Ow5WkE64N96s9PIGNeebaWHPdQXd3Bp4WkE6S4Wy15ykE6SyUMoCyxthwPsNdR55d3BadqCF5WV0v3n8L5Wyuph1khwXth)SxxQpveiicEWHPdQXd3Bp4WkE6S4Wy15ykE6SyUMoCyxthwPsNdd96OgZhU3aMhCF5WV0v3n8L5WkE6S4W7tNJ6cIrhut85Wyuph1kh28vY92UpDoQliM8KSmw6OyIfbVebzXHXGWUZgfb9HY92d(WhoCe64uAvhUVCV9G7lhwXtNfhgPn9mZvdh(LU6UHVmF4EdaUVC4x6Q7g(YC4sLohw9lfOIukBN1WYnlkLFehwXtNfhw9lfOIukBN1WYnlkLFeF4EdyCF5WV0v3n8L5WM7uqCyaWHv80zXHvKeiwUzdWZmxn8HpCyCMotkVOCF5E7b3xoSINoloSIKaXYnBaEM5QHd)sxD3WxMpCVba3xo8lD1DdFzomg1ZrTYHnFLCVT7tNJ6cIjpjlJLokMyrWtcIGSeHfIqmIGINo(zVUuFQi4jbraaIayWIGpIWP0x4BJ30olwUzrhTpE6SSV0v3nIayWIGpIG63J65wjfIKYYnBaEM5QX(sxD3icGblcNsFHVnEt7Sy5MfD0(4PZY(sxD3icleHyeHrDVglzbmDGykLQKUX(sxD3iclebCMotkVSKfW0bIPuQs6gl6sAxurWlcIaGjcGblc(icJ6EnwYcy6aXukvjDJ9LU6Ure8xe8NdR4PZIdRrjwDGIONpCVbmUVC4x6Q7g(YCymQNJALd7JiG02WE8xJvngQ9auA6qfbWGfbK2g2J)ASQXqTDjcEkcE4hoSINoloSrreZgKw0DIK0PZIpCVLf3xo8lD1DdFzomg1ZrTYHrKvJzrP8JSMVBCpIGxIGhYIdR4PZIdtjLKYIbPiOeK78H7TF4(YHFPRUB4lZHXOEoQvo8P0x4BJ30olwUzrhTpE6SSV0v3nIWcri6JvJsmdcys6SkE64xeadwemFLCVT7tNJ6cIjpjlJLokMyrWlrqwIWcrWhr4u6l8TXBANfl3SOJ2hpDw2x6Q7gryHieJi4JiO(9OEUvsHiPSCZgGNzUASV0v3nIayWIG63J65wjfIKYYnBaEM5QX(sxD3icleHOpwnkXmiGjPZQ4PJFrWFoSINolomzbmDGykLQKUHpCVbiCF5WV0v3n8L5Wyuph1khwXth)SxxQpve8KGiaaryHieJieJiGZ0zs5L1CDaY0YWmhRGSOlPDrfbViicqyJiSqe8reg19ASMVB3TV0v3nIG)IayWIqmIaotNjLxwZ3T7w0L0UOIGxeebiSrewicJ6EnwZ3T72x6Q7grWFrWFoSINolomzbmDGykLQKUHpCVbO5(YHFPRUB4lZHXOEoQvo8OiOp2PLoBsMPVi4Pi4HS4WkE6S4WuGkMy3zdWZil5jAacIpCVbCCF5WV0v3n8L5Wyuph1khwXth)SxxQpve8ueaahwXtNfhwxtPU0PZI5APv(W9w2M7lh(LU6UHVmhgJ65Ow5WkE64N96s9PIGNIaa4WkE6S4Wu5ksQliMuth(W92daX9Ld)sxD3WxMdJr9CuRC4rrqFStlD2KmtFrWlraWjcleHrrqFStlD2KmtFrWtrqwCyfpDwCyAs6yORrhXhU3E4b3xo8lD1DdFzomg1ZrTYHJre8reqAByp(RXQgd1EaknDOIayWIasBd7XFnw1yO2UebpfbaairWFryHiGiRlcErqeIre8qea4eHvY92swathiMsPkPBSKrIG)CyfpDwCyAs6yORrhXhU3EaaUVCyfpDwCyYcy6aXwDneWHd)sxD3WxMp8Hdd96OgZ9L7ThCF5WV0v3n8L5Wyuph1khELCVTusJ5fZKPKfDfpIWcrarw3oT0ztYKLi4PiaHnIWcrWhriUIAD1DBuMUUGy7eXGueucYDramyri6Jfsrqji3TkE64NdR4PZIdBUoaz4SD8H7na4(YHFPRUB4lZHXOEoQvomISAmlkLFK18DJ7re8se8qwIWcrarw3oT0ztYKLi4PiaHnIWcrWhriUIAD1DBuMUUGy7eXGueucYDoSINoloS56aKHZ2XhU3ag3xo8lD1DdFzomg1ZrTYHnFLCVT7tNJ6cIjpjlJLmIdR4PZIdtXjjc6m6GAIpF4EllUVC4x6Q7g(YCymQNJALdB(k5EB3Noh1fetEswglzKiSqeIreWz6mP8YQrjwDGIO3IUK2fve8ue8JiagSiy(k5EB3Noh1fetEswglDumXIGNIGSeb)5WkE6S4WyNkVligfOAs5u(W92pCF5WV0v3n8L5Wyuph1khgrwnMfLYpYA(UX9icEjcaaqIWcrWhriUIAD1DBuMUUGy7eXGueucYDoSINoloS56aKHZ2XhU3aeUVC4x6Q7g(YCymQNJALdB(k5EB3Noh1fetEswglDumXIGxIGSeHfIaotNjLxwnkXQdue9w0L0UOIGxIaGjcGblcMVsU329PZrDbXKNKLXshftSi4Li4bhwXtNfhEF6Cuxqm6GAIpF4EdqZ9Ld)sxD3WxMdJr9CuRCyFeH4kQ1v3Trz66cITtedsrqji35WkE6S4WMRdqgoBhF4dhwZZ9L7ThCF5WV0v3n8L5Wyuph1khgNPZKYlRgLy1bkIEl6sAxuryHiO4PJFMjh7(05OUGyYtYYicEkcaIdR4PZIdBUoazAzyMJvq8H7na4(YHFPRUB4lZHXOEoQvomotNjLxwnkXQdue9w0L0UOIWcrqXth)mto29PZrDbXKNKLre8ueaehwXtNfh28D7oF4EdyCF5WV0v3n8L5Wyuph1khgNPZKYlRgLy1bkIEl6sAxuryHiO4PJFMjh7(05OUGyYtYYicEkcaIdR4PZIdBUoaPmd55d3BzX9Ld)sxD3WxMdJr9CuRCyZ1bitldZCScYonM4UGeHfIaISAmlkLFK18DJ7re8se8qwIWcrWhryu3RXUsIOtxqmAIo1(sxD3iclebFeH4kQ1v3Trz66cITtedsrqji35WkE6S4WpQnxQX8H7TF4(YHFPRUB4lZHXOEoQvoS56aKPLHzowbzNgtCxqIWcrigrWhrWCDaYiUAiGJDlpjlZnSrrqFOIWcryu3RXUsIOtxqmAIo1(sxD3ic(lclebFeH4kQ1v3Trz66cITtedsrqji35WkE6S4WpQnxQX8H7naH7lh(LU6UHVmhgJ65Ow5WMRdqMwgM5yfKDAmXDbjclebCMotkVSAuIvhOi6TOlPDr5WkE6S4WuCsIGoJoOM4ZhU3a0CF5WV0v3n8L5Wyuph1kh2CDaY0YWmhRGStJjUliryHiGZ0zs5LvJsS6afrVfDjTlkhwXtNfhg7u5DbXOavtkNYhU3aoUVC4x6Q7g(YCymQNJALd7JiexrTU6UnktxxqSDIyqkckb5ohwXtNfh(rT5snMpCVLT5(YHFPRUB4lZHv80zXH3Noh1feJoOM4ZHXOEoQvoCmIqmIqmIqmIG5RK7TDF6Cuxqm5jzzS0rXelcEjcYsewic(icRK7TLSaMoqmLsvs3yjJeb)fbWGfbZxj3B7(05OUGyYtYYyPJIjwe8seamrWFryHiGZ0zs5LvJsS6afrVfDjTlQi4LiayIG)IayWIG5RK7TDF6Cuxqm5jzzS0rXelcEjcEic(lcleHyebCMotkVSkscel3Sb4zMRgl6sAxurWtrWpIG)CymiS7SrrqFOCV9GpCV9aqCF5WV0v3n8L5Wyuph1khELCVTusJ5fZKPKfDfpIWcrarw3oT0ztYKLi4PiaHnCyfpDwCyZ1bidNTJpCV9WdUVC4x6Q7g(YCymQNJALdVsU3wkPX8IzYuYIUIhryHi4JiexrTU6UnktxxqSDIyqkckb5UiagSie9XcPiOeK7wfpD8ZHv80zXHnxhGmC2o(W92daW9Ld)sxD3WxMdJr9CuRCyez1ywuk)iR57g3Ji4Li4HSeHfIqmIaotNjLxwnkXQdue9w0L0UOIGNIGFebWGfbZxj3B7(05OUGyYtYYyPJIjwe8ueKLi4ViSqe8reIROwxD3gLPRli2ormifbLGCNdR4PZIdBUoaz4SD8H7Thag3xo8lD1DdFzoSINolomfNKiOZOdQj(CymQNJALdhJieJiGZ0zs5LvrsGy5MnapZC1yrxs7IkcEkc(readwemxhGmIRgc4ynnvxDNP5yeb)fHfIqmIaotNjLxwnkXQdue9w0L0UOIGNIGFeHfIG5RK7TDF6Cuxqm5jzzS0rXelcEkcaseadwemFLCVT7tNJ6cIjpjlJLokMyrWtrqwIG)IWcrigry3qahg6sAxurWlraNPZKYlR56aKPLHzowbzrxs7IkcXkcEairamyry3qahg6sAxurWtraNPZKYlRgLy1bkIEl6sAxurWFrWFomge2D2OiOpuU3EWhU3EilUVC4x6Q7g(YCyfpDwCyStL3feJcunPCkhgJ65Ow5WXicXic4mDMuEzvKeiwUzdWZmxnw0L0UOIGNIGFebWGfbZ1biJ4QHaowtt1v3zAogrWFryHieJiGZ0zs5LvJsS6afrVfDjTlQi4Pi4hryHiy(k5EB3Noh1fetEswglDumXIGNIaGebWGfbZxj3B7(05OUGyYtYYyPJIjwe8ueKLi4ViSqeIre2neWHHUK2fve8seWz6mP8YAUoazAzyMJvqw0L0UOIqSIGhaseadwe2neWHHUK2fve8ueWz6mP8YQrjwDGIO3IUK2fve8xe8NdJbHDNnkc6dL7Th8H7Th(H7lh(LU6UHVmhgJ65Ow5WiYQXSOu(rwZ3nUhrWlraaasewic(icXvuRRUBJY01feBNigKIGsqUZHv80zXHnxhGmC2o(W92dac3xo8lD1DdFzomg1ZrTYHJreIreIreIremFLCVT7tNJ6cIjpjlJLokMyrWlrqwIWcrWhryLCVTKfW0bIPuQs6glzKi4ViagSiy(k5EB3Noh1fetEswglDumXIGxIaGjc(lclebCMotkVSAuIvhOi6TOlPDrfbVebate8xeadwemFLCVT7tNJ6cIjpjlJLokMyrWlrWdrWFryHieJiGZ0zs5LvrsGy5MnapZC1yrxs7IkcEkc(readwemxhGmIRgc4ynnvxDNP5yeb)5WkE6S4W7tNJ6cIrhut85d3BpaO5(YHFPRUB4lZHXOEoQvoS56aKPLHzowbzNgtCxqCyfpDwCykojrqNrhut85d3BpaCCF5WV0v3n8L5Wyuph1kh2hriUIAD1DBuMUUGy7eXGueucYDoSINoloS56aKHZ2Xh(WhoC8JODwCVbaGaaG8aqE4bhwUIQUGOCyzRsrjAUreaiIGINolrW10HAfeXHvYbyI4WWTePtNolzpKUhoCek3T7CyaMiiBPaMoqIaavxhGIGS)QHaocIayIaaF4jxpse8aWKreaaGaaGeejicGjcYEa1c6uzZcIayIaaNiiBYyUreKn2Lrea4H(97TcIayIaaNii7Lv8JMBeHrrqFy9weWzz6PZIkctkcOdr6uKiGZY0tNf1kicGjcaCIGSpf3QJUeaVSgri3IGSHu(rIWi)kXuRGibrkE6SO2i0XP0QoXsyjK20ZmxncIu80zrTrOJtPvDILWsK0Z65sYuQ0jO(LcurkLTZAy5MfLYpsqKINolQncDCkTQtSewsrsGy5MnapZC1iJ5ofebaiisqeateaOgGYXKZnIWJFeiryAPlcdWlckEsKi0urqJRTtxD3kisXtNfLGuxg2g973lisXtNfnwclfxrTU6UmLkDcrz66cITtedsrqji3LjU6ipbCMotkVSusjPSyqkckb5UfDjTlQx(zXOUxJLskjLfdsrqji3TV0v3ncIayIGSpf3QJkJiiBDUevgrqlJiKdWJeHecBOcIu80zrJLWskcR1ztIqVgz6nbez1ywuk)iR57g3JNae)SiMOpwifbLGC3Q4PJFWG9zu3RXsjLKYIbPiOeK72x6Q7g)xGiRBnF34E8KGFeeP4PZIglHLwDzAyBseiz6nHOpwifbLGC3Q4PJFWG9zu3RXsjLKYIbPiOeK72x6Q7gbrkE6SOXsyP1JOhrCxqY0BcRK7TLSaMoqmLsvs3yjJado6Jfsrqji3TkE64hm4yg19ASkscel3Sb4zgvQUX(sxD3Si6JvJsmdcys6SkE643FbrkE6SOXsyjxdbCOmapPbs61itVjeZk5EBjlGPdeJoOxqdqlz0IvY92UpDosQHaow0L0UOErWp(dgSINo(zVUuFQNeaWIywj3BlzbmDGy0b9cAaAjJadELCVT7tNJKAiGJfDjTlQxe8J)cIu80zrJLWsAHpDqQJHvNtMEtiMOpwifbLGC3Q4PJ)fJ6EnwkPKuwmifbLGC3(sxD34pyWrFSAuIzqatsNvXth)cIu80zrJLWskcR1zrKo6LP3eu80Xp71L6t9KaaadogezDR57g3JNe8Zcez1ywuk)iR57g3JNeaiaYFbrkE6SOXsyPDJ(QltJm9MqmrFSqkckb5UvXth)lg19ASusjPSyqkckb5U9LU6UXFWGJ(y1OeZGaMKoRINo(feP4PZIglHLwviwUzdQXetLP3ewj3BlzbmDGy0b9cAaAjJwO4PJF2Rl1NsWdWGxj3B7(05iPgc4yrxs7I6fe2SqXth)SxxQpLGhcIayIGShjDsjryqDr8hQiqsvOlisXtNfnwclrspRNlrLP3eMw6EcaabgSpx2r2rr3yrQuuxqmvkY1dP5mOgsJNUH9cQRdgSpx2r2rr3yJ30olwUzMl10lisXtNfnwclrspRNljtPsNG6xkqfPu2oRHLBwuk)iz6nHyoL(cFB8M2zXYnl6O9XtNL9LU6UzHpJ6EnwYcy6aXukvjDJ9LU6UXFWGJXNtPVW3IZY8IEdZ17Vte(wjfWNOf(Ck9f(24nTZILBw0r7JNol7lD1DJ)cIu80zrJLWsK0Z65sYuQ0jO(LcurkLTZAy5MfLYpsMEtaNPZKYlRgLy1bkIEl6sAxuV8qwlI5u6l8T4SmVO3WC9(7eHVvsb8jcm4tPVW3gVPDwSCZIoAF80zzFPRUBwmQ71yjlGPdetPuL0n2x6Q7g)feP4PZIglHLiPN1ZLKPuPtq9lfOIukBN1WYnlkLFKm9MWUHaom0L0UOEHZ0zs5LvJsS6afrVfDjTlASaMSeeP4PZIglHLiPN1ZLKPuPtqPaJR1PmK63eXWjsDY0BcMVsU3wK63eXWjsDmZxj3BlDumXE5HGifpDw0yjSej9SEUKmLkDckfyCToLHu)MigorQtMEti6JfIurMwlwUzQFpkhGwfpD8Vi6JvJsmdcys6SkE64xqKINolASewIKEwpxsMsLobLcmUwNYqQFtedNi1jtVjGZ0zs5LvJsS6afrVfD1aArmNsFHVfNL5f9gMR3FNi8TskGprl2neWHHUK2f1lCMotkVS4SmVO3WC9(7eHVfDjTlASaaqGb7ZP0x4BXzzErVH5693jcFRKc4tK)cIu80zrJLWsK0Z65sYuQ0jOuGX16ugs9BIy4ePoz6nHDdbCyOlPDr9cNPZKYlRgLy1bkIEl6sAx0ybaGeeP4PZIglHLiPN1ZLKPuPtiEt7Sy5MzUutVm9Mqm4mDMuEz1OeRoqr0BrxnGwy(k5EB3Noh1fetEswglDumXEsqwloL(cFB8M2zXYnl6O9XtNL9LU6UXFWGxj3BlzbmDGykLQKUXsgbgC0hlKIGsqUBv80XVGifpDw0yjSej9SEUKmLkDcivkQliMkf56H0CgudPXt3WEb11LP3eWz6mP8YQrjwDGIO3IUK2f1laag8OUxJvrsGy5MnapZOs1n2x6Q7gWGrAByp(RXQgd12Lx(rqKINolASewIKEwpxsMsLoHvqqzD26ptDsAPyz6nbCMotkVSusjPSyqkckb5UfDjTlQNaeabgSpJ6EnwkPKuwmifbLGC3(sxD3SyAP7jaaeyW(CzhzhfDJfPsrDbXuPixpKMZGAinE6g2lOUUGifpDw0yjSej9SEUKmLkDca(tzat5UJKP3eI(yHueucYDRINo(bd2NrDVglLusklgKIGsqUBFPRUBwmT09eaacmyFUSJSJIUXIuPOUGyQuKRhsZzqnKgpDd7fuxxqKINolASewIKEwpxsMsLobi1DS6ChrzRxjwMEti6Jfsrqji3TkE64hmyFg19ASusjPSyqkckb5U9LU6UzX0s3taaiWG95YoYok6glsLI6cIPsrUEinNb1qA80nSxqDDbrkE6SOXsyjs6z9Cjzkv6eGqzbrzrOwsDmKcDz6nbezDViaylIzAP7jaaeyW(CzhzhfDJfPsrDbXuPixpKMZGAinE6g2lOUU)cIu80zrJLWsr50zjtVjGZ0zs5LvrsGy5MnapZC1yrxnGado6Jfsrqji3TkE64hm4vY92swathiMsPkPBSKrcIayIGSrTRr7QliraG)gr6EnIGSbNcrErOPIGkcrOor9asqKINolASewkjNv0vILP3em5yJ3is3RHf5uiYBrxs7I6fbiSrqKINolASewcRohtXtNfZ10rMsLoHtPVWNkisXtNfnwclHvNJP4PZI5A6itPsNaotNjLxubrkE6SOXsyjS6CmfpDwmxthzOdQXdbpKPuPtqZltVjO4PJF2Rl1N6jbaiisXtNfnwclHvNJP4PZI5A6idDqnEi4HmLkDcqVoQXY0BckE64N96s9Pe8qqKINolASewAF6Cuxqm6GAIVmyqy3zJIG(qj4Hm9MG5RK7TDF6Cuxqm5jzzS0rXe7LSeejicGjcYMsaQfbuo60zjisXtNf1Q5jyUoazAzyMJvqY0Bc4mDMuEz1OeRoqr0Brxs7IUqXth)mto29PZrDbXKNKLXtajisXtNf1Q5JLWsMVB3LP3eWz6mP8YQrjwDGIO3IUK2fDHINo(zMCS7tNJ6cIjpjlJNasqKINolQvZhlHLmxhGuMH8Y0Bc4mDMuEz1OeRoqr0Brxs7IUqXth)mto29PZrDbXKNKLXtajisXtNf1Q5JLWspQnxQXY0BcMRdqMwgM5yfKDAmXDbTarwnMfLYpYA(UX94LhYAHpJ6En2vseD6cIrt0P2x6Q7Mf(exrTU6UnktxxqSDIyqkckb5UGifpDwuRMpwcl9O2CPgltVjyUoazAzyMJvq2PXe3f0Iy8XCDaYiUAiGJDlpjlZnSrrqFOlg19ASRKi60feJMOtTV0v3n(VWN4kQ1v3Trz66cITtedsrqji3feP4PZIA18XsyjkojrqNrhut8LP3emxhGmTmmZXki70yI7cAbotNjLxwnkXQdue9w0L0UOcIu80zrTA(yjSe2PY7cIrbQMuovMEtWCDaY0YWmhRGStJjUlOf4mDMuEz1OeRoqr0Brxs7IkisXtNf1Q5JLWspQnxQXY0Bc(exrTU6UnktxxqSDIyqkckb5UGifpDwuRMpwclTpDoQligDqnXxgmiS7SrrqFOe8qMEtiMyIjgZxj3B7(05OUGyYtYYyPJIj2lzTWNvY92swathiMsPkPBSKr(dgS5RK7TDF6Cuxqm5jzzS0rXe7fG5)cCMotkVSAuIvhOi6TOlPDr9cW8hmyZxj3B7(05OUGyYtYYyPJIj2lp8Frm4mDMuEzvKeiwUzdWZmxnw0L0UOE6h)feP4PZIA18XsyjZ1bidNTtMEtyLCVTusJ5fZKPKfDfplqK1TtlD2Kmz5je2iisXtNf1Q5JLWsMRdqgoBNm9MWk5EBPKgZlMjtjl6kEw4tCf16Q72OmDDbX2jIbPiOeK7Gbh9XcPiOeK7wfpD8lisXtNf1Q5JLWsMRdqgoBNm9MaISAmlkLFK18DJ7XlpK1IyWz6mP8YQrjwDGIO3IUK2f1t)agS5RK7TDF6Cuxqm5jzzS0rXe7PS8FHpXvuRRUBJY01feBNigKIGsqUlisXtNf1Q5JLWsuCsIGoJoOM4ldge2D2OiOpucEitVjetm4mDMuEzvKeiwUzdWZmxnw0L0UOE6hWGnxhGmIRgc4ynnvxDNP5y8Frm4mDMuEz1OeRoqr0Brxs7I6PFwy(k5EB3Noh1fetEswglDumXEciWGnFLCVT7tNJ6cIjpjlJLokMypLL)lIz3qahg6sAxuVWz6mP8YAUoazAzyMJvqw0L0UOX6bGadE3qahg6sAxupXz6mP8YQrjwDGIO3IUK2f1F)feP4PZIA18XsyjStL3feJcunPCQmyqy3zJIG(qj4Hm9MqmXGZ0zs5LvrsGy5MnapZC1yrxs7I6PFad2CDaYiUAiGJ10uD1DMMJX)fXGZ0zs5LvJsS6afrVfDjTlQN(zH5RK7TDF6Cuxqm5jzzS0rXe7jGad28vY92UpDoQliM8KSmw6OyI9uw(ViMDdbCyOlPDr9cNPZKYlR56aKPLHzowbzrxs7IgRhacm4DdbCyOlPDr9eNPZKYlRgLy1bkIEl6sAxu)9xqKINolQvZhlHLmxhGmC2oz6nbez1ywuk)iR57g3Jxaaql8jUIAD1DBuMUUGy7eXGueucYDbrkE6SOwnFSewAF6Cuxqm6GAIVm9MqmXetmMVsU329PZrDbXKNKLXshftSxYAHpRK7TLSaMoqmLsvs3yjJ8hmyZxj3B7(05OUGyYtYYyPJIj2laZ)f4mDMuEz1OeRoqr0Brxs7I6fG5pyWMVsU329PZrDbXKNKLXshftSxE4)IyWz6mP8YQijqSCZgGNzUASOlPDr90pGbBUoazexneWXAAQU6otZX4VGifpDwuRMpwclrXjjc6m6GAIVm9MG56aKPLHzowbzNgtCxqcIu80zrTA(yjSK56aKHZ2jtVj4tCf16Q72OmDDbX2jIbPiOeK7cIeeP4PZIAXz6mP8IsqrsGy5MnapZC1iisXtNf1IZ0zs5fnwclPrjwDGIOxMEtW8vY92UpDoQliM8KSmw6OyI9KGSweJINo(zVUuFQNeaayW(Ck9f(24nTZILBw0r7JNol7lD1DdyW(O(9OEUvsHiPSCZgGNzUASV0v3nGbFk9f(24nTZILBw0r7JNol7lD1DZIyg19ASKfW0bIPuQs6g7lD1DZcCMotkVSKfW0bIPuQs6gl6sAxuViayGb7ZOUxJLSaMoqmLsvs3yFPRUB83FbrkE6SOwCMotkVOXsyjJIiMniTO7ejPtNLm9MGpiTnSh)1yvJHApaLMouWGrAByp(RXQgd12LNE4hbrkE6SOwCMotkVOXsyjkPKuwmifbLGCxMEtarwnMfLYpYA(UX94LhYsqKINolQfNPZKYlASewISaMoqmLsvs3itVjCk9f(24nTZILBw0r7JNol7lD1DZIOpwnkXmiGjPZQ4PJFWGnFLCVT7tNJ6cIjpjlJLokMyVK1cFoL(cFB8M2zXYnl6O9XtNL9LU6Uzrm(O(9OEUvsHiPSCZgGNzUASV0v3nGbR(9OEUvsHiPSCZgGNzUASV0v3nlI(y1OeZGaMKoRINo(9xqKINolQfNPZKYlASewISaMoqmLsvs3itVjO4PJF2Rl1N6jbaSiMyWz6mP8YAUoazAzyMJvqw0L0UOEracBw4ZOUxJ18D7U9LU6UXFWGJbNPZKYlR572Dl6sAxuViaHnlg19ASMVB3TV0v3n(7VGifpDwulotNjLx0yjSefOIj2D2a8mYsEIgGGKP3egfb9XoT0ztYm990dzjisXtNf1IZ0zs5fnwclPRPux60zXCT0Qm9MGINo(zVUuFQNaqqKINolQfNPZKYlASewIkxrsDbXKA6itVjO4PJF2Rl1N6jaeeP4PZIAXz6mP8IglHLOjPJHUgDKmJIG(W6nHrrqFStlD2KmtFVaClgfb9XoT0ztYm99uwcIu80zrT4mDMuErJLWs0K0XqxJosMEtigFqAByp(RXQgd1EaknDOGbJ02WE8xJvngQTlpbaG8FbISUxeIXdaUvY92swathiMsPkPBSKr(lisXtNf1IZ0zs5fnwclrwathi2QRHaocIeeP4PZIApL(cFkbPlLiqSCZCK42WmORsuz6nbezD70sNnjZdpHWMfiYQXSOu(rEjlajisXtNf1Ek9f(0yjS0Qltdl3Sb4zVUeiz6nbZ1bitldZCScYonM4UGado6JvJsmdcys6SkE64FHINo(zVUuFkbpeeP4PZIApL(cFASewcIurMwlwUzQFpkhGY0BcXGZ0zs5LvJsS6afrVfDjTlQxaKf4mDMuEzvKeiwUzdWZmxnw0L0UOEIZ0zs5LfNL5f9gMR3FNi8TOlPDr9hmyCMotkVSkscel3Sb4zMRgl6sAxuVaGGifpDwu7P0x4tJLWsdWZiR1KSmSDIWxMEtyLCVTOJj2DkLTte(wYiWGxj3Bl6yIDNsz7eHpdNK1CKLokMyV8WdbrkE6SO2tPVWNglHL2jMKEdt97r9C26vjz6nbFmxhGmTmmZXki70yI7csqKINolQ9u6l8PXsyjCw4xdsNByBNkDz6nbtowCw4xdsNByBNkD2kjQSOlPDrjaibrkE6SO2tPVWNglHLIir9guxqSvNshz6nbFmxhGmTmmZXki70yI7csqKINolQ9u6l8PXsyj5jYzI)UyOtZsl8LP3eg19ASkscel3Sb4zgvQUX(sxD3S4u6l8TXBANfl3SOJ2hpDwwPUs0IvY92swathigDqVGgGwYiWGpL(cFB8M2zXYnl6O9XtNLvQReTi6JvJsmdcys6SkE64hm4rDVgRIKaXYnBaEMrLQBSV0v3nlI(y1OeZGaMKoRINo(xGZ0zs5LvrsGy5MnapZC1yrxs7I6jabqGbpQ71yvKeiwUzdWZmQuDJ9LU6Uzr0hRIKaXGaMKoRINo(feP4PZIApL(cFASewsEICM4Vlg60S0cFz6nbFmxhGmTmmZXki70yI7cAXk5EBjlGPdeJoOxqdqlz0cFoL(cFB8M2zXYnl6O9XtNLvQReTWNrDVgRIKaXYnBaEMrLQBSV0v3nGbpkc6JDAPZMKz67fotNjLxwnkXQdue9w0L0UOcIu80zrTNsFHpnwclH6Oi3zDXOrk(Y0Bc(yUoazAzyMJvq2PXe3fKGifpDwu7P0x4tJLWsORrDbX2ov6uz6nbFwj3BBu7CkILB2gL0XsgTWNvY92UIUoaz5Mr7YGuOKQwYOfXmkc6Jf4v3aKfHhpja4aeyWJIG(ybE1nazr4XlcaaqGbVBiGddDjTlQxYYp(lisqKINolQf61rnMG56aKHZ2jtVjSsU3wkPX8IzYuYIUINfiY62PLoBsMS8ecBw4tCf16Q72OmDDbX2jIbPiOeK7Gbh9XcPiOeK7wfpD8lisXtNf1c96OghlHLmxhGmC2oz6nbez1ywuk)iR57g3JxEiRfiY62PLoBsMS8ecBw4tCf16Q72OmDDbX2jIbPiOeK7cIu80zrTqVoQXXsyjkojrqNrhut8LP3emFLCVT7tNJ6cIjpjlJLmsqKINolQf61rnowclHDQ8UGyuGQjLtLP3emFLCVT7tNJ6cIjpjlJLmArm4mDMuEz1OeRoqr0Brxs7I6PFad28vY92UpDoQliM8KSmw6OyI9uw(lisXtNf1c96OghlHLmxhGmC2oz6nbez1ywuk)iR57g3Jxaaql8jUIAD1DBuMUUGy7eXGueucYDbrkE6SOwOxh14yjS0(05OUGy0b1eFz6nbZxj3B7(05OUGyYtYYyPJIj2lzTaNPZKYlRgLy1bkIEl6sAxuVamWGnFLCVT7tNJ6cIjpjlJLokMyV8qqKINolQf61rnowclzUoaz4SDY0Bc(exrTU6UnktxxqSDIyqkckb5oF4dNda]] )

end
