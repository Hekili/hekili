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


    spec:RegisterPack( "Unholy", 20220523, [[divrqdqivk9iKcUesH0MqL(eq1OakNciTkKkXRaIMLuHBjveTlc)cPOHHuvhtf1Yqv6zccttLIUMksBtLc(MuryCifQZjvKSobrVdvrKMNG09qvTpve)dvrehePsAHOk8qPIAIivQlQsfSrufr9rvkugjsHiNuLk0krk9svku1mvPs3ePqu7ei8tvkKHQsf1svPI8uPQPQsvxfPqyRQuOYxrveglsv2lG)k0Gv6Wswmr9yPmzsUm0MrYNfy0QKtRy1OksVwQ0Sj1TjYUf9BvnCv44OkQLd65OmDkxhHTJO(oQy8ivCEb16LksnFez)unWzG7b6vLHaGGx6ZlV0)uEdH4m9p90qCtGEl8bc0FuTUvac0NLec0tJiVEDyG(JkS(lfW9a9SNa2qG(lZoyHKM0mySlczr7LOjBKi0LnF2GfLrt2i1OjqVmXOT7ycid0RkdbabV0NxEP)P8gcXz6F6PHaONDGnaqW7P8c0FnkfMaYa9kK1a6PBSSlFVXNtWL5lnI861HDAPrUc7lVHOdF5L(8YRtRtBNVQmazH0PTt6lDvXtjyMeMgZx79LUt6MM0nsnAKM0nw2fZx6Ma91EF)uh232tKMVwbdqJ5lNR33cI(I05aBgQ81EF1dz0x9Nb(I5teC5R9(kvMHqFbREmYqJ4WxA4mOcN2oPV09WkznQ8TVAWHAAtP99oxnZxzSvem0xfwkFdUEcnZxPQl6l1d9LvkFP7B8mHtBN0xAeSjd8LN4jsLV9hyQqOVL8OhBqMVspe9LsJ0zK1H9fSY89MG0xMvTUmFNKzyP89P89uqckpP(s335EFtKWGL23kv(kvH99aIKX08L9sOV53jHyZx2yeLnFYeoTDsFPrWMmWxEYiZq4Kb(2BWPl67K(sxVr3bFhkFd)e(EvKrFZ3UMmWxuZqFT3x17BLkF58j4MVpze2QdF58ePI57W8LUVZ9(MiHblTWPTt6BNVQmav(kvzyFbNAcUSieLQjzG7B7t1yZNLM5R9(whh6W(oPVYpJ5l1eCzmF)uh2xW0iJ5BNPBF5umd99tFnyXUav402j9LUQuOY3kF7cH(EJimziwD9ftdg2x79LHMVeh(Ym4Nbi037WXOqPPXeoTDsFVtOUOJV937lzMWx66n6o4R(dMMVSjBOVJ5le1dY89tFBFsvYe6YqLVWAurKmMgt402j99(BeDFJcPV(YtUA2d9T3Gygyx(Ea)gZ3jT3xdozx08v)btta0RhMXaUhOVEmYqJ4a4EaqCg4EGEmlznQa4bqFdogcNcOxHLDf7MtWLjO48ePcvrRGbOX8LVVTWnngXeLgK5ljs(QWYUIDZj4YeuCEIuHQOvWa0y(EcFFp1xsK89wFTsJPjKjGmBYGi7HitGzjRrLVKi5RvAmnHcPgnkWSK1OYxU(2(urmMGZyxiCYGya8jsLaZswJkFjrYxynQisgttukftG0zygZxU(cRrfrYyAIsPycikvtY8nu((E(SVKi5R8Zy(Y1xQj4YIquQMK5BO8998zG(QzZNa9vgoQsfGbacEbUhOhZswJkaEa03GJHWPa6V1xYfCkznko(xpzqesKtlE8CqOVC9fmFLjOOeQc2nAWkzupuQS5tbXHVC9fsKi1ddqHclLEqMfB)OfywYAu5lxFRMnKXiMO0GmFdLVVHWxsK8TA2qgJyIsdY8LVV86lOa9vZMpb6vyzxX2pAadaeHa4EGEmlznQa4bqFdogcNcO)wFjxWPK1O44F9KbriroT4XZbHa9vZMpb6XJrHstdWaaXnbUhOhZswJkaEa0xnB(eONczgcNmiYm40fb6BWXq4ua9kuMGIsqHmdHtge58ePsWSQ113q57Bi8LRVT)1QNtkQJVv6WhmuarPAsMVH6Bia6BHBAmAfmangaiodyaG4uG7b6XSK1OcGha9vZMpb6PqMHWjdImdoDrG(gCmeofqVcLjOOeuiZq4KbroprQemRAD9nuFpd03c30y0kyaAmaqCgWaaXnaCpqpMLSgva8aOVA28jqpfYmeozqKzWPlc03GJHWPa6HejkSrcJ2hVPVH6ly(2(xREoPqHLDfRufvyRclGOunjZxU(ERVwPX0ekKA0OaZswJkFjrY32)A1ZjfkKA0OaIs1KmF56RvAmnHcPgnkWSK1OYxsK8T9KXSstKtWLfPk0xU(2(xREoPqHLDXIkcuarPAsMVGc03c30y0kyaAmaqCgWaarNa4EGEmlznQa4bqF1S5tGEoprQISdmvieOxHSgCoS5tGEEIlm91kyaA(Y4uhmFli6RAyLSgvD4RDnmF5mATVA08n8t4l7atLVqIez0KZtKkMVtYmSu((u(YPgBYaFPEOV0Ds30KUrQrJ0KUXYUaN5lDtGcG(gCmeofqpy(ERVm0SjdyIw4Mg9LejFvyzxXU5eCzckoprQqv0kyaAmFpHVVTWnngXeLgK5lO(Y1xfktqrjOqMHWjdICEIujyw1667j(gcF56lKirHnsy0(yi8nuFB)RvpNuuz4OkvcikvtYamadOVEmktazgW9aG4mW9a9ywYAubWdG(gCmeofqF1SHmgXeLgK5BO899uG(QzZNa9nDXzYGi7QuphgGbacEbUhOhZswJkaEa03GJHWPa6RMnKXiMO0GmF577n4lxFvyzxXU5eCzckoprQqv0kyaAmFpHVVHaOVA28jqFtxCMmiYUk1ZHbyaGiea3d0JzjRrfapa6BWXq4ua9wPX0eYeqMnzqK9qKjWSK1OYxU(cMVkSSRy3CcUmbfNNivOkAfmanMV89TA2qgJyIsdY8LejFvyzxXU5eCzckoprQqv0kyaAmFpHVVHWxq9LejFTsJPjKjGmBYGi7HitGzjRrLVC91knMMOPlotgezxL65WeywYAu5lxFvyzxXU5eCzckoprQqv0kyaAmFpHVVNb6RMnFc0Z5jsvKDGPcHagaiUjW9a9ywYAubWdG(gCmeofqpy(ktqrjyekfMr1)sciwnZxsK89wFjxWPK1O44F9KbriroT4XZbH(cQVC9fmFLjOOeQc2nAWkzupuQS5tbXHVC9fsKi1ddqHclLEqMfB)OfywYAu5lxFRMnKXiMO0GmFdLVVHWxsK8TA2qgJyIsdY8LVV86lOa9vZMpb6vyzxX2pAadaeNcCpqpMLSgva8aOVbhdHtb0djYPfpEoiuOqQPnMVH6ly(EM((csFvyzxXU5eCzckoprQqv0kyaAmFPl(gcFb1xU(QWYUIDZj4YeuCEIuHQOvWa0y(gQV3GVC99wFjxWPK1O44F9KbriroT4XZbH(sIKVYeuucgNcknzquAyMG4aOVA28jqpEmkuAAagaiUbG7b6XSK1OcGha9n4yiCkGEiroT4XZbHcfsnTX8nuF59uF56Rcl7k2nNGltqX5jsfQIwbdqJ57j(EQVC99wFjxWPK1O44F9KbriroT4XZbHa9vZMpb6XJrHstdWaarNa4EGEmlznQa4bqFdogcNcO)wFvyzxXU5eCzckoprQqv0kyaAmF567T(sUGtjRrXX)6jdIqICAXJNdc9LejFPMGllcrPAsMVH67P(sIKVWAurKmMMOukMaPZWmMVC9fwJkIKX0eLsXequQMK5BO(EkqF1S5tGE8yuO00amaqqJbUhOVA28jqpNNivr2bMkec0JzjRrfapamaq0PaUhOhZswJkaEa03GJHWPa6V1xYfCkznko(xpzqesKtlE8CqiqF1S5tGE8yuO00amadOhwTP0mG7baXzG7b6XSK1OcGha9vZMpb6lyRsmApeIPb0Rqwdoh28jq)DQAtPza9n4yiCkGEiroT4XZbHcfsnTX89eFVHt9LRVG57bAIGcg8H1OOA2qg9LejFV1xR0yAcgHK0NXGcg8H1OaZswJkFb1xU(cjsuOqQPnMVNW33tbmaqWlW9a9ywYAubWdG(gCmeofqp5coLSgfsfp9HX2)A1ZjzXQzdz0xsK89anrqbd(WAuunBiJ(Y13d0ebfm4dRrbeLQjz(gkFFLjOOeY6)vrkcyyHIaw28PVKi5R8Zy(Y1xQj4YIquQMK5BO89vMGIsiR)xfPiGHfkcyzZNa9vZMpb6L1)RIueWWagaicbW9a9ywYAubWdG(gCmeofqp5coLSgfsfp9HX2)A1ZjzXQzdz0xU(EGMOGsHJbxpHwunBiJ(sIKVhOjckyWhwJIQzdz0xU(EGMiOGbFynkGOunjZ3q57RmbfLqgHme2DYaHIaw28PVKi5l1eCzrikvtY8nu((ktqrjKridHDNmqOiGLnFc0xnB(eOxgHme2DYaadae3e4EGEmlznQa4bqFdogcNcOxMGIsqKxVoCKzqmdSlbXbqF1S5tGE9eCzSipLqfiHPbyaG4uG7b6XSK1OcGha9vZMpb6RSHmdw6yR0AGEfYAW5WMpb6PRzdzgS0(25sR9TvPVgCccqOV303J3W0Ms7RmbffRdFXQD5RUy2Kb(E(uFzy7tft4lncB0tNgv(EvqLVTxHkFTrc9Ty(w(AWjiaH(AVVDr8W3X8fILQK1OaOVbhdHtb0tUGtjRrHuXtFyS9Vw9CswSA2qg9LejFpqteuWGpSgfvZgYOVC99anrqbd(WAuarPAsMVHY33ZN6ljs(k)mMVC9LAcUSieLQjz(gkFFpFkGbaIBa4EGEmlznQa4bqFdogcNcOVA2qgJyIsdY89e((YRVKi5ly(cjsuOqQPnMVNW33t9LRVqICAXJNdcfkKAAJ57j899gOVVGc0xnB(eOVGTkX4bHMHagai6ea3d0JzjRrfapa6BWXq4ua9Kl4uYAuiv80hgB)RvpNKfRMnKrFjrY3d0ebfm4dRrr1SHm6lxFpqteuWGpSgfquQMK5BO89vMGIsqnquw)VsOiGLnF6ljs(k)mMVC9LAcUSieLQjz(gkFFLjOOeudeL1)RekcyzZNa9vZMpb6PgikR)xbyaGGgdCpqpMLSgva8aOVbhdHtb0xnBiJrmrPbz(Y33Z(Y1xW8vMGIsqKxVoCKzqmdSlbXHVKi5R8Zy(Y1xQj4YIquQMK5BO(EQVGc0xnB(eOxUcIpv0GtRldWamG(amr40aUhaeNbUhOhZswJkaEa03GJHWPa6V1xYfCkznko(xpzqesKtlE8CqOVC9fmFLjOOemcLcZO6FjbeRM5ljs(cjYPfpEoiuOqQPnMVHY3xEPVVG0xW8fsKi1ddqbSKoQ0IgSsgfcXSHcmlznQ8LU47P(csFvyzxXU5eCzcirIupmafxHzgcNYx6IVN6lO(cQVKi57bAIGcg8H1OOA2qg9LRVqIe9nu((gcFjrYxQj4YIquQMK5BO(EM((Y13B9vHYeuuckKziCYGiNNivcIdFjrYxR0yAIckfo(ur7cJQskrLaZswJkF56RvAmnbrE96Wrz9eCzcmlznQ8LRVqIe9nuFdHVC9fmFB)RvpNuqKxVoCuwpbxMaIs1KmFbPVbnLV0fFdHVG6BO(2(xREoPOo(wPdFWqbeLQjzrKohyZqfqF1S5tGEfw2vS9JgWaabVa3d0JzjRrfapa6BWXq4ua9G5RvAmnHcPgnkWSK1OYxsK8T9KXSstKtWLfPk0xsK8fsKi1ddqXXfwWx6tKjWSK1OYxq9LRVG5ly(ERVKl4uYAuC8VEYGiKirMVKi5RvAmnHcPgnkWSK1OYxU(2(urmMGZyxiCYGya8jsLaZswJkFb1xsK8LAcUSieLQjz(gQVN6lOa9vZMpb6RmCuLkadaeHa4EGEmlznQa4bqFdogcNcOxHYeuuckKziCYGiNNivcMvTU(gQV30xU(2(xREoPOo(wPdFWqbeLQjz(gQVbnLV0fF5fOVA28jqpfYmeozqKzWPlcyaG4Ma3d0JzjRrfapa6BWXq4ua9Kl4uYAuOiKoICEIuX8LRVkuMGIsqHmdHtge58ePsWSQ113t477zF56B7FT65KI64BLo8bdfquQMKfr6CGndv(EIVNp13oPVG5lKirQhgGcfwk9Gml2(rlWSK1OYxq9LRV36l5coLSgfh)RNmicjsKb0xnB(eONZtKQi7atfcbmaqCkW9a9ywYAubWdG(gCmeofqVcLjOOeuiZq4KbroprQemRAD99eFdHVC99wFjxWPK1O44F9KbrirImFjrYxfktqrjOqMHWjdICEIujio8LRVutWLfHOunjZ3q9fmFvOmbfLGczgcNmiY5jsLGzvRRV0fFdAkFb1xsK8vHYeuuckKziCYGiNNivcMvTU(EIV30xU(2(xREoPOo(wPdFWqbeLQjzrKohyZqLVN4B7FT65KcI861HJY6j4YequQMK5lxFBFQigt0(K83kB(m(ur7cJkSucmlznQa6RMnFc0Z5jsvKDGPcHagaiUbG7b6XSK1OcGha9n4yiCkGEfktqrjOqMHWjdICEIujyw166BO(EtF567T(sUGtjRrXX)6jdIqIeza9vZMpb6PqMHWjdImdoDradaeDcG7b6XSK1OcGha9n4yiCkG(B9LCbNswJIJ)1tgeHe50Ihphec0xnB(eOxHLDfB)ObmaqqJbUhOhZswJkaEa03GJHWPa6vOmbfLGczgcNmiY5jsLGzvRRVNW33Z(Y1xirI(gQV86lxFV1xYfCkznko(xpzqesKiZxU(2(xREoPOo(wPdFWqbeLQjzrKohyZqLVN47zEb6RMnFc0Z5jsvKDGPcHagGb03EYywPXaUhaeNbUhOhZswJkaEa03GJHWPa6jxWPK1OGzXdDL5Kb(Y1xiroT4XZbHcfsnTX89eFpFd(Y1xW8T9Vw9CsrD8Tsh(GHcikvtY8LejFV1xR0yAIckfo(ur7cJQskrLaZswJkF56B7FT65Kcvb7gnyLmQhkv28PaIs1KmFb1xsK8v(zmF56l1eCzrikvtY8nuFpFgOVA28jqpJtbLMmiknmdWaabVa3d0JzjRrfapa6RMnFc0Z4uqPjdIsdZa6viRbNdB(eOVhnFT3xcg6Brzi0364B(omF)03ot3(wmFT33disgtZ3NmcB1XXKb(ENUZ(Y5A0OVm0Sjd8L4W3ot3GZa6BWXq4ua9T)1QNtkQJVv6WhmuarPAsMVC9fmFRMnKXiMO0GmFpHVV86lxFRMnKXiMO0GmFdLVVN6lxFHe50Ihphekui10gZ3t89m99fK(cMVvZgYyetuAqMV0fFVbFb1xU(sUGtjRrrPuSieLQj9LejFRMnKXiMO0GmFpX3t9LRVqICAXJNdcfkKAAJ57j(Et67lOagaicbW9a9ywYAubWdG(gCmeofqp5coLSgfmlEORmNmWxU(ERVSNqlpPsOXsfLdhr6ushAuGzjRrLVC9fmFB)RvpNuuhFR0HpyOaIs1KmFjrY3B91knMMOGsHJpv0UWOQKsujWSK1OYxU(2(xREoPqvWUrdwjJ6HsLnFkGOunjZxq9LRVqIef2iHr7J303t8vMGIsajYPfBpesCyZNcikvtY8LejFLFgZxU(snbxweIs1KmFd13Z86li9fmFzpHwEsLOlsEsw8)onQNmqGzjRrLV0fF5Lg7lOa9vZMpb6l5xAYYMpJ6rsgWaaXnbUhOhZswJkaEa03GJHWPa6jxWPK1OGzXdDL5Kb(Y1x2tOLNuj0yPIYHJiDkPdnkWSK1OYxU(cMVQ3ee51RdhL1tWLfvVjGOunjZ3t898zFjrY3B91knMMGiVED4OSEcUmbMLSgv(Y132)A1ZjfQc2nAWkzupuQS5tbeLQjz(ckqF1S5tG(s(LMSS5ZOEKKbmaqCkW9a9ywYAubWdG(gCmeofqp5coLSgfmlEORmNmWxU(YEcT8KkrxK8KS4)DAupzGaZswJkF56ly(QqzckkbfYmeozqKZtKkbZQwxFpHVV30xU(ERVqIePEyakk5xAYYMpzrkiMD6WcmlznQ8LejFHejs9WauuYV0KLnFYIuqm70HfywYAu5lxFB)RvpNuuhFR0HpyOaIs1KmFbfOVA28jqFj)stw28zupsYagaiUbG7b6XSK1OcGha9n4yiCkGEYfCkznkkLIfHOunPVC9fsKOWgjmAF8M(EIVYeuuciroTy7HqIdB(uarPAsgqF1S5tG(s(LMSS5ZOEKKbmaq0jaUhOhZswJkaEa03GJHWPa6jxWPK1OGzXdDL5Kb(Y1xW8T9Vw9CsrD8Tsh(GHcikvtY89eFptFFjrY3B91knMMOGsHJpv0UWOQKsujWSK1OYxU(2(xREoPqvWUrdwjJ6HsLnFkGOunjZxq9LejFLFgZxU(snbxweIs1KmFd13ZNc0xnB(eONDvTUAmAxyKi58q7kmGbacAmW9a9ywYAubWdG(gCmeofqp5coLSgfLsXIquQM0xU(cMVkSSRyLQOcBvyHnTUtg4ljs(cRrfrYyAIsPycikvtY8nu((E(M(ckqF1S5tGE2v16QXODHrIKZdTRWagai6ua3d0JzjRrfapa6BWXq4ua9SNqlpPsCqWmcngriXHnFkWSK1OYxsK8L9eA5jvcYVUSrJr2RjJPjWSK1OYxU(ERVYeuucYVUSrJr2RjJPfViKQ8hLG4aOFsdHqIdloua9SNqlpPsq(1LnAmYEnzmnG(jnecjoS4ijHQPmeO)mqF1S5tGEknYUAWIYa6N0qiK4WIb6xU0a9NbmadO)aITxsUmG7baXzG7b6RMnFc0F828jqpMLSgva8aWaabVa3d0xnB(eOhwddJkSua9ywYAubWdadaeHa4EG(QzZNa9uAKD1GfLb0JzjRrfapamaqCtG7b6XSK1OcGha9vZMpb6lOu44tfTlmQWsb03GJHWPa6V1xR0yAcgHK0NXGcg8H1OaZswJkF567T(2EYywPjYj4YIufc0FaX2ljxw0gjeO)Magaiof4EGEmlznQa4bqF1S5tG(ckfo(ur7cJkSua9n4yiCkG(B91knMMGrij9zmOGbFynkWSK1OYxU(2EYywPjYj4YIufc0FaX2ljxw0gjeOpeagaiUbG7b6XSK1OcGha9)bqpdTHcOVbhdHtb0BWj7IMWolUkwKGHrzckkF56ly(AWj7IMWolA)RvpNuOiGLnF6lnQV38uF57l99fuGEfYAW5WMpb6VdKlnrziZ3Yxdozx0y(2(xREozh(QgYJcv(kh23BEQW37VgMVCkMVTRNHPVfZxI861H9LZd7Y89tFV5P(YW2NkFLjGmZ3w4MgzD4RmH57vX81(3xPkd7Btb9fPOWMX81EFdgYOVLVT)1QNtkOJqralB(0x1qEyp03jzgwkHV3rkFhdCMVKlnb67vX8nFFHOunPcH(crJaM(EUdFrnd9fIgbm9L(Itfa9KlymljeO3Gt2fT45ilC2a6RMnFc0tUGtjRrGEYLMaJOMHa90xCkqp5stGa9Nbmaq0jaUhOhZswJkaEa0)ha9m0gkG(QzZNa9Kl4uYAeONCbJzjHa9gCYUOf5nYcNnG(gCmeofqVbNSlAcJxXvXIemmktqr5lxFbZxdozx0egVI2)A1ZjfkcyzZN(sJ67np1x((sFFbfONCPjWiQziqp9fNc0tU0eiq)zadae0yG7b6XSK1OcGha9)bqpdTHcOVbhdHtb0FRVgCYUOjSZIRIfjyyuMGIYxU(AWj7IMW4vCvSibdJYeuu(sIKVgCYUOjmEfxflsWWOmbfLVC9fmFbZxdozx0egVI2)A1ZjfkcyzZN(stFbZxdozx0egVczckQOIaw28PVNWtIV0xq)Z(cQVG6lDXxW89S4uFbPVgCYUOjmEfxflktqr5lO(sx8fmFjxWPK1OWGt2fTiVrw4S5lO(cQVN4ly(cMVgCYUOjSZI2)A1ZjfkcyzZN(stFbZxdozx0e2zHmbfvuralB(03t4jXx6lO)zFb1xq9LU4ly(EwCQVG0xdozx0e2zXvXIYeuu(cQV0fFbZxYfCkznkm4KDrlEoYcNnFb1xqb6viRbNdB(eO)oWSrQmK5B5RbNSlAmFjxAc0x5W(2EPJcozGV2f6B7FT65K((u(AxOVgCYUO1HVQH8OqLVYH91UqFveWYMp99P81UqFLjOO8DmFpGp5rHmHV0ivmFlFzgeZa7YxPxnudc91EFdgYOVLVxtWfc99aopCSW(AVVmdIzGD5RbNSlASo8Ty(Yb1AFlMVLVsVAOge6l1d9DO8T81Gt2fnF5mATVp0xoJw7B(MVSWzZxoJD5B7FT65Kmbqp5cgZscb6n4KDrlEaNhowyG(QzZNa9Kl4uYAeONCPjWiQziq)zGEYLMab65fWaarNc4EGEmlznQa4bq)Fa0ZqdOVA28jqp5coLSgb6jxAceO3knMMOGsHJpv0UWOQKsujWSK1OYxU(2(urmMO9j5Vv28z8PI2fgvyPeywYAub0Rqwdoh28jq)DGCPjkdz(2iGqmnFzOrC4l1d91UqF5zIkTXc77t5lD94BLo8bd9TZ09DYxKIcBgdONCbJzjHa9ueADSPGagaiotFG7b6XSK1OcGha9)bqpdnG(QzZNa9Kl4uYAeONCPjqGEirIupmafkSSlwSHqRM0clWSK1OYxU(cjsK6HbOawshvArdwjJcHy2qbMLSgva9KlymljeOx1IqdWamG(2)A1Zjza3daIZa3d0JzjRrfapa6BWXq4ua9Kl4uYAuiv80hgB)RvpNKfRMnKrFjrY3d0ebfm4dRrr1SHm6lxFpqteuWGpSgfquQMK5BO89L3BWxsK8v(zmF56l1eCzrikvtY8nuF59ga6RMnFc0F828jGbacEbUhOhZswJkaEa03GJHWPa6B)RvpNuOky3ObRKr9qPYMpfquQMKfr6CGndv(gQV0yF56ly(I8mXCCGkrqrg1XNkAxyKAGmlwq5XqOVC9T9Vw9CsHXzygQI8ucvGeMwme3qNOtDAiequQMK5BO(sJ9LejFV1xKNjMJdujckYOo(ur7cJudKzXckpgc9LejFrEMyooqLiOiJ64tfTlmsnqMflO8yi0xU(snbxweIs1KmFd132)A1ZjfgNHzOkYtjubsyAXqCdDIo1PHqarPAsMVG03qqFFb1xU(cMVT)1QNtkiYRxhokRNGltarPAsMVH6ln2xU(ALgttqKxVoCuwpbxMaZswJkFjrY3B91knMMGiVED4OSEcUmbMLSgv(cQVC9fmFzOfL)KGjSbH8sJJ38O5lxFTcgGMWgjmAF8OzXqCQVH67n9LejFV1xgAr5pjycBqiV044npA(sIKVutWLfHOunjZ3t8Lx6tFFb1xU(cMVTNmMvAIeBWx)qLVC9T9Vw9Csrj)stw28zupsYcikvtY8nuFptJ9LRVG5lKirQhgGIs(LMSS5twKcIzNoSaZswJkFjrYx2tOLNuj6IKNKf)VtJ6jdeywYAu5lO(sIKV36lKirQhgGIs(LMSS5twKcIzNoSaZswJkF567T(YEcT8KkrxK8KS4)DAupzGaZswJkFjrYxQj4YIquQMK5BO(2(xREoPOKFPjlB(mQhjzbeLQjz(csFdb99LejFV132tgZknrIn4RFOYxqb6RMnFc0xqPWXNkAxyuHLcWaariaUhOhZswJkaEa03GJHWPa6LFgZxU(snbxweIs1KmFd13qqFFbPVbnfqF1S5tG(ckfo(ur7cJkSuagaiUjW9a9ywYAubWdG(gCmeofqF1SHmgXeLgK5lFFp7lxFTcgGMWgjmAF8OzXqCQVH67P(Y1xRGbOjSrcJ2hvd67j(cMVQ3eSNqhHyDGqbeLQjz(csFp1xqb6RMnFc0ZEcDeI1bcbmaqCkW9a9ywYAubWdG(QzZNa9SNqhHyDGqG(gCmeofqVvWa0e2iHr7JhnlgIt9nuFp1xU(wnBiJrmrPbz(EcFF51xU(AfmanHnsy0(OAqFpXxW8v9MG9e6ieRdekGOunjZxq67P(cQVC9fmFRMnKXiMO0GmFdLVVHWxsK8LHwu(tcMWgeYlnoEZJMVC9TA2qgJyIsdY8nu((EQVC9fmFLjOOeQc2nAWkzupuQS5tbXHVKi5lKirQhgGciw5ivgQISRsswJqbMLSgv(cQVC9fmFV1xfw2vSsvuHTkSWMw3jd8LejFBpzmR0e5eCzrQc9fuFbfOVfUPXOvWa0yaG4mGbaIBa4EGEmlznQa4bqF1S5tGEI861HJY6j4Ya6viRbNdB(eONgPxRy(Yd9eCz(s9qFjo81EFp1xg2(uX81EFzHZMVCg7Yx66X3kD4dg2HV3i7cHCgg2HVem0xoJD5lDxWU(EpSsg1dLkB(ua03GJHWPa6jxWPK1OGzXdDL5Kb(Y1xW8T9Vw9CsrD8Tsh(GHcikvtYIiDoWMHkFd13oHVKi5B7FT65KI64BLo8bdfquQMKfr6CGndv(EIVNp1xq9LRVG5B7FT65Kcvb7gnyLmQhkv28PaIs1KmFd13GMYxsK8vMGIsOky3ObRKr9qPYMpfeh(ckGbaIobW9a9ywYAubWdG(gCmeofqp5coLSgfLsXIquQM0xsK8v(zmF56l1eCzrikvtY8nuF59mqF1S5tGEI861HJY6j4YamaqqJbUhOhZswJkaEa03GJHWPa6jxWPK1OGzXdDL5Kb(Y1xW8v9MGiVED4OSEcUSO6nbeLQjz(sIKV36RvAmnbrE96Wrz9eCzcmlznQ8fuG(QzZNa9Qc2nAWkzupuQS5tadaeDkG7b6XSK1OcGha9n4yiCkGEYfCkznkkLIfHOunPVKi5R8Zy(Y1xQj4YIquQMK5BO(EUt5li9fmFHejs9WauOWsPhKzX2pAbMLSgv(sx8Tt5lOa9vZMpb6vfSB0GvYOEOuzZNagaiotFG7b6XSK1OcGha9n4yiCkG(QzdzmIjkniZx((E2xU(QqzckkbfYmeozqKZtKkbZQwxFpHVV30xU(cMV36l5coLSgfueADSPG(sIKVKl4uYAuqrO1XMc6lxFbZ32)A1Zjfe51RdhL1tWLjGOunjZ3t8Lx67ljs(2(xREoPqvWUrdwjJ6HsLnFkGOunjlI05aBgQ89eF5L((Y13B91knMMGiVED4OSEcUmbMLSgv(sIKV36RvAmnbrE96Wrz9eCzcmlznQ8LRV36RvAmnbrE96WXJQzcmlznQ8fuFb1xsK8v(zmF56l1eCzrikvtY8nuFpFda9vZMpb6RJVv6WhmeWaaX5Za3d0JzjRrfapa6RMnFc0xhFR0HpyiqFdogcNcOVA2qgJyIsdY89e((YRVC9vHYeuuckKziCYGiNNivcMvTU(EcFFVPVC99wFvyzxXkvrf2QWcBADNmaOVfUPXOvWa0yaG4mGbaIZ8cCpqpMLSgva8aOVbhdHtb0djYPfpEoiuOqQPnMVH675B6lxFB)RvpNuqKxVoCuwpbxMaIs1KmFd13ZHWxU(2(xREoPqvWUrdwjJ6HsLnFkGOunjlI05aBgQ8nuFphcG(QzZNa9mcjPpJbfm4dRradaeNdbW9a9ywYAubWdG(gCmeofqp5coLSgfmlEORmNmWxU(QqzckkbfYmeozqKZtKkbZQwxFd1xE9LRVG57bAI64BXGRNqlQMnKrFjrYxzckkHQGDJgSsg1dLkB(uqC4lxFB)RvpNuuhFR0HpyOaIs1KmFpX3Z03xsK8T9Vw9CsrD8Tsh(GHcikvtY89eFptFF56B7FT65Kcvb7gnyLmQhkv28PaIs1KmFpX3Z03xq9LejFLFgZxU(snbxweIs1KmFd13ZHaOVA28jqprE96WXIXkcTbyaG48nbUhOhZswJkaEa0xnB(eONiVED4yXyfH2a6BWXq4ua9vZgYyetuAqMVNW3xE9LRVkuMGIsqHmdHtge58ePsWSQ113q9LxF56ly(EGMOo(wm46j0IQzdz0xsK8vMGIsOky3ObRKr9qPYMpfeh(sIKVT)1QNtkuyzxXkvrf2QWcikvtY8nuFdAkFbfOVfUPXOvWa0yaG4mGbaIZNcCpqpMLSgva8aOVbhdHtb0FRVhOjcUEcTOA2qgb6RMnFc0dRHHrfwkadWa6dWeHtlwpcCpaiodCpqpMLSgva8aONHnG(2)A1ZjfSNqhHyDGqbeLQjza9vZMpb65uJb03GJHWPa6TsJPjypHocX6aHcmlznQ8LRVwbdqtyJegTpE0Syio13q99uF56l1eCzrikvtY89eFp1xU(2(xREoPG9e6ieRdekGOunjZ3q9fmFdAkFPl(sFrN4uFb1xU(wnBiJrmrPbz(gkFFdbGbacEbUhOhZswJkaEa03GJHWPa6bZ3B9LCbNswJIJ)1tgeHe50Ihphe6ljs(ktqrjyekfMr1)sciwnZxq9LRVG5RmbfLqvWUrdwjJ6HsLnFkio8LRVqIePEyakuyP0dYSy7hTaZswJkF56B1SHmgXeLgK5BO89ne(sIKVvZgYyetuAqMV89LxFbfOVA28jqVcl7k2(rdyaGiea3d0JzjRrfapa6BWXq4ua9YeuucgHsHzu9VKaIvZ8LejFV1xYfCkznko(xpzqesKtlE8CqiqF1S5tGE8yuO00amaqCtG7b6XSK1OcGha9kK1GZHnFc0FhP81kyaA(2c30tg47W8vnSswJQo8LXzS2LVYvRRV27RDH(YMmqJDsRGbO5BaMiCA(QhM57KmdlLaOVA28jqpKiJvZMpJ6Hza9mdondaeNb6BWXq4ua9TWnngXeLgK5lFFpd0RhMfZscb6dWeHtdWaaXPa3d0JzjRrfapa6RMnFc0Z5jsvKDGPcHa9n4yiCkGEW8T9Vw9CsrD8Tsh(GHcikvtY89eFpFQVC9vHYeuuckKziCYGiNNivcIdFjrYxfktqrjOqMHWjdICEIujyw1667j(EtFb1xU(cMVutWLfHOunjZ3q9T9Vw9CsHcl7kwPkQWwfwarPAsMVG03Z03xsK8LAcUSieLQjz(EIVT)1QNtkQJVv6WhmuarPAsMVGc03c30y0kyaAmaqCgWaaXnaCpqpMLSgva8aOVA28jqpfYmeozqKzWPlc03GJHWPa6vOmbfLGczgcNmiY5jsLGzvRRVHY33q4lxFB)RvpNuuhFR0HpyOaIs1KmFd13t9LejFvOmbfLGczgcNmiY5jsLGzvRRVH67zG(w4MgJwbdqJbaIZagai6ea3d0JzjRrfapa6RMnFc0tHmdHtgezgC6Ia9n4yiCkG(2)A1Zjf1X3kD4dgkGOunjZ3t89uF56RcLjOOeuiZq4KbroprQemRAD9nuFpd03c30y0kyaAmaqCgWaabng4EGEmlznQa4bqF1S5tGEkKziCYGiZGtxeOxHSgCoS5tG(7VgMVdZxKIcB2qg1H9LA0Ae6lNRPD5lBKy(s335EFtKWGLUdFLjmFzxpHw57bejJP5B5lRHzbN3xoxie91UqFlL6tFVkMV5Bxtg4R9(cX2ljHPsa03GJHWPa6RMnKXO6nbfYmeozqKZtKkFpHVVTWnngXeLgK5lxFvOmbfLGczgcNmiY5jsLGzvRRVH67nbmadOxHufH2aUhaeNbUhOVA28jqV0KQifeXonc0JzjRrfapamaqWlW9a9ywYAubWdG()aONHgqF1S5tGEYfCkznc0tU0eiqpy(I8mXCCGkXKSgKWkzng5zIkncPOcjpn0xsK8f5zI54avc7cJudKzr2emAFjrYxKNjMJdujEYiKZfQLMmiE8CqySbdZSs7lO(Y1xW8T9Vw9CsXKSgKWkzng5zIkncPOcjpnuaXsf2xsK8T9Vw9CsHDHrQbYSiBcgTaIs1KmFjrY32)A1ZjfpzeY5c1stgepEoim2GHzwPfquQMK5lO(sIKVG5lYZeZXbQe2fgPgiZISjy0(sIKViptmhhOs8KriNlulnzq845GWydgMzL2xq9LRViptmhhOsmjRbjSswJrEMOsJqkQqYtdb6viRbNdB(eO)odrYyA(YoW2qnOYxdozx0y(kJtg4lbdv(YzSlFlc7LkBA(QNeza9KlymljeONDGTHAqv0Gt2fnadaeHa4EGEmlznQa4bq)Fa0ZqdOVA28jqp5coLSgb6jxAceOV9Vw9CsbJqs6Zyqbd(WAuarPAsMVH67P(Y1xR0yAcgHK0NXGcg8H1OaZswJkF56ly(ALgttqKxVoCuwpbxMaZswJkF56B7FT65KcI861HJY6j4YequQMK5BO(Eoe(Y132)A1ZjfQc2nAWkzupuQS5tbeLQjzrKohyZqLVH675q4ljs(ERVwPX0ee51RdhL1tWLjWSK1OYxqb6jxWywsiq)X)6jdIqICAXJNdcbmaqCtG7b6XSK1OcGha9)bqpdnG(QzZNa9Kl4uYAeONCPjqGER0yAc2tOJqSoqOaZswJkF56lKirFd1xE9LRVwbdqtyJegTpE0Syio13q99uF56l1eCzrikvtY89eFbZx1Bc2tOJqSoqOaIs1KmFbPVN6lO(sIKVTNmMvAICcUSivH(Y1xR0yAcfsnAuGzjRrLVC9T9Vw9CsHcPgnkGOunjZ3q9fsKOWgjmAFKxGEYfmMLec0F8VEYGiKirgGbaItbUhOhZswJkaEa0)ha9m0a6RMnFc0tUGtjRrGEYLMab6RMnKXiMO0GmF577zF56ly(ERVWAurKmMMOukMaPZWmMVKi5lSgvejJPjkLIjM03t898P(ckqp5cgZscb6zw8qxzozaGbaIBa4EGEmlznQa4bq)Fa0ZqdOVA28jqp5coLSgb6jxAceOVA2qgJyIsdY89e((YRVC9fmFV1xynQisgttukftG0zygZxsK8fwJkIKX0eLsXeiDgMX8LRVG5lSgvejJPjkLIjGOunjZ3t89uFjrYxQj4YIquQMK57j(EM((cQVGc0tUGXSKqG(sPyrikvtcyaGOtaCpqpMLSgva8aO)pa6zOb0xnB(eONCbNswJa9Klnbc0dMVwPX0emcjPpJbfm4dRrbMLSgv(Y13B99anrqbd(WAuunBiJ(Y132)A1ZjfmcjPpJbfm4dRrbeLQjz(sIKV36RvAmnbJqs6Zyqbd(WAuGzjRrLVG6lxFbZxzckkbrE96WXIXkcTjio8LejFTsJPjkOu44tfTlmQkPevcmlznQ8LRVhOjQJVfdUEcTOA2qg9LejFLjOOeQc2nAWkzupuQS5tbXHVC9vMGIsOky3ObRKr9qPYMpfquQMK57j(EQVKi5B1SHmgXeLgK57j89LxF56Rcl7kwPkQWwfwytR7Kb(ckqp5cgZscb6LkE6dJT)1QNtYIvZgYiGbacAmW9a9ywYAubWdG()aONHgqF1S5tGEYfCkznc0tU0eiqF7FT65KI64BLo8bdfquQMKfr6CGndv(EIVNp1xU(cMVTNmMvAICcUSivH(Y1xfw2vSsvuHTkSWMw3jd8LRVYeuucfw2flQiqbZQwxFd13B6ljs(ktqrjKki85GQyakXSpXiMxv2qjmnbXHVKi5RmbfLWUGJwhzi2fHcIdFjrYxzckkbfeZo9GQO0Nmd(SXclio8LejFLjOOeASur5WrKoL0Hgfeh(sIKVYeuuI2v9SOCLOG4WxsK8T9Vw9CsbrE96WXIXkcTjGOunjZ3q99uFbfONCbJzjHa9kcPJiNNivmadaeDkG7b6XSK1OcGha9vZMpb6FctgIvxGEfYAW5WMpb6PrUM0QjNmW3BCdKqJP57DwxbeOVdZ3Y3d48WXcd03GJHWPa6vVjipqcnMw8qxbeOaIuqKDvYA0xU(ERVwPX0ee51RdhL1tWLjWSK1OYxU(ERVWAurKmMMOukMaPZWmgGbaIZ0h4EGEmlznQa4bqF1S5tG(NWKHy1fOVbhdHtb0REtqEGeAmT4HUciqbePGi7QK1OVC9TA2qgJyIsdY89e((YRVC9fmFV1xR0yAcI861HJY6j4YeywYAu5ljs(ALgttqKxVoCuwpbxMaZswJkF56ly(2(xREoPGiVED4OSEcUmbeLQjz(EIVG575t9LM(wnBiJrmrPbz(csFvVjipqcnMw8qxbeOaIs1KmFb1xsK8TA2qgJyIsdY89e((gcFb1xqb6BHBAmAfmangaiodyaG48zG7b6XSK1OcGha9vZMpb6FctgIvxGE9KySPa6VbG(gCmeofqF1SHmgvVjipqcnMw8qxbeOVH6B1SHmgXeLgK5lxFRMnKXiMO0GmFpHVV86lxFbZ3B91knMMGiVED4OSEcUmbMLSgv(sIKVT)1QNtkiYRxhokRNGltarPAsMVC9vMGIsqKxVoCuwpbxwuMGIsOEoPVGc0Rqwdoh28jq)DKYx7cHOVfe9ftuAqMVsdJnzGV34UZD4BDCOd77y(cMmH5B((k9q0x7QsF)SH(EGqFVbFzy7tfdubGbaIZ8cCpqpMLSgva8aOVbhdHtb0djsK6HbOGrCGqMbRjfywYAu5lxFbZx1Bck4ZSifsgHcisbr2vjRrFjrYx1Bcz9)Q4HUciqbePGi7QK1OVGc0xnB(eO)jmziwDbmaqCoea3d0JzjRrfapa6RMnFc0Z5jsvKDGPcHa9kK1GZHnFc0FNqkiYUqMV0nw2fZx6MabN5RmbfLV8ucM5Rms9q0xfw2fZxfb6lMkgqFdogcNcOV9KXSstKtWLfPk0xU(QWYUIvQIkSvHf206ozGVC9fmFvyzxXkvrf2QWIQzdzmcrPAsMVH6ly(g0u(sx89S4uFb1xsK8vMGIsOWYUyrfbkGOunjZ3q9nOP8fuadaeNVjW9a9ywYAubWdGEg2a6B)RvpNuWEcDeI1bcfquQMKb0xnB(eONtngqFdogcNcO3knMMG9e6ieRdekWSK1OYxU(AfmanHnsy0(4rZIH4uFd13t9LRVwbdqtyJegTpQg03t89uF56B7FT65Kc2tOJqSoqOaIs1KmFd1xW8nOP8LU4l9fDIt9fuF56B1SHmgXeLgK5lFFpdyaG48Pa3d0JzjRrfapa6viRbNdB(eONNOgZxQh6lDJLDboZx6MaPjDJuJg9DO8fetWL5lp5c91EFdqZxMbXmWU8vMGIYx5Q113Ivha9mSb03(xREoPqHLDXIkcuarPAsgqF1S5tGEo1ya9n4yiCkG(2tgZknrobxwKQqF56B7FT65Kcfw2flQiqbeLQjz(gQVbnLVC9TA2qgJyIsdY8LVVNbmaqC(gaUhOhZswJkaEa0ZWgqF7FT65KcfsnAuarPAsgqF1S5tGEo1ya9n4yiCkG(2tgZknrobxwKQqF56B7FT65KcfsnAuarPAsMVH6Bqt5lxFRMnKXiMO0GmF577zadaeN7ea3d0JzjRrfapa6viRbNdB(eONU2S5tFV7WmMVvQ89gDGjcz(c2n6ateYOzpYZey2qMVejJ444HgQ8DsFlL6tbOa9vZMpb6BLwhRMnFg1dZa61dZIzjHa9gCYUOXamaqCMgdCpqpMLSgva8aOVA28jqFR06y1S5ZOEygqVEywmljeOV9KXSsJbyaG4CNc4EGEmlznQa4bqF1S5tG(wP1XQzZNr9WmGE9WSywsiqpSAtPzagai4L(a3d0JzjRrfapa6RMnFc03kTownB(mQhMb0RhMfZscb6B)RvpNKbyaGG3Za3d0JzjRrfapa6BWXq4ua9Kl4uYAuukflcrPAsF56ly(2(xREoPqHLDfRufvyRclGOunjZ3q99m99LRV36RvAmnHcPgnkWSK1OYxsK8T9Vw9CsHcPgnkGOunjZ3q99m99LRVwPX0ekKA0OaZswJkFjrY32tgZknrobxwKQqF56B7FT65Kcfw2flQiqbeLQjz(gQVNPVVG6lxFV1xfw2vSsvuHTkSWMw3jda6RMnFc0djYy1S5ZOEygqVEywmljeOVEmYqJ4aWaabV8cCpqpMLSgva8aOVbhdHtb0xnBiJrmrPbz(EcFF51xU(QWYUIvQIkSvHf206ozaqpZGtZaaXzG(QzZNa9qImwnB(mQhMb0RhMfZscb6RhJYeqMbyaGG3qaCpqpMLSgva8aOVbhdHtb0xnBiJrmrPbz(EcFF51xU(ERVkSSRyLQOcBvyHnTUtg4lxFbZ3B9LCbNswJIsPyrikvt6ljs(2(xREoPqHLDfRufvyRclGOunjZ3t89m99LRV36RvAmnHcPgnkWSK1OYxsK8T9Vw9CsHcPgnkGOunjZ3t89m99LRVwPX0ekKA0OaZswJkFjrY32tgZknrobxwKQqF56B7FT65Kcfw2flQiqbeLQjz(EIVNPVVGc0xnB(eOhsKXQzZNr9WmGE9WSywsiqFaMiCAX6radae8EtG7b6XSK1OcGha9n4yiCkG(QzdzmIjkniZx((EgOVA28jqFR06y1S5ZOEygqVEywmljeOpateonadWa6n4KDrJbCpaiodCpqpMLSgva8aOVA28jq)KSgKWkzng5zIkncPOcjpneOVbhdHtb0dMVT)1QNtkiYRxhokRNGltarPAsMVN4lV03xsK8T9Vw9CsHQGDJgSsg1dLkB(uarPAswePZb2mu57j(Yl99fuF56ly(wnBiJrmrPbz(EcFF51xsK89anrbLchdUEcTOA2qg9LejFpqtuhFlgC9eAr1SHm6lxFbZxR0yAcI861HJfJveAtGzjRrLVKi5Rcl7k2nNGltOgwjRXy9MYxq9LejFpqteuWGpSgfvZgYOVG6ljs(k)mMVC9LAcUSieLQjz(gQV8E2xsK8vHLDf7MtWLjudRK1yC4zvePd2im0x((sFF56RvWa0e2iHr7JhnlYl99nuFpfOpljeOFswdsyLSgJ8mrLgHuuHKNgcyaGGxG7b6XSK1OcGha9zjHa9bfzuhFQODHrQbYSybLhdHa9vZMpb6dkYOo(ur7cJudKzXckpgcbmaqecG7b6XSK1OcGha9zjHa9SwbzXNksbldHzPJmdouiqF1S5tGEwRGS4tfPGLHWS0rMbhkeWaaXnbUhOhZswJkaEa0xnB(eO3UWi1azwKnbJgOVbhdHtb0tUGtjRrHuXtFyS9Vw9CswSA2qg9LRVG5RnsOVN4BiOVVKi57T(I8mXCCGkXKSgKWkzng5zIkncPOcjpn0xqb6Zscb6TlmsnqMfztWObmaqCkW9a9ywYAubWdG(QzZNa9pzeY5c1stgepEoim2GHzwPb6BWXq4ua9Kl4uYAuiv80hgB)RvpNKfRMnKrF56ly(AJe67j(gc67ljs(ERViptmhhOsmjRbjSswJrEMOsJqkQqYtd9LRV36lYZeZXbQe2fgPgiZISjy0(ckqFwsiq)tgHCUqT0KbXJNdcJnyyMvAadae3aW9a9ywYAubWdG(QzZNa9gCYUODgOxHSgCoS5tG(7VqFn4KDrZxoJD5RDH(EnbxiZ8fz2ivgQ8LCPjWo8LZO1(kJ(sWqLVudKz(wPY3JAGOYxoJD5lD94BLo8bd9fSHYxzckkFhMVNp1xg2(uX89H(QrgduFFOV8qpbxgnP779fSHY3aiwgc91UQ03ZN6ldBFQyGc03GJHWPa6V1xYfCkznkyhyBOgufn4KDrZxU(cMVG5RbNSlAc7SqMGIkQiGLnF6BO8998P(Y132)A1Zjf1X3kD4dgkGOunjZ3t8Lx67ljs(AWj7IMWolKjOOIkcyzZN(EIVNp1xU(cMVT)1QNtkiYRxhokRNGltarPAsMVN4lV03xsK8T9Vw9CsHQGDJgSsg1dLkB(uarPAswePZb2mu57j(Yl99fuFjrY3QzdzmIjkniZ3t47lV(Y1xzckkHQGDJgSsg1dLkB(uqC4lO(Y1xW89wFn4KDrty8kUkwS9Vw9CsFjrYxdozx0egVI2)A1ZjfquQMK5ljs(sUGtjRrHbNSlAXd48WXc7lFFp7lO(cQVKi5R8Zy(Y1xdozx0e2zHmbfvuralB(03t47l1eCzrikvtYamaq0jaUhOhZswJkaEa03GJHWPa6V1xYfCkznkyhyBOgufn4KDrZxU(cMVG5RbNSlAcJxHmbfvuralB(03q5775t9LRVT)1QNtkQJVv6WhmuarPAsMVN4lV03xsK81Gt2fnHXRqMGIkQiGLnF67j(E(uF56ly(2(xREoPGiVED4OSEcUmbeLQjz(EIV8sFFjrY32)A1ZjfQc2nAWkzupuQS5tbeLQjzrKohyZqLVN4lV03xq9LejFRMnKXiMO0GmFpHVV86lxFLjOOeQc2nAWkzupuQS5tbXHVG6lxFbZ3B91Gt2fnHDwCvSy7FT65K(sIKVgCYUOjSZI2)A1ZjfquQMK5ljs(sUGtjRrHbNSlAXd48WXc7lFF51xq9fuFjrYx5NX8LRVgCYUOjmEfYeuurfbSS5tFpHVVutWLfHOunjdOVA28jqVbNSlA8cyaGGgdCpqpMLSgva8aOVA28jqVbNSlANb6z63a6n4KDr7mqFdogcNcO)wFjxWPK1OGDGTHAqv0Gt2fnF567T(AWj7IMWolUkwKGHrzckkF56ly(AWj7IMW4v0(xREoPaIs1KmFjrY3B91Gt2fnHXR4QyrcggLjOO8fuGEfYAW5WMpb6VJu((PoSVFI((PVem0xdozx089a(KhfY8T8vMGIQdFjyOV2f67Bxi03p9T9Vw9CsHV3iOVdLVjo2fc91Gt2fnFpGp5rHmFlFLjOO6Wxcg6R8Bx((PVT)1QNtkamaq0PaUhOhZswJkaEa0xnB(eO3Gt2fnEb6BWXq4ua936l5coLSgfSdSnudQIgCYUO5lxFV1xdozx0egVIRIfjyyuMGIYxU(cMVgCYUOjSZI2)A1ZjfquQMK5ljs(ERVgCYUOjSZIRIfjyyuMGIYxqb6z63a6n4KDrJxadWamGEYiKnFcacEPpV8s)tpFtGEofmNmGb0ZtqxVtG4ocIBSq6RV3FH(oshp08L6H(cE9yKHgXb4(crEMyGOYx2lH(we2lvgQ8TDvzaYeoT3Ds03ZH03o)jzeAOYxWTsJPjOh4(AVVGBLgttqpbMLSgvG7ly8shqfoT3Ds03ZH03o)jzeAOYxWBFQigtqpW91EFbV9PIymb9eywYAubUVGDMoGkCAV7KOV8gsF78NKrOHkFbhsKi1ddqb9a3x79fCirIupmaf0tGzjRrf4(c2z6aQWP9UtI(EdH03o)jzeAOYxWTsJPjOh4(AVVGBLgttqpbMLSgvG7ly8shqfoToT8e017eiUJG4glK(679xOVJ0XdnFPEOVGxpgLjGmdCFHiptmqu5l7LqFlc7Lkdv(2UQmazcN27oj6BicPVD(tYi0qLVGBLgttqpW91EFb3knMMGEcmlznQa3xWcbDav40E3jrFVzi9TZFsgHgQ8fCirIupmaf0dCFT3xWHejs9WauqpbMLSgvG7lyNPdOcNwNwEc66Dce3rqCJfsF99(l03r64HMVup0xWn4KDrJbUVqKNjgiQ8L9sOVfH9sLHkFBxvgGmHt7DNe99Ci9TZFsgHgQ8fCR0yAc6bUV27l4wPX0e0tGzjRrf4(c2z6aQWP9UtI(EdH03o)jzeAOYxWn4KDrtCwqpW91EFb3Gt2fnHDwqpW9fSqqhqfoT3Ds03BiK(25pjJqdv(cUbNSlAcEf0dCFT3xWn4KDrty8kOh4(cgV0buHt7DNe9TtesF78NKrOHkFb3Gt2fnXzb9a3x79fCdozx0e2zb9a3xW4LoGkCAV7KOVDIq6BN)Kmcnu5l4gCYUOj4vqpW91EFb3Gt2fnHXRGEG7lyHGoGkCAV7KOV04q6BN)Kmcnu5l4gCYUOjolOh4(AVVGBWj7IMWolOh4(c2z6aQWP9UtI(sJdPVD(tYi0qLVGBWj7IMGxb9a3x79fCdozx0egVc6bUVGXlDav40E3jrF7uH03o)jzeAOYxWn4KDrtCwqpW91EFb3Gt2fnHDwqpW9fmEPdOcN27oj6BNkK(25pjJqdv(cUbNSlAcEf0dCFT3xWn4KDrty8kOh4(c2z6aQWP1PLNGUENaXDee3yH0xFV)c9DKoEO5l1d9f8amr40a3xiYZedev(YEj03IWEPYqLVTRkdqMWP9UtI(EoK(25pjJqdv(cUvAmnb9a3x79fCR0yAc6jWSK1OcCFbJx6aQWP9UtI(EoK(25pjJqdv(coKirQhgGc6bUV27l4qIePEyakONaZswJkW9fSZ0buHt7DNe9L3q6BN)Kmcnu5l4wPX0e0dCFT3xWTsJPjONaZswJkW9fSZ0buHt7DNe9L3q6BN)Kmcnu5l4qIePEyakOh4(AVVGdjsK6HbOGEcmlznQa3xWothqfoT3Ds0xEdPVD(tYi0qLVG3(urmMGEG7R9(cE7tfXyc6jWSK1OcCFb7mDav40E3jrFVzi9TZFsgHgQ8fCirIupmaf0dCFT3xWHejs9WauqpbMLSgvG7lyNPdOcN27oj67PH03o)jzeAOYxWBFQigtqpW91EFbV9PIymb9eywYAubUVL57D4gDxFb7mDav4060YtqxVtG4ocIBSq6RV3FH(oshp08L6H(cE7jJzLgdCFHiptmqu5l7LqFlc7Lkdv(2UQmazcN27oj675q6BN)Kmcnu5l4wPX0e0dCFT3xWTsJPjONaZswJkW9fSZ0buHt7DNe9neH03o)jzeAOYxWTsJPjOh4(AVVGBLgttqpbMLSgvG7lyNPdOcN27oj6BicPVD(tYi0qLVGZEcT8Kkb9a3x79fC2tOLNujONaZswJkW9fmEPdOcN27oj67ndPVD(tYi0qLVGBLgttqpW91EFb3knMMGEcmlznQa3xWothqfoT3Ds03BgsF78NKrOHkFbN9eA5jvc6bUV27l4SNqlpPsqpbMLSgvG7lyNPdOcN27oj67PH03o)jzeAOYxWHejs9WauqpW91EFbhsKi1ddqb9eywYAubUVGXlDav40E3jrFpnK(25pjJqdv(co7j0YtQe0dCFT3xWzpHwEsLGEcmlznQa3xWothqfoT3Ds03ori9TZFsgHgQ8fCR0yAc6bUV27l4wPX0e0tGzjRrf4(c2z6aQWP9UtI(2PcPVD(tYi0qLVGZEcT8Kkb9a3x79fC2tOLNujONaZswJkW9fmEPdOcNwNwEc66Dce3rqCJfsF99(l03r64HMVup0xWpGy7LKldCFHiptmqu5l7LqFlc7Lkdv(2UQmazcN27oj67ndPVD(tYi0qLVGBLgttqpW91EFb3knMMGEcmlznQa3xWothqfoT3Ds03tdPVD(tYi0qLVGBLgttqpW91EFb3knMMGEcmlznQa3xWothqfoT3Ds03BiK(25pjJqdv(2psD2xw40k64lnknQV277DjkFLEfHMG57FGWYEOVGrJcQVGDMoGkCAV7KOV3qi9TZFsgHgQ8fCdozx0eNf0dCFT3xWn4KDrtyNf0dCFbJx6aQWP9UtI(2jcPVD(tYi0qLV9JuN9LfoTIo(sJsJ6R9(ExIYxPxrOjy((hiSSh6ly0OG6lyNPdOcN27oj6BNiK(25pjJqdv(cUbNSlAcEf0dCFT3xWn4KDrty8kOh4(cgV0buHt7DNe9LghsF78NKrOHkF7hPo7llCAfD8Lg1x799UeLVQH8WMp99pqyzp0xWOjO(cgV0buHt7DNe9LghsF78NKrOHkFb3Gt2fnXzb9a3x79fCdozx0e2zb9a3xWUjDav40E3jrFPXH03o)jzeAOYxWn4KDrtWRGEG7R9(cUbNSlAcJxb9a3xWoLoGkCAV7KOVDQq6BN)Kmcnu5l4wPX0e0dCFT3xWTsJPjONaZswJkW9fSZ0buHt7DNe9TtfsF78NKrOHkFbV9PIymb9a3x79f82NkIXe0tGzjRrf4(wMV3HB0D9fSZ0buHt7DNe99m9dPVD(tYi0qLVGdjsK6HbOGEG7R9(coKirQhgGc6jWSK1OcCFlZ37Wn6U(c2z6aQWP9UtI(EM(H03o)jzeAOYxWHejs9WauqpW91EFbhsKi1ddqb9eywYAubUVGDMoGkCADA5jOR3jqChbXnwi9137VqFhPJhA(s9qFbV9Vw9Csg4(crEMyGOYx2lH(we2lvgQ8TDvzaYeoT3Ds0xEdPVD(tYi0qLVGBLgttqpW91EFb3knMMGEcmlznQa3xW4LoGkCAV7KOV8gsF78NKrOHkFbhsKi1ddqb9a3x79fCirIupmaf0tGzjRrf4(cgV0buHt7DNe9L3q6BN)Kmcnu5l4SNqlpPsqpW91EFbN9eA5jvc6jWSK1OcCFbJx6aQWP9UtI(EAi9TZFsgHgQ8fCirIupmaf0dCFT3xWHejs9WauqpbMLSgvG7lyNPdOcN27oj6lnoK(25pjJqdv(cUvAmnb9a3x79fCR0yAc6jWSK1OcCFb7mDav40E3jrF7uH03o)jzeAOYxWHejs9WauqpW91EFbhsKi1ddqb9eywYAubUVGDMoGkCAV7KOVNPFi9TZFsgHgQ8fCR0yAc6bUV27l4wPX0e0tGzjRrf4(cwiOdOcNwNwEc66Dce3rqCJfsF99(l03r64HMVup0xWdWeHtlwpcUVqKNjgiQ8L9sOVfH9sLHkFBxvgGmHt7DNe99Ci9TZFsgHgQ8fCR0yAc6bUV27l4wPX0e0tGzjRrf4(c2z6aQWP9UtI(YBi9TZFsgHgQ8fCirIupmaf0dCFT3xWHejs9WauqpbMLSgvG7lyNPdOcNwNwEc66Dce3rqCJfsF99(l03r64HMVup0xWvivrOnW9fI8mXarLVSxc9TiSxQmu5B7QYaKjCAV7KOVHiK(25pjJqdv(cUvAmnb9a3x79fCR0yAc6jWSK1OcCFble0buHt7DNe99MH03o)jzeAOYxWTsJPjOh4(AVVGBLgttqpbMLSgvG7ly8shqfoT3Ds03ori9TZFsgHgQ8fCR0yAc6bUV27l4wPX0e0tGzjRrf4(cwiOdOcN27oj6BNkK(25pjJqdv(cUvAmnb9a3x79fCR0yAc6jWSK1OcCFb7mDav40E3jrFpt)q6BN)Kmcnu5B)i1zFzHtROJV0O(AVV3LO8vnKh28PV)bcl7H(cgnb1xWothqfoT3Ds03Z0pK(25pjJqdv(cUvAmnb9a3x79fCR0yAc6jWSK1OcCFbJx6aQWP9UtI(E(Ci9TZFsgHgQ8fCR0yAc6bUV27l4wPX0e0tGzjRrf4(c2z6aQWP9UtI(EM3q6BN)Kmcnu5l4qIePEyakOh4(AVVGdjsK6HbOGEcmlznQa3xWothqfoT3Ds03Z3mK(25pjJqdv(cUvAmnb9a3x79fCR0yAc6jWSK1OcCFb7mDav40E3jrF59Ci9TZFsgHgQ8fCR0yAc6bUV27l4wPX0e0tGzjRrf4(cgV0buHt7DNe9L3qesF78NKrOHkFb3knMMGEG7R9(cUvAmnb9eywYAubUVGXlDav4060EhLoEOHkFptFFRMnF6REygt40c0xe21db67hjcDzZNDgwugq)b8Pgnc0td0GV0nw2LV34Zj4Y8LgrE96WoT0an4lnYvyF5neD4lV0NxEDADAPbAW3oFvzaYcPtlnqd(2j9LUQ4PemtctJ5R9(s3jDtt6gPgnst6gl7I5lDtG(AVVFQd7B7jsZxRGbOX8LZ17BbrFr6CGndv(AVV6Hm6R(ZaFX8jcU81EFLkZqOVGvpgzOrC4lnCguHtlnqd(2j9LUhwjRrLV9vdoutBkTV35Qz(kJTIGH(QWs5BW1tOz(kvDrFPEOVSs5lDFJNjCAPbAW3oPV0iytg4lpXtKkF7pWuHqFl5rp2GmFLEi6lLgPZiRd7lyL57nbPVmRADz(ojZWs57t57PGeuEs9LUVZ9(MiHblTVvQ8vQc77bejJP5l7LqFZVtcXMVSXikB(KjCAPbAW3oPV0iytg4lpzKziCYaF7n40f9DsFPR3O7GVdLVHFcFVkYOV5Bxtg4lQzOV27R69TsLVC(eCZ3NmcB1HVCEIuX8Dy(s335EFtKWGLw40sd0GVDsF78vLbOYxPkd7l4utWLfHOunjdCFBFQgB(S0mFT3364qh23j9v(zmFPMGlJ57N6W(cMgzmF7mD7lNIzOVF6Rbl2fOcNwAGg8Tt6lDvPqLVv(2fc99gryYqS66lMgmSV27ldnFjo8LzWpdqOV3HJrHstJjCAPbAW3oPV3jux0X3(79Lmt4lD9gDh8v)btZx2Kn03X8fI6bz((PVTpPkzcDzOYxynQisgtJjCAPbAW3oPV3FJO7Bui91xEYvZEOV9geZa7Y3d43y(oP9(AWj7IMV6pyAcNwN2QzZNmXbeBVKCzGKpnpEB(0PTA28jtCaX2ljxgi5ttynmmQWs50wnB(KjoGy7LKldK8PjLgzxnyrzoTvZMpzIdi2Ej5YajFAwqPWXNkAxyuHLQJdi2Ej5YI2iH8Vzhdf)BTsJPjyessFgdkyWhwJCVT9KXSstKtWLfPk0PTA28jtCaX2ljxgi5tZckfo(ur7cJkSuDCaX2ljxw0gjKFi6yO4FRvAmnbJqs6Zyqbd(WAKB7jJzLMiNGllsvOtln47DGCPjkdz(w(AWj7IgZ32)A1Zj7Wx1qEuOYx5W(EZtf(E)1W8LtX8TD9mm9Ty(sKxVoSVCEyxMVF67np1xg2(u5RmbKz(2c30iRdFLjmFVkMV2)(kvzyFBkOViff2mMV27BWqg9T8T9Vw9CsbDekcyzZN(QgYd7H(ojZWsj89os57yGZ8LCPjqFVkMV57leLQjvi0xiAeW03ZD4lQzOVq0iGPV0xCQWPTA28jtCaX2ljxgi5ttYfCkzn2rwsiFdozx0INJSWzRJ)GpdTHQdYLMa5FUdYLMaJOMH8PV40oAFQgB(KVbNSlAIZIRIfjyyuMGIIlygCYUOjolA)RvpNuOiGLnFsJsJEZt5tFqDARMnFYehqS9sYLbs(0KCbNswJDKLeY3Gt2fTiVrw4S1XFWNH2q1b5stG8p3b5stGruZq(0xCAhTpvJnFY3Gt2fnbVIRIfjyyuMGIIlygCYUOj4v0(xREoPqralB(KgLg9MNYN(G60sd(Ehy2ivgY8T81Gt2fnMVKlnb6RCyFBV0rbNmWx7c9T9Vw9CsFFkFTl0xdozx06Wx1qEuOYx5W(AxOVkcyzZN((u(AxOVYeuu(oMVhWN8OqMWxAKkMVLVmdIzGD5R0RgQbH(AVVbdz03Y3Rj4cH(EaNhowyFT3xMbXmWU81Gt2fnwh(wmF5GATVfZ3YxPxnudc9L6H(ou(w(AWj7IMVCgT23h6lNrR9nFZxw4S5lNXU8T9Vw9CsMWPTA28jtCaX2ljxgi5ttYfCkzn2rwsiFdozx0IhW5HJfUJ)GpdTHQdYLMa5ZBhKlnbgrnd5FUJ2NQXMp5FRbNSlAIZIRIfjyyuMGIIRbNSlAcEfxflsWWOmbffjsgCYUOj4vCvSibdJYeuuCbdmdozx0e8kA)RvpNuOiGLnFsJcMbNSlAcEfYeuurfbSS5Zt4jH(c6FguqPlGDwCkin4KDrtWR4QyrzckkqPlGrUGtjRrHbNSlArEJSWzduqpbmWm4KDrtCw0(xREoPqralB(Kgfmdozx0eNfYeuurfbSS5Zt4jH(c6FguqPlGDwCkin4KDrtCwCvSOmbffO0fWixWPK1OWGt2fT45ilC2afuNwAW37a5stugY8TraHyA(YqJ4WxQh6RDH(YZevAJf23NYx66X3kD4dg6BNP77KViff2mMtB1S5tM4aITxsUmqYNMKl4uYASJSKq(ueADSPGDqU0eiFR0yAIckfo(ur7cJQskrf32NkIXeTpj)TYMpJpv0UWOclLtB1S5tM4aITxsUmqYNMKl4uYASJSKq(QweADqU0eiFirIupmafkSSlwSHqRM0cZfsKi1ddqbSKoQ0IgSsgfcXSHoToT0an47DGoyJWqLVizeg2xBKqFTl03Qzp03H5BrUgDjRrHtB1S5tgFPjvrkiIDA0PLg89odrYyA(YoW2qnOYxdozx0y(kJtg4lbdv(YzSlFlc7LkBA(QNezoTvZMpzGKpnjxWPK1yhzjH8zhyBOgufn4KDrRdYLMa5dgYZeZXbQetYAqcRK1yKNjQ0iKIkK80qsKqEMyooqLWUWi1azwKnbJMejKNjMJdujEYiKZfQLMmiE8CqySbdZSsdkxWA)RvpNumjRbjSswJrEMOsJqkQqYtdfqSuHjrQ9Vw9CsHDHrQbYSiBcgTaIs1KmsKA)RvpNu8KriNlulnzq845GWydgMzLwarPAsgOKibgYZeZXbQe2fgPgiZISjy0KiH8mXCCGkXtgHCUqT0KbXJNdcJnyyMvAq5I8mXCCGkXKSgKWkzng5zIkncPOcjpn0PLgObFVXvWPK1iZPTA28jdK8Pj5coLSg7iljK)X)6jdIqICAXJNdc7GCPjq(T)1QNtkyessFgdkyWhwJcikvtYc9uUwPX0emcjPpJbfm4dRrUGzLgttqKxVoCuwpbxg32)A1Zjfe51RdhL1tWLjGOunjl0ZHGB7FT65Kcvb7gnyLmQhkv28PaIs1KSisNdSzOk0ZHGePBTsJPjiYRxhokRNGlduN2QzZNmqYNMKl4uYASJSKq(h)RNmicjsK1b5stG8TsJPjypHocX6aHCHejgkVCTcgGMWgjmAF8OzXqCAONYLAcUSieLQjzNaM6nb7j0riwhiuarPAsgipfusKApzmR0e5eCzrQc5ALgttOqQrJCB)RvpNuOqQrJcikvtYcfsKOWgjmAFKxN2QzZNmqYNMKl4uYASJSKq(mlEORmNmOdYLMa5xnBiJrmrPbz8pZfSBH1OIizmnrPumbsNHzmsKG1OIizmnrPumXKNC(uqDARMnFYajFAsUGtjRXoYsc5xkflcrPAYoixAcKF1SHmgXeLgKDcFE5c2TWAurKmMMOukMaPZWmgjsWAurKmMMOukMaPZWmgxWG1OIizmnrPumbeLQjzNCkjsutWLfHOunj7KZ0huqDARMnFYajFAsUGtjRXoYsc5lv80hgB)RvpNKfRMnKXoixAcKpywPX0emcjPpJbfm4dRrU3EGMiOGbFynkQMnKrUT)1QNtkyessFgdkyWhwJcikvtYir6wR0yAcgHK0NXGcg8H1iOCbtMGIsqKxVoCSySIqBcIdsKSsJPjkOu44tfTlmQkPevCpqtuhFlgC9eAr1SHmsIKmbfLqvWUrdwjJ6HsLnFkio4ktqrjufSB0GvYOEOuzZNcikvtYo5usKQMnKXiMO0GSt4Zlxfw2vSsvuHTkSWMw3jda1PTA28jdK8Pj5coLSg7iljKVIq6iY5jsfRdYLMa53(xREoPOo(wPdFWqbeLQjzrKohyZq1jNpLlyTNmMvAICcUSivHCvyzxXkvrf2QWcBADNmGRmbfLqHLDXIkcuWSQ1n0BsIKmbfLqQGWNdQIbOeZ(eJyEvzdLW0eehKijtqrjSl4O1rgIDrOG4GejzckkbfeZo9GQO0Nmd(SXclioirsMGIsOXsfLdhr6ushAuqCqIKmbfLODvplkxjkioirQ9Vw9CsbrE96WXIXkcTjGOunjl0tb1PLg8Lg5AsRMCYaFVXnqcnMMV3zDfqG(omFlFpGZdhlStB1S5tgi5tZNWKHy1TJHIV6nb5bsOX0Ih6kGafqKcISRswJCV1knMMGiVED4OSEcUmU3cRrfrYyAIsPycKodZyoTvZMpzGKpnFctgIv3oAHBAmAfmang)ZDmu8vVjipqcnMw8qxbeOaIuqKDvYAKB1SHmgXeLgKDcFE5c2TwPX0ee51RdhL1tWLrIKvAmnbrE96Wrz9eCzCbR9Vw9CsbrE96Wrz9eCzcikvtYobSZNsJwnBiJrmrPbzGu9MG8aj0yAXdDfqGcikvtYaLePQzdzmIjkni7e(HauqDAPbFVJu(Axie9TGOVyIsdY8vAySjd89g3DUdFRJdDyFhZxWKjmFZ3xPhI(Axv67Nn03de67n4ldBFQyGkCARMnFYajFA(eMmeRUDONeJnf)BOJHIF1SHmgvVjipqcnMw8qxbeyOvZgYyetuAqg3QzdzmIjkni7e(8YfSBTsJPjiYRxhokRNGlJeP2)A1Zjfe51RdhL1tWLjGOunjJRmbfLGiVED4OSEcUSOmbfLq9CsqDARMnFYajFA(eMmeRUDmu8Hejs9WauWioqiZG1KCbt9MGc(mlsHKrOaIuqKDvYAKej1Bcz9)Q4HUciqbePGi7QK1iOoT0GV3jKcISlK5lDJLDX8LUjqWz(ktqr5lpLGz(kJupe9vHLDX8vrG(IPI50wnB(Kbs(0KZtKQi7atfc7yO43EYywPjYj4YIufYvHLDfRufvyRclSP1DYaUGPWYUIvQIkSvHfvZgYyeIs1KSqblOPOlNfNckjsYeuucfw2flQiqbeLQjzHg0uG60wnB(Kbs(0KtnwhmSXV9Vw9Csb7j0riwhiuarPAswhdfFR0yAc2tOJqSoqixRGbOjSrcJ2hpAwmeNg6PCTcgGMWgjmAFun4jNYT9Vw9Csb7j0riwhiuarPAswOGf0u0f6l6eNck3QzdzmIjkniJ)zNwAWxEIAmFPEOV0nw2f4mFPBcKM0nsnA03HYxqmbxMV8Kl0x79nanFzgeZa7YxzckkFLRwxFlwD40wnB(Kbs(0KtnwhmSXV9Vw9CsHcl7IfveOaIs1KSogk(TNmMvAICcUSivHCB)RvpNuOWYUyrfbkGOunjl0GMIB1SHmgXeLgKX)StB1S5tgi5tto1yDWWg)2)A1ZjfkKA0OaIs1KSogk(TNmMvAICcUSivHCB)RvpNuOqQrJcikvtYcnOP4wnBiJrmrPbz8p70sd(sxB28PV3DygZ3kv(EJoWeHmFb7gDGjcz0Sh5zcmBiZxIKrCC8qdv(oPVLs9PauN2QzZNmqYNMTsRJvZMpJ6HzDKLeY3Gt2fnMtB1S5tgi5tZwP1XQzZNr9WSoYsc53EYywPXCARMnFYajFA2kTownB(mQhM1rwsiFy1MsZCAPbAW3QzZNmqYNMmKNjWSHDmu8RMnKXiMO0Gm(N5ERcl7k2nNGltOgwjRXy9MIRvAmnbJqs6Zyqbd(WASJSKq(bfmi(hyIWq(eMmeRUHKczgcNmiYm40fdjfYmeozqKzWPlgsgHK0NXGcg8H1yilOu44tfTlmQWsfsfw2vS9JUJHIVmbfLGrOuygv)ljiocPcl7k2(rhsfw2vS9JoKS2tadWiZGtxSJHIVcLjOOeuiZq4KbroprQemRADp5MHK1EcyagzgC6IDmu8vOmbfLGczgcNmiY5jsLGzvR7j3mKuiZq4KbrMbNUOtlnqd(wnB(Kbs(0KH8mbMnSJHIF1SHmgXeLgKX)m3BvyzxXU5eCzc1WkzngR3uCV1knMMGrij9zmOGbFyn2rwsi))ategskKziCYGiZGtxmKuiZq4KbrMbNUyipEB(mKe51RdhL1tWLfsvb7gnyLmQhkv28ziRJVv6Whm0PTA28jdK8PzR06y1S5ZOEywhzjH8B)RvpNK50wnB(Kbs(0esKXQzZNr9WSoYsc5xpgzOrC0XqXNCbNswJIsPyrikvtYfS2)A1ZjfkSSRyLQOcBvybeLQjzHEM(CV1knMMqHuJgjrQ9Vw9CsHcPgnkGOunjl0Z0NRvAmnHcPgnsIu7jJzLMiNGllsvi32)A1ZjfkSSlwurGcikvtYc9m9bL7TkSSRyLQOcBvyHnTUtg40wnB(Kbs(0esKXQzZNr9WSoYsc5xpgLjGmRdMbNMX)Chdf)QzdzmIjkni7e(8YvHLDfRufvyRclSP1DYaN2QzZNmqYNMqImwnB(mQhM1rwsi)amr40I1JDmu8RMnKXiMO0GSt4Zl3BvyzxXkvrf2QWcBADNmGly3sUGtjRrrPuSieLQjjrQ9Vw9CsHcl7kwPkQWwfwarPAs2jNPp3BTsJPjui1OrsKA)RvpNuOqQrJcikvtYo5m95ALgttOqQrJKi1EYywPjYj4YIufYT9Vw9CsHcl7IfveOaIs1KStotFqDARMnFYajFA2kTownB(mQhM1rwsi)amr406yO4xnBiJrmrPbz8p7060sd0GV01)o4lpiGmZPTA28jtupgLjGmJFtxCMmiYUk1ZH1XqXVA2qgJyIsdYcL)PoTvZMpzI6XOmbKzGKpnB6IZKbr2vPEoSogk(vZgYyetuAqg)BGRcl7k2nNGltqX5jsfQIwbdqJDc)q40wnB(KjQhJYeqMbs(0KZtKQi7atfc7yO4BLgttitaz2Kbr2drgxWuyzxXU5eCzckoprQqv0kyaAm(vZgYyetuAqgjskSSRy3CcUmbfNNivOkAfman2j8dbOKizLgttitaz2Kbr2drgxR0yAIMU4mzqKDvQNdJRcl7k2nNGltqX5jsfQIwbdqJDc)ZoTvZMpzI6XOmbKzGKpnvyzxX2p6ogk(GjtqrjyekfMr1)sciwnJePBjxWPK1O44F9KbriroT4XZbHGYfmzckkHQGDJgSsg1dLkB(uqCWfsKi1ddqHclLEqMfB)O5wnBiJrmrPbzHYpeKivnBiJrmrPbz85fuN2QzZNmr9yuMaYmqYNM4XOqPP1XqXhsKtlE8CqOqHutBSqb7m9bPcl7k2nNGltqX5jsfQIwbdqJrxcbOCvyzxXU5eCzckoprQqv0kyaASqVbU3sUGtjRrXX)6jdIqICAXJNdcjrsMGIsW4uqPjdIsdZeehoTvZMpzI6XOmbKzGKpnXJrHstRJHIpKiNw845GqHcPM2yHY7PCvyzxXU5eCzckoprQqv0kyaAStoL7TKl4uYAuC8VEYGiKiNw845GqN2QzZNmr9yuMaYmqYNM4XOqPP1XqX)wfw2vSBobxMGIZtKkufTcgGgJ7TKl4uYAuC8VEYGiKiNw845GqsKOMGllcrPAswONsIeSgvejJPjkLIjq6mmJXfwJkIKX0eLsXequQMKf6PoTvZMpzI6XOmbKzGKpn58ePkYoWuHqN2QzZNmr9yuMaYmqYNM4XOqPP1XqX)wYfCkznko(xpzqesKtlE8CqOtRtlnqd(sx)7GV9OrC40wnB(KjQhJm0io4xz4OkvDmu8vyzxXU5eCzckoprQqv0kyaAm(TWnngXeLgKrIKcl7k2nNGltqX5jsfQIwbdqJDc)tjr6wR0yAczciZMmiYEiYirYknMMqHuJg52(urmMGZyxiCYGya8jsfjsWAurKmMMOukMaPZWmgxynQisgttukftarPAswO8pFMej5NX4snbxweIs1KSq5F(StB1S5tMOEmYqJ4aK8PPcl7k2(r3XqX)wYfCkznko(xpzqesKtlE8CqixWKjOOeQc2nAWkzupuQS5tbXbxirIupmafkSu6bzwS9JMB1SHmgXeLgKfk)qqIu1SHmgXeLgKXNxqDARMnFYe1JrgAehGKpnXJrHstRJHI)TKl4uYAuC8VEYGiKiNw845GqN2QzZNmr9yKHgXbi5ttkKziCYGiZGtxSJw4MgJwbdqJX)ChdfFfktqrjOqMHWjdICEIujyw16gk)qWT9Vw9CsrD8Tsh(GHcikvtYcneoTvZMpzI6XidnIdqYNMuiZq4KbrMbNUyhTWnngTcgGgJ)5ogk(kuMGIsqHmdHtge58ePsWSQ1n0ZoTvZMpzI6XidnIdqYNMuiZq4KbrMbNUyhTWnngTcgGgJ)5ogk(qIef2iHr7J3muWA)RvpNuOWYUIvQIkSvHfquQMKX9wR0yAcfsnAKeP2)A1ZjfkKA0OaIs1KmUwPX0ekKA0ijsTNmMvAICcUSivHCB)RvpNuOWYUyrfbkGOunjduNwAWxEIlm91kyaA(Y4uhmFli6RAyLSgvD4RDnmF5mATVA08n8t4l7atLVqIez0KZtKkMVtYmSu((u(YPgBYaFPEOV0Ds30KUrQrJ0KUXYUaN5lDtGcN2QzZNmr9yKHgXbi5ttoprQISdmviSJHIpy3YqZMmGjAHBAKejfw2vSBobxMGIZtKkufTcgGg7e(TWnngXeLgKbkxfktqrjOqMHWjdICEIujyw16Esi4cjsuyJegTpgIqB)RvpNuuz4OkvcikvtYCADAPbAW378BZNoTvZMpzI2)A1Zjz8pEB(SJHIp5coLSgfsfp9HX2)A1ZjzXQzdzKePd0ebfm4dRrr1SHmY9anrqbd(WAuarPAswO859girs(zmUutWLfHOunjluEVbNwAGg8TZ)RvpNK50wnB(KjA)RvpNKbs(0SGsHJpv0UWOclvhdf)2)A1ZjfQc2nAWkzupuQS5tbeLQjzrKohyZqvO0yUGH8mXCCGkrqrg1XNkAxyKAGmlwq5Xqi32)A1ZjfgNHzOkYtjubsyAXqCdDIo1PHqarPAswO0ysKUf5zI54avIGImQJpv0UWi1azwSGYJHqsKqEMyooqLiOiJ64tfTlmsnqMflO8yiKl1eCzrikvtYcT9Vw9CsHXzygQI8ucvGeMwme3qNOtDAiequQMKbYqqFq5cw7FT65KcI861HJY6j4YequQMKfknMRvAmnbrE96Wrz9eCzKiDRvAmnbrE96Wrz9eCzGYfmgAr5pjycBqiV044npACTcgGMWgjmAF8OzXqCAO3KePBzOfL)KGjSbH8sJJ38OrIe1eCzrikvtYoHx6tFq5cw7jJzLMiXg81puXT9Vw9Csrj)stw28zupsYcikvtYc9mnMlyqIePEyakk5xAYYMpzrkiMD6WKiXEcT8KkrxK8KS4)DAupzaOKiDlKirQhgGIs(LMSS5twKcIzNom3BzpHwEsLOlsEsw8)onQNmGejQj4YIquQMKfA7FT65KIs(LMSS5ZOEKKfquQMKbYqqFsKUT9KXSstKyd(6hQa1PTA28jt0(xREojdK8PzbLchFQODHrfwQogk(YpJXLAcUSieLQjzHgc6dYGMYPTA28jt0(xREojdK8Pj7j0riwhiSJHIF1SHmgXeLgKX)mxRGbOjSrcJ2hpAwmeNg6PCTcgGMWgjmAFun4jGPEtWEcDeI1bcfquQMKbYtb1PTA28jt0(xREojdK8Pj7j0riwhiSJw4MgJwbdqJX)ChdfFRGbOjSrcJ2hpAwmeNg6PCRMnKXiMO0GSt4ZlxRGbOjSrcJ2hvdEcyQ3eSNqhHyDGqbeLQjzG8uq5cw1SHmgXeLgKfk)qqIedTO8NemHniKxAC8MhnUvZgYyetuAqwO8pLlyYeuucvb7gnyLmQhkv28PG4GejirIupmafqSYrQmufzxLKSgHGYfSBvyzxXkvrf2QWcBADNmGeP2tgZknrobxwKQqqb1PLg8LgPxRy(Yd9eCz(s9qFjo81EFp1xg2(uX81EFzHZMVCg7Yx66X3kD4dg2HV3i7cHCgg2HVem0xoJD5lDxWU(EpSsg1dLkB(u40wnB(KjA)RvpNKbs(0KiVED4OSEcUSogk(Kl4uYAuWS4HUYCYaUG1(xREoPOo(wPdFWqbeLQjzrKohyZqvODcsKA)RvpNuuhFR0HpyOaIs1KSisNdSzO6KZNckxWA)RvpNuOky3ObRKr9qPYMpfquQMKfAqtrIKmbfLqvWUrdwjJ6HsLnFkioa1PTA28jt0(xREojdK8PjrE96Wrz9eCzDmu8jxWPK1OOukweIs1KKij)mgxQj4YIquQMKfkVNDARMnFYeT)1QNtYajFAQky3ObRKr9qPYMp7yO4tUGtjRrbZIh6kZjd4cM6nbrE96Wrz9eCzr1BcikvtYir6wR0yAcI861HJY6j4Ya1PTA28jt0(xREojdK8PPQGDJgSsg1dLkB(SJHIp5coLSgfLsXIquQMKej5NX4snbxweIs1KSqp3PajyqIePEyakuyP0dYSy7hnDPtbQtB1S5tMO9Vw9Csgi5tZ64BLo8bd7yO4xnBiJrmrPbz8pZvHYeuuckKziCYGiNNivcMvTUNW)MCb7wYfCkznkOi06ytbjrICbNswJckcTo2uqUG1(xREoPGiVED4OSEcUmbeLQjzNWl9jrQ9Vw9CsHQGDJgSsg1dLkB(uarPAswePZb2muDcV0N7TwPX0ee51RdhL1tWLrI0TwPX0ee51RdhL1tWLX9wR0yAcI861HJhvZafusKKFgJl1eCzrikvtYc98n40wnB(KjA)RvpNKbs(0So(wPdFWWoAHBAmAfmang)ZDmu8RMnKXiMO0GSt4ZlxfktqrjOqMHWjdICEIujyw16Ec)BY9wfw2vSsvuHTkSWMw3jdCARMnFYeT)1QNtYajFAYiKK(mguWGpSg7yO4djYPfpEoiuOqQPnwONVj32)A1Zjfe51RdhL1tWLjGOunjl0ZHGB7FT65Kcvb7gnyLmQhkv28PaIs1KSisNdSzOk0ZHWPTA28jt0(xREojdK8PjrE96WXIXkcT1XqXNCbNswJcMfp0vMtgWvHYeuuckKziCYGiNNivcMvTUHYlxWoqtuhFlgC9eAr1SHmsIKmbfLqvWUrdwjJ6HsLnFkio42(xREoPOo(wPdFWqbeLQjzNCM(Ki1(xREoPOo(wPdFWqbeLQjzNCM(CB)RvpNuOky3ObRKr9qPYMpfquQMKDYz6dkjsYpJXLAcUSieLQjzHEoeoTvZMpzI2)A1ZjzGKpnjYRxhowmwrOToAHBAmAfmang)ZDmu8RMnKXiMO0GSt4ZlxfktqrjOqMHWjdICEIujyw16gkVCb7anrD8TyW1tOfvZgYijsYeuucvb7gnyLmQhkv28PG4GeP2)A1ZjfkSSRyLQOcBvybeLQjzHg0uG60wnB(KjA)RvpNKbs(0ewddJkSuDmu8V9anrW1tOfvZgYOtlnqd(s3dRK1OQdF5PemZ38nFHyP1H9nFOuP9vgVkYZd91UkdCMVCEOD57bbKrmzGVt2jdkju40sd0GVvZMpzI2)A1ZjzGKpnzvdoutBkD8OAwhdf)QzdzmIjkni7e(8Y9wzckkHQGDJgSsg1dLkB(uqCWT9Vw9CsHQGDJgSsg1dLkB(uarPAs2j3ajsutWLfHOunjl0GMYP1PLgObF78tgZknFPRYJESbzoTvZMpzI2tgZkngFgNcknzquAywhdfFYfCkznkyw8qxzozaxiroT4XZbHcfsnTXo58nWfS2)A1Zjf1X3kD4dgkGOunjJePBTsJPjkOu44tfTlmQkPevCB)RvpNuOky3ObRKr9qPYMpfquQMKbkjsYpJXLAcUSieLQjzHE(Stln4BpA(AVVem03IYqOV1X38Dy((PVDMU9Ty(AVVhqKmMMVpze2QJJjd89oDN9LZ1OrFzOztg4lXHVDMUbN50wnB(KjApzmR0yGKpnzCkO0KbrPHzDmu8B)RvpNuuhFR0HpyOaIs1KmUGvnBiJrmrPbzNWNxUvZgYyetuAqwO8pLlKiNw845GqHcPM2yNCM(GeSQzdzmIjkniJUCdGYLCbNswJIsPyrikvtsIu1SHmgXeLgKDYPCHe50Ihphekui10g7KBsFqDARMnFYeTNmMvAmqYNML8lnzzZNr9ij3XqXNCbNswJcMfp0vMtgW9w2tOLNuj0yPIYHJiDkPdnYfS2)A1Zjf1X3kD4dgkGOunjJePBTsJPjkOu44tfTlmQkPevCB)RvpNuOky3ObRKr9qPYMpfquQMKbkxirIcBKWO9XBEImbfLasKtl2EiK4WMpfquQMKrIK8ZyCPMGllcrPAswON5fKGXEcT8KkrxK8KS4)DAupzaDHxAmOoTvZMpzI2tgZkngi5tZs(LMSS5ZOEKK7yO4tUGtjRrbZIh6kZjd4YEcT8KkHglvuoCePtjDOrUGPEtqKxVoCuwpbxwu9MaIs1KStoFMePBTsJPjiYRxhokRNGlJB7FT65Kcvb7gnyLmQhkv28PaIs1KmqDARMnFYeTNmMvAmqYNML8lnzzZNr9ij3XqXNCbNswJcMfp0vMtgWL9eA5jvIUi5jzX)70OEYaUGPqzckkbfYmeozqKZtKkbZQw3t4FtU3cjsK6HbOOKFPjlB(KfPGy2PdtIeKirQhgGIs(LMSS5twKcIzNom32)A1Zjf1X3kD4dgkGOunjduN2QzZNmr7jJzLgdK8Pzj)stw28zupsYDmu8jxWPK1OOukweIs1KCHejkSrcJ2hV5jYeuuciroTy7HqIdB(uarPAsMtB1S5tMO9KXSsJbs(0KDvTUAmAxyKi58q7kChdfFYfCkznkyw8qxzozaxWA)RvpNuuhFR0HpyOaIs1KStotFsKU1knMMOGsHJpv0UWOQKsuXT9Vw9CsHQGDJgSsg1dLkB(uarPAsgOKij)mgxQj4YIquQMKf65tDARMnFYeTNmMvAmqYNMSRQ1vJr7cJejNhAxH7yO4tUGtjRrrPuSieLQj5cMcl7kwPkQWwfwytR7KbKibRrfrYyAIsPycikvtYcL)5BcQtB1S5tMO9KXSsJbs(0KsJSRgSOSogk(SNqlpPsCqWmcngriXHnFsIe7j0YtQeKFDzJgJSxtgtJ7TYeuucYVUSrJr2RjJPfViKQ8hLG4OJjnecjoS4ijHQPmK)5oM0qiK4WIb6xU08p3XKgcHehwCO4ZEcT8Kkb5xx2OXi71KX0CADAPbAW3(jd0OV3xWa0CARMnFYebyIWPXxHLDfB)O7yO4Fl5coLSgfh)RNmicjYPfpEoiKlyYeuucgHsHzu9VKaIvZircsKtlE8CqOqHutBSq5Zl9bjyqIePEyakGL0rLw0GvYOqiMnKUCkivyzxXU5eCzcirIupmafxHzgcNIUCkOGsI0bAIGcg8H1OOA2qg5cjsmu(HGejQj4YIquQMKf6z6Z9wfktqrjOqMHWjdICEIujioirYknMMOGsHJpv0UWOQKsuX1knMMGiVED4OSEcUmUqIedneCbR9Vw9CsbrE96Wrz9eCzcikvtYazqtrxcbOH2(xREoPOo(wPdFWqbeLQjzrKohyZqLtB1S5tMiateonqYNMvgoQsvhdfFWSsJPjui1OrbMLSgvKi1EYywPjYj4YIufsIeKirQhgGIJlSGV0NiduUGb2TKl4uYAuC8VEYGiKirgjswPX0ekKA0i32NkIXeCg7cHtgedGprQaLejQj4YIquQMKf6PG60wnB(KjcWeHtdK8PjfYmeozqKzWPl2XqXxHYeuuckKziCYGiNNivcMvTUHEtUT)1QNtkQJVv6WhmuarPAswObnfDHxN2QzZNmraMiCAGKpn58ePkYoWuHWogk(Kl4uYAuOiKoICEIuX4QqzckkbfYmeozqKZtKkbZQw3t4FMB7FT65KI64BLo8bdfquQMKfr6CGndvNC(0ojyqIePEyakuyP0dYSy7hnOCVLCbNswJIJ)1tgeHejYCARMnFYebyIWPbs(0KZtKQi7atfc7yO4RqzckkbfYmeozqKZtKkbZQw3tcb3BjxWPK1O44F9KbrirImsKuOmbfLGczgcNmiY5jsLG4Gl1eCzrikvtYcfmfktqrjOqMHWjdICEIujyw16sxcAkqjrsHYeuuckKziCYGiNNivcMvTUNCtUT)1QNtkQJVv6WhmuarPAswePZb2muDs7FT65KcI861HJY6j4YequQMKXT9PIymr7tYFRS5Z4tfTlmQWs50wnB(KjcWeHtdK8PjfYmeozqKzWPl2XqXxHYeuuckKziCYGiNNivcMvTUHEtU3sUGtjRrXX)6jdIqIezoTvZMpzIamr40ajFAQWYUITF0Dmu8VLCbNswJIJ)1tgeHe50Ihphe60wnB(KjcWeHtdK8PjNNivr2bMke2XqXxHYeuuckKziCYGiNNivcMvTUNW)mxirIHYl3BjxWPK1O44F9KbrirImUT)1QNtkQJVv6WhmuarPAswePZb2muDYzEDADAPbAW3Bmmr408LU(3bFVZW5HJf2PTA28jteGjcNwSEKpNASoyyJF7FT65Kc2tOJqSoqOaIs1KSogk(wPX0eSNqhHyDGqUwbdqtyJegTpE0Syion0t5snbxweIs1KStoLB7FT65Kc2tOJqSoqOaIs1KSqblOPOl0x0jofuUvZgYyetuAqwO8dHtB1S5tMiateoTy9ii5ttfw2vS9JUJHIpy3sUGtjRrXX)6jdIqICAXJNdcjrsMGIsWiukmJQ)LeqSAgOCbtMGIsOky3ObRKr9qPYMpfehCHejs9WauOWsPhKzX2pAUvZgYyetuAqwO8dbjsvZgYyetuAqgFEb1PTA28jteGjcNwSEeK8PjEmkuAADmu8LjOOemcLcZO6FjbeRMrI0TKl4uYAuC8VEYGiKiNw845GqNwAW37iLVwbdqZ3w4MEYaFhMVQHvYAu1HVmoJ1U8vUAD91EFTl0x2KbAStAfmanFdWeHtZx9WmFNKzyPeoTvZMpzIamr40I1JGKpnHezSA28zupmRJSKq(byIWP1bZGtZ4FUJHIFlCtJrmrPbz8p70wnB(KjcWeHtlwpcs(0KZtKQi7atfc7OfUPXOvWa0y8p3XqXhS2)A1Zjf1X3kD4dgkGOunj7KZNYvHYeuuckKziCYGiNNivcIdsKuOmbfLGczgcNmiY5jsLGzvR7j3euUGrnbxweIs1KSqB)RvpNuOWYUIvQIkSvHfquQMKbYZ0NejQj4YIquQMKDs7FT65KI64BLo8bdfquQMKbQtB1S5tMiateoTy9ii5ttkKziCYGiZGtxSJw4MgJwbdqJX)ChdfFfktqrjOqMHWjdICEIujyw16gk)qWT9Vw9CsrD8Tsh(GHcikvtYc9usKuOmbfLGczgcNmiY5jsLGzvRBONDARMnFYebyIWPfRhbjFAsHmdHtgezgC6ID0c30y0kyaAm(N7yO43(xREoPOo(wPdFWqbeLQjzNCkxfktqrjOqMHWjdICEIujyw16g6zNwAW37VgMVdZxKIcB2qg1H9LA0Ae6lNRPD5lBKy(s335EFtKWGLUdFLjmFzxpHw57bejJP5B5lRHzbN3xoxie91UqFlL6tFVkMV5Bxtg4R9(cX2ljHPs40wnB(KjcWeHtlwpcs(0KczgcNmiYm40f7yO4xnBiJr1BckKziCYGiNNivNWVfUPXiMO0GmUkuMGIsqHmdHtge58ePsWSQ1n0B6060sd(ENQ2uAMtB1S5tMawTP0m(fSvjgThcX06yO4djYPfpEoiuOqQPn2j3WPCb7anrqbd(WAuunBiJKiDRvAmnbJqs6Zyqbd(WAuGzjRrfOCHejkui10g7e(N60wnB(KjGvBkndK8PPS(FvKIagUJHIp5coLSgfsfp9HX2)A1ZjzXQzdzKePd0ebfm4dRrr1SHmY9anrqbd(WAuarPAswO8LjOOeY6)vrkcyyHIaw28jjsYpJXLAcUSieLQjzHYxMGIsiR)xfPiGHfkcyzZNoTvZMpzcy1MsZajFAkJqgc7ozqhdfFYfCkznkKkE6dJT)1QNtYIvZgYi3d0efukCm46j0IQzdzKePd0ebfm4dRrr1SHmY9anrqbd(WAuarPAswO8LjOOeYiKHWUtgiueWYMpjrIAcUSieLQjzHYxMGIsiJqgc7ozGqralB(0PTA28jtaR2uAgi5tt9eCzSipLqfiHP1XqXxMGIsqKxVoCKzqmdSlbXHtln4lDnBiZGL23oxATVTk91Gtqac99M(E8gM2uAFLjOOyD4lwTlF1fZMmW3ZN6ldBFQycFPryJE60OY3RcQ8T9ku5RnsOVfZ3Yxdobbi0x79TlIh(oMVqSuLSgfoTvZMpzcy1MsZajFAwzdzgS0XwP1Dmu8jxWPK1OqQ4Ppm2(xREojlwnBiJKiDGMiOGbFynkQMnKrUhOjckyWhwJcikvtYcL)5tjrs(zmUutWLfHOunjlu(Np1PTA28jtaR2uAgi5tZc2QeJheAg2XqXVA2qgJyIsdYoHpVKibgKirHcPM2yNW)uUqICAXJNdcfkKAAJDc)BG(G60wnB(KjGvBkndK8Pj1arz9)Qogk(Kl4uYAuiv80hgB)RvpNKfRMnKrsKoqteuWGpSgfvZgYi3d0ebfm4dRrbeLQjzHYxMGIsqnquw)VsOiGLnFsIK8ZyCPMGllcrPAswO8LjOOeudeL1)RekcyzZNoTvZMpzcy1MsZajFAkxbXNkAWP1L1XqXVA2qgJyIsdY4FMlyYeuucI861HJmdIzGDjioirs(zmUutWLfHOunjl0tb1P1PLgObFVhozx0yoTvZMpzcdozx0y8jyyCmuQJSKq(tYAqcRK1yKNjQ0iKIkK80Wogk(G1(xREoPGiVED4OSEcUmbeLQjzNWl9jrQ9Vw9CsHQGDJgSsg1dLkB(uarPAswePZb2muDcV0huUGvnBiJrmrPbzNWNxsKoqtuqPWXGRNqlQMnKrsKoqtuhFlgC9eAr1SHmYfmR0yAcI861HJfJveAJejfw2vSBobxMqnSswJX6nfOKiDGMiOGbFynkQMnKrqjrs(zmUutWLfHOunjluEptIKcl7k2nNGltOgwjRX4WZQishSryiF6Z1kyaAcBKWO9XJMf5L(HEQtB1S5tMWGt2fngi5ttcgghdL6iljKFqrg1XNkAxyKAGmlwq5XqOtB1S5tMWGt2fngi5ttcgghdL6iljKpRvqw8PIuWYqyw6iZGdf60wnB(Kjm4KDrJbs(0KGHXXqPoYsc5BxyKAGmlYMGr3XqXNCbNswJcPIN(Wy7FT65KSy1SHmYfmBKWtcb9jr6wKNjMJdujMK1GewjRXiptuPrifvi5PHG60wnB(Kjm4KDrJbs(0KGHXXqPoYsc5)KriNlulnzq845GWydgMzLUJHIp5coLSgfsfp9HX2)A1ZjzXQzdzKly2iHNec6tI0TiptmhhOsmjRbjSswJrEMOsJqkQqYtd5ElYZeZXbQe2fgPgiZISjy0G60sd(E)f6RbNSlA(YzSlFTl03Rj4czMViZgPYqLVKlnb2HVCgT2xz0xcgQ8LAGmZ3kv(Eudev(YzSlFPRhFR0HpyOVGnu(ktqr57W898P(YW2NkMVp0xnYyG67d9Lh6j4YOjDFVVGnu(gaXYqOV2vL(E(uFzy7tfduN2QzZNmHbNSlAmqYNMgCYUODUJHI)TKl4uYAuWoW2qnOkAWj7IgxWaZGt2fnXzHmbfvuralB(mu(NpLB7FT65KI64BLo8bdfquQMKDcV0Nejdozx0eNfYeuurfbSS5ZtoFkxWA)RvpNuqKxVoCuwpbxMaIs1KSt4L(Ki1(xREoPqvWUrdwjJ6HsLnFkGOunjlI05aBgQoHx6dkjsvZgYyetuAq2j85LRmbfLqvWUrdwjJ6HsLnFkioaLly3AWj7IMGxXvXIT)1QNtsIKbNSlAcEfT)1QNtkGOunjJejYfCkznkm4KDrlEaNhowy(NbfusKKFgJRbNSlAIZczckQOIaw285j8PMGllcrPAsMtB1S5tMWGt2fngi5ttdozx04TJHI)TKl4uYAuWoW2qnOkAWj7IgxWaZGt2fnbVczckQOIaw28zO8pFk32)A1Zjf1X3kD4dgkGOunj7eEPpjsgCYUOj4vitqrfveWYMpp58PCbR9Vw9CsbrE96Wrz9eCzcikvtYoHx6tIu7FT65Kcvb7gnyLmQhkv28PaIs1KSisNdSzO6eEPpOKivnBiJrmrPbzNWNxUYeuucvb7gnyLmQhkv28PG4auUGDRbNSlAIZIRIfB)RvpNKejdozx0eNfT)1QNtkGOunjJejYfCkznkm4KDrlEaNhowy(8ckOKij)mgxdozx0e8kKjOOIkcyzZNNWNAcUSieLQjzoT0GV3rkF)uh23prF)0xcg6RbNSlA(EaFYJcz(w(ktqr1HVem0x7c99Tle67N(2(xREoPW3Be03HY3eh7cH(AWj7IMVhWN8OqMVLVYeuuD4lbd9v(TlF)032)A1ZjfoTvZMpzcdozx0yGKpnjyyCmuQdM(n(gCYUODUJHI)TKl4uYAuWoW2qnOkAWj7Ig3Bn4KDrtCwCvSibdJYeuuCbZGt2fnbVI2)A1ZjfquQMKrI0TgCYUOj4vCvSibdJYeuuG60wnB(Kjm4KDrJbs(0KGHXXqPoy634BWj7IgVDmu8VLCbNswJc2b2gQbvrdozx04ERbNSlAcEfxflsWWOmbffxWm4KDrtCw0(xREoPaIs1KmsKU1Gt2fnXzXvXIemmktqrbkGbyaaa]] )

end
