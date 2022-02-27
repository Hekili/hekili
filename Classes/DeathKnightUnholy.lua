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


    spec:RegisterPack( "Unholy", 20220227.1, [[deLIedqivk9ivQ0LuPIAtOsFcr1Oquofc1QqQqVcPuZsqCluvvTlc)cPKHHQkhtf1Yqv5zcsMMkfDnvK2Mkv4BiKY4uriNtfb16eK6DQuOK5jf5EOk7tkQdIublePQEOkIMisfDrvkKnIqQ0hvrqgjcPIoPkfyLifVeHuHzIqYnvPqP2jcXpvrGHQsfzPQuqpvknvvQ6QQuOARQuO4RiKQglsv2lG)kvdwPdlAXe5XcnzsUm0MrYNfy0QKtRy1OQQ8APWSj1TjQDl53QA4QWXrvvwoONJY0PCDG2oc(oQy8iv68cQ1RIqnFez)unWzG7bAvPHaeHp(XhF8Jp(iAIZ8fQBYxOaATWhiq7rgBKbiqBLYiq7nED96WaThzy9NkG7bAzpimIaTxMDWcnTOvWyxGsI4ltl2idQtB(kctkJwSroslGwjWrB3GcqcOvLgcqe(4hF8Xp(4JOjoZxOUjF8b0YoWiar47u(aAVgLclajGwfYIaT0jM2LVeDutWL57nED96WoneDrjiycd7lFeTq8Lp(XhFononN8kRaKfANg(VV0bf)dKzYyzmFT3x6SOtArNi1OrArNyAxmFPtq0x799lDyFJpyz(AjmanMVCUEFti6ls3dmAOYx79vpeqF1Ff4lwpyWLV27RCAgc9LS8XodnWdFV7zIfon8FFPZHLsAu5BBgHd1eNu77DkJMVsymbzOVkmv(gC9GAMVYzd0xQh6llv(sNeDWeon8FFVXztf4lr)dwkFBpWsHqFtPrp2GmFLFi6lLgP7iPd7lzP57nPTVmlJny(ofZWu57t57P0M4BS8LoVtT(wiObtTVzP8vod77bejGL5l7LrFRN)dXOVSXatB(IjCA4)(EJZMkWxIUiZq4ub(2AWPb67u(shob3iFhkFd)G(ELeqFR3UMkWxuZqFT3x17BwkF58f5MVpbegZdF58GLI57W8LoVtT(wiObtTWPH)77jVYkav(kNvyFjNAcUSoeLZPyK7B8l1yZxPM5R9(Mhh6W(oLVspJ5l1eCzmF)sh2xY0iJ57jPtF5Kmd99lFnyYUiw40W)9LoOuOY3SE7cH(EcanjiMn8fldg2x79LHMVGh(Ym4xbi03B0XOq5jYeon8FFVHOoPRVT37lbMWx6Wj4g5R(dMOVSPIOVJ5le1dY89lFJFrLsG60qLVWCuDKawgt40W)99(taDEccTV(s0nJ2d9T1Gyfyx(Ea)iZ3PS3xdovd08v)btua0QhMXaUhOnFSZqd8a4EaICg4EGwSsjnQaOpqBeogcNeOvHPD1ButWLjO48GLcvDlHbOX8TzE(gdh1yhluEqMVKi5Rct7Q3OMGltqX5blfQ6wcdqJ5BZ889uFjrY3B91snwMqceYSPc6ShImbwPKgv(sIKVWCuDKawMivkMaP7WmMVC9fMJQJeWYePsXequoNI5Bt8898zFjrYxPNX8LRVutWL1HOCofZ3M4575ZaTz0MVaAZkCxvkadGi8bCpqlwPKgva0hOnchdHtc0ERVes4KsAuC8VEQGoeSMy)45GqF56lz(kbsrjujSr3GzXOEOCAZxcWdF56leSqQhgGcfMk9GmRh)rlWkL0OYxU(MrBiGDSq5bz(2epFdLVKi5BgTHa2XcLhK5lpF5ZxIbAZOnFb0QW0U6XF0agarcfW9aTyLsAubqFG2iCmeojq7T(siHtkPrXX)6Pc6qWAI9JNdcbAZOnFb0IhJcLNiGbqKBcCpqlwPKgva0hOnJ28fqlfYmeovqNzWPbc0gHJHWjbAvOeifLGczgcNkOZ5blLGzzSHVnXZ3q5lxFJ)RvpNsKhFm1HpyOaIY5umFBY3qb0gdh1y3syaAmaICgWaiYPa3d0IvkPrfa9bAZOnFb0sHmdHtf0zgCAGaTr4yiCsGwfkbsrjOqMHWPc6CEWsjywgB4Bt(EgOngoQXULWa0yae5mGbqK7a4EGwSsjnQaOpqBgT5lGwkKziCQGoZGtdeOnchdHtc0cbluyJm2TVFtFBYxY8n(Vw9CkHct7QNLQRWygwar5CkMVC99wFTuJLjui1OrbwPKgv(sIKVX)1QNtjui1OrbeLZPy(Y1xl1yzcfsnAuGvkPrLVKi5B8jGvwMOMGlRtLOVC9n(Vw9CkHct7I1vGOaIY5umFjgOngoQXULWa0yae5mGbqeIgW9aTyLsAubqFG2mAZxaTCEWs1zhyPqiqRczr4CyZxaTe9xy5RLWa08LXjpy(Mq0x1WsjnQcXx7Ay(Yz0AF1O5B4h0x2bwkFHGfYOfNhSumFNIzyQ89P8Lto2ub(s9qFPZIoPfDIuJgPfDIPDroZx6eefaTr4yiCsGwY89wFzOztfWeXWrn6ljs(QW0U6nQj4YeuCEWsHQULWa0y(2mpFJHJASJfkpiZxI9LRVkucKIsqHmdHtf058GLsWSm2W3M9nu(Y1xiyHcBKXU99q5Bt(g)xREoLiRWDvPequoNIbyagqB(yxceYmG7biYzG7bAXkL0OcG(aTr4yiCsG2mAdbSJfkpiZ3M457PaTz0MVaAJ6KZubD2vQEomadGi8bCpqlwPKgva0hOnchdHtc0MrBiGDSq5bz(YZ37WxU(QW0U6nQj4YeuCEWsHQULWa0y(2mpFdfqBgT5lG2Oo5mvqNDLQNddWaisOaUhOfRusJka6d0gHJHWjbATuJLjKaHmBQGo7HitGvkPrLVC9LmFvyAx9g1eCzckopyPqv3syaAmF55BgTHa2XcLhK5ljs(QW0U6nQj4YeuCEWsHQULWa0y(2mpFdLVe7ljs(APgltibcz2ubD2drMaRusJkF56RLASmruNCMkOZUs1ZHjWkL0OYxU(QW0U6nQj4YeuCEWsHQULWa0y(2mpFpd0MrB(cOLZdwQo7alfcbmaICtG7bAXkL0OcG(aTr4yiCsGwY8vcKIsWavkS6Q)LfqmJMVKi57T(siHtkPrXX)6Pc6qWAI9JNdc9LyF56lz(kbsrjujSr3GzXOEOCAZxcWdF56leSqQhgGcfMk9GmRh)rlWkL0OYxU(MrBiGDSq5bz(2epFdLVKi5BgTHa2XcLhK5lpF5ZxIbAZOnFb0QW0U6XF0agarof4EGwSsjnQaOpqBeogcNeOfcwtSF8CqOqHutCmFBYxY89m)8L2(QW0U6nQj4YeuCEWsHQULWa0y(sh9nu(sSVC9vHPD1ButWLjO48GLcvDlHbOX8TjFVdF567T(siHtkPrXX)6Pc6qWAI9JNdc9LejFLaPOemojuEQGU8Wmb4bqBgT5lGw8yuO8ebmaICha3d0IvkPrfa9bAJWXq4KaTqWAI9JNdcfkKAIJ5Bt(Y3P(Y1xfM2vVrnbxMGIZdwku1TegGgZ3M99uF567T(siHtkPrXX)6Pc6qWAI9JNdcbAZOnFb0IhJcLNiGbqeIgW9aTyLsAubqFG2iCmeojq7T(QW0U6nQj4YeuCEWsHQULWa0y(Y13B9LqcNusJIJ)1tf0HG1e7hphe6ljs(snbxwhIY5umFBY3t9LejFH5O6ibSmrQumbs3HzmF56lmhvhjGLjsLIjGOCofZ3M89uG2mAZxaT4XOq5jcyae5ebCpqBgT5lGwopyP6SdSuieOfRusJka6dyae5eg4EGwSsjnQaOpqBeogcNeO9wFjKWjL0O44F9ubDiynX(XZbHaTz0MVaAXJrHYteWamG2aSq4e75Ja3dqKZa3d0IvkPrfa9bAzyeOn(Vw9Ckb7b1DiMhiuar5CkgqBgT5lGwo5yaTr4yiCsGwl1yzc2dQ7qmpqOaRusJkF56RLWa0e2iJD77hrRhQt9TjFp1xU(snbxwhIY5umFB23t9LRVX)1QNtjypOUdX8aHcikNtX8TjFjZ3GOYx6OV8tq0o1xI9LRVz0gcyhluEqMVnXZ3qbyaeHpG7bAXkL0OcG(aTr4yiCsGwY89wFjKWjL0O44F9ubDiynX(XZbH(sIKVsGuucgOsHvx9VSaIz08LyF56lz(kbsrjujSr3GzXOEOCAZxcWdF56leSqQhgGcfMk9GmRh)rlWkL0OYxU(MrBiGDSq5bz(2epFdLVKi5BgTHa2XcLhK5lpF5ZxIbAZOnFb0QW0U6XF0agarcfW9aTyLsAubqFG2iCmeojqReifLGbQuy1v)llGygnFjrY3B9LqcNusJIJ)1tf0HG1e7hphec0MrB(cOfpgfkpradGi3e4EGwSsjnQaOpqRczr4CyZxaT3akFTegGMVXWr9ub(omFvdlL0OkeFzCglE5RugB4R9(AxOVSPc0i)3syaA(gGfcNOV6Hz(ofZWujaAZOnFb0cbREgT5RUEygqlZGt0aiYzG2iCmeojqBmCuJDSq5bz(YZ3ZaT6Hz9kLrG2aSq4ebmaICkW9aTyLsAubqFG2mAZxaTCEWs1zhyPqiqBeogcNeOLmFJ)RvpNsKhFm1HpyOaIY5umFB23t9LRVkucKIsqHmdHtf058GLsaE4ljs(QqjqkkbfYmeovqNZdwkbZYydFB23q5lX(Y1xY8LAcUSoeLZPy(2KVX)1QNtjuyAx9SuDfgZWcikNtX8L2(EMF(sIKVutWL1HOCofZ3M9n(Vw9CkrE8Xuh(GHcikNtX8LyG2y4Og7wcdqJbqKZagarUdG7bAXkL0OcG(aTz0MVaAPqMHWPc6mdonqG2iCmeojqRcLaPOeuiZq4ubDopyPemlJn8TjE(gkF56B8FT65uI84JPo8bdfquoNI5Bt(EQVKi5RcLaPOeuiZq4ubDopyPemlJn8TjFpd0gdh1y3syaAmaICgWaicrd4EGwSsjnQaOpqBgT5lGwkKziCQGoZGtdeOnchdHtc0g)xREoLip(yQdFWqbeLZPy(2SVN6lxFvOeifLGczgcNkOZ5blLGzzSHVn57zG2y4Og7wcdqJbqKZagarora3d0IvkPrfa9bAZOnFb0sHmdHtf0zgCAGaTkKfHZHnFb0E)1W8Dy(Iuuy0gcOoSVuJwJqF5CnXlFzJmZx68o16BHGgm1H4ReO5l76b1kFpGibSmFtFzrSs48(Y5cHOV2f6BQuF57vY8TE7AQaFT3xigFzzSucG2iCmeojqBgTHa2vVjOqMHWPc6CEWs5BZ88ngoQXowO8GmF56RcLaPOeuiZq4ubDopyPemlJn8TjFVjGbyaTbyHWjcCparodCpqlwPKgva0hOnchdHtc0ERVes4KsAuC8VEQGoeSMy)45GqF56lz(kbsrjyGkfwD1)YciMrZxsK8fcwtSF8CqOqHutCmFBINVNdLV02xY8fcwi1ddqbmLpYY6gmlgfcXkIcSsjnQ8Lo6BO8L2(QW0U6nQj4YeqWcPEyakUcZmeoPV0rFdLVe7lX(sIKVhOjcsyWhwJImAdb0xU(cbl03M45BO8LejFPMGlRdr5CkMVn57z(5lxFV1xfkbsrjOqMHWPc6CEWsjapaAZOnFb0QW0U6XF0agar4d4EGwSsjnQaOpqBeogcNeOLmFTuJLjui1OrbwPKgv(sIKVXNawzzIAcUSovI(sIKVqWcPEyakoUWe(YFHmbwPKgv(sSVC9LmFjZ3B9LqcNusJIJ)1tf0HGfY8LejFJpbSYYe1eCzDQe9LRVwQXYekKA0OaRusJkF56B8lf4ycoJDHWPc6bWhSucSsjnQ8LyFjrYxPNX8LRVutWL1HOCofZ3M89uFjgOnJ28fqBwH7Qsbyaejua3d0IvkPrfa9bAJWXq4KaTes4KsAuOaLp6CEWsX8LRVkucKIsqHmdHtf058GLsWSm2W3M557zF56B8FT65uI84JPo8bdfquoNI1r6EGrdv(2SVNp1x(VVK5leSqQhgGcfMk9GmRh)rlWkL0OYx6OVN5NVe7lxFV1xcjCsjnko(xpvqhcwidOnJ28fqlNhSuD2bwkecyae5Ma3d0IvkPrfa9bAJWXq4KaTkucKIsqHmdHtf058GLsWSm2W3M9nu(Y13B9LqcNusJIJ)1tf0HGfY8LejFvOeifLGczgcNkOZ5blLa8WxU(snbxwhIY5umFBYxY8vHsGuuckKziCQGoNhSucMLXg(sh9niQ8LyG2mAZxaTCEWs1zhyPqiGbqKtbUhOfRusJka6d0gHJHWjbAHG1e7hphekui1ehZ3M45lF8ZxA7lz(cblK6HbOaMYhzzDdMfJcHyfrbwPKgv(sh99M(sBFvyAx9g1eCzciyHupmafxHzgcN0x6OV30xI9LRV36lHeoPKgfh)RNkOdbRj2pEoieOnJ28fqRct7Qh)rdyae5oaUhOfRusJka6d0gHJHWjbAvOeifLGczgcNkOZ5blLGzzSHVn57n9LRV36lHeoPKgfh)RNkOdblKb0MrB(cOLczgcNkOZm40abmaIq0aUhOfRusJka6d0gHJHWjbAV1xcjCsjnko(xpvqhcwtSF8CqiqBgT5lGwfM2vp(JgWaiYjc4EGwSsjnQaOpqBeogcNeOvHsGuuckKziCQGoNhSucMLXg(2mpFp7lxFHGf6Bt(YNVC99wFjKWjL0O44F9ubDiyHmF56B8FT65uI84JPo8bdfquoNI1r6EGrdv(2SVNc0MrB(cOLZdwQo7alfcbmadOn(eWklJbCparodCpqlwPKgva0hOnchdHtc0siHtkPrbZ6h6SQPc8LRVqWAI9JNdcfkKAIJ5BZ(E(o8LRVK5B8FT65uI84JPo8bdfquoNI5ljs(ERVwQXYejuoC)P62f2vPCHkbwPKgv(Y134)A1ZPeQe2OBWSyupuoT5lbeLZPy(sSVKi5R0Zy(Y1xQj4Y6quoNI5Bt(E(mqBgT5lGwgNekpvqxEygGbqe(aUhOfRusJka6d0MrB(cOLXjHYtf0LhMb0Qqweoh28fqBlA(AVVGm03KYqOV5Xh9Dy((LVNKo9nz(AVVhqKawMVpbegZJJPc89gEN8LZ1OrFzOztf4l4HVNKojNb0gHJHWjbAJ)RvpNsKhFm1HpyOaIY5umF56lz(MrBiGDSq5bz(2mpF5ZxU(MrBiGDSq5bz(2epFp1xU(cbRj2pEoiuOqQjoMVn77z(5lT9LmFZOneWowO8GmFPJ(Eh(sSVC9LqcNusJIuPyDikNt5ljs(MrBiGDSq5bz(2SVN6lxFHG1e7hphekui1ehZ3M99M8ZxIbmaIekG7bAXkL0OcG(aTr4yiCsGwcjCsjnkyw)qNvnvGVC99wFzpOwAkLqJPQlfUJ0nLp0OaRusJkF56lz(g)xREoLip(yQdFWqbeLZPy(sIKV36RLASmrcLd3FQUDHDvkxOsGvkPrLVC9n(Vw9CkHkHn6gmlg1dLtB(sar5CkMVe7lxFHGfkSrg723VPVn7ReifLacwtShFie8WMVequoNI5ljs(k9mMVC9LAcUSoeLZPy(2KV8DgOnJ28fqBk9YtL28vxpYsagarUjW9aTyLsAubqFG2iCmeojqlHeoPKgfmRFOZQMkWxU(YEqT0ukHgtvxkChPBkFOrbwPKgv(Y1xY8v9MaSUED4UKEcUSU6nbeLZPy(2SVNp7ljs(ERVwQXYeG11Rd3L0tWLjWkL0OYxU(g)xREoLqLWgDdMfJ6HYPnFjGOCofZxIbAZOnFb0MsV8uPnF11JSeGbqKtbUhOfRusJka6d0gHJHWjbAjKWjL0OGz9dDw1ub(Y1x2dQLMsjAGeMI1))eJ6PceyLsAu5lxFjZxfkbsrjOqMHWPc6CEWsjywgB4BZ889M(Y13B9fcwi1ddqrk9YtL28fRtbX6ehwGvkPrLVKi5leSqQhgGIu6LNkT5lwNcI1joSaRusJkF56B8FT65uI84JPo8bdfquoNI5lXaTz0MVaAtPxEQ0MV66rwcWaiYDaCpqlwPKgva0hOnchdHtc0siHtkPrrQuSoeLZP8LRVqWcf2iJD77303M9vcKIsabRj2JpecEyZxcikNtXaAZOnFb0MsV8uPnF11JSeGbqeIgW9aTyLsAubqFG2iCmeojqlHeoPKgfmRFOZQMkWxU(sMVX)1QNtjYJpM6Whmuar5CkMVn77z(5ljs(ERVwQXYejuoC)P62f2vPCHkbwPKgv(Y134)A1ZPeQe2OBWSyupuoT5lbeLZPy(sSVKi5R0Zy(Y1xQj4Y6quoNI5Bt(E(uG2mAZxaTSRm2qJD7c7GfNhAxHbmaICIaUhOfRusJka6d0gHJHWjbAjKWjL0OivkwhIY5u(Y1xY8vHPD1Zs1vymdlSj2yQaFjrYxyoQosaltKkftar5CkMVnXZ3Z30xIbAZOnFb0YUYydn2TlSdwCEODfgWaiYjmW9aTyLsAubqFG2iCmeojql7b1stPehGmduJDecEyZxcSsjnQ8LejFzpOwAkLGWRtB0yN9AcyzcSsjnQ8LRV36ReifLGWRtB0yN9Acyz9lq5S(rjapaANYqie8W6dfql7b1stPeeEDAJg7SxtaldODkdHqWdRpYYOAsdbApd0MrB(cOLsJSRimPmG2PmecbpSEG(Lsnq7zadWaApGy8LLsd4EaICg4EG2mAZxaThVnFb0IvkPrfa9bmaIWhW9aTz0MVaAH5WWUctfqlwPKgva0hWaisOaUhOnJ28fqlLgzxryszaTyLsAubqFadGi3e4EGwSsjnQaOpqBgT5lG2ekhU)uD7c7kmvaTr4yiCsG2B91snwMGbkl)vpiHbFynkWkL0OcO9aIXxwkTUnYiqBOamaICkW9aTyLsAubqFG2)aOLH2qb0gHJHWjbAn4unqtyNfxjRdYWUeifLVC9LmFn4unqtyNfX)1QNtjuGW0MV89o77np1xE(YpFjgOvHSiCoS5lG2BeHudMgY8n91Gt1anMVX)1QNtfIVQHWOqLVsH99MNk89(RH5lNK5B86zy5BY8fSUEDyF58WgmF)Y3BEQVmm(LYxjqiZ8ngoQrwi(kbA(ELmFT)9voRW(gvqFrkkmAmFT33GHa6B6B8FT65uc6kuGW0MV8vneg2d9DkMHPs47nGY3XiN5lHudI(ELmFR3xikNtPqOVq0aHLVNdXxuZqFHObclF5N4ubqlHe2RugbAn4unqRFUZcxrG2mAZxaTes4KsAeOLqQbXoQziql)eNc0si1Giq7zadGi3bW9aTyLsAubqFG2)aOLH2qb0MrB(cOLqcNusJaTesyVszeO1Gt1aToFDw4kc0gHJHWjbAn4unqty8jUswhKHDjqkkF56lz(AWPAGMW4te)xREoLqbctB(Y37SV38uF55l)8LyGwcPge7OMHaT8tCkqlHudIaTNbmaIq0aUhOfRusJka6d0(haTm0gkG2iCmeojq7T(AWPAGMWolUswhKHDjqkkF56RbNQbAcJpXvY6GmSlbsr5ljs(AWPAGMW4tCLSoid7sGuu(Y1xY8LmFn4unqty8jI)RvpNsOaHPnF5lT81Gt1anHXNqcKIQRaHPnF5lX(sh9LmFplo1xA7RbNQbAcJpXvY6sGuu(sSV0rFjZxcjCsjnkm4unqRZxNfUI(sSVe7BZ(sMVK5RbNQbAc7Si(Vw9CkHceM28LV0Yxdovd0e2zHeifvxbctB(YxI9Lo6lz(EwCQV02xdovd0e2zXvY6sGuu(sSV0rFjZxcjCsjnkm4unqRFUZcxrFj2xIbAvilcNdB(cO9gXSronK5B6RbNQbAmFjKAq0xPW(gF5JeovGV2f6B8FT65u((u(AxOVgCQgOfIVQHWOqLVsH91UqFvGW0MV89P81UqFLaPO8DmFpGpHrHmHVeDMmFtFzgeRa7Yx5xnudc91EFdgcOVPVxtWfc99aopCSW(AVVmdIvGD5RbNQbASq8nz(Yb1AFtMVPVYVAOge6l1d9DO8n91Gt1anF5mATVp0xoJw7B9MVSWv0xoJD5B8FT65umbqlHe2RugbAn4unqRFaNhowyG2mAZxaTes4KsAeOLqQbXoQziq7zGwcPgebA5dWaiYjc4EGwSsjnQaOpq7Fa0YqdOnJ28fqlHeoPKgbAjKAqeO1snwMiHYH7pv3UWUkLlujWkL0OYxU(g)sboMi(fHpM28v)P62f2vyQeyLsAub0Qqweoh28fq7nIqQbtdz(gbHqSmFzObE4l1d91UqF5pWSSXc77t5lD44JPo8bd99K05n0xKIcJgdOLqc7vkJaTuGADpQGagaroHbUhOfRusJka6d0(haTm0aAZOnFb0siHtkPrGwcPgebAHGfs9WauOW0Uy9icTCklSaRusJkF56leSqQhgGcykFKL1nywmkeIvefyLsAub0siH9kLrGwvSdnadWaAJ)RvpNIbCparodCpqlwPKgva0hOnchdHtc0siHtkPrHCY)Eyp(Vw9CkwpJ2qa9LejFpqteKWGpSgfz0gcOVC99anrqcd(WAuar5CkMVnXZx(UdFjrYxPNX8LRVutWL1HOCofZ3M8LV7aOnJ28fq7XBZxagar4d4EGwSsjnQaOpqBeogcNeOn(Vw9CkHkHn6gmlg1dLtB(sar5CkwhP7bgnu5Bt(s08LRVK5B8FT65ucW661H7s6j4YequoNI5Bt(s08LRVwQXYeG11Rd3L0tWLjWkL0OYxsK89wFTuJLjaRRxhUlPNGltGvkPrLVe7lxFjZxgADPVazcBqiFNO(npI(Y1xlHbOjSrg723pIwpuN6Bt(EtFjrY3B9LHwx6lqMWgeY3jQFZJOVKi5l1eCzDikNtX8TzF5JF8ZxI9LRVK5B8FT65uIu6LNkT5RUEKLequoNI5Bt(E(e5lxFjZxiyHupmafP0lpvAZxSofeRtCybwPKgv(sIKVShulnLs0ajmfR))jg1tfiWkL0OYxI9LejFV1xiyHupmafP0lpvAZxSofeRtCybwPKgv(Y13B9L9GAPPuIgiHPy9)pXOEQabwPKgv(sSVC9LmFJ)RvpNsKhFm1HpyOaIY5uSos3dmAOY3M8LO5lxFjKWjL0OGcuR7rf0xsK89wFjKWjL0OGcuR7rf0xsK8LqcNusJcvSdnFj2xsK8v6zmF56l1eCzDikNtX8TjFd1PaTz0MVaAtOC4(t1TlSRWubyaejua3d0IvkPrfa9bAZOnFb0YEqDhI5bcbAJWXq4KaTwcdqtyJm2TVFeTEOo13M89uF56lz(AjmanHnYy3(UAqFB23t9LRVz0gcyhluEqMVnXZ3q5ljs(YqRl9fitydc57e1V5r0xU(kbsrjujSr3GzXOEOCAZxcWdF56BgTHa2XcLhK5Bt889uF56lz(ERVkmTREwQUcJzyHnXgtf4ljs(gFcyLLjQj4Y6uj6lX(smqBmCuJDlHbOXaiYzadGi3e4EGwSsjnQaOpqBgT5lGwW661H7s6j4YaAvilcNdB(cOLOZxRy(sF9eCz(s9qFbp81EFp1xgg)sX81EFzHROVCg7Yx6WXhtD4dggIVNa7cHCgggIVGm0xoJD5lDMWg(Epmlg1dLtB(sa0gHJHWjbAjKWjL0OGz9dDw1ub(Y1xY8n(Vw9CkrE8Xuh(GHcikNtX6iDpWOHkFBY3t9LejFJ)RvpNsKhFm1HpyOaIY5uSos3dmAOY3M99m)8LyF56lz(g)xREoLqLWgDdMfJ6HYPnFjGOCofZ3M8niQ8LejFLaPOeQe2OBWSyupuoT5lb4HVedyae5uG7bAXkL0OcG(aTr4yiCsGwcjCsjnksLI1HOCoLVKi5R0Zy(Y1xQj4Y6quoNI5Bt(Y3zG2mAZxaTG11Rd3L0tWLbyae5oaUhOfRusJka6d0gHJHWjbAjKWjL0OGz9dDw1ub(Y1xY8v9MaSUED4UKEcUSU6nbeLZPy(sIKV36RLASmbyD96WDj9eCzcSsjnQ8LyG2mAZxaTQe2OBWSyupuoT5ladGienG7bAXkL0OcG(aTr4yiCsGwcjCsjnksLI1HOCoLVKi5R0Zy(Y1xQj4Y6quoNI5Bt(Y3zG2mAZxaTQe2OBWSyupuoT5ladGiNiG7bAXkL0OcG(aTr4yiCsG2mAdbSJfkpiZxE(E2xU(QqjqkkbfYmeovqNZdwkbZYydFBMNV30xU(sMV36lHeoPKgfuGADpQG(sIKVes4KsAuqbQ19Oc6lxFjZ34)A1ZPeG11Rd3L0tWLjGOCofZ3M99m)8LejFJ)RvpNsOsyJUbZIr9q50MVequoNI1r6EGrdv(2SVN5NVC99wFTuJLjaRRxhUlPNGltGvkPrLVe7lXaTz0MVaAZJpM6WhmeWaiYjmW9aTyLsAubqFG2mAZxaT5XhtD4dgc0gHJHWjbAZOneWowO8GmFBMNV85lxFvOeifLGczgcNkOZ5blLGzzSHVnZZ3B6lxFV1xfM2vplvxHXmSWMyJPcaAJHJASBjmangarodyae5m)aUhOfRusJka6d0gHJHWjbAHG1e7hphekui1ehZ3M898n9LRVX)1QNtjaRRxhUlPNGltar5CkMVn575q5lxFJ)RvpNsOsyJUbZIr9q50MVequoNI1r6EGrdv(2KVNdfqBgT5lGwgOS8x9Geg8H1iGbqKZNbUhOfRusJka6d0gHJHWjbAjKWjL0OGz9dDw1ub(Y1xfkbsrjOqMHWPc6CEWsjywgB4Bt(YNVC9LmFpqtKhFShC9GArgTHa6ljs(kbsrjujSr3GzXOEOCAZxcWdF56B8FT65uI84JPo8bdfquoNI5BZ(EMF(sIKVX)1QNtjYJpM6Whmuar5CkMVn77z(5lxFJ)RvpNsOsyJUbZIr9q50MVequoNI5BZ(EMF(smqBgT5lGwW661H7jJLGAdWaiYz(aUhOfRusJka6d0MrB(cOfSUED4EYyjO2aAJWXq4KaTz0gcyhluEqMVnZZx(8LRVkucKIsqHmdHtf058GLsWSm2W3M8LpF56lz(EGMip(yp46b1ImAdb0xsK8vcKIsOsyJUbZIr9q50MVeGh(sIKVX)1QNtjuyAx9SuDfgZWcikNtX8TjFdIkFjgOngoQXULWa0yae5mGbqKZHc4EGwSsjnQaOpqBeogcNeO9wFpqteC9GArgTHac0MrB(cOfMdd7kmvagGb0AWPAGgd4EaICg4EGwSsjnQaOpqBgT5lG2PyriOLsASZFGzzGYDfsyIiqBeogcNeOLmFJ)RvpNsawxVoCxspbxMaIY5umFB2x(4NVKi5B8FT65ucvcB0nywmQhkN28LaIY5uSos3dmAOY3M9Lp(5lX(Y1xY8nJ2qa7yHYdY8TzE(YNVKi57bAIekhUhC9GArgTHa6ljs(EGMip(yp46b1ImAdb0xU(sMVwQXYeG11Rd3tglb1MaRusJkFjrYxfM2vVrnbxMqnSusJ98nLVe7ljs(EGMiiHbFynkYOneqFj2xsK8v6zmF56l1eCzDikNtX8TjF57SVKi5Rct7Q3OMGltOgwkPX(WFQosxmcAOV88LF(Y1xlHbOjSrg723pIwNp(5Bt(EkqBLYiq7uSie0sjn25pWSmq5UcjmreWaicFa3d0IvkPrfa9bAZOnFb0AxyNAGmRZMGrd0gHJHWjbAjKWjL0Oqo5FpSh)xREofRNrBiG(Y1xY81gz03M9nu8ZxsK89wFr(dCooqLykwecAPKg78hywgOCxHeMi6lXaTvkJaT2f2PgiZ6Sjy0agarcfW9aTyLsAubqFG2mAZxaTpbeY5c1Ytf0pEoiShHHzwQbAJWXq4KaTes4KsAuiN8Vh2J)RvpNI1ZOneqF56lz(AJm6BZ(gk(5ljs(ERVi)bohhOsmflcbTusJD(dmlduURqcte9LRV36lYFGZXbQe2f2PgiZ6Sjy0(smqBLYiq7taHCUqT8ub9JNdc7ryyMLAadGi3e4EGwSsjnQaOpqBgT5lGwdovd0od0Qqweoh28fq79xOVgCQgO5lNXU81UqFVMGlKz(ImBKtdv(si1Gyi(Yz0AFLqFbzOYxQbYmFZs57roqu5lNXU8LoC8Xuh(GH(s2q5ReifLVdZ3ZN6ldJFPy((qF1iJrSVp0x6RNGlJw059(s2q5BaetdH(Axz575t9LHXVumIbAJWXq4KaT36lHeoPKgfSdmoudQ6gCQgO5lxFjZxY81Gt1anHDwibsr1vGW0MV8TjE(E(uF56B8FT65uI84JPo8bdfquoNI5BZ(Yh)8LejFn4unqtyNfsGuuDfimT5lFB23ZN6lxFjZ34)A1ZPeG11Rd3L0tWLjGOCofZ3M9Lp(5ljs(g)xREoLqLWgDdMfJ6HYPnFjGOCofRJ09aJgQ8TzF5JF(sSVKi5BgTHa2XcLhK5BZ88LpF56ReifLqLWgDdMfJ6HYPnFjap8LyF56lz(ERVgCQgOjm(exjRh)xREoLVKi5RbNQbAcJpr8FT65ucikNtX8LejFjKWjL0OWGt1aT(bCE4yH9LNVN9LyFj2xsK8v6zmF56RbNQbAc7SqcKIQRaHPnF5BZ88LAcUSoeLZPyagarof4EGwSsjnQaOpqBeogcNeO9wFjKWjL0OGDGXHAqv3Gt1anF56lz(sMVgCQgOjm(esGuuDfimT5lFBINVNp1xU(g)xREoLip(yQdFWqbeLZPy(2SV8XpFjrYxdovd0egFcjqkQUceM28LVn775t9LRVK5B8FT65ucW661H7s6j4YequoNI5BZ(Yh)8LejFJ)RvpNsOsyJUbZIr9q50MVequoNI1r6EGrdv(2SV8XpFj2xsK8nJ2qa7yHYdY8TzE(YNVC9vcKIsOsyJUbZIr9q50MVeGh(sSVC9LmFV1xdovd0e2zXvY6X)1QNt5ljs(AWPAGMWolI)RvpNsar5CkMVKi5lHeoPKgfgCQgO1pGZdhlSV88LpFj2xI9LejFLEgZxU(AWPAGMW4tibsr1vGW0MV8TzE(snbxwhIY5umG2mAZxaTgCQgOXhGbqK7a4EGwSsjnQaOpqBgT5lGwdovd0od0Y0Vb0AWPAG2zG2iCmeojq7T(siHtkPrb7aJd1GQUbNQbA(Y13B91Gt1anHDwCLSoid7sGuu(Y1xY81Gt1anHXNi(Vw9CkbeLZPy(sIKV36RbNQbAcJpXvY6GmSlbsr5lXaTkKfHZHnFb0EdO89lDyF)c99lFbzOVgCQgO57b8jmkK5B6Reifvi(cYqFTl033UqOVF5B8FT65ucFpbqFhkFlCSle6RbNQbA(EaFcJcz(M(kbsrfIVGm0xP3U89lFJ)RvpNsayaeHObCpqlwPKgva0hOnJ28fqRbNQbA8b0gHJHWjbAV1xcjCsjnkyhyCOgu1n4unqZxU(ERVgCQgOjm(exjRdYWUeifLVC9LmFn4unqtyNfX)1QNtjGOCofZxsK89wFn4unqtyNfxjRdYWUeifLVed0Y0Vb0AWPAGgFagGb0QqQeuBa3dqKZa3d0MrB(cOvEkvNcI4jgbAXkL0OcG(agar4d4EGwSsjnQaOpq7Fa0YqdOnJ28fqlHeoPKgbAjKAqeOLmFr(dCooqLykwecAPKg78hywgOCxHeMi6ljs(I8h4CCGkHDHDQbYSoBcgTVKi5lYFGZXbQepbeY5c1Ytf0pEoiShHHzwQ9LyF56lz(g)xREoLykwecAPKg78hywgOCxHeMikGyQc7ljs(g)xREoLWUWo1azwNnbJwar5CkMVKi5B8FT65uINac5CHA5Pc6hphe2JWWml1cikNtX8LyFjrYxY8f5pW54avc7c7udKzD2emAFjrYxK)aNJdujEciKZfQLNkOF8CqypcdZSu7lX(Y1xK)aNJdujMIfHGwkPXo)bMLbk3viHjIaTkKfHZHnFb0ENGibSmFzhyCOgu5RbNQbAmFLWPc8fKHkF5m2LVjO9YPnrF1tHmGwcjSxPmc0YoW4qnOQBWPAGgGbqKqbCpqlwPKgva0hO9paAzOb0MrB(cOLqcNusJaTesnic0g)xREoLGbkl)vpiHbFynkGOCofZ3M89uF56RLASmbduw(REqcd(WAuGvkPrLVC9LmFTuJLjaRRxhUlPNGltGvkPrLVC9n(Vw9CkbyD96WDj9eCzcikNtX8TjFphkF56B8FT65ucvcB0nywmQhkN28LaIY5uSos3dmAOY3M89CO8LejFV1xl1yzcW661H7s6j4YeyLsAu5lXaTesyVszeO94F9ubDiynX(XZbHagarUjW9aTyLsAubqFG2)aOLHgqBgT5lGwcjCsjnc0si1GiqRLASmb7b1DiMhiuGvkPrLVC9fcwOVn5lF(Y1xlHbOjSrg723pIwpuN6Bt(EQVC9LAcUSoeLZPy(2SVN6ljs(gFcyLLjQj4Y6uj6lxFTuJLjui1OrbwPKgv(Y134)A1ZPekKA0OaIY5umFBYxiyHcBKXU9D(aAjKWELYiq7X)6Pc6qWczagarof4EGwSsjnQaOpq7Fa0YqdOnJ28fqlHeoPKgbAjKAqeOnJ2qa7yHYdY8LNVN9LRVK57T(cZr1rcyzIuPycKUdZy(sIKVWCuDKawMivkMykFB23ZN6lXaTesyVszeOLz9dDw1ubagarUdG7bAXkL0OcG(aT)bqldnG2mAZxaTes4KsAeOLqQbrG2mAdbSJfkpiZ3M55lF(Y1xY89wFH5O6ibSmrQumbs3HzmFjrYxyoQosaltKkftG0DygZxU(sMVWCuDKawMivkMaIY5umFB23t9LejFPMGlRdr5CkMVn77z(5lX(smqlHe2RugbAtLI1HOCofGbqeIgW9aTyLsAubqFG2)aOLHgqBgT5lGwcjCsjnc0si1Giqlz(APgltWaLL)QhKWGpSgfyLsAu5lxFV13d0ebjm4dRrrgTHa6lxFJ)RvpNsWaLL)QhKWGpSgfquoNI5ljs(ERVwQXYemqz5V6bjm4dRrbwPKgv(sSVC9LmFLaPOeG11Rd3tglb1Ma8WxsK81snwMiHYH7pv3UWUkLlujWkL0OYxU(EGMip(yp46b1ImAdb0xsK8vcKIsOsyJUbZIr9q50MVeGh(Y1xjqkkHkHn6gmlg1dLtB(sar5CkMVn77P(sIKVz0gcyhluEqMVnZZx(8LRVkmTREwQUcJzyHnXgtf4lXaTesyVszeOvo5FpSh)xREofRNrBiGagarora3d0IvkPrfa9bA)dGwgAaTz0MVaAjKWjL0iqlHudIaTXNawzzIAcUSovI(Y1xfM2vplvxHXmSWMyJPc8LRVsGuucfM2fRRarbZYydFBY3B6ljs(kbsrjKti85GQEakZSVWowxzfrzSmb4HVKi5ReifLWUGJw3zi2aHcWdFjrYxjqkkbfeRt8GQU8xmd(SXclap8LejFLaPOeAmvDPWDKUP8HgfGh(sIKVsGuuI4v(SUuwOa8WxsK8n(Vw9CkbyD96W9KXsqTjGOCofZ3M89uF56B8FT65uI84JPo8bdfquoNI5BZ(EMFaTesyVszeOvbkF058GLIbyae5eg4EGwSsjnQaOpqBgT5lG2h0KGy2aOvHSiCoS5lG2BSZPSCQPc89gZab1yz(EN0zai67W8n99aopCSWaTr4yiCsGw1BccdeuJL1p0zaikGifezxPKg9LRV36RLASmbyD96WDj9eCzcSsjnQ8LRV36lmhvhjGLjsLIjq6omJbyae5m)aUhOfRusJka6d0MrB(cO9bnjiMnaAJWXq4KaTQ3eegiOglRFOZaquarkiYUsjn6lxFZOneWowO8GmFBMNV85lxFjZ3B91snwMaSUED4UKEcUmbwPKgv(sIKVwQXYeG11Rd3L0tWLjWkL0OYxU(sMVX)1QNtjaRRxhUlPNGltar5CkMVn7lz(E(uFPLVz0gcyhluEqMV02x1BccdeuJL1p0zaikGOCofZxI9LejFZOneWowO8GmFBMNVHYxI9LyG2y4Og7wcdqJbqKZagaroFg4EGwSsjnQaOpqBgT5lG2h0KGy2aOvpf2JkG27aOnchdHtc0MrBiGD1BccdeuJL1p0zai6Bt(MrBiGDSq5bz(Y13mAdbSJfkpiZ3M55lF(Y1xY89wFTuJLjaRRxhUlPNGltGvkPrLVKi5B8FT65ucW661H7s6j4YequoNI5lxFLaPOeG11Rd3L0tWL1LaPOeQNt5lXaTkKfHZHnFb0EdO81Uqi6BcrFXcLhK5R8Wytf47nM7ui(Mhh6W(oMVKjbA(wVVYpe91UYY3VIOVhi037Wxgg)sXiwayae5mFa3d0IvkPrfa9bAJWXq4KaTqWcPEyakyGhiKzWCkbwPKgv(Y1xY8v9MGc(mRtHeqOaIuqKDLsA0xsK8v9Mqs)VQFOZaquarkiYUsjn6lXaTz0MVaAFqtcIzdadGiNdfW9aTyLsAubqFG2mAZxaTCEWs1zhyPqiqRczr4CyZxaT3qKcISlK5lDIPDX8LobrYz(kbsr5l)dKz(kHupe9vHPDX8vbI(ILIb0gHJHWjbAJpbSYYe1eCzDQe9LRVkmTREwQUcJzyHnXgtf4lxFjZxfM2vplvxHXmSiJ2qa7quoNI5Bt(sMVbrLV0rFplo1xI9LejFLaPOekmTlwxbIcikNtX8TjFdIkFjgWaiY5BcCpqlwPKgva0hOLHrG24)A1ZPeShu3HyEGqbeLZPyaTz0MVaA5KJb0gHJHWjbATuJLjypOUdX8aHcSsjnQ8LRVwcdqtyJm2TVFeTEOo13M89uF56RLWa0e2iJD77Qb9TzFp1xU(g)xREoLG9G6oeZdekGOCofZ3M8LmFdIkFPJ(Ypbr7uFj2xU(MrBiGDSq5bz(YZ3ZagaroFkW9aTyLsAubqFGwfYIW5WMVaAj6ZX8L6H(sNyAxKZ8LobrArNi1OrFhkFjYeCz(s0nrFT33a08LzqScSlFLaPO8vkJn8nz5bqldJaTX)1QNtjuyAxSUcefquoNIb0MrB(cOLtogqBeogcNeOn(eWkltutWL1Ps0xU(g)xREoLqHPDX6kquar5CkMVn5Bqu5lxFZOneWowO8GmF557zadGiNVdG7bAXkL0OcG(aTmmc0g)xREoLqHuJgfquoNIb0MrB(cOLtogqBeogcNeOn(eWkltutWL1Ps0xU(g)xREoLqHuJgfquoNI5Bt(gev(Y13mAdbSJfkpiZxE(EgWaiYzIgW9aTyLsAubqFGwfYIW5WMVaAPdrB(YxIAygZ3Su(EcoWcHmFj7eCGfcz0Qf5pqSIiZxWIbEC8qdv(oLVPs9LGyG2mAZxaTXuR7z0MV66HzaT6Hz9kLrGwdovd0yagaroFIaUhOfRusJka6d0MrB(cOnMADpJ28vxpmdOvpmRxPmc0gFcyLLXamaIC(eg4EGwSsjnQaOpqBgT5lG2yQ19mAZxD9WmGw9WSELYiqlmJtQzagar4JFa3d0IvkPrfa9bAZOnFb0gtTUNrB(QRhMb0QhM1RugbAJ)RvpNIbyaeHVZa3d0IvkPrfa9bAJWXq4KaTes4KsAuKkfRdr5CkF56lz(g)xREoLqHPD1Zs1vymdlGOCofZ3M89m)8LRV36RLASmHcPgnkWkL0OYxsK8n(Vw9CkHcPgnkGOCofZ3M89m)8LRVwQXYekKA0OaRusJkFjrY34taRSmrnbxwNkrF56B8FT65ucfM2fRRarbeLZPy(2KVN5NVe7lxFV1xfM2vplvxHXmSWMyJPcaAZOnFb0cbREgT5RUEygqREywVszeOnFSZqd8aWaicF8bCpqlwPKgva0hOnchdHtc0MrBiGDSq5bz(2mpF5ZxU(QW0U6zP6kmMHf2eBmvaqlZGt0aiYzG2mAZxaTqWQNrB(QRhMb0QhM1RugbAZh7sGqMbyaeHVqbCpqlwPKgva0hOnchdHtc0MrBiGDSq5bz(2mpF5ZxU(ERVkmTREwQUcJzyHnXgtf4lxFjZ3B9LqcNusJIuPyDikNt5ljs(g)xREoLqHPD1Zs1vymdlGOCofZ3M99m)8LRV36RLASmHcPgnkWkL0OYxsK8n(Vw9CkHcPgnkGOCofZ3M99m)8LRVwQXYekKA0OaRusJkFjrY34taRSmrnbxwNkrF56B8FT65ucfM2fRRarbeLZPy(2SVN5NVed0MrB(cOfcw9mAZxD9WmGw9WSELYiqBawiCI98radGi8DtG7bAXkL0OcG(aTr4yiCsG2mAdbSJfkpiZxE(EgOnJ28fqBm16EgT5RUEygqREywVszeOnaleoradWaAHzCsnd4EaICg4EGwSsjnQaOpqBgT5lG2egZc72dHyzaTkKfHZHnFb0EdZ4KAgqBeogcNeOfcwtSF8CqOqHutCmFB2374uF56lz(EGMiiHbFynkYOneqFjrY3B91snwMGbkl)vpiHbFynkWkL0OYxI9LRVqWcfkKAIJ5BZ889uadGi8bCpqlwPKgva0hOnchdHtc0siHtkPrHCY)Eyp(Vw9CkwpJ2qa9LejFpqteKWGpSgfz0gcOVC99anrqcd(WAuar5CkMVnXZxjqkkHK(FvNcegwOaHPnF5ljs(k9mMVC9LAcUSoeLZPy(2epFLaPOes6)vDkqyyHceM28fqBgT5lGwj9)QofimmGbqKqbCpqlwPKgva0hOnchdHtc0siHtkPrHCY)Eyp(Vw9CkwpJ2qa9LejFpqteKWGpSgfz0gcOVC99anrqcd(WAuar5CkMVnXZxjqkkHecziSXubcfimT5lFjrYxPNX8LRVutWL1HOCofZ3M45ReifLqcHme2yQaHceM28fqBgT5lGwjeYqyJPcamaICtG7bAXkL0OcG(aTr4yiCsGwjqkkbyD96WDMbXkWUeGhaTz0MVaA1tWLX68pqvGmwgGbqKtbUhOfRusJka6d0MrB(cOnRiYmyQ7XuRbAvilcNdB(cOLourKzWu77jtT23yw(AWjiaH(EtFpEdlBsTVsGuuSq8fZ4LV6Kztf475t9LHXVumHV342ONtmQ89kHkFJVcv(AJm6BY8n91Gtqac91EFBG4HVJ5letvkPrbqBeogcNeOLqcNusJc5K)9WE8FT65uSEgTHa6ljs(EGMiiHbFynkYOneqF567bAIGeg8H1OaIY5umFBINVNp1xsK8v6zmF56l1eCzDikNtX8TjE(E(uadGi3bW9aTyLsAubqFG2iCmeojqBgTHa2XcLhK5BZ88LpFjrYxY8fcwOqHutCmFBMNVN6lxFHG1e7hphekui1ehZ3M557DWpFjgOnJ28fqBcJzH9dqndbmaIq0aUhOfRusJka6d0gHJHWjbAjKWjL0Oqo5FpSh)xREofRNrBiG(sIKVhOjcsyWhwJImAdb0xU(EGMiiHbFynkGOCofZ3M45ReifLGAGOK(FLqbctB(YxsK8v6zmF56l1eCzDikNtX8TjE(kbsrjOgikP)xjuGW0MVaAZOnFb0snqus)VcWaiYjc4EGwSsjnQaOpqBeogcNeOnJ2qa7yHYdY8LNVN9LRVK5ReifLaSUED4oZGyfyxcWdFjrYxPNX8LRVutWL1HOCofZ3M89uFjgOnJ28fqRug0FQUbNydgGbyagqlbeYMVaicF8Jp(4hF8r0aA5KWAQagqlrpD4gsKBaroHcTV(E)f67iF8qZxQh6l55JDgAGhK7le5pWbIkFzVm6BcAVCAOY34vwbit40qutH(Eo0(EYViGqdv(sULASmb9i3x79LCl1yzc6jWkL0OICFj7mDjw40qutH(YxO99KFraHgQ8LCiyHupmaf0JCFT3xYHGfs9WauqpbwPKgvK7lzNPlXcNgIAk037i0(EYViGqdv(sULASmb9i3x79LCl1yzc6jWkL0OICFjJp6sSWPXPHONoCdjYnGiNqH2xFV)c9DKpEO5l1d9L88XUeiKzK7le5pWbIkFzVm6BcAVCAOY34vwbit40qutH(gQq77j)Iacnu5l5wQXYe0JCFT3xYTuJLjONaRusJkY9LSqrxIfone1uOV3m0(EYViGqdv(soeSqQhgGc6rUV27l5qWcPEyakONaRusJkY9LSZ0LyHtJtdrpD4gsKBaroHcTV(E)f67iF8qZxQh6l5gCQgOXi3xiYFGdev(YEz03e0E50qLVXRScqMWPHOMc99CO99KFraHgQ8LCl1yzc6rUV27l5wQXYe0tGvkPrf5(s2z6sSWPHOMc99MH23t(fbeAOYxYn4unqtCwqpY91EFj3Gt1anHDwqpY9LSqrxIfone1uOV3m0(EYViGqdv(sUbNQbAc(e0JCFT3xYn4unqty8jOh5(sgF0LyHtdrnf67PH23t(fbeAOYxYn4unqtCwqpY91EFj3Gt1anHDwqpY9Lm(OlXcNgIAk03tdTVN8lci0qLVKBWPAGMGpb9i3x79LCdovd0egFc6rUVKfk6sSWPHOMc99ocTVN8lci0qLVKBWPAGM4SGEK7R9(sUbNQbAc7SGEK7lzNPlXcNgIAk037i0(EYViGqdv(sUbNQbAc(e0JCFT3xYn4unqty8jOh5(sgF0LyHtdrnf6lrl0(EYViGqdv(sUbNQbAIZc6rUV27l5gCQgOjSZc6rUVKXhDjw40qutH(s0cTVN8lci0qLVKBWPAGMGpb9i3x79LCdovd0egFc6rUVKDMUelCACAi6Pd3qICdiYjuO9137VqFh5JhA(s9qFjpaleorY9fI8h4arLVSxg9nbTxonu5B8kRaKjCAiQPqFphAFp5xeqOHkFjhcwi1ddqb9i3x79LCiyHupmaf0tGvkPrf5(s2z6sSWPHOMc9LVq77j)Iacnu5l5wQXYe0JCFT3xYTuJLjONaRusJkY9LSZ0LyHtdrnf6lFH23t(fbeAOYxYHGfs9WauqpY91EFjhcwi1ddqb9eyLsAurUVKDMUelCAiQPqF5l0(EYViGqdv(sE8lf4yc6rUV27l5XVuGJjONaRusJkY9LSZ0LyHtdrnf6BOcTVN8lci0qLVKdblK6HbOGEK7R9(soeSqQhgGc6jWkL0OICFj7mDjw40qutH(EAO99KFraHgQ8LCiyHupmaf0JCFT3xYHGfs9WauqpbwPKgvK7lzNPlXcNgNgIE6WnKi3aICcfAF99(l03r(4HMVup0xYJpbSYYyK7le5pWbIkFzVm6BcAVCAOY34vwbit40qutH(Eo0(EYViGqdv(sULASmb9i3x79LCl1yzc6jWkL0OICFj7mDjw40qutH(gQq77j)Iacnu5l5wQXYe0JCFT3xYTuJLjONaRusJkY9LSZ0LyHtdrnf6BOcTVN8lci0qLVKZEqT0ukb9i3x79LC2dQLMsjONaRusJkY9LSZ0LyHtdrnf67ndTVN8lci0qLVKBPgltqpY91EFj3snwMGEcSsjnQi3xYotxIfone1uOV3m0(EYViGqdv(so7b1stPe0JCFT3xYzpOwAkLGEcSsjnQi3xYotxIfone1uOVNgAFp5xeqOHkFjhcwi1ddqb9i3x79LCiyHupmaf0tGvkPrf5(sgF0LyHtdrnf67PH23t(fbeAOYxYzpOwAkLGEK7R9(so7b1stPe0tGvkPrf5(s2z6sSWPHOMc9LOfAFp5xeqOHkFj3snwMGEK7R9(sULASmb9eyLsAurUVKDMUelCAiQPqFpHdTVN8lci0qLVKZEqT0ukb9i3x79LC2dQLMsjONaRusJkY9Lm(OlXcNgNgIE6WnKi3aICcfAF99(l03r(4HMVup0xYpGy8LLsJCFHi)boqu5l7LrFtq7Ltdv(gVYkazcNgIAk03BgAFp5xeqOHkFj3snwMGEK7R9(sULASmb9eyLsAurUVP57n6equ(s2z6sSWPHOMc990q77j)Iacnu5B7iFsFzHllPRV357SV27lrbM(k)kqniZ3)aHP9qFj7otSVKDMUelCAiQPqFpn0(EYViGqdv(sUbNQbAIZc6rUV27l5gCQgOjSZc6rUVKXhDjw40qutH(EhH23t(fbeAOY32r(K(YcxwsxFVZ3zFT3xIcm9v(vGAqMV)bct7H(s2DMyFj7mDjw40qutH(EhH23t(fbeAOYxYn4unqtWNGEK7R9(sUbNQbAcJpb9i3xY4JUelCAiQPqFjAH23t(fbeAOY32r(K(YcxwsxFVZ(AVVefy6RAimS5lF)deM2d9LmArSVKXhDjw40qutH(s0cTVN8lci0qLVKBWPAGM4SGEK7R9(sUbNQbAc7SGEK7lz3KUelCAiQPqFjAH23t(fbeAOYxYn4unqtWNGEK7R9(sUbNQbAcJpb9i3xYoLUelCAiQPqFprH23t(fbeAOYxYTuJLjOh5(AVVKBPgltqpbwPKgvK7lzNPlXcNgIAk03tuO99KFraHgQ8L84xkWXe0JCFT3xYJFPahtqpbwPKgvK7BA(EJobeLVKDMUelCAiQPqFpHdTVN8lci0qLVKdblK6HbOGEK7R9(soeSqQhgGc6jWkL0OICFtZ3B0jGO8LSZ0LyHtdrnf67jCO99KFraHgQ8LCiyHupmaf0JCFT3xYHGfs9WauqpbwPKgvK7lzNPlXcNgNgIE6WnKi3aICcfAF99(l03r(4HMVup0xYJ)RvpNIrUVqK)ahiQ8L9YOVjO9YPHkFJxzfGmHtdrnf6lFH23t(fbeAOYxYTuJLjOh5(AVVKBPgltqpbwPKgvK7lz8rxIfone1uOV8fAFp5xeqOHkFjhcwi1ddqb9i3x79LCiyHupmaf0tGvkPrf5(sgF0LyHtdrnf6lFH23t(fbeAOYxYzpOwAkLGEK7R9(so7b1stPe0tGvkPrf5(sgF0LyHtdrnf67DeAFp5xeqOHkFj3snwMGEK7R9(sULASmb9eyLsAurUVKDMUelCAiQPqFprH23t(fbeAOYxYTuJLjOh5(AVVKBPgltqpbwPKgvK7lzNPlXcNgNgIE6WnKi3aICcfAF99(l03r(4HMVup0xYdWcHtSNpsUVqK)ahiQ8L9YOVjO9YPHkFJxzfGmHtdrnf675q77j)Iacnu5l5wQXYe0JCFT3xYTuJLjONaRusJkY9LSZ0LyHtdrnf6lFH23t(fbeAOYxYHGfs9WauqpY91EFjhcwi1ddqb9eyLsAurUVKDMUelCACAi6Pd3qICdiYjuO9137VqFh5JhA(s9qFjxHujO2i3xiYFGdev(YEz03e0E50qLVXRScqMWPHOMc9nuH23t(fbeAOYxYTuJLjOh5(AVVKBPgltqpbwPKgvK7lzHIUelCAiQPqFVzO99KFraHgQ8LCl1yzc6rUV27l5wQXYe0tGvkPrf5(sgF0LyHtdrnf6lrl0(EYViGqdv(sULASmb9i3x79LCl1yzc6jWkL0OICFjlu0LyHtdrnf67jCO99KFraHgQ8LCl1yzc6rUV27l5wQXYe0tGvkPrf5(s2z6sSWPHOMc99m)cTVN8lci0qLVTJ8j9LfUSKU(EN91EFjkW0x1qyyZx((himTh6lz0IyFj7mDjw40qutH(EMFH23t(fbeAOYxYTuJLjOh5(AVVKBPgltqpbwPKgvK7lz8rxIfone1uOVNphAFp5xeqOHkFj3snwMGEK7R9(sULASmb9eyLsAurUVKDMUelCAiQPqFpZxO99KFraHgQ8LCiyHupmaf0JCFT3xYHGfs9WauqpbwPKgvK7lzNPlXcNgIAk03Z3m0(EYViGqdv(sULASmb9i3x79LCl1yzc6jWkL0OICFj7mDjw40qutH(Y35q77j)Iacnu5l5wQXYe0JCFT3xYTuJLjONaRusJkY9Lm(OlXcNgIAk0x(cvO99KFraHgQ8LCl1yzc6rUV27l5wQXYe0tGvkPrf5(sgF0LyHtJtZnq(4HgQ89m)8nJ28LV6HzmHtdq7b8Pgnc0E376lDIPD5lrh1eCz(EJxxVoStZDVRVeDrjiycd7lFeTq8Lp(XhFonon39U(EYRScqwODAU7D9L)7lDqX)azMmwgZx79Lol6Kw0jsnAKw0jM2fZx6ee91EF)sh234dwMVwcdqJ5lNR33eI(I09aJgQ81EF1db0x9xb(I1dgC5R9(kNMHqFjlFSZqd8W37EMyHtZDVRV8FFPZHLsAu5BBgHd1eNu77DkJMVsymbzOVkmv(gC9GAMVYzd0xQh6llv(sNeDWeon39U(Y)99gNnvGVe9pyP8T9alfc9nLg9ydY8v(HOVuAKUJKoSVKLMV3K2(YSm2G57umdtLVpLVNsBIVXYx68o16BHGgm1(MLYx5mSVhqKawMVSxg9TE(peJ(YgdmT5lMWP5U31x(VV34SPc8LOlYmeovGVTgCAG(oLV0HtWnY3HY3WpOVxjb036TRPc8f1m0x79v9(MLYxoFrU57taHX8WxopyPy(omFPZ7uRVfcAWulCAU7D9L)77jVYkav(kNvyFjNAcUSoeLZPyK7B8l1yZxPM5R9(Mhh6W(oLVspJ5l1eCzmF)sh2xY0iJ57jPtF5Kmd99lFnyYUiw40C376l)3x6GsHkFZ6Tle67ja0KGy2WxSmyyFT3xgA(cE4lZGFfGqFVrhJcLNit40C376l)33BiQt66B79(sGj8LoCcUr(Q)Gj6lBQi67y(cr9GmF)Y34xuPeOonu5lmhvhjGLXeon39U(Y)99(taDEccTV(s0nJ2d9T1Gyfyx(Ea)iZ3PS3xdovd08v)btu4040KrB(IjoGy8LLsJ28O1XBZxonz0MVyIdigFzP0OnpAbZHHDfMkNMmAZxmXbeJVSuA0MhTO0i7kctkZPjJ28ftCaX4llLgT5rRekhU)uD7c7kmvHCaX4llLw3gzKxOczO4DRLASmbduw(REqcd(WA0P5U(EJiKAW0qMVPVgCQgOX8n(Vw9CQq8vnegfQ8vkSV38uHV3FnmF5KmFJxpdlFtMVG11Rd7lNh2G57x(EZt9LHXVu(kbczMVXWrnYcXxjqZ3RK5R9VVYzf23Oc6lsrHrJ5R9(gmeqFtFJ)RvpNsqxHceM28LVQHWWEOVtXmmvcFVbu(og5mFjKAq03RK5B9(cr5Ckfc9fIgiS89Ci(IAg6lenqy5l)eNkCAYOnFXehqm(YsPrBE0IqcNusJHuPmYZGt1aT(5olCfd5p4XqBOcHqQbrENdHqQbXoQzip(jonK4xQXMV4zWPAGM4S4kzDqg2LaPO4sMbNQbAIZI4)A1ZPekqyAZx3578npLh)i2PjJ28ftCaX4llLgT5rlcjCsjngsLYipdovd0681zHRyi)bpgAdviesniY7Ciesni2rnd5XpXPHe)sn28fpdovd0e8jUswhKHDjqkkUKzWPAGMGpr8FT65ucfimT5R78D(MNYJFe70CxFVrmBKtdz(M(AWPAGgZxcPge9vkSVXx(iHtf4RDH(g)xREoLVpLV2f6RbNQbAH4RAimku5RuyFTl0xfimT5lFFkFTl0xjqkkFhZ3d4tyuit4lrNjZ30xMbXkWU8v(vd1GqFT33GHa6B671eCHqFpGZdhlSV27lZGyfyx(AWPAGgleFtMVCqT23K5B6R8RgQbH(s9qFhkFtFn4unqZxoJw77d9LZO1(wV5llCf9LZyx(g)xREoft40KrB(IjoGy8LLsJ28OfHeoPKgdPszKNbNQbA9d48WXchYFWJH2qfcHudI84lecPge7OMH8ohs8l1yZx8U1Gt1anXzXvY6GmSlbsrX1Gt1anbFIRK1bzyxcKIIejdovd0e8jUswhKHDjqkkUKrMbNQbAc(eX)1QNtjuGW0MVUZgCQgOj4tibsr1vGW0MViMos2zXP02Gt1anbFIRK1LaPOiMosgHeoPKgfgCQgO15RZcxrIjUzYiZGt1anXzr8FT65ucfimT5R7SbNQbAIZcjqkQUceM28fX0rYoloL2gCQgOjolUswxcKIIy6izes4KsAuyWPAGw)CNfUIetStZD99gri1GPHmFJGqiwMVm0ap8L6H(AxOV8hyw2yH99P8LoC8Xuh(GH(Es68g6lsrHrJ50KrB(IjoGy8LLsJ28OfHeoPKgdPszKhfOw3JkyiesniYZsnwMiHYH7pv3UWUkLluXn(LcCmr8lcFmT5R(t1TlSRWu50KrB(IjoGy8LLsJ28OfHeoPKgdPszKNk2HwiesniYdcwi1ddqHct7I1Ji0YPSWCHGfs9Wauat5JSSUbZIrHqSIOtJtZDVRV3i6Irqdv(IeqyyFTrg91UqFZO9qFhMVjHC0PKgfonz0MVy8KNs1PGiEIrNM767DcIeWY8LDGXHAqLVgCQgOX8vcNkWxqgQ8LZyx(MG2lN2e9vpfYCAYOnFXOnpAriHtkPXqQug5XoW4qnOQBWPAGwiesniYJmK)aNJdujMIfHGwkPXo)bMLbk3viHjIKiH8h4CCGkHDHDQbYSoBcgnjsi)bohhOs8eqiNlulpvq)45GWEegMzPMyUKf)xREoLykwecAPKg78hywgOCxHeMikGyQctIu8FT65uc7c7udKzD2emAbeLZPyKif)xREoL4jGqoxOwEQG(XZbH9immZsTaIY5umIjrImK)aNJdujSlStnqM1ztWOjrc5pW54avINac5CHA5Pc6hphe2JWWml1eZf5pW54avIPyriOLsASZFGzzGYDfsyIOtZDVRV3ys4KsAK50KrB(IrBE0IqcNusJHuPmY74F9ubDiynX(XZbHHqi1GiV4)A1ZPemqz5V6bjm4dRrbeLZPynDkxl1yzcgOS8x9Geg8H1ixYSuJLjaRRxhUlPNGlJB8FT65ucW661H7s6j4YequoNI105qXn(Vw9CkHkHn6gmlg1dLtB(sar5CkwhP7bgnu105qrI0TwQXYeG11Rd3L0tWLrSttgT5lgT5rlcjCsjngsLYiVJ)1tf0HGfYcHqQbrEwQXYeShu3HyEGqUqWcBIpUwcdqtyJm2TVFeTEOoTPt5snbxwhIY5uSMpLeP4taRSmrnbxwNkrUwQXYekKA0i34)A1ZPekKA0OaIY5uSMGGfkSrg7235ZPjJ28fJ28OfHeoPKgdPszKhZ6h6SQPccHqQbrEz0gcyhluEqgVZCj7wyoQosaltKkftG0DygJejyoQosaltKkftmvZNpLyNMmAZxmAZJwes4KsAmKkLrEPsX6quoNkecPge5LrBiGDSq5bznZJpUKDlmhvhjGLjsLIjq6omJrIemhvhjGLjsLIjq6omJXLmyoQosaltKkftar5CkwZNsIe1eCzDikNtXA(m)iMyNMmAZxmAZJwes4KsAmKkLrEYj)7H94)A1ZPy9mAdbmecPge5rMLASmbduw(REqcd(WAK7ThOjcsyWhwJImAdbKB8FT65ucgOS8x9Geg8H1OaIY5umsKU1snwMGbkl)vpiHbFynsmxYKaPOeG11Rd3tglb1Ma8Gejl1yzIekhU)uD7c7QuUqf3d0e5Xh7bxpOwKrBiGKijbsrjujSr3GzXOEOCAZxcWdUsGuucvcB0nywmQhkN28LaIY5uSMpLePmAdbSJfkpiRzE8XvHPD1Zs1vymdlSj2yQaIDAYOnFXOnpAriHtkPXqQug5PaLp6CEWsXcHqQbrEXNawzzIAcUSovICvyAx9SuDfgZWcBInMkGReifLqHPDX6kquWSm2OPBsIKeifLqoHWNdQ6bOmZ(c7yDLveLXYeGhKijbsrjSl4O1DgInqOa8GejjqkkbfeRt8GQU8xmd(SXclapirscKIsOXu1Lc3r6MYhAuaEqIKeifLiELpRlLfkapirk(Vw9CkbyD96W9KXsqTjGOCofRPt5g)xREoLip(yQdFWqbeLZPynFMFon313BSZPSCQPc89gZab1yz(EN0zai67W8n99aopCSWonz0MVy0MhTEqtcIzJqgkEQ3eegiOglRFOZaquarkiYUsjnY9wl1yzcW661H7s6j4Y4ElmhvhjGLjsLIjq6omJ50KrB(IrBE06bnjiMncjgoQXULWa0y8ohYqXt9MGWab1yz9dDgaIcisbr2vkPrUz0gcyhluEqwZ84Jlz3APgltawxVoCxspbxgjswQXYeG11Rd3L0tWLXLS4)A1ZPeG11Rd3L0tWLjGOCofRzYoF6DoJ2qa7yHYdYOT6nbHbcQXY6h6maefquoNIrmjsz0gcyhluEqwZ8cfXe70CxFVbu(Axie9nHOVyHYdY8vEySPc89gZDkeFZJdDyFhZxYKanFR3x5hI(Axz57xr03de67D4ldJFPyelCAYOnFXOnpA9GMeeZgHONc7rfV7iKHIxgTHa2vVjimqqnww)qNbGytz0gcyhluEqg3mAdbSJfkpiRzE8XLSBTuJLjaRRxhUlPNGlJeP4)A1ZPeG11Rd3L0tWLjGOCofJReifLaSUED4UKEcUSUeifLq9CkIDAYOnFXOnpA9GMeeZgHmu8GGfs9WauWapqiZG5uCjt9MGc(mRtHeqOaIuqKDLsAKej1Bcj9)Q(HodarbePGi7kL0iXon313Bisbr2fY8LoX0Uy(sNGi5mFLaPO8L)bYmFLqQhI(QW0Uy(QarFXsXCAYOnFXOnpAX5blvNDGLcHHmu8IpbSYYe1eCzDQe5QW0U6zP6kmMHf2eBmvaxYuyAx9SuDfgZWImAdbSdr5CkwtKfev0XZItjMejjqkkHct7I1vGOaIY5uSMcIkIDAYOnFXOnpAXjhlegg5f)xREoLG9G6oeZdekGOCoflKHINLASmb7b1DiMhiKRLWa0e2iJD77hrRhQtB6uUwcdqtyJm2TVRgS5t5g)xREoLG9G6oeZdekGOCofRjYcIk6i)eeTtjMBgTHa2XcLhKX7StZD9LOphZxQh6lDIPDroZx6eePfDIuJg9DO8LitWL5lr3e91EFdqZxMbXkWU8vcKIYxPm2W3KLhonz0MVy0MhT4KJfcdJ8I)RvpNsOW0UyDfikGOCoflKHIx8jGvwMOMGlRtLi34)A1ZPekmTlwxbIcikNtXAkiQ4MrBiGDSq5bz8o70KrB(IrBE0ItowimmYl(Vw9CkHcPgnkGOCoflKHIx8jGvwMOMGlRtLi34)A1ZPekKA0OaIY5uSMcIkUz0gcyhluEqgVZon31x6q0MV8LOgMX8nlLVNGdSqiZxYobhyHqgTAr(deRiY8fSyGhhp0qLVt5BQuFji2PjJ28fJ28Ovm16EgT5RUEywivkJ8m4unqJ50KrB(IrBE0kMADpJ28vxpmlKkLrEXNawzzmNMmAZxmAZJwXuR7z0MV66HzHuPmYdMXj1mNM7ExFZOnFXOnpAXq(deRigYqXlJ2qa7yHYdY4DM7TkmTREJAcUmHAyPKg75BkUwQXYemqz5V6bjm4dRXqQug5fKWG(FGfcd9dAsqmBeAkKziCQGoZGtdm0uiZq4ubDMbNgyOzGYYF1dsyWhwJHoHYH7pv3UWUctvOvyAx94p6qgkEsGuucgOsHvx9VSa8i0kmTRE8hDOvyAx94p6qZIpima7mdonWqgkEkucKIsqHmdHtf058GLsWSm2O5BgAw8bHbyNzWPbgYqXtHsGuuckKziCQGoNhSucMLXgnFZqtHmdHtf0zgCAGon39U(MrB(IrBE0IH8hiwrmKHIxgTHa2XcLhKX7m3BvyAx9g1eCzc1Wsjn2Z3uCV1snwMGbkl)vpiHbFyngsLYiV)alegAkKziCQGoZGtdm0uiZq4ubDMbNgyOpEB(k0G11Rd3L0tWLfAvcB0nywmQhkN28vOZJpM6Whm0PjJ28fJ28Ovm16EgT5RUEywivkJ8I)RvpNI50KrB(IrBE0ccw9mAZxD9WSqQug5Lp2zObEeYqXJqcNusJIuPyDikNtXLS4)A1ZPekmTREwQUcJzybeLZPynDMFCV1snwMqHuJgjrk(Vw9CkHcPgnkGOCofRPZ8JRLASmHcPgnsIu8jGvwMOMGlRtLi34)A1ZPekmTlwxbIcikNtXA6m)iM7TkmTREwQUcJzyHnXgtf40KrB(IrBE0ccw9mAZxD9WSqQug5Lp2LaHmleMbNOX7CidfVmAdbSJfkpiRzE8XvHPD1Zs1vymdlSj2yQaNMmAZxmAZJwqWQNrB(QRhMfsLYiVaSq4e75JHmu8YOneWowO8GSM5Xh3BvyAx9SuDfgZWcBInMkGlz3siHtkPrrQuSoeLZPirk(Vw9CkHct7QNLQRWygwar5CkwZN5h3BTuJLjui1OrsKI)RvpNsOqQrJcikNtXA(m)4APgltOqQrJKifFcyLLjQj4Y6ujYn(Vw9CkHct7I1vGOaIY5uSMpZpIDAYOnFXOnpAftTUNrB(QRhMfsLYiVaSq4edzO4LrBiGDSq5bz8o7040C376lD4Vr(sFqiZCAYOnFXe5JDjqiZ4f1jNPc6SRu9CyHmu8YOneWowO8GSM4DQttgT5lMiFSlbczgT5rROo5mvqNDLQNdlKHIxgTHa2XcLhKX7o4QW0U6nQj4YeuCEWsHQULWa0ynZluonz0MVyI8XUeiKz0MhT48GLQZoWsHWqgkEwQXYesGqMnvqN9qKXLmfM2vVrnbxMGIZdwku1TegGgJxgTHa2XcLhKrIKct7Q3OMGltqX5blfQ6wcdqJ1mVqrmjswQXYesGqMnvqN9qKX1snwMiQtotf0zxP65W4QW0U6nQj4YeuCEWsHQULWa0ynZ7SttgT5lMiFSlbczgT5rlfM2vp(JoKHIhzsGuucgOsHvx9VSaIz0ir6wcjCsjnko(xpvqhcwtSF8CqiXCjtcKIsOsyJUbZIr9q50MVeGhCHGfs9WauOWuPhKz94pAUz0gcyhluEqwt8cfjsz0gcyhluEqgp(i2PjJ28ftKp2LaHmJ28OfEmkuEIHmu8GG1e7hphekui1ehRjYoZpARW0U6nQj4YeuCEWsHQULWa0y0XqrmxfM2vVrnbxMGIZdwku1TegGgRP7G7Tes4KsAuC8VEQGoeSMy)45GqsKKaPOemojuEQGU8Wmb4HttgT5lMiFSlbczgT5rl8yuO8edzO4bbRj2pEoiuOqQjowt8DkxfM2vVrnbxMGIZdwku1TegGgR5t5ElHeoPKgfh)RNkOdbRj2pEoi0PjJ28ftKp2LaHmJ28OfEmkuEIHmu8UvHPD1ButWLjO48GLcvDlHbOX4ElHeoPKgfh)RNkOdbRj2pEoiKejQj4Y6quoNI10PKibZr1rcyzIuPycKUdZyCH5O6ibSmrQumbeLZPynDQttgT5lMiFSlbczgT5rlopyP6SdSui0PjJ28ftKp2LaHmJ28OfEmkuEIHmu8ULqcNusJIJ)1tf0HG1e7hphe6040C376lD4Vr(2Ig4HttgT5lMiFSZqd8GxwH7QsfYqXtHPD1ButWLjO48GLcvDlHbOXAMxmCuJDSq5bzKiPW0U6nQj4YeuCEWsHQULWa0ynZ7usKU1snwMqceYSPc6ShImsKG5O6ibSmrQumbs3HzmUWCuDKawMivkMaIY5uSM4D(mjsspJXLAcUSoeLZPynX78zNMmAZxmr(yNHg4bT5rlfM2vp(JoKHI3Tes4KsAuC8VEQGoeSMy)45GqUKjbsrjujSr3GzXOEOCAZxcWdUqWcPEyakuyQ0dYSE8hn3mAdbSJfkpiRjEHIePmAdbSJfkpiJhFe70KrB(IjYh7m0apOnpAHhJcLNyidfVBjKWjL0O44F9ubDiynX(XZbHonz0MVyI8XodnWdAZJwuiZq4ubDMbNgyiXWrn2TegGgJ35qgkEkucKIsqHmdHtf058GLsWSm2OjEHIB8FT65uI84JPo8bdfquoNI1uOCAYOnFXe5JDgAGh0MhTOqMHWPc6mdonWqIHJASBjmangVZHmu8uOeifLGczgcNkOZ5blLGzzSrtNDAYOnFXe5JDgAGh0MhTOqMHWPc6mdonWqIHJASBjmangVZHmu8GGfkSrg723VztKf)xREoLqHPD1Zs1vymdlGOCofJ7TwQXYekKA0ijsX)1QNtjui1OrbeLZPyCTuJLjui1OrsKIpbSYYe1eCzDQe5g)xREoLqHPDX6kquar5CkgXon31xI(lS81syaA(Y4KhmFti6RAyPKgvH4RDnmF5mATVA08n8d6l7alLVqWcz0IZdwkMVtXmmv((u(YjhBQaFPEOV0zrN0IorQrJ0IoX0UiN5lDcIcNMmAZxmr(yNHg4bT5rlopyP6SdSuimKHIhz3YqZMkGjIHJAKejfM2vVrnbxMGIZdwku1TegGgRzEXWrn2XcLhKrmxfkbsrjOqMHWPc6CEWsjywgB0CO4cbluyJm2TVhQMI)RvpNsKv4UQucikNtXCACAU7D99o928LttgT5lMi(Vw9CkgVJ3MVczO4riHtkPrHCY)Eyp(Vw9CkwpJ2qajr6anrqcd(WAuKrBiGCpqteKWGpSgfquoNI1ep(UdsKKEgJl1eCzDikNtXAIV7WP5U313t(Vw9CkMttgT5lMi(Vw9CkgT5rRekhU)uD7c7kmvHmu8I)RvpNsOsyJUbZIr9q50MVequoNI1r6EGrdvnr04sw8FT65ucW661H7s6j4YequoNI1erJRLASmbyD96WDj9eCzKiDRLASmbyD96WDj9eCzeZLmgADPVazcBqiFNO(npICTegGMWgzSBF)iA9qDAt3KePBzO1L(cKjSbH8DI638isIe1eCzDikNtXAMp(XpI5sw8FT65uIu6LNkT5RUEKLequoNI105texYGGfs9WauKsV8uPnFX6uqSoXHjrI9GAPPuIgiHPy9)pXOEQaIjr6wiyHupmafP0lpvAZxSofeRtCyU3YEqT0ukrdKWuS()NyupvaXCjl(Vw9CkrE8Xuh(GHcikNtX6iDpWOHQMiACjKWjL0OGcuR7rfKePBjKWjL0OGcuR7rfKejcjCsjnkuXo0iMejPNX4snbxwhIY5uSMc1Ponz0MVyI4)A1ZPy0MhTypOUdX8aHHedh1y3syaAmENdzO4zjmanHnYy3((r06H60MoLlzwcdqtyJm2TVRgS5t5MrBiGDSq5bznXluKiXqRl9fitydc57e1V5rKReifLqLWgDdMfJ6HYPnFjap4MrBiGDSq5bznX7uUKDRct7QNLQRWygwytSXubKifFcyLLjQj4Y6ujsmXon31xIoFTI5l91tWL5l1d9f8Wx799uFzy8lfZx79LfUI(YzSlFPdhFm1Hpyyi(EcSleYzyyi(cYqF5m2LV0zcB479WSyupuoT5lHttgT5lMi(Vw9CkgT5rlW661H7s6j4YczO4riHtkPrbZ6h6SQPc4sw8FT65uI84JPo8bdfquoNI1r6EGrdvnDkjsX)1QNtjYJpM6Whmuar5CkwhP7bgnu18z(rmxYI)RvpNsOsyJUbZIr9q50MVequoNI1uqurIKeifLqLWgDdMfJ6HYPnFjapi2PjJ28fte)xREofJ28OfyD96WDj9eCzHmu8iKWjL0OivkwhIY5uKij9mgxQj4Y6quoNI1eFNDAYOnFXeX)1QNtXOnpAPsyJUbZIr9q50MVczO4riHtkPrbZ6h6SQPc4sM6nbyD96WDj9eCzD1BcikNtXir6wl1yzcW661H7s6j4Yi2PjJ28fte)xREofJ28OLkHn6gmlg1dLtB(kKHIhHeoPKgfPsX6quoNIejPNX4snbxwhIY5uSM47SttgT5lMi(Vw9CkgT5rR84JPo8bddzO4LrBiGDSq5bz8oZvHsGuuckKziCQGoNhSucMLXgnZ7MCj7wcjCsjnkOa16EubjrIqcNusJckqTUhvqUKf)xREoLaSUED4UKEcUmbeLZPynFMFKif)xREoLqLWgDdMfJ6HYPnFjGOCofRJ09aJgQA(m)4ERLASmbyD96WDj9eCzetSttgT5lMi(Vw9CkgT5rR84JPo8bddjgoQXULWa0y8ohYqXlJ2qa7yHYdYAMhFCvOeifLGczgcNkOZ5blLGzzSrZ8Uj3BvyAx9SuDfgZWcBInMkWPjJ28fte)xREofJ28Ofduw(REqcd(WAmKHIheSMy)45GqHcPM4ynD(MCJ)RvpNsawxVoCxspbxMaIY5uSMohkUX)1QNtjujSr3GzXOEOCAZxcikNtX6iDpWOHQMohkNMmAZxmr8FT65umAZJwG11Rd3tglb1widfpcjCsjnkyw)qNvnvaxfkbsrjOqMHWPc6CEWsjywgB0eFCj7anrE8XEW1dQfz0gcijssGuucvcB0nywmQhkN28La8GB8FT65uI84JPo8bdfquoNI18z(rIu8FT65uI84JPo8bdfquoNI18z(Xn(Vw9CkHkHn6gmlg1dLtB(sar5CkwZN5hXonz0MVyI4)A1ZPy0MhTaRRxhUNmwcQTqIHJASBjmangVZHmu8YOneWowO8GSM5XhxfkbsrjOqMHWPc6CEWsjywgB0eFCj7anrE8XEW1dQfz0gcijssGuucvcB0nywmQhkN28La8GeP4)A1ZPekmTREwQUcJzybeLZPynfeve70KrB(IjI)RvpNIrBE0cMdd7kmvHmu8U9anrW1dQfz0gcOtZDVRV05WsjnQcXx(hiZ8TEZxiMADyFRhkNAFLWRKW8qFTR0iN5lNhAx(EaczGtf47u8)Gugfon39U(MrB(IjI)RvpNIrBE0ILr4qnXj19JmAHmu8YOneWowO8GSM5Xh3BLaPOeQe2OBWSyupuoT5lb4b34)A1ZPeQe2OBWSyupuoT5lbeLZPynFkjsspJXLAcUSoeLZPynfevonon39U(EYNawzz(shKg9ydYCAYOnFXeXNawzzmEmojuEQGU8WSqgkEes4KsAuWS(HoRAQaUqWAI9JNdcfkKAIJ1857GlzX)1QNtjYJpM6Whmuar5Ckgjs3APgltKq5W9NQBxyxLYfQ4g)xREoLqLWgDdMfJ6HYPnFjGOCofJysKKEgJl1eCzDikNtXA68zNM76BlA(AVVGm03KYqOV5Xh9Dy((LVNKo9nz(AVVhqKawMVpbegZJJPc89gEN8LZ1OrFzOztf4l4HVNKojN50KrB(IjIpbSYYy0MhTyCsO8ubD5HzHmu8I)RvpNsKhFm1HpyOaIY5umUKLrBiGDSq5bznZJpUz0gcyhluEqwt8oLleSMy)45GqHcPM4ynFMF0MSmAdbSJfkpiJoEheZLqcNusJIuPyDikNtrIugTHa2XcLhK18PCHG1e7hphekui1ehR5BYpIDAYOnFXeXNawzzmAZJwP0lpvAZxD9ilfYqXJqcNusJcM1p0zvtfW9w2dQLMsj0yQ6sH7iDt5dnYLS4)A1ZPe5XhtD4dgkGOCofJePBTuJLjsOC4(t1TlSRs5cvCJ)RvpNsOsyJUbZIr9q50MVequoNIrmxiyHcBKXU99B2SeifLacwtShFie8WMVequoNIrIK0ZyCPMGlRdr5Ckwt8D2PjJ28fteFcyLLXOnpALsV8uPnF11JSuidfpcjCsjnkyw)qNvnvax2dQLMsj0yQ6sH7iDt5dnYLm1BcW661H7s6j4Y6Q3equoNI185ZKiDRLASmbyD96WDj9eCzCJ)RvpNsOsyJUbZIr9q50MVequoNIrSttgT5lMi(eWklJrBE0kLE5PsB(QRhzPqgkEes4KsAuWS(HoRAQaUShulnLs0ajmfR))jg1tfWLmfkbsrjOqMHWPc6CEWsjywgB0mVBY9wiyHupmafP0lpvAZxSofeRtCysKGGfs9WauKsV8uPnFX6uqSoXH5g)xREoLip(yQdFWqbeLZPye70KrB(IjIpbSYYy0MhTsPxEQ0MV66rwkKHIhHeoPKgfPsX6quoNIleSqHnYy3((nBwcKIsabRj2JpecEyZxcikNtXCAYOnFXeXNawzzmAZJwSRm2qJD7c7GfNhAxHdzO4riHtkPrbZ6h6SQPc4sw8FT65uI84JPo8bdfquoNI18z(rI0TwQXYejuoC)P62f2vPCHkUX)1QNtjujSr3GzXOEOCAZxcikNtXiMejPNX4snbxwhIY5uSMoFQttgT5lMi(eWklJrBE0IDLXgASBxyhS48q7kCidfpcjCsjnksLI1HOCofxYuyAx9SuDfgZWcBInMkGejyoQosaltKkftar5Ckwt8oFtIDAYOnFXeXNawzzmAZJwuAKDfHjLfYqXJ9GAPPuIdqMbQXocbpS5lsKypOwAkLGWRtB0yN9AcyzCVvcKIsq41PnASZEnbSS(fOCw)OeGhHmLHqi4H1hzzunPH8ohYugcHGhwpq)sPM35qMYqie8W6dfp2dQLMsji860gn2zVMawMtJtZDVRVTtfOrFVpHbO50KrB(IjcWcHtKNct7Qh)rhYqX7wcjCsjnko(xpvqhcwtSF8CqixYKaPOemqLcRU6FzbeZOrIeeSMy)45GqHcPM4ynX7COOnzqWcPEyakGP8rww3GzXOqiwrKogkARW0U6nQj4YeqWcPEyakUcZmeojDmuetmjshOjcsyWhwJImAdbKleSWM4fksKOMGlRdr5CkwtN5h3BvOeifLGczgcNkOZ5blLa8WPjJ28fteGfcNiT5rRSc3vLkKHIhzwQXYekKA0OaRusJksKIpbSYYe1eCzDQejrccwi1ddqXXfMWx(lKrmxYi7wcjCsjnko(xpvqhcwiJeP4taRSmrnbxwNkrUwQXYekKA0i34xkWXeCg7cHtf0dGpyPiMejPNX4snbxwhIY5uSMoLyNMmAZxmrawiCI0MhT48GLQZoWsHWqgkEes4KsAuOaLp6CEWsX4QqjqkkbfYmeovqNZdwkbZYyJM5DMB8FT65uI84JPo8bdfquoNI1r6EGrdvnF(u(pzqWcPEyakuyQ0dYSE8hnD8m)iM7Tes4KsAuC8VEQGoeSqMttgT5lMialeorAZJwCEWs1zhyPqyidfpfkbsrjOqMHWPc6CEWsjywgB0CO4ElHeoPKgfh)RNkOdblKrIKcLaPOeuiZq4ubDopyPeGhCPMGlRdr5CkwtKPqjqkkbfYmeovqNZdwkbZYyd6yqurSttgT5lMialeorAZJwkmTRE8hDidfpiynX(XZbHcfsnXXAIhF8J2KbblK6HbOaMYhzzDdMfJcHyfr64nPTct7Q3OMGltablK6HbO4kmZq4K0XBsm3BjKWjL0O44F9ubDiynX(XZbHonz0MVyIaSq4ePnpArHmdHtf0zgCAGHmu8uOeifLGczgcNkOZ5blLGzzSrt3K7Tes4KsAuC8VEQGoeSqMttgT5lMialeorAZJwkmTRE8hDidfVBjKWjL0O44F9ubDiynX(XZbHonz0MVyIaSq4ePnpAX5blvNDGLcHHmu8uOeifLGczgcNkOZ5blLGzzSrZ8oZfcwyt8X9wcjCsjnko(xpvqhcwiJB8FT65uI84JPo8bdfquoNI1r6EGrdvnFQtJtZDVRVNqyHWj6lD4Vr(ENGZdhlSttgT5lMialeoXE(ipo5yHWWiV4)A1ZPeShu3HyEGqbeLZPyHmu8SuJLjypOUdX8aHCTegGMWgzSBF)iA9qDAtNYLAcUSoeLZPynFk34)A1ZPeShu3HyEGqbeLZPynrwqurh5NGODkXCZOneWowO8GSM4fkNMmAZxmrawiCI98rAZJwkmTRE8hDidfpYULqcNusJIJ)1tf0HG1e7hphesIKeifLGbQuy1v)llGygnI5sMeifLqLWgDdMfJ6HYPnFjap4cblK6HbOqHPspiZ6XF0CZOneWowO8GSM4fksKYOneWowO8GmE8rSttgT5lMialeoXE(iT5rl8yuO8edzO4jbsrjyGkfwD1)YciMrJePBjKWjL0O44F9ubDiynX(XZbHon313BaLVwcdqZ3y4OEQaFhMVQHLsAufIVmoJfV8vkJn81EFTl0x2ubAK)BjmanFdWcHt0x9WmFNIzyQeonz0MVyIaSq4e75J0MhTGGvpJ28vxpmlKkLrEbyHWjgcZGt04DoKHIxmCuJDSq5bz8o70KrB(IjcWcHtSNpsBE0IZdwQo7alfcdjgoQXULWa0y8ohYqXJS4)A1ZPe5XhtD4dgkGOCofR5t5QqjqkkbfYmeovqNZdwkb4bjskucKIsqHmdHtf058GLsWSm2O5qrmxYOMGlRdr5CkwtX)1QNtjuyAx9SuDfgZWcikNtXO9z(rIe1eCzDikNtXAo(Vw9CkrE8Xuh(GHcikNtXi2PjJ28fteGfcNypFK28OffYmeovqNzWPbgsmCuJDlHbOX4DoKHINcLaPOeuiZq4ubDopyPemlJnAIxO4g)xREoLip(yQdFWqbeLZPynDkjskucKIsqHmdHtf058GLsWSm2OPZonz0MVyIaSq4e75J0MhTOqMHWPc6mdonWqIHJASBjmangVZHmu8I)RvpNsKhFm1HpyOaIY5uSMpLRcLaPOeuiZq4ubDopyPemlJnA6StZD99(RH57W8fPOWOneqDyFPgTgH(Y5AIx(YgzMV05DQ13cbnyQdXxjqZx21dQv(Earcyz(M(YIyLW59LZfcrFTl03uP(Y3RK5B921ub(AVVqm(YYyPeonz0MVyIaSq4e75J0MhTOqMHWPc6mdonWqgkEz0gcyx9MGczgcNkOZ5blvZ8IHJASJfkpiJRcLaPOeuiZq4ubDopyPemlJnA6Monon313BygNuZCAYOnFXeWmoPMXlHXSWU9qiwwidfpiynX(XZbHcfsnXXA(ooLlzhOjcsyWhwJImAdbKePBTuJLjyGYYF1dsyWhwJcSsjnQiMleSqHcPM4ynZ7uNMmAZxmbmJtQz0MhTK0)R6uGWWHmu8iKWjL0Oqo5FpSh)xREofRNrBiGKiDGMiiHbFynkYOneqUhOjcsyWhwJcikNtXAINeifLqs)VQtbcdluGW0MVirs6zmUutWL1HOCofRjEsGuucj9)QofimSqbctB(YPjJ28ftaZ4KAgT5rljeYqyJPcczO4riHtkPrHCY)Eyp(Vw9CkwpJ2qajr6anrqcd(WAuKrBiGCpqteKWGpSgfquoNI1epjqkkHecziSXubcfimT5lsKKEgJl1eCzDikNtXAINeifLqcHme2yQaHceM28LttgT5lMaMXj1mAZJw6j4YyD(hOkqgllKHINeifLaSUED4oZGyfyxcWdNM76lDOIiZGP23tMATVXS81Gtqac99M(E8gw2KAFLaPOyH4lMXlF1jZMkW3ZN6ldJFPycFVXTrpNyu57vcv(gFfQ81gz03K5B6RbNGae6R9(2aXdFhZxiMQusJcNMmAZxmbmJtQz0MhTYkImdM6Em16qgkEes4KsAuiN8Vh2J)RvpNI1ZOneqsKoqteKWGpSgfz0gci3d0ebjm4dRrbeLZPynX78PKij9mgxQj4Y6quoNI1eVZN60KrB(IjGzCsnJ28OvcJzH9dqnddzO4LrBiGDSq5bznZJpsKidcwOqHutCSM5DkxiynX(XZbHcfsnXXAM3DWpIDAYOnFXeWmoPMrBE0IAGOK(FvidfpcjCsjnkKt(3d7X)1QNtX6z0gcijshOjcsyWhwJImAdbK7bAIGeg8H1OaIY5uSM4jbsrjOgikP)xjuGW0MVirs6zmUutWL1HOCofRjEsGuucQbIs6)vcfimT5lNMmAZxmbmJtQz0MhTKYG(t1n4eBWczO4LrBiGDSq5bz8oZLmjqkkbyD96WDMbXkWUeGhKij9mgxQj4Y6quoNI10Pe7040C37679WPAGgZPjJ28ftyWPAGgJhid7JHYHuPmYBkwecAPKg78hywgOCxHeMigYqXJS4)A1ZPeG11Rd3L0tWLjGOCofRz(4hjsX)1QNtjujSr3GzXOEOCAZxcikNtX6iDpWOHQM5JFeZLSmAdbSJfkpiRzE8rI0bAIekhUhC9GArgTHasI0bAI84J9GRhulYOneqUKzPgltawxVoCpzSeuBKiPW0U6nQj4YeQHLsASNVPiMePd0ebjm4dRrrgTHasmjsspJXLAcUSoeLZPynX3zsKuyAx9g1eCzc1Wsjn2h(t1r6Irqd5XpUwcdqtyJm2TVFeToF8RPtDAYOnFXegCQgOXOnpAbYW(yOCivkJ8SlStnqM1ztWOdzO4riHtkPrHCY)Eyp(Vw9CkwpJ2qa5sMnYyZHIFKiDlYFGZXbQetXIqqlL0yN)aZYaL7kKWerIDAYOnFXegCQgOXOnpAbYW(yOCivkJ8EciKZfQLNkOF8CqypcdZSuhYqXJqcNusJc5K)9WE8FT65uSEgTHaYLmBKXMdf)ir6wK)aNJdujMIfHGwkPXo)bMLbk3viHjICVf5pW54avc7c7udKzD2emAIDAURV3FH(AWPAGMVCg7Yx7c99AcUqM5lYSronu5lHudIH4lNrR9vc9fKHkFPgiZ8nlLVh5arLVCg7Yx6WXhtD4dg6lzdLVsGuu(omFpFQVmm(LI57d9vJmgX((qFPVEcUmArN37lzdLVbqmne6RDLLVNp1xgg)sXi2PjJ28ftyWPAGgJ28OLbNQbANdzO4DlHeoPKgfSdmoudQ6gCQgOXLmYm4unqtCwibsr1vGW0MVAI35t5g)xREoLip(yQdFWqbeLZPynZh)irYGt1anXzHeifvxbctB(Q5ZNYLS4)A1ZPeG11Rd3L0tWLjGOCofRz(4hjsX)1QNtjujSr3GzXOEOCAZxcikNtX6iDpWOHQM5JFetIugTHa2XcLhK1mp(4kbsrjujSr3GzXOEOCAZxcWdI5s2TgCQgOj4tCLSE8FT65uKizWPAGMGpr8FT65ucikNtXirIqcNusJcdovd06hW5HJfM3zIjMejPNX4AWPAGM4SqcKIQRaHPnF1mpQj4Y6quoNI50KrB(Ijm4unqJrBE0YGt1an(czO4DlHeoPKgfSdmoudQ6gCQgOXLmYm4unqtWNqcKIQRaHPnF1eVZNYn(Vw9CkrE8Xuh(GHcikNtXAMp(rIKbNQbAc(esGuuDfimT5RMpFkxYI)RvpNsawxVoCxspbxMaIY5uSM5JFKif)xREoLqLWgDdMfJ6HYPnFjGOCofRJ09aJgQAMp(rmjsz0gcyhluEqwZ84JReifLqLWgDdMfJ6HYPnFjapiMlz3AWPAGM4S4kz94)A1ZPirYGt1anXzr8FT65ucikNtXirIqcNusJcdovd06hW5HJfMhFetmjsspJX1Gt1anbFcjqkQUceM28vZ8OMGlRdr5CkMtZD99gq57x6W((f67x(cYqFn4unqZ3d4tyuiZ30xjqkQq8fKH(AxOVVDHqF)Y34)A1ZPe(EcG(ou(w4yxi0xdovd089a(egfY8n9vcKIkeFbzOVsVD57x(g)xREoLWPjJ28ftyWPAGgJ28Ofid7JHYHW0VXZGt1aTZHmu8ULqcNusJc2bghQbvDdovd04ERbNQbAIZIRK1bzyxcKIIlzgCQgOj4te)xREoLaIY5umsKU1Gt1anbFIRK1bzyxcKIIyNMmAZxmHbNQbAmAZJwGmSpgkhct)gpdovd04lKHI3Tes4KsAuWoW4qnOQBWPAGg3Bn4unqtWN4kzDqg2LaPO4sMbNQbAIZI4)A1ZPequoNIrI0TgCQgOjolUswhKHDjqkkIbAtq76HaTTJmOoT5RtctkdWamaa]] )

end
