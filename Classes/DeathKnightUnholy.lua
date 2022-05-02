-- DeathKnightUnholy.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local roundUp = ns.roundUp

local FindUnitBuffByID = ns.FindUnitBuffByID
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
                local app = state.buff.swarming_mist.applied
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
        dark_simulacrum = 41, -- 77606
        deaths_echo = 5428, -- 356367
        dome_of_ancient_shadow = 5367, -- 328718
        doomburst = 5436, -- 356512
        life_and_death = 40, -- 288855
        necromancers_bargain = 3746, -- 288848
        necrotic_aura = 3437, -- 199642
        necrotic_wounds = 149, -- 356520
        raise_abomination = 3747, -- 288853
        reanimation = 152, -- 210128
        spellwarden = 5423, -- 356332
        strangulate = 5430, -- 47476
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
            duration = 8,
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
                local name, _, count, _, duration, expires, caster, _, _, spellID, _, _, _, _, timeMod, v1, v2, v3 = FindUnitBuffByID( "pet", 63560 )

                if name then
                    t.name = t.name or name or class.abilities.dark_transformation.name
                    t.count = count > 0 and count or 1
                    t.expires = expires
                    t.duration = duration
                    t.applied = expires - duration
                    t.caster = "player"
                    return
                end

                t.name = t.name or class.abilities.dark_transformation.name
                t.count = 0
                t.expires = 0
                t.duration = class.auras.dark_transformation.duration
                t.applied = 0
                t.caster = "nobody"
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
            dot = "buff",
        },
        unholy_blight = {
            id = 115994,
            duration = 14,
            tick_time = function () return 2 * haste end,
            max_stack = 4,
            copy = { "unholy_blight_debuff", "unholy_blight_dot" }
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

        doomburst = {
            id = 356518,
            duration = 3,
            max_stack = 2,
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

    spec:RegisterHook( "step", function ( time )
        if Hekili.ActiveDebug then Hekili:Debug( "Rune Regeneration Time: 1=%.2f, 2=%.2f, 3=%.2f, 4=%.2f, 5=%.2f, 6=%.2f\n", runes.time_to_1, runes.time_to_2, runes.time_to_3, runes.time_to_4, runes.time_to_5, runes.time_to_6 ) end
    end )


    -- Tier 28
    spec:RegisterSetBonuses( "tier28_2pc", 364392, "tier28_4pc", 363560 )
    -- 2-Set - Every 5 Scourge Strikes casts Soul Reaper on your target. Soul Reaper grants your pet 20% Attack Speed for 10 seconds.
    -- 4-Set - Your minions deal 5% increased damage. When Soul Reaper's secondary effect triggers, this bonus is increased to 25% for 8 seconds.

    spec:RegisterAuras( {
        harvest_time_stack = {
            id = 363885,
            duration = 3600,
            max_stack = 5
        },
        harvest_time = {
            id = 363887,
            duration = 3600,
            max_stack = 1
        },
        harvest_time_pet = {
            id = 367954,
            duration = 8,
            max_stack = 1,
            generate = function( t )
                local name, _, count, _, duration, expires, caster = FindUnitBuffByID( "pet", 367954 )

                if name then
                    t.name = name
                    t.count = count
                    t.expires = expires
                    t.applied = expires - duration
                    t.caster = caster
                    return
                end

                t.count = 0
                t.expires = 0
                t.applied = 0
                t.caster = "nobody"
            end,
        }
    } )


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
        StoreMatchingAuras( "target", { count = 1, [191587] = "virulent_plague" }, "HARMFUL", select( 2, UnitAuraSlots( "target", "HARMFUL" ) ) )
        Hekili:ForceUpdate( "VIRULENT_PLAGUE_REFRESH" )
    end, state )

    local After = C_Timer.After

    spec:RegisterHook( "COMBAT_LOG_EVENT_UNFILTERED", function( _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID )
        if sourceGUID == GUID and subtype == "SPELL_CAST_SUCCESS" and spellID == 77575 then
            After( state.latency, ForceVirulentPlagueRefresh )
            After( state.latency * 2, ForceVirulentPlagueRefresh )
        end
    end )


    local any_dnd_set, wound_spender_set = false, false

    local ExpireRunicCorruption = setfenv( function()
        local debugstr

        if Hekili.ActiveDebug then debugstr = format( "Runic Corruption expired; updating regen from %.2f to %.2f at %.2f + %.2f.", rune.cooldown, rune.cooldown * 2, offset, delay ) end
        rune.cooldown = rune.cooldown * 2

        for i = 1, 6 do
            local exp = rune.expiry[ i ] - query_time

            if exp > 0 then
                rune.expiry[ i ] = rune.expiry[ i ] + exp
                if Hekili.ActiveDebug then debugstr = format( "%s\n - rune %d extended by %.2f [%.2f].", debugstr, i, exp, rune.expiry[ i ] - query_time ) end
            end
        end

        table.sort( rune.expiry )
        rune.actual = nil
        if Hekili.ActiveDebug then debugstr = format( "%s\n - %d, %.2f %.2f %.2f %.2f %.2f %.2f.", debugstr, rune.current, rune.expiry[1] - query_time, rune.expiry[2] - query_time, rune.expiry[3] - query_time, rune.expiry[4] - query_time, rune.expiry[5] - query_time, rune.expiry[6] - query_time ) end
        forecastResources( "runes" )
        if Hekili.ActiveDebug then debugstr = format( "%s\n - %d, %.2f %.2f %.2f %.2f %.2f %.2f.", debugstr, rune.current, rune.expiry[1] - query_time, rune.expiry[2] - query_time, rune.expiry[3] - query_time, rune.expiry[4] - query_time, rune.expiry[5] - query_time, rune.expiry[6] - query_time ) end
        if debugstr then Hekili:Debug( debugstr ) end
    end, state )

    spec:RegisterHook( "reset_precast", function ()
        if buff.runic_corruption.up then
            state:QueueAuraExpiration( "runic_corruption", ExpireRunicCorruption, buff.runic_corruption.expires )
        end

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

        -- Reset CDs on any Rune abilities that do not have an actual cooldown.
        for action in pairs( class.abilityList ) do
            local data = class.abilities[ action ]
            if data.cooldown == 0 and data.spendType == "runes" then
                setCooldown( action, 0 )
            end
        end
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
            if k == "disable_iqd_execute" then return state.settings.disable_iqd_execute and 1 or 0 end
            return 0
        end,
    } ) )


    local runeforges = {
        [6243] = "hysteria",
        [3370] = "razorice",
        [6241] = "sanguination",
        [6242] = "spellwarding",
        [6245] = "apocalypse",
        [3368] = "fallen_crusader",
        [3847] = "stoneskin_gargoyle",
        [6244] = "unending_thirst"
    }

    local function ResetRuneforges()
        table.wipe( state.death_knight.runeforge )
    end

    local function UpdateRuneforge( slot, item )
        if ( slot == 16 or slot == 17 ) then
            local link = GetInventoryItemLink( "player", slot )
            local enchant = link:match( "item:%d+:(%d+)" )

            if enchant then
                enchant = tonumber( enchant )
                local name = runeforges[ enchant ]

                if name then
                    state.death_knight.runeforge[ name ] = true

                    if name == "razorice" and slot == 16 then
                        state.death_knight.runeforge.razorice_mh = true
                    elseif name == "razorice" and slot == 17 then
                        state.death_knight.runeforge.razorice_oh = true
                    end
                end
            end
        end
    end

    Hekili:RegisterGearHook( ResetRuneforges, UpdateRuneforge )


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
            cooldown = 180,
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

                if pvptalent.necrotic_wounds.enabled and debuff.festering_wound.up and debuff.necrotic_wound.down then
                    applyDebuff( "target", "necrotic_wound" )
                end

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
            cooldown = function () return pvptalent.raise_abomination.enabled and 120 or 480 end,
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

                        if set_bonus.tier28_2pc > 0 then
                            if buff.harvest_time.up then
                                applyDebuff( "target", "soul_reaper" )
                                removeBuff( "harvest_time" )
                                summonPet( "army_ghoul", 15 )
                            else
                                addStack( "harvest_time_stack", nil, 1 )
                                if buff.harvest_time_stack.stack == 5 then
                                    removeBuff( "harvest_time_stack" )
                                    applyBuff( "harvest_time" )
                                end
                            end
                        end
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
                if pvptalent.doomburst.enabled and buff.sudden_doom.up and debuff.festering_wound.up then
                    if debuff.festering_wound.stack > 2 then
                        applyDebuff( "target", "festering_wound", debuff.festering_wound.remains, debuff.festering_wound.stack - 2 )
                        applyDebuff( "target", "doomburst", debuff.doomburst.up and debuff.doomburst.remains or nil, 2 )
                    else
                        removeDebuff( "target", "festering_wound" )
                        applyDebuff( "target", "doomburst", debuff.doomburst.up and debuff.doomburst.remains or nil, debuff.doomburst.stack + 1 )
                    end
                end

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
            charges = function ()
                if not pvptalent.deaths_echo.enabled then return end
                return 2
            end,
            cooldown = 25,
            recharge = function ()
                if not pvptalent.deaths_echo.enabled then return end
                return 25
            end,
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
            charges = function ()
                if not pvptalent.deaths_echo.enabled then return end
                return 2
            end,
            cooldown = 45,
            recharge = function ()
                if not pvptalent.deaths_echo.enabled then return end
                return 45
            end,
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
            charges = function ()
                if not pvptalent.deaths_echo.enabled then return end
                return 2
            end,
            cooldown = 20,
            recharge = function ()
                if not pvptalent.deaths_echo.enabled then return end
                return 20
            end,
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

                    if set_bonus.tier28_2pc > 0 then
                        if buff.harvest_time.up then
                            applyDebuff( "target", "soul_reaper" )
                            removeBuff( "harvest_time" )
                            summonPet( "army_ghoul", 15 )
                        else
                            addStack( "harvest_time_stack", nil, 1 )
                            if buff.harvest_time_stack.stack == 5 then
                                removeBuff( "harvest_time_stack" )
                                applyBuff( "harvest_time" )
                            end
                        end
                    end
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

            aura = "soul_reaper",

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
                applyDebuff( "target", "unholy_blight" )
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
        cycleDebuff = "festering_wound",

        enhancedRecheck = true,

        potion = "potion_of_spectral_strength",

        package = "Unholy",
    } )


    spec:RegisterSetting( "disable_iqd_execute", false, {
        name = "Disable |T2000857:0|t Inscrutable Quantum Device Execute",
        desc = "If checked, the default Unholy priority will not try to use Inscrutable Quantum Device solely because your enemy is in execute range.",
        type = "toggle",
        width = "full"
    } )


    spec:RegisterPack( "Unholy", 20220319, [[de1Qfdqivk9iecxcHuSjuPpHqnkevNcrzvivIxHu0See3sfbTlc)cPWWqvLJPIAzOQ8mbjtdHORPsX2urkFdPsACOQkDovKQwNGuVdvvHAEsPCpuL9jLQdIqQwisv9qvenrKk1fvrI2iQQI8rvKGrIQQaNufj1krk9suvfYmri5MOQkODQsv)ufHmuvKklvfj5PsXuvPYvvrcTvuvf1xriLglsv2lG)kvdwPdlAXe5XcnzsUm0MrYNfy0QKtRy1QiWRfuZMu3MO2TKFRQHRchhvv1Yb9CuMoLRd02rW3rfJhPIZlLSEveQ5Ji7NQbodChqJkne4E(4hF8XVqD(0l4JFNdf)o9anwRdeO5iJHZaeOPszeO5uSUEDlGMJSL(tfWDanShegrGMlZoyHMg0iySlqjr8LPbBKb1PnFfHjLrd2ihPbqJe4OTtDbib0OsdbUNp(XhF8luNp9c(435qXp(lqd7aJa3Z3n8b0CnkfwasankKfbAOBmTlF5pQMGlZ3tX661TCA5pmHXlFpF6dXx(4hF85060EYRScqwODApH(s0vNaqMjJLX81EFP7IUPbDJuJgPbDJPDX8LUbrFT33V0T8n(GL5RLWa0y(Y569nHOViDoWOHkFT3x9qa9v)vGVy9Gbx(AVVYPzi0xYZh7m0ap8LiotMWP9e6lDpSusJkFBYiCOM4KAFpDz08vcJjid9vHPY3GRhuZ8vodJ(s9qFzPYx6M)iMWP9e67PiBQaFjAFWs5BZbwke6Bkn6XgK5R8drFP0iDgjDlFjpnFjsA6lZYyyMVtXmmv((u(EdnjJ)yFP7txJVfcAWu7BwkFLZw(Earcyz(YEz036pHqm6lBmW0MVycN2tOVNISPc8L)eYmeovGVngCcJ(oLVe9t0P03HY3wpOVxjb036TRPc8f1m0x79v9(MLYxoFrS57taHX8WxopyPy(omFP7txJVfcAWulCApH(EYRScqLVYz1YxIPMGlRdr5CkgX(g)sn28vQz(AVV5XHULVt5R0Zy(snbxgZ3V0T8LCnYy(Es62xojZqF)YxdMSlYeoTNqFj6kfQ8nR3UqOVNiqtcIzyFXYGT81EFzO5l4HVmd(vac99uEmkuEImHt7j03tfQt64BZD(sGj8LOFIoL(Q)Gj6lBQi67y(cr9GmF)Y34xuPeOonu5lmhvhjGLXeoTNqFV7er3NOq7RV8NYO9qFBmiwb2LVhWpY8Dk791GtfgnF1FWefan6HzmG7aAYh7m0apaUd4(Za3b0GvkPrfa9bAIWXq4KankmTRE4AcUmbfNhSuOQBjmanMVTZZ3yROg7yHYdY8LejFvyAx9W1eCzckopyPqv3syaAmFBNNV34ljs(ERVwQXYesGqMnvqN9qKjWkL0OYxsK8fMJQJeWYePsXeiDgMX8LRVWCuDKawMivkMaIY5umFBJNVNp7ljs(k9mMVC9LAcUSoeLZPy(2gpFpFgOjJ28fqtwT6Qsbya3ZhWDanyLsAubqFGMiCmeojqZT(siHtkPrXX)6Pc6qWAI9JNdc9LRVK7ReifLqLWWDdMfJ6HYPnFjap8LRVqWcPEyakuyQ0dYSE8hTaRusJkF56BgTHa2XcLhK5BB88nu(sIKVz0gcyhluEqMV88LpFjdOjJ28fqJct7Qh)rdya3hkG7aAWkL0OcG(anr4yiCsGMB9LqcNusJIJ)1tf0HG1e7hphec0KrB(cObpgfkprad4EIe4oGgSsjnQaOpqtgT5lGgkKziCQGoZGtyeOjchdHtc0OqjqkkbfYmeovqNZdwkbZYyyFBJNVHYxU(g)xREoLip(yQBDWqbeLZPy(2MVHcOj2kQXULWa0ya3FgWaU)gG7aAWkL0OcG(anz0MVaAOqMHWPc6mdoHrGMiCmeojqJcLaPOeuiZq4ubDopyPemlJH9TnFpd0eBf1y3syaAmG7pdya3FAa3b0GvkPrfa9bAYOnFb0qHmdHtf0zgCcJanr4yiCsGgiyHcBKXU9DI0328LCFJ)RvpNsOW0U6zP6kmMTequoNI5lxFV1xl1yzcfsnAuGvkPrLVKi5B8FT65ucfsnAuar5CkMVC91snwMqHuJgfyLsAu5ljs(gFcyLLjQj4Y6uj6lxFJ)RvpNsOW0UyDfikGOCofZxYaAITIASBjmangW9NbmG7PRa3b0GvkPrfa9bAYOnFb0W5blvNDGLcHankKfHZHnFb0q0EHLVwcdqZxgN8G5BcrFvdlL0OkeFTRH5lNrR9vJMVTEqFzhyP8fcwiJgCEWsX8DkMHPY3NYxo5ytf4l1d9LUl6Mg0nsnAKg0nM2fXmFPBqua0eHJHWjbAi33B9LHMnvateBf1OVKi5Rct7QhUMGltqX5blfQ6wcdqJ5B788n2kQXowO8GmFjZxU(QqjqkkbfYmeovqNZdwkbZYyyFB33q5lxFHGfkSrg723dLVT5B8FT65uISA1vLsar5CkgGbyan5JDjqiZaUd4(Za3b0GvkPrfa9bAIWXq4Kanz0gcyhluEqMVTXZ3BaAYOnFb0e1jNPc6SRu9CyagW98bChqdwPKgva0hOjchdHtc0KrBiGDSq5bz(YZ3tZxU(QW0U6HRj4YeuCEWsHQULWa0y(2opFdfqtgT5lGMOo5mvqNDLQNddWaUpua3b0GvkPrfa9bAIWXq4KanwQXYesGqMnvqN9qKjWkL0OYxU(sUVkmTRE4AcUmbfNhSuOQBjmanMV88nJ2qa7yHYdY8LejFvyAx9W1eCzckopyPqv3syaAmFBNNVHYxY8LejFTuJLjKaHmBQGo7HitGvkPrLVC91snwMiQtotf0zxP65WeyLsAu5lxFvyAx9W1eCzckopyPqv3syaAmFBNNVNbAYOnFb0W5blvNDGLcHagW9ejWDanyLsAubqFGMiCmeojqd5(kbsrjyGkfwD1)YciMrZxsK89wFjKWjL0O44F9ubDiynX(XZbH(sMVC9LCFLaPOeQegUBWSyupuoT5lb4HVC9fcwi1ddqHctLEqM1J)OfyLsAu5lxFZOneWowO8GmFBJNVHYxsK8nJ2qa7yHYdY8LNV85lzanz0MVaAuyAx94pAad4(BaUdObRusJka6d0eHJHWjbAGG1e7hphekui1ehZ328LCFpZpFPPVkmTRE4AcUmbfNhSuOQBjmanMV0fFdLVK5lxFvyAx9W1eCzckopyPqv3syaAmFBZ3tZxU(ERVes4KsAuC8VEQGoeSMy)45GqFjrYxjqkkbJtcLNkOlpmtaEa0KrB(cObpgfkprad4(td4oGgSsjnQaOpqteogcNeObcwtSF8CqOqHutCmFBZx(UXxU(QW0U6HRj4YeuCEWsHQULWa0y(2UV34lxFV1xcjCsjnko(xpvqhcwtSF8CqiqtgT5lGg8yuO8ebmG7PRa3b0GvkPrfa9bAIWXq4Kan36Rct7QhUMGltqX5blfQ6wcdqJ5lxFV1xcjCsjnko(xpvqhcwtSF8CqOVKi5l1eCzDikNtX8TnFVXxsK8fMJQJeWYePsXeiDgMX8LRVWCuDKawMivkMaIY5umFBZ3BaAYOnFb0GhJcLNiGbCp)f4oGMmAZxanCEWs1zhyPqiqdwPKgva0hWaU)0dChqdwPKgva0hOjchdHtc0CRVes4KsAuC8VEQGoeSMy)45GqGMmAZxan4XOq5jcyagqdmJtQza3bC)zG7aAWkL0OcG(anz0MVaAsymlSBpeILb0Oqweoh28fqZPkJtQzanr4yiCsGgiynX(XZbHcfsnXX8TDFpTB8LRVK77bAIGeg8T0OiJ2qa9LejFV1xl1yzcgOS8x9Geg8T0OaRusJkFjZxU(cbluOqQjoMVTZZ3BamG75d4oGgSsjnQaOpqteogcNeOHqcNusJc58e8WE8FT65uSEgTHa6ljs(EGMiiHbFlnkYOneqF567bAIGeg8T0OaIY5umFBJNVsGuucj9)QofiSLqbctB(YxsK8v6zmF56l1eCzDikNtX8TnE(kbsrjK0)R6uGWwcfimT5lGMmAZxans6)vDkqylad4(qbChqdwPKgva0hOjchdHtc0qiHtkPrHCEcEyp(Vw9CkwpJ2qa9LejFpqteKWGVLgfz0gcOVC99anrqcd(wAuar5CkMVTXZxjqkkHeczim8ubcfimT5lFjrYxPNX8LRVutWL1HOCofZ3245ReifLqcHmegEQaHceM28fqtgT5lGgjeYqy4PcamG7jsG7aAWkL0OcG(anr4yiCsGgjqkkbyD96wDMbXkWUeGhanz0MVaA0tWLX6NaqvGmwgGbC)na3b0GvkPrfa9bAYOnFb0Kvezgm19yQ1ankKfHZHnFb0q0RiYmyQ99KPw7BmlFn4eeGqFjsFpEdlBsTVsGuuSq8fZ4LV6Kztf475B8LHXVumHVNI2ONtmQ89kHkFJVcv(AJm6BY8n91Gtqac91EFdJ4HVJ5letvkPrbqteogcNeOHqcNusJc58e8WE8FT65uSEgTHa6ljs(EGMiiHbFlnkYOneqF567bAIGeg8T0OaIY5umFBJNVNVXxsK8v6zmF56l1eCzDikNtX8TnE(E(gad4(td4oGgSsjnQaOpqteogcNeOjJ2qa7yHYdY8TDE(YNVKi5l5(cbluOqQjoMVTZZ3B8LRVqWAI9JNdcfkKAIJ5B788904NVKb0KrB(cOjHXSW(bOMHagW90vG7aAWkL0OcG(anr4yiCsGgcjCsjnkKZtWd7X)1QNtX6z0gcOVKi57bAIGeg8T0OiJ2qa9LRVhOjcsyW3sJcikNtX8TnE(kbsrjOgikP)xjuGW0MV8LejFLEgZxU(snbxwhIY5umFBJNVsGuucQbIs6)vcfimT5lGMmAZxanudeL0)RamG75Va3b0GvkPrfa9bAIWXq4Kanz0gcyhluEqMV889SVC9LCFLaPOeG11RB1zgeRa7saE4ljs(k9mMVC9LAcUSoeLZPy(2MV34lzanz0MVaAKYG(t1n4edZamadOjaleorG7aU)mWDanyLsAubqFGMiCmeojqZT(siHtkPrXX)6Pc6qWAI9JNdc9LRVK7ReifLGbQuy1v)llGygnFjrYxiynX(XZbHcfsnXX8TnE(Eou(stFj3xiyHupmafWu(ilRBWSyuieRikWkL0OYx6IVHYxA6Rct7QhUMGltablK6HbO4QfZq4K(sx8nu(sMVK5ljs(EGMiiHbFlnkYOneqF56leSqFBJNVHYxsK8LAcUSoeLZPy(2MVN5NVC99wFvOeifLGczgcNkOZ5blLa8aOjJ28fqJct7Qh)rdya3ZhWDanyLsAubqFGMiCmeojqd5(APgltOqQrJcSsjnQ8LejFJpbSYYe1eCzDQe9LejFHGfs9WauCCHj8L)czcSsjnQ8LmF56l5(sUV36lHeoPKgfh)RNkOdblK5ljs(gFcyLLjQj4Y6uj6lxFTuJLjui1OrbwPKgv(Y134xkWXeCg7cHtf0dGpyPeyLsAu5lz(sIKVspJ5lxFPMGlRdr5CkMVT57n(sgqtgT5lGMSA1vLcWaUpua3b0GvkPrfa9bAIWXq4Kanes4KsAuOaLp6CEWsX8LRVkucKIsqHmdHtf058GLsWSmg232557zF56B8FT65uI84JPU1bdfquoNI1r6CGrdv(2UVNVX3tOVK7leSqQhgGcfMk9GmRh)rlWkL0OYx6IVN5NVK5lxFV1xcjCsjnko(xpvqhcwidOjJ28fqdNhSuD2bwkecya3tKa3b0GvkPrfa9bAIWXq4KankucKIsqHmdHtf058GLsWSmg2329nu(Y13B9LqcNusJIJ)1tf0HGfY8LejFvOeifLGczgcNkOZ5blLa8WxU(snbxwhIY5umFBZxY9vHsGuuckKziCQGoNhSucMLXW(sx8niQ8LmGMmAZxanCEWs1zhyPqiGbC)na3b0GvkPrfa9bAIWXq4KanqWAI9JNdcfkKAIJ5BB88Lp(5ln9LCFHGfs9Wauat5JSSUbZIrHqSIOaRusJkFPl(sK(stFvyAx9W1eCzciyHupmafxTygcN0x6IVePVK5lxFV1xcjCsjnko(xpvqhcwtSF8CqiqtgT5lGgfM2vp(JgWaU)0aUdObRusJka6d0eHJHWjbAuOeifLGczgcNkOZ5blLGzzmSVT5lr6lxFV1xcjCsjnko(xpvqhcwidOjJ28fqdfYmeovqNzWjmcya3txbUdObRusJka6d0eHJHWjbAU1xcjCsjnko(xpvqhcwtSF8CqiqtgT5lGgfM2vp(JgWaUN)cChqdwPKgva0hOjchdHtc0OqjqkkbfYmeovqNZdwkbZYyyFBNNVN9LRVqWc9TnF5ZxU(ERVes4KsAuC8VEQGoeSqMVC9n(Vw9CkrE8Xu36GHcikNtX6iDoWOHkFB33BaAYOnFb0W5blvNDGLcHagGb0eFcyLLXaUd4(Za3b0GvkPrfa9bAIWXq4Kanes4KsAuWS(HoRAQaF56leSMy)45GqHcPM4y(2UVNpnF56l5(g)xREoLip(yQBDWqbeLZPy(sIKV36RLASmrcLB1FQUDHDvkxOsGvkPrLVC9n(Vw9CkHkHH7gmlg1dLtB(sar5CkMVK5ljs(k9mMVC9LAcUSoeLZPy(2MVNpd0KrB(cOHXjHYtf0LhMbya3ZhWDanyLsAubqFGMmAZxanmojuEQGU8WmGgfYIW5WMVaAAqZx79fKH(Mugc9np(OVdZ3V89K0TVjZx799aIeWY89jGWyECmvGVNQtNVCUgn6ldnBQaFbp89K0nXmGMiCmeojqt8FT65uI84JPU1bdfquoNI5lxFj33mAdbSJfkpiZ3255lF(Y13mAdbSJfkpiZ32457n(Y1xiynX(XZbHcfsnXX8TDFpZpFPPVK7BgTHa2XcLhK5lDX3tZxY8LRVes4KsAuKkfRdr5CkFjrY3mAdbSJfkpiZ3299gF56leSMy)45GqHcPM4y(2UVej)8Lmad4(qbChqdwPKgva0hOjchdHtc0qiHtkPrbZ6h6SQPc8LRV36l7b1stPeAmvDPwDKoP8HgfyLsAu5lxFj334)A1ZPe5XhtDRdgkGOCofZxsK89wFTuJLjsOCR(t1TlSRs5cvcSsjnQ8LRVX)1QNtjujmC3GzXOEOCAZxcikNtX8LmF56leSqHnYy3(or6B7(kbsrjGG1e7XhcbpS5lbeLZPy(sIKVspJ5lxFPMGlRdr5CkMVT5lFNbAYOnFb0KsV8uPnF11JSeGbCprcChqdwPKgva0hOjchdHtc0qiHtkPrbZ6h6SQPc8LRVShulnLsOXu1LA1r6KYhAuGvkPrLVC9LCFvVjaRRx3QlPNGlRREtar5CkMVT775Z(sIKV36RLASmbyD96wDj9eCzcSsjnQ8LRVX)1QNtjujmC3GzXOEOCAZxcikNtX8LmGMmAZxanP0lpvAZxD9ilbya3FdWDanyLsAubqFGMiCmeojqdHeoPKgfmRFOZQMkWxU(YEqT0ukryKWuS()NyupvGaRusJkF56l5(QqjqkkbfYmeovqNZdwkbZYyyFBNNVePVC99wFHGfs9WauKsV8uPnFX6uqSoXTeyLsAu5ljs(cblK6HbOiLE5PsB(I1PGyDIBjWkL0OYxU(g)xREoLip(yQBDWqbeLZPy(sgqtgT5lGMu6LNkT5RUEKLamG7pnG7aAWkL0OcG(anr4yiCsGgcjCsjnksLI1HOCoLVC9fcwOWgzSBFNi9TDFLaPOeqWAI94dHGh28LaIY5umGMmAZxanP0lpvAZxD9ilbya3txbUdObRusJka6d0eHJHWjbAiKWjL0OGz9dDw1ub(Y1xY9n(Vw9CkrE8Xu36GHcikNtX8TDFpZpFjrY3B91snwMiHYT6pv3UWUkLlujWkL0OYxU(g)xREoLqLWWDdMfJ6HYPnFjGOCofZxY8LejFLEgZxU(snbxwhIY5umFBZ3Z3a0KrB(cOHDLXWASBxyhS48q7QfGbCp)f4oGgSsjnQaOpqteogcNeOHqcNusJIuPyDikNt5lxFj3xfM2vplvxHXSLWMy4Pc8LejFH5O6ibSmrQumbeLZPy(2gpFptK(sgqtgT5lGg2vgdRXUDHDWIZdTRwagW9NEG7aAWkL0OcG(anr4yiCsGg2dQLMsjoazgOg7ie8WMVeyLsAu5ljs(YEqT0ukbHxN2OXo71eWYeyLsAu5lxFV1xjqkkbHxN2OXo71eWY6xGYz9JsaEa0mLHqi4H1hkGg2dQLMsji860gn2zVMawgqZugcHGhwFKLr1Kgc0CgOjJ28fqdLgzxryszantziecEy9a9lLAGMZagGb0CaX4llLgWDa3Fg4oGMmAZxanhVnFb0GvkPrfa9bmG75d4oGMmAZxanWCyyxHPcObRusJka6dya3hkG7aAYOnFb0qPr2veMugqdwPKgva0hWaUNibUdObRusJka6d0KrB(cOjHYT6pv3UWUctfqteogcNeO5wFTuJLjyGYYF1dsyW3sJcSsjnQaAoGy8LLsRBJmc0ekad4(BaUdObRusJka6d08hanm0gkGMiCmeojqJbNkmAc7S4kzDqg2LaPO8LRVK7RbNkmAc7Si(Vw9CkHceM28LVen(sK34lpF5NVKb0Oqweoh28fqZPKqQbtdz(M(AWPcJgZ34)A1ZPcXx1qyuOYxPw(sK3i89URH5lNK5B86zy5BY8fSUEDlF58WWmF)YxI8gFzy8lLVsGqM5BSvuJSq8vc089kz(A)7RCwT8nQG(Iuuy0y(AVVbdb03034)A1ZPe0rOaHPnF5RAimSh67umdtLW3tnLVJrmZxcPge99kz(wVVquoNsHqFHObclFphIVOMH(crdew(YpXncGgcjSxPmc0yWPcJw)CN1QIanz0MVaAiKWjL0iqdHudIDuZqGg(jUbOHqQbrGMZagW9NgWDanyLsAubqFGM)aOHH2qb0KrB(cOHqcNusJanesyVszeOXGtfgToFDwRkc0eHJHWjbAm4uHrty8jUswhKHDjqkkF56l5(AWPcJMW4te)xREoLqbctB(YxIgFjYB8LNV8ZxYaAiKAqSJAgc0WpXnanesnic0CgWaUNUcChqdwPKgva0hO5paAyOnuanr4yiCsGMB91GtfgnHDwCLSoid7sGuu(Y1xdovy0egFIRK1bzyxcKIYxsK81GtfgnHXN4kzDqg2LaPO8LRVK7l5(AWPcJMW4te)xREoLqbctB(YxA4RbNkmAcJpHeifvxbctB(YxY8LU4l5(EwCJV00xdovy0egFIRK1LaPO8LmFPl(sUVes4KsAuyWPcJwNVoRvf9LmFjZ329LCFj3xdovy0e2zr8FT65ucfimT5lFPHVgCQWOjSZcjqkQUceM28LVK5lDXxY99S4gFPPVgCQWOjSZIRK1LaPO8LmFPl(sUVes4KsAuyWPcJw)CN1QI(sMVKb0Oqweoh28fqZPKzJCAiZ30xdovy0y(si1GOVsT8n(YhjCQaFTl034)A1ZP89P81UqFn4uHrleFvdHrHkFLA5RDH(QaHPnF57t5RDH(kbsr57y(EaFcJczcF5piz(M(Ymiwb2LVYVAOge6R9(gmeqFtFVMGle67bCE4yT81EFzgeRa7Yxdovy0yH4BY8LdQ1(MmFtFLF1qni0xQh67q5B6RbNkmA(Yz0AFFOVCgT236nFzTQOVCg7Y34)A1ZPycGgcjSxPmc0yWPcJw)aopCSwanz0MVaAiKWjL0iqdHudIDuZqGMZanesnic0WhGbCp)f4oGgSsjnQaOpqZFa0WqdOjJ28fqdHeoPKgbAiKAqeOXsnwMiHYT6pv3UWUkLlujWkL0OYxU(g)sboMi(fHpM28v)P62f2vyQeyLsAub0Oqweoh28fqZPKqQbtdz(gbHqSmFzObE4l1d91UqF5FWSSXA57t5lr)4JPU1bd99K09PYxKIcJgdOHqc7vkJanuGADpQGagW9NEG7aAWkL0OcG(an)bqddnGMmAZxanes4KsAeOHqQbrGgiyHupmafkmTlwpIqlNYAjWkL0OYxU(cblK6HbOaMYhzzDdMfJcHyfrbwPKgvanesyVszeOrf7qdWamGM4)A1ZPya3bC)zG7aAWkL0OcG(anr4yiCsGgcjCsjnkKZtWd7X)1QNtX6z0gcOVKi57bAIGeg8T0OiJ2qa9LRVhOjcsyW3sJcikNtX8TnE(Y3P5ljs(k9mMVC9LAcUSoeLZPy(2MV8DAanz0MVaAoEB(cWaUNpG7aAWkL0OcG(anr4yiCsGM4)A1ZPeQegUBWSyupuoT5lbeLZPyDKohy0qLVT5lD1xU(sUVX)1QNtjaRRx3QlPNGltar5CkMVT5lD1xU(APgltawxVUvxspbxMaRusJkFjrY3B91snwMaSUEDRUKEcUmbwPKgv(sMVC9LCFzO1L(cKjSbH8XF7e5r0xU(AjmanHnYy3((r06H6gFBZxI0xsK89wFzO1L(cKjSbH8XF7e5r0xsK8LAcUSoeLZPy(2UV8Xp(5lz(Y1xY9n(Vw9Ckrk9YtL28vxpYscikNtX8TnFpZF9LRVK7leSqQhgGIu6LNkT5lwNcI1jULaRusJkFjrYx2dQLMsjcJeMI1))eJ6PceyLsAu5lz(sIKV36leSqQhgGIu6LNkT5lwNcI1jULaRusJkF567T(YEqT0ukryKWuS()NyupvGaRusJkFjZxU(sUVX)1QNtjYJpM6whmuar5CkwhPZbgnu5BB(sx9LRVes4KsAuqbQ19Oc6ljs(ERVes4KsAuqbQ19Oc6ljs(siHtkPrHk2HMVK5ljs(k9mMVC9LAcUSoeLZPy(2MVH6gGMmAZxanjuUv)P62f2vyQamG7dfWDanyLsAubqFGMmAZxanShu3HyEGqGMiCmeojqJLWa0e2iJD77hrRhQB8TnFVXxU(sUVwcdqtyJm2TVRg03299gF56BgTHa2XcLhK5BB88nu(sIKVm06sFbYe2Gq(4VDI8i6lxFLaPOeQegUBWSyupuoT5lb4HVC9nJ2qa7yHYdY8TnE(EJVC9LCFV1xfM2vplvxHXSLWMy4Pc8LejFJpbSYYe1eCzDQe9LmFjdOj2kQXULWa0ya3FgWaUNibUdObRusJka6d0KrB(cObSUEDRUKEcUmGgfYIW5WMVaA4p41kMV0xpbxMVup0xWdFT33B8LHXVumFT3xwRk6lNXU8LOF8Xu36GHH47jYUqiNHHH4lid9LZyx(s3jmSV3bZIr9q50MVeanr4yiCsGgcjCsjnkyw)qNvnvGVC9LCFJ)RvpNsKhFm1ToyOaIY5uSosNdmAOY3289gFjrY34)A1ZPe5XhtDRdgkGOCofRJ05aJgQ8TDFpZpFjZxU(sUVX)1QNtjujmC3GzXOEOCAZxcikNtX8TnFdIkFjrYxjqkkHkHH7gmlg1dLtB(saE4lzagW93aChqdwPKgva0hOjchdHtc0qiHtkPrrQuSoeLZP8LejFLEgZxU(snbxwhIY5umFBZx(od0KrB(cObSUEDRUKEcUmad4(td4oGgSsjnQaOpqteogcNeOHqcNusJcM1p0zvtf4lxFj3x1BcW661T6s6j4Y6Q3equoNI5ljs(ERVwQXYeG11RB1L0tWLjWkL0OYxYaAYOnFb0Osy4UbZIr9q50MVamG7PRa3b0GvkPrfa9bAIWXq4Kanes4KsAuKkfRdr5CkFjrYxPNX8LRVutWL1HOCofZ328LVZanz0MVaAujmC3GzXOEOCAZxagW98xG7aAWkL0OcG(anr4yiCsGMmAdbSJfkpiZxE(E2xU(QqjqkkbfYmeovqNZdwkbZYyyFBNNVePVC9LCFV1xcjCsjnkOa16Eub9LejFjKWjL0OGcuR7rf0xU(sUVX)1QNtjaRRx3QlPNGltar5CkMVT77z(5ljs(g)xREoLqLWWDdMfJ6HYPnFjGOCofRJ05aJgQ8TDFpZpF567T(APgltawxVUvxspbxMaRusJkFjZxYaAYOnFb0KhFm1ToyiGbC)Ph4oGgSsjnQaOpqtgT5lGM84JPU1bdbAIWXq4Kanz0gcyhluEqMVTZZx(8LRVkucKIsqHmdHtf058GLsWSmg23255lr6lxFV1xfM2vplvxHXSLWMy4PcaAITIASBjmangW9NbmG7pZpG7aAWkL0OcG(anr4yiCsGgiynX(XZbHcfsnXX8TnFptK(Y134)A1ZPeG11RB1L0tWLjGOCofZ3289CO8LRVX)1QNtjujmC3GzXOEOCAZxcikNtX6iDoWOHkFBZ3ZHcOjJ28fqdduw(REqcd(wAeWaU)8zG7aAWkL0OcG(anr4yiCsGgcjCsjnkyw)qNvnvGVC9vHsGuuckKziCQGoNhSucMLXW(2MV85lxFj33d0e5Xh7bxpOwKrBiG(sIKVsGuucvcd3nywmQhkN28La8WxU(g)xREoLip(yQBDWqbeLZPy(2UVN5NVKi5B8FT65uI84JPU1bdfquoNI5B7(EMF(Y134)A1ZPeQegUBWSyupuoT5lbeLZPy(2UVN5NVKb0KrB(cObSUEDREYyjO2amG7pZhWDanyLsAubqFGMmAZxanG11RB1tglb1gqteogcNeOjJ2qa7yHYdY8TDE(YNVC9vHsGuuckKziCQGoNhSucMLXW(2MV85lxFj33d0e5Xh7bxpOwKrBiG(sIKVsGuucvcd3nywmQhkN28La8WxsK8n(Vw9CkHct7QNLQRWy2sar5CkMVT5Bqu5lzanXwrn2TegGgd4(ZagW9NdfWDanyLsAubqFGMiCmeojqZT(EGMi46b1ImAdbeOjJ28fqdmhg2vyQamadOjaleoXE(iWDa3Fg4oGgSsjnQaOpqddJanX)1QNtjypOUdX8aHcikNtXaAYOnFb0WjhdOjchdHtc0yPgltWEqDhI5bcfyLsAu5lxFTegGMWgzSBF)iA9qDJVT57n(Y1xQj4Y6quoNI5B7(EJVC9n(Vw9Ckb7b1DiMhiuar5CkMVT5l5(gev(sx8LFc66n(sMVC9nJ2qa7yHYdY8TnE(gkad4E(aUdObRusJka6d0eHJHWjbAi33B9LqcNusJIJ)1tf0HG1e7hphe6ljs(kbsrjyGkfwD1)YciMrZxY8LRVK7ReifLqLWWDdMfJ6HYPnFjap8LRVqWcPEyakuyQ0dYSE8hTaRusJkF56BgTHa2XcLhK5BB88nu(sIKVz0gcyhluEqMV88LpFjdOjJ28fqJct7Qh)rdya3hkG7aAWkL0OcG(anr4yiCsGgjqkkbduPWQR(xwaXmA(sIKV36lHeoPKgfh)RNkOdbRj2pEoieOjJ28fqdEmkuEIagW9ejWDanyLsAubqFGgfYIW5WMVaAo1u(AjmanFJTI6Pc8Dy(QgwkPrvi(Y4mw8YxPmg2x791UqFztfOXtOLWa08naleorF1dZ8DkMHPsa0KrB(cObcw9mAZxD9WmGgMbNObC)zGMiCmeojqtSvuJDSq5bz(YZ3Zan6Hz9kLrGMaSq4ebmG7Vb4oGgSsjnQaOpqtgT5lGgopyP6SdSuieOjchdHtc0qUVX)1QNtjYJpM6whmuar5CkMVT77n(Y1xfkbsrjOqMHWPc6CEWsjap8LejFvOeifLGczgcNkOZ5blLGzzmSVT7BO8LmF56l5(snbxwhIY5umFBZ34)A1ZPekmTREwQUcJzlbeLZPy(stFpZpFjrYxQj4Y6quoNI5B7(g)xREoLip(yQBDWqbeLZPy(sgqtSvuJDlHbOXaU)mGbC)PbChqdwPKgva0hOjJ28fqdfYmeovqNzWjmc0eHJHWjbAuOeifLGczgcNkOZ5blLGzzmSVTXZ3q5lxFJ)RvpNsKhFm1ToyOaIY5umFBZ3B8LejFvOeifLGczgcNkOZ5blLGzzmSVT57zGMyROg7wcdqJbC)zad4E6kWDanyLsAubqFGMmAZxanuiZq4ubDMbNWiqteogcNeOj(Vw9CkrE8Xu36GHcikNtX8TDFVXxU(QqjqkkbfYmeovqNZdwkbZYyyFBZ3ZanXwrn2TegGgd4(ZagW98xG7aAWkL0OcG(anz0MVaAOqMHWPc6mdoHrGgfYIW5WMVaAU7Ay(omFrkkmAdbu3YxQrRrOVCUM4LVSrM5lDF6A8TqqdM6q8vc08LD9GALVhqKawMVPVSiwjCEF5CHq0x7c9nvQV89kz(wVDnvGV27leJVSmwkbqteogcNeOjJ2qa7Q3euiZq4ubDopyP8TDE(gBf1yhluEqMVC9vHsGuuckKziCQGoNhSucMLXW(2MVejGbyankKkb1gWDa3Fg4oGMmAZxanYtP6uqepXiqdwPKgva0hWaUNpG7aAWkL0OcG(an)bqddnGMmAZxanes4KsAeOHqQbrGgY9f5FW54avIPyriOLsASZ)GzzGYDfsyIOVKi5lY)GZXbQe2f2PgiZ6Sjy0(sIKVi)dohhOs8eqiNlulpvq)45GWEe2IzP2xY8LRVK7B8FT65uIPyriOLsASZ)GzzGYDfsyIOaIPQLVKi5B8FT65uc7c7udKzD2emAbeLZPy(sIKVX)1QNtjEciKZfQLNkOF8CqypcBXSulGOCofZxY8LejFj3xK)bNJdujSlStnqM1ztWO9LejFr(hCooqL4jGqoxOwEQG(XZbH9iSfZsTVK5lxFr(hCooqLykwecAPKg78pywgOCxHeMic0Oqweoh28fqZPdIeWY8LDGXHAqLVgCQWOX8vcNkWxqgQ8LZyx(MG2lN2e9vpfYaAiKWELYiqd7aJd1GQUbNkmAagW9Hc4oGgSsjnQaOpqZFa0WqdOjJ28fqdHeoPKgbAiKAqeOj(Vw9Ckbduw(REqcd(wAuar5CkMVT57n(Y1xl1yzcgOS8x9Geg8T0OaRusJkF56l5(APgltawxVUvxspbxMaRusJkF56B8FT65ucW661T6s6j4YequoNI5BB(Eou(Y134)A1ZPeQegUBWSyupuoT5lbeLZPyDKohy0qLVT575q5ljs(ERVwQXYeG11RB1L0tWLjWkL0OYxYaAiKWELYiqZX)6Pc6qWAI9JNdcbmG7jsG7aAWkL0OcG(an)bqddnGMmAZxanes4KsAeOHqQbrGgl1yzc2dQ7qmpqOaRusJkF56leSqFBZx(8LRVwcdqtyJm2TVFeTEOUX3289gF56l1eCzDikNtX8TDFVXxsK8n(eWkltutWL1Ps0xU(APgltOqQrJcSsjnQ8LRVX)1QNtjui1OrbeLZPy(2MVqWcf2iJD778b0qiH9kLrGMJ)1tf0HGfYamG7Vb4oGgSsjnQaOpqZFa0WqdOjJ28fqdHeoPKgbAiKAqeOjJ2qa7yHYdY8LNVN9LRVK77T(cZr1rcyzIuPycKodZy(sIKVWCuDKawMivkMykFB33Z34lzanesyVszeOHz9dDw1ubagW9NgWDanyLsAubqFGM)aOHHgqtgT5lGgcjCsjnc0qi1GiqtgTHa2XcLhK5B788LpF56l5(ERVWCuDKawMivkMaPZWmMVKi5lmhvhjGLjsLIjq6mmJ5lxFj3xyoQosaltKkftar5CkMVT77n(sIKVutWL1HOCofZ3299m)8LmFjdOHqc7vkJanPsX6quoNcWaUNUcChqdwPKgva0hO5paAyOb0KrB(cOHqcNusJanesnic0qUVwQXYemqz5V6bjm4BPrbwPKgv(Y13B99anrqcd(wAuKrBiG(Y134)A1ZPemqz5V6bjm4BPrbeLZPy(sIKV36RLASmbduw(REqcd(wAuGvkPrLVK5lxFj3xjqkkbyD96w9KXsqTjap8LejFTuJLjsOCR(t1TlSRs5cvcSsjnQ8LRVhOjYJp2dUEqTiJ2qa9LejFLaPOeQegUBWSyupuoT5lb4HVC9vcKIsOsy4UbZIr9q50MVequoNI5B7(EJVKi5BgTHa2XcLhK5B788LpF56Rct7QNLQRWy2sytm8ub(sgqdHe2RugbAKZtWd7X)1QNtX6z0gciGbCp)f4oGgSsjnQaOpqZFa0WqdOjJ28fqdHeoPKgbAiKAqeOj(eWkltutWL1Ps0xU(QW0U6zP6kmMTe2edpvGVC9vcKIsOW0UyDfikywgd7BB(sK(sIKVsGuuc5ecFoOQhGYm7lSJ1vwrugltaE4ljs(kbsrjSl4O1DgIHrOa8WxsK8vcKIsqbX6epOQl)fZGpBSwcWdFjrYxjqkkHgtvxQvhPtkFOrb4HVKi5ReifLiELpRlLfkap8LejFJ)RvpNsawxVUvpzSeuBcikNtX8TnFVXxU(g)xREoLip(yQBDWqbeLZPy(2UVN5hqdHe2RugbAuGYhDopyPyagW9NEG7aAWkL0OcG(anz0MVaAEqtcIzyGgfYIW5WMVaA4pmNYYPMkWx(ZdeuJL57PtNbGOVdZ303d48WXAb0eHJHWjbAuVjimqqnww)qNbGOaIuqKDLsA0xU(ERVwQXYeG11RB1L0tWLjWkL0OYxU(ERVWCuDKawMivkMaPZWmgGbC)z(bChqdwPKgva0hOjJ28fqZdAsqmdd0eHJHWjbAuVjimqqnww)qNbGOaIuqKDLsA0xU(MrBiGDSq5bz(2opF5ZxU(sUV36RLASmbyD96wDj9eCzcSsjnQ8LejFTuJLjaRRx3QlPNGltGvkPrLVC9LCFJ)RvpNsawxVUvxspbxMaIY5umFB3xY998n(sdFZOneWowO8GmFPPVQ3eegiOglRFOZaquar5CkMVK5ljs(MrBiGDSq5bz(2opFdLVK5lzanXwrn2TegGgd4(ZagW9NpdChqdwPKgva0hOjJ28fqZdAsqmdd0ONc7rfqZPb0eHJHWjbAYOneWU6nbHbcQXY6h6mae9TnFZOneWowO8GmF56BgTHa2XcLhK5B788LpF56l5(ERVwQXYeG11RB1L0tWLjWkL0OYxsK8n(Vw9CkbyD96wDj9eCzcikNtX8LRVsGuucW661T6s6j4Y6sGuuc1ZP8LmGgfYIW5WMVaAo1u(Axie9nHOVyHYdY8vEySPc8L)8PleFZJdDlFhZxYLanFR3x5hI(Axz57xr03de67P5ldJFPyKjamG7pZhWDanyLsAubqFGMiCmeojqdeSqQhgGcg4bczgmNsGvkPrLVC9LCFvVjOGpZ6uibekGifezxPKg9LejFvVjK0)R6h6maefqKcISRusJ(sgqtgT5lGMh0KGyggWaU)COaUdObRusJka6d0KrB(cOHZdwQo7alfcbAuilcNdB(cO5uHuqKDHmFPBmTlMV0nismZxjqkkFpbGmZxjK6HOVkmTlMVkq0xSumGMiCmeojqt8jGvwMOMGlRtLOVC9vHPD1Zs1vymBjSjgEQaF56l5(QW0U6zP6kmMTez0gcyhIY5umFBZxY9niQ8LU47zXn(sMVKi5ReifLqHPDX6kquar5CkMVT5Bqu5lzagW9NjsG7aAWkL0OcG(anmmc0e)xREoLG9G6oeZdekGOCofdOjJ28fqdNCmGMiCmeojqJLASmb7b1DiMhiuGvkPrLVC91syaAcBKXU99JO1d1n(2MV34lxFTegGMWgzSBFxnOVT77n(Y134)A1ZPeShu3HyEGqbeLZPy(2MVK7Bqu5lDXx(jOR34lz(Y13mAdbSJfkpiZxE(EgWaU)8na3b0GvkPrfa9bAuilcNdB(cOHOnhZxQh6lDJPDrmZx6gePbDJuJg9DO89(j4Y8L)uI(AVVbO5lZGyfyx(kbsr5Rugd7BYYdGgggbAI)RvpNsOW0UyDfikGOCofdOjJ28fqdNCmGMiCmeojqt8jGvwMOMGlRtLOVC9n(Vw9CkHct7I1vGOaIY5umFBZ3GOYxU(MrBiGDSq5bz(YZ3ZagW9NpnG7aAWkL0OcG(anmmc0e)xREoLqHuJgfquoNIb0KrB(cOHtogqteogcNeOj(eWkltutWL1Ps0xU(g)xREoLqHuJgfquoNI5BB(gev(Y13mAdbSJfkpiZxE(EgWaU)mDf4oGgSsjnQaOpqJczr4CyZxane9OnF5lrnmJ5BwkFprhyHqMVKFIoWcHmA0G8piwrK5lyXapoEOHkFNY3uP(sqgqtgT5lGMyQ19mAZxD9WmGg9WSELYiqJbNkmAmad4(Z8xG7aAWkL0OcG(anz0MVaAIPw3ZOnF11dZaA0dZ6vkJanXNawzzmad4(ZNEG7aAWkL0OcG(anz0MVaAIPw3ZOnF11dZaA0dZ6vkJanWmoPMbya3Zh)aUdObRusJka6d0KrB(cOjMADpJ28vxpmdOrpmRxPmc0e)xREofdWaUNVZa3b0GvkPrfa9bAIWXq4Kanes4KsAuKkfRdr5CkF56l5(g)xREoLqHPD1Zs1vymBjGOCofZ3289m)8LRV36RLASmHcPgnkWkL0OYxsK8n(Vw9CkHcPgnkGOCofZ3289m)8LRVwQXYekKA0OaRusJkFjrY34taRSmrnbxwNkrF56B8FT65ucfM2fRRarbeLZPy(2MVN5NVK5lxFV1xfM2vplvxHXSLWMy4PcaAYOnFb0abREgT5RUEygqJEywVszeOjFSZqd8aWaUNp(aUdObRusJka6d0eHJHWjbAYOneWowO8GmFBNNV85lxFvyAx9SuDfgZwcBIHNkaOHzWjAa3FgOjJ28fqdeS6z0MV66Hzan6Hz9kLrGM8XUeiKzagW98fkG7aAWkL0OcG(anr4yiCsGMmAdbSJfkpiZ3255lF(Y13B9vHPD1Zs1vymBjSjgEQaF56l5(ERVes4KsAuKkfRdr5CkFjrY34)A1ZPekmTREwQUcJzlbeLZPy(2UVN5NVC99wFTuJLjui1OrbwPKgv(sIKVX)1QNtjui1OrbeLZPy(2UVN5NVC91snwMqHuJgfyLsAu5ljs(gFcyLLjQj4Y6uj6lxFJ)RvpNsOW0UyDfikGOCofZ3299m)8LmGMmAZxanqWQNrB(QRhMb0OhM1RugbAcWcHtSNpcya3ZhrcChqdwPKgva0hOjchdHtc0KrBiGDSq5bz(YZ3Zanz0MVaAIPw3ZOnF11dZaA0dZ6vkJanbyHWjcyagqJbNkmAmG7aU)mWDanyLsAubqFGMmAZxantXIqqlL0yN)bZYaL7kKWerGMiCmeojqd5(g)xREoLaSUEDRUKEcUmbeLZPy(2UV8XpFjrY34)A1ZPeQegUBWSyupuoT5lbeLZPyDKohy0qLVT7lF8ZxY8LRVK7BgTHa2XcLhK5B788LpFjrY3d0ejuUvp46b1ImAdb0xsK89anrE8XEW1dQfz0gcOVC9LCFTuJLjaRRx3QNmwcQnbwPKgv(sIKVkmTRE4AcUmHAyPKg75BkFjZxsK89anrqcd(wAuKrBiG(sMVKi5R0Zy(Y1xQj4Y6quoNI5BB(Y3zFjrYxfM2vpCnbxMqnSusJ9H)vDKoye0qF55l)8LRVwcdqtyJm2TVFeToF8Z3289gGMkLrGMPyriOLsASZ)GzzGYDfsyIiGbCpFa3b0GvkPrfa9bAQugbAcscOU)uD7c7udKz9ekngcbAYOnFb0eKeqD)P62f2PgiZ6juAmecya3hkG7aAWkL0OcG(anvkJanSycz9NQtbtdHvQ7mdouiqtgT5lGgwmHS(t1PGPHWk1DMbhkeWaUNibUdObRusJka6d0KrB(cOXUWo1azwNnbJgOjchdHtc0qiHtkPrHCEcEyp(Vw9CkwpJ2qa9LRVK7RnYOVT7BO4NVKi57T(I8p4CCGkXuSie0sjn25FWSmq5Ucjmr0xYaAQugbASlStnqM1ztWObmG7Vb4oGgSsjnQaOpqtgT5lGMNac5CHA5Pc6hphe2JWwml1anr4yiCsGgcjCsjnkKZtWd7X)1QNtX6z0gcOVC9LCFTrg9TDFdf)8LejFV1xK)bNJdujMIfHGwkPXo)dMLbk3viHjI(Y13B9f5FW54avc7c7udKzD2emAFjdOPszeO5jGqoxOwEQG(XZbH9iSfZsnGbC)PbChqdwPKgva0hOjJ28fqJbNkmANbAuilcNdB(cO5Ul0xdovy08LZyx(AxOVxtWfYmFrMnYPHkFjKAqmeF5mATVsOVGmu5l1azMVzP89ihiQ8LZyx(s0p(yQBDWqFjFO8vcKIY3H575B8LHXVumFFOVAKXiZ3h6l91tWLrd6(oFjFO8naIPHqFTRS898n(YW4xkgzanr4yiCsGMB9LqcNusJc2bghQbvDdovy08LRVK7l5(AWPcJMWolKaPO6kqyAZx(2gpFpFJVC9n(Vw9CkrE8Xu36GHcikNtX8TDF5JF(sIKVgCQWOjSZcjqkQUceM28LVT775B8LRVK7B8FT65ucW661T6s6j4YequoNI5B7(Yh)8LejFJ)RvpNsOsy4UbZIr9q50MVequoNI1r6CGrdv(2UV8XpFjZxsK8nJ2qa7yHYdY8TDE(YNVC9vcKIsOsy4UbZIr9q50MVeGh(sMVC9LCFV1xdovy0egFIRK1J)RvpNYxsK81GtfgnHXNi(Vw9CkbeLZPy(sIKVes4KsAuyWPcJw)aopCSw(YZ3Z(sMVK5ljs(k9mMVC91GtfgnHDwibsr1vGW0MV8TDE(snbxwhIY5umad4E6kWDanyLsAubqFGMiCmeojqZT(siHtkPrb7aJd1GQUbNkmA(Y1xY9LCFn4uHrty8jKaPO6kqyAZx(2gpFpFJVC9n(Vw9CkrE8Xu36GHcikNtX8TDF5JF(sIKVgCQWOjm(esGuuDfimT5lFB33Z34lxFj334)A1ZPeG11RB1L0tWLjGOCofZ329Lp(5ljs(g)xREoLqLWWDdMfJ6HYPnFjGOCofRJ05aJgQ8TDF5JF(sMVKi5BgTHa2XcLhK5B788LpF56ReifLqLWWDdMfJ6HYPnFjap8LmF56l5(ERVgCQWOjSZIRK1J)RvpNYxsK81GtfgnHDwe)xREoLaIY5umFjrYxcjCsjnkm4uHrRFaNhowlF55lF(sMVK5ljs(k9mMVC91GtfgnHXNqcKIQRaHPnF5B788LAcUSoeLZPyanz0MVaAm4uHrJpad4E(lWDanyLsAubqFGMmAZxangCQWODgOHPFdOXGtfgTZanr4yiCsGMB9LqcNusJc2bghQbvDdovy08LRV36RbNkmAc7S4kzDqg2LaPO8LRVK7RbNkmAcJpr8FT65ucikNtX8LejFV1xdovy0egFIRK1bzyxcKIYxYaAuilcNdB(cO5ut57x6w((f67x(cYqFn4uHrZ3d4tyuiZ30xjqkQq8fKH(AxOVVDHqF)Y34)A1ZPe(EIG(ou(w4yxi0xdovy089a(egfY8n9vcKIkeFbzOVsVD57x(g)xREoLaWaU)0dChqdwPKgva0hOjJ28fqJbNkmA8b0eHJHWjbAU1xcjCsjnkyhyCOgu1n4uHrZxU(ERVgCQWOjm(exjRdYWUeifLVC9LCFn4uHrtyNfX)1QNtjGOCofZxsK89wFn4uHrtyNfxjRdYWUeifLVKb0W0Vb0yWPcJgFagGbyaneqiB(c4E(4hF8XVqXVZanCsynvadOHOLOFQU)uF)PqO9137UqFh5JhA(s9qFjoFSZqd8GyFHi)doqu5l7LrFtq7Ltdv(gVYkazcNwIAk03ZH23t(fbeAOYxITuJLjOhX(AVVeBPgltqpbwPKgve7l5NPdzcNwIAk0x(cTVN8lci0qLVedblK6HbOGEe7R9(smeSqQhgGc6jWkL0OIyFj)mDit40sutH(EAH23t(fbeAOYxITuJLjOhX(AVVeBPgltqpbwPKgve7l58rhYeoToTeTe9t19N67pfcTV(E3f67iF8qZxQh6lX5JDjqiZi2xiY)Gdev(YEz03e0E50qLVXRScqMWPLOMc9nuH23t(fbeAOYxITuJLjOhX(AVVeBPgltqpbwPKgve7l5HIoKjCAjQPqFjYq77j)Iacnu5lXqWcPEyakOhX(AVVedblK6HbOGEcSsjnQi2xYpthYeoToTeTe9t19N67pfcTV(E3f67iF8qZxQh6lXgCQWOXi2xiY)Gdev(YEz03e0E50qLVXRScqMWPLOMc99CO99KFraHgQ8Lyl1yzc6rSV27lXwQXYe0tGvkPrfX(s(z6qMWPLOMc990cTVN8lci0qLVeBWPcJM4SGEe7R9(sSbNkmAc7SGEe7l5HIoKjCAjQPqFpTq77j)Iacnu5lXgCQWOj4tqpI91EFj2GtfgnHXNGEe7l58rhYeoTe1uOV01q77j)Iacnu5lXgCQWOjolOhX(AVVeBWPcJMWolOhX(soF0HmHtlrnf6lDn0(EYViGqdv(sSbNkmAc(e0JyFT3xIn4uHrty8jOhX(sEOOdzcNwIAk0x(BO99KFraHgQ8Lydovy0eNf0JyFT3xIn4uHrtyNf0JyFj)mDit40sutH(YFdTVN8lci0qLVeBWPcJMGpb9i2x79Lydovy0egFc6rSVKZhDit40sutH(E6dTVN8lci0qLVeBWPcJM4SGEe7R9(sSbNkmAc7SGEe7l58rhYeoTe1uOVN(q77j)Iacnu5lXgCQWOj4tqpI91EFj2GtfgnHXNGEe7l5NPdzcNwNwIwI(P6(t99NcH2xFV7c9DKpEO5l1d9L4aSq4ej2xiY)Gdev(YEz03e0E50qLVXRScqMWPLOMc99CO99KFraHgQ8LyiyHupmaf0JyFT3xIHGfs9WauqpbwPKgve7l5NPdzcNwIAk0x(cTVN8lci0qLVeBPgltqpI91EFj2snwMGEcSsjnQi2xYpthYeoTe1uOV8fAFp5xeqOHkFjgcwi1ddqb9i2x79LyiyHupmaf0tGvkPrfX(s(z6qMWPLOMc9LVq77j)Iacnu5lXXVuGJjOhX(AVVeh)sboMGEcSsjnQi2xYpthYeoTe1uOVHk0(EYViGqdv(smeSqQhgGc6rSV27lXqWcPEyakONaRusJkI9L8Z0HmHtlrnf67nH23t(fbeAOYxIHGfs9WauqpI91EFjgcwi1ddqb9eyLsAurSVKFMoKjCADAjAj6NQ7p13FkeAF99Ul03r(4HMVup0xIJpbSYYye7le5FWbIkFzVm6BcAVCAOY34vwbit40sutH(Eo0(EYViGqdv(sSLASmb9i2x79Lyl1yzc6jWkL0OIyFj)mDit40sutH(gQq77j)Iacnu5lXwQXYe0JyFT3xITuJLjONaRusJkI9L8Z0HmHtlrnf6BOcTVN8lci0qLVeZEqT0ukb9i2x79Ly2dQLMsjONaRusJkI9L8Z0HmHtlrnf6lrgAFp5xeqOHkFj2snwMGEe7R9(sSLASmb9eyLsAurSVKFMoKjCAjQPqFjYq77j)Iacnu5lXShulnLsqpI91EFjM9GAPPuc6jWkL0OIyFj)mDit40sutH(EtO99KFraHgQ8LyiyHupmaf0JyFT3xIHGfs9WauqpbwPKgve7l58rhYeoTe1uOV3eAFp5xeqOHkFjM9GAPPuc6rSV27lXShulnLsqpbwPKgve7l5NPdzcNwIAk0x6AO99KFraHgQ8Lyl1yzc6rSV27lXwQXYe0tGvkPrfX(s(z6qMWPLOMc990hAFp5xeqOHkFjM9GAPPuc6rSV27lXShulnLsqpbwPKgve7l58rhYeoToTeTe9t19N67pfcTV(E3f67iF8qZxQh6lXhqm(YsPrSVqK)bhiQ8L9YOVjO9YPHkFJxzfGmHtlrnf6lrgAFp5xeqOHkFj2snwMGEe7R9(sSLASmb9eyLsAurSVP57P8eru(s(z6qMWPLOMc99Mq77j)Iacnu5BZiFsFzTklPJVenen(AVVefy6R8Ra1GmF)deM2d9LCIgY8L8Z0HmHtlrnf67nH23t(fbeAOYxIn4uHrtCwqpI91EFj2GtfgnHDwqpI9LC(OdzcNwIAk03tl0(EYViGqdv(2mYN0xwRYs64lrdrJV27lrbM(k)kqniZ3)aHP9qFjNOHmFj)mDit40sutH(EAH23t(fbeAOYxIn4uHrtWNGEe7R9(sSbNkmAcJpb9i2xY5JoKjCAjQPqFPRH23t(fbeAOY3Mr(K(YAvwshFjA81EFjkW0x1qyyZx((himTh6l50GmFjNp6qMWPLOMc9LUgAFp5xeqOHkFj2GtfgnXzb9i2x79Lydovy0e2zb9i2xYjs6qMWPLOMc9LUgAFp5xeqOHkFj2GtfgnbFc6rSV27lXgCQWOjm(e0JyFj)g6qMWPLOMc9L)gAFp5xeqOHkFj2snwMGEe7R9(sSLASmb9eyLsAurSVKFMoKjCAjQPqF5VH23t(fbeAOYxIJFPahtqpI91EFjo(LcCmb9eyLsAurSVP57P8eru(s(z6qMWPLOMc990hAFp5xeqOHkFjgcwi1ddqb9i2x79LyiyHupmaf0tGvkPrfX(MMVNYter5l5NPdzcNwIAk03tFO99KFraHgQ8LyiyHupmaf0JyFT3xIHGfs9WauqpbwPKgve7l5NPdzcNwNwIwI(P6(t99NcH2xFV7c9DKpEO5l1d9L44)A1ZPye7le5FWbIkFzVm6BcAVCAOY34vwbit40sutH(YxO99KFraHgQ8Lyl1yzc6rSV27lXwQXYe0tGvkPrfX(soF0HmHtlrnf6lFH23t(fbeAOYxIHGfs9WauqpI91EFjgcwi1ddqb9eyLsAurSVKZhDit40sutH(YxO99KFraHgQ8Ly2dQLMsjOhX(AVVeZEqT0ukb9eyLsAurSVKZhDit40sutH(EAH23t(fbeAOYxITuJLjOhX(AVVeBPgltqpbwPKgve7l5NPdzcNwIAk0x(BO99KFraHgQ8Lyl1yzc6rSV27lXwQXYe0tGvkPrfX(s(z6qMWP1PLOLOFQU)uF)PqO9137UqFh5JhA(s9qFjoaleoXE(iX(cr(hCGOYx2lJ(MG2lNgQ8nELvaYeoTe1uOVNdTVN8lci0qLVeBPgltqpI91EFj2snwMGEcSsjnQi2xYpthYeoTe1uOV8fAFp5xeqOHkFjgcwi1ddqb9i2x79LyiyHupmaf0tGvkPrfX(s(z6qMWP1PLOLOFQU)uF)PqO9137UqFh5JhA(s9qFjwHujO2i2xiY)Gdev(YEz03e0E50qLVXRScqMWPLOMc9nuH23t(fbeAOYxITuJLjOhX(AVVeBPgltqpbwPKgve7l5HIoKjCAjQPqFjYq77j)Iacnu5lXwQXYe0JyFT3xITuJLjONaRusJkI9LC(OdzcNwIAk0x6AO99KFraHgQ8Lyl1yzc6rSV27lXwQXYe0tGvkPrfX(sEOOdzcNwIAk03tFO99KFraHgQ8Lyl1yzc6rSV27lXwQXYe0tGvkPrfX(s(z6qMWPLOMc99m)cTVN8lci0qLVnJ8j9L1QSKo(s04R9(suGPVQHWWMV89pqyAp0xYPbz(s(z6qMWPLOMc99m)cTVN8lci0qLVeBPgltqpI91EFj2snwMGEcSsjnQi2xY5JoKjCAjQPqFpFo0(EYViGqdv(sSLASmb9i2x79Lyl1yzc6jWkL0OIyFj)mDit40sutH(EMVq77j)Iacnu5lXqWcPEyakOhX(AVVedblK6HbOGEcSsjnQi2xYpthYeoTe1uOVNjYq77j)Iacnu5lXwQXYe0JyFT3xITuJLjONaRusJkI9L8Z0HmHtlrnf6lFNdTVN8lci0qLVeBPgltqpI91EFj2snwMGEcSsjnQi2xY5JoKjCAjQPqF5luH23t(fbeAOYxITuJLjOhX(AVVeBPgltqpbwPKgve7l58rhYeoToTNA5JhAOY3Z8Z3mAZx(QhMXeoTanjOD9qGMMrguN281jHjLb0CaFQrJanebr4lDJPD5l)r1eCz(EkwxVULtlrqe(YFycJx(E(0hIV8Xp(4ZP1PLiicFp5vwbil0oTebr47j0xIU6eaYmzSmMV27lDx0nnOBKA0inOBmTlMV0ni6R9((LULVXhSmFTegGgZxoxVVje9fPZbgnu5R9(QhcOV6Vc8fRhm4Yx79vondH(sE(yNHg4HVeXzYeoTebr47j0x6EyPKgv(2Kr4qnXj1(E6YO5Regtqg6RctLVbxpOM5RCgg9L6H(YsLV0n)rmHtlrqe(Ec99uKnvGVeTpyP8T5alfc9nLg9ydY8v(HOVuAKoJKULVKNMVejn9LzzmmZ3PygMkFFkFVHMKXFSV09PRX3cbnyQ9nlLVYzlFpGibSmFzVm6B9Nqig9LngyAZxmHtlrqe(Ec99uKnvGV8NqMHWPc8TXGty03P8LOFIoL(ou(26b99kjG(wVDnvGVOMH(AVVQ33Su(Y5lInFFcimMh(Y5blfZ3H5lDF6A8TqqdMAHtlrqe(Ec99KxzfGkFLZQLVetnbxwhIY5umI9n(LAS5RuZ81EFZJdDlFNYxPNX8LAcUmMVFPB5l5AKX89K0TVCsMH((LVgmzxKjCAjcIW3tOVeDLcv(M1Bxi03teOjbXmSVyzWw(AVVm08f8WxMb)kaH(EkpgfkprMWPLiicFpH(EQqDshFBUZxcmHVe9t0P0x9hmrFztfrFhZxiQhK57x(g)IkLa1PHkFH5O6ibSmMWPLiicFpH(E3jIUprH2xF5pLr7H(2yqScSlFpGFK57u27RbNkmA(Q)GjkCADAZOnFXehqm(YsPrtE044T5lN2mAZxmXbeJVSuA0KhnG5WWUctLtBgT5lM4aIXxwknAYJguAKDfHjL50MrB(IjoGy8LLsJM8OrcLB1FQUDHDfMQqoGy8LLsRBJmYluHmu8U1snwMGbkl)vpiHbFln60se(EkjKAW0qMVPVgCQWOX8n(Vw9CQq8vnegfQ8vQLVe5ncFV7Ay(Yjz(gVEgw(MmFbRRx3YxopmmZ3V8LiVXxgg)s5ReiKz(gBf1ileFLanFVsMV2)(kNvlFJkOViffgnMV27BWqa9n9n(Vw9CkbDekqyAZx(Qgcd7H(ofZWuj89ut57yeZ8LqQbrFVsMV17leLZPui0xiAGWY3ZH4lQzOVq0aHLV8tCJWPnJ28ftCaX4llLgn5rdcjCsjngsLYipdovy06N7SwvmK)GhdTHkecPge5DoecPge7OMH84N4MqIFPgB(INbNkmAIZIRK1bzyxcKIIl5gCQWOjolI)RvpNsOaHPnFr0q0qK3WJFK50MrB(IjoGy8LLsJM8ObHeoPKgdPszKNbNkmAD(6SwvmK)GhdTHkecPge5DoecPge7OMH84N4MqIFPgB(INbNkmAc(exjRdYWUeiffxYn4uHrtWNi(Vw9CkHceM28frdrdrEdp(rMtlr47PKzJCAiZ30xdovy0y(si1GOVsT8n(YhjCQaFTl034)A1ZP89P81UqFn4uHrleFvdHrHkFLA5RDH(QaHPnF57t5RDH(kbsr57y(EaFcJczcF5piz(M(Ymiwb2LVYVAOge6R9(gmeqFtFVMGle67bCE4yT81EFzgeRa7Yxdovy0yH4BY8LdQ1(MmFtFLF1qni0xQh67q5B6RbNkmA(Yz0AFFOVCgT236nFzTQOVCg7Y34)A1ZPycN2mAZxmXbeJVSuA0KhniKWjL0yivkJ8m4uHrRFaNhowRq(dEm0gQqiKAqKhFHqi1Gyh1mK35qIFPgB(I3TgCQWOjolUswhKHDjqkkUgCQWOj4tCLSoid7sGuuKizWPcJMGpXvY6GmSlbsrXLCYn4uHrtWNi(Vw9CkHceM28frJbNkmAc(esGuuDfimT5lYOlKFwCdnn4uHrtWN4kzDjqkkYOlKtiHtkPrHbNkmAD(6SwvKmYANCYn4uHrtCwe)xREoLqbctB(IOXGtfgnXzHeifvxbctB(Im6c5Nf3qtdovy0eNfxjRlbsrrgDHCcjCsjnkm4uHrRFUZAvrYiZPLi89usi1GPHmFJGqiwMVm0ap8L6H(AxOV8pyw2yT89P8LOF8Xu36GH(Es6(u5lsrHrJ50MrB(IjoGy8LLsJM8ObHeoPKgdPszKhfOw3JkyiesniYZsnwMiHYT6pv3UWUkLluXn(LcCmr8lcFmT5R(t1TlSRWu50MrB(IjoGy8LLsJM8ObHeoPKgdPszKNk2HwiesniYdcwi1ddqHct7I1Ji0YPSwCHGfs9Wauat5JSSUbZIrHqSIOtRtlrqe(EkPdgbnu5lsaHT81gz0x7c9nJ2d9Dy(MeYrNsAu40MrB(IXtEkvNcI4jgDAjcFpDqKawMVSdmoudQ81GtfgnMVs4ub(cYqLVCg7Y3e0E50MOV6PqMtBgT5lgn5rdcjCsjngsLYip2bghQbvDdovy0cHqQbrEKJ8p4CCGkXuSie0sjn25FWSmq5UcjmrKejK)bNJdujSlStnqM1ztWOjrc5FW54avINac5CHA5Pc6hphe2JWwml1KXL84)A1ZPetXIqqlL0yN)bZYaL7kKWerbetvlsKI)RvpNsyxyNAGmRZMGrlGOCofJeP4)A1ZPepbeY5c1Ytf0pEoiShHTywQfquoNIrgjsKJ8p4CCGkHDHDQbYSoBcgnjsi)dohhOs8eqiNlulpvq)45GWEe2IzPMmUi)dohhOsmflcbTusJD(hmlduURqcteDAjcIWx(ZjCsjnYCAZOnFXOjpAqiHtkPXqQug5D8VEQGoeSMy)45GWqiKAqKx8FT65ucgOS8x9Geg8T0OaIY5uS2UHRLASmbduw(REqcd(wAKl5wQXYeG11RB1L0tWLXn(Vw9CkbyD96wDj9eCzcikNtXA7CO4g)xREoLqLWWDdMfJ6HYPnFjGOCofRJ05aJgQA7COir6wl1yzcW661T6s6j4YiZPnJ28fJM8ObHeoPKgdPszK3X)6Pc6qWczHqi1Gipl1yzc2dQ7qmpqixiyHTXhxlHbOjSrg723pIwpu302nCPMGlRdr5Ckw73qIu8jGvwMOMGlRtLixl1yzcfsnAKB8FT65ucfsnAuar5CkwBqWcf2iJD77850MrB(IrtE0GqcNusJHuPmYJz9dDw1ubHqi1GiVmAdbSJfkpiJ3zUKFlmhvhjGLjsLIjq6mmJrIemhvhjGLjsLIjMQ9Z3qMtBgT5lgn5rdcjCsjngsLYiVuPyDikNtfcHudI8YOneWowO8GS25XhxYVfMJQJeWYePsXeiDgMXircMJQJeWYePsXeiDgMX4somhvhjGLjsLIjGOCofR9BirIAcUSoeLZPyTFMFKrMtBgT5lgn5rdcjCsjngsLYip58e8WE8FT65uSEgTHagcHudI8i3snwMGbkl)vpiHbFlnY92d0ebjm4BPrrgTHaYn(Vw9Ckbduw(REqcd(wAuar5Ckgjs3APgltWaLL)QhKWGVLgjJl5sGuucW661T6jJLGAtaEqIKLASmrcLB1FQUDHDvkxOI7bAI84J9GRhulYOneqsKKaPOeQegUBWSyupuoT5lb4bxjqkkHkHH7gmlg1dLtB(sar5Ckw73qIugTHa2XcLhK1op(4QW0U6zP6kmMTe2edpvazoTz0MVy0KhniKWjL0yivkJ8uGYhDopyPyHqi1GiV4taRSmrnbxwNkrUkmTREwQUcJzlHnXWtfWvcKIsOW0UyDfikywgd3grsIKeifLqoHWNdQ6bOmZ(c7yDLveLXYeGhKijbsrjSl4O1DgIHrOa8GejjqkkbfeRt8GQU8xmd(SXAjapirscKIsOXu1LA1r6KYhAuaEqIKeifLiELpRlLfkapirk(Vw9CkbyD96w9KXsqTjGOCofRTB4g)xREoLip(yQBDWqbeLZPyTFMFoTeHV8hMtz5utf4l)5bcQXY890PZaq03H5B67bCE4yTCAZOnFXOjpA8GMeeZWHmu8uVjimqqnww)qNbGOaIuqKDLsAK7TwQXYeG11RB1L0tWLX9wyoQosaltKkftG0zygZPnJ28fJM8OXdAsqmdhsSvuJDlHbOX4DoKHIN6nbHbcQXY6h6maefqKcISRusJCZOneWowO8GS25XhxYV1snwMaSUEDRUKEcUmsKSuJLjaRRx3QlPNGlJl5X)1QNtjaRRx3QlPNGltar5Ckw7KF(gIMmAdbSJfkpiJMQ3eegiOglRFOZaquar5CkgzKiLrBiGDSq5bzTZluKrMtlr47PMYx7cHOVje9fluEqMVYdJnvGV8NpDH4BECOB57y(sUeO5B9(k)q0x7klF)kI(EGqFpnFzy8lfJmHtBgT5lgn5rJh0KGygoe9uypQ4DAHmu8YOneWU6nbHbcQXY6h6maeBlJ2qa7yHYdY4MrBiGDSq5bzTZJpUKFRLASmbyD96wDj9eCzKif)xREoLaSUEDRUKEcUmbeLZPyCLaPOeG11RB1L0tWL1LaPOeQNtrMtBgT5lgn5rJh0KGygoKHIheSqQhgGcg4bczgmNIl5Q3euWNzDkKacfqKcISRusJKiPEtiP)x1p0zaikGifezxPKgjZPLi89uHuqKDHmFPBmTlMV0nismZxjqkkFpbGmZxjK6HOVkmTlMVkq0xSumN2mAZxmAYJgCEWs1zhyPqyidfV4taRSmrnbxwNkrUkmTREwQUcJzlHnXWtfWLCfM2vplvxHXSLiJ2qa7quoNI1g5brfD5S4gYirscKIsOW0UyDfikGOCofRTGOImN2mAZxmAYJgCYXcHHrEX)1QNtjypOUdX8aHcikNtXczO4zPgltWEqDhI5bc5AjmanHnYy3((r06H6M2UHRLWa0e2iJD77QbB)gUX)1QNtjypOUdX8aHcikNtXAJ8GOIUWpbD9gY4MrBiGDSq5bz8o70se(s0MJ5l1d9LUX0UiM5lDdI0GUrQrJ(ou(E)eCz(YFkrFT33a08LzqScSlFLaPO8vkJH9nz5HtBgT5lgn5rdo5yHWWiV4)A1ZPekmTlwxbIcikNtXczO4fFcyLLjQj4Y6ujYn(Vw9CkHct7I1vGOaIY5uS2cIkUz0gcyhluEqgVZoTz0MVy0Khn4KJfcdJ8I)RvpNsOqQrJcikNtXczO4fFcyLLjQj4Y6ujYn(Vw9CkHcPgnkGOCofRTGOIBgTHa2XcLhKX7Stlr4lrpAZx(sudZy(MLY3t0bwiK5l5NOdSqiJgni)dIvez(cwmWJJhAOY3P8nvQVeK50MrB(IrtE0iMADpJ28vxpmlKkLrEgCQWOXCAZOnFXOjpAetTUNrB(QRhMfsLYiV4taRSmMtBgT5lgn5rJyQ19mAZxD9WSqQug5bZ4KAMtlrqe(MrB(IrtE0GH8piwrmKHIxgTHa2XcLhKX7m3BvyAx9W1eCzc1Wsjn2Z3uCTuJLjyGYYF1dsyW3sJHuPmYliHb9)aleg6h0KGygo0uiZq4ubDMbNWyOPqMHWPc6mdoHXqZaLL)QhKWGVLgdDcLB1FQUDHDfMQqRW0U6XF0Hmu8KaPOemqLcRU6Fzb4rOvyAx94p6qRW0U6XF0HMfFqya2zgCcJHmu8uOeifLGczgcNkOZ5blLGzzmC7ezOzXhegGDMbNWyidfpfkbsrjOqMHWPc6CEWsjywgd3orgAkKziCQGoZGty0PLiicFZOnFXOjpAWq(heRigYqXlJ2qa7yHYdY4DM7TkmTRE4AcUmHAyPKg75BkU3APgltWaLL)QhKWGVLgdPszK3FGfcdnfYmeovqNzWjmgAkKziCQGoZGtym0hVnFfAW661T6s6j4YcTkHH7gmlg1dLtB(k05XhtDRdg60MrB(IrtE0iMADpJ28vxpmlKkLrEX)1QNtXCAZOnFXOjpAabREgT5RUEywivkJ8Yh7m0apczO4riHtkPrrQuSoeLZP4sE8FT65ucfM2vplvxHXSLaIY5uS2oZpU3APgltOqQrJKif)xREoLqHuJgfquoNI12z(X1snwMqHuJgjrk(eWkltutWL1PsKB8FT65ucfM2fRRarbeLZPyTDMFKX9wfM2vplvxHXSLWMy4PcCAZOnFXOjpAabREgT5RUEywivkJ8Yh7sGqMfcZGt04DoKHIxgTHa2XcLhK1op(4QW0U6zP6kmMTe2edpvGtBgT5lgn5rdiy1ZOnF11dZcPszKxawiCI98XqgkEz0gcyhluEqw784J7TkmTREwQUcJzlHnXWtfWL8BjKWjL0OivkwhIY5uKif)xREoLqHPD1Zs1vymBjGOCofR9Z8J7TwQXYekKA0ijsX)1QNtjui1OrbeLZPyTFMFCTuJLjui1OrsKIpbSYYe1eCzDQe5g)xREoLqHPDX6kquar5Ckw7N5hzoTz0MVy0KhnIPw3ZOnF11dZcPszKxawiCIHmu8YOneWowO8GmENDADAjcIWxI(Fk9L(GqM50MrB(IjYh7sGqMXlQtotf0zxP65WczO4LrBiGDSq5bzTX7gN2mAZxmr(yxceYmAYJgrDYzQGo7kvphwidfVmAdbSJfkpiJ3PXvHPD1dxtWLjO48GLcvDlHbOXANxOCAZOnFXe5JDjqiZOjpAW5blvNDGLcHHmu8SuJLjKaHmBQGo7HiJl5kmTRE4AcUmbfNhSuOQBjmangVmAdbSJfkpiJejfM2vpCnbxMGIZdwku1TegGgRDEHImsKSuJLjKaHmBQGo7HiJRLASmruNCMkOZUs1ZHXvHPD1dxtWLjO48GLcvDlHbOXAN3zN2mAZxmr(yxceYmAYJgkmTRE8hDidfpYLaPOemqLcRU6FzbeZOrI0Tes4KsAuC8VEQGoeSMy)45GqY4sUeifLqLWWDdMfJ6HYPnFjap4cblK6HbOqHPspiZ6XF0CZOneWowO8GS24fksKYOneWowO8GmE8rMtBgT5lMiFSlbczgn5rd8yuO8edzO4bbRj2pEoiuOqQjowBKFMF0uHPD1dxtWLjO48GLcvDlHbOXOlHImUkmTRE4AcUmbfNhSuOQBjmanwBNg3BjKWjL0O44F9ubDiynX(XZbHKijbsrjyCsO8ubD5HzcWdN2mAZxmr(yxceYmAYJg4XOq5jgYqXdcwtSF8CqOqHutCS247gUkmTRE4AcUmbfNhSuOQBjmanw73W9wcjCsjnko(xpvqhcwtSF8CqOtBgT5lMiFSlbczgn5rd8yuO8edzO4DRct7QhUMGltqX5blfQ6wcdqJX9wcjCsjnko(xpvqhcwtSF8CqijsutWL1HOCofRTBircMJQJeWYePsXeiDgMX4cZr1rcyzIuPycikNtXA7gN2mAZxmr(yxceYmAYJgCEWs1zhyPqOtBgT5lMiFSlbczgn5rd8yuO8edzO4DlHeoPKgfh)RNkOdbRj2pEoi0P1PLiicFj6)P03g0apCAZOnFXe5JDgAGh8YQvxvQqgkEkmTRE4AcUmbfNhSuOQBjmanw78ITIASJfkpiJejfM2vpCnbxMGIZdwku1TegGgRDE3qI0TwQXYesGqMnvqN9qKrIemhvhjGLjsLIjq6mmJXfMJQJeWYePsXequoNI1gVZNjrs6zmUutWL1HOCofRnENp70MrB(IjYh7m0apOjpAOW0U6XF0Hmu8ULqcNusJIJ)1tf0HG1e7hpheYLCjqkkHkHH7gmlg1dLtB(saEWfcwi1ddqHctLEqM1J)O5MrBiGDSq5bzTXluKiLrBiGDSq5bz84JmN2mAZxmr(yNHg4bn5rd8yuO8edzO4DlHeoPKgfh)RNkOdbRj2pEoi0PnJ28ftKp2zObEqtE0GczgcNkOZm4egdj2kQXULWa0y8ohYqXtHsGuuckKziCQGoNhSucMLXWTXluCJ)RvpNsKhFm1ToyOaIY5uS2cLtBgT5lMiFSZqd8GM8ObfYmeovqNzWjmgsSvuJDlHbOX4DoKHINcLaPOeuiZq4ubDopyPemlJHB7StBgT5lMiFSZqd8GM8ObfYmeovqNzWjmgsSvuJDlHbOX4DoKHIheSqHnYy3(or2g5X)1QNtjuyAx9SuDfgZwcikNtX4ERLASmHcPgnsIu8FT65ucfsnAuar5Ckgxl1yzcfsnAKeP4taRSmrnbxwNkrUX)1QNtjuyAxSUcefquoNIrMtlr4lr7fw(AjmanFzCYdMVje9vnSusJQq81UgMVCgT2xnA(26b9LDGLYxiyHmAW5blfZ3PygMkFFkF5KJnvGVup0x6UOBAq3i1OrAq3yAxeZ8LUbrHtBgT5lMiFSZqd8GM8ObNhSuD2bwkegYqXJ8BzOztfWeXwrnsIKct7QhUMGltqX5blfQ6wcdqJ1oVyROg7yHYdYiJRcLaPOeuiZq4ubDopyPemlJHBpuCHGfkSrg723dvBX)1QNtjYQvxvkbeLZPyoToTebr47P7T5lN2mAZxmr8FT65umEhVnFfYqXJqcNusJc58e8WE8FT65uSEgTHasI0bAIGeg8T0OiJ2qa5EGMiiHbFlnkGOCofRnE8DAKij9mgxQj4Y6quoNI1gFNMtlrqe(EY)1QNtXCAZOnFXeX)1QNtXOjpAKq5w9NQBxyxHPkKHIx8FT65ucvcd3nywmQhkN28LaIY5uSosNdmAOQn6kxYJ)RvpNsawxVUvxspbxMaIY5uS2ORCTuJLjaRRx3QlPNGlJePBTuJLjaRRx3QlPNGlJmUKZqRl9fitydc5J)2jYJixlHbOjSrg723pIwpu30grsI0Tm06sFbYe2Gq(4VDI8isIe1eCzDikNtXANp(XpY4sE8FT65uIu6LNkT5RUEKLequoNI12z(lxYHGfs9WauKsV8uPnFX6uqSoXTirI9GAPPuIWiHPy9)pXOEQaYir6wiyHupmafP0lpvAZxSofeRtClU3YEqT0ukryKWuS()NyupvazCjp(Vw9CkrE8Xu36GHcikNtX6iDoWOHQ2ORCjKWjL0OGcuR7rfKePBjKWjL0OGcuR7rfKejcjCsjnkuXo0iJejPNX4snbxwhIY5uS2c1noTz0MVyI4)A1ZPy0KhnypOUdX8aHHeBf1y3syaAmENdzO4zjmanHnYy3((r06H6M2UHl5wcdqtyJm2TVRgS9B4MrBiGDSq5bzTXluKiXqRl9fitydc5J)2jYJixjqkkHkHH7gmlg1dLtB(saEWnJ2qa7yHYdYAJ3nCj)wfM2vplvxHXSLWMy4Pcirk(eWkltutWL1PsKmYCAjcF5p41kMV0xpbxMVup0xWdFT33B8LHXVumFT3xwRk6lNXU8LOF8Xu36GHH47jYUqiNHHH4lid9LZyx(s3jmSV3bZIr9q50MVeoTz0MVyI4)A1ZPy0KhnaRRx3QlPNGllKHIhHeoPKgfmRFOZQMkGl5X)1QNtjYJpM6whmuar5CkwhPZbgnu12nKif)xREoLip(yQBDWqbeLZPyDKohy0qv7N5hzCjp(Vw9CkHkHH7gmlg1dLtB(sar5CkwBbrfjssGuucvcd3nywmQhkN28La8GmN2mAZxmr8FT65umAYJgG11RB1L0tWLfYqXJqcNusJIuPyDikNtrIK0ZyCPMGlRdr5CkwB8D2PnJ28fte)xREofJM8OHkHH7gmlg1dLtB(kKHIhHeoPKgfmRFOZQMkGl5Q3eG11RB1L0tWL1vVjGOCofJePBTuJLjaRRx3QlPNGlJmN2mAZxmr8FT65umAYJgQegUBWSyupuoT5RqgkEes4KsAuKkfRdr5CksKKEgJl1eCzDikNtXAJVZoTz0MVyI4)A1ZPy0KhnYJpM6whmmKHIxgTHa2XcLhKX7mxfkbsrjOqMHWPc6CEWsjywgd3opIKl53siHtkPrbfOw3Jkijses4KsAuqbQ19OcYL84)A1ZPeG11RB1L0tWLjGOCofR9Z8JeP4)A1ZPeQegUBWSyupuoT5lbeLZPyDKohy0qv7N5h3BTuJLjaRRx3QlPNGlJmYCAZOnFXeX)1QNtXOjpAKhFm1ToyyiXwrn2TegGgJ35qgkEz0gcyhluEqw784JRcLaPOeuiZq4ubDopyPemlJHBNhrY9wfM2vplvxHXSLWMy4PcCAZOnFXeX)1QNtXOjpAWaLL)QhKWGVLgdzO4bbRj2pEoiuOqQjowBNjsUX)1QNtjaRRx3QlPNGltar5CkwBNdf34)A1ZPeQegUBWSyupuoT5lbeLZPyDKohy0qvBNdLtBgT5lMi(Vw9Ckgn5rdW661T6jJLGAlKHIhHeoPKgfmRFOZQMkGRcLaPOeuiZq4ubDopyPemlJHBJpUKFGMip(yp46b1ImAdbKejjqkkHkHH7gmlg1dLtB(saEWn(Vw9CkrE8Xu36GHcikNtXA)m)irk(Vw9CkrE8Xu36GHcikNtXA)m)4g)xREoLqLWWDdMfJ6HYPnFjGOCofR9Z8JmN2mAZxmr8FT65umAYJgG11RB1tglb1wiXwrn2TegGgJ35qgkEz0gcyhluEqw784JRcLaPOeuiZq4ubDopyPemlJHBJpUKFGMip(yp46b1ImAdbKejjqkkHkHH7gmlg1dLtB(saEqIu8FT65ucfM2vplvxHXSLaIY5uS2cIkYCAZOnFXeX)1QNtXOjpAaZHHDfMQqgkE3EGMi46b1ImAdb0PLiicFP7HLsAufIVNaqM5B9MVqm16w(wpuo1(kHxjH5H(AxPrmZxop0U89aeYaNkW3PoHbPmkCAjcIW3mAZxmr8FT65umAYJgSmchQjoPUFKrlKHIxgTHa2XcLhK1op(4EReifLqLWWDdMfJ6HYPnFjap4g)xREoLqLWWDdMfJ6HYPnFjGOCofR9Birs6zmUutWL1HOCofRTGOYP1PLiicFp5taRSmFj6sJESbzoTz0MVyI4taRSmgpgNekpvqxEywidfpcjCsjnkyw)qNvnvaxiynX(XZbHcfsnXXA)8PXL84)A1ZPe5XhtDRdgkGOCofJePBTuJLjsOCR(t1TlSRs5cvCJ)RvpNsOsy4UbZIr9q50MVequoNIrgjsspJXLAcUSoeLZPyTD(Stlr4BdA(AVVGm03KYqOV5Xh9Dy((LVNKU9nz(AVVhqKawMVpbegZJJPc89uD68LZ1OrFzOztf4l4HVNKUjM50MrB(IjIpbSYYy0KhnyCsO8ubD5HzHmu8I)RvpNsKhFm1ToyOaIY5umUKNrBiGDSq5bzTZJpUz0gcyhluEqwB8UHleSMy)45GqHcPM4yTFMF0K8mAdbSJfkpiJUCAKXLqcNusJIuPyDikNtrIugTHa2XcLhK1(nCHG1e7hphekui1ehRDIKFK50MrB(IjIpbSYYy0KhnsPxEQ0MV66rwkKHIhHeoPKgfmRFOZQMkG7TShulnLsOXu1LA1r6KYhAKl5X)1QNtjYJpM6whmuar5Ckgjs3APgltKq5w9NQBxyxLYfQ4g)xREoLqLWWDdMfJ6HYPnFjGOCofJmUqWcf2iJD77ez7sGuuciynXE8HqWdB(sar5CkgjsspJXLAcUSoeLZPyTX3zN2mAZxmr8jGvwgJM8Ork9YtL28vxpYsHmu8iKWjL0OGz9dDw1ubCzpOwAkLqJPQl1QJ0jLp0ixYvVjaRRx3QlPNGlRREtar5Ckw7NptI0TwQXYeG11RB1L0tWLXn(Vw9CkHkHH7gmlg1dLtB(sar5CkgzoTz0MVyI4taRSmgn5rJu6LNkT5RUEKLczO4riHtkPrbZ6h6SQPc4YEqT0ukryKWuS()NyupvaxYvOeifLGczgcNkOZ5blLGzzmC78isU3cblK6HbOiLE5PsB(I1PGyDIBrIeeSqQhgGIu6LNkT5lwNcI1jUf34)A1ZPe5XhtDRdgkGOCofJmN2mAZxmr8jGvwgJM8Ork9YtL28vxpYsHmu8iKWjL0OivkwhIY5uCHGfkSrg723jY2LaPOeqWAI94dHGh28LaIY5umN2mAZxmr8jGvwgJM8Ob7kJH1y3UWoyX5H2vRqgkEes4KsAuWS(HoRAQaUKh)xREoLip(yQBDWqbeLZPyTFMFKiDRLASmrcLB1FQUDHDvkxOIB8FT65ucvcd3nywmQhkN28LaIY5umYirs6zmUutWL1HOCofRTZ340MrB(IjIpbSYYy0KhnyxzmSg72f2blop0UAfYqXJqcNusJIuPyDikNtXLCfM2vplvxHXSLWMy4PcircMJQJeWYePsXequoNI1gVZejzoTz0MVyI4taRSmgn5rdknYUIWKYczO4XEqT0ukXbiZa1yhHGh28fjsShulnLsq41PnASZEnbSmU3kbsrji860gn2zVMaww)cuoRFucWJqMYqie8W6JSmQM0qENdzkdHqWdRhOFPuZ7CitziecEy9HIh7b1stPeeEDAJg7SxtalZP1PLiicFBMkqJ(ExcdqZPnJ28fteGfcNipfM2vp(JoKHI3Tes4KsAuC8VEQGoeSMy)45GqUKlbsrjyGkfwD1)YciMrJejiynX(XZbHcfsnXXAJ35qrtYHGfs9Wauat5JSSUbZIrHqSIiDju0uHPD1dxtWLjGGfs9WauC1IziCs6sOiJmsKoqteKWGVLgfz0gcixiyHTXluKirnbxwhIY5uS2oZpU3QqjqkkbfYmeovqNZdwkb4HtBgT5lMialeorAYJgz1QRkvidfpYTuJLjui1OrbwPKgvKifFcyLLjQj4Y6ujsIeeSqQhgGIJlmHV8xiJmUKt(Tes4KsAuC8VEQGoeSqgjsXNawzzIAcUSovICTuJLjui1OrUXVuGJj4m2fcNkOhaFWsrgjsspJXLAcUSoeLZPyTDdzoTz0MVyIaSq4ePjpAW5blvNDGLcHHmu8iKWjL0OqbkF058GLIXvHsGuuckKziCQGoNhSucMLXWTZ7m34)A1ZPe5XhtDRdgkGOCofRJ05aJgQA)8nNqYHGfs9WauOWuPhKz94pA6Yz(rg3BjKWjL0O44F9ubDiyHmN2mAZxmrawiCI0Khn48GLQZoWsHWqgkEkucKIsqHmdHtf058GLsWSmgU9qX9wcjCsjnko(xpvqhcwiJejfkbsrjOqMHWPc6CEWsjap4snbxwhIY5uS2ixHsGuuckKziCQGoNhSucMLXW0LGOImN2mAZxmrawiCI0KhnuyAx94p6qgkEqWAI9JNdcfkKAIJ1gp(4hnjhcwi1ddqbmLpYY6gmlgfcXkI0fIKMkmTRE4AcUmbeSqQhgGIRwmdHtsxisY4ElHeoPKgfh)RNkOdbRj2pEoi0PnJ28fteGfcNin5rdkKziCQGoZGtymKHINcLaPOeuiZq4ubDopyPemlJHBJi5ElHeoPKgfh)RNkOdblK50MrB(IjcWcHtKM8OHct7Qh)rhYqX7wcjCsjnko(xpvqhcwtSF8CqOtBgT5lMialeorAYJgCEWs1zhyPqyidfpfkbsrjOqMHWPc6CEWsjywgd3oVZCHGf2gFCVLqcNusJIJ)1tf0HGfY4g)xREoLip(yQBDWqbeLZPyDKohy0qv734060seeHVNcyHWj6lr)pL(E6GZdhRLtBgT5lMialeoXE(ipo5yHWWiV4)A1ZPeShu3HyEGqbeLZPyHmu8SuJLjypOUdX8aHCTegGMWgzSBF)iA9qDtB3WLAcUSoeLZPyTFd34)A1ZPeShu3HyEGqbeLZPyTrEqurx4NGUEdzCZOneWowO8GS24fkN2mAZxmrawiCI98rAYJgkmTRE8hDidfpYVLqcNusJIJ)1tf0HG1e7hphesIKeifLGbQuy1v)llGygnY4sUeifLqLWWDdMfJ6HYPnFjap4cblK6HbOqHPspiZ6XF0CZOneWowO8GS24fksKYOneWowO8GmE8rMtBgT5lMialeoXE(in5rd8yuO8edzO4jbsrjyGkfwD1)YciMrJePBjKWjL0O44F9ubDiynX(XZbHoTeHVNAkFTegGMVXwr9ub(omFvdlL0OkeFzCglE5Rugd7R9(AxOVSPc04j0syaA(gGfcNOV6Hz(ofZWujCAZOnFXebyHWj2ZhPjpAabREgT5RUEywivkJ8cWcHtmeMbNOX7CidfVyROg7yHYdY4D2PnJ28fteGfcNypFKM8ObNhSuD2bwkegsSvuJDlHbOX4DoKHIh5X)1QNtjYJpM6whmuar5Ckw73WvHsGuuckKziCQGoNhSucWdsKuOeifLGczgcNkOZ5blLGzzmC7HImUKtnbxwhIY5uS2I)RvpNsOW0U6zP6kmMTequoNIrZZ8JejQj4Y6quoNI1E8FT65uI84JPU1bdfquoNIrMtBgT5lMialeoXE(in5rdkKziCQGoZGtymKyROg7wcdqJX7CidfpfkbsrjOqMHWPc6CEWsjywgd3gVqXn(Vw9CkrE8Xu36GHcikNtXA7gsKuOeifLGczgcNkOZ5blLGzzmCBNDAZOnFXebyHWj2ZhPjpAqHmdHtf0zgCcJHeBf1y3syaAmENdzO4f)xREoLip(yQBDWqbeLZPyTFdxfkbsrjOqMHWPc6CEWsjywgd32zNwIW37UgMVdZxKIcJ2qa1T8LA0Ae6lNRjE5lBKz(s3NUgFle0GPoeFLanFzxpOw57bejGL5B6llIvcN3xoxie91UqFtL6lFVsMV1Bxtf4R9(cX4llJLs40MrB(IjcWcHtSNpstE0GczgcNkOZm4egdzO4LrBiGD1BckKziCQGoNhSuTZl2kQXowO8GmUkucKIsqHmdHtf058GLsWSmgUnI0P1PLi89uLXj1mN2mAZxmbmJtQz8symlSBpeILfYqXdcwtSF8CqOqHutCS2pTB4s(bAIGeg8T0OiJ2qajr6wl1yzcgOS8x9Geg8T0OaRusJkY4cbluOqQjow78UXPnJ28ftaZ4KAgn5rdj9)QofiSvidfpcjCsjnkKZtWd7X)1QNtX6z0gcijshOjcsyW3sJImAdbK7bAIGeg8T0OaIY5uS24jbsrjK0)R6uGWwcfimT5lsKKEgJl1eCzDikNtXAJNeifLqs)VQtbcBjuGW0MVCAZOnFXeWmoPMrtE0qcHmegEQGqgkEes4KsAuiNNGh2J)RvpNI1ZOneqsKoqteKWGVLgfz0gci3d0ebjm4BPrbeLZPyTXtcKIsiHqgcdpvGqbctB(IejPNX4snbxwhIY5uS24jbsrjKqidHHNkqOaHPnF50MrB(IjGzCsnJM8OHEcUmw)eaQcKXYczO4jbsrjaRRx3QZmiwb2La8WPLi8LOxrKzWu77jtT23yw(AWjiaH(sK(E8gw2KAFLaPOyH4lMXlF1jZMkW3Z34ldJFPycFpfTrpNyu57vcv(gFfQ81gz03K5B6RbNGae6R9(ggXdFhZxiMQusJcN2mAZxmbmJtQz0KhnYkImdM6Em16qgkEes4KsAuiNNGh2J)RvpNI1ZOneqsKoqteKWGVLgfz0gci3d0ebjm4BPrbeLZPyTX78nKij9mgxQj4Y6quoNI1gVZ340MrB(IjGzCsnJM8OrcJzH9dqnddzO4LrBiGDSq5bzTZJpsKihcwOqHutCS25DdxiynX(XZbHcfsnXXAN3PXpYCAZOnFXeWmoPMrtE0GAGOK(FvidfpcjCsjnkKZtWd7X)1QNtX6z0gcijshOjcsyW3sJImAdbK7bAIGeg8T0OaIY5uS24jbsrjOgikP)xjuGW0MVirs6zmUutWL1HOCofRnEsGuucQbIs6)vcfimT5lN2mAZxmbmJtQz0KhnKYG(t1n4edZczO4LrBiGDSq5bz8oZLCjqkkbyD96wDMbXkWUeGhKij9mgxQj4Y6quoNI12nK5060seeHV3bNkmAmN2mAZxmHbNkmAmEGmSpgkhsLYiVPyriOLsASZ)GzzGYDfsyIyidfpYJ)RvpNsawxVUvxspbxMaIY5uS25JFKif)xREoLqLWWDdMfJ6HYPnFjGOCofRJ05aJgQANp(rgxYZOneWowO8GS25XhjshOjsOCREW1dQfz0gcijshOjYJp2dUEqTiJ2qa5sULASmbyD96w9KXsqTrIKct7QhUMGltOgwkPXE(MImsKoqteKWGVLgfz0gcizKij9mgxQj4Y6quoNI1gFNjrsHPD1dxtWLjudlL0yF4FvhPdgbnKh)4AjmanHnYy3((r068XV2UXPnJ28ftyWPcJgJM8Obid7JHYHuPmYlijG6(t1TlStnqM1tO0yi0PnJ28ftyWPcJgJM8Obid7JHYHuPmYJftiR)uDkyAiSsDNzWHcDAZOnFXegCQWOXOjpAaYW(yOCivkJ8SlStnqM1ztWOdzO4riHtkPrHCEcEyp(Vw9CkwpJ2qa5sUnYy7HIFKiDlY)GZXbQetXIqqlL0yN)bZYaL7kKWerYCAZOnFXegCQWOXOjpAaYW(yOCivkJ8EciKZfQLNkOF8CqypcBXSuhYqXJqcNusJc58e8WE8FT65uSEgTHaYLCBKX2df)ir6wK)bNJdujMIfHGwkPXo)dMLbk3viHjICVf5FW54avc7c7udKzD2emAYCAjcFV7c91GtfgnF5m2LV2f671eCHmZxKzJCAOYxcPgedXxoJw7Re6lidv(snqM5BwkFpYbIkF5m2LVe9JpM6whm0xYhkFLaPO8Dy(E(gFzy8lfZ3h6RgzmY89H(sF9eCz0GUVZxYhkFdGyAi0x7klFpFJVmm(LIrMtBgT5lMWGtfgngn5rddovy0ohYqX7wcjCsjnkyhyCOgu1n4uHrJl5KBWPcJM4SqcKIQRaHPnF1gVZ3Wn(Vw9CkrE8Xu36GHcikNtXANp(rIKbNkmAIZcjqkQUceM28v7NVHl5X)1QNtjaRRx3QlPNGltar5Ckw78XpsKI)RvpNsOsy4UbZIr9q50MVequoNI1r6CGrdvTZh)iJePmAdbSJfkpiRDE8XvcKIsOsy4UbZIr9q50MVeGhKXL8Bn4uHrtWN4kz94)A1ZPirYGtfgnbFI4)A1ZPequoNIrIeHeoPKgfgCQWO1pGZdhRfVZKrgjsspJX1GtfgnXzHeifvxbctB(QDEutWL1HOCofZPnJ28ftyWPcJgJM8OHbNkmA8fYqX7wcjCsjnkyhyCOgu1n4uHrJl5KBWPcJMGpHeifvxbctB(QnENVHB8FT65uI84JPU1bdfquoNI1oF8Jejdovy0e8jKaPO6kqyAZxTF(gUKh)xREoLaSUEDRUKEcUmbeLZPyTZh)irk(Vw9CkHkHH7gmlg1dLtB(sar5CkwhPZbgnu1oF8JmsKYOneWowO8GS25XhxjqkkHkHH7gmlg1dLtB(saEqgxYV1GtfgnXzXvY6X)1QNtrIKbNkmAIZI4)A1ZPequoNIrIeHeoPKgfgCQWO1pGZdhRfp(iJmsKKEgJRbNkmAc(esGuuDfimT5R25rnbxwhIY5umNwIW3tnLVFPB57xOVF5lid91GtfgnFpGpHrHmFtFLaPOcXxqg6RDH((2fc99lFJ)RvpNs47jc67q5BHJDHqFn4uHrZ3d4tyuiZ30xjqkQq8fKH(k92LVF5B8FT65ucN2mAZxmHbNkmAmAYJgGmSpgkhct)gpdovy0ohYqX7wcjCsjnkyhyCOgu1n4uHrJ7TgCQWOjolUswhKHDjqkkUKBWPcJMGpr8FT65ucikNtXir6wdovy0e8jUswhKHDjqkkYCAZOnFXegCQWOXOjpAaYW(yOCim9B8m4uHrJVqgkE3siHtkPrb7aJd1GQUbNkmACV1GtfgnbFIRK1bzyxcKIIl5gCQWOjolI)RvpNsar5Ckgjs3AWPcJM4S4kzDqg2LaPOidWamaaa]] )

end
