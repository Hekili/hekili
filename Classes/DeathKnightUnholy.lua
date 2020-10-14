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
    spec:RegisterPet( "army_ghoul", 24207, "army_of_the_dead", 30 )


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

        local army_expires = action.army_of_the_dead.lastCast + 30
        if army_expires > now then
            summonPet( "army_ghoul", army_expires - now )
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

        if state:IsKnown( "deaths_due" ) and cooldown.deaths_due.remains then setCooldown( "death_and_decay", cooldown.deaths_due.remains )
        elseif talent.defile.enabled and cooldown.defile.remains then setCooldown( "death_and_decay", cooldown.defile.remains ) end
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

            spend = function () return buff.sudden_doom.up and 0 or 30 end,
            spendType = "runic_power",

            startsCombat = true,
            texture = 136066,

            targets = {
                count = function () return active_dot.virulent_plague end,
            },

            usable = function () return active_dot.virulent_plague > 0 end,
            handler = function ()
                removeBuff( "sudden_doom" )
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


        sacrificial_pact = {
            id = 327574,
            cast = 0,
            cooldown = 120,
            gcd = "spell",
            
            spend = 20,
            spendType = "runic_power",
            
            toggle = "cooldowns",

            startsCombat = true,
            texture = 136133,
            
            handler = function ()
                dismissPet( "ghoul" )
            end,
        },


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


    spec:RegisterPack( "Unholy", 20201014, [[dOu4sbqiHWJuKWMqvnkaYPaqRsrIQxjuzwOkDlfjr7cLFju1Wes6ykILbL4zqjzAcjUgaSnaQ8nfjLXbqvohusvRdkPI5Pi19a0(Gqhurs1cfs9qOKsteGQIlQij1gvKi1hvKi6KqjfwjuQxQirYnbOQANOk(jusLgkavLwQIefpfQMQq0vHskARksuAVe9xsnybhMYIPkpMWKbDzvBgOpdPrtvDAjRwrIWRHGzJ0TvWUL63knCf1XvKewoINtLPl66OY2fkFhIgpaLZRqRxrsY8HI9tYYjYiL4qlVKhSevSe1jrDsuytIYeSefapjEooFj(SjqWqVeVTHlXXA2(lDuIpBJ01GYiL4ULJiUe3pZzhwN4JhTsFopMyhI3vdCulRTfedmJ3vdI4L4ECfnXA0spjo0Yl5blrflrDsuNef2KOmblrzQjXDZxi5blaalsC)ccFl9K4W7es8PqfWA2(lDufa85w6RctP6c1pvypfQawxrUENOctIcVQawIkwIQcBf2tHkG16Bn6DyDuypfQWuPkm1HWdvba)vdvHP0K)PQZuypfQWuPkm1HWdvbS2n2BRthtItlx6KrkXrFFsjKrk5zImsj(BZJEOmAjUGu5jLjX94abzooi8TgU7aJCtKQaFvicviMrkZJE28U0Qr1GlrJAe0DKEvadgvy(jd1iO7i9mtKvSlXnrwBlXH3sFTylQmL8GfzKs83Mh9qz0sCbPYtktIt46sONxKNWGhSevQctRctIIkWxfIqfIzKY8ONnVlTAun4s0OgbDhPxIBIS2wIdVL(AXwuzk5bRKrkXFBE0dLrlXfKkpPmjUyxkCr2mBEfgDC2Dg5dw1ojUjYABjo8Gf9YuYtuKrkXFBE0dLrlXfKkpPmjUyxkCr2mBEfgDC2Dg5dw1ojUjYABjo8w670qUltjpaqgPe)T5rpugTexqQ8KYK4W7XbcYaVlpPAunYLRHmUzvGVkaivicvin67KX1(lDu7rlu)K928OhQcyWOcPrFNmJmmQxqD6Fn0g6dzVnp6HQagmQGyBixLmX2XwHL126fuN(xdVbzVnp6HQagmQaXkO(XENmdcDSdyLlDQaavb(QGyxkCr2mBEfgDC2Dg5dw1ovarvaasCtK12sCNy5iOx7ssHWLPKhaNmsj(BZJEOmAjUGu5jLjXH3JdeKbExEs1OAKlxdzU0eiOciQcrrIBIS2wI7elhb9AxskeUmL8m1KrkXFBE0dLrlXfKkpPmjo8ECGGmW7YtQgvJC5AiJBwf4RcPrFNmU2FPJApAH6NS3Mh9qvGVkeHkKg9DYmYWOEb1P)1qBOpK928OhQc8vbXUu4ISzCT)sh1E0c1pzKpyv7ubevbaOc8vHiubXUu4ISz28km64S7mYn4OkWxfIqfiwb1p27KzqOJDaRCPtIBIS2wI7elhb9AxskeUmL8a4jJuI)28OhkJwIlivEszsC494abzG3LNunQg5Y1qg3SkWxfaKkeHkKg9DY4A)LoQ9OfQFYEBE0dvbmyuH0OVtMrgg1lOo9VgAd9HS3Mh9qvadgvqSnKRsMy7yRWYAB9cQt)RH3GS3Mh9qvadgvGyfu)yVtMbHo2bSYLovaGQaFvqSlfUiBMnVcJoo7oJ8bRANkGOkaajUjYABjUGAiRgv78n4I0jtjpy9YiL4Vnp6HYOL4csLNuMehEpoqqg4D5jvJQrUCnK5stGGkGOkefjUjYABjUGAiRgv78n4I0jtjptIQmsj(BZJEOmAjUGu5jLjXH3JdeKbExEs1OAKlxdzCZQaFvin67KX1(lDu7rlu)K928OhQc8vHiuH0OVtMrgg1lOo9VgAd9HS3Mh9qvGVki2LcxKnJR9x6O2JwO(jJ8bRANkGOkaavGVkeHki2LcxKnZMxHrhNDNrUbhvb(QqeQaXkO(XENmdcDSdyLlDsCtK12sCb1qwnQ25BWfPtMsEMmrgPe)T5rpugTexqQ8KYK4eUUe65f5jm4blrLQW0QawIQkWxfIqfIzKY8ONnVlTAun4s0OgbDhPxIBIS2wIdVL(AXwuzk5zcwKrkXFBE0dLrlXfKkpPmjo8ECGGmW7YtQgvJC5AiZLMabvyAvikQaFvqSlfUiBMnVcJoo7oJ8bRANkmTkGvQaFvaqQqeQqA03jJR9x6O2JwO(j7T5rpufWGrfsJ(ozgzyuVG60)AOn0hYEBE0dvbmyubX2qUkzITJTclRT1lOo9VgEdYEBE0dvbmyubIvq9J9ozge6yhWkx6ubakXnrwBlXbVlpPAuTljfcxMsEMGvYiL4Vnp6HYOL4csLNuMehEpoqqg4D5jvJQrUCnK5stGGkmTkmrIBIS2wIdExEs1OAxskeUmL8mjkYiL4Vnp6HYOL4csLNuMehEpoqqg4D5jvJQrUCnK5stGGkmTkefvGVkaivqSlfUiBgx7V0rThTq9tg5dw1ovyAvaRubmyubaPcIDPWfzZS5vy0Xz3zKBWrvGVka3KX1(lDu7rlu)Kr(GvTtfaOkWxfsJ(ozCT)sh1E0c1pzVnp6HQaFvicvin67KzKHr9cQt)RH2qFi7T5rpufaOkWxfIqfiwb1p27KzqOJDaRCPtIBIS2wIdExEs1OAxskeUmL8mbaYiL4Vnp6HYOL4csLNuMepcviMrkZJE28U0Qr1GlrJAe0DKEjUjYABjo8w6RfBrLPmL4WdAC0ugPKNjYiL4MiRTL4dvd1GK)PQlXFBE0dLrltjpyrgPe)T5rpugTeFNL4UNsCtK12s8ygPmp6L4Xmk3L4IDPWfzZCCddBRrnc6ospJ8bRANkmTkaavGVkKg9DYCCddBRrnc6osp7T5rpuIhZi62gUeFExA1OAWLOrnc6osVmL8GvYiL4Vnp6HYOL4csLNuMeNW1LqpVipHbpyjQufqufaCaqf4RcZpzOgbDhPNzISIDvGVkq46ZGhSevQcicufaGe3ezTTe3icRVoxc5DktjprrgPe)T5rpugTexqQ8KYK4ZpzOgbDhPNzISIDvadgvWJdeKX1(lDuBoNXrtg3SkGbJkKg9DYmYWOEb1P)1qBOpK928OhQc8vbaPcZpzgzyuJ6VCuMjYk2vbmyubXUu4ISzgzyuVG60)A4niJ8bRANkGOkawO(PM8bRANkaqjUjYABjUhDxOgKJmktjpaqgPe)T5rpugTexqQ8KYK4ZpzOgbDhPNzISIDvadgvWJdeKX1(lDuBoNXrtg3SkGbJkKg9DYmYWOEb1P)1qBOpK928OhQc8vbaPcZpzgzyuJ6VCuMjYk2vbmyubXUu4ISzgzyuVG60)A4niJ8bRANkGOkawO(PM8bRANkaqjUjYABjU3jUtqOAuzk5bWjJuI)28OhkJwIlivEszsCpoqqgx7V0rTljVrtFg3Se3ezTTeNwO(PtpLGdIo8oLPKNPMmsj(BZJEOmAjUGu5jLjXNFYqnc6ospZezf7QagmQGhhiiJR9x6O2CoJJMmUzvadgvin67KzKHr9cQt)RH2qFi7T5rpuf4RcasfMFYmYWOg1F5OmtKvSRcyWOcIDPWfzZmYWOEb1P)1WBqg5dw1ovarvaSq9tn5dw1ovaGsCtK12sCRf3LeJQfgLktjpaEYiL4Vnp6HYOL4csLNuMe3ezf763FOUtfqeOkGfvadgvaqQaHRpdEWsuPkGiqvaaQaFvGW1LqpVipHbpyjQufqeOka4IQkaqjUjYABjUrewF9mh1Dzk5bRxgPe)T5rpugTexqQ8KYK4ZpzOgbDhPNzISIDvadgvWJdeKX1(lDuBoNXrtg3SkGbJkKg9DYmYWOEb1P)1qBOpK928OhQc8vbaPcZpzgzyuJ6VCuMjYk2vbmyubXUu4ISzgzyuVG60)A4niJ8bRANkGOkawO(PM8bRANkaqjUjYABjoyrUhDxOmL8mjQYiL4Vnp6HYOL4csLNuMe3JdeKX1(lDu7sYB00NXnRc8vbtKvSRF)H6ovaOkmrIBIS2wI7zO6fuNKsGGtMsEMmrgPe3ezTTeNZDDLFWjXFBE0dLrltjptWImsj(BZJEOmAjUGu5jLjXNFYqnc6ospZezf7QagmQGhhiiJR9x6O2CoJJMmUzvadgvin67KzKHr9cQt)RH2qFi7T5rpuf4RcasfMFYmYWOg1F5OmtKvSRcyWOcIDPWfzZmYWOEb1P)1WBqg5dw1ovarvaSq9tn5dw1ovaGsCtK12s85nRTLPKNjyLmsj(BZJEOmAjUjYABj(YLEKBiiXfKkpPmjoCtwSIWrFN6zQHYDg5GK78np6vb(QqeQqA03jJR9x6O2JwO(j7T5rpuf4RcrOceRG6h7DYmi0XoGvU0jXfJc61PrqF6K8mrMsEMefzKs83Mh9qz0sCtK12s8Ll9i3qqIlivEszsC4MSyfHJ(o1ZudL7mYbj35BE0Rc8vbaPcrOcPrFNmU2FPJApAH6NS3Mh9qvadgvin67KX1(lDu7rlu)K928OhQc8vbXUu4ISzCT)sh1E0c1pzKpyv7ubaQc8vbtKvSRF)H6ovarGQawK4Irb960iOpDsEMitjptaGmsj(BZJEOmAjUjYABjUWOuTjYABnTCPeNwUu32WL4IDPWfz7KPKNjaozKs83Mh9qz0sCbPYtktIBISID97pu3PcicufWIkWxfaKki2yVTozDH6NAq7QaFvqSlfUiBg8w670qUZiFWQ2PctRctIQkGbJki2LcxKndEl91wd1WlSrg5dw1ovyAvysuvb(QqeQqA03jdEWIE2BZJEOkGbJki2LcxKndEWIEg5dw1ovyAvysuvb(QqA03jdEWIE2BZJEOkaqvGVkeHkaVL(ARHA4f2illbcvJkXDjPePKNjsCtK12sCHrPAtK12AA5sjoTCPUTHlXT9A3tUzzk5zYutgPe)T5rpugTexqQ8KYK4MiRyx)(d1DQaIavbSOc8vb4T0xBnudVWgzzjqOAujUljLiL8mrIBIS2wIlmkvBIS2wtlxkXPLl1TnCjUTx7XrCPmL8mbWtgPe)T5rpugTexqQ8KYK4MiRyx)(d1DQaIavbSOc8vbaPcrOcWBPV2AOgEHnYYsGq1OQaFvaqQGyJ926K1fQFQbTRc8vbXUu4ISzWBPVtd5oJ8bRANkmTkmjQQagmQGyxkCr2m4T0xBnudVWgzKpyv7ubevHjrvf4RcrOcPrFNm4bl6zVnp6HQagmQGyxkCr2m4bl6zKpyv7ubevHjrvf4RcPrFNm4bl6zVnp6HQaavbakXDjPePKNjsCtK12sCHrPAtK12AA5sjoTCPUTHlXrFFsj02Ezk5zcwVmsj(BZJEOmAjUjYABjUWOuTjYABnTCPeNwUu32WL4OVpPeYuMs8zYf7GNLYiL8mrgPe3ezTTeNyL7A4nOe)T5rpugTmLPexSlfUiBNmsjptKrkXFBE0dLrlXfKkpPmjUyxkCr2mU2FPJApAH6NmYhSQDQW0Qaaub(QqA03jJR9x6O2JwO(j7T5rpufWGrfIqfsJ(ozCT)sh1E0c1pzVnp6HsCtK12sCJmmQxqD6Fn8guMsEWImsj(BZJEOmAjUGu5jLjXbKki2LcxKnZidJ6fuN(xdVbzKpyv7ubevbaOcyWOcWBPVgHUq9tgSCMh9ABtOkaqvGVkaivqSlfUiBMnVcJoo7oJCdoQc8vbaPcW7XbcYaVlpPAunYLRHmxAceubebQcrrfWGrfiC9vbebQcyLkaqvadgvqSlfUiBMnVcJoo7oJ8bRANkaqvGVkeHkqScQFS3jZGqh7aw5sNe3ezTTeNR9x6O2JwO(PmL8GvYiL4Vnp6HYOL4csLNuMeNyfu)yVtMbHo2bSYLovGVkaivWezf763FOUtfqeOkGfvadgvGyfu)yVtMbHow1QaIQWeaOcauIBIS2wIZ1(lDu7rlu)uMsEIImsj(BZJEOmAjUGu5jLjXJqfiwb1p27KzqOJDaRCPtf4RcIDPWfzZ4A)LoQ9OfQFYiFWQ2Pc8vbaPceU(Glb9m4niTUl1ITOSpvWvZZhQc8vbaPcrOcECGGmOrqqNeRDGlzWYABg3SkWxfIqfsJ(ozCT)sh1ZMizVnp6HQagmQqA03jJR9x6OE2ej7T5rpufaOkGbJkeHkq46dUe0ZG3G06Uul2IY(ubxnpFOkaqvadgvicvin67KX1(lDu7rlu)K928OhQc8vHiubIvq9J9ozge6yhWkx6K4MiRTL4qJGGojw7axYGL12YuYdaKrkXFBE0dLrlXfKkpPmjoXkO(XENmdcDSdyLlDQaFvaqQGjYk21V)qDNkGiqvalQagmQaXkO(XENmdcDSQvbevHjaqfaOe3ezTTehAee0jXAh4sgSS2wMsEaCYiL4Vnp6HYOL4csLNuMe3ezf763FOUtfaQctub(QaGuH5NmBEfAu)LJYmrwXUkGbJki2gYvjtSDSvyzTTEb1P)1WBq2BZJEOkaqjUjYABjox7V0rT5CghnLPKNPMmsj(BZJEOmAjUjYABjox7V0rT5CghnL4csLNuMe3ezf763FOUtfqeOkGfvGVkaVhhiid8U8KQr1ixUgYCPjqqfMwfWIexmkOxNgb9PtYZezk5bWtgPe)T5rpugTexqQ8KYK4PrqFYYA46C1W6QaIQWKOiXnrwBlXD(Mab61P)1CnYLK(JYuYdwVmsj(BZJEOmAjUGu5jLjXnrwXU(9hQ7ubevbSiXnrwBlXnVDOAlRT10AWtMsEMevzKs83Mh9qz0sCbPYtktIBISID97pu3PciQcyrIBIS2wI7qAKHQr1dLlLPKNjtKrkXFBE0dLrlXfKkpPmjo8ECGGmW7YtQgvJC5AiZLMabvarGQquub(QaGubaPcrOcPrFNmU2FPJApAH6NS3Mh9qvadgvin67KzKHr9cQt)RH2qFi7T5rpufWGrfeBd5QKj2o2kSS2wVG60)A4ni7T5rpufaOkGbJkKg9DY4A)LoQ9OfQFYEBE0dvb(QqeQqA03jZidJ6fuN(xdTH(q2BZJEOkWxfGBY4A)LoQ9OfQFYiFWQ2Pcauf4RcMiRyx)(d1DQaqvyIe3ezTTe3MxHrhNDxMsEMGfzKs83Mh9qz0sCtK12sCBEfgDC2DjUGu5jLjXH3JdeKbExEs1OAKlxdzU0eiOcicufIIkWxfmrwXU(9hQ7ubebQcyrf4RcrOcWBPV2AOgEHnYYsGq1OsCXOGEDAe0NojptKPKNjyLmsj(BZJEOmAjUGu5jLjXjCDj0ZlYtyWdwIkvHPvHjrrIBIS2wI74gg2wJAe0DKEzk5zsuKrkXFBE0dLrlXnrwBlXDlhvtUnFIexqQ8KYK4PrqFYYA46C1ZIuJvaqfMwfaGkWxfalu)ut(GvTtfqufaGexmkOxNgb9PtYZezk5zcaKrkXFBE0dLrlXfKkpPmjEeQW8tgQ)YrzMiRyxIBIS2wItSYDn8guMsEMa4KrkXFBE0dLrlXfKkpPmjUjYk21V)qDNkGiqvalQaFvicvWJdeKbncc6KyTdCjdwwBZ4Mvb(QqeQGyxkCr2mOrqqNeRDGlzWYABg5gCuf4RcIDPWfzZiw5UgEdYiFWQ2PctRcyLkmLRcOcOe3ezTTe3zcsbwIYO6ztKYuMsC03NucTTxgPKNjYiL4Vnp6HYOL4csLNuMe3JdeK54GW3A4UdmYnrkXnrwBlX)Cb)qjKPKhSiJuI)28OhkJwIlivEszs8iuHygPmp6zZ7sRgvdUenQrq3r6L4MiRTL4FUGFOeYuYdwjJuI)28OhkJwIBIS2wI7elhb9AxskeUexqQ8KYK4IDPWfzZS5vy0Xz3zKpyv7ubevbaOc8vb494abzG3LNunQg5Y1qMlnbcQaIavHjsCXOGEDAe0NojptKPKNOiJuI)28OhkJwIBIS2wIlOgYQr1oFdUiDsCbPYtktIl2LcxKnZMxHrhNDNr(GvTtfqufaGkWxfG3JdeKbExEs1OAKlxdzU0eiOcicufMiXfJc61PrqF6K8mrMsEaGmsj(BZJEOmAjUjYABjo4D5jvJQDjPq4sCbPYtktIl2LcxKnZMxHrhNDNr(GvTtfqufaGkWxfG3JdeKbExEs1OAKlxdzU0eiOctRctK4Irb960iOpDsEMitjpaozKs83Mh9qz0sCtK12sCNy5iOx7ssHWL4csLNuMehqQGyxkCr2mBEfgDC2Dg5dw1ovarvaaQaFvaEpoqqg4D5jvJQrUCnKXnRcyWOcW7XbcYaVlpPAunYLRHmxAceubevHOOcauf4Rcasfalu)ut(GvTtfMwfe7sHlYMbVL(ARHA4f2iJ8bRANkeNkmjQQagmQayH6NAYhSQDQaIQGyxkCr2mBEfgDC2Dg5dw1ovaGsCXOGEDAe0NojptKPKNPMmsj(BZJEOmAjUjYABjUGAiRgv78n4I0jXfKkpPmjoGubXUu4ISz28km64S7mYhSQDQaIQaaub(Qa8ECGGmW7YtQgvJC5AiJBwfWGrfG3JdeKbExEs1OAKlxdzU0eiOciQcrrfaOkWxfaKkawO(PM8bRANkmTki2LcxKndEl91wd1WlSrg5dw1oviovysuvbmyubWc1p1Kpyv7ubevbXUu4ISz28km64S7mYhSQDQaaL4Irb960iOpDsEMitjpaEYiL4Vnp6HYOL4MiRTL4G3LNunQ2LKcHlXfKkpPmjo8ECGGmW7YtQgvJC5AiZLMabvyAvaRub(QGyxkCr2mBEfgDC2Dg5dw1ovyAvaRubmyub494abzG3LNunQg5Y1qMlnbcQW0QWejUyuqVonc6tNKNjYuMsCBV2JJ4szKsEMiJuI)28OhkJwIlivEszsCcxxc98I8eg8GLOsvyAvaqQWKOQcXPcWBPVgHUq9tgiYLRHhQtJG(0Pct5QawPcauf4RcWBPVgHUq9tgiYLRHhQtJG(0PctRcaovGVkeHkeZiL5rpBExA1OAWLOrnc6osVe3ezTTe)Zf8dLqMsEWImsj(BZJEOmAjUGu5jLjXjCDj0ZlYtyWdwIkvHPvbSaavGVkaVL(Ae6c1pzGixUgEOonc6tNkGOkaavGVkeHkeZiL5rpBExA1OAWLOrnc6osVe3ezTTe)Zf8dLqMsEWkzKs83Mh9qz0sCbPYtktIhHkaVL(Ae6c1pzGixUgEOonc6tNkWxfIqfIzKY8ONnVlTAun4s0OgbDhPxIBIS2wI)5c(HsitjprrgPe3ezTTe3jwoc61UKuiCj(BZJEOmAzk5baYiL4MiRTL4cQHSAuTZ3GlsNe)T5rpugTmL8a4KrkXFBE0dLrlXfKkpPmjEeQqmJuMh9S5DPvJQbxIg1iO7i9sCtK12s8pxWpuczktjUTx7EYnlJuYZezKs83Mh9qz0sCbPYtktIdVL(Ae6c1pzGixUgEOonc6tNkaufmrwXU(9hQ7ubmyubIvq9J9ozge6yhWkx6ub(QaXkO(XENmdcDmYhSQDQW0avHjtK4MiRTL4WBPV2AOgEHnktjpyrgPe)T5rpugTexqQ8KYK4WBPVgHUq9tgiYLRHhQtJG(0PcicufaGe3ezTTehEl91wd1WlSrzk5bRKrkXFBE0dLrlXfKkpPmjo8w6RrOlu)KbIC5A4H60iOpDQaqvWezf763FOUtfWGrfiwb1p27KzqOJDaRCPtf4RceRG6h7DYmi0XiFWQ2PctdufMmrIBIS2wIdpyrVmL8efzKs83Mh9qz0sCbPYtktIdVL(Ae6c1pzGixUgEOonc6tNkGiqvaasCtK12sC4bl6LPKhaiJuI)28OhkJwIlivEszsC4T0xJqxO(jde5Y1Wd1PrqF6ubGQGjYk21V)qDNkGbJkqScQFS3jZGqh7aw5sNkWxfiwb1p27KzqOJr(GvTtfMgOkmzIe3ezTTehEl9DAi3LPKhaNmsj(BZJEOmAjUGu5jLjXH3sFncDH6NmqKlxdpuNgb9PtfqeOkaajUjYABjo8w670qUltjptnzKs83Mh9qz0sCbPYtktIhHkeZiL5rpBExA1OAWLOrnc6osVkWxfiCDj0ZlYtyWdwIkvHPvbSevjUjYABj(Nl4hkHmL8a4jJuI)28OhkJwIBIS2wIdExEs1OAxskeUexqQ8KYK4W7XbcYaVlpPAunYLRHmxAceuHPvHjsCXOGEDAe0NojptKPKhSEzKs83Mh9qz0sCbPYtktIhHkeZiL5rpBExA1OAWLOrnc6osVe3ezTTe)Zf8dLqMYuMs8yN4QTL8GLOILOojQtWkjosJ0vJ6K4yngMxsEOkm1ubtK12QaTCPJPWwIptwWIEj(uOcynB)LoQca(Cl9vHPuDH6NkSNcvaRRixVtuHjrHxvalrflrvHTc7PqfWA9Tg9oSokSNcvyQufM6q4HQaG)QHQWuAY)u1zkSNcvyQufM6q4HQaw7g7T1PJPWwHTjYABhBMCXo4zzCaJNyL7A4nOcBvqH9uOct1a2fC5HQWJDYOkK1WvH0)QGjYLOcLtfSywrnp6zkSnrwB7aounuds(NQUc7PqfMYAKY8O3PW2ezTTloGXhZiL5rpVTnCGZ7sRgvdUenQrq3r65nMr5oqXUu4ISzoUHHT1OgbDhPNr(GvTBAaWpn67K54gg2wJAe0DKE2BZJEOc7PqfMYyIYOoEvbSg5hC8QcwdvHn9prfwub0PW2ezTTloGXBeH1xNlH8o5Tabs46sONxKNWGhSevIiGda8NFYqnc6ospZezf78jC9zWdwIkreiauyBIS22fhW49O7c1GCKrElqGZpzOgbDhPNzISIDmy84abzCT)sh1MZzC0KXnJbtA03jZidJ6fuN(xdTH(q2BZJEiFan)KzKHrnQ)YrzMiRyhdgXUu4ISzgzyuVG60)A4niJ8bRAhIGfQFQjFWQ2bqf2MiRTDXbmEVtCNGq1O8wGaNFYqnc6ospZezf7yW4XbcY4A)LoQnNZ4OjJBgdM0OVtMrgg1lOo9VgAd9HS3Mh9q(aA(jZidJAu)LJYmrwXogmIDPWfzZmYWOEb1P)1WBqg5dw1oeblu)ut(GvTdGkSnrwB7Idy80c1pD6PeCq0H3jVfiqpoqqgx7V0rTljVrtFg3ScBtK12U4agV1I7sIr1cJs5Tabo)KHAe0DKEMjYk2XGXJdeKX1(lDuBoNXrtg3mgmPrFNmJmmQxqD6Fn0g6dzVnp6H8b08tMrgg1O(lhLzISIDmye7sHlYMzKHr9cQt)RH3GmYhSQDicwO(PM8bRAhavyBIS22fhW4nIW6RN5OUZBbc0ezf763FOUdrGybdgar46ZGhSevIiqaWNW1LqpVipHbpyjQerGaUOcqf2MiRTDXbmEWICp6UqElqGZpzOgbDhPNzISIDmy84abzCT)sh1MZzC0KXnJbtA03jZidJ6fuN(xdTH(q2BZJEiFan)KzKHrnQ)YrzMiRyhdgXUu4ISzgzyuVG60)A4niJ8bRAhIGfQFQjFWQ2bqf2MiRTDXbmEpdvVG6KuceC8wGa94abzCT)sh1UK8gn9zCZ8nrwXU(9hQ7aorHTjYABxCaJNZDDLFWPW2ezTTloGXpVzTnVfiW5NmuJGUJ0ZmrwXogmECGGmU2FPJAZ5moAY4MXGjn67KzKHr9cQt)RH2qFi7T5rpKpGMFYmYWOg1F5OmtKvSJbJyxkCr2mJmmQxqD6Fn8gKr(GvTdrWc1p1Kpyv7aOc7Pqfa8BvNw1vJQctzlch9DQca(snuURcLtfmvyMulPYrf2MiRTDXbm(Ll9i3qGxXOGEDAe0NoGt4Tabc3KfRiC03PEMAOCNroi5oFZJE(rKg9DY4A)LoQ9OfQFYEBE0d5hbXkO(XENmdcDSdyLlDkSnrwB7Idy8lx6rUHaVIrb960iOpDaNWBbceUjlwr4OVt9m1q5oJCqYD(Mh98buePrFNmU2FPJApAH6NS3Mh9qmysJ(ozCT)sh1E0c1pzVnp6H8f7sHlYMX1(lDu7rlu)Kr(GvTdG8nrwXU(9hQ7qeiwuyBIS22fhW4fgLQnrwBRPLl5TTHduSlfUiBNcBtK12U4agVWOuTjYABnTCjVTnCG2ET7j3mVUKuIe4eElqGMiRyx)(d1Dicel8bKyJ926K1fQFQbTZxSlfUiBg8w670qUZiFWQ2n9KOIbJyxkCr2m4T0xBnudVWgzKpyv7MEsu5hrA03jdEWIE2BZJEigmIDPWfzZGhSONr(GvTB6jrLFA03jdEWIE2BZJEia5hb8w6RTgQHxyJSSeiunQcBtK12U4agVWOuTjYABnTCjVTnCG2EThhXL86ssjsGt4TabAISID97pu3HiqSWhEl91wd1WlSrwwceQgvHTjYABxCaJxyuQ2ezTTMwUK32goq03NucTTNxxskrcCcVfiqtKvSRF)H6oebIf(akc4T0xBnudVWgzzjqOAu(asSXEBDY6c1p1G25l2LcxKndEl9DAi3zKpyv7MEsuXGrSlfUiBg8w6RTgQHxyJmYhSQDiojQ8Jin67Kbpyrp7T5rpedgXUu4ISzWdw0ZiFWQ2H4KOYpn67Kbpyrp7T5rpeGauHTjYABxCaJxyuQ2ezTTMwUK32goq03Nucf2QGc7PyQVt1Qa(tUzf2MiRTDmBV29KBgi8w6RTgQHxyJ8wGaH3sFncDH6NmqKlxdpuNgb9PdOjYk21V)qDhgmeRG6h7DYmi0XoGvU0XNyfu)yVtMbHog5dw1UPbozIcBtK12oMTx7EYnhhW4H3sFT1qn8cBK3cei8w6RrOlu)KbIC5A4H60iOpDiceakSnrwB7y2ET7j3CCaJhEWIEElqGWBPVgHUq9tgiYLRHhQtJG(0b0ezf763FOUddgIvq9J9ozge6yhWkx64tScQFS3jZGqhJ8bRA30aNmrHTjYABhZ2RDp5MJdy8Wdw0ZBbceEl91i0fQFYarUCn8qDAe0Noebcaf2MiRTDmBV29KBooGXdVL(onK78wGaH3sFncDH6NmqKlxdpuNgb9PdOjYk21V)qDhgmeRG6h7DYmi0XoGvU0XNyfu)yVtMbHog5dw1UPbozIcBtK12oMTx7EYnhhW4H3sFNgYDElqGWBPVgHUq9tgiYLRHhQtJG(0HiqaOW2ezTTJz71UNCZXbm(pxWpucElqGreZiL5rpBExA1OAWLOrnc6ospFcxxc98I8eg8GLOYPXsuvyBIS22XS9A3tU54agp4D5jvJQDjPq48kgf0RtJG(0bCcVfiq494abzG3LNunQg5Y1qMlnbctprHTjYABhZ2RDp5MJdy8FUGFOe8wGaJiMrkZJE28U0Qr1GlrJAe0DKEf2QGc7PqfM67uTkenhXLkSnrwB7y2EThhXLa)Cb)qj4Tabs46sONxKNWGhSevonGMe14G3sFncDH6NmqKlxdpuNgb9PBkhRaiF4T0xJqxO(jde5Y1Wd1PrqF6MgWXpIygPmp6zZ7sRgvdUenQrq3r6vyBIS22XS9ApoIlJdy8FUGFOe8wGajCDj0ZlYtyWdwIkNglaGp8w6RrOlu)KbIC5A4H60iOpDica(reZiL5rpBExA1OAWLOrnc6osVcBtK12oMTx7XrCzCaJ)Zf8dLG3ceyeWBPVgHUq9tgiYLRHhQtJG(0XpIygPmp6zZ7sRgvdUenQrq3r6vyBIS22XS9ApoIlJdy8oXYrqV2LKcHRW2ezTTJz71ECexghW4fudz1OANVbxKof2MiRTDmBV2JJ4Y4ag)Nl4hkbVfiWiIzKY8ONnVlTAun4s0OgbDhPxHTc7PqfMs((KsOct9DQwHTjYABhd99jLqB7b(5c(HsWBbc0JdeK54GW3A4UdmYnrQW2ezTTJH((KsOT9Xbm(pxWpucElqGreZiL5rpBExA1OAWLOrnc6osVcBtK12og67tkH22hhW4DILJGETljfcNxXOGEDAe0NoGt4Tabk2LcxKnZMxHrhNDNr(GvTdraWhEpoqqg4D5jvJQrUCnK5stGaIaNOW2ezTTJH((KsOT9XbmEb1qwnQ25BWfPJxXOGEDAe0NoGt4Tabk2LcxKnZMxHrhNDNr(GvTdraWhEpoqqg4D5jvJQrUCnK5stGaIaNOW2ezTTJH((KsOT9XbmEW7YtQgv7ssHW5vmkOxNgb9Pd4eElqGIDPWfzZS5vy0Xz3zKpyv7qea8H3JdeKbExEs1OAKlxdzU0eim9ef2MiRTDm03NucTTpoGX7elhb9AxskeoVIrb960iOpDaNWBbceqIDPWfzZS5vy0Xz3zKpyv7qea8H3JdeKbExEs1OAKlxdzCZyWaVhhiid8U8KQr1ixUgYCPjqaXOaq(acSq9tn5dw1UPf7sHlYMbVL(ARHA4f2iJ8bRAxCtIkgmGfQFQjFWQ2HOyxkCr2mBEfgDC2Dg5dw1oaQW2ezTTJH((KsOT9XbmEb1qwnQ25BWfPJxXOGEDAe0NoGt4TabciXUu4ISz28km64S7mYhSQDica(W7XbcYaVlpPAunYLRHmUzmyG3JdeKbExEs1OAKlxdzU0eiGyuaiFabwO(PM8bRA30IDPWfzZG3sFT1qn8cBKr(GvTlUjrfdgWc1p1Kpyv7quSlfUiBMnVcJoo7oJ8bRAhavyBIS22XqFFsj02(4agp4D5jvJQDjPq48kgf0RtJG(0bCcVfiq494abzG3LNunQg5Y1qMlnbctJv8f7sHlYMzZRWOJZUZiFWQ2nnwHbd8ECGGmW7YtQgvJC5AiZLMaHPNOWwfuypfQaw7Uu4ISDkSnrwB7yIDPWfz7aAKHr9cQt)RH3G8wGaf7sHlYMX1(lDu7rlu)Kr(GvTBAaWpn67KX1(lDu7rlu)K928OhIbtePrFNmU2FPJApAH6NS3Mh9qf2MiRTDmXUu4ISDXbmEU2FPJApAH6N8wGabKyxkCr2mJmmQxqD6Fn8gKr(GvTdraGbd8w6RrOlu)KblN5rV22ecq(asSlfUiBMnVcJoo7oJCdoYhqW7XbcYaVlpPAunYLRHmxAceqeyuWGHW1hrGyfaXGrSlfUiBMnVcJoo7oJ8bRAha5hbXkO(XENmdcDSdyLlDkSnrwB7yIDPWfz7Idy8CT)sh1E0c1p5TabsScQFS3jZGqh7aw5shFazISID97pu3HiqSGbdXkO(XENmdcDSQrCcaaOcBtK12oMyxkCr2U4agp0iiOtI1oWLmyzTnVfiWiiwb1p27KzqOJDaRCPJVyxkCr2mU2FPJApAH6NmYhSQD8beHRp4sqpdEdsR7sTylk7tfC188H8bueECGGmOrqqNeRDGlzWYABg3m)isJ(ozCT)sh1ZMizVnp6HyWKg9DY4A)LoQNnrYEBE0dbigmrq46dUe0ZG3G06Uul2IY(ubxnpFiaXGjI0OVtgx7V0rThTq9t2BZJEi)iiwb1p27KzqOJDaRCPtHTjYABhtSlfUiBxCaJhAee0jXAh4sgSS2M3ceiXkO(XENmdcDSdyLlD8bKjYk21V)qDhIaXcgmeRG6h7DYmi0XQgXjaaGkSnrwB7yIDPWfz7Idy8CT)sh1MZzC0K3ceOjYk21V)qDhWj8b08tMnVcnQ)YrzMiRyhdgX2qUkzITJTclRT1lOo9VgEdYEBE0dbOcBtK12oMyxkCr2U4agpx7V0rT5Cghn5vmkOxNgb9Pd4eElqGMiRyx)(d1Dicel8H3JdeKbExEs1OAKlxdzU0eimnwuyBIS22Xe7sHlY2fhW4D(Mab61P)1CnYLK(J8wGatJG(KL1W15QH1rCsuuyBIS22Xe7sHlY2fhW4nVDOAlRT10AWJ3ceOjYk21V)qDhIyrHTjYABhtSlfUiBxCaJ3H0idvJQhkxYBbc0ezf763FOUdrSOW2ezTTJj2LcxKTloGXBZRWOJZUZBbceEpoqqg4D5jvJQrUCnK5stGaIaJcFabOisJ(ozCT)sh1E0c1pzVnp6HyWKg9DYmYWOEb1P)1qBOpK928OhIbJyBixLmX2XwHL126fuN(xdVbzVnp6HaedM0OVtgx7V0rThTq9t2BZJEi)isJ(ozgzyuVG60)AOn0hYEBE0d5d3KX1(lDu7rlu)Kr(GvTdG8nrwXU(9hQ7aorHTjYABhtSlfUiBxCaJ3MxHrhNDNxXOGEDAe0NoGt4TabcVhhiid8U8KQr1ixUgYCPjqarGrHVjYk21V)qDhIaXc)iG3sFT1qn8cBKLLaHQrvyBIS22Xe7sHlY2fhW4DCddBRrnc6ospVfiqcxxc98I8eg8GLOYPNeff2MiRTDmXUu4ISDXbmE3Yr1KBZNWRyuqVonc6thWj8wGatJG(KL1W15QNfPgRaW0aGpyH6NAYhSQDicaf2MiRTDmXUu4ISDXbmEIvURH3G8wGaJy(jd1F5OmtKvSRW2ezTTJj2LcxKTloGX7mbPalrzu9SjsElqGMiRyx)(d1Dicel8JWJdeKbncc6KyTdCjdwwBZ4M5hHyxkCr2mOrqqNeRDGlzWYABg5gCKVyxkCr2mIvURH3GmYhSQDtJvt5OcOcBvqH9uOctjFFIrvHPmBAzTTcBtK12og67tkbq4T0xl2IYBbc0JdeK54GW3A4UdmYnrYpIygPmp6zZ7sRgvdUenQrq3r6XGz(jd1iO7i9mtKvSRW2ezTTJH((KsehW4H3sFTylkVfiqcxxc98I8eg8GLOYPNef(reZiL5rpBExA1OAWLOrnc6osVcBtK12og67tkrCaJhEWIEElqGIDPWfzZS5vy0Xz3zKpyv7uyBIS22XqFFsjIdy8WBPVtd5oVfiqXUu4ISz28km64S7mYhSQDkSnrwB7yOVpPeXbmENy5iOx7ssHW5TabcVhhiid8U8KQr1ixUgY4M5dOisJ(ozCT)sh1E0c1pzVnp6HyWKg9DYmYWOEb1P)1qBOpK928OhIbJyBixLmX2XwHL126fuN(xdVbzVnp6HyWqScQFS3jZGqh7aw5sha5l2LcxKnZMxHrhNDNr(GvTdraOW2ezTTJH((KsehW4DILJGETljfcN3cei8ECGGmW7YtQgvJC5AiZLMabeJIcBtK12og67tkrCaJ3jwoc61UKuiCElqGW7XbcYaVlpPAunYLRHmUz(PrFNmU2FPJApAH6NS3Mh9q(rKg9DYmYWOEb1P)1qBOpK928OhYxSlfUiBgx7V0rThTq9tg5dw1oeba)ie7sHlYMzZRWOJZUZi3GJ8JGyfu)yVtMbHo2bSYLof2MiRTDm03NuI4agVGAiRgv78n4I0XBbceEpoqqg4D5jvJQrUCnKXnZhqrKg9DY4A)LoQ9OfQFYEBE0dXGjn67KzKHr9cQt)RH2qFi7T5rpedgX2qUkzITJTclRT1lOo9VgEdYEBE0dXGHyfu)yVtMbHo2bSYLoaYxSlfUiBMnVcJoo7oJ8bRAhIaqHTjYABhd99jLioGXlOgYQr1oFdUiD8wGaH3JdeKbExEs1OAKlxdzU0eiGyuuyBIS22XqFFsjIdy8cQHSAuTZ3GlshVfiq494abzG3LNunQg5Y1qg3m)0OVtgx7V0rThTq9t2BZJEi)isJ(ozgzyuVG60)AOn0hYEBE0d5l2LcxKnJR9x6O2JwO(jJ8bRAhIaGFeIDPWfzZS5vy0Xz3zKBWr(rqScQFS3jZGqh7aw5sNcBtK12og67tkrCaJhEl91ITO8wGajCDj0ZlYtyWdwIkNglrLFeXmszE0ZM3LwnQgCjAuJGUJ0RW2ezTTJH((KsehW4bVlpPAuTljfcN3cei8ECGGmW7YtQgvJC5AiZLMaHPJcFXUu4ISz28km64S7mYhSQDtJv8buePrFNmU2FPJApAH6NS3Mh9qmysJ(ozgzyuVG60)AOn0hYEBE0dXGrSnKRsMy7yRWYAB9cQt)RH3GS3Mh9qmyiwb1p27KzqOJDaRCPdGkSnrwB7yOVpPeXbmEW7YtQgv7ssHW5TabcVhhiid8U8KQr1ixUgYCPjqy6jkSnrwB7yOVpPeXbmEW7YtQgv7ssHW5TabcVhhiid8U8KQr1ixUgYCPjqy6OWhqIDPWfzZ4A)LoQ9OfQFYiFWQ2nnwHbdGe7sHlYMzZRWOJZUZi3GJ8HBY4A)LoQ9OfQFYiFWQ2bq(PrFNmU2FPJApAH6NS3Mh9q(rKg9DYmYWOEb1P)1qBOpK928Ohcq(rqScQFS3jZGqh7aw5sNcBtK12og67tkrCaJhEl91ITO8wGaJiMrkZJE28U0Qr1GlrJAe0DKEjUXL(lrIJxdCulRTXAjgyktzkLa]] )

end
