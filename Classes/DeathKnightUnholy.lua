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


    spec:RegisterPack( "Unholy", 20220514, [[di11fdqivk9ivQ0LaIInHk9jevJcr5uaPvHubVcPOzjiUfQkPDr4xifggsvoMkYYqv1ZeKmnvu11uPyBQuHVHuHgNkk4COQewNGuVdvLinpHK7HQSpHu)dvLioiquTquv8qvuAIiv0fvrLSruvI6JQOcgPkvu5KQOsTsKsVufvOMjqKBQsfvTtGWpvrrgQkvKLQIk6Pc1uvPQRQsfLTQIkKVceLglsvTxa)vQgSshw0IjYJLYKj5YqBgjFwGrRsoTIvRIc9AHy2K62e1UL8BvnCv44OQulh0Zrz6uUocBhO(oQy8iv68cQ1RIIA(iY(PAGta3deRsdbab)0JF(P3nNoV4eDmuNNENhi2cFGaXhzlsgGaXvkJaX3z11RddeFKH1FQaUhiM9eWgceFz2bl00GgbJDrijAVmnyJmHoT5RgmPmAWg5gnaILigTDUlajGyvAiai4NE8Zp9U505fNOJHku8Zpqm7aBaGG)B4hi(AukSaKaIviRbetNyAx(EoUMGlZ37S661HDAVZNH9905dXx(Ph)87060E2RScqwODA5R(cYvNrcMjJLX81EFPZIoPbDIuJgPbDIPDX8LojqFT33V0H9T9eL5RLWa0y(Y569nHOViDpWMHkFT3x9ag9v)vGVy9ebx(AVVYPzi0xYYh7m0io89UNav40Yx9LohwkPrLVXzdoutBsTV3PSz(kHTKGH(QWu5BW1tOz(kNrqFPEOVSu5lDEoMjCA5R(ENXMkWxq2NOu(gFGLcH(MsJESbz(k)q0xkns3rsh2xYsZ3ZttFzw2IW8DkMHPY3NY3BOjO8L6lDENI9TqcdMAFZs5RCg23dicglZx2lJ(wpFfInFzJrK28ft40Yx99oJnvGV8LrMHWPc8n2Gte03P8fKFMox(ou(g(j89kbJ(wVDnvGVOMH(AVVQ33Su(Y5lYnFFWiSLh(Y5jkfZ3H5lDENI9TqcdMAHtlF13ZELvaQ8voRW(so1eCzDikNtXi332xQXMVsnZx79npo0H9DkFLEgZxQj4Yy((LoSVKPrgZ3ZsN(Yjzg67x(AWKDbQWPLV6lixPqLVz92fc99mrysqmJ4lwgmSV27ldnFjo8LzWVcqOVNRJrHYtJjCA5R(EorDsxFJV3xWmHVG8Z05Yx9hmnFzt1qFhZxiQhK57x(2(IkLi0PHkFH5O6iySmMWPLV679Nj68mfAF9LVC2Sh6BSbXkWU89a(nMVtzVVgCQiO5R(dMMaiwpmJbCpqC(yNHgXbW9aG4eW9aXyLsAubWhG4gCmeojqSct7QhPMGltqX5jkfQ6wcdqJ5B088TfUPXowO8GmFjrYxfM2vpsnbxMGIZtuku1TegGgZ3O557n(sIKV36RLASmHebKztf0zpezcSsjnQ8LejFH5O6iySmrQumbs3HzmF56lmhvhbJLjsLIjGOCofZ3O457Pt(sIKVspJ5lxFPMGlRdr5CkMVrXZ3tNaIZMnFbeNv4UQuagai4h4EGySsjnQa4dqCdogcNei(wFbNWjL0O44F9ubDirnT(XZbH(Y1xY8vIGIsOsyKUbZIr9q50MVeeh(Y1xirHupmafkmv6bzwV9JwGvkPrLVC9nB2ag7yHYdY8nkE(gkFjrY3SzdySJfkpiZxE(YVVGceNnB(ciwHPD1B)ObmaqekG7bIXkL0OcGpaXn4yiCsG4B9fCcNusJIJ)1tf0He106hpheceNnB(cigpgfkpnadaeNh4EGySsjnQa4dqCdogcNeiwHseuuckKziCQGoNNOucMLTi(gfpFdLVC9T9Vw9CkrE8Tuh(GHcikNtX8nkFdfqC2S5lGykKziCQGoZGteeiUfUPXULWa0yaG4eGbaIBaUhigRusJka(ae3GJHWjbIvOebfLGczgcNkOZ5jkLGzzlIVr57jG4SzZxaXuiZq4ubDMbNiiqClCtJDlHbOXaaXjadae3bW9aXyLsAubWhG4gCmeojqmKOqHnYy3((59nkFjZ32)A1ZPekmTREwQUcBzybeLZPy(Y13B91snwMqHuJgfyLsAu5ljs(2(xREoLqHuJgfquoNI5lxFTuJLjui1OrbwPKgv(sIKVThmwzzIAcUSovI(Y132)A1ZPekmTlwxrGcikNtX8fuG4SzZxaXuiZq4ubDMbNiiqClCtJDlHbOXaaXjadae0rG7bIXkL0OcGpaXn4yiCsGyY89wFzOztfWeTWnn6ljs(QW0U6rQj4YeuCEIsHQULWa0y(gnpFBHBASJfkpiZxq9LRVkuIGIsqHmdHtf058eLsWSSfX3O9nu(Y1xirHcBKXU99q5Bu(2(xREoLiRWDvPequoNIbeNnB(ciMZtuQo7alfcbIviRbNdB(cigK9clFTegGMVmo5bZ3eI(QgwkPrvi(AxdZxoJw7RgnFd)e(YoWs5lKOqgn48eLI57umdtLVpLVCYXMkWxQh6lDw0jnOtKA0inOtmTlYz(sNeOaWamG48XUebKza3daIta3deJvkPrfaFaIBWXq4KaXzZgWyhluEqMVrXZ3BaIZMnFbe30jNPc6SRu9Cyagai4h4EGySsjnQa4dqCdogcNeioB2ag7yHYdY8LNV3HVC9vHPD1JutWLjO48eLcvDlHbOX8nAE(gkG4SzZxaXnDYzQGo7kvphgGbaIqbCpqmwPKgva8biUbhdHtceBPgltiraz2ubD2drMaRusJkF56lz(QW0U6rQj4YeuCEIsHQULWa0y(YZ3SzdySJfkpiZxsK8vHPD1JutWLjO48eLcvDlHbOX8nAE(gkFb1xsK81snwMqIaYSPc6ShImbwPKgv(Y1xl1yzIMo5mvqNDLQNdtGvkPrLVC9vHPD1JutWLjO48eLcvDlHbOX8nAE(EcioB28fqmNNOuD2bwkecyaG48a3deJvkPrfaFaIBWXq4KaXK5RebfLGrOuy1v)llGy2mFjrY3B9fCcNusJIJ)1tf0He106hphe6lO(Y1xY8vIGIsOsyKUbZIr9q50MVeeh(Y1xirHupmafkmv6bzwV9JwGvkPrLVC9nB2ag7yHYdY8nkE(gkFjrY3SzdySJfkpiZxE(YVVGceNnB(ciwHPD1B)ObmaqCdW9aXyLsAubWhG4gCmeojqmKOMw)45GqHcPM2y(gLVK57j65ln9vHPD1JutWLjO48eLcvDlHbOX8Lo4BO8fuF56Rct7QhPMGltqX5jkfQ6wcdqJ5Bu(Eh(Y13B9fCcNusJIJ)1tf0He106hphe6ljs(krqrjyCsO8ubD5HzcIdG4SzZxaX4XOq5PbyaG4oaUhigRusJka(ae3GJHWjbIHe106hphekui10gZ3O8L)B8LRVkmTREKAcUmbfNNOuOQBjmanMVr77n(Y13B9fCcNusJIJ)1tf0He106hpheceNnB(cigpgfkpnadae0rG7bIXkL0OcGpaXn4yiCsG4B9vHPD1JutWLjO48eLcvDlHbOX8LRV36l4eoPKgfh)RNkOdjQP1pEoi0xsK8LAcUSoeLZPy(gLV34ljs(cZr1rWyzIuPycKUdZy(Y1xyoQocgltKkftar5CkMVr57naXzZMVaIXJrHYtdWaaXza4EG4SzZxaXCEIs1zhyPqiqmwPKgva8bWaabFbW9aXyLsAubWhG4gCmeojq8T(coHtkPrXX)6Pc6qIAA9JNdcbIZMnFbeJhJcLNgGbyaXT)1QNtXaUhaeNaUhigRusJka(ae3GJHWjbIbNWjL0OqopJpS3(xREofRNnBaJ(sIKVhOjcsyWhwJISzdy0xU(EGMiiHbFynkGOCofZ3O45l)3HVKi5R0Zy(Y1xQj4Y6quoNI5Bu(Y)DaeNnB(ci(4T5ladae8dCpqmwPKgva8biUbhdHtce3(xREoLqLWiDdMfJ6HYPnFjGOCofRJ09aBgQ8nkFPJ(Y1xY8T9Vw9CkbrD96WDj9eCzcikNtX8nkFPJ(Y1xl1yzcI661H7s6j4YeyLsAu5ljs(ERVwQXYee11Rd3L0tWLjWkL0OYxq9LRVK5ldTU0xemHniK)Zq)8hnF56RLWa0e2iJD77hnRhQB8nkFpVVKi57T(YqRl9fbtydc5)m0p)rZxsK8LAcUSoeLZPy(gTV8tp65lO(Y1xY8T9Vw9Ckrk9YtL28vxpYscikNtX8nkFpDg8LRVK5lKOqQhgGIu6LNkT5lwNcI1zoSaRusJkFjrYx2tOLMsjIGGNI1))mJ6PceyLsAu5lO(sIKV36lKOqQhgGIu6LNkT5lwNcI1zoSaRusJkF567T(YEcT0ukree8uS()NzupvGaRusJkFb1xU(sMVT)1QNtjYJVL6Whmuar5CkwhP7b2mu5Bu(sh9LRVGt4KsAuqrO19Mc6ljs(ERVGt4KsAuqrO19Mc6ljs(coHtkPrHQ1HMVG6ljs(k9mMVC9LAcUSoeLZPy(gLVH6gG4SzZxaXjuoC)P62f2vyQamaqekG7bIXkL0OcGpaXn4yiCsGylHbOjSrg723pAwpu34Bu(EJVC9LmFTegGMWgzSBFxnOVr77n(Y13SzdySJfkpiZ3O45BO8LejFzO1L(IGjSbH8Fg6N)O5lxFLiOOeQegPBWSyupuoT5lbXHVC9nB2ag7yHYdY8nkE(EJVC9LmFV1xfM2vplvxHTmSWMwKPc8LejFBpySYYe1eCzDQe9fuFbfioB28fqm7j0DiMhieiUfUPXULWa0yaG4eGbaIZdCpqmwPKgva8biUbhdHtcedoHtkPrbZ6h6SQPc8LRVK5B7FT65uI84BPo8bdfquoNI1r6EGndv(gLV34ljs(2(xREoLip(wQdFWqbeLZPyDKUhyZqLVr77j65lO(Y1xY8T9Vw9CkHkHr6gmlg1dLtB(sar5CkMVr5Bqt5ljs(krqrjujms3GzXOEOCAZxcIdFbfioB28fqmrD96WDj9eCzaXkK1GZHnFbeFN71kMV8rpbxMVup0xIdFT33B8LHTVumFT3xw4Q5lNXU8fKF8Tuh(GHH47zYUqiNHHH4lbd9LZyx(sNjmIV3dZIr9q50MVeagaiUb4EGySsjnQa4dqCdogcNeigCcNusJIuPyDikNt5ljs(k9mMVC9LAcUSoeLZPy(gLV8FcioB28fqmrD96WDj9eCzagaiUdG7bIXkL0OcGpaXn4yiCsGyWjCsjnkyw)qNvnvGVC9LmFvVjiQRxhUlPNGlRREtar5CkMVKi57T(APgltquxVoCxspbxMaRusJkFbfioB28fqSkHr6gmlg1dLtB(cWaabDe4EGySsjnQa4dqCdogcNeigCcNusJIuPyDikNt5ljs(k9mMVC9LAcUSoeLZPy(gLV8FcioB28fqSkHr6gmlg1dLtB(cWaaXza4EGySsjnQa4dqCdogcNeioB2ag7yHYdY8LNVN8LRVkuIGIsqHmdHtf058eLsWSSfX3O55759LRVK57T(coHtkPrbfHw3BkOVKi5l4eoPKgfueADVPG(Y1xY8T9Vw9CkbrD96WDj9eCzcikNtX8nAFprpFjrY32)A1ZPeQegPBWSyupuoT5lbeLZPyDKUhyZqLVr77j65lxFV1xl1yzcI661H7s6j4YeyLsAu5lO(ckqC2S5lG484BPo8bdbmaqWxaCpqmwPKgva8biUbhdHtceNnBaJDSq5bz(gnpF53xU(QqjckkbfYmeovqNZtukbZYweFJMNVN3xU(ERVkmTREwQUcBzyHnTitfaeNnB(ciop(wQdFWqG4w4Mg7wcdqJbaItagaiorpG7bIXkL0OcGpaXn4yiCsGyirnT(XZbHcfsnTX8nkFpDEF56B7FT65ucI661H7s6j4YequoNI5Bu(Eku(Y132)A1ZPeQegPBWSyupuoT5lbeLZPyDKUhyZqLVr57PqbeNnB(ciMril)vpiHbFyncyaG40jG7bIXkL0OcGpaXn4yiCsGyWjCsjnkyw)qNvnvGVC9vHseuuckKziCQGoNNOucMLTi(gLV87lxFjZ3d0e5X36bxpHwKnBaJ(sIKVseuucvcJ0nywmQhkN28LG4WxU(2(xREoLip(wQdFWqbeLZPy(gTVNONVKi5B7FT65uI84BPo8bdfquoNI5B0(EIE(Y132)A1ZPeQegPBWSyupuoT5lbeLZPy(gTVNONVGceNnB(ciMOUED4EYyjH2amaqCIFG7bIXkL0OcGpaXn4yiCsG4SzdySJfkpiZ3O55l)(Y1xfkrqrjOqMHWPc6CEIsjyw2I4Bu(YVVC9LmFpqtKhFRhC9eAr2Sbm6ljs(krqrjujms3GzXOEOCAZxcIdFjrY32)A1ZPekmTREwQUcBzybeLZPy(gLVbnLVGceNnB(ciMOUED4EYyjH2aIBHBASBjmangaiobyaG4uOaUhigRusJka(ae3GJHWjbIV13d0ebxpHwKnBaJaXzZMVaIH5WWUctfGbyaXbyHWPbCpaiobCpqmwPKgva8biUbhdHtceFRVGt4KsAuC8VEQGoKOMw)45GqF56lz(krqrjyekfwD1)YciMnZxsK8fsutRF8CqOqHutBmFJINVNcLV00xY8fsui1ddqbmLpYY6gmlgfcXQHcSsjnQ8Lo4BO8LM(QW0U6rQj4YeqIcPEyakUcZmeoPV0bFdLVG6lO(sIKVhOjcsyWhwJISzdy0xU(cjk03O45BO8LejFPMGlRdr5CkMVr57j65lxFV1xfkrqrjOqMHWPc6CEIsjioaIZMnFbeRW0U6TF0agai4h4EGySsjnQa4dqCdogcNeiMmFTuJLjui1OrbwPKgv(sIKVThmwzzIAcUSovI(sIKVqIcPEyakoUWe(YFHmbwPKgv(cQVC9LmFjZ3B9fCcNusJIJ)1tf0HefY8LejFBpySYYe1eCzDQe9LRVwQXYekKA0OaRusJkF56B7lfXycoJDHWPc6bWNOucSsjnQ8fuFjrYxPNX8LRVutWL1HOCofZ3O89gFbfioB28fqCwH7QsbyaGiua3deJvkPrfaFaIBWXq4KaXGt4KsAuOiKp6CEIsX8LRVkuIGIsqHmdHtf058eLsWSSfX3O557jF56B7FT65uI84BPo8bdfquoNI1r6EGndv(gTVNUXx(QVK5lKOqQhgGcfMk9GmR3(rlWkL0OYx6GVNONVG6lxFV1xWjCsjnko(xpvqhsuidioB28fqmNNOuD2bwkecyaG48a3deJvkPrfaFaIBWXq4KaXkuIGIsqHmdHtf058eLsWSSfX3O9nu(Y13B9fCcNusJIJ)1tf0HefY8LejFvOebfLGczgcNkOZ5jkLG4WxU(snbxwhIY5umFJYxY8vHseuuckKziCQGoNNOucMLTi(sh8nOP8fuG4SzZxaXCEIs1zhyPqiGbaIBaUhigRusJka(ae3GJHWjbIHe106hphekui10gZ3O45l)0ZxA6lz(cjkK6HbOaMYhzzDdMfJcHy1qbwPKgv(sh898(stFvyAx9i1eCzcirHupmafxHzgcN0x6GVN3xq9LRV36l4eoPKgfh)RNkOdjQP1pEoieioB28fqSct7Q3(rdyaG4oaUhigRusJka(ae3GJHWjbIvOebfLGczgcNkOZ5jkLGzzlIVr5759LRV36l4eoPKgfh)RNkOdjkKbeNnB(ciMczgcNkOZm4ebbmaqqhbUhigRusJka(ae3GJHWjbIV1xWjCsjnko(xpvqhsutRF8CqiqC2S5lGyfM2vV9JgWaaXza4EGySsjnQa4dqCdogcNeiwHseuuckKziCQGoNNOucMLTi(gnpFp5lxFHef6Bu(YVVC99wFbNWjL0O44F9ubDirHmF56B7FT65uI84BPo8bdfquoNI1r6EGndv(gTV3aeNnB(ciMZtuQo7alfcbmadiU9GXklJbCpaiobCpqmwPKgva8biUbhdHtcedoHtkPrbZ6h6SQPc8LRVqIAA9JNdcfkKAAJ5B0(E6o8LRVK5B7FT65uI84BPo8bdfquoNI5ljs(ERVwQXYejuoC)P62f2vPCHkbwPKgv(Y132)A1ZPeQegPBWSyupuoT5lbeLZPy(cQVKi5R0Zy(Y1xQj4Y6quoNI5Bu(E6eqC2S5lGygNekpvqxEygGbac(bUhigRusJka(ae3GJHWjbIB)RvpNsKhFl1HpyOaIY5umF56lz(MnBaJDSq5bz(gnpF53xU(MnBaJDSq5bz(gfpFVXxU(cjQP1pEoiuOqQPnMVr77j65ln9LmFZMnGXowO8GmFPd(Eh(cQVC9fCcNusJIuPyDikNt5ljs(MnBaJDSq5bz(gTV34lxFHe106hphekui10gZ3O9980ZxqbIZMnFbeZ4Kq5Pc6YdZaIviRbNdB(ciognFT3xcg6Bszi0384B(omF)Y3ZsN(MmFT33dicglZ3hmcB5XXub(EoVt(Y5A0OVm0SPc8L4W3ZsNKZamaqekG7bIXkL0OcGpaXn4yiCsGyWjCsjnkyw)qNvnvGVC99wFzpHwAkLqJPQlfUJ0nLp0OaRusJkF56lz(2(xREoLip(wQdFWqbeLZPy(sIKV36RLASmrcLd3FQUDHDvkxOsGvkPrLVC9T9Vw9CkHkHr6gmlg1dLtB(sar5CkMVG6lxFHefkSrg723pVVr7RebfLasutR3EiK4WMVequoNI5ljs(k9mMVC9LAcUSoeLZPy(gLV8FcioB28fqCk9YtL28vxpYsagaiopW9aXyLsAubWhG4gCmeojqm4eoPKgfmRFOZQMkWxU(YEcT0ukHgtvxkChPBkFOrbwPKgv(Y1xY8v9MGOUED4UKEcUSU6nbeLZPy(gTVNo5ljs(ERVwQXYee11Rd3L0tWLjWkL0OYxU(2(xREoLqLWiDdMfJ6HYPnFjGOCofZxqbIZMnFbeNsV8uPnF11JSeGbaIBaUhigRusJka(ae3GJHWjbIbNWjL0OGz9dDw1ub(Y1x2tOLMsjIGGNI1))mJ6PceyLsAu5lxFjZxfkrqrjOqMHWPc6CEIsjyw2I4B08898(Y13B9fsui1ddqrk9YtL28fRtbX6mhwGvkPrLVKi5lKOqQhgGIu6LNkT5lwNcI1zoSaRusJkF56B7FT65uI84BPo8bdfquoNI5lOaXzZMVaItPxEQ0MV66rwcWaaXDaCpqmwPKgva8biUbhdHtcedoHtkPrrQuSoeLZP8LRVqIcf2iJD77N33O9vIGIsajQP1BpesCyZxcikNtXaIZMnFbeNsV8uPnF11JSeGbac6iW9aXyLsAubWhG4gCmeojqm4eoPKgfmRFOZQMkWxU(sMVT)1QNtjYJVL6Whmuar5CkMVr77j65ljs(ERVwQXYejuoC)P62f2vPCHkbwPKgv(Y132)A1ZPeQegPBWSyupuoT5lbeLZPy(cQVKi5R0Zy(Y1xQj4Y6quoNI5Bu(E6gG4SzZxaXSRSfrJD7c7efNhAxHbmaqCgaUhigRusJka(ae3GJHWjbIbNWjL0OivkwhIY5u(Y1xY8vHPD1Zs1vyldlSPfzQaFjrYxyoQocgltKkftar5CkMVrXZ3tN3xqbIZMnFbeZUYwen2TlStuCEODfgWaabFbW9aXyLsAubWhG4gCmeojqm7j0stPehemJqJDesCyZxcSsjnQ8LejFzpHwAkLa8RtB0yN9AWyzcSsjnQ8LRV36RebfLa8RtB0yN9AWyz9lc5S(rjioaINYqiK4W6dfqm7j0stPeGFDAJg7SxdgldiEkdHqIdRpYYOAsdbIpbeNnB(ciMsJSRgmPmG4PmecjoSEG(Lsnq8jadWaIpGy7LLsd4EaqCc4EG4SzZxaXhVnFbeJvkPrfaFamaqWpW9aXzZMVaIH5WWUctfqmwPKgva8bWaarOaUhioB28fqmLgzxnyszaXyLsAubWhadaeNh4EGySsjnQa4dqCdogcNei(wFTuJLjyeYYF1dsyWhwJcSsjnQaIZMnFbeNq5W9NQBxyxHPci(aITxwkTUnYiqCOamaqCdW9aXyLsAubWhG4)aiMH2qbeRqwdoh28fq85cCQjsdz(M(AWPIGgZ32)A1ZPcXx1aEuOYxPW(E(Be(E)1W8LtY8TD9mS8nz(suxVoSVCEyeMVF575VXxg2(s5RebKz(2c30ileFLimFVsMV2)(kNvyFBkOViff2mMV27BWag9n9T9Vw9CkbDfkcyAZx(QgWd7H(ofZWuj89Ct57yKZ8fCQjqFVsMV17leLZPui0xiAeWY3tH4lQzOVq0iGLV0tCJaigCQjqG4taXGtyVszei2GtfbT(PolC1aIZMnFbedoHtkPrGyWPMa7OMHaX0tCdqCdogcNei2GtfbnHDsCLSobd7seuu(Y1xY81GtfbnHDs0(xREoLqratB(YxqgFp)n(YZx65lOagaiUdG7bIXkL0OcGpaX)bqmdTHcioB28fqm4eoPKgbIbNWELYiqSbNkcAD(7SWvdigCQjqG4taXGtnb2rndbIPN4gG4gCmeojqSbNkcAcJFXvY6emSlrqr5lxFjZxdove0eg)I2)A1ZPekcyAZx(cY475VXxE(spFbfWaabDe4EGySsjnQa4dq8FaeZqBOaIviRbNdB(ci(CXSronK5B6RbNkcAmFbNAc0xPW(2E5JeovGV2f6B7FT65u((u(AxOVgCQiOfIVQb8OqLVsH91UqFveW0MV89P81UqFLiOO8DmFpGp4rHmHV35sMVPVmdIvGD5R8RgQbH(AVVbdy0303Rj4cH(EaNhowyFT3xMbXkWU81Gtfbnwi(MmF5GATVjZ30x5xnudc9L6H(ou(M(AWPIGMVCgT23h6lNrR9TEZxw4Q5lNXU8T9Vw9CkMaigCQjqGy(bIbNWELYiqSbNkcA9d48WXcdeNnB(cigCcNusJaXGtnb2rndbIpbe3GJHWjbIV1xdove0e2jXvY6emSlrqr5lxFn4urqty8lUswNGHDjckkFjrYxdove0eg)IRK1jyyxIGIYxU(sMVK5RbNkcAcJFr7FT65ucfbmT5lFPHVK5RbNkcAcJFHebfvxratB(Y3O5lXx6jO3jFb1xq9Lo4lz(EsCJV00xdove0eg)IRK1LiOO8fuFPd(sMVGt4KsAuyWPIGwN)olC18fuFb13O9LmFjZxdove0e2jr7FT65ucfbmT5lFPHVK5RbNkcAc7KqIGIQRiGPnF5B08L4l9e07KVG6lO(sh8LmFpjUXxA6RbNkcAc7K4kzDjckkFb1x6GVK5l4eoPKgfgCQiO1p1zHRMVG6lOagaioda3deJvkPrfaFaI)dGygAaXzZMVaIbNWjL0iqm4utGaXwQXYejuoC)P62f2vPCHkbwPKgv(Y132xkIXeTVa)T0MV6pv3UWUctLaRusJkGyWjSxPmcetrO19McceRqwdoh28fq85cCQjsdz(2iGqSmFzOrC4l1d91UqF5BISSXc77t5li)4BPo8bd99S0550xKIcBgdWaabFbW9aXyLsAubWhG4)aiMHgqC2S5lGyWjCsjncedo1eiqmKOqQhgGcfM2fR3qOLtzHfyLsAu5lxFHefs9Wauat5JSSUbZIrHqSAOaRusJkGyWjSxPmceRADObyagqmmBtQza3daIta3deJvkPrfaFaIBWXq4KaXqIAA9JNdcfkKAAJ5B0(Eh34lxFjZ3d0ebjm4dRrr2Sbm6ljs(ERVwQXYemcz5V6bjm4dRrbwPKgv(cQVC9fsuOqHutBmFJMNV3aeNnB(cioHTSWU9qiwgqSczn4CyZxaXNZSnPMbyaGGFG7bIXkL0OcGpaXn4yiCsGyWjCsjnkKZZ4d7T)1QNtX6zZgWOVKi57bAIGeg8H1OiB2ag9LRVhOjcsyWhwJcikNtX8nkE(krqrjK0)R6ueWWcfbmT5lFjrYxPNX8LRVutWL1HOCofZ3O45RebfLqs)VQtradlueW0MVaIZMnFbelP)x1PiGHbmaqekG7bIXkL0OcGpaXn4yiCsGyWjCsjnkKZZ4d7T)1QNtX6zZgWOVKi57bAIGeg8H1OiB2ag9LRVhOjcsyWhwJcikNtX8nkE(krqrjKqidHrMkqOiGPnF5ljs(k9mMVC9LAcUSoeLZPy(gfpFLiOOesiKHWitfiueW0MVaIZMnFbelHqgcJmvaGbaIZdCpqmwPKgva8biUbhdHtcelrqrjiQRxhUZmiwb2LG4aioB28fqSEcUmw)msOcKXYamaqCdW9aXyLsAubWhG4gCmeojqm4eoPKgfY5z8H92)A1ZPy9Szdy0xsK89anrqcd(WAuKnBaJ(Y13d0ebjm4dRrbeLZPy(gfpFpDJVKi5R0Zy(Y1xQj4Y6quoNI5Bu8890naXzZMVaIZQHmdM6El1AGyfYAW5WMVaIb5vdzgm1(E2uR9TLLVgCccqOVN33J3WYMu7RebffleFXSD5Roz2ub(E6gFzy7lft47DMn65mJkFVsOY32RqLV2iJ(MmFtFn4eeGqFT33iiE47y(cXuLsAuayaG4oaUhigRusJka(ae3GJHWjbIZMnGXowO8GmFJMNV87ljs(sMVqIcfkKAAJ5B0889gF56lKOMw)45GqHcPM2y(gnpFVd65lOaXzZMVaItyllSFqOziGbac6iW9aXyLsAubWhG4gCmeojqm4eoPKgfY5z8H92)A1ZPy9Szdy0xsK89anrqcd(WAuKnBaJ(Y13d0ebjm4dRrbeLZPy(gfpFLiOOeudeL0)RekcyAZx(sIKVspJ5lxFPMGlRdr5CkMVrXZxjckkb1arj9)kHIaM28fqC2S5lGyQbIs6)vagaioda3deJvkPrfaFaIBWXq4KaXzZgWyhluEqMV889KVC9LmFLiOOee11Rd3zgeRa7sqC4ljs(k9mMVC9LAcUSoeLZPy(gLV34lOaXzZMVaILYG(t1n40IWamadi2GtfbngW9aG4eW9aXyLsAubWhG4kLrG4PyniHLsASZ3ezzeYDfcEAiqC2S5lG4PyniHLsASZ3ezzeYDfcEAiqCdogcNeiMmFB)RvpNsquxVoCxspbxMaIY5umFJ2x(PNVKi5B7FT65ucvcJ0nywmQhkN28LaIY5uSos3dSzOY3O9LF65lO(Y1xY8nB2ag7yHYdY8nAE(YVVKi57bAIekhUhC9eAr2Sbm6ljs(EGMip(wp46j0ISzdy0xU(sMVwQXYee11Rd3tglj0MaRusJkFjrYxfM2vpsnbxMqnSusJ98nLVG6ljs(EGMiiHbFynkYMnGrFb1xsK8v6zmF56l1eCzDikNtX8nkF5)KVKi5Rct7QhPMGltOgwkPX(W3QosxSryOV88LE(Y1xlHbOjSrg723pAwNF65Bu(EdGbac(bUhigRusJka(aexPmcehKGrD)P62f2PgiZ6juAmeceNnB(cioibJ6(t1TlStnqM1tO0yieWaarOaUhigRusJka(aexPmceZAjK1FQofmnewPUZm4qHaXzZMVaIzTeY6pvNcMgcRu3zgCOqadaeNh4EGySsjnQa4dqCLYiqSDHDQbYSoBcgnqC2S5lGy7c7udKzD2emAG4gCmeojqm4eoPKgfY5z8H92)A1ZPy9Szdy0xU(sMV2iJ(gTVHIE(sIKV36lY3eZXbQetXAqclL0yNVjYYiK7ke80qFbfWaaXna3deJvkPrfaFaIRugbIFWiKZfQLNkOF8CqyVbdZSudeNnB(ci(bJqoxOwEQG(XZbH9gmmZsnqCdogcNeigCcNusJc58m(WE7FT65uSE2Sbm6lxFjZxBKrFJ23qrpFjrY3B9f5BI54avIPyniHLsASZ3ezzeYDfcEAOVC99wFr(MyooqLWUWo1azwNnbJ2xqbmaqCha3deJvkPrfaFaIBWXq4KaX36l4eoPKgfSdSnudQ6gCQiO5lxFjZxY81GtfbnHDsirqr1veW0MV8nkE(E6gF56B7FT65uI84BPo8bdfquoNI5B0(Yp98LejFn4urqtyNeseuuDfbmT5lFJ23t34lxFjZ32)A1ZPee11Rd3L0tWLjGOCofZ3O9LF65ljs(2(xREoLqLWiDdMfJ6HYPnFjGOCofRJ09aBgQ8nAF5NE(cQVKi5B2Sbm2XcLhK5B088LFF56RebfLqLWiDdMfJ6HYPnFjio8fuF56lz(ERVgCQiOjm(fxjR3(xREoLVKi5RbNkcAcJFr7FT65ucikNtX8LejFbNWjL0OWGtfbT(bCE4yH9LNVN8fuFb1xsK8v6zmF56RbNkcAc7KqIGIQRiGPnF5B088LAcUSoeLZPyaXzZMVaIn4urq7eqSczn4CyZxaX3FH(AWPIGMVCg7Yx7c99AcUqM5lYSronu5l4utGH4lNrR9vc9LGHkFPgiZ8nlLVh5arLVCg7Yxq(X3sD4dg6lzdLVseuu(omFpDJVmS9LI57d9vJmgO((qF5JEcUmAqN37lzdLVbqmne6RDLLVNUXxg2(sXafWaabDe4EGySsjnQa4dqCdogcNei(wFbNWjL0OGDGTHAqv3GtfbnF56lz(sMVgCQiOjm(fseuuDfbmT5lFJINVNUXxU(2(xREoLip(wQdFWqbeLZPy(gTV8tpFjrYxdove0eg)cjckQUIaM28LVr77PB8LRVK5B7FT65ucI661H7s6j4YequoNI5B0(Yp98LejFB)RvpNsOsyKUbZIr9q50MVequoNI1r6EGndv(gTV8tpFb1xsK8nB2ag7yHYdY8nAE(YVVC9vIGIsOsyKUbZIr9q50MVeeh(cQVC9LmFV1xdove0e2jXvY6T)1QNt5ljs(AWPIGMWojA)RvpNsar5CkMVKi5l4eoPKgfgCQiO1pGZdhlSV88LFFb1xq9LejFLEgZxU(AWPIGMW4xirqr1veW0MV8nAE(snbxwhIY5umG4SzZxaXgCQiOXpGbaIZaW9aXyLsAubWhG4SzZxaXgCQiODciMPFdi2GtfbTtaXkK1GZHnFbeFUP89lDyF)c99lFjyOVgCQiO57b8bpkK5B6Rebfvi(sWqFTl033UqOVF5B7FT65ucFptqFhkFlCSle6RbNkcA(EaFWJcz(M(krqrfIVem0xP3U89lFB)RvpNsae3GJHWjbIV1xWjCsjnkyhyBOgu1n4urqZxU(ERVgCQiOjStIRK1jyyxIGIYxU(sMVgCQiOjm(fT)1QNtjGOCofZxsK89wFn4urqty8lUswNGHDjckkFbfWaabFbW9aXyLsAubWhG4gCmeojq8T(coHtkPrb7aBd1GQUbNkcA(Y13B91GtfbnHXV4kzDcg2LiOO8LRVK5RbNkcAc7KO9Vw9CkbeLZPy(sIKV36RbNkcAc7K4kzDcg2LiOO8fuG4SzZxaXgCQiOXpqmt)gqSbNkcA8dyagqScPscTbCpaiobCpqC2S5lGy5PuDkiINzeigRusJka(ayaGGFG7bIXkL0OcGpaX)bqmdnG4SzZxaXGt4KsAeigCQjqGyY8f5BI54avIPyniHLsASZ3ezzeYDfcEAOVKi5lY3eZXbQe2f2PgiZ6Sjy0(sIKViFtmhhOs8GriNlulpvq)45GWEdgMzP2xq9LRVK5B7FT65uIPyniHLsASZ3ezzeYDfcEAOaIPkSVKi5B7FT65uc7c7udKzD2emAbeLZPy(sIKVT)1QNtjEWiKZfQLNkOF8CqyVbdZSulGOCofZxq9LejFjZxKVjMJdujSlStnqM1ztWO9LejFr(MyooqL4bJqoxOwEQG(XZbH9gmmZsTVG6lxFr(MyooqLykwdsyPKg78nrwgHCxHGNgcedoH9kLrGy2b2gQbvDdove0aIviRbNdB(ci(obrWyz(YoW2qnOYxdove0y(kHtf4lbdv(YzSlFtc7LtBA(QNczagaicfW9aXyLsAubWhG4)aiMHgqC2S5lGyWjCsjncedo1eiqC7FT65ucgHS8x9Geg8H1OaIY5umFJY3B8LRVwQXYemcz5V6bjm4dRrbwPKgv(Y1xY81snwMGOUED4UKEcUmbwPKgv(Y132)A1ZPee11Rd3L0tWLjGOCofZ3O89uO8LRVT)1QNtjujms3GzXOEOCAZxcikNtX6iDpWMHkFJY3tHYxsK89wFTuJLjiQRxhUlPNGltGvkPrLVGcedoH9kLrG4J)1tf0He106hphecyaG48a3deJvkPrfaFaI)dGygAaXzZMVaIbNWjL0iqm4utGaXwQXYeSNq3HyEGqbwPKgv(Y1xirH(gLV87lxFTegGMWgzSBF)Oz9qDJVr57n(Y1xQj4Y6quoNI5B0(EJVKi5B7bJvwMOMGlRtLOVC91snwMqHuJgfyLsAu5lxFB)RvpNsOqQrJcikNtX8nkFHefkSrg7235higCc7vkJaXh)RNkOdjkKbyaG4gG7bIXkL0OcGpaX)bqmdnG4SzZxaXGt4KsAeigCQjqG4SzdySJfkpiZxE(EYxU(sMV36lmhvhbJLjsLIjq6omJ5ljs(cZr1rWyzIuPyIP8nAFpDJVGcedoH9kLrGyM1p0zvtfayaG4oaUhigRusJka(ae)haXm0aIZMnFbedoHtkPrGyWPMabIZMnGXowO8GmFJMNV87lxFjZ3B9fMJQJGXYePsXeiDhMX8LejFH5O6iySmrQumbs3HzmF56lz(cZr1rWyzIuPycikNtX8nAFVXxsK8LAcUSoeLZPy(gTVNONVG6lOaXGtyVszeiovkwhIY5uagaiOJa3deJvkPrfaFaI)dGygAaXzZMVaIbNWjL0iqm4utGaXK5RLASmbJqw(REqcd(WAuGvkPrLVC99wFpqteKWGpSgfzZgWOVC9T9Vw9CkbJqw(REqcd(WAuar5CkMVKi57T(APgltWiKL)QhKWGpSgfyLsAu5lO(Y1xY8vIGIsquxVoCpzSKqBcIdFjrYxl1yzIekhU)uD7c7QuUqLaRusJkF567bAI84B9GRNqlYMnGrFjrYxjckkHkHr6gmlg1dLtB(sqC4lxFLiOOeQegPBWSyupuoT5lbeLZPy(gTV34ljs(MnBaJDSq5bz(gnpF53xU(QW0U6zP6kSLHf20ImvGVGcedoH9kLrGy58m(WE7FT65uSE2SbmcyaG4maCpqmwPKgva8bi(paIzObeNnB(cigCcNusJaXGtnbce3EWyLLjQj4Y6uj6lxFvyAx9SuDf2YWcBArMkWxU(krqrjuyAxSUIafmlBr8nkFpVVKi5RebfLqoHWNdQ6bOmZ(c7yDLvdLXYeeh(sIKVseuuc7coADNHyeekio8LejFLiOOeuqSoZdQ6YFXm4ZglSG4WxsK8vIGIsOXu1Lc3r6MYhAuqC4ljs(krqrjAx5Z6szHcIdFjrY32)A1ZPee11Rd3tglj0MaIY5umFJY3B8LRVT)1QNtjYJVL6Whmuar5CkMVr77j6bedoH9kLrGyfH8rNZtukgGbac(cG7bIXkL0OcGpaXn4yiCsGy1BcWdKqJL1p0zabkGifezxPKg9LRV36RLASmbrD96WDj9eCzcSsjnQ8LRV36lmhvhbJLjsLIjq6omJbeNnB(ci(jmjiMraIviRbNdB(ci(oFoLLtnvGVNJgiHglZ37KodiqFhMVPVhW5HJfgWaaXj6bCpqmwPKgva8biUbhdHtceREtaEGeASS(HodiqbePGi7kL0OVC9nB2ag7yHYdY8nAE(YVVC9LmFV1xl1yzcI661H7s6j4YeyLsAu5ljs(APgltquxVoCxspbxMaRusJkF56lz(2(xREoLGOUED4UKEcUmbeLZPy(gTVK57PB8Lg(MnBaJDSq5bz(stFvVjapqcnww)qNbeOaIY5umFb1xsK8nB2ag7yHYdY8nAE(gkFb1xqbIZMnFbe)eMeeZiaXTWnn2TegGgdaeNamaqC6eW9aXyLsAubWhG4SzZxaXpHjbXmcqSEkS3uaX3bqSczn4CyZxaXNBkFTleI(Mq0xSq5bz(kpm2ub(Eo6ofIV5XHoSVJ5lzseMV17R8drFTRS89Rg67bc99o8LHTVumqfaXn4yiCsG4SzdySREtaEGeASS(HodiqFJY3SzdySJfkpiZxU(MnBaJDSq5bz(gnpF53xU(sMV36RLASmbrD96WDj9eCzcSsjnQ8LejFB)RvpNsquxVoCxspbxMaIY5umF56RebfLGOUED4UKEcUSUebfLq9CkFbfWaaXj(bUhigRusJka(ae3GJHWjbIHefs9WauWioqiZG5ucSsjnQ8LRVK5R6nbf8zwNcbJqbePGi7kL0OVKi5R6nHK(Fv)qNbeOaIuqKDLsA0xqbIZMnFbe)eMeeZiagaiofkG7bIXkL0OcGpaXn4yiCsG42dgRSmrnbxwNkrF56Rct7QNLQRWwgwytlYub(Y1xY8vHPD1Zs1vyldlYMnGXoeLZPy(gLVK5Bqt5lDW3tIB8fuFjrYxjckkHct7I1veOaIY5umFJY3GMYxqbIZMnFbeZ5jkvNDGLcHaXkK1GZHnFbeForkiYUqMV0jM2fZx6KajN5RebfLVNrcM5Res9q0xfM2fZxfb6lwkgGbaItNh4EGySsjnQa4dqmdBaXT)1QNtjypHUdX8aHcikNtXaIZMnFbeZjhdiUbhdHtceBPgltWEcDhI5bcfyLsAu5lxFTegGMWgzSBF)Oz9qDJVr57n(Y1xlHbOjSrg723vd6B0(EJVC9T9Vw9Ckb7j0DiMhiuar5CkMVr5lz(g0u(sh8LEc64n(cQVC9nB2ag7yHYdY8LNVNamaqC6gG7bIXkL0OcGpaXzZMVaI5KJbeZWgqC7FT65ucfM2fRRiqbeLZPyaXkK1GZHnFbedYMJ5l1d9LoX0UiN5lDsG0GorQrJ(ou(cIj4Y8LVCI(AVVbO5lZGyfyx(krqr5Ru2I4BYYdG4gCmeojqC7bJvwMOMGlRtLOVC9T9Vw9CkHct7I1veOaIY5umFJY3GMYxU(MnBaJDSq5bz(YZ3tagaioDha3deJvkPrfaFaIzydiU9Vw9CkHcPgnkGOCofdioB28fqmNCmG4gCmeojqC7bJvwMOMGlRtLOVC9T9Vw9CkHcPgnkGOCofZ3O8nOP8LRVzZgWyhluEqMV889eGbaIt0rG7bIXkL0OcGpaXzZMVaIBPw3ZMnF11dZaIviRbNdB(cigK3S5lFbPHzmFZs57z6aleY8LSZ0bwiKrJyKVjWQHmFjkgXXXdnu57u(Mk1xcqbI1dZ6vkJaXgCQiOXamaqC6maCpqmwPKgva8bioB28fqCl16E2S5RUEygqSEywVszeiU9GXklJbyaG4eFbW9aXyLsAubWhG4SzZxaXTuR7zZMV66HzaX6Hz9kLrGyy2MuZamaqWp9aUhigRusJka(aeNnB(ciULADpB28vxpmdiwpmRxPmce3(xREofdWaab)NaUhigRusJka(aeNnB(cigsu9SzZxD9WmG4gCmeojqm4eoPKgfPsX6quoNYxU(sMVT)1QNtjuyAx9SuDf2YWcikNtX8nkFprpF567T(APgltOqQrJcSsjnQ8LejFB)RvpNsOqQrJcikNtX8nkFprpF56RLASmHcPgnkWkL0OYxsK8T9GXkltutWL1Ps0xU(2(xREoLqHPDX6kcuar5CkMVr57j65lO(Y13B9vHPD1Zs1vyldlSPfzQaGy9WSELYiqC(yNHgXbGbac(5h4EGySsjnQa4dqCdogcNeioB2ag7yHYdY8nAE(YVVC9vHPD1Zs1vyldlSPfzQaGyMbNMbaItaXzZMVaIHevpB28vxpmdiwpmRxPmceNp2LiGmdWaab)Hc4EGySsjnQa4dqC2S5lGyir1ZMnF11dZaIBWXq4KaXzZgWyhluEqMVrZZx(9LRV36Rct7QNLQRWwgwytlYub(Y1xY89wFbNWjL0OivkwhIY5u(sIKVT)1QNtjuyAx9SuDf2YWcikNtX8nAFprpF567T(APgltOqQrJcSsjnQ8LejFB)RvpNsOqQrJcikNtX8nAFprpF56RLASmHcPgnkWkL0OYxsK8T9GXkltutWL1Ps0xU(2(xREoLqHPDX6kcuar5CkMVr77j65lOaX6Hz9kLrG4aSq4065Jagai4)8a3deJvkPrfaFaIZMnFbe3sTUNnB(QRhMbe3GJHWjbIZMnGXowO8GmF557jGy9WSELYiqCawiCAagGbehGfcNwpFe4EaqCc4EGySsjnQa4dqmdBaXT)1QNtjypHUdX8aHcikNtXaIZMnFbeZjhdiUbhdHtceBPgltWEcDhI5bcfyLsAu5lxFTegGMWgzSBF)Oz9qDJVr57n(Y1xQj4Y6quoNI5B0(EJVC9T9Vw9Ckb7j0DiMhiuar5CkMVr5lz(g0u(sh8LEc64n(cQVC9nB2ag7yHYdY8nkE(gkadae8dCpqmwPKgva8biUbhdHtcetMV36l4eoPKgfh)RNkOdjQP1pEoi0xsK8vIGIsWiukS6Q)LfqmBMVG6lxFjZxjckkHkHr6gmlg1dLtB(sqC4lxFHefs9WauOWuPhKz92pAbwPKgv(Y13SzdySJfkpiZ3O45BO8LejFZMnGXowO8GmF55l)(ckqC2S5lGyfM2vV9JgWaarOaUhigRusJka(ae3GJHWjbILiOOemcLcRU6FzbeZM5ljs(ERVGt4KsAuC8VEQGoKOMw)45GqG4SzZxaX4XOq5PbyaG48a3deJvkPrfaFaIviRbNdB(ci(Ct5RLWa08TfUPNkW3H5RAyPKgvH4lJZyTlFLYweFT3x7c9LnvGg5RwcdqZ3aSq408vpmZ3PygMkbqC2S5lGyir1ZMnF11dZaIzgCAgaiobe3GJHWjbIBHBASJfkpiZxE(EciwpmRxPmcehGfcNgGbaIBaUhigRusJka(ae3GJHWjbIjZ32)A1ZPe5X3sD4dgkGOCofZ3O99gF56RcLiOOeuiZq4ubDoprPeeh(sIKVkuIGIsqHmdHtf058eLsWSSfX3O9nu(cQVC9LmFPMGlRdr5CkMVr5B7FT65ucfM2vplvxHTmSaIY5umFPPVNONVKi5l1eCzDikNtX8nAFB)RvpNsKhFl1HpyOaIY5umFbfioB28fqmNNOuD2bwkece3c30y3syaAmaqCcWaaXDaCpqmwPKgva8biUbhdHtceRqjckkbfYmeovqNZtukbZYweFJINVHYxU(2(xREoLip(wQdFWqbeLZPy(gLV34ljs(QqjckkbfYmeovqNZtukbZYweFJY3taXzZMVaIPqMHWPc6mdorqG4w4Mg7wcdqJbaItagaiOJa3deJvkPrfaFaIBWXq4KaXT)1QNtjYJVL6Whmuar5CkMVr77n(Y1xfkrqrjOqMHWPc6CEIsjyw2I4Bu(EcioB28fqmfYmeovqNzWjcce3c30y3syaAmaqCcWaaXza4EGySsjnQa4dqCdogcNeioB2ag7Q3euiZq4ubDoprP8nAE(2c30yhluEqMVC9vHseuuckKziCQGoNNOucMLTi(gLVNhioB28fqmfYmeovqNzWjcceRqwdoh28fq89xdZ3H5lsrHnBaJ6W(snAnc9LZ10U8LnYmFPZ7uSVfsyWuhIVseMVSRNqR89aIGXY8n9L1WkHZ7lNleI(AxOVPs9LVxjZ36TRPc81EFHy7LLXsjamadWaIbJq28fai4NE8Zp9c1j(cGyojSMkGbedYcYpNG4CdIZHq7RV3FH(oYhp08L6H(sE(yNHgXb5(cr(MyGOYx2lJ(Me2lNgQ8TDLvaYeoTG0uOVNcTVN9lWi0qLVKBPgltqFY91EFj3snwMG(cSsjnQi3xYorxqfoTG0uOV8hAFp7xGrOHkFjhsui1ddqb9j3x79LCirHupmaf0xGvkPrf5(s2j6cQWPfKMc99ocTVN9lWi0qLVKBPgltqFY91EFj3snwMG(cSsjnQi3xY4NUGkCADAbzb5NtqCUbX5qO9137VqFh5JhA(s9qFjpFSlrazg5(cr(MyGOYx2lJ(Me2lNgQ8TDLvaYeoTG0uOVHk0(E2VaJqdv(sULASmb9j3x79LCl1yzc6lWkL0OICFjlu0fuHtlinf675dTVN9lWi0qLVKdjkK6HbOG(K7R9(soKOqQhgGc6lWkL0OICFj7eDbv4060cYcYpNG4CdIZHq7RV3FH(oYhp08L6H(sUbNkcAmY9fI8nXarLVSxg9njSxonu5B7kRaKjCAbPPqFpfAFp7xGrOHkFj3snwMG(K7R9(sULASmb9fyLsAurUVKDIUGkCAbPPqFVJq77z)cmcnu5l5gCQiOjojOp5(AVVKBWPIGMWojOp5(swOOlOcNwqAk037i0(E2VaJqdv(sUbNkcAc(f0NCFT3xYn4urqty8lOp5(sg)0fuHtlinf6lDm0(E2VaJqdv(sUbNkcAItc6tUV27l5gCQiOjStc6tUVKXpDbv40cstH(shdTVN9lWi0qLVKBWPIGMGFb9j3x79LCdove0eg)c6tUVKfk6cQWPfKMc99meAFp7xGrOHkFj3GtfbnXjb9j3x79LCdove0e2jb9j3xYorxqfoTG0uOVNHq77z)cmcnu5l5gCQiOj4xqFY91EFj3GtfbnHXVG(K7lz8txqfoTG0uOV8fH23Z(fyeAOYxYn4urqtCsqFY91EFj3GtfbnHDsqFY9Lm(PlOcNwqAk0x(Iq77z)cmcnu5l5gCQiOj4xqFY91EFj3GtfbnHXVG(K7lzNOlOcNwNwqwq(5eeNBqCoeAF99(l03r(4HMVup0xYdWcHtJCFHiFtmqu5l7LrFtc7Ltdv(2UYkazcNwqAk03tH23Z(fyeAOYxYHefs9WauqFY91EFjhsui1ddqb9fyLsAurUVKDIUGkCAbPPqF5p0(E2VaJqdv(sULASmb9j3x79LCl1yzc6lWkL0OICFj7eDbv40cstH(YFO99SFbgHgQ8LCirHupmaf0NCFT3xYHefs9WauqFbwPKgvK7lzNOlOcNwqAk0x(dTVN9lWi0qLVK3(srmMG(K7R9(sE7lfXyc6lWkL0OICFj7eDbv40cstH(gQq77z)cmcnu5l5qIcPEyakOp5(AVVKdjkK6HbOG(cSsjnQi3xYorxqfoTG0uOV3eAFp7xGrOHkFjhsui1ddqb9j3x79LCirHupmaf0xGvkPrf5(s2j6cQWP1PfKfKFobX5geNdH2xFV)c9DKpEO5l1d9L82dgRSmg5(cr(MyGOYx2lJ(Me2lNgQ8TDLvaYeoTG0uOVNcTVN9lWi0qLVKBPgltqFY91EFj3snwMG(cSsjnQi3xYorxqfoTG0uOVHk0(E2VaJqdv(sULASmb9j3x79LCl1yzc6lWkL0OICFj7eDbv40cstH(gQq77z)cmcnu5l5SNqlnLsqFY91EFjN9eAPPuc6lWkL0OICFj7eDbv40cstH(E(q77z)cmcnu5l5wQXYe0NCFT3xYTuJLjOVaRusJkY9LSt0fuHtlinf675dTVN9lWi0qLVKZEcT0ukb9j3x79LC2tOLMsjOVaRusJkY9LSt0fuHtlinf67nH23Z(fyeAOYxYHefs9WauqFY91EFjhsui1ddqb9fyLsAurUVKXpDbv40cstH(EtO99SFbgHgQ8LC2tOLMsjOp5(AVVKZEcT0ukb9fyLsAurUVKDIUGkCAbPPqFPJH23Z(fyeAOYxYTuJLjOp5(AVVKBPgltqFbwPKgvK7lzNOlOcNwqAk0x(Iq77z)cmcnu5l5SNqlnLsqFY91EFjN9eAPPuc6lWkL0OICFjJF6cQWP1PfKfKFobX5geNdH2xFV)c9DKpEO5l1d9L8di2EzP0i3xiY3edev(YEz03KWE50qLVTRScqMWPfKMc998H23Z(fyeAOYxYTuJLjOp5(AVVKBPgltqFbwPKgvK7BA(EUotGKVKDIUGkCAbPPqFVj0(E2VaJqdv(gpYN1xw4Ys66lidiJV27lirK(k)kcnbZ3)aHP9qFjdKbuFj7eDbv40cstH(EtO99SFbgHgQ8LCdove0eNe0NCFT3xYn4urqtyNe0NCFjJF6cQWPfKMc99ocTVN9lWi0qLVXJ8z9LfUSKU(cYaY4R9(csePVYVIqtW89pqyAp0xYaza1xYorxqfoTG0uOV3rO99SFbgHgQ8LCdove0e8lOp5(AVVKBWPIGMW4xqFY9Lm(PlOcNwqAk0x6yO99SFbgHgQ8nEKpRVSWLL01xqgFT3xqIi9vnGh28LV)bct7H(sgna1xY4NUGkCAbPPqFPJH23Z(fyeAOYxYn4urqtCsqFY91EFj3GtfbnHDsqFY9LSZtxqfoTG0uOV0Xq77z)cmcnu5l5gCQiOj4xqFY91EFj3GtfbnHXVG(K7lz3qxqfoTG0uOVNHq77z)cmcnu5l5wQXYe0NCFT3xYTuJLjOVaRusJkY9LSt0fuHtlinf67zi0(E2VaJqdv(sE7lfXyc6tUV27l5TVueJjOVaRusJkY9nnFpxNjqYxYorxqfoTG0uOV8fH23Z(fyeAOYxYHefs9WauqFY91EFjhsui1ddqb9fyLsAurUVP5756mbs(s2j6cQWPfKMc9LVi0(E2VaJqdv(soKOqQhgGc6tUV27l5qIcPEyakOVaRusJkY9LSt0fuHtRtlili)CcIZniohcTV(E)f67iF8qZxQh6l5T)1QNtXi3xiY3edev(YEz03KWE50qLVTRScqMWPfKMc9L)q77z)cmcnu5l5wQXYe0NCFT3xYTuJLjOVaRusJkY9Lm(PlOcNwqAk0x(dTVN9lWi0qLVKdjkK6HbOG(K7R9(soKOqQhgGc6lWkL0OICFjJF6cQWPfKMc9L)q77z)cmcnu5l5SNqlnLsqFY91EFjN9eAPPuc6lWkL0OICFjJF6cQWPfKMc99ocTVN9lWi0qLVKBPgltqFY91EFj3snwMG(cSsjnQi3xYorxqfoTG0uOVNHq77z)cmcnu5l5wQXYe0NCFT3xYTuJLjOVaRusJkY9LSt0fuHtRtlili)CcIZniohcTV(E)f67iF8qZxQh6l5byHWP1Zhj3xiY3edev(YEz03KWE50qLVTRScqMWPfKMc99uO99SFbgHgQ8LCl1yzc6tUV27l5wQXYe0xGvkPrf5(s2j6cQWPfKMc9L)q77z)cmcnu5l5qIcPEyakOp5(AVVKdjkK6HbOG(cSsjnQi3xYorxqfoToTGSG8Zjio3G4Ci0(679xOVJ8XdnFPEOVKRqQKqBK7le5BIbIkFzVm6BsyVCAOY32vwbit40cstH(gQq77z)cmcnu5l5wQXYe0NCFT3xYTuJLjOVaRusJkY9LSqrxqfoTG0uOVNp0(E2VaJqdv(sULASmb9j3x79LCl1yzc6lWkL0OICFjJF6cQWPfKMc9LogAFp7xGrOHkFj3snwMG(K7R9(sULASmb9fyLsAurUVKfk6cQWPfKMc9LVi0(E2VaJqdv(sULASmb9j3x79LCl1yzc6lWkL0OICFj7eDbv40cstH(EIEH23Z(fyeAOY34r(S(YcxwsxFbz81EFbjI0x1aEyZx((himTh6lz0auFj7eDbv40cstH(EIEH23Z(fyeAOYxYTuJLjOp5(AVVKBPgltqFbwPKgvK7lz8txqfoTG0uOVNofAFp7xGrOHkFj3snwMG(K7R9(sULASmb9fyLsAurUVKDIUGkCAbPPqFpXFO99SFbgHgQ8LCirHupmaf0NCFT3xYHefs9WauqFbwPKgvK7lzNOlOcNwqAk03tNp0(E2VaJqdv(sULASmb9j3x79LCl1yzc6lWkL0OICFj7eDbv40cstH(Y)Pq77z)cmcnu5l5wQXYe0NCFT3xYTuJLjOVaRusJkY9Lm(PlOcNwqAk0x(dvO99SFbgHgQ8LCl1yzc6tUV27l5wQXYe0xGvkPrf5(sg)0fuHtRt75w(4HgQ89e98nB28LV6HzmHtlqCsyxpeioEKj0PnFDwyszaXhWNA0iq8DVRV0jM2LVNJRj4Y89oRUEDyN27ExFVZNH9905dXx(Ph)87060E3767zVYkazH2P9U31x(QVGC1zKGzYyzmFT3x6SOtAqNi1OrAqNyAxmFPtc0x799lDyFBprz(AjmanMVCUEFti6ls3dSzOYx79vpGrF1Ff4lwprWLV27RCAgc9LS8XodnIdFV7jqfoT39U(Yx9LohwkPrLVXzdoutBsTV3PSz(kHTKGH(QWu5BW1tOz(kNrqFPEOVSu5lDEoMjCAV7D9LV67DgBQaFbzFIs5B8bwke6Bkn6XgK5R8drFP0iDhjDyFjlnFppn9LzzlcZ3PygMkFFkFVHMGYxQV05Dk23cjmyQ9nlLVYzyFpGiySmFzVm6B98vi28LngrAZxmHt7DVRV8vFVZytf4lFzKziCQaFJn4eb9DkFb5NPZLVdLVHFcFVsWOV1Bxtf4lQzOV27R69nlLVC(ICZ3hmcB5HVCEIsX8Dy(sN3PyFlKWGPw40E376lF13ZELvaQ8voRW(so1eCzDikNtXi332xQXMVsnZx79npo0H9DkFLEgZxQj4Yy((LoSVKPrgZ3ZsN(Yjzg67x(AWKDbQWP9U31x(QVGCLcv(M1Bxi03ZeHjbXmIVyzWW(AVVm08L4WxMb)kaH(EUogfkpnMWP9U31x(QVNtuN013479fmt4li)mDU8v)btZx2un03X8fI6bz((LVTVOsjcDAOYxyoQocglJjCAV7D9LV679Nj68mfAF9LVC2Sh6BSbXkWU89a(nMVtzVVgCQiO5R(dMMWP1PnB28ftCaX2llLgn5rJJ3MVCAZMnFXehqS9YsPrtE0aMdd7kmvoTzZMVyIdi2EzP0OjpAqPr2vdMuMtB2S5lM4aITxwknAYJgjuoC)P62f2vyQc5aITxwkTUnYiVqfYqX7wl1yzcgHS8x9Geg8H1Ot7D99Cbo1ePHmFtFn4urqJ5B7FT65uH4RAapku5RuyFp)ncFV)Ay(Yjz(2UEgw(MmFjQRxh2xopmcZ3V89834ldBFP8vIaYmFBHBAKfIVseMVxjZx7FFLZkSVnf0xKIcBgZx79nyaJ(M(2(xREoLGUcfbmT5lFvd4H9qFNIzyQe(EUP8DmYz(co1eOVxjZ369fIY5uke6lency57Pq8f1m0xiAeWYx6jUr40MnB(IjoGy7LLsJM8Ob4eoPKgdPszKNbNkcA9tDw4QfYFWJH2qfc4utG8ofc4utGDuZqE0tCtiTVuJnFXZGtfbnXjXvY6emSlrqrXLmdove0eNeT)1QNtjueW0MVazazo)n8OhOoTzZMVyIdi2EzP0OjpAaoHtkPXqQug5zWPIGwN)olC1c5p4XqBOcbCQjqENcbCQjWoQzip6jUjK2xQXMV4zWPIGMGFXvY6emSlrqrXLmdove0e8lA)RvpNsOiGPnFbYaYC(B4rpqDAVRVNlMnYPHmFtFn4urqJ5l4utG(kf232lFKWPc81UqFB)RvpNY3NYx7c91GtfbTq8vnGhfQ8vkSV2f6RIaM28LVpLV2f6RebfLVJ57b8bpkKj89oxY8n9LzqScSlFLF1qni0x79nyaJ(M(Enbxi03d48WXc7R9(Ymiwb2LVgCQiOXcX3K5lhuR9nz(M(k)QHAqOVup03HY30xdove08LZO1((qF5mATV1B(YcxnF5m2LVT)1QNtXeoTzZMVyIdi2EzP0OjpAaoHtkPXqQug5zWPIGw)aopCSWH8h8yOnuHao1eip(dbCQjWoQziVtH0(sn28fVBn4urqtCsCLSobd7seuuCn4urqtWV4kzDcg2LiOOirYGtfbnb)IRK1jyyxIGIIlzKzWPIGMGFr7FT65ucfbmT5lqgYm4urqtWVqIGIQRiGPnFfnFj0tqVtGckDGStIBOPbNkcAc(fxjRlrqrbkDGmWjCsjnkm4urqRZFNfUAGcA0KrMbNkcAItI2)A1ZPekcyAZxGmKzWPIGM4KqIGIQRiGPnFfnFj0tqVtGckDGStIBOPbNkcAItIRK1LiOOaLoqg4eoPKgfgCQiO1p1zHRgOG60ExFpxGtnrAiZ3gbeIL5ldnIdFPEOV2f6lFtKLnwyFFkFb5hFl1HpyOVNLopN(IuuyZyoTzZMVyIdi2EzP0OjpAaoHtkPXqQug5rrO19Mcgc4utG8SuJLjsOC4(t1TlSRs5cvCBFPigt0(c83sB(Q)uD7c7kmvoTzZMVyIdi2EzP0OjpAaoHtkPXqQug5PADOfc4utG8Gefs9WauOW0Uy9gcTCklmxirHupmafWu(ilRBWSyuieRg6060E37675IUyJWqLViyeg2xBKrFTl03Szp03H5BcohDkPrHtB2S5lgp5PuDkiINz0P9U(ENGiySmFzhyBOgu5RbNkcAmFLWPc8LGHkF5m2LVjH9YPnnF1tHmN2SzZxmAYJgGt4KsAmKkLrESdSnudQ6gCQiOfc4utG8id5BI54avIPyniHLsASZ3ezzeYDfcEAijsiFtmhhOsyxyNAGmRZMGrtIeY3eZXbQepyeY5c1Ytf0pEoiS3GHzwQbLlzT)1QNtjMI1GewkPXoFtKLri3vi4PHciMQWKi1(xREoLWUWo1azwNnbJwar5CkgjsT)1QNtjEWiKZfQLNkOF8CqyVbdZSulGOCofdusKid5BI54avc7c7udKzD2emAsKq(MyooqL4bJqoxOwEQG(XZbH9gmmZsnOCr(MyooqLykwdsyPKg78nrwgHCxHGNg60E37675OeoPKgzoTzZMVy0KhnaNWjL0yivkJ8o(xpvqhsutRF8CqyiGtnbYR9Vw9CkbJqw(REqcd(WAuar5Ckwu3W1snwMGril)vpiHbFynYLml1yzcI661H7s6j4Y42(xREoLGOUED4UKEcUmbeLZPyrDkuCB)RvpNsOsyKUbZIr9q50MVequoNI1r6EGndvrDkuKiDRLASmbrD96WDj9eCzG60MnB(IrtE0aCcNusJHuPmY74F9ubDirHSqaNAcKNLASmb7j0DiMhiKlKOWO4NRLWa0e2iJD77hnRhQBI6gUutWL1HOCofl6BirQ9GXkltutWL1PsKRLASmHcPgnYT9Vw9CkHcPgnkGOCoflkirHcBKXU9D(DAZMnFXOjpAaoHtkPXqQug5XS(HoRAQGqaNAcKx2Sbm2XcLhKX7exYUfMJQJGXYePsXeiDhMXircMJQJGXYePsXetf9PBa1PnB28fJM8Ob4eoPKgdPszKxQuSoeLZPcbCQjqEzZgWyhluEqw084Nlz3cZr1rWyzIuPycKUdZyKibZr1rWyzIuPycKUdZyCjdMJQJGXYePsXequoNIf9nKirnbxwhIY5uSOprpqb1PnB28fJM8Ob4eoPKgdPszKNCEgFyV9Vw9CkwpB2agdbCQjqEKzPgltWiKL)QhKWGpSg5E7bAIGeg8H1OiB2ag52(xREoLGril)vpiHbFynkGOCofJePBTuJLjyeYYF1dsyWhwJGYLmjckkbrD96W9KXscTjioirYsnwMiHYH7pv3UWUkLluX9anrE8TEW1tOfzZgWijsseuucvcJ0nywmQhkN28LG4GRebfLqLWiDdMfJ6HYPnFjGOCofl6BirkB2ag7yHYdYIMh)CvyAx9SuDf2YWcBArMkauN2SzZxmAYJgGt4KsAmKkLrEkc5JoNNOuSqaNAcKx7bJvwMOMGlRtLixfM2vplvxHTmSWMwKPc4krqrjuyAxSUIafmlBrI68KijrqrjKti85GQEakZSVWowxz1qzSmbXbjsseuuc7coADNHyeekioirsIGIsqbX6mpOQl)fZGpBSWcIdsKKiOOeAmvDPWDKUP8HgfehKijrqrjAx5Z6szHcIdsKA)RvpNsquxVoCpzSKqBcikNtXI6gUT)1QNtjYJVL6Whmuar5Ckw0NONt7D99oFoLLtnvGVNJgiHglZ37KodiqFhMVPVhW5HJf2PnB28fJM8OXtysqmJeYqXt9Ma8aj0yz9dDgqGcisbr2vkPrU3APgltquxVoCxspbxg3BH5O6iySmrQumbs3HzmN2SzZxmAYJgpHjbXmsiTWnn2TegGgJ3PqgkEQ3eGhiHglRFOZacuarkiYUsjnYnB2ag7yHYdYIMh)Cj7wl1yzcI661H7s6j4YirYsnwMGOUED4UKEcUmUK1(xREoLGOUED4UKEcUmbeLZPyrt2PBazYMnGXowO8GmAQEtaEGeASS(HodiqbeLZPyGsIu2Sbm2XcLhKfnVqbkOoT313ZnLV2fcrFti6lwO8GmFLhgBQaFphDNcX384qh23X8LmjcZ369v(HOV2vw((vd99aH(Eh(YW2xkgOcN2SzZxmAYJgpHjbXmsi6PWEtX7oczO4LnBaJD1BcWdKqJL1p0zabgv2Sbm2XcLhKXnB2ag7yHYdYIMh)Cj7wl1yzcI661H7s6j4YirQ9Vw9CkbrD96WDj9eCzcikNtX4krqrjiQRxhUlPNGlRlrqrjupNcuN2SzZxmAYJgpHjbXmsidfpirHupmafmIdeYmyofxYuVjOGpZ6uiyekGifezxPKgjrs9Mqs)VQFOZacuarkiYUsjncQt7D99CIuqKDHmFPtmTlMV0jbsoZxjckkFpJemZxjK6HOVkmTlMVkc0xSumN2SzZxmAYJgCEIs1zhyPqyidfV2dgRSmrnbxwNkrUkmTREwQUcBzyHnTitfWLmfM2vplvxHTmSiB2ag7quoNIffzbnfD4K4gqjrsIGIsOW0UyDfbkGOCoflQGMcuN2SzZxmAYJgCYXcHHnET)1QNtjypHUdX8aHcikNtXczO4zPgltWEcDhI5bc5AjmanHnYy3((rZ6H6MOUHRLWa0e2iJD77QbJ(gUT)1QNtjypHUdX8aHcikNtXIISGMIoqpbD8gq5MnBaJDSq5bz8o50ExFbzZX8L6H(sNyAxKZ8LojqAqNi1OrFhkFbXeCz(YxorFT33a08LzqScSlFLiOO8vkBr8nz5HtB2S5lgn5rdo5yHWWgV2)A1ZPekmTlwxrGcikNtXczO41EWyLLjQj4Y6ujYT9Vw9CkHct7I1veOaIY5uSOcAkUzZgWyhluEqgVtoTzZMVy0Khn4KJfcdB8A)RvpNsOqQrJcikNtXczO41EWyLLjQj4Y6ujYT9Vw9CkHcPgnkGOCoflQGMIB2Sbm2XcLhKX7Kt7D9fK3S5lFbPHzmFZs57z6aleY8LSZ0bwiKrJyKVjWQHmFjkgXXXdnu57u(Mk1xcqDAZMnFXOjpA0sTUNnB(QRhMfsLYipdove0yoTzZMVy0KhnAPw3ZMnF11dZcPszKx7bJvwgZPnB28fJM8Orl16E2S5RUEywivkJ8GzBsnZP9U313SzZxmAYJgmKVjWQHHmu8YMnGXowO8GmEN4ERct7QhPMGltOgwkPXE(MIRLASmbJqw(REqcd(WAmKkLrEbjmO)hyHWq)eMeeZiHMczgcNkOZm4ebdnfYmeovqNzWjcgAgHS8x9Geg8H1yOtOC4(t1TlSRWufAfM2vV9JoKHINebfLGrOuy1v)lliocTct7Q3(rhAfM2vV9Jo0S2tadWoZGtemKHINcLiOOeuiZq4ubDoprPemlBrI(8HM1Ecya2zgCIGHmu8uOebfLGczgcNkOZ5jkLGzzls0Np0uiZq4ubDMbNiOt7DVRVzZMVy0KhnyiFtGvddzO4LnBaJDSq5bz8oX9wfM2vpsnbxMqnSusJ98nf3BTuJLjyeYYF1dsyWhwJHuPmY7pWcHHMczgcNkOZm4ebdnfYmeovqNzWjcg6J3MVcnrD96WDj9eCzHwLWiDdMfJ6HYPnFf684BPo8bdDAZMnFXOjpA0sTUNnB(QRhMfsLYiV2)A1ZPyoTzZMVy0KhnGevpB28vxpmlKkLrE5JDgAehHmu8aNWjL0OivkwhIY5uCjR9Vw9CkHct7QNLQRWwgwar5CkwuNOh3BTuJLjui1OrsKA)RvpNsOqQrJcikNtXI6e94APgltOqQrJKi1EWyLLjQj4Y6ujYT9Vw9CkHct7I1veOaIY5uSOorpq5ERct7QNLQRWwgwytlYuboTzZMVy0KhnGevpB28vxpmlKkLrE5JDjciZcHzWPz8ofYqXlB2ag7yHYdYIMh)CvyAx9SuDf2YWcBArMkWPnB28fJM8ObKO6zZMV66HzHuPmYlaleoTE(yidfVSzdySJfkpilAE8Z9wfM2vplvxHTmSWMwKPc4s2TGt4KsAuKkfRdr5CksKA)RvpNsOW0U6zP6kSLHfquoNIf9j6X9wl1yzcfsnAKeP2)A1ZPekKA0OaIY5uSOprpUwQXYekKA0ijsThmwzzIAcUSovICB)RvpNsOW0UyDfbkGOCofl6t0duN2SzZxmAYJgTuR7zZMV66HzHuPmYlaleoTqgkEzZgWyhluEqgVtoToT39U(cY)ZLV8HaYmN2SzZxmr(yxIaYmEnDYzQGo7kvphwidfVSzdySJfkpilkE340MnB(IjYh7seqMrtE0OPtotf0zxP65WczO4LnBaJDSq5bz8UdUkmTREKAcUmbfNNOuOQBjmanw08cLtB2S5lMiFSlrazgn5rdoprP6SdSuimKHINLASmHebKztf0zpezCjtHPD1JutWLjO48eLcvDlHbOX4LnBaJDSq5bzKiPW0U6rQj4YeuCEIsHQULWa0yrZluGsIKLASmHebKztf0zpezCTuJLjA6KZubD2vQEomUkmTREKAcUmbfNNOuOQBjmanw08o50MnB(IjYh7seqMrtE0qHPD1B)OdzO4rMebfLGrOuy1v)llGy2msKUfCcNusJIJ)1tf0He106hpheckxYKiOOeQegPBWSyupuoT5lbXbxirHupmafkmv6bzwV9JMB2Sbm2XcLhKffVqrIu2Sbm2XcLhKXJFqDAZMnFXe5JDjciZOjpAGhJcLNwidfpirnT(XZbHcfsnTXIISt0JMkmTREKAcUmbfNNOuOQBjmangDiuGYvHPD1JutWLjO48eLcvDlHbOXI6o4El4eoPKgfh)RNkOdjQP1pEoiKejjckkbJtcLNkOlpmtqC40MnB(IjYh7seqMrtE0apgfkpTqgkEqIAA9JNdcfkKAAJff)3WvHPD1JutWLjO48eLcvDlHbOXI(gU3coHtkPrXX)6Pc6qIAA9JNdcDAZMnFXe5JDjciZOjpAGhJcLNwidfVBvyAx9i1eCzckoprPqv3syaAmU3coHtkPrXX)6Pc6qIAA9JNdcjrIAcUSoeLZPyrDdjsWCuDemwMivkMaP7WmgxyoQocgltKkftar5Ckwu340MnB(IjYh7seqMrtE0GZtuQo7alfcDAZMnFXe5JDjciZOjpAGhJcLNwidfVBbNWjL0O44F9ubDirnT(XZbHoToT39U(cY)ZLVXOrC40MnB(IjYh7m0io4Lv4UQuHmu8uyAx9i1eCzckoprPqv3syaASO51c30yhluEqgjskmTREKAcUmbfNNOuOQBjmanw08UHePBTuJLjKiGmBQGo7HiJejyoQocgltKkftG0DygJlmhvhbJLjsLIjGOCoflkENorIK0ZyCPMGlRdr5Ckwu8oDYPnB28ftKp2zOrCqtE0qHPD1B)OdzO4Dl4eoPKgfh)RNkOdjQP1pEoiKlzseuucvcJ0nywmQhkN28LG4GlKOqQhgGcfMk9GmR3(rZnB2ag7yHYdYIIxOirkB2ag7yHYdY4XpOoTzZMVyI8XodnIdAYJg4XOq5PfYqX7wWjCsjnko(xpvqhsutRF8CqOtB2S5lMiFSZqJ4GM8ObfYmeovqNzWjcgslCtJDlHbOX4DkKHINcLiOOeuiZq4ubDoprPemlBrIIxO42(xREoLip(wQdFWqbeLZPyrfkN2SzZxmr(yNHgXbn5rdkKziCQGoZGtemKw4Mg7wcdqJX7uidfpfkrqrjOqMHWPc6CEIsjyw2Ie1jN2SzZxmr(yNHgXbn5rdkKziCQGoZGtemKw4Mg7wcdqJX7uidfpirHcBKXU99ZhfzT)1QNtjuyAx9SuDf2YWcikNtX4ERLASmHcPgnsIu7FT65ucfsnAuar5Ckgxl1yzcfsnAKeP2dgRSmrnbxwNkrUT)1QNtjuyAxSUIafquoNIbQt7D9fK9clFTegGMVmo5bZ3eI(QgwkPrvi(AxdZxoJw7RgnFd)e(YoWs5lKOqgn48eLI57umdtLVpLVCYXMkWxQh6lDw0jnOtKA0inOtmTlYz(sNeOWPnB28ftKp2zOrCqtE0GZtuQo7alfcdzO4r2Tm0SPcyIw4MgjrsHPD1JutWLjO48eLcvDlHbOXIMxlCtJDSq5bzGYvHseuuckKziCQGoNNOucMLTirhkUqIcf2iJD77HkQ2)A1ZPezfURkLaIY5umNwN27ExFVtVnF50MnB(IjA)RvpNIX74T5RqgkEGt4KsAuiNNXh2B)RvpNI1ZMnGrsKoqteKWGpSgfzZgWi3d0ebjm4dRrbeLZPyrXJ)7GejPNX4snbxwhIY5uSO4)oCAV7D99S)RvpNI50MnB(IjA)RvpNIrtE0iHYH7pv3UWUctvidfV2)A1ZPeQegPBWSyupuoT5lbeLZPyDKUhyZqvu0rUK1(xREoLGOUED4UKEcUmbeLZPyrrh5APgltquxVoCxspbxgjs3APgltquxVoCxspbxgOCjJHwx6lcMWgeY)zOF(JgxlHbOjSrg723pAwpu3e15jr6wgADPViycBqi)NH(5pAKirnbxwhIY5uSO5NE0duUK1(xREoLiLE5PsB(QRhzjbeLZPyrD6mWLmirHupmafP0lpvAZxSofeRZCysKypHwAkLiccEkw))ZmQNkausKUfsui1ddqrk9YtL28fRtbX6mhM7TSNqlnLsebbpfR))zg1tfakxYA)RvpNsKhFl1HpyOaIY5uSos3dSzOkk6ixWjCsjnkOi06Etbjr6wWjCsjnkOi06EtbjrcCcNusJcvRdnqjrs6zmUutWL1HOCoflQqDJtB2S5lMO9Vw9Ckgn5rd2tO7qmpqyiTWnn2TegGgJ3PqgkEwcdqtyJm2TVF0SEOUjQB4sMLWa0e2iJD77QbJ(gUzZgWyhluEqwu8cfjsm06sFrWe2Gq(pd9ZF04krqrjujms3GzXOEOCAZxcIdUzZgWyhluEqwu8UHlz3QW0U6zP6kSLHf20ImvajsThmwzzIAcUSovIGcQt7D99o3RvmF5JEcUmFPEOVeh(AVV34ldBFPy(AVVSWvZxoJD5li)4BPo8bddX3ZKDHqodddXxcg6lNXU8LotyeFVhMfJ6HYPnFjCAZMnFXeT)1QNtXOjpAquxVoCxspbxwidfpWjCsjnkyw)qNvnvaxYA)RvpNsKhFl1HpyOaIY5uSos3dSzOkQBirQ9Vw9CkrE8Tuh(GHcikNtX6iDpWMHQOprpq5sw7FT65ucvcJ0nywmQhkN28LaIY5uSOcAksKKiOOeQegPBWSyupuoT5lbXbOoTzZMVyI2)A1ZPy0KhniQRxhUlPNGllKHIh4eoPKgfPsX6quoNIejPNX4snbxwhIY5uSO4)KtB2S5lMO9Vw9Ckgn5rdvcJ0nywmQhkN28vidfpWjCsjnkyw)qNvnvaxYuVjiQRxhUlPNGlRREtar5Ckgjs3APgltquxVoCxspbxgOoTzZMVyI2)A1ZPy0Khnujms3GzXOEOCAZxHmu8aNWjL0OivkwhIY5uKij9mgxQj4Y6quoNIff)NCAZMnFXeT)1QNtXOjpAKhFl1HpyyidfVSzdySJfkpiJ3jUkuIGIsqHmdHtf058eLsWSSfjAENNlz3coHtkPrbfHw3BkijsGt4KsAuqrO19McYLS2)A1ZPee11Rd3L0tWLjGOCofl6t0JeP2)A1ZPeQegPBWSyupuoT5lbeLZPyDKUhyZqv0NOh3BTuJLjiQRxhUlPNGlduqDAZMnFXeT)1QNtXOjpAKhFl1HpyyiTWnn2TegGgJ3PqgkEzZgWyhluEqw084NRcLiOOeuiZq4ubDoprPemlBrIM355ERct7QNLQRWwgwytlYuboTzZMVyI2)A1ZPy0KhnyeYYF1dsyWhwJHmu8Ge106hphekui10glQtNNB7FT65ucI661H7s6j4YequoNIf1PqXT9Vw9CkHkHr6gmlg1dLtB(sar5CkwhP7b2muf1Pq50MnB(IjA)RvpNIrtE0GOUED4EYyjH2czO4boHtkPrbZ6h6SQPc4QqjckkbfYmeovqNZtukbZYwKO4NlzhOjYJV1dUEcTiB2agjrsIGIsOsyKUbZIr9q50MVeehCB)RvpNsKhFl1HpyOaIY5uSOprpsKA)RvpNsKhFl1HpyOaIY5uSOprpUT)1QNtjujms3GzXOEOCAZxcikNtXI(e9a1PnB28ft0(xREofJM8ObrD96W9KXscTfslCtJDlHbOX4DkKHIx2Sbm2XcLhKfnp(5QqjckkbfYmeovqNZtukbZYwKO4NlzhOjYJV1dUEcTiB2agjrsIGIsOsyKUbZIr9q50MVeehKi1(xREoLqHPD1Zs1vyldlGOCoflQGMcuN2SzZxmr7FT65umAYJgWCyyxHPkKHI3ThOjcUEcTiB2agDAV7D9LohwkPrvi(EgjyMV1B(cXuRd7B9q5u7ReELGNh6RDLg5mF58q7Y3dciJyQaFNIVgKYOWP9U313SzZxmr7FT65umAYJgSSbhQPnPUFKnlKHIx2Sbm2XcLhKfnp(5ERebfLqLWiDdMfJ6HYPnFjio42(xREoLqLWiDdMfJ6HYPnFjGOCofl6Birs6zmUutWL1HOCoflQGMYP1P9U313Z(GXklZxqU0OhBqMtB2S5lMO9GXklJXJXjHYtf0LhMfYqXdCcNusJcM1p0zvtfWfsutRF8CqOqHutBSOpDhCjR9Vw9CkrE8Tuh(GHcikNtXir6wl1yzIekhU)uD7c7QuUqf32)A1ZPeQegPBWSyupuoT5lbeLZPyGsIK0ZyCPMGlRdr5CkwuNo50ExFJrZx79LGH(Mugc9np(MVdZ3V89S0PVjZx799aIGXY89bJWwECmvGVNZ7KVCUgn6ldnBQaFjo89S0j5mN2SzZxmr7bJvwgJM8ObJtcLNkOlpmlKHIx7FT65uI84BPo8bdfquoNIXLSSzdySJfkpilAE8ZnB2ag7yHYdYII3nCHe106hphekui10gl6t0JMKLnBaJDSq5bz0H7auUGt4KsAuKkfRdr5CksKYMnGXowO8GSOVHlKOMw)45GqHcPM2yrFE6bQtB2S5lMO9GXklJrtE0iLE5PsB(QRhzPqgkEGt4KsAuWS(HoRAQaU3YEcT0ukHgtvxkChPBkFOrUK1(xREoLip(wQdFWqbeLZPyKiDRLASmrcLd3FQUDHDvkxOIB7FT65ucvcJ0nywmQhkN28LaIY5umq5cjkuyJm2TVF(OLiOOeqIAA92dHeh28LaIY5umsKKEgJl1eCzDikNtXII)toTzZMVyI2dgRSmgn5rJu6LNkT5RUEKLczO4boHtkPrbZ6h6SQPc4YEcT0ukHgtvxkChPBkFOrUKPEtquxVoCxspbxwx9MaIY5uSOpDIePBTuJLjiQRxhUlPNGlJB7FT65ucvcJ0nywmQhkN28LaIY5umqDAZMnFXeThmwzzmAYJgP0lpvAZxD9ilfYqXdCcNusJcM1p0zvtfWL9eAPPuIii4Py9)pZOEQaUKPqjckkbfYmeovqNZtukbZYwKO5DEU3cjkK6HbOiLE5PsB(I1PGyDMdtIeKOqQhgGIu6LNkT5lwNcI1zom32)A1ZPe5X3sD4dgkGOCofduN2SzZxmr7bJvwgJM8Ork9YtL28vxpYsHmu8aNWjL0OivkwhIY5uCHefkSrg723pF0seuucirnTE7HqIdB(sar5CkMtB2S5lMO9GXklJrtE0GDLTiASBxyNO48q7kCidfpWjCsjnkyw)qNvnvaxYA)RvpNsKhFl1HpyOaIY5uSOprpsKU1snwMiHYH7pv3UWUkLluXT9Vw9CkHkHr6gmlg1dLtB(sar5CkgOKij9mgxQj4Y6quoNIf1PBCAZMnFXeThmwzzmAYJgSRSfrJD7c7efNhAxHdzO4boHtkPrrQuSoeLZP4sMct7QNLQRWwgwytlYubKibZr1rWyzIuPycikNtXII3PZdQtB2S5lMO9GXklJrtE0GsJSRgmPSqgkESNqlnLsCqWmcn2riXHnFrIe7j0stPeGFDAJg7SxdglJ7TseuucWVoTrJD2RbJL1ViKZ6hLG4iKPmecjoS(ilJQjnK3PqMYqiK4W6b6xk18ofYugcHehwFO4XEcT0ukb4xN2OXo71GXYCADAV7D9nEQan679jmanN2SzZxmrawiCA8uyAx92p6qgkE3coHtkPrXX)6Pc6qIAA9JNdc5sMebfLGrOuy1v)llGy2msKGe106hphekui10glkENcfnjdsui1ddqbmLpYY6gmlgfcXQH0HqrtfM2vpsnbxMasui1ddqXvyMHWjPdHcuqjr6anrqcd(WAuKnBaJCHefgfVqrIe1eCzDikNtXI6e94ERcLiOOeuiZq4ubDoprPeehoTzZMVyIaSq40OjpAKv4UQuHmu8iZsnwMqHuJgfyLsAurIu7bJvwMOMGlRtLijsqIcPEyakoUWe(YFHmq5sgz3coHtkPrXX)6Pc6qIczKi1EWyLLjQj4Y6ujY1snwMqHuJg52(srmMGZyxiCQGEa8jkfOKij9mgxQj4Y6quoNIf1nG60MnB(IjcWcHtJM8ObNNOuD2bwkegYqXdCcNusJcfH8rNZtukgxfkrqrjOqMHWPc6CEIsjyw2IenVtCB)RvpNsKhFl1HpyOaIY5uSos3dSzOk6t3Wxjdsui1ddqHctLEqM1B)OPdNOhOCVfCcNusJIJ)1tf0HefYCAZMnFXebyHWPrtE0GZtuQo7alfcdzO4PqjckkbfYmeovqNZtukbZYwKOdf3BbNWjL0O44F9ubDirHmsKuOebfLGczgcNkOZ5jkLG4Gl1eCzDikNtXIImfkrqrjOqMHWPc6CEIsjyw2IqhcAkqDAZMnFXebyHWPrtE0qHPD1B)OdzO4bjQP1pEoiuOqQPnwu84NE0KmirHupmafWu(ilRBWSyuieRgshopnvyAx9i1eCzcirHupmafxHzgcNKoCEq5El4eoPKgfh)RNkOdjQP1pEoi0PnB28fteGfcNgn5rdkKziCQGoZGtemKHINcLiOOeuiZq4ubDoprPemlBrI68CVfCcNusJIJ)1tf0HefYCAZMnFXebyHWPrtE0qHPD1B)OdzO4Dl4eoPKgfh)RNkOdjQP1pEoi0PnB28fteGfcNgn5rdoprP6SdSuimKHINcLiOOeuiZq4ubDoprPemlBrIM3jUqIcJIFU3coHtkPrXX)6Pc6qIczCB)RvpNsKhFl1HpyOaIY5uSos3dSzOk6BCADAV7D99CaleonFb5)5Y37eCE4yHDAZMnFXebyHWP1Zh5Xjhleg241(xREoLG9e6oeZdekGOCoflKHINLASmb7j0DiMhiKRLWa0e2iJD77hnRhQBI6gUutWL1HOCofl6B42(xREoLG9e6oeZdekGOCoflkYcAk6a9e0XBaLB2Sbm2XcLhKffVq50MnB(IjcWcHtRNpstE0qHPD1B)OdzO4r2TGt4KsAuC8VEQGoKOMw)45GqsKKiOOemcLcRU6FzbeZMbkxYKiOOeQegPBWSyupuoT5lbXbxirHupmafkmv6bzwV9JMB2Sbm2XcLhKffVqrIu2Sbm2XcLhKXJFqDAZMnFXebyHWP1ZhPjpAGhJcLNwidfpjckkbJqPWQR(xwaXSzKiDl4eoPKgfh)RNkOdjQP1pEoi0P9U(EUP81syaA(2c30tf47W8vnSusJQq8LXzS2LVszlIV27RDH(YMkqJ8vlHbO5BawiCA(QhM57umdtLWPnB28fteGfcNwpFKM8ObKO6zZMV66HzHuPmYlaleoTqygCAgVtHmu8AHBASJfkpiJ3jN2SzZxmrawiCA98rAYJgCEIs1zhyPqyiTWnn2TegGgJ3PqgkEK1(xREoLip(wQdFWqbeLZPyrFdxfkrqrjOqMHWPc6CEIsjioirsHseuuckKziCQGoNNOucMLTirhkq5sg1eCzDikNtXIQ9Vw9CkHct7QNLQRWwgwar5CkgnprpsKOMGlRdr5Ckw0T)1QNtjYJVL6Whmuar5CkgOoTzZMVyIaSq4065J0KhnOqMHWPc6mdorWqAHBASBjmangVtHmu8uOebfLGczgcNkOZ5jkLGzzlsu8cf32)A1ZPe5X3sD4dgkGOCoflQBirsHseuuckKziCQGoNNOucMLTirDYPnB28fteGfcNwpFKM8ObfYmeovqNzWjcgslCtJDlHbOX4DkKHIx7FT65uI84BPo8bdfquoNIf9nCvOebfLGczgcNkOZ5jkLGzzlsuNCAVRV3FnmFhMViff2SbmQd7l1O1i0xoxt7Yx2iZ8LoVtX(wiHbtDi(kry(YUEcTY3dicglZ30xwdReoVVCUqi6RDH(Mk1x(ELmFR3UMkWx79fITxwglLWPnB28fteGfcNwpFKM8ObfYmeovqNzWjcgYqXlB2ag7Q3euiZq4ubDoprPIMxlCtJDSq5bzCvOebfLGczgcNkOZ5jkLGzzlsuN3P1P9U(EoZ2KAMtB2S5lMaMTj1mEjSLf2ThcXYczO4bjQP1pEoiuOqQPnw03XnCj7anrqcd(WAuKnBaJKiDRLASmbJqw(REqcd(WAuGvkPrfOCHefkui10glAE340MnB(IjGzBsnJM8OHK(FvNIagoKHIh4eoPKgfY5z8H92)A1ZPy9SzdyKePd0ebjm4dRrr2SbmY9anrqcd(WAuar5Ckwu8KiOOes6)vDkcyyHIaM28fjsspJXLAcUSoeLZPyrXtIGIsiP)x1PiGHfkcyAZxoTzZMVycy2MuZOjpAiHqgcJmvqidfpWjCsjnkKZZ4d7T)1QNtX6zZgWijshOjcsyWhwJISzdyK7bAIGeg8H1OaIY5uSO4jrqrjKqidHrMkqOiGPnFrIK0ZyCPMGlRdr5Ckwu8KiOOesiKHWitfiueW0MVCAZMnFXeWSnPMrtE0qpbxgRFgjubYyzHmu8KiOOee11Rd3zgeRa7sqC40ExFb5vdzgm1(E2uR9TLLVgCccqOVN33J3WYMu7RebffleFXSD5Roz2ub(E6gFzy7lft47DMn65mJkFVsOY32RqLV2iJ(MmFtFn4eeGqFT33iiE47y(cXuLsAu40MnB(IjGzBsnJM8OrwnKzWu3BPwhYqXdCcNusJc58m(WE7FT65uSE2SbmsI0bAIGeg8H1OiB2ag5EGMiiHbFynkGOCoflkENUHejPNX4snbxwhIY5uSO4D6gN2SzZxmbmBtQz0KhnsyllSFqOzyidfVSzdySJfkpilAE8tIezqIcfkKAAJfnVB4cjQP1pEoiuOqQPnw08Ud6bQtB2S5lMaMTj1mAYJgudeL0)RczO4boHtkPrHCEgFyV9Vw9CkwpB2agjr6anrqcd(WAuKnBaJCpqteKWGpSgfquoNIffpjckkb1arj9)kHIaM28fjsspJXLAcUSoeLZPyrXtIGIsqnqus)VsOiGPnF50MnB(IjGzBsnJM8OHug0FQUbNwewidfVSzdySJfkpiJ3jUKjrqrjiQRxhUZmiwb2LG4GejPNX4snbxwhIY5uSOUbuNwN27ExFVhove0yoTzZMVycdove0y8iyyFmuoKkLrEtXAqclL0yNVjYYiK7ke80WqgkEK1(xREoLGOUED4UKEcUmbeLZPyrZp9irQ9Vw9CkHkHr6gmlg1dLtB(sar5CkwhP7b2mufn)0duUKLnBaJDSq5bzrZJFsKoqtKq5W9GRNqlYMnGrsKoqtKhFRhC9eAr2SbmYLml1yzcI661H7jJLeAJejfM2vpsnbxMqnSusJ98nfOKiDGMiiHbFynkYMnGrqjrs6zmUutWL1HOCoflk(prIKct7QhPMGltOgwkPX(W3QosxSryip6X1syaAcBKXU99JM15NErDJtB2S5lMWGtfbngn5rdcg2hdLdPszKxqcg19NQBxyNAGmRNqPXqOtB2S5lMWGtfbngn5rdcg2hdLdPszKhRLqw)P6uW0qyL6oZGdf60MnB(Ijm4urqJrtE0GGH9Xq5qQug5zxyNAGmRZMGrhYqXdCcNusJc58m(WE7FT65uSE2SbmYLmBKXOdf9ir6wKVjMJdujMI1GewkPXoFtKLri3vi4PHG60MnB(Ijm4urqJrtE0GGH9Xq5qQug59GriNlulpvq)45GWEdgMzPoKHIh4eoPKgfY5z8H92)A1ZPy9SzdyKlz2iJrhk6rI0TiFtmhhOsmfRbjSusJD(MilJqURqWtd5ElY3eZXbQe2f2PgiZ6Sjy0G60ExFV)c91GtfbnF5m2LV2f671eCHmZxKzJCAOYxWPMadXxoJw7Re6lbdv(snqM5BwkFpYbIkF5m2LVG8JVL6Whm0xYgkFLiOO8Dy(E6gFzy7lfZ3h6Rgzmq99H(Yh9eCz0GoV3xYgkFdGyAi0x7klFpDJVmS9LIbQtB2S5lMWGtfbngn5rddove0ofYqX7wWjCsjnkyhyBOgu1n4urqJlzKzWPIGM4KqIGIQRiGPnFffVt3WT9Vw9CkrE8Tuh(GHcikNtXIMF6rIKbNkcAItcjckQUIaM28v0NUHlzT)1QNtjiQRxhUlPNGltar5Ckw08tpsKA)RvpNsOsyKUbZIr9q50MVequoNI1r6EGndvrZp9aLePSzdySJfkpilAE8ZvIGIsOsyKUbZIr9q50MVeehGYLSBn4urqtWV4kz92)A1ZPirYGtfbnb)I2)A1ZPequoNIrIe4eoPKgfgCQiO1pGZdhlmVtGckjsspJX1GtfbnXjHebfvxratB(kAEutWL1HOCofZPnB28ftyWPIGgJM8OHbNkcA8hYqX7wWjCsjnkyhyBOgu1n4urqJlzKzWPIGMGFHebfvxratB(kkENUHB7FT65uI84BPo8bdfquoNIfn)0Jejdove0e8lKiOO6kcyAZxrF6gUK1(xREoLGOUED4UKEcUmbeLZPyrZp9irQ9Vw9CkHkHr6gmlg1dLtB(sar5CkwhP7b2mufn)0dusKYMnGXowO8GSO5XpxjckkHkHr6gmlg1dLtB(sqCakxYU1GtfbnXjXvY6T)1QNtrIKbNkcAItI2)A1ZPequoNIrIe4eoPKgfgCQiO1pGZdhlmp(bfusKKEgJRbNkcAc(fseuuDfbmT5RO5rnbxwhIY5umN27675MY3V0H99l03V8LGH(AWPIGMVhWh8OqMVPVseuuH4lbd91UqFF7cH((LVT)1QNtj89mb9DO8TWXUqOVgCQiO57b8bpkK5B6Rebfvi(sWqFLE7Y3V8T9Vw9CkHtB2S5lMWGtfbngn5rdcg2hdLdHPFJNbNkcANczO4Dl4eoPKgfSdSnudQ6gCQiOX9wdove0eNexjRtWWUebffxYm4urqtWVO9Vw9CkbeLZPyKiDRbNkcAc(fxjRtWWUebffOoTzZMVycdove0y0KhniyyFmuoeM(nEgCQiOXFidfVBbNWjL0OGDGTHAqv3GtfbnU3AWPIGMGFXvY6emSlrqrXLmdove0eNeT)1QNtjGOCofJePBn4urqtCsCLSobd7seuuGcyagaa]] )

end
