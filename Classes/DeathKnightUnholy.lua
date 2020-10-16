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
            
            usable = function () return pet.alive, "requires an undead pet" end,

            handler = function ()
                dismissPet( "ghoul" )
                gain( 0.25 * health.max, "health" )
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


    spec:RegisterPack( "Unholy", 20201015.1, [[dGuOAbqiHOhbaztcvJsO4ucLELqQzrGUfaq7Is)sjYWaihJQWYaqpdHW0aOUgcPTba6BaqzCcjQZHqeRtib18Ok5EiyFufDqaaTqLOEOqIyIaqfxeaQ0gbGQoPqIKvIq9seIe3uibStQs9tHePgQqc0sba4PGAQcHRkKGSveIK2lQ(lkdwWHjTyL0JHAYuCzvBwP(miJgqNwQvJquVMaMnvUnH2TKFlA4uvhxiHwoKNJ00vCDeTDLW3jOXJqK68az9cjnFGA)en3dEeCyJoN7nabeabKhaYdIAbercrquIaaJdpG8ph2xXcOqNdxQ45WrHkGPdeh2xb5s1WJGdttse(CyGZ4tJcV0sq9aKC1ItXLOTiPtNolms3Zs0weVehELSDtuQIVYHn6CU3aeqaeqEaipikhM6Fm3BasuaYHb2gZl(kh2CkMddGKHOqfW0bsgaW56augisPAiGJKyaKmeLgp56rYGhawqzaGacGassSKyaKmeLaulOtJcljgajdaGYaaqJ5gzikqxgzaap6pQ3kjgajdaGYquswloAUrggfb9H1BzaNLPNolQmmPmGoePtrYaoltpDwuRKyaKmaakdaauCRo6sa4ZAKHCldrbtHhjdJWRcqTsIbqYaaOmaNKozaaWv)Jeugaa6Ny1bYNEzyeEvaQLd7A6q5rWHpL(cFkpcU3EWJGd)sxD3WxMdJr9CuRCyezD70INnjZdzWtzacBKH4YaISAmZpfEKm4LmayaXHv80zXHfVyIaXYnZrIBdZGUks5d3BaYJGd)sxD3WxMdJr9CuRCyZ1bitldZCScYonwGUGKbWGLb)pw1pXmiGjPZQ4PxCziUmO4PxC2Rl2NkdeKbp4WkE6S4WRUmnSCZgGN96IG4d3BIGhbh(LU6UHVmhgJ65Ow5WXid4mDMuyzv)eRoq(0Brxu7IkdEjdaqziUmGZ0zsHLvrIGy5MnapZC1yrxu7IkdEkd4mDMuyzXzzErVH5693jcFl6IAxuziwzamyzaNPZKclRIebXYnBaEM5QXIUO2fvg8sgaihwXtNfhgIurMwlwUzAupkhG8H7nG5rWHFPRUB4lZHXOEoQvo8k5EBrhlG7ukBNi8TK(YayWYWk5EBrhlG7ukBNi8z4KSMJS0rXcidEjdE4bhwXtNfhEaEgzTMKLHTte(8H7nr5rWHFPRUB4lZHXOEoQvoCKYG56aKPLHzowbzNglqxqCyfpDwC4DIjP3W0OEupNTEvKpCVbG8i4WV0v3n8L5Wyuph1kh2KJfNf(1G05g22PINTsIkl6IAxuzGGmaioSINolomol8RbPZnSTtfpF4EdGXJGd)sxD3WxMdJr9CuRC4iLbZ1bitldZCScYonwGUG4WkE6S4W(KOEdQli2QtPdF4EhL5rWHFPRUB4lZHXOEoQvo8OUxJvrIGy5MnapZOI1n2x6Q7gziUmCk9f(2fnTZILBM)r7JNolRyxjsgIldRK7TLSaMoqm6GEbnaTK(YayWYWP0x4Bx00olwUz(hTpE6SSIDLiziUm4)XQ(jMbbmjDwfp9IldGbldJ6EnwfjcILB2a8mJkw3yFPRUBKH4YG)hR6NygeWK0zv80lUmexgWz6mPWYQirqSCZgGNzUASOlQDrLbpLbaiGKbWGLHrDVgRIebXYnBaEMrfRBSV0v3nYqCzW)JvrIGyqatsNvXtV4CyfpDwCyHjYzw8UyOtZsl85d3BIeEeC4x6Q7g(YCymQNJALdhPmyUoazAzyMJvq2PXc0fKmexgwj3BlzbmDGy0b9cAaAj9LH4YqKYWP0x4Bx00olwUz(hTpE6SSIDLiziUmePmmQ71yvKiiwUzdWZmQyDJ9LU6Urgadwggfb9XoT4ztYm9LbVKbCMotkSSQFIvhiF6TOlQDr5WkE6S4WctKZS4DXqNMLw4ZhU3EaiEeC4x6Q7g(YCymQNJALdhPmyUoazAzyMJvq2PXc0fehwXtNfhg1((UZ6Ir9v85d3Bp8Ghbh(LU6UHVmhgJ65Ow5WrkdRK7T1VDofXYnBJs6yj9LH4YqKYWk5EBxrxhGSCZODzqkusvlPVmexgIrggfb9Xc8QBaY8XJm4jbzikdizamyzyue0hlWRUbiZhpYGxeKbacizamyzy3qahg6IAxuzWlzaWevgILdR4PZIdJU63feB7uXt5dF4WMVvs3WJG7Th8i4WkE6S4WIDzyB0Fuph(LU6UHVmF4EdqEeC4x6Q7g(YC40Ndt)WHv80zXHxOOwxDNdVqDKNdJZ0zsHLLskkMfdsrqji3TOlQDrLbVKbIkdXLHrDVglLuumlgKIGsqUBFPRUB4WlueRuXZH9Z01feBNigKIGsqUZhU3ebpco8lD1DdFzomg1ZrTYHrKvJz(PWJSMVBCpYGNYaaKOYqCzigzW)Jfsrqji3TkE6fxgadwgIugg19ASusrXSyqkckb5U9LU6UrgIvgIldiY6wZ3nUhzWtcYar5WkE6S4WkcR1ztIqVg(W9gW8i4WV0v3n8L5Wyuph1kh2)Jfsrqji3TkE6fxgadwgIugg19ASusrXSyqkckb5U9LU6UHdR4PZIdV6Y0W2Kiq8H7nr5rWHFPRUB4lZHXOEoQvo8k5EBjlGPdetPuL0nwsFzamyzW)Jfsrqji3TkE6fxgadwgIrgg19ASkseel3Sb4zgvSUX(sxD3idXLb)pw1pXmiGjPZQ4PxCziwoSINolo86r0JeOli(W9gaYJGd)sxD3WxMdJr9CuRC4yKHvY92swathigDqVGgGwsFziUmSsU329PZrIneWXIUO2fvg8IGmquziwzamyzqXtV4SxxSpvg8KGmaqziUmeJmSsU3wYcy6aXOd6f0a0s6ldGbldRK7TDF6CKydbCSOlQDrLbViidevgILdR4PZId7AiGdLrKjnqIVg(W9gaJhbh(LU6UHVmhgJ65Ow5WXid(FSqkckb5UvXtV4YqCzyu3RXsjffZIbPiOeK72x6Q7gziwzamyzW)Jv9tmdcys6SkE6fNdR4PZIdRf(0bPogwDo(W9okZJGd)sxD3WxMdJr9CuRCyfp9IZEDX(uzWtcYaaLbWGLHyKbezDR57g3Jm4jbzGOYqCzarwnM5NcpYA(UX9idEsqgaGasgILdR4PZIdRiSwN5t6ONpCVjs4rWHFPRUB4lZHXOEoQvoCmYG)hlKIGsqUBv80lUmexgg19ASusrXSyqkckb5U9LU6UrgIvgadwg8)yv)eZGaMKoRINEX5WkE6S4W7g9vxMg(W92daXJGd)sxD3WxMdJr9CuRC4vY92swathigDqVGgGwsFziUmO4PxC2Rl2NkdeKbpKbWGLHvY92UpDosSHaow0f1UOYGxYae2idXLbfp9IZEDX(uzGGm4bhwXtNfhEvHy5MnOglaLpCV9WdEeC4x6Q7g(YCymQNJALdpT4LbpLbacizamyzisz4rrY23)glsf97cIPI(UEinNb1q6I0nSxqDDzamyzisz4rrY23)g7IM2zXYnZCXMEoSINolomj9SEUiLpCV9aG8i4WV0v3n8L5WkE6S4WAuPavKsz7SgwUz(PWJ4Wyuph1khogz4u6l8TlAANfl3m)J2hpDw2x6Q7gziUmePmmQ71yjlGPdetPuL0n2x6Q7gziwzamyzigzisz4u6l8T4SmVO3WC9(7eHVvujYjsgIldrkdNsFHVDrt7Sy5M5F0(4PZY(sxD3idXYHlv8CynQuGksPSDwdl3m)u4r8H7Thebpco8lD1DdFzoSINoloSgvkqfPu2oRHLBMFk8iomg1ZrTYHXz6mPWYQ(jwDG8P3IUO2fvg8sg8aWYqCzigz4u6l8T4SmVO3WC9(7eHVvujYjsgadwgoL(cF7IM2zXYnZ)O9XtNL9LU6UrgIldJ6EnwYcy6aXukvjDJ9LU6UrgILdxQ45WAuPavKsz7SgwUz(PWJ4d3Bpampco8lD1DdFzoSINoloSgvkqfPu2oRHLBMFk8iomg1ZrTYH3neWHHUO2fvg8sgWz6mPWYQ(jwDG8P3IUO2fvgIwgicaZHlv8CynQuGksPSDwdl3m)u4r8H7TheLhbh(LU6UHVmhwXtNfhwPaxO1PmKg1eXWjsDCymQNJALdB(k5EBrAutedNi1XmFLCVT0rXcidEjdEWHlv8CyLcCHwNYqAutedNi1XhU3Eaa5rWHFPRUB4lZHv80zXHvkWfADkdPrnrmCIuhhgJ65Ow5W(FSqKkY0AXYntJ6r5a0Q4PxCziUm4)XQ(jMbbmjDwfp9IZHlv8CyLcCHwNYqAutedNi1XhU3EaGXJGd)sxD3WxMdR4PZIdRuGl06ugsJAIy4ePoomg1ZrTYHXz6mPWYQ(jwDG8P3IUAajdXLHyKHtPVW3IZY8IEdZ17Vte(wrLiNiziUmSBiGddDrTlQm4LmGZ0zsHLfNL5f9gMR3FNi8TOlQDrLHOLbacizamyzisz4u6l8T4SmVO3WC9(7eHVvujYjsgILdxQ45Wkf4cToLH0OMigorQJpCV9ikZJGd)sxD3WxMdR4PZIdRuGl06ugsJAIy4ePoomg1ZrTYH3neWHHUO2fvg8sgWz6mPWYQ(jwDG8P3IUO2fvgIwgaiG4WLkEoSsbUqRtzinQjIHtK64d3Bpis4rWHFPRUB4lZHv80zXHx00olwUzMl20ZHXOEoQvoCmYaotNjfww1pXQdKp9w0vdiziUmy(k5EB3Noh1fetyswglDuSaYGNeKbaldXLHtPVW3UOPDwSCZ8pAF80zzFPRUBKHyLbWGLHvY92swathiMsPkPBSK(YayWYG)hlKIGsqUBv80lohUuXZHx00olwUzMl20ZhU3aeq8i4WV0v3n8L5WkE6S4Wiv0VliMk676H0CgudPls3WEb115Wyuph1khgNPZKclR6Ny1bYNEl6IAxuzWlzaGYayWYWOUxJvrIGy5MnapZOI1n2x6Q7gzamyzaPTH9fVgRAmuBxYGxYar5WLkEomsf97cIPI(UEinNb1q6I0nSxqDD(W9gGEWJGd)sxD3WxMdR4PZIdVcckRZw)zQtulfZHXOEoQvomotNjfwwkPOywmifbLGC3IUO2fvg8ugaGasgadwgIugg19ASusrXSyqkckb5U9LU6UrgIldtlEzWtzaGasgadwgIugEuKS99VXIur)UGyQOVRhsZzqnKUiDd7fuxNdxQ45WRGGY6S1FM6e1sX8H7nabipco8lD1DdFzoSINolomr(ugWuO7iomg1ZrTYH9)yHueucYDRINEXLbWGLHiLHrDVglLuumlgKIGsqUBFPRUBKH4YW0Ixg8ugaiGKbWGLHiLHhfjBF)BSiv0VliMk676H0CgudPls3WEb115WLkEomr(ugWuO7i(W9gGebpco8lD1DdFzoSINolomK6owDUJOS1RcWHXOEoQvoS)hlKIGsqUBv80lUmagSmePmmQ71yPKIIzXGueucYD7lD1DJmexgMw8YGNYaabKmagSmePm8Oiz77FJfPI(DbXurFxpKMZGAiDr6g2lOUohUuXZHHu3XQZDeLTEva(W9gGaMhbh(LU6UHVmhwXtNfhgcLfeL5JAr1Xqk05Wyuph1khgrwxg8IGmqeYqCzigzyAXldEkdaeqYayWYqKYWJIKTV)nwKk63fetf9D9qAodQH0fPByVG66YqSC4sfphgcLfeL5JAr1Xqk05d3BasuEeC4x6Q7g(YCymQNJALdJZ0zsHLvrIGy5MnapZC1yrxnGKbWGLb)pwifbLGC3Q4PxCzamyzyLCVTKfW0bIPuQs6glPphwXtNfh2pNol(W9gGaqEeC4x6Q7g(YCymQNJALdBYXUOrKUxdZ3PqK3IUO2fvg8IGmaHnCyfpDwC4KCwrxfGpCVbiagpco8lD1DdFzoSINolomwDoMINolMRPdh210HvQ45WNsFHpLpCVbyuMhbh(LU6UHVmhwXtNfhgRohtXtNfZ10Hd7A6Wkv8CyCMotkSO8H7najs4rWHFPRUB4lZHXOEoQvoSINEXzVUyFQm4jbzaGCy6GA8W92doSINolomwDoMINolMRPdh210HvQ45WAE(W9Miaepco8lD1DdFzomg1ZrTYHv80lo71f7tLbcYGhCy6GA8W92doSINolomwDoMINolMRPdh210HvQ45WqVoQX8H7nr4bpco8lD1DdFzomg1ZrTYHnFLCVT7tNJ6cIjmjlJLokwazWlzaWCyfpDwC49PZrDbXOdQf4CymiS7SrrqFOCV9Gp8Hd7Joofx1Hhb3Bp4rWHv80zXHrAtpZC1WHFPRUB4lZhU3aKhbh(LU6UHVmhUuXZH1OsbQiLY2znSCZ8tHhXHv80zXH1OsbQiLY2znSCZ8tHhXhU3ebpco8lD1DdFzoS5ofehgGCyfpDwCyfjcILB2a8mZvdF4dhgNPZKclkpcU3EWJGdR4PZIdRirqSCZgGNzUA4WV0v3n8L5d3BaYJGd)sxD3WxMdJr9CuRCyZxj3B7(05OUGyctYYyPJIfqg8KGmayziUmeJmO4PxC2Rl2NkdEsqgaOmagSmePmCk9f(2fnTZILBM)r7JNol7lD1DJmagSmePmOr9OEUvuHiPSCZgGNzUASV0v3nYayWYWP0x4Bx00olwUz(hTpE6SSV0v3nYqCzigzyu3RXswathiMsPkPBSV0v3nYqCzaNPZKcllzbmDGykLQKUXIUO2fvg8IGmqeYayWYqKYWOUxJLSaMoqmLsvs3yFPRUBKHyLHy5WkE6S4WQFIvhiF65d3BIGhbh(LU6UHVmhgJ65Ow5WrkdiTnSV41yvJHApr6MouzamyzaPTH9fVgRAmuBxYGNYGheLdR4PZIdBuKaSbPfDNirD6S4d3BaZJGd)sxD3WxMdJr9CuRCyez1yMFk8iR57g3Jm4Lm4bG5WkE6S4WusrXSyqkckb5oF4EtuEeC4x6Q7g(YCymQNJALdFk9f(2fnTZILBM)r7JNol7lD1DJmexg8)yv)eZGaMKoRINEXLbWGLbZxj3B7(05OUGyctYYyPJIfqg8sgaSmexgIugoL(cF7IM2zXYnZ)O9XtNL9LU6UrgIldXidrkdAupQNBfviskl3Sb4zMRg7lD1DJmagSmOr9OEUvuHiPSCZgGNzUASV0v3nYqCzW)Jv9tmdcys6SkE6fxgILdR4PZIdtwathiMsPkPB4d3Baipco8lD1DdFzomg1ZrTYHv80lo71f7tLbpjidaugIldXidXid4mDMuyznxhGmTmmZXkil6IAxuzWlcYae2idXLHiLHrDVgR572D7lD1DJmeRmagSmeJmGZ0zsHL18D7UfDrTlQm4fbzacBKH4YWOUxJ18D7U9LU6UrgIvgILdR4PZIdtwathiMsPkPB4d3BamEeC4x6Q7g(YCymQNJALdpkc6JDAXZMKz6ldEkdEayoSINolomfOIfWD2a8mYsyIgGG4d37Ompco8lD1DdFzomg1ZrTYHv80lo71f7tLbpLbaYHv80zXH11uSlD6SyUwCLpCVjs4rWHFPRUB4lZHXOEoQvoSINEXzVUyFQm4PmaqoSINolomvOIe7cIj20HpCV9aq8i4WV0v3n8L5Wyuph1khEue0h70INnjZ0xg8sgIYYqCzyue0h70INnjZ0xg8ugamhwXtNfhMMKog6Q)rCymiS7SrrqFOCV9GpCV9WdEeC4x6Q7g(YCymQNJALdpkc6JDAXZMK5JhgrayzWlzGOYqCzarwxg8IGmeJm4HmaakdRK7TLSaMoqmLsvs3yj9LHy5WkE6S4W0K0Xqx9pIpCV9aG8i4WkE6S4WKfW0bIT6AiGdh(LU6UHVmF4dhg61rnMhb3Bp4rWHFPRUB4lZHXOEoQvo8k5EBPKgZlMjtrl6kEKH4YaISUDAXZMKbyzWtzacBKH4YqKYWcf16Q7w)mDDbX2jIbPiOeK7YayWYG)hlKIGsqUBv80lohwXtNfh2CDaYWz74d3BaYJGd)sxD3WxMdJr9CuRCyez1yMFk8iR57g3Jm4Lm4bGLH4YaISUDAXZMKbyzWtzacBKH4YqKYWcf16Q7w)mDDbX2jIbPiOeK7CyfpDwCyZ1bidNTJpCVjcEeC4x6Q7g(YCymQNJALdJZ0zsHLv9tS6a5tVfDrTlQm4PmquziUmy(k5EB3Noh1fetyswglPphwXtNfhMItse0z0b1cC(W9gW8i4WV0v3n8L5Wyuph1kh28vY92UpDoQliMWKSmwsFziUmeJmGZ0zsHLv9tS6a5tVfDrTlQm4PmquzamyzW8vY92UpDoQliMWKSmw6OybKbpLbaldXYHv80zXHXovyxqmkq1KcP8H7nr5rWHFPRUB4lZHXOEoQvomISAmZpfEK18DJ7rg8sgaiGKH4YqKYWcf16Q7w)mDDbX2jIbPiOeK7CyfpDwCyZ1bidNTJpCVbG8i4WV0v3n8L5Wyuph1kh28vY92UpDoQliMWKSmw6OybKbVKbaldXLbCMotkSSQFIvhiF6TOlQDrLbVKbIqgadwgmFLCVT7tNJ6cIjmjlJLokwazWlzWdoSINolo8(05OUGy0b1cC(W9gaJhbh(LU6UHVmhgJ65Ow5WrkdluuRRUB9Z01feBNigKIGsqUZHv80zXHnxhGmC2o(WhoSMNhb3Bp4rWHFPRUB4lZHXOEoQvomotNjfww1pXQdKp9w0f1UOYqCzqXtV4mto29PZrDbXeMKLrg8ugaehwXtNfh2CDaY0YWmhRG4d3BaYJGd)sxD3WxMdJr9CuRCyCMotkSSQFIvhiF6TOlQDrLH4YGINEXzMCS7tNJ6cIjmjlJm4PmaioSINoloS572D(W9Mi4rWHFPRUB4lZHXOEoQvomotNjfww1pXQdKp9w0f1UOYqCzqXtV4mto29PZrDbXeMKLrg8ugaehwXtNfh2CDaszgYZhU3aMhbh(LU6UHVmhgJ65Ow5WMRdqMwgM5yfKDASaDbjdXLbez1yMFk8iR57g3Jm4Lm4bGLH4YqKYWOUxJDLerNUGy0eDQ9LU6UrgIldrkdluuRRUB9Z01feBNigKIGsqUZHv80zXHVFBUyJ5d3BIYJGd)sxD3WxMdJr9CuRCyZ1bitldZCScYonwGUGKH4YqmYqKYG56aKjq1qah7wyswMByJIG(qLH4YWOUxJDLerNUGy0eDQ9LU6UrgIvgIldrkdluuRRUB9Z01feBNigKIGsqUZHv80zXHVFBUyJ5d3Baipco8lD1DdFzomg1ZrTYHnxhGmTmmZXki70yb6csgIld4mDMuyzv)eRoq(0Brxu7IYHv80zXHP4KebDgDqTaNpCVbW4rWHFPRUB4lZHXOEoQvoS56aKPLHzowbzNglqxqYqCzaNPZKclR6Ny1bYNEl6IAxuoSINolom2Pc7cIrbQMuiLpCVJY8i4WV0v3n8L5Wyuph1khoszyHIAD1DRFMUUGy7eXGueucYDoSINolo89BZfBmF4EtKWJGd)sxD3WxMdJr9CuRC4yKHyKHyKHyKbZxj3B7(05OUGyctYYyPJIfqg8sgaSmexgIugwj3BlzbmDGykLQKUXs6ldXkdGbldMVsU329PZrDbXeMKLXshflGm4LmqeYqSYqCzaNPZKclR6Ny1bYNEl6IAxuzWlzGiKHyLbWGLbZxj3B7(05OUGyctYYyPJIfqg8sg8qgIvgIldXid4mDMuyzvKiiwUzdWZmxnw0f1UOYGNYarLHy5WkE6S4W7tNJ6cIrhulW5Wyqy3zJIG(q5E7bF4E7bG4rWHFPRUB4lZHXOEoQvo8k5EBPKgZlMjtrl6kEKH4YaISUDAXZMKbyzWtzacB4WkE6S4WMRdqgoBhF4E7Hh8i4WV0v3n8L5Wyuph1khELCVTusJ5fZKPOfDfpYqCziszyHIAD1DRFMUUGy7eXGueucYDzamyzW)Jfsrqji3TkE6fNdR4PZIdBUoaz4SD8H7ThaKhbh(LU6UHVmhgJ65Ow5WiYQXm)u4rwZ3nUhzWlzWdaldXLHyKbCMotkSSQFIvhiF6TOlQDrLbpLbIkdGbldMVsU329PZrDbXeMKLXshflGm4PmayziwziUmePmSqrTU6U1ptxxqSDIyqkckb5ohwXtNfh2CDaYWz74d3BpicEeC4x6Q7g(YCymQNJALdhJmeJmGZ0zsHLvrIGy5MnapZC1yrxu7IkdEkdevgadwgmxhGmbQgc4ynnvxDNP5yKHyLH4YqmYaotNjfww1pXQdKp9w0f1UOYGNYarLH4YG5RK7TDF6CuxqmHjzzS0rXcidEkdasgadwgmFLCVT7tNJ6cIjmjlJLokwazWtzaWYqSYqCzigzy3qahg6IAxuzWlzaNPZKclR56aKPLHzowbzrxu7IkdrldEaizamyzy3qahg6IAxuzWtzaNPZKclR6Ny1bYNEl6IAxuziwziwoSINolomfNKiOZOdQf4CymiS7SrrqFOCV9GpCV9aW8i4WV0v3n8L5Wyuph1khogzigzaNPZKclRIebXYnBaEM5QXIUO2fvg8ugiQmagSmyUoazcuneWXAAQU6otZXidXkdXLHyKbCMotkSSQFIvhiF6TOlQDrLbpLbIkdXLbZxj3B7(05OUGyctYYyPJIfqg8ugaKmagSmy(k5EB3Noh1fetyswglDuSaYGNYaGLHyLH4YqmYWUHaom0f1UOYGxYaotNjfwwZ1bitldZCScYIUO2fvgIwg8aqYayWYWUHaom0f1UOYGNYaotNjfww1pXQdKp9w0f1UOYqSYqSCyfpDwCyStf2feJcunPqkhgdc7oBue0hk3Bp4d3Bpikpco8lD1DdFzomg1ZrTYHrKvJz(PWJSMVBCpYGxYaabKmexgIugwOOwxD36NPRli2ormifbLGCNdR4PZIdBUoaz4SD8H7ThaqEeC4x6Q7g(YCymQNJALdhJmeJmeJmeJmy(k5EB3Noh1fetyswglDuSaYGxYaGLH4YqKYWk5EBjlGPdetPuL0nwsFziwzamyzW8vY92UpDoQliMWKSmw6OybKbVKbIqgIvgIld4mDMuyzv)eRoq(0Brxu7IkdEjdeHmeRmagSmy(k5EB3Noh1fetyswglDuSaYGxYGhYqSYqCzigzaNPZKclRIebXYnBaEM5QXIUO2fvg8ugiQmagSmyUoazcuneWXAAQU6otZXidXYHv80zXH3Noh1feJoOwGZhU3EaGXJGd)sxD3WxMdJr9CuRCyZ1bitldZCScYonwGUG4WkE6S4WuCsIGoJoOwGZhU3EeL5rWHFPRUB4lZHXOEoQvoCKYWcf16Q7w)mDDbX2jIbPiOeK7CyfpDwCyZ1bidNTJp8HpC4fhr7S4Edqabqa5bG8GOCyHkQ6cIYHJsj6NO5gzaakdkE6SKbxthQvsmhwjhGjIdd3IKoD6SIsq6E4W(OC3UZHbqYquOcy6ajda4CDakdePuneWrsmasgIsJNC9izWdalOmaqabqajjwsmasgIsaQf0PrHLedGKbaqzaaOXCJmefOlJmaGh9h1BLedGKbaqzikjRfhn3idJIG(W6TmGZY0tNfvgMugqhI0PizaNLPNolQvsmasgaaLbaakUvhDja8znYqULHOGPWJKHr4vbOwjXaizaaugGtsNmaa4Q)rckdaa9tS6a5tVmmcVka1kjwsSINolQ1hDCkUQt0ewcPn9mZvJKyfpDwuRp64uCvNOjSej9SEUOGLkEcAuPavKsz7SgwUz(PWJKeR4PZIA9rhNIR6enHLuKiiwUzdWZmxncAUtbraGsILedGKbaCjsFm5CJm8fhbsgMw8YWa8YGINejdnvg0fA70v3TsIv80zrji2LHTr)r9sIv80zrJMWsluuRRUlyPINGFMUUGy7eXGueucYDbxOoYtaNPZKcllLuumlgKIGsqUBrxu7I6frJpQ71yPKIIzXGueucYD7lD1DJKyaKmaaqXT6OckdrPMlsfug0Yid5a8iziHWgQKyfpDw0OjSKIWAD2Ki0RrWEtarwnM5NcpYA(UX94jaKOXJX)Jfsrqji3TkE6fhm4ih19ASusrXSyqkckb5U9LU6Uj24iY6wZ3nUhpjqujXkE6SOrtyPvxMg2MebsWEtW)Jfsrqji3TkE6fhm4ih19ASusrXSyqkckb5U9LU6UrsSINolA0ewA9i6rc0fKG9MWk5EBjlGPdetPuL0nwsFWG9)yHueucYDRINEXbdoMrDVgRIebXYnBaEMrfRBSV0v3nX9)yv)eZGaMKoRINEXJvsSINolA0ewY1qahkJitAGeFnc2BcXSsU3wYcy6aXOd6f0a0s6hFLCVT7tNJeBiGJfDrTlQxeiASGbR4PxC2Rl2N6jbagpMvY92swathigDqVGgGwsFWGxj3B7(05iXgc4yrxu7I6fbIgRKyfpDw0OjSKw4thK6yy15eS3eIX)Jfsrqji3TkE6fp(OUxJLskkMfdsrqji3TV0v3nXcgS)hR6NygeWK0zv80lUKyfpDw0OjSKIWADMpPJEb7nbfp9IZEDX(upjaqWGJbrw3A(UX94jbIghrwnM5NcpYA(UX94jbaiGIvsSINolA0ewA3OV6Y0iyVjeJ)hlKIGsqUBv80lE8rDVglLuumlgKIGsqUBFPRUBIfmy)pw1pXmiGjPZQ4PxCjXkE6SOrtyPvfILB2GASaub7nHvY92swathigDqVGgGws)4kE6fN96I9Pe8am4vY92UpDosSHaow0f1UOEbHnXv80lo71f7tj4HKyaKmeLqsNuugguxc8HkdKuf6sIv80zrJMWsK0Z65Iub7nHPfVNaeqGbh5JIKTV)nwKk63fetf9D9qAodQH0fPByVG66Gbh5JIKTV)n2fnTZILBM5In9sIv80zrJMWsK0Z65IcwQ4jOrLcurkLTZAy5M5NcpsWEtiMtPVW3UOPDwSCZ8pAF80zzFPRUBIh5OUxJLSaMoqmLsvs3yFPRUBIfm4yI8u6l8T4SmVO3WC9(7eHVvujYjkEKNsFHVDrt7Sy5M5F0(4PZY(sxD3eRKyfpDw0OjSej9SEUOGLkEcAuPavKsz7SgwUz(PWJeS3eWz6mPWYQ(jwDG8P3IUO2f1lpaC8yoL(cFlolZl6nmxV)or4BfvICIad(u6l8TlAANfl3m)J2hpDw2x6Q7M4J6EnwYcy6aXukvjDJ9LU6UjwjXkE6SOrtyjs6z9Crblv8e0OsbQiLY2znSCZ8tHhjyVjSBiGddDrTlQx4mDMuyzv)eRoq(0Brxu7IgnrayjXkE6SOrtyjs6z9Crblv8eukWfADkdPrnrmCIuNG9MG5RK7TfPrnrmCIuhZ8vY92shflGxEijwXtNfnAclrspRNlkyPINGsbUqRtzinQjIHtK6eS3e8)yHivKP1ILBMg1JYbOvXtV4X9)yv)eZGaMKoRINEXLeR4PZIgnHLiPN1ZffSuXtqPaxO1PmKg1eXWjsDc2Bc4mDMuyzv)eRoq(0BrxnGIhZP0x4BXzzErVH5693jcFROsKtu8DdbCyOlQDr9cNPZKcllolZl6nmxV)or4Brxu7IgnabeyWrEk9f(wCwMx0ByUE)DIW3kQe5efRKyfpDw0OjSej9SEUOGLkEckf4cToLH0OMigorQtWEty3qahg6IAxuVWz6mPWYQ(jwDG8P3IUO2fnAacijXkE6SOrtyjs6z9Crblv8ew00olwUzMl20lyVjedotNjfww1pXQdKp9w0vdO4MVsU329PZrDbXeMKLXshflGNeaC8tPVW3UOPDwSCZ8pAF80zzFPRUBIfm4vY92swathiMsPkPBSK(Gb7)XcPiOeK7wfp9IljwXtNfnAclrspRNlkyPINasf97cIPI(UEinNb1q6I0nSxqDDb7nbCMotkSSQFIvhiF6TOlQDr9cGGbpQ71yvKiiwUzdWZmQyDJ9LU6UbmyK2g2x8ASQXqTD5frLeR4PZIgnHLiPN1ZffSuXtyfeuwNT(ZuNOwkwWEtaNPZKcllLuumlgKIGsqUBrxu7I6jaeqGbh5OUxJLskkMfdsrqji3TV0v3nXNw8EcqabgCKpks2((3yrQOFxqmv031dP5mOgsxKUH9cQRljwXtNfnAclrspRNlkyPINar(ugWuO7ib7nb)pwifbLGC3Q4PxCWGJCu3RXsjffZIbPiOeK72x6Q7M4tlEpbiGadoYhfjBF)BSiv0VliMk676H0CgudPls3WEb11LeR4PZIgnHLiPN1ZffSuXtasDhRo3ru26vbeS3e8)yHueucYDRINEXbdoYrDVglLuumlgKIGsqUBFPRUBIpT49eGacm4iFuKS99VXIur)UGyQOVRhsZzqnKUiDd7fuxxsSINolA0ewIKEwpxuWsfpbiuwquMpQfvhdPqxWEtarw3lcer8yMw8EcqabgCKpks2((3yrQOFxqmv031dP5mOgsxKUH9cQRhRKyfpDw0OjSKFoDwc2Bc4mDMuyzvKiiwUzdWZmxnw0vdiWG9)yHueucYDRINEXbdELCVTKfW0bIPuQs6glPVKyaKmefq7A0U6csgisTrKUxJmef0PqKxgAQmOYGpQtupGKeR4PZIgnHLsYzfDvab7nbto2fnI09Ay(ofI8w0f1UOEracBKeR4PZIgnHLWQZXu80zXCnDeSuXt4u6l8PsIv80zrJMWsy15ykE6SyUMocwQ4jGZ0zsHfvsSINolA0ewcRohtXtNfZ10rq6GA8qWdblv8e08c2BckE6fN96I9PEsaGsIv80zrJMWsy15ykE6SyUMocshuJhcEiyPINa0RJASG9MGINEXzVUyFkbpKeR4PZIgnHL2Noh1feJoOwGlige2D2OiOpucEiyVjy(k5EB3Noh1fetyswglDuSaEbyjXsIbqYaaWeaxzaLJoDwsIv80zrTAEcMRdqMwgM5yfKG9MaotNjfww1pXQdKp9w0f1UOXv80loZKJDF6CuxqmHjzz8eqsIv80zrTA(OjSK572Db7nbCMotkSSQFIvhiF6TOlQDrJR4PxCMjh7(05OUGyctYY4jGKeR4PZIA18rtyjZ1biLziVG9MaotNjfww1pXQdKp9w0f1UOXv80loZKJDF6CuxqmHjzz8eqsIv80zrTA(OjS09BZfBSG9MG56aKPLHzowbzNglqxqXrKvJz(PWJSMVBCpE5bGJh5OUxJDLerNUGy0eDQ9LU6UjEKluuRRUB9Z01feBNigKIGsqUljwXtNf1Q5JMWs3VnxSXc2BcMRdqMwgM5yfKDASaDbfpMinxhGmbQgc4y3ctYYCdBue0hA8rDVg7kjIoDbXOj6u7lD1DtSXJCHIAD1DRFMUUGy7eXGueucYDjXkE6SOwnF0ewIItse0z0b1cCb7nbZ1bitldZCScYonwGUGIJZ0zsHLv9tS6a5tVfDrTlQKyfpDwuRMpAclHDQWUGyuGQjfsfS3emxhGmTmmZXki70yb6ckootNjfww1pXQdKp9w0f1UOsIv80zrTA(OjS09BZfBSG9MqKluuRRUB9Z01feBNigKIGsqUljwXtNf1Q5JMWs7tNJ6cIrhulWfedc7oBue0hkbpeS3eIjMyIX8vY92UpDoQliMWKSmw6Oyb8cWXJCLCVTKfW0bIPuQs6glPFSGbB(k5EB3Noh1fetyswglDuSaEreXghNPZKclR6Ny1bYNEl6IAxuViIybd28vY92UpDoQliMWKSmw6Oyb8YJyJhdotNjfwwfjcILB2a8mZvJfDrTlQNenwjXkE6SOwnF0ewYCDaYWz7eS3ewj3BlL0yEXmzkArxXtCezD70INnjdWEcHnsIv80zrTA(OjSK56aKHZ2jyVjSsU3wkPX8IzYu0IUIN4rUqrTU6U1ptxxqSDIyqkckb5oyW(FSqkckb5UvXtV4sIv80zrTA(OjSK56aKHZ2jyVjGiRgZ8tHhznF34E8YdahpgCMotkSSQFIvhiF6TOlQDr9KOGbB(k5EB3Noh1fetyswglDuSaEc4yJh5cf16Q7w)mDDbX2jIbPiOeK7sIv80zrTA(OjSefNKiOZOdQf4cIbHDNnkc6dLGhc2BcXedotNjfwwfjcILB2a8mZvJfDrTlQNefmyZ1bitGQHaowtt1v3zAoMyJhdotNjfww1pXQdKp9w0f1UOEs04MVsU329PZrDbXeMKLXshflGNacmyZxj3B7(05OUGyctYYyPJIfWtahB8y2neWHHUO2f1lCMotkSSMRdqMwgM5yfKfDrTlA0EaiWG3neWHHUO2f1tCMotkSSQFIvhiF6TOlQDrJnwjXkE6SOwnF0ewc7uHDbXOavtkKkige2D2OiOpucEiyVjetm4mDMuyzvKiiwUzdWZmxnw0f1UOEsuWGnxhGmbQgc4ynnvxDNP5yInEm4mDMuyzv)eRoq(0Brxu7I6jrJB(k5EB3Noh1fetyswglDuSaEciWGnFLCVT7tNJ6cIjmjlJLokwapbCSXJz3qahg6IAxuVWz6mPWYAUoazAzyMJvqw0f1UOr7bGadE3qahg6IAxupXz6mPWYQ(jwDG8P3IUO2fn2yLeR4PZIA18rtyjZ1bidNTtWEtarwnM5NcpYA(UX94fabu8ixOOwxD36NPRli2ormifbLGCxsSINolQvZhnHL2Noh1feJoOwGlyVjetmXeJ5RK7TDF6CuxqmHjzzS0rXc4fGJh5k5EBjlGPdetPuL0nws)ybd28vY92UpDoQliMWKSmw6Oyb8IiInootNjfww1pXQdKp9w0f1UOEreXcgS5RK7TDF6CuxqmHjzzS0rXc4LhXgpgCMotkSSkseel3Sb4zMRgl6IAxupjkyWMRdqMavdbCSMMQRUZ0CmXkjwXtNf1Q5JMWsuCsIGoJoOwGlyVjyUoazAzyMJvq2PXc0fKKyfpDwuRMpAclzUoaz4SDc2BcrUqrTU6U1ptxxqSDIyqkckb5UKyjXkE6SOwCMotkSOeuKiiwUzdWZmxnsIv80zrT4mDMuyrJMWsQFIvhiF6fS3emFLCVT7tNJ6cIjmjlJLokwapja44XO4PxC2Rl2N6jbacgCKNsFHVDrt7Sy5M5F0(4PZY(sxD3agCKAupQNBfviskl3Sb4zMRg7lD1DdyWNsFHVDrt7Sy5M5F0(4PZY(sxD3epMrDVglzbmDGykLQKUX(sxD3ehNPZKcllzbmDGykLQKUXIUO2f1lcebyWroQ71yjlGPdetPuL0n2x6Q7MyJvsSINolQfNPZKclA0ewYOibydsl6orI60zjyVjejsBd7lEnw1yO2tKUPdfmyK2g2x8ASQXqTD5PhevsSINolQfNPZKclA0ewIskkMfdsrqji3fS3eqKvJz(PWJSMVBCpE5bGLeR4PZIAXz6mPWIgnHLilGPdetPuL0nc2BcNsFHVDrt7Sy5M5F0(4PZY(sxD3e3)Jv9tmdcys6SkE6fhmyZxj3B7(05OUGyctYYyPJIfWlahpYtPVW3UOPDwSCZ8pAF80zzFPRUBIhtKAupQNBfviskl3Sb4zMRg7lD1DdyWAupQNBfviskl3Sb4zMRg7lD1DtC)pw1pXmiGjPZQ4Px8yLeR4PZIAXz6mPWIgnHLilGPdetPuL0nc2BckE6fN96I9PEsaGXJjgCMotkSSMRdqMwgM5yfKfDrTlQxeGWM4roQ71ynF3UBFPRUBIfm4yWz6mPWYA(UD3IUO2f1lcqyt8rDVgR572D7lD1DtSXkjwXtNf1IZ0zsHfnAclrbQybCNnapJSeMObiib7nHrrqFStlE2KmtFp9aWsIv80zrT4mDMuyrJMWs6Ak2LoDwmxlUkyVjO4PxC2Rl2N6jaLeR4PZIAXz6mPWIgnHLOcvKyxqmXMoc2BckE6fN96I9PEcqjXkE6SOwCMotkSOrtyjAs6yOR(hjige2D2OiOpucEiyVjmkc6JDAXZMKz67vuo(OiOp2PfpBsMPVNawsSINolQfNPZKclA0ewIMKog6Q)rc2BcJIG(yNw8Sjz(4Hrea2lIghrw3lcX4ba4k5EBjlGPdetPuL0nws)yLeR4PZIAXz6mPWIgnHLilGPdeB11qahjXsIv80zrTNsFHpLG4fteiwUzosCByg0vrQG9MaISUDAXZMK5HNqytCez1yMFk8iVamGKeR4PZIApL(cFA0ewA1LPHLB2a8SxxeKG9MG56aKPLHzowbzNglqxqGb7)XQ(jMbbmjDwfp9IhxXtV4SxxSpLGhsIv80zrTNsFHpnAclbrQitRfl3mnQhLdqb7nHyWz6mPWYQ(jwDG8P3IUO2f1layCCMotkSSkseel3Sb4zMRgl6IAxupXz6mPWYIZY8IEdZ17Vte(w0f1UOXcgmotNjfwwfjcILB2a8mZvJfDrTlQxausSINolQ9u6l8PrtyPb4zK1Aswg2or4lyVjSsU3w0Xc4oLY2jcFlPpyWRK7TfDSaUtPSDIWNHtYAoYshflGxE4HKyfpDwu7P0x4tJMWs7etsVHPr9OEoB9QOG9MqKMRdqMwgM5yfKDASaDbjjwXtNf1Ek9f(0OjSeol8RbPZnSTtfVG9MGjhlol8RbPZnSTtfpBLevw0f1UOeaKKyfpDwu7P0x4tJMWs(KOEdQli2QtPJG9MqKMRdqMwgM5yfKDASaDbjjwXtNf1Ek9f(0OjSKWe5mlExm0PzPf(c2BcJ6EnwfjcILB2a8mJkw3yFPRUBIFk9f(2fnTZILBM)r7JNolRyxjk(k5EBjlGPdeJoOxqdqlPpyWNsFHVDrt7Sy5M5F0(4PZYk2vII7)XQ(jMbbmjDwfp9Idg8OUxJvrIGy5MnapZOI1n2x6Q7M4(FSQFIzqatsNvXtV4XXz6mPWYQirqSCZgGNzUASOlQDr9eaciWGh19ASkseel3Sb4zgvSUX(sxD3e3)JvrIGyqatsNvXtV4sIv80zrTNsFHpnAcljmroZI3fdDAwAHVG9MqKMRdqMwgM5yfKDASaDbfFLCVTKfW0bIrh0lObOL0pEKNsFHVDrt7Sy5M5F0(4PZYk2vIIh5OUxJvrIGy5MnapZOI1n2x6Q7gWGhfb9XoT4ztYm99cNPZKclR6Ny1bYNEl6IAxujXkE6SO2tPVWNgnHLqTVV7SUyuFfFb7nHinxhGmTmmZXki70yb6cssSINolQ9u6l8Prtyj0v)UGyBNkEQG9MqKRK7T1VDofXYnBJs6yj9Jh5k5EBxrxhGSCZODzqkusvlPF8ygfb9Xc8QBaY8XJNeIYacm4rrqFSaV6gGmF84fbaciWG3neWHHUO2f1lat0yLeljwXtNf1c96OgtWCDaYWz7eS3ewj3BlL0yEXmzkArxXtCezD70INnjdWEcHnXJCHIAD1DRFMUUGy7eXGueucYDWG9)yHueucYDRINEXLeR4PZIAHEDuJJMWsMRdqgoBNG9MaISAmZpfEK18DJ7XlpaCCezD70INnjdWEcHnXJCHIAD1DRFMUUGy7eXGueucYDjXkE6SOwOxh14OjSefNKiOZOdQf4c2Bc4mDMuyzv)eRoq(0Brxu7I6jrJB(k5EB3Noh1fetyswglPVKyfpDwul0RJAC0ewc7uHDbXOavtkKkyVjy(k5EB3Noh1fetyswglPF8yWz6mPWYQ(jwDG8P3IUO2f1tIcgS5RK7TDF6CuxqmHjzzS0rXc4jGJvsSINolQf61rnoAclzUoaz4SDc2BciYQXm)u4rwZ3nUhVaiGIh5cf16Q7w)mDDbX2jIbPiOeK7sIv80zrTqVoQXrtyP9PZrDbXOdQf4c2BcMVsU329PZrDbXeMKLXshflGxaoootNjfww1pXQdKp9w0f1UOEreGbB(k5EB3Noh1fetyswglDuSaE5HKyfpDwul0RJAC0ewYCDaYWz7eS3eICHIAD1DRFMUUGy7eXGueucYD(Whoha]] )

end
