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


    spec:RegisterPack( "Unholy", 20211101, [[def3YcqiGWJuPWLuHuTjuLpHuAuiQofsXQeQIEfIsZcvv3sOkSlc)ciAyOs1XubldvLNjaMMkv5AQqTnvi6BOsHXHkL05qLsSoHQ6DcvjL5jGUhQyFcvoOkvLfIkXdvPOjIOWfvHeBuLQQ6JcvjgPkKsDsHQuRei9sviLmtefDtHQKQDQsLFIkLAOQqslvfc9ubnvvkDvvifBvOkjFvLQkJvaAVa(RunyLoSOftIhlLjt0LH2ms(SqgTk50kwTke8AbA2K62K0UL8BvnCv0XrLIwoONJY0PCDe2oq9DKQXJkPZluwVkvvz(iY(PAGda3cektdbUJpUZ3Hdh4(bbFhUxaUh3cqOf7ebcpZwWmcbcRufbcpAQRxhdi8mJP)ucClqi7jGnei8YStw8bjiJg7Iqr0EvqYgvcDAZxnyszGKnQnqceQqmAlExakaHY0qG74J78D4WbUFqW3H7fG7Dmqi7eBa3X3X8beEnsjwakaHsK1acjdmTlFpAvt0L57rtD96yoOC7M9ki0x(os(9LpUZ3bhuh0BELveYIVdA8W37tEeiyMkwgZx79LmkYaKKbsnAeKKbM2fZxYGa91EF)shZ32tuMVwcJqJ5l9R33eI(IC9eBgk91EF1dy0x9xr(I1teD5R9(QMMHqFjpFSZqJ403BCGgHdA8WxYyyPIgL(gMn4qnTj1(EuZM5Rc2scg6RetPVrxpHM5RAge9L6H(YsPVKXrlMWbnE47rdBQiFVFprj9n8eljc9nvg9ydY8v9HOVuAKRJIoMVKNMV3JS(YSSfK57umdtPVpLVhtwAIxZxY4Og6BHegm1(ML0x1mMVNqemwMVSxf9T(4beB(YgJiT5lMWbnE47rdBQiFV)rMHWPI8n0Gtq03P89(42hfFhkFJ9e(ELGrFR3UMkYxuZqFT3x57BwsFP)fTMVpye2YtFP)eLK57W8LmoQH(wiHbtTWbnE47nVYkcL(QMvmFPLAIUSoevZPy06B7l5yZxPM5R9(MNN6y(oLVkpJ5l1eDzmF)shZxY1iJ57njdFPNmd99lFnyYUOr4Ggp89(Ksu6BwVDHqF52eMceZG(ILbJ5R9(YqZxItFzg8Rie67r5CKO60ych04HVhruNC13WB9fmt479XTpk(Q)OP5lBQg67y(cr9GmF)Y32xuPcHonu6lmhzhbJLXeoOXdFVLBtgC747RV3)zZEOVHgeRi7Y3t43y(oL9(AWPcIMV6pAAcGq9WmgWTaH5JDgAeNa3cC3bGBbcXkv0OeGlaHn4yiCsGqjM2vpynrxMGI(tusu2TegHgZ3444BlwtJDSq1bz(sIKVsmTREWAIUmbf9NOKOSBjmcnMVXXX3J9LejFbHVwQXYekeqMnvuN9qKjWkv0O0xsK8fMJSJGXYePuYeixhMX8LNVWCKDemwMiLsMaIQ5umFdKJVho4ljs(snrxwhIQ5umFdKJVhoaeMnB(cimRyDzjbmG74d4wGqSsfnkb4cqydogcNeiee(coHtQOrX5)6PI6qIAA9ZNoc9LNVK7RcbfLqMWGDdMfJ6HQPnFjio9LNVqIcPEyekKyk1dYSE7hTaRurJsF55B2Sbm2XcvhK5BGC8na(sIKVzZgWyhluDqMVC8LpFPbimB28fqOet7Q3(rdya3faGBbcXkv0OeGlaHn4yiCsGqq4l4eoPIgfN)RNkQdjQP1pF6ieimB28fqiEosuDAagWD3d4wGqSsfnkb4cqy2S5lGqkKziCQOoZGtqeiSbhdHtcekrfckkbfYmeovuN(tusbZYwqFdKJVbWxE(2(xlF6Lip)wQJDYqbevZPy(gOVbaiSfRPXULWi0ya3DaWaU7yGBbcXkv0OeGlaHzZMVacPqMHWPI6mdobrGWgCmeojqOeviOOeuiZq4urD6prjfmlBb9nqFpae2I10y3syeAmG7oaya3DKa3ceIvQOrjaxacZMnFbesHmdHtf1zgCcIaHn4yiCsGqirHcBuXU9975BG(sUVT)1YNEjKyAx9SKDj2YyciQMtX8LNVGWxl1yzcjsnAuGvQOrPVKi5B7FT8PxcjsnAuar1CkMV881snwMqIuJgfyLkAu6ljs(2EWyLLjQj6Y6uj6lpFB)RLp9siX0UyDjbkGOAofZxAacBXAASBjmcngWDhamG74ga3ceIvQOrjaxacZMnFbes)jkzNDILeHaHsK1GZPnFbeE)UWYxlHrO5lJEEY8nHOVYHLkAuYVV21W8L(O1(QrZ3ypHVStSK(cjkKbs6prjz(ofZWu67t5l9CSPI8L6H(sgfzasYaPgncsYat7IwMVKbbkacBWXq4KaHK7li8LHMnvet0I10OVKi5Ret7QhSMOltqr)jkjk7wcJqJ5BCC8TfRPXowO6GmFPXxE(krfckkbfYmeovuN(tusbZYwqFJZ3a4lpFHefkSrf723dGVb6B7FT8PxISI1LLuar1CkgGbyaH5JDfciZaUf4Uda3ceIvQOrjaxacBWXq4KaHzZgWyhluDqMVbYX3JbcZMnFbe20j9PI6SRu(0zagWD8bClqiwPIgLaCbiSbhdHtceMnBaJDSq1bz(YX3J0xE(kX0U6bRj6Yeu0FIsIYULWi0y(ghhFdaqy2S5lGWMoPpvuNDLYNodWaUlaa3ceIvQOrjaxacBWXq4KaHwQXYekeqMnvuN9qKjWkv0O0xE(sUVsmTREWAIUmbf9NOKOSBjmcnMVC8nB2ag7yHQdY8LejFLyAx9G1eDzck6prjrz3syeAmFJJJVbWxA8LejFTuJLjuiGmBQOo7HitGvQOrPV881snwMOPt6tf1zxP8PZeyLkAu6lpFLyAx9G1eDzck6prjrz3syeAmFJJJVhacZMnFbes)jkzNDILeHagWD3d4wGqSsfnkb4cqydogcNeiKCFviOOemcPeRU8FvbeZM5ljs(ccFbNWjv0O48F9urDirnT(5thH(sJV88LCFviOOeYegSBWSyupunT5lbXPV88fsui1dJqHetPEqM1B)OfyLkAu6lpFZMnGXowO6GmFdKJVbWxsK8nB2ag7yHQdY8LJV85lnaHzZMVacLyAx92pAad4UJbUfieRurJsaUae2GJHWjbcHe106NpDekKi10gZ3a9LCFpWDFjRVsmTREWAIUmbf9NOKOSBjmcnMVXtFdGV04lpFLyAx9G1eDzck6prjrz3syeAmFd03J0xE(ccFbNWjv0O48F9urDirnT(5thH(sIKVkeuucg9eQovuxDyMG4eimB28fqiEosuDAagWDhjWTaHyLkAucWfGWgCmeojqiKOMw)8PJqHePM2y(gOV8DSV88vIPD1dwt0LjOO)eLeLDlHrOX8noFp2xE(ccFbNWjv0O48F9urDirnT(5thHaHzZMVacXZrIQtdWaUJBaClqiwPIgLaCbiSbhdHtceccFLyAx9G1eDzck6prjrz3syeAmF55li8fCcNurJIZ)1tf1He106NpDe6ljs(snrxwhIQ5umFd03J9LejFH5i7iySmrkLmbY1HzmF55lmhzhbJLjsPKjGOAofZ3a99yGWSzZxaH45ir1Pbya3XTcClqy2S5lGq6prj7StSKieieRurJsaUaya3XTaClqiwPIgLaCbiSbhdHtceccFbNWjv0O48F9urDirnT(5thHaHzZMVacXZrIQtdWamGWiSq4065Ja3cC3bGBbcXkv0OeGlaHmSbe2(xlF6LG9e6oeZtekGOAofdimB28fqi9CmGWgCmeojqOLASmb7j0DiMNiuGvQOrPV881syeAcBuXU99ZM1dWX(gOVh7lpFPMOlRdr1CkMVX57X(YZ32)A5tVeSNq3HyEIqbevZPy(gOVK7But6B80xUl4gh7ln(YZ3SzdySJfQoiZ3a54BaamG74d4wGqSsfnkb4cqydogcNeiKCFbHVGt4KkAuC(VEQOoKOMw)8PJqFjrYxfckkbJqkXQl)xvaXSz(sJV88LCFviOOeYegSBWSyupunT5lbXPV88fsui1dJqHetPEqM1B)OfyLkAu6lpFZMnGXowO6GmFdKJVbWxsK8nB2ag7yHQdY8LJV85lnaHzZMVacLyAx92pAad4UaaClqiwPIgLaCbiSbhdHtceQqqrjyesjwD5)QciMnZxsK8fe(coHtQOrX5)6PI6qIAA9ZNocbcZMnFbeINJevNgGbC39aUfieRurJsaUaekrwdoN28fqy8MYxlHrO5BlwtpvKVdZx5Wsfnk53xg9XAx(QKTG(AVV2f6lBQingpSegHMVryHWP5REyMVtXmmLcGWSzZxaHqIQNnB(QRhMbeYm40mG7oae2GJHWjbcBXAASJfQoiZxo(EaiupmRxPkcegHfcNgGbC3Xa3ceIvQOrjaxacZMnFbes)jkzNDILeHaHn4yiCsGqY9T9Vw(0lrE(Tuh7KHciQMtX8noFp2xE(krfckkbfYmeovuN(tusbXPVKi5ReviOOeuiZq4urD6prjfmlBb9noFdGV04lpFj3xQj6Y6qunNI5BG(2(xlF6LqIPD1Zs2LylJjGOAofZxY67bU7ljs(snrxwhIQ5umFJZ32)A5tVe553sDStgkGOAofZxAacBXAASBjmcngWDhamG7osGBbcXkv0OeGlaHzZMVacPqMHWPI6mdobrGWgCmeojqOeviOOeuiZq4urD6prjfmlBb9nqo(gaF55B7FT8PxI88BPo2jdfqunNI5BG(ESVKi5ReviOOeuiZq4urD6prjfmlBb9nqFpae2I10y3syeAmG7oaya3XnaUfieRurJsaUaeMnB(ciKczgcNkQZm4eebcBWXq4KaHT)1YNEjYZVL6yNmuar1CkMVX57X(YZxjQqqrjOqMHWPI60FIskyw2c6BG(EaiSfRPXULWi0ya3DaWaUJBf4wGqSsfnkb4cqy2S5lGqkKziCQOoZGtqeiuISgCoT5lGWBVgMVdZxKIcB2ag1X8LA0Ae6l9RPD5lBuz(sgh1qFlKWGPMFFvimFzxpHw67jebJL5B6lRHvcN3x6xie91UqFtP8lFVsMV1Bxtf5R9(cX2RQILuae2GJHWjbcZMnGXU8nbfYmeovuN(tusFJJJVTynn2XcvhK5lpFLOcbfLGczgcNkQt)jkPGzzlOVb679amadimcleonGBbU7aWTaHyLkAucWfGWgCmeojqii8fCcNurJIZ)1tf1He106NpDe6lpFj3xfckkbJqkXQl)xvaXSz(sIKVqIAA9ZNocfsKAAJ5BGC89qa8LgFjrY3t0erjm6JPrr2Sbm6lpFHef6BGC8na(sIKVut0L1HOAofZ3a99a39LNVGWxjQqqrjOqMHWPI60FIskiobcZMnFbekX0U6TF0agWD8bClqiwPIgLaCbiSbhdHtcesUVwQXYesKA0OaRurJsFjrY32dgRSmrnrxwNkrFjrYxirHupmcfNxycF1VqMaRurJsFPXxE(sUVGWxWjCsfnko)xpvuhsuiZxsK8v5zmF55l1eDzDiQMtX8nqFp2xAacZMnFbeMvSUSKagWDba4wGqSsfnkb4cqydogcNeieCcNurJcjH6zN(tusMV88vIkeuuckKziCQOo9NOKcMLTG(ghhFp4lpFB)RLp9sKNFl1XozOaIQ5uSoY1tSzO03489yF55li8fCcNurJIZ)1tf1HefYacZMnFbes)jkzNDILeHagWD3d4wGqSsfnkb4cqydogcNeiuIkeuuckKziCQOo9NOKcMLTG(gNVbWxE(ccFbNWjv0O48F9urDirHmFjrYxjQqqrjOqMHWPI60FIskio9LNVut0L1HOAofZ3a9LCFLOcbfLGczgcNkQt)jkPGzzlOVXtFJAsFPbimB28fqi9NOKD2jwsecya3DmWTaHyLkAucWfGWgCmeojqiKOMw)8PJqHePM2y(gihF5J7(YZxq4l4eoPIgfN)RNkQdjQP1pF6ieimB28fqOet7Q3(rdya3DKa3ceIvQOrjaxacBWXq4KaHsuHGIsqHmdHtf1P)eLuWSSf03a99E(YZxq4l4eoPIgfN)RNkQdjkKbeMnB(ciKczgcNkQZm4eebmG74ga3ceIvQOrjaxacBWXq4KaHGWxWjCsfnko)xpvuhsutRF(0riqy2S5lGqjM2vV9JgWaUJBf4wGqSsfnkb4cqydogcNeiuIkeuuckKziCQOo9NOKcMLTG(ghhFp4lpFHef6BG(YNV88fe(coHtQOrX5)6PI6qIcz(YZ32)A5tVe553sDStgkGOAofRJC9eBgk9noFpgimB28fqi9NOKD2jwsecyagqy7bJvwgd4wG7oaClqiwPIgLaCbiSbhdHtcecoHtQOrbZ6N6SQPI8LNVqIAA9ZNocfsKAAJ5BC(E4i9LNVK7B7FT8PxI88BPo2jdfqunNI5ljs(ccFTuJLjsOAS(t1TlSlt1cLcSsfnk9LNVT)1YNEjKjmy3GzXOEOAAZxciQMtX8LgFjrYxLNX8LNVut0L1HOAofZ3a99WbGWSzZxaHm6juDQOU6Wmad4o(aUfieRurJsaUaeMnB(ciKrpHQtf1vhMbekrwdoN28fqyiA(AVVem03KYqOV5538Dy((LV3Km8nz(AVVNqemwMVpye2YZZPI89iEu9L(1OrFzOztf5lXPV3KmOLbe2GJHWjbcB)RLp9sKNFl1XozOaIQ5umF55l5(MnBaJDSq1bz(ghhF5ZxE(MnBaJDSq1bz(gihFp2xE(cjQP1pF6iuirQPnMVX57bU7lz9LCFZMnGXowO6GmFJN(EK(sJV88fCcNurJIukzDiQMt5ljs(MnBaJDSq1bz(gNVh7lpFHe106NpDekKi10gZ3489EC3xAamG7caWTaHyLkAucWfGWgCmeojqi4eoPIgfmRFQZQMkYxE(ccFzpHwzkPqJPSReRJCnvp1OaRurJsF55l5(2(xlF6Lip)wQJDYqbevZPy(sIKVGWxl1yzIeQgR)uD7c7YuTqPaRurJsF55B7FT8Pxczcd2nywmQhQM28LaIQ5umFPXxE(cjkuyJk2TVFpFJZxfckkbKOMwV9qiXPnFjGOAofZxsK8v5zmF55l1eDzDiQMtX8nqF57aqy2S5lGWu5vNkT5RUEuvamG7UhWTaHyLkAucWfGWgCmeojqi4eoPIgfmRFQZQMkYxE(YEcTYusHgtzxjwh5AQEQrbwPIgL(YZxY9v(MGOUEDSUIEIUSU8nbevZPy(gNVho4ljs(ccFTuJLjiQRxhRRONOltGvQOrPV88T9Vw(0lHmHb7gmlg1dvtB(sar1CkMV0aeMnB(cimvE1PsB(QRhvfad4UJbUfieRurJsaUae2GJHWjbcbNWjv0OGz9tDw1ur(YZx2tOvMskcIGNI1))(d1tfjWkv0O0xE(krfckkbfYmeovuN(tusbZYwqFJJJV3dimB28fqyQ8QtL28vxpQkagWDhjWTaHyLkAucWfGWgCmeojqi4eoPIgfPuY6qunNYxE(cjkuyJk2TVFpFJZxfckkbKOMwV9qiXPnFjGOAofdimB28fqyQ8QtL28vxpQkagWDCdGBbcXkv0OeGlaHn4yiCsGqWjCsfnkyw)uNvnvKV88LCFB)RLp9sKNFl1XozOaIQ5umFJZ3dC3xsK8fe(APgltKq1y9NQBxyxMQfkfyLkAu6lpFB)RLp9sityWUbZIr9q10MVequnNI5ln(sIKVkpJ5lpFPMOlRdr1CkMVb67HJbcZMnFbeYUYwqn2TlStu0FODfdWaUJBf4wGqSsfnkb4cqydogcNeieCcNurJIukzDiQMt5lpFj3xjM2vplzxITmMWMwWPI8LejFH5i7iySmrkLmbevZPy(gihFpCpFPbimB28fqi7kBb1y3UWorr)H2vmad4oUfGBbcXkv0OeGlaHn4yiCsGq2tOvMskojygHg7iK40MVeyLkAuceMnB(ciKsJSRgmPmadWacpHy7vvsd4wG7oaClqy2S5lGWZ3MVacXkv0OeGlagWD8bClqy2S5lGqyomSlXuceIvQOrjaxamG7caWTaHzZMVacP0i7QbtkdieRurJsaUaya3DpGBbcXkv0OeGlaHzZMVactOAS(t1TlSlXuce2GJHWjbcbHVwQXYemcv1V6rjm6JPrbwPIgLaHNqS9QkP1TrfbcdaGbC3Xa3ceIvQOrjaxac)tGqgAdfqydogcNei0GtfenHDqCLSobd7keuu(YZxY91GtfenHDq0(xlF6LqsatB(Y3JUV37yF54l39LgGqjYAW50MVacpkGtnrAiZ30xdovq0y(2(xlF6f)(khWJeL(QeZ37DSW3BVgMV0tMVTRNHLVjZxI661X8L(ddY89lFV3X(YW2xsFviGmZ3wSMgz87RcH57vY81(3x1SI5Btc9fPOWMX81EFJgWOVPVT)1YNEj4QqsatB(Yx5aEyp03PygMsHVXBkFhJwMVGtnb67vY8TEFHOAoLeH(crJaw(EGFFrnd9fIgbS8L7IJfaHGtyVsvei0GtfeT(Holw1acZMnFbecoHtQOrGqWPMa7OMHaHCxCmqi4utGaHhamG7osGBbcXkv0OeGlaH)jqidTHcimB28fqi4eoPIgbcbNWELQiqObNkiAD(6SyvdiSbhdHtceAWPcIMW4tCLSobd7keuu(YZxY91GtfenHXNO9Vw(0lHKaM28LVhDFV3X(YXxU7lnaHGtnb2rndbc5U4yGqWPMabcpaya3XnaUfieRurJsaUae(NaHm0gkGWgCmeojqii81GtfenHDqCLSobd7keuu(YZxdovq0egFIRK1jyyxHGIYxsK81GtfenHXN4kzDcg2viOO8LNVK7l5(AWPcIMW4t0(xlF6LqsatB(Yxq6RbNkiAcJpHcbfvxsatB(YxA8nE6l5(EqCSVK1xdovq0egFIRK1viOO8LgFJN(sUVGt4KkAuyWPcIwNVolw18LgFPX348LCFj3xdovq0e2br7FT8PxcjbmT5lFbPVgCQGOjSdcfckQUKaM28LV04B80xY99G4yFjRVgCQGOjSdIRK1viOO8LgFJN(sUVGt4KkAuyWPcIw)qNfRA(sJV0aekrwdoN28fq4rHzJAAiZ30xdovq0y(co1eOVkX8T9QNjCQiFTl032)A5tV89P81UqFn4ubrJFFLd4rIsFvI5RDH(kjGPnF57t5RDH(Qqqr57y(EcFWJezcFpANmFtFzgeRi7Yx1xoudc91EFJgWOVPVxt0fc99eopCSy(AVVmdIvKD5RbNkiAm(9nz(sh1AFtMVPVQVCOge6l1d9DO8n91GtfenFPpATVp0x6Jw7B9MVSyvZx6JD5B7FT8Pxmbqi4e2Rufbcn4ubrRFcNhowmGWSzZxaHGt4KkAeieCQjWoQziq4bGqWPMabc5dWaUJBf4wGqSsfnkb4cq4FceYqdimB28fqi4eoPIgbcbNAcei0snwMiHQX6pv3UWUmvlukWkv0O0xE(2(ssmMO9f4VL28v)P62f2LykfWSc6BCC8LBbiuISgCoT5lGWJc4utKgY8TraHyz(YqJ40xQh6RDH(YnjYYglMVpLV3353sDStg67njJJOViff2mgqi4e2RufbcPi06EtcbmadiS9Vw(0lgWTa3Da4wGqSsfnkb4cqydogcNeieCcNurJc18i8WE7FT8PxSE2Sbm6ljs(EIMikHrFmnkYMnGrF557jAIOeg9X0OaIQ5umFdKJV8DK(sIKVut0L1HOAofZ3a9LVJeimB28fq45BZxagWD8bClqiwPIgLaCbiSbhdHtce2(xlF6LGOUEDSUIEIUmbevZPy(gOVCdF55B7FT8Pxczcd2nywmQhQM28LaIQ5uSoY1tSzO03a9LB4lpFTuJLjiQRxhRRONOltGvQOrPV88LCFB)RLp9sKNFl1XozOaIQ5uSoY1tSzO03a9LB4lpFbNWjv0OGIqR7nj0xsK8fe(coHtQOrbfHw3BsOV04ljs(ccFTuJLjiQRxhRRONOltGvQOrPVKi5RYZy(YZxQj6Y6qunNI5BG(gGJbcZMnFbeMq1y9NQBxyxIPeWaUlaa3ceIvQOrjaxacZMnFbeYEcDhI5jcbcBWXq4KaHwcJqtyJk2TVF2SEao23a99yF55RLWi0e2OID77Yb9noFp2xE(MnBaJDSq1bz(gihFdaqylwtJDlHrOXaU7aGbC39aUfieRurJsaUaeMnB(ciKOUEDSUIEIUmGqjYAW50MVacpA)AjZxUONOlZxQh6lXPV277X(YW2xsMV27llw18L(yx(EFNFl1Xozi)(YTTlesFyi)(sWqFPp2LVKrcd67TWSyupunT5lbqydogcNeieCcNurJcM1p1zvtf5lpFj332)A5tVe553sDStgkGOAofRJC9eBgk9nqFp2xsK8T9Vw(0lrE(Tuh7KHciQMtX6ixpXMHsFJZ3dC3xA8LNVK7B7FT8Pxczcd2nywmQhQM28LaIQ5umFd03OM0xsK8vHGIsityWUbZIr9q10MVeeN(sdGbC3Xa3ceIvQOrjaxacBWXq4KaHGt4KkAuKsjRdr1CkFjrYxLNX8LNVut0L1HOAofZ3a9LVdaHzZMVacjQRxhRRONOldWaU7ibUfieRurJsaUaeMnB(ciKrOQ(vpkHrFmnce2GJHWjbcHe106NpDekKi10gZ3a99W98LNVT)1YNEjiQRxhRRONOltar1CkMVb67Ha4lpFB)RLp9sityWUbZIr9q10MVequnNI5BG(EiaaH6PWEtcegGJK7ChWaUJBaClqiwPIgLaCbiSbhdHtcecoHtQOrbZ6N6SQPI8LNVK7R8nbrD96yDf9eDzD5BciQMtX8LejFbHVwQXYee11RJ1v0t0LjWkv0O0xAacZMnFbektyWUbZIr9q10MVamG74wbUfieRurJsaUae2GJHWjbcbNWjv0OiLswhIQ5u(sIKVkpJ5lpFPMOlRdr1CkMVb6lFhacZMnFbektyWUbZIr9q10MVamG74waUfieRurJsaUae2GJHWjbcZMnGXowO6GmF547bF55ReviOOeuiZq4urD6prjfmlBb9noo(EpF55l5(ccFbNWjv0OGIqR7nj0xsK8fCcNurJckcTU3KqF55l5(2(xlF6LGOUEDSUIEIUmbevZPy(gNVh4UVKi5B7FT8Pxczcd2nywmQhQM28LaIQ5uSoY1tSzO03489a39LNVGWxl1yzcI661X6k6j6YeyLkAu6ln(sdqy2S5lGW88BPo2jdbmG7oWDGBbcXkv0OeGlaHzZMVacZZVL6yNmeiSbhdHtceMnBaJDSq1bz(ghhF5ZxE(krfckkbfYmeovuN(tusbZYwqFJZ3a4lpFbHVsmTREwYUeBzmHnTGtfbe2I10y3syeAmG7oaya3D4aWTaHyLkAucWfGWgCmeojqiKOMw)8PJqHePM2y(gOVhUNV88T9Vw(0lbrD96yDf9eDzciQMtX8nqFpeaF55B7FT8Pxczcd2nywmQhQM28LaIQ5uSoY1tSzO03a99qaacZMnFbeYiuv)QhLWOpMgbmG7oWhWTaHyLkAucWfGWgCmeojqi4eoPIgfmRFQZQMkYxE(krfckkbfYmeovuN(tusbZYwqFd0x(8LNVK77jAI88B9ORNqlYMnGrFjrYxfckkHmHb7gmlg1dvtB(sqC6lpFB)RLp9sKNFl1XozOaIQ5umFJZ3dC3xsK8T9Vw(0lrE(Tuh7KHciQMtX8noFpWDF55B7FT8Pxczcd2nywmQhQM28LaIQ5umFJZ3dC3xAacZMnFbesuxVowpzSKqBagWDhcaWTaHyLkAucWfGWSzZxaHe11RJ1tglj0gqydogcNeimB2ag7yHQdY8noo(YNV88vIkeuuckKziCQOo9NOKcMLTG(gOV85lpFj33t0e5536rxpHwKnBaJ(sIKVkeuuczcd2nywmQhQM28LG40xsK8T9Vw(0lHet7QNLSlXwgtar1CkMVb6But6lnaHTynn2TegHgd4UdagWDhUhWTaHyLkAucWfGWgCmeojqii89enr01tOfzZgWiqy2S5lGqyomSlXucyagqObNkiAmGBbU7aWTaHyLkAucWfGWSzZxaHtXAqclv0yNBsKLrO2Li4PHaHn4yiCsGqY9T9Vw(0lbrD96yDf9eDzciQMtX8noF5J7(sIKVT)1YNEjKjmy3GzXOEOAAZxciQMtX6ixpXMHsFJZx(4UV04lpFj33SzdySJfQoiZ3444lF(sIKVNOjsOASE01tOfzZgWOVKi57jAI88B9ORNqlYMnGrF55l5(APgltquxVowpzSKqBcSsfnk9LejFLyAx9G1eDzc5Wsfn2Z3K(sJVKi57jAIOeg9X0OiB2ag9LgFjrYxLNX8LNVut0L1HOAofZ3a9LVd(sIKVwcJqtyJk2TVF2SoFC33a99yGWkvrGWPyniHLkASZnjYYiu7se80qad4o(aUfieRurJsaUaeMnB(ci0GtfeTdaHsK1GZPnFbeE7f6RbNkiA(sFSlFTl03Rj6czMViZg10qPVGtnbYVV0hT2xf0xcgk9LAGmZ3SK(EMdeL(sFSlFVVZVL6yNm0xYhkFviOO8Dy(E4yFzy7ljZ3h6RgzmA89H(Yf9eDzGKmU1xYhkFJGyAi0x7klFpCSVmS9LKrdqydogcNeiee(coHtQOrb7eBd1GYUbNkiA(YZxY9LCFn4ubrtyhekeuuDjbmT5lFdKJVho2xE(2(xlF6Lip)wQJDYqbevZPy(gNV8XDFjrYxdovq0e2bHcbfvxsatB(Y3489WX(YZxY9T9Vw(0lbrD96yDf9eDzciQMtX8noF5J7(sIKVT)1YNEjKjmy3GzXOEOAAZxciQMtX6ixpXMHsFJZx(4UV04ljs(MnBaJDSq1bz(ghhF5ZxE(QqqrjKjmy3GzXOEOAAZxcItFPXxE(sUVGWxdovq0egFIRK1B)RLp9YxsK81GtfenHXNO9Vw(0lbevZPy(sIKVGt4KkAuyWPcIw)eopCSy(YX3d(sJV04ljs(AWPcIMWoiuiOO6scyAZx(ghhFPMOlRdr1CkgGbCxaaUfieRurJsaUae2GJHWjbcbHVGt4KkAuWoX2qnOSBWPcIMV88LCFj3xdovq0egFcfckQUKaM28LVbYX3dh7lpFB)RLp9sKNFl1XozOaIQ5umFJZx(4UVKi5RbNkiAcJpHcbfvxsatB(Y3489WX(YZxY9T9Vw(0lbrD96yDf9eDzciQMtX8noF5J7(sIKVT)1YNEjKjmy3GzXOEOAAZxciQMtX6ixpXMHsFJZx(4UV04ljs(MnBaJDSq1bz(ghhF5ZxE(QqqrjKjmy3GzXOEOAAZxcItFPXxE(sUVGWxdovq0e2bXvY6T)1YNE5ljs(AWPcIMWoiA)RLp9sar1CkMVKi5l4eoPIgfgCQGO1pHZdhlMVC8LpFPXxA8LejFn4ubrty8juiOO6scyAZx(ghhFPMOlRdr1Ckgqy2S5lGqdovq04dWaU7Ea3ceIvQOrjaxacZMnFbeAWPcI2bGqjYAW50MVacJ3u((LoMVFH((LVem0xdovq089e(GhjY8n9vHGIIFFjyOV2f67Bxi03V8T9Vw(0lHVCBOVdLVfo2fc91GtfenFpHp4rImFtFviOO43xcg6RYBx((LVT)1YNEjacBWXq4KaHGWxdovq0e2bXvY6emSRqqr5lpFj3xdovq0egFI2)A5tVequnNI5ljs(ccFn4ubrty8jUswNGHDfckkFPbWaU7yGBbcXkv0OeGlaHn4yiCsGqq4RbNkiAcJpXvY6emSRqqr5lpFj3xdovq0e2br7FT8PxciQMtX8LejFbHVgCQGOjSdIRK1jyyxHGIYxAacZMnFbeAWPcIgFagGbekrQKqBa3cC3bGBbcZMnFbeQoLStbr8(dbcXkv0OeGlagWD8bClqiwPIgLaCbi8pbczObeMnB(cieCcNurJaHGtnbcesUVi3KyoprPykwdsyPIg7CtISmc1Uebpn0xE(2(xlF6LykwdsyPIg7CtISmc1UebpnuaXugZxAacLiRbNtB(ci8OcrWyz(YoX2qnO0xdovq0y(QGtf5lbdL(sFSlFtc7vtBA(QNczaHGtyVsveiKDITHAqz3Gtfenad4UaaClqiwPIgLaCbi8pbczObeMnB(cieCcNurJaHGtnbce2(xlF6LGrOQ(vpkHrFmnkGOAofZ3a99yF55RLASmbJqv9REucJ(yAuGvQOrPV88LCFTuJLjiQRxhRRONOltGvQOrPV88T9Vw(0lbrD96yDf9eDzciQMtX8nqFpeaF55B7FT8Pxczcd2nywmQhQM28LaIQ5uSoY1tSzO03a99qa8LejFbHVwQXYee11RJ1v0t0LjWkv0O0xAacbNWELQiq45)6PI6qIAA9ZNocbmG7UhWTaHyLkAucWfGW)eiKHgqy2S5lGqWjCsfnceco1eiqOLASmb7j0DiMNiuGvQOrPV88fsuOVb6lF(YZxlHrOjSrf723pBwpah7BG(ESV88LAIUSoevZPy(gNVhdecoH9kvrGWZ)1tf1HefYamG7og4wGqSsfnkb4cq4FceYqdimB28fqi4eoPIgbcbNAceimB2ag7yHQdY8LJVh8LNVK7li8fMJSJGXYePuYeixhMX8LejFH5i7iySmrkLmXu(gNVho2xAacbNWELQiqiZ6N6SQPIamG7osGBbcXkv0OeGlaH)jqidnGWSzZxaHGt4KkAeieCQjqGWSzdySJfQoiZ3444lF(YZxY9fe(cZr2rWyzIukzcKRdZy(sIKVWCKDemwMiLsMa56WmMV88LCFH5i7iySmrkLmbevZPy(gNVh7ljs(snrxwhIQ5umFJZ3dC3xA8LgGqWjSxPkceMsjRdr1Ckad4oUbWTaHyLkAucWfGW)eiKHgqy2S5lGqWjCsfnceco1eiqi5(APgltWiuv)QhLWOpMgfyLkAu6lpFbHVNOjIsy0htJISzdy0xE(2(xlF6LGrOQ(vpkHrFmnkGOAofZxsK8fe(APgltWiuv)QhLWOpMgfyLkAu6ln(YZxY9vHGIsquxVowpzSKqBcItFjrYxl1yzIeQgR)uD7c7YuTqPaRurJsF557jAI88B9ORNqlYMnGrFjrYxfckkHmHb7gmlg1dvtB(sqC6ljs(MnBaJDSq1bz(ghhF5ZxE(kX0U6zj7sSLXe20covKV0aecoH9kvrGq18i8WE7FT8PxSE2Sbmcya3XTcClqiwPIgLaCbi8pbczObeMnB(cieCcNurJaHGtnbce2EWyLLjQj6Y6uj6lpFLyAx9SKDj2YycBAbNkYxE(QqqrjKyAxSUKafmlBb9nqFVNVKi5RcbfLqnHWNok7rOkZ(c7yDLvdvXYeeN(sIKVkeuuc7coADNHyqekio9LejFviOOeuqSU)gu2v)IzWNnwmbXPVKi5RcbfLqJPSReRJCnvp1OG40xsK8vHGIs0UYN1vYcfeN(sIKVT)1YNEjiQRxhRNmwsOnbevZPy(gOVhdecoH9kvrGqjH6zN(tusgGbCh3cWTaHyLkAucWfGWSzZxaHpHPaXmiqOezn4CAZxaHXRNtz5utf5B8QbsOXY89OQZic03H5B67jCE4yXacBWXq4KaHY3eGhiHglRFQZicuarkiYUsfn6lpFbHVwQXYee11RJ1v0t0LjWkv0O0xE(ccFH5i7iySmrkLmbY1Hzmad4UdCh4wGqSsfnkb4cqy2S5lGWNWuGygeiSbhdHtcekFtaEGeASS(PoJiqbePGi7kv0OV88nB2ag7yHQdY8noo(YNV88LCFbHVwQXYee11RJ1v0t0LjWkv0O0xsK81snwMGOUEDSUIEIUmbwPIgL(YZxY9T9Vw(0lbrD96yDf9eDzciQMtX8noFj33dh7li9nB2ag7yHQdY8LS(kFtaEGeASS(PoJiqbevZPy(sJVKi5B2Sbm2XcvhK5BCC8na(sJV0ae2I10y3syeAmG7oaya3D4aWTaHyLkAucWfGWSzZxaHpHPaXmiqOEkS3KaHhjqydogcNeimB2ag7Y3eGhiHglRFQZic03a9nB2ag7yHQdY8LNVzZgWyhluDqMVXXXx(8LNVK7li81snwMGOUEDSUIEIUmbwPIgL(sIKVT)1YNEjiQRxhRRONOltar1CkMV88vHGIsquxVowxrprxwxHGIsiF6LV0aekrwdoN28fqy8MYx7cHOVje9fluDqMVQdJnvKVXRoQ87BEEQJ57y(sUcH5B9(Q(q0x7klF)QH(EIqFpsFzy7ljJgbGbC3b(aUfieRurJsaUae2GJHWjbcHefs9WiuWioriZG5ucSsfnk9LNVK7R8nbf8zwNcbJqbePGi7kv0OVKi5R8nHI(Fz)uNreOaIuqKDLkA0xAacZMnFbe(eMceZGagWDhcaWTaHyLkAucWfGWSzZxaH0FIs2zNyjriqOezn4CAZxaHhrKcISlK5lzGPDX8LmiqAz(Qqqr57rGGz(QGupe9vIPDX8vsG(ILKbe2GJHWjbcBpySYYe1eDzDQe9LNVsmTREwYUeBzmr2Sbm2HOAofZ3a9LCFJAsFJN(EqCSV04lpFLyAx9SKDj2YycBAbNkcWaU7W9aUfieRurJsaUaeYWgqy7FT8Pxc2tO7qmprOaIQ5umGWSzZxaH0ZXacBWXq4KaHwQXYeSNq3HyEIqbwPIgL(YZxlHrOjSrf723pBwpah7BG(ESV881syeAcBuXU9D5G(gNVh7lpFB)RLp9sWEcDhI5jcfqunNI5BG(sUVrnPVXtF5UGBCSV04lpFZMnGXowO6GmF547bad4UdhdClqiwPIgLaCbiuISgCoT5lGW7xoMVup0xYat7IwMVKbbcsYaPgn67q57Dt0L579FI(AVVrO5lZGyfzx(Qqqr5Rs2c6BYYtGqg2acB)RLp9siX0UyDjbkGOAofdimB28fqi9CmGWgCmeojqy7bJvwMOMOlRtLOV88T9Vw(0lHet7I1LeOaIQ5umFd03OM0xE(MnBaJDSq1bz(YX3dagWDhosGBbcXkv0OeGlaHmSbe2(xlF6LqIuJgfqunNIbeMnB(ciKEogqydogcNeiS9GXkltut0L1Ps0xE(2(xlF6LqIuJgfqunNI5BG(g1K(YZ3SzdySJfQoiZxo(EaWaU7a3a4wGqSsfnkb4cqOezn4CAZxaH3xZMV8LmhMX8nlPVC7tSqiZxY52NyHqgidrUjbwnK5lrXiopFOHsFNY3uk)sqdqy2S5lGWwQ19SzZxD9WmGq9WSELQiqObNkiAmad4UdCRa3ceIvQOrjaxacZMnFbe2sTUNnB(QRhMbeQhM1RufbcBpySYYyagWDh4waUfieRurJsaUaeMnB(ciSLADpB28vxpmdiupmRxPkcecZ2KAgGbChFCh4wGqSsfnkb4cqy2S5lGWwQ19SzZxD9WmGq9WSELQiqy7FT8Pxmad4o(oaClqiwPIgLaCbiSbhdHtcecoHtQOrrkLSoevZP8LNVK7B7FT8PxcjM2vplzxITmMaIQ5umFd03dC3xE(ccFTuJLjKi1OrbwPIgL(sIKVT)1YNEjKi1OrbevZPy(gOVh4UV881snwMqIuJgfyLkAu6ljs(2EWyLLjQj6Y6uj6lpFB)RLp9siX0UyDjbkGOAofZ3a99a39LgF55li8vIPD1Zs2LylJjSPfCQiGWSzZxaHqIQNnB(QRhMbeQhM1RufbcZh7m0iobmG74JpGBbcXkv0OeGlaHn4yiCsGWSzdySJfQoiZ3444lF(YZxjM2vplzxITmMWMwWPIaczgCAgWDhacZMnFbecjQE2S5RUEygqOEywVsveimFSRqazgGbChFba4wGqSsfnkb4cqydogcNeimB2ag7yHQdY8noo(YNV88LCFbHVsmTREwYUeBzmHnTGtf5lpFj332)A5tVesmTREwYUeBzmbevZPy(gNVh4UV88fe(APgltirQrJcSsfnk9LejFB)RLp9sirQrJciQMtX8noFpWDF55RLASmHePgnkWkv0O0xsK8T9GXkltut0L1Ps0xE(2(xlF6LqIPDX6scuar1CkMVX57bU7ln(sIKVGWxWjCsfnksPK1HOAoLV0aeMnB(ciesu9SzZxD9WmGq9WSELQiqyewiCA98rad4o(UhWTaHyLkAucWfGWgCmeojqy2Sbm2XcvhK5lhFp4ljs(ccFbNWjv0OiLswhIQ5uaHmdond4UdaHzZMVacBPw3ZMnF11dZac1dZ6vQIaHryHWPbyagqimBtQza3cC3bGBbcXkv0OeGlaHzZMVactyllSBpeILbekrwdoN28fq4rmBtQzaHn4yiCsGqirnT(5thHcjsnTX8noFpYJ9LNVK77jAIOeg9X0OiB2ag9LejFbHVwQXYemcv1V6rjm6JPrbwPIgL(sJV88fsuOqIutBmFJJJVhdya3XhWTaHyLkAucWfGWgCmeojqi4eoPIgfQ5r4H92)A5tVy9Szdy0xsK89enrucJ(yAuKnBaJ(YZ3t0erjm6JPrbevZPy(gihFviOOek6)LDkcymHKaM28LVKi5RYZy(YZxQj6Y6qunNI5BGC8vHGIsOO)x2PiGXescyAZxaHzZMVacv0)l7ueWyagWDba4wGqSsfnkb4cqydogcNeieCcNurJc18i8WE7FT8PxSE2Sbm6ljs(EIMikHrFmnkYMnGrF557jAIOeg9X0OaIQ5umFdKJVkeuucfeYqyWPIescyAZx(sIKVkpJ5lpFPMOlRdr1CkMVbYXxfckkHcczim4urcjbmT5lGWSzZxaHkiKHWGtfbya3DpGBbcXkv0OeGlaHn4yiCsGqfckkbrD96yDMbXkYUeeNaHzZMVac1t0LX6hbczKkwgGbC3Xa3ceIvQOrjaxacZMnFbeMvdzgm19wQ1aHsK1GZPnFbeEFvdzgm1(EZuR9TLLVgCIIqOV3Z3Z3WYMu7RcbffJFFXSD5Roz2ur(E4yFzy7ljt47rJn65(dL(ELqPVTxIsFTrf9nz(M(AWjkcH(AVVbr803X8fIPmv0OaiSbhdHtcecoHtQOrHAEeEyV9Vw(0lwpB2ag9LejFprteLWOpMgfzZgWOV889enrucJ(yAuar1CkMVbYX3dh7ljs(Q8mMV88LAIUSoevZPy(gihFpCmGbC3rcClqiwPIgLaCbiSbhdHtceMnBaJDSq1bz(ghhF5ZxsK8LCFHefkKi10gZ34447X(YZxirnT(5thHcjsnTX8noo(EKC3xAacZMnFbeMWwwy)KqZqad4oUbWTaHyLkAucWfGWgCmeojqi4eoPIgfQ5r4H92)A5tVy9Szdy0xsK89enrucJ(yAuKnBaJ(YZ3t0erjm6JPrbevZPy(gihFviOOeudev0)lfscyAZx(sIKVkpJ5lpFPMOlRdr1CkMVbYXxfckkb1arf9)sHKaM28fqy2S5lGqQbIk6)LagWDCRa3ceIvQOrjaxacBWXq4KaHzZgWyhluDqMVC89GV88LCFviOOee11RJ1zgeRi7sqC6ljs(Q8mMV88LAIUSoevZPy(gOVh7lnaHzZMVacvYO(t1n40cYamadWacbJq28fWD8XD(oWDUvUFaiKEcRPIyaH3V77iEx8(U4L47RV3EH(oQNp08L6H(sB(yNHgXjT(crUjXarPVSxf9njSxnnu6B7kRiKjCqjZPqFpeFFV5xGrOHsFP1snwMiG06R9(sRLASmrafyLkAusRVKFGR0iCqjZPqF5l((EZVaJqdL(slKOqQhgHIasRV27lTqIcPEyekcOaRurJsA9L8dCLgHdkzof67rgFFV5xGrOHsFP1snwMiG06R9(sRLASmrafyLkAusRVKZhxPr4G6GE)UVJ4DX77IxIVV(E7f67OE(qZxQh6lT5JDfciZO1xiYnjgik9L9QOVjH9QPHsFBxzfHmHdkzof6BaIVV38lWi0qPV0APglteqA91EFP1snwMiGcSsfnkP1xYdaxPr4GsMtH(EV477n)cmcnu6lTqIcPEyekciT(AVV0cjkK6HrOiGcSsfnkP1xYpWvAeoOoO3V77iEx8(U4L47RV3EH(oQNp08L6H(sRbNkiAmA9fICtIbIsFzVk6BsyVAAO032vwrit4GsMtH(Ei((EZVaJqdL(sRLASmraP1x79Lwl1yzIakWkv0OKwFj)axPr4GsMtH(Yx899MFbgHgk9Lwdovq0ehebKwFT3xAn4ubrtyhebKwFjpaCLgHdkzof6lFX33B(fyeAO0xAn4ubrtWNiG06R9(sRbNkiAcJpraP1xY5JR0iCqjZPqFdq899MFbgHgk9Lwdovq0ehebKwFT3xAn4ubrtyhebKwFjNpUsJWbLmNc9naX33B(fyeAO0xAn4ubrtWNiG06R9(sRbNkiAcJpraP1xYdaxPr4GsMtH(EV477n)cmcnu6lTgCQGOjoiciT(AVV0AWPcIMWoiciT(s(bUsJWbLmNc99EX33B(fyeAO0xAn4ubrtWNiG06R9(sRbNkiAcJpraP1xY5JR0iCqjZPqFpo((EZVaJqdL(sRbNkiAIdIasRV27lTgCQGOjSdIasRVKZhxPr4GsMtH(EC899MFbgHgk9Lwdovq0e8jciT(AVV0AWPcIMW4teqA9L8dCLgHdQd697(oI3fVVlEj((67TxOVJ65dnFPEOV0gHfcNgT(crUjXarPVSxf9njSxnnu6B7kRiKjCqjZPqF5l((EZVaJqdL(slKOqQhgHIasRV27lTqIcPEyekcOaRurJsA9L8dCLgHdQd697(oI3fVVlEj((67TxOVJ65dnFPEOV02EWyLLXO1xiYnjgik9L9QOVjH9QPHsFBxzfHmHdkzof67H477n)cmcnu6lTwQXYebKwFT3xATuJLjcOaRurJsA9L8dCLgHdkzof6BaIVV38lWi0qPV0APglteqA91EFP1snwMiGcSsfnkP1xYpWvAeoOK5uOVbi((EZVaJqdL(sl7j0ktjfbKwFT3xAzpHwzkPiGcSsfnkP1xYpWvAeoOK5uOV3l((EZVaJqdL(sRLASmraP1x79Lwl1yzIakWkv0OKwFj)axPr4GsMtH(EV477n)cmcnu6lTSNqRmLueqA91EFPL9eALPKIakWkv0OKwFj)axPr4GsMtH(EC899MFbgHgk9Lw2tOvMskciT(AVV0YEcTYusrafyLkAusRVKFGR0iCqjZPqF5gX33B(fyeAO0xATuJLjciT(AVV0APglteqbwPIgL06l5h4knchuYCk0xUL477n)cmcnu6lTSNqRmLueqA91EFPL9eALPKIakWkv0OKwFtZ3Jc3Mm9L8dCLgHdQd697(oI3fVVlEj((67TxOVJ65dnFPEOV0EcX2RQKgT(crUjXarPVSxf9njSxnnu6B7kRiKjCqjZPqFVx899MFbgHgk9Lwl1yzIasRV27lTwQXYebuGvQOrjT(MMVhfUnz6l5h4knchuYCk03JJVV38lWi0qPVHJ6n9LfRSKR(E0p6(AVVKjr6R6lj0emF)teM2d9L8Jon(s(bUsJWbLmNc994477n)cmcnu6lTgCQGOjoiciT(AVV0AWPcIMWoiciT(soFCLgHdkzof67rgFFV5xGrOHsFdh1B6llwzjx99OF091EFjtI0x1xsOjy((NimTh6l5hDA8L8dCLgHdkzof67rgFFV5xGrOHsFP1GtfenbFIasRV27lTgCQGOjm(ebKwFjNpUsJWbLmNc9LBeFFV5xGrOHsFdh1B6llwzjx99O7R9(sMePVYb8WMV89pryAp0xYbjn(soFCLgHdkzof6l3i((EZVaJqdL(sRbNkiAIdIasRV27lTgCQGOjSdIasRVKFpUsJWbLmNc9LBeFFV5xGrOHsFP1GtfenbFIasRV27lTgCQGOjm(ebKwFj)yUsJWbLmNc9LBn((EZVaJqdL(sRLASmraP1x79Lwl1yzIakWkv0OKwFj)axPr4G6GE)UVJ4DX77IxIVV(E7f67OE(qZxQh6lTT)1YNEXO1xiYnjgik9L9QOVjH9QPHsFBxzfHmHdkzof6lFX33B(fyeAO0xATuJLjciT(AVV0APglteqbwPIgL06l58XvAeoOK5uOVCJ477n)cmcnu6lTwQXYebKwFT3xATuJLjcOaRurJsA9L8dCLgHdkzof6l3s899MFbgHgk9Lwl1yzIasRV27lTwQXYebuGvQOrjT(s(bUsJWb1b9(DFhX7I33fVeFF992l03r98HMVup0xAJWcHtRNpsRVqKBsmqu6l7vrFtc7vtdL(2UYkczchuYCk03dX33B(fyeAO0xATuJLjciT(AVV0APglteqbwPIgL06l5h4knchuYCk0x(IVV38lWi0qPV0cjkK6HrOiG06R9(slKOqQhgHIakWkv0OKwFj)axPr4G6GE)UVJ4DX77IxIVV(E7f67OE(qZxQh6lTsKkj0gT(crUjXarPVSxf9njSxnnu6B7kRiKjCqjZPqFdq899MFbgHgk9Lwl1yzIasRV27lTwQXYebuGvQOrjT(sEa4knchuYCk037fFFV5xGrOHsFP1snwMiG06R9(sRLASmrafyLkAusRVKFGR0iCqjZPqF5gX33B(fyeAO0xATuJLjciT(AVV0APglteqbwPIgL06l5bGR0iCqjZPqF5wIVV38lWi0qPV0APglteqA91EFP1snwMiGcSsfnkP1xYpWvAeoOK5uOVh4E899MFbgHgk9nCuVPVSyLLC13JUV27lzsK(khWdB(Y3)eHP9qFjhK04l5h4knchuYCk03dCp((EZVaJqdL(sRLASmraP1x79Lwl1yzIakWkv0OKwFjNpUsJWbLmNc99WH477n)cmcnu6lTwQXYebKwFT3xATuJLjcOaRurJsA9L8dCLgHdkzof67b(IVV38lWi0qPV0cjkK6HrOiG06R9(slKOqQhgHIakWkv0OKwFj)axPr4GsMtH(E4EX33B(fyeAO0xATuJLjciT(AVV0APglteqbwPIgL06l5h4knchuYCk0x(oeFFV5xGrOHsFP1snwMiG06R9(sRLASmrafyLkAusRVKZhxPr4GsMtH(YxaIVV38lWi0qPV0APglteqA91EFP1snwMiGcSsfnkP1xY5JR0iCqDqJ3QNp0qPVh4UVzZMV8vpmJjCqbcpHp1OrGWBCdFjdmTlFpAvt0L57rtD96yoO34g(YTB2RGqF57i53x(4oFhCqDqVXn89MxzfHS47GEJB4B8W37tEeiyMkwgZx79LmkYaKKbsnAeKKbM2fZxYGa91EF)shZ32tuMVwcJqJ5l9R33eI(IC9eBgk91EF1dy0x9xr(I1teD5R9(QMMHqFjpFSZqJ403BCGgHd6nUHVXdFjJHLkAu6By2Gd10Mu77rnBMVkyljyOVsmL(gD9eAMVQzq0xQh6llL(sghTych0BCdFJh(E0WMkY373tusFdpXsIqFtLrp2GmFvFi6lLg56OOJ5l5P579iRVmlBbz(ofZWu67t57XKLM418LmoQH(wiHbtTVzj9vnJ57jebJL5l7vrFRpEaXMVSXisB(IjCqVXn8nE47rdBQiFV)rMHWPI8n0Gtq03P89(42hfFhkFJ9e(ELGrFR3UMkYxuZqFT3x57BwsFP)fTMVpye2YtFP)eLK57W8LmoQH(wiHbtTWb9g3W34HV38kRiu6RAwX8LwQj6Y6qunNIrRVTVKJnFLAMV27BEEQJ57u(Q8mMVut0LX89lDmFjxJmMV3Km8LEYm03V81Gj7IgHd6nUHVXdFVpPeL(M1Bxi0xUnHPaXmOVyzWy(AVVm08L40xMb)kcH(EuohjQonMWb9g3W34HVhruNC13WB9fmt479XTpk(Q)OP5lBQg67y(cr9GmF)Y32xuPcHonu6lmhzhbJLXeoO34g(gp89wUnzWTJVV(E)Nn7H(gAqSISlFpHFJ57u27RbNkiA(Q)OPjCqDqZMnFXeNqS9QkPrwoG88T5lh0SzZxmXjeBVQsAKLdiH5WWUetPdA2S5lM4eITxvjnYYbKuAKD1GjL5GMnB(IjoHy7vvsJSCazcvJ1FQUDHDjMs(pHy7vvsRBJkYja8puCaHLASmbJqv9REucJ(yA0b9g(EuaNAI0qMVPVgCQGOX8T9Vw(0l(9voGhjk9vjMV37yHV3EnmFPNmFBxpdlFtMVe11RJ5l9hgK57x(EVJ9LHTVK(QqazMVTynnY43xfcZ3RK5R9VVQzfZ3Me6lsrHnJ5R9(gnGrFtFB)RLp9sWvHKaM28LVYb8WEOVtXmmLcFJ3u(ogTmFbNAc03RK5B9(cr1Ckjc9fIgbS89a)(IAg6lency5l3fhlCqZMnFXeNqS9QkPrwoGeCcNurJ8xPkYXGtfeT(Holw14)p5WqBO4hCQjqoh4hCQjWoQzihUloM)2xYXMV4yWPcIM4G4kzDcg2viOO4rUbNkiAIdI2)A5tVescyAZxh9J(9oMd3PXbnB28ftCcX2RQKgz5asWjCsfnYFLQihdovq0681zXQg))jhgAdf)GtnbY5a)Gtnb2rnd5WDXX83(so28fhdovq0e8jUswNGHDfckkEKBWPcIMGpr7FT8PxcjbmT5RJ(r)EhZH704GEdFpkmButdz(M(AWPcIgZxWPMa9vjMVTx9mHtf5RDH(2(xlF6LVpLV2f6RbNkiA87RCapsu6RsmFTl0xjbmT5lFFkFTl0xfckkFhZ3t4dEKit47r7K5B6lZGyfzx(Q(YHAqOV27B0ag9n99AIUqOVNW5HJfZx79LzqSISlFn4ubrJXVVjZx6Ow7BY8n9v9Ld1GqFPEOVdLVPVgCQGO5l9rR99H(sF0AFR38LfRA(sFSlFB)RLp9IjCqZMnFXeNqS9QkPrwoGeCcNurJ8xPkYXGtfeT(jCE4yX4)p5WqBO4hCQjqo8Xp4utGDuZqoh4V9LCS5loGWGtfenXbXvY6emSRqqrXZGtfenbFIRK1jyyxHGIIejdovq0e8jUswNGHDfckkEKtUbNkiAc(eT)1YNEjKeW0MVo6gCQGOj4tOqqr1LeW0MVOjEs(bXXK1GtfenbFIRK1viOOOjEso4eoPIgfgCQGO15RZIvnAOjoYj3GtfenXbr7FT8PxcjbmT5RJUbNkiAIdcfckQUKaM28fnXtYpioMSgCQGOjoiUswxHGIIM4j5Gt4KkAuyWPcIw)qNfRA0qJd6n89Oao1ePHmFBeqiwMVm0io9L6H(AxOVCtISSXI57t579D(Tuh7KH(EtY4i6lsrHnJ5GMnB(IjoHy7vvsJSCaj4eoPIg5VsvKdfHw3Bsi)GtnbYXsnwMiHQX6pv3UWUmvluYR9LKymr7lWFlT5R(t1TlSlXukGzfmooCloOoO34g(Eu4k2imu6lcgHX81gv0x7c9nB2d9Dy(MGZrNkAu4GMnB(IXrDkzNcI49h6GEdFpQqemwMVStSnudk91GtfenMVk4ur(sWqPV0h7Y3KWE10MMV6PqMdA2S5lgz5asWjCsfnYFLQih2j2gQbLDdovq04hCQjqoKJCtI58eLIPyniHLkASZnjYYiu7se80qET)1YNEjMI1GewQOXo3KilJqTlrWtdfqmLXOXb9g3W34vjCsfnYCqZMnFXilhqcoHtQOr(Ruf5C(VEQOoKOMw)8PJq(bNAcKt7FT8PxcgHQ6x9Oeg9X0OaIQ5uSapMNLASmbJqv9REucJ(yAKh5wQXYee11RJ1v0t0LXR9Vw(0lbrD96yDf9eDzciQMtXc8qa41(xlF6LqMWGDdMfJ6HQPnFjGOAofRJC9eBgkd8qaircewQXYee11RJ1v0t0LrJdA2S5lgz5asWjCsfnYFLQiNZ)1tf1HefY4hCQjqowQXYeSNq3HyEIqEqIcdKpEwcJqtyJk2TVF2SEaooWJ5rnrxwhIQ5uS4o2bnB28fJSCaj4eoPIg5VsvKdZ6N6SQPI4hCQjqozZgWyhluDqgNd8iheWCKDemwMiLsMa56WmgjsWCKDemwMiLsMyQ4oCmnoOzZMVyKLdibNWjv0i)vQICsPK1HOAof)GtnbYjB2ag7yHQdYIJdF8iheWCKDemwMiLsMa56WmgjsWCKDemwMiLsMa56WmgpYH5i7iySmrkLmbevZPyXDmjsut0L1HOAoflUdCNgACqZMnFXilhqcoHtQOr(Ruf5OMhHh2B)RLp9I1ZMnGr(bNAcKd5wQXYemcv1V6rjm6JPrEG4enrucJ(yAuKnBaJ8A)RLp9sWiuv)QhLWOpMgfqunNIrIeiSuJLjyeQQF1Jsy0htJ0WJCfckkbrD96y9KXscTjiojrYsnwMiHQX6pv3UWUmvluY7enrE(TE01tOfzZgWijskeuuczcd2nywmQhQM28LG4KePSzdySJfQoiloo8XtIPD1Zs2LylJjSPfCQiACqZMnFXilhqcoHtQOr(Ruf5ijup70FIsY4hCQjqoThmwzzIAIUSovI8KyAx9SKDj2YycBAbNkINcbfLqIPDX6scuWSSfmW7rIKcbfLqnHWNok7rOkZ(c7yDLvdvXYeeNKiPqqrjSl4O1DgIbrOG4KejfckkbfeR7VbLD1Vyg8zJftqCsIKcbfLqJPSReRJCnvp1OG4Kejfckkr7kFwxjluqCsIu7FT8PxcI661X6jJLeAtar1CkwGh7GEdFJxpNYYPMkY34vdKqJL57rvNreOVdZ303t48WXI5GMnB(IrwoG8jmfiMb5FO4iFtaEGeASS(PoJiqbePGi7kv0ipqyPgltquxVowxrprxgpqaZr2rWyzIukzcKRdZyoOzZMVyKLdiFctbIzq(BXAASBjmcngNd8puCKVjapqcnww)uNreOaIuqKDLkAKx2Sbm2XcvhKfhh(4roiSuJLjiQRxhRRONOlJejl1yzcI661X6k6j6Y4rE7FT8PxcI661X6k6j6YequnNIfh5ho(ONnBaJDSq1bzKv(Ma8aj0yz9tDgrGciQMtXOHePSzdySJfQoiloobGgACqVHVXBkFTleI(Mq0xSq1bz(Qom2ur(gV6OYVV55PoMVJ5l5keMV17R6drFTRS89Rg67jc99i9LHTVKmAeoOzZMVyKLdiFctbIzq(1tH9MKZrY)qXjB2ag7Y3eGhiHglRFQZicmWSzdySJfQoiJx2Sbm2XcvhKfhh(4roiSuJLjiQRxhRRONOlJeP2)A5tVee11RJ1v0t0LjGOAofJNcbfLGOUEDSUIEIUSUcbfLq(0lACqZMnFXilhq(eMceZG8puCGefs9WiuWioriZG5u8ix(MGc(mRtHGrOaIuqKDLkAKej5Bcf9)Y(PoJiqbePGi7kv0inoO3W3Jisbr2fY8LmW0Uy(sgeiTmFviOO89iqWmFvqQhI(kX0Uy(kjqFXsYCqZMnFXilhqs)jkzNDILeH8puCApySYYe1eDzDQe5jX0U6zj7sSLXezZgWyhIQ5uSajpQjJNhehtdpjM2vplzxITmMWMwWPICqZMnFXilhqsphJFg240(xlF6LG9e6oeZtekGOAofJ)HIJLASmb7j0DiMNiKNLWi0e2OID77NnRhGJd8yEwcJqtyJk2TVlhmUJ51(xlF6LG9e6oeZtekGOAoflqYJAY4j3fCJJPHx2Sbm2XcvhKX5Gd6n89(LJ5l1d9LmW0UOL5lzqGGKmqQrJ(ou(E3eDz(E)NOV27BeA(Ymiwr2LVkeuu(QKTG(MS80bnB28fJSCaj9Cm(zyJt7FT8PxcjM2fRljqbevZPy8puCApySYYe1eDzDQe51(xlF6LqIPDX6scuar1CkwGrnjVSzdySJfQoiJZbh0SzZxmYYbK0ZX4NHnoT)1YNEjKi1OrbevZPy8puCApySYYe1eDzDQe51(xlF6LqIuJgfqunNIfyutYlB2ag7yHQdY4CWb9g(EFnB(YxYCygZ3SK(YTpXcHmFjNBFIfczGme5Mey1qMVefJ488Hgk9DkFtP8lbnoOzZMVyKLdiBPw3ZMnF11dZ4VsvKJbNkiAmh0SzZxmYYbKTuR7zZMV66Hz8xPkYP9GXklJ5GMnB(IrwoGSLADpB28vxpmJ)kvroWSnPM5GEJB4B2S5lgz5asgYnjWQH8puCYMnGXowO6Gmoh4bcjM2vpynrxMqoSurJ98njpl1yzcgHQ6x9Oeg9X0i)vQICIsyu)pXcHX)jmfiMbJpfYmeovuNzWjigFkKziCQOoZGtqm(mcv1V6rjm6JPX4Nq1y9NQBxyxIPm(smTRE7hn)dfhfckkbJqkXQl)xvqCgFjM2vV9Jo(smTRE7hD8zTNagHDMbNGi)dfhjQqqrjOqMHWPI60FIskyw2cg39IpR9eWiSZm4ee5FO4irfckkbfYmeovuN(tusbZYwW4Ux8PqMHWPI6mdobrh0BCdFZMnFXilhqYqUjbwnK)HIt2Sbm2XcvhKX5apqiX0U6bRj6YeYHLkASNVj5bcl1yzcgHQ6x9Oeg9X0i)vQIC(tSqy8PqMHWPI6mdobX4tHmdHtf1zgCcIX)8T5R4tuxVowxrprxw8Ljmy3GzXOEOAAZxXpp)wQJDYqh0SzZxmYYbKTuR7zZMV66Hz8xPkYP9Vw(0lMdA2S5lgz5asir1ZMnF11dZ4VsvKt(yNHgXj)dfhWjCsfnksPK1HOAofpYB)RLp9siX0U6zj7sSLXequnNIf4bUZdewQXYesKA0ijsT)1YNEjKi1OrbevZPybEG78SuJLjKi1OrsKApySYYe1eDzDQe51(xlF6LqIPDX6scuar1CkwGh4on8aHet7QNLSlXwgtytl4uroOzZMVyKLdiHevpB28vxpmJ)kvro5JDfciZ4NzWPzCoW)qXjB2ag7yHQdYIJdF8KyAx9SKDj2YycBAbNkYbnB28fJSCajKO6zZMV66Hz8xPkYjcleoTE(i)dfNSzdySJfQoiloo8XJCqiX0U6zj7sSLXe20covepYB)RLp9siX0U6zj7sSLXequnNIf3bUZdewQXYesKA0ijsT)1YNEjKi1OrbevZPyXDG78SuJLjKi1OrsKApySYYe1eDzDQe51(xlF6LqIPDX6scuar1CkwCh4onKibcWjCsfnksPK1HOAofnoOzZMVyKLdiBPw3ZMnF11dZ4VsvKtewiCA8Zm40moh4FO4KnBaJDSq1bzCoqIeiaNWjv0OiLswhIQ5uoOoO34g(EF)rXxUqazMdA2S5lMiFSRqazgNMoPpvuNDLYNoJ)HIt2Sbm2XcvhKfiNJDqZMnFXe5JDfciZilhq20j9PI6SRu(0z8puCYMnGXowO6GmohjpjM2vpynrxMGI(tusu2TegHgloobWbnB28ftKp2viGmJSCaj9NOKD2jwseY)qXXsnwMqHaYSPI6ShImEKlX0U6bRj6Yeu0FIsIYULWi0yCYMnGXowO6GmsKKyAx9G1eDzck6prjrz3syeAS44eaAirYsnwMqHaYSPI6ShImEwQXYenDsFQOo7kLpDgpjM2vpynrxMGI(tusu2TegHgloohCqZMnFXe5JDfciZilhqkX0U6TF08puCixHGIsWiKsS6Y)vfqmBgjsGaCcNurJIZ)1tf1He106NpDesdpYviOOeYegSBWSyupunT5lbXjpirHupmcfsmL6bzwV9JMx2Sbm2XcvhKfiNaqIu2Sbm2XcvhKXHpACqZMnFXe5JDfciZilhqINJevNg)dfhirnT(5thHcjsnTXcK8dCNSsmTREWAIUmbf9NOKOSBjmcnw8ma0WtIPD1dwt0LjOO)eLeLDlHrOXc8i5bcWjCsfnko)xpvuhsutRF(0rijskeuucg9eQovuxDyMG40bnB28ftKp2viGmJSCajEosuDA8puCGe106NpDekKi10glq(oMNet7QhSMOltqr)jkjk7wcJqJf3X8ab4eoPIgfN)RNkQdjQP1pF6i0bnB28ftKp2viGmJSCajEosuDA8puCaHet7QhSMOltqr)jkjk7wcJqJXdeGt4KkAuC(VEQOoKOMw)8PJqsKOMOlRdr1CkwGhtIemhzhbJLjsPKjqUomJXdMJSJGXYePuYequnNIf4XoOzZMVyI8XUcbKzKLdiP)eLSZoXsIqh0SzZxmr(yxHaYmYYbK45ir1PX)qXbeGt4KkAuC(VEQOoKOMw)8PJqhuh0BCdFVV)O4BiAeNoOzZMVyI8XodnItozfRllj)dfhjM2vpynrxMGI(tusu2TegHglooTynn2XcvhKrIKet7QhSMOltqr)jkjk7wcJqJfhNJjrcewQXYekeqMnvuN9qKrIemhzhbJLjsPKjqUomJXdMJSJGXYePuYequnNIfiNdhirIAIUSoevZPybY5Wbh0SzZxmr(yNHgXjz5asjM2vV9JM)HIdiaNWjv0O48F9urDirnT(5thH8ixHGIsityWUbZIr9q10MVeeN8Gefs9WiuiXuQhKz92pAEzZgWyhluDqwGCcajszZgWyhluDqgh(OXbnB28ftKp2zOrCswoGephjQon(hkoGaCcNurJIZ)1tf1He106NpDe6GMnB(IjYh7m0iojlhqsHmdHtf1zgCcI83I10y3syeAmoh4FO4irfckkbfYmeovuN(tusbZYwWa5eaET)1YNEjYZVL6yNmuar1CkwGbWbnB28ftKp2zOrCswoGKczgcNkQZm4ee5VfRPXULWi0yCoW)qXrIkeuuckKziCQOo9NOKcMLTGbEWbnB28ftKp2zOrCswoGKczgcNkQZm4ee5VfRPXULWi0yCoW)qXbsuOWgvSBF)EbsE7FT8PxcjM2vplzxITmMaIQ5umEGWsnwMqIuJgjrQ9Vw(0lHePgnkGOAofJNLASmHePgnsIu7bJvwMOMOlRtLiV2)A5tVesmTlwxsGciQMtXOXb9g(E)UWYxlHrO5lJEEY8nHOVYHLkAuYVV21W8L(O1(QrZ3ypHVStSK(cjkKbs6prjz(ofZWu67t5l9CSPI8L6H(sgfzasYaPgncsYat7IwMVKbbkCqZMnFXe5JDgAeNKLdiP)eLSZoXsIq(hkoKdcgA2urmrlwtJKijX0U6bRj6Yeu0FIsIYULWi0yXXPfRPXowO6GmA4jrfckkbfYmeovuN(tusbZYwW4capirHcBuXU99aey7FT8PxISI1LLuar1CkMdQd6nUHVh13MVCqZMnFXeT)1YNEX4C(28f)dfhWjCsfnkuZJWd7T)1YNEX6zZgWijsNOjIsy0htJISzdyK3jAIOeg9X0OaIQ5uSa5W3rsIe1eDzDiQMtXcKVJ0b9g3W3B(Vw(0lMdA2S5lMO9Vw(0lgz5aYeQgR)uD7c7smL8puCA)RLp9squxVowxrprxMaIQ5uSa5g8A)RLp9sityWUbZIr9q10MVequnNI1rUEIndLbYn4zPgltquxVowxrprxgpYB)RLp9sKNFl1XozOaIQ5uSoY1tSzOmqUbpWjCsfnkOi06EtcjrceGt4KkAuqrO19MesdjsGWsnwMGOUEDSUIEIUmsKuEgJh1eDzDiQMtXcmah7GMnB(IjA)RLp9IrwoGK9e6oeZteYFlwtJDlHrOX4CG)HIJLWi0e2OID77NnRhGJd8yEwcJqtyJk2TVlhmUJ5LnBaJDSq1bzbYjaoO3W3J2VwY8Ll6j6Y8L6H(sC6R9(ESVmS9LK5R9(YIvnFPp2LV3353sDStgYVVCB7cH0hgYVVem0x6JD5lzKWG(Elmlg1dvtB(s4GMnB(IjA)RLp9IrwoGKOUEDSUIEIUm(hkoGt4KkAuWS(PoRAQiEK3(xlF6Lip)wQJDYqbevZPyDKRNyZqzGhtIu7FT8PxI88BPo2jdfqunNI1rUEIndLXDG70WJ82)A5tVeYegSBWSyupunT5lbevZPybg1KKiPqqrjKjmy3GzXOEOAAZxcItACqZMnFXeT)1YNEXilhqsuxVowxrprxg)dfhWjCsfnksPK1HOAofjskpJXJAIUSoevZPybY3bh0SzZxmr7FT8PxmYYbKmcv1V6rjm6JPr(1tH9MKtaosUZD(hkoqIAA9ZNocfsKAAJf4H7XR9Vw(0lbrD96yDf9eDzciQMtXc8qa41(xlF6LqMWGDdMfJ6HQPnFjGOAoflWdbWbnB28ft0(xlF6fJSCaPmHb7gmlg1dvtB(I)HId4eoPIgfmRFQZQMkIh5Y3ee11RJ1v0t0L1LVjGOAofJejqyPgltquxVowxrprxgnoOzZMVyI2)A5tVyKLdiLjmy3GzXOEOAAZx8puCaNWjv0OiLswhIQ5uKiP8mgpQj6Y6qunNIfiFhCqZMnFXeT)1YNEXilhqMNFl1Xozi)dfNSzdySJfQoiJZbEsuHGIsqHmdHtf1P)eLuWSSfmoo3Jh5GaCcNurJckcTU3KqsKaNWjv0OGIqR7njKh5T)1YNEjiQRxhRRONOltar1CkwCh4ojsT)1YNEjKjmy3GzXOEOAAZxciQMtX6ixpXMHY4oWDEGWsnwMGOUEDSUIEIUmAOXbnB28ft0(xlF6fJSCazE(Tuh7KH83I10y3syeAmoh4FO4KnBaJDSq1bzXXHpEsuHGIsqHmdHtf1P)eLuWSSfmUaWdesmTREwYUeBzmHnTGtf5GMnB(IjA)RLp9IrwoGKrOQ(vpkHrFmnY)qXbsutRF(0rOqIutBSapCpET)1YNEjiQRxhRRONOltar1CkwGhcaV2)A5tVeYegSBWSyupunT5lbevZPyDKRNyZqzGhcGdA2S5lMO9Vw(0lgz5asI661X6jJLeAJ)HId4eoPIgfmRFQZQMkINeviOOeuiZq4urD6prjfmlBbdKpEKFIMip)wp66j0ISzdyKejfckkHmHb7gmlg1dvtB(sqCYR9Vw(0lrE(Tuh7KHciQMtXI7a3jrQ9Vw(0lrE(Tuh7KHciQMtXI7a351(xlF6LqMWGDdMfJ6HQPnFjGOAoflUdCNgh0SzZxmr7FT8PxmYYbKe11RJ1tglj0g)Tynn2TegHgJZb(hkozZgWyhluDqwCC4JNeviOOeuiZq4urD6prjfmlBbdKpEKFIMip)wp66j0ISzdyKejfckkHmHb7gmlg1dvtB(sqCsIu7FT8PxcjM2vplzxITmMaIQ5uSaJAsACqZMnFXeT)1YNEXilhqcZHHDjMs(hkoG4enr01tOfzZgWOd6nUHVKXWsfnk533JabZ8TEZxiMADmFRhQMAFvWRe88qFTR0OL5l9hAx(Esazetf57uXJOuffoO34g(MnB(IjA)RLp9IrwoGKLn4qnTj19ZSz8puCYMnGXowO6GS44WhpqOqqrjKjmy3GzXOEOAAZxcItET)1YNEjKjmy3GzXOEOAAZxciQMtXI7ysKuEgJh1eDzDiQMtXcmQjDqDqVXn89MpySYY89(ug9ydYCqZMnFXeThmwzzmom6juDQOU6Wm(hkoGt4KkAuWS(PoRAQiEqIAA9ZNocfsKAAJf3HJKh5T)1YNEjYZVL6yNmuar1CkgjsGWsnwMiHQX6pv3UWUmvluYR9Vw(0lHmHb7gmlg1dvtB(sar1CkgnKiP8mgpQj6Y6qunNIf4HdoO3W3q081EFjyOVjLHqFZZV57W89lFVjz4BY81EFpHiySmFFWiSLNNtf57r8O6l9RrJ(YqZMkYxItFVjzqlZbnB28ft0EWyLLXilhqYONq1PI6QdZ4FO40(xlF6Lip)wQJDYqbevZPy8ipB2ag7yHQdYIJdF8YMnGXowO6GSa5CmpirnT(5thHcjsnTXI7a3jl5zZgWyhluDqw88iPHh4eoPIgfPuY6qunNIePSzdySJfQoilUJ5bjQP1pF6iuirQPnwC3J704GMnB(IjApySYYyKLditLxDQ0MV66rvH)HId4eoPIgfmRFQZQMkIhiypHwzkPqJPSReRJCnvp1ipYB)RLp9sKNFl1XozOaIQ5umsKaHLASmrcvJ1FQUDHDzQwOKx7FT8Pxczcd2nywmQhQM28LaIQ5umA4bjkuyJk2TVFV4uiOOeqIAA92dHeN28LaIQ5umsKuEgJh1eDzDiQMtXcKVdoOzZMVyI2dgRSmgz5aYu5vNkT5RUEuv4FO4aoHtQOrbZ6N6SQPI4XEcTYusHgtzxjwh5AQEQrEKlFtquxVowxrprxwx(MaIQ5uS4oCGejqyPgltquxVowxrprxgV2)A5tVeYegSBWSyupunT5lbevZPy04GMnB(IjApySYYyKLditLxDQ0MV66rvH)HId4eoPIgfmRFQZQMkIh7j0ktjfbrWtX6)F)H6PI4jrfckkbfYmeovuN(tusbZYwW44Cph0SzZxmr7bJvwgJSCazQ8QtL28vxpQk8puCaNWjv0OiLswhIQ5u8GefkSrf723VxCkeuucirnTE7HqItB(sar1CkMdA2S5lMO9GXklJrwoGKDLTGASBxyNOO)q7kg)dfhWjCsfnkyw)uNvnvepYB)RLp9sKNFl1XozOaIQ5uS4oWDsKaHLASmrcvJ1FQUDHDzQwOKx7FT8Pxczcd2nywmQhQM28LaIQ5umAirs5zmEut0L1HOAoflWdh7GMnB(IjApySYYyKLdizxzlOg72f2jk6p0UIX)qXbCcNurJIukzDiQMtXJCjM2vplzxITmMWMwWPIircMJSJGXYePuYequnNIfiNd3Jgh0SzZxmr7bJvwgJSCajLgzxnysz8puCypHwzkP4KGzeASJqItB(Yb1b9g3W3WPI0OV3MWi0CqZMnFXeryHWPXrIPD1B)O5FO4acWjCsfnko)xpvuhsutRF(0ripYviOOemcPeRU8FvbeZMrIeKOMw)8PJqHePM2ybY5qaOHePt0erjm6JPrr2SbmYdsuyGCcajsut0L1HOAoflWdCNhiKOcbfLGczgcNkQt)jkPG40bnB28fteHfcNgz5aYSI1LLK)HId5wQXYesKA0OaRurJssKApySYYe1eDzDQejrcsui1dJqX5fMWx9lKrdpYbb4eoPIgfN)RNkQdjkKrIKYZy8OMOlRdr1CkwGhtJdA2S5lMicleonYYbK0FIs2zNyjri)dfhWjCsfnkKeQND6prjz8KOcbfLGczgcNkQt)jkPGzzlyCCoWR9Vw(0lrE(Tuh7KHciQMtX6ixpXMHY4oMhiaNWjv0O48F9urDirHmh0SzZxmrewiCAKLdiP)eLSZoXsIq(hkosuHGIsqHmdHtf1P)eLuWSSfmUaWdeGt4KkAuC(VEQOoKOqgjssuHGIsqHmdHtf1P)eLuqCYJAIUSoevZPybsUeviOOeuiZq4urD6prjfmlBbJNrnjnoOzZMVyIiSq40ilhqkX0U6TF08puCGe106NpDekKi10glqo8XDEGaCcNurJIZ)1tf1He106NpDe6GMnB(IjIWcHtJSCajfYmeovuNzWjiY)qXrIkeuuckKziCQOo9NOKcMLTGbEpEGaCcNurJIZ)1tf1HefYCqZMnFXeryHWPrwoGuIPD1B)O5FO4acWjCsfnko)xpvuhsutRF(0rOdA2S5lMicleonYYbK0FIs2zNyjri)dfhjQqqrjOqMHWPI60FIskyw2cghNd8GefgiF8ab4eoPIgfN)RNkQdjkKXR9Vw(0lrE(Tuh7KHciQMtX6ixpXMHY4o2b1b9g3W34fSq4089((JIVhv48WXI5GMnB(IjIWcHtRNpYHEog)mSXP9Vw(0lb7j0DiMNiuar1Ckg)dfhl1yzc2tO7qmpriplHrOjSrf723pBwpahh4X8OMOlRdr1CkwChZR9Vw(0lb7j0DiMNiuar1CkwGKh1KXtUl4ghtdVSzdySJfQoilqobWbnB28fteHfcNwpFKSCaPet7Q3(rZ)qXHCqaoHtQOrX5)6PI6qIAA9ZNocjrsHGIsWiKsS6Y)vfqmBgn8ixHGIsityWUbZIr9q10MVeeN8Gefs9WiuiXuQhKz92pAEzZgWyhluDqwGCcajszZgWyhluDqgh(OXbnB28fteHfcNwpFKSCajEosuDA8puCuiOOemcPeRU8FvbeZMrIeiaNWjv0O48F9urDirnT(5thHoO3W34nLVwcJqZ3wSMEQiFhMVYHLkAuYVVm6J1U8vjBb91EFTl0x2urAmEyjmcnFJWcHtZx9WmFNIzykfoOzZMVyIiSq4065JKLdiHevpB28vxpmJ)kvroryHWPXpZGtZ4CG)HItlwtJDSq1bzCo4GMnB(IjIWcHtRNpswoGK(tuYo7eljc5VfRPXULWi0yCoW)qXH82)A5tVe553sDStgkGOAoflUJ5jrfckkbfYmeovuN(tusbXjjssuHGIsqHmdHtf1P)eLuWSSfmUaqdpYPMOlRdr1CkwGT)1YNEjKyAx9SKDj2YyciQMtXi7bUtIe1eDzDiQMtXIR9Vw(0lrE(Tuh7KHciQMtXOXbnB28fteHfcNwpFKSCajfYmeovuNzWjiYFlwtJDlHrOX4CG)HIJeviOOeuiZq4urD6prjfmlBbdKta41(xlF6Lip)wQJDYqbevZPybEmjssuHGIsqHmdHtf1P)eLuWSSfmWdoOzZMVyIiSq4065JKLdiPqMHWPI6mdobr(BXAASBjmcngNd8puCA)RLp9sKNFl1XozOaIQ5uS4oMNeviOOeuiZq4urD6prjfmlBbd8Gd6n892RH57W8fPOWMnGrDmFPgTgH(s)AAx(YgvMVKXrn03cjmyQ53xfcZx21tOL(EcrWyz(M(YAyLW59L(fcrFTl03uk)Y3RK5B921ur(AVVqS9QQyjfoOzZMVyIiSq4065JKLdiPqMHWPI6mdobr(hkozZgWyx(MGczgcNkQt)jkzCCAXAASJfQoiJNeviOOeuiZq4urD6prjfmlBbd8EoOoO3W3Jy2MuZCqZMnFXeWSnPMXjHTSWU9qiwg)dfhirnT(5thHcjsnTXI7ipMh5NOjIsy0htJISzdyKejqyPgltWiuv)QhLWOpMgfyLkAusdpirHcjsnTXIJZXoOzZMVycy2MuZilhqQO)x2PiGX4FO4aoHtQOrHAEeEyV9Vw(0lwpB2agjr6enrucJ(yAuKnBaJ8orteLWOpMgfqunNIfihfckkHI(FzNIagtijGPnFrIKYZy8OMOlRdr1CkwGCuiOOek6)LDkcymHKaM28LdA2S5lMaMTj1mYYbKkiKHWGtfX)qXbCcNurJc18i8WE7FT8PxSE2SbmsI0jAIOeg9X0OiB2ag5DIMikHrFmnkGOAoflqokeuucfeYqyWPIescyAZxKiP8mgpQj6Y6qunNIfihfckkHcczim4urcjbmT5lh0SzZxmbmBtQzKLdi1t0LX6hbczKkwg)dfhfckkbrD96yDMbXkYUeeNoO3W37RAiZGP23BMATVTS81Gtuec99E(E(gw2KAFviOOy87lMTlF1jZMkY3dh7ldBFjzcFpASrp3FO03Rek9T9su6RnQOVjZ30xdorri0x79niIN(oMVqmLPIgfoOzZMVycy2MuZilhqMvdzgm19wQ18puCaNWjv0OqnpcpS3(xlF6fRNnBaJKiDIMikHrFmnkYMnGrENOjIsy0htJciQMtXcKZHJjrs5zmEut0L1HOAoflqoho2bnB28ftaZ2KAgz5aYe2Yc7NeAgY)qXjB2ag7yHQdYIJdFKiroKOqHePM2yXX5yEqIAA9ZNocfsKAAJfhNJK704GMnB(IjGzBsnJSCaj1arf9)s(hkoGt4KkAuOMhHh2B)RLp9I1ZMnGrsKorteLWOpMgfzZgWiVt0erjm6JPrbevZPybYrHGIsqnqur)VuijGPnFrIKYZy8OMOlRdr1CkwGCuiOOeudev0)lfscyAZxoOzZMVycy2MuZilhqQKr9NQBWPfKX)qXjB2ag7yHQdY4CGh5keuucI661X6mdIvKDjiojrs5zmEut0L1HOAoflWJPXb1b9g3W3BHtfenMdA2S5lMWGtfenghcg2hdv5VsvKZuSgKWsfn25MezzeQDjcEAi)dfhYB)RLp9squxVowxrprxMaIQ5uS44J7Ki1(xlF6LqMWGDdMfJ6HQPnFjGOAofRJC9eBgkJJpUtdpYZMnGXowO6GS44WhjsNOjsOASE01tOfzZgWijsNOjYZV1JUEcTiB2ag5rULASmbrD96y9KXscTrIKet7QhSMOltihwQOXE(MKgsKorteLWOpMgfzZgWinKiP8mgpQj6Y6qunNIfiFhirYsyeAcBuXU99ZM15J7bESd6n892l0xdovq08L(yx(AxOVxt0fYmFrMnQPHsFbNAcKFFPpATVkOVemu6l1azMVzj99mhik9L(yx(EFNFl1XozOVKpu(Qqqr57W89WX(YW2xsMVp0xnYy047d9Ll6j6YajzCRVKpu(gbX0qOV2vw(E4yFzy7ljJgh0SzZxmHbNkiAmYYbKgCQGODG)HIdiaNWjv0OGDITHAqz3GtfenEKtUbNkiAIdcfckQUKaM28vGCoCmV2)A5tVe553sDStgkGOAoflo(4ojsgCQGOjoiuiOO6scyAZxXD4yEK3(xlF6LGOUEDSUIEIUmbevZPyXXh3jrQ9Vw(0lHmHb7gmlg1dvtB(sar1Ckwh56j2mughFCNgsKYMnGXowO6GS44WhpfckkHmHb7gmlg1dvtB(sqCsdpYbHbNkiAc(exjR3(xlF6fjsgCQGOj4t0(xlF6LaIQ5umsKaNWjv0OWGtfeT(jCE4yX4CGgAirYGtfenXbHcbfvxsatB(koout0L1HOAofZbnB28ftyWPcIgJSCaPbNkiA8X)qXbeGt4KkAuWoX2qnOSBWPcIgpYj3GtfenbFcfckQUKaM28vGCoCmV2)A5tVe553sDStgkGOAoflo(4ojsgCQGOj4tOqqr1LeW0MVI7WX8iV9Vw(0lbrD96yDf9eDzciQMtXIJpUtIu7FT8Pxczcd2nywmQhQM28LaIQ5uSoY1tSzOmo(4onKiLnBaJDSq1bzXXHpEkeuuczcd2nywmQhQM28LG4KgEKdcdovq0ehexjR3(xlF6fjsgCQGOjoiA)RLp9sar1CkgjsGt4KkAuyWPcIw)eopCSyC4JgAirYGtfenbFcfckQUKaM28vCCOMOlRdr1CkMd6n8nEt57x6y((f67x(sWqFn4ubrZ3t4dEKiZ30xfckk(9LGH(AxOVVDHqF)Y32)A5tVe(YTH(ou(w4yxi0xdovq089e(GhjY8n9vHGIIFFjyOVkVD57x(2(xlF6LWbnB28ftyWPcIgJSCaPbNkiAh4FO4acdovq0ehexjRtWWUcbffpYn4ubrtWNO9Vw(0lbevZPyKibcdovq0e8jUswNGHDfckkACqZMnFXegCQGOXilhqAWPcIgF8puCaHbNkiAc(exjRtWWUcbffpYn4ubrtCq0(xlF6LaIQ5umsKaHbNkiAIdIRK1jyyxHGIIgGWKWUEiqy4OsOtB(6MWKYamadaaa]] )


end
