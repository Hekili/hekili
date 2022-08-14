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
            icd = 5,
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


    spec:RegisterPack( "Unholy", 20220814, [[Hekili:T3t)ZTTnY(3INBQIuSRSPKLBAEw(M2K(UR961KPo3h)KPPOOKydLOk)WUUJh93(B3fGKaGaGqYo56BMBUPxKjXhlwSFVlaVX7MpCZ1ZdkIU5NgD2OrN9kVZh69QrF1zF9nxx8W2OBUEBq4hdwc)ytWA4))FSzvAYd4JFijnyo2980YSq4vRkk2M)6tpDzCXQYzddtxFAE86YKGI40nHzblkW)o80BUEwzCsX3V5Mz6M7jtgdJ52Oq4XtgbdB885rS2gLhEZ1VnkOy1UB)BBIxUQy3TmaA3p8nLllZH)278t2DloE7(HD)WBwfSzzu(R39dF5UB)M5)c0I1rBkY3DBr6UBF7M3E6BJweNeDknOWJFBze7DPBGb92W0YnWyweKTmc719RGxfKbTj63aiSiAoR1jX3bpljDZs4nBslxUI981bffrz7UTFqAKFEur52D3(N8gmKGN3gNhmlbhIRdcZIxehghKS723hect5SOWGYCyqNhfaTy5Q0YKCCa)i8SfPWyMJp)T)TC2G9pYJXj)FbamoGBJ2mhN4GzXjXfXryxtr4Ers0VfpdxB9dGP58JHbQa2IHgeVjVGMS0f7UDYXd(FGH)9xV72nrLfziKfGd96aOVBZIUlcXm5PRHbDt6xMffc)vCrjTBldu)VrWaNr)86ISyCfeVb2pE33b)aMRhsl3D7QG7OrQyf1WOKC(oX8u(mFF6Mxatz6DrzHbBX)gwRiCNldOS5MT1ta8gaIFXcKCXplADaSoFbU1UzEmcRbjCYHGTBr8ccAZsZHhsDjVIwOFse(W38wyMdGfe(COJzb5R4BOFdqOohbwyrGi)3vwmllk4Jinrr2dSzbOc2DlshKxKb0ly7(UTXZJwhhYXA)CusWVbOQpS727GhXWtjPlJjm8Mqe9bJrwucTVIqbSywemdz1qailiEUpTbXhXp8U3(UxV7wyNaOTqAhyBiAZsKnABwAiT3JWgS5S5Ji8rZ2WBUojoVih5XRPFH)4NiHgrBiI3B(2BUgiEX93aKdfyJ8)iXAoCbTbfn3VM95QPaO(qysKF0gybJq)JpsK4D1RjSwEeYlMalSHZkZYlakf)CGSoFihAyTI3K5eRDZR6X20lJlgEFmUdHDFzgoDY9Vb)nmy(CyW)nenqdG6R40t7U9sai98y9Nr90Jta5R0gazgI0DW)U5b)5BMFtbiPZikfwY3fa)cEZWTPPjiqNvUjo0FB69i1dmp9H5SCXIHZdY(OpqrUjhKqSM4ehIKAiGxUjcE4YOHOafKYPWpmnorc9Ga2DcBoiapMTMuFf8Mr7UDqZIHTjIdjUEgFORNMbmIZvGd35kdxvBwujzXpNeSitls4KMMqewdjPD1lnIMinzE69BggSnnmi5HT5rcBRqRGbLOz5eKi9pastE(bjG6q)CDXbmx4g(WI41WyL6Fon6nRugHx1Yu)K(vgMucM9ZzAyykLZI3YE3)Av0Mk1LGWQ7d2MZ1xoNRSduods4rvPXjGkLeSDK8FAaz0P5NwlAxuL09bXfKUbs9NQY7xW0Epueh0NKyaYTW(LpKwLolYrrq1aIyX(o4vv0usi)X2r(fW)JKVsI0SlFvhd6KMTMWKG7jQHvbWuLBxWIgo6l4RXoXnJToNMz(7q4ntuMdZ)HPezmTlkOHWcCWBHYQtQjomJEMyB0ittISLOYYlrlF9NNMUgOwiZc5kbTRryWFqvkOkYusyvf4tQTdrdCUKwdENT72J7ez)YQD3U3xUSIoVt8iPlN2iUpiBn(61GHaaYtVskvP0DV8gnXfa(kY8NUby9qLQyCjnXDmZDpNmKKQDo12RDqwsjjstCP8kYsu9QHAwHqd)6NvRpaXZlbs8mOrGyADcOZbNvVUwap4pCcGmc2c721AyRbBqjMgjII9rwmeUvuRkzByH)4jvy42wywtQydyQ4SwgoNyCoB4xnPI3rlZUD9i9DKiXKiT)OkTYSwSNGWz3mVvYMQVFrJfvOEpYei0ckbtQYbhAcbV5MrMHqUYTkI8wCzs0xw1BovmgUcmsjCJRg2ataG6Z(Tp2eGWgmRmSaj4fw(kkFzQ5W27ZcreFASzKScZReXKv7XbcCVj2SedPvyMd0HHANlq51w(vnqWOjcaODEuyWdnqYXmvtAe)DvhRHbpFg5)C5JZexqAM9pXKRc2a9U2MTUl3je9kNHijETpqUMG)x0IfrK8cm0pGxgjOyS7xfJCz5XRZLd50jO0l0JhmmDZfIpwa8SqaoYItXUhHUcrSMGopmWnRcYfc6fY4MffMUEnWymuJX6ZtluXfAni2fm35sQ2S73rNc4fKGBqWOEBGqzWmd86lkGply92GnfCfbawBtOqGCEjrDOAuytVx9aTMdQA5GA7(3c6sxcekPpalegoTw1IKUI2seqMDM9qDi5HRrhSy8b)0f(WUT)8G1BIMRZ)Isk61(ZsOLGyd4GufhSOGr5ojkrQsLoZw4lTY47xfcBtkaTQY3qm2qeqykq7d7EdP9f)fbr1ua8nOTRIcYsxNUr0PRAPXMnOOYxVNsa(gyXK1bAJnNzdb6MhZjPVv7AJSiNYQdJ14Q5LR36xf8KofcqEO2fe63KPdUY3VuHz1K1ydS5aruUfxJn7OyNQ1hBFsTQNJBNzBsJ(DHjFjFtCGl6rVYb6czSExC(ce(W)EhmyKnCvsFqJ8QWMMr6MDF1rYCh2P1rwB1bv3SLwwULQUFxxinSd1YEh1f10(Sl6nYm2h9jKl2m3UQ4Aib432MeSzdz5qpdkyXP9Iwkq0jhso9kDO9QX8ynUR1yOBhPdroBisbzrN(h9nu2aURr)CqZOOCNgSOGsckSCzw1HMCHjWdT6cBvTDA8KkULqM)87jt9WyfZJDmlJDV5TVi3ztyzOCvFoVAAfrLohvNyFJS2qj1((skKwm5T10hyuv4iB9()Evxt45NHQeTQb0i1ig3DWw4zXa)vciaYF2da3aywNIc7)Zqw2tje9NtRxs4adzeMMLvUvUFDrlpQA7PEH)XO7qPaPP)Eek0qYc2rVs2EJzPanDa3371ZCuHVkA3vCo6iHKYeY1cj3S9ur(MTv1r8U9vRzL(DVAnIO75GYBKNSwdwJzncWyU)cWfKF)bL0e7wt7YaWoqlMvlRNt)aiTTdaM1pBCFPlM6RAIDYZpVDxSPcbxoFfqaGXoaMYYn3NMvS6b7wqyeNxN3QMqfveh(rcJOls4nGeA1X5sKbMalZH1UMryBzErjgjGQTyjk26MDxkwvwq7YttiysetFeNCrTr(RkxhSjnEoLbK4nWCJZIF8cbaqTtsnC96O5XybFDTGE)fjr5ROYdtSTltsNfKGnKmoAlfwKzbn5hTQ7Btz)BdEPY0H6OAgeNZScwPvJfBLiyi1kt1EGe9kn4swUwfy)Y1GFU(1bDqbr32xzH1QpYdFZ1NBlsQpDOWfqySojrPBXmFuGB)c5ZGvcrdl8gUki3hmdZhjMQ4reEDddDzgXfV72VaeepHIOmz5HSPDF3DbjLaXtofvn(aL3iy4emI43ftLG1ShWrA4UBzb07E0EVWvP5y1jG)MPkdlHSSpYnleN48i0nkK8plNhT9O8Qy7TIz0yAvfLfopRkmHCRjxsHtkqqw1VjS4qGlhRCHyEC33DlgA)4cSYfW1wuD4aXOaIIhOs4llQOmd6V3jvvfx1toB4KHKijEG354eFp)8h2e2qJuj0c)fmn(4OCZ1qV5pGXL1sqVW(RUrsDwhXNvn0cJStlmYfAbRGUQaBTKMhjr(1cImcTueNSVu6C1CQABWE738(R(Z425zEvbR8LSCFpKfNtLzNnZ1TQwNK8or1qDvliulV3PQT5WGqpNGqpbiuLnphe5OHnNZHmJQk31BdYivRuS0RwnSYeIEeVFQYeO31SMQBodEr3E2MLIThR7Y)AadgYRlwY1PZJxeJmLsS7RabN4d3MfNcuBvf6zD3QweNWe(CFew5t8bVziPQAclh2MLDvvsHVH9RnPywgiChgIZM1EUwjbvquxYc8QzNgPZqdo7KXrPon2DAdNJbPYKG)WYSmwDhZQLAcNr7G)AjOcJW94M63uB0j61(pxlNwehTOmjXheIJlyVZ27vSu8plwL7hgLvaYSlEOvy87oNgIW18q)SIQqcX3CDmKqRd(L0m)6E5xLHdBP(q65swLo6IonME0fTmeZAIdCXiEHGMbZWRQeXg9RLXB3ceuldUlkPISzrmOP2piBwCbpnu1trX9XGE25()s58Lyr)7p(IV6RNmwkY7VQ2jeNgESTo1qTil3HmqG64ZeYisxX)Tgpz3tDNCNVEsbYF)zPBkZbhzIYg9k)Z3gYNet1KY51ZH(oRpz5JotETwzoAuywAsAMQl0kUOkHf8QjxC05CjVImgfHb1Rlhh2EYbaZ4aRptuoSw5uiCOshoBGfFeSxDlMz3hFwvwgTp4MdCLAmiRd5Exf6KY7Nhhvzzdg4kTv50XQ50tOv2CPsSzIwZ2beAouVhoSxrnRlyX8mvBKn1CaM73rTwjhCla02qwKnhRc21a2ktJ0IJ6i(h6skmZ6V9PwyKKzPyMWFfyAGL53sVJBAaUAqBXQ9TJ7PMOfun2ka2N9omTXG4z83ukeyT5TaMcCMugv9mekmzDDFvfQYL2ZtgBBDewJpwv2Mj962Obg4yO)ALLbBwl4zAN0TyUPb32rCSDtJxduPbBypWBheEW7RBxXlMsIo4a1x7ci2YcwhK56AyX7lNc0kdNzRtnp2nJwUIv6psu8UzwiVN9CyV1jcaDd0waRjjMtuFAnFjH5TDC4CdbBJw5cJZRP8Jk0mlubnQNCfknlIxVqCpZ2yOVyWybcVx3KoylvkSr3OCOokOPxoSOeqFajDRZ6Jyufpb6SfU94tNN3HI(NzvACp3tOIlTZrexD7DiRkJBjApippOmHKT7zYulLM(mqU(CGTLfjzQaGRuLAWegpZjU7iUx3cq1n6YwbfdGQGhPleav9bGNWSYc85(uGqkxdJWDXHssa(Cit2OfR89VQirqEn0EBXWogBiLfqZPzKf1lvqO86J3piTOXhoTHbPB67rEwMG4FDoGjIclXdfolG1TT6h9xaXqxshVfwOESSVPjmk8QR3yyhAOhS0gnU(Xg38WGSCSplYaB9Z2eKq1O1cbstZnXsAYAaH84LXj7vCR477XRzomj4XBDuymJcjotE4qvGblo)Hfc09RIsOcmIuq5hM9aiC5ZkK3tUPkWVWkZc4AXnkUmfVwv)EKuONPyxJpJcWnMrSiEW5NZJh)jvXLEwe5V0CK3HYDgDJnSniodFMQJwaYbd0npQ75mpzQDqdDCdVRfgW(jZHUtF7h49Aj4qkfKTIvbBK66afHSnkSbPuyu2N7xV66PjRikz8GYm)eNu(wj00s6tQhRptIHXoBwjQDF)eS6xj1tnPArA5kKZljFVAL4NMuKW8czqBHVwWHtvenB3h19McOvw5EkuaTtX3)FNcWZgfG3brbmYofqBCylkavzAJ0flH2Y9Ytsle)79HQPJ8i33b(I2mwndHAcrXIeGDd0KIvLmIgOitvdsvPSKYCiogvXUIKDZVlAy3smCyz3TVJNRXnrXS339OnlffIlno6InsR9Jdg32rvdyIIZ22ZaLD(rmBSbxqj)puRTiqR6Cm2(r)EK4AuJTzDNVW(oQ6hxcMv8l9wZk)1fxqZtkgI35pOiTrzQLXX1TYmi00bo7D)NX1LdysfUO3xFJvvr3TtO4cMfXkY78gRvcklsrjI0XLLoednPOTfTRoZQ7MKOglQwEwIEEuL(JoRJRwEizRqD)KeyLg(VUI3AdQu356qJ3eDJm74G0RCKo6kzoTZsPtzRHXB0othn7GApZA1HAGEN4UHuP8oYaIlkxNhnDJYunoOoWWmf)MU8gWfP67IBmWrA7viuz6Ciz)HXgdy2FGu42NOVLkY9Q6ZdDBQaE0WKwJcH(xNbPDVg77e)9rMRHJUfKiZyACAQ1AqwhQePL97aUEObFZMPPA2ISfNqdPJuAZtVd86mIS79rl(i0oXDvAN1kSWiSxJDy1C08Yi5JHxn6DDqwgimDU)YO15fGLJakc8xomAnjzERqtlwLb(W7Nhf9rqOM0RO6Aa1ZbKl49vyoy4UClupNjsVmCvqAU)SGnrTJRQcXLIkpP9iHt1Qnlot5x3IkA()7W4IfMfH)(NXzLjKDaVpjyjwqHXmlDBQuoH03aY7VJ3bumg0EaobCs(kCYRnyTlTUgftPnXDTxo7he1LeZUtywNli3CGTpJq)02G0XmDPTxjYwmQBLmENLYgOvQ4AJlrB58X6x5cnzBqdqreKQaYZcwUlmypzPW80BZ4(j)V15Oyb7kMGDf1wbBRJZzxeR)Z3JLGk)Aof4b6tf2owV5Slhwwe1sPRy0TOxHx0eBTHAZ5Ouk94PYoVe6liTawgQun09xbigbK0bmdzY0UisbBWSK005APUhOzhvxIgRAKY1mJe26NzdmIFeU8FXAXN5Q4Vq3MWZW1uexGCow7WeIDUY5aDVfI3V9R5uuIcc73C3aqfA9ar9NnAae7cpLu6YK5)5ULQmuaukrw7jEvvHwVQnzJY3qLbXvfhK41gj)QKKfuKFc3gXllxKLal0B6YSSUCUz0hSRAPG8GTQy227mMrSgiDSmwn7Y2WbQgARcHIoA8uGUwoS0jKPAES0UZ3eYIZ3pYmuNsIW72I3qnWF1N)RtVgC)hRE6C8G8asB2MMrwwHoHq3RodfeuagILiFPwjCvvvfbacYmf1qRJqZP2hhctMMyDiYcWl(B2T1PjJb6ag4wVsdHd1jU6HxSXWv57MuMF9N1agzQxqycqrZvencfUFVJ2Pf7sxdzUcjSltvesmxfkMHeBvZyTkEZ1(Lm7RUIhOPqmoYyObugjzwTMbWAV7I)TT0LkNCDdvlEXiIi79RYFDK(U5cLROHBXs5qeKfcUCaAAOdlIQEFE)7QAKa8Wf1UPP1X79YNAkqondowlU6IJ8EKIzC63)d1bz7aZcRfLzpiCaWillSCZLBQNn49MxQlEO7XsRxNfjYHSObvhrzipSYI24ATDhewR1Vux4kBwRIMWxzcH0nilzwFE9zbrxK8QPRrDE41nNpYUOQ6S6L7U9nbyk5drB5bbNlPVXaNd4N0cycOVXeiuHhhTOa8(SljiNDjNiKl9H7U9FueNe)7ij8Qa8efeMsNJowrnWp(A1JpAN0hJI2w9TjiyoTdVxB7h2MR3KUPD9MOl6JDQjGN2cn8Uv80AKBaV(czbOC5rBltY74gp6tekIflN4SiIdDF55B3XMLw970fXm7c)RKTAGdPdGt9SDmlyjfmsqpXhz3P6GGFWfZC8T1FFzqtCZWibbY))xFZp)tF)p9xOVlguLVeVgnKK7CWlQnN5fi58VwYQKf237eEUHWheY(cZmC3p8JXygg8GX7nPBGzME9l4Ah(3VGXIu)3v6hGN3F0VnWy)RoYK1dq9dehbpHryKYi04yE9yi8O2JYUFWbmdzE1(HzgFayMXcRRZ)uVUQCgy)wwhYgU421fQ9NN7ApHHOjD2)BvSIPUpst3zptIC7R2)z3LUBz2fb(xT)ZUNdD3X1(xV)ZUlD3YS7iHi3E3p90H2e8SVSx6f(4cu8Ck8s)OS)crFQcByJYKdboWplxF37(r3jxQdbXNEcgXf3Hip3w)RpTS1JqZtmr0QUnTVWGA)DfgSTj7oPYilJYHajTKgVNydvjAUcdJCJoT(sfA)OtFQ7XQy29T)kAyVoE9BOdqAb(rA7l(c2O8JLS7YJYKsW600TrGHY4IU)xm4PRV3Ig3Nk0CakWhzwdSc0iam0LFe5YHa0C6a7dNl4MZDO7wwmtSPqFpjuu7)bjTNlB(SdvOYZ945UsiURQ7hZ9HyVWONf7fSnk7NGVNQAaRM06a(Wgn4HbfTixCbmg7gHIqeJ3psLNQ9khoPIJSa8QiE)wvhIvu28k2L(B1doh6)4NrHMQKAhIkKNmPRKFqpv6mVNkHgFyoKDwj69dH0QYuUVFDvsvXKbXcYg77ges6IxqKPy6MU56)0FINi92FrMXxP9RYm(IMVmZ4F9hTVoZCy657l0mFa)J3xPzza7Z)xQz(8)5(R1Cnr3t)l2mFOEM)QnZh1d8l3mYLXyAZhw721XtpLDhTP)Dnh8C9VV5cYv)7vViOor(sKD65NeVy6rCHokzlT3rAsv9bnlJTnl6Meap)FVzz1DZYQh)xLHQtWuZpLJR43NNNKUDkDRREcnPt9oP5oMCkmKNuZfpTXZoXdOvV(npVPif4RZV4loFY0ZgSpG1OdfSgzaS0C3UwdwiH0)9UlD3bD3LUpBQvqQ626iXTvpHn1JmqSPFZ(XhnreyLkq4LyRRpZQx9NXln3bdEzFVHtowEOXgcVO1rKLr2oyWv9TYpi8shMspRtPhFkvLh(uVWvDzJT6IJIVpYLD3(4L0RJRpwxMl6YvLprngHREdU2R5v6U1wRSH97y35ha)jwmZiRdvAee6HRUMoDb3feNqy7AiCQWjlLq5p5JNy9q3Aj36WkYx(9D4qu(4JMoYMcVX8X1CqV(1KTMNKH0Xp9XhRBQHJEQql6(yNo4Xh7)eHDhWpm6G)jhFBztqZXCKVn0u(Z6p7wxoPNbRz6ZFU0beON9JvWLEJBAHlhTtOdp(4r6MPboTAbRCKyRfkYBIl7Yr90w94WYwYhGR6B40xE8KbiHHQHDvinwzr2ZqDuEjccnNVslmrnNJr(6rUKwM61R)r6pKpp(y7dl5vEtSG(eQNuTt2vthThZg7596B48oE1KhFugt7D2alaN(ktQsMIjZ71uZs96IYVHUtPbGyfXIgQ58jc6UnQ8q75r8XhnEwdl32Z47eqDT3zmu4WwqPcNVnvHcwojHanekETfHVH5VN6PgHcOWLNZrbDDEb5nt9ScYFSHZji)TTpJG8xiD(afeVR)SbE5eM5j73b6teTxDOHqFe74O01tRmVEg460ojsNqnWIuhMuD856GJAcDzORVDH)x13BYxipfhB5C4nOn19yUfIFIpQzArN8tU30lqejhW0a9xkdZ7bk1oYRNOih1dJ3atuzngskCQ4613Y5G7XhTDg4yO)N4zxteyLoICieVhsu6B)iSDz)LHZFj4dYGkXSToUbxcTqc3HNaPta6abZIARYhbtnMtyYoI2N(SRM0Z24ZaC8SMnONQAEc))j4qKzhj0gZzyRYspqCTMLJ9Pv0yPUNsjtR0pDyobczrW4jFiVebE1dqIumdY7UL1frv3nLFcuy2(304CoaliEQX4WJmEZuAW6E2uH)LFkHrEDLyLxR(r0T9dugRxRg00xZGg8MMgHwI5u8Z2E5wHwi(Z8W0sGzIppKgnl3gRxD((3b11YZfw2GPKm0mhd3nILf)8xlPf41ASq81n2T1n9uTT0Innt(qxXDmOkpv4Qx3XpRHzu5K8DP3zon6u8PpHDE7yMS0w)PPtgxxJVqM)1pWhzurZr6wScASnCo7axzQ34zsNK6JO4kSPTA5(iEfDBQ79Aooqh1BvuL(M0VB3TFlLNG6aAvV1mnmj4EIGCvaai5ThOlNort)qaQREo9IEs8pliotmUrmtybZ)0pYTSHGJiP3ttjyhsEL5cghDM9YCGbmdQdyzqTrWkZd)PkR3UwBE6xBYsk73sujiroeSDSHavtKEQ8x1GBMsXHu4Jaqp1n2XQgKpD0a9qDep)KCtqvpLsx237SJTIpE54b2ryxErpRRzUjFsFRUXt1ZbbUJM0XU3e7at3Z6rwh)UwQsXp5YjgJbJHqWCPbowj(khwd2rbcsxUMcMV0asQvMY1AW0t)mYSoPjwoYmR18W1XPJfI)7PRLsSzlZWbBVrPt98asW08C5WiIpxZcVfJUvC5Nn25kyBp2L11DvZy0gzclMLbGAplrK6YXFIMwd7uUmUsX198lnzweZBUvyY7zDhCr7(GT58WAWTGC(jy8kO09tjYmbBhvkmeVj7aIMFADvUiwHoOtvuaryElQuttChhhQFH2sVA)JGxHdx(qAn3jFNexkkr3IT3J7jH0gBbPXeL8ELIjP2o2PmZKLmsvFyJF8rDbgw3bz9YPJUqld9Ol4fuwlROBaOJ1u3iKZS7tIqEvV(o8T)RHrPJVYFx(kqMOddOqYQSmRY4exHHJhF2GUcAiSU1hUm9jfQxFDFqYmeBMZHrrxZvZiXOZyWzL94vFL7eKkz4lL3LEW2wJeznF0(E8rtFM(admpYAx7DKPUQAsqNWjStaZw7v4a3PM1WBm(SJX7JhTdHqCV06l9EennlPMR75wJWBttTmmIEmUFatV(AubRLCTLlvwv5dgN0uVaT)A5bZRjpB15KjfIDqG2h(23Ecl2xOQOvP3ZIJ4kyqsIykK41j4Fhl2Z7dOAHfAri9bsGv(pyU)XIcveld6Ik3q7kCTsxdylmOYbuG4z1xa9ve8dJEfp(C)fu0ZjSiBYQVH5Z5fv2Siu9z(2G7XRauP41yAt3NKKHB1UiBtl5WvtiD3F2)O)PNGwsgOKEpHehliP1sA9U8ReIrH90)jk72IkmmsSwt0PbUuZlkPGWOtNSN(ruZ0Bgzz9t7xN1KWEnVDTE8(6J7BYS(x(1MKr3qIPt(QvBXMEUymVQkqQhFS1J6s7nO6umKxoyNd0d95(0akxTX4hoVboHs6cdOBJ4Iohyn6tAR3ORP2K8AdQZuIPSHOy4D(NGIZXkRlpb6g5XS691OE9pGAMWIORR8oZQOnmeSUS8XiTQNn1nSXtMc5WqnDhUA5SHkTeAkoFkgaQF(4yADFBJ7QSmatvClOYnbZc)gewOpvtRcUlMvhNbujIFFAgDGckZYljFvJ38LldwhztzEZ5HH441JepYjkfBB1xOAjnzpBLhFmtNaT51NFgbKhpFEtLcbPrwbnmSx5DHvv2nce1wRQDV6mqfZYs61rCZ5ilscwqNujeiyv4cA8gE4wc4g3uFwF4h6MT0g5p)E8urr5KMh5aM5rV5TVqhUc3yvXwwqaQ2tJB5TTCwlM9SJv67lVyqp96JvMd9d45Nnq)6r1HlJean(YPuUsFIPbKJ6Y5xrSmSLyyAww5wXwRNGz0X9n5i6lh9QNkIXmEXQfAxHbGvVfdoHxEUGAfecMfQo093r4cShsal0khYssm3U7dHIbM7vWAe19b0OLBiX(pCqERqQYFQu(6jMNCGGUiMQvHjv7UT50fCUHTNMJ9goD1KvBbfSLySv5iEHWiDxAcSqH3LNMGZexnO6J9xvUoytA88Hy(83aeJ4q5hVED08yWbE0YK6NUmjDwqI0JeHg1XUsf51WIgf()bMJ)1lqEAONU)j9qtUp1zR70rNj6YKUtrXlNiNcYMwV6bI1m4LtgmqFeIX2srVrH45m0YDTS32loyTIPOjzCxEyHry7LJhCPl(S3Adaz)Bs5wFPCHvDSS1fJirPqBxffKLcoGGr4VFFTBIUNOTbTYM5aDqDRCW0H)CxEU1miH4Wr6MNwPaPE1ju00D4oNNTPwmEkFPrN8hOpdWIgCAbM7iTlg3XmskRiZ0QkTxIovyCS4LDLByi7mcUF8SEsKr7XgXEiD7PVpcKzzSZZIbi0nCSx9nKWFHbi8u2)E1YzFOq5un9trzZkNcMdTIzVuSOHea5wBp6fCPwojQAF(8uAnYWTy24nPtSdITQsONhpEmIeKVzONDcjDohKoJxqZSYeMoN)yS3ZjT6FzvVxwrOGLzMWHa3a4NzP28KQ8pPKhlwFuYJNmBIMGRy3qYjMKEJASTl1c28nKMndby5y0Svz6A3SxxEf7sbi8uQNIj2x4xACRWfaZ2MHX9I659pvDXhG)h7m(cmny4LaRksO0hTkgjzZJxNlFzFuDBhKJXTAUqelW8ufcg4as4WUhLf1KJjmmh8RUa(1nsbDhgeMcMjVXmrUoflCgC6SxiV(ukuc7yHZjb07U9NRkd8kiGxx4tL)8dyiAWxDXewqevmT14HERYCqEadQggXQ9KdaWYV5M4xYMPNEryq4fnFea0xRvMATwqU(c13bqUN2ppa7)cP9n8VQ5VgBOU1GYD5FTccU9sI3U50bH4pKxz)6wyYF5bCydAF2k8MyOs90sAlEz6RnQZp(yFfoeTrmC6fIHmSz8RVr7FMxLmjkTUk9TW4O5c7xhFJ4fFFBecEWKnqdQDQr3941FqMYzNP6YIiFkENyexeTMz7qSXJhVS2)NVeu2QsoOTDlYeALPg1dppp3qkfuN4jirFKi0heRrEggO4FDoSoOBnIPNPZY7rNjwmWviCmhwsOCZvlHdDopmilh78cGQkkBdWvJkjxe5qFvUjfCGhbW0W67kQ(MC4gvyGdaH5lTHNF4P3rMUfjgWTgks6kVHUZCWNrxSoO94r8lfO587bOtQkJ0zrvxPh0OYR0MTbSBos16uz3T9XIVb5LzwF5jwFly68WB8SbSFYQhMtF7h49Ajvsqzvh7wHUQhFZ)PNSFZTUjr6130Dqdk92AUGr2Ed9LFW2F(LAO706BX7rSUTQar2f2t1mkEhbvdf8zuOin4nQ(glAQ3Gk5fMw6tL)oNyzVzK77nJEc7nQxNr)bCVXZWEJ3ET3mQ1EJ6sxDVH7ep7(gmfVYnrVvO01wlqO6k5IS8chUQsmJKrWV1bz3fGCqD3TVJFxATjkM9(UhTzPOWc5XXQC08K0IPUYLB6c0s3fIvnMwH1PQtDiFxeU6Kc3WuO9wKRnCjVyWpLqLfRsZU56RJxJ3jJam(gmTp0NsOB()c]] )

end
