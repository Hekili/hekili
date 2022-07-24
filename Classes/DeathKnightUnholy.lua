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
    end, false )


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

            debuff = "festering_wound",

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


    spec:RegisterPack( "Unholy", 20220723, [[Hekili:T3ZAZnUT1(BXtMOvA9gztjlND3RKUt6UPTjn3KDItA6NmnLiLe7srQYh2Xz8OF73ZbpibabaHK8MMot)qB8kccCWbN3paV172F62BcdkJU97hD5Orx(LJgpC0yV3m(6BVP8XDr3EZUGLFmyn8hPbBH))FoDtwYJ4p)yswqi(6fzv5lHhTPSCxXBV4I1XLBQwmCz22lkI3wLeugNLUmpyvj(VxEXT3SOkoP8BsVDH21E0yyo3fTe(5jJGPnommIo2OIL3EZ7Jck3S)U)wA86nL7VJcq7)2VTc()VB04xb)FWST)B3)TVBtq66OI3U)B)I939vH)ZQIYTrPLf7VRmB)DVp99x8(OvXjrxqMs4NFFve9zzP4KTmRkfwHYG81r4B9Wg4rb5WyI(va(kJcPJoj(E43sYsxdpjnRA9g6VVnOSmkF)D9dYI8lIkR2T)UpZBWqc88(4IGfj4uCtWY84vXlJds2F3hcwcl5IOLbvfWKggfaJy9MSQKcCc)i8BRYG5Sa)93)3kOt2pxeJl(VaamoH7IsdXfoyrCsCzCe(QziCVkj6xJxG7T(bWYC15WevchWWaItlkjlw2Q93n58b)pW0)HB2FxAuvzoczb4uVnaE3D5r3hHyMISTWKMM9f5rlH)vCzf5SwgO(ZrWeNt(ZBkZJXDqCkCE8dFn8hWA9yw1(72eCpzMk3qgyusb7KimJTYpKL(cyjZUpkFzWo8Fd7veUlKbu6Atp6jaCkaXVyfsS4NhTna2NVapAtdJryniHroeSBhIxqqBrwb8JKxPGtl0pjc)X39EyLdGne(7WlMhuSHDG(vazAicSWMar()qv5I8OGpI0eL5psxfGky)DiDqrzoqVGJ7R3fhgTnEjdR9Jrjb)kGQ(P93Dp8tu8us26ycgoDjI(G5ipkHCUIqbSzwfSaz0qaipio0NCaXMXF6hE)p8293bNeaTfs7ahdrPRrMOD5zljN9iSbhoPFeHpYQn82BsIlklqo8A6x4F89ergrPeI3B)t3Edq8INVbi)jWg5)rcJ5WvKdOOq)A2NzaK(4YKi)Ouy)Ia)tprOWT9sZH3AcDKNHSIjW(A4IQ8IsGqXVaOQlgYag6OydjKWz38OE0Z8Q4YHpeJhq4RVohxo53Vb9nmimeM8FfXcKjq9rmYP93nfaspp67tjE6XOF8vgdGlxIKDW)n9r)W0WBlbXCgXOWw((a4VGNmCxwwcc05vPXl93L9as8aRtFynRwTAyyq(h9bcY0cqaXwcJ4qKsdb8Q0i4hxhneLNGeoL(lZItKqpiGDVWHdcWJP7j1hbpz0(7g0SzOhI4uI7NXh7(PzcJymf40DLY0XhZkUGf)cICfzsrcoPziecRHeHD1Bncnrwsy2dPdd2LTmi5XDfrchRWOGjLqZYiirYFaKM88dsa1H(166JyTWd8HLXBH5kZ)kYS3xyZspUaXQ(HGIMhB2X9e5YuzHqkbHPG8qX306RbCnbWdjS5(RcIKX(eaQWpSsyghOhD8LgqheSPFbv1h1wH84D0N9lBIs56XbPOpeSRGPipKPfgSAau9G64JtaDDj44ikMitiLdQ4IADoI6kFiiUKO0IOxw1QIxqnRyO4PtFcwgeOIVxXqYU0zHHkIqhqqK2PTMZP2LilgtilAyaOYJ44Favxsf8te2AxWVorhtAoAwMe8aHoDtaSuf2f5PrwZ1S9yN4MXwxtZIL6qTcviB3A3ubDhprhtoff0DzboyJqz3jnehwrptSnAK2kr2sOYkQqdY9dZY2cule7vzQNTRRAWFqvxPkmxsmkh8jI1wIwErLL6D5(7oVtK9l5NUDFUmLtN3jEKyLb5G4HG8T4J3cMOaip9Qpv1F092B0exa45edZ6gG1dvQIXLSrOJvU71KIKuTaR2sYJYgpjrAIBLxtmrwVAOMDimW38SAxeiEopaDASqNW5AZmbVLsr595Gn)Lk6f)r273fnbCuF9eo37UOYHRHJIShbGLYQPAFEr12TzP(1JQMVDqJAOMjNOSWQoHACZ2G)zwUpxNvHV4YRfU6P87sMJtyIwKKLf6VQk)XHHv5e5qDBiVP3SbV38q7QE6CRX2baN(J(K4am85ythLxeL)rGmtztBCV2(fe2R1p0UceYmvrIxdAZkXhujXwjexU9)NvHRXa1yZs7aWt4c0FFFWS9ef66VI)qWH9a0EoGhG4F7AIh3GbX7YkHfGeXfeQka7)anzGhXjbfuR58MGMOH(mIEH)ZLXjX)gscVjipenBI4SpAlfOVbTMuy(rNP)yu0oUN6bHKt4d6y)4oC9M0nTR3e7Afu1EoNQ(eN2(A5D580AKBGgVDPKQxM8ODvjfr21d8jcfrnuoopIWHEO88TFrbhY4pRwPGt4x8irYYO2CiDaCKZabC8IG1(zRaJRIx(rMH8RHLd(N2nJVtLQcaPbJa1BsbsbrTxQVO1D5bB3bofYScmc2Ulf0v8sY2s1gRM3EZJeNDc4JCqTz0MikW3vYqX2is0SoQ5fgCPIFyW00relJ46nr(HbBtJc1zUo7eDbr(M0ayGe3bnrN0LFPAGeqiRxgkyA5uRrXWNhQAtw)AwRB)d2LEgfa7aA3MOG8mWqarFyQDcOVrJ44UoDkrYBGflafLg1eeoZQO7mWnxXak7HsIFQnYsiCSQ(SgxfwTDNppwe9607)AbmUqMqm2dvJ8fkmRMCfBGn7XJkS4PPz)UCmCgDq)yHdwRq0(DHjFj7qCG15Vbk7KUqgR3fNVaHp8FVhMmeXwl9boF4Nkwq6M177izUdN06iRT6VNB((il3YScwxzhQL9oQlQPd5u0BKzSpOiMl2uRtBA41b(TDjbPPeBsnANfSSx3sbIo5qY(P1H2RMWZQjwnnXPTtRtet7Huml0P)r)aLTV)gm8SOv2KCKgSQKKSty7sthiAnhMOo0UCCu15RKL8WDeK5p(bmJUXyOxzHILMzU39(xi5rSv8jfLBWK5E6JsLndMRdSKMz9LKierL3wtFGbPGHS1h8R5DTGxrmq3nNuvPgXWydUKUig4Vsabq(lEe4gaZ6uuy)VhYYEkr8(kY(LiCGImwMLNxTt(96IwEe)4PEJ)XO7rPazz)wek0qYc2rVw2EJfzannvUDs82foQWxfT7kopmtX2tF8xQ3oZBYA5zoyRQJ4D77wZk97E3Aer3ZbL3ipzTgSgZAeGXc)vGli)2Jk5d2TH2LbGDGwmRwwpN(rqABhaCWpC1ZLUyQzcZ(0WB3fBQqSAl2aeayEeHLSk9HS8YnpA3ccJ4860a1K70sWjBcgrxGLLd8YvsKbMalZrjUMryxvrzfMfq(rSefB9WUpdR9kyCfzjeysetFgJCrDq(BQ2gKMfhsImxCkS24Q4hVsaauFjPbUDBuymwwx3iO3FvsuXgsrGjo21jzlcsWbsmocuuVmB7IGM0nYF9Dz0)BdEHB6aFeaQVGAfSYOglokrWqAuMkYaj6vYKlz5Axb8MIOB7RSWE1h5HV9MRSgTZtgkCbegRtsugqfa2hHh)nRjRuHgw6nCtqHpygMpsmX5reECddDDG2(Cqq8esCVOHguY0UV((GKkG4PGhsvCIkAem8kmN93htI(6IhXzA4(7(jAQ7r79wUjRat2p(3uvzyPIL)rMzHxvhvxK8pVOKLqDmaWlQkXW7smAmJx5yldbtlJwTcmWNzn5As4KceKv9RcBoe4kWcbiMwJaa09nRWabJfcaU3IyRrAggAyu8aPu9YJkRYH337v8QFJ)lxoCYqIijFAfyYWj(E(fpMUSHgHl0c)lyz8Xz52BG3M9duUSwc6foF1ntQR6i2QQHwyKDAHrUqlyf0vfyRL08mjYVwqKrOLeXj7BLo3nxOog8T9BE(8)x848spEWkFjnvYdPX5uz1PRC9OQ1jjFsWNQ5TGqT8ExOoMJdc9Ccc9eGqv28cqKJg2CghYcs13UDxqor1ki2RHDJw1nKFI9EQYeipRzpvpCk8IU9SlpdhpMzN)kl7nf1ff52SW4vX8e5uZUVbeCI)4U84mGAJxqN1VgFt8kQWNhIWepXM8MPKuKqyzV2ST5fDe(e6FLMHLPeb3HH4SzVxOvsahI6swGxn70iDgAWyNmol11jtN2W5yqQmj4Fzfjz1e)YrpYj4mYj4)QcuHrW94H6xvB0j61(pwlNwehTQkjXheIJByVlp4DSu8pXsuBzuEjiZU8XwHXV7CAicxHl9Zl5HeID46yiHEEZh2OR70y6rx3YqmRjoWfJ4fcAgScVMlIn6FvfVBhqqTo4(OeozZQyqtTFq(I4swAOQxIYhIb9SH15m2F81F5BMmwkY7VU2jeNMECSonqTil3HmqG64lfYisxX)Tgpz3tDNCNVErbYF)fzPvfGJmr5JET)v7wYweSABQDWC3sydmHhhy2AO)L1K4L5ycaL3RCZrJwMNLKLR6cTIlQsybVAYfhDoxYRiJrryq9(YXPTNCaWmoX6ZeLd7vgfcdQ0HZgyXhbRH0Zc7(4l5zz0(KBoWvQXGSoK7MjQMO75HXrClBWaxHyAasd2fLlHJKZPNWOS5sL4WeTMTdi0COEpEyNtnRlyXSmvBKn1CaM73rHwkhCla0sjwKfIfv6waBLRrAXzDe)dDjfMA93Huz7sYSumt4VcmnW28prEgZ0aC3G2I1uXomBZeSGQXwbW(SFatBmiEg)BskeOJ59aMcCMugv9mekmzDDFjhv5Y4zjJTTocRXhJNTzIEDB0adCm0FTYYGnRf8mDs6wm30GB7io2UPXRbQ0GnSh4TJcp49M2v8IPKOdoq9gxaXwwW6GmxxdlEF5uGYnCMUp18ZUz0YCAP)irX7MzHS3SNdNToraOBI2bynjXCI6tR5ljyEBT9MBiyB0kxBCDnLFuHHzHkOr9KRqPzr86fI7z2gd9fdgnq496M0bhPsxA5gLd5ff00lhwucqFejDRZ6JyeNNGuVUWXJM611Q04EUNqfxgNJiU6X7qwvg3s0Eqrrqvcr2UNjtTug6Za56Zb2wwKKPoIJRk1GjmEMtC3zmVUfGQB1LTcX6Z0pilsxuaaZAeCRwJTKnZm2oAYg0sZnGW7iksSl7DB7i3ezklTg2sRMkEfVD5WVS2ggT24ApCc9DSDpiN2AQl1bozoCpx0tBAdqbanQGpU2K10oHPNZTYLYwl0kzsnMFcEVrI04ebEycveAoYcWczS84xqy)iDlogpoSd)tI(c(BZOIXBebmZkXSuGiq2xL6t)B)esz9Gfi2sKpsk(rYT4iAjdTz0zXoJxmZw8UtPnCKiM6u25eBsG4IoCP6)QP8S49VrjpN3iTVntO19Wb6U1j00YZCTpQN4csB6Et9aTPM(1gO31XS1t5oHivhzmdrs8A0mvI)pASQb5fygkxfNKGIXEytmYLveVTq(wTGNEYcuBsOqjTHzUyjah5Xz4RhHn1mH1eCvbt(blxJS7vJssshxMTDlWymuJMy0VkfCXEDTDSlyUROQ2al)iQ9vtP)2yGMFvEu0VfDRCU4vvf0Dy6fJCmC(UmVQeFUpjFbvBbwR7JxgPeA3Mi6weVoor5PyTcc4ZesniseT6Vm)ry3LOZDCZlkk7o8rfZnuwAzxzRhLzqqGxN(o9Fg3xoGjvOQ)q9fcdycoMORqXC6TiIq7vvG)mnslbvLzOUxIQcsTd3KzK65WNnf60v2njrJbkkvfHIyPE7DP8j67G3LFA9NXrVChiIk1zFGgRb6gz2HrKkvs9HBtPtbj1uagBob12Qi16zLVWkMQubDJmG4Ik0zNr3Omngdw3MxN1UsX4TGmjQSkpdd2epqGsCknEOQt)(HdJnUFD4aPqpu33sHWnV2wG2ubmNqL2JcrCtNHaDVh77e)9zMtDA3csKzm7O5N7l3LFmNIpW(k7y95TNLNR5iYM75gYcG0HN(mvRZ8PUphpO4L3tjjJsclmc71yNMBJgPUFPg9UnipheMg6VoABrzwkII2GDK8wIK5DcdTCtoyBNFru0hbHAspIKoruphqUGxhyfXLpkpc1Y7w6Hl3eKv4ViinQD4muiUuu5jDgj0mz6cco)8iJDBMPO5))dMxSEii4V)ECEvcXoGpKeSgRJh0q3GMsMrYZcqE)9SxafJTMC3)a4KIn4IZ5k7uRRrXuAJxE7TZHbrDjXS74u35gYTGQ3NsOFrBq6CQU027ezlg1TtgBlBDTIaEBCjAlNpM24Rn4AHcqriivbKNfSCxyWEYsHzzvIY9NH1yMAbR9n0IidDVIEdqYHTTXf075W)(hWk)IDlcc8a9joSHL5j9UxSCdEjeKrUb)2Ho7DDD6khmuBO(LIKolYufvW7I3TbXPQuneF3aXiGKoGzixM2L49nma69sHoQ7bAor1fFFdHyr(IfHoXi(r4U1elbwAn4HxfNOJbRiyMq2qcRii2qL2V6GfI3V9JzuugcqjP(ghiQ)uZ9rwtKG1LaH)9fHwd1DWZByAjXGtxm(LVN1cI55Kx8YpJDHOrR7XVNM4()mEosQVsYvYwDvusPpOHzmOiyNkMT9jJze7XCRZXpLTHdun0wfcfD04uGUwoS0jKPAES8TIcbq2F33rnuNCRQ(d7WyPc)R(S)6IBa3)XIwSaRFEqAZUSCILvOtiKyknuqqbE3RihqxHW0YJaabYmfVmRZqtZYItHjttSof8RijmSsMmgOdyGz9kzkCO8m10ZqDhS3P7fU6jSERlyM6GnbwF7Ui50Yq4vx5E2somhB2kg)ciZMlswez6(LayNoEiLjbxHe6nBicjMtfJziXwTq1Rv5u0QYr6MMy(Pstm)tfnb3xD3q1I52er2hwDd6iBAtoHkfK8y5IrZwWn1NUOpvv4IX6)t4MxQJRamnXcONMGwY9huIaiu861HLYp4SQmS2KiTrgP7QfyKNLfi(FbUS9RrlRWRsBA7)O3whednLC37rpOTCUPj1bmIdJfXDd9GLXOj(ZSaWTmiVaFNv5bWatdsiz9zvuZ0AEiAcel)LuIGVw1mwUV4WZDYft2CP6h2H46t4PzAVvGbljB1Ckf(9eY7jp0wzbPENzbCTKLuMmfVwj0lAVyJ8q6ei83iTle6LteRvNczD30R4D5ZIiEsriWjZISDbX5njkrSfx6JMptTpgJRINy5UIMCJ3q9dO)jT8yV49)e7Twdw(xs6OjItOcV6GBLlzLMYFsnnm8dO(7T0)y8lHUEDNMDUqtlnJMCW8(0lg2EmpTgzvXsKwPr(4GJY2vOdcLIK89QTrxtdNrZHWG2cFTGdNPiAwxu0pbkGw944Pqb0UHj)pDkapBuaEhffWi7uaTXHTOauLPnsxe5Bl3RijRu8FFiunTXjU0NWsyL2mwntHUO1r)UDKHzMerdK68VgK4nakj804CW7eaISB2xWd63wdgSa(kZ6CZ0Oy6Z7E2wKHcXLMhBbzV(84OXTD0d2MO4SD8mq5KF0TS(weuJwGGn9R3Ze8Z2Zdb5yQaasSF5R(XV)B(()c57ocrhz8wmscSOd9IAhbFbwqkGoBIop63tgwXbG)Ws6xWNH7)2Vlgpi9G57DzPWktE8lyM3(pEbnws1)BUfUWV3F0VoW47ZBv16jO(heNbpHzyKYm0ez265q4NmnlxF07J9FRdywIJThgMD8rarJf2rxDI4Lo3xmQVIdBBDmemwpOyCjEctrdJZ)qfRy61hP51P)Me56xE4RUlVULvxe4F9HV6Eo86oU3FZHV6U86wwDhjezrA4tpDOnbxhk7LEHxUafp)c)uNLdxi8PkSHoltog4a)SP91)W35o5sDmS)0tWiU5og552E)6UCUEgA(fteTQhthkmO((Ucd2oKDNuzKLz5yGKwsJpqSHQenxHbhTBO(YG6WOtp1Zyvm7H((kAyVjE77in(Bj(r07Z)C6S8Dv07GLQKkmwj7IaFJWnD)pFWPRV3Ig3tfAocf4JmRbwbAeagYLwfXzrbO5Ib2NoxWnx5WRBzZmXMc9dKqr99pkP9mzZxEScvEUNp3vcXc26HXCFm2lm6zXEbBZYHj47uvdy1KwhWh2ObpoOOf5IlGXy3iueYv3HrQCQ2RC8KkoYcWAdLdBxDmwrzZRyxEFREW5W7p(zuOPkP2XOc5KjDL8d6uPZ8ovcn20CmNSs07hZgrsQ4XqBYTf8B2YlRhmp(0Wps7AtK2)2BawInz53EZn1F)UFh9otDxEgwcb3EZN9zSA8Q9xIB8rA(ACJ)CZxKB8F9hTVk3my657lZnBc)J3xNBza73)Vq3S1)37Vs31eDN(xQB2u9m)16MnRh5xSBKlJYlxmS2DUZNDb9o7t)ZAUic0)8Mlmz9px9Ib7vYxQWZU6vXRMDgtwKsRX07mnfF0rTkJTTk6weap)FVPH1DtdRh)ZZa1RWkOygdxXUFxFv2UzKBH3xrw0zEVQ5ohDgmLVQMlEwJhJIPyQx)MFVjXTS95N)5xnz2LdoeWA0XcwJmawAURFRblKq6)Ex2U)OUlBpKdvoKQESos8y1t4q9mdeB6pSF6jtebwPceEOuw3N))IxIYdg8Y(EdNCU8uJdeEqRK8tjBhmyEFR8dcp0HL0Z6s6Xwsv5HN6fWRlhS8lsm25it2D7(ESxhxNWUSwKlBx2cLlEjViDJ(2R5r6UfF52W(10Qwe4pXUSbzDivSg9sxGQUM02B3heNqW21q4mHR8ack)K7B(6PU1wUvPcW2(9DOw6E6jtvrNWtmxfDd61VMS18ImKCVi80t1d1WDIGWi6((qyWtp1)eHDhWpu6G)odFB5qqt)3ZogQ3tgAQ4Pt6zWAM(SFxQiO6zV2OM6nU3bvsuWl80tNPBLg40UfSYrITwO7JiCzth1tBBnbBBjFaM33W1cW5tgGegQg2XrA0cDxyplvz8trqOPX)TWe10G9S9JCTHnZRx)Z039Pp9u7U4FU3elOpHoeq7InF2Ody1O)EV(gAe)5tE6jzmT3LdSaC6RzxUmftM3RPWX71fLFdDNYaaXkITSztJZd6UnQ8qBXX)0twkKVEgFMaQR9jJHwbXckvOXRvfkyPf3bAiu8AlcFdRFp12zKeqHPxXqbD1i7SHP2e7SF2qdSZEA7MxN9aPgxxq8U(MwF6eQ5jhwNMlI25DZk6Jyh94DpTY86zGRt7Ii160GfPoSO64Z1bh1e6YqxF7c)N33BYNlVeNBPbXh0M6EmZcXpX9aTw0jRLYNDnIizaMgOFQmmFaOu7iVEIICu7s8bMOYY11U296BPbTF6jBnNnf9FInvTiWk172ieFasu6BV3QN2F9YWxc(GmGlMTvdKnfgHeUdBn2xb0bcMf1wLpcMAmNWKDeTBl65t6zB(Pao2e0d6PQMNG))e0DZ2rcTXCgoQS8giUwZ2X(YkASu3lPKPv6xoa79S19XIaVAlbkfZGIUhzDXz19qznsm12)MbxWaybXtnghEMXERZG190Lc)x(zemYB5IvER6fly7FqzUERAqtFlfAWRFueAjmNIxYOv7egH4FwSmRcyMyRdrJML7(V5xD4VG6E55clBWuskAMHH7gXsJF(BL0c8wnwi(2g726MEQ2wAXHMl3gTmhd45Pc396AOyblam0mXt9USgxqzyfu8PWbddT1ipijoGNe8ZK2TgTlBws4YFfTHUPwq1wD(Xo)cf4G(j2eKdgqOd3lHh1I7N7oUF(PI7rV46M0JHd0XmXdY1xL917V7prsBrD81QpAMTmj4bc)XMaaqkAprtNnrZ7HauxV5SR7jXoVIiOadJf1IAWAu9ZCltAyisYZjljywub36fdZUcWawL1bSmO2MCL1H9Rk73U2BE63BYcU73sYn56HgCCUMavtGN4UpBWRxPWIkC3x3t9GDSQ)bZgnqpuZVaQzweR(PayAFVlp3k(4LJhyhHn96Ew3ZmlqL(uYJ9Q3rbUJM0XP3e7at3R6zwN)U2QsHZz6eJHeYqeHMAGJvIVYH9GDuGG0LBi5wqAcjA5MfK(OFyAi1SbBmRs3jXDYRoPjYsY8Q1SW1rnKMWHhiT5hoS154KDWy0zEEafywrHCqnXFxZ(UfFUvu5VBCZCy7aoK196QgvPnojwmsea1EwIp20XFIwwdNuUmVsrz(QPDAKMRwjCAMiqJLWVSblDb(92piGCxblOocx6)L0IDGKg3eCCKcbIikGE55wCrDn(iwFsOlLKWbr9vwPIUyUnpupITLA8(NbpcNUIHeCCN85ssfqfiw88yCpPdPXtBiXOcH4ynUKRpOukn1wXpJ6KGKj66dA(tpPlS46(aDoD2OR1kaz01SYPRLpena05AQAgIR8hsAGEDV(o8LWSHCRJV5LtFnid2HjuivDwwvzCIRWW5JVCqxHmf236dwO(uI1RVUppFgIm1vWSOB4Q5Jz0Lu4KZBZ)Mpkif0W3nYPEWXwJganFclF6jtF0kb7zpZ6R27mtVQQfiDcNWjbSAT3HdCNAwdVX4lphVM80ofcr9tBKeoGyjAjXKDV2AuwyAPLHr0b1ddy61xJkFTKRQJBIvtmaJHAQwI2F7iH11KJ06uyXsWWV7FCh1FujXDljrxiHWcYqSKUUPFPGAC7P1tuQKfHZyewTMatd0FM3usrZqN2gp9ZOML3mYY6NWXoR1GdAD7A)49MZ7BYa5x(gtsFAiX0j5WQvgZUsm4r8cF6PNA9tDPxcukiAvOdAWH3qFonnGYvhm(bsCGtOKUWa6oiUUZjwJKY2se7AP7myKYcQvIvSHWb4D1NGIUXkRllX4g5XS6hZOE9pIAHWIOR5ExAv0ggltx2(yil1ZM6g24KPqoout3X9volNsBHMIUN4nT6NjqQX9VVXrmAMDjvslORnbZUEkclKlrUnb3htRpZasPF)qwoPrbQYlQiEHfN(fRd2gnukPkYK8n95cHJxps8mNOuSDuFTQnIel14(Yqnka0Mx3xmcipwE6MjflpJScAyyN7DTvv2nce1wdQDV7mqftZ(5nO7ZOzlelscwr6ajeiOvUcMyuSPvcyg3u3dpSMPzh5G8h)a5legMRzMpXuZJE37FHoCfEWQITSGauTuepYBBtOwm7LNR8UV86b90Rpwzn0pHxD5a97hvxjmsa04LIszi9jMgqoEcxnNWYq3IlZYZR2joA9emJoVVjxSE5OxFQigZ4fRwOnhdLPElgCcV8Cb1kiemDoDO7VdhHT7SRfALJzljMZ2dHqXaZ9gypI6(aA0QuIy)hpkVviQYpvkF9eZtosqxk72gDK0CG3VYWXtt7SHlxnz1oqbBfg1qgIxiaj3NHnal8SISeCLyQbv)z)nvBdsZIXpqOVkofigXPYpE72OWyW1y0YK6FDDs2IGePFseAuNBUkYBIXV2QGtS0W2wVbz5ZD2HN(anjruNTUZgDPOlt66oIxoroxEnJEZJewZGxozWa9X(ehljUekepxIwURL92Er)Qvmfzrg3LhwySJE54btDXN9whai7FtUR6lfMEExyRl6hIsH2TjkipdCabJDD)(ApeDpLvdALwWb6G6wzZORSICL1CXG4Wr6wNwb3VE3jum0D4oNNTLwmEkFHrN8hOpvQIgCAbM7iHcgpXmskRiZ0QkTxIovyCUyLtLByi7mcU32vNez0bCqCas3o9ZrGmlN2NkgGq3WXE138b)Li2NgBsUV)GAzQpuOUKM9POCyLtUWXwjStfR(gbqU1XJEbxQ1LHQ2NFFQrfz4wmV2M0j2bXgV04zzt9tY3qDtGFULICtQe6KslQyHgjpFYSjAcUIDdjNys6nQX2Uul4W3qcKmeGLZrZwLPRDZED5DSlPY)uQmHj234tnEu4cGz7WW4zr96(z8l0G)G8bj3zmrSuVGOS)ukba7yHRicO3F3pYlVBoeWQ37zb5ldsrzPKwI2q0GNF9eAqevmT1yZSXnhKfWa(0iw2Kmaa2(02czvvUSpsNE5fqWlnZEDtMRVQLmnATGCuEruo6LMdGCpTFDBo8ns9AkSr0UhApqD7bI9qf11rqTccM9s8U6GuqHyrTHTTa9Y45DbyjZSmGC3ZeVMC5XCfWJKvcZd5YecNi82va0VaSxjbf0O5j8H5y4(7(zWjW4FdB)Hnb5H4nNa5AHG2V5b1x3e05h5K(yu0o(fotqibJRBJfWHuFS(GD4a6qok8MyOM30sAZ4U2vLOlXAZNn6PN6RWHOnIHZUwmKHnZ)Q48icj7Z8UKkrHp5UW40EWA5BcwtSYgK99rDvhTNCtWkqdQDPr39O2F(t5k9ed)sGOygExxexgTLA7qSX2Exw7)ZxckBvJcKJDlYeALPg1MINLBiLsftSZq0hjc9bXAKNHjs4By1Sl1z59OlfRQwochZHLek3Cno5WlB8dmLdVRYnKGd8iaMg2FZjvUJd3ucdCaimFzm88dp9oZ0TdXaM1qr7)p6VMtAX3S)0t2V5w3qi96B6ULbLEBnxWiBVH3L1W6p)sn01f(w8EeRijoik)Dzs8U)PgkyROqrAWgu9nr0mVbC5fM26ZKeKy7SzK7NnJoHZg1RPO)aE24z4SP9NUgBNnJAD2OU1vpByoX)h0VAq2LJIFFEM5kxUPlglDx0v1yAfwh(l1H8Dr4QtkCdlH2BhU2WL8Mza5lu0T))]] )

end
