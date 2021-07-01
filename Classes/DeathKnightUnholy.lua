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


    spec:RegisterPack( "Unholy", 20210701, [[de1GUcqivQ6rQq6sQurTjuLpHKAuifNcP0QKsrEfssZcvv3skfSlc)ciAyOs1XubldvLNjannKeUMkuBtfI(gqqJdvkLZHkLQ1jLsVtkfvzEcO7Hk2NuQoiqGfIkXdvPstei0fvPc2iQuO(OukkJuLksDsviyLaPxQsfjZejr3ukfv1ovP0pLsHgQkvOLQcHEQGMQkfxvLkITkLIkFfvkyScG9c4Vs1Gv6WIwmjESqtMOldTze9zPy0QKtRy1OsjVwGMnPUnjTBj)wvdxfDCuPOLd65OmDkxhHTduFhPA8Os68sjRhvkK5Je7NQboaCdqOmne4w(4oFh4oiK7heCheECad4rceATorGWZmgmBqGWkvrGW7K661TacpZw6pLa3aeYEcyebcVm7K1wqcYMXUiueXxfKSrLqN28veMKgizJAeKaHkeJ2ocfGcqOmne4w(4oFh4oiK7heChesfC7bKBhiKDIrGB57y(acVgPelafGqjYIaHGiM2LV3PQP5Y89oPUEDlhuqj0T89a)(Yh357GdQd6DVYQbzT1bTn4liqYTiyMkwgZx79felqeKGisoAeKGiM2fZxqKa91EF)s3Y34tuMVwcBqJ5l9R33eI(IC9eJgk91EF1dy0x9xn(I1t0C5R9(QMMHqFPjFSZqJ403JEGwHdABWxqCyPIgL(gMr4qoXj1(EhZO5Rcgtcg6RetPVnxpHM5RAge9L8H(YsPVG4DkMWbTn47DcBQgF5gEIs6B4jwse6BQm6XgK5R6drFj1ixhfDlFPjnFPcQ6lZYyqMVtXmmL((K(EmvPTnpFbX7yOVfsyWu7BwsFvZw(EcrWyz(YEv036Bdqm6lBmI0MVych02GV3jSPA8LBmYmeovJVHgCcI(oLVGG24DW3H03wpHVxjy036TRPA8f1m0x79v((ML0x6FrT57dgHX80x6prjz(omFbX7yOVfsyWulCqBd(E3RSAqPVQz1YxQjNMlRdr1Ckg1(g)so28vQz(AVV55PULVt5RYZy(sonxgZ3V0T8LgnYy(Exq0x6jZqF)YxdMSlAfoOTbFbbsjk9nR3UqOVTrctbIzqFXYGT81EFzO5lXPVmd(vdc99oCosuDImHdABW3JiQtU6B4n(cMj8fe0gVd(Q)Mj6lBQi67y(cr9GmF)Y34xKPcHonu6lmhzhbJLXeoOTbFVPncITX26RVCJZO9qFdniwn2LVNWpY8Dk791GtfenF1FZefaH6HzmGBacZh7m0iobUb42da3aeIvQOrjaxacJWXq4KaHsmTREWAAUmbj9NOKOSBjSbnMVTZX3yROg7yHQdY8LcfFLyAx9G10Czcs6prjrz3sydAmFBNJVh7lfk(EVVwQXYekeqMnvtN9qKjWkv0O0xku8fMJSJGXYePuYeixhMX8LNVWCKDemwMiLsMaIQ5umFdKJVho4lfk(sonxwhIQ5umFdKJVhoaeMrB(cimRwDzjbmGB5d4gGqSsfnkb4cqyeogcNei8EFbNWjv0O48F9unDirnX(5thH(YZxA8vHGKuityWUbZIr(q10MVeeN(YZxirHKpSbfsmL6bzwp(JwGvQOrPV88nJ2ag7yHQdY8nqo(gqFPqX3mAdySJfQoiZxo(YNV0ceMrB(ciuIPD1J)ObmGBdiWnaHyLkAucWfGWiCmeojq49(coHtQOrX5)6PA6qIAI9ZNocbcZOnFbeINJevNiGbClvaCdqiwPIgLaCbimchdHtcekrfcssbjYmeovtN(tusbZYyqFdKJVb0xE(g)xlF6Lip)yQBDYqbevZPy(gOVbeimJ28fqijYmeovtNzWjicegBf1y3sydAmGBpaya3EmWnaHyLkAucWfGWiCmeojqOeviijfKiZq4unD6prjfmlJb9nqFpaeMrB(ciKezgcNQPZm4eebcJTIASBjSbngWThamGBpsGBacXkv0OeGlaHr4yiCsGqirHcBuXU9DQW3a9LgFJ)RLp9siX0U6zj7smMTequnNI5lpFV3xl1yzcjsoAuGvQOrPVuO4B8FT8PxcjsoAuar1CkMV881snwMqIKJgfyLkAu6lfk(gFWyLLjQP5Y6Kj6lpFJ)RLp9siX0UyDjbkGOAofZxAbcZOnFbesImdHt10zgCcIaHXwrn2Te2Ggd42dagWTGqGBacXkv0OeGlaHr4yiCsGqA89EFzOzt1WeXwrn6lfk(kX0U6bRP5YeK0FIsIYULWg0y(2ohFJTIASJfQoiZxA9LNVsuHGKuqImdHt10P)eLuWSmg0329nG(YZxirHcBuXU99a6BG(g)xlF6LiRwDzjfqunNIbeMrB(ciK(tuYo7eljcbcLilcNtB(ciKB4clFTe2GMVm65jZ3eI(khwQOrj)(AxdZx6Jw7RgnFB9e(YoXs6lKOqgiP)eLK57umdtPVpPV0ZXMQXxYh6liwGiibrKC0iibrmTlQz(cIeOaWamGW8XUcbKza3aC7bGBacXkv0OeGlaHr4yiCsGWmAdySJfQoiZ3a547XaHz0MVacJ6K(unD2vkF6mad4w(aUbieRurJsaUaegHJHWjbcZOnGXowO6GmF547r6lpFLyAx9G10Czcs6prjrz3sydAmFBNJVbeimJ28fqyuN0NQPZUs5tNbya3gqGBacXkv0OeGlaHr4yiCsGql1yzcfciZMQPZEiYeyLkAu6lpFPXxjM2vpynnxMGK(tusu2Te2GgZxo(MrBaJDSq1bz(sHIVsmTREWAAUmbj9NOKOSBjSbnMVTZX3a6lT(sHIVwQXYekeqMnvtN9qKjWkv0O0xE(APglte1j9PA6SRu(0zcSsfnk9LNVsmTREWAAUmbj9NOKOSBjSbnMVTZX3daHz0MVacP)eLSZoXsIqad4wQa4gGqSsfnkb4cqyeogcNeiKgFviijfmcPeRU8FvbeZO5lfk(EVVGt4KkAuC(VEQMoKOMy)8PJqFP1xE(sJVkeKKczcd2nywmYhQM28LG40xE(cjkK8HnOqIPupiZ6XF0cSsfnk9LNVz0gWyhluDqMVbYX3a6lfk(MrBaJDSq1bz(YXx(8LwGWmAZxaHsmTRE8hnGbC7Xa3aeIvQOrjaxacJWXq4KaHqIAI9ZNocfsKCIJ5BG(sJVh4UVu1xjM2vpynnxMGK(tusu2Te2GgZ32KVb0xA9LNVsmTREWAAUmbj9NOKOSBjSbnMVb67r6lpFV3xWjCsfnko)xpvthsutSF(0rOVuO4RcbjPGrpHQt10vhMjiobcZOnFbeINJevNiGbC7rcCdqiwPIgLaCbimchdHtcecjQj2pF6iuirYjoMVb6lFh7lpFLyAx9G10Czcs6prjrz3sydAmFB33J9LNV37l4eoPIgfN)RNQPdjQj2pF6ieimJ28fqiEosuDIagWTGqGBacXkv0OeGlaHr4yiCsGW79vIPD1dwtZLjiP)eLeLDlHnOX8LNV37l4eoPIgfN)RNQPdjQj2pF6i0xku8LCAUSoevZPy(gOVh7lfk(cZr2rWyzIukzcKRdZy(YZxyoYocgltKsjtar1CkMVb67XaHz0MVacXZrIQteWaULBd4gGWmAZxaH0FIs2zNyjriqiwPIgLaCbWaULBh4gGqSsfnkb4cqyeogcNei8EFbNWjv0O48F9unDirnX(5thHaHz0MVacXZrIQteWamGqdovq0ya3aC7bGBacXkv0OeGlaHvQIaHtXIqclv0yNBsKLrO2Li4jIaHz0MVacNIfHewQOXo3KilJqTlrWtebcJWXq4KaH04B8FT8PxcI661T6k6P5YequnNI5B7(Yh39LcfFJ)RLp9sityWUbZIr(q10MVequnNI1rUEIrdL(2UV8XDFP1xE(sJVz0gWyhluDqMVTZXx(8LcfFprtKq1w9MRNqlYOnGrFPqX3t0e55h7nxpHwKrBaJ(YZxA81snwMGOUEDREYyjH2eyLkAu6lfk(kX0U6bRP5YeYHLkASNVj9LwFPqX3t0enjS5BPrrgTbm6lT(sHIVkpJ5lpFjNMlRdr1CkMVb6lFh8LcfFTe2GMWgvSBF)mAD(4UVb67XagWT8bCdqiwPIgLaCbimchdHtceEVVGt4KkAuWoX4qoOSBWPcIMV88LgFPXxdovq0e2bHcbjzxsatB(Y3a547HJ9LNVX)1YNEjYZpM6wNmuar1CkMVT7lFC3xku81GtfenHDqOqqs2LeW0MV8TDFpCSV88LgFJ)RLp9squxVUvxrpnxMaIQ5umFB3x(4UVuO4B8FT8Pxczcd2nywmYhQM28LaIQ5uSoY1tmAO0329LpU7lT(sHIVz0gWyhluDqMVTZXx(8LNVkeKKczcd2nywmYhQM28LG40xA9LNV0479(AWPcIMW4tCLSE8FT8Px(sHIVgCQGOjm(eX)1YNEjGOAofZxku8fCcNurJcdovq06NW5HJ1Yxo(EWxA9LwFPqXxdovq0e2bHcbjzxsatB(Y3254l50CzDiQMtXacZOnFbeAWPcI2bGqjYIW50MVacV5c91GtfenFPp2LV2f6710CHmZxKzJAAO0xWPMa53x6Jw7Rc6lbdL(soqM5BwsFpZbIsFPp2LVGGZpM6wNm0xAgsFviij9Dy(E4yFzy8ljZ3h6RgzmA99H(Yf90CzGeeVXxAgsFBGyAi0x7klFpCSVmm(LKrlGbCBabUbieRurJsaUaegHJHWjbcV3xWjCsfnkyNyCihu2n4ubrZxE(sJV04RbNkiAcJpHcbjzxsatB(Y3a547HJ9LNVX)1YNEjYZpM6wNmuar1CkMVT7lFC3xku81GtfenHXNqHGKSljGPnF5B7(E4yF55ln(g)xlF6LGOUEDRUIEAUmbevZPy(2UV8XDFPqX34)A5tVeYegSBWSyKpunT5lbevZPyDKRNy0qPVT7lFC3xA9LcfFZOnGXowO6GmFBNJV85lpFviijfYegSBWSyKpunT5lbXPV06lpFPX3791GtfenHDqCLSE8FT8Px(sHIVgCQGOjSdI4)A5tVequnNI5lfk(coHtQOrHbNkiA9t48WXA5lhF5ZxA9LwFPqXxdovq0egFcfcsYUKaM28LVTZXxYP5Y6qunNIbeMrB(ci0Gtfen(amGBPcGBacXkv0OeGlaHr4yiCsGW791GtfenHDqCLSobd7keKK(YZxA81GtfenHXNi(Vw(0lbevZPy(sHIV37RbNkiAcJpXvY6emSRqqs6lTaHz0MVacn4ubr7aqOezr4CAZxaHhbsF)s3Y3VqF)Yxcg6RbNkiA(EcFWJez(M(QqqsYVVem0x7c99Tle67x(g)xlF6LW32i03H03ch7cH(AWPcIMVNWh8irMVPVkeKK87lbd9v5TlF)Y34)A5tVeagWThdCdqiwPIgLaCbimchdHtceEVVgCQGOjm(exjRtWWUcbjPV88LgFn4ubrtyheX)1YNEjGOAofZxku89EFn4ubrtyhexjRtWWUcbjPV0ceMrB(ci0Gtfen(amadiSbleorGBaU9aWnaHyLkAucWfGWiCmeojq49(coHtQOrX5)6PA6qIAI9ZNoc9LNV04RcbjPGriLy1L)RkGygnFPqXxirnX(5thHcjsoXX8nqo(EiG(sRVuO47jAIMe28T0OiJ2ag9LNVqIc9nqo(gqFPqXxYP5Y6qunNI5BG(EG7(YZ379vIkeKKcsKziCQMo9NOKcItGWmAZxaHsmTRE8hnGbClFa3aeIvQOrjaxacJWXq4KaH04RLASmHejhnkWkv0O0xku8n(GXkltutZL1jt0xku8fsui5dBqX5fMWx9lKjWkv0O0xA9LNV0479(coHtQOrX5)6PA6qIcz(sHIVkpJ5lpFjNMlRdr1CkMVb67X(slqygT5lGWSA1LLeWaUnGa3aeIvQOrjaxacJWXq4KaHGt4KkAuOMCRh2pHFK1ZOnGrF55ReviijfKiZq4unD6prjfmlJb9TDo(EWxE(g)xlF6Lip)yQBDYqbevZPyDKRNy0qPVT77X(YZ379fCcNurJIZ)1t10HefYacZOnFbes)jkzNDILeHagWTubWnaHyLkAucWfGWiCmeojqOeviijfKiZq4unD6prjfmlJb9TDFdOV889EFbNWjv0O48F9unDirHmFPqXxjQqqskirMHWPA60FIskio9LNVKtZL1HOAofZ3a9LgFLOcbjPGezgcNQPt)jkPGzzmOVTjFBIsFPfimJ28fqi9NOKD2jwsecya3EmWnaHyLkAucWfGWiCmeojqiKOMy)8PJqHejN4y(gihF5J7(YZ379fCcNurJIZ)1t10He1e7NpDeceMrB(ciuIPD1J)ObmGBpsGBacXkv0OeGlaHr4yiCsGqjQqqskirMHWPA60FIskywgd6BG(sf(YZ379fCcNurJIZ)1t10HefYacZOnFbesImdHt10zgCcIagWTGqGBacXkv0OeGlaHr4yiCsGW79fCcNurJIZ)1t10He1e7NpDeceMrB(ciuIPD1J)ObmGB52aUbieRurJsaUaegHJHWjbcLOcbjPGezgcNQPt)jkPGzzmOVTZX3d(YZxirH(gOV85lpFV3xWjCsfnko)xpvthsuiZxE(g)xlF6Lip)yQBDYqbevZPyDKRNy0qPVT77XaHz0MVacP)eLSZoXsIqadWacJpySYYya3aC7bGBacXkv0OeGlaHr4yiCsGqWjCsfnkyw)uNvnvJV88fsutSF(0rOqIKtCmFB33dhPV88LgFJ)RLp9sKNFm1TozOaIQ5umFPqX3791snwMiHQT6pz3UWUmvlukWkv0O0xE(g)xlF6LqMWGDdMfJ8HQPnFjGOAofZxA9LcfFvEgZxE(sonxwhIQ5umFd03dhacZOnFbeYONq1PA6QdZamGB5d4gGqSsfnkb4cqyeogcNeim(Vw(0lrE(Xu36KHciQMtX8LNV04BgTbm2XcvhK5B7C8LpF55BgTbm2XcvhK5BGC89yF55lKOMy)8PJqHejN4y(2UVh4UVu1xA8nJ2ag7yHQdY8Tn57r6lT(YZxWjCsfnksPK1HOAoLVuO4BgTbm2XcvhK5B7(ESV88fsutSF(0rOqIKtCmFB3xQG7(slqygT5lGqg9eQovtxDygqOezr4CAZxaHHO5R9(sWqFtsdH(MNF03H57x(Exq03K5R9(EcrWyz((GrymppNQX3J4D0x6xJg9LHMnvJVeN(ExqKAgGbCBabUbieRurJsaUaegHJHWjbcbNWjv0OGz9tDw1un(YZ379L9eALPKcnMYUsRoY1u9uJcSsfnk9LNV04B8FT8PxI88JPU1jdfqunNI5lfk(EVVwQXYejuTv)j72f2LPAHsbwPIgL(YZ34)A5tVeYegSBWSyKpunT5lbevZPy(sRV88fsuOWgvSBFNk8TDFviijfqIAI94dHeN28LaIQ5umFPqXxLNX8LNVKtZL1HOAofZ3a9LVdaHz0MVactLxDQ0MV66rvbWaULkaUbieRurJsaUaegHJHWjbcbNWjv0OGz9tDw1un(YZx2tOvMsk0yk7kT6ixt1tnkWkv0O0xE(sJVY3ee11RB1v0tZL1LVjGOAofZ3299WbFPqX3791snwMGOUEDRUIEAUmbwPIgL(YZ34)A5tVeYegSBWSyKpunT5lbevZPy(slqygT5lGWu5vNkT5RUEuvamGBpg4gGqSsfnkb4cqyeogcNeieCcNurJIukzDiQMt5lpFHefkSrf723PcFB3xfcssbKOMyp(qiXPnFjGOAofdimJ28fqyQ8QtL28vxpQkagWThjWnaHyLkAucWfGWiCmeojqi4eoPIgfmRFQZQMQXxE(sJVX)1YNEjYZpM6wNmuar1CkMVT77bU7lfk(EVVwQXYejuTv)j72f2LPAHsbwPIgL(YZ34)A5tVeYegSBWSyKpunT5lbevZPy(sRVuO4RYZy(YZxYP5Y6qunNI5BG(E4yGWmAZxaHSRmguJD7c7ef9hAxTamGBbHa3aeIvQOrjaxacJWXq4KaHGt4KkAuKsjRdr1CkF55ln(kX0U6zj7smMTe2edovJVuO4lmhzhbJLjsPKjGOAofZ3a547bQWxAbcZOnFbeYUYyqn2TlStu0FOD1cWaULBd4gGqSsfnkb4cqyeogcNeiK9eALPKItcMrOXocjoT5lbwPIgLaHz0MVacj1i7kctsdWamGWtigFvL0aUb42da3aeMrB(ci88T5lGqSsfnkb4cGbClFa3aeMrB(cieMdd7smLaHyLkAucWfad42acCdqygT5lGqsnYUIWK0acXkv0OeGlagWTubWnaHyLkAucWfGWiCmeojq49(APgltWiuv)Q3KWMVLgfyLkAuceMrB(cimHQT6pz3UWUetjq4jeJVQsADBurGWacya3EmWnaHyLkAucWfGW)eiKH2qcekrweoN28fq4DaCQjsdz(M(AWPcIgZ34)A5tV43x5aEKO0xLw(sfhl89MRH5l9K5B86zy5BY8LOUEDlFP)WGmF)YxQ4yFzy8lPVkeqM5BSvuJm(9vHW89kz(A)7RAwT8nkH(IKKy0y(AVVndy03034)A5tVeCvijGPnF5RCapSh67umdtPW3JaPVJrnZxWPMa99kz(wVVqunNsIqFHOralFpWVVOMH(crJaw(YDXXcGqWPMabcpaecoH9kvrGqdovq06h6SwveimJ28fqi4eoPIgbcbNAcSJAgceYDXXaHr4yiCsGqdovq0e2bXvY6emSRqqs6lpFPXxdovq0e2br8FT8PxcjbmT5lFVZ(sfh7lhF5UV0cya3EKa3aeIvQOrjaxac)tGqgAdjqygT5lGqWjCsfncecoH9kvrGqdovq0681zTQiqi4utGaHhacbNAcSJAgceYDXXaHr4yiCsGqdovq0egFIRK1jyyxHGK0xE(sJVgCQGOjm(eX)1YNEjKeW0MV89o7lvCSVC8L7(slGbClie4gGqSsfnkb4cq4FceYqBibcLilcNtB(ci8oWSrnnK5B6RbNkiAmFbNAc0xLw(gF1ZeovJV2f6B8FT8Px((K(AxOVgCQGOXVVYb8irPVkT81UqFLeW0MV89j91UqFviij9DmFpHp4rImHV3PtMVPVmdIvJD5R6lhYbH(AVVndy0303RP5cH(EcNhowlFT3xMbXQXU81Gtfeng)(MmFPJATVjZ30x1xoKdc9L8H(oK(M(AWPcIMV0hT23h6l9rR9TEZxwRk6l9XU8n(Vw(0lMaieCQjqGq(acbNWELQiqObNkiA9t48WXAbeMrB(cieCcNurJaHGtnb2rndbcpaegHJHWjbcV3xdovq0e2bXvY6emSRqqs6lpFn4ubrty8jUswNGHDfcssFPqXxdovq0egFIRK1jyyxHGK0xE(sJV04RbNkiAcJpr8FT8PxcjbmT5lFbPVgCQGOjm(ekeKKDjbmT5lFP132KV047bXX(svFn4ubrty8jUswxHGK0xA9Tn5ln(coHtQOrHbNkiAD(6Swv0xA9LwFB3xA8LgFn4ubrtyheX)1YNEjKeW0MV8fK(AWPcIMWoiuiij7scyAZx(sRVTjFPX3dIJ9LQ(AWPcIMWoiUswxHGK0xA9Tn5ln(coHtQOrHbNkiA9dDwRk6lT(slGbCl3gWnaHyLkAucWfGW)eiKHgqygT5lGqWjCsfnceco1eiqOLASmrcvB1FYUDHDzQwOuGvQOrPV88n(LKymr8lWFmT5R(t2TlSlXukGzf03254l3oqi4e2Rufbcjj06EucbcLilcNtB(ci8oao1ePHmFJeqiwMVm0io9L8H(AxOVCtISSXA57t6li48JPU1jd99UG4r0xKKeJgdWamGqygNuZaUb42da3aeIvQOrjaxacJWXq4KaHqIAI9ZNocfsKCIJ5B7(EKh7lpFPX3t0enjS5BPrrgTbm6lfk(EVVwQXYemcv1V6njS5BPrbwPIgL(sRV88fsuOqIKtCmFBNJVhdeMrB(cimHXSWU9qiwgqOezr4CAZxaHhXmoPMbya3YhWnaHyLkAucWfGWiCmeojqi4eoPIgfQj36H94)A5tVy9mAdy0xku89enrtcB(wAuKrBaJ(YZ3t0enjS5BPrbevZPy(gihFviijfk6)LDscylHKaM28LVuO4RYZy(YZxYP5Y6qunNI5BGC8vHGKuOO)x2jjGTescyAZxaHz0MVacv0)l7KeWwagWTbe4gGqSsfnkb4cqyeogcNeieCcNurJc1KB9WE8FT8PxSEgTbm6lfk(EIMOjHnFlnkYOnGrF557jAIMe28T0OaIQ5umFdKJVkeKKcfeYqyWPAescyAZx(sHIVkpJ5lpFjNMlRdr1CkMVbYXxfcssHcczim4uncjbmT5lGWmAZxaHkiKHWGt1aya3sfa3aeIvQOrjaxacJWXq4KaHkeKKcI661T6mdIvJDjiobcZOnFbeQNMlJ15weYgvSmad42JbUbieRurJsaUaegHJHWjbcbNWjv0Oqn5wpSh)xlF6fRNrBaJ(sHIVNOjAsyZ3sJImAdy0xE(EIMOjHnFlnkGOAofZ3a547HJ9LcfFvEgZxE(sonxwhIQ5umFdKJVhogimJ28fqywrKzWu3JPwdekrweoN28fqiiOIiZGP237MATVXS81Gttdc9Lk898nSSj1(QqqsY43xmJx(QtMnvJVho2xgg)sYe(ENyJE4gHsFVsO034lrPV2OI(MmFtFn400GqFT33GiE67y(cXuMkAuaya3EKa3aeIvQOrjaxacJWXq4KaHz0gWyhluDqMVTZXx(8LcfFPXxirHcjsoXX8TDo(ESV88fsutSF(0rOqIKtCmFBNJVhj39LwGWmAZxaHjmMf2pj0meWaUfecCdqiwPIgLaCbimchdHtcecoHtQOrHAYTEyp(Vw(0lwpJ2ag9LcfFprt0KWMVLgfz0gWOV889enrtcB(wAuar1CkMVbYXxfcssb5arf9)sHKaM28LVuO4RYZy(YZxYP5Y6qunNI5BGC8vHGKuqoqur)VuijGPnFbeMrB(ciKCGOI(FjGbCl3gWnaHyLkAucWfGWiCmeojqygTbm2XcvhK5lhFp4lpFPXxfcssbrD96wDMbXQXUeeN(sHIVkpJ5lpFjNMlRdr1CkMVb67X(slqygT5lGqLSP)KDdoXGmadWacBWcHtSNpcCdWThaUbieRurJsaUaeYWiqy8FT8Pxc2tO7qmprOaIQ5umGWmAZxaH0ZXacJWXq4KaHwQXYeSNq3HyEIqbwPIgL(YZxlHnOjSrf723pJwpGh7BG(ESV88LCAUSoevZPy(2UVh7lpFJ)RLp9sWEcDhI5jcfqunNI5BG(sJVnrPVTjF5UaeESV06lpFZOnGXowO6GmFdKJVbeWaULpGBacXkv0OeGlaHr4yiCsGqA89EFbNWjv0O48F9unDirnX(5thH(sHIVkeKKcgHuIvx(VQaIz08LwF55ln(QqqskKjmy3GzXiFOAAZxcItF55lKOqYh2GcjMs9GmRh)rlWkv0O0xE(MrBaJDSq1bz(gihFdOVuO4BgTbm2XcvhK5lhF5ZxAbcZOnFbekX0U6XF0agWTbe4gGqSsfnkb4cqyeogcNeiuHGKuWiKsS6Y)vfqmJMVuO479(coHtQOrX5)6PA6qIAI9ZNocbcZOnFbeINJevNiGbClvaCdqiwPIgLaCbiuISiCoT5lGWJaPVwcBqZ3yROEQgFhMVYHLkAuYVVm6JfV8vjJb91EFTl0x2unASnyjSbnFBWcHt0x9WmFNIzykfaHz0MVacHevpJ28vxpmdiKzWjAa3EaimchdHtcegBf1yhluDqMVC89aqOEywVsveiSbleorad42JbUbieRurJsaUaegHJHWjbcPX34)A5tVe55htDRtgkGOAofZ3299yF55ReviijfKiZq4unD6prjfeN(sHIVsuHGKuqImdHt10P)eLuWSmg0329nG(sRV88LgFjNMlRdr1CkMVb6B8FT8PxcjM2vplzxIXSLaIQ5umFPQVh4UVuO4l50CzDiQMtX8TDFJ)RLp9sKNFm1TozOaIQ5umFPfimJ28fqi9NOKD2jwsecegBf1y3sydAmGBpaya3EKa3aeIvQOrjaxacJWXq4KaHsuHGKuqImdHt10P)eLuWSmg03a54Ba9LNVX)1YNEjYZpM6wNmuar1CkMVb67X(sHIVsuHGKuqImdHt10P)eLuWSmg03a99aqygT5lGqsKziCQMoZGtqeim2kQXULWg0ya3EaWaUfecCdqiwPIgLaCbimchdHtceg)xlF6Lip)yQBDYqbevZPy(2UVh7lpFLOcbjPGezgcNQPt)jkPGzzmOVb67bGWmAZxaHKiZq4unDMbNGiqySvuJDlHnOXaU9aGbCl3gWnaHyLkAucWfGWiCmeojqygTbm2LVjirMHWPA60FIs6B7C8n2kQXowO6GmF55ReviijfKiZq4unD6prjfmlJb9nqFPcGWmAZxaHKiZq4unDMbNGiqOezr4CAZxaH3CnmFhMVijjgTbmQB5l5O1i0x6xt8Yx2OY8feVJH(wiHbtn)(Qqy(YUEcT03ticglZ30xweReoVV0Vqi6RDH(Ms5x(ELmFR3UMQXx79fIXxvflPaWamGqjsMeAd4gGBpaCdqygT5lGq1PKDsiICJqGqSsfnkb4cGbClFa3aeIvQOrjaxac)tGqgAaHz0MVacbNWjv0iqi4utGaH04lYnjMZtukMIfHewQOXo3KilJqTlrWte9LNVX)1YNEjMIfHewQOXo3KilJqTlrWtefqmLT8LwGqWjSxPkceYoX4qoOSBWPcIgqOezr4CAZxaH3ricglZx2jghYbL(AWPcIgZxfCQgFjyO0x6JD5BsyVAAt0x9uidWaUnGa3aeIvQOrjaxac)tGqgAaHz0MVacbNWjv0iqi4utGaHX)1YNEjyeQQF1BsyZ3sJciQMtX8nqFp2xE(APgltWiuv)Q3KWMVLgfyLkAu6lpFPXxl1yzcI661T6k6P5YeyLkAu6lpFJ)RLp9squxVUvxrpnxMaIQ5umFd03db0xE(g)xlF6LqMWGDdMfJ8HQPnFjGOAofRJC9eJgk9nqFpeqFPqX3791snwMGOUEDRUIEAUmbwPIgL(slqi4e2Rufbcp)xpvthsutSF(0riGbClvaCdqiwPIgLaCbi8pbczObeMrB(cieCcNurJaHGtnbceAPgltWEcDhI5jcfyLkAu6lpFHef6BG(YNV881sydAcBuXU99ZO1d4X(gOVh7lpFjNMlRdr1CkMVT77XaHGtyVsvei88F9unDirHmad42JbUbieRurJsaUae(NaHm0acZOnFbecoHtQOrGqWPMabcZOnGXowO6GmF547bF55ln(EVVWCKDemwMiLsMa56WmMVuO4lmhzhbJLjsPKjMY3299WX(slqi4e2Rufbczw)uNvnvdGbC7rcCdqiwPIgLaCbi8pbczObeMrB(cieCcNurJaHGtnbceMrBaJDSq1bz(2ohF5ZxE(sJV37lmhzhbJLjsPKjqUomJ5lfk(cZr2rWyzIukzcKRdZy(YZxA8fMJSJGXYePuYequnNI5B7(ESVuO4l50CzDiQMtX8TDFpWDFP1xAbcbNWELQiqykLSoevZPamGBbHa3aeIvQOrjaxac)tGqgAaHz0MVacbNWjv0iqi4utGaH04RLASmbJqv9REtcB(wAuGvQOrPV889EFprt0KWMVLgfz0gWOV88n(Vw(0lbJqv9REtcB(wAuar1CkMVuO479(APgltWiuv)Q3KWMVLgfyLkAu6lT(YZxA8vHGKuquxVUvpzSKqBcItFPqXxl1yzIeQ2Q)KD7c7YuTqPaRurJsF557jAI88J9MRNqlYOnGrFPqXxfcssHmHb7gmlg5dvtB(sqC6lfk(MrBaJDSq1bz(2ohF5ZxE(kX0U6zj7smMTe2edovJV0cecoH9kvrGq1KB9WE8FT8PxSEgTbmcya3YTbCdqiwPIgLaCbi8pbczObeMrB(cieCcNurJaHGtnbcegFWyLLjQP5Y6Kj6lpFLyAx9SKDjgZwcBIbNQXxE(QqqskKyAxSUKafmlJb9nqFPcFPqXxfcssHAcHpDu2BqvM9f2X6kRiQILjio9LcfFviijf2fC06odXGiuqC6lfk(QqqskiHyXnAqzx9lMbF2yTeeN(sHIVkeKKcnMYUsRoY1u9uJcItGqWjSxPkceQMCRh2pHFK1ZOnGrad4wUDGBacXkv0OeGlaHr4yiCsGq5BcWdKqJL1p1zdbkGijezxPIg9LNV37RLASmbrD96wDf90CzcSsfnk9LNV37lmhzhbJLjsPKjqUomJbeMrB(ci8jmfiMbbcLilcNtB(ciSn)CklNAQgFBZnqcnwMV3rD2qG(omFtFpHZdhRfGbC7bUdCdqiwPIgLaCbimchdHtcekFtaEGeASS(PoBiqbejHi7kv0OV88nJ2ag7yHQdY8TDo(YNV88LgFV3xl1yzcI661T6k6P5YeyLkAu6lfk(g)xlF6LGOUEDRUIEAUmbevZPy(YZxfcssbrD96wDf90CzDfcssH8Px(slqygT5lGWNWuGygeim2kQXULWg0ya3EaWaU9WbGBacXkv0OeGlaHz0MVacFctbIzqGq9uypkbcpsGqjYIW50MVacpcK(Axie9nHOVyHQdY8vDySPA8Tn3DKFFZZtDlFhZxAuimFR3x1hI(Axz57xr03te67r6ldJFjz0kacJWXq4KaHz0gWyx(Ma8aj0yz9tD2qG(gOVz0gWyhluDqMV88nJ2ag7yHQdY8TDo(YNV88LgFV3xl1yzcI661T6k6P5YeyLkAu6lfk(g)xlF6LGOUEDRUIEAUmbevZPy(YZxfcssbrD96wDf90CzDfcssH8Px(slGbC7b(aUbieRurJsaUaegHJHWjbcHefs(WguWioriZG5ucSsfnk9LNV04R8nbj8zwNebJqbejHi7kv0OVuO4R8nHI(Fz)uNneOaIKqKDLkA0xAbcZOnFbe(eMceZGagWThciWnaHyLkAucWfGWiCmeojqy8bJvwMOMMlRtMOV88vIPD1Zs2LymBjYOnGXoevZPy(gOV04Btu6BBY3dIJ9LwF55Ret7QNLSlXy2sytm4unaHz0MVacP)eLSZoXsIqGqjYIW50MVacpIijezxiZxqet7I5lisGuZ8vHGK0xUfbZ8vbjFi6Ret7I5RKa9fljdWaU9avaCdqiwPIgLaCbiKHrGW4)A5tVeSNq3HyEIqbevZPyaHz0MVacPNJbegHJHWjbcTuJLjypHUdX8eHcSsfnk9LNVwcBqtyJk2TVFgTEap23a99yF55RLWg0e2OID77Yb9TDFp2xE(g)xlF6LG9e6oeZtekGOAofZ3a9LgFBIsFBt(YDbi8yFP1xE(MrBaJDSq1bz(YX3dagWThog4gGqSsfnkb4cqygT5lGq65yaHmmceg)xlF6LqIPDX6scuar1CkgqOezr4CAZxaHCd5y(s(qFbrmTlQz(cIeiibrKC0OVdPV3onxMVCJt0x79TbnFzgeRg7YxfcssFvYyqFtwEcegHJHWjbcJpySYYe10CzDYe9LNVX)1YNEjKyAxSUKafqunNI5BG(2eL(YZ3mAdySJfQoiZxo(EaWaU9WrcCdqiwPIgLaCbiKHrGW4)A5tVesKC0OaIQ5umGWmAZxaH0ZXacJWXq4KaHXhmwzzIAAUSozI(YZ34)A5tVesKC0OaIQ5umFd03MO0xE(MrBaJDSq1bz(YX3dagWThaHa3aeIvQOrjaxacZOnFbegtTUNrB(QRhMbekrweoN28fqiiiAZx(sLdZy(ML0324jwiK5lnTXtSqidKHi3KaRiY8LOyeNNp0qPVt5BkLFjOfiupmRxPkceAWPcIgdWaU9a3gWnaHyLkAucWfGWmAZxaHXuR7z0MV66HzaH6Hz9kvrGW4dgRSmgGbC7bUDGBacXkv0OeGlaHz0MVacJPw3ZOnF11dZac1dZ6vQIaHWmoPMbya3Yh3bUbieRurJsaUaeMrB(cimMADpJ28vxpmdiupmRxPkceg)xlF6fdWaULVda3aeIvQOrjaxacZOnFbecjQEgT5RUEygqyeogcNeieCcNurJIukzDiQMt5lpFPX34)A5tVesmTREwYUeJzlbevZPy(gOVh4UV889EFTuJLjKi5OrbwPIgL(sHIVX)1YNEjKi5OrbevZPy(gOVh4UV881snwMqIKJgfyLkAu6lfk(gFWyLLjQP5Y6Kj6lpFJ)RLp9siX0UyDjbkGOAofZ3a99a39LwF5579(kX0U6zj7smMTe2edovdqOEywVsveimFSZqJ4eWaULp(aUbieRurJsaUaegHJHWjbcZOnGXowO6GmFBNJV85lpFLyAx9SKDjgZwcBIbNQbiKzWjAa3EaimJ28fqiKO6z0MV66HzaH6Hz9kvrGW8XUcbKzagWT8fqGBacXkv0OeGlaHz0MVacHevpJ28vxpmdimchdHtceMrBaJDSq1bz(2ohF5ZxE(sJV37Ret7QNLSlXy2sytm4un(YZxA8n(Vw(0lHet7QNLSlXy2sar1CkMVT77bU7lpFV3xl1yzcjsoAuGvQOrPVuO4B8FT8PxcjsoAuar1CkMVT77bU7lpFTuJLjKi5OrbwPIgL(sHIVXhmwzzIAAUSozI(YZ34)A5tVesmTlwxsGciQMtX8TDFpWDFP1xku89EFbNWjv0OiLswhIQ5u(slqOEywVsveiSbleoXE(iGbClFubWnaHyLkAucWfGWiCmeojqygTbm2XcvhK5lhFp4lfk(EVVGt4KkAuKsjRdr1CkGqMbNObC7bGWmAZxaHXuR7z0MV66HzaH6Hz9kvrGWgSq4ebmadim(Vw(0lgWna3Ea4gGqSsfnkb4cqyeogcNeieCcNurJc1KB9WE8FT8PxSEgTbm6lfk(EIMOjHnFlnkYOnGrF557jAIMe28T0OaIQ5umFdKJV8DK(sHIVKtZL1HOAofZ3a9LVJeimJ28fq45BZxagWT8bCdqiwPIgLaCbimchdHtceg)xlF6LGOUEDRUIEAUmbevZPy(gOVGqF55B8FT8Pxczcd2nywmYhQM28LaIQ5uSoY1tmAO03a9fe6lpFTuJLjiQRx3QRONMltGvQOrPV88LgFJ)RLp9sKNFm1TozOaIQ5uSoY1tmAO03a9fe6lpFbNWjv0OGKqR7rj0xku89EFbNWjv0OGKqR7rj0xA9LcfFV3xl1yzcI661T6k6P5YeyLkAu6lfk(Q8mMV88LCAUSoevZPy(gOVb8yGWmAZxaHjuTv)j72f2LykbmGBdiWnaHyLkAucWfGWiCmeojqOLWg0e2OID77NrRhWJ9nqFp2xE(AjSbnHnQy3(UCqFB33J9LNVz0gWyhluDqMVbYX3aceMrB(ciK9e6oeZtecegBf1y3sydAmGBpaya3sfa3aeIvQOrjaxacJWXq4KaHGt4KkAuWS(PoRAQgF55ln(g)xlF6Lip)yQBDYqbevZPyDKRNy0qPVb67X(sHIVX)1YNEjYZpM6wNmuar1Ckwh56jgnu6B7(EG7(sRV88LgFJ)RLp9sityWUbZIr(q10MVequnNI5BG(2eL(sHIVkeKKczcd2nywmYhQM28LG40xAbcZOnFbesuxVUvxrpnxgqOezr4CAZxaH3PFTK5lx0tZL5l5d9L40x799yFzy8ljZx79L1QI(sFSlFbbNFm1Tozi)(2gTlesFyi)(sWqFPp2LVGycd67nWSyKpunT5lbGbC7Xa3aeIvQOrjaxacJWXq4KaHGt4KkAuKsjRdr1CkFPqXxLNX8LNVKtZL1HOAofZ3a9LVdaHz0MVacjQRx3QRONMldWaU9ibUbieRurJsaUaegHJHWjbcbNWjv0OGz9tDw1un(YZxA8v(MGOUEDRUIEAUSU8nbevZPy(sHIV37RLASmbrD96wDf90CzcSsfnk9LwGWmAZxaHYegSBWSyKpunT5lad4wqiWnaHyLkAucWfGWiCmeojqi4eoPIgfPuY6qunNYxku8v5zmF55l50CzDiQMtX8nqF57aqygT5lGqzcd2nywmYhQM28fGbCl3gWnaHyLkAucWfGWiCmeojqygTbm2XcvhK5lhFp4lpFLOcbjPGezgcNQPt)jkPGzzmOVTZXxQWxE(sJV37l4eoPIgfKeADpkH(sHIVGt4KkAuqsO19Oe6lpFPX34)A5tVee11RB1v0tZLjGOAofZ3299a39LcfFJ)RLp9sityWUbZIr(q10MVequnNI1rUEIrdL(2UVh4UV889EFTuJLjiQRx3QRONMltGvQOrPV06lTaHz0MVacZZpM6wNmeWaULBh4gGqSsfnkb4cqyeogcNeimJ2ag7yHQdY8TDo(YNV88vIkeKKcsKziCQMo9NOKcMLXG(2UVb0xE(EVVsmTREwYUeJzlHnXGt1aeMrB(cimp)yQBDYqGWyROg7wcBqJbC7bad42dCh4gGqSsfnkb4cqyeogcNeiesutSF(0rOqIKtCmFd03duHV88n(Vw(0lbrD96wDf90CzciQMtX8nqFpeqF55B8FT8Pxczcd2nywmYhQM28LaIQ5uSoY1tmAO03a99qabcZOnFbeYiuv)Q3KWMVLgbmGBpCa4gGqSsfnkb4cqyeogcNeieCcNurJcM1p1zvt14lpFLOcbjPGezgcNQPt)jkPGzzmOVb6lF(YZxA89enrE(XEZ1tOfz0gWOVuO4RcbjPqMWGDdMfJ8HQPnFjio9LNVX)1YNEjYZpM6wNmuar1CkMVT77bU7lTaHz0MVacjQRx3QNmwsOnad42d8bCdqiwPIgLaCbimchdHtceMrBaJDSq1bz(2ohF5ZxE(krfcssbjYmeovtN(tusbZYyqFd0x(8LNV047jAI88J9MRNqlYOnGrFPqXxfcssHmHb7gmlg5dvtB(sqC6lfk(g)xlF6LqIPD1Zs2LymBjGOAofZ3a9Tjk9LwGWmAZxaHe11RB1tglj0gqySvuJDlHnOXaU9aGbC7HacCdqiwPIgLaCbimchdHtceEVVNOjAUEcTiJ2agbcZOnFbecZHHDjMsadWamGqWiKnFbClFCNVdC)i5JBxCaiKEcRPAyaHCdGGJ4ThHBBZARV(EZf67OE(qZxYh6l15JDgAeNu7le5MedeL(YEv03KWE10qPVXRSAqMWbLkNc99qB99UFbgHgk9LAl1yzIaqTV27l1wQXYebqGvQOrj1(sZbUsRWbLkNc9LV267D)cmcnu6l1qIcjFydkca1(AVVudjkK8HnOiacSsfnkP2xAoWvAfoOu5uOVhzB99UFbgHgk9LAl1yzIaqTV27l1wQXYebqGvQOrj1(sdFCLwHdQdk3ai4iE7r422S26RV3CH(oQNp08L8H(sD(yxHaYmQ9fICtIbIsFzVk6BsyVAAO034vwnit4GsLtH(gW267D)cmcnu6l1wQXYebGAFT3xQTuJLjcGaRurJsQ9LMaYvAfoOu5uOVurB99UFbgHgk9LAirHKpSbfbGAFT3xQHefs(WgueabwPIgLu7lnh4kTchuhuUbqWr82JWTTzT1xFV5c9DupFO5l5d9LAdovq0yu7le5MedeL(YEv03KWE10qPVXRSAqMWbLkNc99qB99UFbgHgk9LAl1yzIaqTV27l1wQXYebqGvQOrj1(sZbUsRWbLkNc9LV267D)cmcnu6l1gCQGOjoica1(AVVuBWPcIMWoica1(sta5kTchuQCk0x(ARV39lWi0qPVuBWPcIMGpraO2x79LAdovq0egFIaqTV0WhxPv4GsLtH(gW267D)cmcnu6l1gCQGOjoica1(AVVuBWPcIMWoica1(sdFCLwHdkvof6BaBRV39lWi0qPVuBWPcIMGpraO2x79LAdovq0egFIaqTV0eqUsRWbLkNc9LkARV39lWi0qPVuBWPcIM4Giau7R9(sTbNkiAc7Giau7lnh4kTchuQCk0xQOT(E3VaJqdL(sTbNkiAc(ebGAFT3xQn4ubrty8jca1(sdFCLwHdkvof67XT137(fyeAO0xQn4ubrtCqeaQ91EFP2GtfenHDqeaQ9Lg(4kTchuQCk03JBRV39lWi0qPVuBWPcIMGpraO2x79LAdovq0egFIaqTV0CGR0kCqDq5gabhXBpc32M1wF99Ml03r98HMVKp0xQBWcHtKAFHi3KyGO0x2RI(Me2RMgk9nELvdYeoOu5uOV81wFV7xGrOHsFPgsui5dBqraO2x79LAirHKpSbfbqGvQOrj1(sZbUsRWb1bLBaeCeV9iCBBwB913BUqFh1ZhA(s(qFPo(GXklJrTVqKBsmqu6l7vrFtc7vtdL(gVYQbzchuQCk03dT137(fyeAO0xQTuJLjca1(AVVuBPglteabwPIgLu7lnh4kTchuQCk03a2wFV7xGrOHsFP2snwMiau7R9(sTLASmraeyLkAusTV0CGR0kCqPYPqFdyB99UFbgHgk9LA2tOvMskca1(AVVuZEcTYusraeyLkAusTV0CGR0kCqPYPqFPI267D)cmcnu6l1wQXYebGAFT3xQTuJLjcGaRurJsQ9LMdCLwHdkvof6lv0wFV7xGrOHsFPM9eALPKIaqTV27l1SNqRmLueabwPIgLu7lnh4kTchuQCk03JST(E3VaJqdL(sTLASmraO2x79LAl1yzIaiWkv0OKAFP5axPv4GsLtH(YT1wFV7xGrOHsFPM9eALPKIaqTV27l1SNqRmLueabwPIgLu7BA(EhAJuPV0CGR0kCqDq5gabhXBpc32M1wF99Ml03r98HMVKp0xQpHy8vvsJAFHi3KyGO0x2RI(Me2RMgk9nELvdYeoOu5uOVurB99UFbgHgk9LAl1yzIaqTV27l1wQXYebqGvQOrj1(MMV3H2iv6lnh4kTchuQCk03JBRV39lWi0qPVHJ6D9L1QSKR(ENVZ(AVVujr6R6lj0emF)teM2d9LM7mT(sZbUsRWbLkNc994267D)cmcnu6l1gCQGOjoica1(AVVuBWPcIMWoica1(sdFCLwHdkvof67r2wFV7xGrOHsFdh176lRvzjx99oFN91EFPsI0x1xsOjy((NimTh6ln3zA9LMdCLwHdkvof67r2wFV7xGrOHsFP2GtfenbFIaqTV27l1gCQGOjm(ebGAFPHpUsRWbLkNc9fe2wFV7xGrOHsFdh176lRvzjx99o7R9(sLePVYb8WMV89pryAp0xAajT(sdFCLwHdkvof6liST(E3VaJqdL(sTbNkiAIdIaqTV27l1gCQGOjSdIaqTV0qfCLwHdkvof6liST(E3VaJqdL(sTbNkiAc(ebGAFT3xQn4ubrty8jca1(sZXCLwHdkvof6l3wB99UFbgHgk9LAl1yzIaqTV27l1wQXYebqGvQOrj1(sZbUsRWb1bLBaeCeV9iCBBwB913BUqFh1ZhA(s(qFPo(Vw(0lg1(crUjXarPVSxf9njSxnnu6B8kRgKjCqPYPqF5RT(E3VaJqdL(sTLASmraO2x79LAl1yzIaiWkv0OKAFPHpUsRWbLkNc99iBRV39lWi0qPVuBPglteaQ91EFP2snwMiacSsfnkP2xAoWvAfoOu5uOVCBT137(fyeAO0xQTuJLjca1(AVVuBPglteabwPIgLu7lnh4kTchuhuUbqWr82JWTTzT1xFV5c9DupFO5l5d9L6gSq4e75Ju7le5MedeL(YEv03KWE10qPVXRSAqMWbLkNc99qB99UFbgHgk9LAl1yzIaqTV27l1wQXYebqGvQOrj1(sZbUsRWbLkNc9LV267D)cmcnu6l1qIcjFydkca1(AVVudjkK8HnOiacSsfnkP2xAoWvAfoOoOCdGGJ4ThHBBZARV(EZf67OE(qZxYh6l1sKmj0g1(crUjXarPVSxf9njSxnnu6B8kRgKjCqPYPqFdyB99UFbgHgk9LAl1yzIaqTV27l1wQXYebqGvQOrj1(sta5kTchuQCk0xQOT(E3VaJqdL(sTLASmraO2x79LAl1yzIaiWkv0OKAFP5axPv4GsLtH(ccBRV39lWi0qPVuBPglteaQ91EFP2snwMiacSsfnkP2xAcixPv4GsLtH(YT3wFV7xGrOHsFP2snwMiau7R9(sTLASmraeyLkAusTV0CGR0kCqPYPqFpW9267D)cmcnu6l1wQXYebGAFT3xQTuJLjcGaRurJsQ9LMdCLwHdkvof67HdT137(fyeAO0xQTuJLjca1(AVVuBPglteabwPIgLu7lnh4kTchuQCk03d81wFV7xGrOHsFPgsui5dBqraO2x79LAirHKpSbfbqGvQOrj1(sZbUsRWbLkNc99av0wFV7xGrOHsFP2snwMiau7R9(sTLASmraeyLkAusTV0CGR0kCqPYPqF57qB99UFbgHgk9LAl1yzIaqTV27l1wQXYebqGvQOrj1(sdFCLwHdkvof6lFbST(E3VaJqdL(sTLASmraO2x79LAl1yzIaiWkv0OKAFPHpUsRWb1b9Ml0xQjyyFmuLrTVz0MV8LEY8TEZxYNOK(oLV21W8DupFOjCqpcQNp0qPVh4UVz0MV8vpmJjCqbcpHp5OrGWJEuFbrmTlFVtvtZL57DsD96woOh9O(ckHULVh43x(4oFhCqDqp6r99Uxz1GS26GE0J6BBWxqGKBrWmvSmMV27liwGiibrKC0iibrmTlMVGib6R9((LULVXNOmFTe2GgZx6xVVje9f56jgnu6R9(QhWOV6VA8fRNO5Yx79vnndH(st(yNHgXPVh9aTch0JEuFBd(cIdlv0O03WmchYjoP237ygnFvWysWqFLyk9T56j0mFvZGOVKp0xwk9feVtXeoOh9O(2g89oHnvJVCdprj9n8eljc9nvg9ydY8v9HOVKAKRJIULV0KMVubv9LzzmiZ3PygMsFFsFpMQ02MNVG4Dm03cjmyQ9nlPVQzlFpHiySmFzVk6B9Tbig9LngrAZxmHd6rpQVTbFVtyt14l3yKziCQgFdn4ee9DkFbbTX7GVdPVTEcFVsWOV1Bxt14lQzOV27R89nlPV0)IAZ3hmcJ5PV0FIsY8Dy(cI3XqFlKWGPw4GE0J6BBW37ELvdk9vnRw(sn50CzDiQMtXO234xYXMVsnZx79npp1T8DkFvEgZxYP5Yy((LULV0OrgZ37cI(spzg67x(AWKDrRWb9Oh132GVGaPeL(M1Bxi032iHPaXmOVyzWw(AVVm08L40xMb)QbH(EhohjQorMWb9Oh132GVhruNC13WB8fmt4liOnEh8v)nt0x2ur03X8fI6bz((LVXVitfcDAO0xyoYocglJjCqp6r9Tn47nTrqSn2wF9LBCgTh6BObXQXU89e(rMVtzVVgCQGO5R(BMOWb1bnJ28ftCcX4RQKgv5aYZ3MVCqZOnFXeNqm(QkPrvoGeMdd7smLoOz0MVyItigFvL0OkhqsQr2veMKMdAgT5lM4eIXxvjnQYbKjuTv)j72f2Lyk5)eIXxvjTUnQiNaY)qY5El1yzcgHQ6x9Me28T0Od6r99oao1ePHmFtFn4ubrJ5B8FT8Px87RCapsu6RslFPIJf(EZ1W8LEY8nE9mS8nz(suxVULV0FyqMVF5lvCSVmm(L0xfciZ8n2kQrg)(Qqy(ELmFT)9vnRw(gLqFrssmAmFT33Mbm6B6B8FT8PxcUkKeW0MV8voGh2d9DkMHPu47rG03XOM5l4utG(ELmFR3xiQMtjrOVq0iGLVh43xuZqFHOralF5U4yHdAgT5lM4eIXxvjnQYbKGt4KkAK)kvrogCQGO1p0zTQi))jhgAdj)GtnbY5a)Gtnb2rnd5WDXX8h)so28fhdovq0ehexjRtWWUcbjjpAm4ubrtCqe)xlF6LqsatB(6oFNPIJ5WDADqZOnFXeNqm(QkPrvoGeCcNurJ8xPkYXGtfeToFDwRkY)FYHH2qYp4utGCoWp4utGDuZqoCxCm)XVKJnFXXGtfenbFIRK1jyyxHGKKhngCQGOj4te)xlF6LqsatB(6oFNPIJ5WDADqpQV3bMnQPHmFtFn4ubrJ5l4utG(Q0Y34REMWPA81UqFJ)RLp9Y3N0x7c91Gtfen(9voGhjk9vPLV2f6RKaM28LVpPV2f6RcbjPVJ57j8bpsKj89oDY8n9LzqSASlFvF5qoi0x79TzaJ(M(Ennxi03t48WXA5R9(Ymiwn2LVgCQGOX433K5lDuR9nz(M(Q(YHCqOVKp03H030xdovq08L(O1((qFPpATV1B(YAvrFPp2LVX)1YNEXeoOz0MVyItigFvL0OkhqcoHtQOr(Ruf5yWPcIw)eopCSw8)NCyOnK8do1eih(4hCQjWoQziNd8h)so28fN7n4ubrtCqCLSobd7keKK8m4ubrtWN4kzDcg2viijPqXGtfenbFIRK1jyyxHGKKhn0yWPcIMGpr8FT8PxcjbmT5R7SbNkiAc(ekeKKDjbmT5lABt0CqCmvn4ubrtWN4kzDfcssABt0aoHtQOrHbNkiAD(6SwvKwABNgAm4ubrtCqe)xlF6LqsatB(6oBWPcIM4GqHGKSljGPnFrBBIMdIJPQbNkiAIdIRK1viijPTnrd4eoPIgfgCQGO1p0zTQiT06GEuFVdGtnrAiZ3ibeIL5ldnItFjFOV2f6l3KilBSw((K(cco)yQBDYqFVliEe9fjjXOXCqZOnFXeNqm(QkPrvoGeCcNurJ8xPkYHKqR7rjKFWPMa5yPgltKq1w9NSBxyxMQfk5f)ssmMi(f4pM28v)j72f2LykfWSc2ohUDhuh0JEuFVdCfJegk9fbJWw(AJk6RDH(Mr7H(omFtW5OtfnkCqZOnFX4OoLStcrKBe6GEuFVJqemwMVStmoKdk91GtfenMVk4un(sWqPV0h7Y3KWE10MOV6PqMdAgT5lgv5asWjCsfnYFLQih2jghYbLDdovq04hCQjqo0GCtI58eLIPyriHLkASZnjYYiu7se8erEX)1YNEjMIfHewQOXo3KilJqTlrWtefqmLTO1b9Oh132CjCsfnYCqZOnFXOkhqcoHtQOr(Ruf5C(VEQMoKOMy)8PJq(bNAcKt8FT8PxcgHQ6x9Me28T0OaIQ5uSapMNLASmbJqv9REtcB(wAKhnwQXYee11RB1v0tZLXl(Vw(0lbrD96wDf90CzciQMtXc8qa5f)xlF6LqMWGDdMfJ8HQPnFjGOAofRJC9eJgkd8qaPq5El1yzcI661T6k6P5YO1bnJ28fJQCaj4eoPIg5VsvKZ5)6PA6qIcz8do1eihl1yzc2tO7qmpripirHbYhplHnOjSrf723pJwpGhh4X8iNMlRdr1Ckw7h7GMrB(IrvoGeCcNurJ8xPkYHz9tDw1un8do1eiNmAdySJfQoiJZbE0CpmhzhbJLjsPKjqUomJrHcmhzhbJLjsPKjMQ9dhtRdAgT5lgv5asWjCsfnYFLQiNukzDiQMtXp4utGCYOnGXowO6GS25WhpAUhMJSJGXYePuYeixhMXOqbMJSJGXYePuYeixhMX4rdmhzhbJLjsPKjGOAofR9JPqHCAUSoevZPyTFG70sRdAgT5lgv5asWjCsfnYFLQih1KB9WE8FT8PxSEgTbmYp4utGCOXsnwMGrOQ(vVjHnFlnY7(t0enjS5BPrrgTbmYl(Vw(0lbJqv9REtcB(wAuar1Ckgfk3BPgltWiuv)Q3KWMVLgPLhnkeKKcI661T6jJLeAtqCsHILASmrcvB1FYUDHDzQwOK3jAI88J9MRNqlYOnGrkuuiijfYegSBWSyKpunT5lbXjfkz0gWyhluDqw7C4JNet7QNLSlXy2sytm4un06GMrB(IrvoGeCcNurJ8xPkYrn5wpSFc)iRNrBaJ8do1eiN4dgRSmrnnxwNmrEsmTREwYUeJzlHnXGt1WtHGKuiX0UyDjbkywgdgivqHIcbjPqnHWNok7nOkZ(c7yDLvevXYeeNuOOqqskSl4O1DgIbrOG4KcffcssbjelUrdk7QFXm4ZgRLG4KcffcssHgtzxPvh5AQEQrbXPd6r9Tn)CklNAQgFBZnqcnwMV3rD2qG(omFtFpHZdhRLdAgT5lgv5aYNWuGygK)HKJ8nb4bsOXY6N6SHafqKeISRurJ8U3snwMGOUEDRUIEAUmE3dZr2rWyzIukzcKRdZyoOz0MVyuLdiFctbIzq(JTIASBjSbngNd8pKCKVjapqcnww)uNneOaIKqKDLkAKxgTbm2XcvhK1oh(4rZ9wQXYee11RB1v0tZLrHs8FT8PxcI661T6k6P5YequnNIXtHGKuquxVUvxrpnxwxHGKuiF6fToOh13JaPV2fcrFti6lwO6GmFvhgBQgFBZDh53388u3Y3X8LgfcZ369v9HOV2vw((ve99eH(EK(YW4xsgTch0mAZxmQYbKpHPaXmi)6PWEuY5i5Fi5KrBaJD5BcWdKqJL1p1zdbgygTbm2XcvhKXlJ2ag7yHQdYANdF8O5El1yzcI661T6k6P5YOqj(Vw(0lbrD96wDf90CzciQMtX4PqqskiQRx3QRONMlRRqqskKp9Iwh0mAZxmQYbKpHPaXmi)djhirHKpSbfmIteYmyofpAKVjiHpZ6KiyekGijezxPIgPqr(Mqr)VSFQZgcuarsiYUsfnsRd6r99iIKqKDHmFbrmTlMVGibsnZxfcssF5wemZxfK8HOVsmTlMVsc0xSKmh0mAZxmQYbK0FIs2zNyjri)djN4dgRSmrnnxwNmrEsmTREwYUeJzlrgTbm2HOAoflqAAIY20bXX0YtIPD1Zs2LymBjSjgCQgh0mAZxmQYbK0ZX4NHroX)1YNEjypHUdX8eHciQMtX4Fi5yPgltWEcDhI5jc5zjSbnHnQy3((z06b84apMNLWg0e2OID77YbB)yEX)1YNEjypHUdX8eHciQMtXcKMMOSnXDbi8yA5LrBaJDSq1bzCo4GEuF5gYX8L8H(cIyAxuZ8fejqqcIi5OrFhsFVDAUmF5gNOV27BdA(Ymiwn2LVkeKK(QKXG(MS80bnJ28fJQCaj9Cm(zyKt8FT8PxcjM2fRljqbevZPy8pKCIpySYYe10CzDYe5f)xlF6LqIPDX6scuar1CkwGnrjVmAdySJfQoiJZbh0mAZxmQYbK0ZX4NHroX)1YNEjKi5OrbevZPy8pKCIpySYYe10CzDYe5f)xlF6LqIKJgfqunNIfytuYlJ2ag7yHQdY4CWb9O(ccI28LVu5WmMVzj9TnEIfcz(stB8eleYaziYnjWkImFjkgX55dnu67u(Ms5xcADqZOnFXOkhqgtTUNrB(QRhMXFLQihdovq0yoOz0MVyuLdiJPw3ZOnF11dZ4VsvKt8bJvwgZbnJ28fJQCazm16EgT5RUEyg)vQICGzCsnZb9Oh13mAZxmQYbKmKBsGve5Fi5KrBaJDSq1bzCoW7EjM2vpynnxMqoSurJ98njpl1yzcgHQ6x9Me28T0i)vQICAsyt)pXcHT9jmfiMbBljYmeovtNzWji2wsKziCQMoZGtqSTmcv1V6njS5BPX2Mq1w9NSBxyxIPSTsmTRE8hn)djhfcssbJqkXQl)xvqC2wjM2vp(JUTsmTRE8hDBzXNa2GDMbNGi)djhjQqqskirMHWPA60FIskywgd2ov0ww8jGnyNzWjiY)qYrIkeKKcsKziCQMo9NOKcMLXGTtfTLezgcNQPZm4eeDqp6r9nJ28fJQCajd5Meyfr(hsoz0gWyhluDqgNd8UxIPD1dwtZLjKdlv0ypFtY7El1yzcgHQ6x9Me28T0i)vQIC(tSqyBjrMHWPA6mdobX2sImdHt10zgCcIT98T5R2suxVUvxrpnxwBLjmy3GzXiFOAAZxTnp)yQBDYqh0mAZxmQYbKXuR7z0MV66Hz8xPkYj(Vw(0lMdAgT5lgv5asir1ZOnF11dZ4VsvKt(yNHgXj)djhWjCsfnksPK1HOAofpAI)RLp9siX0U6zj7smMTequnNIf4bUZ7El1yzcjsoAKcL4)A5tVesKC0OaIQ5uSapWDEwQXYesKC0ifkXhmwzzIAAUSozI8I)RLp9siX0UyDjbkGOAoflWdCNwE3lX0U6zj7smMTe2edovJdAgT5lgv5asir1ZOnF11dZ4VsvKt(yxHaYm(zgCIgNd8pKCYOnGXowO6GS25WhpjM2vplzxIXSLWMyWPACqZOnFXOkhqcjQEgT5RUEyg)vQICAWcHtSNpY)qYjJ2ag7yHQdYANdF8O5EjM2vplzxIXSLWMyWPA4rt8FT8PxcjM2vplzxIXSLaIQ5uS2pWDE3BPgltirYrJuOe)xlF6LqIKJgfqunNI1(bUZZsnwMqIKJgPqj(GXkltutZL1jtKx8FT8PxcjM2fRljqbevZPyTFG70sHY9Gt4KkAuKsjRdr1CkADqZOnFXOkhqgtTUNrB(QRhMXFLQiNgSq4e5NzWjACoW)qYjJ2ag7yHQdY4CGcL7bNWjv0OiLswhIQ5uoOoOh9O(cc(7GVCHaYmh0mAZxmr(yxHaYmorDsFQMo7kLpDg)djNmAdySJfQoilqoh7GMrB(IjYh7keqMrvoGmQt6t10zxP8PZ4Fi5KrBaJDSq1bzCosEsmTREWAAUmbj9NOKOSBjSbnw7CcOdAgT5lMiFSRqazgv5as6prj7StSKiK)HKJLASmHcbKzt10zpez8OrIPD1dwtZLjiP)eLeLDlHnOX4KrBaJDSq1bzuOiX0U6bRP5YeK0FIsIYULWg0yTZjG0sHILASmHcbKzt10zpez8SuJLjI6K(unD2vkF6mEsmTREWAAUmbj9NOKOSBjSbnw7Co4GMrB(IjYh7keqMrvoGuIPD1J)O5Fi5qJcbjPGriLy1L)RkGygnkuUhCcNurJIZ)1t10He1e7NpDeslpAuiijfYegSBWSyKpunT5lbXjpirHKpSbfsmL6bzwp(JMxgTbm2XcvhKfiNasHsgTbm2XcvhKXHpADqZOnFXe5JDfciZOkhqINJevNi)djhirnX(5thHcjsoXXcKMdCNQsmTREWAAUmbj9NOKOSBjSbnwBkG0YtIPD1dwtZLjiP)eLeLDlHnOXc8i5Dp4eoPIgfN)RNQPdjQj2pF6iKcffcssbJEcvNQPRomtqC6GMrB(IjYh7keqMrvoGephjQor(hsoqIAI9ZNocfsKCIJfiFhZtIPD1dwtZLjiP)eLeLDlHnOXA)yE3doHtQOrX5)6PA6qIAI9ZNocDqZOnFXe5JDfciZOkhqINJevNi)djN7LyAx9G10Czcs6prjrz3sydAmE3doHtQOrX5)6PA6qIAI9ZNocPqHCAUSoevZPybEmfkWCKDemwMiLsMa56WmgpyoYocgltKsjtar1CkwGh7GMrB(IjYh7keqMrvoGK(tuYo7eljcDqZOnFXe5JDfciZOkhqINJevNi)djN7bNWjv0O48F9unDirnX(5thHoOoOh9O(cc(7GVHOrC6GMrB(IjYh7m0io5KvRUSK8pKCKyAx9G10Czcs6prjrz3sydAS25eBf1yhluDqgfksmTREWAAUmbj9NOKOSBjSbnw7CoMcL7TuJLjuiGmBQMo7HiJcfyoYocgltKsjtGCDygJhmhzhbJLjsPKjGOAoflqohoqHc50CzDiQMtXcKZHdoOz0MVyI8XodnItQYbKsmTRE8hn)djN7bNWjv0O48F9unDirnX(5thH8OrHGKuityWUbZIr(q10MVeeN8Gefs(WguiXuQhKz94pAEz0gWyhluDqwGCcifkz0gWyhluDqgh(O1bnJ28ftKp2zOrCsvoGephjQor(hso3doHtQOrX5)6PA6qIAI9ZNocDqZOnFXe5JDgAeNuLdijrMHWPA6mdobr(JTIASBjSbngNd8pKCKOcbjPGezgcNQPt)jkPGzzmyGCciV4)A5tVe55htDRtgkGOAoflWa6GMrB(IjYh7m0ioPkhqsImdHt10zgCcI8hBf1y3sydAmoh4Fi5irfcssbjYmeovtN(tusbZYyWap4GMrB(IjYh7m0ioPkhqsImdHt10zgCcI8hBf1y3sydAmoh4Fi5ajkuyJk2TVtfbst8FT8PxcjM2vplzxIXSLaIQ5umE3BPgltirYrJuOe)xlF6LqIKJgfqunNIXZsnwMqIKJgPqj(GXkltutZL1jtKx8FT8PxcjM2fRljqbevZPy06GEuF5gUWYxlHnO5lJEEY8nHOVYHLkAuYVV21W8L(O1(QrZ3wpHVStSK(cjkKbs6prjz(ofZWu67t6l9CSPA8L8H(cIficsqejhncsqet7IAMVGibkCqZOnFXe5JDgAeNuLdiP)eLSZoXsIq(hso0CpdnBQgMi2kQrkuKyAx9G10Czcs6prjrz3sydAS25eBf1yhluDqgT8KOcbjPGezgcNQPt)jkPGzzmy7bKhKOqHnQy3(Eadm(Vw(0lrwT6YskGOAofZb1b9Oh1374BZxoOz0MVyI4)A5tVyCoFB(I)HKd4eoPIgfQj36H94)A5tVy9mAdyKcLt0enjS5BPrrgTbmY7enrtcB(wAuar1CkwGC47iPqHCAUSoevZPybY3r6GE0J67D)xlF6fZbnJ28fte)xlF6fJQCazcvB1FYUDHDjMs(hsoX)1YNEjiQRx3QRONMltar1CkwGGqEX)1YNEjKjmy3GzXiFOAAZxciQMtX6ixpXOHYabH8SuJLjiQRx3QRONMlJhnX)1YNEjYZpM6wNmuar1Ckwh56jgnugiiKh4eoPIgfKeADpkHuOCp4eoPIgfKeADpkH0sHY9wQXYee11RB1v0tZLrHIYZy8iNMlRdr1CkwGb8yh0mAZxmr8FT8PxmQYbKSNq3HyEIq(JTIASBjSbngNd8pKCSe2GMWgvSBF)mA9aECGhZZsydAcBuXU9D5GTFmVmAdySJfQoilqob0b9O(EN(1sMVCrpnxMVKp0xItFT33J9LHXVKmFT3xwRk6l9XU8feC(Xu36KH87BB0Uqi9HH87lbd9L(yx(cIjmOV3aZIr(q10MVeoOz0MVyI4)A5tVyuLdijQRx3QRONMlJ)HKd4eoPIgfmRFQZQMQHhnX)1YNEjYZpM6wNmuar1Ckwh56jgnug4XuOe)xlF6Lip)yQBDYqbevZPyDKRNy0qz7h4oT8Oj(Vw(0lHmHb7gmlg5dvtB(sar1CkwGnrjfkkeKKczcd2nywmYhQM28LG4Kwh0mAZxmr8FT8PxmQYbKe11RB1v0tZLX)qYbCcNurJIukzDiQMtrHIYZy8iNMlRdr1CkwG8DWbnJ28fte)xlF6fJQCaPmHb7gmlg5dvtB(I)HKd4eoPIgfmRFQZQMQHhnY3ee11RB1v0tZL1LVjGOAofJcL7TuJLjiQRx3QRONMlJwh0mAZxmr8FT8PxmQYbKYegSBWSyKpunT5l(hsoGt4KkAuKsjRdr1CkkuuEgJh50CzDiQMtXcKVdoOz0MVyI4)A5tVyuLdiZZpM6wNmK)HKtgTbm2XcvhKX5apjQqqskirMHWPA60FIskywgd2ohQGhn3doHtQOrbjHw3JsifkGt4KkAuqsO19OeYJM4)A5tVee11RB1v0tZLjGOAofR9dCNcL4)A5tVeYegSBWSyKpunT5lbevZPyDKRNy0qz7h4oV7TuJLjiQRx3QRONMlJwADqZOnFXeX)1YNEXOkhqMNFm1Tozi)Xwrn2Te2GgJZb(hsoz0gWyhluDqw7C4JNeviijfKiZq4unD6prjfmlJbBpG8UxIPD1Zs2LymBjSjgCQgh0mAZxmr8FT8PxmQYbKmcv1V6njS5BPr(hsoqIAI9ZNocfsKCIJf4bQGx8FT8PxcI661T6k6P5YequnNIf4HaYl(Vw(0lHmHb7gmlg5dvtB(sar1Ckwh56jgnug4Ha6GMrB(IjI)RLp9IrvoGKOUEDREYyjH24Fi5aoHtQOrbZ6N6SQPA4jrfcssbjYmeovtN(tusbZYyWa5JhnNOjYZp2BUEcTiJ2agPqrHGKuityWUbZIr(q10MVeeN8I)RLp9sKNFm1TozOaIQ5uS2pWDADqZOnFXeX)1YNEXOkhqsuxVUvpzSKqB8hBf1y3sydAmoh4Fi5KrBaJDSq1bzTZHpEsuHGKuqImdHt10P)eLuWSmgmq(4rZjAI88J9MRNqlYOnGrkuuiijfYegSBWSyKpunT5lbXjfkX)1YNEjKyAx9SKDjgZwciQMtXcSjkP1bnJ28fte)xlF6fJQCajmhg2Lyk5Fi5C)jAIMRNqlYOnGrh0JEuFbXHLkAuYVVClcM5B9MVqm16w(wpun1(QGxj45H(AxPrnZx6p0U89KaYiMQX3PAdnPkkCqp6r9nJ28fte)xlF6fJQCajlJWHCItQ7Nz04Fi5KrBaJDSq1bzTZHpE3RqqskKjmy3GzXiFOAAZxcItEX)1YNEjKjmy3GzXiFOAAZxciQMtXA)ykuuEgJh50CzDiQMtXcSjkDqDqp6r99UpySYY8feOm6XgK5GMrB(IjIpySYYyCy0tO6unD1Hz8pKCaNWjv0OGz9tDw1un8Ge1e7NpDekKi5ehR9dhjpAI)RLp9sKNFm1TozOaIQ5umkuU3snwMiHQT6pz3UWUmvluYl(Vw(0lHmHb7gmlg5dvtB(sar1CkgTuOO8mgpYP5Y6qunNIf4HdoOh13q081EFjyOVjPHqFZZp67W89lFVli6BY81EFpHiySmFFWimMNNt147r8o6l9RrJ(YqZMQXxItFVlisnZbnJ28fteFWyLLXOkhqYONq1PA6QdZ4Fi5e)xlF6Lip)yQBDYqbevZPy8OjJ2ag7yHQdYANdF8YOnGXowO6GSa5CmpirnX(5thHcjsoXXA)a3Pknz0gWyhluDqwB6iPLh4eoPIgfPuY6qunNIcLmAdySJfQoiR9J5bjQj2pF6iuirYjow7ub3P1bnJ28fteFWyLLXOkhqMkV6uPnF11JQc)djhWjCsfnkyw)uNvnvdV7zpHwzkPqJPSR0QJCnvp1ipAI)RLp9sKNFm1TozOaIQ5umkuU3snwMiHQT6pz3UWUmvluYl(Vw(0lHmHb7gmlg5dvtB(sar1CkgT8GefkSrf723PI2viijfqIAI94dHeN28LaIQ5umkuuEgJh50CzDiQMtXcKVdoOz0MVyI4dgRSmgv5aYu5vNkT5RUEuv4Fi5aoHtQOrbZ6N6SQPA4XEcTYusHgtzxPvh5AQEQrE0iFtquxVUvxrpnxwx(MaIQ5uS2pCGcL7TuJLjiQRx3QRONMlJx8FT8Pxczcd2nywmYhQM28LaIQ5umADqZOnFXeXhmwzzmQYbKPYRovAZxD9OQW)qYbCcNurJIukzDiQMtXdsuOWgvSBFNkAxHGKuajQj2JpesCAZxciQMtXCqZOnFXeXhmwzzmQYbKSRmguJD7c7ef9hAxT4Fi5aoHtQOrbZ6N6SQPA4rt8FT8PxI88JPU1jdfqunNI1(bUtHY9wQXYejuTv)j72f2LPAHsEX)1YNEjKjmy3GzXiFOAAZxciQMtXOLcfLNX4ronxwhIQ5uSapCSdAgT5lMi(GXklJrvoGKDLXGASBxyNOO)q7Qf)djhWjCsfnksPK1HOAofpAKyAx9SKDjgZwcBIbNQHcfyoYocgltKsjtar1CkwGCoqf06GMrB(IjIpySYYyuLdij1i7kctsJ)HKd7j0ktjfNemJqJDesCAZxoOoOh9O(govJg99Me2GMdAgT5lMObleorosmTRE8hn)djN7bNWjv0O48F9unDirnX(5thH8OrHGKuWiKsS6Y)vfqmJgfkqIAI9ZNocfsKCIJfiNdbKwkuort0KWMVLgfz0gWipirHbYjGuOqonxwhIQ5uSapWDE3lrfcssbjYmeovtN(tusbXPdAgT5lMObleorQYbKz1Qllj)djhASuJLjKi5OrbwPIgLuOeFWyLLjQP5Y6KjsHcKOqYh2GIZlmHV6xiJwE0Cp4eoPIgfN)RNQPdjkKrHIYZy8iNMlRdr1CkwGhtRdAgT5lMObleorQYbK0FIs2zNyjri)djhWjCsfnkutU1d7NWpY6z0gWipjQqqskirMHWPA60FIskywgd2oNd8I)RLp9sKNFm1TozOaIQ5uSoY1tmAOS9J5Dp4eoPIgfN)RNQPdjkK5GMrB(IjAWcHtKQCaj9NOKD2jwseY)qYrIkeKKcsKziCQMo9NOKcMLXGThqE3doHtQOrX5)6PA6qIczuOirfcssbjYmeovtN(tusbXjpYP5Y6qunNIfinsuHGKuqImdHt10P)eLuWSmgSn1eL06GMrB(IjAWcHtKQCaPet7Qh)rZ)qYbsutSF(0rOqIKtCSa5Wh35Dp4eoPIgfN)RNQPdjQj2pF6i0bnJ28ft0GfcNiv5assKziCQMoZGtqK)HKJeviijfKiZq4unD6prjfmlJbdKk4Dp4eoPIgfN)RNQPdjkK5GMrB(IjAWcHtKQCaPet7Qh)rZ)qY5EWjCsfnko)xpvthsutSF(0rOdAgT5lMObleorQYbK0FIs2zNyjri)djhjQqqskirMHWPA60FIskywgd2oNd8GefgiF8UhCcNurJIZ)1t10HefY4f)xlF6Lip)yQBDYqbevZPyDKRNy0qz7h7G6GE0J6BBgwiCI(cc(7GV3r48WXA5GMrB(IjAWcHtSNpYHEog)mmYj(Vw(0lb7j0DiMNiuar1Ckg)djhl1yzc2tO7qmpriplHnOjSrf723pJwpGhh4X8iNMlRdr1Ckw7hZl(Vw(0lb7j0DiMNiuar1CkwG00eLTjUlaHhtlVmAdySJfQoilqob0bnJ28ft0GfcNypFKQCaPet7Qh)rZ)qYHM7bNWjv0O48F9unDirnX(5thHuOOqqskyesjwD5)QciMrJwE0OqqskKjmy3GzXiFOAAZxcItEqIcjFydkKyk1dYSE8hnVmAdySJfQoilqobKcLmAdySJfQoiJdF06GMrB(IjAWcHtSNpsvoGephjQor(hsokeKKcgHuIvx(VQaIz0Oq5EWjCsfnko)xpvthsutSF(0rOd6r99iq6RLWg08n2kQNQX3H5RCyPIgL87lJ(yXlFvYyqFT3x7c9LnvJgBdwcBqZ3gSq4e9vpmZ3PygMsHdAgT5lMObleoXE(iv5asir1ZOnF11dZ4VsvKtdwiCI8Zm4enoh4Fi5eBf1yhluDqgNdoOz0MVyIgSq4e75JuLdiP)eLSZoXsIq(JTIASBjSbngNd8pKCOj(Vw(0lrE(Xu36KHciQMtXA)yEsuHGKuqImdHt10P)eLuqCsHIeviijfKiZq4unD6prjfmlJbBpG0YJgYP5Y6qunNIfy8FT8PxcjM2vplzxIXSLaIQ5umQEG7uOqonxwhIQ5uS2J)RLp9sKNFm1TozOaIQ5umADqZOnFXenyHWj2ZhPkhqsImdHt10zgCcI8hBf1y3sydAmoh4Fi5irfcssbjYmeovtN(tusbZYyWa5eqEX)1YNEjYZpM6wNmuar1CkwGhtHIeviijfKiZq4unD6prjfmlJbd8GdAgT5lMObleoXE(iv5assKziCQMoZGtqK)yROg7wcBqJX5a)djN4)A5tVe55htDRtgkGOAofR9J5jrfcssbjYmeovtN(tusbZYyWap4GEuFV5Ay(omFrssmAdyu3YxYrRrOV0VM4LVSrL5liEhd9TqcdMA(9vHW8LD9eAPVNqemwMVPVSiwjCEFPFHq0x7c9nLYV89kz(wVDnvJV27leJVQkwsHdAgT5lMObleoXE(iv5assKziCQMoZGtqK)HKtgTbm2LVjirMHWPA60FIs2oNyROg7yHQdY4jrfcssbjYmeovtN(tusbZYyWaPchuh0J67rmJtQzoOz0MVycygNuZ4KWywy3EielJ)HKdKOMy)8PJqHejN4yTFKhZJMt0enjS5BPrrgTbmsHY9wQXYemcv1V6njS5BPrbwPIgL0YdsuOqIKtCS25CSdAgT5lMaMXj1mQYbKk6)LDscyl(hsoGt4KkAuOMCRh2J)RLp9I1ZOnGrkuort0KWMVLgfz0gWiVt0enjS5BPrbevZPybYrHGKuOO)x2jjGTescyAZxuOO8mgpYP5Y6qunNIfihfcssHI(FzNKa2sijGPnF5GMrB(IjGzCsnJQCaPcczim4un8pKCaNWjv0Oqn5wpSh)xlF6fRNrBaJuOCIMOjHnFlnkYOnGrENOjAsyZ3sJciQMtXcKJcbjPqbHmegCQgHKaM28ffkkpJXJCAUSoevZPybYrHGKuOGqgcdovJqsatB(YbnJ28ftaZ4KAgv5as90CzSo3Iq2OILX)qYrHGKuquxVUvNzqSASlbXPd6r9feurKzWu77DtT23yw(AWPPbH(sf(E(gw2KAFviijz87lMXlF1jZMQX3dh7ldJFjzcFVtSrpCJqPVxju6B8LO0xBurFtMVPVgCAAqOV27Bqep9DmFHyktfnkCqZOnFXeWmoPMrvoGmRiYmyQ7XuR5Fi5aoHtQOrHAYTEyp(Vw(0lwpJ2agPq5enrtcB(wAuKrBaJ8ort0KWMVLgfqunNIfiNdhtHIYZy8iNMlRdr1CkwGCoCSdAgT5lMaMXj1mQYbKjmMf2pj0mK)HKtgTbm2XcvhK1oh(OqHgirHcjsoXXANZX8Ge1e7NpDekKi5ehRDohj3P1bnJ28ftaZ4KAgv5asYbIk6)L8pKCaNWjv0Oqn5wpSh)xlF6fRNrBaJuOCIMOjHnFlnkYOnGrENOjAsyZ3sJciQMtXcKJcbjPGCGOI(FPqsatB(IcfLNX4ronxwhIQ5uSa5OqqskihiQO)xkKeW0MVCqZOnFXeWmoPMrvoGujB6pz3GtmiJ)HKtgTbm2XcvhKX5apAuiijfe11RB1zgeRg7sqCsHIYZy8iNMlRdr1CkwGhtRdQd6rpQV3aNkiAmh0mAZxmHbNkiAmoemSpgQYFLQiNPyriHLkASZnjYYiu7se8er(hso0e)xlF6LGOUEDRUIEAUmbevZPyTZh3Pqj(Vw(0lHmHb7gmlg5dvtB(sar1Ckwh56jgnu2oFCNwE0KrBaJDSq1bzTZHpkuortKq1w9MRNqlYOnGrkuortKNFS3C9eArgTbmYJgl1yzcI661T6jJLeAJcfjM2vpynnxMqoSurJ98njTuOCIMOjHnFlnkYOnGrAPqr5zmEKtZL1HOAoflq(oqHILWg0e2OID77NrRZh3d8yh0J67nxOVgCQGO5l9XU81UqFVMMlKz(ImButdL(co1ei)(sF0AFvqFjyO0xYbYmFZs67zoqu6l9XU8feC(Xu36KH(sZq6RcbjPVdZ3dh7ldJFjz((qF1iJrRVp0xUONMldKG4n(sZq6BdetdH(Axz57HJ9LHXVKmADqZOnFXegCQGOXOkhqAWPcI2b(hso3doHtQOrb7eJd5GYUbNkiA8OHgdovq0ehekeKKDjbmT5Ra5C4yEX)1YNEjYZpM6wNmuar1Ckw78XDkum4ubrtCqOqqs2LeW0MVA)WX8Oj(Vw(0lbrD96wDf90CzciQMtXANpUtHs8FT8Pxczcd2nywmYhQM28LaIQ5uSoY1tmAOSD(4oTuOKrBaJDSq1bzTZHpEkeKKczcd2nywmYhQM28LG4KwE0CVbNkiAc(exjRh)xlF6ffkgCQGOj4te)xlF6LaIQ5umkuaNWjv0OWGtfeT(jCE4yT4CGwAPqXGtfenXbHcbjzxsatB(QDoKtZL1HOAofZbnJ28ftyWPcIgJQCaPbNkiA8X)qY5EWjCsfnkyNyCihu2n4ubrJhn0yWPcIMGpHcbjzxsatB(kqohoMx8FT8PxI88JPU1jdfqunNI1oFCNcfdovq0e8juiij7scyAZxTF4yE0e)xlF6LGOUEDRUIEAUmbevZPyTZh3Pqj(Vw(0lHmHb7gmlg5dvtB(sar1Ckwh56jgnu2oFCNwkuYOnGXowO6GS25WhpfcssHmHb7gmlg5dvtB(sqCslpAU3GtfenXbXvY6X)1YNErHIbNkiAIdI4)A5tVequnNIrHc4eoPIgfgCQGO1pHZdhRfh(OLwkum4ubrtWNqHGKSljGPnF1ohYP5Y6qunNI5GEuFpcK((LULVFH((LVem0xdovq089e(GhjY8n9vHGKKFFjyOV2f67Bxi03V8n(Vw(0lHVTrOVdPVfo2fc91GtfenFpHp4rImFtFviij53xcg6RYBx((LVX)1YNEjCqZOnFXegCQGOXOkhqAWPcI2b(hso3BWPcIM4G4kzDcg2viij5rJbNkiAc(eX)1YNEjGOAofJcL7n4ubrtWN4kzDcg2viijP1bnJ28ftyWPcIgJQCaPbNkiA8X)qY5Edovq0e8jUswNGHDfcssE0yWPcIM4Gi(Vw(0lbevZPyuOCVbNkiAIdIRK1jyyxHGKKwGWKWUEiqy4OsOtB(6UWK0amadaaa]] )


end
