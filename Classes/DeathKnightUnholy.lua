-- DeathKnightUnholy.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local roundUp = ns.roundUp

local FindUnitBuffBySpellID = ns.FindUnitBuffBySpellID
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
        unholy_blight_buff = {
            id = 115989,
            duration = 6,
            max_stack = 1,
            dot = "buff"
        },
        unholy_blight = {
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


    local ForceVirulentPlagueRefresh = setfenv( function ()
        target.updated = true
        Hekili:ForceUpdate( "VIRULENT_PLAGUE_REFRESH" )
    end, state )

    local After = C_Timer.After

    spec:RegisterHook( "COMBAT_LOG_EVENT_UNFILTERED", function( event, _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID )
        if sourceGUID == GUID and subtype == "SPELL_CAST_SUCCESS" and spellID == 77575 then
            After( state.latency, ForceVirulentPlagueRefresh )
            After( state.latency * 2, ForceVirulentPlagueRefresh )
        end
    end )


    local any_dnd_set, wound_spender_set = false, false

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

        if state:IsKnown( "deaths_due" ) then
            class.abilities.any_dnd = class.abilities.deaths_due
            cooldown.any_dnd = cooldown.deaths_due
            setCooldown( "death_and_decay", cooldown.deaths_due.remains )
        elseif state:IsKnown( "defile" ) then
            class.abilities.any_dnd = class.abilities.defile
            cooldown.any_dnd = cooldown.defile
            setCooldown( "death_and_decay", cooldown.defile.remains )
        else
            class.abilities.any_dnd = class.abilities.death_and_decay
            cooldown.any_dnd = cooldown.death_and_decay
        end

        if not any_dnd_set then
            class.abilityList.any_dnd = "|T136144:0|t |cff00ccff[Any]|r " .. class.abilities.death_and_decay.name
            any_dnd_set = true
        end

        if state:IsKnown( "clawing_shadows" ) then
            class.abilities.wound_spender = class.abilities.clawing_shadows
            cooldown.wound_spender = cooldown.clawing_shadows
        else
            class.abilities.wound_spender = class.abilities.scourge_strike
            cooldown.wound_spender = cooldown.scourge_strike
        end

        if not wound_spender_set then
            class.abilityList.wound_spender = "|T237530:0|t |cff00ccff[Wound Spender]|r"
            wound_spender_set = true
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

            toggle = function () return not talent.army_of_the_damned.enabled and "cooldowns" or nil end,

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

            bind = { "scourge_strike", "wound_spender" }
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

            bind = { "defile", "any_dnd" },

            copy = "any_dnd"
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

            bind = { "defile", "any_dnd" },
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

            aura = "festering_wound",
            cycle = "festering_wound",

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
            id = function () return IsActiveSpell( 46584 ) and 46584 or 46585 end,
            cast = 0,
            cooldown = function () return level < 29 and 120 or 30 end,
            gcd = "spell",

            startsCombat = false,
            texture = 1100170,

            essential = true, -- new flag, will allow recasting even in precombat APL.
            nomounted = true,

            usable = function () return not pet.alive end,
            handler = function ()
                summonPet( "ghoul", level > 28 and 3600 or 30 )
                if talent.all_will_serve.enabled then summonPet( "skeleton", level > 28 and 3600 or 30 ) end
            end,

            copy = { 46584, 46585 }
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

            bind = { "clawing_shadows", "wound_spender" }
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

            cycle = "festering_wound",

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
                applyBuff( "unholy_blight_buff" )
                applyDebuff( "unholy_blight" )
                applyDebuff( "target", "virulent_plague" )
                active_dot.virulent_plague = active_enemies
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


        -- Stub.
        any_dnd = {
            name = function () return "|T136144:0|t |cff00ccff[Any]|r " .. ( class.abilities.death_and_decay and class.abilities.death_and_decay.name or "Death and Decay" ) end,
        },

        wound_spender = {
            name = "|T237530:0|t |cff00ccff[Wound Spender]|r",            
        }
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


    spec:RegisterPack( "Unholy", 20201124, [[dW0b6bqiHWJGiXMesFsqzucvoLqvRcIu0RKkzwcIDHQFjvQHjG6yqultQWZekmnPI6AcfTnbiFdIuACqKuNdajRta08GiUhISpbvheaPwia8qbOMiaIUOas1hHifojacTsa6LqKentbe3uaPu7uq6NaiWqHijSuisspfHPku6QaiOTkGuYxfqkgRur2lv(lsdMKdtzXsPhtQjJYLvTzG(mrgTu1PvA1ci51crZMWTjQDl63kgUuCCis1YH65u10LCDiTDe13fOXdG68aA9caZhc7h0oKDX6iywDxODe4ocmYi3rN5DeJyGuJmYoIcyZDenMost6oI0KVJaGWSFeaDengqXymxSoc)GI13r0xvJpa7UBPT6rB56rUB)kJkSANuJnWQB)kR72r0IUIcGy6ADemRUl0ocChbgzK7OZ8oIrmcOy2zhHV5AxODeZoCe9lJ9016iy3RDeifOcG8w1dvivMRuFbvaeM9JaieqKcuf6q(YThdvD05qGQocChbgcieqKcubqZcuO(s(z5HQAGkaYeGSBaYdUI3na5TQ3dvaKOhQQbQMuaeQ0dAwqvzyPxEOky)avg(q1b4MRRZGQAGkXs(qLysjO65Gk1dv1avYwvhdvXzZP(xOnqfsb545ocX6lVlwhX9(N67DX6cfzxSoINwR4mhaCeA8whVMJaJMNxR8P1qrgQchQK0mOkkuHrZvtBMGhdvibQ6CGDeMU2jDeYxEWaPdivGQxgLHVj7DLl0oCX6iEATIZCaWrOXBD8Aoc2TQNAjJYU2aYRvh5MsqfceqvZlU1mAQu)Gk4MUwYhQIcvMUwYN(8Y79qfjOczhHPRDshrRyggDaPv)PpVmqx5cngUyDepTwXzoa4i04ToEnhrCqLEgbBcMCRz0MayJ)C8LTn9qfsGQacQIcv6zeSjyYnSmq6asR(tz3yC8LTn9qv4qLEgbBcMC9KSN(ZOIf8GdwFo(Y2MEOkEOcbcOspJGnbtUHLbshqA1Fk7gJJVSTPhQqcu1HJW01oPJqc1WS1s6asTa44P6DLl0o7I1r80AfN5aGJqJ3641CeTOGGC81rkU3tbhS(C0gOcbcOQffeKJVosX9Ek4G1NQh0SoM7lthjuHeOczKDeMU2jDev)POz7GMmk4G13vUqJPlwhXtRvCMdaocnERJxZrebuXUv9ulzu21gqET6i3uYry6AN0raoAu)zulaoERtBVj7kxObKlwhXtRvCMdaocnERJxZrWMIRNu)SWwDgfuyYN2IIto(Y2MEOIeufyhHPRDshHEs9ZcB1zuqHjFx5cfP1fRJ4P1koZbahHgV1XR5iIaQy3QEQLmk7AdiVwDKBk5imDTt6iAqXliWnLOTcZxUYfksTlwhXtRvCMdaocnERJxZruM4zXnSmq6asR(tzMCEg)P1kodQIcv37FQpN863jPdiT5yWRRDsU8MdgQIcvTOGGC0SFeaP(c)uQ65Onqfceq19(N6ZjV(Ds6asBog86ANKlV5GHQOqvZlU1mAQu)Gk4MUwYhQqGaQkt8S4gwgiDaPv)PmtopJ)0AfNbvrHQMxCRz0uP(bvWnDTKpuffQ0ZiytWKByzG0bKw9NYUX44lBB6HQWHQakWqfceqvzINf3WYaPdiT6pLzY5z8NwR4mOkku18IByzGuP(bvWnDTKVJW01oPJi4GfmYFtk((jTuFx5cfGYfRJ4P1koZbahHgV1XR5iIaQy3QEQLmk7AdiVwDKBkbvrHQwuqqoA2pcGuFHFkv9C0gOkkufbuDV)P(CYRFNKoG0MJbVU2j5YBoyOkkufbuvM4zXnSmq6asR(tzMCEg)P1kodQqGaQkdl9IxR8P1qz7HkKav6zeSjyYTMrBcGn(ZXx2207imDTt6icoybJ83KIVFsl13vUqroWUyDepTwXzoa4i04ToEnhreqf7w1tTKrzxBa51QJCtjhHPRDshbEBAeNUj13y67kxOiJSlwhHPRDshb(wZMsuqHjFVJ4P1koZbax5khHnN2II9LlwxOi7I1r80AfN5aGJqJ3641Cey0C10Mj4XC2bx9wqfsGQ4GkKdmu1fuXUv90iZvQV4Gbh0KDgTmS0lpuH0eQIbufpuffQy3QEAK5k1xCWGdAYoJwgw6LhQqcufqqvuOkcOISHxRvCEZmInLOGdMkzyPbO4octx7KoI3SSlVAx5cTdxSoINwR4mhaCeA8whVMJaJMRM2mbpMZo4Q3cQqcu1rmHQOqf7w1tJmxP(IdgCqt2z0YWsV8qv4qvmHQOqveqfzdVwR48MzeBkrbhmvYWsdqXDeMU2jDeVzzxE1UYfAmCX6iEATIZCaWrOXBD8AoIiGk2TQNgzUs9fhm4GMSZOLHLE5HQOqveqfzdVwR48MzeBkrbhmvYWsdqXDeMU2jDeVzzxE1UYfANDX6imDTt6icoOjJ6BEYo2r80AfN5aGRCHgtxSoINwR4mhaCeA8whVMJicOISHxRvCEZmInLOGdMkzyPbO4octx7KoI3SSlVAx5khH0ZJxTlwxOi7I1r80AfN5aGJqJ3641CeTOGGCpkJ9KYMrMJVPlOkkufbur2WR1koVzgXMsuWbtLmS0auCOcbcOQ5fxYWsdqX5MUwY3ry6AN0rWUv9u9Scx5cTdxSoINwR4mhaCeA8whVMJaJMRM2mbpMZo4Q3cQqcuHCmGQOqveqfzdVwR48MzeBkrbhmvYWsdqXDeMU2jDeSBvpvpRWvUqJHlwhXtRvCMdaocnERJxZrONrWMGj3AgTja24phFzBtpuffQIdQkt8S4SdUIZFATIZGkeiGk9q(PLfpxP(IcAhQI3ry6AN0ryjqklzUYfANDX6iEATIZCaWrOXBD8Aoc2Brbb5G3xhVPen4GMmUVmDKqv4qvNDeMU2jDebh0Kr9npzh7kxOX0fRJ4P1koZbahHgV1XR5iyVffeKdEFD8Ms0GdAY4OnqvuOspJGnbtU1mAtaSXFo(Y2MEOkCOkMqvuOkoOkcOQmXZIJM9JaiTvSs9f)P1kodQqGaQkt8S4gwgiDaPv)PmtopJ)0AfNbviqav6jzOBX1tsE0wTtshqA1Fk7gJ)0AfNbviqavyBz0t(zXngZZpaV(YdvX7imDTt6icoOjJ6BEYo2vUqdixSoINwR4mhaCeA8whVMJG9wuqqo491XBkrdoOjJJ2avrHQYeploA2pcG0wXk1x8NwR4mOkkufbuvM4zXnSmq6asR(tzMCEg)P1kodQIcvrav6jzOBX1tsE0wTtshqA1Fk7gJ)0AfNbvrHQiGkSTm6j)S4gJ55hGxF5HQOqvCqLEgbBcMC0SFeaPTIvQV44lBB6HQWHQycvrHk9mc2em5wZOnbWg)54BmGqvuOkcOInfhn7hbqARyL6lo(Y2MEOcbcOkcOspJGnbtU1mAtaSXFo(gdiufVJW01oPJi4GMmQV5j7yx5cfP1fRJ4P1koZbahHgV1XR5iWO5QPntWJ5SdU6TGkKavDeyOkkufbur2WR1koVzgXMsuWbtLmS0auChHPRDshb7w1t1ZkCLluKAxSoINwR4mhaCeA8whVMJG9wuqqo491XBkrdoOjJ7lthjuHeOczhHPRDshb491XBkr9fEJ8UYfkaLlwhXtRvCMdaocnERJxZrWElkiih8(64nLObh0KX9LPJeQqcu1zOkkuPNrWMGj3AgTja24phFzBtpuHeOkgqvuOkoOkcOQmXZIJM9JaiTvSs9f)P1kodQqGaQkt8S4gwgiDaPv)PmtopJ)0AfNbviqav6jzOBX1tsE0wTtshqA1Fk7gJ)0AfNbviqavyBz0t(zXngZZpaV(YdvX7imDTt6iaVVoEtjQVWBK3vUqroWUyDepTwXzoa4i04ToEnhb7TOGGCW7RJ3uIgCqtg3xMosOcjqvNHQOqvzINfhn7hbqARyL6l(tRvCguffQIaQkt8S4gwgiDaPv)PmtopJ)0AfNbvrHQiGk9Km0T46jjpAR2jPdiT6pLDJXFATIZGQOqveqf2wg9KFwCJX88dWRV8qvuOspJGnbtU1mAtaSXFo(gdiuffQIdQ0ZiytWKJM9JaiTvSs9fhFzBtpuHeOkgqfceqfBkoA2pcG0wXk1xC8LTn9qv8octx7KocW7RJ3uI6l8g5DLluKr2fRJ4P1koZbahHgV1XR5iIaQiB41AfN3mJytjk4GPsgwAakUJW01oPJGDR6P6zfUYvoc9q(PLL3fRluKDX6iEATIZCaWrOXBD8AocYgETwX5(I2iSm3ucQIcvy0C10Mj4XC2bx9wqv4qva5imDTt6i8bnS8Msu51xUYfAhUyDepTwXzoa4i04ToEnhHPRL8PpV8EpufojOQdOkkuz6AjF6ZlV3dviHeuftOkkuHrZvtBMGhZzhC1BbvHdvXbvMUwYN(8Y79qfstOkGGQ4HkeiGktxl5tFE59EOkCOkMqvuOcJMRM2mbpMZo4Q3cQchQIrGDeMU2jDe(GgwEtjQ86lx5cngUyDepTwXzoa4i04ToEnhbzdVwR4CFrBewMBkbvrHkmAEETYNwdTZqv4qvCqvmGQUGQwuqqognxnvpymAtTtYXx220dvX7imDTt6iS2rEtR2jPIvU1vUq7SlwhXtRvCMdaocnERJxZry6AjF6ZlV3dvHtcQ6aQIcvy088ALpTgANHQWHQ4GQyavDbvTOGGCmAUAQEWy0MANKJVSTPhQI3ry6AN0ryTJ8MwTtsfRCRRCHgtxSoINwR4mhaCeA8whVMJGSHxRvCUVOnclZnLGQOqLEgbBcMCRz0MayJ)C8LTn9octx7KocFVPJuCA1FkAgCWvpqx5cnGCX6iEATIZCaWrOXBD8Aoctxl5tFE59EOkCsqvhqvuOkoOIDR6PwYOSRnG8A1rUPeuHabuHTLrp5Nf3ymphFzBtpuHesqfYDgQI3ry6AN0r47nDKItR(trZGdU6b6kx5iAWxpYTw5I1fkYUyDeMU2jDentTt6iEATIZCaWvUq7WfRJ4P1koZbahrAY3rybGV3WMNcozrhqAZe8yhHPRDshHfa(EdBEk4KfDaPntWJDLl0y4I1ry6AN0rGT1Fk7gZr80AfN5aGRCLJqpJGnbtVlwxOi7I1ry6AN0rG6pDRl7DepTwXzoa4kxOD4I1r80AfN5aGJqJ3641CenV4sgwAako301s(qfceqvlkiihn7hbqQ59gQO4OnqfceqvzINf3WYaPdiT6pLzY5z8NwR4mOkkufhu18IByzGuP(bvWnDTKpuHabu18IBnJMk1pOcUPRL8HkeiGk9mc2em5gwgiDaPv)PSBmo(Y2MEOkCOQmS0lETYNwdLThQI3ry6AN0r0m1oPRCHgdxSoINwR4mhaCeA8whVMJqpJGnbtoA2pcG0wXk1xC8LTn9qfsGQycvrHQYeploA2pcG0wXk1x8NwR4mOcbcOkcOQmXZIJM9JaiTvSs9f)P1koZry6AN0ryyzG0bKw9NYUXCLl0o7I1r80AfN5aGJqJ3641CeKn8ATIZ9fTryzUPeuffQIdQ0ZiytWKByzG0bKw9NYUX44lBB6HQWHQycviqavSBvpnYCL6loB9wR4uBkgufpuffQIdQ0ZiytWKBnJ2eaB8NJVXacvrHQ4Gk2Brbb5G3xhVPen4GMmUVmDKqv4KGQodviqavy08qv4KGQyavXdviqav6zeSjyYTMrBcGn(ZXx220dvX7imDTt6iqZ(raK2kwP(YvUqJPlwhXtRvCMdaocnERJxZry6AjF6ZlV3dvHtcQ6Wry6AN0rGM9JaiTvSs9LRCHgqUyDepTwXzoa4i04ToEnhbzdVwR4CFrBewMBkbvrHk9mc2em5Oz)iasBfRuFXXx220dvrHQ4GQiGkmAEWblDo7gtS3xu9Sc(tRvCguHabuHrZdoyPZz3yI9(IQNvWFATIZGQOqvCqveqvlkiiNz4iPf2sp4GLTANKJ2avrHQiGQYeploA2pcG0gtx8NwR4mOcbcOQmXZIJM9JaiTX0f)P1kodQIhQI3ry6AN0rWmCK0cBPhCWYwTt6kxOiTUyDepTwXzoa4i04ToEnhbzdVwR4CFrBewMBkbvrHQiGQYeploA2pcG0wXk1x8NwR4mhHPRDshbZWrslSLEWblB1oPRCHIu7I1r80AfN5aGJqJ3641CeMUwYN(8Y79qv4KGQoCeMU2jDemdhjTWw6bhSSv7KUYfkaLlwhXtRvCMdaocnERJxZry6AjF6ZlV3dvKGkKHQOqf7TOGGCW7RJ3uIgCqtg3xMosOkCsqvNHQOqvCqvCqveqvzINfhn7hbqARyL6l(tRvCguHabuvM4zXnSmq6asR(tzMCEg)P1kodQqGaQ0tYq3IRNK8OTANKoG0Q)u2ng)P1kodQIhQqGaQkt8S4Oz)iasBfRuFXFATIZGQOqveqvzINf3WYaPdiT6pLzY5z8NwR4mOkkuXMIJM9JaiTvSs9fhFzBtpufVJW01oPJWAgTja24VRCHICGDX6iEATIZCaWrOXBD8Aoctxl5tFE59EOkCsqvhqvuOI9wuqqo491XBkrdoOjJ7lthjufojOQZqvuOkcOIDR6PwYOSRnG8A1rUPKJW01oPJWAgTja24VRCHImYUyDepTwXzoa4i04ToEnhbgnxnTzcEmNDWvVfuHeOc5o7imDTt6i8OYYtsLmS0auCx5cf5oCX6iEATIZCaWrOXBD8AocYgETwX5(I2iSm3ucQIcvS3IccYbVVoEtjAWbnzCFz6iHkKavDavrHQ4GQMxCRz0uP(bvWnDTKpuHabuPNKHUfxpj5rB1ojDaPv)PSBm(tRvCgufVJW01oPJan7hbqQ59gQOCLluKJHlwhXtRvCMdaoctx7Koc0SFeaPM3BOIYrOXBD8Aoctxl5tFE59EOkCsqvhqvuOI9wuqqo491XBkrdoOjJ7lthjuHeOQdhHgOwCAzyPxExOi7kxOi3zxSoINwR4mhaCeMU2jDe(bvqX3Ao2rOXBD8AoIYWsV41kFAn0gDrJrmHkKavXeQIcvLHLEXRv(0AOS9qv4qvmDeAGAXPLHLE5DHISRCHICmDX6iEATIZCaWrOXBD8AoIiGQMxCP(bvWnDTKVJW01oPJaBR)u2nMRCLJq65XRMAZDX6cfzxSoINwR4mhaCeA8whVMJOffeK7rzSNu2mYC8nD5imDTt6iEZYU8QDLl0oCX6iEATIZCaWrOXBD8AoIiGkYgETwX5nZi2uIcoyQKHLgGI7imDTt6iEZYU8QDLl0y4I1r80AfN5aGJW01oPJi4GMmQV5j7yhHgV1XR5iIdQ0ZiytWKBnJ2eaB8NJVSTPhQchQIjuffQyVffeKdEFD8Ms0GdAY4Onqfceqf7TOGGCW7RJ3uIgCqtg3xMosOkCOQZqv8qvuOkoOcCL6lk(Y2MEOcjqLEgbBcMC2TQNAjJYU2aYXx220dvDbvihyOcbcOcCL6lk(Y2MEOkCOspJGnbtU1mAtaSXFo(Y2MEOkEhHgOwCAzyPxExOi7kxOD2fRJ4P1koZbahHPRDshb491XBkr9fEJ8ocnERJxZrWElkiih8(64nLObh0KX9LPJeQqcjOkgqvuOspJGnbtU1mAtaSXFo(Y2MEOcjqvmGkeiGk2Brbb5G3xhVPen4GMmUVmDKqfsGkKDeAGAXPLHLE5DHISRCHgtxSoINwR4mhaCeMU2jDeG3xhVPe1x4nY7i04ToEnhHEgbBcMCRz0MayJ)C8LTn9qv4qvmHQOqf7TOGGCW7RJ3uIgCqtg3xMosOcjqfYocnqT40YWsV8Uqr2vUYrWoOHkkxSUqr2fRJW01oPJqEtgfe)ha3r80AfN5aGRCH2HlwhXtRvCMdaoIPXr4F5imDTt6iiB41Af3rq2eO3rONrWMGj3JklpjvYWsdqX54lBB6HkKavXeQIcvLjEwCpQS8KujdlnafN)0AfN5iiByAAY3r0mJytjk4GPsgwAakURCHgdxSoINwR4mhaCetJJW)Yry6AN0rq2WR1kUJGSjqVJW01s(0NxEVhQibvidvrHQ4GQiGkSTm6j)S4gJ55hGxF5HkeiGkSTm6j)S4gJ55BcvHdvihtOkEhbzdttt(ocFrBewMBk5kxOD2fRJ4P1koZbahHgV1XR5iWO5QPntWJ5SdU6TGQWHQakMqvuOkoOQ5fxYWsdqX5MUwYhQqGaQIaQkt8S4Euz5jPsgwAako)P1kodQIhQIcvy08C2bx9wqv4KGQy6imDTt6imS2YtRbJFwUYfAmDX6iEATIZCaWrOXBD8AoIMxCjdlnafNB6AjFOcbcOQffeKJM9Jai18EdvuC0gOcbcOQmXZIByzG0bKw9NYm58m(tRvCguffQIdQAEXnSmqQu)Gk4MUwYhQqGaQ0ZiytWKByzG0bKw9NYUX44lBB6HQWHQYWsV41kFAnu2EOcbcOQ5f3AgnvQFqfCtxl5dvrHk9mc2em5gwgiDaPv)PSBmo(Y2MEOkCOspJGnbtERyggfefdKZqXwTtcvX7imDTt6iAfZWOGOyGUYfAa5I1r80AfN5aGJqJ3641CenV4sgwAako301s(qfceqvlkiihn7hbqQ59gQO4OnqfceqvzINf3WYaPdiT6pLzY5z8NwR4mOkkufhu18IByzGuP(bvWnDTKpuHabuPNrWMGj3WYaPdiT6pLDJXXx220dvHdvLHLEXRv(0AOS9qfceqvZlU1mAQu)Gk4MUwYhQIcv6zeSjyYnSmq6asR(tz3yC8LTn9qv4qLEgbBcM82J9hh5MsCgk2QDsOkEhHPRDshr7X(JJCtjx5cfP1fRJ4P1koZbahHgV1XR5iArbb5Oz)ias9f(Pu1ZrBCeMU2jDeIvQV80afkts(z5kxOi1UyDepTwXzoa4i04ToEnhrZlUKHLgGIZnDTKpuHabu1IccYrZ(raKAEVHkkoAduHabuvM4zXnSmq6asR(tzMCEg)P1kodQIcvXbvnV4gwgivQFqfCtxl5dviqav6zeSjyYnSmq6asR(tz3yC8LTn9qv4qvzyPx8ALpTgkBpuHabu18IBnJMk1pOcUPRL8HQOqLEgbBcMCdldKoG0Q)u2nghFzBtpufouPNrWMGj3s99f2euTjeCgk2QDsOkEhHPRDshHL67lSjOAtiCLluakxSoINwR4mhaCeA8whVMJW01s(0NxEVhQcNeu1buHabufhuHrZZzhC1BbvHtcQIjuffQWO5QPntWJ5SdU6TGQWjbvbuGHQ4DeMU2jDegwB5PnOc)DLluKdSlwhXtRvCMdaocnERJxZr08IlzyPbO4Ctxl5dviqavTOGGC0SFeaPM3BOIIJ2aviqavLjEwCdldKoG0Q)uMjNNXFATIZGQOqvCqvZlUHLbsL6hub301s(qfceqLEgbBcMCdldKoG0Q)u2nghFzBtpufouvgw6fVw5tRHY2dviqavnV4wZOPs9dQGB6AjFOkkuPNrWMGj3WYaPdiT6pLDJXXx220dvHdv6zeSjyYbx8BfZW4muSv7Kqv8octx7KocWf)wXmmx5cfzKDX6iEATIZCaWrOXBD8AoIwuqqoA2pcGuFHFkv9C0gOkkuz6AjF6ZlV3dvKGkKDeMU2jDeTMeDaPfE1r6DLluK7WfRJ4P1koZbahHgV1XR5iQv(qv4qvhbgQqGaQIaQoshDBAoJJn5MnLOMCJylu2PsRKrEef9P0MhQqGaQIaQoshDBAoJtE97K0bKYU86VJW01oPJa1F6wx27kxOihdxSoINwR4mhaCeMU2jDewa47nS5PGtw0bK2mbp2rOXBD8AoI4GQ79p1NtE97K0bK2Cm411oj)P1kodQIcvravLjEwC0SFeaPM3BOII)0AfNbvXdviqavXbvrav37FQpxpj7P)mQybp4G1NlBbQbdvrHQiGQ79p1NtE97K0bK2Cm411oj)P1kodQI3rKM8Dewa47nS5PGtw0bK2mbp2vUqrUZUyDepTwXzoa4imDTt6iSaW3ByZtbNSOdiTzcESJqJ3641Ce6zeSjyYTMrBcGn(ZXx220dvibQqUZqvuOkoO6E)t956jzp9Nrfl4bhS(CzlqnyOcbcO6E)t95Kx)ojDaPnhdEDTtYFATIZGQOqvzINfhn7hbqQ59gQO4pTwXzqv8oI0KVJWcaFVHnpfCYIoG0Mj4XUYfkYX0fRJ4P1koZbahHPRDshHfa(EdBEk4KfDaPntWJDeA8whVMJaCL6lk(Y2MEOcjqLEgbBcMCRz0MayJ)C8LTn9qvxqvm6SJin57iSaW3ByZtbNSOdiTzcESRCHICa5I1r80AfN5aGJW01oPJW89KT8Ek2cGbt1d2eocnERJxZrWElkiihBbWGP6bBck7TOGGCFz6iHkKavi7ist(ocZ3t2Y7Pylagmvpyt4kxOiJ06I1r80AfN5aGJW01oPJW89KT8Ek2cGbt1d2eocnERJxZr08IlHAy2AjDaPwaC8u9Ctxl5dvrHQMxCRz0uP(bvWnDTKVJin57imFpzlVNITayWu9GnHRCHImsTlwhXtRvCMdaoctx7KocZ3t2Y7Pylagmvpyt4i04ToEnhHEgbBcMCRz0MayJ)C8ngqOkkufhuDV)P(C9KSN(ZOIf8GdwFUSfOgmuffQaxP(IIVSTPhQqcuPNrWMGjxpj7P)mQybp4G1NJVSTPhQ6cQ6iWqfceqveq19(N6Z1tYE6pJkwWdoy95YwGAWqv8oI0KVJW89KT8Ek2cGbt1d2eUYfkYauUyDepTwXzoa4imDTt6imFpzlVNITayWu9GnHJqJ3641CeGRuFrXx220dvibQ0ZiytWKBnJ2eaB8NJVSTPhQ6cQ6iWoI0KVJW89KT8Ek2cGbt1d2eUYfAhb2fRJ4P1koZbahHPRDshb51Vtshqk7YR)ocnERJxZrehuPNrWMGj3AgTja24phFJbeQIcvS3IccYbVVoEtjAWbnzCFz6iHQWjbvDgQIcv37FQpN863jPdiT5yWRRDs(tRvCgufpuHabu1IccYrZ(raKAEVHkkoAduHabu18IlzyPbO4Ctxl57ist(ocYRFNKoGu2Lx)DLl0oq2fRJ4P1koZbahHPRDshb2KB2uIAYnITqzNkTsg5ru0NsBEhHgV1XR5i0ZiytWKBnJ2eaB8NJVSTPhQqcu1buHabuvM4zXnSmq6asR(tzMCEg)P1kodQqGaQW2YON8ZIBmMNVjuHeOkMoI0KVJaBYnBkrn5gXwOStLwjJ8ik6tPnVRCH2rhUyDepTwXzoa4imDTt6iAbkn5PT)utiBPPDeA8whVMJqpJGnbtUhvwEsQKHLgGIZXx220dvHdvbuGHkeiGQiGQYeplUhvwEsQKHLgGIZFATIZGQOqvTYhQchQ6iWqfceqveq1r6OBtZzCSj3SPe1KBeBHYovALmYJOOpL28oI0KVJOfO0KN2(tnHSLM2vUq7igUyDepTwXzoa4imDTt6icu3t7NGIJDeA8whVMJO5fxYWsdqX5MUwYhQqGaQIaQkt8S4Euz5jPsgwAako)P1kodQIcv1kFOkCOQJadviqavravhPJUnnNXXMCZMsutUrSfk7uPvYipII(uAZ7ist(oIa190(jO4yx5cTJo7I1r80AfN5aGJW01oPJqYexBcXXEA7TiDeA8whVMJO5fxYWsdqX5MUwYhQqGaQIaQkt8S4Euz5jPsgwAako)P1kodQIcv1kFOkCOQJadviqavravhPJUnnNXXMCZMsutUrSfk7uPvYipII(uAZ7ist(ocjtCTjeh7PT3I0vUq7iMUyDepTwXzoa4imDTt6iKWtk5Pn4v2euSjDhHgV1XR5iWO5HkKqcQIbuffQIdQQv(qv4qvhbgQqGaQIaQoshDBAoJJn5MnLOMCJylu2PsRKrEef9P0MhQI3rKM8Des4jL80g8kBck2KURCH2ra5I1r80AfN5aGJqJ3641Ce6zeSjyYnSmq6asR(tz3yC8ngqOcbcOQ5fxYWsdqX5MUwYhQqGaQArbb5Oz)iasnV3qffhTXry6AN0r0m1oPRCH2bsRlwhXtRvCMdaocnERJxZrWMItEXOINfTrysONJpi((ERvCOkkufbuvM4zXrZ(raK2kwP(I)0AfNbvrHQiGkSTm6j)S4gJ55hGxF5DeMU2jDedA1IVfPRCH2bsTlwhXtRvCMdaocnERJxZrWMItEXOINfTrysONJpi((ERvCOkkufhufbuvM4zXrZ(raK2kwP(I)0AfNbviqavLjEwC0SFeaPTIvQV4pTwXzqvuOspJGnbtoA2pcG0wXk1xC8LTn9qv8qvuOY01s(0NxEVhQcNeu1HJW01oPJyqRw8TiDLl0oaOCX6iEATIZCaWrOXBD8AocmAEWblDUhT5yFHTn5pTwXzqvuOkoOInfhep(IcEYhZXheFFV1kouHabuXMI3kMHrBeMe654dIVV3AfhQI3ry6AN0rmOvl(wKUYfAmcSlwhXtRvCMdaoctx7KocTjeutx7KuX6lhHy9fnn57i0d5NwwEx5cngi7I1r80AfN5aGJW01oPJqBcb101ojvS(YriwFrtt(oc9mc2em9UYfAm6WfRJ4P1koZbahHPRDshH2ecQPRDsQy9LJqS(IMM8De37FQV3vUqJrmCX6iEATIZCaWrOXBD8Aoctxl5tFE59EOkCsqvhqvuOkoOspJGnbto7w1tTKrzxBa54lBB6HkKavihyOkkufbuvM4zXzhCfN)0AfNbviqav6zeSjyYzhCfNJVSTPhQqcuHCGHQOqvzINfNDWvC(tRvCgufpuffQIaQy3QEQLmk7AdiVwDKBk5imDTt6iWOj101ojvS(YriwFrtt(ocBo1)cTXvUqJrNDX6iEATIZCaWrOXBD8Aoctxl5tFE59EOkCsqvhqvuOIDR6PwYOSRnG8A1rUPKJW01oPJaJMutx7KuX6lhHy9fnn57iS50wuSVCLl0yetxSoINwR4mhaCeA8whVMJW01s(0NxEVhQcNeu1buffQIdQIaQy3QEQLmk7AdiVwDKBkbvrHQ4Gk9mc2em5SBvp1sgLDTbKJVSTPhQchQqoWqvuOkcOQmXZIZo4ko)P1kodQqGaQ0ZiytWKZo4kohFzBtpufouHCGHQOqvzINfNDWvC(tRvCgufpufVJW01oPJaJMutx7KuX6lhHy9fnn57iKEE8QP2Cx5cngbKlwhXtRvCMdaocnERJxZry6AjF6ZlV3dvKGkKDeMU2jDeAtiOMU2jPI1xocX6lAAY3ri984v7kx5iS5u)l0gxSUqr2fRJ4P1koZbahHgV1XR5iy3QEAK5k1xCWGdAYoJwgw6LhQcNeuPbQfN(8Y79qfceqf2wg9KFwCJX88dWRV8qvuOcBlJEYplUXyEo(Y2MEOcjKGkKr2ry6AN0ryjqklzUYfAhUyDepTwXzoa4i04ToEnhb7w1tJmxP(IdgCqt2z0YWsV8qv4KGQy6imDTt6iSeiLLmx5cngUyDepTwXzoa4i04ToEnhreqfzdVwR48MzeBkrbhmvYWsdqXHQOqfgnxnTzcEmNDWvVfuHeOQJadviqavTOGGCpkJ9KYMrMJVPlhHPRDshXBw2LxTRCH2zxSoINwR4mhaCeMU2jDeG3xhVPe1x4nY7i04ToEnhb7TOGGCW7RJ3uIgCqtg3xMosOcjKGQyavrHk9mc2em5wZOnbWg)54lBB6HkKavXWrObQfNwgw6L3fkYUYfAmDX6iEATIZCaWry6AN0raEFD8MsuFH3iVJqJ3641CeS3IccYbVVoEtjAWbnzCFz6iHkKavi7i0a1Itldl9Y7cfzx5cnGCX6iEATIZCaWry6AN0raEFD8MsuFH3iVJqJ3641Cey088ALpTgANHkKavXbv6zeSjyYz3QEQLmk7AdihFzBtpuffQIaQkt8S4SdUIZFATIZGkeiGk9mc2em5SdUIZXx220dvrHQYeplo7GR48NwR4mOkEhHgOwCAzyPxExOi7kxOiTUyDepTwXzoa4i04ToEnhreqfzdVwR48MzeBkrbhmvYWsdqXDeMU2jDeVzzxE1UYvUYrq(y)oPl0ocChbgzKrgP2re0W5MsEhrGgaAKQHcqmuKgbiubvX2FOALBgCbvGdgQct65XRomOcFKo6IpdQ8J8HkdTgzRodQ09wkDphcyGS5HQygGqvapj5JRZGQWkt8S4DkmOQgOkSYeplEN4pTwXzHbvX1bahphcyGS5HQygGqvapj5JRZGQW0tYq3I3PWGQAGQW0tYq3I3j(tRvCwyqvCidWXZHagiBEOkGcqOkGNK8X1zqvyLjEw8ofguvdufwzINfVt8NwR4SWGQ46aGJNdbmq28qvafGqvapj5JRZGQW0tYq3I3PWGQAGQW0tYq3I3j(tRvCwyqvCidWXZHagiBEOcGkaHQaEsYhxNbvHvM4zX7uyqvnqvyLjEw8oXFATIZcdQIRdaoEoeWazZdvaubiufWts(46mOkm9Km0T4DkmOQgOkm9Km0T4DI)0AfNfgufhYaC8CiGbYMhQqoWbiufWts(46mOkSYeplENcdQQbQcRmXZI3j(tRvCwyqvCDaWXZHagiBEOc5ahGqvapj5JRZGQW0tYq3I3PWGQAGQW0tYq3I3j(tRvCwyqvCidWXZHacbmqdans1qbigksJaeQGQy7puTYndUGkWbdvHPNrWMGPpmOcFKo6IpdQ8J8HkdTgzRodQ09wkDphcyGS5HQocqOkGNK8X1zqvyLjEw8ofguvdufwzINfVt8NwR4SWGQ4qgGJNdbmq28qvmcqOkGNK8X1zqvyLjEw8ofguvdufwzINfVt8NwR4SWGQ4qgGJNdbmq28qvmcqOkGNK8X1zqvyLjEw8ofguvdufwzINfVt8NwR4SWGkRGQaDacceOkoKb445qadKnpufqbiufWts(46mOkSYeplENcdQQbQcRmXZI3j(tRvCwyqvCDaWXZHagiBEOkGcqOkGNK8X1zqvyy08Gdw68ofguvdufggnp4GLoVt8NwR4SWGQ46aGJNdbmq28qfsBacvb8KKpUodQcRmXZI3PWGQAGQWkt8S4DI)0AfNfguzfufOdqqGavXHmahphcyGS5HkaQaeQc4jjFCDgufwzINfVtHbv1avHvM4zX7e)P1kolmOkUodWXZHagiBEOcGkaHQaEsYhxNbvHPNKHUfVtHbv1avHPNKHUfVt8NwR4SWGQ4qgGJNdbmq28qfYDeGqvapj5JRZGQW0tYq3I3PWGQAGQW0tYq3I3j(tRvCwyqvCidWXZHacbmqdans1qbigksJaeQGQy7puTYndUGkWbdvHzZP(xOnHbv4J0rx8zqLFKpuzO1iB1zqLU3sP75qadKnpufqbiufWts(46mOkSYeplENcdQQbQcRmXZI3j(tRvCwyqvCDaWXZHacbmqdans1qbigksJaeQGQy7puTYndUGkWbdvHXoOHkQWGk8r6Ol(mOYpYhQm0AKT6mOs3BP09CiGbYMhQ6iaHQaEsYhxNbvHvM4zX7uyqvnqvyLjEw8oXFATIZcdQScQc0biiqGQ4qgGJNdbmq28qvmdqOkGNK8X1zqvyLjEw8ofguvdufwzINfVt8NwR4SWGQ4qgGJNdbmq28qvafGqvapj5JRZGQWkt8S4DkmOQgOkSYeplEN4pTwXzHbvXHmahphcyGS5HkK6aeQc4jjFCDgufwzINfVtHbv1avHvM4zX7e)P1kolmOkoKb445qadKnpuHCGdqOkGNK8X1zqvyLjEw8ofguvdufwzINfVt8NwR4SWGQ4qgGJNdbmq28qvhiTbiufWts(46mOkSYeplENcdQQbQcRmXZI3j(tRvCwyqvCidWXZHagiBEOQdK6aeQc4jjFCDgufwzINfVtHbv1avHvM4zX7e)P1kolmOkUoa445qadKnpu1bavacvb8KKpUodQcdJMhCWsN3PWGQAGQWWO5bhS05DI)0AfNfgufhYaC8CiGbYMhQIrmcqOkGNK8X1zqvyLjEw8ofguvdufwzINfVt8NwR4SWGQ46aGJNdbmq28qvmIzacvb8KKpUodQcRmXZI3PWGQAGQWkt8S4DI)0AfNfgufxhaC8CiGqabik3m46mOcGcQmDTtcvI1xEoeqhHHw9d2rqSYOcR2jdySbwoIg8aUI7iqkqfa5TQhQqQmxP(cQaim7hbqiGifOk0H8LBpgQ6OZHavDe4ocmeqiGifOcGMfOq9L8ZYdv1avaKjaz3aKhCfVBaYBvVhQairpuvdunPaiuPh0SGQYWsV8qvW(bQm8HQdWnxxNbv1avIL8HkXKsq1ZbvQhQQbQKTQogQIZMt9VqBGkKcYXZHacb001oPN3GVEKBTQlsD3m1ojeqtx7KEEd(6rU1QUi1nQ)0TUCiPjFswa47nS5PGtw0bK2mbpgcOPRDspVbF9i3AvxK6gBR)u2ngeqiGifOkqhGVgTodQo5Jbcv1kFOQ6puz6AWq16HkJSTcRvCoeqtx7KEsYBYOG4)a4qarkqvGwgETwX9qanDTt67Iu3Kn8ATIhsAYNuZmInLOGdMkzyPbO4Hq2eONKEgbBcMCpQS8KujdlnafNJVSTPhjXmAzINf3JklpjvYWsdqXHaA6AN03fPUjB41AfpK0KpjFrBewMBkfcztGEsMUwYN(8Y79KqoACrGTLrp5Nf3ymp)a86lpceyBz0t(zXngZZ3mCKJz8qarkqfsvtVMWdb001oPVlsDByTLNwdg)SczbjHrZvtBMGhZzhC1BfEafZOX18IlzyPbO4Ctxl5JareLjEwCpQS8KujdlnafN)0AfNfFumAEo7GRERWjftiGMU2j9DrQ7wXmmkikgyiliPMxCjdlnafNB6AjFeiArbb5Oz)iasnV3qffhTbbIYeplUHLbshqA1FkZKZZIgxZlUHLbsL6hub301s(iqONrWMGj3WYaPdiT6pLDJXXx220hEzyPx8ALpTgkBpcenV4wZOPs9dQGB6Aj)O6zeSjyYnSmq6asR(tz3yC8LTn9HRNrWMGjVvmdJcIIbYzOyR2jJhcOPRDsFxK6U9y)XrUPuiliPMxCjdlnafNB6AjFeiArbb5Oz)iasnV3qffhTbbIYeplUHLbshqA1FkZKZZIgxZlUHLbsL6hub301s(iqONrWMGj3WYaPdiT6pLDJXXx220hEzyPx8ALpTgkBpcenV4wZOPs9dQGB6Aj)O6zeSjyYnSmq6asR(tz3yC8LTn9HRNrWMGjV9y)XrUPeNHITANmEiGMU2j9DrQBXk1xEAGcLjj)Sczbj1IccYrZ(raK6l8tPQNJ2ab001oPVlsDBP((cBcQ2eIqwqsnV4sgwAako301s(iq0IccYrZ(raKAEVHkkoAdceLjEwCdldKoG0Q)uMjNNfnUMxCdldKk1pOcUPRL8rGqpJGnbtUHLbshqA1Fk7gJJVSTPp8YWsV41kFAnu2EeiAEXTMrtL6hub301s(r1ZiytWKByzG0bKw9NYUX44lBB6dxpJGnbtUL67lSjOAti4muSv7KXdb001oPVlsDByTLN2Gk8pKfKKPRL8PpV8EF4K6abI4WO55SdU6TcNumJIrZvtBMGhZzhC1BfoPakWXdb001oPVlsDdU43kMHfYcsQ5fxYWsdqX5MUwYhbIwuqqoA2pcGuZ7nurXrBqGOmXZIByzG0bKw9NYm58SOX18IByzGuP(bvWnDTKpce6zeSjyYnSmq6asR(tz3yC8LTn9Hxgw6fVw5tRHY2JarZlU1mAQu)Gk4MUwYpQEgbBcMCdldKoG0Q)u2nghFzBtF46zeSjyYbx8BfZW4muSv7KXdb001oPVlsD3As0bKw4vhPpKfKulkiihn7hbqQVWpLQEoAtutxl5tFE59EsidbePavbmQVgzOQWBg5lpuH6nPdb001oPVlsDJ6pDRl7dzbjvR8dVJaJarehPJUnnNXXMCZMsutUrSfk7uPvYipII(uAZJarehPJUnnNXjV(Ds6aszxE9hcOPRDsFxK6g1F6wxoK0Kpjla89g28uWjl6asBMGhhYcskU79p1NtE97K0bK2Cm411oj)P1kolAeLjEwC0SFeaPM3BOII)0AfNfpceXfX9(N6Z1tYE6pJkwWdoy95YwGAWrJ4E)t95Kx)ojDaPnhdEDTtYFATIZIhcOPRDsFxK6g1F6wxoK0Kpjla89g28uWjl6asBMGhhYcsspJGnbtU1mAtaSXFo(Y2MEKGCNJg39(N6Z1tYE6pJkwWdoy95YwGAWiqCV)P(CYRFNKoG0MJbVU2j5pTwXzrlt8S4Oz)iasnV3qff)P1kolEiGMU2j9DrQBu)PBD5qst(KSaW3ByZtbNSOdiTzcECilijWvQVO4lBB6rIEgbBcMCRz0MayJ)C8LTn9DfJodb001oPVlsDJ6pDRlhsAYNK57jB59uSfadMQhSjczbjXElkiihBbWGP6bBck7TOGGCFz6ircYqanDTt67Iu3O(t36YHKM8jz(EYwEpfBbWGP6bBIqwqsnV4sOgMTwshqQfahpvp301s(rBEXTMrtL6hub301s(qanDTt67Iu3O(t36YHKM8jz(EYwEpfBbWGP6bBIqwqs6zeSjyYTMrBcGn(ZX3yaJg39(N6Z1tYE6pJkwWdoy95YwGAWrbxP(IIVSTPhj6zeSjyY1tYE6pJkwWdoy954lBB67QJaJare37FQpxpj7P)mQybp4G1NlBbQbhpeqtx7K(Ui1nQ)0TUCiPjFsMVNSL3tXwamyQEWMiKfKe4k1xu8LTn9irpJGnbtU1mAtaSXFo(Y2M(U6iWqanDTt67Iu3O(t36YHKM8jrE97K0bKYU86FiliP40ZiytWKBnJ2eaB8NJVXagL9wuqqo491XBkrdoOjJ7lthz4K6C079p1NtE97K0bK2Cm411oj)P1kolEeiArbb5Oz)iasnV3qffhTbbIMxCjdlnafNB6AjFiGMU2j9DrQBu)PBD5qst(KWMCZMsutUrSfk7uPvYipII(uAZhYcsspJGnbtU1mAtaSXFo(Y2MEK0bceLjEwCdldKoG0Q)uMjNNXFATIZqGaBlJEYplUXyE(MijMqanDTt67Iu3O(t36YHKM8j1cuAYtB)PMq2sthYcsspJGnbtUhvwEsQKHLgGIZXx220hEafyeiIOmXZI7rLLNKkzyPbO48NwR4SO1k)W7iWiqeXr6OBtZzCSj3SPe1KBeBHYovALmYJOOpL28qanDTt67Iu3O(t36YHKM8jfOUN2pbfhhYcsQ5fxYWsdqX5MUwYhbIikt8S4Euz5jPsgwAako)P1kolATYp8ocmcerCKo620CghBYnBkrn5gXwOStLwjJ8ik6tPnpeqtx7K(Ui1nQ)0TUCiPjFssM4Atio2tBVfziliPMxCjdlnafNB6AjFeiIOmXZI7rLLNKkzyPbO48NwR4SO1k)W7iWiqeXr6OBtZzCSj3SPe1KBeBHYovALmYJOOpL28qanDTt67Iu3O(t36YHKM8jjHNuYtBWRSjOyt6HSGKWO5rcPyenUALF4DeyeiI4iD0TP5mo2KB2uIAYnITqzNkTsg5ru0NsB(4HaA6AN03fPUBMANmKfKKEgbBcMCdldKoG0Q)u2nghFJbebIMxCjdlnafNB6AjFeiArbb5Oz)iasnV3qffhTbcisbQc022SSn3ucQc0AXOINfuHuHWKqpuTEOYGQg8o4Tacb001oPVlsDpOvl(wKHSGKytXjVyuXZI2imj0ZXheFFV1kE0ikt8S4Oz)iasBfRuFfncSTm6j)S4gJ55hGxF5HaA6AN03fPUh0QfFlYqwqsSP4KxmQ4zrBeMe654dIVV3AfpACruM4zXrZ(raK2kwP(cbIYeploA2pcG0wXk1xr1ZiytWKJM9JaiTvSs9fhFzBtF8rnDTKp95L37dNuhqanDTt67Iu3dA1IVfzilijmAEWblDUhT5yFHTnJghBkoiE8ff8KpMJpi((ERvCeiytXBfZWOnctc9C8bX33BTIhpeqKcubqRRDsOkqwF5HaA6AN03fPU1MqqnDTtsfRVcjn5tspKFAz5HaA6AN03fPU1MqqnDTtsfRVcjn5tspJGnbtpeqtx7K(Ui1T2ecQPRDsQy9viPjFs37FQVhcOPRDsFxK6gJMutx7KuX6Rqst(KS5u)l0MqwqsMUwYN(8Y79HtQJOXPNrWMGjNDR6PwYOSRnGC8LTn9ib5ahnIYeplo7GR4iqONrWMGjNDWvCo(Y2MEKGCGJwM4zXzhCfp(OrWUv9ulzu21gqET6i3uccOPRDsFxK6gJMutx7KuX6Rqst(KS50wuSVczbjz6AjF6ZlV3hoPoIYUv9ulzu21gqET6i3uccOPRDsFxK6gJMutx7KuX6Rqst(KKEE8QP28qwqsMUwYN(8Y79HtQJOXfb7w1tTKrzxBa51QJCtPOXPNrWMGjNDR6PwYOSRnGC8LTn9HJCGJgrzINfNDWvCei0ZiytWKZo4kohFzBtF4ih4OLjEwC2bxXJpEiGMU2j9DrQBTjeutx7KuX6Rqst(KKEE8Qdzbjz6AjF6ZlV3tcziGqarkqfa9eOdvaaf7liGMU2j9CBoTff7lsVzzxE1HSGKWO5QPntWJ5SdU6TqsCih4Uy3QEAK5k1xCWGdAYoJwgw6LhPzmIpk7w1tJmxP(IdgCqt2z0YWsV8ijGIgbzdVwR48MzeBkrbhmvYWsdqXHaA6AN0ZT50wuSV6Iu3VzzxE1HSGKWO5QPntWJ5SdU6TqshXmk7w1tJmxP(IdgCqt2z0YWsV8HhZOrq2WR1koVzgXMsuWbtLmS0auCiGMU2j9CBoTff7RUi19Bw2LxDiliPiy3QEAK5k1xCWGdAYoJwgw6LpAeKn8ATIZBMrSPefCWujdlnafhcOPRDsp3MtBrX(QlsDhCqtg138KDmeqtx7KEUnN2II9vxK6(nl7YRoKfKueKn8ATIZBMrSPefCWujdlnafhcieqKcubqpb6qfXl0giGMU2j9CBo1)cTHKLaPSKfYcsIDR6PrMRuFXbdoOj7mAzyPx(WjPbQfN(8Y79iqGTLrp5Nf3ymp)a86lFuSTm6j)S4gJ554lBB6rcjKrgcOPRDsp3Mt9VqB6Iu3wcKYswilij2TQNgzUs9fhm4GMSZOLHLE5dNumHaA6AN0ZT5u)l0MUi19Bw2LxDiliPiiB41AfN3mJytjk4GPsgwAakEumAUAAZe8yo7GRElK0rGrGOffeK7rzSNu2mYC8nDbb001oPNBZP(xOnDrQBW7RJ3uI6l8g5drduloTmS0lpjKdzbjXElkiih8(64nLObh0KX9LPJejKIru9mc2em5wZOnbWg)54lBB6rsmGaA6AN0ZT5u)l0MUi1n491XBkr9fEJ8HObQfNwgw6LNeYHSGKyVffeKdEFD8Ms0GdAY4(Y0rIeKHaA6AN0ZT5u)l0MUi1n491XBkr9fEJ8HObQfNwgw6LNeYHSGKWO551kFAn0oJK40ZiytWKZUv9ulzu21gqo(Y2M(OruM4zXzhCfhbc9mc2em5SdUIZXx220hTmXZIZo4kE8qanDTt652CQ)fAtxK6(nl7YRoKfKueKn8ATIZBMrSPefCWujdlnafhcieqKcuHuXu7KEOYsgunv)Xq1KqfQ)qanDTt656zeSjy6jH6pDRl7HaA6AN0Z1ZiytW03fPUBMANmKfKuZlUKHLgGIZnDTKpceTOGGC0SFeaPM3BOIIJ2GarzINf3WYaPdiT6pLzY5zrJR5f3WYaPs9dQGB6AjFeiAEXTMrtL6hub301s(iqONrWMGj3WYaPdiT6pLDJXXx220hEzyPx8ALpTgkBF8qarkqvapJGnbtpeqtx7KEUEgbBcM(Ui1THLbshqA1Fk7glKfKKEgbBcMC0SFeaPTIvQV44lBB6rsmJwM4zXrZ(raK2kwP(cbIikt8S4Oz)iasBfRuFbb001oPNRNrWMGPVlsDJM9JaiTvSs9vilijYgETwX5(I2iSm3ukAC6zeSjyYnSmq6asR(tz3yC8LTn9Hhteiy3QEAK5k1xC26TwXP2uS4JgNEgbBcMCRz0MayJ)C8ngWOXXElkiih8(64nLObh0KX9LPJmCsDgbcmA(WjfJ4rGqpJGnbtU1mAtaSXFo(Y2M(4HaA6AN0Z1ZiytW03fPUrZ(raK2kwP(kKfKKPRL8PpV8EF4K6acOPRDspxpJGnbtFxK6Mz4iPf2sp4GLTANmKfKezdVwR4CFrBewMBkfvpJGnbtoA2pcG0wXk1xC8LTn9rJlcmAEWblDo7gtS3xu9SceiWO5bhS05SBmXEFr1ZkIgxeTOGGCMHJKwyl9Gdw2QDsoAt0ikt8S4Oz)iasBmDHarzINfhn7hbqAJPR4JhcOPRDspxpJGnbtFxK6Mz4iPf2sp4GLTANmKfKezdVwR4CFrBewMBkfnIYeploA2pcG0wXk1xqanDTt656zeSjy67Iu3mdhjTWw6bhSSv7KHSGKmDTKp95L37dNuhqanDTt656zeSjy67Iu3wZOnbWg)dzbjz6AjF6ZlV3tc5OS3IccYbVVoEtjAWbnzCFz6idNuNJgxCruM4zXrZ(raK2kwP(cbIYeplUHLbshqA1FkZKZZqGqpjdDlUEsYJ2QDs6asR(tz3yXJarzINfhn7hbqARyL6ROruM4zXnSmq6asR(tzMCEwu2uC0SFeaPTIvQV44lBB6JhcOPRDspxpJGnbtFxK62AgTja24Filijtxl5tFE59(Wj1ru2Brbb5G3xhVPen4GMmUVmDKHtQZrJGDR6PwYOSRnG8A1rUPeeqtx7KEUEgbBcM(Ui1ThvwEsQKHLgGIhYcscJMRM2mbpMZo4Q3cji3ziGMU2j9C9mc2em9DrQB0SFeaPM3BOIkKfKezdVwR4CFrBewMBkfL9wuqqo491XBkrdoOjJ7lthjs6iACnV4wZOPs9dQGB6AjFei0tYq3IRNK8OTANKoG0Q)u2nw8qanDTt656zeSjy67Iu3Oz)iasnV3qfviAGAXPLHLE5jHCilijtxl5tFE59(Wj1ru2Brbb5G3xhVPen4GMmUVmDKiPdiGMU2j9C9mc2em9DrQB)GkO4BnhhIgOwCAzyPxEsihYcsQmS0lETYNwdTrx0yetKeZOLHLEXRv(0AOS9HhtiGMU2j9C9mc2em9DrQBST(tz3yHSGKIO5fxQFqfCtxl5dbecisbQc4H8tllOcGUDfBT3db001oPNRhYpTS8K8bnS8Msu51xHSGKiB41AfN7lAJWYCtPOy0C10Mj4XC2bx9wHhqqanDTt656H8tllFxK62h0WYBkrLxFfYcsY01s(0NxEVpCsDe101s(0NxEVhjKIzumAUAAZe8yo7GRERWJZ01s(0NxEVhPzafpceMUwYN(8Y79HhZOy0C10Mj4XC2bx9wHhJadb001oPNRhYpTS8DrQBRDK30QDsQyLBdzbjr2WR1ko3x0gHL5MsrXO551kFAn0ohECXORwuqqognxnvpymAtTtYXx220hpeqtx7KEUEi)0YY3fPUT2rEtR2jPIvUnKfKKPRL8PpV8EF4K6ikgnpVw5tRH25WJlgD1IccYXO5QP6bJrBQDso(Y2M(4HaA6AN0Z1d5Nww(Ui1TV30rkoT6pfndo4QhyilijYgETwX5(I2iSm3ukQEgbBcMCRz0MayJ)C8LTn9qanDTt656H8tllFxK623B6ifNw9NIMbhC1dmKfKKPRL8PpV8EF4K6iACSBvp1sgLDTbKxRoYnLqGaBlJEYplUXyEo(Y2MEKqc5ohpeqiGMU2j9879p13ts(YdgiDaPcu9YOm8nzFilijmAEETYNwdf5WL0SOy0C10Mj4XiPZbgcOPRDsp)E)t99DrQ7wXmm6asR(tFEzGHSGKy3QEQLmk7AdiVwDKBkHarZlU1mAQu)Gk4MUwYpQPRL8PpV8EpjKHaA6AN0ZV3)uFFxK6wc1WS1s6asTa44P6dzbjfNEgbBcMCRz0MayJ)C8LTn9ijGIQNrWMGj3WYaPdiT6pLDJXXx220hUEgbBcMC9KSN(ZOIf8GdwFo(Y2M(4rGqpJGnbtUHLbshqA1Fk7gJJVSTPhjDab001oPNFV)P((Ui1D1FkA2oOjJcoy9dzbj1IccYXxhP4EpfCW6ZrBqGOffeKJVosX9Ek4G1NQh0SoM7lthjsqgziGMU2j9879p133fPUbhnQ)mQfahV1PT3Kdzbjfb7w1tTKrzxBa51QJCtjiGMU2j9879p133fPU1tQFwyRoJckm5hYcsInfxpP(zHT6mkOWKpTffNC8LTn9Kcmeqtx7KE(9(N677Iu3nO4fe4Ms0wH5RqwqsrWUv9ulzu21gqET6i3uccOPRDsp)E)t99DrQ7GdwWi)nP47N0s9dzbjvM4zXnSmq6asR(tzMCEg)P1kol69(N6ZjV(Ds6asBog86ANKlV5GJ2IccYrZ(raK6l8tPQNJ2GaX9(N6ZjV(Ds6asBog86ANKlV5GJ28IBnJMk1pOcUPRL8rGOmXZIByzG0bKw9NYm58m(tRvCw0MxCRz0uP(bvWnDTKFu9mc2em5gwgiDaPv)PSBmo(Y2M(WdOaJarzINf3WYaPdiT6pLzY5z8NwR4SOnV4gwgivQFqfCtxl5db001oPNFV)P((Ui1DWblyK)Mu89tAP(HSGKIGDR6PwYOSRnG8A1rUPu0wuqqoA2pcGuFHFkv9C0MOrCV)P(CYRFNKoG0MJbVU2j5YBo4OruM4zXnSmq6asR(tzMCEg)P1kodbIYWsV41kFAnu2EKONrWMGj3AgTja24phFzBtpeqtx7KE(9(N677Iu34TPrC6MuFJPFiliPiy3QEQLmk7AdiVwDKBkbb001oPNFV)P((Ui1n(wZMsuqHjFpeqiGifOIytjXHQynS0liGMU2j9CPNhVAsSBvpvpRiKfKulkii3JYypPSzK54B6kAeKn8ATIZBMrSPefCWujdlnafhbIMxCjdlnafNB6AjFiGMU2j9CPNhV6Ui1n7w1t1ZkczbjHrZvtBMGhZzhC1BHeKJr0iiB41AfN3mJytjk4GPsgwAakoeqtx7KEU0ZJxDxK62sGuwYczbjPNrWMGj3AgTja24phFzBtF04kt8S4SdUIZFATIZqGqpKFAzXZvQVOG2JhcOPRDspx65XRUlsDhCqtg138KDCilij2Brbb5G3xhVPen4GMmUVmDKH3ziGMU2j9CPNhV6Ui1DWbnzuFZt2XHSGKyVffeKdEFD8Ms0GdAY4Onr1ZiytWKBnJ2eaB8NJVSTPp8ygnUikt8S4Oz)iasBfRuFHarzINf3WYaPdiT6pLzY5ziqONKHUfxpj5rB1ojDaPv)PSBmeiW2YON8ZIBmMNFaE9LpEiGMU2j9CPNhV6Ui1DWbnzuFZt2XHSGKyVffeKdEFD8Ms0GdAY4Onrlt8S4Oz)iasBfRuFfnIYeplUHLbshqA1FkZKZZIgHEsg6wC9KKhTv7K0bKw9NYUXIgb2wg9KFwCJX88dWRV8rJtpJGnbtoA2pcG0wXk1xC8LTn9HhZO6zeSjyYTMrBcGn(ZX3yaJgbBkoA2pcG0wXk1xC8LTn9iqeHEgbBcMCRz0MayJ)C8ngW4HaA6AN0ZLEE8Q7Iu3SBvpvpRiKfKegnxnTzcEmNDWvVfs6iWrJGSHxRvCEZmInLOGdMkzyPbO4qanDTt65sppE1DrQBW7RJ3uI6l8g5dzbjXElkiih8(64nLObh0KX9LPJejidb001oPNl984v3fPUbVVoEtjQVWBKpKfKe7TOGGCW7RJ3uIgCqtg3xMosK05O6zeSjyYTMrBcGn(ZXx220JKyenUikt8S4Oz)iasBfRuFHarzINf3WYaPdiT6pLzY5ziqONKHUfxpj5rB1ojDaPv)PSBmeiW2YON8ZIBmMNFaE9LpEiGMU2j9CPNhV6Ui1n491XBkr9fEJ8HSGKyVffeKdEFD8Ms0GdAY4(Y0rIKohTmXZIJM9JaiTvSs9v0ikt8S4gwgiDaPv)PmtoplAe6jzOBX1tsE0wTtshqA1Fk7glAeyBz0t(zXngZZpaV(YhvpJGnbtU1mAtaSXFo(gdy040ZiytWKJM9JaiTvSs9fhFzBtpsIbceSP4Oz)iasBfRuFXXx220hpeqtx7KEU0ZJxDxK6MDR6P6zfHSGKIGSHxRvCEZmInLOGdMkzyPbO4qaHaIuGkKgppE1qfa9eOdvivG3bVfqiGMU2j9CPNhVAQnN0Bw2LxDiliPwuqqUhLXEszZiZX30feqtx7KEU0ZJxn1M3fPUFZYU8QdzbjfbzdVwR48MzeBkrbhmvYWsdqXHaA6AN0ZLEE8QP28Ui1DWbnzuFZt2XHObQfNwgw6LNeYHSGKItpJGnbtU1mAtaSXFo(Y2M(WJzu2Brbb5G3xhVPen4GMmoAdceS3IccYbVVoEtjAWbnzCFz6idVZXhnoWvQVO4lBB6rIEgbBcMC2TQNAjJYU2aYXx2203fYbgbcWvQVO4lBB6dxpJGnbtU1mAtaSXFo(Y2M(4HaA6AN0ZLEE8QP28Ui1n491XBkr9fEJ8HObQfNwgw6LNeYHSGKyVffeKdEFD8Ms0GdAY4(Y0rIesXiQEgbBcMCRz0MayJ)C8LTn9ijgiqWElkiih8(64nLObh0KX9LPJejidb001oPNl984vtT5DrQBW7RJ3uI6l8g5drduloTmS0lpjKdzbjPNrWMGj3AgTja24phFzBtF4Xmk7TOGGCW7RJ3uIgCqtg3xMosKGSRCLZba]] )

end
