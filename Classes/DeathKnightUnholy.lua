-- DeathKnightUnholy.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

if Hekili.IsDragonflight() then return end

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


    spec:RegisterPack( "Unholy", 20220821, [[Hekili:T3ZAZnUns(BX1wrJKTJSPSLZmZz5TsIZTBYMnZuXZ(4tMMIIsIzOev4d74uU0V9R7gaKaGaGuYEMnxvBLkjYK4rJg97Ub4TE3(HBVzwqr0T)0Othn60xpYBO3B8gn6n3EtXJBIU9MnbHFmyb8J1bRG)7)y9Y0KhXh)ysAWmS75PLzHWRwwuSj)TNCYI4ILLthgMU6K84vLjbfXPRdZcMxG)D4j3EZ0Y4KIVF9Ttnp3xaJ5MOq4XJhbdB8SzrS2gLhE7nxhfuSC7D)T1XlwwS9ogaT9h(6YfL5WFp60JX)ZOrB)HT)W3Umy9IO83U9h(YT391Z(fOfRIwxKV9UI0T3D96Rp56O5XjrNqdk84RlJyVlDnmO3fMwUggZIGSfryVEyj8QGmOnr)gaHfrZyToj(E4zjPRxaVzDA5ILSNVkOOikB7D9dsJ8ZJkk3S9U)K3GHe8CDCEW0eCiUjimlEECyCqY27EFqimLtJcdkZHbDwua0IfltltYXb8JWZMNcJzo(8R)B5Sb7FKhJt()cayCa3eTEgoXbtJtIlIJWUMIW98KOFlEkU26hatZ5hbdubSfdniEDEbnzPZ3E34Jg8)ad)7Vz7DRJklYqilah6vbqF3KfDFeIzYtxbd660Vmlke(R4IsA3wfO(FJGboJ(5nfzX4kiEnSF8UVd(bmxpMwU9ULb3tJuXsQHrj58DIzP8z(H01VcMY07JYcd2G)nSwr4oxfqzZnBRNa41ae)Q5i5IFw0QayD(kCRD9Syewds4KdbB2G4fe0MMMdpK6sUGwOFse(WV9AyMdGfe(COJzb5l5BOFnqOodbwyrGi)3vwmnlk4Jinrr2JSzbOc2EhshKxKb0ly7(UnXZIwfhYXA)CusWVbOQpS9U7HhXWtjPlIjm86qe9bJrwucTVIqbSyMhmfz1qailiEMpTbXhXp8URF3B3EhSta0wiTdSneTEbYgTjlnK27ryd2Cw)re(OzB4T3KeNxKJ84v0VWF8tKqJO1eX7TFZT3aeV4(BaYHcSr(FKynhoN2GIM5xX(C1eauFmmjYpAnSGrO)PNis8261ywlpa5ftGf2WPLz5faLIFoqwNpKdnSwXBYmI1U(v9yB6LXfdFig3HWUVidNo1(xJ)ggmBgm4)gIgObq)vC6PT3DjaKEES(ZOE6XjG81AdGmdr6o4)V(r)zRNDBbiPZkkfwY3ha)cEZWnPPjiqNvUoo0Ft6di1dmp9H5SC(8HZcY(OpqrUohKqSI4ehIKAiGxUocE4IOHOafKYPWpmnorb9Ga29sBoiaFgBnP)k4nJ2E3G6fdBtehsC9C2(UEQhWioxboCNRnCI2mxizXpNeSOsls4K6MqewdjPDvlnIMinzw6dRhgSjnmi5Xn5rsBRqRGbLOz5eKi9pasJF5bjG6W8CDXEmx4g(WI4vWyL6Fon61RugHNyzAEs)kltkbZ(5mnmmLYzXByV7FTmATqDjiS6HGn5C9LZ4k7aLZGeEuvACcOsjbBhj)NgqgDA(jvI2Lvj9qqCbPBGu)PR8(vmT3dLXb9jjgGClSF5dPvzNf5OjOAarS4Eh8kbnLcY)m3i)c4Fi5RKin3YxnXGoUERjmj4bIAyzamv5UfSyGJ(c(ASvCZzoNt7m)Ti8MjkRdZ)(Pe5mAxusdHd4G3cTvNst6Wm6zJTXGmnfYwIklVeT81FwA6kGAHmlKRe0TgHb)bvPGUitfHvcWNuBhIg4CjTg8oD7Dh1kY(qXUB77lxkOZBfps6YPnIhcYwHVEfyiaG8mRKsxkD7lVrJ7caFfz(t7aSzOsxmUIM4wM52Ntgss3oNk712llPuePjVuEnzjQz1q1RqOHV5f16dq88cGepdAeiM2Ka6CWz1BQeWd(dNaiJGnWUDLg2kWguIzqIOCFufdHBfvQs2ew4F2ybgUPfMvKkUagbN1IWzeJZPd)QXcEhJm7U1J0VJej2eP9hvPv21I9meo3nZBvSP67NxBrfQ3JmbcTGsYKQCWHMqWBUPKziKRClJiVfxKe9LIEZPIXWvGrkHBC1WAycauF2V9XMae2GzLHfibV0Yxt5ltnh2EFwiI4tJlJK1yEviMCApoqG7n2LLyiTcZCGwmu7CjkVMYVQacgnraaTZIcdESgsoIPAYG4VRAznm4LZi)xkFCg3fKMD)tS5QGlqVTTzN7YTcrVUZqKcV2hixtW)nA(8isEbg6hWlJeum2dlJrUS84v5QHC6yu6f6XdgMUzsXhlaEwiahzXPy3JqxHiwtqNhg4MLb5sb9czCZIctxTcymgAWy9zPf64cJge3fm35kQ2C73rRc4LKGBrWOzBGqzWmd86llGply1MG1fCfbawBDOuGCoKOo0nkSU3lFKwZbIwoOYU)nGU0faHs6JWcHHtRuTOOROPebKzNzpulsE4A0blgF0pDUpSB7ply16OzM8VOKIET)0eAji3aoij4GLfmQ2jzjscv6mBHV0jJVVie22ua6uLVLySHiGWuG2h29gs7l(ZdIQOa4BqBwgfKLUkDTStxvsJTBqHWxVNta(g4WK1bgJnNDdbANhRtsFf7AJCiNYPdJv4QzLR24lcEsRcbipuBdc9RZ0bx57xQXSAZASbUCGik3HRX2DuSv16N5EsDQNJBNztsJ(THjpKVjoOl6rVQd0fQy9248Li8H))9WGr2WjK(Gg5jWM2r62DFTJK5DyN2ezTthu7MT0QYT01931fsn7qLS3rTrnTl7IEJSJ9rFc5InZDRkUcsa(TnjbRxtwo0ZIcwCAVOHcetYHutVslAVQnp2G7A1g62s6quZgIsqwmP)XCdvnG7g0ph0mkk3PbZlOKGclxMvDOjxyc8qRUWwvzNgpPIBiK5p)EYupmwX8yhZYy33E9RY7SjSmuUUpNxnrquzYr1XU3iRmusVVhsH0IjVTI(aJQchzB2)3RABcp)uuLOtnGwPgX4Ud2cpng4Vsabq(tFe4gaZ60uy)FgYYEAHO)CA9schyiJW0SSYnQ9RnA5rITNQf(hJUhLcKM(7rOqdflyh9Av7nMMc00bCFVxnTJk81r7DfNJosOOmHCTqXnBpDKVDBv7iE39Q1Us)2xTwr096GYBKNSsdwTznsWyU)CWfKF)rT0e3TM2MbGTGwSRw2mN(EqA7gaSRF26(sBm1xvh7KxEE72ytLcUC(sGaaJDamLLRFinRy5JUTGWkoVkVv1HkQio8JegXuKWRbj0QJZvidSbw2dRDfJWMY8IsmsaITyfk2QMDFkwvwq7YttiysgtFaNCrVr(llxfSonEgLbK41WCJZIF8CjaqVtknC1QOzXybFDJKE)5jr5lPYdtUTlssNgKGnKmoAdfwKPb15hv09nPS)FnEry6qvundIZzwbR1QZKBLmyO0kB1EGc9kn4kwUkcSF5kWpx)QGoOHOB6RS0A1h5HV9MZDfj1Npu0fq4mtsIs3Gz(Oa3(LYNbReIgw4nCzqUpygMpsmj4rKEDndDzgXfV9UVaeepMIOmz5HQPDF39bjLaXtofvn(aLxly4ymI43htLG10hXrA427yb07b0EVWLP5y1jG)MPkdlHSSpYnleN48i0nkK8plNhT9OCrS9wYmAmvurzHZYeHjKBn5ckCsbsYQ(nPfhcC5yLleZJ7(27Wq7hxGvUaU2IQchigfqu8avcFzrfLzq)9owuvCINC6WXdjrs8aVZXj(E(5pUoSMgri0c)fmn(4OC7nqV5pGXL1qqV0(RPrsFwhXNvd0cJCtlmQl0cobDDb2gjnpqH8RbezfAPio5EP06Q5e92G92V(9x9NXTZt9ebR8qwUVhYIZP2SZM5QwvPtsDNqmux1acnY7DIEB2pi0RtqONeeQZMNdICmWMZ5qMsvL7QnbzKQvkw6IvdRmHOhX7NUmb6D1RPQMZGx0TNnzPy7X6U8VgWGH8QILCv6S45XitPc7(sqWj(WnzXPa1MOqpR6MyrCmt4ZdryLpXh86HKQQjSCyRx2IQKcFd7xRtXSmq4omeN1R9CJscequBYc8QyNgzYqdo7K1rPkn2TAdxhdsLnb)HLzzS6oMvl1eoJ2b)1sqfgH7Xn1VUYOt0R9FUsoTmoAEzsIpiehxWENUZRyL4FwSm3pmkRaKzx8yJW43EonKHRzH(zfIqcX3C7yiHwf8lPz(v9YxKHdxP(q55kwLo6IwnMglvFndXCM4GUyeVuqZGz41crSr)Az8Mnab1IG7JseKnZJbn1(bztJl4PHQAkkEig0ZoZ)xkNTal6F)ZU4REZ4ZuI8(RRCcPtdp22o1qJiRUdzGa1ZovkJiTf)3k8KBp17K78vtkq(7pnDDzo4itu2Ox7F(Mq(KyRMuoVAom3zZjlF0PQRvH5OrHzPjPz6UqR5IQcwWRICPJoNR4vK1OimOAD1XHTNAaWSoWMZevhwRCkeouzcNnWHpcURUf7S7NDQilJUhC7bUspgKvHCVTcDs79ZIJew2GbUYyvoDKEo9KALlxQKBMS1STaH2d17(d7cQztblMNPARSP2dWC)wQ1k1GBbG2AYISzyvWUcWwzgKwCqlX)WusHzw)Tl1cJImlnZe(RatdSm)g6DCtdWvdAlwLVDCp1KTGQ2wbW(S3HPngepJ)MsHaRnxdykWzsvu1lqOWu119vcuvxAppzSn1r4m(yISnt61DrdmOJH(RrwgCzTGNTDYUfZnd42wIJD304vdvgWgUd82EHh8EtZkEXws0bhOEtxaXgwW2bzUDnS49vtbQWWz260WJ7MrlxXk9hfk(UzwiVN96WEBNiamnqBaSMIyoz9Pv8LeM31XHRBiyx0kxyDETLFuPM5GkOw9uxHs7I4nle3ZUngMlgmwGW71oPd2sTcBSBuouhL00RgwucO3JKU1A9rmsWtGoBHBp(055DOS)zoLg3R7juPlTRJiUQ23HSQCwdr7b55bLjKSDpBMAP10xaY1xcSTQijBfaSqvQfty8SN4Ud4EDlbv3AkBfumaebpYuiae9bGNWSYc85(uGqkxbJW9XHksa(Cit2QfR89prKiiVgAUTyzhJnKQcO50mQI6vkiuE9X7hKwu7dNXWG0o99iphtq8VodWerHL4HcNfW6Mw9J(lGyOlPJ3clupo23megfE11BnSd10doAJbx)yJBEyqwo2N5zGT(zRdsOA0AUePP9M4inz1GqE8I4KDkUv8994vmhMK84Tkkm2rHeNjpCOAWGdN)Wcb6HLrjubgrkO8dZEeeU8zfY7P2un4xAL5aCD4gfxMIxJQFpsj0ZuSRXNrb4gZiwep48Z4XJ)yrCPNgr(lnd5DOCNr3ydBcIZWNP7OfGCWaDZJ6EoZtMkh0qh3W7AHbSFYCO7KR)aVxlahsPGSvSmyTsxhOjKTwHniLcJY(m)QvxpdzfrlJhuM5h3jLVcHMosFs1y9zsmm2z7krD77NKv)APEQovlklxPCEP47vJe)uNIeMxidAk81boCIMOz3(OUZuanYk3ZHcOzk(()7uaEUOa82lkGrUPaAIdBqbOltBKPyj0ICpmn8S74LuSUFXjII9tfPIiPGuU5qqseDis6i)2EHDpSWXbBV7D8S5TokM9(2hTPPOysLXz3ONBjd397ahBtw(6HyG7yHSBWxl1eGn6jxlXbMPgAeAedh5lXb3Iv2Wy5DW3vz6GXUIz0LTzXVeEyBxvRV8Kump10TDrqcOKA2Ji)hDfsrkgtZKoQLiudiUv87)bWjyYdi9QBc0RpdZUq0VhjVemyDy7zSSFhn(arZ2n9q5T2n)WuKjTpPd5Olf5DAtTkDqvRSdc1DGlGP)l46QdysncT3xDNzj4n2kvEdtJyLzEET9sbLfPOmz6a7shJI6Ke3G)YKH9TtsuHf1lqmzFFejGP1kjRHpAUkv4pjH2PwgrBr8TgvA6KLyWFM2rMTCu(1oujTLoPM5jTt5lIXB0mxl17Ggp1Cvb7GEN8UHsXepYcIlk3KpvTJY0npPk00mtpSD9rGls93fxBILY2RuW6m5s0UdJ1MqT7aP09FrFh1e8vvNi7Mub84XPSgLs(GjtIBFn2Vt83hyVksAxqIkJP1PPsRbzFQwSE2TJy7(g(pxghBylYo9H1eIQS5zoecMmJT99rhEP0m1HcTZgfwyf2RWoSQEAwzK6bbSc9UkildeMoZFbyLtbyznGIap2dJwrsM3i10ILzXjj(5rrFeeQP8kQYkq9Ca5cEJjMdUoO2c9t6IYldxgKM7pnyDuZi7QrCPPYtzps6C1AYg4QGhXVWh108)3HXflnmc)9pJZkti7aEFsWcSKgJzEcuxREsjqcK3FpVdOymO9aCc4K8Lmts71bTD9CiMYO9Xnxo7ge1MeZ2tzxRlOU5cDFgH(jnbPJy6sBUsuTy00k5STokCHgjdSjUeTLZhRGMlmKVddafrqQdiViy52WG9uLcZtWoJ7NIaGET7(9S6PL8aIUKCfW2Q4C2vb7)89yrWYVOvbEG(uP1Jv8o76PLftVuY)QnO)xxuhDVHgZ6Pssf5jtpVe6liTawg6un0nObigbK0bmdzQ0UisbBW0K00zgPUhyyh1uQofns7IUrbB9ZSbgXpsx)W4PbG5o7Vq3NXtX1uexGCow9YeIDM2jrDNfI3V5R5uuYcc7xF7eqL69az9N1AaK7cpPyMYL6)5UNSSucwAX27zEzzHwVAmDNQ3rMbXIYts(IRKFzwYcA0pHBJ411lYsGLAofGHQckNrFWUSNcYd2OJzBUZyhXAH0XXyvVl7chOBOToek7OXZb6A4WsRqMU5Xk7oFDilsJ)iZqDkngVBdEh5a)vF(Vo5gW9FS(TZXJseiTztAgzzf6ecDZ(musqbyiwI61QL0LLLicaeKzlULohH67naCiSzAIZHilaV6Xz3xO2mgOfyGB9kneDOs11p(K1gUQE7OY8R)0AWit)kktckQVKQrOO738PTAXUYfHwxHe215kcj2Rdg7qIR6PSsfV9QptL91u5luxkihyn0aAJKkRw9a4S3TX)2u6IWj3UHQLVAgrK9Uv7XDK(U(kTROMBXrbzeKfcUCaAAOJRIUEFE)BREOa8WfvUPz0X7DYNAkqo1downWMIJ8oKKBC639Jvcz7aZcR5LzpkDe0illCC3PBRN1496xAkEO7WsRxRLPY(SObvhrzipS2I26ATzhKwRvV0u4kRxRYMWlmHq5oSLmRpV60OyksEv01Oop8cVZhzx0vDkE527(2aSOacrB5bbNlOVYbNd4N0cycOVYfiuHhiUOa8g1ljiNDnRiLn)HBV7FueNe)7ij8Ya8mneMsNKpwzvWpaDvJpAN0hJI2i(6iemJ2H3PT99BZ1BC70UEJnf9Xw1eWtBHbExbpTb5gWRVqvakxE0MYK8wUZL(eHIyXYjolI4q3vE(MDSEPv9otrmZTWFHSvlCiTaC6NUKPblOGrc6j(ilREGGFWfZC8T8VWnGhrGjUzyKGa5))RV(N)PV)N(l0xMdQ2BIxHgsYDo4vvMZ8kKC(xlz1sd7lUcp3q4dczFJBgU9h(XymddEW49TPRHzME9R4Ah(3VIXIu93c9dWZ7p63gyT)IdTz1au9a5rWtAegPnc1oMxngspQ5OS9h6aMHmVA3WmNThyMZKwxN)PEDjCgy3ww7ZgU821f69NNFDpPHOoL7)BDSITUpYq3zptHC7R29zVlD3XSld8VE3NDVo09oU2FZUp7DP7oM9osiYT39tpDOlbp7k7LzHpDbkEjfEzEu2DHOpxHnSrz8(ah4hgSV7D)y3jxQcbXNEcg5f3(ip3v)RoVUvJq9tSr0QVnTRWGE)7km4AtU7KkJCmk7dK0qA8oIn0LO1vyyu3OtRUwJ2n60N7ESoMDx7VMg2BIx9T0ryTa)mX9fFbBu(Xs2TjszsjyDA6MiWqzCr3)lg88137qJ7ZfA2df4JSRbwdAKag66xIC5qcAozG7HRl4MZ7q3DSyg7sH(osOO3)9sApx28P7RqLx6XR7kH4UQUBm37J9cJErSxW1OSBc(EUQbCAsBhWhUOb3pOOb5sxaJZ6gHIueJ3nsLNR9k7pPshzb4vr8UTQ2hROC5vCx6Vtp46q)p7fuOPoP2(Oc5zt6Q4h0ZLoZ75sOXhM9zNvHEFFiTeMY99RejvftgeliBSVCriPlEfvMIPB62B(t)jEI0B(nHgFLXVl04lQ)2qJ)1F0((qZHPxUVr08b8pEFNOvbSp)FRO5Z)N7Vx0veDp)Vz08H6f(7gnFu3ZVD0ixgJPnFyLBxhn5e2TeN53vF03n)(6ROxZVx)QO6y1RX2jNFC88jhWf6OLT0Ehyiv171SCMRzX0Ka45)7DBRP72wZ4FrgQogtn)eoUIFJIEC6Mj09(6X0KoX746B5YjWqECfx8KAp7Kpez96x)86IuGVo)IV48XtoDWUawJ2xWAKfWYWTlBfyHes)3Bp1T71TN6USPkGu9T1rYBREsBQhyHyZ8M9tpzJiWjvG0lXwxDQzV6pJxBVdgCyFVHJpsDOXgcVOXH0Lr2oyWv9DYpi9YomLEoNsp(uQlp85ELV2LnwXvxfFFKl7U5XlPxlxGTDzUOR3v(evBeU(DiBV6xz6EJvyd73XU1ra(tSyMrwhQ0ii0dxDnD6cUpioHW2vq4ePtwkHYF2hpXQHUXsUXHvKV873Hdr5tpz7iBk9g7hxZb96xr2AFsgsh)0NEQQPwo6PsTO9JD6GNEQ)Ze27a(Hrh8p54BhBcgoMJ8TH6YF28z36YX9SyntF(ZvoGa9CFScU07S6w0LJ2j0HNE6atZ0GoTAbRCuyRLkYBIl7Yr9mw94WYwXhGR6B50xE04biHHUHDcKgRSi7zPokVebH6ZxPdMO6ZXiF9Owslt861)aZhYNNEQ5HL8kVXoqFs1tQXj7QjJ2HzJ98E9TCEhVA8tpPIP9oDGdGZCLjjKPyZ8Ed1SuV2O8RP70AaiwrUOHQpFIGUBRkpmEEeF6jRN1WYn9S(ojuxZDglfoSduQ05BtxOGJtsiqdHIxBq4Bz(7PFQrOakC55CuqBNxqEZ0pRG8hB5CcYFBZZii)fkNpqjX7MpBGxoMzEYUDG(Kr7Idne6JylhLUEgL51ZcxNXjr5eQbwK2Hj1eFUj4OIqxf667w4)v99g)fQtXroohEdAsDFg3cXpXh1mJOt(j3BYfiIKdygG(lvH5DaL6g51twKJ(HXBGnQSAdjLovC9674CW90tUodCm0)Z8SRjdSkhroeI3bjk9DFe2US)IWzhc(GmqiMTXXn4sOfk4o8eiDmqhizwutv(iyAWCcB2r080ND14EUgFgGJN1Sb90vZt4)pbhIm3iHMyolBvo6bIRnSCCpTYgl1(uQyAL5PdZjqilcgp7d5LmWRFasuIzqE7TSQiQAVP8tGcZ2)6gNZbyjXt1ghEG17gtlw3ZMk8V8tjmYBfIvER(NX3MpqBSEREqtFldAW76AeAjMt5pC8LBKAH8pZdtlbMj(8qA0CCFWE157Eh0xlVuyzlMsYqZCmC7iww8ZFRIwG3AWcX3wB3w70tv2sl30m1dDf3XarEQWvVPJFwnZO2j57sVt70OtXN(y25TJzYst9N2ozCTn(sz(38aFGvfnhyAXkPX2Y5SdCLPAJNjDsPpYIRWM2OL7I4v0TP23R54atuVIOk91PF327(gkpbvb0QARzsysWdeb5YaaqYBoqxozSH(HauB9CYf9u4FMtCMyCJyMWcM)zEKBydbhrsVNMsWoKCH5cwhDM9YCGbmdQfyzqLrWAZd)PAR32wBEMxBQsk73qujiroeSDSMa1qKEe(RAXntL4qk9ziON(g7z6gKpz0aZqDep)KCtq1pLsx2370JCIpo8SbUryxErpNRzUjFkFTWXt1ZEbUJg3YU3y3at7Z6boh)2wQkXp5YXwJbJLqWCPfowf(QoSgCJcKKUCdfmFLbKuRmHR1GPN(fKzDCDSCuzwR4HRIthle)pqxBNyZwKHd2oJsN45bKGP55QHreFUHfEdgDN4YpBSZcyBh2Ln1DDZymgzchMLbGAphrK6YZ(enTw2P6Y4Qex3ZV0MzrmV5wIjVN1DWfThc2KZdRb3cYzhJXRGs3pLiZeSDuPWq8MSdiA(jvv5ICf6GovrbeH5TOwnnXDCCO5fAd9Q9paEfoC5dP1CR8DkCPOeDh2EFwpfK2zoqAmrjVxRysQSJDcZmzfJunh24NEYuGHnDqwVCYOlmYqp6cEbL1Wk6Aa6id1nc5m7UKiKx3RFh(6dwZO0Y3zWlFnitSddOuYQCmRQ4KUcdhD2PdAlOHW62C4YmNuOE9n9jrZsSzohgftnxpJeJoLbNc7XfFN9KKkz5B13LEW2wTezdF2aF6jBFOabdmpWzx7DGTUQBsqRWjStaZwZv4GUtnBG34StpcVpEmoesX9YOV07q00CKAU2NBdcVTn1QWi6X4Ubm96BqfSrY1gUu5uLpyCsD9c0871hmV28S1KtMui2bbAF4BU(ywSVqvrltFGfhXLWGKeXuiXRtW)owSNpeq1cl0Iq6t0aR8FWC)JffQmwg0fvUM2v4ALUbWwyqLdOaXZQVa67y4hg9AE85(lOONJzr2KvFdZMXlQSPrO6Z8nbpGxbOkXRX2MUpjjd3Q7ISnJKdxnM0D)z)ZoOzcAfzGk69KsCSKKwhP17YVskgfUt)NSSBhQWWiX6mrNw4sTVOuccJjDYEMhrdtVDKLZpUGTwtc708226X7nh13Mz9h(gBYORjXmjF1PTytoxoMxIcK6PNA8O20EdQoLd5vhSZb6H5CFAbLR3y8t33GoHsAddyAJ4Iwhyd6tAQ3OTP2M8AlQZ0IPSLOy4D(NGIZXjRlpb6w5XC691OE93JAMWHORR8o1POnmeSDz5JrA1mBA3WgpBkK9d10E4QvZgQYsOU48PyaO)bSJP196A3vzzaMQ4wqLBcMf(1iSqFSOwgCFmRoodOse)H0m6afuMLxs(QgV(lxeSkYLY86ZddXXBgjEqNOuCTvFHUL0K9Scp(yMobAZRo)msipE(8MOecsRScgyyVY7cNQSRfiASwvBF1zHkMLL0BI4MZX(OOmNoPsiqWQWf04n8WTeWnUP6S(Wp0nBOnYF(94PIIYjnpYbmZJ(2RFLjCfUXQJTCGa0TNg3YBA5Srm7PhP13dVyqpZ6J1MdZd45NoW86r3HlRea1(YPvUsFIPbuJ6Y5xrSmSLyyAww5g5wBMGz0r9T5i6HJE9ZfXyhV40cTRWaWA2IHoHxEPGAnecMfQw093s4cChsah0k7Zsso3U7cHIfM7LWAe19b0OLRjX(pUxERqQYFUu(MjMhVNGUmMQrHjv5UT90fCULTN6J9goDvKvBafSLySv5iEPWiDFAcSqH3LNMGZexnO(J9xwUkyDA8SHy(8xdeJ4q5hVAv0SyWbE0YKQNUijDAqIYJKHg9XwOI8gyrJc))aZX)Qfipn0t29KEyi3NMS1DYOtLDzY0PO4WXQPGSU1lFKyndoC8GbMJqm2wk6nAepNIwUBK92DXbBumfnjN1Mhwye2o8Sbx2fF2BSbGS)1PCRVsUWehlBtXiswk0MLrbzPGdiye(7334My3t02GgzZCGjOUroyAXFUlp3zgKqC4itZtJuGuT6KkA6wCNZZ1ulhpLV0Qt(dmNbyzdoDaZTK2fR7ywjL1Kz6uL2HOtfwhlEzx1nmKBgHUF8SEwKr7WgXoiD75VpcKzzSZZIfiSB4yVQBiH)cdq4PS)96LZ(qPYPAYNIYMvnfm7BfZEPCrdjbYn2Eml4sVCs01(85P0AuHB5SXBtNyleBIsONhpEmIeKVzONDsjDohKoJxqZSYeMoN)yS3ZjT6FPO3leekyzMjDiWTa(zoQnpLk)tj5XY1hL64PYMyi4kUnKCSnP3OgB3sTGnFlPzZsawocnBvLUUB2RRUI7sbi8CQNIXUx4xADROlaMRndR7fvZ7FsCXhG)l7m(cmny4LaRksO0hTmgjzZJxLREzFiUTdeFSxRIybMNQqWahqch29OSO6CmHH5GF1fWVUrkO7WGWuWm512jYnPyHZGtN9c11NwHs4glCojGE7D)SOmWfqaVUWNO(5hWs0GV6IXSGiQzAR1d9MWCqEadedJC1EYbay5xFt8RyZ0ZVimi8IHpcaMR1kBT2iixDH63bqUNXppa7(cP5n8VU5VwBOP1G2D5FLccU9sY3U50bH4pKxz)MwyQF5b6Wg0USv4n2sL6zK0w(Y03yuNF6P(ACigJy4KlKdzy94xDJ2)cVkzsuACv67GXXWf2Vj(g5l((Mie8GjBHg04uJU7XR)GmTZoJ4YIiFI4ZNnZ2HyRhpEvT)VCjOSrLCqB7oKj0itn6hEEEUH0kOo5tqI5iryoiwJ8SmqX)6myDq3Aeto1KL3JovUyGfiCmhwkOC7vlrh6CEyqwo255avvu2AGRgvsopQd9v7MuOd8iaMgwFxr13uhUrfg0bGW(L2Wlp807aB3Ied4wdfPCL3q3zo4ZOlwh0E8i(Lc0m(9a0XIYiDAK4k9GgvEL2SjGDZrQxNkBVRpw8niVmZ6lp56BbtNhEJNnG9tw9WCY1FG3RfujbLjo2TsD1m(M)tpv)MBCtI0RVT7Ggu6TZCbJS9w6l)GT)Yl1W0P13H3JyDBjar2f2JygLVJGQGc(mkvKg8gvDJfnXBGqEHTL(e1VZjo2Bg199MrpJ9g9RZO)aU34zzVXBN2Bg1yVrFPRV3WDINDFdMIx5MO3ku6AReiiUsUilVWHtuIzKmc(Toi7UaKdQBV7D87sR1rXS33(OnnffwOooph(ABxzwMUcSQWTAmlIo5uctRuXwguJ3uCnHepDiPY)vHxOSSRJ36E8ndM4EeAWJRndhZV)gzy5QDJ8K0cXjfiiHUeJWILGUvsjP6PzM3feAZWV8MLfltZU9MBIxH3dKql)wmvt0NVOB))o]] )

end
