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


    spec:RegisterPack( "Unholy", 20201014.1, [[dG0(zbqib4raKSjLWOeiNsG6vcsZcHClas1UO0VuImma0XiKwga8mQcmnaQRjiSnacFdGiJJQq5CufcRJQqfZJQu3db7JQOdcqkwOsupKQq0ebiQ6IaKs2ivbvojvbfReH6LaeLUjvbL2jvj)KQqLgkarXsbiQ8uqMQa6Qufu1wbiLAVO6VOmyHomPfRKEmutMIlRAZk1Nb1Ob0PLA1ufKxtiMnvUnb7wYVfnCQQJtviTCiphPPR46iA7cQVtOgpvHQopqwVGO5du7NO5IYdKdz05CVaaabaaffGIcylaefWaoeasCObK)5q(kwef(COsfohYdFbmDG4q(kixQgEGCiAsIWNdbCgFQhNLwcUhGKRwCkSeTfiD60zHr6EwI2c4L4qRKTB8Wu8voKrNZ9caaeaauuakkGTaquad4q4bCiQ)XCVaqiaahcyBmV4RCiZPyoeGsg9Wxathizeq(Rdqzeq2QHbosIbuYOhx8KRhjJIcyIKraaqaaqjXsIbuYOhjqTGp1JJKyaLmcOlJaAmMBKrpSDzKrpCO)qERKyaLmcOlJaAmMBKrpYm8lTgQLd5A6q5bYHoL(cFkpqUxIYdKd9sxD3WxMdHr9CuRCiezD70cNnjtuz0tzegBKXfYiISAmZpfFKm6TmcyaYHu80zXHeUqIaXYnZrIBdZGUkq5d3laWdKd9sxD3WxMdHr9CuRCiZ1bitldZCScYonwKUGLrWGLr)pw1pXmyGjPZQ4PdFzCHmQ4PdF2Rl0NkJeKrr5qkE6S4qRUmnSCZgGN96cG4d3lpGhih6LU6UHVmhcJ65Ow5qbjJ4mDMuCzv)eRoq(0Brxq7IkJElJaczCHmIZ0zsXLvrcGy5MnapZC1yrxq7IkJEkJ4mDMuCzXzzErVH5693jcFl6cAxuzmyzemyzeNPZKIlRIeaXYnBaEM5QXIUG2fvg9wgbahsXtNfhcMurMwlwUzAipkhG8H7fG5bYHEPRUB4lZHWOEoQvo0k5EBrhlI7ukBNi8TK(YiyWY4k5EBrhlI7ukBNi8z4KSMJS0rXIiJElJIkkhsXtNfhAaEgzTMKLHTte(8H7vi4bYHEPRUB4lZHWOEoQvouaYO56aKPLHzowbzNglsxWCifpDwCODIjP3W0qEupNTEvGpCVae8a5qV0v3n8L5qyuph1khYKJfNf(1G05g22PcNTsIkl6cAxuzKGmcqoKINoloeol8RbPZnSTtfoF4EbiXdKd9sxD3WxMdHr9CuRCOaKrZ1bitldZCScYonwKUG5qkE6S4q(KOEdQly2QtPdF4E5X4bYHEPRUB4lZHWOEoQvo0OUxJvrcGy5MnapZOc1n2x6Q7gzCHmEk9f(2WnTZILBM)r7JNolRqxjsgxiJRK7TLSaMoqm6GEbpaTK(YiyWY4P0x4Bd30olwUz(hTpE6SScDLizCHm6)XQ(jMbdmjDwfpD4lJGblJJ6EnwfjaILB2a8mJku3yFPRUBKXfYO)hR6NygmWK0zv80HVmUqgXz6mP4YQibqSCZgGNzUASOlODrLrpLrabaLrWGLXrDVgRIeaXYnBaEMrfQBSV0v3nY4cz0)JvrcGyWatsNvXth(CifpDwCiXjYzc)UyOtZsl85d3lpcEGCOx6Q7g(YCimQNJALdfGmAUoazAzyMJvq2PXI0fSmUqgxj3BlzbmDGy0b9cEaAj9LXfYyaY4P0x4Bd30olwUz(hTpE6SScDLizCHmgGmoQ71yvKaiwUzdWZmQqDJ9LU6Urgbdwghfb)XoTWztYm9LrVLrCMotkUSQFIvhiF6TOlODr5qkE6S4qItKZe(DXqNMLw4ZhUxIcqEGCOx6Q7g(YCimQNJALdfGmAUoazAzyMJvq2PXI0fmhsXtNfhc1((UZ6Ir9v85d3lrfLhih6LU6UHVmhcJ65Ow5qbiJRK7T1VDofXYnBJs6yj9LXfYyaY4k5EBxrxhGSCZODzqkCsvlPVmUqgdsghfb)Xc8QBaY8XJm6jbz0JbqzemyzCue8hlWRUbiZhpYO3eKraaqzemyzC3Wahg6cAxuz0BzeWHqgdMdP4PZIdHU63fmB7uHt5dF4qMVvs3WdK7LO8a5qkE6S4qcDzyB0Fiph6LU6UHVmF4EbaEGCOx6Q7g(YCO0Ndr)WHu80zXHcROwxDNdfwDKNdHZ0zsXLLskiKfdwrWji3TOlODrLrVLXqiJlKXrDVglLuqilgSIGtqUBFPRUB4qHveRuHZH8Z01fmBNigSIGtqUZhUxEapqo0lD1DdFzoeg1ZrTYHqKvJz(P4JSMVBCpYONYiGieY4czmiz0)JfwrWji3TkE6Wxgbdwgdqgh19ASusbHSyWkcob5U9LU6UrgdwgxiJiY6wZ3nUhz0tcYyi4qkE6S4qkcR1ztIqVg(W9cW8a5qV0v3n8L5qyuph1khY)JfwrWji3TkE6Wxgbdwgdqgh19ASusbHSyWkcob5U9LU6UHdP4PZIdT6Y0W2Kiq8H7vi4bYHEPRUB4lZHWOEoQvo0k5EBjlGPdetPuL0nwsFzemyz0)JfwrWji3TkE6Wxgbdwgdsgh19ASksael3Sb4zgvOUX(sxD3iJlKr)pw1pXmyGjPZQ4PdFzmyoKINolo06r0JePly(W9cqWdKd9sxD3WxMdHr9CuRCOGKXvY92swathigDqVGhGwsFzCHmUsU329PZrcnmWXIUG2fvg9MGmgczmyzemyzuXth(SxxOpvg9KGmcazCHmgKmUsU3wYcy6aXOd6f8a0s6lJGblJRK7TDF6CKqddCSOlODrLrVjiJHqgdMdP4PZId5AyGdL5HinWcVg(W9cqIhih6LU6UHVmhcJ65Ow5qbjJ(FSWkcob5UvXth(Y4czCu3RXsjfeYIbRi4eK72x6Q7gzmyzemyz0)Jv9tmdgys6SkE6WNdP4PZIdPf(0bPogwDo(W9YJXdKd9sxD3WxMdHr9CuRCifpD4ZEDH(uz0tcYiaKrWGLXGKrezDR57g3Jm6jbzmeY4czerwnM5NIpYA(UX9iJEsqgbeaugdMdP4PZIdPiSwN5t6ONpCV8i4bYHEPRUB4lZHWOEoQvouqYO)hlSIGtqUBv80HVmUqgh19ASusbHSyWkcob5U9LU6Urgdwgbdwg9)yv)eZGbMKoRINo85qkE6S4q7g9vxMg(W9suaYdKd9sxD3WxMdHr9CuRCOvY92swathigDqVGhGwsFzCHmQ4PdF2Rl0NkJeKrrLrWGLXvY92UpDosOHbow0f0UOYO3Yim2iJlKrfpD4ZEDH(uzKGmkkhsXtNfhAvHz5MnOglcLpCVevuEGCOx6Q7g(YCimQNJALdnTWLrpLraaqzemyzmaz8EuY23)glsf87cMPc(UEinNb3WA40nSxWDDzemyzmaz8EuY23)gB4M2zXYnZCHMEoKINoloej9SEUaLpCVefa8a5qV0v3n8L5qkE6S4qAiPavKsz7SgwUz(P4J4qyuph1khkiz8u6l8THBANfl3m)J2hpDw2x6Q7gzCHmgGmoQ71yjlGPdetPuL0n2x6Q7gzmyzemyzmizmaz8u6l8T4SmVO3WC9(7eHVvq9qjsgxiJbiJNsFHVnCt7Sy5M5F0(4PZY(sxD3iJbZHkv4CinKuGksPSDwdl3m)u8r8H7LOEapqo0lD1DdFzoKINoloKgskqfPu2oRHLBMFk(ioeg1ZrTYHWz6mP4YQ(jwDG8P3IUG2fvg9wgffWY4czmiz8u6l8T4SmVO3WC9(7eHVvq9qjsgbdwgpL(cFB4M2zXYnZ)O9XtNL9LU6UrgxiJJ6EnwYcy6aXukvjDJ9LU6UrgdMdvQW5qAiPavKsz7SgwUz(P4J4d3lrbmpqo0lD1DdFzoKINoloKgskqfPu2oRHLBMFk(ioeg1ZrTYH2nmWHHUG2fvg9wgXz6mP4YQ(jwDG8P3IUG2fvgdvg9aaZHkv4CinKuGksPSDwdl3m)u8r8H7LOHGhih6LU6UHVmhsXtNfhsPadR1PmKgYeXWjsDCimQNJALdz(k5EBrAitedNi1XmFLCVT0rXIiJElJIYHkv4CiLcmSwNYqAitedNi1XhUxIci4bYHEPRUB4lZHu80zXHukWWADkdPHmrmCIuhhcJ65Ow5q(FSWKkY0AXYntd5r5a0Q4PdFzCHm6)XQ(jMbdmjDwfpD4ZHkv4CiLcmSwNYqAitedNi1XhUxIciXdKd9sxD3WxMdP4PZIdPuGH16ugsdzIy4ePooeg1ZrTYHWz6mP4YQ(jwDG8P3IUAajJlKXGKXtPVW3IZY8IEdZ17Vte(wb1dLizCHmUByGddDbTlQm6TmIZ0zsXLfNL5f9gMR3FNi8TOlODrLXqLraaqzemyzmaz8u6l8T4SmVO3WC9(7eHVvq9qjsgdMdvQW5qkfyyToLH0qMigorQJpCVe1JXdKd9sxD3WxMdP4PZIdPuGH16ugsdzIy4ePooeg1ZrTYH2nmWHHUG2fvg9wgXz6mP4YQ(jwDG8P3IUG2fvgdvgbaa5qLkCoKsbgwRtzinKjIHtK64d3lr9i4bYHEPRUB4lZHu80zXHc30olwUzMl00ZHWOEoQvouqYiotNjfxw1pXQdKp9w0vdizCHmA(k5EB3Noh1fmtCswglDuSiYONeKralJlKXtPVW3gUPDwSCZ8pAF80zzFPRUBKXGLrWGLXvY92swathiMsPkPBSK(YiyWYO)hlSIGtqUBv80HphQuHZHc30olwUzMl00ZhUxaaG8a5qV0v3n8L5qkE6S4qivWVlyMk476H0CgCdRHt3WEb315qyuph1khcNPZKIlR6Ny1bYNEl6cAxuz0BzeaYiyWY4OUxJvrcGy5MnapZOc1n2x6Q7gzemyzePTH9WVgRAmuBxYO3Yyi4qLkCoesf87cMPc(UEinNb3WA40nSxWDD(W9caIYdKd9sxD3WxMdP4PZIdTccoRZw)zQtqlfZHWOEoQvoeotNjfxwkPGqwmyfbNGC3IUG2fvg9ugbeaugbdwgdqgh19ASusbHSyWkcob5U9LU6UrgxiJtlCz0tzeaaugbdwgdqgVhLS99VXIub)UGzQGVRhsZzWnSgoDd7fCxNdvQW5qRGGZ6S1FM6e0sX8H7faaapqo0lD1DdFzoKINoloKh6ugWuS7ioeg1ZrTYH8)yHveCcYDRINo8LrWGLXaKXrDVglLuqilgSIGtqUBFPRUBKXfY40cxg9ugbaaLrWGLXaKX7rjBF)BSivWVlyMk476H0CgCdRHt3WEb315qLkCoKh6ugWuS7i(W9caEapqo0lD1DdFzoKINoloeS6owDUJOS1RIWHWOEoQvoK)hlSIGtqUBv80HVmcgSmgGmoQ71yPKcczXGveCcYD7lD1DJmUqgNw4YONYiaaOmcgSmgGmEpkz77FJfPc(DbZubFxpKMZGBynC6g2l4UohQuHZHGv3XQZDeLTEve(W9caaMhih6LU6UHVmhsXtNfhcgLfmL5JAb1Xqk85qyuph1khcrwxg9MGm6bY4czmizCAHlJEkJaaGYiyWYyaY49OKTV)nwKk43fmtf8D9qAodUH1WPByVG76YyWCOsfohcgLfmL5JAb1Xqk85d3laecEGCOx6Q7g(YCimQNJALdHZ0zsXLvrcGy5MnapZC1yrxnGKrWGLr)pwyfbNGC3Q4PdFzemyzCLCVTKfW0bIPuQs6glPphsXtNfhYpNol(W9caacEGCOx6Q7g(YCimQNJALdzYXgUrKUxdZ3PWK3IUG2fvg9MGmcJnCifpDwCOKCwrxfHpCVaaGepqo0lD1DdFzoKINoloewDoMINolMRPdhY10HvQW5qNsFHpLpCVaGhJhih6LU6UHVmhsXtNfhcRohtXtNfZ10Hd5A6Wkv4CiCMotkUO8H7fa8i4bYHEPRUB4lZHWOEoQvoKINo8zVUqFQm6jbzeaCi6GA8W9suoKINoloewDoMINolMRPdhY10HvQW5qAE(W9Ydaipqo0lD1DdFzoeg1ZrTYHu80Hp71f6tLrcYOOCi6GA8W9suoKINoloewDoMINolMRPdhY10HvQW5qWVoQX8H7Lhikpqo0lD1DdFzoKINolo0(05OUGz0b1ICoeg1ZrTYHmFLCVT7tNJ6cMjojlJLokwez0BzeWCimiS7SrrWFOCVeLp8Hd5Joofw1Hhi3lr5bYHu80zXHqAtpZC1WHEPRUB4lZhUxaGhih6LU6UHVmhQuHZH0qsbQiLY2znSCZ8tXhXHu80zXH0qsbQiLY2znSCZ8tXhXhUxEapqo0lD1DdFzoK5ofehcaCifpDwCifjaILB2a8mZvdF4dhcNPZKIlkpqUxIYdKdP4PZIdPibqSCZgGNzUA4qV0v3n8L5d3laWdKd9sxD3WxMdHr9CuRCiZxj3B7(05OUGzItYYyPJIfrg9KGmcyzCHmgKmQ4PdF2Rl0NkJEsqgbGmcgSmgGmEk9f(2WnTZILBM)r7JNol7lD1DJmcgSmgGmQH8OEUvqHjPSCZgGNzUASV0v3nYiyWY4P0x4Bd30olwUz(hTpE6SSV0v3nY4czmizCu3RXswathiMsPkPBSV0v3nY4czeNPZKIllzbmDGykLQKUXIUG2fvg9MGm6bYiyWYyaY4OUxJLSaMoqmLsvs3yFPRUBKXGLXG5qkE6S4qQFIvhiF65d3lpGhih6LU6UHVmhcJ65Ow5qbiJiTnSh(1yvJHAVhFthQmcgSmI02WE4xJvngQTlz0tzu0qWHu80zXHmkse2G0IUtKGoDw8H7fG5bYHEPRUB4lZHWOEoQvoeISAmZpfFK18DJ7rg9wgffWCifpDwCikPGqwmyfbNGCNpCVcbpqo0lD1DdFzoeg1ZrTYHoL(cFB4M2zXYnZ)O9XtNL9LU6UrgxiJ(FSQFIzWatsNvXth(YiyWYO5RK7TDF6CuxWmXjzzS0rXIiJElJawgxiJbiJNsFHVnCt7Sy5M5F0(4PZY(sxD3iJlKXGKXaKrnKh1ZTckmjLLB2a8mZvJ9LU6Urgbdwg1qEup3kOWKuwUzdWZmxn2x6Q7gzCHm6)XQ(jMbdmjDwfpD4lJbZHu80zXHilGPdetPuL0n8H7fGGhih6LU6UHVmhcJ65Ow5qkE6WN96c9PYONeKraiJlKXGKXGKrCMotkUSMRdqMwgM5yfKfDbTlQm6nbzegBKXfYyaY4OUxJ18D7U9LU6UrgdwgbdwgdsgXz6mP4YA(UD3IUG2fvg9MGmcJnY4czCu3RXA(UD3(sxD3iJblJbZHu80zXHilGPdetPuL0n8H7fGepqo0lD1DdFzoeg1ZrTYHgfb)XoTWztYm9LrpLrrbmhsXtNfhIcuXI4oBaEgzjordqq8H7LhJhih6LU6UHVmhcJ65Ow5qkE6WN96c9PYONYia4qkE6S4q6Ak0LoDwmxlSYhUxEe8a5qV0v3n8L5qyuph1khsXth(SxxOpvg9ugbahsXtNfhIkwrcDbZeA6WhUxIcqEGCOx6Q7g(YCifpDwCiAs6yOR(hXHWOEoQvo0Oi4p2PfoBsMPVm6Tm6XKXfY4Oi4p2PfoBsMPVm6Pmcyoege2D2Oi4puUxIYhUxIkkpqo0lD1DdFzoeg1ZrTYHcsgdqgrAByp8RXQgd1Ep(MouzemyzePTH9WVgRAmuBxYONYiaaOmgSmUqgrK1LrVjiJbjJIkJa6Y4k5EBjlGPdetPuL0nwsFzmyoKINoloenjDm0v)J4d3lrbapqoKINoloezbmDGyRUgg4WHEPRUB4lZh(WH088a5Ejkpqo0lD1DdFzoeg1ZrTYHWz6mP4YQ(jwDG8P3IUG2fvgxiJkE6WNzYXUpDoQlyM4KSmYONYia5qkE6S4qMRdqMwgM5yfeF4EbaEGCOx6Q7g(YCimQNJALdHZ0zsXLv9tS6a5tVfDbTlQmUqgv80HpZKJDF6CuxWmXjzzKrpLraYHu80zXHmF3UZhUxEapqo0lD1DdFzoeg1ZrTYHWz6mP4YQ(jwDG8P3IUG2fvgxiJkE6WNzYXUpDoQlyM4KSmYONYia5qkE6S4qMRdqkZqE(W9cW8a5qV0v3n8L5qyuph1khYCDaY0YWmhRGStJfPlyzCHmIiRgZ8tXhznF34EKrVLrrbSmUqgdqgh19ASRKi60fmJMOtTV0v3nY4czmazmSIAD1DRFMUUGz7eXGveCcYDoKINolo09BZfAmF4EfcEGCOx6Q7g(YCimQNJALdzUoazAzyMJvq2PXI0fSmUqgdsgdqgnxhGmrQgg4y3ItYYCdBue8hQmUqgh19ASRKi60fmJMOtTV0v3nYyWY4czmazmSIAD1DRFMUUGz7eXGveCcYDoKINolo09BZfAmF4Ebi4bYHEPRUB4lZHWOEoQvoK56aKPLHzowbzNglsxWY4czeNPZKIlR6Ny1bYNEl6cAxuoKINoloefNKi4ZOdQf58H7fGepqo0lD1DdFzoeg1ZrTYHmxhGmTmmZXki70yr6cwgxiJ4mDMuCzv)eRoq(0Brxq7IYHu80zXHWovCxWmkq1KIP8H7LhJhih6LU6UHVmhcJ65Ow5qbiJHvuRRUB9Z01fmBNigSIGtqUZHu80zXHUFBUqJ5d3lpcEGCOx6Q7g(YCifpDwCO9PZrDbZOdQf5CimQNJALdfKmgKmgKmgKmA(k5EB3Noh1fmtCswglDuSiYO3YiGLXfYyaY4k5EBjlGPdetPuL0nwsFzmyzemyz08vY92UpDoQlyM4KSmw6OyrKrVLrpqgdwgxiJ4mDMuCzv)eRoq(0Brxq7IkJElJEGmgSmcgSmA(k5EB3Noh1fmtCswglDuSiYO3YOOYyWY4czmizeNPZKIlRIeaXYnBaEM5QXIUG2fvg9ugdHmgmhcdc7oBue8hk3lr5d3lrbipqo0lD1DdFzoeg1ZrTYHwj3BlL0yEXmzkyrxXJmUqgrK1TtlC2KmalJEkJWydhsXtNfhYCDaYWz74d3lrfLhih6LU6UHVmhcJ65Ow5qRK7TLsAmVyMmfSOR4rgxiJbiJHvuRRUB9Z01fmBNigSIGtqUlJGblJ(FSWkcob5UvXth(CifpDwCiZ1bidNTJpCVefa8a5qV0v3n8L5qyuph1khcrwnM5NIpYA(UX9iJElJIcyzCHmgKmIZ0zsXLv9tS6a5tVfDbTlQm6Pmgczemyz08vY92UpDoQlyM4KSmw6OyrKrpLralJblJlKXaKXWkQ1v3T(z66cMTtedwrWji35qkE6S4qMRdqgoBhF4EjQhWdKd9sxD3WxMdP4PZIdrXjjc(m6GArohcJ65Ow5qbjJbjJ4mDMuCzvKaiwUzdWZmxnw0f0UOYONYyiKrWGLrZ1bitKQHbowtt1v3zAogzmyzCHmgKmIZ0zsXLv9tS6a5tVfDbTlQm6PmgczCHmA(k5EB3Noh1fmtCswglDuSiYONYiaLrWGLrZxj3B7(05OUGzItYYyPJIfrg9ugbSmgSmUqgdsg3nmWHHUG2fvg9wgXz6mP4YAUoazAzyMJvqw0f0UOYyOYOOaugbdwg3nmWHHUG2fvg9ugXz6mP4YQ(jwDG8P3IUG2fvgdwgdMdHbHDNnkc(dL7LO8H7LOaMhih6LU6UHVmhsXtNfhc7uXDbZOavtkMYHWOEoQvouqYyqYiotNjfxwfjaILB2a8mZvJfDbTlQm6Pmgczemyz0CDaYePAyGJ10uD1DMMJrgdwgxiJbjJ4mDMuCzv)eRoq(0Brxq7IkJEkJHqgxiJMVsU329PZrDbZeNKLXshflIm6Pmcqzemyz08vY92UpDoQlyM4KSmw6OyrKrpLralJblJlKXGKXDddCyOlODrLrVLrCMotkUSMRdqMwgM5yfKfDbTlQmgQmkkaLrWGLXDddCyOlODrLrpLrCMotkUSQFIvhiF6TOlODrLXGLXG5qyqy3zJIG)q5EjkF4EjAi4bYHEPRUB4lZHWOEoQvoeISAmZpfFK18DJ7rg9wgbaaLXfYyaYyyf16Q7w)mDDbZ2jIbRi4eK7CifpDwCiZ1bidNTJpCVefqWdKd9sxD3WxMdHr9CuRCOGKXGKXGKXGKrZxj3B7(05OUGzItYYyPJIfrg9wgbSmUqgdqgxj3BlzbmDGykLQKUXs6lJblJGblJMVsU329PZrDbZeNKLXshflIm6Tm6bYyWY4czeNPZKIlR6Ny1bYNEl6cAxuz0Bz0dKXGLrWGLrZxj3B7(05OUGzItYYyPJIfrg9wgfvgdwgxiJbjJ4mDMuCzvKaiwUzdWZmxnw0f0UOYONYyiKrWGLrZ1bitKQHbowtt1v3zAogzmyoKINolo0(05OUGz0b1IC(W9suajEGCOx6Q7g(YCimQNJALdzUoazAzyMJvq2PXI0fmhsXtNfhIItse8z0b1IC(W9supgpqo0lD1DdFzoeg1ZrTYHcqgdROwxD36NPRly2ormyfbNGCNdP4PZIdzUoaz4SD8HpCi4xh1yEGCVeLhih6LU6UHVmhcJ65Ow5qRK7TLsAmVyMmfSOR4rgxiJiY62PfoBsgGLrpLrySrgxiJbiJHvuRRUB9Z01fmBNigSIGtqUlJGblJ(FSWkcob5UvXth(CifpDwCiZ1bidNTJpCVaapqo0lD1DdFzoeg1ZrTYHqKvJz(P4JSMVBCpYO3YOOawgxiJiY62PfoBsgGLrpLrySrgxiJbiJHvuRRUB9Z01fmBNigSIGtqUZHu80zXHmxhGmC2o(W9Yd4bYHEPRUB4lZHWOEoQvoK5RK7TDF6CuxWmXjzzSK(CifpDwCikojrWNrhulY5d3laZdKd9sxD3WxMdHr9CuRCiZxj3B7(05OUGzItYYyj9LXfYyqYiotNjfxw1pXQdKp9w0f0UOYONYyiKrWGLrZxj3B7(05OUGzItYYyPJIfrg9ugbSmgmhsXtNfhc7uXDbZOavtkMYhUxHGhih6LU6UHVmhcJ65Ow5qiYQXm)u8rwZ3nUhz0BzeaaugxiJbiJHvuRRUB9Z01fmBNigSIGtqUZHu80zXHmxhGmC2o(W9cqWdKd9sxD3WxMdHr9CuRCiZxj3B7(05OUGzItYYyPJIfrg9wgbSmUqgXz6mP4YQ(jwDG8P3IUG2fvg9wg9azemyz08vY92UpDoQlyM4KSmw6OyrKrVLrr5qkE6S4q7tNJ6cMrhulY5d3lajEGCOx6Q7g(YCimQNJALdfGmgwrTU6U1ptxxWSDIyWkcob5ohsXtNfhYCDaYWz74dF4dhk8r0olUxaaGaaGIcqrbmhsSIQUGPCipmc(jAUrgbeYOINolz010HALeZH8r5UDNdbOKrp8fW0bsgbK)6augbKTAyGJKyaLm6Xfp56rYOOaMizeaaeaausSKyaLm6rcul4t94ijgqjJa6YiGgJ5gz0dBxgz0dh6pK3kjgqjJa6YOhzwHpAUrghfb)H1BzeNLPNolQmoPmIomPtrYioltpDwuRKyaLmcOlJaYP4wD0L8WL1iJ5wgbKjfFKmoIVkc1kjwsSINolQ1hDCkSQtOewcPn9mZvJKyfpDwuRp64uyvNqjSej9SEUarLkCcAiPavKsz7SgwUz(P4JKeR4PZIA9rhNcR6ekHLuKaiwUzdWZmxnezUtbraasILedOKraT84pMCUrgF4JajJtlCzCaEzuXtIKXMkJAyTD6Q7wjXkE6SOee6YW2O)qEjXkE6SOHsyPWkQ1v3jQuHtWptxxWSDIyWkcob5orHvh5jGZ0zsXLLskiKfdwrWji3TOlODr9oelg19ASusbHSyWkcob5U9LU6UrsmGsgbKtXT6OejJEyMlqjsg1YiJ5a8izmHXgQKyfpDw0qjSKIWAD2Ki0RHOEtarwnM5NIpYA(UX94jGielcY)JfwrWji3TkE6Whm4ag19ASusbHSyWkcob5U9LU6Uj4fiY6wZ3nUhpjecjXkE6SOHsyPvxMg2MebIOEtW)JfwrWji3TkE6Whm4ag19ASusbHSyWkcob5U9LU6UrsSINolAOewA9i6rI0fmr9MWk5EBjlGPdetPuL0nwsFWG9)yHveCcYDRINo8bdoOrDVgRIeaXYnBaEMrfQBSV0v3nl8)yv)eZGbMKoRINo8dwsSINolAOewY1WahkZdrAGfEne1BcbTsU3wYcy6aXOd6f8a0s6VyLCVT7tNJeAyGJfDbTlQ3ecrWGbR4PdF2Rl0N6jbaSiOvY92swathigDqVGhGwsFWGxj3B7(05iHgg4yrxq7I6nHqeSKyfpDw0qjSKw4thK6yy15iQ3ecY)JfwrWji3TkE6WFXOUxJLskiKfdwrWji3TV0v3nbdgS)hR6NygmWK0zv80HVKyfpDw0qjSKIWADMpPJEI6nbfpD4ZEDH(upjaaWGdcrw3A(UX94jHqSarwnM5NIpYA(UX94jbabadwsSINolAOewA3OV6Y0quVjeK)hlSIGtqUBv80H)IrDVglLuqilgSIGtqUBFPRUBcgmy)pw1pXmyGjPZQ4PdFjXkE6SOHsyPvfMLB2GASiuI6nHvY92swathigDqVGhGws)fkE6WN96c9Peefm4vY92UpDosOHbow0f0UOEdJnlu80Hp71f6tjiQKyaLm6rssNuqghuxI8HkJKuf(sIv80zrdLWsK0Z65cuI6nHPfUNaaGGbhW9OKTV)nwKk43fmtf8D9qAodUH1WPByVG76GbhW9OKTV)n2WnTZILBM5cn9sIv80zrdLWsK0Z65cevQWjOHKcurkLTZAy5M5NIpIOEtiOtPVW3gUPDwSCZ8pAF80zzFPRUBweWOUxJLSaMoqmLsvs3yFPRUBcgm4Gc4u6l8T4SmVO3WC9(7eHVvq9qjAraNsFHVnCt7Sy5M5F0(4PZY(sxD3eSKyfpDw0qjSej9SEUarLkCcAiPavKsz7SgwUz(P4JiQ3eWz6mP4YQ(jwDG8P3IUG2f1Brb8IGoL(cFlolZl6nmxV)or4BfupuIad(u6l8THBANfl3m)J2hpDw2x6Q7MfJ6EnwYcy6aXukvjDJ9LU6UjyjXkE6SOHsyjs6z9CbIkv4e0qsbQiLY2znSCZ8tXhruVjSByGddDbTlQ34mDMuCzv)eRoq(0Brxq7IgQhayjXkE6SOHsyjs6z9CbIkv4eukWWADkdPHmrmCIuhr9MG5RK7TfPHmrmCIuhZ8vY92shflI3IkjwXtNfnuclrspRNlquPcNGsbgwRtzinKjIHtK6iQ3e8)yHjvKP1ILBMgYJYbOvXth(l8)yv)eZGbMKoRINo8LeR4PZIgkHLiPN1ZfiQuHtqPadR1PmKgYeXWjsDe1Bc4mDMuCzv)eRoq(0BrxnGwe0P0x4BXzzErVH5693jcFRG6Hs0IDddCyOlODr9gNPZKIllolZl6nmxV)or4Brxq7IgkaaiyWbCk9f(wCwMx0ByUE)DIW3kOEOefSKyfpDw0qjSej9SEUarLkCckfyyToLH0qMigorQJOEty3Wahg6cAxuVXz6mP4YQ(jwDG8P3IUG2fnuaaqjXkE6SOHsyjs6z9CbIkv4ec30olwUzMl00tuVjeeotNjfxw1pXQdKp9w0vdOfMVsU329PZrDbZeNKLXshflINea8ItPVW3gUPDwSCZ8pAF80zzFPRUBcgm4vY92swathiMsPkPBSK(Gb7)XcRi4eK7wfpD4ljwXtNfnuclrspRNlquPcNasf87cMPc(UEinNb3WA40nSxWDDI6nbCMotkUSQFIvhiF6TOlODr9gaGbpQ71yvKaiwUzdWZmQqDJ9LU6UbmyK2g2d)ASQXqTD5DiKeR4PZIgkHLiPN1ZfiQuHtyfeCwNT(ZuNGwkMOEtaNPZKIllLuqilgSIGtqUBrxq7I6jGaGGbhWOUxJLskiKfdwrWji3TV0v3nlMw4EcaacgCa3Js2((3yrQGFxWmvW31dP5m4gwdNUH9cURljwXtNfnuclrspRNlquPcNGh6ugWuS7iI6nb)pwyfbNGC3Q4PdFWGdyu3RXsjfeYIbRi4eK72x6Q7MftlCpbaabdoG7rjBF)BSivWVlyMk476H0CgCdRHt3WEb31LeR4PZIgkHLiPN1ZfiQuHtawDhRo3ru26vriQ3e8)yHveCcYDRINo8bdoGrDVglLuqilgSIGtqUBFPRUBwmTW9eaaem4aUhLS99VXIub)UGzQGVRhsZzWnSgoDd7fCxxsSINolAOewIKEwpxGOsfobyuwWuMpQfuhdPWNOEtarw3BcEWIGMw4EcaacgCa3Js2((3yrQGFxWmvW31dP5m4gwdNUH9cURhSKyfpDw0qjSKFoDwe1Bc4mDMuCzvKaiwUzdWZmxnw0vdiWG9)yHveCcYDRINo8bdELCVTKfW0bIPuQs6glPVKyaLm6Hv7A0U6cwgb0UrKUxJmciJtHjVm2uzuLrFuNOEajjwXtNfnuclLKZk6Qie1BcMCSHBeP71W8Dkm5TOlODr9Mam2ijwXtNfnuclHvNJP4PZI5A6quPcNWP0x4tLeR4PZIgkHLWQZXu80zXCnDiQuHtaNPZKIlQKyfpDw0qjSewDoMINolMRPdr0b14HGOevQWjO5jQ3eu80Hp71f6t9KaaKeR4PZIgkHLWQZXu80zXCnDiIoOgpeeLOsfob4xh1yI6nbfpD4ZEDH(ucIkjwXtNfnuclTpDoQlygDqTiNimiS7SrrWFOeeLOEtW8vY92UpDoQlyM4KSmw6Oyr8gWsILedOKranjGwYikhD6SKeR4PZIA18emxhGmTmmZXkiI6nbCMotkUSQFIvhiF6TOlODrxO4PdFMjh7(05OUGzItYY4jaLeR4PZIA18HsyjZ3T7e1Bc4mDMuCzv)eRoq(0Brxq7IUqXth(mto29PZrDbZeNKLXtakjwXtNf1Q5dLWsMRdqkZqEI6nbCMotkUSQFIvhiF6TOlODrxO4PdFMjh7(05OUGzItYY4jaLeR4PZIA18HsyP73Ml0yI6nbZ1bitldZCScYonwKUGxGiRgZ8tXhznF34E8wuaViGrDVg7kjIoDbZOj6u7lD1DZIacROwxD36NPRly2ormyfbNGCxsSINolQvZhkHLUFBUqJjQ3emxhGmTmmZXki70yr6cErqbyUoazIunmWXUfNKL5g2Oi4p0fJ6En2vseD6cMrt0P2x6Q7MGxeqyf16Q7w)mDDbZ2jIbRi4eK7sIv80zrTA(qjSefNKi4ZOdQf5e1BcMRdqMwgM5yfKDASiDbVaNPZKIlR6Ny1bYNEl6cAxujXkE6SOwnFOewc7uXDbZOavtkMsuVjyUoazAzyMJvq2PXI0f8cCMotkUSQFIvhiF6TOlODrLeR4PZIA18HsyP73Ml0yI6nHacROwxD36NPRly2ormyfbNGCxsSINolQvZhkHL2Noh1fmJoOwKtege2D2Oi4pucIsuVjeuqbfK5RK7TDF6CuxWmXjzzS0rXI4nGxeWk5EBjlGPdetPuL0nws)Gbd28vY92UpDoQlyM4KSmw6Oyr82dcEbotNjfxw1pXQdKp9w0f0UOE7bbdgS5RK7TDF6CuxWmXjzzS0rXI4TObViiCMotkUSksael3Sb4zMRgl6cAxupdrWsIv80zrTA(qjSK56aKHZ2ruVjSsU3wkPX8IzYuWIUINfiY62PfoBsgG9egBKeR4PZIA18HsyjZ1bidNTJOEtyLCVTusJ5fZKPGfDfplciSIAD1DRFMUUGz7eXGveCcYDWG9)yHveCcYDRINo8LeR4PZIA18HsyjZ1bidNTJOEtarwnM5NIpYA(UX94TOaErq4mDMuCzv)eRoq(0Brxq7I6ziad28vY92UpDoQlyM4KSmw6Oyr8eWbViGWkQ1v3T(z66cMTtedwrWji3LeR4PZIA18HsyjkojrWNrhulYjcdc7oBue8hkbrjQ3eckiCMotkUSksael3Sb4zMRgl6cAxupdbyWMRdqMivddCSMMQRUZ0CmbViiCMotkUSQFIvhiF6TOlODr9melmFLCVT7tNJ6cMjojlJLokwepbiyWMVsU329PZrDbZeNKLXshflINao4fbTByGddDbTlQ34mDMuCznxhGmTmmZXkil6cAx0qffGGbVByGddDbTlQN4mDMuCzv)eRoq(0Brxq7IgCWsIv80zrTA(qjSe2PI7cMrbQMumLimiS7SrrWFOeeLOEtiOGWz6mP4YQibqSCZgGNzUASOlODr9meGbBUoazIunmWXAAQU6otZXe8IGWz6mP4YQ(jwDG8P3IUG2f1ZqSW8vY92UpDoQlyM4KSmw6Oyr8eGGbB(k5EB3Noh1fmtCswglDuSiEc4Gxe0UHbom0f0UOEJZ0zsXL1CDaY0YWmhRGSOlODrdvuacg8UHbom0f0UOEIZ0zsXLv9tS6a5tVfDbTlAWbljwXtNf1Q5dLWsMRdqgoBhr9MaISAmZpfFK18DJ7XBaaWfbewrTU6U1ptxxWSDIyWkcob5UKyfpDwuRMpuclTpDoQlygDqTiNOEtiOGckiZxj3B7(05OUGzItYYyPJIfXBaViGvY92swathiMsPkPBSK(bdgS5RK7TDF6CuxWmXjzzS0rXI4The8cCMotkUSQFIvhiF6TOlODr92dcgmyZxj3B7(05OUGzItYYyPJIfXBrdErq4mDMuCzvKaiwUzdWZmxnw0f0UOEgcWGnxhGmrQgg4ynnvxDNP5ycwsSINolQvZhkHLO4KebFgDqTiNOEtWCDaY0YWmhRGStJfPlyjXkE6SOwnFOewYCDaYWz7iQ3eciSIAD1DRFMUUGz7eXGveCcYDjXsIv80zrT4mDMuCrjOibqSCZgGNzUAKeR4PZIAXz6mP4IgkHLu)eRoq(0tuVjy(k5EB3Noh1fmtCswglDuSiEsaWlcsXth(SxxOp1tcaam4aoL(cFB4M2zXYnZ)O9XtNL9LU6Ubm4a0qEup3kOWKuwUzdWZmxn2x6Q7gWGpL(cFB4M2zXYnZ)O9XtNL9LU6UzrqJ6EnwYcy6aXukvjDJ9LU6UzbotNjfxwYcy6aXukvjDJfDbTlQ3e8aWGdyu3RXswathiMsPkPBSV0v3nbhSKyfpDwulotNjfx0qjSKrrIWgKw0DIe0PZIOEtiaK2g2d)ASQXqT3JVPdfmyK2g2d)ASQXqTD5POHqsSINolQfNPZKIlAOewIskiKfdwrWji3jQ3eqKvJz(P4JSMVBCpElkGLeR4PZIAXz6mP4IgkHLilGPdetPuL0ne1BcNsFHVnCt7Sy5M5F0(4PZY(sxD3SW)Jv9tmdgys6SkE6WhmyZxj3B7(05OUGzItYYyPJIfXBaViGtPVW3gUPDwSCZ8pAF80zzFPRUBweuaAipQNBfuyskl3Sb4zMRg7lD1DdyWAipQNBfuyskl3Sb4zMRg7lD1DZc)pw1pXmyGjPZQ4Pd)GLeR4PZIAXz6mP4IgkHLilGPdetPuL0ne1BckE6WN96c9PEsaalckiCMotkUSMRdqMwgM5yfKfDbTlQ3eGXMfbmQ71ynF3UBFPRUBcgm4GWz6mP4YA(UD3IUG2f1BcWyZIrDVgR572D7lD1DtWbljwXtNf1IZ0zsXfnuclrbQyrCNnapJSeNObiiI6nHrrWFStlC2KmtFpffWsIv80zrT4mDMuCrdLWs6Ak0LoDwmxlSsuVjO4PdF2Rl0N6jaKeR4PZIAXz6mP4IgkHLOIvKqxWmHMoe1BckE6WN96c9PEcajXkE6SOwCMotkUOHsyjAs6yOR(hrege2D2Oi4pucIsuVjmkc(JDAHZMKz67ThBXOi4p2PfoBsMPVNawsSINolQfNPZKIlAOewIMKog6Q)re1BcbfasBd7HFnw1yO27X30HcgmsBd7HFnw1yO2U8eaam4fiY6Etiirb0xj3BlzbmDGykLQKUXs6hSKyfpDwulotNjfx0qjSezbmDGyRUgg4ijwsSINolQ9u6l8PeeUqIaXYnZrIBdZGUkqjQ3eqK1TtlC2Kmr9egBwGiRgZ8tXh5nGbOKyfpDwu7P0x4tdLWsRUmnSCZgGN96cGiQ3emxhGmTmmZXki70yr6cgmy)pw1pXmyGjPZQ4Pd)fkE6WN96c9PeevsSINolQ9u6l8PHsyjysfzATy5MPH8OCasuVjeeotNjfxw1pXQdKp9w0f0UOEdiwGZ0zsXLvrcGy5MnapZC1yrxq7I6jotNjfxwCwMx0ByUE)DIW3IUG2fnyWGXz6mP4YQibqSCZgGNzUASOlODr9gasIv80zrTNsFHpnuclnapJSwtYYW2jcFI6nHvY92Iowe3Pu2or4Bj9bdELCVTOJfXDkLTte(mCswZrw6Oyr8wurLeR4PZIApL(cFAOewANys6nmnKh1ZzRxfiQ3ecWCDaY0YWmhRGStJfPlyjXkE6SO2tPVWNgkHLWzHFniDUHTDQWjQ3em5yXzHFniDUHTDQWzRKOYIUG2fLaaLeR4PZIApL(cFAOewYNe1BqDbZwDkDiQ3ecWCDaY0YWmhRGStJfPlyjXkE6SO2tPVWNgkHLeNiNj87IHonlTWNOEtyu3RXQibqSCZgGNzuH6g7lD1DZItPVW3gUPDwSCZ8pAF80zzf6krlwj3BlzbmDGy0b9cEaAj9bd(u6l8THBANfl3m)J2hpDwwHUs0c)pw1pXmyGjPZQ4PdFWGh19ASksael3Sb4zgvOUX(sxD3SW)Jv9tmdgys6SkE6WFbotNjfxwfjaILB2a8mZvJfDbTlQNacacg8OUxJvrcGy5MnapZOc1n2x6Q7Mf(FSksaedgys6SkE6WxsSINolQ9u6l8PHsyjXjYzc)UyOtZsl8jQ3ecWCDaY0YWmhRGStJfPl4fRK7TLSaMoqm6GEbpaTK(lc4u6l8THBANfl3m)J2hpDwwHUs0Iag19ASksael3Sb4zgvOUX(sxD3ag8Oi4p2PfoBsMPV34mDMuCzv)eRoq(0Brxq7IkjwXtNf1Ek9f(0qjSeQ99DN1fJ6R4tuVjeG56aKPLHzowbzNglsxWsIv80zrTNsFHpnuclHU63fmB7uHtjQ3ecyLCVT(TZPiwUzBushlP)Iawj3B7k66aKLBgTldsHtQAj9xe0Oi4pwGxDdqMpE8KGhdGGbpkc(Jf4v3aK5JhVjaaacg8UHbom0f0UOEd4qeSKyjXkE6SOw4xh1ycMRdqgoBhr9MWk5EBPKgZlMjtbl6kEwGiRBNw4Sjza2tySzraHvuRRUB9Z01fmBNigSIGtqUdgS)hlSIGtqUBv80HVKyfpDwul8RJACOewYCDaYWz7iQ3eqKvJz(P4JSMVBCpElkGxGiRBNw4Sjza2tySzraHvuRRUB9Z01fmBNigSIGtqUljwXtNf1c)6OghkHLO4KebFgDqTiNOEtW8vY92UpDoQlyM4KSmwsFjXkE6SOw4xh14qjSe2PI7cMrbQMumLOEtW8vY92UpDoQlyM4KSmws)fbHZ0zsXLv9tS6a5tVfDbTlQNHamyZxj3B7(05OUGzItYYyPJIfXtahSKyfpDwul8RJACOewYCDaYWz7iQ3eqKvJz(P4JSMVBCpEdaaUiGWkQ1v3T(z66cMTtedwrWji3LeR4PZIAHFDuJdLWs7tNJ6cMrhulYjQ3emFLCVT7tNJ6cMjojlJLokweVb8cCMotkUSQFIvhiF6TOlODr92dad28vY92UpDoQlyM4KSmw6Oyr8wujXkE6SOw4xh14qjSK56aKHZ2ruVjeqyf16Q7w)mDDbZ2jIbRi4eK7CiLCaMioeulq60PZYJeP7Hp8HZb]] )

end
