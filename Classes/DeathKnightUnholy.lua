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


    spec:RegisterPack( "Unholy", 20220911, [[Hekili:T3tAZnUnY(BXvQOrY2r2u2YzY8S8wjJZB3KnBMPIN94tMMIIsI7qjQWd74uU0V9x34IaGaGqYEMnVQ2ARSJmjoA0OV7gG3gC7hU9Mzrvj3(ZJoD0Ot)MGGHbbNE(5b3Et1JBsU9MnrXFmAb8J1rRG)))(6L5zpIp(XS8Ozy3lZRlIHxTSQAt5Bo5KfPvlRNomoF1jLPRQZIQsZxhxenVc)74tU9MP1Pzv)W6BNAEUHHCtsm80XJGrnD2SeAttkJV9MRtIQwU9U)660flR2EhfE2(J3KSPkz10KIT3feC827WrC7pU9hF7YO1lskFZ2F8R2E33o7FxxwTkzDv527QY3E31RV(KRtMNMLCczCHhFDDc9D5RHX9U4861W0ufvSib71dlHxfvaTj53aGSkzgT1zP3dpllF9c4nRZRxSK(8vrvviq1pkpjSmPQEZ27(IGbdjWZ1PLrtZWH4MO4I05PXPrzBV79rXWuonjoQUeg0zjrqlwSmVoRehWpcpBEomML4ZV(VwshS)Ezko5)taGXbCtY6z4ehnnnlTknb7Aoc3ZZs(T0P4ARFemnNFemqvWMm0G01LvKjlF(27gF0G)hy4F)nBVBDsDvbczr4qVkc67MIK7tqmtz(kyqxN)vfjXWFLwvt2VvbQ)3eyGli)8MQIuCfKUg2pE33d)aMRhZR3E3YO7jJu1ssdtYkz7eZYzZ8d5RFfmL53NuehTb)ByTIWDPkGsNB6wpbGxdq8RMJumHfjRIG15RWT21ZsrynkJroeTzdIxqqBAEj8qsxk50c9ZsWh(2RHzocwq4ZHowevUKTH(TaT6meyHfbI8FxD10IKOpI0evfpsNfGky7DiDqzvbqVGT773KolzvAmdR9ljzr)gGQ(W27UhEefpLLViLGHxhJOpymksYi7RiualM5rtrMneakIsNfs2GyJ4hE31V7nBVd2jaAlK2b2gswVa5K2uKht27ryd2Cw)re(iZ2WBVjlTSQe5Yf0VWF8ZeXgjRjeV3(D3Edq8I7VritkWgf(rc35W5KnOKzHc2NRMaG6JXzjHjRHfmc9p9eHeVREnM2YdqEXmyHnCADrzfqPewcK1LdzqdTvSMmJWA38QE0n960QHpKI7qy3xuGtNA)BWFdJMndg8FdrdKbq)vm6PT3D5eu0dT)uQNEmcOqT2aiZyKUd(31pgoB9SBRaHDwrPWs((i4xWBgUjppdb6I61PXHBYFaPEG5PpmN1ZNpCwuXhdbkY1LGeIveoXHiPgc41RtGhUizikqbPCQcJZtZuqpiGDV0MdcWNrxt6VcEZOT3nOzXq3eXHexpNTVRNMbmHXvGd35AdhVnZ5swcljcwuPfj4KMMqiSgsK2jwAeAI8Sz5pSEy0M84OSh3uMiTTcTcgucnlJGeP)bqA8lpibuhMNRl2J5c3WhwLUcgR8WZjJEZkLs4XxMMN0V2YKsG5WsQggQE5I0n039pxMSMRUeew9q0MsM(YzmLDGYzqcpQknnduPKHTJi)NmGu60YteI2Lvj9quAfr3ar9NUY7xr1Epugh0NiXaKBH9RCizv6TihnbvdielU3bVIttPG8pZnYVc(Fe5RerAULVAIbDCZwtCw0deQHLrWuv6wWIbo6lyRXoXnN5CoTZ83HWBQOmpM)9tjYzKDrjneoGdwl0wDknXJzmWgBJbzAkKTeQSYA043Wz55RaQfIzHmLGU1im4pOkf0fzQiSId(e12XOboxswdbNU9UJ6ezFiF3T79Ll505DIhj6YjBepevScF9kWqaa5zwjLUu6UxEJg7daFfX8NUbyZqLUyCfnXDmZDpNuKKUDoc712llPuePjVuEnXsuZQHAwHqd)MxuRpaXZlas8cOrGyAtcOlb)vVriGh8iodqgrBGDBHgwbydkXmiruUpQIHWTcHQKnXvHNnMJHBBHPGuXfWW5SwepJW4C6WVEmN3XiZUB9i99KiXMiT)OkTYUwSNHWz)mVvXMQFyEJfvOEpIjqOfusMuvco0edEZnLygcXvULjeVfxKL8v8EZOIXWvuwjmUAydmbaAi93HytacBWSY4kKGxA5RP8LQMdBFinirSPXLrYAmVketoThhiWdg7YsmKwHAoqhgQDUeLxB5xcGGstebq7SK4OhBGKJOQMmi(7QowddE5mY)LYhNX(G0S7FInxfCb6DTn7CxUti61Edrk8AFG4Ac(FjZNNqKxGH(b8YidfJ9WYuKlRmDvPAiNogLEHE8GHPBMu8XIGNfdWrrAo29e0vicRjOZddCZYOsPGEHmUfjX5RwbmgdnyS(S8kDCHrdI9bZDUIQn3(D0PaEjj4wemA2giugm1aV(Yc4lIwTjADftraG1whlfiNdjuh6gf207LpswZr8woqy3)gqx6cGqj)ryHqXPcvlk6kAlraz2P2d1HKhMgDWIXhdZNhc72HZIwTozMj)lQjbWoCAgzji3agiX5GLfmQ2jzjsCv6uBHV0jJFipe22ua6uLVLySHiG4CG2h29gs2xcNhLiOayBqBwMevKVkFTStxcPX2nOG7R3ZjaFdCyY6aJXMZUHaDZJ5L0x(U2ihYPC6WOaxnRE1MqEWt6uiaXd1UGWWMmDWu((vAmR2SgBGlhiskD4ASDhf7uT(zUNuN65y2z2M0OFxyYdzBId8rp6vEqxOI17IZxIWh(37HbJydhx6dAKhhBAhPB39vpjZ9yN2ezTthu9ZwAv5w66(9DH0WoiK9oQlQPDzxmyKDSp6titSzPBvXcib432KfTEnXYHEwuWIt7fTuGysoKA6v6q7vJ5XgCxRXq3oshIA2qucYIj9pMBOQbC3G(5GMrrYDA08kssqHLl1Qo0KlmbEOvxyRe2PXsQ4gcY8xEpXupmwXSyhtZy3BV(vLEBclfLR7Z5vt4evMCuDS7nsHHs699qsiTOYBf0hyuvyiBZ()Evxt45NIQeDQb0k1ig3DWw4PPa)vgiakC6Ja3aywNMc7)Zqw2tle9NtwVeHduKrCErr9g1(1fT8i(2JyH)XK7rPa55)Eck0qXc2rVw1EJP5anDeZ37vt9uHVoA3xCo6iHIYeIRfkUzhOJ8TBRQN4D3Rw7k97E1Afr3ZdL3ipPqdwJznsWyz4CWfKF)rT0e7xt7YaWoql2vlBMtFpiTDda21pBDFPlM6RAIDYlpVDxSPsbxUCjqaGXoaMY61pKxuT8r3wqyfNlYBvtOIQsJ)ibJyks4nGeA1X5kKb2al7H1wWiSPUSQgJeaFlwHIv0S7ZX6YcAxzEgbMKX0hWix0Bu4Y6vrRZtNrYas6AyUXzjmDUeaO3jLgUAvYSuSKVUrsV)8SKYLKcetUTlYYNgLHnKyC0gsyrMg1KFuE33Kt)3g8c30brunJslPwbR1QZKBLmyO0kB1EGc9kzWvSCLhy)6vGFUHIGoOHOB7RS0Ane5HV9MZDfj1Npu4diCMjjr5BWmFuHB)s5ZGwcrdRcgUmQmemdlejM48isVUHHUUGWfV9UVeeepMerzILhQM2993hLvdepLKOQXgOYgbdhJre)(usjyn9rCKgU9oAa9EaT3lEzEjwDc4VPQYWsiR4JmZcXjUmbDJcj)lkzrBpPKhBVLuJgZ5vuw8ScEyczwtUGeoPijzv)M0IdbUsSYfszXDF7DyO9tRWkxaxBjIWbIrbefpqkHVIKQ6cO)yDnsRko(toD44HersSaVZWjHbHLpUoUHgHl0c)fmnH4OC7nqVzpGYL1sqV0(RPrsFwhXMvd0cJCtlmYhAbNGUUaBJKMhOq(1cIScTKio5EP05Q5e92G9oS59x9NWTZtd4bR8qAUVhsJZP2StNzrRe6Ku3j4d1vTGqJ8ENO3M9dcd8ccdKGqD28sqKJb2CghYusv5UAtubr1kjw68vdTmHipI1pDzcK31SMenNcVOBpBkYX2J1D5FjIcdLIILCv(S05PitPc7(sqWj(WnfP5a1gVqpfDJVioMk85HeSYNydEZqsQQjSCyBw28QKcFd9xRZXSmqWDyioBw7LgLeWHOUKfeiyNgzYqdg7K1rrKg7oTHZZGuztWFCDrbTUJP1snbNr2b)1Aqfgb3JBQFRWOt0R9FriNwghnVolleeIJl4Gt35vSs8pRwwggNuubYSRESvy87oNgYW1S4WIkEiHyBUEgsOvr)78IqrVc5z4WvQpuEUIvPJUOtJPhDrldXCM4aFmIxkOzWm8AUi2KFToDZgGGAr09jzCYM5PGM6WOIPPvS0qjMIQhsb9SZc)31ZwGf9F4zx81FZ4ZuI8(RfoH41WJT1RgAez5pKbcup7uPmI0v8Ff4j3EQ7L78Ijfi)dNMVUUeCKjPy0RdpFtmBsSvtkNlMdZD2CYYhDQ6ALBoAsCrEwEHUl0AUOQGfceKlE6CUIxrwJIWaX6YZHTNAaWSoWMZeLhRvgfcdQmHZg4Whb3v3ID29ZoLNLr3dU9axPhdsri37QqN0E)S0eULnyGRmwLthPNtpPw5YLk5MjBnBhqO9q9U)WoNA2uWIzzQ2kBQ9am3VJATsn4waOTMyr2mSkyxbyRcdsloOJ4FykPWuR)2LAHrrMLMzc)fGPbwMFh5DmtdWvdAlMW3oMNAYwq1yRayF27W0gdINXFtsHaTnxdykWzsvu1lqOWu1191CuLpTNLm226iCgFmE2Mj61DrdmWZq)1kldUSwiW2oPFXCZaUTJ4y7NgVgOYa2WDG32l8qW30UIxSLeDWbQVXhqSLfSEiZ13WI3xnfOCdNPRtdp2pJwUIw6pku8(zwiRN98yV1lcatd0gaRPiMtwFQGVKG5DDC48db7Iw5cRZRT8Jk1mhubnQN8fkTlI3Sq8a72yyUyWObcVx3Koyl1kSr)OCiDustVAyrja9EK0ToRpIrCEc0zlC7jKCEEhk7FMtPX98pHk(0oprCI27rwvoRLO9OYYO6mIS9aBMAP10xaY1xcSTQijBfamxvQftycSN4UdyEDlbv3AkBfKyaWdEKPqaW7dapXf1v4ZdjbcPEfmc3NgRib4ZHmzRwSY2)4rIG41q7Tfl7y0HuvanJMrvuVsbHYQp(WO8QgF4mggKUPVhf4ycs)1zaMijUgpu40aw32QF0FbedDj54Tqd1JJ9ndHrHvD9wd7qd9GJ2yW1p64wghvuI9zEbyRFX6OmsnAnxI00EtCKMSgqOmDrA2of3k2(E6kQdtsE8kIcJDuiHZKfounyWHZFyHa9WYKmsbgruqfgx8iiC5ZkK3tTPAWV0kZb46WnkMmLGwv)EIsONjXUgFgja3ygXsybNFglE8hZJl90eI)sZqEhsUZi3ydBIslWNP7OfGCWaDZI6Ej1tgHdAOJB4DTWa6pPo0DY1FG1RfGdPKGSvTmATsxhOjKTrHniLcJY(SqXQRNHSIOLXdsM5h7LYxUqthPprmwFMedJD2Usu3((jz1VwQNAs1IYYvkNxk(E1kXpnPiH6fYG2cFDGdNOjA2TpQ7mfqRSY9COaANIV))ofqGlkGG9IcyKBkG24Wwua6Y0gzkwcDi3dtdp9oEjhR7xCIiX(rqQWtkij3CiiXJoer6i72EHEpSWWbBV7DSS5TojL((UhTP5OysLXz3ON7id399GJTnlFZqmWDSq2n4RJAcWg9KRL4aZudTcnIHJ8f)GBrlByS8oy7QuDWyxXm6s3Syxcp0TlX6RmlhZtn52Uikdusn7rK)JCfsrumMxiDulrOgqCRy3)dGtWepG0RUjqV(mm7cj)EI8sWG1HDNXY(EA8bIMTB6HYBTB(HPitAFshYqxkY70MAv6arRSdcnDGjGP)l46YdmPgH27f3zwCEJTsL3W0eAzMx2yVuuDvoktMCGDjhJIMKe3I)YKH9DtsiWI6fiMSVp8eW0zLK1YhnxLk8NKq70iJORi(2GknDYsm4pt3iZook)AhQKUsNu78K6v(IO8gTZ1sZoOXtnNiyhK3jVBOumXJSG4skn5tv3OmDZteHMMA6HTRpcCrQ)U0gtSu2ELcwNjxI2DySXeQDhiLU)l67OMGVsCISBtfWIhNYAuk5dMmjU71yFV4VpWEvK0TGevgtRtJqRbX(uTy9SBhX29n8FUmo2WwKD6dRjevzZZCiemzgB37Jo8sPDQd5ANnkSWkSlWo0QEAwDI6bbuGExfvuactNfUaSYPcSSgqrGh7XjRisM3i10QLfPzzHLjjFeeQP8ksLvG65aYf8gtSeCDqTf6N0fLxgVmkVmCA06K2r2vJ4stLNYEK05Q1KnWIGhXUWh108)3GXflnmc(7FKwuNrSd49zrlWsAmL6jqtT6jLajqE)9SoGIXG2dWjGtkxsnjTNhA765qmLr7JBVC2niQljMDNYUoxq(5cDFkH(jTbPJO6sBVsuTy00k5STokCHwjdSnUeTLleRGMlmKVddafHGuhqErWYDHb7PkfMLGDk3pjca61U7pqRNwIhqKljxoSTkTKEvW(pEpweSSlAvGhOpP06XkENE90sJPxoX)QnO)xx0eDVHgZ6PssfzjtVSg6liTawg6unKBqdqmciPdygkuPDrKc2GPz55ZmsDpWWoQPuDYBK2fDJc26xOdmIFKU(HXtda1Dw82kgDmyobZmJ1Kz1ee7mTtI6oleVF7xZOOKfe2V52jGuQ3dK1F2ObqUlSKIzkxQ)N7EYYsjyPfBVN5LLfA9QX0DQEhzgLYlpj5lUs2LzjnOr)mUnIxxVilbwQ5KamikOCk9b9YEkQmAJoMT9oJDeRfshhJvZUSlCGUH26qOSJgphORLdlDcz6MhRS78TX0in(tud1jPX4DBW7ih4V6Z(1j3aU)J1VDjEuIaPnBYliwwHoHqUzFgkjOamelt9A1s6YYIhbacKzlULohHM7naCiSzAIZHOicV6XP3xO2mgOdyGz9kzi8Os11p(KngUQE7Os9R)0gWOq)kktckAUKQrOW)B(0oTyx5IqZxiHEDUIqI96GXoK4QEkfQ4Tx9zQSVMkFHMsb5aRHgqBKuz1AgaN9Ul(32sx4o56hQw(Qzer27wTh7j9DZvAxvd3IJcYiQigC5a00qoUk669z9VR6HcWdxiCtZOJ37Kp1Ka50m4y1aBkoY7qsUXPF3pwjeBhOwynVU4rPJGgXYch3D626zdEV5LMIh6oS061zzQSplAq1rsbYdRTOTUwB3bP1Q4LMcxzZAv2eEUjek3HTeZ6lfNgftrYtqxJ68Wl8UqKDrx1j)LBV7TryrbeJ2Ydcoxq(khCoGFYRGjG8vUaHk8aXLeH3OEzrL0RzfPS5pC7D)9Q0S0FhjHxgHNPH4CYj5JwwfSdqNy8r7K(ysYg(xhHOzKD4DABF)2Cdg3nTBWytrFStnbS0wyG3LZtBqUb86lufGYKhTPoRSJ7CPprOiASCslsiCO7kpF7o2S0eVZueZCl8NlB1chshaN(PlzA0csWib9eFKMvpqWp4Izj(w634MxJva)drfyKGa5))ZV9x(5F4N)ZKVmhKAVjDfAijZ5GxjmN5vi58VwtRLg6xCfwUHWhet)g3mC7p(tPyggcGX7T5RHzM86xX0o8VEfLfr83C9dWZ7p63gyT)8dTPyaepqEecKgHrAJqJJ5IXq6rThLT)OhygI5v7gM5S9aZCM0668p1RlUZa72YAF2WL3UUqV)S8RhinenPC)FPJvS19rg6o9zkKBF9Up7(0DhZUmW)6DF2d8O7EU2)MDF29P7oMDpjez27(PNo0LGNDL9YSWhFGIxsHxMhLDxi6ZvydDugVpWb(Hb77F3p5p5IieeF6jyKxC7J8Cx9xCEDfJqZtSr0QVnTRWGE)9fgCTj7pPYihJY(ajTKgVJydDjA(cdJ8JovCTgTB0Pp39yDm7U2FnnS3KU6TKJWAf(zI7l)s6O8t10BtK6SAW608njGHY4IU)xo45RV3Hg3Nl0ShkWhzxdSg0ibmKRFjIlhsqZjdCpC(GBo3JU7yXm2Lc9DKqrV)7L0EMS5t3xHkV0JN)kHyUQUBm37J9cJErSxW1OSBc(EUQbCAsRh4dx0G7hu0ICXhW4m)iuKIy8UrQ8CTxz)jv8KfGvfX72QAFSIYLxX(0FNEW5r)p7fuOPoP2(Oc5zt6Q4h0ZLol45sOXgM9zNvHEFFiT4MY9dR4jvftgeniB0VCriPlEfvMJPB62B(IVGLi92FwOXxz7tdn(UMpp04F9hTpr0my6L7ZenBa)J3NkAva7Z)NlA28)5(tgTGO75)zJMnuVWF6OzJ6E(5Jg5YO8TLdfEED0KtOxuCMFxZPF387BULEn)E9BJQJvVjBNC(XPZNCatUJwct7DGHSvVxZYzUMfttcGN)VxVTMUEBnJ)5jP6ym78ty4k2Lk6X5BMqU6xpMmPtcoU5IUCcmKhl4IN04CN85iRx)MN3uNcS15x(LNpEYPd2fWA0(cwJSawgUGzfGfsi9FVav3UxxGQ7YMkhs13whjVTgiTPEGfInZB2p9KnIaNubsVeBT4GZE1FcV5Ehm4W(bdhFK6qJneErRZPlLSDWGR67KFq6LEmLboNYa2uQlp85ERV6Zgl)2RITpYKD3(eM0RJ7WwFMlYn8kBIASdx)AKTxZRmD1XYTH97Px8ia)jwpZiRdP6iiOhM6AYbm4(O0mc2waHtKoCPeu(Z(ekkg6wl5wNxr2YVVhNJYNEY2P2u6n2pXMd61xq2AFsgsobQp9KOPwo9PsTO7tE6GNEQ)Ze29a)qPd(hm8TJnbdN0r22qtfqB(4BD54EwSMPp75kNrGEUpzbxgCwtl850DcD4PNoW0mnWRvlyLJcBTuDEt4YUCupJfqoSSv8b4Q(woaMhnEasyOByhhPrRmYEwkLYlrqO5iw6GjQ5OmYwpQv1YKGE9pW8585PNAFEjVkySd0NujLACYUAYODy2OpVxFlh5XRg)0tQy6Gth4a4mxCsCzk2mV3qzl1Rlk)g6oTgaIvKRBOMJOiO72QYdJhjXNEY6XnSEtpRVtc11ENXsTd7aLkDe30fk44Wec0qO41we(wM)E6hCesafU8CgkORJmiRz6hxq2JTCubzVT9XeK9cLJiOK4DZhpWlhtnpz3otFYOD(5gc9rSJttxpJY86zHRZ4KOCi1als9ysnXNBcoee6QqxF3c)VQFW4VuDkoYXrXBqBQ7Zywi(j(0MzeDYo8EtUarKmaZa0FPkmVdOu3iVEYIC0ppEdSrL1yiP0bJRxFhhfUNEY1XGJI(FMhFnzGv5uYHq8oirPV7tX2L9xep7qWhKbCXSToXbxcTqb3HhcPJb6ajZIARYhbtdMtyZoI2haTRg3Z14tbC84MnONUAEc()tW5iZnsOnMZYwLJEG4Adlh3tRSXsDpLkMwzE6aS3l258sg41pdjkXmOS7wkQJQUBk7qOqT9VPXLmaws8uJXHhy96X0I190Pc)RWCcg5nCXkVr)l5B7hOnwVrpOPVHcn41DncTeMt5VD81BKAH8plJZRbMj28q0O54kH9QZ39oOVwEPWYwmLKIMzy4UrS04N)gfTaVXGfIVPXUTUPNe2sl30c1ZDfZXaEEQWvVPtGwdZO2H57YGt9A0jXN(y6rUJAYsB9N2oCCDn(sj)38aFGvfnhyAXkPX2YrTdCLrSXtLoP0hzXvytB1YDr8k62u371mCGjQxEuL(28VF7DFhjpbIaAj2AMeNf9aHGCzeaiLThOlNm2q)qaQREo5IEk8pZjCMyCJOMWcM)zEKBzdbdrsEpzkb7qk5MlyD0P2lZagWmOoGLbcJG1Mh2t1wVDT2cmV2uLu2VLOsqICmy7ydbQHi9W9x1IBMkXHu6lrqp9n2Z0niFYObMH6ew(jzMGQFqLUSFWPh5eFC4zdCJWU8IEoxZmt(u(GHJhSN9cChnUJDVXUbMUN1dCo(DTuvIFYLJTgdglHG5slCSk8vESgCJcKKUCdjy(kdirTYeMwdQE6xqM1XnXYrLzvWdlIthne)pqU5oXMTOahSDgLojiaibZllvdJi(Cdl8wm6oXLF2yN5W2oSlBQ76MXymYeomlda1EoIi1LN9jAATSt5Z4Qex3ZV0MzruV5wIjVN2DWfThI2uYcRbZcYzhJXRGKUFsImZW2rkfgcVj9mIwEIOkxKRqh0PksarOElQvttmhhhAEH2sVA)dGxHdx5qYAUt(ofUuuIUdBVpRNcs7mhinQOK3Rvmjc7yNqntwXivZHn(PNmfyytNL1lNm6cJm0JUGvqzTSIUbGoYqDJqCMDxseYR713JpaHnmkD8Pg8YxdYe9yaLswLJzvfN4lmC0zNoORGgcRBZHlZCsH6130xfnlXM5Cyum1C9msm6ukCYThN)P2tsQKLpxFxgaBBnsKn8Ld8PNS9TcemW8aNDT3b26QUjbDcNWobmBTxHd8NA2aVXzNEeEL8yCiKI7LrFP3HOP5i1CDp3geEBBQvHr0JXDdy613GkyJKRTCPYPkFW4KM6fO9NSpyET5zRjNmjHyheO9HV76JPX(cvfTm)bACexcdswcvHeRob)ByXE(qePwyHwet(knql)hm3)yrHkJLbDr1Rj7kmTs3aylmOYrKaXtRVaYNYWpm61S4Z9NrrphtJSjT(gMnJvuzttq1NLBIEaVfqvIxJTn9qIKmCR2hzBgjhUAmdlTmbR5eXcvOgpgqRfP5Cv5PyMNqrGymeZNnJx7O0soN(jZGMXO0KspxfL4vJHYQ4bytzdZ2e8L4cIAYOLfbJUIhx4W01HZtIYQEmeV)ecXc6z9IMeMzODRWQBT4rFA6sSP(0W7tkkJWlaKkPXLM6Hp7FQhnlbrrPJIHgszQxs1MJ8OE5xlfui35BvwzPdBgWqF7mZYwelAFrPe1ltgbfyEenm92rwo)Go2zrGStZBxRNGV5O(28J6WVXMsXgsmtk0CA87KZLdYiVI0E6PwpQlZLaBvKJXOhgwc9WCYMTGY1Bm(5sCGxOKUWaM2iUOZb2Gc82kQ7AQTPG0I9dAbX3syJco)tq1q5K1LvXcw5XC6U7OE93JIuXHORRco1POnmM3(S8XqBBMn1pSXZMcz)qnDNFa10pRSeAoneKGUO)rdKAGW1nXhGMYDsjodwhKHMxSgHfYhORLr3NslC2isn5)qEb5eCuxuwtcoq66VAr0Qex2D0CaKiC8MrIh4fLIRT6l0DDH4ab3fBQTQG2CXbwsc5XsG6eLy(ALvWad7vbx4uLDJarJfhC3RoluX00sFtcZ(z6hIM5KJggce0skcTwgpnrrmJBehUk2PCAdzJ8xEpEm0ifbalunuZJE71VYeUc3y1Xwoqa6oWGB5TDvXiM90J067HxmONz9XAZH5b88thyE9O7HRvcGgNN1QpSpX0aQH568RiSm0LyCErr9g5wBMGz0r9T55)HJE9ZfXyhV40cTRWiEB2IbVWlVuqTgcbt7xh6(7i(mUJbJdAL9zjjNm9DHqXcZ9synI6(aA061eX(pUxERquL)CP8ntmpEpbDzmvRkbteFd75N5ClBpnNZqC6eKvBafS1yWSziEP42DFEg6TAsyzEgotm1G6poCz9QO15PZgIfqXAGyehQW0vRsMLgvHhAOMNUilFAuMYJKHg9XMRI8gyrJc))anmeIfilV)t29SmzizZMS1DYOtLDzY0Xw5WXQ58TP1lFKWAgD44bdmhsESTKWLPr8CkA5Ur2B3vJTrXuKj5SU8WcdP5HNn4sF8zV1gaY(3KJZ(kjFKFu4nfuozPqBwMevKdoGGPuPFFJBI(NzZbTsF8atqDRKE1H)CxEUZu2H4WrMMNw5CsS6KQs9oCNlW1ulhpLVYQt(dmNYDzdoDaZDKNlR7ywjL1Kz6uL2HOtfwhlwDU5hgYnJG)NhUNfz0oSrSds3E(7Jazwb9aezbc9dhhiUsk(ZuaHvJeVx)8dmuQ(1M8POoLvZ51(wIYxkxLwsGCRThZcU0RFhDTpFEQLjv4wU8hSPtSdIn(zwGLDamIeeFZqp7KYYFjiDgVuSP1Ln5Ivat2rjrR(xX79coHcwxFsN6ElGFHJIHuPulvYwVCbPPoEQSjgcUIBdjhBt6nQX2TulyZ3sEnTeGLJqZwvPR9ZED1vSpv8XZPawg7EHFP1TcFamxBgw3leZ7xWVPjW)JEOQbMgm8sGvfzK81TmfjzltxvQE7QWVEj4FGDfrSiQj9yy3tksAsQhgMd2Dfb7(DPICPreNdMjV2orUjflmgCYHDrD9PvzkUXcNteqV9UFHx39CiGvi(tu)KpyjAWxDXyAqe1mT16PmKBoilGb8HrU8AzaaS8B(6hOyZ0ZVQxi4fdF4fmxCB2ATrqw8rmWdqUNXpjd7(cP9xvbDZFT2qtRbTVFccfem7LKVr5jN8K)q(zsW0ct9R9GhBq7YwrWylLgPrsB5pGbgJ68tp1xJdXyedNCHCidBgFXxrGx4vjvIsRpFboyCm8rsWeFJ8hBG2ie8KGBHg04uJU7XkLHcTdRe)25OCc)two12HuR3hbQA)F5sqzRsNHST7qMqRm1OFBfWYnKwfmkFKDmhjcZbXAuGLbk9xNbRdY10XKtnz59OtLR(AochZHLck3E5P4rNlJJkkXophOQskwdC1OsY5jE0xTRUcp4ramnS(UIuqzECfwmWdGW(TKXlp807aBxBhdywdLOChdrUKIWNrUjJq7Xty3ctZyx8shZRB3Pj87qfYOYl7Ni6T1PEDQS9U(y1oH8YuRVcKRVfmDE4vm3a6pP1dZjx)bwVwqQbRc(5CwQRMX3SFgO63CRRULE9TDP)GsVDMlyKT3sFz3KaV8snmD9i4W7rSq54Gi9gsIpJYxktcOGnJsfPbRrIRiQjbd4YlST0NO(TLXXEZi)3Bg9m2B0V)O(d4EtGL9MGDAVzuR9g9LU(EdZjE6f8yoEnNIERqsxRqGa)oqJy5foC8smJiJGDnpsV8fzG627Eh7YlBDsk99DpAtZrHfQJZZHV22DuMP7CmbUvJzH3jNsy6Kk2YGA8Q5RnKeOdjc)x5EHsZUoEnhY2mOI7rObpF8uCm7cZKILf7gLz5v865mkJCRrHflb5AGLivpVW8UaxBg(1oTUAzEXT3Ct6k8I3eA5BXunr(KrD7)h]] )

end
