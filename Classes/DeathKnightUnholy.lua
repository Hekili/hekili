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


    spec:RegisterPack( "Unholy", 20220227, [[devGedqivk9ivQ0LuPOAtOsFcbnkeLtHOAvivOxHuQzjiUfQQQ2fHFHuYWqvLJPIAzOQ8mbjttLkUMksBtLc9neOmoveY5urqTobPENkfjzEsrUhQY(KI6GivWcrQQhQIOjIurxuLIyJiqL(OkcYirGk6KQuGvIu8seOcZebYnvPiP2jc4NQiWqvPOSuvkONkLMQkvDvvksTvvks8veOQXIuL9c4Vs1Gv6WIwmrESqtMKldTzK8zbgTk50kwnQQkVwkmBsDBIA3s(TQgUkCCuvLLd65OmDkxhOTJqFhvmEKkDEb16vrOMpISFQg4mW9aTQ0qacWh)4Jp(XhFemXz(DkbluNbATWhiq7rgBKbiqBLYiq7nDD96WaThzy9NkG7bAzpimIaTxMDWcnTOvWyxGsI4ltl2idQtB(kctkJwSroslGwjWrB3GcqcOvLgcqa(4hF8Xp(4JGjoZVtjyHcOLDGracW3P8b0EnkfwasaTkKfbAPtmTlFj4OMGlZ3B6661HDAi4IsqWeg2x(iyH4lF8Jp(CACAo5vwbil0on8FFPdk(hiZKXYy(AVV0zrN0IorQrJ0IoX0Uy(sNGOV277x6W(gFWY81syaAmF5C9(Mq0xKUhy0qLV27REiI(Q)kWxSEWGlFT3x50me6lz5JDgAGh(E3ZKlCA4)(sNdlL0OY32mchQjoP23BwgnFLWycYqFvyQ8n46b1mFLZgOVup0xwQ8Loj4GjCA4)(EtZMkWxc(hSu(2EGLcH(MsJESbz(k)q0xkns3rsh2xYsZ37qBFzwgBW8DkMHPY3NY3tPn53u5lDEZA9TqqdMAFZs5RCg23diselZx2lJ(wp)hIrFzJbM28ft40W)99MMnvGVeCrMHWPc8T1Gtd03P8LoCcUj(ou(g(b99kjI(wVDnvGVOMH(AVVQ33Su(Y5lcnFFIimMh(Y5blfZ3H5lDEZA9TqqdMAHtd)33tELvaQ8voRW(si1eCzDikNtXi034xQXMVsnZx79npo0H9DkFLEgZxQj4Yy((LoSVKPrgZ3tsN(Yjzg67x(AWKDrUWPH)7lDqPqLVz92fc99eaAsqmB4lwgmSV27ldnFbp8LzWVcqOV3KJrHYtKjCA4)(EdrDsxFBV3xImHV0HtWnXx9hmrFztfrFhZxiQhK57x(g)IkLa1PHkFH5O6irSmMWPH)779Na68eeAF9LGBgTh6BRbXkWU89a(rMVtzVVgCQgO5R(dMOaOvpmJbCpqB(yNHg4bW9ae4mW9aTyLsAubqFG2iCmeojqRct7Q3OMGltqX5blfQ6wcdqJ5BZ88ngoQXowO8GmFjrYxfM2vVrnbxMGIZdwku1TegGgZ3M557P(sIKV36RLASmHeiKztf0zpezcSsjnQ8LejFH5O6irSmrQumbs3HzmF56lmhvhjILjsLIjGOCofZ3M4575Z(sIKVspJ5lxFPMGlRdr5CkMVnXZ3ZNbAZOnFb0Mv4UQuagab4d4EGwSsjnQaOpqBeogcNeO9wFjMWjL0O44F9ubDiynX(XZbH(Y1xY8vcKIsOsyJUbZIr9q50MVeGh(Y1xiyHupmafkmv6bzwp(JwGvkPrLVC9nJ2qe7yHYdY8TjE(gkFjrY3mAdrSJfkpiZxE(YNVKd0MrB(cOvHPD1J)ObmacekG7bAXkL0OcG(aTr4yiCsG2B9LycNusJIJ)1tf0HG1e7hphec0MrB(cOfpgfkpradGa3b4EGwSsjnQaOpqBgT5lGwkKziCQGoZGtdeOnchdHtc0QqjqkkbfYmeovqNZdwkbZYydFBINVHYxU(g)xREoLip(yQdFWqbeLZPy(2KVHcOngoQXULWa0yae4mGbqGtbUhOfRusJka6d0MrB(cOLczgcNkOZm40abAJWXq4KaTkucKIsqHmdHtf058GLsWSm2W3M89mqBmCuJDlHbOXaiWzadGa3iW9aTyLsAubqFG2mAZxaTuiZq4ubDMbNgiqBeogcNeOfcwOWgzSBF)o(2KVK5B8FT65ucfM2vplvxHXmSaIY5umF567T(APgltOqQrJcSsjnQ8LejFJ)RvpNsOqQrJcikNtX8LRVwQXYekKA0OaRusJkFjrY34teRSmrnbxwNkrF56B8FT65ucfM2fRRarbeLZPy(soqBmCuJDlHbOXaiWzadGaemG7bAXkL0OcG(aTz0MVaA58GLQZoWsHqGwfYIW5WMVaAj4VWYxlHbO5lJtEW8nHOVQHLsAufIV21W8LZO1(QrZ3WpOVSdSu(cblKrlopyPy(ofZWu57t5lNCSPc8L6H(sNfDsl6ePgnsl6et7IqMV0jikaAJWXq4KaTK57T(YqZMkGjIHJA0xsK8vHPD1ButWLjO48GLcvDlHbOX8TzE(gdh1yhluEqMVK7lxFvOeifLGczgcNkOZ5blLGzzSHVn7BO8LRVqWcf2iJD77HY3M8n(Vw9CkrwH7QsjGOCofdWamG28XUeiKza3dqGZa3d0IvkPrfa9bAJWXq4KaTz0gIyhluEqMVnXZ3tbAZOnFb0g1jNPc6SRu9Cyagab4d4EGwSsjnQaOpqBeogcNeOnJ2qe7yHYdY8LNV3OVC9vHPD1ButWLjO48GLcvDlHbOX8TzE(gkG2mAZxaTrDYzQGo7kvphgGbqGqbCpqlwPKgva0hOnchdHtc0APgltibcz2ubD2drMaRusJkF56lz(QW0U6nQj4YeuCEWsHQULWa0y(YZ3mAdrSJfkpiZxsK8vHPD1ButWLjO48GLcvDlHbOX8TzE(gkFj3xsK81snwMqceYSPc6ShImbwPKgv(Y1xl1yzIOo5mvqNDLQNdtGvkPrLVC9vHPD1ButWLjO48GLcvDlHbOX8TzE(EgOnJ28fqlNhSuD2bwkecyae4oa3d0IvkPrfa9bAJWXq4KaTK5ReifLGbQuy1v)llGygnFjrY3B9LycNusJIJ)1tf0HG1e7hphe6l5(Y1xY8vcKIsOsyJUbZIr9q50MVeGh(Y1xiyHupmafkmv6bzwp(JwGvkPrLVC9nJ2qe7yHYdY8TjE(gkFjrY3mAdrSJfkpiZxE(YNVKd0MrB(cOvHPD1J)ObmacCkW9aTyLsAubqFG2iCmeojqleSMy)45GqHcPM4y(2KVK57z(5lT9vHPD1ButWLjO48GLcvDlHbOX8Lo6BO8LCF56Rct7Q3OMGltqX5blfQ6wcdqJ5Bt(EJ(Y13B9LycNusJIJ)1tf0HG1e7hphe6ljs(kbsrjyCsO8ubD5HzcWdG2mAZxaT4XOq5jcyae4gbUhOfRusJka6d0gHJHWjbAHG1e7hphekui1ehZ3M8LVt9LRVkmTREJAcUmbfNhSuOQBjmanMVn77P(Y13B9LycNusJIJ)1tf0HG1e7hphec0MrB(cOfpgfkpradGaemG7bAXkL0OcG(aTr4yiCsG2B9vHPD1ButWLjO48GLcvDlHbOX8LRV36lXeoPKgfh)RNkOdbRj2pEoi0xsK8LAcUSoeLZPy(2KVN6ljs(cZr1rIyzIuPycKUdZy(Y1xyoQoseltKkftar5CkMVn57PaTz0MVaAXJrHYteWaiWjc4EG2mAZxaTCEWs1zhyPqiqlwPKgva0hWaiWjmW9aTyLsAubqFG2iCmeojq7T(smHtkPrXX)6Pc6qWAI9JNdcbAZOnFb0IhJcLNiGbyaTWmoPMbCpabodCpqlwPKgva0hOnJ28fqBcJzHD7HqSmGwfYIW5WMVaAVHzCsndOnchdHtc0cbRj2pEoiuOqQjoMVn77nEQVC9LmFpqteKWGpSgfz0gIOVKi57T(APgltWaLL)QhKWGpSgfyLsAu5l5(Y1xiyHcfsnXX8TzE(EkGbqa(aUhOfRusJka6d0gHJHWjbAjMWjL0Oqo5FpSh)xREofRNrBiI(sIKVhOjcsyWhwJImAdr0xU(EGMiiHbFynkGOCofZ3M45ReifLqs)VQtbcdluGW0MV8LejFLEgZxU(snbxwhIY5umFBINVsGuucj9)QofimSqbctB(cOnJ28fqRK(FvNceggWaiqOaUhOfRusJka6d0gHJHWjbAjMWjL0Oqo5FpSh)xREofRNrBiI(sIKVhOjcsyWhwJImAdr0xU(EGMiiHbFynkGOCofZ3M45ReifLqcHme2yQaHceM28LVKi5R0Zy(Y1xQj4Y6quoNI5Bt88vcKIsiHqgcBmvGqbctB(cOnJ28fqRecziSXubagabUdW9aTyLsAubqFG2iCmeojqReifLaSUED4oZGyfyxcWdG2mAZxaT6j4YyD(hOkqgldWaiWPa3d0IvkPrfa9bAZOnFb0Mvezgm19yQ1aTkKfHZHnFb0shQiYmyQ99KPw7BmlFn4eeGqFVJVhVHLnP2xjqkkwi(Iz8YxDYSPc898P(YW4xkMW3BAB0Zjgv(ELqLVXxHkFTrg9nz(M(AWjiaH(AVVnq8W3X8fIPkL0OaOnchdHtc0smHtkPrHCY)Eyp(Vw9CkwpJ2qe9LejFpqteKWGpSgfz0gIOVC99anrqcd(WAuar5CkMVnXZ3ZN6ljs(k9mMVC9LAcUSoeLZPy(2epFpFkGbqGBe4EGwSsjnQaOpqBeogcNeOnJ2qe7yHYdY8TzE(YNVKi5lz(cbluOqQjoMVnZZ3t9LRVqWAI9JNdcfkKAIJ5BZ889g5NVKd0MrB(cOnHXSW(bOMHagabiya3d0IvkPrfa9bAJWXq4KaTet4KsAuiN8Vh2J)RvpNI1ZOnerFjrY3d0ebjm4dRrrgTHi6lxFpqteKWGpSgfquoNI5Bt88vcKIsqnqus)VsOaHPnF5ljs(k9mMVC9LAcUSoeLZPy(2epFLaPOeudeL0)RekqyAZxaTz0MVaAPgikP)xbyae4ebCpqlwPKgva0hOnchdHtc0MrBiIDSq5bz(YZ3Z(Y1xY8vcKIsawxVoCNzqScSlb4HVKi5R0Zy(Y1xQj4Y6quoNI5Bt(EQVKd0MrB(cOvkd6pv3GtSbdWamG2aSq4ebUhGaNbUhOfRusJka6d0gHJHWjbAV1xIjCsjnko(xpvqhcwtSF8CqOVC9LmFLaPOemqLcRU6FzbeZO5ljs(cbRj2pEoiuOqQjoMVnXZ3ZHYxA7lz(cblK6HbOaMYhzzDdMfJcHyfrbwPKgv(sh9nu(sBFvyAx9g1eCzciyHupmafxHzgcN0x6OVHYxY9LCFjrY3d0ebjm4dRrrgTHi6lxFHGf6Bt88nu(sIKVutWL1HOCofZ3M89m)8LRV36RcLaPOeuiZq4ubDopyPeGhaTz0MVaAvyAx94pAadGa8bCpqlwPKgva0hOnchdHtc0sMVwQXYekKA0OaRusJkFjrY34teRSmrnbxwNkrFjrYxiyHupmafhxycF5VqMaRusJkFj3xU(sMVK57T(smHtkPrXX)6Pc6qWcz(sIKVXNiwzzIAcUSovI(Y1xl1yzcfsnAuGvkPrLVC9n(LcCmbNXUq4ub9a4dwkbwPKgv(sUVKi5R0Zy(Y1xQj4Y6quoNI5Bt(EQVKd0MrB(cOnRWDvPamacekG7bAXkL0OcG(aTr4yiCsGwIjCsjnkuGYhDopyPy(Y1xfkbsrjOqMHWPc6CEWsjywgB4BZ889SVC9n(Vw9CkrE8Xuh(GHcikNtX6iDpWOHkFB23ZN6l)3xY8fcwi1ddqHctLEqM1J)OfyLsAu5lD03Z8ZxY9LRV36lXeoPKgfh)RNkOdblKb0MrB(cOLZdwQo7alfcbmacChG7bAXkL0OcG(aTr4yiCsGwfkbsrjOqMHWPc6CEWsjywgB4BZ(gkF567T(smHtkPrXX)6Pc6qWcz(sIKVkucKIsqHmdHtf058GLsaE4lxFPMGlRdr5CkMVn5lz(QqjqkkbfYmeovqNZdwkbZYydFPJ(gev(soqBgT5lGwopyP6SdSuieWaiWPa3d0IvkPrfa9bAJWXq4KaTqWAI9JNdcfkKAIJ5Bt88Lp(5lT9LmFHGfs9Wauat5JSSUbZIrHqSIOaRusJkFPJ(EhFPTVkmTREJAcUmbeSqQhgGIRWmdHt6lD0374l5(Y13B9LycNusJIJ)1tf0HG1e7hphec0MrB(cOvHPD1J)ObmacCJa3d0IvkPrfa9bAJWXq4KaTkucKIsqHmdHtf058GLsWSm2W3M89o(Y13B9LycNusJIJ)1tf0HGfYaAZOnFb0sHmdHtf0zgCAGagabiya3d0IvkPrfa9bAJWXq4KaT36lXeoPKgfh)RNkOdbRj2pEoieOnJ28fqRct7Qh)rdyae4ebCpqlwPKgva0hOnchdHtc0QqjqkkbfYmeovqNZdwkbZYydFBMNVN9LRVqWc9TjF5ZxU(ERVet4KsAuC8VEQGoeSqMVC9n(Vw9CkrE8Xuh(GHcikNtX6iDpWOHkFB23tbAZOnFb0Y5blvNDGLcHagGb0gFIyLLXaUhGaNbUhOfRusJka6d0gHJHWjbAjMWjL0OGz9dDw1ub(Y1xiynX(XZbHcfsnXX8TzFpFJ(Y1xY8n(Vw9CkrE8Xuh(GHcikNtX8LejFV1xl1yzIekhU)uD7c7QuUqLaRusJkF56B8FT65ucvcB0nywmQhkN28LaIY5umFj3xsK8v6zmF56l1eCzDikNtX8TjFpFgOnJ28fqlJtcLNkOlpmdWaiaFa3d0IvkPrfa9bAZOnFb0Y4Kq5Pc6YdZaAvilcNdB(cOTfnFT3xqg6Bszi0384J(omF)Y3tsN(MmFT33diselZ3NicJ5XXub(EdVz(Y5A0OVm0SPc8f8W3tsNeYaAJWXq4KaTX)1QNtjYJpM6Whmuar5CkMVC9LmFZOneXowO8GmFBMNV85lxFZOneXowO8GmFBINVN6lxFHG1e7hphekui1ehZ3M99m)8L2(sMVz0gIyhluEqMV0rFVrFj3xU(smHtkPrrQuSoeLZP8LejFZOneXowO8GmFB23t9LRVqWAI9JNdcfkKAIJ5BZ(Eh(5l5agabcfW9aTyLsAubqFG2iCmeojqlXeoPKgfmRFOZQMkWxU(ERVShulnLsOXu1Lc3r6MYhAuGvkPrLVC9LmFJ)RvpNsKhFm1HpyOaIY5umFjrY3B91snwMiHYH7pv3UWUkLlujWkL0OYxU(g)xREoLqLWgDdMfJ6HYPnFjGOCofZxY9LRVqWcf2iJD773X3M9vcKIsabRj2JpecEyZxcikNtX8LejFLEgZxU(snbxwhIY5umFBYx(od0MrB(cOnLE5PsB(QRhzjadGa3b4EGwSsjnQaOpqBeogcNeOLycNusJcM1p0zvtf4lxFzpOwAkLqJPQlfUJ0nLp0OaRusJkF56lz(QEtawxVoCxspbxwx9MaIY5umFB23ZN9LejFV1xl1yzcW661H7s6j4YeyLsAu5lxFJ)RvpNsOsyJUbZIr9q50MVequoNI5l5aTz0MVaAtPxEQ0MV66rwcWaiWPa3d0IvkPrfa9bAJWXq4KaTet4KsAuWS(HoRAQaF56l7b1stPenqItX6)FIr9ubcSsjnQ8LRVK5RcLaPOeuiZq4ubDopyPemlJn8TzE(EhF567T(cblK6HbOiLE5PsB(I1PGyDIdlWkL0OYxsK8fcwi1ddqrk9YtL28fRtbX6ehwGvkPrLVC9n(Vw9CkrE8Xuh(GHcikNtX8LCG2mAZxaTP0lpvAZxD9ilbyae4gbUhOfRusJka6d0gHJHWjbAjMWjL0OivkwhIY5u(Y1xiyHcBKXU9974BZ(kbsrjGG1e7XhcbpS5lbeLZPyaTz0MVaAtPxEQ0MV66rwcWaiabd4EGwSsjnQaOpqBeogcNeOLycNusJcM1p0zvtf4lxFjZ34)A1ZPe5XhtD4dgkGOCofZ3M99m)8LejFV1xl1yzIekhU)uD7c7QuUqLaRusJkF56B8FT65ucvcB0nywmQhkN28LaIY5umFj3xsK8v6zmF56l1eCzDikNtX8TjFpFkqBgT5lGw2vgBOXUDHDWIZdTRWagabora3d0IvkPrfa9bAJWXq4KaTet4KsAuKkfRdr5CkF56lz(QW0U6zP6kmMHf2eBmvGVKi5lmhvhjILjsLIjGOCofZ3M457574l5aTz0MVaAzxzSHg72f2blop0Ucdyae4eg4EGwSsjnQaOpqBeogcNeOL9GAPPuIdqMbQXocbpS5lbwPKgv(sIKVShulnLsq81PnASZEnrSmbwPKgv(Y13B9vcKIsq81PnASZEnrSS(fOCw)OeGhaTtziecEy9HcOL9GAPPucIVoTrJD2RjILb0oLHqi4H1hzzunPHaTNbAZOnFb0sPr2veMugq7ugcHGhwpq)sPgO9mGbyaThqm(YsPbCpabodCpqBgT5lG2J3MVaAXkL0OcG(agab4d4EG2mAZxaTWCyyxHPcOfRusJka6dyaeiua3d0MrB(cOLsJSRimPmGwSsjnQaOpGbqG7aCpqlwPKgva0hOnJ28fqBcLd3FQUDHDfMkG2iCmeojq7T(APgltWaLL)QhKWGpSgfyLsAub0EaX4llLw3gzeOnuagabof4EGwSsjnQaOpq7Fa0YqBOaAJWXq4KaTgCQgOjSZIRK1bzyxcKIYxU(sMVgCQgOjSZI4)A1ZPekqyAZx(EZ99oN6lpF5NVKd0Qqweoh28fq7nHyQbtdz(M(AWPAGgZ34)A1ZPcXx1qCuOYxPW(ENtf(E)1W8LtY8nE9mS8nz(cwxVoSVCEydMVF57Do1xgg)s5ReiKz(gdh1ileFLanFVsMV2)(kNvyFJkOViffgnMV27BWqe9n9n(Vw9CkbDfkqyAZx(QgId7H(ofZWuj89gq57yeY8LyQbrFVsMV17leLZPui0xiAGWY3ZH4lQzOVq0aHLV8tCQaOLyc7vkJaTgCQgO1p3zHRiqBgT5lGwIjCsjnc0sm1Gyh1meOLFItbAjMAqeO9mGbqGBe4EGwSsjnQaOpq7Fa0YqBOaAZOnFb0smHtkPrGwIjSxPmc0AWPAGwNVolCfbAJWXq4KaTgCQgOjm(exjRdYWUeifLVC9LmFn4unqty8jI)RvpNsOaHPnF57n337CQV88LF(soqlXudIDuZqGw(jofOLyQbrG2Zagabiya3d0IvkPrfa9bA)dGwgAdfqBeogcNeO9wFn4unqtyNfxjRdYWUeifLVC91Gt1anHXN4kzDqg2LaPO8LejFn4unqty8jUswhKHDjqkkF56lz(sMVgCQgOjm(eX)1QNtjuGW0MV8Lw(AWPAGMW4tibsr1vGW0MV8LCFPJ(sMVNfN6lT91Gt1anHXN4kzDjqkkFj3x6OVK5lXeoPKgfgCQgO15RZcxrFj3xY9TzFjZxY81Gt1anHDwe)xREoLqbctB(YxA5RbNQbAc7SqcKIQRaHPnF5l5(sh9LmFplo1xA7RbNQbAc7S4kzDjqkkFj3x6OVK5lXeoPKgfgCQgO1p3zHROVK7l5aTkKfHZHnFb0Ety2iNgY8n91Gt1anMVetni6RuyFJV8rcNkWx7c9n(Vw9CkFFkFTl0xdovd0cXx1qCuOYxPW(AxOVkqyAZx((u(AxOVsGuu(oMVhWN4OqMWxcotMVPVmdIvGD5R8RgQbH(AVVbdr0303Rj4cH(EaNhowyFT3xMbXkWU81Gt1anwi(MmF5GATVjZ30x5xnudc9L6H(ou(M(AWPAGMVCgT23h6lNrR9TEZxw4k6lNXU8n(Vw9CkMaOLyc7vkJaTgCQgO1pGZdhlmqBgT5lGwIjCsjnc0sm1Gyh1meO9mqlXudIaT8byae4ebCpqlwPKgva0hO9paAzOb0MrB(cOLycNusJaTetnic0APgltKq5W9NQBxyxLYfQeyLsAu5lxFJFPahte)I4htB(Q)uD7c7kmvcSsjnQaAvilcNdB(cO9Mqm1GPHmFJGqiwMVm0ap8L6H(AxOV8hyw2yH99P8LoC8Xuh(GH(Es68g6lsrHrJb0smH9kLrGwkqTUhvqadGaNWa3d0IvkPrfa9bA)dGwgAaTz0MVaAjMWjL0iqlXudIaTqWcPEyakuyAxSEeHwoLfwGvkPrLVC9fcwi1ddqbmLpYY6gmlgfcXkIcSsjnQaAjMWELYiqRk2HgGbyaTX)1QNtXaUhGaNbUhOfRusJka6d0gHJHWjbAjMWjL0Oqo5FpSh)xREofRNrBiI(sIKVhOjcsyWhwJImAdr0xU(EGMiiHbFynkGOCofZ3M45lF3OVKi5R0Zy(Y1xQj4Y6quoNI5Bt(Y3nc0MrB(cO94T5ladGa8bCpqlwPKgva0hOnchdHtc0g)xREoLaSUED4UKEcUmbeLZPy(2KVemF56B8FT65ucvcB0nywmQhkN28LaIY5uSos3dmAOY3M8LG5lxFTuJLjaRRxhUlPNGltGvkPrLVC9LmFzO1L(cKjSbH8DI635i6lxFTegGMWgzSBF)iA9qDQVn57D8LejFV1xgADPVazcBqiFNO(DoI(sIKVutWL1HOCofZ3M9Lp(XpFj3xU(sMVX)1QNtjsPxEQ0MV66rwsar5CkMVn575tKVC9LmFHGfs9WauKsV8uPnFX6uqSoXHfyLsAu5ljs(YEqT0ukrdK4uS()NyupvGaRusJkFj3xsK89wFHGfs9WauKsV8uPnFX6uqSoXHfyLsAu5lxFV1x2dQLMsjAGeNI1))eJ6PceyLsAu5l5(Y1xY8n(Vw9CkrE8Xuh(GHcikNtX6iDpWOHkFBYxcMVC9LycNusJckqTUhvqFjrY3B9LycNusJckqTUhvqFjrYxIjCsjnkuXo08LCFjrY3B91snwMaSUED4UKEcUmbwPKgv(sIKVspJ5lxFPMGlRdr5CkMVn5BOofOnJ28fqBcLd3FQUDHDfMkadGaHc4EGwSsjnQaOpqBgT5lGw2dQ7qmpqiqBeogcNeO1syaAcBKXU99JO1d1P(2KVN6lxFjZxlHbOjSrg723vd6BZ(EQVC9nJ2qe7yHYdY8TjE(gkFjrYxgADPVazcBqiFNO(DoI(Y1xjqkkHkHn6gmlg1dLtB(saE4lxFZOneXowO8GmFBINVN6lxFjZ3B9vHPD1Zs1vymdlSj2yQaFjrY34teRSmrnbxwNkrFj3xYbAJHJASBjmangabodyae4oa3d0IvkPrfa9bAZOnFb0cwxVoCxspbxgqRczr4CyZxaTeC(AfZx6RNGlZxQh6l4HV277P(YW4xkMV27llCf9LZyx(sho(yQdFWWq89eyxiKZWWq8fKH(YzSlFPZe2W37HzXOEOCAZxcG2iCmeojqlXeoPKgfmRFOZQMkWxU(sMVX)1QNtjYJpM6Whmuar5CkwhP7bgnu5Bt(EQVKi5B8FT65uI84JPo8bdfquoNI1r6EGrdv(2SVN5NVK7lxFjZ34)A1ZPeQe2OBWSyupuoT5lbeLZPy(2KVbrLVKi5ReifLqLWgDdMfJ6HYPnFjap8LCadGaNcCpqlwPKgva0hOnchdHtc0smHtkPrrQuSoeLZP8LejFLEgZxU(snbxwhIY5umFBYx(od0MrB(cOfSUED4UKEcUmadGa3iW9aTyLsAubqFG2iCmeojqlXeoPKgfmRFOZQMkWxU(sMVQ3eG11Rd3L0tWL1vVjGOCofZxsK89wFTuJLjaRRxhUlPNGltGvkPrLVKd0MrB(cOvLWgDdMfJ6HYPnFbyaeGGbCpqlwPKgva0hOnchdHtc0smHtkPrrQuSoeLZP8LejFLEgZxU(snbxwhIY5umFBYx(od0MrB(cOvLWgDdMfJ6HYPnFbyae4ebCpqlwPKgva0hOnchdHtc0MrBiIDSq5bz(YZ3Z(Y1xfkbsrjOqMHWPc6CEWsjywgB4BZ889o(Y1xY89wFjMWjL0OGcuR7rf0xsK8LycNusJckqTUhvqF56lz(g)xREoLaSUED4UKEcUmbeLZPy(2SVN5NVKi5B8FT65ucvcB0nywmQhkN28LaIY5uSos3dmAOY3M99m)8LRV36RLASmbyD96WDj9eCzcSsjnQ8LCFjhOnJ28fqBE8Xuh(GHagaboHbUhOfRusJka6d0MrB(cOnp(yQdFWqG2iCmeojqBgTHi2XcLhK5BZ88LpF56RcLaPOeuiZq4ubDopyPemlJn8TzE(EhF567T(QW0U6zP6kmMHf2eBmvaqBmCuJDlHbOXaiWzadGaN5hW9aTyLsAubqFG2iCmeojqleSMy)45GqHcPM4y(2KVNVJVC9n(Vw9CkbyD96WDj9eCzcikNtX8TjFphkF56B8FT65ucvcB0nywmQhkN28LaIY5uSos3dmAOY3M89COaAZOnFb0YaLL)QhKWGpSgbmacC(mW9aTyLsAubqFG2iCmeojqlXeoPKgfmRFOZQMkWxU(QqjqkkbfYmeovqNZdwkbZYydFBYx(8LRVK57bAI84J9GRhulYOnerFjrYxjqkkHkHn6gmlg1dLtB(saE4lxFJ)RvpNsKhFm1HpyOaIY5umFB23Z8ZxsK8n(Vw9CkrE8Xuh(GHcikNtX8TzFpZpF56B8FT65ucvcB0nywmQhkN28LaIY5umFB23Z8ZxYbAZOnFb0cwxVoCpzSeuBagaboZhW9aTyLsAubqFG2mAZxaTG11Rd3tglb1gqBeogcNeOnJ2qe7yHYdY8TzE(YNVC9vHsGuuckKziCQGoNhSucMLXg(2KV85lxFjZ3d0e5Xh7bxpOwKrBiI(sIKVsGuucvcB0nywmQhkN28La8WxsK8n(Vw9CkHct7QNLQRWygwar5CkMVn5Bqu5l5aTXWrn2TegGgdGaNbmacCoua3d0IvkPrfa9bAJWXq4KaT367bAIGRhulYOnerG2mAZxaTWCyyxHPcWamG2aSq4e75Ja3dqGZa3d0IvkPrfa9bAzyeOn(Vw9Ckb7b1DiMhiuar5CkgqBgT5lGwo5yaTr4yiCsGwl1yzc2dQ7qmpqOaRusJkF56RLWa0e2iJD77hrRhQt9TjFp1xU(snbxwhIY5umFB23t9LRVX)1QNtjypOUdX8aHcikNtX8TjFjZ3GOYx6OV8tqWo1xY9LRVz0gIyhluEqMVnXZ3qbyaeGpG7bAXkL0OcG(aTr4yiCsGwY89wFjMWjL0O44F9ubDiynX(XZbH(sIKVsGuucgOsHvx9VSaIz08LCF56lz(kbsrjujSr3GzXOEOCAZxcWdF56leSqQhgGcfMk9GmRh)rlWkL0OYxU(MrBiIDSq5bz(2epFdLVKi5BgTHi2XcLhK5lpF5ZxYbAZOnFb0QW0U6XF0agabcfW9aTyLsAubqFG2iCmeojqReifLGbQuy1v)llGygnFjrY3B9LycNusJIJ)1tf0HG1e7hphec0MrB(cOfpgfkpradGa3b4EGwSsjnQaOpqRczr4CyZxaT3akFTegGMVXWr9ub(omFvdlL0OkeFzCglE5RugB4R9(AxOVSPc0i)3syaA(gGfcNOV6Hz(ofZWujaAZOnFb0cbREgT5RUEygqlZGt0aiWzG2iCmeojqBmCuJDSq5bz(YZ3ZaT6Hz9kLrG2aSq4ebmacCkW9aTyLsAubqFG2mAZxaTCEWs1zhyPqiqBeogcNeOLmFJ)RvpNsKhFm1HpyOaIY5umFB23t9LRVkucKIsqHmdHtf058GLsaE4ljs(QqjqkkbfYmeovqNZdwkbZYydFB23q5l5(Y1xY8LAcUSoeLZPy(2KVX)1QNtjuyAx9SuDfgZWcikNtX8L2(EMF(sIKVutWL1HOCofZ3M9n(Vw9CkrE8Xuh(GHcikNtX8LCG2y4Og7wcdqJbqGZagabUrG7bAXkL0OcG(aTz0MVaAPqMHWPc6mdonqG2iCmeojqRcLaPOeuiZq4ubDopyPemlJn8TjE(gkF56B8FT65uI84JPo8bdfquoNI5Bt(EQVKi5RcLaPOeuiZq4ubDopyPemlJn8TjFpd0gdh1y3syaAmacCgWaiabd4EGwSsjnQaOpqBgT5lGwkKziCQGoZGtdeOnchdHtc0g)xREoLip(yQdFWqbeLZPy(2SVN6lxFvOeifLGczgcNkOZ5blLGzzSHVn57zG2y4Og7wcdqJbqGZagabora3d0IvkPrfa9bAZOnFb0sHmdHtf0zgCAGaTkKfHZHnFb0E)1W8Dy(Iuuy0gIOoSVuJwJqF5CnXlFzJmZx68M16BHGgm1H4ReO5l76b1kFpGirSmFtFzrSs48(Y5cHOV2f6BQuF57vY8TE7AQaFT3xigFzzSucG2iCmeojqBgTHi2vVjOqMHWPc6CEWs5BZ88ngoQXowO8GmF56RcLaPOeuiZq4ubDopyPemlJn8TjFVdGbyaTkKkb1gW9ae4mW9aTz0MVaALNs1PGiEIrGwSsjnQaOpGbqa(aUhOfRusJka6d0(haTm0aAZOnFb0smHtkPrGwIPgebAjZxK)aNJdujMIfHGwkPXo)bMLbk3viXjI(sIKVi)bohhOsyxyNAGmRZMGr7ljs(I8h4CCGkXteHCUqT8ub9JNdc7ryyMLAFj3xU(sMVX)1QNtjMIfHGwkPXo)bMLbk3viXjIciMQW(sIKVX)1QNtjSlStnqM1ztWOfquoNI5ljs(g)xREoL4jIqoxOwEQG(XZbH9immZsTaIY5umFj3xsK8LmFr(dCooqLWUWo1azwNnbJ2xsK8f5pW54avINic5CHA5Pc6hphe2JWWml1(sUVC9f5pW54avIPyriOLsASZFGzzGYDfsCIiqRczr4CyZxaT3miselZx2bghQbv(AWPAGgZxjCQaFbzOYxoJD5BcAVCAt0x9uidOLyc7vkJaTSdmoudQ6gCQgObyaeiua3d0IvkPrfa9bA)dGwgAaTz0MVaAjMWjL0iqlXudIaTX)1QNtjyGYYF1dsyWhwJcikNtX8TjFp1xU(APgltWaLL)QhKWGpSgfyLsAu5lxFjZxl1yzcW661H7s6j4YeyLsAu5lxFJ)RvpNsawxVoCxspbxMaIY5umFBY3ZHYxU(g)xREoLqLWgDdMfJ6HYPnFjGOCofRJ09aJgQ8TjFphkFjrY3B91snwMaSUED4UKEcUmbwPKgv(soqlXe2RugbAp(xpvqhcwtSF8CqiGbqG7aCpqlwPKgva0hO9paAzOb0MrB(cOLycNusJaTetnic0APgltWEqDhI5bcfyLsAu5lxFHGf6Bt(YNVC91syaAcBKXU99JO1d1P(2KVN6lxFPMGlRdr5CkMVn77P(sIKVXNiwzzIAcUSovI(Y1xl1yzcfsnAuGvkPrLVC9n(Vw9CkHcPgnkGOCofZ3M8fcwOWgzSBFNpGwIjSxPmc0E8VEQGoeSqgGbqGtbUhOfRusJka6d0(haTm0aAZOnFb0smHtkPrGwIPgebAZOneXowO8GmF557zF56lz(ERVWCuDKiwMivkMaP7WmMVKi5lmhvhjILjsLIjMY3M998P(soqlXe2RugbAzw)qNvnvaGbqGBe4EGwSsjnQaOpq7Fa0YqdOnJ28fqlXeoPKgbAjMAqeOnJ2qe7yHYdY8TzE(YNVC9LmFV1xyoQoseltKkftG0DygZxsK8fMJQJeXYePsXeiDhMX8LRVK5lmhvhjILjsLIjGOCofZ3M99uFjrYxQj4Y6quoNI5BZ(EMF(sUVKd0smH9kLrG2uPyDikNtbyaeGGbCpqlwPKgva0hO9paAzOb0MrB(cOLycNusJaTetnic0sMVwQXYemqz5V6bjm4dRrbwPKgv(Y13B99anrqcd(WAuKrBiI(Y134)A1ZPemqz5V6bjm4dRrbeLZPy(sIKV36RLASmbduw(REqcd(WAuGvkPrLVK7lxFjZxjqkkbyD96W9KXsqTjap8LejFTuJLjsOC4(t1TlSRs5cvcSsjnQ8LRVhOjYJp2dUEqTiJ2qe9LejFLaPOeQe2OBWSyupuoT5lb4HVC9vcKIsOsyJUbZIr9q50MVequoNI5BZ(EQVKi5BgTHi2XcLhK5BZ88LpF56Rct7QNLQRWygwytSXub(soqlXe2RugbALt(3d7X)1QNtX6z0gIiGbqGteW9aTyLsAubqFG2)aOLHgqBgT5lGwIjCsjnc0sm1GiqB8jIvwMOMGlRtLOVC9vHPD1Zs1vymdlSj2yQaF56ReifLqHPDX6kquWSm2W3M89o(sIKVsGuuc5ecFoOQhGYm7lSJ1vwrugltaE4ljs(kbsrjSl4O1DgInqOa8WxsK8vcKIsqbX6epOQl)fZGpBSWcWdFjrYxjqkkHgtvxkChPBkFOrb4HVKi5ReifLiELpRlLfkap8LejFJ)RvpNsawxVoCpzSeuBcikNtX8TjFp1xU(g)xREoLip(yQdFWqbeLZPy(2SVN5hqlXe2RugbAvGYhDopyPyagaboHbUhOfRusJka6d0MrB(cO9bnjiMnaAvilcNdB(cO9M6CklNAQaFVPmqqnwMV3mDgaI(omFtFpGZdhlmqBeogcNeOv9MG4ab1yz9dDgaIcisbr2vkPrF567T(APgltawxVoCxspbxMaRusJkF567T(cZr1rIyzIuPycKUdZyagaboZpG7bAXkL0OcG(aTz0MVaAFqtcIzdG2iCmeojqR6nbXbcQXY6h6maefqKcISRusJ(Y13mAdrSJfkpiZ3M55lF(Y1xY89wFTuJLjaRRxhUlPNGltGvkPrLVKi5RLASmbyD96WDj9eCzcSsjnQ8LRVK5B8FT65ucW661H7s6j4YequoNI5BZ(sMVNp1xA5BgTHi2XcLhK5lT9v9MG4ab1yz9dDgaIcikNtX8LCFjrY3mAdrSJfkpiZ3M55BO8LCFjhOngoQXULWa0yae4mGbqGZNbUhOfRusJka6d0MrB(cO9bnjiMnaA1tH9OcO9gbAJWXq4KaTz0gIyx9MG4ab1yz9dDgaI(2KVz0gIyhluEqMVC9nJ2qe7yHYdY8TzE(YNVC9LmFV1xl1yzcW661H7s6j4YeyLsAu5ljs(g)xREoLaSUED4UKEcUmbeLZPy(Y1xjqkkbyD96WDj9eCzDjqkkH65u(soqRczr4CyZxaT3akFTleI(Mq0xSq5bz(kpm2ub(Et5MfIV5XHoSVJ5lzsGMV17R8drFTRS89Ri67bc99g9LHXVumYfagaboZhW9aTyLsAubqFG2iCmeojqleSqQhgGcg4bczgmNsGvkPrLVC9LmFvVjOGpZ6uirekGifezxPKg9LejFvVjK0)R6h6maefqKcISRusJ(soqBgT5lG2h0KGy2aWaiW5qbCpqlwPKgva0hOnJ28fqlNhSuD2bwkec0Qqweoh28fq7nePGi7cz(sNyAxmFPtqKqMVsGuu(Y)azMVsi1drFvyAxmFvGOVyPyaTr4yiCsG24teRSmrnbxwNkrF56Rct7QNLQRWygwytSXub(Y1xY8vHPD1Zs1vymdlYOneXoeLZPy(2KVK5Bqu5lD03ZIt9LCFjrYxjqkkHct7I1vGOaIY5umFBY3GOYxYbmacC(oa3d0IvkPrfa9bAzyeOn(Vw9Ckb7b1DiMhiuar5CkgqBgT5lGwo5yaTr4yiCsGwl1yzc2dQ7qmpqOaRusJkF56RLWa0e2iJD77hrRhQt9TjFp1xU(AjmanHnYy3(UAqFB23t9LRVX)1QNtjypOUdX8aHcikNtX8TjFjZ3GOYx6OV8tqWo1xY9LRVz0gIyhluEqMV889mGbqGZNcCpqlwPKgva0hOvHSiCoS5lGwc(CmFPEOV0jM2fHmFPtqKw0jsnA03HYxcmbxMVeCt0x79nanFzgeRa7YxjqkkFLYydFtwEa0YWiqB8FT65ucfM2fRRarbeLZPyaTz0MVaA5KJb0gHJHWjbAJprSYYe1eCzDQe9LRVX)1QNtjuyAxSUcefquoNI5Bt(gev(Y13mAdrSJfkpiZxE(EgWaiW5Be4EGwSsjnQaOpqldJaTX)1QNtjui1OrbeLZPyaTz0MVaA5KJb0gHJHWjbAJprSYYe1eCzDQe9LRVX)1QNtjui1OrbeLZPy(2KVbrLVC9nJ2qe7yHYdY8LNVNbmacCMGbCpqlwPKgva0hOvHSiCoS5lGw6q0MV8LGgMX8nlLVNGdSqiZxYobhyHqgTAr(deRiY8fSyGhhp0qLVt5BQuFjihOnJ28fqBm16EgT5RUEygqREywVszeO1Gt1angGbqGZNiG7bAXkL0OcG(aTz0MVaAJPw3ZOnF11dZaA1dZ6vkJaTXNiwzzmadGaNpHbUhOfRusJka6d0MrB(cOnMADpJ28vxpmdOvpmRxPmc0cZ4KAgGbqa(4hW9aTyLsAubqFG2mAZxaTXuR7z0MV66HzaT6Hz9kLrG24)A1ZPyagab47mW9aTyLsAubqFG2iCmeojqlXeoPKgfPsX6quoNYxU(sMVX)1QNtjuyAx9SuDfgZWcikNtX8TjFpZpF567T(APgltOqQrJcSsjnQ8LejFJ)RvpNsOqQrJcikNtX8TjFpZpF56RLASmHcPgnkWkL0OYxsK8n(eXkltutWL1Ps0xU(g)xREoLqHPDX6kquar5CkMVn57z(5l5(Y13B9vHPD1Zs1vymdlSj2yQaG2mAZxaTqWQNrB(QRhMb0QhM1RugbAZh7m0apamacWhFa3d0IvkPrfa9bAJWXq4KaTz0gIyhluEqMVnZZx(8LRVkmTREwQUcJzyHnXgtfa0Ym4enacCgOnJ28fqleS6z0MV66HzaT6Hz9kLrG28XUeiKzagab4lua3d0IvkPrfa9bAJWXq4KaTz0gIyhluEqMVnZZx(8LRV36Rct7QNLQRWygwytSXub(Y1xY89wFjMWjL0OivkwhIY5u(sIKVX)1QNtjuyAx9SuDfgZWcikNtX8TzFpZpF567T(APgltOqQrJcSsjnQ8LejFJ)RvpNsOqQrJcikNtX8TzFpZpF56RLASmHcPgnkWkL0OYxsK8n(eXkltutWL1Ps0xU(g)xREoLqHPDX6kquar5CkMVn77z(5l5aTz0MVaAHGvpJ28vxpmdOvpmRxPmc0gGfcNypFeWaiaF3b4EGwSsjnQaOpqBeogcNeOnJ2qe7yHYdY8LNVNbAZOnFb0gtTUNrB(QRhMb0QhM1RugbAdWcHteWamGwdovd0ya3dqGZa3d0IvkPrfa9bAZOnFb0oflcbTusJD(dmlduURqItebAJWXq4KaTK5B8FT65ucW661H7s6j4YequoNI5BZ(Yh)8LejFJ)RvpNsOsyJUbZIr9q50MVequoNI1r6EGrdv(2SV8XpFj3xU(sMVz0gIyhluEqMVnZZx(8LejFpqtKq5W9GRhulYOnerFjrY3d0e5Xh7bxpOwKrBiI(Y1xY81snwMaSUED4EYyjO2eyLsAu5ljs(QW0U6nQj4YeQHLsASNVP8LCFjrY3d0ebjm4dRrrgTHi6l5(sIKVspJ5lxFPMGlRdr5CkMVn5lFN9LejFvyAx9g1eCzc1Wsjn2h(t1r6Irqd9LNV8ZxU(AjmanHnYy3((r068XpFBY3tbARugbANIfHGwkPXo)bMLbk3viXjIagab4d4EGwSsjnQaOpqBgT5lGw7c7udKzD2emAG2iCmeojqlXeoPKgfYj)7H94)A1ZPy9mAdr0xU(sMV2iJ(2SVHIF(sIKV36lYFGZXbQetXIqqlL0yN)aZYaL7kK4erFjhOTszeO1UWo1azwNnbJgWaiqOaUhOfRusJka6d0MrB(cO9jIqoxOwEQG(XZbH9immZsnqBeogcNeOLycNusJc5K)9WE8FT65uSEgTHi6lxFjZxBKrFB23qXpFjrY3B9f5pW54avIPyriOLsASZFGzzGYDfsCIOVC99wFr(dCooqLWUWo1azwNnbJ2xYbARugbAFIiKZfQLNkOF8CqypcdZSudyae4oa3d0IvkPrfa9bAZOnFb0AWPAG2zGwfYIW5WMVaAV)c91Gt1anF5m2LV2f671eCHmZxKzJCAOYxIPgedXxoJw7Re6lidv(snqM5BwkFpYbIkF5m2LV0HJpM6Whm0xYgkFLaPO8Dy(E(uFzy8lfZ3h6RgzmY99H(sF9eCz0IoV3xYgkFdGyAi0x7klFpFQVmm(LIroqBeogcNeO9wFjMWjL0OGDGXHAqv3Gt1anF56lz(sMVgCQgOjSZcjqkQUceM28LVnXZ3ZN6lxFJ)RvpNsKhFm1HpyOaIY5umFB2x(4NVKi5RbNQbAc7SqcKIQRaHPnF5BZ(E(uF56lz(g)xREoLaSUED4UKEcUmbeLZPy(2SV8XpFjrY34)A1ZPeQe2OBWSyupuoT5lbeLZPyDKUhy0qLVn7lF8ZxY9LejFZOneXowO8GmFBMNV85lxFLaPOeQe2OBWSyupuoT5lb4HVK7lxFjZ3B91Gt1anHXN4kz94)A1ZP8LejFn4unqty8jI)RvpNsar5CkMVKi5lXeoPKgfgCQgO1pGZdhlSV889SVK7l5(sIKVspJ5lxFn4unqtyNfsGuuDfimT5lFBMNVutWL1HOCofdWaiWPa3d0IvkPrfa9bAJWXq4KaT36lXeoPKgfSdmoudQ6gCQgO5lxFjZxY81Gt1anHXNqcKIQRaHPnF5Bt8898P(Y134)A1ZPe5XhtD4dgkGOCofZ3M9Lp(5ljs(AWPAGMW4tibsr1vGW0MV8TzFpFQVC9LmFJ)RvpNsawxVoCxspbxMaIY5umFB2x(4NVKi5B8FT65ucvcB0nywmQhkN28LaIY5uSos3dmAOY3M9Lp(5l5(sIKVz0gIyhluEqMVnZZx(8LRVsGuucvcB0nywmQhkN28La8WxY9LRVK57T(AWPAGMWolUswp(Vw9CkFjrYxdovd0e2zr8FT65ucikNtX8LejFjMWjL0OWGt1aT(bCE4yH9LNV85l5(sUVKi5R0Zy(Y1xdovd0egFcjqkQUceM28LVnZZxQj4Y6quoNIb0MrB(cO1Gt1an(amacCJa3d0IvkPrfa9bAZOnFb0AWPAG2zGwM(nGwdovd0od0gHJHWjbAV1xIjCsjnkyhyCOgu1n4unqZxU(ERVgCQgOjSZIRK1bzyxcKIYxU(sMVgCQgOjm(eX)1QNtjGOCofZxsK89wFn4unqty8jUswhKHDjqkkFjhOvHSiCoS5lG2BaLVFPd77xOVF5lid91Gt1anFpGpXrHmFtFLaPOcXxqg6RDH((2fc99lFJ)RvpNs47ja67q5BHJDHqFn4unqZ3d4tCuiZ30xjqkQq8fKH(k92LVF5B8FT65ucadGaemG7bAXkL0OcG(aTz0MVaAn4unqJpG2iCmeojq7T(smHtkPrb7aJd1GQUbNQbA(Y13B91Gt1anHXN4kzDqg2LaPO8LRVK5RbNQbAc7Si(Vw9CkbeLZPy(sIKV36RbNQbAc7S4kzDqg2LaPO8LCGwM(nGwdovd04dWamadOLiczZxaeGp(XhF8Jp(UrGwojSMkGb0sWthUHe4gqGtOq7RV3FH(oYhp08L6H(sy(yNHg4bH(cr(dCGOYx2lJ(MG2lNgQ8nELvaYeone0uOVNdTVN8lIi0qLVeAPgltqpc91EFj0snwMGEcSsjnQi0xYotxYfone0uOV8fAFp5xerOHkFjecwi1ddqb9i0x79LqiyHupmaf0tGvkPrfH(s2z6sUWPHGMc99gdTVN8lIi0qLVeAPgltqpc91EFj0snwMGEcSsjnQi0xY4JUKlCACAi4Pd3qcCdiWjuO9137VqFh5JhA(s9qFjmFSlbczgH(cr(dCGOYx2lJ(MG2lNgQ8nELvaYeone0uOVHk0(EYViIqdv(sOLASmb9i0x79Lql1yzc6jWkL0OIqFjlu0LCHtdbnf67DcTVN8lIi0qLVecblK6HbOGEe6R9(sieSqQhgGc6jWkL0OIqFj7mDjx4040qWthUHe4gqGtOq7RV3FH(oYhp08L6H(sObNQbAmc9fI8h4arLVSxg9nbTxonu5B8kRaKjCAiOPqFphAFp5xerOHkFj0snwMGEe6R9(sOLASmb9eyLsAurOVKDMUKlCAiOPqFVtO99KFreHgQ8Lqdovd0eNf0JqFT3xcn4unqtyNf0JqFjlu0LCHtdbnf67DcTVN8lIi0qLVeAWPAGMGpb9i0x79Lqdovd0egFc6rOVKXhDjx40qqtH(EAO99KFreHgQ8Lqdovd0eNf0JqFT3xcn4unqtyNf0JqFjJp6sUWPHGMc990q77j)Iicnu5lHgCQgOj4tqpc91EFj0Gt1anHXNGEe6lzHIUKlCAiOPqFVXq77j)Iicnu5lHgCQgOjolOhH(AVVeAWPAGMWolOhH(s2z6sUWPHGMc99gdTVN8lIi0qLVeAWPAGMGpb9i0x79Lqdovd0egFc6rOVKXhDjx40qqtH(sWcTVN8lIi0qLVeAWPAGM4SGEe6R9(sObNQbAc7SGEe6lz8rxYfone0uOVeSq77j)Iicnu5lHgCQgOj4tqpc91EFj0Gt1anHXNGEe6lzNPl5cNgNgcE6WnKa3acCcfAF99(l03r(4HMVup0xcdWcHtKqFHi)boqu5l7LrFtq7Ltdv(gVYkazcNgcAk03ZH23t(freAOYxcHGfs9Wauqpc91EFjecwi1ddqb9eyLsAurOVKDMUKlCAiOPqF5l0(EYViIqdv(sOLASmb9i0x79Lql1yzc6jWkL0OIqFj7mDjx40qqtH(YxO99KFreHgQ8LqiyHupmaf0JqFT3xcHGfs9WauqpbwPKgve6lzNPl5cNgcAk0x(cTVN8lIi0qLVeg)sboMGEe6R9(sy8lf4yc6jWkL0OIqFj7mDjx40qqtH(gQq77j)Iicnu5lHqWcPEyakOhH(AVVecblK6HbOGEcSsjnQi0xYotxYfone0uOVNgAFp5xerOHkFjecwi1ddqb9i0x79LqiyHupmaf0tGvkPrfH(s2z6sUWPXPHGNoCdjWnGaNqH2xFV)c9DKpEO5l1d9LW4teRSmgH(cr(dCGOYx2lJ(MG2lNgQ8nELvaYeone0uOVNdTVN8lIi0qLVeAPgltqpc91EFj0snwMGEcSsjnQi0xYotxYfone0uOVHk0(EYViIqdv(sOLASmb9i0x79Lql1yzc6jWkL0OIqFj7mDjx40qqtH(gQq77j)Iicnu5lHShulnLsqpc91EFjK9GAPPuc6jWkL0OIqFj7mDjx40qqtH(ENq77j)Iicnu5lHwQXYe0JqFT3xcTuJLjONaRusJkc9LSZ0LCHtdbnf67DcTVN8lIi0qLVeYEqT0ukb9i0x79Lq2dQLMsjONaRusJkc9LSZ0LCHtdbnf67PH23t(freAOYxcHGfs9Wauqpc91EFjecwi1ddqb9eyLsAurOVKXhDjx40qqtH(EAO99KFreHgQ8Lq2dQLMsjOhH(AVVeYEqT0ukb9eyLsAurOVKDMUKlCAiOPqFjyH23t(freAOYxcTuJLjOhH(AVVeAPgltqpbwPKgve6lzNPl5cNgcAk03t4q77j)Iicnu5lHShulnLsqpc91EFjK9GAPPuc6jWkL0OIqFjJp6sUWPXPHGNoCdjWnGaNqH2xFV)c9DKpEO5l1d9LWdigFzP0i0xiYFGdev(YEz03e0E50qLVXRScqMWPHGMc99oH23t(freAOYxcTuJLjOhH(AVVeAPgltqpbwPKgve6BA(EtobeKVKDMUKlCAiOPqFpn0(EYViIqdv(2oYN0xw4Ys667n)M7R9(sqGPVYVcudY89pqyAp0xYU5K7lzNPl5cNgcAk03tdTVN8lIi0qLVeAWPAGM4SGEe6R9(sObNQbAc7SGEe6lz8rxYfone0uOV3yO99KFreHgQ8TDKpPVSWLL013B(n3x79LGatFLFfOgK57FGW0EOVKDZj3xYotxYfone0uOV3yO99KFreHgQ8Lqdovd0e8jOhH(AVVeAWPAGMW4tqpc9Lm(Ol5cNgcAk0xcwO99KFreHgQ8TDKpPVSWLL013BUV27lbbM(QgIdB(Y3)aHP9qFjJwK7lz8rxYfone0uOVeSq77j)Iicnu5lHgCQgOjolOhH(AVVeAWPAGMWolOhH(s2DOl5cNgcAk0xcwO99KFreHgQ8Lqdovd0e8jOhH(AVVeAWPAGMW4tqpc9LStPl5cNgcAk03tuO99KFreHgQ8Lql1yzc6rOV27lHwQXYe0tGvkPrfH(s2z6sUWPHGMc99efAFp5xerOHkFjm(LcCmb9i0x79LW4xkWXe0tGvkPrfH(MMV3Ktab5lzNPl5cNgcAk03t4q77j)Iicnu5lHqWcPEyakOhH(AVVecblK6HbOGEcSsjnQi03089MCciiFj7mDjx40qqtH(EchAFp5xerOHkFjecwi1ddqb9i0x79LqiyHupmaf0tGvkPrfH(s2z6sUWPXPHGNoCdjWnGaNqH2xFV)c9DKpEO5l1d9LW4)A1ZPye6le5pWbIkFzVm6BcAVCAOY34vwbit40qqtH(YxO99KFreHgQ8Lql1yzc6rOV27lHwQXYe0tGvkPrfH(sgF0LCHtdbnf6lFH23t(freAOYxcHGfs9Wauqpc91EFjecwi1ddqb9eyLsAurOVKXhDjx40qqtH(YxO99KFreHgQ8Lq2dQLMsjOhH(AVVeYEqT0ukb9eyLsAurOVKXhDjx40qqtH(EJH23t(freAOYxcTuJLjOhH(AVVeAPgltqpbwPKgve6lzNPl5cNgcAk03tuO99KFreHgQ8Lql1yzc6rOV27lHwQXYe0tGvkPrfH(s2z6sUWPXPHGNoCdjWnGaNqH2xFV)c9DKpEO5l1d9LWaSq4e75Je6le5pWbIkFzVm6BcAVCAOY34vwbit40qqtH(Eo0(EYViIqdv(sOLASmb9i0x79Lql1yzc6jWkL0OIqFj7mDjx40qqtH(YxO99KFreHgQ8LqiyHupmaf0JqFT3xcHGfs9WauqpbwPKgve6lzNPl5cNgNgcE6WnKa3acCcfAF99(l03r(4HMVup0xcvivcQnc9fI8h4arLVSxg9nbTxonu5B8kRaKjCAiOPqFdvO99KFreHgQ8Lql1yzc6rOV27lHwQXYe0tGvkPrfH(swOOl5cNgcAk037eAFp5xerOHkFj0snwMGEe6R9(sOLASmb9eyLsAurOVKXhDjx40qqtH(sWcTVN8lIi0qLVeAPgltqpc91EFj0snwMGEcSsjnQi0xYcfDjx40qqtH(EchAFp5xerOHkFj0snwMGEe6R9(sOLASmb9eyLsAurOVKDMUKlCAiOPqFpZVq77j)Iicnu5B7iFsFzHllPRV3CFT3xccm9vneh28LV)bct7H(sgTi3xYotxYfone0uOVN5xO99KFreHgQ8Lql1yzc6rOV27lHwQXYe0tGvkPrfH(sgF0LCHtdbnf675ZH23t(freAOYxcTuJLjOhH(AVVeAPgltqpbwPKgve6lzNPl5cNgcAk03Z8fAFp5xerOHkFjecwi1ddqb9i0x79LqiyHupmaf0tGvkPrfH(s2z6sUWPHGMc998DcTVN8lIi0qLVeAPgltqpc91EFj0snwMGEcSsjnQi0xYotxYfone0uOV8Do0(EYViIqdv(sOLASmb9i0x79Lql1yzc6jWkL0OIqFjJp6sUWPHGMc9LVqfAFp5xerOHkFj0snwMGEe6R9(sOLASmb9eyLsAurOVKXhDjx4040CdKpEOHkFpZpFZOnF5REygt40a0MG21dbABhzqDAZxNeMugq7b8Pgnc0E376lDIPD5lbh1eCz(EtxxVoStZDVRVeCrjiycd7lFeSq8Lp(XhFonon39U(EYRScqwODAU7D9L)7lDqX)azMmwgZx79Lol6Kw0jsnAKw0jM2fZx6ee91EF)sh234dwMVwcdqJ5lNR33eI(I09aJgQ81EF1dr0x9xb(I1dgC5R9(kNMHqFjlFSZqd8W37EMCHtZDVRV8FFPZHLsAu5BBgHd1eNu77nlJMVsymbzOVkmv(gC9GAMVYzd0xQh6llv(sNeCWeon39U(Y)99MMnvGVe8pyP8T9alfc9nLg9ydY8v(HOVuAKUJKoSVKLMV3H2(YSm2G57umdtLVpLVNsBYVPYx68M16BHGgm1(MLYx5mSVhqKiwMVSxg9TE(peJ(YgdmT5lMWP5U31x(VV30SPc8LGlYmeovGVTgCAG(oLV0HtWnX3HY3WpOVxjr036TRPc8f1m0x79v9(MLYxoFrO57teHX8WxopyPy(omFPZBwRVfcAWulCAU7D9L)77jVYkav(kNvyFjKAcUSoeLZPye6B8l1yZxPM5R9(Mhh6W(oLVspJ5l1eCzmF)sh2xY0iJ57jPtF5Kmd99lFnyYUix40C376l)3x6GsHkFZ6Tle67ja0KGy2WxSmyyFT3xgA(cE4lZGFfGqFVjhJcLNit40C376l)33BiQt66B79(sKj8LoCcUj(Q)Gj6lBQi67y(cr9GmF)Y34xuPeOonu5lmhvhjILXeon39U(Y)99(taDEccTV(sWnJ2d9T1Gyfyx(Ea)iZ3PS3xdovd08v)btu4040KrB(IjoGy8LLsJ28O1XBZxonz0MVyIdigFzP0OnpAbZHHDfMkNMmAZxmXbeJVSuA0MhTO0i7kctkZPjJ28ftCaX4llLgT5rRekhU)uD7c7kmvHCaX4llLw3gzKxOczO4DRLASmbduw(REqcd(WA0P5U(EtiMAW0qMVPVgCQgOX8n(Vw9CQq8vnehfQ8vkSV35uHV3FnmF5KmFJxpdlFtMVG11Rd7lNh2G57x(ENt9LHXVu(kbczMVXWrnYcXxjqZ3RK5R9VVYzf23Oc6lsrHrJ5R9(gmerFtFJ)RvpNsqxHceM28LVQH4WEOVtXmmvcFVbu(ogHmFjMAq03RK5B9(cr5Ckfc9fIgiS89Ci(IAg6lenqy5l)eNkCAYOnFXehqm(YsPrBE0IycNusJHuPmYZGt1aT(5olCfd5p4XqBOcHyQbrENdHyQbXoQzip(jonK4xQXMV4zWPAGM4S4kzDqg2LaPO4sMbNQbAIZI4)A1ZPekqyAZx38B(DoLh)i3PjJ28ftCaX4llLgT5rlIjCsjngsLYipdovd0681zHRyi)bpgAdvietniY7Cietni2rnd5XpXPHe)sn28fpdovd0e8jUswhKHDjqkkUKzWPAGMGpr8FT65ucfimT5RB(n)oNYJFK70CxFVjmBKtdz(M(AWPAGgZxIPge9vkSVXx(iHtf4RDH(g)xREoLVpLV2f6RbNQbAH4RAioku5RuyFTl0xfimT5lFFkFTl0xjqkkFhZ3d4tCuit4lbNjZ30xMbXkWU8v(vd1GqFT33GHi6B671eCHqFpGZdhlSV27lZGyfyx(AWPAGgleFtMVCqT23K5B6R8RgQbH(s9qFhkFtFn4unqZxoJw77d9LZO1(wV5llCf9LZyx(g)xREoft40KrB(IjoGy8LLsJ28OfXeoPKgdPszKNbNQbA9d48WXchYFWJH2qfcXudI84leIPge7OMH8ohs8l1yZx8U1Gt1anXzXvY6GmSlbsrX1Gt1anbFIRK1bzyxcKIIejdovd0e8jUswhKHDjqkkUKrMbNQbAc(eX)1QNtjuGW0MVU5gCQgOj4tibsr1vGW0MViNos2zXP02Gt1anbFIRK1LaPOiNosgXeoPKgfgCQgO15RZcxrYjVzYiZGt1anXzr8FT65ucfimT5RBUbNQbAIZcjqkQUceM28f50rYoloL2gCQgOjolUswxcKIIC6izet4KsAuyWPAGw)CNfUIKtUtZD99Mqm1GPHmFJGqiwMVm0ap8L6H(AxOV8hyw2yH99P8LoC8Xuh(GH(Es68g6lsrHrJ50KrB(IjoGy8LLsJ28OfXeoPKgdPszKhfOw3JkyietniYZsnwMiHYH7pv3UWUkLluXn(LcCmr8lIFmT5R(t1TlSRWu50KrB(IjoGy8LLsJ28OfXeoPKgdPszKNk2HwietniYdcwi1ddqHct7I1Ji0YPSWCHGfs9Wauat5JSSUbZIrHqSIOtJtZDVRV3e6Irqdv(IeryyFTrg91UqFZO9qFhMVjXC0PKgfonz0MVy8KNs1PGiEIrNM767ndIeXY8LDGXHAqLVgCQgOX8vcNkWxqgQ8LZyx(MG2lN2e9vpfYCAYOnFXOnpArmHtkPXqQug5XoW4qnOQBWPAGwietniYJmK)aNJdujMIfHGwkPXo)bMLbk3viXjIKiH8h4CCGkHDHDQbYSoBcgnjsi)bohhOs8eriNlulpvq)45GWEegMzPMCUKf)xREoLykwecAPKg78hywgOCxHeNikGyQctIu8FT65uc7c7udKzD2emAbeLZPyKif)xREoL4jIqoxOwEQG(XZbH9immZsTaIY5umYjrImK)aNJdujSlStnqM1ztWOjrc5pW54avINic5CHA5Pc6hphe2JWWml1KZf5pW54avIPyriOLsASZFGzzGYDfsCIOtZDVRV3us4KsAK50KrB(IrBE0IycNusJHuPmY74F9ubDiynX(XZbHHqm1GiV4)A1ZPemqz5V6bjm4dRrbeLZPynDkxl1yzcgOS8x9Geg8H1ixYSuJLjaRRxhUlPNGlJB8FT65ucW661H7s6j4YequoNI105qXn(Vw9CkHkHn6gmlg1dLtB(sar5CkwhP7bgnu105qrI0TwQXYeG11Rd3L0tWLrUttgT5lgT5rlIjCsjngsLYiVJ)1tf0HGfYcHyQbrEwQXYeShu3HyEGqUqWcBIpUwcdqtyJm2TVFeTEOoTPt5snbxwhIY5uSMpLeP4teRSmrnbxwNkrUwQXYekKA0i34)A1ZPekKA0OaIY5uSMGGfkSrg7235ZPjJ28fJ28OfXeoPKgdPszKhZ6h6SQPccHyQbrEz0gIyhluEqgVZCj7wyoQoseltKkftG0DygJejyoQoseltKkftmvZNpLCNMmAZxmAZJwet4KsAmKkLrEPsX6quoNkeIPge5LrBiIDSq5bznZJpUKDlmhvhjILjsLIjq6omJrIemhvhjILjsLIjq6omJXLmyoQoseltKkftar5CkwZNsIe1eCzDikNtXA(m)iNCNMmAZxmAZJwet4KsAmKkLrEYj)7H94)A1ZPy9mAdrmeIPge5rMLASmbduw(REqcd(WAK7ThOjcsyWhwJImAdrKB8FT65ucgOS8x9Geg8H1OaIY5umsKU1snwMGbkl)vpiHbFynsoxYKaPOeG11Rd3tglb1Ma8Gejl1yzIekhU)uD7c7QuUqf3d0e5Xh7bxpOwKrBiIKijbsrjujSr3GzXOEOCAZxcWdUsGuucvcB0nywmQhkN28LaIY5uSMpLePmAdrSJfkpiRzE8XvHPD1Zs1vymdlSj2yQaYDAYOnFXOnpArmHtkPXqQug5PaLp6CEWsXcHyQbrEXNiwzzIAcUSovICvyAx9SuDfgZWcBInMkGReifLqHPDX6kquWSm2OP7qIKeifLqoHWNdQ6bOmZ(c7yDLveLXYeGhKijbsrjSl4O1DgInqOa8GejjqkkbfeRt8GQU8xmd(SXclapirscKIsOXu1Lc3r6MYhAuaEqIKeifLiELpRlLfkapirk(Vw9CkbyD96W9KXsqTjGOCofRPt5g)xREoLip(yQdFWqbeLZPynFMFon313BQZPSCQPc89MYab1yz(EZ0zai67W8n99aopCSWonz0MVy0MhTEqtcIzJqgkEQ3eehiOglRFOZaquarkiYUsjnY9wl1yzcW661H7s6j4Y4ElmhvhjILjsLIjq6omJ50KrB(IrBE06bnjiMncjgoQXULWa0y8ohYqXt9MG4ab1yz9dDgaIcisbr2vkPrUz0gIyhluEqwZ84Jlz3APgltawxVoCxspbxgjswQXYeG11Rd3L0tWLXLS4)A1ZPeG11Rd3L0tWLjGOCofRzYoF6npJ2qe7yHYdYOT6nbXbcQXY6h6maefquoNIrojsz0gIyhluEqwZ8cf5K70CxFVbu(Axie9nHOVyHYdY8vEySPc89MYnleFZJdDyFhZxYKanFR3x5hI(Axz57xr03de67n6ldJFPyKlCAYOnFXOnpA9GMeeZgHONc7rfVBmKHIxgTHi2vVjioqqnww)qNbGytz0gIyhluEqg3mAdrSJfkpiRzE8XLSBTuJLjaRRxhUlPNGlJeP4)A1ZPeG11Rd3L0tWLjGOCofJReifLaSUED4UKEcUSUeifLq9CkYDAYOnFXOnpA9GMeeZgHmu8GGfs9WauWapqiZG5uCjt9MGc(mRtHerOaIuqKDLsAKej1Bcj9)Q(HodarbePGi7kL0i5on313Bisbr2fY8LoX0Uy(sNGiHmFLaPO8L)bYmFLqQhI(QW0Uy(QarFXsXCAYOnFXOnpAX5blvNDGLcHHmu8IprSYYe1eCzDQe5QW0U6zP6kmMHf2eBmvaxYuyAx9SuDfgZWImAdrSdr5CkwtKfev0XZItjNejjqkkHct7I1vGOaIY5uSMcIkYDAYOnFXOnpAXjhlegg5f)xREoLG9G6oeZdekGOCoflKHINLASmb7b1DiMhiKRLWa0e2iJD77hrRhQtB6uUwcdqtyJm2TVRgS5t5g)xREoLG9G6oeZdekGOCofRjYcIk6i)eeStjNBgTHi2XcLhKX7StZD9LGphZxQh6lDIPDriZx6eePfDIuJg9DO8LatWL5lb3e91EFdqZxMbXkWU8vcKIYxPm2W3KLhonz0MVy0MhT4KJfcdJ8I)RvpNsOW0UyDfikGOCoflKHIx8jIvwMOMGlRtLi34)A1ZPekmTlwxbIcikNtXAkiQ4MrBiIDSq5bz8o70KrB(IrBE0ItowimmYl(Vw9CkHcPgnkGOCoflKHIx8jIvwMOMGlRtLi34)A1ZPekKA0OaIY5uSMcIkUz0gIyhluEqgVZon31x6q0MV8LGgMX8nlLVNGdSqiZxYobhyHqgTAr(deRiY8fSyGhhp0qLVt5BQuFji3PjJ28fJ28Ovm16EgT5RUEywivkJ8m4unqJ50KrB(IrBE0kMADpJ28vxpmlKkLrEXNiwzzmNMmAZxmAZJwXuR7z0MV66HzHuPmYdMXj1mNM7ExFZOnFXOnpAXq(deRigYqXlJ2qe7yHYdY4DM7TkmTREJAcUmHAyPKg75BkUwQXYemqz5V6bjm4dRXqQug5fKWG(FGfcd9dAsqmBeAkKziCQGoZGtdm0uiZq4ubDMbNgyOzGYYF1dsyWhwJHoHYH7pv3UWUctvOvyAx94p6qgkEsGuucgOsHvx9VSa8i0kmTRE8hDOvyAx94p6qZIpima7mdonWqgkEkucKIsqHmdHtf058GLsWSm2O57eAw8bHbyNzWPbgYqXtHsGuuckKziCQGoNhSucMLXgnFNqtHmdHtf0zgCAGon39U(MrB(IrBE0IH8hiwrmKHIxgTHi2XcLhKX7m3BvyAx9g1eCzc1Wsjn2Z3uCV1snwMGbkl)vpiHbFyngsLYiV)alegAkKziCQGoZGtdm0uiZq4ubDMbNgyOpEB(k0G11Rd3L0tWLfAvcB0nywmQhkN28vOZJpM6Whm0PjJ28fJ28Ovm16EgT5RUEywivkJ8I)RvpNI50KrB(IrBE0ccw9mAZxD9WSqQug5Lp2zObEeYqXJycNusJIuPyDikNtXLS4)A1ZPekmTREwQUcJzybeLZPynDMFCV1snwMqHuJgjrk(Vw9CkHcPgnkGOCofRPZ8JRLASmHcPgnsIu8jIvwMOMGlRtLi34)A1ZPekmTlwxbIcikNtXA6m)iN7TkmTREwQUcJzyHnXgtf40KrB(IrBE0ccw9mAZxD9WSqQug5Lp2LaHmleMbNOX7CidfVmAdrSJfkpiRzE8XvHPD1Zs1vymdlSj2yQaNMmAZxmAZJwqWQNrB(QRhMfsLYiVaSq4e75JHmu8YOneXowO8GSM5Xh3BvyAx9SuDfgZWcBInMkGlz3smHtkPrrQuSoeLZPirk(Vw9CkHct7QNLQRWygwar5CkwZN5h3BTuJLjui1OrsKI)RvpNsOqQrJcikNtXA(m)4APgltOqQrJKifFIyLLjQj4Y6ujYn(Vw9CkHct7I1vGOaIY5uSMpZpYDAYOnFXOnpAftTUNrB(QRhMfsLYiVaSq4edzO4LrBiIDSq5bz8o7040C376lD4Vj(sFqiZCAYOnFXe5JDjqiZ4f1jNPc6SRu9CyHmu8YOneXowO8GSM4DQttgT5lMiFSlbczgT5rROo5mvqNDLQNdlKHIxgTHi2XcLhKX7g5QW0U6nQj4YeuCEWsHQULWa0ynZluonz0MVyI8XUeiKz0MhT48GLQZoWsHWqgkEwQXYesGqMnvqN9qKXLmfM2vVrnbxMGIZdwku1TegGgJxgTHi2XcLhKrIKct7Q3OMGltqX5blfQ6wcdqJ1mVqrojswQXYesGqMnvqN9qKX1snwMiQtotf0zxP65W4QW0U6nQj4YeuCEWsHQULWa0ynZ7SttgT5lMiFSlbczgT5rlfM2vp(JoKHIhzsGuucgOsHvx9VSaIz0ir6wIjCsjnko(xpvqhcwtSF8Cqi5CjtcKIsOsyJUbZIr9q50MVeGhCHGfs9WauOWuPhKz94pAUz0gIyhluEqwt8cfjsz0gIyhluEqgp(i3PjJ28ftKp2LaHmJ28OfEmkuEIHmu8GG1e7hphekui1ehRjYoZpARW0U6nQj4YeuCEWsHQULWa0y0XqroxfM2vVrnbxMGIZdwku1TegGgRPBK7Tet4KsAuC8VEQGoeSMy)45GqsKKaPOemojuEQGU8Wmb4HttgT5lMiFSlbczgT5rl8yuO8edzO4bbRj2pEoiuOqQjowt8DkxfM2vVrnbxMGIZdwku1TegGgR5t5ElXeoPKgfh)RNkOdbRj2pEoi0PjJ28ftKp2LaHmJ28OfEmkuEIHmu8UvHPD1ButWLjO48GLcvDlHbOX4ElXeoPKgfh)RNkOdbRj2pEoiKejQj4Y6quoNI10PKibZr1rIyzIuPycKUdZyCH5O6irSmrQumbeLZPynDQttgT5lMiFSlbczgT5rlopyP6SdSui0PjJ28ftKp2LaHmJ28OfEmkuEIHmu8ULycNusJIJ)1tf0HG1e7hphe6040C376lD4Vj(2Ig4HttgT5lMiFSZqd8GxwH7QsfYqXtHPD1ButWLjO48GLcvDlHbOXAMxmCuJDSq5bzKiPW0U6nQj4YeuCEWsHQULWa0ynZ7usKU1snwMqceYSPc6ShImsKG5O6irSmrQumbs3HzmUWCuDKiwMivkMaIY5uSM4D(mjsspJXLAcUSoeLZPynX78zNMmAZxmr(yNHg4bT5rlfM2vp(JoKHI3Tet4KsAuC8VEQGoeSMy)45GqUKjbsrjujSr3GzXOEOCAZxcWdUqWcPEyakuyQ0dYSE8hn3mAdrSJfkpiRjEHIePmAdrSJfkpiJhFK70KrB(IjYh7m0apOnpAHhJcLNyidfVBjMWjL0O44F9ubDiynX(XZbHonz0MVyI8XodnWdAZJwuiZq4ubDMbNgyiXWrn2TegGgJ35qgkEkucKIsqHmdHtf058GLsWSm2OjEHIB8FT65uI84JPo8bdfquoNI1uOCAYOnFXe5JDgAGh0MhTOqMHWPc6mdonWqIHJASBjmangVZHmu8uOeifLGczgcNkOZ5blLGzzSrtNDAYOnFXe5JDgAGh0MhTOqMHWPc6mdonWqIHJASBjmangVZHmu8GGfkSrg723VttKf)xREoLqHPD1Zs1vymdlGOCofJ7TwQXYekKA0ijsX)1QNtjui1OrbeLZPyCTuJLjui1OrsKIprSYYe1eCzDQe5g)xREoLqHPDX6kquar5Ckg5on31xc(lS81syaA(Y4KhmFti6RAyPKgvH4RDnmF5mATVA08n8d6l7alLVqWcz0IZdwkMVtXmmv((u(YjhBQaFPEOV0zrN0IorQrJ0IoX0UiK5lDcIcNMmAZxmr(yNHg4bT5rlopyP6SdSuimKHIhz3YqZMkGjIHJAKejfM2vVrnbxMGIZdwku1TegGgRzEXWrn2XcLhKroxfkbsrjOqMHWPc6CEWsjywgB0CO4cbluyJm2TVhQMI)RvpNsKv4UQucikNtXCACAU7D99M928LttgT5lMi(Vw9CkgVJ3MVczO4rmHtkPrHCY)Eyp(Vw9CkwpJ2qejr6anrqcd(WAuKrBiICpqteKWGpSgfquoNI1ep(UrsKKEgJl1eCzDikNtXAIVB0P5U313t(Vw9CkMttgT5lMi(Vw9CkgT5rRekhU)uD7c7kmvHmu8I)RvpNsawxVoCxspbxMaIY5uSMiyCJ)RvpNsOsyJUbZIr9q50MVequoNI1r6EGrdvnrW4APgltawxVoCxspbxgxYyO1L(cKjSbH8DI635iY1syaAcBKXU99JO1d1PnDhsKULHwx6lqMWgeY3jQFNJijsutWL1HOCofRz(4h)iNlzX)1QNtjsPxEQ0MV66rwsar5CkwtNprCjdcwi1ddqrk9YtL28fRtbX6ehMej2dQLMsjAGeNI1))eJ6PciNePBHGfs9WauKsV8uPnFX6uqSoXH5El7b1stPenqItX6)FIr9ubKZLS4)A1ZPe5XhtD4dgkGOCofRJ09aJgQAIGXLycNusJckqTUhvqsKULycNusJckqTUhvqsKiMWjL0Oqf7qJCsKU1snwMaSUED4UKEcUmsKKEgJl1eCzDikNtXAkuN60KrB(IjI)RvpNIrBE0I9G6oeZdegsmCuJDlHbOX4DoKHINLWa0e2iJD77hrRhQtB6uUKzjmanHnYy3(UAWMpLBgTHi2XcLhK1eVqrIedTU0xGmHniKVtu)ohrUsGuucvcB0nywmQhkN28La8GBgTHi2XcLhK1eVt5s2TkmTREwQUcJzyHnXgtfqIu8jIvwMOMGlRtLi5K70CxFj481kMV0xpbxMVup0xWdFT33t9LHXVumFT3xw4k6lNXU8LoC8Xuh(GHH47jWUqiNHHH4lid9LZyx(sNjSHV3dZIr9q50MVeonz0MVyI4)A1ZPy0MhTaRRxhUlPNGllKHIhXeoPKgfmRFOZQMkGlzX)1QNtjYJpM6Whmuar5CkwhP7bgnu10PKif)xREoLip(yQdFWqbeLZPyDKUhy0qvZN5h5Cjl(Vw9CkHkHn6gmlg1dLtB(sar5CkwtbrfjssGuucvcB0nywmQhkN28La8GCNMmAZxmr8FT65umAZJwG11Rd3L0tWLfYqXJycNusJIuPyDikNtrIK0ZyCPMGlRdr5Ckwt8D2PjJ28fte)xREofJ28OLkHn6gmlg1dLtB(kKHIhXeoPKgfmRFOZQMkGlzQ3eG11Rd3L0tWL1vVjGOCofJePBTuJLjaRRxhUlPNGlJCNMmAZxmr8FT65umAZJwQe2OBWSyupuoT5RqgkEet4KsAuKkfRdr5CksKKEgJl1eCzDikNtXAIVZonz0MVyI4)A1ZPy0MhTYJpM6WhmmKHIxgTHi2XcLhKX7mxfkbsrjOqMHWPc6CEWsjywgB0mV7WLSBjMWjL0OGcuR7rfKejIjCsjnkOa16Eub5sw8FT65ucW661H7s6j4YequoNI18z(rIu8FT65ucvcB0nywmQhkN28LaIY5uSos3dmAOQ5Z8J7TwQXYeG11Rd3L0tWLro5onz0MVyI4)A1ZPy0MhTYJpM6WhmmKy4Og7wcdqJX7CidfVmAdrSJfkpiRzE8XvHsGuuckKziCQGoNhSucMLXgnZ7oCVvHPD1Zs1vymdlSj2yQaNMmAZxmr8FT65umAZJwmqz5V6bjm4dRXqgkEqWAI9JNdcfkKAIJ1057Wn(Vw9CkbyD96WDj9eCzcikNtXA6CO4g)xREoLqLWgDdMfJ6HYPnFjGOCofRJ09aJgQA6COCAYOnFXeX)1QNtXOnpAbwxVoCpzSeuBHmu8iMWjL0OGz9dDw1ubCvOeifLGczgcNkOZ5blLGzzSrt8XLSd0e5Xh7bxpOwKrBiIKijbsrjujSr3GzXOEOCAZxcWdUX)1QNtjYJpM6Whmuar5CkwZN5hjsX)1QNtjYJpM6Whmuar5CkwZN5h34)A1ZPeQe2OBWSyupuoT5lbeLZPynFMFK70KrB(IjI)RvpNIrBE0cSUED4EYyjO2cjgoQXULWa0y8ohYqXlJ2qe7yHYdYAMhFCvOeifLGczgcNkOZ5blLGzzSrt8XLSd0e5Xh7bxpOwKrBiIKijbsrjujSr3GzXOEOCAZxcWdsKI)RvpNsOW0U6zP6kmMHfquoNI1uqurUttgT5lMi(Vw9CkgT5rlyomSRWufYqX72d0ebxpOwKrBiIon39U(sNdlL0OkeF5FGmZ36nFHyQ1H9TEOCQ9vcVsIZd91UsJqMVCEOD57biKbovGVtX)dszu40C376BgT5lMi(Vw9CkgT5rlwgHd1eNu3pYOfYqXlJ2qe7yHYdYAMhFCVvcKIsOsyJUbZIr9q50MVeGhCJ)RvpNsOsyJUbZIr9q50MVequoNI18PKij9mgxQj4Y6quoNI1uqu5040C3767jFIyLL5lDqA0JniZPjJ28fteFIyLLX4X4Kq5Pc6YdZczO4rmHtkPrbZ6h6SQPc4cbRj2pEoiuOqQjowZNVrUKf)xREoLip(yQdFWqbeLZPyKiDRLASmrcLd3FQUDHDvkxOIB8FT65ucvcB0nywmQhkN28LaIY5umYjrs6zmUutWL1HOCofRPZNDAURVTO5R9(cYqFtkdH(MhF03H57x(Es603K5R9(EarIyz((erympoMkW3B4nZxoxJg9LHMnvGVGh(Es6KqMttgT5lMi(eXklJrBE0IXjHYtf0LhMfYqXl(Vw9CkrE8Xuh(GHcikNtX4swgTHi2XcLhK1mp(4MrBiIDSq5bznX7uUqWAI9JNdcfkKAIJ18z(rBYYOneXowO8Gm64nsoxIjCsjnksLI1HOCofjsz0gIyhluEqwZNYfcwtSF8CqOqHutCSMVd)i3PjJ28fteFIyLLXOnpALsV8uPnF11JSuidfpIjCsjnkyw)qNvnva3BzpOwAkLqJPQlfUJ0nLp0ixYI)RvpNsKhFm1HpyOaIY5umsKU1snwMiHYH7pv3UWUkLluXn(Vw9CkHkHn6gmlg1dLtB(sar5Ckg5CHGfkSrg723VtZsGuuciynXE8HqWdB(sar5CkgjsspJXLAcUSoeLZPynX3zNMmAZxmr8jIvwgJ28Ovk9YtL28vxpYsHmu8iMWjL0OGz9dDw1ubCzpOwAkLqJPQlfUJ0nLp0ixYuVjaRRxhUlPNGlRREtar5CkwZNptI0TwQXYeG11Rd3L0tWLXn(Vw9CkHkHn6gmlg1dLtB(sar5Ckg5onz0MVyI4teRSmgT5rRu6LNkT5RUEKLczO4rmHtkPrbZ6h6SQPc4YEqT0ukrdK4uS()NyupvaxYuOeifLGczgcNkOZ5blLGzzSrZ8Ud3BHGfs9WauKsV8uPnFX6uqSoXHjrccwi1ddqrk9YtL28fRtbX6ehMB8FT65uI84JPo8bdfquoNIrUttgT5lMi(eXklJrBE0kLE5PsB(QRhzPqgkEet4KsAuKkfRdr5CkUqWcf2iJD773PzjqkkbeSMyp(qi4HnFjGOCofZPjJ28fteFIyLLXOnpAXUYydn2TlSdwCEODfoKHIhXeoPKgfmRFOZQMkGlzX)1QNtjYJpM6Whmuar5CkwZN5hjs3APgltKq5W9NQBxyxLYfQ4g)xREoLqLWgDdMfJ6HYPnFjGOCofJCsKKEgJl1eCzDikNtXA68Ponz0MVyI4teRSmgT5rl2vgBOXUDHDWIZdTRWHmu8iMWjL0OivkwhIY5uCjtHPD1Zs1vymdlSj2yQasKG5O6irSmrQumbeLZPynX78Di3PjJ28fteFIyLLXOnpArPr2veMuwidfp2dQLMsjoazgOg7ie8WMVirI9GAPPucIVoTrJD2RjILX9wjqkkbXxN2OXo71eXY6xGYz9JsaEeYugcHGhwFKLr1KgY7CitziecEy9a9lLAENdzkdHqWdRpu8ypOwAkLG4RtB0yN9AIyzonon39U(2ovGg99(egGMttgT5lMialeorEkmTRE8hDidfVBjMWjL0O44F9ubDiynX(XZbHCjtcKIsWavkS6Q)LfqmJgjsqWAI9JNdcfkKAIJ1eVZHI2KbblK6HbOaMYhzzDdMfJcHyfr6yOOTct7Q3OMGltablK6HbO4kmZq4K0Xqro5KiDGMiiHbFynkYOnerUqWcBIxOirIAcUSoeLZPynDMFCVvHsGuuckKziCQGoNhSucWdNMmAZxmrawiCI0MhTYkCxvQqgkEKzPgltOqQrJcSsjnQirk(eXkltutWL1PsKejiyHupmafhxycF5Vqg5CjJSBjMWjL0O44F9ubDiyHmsKIprSYYe1eCzDQe5APgltOqQrJCJFPahtWzSleovqpa(GLICsKKEgJl1eCzDikNtXA6uYDAYOnFXebyHWjsBE0IZdwQo7alfcdzO4rmHtkPrHcu(OZ5blfJRcLaPOeuiZq4ubDopyPemlJnAM3zUX)1QNtjYJpM6Whmuar5CkwhP7bgnu185t5)KbblK6HbOqHPspiZ6XF00XZ8JCU3smHtkPrXX)6Pc6qWczonz0MVyIaSq4ePnpAX5blvNDGLcHHmu8uOeifLGczgcNkOZ5blLGzzSrZHI7Tet4KsAuC8VEQGoeSqgjskucKIsqHmdHtf058GLsaEWLAcUSoeLZPynrMcLaPOeuiZq4ubDopyPemlJnOJbrf5onz0MVyIaSq4ePnpAPW0U6XF0Hmu8GG1e7hphekui1ehRjE8XpAtgeSqQhgGcykFKL1nywmkeIvePJ3H2kmTREJAcUmbeSqQhgGIRWmdHtshVd5CVLycNusJIJ)1tf0HG1e7hphe60KrB(IjcWcHtK28OffYmeovqNzWPbgYqXtHsGuuckKziCQGoNhSucMLXgnDhU3smHtkPrXX)6Pc6qWczonz0MVyIaSq4ePnpAPW0U6XF0Hmu8ULycNusJIJ)1tf0HG1e7hphe60KrB(IjcWcHtK28OfNhSuD2bwkegYqXtHsGuuckKziCQGoNhSucMLXgnZ7mxiyHnXh3BjMWjL0O44F9ubDiyHmUX)1QNtjYJpM6Whmuar5CkwhP7bgnu18Ponon39U(EcHfcNOV0H)M47ndopCSWonz0MVyIaSq4e75J84KJfcdJ8I)RvpNsWEqDhI5bcfquoNIfYqXZsnwMG9G6oeZdeY1syaAcBKXU99JO1d1PnDkxQj4Y6quoNI18PCJ)RvpNsWEqDhI5bcfquoNI1ezbrfDKFcc2PKZnJ2qe7yHYdYAIxOCAYOnFXebyHWj2ZhPnpAPW0U6XF0Hmu8i7wIjCsjnko(xpvqhcwtSF8CqijssGuucgOsHvx9VSaIz0iNlzsGuucvcB0nywmQhkN28La8GleSqQhgGcfMk9GmRh)rZnJ2qe7yHYdYAIxOirkJ2qe7yHYdY4Xh5onz0MVyIaSq4e75J0MhTWJrHYtmKHINeifLGbQuy1v)llGygnsKULycNusJIJ)1tf0HG1e7hphe60CxFVbu(AjmanFJHJ6Pc8Dy(QgwkPrvi(Y4mw8YxPm2Wx791UqFztfOr(VLWa08naleorF1dZ8DkMHPs40KrB(IjcWcHtSNpsBE0ccw9mAZxD9WSqQug5fGfcNyimdorJ35qgkEXWrn2XcLhKX7SttgT5lMialeoXE(iT5rlopyP6SdSuimKy4Og7wcdqJX7CidfpYI)RvpNsKhFm1HpyOaIY5uSMpLRcLaPOeuiZq4ubDopyPeGhKiPqjqkkbfYmeovqNZdwkbZYyJMdf5CjJAcUSoeLZPynf)xREoLqHPD1Zs1vymdlGOCofJ2N5hjsutWL1HOCofR54)A1ZPe5XhtD4dgkGOCofJCNMmAZxmrawiCI98rAZJwuiZq4ubDMbNgyiXWrn2TegGgJ35qgkEkucKIsqHmdHtf058GLsWSm2OjEHIB8FT65uI84JPo8bdfquoNI10PKiPqjqkkbfYmeovqNZdwkbZYyJMo70KrB(IjcWcHtSNpsBE0IczgcNkOZm40adjgoQXULWa0y8ohYqXl(Vw9CkrE8Xuh(GHcikNtXA(uUkucKIsqHmdHtf058GLsWSm2OPZon3137VgMVdZxKIcJ2qe1H9LA0Ae6lNRjE5lBKz(sN3SwFle0GPoeFLanFzxpOw57bejIL5B6llIvcN3xoxie91UqFtL6lFVsMV1Bxtf4R9(cX4llJLs40KrB(IjcWcHtSNpsBE0IczgcNkOZm40adzO4LrBiID1BckKziCQGoNhSunZlgoQXowO8GmUkucKIsqHmdHtf058GLsWSm2OP74040CxFVHzCsnZPjJ28ftaZ4KAgVegZc72dHyzHmu8GG1e7hphekui1ehR5B8uUKDGMiiHbFynkYOnersKU1snwMGbkl)vpiHbFynkWkL0OICUqWcfkKAIJ1mVtDAYOnFXeWmoPMrBE0ss)VQtbcdhYqXJycNusJc5K)9WE8FT65uSEgTHisI0bAIGeg8H1OiJ2qe5EGMiiHbFynkGOCofRjEsGuucj9)QofimSqbctB(IejPNX4snbxwhIY5uSM4jbsrjK0)R6uGWWcfimT5lNMmAZxmbmJtQz0MhTKqidHnMkiKHIhXeoPKgfYj)7H94)A1ZPy9mAdrKePd0ebjm4dRrrgTHiY9anrqcd(WAuar5Ckwt8KaPOesiKHWgtfiuGW0MVirs6zmUutWL1HOCofRjEsGuucjeYqyJPcekqyAZxonz0MVycygNuZOnpAPNGlJ15FGQazSSqgkEsGuucW661H7mdIvGDjapCAURV0HkImdMAFpzQ1(gZYxdobbi03747XByztQ9vcKIIfIVygV8vNmBQaFpFQVmm(LIj89M2g9CIrLVxju5B8vOYxBKrFtMVPVgCccqOV27Bdep8DmFHyQsjnkCAYOnFXeWmoPMrBE0kRiYmyQ7XuRdzO4rmHtkPrHCY)Eyp(Vw9CkwpJ2qejr6anrqcd(WAuKrBiICpqteKWGpSgfquoNI1eVZNsIK0ZyCPMGlRdr5Ckwt8oFQttgT5lMaMXj1mAZJwjmMf2pa1mmKHIxgTHi2XcLhK1mp(irImiyHcfsnXXAM3PCHG1e7hphekui1ehRzE3i)i3PjJ28ftaZ4KAgT5rlQbIs6)vHmu8iMWjL0Oqo5FpSh)xREofRNrBiIKiDGMiiHbFynkYOnerUhOjcsyWhwJcikNtXAINeifLGAGOK(FLqbctB(IejPNX4snbxwhIY5uSM4jbsrjOgikP)xjuGW0MVCAYOnFXeWmoPMrBE0skd6pv3GtSblKHIxgTHi2XcLhKX7mxYKaPOeG11Rd3zgeRa7saEqIK0ZyCPMGlRdr5CkwtNsUtJtZDVRV3dNQbAmNMmAZxmHbNQbAmEGmSpgkhsLYiVPyriOLsASZFGzzGYDfsCIyidfpYI)RvpNsawxVoCxspbxMaIY5uSM5JFKif)xREoLqLWgDdMfJ6HYPnFjGOCofRJ09aJgQAMp(roxYYOneXowO8GSM5XhjshOjsOC4EW1dQfz0gIijshOjYJp2dUEqTiJ2qe5sMLASmbyD96W9KXsqTrIKct7Q3OMGltOgwkPXE(MICsKoqteKWGpSgfz0gIi5Kij9mgxQj4Y6quoNI1eFNjrsHPD1ButWLjudlL0yF4pvhPlgbnKh)4AjmanHnYy3((r068XVMo1PjJ28ftyWPAGgJ28Ofid7JHYHuPmYZUWo1azwNnbJoKHIhXeoPKgfYj)7H94)A1ZPy9mAdrKlz2iJnhk(rI0Ti)bohhOsmflcbTusJD(dmlduURqItej3PjJ28ftyWPAGgJ28Ofid7JHYHuPmY7jIqoxOwEQG(XZbH9immZsDidfpIjCsjnkKt(3d7X)1QNtX6z0gIixYSrgBou8JePBr(dCooqLykwecAPKg78hywgOCxHeNiY9wK)aNJdujSlStnqM1ztWOj3P5U(E)f6RbNQbA(YzSlFTl03Rj4czMViZg50qLVetnigIVCgT2xj0xqgQ8LAGmZ3Su(EKdev(YzSlFPdhFm1HpyOVKnu(kbsr57W898P(YW4xkMVp0xnYyK77d9L(6j4YOfDEVVKnu(gaX0qOV2vw(E(uFzy8lfJCNMmAZxmHbNQbAmAZJwgCQgODoKHI3Tet4KsAuWoW4qnOQBWPAGgxYiZGt1anXzHeifvxbctB(QjENpLB8FT65uI84JPo8bdfquoNI1mF8Jejdovd0eNfsGuuDfimT5RMpFkxYI)RvpNsawxVoCxspbxMaIY5uSM5JFKif)xREoLqLWgDdMfJ6HYPnFjGOCofRJ09aJgQAMp(rojsz0gIyhluEqwZ84JReifLqLWgDdMfJ6HYPnFjapiNlz3AWPAGMGpXvY6X)1QNtrIKbNQbAc(eX)1QNtjGOCofJejIjCsjnkm4unqRFaNhowyENjNCsKKEgJRbNQbAIZcjqkQUceM28vZ8OMGlRdr5CkMttgT5lMWGt1angT5rldovd04lKHI3Tet4KsAuWoW4qnOQBWPAGgxYiZGt1anbFcjqkQUceM28vt8oFk34)A1ZPe5XhtD4dgkGOCofRz(4hjsgCQgOj4tibsr1vGW0MVA(8PCjl(Vw9CkbyD96WDj9eCzcikNtXAMp(rIu8FT65ucvcB0nywmQhkN28LaIY5uSos3dmAOQz(4h5KiLrBiIDSq5bznZJpUsGuucvcB0nywmQhkN28La8GCUKDRbNQbAIZIRK1J)RvpNIejdovd0eNfX)1QNtjGOCofJejIjCsjnkm4unqRFaNhowyE8ro5Kij9mgxdovd0e8jKaPO6kqyAZxnZJAcUSoeLZPyon313BaLVFPd77xOVF5lid91Gt1anFpGpXrHmFtFLaPOcXxqg6RDH((2fc99lFJ)RvpNs47ja67q5BHJDHqFn4unqZ3d4tCuiZ30xjqkQq8fKH(k92LVF5B8FT65ucNMmAZxmHbNQbAmAZJwGmSpgkhct)gpdovd0ohYqX7wIjCsjnkyhyCOgu1n4unqJ7TgCQgOjolUswhKHDjqkkUKzWPAGMGpr8FT65ucikNtXir6wdovd0e8jUswhKHDjqkkYDAYOnFXegCQgOXOnpAbYW(yOCim9B8m4unqJVqgkE3smHtkPrb7aJd1GQUbNQbACV1Gt1anbFIRK1bzyxcKIIlzgCQgOjolI)RvpNsar5Ckgjs3AWPAGM4S4kzDqg2LaPOihWamaaa]] )

end
