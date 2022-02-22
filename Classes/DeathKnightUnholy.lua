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


    spec:RegisterPack( "Unholy", 20220221, [[devD)dqivcpcLkDjvIkBcL8jPIgfkQtHISksLsVsfPzbq3caWUq1VKkzyOu1XurTmsfpJujtda6AQi2gaOVrQumovIIZjvQuRtLiVdLkGMhr4EQu7tQWbbq1cLkLhIsHjIsrxuQuvBeLkOpcGsgPuPs6KaaTsvsVeLkqZKuP6MOubyNer(PkrvdvQuLLcGINIitfLsxfaLARsLkXxrPcnwaK9sWFLYGv1Hfwmr9yknzsUm0Mr4ZKYOvHtlz1sLkEnrA2uCBcTBr)wXWLQookv0Yb9CKMovxhOTJO(okmEIOopPQ1RsuA(aA)kTWzb2kqsfokijDyVo6WED05m)C3TUUmNbqbsU(EuGuFyLgAOaPmerbsaSZJXOxGuFO3mHsGTcKOdi0IcKoCVNEPU6sR8dqzUDe7IwIGMWRjTWGW7IwI2UeijdwghamfKfiPchfKKoSxhDyVo6CMFU7wxxMZ6sGeThTcssNt0rG0rPuykilqsHuRaj2ed)yF2bZs7W3hGDEmg97v2HOmemG63xNZaUVoSxhD2R7v24isnKEP9kaW(aCv3bK6Iy6099zF2mzZUytKOmyxSjg(bDF2ee33N9N0OFF7aM((Ea1qNUpJJz)aI7JsUhToQ23N9nfzCFZKA7J5aQDSVp7lgUJW9zogSrrhSFF29mt89kaW(SzrdzdQ2NuyHfrzRWSF3lS((YOnaP4(kmu7RDmGg6(IHuCFIbUpnu7ZMSds57vaG9bytRuBF2Xbmv7tQhtfc3pKlt5fs3xCG4(eguYLSr)(mh((a4P7t9WkLUFLuhd1(dX(NCktSdCF2S7rA)ebDyy2ps1(IH(97Hizm99PJiUFoaaq0UpTCWWRjP89kaW(aSPvQTp7qK6iSsT9j5WskUFL7dWV8D)9lI91pG7FeKX9ZXpQuBF0qX99zF1SFKQ9zmzN((dzeAJ(9zmGPIUFr3Nn7EK2prqhgg(EfayF24isnuTVyK63VtIs7WBqumQK25(2jvLxtgg6((SF03B0VFL7lpu6(eL2Ht3FsJ(9z2Gu6(SbBUpJG64(tUVdd6bt89kaW(aCLcv7h54hiC)lpOldXq6(y6q977Z(u03hSFFQdNudH7397lfkwwkFVcaSpadAcjVpj2UpzkFFa(LV7VVz0k7(0kT4(LVpenfs3FY9TtseYGMWr1(WOunKmMoLVxba2NTxE28YFP93NDyy9bUpjhIPMFSFpCS09R0N9DyLsrFFZOvw(EDVgwVMKY7HODeLd)07U6hVMCVgwVMKY7HODeLd)07UGrrXMcd1EnSEnjL3dr7ikh(P3Dryq6Hfge(EnSEnjL3dr7ikh(P3Dfqr9THO5hytHHcWEiAhr5WBEjI36cWI4(cpmy6CkOO4KnTaQn6n4ET7tomGHJ09J9DyLsrNUVDgJAyKaUVQixkuTVS(9bWt47Z2JIUpJGUV9yOyUFq3hmpgJ(9zmqP09NCFa8K9PODs1(YGqQVVvV1Gua3xg03)iO77ZSVyK633QG7JeeO1P77Z(AfzC)yF7mg1Wi5sMRaHHxtUVQix0bUFLuhdfFFaqI9lVt6(KddiU)rq3pN9HOyuPcH7drheM7FgW9rdf3hIoim3N98t471W61KuEpeTJOC4NE3f5awHSbbmdr82Hvkf925gvFAbC6VPOxeasomG49zajhgqSHgkEZE(jaANuvEn5TdRuk68Z8JG2aPytgKGGfZoSsPOZpZTZyudJKRaHHxtE5UCa4j3SNP9Ay9AskVhI2ruo8tV7ICaRq2GaMHiE7WkLIEtNgvFAbC6VPOxeasomG49zajhgqSHgkEZE(jaANuvEn5TdRuk6CD4hbTbsXMmibblMDyLsrNRd3oJrnmsUcegEn5L7YbGNCZEM2RDFQxIHJ09J9DyLsrNUp5WaI7lRFF7i2hWk123pW9TZyudJC)HyF)a33HvkfDa3xvKlfQ2xw)((bUVcegEn5(dX((bUVmibX(LVFpCixkKY3V7Aq3p2N6qm18J9fhvruiCFF2xRiJ7h7FuAhiC)EynWY1VVp7tDiMA(X(oSsPOtbC)GUpd0y2pO7h7loQIOq4(edC)Iy)yFhwPu03Nrzm7pW9zugZ(547t1N29zu(X(2zmQHrs571W61KuEpeTJOC4NE3f5awHSbbmdr82Hvkf9wpSgy56bC6VPOxeasomG4ToasomGydnu8(mG2jvLxtEFHdRuk68Z8JG2aPytgKGGLdRuk6CD4hbTbsXMmibbqGoSsPOZ1HFe0gifBYGeeSyMzhwPu056WTZyudJKRaHHxtE5CyLsrNRdxgKGOPaHHxtYKUL5Z8to1HvkfDUo8JG2Kbjiys3Ym5awHSb5oSsPO30Pr1NwMyQdMz2HvkfD(zUDgJAyKCfim8AYlNdRuk68ZCzqcIMcegEnjt6wMpZp5uhwPu05N5hbTjdsqWKULzYbSczdYDyLsrVDUr1NwMyAV29jhgWWr6(wqietFFk6G97tmW99dCF2jyKE563Fi2hG3p2WOVNI7ZgSjaZ(ibbAD6EnSEnjL3dr7ikh(P3DroGviBqaZqeVjanMMvbbKCyaXBpmy68akQVnen)aBQqmrfl7KkWY52jjp2WRjBdrZpWMcdfhgP0oU7U3R71UVKrlOJQ9rYiu)(EjI77h4(H1h4(fD)GCuMq2G89Ay9As6TyLQgbeXllUx7EqKmM((0E0wefQ23HvkfD6(YyLA7dsr1(mk)y)a0hXWl7(Mkr6EnSEnj907UihWkKniGziI30E0wefQAoSsPOdi5WaI3mJStWQVhv8kPwiOhYgSXobJ0bfBkKCzrw2zmQHrYRKAHGEiBWg7emshuSPqYLf5qmu6zAV2DjGviBq6EnSEnj907UihWkKniGziI39ZyQuRbbZY26hgieqYHbeVTZyudJKtbffNSPfqTrVb5qumQKkXjS8WGPZPGIIt20cO2O3GSy2ddMohmpgJ(MSP0oCw2zmQHrYbZJXOVjBkTdNdrXOsQeN1fl7mg1Wi5QakT5WiPedum8AsoefJkPnuY9O1rLeN1fqGx4HbtNdMhJrFt2uAhot71W61K0tV7ICaRq2GaMHiE3pJPsTgemrkGKddiE7HbtNthqtdIrpczbbtucDy5budDUxIyZNwV1B66ejoHfrPD4nikgvs74K9Ay9As6P3DroGviBqaZqeVPER3ezwPgGKddiEhwViJnmrXcP3NzX8fWOunKmMopukkhLCrDkqGWOunKmMopukkVYooFct71W61K0tV7ICaRq2GaMHiEhkfTbrXOsajhgq8oSErgByIIfs74whwmFbmkvdjJPZdLIYrjxuNceimkvdjJPZdLIYrjxuNYIzyuQgsgtNhkfLdrXOsAhNaeirPD4nikgvs74m7zIP9Ay9As6P3DroGviBqaZqeVfJUZaB2zmQHrsBH1lYiGKddiEZShgmDofuuCYMwa1g9gK1f9OZ1cO2O3G8W6fzKLDgJAyKCkOO4KnTaQn6nihIIrLuGaVWddMoNckkoztlGAJEdYelMLbji4G5Xy03cknanohShiqpmy68akQVnen)aBQqmrfRE05r)yBAhdOHhwViJabkdsqWvbuAZHrsjgOy41KCWEGadRxKXgMOyH0oU1HLcd)OfPQPqBON7LvALAmTxdRxtsp9UlYbSczdcygI4TcuSVXyatffqYHbeVTdzmJ05zPD4nIazPWWpArQAk0g65EzLwPglzqccUcd)G2uGiN6HvQeaiqGYGeeCXachgOQPHIuFsSH5rKwuetNd2deOmibb3pGLX0OikfHCWEGaLbji4eqmVSfQAItsD4qlxphShiqzqccUbdvtwFdLCi2BqoypqGYGeeC7rm0MCKihShiq7mg1Wi5G5Xy03cknanohIIrLujozVYoGOspQSsT97UuqqdM((DptObI7x09J97H1alx)EnSEnj907UgqxgIHualIB14CYfe0GP36nHgiYHibePhHSbzDHhgmDoyEmg9nztPD4SUagLQHKX05Hsr5OKlQt3RH1RjPNE31a6YqmKcOvV1GnpGAOtVpdyrCRgNtUGGgm9wVj0aroejGi9iKniRW6fzSHjkwiTJBDyX8fEyW05G5Xy03KnL2HdeOhgmDoyEmg9nztPD4Sy2oJrnmsoyEmg9nztPD4Cikgvs7G5ZNC5cRxKXgMOyH0tvJZjxqqdMER3eAGihIIrLuMacmSErgByIIfs74wxmX0EfaKyF)aH4(be3htuSq6(IfLwP2(Dx6EaUF03B0VF57ZSmOVFo7loqCF)iY9N0I73JW9bG7tr7Kkkt89Ay9As6P3DnGUmedPaAQeBw1naeWI4oSErgBQX5KliObtV1BcnquIW6fzSHjkwiLvy9Im2WeflK2XToSy(cpmy6CW8ym6BYMs7Wbc0oJrnmsoyEmg9nztPD4CikgvszjdsqWbZJXOVjBkTdVjdsqWvdJKP9Ay9As6P3DnGUmedPawe3qWejgOgYPG9iK6WOswmRgNtahQ3iqYiKdrcispczdceOACUSzgvR3eAGihIeqKEeYgKP9kadsar6bs3NnXWpO7ZMGyN09Lbji2V7as99LrIbI7RWWpO7RaX9Xur3RH1RjPNE3fJbmvnApMkecyrCBhYygPZZs7WBebYsHHF0Iu1uOn0ZdRxKXgefJkPsWSMvPBpZpHjwkm8JwKQMcTHEUxwPvQTxdRxtsp9Ulgr5asr7TDgJAyKC6aAAqm6rihIIrLualIBpmy6C6aAAqm6rilpGAOZ9seB(06TEtxNiXjS8aQHo3lrS5ttvyhNWYoJrnmsoDannig9iKdrXOsQemRzv6w2Z1nNWeRW6fzSHjkwi9(8ELDmkFFIbUpBIHF0jDF2ee7InrIYG7xe7lPs7W3NDyG77Z(AOVp1HyQ5h7ldsqSVCyLUFqJ(9Ay9As6P3DXikhqkAVTZyudJKRWWpOnfiYHOyujfWI42oKXmsNNL2H3icKLDgJAyKCfg(bTParoefJkPsOzvScRxKXgMOyH07Z71W61K0tV7IruoGu0EBNXOggjxHeLb5qumQKcyrCBhYygPZZs7WBebYYoJrnmsUcjkdYHOyujvcnRIvy9Im2WeflKEFEVcWTEn5(6ErD6(rQ2)Y3JjcP7Z8LVhtes7IeYobX0I09btkyF)aDuTFL7hk1KCM2RH1RjPNE3LnmMwy9AYMPOoGziI3oSsPOt3RH1RjPNE3LnmMwy9AYMPOoGziI32HmMr609Ay9As6P3DzdJPfwVMSzkQdygI4nmSvyO71W61K0tV7IIStqmTiGfXDy9Im2WeflKEFM1fkm8JM0S0oCUQOHSbBX4kwEyW05uqrXjBAbuB0BqaZqeV1cOwB6XeHxAaDzigsVebsDewPwJ6WskEjcK6iSsTg1HLu8suqrXjBAbuB0BWlfqr9THO5hytHH6skm8JMDkdGfXTmibbNcQuy2uZiYb7VKcd)OzNYCjfg(rZoL5su7ac1Wg1HLueWI4wHYGeeCcK6iSsTgJbmvCQhwPDaGxIAhqOg2OoSKIawe3kugKGGtGuhHvQ1ymGPIt9WkTda8sei1ryLAnQdlP4EnSEnj907UOi7eetlcyrChwViJnmrXcP3NzDHcd)OjnlTdNRkAiBWwmUI1fEyW05uqrXjBAbuB0BqaZqeVNEmr4LiqQJWk1AuhwsXlrGuhHvQ1OoSKIxQF8AYlbMhJrFt2uAh(LubuAZHrsjgOy41Kxk6hBy03tX9Ay9As6P3DzdJPfwVMSzkQdygI4TDgJAyK09Ay9As6P3DbbZwy9AYMPOoGziI3XGnk6G9awe3KdyfYgKhkfTbrXOswmBNXOggjxHHF0Iu1uOn0ZHOyujvIZSN1fEyW05kKOmiqG2zmQHrYvirzqoefJkPsCM9S8WGPZvirzqGaTdzmJ05zPD4nIazzNXOggjxHHFqBkqKdrXOsQeNzptSUqHHF0Iu1uOn0Z9YkTsT9Ay9As6P3DbbZwy9AYMPOoGziI3XGnzqi1bK6WY63NbSiUdRxKXgMOyH0oU1HLcd)OfPQPqBON7LvALA71W61K0tV7ccMTW61KntrDaZqeV1WeHLTfdcyrChwViJnmrXcPDCRdlMVqHHF0Iu1uOn0Z9YkTsnwmBNXOggjxHHF0Iu1uOn0ZHOyujTJZSN1fEyW05kKOmiqG2zmQHrYvirzqoefJkPDCM9S8WGPZvirzqGaTdzmJ05zPD4nIazzNXOggjxHHFqBkqKdrXOsAhNzptabEb5awHSb5HsrBqumQKP9Ay9As6P3DzdJPfwVMSzkQdygI4TgMiSSasDyz97Zawe3H1lYydtuSq69zGaVGCaRq2G8qPOnikgvUx3Ra8P7VF3aHuFVgwVMKYJbBYGqQFBnbJk1A0JqnmOawe3H1lYydtuSqQe3NSxdRxts5XGnzqi1p9UlRjyuPwJEeQHbfWI4oSErgByIIfsVbGSuy4hnPzPD4CcgdyQqvZdOg60oU11EnSEnjLhd2KbHu)07UymGPQr7XuHqalIBpmy6Czqi1RuRrhiszXScd)OjnlTdNtWyatfQAEa1qNEhwViJnmrXcPabQWWpAsZs7W5emgWuHQMhqn0PDCRlMac0ddMoxges9k1A0bIuwEyW05wtWOsTg9iuddklfg(rtAwAhoNGXaMku18aQHoTJ7Z71W61KuEmytges9tV7sHHF0StzaSiUzwgKGGtbvkmBQze5qmSoqGxqoGviBqE)mMk1AqWSST(HbczIfZYGeeCvaL2CyKuIbkgEnjhSNfemrIbQHCfgktHuVzNYWkSErgByIIfsL4wxabgwViJnmrXcP36W0EnSEnjLhd2KbHu)07UW(sHILfWI4gcMLT1pmqixHeLTCjy(m7pvHHF0KML2HZjymGPcvnpGAOt1T6Ijwkm8JM0S0oCobJbmvOQ5budDQeaqwxqoGviBqE)mMk1AqWSST(HbcbcugKGGtzeqXk1AIf15G971W61KuEmytges9tV7c7lfkwwalIBiyw2w)WaHCfsu2YLqNtyPWWpAsZs7W5emgWuHQMhqn0PDCcRlihWkKniVFgtLAniyw2w)WaH71W61KuEmytges9tV7c7lfkwwalI7luy4hnPzPD4CcgdyQqvZdOg6uwxqoGviBqE)mMk1AqWSST(HbcbcKO0o8gefJkPsCcqGWOunKmMopukkhLCrDklyuQgsgtNhkfLdrXOsQeNSxdRxts5XGnzqi1p9UlgdyQA0EmviCVgwVMKYJbBYGqQF6DxyFPqXYcyrCFb5awHSb59ZyQuRbbZY26hgiCVUxb4t3FFsOd2VxdRxts5XGnk6G93rQVPsfGfXTcd)OjnlTdNtWyatfQAEa1qN2XTvV1GnmrXcPabQWWpAsZs7W5emgWuHQMhqn0PDCFcqGx4HbtNldcPELAn6arkqGWOunKmMopukkhLCrDklyuQgsgtNhkfLdrXOsQe3NpdeirPD4nikgvsL4(859Ay9AskpgSrrhS)07Uuy4hn7ugalI7lihWkKniVFgtLAniyw2w)WaHSywgKGGRcO0MdJKsmqXWRj5G9SGGjsmqnKRWqzkK6n7ugwH1lYydtuSqQe36ciWW6fzSHjkwi9whM2RH1RjP8yWgfDW(tV7c7lfkwwalI7lihWkKniVFgtLAniyw2w)WaH71W61KuEmyJIoy)P3DrGuhHvQ1OoSKIaA1BnyZdOg607Zawe3kugKGGtGuhHvQ1ymGPIt9WkvIBDXYoJrnmsE0p2WOVNICikgvsLqx71W61KuEmyJIoy)P3DrGuhHvQ1OoSKIaA1BnyZdOg607Zawe3kugKGGtGuhHvQ1ymGPIt9WkvIZ71W61KuEmyJIoy)P3DrGuhHvQ1OoSKIaA1BnyZdOg607Zawe3qWe5EjInFAaOemBNXOggjxHHF0Iu1uOn0ZHOyujL1fEyW05kKOmiqG2zmQHrYvirzqoefJkPS8WGPZvirzqGaTdzmJ05zPD4nIazzNXOggjxHHFqBkqKdrXOskt7v2Xdm33dOg67tze909diUVQOHSbvaUVFu09zugZ(g03x)aUpTht1(qWePDXyatfD)kPogQ9hI9zeLxP2(edCF2mzZUytKOmyxSjg(rN09ztqKVxdRxts5XGnk6G9NE3fJbmvnApMkecyrCZ8fu09k1OCRERbbcuHHF0KML2HZjymGPcvnpGAOt742Q3AWgMOyHuMyPqzqccobsDewPwJXaMko1dR0o0fliyICVeXMpnDjHDgJAyK8i13uPIdrXOs6EDV29gVMCVgwVMKYTZyudJKE3pEnjGfXn5awHSb5Ir3zGn7mg1WiPTW6fzeiWE05AbuB0BqEy9ImYQhDUwa1g9gKdrXOsQe36aabcKO0o8gefJkPsOdaCVYgZyudJKUxdRxts52zmQHrsp9URakQVnen)aBkmuawe32zmQHrYbZJXOVjBkTdNdrXOsQe6gw2zmQHrYvbuAZHrsjgOy41KCikgvsBOK7rRJkj0nS8WGPZbZJXOVjBkTdNfZu0BYtcs5EHqDUmnaS3YYdOg6CVeXMpTER301jsaGabEbf9M8KGuUxiuNltda7TabsuAhEdIIrL0o0H9SNjwmBNXOggjpKhXkdVMSzkrzoefJkPsC(YWIziyIedud5H8iwz41K0gbeZlREGaPdOrUsfxksUsABMllAQuJjGaVacMiXa1qEipIvgEnjTraX8YQN1f0b0ixPIlfjxjTnZLfnvQXelMTZyudJKh9Jnm67PihIIrL0gk5E06OscDdlYbSczdYjanMMvbbc8cYbSczdYjanMMvbbcKCaRq2GCLTbDMac8cpmy6CW8ym6BYMs7WbcuEOuweL2H3GOyujvcDDYEnSEnjLBNXOggj907UOdOPbXOhHaA1BnyZdOg607Zawe3Ea1qN7Li28P1B9MUorItyXShqn05EjInFAQc74ewH1lYydtuSqQe36ciqk6n5jbPCVqOoxMga2BzjdsqWvbuAZHrsjgOy41KCWEwH1lYydtuSqQe3NWI5luy4hTivnfAd9CVSsRudiq7qgZiDEwAhEJiqMyAV2DDmk6(DZuAh((edCFW(99z)t2NI2jv099zFQ(0UpJYp2hG3p2WOVNIaU)L3pqiJIIaUpif3Nr5h7ZMbu6(SfgjLyGIHxtY3RH1RjPC7mg1WiPNE3fyEmg9nztPD4awe3KdyfYgKt9wVjYSsnwmBNXOggjp6hBy03troefJkPnuY9O1rLeNaeODgJAyK8OFSHrFpf5qumQK2qj3JwhvDCM9mXIz7mg1Wi5QakT5WiPedum8AsoefJkPsOzvabkdsqWvbuAZHrsjgOy41KCWEM2RH1RjPC7mg1WiPNE3fyEmg9nztPD4awe3KdyfYgKhkfTbrXOsGaLhkLfrPD4nikgvsLqNZ71W61KuUDgJAyK0tV7IckkoztlGAJEdcOPsSzv36caYE2dyrCdbZY26hgiKRqIYwUeNbqw2zmQHrYbZJXOVjBkTdNdrXOsQeN1fl7mg1Wi5QakT5WiPedum8AsoefJkPsCwx71W61KuUDgJAyK0tV7sfqPnhgjLyGIHxtcyrCtoGviBqo1B9MiZk1yXSACoyEmg9nztPD4n14Cikgvsbc8cpmy6CW8ym6BYMs7WzAVgwVMKYTZyudJKE6DxQakT5WiPedum8AsalIBYbSczdYdLI2GOyujqGYdLYIO0o8gefJkPsOZ59Ay9Ask3oJrnms6P3Df9Jnm67PiGfXDy9Im2WeflKEFMLcLbji4ei1ryLAngdyQ4upSs74gazX8fKdyfYgKtaAmnRccei5awHSb5eGgtZQGSy2oJrnmsoyEmg9nztPD4Cikgvs74m7bc0oJrnmsUkGsBomskXafdVMKdrXOsAdLCpADu1Xz2Z6cpmy6CW8ym6BYMs7WzIP9Ay9Ask3oJrnms6P3Df9Jnm67PiGw9wd28aQHo9(mGfXDy9Im2WeflK2XToSuOmibbNaPocRuRXyatfN6HvAh6I1fkm8JwKQMcTHEUxwPvQTxdRxts52zmQHrsp9UlkOO4KnTaQn6niGfXnemlBRFyGqUcjkB5sCgazzNXOggjhmpgJ(MSP0oCoefJkPsCwxSSZyudJKRcO0MdJKsmqXWRj5qumQK2qj3JwhvsCwx71W61KuUDgJAyK0tV7cmpgJ(wqPbOXbSiUjhWkKniN6TEtKzLASuOmibbNaPocRuRXyatfN6HvQe6WI5E05r)yBAhdOHhwViJabkdsqWvbuAZHrsjgOy41KCWEw2zmQHrYJ(Xgg99uKdrXOsAhNzpqG2zmQHrYJ(Xgg99uKdrXOsAhNzpl7mg1Wi5QakT5WiPedum8AsoefJkPDCM9mTxdRxts52zmQHrsp9UlW8ym6BbLgGghqRERbBEa1qNEFgWI4oSErgByIIfs74whwkugKGGtGuhHvQ1ymGPIt9WkvcDyXCp68OFSnTJb0WdRxKrGaLbji4QakT5WiPedum8AsoypqG2zmQHrYvy4hTivnfAd9CikgvsLqZQyAVgwVMKYTZyudJKE6DxWOOytHHcWI4(IE05AhdOHhwViJ7v2SOHSbvaUF3bK67NJVpedJr)(5afdZ(Y4rqUg4((r4Ds3NXa9J97bHuWk12VsaaTqe571W61KuUDgJAyK0tV7Igwyru2kmT(W6awe3H1lYydtuSqAh36W6czqccUkGsBomskXafdVMKd2ZYoJrnmsUkGsBomskXafdVMKdrXOsAhNaeO8qPSikTdVbrXOsQeAw1EDVYgdzmJ03hGlxMYlKUxdRxts52HmMr60BkJakwPwtSOoGfXn5awHSb5uV1BImRuJfemlBRFyGqUcjkB5DCgaYIz7mg1Wi5r)ydJ(EkYHOyujfiWl8WGPZdOO(2q08dSPcXevSSZyudJKRcO0MdJKsmqXWRj5qumQKYeqGYdLYIO0o8gefJkPsC(8ELe677Z(GuC)GWr4(r)y3VO7p5(SbBUFq33N97Hizm99hYi0g99vQTpat3BFghLb3NIUxP2(G97ZgSzN09Ay9Ask3oKXmsNE6DxugbuSsTMyrDalIB7mg1Wi5r)ydJ(EkYHOyujLfZH1lYydtuSqAh36WkSErgByIIfsL4(ewqWSST(Hbc5kKOSL3Xz2FkZH1lYydtuSqQUfaYelYbSczdYdLI2GOyujqGH1lYydtuSqAhNWccMLT1pmqixHeLT8oaq2Z0EnSEnjLBhYygPtp9URqEeRm8AYMPeLbSiUjhWkKniN6TEtKzLASUGoGg5kvCdgQMS(gk5qS3GSy2oJrnmsE0p2WOVNICikgvsbc8cpmy68akQVnen)aBQqmrfl7mg1Wi5QakT5WiPedum8AsoefJkPmXccMi3lrS5tda7qgKGGdbZY2Sdec271KCikgvsbcuEOuweL2H3GOyujvcDoVxdRxts52HmMr60tV7kKhXkdVMSzkrzalIBYbSczdYPER3ezwPgl6aAKRuXnyOAY6BOKdXEdYIz14CW8ym6BYMs7WBQX5qumQK2X5ZabEHhgmDoyEmg9nztPD4SSZyudJKRcO0MdJKsmqXWRj5qumQKY0EnSEnjLBhYygPtp9URqEeRm8AYMPeLbSiUjhWkKniN6TEtKzLASOdOrUsfxksUsABMllAQuJLcLbji4ei1ryLAngdyQ4upSs74ga3RH1RjPC7qgZiD6P3DfYJyLHxt2mLOmGfXn5awHSb5HsrBqumQKfemrUxIyZNga2HmibbhcMLTzhieS3Rj5qumQKUxdRxts52HmMr60tV7IEewPgS5hydmzmq)qpGfXn5awHSb5uV1BImRuJfZ2zmQHrYJ(Xgg99uKdrXOsAhNzpqGx4HbtNhqr9THO5hytfIjQyzNXOggjxfqPnhgjLyGIHxtYHOyujLjGaLhkLfrPD4nikgvsL48j71W61KuUDiJzKo907UOhHvQbB(b2atgd0p0dyrCtoGviBqEOu0gefJkzXScd)OfPQPqBON7LvALAabcJs1qYy68qPOCikgvsL4(maY0EnSEnjLBhYygPtp9UlcdspSWGWbSiUPdOrUsfVhK6GgSHqWEVMCVUxjvPMb3NTbud99Ay9Askxdtew2Bfg(rZoLbWI4(cYbSczdY7NXuPwdcMLT1pmqilMLbji4uqLcZMAgroedRdeiemlBRFyGqUcjkB5sCFwxmbeyp6CTaQn6nipSErgzbbtuIBDbeirPD4nikgvsL4m7zDHcLbji4ei1ryLAngdyQ4G971W61KuUgMiSSNE3vK6BQubyrCZShgmDUcjkdYXmKnOciq7qgZiDEwAhEJiqGaHGjsmqnK3FGbCeNePmXI5lihWkKniVFgtLAniyIuGaLhkLfrPD4nikgvsL4eM2RH1RjPCnmryzp9UlgdyQA0EmvieWI4MCaRq2GCfOyFJXaMkklfkdsqWjqQJWk1AmgWuXPEyL2X9zw2zmQHrYJ(Xgg99uKdrXOsAdLCpADu1XjSUGCaRq2G8(zmvQ1GGjs3RH1RjPCnmryzp9UlgdyQA0EmvieWI4wHYGeeCcK6iSsTgJbmvCQhwPDOlwxqoGviBqE)mMk1AqWePabQqzqccobsDewPwJXaMkoyplIs7WBqumQKkbZkugKGGtGuhHvQ1ymGPIt9Wkv3QzvmTxdRxts5AyIWYE6Dxkm8JMDkdGfXnemlBRFyGqUcjkB5sCRd7zDb5awHSb59ZyQuRbbZY26hgiCVgwVMKY1WeHL907UiqQJWk1AuhwsralIBfkdsqWjqQJWk1AmgWuXPEyLkbaY6cYbSczdY7NXuPwdcMiDVgwVMKY1WeHL907Uuy4hn7ugalI7lihWkKniVFgtLAniyw2w)WaH71W61KuUgMiSSNE3fJbmvnApMkecyrCRqzqccobsDewPwJXaMko1dR0oUpZccMOe6W6cYbSczdY7NXuPwdcMiLLDgJAyK8OFSHrFpf5qumQK2qj3JwhvDCYEDVcWctew29b4t3F)UhSgy563RH1RjPCnmryzBXG3mIYbKI2B7mg1Wi50b00Gy0JqoefJkPawe3EyW050b00Gy0JqwEa1qN7Li28P1B9MUorItyruAhEdIIrL0ooHLDgJAyKC6aAAqm6rihIIrLujywZQ0TSNRBoHjwH1lYydtuSqQe36AVgwVMKY1WeHLTfdE6Dxkm8JMDkdGfXnZxqoGviBqE)mMk1AqWSST(HbcbcugKGGtbvkmBQze5qmSotSywgKGGRcO0MdJKsmqXWRj5G9SGGjsmqnKRWqzkK6n7ugwH1lYydtuSqQe36ciWW6fzSHjkwi9whM2RH1RjPCnmryzBXGNE3f2xkuSSawe3YGeeCkOsHztnJihIH1bc8cYbSczdY7NXuPwdcMLT1pmq4EfaKyFpGAOVVvV1uP2(fDFvrdzdQaCFkJYTh7lhwP77Z((bUpTsndca4bud991WeHLDFtr99RK6yO471W61KuUgMiSSTyWtV7ccMTW61KntrDaZqeV1WeHLfqQdlRFFgWI42Q3AWgMOyH07Z71W61KuUgMiSSTyWtV7IXaMQgThtfcb0Q3AWMhqn0P3NbSiUz2oJrnmsE0p2WOVNICikgvs74ewkugKGGtGuhHvQ1ymGPId2deOcLbji4ei1ryLAngdyQ4upSs7qxmXIzIs7WBqumQKkHDgJAyKCfg(rlsvtH2qphIIrL0tpZEGajkTdVbrXOsAh2zmQHrYJ(Xgg99uKdrXOskt71W61KuUgMiSSTyWtV7IaPocRuRrDyjfb0Q3AWMhqn0P3NbSiUvOmibbNaPocRuRXyatfN6HvQe36ILDgJAyK8OFSHrFpf5qumQKkXjabQqzqccobsDewPwJXaMko1dRujoVxdRxts5AyIWY2Ibp9UlcK6iSsTg1HLueqRERbBEa1qNEFgWI42oJrnmsE0p2WOVNICikgvs74ewkugKGGtGuhHvQ1ymGPIt9WkvIZ7v2Eu09l6(ibbA9ImA0VprzmiCFghL9yFAjs3Nn7EK2prqhgga3xg03NEmGg1(9qKmM((X(ulMbSM9zCGqCF)a3puQj3)iO7NJFuP2((SpeTJOiMk(EnSEnjLRHjclBlg807UiqQJWk1AuhwsralI7W6fzSPgNtGuhHvQ1ymGPQJBRERbByIIfszPqzqccobsDewPwJXaMko1dRujaW96EfGjSvyO71W61KuomSvyO3b0gj28bcX0bSiUHGzzB9ddeYvirzlVda4jSyUhDUwa1g9gKhwViJabEHhgmDofuuCYMwa1g9gKJziBqftSGGjYvirzlVJ7t2RH1RjPCyyRWqp9UlzZmQgbiupGfXn5awHSb5Ir3zGn7mg1WiPTW6fzeiWE05AbuB0BqEy9ImYQhDUwa1g9gKdrXOsQe3YGeeCzZmQgbiupxbcdVMeiq5HszruAhEdIIrLujULbji4YMzuncqOEUcegEn5EnSEnjLddBfg6P3DjJqkcLwPgGfXn5awHSb5Ir3zGn7mg1WiPTW6fzeiWE05AbuB0BqEy9ImYQhDUwa1g9gKdrXOsQe3YGeeCzesrO0k14kqy41KabkpuklIs7WBqumQKkXTmibbxgHuekTsnUcegEn5EnSEnjLddBfg6P3DzkTdN26oGknrmDalIBzqccoyEmg9nQdXuZp4G97vaEArQddZ(Srym7BJCFhwAAiCFaC)(XX0RWSVmibbfW9XWESVjOELA7F(K9PODsfLVpaBVm1Lfv7Feq1(2rHQ99se3pO7h77WstdH77Z(srSF)Y3hIHkKniFVgwVMKYHHTcd907UI0IuhgMMnmgalIBYbSczdYfJUZaB2zmQHrsBH1lYiqG9OZ1cO2O3G8W6fzKvp6CTaQn6nihIIrLujUpFcqGYdLYIO0o8gefJkPsCF(K9Ay9Askhg2km0tV7kG2iXwpOHIawe3H1lYydtuSqAh36aeiZqWe5kKOSL3X9jSGGzzB9ddeYvirzlVJBai7zAVgwVMKYHHTcd907UikikBMrbyrCtoGviBqUy0DgyZoJrnmsAlSErgbcShDUwa1g9gKhwViJS6rNRfqTrVb5qumQKkXTmibbNOGOSzgfxbcdVMeiq5HszruAhEdIIrLujULbji4efeLnZO4kqy41K71W61KuomSvyONE3LCO1gIMdlRukGfXDy9Im2WeflKEFMfZYGeeCW8ym6BuhIPMFWb7bcuEOuweL2H3GOyujvItyAVUxzlSsPOt3RH1RjPChwPu0P3GuSvokcygI4DLule0dzd2yNGr6GInfsUSiGfXnZ2zmQHrYbZJXOVjBkTdNdrXOsAh6WEGaTZyudJKRcO0MdJKsmqXWRj5qumQK2qj3JwhvDOd7zIfZH1lYydtuSqAh36aeyp68akQVPDmGgEy9Imceyp68OFSnTJb0WdRxKrwm7HbtNdMhJrFlO0a04abQWWpAsZs7W5QIgYgSfJRyciWE05AbuB0BqEy9ImYeqGYdLYIO0o8gefJkPsOZzGavy4hnPzPD4Cvrdzd2k2PQHsgTGoEZEwEa1qN7Li28P1B9MoSxIt2RS9a33Hvkf99zu(X((bU)rPDGuFFK6Ly4OAFYHbebCFgLXSVmUpifv7tuqQVFKQ97JcIQ9zu(X(a8(Xgg99uCFMlI9Lbji2VO7F(K9PODsfD)bUVbPuM2FG73ntPD4DXMSDFMlI91Gy4iCF)iY9pFY(u0oPIY0EnSEnjL7WkLIo907UCyLsr)mGfX9fKdyfYgKt7rBruOQ5WkLIolMz2HvkfD(zUmibrtbcdVMuI7ZNWYoJrnmsE0p2WOVNICikgvs7qh2deOdRuk68ZCzqcIMcegEnzhNpHfZ2zmQHrYbZJXOVjBkTdNdrXOsAh6WEGaTZyudJKRcO0MdJKsmqXWRj5qumQK2qj3JwhvDOd7zciWW6fzSHjkwiTJBDyjdsqWvbuAZHrsjgOy41KCWEMyX8foSsPOZ1HFe0MDgJAyKab6WkLIoxhUDgJAyKCikgvsbcKCaRq2GChwPu0B9WAGLR)(mtmbeOdRuk68ZCzqcIMcegEnzh3eL2H3GOyujDVgwVMKYDyLsrNE6DxoSsPORdGfX9fKdyfYgKt7rBruOQ5WkLIolMz2HvkfDUoCzqcIMcegEnPe3NpHLDgJAyK8OFSHrFpf5qumQK2HoShiqhwPu056WLbjiAkqy41KDC(ewmBNXOggjhmpgJ(MSP0oCoefJkPDOd7bc0oJrnmsUkGsBomskXafdVMKdrXOsAdLCpADu1HoSNjGadRxKXgMOyH0oU1HLmibbxfqPnhgjLyGIHxtYb7zIfZx4WkLIo)m)iOn7mg1Wibc0HvkfD(zUDgJAyKCikgvsbcKCaRq2GChwPu0B9WAGLR)whMyciqhwPu056WLbjiAkqy41KDCtuAhEdIIrL09kaiX(tA0V)K4(tUpif33Hvkf997Hd5sH09J9LbjiaCFqkUVFG7p(bc3FY9TZyudJKV)LhUFrSFILFGW9DyLsrF)E4qUuiD)yFzqcca3hKI7lp(X(tUVDgJAyK89Ay9Ask3HvkfD6P3DbsXw5OiGuZ43oSsPOFgWI4(cYbSczdYP9OTiku1CyLsrN1foSsPOZpZpcAdKInzqccwm7WkLIoxhUDgJAyKCikgvsbc8chwPu056WpcAdKInzqccM2RH1RjPChwPu0PNE3fifBLJIasnJF7WkLIUoawe3xqoGviBqoThTfrHQMdRuk6SUWHvkfDUo8JG2aPytgKGGfZoSsPOZpZTZyudJKdrXOskqGx4WkLIo)m)iOnqk2KbjiysGKPOovGTcKIbBu0b7fyRGKolWwbsygYguj0nbswy5iScbskm8JM0S0oCobJbmvOQ5budD6(DCVVvV1GnmrXcP7de4(km8JM0S0oCobJbmvOQ5budD6(DCV)j7de4(xSVhgmDUmiK6vQ1OdePCmdzdQ2hiW9HrPAizmDEOuuok5I609zTpmkvdjJPZdLIYHOyujDFjU3)859bcCFIs7WBqumQKUVe37F(SaPW61KcKIuFtLkbxqs6iWwbsygYguj0nbswy5iScbsxSp5awHSb59ZyQuRbbZY26hgiCFw7Z8(YGeeCvaL2CyKuIbkgEnjhSFFw7dbtKyGAixHHYui1B2PmCmdzdQ2N1(H1lYydtuSq6(sCVVU2hiW9dRxKXgMOyH09V3xN9zsGuy9Asbskm8JMDkJGlijDjWwbsygYguj0nbswy5iScbsxSp5awHSb59ZyQuRbbZY26hgiuGuy9AsbsyFPqXYk4cscafyRajmdzdQe6MaPW61KcKiqQJWk1Auhwsrbswy5iScbskugKGGtGuhHvQ1ymGPIt9WkDFjU3xx7ZAF7mg1Wi5r)ydJ(EkYHOyujDFj2xxcKS6TgS5budDQGKol4cs6eb2kqcZq2GkHUjqkSEnPajcK6iSsTg1HLuuGKfwocRqGKcLbji4ei1ryLAngdyQ4upSs3xI9plqYQ3AWMhqn0Pcs6SGlijaOaBfiHziBqLq3eifwVMuGebsDewPwJ6WskkqYclhHviqccMi3lrS5tda3xI9zEF7mg1Wi5km8JwKQMcTHEoefJkP7ZA)l23ddMoxHeLb5ygYguTpqG7BNXOggjxHeLb5qumQKUpR99WGPZvirzqoMHSbv7de4(2HmMr68S0o8grG7ZAF7mg1Wi5km8dAtbICikgvs3Njbsw9wd28aQHovqsNfCbjPBeyRajmdzdQe6MaPW61KcKymGPQr7XuHqbskKAHvVxtkqID8aZ99aQH((ugrpD)aI7RkAiBqfG77hfDFgLXSVb991pG7t7XuTpemrAxmgWur3VsQJHA)HyFgr5vQTpXa3Nnt2Sl2ejkd2fBIHF0jDF2ee5cKSWYryfcKyE)l2NIUxPgLB1Bn4(abUVcd)OjnlTdNtWyatfQAEa1qNUFh37B1BnydtuSq6(mTpR9vOmibbNaPocRuRXyatfN6Hv6(DSVU2N1(qWe5EjInFA6AFj23oJrnmsEK6BQuXHOyujvWfCbsXGnzqi1fyRGKolWwbsygYguj0nbswy5iScbsH1lYydtuSq6(sCV)jcKcRxtkqYAcgvQ1OhHAyqfCbjPJaBfiHziBqLq3eizHLJWkeifwViJnmrXcP7FVpaCFw7RWWpAsZs7W5emgWuHQMhqn0P73X9(6sGuy9AsbswtWOsTg9iuddQGlijDjWwbsygYguj0nbswy5iScbsEyW05YGqQxPwJoqKYXmKnOAFw7Z8(km8JM0S0oCobJbmvOQ5budD6(37hwViJnmrXcP7de4(km8JM0S0oCobJbmvOQ5budD6(DCVVU2NP9bcCFpmy6Czqi1RuRrhis5ygYguTpR99WGPZTMGrLAn6rOgguoMHSbv7ZAFfg(rtAwAhoNGXaMku18aQHoD)oU3)SaPW61KcKymGPQr7XuHqbxqsaOaBfiHziBqLq3eizHLJWkeiX8(YGeeCkOsHztnJihIH13hiW9VyFYbSczdY7NXuPwdcMLT1pmq4(mTpR9zEFzqccUkGsBomskXafdVMKd2VpR9HGjsmqnKRWqzkK6n7ugoMHSbv7ZA)W6fzSHjkwiDFjU3xx7de4(H1lYydtuSq6(37RZ(mjqkSEnPajfg(rZoLrWfK0jcSvGeMHSbvcDtGKfwocRqGeemlBRFyGqUcjkB57lX(mV)z2V)P7RWWpAsZs7W5emgWuHQMhqn0P7RB3xx7Z0(S2xHHF0KML2HZjymGPcvnpGAOt3xI9bG7ZA)l2NCaRq2G8(zmvQ1GGzzB9ddeUpqG7ldsqWPmcOyLAnXI6CWEbsH1RjfiH9LcflRGlijaOaBfiHziBqLq3eizHLJWkeibbZY26hgiKRqIYw((sSVoNSpR9vy4hnPzPD4CcgdyQqvZdOg6097y)t2N1(xSp5awHSb59ZyQuRbbZY26hgiuGuy9AsbsyFPqXYk4css3iWwbsygYguj0nbswy5iScbsxSVcd)OjnlTdNtWyatfQAEa1qNUpR9VyFYbSczdY7NXuPwdcMLT1pmq4(abUprPD4nikgvs3xI9pzFGa3hgLQHKX05Hsr5OKlQt3N1(WOunKmMopukkhIIrL09Ly)teifwVMuGe2xkuSScUGKUmcSvGuy9AsbsmgWu1O9yQqOajmdzdQe6MGliPUBb2kqcZq2GkHUjqYclhHviq6I9jhWkKniVFgtLAniyw2w)WaHcKcRxtkqc7lfkwwbxWfibdBfgQaBfK0zb2kqcZq2GkHUjqkSEnPaPaAJeB(aHy6cKui1cREVMuGeatyRWqfizHLJWkeibbZY26hgiKRqIYw((DSpa8K9zTpZ73JoxlGAJEdYdRxKX9bcC)l23ddMoNckkoztlGAJEdYXmKnOAFM2N1(qWe5kKOSLVFh37FIGlijDeyRajmdzdQe6MajlSCewHajYbSczdYfJUZaB2zmQHrsBH1lY4(abUFp6CTaQn6nipSErg3N1(9OZ1cO2O3GCikgvs3xI79Lbji4YMzuncqOEUcegEn5(abUV8qP7ZAFIs7WBqumQKUVe37ldsqWLnZOAeGq9Cfim8AsbsH1RjfijBMr1iaH6fCbjPlb2kqcZq2GkHUjqYclhHviqICaRq2GCXO7mWMDgJAyK0wy9ImUpqG73JoxlGAJEdYdRxKX9zTFp6CTaQn6nihIIrL09L4EFzqccUmcPiuALACfim8AY9bcCF5Hs3N1(eL2H3GOyujDFjU3xgKGGlJqkcLwPgxbcdVMuGuy9AsbsYiKIqPvQj4cscafyRajmdzdQe6MajlSCewHajzqccoyEmg9nQdXuZp4G9cKcRxtkqYuAhoT1DavAIy6cUGKorGTcKWmKnOsOBcKcRxtkqkslsDyyA2WyeiPqQfw9EnPajaEArQddZ(Srym7BJCFhwAAiCFaC)(XX0RWSVmibbfW9XWESVjOELA7F(K9PODsfLVpaBVm1Lfv7Feq1(2rHQ99se3pO7h77WstdH77Z(srSF)Y3hIHkKnixGKfwocRqGe5awHSb5Ir3zGn7mg1WiPTW6fzCFGa3VhDUwa1g9gKhwViJ7ZA)E05AbuB0BqoefJkP7lX9(NpzFGa3xEO09zTprPD4nikgvs3xI79pFIGlijaOaBfiHziBqLq3eizHLJWkeifwViJnmrXcP73X9(6SpqG7Z8(qWe5kKOSLVFh37FY(S2hcMLT1pmqixHeLT8974EFai73NjbsH1RjfifqBKyRh0qrbxqs6gb2kqcZq2GkHUjqYclhHviqICaRq2GCXO7mWMDgJAyK0wy9ImUpqG73JoxlGAJEdYdRxKX9zTFp6CTaQn6nihIIrL09L4EFzqccorbrzZmkUcegEn5(abUV8qP7ZAFIs7WBqumQKUVe37ldsqWjkikBMrXvGWWRjfifwVMuGerbrzZmkbxqsxgb2kqcZq2GkHUjqYclhHviqkSErgByIIfs3)E)Z7ZAFM3xgKGGdMhJrFJ6qm18doy)(abUV8qP7ZAFIs7WBqumQKUVe7FY(mjqkSEnPaj5qRnenhwwPubxWfiPHjclRaBfK0zb2kqcZq2GkHUjqYclhHviq6I9jhWkKniVFgtLAniyw2w)WaH7ZAFM3xgKGGtbvkmBQze5qmS((abUpemlBRFyGqUcjkB57lX9(N11(mTpqG73JoxlGAJEdYdRxKX9zTpemX9L4EFDTpqG7tuAhEdIIrL09Ly)ZSFFw7FX(kugKGGtGuhHvQ1ymGPId2lqkSEnPajfg(rZoLrWfKKocSvGeMHSbvcDtGKfwocRqGeZ77HbtNRqIYGCmdzdQ2hiW9TdzmJ05zPD4nIa3hiW9HGjsmqnK3FGbCeNePCmdzdQ2NP9zTpZ7FX(KdyfYgK3pJPsTgemr6(abUV8qP7ZAFIs7WBqumQKUVe7FY(mjqkSEnPaPi13uPsWfKKUeyRajmdzdQe6MajlSCewHajYbSczdYvGI9ngdyQO7ZAFfkdsqWjqQJWk1AmgWuXPEyLUFh37FEFw7BNXOggjp6hBy03troefJkPnuY9O1r1(DS)j7ZA)l2NCaRq2G8(zmvQ1GGjsfifwVMuGeJbmvnApMkek4cscafyRajmdzdQe6MajlSCewHajfkdsqWjqQJWk1AmgWuXPEyLUFh7RR9zT)f7toGviBqE)mMk1AqWeP7de4(kugKGGtGuhHvQ1ymGPId2VpR9jkTdVbrXOs6(sSpZ7RqzqccobsDewPwJXaMko1dR091T7Rzv7ZKaPW61KcKymGPQr7XuHqbxqsNiWwbsygYguj0nbswy5iScbsqWSST(Hbc5kKOSLVVe37Rd73N1(xSp5awHSb59ZyQuRbbZY26hgiuGuy9Asbskm8JMDkJGlijaOaBfiHziBqLq3eizHLJWkeiPqzqccobsDewPwJXaMko1dR09LyFaCFw7FX(KdyfYgK3pJPsTgemrQaPW61KcKiqQJWk1Auhwsrbxqs6gb2kqcZq2GkHUjqYclhHviq6I9jhWkKniVFgtLAniyw2w)WaHcKcRxtkqsHHF0StzeCbjDzeyRajmdzdQe6MajlSCewHajfkdsqWjqQJWk1AmgWuXPEyLUFh37FEFw7dbtCFj2xN9zT)f7toGviBqE)mMk1AqWeP7ZAF7mg1Wi5r)ydJ(EkYHOyujTHsUhToQ2VJ9prGuy9AsbsmgWu1O9yQqOGl4cKSdzmJ0PcSvqsNfyRajmdzdQe6MajlSCewHajYbSczdYPER3ezwP2(S2hcMLT1pmqixHeLT897y)ZaW9zTpZ7BNXOggjp6hBy03troefJkP7de4(xSVhgmDEaf13gIMFGnviMOIJziBq1(S23oJrnmsUkGsBomskXafdVMKdrXOs6(mTpqG7lpu6(S2NO0o8gefJkP7lX(NplqkSEnPajkJakwPwtSOUGlijDeyRajmdzdQe6MaPW61KcKOmcOyLAnXI6cKui1cREVMuGej033N9bP4(bHJW9J(XUFr3FY9zd2C)GUVp73drYy67pKrOn67RuBFaMU3(mokdUpfDVsT9b73NnyZoPcKSWYryfcKSZyudJKh9Jnm67PihIIrL09zTpZ7hwViJnmrXcP73X9(6SpR9dRxKXgMOyH09L4E)t2N1(qWSST(Hbc5kKOSLVFh7FM97F6(mVFy9Im2WeflKUVUDFa4(mTpR9jhWkKnipukAdIIrL7de4(H1lYydtuSq6(DS)j7ZAFiyw2w)WaHCfsu2Y3VJ9bq2VptcUGK0LaBfiHziBqLq3eizHLJWkeiroGviBqo1B9MiZk12N1(xSpDanYvQ4gmunz9nuYHyVb5ygYguTpR9zEF7mg1Wi5r)ydJ(EkYHOyujDFGa3)I99WGPZdOO(2q08dSPcXevCmdzdQ2N1(2zmQHrYvbuAZHrsjgOy41KCikgvs3NP9zTpemrUxIyZNgaUFh7ldsqWHGzzB2bcb79AsoefJkP7de4(YdLUpR9jkTdVbrXOs6(sSVoNfifwVMuGuipIvgEnzZuIYcUGKaqb2kqcZq2GkHUjqYclhHviqICaRq2GCQ36nrMvQTpR9PdOrUsf3GHQjRVHsoe7nihZq2GQ9zTpZ7RgNdMhJrFt2uAhEtnohIIrL097y)ZN3hiW9VyFpmy6CW8ym6BYMs7W5ygYguTpR9TZyudJKRcO0MdJKsmqXWRj5qumQKUptcKcRxtkqkKhXkdVMSzkrzbxqsNiWwbsygYguj0nbswy5iScbsKdyfYgKt9wVjYSsT9zTpDanYvQ4srYvsBZCzrtLACmdzdQ2N1(kugKGGtGuhHvQ1ymGPIt9WkD)oU3hafifwVMuGuipIvgEnzZuIYcUGKaGcSvGeMHSbvcDtGKfwocRqGe5awHSb5HsrBqumQCFw7dbtK7Li28PbG73X(YGeeCiyw2MDGqWEVMKdrXOsQaPW61KcKc5rSYWRjBMsuwWfKKUrGTcKWmKnOsOBcKSWYryfcKihWkKniN6TEtKzLA7ZAFM33oJrnmsE0p2WOVNICikgvs3VJ9pZ(9bcC)l23ddMopGI6BdrZpWMketuXXmKnOAFw7BNXOggjxfqPnhgjLyGIHxtYHOyujDFM2hiW9LhkDFw7tuAhEdIIrL09Ly)ZNiqkSEnPaj6ryLAWMFGnWKXa9d9cUGKUmcSvGeMHSbvcDtGKfwocRqGe5awHSb5HsrBqumQCFw7Z8(km8JwKQMcTHEUxwPvQTpqG7dJs1qYy68qPOCikgvs3xI79pdG7ZKaPW61KcKOhHvQbB(b2atgd0p0l4csQ7wGTcKWmKnOsOBcKSWYryfcKOdOrUsfVhK6GgSHqWEVMKJziBqLaPW61KcKimi9WcdcxWfCbs9q0oIYHlWwbjDwGTcKcRxtkqQF8AsbsygYguj0nbxqs6iWwbsH1RjfibJIInfgkbsygYguj0nbxqs6sGTcKcRxtkqIWG0dlmiCbsygYguj0nbxqsaOaBfiHziBqLq3eifwVMuGuaf13gIMFGnfgkbswy5iScbsxSVhgmDofuuCYMwa1g9gKJziBqLaPEiAhr5WBEjIcK0LGliPteyRajmdzdQe6MaPPxGef9IqGKfwocRqGKdRuk6C)m)iOnqk2Kbji2N1(mVVdRuk6C)m3oJrnmsUcegEn5(xU9bWt2)EF2VptcKui1cREVMuGu3NCyadhP7h77WkLIoDF7mg1WibCFvrUuOAFz97dGNW3NThfDFgbDF7XqXC)GUpyEmg97ZyGsP7p5(a4j7tr7KQ9LbHuFFRERbPaUVmOV)rq33NzFXi1VVvb3hjiqRt33N91kY4(X(2zmQHrYLmxbcdVMCFvrUOdC)kPogk((aGe7xEN09jhgqC)JGUFo7drXOsfc3hIoim3)mG7JgkUpeDqyUp75NWfiroGTmerbsoSsPO3o3O6tRaPW61KcKihWkKnOajYHbeBOHIcKyp)ebsKddikq6SGlijaOaBfiHziBqLq3ein9cKOOxecKcRxtkqICaRq2GcKihWwgIOajhwPu0B60O6tRajlSCewHajhwPu05Uo8JG2aPytgKGyFw7Z8(oSsPOZDD42zmQHrYvGWWRj3)YTpaEY(37Z(9zsGe5WaIn0qrbsSNFIajYHbefiDwWfKKUrGTcKWmKnOsOBcKMEbsu0lcbswy5iScbsxSVdRuk6C)m)iOnqk2Kbji2N1(oSsPOZDD4hbTbsXMmibX(abUVdRuk6Cxh(rqBGuSjdsqSpR9zEFM33HvkfDURd3oJrnmsUcegEn5(DTVdRuk6CxhUmibrtbcdVMCFM2x3UpZ7FMFY(NUVdRuk6Cxh(rqBYGee7Z0(629zEFYbSczdYDyLsrVPtJQpT7Z0(mTFh7Z8(mVVdRuk6C)m3oJrnmsUcegEn5(DTVdRuk6C)mxgKGOPaHHxtUpt7RB3N59pZpz)t33HvkfDUFMFe0MmibX(mTVUDFM3NCaRq2GChwPu0BNBu9PDFM2NjbskKAHvVxtkqQ7t9smCKUFSVdRuk609jhgqCFz97BhX(awP2((bUVDgJAyK7pe77h4(oSsPOd4(QICPq1(Y633pW9vGWWRj3Fi23pW9Lbji2V897Hd5sHu((Dxd6(X(uhIPMFSV4OkIcH77Z(AfzC)y)Js7aH73dRbwU(99zFQdXuZp23HvkfDkG7h09zGgZ(bD)yFXrvefc3NyG7xe7h77WkLI((mkJz)bUpJYy2phFFQ(0UpJYp23oJrnmskxGe5a2Yqefi5WkLIERhwdSC9cKcRxtkqICaRq2GcKihgqSHgkkq6SajYHbefiPJGliPlJaBfiHziBqLq3ein9cKOOlqkSEnPajYbSczdkqICyarbsEyW05buuFBiA(b2uHyIkoMHSbv7ZAF7KkWY52jjp2WRjBdrZpWMcdfhgP0974E)UBbskKAHvVxtkqQ7tomGHJ09TGqiM((u0b73NyG77h4(StWi9Y1V)qSpaVFSHrFpf3NnytaM9rcc06ubsKdyldruGebOX0SkOGl4cKSZyudJKkWwbjDwGTcKWmKnOsOBcKSWYryfcKihWkKnixm6odSzNXOggjTfwViJ7de4(9OZ1cO2O3G8W6fzCFw73JoxlGAJEdYHOyujDFjU3xha4(abUprPD4nikgvs3xI91bakqkSEnPaP(XRjfCbjPJaBfiHziBqLq3eizHLJWkeizNXOggjhmpgJ(MSP0oCoefJkP7lX(6M9zTVDgJAyKCvaL2CyKuIbkgEnjhIIrL0gk5E06OAFj2x3SpR99WGPZbZJXOVjBkTdNJziBq1(S2N59PO3KNeKY9cH6CzAayVDFw77budDUxIyZNwV1B66K9LyFaCFGa3)I9PO3KNeKY9cH6CzAayVDFGa3NO0o8gefJkP73X(6WE2Vpt7ZAFM33oJrnmsEipIvgEnzZuIYCikgvs3xI9pFz2N1(mVpemrIbQH8qEeRm8AsAJaI5LvphZq2GQ9bcCF6aAKRuXLIKRK2M5YIMk14ygYguTpt7de4(xSpemrIbQH8qEeRm8AsAJaI5LvphZq2GQ9zT)f7thqJCLkUuKCL02mxw0uPghZq2GQ9zAFw7Z8(2zmQHrYJ(Xgg99uKdrXOsAdLCpADuTVe7RB2N1(KdyfYgKtaAmnRcUpqG7FX(KdyfYgKtaAmnRcUpqG7toGviBqUY2G((mTpqG7FX(EyW05G5Xy03KnL2HZXmKnOAFGa3xEO09zTprPD4nikgvs3xI911jcKcRxtkqkGI6BdrZpWMcdLGlijDjWwbsygYguj0nbsH1RjfirhqtdIrpcfizHLJWkei5budDUxIyZNwV1B66K9Ly)t2N1(mVVhqn05EjInFAQc3VJ9pzFw7hwViJnmrXcP7lX9(6AFGa3NIEtEsqk3leQZLPbG929zTVmibbxfqPnhgjLyGIHxtYb73N1(H1lYydtuSq6(sCV)j7ZAFM3)I9vy4hTivnfAd9CVSsRuBFGa33oKXmsNNL2H3icCFM2Njbsw9wd28aQHovqsNfCbjbGcSvGeMHSbvcDtGuy9AsbsG5Xy03KnL2HlqsHulS69AsbsDxhJIUF3mL2HVpXa3hSFFF2)K9PODsfDFF2NQpT7ZO8J9b49Jnm67PiG7F59deYOOiG7dsX9zu(X(SzaLUpBHrsjgOy41KCbswy5iScbsKdyfYgKt9wVjYSsT9zTpZ7BNXOggjp6hBy03troefJkPnuY9O1r1(sS)j7de4(2zmQHrYJ(Xgg99uKdrXOsAdLCpADuTFh7FM97Z0(S2N59TZyudJKRcO0MdJKsmqXWRj5qumQKUVe7Rzv7de4(YGeeCvaL2CyKuIbkgEnjhSFFMeCbjDIaBfiHziBqLq3eizHLJWkeiroGviBqEOu0gefJk3hiW9LhkDFw7tuAhEdIIrL09LyFDolqkSEnPajW8ym6BYMs7WfCbjbafyRajmdzdQe6MaPW61KcKOGIIt20cO2O3GcKSWYryfcKGGzzB9ddeYvirzlFFj2)maUpR9TZyudJKdMhJrFt2uAhohIIrL09Ly)Z6AFw7BNXOggjxfqPnhgjLyGIHxtYHOyujDFj2)SUeizQeBwLajDbazp7fCbjPBeyRajmdzdQe6MajlSCewHajYbSczdYPER3ezwP2(S2N59vJZbZJXOVjBkTdVPgNdrXOs6(abU)f77HbtNdMhJrFt2uAhohZq2GQ9zsGuy9AsbsQakT5WiPedum8Asbxqsxgb2kqcZq2GkHUjqYclhHviqICaRq2G8qPOnikgvUpqG7lpu6(S2NO0o8gefJkP7lX(6CwGuy9AsbsQakT5WiPedum8AsbxqsD3cSvGeMHSbvcDtGKfwocRqGuy9Im2WeflKU)9(N3N1(kugKGGtGuhHvQ1ymGPIt9WkD)oU3ha3N1(mV)f7toGviBqobOX0Sk4(abUp5awHSb5eGgtZQG7ZAFM33oJrnmsoyEmg9nztPD4Cikgvs3VJ9pZ(9bcCF7mg1Wi5QakT5WiPedum8AsoefJkPnuY9O1r1(DS)z2VpR9VyFpmy6CW8ym6BYMs7W5ygYguTpt7ZKaPW61KcKI(Xgg99uuWfK0z2lWwbsygYguj0nbsH1Rjfif9Jnm67POajlSCewHaPW6fzSHjkwiD)oU3xN9zTVcLbji4ei1ryLAngdyQ4upSs3VJ911(S2)I9vy4hTivnfAd9CVSsRutGKvV1GnpGAOtfK0zbxqsNplWwbsygYguj0nbswy5iScbsqWSST(Hbc5kKOSLVVe7Fga3N1(2zmQHrYbZJXOVjBkTdNdrXOs6(sS)zDTpR9TZyudJKRcO0MdJKsmqXWRj5qumQK2qj3Jwhv7lX(N1LaPW61KcKOGIIt20cO2O3GcUGKoRJaBfiHziBqLq3eizHLJWkeiroGviBqo1B9MiZk12N1(kugKGGtGuhHvQ1ymGPIt9WkDFj2xN9zTpZ73Jop6hBt7yan8W6fzCFGa3xgKGGRcO0MdJKsmqXWRj5G97ZAF7mg1Wi5r)ydJ(EkYHOyujD)o2)m73hiW9TZyudJKh9Jnm67PihIIrL097y)ZSFFw7BNXOggjxfqPnhgjLyGIHxtYHOyujD)o2)m73NjbsH1RjfibMhJrFlO0a04cUGKoRlb2kqcZq2GkHUjqkSEnPajW8ym6BbLgGgxGKfwocRqGuy9Im2WeflKUFh37RZ(S2xHYGeeCcK6iSsTgJbmvCQhwP7lX(6SpR9zE)E05r)yBAhdOHhwViJ7de4(YGeeCvaL2CyKuIbkgEnjhSFFGa33oJrnmsUcd)OfPQPqBONdrXOs6(sSVMvTptcKS6TgS5budDQGKol4cs6makWwbsygYguj0nbswy5iScbsxSFp6CTJb0WdRxKrbsH1RjfibJIInfgkbxWfiPHjclBlguGTcs6SaBfiHziBqLq3eirrRaj7mg1Wi50b00Gy0JqoefJkPcKcRxtkqIruUajlSCewHajpmy6C6aAAqm6rihZq2GQ9zTVhqn05EjInFA9wVPRt2xI9pzFw7tuAhEdIIrL097y)t2N1(2zmQHrYPdOPbXOhHCikgvs3xI9zEFnRAFD7(SNRBozFM2N1(H1lYydtuSq6(sCVVUeCbjPJaBfiHziBqLq3eizHLJWkeiX8(xSp5awHSb59ZyQuRbbZY26hgiCFGa3xgKGGtbvkmBQze5qmS((mTpR9zEFzqccUkGsBomskXafdVMKd2VpR9HGjsmqnKRWqzkK6n7ugoMHSbv7ZA)W6fzSHjkwiDFjU3xx7de4(H1lYydtuSq6(37RZ(mjqkSEnPajfg(rZoLrWfKKUeyRajmdzdQe6MajlSCewHajzqccofuPWSPMrKdXW67de4(xSp5awHSb59ZyQuRbbZY26hgiuGuy9AsbsyFPqXYk4cscafyRajmdzdQe6MajfsTWQ3RjfibasSVhqn033Q3AQuB)IUVQOHSbvaUpLr52J9LdR099zF)a3NwPMbba8aQH((AyIWYUVPO((vsDmuCbsH1RjfibbZwy9AYMPOUajQdlRliPZcKSWYryfcKS6TgSHjkwiD)79plqYuuVLHikqsdtewwbxqsNiWwbsygYguj0nbsH1RjfiXyatvJ2JPcHcKSWYryfcKyEF7mg1Wi5r)ydJ(EkYHOyujD)o2)K9zTVcLbji4ei1ryLAngdyQ4G97de4(kugKGGtGuhHvQ1ymGPIt9WkD)o2xx7Z0(S2N59jkTdVbrXOs6(sSVDgJAyKCfg(rlsvtH2qphIIrL09pD)ZSFFGa3NO0o8gefJkP73X(2zmQHrYJ(Xgg99uKdrXOs6(mjqYQ3AWMhqn0Pcs6SGlijaOaBfiHziBqLq3eifwVMuGebsDewPwJ6WskkqYclhHviqsHYGeeCcK6iSsTgJbmvCQhwP7lX9(6AFw7BNXOggjp6hBy03troefJkP7lX(NSpqG7RqzqccobsDewPwJXaMko1dR09Ly)ZcKS6TgS5budDQGKol4css3iWwbsygYguj0nbsH1RjfirGuhHvQ1OoSKIcKSWYryfcKSZyudJKh9Jnm67PihIIrL097y)t2N1(kugKGGtGuhHvQ1ymGPIt9WkDFj2)SajRERbBEa1qNkiPZcUGKUmcSvGeMHSbvcDtGuy9Asbsei1ryLAnQdlPOajfsTWQ3RjfiX2JIUFr3hjiqRxKrJ(9jkJbH7Z4OSh7tlr6(Sz3J0(jc6WWa4(YG((0Jb0O2VhIKX03p2NAXmG1SpJdeI77h4(Hsn5(hbD)C8Jk123N9HODefXuXfizHLJWkeifwViJn14CcK6iSsTgJbmv73X9(w9wd2WeflKUpR9vOmibbNaPocRuRXyatfN6Hv6(sSpak4cUajfseGgxGTcs6SaBfifwVMuGKyLQgbeXllkqcZq2GkHUj4csshb2kqcZq2GkHUjqA6firrxGuy9AsbsKdyfYguGe5WaIcKyEFKDcw99OIxj1cb9q2Gn2jyKoOytHKllUpR9TZyudJKxj1cb9q2Gn2jyKoOytHKllYHyO0VptcKui1cREVMuGu3dIKX03N2J2IOq1(oSsPOt3xgRuBFqkQ2Nr5h7hG(igEz33ujsfiroGTmerbs0E0wefQAoSsPOl4cssxcSvGeMHSbvcDtG00lqIIUaPW61KcKihWkKnOajYHbefizNXOggjNckkoztlGAJEdYHOyujDFj2)K9zTVhgmDofuuCYMwa1g9gKJziBq1(S2N599WGPZbZJXOVjBkTdNJziBq1(S23oJrnmsoyEmg9nztPD4Cikgvs3xI9pRR9zTVDgJAyKCvaL2CyKuIbkgEnjhIIrL0gk5E06OAFj2)SU2hiW9VyFpmy6CW8ym6BYMs7W5ygYguTptcKihWwgIOaP(zmvQ1GGzzB9ddek4cscafyRajmdzdQe6MaPPxGefDbsH1RjfiroGviBqbsKddikqYddMoNoGMgeJEeYXmKnOAFw7dbtCFj2xN9zTVhqn05EjInFA9wVPRt2xI9pzFw7tuAhEdIIrL097y)teiroGTmerbs9ZyQuRbbtKk4cs6eb2kqcZq2GkHUjqA6firrxGuy9AsbsKdyfYguGe5WaIcKcRxKXgMOyH09V3)8(S2N59VyFyuQgsgtNhkfLJsUOoDFGa3hgLQHKX05Hsr5vUFh7F(K9zsGe5a2Yqefir9wVjYSsnbxqsaqb2kqcZq2GkHUjqA6firrxGuy9AsbsKdyfYguGe5WaIcKcRxKXgMOyH0974EFD2N1(mV)f7dJs1qYy68qPOCuYf1P7de4(WOunKmMopukkhLCrD6(S2N59HrPAizmDEOuuoefJkP73X(NSpqG7tuAhEdIIrL097y)ZSFFM2NjbsKdyldruGuOu0gefJkfCbjPBeyRajmdzdQe6MaPPxGefDbsH1RjfiroGviBqbsKddikqI599WGPZPGIIt20cO2O3GCmdzdQ2N1(xSFp6CTaQn6nipSErg3N1(2zmQHrYPGIIt20cO2O3GCikgvs3hiW9VyFpmy6CkOO4KnTaQn6nihZq2GQ9zAFw7Z8(YGeeCW8ym6BbLgGgNd2VpqG77HbtNhqr9THO5hytfIjQ4ygYguTpR97rNh9JTPDmGgEy9ImUpqG7ldsqWvbuAZHrsjgOy41KCW(9bcC)W6fzSHjkwiD)oU3xN9zTVcd)OfPQPqBON7LvALA7ZKajYbSLHikqsm6odSzNXOggjTfwViJcUGKUmcSvGeMHSbvcDtG00lqIIUaPW61KcKihWkKnOajYHbefizhYygPZZs7WBebUpR9vy4hTivnfAd9CVSsRuBFw7ldsqWvy4h0Mce5upSs3xI9bW9bcCFzqccUyaHddu10qrQpj2W8islkIPZb73hiW9Lbji4(bSmMgfrPiKd2VpqG7ldsqWjGyEzlu1eNK6WHwUEoy)(abUVmibb3GHQjRVHsoe7nihSFFGa3xgKGGBpIH2KJe5G97de4(2zmQHrYbZJXOVfuAaACoefJkP7lX(NiqICaBziIcKuGI9ngdyQOcUGK6UfyRajmdzdQe6MaPW61KcKgqxgIHubskKAHvVxtkqIDarLEuzLA73DPGGgm997EMqde3VO7h73dRbwUEbswy5iScbsQX5KliObtV1BcnqKdrcispczdUpR9VyFpmy6CW8ym6BYMs7W5ygYguTpR9VyFyuQgsgtNhkfLJsUOovWfK0z2lWwbsygYguj0nbsH1RjfinGUmedPcKSWYryfcKuJZjxqqdMER3eAGihIeqKEeYgCFw7hwViJnmrXcP73X9(6SpR9zE)l23ddMohmpgJ(MSP0oCoMHSbv7de4(EyW05G5Xy03KnL2HZXmKnOAFw7Z8(2zmQHrYbZJXOVjBkTdNdrXOs6(DSpZ7F(K97A)W6fzSHjkwiD)t3xnoNCbbny6TEtObICikgvs3NP9bcC)W6fzSHjkwiD)oU3xx7Z0(mjqYQ3AWMhqn0Pcs6SGliPZNfyRajmdzdQe6MaPW61KcKgqxgIHubsMkXMvjqcakqYclhHviqkSErgBQX5KliObtV1BcnqCFj2pSErgByIIfs3N1(H1lYydtuSq6(DCVVo7ZAFM3)I99WGPZbZJXOVjBkTdNJziBq1(abUVDgJAyKCW8ym6BYMs7W5qumQKUpR9Lbji4G5Xy03KnL2H3Kbji4QHrUptcKui1cREVMuGeaiX((bcX9diUpMOyH09flkTsT97U09aC)OV3OF)Y3NzzqF)C2xCG4((rK7pPf3VhH7da3NI2jvuM4cUGKoRJaBfiHziBqLq3eizHLJWkeibbtKyGAiNc2JqQdJk5ygYguTpR9zEF14Cc4q9gbsgHCisar6riBW9bcCF14CzZmQwVj0aroejGi9iKn4(mjqkSEnPaPb0LHyivWfK0zDjWwbsygYguj0nbsH1RjfiXyatvJ2JPcHcKui1cREVMuGeadsar6bs3NnXWpO7ZMGyN09Lbji2V7as99LrIbI7RWWpO7RaX9XurfizHLJWkeizhYygPZZs7WBebUpR9vy4hTivnfAd98W6fzSbrXOs6(sSpZ7Rzv7RB3)m)K9zAFw7RWWpArQAk0g65EzLwPMGliPZaOaBfiHziBqLq3eirrRaj7mg1Wi50b00Gy0JqoefJkPcKcRxtkqIruUajlSCewHajpmy6C6aAAqm6rihZq2GQ9zTVhqn05EjInFA9wVPRt2xI9pzFw77budDUxIyZNMQW97y)t2N1(2zmQHrYPdOPbXOhHCikgvs3xI9zEFnRAFD7(SNRBozFM2N1(H1lYydtuSq6(37FwWfK05teyRajmdzdQe6MajfsTWQ3RjfiXogLVpXa3NnXWp6KUpBcIDXMirzW9lI9LuPD47ZomW99zFn03N6qm18J9Lbji2xoSs3pOrVajkAfizNXOggjxHHFqBkqKdrXOsQaPW61KcKyeLlqYclhHviqYoKXmsNNL2H3icCFw7BNXOggjxHHFqBkqKdrXOs6(sSVMvTpR9dRxKXgMOyH09V3)SGliPZaqb2kqcZq2GkHUjqIIwbs2zmQHrYvirzqoefJkPcKcRxtkqIruUajlSCewHaj7qgZiDEwAhEJiW9zTVDgJAyKCfsugKdrXOs6(sSVMvTpR9dRxKXgMOyH09V3)SGliPZ6gb2kqcZq2GkHUjqsHulS69AsbsaCRxtUVUxuNUFKQ9V89yIq6(mF57XeH0UiHStqmTiDFWKc23pqhv7x5(HsnjNjbsH1RjfizdJPfwVMSzkQlqYuuVLHikqYHvkfDQGliPZxgb2kqcZq2GkHUjqkSEnPajBymTW61KntrDbsMI6Tmerbs2HmMr6ubxqsN7UfyRajmdzdQe6MaPW61KcKSHX0cRxt2mf1fizkQ3YqefibdBfgQGlijDyVaBfiHziBqLq3eifwVMuGKnmMwy9AYMPOUajtr9wgIOaj7mg1WiPcUGK05SaBfiHziBqLq3eizHLJWkeiroGviBqEOu0gefJk3N1(mVVDgJAyKCfg(rlsvtH2qphIIrL09Ly)ZSFFw7FX(EyW05kKOmihZq2GQ9bcCF7mg1Wi5kKOmihIIrL09Ly)ZSFFw77HbtNRqIYGCmdzdQ2hiW9TdzmJ05zPD4nIa3N1(2zmQHrYvy4h0Mce5qumQKUVe7FM97Z0(S2)I9vy4hTivnfAd9CVSsRutGuy9AsbsqWSfwVMSzkQlqYuuVLHikqkgSrrhSxWfKKo6iWwbsygYguj0nbswy5iScbsH1lYydtuSq6(DCVVo7ZAFfg(rlsvtH2qp3lR0k1eirDyzDbjDwGuy9AsbsqWSfwVMSzkQlqYuuVLHikqkgSjdcPUGlijD0LaBfiHziBqLq3eizHLJWkeifwViJnmrXcP73X9(6SpR9zE)l2xHHF0Iu1uOn0Z9YkTsT9zTpZ7BNXOggjxHHF0Iu1uOn0ZHOyujD)o2)m73N1(xSVhgmDUcjkdYXmKnOAFGa33oJrnmsUcjkdYHOyujD)o2)m73N1(EyW05kKOmihZq2GQ9bcCF7qgZiDEwAhEJiW9zTVDgJAyKCfg(bTParoefJkP73X(Nz)(mTpqG7FX(KdyfYgKhkfTbrXOY9zsGuy9AsbsqWSfwVMSzkQlqYuuVLHikqsdtew2wmOGlijDaqb2kqcZq2GkHUjqYclhHviqkSErgByIIfs3)E)Z7de4(xSp5awHSb5HsrBqumQuGe1HL1fK0zbsH1RjfizdJPfwVMSzkQlqYuuVLHikqsdtewwbxWfi5WkLIovGTcs6SaBfiHziBqLq3eifwVMuGuLule0dzd2yNGr6GInfsUSOajlSCewHajM33oJrnmsoyEmg9nztPD4Cikgvs3VJ91H97de4(2zmQHrYvbuAZHrsjgOy41KCikgvsBOK7rRJQ97yFDy)(mTpR9zE)W6fzSHjkwiD)oU3xN9bcC)E05buuFt7yan8W6fzCFGa3VhDE0p2M2XaA4H1lY4(S2N599WGPZbZJXOVfuAaACoMHSbv7de4(km8JM0S0oCUQOHSbBX4Q9zAFGa3VhDUwa1g9gKhwViJ7Z0(abUV8qP7ZAFIs7WBqumQKUVe7RZ59bcCFfg(rtAwAhoxv0q2GTIDQAOKrlOJ7FVp73N1(Ea1qN7Li28P1B9MoSFFj2)ebsziIcKQKAHGEiBWg7emshuSPqYLffCbjPJaBfiHziBqLq3eifwVMuGKdRuk6NfiPqQfw9EnPaj2EG77WkLI((mk)yF)a3)O0oqQVps9smCuTp5WaIaUpJYy2xg3hKIQ9jki13ps1(9rbr1(mk)yFaE)ydJ(EkUpZfX(YGee7x09pFY(u0oPIU)a33Gukt7pW97MP0o8Uyt2UpZfX(AqmCeUVFe5(NpzFkANurzsGKfwocRqG0f7toGviBqoThTfrHQMdRuk67ZAFM3N59DyLsrN7N5YGeenfim8AY9L4E)ZNSpR9TZyudJKh9Jnm67PihIIrL097yFDy)(abUVdRuk6C)mxgKGOPaHHxtUFh7F(K9zTpZ7BNXOggjhmpgJ(MSP0oCoefJkP73X(6W(9bcCF7mg1Wi5QakT5WiPedum8AsoefJkPnuY9O1r1(DSVoSFFM2hiW9dRxKXgMOyH0974EFD2N1(YGeeCvaL2CyKuIbkgEnjhSFFM2N1(mV)f77WkLIo31HFe0MDgJAyK7de4(oSsPOZDD42zmQHrYHOyujDFGa3NCaRq2GChwPu0B9WAGLRF)79pVpt7Z0(abUVdRuk6C)mxgKGOPaHHxtUFh37tuAhEdIIrLubxqs6sGTcKWmKnOsOBcKSWYryfcKUyFYbSczdYP9OTiku1CyLsrFFw7Z8(mVVdRuk6CxhUmibrtbcdVMCFjU3)8j7ZAF7mg1Wi5r)ydJ(EkYHOyujD)o2xh2VpqG77WkLIo31Hldsq0uGWWRj3VJ9pFY(S2N59TZyudJKdMhJrFt2uAhohIIrL097yFDy)(abUVDgJAyKCvaL2CyKuIbkgEnjhIIrL0gk5E06OA)o2xh2Vpt7de4(H1lYydtuSq6(DCVVo7ZAFzqccUkGsBomskXafdVMKd2Vpt7ZAFM3)I9DyLsrN7N5hbTzNXOgg5(abUVdRuk6C)m3oJrnmsoefJkP7de4(KdyfYgK7WkLIERhwdSC97FVVo7Z0(mTpqG77WkLIo31Hldsq0uGWWRj3VJ79jkTdVbrXOsQaPW61KcKCyLsrxhbxqsaOaBfiHziBqLq3eifwVMuGKdRuk6NfirnJlqYHvkf9ZcKSWYryfcKUyFYbSczdYP9OTiku1CyLsrFFw7FX(oSsPOZ9Z8JG2aPytgKGyFw7Z8(oSsPOZDD42zmQHrYHOyujDFGa3)I9DyLsrN76WpcAdKInzqcI9zsGKcPwy171KcKaaj2FsJ(9Ne3FY9bP4(oSsPOVFpCixkKUFSVmibbG7dsX99dC)Xpq4(tUVDgJAyK89V8W9lI9tS8deUVdRuk673dhYLcP7h7ldsqa4(GuCF5Xp2FY9TZyudJKl4cs6eb2kqcZq2GkHUjqkSEnPajhwPu01rGKfwocRqG0f7toGviBqoThTfrHQMdRuk67ZA)l23HvkfDURd)iOnqk2Kbji2N1(mVVdRuk6C)m3oJrnmsoefJkP7de4(xSVdRuk6C)m)iOnqk2Kbji2NjbsuZ4cKCyLsrxhbxWfCbsKriTMuqs6WED0H96OZzbsmcywPgvGe7iahGrsaGscG1L2FF2EG7xI9d03NyG73zmyJIoyFN7dr2jybr1(0re3pa9rmCuTV9isnKY3R6EL4(NV0(SXKKrOJQ970ddMohG6CFF2Vtpmy6CaIJziBqvN7Z8zjZeFVQ7vI7RZL2NnMKmcDuTFNqWejgOgYbOo33N97ecMiXa1qoaXXmKnOQZ9z(SKzIVx19kX9bGxAF2ysYi0r1(D6HbtNdqDUVp73PhgmDoaXXmKnOQZ9zwhjZeFVUxzhb4amscausaSU0(7Z2dC)sSFG((edC)oJbBYGqQ35(qKDcwquTpDeX9dqFedhv7BpIudP89QUxjUVUU0(SXKKrOJQ970ddMohG6CFF2Vtpmy6CaIJziBqvN7ZSUKmt89QUxjUpaEP9zJjjJqhv73jemrIbQHCaQZ99z)oHGjsmqnKdqCmdzdQ6CFMplzM4719k7iahGrsaGscG1L2FF2EG7xI9d03NyG73PdRuk60o3hIStWcIQ9PJiUFa6Jy4OAF7rKAiLVx19kX9pFP9zJjjJqhv73PhgmDoa15((SFNEyW05aehZq2GQo3N5ZsMj(Ev3Re3xNlTpBmjze6OA)oDyLsrNFMdqDUVp73PdRuk6C)mhG6CFM1LKzIVx19kX915s7ZgtsgHoQ2VthwPu056WbOo33N970HvkfDURdhG6CFM1rYmX3R6EL4(66s7ZgtsgHoQ2VthwPu05N5auN77Z(D6WkLIo3pZbOo3NzDKmt89QUxjUVUU0(SXKKrOJQ970HvkfDUoCaQZ99z)oDyLsrN76WbOo3NzDjzM47vDVsCFa8s7ZgtsgHoQ2VthwPu05N5auN77Z(D6WkLIo3pZbOo3N5ZsMj(Ev3Re3haV0(SXKKrOJQ970HvkfDUoCaQZ99z)oDyLsrN76WbOo3NzDKmt89QUxjU)jxAF2ysYi0r1(D6WkLIo)mhG6CFF2VthwPu05(zoa15(mRJKzIVx19kX9p5s7ZgtsgHoQ2VthwPu056WbOo33N970HvkfDURdhG6CFMplzM4719k7iahGrsaGscG1L2FF2EG7xI9d03NyG73PgMiSSDUpezNGfev7thrC)a0hXWr1(2Ji1qkFVQ7vI7RZL2NnMKmcDuTFNqWejgOgYbOo33N97ecMiXa1qoaXXmKnOQZ9z(SKzIVx3RSJaCagjbakjawxA)9z7bUFj2pqFFIbUFN2HmMr60o3hIStWcIQ9PJiUFa6Jy4OAF7rKAiLVx19kX9pFP9zJjjJqhv73PhgmDoa15((SFNEyW05aehZq2GQo3N5ZsMj(Ev3Re3xxxAF2ysYi0r1(D6HbtNdqDUVp73PhgmDoaXXmKnOQZ9z(SKzIVx19kX911L2NnMKmcDuTFN0b0ixPIdqDUVp73jDanYvQ4aehZq2GQo3N5ZsMj(Ev3Re3haV0(SXKKrOJQ970ddMohG6CFF2Vtpmy6CaIJziBqvN7Z8zjZeFVQ7vI7dGxAF2ysYi0r1(DshqJCLkoa15((SFN0b0ixPIdqCmdzdQ6CFMplzM47vDVsC)tU0(SXKKrOJQ97KoGg5kvCaQZ99z)oPdOrUsfhG4ygYgu15(mFwYmX3R6EL4(6MlTpBmjze6OA)o9WGPZbOo33N970ddMohG4ygYgu15(mFwYmX3R6EL4(D3xAF2ysYi0r1(DshqJCLkoa15((SFN0b0ixPIdqCmdzdQ6C)W3V7F5199z(SKzIVx3RSJaCagjbakjawxA)9z7bUFj2pqFFIbUFN9q0oIYH35(qKDcwquTpDeX9dqFedhv7BpIudP89QUxjUpaEP9zJjjJqhv73PhgmDoa15((SFNEyW05aehZq2GQo3p897(xEDFFMplzM47vDVsC)tU0(SXKKrOJQ9jvISX(u9PhsE)l3LBFF2x3bJ9fhfObKU)0JWWh4(mF5yAFMplzM47vDVsC)tU0(SXKKrOJQ970HvkfD(zoa15((SFNoSsPOZ9ZCaQZ9zwhjZeFVQ7vI7daV0(SXKKrOJQ9jvISX(u9PhsE)l3LBFF2x3bJ9fhfObKU)0JWWh4(mF5yAFMplzM47vDVsCFa4L2NnMKmcDuTFNoSsPOZ1HdqDUVp73PdRuk6Cxhoa15(mRJKzIVx19kX91nxAF2ysYi0r1(Kkr2yFQ(0djV)LBFF2x3bJ9vf5IwtU)0JWWh4(m3ft7ZSosMj(Ev3Re3x3CP9zJjjJqhv73PdRuk68ZCaQZ99z)oDyLsrN7N5auN7ZmakzM47vDVsCFDZL2NnMKmcDuTFNoSsPOZ1HdqDUVp73PdRuk6Cxhoa15(mFIKzIVx19kX9VmxAF2ysYi0r1(D6HbtNdqDUVp73PhgmDoaXXmKnOQZ9z(SKzIVx3RSJaCagjbakjawxA)9z7bUFj2pqFFIbUFN2zmQHrs7CFiYobliQ2NoI4(bOpIHJQ9ThrQHu(Ev3Re3xNlTpBmjze6OA)o9WGPZbOo33N970ddMohG4ygYgu15(mRJKzIVx19kX915s7ZgtsgHoQ2VtiyIedud5auN77Z(DcbtKyGAihG4ygYgu15(mRJKzIVx19kX915s7ZgtsgHoQ2Vt6aAKRuXbOo33N97KoGg5kvCaIJziBqvN7ZSosMj(Ev3Re3x3CP9zJjjJqhv73PhgmDoa15((SFNEyW05aehZq2GQo3N5ZsMj(Ev3Re3V7(s7ZgtsgHoQ2Vtpmy6CaQZ99z)o9WGPZbioMHSbvDUpZNLmt896ELDeGdWijaqjbW6s7VpBpW9lX(b67tmW97udtew2wmyN7dr2jybr1(0re3pa9rmCuTV9isnKY3R6EL4(NV0(SXKKrOJQ970ddMohG6CFF2Vtpmy6CaIJziBqvN7Z8zjZeFVQ7vI7RZL2NnMKmcDuTFNqWejgOgYbOo33N97ecMiXa1qoaXXmKnOQZ9z(SKzIVx3RSJaCagjbakjawxA)9z7bUFj2pqFFIbUFNkKianEN7dr2jybr1(0re3pa9rmCuTV9isnKY3R6EL4(66s7ZgtsgHoQ2Vtpmy6CaQZ99z)o9WGPZbioMHSbvDUpZ6sYmX3R6EL4(a4L2NnMKmcDuTFNEyW05auN77Z(D6HbtNdqCmdzdQ6CFMplzM47vDVsCFDZL2NnMKmcDuTFNEyW05auN77Z(D6HbtNdqCmdzdQ6CFM1LKzIVx19kX97UV0(SXKKrOJQ970ddMohG6CFF2Vtpmy6CaIJziBqvN7Z8zjZeFVQ7vI7FM9xAF2ysYi0r1(Kkr2yFQ(0djV)LBFF2x3bJ9vf5IwtU)0JWWh4(m3ft7Z8zjZeFVQ7vI7FM9xAF2ysYi0r1(D6HbtNdqDUVp73PhgmDoaXXmKnOQZ9zwhjZeFVQ7vI7F(8L2NnMKmcDuTFNEyW05auN77Z(D6HbtNdqCmdzdQ6CFMplzM47vDVsC)Z6CP9zJjjJqhv73jemrIbQHCaQZ99z)oHGjsmqnKdqCmdzdQ6CFMplzM47vDVsC)Za4L2NnMKmcDuTFNEyW05auN77Z(D6HbtNdqCmdzdQ6CFMplzM47vDVsCFDoFP9zJjjJqhv73PhgmDoa15((SFNEyW05aehZq2GQo3NzDKmt89QUxjUVo66s7ZgtsgHoQ2Vtpmy6CaQZ99z)o9WGPZbioMHSbvDUpZ6izM4719kaOy)aDuT)z2VFy9AY9nf1P89QaPa0pgOajsLiOj8As2ageUaPE4quguGe7YU7ZMy4h7ZoywAh((aSZJXOFVYUS7(Sdrziya1VVoNbCFDyVo6Sx3RSl7UpBCePgsV0ELDz39ba2hGR6oGuxetNUVp7ZMjB2fBIeLb7InXWpO7ZMG4((S)Kg97BhW033dOg609zCm7hqCFuY9O1r1((SVPiJ7BMuBFmhqTJ99zFXWDeUpZXGnk6G97ZUNzIVxzx2DFaG9zZIgYguTpPWclIYwHz)Uxy99LrBasX9vyO2x7yan09fdP4(edCFAO2NnzhKY3RSl7UpaW(aSPvQTp74aMQ9j1JPcH7hYLP8cP7loqCFcdk5s2OFFMdFFa809PEyLs3VsQJHA)Hy)toLj2bUpB29iTFIGomm7hPAFXq)(9qKmM((0re3phaaiA3Nwoy41Ku(ELDz39ba2hGnTsT9zhIuhHvQTpjhwsX9RCFa(LV7VFrSV(bC)JGmUFo(rLA7JgkUVp7RM9JuTpJj703FiJqB0VpJbmv09l6(Sz3J0(jc6WWW3RSl7UpaW(SXrKAOAFXi1VFNeL2H3GOyujTZ9TtQkVMmm099z)OV3OF)k3xEO09jkTdNU)Kg97ZSbP09zd2CFgb1X9NCFhg0dM47v2LD3hayFaUsHQ9JC8deU)Lh0LHyiDFmDO(99zFk67d2Vp1HtQHW97(9LcfllLVxzx2DFaG9byqti59jX29jt57dWV8D)9nJwz3NwPf3V89HOPq6(tUVDsIqg0eoQ2hgLQHKX0P89k7YU7daSpBV8S5L)s7Vp7WW6dCFsoetn)y)E4yP7xPp77WkLI((MrRS896EnSEnjL3dr7ikh(P3D1pEn5EnSEnjL3dr7ikh(P3DbJIInfgQ9Ay9AskVhI2ruo8tV7IWG0dlmi89Ay9AskVhI2ruo8tV7kGI6BdrZpWMcdfG9q0oIYH38seV1fGfX9fEyW05uqrXjBAbuB0BW9k7UF3NCyadhP7h77WkLIoDF7mg1WibCFvrUuOAFz97dGNW3NThfDFgbDF7XqXC)GUpyEmg97ZyGsP7p5(a4j7tr7KQ9LbHuFFRERbPaUVmOV)rq33NzFXi1VVvb3hjiqRt33N91kY4(X(2zmQHrYLmxbcdVMCFvrUOdC)kPogk((aGe7xEN09jhgqC)JGUFo7drXOsfc3hIoim3)mG7JgkUpeDqyUp75NW3RH1RjP8EiAhr5Wp9UlYbSczdcygI4TdRuk6TZnQ(0c40FtrViaKCyaX7ZasomGydnu8M98ta0oPQ8AYBhwPu05N5hbTbsXMmibblMDyLsrNFMBNXOggjxbcdVM8YD5aWtUzpt71W61KuEpeTJOC4NE3f5awHSbbmdr82Hvkf9MonQ(0c40FtrViaKCyaX7ZasomGydnu8M98ta0oPQ8AYBhwPu056WpcAdKInzqccwm7WkLIoxhUDgJAyKCfim8AYl3Ldap5M9mTxz397(uVedhP7h77WkLIoDFYHbe3xw)(2rSpGvQTVFG7BNXOgg5(dX((bUVdRuk6aUVQixkuTVS(99dCFfim8AY9hI99dCFzqcI9lF)E4qUuiLVF31GUFSp1HyQ5h7loQIOq4((SVwrg3p2)O0oq4(9WAGLRFFF2N6qm18J9DyLsrNc4(bDFgOXSFq3p2xCufrHW9jg4(fX(X(oSsPOVpJYy2FG7ZOmM9ZX3NQpT7ZO8J9TZyudJKY3RH1RjP8EiAhr5Wp9UlYbSczdcygI4TdRuk6TEynWY1d40FtrViaKCyaXBDaKCyaXgAO49zaTtQkVM8(chwPu05N5hbTbsXMmibblhwPu056WpcAdKInzqccGaDyLsrNRd)iOnqk2KbjiyXmZoSsPOZ1HBNXOggjxbcdVM8Y5WkLIoxhUmibrtbcdVMKjDlZN5NCQdRuk6CD4hbTjdsqWKULzYbSczdYDyLsrVPtJQpTmXuhmZSdRuk68ZC7mg1Wi5kqy41KxohwPu05N5YGeenfim8AsM0TmFMFYPoSsPOZpZpcAtgKGGjDlZKdyfYgK7WkLIE7CJQpTmX0ELD3V7tomGHJ09TGqiM((u0b73NyG77h4(StWi9Y1V)qSpaVFSHrFpf3NnytaM9rcc0609Ay9AskVhI2ruo8tV7ICaRq2GaMHiEtaAmnRcci5WaI3EyW05buuFBiA(b2uHyIkw2jvGLZTtsESHxt2gIMFGnfgkomsPDC3DVx3RSl7UF3xYOf0r1(izeQFFVeX99dC)W6dC)IUFqoktiBq(EnSEnj9wSsvJaI4Lf3RS7(DpisgtFFApAlIcv77WkLIoDFzSsT9bPOAFgLFSFa6Jy4LDFtLiDVgwVMKE6DxKdyfYgeWmeXBApAlIcvnhwPu0bKCyaXBMr2jy13JkELule0dzd2yNGr6GInfsUSil7mg1Wi5vsTqqpKnyJDcgPdk2ui5YICigk9mTxzx2D)UlbSczds3RH1RjPNE3f5awHSbbmdr8UFgtLAniyw2w)WaHasomG4TDgJAyKCkOO4KnTaQn6nihIIrLujoHLhgmDofuuCYMwa1g9gKfZEyW05G5Xy03KnL2HZYoJrnmsoyEmg9nztPD4CikgvsL4SUyzNXOggjxfqPnhgjLyGIHxtYHOyujTHsUhToQK4SUac8cpmy6CW8ym6BYMs7WzAVgwVMKE6DxKdyfYgeWmeX7(zmvQ1GGjsbKCyaXBpmy6C6aAAqm6riliyIsOdlpGAOZ9seB(06TEtxNiXjSikTdVbrXOsAhNSxdRxtsp9UlYbSczdcygI4n1B9MiZk1aKCyaX7W6fzSHjkwi9(mlMVagLQHKX05Hsr5OKlQtbcegLQHKX05Hsr5v2X5tyAVgwVMKE6DxKdyfYgeWmeX7qPOnikgvci5WaI3H1lYydtuSqAh36WI5lGrPAizmDEOuuok5I6uGaHrPAizmDEOuuok5I6uwmdJs1qYy68qPOCikgvs74eGajkTdVbrXOsAhNzptmTxdRxtsp9UlYbSczdcygI4Ty0DgyZoJrnmsAlSErgbKCyaXBM9WGPZPGIIt20cO2O3GSUOhDUwa1g9gKhwViJSSZyudJKtbffNSPfqTrVb5qumQKce4fEyW05uqrXjBAbuB0BqMyXSmibbhmpgJ(wqPbOX5G9ab6HbtNhqr9THO5hytfIjQy1Jop6hBt7yan8W6fzeiqzqccUkGsBomskXafdVMKd2deyy9Im2WeflK2XToSuy4hTivnfAd9CVSsRuJP9Ay9As6P3DroGviBqaZqeVvGI9ngdyQOasomG4TDiJzKoplTdVreilfg(rlsvtH2qp3lR0k1yjdsqWvy4h0Mce5upSsLaabcugKGGlgq4WavnnuK6tInmpI0IIy6CWEGaLbji4(bSmMgfrPiKd2deOmibbNaI5LTqvtCsQdhA565G9abkdsqWnyOAY6BOKdXEdYb7bcugKGGBpIH2KJe5G9abANXOggjhmpgJ(wqPbOX5qumQKkXj7v2DF2bev6rLvQTF3LccAW03V7zcnqC)IUFSFpSgy563RH1RjPNE31a6YqmKcyrCRgNtUGGgm9wVj0aroejGi9iKniRl8WGPZbZJXOVjBkTdN1fWOunKmMopukkhLCrD6EnSEnj907UgqxgIHuaT6TgS5budD69zalIB14CYfe0GP36nHgiYHibePhHSbzfwViJnmrXcPDCRdlMVWddMohmpgJ(MSP0oCGa9WGPZbZJXOVjBkTdNfZ2zmQHrYbZJXOVjBkTdNdrXOsAhmF(Klxy9Im2WeflKEQACo5ccAW0B9Mqde5qumQKYeqGH1lYydtuSqAh36IjM2RS7(aGe77hie3pG4(yIIfs3xSO0k12V7s3dW9J(EJ(9lFFMLb99ZzFXbI77hrU)KwC)EeUpaCFkANurzIVxdRxtsp9URb0LHyifqtLyZQUbGawe3H1lYytnoNCbbny6TEtObIsewViJnmrXcPScRxKXgMOyH0oU1HfZx4HbtNdMhJrFt2uAhoqG2zmQHrYbZJXOVjBkTdNdrXOsklzqccoyEmg9nztPD4nzqccUAyKmTxdRxtsp9URb0LHyifWI4gcMiXa1qofShHuhgvYIz14Cc4q9gbsgHCisar6riBqGavJZLnZOA9Mqde5qKaI0Jq2GmTxz39byqcispq6(Sjg(bDF2ee7KUVmibX(DhqQVVmsmqCFfg(bDFfiUpMk6EnSEnj907UymGPQr7XuHqalIB7qgZiDEwAhEJiqwkm8JwKQMcTHEEy9Im2GOyujvcM1SkD7z(jmXsHHF0Iu1uOn0Z9YkTsT9Ay9As6P3DXikhqkAVTZyudJKthqtdIrpc5qumQKcyrC7HbtNthqtdIrpcz5budDUxIyZNwV1B66ejoHLhqn05EjInFAQc74ew2zmQHrYPdOPbXOhHCikgvsLGznRs3YEUU5eMyfwViJnmrXcP3N3RS7(SJr57tmW9ztm8JoP7ZMGyxSjsugC)IyFjvAh((SddCFF2xd99Poetn)yFzqcI9LdR09dA0VxdRxtsp9Ulgr5asr7TDgJAyKCfg(bTParoefJkPawe32HmMr68S0o8grGSSZyudJKRWWpOnfiYHOyujvcnRIvy9Im2WeflKEFEVgwVMKE6DxmIYbKI2B7mg1Wi5kKOmihIIrLualIB7qgZiDEwAhEJiqw2zmQHrYvirzqoefJkPsOzvScRxKXgMOyH07Z7v2DFaU1Rj3x3lQt3ps1(x(EmriDFMV89yIqAxKq2jiMwKUpysb77hOJQ9RC)qPMKZ0EnSEnj907USHX0cRxt2mf1bmdr82HvkfD6EnSEnj907USHX0cRxt2mf1bmdr82oKXmsNUxdRxtsp9UlBymTW61KntrDaZqeVHHTcdDVYUS7(H1RjPNE3ffzNGyAralI7W6fzSHjkwi9(mRluy4hnPzPD4Cvrdzd2IXvS8WGPZPGIIt20cO2O3GaMHiERfqT20JjcV0a6YqmKEjcK6iSsTg1HLu8sei1ryLAnQdlP4LOGIIt20cO2O3GxkGI6BdrZpWMcd1Luy4hn7ugalIBzqccofuPWSPMrKd2Fjfg(rZoL5skm8JMDkZLO2beQHnQdlPiGfXTcLbji4ei1ryLAngdyQ4upSs7aaVe1oGqnSrDyjfbSiUvOmibbNaPocRuRXyatfN6HvAha4LiqQJWk1AuhwsX9k7YU7hwVMKE6DxuKDcIPfbSiUdRxKXgMOyH07ZSUqHHF0KML2HZvfnKnylgxX6cpmy6CkOO4KnTaQn6niGziI3tpMi8sei1ryLAnQdlP4LiqQJWk1AuhwsXl1pEn5LaZJXOVjBkTd)sQakT5WiPedum8AYlf9Jnm67P4EnSEnj907USHX0cRxt2mf1bmdr82oJrnms6EnSEnj907UGGzlSEnzZuuhWmeX7yWgfDWEalIBYbSczdYdLI2GOyujlMTZyudJKRWWpArQAk0g65qumQKkXz2Z6cpmy6Cfsugeiq7mg1Wi5kKOmihIIrLujoZEwEyW05kKOmiqG2HmMr68S0o8grGSSZyudJKRWWpOnfiYHOyujvIZSNjwxOWWpArQAk0g65EzLwP2EnSEnj907UGGzlSEnzZuuhWmeX7yWMmiK6asDyz97Zawe3H1lYydtuSqAh36WsHHF0Iu1uOn0Z9YkTsT9Ay9As6P3DbbZwy9AYMPOoGziI3AyIWY2IbbSiUdRxKXgMOyH0oU1HfZxOWWpArQAk0g65EzLwPglMTZyudJKRWWpArQAk0g65qumQK2Xz2Z6cpmy6Cfsugeiq7mg1Wi5kKOmihIIrL0ooZEwEyW05kKOmiqG2HmMr68S0o8grGSSZyudJKRWWpOnfiYHOyujTJZSNjGaVGCaRq2G8qPOnikgvY0EnSEnj907USHX0cRxt2mf1bmdr8wdtewwaPoSS(9zalI7W6fzSHjkwi9(mqGxqoGviBqEOu0gefJk3R7v2LD3hGpD)97giK671W61KuEmytges9BRjyuPwJEeQHbfWI4oSErgByIIfsL4(K9Ay9AskpgSjdcP(P3DznbJk1A0JqnmOawe3H1lYydtuSq6naKLcd)OjnlTdNtWyatfQAEa1qN2XTU2RH1RjP8yWMmiK6NE3fJbmvnApMkecyrC7HbtNldcPELAn6arklMvy4hnPzPD4CcgdyQqvZdOg607W6fzSHjkwifiqfg(rtAwAhoNGXaMku18aQHoTJBDXeqGEyW05YGqQxPwJoqKYYddMo3AcgvQ1OhHAyqzPWWpAsZs7W5emgWuHQMhqn0PDCFEVgwVMKYJbBYGqQF6Dxkm8JMDkdGfXnZYGeeCkOsHztnJihIH1bc8cYbSczdY7NXuPwdcMLT1pmqitSywgKGGRcO0MdJKsmqXWRj5G9SGGjsmqnKRWqzkK6n7ugwH1lYydtuSqQe36ciWW6fzSHjkwi9whM2RH1RjP8yWMmiK6NE3f2xkuSSawe3qWSST(Hbc5kKOSLlbZNz)Pkm8JM0S0oCobJbmvOQ5budDQUvxmXsHHF0KML2HZjymGPcvnpGAOtLaaY6cYbSczdY7NXuPwdcMLT1pmqiqGYGeeCkJakwPwtSOohSFVgwVMKYJbBYGqQF6DxyFPqXYcyrCdbZY26hgiKRqIYwUe6Cclfg(rtAwAhoNGXaMku18aQHoTJtyDb5awHSb59ZyQuRbbZY26hgiCVgwVMKYJbBYGqQF6DxyFPqXYcyrCFHcd)OjnlTdNtWyatfQAEa1qNY6cYbSczdY7NXuPwdcMLT1pmqiqGeL2H3GOyujvItacegLQHKX05Hsr5OKlQtzbJs1qYy68qPOCikgvsL4K9Ay9AskpgSjdcP(P3DXyatvJ2JPcH71W61KuEmytges9tV7c7lfkwwalI7lihWkKniVFgtLAniyw2w)WaH719k7YU7dWNU)(KqhSFVgwVMKYJbBu0b7VJuFtLkalIBfg(rtAwAhoNGXaMku18aQHoTJBRERbByIIfsbcuHHF0KML2HZjymGPcvnpGAOt74(eGaVWddMoxges9k1A0bIuGaHrPAizmDEOuuok5I6uwWOunKmMopukkhIIrLujUpFgiqIs7WBqumQKkX95Z71W61KuEmyJIoy)P3DPWWpA2Pmawe3xqoGviBqE)mMk1AqWSST(HbczXSmibbxfqPnhgjLyGIHxtYb7zbbtKyGAixHHYui1B2PmScRxKXgMOyHujU1fqGH1lYydtuSq6TomTxdRxts5XGnk6G9NE3f2xkuSSawe3xqoGviBqE)mMk1AqWSST(Hbc3RH1RjP8yWgfDW(tV7IaPocRuRrDyjfb0Q3AWMhqn0P3NbSiUvOmibbNaPocRuRXyatfN6HvQe36ILDgJAyK8OFSHrFpf5qumQKkHU2RH1RjP8yWgfDW(tV7IaPocRuRrDyjfb0Q3AWMhqn0P3NbSiUvOmibbNaPocRuRXyatfN6HvQeN3RH1RjP8yWgfDW(tV7IaPocRuRrDyjfb0Q3AWMhqn0P3NbSiUHGjY9seB(0aqjy2oJrnmsUcd)OfPQPqBONdrXOskRl8WGPZvirzqGaTZyudJKRqIYGCikgvsz5HbtNRqIYGabAhYygPZZs7WBebYYoJrnmsUcd)G2uGihIIrLuM2RS7(SJhyUVhqn03NYi6P7hqCFvrdzdQaCF)OO7ZOmM9nOVV(bCFApMQ9HGjs7IXaMk6(vsDmu7pe7ZikVsT9jg4(SzYMDXMirzWUytm8JoP7ZMGiFVgwVMKYJbBu0b7p9UlgdyQA0EmvieWI4M5lOO7vQr5w9wdceOcd)OjnlTdNtWyatfQAEa1qN2XTvV1GnmrXcPmXsHYGeeCcK6iSsTgJbmvCQhwPDOlwqWe5EjInFA6sc7mg1Wi5rQVPsfhIIrL096ELDz397EJxtUxdRxts52zmQHrsV7hVMeWI4MCaRq2GCXO7mWMDgJAyK0wy9Imceyp6CTaQn6nipSErgz1JoxlGAJEdYHOyujvIBDaGabsuAhEdIIrLuj0baUxzx2DF2ygJAyK09Ay9Ask3oJrnms6P3Dfqr9THO5hytHHcWI42oJrnmsoyEmg9nztPD4CikgvsLq3WYoJrnmsUkGsBomskXafdVMKdrXOsAdLCpADujHUHLhgmDoyEmg9nztPD4SyMIEtEsqk3leQZLPbG9wwEa1qN7Li28P1B9MUorcaeiWlOO3KNeKY9cH6CzAayVfiqIs7WBqumQK2HoSN9mXIz7mg1Wi5H8iwz41KntjkZHOyujvIZxgwmdbtKyGAipKhXkdVMK2iGyEz1deiDanYvQ4srYvsBZCzrtLAmbe4fqWejgOgYd5rSYWRjPnciMxw9SUGoGg5kvCPi5kPTzUSOPsnMyXSDgJAyK8OFSHrFpf5qumQK2qj3JwhvsOByroGviBqobOX0SkiqGxqoGviBqobOX0SkiqGKdyfYgKRSnOZeqGx4HbtNdMhJrFt2uAhoqGYdLYIO0o8gefJkPsORt2RH1RjPC7mg1WiPNE3fDannig9ieqRERbBEa1qNEFgWI42dOg6CVeXMpTER301jsCclM9aQHo3lrS5ttvyhNWkSErgByIIfsL4wxabsrVjpjiL7fc15Y0aWEllzqccUkGsBomskXafdVMKd2ZkSErgByIIfsL4(ewmFHcd)OfPQPqBON7LvALAabAhYygPZZs7WBebYet7v2D)URJrr3VBMs7W3NyG7d2VVp7FY(u0oPIUVp7t1N29zu(X(a8(Xgg99ueW9V8(bczuueW9bP4(mk)yF2mGs3NTWiPedum8As(EnSEnjLBNXOggj907UaZJXOVjBkTdhWI4MCaRq2GCQ36nrMvQXIz7mg1Wi5r)ydJ(EkYHOyujTHsUhToQK4eGaTZyudJKh9Jnm67PihIIrL0gk5E06OQJZSNjwmBNXOggjxfqPnhgjLyGIHxtYHOyujvcnRciqzqccUkGsBomskXafdVMKd2Z0EnSEnjLBNXOggj907UaZJXOVjBkTdhWI4MCaRq2G8qPOnikgvceO8qPSikTdVbrXOsQe6CEVgwVMKYTZyudJKE6DxuqrXjBAbuB0BqanvInR6wxaq2ZEalIBiyw2w)WaHCfsu2YL4maYYoJrnmsoyEmg9nztPD4CikgvsL4SUyzNXOggjxfqPnhgjLyGIHxtYHOyujvIZ6AVgwVMKYTZyudJKE6DxQakT5WiPedum8AsalIBYbSczdYPER3ezwPglMvJZbZJXOVjBkTdVPgNdrXOskqGx4HbtNdMhJrFt2uAhot71W61KuUDgJAyK0tV7sfqPnhgjLyGIHxtcyrCtoGviBqEOu0gefJkbcuEOuweL2H3GOyujvcDoVxdRxts52zmQHrsp9UROFSHrFpfbSiUdRxKXgMOyH07ZSuOmibbNaPocRuRXyatfN6HvAh3ailMVGCaRq2GCcqJPzvqGajhWkKniNa0yAwfKfZ2zmQHrYbZJXOVjBkTdNdrXOsAhNzpqG2zmQHrYvbuAZHrsjgOy41KCikgvsBOK7rRJQooZEwx4HbtNdMhJrFt2uAhotmTxdRxts52zmQHrsp9UROFSHrFpfb0Q3AWMhqn0P3NbSiUdRxKXgMOyH0oU1HLcLbji4ei1ryLAngdyQ4upSs7qxSUqHHF0Iu1uOn0Z9YkTsT9Ay9Ask3oJrnms6P3DrbffNSPfqTrVbbSiUHGzzB9ddeYvirzlxIZail7mg1Wi5G5Xy03KnL2HZHOyujvIZ6ILDgJAyKCvaL2CyKuIbkgEnjhIIrL0gk5E06OsIZ6AVgwVMKYTZyudJKE6DxG5Xy03cknanoGfXn5awHSb5uV1BImRuJLcLbji4ei1ryLAngdyQ4upSsLqhwm3Jop6hBt7yan8W6fzeiqzqccUkGsBomskXafdVMKd2ZYoJrnmsE0p2WOVNICikgvs74m7bc0oJrnmsE0p2WOVNICikgvs74m7zzNXOggjxfqPnhgjLyGIHxtYHOyujTJZSNP9Ay9Ask3oJrnms6P3DbMhJrFlO0a04aA1BnyZdOg607Zawe3H1lYydtuSqAh36WsHYGeeCcK6iSsTgJbmvCQhwPsOdlM7rNh9JTPDmGgEy9ImceOmibbxfqPnhgjLyGIHxtYb7bc0oJrnmsUcd)OfPQPqBONdrXOsQeAwft71W61KuUDgJAyK0tV7cgffBkmuawe3x0Jox7yan8W6fzCVYUS7(SzrdzdQaC)Udi13phFFiggJ(9ZbkgM9LXJGCnW99JW7KUpJb6h73dcPGvQTFLaaAHiY3RSl7UFy9Ask3oJrnms6P3DrdlSikBfMwFyDalI7W6fzSHjkwiTJBDyDHmibbxfqPnhgjLyGIHxtYb7zzNXOggjxfqPnhgjLyGIHxtYHOyujTJtacuEOuweL2H3GOyujvcnRAVUxzx2DF2yiJzK((aC5YuEH09Ay9Ask3oKXmsNEtzeqXk1AIf1bSiUjhWkKniN6TEtKzLASGGzzB9ddeYvirzlVJZaqwmBNXOggjp6hBy03troefJkPabEHhgmDEaf13gIMFGnviMOILDgJAyKCvaL2CyKuIbkgEnjhIIrLuMacuEOuweL2H3GOyujvIZN3RS7(KqFFF2hKI7heoc3p6h7(fD)j3NnyZ9d6((SFpejJPV)qgH2OVVsT9by6E7Z4Om4(u09k12hSFF2Gn7KUxdRxts52HmMr60tV7IYiGIvQ1elQdyrCBNXOggjp6hBy03troefJkPSyoSErgByIIfs74whwH1lYydtuSqQe3NWccMLT1pmqixHeLT8ooZ(tzoSErgByIIfs1TaqMyroGviBqEOu0gefJkbcmSErgByIIfs74ewqWSST(Hbc5kKOSL3baYEM2RH1RjPC7qgZiD6P3DfYJyLHxt2mLOmGfXn5awHSb5uV1BImRuJ1f0b0ixPIBWq1K13qjhI9gKfZ2zmQHrYJ(Xgg99uKdrXOskqGx4HbtNhqr9THO5hytfIjQyzNXOggjxfqPnhgjLyGIHxtYHOyujLjwqWe5EjInFAayhYGeeCiyw2MDGqWEVMKdrXOskqGYdLYIO0o8gefJkPsOZ59Ay9Ask3oKXmsNE6DxH8iwz41KntjkdyrCtoGviBqo1B9MiZk1yrhqJCLkUbdvtwFdLCi2BqwmRgNdMhJrFt2uAhEtnohIIrL0ooFgiWl8WGPZbZJXOVjBkTdNLDgJAyKCvaL2CyKuIbkgEnjhIIrLuM2RH1RjPC7qgZiD6P3DfYJyLHxt2mLOmGfXn5awHSb5uV1BImRuJfDanYvQ4srYvsBZCzrtLASuOmibbNaPocRuRXyatfN6HvAh3a4EnSEnjLBhYygPtp9URqEeRm8AYMPeLbSiUjhWkKnipukAdIIrLSGGjY9seB(0aWoKbji4qWSSn7aHG9EnjhIIrL09Ay9Ask3oKXmsNE6Dx0JWk1Gn)aBGjJb6h6bSiUjhWkKniN6TEtKzLASy2oJrnmsE0p2WOVNICikgvs74m7bc8cpmy68akQVnen)aBQqmrfl7mg1Wi5QakT5WiPedum8AsoefJkPmbeO8qPSikTdVbrXOsQeNpzVgwVMKYTdzmJ0PNE3f9iSsnyZpWgyYyG(HEalIBYbSczdYdLI2GOyujlMvy4hTivnfAd9CVSsRudiqyuQgsgtNhkfLdrXOsQe3NbqM2RH1RjPC7qgZiD6P3Dryq6HfgeoGfXnDanYvQ49Guh0Gnec271K719k7YU7tQsndUpBdOg671W61KuUgMiSS3km8JMDkdGfX9fKdyfYgK3pJPsTgemlBRFyGqwmldsqWPGkfMn1mICigwhiqiyw2w)WaHCfsu2YL4(SUyciWE05AbuB0BqEy9ImYccMOe36ciqIs7WBqumQKkXz2Z6cfkdsqWjqQJWk1AmgWuXb73RH1RjPCnmryzp9URi13uPcWI4Mzpmy6CfsugKJziBqfqG2HmMr68S0o8grGabcbtKyGAiV)ad4iojszIfZxqoGviBqE)mMk1AqWePabkpuklIs7WBqumQKkXjmTxdRxts5AyIWYE6DxmgWu1O9yQqiGfXn5awHSb5kqX(gJbmvuwkugKGGtGuhHvQ1ymGPIt9WkTJ7ZSSZyudJKh9Jnm67PihIIrL0gk5E06OQJtyDb5awHSb59ZyQuRbbtKUxdRxts5AyIWYE6DxmgWu1O9yQqiGfXTcLbji4ei1ryLAngdyQ4upSs7qxSUGCaRq2G8(zmvQ1GGjsbcuHYGeeCcK6iSsTgJbmvCWEweL2H3GOyujvcMvOmibbNaPocRuRXyatfN6HvQUvZQyAVgwVMKY1WeHL907Uuy4hn7ugalIBiyw2w)WaHCfsu2YL4wh2Z6cYbSczdY7NXuPwdcMLT1pmq4EnSEnjLRHjcl7P3DrGuhHvQ1OoSKIawe3kugKGGtGuhHvQ1ymGPIt9WkvcaK1fKdyfYgK3pJPsTgemr6EnSEnjLRHjcl7P3DPWWpA2Pmawe3xqoGviBqE)mMk1AqWSST(Hbc3RH1RjPCnmryzp9UlgdyQA0EmvieWI4wHYGeeCcK6iSsTgJbmvCQhwPDCFMfemrj0H1fKdyfYgK3pJPsTgemrkl7mg1Wi5r)ydJ(EkYHOyujTHsUhToQ64K96ELDz39byHjcl7(a8P7VF3dwdSC971W61KuUgMiSSTyWBgr5asr7TDgJAyKC6aAAqm6rihIIrLualIBpmy6C6aAAqm6rilpGAOZ9seB(06TEtxNiXjSikTdVbrXOsAhNWYoJrnmsoDannig9iKdrXOsQemRzv6w2Z1nNWeRW6fzSHjkwivIBDTxdRxts5AyIWY2Ibp9Ulfg(rZoLbWI4M5lihWkKniVFgtLAniyw2w)WaHabkdsqWPGkfMn1mICigwNjwmldsqWvbuAZHrsjgOy41KCWEwqWejgOgYvyOmfs9MDkdRW6fzSHjkwivIBDbeyy9Im2WeflKERdt71W61KuUgMiSSTyWtV7c7lfkwwalIBzqccofuPWSPMrKdXW6abEb5awHSb59ZyQuRbbZY26hgiCVYU7dasSVhqn033Q3AQuB)IUVQOHSbvaUpLr52J9LdR099zF)a3NwPMbba8aQH((AyIWYUVPO((vsDmu89Ay9Askxdtew2wm4P3DbbZwy9AYMPOoGziI3AyIWYci1HL1VpdyrCB1BnydtuSq6959Ay9Askxdtew2wm4P3DXyatvJ2JPcHaA1BnyZdOg607Zawe3mBNXOggjp6hBy03troefJkPDCclfkdsqWjqQJWk1AmgWuXb7bcuHYGeeCcK6iSsTgJbmvCQhwPDOlMyXmrPD4nikgvsLWoJrnmsUcd)OfPQPqBONdrXOs6PNzpqGeL2H3GOyujTd7mg1Wi5r)ydJ(EkYHOyujLP9Ay9Askxdtew2wm4P3DrGuhHvQ1OoSKIaA1BnyZdOg607Zawe3kugKGGtGuhHvQ1ymGPIt9WkvIBDXYoJrnmsE0p2WOVNICikgvsL4eGavOmibbNaPocRuRXyatfN6HvQeN3RH1RjPCnmryzBXGNE3fbsDewPwJ6WskcOvV1GnpGAOtVpdyrCBNXOggjp6hBy03troefJkPDCclfkdsqWjqQJWk1AmgWuXPEyLkX59k7UpBpk6(fDFKGaTErgn63NOmgeUpJJYESpTeP7ZMDps7NiOdddG7ld67tpgqJA)EisgtF)yFQfZawZ(moqiUVFG7hk1K7Fe09ZXpQuBFF2hI2ruetfFVgwVMKY1WeHLTfdE6Dxei1ryLAnQdlPiGfXDy9Im2uJZjqQJWk1AmgWu1XTvV1GnmrXcPSuOmibbNaPocRuRXyatfN6HvQea4EDVYU7dWe2km09Ay9Askhg2km07aAJeB(aHy6awe3qWSST(Hbc5kKOSL3ba8ewm3JoxlGAJEdYdRxKrGaVWddMoNckkoztlGAJEdYXmKnOIjwqWe5kKOSL3X9j71W61KuomSvyONE3LSzgvJaeQhWI4MCaRq2GCXO7mWMDgJAyK0wy9Imceyp6CTaQn6nipSErgz1JoxlGAJEdYHOyujvIBzqccUSzgvJaeQNRaHHxtceO8qPSikTdVbrXOsQe3YGeeCzZmQgbiupxbcdVMCVgwVMKYHHTcd907UKrifHsRudWI4MCaRq2GCXO7mWMDgJAyK0wy9Imceyp6CTaQn6nipSErgz1JoxlGAJEdYHOyujvIBzqccUmcPiuALACfim8AsGaLhkLfrPD4nikgvsL4wgKGGlJqkcLwPgxbcdVMCVgwVMKYHHTcd907UmL2HtBDhqLMiMoGfXTmibbhmpgJ(g1HyQ5hCW(9k7UpapTi1HHzF2imM9TrUVdlnneUpaUF)4y6vy2xgKGGc4(yyp23euVsT9pFY(u0oPIY3hGTxM6YIQ9pcOAF7Oq1(EjI7h09J9DyPPHW99zFPi2VF57dXqfYgKVxdRxts5WWwHHE6DxrArQddtZggdGfXn5awHSb5Ir3zGn7mg1WiPTW6fzeiWE05AbuB0BqEy9ImYQhDUwa1g9gKdrXOsQe3Npbiq5HszruAhEdIIrLujUpFYEnSEnjLddBfg6P3DfqBKyRh0qralI7W6fzSHjkwiTJBDacKziyICfsu2Y74(ewqWSST(Hbc5kKOSL3XnaK9mTxdRxts5WWwHHE6DxefeLnZOaSiUjhWkKnixm6odSzNXOggjTfwViJab2JoxlGAJEdYdRxKrw9OZ1cO2O3GCikgvsL4wgKGGtuqu2mJIRaHHxtceO8qPSikTdVbrXOsQe3YGeeCIcIYMzuCfim8AY9Ay9Askhg2km0tV7so0AdrZHLvkfWI4oSErgByIIfsVpZIzzqccoyEmg9nQdXuZp4G9abkpuklIs7WBqumQKkXjmTx3RSl7UpBHvkfD6EnSEnjL7WkLIo9gKITYrraZqeVRKAHGEiBWg7emshuSPqYLfbSiUz2oJrnmsoyEmg9nztPD4Cikgvs7qh2deODgJAyKCvaL2CyKuIbkgEnjhIIrL0gk5E06OQdDyptSyoSErgByIIfs74whGa7rNhqr9nTJb0WdRxKrGa7rNh9JTPDmGgEy9ImYIzpmy6CW8ym6BbLgGghiqfg(rtAwAhoxv0q2GTyCftab2JoxlGAJEdYdRxKrMacuEOuweL2H3GOyujvcDodeOcd)OjnlTdNRkAiBWwXovnuYOf0XB2ZYdOg6CVeXMpTER30H9sCYELD3NTh4(oSsPOVpJYp23pW9pkTdK67JuVedhv7tomGiG7ZOmM9LX9bPOAFIcs99JuTFFuquTpJYp2hG3p2WOVNI7ZCrSVmibX(fD)ZNSpfTtQO7pW9niLY0(dC)UzkTdVl2KT7ZCrSVgedhH77hrU)5t2NI2jvuM2RH1RjPChwPu0PNE3LdRuk6NbSiUVGCaRq2GCApAlIcvnhwPu0zXmZoSsPOZpZLbjiAkqy41KsCF(ew2zmQHrYJ(Xgg99uKdrXOsAh6WEGaDyLsrNFMldsq0uGWWRj748jSy2oJrnmsoyEmg9nztPD4Cikgvs7qh2deODgJAyKCvaL2CyKuIbkgEnjhIIrL0gk5E06OQdDyptabgwViJnmrXcPDCRdlzqccUkGsBomskXafdVMKd2ZelMVWHvkfDUo8JG2SZyudJeiqhwPu056WTZyudJKdrXOskqGKdyfYgK7WkLIERhwdSC93NzIjGaDyLsrNFMldsq0uGWWRj74MO0o8gefJkP71W61KuUdRuk60tV7YHvkfDDaSiUVGCaRq2GCApAlIcvnhwPu0zXmZoSsPOZ1Hldsq0uGWWRjL4(8jSSZyudJKh9Jnm67PihIIrL0o0H9ab6WkLIoxhUmibrtbcdVMSJZNWIz7mg1Wi5G5Xy03KnL2HZHOyujTdDypqG2zmQHrYvbuAZHrsjgOy41KCikgvsBOK7rRJQo0H9mbeyy9Im2WeflK2XToSKbji4QakT5WiPedum8AsoyptSy(chwPu05N5hbTzNXOggjqGoSsPOZpZTZyudJKdrXOskqGKdyfYgK7WkLIERhwdSC936Wetab6WkLIoxhUmibrtbcdVMSJBIs7WBqumQKUxz39baj2FsJ(9Ne3FY9bP4(oSsPOVFpCixkKUFSVmibbG7dsX99dC)Xpq4(tUVDgJAyK89V8W9lI9tS8deUVdRuk673dhYLcP7h7ldsqa4(GuCF5Xp2FY9TZyudJKVxdRxts5oSsPOtp9Ulqk2khfbKAg)2Hvkf9Zawe3xqoGviBqoThTfrHQMdRuk6SUWHvkfD(z(rqBGuSjdsqWIzhwPu056WTZyudJKdrXOskqGx4WkLIoxh(rqBGuSjdsqW0EnSEnjL7WkLIo907UaPyRCueqQz8BhwPu01bWI4(cYbSczdYP9OTiku1CyLsrN1foSsPOZ1HFe0gifBYGeeSy2HvkfD(zUDgJAyKCikgvsbc8chwPu05N5hbTbsXMmibbtcUGlia]] )

end
