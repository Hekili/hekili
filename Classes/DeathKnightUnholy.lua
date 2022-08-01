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


    spec:RegisterPack( "Unholy", 20220801, [[Hekili:T3ZAZnUT1(BXtMOvY2r2uYY7M9kPoBwN2Bstt2joPPFY0ususmlfPkFyhNXJ(TFph8GeaeaesYBUPZ0p0gVIGahCW59dW78U7NU72fbfH399dUCWGlFZLE99E9Ox7D3TfpTn8UB3gm)JbRG)ijyd8))ZjRtJFc)5NItdwGVDEAz2C4rRlk2M)2lUyvuX6Yz9NNU5I8OnLXbfrPjZZcwwG)75xC3TZkJIl(MK7MPDPV81WCUnCo8ZJgatB0IfH0XgMp)UBVjmOy9U7)7jrRwxS7EkaT7BFx5QYC4F7D(U7XPB33U7BF)6GKvH5VD33(f7U)Dl(vyaBctkY3DFr6U7Vj5MlUjCzuC4fK5e(5BkdPplnbMZ7NNwMatzrq2Qq8TECn8OGmymH)gaGfHlOJoo6b43IttwbpjjTC1A6VVjOOimB39Ddsd9Zdlk3U7(pZRxFc8CtuEWSyCkUnyEw0YO5rbX7U)dbZHLCw48GYCysxegaJy160Y4CCc)i8BltH5mh)9B(750j7NZJWf)xaagNWTHjlWfoywuCurui(QPiCVmo83IMH7TUbWYC1zWevaNWWaIsYlilw6YD3p6SE)pW0)HB3DFsyzrgczb4uVjaE3TzHpeIyM80nWKMK(fzHZH)vurj5WwgO(RHWeNr(ZBlYIWDqucCE8dFn8hWA9uA5U7xh8azMkwtgyyCo7KyrkBLFmn5vWsM(qy28GT4)g2RiCNldO01ME0ta4eaIF1sKAXplCtaSpFfE0MSicH1Gyg5qW2TiEbbTzP5WpsELCoTq34q8hF)nWkhaBi83HxmliFn7a9DaD6ceyHnbI8)HYIzzHbFePjkYEIUkavWU7r6G8ImGEbh3xVnAr4MO5mS2pggh8BaQ6N2D)dWprXtXPRIiy4K5i6dMJSWyY5kcfWMzzWmKtdbGSGOf(Kdi2m(t)Wn)WB3DpCsa0wiTdCmeMSc5I2MLoNC2JWgC4K8re(iRw)7UnokVihzXROFH)X3tezeMqiEV7RU7wG4fpFdqguGnY)JeoZ(ljhqHl8RyFMaq6tZJd9dtG9lc8p)mHc32lnfERr0rEcYkgd7R(ZkZYlacf)CGQoVpdyOJInKfeo76h1HEMxgv0)Xi8acF9vz4Yj)(1OV(blwat(VHybYeO(ig50U7hdaPNh99PepDy0p(kJbWLZrYo4)M8K)IKf3vaY5mIrHT8dbWFbpP)200yeOZktIM7Vn9rK4bwNUWAwUCz)fbzF0hiitYbbeBimI9rkneWltcHFCvyFuEcs4u4ppnkwc9Ga2dchoiapKUNuFe8Kb7UVx9MHEiItjUFgEO7N6jmKXuGt3vkthFml5cw8ZjYvKjfj4K6HqiS6te2vT1i0ePXlsFmPFW205bXpTnpu4yfgfmPeAwgbjs(dG0OxEqcOo0VwxFaRfEG3ViAdmxP(xrM9UcBw6Xfiw1FbOO5P6DChrUmvwiKsqykipu8nT(Aaxta8qcBU)YGqzSpbGY9xukmJ90JoETb0bbB6Ntv9rnwilAl9z)Y6WeUECqk6JbBZzkYxW0cdwnaQEqD8rXGUUyCCeftKjKYbLFrLohrDLpgevquAr0lRAvXROMv0x80PlbldcuX3lVpzx6SWqfrO9iis70wt5u7sKfdjKf1mau5rC8pGQlOc(jcBTl4xNOJr1hnZJdEKqNUoawQC7I80iR5A2ESvCZqRRPzXsTOwHkKTDTBQGUJNOdjNIc6USahSrOS7KgIdRONj2gnsBLiBjuz5LOf5(lst3aule7vzQNTRRQ3FsvxPkmxsmkh8jI1MJwErLL6D5U7pRvK9P8t32pxgZPZBfpsSYGCq8yq2g8XBatuaKNE1NQ6pAF7nyKla8uIHzTdW6HkvX4s2i0Yk3(AsrsQwGvzj5bzJNKinXTYBiMiRxnu9oeg4x(IAxeiEolaDAmxNW5kZmbVLsq59zGn)fk6f)r273gnbCuF9io372WI(RGJI0NaGLYQPAFEE5MnPj(vJQIVTxTAO6jNOSWQoHkCZMGFnnZNRZk3xC51cxDu(DjZXjmrZIttx4VSm7P(lkZiYHA3qEtVznEV(H2v906wJTdao9N8jXbO)lXMomlpm7JazMYM24ET5liSxREODfiKzQKeWg0MvIpOsITIjUC7)RLlwHbQXML2bGNW5O)((Gz7Xk01VJ)qWH9a0EoGhG4F7kIh3GbXBtlGfGeXfeQYb7)anzGhXXb5uR58gHMOH(mIEH)ZfrXr)oscVoiBbA2eXzF0wkqFdAnPW8Jot)XWWTCp1dwqoH3RJ9d7W1Bu70UEJSRvqv75uQ6tCA7QL3LZtRrUbA82LsQEzYJ2wgNhAxpWNiue1q5OSqch6(YZ38ffCiJ)SkLcoHFXJejlJAYH0cWrodeWXZcw5NUemUkA(hzgYVcwo4FA3m(wvQkaKgmcuVjfife1EPUIw3LfSzl4uiZkWqy7oxqxXPKTLQnw1V96Nio7eWhzVkZOnruGVRKHInrKOzDuZlm4sf)WGPPJiwgX1Rd9xeSjjCHoZ1zNOZiY3KgadK4oOj6KU8lvbKacz18fcMwo2Aum85HQ2K1VM162DVDPNrbWoG2Uomilfmeq0hMkNa6A0ioURthtK86zXcqrPr1bHZSk6wdCZvmGYEOK4NAdSechRQpRWvlk3S1NhlIoT69FLagxitig7HQr(cfMvtUI1ZM94H5w800SFxogoJwOFSWbRviA32WKNYoe7zD(RHYwPlKX6TX5lq4d)3hGjdrSvsFGZh(PIfKUz9(osM7WjToYAR(75MVpYYTmRG1v2HkzVdAJAAFof9gyg7dkI5In160MgEDGFBBCqscXMuJ2zbl71nuGOtoKSFATO9Qo8SAIvtDCAB16eX0EifZcD6F0pqz77VfdplALnjhPbllij7e2U00bIwZHjQdTlhhvv(kzjpClbz(JFaZOBeg6vwOyPzM7938kjpITIpPOCdMm3rFuQSzWCvGL0mRNsIqevEBf9bgKcgYwFWVM22cEfXaD3CsvLAedJn4s6SiG)kgea5p7jGBamRtrH9))qw2rjI3xr2VeHduKX80SSYTYVxB0Yd4hpvB8pg(akfin93drHgswWo4nY2BmlfOPPYTJJ2mZrf(QODxX5lsvS90h)LQTZ06SwEId2Q6iE3(U1Ss)23Tgr0DCq5nYtwPbR2Sgbym3Fj4cYV)Ks(GDBOTzaylOfZQL1ZPFaK22bah8dx9CPnMAMWSpn82TXMkeR281abaMhryjltEmnRy9t2TGWioVknq15oTaCYMGr0fyz5aVCLezGjWYCuIRye2wMxuIzbKFelrXwnShsXIVcgxEAmbMeX0NWixuhK)6YnbjPrlirMlkbwBCv8JwkaaQVK0a3SjCrewxx3kO3FzCy(AsvGjo2vXPZcIXbsmocuuppDZSG60nYF9TP0)BnEHB6aFeaQpNAfSYOgkokrWqAuMkYaj6vYKlz5ABb8MIOB6RSWE1h5HV72RSgTZJgkCbegQtsukqfa2hHh)1RjRuH6x41FDqUpygMpsmX5reECndDvG2(Cqq8isCVOHguY0UV(HG4sG4jNhsvCIYRfmCoMZ(hIirFD2t4m1F39)en19O9EZxNMJj7h)BQQmSuXY(iZSWRQIQls(NHvmijH6yaGNvwGH3Ly0ykVYXMVamTmC5sWaFM1KRiHtkqqw1VjS5qGlhleGiAncaq33Sedemwia4ElKTgjPyOHrXdKs1llSOmlHw)I0QFJ)lx2FuFIijFAjyYWj(E(5pLmVMgHl0c)lyz8Xz5UBH3M9duUSgc6foF1ntQR6a2QQHwyGDAHbUqlyf0vfyRL08ejYVgqKrOLeXj7BLw3nxOog8T9RF(0)cECEPhpyLNstLCFACovwD6kxnQkDsYNe8PAAdiulV3fQJ5WGqpNGqpbiuLnphe5OHnNXHmJu9TB2gKruTcI9Qz3OvDd5NyVNQmbYZQ3tvdNcVOBpBZsXXJz25)LL9M8QIICt6IOLr8e5uXUVgeCI)42SOuGAJxqNvVgFtCov4ZJHyINytE9usksiSSxR328IocFc9VssXYuIG7WqCwV3Z1kjGdrTjlWRIDAGodnyStgNLQ6KPvB4CmivMe8pVKKSAIF5Oh5eCg5e8FxcQWi4E8q9DvgDIET)JvYPfXrllJJ9bH44g27Y9Ehlf)tSe1MhMvaYSlEQry8BpNgIW1I5(zf8qcXoCDmKqVS5dBW1TAm9GRByiM1eh4Ir8cbndwH3WfXg(VlJ2UfiOwf8qymNSzzeOP2piBwublnuvlrXJrGE2fv5m2F41V(lhnukY7VPYjeNMECSonqTil3HmqG6WlfYisBX)Tcpz3tDNCNVArbYF)zPjL5GJmHzdEJ)vBNZweSABQCWC7CydmIhhy2AO)L1K4LPycaL3RCZrdNNLgNMP6cTIlQsybVkYfhDoxYRiJrrOx1(YXPTJCaWmoX6ZeLd7vgfcdQ0HZ6zXhbRH0Zc7(Wl5zz0(KBoWvQXGSkK7MjQgP75lIc5w2GbUcX0aKgSnmtchjNtpHrzZLkXHjAnBlqO5q9E4WoNAwxWIzzQ2iBQ5am3TLcTuo4waOLqSiBbwuPBaSvMgPfN0s8p0LuyQ1F7tLTljZsXmH)xGPb2MFf5zmtdWDdAlwDf7WSntWcQABfa7Z(bmTXG4z8VjPqGoMBamf4mPmQ6fiuyY66Enhv5Y4zjJTPocRXhJNTzIEDB0a9Cm0FnYYGnRf8mDs6wm30GBBjo2UPXRgQ0GnSh4Tdcp49LnR4ftjrhCG6lDbeBybRdYCDnS4DLtbk3Wz6(uZp7MrltPL(JefVBMfYEZooC26ebGUjAlG1KeZjQpTIVKG5T12BUHGTrRCTX11u(rfgMfQGA1tUcLMfXRxiUNzBm0xmy0aH3PDshCKkDPLBuoKxuqtVCyrja9bK0TwRpIbCEcs96chpAQxxRsJ74EcvCzCoI4QgVdzvzydr7b55bLXez7EMm1szOVaKRVeyBzrsM6ioUQudMW4zoXDNW86waQUtx2keRpt)G0qDrbamRrWTAn2swpZy7OjBqln3acVJOiX2S3TPJCJKPS0AylTAQ4v82L9FDLnmATX1E4e66y7EqoT1uxQ9CYC4oUON20gGcaAubFyTjRPDctpNBLlLTwOvYKAm)e8EJePXjc8WeQi0CK5GfYy5XpJW(r6wCmECyh(hh(f83MrfJ3icyMvIyParGSVmXN(3(XKY6blqS5iFKu8JKBXr0sgAZOZIDgVyMT4DNsB4irm1QSZr2KaXfD4s1)vr5zX7FJsEoRwAFtMqR7H90DRJOPLN4AFupYfK24DM6bAtn9RnqVTJzRNYTcrQoYygIK41OzQe)F0yvdYlWmuUmkogfJ946iKllpAtU8TAbp9K5O2KfcL0gM5I5aCKfLIVEi2uZewtWvfm5hSCnYUxnkijDCE6MnaJrFnAIr)QuWf7012XUG5UIQAdS8JO2xnL(BIaA(LzHH)E4DY5Ixvvq7HPxmYXW578SYc85(K8fuUbyTEiAEOsODRJOBE0QOyLNI1kiGpJj1Gir0Q)8SNGDxSo3XnVOOS7fpPyUHYsl7kB1Omdcc8603P7l4(YbmPcv9hQUqyatWXeDTqmNEZcj0EL54ptJ0sqzrkQ7LOQGu7W1zgPAo8ztHoDLTtsuBGIsvrOiwQZoxkFIUo4D5Nw)zC0l3EIOsD2hOXAG2rMTyePsLuV)2u6uqsnfGX6tqTTksLEw5lSIXkvq3adiUWCD2z0oktJXGvT51jnRumElitIkRYZWGnXdeOeNsThQ60VV)WyT7x7pqk0d1DTuiCtRSfOjvaZjuP9Oqe30ziq77XUoXFFI5uN2UGezgZwA(5UYD5hZP49SVYouFE7y55AoIS5EUHSaiD4Ppt16mFQ9ZX9kE5DusYOKWcJWEf2P(2OrQ7xQqVBcYYaHPl8xfUjVinbrrRXosEdrY8wHHwSodSTZppm8JGqnPhrsNiQNdixWRdS8OINKhHA5Dl9W5RdsZ9NfKe2mCgkexkQ8KoJeAMmDbbNFEKYUnZu08)pG5fRhcc(7FgLvgtSd4dXbRW64bn0nOUKzK8SaK3)a7fqXyRi39paojFnU4CUYw16AumL24L3C7SFquBsmBpo1TUHClO6DPe6x0eKoJQlT5or2IrD7KH2YwxJiG3exI2Y5JPn(AdUwOauecsva5fbl3ggSJSuywwLOC)PynMPwWAFdTiYq3RO3aKCyBtuo9Eo8F(bSYVy3IGapqxIdByzEsV7flwJxcbPKBWVTOZExxLUYE91gQFPiPZImvEj8U4DBquIkvdX3nqmciPdygYKPDjEFddGEVuOJ6UNMtuDX33qiwKVyrOtmIFeUBnXsGLwdE)k5U6CgUNczcKZXs2JGyxO0(v7Tq8UnFmJIYqakj13ypr9NAUpYQJeSUei8)FrO1qDh8YgMwsm40fJF57zTGiEo5fV8ZyxiA06E87PjU)VINJK6RKCLSvvfLu6dAygdYd2QIzBEYygXEi36C8tzB4avdTvHqrhnogORHdlTczQMhlFROqaKD3)Dud1j3QQ)WwmwQW)Ql7VU4wW9FSOfZX6NhK2SnnJyzf6ecjMs9feuG39kYb0vimT8iaqGmtXlZ6mu3SS4uyY0eRtb)kscdRKjJbAbgywVsMchkptn9mu7b7D8oHREcR36cMPoytG13UnsoTmeEvvUNTKdZXMnIXVaYS(IKfrMUFja2QJhszsWviHEZgIqI5uXygsSvluDAuofnQCK2PjMES0et)urtW9v3nuTyUnrK9(v3GoYMwNtOcbjpwUy0SfCt9Pl6tvfUyS()eU5LA5kattSa6OjOLC)bLiawiE96Ws5hCwvSOYKiTrgP9QfyGNLfi6FdUS9BHZlXRsBA7)O3whednMC37rpOTCUPj1bmIdJfXDn9GLXOj(ZSaWnpilhFNLzbWatcIjz9zzy90AEiAcel)LuIGVw1mwUV4WZDYft2uP6h2H46t4PzAVvGbljB1Ckf(JeY7ip0gzbPANzbCTKLuMmfVgj0lCNyJ8q6ei83iTle6LtiRvNwW6UPZ5D5ZSqEsriWjZISTbrz1jkrSfx6IMptTpgJRINy5UIMCJ3q99O)jT8yV4MFI9wRal)liD0eXjuHxT3DYLSsD5pPMgg(bu3Dw6Fm(LqxN2tZoxOPLMrtoyEF6fdBpMNwJSQyjsR0iFCWrz7k0bHsrs(b12ORUHZO5qOxtHVwWHtuenRlk6hbfqJEC8yOaA2WK)NofGNnkaVdIcyGDkGM4WguaQY0gOlI8nL7LhNwi(V3hQMM4ex6tyjSstgR6Pqx06OF3osXmtIObsD(xbs8gaLeEACo4Dcar2n7l4b9BRbdwaFLzDUzsye95TpBZsrH4sZJTGSxDECW42w6bBtuC2oE6PCYp4owFlcQrZrWM(5751Gtu3(yqgMkaGe7xE3p(9FZ3)3iF3ri6iJ2GrsGfDOxv5i4RWcsb0zt05r)EYWkoa8hMt)c(0F33(Dr4bPhmFVpnbwzYJFfZ82)1ROXsQ6FZTWf(9Ud(TEgFFERQwnbv)G4m4jmdduMH6iZwnhc)KPz56dEFS7BDaZsCSD)WSdpaiAOWo6QJeV06(Ir9LVFBRdHGX6bfJlXtykQzC(xQyftV(anVo93KixF9(V6U86wwDrG)n7)Q75WR74E)l3)v3Lx3YQ7iHilsdF6PdTj4AFzV0l8YfO4Lx4N6SS)cHpwHn0zz0Hah4NnTV(h(o3jxQIH9NEcgXn3Hip327x1LZvZq9VyIOv9yAFHb133vyW2HS7KkdSmlhcK0qA8EInuLO5km4ODdvxgu7hD6XEgRIz333xrd7TrBEpPXFlWpIEF(NtNLVRKEhSugxIXkzBi4BeUP7(59oE99w04ESqZbOaFGznWkqJaWqU0Qiolkanx0Z(05cU5khEDlBMr2uOVNekQV)bjTNjB(YdvOYl985UsiwWw3pM7dXEHbVi2lyBw2pbFhRAaRM06a(Wgn4HbfnixCbmg6gHIqU62psLJ1ELdNuXrwawBOSF7QdXkkBEf7Y7B1dohE)HVGcnvj1oevihnPRKFqhlDM3XsOXMMd5KvIE)q2issfpeAtUTGFZgEz9G5XNg(rAxBI0(3DlWsSon7UBVT6d497P3zQBZsXsi4UB)SpJvJxn)uCJps3NJB83R)KCJ)R)S9z5MbtVCFAUzt4F((8Cldy)X)j6MT()r)z6UIO74)uDZMQx4px3Sz9a)KDJCzuM58(v(ZD2KlOxAF6Fw9nrG(NxFJjR)5Q3myNlFRcp5QZJwo5eMWiLEJPZjAQ(OdAvgABv0TiaE()EvdR7Qgwp(NNcQZXsOycdxXUGxppD7eY1W75KfDI351x6OtGP88kU4j1UmkMJPoDR)96m3Y2NF(NF1Ojx2BFaRbhkynWayP5Y(TcSqcP)7Lz7Ud6YSDFou5qQ6X6aXJvpHd1tmqSP)W(5NnreyLkq4HsPDF6FbVfL7170UE9hDM8uJdeEqJS8tjB71BAxR8dcp0HL0Z6s6Xwsv5Hh7nWRlhS8Bsm25it2DZgFStl3NWUSwKBBx2cLjElViDL(2P(r6UgF52W(10Ywe4pX2SbzDiLSg9wxGQUM03BpeeftW2vq4eH78ack)OBC(QPUXwUrTcW2(DDOy6E(ztLrNWtmxgD960TIS18I0NCXi88Zvd1WLIGWiA)crO3Zp39iHDhWpu6G)jdFB5qqtd4ZogQ2tg6Q4XJ6yWAMUSFxQkO6yV4Og7nSZEvtuWl88ZNOBL650UfSYrITwO9JiCzJh0rBFnbBBjFaM21W9cWzJ6HegQg2XrA0kDxyplvA8JrqOUZ)TWev3H9S9JCXHnXRt3t03(Pp)CZ24FQ3ilOpHweq7InDYG9y1O)ENUg6e)PJE(zzmT3L9SaC6lAxUmftM3RPYX70gLFnDNYaaXkI9SzDNZd6UnQ8qB1X)8ZwQKVogFMaQR5jJHEbXckvOZRvfkyPh3bAiu8AdcFdRFh1(zKeqHXxXqbT1j7SHP2f7SF2qhSZEAZUxN9aPoxxq8U(UwF8iQ5j7xRMlI25TZk6Jyln5DhTY86yGRt7Ii170GfPoSO64Z1bhve6Yqxx7c)N21B0NlVeNzPdX71K6EiZcXpXnbTw0jRNYNCnIizaMgOFSmmVhOu7iVoIICuBt8EMOYY01V2D6APdTF(zBDNnf9FKDvTiWk182ieVhsu6AV5Qh3D18fNc(G0JlMTrhKnggHeUd7n2Zb6abZIAQYhbtnMtyYoIM9f90rDSn)uah7c6EDuvZtW)FcAVz7iHMyodhvwEdexRz7yFzfnwQ9LuY0k9lhMsG50iyC0TFSiWR2tGsXmiV9rwvDwTpuwNetT9VEW5mawq8uTXHNyS56myDpDPW)LFkbJ8wUyL3QEZc28huMR3Qg003sHg8(hfHwcZP4TmA5wHri(N5ZtlbMj26q0Oz5Y)B6v7)lOUxEPWYgmLKIMzy42rS04N)wjTaVvJfIVT2UT2PNQSLwCOzY9rlZXaEEQWDVUokwWcadDt8yVlRWfugwbfFkCWWqBmY9sId4jb)mPzVr7YMLeU8ZPD0n1cQMQZp05xOch0pXMGCWacD4Ej8OwC)u3X9tpwCp6fx7KEmCGoMjEqUEx6xV7(VIK2IQ4RvD0mzECWJe(J1baGK3CIgpzKM3dbO2EZjx3rIDEjrqbgglQf1G1O6N5gM0WqKKNtwsWSOCU1lgMDfGbSkRfyPxLn5kRd7xv2VTT380V3KfC3THKBY9dn44CfbQMapXDF2GxVsHfv4YVUJ6b7qv)dMmONEOMFduZSiw9BbW4UExEMv8XPd7zhHn(6ow3ZmlqL(wYJnR3bbUdg1YP3i7at7R6jwN)22QsHZz8iJHeYqeHgBGJvIVYH9GDuGG0LBj5wqAcjA5MeK8K)IKfuZgSXSkDPe3kV6O6iljZRwXcxf1qAchEK0NF4WwLHt2EJrN45buGP55Yb1e)Dn77g85wrL)HXnZHT94qw3RRAuL24KyXirau7yj(yJh(jAznCs5Y8kfL5Rg3QrAUALWXzIanwc)YAS0f4xC)GaYT5SG6iCR)xql2bsACJXXrkeiIOa6TNB(fv14Jy9jHUusche1xzLk6I52CF9i2gQX7Ec8iC6Y7tWXTYNljvavGyXZJHDKoKgoUMeJkeIJ14sU(GsP0uzf)eQtcsMORpO5p)SUWIR7l054jdUwRaKbxZkNUg(qudqNPPQziUYVpPb6nD66WNcZAYTw(Oxo(nGmyhMqHu1zzvLXjUcdNn8YETfYuyFRpyH6tjwNU6((8ziYuxbZIUHRMpMbxsHtoVn)J(OGuqdF4ih7bhB1Aa08nS85Nn9vReSN9eRVANtm9QQwG0kCcNeWQ1Ch2ZDQzn8gdV8m8EYt7uie1pTrsypILOLet2(ARrzHPLwggrhu3pGPtxnQ81sUQoUrwnXamgQUAjA(XJewxtosRtHfjbdGaTF6RU5CAK)qvrRtFKgf11WKehsviXQsY)bwQRpgqQeyyeZj3Wn0IFcR8bSKyfXYGUOYeYPctR0Ta2cdPEajne0QRG8r18Ng8gw0j)BOONZPX1TG9n1GvsDZcr1N5BdEeVAULIwLPdDFIKm8O2fzBAjhMoIO7(p8VbM6jOLKbkP3tiT5csATKuZXVwWyh7j)uu2TfvyyCOTMMxdCPM3usX8rNozp9ZOML3mYY6x6YwRiJ9ADBB)49LN11KBeN(LMKrxtIPt(QvBXMCLyi24Lh2Zp34NAt7nO6u02zhSZbEd9z(1akxDW43rYEoHsAddO7G46wNyn6tAQ3OTLU1q2klztjI6gcAI3vFcknjRSUSYhWipMvV9g0P7buXiweDn17sRI2Wi(6Y2hdSRE2u3WghnfYHHAAp64Y5cwAlu3AcKyoO(1uKQ19MA3vP5)MuVXGk3ySgesqyHCx7To4HiAvSgqkq(htZiTtrzwEjXx1OKVyvWMqBkZR7gichVEK4jorPy7O(AvlPj2ZY94JA6eOnVQ7HeqESSzorkINgzf0WWo17ARQSRfiQTsDBF3zGkMMJ4BdzMZrSijyjPpTqGGwFpOXByR9eWmUPQtNyTC0wYb5p(bYhsn0ErwKdOMh9(BELoCfEWQITSGauTNgpYBA5Swm7LNP8UNEDVo61hRSg6NWRUSN(9JQdxgjaQ9LtPyT(etdih1LRMsyzOBX5PzzLBfhTEcMbN11KJONo4nhlIXmEXQfAtXa(Q3IbNWlVuqTccbt6vl6(BjCb2djGfALdzljMz79HqXaZ9AypI6(aA0YeIy)NoiVviQYpwkF9eZJoqqxQgam6UT50tCLHJN6M(dxUkYQTGc2sm2QmeVqyKEif7ty4z5PX4kXudQ(Z(Rl3eKKgHFhvppkbigXPYpAZMWfrGd8OLjv)6Q40zbXs)Ki0Oo3CvK3gHFuAbNyPo(xTbzz9EY(NKfnPAvNTUtgCPOlt66HKthjNXZ6rV(jcRzWPJ61tFeIXXsIEJcXZLOL7AzVTxA0AftrwKHT5HfgHTth2BSl(S34aaz)RZWxxPKzWBwDDXisuk021HbzPGdiye(72v7HO7j2RxJKN2thu3iNpT4p34RSMXkehoq360ifiv7oHsgVf358ST0IXt5lm6KFp9jCw0GtlWClPDX4jMrszfzMwvPDk6uHX5Iv0zUHHSZi4EZPDuKr7XbXEiD74phbYSmA38yacDdh7vD)q83czFbXjviWhulM)(cvV1KpffnSCkyo06fESynkjaYnoE0l4sT6vu1(8htL8id3Iz)3KoXwi24nqalE8Fs(uZBc8ZSukGsfAOuYJflhl55tMnrtWvSBi5itsVrn22LAbh(gsZMHaSCgA2QmDTB2RlVJDPGhoM63yK9n(yJhfUay2ommEwuTUFg)AF4pjF32Dgtej1Xmk7pLcLWow4kIa6D3)J8IGNdbSQIFsq28GeuwkPXXnen4PxpIgerftBn2YFCZbzbmGpnIfxkdaGTpT5zwwMj7J0Xxege8s9Sx1k(6RTltJwlihMLhMHEP5ai3r7hbO9FJuTMcBeT7HMdu3EGypuEv1wuPGGzVeV3xiLDjw6FyZDqVYIEFawyrZdi3qprRixXoxb8iPfW8qYGlor4DqbOFbyVIdYPrZt47xs)D3)ZGtGr)Eij1SzlW7xcYLNbTR8z3zfvZpYj9XWWT8RLNGfemUUnwahs9XQO2HdO95OWBKHkdulPnJ7ABzSUeRnDYGNFURchI2igo5AXqgwp)lJYcjKSVW7sQef(K7cJtZbRLVjyfXkBq23h1vd5EYTkSanO2LgD3Jv)bzkDoe)QYiFcEJGeveUHA7qKXlhazT)VCjOSrLCqo2TitOrMAuV6ay5gsPG6e7Fg9rIqFqSg4zyIe(uFn5sDwEp4sXApMJWXCyjHYnxTeo8Yg)oC5W7QCps4apcGPH93us9n5W9jrphacZxzfV8WtNtmDhA0Jznu4U)J(JELw8n7p9K9BUX9OsNUMUbEqP3wZfmY2B4DzT1)lVudD3vbw8EeRBloik)5Rs8gsQckyROqrAWgu1910eVEC5fM26tKeKy7SzG7NndoIZg1lZP)eE24z4SP5x4hBNndAC2OU1vpByoX)N0pUs2LJIFgJM4kxUPRpmDxhyvyAfwh(l1I8Dr4QvkCdlH27qVMWL8MPh5d50D)F]] )

end
