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


    spec:RegisterPack( "Unholy", 20220301, [[deLhfdqivk9ivQYLuPOAtOsFcr1Oquofc1QqQGxHuQzjiULkcSlc)cPKHHQkhtf1Yqv5zOQQPPsvDnvK2Mkf5BivOXjiHZPIqADcs9ovkuY8KICpuL9jf1brivlePQEOkIMisfDrvkKnIqk6JQieJeHuOtQsbwjsXlrifmtesUPkfk1ori(PkcAOQuuwQkf0tLstvLkxvLcvBvLcfFfHuASivzVa(RunyLoSOftKhl0Kj5YqBgjFwGrRsoTIvlirVwkmBsDBIA3s(TQgUkCCbjTCqphLPt56aTDe8DuX4rQ05fuRxfHA(iY(PAGZa3b0QsdbicF8Jp(4h)53zbF8)u(FM)aTw4deO9iJnYaeOTszeO9gVUEDyG2JmS(tfWDaTShegrG2lZoyHMw0kySlqjr8LPfBKb1PnFfHjLrl2ihPfqRe4OTBqbib0QsdbicF8Jp(4h)53zbF8)u(FMpGw2bgbicFNYhq71Ouybib0QqweOLoX0U8LOHAcUmFVXRRxh2PHOjkbbtyyF5lueIV8Xp(4ZPXP5KxzfGSq70Cc8LORcLGmtglJ5R9(sNfDsl6ePgnsl6et7I5lDcI(AVVFPd7B8blZxlHbOX8LZ17BcrFr6EGrdv(AVV6Ha6R(RaFX6bdU81EFLtZqOVKLp2zObE479otSWP5e4lDoSusJkFBZiCOM4KAFVzz08vcJjid9vHPY3GRhuZ8voBG(s9qFzPYx6KObMWP5e47noBQaFjAFWs5B7bwke6Bkn6XgK5R8drFP0iDhjDyFjlnFVpT9LzzSbZ3PygMkFFkFpL2eFJLV05nR13cbnyQ9nlLVYzyFpGibSmFzVm6B9Naig9LngyAZxmHtZjW3BC2ub(s0ezgcNkW3wdonqFNYxI(j8g57q5B4h03RKa6B921ub(IAg6R9(QEFZs5lNVi389jGWyE4lNhSumFhMV05nR13cbnyQfonNaFp5vwbOYx5Sc7l5utWL1HOCofJCFJFPgB(k1mFT3384qh23P8v6zmFPMGlJ57x6W(sMgzmFpjD6lNKzOVF5Rbt2fXcNMtGVeDLcv(M1Bxi03tiOjbXSHVyzWW(AVVm08f8WxMb)kaH(EJogfkprMWP5e47ne1jD9T9oFjWe(s0pH3iF1FWe9Lnve9DmFHOEqMVF5B8lQucuNgQ8fMJQJeWYycNMtGV3DcPZtyO91xIMz0EOVTgeRa7Y3d4hz(oL9(AWPAGMV6pyIcGw9WmgWDaT5JDgAGha3bqKZa3b0IvkPrfa9bAJWXq4KaTkmTREJAcUmbfNhSuOQBjmanMVnZZ3y4Og7yHYdY8LejFvyAx9g1eCzckopyPqv3syaAmFBMNVN6ljs(ERVwQXYesGqMnvqN9qKjWkL0OYxsK8fMJQJeWYePsXeiDhMX8LRVWCuDKawMivkMaIY5umFBINVNp7ljs(k9mMVC9LAcUSoeLZPy(2epFpFgOnJ28fqBwH7QsbyaeHpG7aAXkL0OcG(aTr4yiCsG2B9LqcNusJIJ)1tf0HG1e7hphe6lxFjZxjqkkHkHn6gmlg1dLtB(saE4lxFHGfs9WauOWuPhKz94pAbwPKgv(Y13mAdbSJfkpiZ3M45l)9LejFZOneWowO8GmF55lF(smqBgT5lGwfM2vp(JgWaic)bUdOfRusJka6d0gHJHWjbAV1xcjCsjnko(xpvqhcwtSF8CqiqBgT5lGw8yuO8ebmaICFG7aAXkL0OcG(aTz0MVaAPqMHWPc6mdonqG2iCmeojqRcLaPOeuiZq4ubDopyPemlJn8TjE(YFF56B8FT65uI84JPo8bdfquoNI5Bt(YFG2y4Og7wcdqJbqKZagarof4oGwSsjnQaOpqBgT5lGwkKziCQGoZGtdeOnchdHtc0QqjqkkbfYmeovqNZdwkbZYydFBY3ZaTXWrn2TegGgdGiNbmaICta3b0IvkPrfa9bAZOnFb0sHmdHtf0zgCAGaTr4yiCsGwiyHcBKXU9977Bt(sMVX)1QNtjuyAx9SuDfgZWcikNtX8LRV36RLASmHcPgnkWkL0OYxsK8n(Vw9CkHcPgnkGOCofZxU(APgltOqQrJcSsjnQ8LejFJpbSYYe1eCzDQe9LRVX)1QNtjuyAxSUcefquoNI5lXaTXWrn2TegGgdGiNbmaIqhbUdOfRusJka6d0MrB(cOLZdwQo7alfcbAvilcNdB(cOLO9clFTegGMVmo5bZ3eI(QgwkPrvi(AxdZxoJw7RgnFd)G(YoWs5leSqgT48GLI57umdtLVpLVCYXMkWxQh6lDw0jTOtKA0iTOtmTlYz(sNGOaOnchdHtc0sMV36ldnBQaMigoQrFjrYxfM2vVrnbxMGIZdwku1TegGgZ3M55BmCuJDSq5bz(sSVC9vHsGuuckKziCQGoNhSucMLXg(2SV83xU(cbluyJm2TVZFFBY34)A1ZPezfURkLaIY5umadWaAZh7sGqMbCharodChqlwPKgva0hOnchdHtc0MrBiGDSq5bz(2epFpfOnJ28fqBuNCMkOZUs1ZHbyaeHpG7aAXkL0OcG(aTr4yiCsG2mAdbSJfkpiZxE(Et(Y1xfM2vVrnbxMGIZdwku1TegGgZ3M55l)bAZOnFb0g1jNPc6SRu9Cyagar4pWDaTyLsAubqFG2iCmeojqRLASmHeiKztf0zpezcSsjnQ8LRVK5Rct7Q3OMGltqX5blfQ6wcdqJ5lpFZOneWowO8GmFjrYxfM2vVrnbxMGIZdwku1TegGgZ3M55l)9LyFjrYxl1yzcjqiZMkOZEiYeyLsAu5lxFTuJLjI6KZubD2vQEombwPKgv(Y1xfM2vVrnbxMGIZdwku1TegGgZ3M557zG2mAZxaTCEWs1zhyPqiGbqK7dChqlwPKgva0hOnchdHtc0sMVsGuucgOsHvx9VSaIz08LejFV1xcjCsjnko(xpvqhcwtSF8CqOVe7lxFjZxjqkkHkHn6gmlg1dLtB(saE4lxFHGfs9WauOWuPhKz94pAbwPKgv(Y13mAdbSJfkpiZ3M45l)9LejFZOneWowO8GmF55lF(smqBgT5lGwfM2vp(JgWaiYPa3b0IvkPrfa9bAJWXq4KaTqWAI9JNdcfkKAIJ5Bt(sMVN5NV02xfM2vVrnbxMGIZdwku1TegGgZx6GV83xI9LRVkmTREJAcUmbfNhSuOQBjmanMVn57n5lxFV1xcjCsjnko(xpvqhcwtSF8CqOVKi5ReifLGXjHYtf0LhMjapaAZOnFb0IhJcLNiGbqKBc4oGwSsjnQaOpqBeogcNeOfcwtSF8CqOqHutCmFBYx(o1xU(QW0U6nQj4YeuCEWsHQULWa0y(2SVN6lxFV1xcjCsjnko(xpvqhcwtSF8CqiqBgT5lGw8yuO8ebmaIqhbUdOfRusJka6d0gHJHWjbAV1xfM2vVrnbxMGIZdwku1TegGgZxU(ERVes4KsAuC8VEQGoeSMy)45GqFjrYxQj4Y6quoNI5Bt(EQVKi5lmhvhjGLjsLIjq6omJ5lxFH5O6ibSmrQumbeLZPy(2KVNc0MrB(cOfpgfkpradGiHcG7aAZOnFb0Y5blvNDGLcHaTyLsAubqFadGiNOa3b0IvkPrfa9bAJWXq4KaT36lHeoPKgfh)RNkOdbRj2pEoieOnJ28fqlEmkuEIagGb0AWPAGgd4oaICg4oGwSsjnQaOpqBgT5lG2PyriOLsAShQGzzGYDfsyIiqBeogcNeOLmFJ)RvpNsawxVoCxspbxMaIY5umFB2x(4NVKi5B8FT65ucvcB0nywmQhkN28LaIY5uSos3dmAOY3M9Lp(5lX(Y1xY8nJ2qa7yHYdY8TzE(YNVKi57bAIekhUhC9GArgTHa6ljs(EGMip(yp46b1ImAdb0xU(sMVwQXYeG11Rd3tglb1MaRusJkFjrYxfM2vVrnbxMqnSusJ98nLVe7ljs(EGMiiHbFynkYOneqFj2xsK8v6zmF56l1eCzDikNtX8TjF57SVKi5Rct7Q3OMGltOgwkPX(eQQosxmcAOV88LF(Y1xlHbOjSrg723pIwNp(5Bt(EkqBLYiq7uSie0sjn2dvWSmq5UcjmreWaicFa3b0IvkPrfa9bARugbAzXeY6pvNcMgcRu3zgCOqG2mAZxaTSycz9NQtbtdHvQ7mdouiGbqe(dChqlwPKgva0hOnJ28fqRDHDQbYSoBcgnqBeogcNeOLqcNusJc5mu(WE8FT65uSEgTHa6lxFjZxBKrFB2x(ZpFjrY3B9fdvW54avIPyriOLsAShQGzzGYDfsyIOVed0wPmc0AxyNAGmRZMGrdyae5(a3b0IvkPrfa9bAZOnFb0(eqiNlulpvq)45GWEegMzPgOnchdHtc0siHtkPrHCgkFyp(Vw9CkwpJ2qa9LRVK5RnYOVn7l)5NVKi57T(IHk4CCGkXuSie0sjn2dvWSmq5Ucjmr0xU(ERVyOcohhOsyxyNAGmRZMGr7lXaTvkJaTpbeY5c1Ytf0pEoiShHHzwQbmaICkWDaTyLsAubqFG2mAZxaTgCQgODgOvHSiCoS5lG27UqFn4unqZxoJD5RDH(EnbxiZ8fz2iNgQ8LqQbXq8LZO1(kH(cYqLVudKz(MLY3JCGOYxoJD5lr)4JPo8bd9LSHYxjqkkFhMVNp1xgg)sX89H(QrgJyFFOV0xpbxgTOZ78LSHY3aiMgc91UYY3ZN6ldJFPyed0gHJHWjbAV1xcjCsjnkyhyCOgu1n4unqZxU(sMVK5RbNQbAc7SqcKIQRaHPnF5Bt8898P(Y134)A1ZPe5XhtD4dgkGOCofZ3M9Lp(5ljs(AWPAGMWolKaPO6kqyAZx(2SVNp1xU(sMVX)1QNtjaRRxhUlPNGltar5CkMVn7lF8ZxsK8n(Vw9CkHkHn6gmlg1dLtB(sar5CkwhP7bgnu5BZ(Yh)8LyFjrY3mAdbSJfkpiZ3M55lF(Y1xjqkkHkHn6gmlg1dLtB(saE4lX(Y1xY89wFn4unqty8jUswp(Vw9CkFjrYxdovd0egFI4)A1ZPequoNI5ljs(siHtkPrHbNQbA9d48WXc7lpFp7lX(sSVKi5R0Zy(Y1xdovd0e2zHeifvxbctB(Y3M55l1eCzDikNtXamaICta3b0IvkPrfa9bAJWXq4KaT36lHeoPKgfSdmoudQ6gCQgO5lxFjZxY81Gt1anHXNqcKIQRaHPnF5Bt8898P(Y134)A1ZPe5XhtD4dgkGOCofZ3M9Lp(5ljs(AWPAGMW4tibsr1vGW0MV8TzFpFQVC9LmFJ)RvpNsawxVoCxspbxMaIY5umFB2x(4NVKi5B8FT65ucvcB0nywmQhkN28LaIY5uSos3dmAOY3M9Lp(5lX(sIKVz0gcyhluEqMVnZZx(8LRVsGuucvcB0nywmQhkN28La8WxI9LRVK57T(AWPAGMWolUswp(Vw9CkFjrYxdovd0e2zr8FT65ucikNtX8LejFjKWjL0OWGt1aT(bCE4yH9LNV85lX(sSVKi5R0Zy(Y1xdovd0egFcjqkQUceM28LVnZZxQj4Y6quoNIb0MrB(cO1Gt1an(amaIqhbUdOfRusJka6d0MrB(cO1Gt1aTZaTm9BaTgCQgODgOnchdHtc0ERVes4KsAuWoW4qnOQBWPAGMVC99wFn4unqtyNfxjRdYWUeifLVC9LmFn4unqty8jI)RvpNsar5CkMVKi57T(AWPAGMW4tCLSoid7sGuu(smqRczr4CyZxaT3akF)sh23VqF)Yxqg6RbNQbA(EaFcJcz(M(kbsrfIVGm0x7c99Tle67x(g)xREoLW3ti03HY3ch7cH(AWPAGMVhWNWOqMVPVsGuuH4lid9v6TlF)Y34)A1ZPeagarcfa3b0IvkPrfa9bAZOnFb0AWPAGgFaTr4yiCsG2B9LqcNusJc2bghQbvDdovd08LRV36RbNQbAcJpXvY6GmSlbsr5lxFjZxdovd0e2zr8FT65ucikNtX8LejFV1xdovd0e2zXvY6GmSlbsr5lXaTm9BaTgCQgOXhGbyaTbyHWjcCharodChqlwPKgva0hOnchdHtc0ERVes4KsAuC8VEQGoeSMy)45GqF56lz(kbsrjyGkfwD1)YciMrZxsK8fcwtSF8CqOqHutCmFBINVN5VV02xY8fcwi1ddqbmLpYY6gmlgfcXkIcSsjnQ8Lo4l)9L2(QW0U6nQj4YeqWcPEyakUcZmeoPV0bF5VVe7lX(sIKVhOjcsyWhwJImAdb0xU(cbl03M45l)9LejFPMGlRdr5CkMVn57z(5lxFV1xfkbsrjOqMHWPc6CEWsjapaAZOnFb0QW0U6XF0agar4d4oGwSsjnQaOpqBeogcNeOLmFTuJLjui1OrbwPKgv(sIKVXNawzzIAcUSovI(sIKVqWcPEyakoUWe(YFHmbwPKgv(sSVC9LmFjZ3B9LqcNusJIJ)1tf0HGfY8LejFJpbSYYe1eCzDQe9LRVwQXYekKA0OaRusJkF56B8lf4ycoJDHWPc6bWhSucSsjnQ8LyFjrYxPNX8LRVutWL1HOCofZ3M89uFjgOnJ28fqBwH7QsbyaeH)a3b0IvkPrfa9bAJWXq4KaTes4KsAuOaLp6CEWsX8LRVkucKIsqHmdHtf058GLsWSm2W3M557zF56B8FT65uI84JPo8bdfquoNI1r6EGrdv(2SVNp13tGVK5leSqQhgGcfMk9GmRh)rlWkL0OYx6GVN5NVe7lxFV1xcjCsjnko(xpvqhcwidOnJ28fqlNhSuD2bwkecyae5(a3b0IvkPrfa9bAJWXq4KaTkucKIsqHmdHtf058GLsWSm2W3M9L)(Y13B9LqcNusJIJ)1tf0HGfY8LejFvOeifLGczgcNkOZ5blLa8WxU(snbxwhIY5umFBYxY8vHsGuuckKziCQGoNhSucMLXg(sh8niQ8LyG2mAZxaTCEWs1zhyPqiGbqKtbUdOfRusJka6d0gHJHWjbAHG1e7hphekui1ehZ3M45lF8ZxA7lz(cblK6HbOaMYhzzDdMfJcHyfrbwPKgv(sh89((sBFvyAx9g1eCzciyHupmafxHzgcN0x6GV33xI9LRV36lHeoPKgfh)RNkOdbRj2pEoieOnJ28fqRct7Qh)rdyae5MaUdOfRusJka6d0gHJHWjbAvOeifLGczgcNkOZ5blLGzzSHVn5799LRV36lHeoPKgfh)RNkOdblKb0MrB(cOLczgcNkOZm40abmaIqhbUdOfRusJka6d0gHJHWjbAV1xcjCsjnko(xpvqhcwtSF8CqiqBgT5lGwfM2vp(JgWaisOa4oGwSsjnQaOpqBeogcNeOvHsGuuckKziCQGoNhSucMLXg(2mpFp7lxFHGf6Bt(YNVC99wFjKWjL0O44F9ubDiyHmF56B8FT65uI84JPo8bdfquoNI1r6EGrdv(2SVNc0MrB(cOLZdwQo7alfcbmadOn(eWklJbCharodChqlwPKgva0hOnchdHtc0siHtkPrbZ6h6SQPc8LRVqWAI9JNdcfkKAIJ5BZ(E(M8LRVK5B8FT65uI84JPo8bdfquoNI5ljs(ERVwQXYejuoC)P62f2vPCHkbwPKgv(Y134)A1ZPeQe2OBWSyupuoT5lbeLZPy(sSVKi5R0Zy(Y1xQj4Y6quoNI5Bt(E(mqBgT5lGwgNekpvqxEygGbqe(aUdOfRusJka6d0MrB(cOLXjHYtf0LhMb0Qqweoh28fqBlA(AVVGm03KYqOV5Xh9Dy((LVNKo9nz(AVVhqKawMVpbegZJJPc89gEZ8LZ1OrFzOztf4l4HVNKojNb0gHJHWjbAJ)RvpNsKhFm1HpyOaIY5umF56lz(MrBiGDSq5bz(2mpF5ZxU(MrBiGDSq5bz(2epFp1xU(cbRj2pEoiuOqQjoMVn77z(5lT9LmFZOneWowO8GmFPd(Et(sSVC9LqcNusJIuPyDikNt5ljs(MrBiGDSq5bz(2SVN6lxFHG1e7hphekui1ehZ3M99(8ZxIbmaIWFG7aAXkL0OcG(aTr4yiCsGwcjCsjnkyw)qNvnvGVC99wFzpOwAkLqJPQlfUJ0nLp0OaRusJkF56lz(g)xREoLip(yQdFWqbeLZPy(sIKV36RLASmrcLd3FQUDHDvkxOsGvkPrLVC9n(Vw9CkHkHn6gmlg1dLtB(sar5CkMVe7lxFHGfkSrg723VVVn7ReifLacwtShFie8WMVequoNI5ljs(k9mMVC9LAcUSoeLZPy(2KV8DgOnJ28fqBk9YtL28vxpYsagarUpWDaTyLsAubqFG2iCmeojqlHeoPKgfmRFOZQMkWxU(YEqT0ukHgtvxkChPBkFOrbwPKgv(Y1xY8v9MaSUED4UKEcUSU6nbeLZPy(2SVNp7ljs(ERVwQXYeG11Rd3L0tWLjWkL0OYxU(g)xREoLqLWgDdMfJ6HYPnFjGOCofZxIbAZOnFb0MsV8uPnF11JSeGbqKtbUdOfRusJka6d0gHJHWjbAjKWjL0OGz9dDw1ub(Y1x2dQLMsjAGeMI1))eJ6PceyLsAu5lxFjZxfkbsrjOqMHWPc6CEWsjywgB4BZ889((Y13B9fcwi1ddqrk9YtL28fRtbX6ehwGvkPrLVKi5leSqQhgGIu6LNkT5lwNcI1joSaRusJkF56B8FT65uI84JPo8bdfquoNI5lXaTz0MVaAtPxEQ0MV66rwcWaiYnbChqlwPKgva0hOnchdHtc0siHtkPrrQuSoeLZP8LRVqWcf2iJD77333M9vcKIsabRj2JpecEyZxcikNtXaAZOnFb0MsV8uPnF11JSeGbqe6iWDaTyLsAubqFG2iCmeojqlHeoPKgfmRFOZQMkWxU(sMVX)1QNtjYJpM6Whmuar5CkMVn77z(5ljs(ERVwQXYejuoC)P62f2vPCHkbwPKgv(Y134)A1ZPeQe2OBWSyupuoT5lbeLZPy(sSVKi5R0Zy(Y1xQj4Y6quoNI5Bt(E(uG2mAZxaTSRm2qJD7c7GfNhAxHbmaIekaUdOfRusJka6d0gHJHWjbAjKWjL0OivkwhIY5u(Y1xY8vHPD1Zs1vymdlSj2yQaFjrYxyoQosaltKkftar5CkMVnXZ3Z33xIbAZOnFb0YUYydn2TlSdwCEODfgWaiYjkWDaTyLsAubqFG2iCmeojql7b1stPehGmduJDecEyZxcSsjnQ8LejFzpOwAkLGWRtB0yN9AcyzcSsjnQ8LRV36ReifLGWRtB0yN9Acyz9lq5S(rjapaANYqie8W6dfql7b1stPeeEDAJg7SxtaldODkdHqWdRpYYOAsdbApd0MrB(cOLsJSRimPmG2PmecbpSEG(Lsnq7zadWaApGy8LLsd4oaICg4oG2mAZxaThVnFb0IvkPrfa9bmaIWhWDaTz0MVaAH5WWUctfqlwPKgva0hWaic)bUdOnJ28fqlLgzxryszaTyLsAubqFadGi3h4oGwSsjnQaOpqBgT5lG2ekhU)uD7c7kmvaTr4yiCsG2B91snwMGbkl)vpiHbFynkWkL0OcO9aIXxwkTUnYiql)bmaICkWDaTyLsAubqFG2)aOLH2qb0gHJHWjbAn4unqtyNfxjRdYWUeifLVC9LmFn4unqtyNfX)1QNtjuGW0MV89M779p1xE(YpFjgOvHSiCoS5lG2BeHudMgY8n91Gt1anMVX)1QNtfIVQHWOqLVsH99(Nk89URH5lNK5B86zy5BY8fSUEDyF58WgmF)Y37FQVmm(LYxjqiZ8ngoQrwi(kbA(ELmFT)9voRW(gvqFrkkmAmFT33GHa6B6B8FT65uc6kuGW0MV8vneg2d9DkMHPs47nGY3XiN5lHudI(ELmFR3xikNtPqOVq0aHLVNdXxuZqFHObclF5N4ubqlHe2RugbAn4unqRFUZcxrG2mAZxaTes4KsAeOLqQbXoQziql)eNc0si1Giq7zadGi3eWDaTyLsAubqFG2)aOLH2qb0MrB(cOLqcNusJaTesyVszeO1Gt1aToFDw4kc0gHJHWjbAn4unqty8jUswhKHDjqkkF56lz(AWPAGMW4te)xREoLqbctB(Y3BUV3)uF55l)8LyGwcPge7OMHaT8tCkqlHudIaTNbmaIqhbUdOfRusJka6d0(haTm0gkG2iCmeojq7T(AWPAGMWolUswhKHDjqkkF56RbNQbAcJpXvY6GmSlbsr5ljs(AWPAGMW4tCLSoid7sGuu(Y1xY8LmFn4unqty8jI)RvpNsOaHPnF5lT81Gt1anHXNqcKIQRaHPnF5lX(sh8LmFplo1xA7RbNQbAcJpXvY6sGuu(sSV0bFjZxcjCsjnkm4unqRZxNfUI(sSVe7BZ(sMVK5RbNQbAc7Si(Vw9CkHceM28LV0Yxdovd0e2zHeifvxbctB(YxI9Lo4lz(EwCQV02xdovd0e2zXvY6sGuu(sSV0bFjZxcjCsjnkm4unqRFUZcxrFj2xIbAvilcNdB(cO9gXSronK5B6RbNQbAmFjKAq0xPW(gF5JeovGV2f6B8FT65u((u(AxOVgCQgOfIVQHWOqLVsH91UqFvGW0MV89P81UqFLaPO8DmFpGpHrHmHVenMmFtFzgeRa7Yx5xnudc91EFdgcOVPVxtWfc99aopCSW(AVVmdIvGD5RbNQbASq8nz(Yb1AFtMVPVYVAOge6l1d9DO8n91Gt1anF5mATVp0xoJw7B9MVSWv0xoJD5B8FT65umbqlHe2RugbAn4unqRFaNhowyG2mAZxaTes4KsAeOLqQbXoQziq7zGwcPgebA5dWaisOa4oGwSsjnQaOpq7Fa0YqdOnJ28fqlHeoPKgbAjKAqeO1snwMiHYH7pv3UWUkLlujWkL0OYxU(g)sboMi(fHpM28v)P62f2vyQeyLsAub0Qqweoh28fq7nIqQbtdz(gbHqSmFzObE4l1d91UqFdvWSSXc77t5lr)4JPo8bd99K05n0xKIcJgdOLqc7vkJaTuGADpQGagarorbUdOfRusJka6d0(haTm0aAZOnFb0siHtkPrGwcPgebAHGfs9WauOW0Uy9icTCklSaRusJkF56leSqQhgGcykFKL1nywmkeIvefyLsAub0siH9kLrGwvSdnadWaAHzCsnd4oaICg4oGwSsjnQaOpqBgT5lG2egZc72dHyzaTkKfHZHnFb0EdZ4KAgqBeogcNeOfcwtSF8CqOqHutCmFB23B6uF56lz(EGMiiHbFynkYOneqFjrY3B91snwMGbkl)vpiHbFynkWkL0OYxI9LRVqWcfkKAIJ5BZ889uadGi8bChqlwPKgva0hOnchdHtc0siHtkPrHCgkFyp(Vw9CkwpJ2qa9LejFpqteKWGpSgfz0gcOVC99anrqcd(WAuar5CkMVnXZxjqkkHK(FvNcegwOaHPnF5ljs(k9mMVC9LAcUSoeLZPy(2epFLaPOes6)vDkqyyHceM28fqBgT5lGwj9)QofimmGbqe(dChqlwPKgva0hOnchdHtc0siHtkPrHCgkFyp(Vw9CkwpJ2qa9LejFpqteKWGpSgfz0gcOVC99anrqcd(WAuar5CkMVnXZxjqkkHecziSXubcfimT5lFjrYxPNX8LRVutWL1HOCofZ3M45ReifLqcHme2yQaHceM28fqBgT5lGwjeYqyJPcamaICFG7aAXkL0OcG(aTr4yiCsGwjqkkbyD96WDMbXkWUeGhaTz0MVaA1tWLX6HsqvGmwgGbqKtbUdOfRusJka6d0MrB(cOnRiYmyQ7XuRbAvilcNdB(cOLOxrKzWu77jtT23yw(AWjiaH(EFFpEdlBsTVsGuuSq8fZ4LV6Kztf475t9LHXVumHV342ONtmQ89kHkFJVcv(AJm6BY8n91Gtqac91EFBG4HVJ5letvkPrbqBeogcNeOLqcNusJc5mu(WE8FT65uSEgTHa6ljs(EGMiiHbFynkYOneqF567bAIGeg8H1OaIY5umFBINVNp1xsK8v6zmF56l1eCzDikNtX8TjE(E(uadGi3eWDaTyLsAubqFG2iCmeojqBgTHa2XcLhK5BZ88LpFjrYxY8fcwOqHutCmFBMNVN6lxFHG1e7hphekui1ehZ3M557nXpFjgOnJ28fqBcJzH9dqndbmaIqhbUdOfRusJka6d0gHJHWjbAjKWjL0OqodLpSh)xREofRNrBiG(sIKVhOjcsyWhwJImAdb0xU(EGMiiHbFynkGOCofZ3M45ReifLGAGOK(FLqbctB(YxsK8v6zmF56l1eCzDikNtX8TjE(kbsrjOgikP)xjuGW0MVaAZOnFb0snqus)VcWaisOa4oGwSsjnQaOpqBeogcNeOnJ2qa7yHYdY8LNVN9LRVK5ReifLaSUED4oZGyfyxcWdFjrYxPNX8LRVutWL1HOCofZ3M89uFjgOnJ28fqRug0FQUbNydgGbyaTbyHWj2ZhbUdGiNbUdOfRusJka6d0YWiqB8FT65uc2dQ7qmpqOaIY5umG2mAZxaTCYXaAJWXq4KaTwQXYeShu3HyEGqbwPKgv(Y1xlHbOjSrg723pIwN)N6Bt(EQVC9LAcUSoeLZPy(2SVN6lxFJ)RvpNsWEqDhI5bcfquoNI5Bt(sMVbrLV0bF5NGoEQVe7lxFZOneWowO8GmFBINV8hWaicFa3b0IvkPrfa9bAJWXq4KaTK57T(siHtkPrXX)6Pc6qWAI9JNdc9LejFLaPOemqLcRU6FzbeZO5lX(Y1xY8vcKIsOsyJUbZIr9q50MVeGh(Y1xiyHupmafkmv6bzwp(JwGvkPrLVC9nJ2qa7yHYdY8TjE(YFFjrY3mAdbSJfkpiZxE(YNVed0MrB(cOvHPD1J)ObmaIWFG7aAXkL0OcG(aTr4yiCsGwjqkkbduPWQR(xwaXmA(sIKV36lHeoPKgfh)RNkOdbRj2pEoieOnJ28fqlEmkuEIagarUpWDaTyLsAubqFGwfYIW5WMVaAVbu(AjmanFJHJ6Pc8Dy(QgwkPrvi(Y4mw8YxPm2Wx791UqFztfOXtGLWa08naleorF1dZ8DkMHPsa0MrB(cOfcw9mAZxD9WmGwMbNObqKZaTr4yiCsG2y4Og7yHYdY8LNVNbA1dZ6vkJaTbyHWjcyae5uG7aAXkL0OcG(aTz0MVaA58GLQZoWsHqG2iCmeojqlz(g)xREoLip(yQdFWqbeLZPy(2SVN6lxFvOeifLGczgcNkOZ5blLa8WxsK8vHsGuuckKziCQGoNhSucMLXg(2SV83xI9LRVK5l1eCzDikNtX8TjFJ)RvpNsOW0U6zP6kmMHfquoNI5lT99m)8LejFPMGlRdr5CkMVn7B8FT65uI84JPo8bdfquoNI5lXaTXWrn2TegGgdGiNbmaICta3b0IvkPrfa9bAZOnFb0sHmdHtf0zgCAGaTr4yiCsGwfkbsrjOqMHWPc6CEWsjywgB4Bt88L)(Y134)A1ZPe5XhtD4dgkGOCofZ3M89uFjrYxfkbsrjOqMHWPc6CEWsjywgB4Bt(EgOngoQXULWa0yae5mGbqe6iWDaTyLsAubqFG2mAZxaTuiZq4ubDMbNgiqBeogcNeOn(Vw9CkrE8Xuh(GHcikNtX8TzFp1xU(QqjqkkbfYmeovqNZdwkbZYydFBY3ZaTXWrn2TegGgdGiNbmaIekaUdOfRusJka6d0MrB(cOLczgcNkOZm40abAvilcNdB(cO9URH57W8fPOWOneqDyFPgTgH(Y5AIx(YgzMV05nR13cbnyQdXxjqZx21dQv(Earcyz(M(YIyLW59LZfcrFTl03uP(Y3RK5B921ub(AVVqm(YYyPeaTr4yiCsG2mAdbSREtqHmdHtf058GLY3M55BmCuJDSq5bz(Y1xfkbsrjOqMHWPc6CEWsjywgB4Bt(EFadWaAvivcQnG7aiYzG7aAZOnFb0kpLQtbr8eJaTyLsAubqFadGi8bChqlwPKgva0hO9paAzOb0MrB(cOLqcNusJaTesnic0sMVyOcohhOsmflcbTusJ9qfmlduURqcte9LejFXqfCooqLWUWo1azwNnbJ2xsK8fdvW54avINac5CHA5Pc6hphe2JWWml1(sSVC9LmFJ)RvpNsmflcbTusJ9qfmlduURqctefqmvH9LejFJ)RvpNsyxyNAGmRZMGrlGOCofZxsK8n(Vw9CkXtaHCUqT8ub9JNdc7ryyMLAbeLZPy(sSVKi5lz(IHk4CCGkHDHDQbYSoBcgTVKi5lgQGZXbQepbeY5c1Ytf0pEoiShHHzwQ9LyF56lgQGZXbQetXIqqlL0ypubZYaL7kKWerGwfYIW5WMVaAVzqKawMVSdmoudQ81Gt1anMVs4ub(cYqLVCg7Y3e0E50MOV6PqgqlHe2RugbAzhyCOgu1n4unqdWaic)bUdOfRusJka6d0(haTm0aAZOnFb0siHtkPrGwcPgebAJ)RvpNsWaLL)QhKWGpSgfquoNI5Bt(EQVC91snwMGbkl)vpiHbFynkWkL0OYxU(sMVwQXYeG11Rd3L0tWLjWkL0OYxU(g)xREoLaSUED4UKEcUmbeLZPy(2KVN5VVC9n(Vw9CkHkHn6gmlg1dLtB(sar5CkwhP7bgnu5Bt(EM)(sIKV36RLASmbyD96WDj9eCzcSsjnQ8LyGwcjSxPmc0E8VEQGoeSMy)45GqadGi3h4oGwSsjnQaOpq7Fa0YqdOnJ28fqlHeoPKgbAjKAqeO1snwMG9G6oeZdekWkL0OYxU(cbl03M8LpF56RLWa0e2iJD77hrRZ)t9TjFp1xU(snbxwhIY5umFB23t9LejFJpbSYYe1eCzDQe9LRVwQXYekKA0OaRusJkF56B8FT65ucfsnAuar5CkMVn5leSqHnYy3(oFaTesyVszeO94F9ubDiyHmadGiNcChqlwPKgva0hO9paAzOb0MrB(cOLqcNusJaTesnic0MrBiGDSq5bz(YZ3Z(Y1xY89wFH5O6ibSmrQumbs3HzmFjrYxyoQosaltKkftmLVn775t9LyGwcjSxPmc0YS(HoRAQaadGi3eWDaTyLsAubqFG2)aOLHgqBgT5lGwcjCsjnc0si1GiqBgTHa2XcLhK5BZ88LpF56lz(ERVWCuDKawMivkMaP7WmMVKi5lmhvhjGLjsLIjq6omJ5lxFjZxyoQosaltKkftar5CkMVn77P(sIKVutWL1HOCofZ3M99m)8LyFjgOLqc7vkJaTPsX6quoNcWaicDe4oGwSsjnQaOpq7Fa0YqdOnJ28fqlHeoPKgbAjKAqeOLmFTuJLjyGYYF1dsyWhwJcSsjnQ8LRV367bAIGeg8H1OiJ2qa9LRVX)1QNtjyGYYF1dsyWhwJcikNtX8LejFV1xl1yzcgOS8x9Geg8H1OaRusJkFj2xU(sMVsGuucW661H7jJLGAtaE4ljs(APgltKq5W9NQBxyxLYfQeyLsAu5lxFpqtKhFShC9GArgTHa6ljs(kbsrjujSr3GzXOEOCAZxcWdF56ReifLqLWgDdMfJ6HYPnFjGOCofZ3M99uFjrY3mAdbSJfkpiZ3M55lF(Y1xfM2vplvxHXmSWMyJPc8LyGwcjSxPmc0kNHYh2J)RvpNI1ZOneqadGiHcG7aAXkL0OcG(aT)bqldnG2mAZxaTes4KsAeOLqQbrG24taRSmrnbxwNkrF56Rct7QNLQRWygwytSXub(Y1xjqkkHct7I1vGOGzzSHVn5799LejFLaPOeYje(CqvpaLz2xyhRRSIOmwMa8WxsK8vcKIsyxWrR7meBGqb4HVKi5ReifLGcI1jEqvx(lMbF2yHfGh(sIKVsGuucnMQUu4os3u(qJcWdFjrYxjqkkr8kFwxkluaE4ljs(g)xREoLaSUED4EYyjO2equoNI5Bt(EQVC9n(Vw9CkrE8Xuh(GHcikNtX8TzFpZpGwcjSxPmc0QaLp6CEWsXamaICIcChqlwPKgva0hOnJ28fq7dAsqmBa0Qqweoh28fq7n25uwo1ub(EJzGGASmFVz6mae9Dy(M(EaNhowyG2iCmeojqR6nbHbcQXY6h6maefqKcISRusJ(Y13B91snwMaSUED4UKEcUmbwPKgv(Y13B9fMJQJeWYePsXeiDhMXamaICMFa3b0IvkPrfa9bAZOnFb0(GMeeZgaTr4yiCsGw1BccdeuJL1p0zaikGifezxPKg9LRVz0gcyhluEqMVnZZx(8LRVK57T(APgltawxVoCxspbxMaRusJkFjrYxl1yzcW661H7s6j4YeyLsAu5lxFjZ34)A1ZPeG11Rd3L0tWLjGOCofZ3M9LmFpFQV0Y3mAdbSJfkpiZxA7R6nbHbcQXY6h6maefquoNI5lX(sIKVz0gcyhluEqMVnZZx(7lX(smqBmCuJDlHbOXaiYzadGiNpdChqlwPKgva0hOnJ28fq7dAsqmBa0QNc7rfq7nb0gHJHWjbAZOneWU6nbHbcQXY6h6mae9TjFZOneWowO8GmF56BgTHa2XcLhK5BZ88LpF56lz(ERVwQXYeG11Rd3L0tWLjWkL0OYxsK8n(Vw9CkbyD96WDj9eCzcikNtX8LRVsGuucW661H7s6j4Y6sGuuc1ZP8LyGwfYIW5WMVaAVbu(Axie9nHOVyHYdY8vEySPc89gZnleFZJdDyFhZxYKanFR3x5hI(Axz57xr03de67n5ldJFPyelamaICMpG7aAXkL0OcG(aTr4yiCsGwiyHupmafmWdeYmyoLaRusJkF56lz(QEtqbFM1PqciuarkiYUsjn6ljs(QEtiP)x1p0zaikGifezxPKg9LyG2mAZxaTpOjbXSbGbqKZ8h4oGwSsjnQaOpqBgT5lGwopyP6SdSuieOvHSiCoS5lG2Bisbr2fY8LoX0Uy(sNGi5mFLaPO8nucYmFLqQhI(QW0Uy(QarFXsXaAJWXq4KaTXNawzzIAcUSovI(Y1xfM2vplvxHXmSWMyJPc8LRVK5Rct7QNLQRWygwKrBiGDikNtX8TjFjZ3GOYx6GVNfN6lX(sIKVsGuucfM2fRRarbeLZPy(2KVbrLVedyae589bUdOfRusJka6d0YWiqB8FT65uc2dQ7qmpqOaIY5umG2mAZxaTCYXaAJWXq4KaTwQXYeShu3HyEGqbwPKgv(Y1xlHbOjSrg723pIwN)N6Bt(EQVC91syaAcBKXU9D1G(2SVN6lxFJ)RvpNsWEqDhI5bcfquoNI5Bt(sMVbrLV0bF5NGoEQVe7lxFZOneWowO8GmF557zadGiNpf4oGwSsjnQaOpqRczr4CyZxaTeT5y(s9qFPtmTlYz(sNGiTOtKA0OVdLVezcUmFjAMOV27BaA(Ymiwb2LVsGuu(kLXg(MS8aOLHrG24)A1ZPekmTlwxbIcikNtXaAZOnFb0YjhdOnchdHtc0gFcyLLjQj4Y6uj6lxFJ)RvpNsOW0UyDfikGOCofZ3M8niQ8LRVz0gcyhluEqMV889mGbqKZ3eWDaTyLsAubqFGwggbAJ)RvpNsOqQrJcikNtXaAZOnFb0YjhdOnchdHtc0gFcyLLjQj4Y6uj6lxFJ)RvpNsOqQrJcikNtX8TjFdIkF56BgTHa2XcLhK5lpFpdyae5mDe4oGwSsjnQaOpqRczr4CyZxaTe9OnF5lrnmJ5BwkFpHhyHqMVKDcpWcHmA1IHkiwrK5lyXapoEOHkFNY3uP(sqmqBgT5lG2yQ19mAZxD9WmGw9WSELYiqRbNQbAmadGiNdfa3b0IvkPrfa9bAZOnFb0gtTUNrB(QRhMb0QhM1RugbAJpbSYYyagaroFIcChqlwPKgva0hOnJ28fqBm16EgT5RUEygqREywVszeOfMXj1madGi8XpG7aAXkL0OcG(aTz0MVaAJPw3ZOnF11dZaA1dZ6vkJaTX)1QNtXamaIW3zG7aAXkL0OcG(aTr4yiCsGwcjCsjnksLI1HOCoLVC9LmFJ)RvpNsOW0U6zP6kmMHfquoNI5Bt(EMF(Y13B91snwMqHuJgfyLsAu5ljs(g)xREoLqHuJgfquoNI5Bt(EMF(Y1xl1yzcfsnAuGvkPrLVKi5B8jGvwMOMGlRtLOVC9n(Vw9CkHct7I1vGOaIY5umFBY3Z8ZxI9LRV36Rct7QNLQRWygwytSXubaTz0MVaAHGvpJ28vxpmdOvpmRxPmc0Mp2zObEayaeHp(aUdOfRusJka6d0gHJHWjbAZOneWowO8GmFBMNV85lxFvyAx9SuDfgZWcBInMkaOLzWjAae5mqBgT5lGwiy1ZOnF11dZaA1dZ6vkJaT5JDjqiZamaIWh)bUdOfRusJka6d0gHJHWjbAZOneWowO8GmFBMNV85lxFV1xfM2vplvxHXmSWMyJPc8LRVK57T(siHtkPrrQuSoeLZP8LejFJ)RvpNsOW0U6zP6kmMHfquoNI5BZ(EMF(Y13B91snwMqHuJgfyLsAu5ljs(g)xREoLqHuJgfquoNI5BZ(EMF(Y1xl1yzcfsnAuGvkPrLVKi5B8jGvwMOMGlRtLOVC9n(Vw9CkHct7I1vGOaIY5umFB23Z8ZxIbAZOnFb0cbREgT5RUEygqREywVszeOnaleoXE(iGbqe(UpWDaTyLsAubqFG2iCmeojqBgTHa2XcLhK5lpFpd0MrB(cOnMADpJ28vxpmdOvpmRxPmc0gGfcNiGbyaTX)1QNtXaUdGiNbUdOfRusJka6d0gHJHWjbAjKWjL0OqodLpSh)xREofRNrBiG(sIKVhOjcsyWhwJImAdb0xU(EGMiiHbFynkGOCofZ3M45lF3KVKi5R0Zy(Y1xQj4Y6quoNI5Bt(Y3nb0MrB(cO94T5ladGi8bChqlwPKgva0hOnchdHtc0g)xREoLqLWgDdMfJ6HYPnFjGOCofRJ09aJgQ8TjFPJ(Y1xY8n(Vw9CkbyD96WDj9eCzcikNtX8TjFPJ(Y1xl1yzcW661H7s6j4YeyLsAu5ljs(ERVwQXYeG11Rd3L0tWLjWkL0OYxI9LRVK5ldTU0xGmHniKVqr)(hrF56RLWa0e2iJD77hrRZ)t9TjFVVVKi57T(YqRl9fitydc5lu0V)r0xsK8LAcUSoeLZPy(2SV8Xp(5lX(Y1xY8n(Vw9Ckrk9YtL28vxpYscikNtX8TjFphk8LRVK5leSqQhgGIu6LNkT5lwNcI1joSaRusJkFjrYx2dQLMsjAGeMI1))eJ6PceyLsAu5lX(sIKV36leSqQhgGIu6LNkT5lwNcI1joSaRusJkF567T(YEqT0ukrdKWuS()NyupvGaRusJkFj2xU(sMVX)1QNtjYJpM6Whmuar5CkwhP7bgnu5Bt(sh9LRVes4KsAuqbQ19Oc6ljs(ERVes4KsAuqbQ19Oc6ljs(siHtkPrHk2HMVe7ljs(k9mMVC9LAcUSoeLZPy(2KV8)uG2mAZxaTjuoC)P62f2vyQamaIWFG7aAXkL0OcG(aTz0MVaAzpOUdX8aHaTr4yiCsGwlHbOjSrg723pIwN)N6Bt(EQVC9LmFTegGMWgzSBFxnOVn77P(Y13mAdbSJfkpiZ3M45l)9LejFzO1L(cKjSbH8fk63)i6lxFLaPOeQe2OBWSyupuoT5lb4HVC9nJ2qa7yHYdY8TjE(EQVC9LmFV1xfM2vplvxHXmSWMyJPc8LejFJpbSYYe1eCzDQe9LyFjgOngoQXULWa0yae5mGbqK7dChqlwPKgva0hOnJ28fqlyD96WDj9eCzaTkKfHZHnFb0s04RvmFPVEcUmFPEOVGh(AVVN6ldJFPy(AVVSWv0xoJD5lr)4JPo8bddX3tODHqodddXxqg6lNXU8LotydFVdMfJ6HYPnFjaAJWXq4KaTes4KsAuWS(HoRAQaF56lz(g)xREoLip(yQdFWqbeLZPyDKUhy0qLVn57P(sIKVX)1QNtjYJpM6Whmuar5CkwhP7bgnu5BZ(EMF(sSVC9LmFJ)RvpNsOsyJUbZIr9q50MVequoNI5Bt(gev(sIKVsGuucvcB0nywmQhkN28La8WxIbmaICkWDaTyLsAubqFG2iCmeojqlHeoPKgfPsX6quoNYxsK8v6zmF56l1eCzDikNtX8TjF57mqBgT5lGwW661H7s6j4YamaICta3b0IvkPrfa9bAJWXq4KaTes4KsAuWS(HoRAQaF56lz(QEtawxVoCxspbxwx9MaIY5umFjrY3B91snwMaSUED4UKEcUmbwPKgv(smqBgT5lGwvcB0nywmQhkN28fGbqe6iWDaTyLsAubqFG2iCmeojqlHeoPKgfPsX6quoNYxsK8v6zmF56l1eCzDikNtX8TjF57mqBgT5lGwvcB0nywmQhkN28fGbqKqbWDaTyLsAubqFG2iCmeojqBgTHa2XcLhK5lpFp7lxFvOeifLGczgcNkOZ5blLGzzSHVnZZ377lxFjZ3B9LqcNusJckqTUhvqFjrYxcjCsjnkOa16Eub9LRVK5B8FT65ucW661H7s6j4YequoNI5BZ(EMF(sIKVX)1QNtjujSr3GzXOEOCAZxcikNtX6iDpWOHkFB23Z8ZxU(ERVwQXYeG11Rd3L0tWLjWkL0OYxI9LyG2mAZxaT5XhtD4dgcyae5ef4oGwSsjnQaOpqBgT5lG284JPo8bdbAJWXq4KaTz0gcyhluEqMVnZZx(8LRVkucKIsqHmdHtf058GLsWSm2W3M55799LRV36Rct7QNLQRWygwytSXubaTXWrn2TegGgdGiNbmaICMFa3b0IvkPrfa9bAJWXq4KaTqWAI9JNdcfkKAIJ5Bt(E(((Y134)A1ZPeG11Rd3L0tWLjGOCofZ3M89m)9LRVX)1QNtjujSr3GzXOEOCAZxcikNtX6iDpWOHkFBY3Z8hOnJ28fqlduw(REqcd(WAeWaiY5Za3b0IvkPrfa9bAJWXq4KaTes4KsAuWS(HoRAQaF56RcLaPOeuiZq4ubDopyPemlJn8TjF5ZxU(sMVhOjYJp2dUEqTiJ2qa9LejFLaPOeQe2OBWSyupuoT5lb4HVC9n(Vw9CkrE8Xuh(GHcikNtX8TzFpZpFjrY34)A1ZPe5XhtD4dgkGOCofZ3M99m)8LRVX)1QNtjujSr3GzXOEOCAZxcikNtX8TzFpZpFjgOnJ28fqlyD96W9KXsqTbyae5mFa3b0IvkPrfa9bAZOnFb0cwxVoCpzSeuBaTr4yiCsG2mAdbSJfkpiZ3M55lF(Y1xfkbsrjOqMHWPc6CEWsjywgB4Bt(YNVC9LmFpqtKhFShC9GArgTHa6ljs(kbsrjujSr3GzXOEOCAZxcWdFjrY34)A1ZPekmTREwQUcJzybeLZPy(2KVbrLVed0gdh1y3syaAmaICgWaiYz(dChqlwPKgva0hOnchdHtc0ERVhOjcUEqTiJ2qabAZOnFb0cZHHDfMkadWamGwciKnFbqe(4hF8Xp(4Jokod0YjH1ubmGwIwI(nKi3aICIeAF99Ul03r(4HMVup0xYZh7m0api3xigQGdev(YEz03e0E50qLVXRScqMWPHOMc99CO99KFraHgQ8LCl1yzc6rUV27l5wQXYe0tGvkPrf5(s2z6sSWPHOMc9LVq77j)Iacnu5l5qWcPEyakOh5(AVVKdblK6HbOGEcSsjnQi3xYotxIfone1uOV3uO99KFraHgQ8LCl1yzc6rUV27l5wQXYe0tGvkPrf5(sgF0LyHtJtdrlr)gsKBarorcTV(E3f67iF8qZxQh6l55JDjqiZi3xigQGdev(YEz03e0E50qLVXRScqMWPHOMc9L)H23t(fbeAOYxYTuJLjOh5(AVVKBPgltqpbwPKgvK7lz8NUelCAiQPqFVFO99KFraHgQ8LCiyHupmaf0JCFT3xYHGfs9WauqpbwPKgvK7lzNPlXcNgNgIwI(nKi3aICIeAF99Ul03r(4HMVup0xYn4unqJrUVqmubhiQ8L9YOVjO9YPHkFJxzfGmHtdrnf675q77j)Iacnu5l5wQXYe0JCFT3xYTuJLjONaRusJkY9LSZ0LyHtdrnf67PH23t(fbeAOYxYn4unqtCwqpY91EFj3Gt1anHDwqpY9Lm(txIfone1uOVNgAFp5xeqOHkFj3Gt1anbFc6rUV27l5gCQgOjm(e0JCFjJp6sSWPHOMc99McTVN8lci0qLVKBWPAGM4SGEK7R9(sUbNQbAc7SGEK7lz8rxIfone1uOV3uO99KFraHgQ8LCdovd0e8jOh5(AVVKBWPAGMW4tqpY9Lm(txIfone1uOV0Xq77j)Iacnu5l5gCQgOjolOh5(AVVKBWPAGMWolOh5(s2z6sSWPHOMc9LogAFp5xeqOHkFj3Gt1anbFc6rUV27l5gCQgOjm(e0JCFjJp6sSWPHOMc9nueAFp5xeqOHkFj3Gt1anXzb9i3x79LCdovd0e2zb9i3xY4JUelCAiQPqFdfH23t(fbeAOYxYn4unqtWNGEK7R9(sUbNQbAcJpb9i3xYotxIfononeTe9BirUbe5ej0(67DxOVJ8XdnFPEOVKhGfcNi5(cXqfCGOYx2lJ(MG2lNgQ8nELvaYeone1uOVNdTVN8lci0qLVKdblK6HbOGEK7R9(soeSqQhgGc6jWkL0OICFj7mDjw40qutH(YxO99KFraHgQ8LCl1yzc6rUV27l5wQXYe0tGvkPrf5(s2z6sSWPHOMc9LVq77j)Iacnu5l5qWcPEyakOh5(AVVKdblK6HbOGEcSsjnQi3xYotxIfone1uOV8fAFp5xeqOHkFjp(LcCmb9i3x79L84xkWXe0tGvkPrf5(s2z6sSWPHOMc9L)H23t(fbeAOYxYHGfs9WauqpY91EFjhcwi1ddqb9eyLsAurUVKDMUelCAiQPqFpn0(EYViGqdv(soeSqQhgGc6rUV27l5qWcPEyakONaRusJkY9LSZ0LyHtJtdrlr)gsKBarorcTV(E3f67iF8qZxQh6l5XNawzzmY9fIHk4arLVSxg9nbTxonu5B8kRaKjCAiQPqFphAFp5xeqOHkFj3snwMGEK7R9(sULASmb9eyLsAurUVKDMUelCAiQPqF5FO99KFraHgQ8LCl1yzc6rUV27l5wQXYe0tGvkPrf5(s2z6sSWPHOMc9L)H23t(fbeAOYxYzpOwAkLGEK7R9(so7b1stPe0tGvkPrf5(s2z6sSWPHOMc99(H23t(fbeAOYxYTuJLjOh5(AVVKBPgltqpbwPKgvK7lzNPlXcNgIAk037hAFp5xeqOHkFjN9GAPPuc6rUV27l5ShulnLsqpbwPKgvK7lzNPlXcNgIAk03tdTVN8lci0qLVKdblK6HbOGEK7R9(soeSqQhgGc6jWkL0OICFjJp6sSWPHOMc990q77j)Iacnu5l5ShulnLsqpY91EFjN9GAPPuc6jWkL0OICFj7mDjw40qutH(shdTVN8lci0qLVKBPgltqpY91EFj3snwMGEcSsjnQi3xYotxIfone1uOVNOH23t(fbeAOYxYzpOwAkLGEK7R9(so7b1stPe0tGvkPrf5(sgF0LyHtJtdrlr)gsKBarorcTV(E3f67iF8qZxQh6l5hqm(YsPrUVqmubhiQ8L9YOVjO9YPHkFJxzfGmHtdrnf679dTVN8lci0qLVKBPgltqpY91EFj3snwMGEcSsjnQi33089gDcjkFj7mDjw40qutH(EAO99KFraHgQ8TDKpPVSWLL013B(n3x79LOatFLFfOgK57FGW0EOVKDZj2xYotxIfone1uOVNgAFp5xeqOHkFj3Gt1anXzb9i3x79LCdovd0e2zb9i3xY4JUelCAiQPqFVPq77j)Iacnu5B7iFsFzHllPRV38BUV27lrbM(k)kqniZ3)aHP9qFj7MtSVKDMUelCAiQPqFVPq77j)Iacnu5l5gCQgOj4tqpY91EFj3Gt1anHXNGEK7lz8rxIfone1uOV0Xq77j)Iacnu5B7iFsFzHllPRV3CFT3xIcm9vneg28LV)bct7H(sgTi2xY4JUelCAiQPqFPJH23t(fbeAOYxYn4unqtCwqpY91EFj3Gt1anHDwqpY9LS7txIfone1uOV0Xq77j)Iacnu5l5gCQgOj4tqpY91EFj3Gt1anHXNGEK7lzNsxIfone1uOVHIq77j)Iacnu5l5wQXYe0JCFT3xYTuJLjONaRusJkY9LSZ0LyHtdrnf6BOi0(EYViGqdv(sE8lf4yc6rUV27l5XVuGJjONaRusJkY9nnFVrNqIYxYotxIfone1uOVNOH23t(fbeAOYxYHGfs9WauqpY91EFjhcwi1ddqb9eyLsAurUVP57n6esu(s2z6sSWPHOMc99en0(EYViGqdv(soeSqQhgGc6rUV27l5qWcPEyakONaRusJkY9LSZ0LyHtJtdrlr)gsKBarorcTV(E3f67iF8qZxQh6l5X)1QNtXi3xigQGdev(YEz03e0E50qLVXRScqMWPHOMc9LVq77j)Iacnu5l5wQXYe0JCFT3xYTuJLjONaRusJkY9Lm(OlXcNgIAk0x(cTVN8lci0qLVKdblK6HbOGEK7R9(soeSqQhgGc6jWkL0OICFjJp6sSWPHOMc9LVq77j)Iacnu5l5ShulnLsqpY91EFjN9GAPPuc6jWkL0OICFjJp6sSWPHOMc99McTVN8lci0qLVKBPgltqpY91EFj3snwMGEcSsjnQi3xYotxIfone1uOVHIq77j)Iacnu5l5wQXYe0JCFT3xYTuJLjONaRusJkY9LSZ0LyHtJtdrlr)gsKBarorcTV(E3f67iF8qZxQh6l5byHWj2Zhj3xigQGdev(YEz03e0E50qLVXRScqMWPHOMc99CO99KFraHgQ8LCl1yzc6rUV27l5wQXYe0tGvkPrf5(s2z6sSWPHOMc9LVq77j)Iacnu5l5qWcPEyakOh5(AVVKdblK6HbOGEcSsjnQi3xYotxIfononeTe9BirUbe5ej0(67DxOVJ8XdnFPEOVKRqQeuBK7ledvWbIkFzVm6BcAVCAOY34vwbit40qutH(Y)q77j)Iacnu5l5wQXYe0JCFT3xYTuJLjONaRusJkY9Lm(txIfone1uOV3p0(EYViGqdv(sULASmb9i3x79LCl1yzc6jWkL0OICFjJp6sSWPHOMc9LogAFp5xeqOHkFj3snwMGEK7R9(sULASmb9eyLsAurUVKXF6sSWPHOMc99en0(EYViGqdv(sULASmb9i3x79LCl1yzc6jWkL0OICFj7mDjw40qutH(EMFH23t(fbeAOY32r(K(YcxwsxFV5(AVVefy6RAimS5lF)deM2d9LmArSVKDMUelCAiQPqFpZVq77j)Iacnu5l5wQXYe0JCFT3xYTuJLjONaRusJkY9Lm(OlXcNgIAk03ZNdTVN8lci0qLVKBPgltqpY91EFj3snwMGEcSsjnQi3xYotxIfone1uOVN5l0(EYViGqdv(soeSqQhgGc6rUV27l5qWcPEyakONaRusJkY9LSZ0LyHtdrnf6757hAFp5xeqOHkFj3snwMGEK7R9(sULASmb9eyLsAurUVKDMUelCAiQPqF57CO99KFraHgQ8LCl1yzc6rUV27l5wQXYe0tGvkPrf5(sgF0LyHtdrnf6lF8p0(EYViGqdv(sULASmb9i3x79LCl1yzc6jWkL0OICFjJp6sSWPXP5giF8qdv(EMF(MrB(Yx9WmMWPbO9a(uJgbAV398LoX0U8LOHAcUmFVXRRxh2P5E3ZxIMOeemHH9LVqri(Yh)4JpNgNM7DpFp5vwbil0on37E(Ec8LORcLGmtglJ5R9(sNfDsl6ePgnsl6et7I5lDcI(AVVFPd7B8blZxlHbOX8LZ17BcrFr6EGrdv(AVV6Ha6R(RaFX6bdU81EFLtZqOVKLp2zObE479otSWP5E3Z3tGV05WsjnQ8TnJWHAItQ99MLrZxjmMGm0xfMkFdUEqnZx5Sb6l1d9LLkFPtIgycNM7DpFpb(EJZMkWxI2hSu(2EGLcH(MsJESbz(k)q0xkns3rsh2xYsZ37tBFzwgBW8DkMHPY3NY3tPnX3y5lDEZA9TqqdMAFZs5RCg23disalZx2lJ(w)jaIrFzJbM28ft40CV757jW3BC2ub(s0ezgcNkW3wdonqFNYxI(j8g57q5B4h03RKa6B921ub(IAg6R9(QEFZs5lNVi389jGWyE4lNhSumFhMV05nR13cbnyQfon37E(Ec89KxzfGkFLZkSVKtnbxwhIY5umY9n(LAS5RuZ81EFZJdDyFNYxPNX8LAcUmMVFPd7lzAKX89K0PVCsMH((LVgmzxelCAU3989e4lrxPqLVz92fc99ecAsqmB4lwgmSV27ldnFbp8LzWVcqOV3OJrHYtKjCAU3989e47ne1jD9T9oFjWe(s0pH3iF1FWe9Lnve9DmFHOEqMVF5B8lQucuNgQ8fMJQJeWYycNM7DpFpb(E3jKopHH2xFjAMr7H(2AqScSlFpGFK57u27RbNQbA(Q)GjkCACAYOnFXehqm(YsPrBE064T5lNMmAZxmXbeJVSuA0MhTG5WWUctLttgT5lM4aIXxwknAZJwuAKDfHjL50KrB(IjoGy8LLsJ28OvcLd3FQUDHDfMQqoGy8LLsRBJmYJ)Hmu8U1snwMGbkl)vpiHbFyn60CpFVresnyAiZ30xdovd0y(g)xREovi(QgcJcv(kf237FQW37UgMVCsMVXRNHLVjZxW661H9LZdBW89lFV)P(YW4xkFLaHmZ3y4OgzH4ReO57vY81(3x5Sc7Bub9fPOWOX81EFdgcOVPVX)1QNtjORqbctB(Yx1qyyp03PygMkHV3akFhJCMVesni67vY8TEFHOCoLcH(crdew(EoeFrnd9fIgiS8LFItfonz0MVyIdigFzP0OnpAriHtkPXqQug5zWPAGw)CNfUIH8h8yOnuHqi1GiVZHqi1Gyh1mKh)eNgs8l1yZx8m4unqtCwCLSoid7sGuuCjZGt1anXzr8FT65ucfimT5RB(n)(NYJFe70KrB(IjoGy8LLsJ28OfHeoPKgdPszKNbNQbAD(6SWvmK)GhdTHkecPge5DoecPge7OMH84N40qIFPgB(INbNQbAc(exjRdYWUeiffxYm4unqtWNi(Vw9CkHceM281n)MF)t5XpIDAUNV3iMnYPHmFtFn4unqJ5lHudI(kf234lFKWPc81UqFJ)RvpNY3NYx7c91Gt1aTq8vnegfQ8vkSV2f6RceM28LVpLV2f6ReifLVJ57b8jmkKj8LOXK5B6lZGyfyx(k)QHAqOV27BWqa9n99AcUqOVhW5HJf2x79LzqScSlFn4unqJfIVjZxoOw7BY8n9v(vd1GqFPEOVdLVPVgCQgO5lNrR99H(Yz0AFR38LfUI(YzSlFJ)RvpNIjCAYOnFXehqm(YsPrBE0IqcNusJHuPmYZGt1aT(bCE4yHd5p4XqBOcHqQbrE8fcHudIDuZqENdj(LAS5lE3AWPAGM4S4kzDqg2LaPO4AWPAGMGpXvY6GmSlbsrrIKbNQbAc(exjRdYWUeiffxYiZGt1anbFI4)A1ZPekqyAZx3Cdovd0e8jKaPO6kqyAZxethi7S4uABWPAGMGpXvY6sGuuethiJqcNusJcdovd0681zHRiXe3mzKzWPAGM4Si(Vw9CkHceM281n3Gt1anXzHeifvxbctB(Iy6azNfNsBdovd0eNfxjRlbsrrmDGmcjCsjnkm4unqRFUZcxrIj2P5E(EJiKAW0qMVrqielZxgAGh(s9qFTl03qfmlBSW((u(s0p(yQdFWqFpjDEd9fPOWOXCAYOnFXehqm(YsPrBE0IqcNusJHuPmYJcuR7rfmecPge5zPgltKq5W9NQBxyxLYfQ4g)sboMi(fHpM28v)P62f2vyQCAYOnFXehqm(YsPrBE0IqcNusJHuPmYtf7qlecPge5bblK6HbOqHPDX6reA5uwyUqWcPEyakGP8rww3GzXOqiwr0PXP5E3Z3BeDXiOHkFrcimSV2iJ(AxOVz0EOVdZ3Kqo6usJcNMmAZxmEYtP6uqepXOtZ989Mbrcyz(YoW4qnOYxdovd0y(kHtf4lidv(YzSlFtq7LtBI(QNczonz0MVy0MhTiKWjL0yivkJ8yhyCOgu1n4unqlecPge5rggQGZXbQetXIqqlL0ypubZYaL7kKWersKWqfCooqLWUWo1azwNnbJMejmubNJdujEciKZfQLNkOF8CqypcdZSutmxYI)RvpNsmflcbTusJ9qfmlduURqctefqmvHjrk(Vw9CkHDHDQbYSoBcgTaIY5umsKI)RvpNs8eqiNlulpvq)45GWEegMzPwar5CkgXKirggQGZXbQe2f2PgiZ6Sjy0KiHHk4CCGkXtaHCUqT8ub9JNdc7ryyMLAI5IHk4CCGkXuSie0sjn2dvWSmq5Ucjmr0P5E3Z3BmjCsjnYCAYOnFXOnpAriHtkPXqQug5D8VEQGoeSMy)45GWqiKAqKx8FT65ucgOS8x9Geg8H1OaIY5uSMoLRLASmbduw(REqcd(WAKlzwQXYeG11Rd3L0tWLXn(Vw9CkbyD96WDj9eCzcikNtXA6m)5g)xREoLqLWgDdMfJ6HYPnFjGOCofRJ09aJgQA6m)jr6wl1yzcW661H7s6j4Yi2PjJ28fJ28OfHeoPKgdPszK3X)6Pc6qWczHqi1Gipl1yzc2dQ7qmpqixiyHnXhxlHbOjSrg723pIwN)N20PCPMGlRdr5CkwZNsIu8jGvwMOMGlRtLixl1yzcfsnAKB8FT65ucfsnAuar5CkwtqWcf2iJD77850KrB(IrBE0IqcNusJHuPmYJz9dDw1ubHqi1GiVmAdbSJfkpiJ3zUKDlmhvhjGLjsLIjq6omJrIemhvhjGLjsLIjMQ5ZNsSttgT5lgT5rlcjCsjngsLYiVuPyDikNtfcHudI8YOneWowO8GSM5XhxYUfMJQJeWYePsXeiDhMXircMJQJeWYePsXeiDhMX4sgmhvhjGLjsLIjGOCofR5tjrIAcUSoeLZPynFMFetSttgT5lgT5rlcjCsjngsLYip5mu(WE8FT65uSEgTHagcHudI8iZsnwMGbkl)vpiHbFynY92d0ebjm4dRrrgTHaYn(Vw9Ckbduw(REqcd(WAuar5Ckgjs3APgltWaLL)QhKWGpSgjMlzsGuucW661H7jJLGAtaEqIKLASmrcLd3FQUDHDvkxOI7bAI84J9GRhulYOneqsKKaPOeQe2OBWSyupuoT5lb4bxjqkkHkHn6gmlg1dLtB(sar5CkwZNsIugTHa2XcLhK1mp(4QW0U6zP6kmMHf2eBmvaXonz0MVy0MhTiKWjL0yivkJ8uGYhDopyPyHqi1GiV4taRSmrnbxwNkrUkmTREwQUcJzyHnXgtfWvcKIsOW0UyDfikywgB009jrscKIsiNq4Zbv9auMzFHDSUYkIYyzcWdsKKaPOe2fC06odXgiuaEqIKeifLGcI1jEqvx(lMbF2yHfGhKijbsrj0yQ6sH7iDt5dnkapirscKIseVYN1LYcfGhKif)xREoLaSUED4EYyjO2equoNI10PCJ)RvpNsKhFm1HpyOaIY5uSMpZpNM757n25uwo1ub(EJzGGASmFVz6mae9Dy(M(EaNhowyNMmAZxmAZJwpOjbXSridfp1BccdeuJL1p0zaikGifezxPKg5ERLASmbyD96WDj9eCzCVfMJQJeWYePsXeiDhMXCAYOnFXOnpA9GMeeZgHedh1y3syaAmENdzO4PEtqyGGASS(HodarbePGi7kL0i3mAdbSJfkpiRzE8XLSBTuJLjaRRxhUlPNGlJejl1yzcW661H7s6j4Y4sw8FT65ucW661H7s6j4YequoNI1mzNp9MNrBiGDSq5bz0w9MGWab1yz9dDgaIcikNtXiMePmAdbSJfkpiRzE8NyIDAUNV3akFTleI(Mq0xSq5bz(kpm2ub(EJ5MfIV5XHoSVJ5lzsGMV17R8drFTRS89Ri67bc99M8LHXVumIfonz0MVy0MhTEqtcIzJq0tH9OI3nfYqXlJ2qa7Q3eegiOglRFOZaqSPmAdbSJfkpiJBgTHa2XcLhK1mp(4s2TwQXYeG11Rd3L0tWLrIu8FT65ucW661H7s6j4YequoNIXvcKIsawxVoCxspbxwxcKIsOEofXonz0MVy0MhTEqtcIzJqgkEqWcPEyakyGhiKzWCkUKPEtqbFM1PqciuarkiYUsjnsIK6nHK(Fv)qNbGOaIuqKDLsAKyNM757nePGi7cz(sNyAxmFPtqKCMVsGuu(gkbzMVsi1drFvyAxmFvGOVyPyonz0MVy0MhT48GLQZoWsHWqgkEXNawzzIAcUSovICvyAx9SuDfgZWcBInMkGlzkmTREwQUcJzyrgTHa2HOCofRjYcIk6WzXPetIKeifLqHPDX6kquar5CkwtbrfXonz0MVy0MhT4KJfcdJ8I)RvpNsWEqDhI5bcfquoNIfYqXZsnwMG9G6oeZdeY1syaAcBKXU99JO15)PnDkxlHbOjSrg723vd28PCJ)RvpNsWEqDhI5bcfquoNI1ezbrfDGFc64PeZnJ2qa7yHYdY4D2P5E(s0MJ5l1d9LoX0UiN5lDcI0IorQrJ(ou(sKj4Y8LOzI(AVVbO5lZGyfyx(kbsr5RugB4BYYdNMmAZxmAZJwCYXcHHrEX)1QNtjuyAxSUcefquoNIfYqXl(eWkltutWL1PsKB8FT65ucfM2fRRarbeLZPynfevCZOneWowO8GmENDAYOnFXOnpAXjhlegg5f)xREoLqHuJgfquoNIfYqXl(eWkltutWL1PsKB8FT65ucfsnAuar5Ckwtbrf3mAdbSJfkpiJ3zNM75lrpAZx(sudZy(MLY3t4bwiK5lzNWdSqiJwTyOcIvez(cwmWJJhAOY3P8nvQVee70KrB(IrBE0kMADpJ28vxpmlKkLrEgCQgOXCAYOnFXOnpAftTUNrB(QRhMfsLYiV4taRSmMttgT5lgT5rRyQ19mAZxD9WSqQug5bZ4KAMtZ9UNVz0MVy0MhTyyOcIvedzO4LrBiGDSq5bz8oZ9wfM2vVrnbxMqnSusJ98nfxl1yzcgOS8x9Geg8H1yivkJ8csyq)pWcHH(bnjiMncnfYmeovqNzWPbgAkKziCQGoZGtdm0mqz5V6bjm4dRXqNq5W9NQBxyxHPk0kmTRE8hDidfpjqkkbduPWQR(xwaEeAfM2vp(Jo0kmTRE8hDOzXhegGDMbNgyidfpfkbsrjOqMHWPc6CEWsjywgB089dnl(GWaSZm40adzO4PqjqkkbfYmeovqNZdwkbZYyJMVFOPqMHWPc6mdonqNM7DpFZOnFXOnpAXWqfeRigYqXlJ2qa7yHYdY4DM7TkmTREJAcUmHAyPKg75BkU3APgltWaLL)QhKWGpSgdPszK3FGfcdnfYmeovqNzWPbgAkKziCQGoZGtdm0hVnFfAW661H7s6j4YcTkHn6gmlg1dLtB(k05XhtD4dg60KrB(IrBE0kMADpJ28vxpmlKkLrEX)1QNtXCAYOnFXOnpAbbREgT5RUEywivkJ8Yh7m0apczO4riHtkPrrQuSoeLZP4sw8FT65ucfM2vplvxHXmSaIY5uSMoZpU3APgltOqQrJKif)xREoLqHuJgfquoNI10z(X1snwMqHuJgjrk(eWkltutWL1PsKB8FT65ucfM2fRRarbeLZPynDMFeZ9wfM2vplvxHXmSWMyJPcCAYOnFXOnpAbbREgT5RUEywivkJ8Yh7sGqMfcZGt04DoKHIxgTHa2XcLhK1mp(4QW0U6zP6kmMHf2eBmvGttgT5lgT5rliy1ZOnF11dZcPszKxawiCI98XqgkEz0gcyhluEqwZ84J7TkmTREwQUcJzyHnXgtfWLSBjKWjL0OivkwhIY5uKif)xREoLqHPD1Zs1vymdlGOCofR5Z8J7TwQXYekKA0ijsX)1QNtjui1OrbeLZPynFMFCTuJLjui1OrsKIpbSYYe1eCzDQe5g)xREoLqHPDX6kquar5CkwZN5hXonz0MVy0MhTIPw3ZOnF11dZcPszKxawiCIHmu8YOneWowO8GmENDACAU398LO)3iFPpiKzonz0MVyI8XUeiKz8I6KZubD2vQEoSqgkEz0gcyhluEqwt8o1PjJ28ftKp2LaHmJ28OvuNCMkOZUs1ZHfYqXlJ2qa7yHYdY4DtCvyAx9g1eCzckopyPqv3syaASM5XFNMmAZxmr(yxceYmAZJwCEWs1zhyPqyidfpl1yzcjqiZMkOZEiY4sMct7Q3OMGltqX5blfQ6wcdqJXlJ2qa7yHYdYirsHPD1ButWLjO48GLcvDlHbOXAMh)jMejl1yzcjqiZMkOZEiY4APglte1jNPc6SRu9CyCvyAx9g1eCzckopyPqv3syaASM5D2PjJ28ftKp2LaHmJ28OLct7Qh)rhYqXJmjqkkbduPWQR(xwaXmAKiDlHeoPKgfh)RNkOdbRj2pEoiKyUKjbsrjujSr3GzXOEOCAZxcWdUqWcPEyakuyQ0dYSE8hn3mAdbSJfkpiRjE8NePmAdbSJfkpiJhFe70KrB(IjYh7sGqMrBE0cpgfkpXqgkEqWAI9JNdcfkKAIJ1ezN5hTvyAx9g1eCzckopyPqv3syaAm6a)jMRct7Q3OMGltqX5blfQ6wcdqJ10nX9wcjCsjnko(xpvqhcwtSF8CqijssGuucgNekpvqxEyMa8WPjJ28ftKp2LaHmJ28OfEmkuEIHmu8GG1e7hphekui1ehRj(oLRct7Q3OMGltqX5blfQ6wcdqJ18PCVLqcNusJIJ)1tf0HG1e7hphe60KrB(IjYh7sGqMrBE0cpgfkpXqgkE3QW0U6nQj4YeuCEWsHQULWa0yCVLqcNusJIJ)1tf0HG1e7hphesIe1eCzDikNtXA6usKG5O6ibSmrQumbs3HzmUWCuDKawMivkMaIY5uSMo1PjJ28ftKp2LaHmJ28OfNhSuD2bwke60KrB(IjYh7sGqMrBE0cpgfkpXqgkE3siHtkPrXX)6Pc6qWAI9JNdcDACAU398LO)3iFBrd8WPjJ28ftKp2zObEWlRWDvPczO4PW0U6nQj4YeuCEWsHQULWa0ynZlgoQXowO8GmsKuyAx9g1eCzckopyPqv3syaASM5Dkjs3APgltibcz2ubD2drgjsWCuDKawMivkMaP7WmgxyoQosaltKkftar5Ckwt8oFMejPNX4snbxwhIY5uSM4D(SttgT5lMiFSZqd8G28OLct7Qh)rhYqX7wcjCsjnko(xpvqhcwtSF8CqixYKaPOeQe2OBWSyupuoT5lb4bxiyHupmafkmv6bzwp(JMBgTHa2XcLhK1ep(tIugTHa2XcLhKXJpIDAYOnFXe5JDgAGh0MhTWJrHYtmKHI3Tes4KsAuC8VEQGoeSMy)45GqNMmAZxmr(yNHg4bT5rlkKziCQGoZGtdmKy4Og7wcdqJX7CidfpfkbsrjOqMHWPc6CEWsjywgB0ep(Zn(Vw9CkrE8Xuh(GHcikNtXAI)onz0MVyI8XodnWdAZJwuiZq4ubDMbNgyiXWrn2TegGgJ35qgkEkucKIsqHmdHtf058GLsWSm2OPZonz0MVyI8XodnWdAZJwuiZq4ubDMbNgyiXWrn2TegGgJ35qgkEqWcf2iJD773VjYI)RvpNsOW0U6zP6kmMHfquoNIX9wl1yzcfsnAKeP4)A1ZPekKA0OaIY5umUwQXYekKA0ijsXNawzzIAcUSovICJ)RvpNsOW0UyDfikGOCofJyNM75lr7fw(AjmanFzCYdMVje9vnSusJQq81UgMVCgT2xnA(g(b9LDGLYxiyHmAX5blfZ3PygMkFFkF5KJnvGVup0x6SOtArNi1OrArNyAxKZ8LobrHttgT5lMiFSZqd8G28OfNhSuD2bwkegYqXJSBzOztfWeXWrnsIKct7Q3OMGltqX5blfQ6wcdqJ1mVy4Og7yHYdYiMRcLaPOeuiZq4ubDopyPemlJnAM)CHGfkSrg7235FtX)1QNtjYkCxvkbeLZPyonon37E(EZEB(YPjJ28fte)xREofJ3XBZxHmu8iKWjL0OqodLpSh)xREofRNrBiGKiDGMiiHbFynkYOneqUhOjcsyWhwJcikNtXAIhF3ejsspJXLAcUSoeLZPynX3n50CV757j)xREofZPjJ28fte)xREofJ28OvcLd3FQUDHDfMQqgkEX)1QNtjujSr3GzXOEOCAZxcikNtX6iDpWOHQMOJCjl(Vw9CkbyD96WDj9eCzcikNtXAIoY1snwMaSUED4UKEcUmsKU1snwMaSUED4UKEcUmI5sgdTU0xGmHniKVqr)(hrUwcdqtyJm2TVFeTo)pTP7tI0Tm06sFbYe2Gq(cf97FejrIAcUSoeLZPynZh)4hXCjl(Vw9Ckrk9YtL28vxpYscikNtXA6COGlzqWcPEyaksPxEQ0MVyDkiwN4WKiXEqT0ukrdKWuS()NyupvaXKiDleSqQhgGIu6LNkT5lwNcI1jom3BzpOwAkLObsykw))tmQNkGyUKf)xREoLip(yQdFWqbeLZPyDKUhy0qvt0rUes4KsAuqbQ19OcsI0Tes4KsAuqbQ19OcsIeHeoPKgfQyhAetIK0ZyCPMGlRdr5Ckwt8)uNMmAZxmr8FT65umAZJwShu3HyEGWqIHJASBjmangVZHmu8SegGMWgzSBF)iAD(FAtNYLmlHbOjSrg723vd28PCZOneWowO8GSM4XFsKyO1L(cKjSbH8fk63)iYvcKIsOsyJUbZIr9q50MVeGhCZOneWowO8GSM4DkxYUvHPD1Zs1vymdlSj2yQasKIpbSYYe1eCzDQejMyNM75lrJVwX8L(6j4Y8L6H(cE4R9(EQVmm(LI5R9(YcxrF5m2LVe9JpM6WhmmeFpH2fc5mmmeFbzOVCg7Yx6mHn89oywmQhkN28LWPjJ28fte)xREofJ28OfyD96WDj9eCzHmu8iKWjL0OGz9dDw1ubCjl(Vw9CkrE8Xuh(GHcikNtX6iDpWOHQMoLeP4)A1ZPe5XhtD4dgkGOCofRJ09aJgQA(m)iMlzX)1QNtjujSr3GzXOEOCAZxcikNtXAkiQirscKIsOsyJUbZIr9q50MVeGhe70KrB(IjI)RvpNIrBE0cSUED4UKEcUSqgkEes4KsAuKkfRdr5CksKKEgJl1eCzDikNtXAIVZonz0MVyI4)A1ZPy0MhTujSr3GzXOEOCAZxHmu8iKWjL0OGz9dDw1ubCjt9MaSUED4UKEcUSU6nbeLZPyKiDRLASmbyD96WDj9eCze70KrB(IjI)RvpNIrBE0sLWgDdMfJ6HYPnFfYqXJqcNusJIuPyDikNtrIK0ZyCPMGlRdr5Ckwt8D2PjJ28fte)xREofJ28OvE8Xuh(GHHmu8YOneWowO8GmEN5QqjqkkbfYmeovqNZdwkbZYyJM5DFUKDlHeoPKgfuGADpQGKiriHtkPrbfOw3JkixYI)RvpNsawxVoCxspbxMaIY5uSMpZpsKI)RvpNsOsyJUbZIr9q50MVequoNI1r6EGrdvnFMFCV1snwMaSUED4UKEcUmIj2PjJ28fte)xREofJ28OvE8Xuh(GHHedh1y3syaAmENdzO4LrBiGDSq5bznZJpUkucKIsqHmdHtf058GLsWSm2OzE3N7TkmTREwQUcJzyHnXgtf40KrB(IjI)RvpNIrBE0Ibkl)vpiHbFyngYqXdcwtSF8CqOqHutCSMoFFUX)1QNtjaRRxhUlPNGltar5CkwtN5p34)A1ZPeQe2OBWSyupuoT5lbeLZPyDKUhy0qvtN5VttgT5lMi(Vw9CkgT5rlW661H7jJLGAlKHIhHeoPKgfmRFOZQMkGRcLaPOeuiZq4ubDopyPemlJnAIpUKDGMip(yp46b1ImAdbKejjqkkHkHn6gmlg1dLtB(saEWn(Vw9CkrE8Xuh(GHcikNtXA(m)irk(Vw9CkrE8Xuh(GHcikNtXA(m)4g)xREoLqLWgDdMfJ6HYPnFjGOCofR5Z8JyNMmAZxmr8FT65umAZJwG11Rd3tglb1wiXWrn2TegGgJ35qgkEz0gcyhluEqwZ84JRcLaPOeuiZq4ubDopyPemlJnAIpUKDGMip(yp46b1ImAdbKejjqkkHkHn6gmlg1dLtB(saEqIu8FT65ucfM2vplvxHXmSaIY5uSMcIkIDAYOnFXeX)1QNtXOnpAbZHHDfMQqgkE3EGMi46b1ImAdb0P5E3Zx6CyPKgvH4BOeKz(wV5letToSV1dLtTVs4vsyEOV2vAKZ8LZdTlFpaHmWPc8DQtqqkJcNM7DpFZOnFXeX)1QNtXOnpAXYiCOM4K6(rgTqgkEz0gcyhluEqwZ84J7TsGuucvcB0nywmQhkN28La8GB8FT65ucvcB0nywmQhkN28LaIY5uSMpLejPNX4snbxwhIY5uSMcIkNgNM7DpFp5taRSmFj6sJESbzonz0MVyI4taRSmgpgNekpvqxEywidfpcjCsjnkyw)qNvnvaxiynX(XZbHcfsnXXA(8nXLS4)A1ZPe5XhtD4dgkGOCofJePBTuJLjsOC4(t1TlSRs5cvCJ)RvpNsOsyJUbZIr9q50MVequoNIrmjsspJXLAcUSoeLZPynD(StZ98TfnFT3xqg6Bszi0384J(omF)Y3tsN(MmFT33disalZ3NacJ5XXub(EdVz(Y5A0OVm0SPc8f8W3tsNKZCAYOnFXeXNawzzmAZJwmojuEQGU8WSqgkEX)1QNtjYJpM6Whmuar5CkgxYYOneWowO8GSM5Xh3mAdbSJfkpiRjENYfcwtSF8CqOqHutCSMpZpAtwgTHa2XcLhKrhUjI5siHtkPrrQuSoeLZPirkJ2qa7yHYdYA(uUqWAI9JNdcfkKAIJ1895hXonz0MVyI4taRSmgT5rRu6LNkT5RUEKLczO4riHtkPrbZ6h6SQPc4El7b1stPeAmvDPWDKUP8Hg5sw8FT65uI84JPo8bdfquoNIrI0TwQXYejuoC)P62f2vPCHkUX)1QNtjujSr3GzXOEOCAZxcikNtXiMleSqHnYy3((9BwcKIsabRj2JpecEyZxcikNtXirs6zmUutWL1HOCofRj(o70KrB(IjIpbSYYy0MhTsPxEQ0MV66rwkKHIhHeoPKgfmRFOZQMkGl7b1stPeAmvDPWDKUP8Hg5sM6nbyD96WDj9eCzD1BcikNtXA(8zsKU1snwMaSUED4UKEcUmUX)1QNtjujSr3GzXOEOCAZxcikNtXi2PjJ28fteFcyLLXOnpALsV8uPnF11JSuidfpcjCsjnkyw)qNvnvax2dQLMsjAGeMI1))eJ6Pc4sMcLaPOeuiZq4ubDopyPemlJnAM395EleSqQhgGIu6LNkT5lwNcI1jomjsqWcPEyaksPxEQ0MVyDkiwN4WCJ)RvpNsKhFm1HpyOaIY5umIDAYOnFXeXNawzzmAZJwP0lpvAZxD9ilfYqXJqcNusJIuPyDikNtXfcwOWgzSBF)(nlbsrjGG1e7XhcbpS5lbeLZPyonz0MVyI4taRSmgT5rl2vgBOXUDHDWIZdTRWHmu8iKWjL0OGz9dDw1ubCjl(Vw9CkrE8Xuh(GHcikNtXA(m)ir6wl1yzIekhU)uD7c7QuUqf34)A1ZPeQe2OBWSyupuoT5lbeLZPyetIK0ZyCPMGlRdr5CkwtNp1PjJ28fteFcyLLXOnpAXUYydn2TlSdwCEODfoKHIhHeoPKgfPsX6quoNIlzkmTREwQUcJzyHnXgtfqIemhvhjGLjsLIjGOCofRjENVpXonz0MVyI4taRSmgT5rlknYUIWKYczO4XEqT0ukXbiZa1yhHGh28fjsShulnLsq41PnASZEnbSmU3kbsrji860gn2zVMaww)cuoRFucWJqMYqie8W6JSmQM0qENdzkdHqWdRhOFPuZ7CitziecEy9HIh7b1stPeeEDAJg7SxtalZPXP5E3Z32Pc0OV3LWa0CAYOnFXebyHWjYtHPD1J)OdzO4DlHeoPKgfh)RNkOdbRj2pEoiKlzsGuucgOsHvx9VSaIz0irccwtSF8CqOqHutCSM4DM)0MmiyHupmafWu(ilRBWSyuieRish4pTvyAx9g1eCzciyHupmafxHzgcNKoWFIjMePd0ebjm4dRrrgTHaYfcwyt84pjsutWL1HOCofRPZ8J7TkucKIsqHmdHtf058GLsaE40KrB(IjcWcHtK28OvwH7QsfYqXJml1yzcfsnAuGvkPrfjsXNawzzIAcUSovIKibblK6HbO44ct4l)fYiMlzKDlHeoPKgfh)RNkOdblKrIu8jGvwMOMGlRtLixl1yzcfsnAKB8lf4ycoJDHWPc6bWhSuetIK0ZyCPMGlRdr5CkwtNsSttgT5lMialeorAZJwCEWs1zhyPqyidfpcjCsjnkuGYhDopyPyCvOeifLGczgcNkOZ5blLGzzSrZ8oZn(Vw9CkrE8Xuh(GHcikNtX6iDpWOHQMpF6jGmiyHupmafkmv6bzwp(JMoCMFeZ9wcjCsjnko(xpvqhcwiZPjJ28fteGfcNiT5rlopyP6SdSuimKHINcLaPOeuiZq4ubDopyPemlJnAM)CVLqcNusJIJ)1tf0HGfYirsHsGuuckKziCQGoNhSucWdUutWL1HOCofRjYuOeifLGczgcNkOZ5blLGzzSbDiiQi2PjJ28fteGfcNiT5rlfM2vp(JoKHIheSMy)45GqHcPM4ynXJp(rBYGGfs9Wauat5JSSUbZIrHqSIiD4(0wHPD1ButWLjGGfs9WauCfMziCs6W9jM7Tes4KsAuC8VEQGoeSMy)45GqNMmAZxmrawiCI0MhTOqMHWPc6mdonWqgkEkucKIsqHmdHtf058GLsWSm2OP7Z9wcjCsjnko(xpvqhcwiZPjJ28fteGfcNiT5rlfM2vp(JoKHI3Tes4KsAuC8VEQGoeSMy)45GqNMmAZxmrawiCI0MhT48GLQZoWsHWqgkEkucKIsqHmdHtf058GLsWSm2OzEN5cblSj(4ElHeoPKgfh)RNkOdblKXn(Vw9CkrE8Xuh(GHcikNtX6iDpWOHQMp1PXP5E3Z3teSq4e9LO)3iFVzW5HJf2PjJ28fteGfcNypFKhNCSqyyKx8FT65uc2dQ7qmpqOaIY5uSqgkEwQXYeShu3HyEGqUwcdqtyJm2TVFeTo)pTPt5snbxwhIY5uSMpLB8FT65uc2dQ7qmpqOaIY5uSMiliQOd8tqhpLyUz0gcyhluEqwt84VttgT5lMialeoXE(iT5rlfM2vp(JoKHIhz3siHtkPrXX)6Pc6qWAI9JNdcjrscKIsWavkS6Q)LfqmJgXCjtcKIsOsyJUbZIr9q50MVeGhCHGfs9WauOWuPhKz94pAUz0gcyhluEqwt84pjsz0gcyhluEqgp(i2PjJ28fteGfcNypFK28OfEmkuEIHmu8KaPOemqLcRU6FzbeZOrI0Tes4KsAuC8VEQGoeSMy)45GqNM757nGYxlHbO5BmCupvGVdZx1WsjnQcXxgNXIx(kLXg(AVV2f6lBQanEcSegGMVbyHWj6REyMVtXmmvcNMmAZxmrawiCI98rAZJwqWQNrB(QRhMfsLYiVaSq4edHzWjA8ohYqXlgoQXowO8GmENDAYOnFXebyHWj2ZhPnpAX5blvNDGLcHHedh1y3syaAmENdzO4rw8FT65uI84JPo8bdfquoNI18PCvOeifLGczgcNkOZ5blLa8GejfkbsrjOqMHWPc6CEWsjywgB0m)jMlzutWL1HOCofRP4)A1ZPekmTREwQUcJzybeLZPy0(m)irIAcUSoeLZPynh)xREoLip(yQdFWqbeLZPye70KrB(IjcWcHtSNpsBE0IczgcNkOZm40adjgoQXULWa0y8ohYqXtHsGuuckKziCQGoNhSucMLXgnXJ)CJ)RvpNsKhFm1HpyOaIY5uSMoLejfkbsrjOqMHWPc6CEWsjywgB00zNMmAZxmrawiCI98rAZJwuiZq4ubDMbNgyiXWrn2TegGgJ35qgkEX)1QNtjYJpM6Whmuar5CkwZNYvHsGuuckKziCQGoNhSucMLXgnD2P5E(E31W8Dy(Iuuy0gcOoSVuJwJqF5CnXlFzJmZx68M16BHGgm1H4ReO5l76b1kFpGibSmFtFzrSs48(Y5cHOV2f6BQuF57vY8TE7AQaFT3xigFzzSucNMmAZxmrawiCI98rAZJwuiZq4ubDMbNgyidfVmAdbSREtqHmdHtf058GLQzEXWrn2XcLhKXvHsGuuckKziCQGoNhSucMLXgnDFNgNM757nmJtQzonz0MVycygNuZ4LWywy3EiellKHIheSMy)45GqHcPM4ynFtNYLSd0ebjm4dRrrgTHasI0TwQXYemqz5V6bjm4dRrbwPKgveZfcwOqHutCSM5DQttgT5lMaMXj1mAZJws6)vDkqy4qgkEes4KsAuiNHYh2J)RvpNI1ZOneqsKoqteKWGpSgfz0gci3d0ebjm4dRrbeLZPynXtcKIsiP)x1PaHHfkqyAZxKij9mgxQj4Y6quoNI1epjqkkHK(FvNcegwOaHPnF50KrB(IjGzCsnJ28OLecziSXubHmu8iKWjL0OqodLpSh)xREofRNrBiGKiDGMiiHbFynkYOneqUhOjcsyWhwJcikNtXAINeifLqcHme2yQaHceM28fjsspJXLAcUSoeLZPynXtcKIsiHqgcBmvGqbctB(YPjJ28ftaZ4KAgT5rl9eCzSEOeufiJLfYqXtcKIsawxVoCNzqScSlb4HtZ98LOxrKzWu77jtT23yw(AWjiaH(EFFpEdlBsTVsGuuSq8fZ4LV6Kztf475t9LHXVumHV342ONtmQ89kHkFJVcv(AJm6BY8n91Gtqac91EFBG4HVJ5letvkPrHttgT5lMaMXj1mAZJwzfrMbtDpMADidfpcjCsjnkKZq5d7X)1QNtX6z0gcijshOjcsyWhwJImAdbK7bAIGeg8H1OaIY5uSM4D(usKKEgJl1eCzDikNtXAI35tDAYOnFXeWmoPMrBE0kHXSW(bOMHHmu8YOneWowO8GSM5XhjsKbbluOqQjowZ8oLleSMy)45GqHcPM4ynZ7M4hXonz0MVycygNuZOnpArnqus)VkKHIhHeoPKgfYzO8H94)A1ZPy9mAdbKePd0ebjm4dRrrgTHaY9anrqcd(WAuar5Ckwt8KaPOeudeL0)RekqyAZxKij9mgxQj4Y6quoNI1epjqkkb1arj9)kHceM28LttgT5lMaMXj1mAZJwszq)P6gCInyHmu8YOneWowO8GmEN5sMeifLaSUED4oZGyfyxcWdsKKEgJl1eCzDikNtXA6uIDACAU3989o4unqJ50KrB(Ijm4unqJXdKH9Xq5qQug5nflcbTusJ9qfmlduURqctedzO4rw8FT65ucW661H7s6j4YequoNI1mF8JeP4)A1ZPeQe2OBWSyupuoT5lbeLZPyDKUhy0qvZ8XpI5swgTHa2XcLhK1mp(ir6anrcLd3dUEqTiJ2qajr6anrE8XEW1dQfz0gcixYSuJLjaRRxhUNmwcQnsKuyAx9g1eCzc1Wsjn2Z3uetI0bAIGeg8H1OiJ2qajMejPNX4snbxwhIY5uSM47mjskmTREJAcUmHAyPKg7tOQ6iDXiOH84hxlHbOjSrg723pIwNp(10Ponz0MVycdovd0y0MhTazyFmuoKkLrESycz9NQtbtdHvQ7mdouOttgT5lMWGt1angT5rlqg2hdLdPszKNDHDQbYSoBcgDidfpcjCsjnkKZq5d7X)1QNtX6z0gcixYSrgBM)8JePBXqfCooqLykwecAPKg7HkywgOCxHeMisSttgT5lMWGt1angT5rlqg2hdLdPszK3taHCUqT8ub9JNdc7ryyML6qgkEes4KsAuiNHYh2J)RvpNI1ZOneqUKzJm2m)5hjs3IHk4CCGkXuSie0sjn2dvWSmq5UcjmrK7TyOcohhOsyxyNAGmRZMGrtStZ989Ul0xdovd08LZyx(AxOVxtWfYmFrMnYPHkFjKAqmeF5mATVsOVGmu5l1azMVzP89ihiQ8LZyx(s0p(yQdFWqFjBO8vcKIY3H575t9LHXVumFFOVAKXi23h6l91tWLrl68oFjBO8naIPHqFTRS898P(YW4xkgXonz0MVycdovd0y0MhTm4unq7CidfVBjKWjL0OGDGXHAqv3Gt1anUKrMbNQbAIZcjqkQUceM28vt8oFk34)A1ZPe5XhtD4dgkGOCofRz(4hjsgCQgOjolKaPO6kqyAZxnF(uUKf)xREoLaSUED4UKEcUmbeLZPynZh)irk(Vw9CkHkHn6gmlg1dLtB(sar5CkwhP7bgnu1mF8JysKYOneWowO8GSM5XhxjqkkHkHn6gmlg1dLtB(saEqmxYU1Gt1anbFIRK1J)RvpNIejdovd0e8jI)RvpNsar5Ckgjses4KsAuyWPAGw)aopCSW8otmXKij9mgxdovd0eNfsGuuDfimT5RM5rnbxwhIY5umNMmAZxmHbNQbAmAZJwgCQgOXxidfVBjKWjL0OGDGXHAqv3Gt1anUKrMbNQbAc(esGuuDfimT5RM4D(uUX)1QNtjYJpM6Whmuar5CkwZ8XpsKm4unqtWNqcKIQRaHPnF185t5sw8FT65ucW661H7s6j4YequoNI1mF8JeP4)A1ZPeQe2OBWSyupuoT5lbeLZPyDKUhy0qvZ8XpIjrkJ2qa7yHYdYAMhFCLaPOeQe2OBWSyupuoT5lb4bXCj7wdovd0eNfxjRh)xREofjsgCQgOjolI)RvpNsar5Ckgjses4KsAuyWPAGw)aopCSW84JyIjrs6zmUgCQgOj4tibsr1vGW0MVAMh1eCzDikNtXCAUNV3akF)sh23VqF)Yxqg6RbNQbA(EaFcJcz(M(kbsrfIVGm0x7c99Tle67x(g)xREoLW3ti03HY3ch7cH(AWPAGMVhWNWOqMVPVsGuuH4lid9v6TlF)Y34)A1ZPeonz0MVycdovd0y0MhTazyFmuoeM(nEgCQgODoKHI3Tes4KsAuWoW4qnOQBWPAGg3Bn4unqtCwCLSoid7sGuuCjZGt1anbFI4)A1ZPequoNIrI0TgCQgOj4tCLSoid7sGuue70KrB(Ijm4unqJrBE0cKH9Xq5qy634zWPAGgFHmu8ULqcNusJc2bghQbvDdovd04ERbNQbAc(exjRdYWUeiffxYm4unqtCwe)xREoLaIY5umsKU1Gt1anXzXvY6GmSlbsrrmqBcAxpeOTDKb1PnFDsyszagGbaa]] )

end
