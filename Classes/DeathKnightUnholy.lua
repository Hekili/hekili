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


    spec:RegisterPack( "Unholy", 20210628, [[devPNcqiavpskvUecQYMqv(eQKrHkCkKOvHQs6vibZcvQBHQsSlI(fcYWOsQJbGLrL4zujzAiHCnaPTHQs9nurLXHkQY5auOwNuk9oPuLK5HQQ7HuTpaYbrqLfIkYdbuAIiOCrafzJiOQ8rurvnsafsNukvXkrGxcOqmtur5MsPkP2ja1pbuWqLsvzPsPQ6PsXubexvkvP2QuQs8vaf1yLsXEvP)kvdwPdlSys6Xu1KjCzOnJOptfJwfDAfRgju9APKztQBtIDl53QA4QWXrcLLd65OmDkxhOTJqFhjnEuvCEQuRhbvvZhPSFrFb4cKBJim8cyxCTla4A(2fopPlUY18TRb6TXCFG3MJW3kCWBtfk4TP9UoFT7BZr4w)H4cKBd7bHE82CA2bRTeIqoJDcQk9VcHyJcOoS5lpmincXgfpHUnQGJ2Ap1v92icdVa2fx7caUMVDHZt6IRCnF7Ak62Woq)fWUauxUnNJqG1v92iqM)2qyyyN5cmsnoNwUT315RDNeqayH56cNh356IRDbGKGKaG9mkhK12Ka(sUeobfhKzkyzSCTpxcRimcryi5OrcryyyNSCjmqmx7Z9lT7C9pyz5Ab0bnwUup)CdiMlYNd0BOix7ZvpeXC1F5KlwpOZzU2NRsygcZLJ4XodnWJCBhauktc4l5sydlu1Oi3MWdhYXpHo32x4TCvrFaYWCfyiY158b1SCvIwyUKpmxwiYLWagHjtc4l52EZMYjxG5hSe52CGLaH5gQJESbz5Q8qmxsnYNrv7oxoclxkIc5YSW3IL7umddrUpzUaLcu2EvUew7Rj3cbnyOZnkrUkH7CpGirSSCzVcMB98fi6ZLngyyZxmzsaFj32B2uo5s4dzgcNYj3gdoTWCNkxchWaWuUdzUUFWCpdIyU1BNt5KlQzyU2NR4ZnkrUu)Ill3Nic9XrUuFWsWYDy5syTVMCle0GHwMeWxYfypJYbf5QeL7C5ICCoToevIPyCLR)lXyZxHMLR95ghhA35ovUQpJLl54CASC)s7oxo0iJLlWsy5snygM7x5AWGDsPmjGVKlHtiqrUr92jcZfya0uHy0kxSmO7CTpxgA5cEKlZGF5GWCbMogbQmEMmjGVKlqagimGH2MBUe(cV9WCBmiwo2zUhW3ZYDk7Z1Gt1cTC1VZ4L3g9Wm2fi3M4XodnWJlqUagGlqUnyfQAuC50TXdhdHtCBeyyN9w14CAssQpyjqr3cOdASCbe9C9U9ASJfQmilxA0YvGHD2BvJZPjjP(GLafDlGoOXYfq0ZfO5sJwUapxl0yzsvqiZMYPZEiYKyfQAuKlnA5cJr0rIyzYqiysKpdZy5YlxymIoseltgcbtcrLykwU8tpxaaixA0YLCCoToevIPy5Yp9CbaGBt4T5RBtuU7IsCTlGD5cKBdwHQgfxoDB8WXq4e3gGNlXaoHQgLh)RNYPdbRX3pEQimxE5YrUQGKKsraB1nyumYhQe28Le8ixE5cblK8HoOuGHqpiZ6(F0sScvnkYLxUH3gIyhluzqwU8tpxxLlnA5gEBiIDSqLbz5spxxYLYBt4T5RBJad7S7)rFTlGD1fi3gScvnkUC624HJHWjUnapxIbCcvnkp(xpLthcwJVF8ur4Tj8281TbpgbQm(RDbmfDbYTbRqvJIlNUnH3MVUnKiZq4uoDMbNw4TXdhdHtCBeOkijPKezgcNYPt9blHKzHVvU8tpxxLlVC9)Rfp1sghVp0UpyOeIkXuSC5pxxDB8U9ASBb0bn2fWaCTlGb6fi3gScvnkUC62eEB(62qImdHt50zgCAH3gpCmeoXTrGQGKKssKziCkNo1hSesMf(w5YFUaCB8U9ASBb0bn2fWaCTlG57lqUnyfQAuC50Tj8281THezgcNYPZm40cVnE4yiCIBdeSqPnky3(ofLl)5YrU()1INAjfyyN9OeDb6d3siQetXYLxUapxl0yzsbsoAuIvOQrrU0OLR)FT4PwsbsoAucrLykwU8Y1cnwMuGKJgLyfQAuKlnA56FIyfLjRX506KbMlVC9)Rfp1skWWozDbikHOsmflxkVnE3En2Ta6Gg7cyaU2fWCUlqUnyfQAuC50Tj8281TH6dwIo7albcVncK5HZHnFDBaMpXkxlGoOLlJACWYnGyUIHfQAuWDU25WYL6O15Qrlx3pyUSdSe5cblKriQpyjy5ofZWqK7tMl1ySPCYL8H5syfHricdjhnsicdd7KlwUegikVnE4yiCIBdh5c8CzOzt5WKE3EnMlnA5kWWo7TQX50KKuFWsGIUfqh0y5ci656D71yhluzqwUuMlVCfOkijPKezgcNYPt9blHKzHVvUakxxLlVCHGfkTrb723DvU8NR)FT4PwYOC3fLqcrLyk21U2TjESRccz2fixadWfi3gScvnkUC624HJHWjUnH3gIyhluzqwU8tpxGEBcVnFDB86G6uoD2ziEQSRDbSlxGCBWku1O4YPBJhogcN42eEBiIDSqLbz5spx(oxE5kWWo7TQX50KKuFWsGIUfqh0y5ci656QBt4T5RBJxhuNYPZodXtLDTlGD1fi3gScvnkUC624HJHWjUnwOXYKQGqMnLtN9qKjXku1OixE5YrUcmSZERAConjj1hSeOOBb0bnwU0Zn82qe7yHkdYYLgTCfyyN9w14CAssQpyjqr3cOdASCbe9CDvUuMlnA5AHgltQccz2uoD2drMeRqvJIC5LRfASmPxhuNYPZodXtLjXku1OixE5kWWo7TQX50KKuFWsGIUfqh0y5ci65cWTj8281TH6dwIo7albcV2fWu0fi3gScvnkUC624HJHWjUnCKRkijPKbkey1f)RiHy4TCPrlxGNlXaoHQgLh)RNYPdbRX3pEQimxkZLxUCKRkijPueWwDdgfJ8HkHnFjbpYLxUqWcjFOdkfyi0dYSU)hTeRqvJIC5LB4THi2XcvgKLl)0Z1v5sJwUH3gIyhluzqwU0Z1LCP82eEB(62iWWo7(F0x7cyGEbYTbRqvJIlNUnE4yiCIBdeSgF)4PIqPajh)y5YFUCKlaUoxkKRad7S3QgNttss9blbk6waDqJLlFnxxLlL5Ylxbg2zVvnoNMKK6dwcu0Ta6Gglx(ZLVZLxUapxIbCcvnkp(xpLthcwJVF8uryU0OLRkijPKrnGkt50vgMjbpUnH3MVUn4XiqLXFTlG57lqUnyfQAuC50TXdhdHtCBGG147hpvekfi54hlx(Z1fGMlVCfyyN9w14CAssQpyjqr3cOdASCbuUanxE5c8CjgWju1O84F9uoDiyn((XtfH3MWBZx3g8yeOY4V2fWCUlqUnyfQAuC50TXdhdHtCBaEUcmSZERAConjj1hSeOOBb0bnwU8Yf45smGtOQr5X)6PC6qWA89JNkcZLgTCjhNtRdrLykwU8NlqZLgTCHXi6irSmziemjYNHzSC5LlmgrhjILjdHGjHOsmflx(ZfO3MWBZx3g8yeOY4V2fWCExGCBcVnFDBO(GLOZoWsGWBdwHQgfxoDTlGbgFbYTbRqvJIlNUnE4yiCIBdWZLyaNqvJYJ)1t50HG147hpveEBcVnFDBWJrGkJ)Ax72yWPAHg7cKlGb4cKBdwHQgfxoDBcVnFDBMI5HGwOQXofdmkduPlqIJhVnE4yiCIBdh56)xlEQLeSoFT7UQEConjevIPy5cOCDX15sJwU()1INAjfbSv3GrXiFOsyZxsiQetX6iFoqVHICbuUU46CPmxE5YrUH3gIyhluzqwUaIEUUKlnA5EGMmGkU7oNpOwgEBiI5sJwUhOjJJ33DoFqTm82qeZLxUCKRfASmjyD(A39GXcqTjXku1OixA0YvGHD2BvJZPjfdlu1ypEtKlL5sJwUhOjDcOZ7wJYWBdrmxkZLgTCvFglxE5sooNwhIkXuSC5pxxaixA0Y1cOdAsBuWU99dV1DX15YFUa92uHcEBMI5HGwOQXofdmkduPlqIJhV2fWUCbYTbRqvJIlNUnH3MVUnGmSpgQCBy63UngCQwObWTXdhdHtCBaEUgCQwOjnaKNbRdYWUkijzU8YLJCn4uTqtAUi9)Rfp1scrLykwU0OLlWZ1Gt1cnP5I8myDqg2vbjjZLYBJazE4CyZx3M2dzUFPDN7xyUFLlidZ1Gt1cTCpGpXrGSCJCvbjj5oxqgMRDI5(2jcZ9RC9)Rfp1sMlWam3Hm3ch7eH5AWPAHwUhWN4iqwUrUQGKKCNlidZv9TZC)kx))AXtTKx7cyxDbYTbRqvJIlNUnH3MVUnGmSpgQCB8WXq4e3gGNRbNQfAsZf5zW6GmSRcssMlVC5ixdovl0Kgas))AXtTKqujMILlnA5c8Cn4uTqtAaipdwhKHDvqsYCP82W0VDBm4uTqZLRDTBJdwiC8xGCbmaxGCBWku1O4YPBJhogcN42a8CjgWju1O84F9uoDiyn((XtfH5YlxoYvfKKuYafcS6I)vKqm8wU0OLleSgF)4PIqPajh)y5Yp9CbWv5szU0OL7bAsNa68U1Om82qeZLxUqWcZLF656QCPrlxYX506qujMILl)5cGRZLxUapxbQcsskjrMHWPC6uFWsibpUnH3MVUncmSZU)h91Ua2LlqUnyfQAuC50TXdhdHtCB4ixl0yzsbsoAuIvOQrrU0OLR)jIvuMSgNtRtgyU0OLleSqYh6GYJtmGVYxitIvOQrrUuMlVC5ixGNlXaoHQgLh)RNYPdblKLlnA5Q(mwU8YLCCoToevIPy5YFUanxkVnH3MVUnr5UlkX1Ua2vxGCBWku1O4YPBJhogcN42qmGtOQrPsqXFy)a(Ewp82qeZLxUcufKKusImdHt50P(GLqYSW3kxarpxaYLxU()1INAjJJ3hA3hmucrLykwh5Zb6nuKlGYfO5YlxGNlXaoHQgLh)RNYPdblKDBcVnFDBO(GLOZoWsGWRDbmfDbYTbRqvJIlNUnE4yiCIBJavbjjLKiZq4uoDQpyjKml8TYfq56QC5LlWZLyaNqvJYJ)1t50HGfYYLgTCfOkijPKezgcNYPt9blHe8ixE5sooNwhIkXuSC5pxoYvGQGKKssKziCkNo1hSesMf(w5YxZ1XlYLYBt4T5RBd1hSeD2bwceETlGb6fi3gScvnkUC624HJHWjUnqWA89JNkcLcKC8JLl)0Z1fxNlVCbEUed4eQAuE8VEkNoeSgF)4PIWBt4T5RBJad7S7)rFTlG57lqUnyfQAuC50TXdhdHtCBeOkijPKezgcNYPt9blHKzHVvU8NlfLlVCbEUed4eQAuE8VEkNoeSq2Tj8281THezgcNYPZm40cV2fWCUlqUnyfQAuC50TXdhdHtCBaEUed4eQAuE8VEkNoeSgF)4PIWBt4T5RBJad7S7)rFTlG58Ua52GvOQrXLt3gpCmeoXTrGQGKKssKziCkNo1hSesMf(w5ci65cqU8YfcwyU8NRl5YlxGNlXaoHQgLh)RNYPdblKLlVC9)Rfp1sghVp0UpyOeIkXuSoYNd0BOixaLlqVnH3MVUnuFWs0zhyjq41U2TX)eXkkJDbYfWaCbYTbRqvJIlNUnE4yiCIBdXaoHQgLmRFOJQMYjxE5cbRX3pEQiukqYXpwUakxa47C5Llh56)xlEQLmoEFODFWqjevIPy5sJwUapxl0yzYaQ4U)KD7e7IqPqHeRqvJIC5LR)FT4PwsraB1nyumYhQe28LeIkXuSCPmxA0Yv9zSC5Ll54CADiQetXYL)CbaGBt4T5RBdJAavMYPRmm7Axa7Yfi3gScvnkUC62eEB(62WOgqLPC6kdZUncK5HZHnFDBAqlx7ZfKH5gKgcZnoEFUdl3VYfyjSCdwU2N7bejILL7teH(44ykNCB)TVCPEoAmxgA2uo5cEKlWsyCXUnE4yiCIBJ)FT4PwY449H29bdLqujMILlVC5i3WBdrSJfQmilxarpxxYLxUH3gIyhluzqwU8tpxGMlVCHG147hpvekfi54hlxaLlaUoxkKlh5gEBiIDSqLbz5YxZLVZLYC5LlXaoHQgLHqW6qujMkxA0Yn82qe7yHkdYYfq5c0C5LleSgF)4PIqPajh)y5cOCPixNlLx7cyxDbYTbRqvJIlNUnE4yiCIBdXaoHQgLmRFOJQMYjxE5c8CzpOwDkHuJHOR6UJ8juo0OeRqvJIC5Llh56)xlEQLmoEFODFWqjevIPy5sJwUapxl0yzYaQ4U)KD7e7IqPqHeRqvJIC5LR)FT4PwsraB1nyumYhQe28LeIkXuSCPmxE5cbluAJc2TVtr5cOCvbjjLqWA8D)dHGh28LeIkXuSCPrlx1NXYLxUKJZP1HOsmflx(Z1faUnH3MVUnH6RmvyZxD9OOETlGPOlqUnyfQAuC50TXdhdHtCBigWju1OKz9dDu1uo5Ylx2dQvNsi1yi6QU7iFcLdnkXku1OixE5YrUI3KG15RD3v1JZP1fVjHOsmflxaLlaaKlnA5c8CTqJLjbRZx7URQhNttIvOQrrU8Y1)Vw8ulPiGT6gmkg5dvcB(scrLykwUuEBcVnFDBc1xzQWMV66rr9Axad0lqUnyfQAuC50TXdhdHtCBigWju1OmecwhIkXu5YlxiyHsBuWU9DkkxaLRkijPecwJV7Fie8WMVKqujMIDBcVnFDBc1xzQWMV66rr9AxaZ3xGCBWku1O4YPBJhogcN42qmGtOQrjZ6h6OQPCYLxUCKR)FT4PwY449H29bdLqujMILlGYfaxNlnA5c8CTqJLjdOI7(t2TtSlcLcfsScvnkYLxU()1INAjfbSv3GrXiFOsyZxsiQetXYLYCPrlx1NXYLxUKJZP1HOsmflx(ZfaGEBcVnFDByNHVLg72j2blQp0oDFTlG5CxGCBWku1O4YPBJhogcN42qmGtOQrzieSoevIPYLxUCKRad7ShLOlqF4wAJV1uo5sJwUWyeDKiwMmecMeIkXuSC5NEUaqr5s5Tj8281THDg(wASBNyhSO(q7091U2T5aI(xrnSlqUagGlqUnH3MVUnhVnFDBWku1O4YPRDbSlxGCBcVnFDBGXWWUadXTbRqvJIlNU2fWU6cKBdwHQgfxoDBcVnFDBcOI7(t2TtSlWqCB8WXq4e3gGNRfASmjdur5RUtaDE3AuIvOQrXT5aI(xrnSUnk4TXvx7cyk6cKBdwHQgfxoDB(JBddTH824HJHWjUngCQwOjnaKNbRdYWUkijzU8YLJCn4uTqtAai9)Rfp1skaHHnFLlHxUueqZLEUUoxkVncK5HZHnFDBaMigAWWqwUrUgCQwOXY1)Vw8ulUZvmehbkYv1DUueqL5cKZHLl1GLR)8zyLBWYfSoFT7CP(WwSC)kxkcO5Yq)xICvbHmlxVBVgzCNRkOL7zWY1(pxLOCNRxaZfjjrVXY1(CDgIyUrU()1INAj5JuacdB(kxXqCypm3PyggczUThYChJlwUedniM7zWYT(CHOsmLaH5crdew5ca35IAgMlenqyLRRLavEBigWEfk4TXGt1cToaDM7YFBcVnFDBigWju14THyObXoQz4TX1sGEBigAq82aW1UagOxGCBWku1O4YPBZFCByOnK3MWBZx3gIbCcvnEBigWEfk4TXGt1cTUlDM7YFB8WXq4e3gdovl0KMlYZG1bzyxfKKmxE5YrUgCQwOjnxK()1INAjfGWWMVYLWlxkcO5spxxNlL3gIHge7OMH3gxlb6THyObXBdax7cy((cKBdwHQgfxoDB(JBddTH824HJHWjUnapxdovl0KgaYZG1bzyxfKKmxE5AWPAHM0CrEgSoid7QGKK5sJwUgCQwOjnxKNbRdYWUkijzU8YLJC5ixdovl0KMls))AXtTKcqyyZx5sOCn4uTqtAUivbjj7cqyyZx5szU81C5ixaKanxkKRbNQfAsZf5zW6QGKK5szU81C5ixIbCcvnkn4uTqR7sN5U85szUuMlGYLJC5ixdovl0Kgas))AXtTKcqyyZx5sOCn4uTqtAaivbjj7cqyyZx5szU81C5ixaKanxkKRbNQfAsda5zW6QGKK5szU81C5ixIbCcvnkn4uTqRdqN5U85szUuEBeiZdNdB(62amXSrjmKLBKRbNQfASCjgAqmxv356FLJaoLtU2jMR)FT4Pw5(K5ANyUgCQwOXDUIH4iqrUQUZ1oXCfGWWMVY9jZ1oXCvbjjZDSCpGpXrGmzUaJgSCJCzgelh7mxLxmKdcZ1(CDgIyUrUNJZjcZ9aopCm35AFUmdILJDMRbNQfAmUZny5sf16CdwUrUkVyiheMl5dZDiZnY1Gt1cTCPoADUpmxQJwNB9wUm3LpxQJDMR)FT4Pwm5THya7vOG3gdovl06hW5HJ5(2eEB(62qmGtOQXBdXqdIDuZWBda3gIHgeVnUCTlG5CxGCBWku1O4YPBZFCByODBcVnFDBigWju14THyObXBJfASmzavC3FYUDIDrOuOqIvOQrrU8Y1)LaCmP)lIVpS5R(t2TtSlWqiHr1kxarpxGX3gbY8W5WMVUnatednyyilxpieILLldnWJCjFyU2jMlfdmkBm35(K5s4oEFODFWWCbwcR9NlssIEJDBigWEfk4THeuR7Eb8Ax72ad)eA2fixadWfi3gScvnkUC62eEB(62eqFuy3Eiel72iqMhoh281TP9h(j0SBJhogcN42abRX3pEQiukqYXpwUakx(gO5YlxoY9anPtaDE3AugEBiI5sJwUapxl0yzsgOIYxDNa68U1OeRqvJICPmxE5cblukqYXpwUaIEUa9Axa7Yfi3gScvnkUC624HJHWjUned4eQAuQeu8h29)Rfp1I1dVneXCPrl3d0Kob05DRrz4THiMlVCpqt6eqN3TgLqujMILl)0ZvfKKuQQ)x0jbHULcqyyZx5sJwUQpJLlVCjhNtRdrLykwU8tpxvqssPQ(FrNee6wkaHHnFDBcVnFDBu1)l6KGq3x7cyxDbYTbRqvJIlNUnE4yiCIBdXaoHQgLkbf)HD))AXtTy9WBdrmxA0Y9anPtaDE3AugEBiI5Yl3d0Kob05DRrjevIPy5Yp9CvbjjLQiKHWwt5ifGWWMVYLgTCvFglxE5sooNwhIkXuSC5NEUQGKKsveYqyRPCKcqyyZx3MWBZx3gveYqyRPCU2fWu0fi3gScvnkUC624HJHWjUnQGKKsW681U7mdILJDkbpUnH3MVUn6X50yDkoOWrbl7Axad0lqUnyfQAuC50Tj8281TjkpYmyO7(qRVncK5HZHnFDBiCLhzgm05cSHwNRpQCn444GWCPOCpEdlBcDUQGKKmUZfd)zU6Gzt5Klaanxg6)sWK52EBJEi8JICpdOix)lqrU2OG5gSCJCn444GWCTp3wiEK7y5cXqeQAuEB8WXq4e3gIbCcvnkvck(d7()1INAX6H3gIyU0OL7bAsNa68U1Om82qeZLxUhOjDcOZ7wJsiQetXYLF65caqZLgTCvFglxE5sooNwhIkXuSC5NEUaa0RDbmFFbYTbRqvJIlNUnE4yiCIBt4THi2XcvgKLlGONRl5sJwUCKleSqPajh)y5ci65c0C5LleSgF)4PIqPajh)y5ci65Y3UoxkVnH3MVUnb0hf2pa1m8AxaZ5Ua52GvOQrXLt3gpCmeoXTHyaNqvJsLGI)WU)FT4PwSE4THiMlnA5EGM0jGoVBnkdVneXC5L7bAsNa68U1OeIkXuSC5NEUQGKKsYbIQ6)fsbimS5RCPrlx1NXYLxUKJZP1HOsmflx(PNRkijPKCGOQ(FHuacdB(62eEB(62qoquv)V4AxaZ5DbYTbRqvJIlNUnE4yiCIBt4THi2XcvgKLl9CbixE5YrUQGKKsW681U7mdILJDkbpYLgTCvFglxE5sooNwhIkXuSC5pxGMlL3MWBZx3g1WP)KDdo(wSRDTBJdwiC894XlqUagGlqUnyfQAuC50THH(BJ)FT4Pws2dQ7qmoqOeIkXuSBt4T5RBd1ySBJhogcN42yHgltYEqDhIXbcLyfQAuKlVCTa6GM0gfSBF)WBDxb0C5pxGMlVCjhNtRdrLykwUakxGMlVC9)Rfp1sYEqDhIXbcLqujMILl)5YrUoErU81CDTKZb0CPmxE5gEBiIDSqLbz5Yp9CD11Ua2LlqUnyfQAuC50TXdhdHtCB4ixGNlXaoHQgLh)RNYPdbRX3pEQimxA0YvfKKuYafcS6I)vKqm8wUuMlVC5ixvqssPiGT6gmkg5dvcB(scEKlVCHGfs(qhukWqOhKzD)pAjwHQgf5Yl3WBdrSJfQmilx(PNRRYLgTCdVneXowOYGSCPNRl5s5Tj8281TrGHD29)OV2fWU6cKBdwHQgfxoDB8WXq4e3gvqssjduiWQl(xrcXWB5sJwUapxIbCcvnkp(xpLthcwJVF8ur4Tj8281TbpgbQm(RDbmfDbYTbRqvJIlNUncK5HZHnFDBApK5Ab0bTC9U96PCYDy5kgwOQrb35YOoM)mx1W3kx7Z1oXCzt5Or(Ifqh0Y1bleo(C1dZYDkMHHqEBcVnFDBGGvp828vxpm72Wm44TlGb424HJHWjUnE3En2XcvgKLl9Cb42OhM1RqbVnoyHWXFTlGb6fi3gScvnkUC62eEB(62q9blrNDGLaH3gpCmeoXTHJC9)Rfp1sghVp0UpyOeIkXuSCbuUanxE5kqvqssjjYmeoLtN6dwcj4rU0OLRavbjjLKiZq4uoDQpyjKml8TYfq56QCPmxE5YrUKJZP1HOsmflx(Z1)Vw8ulPad7ShLOlqF4wcrLykwUuixaCDU0OLl54CADiQetXYfq56)xlEQLmoEFODFWqjevIPy5s5TX72RXUfqh0yxadW1UaMVVa52GvOQrXLt3MWBZx3gsKziCkNoZGtl824HJHWjUncufKKusImdHt50P(GLqYSW3kx(PNRRYLxU()1INAjJJ3hA3hmucrLykwU8NlqZLgTCfOkijPKezgcNYPt9blHKzHVvU8Nla3gVBVg7waDqJDbmax7cyo3fi3gScvnkUC62eEB(62qImdHt50zgCAH3gpCmeoXTX)Vw8ulzC8(q7(GHsiQetXYfq5c0C5LRavbjjLKiZq4uoDQpyjKml8TYL)Cb424D71y3cOdASlGb4AxaZ5DbYTbRqvJIlNUnH3MVUnKiZq4uoDMbNw4TrGmpCoS5RBdqohwUdlxKKe92qe1UZLC0AeMl1ZXFMlBuy5syTVMCle0GHM7CvbTCzNpOwK7bejILLBKlZJvaNpxQNieZ1oXCdH4RCpdwU1BNt5KR95cr)ROGLqEB8WXq4e3MWBdrSlEtsImdHt50P(GLixarpxVBVg7yHkdYYLxUcufKKusImdHt50P(GLqYSW3kx(ZLIU21UncKma12fixadWfi3MWBZx3gLPeDsiIe(XBdwHQgfxoDTlGD5cKBdwHQgfxoDB(JBddTBt4T5RBdXaoHQgVnedniEB4ixKIbohhOqofZdbTqvJDkgyugOsxGehpMlVC9)Rfp1sofZdbTqvJDkgyugOsxGehpkHyiCNlL3gbY8W5WMVUnTpisellx2b6hYbf5AWPAHglxvCkNCbzOixQJDMBaAVsyJpx9ui72qmG9kuWBd7a9d5GIUbNQfAx7cyxDbYTbRqvJIlNUn)XTHH2Tj8281THyaNqvJ3gIHgeVn()1INAjzGkkF1DcOZ7wJsiQetXYL)CbAU8Y1cnwMKbQO8v3jGoVBnkXku1OixE5YrUwOXYKG15RD3v1JZPjXku1OixE56)xlEQLeSoFT7UQEConjevIPy5YFUa4QC5LR)FT4PwsraB1nyumYhQe28LeIkXuSoYNd0BOix(ZfaxLlnA5c8CTqJLjbRZx7URQhNttIvOQrrUuEBigWEfk4T54F9uoDiyn((XtfHx7cyk6cKBdwHQgfxoDB(JBddTBt4T5RBdXaoHQgVnedniEBSqJLjzpOUdX4aHsScvnkYLxUqWcZL)CDjxE5Ab0bnPnky3((H36UcO5YFUanxE5sooNwhIkXuSCbuUa92qmG9kuWBZX)6PC6qWczx7cyGEbYTbRqvJIlNUn)XTHH2Tj8281THyaNqvJ3gIHgeVnH3gIyhluzqwU0ZfGC5Llh5c8CHXi6irSmziemjYNHzSCPrlxymIoseltgcbtovUakxaaAUuEBigWEfk4THz9dDu1uox7cy((cKBdwHQgfxoDB(JBddTBt4T5RBdXaoHQgVnedniEBcVneXowOYGSCbe9CDjxE5YrUapxymIoseltgcbtI8zyglxA0YfgJOJeXYKHqWKiFgMXYLxUCKlmgrhjILjdHGjHOsmflxaLlqZLgTCjhNtRdrLykwUakxaCDUuMlL3gIbSxHcEBcHG1HOsm11UaMZDbYTbRqvJIlNUn)XTHH2Tj8281THyaNqvJ3gIHgeVnCKRfASmjdur5RUtaDE3AuIvOQrrU8Yf45EGM0jGoVBnkdVneXC5LR)FT4PwsgOIYxDNa68U1OeIkXuSCPrlxGNRfASmjdur5RUtaDE3AuIvOQrrUuMlVC5ixvqssjyD(A39GXcqTjbpYLgTCTqJLjdOI7(t2TtSlcLcfsScvnkYLxUhOjJJ33DoFqTm82qeZLgTCvbjjLIa2QBWOyKpujS5lj4rU0OLB4THi2XcvgKLlGONRl5Ylxbg2zpkrxG(WT0gFRPCYLYBdXa2RqbVnkbf)HD))AXtTy9WBdr8AxaZ5DbYTbRqvJIlNUn)XTHH2Tj8281THyaNqvJ3gIHgeVn(NiwrzYACoTozG5Ylxbg2zpkrxG(WT0gFRPCYLxUQGKKsbg2jRlarjZcFRC5pxkkxA0YvfKKuQeq4tffDhuHzFHDSoJYJkyzsWJCPrlxvqssPDchTUZqSfcLGh5sJwUQGKKssiwe(hu0v(IzWNnMBj4rU0OLRkijPuJHOR6UJ8juo0Oe842qmG9kuWBJsqXFy)a(Ewp82qeV2fWaJVa52GvOQrXLt3MWBZx3Mh0uHy062iqMhoh281TP96yklMAkNCBVmqqnwwUTpD4aI5oSCJCpGZdhZ9TXdhdHtCBeVjjoqqnww)qhoGOeIKqKDgQAmxE5c8CTqJLjbRZx7URQhNttIvOQrrU8Yf45cJr0rIyzYqiysKpdZyx7cyaC9fi3gScvnkUC62eEB(628GMkeJw3gpCmeoXTr8MK4ab1yz9dD4aIsiscr2zOQXC5LB4THi2XcvgKLlGONRl5YlxoYf45AHgltcwNV2DxvpoNMeRqvJICPrlx))AXtTKG15RD3v1JZPjHOsmflxE5QcsskbRZx7URQhNtRRcsskfp1kxkVnE3En2Ta6Gg7cyaU2fWaaWfi3gScvnkUC62eEB(628GMkeJw3g9uy3lUn89TXdhdHtCBcVneXU4njXbcQXY6h6WbeZL)CdVneXowOYGSC5LB4THi2XcvgKLlGONRl5YlxoYf45AHgltcwNV2DxvpoNMeRqvJICPrlx))AXtTKG15RD3v1JZPjHOsmflxE5QcsskbRZx7URQhNtRRcsskfp1kxkVncK5HZHnFDBApK5ANieZnGyUyHkdYYvzySPCYT9s7J7CJJdT7ChlxoubTCRpxLhI5ANrL7xEm3deMlFNld9FjyukV2fWa4Yfi3gScvnkUC624HJHWjUnqWcjFOdkzGhiKzWykjwHQgf5YlxoYv8MKe(mRtIerOeIKqKDgQAmxA0Yv8Muv)VOFOdhqucrsiYodvnMlL3MWBZx3Mh0uHy06AxadGRUa52GvOQrXLt3MWBZx3gQpyj6SdSei82iqMhoh281TP9JKqKDISCjmmStwUegiYflxvqsYCP4GmlxvK8HyUcmStwUcqmxSeSBJhogcN424FIyfLjRX506KbMlVCfyyN9OeDb6d3YWBdrSdrLykwU8Nlh564f5YxZfajqZLYC5LRad7ShLOlqF4wAJV1uox7cyaOOlqUnyfQAuC50THH(BJ)FT4Pws2dQ7qmoqOeIkXuSBt4T5RBd1ySBJhogcN42yHgltYEqDhIXbcLyfQAuKlVCTa6GM0gfSBF)WBDxb0C5pxGMlVCTa6GM0gfSBFxmyUakxGMlVC9)Rfp1sYEqDhIXbcLqujMILl)5YrUoErU81CDTKZb0CPmxE5gEBiIDSqLbz5spxaU2fWaa0lqUnyfQAuC50TrGmpCoS5RBdWCmwUKpmxcdd7KlwUegisicdjhnM7qMlGhNtlxcFbMR956GwUmdILJDMRkijzUQHVvUbloUnm0FB8)Rfp1skWWozDbikHOsmf72eEB(62qng724HJHWjUn(NiwrzYACoTozG5Ylx))AXtTKcmStwxaIsiQetXYL)CD8IC5LB4THi2XcvgKLl9Cb4AxadaFFbYTbRqvJIlNUnm0FB8)Rfp1skqYrJsiQetXUnH3MVUnuJXUnE4yiCIBJ)jIvuMSgNtRtgyU8Y1)Vw8ulPajhnkHOsmflx(Z1XlYLxUH3gIyhluzqwU0ZfGRDbmaCUlqUnyfQAuC50TrGmpCoS5RBdHZBZx5YzdZy5gLixGHdSqilxoagoWcHmc1GumqS8ilxWIbEC8qdf5ovUHq8LKYBt4T5RBJp06E4T5RUEy2TrpmRxHcEBm4uTqJDTlGbGZ7cKBdwHQgfxoDBcVnFDB8Hw3dVnF11dZUn6Hz9kuWBJ)jIvug7AxadaW4lqUnyfQAuC50Tj8281TXhADp828vxpm72OhM1RqbVnWWpHMDTlGDX1xGCBWku1O4YPBt4T5RBJp06E4T5RUEy2TrpmRxHcEB8)Rfp1IDTlGDbGlqUnyfQAuC50TXdhdHtCBigWju1OmecwhIkXu5YlxoY1)Vw8ulPad7ShLOlqF4wcrLykwU8NlaUoxE5c8CTqJLjfi5OrjwHQgf5sJwU()1INAjfi5OrjevIPy5YFUa46C5LRfASmPajhnkXku1OixA0Y1)eXkktwJZP1jdmxE56)xlEQLuGHDY6cqucrLykwU8NlaUoxkZLxUapxbg2zpkrxG(WT0gFRPCUnH3MVUnqWQhEB(QRhMDB0dZ6vOG3M4XodnWJRDbSlUCbYTbRqvJIlNUnE4yiCIBt4THi2XcvgKLlGONRl5Ylxbg2zpkrxG(WT0gFRPCUnmdoE7cyaUnH3MVUnqWQhEB(QRhMDB0dZ6vOG3M4XUkiKzx7cyxC1fi3gScvnkUC624HJHWjUnH3gIyhluzqwUaIEUUKlVC5ixGNRad7ShLOlqF4wAJV1uo5YlxoY1)Vw8ulPad7ShLOlqF4wcrLykwUakxaCDU8Yf45AHgltkqYrJsScvnkYLgTC9)Rfp1skqYrJsiQetXYfq5cGRZLxUwOXYKcKC0OeRqvJICPrlx)teROmznoNwNmWC5LR)FT4Pwsbg2jRlarjevIPy5cOCbW15szUuEBcVnFDBGGvp828vxpm72OhM1RqbVnoyHWX3JhV2fWUqrxGCBWku1O4YPBJhogcN42eEBiIDSqLbz5spxaUnmdoE7cyaUnH3MVUn(qR7H3MV66Hz3g9WSEfk4TXbleo(RDTBJ)FT4PwSlqUagGlqUnyfQAuC50TXdhdHtCBigWju1OujO4pS7)xlEQfRhEBiI5sJwUhOjDcOZ7wJYWBdrmxE5EGM0jGoVBnkHOsmflx(PNRl8DU0OLl54CADiQetXYL)CDHVVnH3MVUnhVnFDTlGD5cKBdwHQgfxoDB8WXq4e3g))AXtTKG15RD3v1JZPjHOsmflx(ZLZLlVC9)Rfp1skcyRUbJIr(qLWMVKqujMI1r(CGEdf5YFUCUC5LRfASmjyD(A3Dv94CAsScvnkYLxUCKR)FT4PwY449H29bdLqujMI1r(CGEdf5YFUCUC5LlXaoHQgLKGAD3lG5sJwUapxIbCcvnkjb16UxaZLYCPrlxGNRfASmjyD(A3Dv94CAsScvnkYLgTCvFglxE5sooNwhIkXuSC5pxxb0Bt4T5RBtavC3FYUDIDbgIRDbSRUa52GvOQrXLt3MWBZx3g2dQ7qmoq4TXdhdHtCBSa6GM0gfSBF)WBDxb0C5pxGMlVCTa6GM0gfSBFxmyUakxGMlVCdVneXowOYGSC5NEUU624D71y3cOdASlGb4AxatrxGCBWku1O4YPBt4T5RBdyD(A3Dv94CA3gbY8W5WMVUnaJ(AblxoPhNtlxYhMl4rU2NlqZLH(VeSCTpxM7YNl1XoZLWD8(q7(GHCNlWGDIqQdd5oxqgMl1XoZLWcyRCbcmkg5dvcB(sEB8WXq4e3gIbCcvnkzw)qhvnLtU8YLJC9)Rfp1sghVp0UpyOeIkXuSoYNd0BOix(ZfO5sJwU()1INAjJJ3hA3hmucrLykwh5Zb6nuKlGYfaxNlL5YlxoY1)Vw8ulPiGT6gmkg5dvcB(scrLykwU8NRJxKlnA5QcsskfbSv3GrXiFOsyZxsWJCP8Axad0lqUnyfQAuC50TXdhdHtCBigWju1OmecwhIkXu5sJwUQpJLlVCjhNtRdrLykwU8NRlaCBcVnFDBaRZx7URQhNt7AxaZ3xGCBWku1O4YPBJhogcN42qmGtOQrjZ6h6OQPCYLxUCKR4njyD(A3Dv94CADXBsiQetXYLgTCbEUwOXYKG15RD3v1JZPjXku1OixkVnH3MVUnIa2QBWOyKpujS5RRDbmN7cKBdwHQgfxoDB8WXq4e3gIbCcvnkdHG1HOsmvU0OLR6Zy5YlxYX506qujMILl)56ca3MWBZx3graB1nyumYhQe2811UaMZ7cKBdwHQgfxoDB8WXq4e3MWBdrSJfQmilx65cqU8YvGQGKKssKziCkNo1hSesMf(w5ci65sr5YlxoYf45smGtOQrjjOw39cyU0OLlXaoHQgLKGAD3lG5YlxoY1)Vw8uljyD(A3Dv94CAsiQetXYfq5cGRZLgTC9)Rfp1skcyRUbJIr(qLWMVKqujMI1r(CGEdf5cOCbW15YlxGNRfASmjyD(A3Dv94CAsScvnkYLYCP82eEB(62ehVp0Upy41Uagy8fi3gScvnkUC62eEB(62ehVp0Upy4TXdhdHtCBcVneXowOYGSCbe9CDjxE5kqvqssjjYmeoLtN6dwcjZcFRCbuUUkxE5c8CfyyN9OeDb6d3sB8TMY524D71y3cOdASlGb4AxadGRVa52GvOQrXLt3gpCmeoXTbcwJVF8urOuGKJFSC5pxaOOC5LR)FT4PwsW681U7Q6X50KqujMILl)5cGRYLxU()1INAjfbSv3GrXiFOsyZxsiQetX6iFoqVHIC5pxaC1Tj8281THbQO8v3jGoVBnETlGbaGlqUnyfQAuC50TXdhdHtCBigWju1OKz9dDu1uo5YlxbQcsskjrMHWPC6uFWsizw4BLl)56sU8YLJCpqtghVV7C(GAz4THiMlnA5QcsskfbSv3GrXiFOsyZxsWJC5LR)FT4PwY449H29bdLqujMILlGYfaxNlL3MWBZx3gW681U7bJfGA7AxadGlxGCBWku1O4YPBt4T5RBdyD(A39GXcqTDB8WXq4e3MWBdrSJfQmilxarpxxYLxUcufKKusImdHt50P(GLqYSW3kx(Z1LC5Llh5EGMmoEF358b1YWBdrmxA0YvfKKukcyRUbJIr(qLWMVKGh5sJwU()1INAjfyyN9OeDb6d3siQetXYL)CD8ICP824D71y3cOdASlGb4AxadGRUa52GvOQrXLt3gpCmeoXTb45EGM058b1YWBdr82eEB(62aJHHDbgIRDTRDBiIq281fWU4AxaW18TlCUBd1awt5WUnaZeU2pGBpaMZVT5MlqoXChLJhA5s(WC5kESZqd8GRCHifdCGOix2RG5gG2RegkY1FgLdYKjbC2uyUa02Cb2ViIqdf5YLfASmzB4kx7ZLll0yzY2iXku1OGRC5aa(qPmjGZMcZ1L2MlW(freAOixUGGfs(qhu2gUY1(C5ccwi5dDqzBKyfQAuWvUCaaFOuMeWztH5Y3TnxG9lIi0qrUCzHglt2gUY1(C5YcnwMSnsScvnk4kxoCHpuktcscaMjCTFa3EamNFBZnxGCI5okhp0YL8H5Yv8yxfeYmUYfIumWbIICzVcMBaAVsyOix)zuoitMeWztH56Q2MlW(freAOixUSqJLjBdx5AFUCzHglt2gjwHQgfCLlhUIpuktc4SPWCPO2MlW(freAOixUGGfs(qhu2gUY1(C5ccwi5dDqzBKyfQAuWvUCaaFOuMeKeamt4A)aU9ayo)2MBUa5eZDuoEOLl5dZLldovl0yCLlePyGdef5YEfm3a0ELWqrU(ZOCqMmjGZMcZfG2MlW(freAOixUSqJLjBdx5AFUCzHglt2gjwHQgfCLlhaWhkLjbC2uyUU02Cb2ViIqdf5YLbNQfAsaKTHRCTpxUm4uTqtAaiBdx5Yba8HszsaNnfMRlTnxG9lIi0qrUCzWPAHM0fzB4kx7ZLldovl0KMlY2WvUC4cFOuMeWztH56Q2MlW(freAOixUm4uTqtcGSnCLR95YLbNQfAsdazB4kxoCHpuktc4SPWCDvBZfy)IicnuKlxgCQwOjDr2gUY1(C5YGt1cnP5ISnCLlhaWhkLjbjbaZeU2pGBpaMZVT5MlqoXChLJhA5s(WC5YbleoEUYfIumWbIICzVcMBaAVsyOix)zuoitMeWztH56sBZfy)IicnuKlxqWcjFOdkBdx5AFUCbblK8HoOSnsScvnk4kxoaGpuktcscaMjCTFa3EamNFBZnxGCI5okhp0YL8H5YL)jIvugJRCHifdCGOix2RG5gG2RegkY1FgLdYKjbC2uyUa02Cb2ViIqdf5YLfASmzB4kx7ZLll0yzY2iXku1OGRC5aa(qPmjGZMcZ1vTnxG9lIi0qrUCzHglt2gUY1(C5YcnwMSnsScvnk4kxoaGpuktc4SPWCDvBZfy)IicnuKlxShuRoLq2gUY1(C5I9GA1PeY2iXku1OGRC5aa(qPmjGZMcZLIABUa7xerOHIC5YcnwMSnCLR95YLfASmzBKyfQAuWvUCaaFOuMeWztH5srTnxG9lIi0qrUCXEqT6uczB4kx7ZLl2dQvNsiBJeRqvJcUYLda4dLYKaoBkmx(UT5cSFreHgkYLll0yzY2WvU2NlxwOXYKTrIvOQrbx5Yba8HszsqsaWmHR9d42dG58BBU5cKtm3r54HwUKpmxUoGO)vudJRCHifdCGOix2RG5gG2RegkY1FgLdYKjbC2uyUUQT5cSFreHgkYLll0yzY2WvU2NlxwOXYKTrIvOQrbx5gwUatadCwUCaaFOuMeWztH5srTnxG9lIi0qrUnJcWMlZDzbFYLWJWlx7ZLZaJCvEbOgKL7FGWWEyUCq4rzUCaaFOuMeWztH5srTnxG9lIi0qrUCzWPAHMeazB4kx7ZLldovl0KgaY2WvUC4cFOuMeWztH5c02MlW(freAOi3MrbyZL5USGp5s4r4LR95YzGrUkVaudYY9pqyypmxoi8OmxoaGpuktc4SPWCbABZfy)IicnuKlxgCQwOjDr2gUY1(C5YGt1cnP5ISnCLlhUWhkLjbC2uyU8DBZfy)IicnuKBZOaS5YCxwWNCj8Y1(C5mWixXqCyZx5(himShMlheIYC5Wf(qPmjGZMcZLVBBUa7xerOHIC5YGt1cnjaY2WvU2NlxgCQwOjnaKTHRC5GI4dLYKaoBkmx(UT5cSFreHgkYLldovl0KUiBdx5AFUCzWPAHM0Cr2gUYLdGYhkLjbC2uyUCU2MlW(freAOixUSqJLjBdx5AFUCzHglt2gjwHQgfCLlhaWhkLjbjbaZeU2pGBpaMZVT5MlqoXChLJhA5s(WC5Y)Vw8ulgx5crkg4arrUSxbZnaTxjmuKR)mkhKjtc4SPWCDPT5cSFreHgkYLll0yzY2WvU2NlxwOXYKTrIvOQrbx5YHl8HszsaNnfMlF32Cb2ViIqdf5YLfASmzB4kx7ZLll0yzY2iXku1OGRC5aa(qPmjGZMcZLZRT5cSFreHgkYLll0yzY2WvU2NlxwOXYKTrIvOQrbx5Yba8HszsqsaWmHR9d42dG58BBU5cKtm3r54HwUKpmxUCWcHJVhpYvUqKIboquKl7vWCdq7vcdf56pJYbzYKaoBkmxaABUa7xerOHIC5YcnwMSnCLR95YLfASmzBKyfQAuWvUCaaFOuMeWztH56sBZfy)IicnuKlxqWcjFOdkBdx5AFUCbblK8HoOSnsScvnk4kxoaGpuktcscaMjCTFa3EamNFBZnxGCI5okhp0YL8H5YLajdqTXvUqKIboquKl7vWCdq7vcdf56pJYbzYKaoBkmxx12Cb2ViIqdf5YLfASmzB4kx7ZLll0yzY2iXku1OGRC5Wv8HszsaNnfMlf12Cb2ViIqdf5YLfASmzB4kx7ZLll0yzY2iXku1OGRC5aa(qPmjGZMcZLZ12Cb2ViIqdf5YLfASmzB4kx7ZLll0yzY2iXku1OGRC5Wv8HszsaNnfMlW42MlW(freAOixUSqJLjBdx5AFUCzHglt2gjwHQgfCLlhaWhkLjbC2uyUa462MlW(freAOixUSqJLjBdx5AFUCzHglt2gjwHQgfCLlhaWhkLjbC2uyUaaqBZfy)IicnuKlxwOXYKTHRCTpxUSqJLjBJeRqvJcUYLda4dLYKaoBkmxaCPT5cSFreHgkYLliyHKp0bLTHRCTpxUGGfs(qhu2gjwHQgfCLlhaWhkLjbC2uyUaqrTnxG9lIi0qrUCzHglt2gUY1(C5YcnwMSnsScvnk4kxoaGpuktc4SPWCDbG2MlW(freAOixUSqJLjBdx5AFUCzHglt2gjwHQgfCLlhUWhkLjbC2uyUU4Q2MlW(freAOixUSqJLjBdx5AFUCzHglt2gjwHQgfCLlhUWhkLjba5eZL816N6uo5gGWGLlveI5cYqrUtLRDI5gEB(kx9WSCvbTCPIqm36TCjFWsK7u5ANyUHq8vUIWc1GHTnjix(sUkbe(urr3bvy2xyhRZO8OcwwsqU8LCTt4O1DgITqysqsaqoXC5cKH9Xqfgx5gEB(kxQbl36TCjFWsK7u5ANdl3r54HMmjO9OC8qdf5cGRZn828vU6HzmzsWT5a(KJgVnTRD5syyyN5cmsnoNwUT315RDNe0U2LlbGfMRlCECNRlU2fascscAx7YfypJYbzTnjODTlx(sUeobfhKzkyzSCTpxcRimcryi5OrcryyyNSCjmqmx7Z9lT7C9pyz5Ab0bnwUup)CdiMlYNd0BOix7ZvpeXC1F5KlwpOZzU2NRsygcZLJ4XodnWJCBhauktcAx7YLVKlHnSqvJICBcpCih)e6CBFH3Yvf9bidZvGHixNZhuZYvjAH5s(WCzHixcdyeMmjODTlx(sUT3SPCYfy(blrUnhyjqyUH6OhBqwUkpeZLuJ8zu1UZLJWYLIOqUml8Ty5ofZWqK7tMlqPaLTxLlH1(AYTqqdg6CJsKRs4o3disellx2RG5wpFbI(CzJbg28ftMe0U2LlFj32B2uo5s4dzgcNYj3gdoTWCNkxchWaWuUdzUUFWCpdIyU1BNt5KlQzyU2NR4ZnkrUu)Ill3Nic9XrUuFWsWYDy5syTVMCle0GHwMe0U2LlFjxG9mkhuKRsuUZLlYX506qujMIXvU(VeJnFfAwU2NBCCODN7u5Q(mwUKJZPXY9lT7C5qJmwUalHLl1GzyUFLRbd2jLYKG21UC5l5s4ecuKBuVDIWCbganvigTYfld6ox7ZLHwUGh5Ym4xoimxGPJrGkJNjtcAx7YLVKlqagimGH2MBUe(cV9WCBmiwo2zUhW3ZYDk7Z1Gt1cTC1VZ4LjbjbH3MVyYdi6Ff1WOaDcD828vsq4T5lM8aI(xrnmkqNqWyyyxGHiji828ftEar)ROggfOtOaQ4U)KD7e7cmeCFar)ROgw3gfKUR4EiPdCl0yzsgOIYxDNa68U1ysq7YfyIyObddz5g5AWPAHglx))AXtT4oxXqCeOixv35sravMlqohwUudwU(ZNHvUblxW681UZL6dBXY9RCPiGMld9FjYvfeYSC9U9AKXDUQGwUNblx7)CvIYDUEbmxKKe9glx7Z1ziI5g56)xlEQLKpsbimS5RCfdXH9WCNIzyiK52EiZDmUy5sm0GyUNbl36ZfIkXuceMlenqyLlaCNlQzyUq0aHvUUwcuzsq4T5lM8aI(xrnmkqNqed4eQAK7kuq6gCQwO1bOZCxEU)d6m0gsUjgAqKoaCtm0Gyh1mKURLaLB)xIXMVOBWPAHMea5zW6GmSRcssYJddovl0Kai9)Rfp1skaHHnFr4r4rraLURPmji828ftEar)ROggfOtiIbCcvnYDfkiDdovl06U0zUlp3)bDgAdj3ednishaUjgAqSJAgs31sGYT)lXyZx0n4uTqt6I8myDqg2vbjj5XHbNQfAsxK()1INAjfGWWMVi8i8OiGs31uMe0UCbMy2OegYYnY1Gt1cnwUedniMRQ7C9VYraNYjx7eZ1)Vw8uRCFYCTtmxdovl04oxXqCeOixv35ANyUcqyyZx5(K5ANyUQGKK5owUhWN4iqMmxGrdwUrUmdILJDMRYlgYbH5AFUodrm3i3ZX5eH5EaNhoM7CTpxMbXYXoZ1Gt1cng35gSCPIADUbl3ixLxmKdcZL8H5oK5g5AWPAHwUuhTo3hMl1rRZTElxM7YNl1XoZ1)Vw8ulMmji828ftEar)ROggfOtiIbCcvnYDfkiDdovl06hW5HJ5M7)GodTHKBIHgeP7c3edni2rndPda3(VeJnFrh4gCQwOjbqEgSoid7QGKK8m4uTqt6I8myDqg2vbjjPrZGt1cnPlYZG1bzyxfKKKhhCyWPAHM0fP)FT4PwsbimS5lcpdovl0KUivbjj7cqyyZxuYx5aajqPGbNQfAsxKNbRRcsssjFLdIbCcvnkn4uTqR7sN5U8usjG4Gddovl0Kai9)Rfp1skaHHnFr4zWPAHMeaPkijzxacdB(Is(khaibkfm4uTqtcG8myDvqssk5RCqmGtOQrPbNQfADa6m3LNsktcAxUatednyyilxpieILLldnWJCjFyU2jMlfdmkBm35(K5s4oEFODFWWCbwcR9NlssIEJLeeEB(IjpGO)vudJc0jeXaoHQg5UcfKojOw39ci3ednis3cnwMmGkU7pz3oXUiukuWZ)LaCmP)lIVpS5R(t2TtSlWqiHr1cq0bgNeKe0U2LlWeFqpOHICrIi0DU2OG5ANyUH3EyUdl3Gym6qvJYKGWBZxm6ktj6Kqej8JjbTl32hejILLl7a9d5GICn4uTqJLRkoLtUGmuKl1XoZnaTxjSXNREkKLeeEB(Irb6eIyaNqvJCxHcsNDG(HCqr3Gt1cnUjgAqKohifdCooqHCkMhcAHQg7umWOmqLUajoEKN)FT4PwYPyEiOfQAStXaJYav6cK44rjedHBktcAx7YT9saNqvJSKGWBZxmkqNqed4eQAK7kuq6h)RNYPdbRX3pEQiKBIHgeP7)xlEQLKbQO8v3jGoVBnkHOsmfJFGYZcnwMKbQO8v3jGoVBnYJdl0yzsW681U7Q6X5045)xlEQLeSoFT7UQEConjevIPy8dGR45)xlEQLueWwDdgfJ8HkHnFjHOsmfRJ85a9gk4haxrJgWTqJLjbRZx7URQhNtJYKGWBZxmkqNqed4eQAK7kuq6h)RNYPdblKXnXqdI0TqJLjzpOUdX4aH8GGfYVl8Sa6GM0gfSBF)WBDxbu(bkpYX506qujMIbiGMeeEB(Irb6eIyaNqvJCxHcsNz9dDu1uoCtm0Gi9WBdrSJfQmiJoa84a4WyeDKiwMmecMe5ZWmgnAWyeDKiwMmecMCkabaqPmji828fJc0jeXaoHQg5UcfKEieSoevIP4MyObr6H3gIyhluzqgGO7cpoaomgrhjILjdHGjr(mmJrJgmgrhjILjdHGjr(mmJXJdymIoseltgcbtcrLykgGaknAKJZP1HOsmfdqa4AkPmji828fJc0jeXaoHQg5UcfKUsqXFy3)Vw8ulwp82qe5MyObr6CyHgltYavu(Q7eqN3Tg5b8d0Kob05DRrz4THiYZ)Vw8uljdur5RUtaDE3AucrLykgnAa3cnwMKbQO8v3jGoVBnsjpoubjjLG15RD3dgla1Me8Ggnl0yzYaQ4U)KD7e7IqPqbVd0KXX77oNpOwgEBiI0OPcsskfbSv3GrXiFOsyZxsWdA0cVneXowOYGmar3fEcmSZEuIUa9HBPn(wt5qzsq4T5lgfOtiIbCcvnYDfkiDLGI)W(b89SE4THiYnXqdI09prSIYK14CADYa5jWWo7rj6c0hUL24BnLdpvqssPad7K1fGOKzHVf)uenAQGKKsLacFQOO7Gkm7lSJ1zuEubltcEqJMkijP0oHJw3zi2cHsWdA0ubjjLKqSi8pOOR8fZGpBm3sWdA0ubjjLAmeDv3DKpHYHgLGhjbTl32RJPSyQPCYT9Yab1yz52(0HdiM7WYnY9aopCm3jbH3MVyuGoHEqtfIrlUhs6I3KehiOglRFOdhqucrsiYodvnYd4wOXYKG15RD3v1JZPXd4WyeDKiwMmecMe5ZWmwsq4T5lgfOtOh0uHy0IBVBVg7waDqJrhaUhs6I3KehiOglRFOdhqucrsiYodvnYl82qe7yHkdYaeDx4XbWTqJLjbRZx7URQhNtJgn))AXtTKG15RD3v1JZPjHOsmfJNkijPeSoFT7UQECoTUkijPu8ulktcAxUThYCTteI5gqmxSqLbz5Qmm2uo52EP9XDUXXH2DUJLlhQGwU1NRYdXCTZOY9lpM7bcZLVZLH(VemkLjbH3MVyuGoHEqtfIrlU1tHDVGoFZ9qsp82qe7I3KehiOglRFOdhqK)WBdrSJfQmiJx4THi2XcvgKbi6UWJdGBHgltcwNV2DxvpoNgnA()1INAjbRZx7URQhNttcrLykgpvqssjyD(A3Dv94CADvqssP4PwuMeeEB(Irb6e6bnvigT4EiPdblK8HoOKbEGqMbJP4XH4njj8zwNejIqjejHi7mu1inAI3KQ6)f9dD4aIsiscr2zOQrktcAxUTFKeIStKLlHHHDYYLWarUy5QcssMlfhKz5QIKpeZvGHDYYvaI5ILGLeeEB(Irb6eI6dwIo7albc5EiP7FIyfLjRX506KbYtGHD2Js0fOpCldVneXoevIPy8ZHJxWxbqcuk5jWWo7rj6c0hUL24BnLtsq4T5lgfOtiQXyCZqpD))AXtTKShu3HyCGqjevIPyCpK0TqJLjzpOUdX4aH8Sa6GM0gfSBF)WBDxbu(bkplGoOjTrb723fdciGYZ)Vw8ulj7b1DighiucrLykg)C44f8vxl5CaLsEH3gIyhluzqgDascAxUaZXy5s(WCjmmStUy5syGiHimKC0yUdzUaECoTCj8fyU2NRdA5Ymiwo2zUQGKK5Qg(w5gS4iji828fJc0je1ymUzONU)FT4Pwsbg2jRlarjevIPyCpK09prSIYK14CADYa55)xlEQLuGHDY6cqucrLykg)oEbVWBdrSJfQmiJoajbH3MVyuGoHOgJXnd909)Rfp1skqYrJsiQetX4EiP7FIyfLjRX506KbYZ)Vw8ulPajhnkHOsmfJFhVGx4THi2XcvgKrhGKG2LlHZBZx5YzdZy5gLixGHdSqilxoagoWcHmc1GumqS8ilxWIbEC8qdf5ovUHq8LKYKGWBZxmkqNq(qR7H3MV66HzCxHcs3Gt1cnwsq4T5lgfOtiFO19WBZxD9WmURqbP7FIyfLXsccVnFXOaDc5dTUhEB(QRhMXDfkiDy4NqZscAx7Yn828fJc0jedPyGy5rUhs6H3gIyhluzqgDa4bCbg2zVvnoNMumSqvJ94nbpl0yzsgOIYxDNa68U1i3vOG0DcOt)pWcHT9bnvigTAljYmeoLtNzWPf2wsKziCkNoZGtlSTmqfLV6ob05DRX2gqf39NSBNyxGHOTcmSZU)hn3djDvqssjduiWQl(xrcE0wbg2z3)JUTcmSZU)hDBz(he6GDMbNwi3djDbQcsskjrMHWPC6uFWsizw4BbikQTm)dcDWoZGtlK7HKUavbjjLKiZq4uoDQpyjKml8Taef1wsKziCkNoZGtlmjODTl3WBZxmkqNqmKIbILh5EiPhEBiIDSqLbz0bGhWfyyN9w14CAsXWcvn2J3e8aUfASmjdur5RUtaDE3AK7kuq6)bwiSTKiZq4uoDMbNwyBjrMHWPC6mdoTW2E828vBbRZx7URQhNtRTIa2QBWOyKpujS5R2ghVp0Upyysq4T5lgfOtiFO19WBZxD9WmURqbP7)xlEQflji828fJc0jeeS6H3MV66HzCxHcspESZqd8G7HKoXaoHQgLHqW6qujMIhh()1INAjfyyN9OeDb6d3siQetX4haxZd4wOXYKcKC0inA()1INAjfi5OrjevIPy8dGR5zHgltkqYrJ0O5FIyfLjRX506KbYZ)Vw8ulPad7K1fGOeIkXum(bW1uYd4cmSZEuIUa9HBPn(wt5KeeEB(Irb6eccw9WBZxD9WmURqbPhp2vbHmJBMbhVrhaUhs6H3gIyhluzqgGO7cpbg2zpkrxG(WT0gFRPCsccVnFXOaDcbbRE4T5RUEyg3vOG0DWcHJVhpY9qsp82qe7yHkdYaeDx4XbWfyyN9OeDb6d3sB8TMYHhh()1INAjfyyN9OeDb6d3siQetXaeaUMhWTqJLjfi5OrA08)Rfp1skqYrJsiQetXaeaUMNfASmPajhnsJM)jIvuMSgNtRtgip))AXtTKcmStwxaIsiQetXaeaUMsktccVnFXOaDc5dTUhEB(QRhMXDfkiDhSq445MzWXB0bG7HKE4THi2XcvgKrhGKGKG21UCjCpWuUCceYSKGWBZxmz8yxfeYm6EDqDkNo7mepvg3dj9WBdrSJfQmiJF6anji828ftgp2vbHmJc0jKxhuNYPZodXtLX9qsp82qe7yHkdYOZ38eyyN9w14CAssQpyjqr3cOdAmar3vjbH3MVyY4XUkiKzuGoHO(GLOZoWsGqUhs6wOXYKQGqMnLtN9qKXJdbg2zVvnoNMKK6dwcu0Ta6GgJE4THi2XcvgKrJMad7S3QgNttss9blbk6waDqJbi6UIsA0SqJLjvbHmBkNo7HiJNfASmPxhuNYPZodXtLXtGHD2BvJZPjjP(GLafDlGoOXaeDasccVnFXKXJDvqiZOaDcjWWo7(F0CpK05qfKKuYafcS6I)vKqm8gnAaNyaNqvJYJ)1t50HG147hpvesjpoubjjLIa2QBWOyKpujS5lj4bpiyHKp0bLcme6bzw3)JMx4THi2XcvgKXpDxrJw4THi2XcvgKr3fktccVnFXKXJDvqiZOaDcHhJavgp3djDiyn((XtfHsbso(X4NdaCnfeyyN9w14CAssQpyjqr3cOdAm(QROKNad7S3QgNttss9blbk6waDqJXpFZd4ed4eQAuE8VEkNoeSgF)4PIqA0ubjjLmQbuzkNUYWmj4rsq4T5lMmESRcczgfOti8yeOY45EiPdbRX3pEQiukqYXpg)UauEcmSZERAConjj1hSeOOBb0bngGakpGtmGtOQr5X)6PC6qWA89JNkctccVnFXKXJDvqiZOaDcHhJavgp3djDGlWWo7TQX50KKuFWsGIUfqh0y8aoXaoHQgLh)RNYPdbRX3pEQiKgnYX506qujMIXpqPrdgJOJeXYKHqWKiFgMX4bJr0rIyzYqiysiQetX4hOjbH3MVyY4XUkiKzuGoHO(GLOZoWsGWKGWBZxmz8yxfeYmkqNq4XiqLXZ9qsh4ed4eQAuE8VEkNoeSgF)4PIWKGKG21UCjCpWuUnObEKeeEB(IjJh7m0apOhL7UOeCpK0fyyN9w14CAssQpyjqr3cOdAmar372RXowOYGmA0eyyN9w14CAssQpyjqr3cOdAmarhO0ObCl0yzsvqiZMYPZEiYOrdgJOJeXYKHqWKiFgMX4bJr0rIyzYqiysiQetX4NoaaqJg54CADiQetX4NoaaKeeEB(IjJh7m0apOaDcjWWo7(F0CpK0boXaoHQgLh)RNYPdbRX3pEQiKhhQGKKsraB1nyumYhQe28Le8GheSqYh6Gsbgc9GmR7)rZl82qe7yHkdY4NUROrl82qe7yHkdYO7cLjbH3MVyY4XodnWdkqNq4XiqLXZ9qsh4ed4eQAuE8VEkNoeSgF)4PIWKGWBZxmz8yNHg4bfOtisKziCkNoZGtlKBVBVg7waDqJrhaUhs6cufKKusImdHt50P(GLqYSW3IF6UIN)FT4PwY449H29bdLqujMIXVRsccVnFXKXJDgAGhuGoHirMHWPC6mdoTqU9U9ASBb0bngDa4EiPlqvqssjjYmeoLtN6dwcjZcFl(biji828ftgp2zObEqb6eIezgcNYPZm40c5272RXUfqh0y0bG7HKoeSqPnky3(ofXph()1INAjfyyN9OeDb6d3siQetX4bCl0yzsbsoAKgn))AXtTKcKC0OeIkXumEwOXYKcKC0inA(NiwrzYACoTozG88)Rfp1skWWozDbikHOsmfJYKG2LlW8jw5Ab0bTCzuJdwUbeZvmSqvJcUZ1ohwUuhToxnA56(bZLDGLixiyHmcr9blbl3PyggICFYCPgJnLtUKpmxcRimcryi5OrcryyyNCXYLWarzsq4T5lMmESZqd8Gc0je1hSeD2bwceY9qsNdGZqZMYHj9U9AKgnbg2zVvnoNMKK6dwcu0Ta6Ggdq09U9ASJfQmiJsEcufKKusImdHt50P(GLqYSW3cqUIheSqPnky3(UR43)Vw8ulzuU7IsiHOsmfljijODTl323BZxjbH3MVys))AXtTy0pEB(I7HKoXaoHQgLkbf)HD))AXtTy9WBdrKgTd0Kob05DRrz4THiY7anPtaDE3AucrLykg)0DHVPrJCCoToevIPy87cFNe0U2LlW(Vw8ulwsq4T5lM0)Vw8ulgfOtOaQ4U)KD7e7cmeCpK09)Rfp1scwNV2DxvpoNMeIkXum(5C88)Rfp1skcyRUbJIr(qLWMVKqujMI1r(CGEdf8Z54zHgltcwNV2DxvpoNgpo8)Rfp1sghVp0UpyOeIkXuSoYNd0BOGFohpIbCcvnkjb16UxaPrd4ed4eQAuscQ1DVasjnAa3cnwMeSoFT7UQEConA0uFgJh54CADiQetX43vanji828ft6)xlEQfJc0je7b1DighiKBVBVg7waDqJrhaUhs6waDqtAJc2TVF4TURak)aLNfqh0K2OGD77Ibbeq5fEBiIDSqLbz8t3vjbTlxGrFTGLlN0JZPLl5dZf8ix7ZfO5Yq)xcwU2NlZD5ZL6yN5s4oEFODFWqUZfyWori1HHCNlidZL6yN5sybSvUabgfJ8HkHnFjtccVnFXK()1INAXOaDcbwNV2DxvpoNg3djDIbCcvnkzw)qhvnLdpo8)Rfp1sghVp0UpyOeIkXuSoYNd0BOGFGsJM)FT4PwY449H29bdLqujMI1r(CGEdfacaxtjpo8)Rfp1skcyRUbJIr(qLWMVKqujMIXVJxqJMkijPueWwDdgfJ8HkHnFjbpOmji828ft6)xlEQfJc0jeyD(A3Dv94CACpK0jgWju1OmecwhIkXu0OP(mgpYX506qujMIXVlaKeeEB(Ij9)Rfp1Irb6eseWwDdgfJ8HkHnFX9qsNyaNqvJsM1p0rvt5WJdXBsW681U7Q6X506I3KqujMIrJgWTqJLjbRZx7URQhNtJYKGWBZxmP)FT4PwmkqNqIa2QBWOyKpujS5lUhs6ed4eQAugcbRdrLykA0uFgJh54CADiQetX43fasccVnFXK()1INAXOaDcfhVp0Upyi3dj9WBdrSJfQmiJoa8eOkijPKezgcNYPt9blHKzHVfGOtr84a4ed4eQAuscQ1DVasJgXaoHQgLKGAD3lG84W)Vw8uljyD(A3Dv94CAsiQetXaeaUMgn))AXtTKIa2QBWOyKpujS5ljevIPyDKphO3qbGaW18aUfASmjyD(A3Dv94CAuszsq4T5lM0)Vw8ulgfOtO449H29bd5272RXUfqh0y0bG7HKE4THi2XcvgKbi6UWtGQGKKssKziCkNo1hSesMf(waYv8aUad7ShLOlqF4wAJV1uojbH3MVys))AXtTyuGoHyGkkF1DcOZ7wJCpK0HG147hpvekfi54hJFaOiE()1INAjbRZx7URQhNttcrLykg)a4kE()1INAjfbSv3GrXiFOsyZxsiQetX6iFoqVHc(bWvjbH3MVys))AXtTyuGoHaRZx7UhmwaQnUhs6ed4eQAuYS(HoQAkhEcufKKusImdHt50P(GLqYSW3IFx4XXbAY449DNZhuldVnerA0ubjjLIa2QBWOyKpujS5lj4bp))AXtTKXX7dT7dgkHOsmfdqa4AktccVnFXK()1INAXOaDcbwNV2DpySauBC7D71y3cOdAm6aW9qsp82qe7yHkdYaeDx4jqvqssjjYmeoLtN6dwcjZcFl(DHhhhOjJJ33DoFqTm82qePrtfKKukcyRUbJIr(qLWMVKGh0O5)xlEQLuGHD2Js0fOpClHOsmfJFhVGYKGWBZxmP)FT4PwmkqNqWyyyxGHG7HKoWpqt6C(GAz4THiMe0U2LlHnSqvJcUZLIdYSCR3YfIHw7o36HkHoxv8miopmx7mmUy5s9H2zUhGqg4uo5ofFXjuqzsq7AxUH3MVys))AXtTyuGoHyHhoKJFcD)i8g3dj9WBdrSJfQmidq0DHhWvbjjLIa2QBWOyKpujS5lj4bp))AXtTKIa2QBWOyKpujS5ljevIPyacO0OP(mgpYX506qujMIXVJxKeKeKe0U2LlW(eXkklxcN6OhBqwsq4T5lM0)eXkkJrNrnGkt50vgMX9qsNyaNqvJsM1p0rvt5WdcwJVF8urOuGKJFmabaFZJd))AXtTKXX7dT7dgkHOsmfJgnGBHgltgqf39NSBNyxekfk45)xlEQLueWwDdgfJ8HkHnFjHOsmfJsA0uFgJh54CADiQetX4haascAxUnOLR95cYWCdsdH5ghVp3HL7x5cSewUblx7Z9aIeXYY9jIqFCCmLtUT)2xUuphnMldnBkNCbpYfyjmUyjbH3MVys)teROmgfOtig1aQmLtxzyg3djD))AXtTKXX7dT7dgkHOsmfJhhH3gIyhluzqgGO7cVWBdrSJfQmiJF6aLheSgF)4PIqPajh)yacaxtbocVneXowOYGm(kFtjpIbCcvnkdHG1HOsmfnAH3gIyhluzqgGakpiyn((XtfHsbso(Xaef5AktccVnFXK(NiwrzmkqNqH6RmvyZxD9OOY9qsNyaNqvJsM1p0rvt5Wd4ShuRoLqQXq0vD3r(ekhAKhh()1INAjJJ3hA3hmucrLykgnAa3cnwMmGkU7pz3oXUiukuWZ)Vw8ulPiGT6gmkg5dvcB(scrLykgL8GGfkTrb723PiaPcsskHG147(hcbpS5ljevIPy0OP(mgpYX506qujMIXVlaKeeEB(Ij9prSIYyuGoHc1xzQWMV66rrL7HKoXaoHQgLmRFOJQMYHh7b1QtjKAmeDv3DKpHYHg5XH4njyD(A3Dv94CADXBsiQetXaeaaqJgWTqJLjbRZx7URQhNtJN)FT4PwsraB1nyumYhQe28LeIkXumktccVnFXK(NiwrzmkqNqH6RmvyZxD9OOY9qsNyaNqvJYqiyDiQetXdcwO0gfSBFNIaKkijPecwJV7Fie8WMVKqujMILeeEB(Ij9prSIYyuGoHyNHVLg72j2blQp0oDZ9qsNyaNqvJsM1p0rvt5WJd))AXtTKXX7dT7dgkHOsmfdqa4AA0aUfASmzavC3FYUDIDrOuOGN)FT4PwsraB1nyumYhQe28LeIkXumkPrt9zmEKJZP1HOsmfJFaaAsq4T5lM0)eXkkJrb6eIDg(wASBNyhSO(q70n3djDIbCcvnkdHG1HOsmfpoeyyN9OeDb6d3sB8TMYHgnymIoseltgcbtcrLykg)0bGIOmjijODTl3MPC0yUajGoOLeeEB(IjDWcHJNUad7S7)rZ9qsh4ed4eQAuE8VEkNoeSgF)4PIqECOcsskzGcbwDX)ksigEJgniyn((XtfHsbso(X4NoaUIsA0oqt6eqN3TgLH3gIipiyH8t3v0OrooNwhIkXum(bW18aUavbjjLKiZq4uoDQpyjKGhjbH3MVyshSq44PaDcfL7UOeCpK05WcnwMuGKJgLyfQAuqJM)jIvuMSgNtRtginAqWcjFOdkpoXa(kFHmk5XbWjgWju1O84F9uoDiyHmA0uFgJh54CADiQetX4hOuMeeEB(IjDWcHJNc0je1hSeD2bwceY9qsNyaNqvJsLGI)W(b89SE4THiYtGQGKKssKziCkNo1hSesMf(waIoa88)Rfp1sghVp0UpyOeIkXuSoYNd0BOaqaLhWjgWju1O84F9uoDiyHSKGWBZxmPdwiC8uGoHO(GLOZoWsGqUhs6cufKKusImdHt50P(GLqYSW3cqUIhWjgWju1O84F9uoDiyHmA0eOkijPKezgcNYPt9blHe8Gh54CADiQetX4NdbQcsskjrMHWPC6uFWsizw4BXxD8cktccVnFXKoyHWXtb6esGHD29)O5EiPdbRX3pEQiukqYXpg)0DX18aoXaoHQgLh)RNYPdbRX3pEQimji828ft6GfchpfOtisKziCkNoZGtlK7HKUavbjjLKiZq4uoDQpyjKml8T4NI4bCIbCcvnkp(xpLthcwilji828ft6GfchpfOtibg2z3)JM7HKoWjgWju1O84F9uoDiyn((XtfHjbH3MVyshSq44PaDcr9blrNDGLaHCpK0fOkijPKezgcNYPt9blHKzHVfGOdapiyH87cpGtmGtOQr5X)6PC6qWcz88)Rfp1sghVp0UpyOeIkXuSoYNd0BOaqanjijODTlxoFSq44ZLW9at52(GZdhZDsq4T5lM0bleo(E8iDQXyCZqpD))AXtTKShu3HyCGqjevIPyCpK0TqJLjzpOUdX4aH8Sa6GM0gfSBF)WBDxbu(bkpYX506qujMIbiGYZ)Vw8ulj7b1DighiucrLykg)C44f8vxl5CaLsEH3gIyhluzqg)0Dvsq4T5lM0bleo(E8ifOtibg2z3)JM7HKohaNyaNqvJYJ)1t50HG147hpvesJMkijPKbkey1f)RiHy4nk5XHkijPueWwDdgfJ8HkHnFjbp4bblK8HoOuGHqpiZ6(F08cVneXowOYGm(P7kA0cVneXowOYGm6Uqzsq4T5lM0bleo(E8ifOti8yeOY45EiPRcsskzGcbwDX)ksigEJgnGtmGtOQr5X)6PC6qWA89JNkctcAxUThYCTa6GwUE3E9uo5oSCfdlu1OG7CzuhZFMRA4BLR95ANyUSPC0iFXcOdA56GfchFU6Hz5ofZWqitccVnFXKoyHWX3JhPaDcbbRE4T5RUEyg3vOG0DWcHJNBMbhVrhaUhs6E3En2XcvgKrhGKGWBZxmPdwiC894rkqNquFWs0zhyjqi3E3En2Ta6GgJoaCpK05W)Vw8ulzC8(q7(GHsiQetXaeq5jqvqssjjYmeoLtN6dwcj4bnAcufKKusImdHt50P(GLqYSW3cqUIsECqooNwhIkXum(9)Rfp1skWWo7rj6c0hULqujMIrbaCnnAKJZP1HOsmfdq()1INAjJJ3hA3hmucrLykgLjbH3MVyshSq447XJuGoHirMHWPC6mdoTqU9U9ASBb0bngDa4EiPlqvqssjjYmeoLtN6dwcjZcFl(P7kE()1INAjJJ3hA3hmucrLykg)aLgnbQcsskjrMHWPC6uFWsizw4BXpajbH3MVyshSq447XJuGoHirMHWPC6mdoTqU9U9ASBb0bngDa4EiP7)xlEQLmoEFODFWqjevIPyacO8eOkijPKezgcNYPt9blHKzHVf)aKe0UCbY5WYDy5IKKO3gIO2DUKJwJWCPEo(ZCzJclxcR91KBHGgm0CNRkOLl78b1ICpGirSSCJCzESc485s9eHyU2jMBieFL7zWYTE7CkNCTpxi6FffSeYKGWBZxmPdwiC894rkqNqKiZq4uoDMbNwi3dj9WBdrSlEtsImdHt50P(GLaq09U9ASJfQmiJNavbjjLKiZq4uoDQpyjKml8T4NIscscAxUT)WpHMLeeEB(IjHHFcnJEa9rHD7HqSmUhs6qWA89JNkcLcKC8Jbi(gO844anPtaDE3AugEBiI0ObCl0yzsgOIYxDNa68U1OeRqvJck5bblukqYXpgGOd0KGWBZxmjm8tOzuGoHu1)l6KGq3CpK0jgWju1OujO4pS7)xlEQfRhEBiI0ODGM0jGoVBnkdVnerEhOjDcOZ7wJsiQetX4NUkijPuv)VOtccDlfGWWMVOrt9zmEKJZP1HOsmfJF6QGKKsv9)Ioji0TuacdB(kji828ftcd)eAgfOtiveYqyRPC4EiPtmGtOQrPsqXFy3)Vw8ulwp82qePr7anPtaDE3AugEBiI8oqt6eqN3TgLqujMIXpDvqssPkcziS1uosbimS5lA0uFgJh54CADiQetX4NUkijPufHme2AkhPaeg28vsq4T5lMeg(j0mkqNq6X50yDkoOWrblJ7HKUkijPeSoFT7oZGy5yNsWJKG2LlHR8iZGHoxGn06C9rLRbhhheMlfL7XByztOZvfKKKXDUy4pZvhmBkNCbaO5Yq)xcMm32BB0dHFuK7zaf56FbkY1gfm3GLBKRbhhheMR952cXJChlxigIqvJYKGWBZxmjm8tOzuGoHIYJmdg6Up0AUhs6ed4eQAuQeu8h29)Rfp1I1dVnerA0oqt6eqN3TgLH3gIiVd0Kob05DRrjevIPy8thaGsJM6Zy8ihNtRdrLykg)0baOjbH3MVysy4NqZOaDcfqFuy)auZqUhs6H3gIyhluzqgGO7cnACablukqYXpgGOduEqWA89JNkcLcKC8Jbi68TRPmji828ftcd)eAgfOtiYbIQ6)fCpK0jgWju1OujO4pS7)xlEQfRhEBiI0ODGM0jGoVBnkdVnerEhOjDcOZ7wJsiQetX4NUkijPKCGOQ(FHuacdB(Ign1NX4rooNwhIkXum(PRcsskjhiQQ)xifGWWMVsccVnFXKWWpHMrb6esnC6pz3GJVfJ7HKE4THi2XcvgKrhaECOcsskbRZx7UZmiwo2Pe8Ggn1NX4rooNwhIkXum(bkLjbjbTRD5ce4uTqJLeeEB(Ijn4uTqJrhKH9XqfURqbPpfZdbTqvJDkgyugOsxGehpY9qsNd))AXtTKG15RD3v1JZPjHOsmfdqU4AA08)Rfp1skcyRUbJIr(qLWMVKqujMI1r(CGEdfaYfxtjpocVneXowOYGmar3fA0oqtgqf3DNZhuldVnerA0oqtghVV7C(GAz4THiYJdl0yzsW681U7bJfGAJgnbg2zVvnoNMumSqvJ94nbL0ODGM0jGoVBnkdVnerkPrt9zmEKJZP1HOsmfJFxaGgnlGoOjTrb723p8w3fxZpqtcAx7YfiNyUgCQwOLl1XoZ1oXCphNtKz5ImBucdf5sm0Gi35sD06CvXCbzOixYbYSCJsK7rmquKl1XoZLWD8(q7(GH5YXqMRkijzUdlxaaAUm0)LGL7dZvJmgL5(WC5KEConcryajxogYCDGyyimx7mQCbaO5Yq)xcgLjbTRD5gEB(Ijn4uTqJrb6ecKH9XqfUz63OBWPAHgaCpK0boXaoHQgLSd0pKdk6gCQwOXJdom4uTqtcG8a(EzuU7IdMuacdB(IF6aauE()1INAjJJ3hA3hmucrLykgGCX10OzWPAHMea5b89YOC3fhmPaeg28fGaaO84W)Vw8uljyD(A3Dv94CAsiQetXaKlUMgn))AXtTKIa2QBWOyKpujS5ljevIPyDKphO3qbGCX1usJw4THi2XcvgKbi6UWtfKKukcyRUbJIr(qLWMVKGhuYJdGBWPAHM0f5zW6()1INArJMbNQfAsxK()1INAjHOsmfJgnIbCcvnkn4uTqRFaNhoMB6aqjL0OzWPAHMea5b89YOC3fhmPaeg28fGOtooNwhIkXuSKG21UCdVnFXKgCQwOXOaDcbYW(yOc3m9B0n4uTqZfUhs6aNyaNqvJs2b6hYbfDdovl04XbhgCQwOjDrEaFVmk3DXbtkaHHnFXpDaakp))AXtTKXX7dT7dgkHOsmfdqU4AA0m4uTqt6I8a(EzuU7IdMuacdB(cqaauEC4)xlEQLeSoFT7UQEConjevIPyaYfxtJM)FT4PwsraB1nyumYhQe28LeIkXuSoYNd0BOaqU4AkPrl82qe7yHkdYaeDx4PcsskfbSv3GrXiFOsyZxsWdk5XbWn4uTqtcG8myD))AXtTOrZGt1cnjas))AXtTKqujMIrJgXaoHQgLgCQwO1pGZdhZnDxOKsA0m4uTqt6I8a(EzuU7IdMuacdB(cq0jhNtRdrLykwsq7YT9qM7xA35(fM7x5cYWCn4uTql3d4tCeil3ixvqssUZfKH5ANyUVDIWC)kx))AXtTK5cmaZDiZTWXoryUgCQwOL7b8jocKLBKRkijj35cYWCvF7m3VY1)Vw8ulzsq4T5lM0Gt1cngfOtiqg2hdv4MPFJUbNQfAaW9qsh4gCQwOjbqEgSoid7QGKK84WGt1cnPls))AXtTKqujMIrJgWn4uTqt6I8myDqg2vbjjPmji828ftAWPAHgJc0jeid7JHkCZ0Vr3Gt1cnx4EiPdCdovl0KUipdwhKHDvqssECyWPAHMeaP)FT4PwsiQetXOrd4gCQwOjbqEgSoid7QGKKuEBcq78H3MMrbuh28fWcds7Ax7Eb]] )


end
