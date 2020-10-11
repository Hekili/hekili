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


    spec:RegisterPack( "Unholy", 20201011, [[dG0BAbqiHWJaq1MucJsi5ucfVsi1SikDlauAxu6xkrgga5yiuldaEgvbMga11ekzBai(gasnoQcvNdafRJQqO5rvQ7HG9rv0bPkeSqLOEivHIjcGKCraKuBKQGWjPke1kriVKQqPUjvbP2jvj)KQGidLQGKLsvOKNcYufIUkvHiBLQGO2lQ(lkdwWHjTyL0JHAYuCzvBwP(mOgnGoTuRMQG61efZMk3Mi7wYVfnCQQJtviTCiphPPR46iA7cvFNOA8aiX5bY6fk18bQ9tyoX8i5qgDo3laaiaaiIbeXeBjgqagGHyaAo0aY)CiFflJcFouPsNd5rQaMoqCiFfKlvdpsoenjr4ZHaoJp1J4slb3dqYvloLwI2sKoD6SWiDplrBj8sCOvY2nEKl(khYOZ5EbaabaarmGiMylXacWametmhI6Fm3laelaWHa2gZl(khYCkMdbWfbpsfW0bseaO66aue8yxnmWrqeaxe8qcp56rIaXelRiaaabaajisqeaxe8yaQf8PEefebWfbawrWJGXCJi4HUlJi4Ha9h7BfebWfbawrWJjR4hn3icJIG)W6TiGZY0tNfveMueqhM0PiraNLPNolQvqeaxeayfbpwkUvhDjpeznIqUfbpuP8JeHr(vzOwoKRPdLhjh6u6l8P8i5Ermpso0lD1DdFzoeg1ZrTYHqK1TtlD2KmIfbpfbySrewiciYQXm)u(rIG3IaGbehsXtNfhs6sjcel3mhjUnmd6QeLpCVaapso0lD1DdFzoeg1ZrTYHmxhGmTmmZXki70yz6cweadwe8)yv)eZGbMKoRINo(fHfIGINo(zVUuFQiqqeiMdP4PZIdT6Y0WYnBaE2RlbIpCV8aEKCOx6Q7g(YCimQNJALdfLiGZ0zs5Lv9tS6a5tVfDjTlQi4TiaqeHfIaotNjLxwfjbILB2a8mZvJfDjTlQi4PiGZ0zs5LfNL5f9gMR3FNi8TOlPDrfHyebWGfbCMotkVSkscel3Sb4zMRgl6sAxurWBraaCifpDwCiysfzATy5MPX(OCaYhUxaMhjh6LU6UHVmhcJ65Ow5qRK7TfDSmUtPSDIW3s6lcGblcRK7TfDSmUtPSDIWNHtYAoYshflJi4TiqmXCifpDwCOb4zK1Aswg2or4ZhUxXIhjh6LU6UHVmhcJ65Ow5qricMRdqMwgM5yfKDASmDbZHu80zXH2jMKEdtJ9r9C26vj(W9cGWJKd9sxD3WxMdHr9CuRCitowCw4xdsNByBNkD2kjQSOlPDrfbcIaG4qkE6S4q4SWVgKo3W2ov68H7fanpso0lD1DdFzoeg1ZrTYHIqemxhGmTmmZXki70yz6cMdP4PZId5tI6nOUGzRoLo8H7LhNhjh6LU6UHVmhcJ65Ow5qJ6EnwfjbILB2a8mJkv3yFPRUBeHfIWP0x4BJ30olwUz(hTpE6SSsDLiryHiSsU3wYcy6aXOd6f8a0s6lcGblcNsFHVnEt7Sy5M5F0(4PZYk1vIeHfIG)hR6NygmWK0zv80XViagSimQ71yvKeiwUzdWZmQuDJ9LU6Urewic(FSQFIzWatsNvXth)IWcraNPZKYlRIKaXYnBaEM5QXIUK2fve8ueaiaseadweg19ASkscel3Sb4zgvQUX(sxD3icleb)pwfjbIbdmjDwfpD8ZHu80zXHKNiNj(7IHonlTWNpCVay4rYHEPRUB4lZHWOEoQvoueIG56aKPLHzowbzNgltxWIWcryLCVTKfW0bIrh0l4bOL0xewicricNsFHVnEt7Sy5M5F0(4PZYk1vIeHfIqeIWOUxJvrsGy5MnapZOs1n2x6Q7gramyryue8h70sNnjZ0xe8weWz6mP8YQ(jwDG8P3IUK2fLdP4PZIdjprot83fdDAwAHpF4ErmG4rYHEPRUB4lZHWOEoQvoueIG56aKPLHzowbzNgltxWCifpDwCiu777oRlg1xXNpCViMyEKCOx6Q7g(YCimQNJALdfHiSsU3w)25uel3SnkPJL0xewicricRK7TDfDDaYYnJ2LbPWjvTK(IWcrikryue8hlWRUbiZhpIGNeebpoGebWGfHrrWFSaV6gGmF8icEtqeaaGebWGfHDddCyOlPDrfbVfbahlrigoKINoloe6QFxWSTtLoLp8Hdz(wjDdpsUxeZJKdP4PZIdj1LHTr)X(COx6Q7g(Y8H7fa4rYHEPRUB4lZHsFoe9dhsXtNfhkUIAD1DouC1rEoeotNjLxwkPKuwmyfbNGC3IUK2fve8weILiSqeg19ASusjPSyWkcob5U9LU6UHdfxrSsLohYptxxWSDIyWkcob5oF4E5b8i5qV0v3n8L5qyuph1khcrwnM5NYpYA(UX9icEkcaKyjcleHOeb)pwyfbNGC3Q4PJFramyricryu3RXsjLKYIbRi4eK72x6Q7grigryHiGiRBnF34EebpjicXIdP4PZIdPiSwNnjc9A4d3laZJKd9sxD3WxMdHr9CuRCi)pwyfbNGC3Q4PJFramyricryu3RXsjLKYIbRi4eK72x6Q7goKINolo0QltdBtIaXhUxXIhjh6LU6UHVmhcJ65Ow5qRK7TLSaMoqmLsvs3yj9fbWGfb)pwyfbNGC3Q4PJFramyrikryu3RXQijqSCZgGNzuP6g7lD1DJiSqe8)yv)eZGbMKoRINo(fHy4qkE6S4qRhrpsMUG5d3lacpso0lD1DdFzoeg1ZrTYHIsewj3BlzbmDGy0b9cEaAj9fHfIWk5EB3Nohj1Wahl6sAxurWBcIqSeHyebWGfbfpD8ZEDP(urWtcIaaeHfIquIWk5EBjlGPdeJoOxWdqlPViagSiSsU329PZrsnmWXIUK2fve8MGielrigoKINoloKRHbouMhM0al9A4d3laAEKCOx6Q7g(YCimQNJALdfLi4)XcRi4eK7wfpD8lcleHrDVglLusklgSIGtqUBFPRUBeHyebWGfb)pw1pXmyGjPZQ4PJFoKINoloKw4thK6yy154d3lpopso0lD1DdFzoeg1ZrTYHu80Xp71L6tfbpjicaqeadweIseqK1TMVBCpIGNeeHyjclebez1yMFk)iR57g3Ji4jbraGairigoKINoloKIWADMpPJE(W9cGHhjh6LU6UHVmhcJ65Ow5qrjc(FSWkcob5UvXth)IWcryu3RXsjLKYIbRi4eK72x6Q7grigramyrW)Jv9tmdgys6SkE64NdP4PZIdTB0xDzA4d3lIbepso0lD1DdFzoeg1ZrTYHwj3BlzbmDGy0b9cEaAj9fHfIGINo(zVUuFQiqqeiweadwewj3B7(05iPgg4yrxs7IkcElcWyJiSqeu80Xp71L6tfbcIaXCifpDwCOvfMLB2GASmu(W9IyI5rYHEPRUB4lZHWOEoQvo00sxe8ueaaGebWGfHieH7rjBF)BSivYVlyMk576H0CgCdRXt3WEb31fbWGfHieH7rjBF)BSXBANfl3mZLA65qkE6S4qK0Z65su(W9IyaWJKd9sxD3WxMdP4PZIdPXMcurkLTZAy5M5NYpIdHr9CuRCOOeHtPVW3gVPDwSCZ8pAF80zzFPRUBeHfIqeIWOUxJLSaMoqmLsvs3yFPRUBeHyebWGfHOeHieHtPVW3IZY8IEdZ17Vte(wj1dNiryHieHiCk9f(24nTZILBM)r7JNol7lD1DJiedhQuPZH0ytbQiLY2znSCZ8t5hXhUxe7b8i5qV0v3n8L5qkE6S4qASPavKsz7SgwUz(P8J4qyuph1khcNPZKYlR6Ny1bYNEl6sAxurWBrGyalcleHOeHtPVW3IZY8IEdZ17Vte(wj1dNiramyr4u6l8TXBANfl3m)J2hpDw2x6Q7gryHimQ71yjlGPdetPuL0n2x6Q7grigouPsNdPXMcurkLTZAy5M5NYpIpCVigW8i5qV0v3n8L5qkE6S4qASPavKsz7SgwUz(P8J4qyuph1khA3Wahg6sAxurWBraNPZKYlR6Ny1bYNEl6sAxuriArWdamhQuPZH0ytbQiLY2znSCZ8t5hXhUxehlEKCOx6Q7g(YCifpDwCiLcmUwNYqAStedNi1XHWOEoQvoK5RK7TfPXormCIuhZ8vY92shflJi4TiqmhQuPZHukW4ADkdPXormCIuhF4ErmaHhjh6LU6UHVmhsXtNfhsPaJR1PmKg7eXWjsDCimQNJALd5)XctQitRfl3mn2hLdqRINo(fHfIG)hR6NygmWK0zv80XphQuPZHukW4ADkdPXormCIuhF4Ermanpso0lD1DdFzoKINoloKsbgxRtzin2jIHtK64qyuph1khcNPZKYlR6Ny1bYNEl6QbKiSqeIseoL(cFlolZl6nmxV)or4BLupCIeHfIWUHbom0L0UOIG3IaotNjLxwCwMx0ByUE)DIW3IUK2fveIweaaGebWGfHieHtPVW3IZY8IEdZ17Vte(wj1dNirigouPsNdPuGX16ugsJDIy4ePo(W9Iypopso0lD1DdFzoKINoloKsbgxRtzin2jIHtK64qyuph1khA3Wahg6sAxurWBraNPZKYlR6Ny1bYNEl6sAxuriAraaaIdvQ05qkfyCToLH0yNigorQJpCVigGHhjh6LU6UHVmhsXtNfhkEt7Sy5MzUutphcJ65Ow5qrjc4mDMuEzv)eRoq(0BrxnGeHfIG5RK7TDF6CuxWm5jzzS0rXYicEsqeaSiSqeoL(cFB8M2zXYnZ)O9XtNL9LU6UreIreadwewj3BlzbmDGykLQKUXs6lcGblc(FSWkcob5UvXth)COsLohkEt7Sy5MzUutpF4EbaaXJKd9sxD3WxMdP4PZIdHuj)UGzQKVRhsZzWnSgpDd7fCxNdHr9CuRCiCMotkVSQFIvhiF6TOlPDrfbVfbaicGblcJ6EnwfjbILB2a8mJkv3yFPRUBebWGfbK2g2J)ASQXqTDjcElcXIdvQ05qivYVlyMk576H0CgCdRXt3WEb315d3laqmpso0lD1DdFzoKINolo0ki4SoB9NPojTumhcJ65Ow5q4mDMuEzPKsszXGveCcYDl6sAxurWtraGairamyricryu3RXsjLKYIbRi4eK72x6Q7gryHimT0fbpfbaairamyricr4EuY23)glsL87cMPs(UEinNb3WA80nSxWDDouPsNdTccoRZw)zQtslfZhUxaaa8i5qV0v3n8L5qkE6S4qE4tzat5UJ4qyuph1khY)JfwrWji3TkE64xeadweIqeg19ASusjPSyWkcob5U9LU6UrewictlDrWtraaaseadweIqeUhLS99VXIuj)UGzQKVRhsZzWnSgpDd7fCxNdvQ05qE4tzat5UJ4d3la4b8i5qV0v3n8L5qkE6S4qWQ7y15oIYwVkdhcJ65Ow5q(FSWkcob5UvXth)IayWIqeIWOUxJLskjLfdwrWji3TV0v3nIWcryAPlcEkcaaqIayWIqeIW9OKTV)nwKk53fmtL8D9qAodUH14PByVG76COsLohcwDhRo3ru26vz4d3laayEKCOx6Q7g(YCifpDwCiyuwWuMpQLuhdPWNdHr9CuRCiezDrWBcIGhicleHOeHPLUi4PiaaajcGblcric3Js2((3yrQKFxWmvY31dP5m4gwJNUH9cURlcXWHkv6CiyuwWuMpQLuhdPWNpCVaqS4rYHEPRUB4lZHWOEoQvoeotNjLxwfjbILB2a8mZvJfD1aseadwe8)yHveCcYDRINo(fbWGfHvY92swathiMsPkPBSK(CifpDwCi)C6S4d3laaq4rYHEPRUB4lZHWOEoQvoKjhB8gr6EnmFNctEl6sAxurWBcIam2WHu80zXHsYzfDvg(W9caa08i5qV0v3n8L5qkE6S4qy15ykE6SyUMoCixthwPsNdDk9f(u(W9caECEKCOx6Q7g(YCifpDwCiS6CmfpDwmxthoKRPdRuPZHWz6mP8IYhUxaaGHhjh6LU6UHVmhcJ65Ow5qkE64N96s9PIGNeebaWHOdQXd3lI5qkE6S4qy15ykE6SyUMoCixthwPsNdP55d3lpaq8i5qV0v3n8L5qyuph1khsXth)SxxQpveiiceZHOdQXd3lI5qkE6S4qy15ykE6SyUMoCixthwPsNdb)6OgZhUxEaX8i5qV0v3n8L5qkE6S4q7tNJ6cMrhulZ5qyuph1khY8vY92UpDoQlyM8KSmw6OyzebVfbaZHWGWUZgfb)HY9Iy(WhoKp64uAvhEKCViMhjhsXtNfhYpNolo0lD1DdFz(W9ca8i5qkE6S4qiTPNzUA4qV0v3n8L5d3lpGhjh6LU6UHVmhQuPZH0ytbQiLY2znSCZ8t5hXHu80zXH0ytbQiLY2znSCZ8t5hXhUxaMhjh6LU6UHVmhYCNcIdbaoKINoloKIKaXYnBaEM5QHp8HdHZ0zs5fLhj3lI5rYHu80zXHuKeiwUzdWZmxnCOx6Q7g(Y8H7fa4rYHEPRUB4lZHWOEoQvoK5RK7TDF6CuxWm5jzzS0rXYicEsqeaSiSqeIseu80Xp71L6tfbpjicaqeadweIqeoL(cFB8M2zXYnZ)O9XtNL9LU6UreadweIqe0yFup3kPWKuwUzdWZmxn2x6Q7gramyr4u6l8TXBANfl3m)J2hpDw2x6Q7gryHieLimQ71yjlGPdetPuL0n2x6Q7gryHiGZ0zs5LLSaMoqmLsvs3yrxs7IkcEtqe8aramyricryu3RXswathiMsPkPBSV0v3nIqmIqmCifpDwCi1pXQdKp98H7LhWJKd9sxD3WxMdHr9CuRCOiebK2g2J)ASQXqThGsthQiagSiG02WE8xJvngQTlrWtrG4yXHu80zXHmksg2G0IUtKKoDw8H7fG5rYHEPRUB4lZHWOEoQvoeISAmZpLFK18DJ7re8weigWCifpDwCikPKuwmyfbNGCNpCVIfpso0lD1DdFzoeg1ZrTYHoL(cFB8M2zXYnZ)O9XtNL9LU6Urewic(FSQFIzWatsNvXth)IayWIG5RK7TDF6CuxWm5jzzS0rXYicElcawewicricNsFHVnEt7Sy5M5F0(4PZY(sxD3icleHOeHiebn2h1ZTskmjLLB2a8mZvJ9LU6Ureadwe0yFup3kPWKuwUzdWZmxn2x6Q7gryHi4)XQ(jMbdmjDwfpD8lcXWHu80zXHilGPdetPuL0n8H7faHhjh6LU6UHVmhcJ65Ow5qkE64N96s9PIGNeebaicleHOeHOebCMotkVSMRdqMwgM5yfKfDjTlQi4nbragBeHfIqeIWOUxJ18D7U9LU6UreIreadweIseWz6mP8YA(UD3IUK2fve8MGiaJnIWcryu3RXA(UD3(sxD3icXicXWHu80zXHilGPdetPuL0n8H7fanpso0lD1DdFzoeg1ZrTYHgfb)XoT0ztYm9fbpfbIbmhsXtNfhIcuXY4oBaEgzjprdqq8H7LhNhjh6LU6UHVmhcJ65Ow5qkE64N96s9PIGNIaa4qkE6S4q6Ak1LoDwmxlTYhUxam8i5qV0v3n8L5qyuph1khsXth)SxxQpve8ueaahsXtNfhIkxrsDbZKA6WhUxediEKCOx6Q7g(YCimQNJALdnkc(JDAPZMKz6lcElcECryHimkc(JDAPZMKz6lcEkcaMdP4PZIdrtshdD1)i(W9IyI5rYHEPRUB4lZHWOEoQvouuIqeIasBd7XFnw1yO2dqPPdveadweqAByp(RXQgd12Li4PiaaajcXiclebezDrWBcIquIaXIaaRiSsU3wYcy6aXukvjDJL0xeIHdP4PZIdrtshdD1)i(W9IyaWJKdP4PZIdrwathi2QRHboCOx6Q7g(Y8HpCi4xh1yEKCViMhjh6LU6UHVmhcJ65Ow5qRK7TLsAmVyMmLSOR4rewiciY62PLoBsgGfbpfbySrewicricXvuRRUB9Z01fmBNigSIGtqUlcGblc(FSWkcob5UvXth)CifpDwCiZ1bidNTJpCVaapso0lD1DdFzoeg1ZrTYHqKvJz(P8JSMVBCpIG3IaXawewiciY62PLoBsgGfbpfbySrewicricXvuRRUB9Z01fmBNigSIGtqUZHu80zXHmxhGmC2o(W9Yd4rYHEPRUB4lZHWOEoQvoK5RK7TDF6CuxWm5jzzSK(CifpDwCikojrWNrhulZ5d3laZJKd9sxD3WxMdHr9CuRCiZxj3B7(05OUGzYtYYyj9fHfIquIaotNjLxw1pXQdKp9w0L0UOIGNIqSebWGfbZxj3B7(05OUGzYtYYyPJILre8ueaSiedhsXtNfhc7u5DbZOavtkNYhUxXIhjh6LU6UHVmhcJ65Ow5qiYQXm)u(rwZ3nUhrWBraaasewicricXvuRRUB9Z01fmBNigSIGtqUZHu80zXHmxhGmC2o(W9cGWJKd9sxD3WxMdHr9CuRCiZxj3B7(05OUGzYtYYyPJILre8weaSiSqeWz6mP8YQ(jwDG8P3IUK2fve8we8aramyrW8vY92UpDoQlyM8KSmw6OyzebVfbI5qkE6S4q7tNJ6cMrhulZ5d3laAEKCOx6Q7g(YCimQNJALdfHiexrTU6U1ptxxWSDIyWkcob5ohsXtNfhYCDaYWz74dF4qAEEKCViMhjh6LU6UHVmhcJ65Ow5q4mDMuEzv)eRoq(0Brxs7IkclebfpD8Zm5y3Noh1fmtEswgrWtraqCifpDwCiZ1bitldZCScIpCVaapso0lD1DdFzoeg1ZrTYHWz6mP8YQ(jwDG8P3IUK2fvewickE64NzYXUpDoQlyM8KSmIGNIaG4qkE6S4qMVB35d3lpGhjh6LU6UHVmhcJ65Ow5q4mDMuEzv)eRoq(0Brxs7IkclebfpD8Zm5y3Noh1fmtEswgrWtraqCifpDwCiZ1biLzipF4EbyEKCOx6Q7g(YCimQNJALdzUoazAzyMJvq2PXY0fSiSqeqKvJz(P8JSMVBCpIG3IaXawewicricJ6En2vseD6cMrt0P2x6Q7gryHieHiexrTU6U1ptxxWSDIyWkcob5ohsXtNfh6(T5snMpCVIfpso0lD1DdFzoeg1ZrTYHmxhGmTmmZXki70yz6cwewicrjcricMRdqMmvddCSB5jzzUHnkc(dvewicJ6En2vseD6cMrt0P2x6Q7grigryHieHiexrTU6U1ptxxWSDIyWkcob5ohsXtNfh6(T5snMpCVai8i5qV0v3n8L5qyuph1khYCDaY0YWmhRGStJLPlyryHiGZ0zs5Lv9tS6a5tVfDjTlkhsXtNfhIItse8z0b1YC(W9cGMhjh6LU6UHVmhcJ65Ow5qMRdqMwgM5yfKDASmDblclebCMotkVSQFIvhiF6TOlPDr5qkE6S4qyNkVlygfOAs5u(W9YJZJKd9sxD3WxMdHr9CuRCOieH4kQ1v3T(z66cMTtedwrWji35qkE6S4q3VnxQX8H7fadpso0lD1DdFzoKINolo0(05OUGz0b1YCoeg1ZrTYHIseIseIseIsemFLCVT7tNJ6cMjpjlJLokwgrWBraWIWcricryLCVTKfW0bIPuQs6glPVieJiagSiy(k5EB3Noh1fmtEswglDuSmIG3IGhicXiclebCMotkVSQFIvhiF6TOlPDrfbVfbpqeIreadwemFLCVT7tNJ6cMjpjlJLokwgrWBrGyrigryHieLiGZ0zs5LvrsGy5MnapZC1yrxs7IkcEkcXseIHdHbHDNnkc(dL7fX8H7fXaIhjh6LU6UHVmhcJ65Ow5qRK7TLsAmVyMmLSOR4rewiciY62PLoBsgGfbpfbySHdP4PZIdzUoaz4SD8H7fXeZJKd9sxD3WxMdHr9CuRCOvY92sjnMxmtMsw0v8icleHieH4kQ1v3T(z66cMTtedwrWji3fbWGfb)pwyfbNGC3Q4PJFoKINoloK56aKHZ2XhUxedaEKCOx6Q7g(YCimQNJALdHiRgZ8t5hznF34EebVfbIbSiSqeIseWz6mP8YQ(jwDG8P3IUK2fve8ueILiagSiy(k5EB3Noh1fmtEswglDuSmIGNIaGfHyeHfIqeIqCf16Q7w)mDDbZ2jIbRi4eK7CifpDwCiZ1bidNTJpCVi2d4rYHEPRUB4lZHu80zXHO4KebFgDqTmNdHr9CuRCOOeHOebCMotkVSkscel3Sb4zMRgl6sAxurWtriwIayWIG56aKjt1WahRPP6Q7mnhJieJiSqeIseWz6mP8YQ(jwDG8P3IUK2fve8ueILiSqemFLCVT7tNJ6cMjpjlJLokwgrWtraqIayWIG5RK7TDF6CuxWm5jzzS0rXYicEkcaweIrewicrjc7gg4Wqxs7IkcElc4mDMuEznxhGmTmmZXkil6sAxuriArGyajcGblc7gg4Wqxs7IkcEkc4mDMuEzv)eRoq(0Brxs7IkcXicXWHWGWUZgfb)HY9Iy(W9IyaZJKd9sxD3WxMdP4PZIdHDQ8UGzuGQjLt5qyuph1khkkrikraNPZKYlRIKaXYnBaEM5QXIUK2fve8ueILiagSiyUoazYunmWXAAQU6otZXicXicleHOebCMotkVSQFIvhiF6TOlPDrfbpfHyjclebZxj3B7(05OUGzYtYYyPJILre8ueaKiagSiy(k5EB3Noh1fmtEswglDuSmIGNIaGfHyeHfIquIWUHbom0L0UOIG3IaotNjLxwZ1bitldZCScYIUK2fveIweigqIayWIWUHbom0L0UOIGNIaotNjLxw1pXQdKp9w0L0UOIqmIqmCimiS7SrrWFOCViMpCViow8i5qV0v3n8L5qyuph1khcrwnM5NYpYA(UX9icElcaaqIWcricriUIAD1DRFMUUGz7eXGveCcYDoKINoloK56aKHZ2XhUxedq4rYHEPRUB4lZHWOEoQvouuIquIquIquIG5RK7TDF6CuxWm5jzzS0rXYicElcawewicricRK7TLSaMoqmLsvs3yj9fHyebWGfbZxj3B7(05OUGzYtYYyPJILre8we8arigryHiGZ0zs5Lv9tS6a5tVfDjTlQi4Ti4bIqmIayWIG5RK7TDF6CuxWm5jzzS0rXYicElcelcXicleHOebCMotkVSkscel3Sb4zMRgl6sAxurWtriwIayWIG56aKjt1WahRPP6Q7mnhJiedhsXtNfhAF6CuxWm6GAzoF4Ermanpso0lD1DdFzoeg1ZrTYHmxhGmTmmZXki70yz6cMdP4PZIdrXjjc(m6GAzoF4ErShNhjh6LU6UHVmhcJ65Ow5qricXvuRRUB9Z01fmBNigSIGtqUZHu80zXHmxhGmC2o(Wh(WHIFeTZI7faaeaaeGayaaaHdjxrvxWuoKhzj)en3icaerqXtNLi4A6qTcI4qk5amrCiOwI0PtNLhds3dhYhL72Doeaxe8ivathiraGQRdqrWJD1WahbraCrWdj8KRhjcetSSIaaaeaaKGibraCrWJbOwWN6ruqeaxeayfbpcgZnIGh6UmIGhc0FSVvqeaxeayfbpMSIF0CJimkc(dR3IaoltpDwurysraDysNIebCwME6SOwbraCraGve8yP4wD0L8qK1ic5we8qLYpseg5xLHAfejisXtNf16JooLw1jAcl5NtNLGifpDwuRp64uAvNOjSesB6zMRgbrkE6SOwF0XP0Qortyjs6z9Cjzlv6e0ytbQiLY2znSCZ8t5hjisXtNf16JooLw1jAclPijqSCZgGNzUAK1CNcIaaeejicGlcaudq5yY5gr4XpcKimT0fHb4fbfpjseAQiOX12PRUBfeP4PZIsqQldBJ(J9feP4PZIgnHLIROwxDx2sLob)mDDbZ2jIbRi4eK7YgxDKNaotNjLxwkPKuwmyfbNGC3IUK2f17yTyu3RXsjLKYIbRi4eK72x6Q7gbraCrWJLIB1rLve8ipxIkRiOLreYb4rIqcJnubrkE6SOrtyjfH16SjrOxJS9MaISAmZpLFK18DJ7XtasSweL)hlSIGtqUBv80XpyWrmQ71yPKsszXGveCcYD7lD1DtmlqK1TMVBCpEsiwcIu80zrJMWsRUmnSnjcKS9MG)hlSIGtqUBv80XpyWrmQ71yPKsszXGveCcYD7lD1DJGifpDw0OjS06r0JKPlyz7nHvY92swathiMsPkPBSK(Gb7)XcRi4eK7wfpD8dgCuJ6EnwfjbILB2a8mJkv3yFPRUBw4)XQ(jMbdmjDwfpD8hJGifpDw0OjSKRHbouMhM0al9AKT3eIALCVTKfW0bIrh0l4bOL0FXk5EB3Nohj1Wahl6sAxuVjeRyadwXth)SxxQp1tcayruRK7TLSaMoqm6GEbpaTK(GbVsU329PZrsnmWXIUK2f1BcXkgbrkE6SOrtyjTWNoi1XWQZjBVjeL)hlSIGtqUBv80X)IrDVglLusklgSIGtqUBFPRUBIbmy)pw1pXmyGjPZQ4PJFbrkE6SOrtyjfH16mFsh9Y2BckE64N96s9PEsaaGbhfISU18DJ7XtcXAbISAmZpLFK18DJ7XtcaeafJGifpDw0OjS0UrF1LPr2Etik)pwyfbNGC3Q4PJ)fJ6EnwkPKuwmyfbNGC3(sxD3edyW(FSQFIzWatsNvXth)cIu80zrJMWsRkml3Sb1yzOY2BcRK7TLSaMoqm6GEbpaTK(lu80Xp71L6tjqmyWRK7TDF6CKuddCSOlPDr9ggBwO4PJF2Rl1NsGybraCrWJHKoPKimOUK5dveiPk8feP4PZIgnHLiPN1ZLOY2BctlDpbaGadoI7rjBF)BSivYVlyMk576H0CgCdRXt3WEb31bdoI7rjBF)BSXBANfl3mZLA6feP4PZIgnHLiPN1ZLKTuPtqJnfOIukBN1WYnZpLFKS9MquNsFHVnEt7Sy5M5F0(4PZY(sxD3SiIrDVglzbmDGykLQKUX(sxD3edyWrfXP0x4BXzzErVH5693jcFRK6Ht0IioL(cFB8M2zXYnZ)O9XtNL9LU6UjgbrkE6SOrtyjs6z9Cjzlv6e0ytbQiLY2znSCZ8t5hjBVjGZ0zs5Lv9tS6a5tVfDjTlQ3ed4frDk9f(wCwMx0ByUE)DIW3kPE4ebg8P0x4BJ30olwUz(hTpE6SSV0v3nlg19ASKfW0bIPuQs6g7lD1DtmcIu80zrJMWsK0Z65sYwQ0jOXMcurkLTZAy5M5NYps2Ety3Wahg6sAxuVXz6mP8YQ(jwDG8P3IUK2fnApaWcIu80zrJMWsK0Z65sYwQ0jOuGX16ugsJDIy4ePoz7nbZxj3BlsJDIy4ePoM5RK7TLokwgVjwqKINolA0ewIKEwpxs2sLobLcmUwNYqAStedNi1jBVj4)XctQitRfl3mn2hLdqRINo(x4)XQ(jMbdmjDwfpD8lisXtNfnAclrspRNljBPsNGsbgxRtzin2jIHtK6KT3eWz6mP8YQ(jwDG8P3IUAaTiQtPVW3IZY8IEdZ17Vte(wj1dNOf7gg4Wqxs7I6notNjLxwCwMx0ByUE)DIW3IUK2fnAaaiWGJ4u6l8T4SmVO3WC9(7eHVvs9WjkgbrkE6SOrtyjs6z9Cjzlv6eukW4ADkdPXormCIuNS9MWUHbom0L0UOEJZ0zs5Lv9tS6a5tVfDjTlA0aaqcIu80zrJMWsK0Z65sYwQ0jeVPDwSCZmxQPx2EtikCMotkVSQFIvhiF6TORgqlmFLCVT7tNJ6cMjpjlJLokwgpja4fNsFHVnEt7Sy5M5F0(4PZY(sxD3edyWRK7TLSaMoqmLsvs3yj9bd2)JfwrWji3TkE64xqKINolA0ewIKEwpxs2sLobKk53fmtL8D9qAodUH14PByVG76Y2Bc4mDMuEzv)eRoq(0Brxs7I6naadEu3RXQijqSCZgGNzuP6g7lD1DdyWiTnSh)1yvJHA7Y7yjisXtNfnAclrspRNljBPsNWki4SoB9NPojTuSS9MaotNjLxwkPKuwmyfbNGC3IUK2f1tacGadoIrDVglLusklgSIGtqUBFPRUBwmT09eaacm4iUhLS99VXIuj)UGzQKVRhsZzWnSgpDd7fCxxqKINolA0ewIKEwpxs2sLobp8PmGPC3rY2Bc(FSWkcob5UvXth)GbhXOUxJLskjLfdwrWji3TV0v3nlMw6EcaabgCe3Js2((3yrQKFxWmvY31dP5m4gwJNUH9cURlisXtNfnAclrspRNljBPsNaS6owDUJOS1RYiBVj4)XcRi4eK7wfpD8dgCeJ6EnwkPKuwmyfbNGC3(sxD3SyAP7jaaeyWrCpkz77FJfPs(DbZujFxpKMZGBynE6g2l4UUGifpDw0OjSej9SEUKSLkDcWOSGPmFulPogsHVS9MaISU3e8GfrnT09eaacm4iUhLS99VXIuj)UGzQKVRhsZzWnSgpDd7fCxpgbrkE6SOrtyj)C6SKT3eWz6mP8YQijqSCZgGNzUASORgqGb7)XcRi4eK7wfpD8dg8k5EBjlGPdetPuL0nwsFbraCrWdT21OD1fSi4HCJiDVgrWdLtHjVi0urqfbFuNOEajisXtNfnAclLKZk6QmY2BcMCSXBeP71W8Dkm5TOlPDr9Mam2iisXtNfnAclHvNJP4PZI5A6iBPsNWP0x4tfeP4PZIgnHLWQZXu80zXCnDKTuPtaNPZKYlQGifpDw0OjSewDoMINolMRPJS0b14HaXYwQ0jO5LT3eu80Xp71L6t9KaaeeP4PZIgnHLWQZXu80zXCnDKLoOgpeiw2sLob4xh1yz7nbfpD8ZEDP(ucelisXtNfnAclTpDoQlygDqTmxwmiS7SrrWFOeiw2EtW8vY92UpDoQlyM8KSmw6Oyz8gWcIeebWfbpcja1IakhD6SeeP4PZIA18emxhGmTmmZXkiz7nbCMotkVSQFIvhiF6TOlPDrxO4PJFMjh7(05OUGzYtYY4jGeeP4PZIA18rtyjZ3T7Y2Bc4mDMuEzv)eRoq(0Brxs7IUqXth)mto29PZrDbZKNKLXtajisXtNf1Q5JMWsMRdqkZqEz7nbCMotkVSQFIvhiF6TOlPDrxO4PJFMjh7(05OUGzYtYY4jGeeP4PZIA18rtyP73Ml1yz7nbZ1bitldZCScYonwMUGxGiRgZ8t5hznF34E8MyaViIrDVg7kjIoDbZOj6u7lD1DZIiIROwxD36NPRly2ormyfbNGCxqKINolQvZhnHLUFBUuJLT3emxhGmTmmZXki70yz6cEruryUoazYunmWXULNKL5g2Oi4p0fJ6En2vseD6cMrt0P2x6Q7MywerCf16Q7w)mDDbZ2jIbRi4eK7cIu80zrTA(OjSefNKi4ZOdQL5Y2BcMRdqMwgM5yfKDASmDbVaNPZKYlR6Ny1bYNEl6sAxubrkE6SOwnF0ewc7u5DbZOavtkNkBVjyUoazAzyMJvq2PXY0f8cCMotkVSQFIvhiF6TOlPDrfeP4PZIA18rtyP73Ml1yz7nHiIROwxD36NPRly2ormyfbNGCxqKINolQvZhnHL2Noh1fmJoOwMllge2D2Oi4pucelBVjevurfL5RK7TDF6CuxWm5jzzS0rXY4nGxeXk5EBjlGPdetPuL0nws)yad28vY92UpDoQlyM8KSmw6Oyz82dIzbotNjLxw1pXQdKp9w0L0UOE7bXagS5RK7TDF6CuxWm5jzzS0rXY4nXXSikCMotkVSkscel3Sb4zMRgl6sAxupJvmcIu80zrTA(OjSK56aKHZ2jBVjSsU3wkPX8IzYuYIUINfiY62PLoBsgG9egBeeP4PZIA18rtyjZ1bidNTt2EtyLCVTusJ5fZKPKfDfplIiUIAD1DRFMUUGz7eXGveCcYDWG9)yHveCcYDRINo(feP4PZIA18rtyjZ1bidNTt2EtarwnM5NYpYA(UX94nXaEru4mDMuEzv)eRoq(0Brxs7I6zSad28vY92UpDoQlyM8KSmw6Oyz8eWXSiI4kQ1v3T(z66cMTtedwrWji3feP4PZIA18rtyjkojrWNrhulZLfdc7oBue8hkbILT3eIkkCMotkVSkscel3Sb4zMRgl6sAxupJfyWMRdqMmvddCSMMQRUZ0CmXSikCMotkVSQFIvhiF6TOlPDr9mwlmFLCVT7tNJ6cMjpjlJLokwgpbeyWMVsU329PZrDbZKNKLXshflJNaoMfrTByGddDjTlQ34mDMuEznxhGmTmmZXkil6sAx0OjgqGbVByGddDjTlQN4mDMuEzv)eRoq(0Brxs7IgtmcIu80zrTA(OjSe2PY7cMrbQMuovwmiS7SrrWFOeiw2EtiQOWz6mP8YQijqSCZgGNzUASOlPDr9mwGbBUoazYunmWXAAQU6otZXeZIOWz6mP8YQ(jwDG8P3IUK2f1ZyTW8vY92UpDoQlyM8KSmw6Oyz8eqGbB(k5EB3Noh1fmtEswglDuSmEc4ywe1UHbom0L0UOEJZ0zs5L1CDaY0YWmhRGSOlPDrJMyabg8UHbom0L0UOEIZ0zs5Lv9tS6a5tVfDjTlAmXiisXtNf1Q5JMWsMRdqgoBNS9MaISAmZpLFK18DJ7XBaaOfrexrTU6U1ptxxWSDIyWkcob5UGifpDwuRMpAclTpDoQlygDqTmx2EtiQOIkkZxj3B7(05OUGzYtYYyPJILXBaViIvY92swathiMsPkPBSK(XagS5RK7TDF6CuxWm5jzzS0rXY4TheZcCMotkVSQFIvhiF6TOlPDr92dIbmyZxj3B7(05OUGzYtYYyPJILXBIJzru4mDMuEzvKeiwUzdWZmxnw0L0UOEglWGnxhGmzQgg4ynnvxDNP5yIrqKINolQvZhnHLO4KebFgDqTmx2EtWCDaY0YWmhRGStJLPlybrkE6SOwnF0ewYCDaYWz7KT3eIiUIAD1DRFMUUGz7eXGveCcYDbrcIu80zrT4mDMuErjOijqSCZgGNzUAeeP4PZIAXz6mP8IgnHLu)eRoq(0lBVjy(k5EB3Noh1fmtEswglDuSmEsaWlIsXth)SxxQp1tcaam4ioL(cFB8M2zXYnZ)O9XtNL9LU6Ubm4i0yFup3kPWKuwUzdWZmxn2x6Q7gWGpL(cFB8M2zXYnZ)O9XtNL9LU6UzruJ6EnwYcy6aXukvjDJ9LU6UzbotNjLxwYcy6aXukvjDJfDjTlQ3e8aWGJyu3RXswathiMsPkPBSV0v3nXeJGifpDwulotNjLx0OjSKrrYWgKw0DIK0PZs2EticK2g2J)ASQXqThGsthkyWiTnSh)1yvJHA7YtIJLGifpDwulotNjLx0OjSeLusklgSIGtqUlBVjGiRgZ8t5hznF34E8MyalisXtNf1IZ0zs5fnAclrwathiMsPkPBKT3eoL(cFB8M2zXYnZ)O9XtNL9LU6UzH)hR6NygmWK0zv80XpyWMVsU329PZrDbZKNKLXshflJ3aEreNsFHVnEt7Sy5M5F0(4PZY(sxD3SiQi0yFup3kPWKuwUzdWZmxn2x6Q7gWG1yFup3kPWKuwUzdWZmxn2x6Q7Mf(FSQFIzWatsNvXth)XiisXtNf1IZ0zs5fnAclrwathiMsPkPBKT3eu80Xp71L6t9Kaawevu4mDMuEznxhGmTmmZXkil6sAxuVjaJnlIyu3RXA(UD3(sxD3edyWrHZ0zs5L18D7UfDjTlQ3eGXMfJ6EnwZ3T72x6Q7MyIrqKINolQfNPZKYlA0ewIcuXY4oBaEgzjprdqqY2BcJIG)yNw6SjzM(EsmGfeP4PZIAXz6mP8IgnHL01uQlD6SyUwAv2EtqXth)SxxQp1taiisXtNf1IZ0zs5fnAclrLRiPUGzsnDKT3eu80Xp71L6t9eacIu80zrT4mDMuErJMWs0K0Xqx9ps2rrWFy9MWOi4p2PLoBsMPV3E8fJIG)yNw6SjzM(EcybrkE6SOwCMotkVOrtyjAs6yOR(hjBVjeveiTnSh)1yvJHApaLMouWGrAByp(RXQgd12LNaaqXSarw3Bcrrma7k5EBjlGPdetPuL0nws)yeeP4PZIAXz6mP8IgnHLilGPdeB11WahbrcIu80zrTNsFHpLG0LseiwUzosCByg0vjQS9MaISUDAPZMKrSNWyZcez1yMFk)iVbmGeeP4PZIApL(cFA0ewA1LPHLB2a8SxxcKS9MG56aKPLHzowbzNgltxWGb7)XQ(jMbdmjDwfpD8VqXth)SxxQpLaXcIu80zrTNsFHpnAclbtQitRfl3mn2hLdqz7nHOWz6mP8YQ(jwDG8P3IUK2f1BaYcCMotkVSkscel3Sb4zMRgl6sAxupXz6mP8YIZY8IEdZ17Vte(w0L0UOXagmotNjLxwfjbILB2a8mZvJfDjTlQ3aqqKINolQ9u6l8PrtyPb4zK1Aswg2or4lBVjSsU3w0XY4oLY2jcFlPpyWRK7TfDSmUtPSDIWNHtYAoYshflJ3etSGifpDwu7P0x4tJMWs7etsVHPX(OEoB9QKS9MqeMRdqMwgM5yfKDASmDblisXtNf1Ek9f(0OjSeol8RbPZnSTtLUS9MGjhlol8RbPZnSTtLoBLevw0L0UOeaKGifpDwu7P0x4tJMWs(KOEdQly2QtPJS9MqeMRdqMwgM5yfKDASmDblisXtNf1Ek9f(0OjSK8e5mXFxm0PzPf(Y2BcJ6EnwfjbILB2a8mJkv3yFPRUBwCk9f(24nTZILBM)r7JNolRuxjAXk5EBjlGPdeJoOxWdqlPpyWNsFHVnEt7Sy5M5F0(4PZYk1vIw4)XQ(jMbdmjDwfpD8dg8OUxJvrsGy5MnapZOs1n2x6Q7Mf(FSQFIzWatsNvXth)lWz6mP8YQijqSCZgGNzUASOlPDr9eGaiWGh19ASkscel3Sb4zgvQUX(sxD3SW)JvrsGyWatsNvXth)cIu80zrTNsFHpnAcljprot83fdDAwAHVS9MqeMRdqMwgM5yfKDASmDbVyLCVTKfW0bIrh0l4bOL0FreNsFHVnEt7Sy5M5F0(4PZYk1vIweXOUxJvrsGy5MnapZOs1n2x6Q7gWGhfb)XoT0ztYm99gNPZKYlR6Ny1bYNEl6sAxubrkE6SO2tPVWNgnHLqTVV7SUyuFfFz7nHimxhGmTmmZXki70yz6cwqKINolQ9u6l8Prtyj0v)UGzBNkDQS9MqeRK7T1VDofXYnBJs6yj9xeXk5EBxrxhGSCZODzqkCsvlP)IOgfb)Xc8QBaY8XJNe84acm4rrWFSaV6gGmF84nbaaiWG3nmWHHUK2f1BahRyeejisXtNf1c)6OgtWCDaYWz7KT3ewj3BlL0yEXmzkzrxXZcezD70sNnjdWEcJnlIiUIAD1DRFMUUGz7eXGveCcYDWG9)yHveCcYDRINo(feP4PZIAHFDuJJMWsMRdqgoBNS9MaISAmZpLFK18DJ7XBIb8cezD70sNnjdWEcJnlIiUIAD1DRFMUUGz7eXGveCcYDbrkE6SOw4xh14OjSefNKi4ZOdQL5Y2BcMVsU329PZrDbZKNKLXs6lisXtNf1c)6OghnHLWovExWmkq1KYPY2BcMVsU329PZrDbZKNKLXs6VikCMotkVSQFIvhiF6TOlPDr9mwGbB(k5EB3Noh1fmtEswglDuSmEc4yeeP4PZIAHFDuJJMWsMRdqgoBNS9MaISAmZpLFK18DJ7XBaaOfrexrTU6U1ptxxWSDIyWkcob5UGifpDwul8RJAC0ewAF6CuxWm6GAzUS9MG5RK7TDF6CuxWm5jzzS0rXY4nGxGZ0zs5Lv9tS6a5tVfDjTlQ3EayWMVsU329PZrDbZKNKLXshflJ3elisXtNf1c)6OghnHLmxhGmC2oz7nHiIROwxD36NPRly2ormyfbNGCNp8HZb]] )

end
