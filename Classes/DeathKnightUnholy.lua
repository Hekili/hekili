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
            duration = function () return talent.spell_eater.enabled and 10 or 5 end,
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
            duration = 15,
            generate = function( t )
                local cast = class.abilities.dark_transformation.lastCast or 0
                local up = pet.ghoul.up and cast + 20 > state.query_time

                t.name = t.name or class.abilities.dark_transformation.name
                t.count = up and 1 or 0
                t.expires = up and cast + 20 or 0
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
                    gain( 12, "runic_power" )
                else                    
                    gain( 3 * debuff.festering_wound.stack, "runic_power" )
                    apply_festermight( debuff.festering_wound.stack )
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
            id = 49039,
            cast = 0,
            cooldown = 60,
            gcd = "off",

            toggle = "defensives",

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


    spec:RegisterPack( "Unholy", 20200828, [[dCerHbqibQhjOuBsqgLa6ucKxPKywcWTuQiTls9lLKgMsvoMGQLPuPNrusttPQUgrP2MGs(MsfLXrucNtqHADckKMNsk3dj2hrXbfuKwOsQEOGIyIkvuLlkOqSrLkQCsbfOvIK8sLkI6Mcki7uOyOckOwQGc4PqmvHsxvPIiBvPIQAVu5VigmvDyklwjEmutMWLvTzG(mKgTs50kwnrj61iPMnj3Mi7wYVfnCHCCbf1Yr1ZbnDPUosTDHQVtunELkcNhqRxPcZhG9JYUWDX6qewFxm7U3U7TNSyxzHE3WL9(HllCinWO7qImm1g6DiLjDhYoPAlvaDirgqvAcxSoeysZX3HS1Demm6QRIo9g9IgNsRchjAL1twyUb2Rchj8QoKf6r1Hbl3Idry9DXS7E7U3EYIDLf6Ddx2Y6(YQdbgDSlMDL9UoKTriE5wCiIdXoKWM53jvBPciZVZ7wVX87KRbDRzuf2mFyknknSz(DLfbW87U3U7XOIrvyZ8HjBwHEyyugvHnZVtz(WuH4cMpm0ucMFNJ)VJRzuf2m)oL5dtYk(59fmFBC03KbK5XzjMEYcY8DY88JsRmoZJZsm9KfuZOkSz(DkZhgWWJPGRUZLvZ8jiZhgoLFoZ3YVrnu7qudSHUyDihcFHp0fRlMWDX6qEzlQlCR7qW8PpFmhcNUUUhPt6KeoZldZJIfmFiMNtxdMeLYpN5xJ53FphIH7jlhI0Lsoqscsu04rqe8Bsqx7IzxxSoKx2I6c36oemF6ZhZHiU1BeReeXXgqDpyQNcL5baG5JERTOetq3sAL2W9e)mFiM3W9e)KxxAoK5PW8H7qmCpz5qwuzkijiP3o51La6AxmYQlwhYlBrDHBDhcMp95J5qcK5XzQeP8sBrj2uaJGxZVKnfK5xJ5dlMpeZJZujs5L24sajjiP3orCtO5xYMcY8YW84mvIuEPXzjEbVGOgWdMC818lztbz(GyEaayECMkrkV0gxcijbj92jIBcn)s2uqMFnMFxMhaaMhNCoDupzb1tDqqBrDsZP7n9lBrDHdXW9KLdbL24IXkscsSDCE2BU2fZ(UyDiVSf1fU1Diy(0NpMdzHgeuZpMA1HqcyYXxthX8aaW8l0GGA(XuRoesato(eCsx95AyByQz(1y(Wd3Hy4EYYH0BNqxljDjiGjhFx7Ir2UyDiVSf1fU1Diy(0NpMdjyMxCR3iwjiIJnG6EWupfQdXW9KLdbmX0Wli2ooF6twUj5AxmHLlwhYlBrDHBDhcMp95J5qezRXzHF1CRVGaQmPtwO5LMFjBkiZtH53ZHy4EYYHGZc)Q5wFbbuzs31Uy2zUyDiVSf1fU1Diy(0NpMdjyMxCR3iwjiIJnG6EWupfQdXW9KLdjIMpGaNcLSOmy7AxmYcxSoKx2I6c36oemF6ZhZH0M6vRnUeqscs6TteMuDH(LTOUG5dX8hcFHVo(aNSijij6CWJ7jlT0ujN5dX8l0GGA6AlvajWM)cT300rmpaam)HWx4RJpWjlscsIoh84EYslnvYz(qmF0BTfLyc6wsR0gUN4N5baG5Bt9Q1gxcijbj92jctQUq)YwuxW8Hy(O3AlkXe0TKwPnCpXpZhI5XzQeP8sBCjGKeK0BNiUj08lztbzEzy(WApMhaaMVn1RwBCjGKeK0BNimP6c9lBrDbZhI5JERnUeqc6wsR0gUN43Hy4EYYHip5kr8pfHFywwHVRDXeg7I1H8Ywux4w3HG5tF(yoKGzEXTEJyLGio2aQ7bt9uOmFiMFHgeutxBPcib28xO9MMoI5dX8bZ8hcFHVo(aNSijij6CWJ7jlT0ujN5dX8bZ8TPE1AJlbKKGKE7eHjvxOFzlQlyEaay(24OV19iDsNeXCMFnMhNPsKYlTfLytbmcEn)s2uqhIH7jlhI8KReX)ue(Hzzf(U2ft475I1H8Ywux4w3HG5tF(yoKGzEXTEJyLGio2aQ7bt9uOoed3twoe(efPozkcmYW31UycpCxSoed3twoe(TOPqjGkt6qhYlBrDHBDx7AhI4GgTQDX6IjCxSoed3twoePPeeq()oUd5LTOUWTURDXSRlwhYlBrDHBDhsg5qGVDigUNSCiXn(ylQ7qIBk67qWzQeP8sdPLKYIGAC0eO6A(LSPGm)AmVSz(qmFBQxTgsljLfb14Ojq11VSf1foK4gNuM0DirzQMcLaMCcQXrtGQ7AxmYQlwhYlBrDHBDhcMp95J5q401GjrP8Z1Ido4PzEzy(Ws2mFiMpqMp6Tg14Ojq11gUN4N5baG5dM5Bt9Q1qAjPSiOghnbQU(LTOUG5dI5dX8C66AXbh80mVmuyEz7qmCpz5qmo2Qt6KZF1U2fZ(UyDiVSf1fU1Diy(0NpMdj6Tg14Ojq11gUN4N5baG5dM5Bt9Q1qAjPSiOghnbQU(LTOUWHy4EYYHSOYuqaP5aDTlgz7I1H8Ywux4w3HG5tF(yoKfAqqnDTLkGedcnAvRPJyEaay(O3AuJJMavxB4EIFMhaaMpqMVn1RwBCjGKeK0BNimP6c9lBrDbZhI5JERTOetq3sAL2W9e)mFqoed3twoKLZHNt9uOU2fty5I1H8Ywux4w3HG5tF(yoKaz(fAqqnDTLkGeyZFH2BA6iMpeZVqdcQbpSpxAq3An)s2uqMFnkmVSz(GyEaayEd3t8tEDP5qMxgkm)UmFiMpqMFHgeutxBPcib28xO9MMoI5baG5xObb1Gh2NlnOBTMFjBkiZVgfMx2mFqoed3twoe1GU1qISKwGk9QDTlMDMlwhYlBrDHBDhcMp95J5qcK5JERrnoAcuDTH7j(z(qmFBQxTgsljLfb14Ojq11VSf1fmFqmpaamF0BTfLyc6wsR0gUN43Hy4EYYHyf(WMBkc2ukx7Irw4I1H8Ywux4w3HG5tF(yoed3t8tEDP5qMxgkm)UmpaamFGmpNUUwCWbpnZldfMx2mFiMNtxdMeLYpxlo4GNM5LHcZhw7X8b5qmCpz5qmo2QtIOvW7AxmHXUyDiVSf1fU1Diy(0NpMdjqMp6Tg14Ojq11gUN4N5dX8TPE1AiTKuweuJJMavx)YwuxW8bX8aaW8rV1wuIjOBjTsB4EIFhIH7jlhc4W)IktHRDXe(EUyDiVSf1fU1Diy(0NpMdzHgeutxBPcib28xO9MMoI5dX8gUN4N86sZHmpfMpCMhaaMFHgeudEyFU0GU1A(LSPGm)AmpkwW8HyEd3t8tEDP5qMNcZhUdXW9KLdzXqjjiP5dMAORDXeE4UyDiVSf1fU1Diy(0NpMdPhPZ8YW87UhZdaaZhmZ)Wm9efDHMBsrtHsmPi100ItqhulEQAYl0PoZdaaZhmZ)Wm9efDHo(aNSijirCPbEhIH7jlhcn8KPVe01UycFxxSoKx2I6c36oed3twoeBhWnJBqcywnjbjrP8ZDiy(0NpMdjqM)q4l81Xh4KfjbjrNdECpzPFzlQly(qmFWmFBQxTMU2sfqIbHgTQ1VSf1fmFqmpaamFGmFWm)HWx4RXzjEbVGOgWdMC81sMSm5mFiMpyM)q4l81Xh4KfjbjrNdECpzPFzlQly(GCiLjDhITd4MXnibmRMKGKOu(5U2ft4YQlwhYlBrDHBDhIH7jlhITd4MXnibmRMKGKOu(5oemF6ZhZHGZujs5L2IsSPagbVMFjBkiZVgZh((mFiMpqM)q4l814SeVGxqud4bto(AjtwMCMhaaM)q4l81Xh4KfjbjrNdECpzPFzlQly(qmFBQxTMU2sfqIbHgTQ1VSf1fmFqoKYKUdX2bCZ4gKaMvtsqsuk)Cx7Ij89DX6qEzlQlCR7qmCpz5qSDa3mUbjGz1KeKeLYp3HG5tF(yoKEKoPtIyoZVgZJZujs5L2IsSPagbVMFjBkiZVcZlR77qkt6oeBhWnJBqcywnjbjrP8ZDTlMWLTlwhYlBrDHBDhIH7jlhIb3IB1HeUTJKtWj3uoemF6ZhZHi(cniOMB7i5eCYnfr8fAqqnSnm1m)AmF4oKYKUdXGBXT6qc32rYj4KBkx7Ij8WYfRd5LTOUWTUdXW9KLdXGBXT6qc32rYj4KBkhcMp95J5qIERrPnUySIKGeBhNN9M2W9e)mFiMp6T2IsmbDlPvAd3t87qkt6oedUf3QdjCBhjNGtUPCTlMW3zUyDiVSf1fU1DigUNSCigClUvhs42osobNCt5qW8PpFmhcotLiLxAlkXMcye8A(nbqMpeZhiZFi8f(ACwIxWliQb8GjhFTKjltoZhI57r6KojI5m)AmpotLiLxACwIxWliQb8GjhFn)s2uqMFfMF39yEaay(Gz(dHVWxJZs8cEbrnGhm54RLmzzYz(GCiLjDhIb3IB1HeUTJKtWj3uU2ft4YcxSoKx2I6c36oed3twoedUf3QdjCBhjNGtUPCiy(0NpMdPhPt6KiMZ8RX84mvIuEPTOeBkGrWR5xYMcY8RW87UNdPmP7qm4wCRoKWTDKCco5MY1Uycpm2fRd5LTOUWTUdXW9KLdj(aNSijirCPbEhcMp95J5qcK5XzQeP8sBrj2uaJGxZVjaY8HyEXxObb1Gh2NpfkrEsxcnSnm1mVmuy(9z(qm)HWx4RJpWjlscsIoh84EYs)YwuxW8bX8aaW8l0GGA6AlvajgeA0QwthX8aaW8rV1OghnbQU2W9e)oKYKUdj(aNSijirCPbEx7Iz39CX6qEzlQlCR7qmCpz5q4Mu0uOetksnnT4e0b1INQM8cDQ7qW8PpFmhcotLiLxAlkXMcye8A(LSPGm)Am)UmpaamFBQxT24sajjiP3orys1f6x2I6cMhaaMNBJG84VATjeq9um)AmVSDiLjDhc3KIMcLysrQPPfNGoOw8u1KxOtDx7Iz3WDX6qEzlQlCR7qmCpz5qwaIM1jl)etjzLHDiy(0NpMdbNPsKYlnKwsklcQXrtGQR5xYMcY8YW8H1EmpaamFWmFBQxTgsljLfb14Ojq11VSf1fmFiMVhPZ8YW87UhZdaaZhmZ)Wm9efDHMBsrtHsmPi100ItqhulEQAYl0PUdPmP7qwaIM1jl)etjzLHDTlMD31fRd5LTOUWTUdXW9KLdrwEizlLRo3HG5tF(yoKO3AuJJMavxB4EIFMhaaMpyMVn1RwdPLKYIGAC0eO66x2I6cMpeZ3J0zEzy(D3J5baG5dM5FyMEIIUqZnPOPqjMuKAAAXjOdQfpvn5f6u3HuM0DiYYdjBPC15U2fZUYQlwhYlBrDHBDhIH7jlhcQPo2uQZHKLBu7qW8PpFmhs0BnQXrtGQRnCpXpZdaaZhmZ3M6vRH0sszrqnoAcuD9lBrDbZhI57r6mVmm)U7X8aaW8bZ8pmtprrxO5Mu0uOetksnnT4e0b1INQM8cDQ7qkt6oeutDSPuNdjl3O21Uy2DFxSoKx2I6c36oed3twoeuEwOqseFKmfHBO3HG5tF(yoeoDDMFnkmVSY8Hy(az(EKoZldZV7EmpaamFWm)dZ0tu0fAUjfnfkXKIuttlobDqT4PQjVqN6mFqoKYKUdbLNfkKeXhjtr4g6DTlMDLTlwhYlBrDHBDhcMp95J5qWzQeP8sBCjGKeK0BNiUj08BcGmpaamF0BnQXrtGQRnCpXpZdaaZVqdcQPRTubKyqOrRAnDKdXW9KLdjk7jlx7Iz3WYfRd5LTOUWTUdbZN(8XCiIS1XhoT6vtIugk918lztbz(1OW8OyHdXW9KLdjP7f(nQDTlMD3zUyDiVSf1fU1DigUNSCiytPigUNSiQb2oe1aBszs3HCi8f(qx7IzxzHlwhYlBrDHBDhIH7jlhc2ukIH7jlIAGTdrnWMuM0Di4mvIuEbDTlMDdJDX6qEzlQlCR7qW8PpFmhIH7j(jVU0CiZldfMFxhcS5dUDXeUdXW9KLdbBkfXW9KfrnW2HOgytkt6oelVRDXiR75I1H8Ywux4w3HG5tF(yoed3t8tEDP5qMNcZhUdb28b3Uyc3Hy4EYYHGnLIy4EYIOgy7qudSjLjDhc6RZhSRDXiRH7I1H8Ywux4w3Hy4EYYHaEyF(uOeyZhQVdbZN(8XCiIVqdcQbpSpFkuI8KUeAyByQz(1y(9DiyGy1jTXrFdDXeURDTdjIFCkTyTlwxmH7I1Hy4EYYHeL9KLd5LTOUWTURDXSRlwhIH7jlhc3g4jIBchYlBrDHBDx7IrwDX6qEzlQlCR7qkt6oeBhWnJBqcywnjbjrP8ZDigUNSCi2oGBg3GeWSAscsIs5N7Axm77I1H8Ywux4w3HiUYa6q21Hy4EYYHyCjGKeK0BNiUjCTRDi4mvIuEbDX6IjCxSoed3twoeJlbKKGKE7eXnHd5LTOUWTURDXSRlwhYlBrDHBDhcMp95J5qeFHgeudEyF(uOe5jDj0W2WuZ8YqH53N5dX8bY8gUN4N86sZHmVmuy(DzEaay(Gz(dHVWxhFGtwKeKeDo4X9KL(LTOUG5baG5dM5TDC(0xlzO0qscs6Tte3e6x2I6cMhaaM)q4l81Xh4KfjbjrNdECpzPFzlQly(qmFGmFBQxTMU2sfqIbHgTQ1VSf1fmFiMhNPsKYlnDTLkGedcnAvR5xYMcY8RrH5LvMhaaMpyMVn1RwtxBPciXGqJw16x2I6cMpiMpihIH7jlhIfLytbmcEx7IrwDX6qEzlQlCR7qW8PpFmhsWmp3gb5XF1AtiG6VtmWgY8aaW8CBeKh)vRnHaQNI5LH5dx2oed3twoeHXPM0CRGGjxY6jlx7IzFxSoKx2I6c36oemF6ZhZHWPRbtIs5NRfhCWtZ8RX8HVVdXW9KLdbsljLfb14Ojq1DTlgz7I1H8Ywux4w3HG5tF(yoKdHVWxhFGtwKeKeDo4X9KL(LTOUG5dX8rV1wuIjOBjTsB4EIFMhaaMx8fAqqn4H95tHsKN0LqdBdtnZVgZVpZhI5dM5pe(cFD8bozrsqs05Gh3tw6x2I6cMpeZhiZhmZB748PVwYqPHKeK0BNiUj0VSf1fmpaamVTJZN(AjdLgssqsVDI4Mq)YwuxW8Hy(O3AlkXe0TKwPnCpXpZhKdXW9KLdHU2sfqIbHgTQDTlMWYfRd5LTOUWTUdbZN(8XCigUN4N86sZHmVmuy(Dz(qmFGmFGmpotLiLxAXTEJyLGio2aQ5xYMcY8RrH5rXcMpeZhmZ3M6vRfhCux)YwuxW8bX8aaW8bY84mvIuEPfhCuxZVKnfK5xJcZJIfmFiMVn1Rwlo4OU(LTOUG5dI5dYHy4EYYHqxBPciXGqJw1U2fZoZfRd5LTOUWTUdbZN(8XCiTXrFR7r6KojI5mVmmF477qmCpz5qGBgMA1j92j0L8K3BaDTlgzHlwhYlBrDHBDhcMp95J5qmCpXp51LMdzEzy(DDigUNSCi2sknL1twe1iT4AxmHXUyDiVSf1fU1Diy(0NpMdXW9e)KxxAoK5LH531Hy4EYYHaLBCPPqjsdSDTlMW3ZfRd5LTOUWTUdXW9KLdbM0kc)w05oemF6ZhZH0gh9TUhPt6KiMZ8RX8YcMpeZ3gh9TUhPt6KiMZ8YW877qWaXQtAJJ(g6IjCx7Ij8WDX6qEzlQlCR7qW8PpFmhsGmFWmp3gb5XF1AtiG6VtmWgY8aaW8CBeKh)vRnHaQNI5LH53DpMpiMpeZZPRZ8RrH5dK5dN53Pm)cniOMU2sfqIbHgTQ10rmFqoed3twoeysRi8BrN7AxmHVRlwhIH7jlhcDTLkGKf1GU1oKx2I6c36U21oe0xNpyxSUyc3fRd5LTOUWTUdbZN(8XCil0GGAiTq8IiYusZVHBMpeZZPRR7r6Koj7Z8YW8OybZhI5dM5JB8XwuxhLPAkucyYjOghnbQoZdaaZh9wJAC0eO6Ad3t87qmCpz5qe36ncohLRDXSRlwhYlBrDHBDhcMp95J5q401GjrP8Z1Ido4Pz(1y(W3N5dX8C666EKoPtY(mVmmpkwW8Hy(Gz(4gFSf11rzQMcLaMCcQXrtGQ7qmCpz5qe36ncohLRDXiRUyDiVSf1fU1Diy(0NpMdjqMpqMx8fAqqn4H95tHsKN0LqthX8Hy(azECMkrkV0wuInfWi418lztbzEzyEzZ8Hy(az(Gz(dHVWxhFGtwKeKeDo4X9KL(LTOUG5baG5dM5Bt9Q101wQasmi0OvT(LTOUG5dI5baG5pe(cFD8bozrsqs05Gh3tw6x2I6cMpeZ3M6vRPRTubKyqOrRA9lBrDbZhI5XzQeP8stxBPciXGqJw1A(LSPGmVmmFyX8bX8bX8aaW8IVqdcQbpSpFkuI8KUeAyByQzEzy(9z(Gy(qmFGmpotLiLxAJlbKKGKE7eXnHMFjBkiZldZlBMhaaMxCR3iuxd6wRfd0wuNyzly(GCigUNSCiqCsZrpb28H67Axm77I1H8Ywux4w3HG5tF(yoKaz(azEXxObb1Gh2NpfkrEsxcnDeZhI5dK5XzQeP8sBrj2uaJGxZVKnfK5LH5LnZhI5dK5dM5pe(cFD8bozrsqs05Gh3tw6x2I6cMhaaMpyMVn1RwtxBPciXGqJw16x2I6cMpiMhaaM)q4l81Xh4KfjbjrNdECpzPFzlQly(qmFBQxTMU2sfqIbHgTQ1VSf1fmFiMhNPsKYlnDTLkGedcnAvR5xYMcY8YW8HfZheZheZdaaZl(cniOg8W(8PqjYt6sOHTHPM5LH53N5dI5dX8bY84mvIuEPnUeqscs6Tte3eA(LSPGmVmmVSzEaayEXTEJqDnOBTwmqBrDILTG5dYHy4EYYHGvM8PqjWntKYHU2fJSDX6qEzlQlCR7qW8PpFmhcNUgmjkLFUwCWbpnZVgZV7EmFiMpyMpUXhBrDDuMQPqjGjNGAC0eO6oed3twoeXTEJGZr5AxmHLlwhYlBrDHBDhcMp95J5qeFHgeudEyF(uOe5jDj0W2WuZ8RX87Z8Hy(azECMkrkV0wuInfWi418lztbz(1yEzL5dX8bY8bZ8hcFHVo(aNSijij6CWJ7jl9lBrDbZdaaZhmZ3M6vRPRTubKyqOrRA9lBrDbZdaaZFi8f(64dCYIKGKOZbpUNS0VSf1fmFiMVn1RwtxBPciXGqJw16x2I6cMpeZJZujs5LMU2sfqIbHgTQ18lztbz(1y(DgZheZheZdaaZl(cniOg8W(8PqjYt6sOHTHPM5xJ5dN5dX8bY84mvIuEPnUeqscs6Tte3eA(LSPGmVmmVSzEaayEXTEJqDnOBTwmqBrDILTG5dYHy4EYYHaEyF(uOeyZhQVRDXSZCX6qEzlQlCR7qW8PpFmhsWmFCJp2I66OmvtHsatob14Ojq1DigUNSCiIB9gbNJY1U2Hy5DX6IjCxSoKx2I6c36oemF6ZhZHGZujs5L2IsSPagbVMFjBkiZhI5nCpXprKTg8W(8PqjYt6sW8YW875qmCpz5qe36nIvcI4ydORDXSRlwhYlBrDHBDhcMp95J5qWzQeP8sBrj2uaJGxZVKnfK5dX8gUN4NiYwdEyF(uOe5jDjyEzy(9CigUNSCiIdoQ7AxmYQlwhYlBrDHBDhcMp95J5qWzQeP8sBrj2uaJGxZVKnfK5dX8gUN4NiYwdEyF(uOe5jDjyEzy(9CigUNSCiIB9gKiOVRDXSVlwhYlBrDHBDhcMp95J5qe36nIvcI4ydOUhm1tHY8HyEoDnysuk)CT4GdEAMFnMp89z(qmFWmFBQxTEHMd7PqjWKFO(LTOUG5dX8bZ8Xn(ylQRJYunfkbm5euJJMav3Hy4EYYH8OrCPb7AxmY2fRd5LTOUWTUdbZN(8XCiIB9gXkbrCSbu3dM6Pqz(qmFGmFWmV4wVrOUg0TwdkpPlXfK24OVHmFiMVn1RwVqZH9uOeyYpu)YwuxW8bX8Hy(Gz(4gFSf11rzQMcLaMCcQXrtGQ7qmCpz5qE0iU0GDTlMWYfRd5LTOUWTUdbZN(8XCiIB9gXkbrCSbu3dM6Pqz(qmpotLiLxAlkXMcye8A(LSPGoed3twoeioP5ONaB(q9DTlMDMlwhYlBrDHBDhcMp95J5qe36nIvcI4ydOUhm1tHY8HyECMkrkV0wuInfWi418lztbDigUNSCiyLjFkucCZePCORDXilCX6qEzlQlCR7qW8PpFmhsWmFCJp2I66OmvtHsatob14Ojq1DigUNSCipAexAWU2ftySlwhYlBrDHBDhIH7jlhc4H95tHsGnFO(oemF6ZhZHi(cniOg8W(8PqjYt6sOHTHPM5xJcZVlZhI5XzQeP8slU1BeReeXXgqn)s2uqMpeZJZujs5L2IsSPagbVMFjBkiZldZlBMpeZhiZJZujs5L24sajjiP3orCtO5xYMcY8YW8YM5baG5f36nc11GU1AXaTf1jw2cMpihcgiwDsBC03qxmH7AxmHVNlwhYlBrDHBDhcMp95J5qwObb1qAH4frKPKMFd3mFiMNtxx3J0jDs2N5LH5rXchIH7jlhI4wVrW5OCTlMWd3fRd5LTOUWTUdbZN(8XCil0GGAiTq8IiYusZVHBMpeZhmZh34JTOUokt1uOeWKtqnoAcuDMhaaMp6Tg14Ojq11gUN43Hy4EYYHiU1BeCokx7Ij8DDX6qEzlQlCR7qW8PpFmhcNUgmjkLFUwCWbpnZVgZh((mFiMpqMhNPsKYlTfLytbmcEn)s2uqMxgMx2mpaamV4l0GGAWd7ZNcLipPlHg2gMAMxgMFFMpiMpeZhmZh34JTOUokt1uOeWKtqnoAcuDhIH7jlhI4wVrW5OCTlMWLvxSoKx2I6c36oed3twoeioP5ONaB(q9Diy(0NpMdjqMpqMhNPsKYlTXLassqsVDI4MqZVKnfK5LH5LnZdaaZlU1BeQRbDR1IbAlQtSSfmFqmFiMpqMhNPsKYlTfLytbmcEn)s2uqMxgMx2mFiMx8fAqqn4H95tHsKN0LqdBdtnZldZVhZdaaZl(cniOg8W(8PqjYt6sOHTHPM5LH53N5dI5dX8bY89iDsNeXCMFnMhNPsKYlT4wVrSsqehBa18lztbz(vy(W3J5baG57r6KojI5mVmmpotLiLxAlkXMcye8A(LSPGmFqmFqoemqS6K24OVHUyc31UycFFxSoKx2I6c36oed3twoeSYKpfkbUzIuo0HG5tF(yoKaz(azECMkrkV0gxcijbj92jIBcn)s2uqMxgMx2mpaamV4wVrOUg0TwlgOTOoXYwW8bX8Hy(azECMkrkV0wuInfWi418lztbzEzyEzZ8HyEXxObb1Gh2NpfkrEsxcnSnm1mVmm)EmpaamV4l0GGAWd7ZNcLipPlHg2gMAMxgMFFMpiMpeZhiZ3J0jDseZz(1yECMkrkV0IB9gXkbrCSbuZVKnfK5xH5dFpMhaaMVhPt6KiMZ8YW84mvIuEPTOeBkGrWR5xYMcY8bX8b5qWaXQtAJJ(g6IjCx7IjCz7I1H8Ywux4w3HG5tF(yoeoDnysuk)CT4GdEAMFnMF39y(qmFWmFCJp2I66OmvtHsatob14Ojq1DigUNSCiIB9gbNJY1UycpSCX6qEzlQlCR7qW8PpFmhsGmFGmFGmFGmV4l0GGAWd7ZNcLipPlHg2gMAMFnMFFMpeZhmZVqdcQPRTubKyqOrRAnDeZheZdaaZl(cniOg8W(8PqjYt6sOHTHPM5xJ5LvMpiMpeZJZujs5L2IsSPagbVMFjBkiZVgZlRmFqmpaamV4l0GGAWd7ZNcLipPlHg2gMAMFnMpCMpiMpeZhiZJZujs5L24sajjiP3orCtO5xYMcY8YW8YM5baG5f36nc11GU1AXaTf1jw2cMpihIH7jlhc4H95tHsGnFO(U2ft47mxSoKx2I6c36oemF6ZhZHiU1BeReeXXgqDpyQNc1Hy4EYYHaXjnh9eyZhQVRDXeUSWfRd5LTOUWTUdbZN(8XCibZ8Xn(ylQRJYunfkbm5euJJMav3Hy4EYYHiU1BeCokx7Ax7qIFoCYYfZU7T7E7fwHVVdrUXRPqHoKWGsrjVVG5dlM3W9KfZRgyd1mQCigDVLChcYirRSEYkmHBGTdjINGJ6oKWM53jvBPciZVZ7wVX87KRbDRzuf2mFyknknSz(DLfbW87U3U7XOIrvyZ8HjBwHEyyugvHnZVtz(WuH4cMpm0ucMFNJ)VJRzuf2m)oL5dtYk(59fmFBC03KbK5XzjMEYcY8DY88JsRmoZJZsm9KfuZOkSz(DkZhgWWJPGRUZLvZ8jiZhgoLFoZ3YVrnuZOIrvyZ8Hr2joMUVG5xoyYpZJtPfRz(LJofuZ8HPy8JAiZxzTt3mUeiTI5nCpzbz(Sua1mQcBM3W9KfuhXpoLwSMcOYGuZOkSzEd3twqDe)4uAX6vOSkyMcgvHnZB4EYcQJ4hNslwVcLvnAuPxT1twmQcBMhPSi4w2mp3gbZVqdcEbZdBRHm)Ybt(zECkTynZVC0PGmVvcMpI)DAu29uOm)azErwxZOkSzEd3twqDe)4uAX6vOSkSSi4w2eyBnKrLH7jlOoIFCkTy9kuwnk7jlgvgUNSG6i(XP0I1RqzvUnWte3emQmCpzb1r8JtPfRxHYQ0WtM(sbuM0Py7aUzCdsaZQjjijkLFoJkd3twqDe)4uAX6vOSQXLassqsVDI4MiaXvgqk7YOIrvyZ8Hr2joMUVG5F8ZbY89iDMV3oZB4o5m)azElUnkBrDnJkd3twqkstjiG8)DCgvgUNSGRqz14gFSf1dOmPtjkt1uOeWKtqnoAcu9aIBk6tbNPsKYlnKwsklcQXrtGQR5xYMcUMSd1M6vRH0sszrqnoAcuD9lBrDbJQWM5ddy4XuWay(WG9LGbW8wjy(S3oN5tuSaYOYW9KfCfkRACSvN0jN)QdyaPWPRbtIs5NRfhCWtltyj7qbg9wJAC0eO6Ad3t8daqWTPE1AiTKuweuJJMavx)YwuxeuioDDT4GdEAzOiBgvgUNSGRqz1fvMccinhyadiLO3AuJJMavxB4EIFaacUn1RwdPLKYIGAC0eO66x2I6cgvgUNSGRqz1LZHNt9uObmGuwObb101wQasmi0OvTMocaGO3AuJJMavxB4EIFaacSn1RwBCjGKeK0BNimP6c9lBrDrOO3AlkXe0TKwPnCpXFqmQmCpzbxHYQQbDRHezjTav6vhWasjWfAqqnDTLkGeyZFH2BA6Oql0GGAWd7ZLg0TwZVKnfCnkYoiaamCpXp51LMdLHYUHcCHgeutxBPcib28xO9MMocaGfAqqn4H95sd6wR5xYMcUgfzheJkd3twWvOSQv4dBUPiytPcyaPey0BnQXrtGQRnCpXFO2uVAnKwsklcQXrtGQRFzlQlccaGO3AlkXe0TKwPnCpXpJkd3twWvOSQXXwDseTc(agqkgUN4N86sZHYqzxaacKtxxlo4GNwgkYoeNUgmjkLFUwCWbpTmucR9cIrLH7jl4kuwfC4FrLPiGbKsGrV1OghnbQU2W9e)HAt9Q1qAjPSiOghnbQU(LTOUiiaaIERTOetq3sAL2W9e)mQmCpzbxHYQlgkjbjnFWuddyaPSqdcQPRTubKaB(l0EtthfYW9e)KxxAoKs4aaSqdcQbpSpxAq3An)s2uW1qXIqgUN4N86sZHucNrfJQWM5dtOHDkX8nFkQFdzEAOHEgvgUNSGRqzvA4jtFjyadiLEKUm7Uhaab)Wm9efDHMBsrtHsmPi100ItqhulEQAYl0Poaab)Wm9efDHo(aNSijirCPbEgvgUNSGRqzvA4jtFPakt6uSDa3mUbjGz1KeKeLYppGbKsGhcFHVo(aNSijij6CWJ7jl9lBrDrOGBt9Q101wQasmi0OvT(LTOUiiaacm4dHVWxJZs8cEbrnGhm54RLmzzYdf8HWx4RJpWjlscsIoh84EYs)YwuxeeJkd3twWvOSkn8KPVuaLjDk2oGBg3GeWSAscsIs5NhWasbNPsKYlTfLytbmcEn)s2uW1cF)qbEi8f(ACwIxWliQb8GjhFTKjltoaahcFHVo(aNSijij6CWJ7jl9lBrDrO2uVAnDTLkGedcnAvRFzlQlcIrLH7jl4kuwLgEY0xkGYKofBhWnJBqcywnjbjrP8ZdyaP0J0jDseZxdNPsKYlTfLytbmcEn)s2uWvK19zuz4EYcUcLvPHNm9LcOmPtXGBXT6qc32rYj4KBQagqkIVqdcQ52osobNCtreFHgeudBdt9AHZOYW9KfCfkRsdpz6lfqzsNIb3IB1HeUTJKtWj3ubmGuIERrPnUySIKGeBhNN9M2W9e)HIERTOetq3sAL2W9e)mQmCpzbxHYQ0WtM(sbuM0PyWT4wDiHB7i5eCYnvadifCMkrkV0wuInfWi418BcGHc8q4l814SeVGxqud4bto(AjtwM8q9iDsNeX81WzQeP8sJZs8cEbrnGhm54R5xYMcUYU7baqWhcFHVgNL4f8cIAapyYXxlzYYKheJkd3twWvOSkn8KPVuaLjDkgClUvhs42osobNCtfWasPhPt6KiMVgotLiLxAlkXMcye8A(LSPGRS7EmQmCpzbxHYQ0WtM(sbuM0PeFGtwKeKiU0aFadiLaXzQeP8sBrj2uaJGxZVjags8fAqqn4H95tHsKN0LqdBdtTmu2p0HWx4RJpWjlscsIoh84EYs)Ywuxeeaal0GGA6AlvajgeA0Qwthbaq0BnQXrtGQRnCpXpJkd3twWvOSkn8KPVuaLjDkCtkAkuIjfPMMwCc6GAXtvtEHo1dyaPGZujs5L2IsSPagbVMFjBk4A7caqBQxT24sajjiP3orys1f6x2I6caa42iip(RwBcbup1AYMrLH7jl4kuwLgEY0xkGYKoLfGOzDYYpXuswz4agqk4mvIuEPH0sszrqnoAcuDn)s2uqzcR9aai42uVAnKwsklcQXrtGQRFzlQlc1J0Lz39aai4hMPNOOl0CtkAkuIjfPMMwCc6GAXtvtEHo1zuz4EYcUcLvPHNm9LcOmPtrwEizlLRopGbKs0BnQXrtGQRnCpXpaab3M6vRH0sszrqnoAcuD9lBrDrOEKUm7Uhaab)Wm9efDHMBsrtHsmPi100ItqhulEQAYl0PoJkd3twWvOSkn8KPVuaLjDkOM6ytPohswUrDadiLO3AuJJMavxB4EIFaacUn1RwdPLKYIGAC0eO66x2I6Iq9iDz2Dpaac(Hz6jk6cn3KIMcLysrQPPfNGoOw8u1KxOtDgvgUNSGRqzvA4jtFPakt6uq5zHcjr8rYueUH(agqkC66RrrwdfypsxMD3daGGFyMEIIUqZnPOPqjMuKAAAXjOdQfpvn5f6upigvgUNSGRqz1OSNScyaPGZujs5L24sajjiP3orCtO53eabai6Tg14Ojq11gUN4haGfAqqnDTLkGedcnAvRPJyuf2mFyiBQ2MAkuMFN)WPvVAMpmSYqPpZpqM3y(i(K8PbYOYW9KfCfkRM09c)g1bmGuezRJpCA1RMePmu6R5xYMcUgfuSGrLH7jl4kuwfBkfXW9KfrnWoGYKoLdHVWhYOYW9KfCfkRInLIy4EYIOgyhqzsNcotLiLxqgvgUNSGRqzvSPued3twe1a7aGnFWnLWdOmPtXYhWasXW9e)KxxAougk7YOYW9KfCfkRInLIy4EYIOgyhaS5dUPeEaLjDkOVoFWbmGumCpXp51LMdPeoJkd3twWvOSk4H95tHsGnFO(bGbIvN0gh9nKs4bmGueFHgeudEyF(uOe5jDj0W2WuV2(mQyuf2mFyAggH55zB9KfJkd3twqTLNI4wVrSsqehBadyaPGZujs5L2IsSPagbVMFjBkyid3t8tezRbpSpFkuI8KUeYShJkd3twqTLFfkRko4OEadifCMkrkV0wuInfWi418lztbdz4EIFIiBn4H95tHsKN0LqM9yuz4EYcQT8RqzvXTEdse0pGbKcotLiLxAlkXMcye8A(LSPGHmCpXprKTg8W(8PqjYt6siZEmQmCpzb1w(vOS6JgXLgCadifXTEJyLGio2aQ7bt9uOH401GjrP8Z1Ido4Pxl89dfCBQxTEHMd7PqjWKFO(LTOUiuWXn(ylQRJYunfkbm5euJJMavNrLH7jlO2YVcLvF0iU0GdyaPiU1BeReeXXgqDpyQNcnuGblU1BeQRbDR1GYt6sCbPno6ByO2uVA9cnh2tHsGj)q9lBrDrqHcoUXhBrDDuMQPqjGjNGAC0eO6mQmCpzb1w(vOSkeN0C0tGnFO(bmGue36nIvcI4ydOUhm1tHgcNPsKYlTfLytbmcEn)s2uqgvgUNSGAl)kuwfRm5tHsGBMiLddyaPiU1BeReeXXgqDpyQNcneotLiLxAlkXMcye8A(LSPGmQmCpzb1w(vOS6JgXLgCadiLGJB8XwuxhLPAkucyYjOghnbQoJkd3twqTLFfkRcEyF(uOeyZhQFayGy1jTXrFdPeEadifXxObb1Gh2NpfkrEsxcnSnm1Rrz3q4mvIuEPf36nIvcI4ydOMFjBkyiCMkrkV0wuInfWi418lztbLr2HceNPsKYlTXLassqsVDI4MqZVKnfugzdaG4wVrOUg0TwlgOTOoXYweeJkd3twqTLFfkRkU1BeCoQagqkl0GGAiTq8IiYusZVH7qC666EKoPtY(YGIfmQmCpzb1w(vOSQ4wVrW5OcyaPSqdcQH0cXlIitjn)gUdfCCJp2I66OmvtHsatob14Ojq1bai6Tg14Ojq11gUN4NrLH7jlO2YVcLvf36ncohvadifoDnysuk)CT4GdE61cF)qbIZujs5L2IsSPagbVMFjBkOmYgaaXxObb1Gh2NpfkrEsxcnSnm1YSFqHcoUXhBrDDuMQPqjGjNGAC0eO6mQmCpzb1w(vOSkeN0C0tGnFO(bGbIvN0gh9nKs4bmGucmqCMkrkV0gxcijbj92jIBcn)s2uqzKnaaIB9gH6Aq3ATyG2I6elBrqHceNPsKYlTfLytbmcEn)s2uqzKDiXxObb1Gh2NpfkrEsxcnSnm1YShaaIVqdcQbpSpFkuI8KUeAyByQLz)GcfypsN0jrmFnCMkrkV0IB9gXkbrCSbuZVKnfCLW3daGEKoPtIyUm4mvIuEPTOeBkGrWR5xYMcguqmQmCpzb1w(vOSkwzYNcLa3mrkhgagiwDsBC03qkHhWasjWaXzQeP8sBCjGKeK0BNiUj08lztbLr2aaiU1BeQRbDR1IbAlQtSSfbfkqCMkrkV0wuInfWi418lztbLr2HeFHgeudEyF(uOe5jDj0W2WulZEaai(cniOg8W(8PqjYt6sOHTHPwM9dkuG9iDsNeX81WzQeP8slU1BeReeXXgqn)s2uWvcFpaa6r6KojI5YGZujs5L2IsSPagbVMFjBkyqbXOYW9KfuB5xHYQIB9gbNJkGbKcNUgmjkLFUwCWbp9A7UxOGJB8XwuxhLPAkucyYjOghnbQoJkd3twqTLFfkRcEyF(uOeyZhQFadiLadmWafFHgeudEyF(uOe5jDj0W2WuV2(HcEHgeutxBPciXGqJw1A6OGaaq8fAqqn4H95tHsKN0LqdBdt9AYAqHWzQeP8sBrj2uaJGxZVKnfCnzniaaeFHgeudEyF(uOe5jDj0W2WuVw4bfkqCMkrkV0gxcijbj92jIBcn)s2uqzKnaaIB9gH6Aq3ATyG2I6elBrqmQmCpzb1w(vOSkeN0C0tGnFO(bmGue36nIvcI4ydOUhm1tHYOYW9KfuB5xHYQIB9gbNJkGbKsWXn(ylQRJYunfkbm5euJJMavNrfJkd3twqnotLiLxqkgxcijbj92jIBcgvgUNSGACMkrkVGRqzvlkXMcye8bmGueFHgeudEyF(uOe5jDj0W2WuldL9dfOH7j(jVU0COmu2faGGpe(cFD8bozrsqs05Gh3tw6x2I6caac22X5tFTKHsdjjiP3orCtOFzlQlaa4q4l81Xh4KfjbjrNdECpzPFzlQlcfyBQxTMU2sfqIbHgTQ1VSf1fHWzQeP8stxBPciXGqJw1A(LSPGRrrwbai42uVAnDTLkGedcnAvRFzlQlckigvgUNSGACMkrkVGRqzvHXPM0CRGGjxY6jRagqkbZTrqE8xT2ecO(7edSHaaWTrqE8xT2ecOEkzcx2mQmCpzb14mvIuEbxHYQqAjPSiOghnbQEadifoDnysuk)CT4GdE61cFFgvgUNSGACMkrkVGRqzv6AlvajgeA0QoGbKYHWx4RJpWjlscsIoh84EYs)Ywuxek6T2IsmbDlPvAd3t8daG4l0GGAWd7ZNcLipPlHg2gM612puWhcFHVo(aNSijij6CWJ7jl9lBrDrOad22X5tFTKHsdjjiP3orCtOFzlQlaaW2X5tFTKHsdjjiP3orCtOFzlQlcf9wBrjMGUL0kTH7j(dIrLH7jlOgNPsKYl4kuwLU2sfqIbHgTQdyaPy4EIFYRlnhkdLDdfyG4mvIuEPf36nIvcI4ydOMFjBk4AuqXIqb3M6vRfhCux)YwuxeeaabIZujs5LwCWrDn)s2uW1OGIfHAt9Q1IdoQRFzlQlckigvgUNSGACMkrkVGRqzv4MHPwDsVDcDjp59gWagqkTXrFR7r6KojI5Ye((mQmCpzb14mvIuEbxHYQ2sknL1twe1iTeWasXW9e)KxxAouMDzuz4EYcQXzQeP8cUcLvHYnU0uOePb2bmGumCpXp51LMdLzxgvgUNSGACMkrkVGRqzvysRi8BrNhagiwDsBC03qkHhWasPno6BDpsN0jrmFnzrO24OV19iDsNeXCz2NrLH7jlOgNPsKYl4kuwfM0kc)w05bmGucmyUncYJ)Q1Mqa1FNyGneaaUncYJ)Q1Mqa1tjZU7fuioD91Oey470fAqqnDTLkGedcnAvRPJcIrLH7jlOgNPsKYl4kuwLU2sfqYIAq3AgvmQmCpzb1hcFHpKI0Lsoqscsu04rqe8BsWagqkC666EKoPts4YGIfH401GjrP8ZxB)9yuz4EYcQpe(cF4kuwDrLPGKGKE7KxxcyadifXTEJyLGio2aQ7bt9uOaae9wBrjMGUL0kTH7j(dz4EIFYRlnhsjCgvgUNSG6dHVWhUcLvrPnUySIKGeBhNN9wadiLaXzQeP8sBrj2uaJGxZVKnfCTWkeotLiLxAJlbKKGKE7eXnHMFjBkOm4mvIuEPXzjEbVGOgWdMC818lztbdcaaCMkrkV0gxcijbj92jIBcn)s2uW12faaCY50r9Kfup1bbTf1jnNU30VSf1fmQmCpzb1hcFHpCfkR2BNqxljDjiGjh)agqkl0GGA(XuRoesato(A6iaawObb18JPwDiKaMC8j4KU6Z1W2WuVw4HZOYW9KfuFi8f(WvOSkyIPHxqSDC(0NSCtkGbKsWIB9gXkbrCSbu3dM6Pqzuz4EYcQpe(cF4kuwfNf(vZT(ccOYKEadifr2ACw4xn36liGkt6KfAEP5xYMcszpgvgUNSG6dHVWhUcLvJO5diWPqjlkd2bmGucwCR3iwjiIJnG6EWupfkJkd3twq9HWx4dxHYQYtUse)tr4hMLv4hWasPn1RwBCjGKeK0BNimP6c9lBrDrOdHVWxhFGtwKeKeDo4X9KLwAQKhAHgeutxBPcib28xO9MMocaGdHVWxhFGtwKeKeDo4X9KLwAQKhk6T2IsmbDlPvAd3t8daqBQxT24sajjiP3orys1f6x2I6IqrV1wuIjOBjTsB4EI)q4mvIuEPnUeqscs6Tte3eA(LSPGYew7baqBQxT24sajjiP3orys1f6x2I6IqrV1gxcibDlPvAd3t8ZOYW9KfuFi8f(WvOSQ8KReX)ue(Hzzf(bmGucwCR3iwjiIJnG6EWupfAOfAqqnDTLkGeyZFH2BA6OqbFi8f(64dCYIKGKOZbpUNS0stL8qb3M6vRnUeqscs6TteMuDH(LTOUaaG24OV19iDsNeX81WzQeP8sBrj2uaJGxZVKnfKrLH7jlO(q4l8HRqzv(efPozkcmYWpGbKsWIB9gXkbrCSbu3dM6Pqzuz4EYcQpe(cF4kuwLFlAkucOYKoKrfJkd3twqn6RZhmfXTEJGZrfWaszHgeudPfIxerMsA(nChItxx3J0jDs2xguSiuWXn(ylQRJYunfkbm5euJJMavhaGO3AuJJMavxB4EIFgvgUNSGA0xNp4vOSQ4wVrW5OcyaPWPRbtIs5NRfhCWtVw47hItxx3J0jDs2xguSiuWXn(ylQRJYunfkbm5euJJMavNrLH7jlOg915dEfkRcXjnh9eyZhQFadiLadu8fAqqn4H95tHsKN0LqthfkqCMkrkV0wuInfWi418lztbLr2Hcm4dHVWxhFGtwKeKeDo4X9KL(LTOUaaGGBt9Q101wQasmi0OvT(LTOUiiaaoe(cFD8bozrsqs05Gh3tw6x2I6IqTPE1A6AlvajgeA0Qw)YwuxecNPsKYlnDTLkGedcnAvR5xYMcktyfuqaai(cniOg8W(8PqjYt6sOHTHPwM9dkuG4mvIuEPnUeqscs6Tte3eA(LSPGYiBaae36nc11GU1AXaTf1jw2IGyuz4EYcQrFD(GxHYQyLjFkucCZePCyadiLadu8fAqqn4H95tHsKN0LqthfkqCMkrkV0wuInfWi418lztbLr2Hcm4dHVWxhFGtwKeKeDo4X9KL(LTOUaaGGBt9Q101wQasmi0OvT(LTOUiiaaoe(cFD8bozrsqs05Gh3tw6x2I6IqTPE1A6AlvajgeA0Qw)YwuxecNPsKYlnDTLkGedcnAvR5xYMcktyfuqaai(cniOg8W(8PqjYt6sOHTHPwM9dkuG4mvIuEPnUeqscs6Tte3eA(LSPGYiBaae36nc11GU1AXaTf1jw2IGyuz4EYcQrFD(GxHYQIB9gbNJkGbKcNUgmjkLFUwCWbp9A7UxOGJB8XwuxhLPAkucyYjOghnbQoJkd3twqn6RZh8kuwf8W(8PqjWMpu)agqkIVqdcQbpSpFkuI8KUeAyByQxB)qbIZujs5L2IsSPagbVMFjBk4AYAOad(q4l81Xh4KfjbjrNdECpzPFzlQlaai42uVAnDTLkGedcnAvRFzlQlaa4q4l81Xh4KfjbjrNdECpzPFzlQlc1M6vRPRTubKyqOrRA9lBrDriCMkrkV001wQasmi0OvTMFjBk4A7SGccaaXxObb1Gh2NpfkrEsxcnSnm1RfEOaXzQeP8sBCjGKeK0BNiUj08lztbLr2aaiU1BeQRbDR1IbAlQtSSfbXOYW9KfuJ(68bVcLvf36ncohvadiLGJB8XwuxhLPAkucyYjOghnbQURDTZb]] )

end
