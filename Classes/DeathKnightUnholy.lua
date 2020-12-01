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


    spec:RegisterPack( "Unholy", 20201201, [[d0K44bqiPepsQO6scrHnjK(ejLrHu1PqQSkHOiVcaMLqyxe9lPsnmsQ6yijltQKNHKQPbq5AiPSnHO6BafLXbuKohjvW6ak18aq3dPSpPchuQO0cbipeGQjssfDrPIcFeOOYjbkcReO6LafrntGsUPquuTtPu(jqrKHssfYsLkk6POYuLs1vbkQARcrr5RKuHAScr2RG)sXGH6WuTyP4XKAYeUSQndPptIrlvDALwTqu61sjnBuUnQA3I(TIHluhhOWYr8CknDjxhITJeFNKmEPICEGSEsQ08b0(bDGQq7boHxp0wxQVl1tvxQNkjvuNADrnW0axbk(bUyx3QR8ax68pWbMp7hgOaxSdInUi0EGZoie9dC9vfBb7U7wzREKgPE472U8imV2j1ehT62U86UdCnilRatKHMaNWRhARl13L6PQl1tLKkQtTUOoywGZgFDOTUOwxbU(viEgAcCIB1bUohIvN3REigm5Cv6ligmF2pmqqW7CiwDE95BobIPkciUl13L6HGdbVZH4oRiYIyl(NLfIRbIvNP6SB15rx27wDEV6TqS6e5qCnq8KmqqSEqYcIlNO8YcXQ6hi2jhIFNIVUUaIRbIzlLdXSjvG4NdIspexdeZ7vDcetVp3yFHedXDov0jdCS1w2q7boXrDewfAp0gvH2dCUU2jdC8BkmOKF19bUNEd7IaGcvOTUcTh4E6nSlcakWnXbo7RaNRRDYahfNSEd7bokod5bo9mmXOkLweE(jnkorzaXUKCEFtledqiMAqCuiUC2ZsAr45N0O4eLbe7YNEd7IahfNysN)bU4zyBQyqhIrXjkdi2dvOnQhApW90ByxeauGBIdC2xboxx7Kbokoz9g2dCuCgYdCUUwk38887TqmniMkioketpe3cet8vyoLNL0fcR8DATLfIbceIj(kmNYZs6cHvUje3betf1Gy6cCuCIjD(h4SLjM5zUPsOcTbyH2dCp9g2fbaf40KToz9ahbjxTjEuDIuC0vVfe3beh5udIJcX0dXXVKkorzaXU011s5qmqGqClqC5SNL0IWZpPrXjkdi2Lp9g2fqmDqCuiMGKxko6Q3cI7GgetTaNRRDYaNt0EEtneYZkuH2OwO9a3tVHDraqbonzRtwpWf)sQ4eLbe7sxxlLdXabcXniOOsKSFyGmU16iSsIedXabcXLZEwsNWdYmOMQ)gHZNxiF6nSlG4OqC8lPhpAJs)GWKUUwkhIJcX0dXXVKoHhKrPFqysxxlLdXabcX6zyIrvkDcpiZGAQ(Be3fsY59nTqChqSEgMyuLYg2mcdkcbKuGq8ANeI7gIPoethedeieJUk9LHCEFtledqAqCdckQSHnJWGIqajfieV2jdCUU2jdCnSzeguecOqfAlYdTh4E6nSlcakWPjBDY6bU4xsfNOmGyx66APCigiqiUbbfvIK9ddKXTwhHvsKyigiqiUC2Zs6eEqMb1u93iC(8c5tVHDbehfIJFj94rBu6heM011s5qCuiMEio(L0j8Gmk9dct66APCigiqiwpdtmQsPt4bzgut1FJ4UqsoVVPfI7aI1ZWeJQu2CI9Kw3urkqiETtcXDdXuhIPdIbceIrxL(YqoVVPfIbiniUbbfv2CI9Kw3urkqiETtg4CDTtg4AoXEsRBQeQqBGzH2dCp9g2fbaf40KToz9axdckQej7hgiJTipvQEjsCGZ11ozGJTk9L1ezrek8pRqfAdmn0EG7P3WUiaOaNMS1jRh4IFjvCIYaIDPRRLYHyGaH4geuujs2pmqg3ADewjrIHyGaH4YzplPt4bzgut1FJW5ZlKp9g2fqCuio(L0JhTrPFqysxxlLdXrHy6H44xsNWdYO0pimPRRLYHyGaHy9mmXOkLoHhKzqnv)nI7cj58(MwiUdiwpdtmQsPN6BlIZmANXKceIx7KqC3qm1Hy6GyGaHy0vPVmKZ7BAHyasdIPIAboxx7Kbop13weNz0oJfQqBQdH2dCp9g2fbaf40KToz9aNRRLYnpp)Ele3bniUligiqiMEiMGKxko6Q3cI7GgetnioketqYvBIhvNifhD1BbXDqdIJC1dX0f4CDTtg4CI2ZBIry2hQqBuP(q7bUNEd7IaGcCAYwNSEGl(LuXjkdi2LUUwkhIbceIBqqrLiz)WazCR1ryLejgIbceIlN9SKoHhKzqnv)ncNpVq(0ByxaXrH44xspE0gL(bHjDDTuoehfIPhIJFjDcpiJs)GWKUUwkhIbceI1ZWeJQu6eEqMb1u93iUlKKZ7BAH4oGy9mmXOkLOl5nSzesbcXRDsiUBiM6qmDqmqGqm6Q0xgY59nTqmaPbXniOOs0L8g2mcPaH41ozGZ11ozGdDjVHnJiuH2OIQq7bUNEd7IaGcCAYwNSEGRbbfvIK9ddKXwKNkvVejgIJcXUUwk38887TqmniMQaNRRDYaxJRygutrwDR2qfAJQUcTh4E6nSlcakWPjBDY6bUA5pe3be3L6HyGaH4wG4dgiBC8fsIZhVPIX5JzBHiUrzvCkdRmpv28qmqGqClq8bdKno(cjL1UtAguJ48R9boxx7Kboe7nBDEBOcTrf1dTh4E6nSlcakW56ANmW5QRT3jU1Gozzgut8O6KaNMS1jRh4OhIV1(uFjL1UtAgut8jOxx7KYNEd7cioke3cexo7zjrY(HbY4wRJWk5tVHDbethedeietpe3ceFR9P(s9KIN2lmSf9OdrFjVhzhcehfIBbIV1(uFjL1UtAgut8jOxx7KYNEd7ciMUax68pW5QRT3jU1Gozzgut8O6KqfAJkal0EG7P3WUiaOaNRRDYaNRU2EN4wd6KLzqnXJQtcCAYwNSEGtpdtmQsPhpANbk2Ej58(MwigGqmvagehfIPhIV1(uFPEsXt7fg2IE0HOVK3JSdbIbceIV1(uFjL1UtAgut8jOxx7KYNEd7ciokexo7zjrY(HbY4wRJWk5tVHDbetxGlD(h4C1127e3AqNSmdQjEuDsOcTrf1cTh4E6nSlcakW56ANmW5QRT3jU1Gozzgut8O6KaNMS1jRh4qxL(YqoVVPfIbieRNHjgvP0JhTZafBVKCEFtledaiM6awGlD(h4C1127e3AqNSmdQjEuDsOcTrvKhApW90ByxeauGZ11ozGZT9u88wdXv3Hy0dXzbonzRtwpWjEdckQK4Q7qm6H4mJ4niOOsB56wHyacXuf4sN)bo32tXZBnexDhIrpeNfQqBubMfApW90ByxeauGZ11ozGZT9u88wdXv3Hy0dXzbonzRtwpWf)sQG4eX6PzqnU6EYu9sxxlLdXrH44xspE0gL(bHjDDTuEGlD(h4CBpfpV1qC1Dig9qCwOcTrfyAO9a3tVHDraqboxx7Kbo32tXZBnexDhIrpeNf40KToz9aNEgMyuLspE0oduS9sYDbiioketpeFR9P(s9KIN2lmSf9OdrFjVhzhcehfIrxL(YqoVVPfIbieRNHjgvPupP4P9cdBrp6q0xsoVVPfIbae3L6HyGaH4wG4BTp1xQNu80EHHTOhDi6l59i7qGy6cCPZ)aNB7P45TgIRUdXOhIZcvOnQuhcTh4E6nSlcakW56ANmW52EkEERH4Q7qm6H4SaNMS1jRh4qxL(YqoVVPfIbieRNHjgvP0JhTZafBVKCEFtledaiUl1h4sN)bo32tXZBnexDhIrpeNfQqBDP(q7bUNEd7IaGcCUU2jdCuw7oPzqnIZV2h40KToz9ah9qSEgMyuLspE0oduS9sYDbiiokelEdckQe926KnvmQgKuiTLRBfI7GgedyqCui(w7t9Luw7oPzqnXNGEDTtkF6nSlGy6GyGaH4geuujs2pmqg3ADewjrIHyGaH44xsfNOmGyx66AP8ax68pWrzT7KMb1io)AFOcT1fvH2dCp9g2fbaf4CDTtg4ioF8MkgNpMTfI4gLvXPmSY8uzZh40KToz9aNEgMyuLspE0oduS9sY59nTqmaH4UGyGaH4YzplPt4bzgut1FJW5ZlKp9g2fqmqGqmXxH5uEwsxiSYnHyacXulWLo)dCeNpEtfJZhZ2crCJYQ4ugwzEQS5dvOTU6k0EG7P3WUiaOaNRRDYaxdiLjVP534mEpDDGtt26K1dC6zyIrvkTi88tAuCIYaIDj58(MwiUdioYvpedeie3cexo7zjTi88tAuCIYaID5tVHDbehfIRL)qChqCxQhIbceIBbIpyGSXXxijoF8MkgNpMTfI4gLvXPmSY8uzZh4sN)bUgqktEtZVXz8E66qfARlQhApW90ByxeauGZ11ozGlYERPFuXojWPjBDY6bU4xsfNOmGyx66APCigiqiUfiUC2ZsAr45N0O4eLbe7YNEd7ciokexl)H4oG4Uupedeie3ceFWazJJVqsC(4nvmoFmBleXnkRItzyL5PYMpWLo)dCr2Bn9Jk2jHk0wxawO9a3tVHDraqboxx7KbofNDTZyNynn3BnWPjBDY6bU4xsfNOmGyx66APCigiqiUfiUC2ZsAr45N0O4eLbe7YNEd7ciokexl)H4oG4Uupedeie3ceFWazJJVqsC(4nvmoFmBleXnkRItzyL5PYMpWLo)dCko7ANXoXAAU3AOcT1f1cTh4E6nSlcakW56ANmWPqMuXAIjlVZmex5bonzRtwpWrqYdXaKgetDioketpexl)H4oG4Uupedeie3ceFWazJJVqsC(4nvmoFmBleXnkRItzyL5PYMhIPlWLo)dCkKjvSMyYY7mdXvEOcT1vKhApW90ByxeauGtt26K1dC6zyIrvkDcpiZGAQ(Be3fsYDbiigiqio(LuXjkdi2LUUwkhIbceIBqqrLiz)WazCR1ryLejoW56ANmWfp1ozOcT1fywO9a3tVHDraqbonzRtwpWjMsszjiSNLjM5kixsok52EVHDioke3cexo7zjrY(HbY0WwL(s(0ByxaXrH4wGyIVcZP8SKUqyLVtRTSboxx7KbUbPAi3BnuH26cmn0EG7P3WUiaOaNMS1jRh4etjPSee2ZYeZCfKljhLCBV3WoehfIPhIBbIlN9SKiz)WazAyRsFjF6nSlGyGaH4Yzpljs2pmqMg2Q0xYNEd7ciokeRNHjgvPej7hgitdBv6lj58(MwiMoioke76APCZZZV3cXDqdI7kW56ANmWnivd5ERHk0wxQdH2dCp9g2fbaf40KToz9ahbjp6quU0IeFITi(MYNEd7cioketpelMsIsgBzqpLtKKJsUT3ByhIbceIftjByZimXmxb5sYrj327nSdX0f4CDTtg4gKQHCV1qfAJ6Qp0EG7P3WUiaOaNRRDYaN2zmJRRDsdBTvGJT2YKo)dC6HYtplBOcTrDQcTh4E6nSlcakW56ANmWPDgZ46AN0WwBf4yRTmPZ)aNEgMyuL2qfAJ6DfApW90ByxeauGZ11ozGt7mMX11oPHT2kWXwBzsN)bUBTp13gQqBuN6H2dCp9g2fbaf40KToz9aNRRLYnpp)Ele3bniUlioketpeRNHjgvPuCV6nEkmIRDqsY59nTqmaHyQupehfIBbIlN9SKIJUSlF6nSlGyGaHy9mmXOkLIJUSljN330cXaeIPs9qCuiUC2Zsko6YU8P3WUaIPdIJcXTaXI7vVXtHrCTdswRU1nvcCUU2jdCeK046AN0WwBf4yRTmPZ)aNp3yFHehQqBuhWcTh4E6nSlcakWPjBDY6boxxlLBEE(9wiUdAqCxqCuiwCV6nEkmIRDqYA1TUPsGZ11ozGJGKgxx7Kg2ARahBTLjD(h485MgeITcvOnQtTq7bUNEd7IaGcCAYwNSEGZ11s5MNNFVfI7Gge3fehfIPhIBbIf3REJNcJ4AhKSwDRBQaXrHy6Hy9mmXOkLI7vVXtHrCTdssoVVPfI7aIPs9qCuiUfiUC2Zsko6YU8P3WUaIbceI1ZWeJQuko6YUKCEFtle3betL6H4OqC5SNLuC0LD5tVHDbethetxGZ11ozGJGKgxx7Kg2ARahBTLjD(h4uEEYQn(8qfAJ6rEO9a3tVHDraqbonzRtwpW56APCZZZV3cX0GyQcCUU2jdCANXmUU2jnS1wbo2Alt68pWP88KvhQqf4uEEYQdThAJQq7bUNEd7IaGcCAYwNSEGRbbfvAreINgXm8sYDDbXrH4wGykoz9g2LXZW2uXGoeJItugqSdXabcXXVKkorzaXU011s5boxx7KboX9Q3ONLfQqBDfApW90ByxeauGtt26K1dCeKC1M4r1jsXrx9wqmaHyQOoehfIBbIP4K1ByxgpdBtfd6qmkorzaXEGZ11ozGtCV6n6zzHk0g1dTh4E6nSlcakWPjBDY6bo9mmXOkLE8ODgOy7LKZ7BAH4Oqm9qC5SNLuC0LD5tVHDbedeieRhkp9SK5Q0xgu)qmqGqmbjp6quUmU)oz4N8w5tVHDbetxGZ11ozGZtqgrkcvOnal0EG7P3WUiaOaNMS1jRh4eVbbfvIEBDYMkgvdskK2Y1TcXDaXawGZ11ozGt1GKcJn(P4KqfAJAH2dCp9g2fbaf40KToz9aN4niOOs0BRt2uXOAqsHejgIJcX6zyIrvk94r7mqX2ljN330cXDaXudIJcX0dXTaXLZEwsKSFyGmnSvPVKp9g2fqmqGqC5SNL0j8GmdQP6Vr485fYNEd7cigiqiwpPazlPEskJ2RDsZGAQ(Be3fYNEd7cigiqiM4RWCkplPlew570AlletxGZ11ozGt1GKcJn(P4KqfAlYdTh4E6nSlcakWPjBDY6boXBqqrLO3wNSPIr1GKcjsmehfIlN9SKiz)WazAyRsFjF6nSlG4OqClqC5SNL0j8GmdQP6Vr485fYNEd7cioke3ceRNuGSLupjLr71oPzqnv)nI7c5tVHDbehfIBbIj(kmNYZs6cHv(oT2YcXrHy6Hy9mmXOkLiz)WazAyRsFjjN330cXDaXudIJcX6zyIrvk94r7mqX2lj3fGG4OqClqSykjs2pmqMg2Q0xsY59nTqmqGqClqSEgMyuLspE0oduS9sYDbiiMUaNRRDYaNQbjfgB8tXjHk0gywO9a3tVHDraqbonzRtwpWrqYvBIhvNifhD1BbXaeI7s9qCuiUfiMItwVHDz8mSnvmOdXO4eLbe7boxx7KboX9Q3ONLfQqBGPH2dCp9g2fbaf40KToz9aN4niOOs0BRt2uXOAqsH0wUUvigGqmvboxx7Kbo0BRt2uXylY26dvOn1Hq7bUNEd7IaGcCAYwNSEGt8geuuj6T1jBQyuniPqAlx3kedqigWG4OqSEgMyuLspE0oduS9sY59nTqmaHyQdXrHy6H4wG4Yzpljs2pmqMg2Q0xYNEd7cigiqiUC2Zs6eEqMb1u93iC(8c5tVHDbedeieRNuGSLupjLr71oPzqnv)nI7c5tVHDbedeiet8vyoLNL0fcR8DATLfIPlW56ANmWHEBDYMkgBr2wFOcTrL6dTh4E6nSlcakWPjBDY6boXBqqrLO3wNSPIr1GKcPTCDRqmaHyadIJcXLZEwsKSFyGmnSvPVKp9g2fqCuiUfiUC2Zs6eEqMb1u93iC(8c5tVHDbehfIBbI1tkq2sQNKYO9AN0mOMQ)gXDH8P3WUaIJcXTaXeFfMt5zjDHWkFNwBzH4OqSEgMyuLspE0oduS9sYDbiioketpeRNHjgvPej7hgitdBv6lj58(MwigGqm1HyGaHyXusKSFyGmnSvPVKKZ7BAHy6cCUU2jdCO3wNSPIXwKT1hQqBurvO9a3tVHDraqbonzRtwpW1cetXjR3WUmEg2Mkg0HyuCIYaI9aNRRDYaN4E1B0ZYcvOcC6HYtplBO9qBufApW90ByxeauGtt26K1dCuCY6nSlTLjM5zUPcehfIji5QnXJQtKIJU6TG4oG4ipW56ANmWzv5e(nvm8RTcvOTUcTh4E6nSlcakWPjBDY6bo9mmXOkLE8ODgOy7LKZ7BAH4Oqm9qSRRLYnpp)Ele3bniUlioke76APCZZZV3cXaKgetnioketqYvBIhvNifhD1BbXDaX0dXUUwk38887TqCKjioYHy6GyGaHyxxlLBEE(9wiUdiMAqCuiMGKR2epQorko6Q3cI7aIPU6Hy6cCUU2jdCwvoHFtfd)ARqfAJ6H2dCp9g2fbaf40KToz9ahfNSEd7sBzIzEMBQaXrHycsEzT83uJbWG4oGy6HyQdXaaIBqqrLeKC1g9qiiX1oPKCEFtletxGZ11ozGZBg(n9AN0Ww(MqfAdWcTh4E6nSlcakWPjBDY6boxxlLBEE(9wiUdAqCxqCuiMGKxwl)n1yamiUdiMEiM6qmaG4geuujbjxTrpecsCTtkjN330cX0f4CDTtg48MHFtV2jnSLVjuH2OwO9a3tVHDraqbonzRtwpWrXjR3WU0wMyMN5MkqCuiwpdtmQsPhpANbk2Ej58(M2aNRRDYaNT31TYUP6VbjvnKQhuOcTf5H2dCp9g2fbaf40KToz9aNRRLYnpp)Ele3bniUlioketpelUx9gpfgX1oizT6w3ubIbceIj(kmNYZs6cHvsoVVPfIbiniMkadIPlW56ANmWz7DDRSBQ(BqsvdP6bfQqf4Ijxp8nEfAp0gvH2dCUU2jdCXtTtg4E6nSlcakuH26k0EG7P3WUiaOax68pW5QRT3jU1Gozzgut8O6KaNRRDYaNRU2EN4wd6KLzqnXJQtcvOnQhApW56ANmWr81EJ4UiW90ByxeauOcvGtpdtmQsBO9qBufApW90ByxeauGtt26K1dCXVKkorzaXU011s5qmqGqCdckQej7hgiJBTocRKiXqmqGqC5SNL0j8GmdQP6Vr485fYNEd7cioketpeh)s6eEqgL(bHjDDTuoedeieh)s6XJ2O0pimPRRLYHyGaHy9mmXOkLoHhKzqnv)nI7cj58(MwiUdigDv6ld58(MwiMUaNRRDYax8u7KHk0wxH2dCp9g2fbaf4CDTtg420QjiL3WUbmq8Sq4nItz1pWPjBDY6bo9mmXOkLiz)WazAyRsFjjN330cXrHy6H44xsNWdYO0pimPRRLYHyGaHy9mmXOkLE8ODgOy7LKZ7BAHyacXudIJcX0dX6zyIrvkDcpiZGAQ(Be3fsY59nTqmqGqS4E1BAnxL(skwR3WUXNsaX0bX0bXabcXLtuEjRL)MAmX6Y0L6HyacXulWLo)dCBA1eKYBy3agiEwi8gXPS6hQqBup0EG7P3WUiaOaNRRDYahVR9gYn2()YWJyxDGtt26K1dC6zyIrvk94r7mqX2ljN330cXaeIPgehfIPhIBbIpyGSXXxi30QjiL3WUbmq8Sq4nItz1hIbceI1ZWeJQuUPvtqkVHDdyG4zHWBeNYQVKCEFtletxGlD(h44DT3qUX2)xgEe7QdvOnal0EG7P3WUiaOaNRRDYaNGCxGUKBOCR9SaNMS1jRh40ZWeJQu6XJ2zGITxsoVVPfIJcXeK8YA5VPgdGbXaeIv0cioketpe3ceFWazJJVqUPvtqkVHDdyG4zHWBeNYQpedeieRNHjgvPCtRMGuEd7gWaXZcH3ioLvFj58(MwiMUax68pWji3fOl5gk3ApluH2OwO9a3tVHDraqboxx7Kboe7nBD(aNMS1jRh4IFj94rBu6heM011s5qCuiMEiUfi(GbYghFHCtRMGuEd7gWaXZcH3ioLvFigiqiwpdtmQs5MwnbP8g2nGbINfcVrCkR(sY59nTqmDbU05FGt4Kw5NjnIRB1q5KrVfOqfAlYdTh4E6nSlcakWPjBDY6bo9mmXOkLE8ODgOy7LKZ7BAH4Oqm9qClq8bdKno(c5MwnbP8g2nGbINfcVrCkR(qmqGqSEgMyuLYnTAcs5nSBadepleEJ4uw9LKZ7BAHy6cCUU2jdCi2B2682qfAdml0EG7P3WUiaOaNMS1jRh4eVbbfvIEBDYMkgvdskKiXqCuiwpdtmQsjs2pmqMg2Q0xsY59nTqmaHyQbXrH4Yzpljs2pmqMg2Q0xYNEd7cigiqiUfiUC2ZsIK9ddKPHTk9L8P3WUiW56ANmW5eEqMb1u93iUlcvOnW0q7bUNEd7IaGcCAYwNSEGJItwVHDPTmXmpZnvG4Oqm9qSEgMyuLsNWdYmOMQ)gXDHKCEFtle3betnigiqiwCV6nTMRsFjfR1By34tjGy6G4Oqm9qSEgMyuLspE0oduS9sYDbiioketpelEdckQe926KnvmQgKuiTLRBfI7GgedyqmqGqmbjpe3bniM6qmDqmqGqSEgMyuLspE0oduS9sY59nTqmDboxx7KboKSFyGmnSvPVcvOn1Hq7bUNEd7IaGcCAYwNSEGZ11s5MNNFVfI7Gge3vGZ11ozGdj7hgitdBv6RqfAJk1hApW90ByxeauGtt26K1dCuCY6nSlTLjM5zUPcehfI1ZWeJQuIK9ddKPHTk9LKCEFtlehfIPhIBbIji5rhIYLI7c2EBz0ZYKp9g2fqmqGqmbjp6quUuCxW2BlJEwM8P3WUaIJcX0dXTaXniOOsHtA1uepTOdH3RDsjsmehfIBbIlN9SKiz)WazIDDjF6nSlGyGaH4Yzpljs2pmqMyxxYNEd7ciMoiMUaNRRDYaNWjTAkINw0HW71ozOcTrfvH2dCp9g2fbaf40KToz9ahfNSEd7sBzIzEMBQaXrH4wG4Yzpljs2pmqMg2Q0xYNEd7IaNRRDYaNWjTAkINw0HW71ozOcTrvxH2dCp9g2fbaf40KToz9aNRRLYnpp)Ele3bniURaNRRDYaNWjTAkINw0HW71ozOcTrf1dTh4E6nSlcakWPjBDY6boxxlLBEE(9wiMgetfehfIfVbbfvIEBDYMkgvdskK2Y1TcXDqdIbmioketpetpe3cexo7zjrY(HbY0WwL(s(0ByxaXabcXLZEwsNWdYmOMQ)gHZNxiF6nSlGyGaHy9KcKTK6jPmAV2jndQP6VrCxiF6nSlGy6GyGaH4Yzpljs2pmqMg2Q0xYNEd7cioke3cexo7zjDcpiZGAQ(BeoFEH8P3WUaIJcXIPKiz)WazAyRsFjjN330cX0f4CDTtg484r7mqX2hQqBubyH2dCp9g2fbaf40KToz9aNRRLYnpp)Ele3bniUliokelEdckQe926KnvmQgKuiTLRBfI7GgedyqCuiUfiwCV6nEkmIRDqYA1TUPsGZ11ozGZJhTZafBFOcTrf1cTh4E6nSlcakWPjBDY6bocsUAt8O6eP4OREligGqmvawGZ11ozGZIWZpPrXjkdi2dvOnQI8q7bUNEd7IaGcCAYwNSEGJItwVHDPTmXmpZnvG4OqS4niOOs0BRt2uXOAqsH0wUUvigGqCxqCuiMEio(L0JhTrPFqysxxlLdXabcX6jfiBj1tsz0ETtAgut1FJ4Uq(0ByxaXrHy9mmXOkLE8ODgOy7LKZ7BAHy6cCUU2jdCiz)WazCR1ryvOcTrfywO9a3tVHDraqboxx7KboKSFyGmU16iSkWPjBDY6boxxlLBEE(9wiUdAqCxqCuiw8geuuj6T1jBQyuniPqAlx3kedqiURaNgKMDt5eLx2qBufQqBubMgApW90ByxeauGZ11ozGZoimd5E8jbonzRtwpWvor5LSw(BQXeRld1PgedqiMAqCuiUCIYlzT83uJrShI7aIPwGtdsZUPCIYlBOnQcvOnQuhcTh4E6nSlcakWPjBDY6bUwG44xsL(bHjDDTuEGZ11ozGJ4R9gXDrOcvGt55jR24ZdThAJQq7bUNEd7IaGcCAYwNSEGRbbfvAreINgXm8sYDDf4CDTtg4E8ko)QdvOTUcTh4E6nSlcakWPjBDY6bUwGykoz9g2LXZW2uXGoeJItugqSh4CDTtg4E8ko)QdvOnQhApW90ByxeauGZ11ozGt1GKcJn(P4KaNMS1jRh4OhI1ZWeJQu6XJ2zGITxsoVVPfI7aIPgehfIfVbbfvIEBDYMkgvdskKiXqmqGqS4niOOs0BRt2uXOAqsH0wUUviUdigWGy6G4Oqm9qm6Q0xgY59nTqmaHy9mmXOkLI7vVXtHrCTdssoVVPfIbaetL6HyGaHy0vPVmKZ7BAH4oGy9mmXOkLE8ODgOy7LKZ7BAHy6cCAqA2nLtuEzdTrvOcTbyH2dCp9g2fbaf4CDTtg4qVToztfJTiBRpWPjBDY6boXBqqrLO3wNSPIr1GKcPTCDRqmaPbXuhIJcX6zyIrvk94r7mqX2ljN330cXaeIPoedeielEdckQe926KnvmQgKuiTLRBfIbietvGtdsZUPCIYlBOnQcvOnQfApW90ByxeauGZ11ozGd926Knvm2IST(aNMS1jRh40ZWeJQu6XJ2zGITxsoVVPfI7aIPgehfIfVbbfvIEBDYMkgvdskK2Y1TcXaeIPkWPbPz3uor5Ln0gvHkuboFUPbHyRq7H2Ok0EG7P3WUiaOaNMS1jRh4ii5QnXJQtKIJU6TGyacX0dXuPEigaqS4E1BAnxL(sIQAqsXfMYjkVSqCKjiM6qmDqCuiwCV6nTMRsFjrvniP4ct5eLxwigGqCKdXrH4wGykoz9g2LXZW2uXGoeJItugqSdXabcXniOOsRkNWVPIHFTLejoW56ANmW94vC(vhQqBDfApW90ByxeauGtt26K1dCeKC1M4r1jsXrx9wqmaH4UOgehfIf3REtR5Q0xsuvdskUWuor5LfI7aIPgehfIBbIP4K1ByxgpdBtfd6qmkorzaXEGZ11ozG7XR48RouH2OEO9a3tVHDraqbonzRtwpW1celUx9MwZvPVKOQgKuCHPCIYllehfIBbIP4K1ByxgpdBtfd6qmkorzaXoedeieJUk9LHCEFtledqiMAqmqGqmXxH5uEwsxiSY3P1wwioket8vyoLNL0fcRKCEFtledqiMAboxx7KbUhVIZV6qfAdWcTh4CDTtg4uniPWyJFkojW90ByxeauOcTrTq7bUNEd7IaGcCAYwNSEGRfiMItwVHDz8mSnvmOdXO4eLbe7boxx7KbUhVIZV6qfQaNp3yFHehAp0gvH2dCp9g2fbaf40KToz9aN4E1BAnxL(sIQAqsXfMYjkVSqCh0Gynin7MNNFVfIbceIj(kmNYZs6cHv(oT2YcXrHyIVcZP8SKUqyLKZ7BAHyasdIPIQaNRRDYaNNGmIueQqBDfApW90ByxeauGtt26K1dCI7vVP1Cv6ljQQbjfxykNO8YcXDqdIPwGZ11ozGZtqgrkcvOnQhApW90ByxeauGtt26K1dCTaXuCY6nSlJNHTPIbDigfNOmGypW56ANmW94vC(vhQqBawO9a3tVHDraqboxx7Kbo0BRt2uXylY26dCAYwNSEGt8geuuj6T1jBQyuniPqAlx3kedqAqm1H4OqSEgMyuLspE0oduS9sY59nTqmaHyQh40G0SBkNO8YgAJQqfAJAH2dCp9g2fbaf4CDTtg4qVToztfJTiBRpWPjBDY6boXBqqrLO3wNSPIr1GKcPTCDRqmaHyQcCAqA2nLtuEzdTrvOcTf5H2dCp9g2fbaf4CDTtg4qVToztfJTiBRpWPjBDY6bocsEzT83uJbWGyacX0dX6zyIrvkf3REJNcJ4AhKKCEFtlehfIBbIlN9SKIJUSlF6nSlGyGaHy9mmXOkLIJUSljN330cXrH4YzplP4Ol7YNEd7ciMUaNgKMDt5eLx2qBufQqfQahLtS7KH26s9DPEQOQlalWPYj5Mk2aN64oBNzBGjAdmhydXqC79hIx(4Huqm6qGy1uEEYQvdIjhmqwYfqSD4pe7i1W71fqSU3tLBLqWbRnpetDWgIb8jPCsDbeRgbjp6quUmsQbX1aXQrqYJoeLlJK8P3WUqniMEQ6eDsi4G1MhIPgydXa(KuoPUaIvRC2Zsgj1G4AGy1kN9SKrs(0ByxOgetFxDIojeCWAZdXudSHyaFskNuxaXQPNuGSLmsQbX1aXQPNuGSLmsYNEd7c1Gy6PQt0jHGdwBEioYbBigWNKYj1fqSALZEwYiPgexdeRw5SNLmsYNEd7c1Gy67Qt0jHGdwBEioYbBigWNKYj1fqSA6jfiBjJKAqCnqSA6jfiBjJK8P3WUqniMEQ6eDsi4G1MhIvhaBigWNKYj1fqSALZEwYiPgexdeRw5SNLmsYNEd7c1Gy67Qt0jHGdwBEiwDaSHyaFskNuxaXQPNuGSLmsQbX1aXQPNuGSLmsYNEd7c1Gy6PQt0jHGdwBEiMk1d2qmGpjLtQlGy1kN9SKrsniUgiwTYzplzKKp9g2fQbX03vNOtcbhS28qmvQhSHyaFskNuxaXQPNuGSLmsQbX1aXQPNuGSLmsYNEd7c1Gy6PQt0jHGdbxDCNTZSnWeTbMdSHyiU9(dXlF8qkigDiqSA(CJ9fsSAqm5GbYsUaITd)HyhPgEVUaI19EQCRecoyT5H4ihSHyaFskNuxaXQvo7zjJKAqCnqSALZEwYijF6nSludIPVRorNecoeC1XD2oZ2at0gyoWgIH427peV8XdPGy0HaXQjoQJWk1GyYbdKLCbeBh(dXosn8EDbeR79u5wjeCWAZdXDb2qmGpjLtQlGy1kN9SKrsniUgiwTYzplzKKp9g2fQbXEbXDgGjbwqm9u1j6KqWbRnpetnWgIb8jPCsDbeZT8aoeBbLL3jioYaIRbIblehIflL1UtcXt8jEneiM(UPdIPNQorNecoyT5HyQb2qmGpjLtQlGy1kN9SKrsniUgiwTYzplzKKp9g2fQbX0tvNOtcbhS28qCKd2qmGpjLtQlGyULhWHylOS8obXrgqCnqmyH4qSyPS2DsiEIpXRHaX03nDqm9u1j6KqWbRnpeh5Gned4ts5K6ciwTYzplzKudIRbIvRC2Zsgj5tVHDHAqm9u1j6KqWbRnpedMc2qmGpjLtQlGyULhWHylOS8obXrgqCnqmyH4qSyPS2DsiEIpXRHaX03nDqm9u1j6KqWbRnpedMc2qmGpjLtQlGy1kN9SKrsniUgiwTYzplzKKp9g2fQbX0tvNOtcbhS28qmvQhSHyaFskNuxaXClpGdXwqz5DcIJmG4AGyWcXHyXszT7Kq8eFIxdbIPVB6Gy6PQt0jHGdwBEiMk1d2qmGpjLtQlGy1kN9SKrsniUgiwTYzplzKKp9g2fQbX0tvNOtcbhS28qCxGzGned4ts5K6ciwTYzplzKudIRbIvRC2Zsgj5tVHDHAqm9u1j6KqWbRnpe3fykydXa(KuoPUaIvRC2Zsgj1G4AGy1kN9SKrs(0ByxOgetFxDIojeCWAZdXDPoa2qmGpjLtQlGy1ii5rhIYLrsniUgiwncsE0HOCzKKp9g2fQbX0tvNOtcbhS28qm1PoydXa(KuoPUaIvRC2Zsgj1G4AGy1kN9SKrs(0ByxOgetFxDIojeCWAZdXuNAGned4ts5K6ciwTYzplzKudIRbIvRC2Zsgj5tVHDHAqm9D1j6KqWHGRoUZ2z2gyI2aZb2qme3E)H4LpEifeJoeiwn9mmXOkTQbXKdgil5ci2o8hIDKA496ciw37PYTsi4G1MhIPcSHyaFskNuxaXQvo7zjJKAqCnqSALZEwYijF6nSludIPNQorNecoyT5HyWmWgIb8jPCsDbeRw5SNLmsQbX1aXQvo7zjJK8P3WUqniMEQ6eDsi4G1MhIbZaBigWNKYj1fqSALZEwYiPgexdeRw5SNLmsYNEd7c1GyVG4odWKaliMEQ6eDsi4G1MhIPs9Gned4ts5K6ciwTYzplzKudIRbIvRC2Zsgj5tVHDHAqm9D1j6KqWbRnpetL6bBigWNKYj1fqSAeK8Odr5YiPgexdeRgbjp6quUmsYNEd7c1Gy67Qt0jHGdwBEiMkQaBigWNKYj1fqSALZEwYiPgexdeRw5SNLmsYNEd7c1GyVG4odWKaliMEQ6eDsi4G1MhIPI6Gned4ts5K6ciwTYzplzKudIRbIvRC2Zsgj5tVHDHAqm9awNOtcbhS28qmvuhSHyaFskNuxaXQPNuGSLmsQbX1aXQPNuGSLmsYNEd7c1Gy6PQt0jHGdwBEiMQihSHyaFskNuxaXQPNuGSLmsQbX1aXQPNuGSLmsYNEd7c1Gy6PQt0jHGdbhmbF8qQlGyWui211ojeZwBzLqWdCos1pKah3YJW8ANeWjoAf4Ijd6YEGRZHy159QhIbtoxL(cIbZN9ddee8ohIvNxF(MtGyQIaI7s9DPEi4qW7CiUZkISi2I)zzH4AGy1zQo7wDE0L9UvN3REleRoroexdepjdeeRhKSG4YjkVSqSQ(bIDYH43P4RRlG4AGy2s5qmBsfi(5GO0dX1aX8EvNaX07Zn2xiXqCNtfDsi4qWDDTtALXKRh(gVaaTUJNANecURRDsRmMC9W34faO1nI9MToFePZFAU6A7DIBnOtwMb1epQobcURRDsRmMC9W34faO1nXx7nI7ci4qW7CiUZOtxJuxaXNYjGG4A5pex9hIDDneiETqStXxM3WUecURRDsln(nfguYV6Ei4DoehzMtwVHDleCxx7KwaqRBkoz9g2JiD(tlEg2Mkg0HyuCIYaI9iO4mKttpdtmQsPfHNFsJItugqSljN330cqQfTC2ZsAr45N0O4eLbe7qWDDTtAbaTUP4K1BypI05pnBzIzEMBQebfNHCAUUwk38887T0Okk9Tq8vyoLNL0fcR8DATLfiqIVcZP8SKUqyLB2bvuJoi4Doe3z661zwi4UU2jTaGw3or75n1qipRiwuAeKC1M4r1jsXrx9wDe5ulk9XVKkorzaXU011s5ab2s5SNL0IWZpPrXjkdi2Lp9g2f0fLGKxko6Q3QdAudcURRDslaO1DdBgHbfHakIfLw8lPItugqSlDDTuoqGniOOsKSFyGmU16iSsIedey5SNL0j8GmdQP6Vr485frJFj94rBu6heM011s5rPp(L0j8Gmk9dct66APCGa1ZWeJQu6eEqMb1u93iUlKKZ7BA7qpdtmQszdBgHbfHaskqiETtgzqD6aceDv6ld58(MwasRbbfv2WMryqriGKceIx7KqWDDTtAbaTUBoXEsRBQeXIsl(LuXjkdi2LUUwkhiWgeuujs2pmqg3ADewjrIbcSC2Zs6eEqMb1u93iC(8IOXVKE8Onk9dct66AP8O0h)s6eEqgL(bHjDDTuoqG6zyIrvkDcpiZGAQ(Be3fsY59nTDONHjgvPS5e7jTUPIuGq8ANmYG60bei6Q0xgY59nTaKwdckQS5e7jTUPIuGq8ANecURRDslaO1nBv6lRjYIiu4FwrSO0AqqrLiz)WazSf5Ps1lrIHG35qCNn13weNbXaUZyqS2tiUiRIYjqmGbXXt9SwNbXniOO2iG476EiM52AtfiMkQbX2RNuyLqmy(AzR6Ebe37ebeRhXfqCT8hIDle7qCrwfLtG4AG4w)JH4TGyYDH3WUecURRDslaO1TN6BlIZmANXIyrPf)sQ4eLbe7sxxlLdeydckQej7hgiJBTocRKiXabwo7zjDcpiZGAQ(BeoFEr04xspE0gL(bHjDDTuEu6JFjDcpiJs)GWKUUwkhiq9mmXOkLoHhKzqnv)nI7cj58(M2o0ZWeJQu6P(2I4mJ2zmPaH41ozKb1Pdiq0vPVmKZ7BAbinQOgeCxx7KwaqRBNO98MyeM9rSO0CDTuU5553B7GwxabspbjVuC0vVvh0OwucsUAt8O6eP4ORERoOf5QNoi4UU2jTaGw3Ol5nSzerSO0IFjvCIYaIDPRRLYbcSbbfvIK9ddKXTwhHvsKyGalN9SKoHhKzqnv)ncNpViA8lPhpAJs)GWKUUwkpk9XVKoHhKrPFqysxxlLdeOEgMyuLsNWdYmOMQ)gXDHKCEFtBh6zyIrvkrxYByZiKceIx7KrguNoGarxL(YqoVVPfG0AqqrLOl5nSzesbcXRDsi4UU2jTaGw3nUIzqnfz1TAJyrP1GGIkrY(HbYylYtLQxIeh111s5MNNFVLgvqW7CigWrS1WdXfzZwFzHyeRRCi4UU2jTaGw3i2B2682iwuA1Y)o6s9ab2YbdKno(cjX5J3uX48XSTqe3OSkoLHvMNkBEGaB5GbYghFHKYA3jndQrC(1Ei4UU2jTaGw3i2B268rKo)P5QRT3jU1Gozzgut8O6KiwuA0FR9P(skRDN0mOM4tqVU2jLp9g2frBPC2ZsIK9ddKXTwhHvYNEd7c6acK(wU1(uFPEsXt7fg2IE0HOVK3JSdjAl3AFQVKYA3jndQj(e0RRDs5tVHDbDqWDDTtAbaTUrS3S15JiD(tZvxBVtCRbDYYmOM4r1jrSO00ZWeJQu6XJ2zGITxsoVVPfGubyrP)w7t9L6jfpTxyyl6rhI(sEpYoeGaV1(uFjL1UtAgut8jOxx7KYNEd7IOLZEwsKSFyGmU16iSs(0ByxqheCxx7KwaqRBe7nBD(isN)0C1127e3AqNSmdQjEuDselkn0vPVmKZ7BAbOEgMyuLspE0oduS9sY59nTaG6ageCxx7KwaqRBe7nBD(isN)0CBpfpV1qC1Dig9qCwelknXBqqrLexDhIrpeNzeVbbfvAlx3kaPccURRDslaO1nI9MToFePZFAUTNIN3AiU6oeJEiolIfLw8lPcIteRNMb14Q7jt1lDDTuE04xspE0gL(bHjDDTuoeCxx7KwaqRBe7nBD(isN)0CBpfpV1qC1Dig9qCwelkn9mmXOkLE8ODgOy7LK7cqrP)w7t9L6jfpTxyyl6rhI(sEpYoKOORsFziN330cq9mmXOkL6jfpTxyyl6rhI(sY59nTaOl1deyl3AFQVupP4P9cdBrp6q0xY7r2HqheCxx7KwaqRBe7nBD(isN)0CBpfpV1qC1Dig9qCwelkn0vPVmKZ7BAbOEgMyuLspE0oduS9sY59nTaOl1db311oPfa06gXEZwNpI05pnkRDN0mOgX5x7JyrPrVEgMyuLspE0oduS9sYDbOOI3GGIkrVToztfJQbjfsB56w7GgGf9w7t9Luw7oPzqnXNGEDTtkF6nSlOdiWgeuujs2pmqg3ADewjrIbcm(LuXjkdi2LUUwkhcURRDslaO1nI9MToFePZFAeNpEtfJZhZ2crCJYQ4ugwzEQS5JyrPPNHjgvP0JhTZafBVKCEFtla7ciWYzplPt4bzgut1FJW5ZlKp9g2fabs8vyoLNL0fcRCtasni4UU2jTaGw3i2B268rKo)P1aszYBA(noJ3txhXIstpdtmQsPfHNFsJItugqSljN3302rKREGaBPC2ZsAr45N0O4eLbe7YNEd7IO1Y)o6s9ab2YbdKno(cjX5J3uX48XSTqe3OSkoLHvMNkBEi4UU2jTaGw3i2B268rKo)PfzV10pQyNeXIsl(LuXjkdi2LUUwkhiWwkN9SKweE(jnkorzaXU8P3WUiAT8VJUupqGTCWazJJVqsC(4nvmoFmBleXnkRItzyL5PYMhcURRDslaO1nI9MToFePZFAko7ANXoXAAU3AelkT4xsfNOmGyx66APCGaBPC2ZsAr45N0O4eLbe7YNEd7IO1Y)o6s9ab2YbdKno(cjX5J3uX48XSTqe3OSkoLHvMNkBEi4UU2jTaGw3i2B268rKo)PPqMuXAIjlVZmex5rSO0ii5binQhL(A5FhDPEGaB5GbYghFHK48XBQyC(y2wiIBuwfNYWkZtLnpDqWDDTtAbaTUJNANmIfLMEgMyuLsNWdYmOMQ)gXDHKCxaciW4xsfNOmGyx66APCGaBqqrLiz)WazCR1ryLejgcENdXrM7Bw(MBQaXrMTee2ZcIvhXCfKdXRfIDioMSdzlqqWDDTtAbaTUhKQHCV1iwuAIPKuwcc7zzIzUcYLKJsUT3BypAlLZEwsKSFyGmnSvPVI2cXxH5uEwsxiSY3P1wwi4UU2jTaGw3ds1qU3AelknXusklbH9SmXmxb5sYrj327nShL(wkN9SKiz)WazAyRsFbey5SNLej7hgitdBv6RO6zyIrvkrY(HbY0WwL(ssoVVPLUOUUwk38887TDqRli4UU2jTaGw3ds1qU3AelkncsE0HOCPfj(eBr8nJsVykjkzSLb9uorsok52EVHDGaftjByZimXmxb5sYrj327nSthe8ohI7S6ANeIbR1wwi4UU2jTaGw3ANXmUU2jnS1wrKo)PPhkp9SSqWDDTtAbaTU1oJzCDTtAyRTIiD(ttpdtmQsleCxx7KwaqRBTZygxx7Kg2ARisN)0U1(uFleCxx7KwaqRBcsACDTtAyRTIiD(tZNBSVqIJyrP56APCZZZV32bTUIsVEgMyuLsX9Q34PWiU2bjjN330cqQuF0wkN9SKIJUSdeOEgMyuLsXrx2LKZ7BAbivQpA5SNLuC0LD6I2I4E1B8uyex7GK1QBDtfi4UU2jTaGw3eK046AN0WwBfr68NMp30GqSvelknxxlLBEE(92oO1vuX9Q34PWiU2bjRv36MkqWDDTtAbaTUjiPX11oPHT2kI05pnLNNSAJppIfLMRRLYnpp)EBh06kk9TiUx9gpfgX1oizT6w3ujk96zyIrvkf3REJNcJ4AhKKCEFtBhuP(OTuo7zjfhDzhiq9mmXOkLIJUSljN3302bvQpA5SNLuC0LD6OdcURRDslaO1T2zmJRRDsdBTvePZFAkppz1rSO0CDTuU5553BPrfeCi4Doe3zNodigqieBbb311oPv6ZnnieBr7XR48RoIfLgbjxTjEuDIuC0vVfaPNk1daX9Q30AUk9Lev1GKIlmLtuEzJmrD6IkUx9MwZvPVKOQgKuCHPCIYllaJ8OTqXjR3WUmEg2Mkg0HyuCIYaIDGaBqqrLwvoHFtfd)AljsmeCxx7KwPp30GqSfaO19JxX5xDelkncsUAt8O6eP4OREla2f1IkUx9MwZvPVKOQgKuCHPCIYlBhulAluCY6nSlJNHTPIbDigfNOmGyhcURRDsR0NBAqi2ca06(XR48RoIfLwlI7vVP1Cv6ljQQbjfxykNO8YgTfkoz9g2LXZW2uXGoeJItugqSdei6Q0xgY59nTaKAabs8vyoLNL0fcR8DATLnkXxH5uEwsxiSsY59nTaKAqWDDTtAL(CtdcXwaGw3QgKuySXpfNab311oPv6ZnnieBbaAD)4vC(vhXIsRfkoz9g2LXZW2uXGoeJItugqSdbhcENdXD2PZaI5EHedb311oPv6Zn2xiX08eKrKIiwuAI7vVP1Cv6ljQQbjfxykNO8Y2bnnin7MNNFVfiqIVcZP8SKUqyLVtRTSrj(kmNYZs6cHvsoVVPfG0OIki4UU2jTsFUX(cjga062tqgrkIyrPjUx9MwZvPVKOQgKuCHPCIYlBh0OgeCxx7KwPp3yFHedaAD)4vC(vhXIsRfkoz9g2LXZW2uXGoeJItugqSdb311oPv6Zn2xiXaGw3O3wNSPIXwKT1hHgKMDt5eLxwAufXIst8geuuj6T1jBQyuniPqAlx3kaPr9O6zyIrvk94r7mqX2ljN330cqQdb311oPv6Zn2xiXaGw3O3wNSPIXwKT1hHgKMDt5eLxwAufXIst8geuuj6T1jBQyuniPqAlx3kaPccURRDsR0NBSVqIbaTUrVToztfJTiBRpcnin7MYjkVS0OkIfLgbjVSw(BQXayaKE9mmXOkLI7vVXtHrCTdssoVVPnAlLZEwsXrx2bcupdtmQsP4Ol7sY59nTrlN9SKIJUStheCi4DoeRoAQDsle7PaINQ)eiEsigXEi4UU2jTs9mmXOkT0INANmIfLw8lPItugqSlDDTuoqGniOOsKSFyGmU16iSsIedey5SNL0j8GmdQP6Vr485frPp(L0j8Gmk9dct66APCGaJFj94rBu6heM011s5abQNHjgvP0j8GmdQP6VrCxijN3302b6Q0xgY59nT0bb311oPvQNHjgvPfa06gXEZwNpI05pTnTAcs5nSBadepleEJ4uw9JyrPPNHjgvPej7hgitdBv6lj58(M2O0h)s6eEqgL(bHjDDTuoqG6zyIrvk94r7mqX2ljN330cqQfLE9mmXOkLoHhKzqnv)nI7cj58(MwGaf3REtR5Q0xsXA9g2n(uc6OdiWYjkVK1YFtnMyDz6s9aKAqWDDTtAL6zyIrvAbaTUrS3S15JiD(tJ31Ed5gB)Fz4rSRoIfLMEgMyuLspE0oduS9sY59nTaKArPVLdgiBC8fYnTAcs5nSBadepleEJ4uw9bcupdtmQs5MwnbP8g2nGbINfcVrCkR(sY59nT0bb311oPvQNHjgvPfa06gXEZwNpI05pnb5UaDj3q5w7zrSO00ZWeJQu6XJ2zGITxsoVVPnkbjVSw(BQXayaurlIsFlhmq244lKBA1eKYBy3agiEwi8gXPS6deOEgMyuLYnTAcs5nSBadepleEJ4uw9LKZ7BAPdcURRDsRupdtmQslaO1nI9MToFePZFAcN0k)mPrCDRgkNm6TafXIsl(L0JhTrPFqysxxlLhL(woyGSXXxi30QjiL3WUbmq8Sq4nItz1hiq9mmXOkLBA1eKYBy3agiEwi8gXPS6ljN330sheCxx7KwPEgMyuLwaqRBe7nBDEBelkn9mmXOkLE8ODgOy7LKZ7BAJsFlhmq244lKBA1eKYBy3agiEwi8gXPS6deOEgMyuLYnTAcs5nSBadepleEJ4uw9LKZ7BAPdcENdXa(mmXOkTqWDDTtAL6zyIrvAbaTUDcpiZGAQ(Be3frSO0eVbbfvIEBDYMkgvdskKiXr1ZWeJQuIK9ddKPHTk9LKCEFtlaPw0Yzpljs2pmqMg2Q0xab2s5SNLej7hgitdBv6li4UU2jTs9mmXOkTaGw3iz)WazAyRsFfXIsJItwVHDPTmXmpZnvIsVEgMyuLsNWdYmOMQ)gXDHKCEFtBhudiqX9Q30AUk9LuSwVHDJpLGUO0RNHjgvP0JhTZafBVKCxakk9I3GGIkrVToztfJQbjfsB56w7GgGbeibjFh0OoDabQNHjgvP0JhTZafBVKCEFtlDqWDDTtAL6zyIrvAbaTUrY(HbY0WwL(kIfLMRRLYnpp)EBh06ccURRDsRupdtmQslaO1TWjTAkINw0HW71ozelknkoz9g2L2YeZ8m3ujQEgMyuLsKSFyGmnSvPVKKZ7BAJsFleK8Odr5sXDbBVTm6zzabsqYJoeLlf3fS92YONLfL(wAqqrLcN0QPiEArhcVx7KsK4OTuo7zjrY(HbYe76ciWYzpljs2pmqMyxx0rheCxx7KwPEgMyuLwaqRBHtA1uepTOdH3RDYiwuAuCY6nSlTLjM5zUPs0wkN9SKiz)WazAyRsFbb311oPvQNHjgvPfa06w4KwnfXtl6q49ANmIfLMRRLYnpp)EBh06ccURRDsRupdtmQslaO1ThpANbk2(iwuAUUwk38887T0OkQ4niOOs0BRt2uXOAqsH0wUU1oObyrPN(wkN9SKiz)WazAyRsFbey5SNL0j8GmdQP6Vr485fabQNuGSLupjLr71oPzqnv)nI7c6acSC2ZsIK9ddKPHTk9v0wkN9SKoHhKzqnv)ncNpViQykjs2pmqMg2Q0xsY59nT0bb311oPvQNHjgvPfa062JhTZafBFelknxxlLBEE(92oO1vuXBqqrLO3wNSPIr1GKcPTCDRDqdWI2I4E1B8uyex7GK1QBDtfi4UU2jTs9mmXOkTaGw3weE(jnkorzaXEelkncsUAt8O6eP4ORElasfGbb311oPvQNHjgvPfa06gj7hgiJBTocRIyrPrXjR3WU0wMyMN5MkrfVbbfvIEBDYMkgvdskK2Y1TcWUIsF8lPhpAJs)GWKUUwkhiq9KcKTK6jPmAV2jndQP6VrCxevpdtmQsPhpANbk2Ej58(Mw6GG76AN0k1ZWeJQ0caADJK9ddKXTwhHvrObPz3uor5LLgvrSO0CDTuU5553B7GwxrfVbbfvIEBDYMkgvdskK2Y1TcWUGG76AN0k1ZWeJQ0caADBheMHCp(Ki0G0SBkNO8YsJQiwuALtuEjRL)MAmX6YqDQbqQfTCIYlzT83uJrSVdQbb311oPvQNHjgvPfa06M4R9gXDrelkTwIFjv6heM011s5qWHG35qmGpuE6zbXD2MLT1EleCxx7KwPEO80ZYsZQYj8BQy4xBfXIsJItwVHDPTmXmpZnvIsqYvBIhvNifhD1B1rKdbVZHyUxqCnqmI9qSJwNaXE8OH41cXtcXaU6eIDlexdehtoLNfepuor7XXBQaXDMQJGyv9l7qS9vTPceJedXaU6unleCxx7KwPEO80ZYcaADBv5e(nvm8RTIyrPPNHjgvP0JhTZafBVKCEFtBu6DDTuU5553B7GwxrDDTuU5553BbinQfLGKR2epQorko6Q3Qd6DDTuU5553BJmf50beORRLYnpp)EBhulkbjxTjEuDIuC0vVvhux90bb311oPvQhkp9SSaGw3EZWVPx7Kg2Y3eXIsJItwVHDPTmXmpZnvIsqYlRL)MAmawh0tDa0GGIkji5Qn6HqqIRDsj58(Mw6GG76AN0k1dLNEwwaqRBVz430RDsdB5BIyrP56APCZZZV32bTUIsqYlRL)MAmawh0tDa0GGIkji5Qn6HqqIRDsj58(Mw6GG76AN0k1dLNEwwaqRBBVRBLDt1FdsQAivpOiwuAuCY6nSlTLjM5zUPsu9mmXOkLE8ODgOy7LKZ7BAHG76AN0k1dLNEwwaqRBBVRBLDt1FdsQAivpOiwuAUUwk38887TDqRRO0lUx9gpfgX1oizT6w3ubiqIVcZP8SKUqyLKZ7BAbinQam6GGdbVZHyUnvyhIB3jkVGG76AN0kvEEYQPjUx9g9SSiwuAniOOslIq80iMHxsURROTqXjR3WUmEg2Mkg0HyuCIYaIDGaJFjvCIYaIDPRRLYHG76AN0kvEEYQbaTUf3REJEwwelkncsUAt8O6eP4ORElasf1J2cfNSEd7Y4zyBQyqhIrXjkdi2HG76AN0kvEEYQbaTU9eKrKIiwuA6zyIrvk94r7mqX2ljN330gL(YzplP4Ol7YNEd7cGa1dLNEwYCv6ldQFGaji5rhIYLX93jd)K3sheCxx7KwPYZtwnaO1TQbjfgB8tXjrSO0eVbbfvIEBDYMkgvdskK2Y1T2bGbb311oPvQ88KvdaADRAqsHXg)uCselknXBqqrLO3wNSPIr1GKcjsCu9mmXOkLE8ODgOy7LKZ7BA7GArPVLYzpljs2pmqMg2Q0xabwo7zjDcpiZGAQ(BeoFEbqG6jfiBj1tsz0ETtAgut1FJ4UaiqIVcZP8SKUqyLVtRTS0bb311oPvQ88KvdaADRAqsHXg)uCselknXBqqrLO3wNSPIr1GKcjsC0Yzpljs2pmqMg2Q0xrBPC2Zs6eEqMb1u93iC(8IOTONuGSLupjLr71oPzqnv)nI7IOTq8vyoLNL0fcR8DATLnk96zyIrvkrY(HbY0WwL(ssoVVPTdQfvpdtmQsPhpANbk2Ej5Uau0wetjrY(HbY0WwL(ssoVVPfiWw0ZWeJQu6XJ2zGITxsUlarheCxx7KwPYZtwnaO1T4E1B0ZYIyrPrqYvBIhvNifhD1BbWUuF0wO4K1ByxgpdBtfd6qmkorzaXoeCxx7KwPYZtwnaO1n6T1jBQySfzB9rSO0eVbbfvIEBDYMkgvdskK2Y1TcqQGG76AN0kvEEYQbaTUrVToztfJTiBRpIfLM4niOOs0BRt2uXOAqsH0wUUvacyr1ZWeJQu6XJ2zGITxsoVVPfGupk9Tuo7zjrY(HbY0WwL(ciWYzplPt4bzgut1FJW5ZlacupPazlPEskJ2RDsZGAQ(Be3fabs8vyoLNL0fcR8DATLLoi4UU2jTsLNNSAaqRB0BRt2uXylY26JyrPjEdckQe926KnvmQgKuiTLRBfGaw0Yzpljs2pmqMg2Q0xrBPC2Zs6eEqMb1u93iC(8IOTONuGSLupjLr71oPzqnv)nI7IOTq8vyoLNL0fcR8DATLnQEgMyuLspE0oduS9sYDbOO0RNHjgvPej7hgitdBv6lj58(MwasDGaftjrY(HbY0WwL(ssoVVPLoi4UU2jTsLNNSAaqRBX9Q3ONLfXIsRfkoz9g2LXZW2uXGoeJItugqSdbhcENdXG5EEYQH4o70zaXQJi7q2ceeCxx7KwPYZtwTXNt7XR48RoIfLwdckQ0IiepnIz4LK76ccURRDsRu55jR24ZbaTUF8ko)QJyrP1cfNSEd7Y4zyBQyqhIrXjkdi2HG76AN0kvEEYQn(CaqRBvdskm24NItIqdsZUPCIYllnQIyrPrVEgMyuLspE0oduS9sY59nTDqTOI3GGIkrVToztfJQbjfsKyGafVbbfvIEBDYMkgvdskK2Y1T2bGrxu6rxL(YqoVVPfG6zyIrvkf3REJNcJ4AhKKCEFtlaOs9abIUk9LHCEFtBh6zyIrvk94r7mqX2ljN330sheCxx7KwPYZtwTXNdaADJEBDYMkgBr2wFeAqA2nLtuEzPrvelknXBqqrLO3wNSPIr1GKcPTCDRaKg1JQNHjgvP0JhTZafBVKCEFtlaPoqGI3GGIkrVToztfJQbjfsB56wbivqWDDTtALkppz1gFoaO1n6T1jBQySfzB9rObPz3uor5LLgvrSO00ZWeJQu6XJ2zGITxsoVVPTdQfv8geuuj6T1jBQyuniPqAlx3kaPkuHkea]] )

end
