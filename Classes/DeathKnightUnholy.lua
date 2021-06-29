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
                local app = state.debuff.swarming_mist.applied
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
            cooldown = 25,
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
            cooldown = 45,
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
                if not pvptalent.unholy_command.enabled then return end
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


    --[[ spec:RegisterSetting( "festermight_cycle", false, {
        name = "Festermight: Spread |T237530:0|t Wounds",
        desc = function ()
            return  "If checked, the addon will encourage you to spread Festering Wounds to multiple targets before |T136144:0|t Death and Decay.\n\n" ..
                    "Requires |cFF" .. ( state.azerite.festermight.enabled and "00FF00" or "FF0000" ) .. "Festermight|r (Azerite)\n" ..
                    "Requires |cFF" .. ( state.settings.cycle and "00FF00" or "FF0000" ) .. "Recommend Target Swaps|r in |cFFFFD100Targeting|r section."
        end,
        type = "toggle",
        width = "full"
    } ) ]]


    spec:RegisterPack( "Unholy", 20210629.1, [[defDTcqiavpsfsxcqPAtOkFcjAuifNcP0QKsbVcj0Sqv1TKsr2fHFHagMaQJPcwgQuptazAiqUMkuBtfcFdvfmouvOohQkK1jLsVtkfQmpb4EOI9jLQdIeWcrL4HakMicuxeqPSrKavFukfYibuI6KsPOwjc6LakrMjsq3ukfQANaIFQcrgQke1sbuspvqtfq6QakHTkLcLVIeiJfvL2Rk9xPAWkDyrlMcpwOjt0LH2mI(SumAaoTIvJQI61c0SP0TPODl53QA4QOJJQISCqphLPt66aTDe67ivJhvsNxkz9ibkZhjTFQ(E4c0BOmv8ceUdm3hc8rWnFK4WbckqCFd1wN4n8mJbZg8gwPjEdbwuaEBRB4z2Y(P8c0Bi7bHr8gcq1twBjabAgfaOHi(MeGnMG2uNVIWKujaBmJe4gAaowTnxxJBOmv8ceUdm3hc8rWnFK4Wbckqh4d3q2jgVaH7J5(gcyKsSUg3qjYI3qcgtfGValvtda1xGffG32YjKqWc9LB(i(9L7aZ9bNqNqGbqwniRToHTjFPas(mitnXsz(QVVeCrWeGGrYXIeGGXubW8LGbrF133VST8n(GL6RMWguz(shW7BcrFrUEIrfL(QVV2Hi6R9RgFX6bBa4R((AMQIqFPjFSZqf803JEGwHtyBYxcEyPHfL(gMr4qoXjT(EKZO6Rbgtqg6RetPVnaEqlZxZmi6l5d9LLsFjyGLycNW2KValyt14lf0dwsFdpXsIqFtJXo6GmFnFi6lPf56yyB5lnP6lbrrFzAgdY8DkMIP03N03JPiTTX5lbFKd9TqqfMwFZs6Rz2Y3tisel1x2BI(wFBcIrFzJcM68ft4e2M8fybBQgFPGJmfHt14BOcNGOVt5lf4ibS57q6BRh0xajr036vat14lAzOV67R89nlPV0)Is13NicJ5PV0FWsY8Dy(sWh5qFleuHPv4e2M8fyaKvdk91mRw(sj50aq7q0mNIrPVXVKJoFLwMV67BEEAB57u(A8mMVKtdaL57x2w(sJfzmFbgc2x6jtrF)YxfMma0kCcBt(sbKsu6BwVcaH(EKavdiMb9flf2Yx99LHQVGN(Yu4xni0xGTZrIMtKjCcBt(c0JebFKARV(sbpJ6d9nuHy1Oa89e(rMVtPVVkCQGO6R9BMO4gAhMYUa9gMp2zOcEEb6fihUa9gIvAyr5Ll3WiCueo5nuIPcOhSMgaQGK(dwsu21e2GkZ3254BSv0IDSqZbz(sLQVsmva9G10aqfK0FWsIYUMWguz(2ohFp2xQu9f4(QPflvyacz6unD2drMaR0WIsFPs1xyoYoselvKsjtGCDykZxE(cZr2rIyPIukzciAMtX8nao(E4GVuP6l50aq7q0mNI5BaC89WHByg15RBywT6YsE1lq4(c0BiwPHfLxUCdJWrr4K3qG7lXeoPHffN)BNQPdbRj2pF6i0xE(sJVgGKKczcd2vywmYhAM68La80xE(cblK8HnOqIP0oit7XFScSsdlk9LNVzuhIyhl0CqMVbWX3a5lvQ(MrDiIDSqZbz(YXxU9L2Byg15RBOetfqp(J9QxGeOlqVHyLgwuE5YnmchfHtEdbUVet4KgwuC(VDQMoeSMy)8PJWByg15RBiEos0CIx9cec6c0BiwPHfLxUCdZOoFDdjrMIWPA6mfobXByeokcN8gkrdqssbjYueovtN(dwsbtZyqFdGJVbYxE(g)3kF6Lip)yABDYqbenZPy(gGVb6ggBfTyxtydQSlqoC1lqo(c0BiwPHfLxUCdZOoFDdjrMIWPA6mfobXByeokcN8gkrdqssbjYueovtN(dwsbtZyqFdW3d3WyROf7AcBqLDbYHREbYrCb6neR0WIYlxUHzuNVUHKitr4unDMcNG4nmchfHtEdHGfk0Xe763jiFdWxA8n(Vv(0lHetfqplzxIXSLaIM5umF55lW9vtlwQqIKJffyLgwu6lvQ(g)3kF6LqIKJffq0mNI5lpF10ILkKi5yrbwPHfL(sLQVXNiwzPIAAaODYe9LNVX)TYNEjKyQayDjikGOzofZxAVHXwrl21e2Gk7cKdx9ce(WfO3qSsdlkVC5gMrD(6gs)blzNDILeH3qjYIW5uNVUHuqaWYxnHnO6lJEEY8nHOVYHLgwuYVVkGH5l9XA91IQVTEqFzNyj9fcwiJa0FWsY8DkMIP03N0x65Ot14l5d9LGlcMaemsowKaemMkakz(sWGO4ggHJIWjVH04lW9LHQovdteBfTOVuP6Retfqpynnaubj9hSKOSRjSbvMVTZX3yROf7yHMdY8LwF55RenajjfKitr4unD6pyjfmnJb9TDFdKV88fcwOqhtSRFpq(gGVX)TYNEjYQvxwsbenZPyx9Q3W8XUbiKPxGEbYHlqVHyLgwuE5YnmchfHtEdZOoeXowO5GmFdGJVhFdZOoFDdJ2K(unDgGu(0zx9ceUVa9gIvAyr5Ll3WiCueo5nmJ6qe7yHMdY8LJVhHV88vIPcOhSMgaQGK(dwsu21e2GkZ3254BGUHzuNVUHrBsFQModqkF6SREbsGUa9gIvAyr5Ll3WiCueo5nutlwQWaeY0PA6ShImbwPHfL(YZxA8vIPcOhSMgaQGK(dwsu21e2GkZxo(MrDiIDSqZbz(sLQVsmva9G10aqfK0FWsIYUMWguz(2ohFdKV06lvQ(QPflvyacz6unD2drMaR0WIsF55RMwSur0M0NQPZaKYNotGvAyrPV88vIPcOhSMgaQGK(dwsu21e2GkZ32547HByg15RBi9hSKD2jwseE1lqiOlqVHyLgwuE5YnmchfHtEdPXxdqssbdukXQl)3uaXmQ(sLQVa3xIjCsdlko)3ovthcwtSF(0rOV06lpFPXxdqssHmHb7kmlg5dntD(saE6lpFHGfs(WguiXuAhKP94pwbwPHfL(YZ3mQdrSJfAoiZ3a44BG8LkvFZOoeXowO5GmF54l3(s7nmJ681nuIPcOh)XE1lqo(c0BiwPHfLxUCdJWrr4K3qiynX(5thHcjsoXr9naFPX3db2xk6Retfqpynnaubj9hSKOSRjSbvMVTbFdKV06lpFLyQa6bRPbGkiP)GLeLDnHnOY8naFpcF55lW9LycN0WIIZ)Tt10HG1e7NpDe6lvQ(Aassky0tO5unDZHPcWZByg15RBiEos0CIx9cKJ4c0BiwPHfLxUCdJWrr4K3qiynX(5thHcjsoXr9naF5(yF55Retfqpynnaubj9hSKOSRjSbvMVT77X(YZxG7lXeoPHffN)BNQPdbRj2pF6i8gMrD(6gINJenN4vVaHpCb6neR0WIYlxUHr4OiCYBiW9vIPcOhSMgaQGK(dwsu21e2GkZxE(cCFjMWjnSO48F7unDiynX(5thH(sLQVKtdaTdrZCkMVb47X(sLQVWCKDKiwQiLsMa56WuMV88fMJSJeXsfPuYeq0mNI5Ba(E8nmJ681nephjAoXREbcF8fO3WmQZx3q6pyj7StSKi8gIvAyr5Llx9ce(OlqVHyLgwuE5YnmchfHtEdbUVet4KgwuC(VDQMoeSMy)8PJWByg15RBiEos0CIx9Q3qfovquzxGEbYHlqVHyLgwuE5YnmJ681nCkwecQPHf78jWSuqZUejor8ggHJIWjVH04B8FR8PxcWcWBB1nStdavarZCkMVT7l3b2xQu9n(Vv(0lHmHb7kmlg5dntD(sarZCkwh56jgvu6B7(YDG9LwF55ln(MrDiIDSqZbz(2ohF52xQu99evrcnB1Ba8Gwrg1Hi6lvQ(EIQip)yVbWdAfzuhIOV88LgF10ILkalaVTvpzSe0QcSsdlk9LkvFLyQa6bRPbGkKdlnSypFv6lT(sLQVNOkAsyZ3YIImQdr0xA9LkvFnEgZxE(sona0oenZPy(gGVCFWxQu9vtydQcDmXU(9ZO25oW(gGVhFdR0eVHtXIqqnnSyNpbMLcA2LiXjIx9ceUVa9gIvAyr5Ll3WmQZx3qfovqupCdLilcNtD(6gcuaOVkCQGO6l9rb4Rca9fW0aazQVithZurPVetliYVV0hR1xd0xqgk9LCGm13SK(EMdeL(sFua(sbo)yABDYqFPzi91aKK03H57HJ9LHXVKmFFOVwKXO13h6lxStdaLaemq9LMH03giMkc9vbKLVho2xgg)sYO9ggHJIWjVHa3xIjCsdlkyNyCihu2v4ubr1xE(sJV04RcNkiQc9GWaKKSlbHPoF5BaC89WX(YZ34)w5tVe55htBRtgkGOzofZ329L7a7lvQ(QWPcIQqpimajj7sqyQZx(2UVho2xE(sJVX)TYNEjalaVTv3WonaubenZPy(2UVChyFPs134)w5tVeYegSRWSyKp0m15lbenZPyDKRNyurPVT7l3b2xA9LkvFZOoeXowO5GmFBNJVC7lpFnajjfYegSRWSyKp0m15lb4PV06lpFPXxG7RcNkiQcLBbGK1J)BLp9YxQu9vHtfevHYTi(Vv(0lbenZPy(sLQVet4KgwuOWPcIA)eopC0w(YX3d(sRV06lvQ(QWPcIQqpimajj7sqyQZx(2ohFjNgaAhIM5uSREbsGUa9gIvAyr5Ll3WiCueo5ne4(smHtAyrb7eJd5GYUcNkiQ(YZxA8LgFv4ubrvOClmajj7sqyQZx(gahFpCSV88n(Vv(0lrE(X026KHciAMtX8TDF5oW(sLQVkCQGOkuUfgGKKDjim15lFB33dh7lpFPX34)w5tVeGfG32QByNgaQaIM5umFB3xUdSVuP6B8FR8Pxczcd2vywmYhAM68LaIM5uSoY1tmQO0329L7a7lT(sLQVzuhIyhl0CqMVTZXxU9LNVgGKKczcd2vywmYhAM68La80xA9LNV04lW9vHtfevHEqaiz94)w5tV8LkvFv4ubrvOheX)TYNEjGOzofZxQu9LycN0WIcfovqu7NW5HJ2Yxo(YTV06lT(sLQVkCQGOkuUfgGKKDjim15lFBNJVKtdaTdrZCk2nmJ681nuHtfevUV6fie0fO3qSsdlkVC5gMrD(6gQWPcI6HBOezr4CQZx3W2mPVFzB57xOVF5lid9vHtfevFpHpXrImFtFnajj53xqg6Rca99vai03V8n(Vv(0lHVhjOVdPVfokae6RcNkiQ(EcFIJez(M(AassYVVGm0xJxb47x(g)3kF6L4ggHJIWjVHa3xfovquf6bbGK1bzy3aKK0xE(sJVkCQGOkuUfX)TYNEjGOzofZxQu9f4(QWPcIQq5waizDqg2najj9L2REbYXxGEdXknSO8YLByeokcN8gcCFv4ubrvOClaKSoid7gGKK(YZxA8vHtfevHEqe)3kF6LaIM5umFPs1xG7RcNkiQc9GaqY6GmSBass6lT3WmQZx3qfovqu5(Qx9g2GfcN4fOxGC4c0BiwPHfLxUCdJWrr4K3qG7lXeoPHffN)BNQPdbRj2pF6i0xE(sJVgGKKcgOuIvx(VPaIzu9LkvFHG1e7NpDekKi5eh13a447Ha5lT(sLQVNOkAsyZ3YIImQdr0xE(cbl03a44BG8LkvFjNgaAhIM5umFdW3db2xE(cCFLObijPGezkcNQPt)blPa88gMrD(6gkXub0J)yV6fiCFb6neR0WIYlxUHr4OiCYBin(QPflvirYXIcSsdlk9LkvFJprSYsf10aq7Kj6lvQ(cblK8HnO4eaMW38lKjWknSO0xA9LNV04lW9LycN0WIIZ)Tt10HGfY8LkvFnEgZxE(sona0oenZPy(gGVh7lT3WmQZx3WSA1LL8QxGeOlqVHyLgwuE5YnmchfHtEdjMWjnSOWm5ZpSFc)iRNrDiI(YZxjAasskirMIWPA60FWskyAgd6B7C89GV88n(Vv(0lrE(X026KHciAMtX6ixpXOIsFB33J9LNVa3xIjCsdlko)3ovthcwi7gMrD(6gs)blzNDILeHx9cec6c0BiwPHfLxUCdJWrr4K3qjAasskirMIWPA60FWskyAgd6B7(giF55lW9LycN0WIIZ)Tt10HGfY8LkvFLObijPGezkcNQPt)blPa80xE(sona0oenZPy(gGV04RenajjfKitr4unD6pyjfmnJb9Tn4Btu6lT3WmQZx3q6pyj7StSKi8QxGC8fO3qSsdlkVC5ggHJIWjVHqWAI9ZNocfsKCIJ6BaC8L7a7lpFbUVet4KgwuC(VDQMoeSMy)8PJWByg15RBOetfqp(J9QxGCexGEdXknSO8YLByeokcN8gkrdqssbjYueovtN(dwsbtZyqFdWxcYxE(cCFjMWjnSO48F7unDiyHSByg15RBijYueovtNPWjiE1lq4dxGEdXknSO8YLByeokcN8gcCFjMWjnSO48F7unDiynX(5thH3WmQZx3qjMkGE8h7vVaHp(c0BiwPHfLxUCdJWrr4K3qjAasskirMIWPA60FWskyAgd6B7C89GV88fcwOVb4l3(YZxG7lXeoPHffN)BNQPdblK5lpFJ)BLp9sKNFmTTozOaIM5uSoY1tmQO032994Byg15RBi9hSKD2jwseE1REdJprSYszxGEbYHlqVHyLgwuE5YnmchfHtEdjMWjnSOGP9tBw1un(YZxiynX(5thHcjsoXr9TDFpCe(YZxA8n(Vv(0lrE(X026KHciAMtX8LkvFbUVAAXsfj0Sv)j7kaSltZcLcSsdlk9LNVX)TYNEjKjmyxHzXiFOzQZxciAMtX8LwFPs1xJNX8LNVKtdaTdrZCkMVb47Hd3WmQZx3qg9eAovt3Cy6vVaH7lqVHyLgwuE5YnmJ681nKrpHMt10nhMEdLilcNtD(6ggIQV67lid9njve6BE(rFhMVF5lWqW(MmF133tisel13NicJ555un(cSEK9LoGXI(YqvNQXxWtFbgcMs2nmchfHtEdJ)BLp9sKNFmTTozOaIM5umF55ln(MrDiIDSqZbz(2ohF52xE(MrDiIDSqZbz(gahFp2xE(cbRj2pF6iuirYjoQVT77Ha7lf9LgFZOoeXowO5GmFBd(Ee(sRV88LycN0WIIukzDiAMt5lvQ(MrDiIDSqZbz(2UVh7lpFHG1e7NpDekKi5eh1329LGcSV0E1lqc0fO3qSsdlkVC5ggHJIWjVHet4KgwuW0(PnRAQgF55lW9L9GwJPKclMYUrRoY1080IcSsdlk9LNV04B8FR8PxI88JPT1jdfq0mNI5lvQ(cCF10ILksOzR(t2vayxMMfkfyLgwu6lpFJ)BLp9sityWUcZIr(qZuNVeq0mNI5lT(YZxiyHcDmXU(DcY3291aKKuabRj2JpecEQZxciAMtX8LkvFnEgZxE(sona0oenZPy(gGVCF4gMrD(6gMgV5uPoF1TJPXvVaHGUa9gIvAyr5Ll3WiCueo5nKycN0WIcM2pTzvt14lpFzpO1ykPWIPSB0QJCnnpTOaR0WIsF55ln(kFvawaEBRUHDAaOD5RciAMtX8TDFpCWxQu9f4(QPflvawaEBRUHDAaOcSsdlk9LNVX)TYNEjKjmyxHzXiFOzQZxciAMtX8L2Byg15RByA8MtL68v3oMgx9cKJVa9gIvAyr5Ll3WiCueo5nKycN0WIIukzDiAMt5lpFHGfk0Xe763jiFB3xdqssbeSMyp(qi4PoFjGOzof7gMrD(6gMgV5uPoF1TJPXvVa5iUa9gIvAyr5Ll3WiCueo5nKycN0WIcM2pTzvt14lpFPX34)w5tVe55htBRtgkGOzofZ3299qG9LkvFbUVAAXsfj0Sv)j7kaSltZcLcSsdlk9LNVX)TYNEjKjmyxHzXiFOzQZxciAMtX8LwFPs1xJNX8LNVKtdaTdrZCkMVb47HJVHzuNVUHmazmOf7kaSdw0FOcO1vVaHpCb6neR0WIYlxUHr4OiCYBiXeoPHffPuY6q0mNYxE(sJVsmva9SKDjgZwcDIbNQXxQu9fMJSJeXsfPuYeq0mNI5BaC89ab5lT3WmQZx3qgGmg0IDfa2bl6pub06QxGWhFb6neR0WIYlxUHr4OiCYBi7bTgtjfNGmf0IDecEQZxcSsdlkVHzuNVUHKwKbicts9Qx9gEcX4BAK6fOxGC4c0Byg15RB45RZx3qSsdlkVC5QxGW9fO3WmQZx3qyomSlXuEdXknSO8YLREbsGUa9gMrD(6gsArgGimj1BiwPHfLxUC1lqiOlqVHyLgwuE5YnmJ681nmHMT6pzxbGDjMYByeokcN8gcCF10ILkyGMMF1BsyZ3YIcSsdlkVHNqm(MgP21XeVHb6QxGC8fO3qSsdlkVC5g(N3qgQd5nmchfHtEdv4ubrvOheaswhKHDdqssF55ln(QWPcIQqpiI)BLp9sibHPoF5lWUVe0X(YX3a7lT3qjYIW5uNVUHaBetlyQiZ30xfovquz(g)3kF6f)(khIJeL(A0Yxc6yHVafWW8LEY8nc4zy5BY8fSa82w(s)Hbz((LVe0X(YW4xsFnaHm13yROfz87RbO6lGK5R(VVMz1Y3Oe6lssIrL5R((2merFtFJ)BLp9sWvHeeM68LVYH4WEOVtXumLcFBZK(okLmFjMwq0xajZ369fIM5use6levqy57b(9fTm0xiQGWY3alowCdjMWELM4nuHtfe1(HoRvfVHzuNVUHet4Kgw8gsmTGyhTm8ggyXX3qIPfeVHhU6fihXfO3qSsdlkVC5g(N3qgQd5nmJ681nKycN0WI3qIjSxPjEdv4ubrTZDN1QI3WiCueo5nuHtfevHYTaqY6GmSBass6lpFPXxfovqufk3I4)w5tVesqyQZx(cS7lbDSVC8nW(s7nKyAbXoAz4nmWIJVHetliEdpC1lq4dxGEdXknSO8YLB4FEdzOoK3WiCueo5ne4(QWPcIQqpiaKSoid7gGKK(YZxfovqufk3cajRdYWUbijPVuP6RcNkiQcLBbGK1bzy3aKK0xE(sJV04RcNkiQcLBr8FR8Pxcjim15lFjGVkCQGOkuUfgGKKDjim15lFP132GV047bXX(srFv4ubrvOClaKSUbijPV06BBWxA8LycN0WIcfovqu7C3zTQOV06lT(2UV04ln(QWPcIQqpiI)BLp9sibHPoF5lb8vHtfevHEqyass2LGWuNV8LwFBd(sJVheh7lf9vHtfevHEqaizDdqssFP132GV04lXeoPHffkCQGO2p0zTQOV06lT3qjYIW5uNVUHaBmDmtfz(M(QWPcIkZxIPfe91OLVX38mHt14Rca9n(Vv(0lFFsFvaOVkCQGOYVVYH4irPVgT8vbG(kbHPoF57t6Rca91aKK03r99e(ehjYe(cSCY8n9LPqSAua(A(YHCqOV67BZqe9n9fW0aaH(EcNhoAlF13xMcXQrb4RcNkiQm(9nz(shTwFtMVPVMVCihe6l5d9Di9n9vHtfevFPpwRVp0x6J16B9QVSwv0x6JcW34)w5tVyIBiXe2R0eVHkCQGO2pHZdhT1nmJ681nKycN0WI3qIPfe7OLH3Wd3qIPfeVHCF1lq4JVa9gIvAyr5Ll3W)8gYq9gMrD(6gsmHtAyXBiX0cI3qnTyPIeA2Q)KDfa2LPzHsbwPHfL(YZ34xsWrfXVi(XuNV6pzxbGDjMsbmRG(2ohF5JUHsKfHZPoFDdb2iMwWurMVrqiel1xgQGN(s(qFvaOV8jWS0rB57t6lf48JPT1jd9fyiyGvFrssmQSBiXe2R0eVHKGwBpkHx9Q3qygN0YUa9cKdxGEdXknSO8YLByg15RBycJzHD9HqS0BOezr4CQZx3qG1moPLDdJWrr4K3qiynX(5thHcjsoXr9TDFpIJ9LNV047jQIMe28TSOiJ6qe9LkvFbUVAAXsfmqtZV6njS5BzrbwPHfL(sRV88fcwOqIKtCuFBNJVhF1lq4(c0BiwPHfLxUCdJWrr4K3qIjCsdlkmt(8d7X)TYNEX6zuhIOVuP67jQIMe28TSOiJ6qe9LNVNOkAsyZ3YIciAMtX8nao(AasskmS)l7KGWwcjim15lFPs1xJNX8LNVKtdaTdrZCkMVbWXxdqssHH9FzNee2sibHPoFDdZOoFDdnS)l7KGWwx9cKaDb6neR0WIYlxUHr4OiCYBiXeoPHffMjF(H94)w5tVy9mQdr0xQu99evrtcB(wwuKrDiI(YZ3tufnjS5BzrbenZPy(gahFnajjfgiKHWGt1iKGWuNV8LkvFnEgZxE(sona0oenZPy(gahFnajjfgiKHWGt1iKGWuNVUHzuNVUHgiKHWGt1C1lqiOlqVHyLgwuE5YnmchfHtEdnajjfGfG32QZuiwnkab45nmJ681n0onauwNpdkBmXsV6fihFb6neR0WIYlxUHzuNVUHzfrMctBpMw7nuISiCo15RBifOIitHP1xGjTwFJz5RcNMge6lb575RyPtA91aKKKXVVygb4Rnz6un(E4yFzy8ljt4lWcDSdfmu6lGek9n(su6RoMOVjZ30xfonni0x99niIN(oQVqmLPHff3WiCueo5nKycN0WIcZKp)WE8FR8PxSEg1Hi6lvQ(EIQOjHnFllkYOoerF557jQIMe28TSOaIM5umFdGJVho2xQu914zmF55l50aq7q0mNI5BaC89WXx9cKJ4c0BiwPHfLxUCdJWrr4K3WmQdrSJfAoiZ3254l3(sLQV04leSqHejN4O(2ohFp2xE(cbRj2pF6iuirYjoQVTZX3JiW(s7nmJ681nmHXSW(jOLHx9ce(WfO3qSsdlkVC5ggHJIWjVHet4KgwuyM85h2J)BLp9I1ZOoerFPs13tufnjS5Bzrrg1Hi6lpFprv0KWMVLffq0mNI5BaC81aKKuqoq0W(VuibHPoF5lvQ(A8mMV88LCAaODiAMtX8nao(AasskihiAy)xkKGWuNVUHzuNVUHKdenS)lV6fi8XxGEdXknSO8YLByeokcN8gMrDiIDSqZbz(YX3d(YZxA81aKKuawaEBRotHy1OaeGN(sLQVgpJ5lpFjNgaAhIM5umFdW3J9L2Byg15RBOr20FYUcNyq2vV6nSbleoXE(4fOxGC4c0BiwPHfLxUCdzy8gg)3kF6LG9G2oeZtekGOzof7gMrD(6gsph9ggHJIWjVHAAXsfSh02HyEIqbwPHfL(YZxnHnOk0Xe763pJApqh7Ba(ESV88LCAaODiAMtX8TDFp2xE(g)3kF6LG9G2oeZtekGOzofZ3a8LgFBIsFBd(gybF4yFP1xE(MrDiIDSqZbz(gahFd0vVaH7lqVHyLgwuE5YnmchfHtEdPXxG7lXeoPHffN)BNQPdbRj2pF6i0xQu91aKKuWaLsS6Y)nfqmJQV06lpFPXxdqssHmHb7kmlg5dntD(saE6lpFHGfs(WguiXuAhKP94pwbwPHfL(YZ3mQdrSJfAoiZ3a44BG8LkvFZOoeXowO5GmF54l3(s7nmJ681nuIPcOh)XE1lqc0fO3qSsdlkVC5ggHJIWjVHgGKKcgOuIvx(VPaIzu9LkvFbUVet4KgwuC(VDQMoeSMy)8PJWByg15RBiEos0CIx9cec6c0BiwPHfLxUCdLilcNtD(6g2Mj9vtydQ(gBfTt147W8voS0WIs(9LrF0iaFnYyqF13xfa6lBQgl2M0e2GQVnyHWj6RDyQVtXumLIByg15RBieS6zuNV62HP3qMcNOEbYHByeokcN8ggBfTyhl0CqMVC89Wn0omTxPjEdBWcHt8QxGC8fO3qSsdlkVC5gMrD(6gs)blzNDILeH3WiCueo5nKgFJ)BLp9sKNFmTTozOaIM5umFB33J9LNVs0aKKuqImfHt10P)GLuaE6lvQ(krdqssbjYueovtN(dwsbtZyqFB33a5lT(YZxA8LCAaODiAMtX8naFJ)BLp9siXub0Zs2LymBjGOzofZxk67Ha7lvQ(sona0oenZPy(2UVX)TYNEjYZpM2wNmuarZCkMV0EdJTIwSRjSbv2fihU6fihXfO3qSsdlkVC5gMrD(6gsImfHt10zkCcI3WiCueo5nuIgGKKcsKPiCQMo9hSKcMMXG(gahFdKV88n(Vv(0lrE(X026KHciAMtX8naFp2xQu9vIgGKKcsKPiCQMo9hSKcMMXG(gGVhUHXwrl21e2Gk7cKdx9ce(WfO3qSsdlkVC5gMrD(6gsImfHt10zkCcI3WiCueo5nm(Vv(0lrE(X026KHciAMtX8TDFp2xE(krdqssbjYueovtN(dwsbtZyqFdW3d3WyROf7AcBqLDbYHREbcF8fO3qSsdlkVC5gMrD(6gsImfHt10zkCcI3qjYIW5uNVUHafWW8Dy(IKKyuhIOTLVKJ1IqFPdyIa8LnMmFj4JCOVfcQW0YVVgGQVmapOv67jejIL6B6llIvcN3x6aqi6Rca9nLYV8fqY8TEfWun(QVVqm(MMyjf3WiCueo5nmJ6qe7YxfKitr4unD6pyj9TDo(gBfTyhl0CqMV88vIgGKKcsKPiCQMo9hSKcMMXG(gGVe0vV6nuIKjOvVa9cKdxGEdZOoFDdnNs2jHisbdVHyLgwuE5YvVaH7lqVHyLgwuE5Yn8pVHmuVHzuNVUHet4Kgw8gsmTG4nKgFr(e4CEIsXuSieutdl25tGzPGMDjsCIOV88n(Vv(0lXuSieutdl25tGzPGMDjsCIOaIPSLV0EdLilcNtD(6gEKHirSuFzNyCihu6RcNkiQmFnWPA8fKHsFPpkaFtq9ntDI(ANcz3qIjSxPjEdzNyCihu2v4ubr9QxGeOlqVHyLgwuE5Yn8pVHmuVHzuNVUHet4Kgw8gsmTG4nm(Vv(0lbd008REtcB(wwuarZCkMVb47X(YZxnTyPcgOP5x9Me28TSOaR0WIsF55ln(QPflvawaEBRUHDAaOcSsdlk9LNVX)TYNEjalaVTv3WonaubenZPy(gGVhcKV88n(Vv(0lHmHb7kmlg5dntD(sarZCkwh56jgvu6Ba(Eiq(sLQVa3xnTyPcWcWBB1nStdavGvAyrPV0EdjMWELM4n88F7unDiynX(5thHx9cec6c0BiwPHfLxUCd)ZBid1Byg15RBiXeoPHfVHetliEd10ILkypOTdX8eHcSsdlk9LNVqWc9naF52xE(QjSbvHoMyx)(zu7b6yFdW3J9LNVKtdaTdrZCkMVT77X3qIjSxPjEdp)3ovthcwi7QxGC8fO3qSsdlkVC5g(N3qgQ3WmQZx3qIjCsdlEdjMwq8gMrDiIDSqZbz(YX3d(YZxA8f4(cZr2rIyPIukzcKRdtz(sLQVWCKDKiwQiLsMykFB33dh7lT3qIjSxPjEdzA)0MvnvZvVa5iUa9gIvAyr5Ll3W)8gYq9gMrD(6gsmHtAyXBiX0cI3WmQdrSJfAoiZ3254l3(YZxA8f4(cZr2rIyPIukzcKRdtz(sLQVWCKDKiwQiLsMa56WuMV88LgFH5i7irSurkLmbenZPy(2UVh7lvQ(sona0oenZPy(2UVhcSV06lT3qIjSxPjEdtPK1HOzo1vVaHpCb6neR0WIYlxUH)5nKH6nmJ681nKycN0WI3qIPfeVH04RMwSubd008REtcB(wwuGvAyrPV88f4(EIQOjHnFllkYOoerF55B8FR8PxcgOP5x9Me28TSOaIM5umFPs1xG7RMwSubd008REtcB(wwuGvAyrPV06lpFPXxdqssbyb4TT6jJLGwvaE6lvQ(QPflvKqZw9NSRaWUmnlukWknSO0xE(EIQip)yVbWdAfzuhIOVuP6RbijPqMWGDfMfJ8HMPoFjap9LkvFZOoeXowO5GmFBNJVC7lpFLyQa6zj7smMTe6edovJV0EdjMWELM4n0m5ZpSh)3kF6fRNrDiIx9ce(4lqVHyLgwuE5Yn8pVHmuVHzuNVUHet4Kgw8gsmTG4nm(eXklvutdaTtMOV88vIPcONLSlXy2sOtm4un(YZxdqssHetfaRlbrbtZyqFdWxcYxQu91aKKuyMq4thL9g0KPFHDSaKvenXsfGN(sLQVgGKKcfaCS2odXGiuaE6lvQ(AasskiHyrbBqz38lMcF2OTeGN(sLQVgGKKclMYUrRoY1080IcWZBiXe2R0eVHMjF(H9t4hz9mQdr8QxGWhDb6neR0WIYlxUHzuNVUHpOAaXm4nuISiCo15RByB85uAo1un(2gBGGwSuFpY2Sbe9Dy(M(EcNhoARByeokcN8gkFvqCGGwS0(PnBarbejHidqAyrF55lW9vtlwQaSa82wDd70aqfyLgwu6lpFbUVWCKDKiwQiLsMa56Wu2vVa5qGVa9gIvAyr5Ll3WmQZx3WhunGyg8ggHJIWjVHYxfehiOflTFAZgquarsiYaKgw0xE(MrDiIDSqZbz(2ohF52xE(sJVa3xnTyPcWcWBB1nStdavGvAyrPVuP6B8FR8PxcWcWBB1nStdavarZCkMV881aKKuawaEBRUHDAaODdqssH8Px(s7nm2kAXUMWguzxGC4QxGC4WfO3qSsdlkVC5gMrD(6g(GQbeZG3q7uypkVHhXnmchfHtEdZOoeXU8vbXbcAXs7N2Sbe9naFZOoeXowO5GmF55Bg1Hi2XcnhK5B7C8LBF55ln(cCF10ILkalaVTv3WonaubwPHfL(sLQVX)TYNEjalaVTv3WonaubenZPy(YZxdqssbyb4TT6g2PbG2najjfYNE5lT3qjYIW5uNVUHTzsFvaie9nHOVyHMdY81CySPA8Tn2rMFFZZtBlFh1xAmavFR3xZhI(QaYY3VIOVNi03JWxgg)sYOvC1lqoW9fO3qSsdlkVC5ggHJIWjVHqWcjFydkyGNiKPWCkbwPHfL(YZxA8v(QGe(mTtIerOaIKqKbinSOVuP6R8vHH9Fz)0MnGOaIKqKbinSOV0EdZOoFDdFq1aIzWREbYHaDb6neR0WIYlxUHzuNVUH0FWs2zNyjr4nuISiCo15RBiWkscrgaK5lbJPcG5lbdIuY81aKK0x(mit91ajFi6RetfaZxji6lws2nmchfHtEdJprSYsf10aq7Kj6lpFLyQa6zj7smMTezuhIyhIM5umFdWxA8Tjk9Tn47bXX(sRV88vIPcONLSlXy2sOtm4unx9cKde0fO3qSsdlkVC5gYW4nm(Vv(0lb7bTDiMNiuarZCk2nmJ681nKEo6nmchfHtEd10ILkypOTdX8eHcSsdlk9LNVAcBqvOJj21VFg1EGo23a89yF55RMWguf6yID97Yb9TDFp2xE(g)3kF6LG9G2oeZtekGOzofZ3a8LgFBIsFBd(gybF4yFP1xE(MrDiIDSqZbz(YX3dx9cKdhFb6neR0WIYlxUHsKfHZPoFDdPGYr9L8H(sWyQaOK5lbdIeGGrYXI(oK(cKPbG6lf8e9vFFBq1xMcXQrb4RbijPVgzmOVjlpVHmmEdJ)BLp9siXubW6squarZCk2nmJ681nKEo6nmchfHtEdJprSYsf10aq7Kj6lpFJ)BLp9siXubW6squarZCkMVb4Btu6lpFZOoeXowO5GmF547HREbYHJ4c0BiwPHfLxUCdzy8gg)3kF6LqIKJffq0mNIDdZOoFDdPNJEdJWrr4K3W4teRSurnna0ozI(YZ34)w5tVesKCSOaIM5umFdW3MO0xE(MrDiIDSqZbz(YX3dx9cKd8HlqVHyLgwuE5YnuISiCo15RBifiQZx(sHdtz(ML03J0jwiK5lnhPtSqiJaHiFceRiY8fSyGNNpurPVt5BkLFjO9gMrD(6ggtRTNrD(QBhMEdTdt7vAI3qfovquzx9cKd8XxGEdXknSO8YLByg15RBymT2Eg15RUDy6n0omTxPjEdJprSYszx9cKd8rxGEdXknSO8YLByg15RBymT2Eg15RUDy6n0omTxPjEdHzCsl7QxGWDGVa9gIvAyr5Ll3WmQZx3WyAT9mQZxD7W0BODyAVst8gg)3kF6f7QxGW9HlqVHyLgwuE5YnmchfHtEdjMWjnSOiLswhIM5u(YZxA8n(Vv(0lHetfqplzxIXSLaIM5umFdW3db2xE(cCF10ILkKi5yrbwPHfL(sLQVX)TYNEjKi5yrbenZPy(gGVhcSV88vtlwQqIKJffyLgwu6lvQ(gFIyLLkQPbG2jt0xE(g)3kF6LqIPcG1LGOaIM5umFdW3db2xA9LNVa3xjMkGEwYUeJzlHoXGt1CdZOoFDdHGvpJ68v3om9gAhM2R0eVH5JDgQGNx9ceU5(c0BiwPHfLxUCdJWrr4K3WmQdrSJfAoiZ3254l3(YZxjMkGEwYUeJzlHoXGt1CdzkCI6fihUHzuNVUHqWQNrD(QBhMEdTdt7vAI3W8XUbiKPx9ceUd0fO3qSsdlkVC5ggHJIWjVHzuhIyhl0CqMVTZXxU9LNV04lW9vIPcONLSlXy2sOtm4un(YZxA8n(Vv(0lHetfqplzxIXSLaIM5umFB33db2xE(cCF10ILkKi5yrbwPHfL(sLQVX)TYNEjKi5yrbenZPy(2UVhcSV88vtlwQqIKJffyLgwu6lvQ(gFIyLLkQPbG2jt0xE(g)3kF6LqIPcG1LGOaIM5umFB33db2xA9L2Byg15RBieS6zuNV62HP3q7W0ELM4nSbleoXE(4vVaHBc6c0BiwPHfLxUCdJWrr4K3WmQdrSJfAoiZxo(E4gYu4e1lqoCdZOoFDdJP12ZOoF1TdtVH2HP9knXBydwiCIx9Q3W4)w5tVyxGEbYHlqVHyLgwuE5YnmchfHtEdjMWjnSOWm5ZpSh)3kF6fRNrDiI(sLQVNOkAsyZ3YIImQdr0xE(EIQOjHnFllkGOzofZ3a44l3hHVuP6l50aq7q0mNI5Ba(Y9rCdZOoFDdpFD(6QxGW9fO3qSsdlkVC5ggHJIWjVHX)TYNEjalaVTv3WonaubenZPy(gGV8bF55B8FR8Pxczcd2vywmYhAM68LaIM5uSoY1tmQO03a8Lp4lpF10ILkalaVTv3WonaubwPHfL(YZxA8n(Vv(0lrE(X026KHciAMtX6ixpXOIsFdWx(GV88LycN0WIcsqRThLqFPs1xG7lXeoPHffKGwBpkH(sRVuP6lW9vtlwQaSa82wDd70aqfyLgwu6lvQ(A8mMV88LCAaODiAMtX8naFd0X3WmQZx3WeA2Q)KDfa2LykV6fib6c0BiwPHfLxUCdZOoFDdzpOTdX8eH3WiCueo5nutydQcDmXU(9ZO2d0X(gGVh7lpF1e2GQqhtSRFxoOVT77X(YZ3mQdrSJfAoiZ3a44BGUHXwrl21e2Gk7cKdx9cec6c0BiwPHfLxUCdZOoFDdblaVTv3Wona0BOezr4CQZx3qGLFRK5lxStda1xYh6l4PV677X(YW4xsMV67lRvf9L(Oa8LcC(X026KH877rsbGq6dd53xqg6l9rb4lbNWG(cuywmYhAM68L4ggHJIWjVHet4KgwuW0(PnRAQgF55ln(g)3kF6Lip)yABDYqbenZPyDKRNyurPVb47X(sLQVX)TYNEjYZpM2wNmuarZCkwh56jgvu6B7(EiW(sRV88LgFJ)BLp9sityWUcZIr(qZuNVeq0mNI5Ba(2eL(sLQVgGKKczcd2vywmYhAM68La80xAV6fihFb6neR0WIYlxUHr4OiCYBiXeoPHffPuY6q0mNYxQu914zmF55l50aq7q0mNI5Ba(Y9HByg15RBiyb4TT6g2PbGE1lqoIlqVHyLgwuE5YnmchfHtEdjMWjnSOGP9tBw1un(YZxA8v(QaSa82wDd70aq7Yxfq0mNI5lvQ(cCF10ILkalaVTv3WonaubwPHfL(s7nmJ681nuMWGDfMfJ8HMPoFD1lq4dxGEdXknSO8YLByeokcN8gsmHtAyrrkLSoenZP8LkvFnEgZxE(sona0oenZPy(gGVCF4gMrD(6gktyWUcZIr(qZuNVU6fi8XxGEdXknSO8YLByeokcN8gMrDiIDSqZbz(YX3d(YZxjAasskirMIWPA60FWskyAgd6B7C8LG8LNV04lW9LycN0WIcsqRThLqFPs1xIjCsdlkibT2Euc9LNV04B8FR8PxcWcWBB1nStdavarZCkMVT77Ha7lvQ(g)3kF6LqMWGDfMfJ8HMPoFjGOzofRJC9eJkk9TDFpeyF55lW9vtlwQaSa82wDd70aqfyLgwu6lT(s7nmJ681nmp)yABDYWREbcF0fO3qSsdlkVC5gMrD(6gMNFmTToz4nmchfHtEdZOoeXowO5GmFBNJVC7lpFLObijPGezkcNQPt)blPGPzmOVT7BG8LNVa3xjMkGEwYUeJzlHoXGt1CdJTIwSRjSbv2fihU6fihc8fO3qSsdlkVC5ggHJIWjVHqWAI9ZNocfsKCIJ6Ba(EGG8LNVX)TYNEjalaVTv3WonaubenZPy(gGVhcKV88n(Vv(0lHmHb7kmlg5dntD(sarZCkwh56jgvu6Ba(Eiq3WmQZx3qgOP5x9Me28TS4vVa5WHlqVHyLgwuE5YnmchfHtEdjMWjnSOGP9tBw1un(YZxjAasskirMIWPA60FWskyAgd6Ba(YTV88LgFprvKNFS3a4bTImQdr0xQu91aKKuityWUcZIr(qZuNVeGN(YZ34)w5tVe55htBRtgkGOzofZ3299qG9L2Byg15RBiyb4TT6jJLGw9QxGCG7lqVHyLgwuE5YnmJ681neSa82w9KXsqREdJWrr4K3WmQdrSJfAoiZ3254l3(YZxjAasskirMIWPA60FWskyAgd6Ba(YTV88LgFprvKNFS3a4bTImQdr0xQu91aKKuityWUcZIr(qZuNVeGN(sLQVX)TYNEjKyQa6zj7smMTeq0mNI5Ba(2eL(s7nm2kAXUMWguzxGC4QxGCiqxGEdXknSO8YLByeokcN8gcCFprv0a4bTImQdr8gMrD(6gcZHHDjMYRE1REdjIq281fiChyUpe4JGB(OBi9ewt1WUHuquaGvG0MbsBuB91xGca9DmpFO6l5d9LY8XodvWtk9fI8jWbIsFzVj6BcQVzQO03iGSAqMWjKcNc99qB9fy(Iicvu6lLAAXsf8LsF13xk10ILk4RaR0WIsk9LMdCLwHtifof6l3T1xG5lIiurPVucblK8HnOGVu6R((sjeSqYh2Gc(kWknSOKsFP5axPv4esHtH(EeT1xG5lIiurPVuQPflvWxk9vFFPutlwQGVcSsdlkP0xA4MR0kCcDcPGOaaRaPndK2O26RVafa67yE(q1xYh6lL5JDdqitP0xiYNahik9L9MOVjO(MPIsFJaYQbzcNqkCk03a1wFbMViIqfL(sPMwSubFP0x99LsnTyPc(kWknSOKsFPjqCLwHtifof6lb1wFbMViIqfL(sjeSqYh2Gc(sPV67lLqWcjFydk4RaR0WIsk9LMdCLwHtOtifefayfiTzG0g1wF9fOaqFhZZhQ(s(qFPuHtfevgL(cr(e4arPVS3e9nb13mvu6Beqwnit4esHtH(EOT(cmFreHkk9LsnTyPc(sPV67lLAAXsf8vGvAyrjL(sZbUsRWjKcNc9L726lW8freQO0xkv4ubrvCqWxk9vFFPuHtfevHEqWxk9LMaXvAfoHu4uOVC3wFbMViIqfL(sPcNkiQcUf8LsF13xkv4ubrvOCl4lL(sd3CLwHtifof6BGARVaZxerOIsFPuHtfevXbbFP0x99Lsfovquf6bbFP0xA4MR0kCcPWPqFduB9fy(Iicvu6lLkCQGOk4wWxk9vFFPuHtfevHYTGVu6lnbIR0kCcPWPqFjO26lW8freQO0xkv4ubrvCqWxk9vFFPuHtfevHEqWxk9LMdCLwHtifof6lb1wFbMViIqfL(sPcNkiQcUf8LsF13xkv4ubrvOCl4lL(sd3CLwHtifof67XT1xG5lIiurPVuQWPcIQ4GGVu6R((sPcNkiQc9GGVu6lnCZvAfoHu4uOVh3wFbMViIqfL(sPcNkiQcUf8LsF13xkv4ubrvOCl4lL(sZbUsRWj0jKcIcaScK2mqAJARV(cuaOVJ55dvFjFOVu2GfcNiL(cr(e4arPVS3e9nb13mvu6Beqwnit4esHtH(YDB9fy(Iicvu6lLqWcjFydk4lL(QVVucblK8HnOGVcSsdlkP0xAoWvAfoHoHuquaGvG0MbsBuB91xGca9DmpFO6l5d9LY4teRSugL(cr(e4arPVS3e9nb13mvu6Beqwnit4esHtH(EOT(cmFreHkk9LsnTyPc(sPV67lLAAXsf8vGvAyrjL(sZbUsRWjKcNc9nqT1xG5lIiurPVuQPflvWxk9vFFPutlwQGVcSsdlkP0xAoWvAfoHu4uOVbQT(cmFreHkk9Ls2dAnMsk4lL(QVVuYEqRXusbFfyLgwusPV0CGR0kCcPWPqFjO26lW8freQO0xk10ILk4lL(QVVuQPflvWxbwPHfLu6lnh4kTcNqkCk0xcQT(cmFreHkk9Ls2dAnMsk4lL(QVVuYEqRXusbFfyLgwusPV0CGR0kCcPWPqFpI26lW8freQO0xk10ILk4lL(QVVuQPflvWxbwPHfLu6lnh4kTcNqkCk0x(426lW8freQO0xkzpO1ykPGVu6R((sj7bTgtjf8vGvAyrjL(MQVaBhjk0xAoWvAfoHoHuquaGvG0MbsBuB91xGca9DmpFO6l5d9LYtigFtJuP0xiYNahik9L9MOVjO(MPIsFJaYQbzcNqkCk0xcQT(cmFreHkk9LsnTyPc(sPV67lLAAXsf8vGvAyrjL(MQVaBhjk0xAoWvAfoHu4uOVh3wFbMViIqfL(goMaJVSwLMC1xGDGDF13xkem918LGwqMV)jct9H(sdWoT(sZbUsRWjKcNc99426lW8freQO0xkv4ubrvCqWxk9vFFPuHtfevHEqWxk9LgU5kTcNqkCk03JOT(cmFreHkk9nCmbgFzTkn5QVa7a7(QVVuiy6R5lbTGmF)teM6d9LgGDA9LMdCLwHtifof67r0wFbMViIqfL(sPcNkiQcUf8LsF13xkv4ubrvOCl4lL(sd3CLwHtifof6lFOT(cmFreHkk9nCmbgFzTkn5QVa7(QVVuiy6RCioS5lF)teM6d9LgcqRV0WnxPv4esHtH(YhARVaZxerOIsFPuHtfevXbbFP0x99Lsfovquf6bbFP0xAiiUsRWjKcNc9Lp0wFbMViIqfL(sPcNkiQcUf8LsF13xkv4ubrvOCl4lL(sZXCLwHtifof6lFCB9fy(Iicvu6lLAAXsf8LsF13xk10ILk4RaR0WIsk9LMdCLwHtOtifefayfiTzG0g1wF9fOaqFhZZhQ(s(qFPm(Vv(0lgL(cr(e4arPVS3e9nb13mvu6Beqwnit4esHtH(YDB9fy(Iicvu6lLAAXsf8LsF13xk10ILk4RaR0WIsk9LgU5kTcNqkCk03JOT(cmFreHkk9LsnTyPc(sPV67lLAAXsf8vGvAyrjL(sZbUsRWjKcNc9LpUT(cmFreHkk9LsnTyPc(sPV67lLAAXsf8vGvAyrjL(sZbUsRWj0jKcIcaScK2mqAJARV(cuaOVJ55dvFjFOVu2GfcNypFKsFHiFcCGO0x2BI(MG6BMkk9nciRgKjCcPWPqFp0wFbMViIqfL(sPMwSubFP0x99LsnTyPc(kWknSOKsFP5axPv4esHtH(YDB9fy(Iicvu6lLqWcjFydk4lL(QVVucblK8HnOGVcSsdlkP0xAoWvAfoHoHuquaGvG0MbsBuB91xGca9DmpFO6l5d9LsjsMGwLsFHiFcCGO0x2BI(MG6BMkk9nciRgKjCcPWPqFduB9fy(Iicvu6lLAAXsf8LsF13xk10ILk4RaR0WIsk9LMaXvAfoHu4uOVeuB9fy(Iicvu6lLAAXsf8LsF13xk10ILk4RaR0WIsk9LMdCLwHtifof6lFOT(cmFreHkk9LsnTyPc(sPV67lLAAXsf8vGvAyrjL(stG4kTcNqkCk0x(O26lW8freQO0xk10ILk4lL(QVVuQPflvWxbwPHfLu6lnh4kTcNqkCk03dbUT(cmFreHkk9LsnTyPc(sPV67lLAAXsf8vGvAyrjL(sZbUsRWjKcNc99WH26lW8freQO0xk10ILk4lL(QVVuQPflvWxbwPHfLu6lnh4kTcNqkCk03dC3wFbMViIqfL(sjeSqYh2Gc(sPV67lLqWcjFydk4RaR0WIsk9LMdCLwHtifof67bcQT(cmFreHkk9LsnTyPc(sPV67lLAAXsf8vGvAyrjL(sZbUsRWjKcNc9L7dT1xG5lIiurPVuQPflvWxk9vFFPutlwQGVcSsdlkP0xA4MR0kCcPWPqF5oqT1xG5lIiurPVuQPflvWxk9vFFPutlwQGVcSsdlkP0xA4MR0kCcDcbka0xkbzyFu0KrPVzuNV8LEY8TE1xYhSK(oLVkGH57yE(qv4e2MnpFOIsFpeyFZOoF5RDykt4eEdpHp5yXB4rpQVemMkaFbwQMgaQValkaVTLt4rpQVecwOVCZhXVVChyUp4e6eE0J6lWaiRgK1wNWJEuFBt(sbK8zqMAILY8vFFj4IGjabJKJfjabJPcG5lbdI(QVVFzB5B8bl1xnHnOY8LoG33eI(IC9eJkk9vFFTdr0x7xn(I1d2aWx991mvfH(st(yNHk4PVh9aTcNWJEuFBt(sWdlnSO03WmchYjoP13JCgvFnWycYqFLyk9TbWdAz(AMbrFjFOVSu6lbdSet4eE0J6BBYxGfSPA8Lc6blPVHNyjrOVPXyhDqMVMpe9L0ICDmST8LMu9LGOOVmnJbz(oftXu67t67XuK2248LGpYH(wiOctRVzj91mB57jejIL6l7nrFRVnbXOVSrbtD(IjCcp6r9Tn5lWc2un(sbhzkcNQX3qfobrFNYxkWrcyZ3H03wpOVasIOV1RaMQXx0YqF13x57BwsFP)fLQVpregZtFP)GLK57W8LGpYH(wiOctRWj8Oh132KVadGSAqPVMz1YxkjNgaAhIM5umk9n(LC05R0Y8vFFZZtBlFNYxJNX8LCAaOmF)Y2YxASiJ5lWqW(spzk67x(QWKbGwHt4rpQVTjFPasjk9nRxbGqFpsGQbeZG(ILcB5R((Yq1xWtFzk8Rge6lW25irZjYeoHh9O(2M8fOhjc(i1wF9LcEg1h6BOcXQrb47j8JmFNsFFv4ubr1x73mrHtOtyg15lM4eIX30ivkYHaNVoF5eMrD(IjoHy8nnsLICiamhg2LykDcZOoFXeNqm(MgPsroeG0ImarysQoHzuNVyItigFtJuPihcKqZw9NSRaWUetj)Nqm(MgP21Xe5ei(hsoaxtlwQGbAA(vVjHnFll6eEuFb2iMwWurMVPVkCQGOY8n(Vv(0l(9voehjk91OLVe0XcFbkGH5l9K5BeWZWY3K5lyb4TT8L(ddY89lFjOJ9LHXVK(AaczQVXwrlY43xdq1xajZx9FFnZQLVrj0xKKeJkZx99TziI(M(g)3kF6LGRcjim15lFLdXH9qFNIPykf(2Mj9Dukz(smTGOVasMV17lenZPKi0xiQGWY3d87lAzOVqubHLVbwCSWjmJ68ftCcX4BAKkf5qaIjCsdlYFLMihfovqu7h6SwvK))Kdd1HKFIPfe5CGFIPfe7OLHCcS4y(JFjhD(IJcNkiQIdcajRdYWUbijjpAu4ubrvCqe)3kF6LqcctD(cyhyNGoMtGP1jmJ68ftCcX4BAKkf5qaIjCsdlYFLMihfovqu7C3zTQi))jhgQdj)etliY5a)etli2rld5eyXX8h)so68fhfovqufClaKSoid7gGKK8OrHtfevb3I4)w5tVesqyQZxa7a7e0XCcmToHh1xGnMoMPImFtFv4ubrL5lX0cI(A0Y34BEMWPA8vbG(g)3kF6LVpPVka0xfovqu53x5qCKO0xJw(QaqFLGWuNV89j9vbG(Aass67O(EcFIJezcFbwoz(M(YuiwnkaFnF5qoi0x99TziI(M(cyAaGqFpHZdhTLV67ltHy1Oa8vHtfevg)(MmFPJwRVjZ30xZxoKdc9L8H(oK(M(QWPcIQV0hR13h6l9XA9TE1xwRk6l9rb4B8FR8PxmHtyg15lM4eIX30ivkYHaet4KgwK)knrokCQGO2pHZdhTf))jhgQdj)etliYHB(jMwqSJwgY5a)XVKJoFXb4kCQGOkoiaKSoid7gGKK8u4ubrvWTaqY6GmSBasssLQcNkiQcUfaswhKHDdqssE0qJcNkiQcUfX)TYNEjKGWuNVa2v4ubrvWTWaKKSlbHPoFrBBGMdIJPOcNkiQcUfasw3aKKK22anet4KgwuOWPcIAN7oRvfPL22PHgfovqufheX)TYNEjKGWuNVa2v4ubrvCqyass2LGWuNVOTnqZbXXuuHtfevXbbGK1najjPTnqdXeoPHffkCQGO2p0zTQiT06eEuFb2iMwWurMVrqiel1xgQGN(s(qFvaOV8jWS0rB57t6lf48JPT1jd9fyiyGvFrssmQmNWmQZxmXjeJVPrQuKdbiMWjnSi)vAICibT2Euc5NyAbroAAXsfj0Sv)j7kaSltZcL8IFjbhve)I4htD(Q)KDfa2LykfWSc2oh(iNqNWJEuFb24kgbvu6lseHT8vht0xfa6Bg1h67W8njMJnnSOWjmJ68fJJ5uYojerkyOt4r99idrIyP(YoX4qoO0xfovquz(AGt14lidL(sFua(MG6BM6e91ofYCcZOoFXOihcqmHtAyr(R0e5WoX4qoOSRWPcIk)etliYHgKpboNNOumflcb10WID(eywkOzxIeNiYl(Vv(0lXuSieutdl25tGzPGMDjsCIOaIPSfToHh9O(2glHtAyrMtyg15lgf5qaIjCsdlYFLMiNZ)Tt10HG1e7NpDeYpX0cICI)BLp9sWann)Q3KWMVLffq0mNIfWX800ILkyGMMF1BsyZ3YI8OrtlwQaSa82wDd70aq5f)3kF6LaSa82wDd70aqfq0mNIfWHaXl(Vv(0lHmHb7kmlg5dntD(sarZCkwh56jgvugWHarLkW10ILkalaVTv3WonauADcZOoFXOihcqmHtAyr(R0e5C(VDQMoeSqg)etliYrtlwQG9G2oeZteYdcwyaCZttydQcDmXU(9ZO2d0XbCmpYPbG2HOzofR9JDcZOoFXOihcqmHtAyr(R0e5W0(PnRAQg(jMwqKtg1Hi2XcnhKX5apAaomhzhjILksPKjqUomLrLkmhzhjILksPKjMQ9dhtRtyg15lgf5qaIjCsdlYFLMiNukzDiAMtXpX0cICYOoeXowO5GS25WnpAaomhzhjILksPKjqUomLrLkmhzhjILksPKjqUomLXJgyoYoselvKsjtarZCkw7htLk50aq7q0mNI1(HatlToHzuNVyuKdbiMWjnSi)vAICmt(8d7X)TYNEX6zuhIi)etliYHgnTyPcgOP5x9Me28TSipGFIQOjHnFllkYOoerEX)TYNEjyGMMF1BsyZ3YIciAMtXOsf4AAXsfmqtZV6njS5BzrA5rJbijPaSa82w9KXsqRkapPsvtlwQiHMT6pzxbGDzAwOK3jQI88J9gapOvKrDiIuPAasskKjmyxHzXiFOzQZxcWtQuZOoeXowO5GS25WnpjMkGEwYUeJzlHoXGt1qRtyg15lgf5qaIjCsdlYFLMihZKp)W(j8JSEg1HiYpX0cICIprSYsf10aq7KjYtIPcONLSlXy2sOtm4un8majjfsmvaSUeefmnJbdGGOs1aKKuyMq4thL9g0KPFHDSaKvenXsfGNuPAasskuaWXA7medIqb4jvQgGKKcsiwuWgu2n)IPWNnAlb4jvQgGKKclMYUrRoY1080IcWtNWJ6BB85uAo1un(2gBGGwSuFpY2Sbe9Dy(M(EcNhoAlNWmQZxmkYHapOAaXmi)djh5RcIde0IL2pTzdikGijezasdlYd4AAXsfGfG32QByNgakpGdZr2rIyPIukzcKRdtzoHzuNVyuKdbEq1aIzq(JTIwSRjSbvgNd8pKCKVkioqqlwA)0MnGOaIKqKbinSiVmQdrSJfAoiRDoCZJgGRPflvawaEBRUHDAaOuPg)3kF6LaSa82wDd70aqfq0mNIXZaKKuawaEBRUHDAaODdqssH8Px06eEuFBZK(Qaqi6BcrFXcnhK5R5Wyt14BBSJm)(MNN2w(oQV0yaQ(wVVMpe9vbKLVFfrFprOVhHVmm(LKrRWjmJ68fJICiWdQgqmdYVDkShLCoc(hsozuhIyx(QG4abTyP9tB2aIbKrDiIDSqZbz8YOoeXowO5GS25WnpAaUMwSubyb4TT6g2PbGsLA8FR8PxcWcWBB1nStdavarZCkgpdqssbyb4TT6g2PbG2najjfYNErRtyg15lgf5qGhunGygK)HKdeSqYh2Gcg4jczkmNIhnYxfKWNPDsKicfqKeImaPHfPsv(QWW(VSFAZgquarsiYaKgwKwNWJ6lWkscrgaK5lbJPcG5lbdIuY81aKK0x(mit91ajFi6RetfaZxji6lwsMtyg15lgf5qa6pyj7StSKiK)HKt8jIvwQOMgaANmrEsmva9SKDjgZwImQdrSdrZCkwa00eLTHdIJPLNetfqplzxIXSLqNyWPACcZOoFXOihcqphLFgg5e)3kF6LG9G2oeZtekGOzofJ)HKJMwSub7bTDiMNiKNMWguf6yID97NrThOJd4yEAcBqvOJj21VlhS9J5f)3kF6LG9G2oeZtekGOzoflaAAIY2qGf8HJPLxg1Hi2XcnhKX5Gt4r9Lckh1xYh6lbJPcGsMVemisacgjhl67q6lqMgaQVuWt0x99TbvFzkeRgfGVgGKK(AKXG(MS80jmJ68fJICia9Cu(zyKt8FR8PxcjMkawxcIciAMtX4Fi5eFIyLLkQPbG2jtKx8FR8PxcjMkawxcIciAMtXcOjk5LrDiIDSqZbzCo4eMrD(IrroeGEok)mmYj(Vv(0lHejhlkGOzofJ)HKt8jIvwQOMgaANmrEX)TYNEjKi5yrbenZPyb0eL8YOoeXowO5GmohCcpQVuGOoF5lfomL5BwsFpsNyHqMV0CKoXcHmceI8jqSIiZxWIbEE(qfL(oLVPu(LGwNWmQZxmkYHaX0A7zuNV62HP8xPjYrHtfevMtyg15lgf5qGyAT9mQZxD7Wu(R0e5eFIyLLYCcZOoFXOihcetRTNrD(QBhMYFLMihygN0YCcp6r9nJ68fJICiad5tGyfr(hsozuhIyhl0CqgNd8aUetfqpynnauHCyPHf75RsEAAXsfmqtZV6njS5Bzr(R0e50KWM(FIfcB7dQgqmd2wsKPiCQMotHtqSTKitr4unDMcNGyBzGMMF1BsyZ3YITnHMT6pzxbGDjMY2kXub0J)y5Fi5yasskyGsjwD5)McWZ2kXub0J)yBRetfqp(JTTS4dcBWotHtqK)HKJenajjfKitr4unD6pyjfmnJbBNGAll(GWgSZu4ee5Fi5irdqssbjYueovtN(dwsbtZyW2jO2sImfHt10zkCcIoHh9O(MrD(IrroeGH8jqSIi)djNmQdrSJfAoiJZbEaxIPcOhSMgaQqoS0WI98vjpGRPflvWann)Q3KWMVLf5VstKZFIfcBljYueovtNPWji2wsKPiCQMotHtqSTNVoF1wWcWBB1nStdaTTYegSRWSyKp0m15R2MNFmTTozOtyg15lgf5qGyAT9mQZxD7Wu(R0e5e)3kF6fZjmJ68fJICiaeS6zuNV62HP8xPjYjFSZqf8K)HKdXeoPHffPuY6q0mNIhnX)TYNEjKyQa6zj7smMTeq0mNIfWHaZd4AAXsfsKCSivQX)TYNEjKi5yrbenZPybCiW800ILkKi5yrQuJprSYsf10aq7KjYl(Vv(0lHetfaRlbrbenZPybCiW0Yd4smva9SKDjgZwcDIbNQXjmJ68fJICiaeS6zuNV62HP8xPjYjFSBaczk)mforLZb(hsozuhIyhl0Cqw7C4MNetfqplzxIXSLqNyWPACcZOoFXOihcabREg15RUDyk)vAICAWcHtSNpY)qYjJ6qe7yHMdYANd38Ob4smva9SKDjgZwcDIbNQHhnX)TYNEjKyQa6zj7smMTeq0mNI1(HaZd4AAXsfsKCSivQX)TYNEjKi5yrbenZPyTFiW800ILkKi5yrQuJprSYsf10aq7KjYl(Vv(0lHetfaRlbrbenZPyTFiW0sRtyg15lgf5qGyAT9mQZxD7Wu(R0e50GfcNi)mforLZb(hsozuhIyhl0CqgNdoHoHh9O(sbEGnF5ciKPoHzuNVyI8XUbiKPCI2K(unDgGu(0z8pKCYOoeXowO5GSa4CStyg15lMiFSBaczkf5qGOnPpvtNbiLpDg)djNmQdrSJfAoiJZrWtIPcOhSMgaQGK(dwsu21e2GkRDobYjmJ68ftKp2naHmLICia9hSKD2jwseY)qYrtlwQWaeY0PA6ShImE0iXub0dwtdavqs)bljk7AcBqLXjJ6qe7yHMdYOsvIPcOhSMgaQGK(dwsu21e2GkRDobIwQu10ILkmaHmDQMo7HiJNMwSur0M0NQPZaKYNoJNetfqpynnaubj9hSKOSRjSbvw7Co4eMrD(IjYh7gGqMsroeqIPcOh)XY)qYHgdqssbdukXQl)3uaXmQuPcCIjCsdlko)3ovthcwtSF(0riT8OXaKKuityWUcZIr(qZuNVeGN8GGfs(WguiXuAhKP94pwEzuhIyhl0CqwaCcevQzuhIyhl0CqghUP1jmJ68ftKp2naHmLICiaEos0CI8pKCGG1e7NpDekKi5ehnaAoeykkXub0dwtdavqs)bljk7AcBqL1gceT8KyQa6bRPbGkiP)GLeLDnHnOYc4i4bCIjCsdlko)3ovthcwtSF(0rivQgGKKcg9eAovt3CyQa80jmJ68ftKp2naHmLICiaEos0CI8pKCGG1e7NpDekKi5ehnaUpMNetfqpynnaubj9hSKOSRjSbvw7hZd4et4KgwuC(VDQMoeSMy)8PJqNWmQZxmr(y3aeYukYHa45irZjY)qYb4smva9G10aqfK0FWsIYUMWguz8aoXeoPHffN)BNQPdbRj2pF6iKkvYPbG2HOzoflGJPsfMJSJeXsfPuYeixhMY4bZr2rIyPIukzciAMtXc4yNWmQZxmr(y3aeYukYHa0FWs2zNyjrOtyg15lMiFSBaczkf5qa8CKO5e5Fi5aCIjCsdlko)3ovthcwtSF(0rOtOt4rpQVuGhyZ3qubpDcZOoFXe5JDgQGNCYQvxws(hsosmva9G10aqfK0FWsIYUMWguzTZj2kAXowO5GmQuLyQa6bRPbGkiP)GLeLDnHnOYANZXuPcCnTyPcdqitNQPZEiYOsfMJSJeXsfPuYeixhMY4bZr2rIyPIukzciAMtXcGZHduPsona0oenZPybW5WbNWmQZxmr(yNHk4jf5qajMkGE8hl)djhGtmHtAyrX5)2PA6qWAI9ZNoc5rJbijPqMWGDfMfJ8HMPoFjap5bblK8HnOqIP0oit7XFS8YOoeXowO5GSa4eiQuZOoeXowO5GmoCtRtyg15lMiFSZqf8KICiaEos0CI8pKCaoXeoPHffN)BNQPdbRj2pF6i0jmJ68ftKp2zOcEsroeGezkcNQPZu4ee5p2kAXUMWguzCoW)qYrIgGKKcsKPiCQMo9hSKcMMXGbWjq8I)BLp9sKNFmTTozOaIM5uSacKtyg15lMiFSZqf8KICiajYueovtNPWjiYFSv0IDnHnOY4CG)HKJenajjfKitr4unD6pyjfmnJbd4Gtyg15lMiFSZqf8KICiajYueovtNPWjiYFSv0IDnHnOY4CG)HKdeSqHoMyx)obfanX)TYNEjKyQa6zj7smMTeq0mNIXd4AAXsfsKCSivQX)TYNEjKi5yrbenZPy800ILkKi5yrQuJprSYsf10aq7KjYl(Vv(0lHetfaRlbrbenZPy06eEuFPGaGLVAcBq1xg98K5BcrFLdlnSOKFFvadZx6J16RfvFB9G(YoXs6leSqgbO)GLK57umftPVpPV0ZrNQXxYh6lbxembiyKCSibiymvauY8LGbrHtyg15lMiFSZqf8KICia9hSKD2jwseY)qYHgGZqvNQHjITIwKkvjMkGEWAAaOcs6pyjrzxtydQS25eBfTyhl0CqgT8KObijPGezkcNQPt)blPGPzmy7bIheSqHoMyx)EGci(Vv(0lrwT6YskGOzofZj0j8Oh13J8RZxoHzuNVyI4)w5tVyCoFD(I)HKdXeoPHffMjF(H94)w5tVy9mQdrKk1tufnjS5Bzrrg1HiY7evrtcB(wwuarZCkwaC4(iOsLCAaODiAMtXcG7JWj8Oh1xG5FR8PxmNWmQZxmr8FR8PxmkYHaj0Sv)j7kaSlXuY)qYj(Vv(0lbyb4TT6g2PbGkGOzofla(aV4)w5tVeYegSRWSyKp0m15lbenZPyDKRNyurza8bEAAXsfGfG32QByNgakpAI)BLp9sKNFmTTozOaIM5uSoY1tmQOma(apIjCsdlkibT2EucPsf4et4KgwuqcAT9OeslvQaxtlwQaSa82wDd70aqPs14zmEKtdaTdrZCkwab6yNWmQZxmr8FR8PxmkYHaSh02HyEIq(JTIwSRjSbvgNd8pKC0e2GQqhtSRF)mQ9aDCahZttydQcDmXU(D5GTFmVmQdrSJfAoilaobYj8O(cS8BLmF5IDAaO(s(qFbp9vFFp2xgg)sY8vFFzTQOV0hfGVuGZpM2wNmKFFpskaesFyi)(cYqFPpkaFj4eg0xGcZIr(qZuNVeoHzuNVyI4)w5tVyuKdbalaVTv3Wonau(hsoet4KgwuW0(PnRAQgE0e)3kF6Lip)yABDYqbenZPyDKRNyurzahtLA8FR8PxI88JPT1jdfq0mNI1rUEIrfLTFiW0YJM4)w5tVeYegSRWSyKp0m15lbenZPyb0eLuPAasskKjmyxHzXiFOzQZxcWtADcZOoFXeX)TYNEXOihcawaEBRUHDAaO8pKCiMWjnSOiLswhIM5uuPA8mgpYPbG2HOzoflaUp4eMrD(IjI)BLp9IrroeqMWGDfMfJ8HMPoFX)qYHycN0WIcM2pTzvt1WJg5RcWcWBB1nStdaTlFvarZCkgvQaxtlwQaSa82wDd70aqP1jmJ68fte)3kF6fJICiGmHb7kmlg5dntD(I)HKdXeoPHffPuY6q0mNIkvJNX4rona0oenZPybW9bNWmQZxmr8FR8PxmkYHa55htBRtgY)qYjJ6qe7yHMdY4CGNenajjfKitr4unD6pyjfmnJbBNdbXJgGtmHtAyrbjO12JsivQet4KgwuqcAT9OeYJM4)w5tVeGfG32QByNgaQaIM5uS2peyQuJ)BLp9sityWUcZIr(qZuNVeq0mNI1rUEIrfLTFiW8aUMwSubyb4TT6g2PbGslToHzuNVyI4)w5tVyuKdbYZpM2wNmK)yROf7AcBqLX5a)djNmQdrSJfAoiRDoCZtIgGKKcsKPiCQMo9hSKcMMXGThiEaxIPcONLSlXy2sOtm4unoHzuNVyI4)w5tVyuKdbyGMMF1BsyZ3YI8pKCGG1e7NpDekKi5ehnGdeeV4)w5tVeGfG32QByNgaQaIM5uSaoeiEX)TYNEjKjmyxHzXiFOzQZxciAMtX6ixpXOIYaoeiNWmQZxmr8FR8PxmkYHaGfG32QNmwcAv(hsoet4KgwuW0(PnRAQgEs0aKKuqImfHt10P)GLuW0mgmaU5rZjQI88J9gapOvKrDiIuPAasskKjmyxHzXiFOzQZxcWtEX)TYNEjYZpM2wNmuarZCkw7hcmToHzuNVyI4)w5tVyuKdbalaVTvpzSe0Q8hBfTyxtydQmoh4Fi5KrDiIDSqZbzTZHBEs0aKKuqImfHt10P)GLuW0mgmaU5rZjQI88J9gapOvKrDiIuPAasskKjmyxHzXiFOzQZxcWtQuJ)BLp9siXub0Zs2LymBjGOzoflGMOKwNWmQZxmr8FR8PxmkYHaWCyyxIPK)HKdWprv0a4bTImQdr0j8Oh1xcEyPHfL87lFgKP(wV6letRTLV1dntRVgiGK48qFvaPsjZx6pub47jiKbovJVt1MAstu4eE0J6Bg15lMi(Vv(0lgf5qawgHd5eN02pZOY)qYjJ6qe7yHMdYANd38aUbijPqMWGDfMfJ8HMPoFjap5f)3kF6LqMWGDfMfJ8HMPoFjGOzofR9JPs14zmEKtdaTdrZCkwanrPtOtOt4rpQVaZteRSuFPagJD0bzoHzuNVyI4teRSughg9eAovt3Cyk)djhIjCsdlkyA)0MvnvdpiynX(5thHcjsoXrB)WrWJM4)w5tVe55htBRtgkGOzofJkvGRPflvKqZw9NSRaWUmnluYl(Vv(0lHmHb7kmlg5dntD(sarZCkgTuPA8mgpYPbG2HOzoflGdhCcpQVHO6R((cYqFtsfH(MNF03H57x(cmeSVjZx999eIeXs99jIWyEEovJVaRhzFPdySOVmu1PA8f80xGHGPK5eMrD(IjIprSYszuKdby0tO5unDZHP8pKCI)BLp9sKNFmTTozOaIM5umE0KrDiIDSqZbzTZHBEzuhIyhl0CqwaCoMheSMy)8PJqHejN4OTFiWuKMmQdrSJfAoiRnCe0YJycN0WIIukzDiAMtrLAg1Hi2XcnhK1(X8GG1e7NpDekKi5ehTDckW06eMrD(IjIprSYszuKdbsJ3CQuNV62X0G)HKdXeoPHffmTFAZQMQHhWzpO1ykPWIPSB0QJCnnpTipAI)BLp9sKNFmTTozOaIM5umQubUMwSurcnB1FYUca7Y0SqjV4)w5tVeYegSRWSyKp0m15lbenZPy0YdcwOqhtSRFNGA3aKKuabRj2JpecEQZxciAMtXOs14zmEKtdaTdrZCkwaCFWjmJ68fteFIyLLYOihcKgV5uPoF1TJPb)djhIjCsdlkyA)0Mvnvdp2dAnMskSyk7gT6ixtZtlYJg5RcWcWBB1nStdaTlFvarZCkw7hoqLkW10ILkalaVTv3WonauEX)TYNEjKjmyxHzXiFOzQZxciAMtXO1jmJ68fteFIyLLYOihcKgV5uPoF1TJPb)djhIjCsdlksPK1HOzofpiyHcDmXU(DcQDdqssbeSMyp(qi4PoFjGOzofZjmJ68fteFIyLLYOihcWaKXGwSRaWoyr)HkGw8pKCiMWjnSOGP9tBw1un8Oj(Vv(0lrE(X026KHciAMtXA)qGPsf4AAXsfj0Sv)j7kaSltZcL8I)BLp9sityWUcZIr(qZuNVeq0mNIrlvQgpJXJCAaODiAMtXc4WXoHzuNVyI4teRSugf5qagGmg0IDfa2bl6pub0I)HKdXeoPHffPuY6q0mNIhnsmva9SKDjgZwcDIbNQHkvyoYoselvKsjtarZCkwaCoqq06eMrD(IjIprSYszuKdbiTidqeMKk)djh2dAnMskobzkOf7ie8uNVCcDcp6r9nCQgl6lqtydQoHzuNVyIgSq4e5iXub0J)y5Fi5aCIjCsdlko)3ovthcwtSF(0ripAmajjfmqPeRU8FtbeZOsLkeSMy)8PJqHejN4ObW5qGOLk1tufnjS5Bzrrg1HiYdcwyaCcevQKtdaTdrZCkwahcmpGlrdqssbjYueovtN(dwsb4Ptyg15lMObleorkYHaz1Qllj)djhA00ILkKi5yrbwPHfLuPgFIyLLkQPbG2jtKkviyHKpSbfNaWe(MFHmA5rdWjMWjnSO48F7unDiyHmQunEgJh50aq7q0mNIfWX06eMrD(IjAWcHtKICia9hSKD2jwseY)qYHycN0WIcZKp)W(j8JSEg1HiYtIgGKKcsKPiCQMo9hSKcMMXGTZ5aV4)w5tVe55htBRtgkGOzofRJC9eJkkB)yEaNycN0WIIZ)Tt10HGfYCcZOoFXenyHWjsroeG(dwYo7eljc5Fi5irdqssbjYueovtN(dwsbtZyW2depGtmHtAyrX5)2PA6qWczuPkrdqssbjYueovtN(dwsb4jpYPbG2HOzoflaAKObijPGezkcNQPt)blPGPzmyBOjkP1jmJ68ft0GfcNif5qajMkGE8hl)djhiynX(5thHcjsoXrdGd3bMhWjMWjnSO48F7unDiynX(5thHoHzuNVyIgSq4ePihcqImfHt10zkCcI8pKCKObijPGezkcNQPt)blPGPzmyaeepGtmHtAyrX5)2PA6qWczoHzuNVyIgSq4ePihciXub0J)y5Fi5aCIjCsdlko)3ovthcwtSF(0rOtyg15lMObleorkYHa0FWs2zNyjri)djhjAasskirMIWPA60FWskyAgd2oNd8GGfga38aoXeoPHffN)BNQPdblKXl(Vv(0lrE(X026KHciAMtX6ixpXOIY2p2j0j8Oh132iSq4e9Lc8aB(EKHZdhTLtyg15lMObleoXE(ih65O8ZWiN4)w5tVeSh02HyEIqbenZPy8pKC00ILkypOTdX8eH80e2GQqhtSRF)mQ9aDCahZJCAaODiAMtXA)yEX)TYNEjypOTdX8eHciAMtXcGMMOSneybF4yA5LrDiIDSqZbzbWjqoHzuNVyIgSq4e75JuKdbKyQa6XFS8pKCOb4et4KgwuC(VDQMoeSMy)8PJqQunajjfmqPeRU8FtbeZOslpAmajjfYegSRWSyKp0m15lb4jpiyHKpSbfsmL2bzAp(JLxg1Hi2XcnhKfaNarLAg1Hi2XcnhKXHBADcZOoFXenyHWj2ZhPihcGNJenNi)djhdqssbdukXQl)3uaXmQuPcCIjCsdlko)3ovthcwtSF(0rOt4r9Tnt6RMWgu9n2kANQX3H5RCyPHfL87lJ(Ora(AKXG(QVVka0x2unwSnPjSbvFBWcHt0x7WuFNIPykfoHzuNVyIgSq4e75JuKdbGGvpJ68v3omL)knronyHWjYptHtu5CG)HKtSv0IDSqZbzCo4eMrD(IjAWcHtSNpsroeG(dwYo7eljc5p2kAXUMWguzCoW)qYHM4)w5tVe55htBRtgkGOzofR9J5jrdqssbjYueovtN(dwsb4jvQs0aKKuqImfHt10P)GLuW0mgS9arlpAiNgaAhIM5uSaI)BLp9siXub0Zs2LymBjGOzofJIhcmvQKtdaTdrZCkw7X)TYNEjYZpM2wNmuarZCkgToHzuNVyIgSq4e75JuKdbirMIWPA6mfobr(JTIwSRjSbvgNd8pKCKObijPGezkcNQPt)blPGPzmyaCceV4)w5tVe55htBRtgkGOzoflGJPsvIgGKKcsKPiCQMo9hSKcMMXGbCWjmJ68ft0GfcNypFKICiajYueovtNPWjiYFSv0IDnHnOY4CG)HKt8FR8PxI88JPT1jdfq0mNI1(X8KObijPGezkcNQPt)blPGPzmyahCcpQVafWW8Dy(IKKyuhIOTLVKJ1IqFPdyIa8LnMmFj4JCOVfcQW0YVVgGQVmapOv67jejIL6B6llIvcN3x6aqi6Rca9nLYV8fqY8TEfWun(QVVqm(MMyjfoHzuNVyIgSq4e75JuKdbirMIWPA6mfobr(hsozuhIyx(QGezkcNQPt)blz7CITIwSJfAoiJNenajjfKitr4unD6pyjfmnJbdGGCcDcpQVaRzCslZjmJ68ftaZ4KwgNegZc76dHyP8pKCGG1e7NpDekKi5ehT9J4yE0CIQOjHnFllkYOoerQubUMwSubd008REtcB(wwuGvAyrjT8GGfkKi5ehTDoh7eMrD(IjGzCslJICiGH9FzNee2I)HKdXeoPHffMjF(H94)w5tVy9mQdrKk1tufnjS5Bzrrg1HiY7evrtcB(wwuarZCkwaCmajjfg2)LDsqylHeeM68fvQgpJXJCAaODiAMtXcGJbijPWW(VStccBjKGWuNVCcZOoFXeWmoPLrroeWaHmegCQg(hsoet4KgwuyM85h2J)BLp9I1ZOoerQuprv0KWMVLffzuhIiVtufnjS5BzrbenZPybWXaKKuyGqgcdovJqcctD(IkvJNX4rona0oenZPybWXaKKuyGqgcdovJqcctD(YjmJ68ftaZ4Kwgf5qa70aqzD(mOSXelL)HKJbijPaSa82wDMcXQrbiapDcpQVuGkImfMwFbM0A9nMLVkCAAqOVeKVNVILoP1xdqssg)(IzeGV2KPt147HJ9LHXVKmHVal0XouWqPVasO034lrPV6yI(MmFtFv400GqF133GiE67O(cXuMgwu4eMrD(IjGzCslJICiqwrKPW02JP1Y)qYHycN0WIcZKp)WE8FR8PxSEg1HisL6jQIMe28TSOiJ6qe5DIQOjHnFllkGOzoflaohoMkvJNX4rona0oenZPybW5WXoHzuNVycygN0YOihcKWywy)e0Yq(hsozuhIyhl0Cqw7C4MkvAGGfkKi5ehTDohZdcwtSF(0rOqIKtC025CebMwNWmQZxmbmJtAzuKdbihiAy)xY)qYHycN0WIcZKp)WE8FR8PxSEg1HisL6jQIMe28TSOiJ6qe5DIQOjHnFllkGOzoflaogGKKcYbIg2)Lcjim15lQunEgJh50aq7q0mNIfahdqssb5ard7)sHeeM68Ltyg15lMaMXjTmkYHagzt)j7kCIbz8pKCYOoeXowO5Gmoh4rJbijPaSa82wDMcXQrbiapPs14zmEKtdaTdrZCkwahtRtOt4rpQVafovquzoHzuNVycfovquzCazyFu0K)knrotXIqqnnSyNpbMLcA2LiXjI8pKCOj(Vv(0lbyb4TT6g2PbGkGOzofRDUdmvQX)TYNEjKjmyxHzXiFOzQZxciAMtX6ixpXOIY25oW0YJMmQdrSJfAoiRDoCtL6jQIeA2Q3a4bTImQdrKk1tuf55h7naEqRiJ6qe5rJMwSubyb4TT6jJLGwLkvjMkGEWAAaOc5Wsdl2ZxL0sL6jQIMe28TSOiJ6qePLkvJNX4rona0oenZPybW9bQu1e2GQqhtSRF)mQDUdCah7eEuFbka0xfovqu9L(Oa8vbG(cyAaGm1xKPJzQO0xIPfe53x6J16Rb6lidL(soqM6BwsFpZbIsFPpkaFPaNFmTTozOV0mK(Aass67W89WX(YW4xsMVp0xlYy067d9Ll2PbGsacgO(sZq6BdetfH(QaYY3dh7ldJFjz06eMrD(Iju4ubrLrroeqHtfe1d8pKCaoXeoPHffStmoKdk7kCQGOYJgAu4ubrvCqyass2LGWuNVcGZHJ5f)3kF6Lip)yABDYqbenZPyTZDGPsvHtfevXbHbijzxcctD(Q9dhZJM4)w5tVeGfG32QByNgaQaIM5uS25oWuPg)3kF6LqMWGDfMfJ8HMPoFjGOzofRJC9eJkkBN7atlvQzuhIyhl0Cqw7C4MNbijPqMWGDfMfJ8HMPoFjapPLhnaxHtfevb3cajRh)3kF6fvQkCQGOk4we)3kF6LaIM5umQujMWjnSOqHtfe1(jCE4OT4CGwAPsvHtfevXbHbijzxcctD(QDoKtdaTdrZCkMtyg15lMqHtfevgf5qafovqu5M)HKdWjMWjnSOGDIXHCqzxHtfevE0qJcNkiQcUfgGKKDjim15Ra4C4yEX)TYNEjYZpM2wNmuarZCkw7ChyQuv4ubrvWTWaKKSlbHPoF1(HJ5rt8FR8PxcWcWBB1nStdavarZCkw7ChyQuJ)BLp9sityWUcZIr(qZuNVeq0mNI1rUEIrfLTZDGPLk1mQdrSJfAoiRDoCZZaKKuityWUcZIr(qZuNVeGN0YJgGRWPcIQ4GaqY6X)TYNErLQcNkiQIdI4)w5tVeq0mNIrLkXeoPHffkCQGO2pHZdhTfhUPLwQuv4ubrvWTWaKKSlbHPoF1ohYPbG2HOzofZj8O(2Mj99lBlF)c99lFbzOVkCQGO67j8josK5B6Rbijj)(cYqFvaOVVcaH((LVX)TYNEj89ib9Di9TWrbGqFv4ubr13t4tCKiZ30xdqss(9fKH(A8kaF)Y34)w5tVeoHzuNVycfovquzuKdbu4ubr9a)djhGRWPcIQ4GaqY6GmSBassYJgfovqufClI)BLp9sarZCkgvQaxHtfevb3cajRdYWUbijjToHzuNVycfovquzuKdbu4ubrLB(hsoaxHtfevb3cajRdYWUbijjpAu4ubrvCqe)3kF6LaIM5umQubUcNkiQIdcajRdYWUbijjT3Weub8WBy4ycAtD(cyGjPE1REV]] )


end
