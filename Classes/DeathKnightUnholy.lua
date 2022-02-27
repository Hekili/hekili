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


    spec:RegisterPack( "Unholy", 20220226, [[deLAedqivk9ivQ0LuPOAtOsFcr1OquofcAvivIxHuQzjiUfQQQ2fHFHuYWqvLJPIAzOQ8mPinnvQ4AQiTnve6BivsJtLcCoveW6KI4DQuKK5jiDpuL9jf1brGQfIuvpufrtePsDrvkKnIaf9rveOrIaf6KQueReP4LiqbZebYnvPiP2jc4NQiOHQsrzPQuOEQuAQQu1vvPi1wvPiXxrGsJfPk7fWFLQbR0HfTyI8yHMmjxgAZi5ZcmAvYPvSAuvvETuy2K62e1UL8BvnCv44OQklh0Zrz6uUoqBhH(oQy8ivCEb16vPGMpISFQg4mW9aTQ0qacWh)4Jp(XhFNOGVZNYVtpbaATWhiq7rgBKbiqBLYiq7nDD96WaThzy9NkG7bAzpimIaTxMDWAcTOvWyxGsI4ltl2idQtB(kctkJwSroslGwjWrB3KcqcOvLgcqa(4hF8Xp(47ef8D(u(D6PaTSdmcqa(oLpG2RrPWcqcOvHSiqlDJPD5lbd1eCz(EtxxVoStdbtuccMWW(Y3jgIV8Xp(4ZPXP5KxzfGSM40W)9LGR4FGmtglJ5R9(s3fDtl6gPgnsl6gt7I5lDdI(AVVFPd7B8blZxlHbOX8LZ17BcrFr6CGrdv(AVV6Hi6R(RaFX6bdU81EFLtZqOVKLp2zObE47DptOWPH)7lDpSusJkFBZiCOM4KAFVzz08vcJjid9vHPY3GRhuZ8voBG(s9qFzPYx6MGbMWPH)77nnBQaFjyFWs5B7bwke6Bkn6XgK5R8drFP0iDgjDyFjlnFVdT9LzzSbZ3PygMkFFkFpL2eEtLV09nR13cbnyQ9nlLVYzyFpGirSmFzVm6B98Fig9LngyAZxmHtd)33BA2ub(sWezgcNkW3wdonqFNYxc(j8g57q5B4h03RKi6B921ub(IAg6R9(QEFZs5lNVi389jIWyE4lNhSumFhMV09nR13cbnyQfon8FFp5vwbOYx5Sc7l5utWL1HOCofJCFJFPgB(k1mFT3384qh23P8v6zmFPMGlJ57x6W(sMgzmFpjD7lNKzOVF5Rbt2fHcNg(VVeCLcv(M1Bxi03tiOjbXSHVyzWW(AVVm08f8WxMb)kaH(EJogfkprMWPH)77ng1jD8T9EFjYe(sWpH3iF1FWe9Lnve9DmFHOEqMVF5B8lQucuNgQ8fMJQJeXYycNg(VV3FcP7tyt81xcMz0EOVTgeRa7Y3d4hz(oL9(AWPAGMV6pyIcGw9WmgW9aT5JDgAGha3dqGZa3d0IvkPrfa9bAJWXq4KaTkmTREJAcUmbfNhSuOQBjmanMVnZZ3y4Og7yHYdY8LejFvyAx9g1eCzckopyPqv3syaAmFBMNVN6ljs(ERVwQXYesGqMnvqN9qKjWkL0OYxsK8fMJQJeXYePsXeiDgMX8LRVWCuDKiwMivkMaIY5umFdLNVNp7ljs(k9mMVC9LAcUSoeLZPy(gkpFpFgOnJ28fqBwH7QsbyaeGpG7bAXkL0OcG(aTr4yiCsG2B9LycNusJIJ)1tf0HG1e7hphe6lxFjZxjqkkHkHn6gmlg1dLtB(saE4lxFHGfs9WauOWuPhKz94pAbwPKgv(Y13mAdrSJfkpiZ3q55Bt9LejFZOneXowO8GmF55lF(siqBgT5lGwfM2vp(JgWaiqtbUhOfRusJka6d0gHJHWjbAV1xIjCsjnko(xpvqhcwtSF8CqiqBgT5lGw8yuO8ebmacChG7bAXkL0OcG(aTz0MVaAPqMHWPc6mdonqG2iCmeojqRcLaPOeuiZq4ubDopyPemlJn8nuE(2uF56B8FT65uI84JPo8bdfquoNI5BO(2uG2y4Og7wcdqJbqGZagabof4EGwSsjnQaOpqBgT5lGwkKziCQGoZGtdeOnchdHtc0QqjqkkbfYmeovqNZdwkbZYydFd13ZaTXWrn2TegGgdGaNbmacCIa3d0IvkPrfa9bAZOnFb0sHmdHtf0zgCAGaTr4yiCsGwiyHcBKXU9974BO(sMVX)1QNtjuyAx9SuDfgZWcikNtX8LRV36RLASmHcPgnkWkL0OYxsK8n(Vw9CkHcPgnkGOCofZxU(APgltOqQrJcSsjnQ8LejFJprSYYe1eCzDQe9LRVX)1QNtjuyAxSUcefquoNI5lHaTXWrn2TegGgdGaNbmacqxbUhOfRusJka6d0MrB(cOLZdwQo7alfcbAvilcNdB(cOLG9clFTegGMVmo5bZ3eI(QgwkPrvi(AxdZxoJw7RgnFd)G(YoWs5leSqgT48GLI57umdtLVpLVCYXMkWxQh6lDx0nTOBKA0iTOBmTlYz(s3GOaOnchdHtc0sMV36ldnBQaMigoQrFjrYxfM2vVrnbxMGIZdwku1TegGgZ3M55BmCuJDSq5bz(sOVC9vHsGuuckKziCQGoNhSucMLXg(2SVn1xU(cbluyJm2TV3uFd134)A1ZPezfURkLaIY5umadWaAZh7sGqMbCpabodCpqlwPKgva0hOnchdHtc0MrBiIDSq5bz(gkpFpfOnJ28fqBuNCMkOZUs1ZHbyaeGpG7bAXkL0OcG(aTr4yiCsG2mAdrSJfkpiZxE(EI(Y1xfM2vVrnbxMGIZdwku1TegGgZ3M55BtbAZOnFb0g1jNPc6SRu9CyagabAkW9aTyLsAubqFG2iCmeojqRLASmHeiKztf0zpezcSsjnQ8LRVK5Rct7Q3OMGltqX5blfQ6wcdqJ5lpFZOneXowO8GmFjrYxfM2vVrnbxMGIZdwku1TegGgZ3M55Bt9LqFjrYxl1yzcjqiZMkOZEiYeyLsAu5lxFTuJLjI6KZubD2vQEombwPKgv(Y1xfM2vVrnbxMGIZdwku1TegGgZ3M557zG2mAZxaTCEWs1zhyPqiGbqG7aCpqlwPKgva0hOnchdHtc0sMVsGuucgOsHvx9VSaIz08LejFV1xIjCsjnko(xpvqhcwtSF8CqOVe6lxFjZxjqkkHkHn6gmlg1dLtB(saE4lxFHGfs9WauOWuPhKz94pAbwPKgv(Y13mAdrSJfkpiZ3q55Bt9LejFZOneXowO8GmF55lF(siqBgT5lGwfM2vp(JgWaiWPa3d0IvkPrfa9bAJWXq4KaTqWAI9JNdcfkKAIJ5BO(sMVN5NV02xfM2vVrnbxMGIZdwku1TegGgZx6IVn1xc9LRVkmTREJAcUmbfNhSuOQBjmanMVH67j6lxFV1xIjCsjnko(xpvqhcwtSF8CqOVKi5ReifLGXjHYtf0LhMjapaAZOnFb0IhJcLNiGbqGte4EGwSsjnQaOpqBeogcNeOfcwtSF8CqOqHutCmFd1x(o1xU(QW0U6nQj4YeuCEWsHQULWa0y(2SVN6lxFV1xIjCsjnko(xpvqhcwtSF8CqiqBgT5lGw8yuO8ebmacqxbUhOfRusJka6d0gHJHWjbAV1xfM2vVrnbxMGIZdwku1TegGgZxU(ERVet4KsAuC8VEQGoeSMy)45GqFjrYxQj4Y6quoNI5BO(EQVKi5lmhvhjILjsLIjq6mmJ5lxFH5O6irSmrQumbeLZPy(gQVNc0MrB(cOfpgfkpradGa3aG7bAZOnFb0Y5blvNDGLcHaTyLsAubqFadGaNaa3d0IvkPrfa9bAJWXq4KaT36lXeoPKgfh)RNkOdbRj2pEoieOnJ28fqlEmkuEIagGb0g)xREofd4EacCg4EGwSsjnQaOpqBeogcNeOLycNusJc5K)9WE8FT65uSEgTHi6ljs(EGMiiHbFynkYOnerF567bAIGeg8H1OaIY5umFdLNV8DI(sIKVspJ5lxFPMGlRdr5CkMVH6lFNiqBgT5lG2J3MVamacWhW9aTyLsAubqFG2iCmeojqB8FT65ucW661H7s6j4YequoNI5BO(sx9LRVX)1QNtjujSr3GzXOEOCAZxcikNtX6iDoWOHkFd1x6QVC91snwMaSUED4UKEcUmbwPKgv(Y1xY8LHwx6lqMWgeY3nOFNJOVC91syaAcBKXU99JO1B6P(gQV3XxsK89wFzO1L(cKjSbH8Dd635i6ljs(snbxwhIY5umFB2x(4h)8LqF56lz(g)xREoLiLE5PsB(QRhzjbeLZPy(gQVNVb(Y1xY8fcwi1ddqrk9YtL28fRtbX6ggwGvkPrLVKi5l7b1stPenqItX6)Fdr9ubcSsjnQ8LqFjrY3B9fcwi1ddqrk9YtL28fRtbX6ggwGvkPrLVC99wFzpOwAkLObsCkw))BiQNkqGvkPrLVe6lxFjZ34)A1ZPe5XhtD4dgkGOCofRJ05aJgQ8nuFPR(Y1xIjCsjnkOa16Eub9LejFV1xIjCsjnkOa16Eub9LejFjMWjL0Oqf7qZxc9LejFV1xl1yzcW661H7s6j4YeyLsAu5ljs(k9mMVC9LAcUSoeLZPy(gQVn9uG2mAZxaTjuoC)P62f2vyQamac0uG7bAXkL0OcG(aTz0MVaAzpOUdX8aHaTr4yiCsGwlHbOjSrg723pIwVPN6BO(EQVC9LmFTegGMWgzSBFxnOVn77P(Y13mAdrSJfkpiZ3q55Bt9LejFzO1L(cKjSbH8Dd635i6lxFLaPOeQe2OBWSyupuoT5lb4HVC9nJ2qe7yHYdY8nuE(EQVC9LmFV1xfM2vplvxHXmSWMyJPc8LejFJprSYYe1eCzDQe9LqFjeOngoQXULWa0yae4mGbqG7aCpqlwPKgva0hOnJ28fqlyD96WDj9eCzaTkKfHZHnFb0sW4RvmFPVEcUmFPEOVGh(AVVN6ldJFPy(AVVSWv0xoJD5lb)4JPo8bddX3tODHqodddXxqg6lNXU8LUtydFVhMfJ6HYPnFjaAJWXq4KaTet4KsAuWS(HoRAQaF56lz(g)xREoLip(yQdFWqbeLZPyDKohy0qLVH67P(sIKVX)1QNtjYJpM6Whmuar5CkwhPZbgnu5BZ(EMF(sOVC9LmFJ)RvpNsOsyJUbZIr9q50MVequoNI5BO(gev(sIKVsGuucvcB0nywmQhkN28La8WxcbmacCkW9aTyLsAubqFG2iCmeojqlXeoPKgfPsX6quoNYxsK8v6zmF56l1eCzDikNtX8nuF57mqBgT5lGwW661H7s6j4YamacCIa3d0IvkPrfa9bAJWXq4KaTet4KsAuWS(HoRAQaF56lz(QEtawxVoCxspbxwx9MaIY5umFjrY3B91snwMaSUED4UKEcUmbwPKgv(siqBgT5lGwvcB0nywmQhkN28fGbqa6kW9aTyLsAubqFG2iCmeojqlXeoPKgfPsX6quoNYxsK8v6zmF56l1eCzDikNtX8nuF57mqBgT5lGwvcB0nywmQhkN28fGbqGBaW9aTyLsAubqFG2iCmeojqBgTHi2XcLhK5lpFp7lxFvOeifLGczgcNkOZ5blLGzzSHVnZZ374lxFjZ3B9LycNusJckqTUhvqFjrYxIjCsjnkOa16Eub9LRVK5B8FT65ucW661H7s6j4YequoNI5BZ(EMF(sIKVX)1QNtjujSr3GzXOEOCAZxcikNtX6iDoWOHkFB23Z8ZxU(ERVwQXYeG11Rd3L0tWLjWkL0OYxc9LqG2mAZxaT5XhtD4dgcyae4ea4EGwSsjnQaOpqBgT5lG284JPo8bdbAJWXq4KaTz0gIyhluEqMVnZZx(8LRVkucKIsqHmdHtf058GLsWSm2W3M557D8LRV36Rct7QNLQRWygwytSXubaTXWrn2TegGgdGaNbmacCMFa3d0IvkPrfa9bAJWXq4KaTqWAI9JNdcfkKAIJ5BO(E(o(Y134)A1ZPeG11Rd3L0tWLjGOCofZ3q99Ct9LRVX)1QNtjujSr3GzXOEOCAZxcikNtX6iDoWOHkFd13ZnfOnJ28fqlduw(REqcd(WAeWaiW5Za3d0IvkPrfa9bAJWXq4KaTet4KsAuWS(HoRAQaF56RcLaPOeuiZq4ubDopyPemlJn8nuF5ZxU(sMVhOjYJp2dUEqTiJ2qe9LejFLaPOeQe2OBWSyupuoT5lb4HVC9n(Vw9CkrE8Xuh(GHcikNtX8TzFpZpFjrY34)A1ZPe5XhtD4dgkGOCofZ3M99m)8LRVX)1QNtjujSr3GzXOEOCAZxcikNtX8TzFpZpFjeOnJ28fqlyD96W9KXsqTbyae4mFa3d0IvkPrfa9bAZOnFb0cwxVoCpzSeuBaTr4yiCsG2mAdrSJfkpiZ3M55lF(Y1xfkbsrjOqMHWPc6CEWsjywgB4BO(YNVC9LmFpqtKhFShC9GArgTHi6ljs(kbsrjujSr3GzXOEOCAZxcWdFjrY34)A1ZPekmTREwQUcJzybeLZPy(gQVbrLVec0gdh1y3syaAmacCgWaiW5McCpqlwPKgva0hOnchdHtc0ERVhOjcUEqTiJ2qebAZOnFb0cZHHDfMkadWaAdWcHte4EacCg4EGwSsjnQaOpqBeogcNeO9wFjMWjL0O44F9ubDiynX(XZbH(Y1xY8vcKIsWavkS6Q)LfqmJMVKi5leSMy)45GqHcPM4y(gkpFp3uFPTVK5leSqQhgGcykFKL1nywmkeIvefyLsAu5lDX3M6lT9vHPD1ButWLjGGfs9WauCfMziCsFPl(2uFj0xc9LejFpqteKWGpSgfz0gIOVC9fcwOVHYZ3M6ljs(snbxwhIY5umFd13Z8ZxU(ERVkucKIsqHmdHtf058GLsaEa0MrB(cOvHPD1J)ObmacWhW9aTyLsAubqFG2iCmeojqlz(APgltOqQrJcSsjnQ8LejFJprSYYe1eCzDQe9LejFHGfs9WauCCHj8L)czcSsjnQ8LqF56lz(sMV36lXeoPKgfh)RNkOdblK5ljs(gFIyLLjQj4Y6uj6lxFTuJLjui1OrbwPKgv(Y134xkWXeCg7cHtf0dGpyPeyLsAu5lH(sIKVspJ5lxFPMGlRdr5CkMVH67P(siqBgT5lG2Sc3vLcWaiqtbUhOfRusJka6d0gHJHWjbAjMWjL0OqbkF058GLI5lxFvOeifLGczgcNkOZ5blLGzzSHVnZZ3Z(Y134)A1ZPe5XhtD4dgkGOCofRJ05aJgQ8TzFpFQV8FFjZxiyHupmafkmv6bzwp(JwGvkPrLV0fFpZpFj0xU(ERVet4KsAuC8VEQGoeSqgqBgT5lGwopyP6SdSuieWaiWDaUhOfRusJka6d0gHJHWjbAvOeifLGczgcNkOZ5blLGzzSHVn7Bt9LRV36lXeoPKgfh)RNkOdblK5ljs(QqjqkkbfYmeovqNZdwkb4HVC9LAcUSoeLZPy(gQVK5RcLaPOeuiZq4ubDopyPemlJn8LU4Bqu5lHaTz0MVaA58GLQZoWsHqadGaNcCpqlwPKgva0hOnchdHtc0cbRj2pEoiuOqQjoMVHYZx(4NV02xY8fcwi1ddqbmLpYY6gmlgfcXkIcSsjnQ8LU47D8L2(QW0U6nQj4YeqWcPEyakUcZmeoPV0fFVJVe6lxFV1xIjCsjnko(xpvqhcwtSF8CqiqBgT5lGwfM2vp(JgWaiWjcCpqlwPKgva0hOnchdHtc0QqjqkkbfYmeovqNZdwkbZYydFd1374lxFV1xIjCsjnko(xpvqhcwidOnJ28fqlfYmeovqNzWPbcyaeGUcCpqlwPKgva0hOnchdHtc0ERVet4KsAuC8VEQGoeSMy)45GqG2mAZxaTkmTRE8hnGbqGBaW9aTyLsAubqFG2iCmeojqRcLaPOeuiZq4ubDopyPemlJn8TzE(E2xU(cbl03q9LpF567T(smHtkPrXX)6Pc6qWcz(Y134)A1ZPe5XhtD4dgkGOCofRJ05aJgQ8TzFpfOnJ28fqlNhSuD2bwkecyagqB8jIvwgd4EacCg4EGwSsjnQaOpqBeogcNeOLycNusJcM1p0zvtf4lxFHG1e7hphekui1ehZ3M998j6lxFjZ34)A1ZPe5XhtD4dgkGOCofZxsK89wFTuJLjsOC4(t1TlSRs5cvcSsjnQ8LRVX)1QNtjujSr3GzXOEOCAZxcikNtX8LqFjrYxPNX8LRVutWL1HOCofZ3q998zG2mAZxaTmojuEQGU8WmadGa8bCpqlwPKgva0hOnJ28fqlJtcLNkOlpmdOvHSiCoS5lG2w081EFbzOVjLHqFZJp67W89lFpjD7BY81EFpGirSmFFIimMhhtf47n(M5lNRrJ(YqZMkWxWdFpjDtodOnchdHtc0g)xREoLip(yQdFWqbeLZPy(Y1xY8nJ2qe7yHYdY8TzE(YNVC9nJ2qe7yHYdY8nuE(EQVC9fcwtSF8CqOqHutCmFB23Z8ZxA7lz(MrBiIDSq5bz(sx89e9LqF56lXeoPKgfPsX6quoNYxsK8nJ2qe7yHYdY8TzFp1xU(cbRj2pEoiuOqQjoMVn77D4NVecyaeOPa3d0IvkPrfa9bAJWXq4KaTet4KsAuWS(HoRAQaF567T(YEqT0ukHgtvxkChPtkFOrbwPKgv(Y1xY8n(Vw9CkrE8Xuh(GHcikNtX8LejFV1xl1yzIekhU)uD7c7QuUqLaRusJkF56B8FT65ucvcB0nywmQhkN28LaIY5umFj0xU(cbluyJm2TVFhFB2xjqkkbeSMyp(qi4HnFjGOCofZxsK8v6zmF56l1eCzDikNtX8nuF57mqBgT5lG2u6LNkT5RUEKLamacChG7bAXkL0OcG(aTr4yiCsGwIjCsjnkyw)qNvnvGVC9L9GAPPucnMQUu4osNu(qJcSsjnQ8LRVK5R6nbyD96WDj9eCzD1BcikNtX8TzFpF2xsK89wFTuJLjaRRxhUlPNGltGvkPrLVC9n(Vw9CkHkHn6gmlg1dLtB(sar5CkMVec0MrB(cOnLE5PsB(QRhzjadGaNcCpqlwPKgva0hOnchdHtc0smHtkPrbZ6h6SQPc8LRVShulnLs0ajofR))ne1tfiWkL0OYxU(sMVkucKIsqHmdHtf058GLsWSm2W3M557D8LRV36leSqQhgGIu6LNkT5lwNcI1nmSaRusJkFjrYxiyHupmafP0lpvAZxSofeRByybwPKgv(Y134)A1ZPe5XhtD4dgkGOCofZxcbAZOnFb0MsV8uPnF11JSeGbqGte4EGwSsjnQaOpqBeogcNeOLycNusJIuPyDikNt5lxFHGfkSrg723VJVn7ReifLacwtShFie8WMVequoNIb0MrB(cOnLE5PsB(QRhzjadGa0vG7bAXkL0OcG(aTr4yiCsGwIjCsjnkyw)qNvnvGVC9LmFJ)RvpNsKhFm1HpyOaIY5umFB23Z8ZxsK89wFTuJLjsOC4(t1TlSRs5cvcSsjnQ8LRVX)1QNtjujSr3GzXOEOCAZxcikNtX8LqFjrYxPNX8LRVutWL1HOCofZ3q998PaTz0MVaAzxzSHg72f2blop0Ucdyae4gaCpqlwPKgva0hOnchdHtc0smHtkPrrQuSoeLZP8LRVK5Rct7QNLQRWygwytSXub(sIKVWCuDKiwMivkMaIY5umFdLNVNVJVec0MrB(cOLDLXgASBxyhS48q7kmGbqGtaG7bAXkL0OcG(aTr4yiCsGw2dQLMsjoazgOg7ie8WMVeyLsAu5ljs(YEqT0ukbXxN2OXo71eXYeyLsAu5lxFV1xjqkkbXxN2OXo71eXY6xGYz9JsaEa0oLHqi4H1hkGw2dQLMsji(60gn2zVMiwgq7ugcHGhwFKLr1Kgc0EgOnJ28fqlLgzxryszaTtziecEy9a9lLAG2ZagGb0EaX4llLgW9ae4mW9aTz0MVaApEB(cOfRusJka6dyaeGpG7bAZOnFb0cZHHDfMkGwSsjnQaOpGbqGMcCpqBgT5lGwknYUIWKYaAXkL0OcG(agabUdW9aTyLsAubqFG2mAZxaTjuoC)P62f2vyQaAJWXq4KaT36RLASmbduw(REqcd(WAuGvkPrfq7beJVSuADBKrG2Mcyae4uG7bAXkL0OcG(aT)bqldTHcOnchdHtc0AWPAGMWolUswhKHDjqkkF56lz(AWPAGMWolI)RvpNsOaHPnF57n337CQV88LF(siqRczr4CyZxaT3iIPgmnK5B6RbNQbAmFJ)RvpNkeFvdXrHkFLc77Dov479xdZxojZ341ZWY3K5lyD96W(Y5Hny((LV35uFzy8lLVsGqM5BmCuJSq8vc089kz(A)7RCwH9nQG(Iuuy0y(AVVbdr03034)A1ZPe0rOaHPnF5RAioSh67umdtLW3BcLVJroZxIPge99kz(wVVquoNsHqFHObclFphIVOMH(crdew(YpXPcGwIjSxPmc0AWPAGw)CNfUIaTz0MVaAjMWjL0iqlXudIDuZqGw(jofOLyQbrG2ZagaborG7bAXkL0OcG(aT)bqldTHcOnJ28fqlXeoPKgbAjMWELYiqRbNQbAD(6SWveOnchdHtc0AWPAGMW4tCLSoid7sGuu(Y1xY81Gt1anHXNi(Vw9CkHceM28LV3CFVZP(YZx(5lHaTetni2rndbA5N4uGwIPgebApdyaeGUcCpqlwPKgva0hO9paAzOnuaTr4yiCsG2B91Gt1anHDwCLSoid7sGuu(Y1xdovd0egFIRK1bzyxcKIYxsK81Gt1anHXN4kzDqg2LaPO8LRVK5lz(AWPAGMW4te)xREoLqbctB(YxA5RbNQbAcJpHeifvxbctB(Yxc9LU4lz(EwCQV02xdovd0egFIRK1LaPO8LqFPl(sMVet4KsAuyWPAGwNVolCf9LqFj03M9LmFjZxdovd0e2zr8FT65ucfimT5lFPLVgCQgOjSZcjqkQUceM28LVe6lDXxY89S4uFPTVgCQgOjSZIRK1LaPO8LqFPl(sMVet4KsAuyWPAGw)CNfUI(sOVec0Qqweoh28fq7nIzJCAiZ30xdovd0y(sm1GOVsH9n(YhjCQaFTl034)A1ZP89P81UqFn4unqleFvdXrHkFLc7RDH(QaHPnF57t5RDH(kbsr57y(EaFIJczcFjymz(M(Ymiwb2LVYVAOge6R9(gmerFtFVMGle67bCE4yH91EFzgeRa7Yxdovd0yH4BY8LdQ1(MmFtFLF1qni0xQh67q5B6RbNQbA(Yz0AFFOVCgT236nFzHROVCg7Y34)A1ZPycGwIjSxPmc0AWPAGw)aopCSWaTz0MVaAjMWjL0iqlXudIDuZqG2ZaTetnic0YhGbqGBaW9aTyLsAubqFG2)aOLHgqBgT5lGwIjCsjnc0sm1GiqRLASmrcLd3FQUDHDvkxOsGvkPrLVC9n(LcCmr8lIFmT5R(t1TlSRWujWkL0OcOvHSiCoS5lG2BeXudMgY8nccHyz(Yqd8WxQh6RDH(YFGzzJf23NYxc(XhtD4dg67jP7BSViffgngqlXe2RugbAPa16EubbmacCcaCpqlwPKgva0hO9paAzOb0MrB(cOLycNusJaTetnic0cblK6HbOqHPDX6reA5uwybwPKgv(Y1xiyHupmafWu(ilRBWSyuieRikWkL0OcOLyc7vkJaTQyhAagGb0cZ4KAgW9ae4mW9aTyLsAubqFG2mAZxaTjmMf2ThcXYaAvilcNdB(cO9gNXj1mG2iCmeojqleSMy)45GqHcPM4y(2SVN4P(Y1xY89anrqcd(WAuKrBiI(sIKV36RLASmbduw(REqcd(WAuGvkPrLVe6lxFHGfkui1ehZ3M557Pagab4d4EGwSsjnQaOpqBeogcNeOLycNusJc5K)9WE8FT65uSEgTHi6ljs(EGMiiHbFynkYOnerF567bAIGeg8H1OaIY5umFdLNVsGuucj9)QofimSqbctB(YxsK8v6zmF56l1eCzDikNtX8nuE(kbsrjK0)R6uGWWcfimT5lG2mAZxaTs6)vDkqyyadGanf4EGwSsjnQaOpqBeogcNeOLycNusJc5K)9WE8FT65uSEgTHi6ljs(EGMiiHbFynkYOnerF567bAIGeg8H1OaIY5umFdLNVsGuucjeYqyJPcekqyAZx(sIKVspJ5lxFPMGlRdr5CkMVHYZxjqkkHecziSXubcfimT5lG2mAZxaTsiKHWgtfayae4oa3d0IvkPrfa9bAJWXq4KaTsGuucW661H7mdIvGDjapaAZOnFb0QNGlJ15FGQazSmadGaNcCpqlwPKgva0hOnJ28fqBwrKzWu3JPwd0Qqweoh28fqlbVIiZGP23tMATVXS81Gtqac99o(E8gw2KAFLaPOyH4lMXlF1jZMkW3ZN6ldJFPycFVPTrp3qu57vcv(gFfQ81gz03K5B6RbNGae6R9(2aXdFhZxiMQusJcG2iCmeojqlXeoPKgfYj)7H94)A1ZPy9mAdr0xsK89anrqcd(WAuKrBiI(Y13d0ebjm4dRrbeLZPy(gkpFpFQVKi5R0Zy(Y1xQj4Y6quoNI5BO8898PagaborG7bAXkL0OcG(aTr4yiCsG2mAdrSJfkpiZ3M55lF(sIKVK5leSqHcPM4y(2mpFp1xU(cbRj2pEoiuOqQjoMVnZZ3tKF(siqBgT5lG2egZc7hGAgcyaeGUcCpqlwPKgva0hOnchdHtc0smHtkPrHCY)Eyp(Vw9CkwpJ2qe9LejFpqteKWGpSgfz0gIOVC99anrqcd(WAuar5CkMVHYZxjqkkb1arj9)kHceM28LVKi5R0Zy(Y1xQj4Y6quoNI5BO88vcKIsqnqus)VsOaHPnFb0MrB(cOLAGOK(FfGbqGBaW9aTyLsAubqFG2iCmeojqBgTHi2XcLhK5lpFp7lxFjZxjqkkbyD96WDMbXkWUeGh(sIKVspJ5lxFPMGlRdr5CkMVH67P(siqBgT5lGwPmO)uDdoXgmadWaAn4unqJbCpabodCpqlwPKgva0hOnJ28fq7uSie0sjn25pWSmq5UcjoreOnchdHtc0sMVX)1QNtjaRRxhUlPNGltar5CkMVn7lF8ZxsK8n(Vw9CkHkHn6gmlg1dLtB(sar5CkwhPZbgnu5BZ(Yh)8LqF56lz(MrBiIDSq5bz(2mpF5ZxsK89anrcLd3dUEqTiJ2qe9LejFpqtKhFShC9GArgTHi6lxFjZxl1yzcW661H7jJLGAtGvkPrLVKi5Rct7Q3OMGltOgwkPXE(MYxc9LejFpqteKWGpSgfz0gIOVe6ljs(k9mMVC9LAcUSoeLZPy(gQV8D2xsK8vHPD1ButWLjudlL0yF4pvhPdgbn0xE(YpF56RLWa0e2iJD77hrRZh)8nuFpfOTszeODkwecAPKg78hywgOCxHeNicyaeGpG7bAXkL0OcG(aTz0MVaATlStnqM1ztWObAJWXq4KaTet4KsAuiN8Vh2J)RvpNI1ZOnerF56lz(AJm6BZ(2u(5ljs(ERVi)bohhOsmflcbTusJD(dmlduURqIte9LqG2kLrGw7c7udKzD2emAadGanf4EGwSsjnQaOpqBgT5lG2Nic5CHA5Pc6hphe2JWWml1aTr4yiCsGwIjCsjnkKt(3d7X)1QNtX6z0gIOVC9LmFTrg9TzFBk)8LejFV1xK)aNJdujMIfHGwkPXo)bMLbk3viXjI(Y13B9f5pW54avc7c7udKzD2emAFjeOTszeO9jIqoxOwEQG(XZbH9immZsnGbqG7aCpqlwPKgva0hOnJ28fqRbNQbANbAvilcNdB(cO9(l0xdovd08LZyx(AxOVxtWfYmFrMnYPHkFjMAqmeF5mATVsOVGmu5l1azMVzP89ihiQ8LZyx(sWp(yQdFWqFjBO8vcKIY3H575t9LHXVumFFOVAKXi03h6l91tWLrl6(EFjBO8naIPHqFTRS898P(YW4xkgHaTr4yiCsG2B9LycNusJc2bghQbvDdovd08LRVK5lz(AWPAGMWolKaPO6kqyAZx(gkpFpFQVC9n(Vw9CkrE8Xuh(GHcikNtX8TzF5JF(sIKVgCQgOjSZcjqkQUceM28LVn775t9LRVK5B8FT65ucW661H7s6j4YequoNI5BZ(Yh)8LejFJ)RvpNsOsyJUbZIr9q50MVequoNI1r6CGrdv(2SV8XpFj0xsK8nJ2qe7yHYdY8TzE(YNVC9vcKIsOsyJUbZIr9q50MVeGh(sOVC9LmFV1xdovd0egFIRK1J)RvpNYxsK81Gt1anHXNi(Vw9CkbeLZPy(sIKVet4KsAuyWPAGw)aopCSW(YZ3Z(sOVe6ljs(k9mMVC91Gt1anHDwibsr1vGW0MV8TzE(snbxwhIY5umadGaNcCpqlwPKgva0hOnchdHtc0ERVet4KsAuWoW4qnOQBWPAGMVC9LmFjZxdovd0egFcjqkQUceM28LVHYZ3ZN6lxFJ)RvpNsKhFm1HpyOaIY5umFB2x(4NVKi5RbNQbAcJpHeifvxbctB(Y3M998P(Y1xY8n(Vw9CkbyD96WDj9eCzcikNtX8TzF5JF(sIKVX)1QNtjujSr3GzXOEOCAZxcikNtX6iDoWOHkFB2x(4NVe6ljs(MrBiIDSq5bz(2mpF5ZxU(kbsrjujSr3GzXOEOCAZxcWdFj0xU(sMV36RbNQbAc7S4kz94)A1ZP8LejFn4unqtyNfX)1QNtjGOCofZxsK8LycNusJcdovd06hW5HJf2xE(YNVe6lH(sIKVspJ5lxFn4unqty8jKaPO6kqyAZx(2mpFPMGlRdr5CkgqBgT5lGwdovd04dWaiWjcCpqlwPKgva0hOnJ28fqRbNQbANbAz63aAn4unq7mqBeogcNeO9wFjMWjL0OGDGXHAqv3Gt1anF567T(AWPAGMWolUswhKHDjqkkF56lz(AWPAGMW4te)xREoLaIY5umFjrY3B91Gt1anHXN4kzDqg2LaPO8LqGwfYIW5WMVaAVju((LoSVFH((LVGm0xdovd089a(ehfY8n9vcKIkeFbzOV2f67Bxi03V8n(Vw9CkHVNqOVdLVfo2fc91Gt1anFpGpXrHmFtFLaPOcXxqg6R0Bx((LVX)1QNtjamacqxbUhOfRusJka6d0MrB(cO1Gt1an(aAJWXq4KaT36lXeoPKgfSdmoudQ6gCQgO5lxFV1xdovd0egFIRK1bzyxcKIYxU(sMVgCQgOjSZI4)A1ZPequoNI5ljs(ERVgCQgOjSZIRK1bzyxcKIYxcbAz63aAn4unqJpadWaAvivcQnG7biWzG7bAZOnFb0kpLQtbr8gIaTyLsAubqFadGa8bCpqlwPKgva0hO9paAzOb0MrB(cOLycNusJaTetnic0sMVi)bohhOsmflcbTusJD(dmlduURqIte9LejFr(dCooqLWUWo1azwNnbJ2xsK8f5pW54avINic5CHA5Pc6hphe2JWWml1(sOVC9LmFJ)RvpNsmflcbTusJD(dmlduURqItefqmvH9LejFJ)RvpNsyxyNAGmRZMGrlGOCofZxsK8n(Vw9CkXteHCUqT8ub9JNdc7ryyMLAbeLZPy(sOVKi5lz(I8h4CCGkHDHDQbYSoBcgTVKi5lYFGZXbQepreY5c1Ytf0pEoiShHHzwQ9LqF56lYFGZXbQetXIqqlL0yN)aZYaL7kK4erGwfYIW5WMVaAVzqKiwMVSdmoudQ81Gt1anMVs4ub(cYqLVCg7Y3e0E50MOV6PqgqlXe2RugbAzhyCOgu1n4unqdWaiqtbUhOfRusJka6d0(haTm0aAZOnFb0smHtkPrGwIPgebAJ)RvpNsWaLL)QhKWGpSgfquoNI5BO(EQVC91snwMGbkl)vpiHbFynkWkL0OYxU(sMVwQXYeG11Rd3L0tWLjWkL0OYxU(g)xREoLaSUED4UKEcUmbeLZPy(gQVNBQVC9n(Vw9CkHkHn6gmlg1dLtB(sar5CkwhPZbgnu5BO(EUP(sIKV36RLASmbyD96WDj9eCzcSsjnQ8LqGwIjSxPmc0E8VEQGoeSMy)45GqadGa3b4EGwSsjnQaOpq7Fa0YqdOnJ28fqlXeoPKgbAjMAqeO1snwMG9G6oeZdekWkL0OYxU(cbl03q9LpF56RLWa0e2iJD77hrR30t9nuFp1xU(snbxwhIY5umFB23t9LejFJprSYYe1eCzDQe9LRVwQXYekKA0OaRusJkF56B8FT65ucfsnAuar5CkMVH6leSqHnYy3(oFaTetyVszeO94F9ubDiyHmadGaNcCpqlwPKgva0hO9paAzOb0MrB(cOLycNusJaTetnic0MrBiIDSq5bz(YZ3Z(Y1xY89wFH5O6irSmrQumbsNHzmFjrYxyoQoseltKkftmLVn775t9LqGwIjSxPmc0YS(HoRAQaadGaNiW9aTyLsAubqFG2)aOLHgqBgT5lGwIjCsjnc0sm1GiqBgTHi2XcLhK5BZ88LpF56lz(ERVWCuDKiwMivkMaPZWmMVKi5lmhvhjILjsLIjq6mmJ5lxFjZxyoQoseltKkftar5CkMVn77P(sIKVutWL1HOCofZ3M99m)8LqFjeOLyc7vkJaTPsX6quoNcWaiaDf4EGwSsjnQaOpq7Fa0YqdOnJ28fqlXeoPKgbAjMAqeOLmFTuJLjyGYYF1dsyWhwJcSsjnQ8LRV367bAIGeg8H1OiJ2qe9LRVX)1QNtjyGYYF1dsyWhwJcikNtX8LejFV1xl1yzcgOS8x9Geg8H1OaRusJkFj0xU(sMVsGuucW661H7jJLGAtaE4ljs(APgltKq5W9NQBxyxLYfQeyLsAu5lxFpqtKhFShC9GArgTHi6ljs(kbsrjujSr3GzXOEOCAZxcWdF56ReifLqLWgDdMfJ6HYPnFjGOCofZ3M99uFjrY3mAdrSJfkpiZ3M55lF(Y1xfM2vplvxHXmSWMyJPc8LqGwIjSxPmc0kN8Vh2J)RvpNI1ZOneradGa3aG7bAXkL0OcG(aT)bqldnG2mAZxaTet4KsAeOLyQbrG24teRSmrnbxwNkrF56Rct7QNLQRWygwytSXub(Y1xjqkkHct7I1vGOGzzSHVH67D8LejFLaPOeYje(CqvpaLz2xyhRRSIOmwMa8WxsK8vcKIsyxWrR7meBGqb4HVKi5ReifLGcI1nCqvx(lMbF2yHfGh(sIKVsGuucnMQUu4osNu(qJcWdFjrYxjqkkr8kFwxkluaE4ljs(g)xREoLaSUED4EYyjO2equoNI5BO(EQVC9n(Vw9CkrE8Xuh(GHcikNtX8TzFpZpGwIjSxPmc0QaLp6CEWsXamacCcaCpqlwPKgva0hOnJ28fq7dAsqmBa0Qqweoh28fq7n15uwo1ub(EtzGGASmFVz6mae9Dy(M(EaNhowyG2iCmeojqR6nbXbcQXY6h6maefqKcISRusJ(Y13B91snwMaSUED4UKEcUmbwPKgv(Y13B9fMJQJeXYePsXeiDgMXamacCMFa3d0IvkPrfa9bAZOnFb0(GMeeZgaTr4yiCsGw1BcIdeuJL1p0zaikGifezxPKg9LRVz0gIyhluEqMVnZZx(8LRVK57T(APgltawxVoCxspbxMaRusJkFjrYxl1yzcW661H7s6j4YeyLsAu5lxFjZ34)A1ZPeG11Rd3L0tWLjGOCofZ3M9LmFpFQV0Y3mAdrSJfkpiZxA7R6nbXbcQXY6h6maefquoNI5lH(sIKVz0gIyhluEqMVnZZ3M6lH(siqBmCuJDlHbOXaiWzadGaNpdCpqlwPKgva0hOnJ28fq7dAsqmBa0QNc7rfq7jc0gHJHWjbAZOneXU6nbXbcQXY6h6mae9nuFZOneXowO8GmF56BgTHi2XcLhK5BZ88LpF56lz(ERVwQXYeG11Rd3L0tWLjWkL0OYxsK8n(Vw9CkbyD96WDj9eCzcikNtX8LRVsGuucW661H7s6j4Y6sGuuc1ZP8LqGwfYIW5WMVaAVju(Axie9nHOVyHYdY8vEySPc89MYnleFZJdDyFhZxYKanFR3x5hI(Axz57xr03de67j6ldJFPyekamacCMpG7bAXkL0OcG(aTr4yiCsGwiyHupmafmWdeYmyoLaRusJkF56lz(QEtqbFM1PqIiuarkiYUsjn6ljs(QEtiP)x1p0zaikGifezxPKg9LqG2mAZxaTpOjbXSbGbqGZnf4EGwSsjnQaOpqBgT5lGwopyP6SdSuieOvHSiCoS5lG2Bmsbr2fY8LUX0Uy(s3Gi5mFLaPO8L)bYmFLqQhI(QW0Uy(QarFXsXaAJWXq4KaTXNiwzzIAcUSovI(Y1xfM2vplvxHXmSWMyJPc8LRVK5Rct7QNLQRWygwKrBiIDikNtX8nuFjZ3GOYx6IVNfN6lH(sIKVsGuucfM2fRRarbeLZPy(gQVbrLVecyae48DaUhOfRusJka6d0YWiqB8FT65uc2dQ7qmpqOaIY5umG2mAZxaTCYXaAJWXq4KaTwQXYeShu3HyEGqbwPKgv(Y1xlHbOjSrg723pIwVPN6BO(EQVC91syaAcBKXU9D1G(2SVN6lxFJ)RvpNsWEqDhI5bcfquoNI5BO(sMVbrLV0fF5NGUEQVe6lxFZOneXowO8GmF557zadGaNpf4EGwSsjnQaOpqRczr4CyZxaTeS5y(s9qFPBmTlYz(s3GiTOBKA0OVdLVeycUmFjyMOV27BaA(Ymiwb2LVsGuu(kLXg(MS8aOLHrG24)A1ZPekmTlwxbIcikNtXaAZOnFb0YjhdOnchdHtc0gFIyLLjQj4Y6uj6lxFJ)RvpNsOW0UyDfikGOCofZ3q9niQ8LRVz0gIyhluEqMV889mGbqGZNiW9aTyLsAubqFGwggbAJ)RvpNsOqQrJcikNtXaAZOnFb0YjhdOnchdHtc0gFIyLLjQj4Y6uj6lxFJ)RvpNsOqQrJcikNtX8nuFdIkF56BgTHi2XcLhK5lpFpdyae4mDf4EGwSsjnQaOpqRczr4CyZxaTe8OnF5lbnmJ5BwkFpHhyHqMVKDcpWcHmA1I8hiwrK5lyXapoEOHkFNY3uP(sqiqBgT5lG2yQ19mAZxD9WmGw9WSELYiqRbNQbAmadGaNVba3d0IvkPrfa9bAZOnFb0gtTUNrB(QRhMb0QhM1RugbAJprSYYyagaboFcaCpqlwPKgva0hOnJ28fqBm16EgT5RUEygqREywVszeOfMXj1madGa8XpG7bAXkL0OcG(aTz0MVaAJPw3ZOnF11dZaA1dZ6vkJaTX)1QNtXamacW3zG7bAXkL0OcG(aTr4yiCsGwIjCsjnksLI1HOCoLVC9LmFJ)RvpNsOW0U6zP6kmMHfquoNI5BO(EMF(Y13B91snwMqHuJgfyLsAu5ljs(g)xREoLqHuJgfquoNI5BO(EMF(Y1xl1yzcfsnAuGvkPrLVKi5B8jIvwMOMGlRtLOVC9n(Vw9CkHct7I1vGOaIY5umFd13Z8Zxc9LRV36Rct7QNLQRWygwytSXubaTz0MVaAHGvpJ28vxpmdOvpmRxPmc0Mp2zObEayaeGp(aUhOfRusJka6d0gHJHWjbAZOneXowO8GmFBMNV85lxFvyAx9SuDfgZWcBInMkaOLzWjAae4mqBgT5lGwiy1ZOnF11dZaA1dZ6vkJaT5JDjqiZamacWxtbUhOfRusJka6d0gHJHWjbAZOneXowO8GmFBMNV85lxFjZ3B9vHPD1Zs1vymdlSj2yQaF56lz(g)xREoLqHPD1Zs1vymdlGOCofZ3M99m)8LRV36RLASmHcPgnkWkL0OYxsK8n(Vw9CkHcPgnkGOCofZ3M99m)8LRVwQXYekKA0OaRusJkFjrY34teRSmrnbxwNkrF56B8FT65ucfM2fRRarbeLZPy(2SVN5NVe6lHaTz0MVaAHGvpJ28vxpmdOvpmRxPmc0gGfcNypFeWaiaF3b4EGwSsjnQaOpqBeogcNeOnJ2qe7yHYdY8LNVNbAzgCIgabod0MrB(cOnMADpJ28vxpmdOvpmRxPmc0gGfcNiGbyaTbyHWj2ZhbUhGaNbUhOfRusJka6d0YWiqB8FT65uc2dQ7qmpqOaIY5umG2mAZxaTCYXaAJWXq4KaTwQXYeShu3HyEGqbwPKgv(Y1xlHbOjSrg723pIwVPN6BO(EQVC9LAcUSoeLZPy(2SVN6lxFJ)RvpNsWEqDhI5bcfquoNI5BO(sMVbrLV0fF5NGUEQVe6lxFZOneXowO8GmFdLNVnfWaiaFa3d0IvkPrfa9bAJWXq4KaTK57T(smHtkPrXX)6Pc6qWAI9JNdc9LejFLaPOemqLcRU6FzbeZO5lH(Y1xY8vcKIsOsyJUbZIr9q50MVeGh(Y1xiyHupmafkmv6bzwp(JwGvkPrLVC9nJ2qe7yHYdY8nuE(2uFjrY3mAdrSJfkpiZxE(YNVec0MrB(cOvHPD1J)Obmac0uG7bAXkL0OcG(aTr4yiCsGwjqkkbduPWQR(xwaXmA(sIKV36lXeoPKgfh)RNkOdbRj2pEoieOnJ28fqlEmkuEIagabUdW9aTyLsAubqFGwfYIW5WMVaAVju(AjmanFJHJ6Pc8Dy(QgwkPrvi(Y4mw8YxPm2Wx791UqFztfOr(VLWa08naleorF1dZ8DkMHPsa0MrB(cOfcw9mAZxD9WmGwMbNObqGZaTr4yiCsG2y4Og7yHYdY8LNVNbA1dZ6vkJaTbyHWjcyae4uG7bAXkL0OcG(aTz0MVaA58GLQZoWsHqG2iCmeojqlz(g)xREoLip(yQdFWqbeLZPy(2SVN6lxFvOeifLGczgcNkOZ5blLa8WxsK8vHsGuuckKziCQGoNhSucMLXg(2SVn1xc9LRVK5l1eCzDikNtX8nuFJ)RvpNsOW0U6zP6kmMHfquoNI5lT99m)8LejFPMGlRdr5CkMVn7B8FT65uI84JPo8bdfquoNI5lHaTXWrn2TegGgdGaNbmacCIa3d0IvkPrfa9bAZOnFb0sHmdHtf0zgCAGaTr4yiCsGwfkbsrjOqMHWPc6CEWsjywgB4BO88TP(Y134)A1ZPe5XhtD4dgkGOCofZ3q99uFjrYxfkbsrjOqMHWPc6CEWsjywgB4BO(EgOngoQXULWa0yae4mGbqa6kW9aTyLsAubqFG2mAZxaTuiZq4ubDMbNgiqBeogcNeOn(Vw9CkrE8Xuh(GHcikNtX8TzFp1xU(QqjqkkbfYmeovqNZdwkbZYydFd13ZaTXWrn2TegGgdGaNbmacCdaUhOfRusJka6d0MrB(cOLczgcNkOZm40abAvilcNdB(cO9(RH57W8fPOWOnerDyFPgTgH(Y5AIx(YgzMV09nR13cbnyQdXxjqZx21dQv(EarIyz(M(YIyLW59LZfcrFTl03uP(Y3RK5B921ub(AVVqm(YYyPeaTr4yiCsG2mAdrSREtqHmdHtf058GLY3M55BmCuJDSq5bz(Y1xfkbsrjOqMHWPc6CEWsjywgB4BO(EhadWamGwIiKnFbqa(4hF8Xp(47mqlNewtfWaAjyj43ycCtiWjyt8137VqFh5JhA(s9qFjpFSZqd8GCFHi)boqu5l7LrFtq7Ltdv(gVYkazcNgcAk03ZnX3t(freAOYxYTuJLjOh5(AVVKBPgltqpbwPKgvK7lzNPdHcNgcAk0x(AIVN8lIi0qLVKdblK6HbOGEK7R9(soeSqQhgGc6jWkL0OICFj7mDiu40qqtH(EInX3t(freAOYxYTuJLjOh5(AVVKBPgltqpbwPKgvK7lz8rhcfononeSe8BmbUje4eSj(679xOVJ8XdnFPEOVKNp2LaHmJCFHi)boqu5l7LrFtq7Ltdv(gVYkazcNgcAk03M2eFp5xerOHkFj3snwMGEK7R9(sULASmb9eyLsAurUVK1u6qOWPHGMc99onX3t(freAOYxYHGfs9WauqpY91EFjhcwi1ddqb9eyLsAurUVKDMoekCACAiyj43ycCtiWjyt8137VqFh5JhA(s9qFj3Gt1ang5(cr(dCGOYx2lJ(MG2lNgQ8nELvaYeone0uOVNBIVN8lIi0qLVKBPgltqpY91EFj3snwMGEcSsjnQi3xYothcfone0uOV3Pj(EYViIqdv(sUbNQbAIZc6rUV27l5gCQgOjSZc6rUVK1u6qOWPHGMc99onX3t(freAOYxYn4unqtWNGEK7R9(sUbNQbAcJpb9i3xY4JoekCAiOPqFpTj(EYViIqdv(sUbNQbAIZc6rUV27l5gCQgOjSZc6rUVKXhDiu40qqtH(EAt89KFreHgQ8LCdovd0e8jOh5(AVVKBWPAGMW4tqpY9LSMshcfone0uOVNyt89KFreHgQ8LCdovd0eNf0JCFT3xYn4unqtyNf0JCFj7mDiu40qqtH(EInX3t(freAOYxYn4unqtWNGEK7R9(sUbNQbAcJpb9i3xY4JoekCAiOPqFPRnX3t(freAOYxYn4unqtCwqpY91EFj3Gt1anHDwqpY9Lm(OdHcNgcAk0x6At89KFreHgQ8LCdovd0e8jOh5(AVVKBWPAGMW4tqpY9LSZ0HqHtJtdblb)gtGBcbobBIV(E)f67iF8qZxQh6l5byHWjsUVqK)ahiQ8L9YOVjO9YPHkFJxzfGmHtdbnf675M47j)Iicnu5l5qWcPEyakOh5(AVVKdblK6HbOGEcSsjnQi3xYothcfone0uOV81eFp5xerOHkFj3snwMGEK7R9(sULASmb9eyLsAurUVKDMoekCAiOPqF5Rj(EYViIqdv(soeSqQhgGc6rUV27l5qWcPEyakONaRusJkY9LSZ0HqHtdbnf6lFnX3t(freAOYxYJFPahtqpY91EFjp(LcCmb9eyLsAurUVKDMoekCAiOPqFBAt89KFreHgQ8LCiyHupmaf0JCFT3xYHGfs9WauqpbwPKgvK7lzNPdHcNgcAk03tBIVN8lIi0qLVKdblK6HbOGEK7R9(soeSqQhgGc6jWkL0OICFj7mDiu4040qWsWVXe4MqGtWM4RV3FH(oYhp08L6H(sE8jIvwgJCFHi)boqu5l7LrFtq7Ltdv(gVYkazcNgcAk03ZnX3t(freAOYxYTuJLjOh5(AVVKBPgltqpbwPKgvK7lzNPdHcNgcAk03M2eFp5xerOHkFj3snwMGEK7R9(sULASmb9eyLsAurUVKDMoekCAiOPqFBAt89KFreHgQ8LC2dQLMsjOh5(AVVKZEqT0ukb9eyLsAurUVKDMoekCAiOPqFVtt89KFreHgQ8LCl1yzc6rUV27l5wQXYe0tGvkPrf5(s2z6qOWPHGMc99onX3t(freAOYxYzpOwAkLGEK7R9(so7b1stPe0tGvkPrf5(s2z6qOWPHGMc990M47j)Iicnu5l5qWcPEyakOh5(AVVKdblK6HbOGEcSsjnQi3xY4JoekCAiOPqFpTj(EYViIqdv(so7b1stPe0JCFT3xYzpOwAkLGEcSsjnQi3xYothcfone0uOV01M47j)Iicnu5l5wQXYe0JCFT3xYTuJLjONaRusJkY9LSZ0HqHtdbnf67jqt89KFreHgQ8LC2dQLMsjOh5(AVVKZEqT0ukb9eyLsAurUVKXhDiu4040qWsWVXe4MqGtWM4RV3FH(oYhp08L6H(s(beJVSuAK7le5pWbIkFzVm6BcAVCAOY34vwbit40qqtH(ENM47j)Iicnu5l5wQXYe0JCFT3xYTuJLjONaRusJkY9nnFVrNqcYxYothcfone0uOVN2eFp5xerOHkFBh5t6llCzjD89MFZ91EFjiW0x5xbQbz((himTh6lz3Cc9LSZ0HqHtdbnf67PnX3t(freAOYxYn4unqtCwqpY91EFj3Gt1anHDwqpY9Lm(OdHcNgcAk03tSj(EYViIqdv(2oYN0xw4Ys647n)M7R9(sqGPVYVcudY89pqyAp0xYU5e6lzNPdHcNgcAk03tSj(EYViIqdv(sUbNQbAc(e0JCFT3xYn4unqty8jOh5(sgF0HqHtdbnf6lDTj(EYViIqdv(2oYN0xw4Ys647n3x79LGatFvdXHnF57FGW0EOVKrlc9Lm(OdHcNgcAk0x6At89KFreHgQ8LCdovd0eNf0JCFT3xYn4unqtyNf0JCFj7o0HqHtdbnf6lDTj(EYViIqdv(sUbNQbAc(e0JCFT3xYn4unqty8jOh5(s2P0HqHtdbnf67nOj(EYViIqdv(sULASmb9i3x79LCl1yzc6jWkL0OICFj7mDiu40qqtH(EdAIVN8lIi0qLVKh)sboMGEK7R9(sE8lf4yc6jWkL0OICFtZ3B0jKG8LSZ0HqHtdbnf67jqt89KFreHgQ8LCiyHupmaf0JCFT3xYHGfs9WauqpbwPKgvK7BA(EJoHeKVKDMoekCAiOPqFpbAIVN8lIi0qLVKdblK6HbOGEK7R9(soeSqQhgGc6jWkL0OICFj7mDiu4040qWsWVXe4MqGtWM4RV3FH(oYhp08L6H(sE8FT65umY9fI8h4arLVSxg9nbTxonu5B8kRaKjCAiOPqF5Rj(EYViIqdv(sULASmb9i3x79LCl1yzc6jWkL0OICFjJp6qOWPHGMc9LVM47j)Iicnu5l5qWcPEyakOh5(AVVKdblK6HbOGEcSsjnQi3xY4JoekCAiOPqF5Rj(EYViIqdv(so7b1stPe0JCFT3xYzpOwAkLGEcSsjnQi3xY4JoekCAiOPqFpXM47j)Iicnu5l5wQXYe0JCFT3xYTuJLjONaRusJkY9LSZ0HqHtdbnf67nOj(EYViIqdv(sULASmb9i3x79LCl1yzc6jWkL0OICFj7mDiu4040qWsWVXe4MqGtWM4RV3FH(oYhp08L6H(sEawiCI98rY9fI8h4arLVSxg9nbTxonu5B8kRaKjCAiOPqFp3eFp5xerOHkFj3snwMGEK7R9(sULASmb9eyLsAurUVKDMoekCAiOPqF5Rj(EYViIqdv(soeSqQhgGc6rUV27l5qWcPEyakONaRusJkY9LSZ0HqHtJtdblb)gtGBcbobBIV(E)f67iF8qZxQh6l5kKkb1g5(cr(dCGOYx2lJ(MG2lNgQ8nELvaYeone0uOVnTj(EYViIqdv(sULASmb9i3x79LCl1yzc6jWkL0OICFjRP0HqHtdbnf67DAIVN8lIi0qLVKBPgltqpY91EFj3snwMGEcSsjnQi3xY4JoekCAiOPqFPRnX3t(freAOYxYTuJLjOh5(AVVKBPgltqpbwPKgvK7lznLoekCAiOPqFpbAIVN8lIi0qLVKBPgltqpY91EFj3snwMGEcSsjnQi3xYothcfone0uOVN5xt89KFreHgQ8TDKpPVSWLL0X3BUV27lbbM(QgIdB(Y3)aHP9qFjJwe6lzNPdHcNgcAk03Z8Rj(EYViIqdv(sULASmb9i3x79LCl1yzc6jWkL0OICFjJp6qOWPHGMc9985M47j)Iicnu5l5wQXYe0JCFT3xYTuJLjONaRusJkY9LSZ0HqHtdbnf67z(AIVN8lIi0qLVKdblK6HbOGEK7R9(soeSqQhgGc6jWkL0OICFj7mDiu40qqtH(E(onX3t(freAOYxYTuJLjOh5(AVVKBPgltqpbwPKgvK7lzNPdHcNgcAk0x(o3eFp5xerOHkFj3snwMGEK7R9(sULASmb9eyLsAurUVKXhDiu40qqtH(YxtBIVN8lIi0qLVKBPgltqpY91EFj3snwMGEcSsjnQi3xY4JoekCACAUjYhp0qLVN5NVz0MV8vpmJjCAaAtq76HaTTJmOoT5RtctkdO9a(uJgbAV7D9LUX0U8LGHAcUmFVPRRxh2P5U31xcMOeemHH9LVtmeF5JF8XNtJtZDVRVN8kRaK1eNM7ExF5)(sWv8pqMjJLX81EFP7IUPfDJuJgPfDJPDX8LUbrFT33V0H9n(GL5RLWa0y(Y569nHOViDoWOHkFT3x9qe9v)vGVy9Gbx(AVVYPzi0xYYh7m0ap89UNju40C376l)3x6EyPKgv(2Mr4qnXj1(EZYO5Regtqg6RctLVbxpOM5RC2a9L6H(YsLV0nbdmHtZDVRV8FFVPztf4lb7dwkFBpWsHqFtPrp2GmFLFi6lLgPZiPd7lzP57DOTVmlJny(ofZWu57t57P0MWBQ8LUVzT(wiObtTVzP8vod77bejIL5l7LrFRN)dXOVSXatB(IjCAU7D9L)77nnBQaFjyImdHtf4BRbNgOVt5lb)eEJ8DO8n8d67vse9TE7AQaFrnd91EFvVVzP8LZxKB((erymp8LZdwkMVdZx6(M16BHGgm1cNM7ExF5)(EYRScqLVYzf2xYPMGlRdr5Ckg5(g)sn28vQz(AVV5XHoSVt5R0Zy(snbxgZ3V0H9LmnYy(Es62xojZqF)YxdMSlcfon39U(Y)9LGRuOY3SE7cH(EcbnjiMn8fldg2x79LHMVGh(Ym4xbi03B0XOq5jYeon39U(Y)99gJ6Ko(2EVVezcFj4NWBKV6pyI(YMkI(oMVqupiZ3V8n(fvkbQtdv(cZr1rIyzmHtZDVRV8FFV)es3NWM4RVemZO9qFBniwb2LVhWpY8Dk791Gt1anF1FWefononz0MVyIdigFzP0OnpAD828LttgT5lM4aIXxwknAZJwWCyyxHPYPjJ28ftCaX4llLgT5rlknYUIWKYCAYOnFXehqm(YsPrBE0kHYH7pv3UWUctvihqm(YsP1Trg510qgkE3APgltWaLL)QhKWGpSgDAURV3iIPgmnK5B6RbNQbAmFJ)RvpNkeFvdXrHkFLc77Dov479xdZxojZ341ZWY3K5lyD96W(Y5Hny((LV35uFzy8lLVsGqM5BmCuJSq8vc089kz(A)7RCwH9nQG(Iuuy0y(AVVbdr03034)A1ZPe0rOaHPnF5RAioSh67umdtLW3BcLVJroZxIPge99kz(wVVquoNsHqFHObclFphIVOMH(crdew(YpXPcNMmAZxmXbeJVSuA0MhTiMWjL0yivkJ8m4unqRFUZcxXq(dEm0gQqiMAqK35qiMAqSJAgYJFItdj(LAS5lEgCQgOjolUswhKHDjqkkUKzWPAGM4Si(Vw9CkHceM281n)MFNt5XpcDAYOnFXehqm(YsPrBE0IycNusJHuPmYZGt1aToFDw4kgYFWJH2qfcXudI8ohcXudIDuZqE8tCAiXVuJnFXZGt1anbFIRK1bzyxcKIIlzgCQgOj4te)xREoLqbctB(6MFZVZP84hHon313BeZg50qMVPVgCQgOX8LyQbrFLc7B8Lps4ub(AxOVX)1QNt57t5RDH(AWPAGwi(QgIJcv(kf2x7c9vbctB(Y3NYx7c9vcKIY3X89a(ehfYe(sWyY8n9LzqScSlFLF1qni0x79nyiI(M(Enbxi03d48WXc7R9(Ymiwb2LVgCQgOXcX3K5lhuR9nz(M(k)QHAqOVup03HY30xdovd08LZO1((qF5mATV1B(YcxrF5m2LVX)1QNtXeonz0MVyIdigFzP0OnpArmHtkPXqQug5zWPAGw)aopCSWH8h8yOnuHqm1Gip(cHyQbXoQziVZHe)sn28fVBn4unqtCwCLSoid7sGuuCn4unqtWN4kzDqg2LaPOirYGt1anbFIRK1bzyxcKIIlzKzWPAGMGpr8FT65ucfimT5RBUbNQbAc(esGuuDfimT5lcPlKDwCkTn4unqtWN4kzDjqkkcPlKrmHtkPrHbNQbAD(6SWvKqcBMmYm4unqtCwe)xREoLqbctB(6MBWPAGM4SqcKIQRaHPnFriDHSZItPTbNQbAIZIRK1LaPOiKUqgXeoPKgfgCQgO1p3zHRiHe60CxFVretnyAiZ3iieIL5ldnWdFPEOV2f6l)bMLnwyFFkFj4hFm1HpyOVNKUVX(Iuuy0yonz0MVyIdigFzP0OnpArmHtkPXqQug5rbQ19OcgcXudI8SuJLjsOC4(t1TlSRs5cvCJFPahte)I4htB(Q)uD7c7kmvonz0MVyIdigFzP0OnpArmHtkPXqQug5PIDOfcXudI8GGfs9WauOW0Uy9icTCklmxiyHupmafWu(ilRBWSyuieRi6040C3767nIoye0qLVireg2xBKrFTl03mAp03H5BsmhDkPrHttgT5lgp5PuDkiI3q0P5U(EZGirSmFzhyCOgu5RbNQbAmFLWPc8fKHkF5m2LVjO9YPnrF1tHmNMmAZxmAZJwet4KsAmKkLrESdmoudQ6gCQgOfcXudI8id5pW54avIPyriOLsASZFGzzGYDfsCIijsi)bohhOsyxyNAGmRZMGrtIeYFGZXbQepreY5c1Ytf0pEoiShHHzwQjKlzX)1QNtjMIfHGwkPXo)bMLbk3viXjIciMQWKif)xREoLWUWo1azwNnbJwar5CkgjsX)1QNtjEIiKZfQLNkOF8CqypcdZSulGOCofJqsKid5pW54avc7c7udKzD2emAsKq(dCooqL4jIqoxOwEQG(XZbH9immZsnHCr(dCooqLykwecAPKg78hywgOCxHeNi60C3767nLeoPKgzonz0MVy0MhTiMWjL0yivkJ8o(xpvqhcwtSF8CqyietniYl(Vw9Ckbduw(REqcd(WAuar5CkwONY1snwMGbkl)vpiHbFynYLml1yzcW661H7s6j4Y4g)xREoLaSUED4UKEcUmbeLZPyHEUPCJ)RvpNsOsyJUbZIr9q50MVequoNI1r6CGrdvHEUPKiDRLASmbyD96WDj9eCze60KrB(IrBE0IycNusJHuPmY74F9ubDiyHSqiMAqKNLASmb7b1DiMhiKleSWq5JRLWa0e2iJD77hrR30td9uUutWL1HOCofR5tjrk(eXkltutWL1PsKRLASmHcPgnYn(Vw9CkHcPgnkGOCofluiyHcBKXU9D(CAYOnFXOnpArmHtkPXqQug5XS(HoRAQGqiMAqKxgTHi2XcLhKX7mxYUfMJQJeXYePsXeiDgMXircMJQJeXYePsXet185tj0PjJ28fJ28OfXeoPKgdPszKxQuSoeLZPcHyQbrEz0gIyhluEqwZ84Jlz3cZr1rIyzIuPycKodZyKibZr1rIyzIuPycKodZyCjdMJQJeXYePsXequoNI18PKirnbxwhIY5uSMpZpcj0PjJ28fJ28OfXeoPKgdPszKNCY)Eyp(Vw9CkwpJ2qedHyQbrEKzPgltWaLL)QhKWGpSg5E7bAIGeg8H1OiJ2qe5g)xREoLGbkl)vpiHbFynkGOCofJePBTuJLjyGYYF1dsyWhwJeYLmjqkkbyD96W9KXsqTjapirYsnwMiHYH7pv3UWUkLluX9anrE8XEW1dQfz0gIijssGuucvcB0nywmQhkN28La8GReifLqLWgDdMfJ6HYPnFjGOCofR5tjrkJ2qe7yHYdYAMhFCvyAx9SuDfgZWcBInMkGqNMmAZxmAZJwet4KsAmKkLrEkq5JoNhSuSqiMAqKx8jIvwMOMGlRtLixfM2vplvxHXmSWMyJPc4kbsrjuyAxSUcefmlJnc9oKijbsrjKti85GQEakZSVWowxzfrzSmb4bjssGuuc7coADNHydekapirscKIsqbX6goOQl)fZGpBSWcWdsKKaPOeAmvDPWDKoP8HgfGhKijbsrjIx5Z6szHcWdsKI)RvpNsawxVoCpzSeuBcikNtXc9uUX)1QNtjYJpM6Whmuar5CkwZN5NtZD99M6CklNAQaFVPmqqnwMV3mDgaI(omFtFpGZdhlSttgT5lgT5rRh0KGy2iKHIN6nbXbcQXY6h6maefqKcISRusJCV1snwMaSUED4UKEcUmU3cZr1rIyzIuPycKodZyonz0MVy0MhTEqtcIzJqIHJASBjmangVZHmu8uVjioqqnww)qNbGOaIuqKDLsAKBgTHi2XcLhK1mp(4s2TwQXYeG11Rd3L0tWLrIKLASmbyD96WDj9eCzCjl(Vw9CkbyD96WDj9eCzcikNtXAMSZNEZZOneXowO8GmAREtqCGGASS(HodarbeLZPyesIugTHi2XcLhK1mVMsiHon313BcLV2fcrFti6lwO8GmFLhgBQaFVPCZcX384qh23X8LmjqZ369v(HOV2vw((ve99aH(EI(YW4xkgHcNMmAZxmAZJwpOjbXSri6PWEuX7edzO4LrBiID1BcIdeuJL1p0zaigAgTHi2XcLhKXnJ2qe7yHYdYAMhFCj7wl1yzcW661H7s6j4Yirk(Vw9CkbyD96WDj9eCzcikNtX4kbsrjaRRxhUlPNGlRlbsrjupNIqNMmAZxmAZJwpOjbXSridfpiyHupmafmWdeYmyofxYuVjOGpZ6uirekGifezxPKgjrs9Mqs)VQFOZaquarkiYUsjnsOtZD99gJuqKDHmFPBmTlMV0nisoZxjqkkF5FGmZxjK6HOVkmTlMVkq0xSumNMmAZxmAZJwCEWs1zhyPqyidfV4teRSmrnbxwNkrUkmTREwQUcJzyHnXgtfWLmfM2vplvxHXmSiJ2qe7quoNIfkzbrfD5S4ucjrscKIsOW0UyDfikGOCofl0GOIqNMmAZxmAZJwCYXcHHrEX)1QNtjypOUdX8aHcikNtXczO4zPgltWEqDhI5bc5AjmanHnYy3((r06n90qpLRLWa0e2iJD77QbB(uUX)1QNtjypOUdX8aHcikNtXcLSGOIUWpbD9uc5MrBiIDSq5bz8o70CxFjyZX8L6H(s3yAxKZ8LUbrAr3i1OrFhkFjWeCz(sWmrFT33a08LzqScSlFLaPO8vkJn8nz5HttgT5lgT5rlo5yHWWiV4)A1ZPekmTlwxbIcikNtXczO4fFIyLLjQj4Y6ujYn(Vw9CkHct7I1vGOaIY5uSqdIkUz0gIyhluEqgVZonz0MVy0MhT4KJfcdJ8I)RvpNsOqQrJcikNtXczO4fFIyLLjQj4Y6ujYn(Vw9CkHcPgnkGOCofl0GOIBgTHi2XcLhKX7StZD9LGhT5lFjOHzmFZs57j8aleY8LSt4bwiKrRwK)aXkImFblg4XXdnu57u(Mk1xccDAYOnFXOnpAftTUNrB(QRhMfsLYipdovd0yonz0MVy0MhTIPw3ZOnF11dZcPszKx8jIvwgZPjJ28fJ28Ovm16EgT5RUEywivkJ8GzCsnZP5U313mAZxmAZJwmK)aXkIHmu8YOneXowO8GmEN5ERct7Q3OMGltOgwkPXE(MIRLASmbduw(REqcd(WAmKkLrEbjmO)hyHWM8GMeeZgnHczgcNkOZm40aBcfYmeovqNzWPb2egOS8x9Geg8H1ytsOC4(t1TlSRWu1efM2vp(JoKHINeifLGbQuy1v)llapAIct7Qh)r3efM2vp(JUjS4dcdWoZGtdmKHINcLaPOeuiZq4ubDopyPemlJnA(onHfFqya2zgCAGHmu8uOeifLGczgcNkOZ5blLGzzSrZ3PjuiZq4ubDMbNgOtZDVRVz0MVy0MhTyi)bIvedzO4LrBiIDSq5bz8oZ9wfM2vVrnbxMqnSusJ98nf3BTuJLjyGYYF1dsyWhwJHuPmY7pWcHnHczgcNkOZm40aBcfYmeovqNzWPb2KJ3MVAcyD96WDj9eCznrLWgDdMfJ6HYPnF1K84JPo8bdDAYOnFXOnpAftTUNrB(QRhMfsLYiV4)A1ZPyonz0MVy0MhTGGvpJ28vxpmlKkLrE5JDgAGhHmu8iMWjL0OivkwhIY5uCjl(Vw9CkHct7QNLQRWygwar5CkwON5h3BTuJLjui1OrsKI)RvpNsOqQrJcikNtXc9m)4APgltOqQrJKifFIyLLjQj4Y6ujYn(Vw9CkHct7I1vGOaIY5uSqpZpc5ERct7QNLQRWygwytSXubonz0MVy0MhTGGvpJ28vxpmlKkLrE5JDjqiZcHzWjA8ohYqXlJ2qe7yHYdYAMhFCvyAx9SuDfgZWcBInMkWPjJ28fJ28OfeS6z0MV66HzHuPmYlaleoXE(yidfVmAdrSJfkpiRzE8XLSBvyAx9SuDfgZWcBInMkGlzX)1QNtjuyAx9SuDfgZWcikNtXA(m)4ERLASmHcPgnsIu8FT65ucfsnAuar5CkwZN5hxl1yzcfsnAKeP4teRSmrnbxwNkrUX)1QNtjuyAxSUcefquoNI18z(riHonz0MVy0MhTIPw3ZOnF11dZcPszKxawiCIHWm4enENdzO4LrBiIDSq5bz8o7040C376lb)Vr(sFqiZCAYOnFXe5JDjqiZ4f1jNPc6SRu9CyHmu8YOneXowO8GSq5DQttgT5lMiFSlbczgT5rROo5mvqNDLQNdlKHIxgTHi2XcLhKX7e5QW0U6nQj4YeuCEWsHQULWa0ynZRPonz0MVyI8XUeiKz0MhT48GLQZoWsHWqgkEwQXYesGqMnvqN9qKXLmfM2vVrnbxMGIZdwku1TegGgJxgTHi2XcLhKrIKct7Q3OMGltqX5blfQ6wcdqJ1mVMsijswQXYesGqMnvqN9qKX1snwMiQtotf0zxP65W4QW0U6nQj4YeuCEWsHQULWa0ynZ7SttgT5lMiFSlbczgT5rlfM2vp(JoKHIhzsGuucgOsHvx9VSaIz0ir6wIjCsjnko(xpvqhcwtSF8CqiHCjtcKIsOsyJUbZIr9q50MVeGhCHGfs9WauOWuPhKz94pAUz0gIyhluEqwO8Akjsz0gIyhluEqgp(i0PjJ28ftKp2LaHmJ28OfEmkuEIHmu8GG1e7hphekui1ehluYoZpARW0U6nQj4YeuCEWsHQULWa0y0LMsixfM2vVrnbxMGIZdwku1TegGgl0tK7Tet4KsAuC8VEQGoeSMy)45GqsKKaPOemojuEQGU8Wmb4HttgT5lMiFSlbczgT5rl8yuO8edzO4bbRj2pEoiuOqQjowO8DkxfM2vVrnbxMGIZdwku1TegGgR5t5ElXeoPKgfh)RNkOdbRj2pEoi0PjJ28ftKp2LaHmJ28OfEmkuEIHmu8UvHPD1ButWLjO48GLcvDlHbOX4ElXeoPKgfh)RNkOdbRj2pEoiKejQj4Y6quoNIf6PKibZr1rIyzIuPycKodZyCH5O6irSmrQumbeLZPyHEQttgT5lMiFSlbczgT5rlopyP6SdSui0PjJ28ftKp2LaHmJ28OfEmkuEIHmu8ULycNusJIJ)1tf0HG1e7hphe6040C376lb)Vr(2Ig4HttgT5lMiFSZqd8GxwH7QsfYqXtHPD1ButWLjO48GLcvDlHbOXAMxmCuJDSq5bzKiPW0U6nQj4YeuCEWsHQULWa0ynZ7usKU1snwMqceYSPc6ShImsKG5O6irSmrQumbsNHzmUWCuDKiwMivkMaIY5uSq5D(mjsspJXLAcUSoeLZPyHY78zNMmAZxmr(yNHg4bT5rlfM2vp(JoKHI3Tet4KsAuC8VEQGoeSMy)45GqUKjbsrjujSr3GzXOEOCAZxcWdUqWcPEyakuyQ0dYSE8hn3mAdrSJfkpiluEnLePmAdrSJfkpiJhFe60KrB(IjYh7m0apOnpAHhJcLNyidfVBjMWjL0O44F9ubDiynX(XZbHonz0MVyI8XodnWdAZJwuiZq4ubDMbNgyiXWrn2TegGgJ35qgkEkucKIsqHmdHtf058GLsWSm2iuEnLB8FT65uI84JPo8bdfquoNIfAtDAYOnFXe5JDgAGh0MhTOqMHWPc6mdonWqIHJASBjmangVZHmu8uOeifLGczgcNkOZ5blLGzzSrONDAYOnFXe5JDgAGh0MhTOqMHWPc6mdonWqIHJASBjmangVZHmu8GGfkSrg723VtOKf)xREoLqHPD1Zs1vymdlGOCofJ7TwQXYekKA0ijsX)1QNtjui1OrbeLZPyCTuJLjui1OrsKIprSYYe1eCzDQe5g)xREoLqHPDX6kquar5CkgHon31xc2lS81syaA(Y4KhmFti6RAyPKgvH4RDnmF5mATVA08n8d6l7alLVqWcz0IZdwkMVtXmmv((u(YjhBQaFPEOV0Dr30IUrQrJ0IUX0UiN5lDdIcNMmAZxmr(yNHg4bT5rlopyP6SdSuimKHIhz3YqZMkGjIHJAKejfM2vVrnbxMGIZdwku1TegGgRzEXWrn2XcLhKrixfkbsrjOqMHWPc6CEWsjywgB0Ct5cbluyJm2TV30qJ)RvpNsKv4UQucikNtXCACAU7D99M928LttgT5lMi(Vw9CkgVJ3MVczO4rmHtkPrHCY)Eyp(Vw9CkwpJ2qejr6anrqcd(WAuKrBiICpqteKWGpSgfquoNIfkp(orsKKEgJl1eCzDikNtXcLVt0P5U313t(Vw9CkMttgT5lMi(Vw9CkgT5rRekhU)uD7c7kmvHmu8I)RvpNsawxVoCxspbxMaIY5uSqPRCJ)RvpNsOsyJUbZIr9q50MVequoNI1r6CGrdvHsx5APgltawxVoCxspbxgxYyO1L(cKjSbH8Dd635iY1syaAcBKXU99JO1B6PHEhsKULHwx6lqMWgeY3nOFNJijsutWL1HOCofRz(4h)iKlzX)1QNtjsPxEQ0MV66rwsar5CkwONVbCjdcwi1ddqrk9YtL28fRtbX6ggMej2dQLMsjAGeNI1))gI6PciKePBHGfs9WauKsV8uPnFX6uqSUHH5El7b1stPenqItX6)Fdr9ubeYLS4)A1ZPe5XhtD4dgkGOCofRJ05aJgQcLUYLycNusJckqTUhvqsKULycNusJckqTUhvqsKiMWjL0Oqf7qJqsKU1snwMaSUED4UKEcUmsKKEgJl1eCzDikNtXcTPN60KrB(IjI)RvpNIrBE0I9G6oeZdegsmCuJDlHbOX4DoKHINLWa0e2iJD77hrR30td9uUKzjmanHnYy3(UAWMpLBgTHi2XcLhKfkVMsIedTU0xGmHniKVBq)ohrUsGuucvcB0nywmQhkN28La8GBgTHi2XcLhKfkVt5s2TkmTREwQUcJzyHnXgtfqIu8jIvwMOMGlRtLiHe60CxFjy81kMV0xpbxMVup0xWdFT33t9LHXVumFT3xw4k6lNXU8LGF8Xuh(GHH47j0UqiNHHH4lid9LZyx(s3jSHV3dZIr9q50MVeonz0MVyI4)A1ZPy0MhTaRRxhUlPNGllKHIhXeoPKgfmRFOZQMkGlzX)1QNtjYJpM6Whmuar5CkwhPZbgnuf6PKif)xREoLip(yQdFWqbeLZPyDKohy0qvZN5hHCjl(Vw9CkHkHn6gmlg1dLtB(sar5CkwObrfjssGuucvcB0nywmQhkN28La8GqNMmAZxmr8FT65umAZJwG11Rd3L0tWLfYqXJycNusJIuPyDikNtrIK0ZyCPMGlRdr5CkwO8D2PjJ28fte)xREofJ28OLkHn6gmlg1dLtB(kKHIhXeoPKgfmRFOZQMkGlzQ3eG11Rd3L0tWL1vVjGOCofJePBTuJLjaRRxhUlPNGlJqNMmAZxmr8FT65umAZJwQe2OBWSyupuoT5RqgkEet4KsAuKkfRdr5CksKKEgJl1eCzDikNtXcLVZonz0MVyI4)A1ZPy0MhTYJpM6WhmmKHIxgTHi2XcLhKX7mxfkbsrjOqMHWPc6CEWsjywgB0mV7WLSBjMWjL0OGcuR7rfKejIjCsjnkOa16Eub5sw8FT65ucW661H7s6j4YequoNI18z(rIu8FT65ucvcB0nywmQhkN28LaIY5uSosNdmAOQ5Z8J7TwQXYeG11Rd3L0tWLriHonz0MVyI4)A1ZPy0MhTYJpM6WhmmKy4Og7wcdqJX7CidfVmAdrSJfkpiRzE8XvHsGuuckKziCQGoNhSucMLXgnZ7oCVvHPD1Zs1vymdlSj2yQaNMmAZxmr8FT65umAZJwmqz5V6bjm4dRXqgkEqWAI9JNdcfkKAIJf657Wn(Vw9CkbyD96WDj9eCzcikNtXc9Ct5g)xREoLqLWgDdMfJ6HYPnFjGOCofRJ05aJgQc9CtDAYOnFXeX)1QNtXOnpAbwxVoCpzSeuBHmu8iMWjL0OGz9dDw1ubCvOeifLGczgcNkOZ5blLGzzSrO8XLSd0e5Xh7bxpOwKrBiIKijbsrjujSr3GzXOEOCAZxcWdUX)1QNtjYJpM6Whmuar5CkwZN5hjsX)1QNtjYJpM6Whmuar5CkwZN5h34)A1ZPeQe2OBWSyupuoT5lbeLZPynFMFe60KrB(IjI)RvpNIrBE0cSUED4EYyjO2cjgoQXULWa0y8ohYqXlJ2qe7yHYdYAMhFCvOeifLGczgcNkOZ5blLGzzSrO8XLSd0e5Xh7bxpOwKrBiIKijbsrjujSr3GzXOEOCAZxcWdsKI)RvpNsOW0U6zP6kmMHfquoNIfAqurOttgT5lMi(Vw9CkgT5rlyomSRWufYqX72d0ebxpOwKrBiIon39U(s3dlL0OkeF5FGmZ36nFHyQ1H9TEOCQ9vcVsIZd91UsJCMVCEOD57biKbovGVtX)dszu40C376BgT5lMi(Vw9CkgT5rlwgHd1eNu3pYOfYqXlJ2qe7yHYdYAMhFCVvcKIsOsyJUbZIr9q50MVeGhCJ)RvpNsOsyJUbZIr9q50MVequoNI18PKij9mgxQj4Y6quoNIfAqu5040C3767jFIyLL5lbxA0JniZPjJ28fteFIyLLX4X4Kq5Pc6YdZczO4rmHtkPrbZ6h6SQPc4cbRj2pEoiuOqQjowZNprUKf)xREoLip(yQdFWqbeLZPyKiDRLASmrcLd3FQUDHDvkxOIB8FT65ucvcB0nywmQhkN28LaIY5umcjrs6zmUutWL1HOCofl0ZNDAURVTO5R9(cYqFtkdH(MhF03H57x(Es623K5R9(EarIyz((erympoMkW3B8nZxoxJg9LHMnvGVGh(Es6MCMttgT5lMi(eXklJrBE0IXjHYtf0LhMfYqXl(Vw9CkrE8Xuh(GHcikNtX4swgTHi2XcLhK1mp(4MrBiIDSq5bzHY7uUqWAI9JNdcfkKAIJ18z(rBYYOneXowO8Gm6YjsixIjCsjnksLI1HOCofjsz0gIyhluEqwZNYfcwtSF8CqOqHutCSMVd)i0PjJ28fteFIyLLXOnpALsV8uPnF11JSuidfpIjCsjnkyw)qNvnva3BzpOwAkLqJPQlfUJ0jLp0ixYI)RvpNsKhFm1HpyOaIY5umsKU1snwMiHYH7pv3UWUkLluXn(Vw9CkHkHn6gmlg1dLtB(sar5CkgHCHGfkSrg723VtZsGuuciynXE8HqWdB(sar5CkgjsspJXLAcUSoeLZPyHY3zNMmAZxmr8jIvwgJ28Ovk9YtL28vxpYsHmu8iMWjL0OGz9dDw1ubCzpOwAkLqJPQlfUJ0jLp0ixYuVjaRRxhUlPNGlRREtar5CkwZNptI0TwQXYeG11Rd3L0tWLXn(Vw9CkHkHn6gmlg1dLtB(sar5CkgHonz0MVyI4teRSmgT5rRu6LNkT5RUEKLczO4rmHtkPrbZ6h6SQPc4YEqT0ukrdK4uS()3qupvaxYuOeifLGczgcNkOZ5blLGzzSrZ8Ud3BHGfs9WauKsV8uPnFX6uqSUHHjrccwi1ddqrk9YtL28fRtbX6ggMB8FT65uI84JPo8bdfquoNIrOttgT5lMi(eXklJrBE0kLE5PsB(QRhzPqgkEet4KsAuKkfRdr5CkUqWcf2iJD773PzjqkkbeSMyp(qi4HnFjGOCofZPjJ28fteFIyLLXOnpAXUYydn2TlSdwCEODfoKHIhXeoPKgfmRFOZQMkGlzX)1QNtjYJpM6Whmuar5CkwZN5hjs3APgltKq5W9NQBxyxLYfQ4g)xREoLqLWgDdMfJ6HYPnFjGOCofJqsKKEgJl1eCzDikNtXc98Ponz0MVyI4teRSmgT5rl2vgBOXUDHDWIZdTRWHmu8iMWjL0OivkwhIY5uCjtHPD1Zs1vymdlSj2yQasKG5O6irSmrQumbeLZPyHY78Di0PjJ28fteFIyLLXOnpArPr2veMuwidfp2dQLMsjoazgOg7ie8WMVirI9GAPPucIVoTrJD2RjILX9wjqkkbXxN2OXo71eXY6xGYz9JsaEeYugcHGhwFKLr1KgY7CitziecEy9a9lLAENdzkdHqWdRpu8ypOwAkLG4RtB0yN9AIyzonon39U(2ovGg99(egGMttgT5lMialeorEkmTRE8hDidfVBjMWjL0O44F9ubDiynX(XZbHCjtcKIsWavkS6Q)LfqmJgjsqWAI9JNdcfkKAIJfkVZnL2KbblK6HbOaMYhzzDdMfJcHyfr6stPTct7Q3OMGltablK6HbO4kmZq4K0LMsiHKiDGMiiHbFynkYOnerUqWcdLxtjrIAcUSoeLZPyHEMFCVvHsGuuckKziCQGoNhSucWdNMmAZxmrawiCI0MhTYkCxvQqgkEKzPgltOqQrJcSsjnQirk(eXkltutWL1PsKejiyHupmafhxycF5VqgHCjJSBjMWjL0O44F9ubDiyHmsKIprSYYe1eCzDQe5APgltOqQrJCJFPahtWzSleovqpa(GLIqsKKEgJl1eCzDikNtXc9ucDAYOnFXebyHWjsBE0IZdwQo7alfcdzO4rmHtkPrHcu(OZ5blfJRcLaPOeuiZq4ubDopyPemlJnAM3zUX)1QNtjYJpM6Whmuar5CkwhPZbgnu185t5)KbblK6HbOqHPspiZ6XF00LZ8JqU3smHtkPrXX)6Pc6qWczonz0MVyIaSq4ePnpAX5blvNDGLcHHmu8uOeifLGczgcNkOZ5blLGzzSrZnL7Tet4KsAuC8VEQGoeSqgjskucKIsqHmdHtf058GLsaEWLAcUSoeLZPyHsMcLaPOeuiZq4ubDopyPemlJnOlbrfHonz0MVyIaSq4ePnpAPW0U6XF0Hmu8GG1e7hphekui1ehluE8XpAtgeSqQhgGcykFKL1nywmkeIvePl3H2kmTREJAcUmbeSqQhgGIRWmdHtsxUdHCVLycNusJIJ)1tf0HG1e7hphe60KrB(IjcWcHtK28OffYmeovqNzWPbgYqXtHsGuuckKziCQGoNhSucMLXgHEhU3smHtkPrXX)6Pc6qWczonz0MVyIaSq4ePnpAPW0U6XF0Hmu8ULycNusJIJ)1tf0HG1e7hphe60KrB(IjcWcHtK28OfNhSuD2bwkegYqXtHsGuuckKziCQGoNhSucMLXgnZ7mxiyHHYh3BjMWjL0O44F9ubDiyHmUX)1QNtjYJpM6Whmuar5CkwhPZbgnu18Ponon39U(EcIfcNOVe8)g57ndopCSWonz0MVyIaSq4e75J84KJfcdJ8I)RvpNsWEqDhI5bcfquoNIfYqXZsnwMG9G6oeZdeY1syaAcBKXU99JO1B6PHEkxQj4Y6quoNI18PCJ)RvpNsWEqDhI5bcfquoNIfkzbrfDHFc66PeYnJ2qe7yHYdYcLxtDAYOnFXebyHWj2ZhPnpAPW0U6XF0Hmu8i7wIjCsjnko(xpvqhcwtSF8CqijssGuucgOsHvx9VSaIz0iKlzsGuucvcB0nywmQhkN28La8GleSqQhgGcfMk9GmRh)rZnJ2qe7yHYdYcLxtjrkJ2qe7yHYdY4XhHonz0MVyIaSq4e75J0MhTWJrHYtmKHINeifLGbQuy1v)llGygnsKULycNusJIJ)1tf0HG1e7hphe60CxFVju(AjmanFJHJ6Pc8Dy(QgwkPrvi(Y4mw8YxPm2Wx791UqFztfOr(VLWa08naleorF1dZ8DkMHPs40KrB(IjcWcHtSNpsBE0ccw9mAZxD9WSqQug5fGfcNyimdorJ35qgkEXWrn2XcLhKX7SttgT5lMialeoXE(iT5rlopyP6SdSuimKy4Og7wcdqJX7CidfpYI)RvpNsKhFm1HpyOaIY5uSMpLRcLaPOeuiZq4ubDopyPeGhKiPqjqkkbfYmeovqNZdwkbZYyJMBkHCjJAcUSoeLZPyHg)xREoLqHPD1Zs1vymdlGOCofJ2N5hjsutWL1HOCofR54)A1ZPe5XhtD4dgkGOCofJqNMmAZxmrawiCI98rAZJwuiZq4ubDMbNgyiXWrn2TegGgJ35qgkEkucKIsqHmdHtf058GLsWSm2iuEnLB8FT65uI84JPo8bdfquoNIf6PKiPqjqkkbfYmeovqNZdwkbZYyJqp70KrB(IjcWcHtSNpsBE0IczgcNkOZm40adjgoQXULWa0y8ohYqXl(Vw9CkrE8Xuh(GHcikNtXA(uUkucKIsqHmdHtf058GLsWSm2i0Zon3137VgMVdZxKIcJ2qe1H9LA0Ae6lNRjE5lBKz(s33SwFle0GPoeFLanFzxpOw57bejIL5B6llIvcN3xoxie91UqFtL6lFVsMV1Bxtf4R9(cX4llJLs40KrB(IjcWcHtSNpsBE0IczgcNkOZm40adzO4LrBiID1BckKziCQGoNhSunZlgoQXowO8GmUkucKIsqHmdHtf058GLsWSm2i074040CxFVXzCsnZPjJ28ftaZ4KAgVegZc72dHyzHmu8GG1e7hphekui1ehR5t8uUKDGMiiHbFynkYOnersKU1snwMGbkl)vpiHbFynkWkL0OIqUqWcfkKAIJ1mVtDAYOnFXeWmoPMrBE0ss)VQtbcdhYqXJycNusJc5K)9WE8FT65uSEgTHisI0bAIGeg8H1OiJ2qe5EGMiiHbFynkGOCofluEsGuucj9)QofimSqbctB(IejPNX4snbxwhIY5uSq5jbsrjK0)R6uGWWcfimT5lNMmAZxmbmJtQz0MhTKqidHnMkiKHIhXeoPKgfYj)7H94)A1ZPy9mAdrKePd0ebjm4dRrrgTHiY9anrqcd(WAuar5CkwO8KaPOesiKHWgtfiuGW0MVirs6zmUutWL1HOCofluEsGuucjeYqyJPcekqyAZxonz0MVycygNuZOnpAPNGlJ15FGQazSSqgkEsGuucW661H7mdIvGDjapCAURVe8kImdMAFpzQ1(gZYxdobbi03747XByztQ9vcKIIfIVygV8vNmBQaFpFQVmm(LIj89M2g9CdrLVxju5B8vOYxBKrFtMVPVgCccqOV27Bdep8DmFHyQsjnkCAYOnFXeWmoPMrBE0kRiYmyQ7XuRdzO4rmHtkPrHCY)Eyp(Vw9CkwpJ2qejr6anrqcd(WAuKrBiICpqteKWGpSgfquoNIfkVZNsIK0ZyCPMGlRdr5CkwO8oFQttgT5lMaMXj1mAZJwjmMf2pa1mmKHIxgTHi2XcLhK1mp(irImiyHcfsnXXAM3PCHG1e7hphekui1ehRzENi)i0PjJ28ftaZ4KAgT5rlQbIs6)vHmu8iMWjL0Oqo5FpSh)xREofRNrBiIKiDGMiiHbFynkYOnerUhOjcsyWhwJcikNtXcLNeifLGAGOK(FLqbctB(IejPNX4snbxwhIY5uSq5jbsrjOgikP)xjuGW0MVCAYOnFXeWmoPMrBE0skd6pv3GtSblKHIxgTHi2XcLhKX7mxYKaPOeG11Rd3zgeRa7saEqIK0ZyCPMGlRdr5CkwONsOtJtZDVRV3dNQbAmNMmAZxmHbNQbAmEGmSpgkhsLYiVPyriOLsASZFGzzGYDfsCIyidfpYI)RvpNsawxVoCxspbxMaIY5uSM5JFKif)xREoLqLWgDdMfJ6HYPnFjGOCofRJ05aJgQAMp(rixYYOneXowO8GSM5XhjshOjsOC4EW1dQfz0gIijshOjYJp2dUEqTiJ2qe5sMLASmbyD96W9KXsqTrIKct7Q3OMGltOgwkPXE(MIqsKoqteKWGpSgfz0gIiHKij9mgxQj4Y6quoNIfkFNjrsHPD1ButWLjudlL0yF4pvhPdgbnKh)4AjmanHnYy3((r068XVqp1PjJ28ftyWPAGgJ28Ofid7JHYHuPmYZUWo1azwNnbJoKHIhXeoPKgfYj)7H94)A1ZPy9mAdrKlz2iJn3u(rI0Ti)bohhOsmflcbTusJD(dmlduURqItej0PjJ28ftyWPAGgJ28Ofid7JHYHuPmY7jIqoxOwEQG(XZbH9immZsDidfpIjCsjnkKt(3d7X)1QNtX6z0gIixYSrgBUP8JePBr(dCooqLykwecAPKg78hywgOCxHeNiY9wK)aNJdujSlStnqM1ztWOj0P5U(E)f6RbNQbA(YzSlFTl03Rj4czMViZg50qLVetnigIVCgT2xj0xqgQ8LAGmZ3Su(EKdev(YzSlFj4hFm1HpyOVKnu(kbsr57W898P(YW4xkMVp0xnYye67d9L(6j4YOfDFVVKnu(gaX0qOV2vw(E(uFzy8lfJqNMmAZxmHbNQbAmAZJwgCQgODoKHI3Tet4KsAuWoW4qnOQBWPAGgxYiZGt1anXzHeifvxbctB(kuENpLB8FT65uI84JPo8bdfquoNI1mF8Jejdovd0eNfsGuuDfimT5RMpFkxYI)RvpNsawxVoCxspbxMaIY5uSM5JFKif)xREoLqLWgDdMfJ6HYPnFjGOCofRJ05aJgQAMp(rijsz0gIyhluEqwZ84JReifLqLWgDdMfJ6HYPnFjapiKlz3AWPAGMGpXvY6X)1QNtrIKbNQbAc(eX)1QNtjGOCofJejIjCsjnkm4unqRFaNhowyENjKqsKKEgJRbNQbAIZcjqkQUceM28vZ8OMGlRdr5CkMttgT5lMWGt1angT5rldovd04lKHI3Tet4KsAuWoW4qnOQBWPAGgxYiZGt1anbFcjqkQUceM28vO8oFk34)A1ZPe5XhtD4dgkGOCofRz(4hjsgCQgOj4tibsr1vGW0MVA(8PCjl(Vw9CkbyD96WDj9eCzcikNtXAMp(rIu8FT65ucvcB0nywmQhkN28LaIY5uSosNdmAOQz(4hHKiLrBiIDSq5bznZJpUsGuucvcB0nywmQhkN28La8GqUKDRbNQbAIZIRK1J)RvpNIejdovd0eNfX)1QNtjGOCofJejIjCsjnkm4unqRFaNhowyE8riHKij9mgxdovd0e8jKaPO6kqyAZxnZJAcUSoeLZPyon313BcLVFPd77xOVF5lid91Gt1anFpGpXrHmFtFLaPOcXxqg6RDH((2fc99lFJ)RvpNs47je67q5BHJDHqFn4unqZ3d4tCuiZ30xjqkQq8fKH(k92LVF5B8FT65ucNMmAZxmHbNQbAmAZJwGmSpgkhct)gpdovd0ohYqX7wIjCsjnkyhyCOgu1n4unqJ7TgCQgOjolUswhKHDjqkkUKzWPAGMGpr8FT65ucikNtXir6wdovd0e8jUswhKHDjqkkcDAYOnFXegCQgOXOnpAbYW(yOCim9B8m4unqJVqgkE3smHtkPrb7aJd1GQUbNQbACV1Gt1anbFIRK1bzyxcKIIlzgCQgOjolI)RvpNsar5Ckgjs3AWPAGM4S4kzDqg2LaPOieWamaaa]] )

end
