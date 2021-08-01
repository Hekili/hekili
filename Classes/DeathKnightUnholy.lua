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


    spec:RegisterPack( "Unholy", 20210708, [[devYUcqivQ6rQq6sab1Mqv(esXOqsDkKsRskf5vijnluvDlPuWUi8lGOHHkvhtfSmuvEMaQPHKW1uHABQuHVHKiJtLkQZPsfX6KsP3PcHK5ja3dvSpPuDqGalevIhQsLMiqOlQcr2isIsFejr1ivPIuNukf1kbsVuLksMjQKCtviKANQu6NsPqdvfIAPQqWtLIPQsXvvHqTvvieFfiiJvazVa(RunyLoSOftIhl0Kj6YqBgrFwqJwLCAfRgvs1RfOztQBts7wYVv1Wvrhhvsz5GEoktNY1ry7a13rQgpQuoVuY6rsumFKy)unWbGBaAKPHa3Yh357a3PsC)oloCNWDUFmvcOXADIanNzmygIanvQIanhX11RBb0CMT0FkbUbOH9eWic0Cz2jRTGeKHJDrOiIVkizJkHoT5RimjnqYg1iibAuigT1MlafGgzAiWT8XD(oWDQe3VZId3jCN7ubvcOHDIrGB57y(aAUgPelafGgjYIanGiM2LV3PQj8Y89iUUEDlhuqj0T89oZVV8XD(o4G6GE3RScrwBDqBd(ccKCDcMPILX81EFbXcebjiIKJgbjiIPDX8fejqFT33V0T8n(eL5RLWq0y(s)69nHOVi3oXOHsFT3x9ag9v)vOVy9eHx(AVVQPzi0xQZh7m0io99OhOv4G2g8fehwQOrPVnzeoKtCsTVh5mA(QGXKGH(kXu6B41tOz(QMbrFjFOVSu6liENIjCqBd(EeZMk0xqONOK(2CILeH(MkJESbz(Q(q0xsnYTrr3YxQtZxQGQ(YSmgK57umdtPVpPVhtvApIYxq8i34BHegm1(ML0x1SLVNqemwMVSxf9T(2aeJ(YgJiT5lMWbTn47rmBQqFPYImdHtf6BJbNGOVt5liOnEK8Di9T1t47vcg9TE7AQqFrnd91EFLVVzj9L(x0y((Grymp9L(tusMVdZxq8i34BHegm1ch02GV39kRqu6RAwT8LgYj8Y6qunNIrJVXVKJnFLAMV27BEEQB57u(Q8mMVKt4LX89lDlFPwJmMV3fe9LEYm03V81Gj7IwHdABWxqGuIsFZ6Tle6BBKWuGyg0xSmylFT3xgA(sC6lZGFfIqFpsNJevNit4G2g89iG6KB(2CJVGzcFbbTXJKV6pCI(YMkI(oMVqupiZ3V8n(fzQqOtdL(cZr2rWyzmHdABW3BAJGyBST(6lv2mAp03gdIvOD57j8JmFNYEFn4ubrZx9horbqJEygd4gGM8XodnItGBaU9aWnanyLkAucWfGMiCmeojqJet7QhSMWltqs)jkjk7wcdrJ5B7C8n2kQXowO6GmFPqXxjM2vpynHxMGK(tusu2TegIgZ32547X(sHIV37RLASmHcbKztf2zpezcSsfnk9LcfFH5i7iySmrkLmbYTHzmF55lmhzhbJLjsPKjGOAofZ3a447Hd(sHIVKt4L1HOAofZ3a447Hdanz0MVaAYQvxwsad4w(aUbObRurJsaUa0eHJHWjbAU3xWjCsfnko)xpvyhsutSF(0rOV88LAFviijfYegSBWSyKpunT5lbXPV88fsui5ddrHetPEqM1J)OfyLkAu6lpFZOnGXowO6GmFdGJVb2xku8nJ2ag7yHQdY8LJV85lTanz0MVaAKyAx94pAad42adCdqdwPIgLaCbOjchdHtc0CVVGt4KkAuC(VEQWoKOMy)8PJqGMmAZxan45ir1jcya3sfa3a0GvQOrjaxaAYOnFb0qImdHtf2zgCcIanr4yiCsGgjQqqskirMHWPc70FIskywgd6BaC8nW(YZ34)A5tVe55htDRtgkGOAofZ3a8nWanXwrn2TegIgd42dagWThdCdqdwPIgLaCbOjJ28fqdjYmeovyNzWjic0eHJHWjbAKOcbjPGezgcNkSt)jkPGzzmOVb47bGMyROg7wcdrJbC7bad427a4gGgSsfnkb4cqtgT5lGgsKziCQWoZGtqeOjchdHtc0ajkuyJk2TVtf(gGVu7B8FT8PxcjM2vplzxIXSLaIQ5umF5579(APgltirYrJcSsfnk9LcfFJ)RLp9sirYrJciQMtX8LNVwQXYesKC0OaRurJsFPqX34dgRSmrnHxwNmrF55B8FT8PxcjM2fRljqbevZPy(slqtSvuJDlHHOXaU9aGbClvc4gGgSsfnkb4cqtgT5lGg6prj7StSKieOrISiCoT5lGgqOlS81syiA(YONNmFti6RCyPIgL87RDnmFPpATVA08T1t4l7elPVqIczGK(tusMVtXmmL((K(sphBQqFjFOVGybIGeerYrJGeeX0UOH5lisGcGMiCmeojqd1(EVVm0SPczIyROg9LcfFLyAx9G1eEzcs6prjrz3syiAmFBNJVXwrn2XcvhK5lT(YZxjQqqskirMHWPc70FIskywgd6B7(gyF55lKOqHnQy3(EG9naFJ)RLp9sKvRUSKciQMtXamadOjFSRqazgWna3Ea4gGgSsfnkb4cqteogcNeOjJ2ag7yHQdY8nao(EmqtgT5lGMOoPpvyNDLYNodWaULpGBaAWkv0OeGlanr4yiCsGMmAdySJfQoiZxo(Eh(YZxjM2vpynHxMGK(tusu2TegIgZ3254BGbAYOnFb0e1j9Pc7SRu(0zagWTbg4gGgSsfnkb4cqteogcNeOXsnwMqHaYSPc7ShImbwPIgL(YZxQ9vIPD1dwt4LjiP)eLeLDlHHOX8LJVz0gWyhluDqMVuO4Ret7QhSMWltqs)jkjk7wcdrJ5B7C8nW(sRVuO4RLASmHcbKztf2zpezcSsfnk9LNVwQXYerDsFQWo7kLpDMaRurJsF55Ret7QhSMWltqs)jkjk7wcdrJ5B7C89aqtgT5lGg6prj7StSKieWaULkaUbObRurJsaUa0eHJHWjbAO2xfcssbJqkXQl)xvaXmA(sHIV37l4eoPIgfN)RNkSdjQj2pF6i0xA9LNVu7RcbjPqMWGDdMfJ8HQPnFjio9LNVqIcjFyikKyk1dYSE8hTaRurJsF55BgTbm2XcvhK5BaC8nW(sHIVz0gWyhluDqMVC8LpFPfOjJ28fqJet7Qh)rdya3EmWnanyLkAucWfGMiCmeojqdKOMy)8PJqHejN4y(gGVu77bU7lv9vIPD1dwt4LjiP)eLeLDlHHOX8Tn5BG9LwF55Ret7QhSMWltqs)jkjk7wcdrJ5Ba(Eh(YZ379fCcNurJIZ)1tf2He1e7NpDe6lfk(Qqqsky0tO6uHD1HzcItGMmAZxan45ir1jcya3Eha3a0GvQOrjaxaAIWXq4KanqIAI9ZNocfsKCIJ5Ba(Y3X(YZxjM2vpynHxMGK(tusu2TegIgZ3299yF5579(coHtQOrX5)6Pc7qIAI9ZNocbAYOnFb0GNJevNiGbClvc4gGgSsfnkb4cqteogcNeO5EFLyAx9G1eEzcs6prjrz3syiAmF5579(coHtQOrX5)6Pc7qIAI9ZNoc9LcfFjNWlRdr1CkMVb47X(sHIVWCKDemwMiLsMa52WmMV88fMJSJGXYePuYequnNI5Ba(EmqtgT5lGg8CKO6ebmGBVZa3a0KrB(cOH(tuYo7eljcbAWkv0OeGlagWT3ja3a0GvQOrjaxaAIWXq4Kan37l4eoPIgfN)RNkSdjQj2pF6ieOjJ28fqdEosuDIagGb0eIfcNypFe4gGBpaCdqdwPIgLaCbOHHrGM4)A5tVeSNq3HyEIqbevZPyanz0MVaAONJb0eHJHWjbASuJLjypHUdX8eHcSsfnk9LNVwcdrtyJk2TVFgTEGp23a89yF55l5eEzDiQMtX8TDFp2xE(g)xlF6LG9e6oeZtekGOAofZ3a8LAFdJsFBt(YDbv6yFP1xE(MrBaJDSq1bz(gahFdmGbClFa3a0GvQOrjaxaAIWXq4Kanu779(coHtQOrX5)6Pc7qIAI9ZNoc9LcfFviijfmcPeRU8FvbeZO5lT(YZxQ9vHGKuityWUbZIr(q10MVeeN(YZxirHKpmefsmL6bzwp(JwGvQOrPV88nJ2ag7yHQdY8nao(gyFPqX3mAdySJfQoiZxo(YNV0c0KrB(cOrIPD1J)ObmGBdmWnanyLkAucWfGMiCmeojqJcbjPGriLy1L)RkGygnFPqX379fCcNurJIZ)1tf2He1e7NpDec0KrB(cObphjQorad4wQa4gGgSsfnkb4cqJezr4CAZxanTzsFTegIMVXwr9uH(omFLdlv0OKFFz0hlE5Rsgd6R9(AxOVSPc1yBWsyiA(gIfcNOV6Hz(ofZWukaAYOnFb0ajQEgT5RUEygqdZGt0aU9aqteogcNeOj2kQXowO6GmF547bGg9WSELQiqtiwiCIagWThdCdqdwPIgLaCbOjJ28fqd9NOKD2jwsec0eHJHWjbAO234)A5tVe55htDRtgkGOAofZ3299yF55ReviijfKiZq4uHD6prjfeN(sHIVsuHGKuqImdHtf2P)eLuWSmg0329nW(sRV88LAFjNWlRdr1CkMVb4B8FT8PxcjM2vplzxIXSLaIQ5umFPQVh4UVuO4l5eEzDiQMtX8TDFJ)RLp9sKNFm1TozOaIQ5umFPfOj2kQXULWq0ya3EaWaU9oaUbObRurJsaUa0KrB(cOHezgcNkSZm4eebAIWXq4KansuHGKuqImdHtf2P)eLuWSmg03a44BG9LNVX)1YNEjYZpM6wNmuar1CkMVb47X(sHIVsuHGKuqImdHtf2P)eLuWSmg03a89aqtSvuJDlHHOXaU9aGbClvc4gGgSsfnkb4cqtgT5lGgsKziCQWoZGtqeOjchdHtc0e)xlF6Lip)yQBDYqbevZPy(2UVh7lpFLOcbjPGezgcNkSt)jkPGzzmOVb47bGMyROg7wcdrJbC7bad427mWnanyLkAucWfGMmAZxanKiZq4uHDMbNGiqJezr4CAZxan3CnmFhMVijjgTbmQB5l5O1i0x6xt8Yx2OY8fepYn(wiHbtn)(Qqy(YUEcT03ticglZ30xweReoVV0Vqi6RDH(Ms5x(ELmFR3UMk0x79fIXxvflPaOjchdHtc0KrBaJD5BcsKziCQWo9NOK(2ohFJTIASJfQoiZxE(krfcssbjYmeovyN(tusbZYyqFdWxQaWamGMqSq4ebUb42da3a0GvQOrjaxaAIWXq4Kan37l4eoPIgfN)RNkSdjQj2pF6i0xE(sTVkeKKcgHuIvx(VQaIz08LcfFHe1e7NpDekKi5ehZ3a447Ha7lT(sHIVNOjcty43sJImAdy0xE(cjk03a44BG9LcfFjNWlRdr1CkMVb47bU7lpFV3xjQqqskirMHWPc70FIskiobAYOnFb0iX0U6XF0agWT8bCdqdwPIgLaCbOjchdHtc0qTVwQXYesKC0OaRurJsFPqX34dgRSmrnHxwNmrFPqXxirHKpmefNxycF1VqMaRurJsFP1xE(sTV37l4eoPIgfN)RNkSdjkK5lfk(Q8mMV88LCcVSoevZPy(gGVh7lTanz0MVaAYQvxwsad42adCdqdwPIgLaCbOjchdHtc0aoHtQOrHAY1Fy)e(rwpJ2ag9LNVsuHGKuqImdHtf2P)eLuWSmg032547bF55B8FT8PxI88JPU1jdfqunNI1rUDIrdL(2UVh7lpFV3xWjCsfnko)xpvyhsuidOjJ28fqd9NOKD2jwsecya3sfa3a0GvQOrjaxaAIWXq4KansuHGKuqImdHtf2P)eLuWSmg0329nW(YZ379fCcNurJIZ)1tf2HefY8LcfFLOcbjPGezgcNkSt)jkPG40xE(soHxwhIQ5umFdWxQ9vIkeKKcsKziCQWo9NOKcMLXG(2M8nmk9LwGMmAZxan0FIs2zNyjriGbC7Xa3a0GvQOrjaxaAIWXq4KanqIAI9ZNocfsKCIJ5BaC8LpU7lpFV3xWjCsfnko)xpvyhsutSF(0riqtgT5lGgjM2vp(JgWaU9oaUbObRurJsaUa0eHJHWjbAKOcbjPGezgcNkSt)jkPGzzmOVb4lv4lpFV3xWjCsfnko)xpvyhsuidOjJ28fqdjYmeovyNzWjicya3sLaUbObRurJsaUa0eHJHWjbAU3xWjCsfnko)xpvyhsutSF(0riqtgT5lGgjM2vp(JgWaU9odCdqdwPIgLaCbOjchdHtc0irfcssbjYmeovyN(tusbZYyqFBNJVh8LNVqIc9naF5ZxE(EVVGt4KkAuC(VEQWoKOqMV88n(Vw(0lrE(Xu36KHciQMtX6i3oXOHsFB33JbAYOnFb0q)jkzNDILeHagGb0eFWyLLXaUb42da3a0GvQOrjaxaAIWXq4KanGt4KkAuWS(PoRAQqF55lKOMy)8PJqHejN4y(2UVhUdF55l1(g)xlF6Lip)yQBDYqbevZPy(sHIV37RLASmrcvB1FYUDHDzQwOuGvQOrPV88n(Vw(0lHmHb7gmlg5dvtB(sar1CkMV06lfk(Q8mMV88LCcVSoevZPy(gGVhoa0KrB(cOHrpHQtf2vhMbya3YhWnanyLkAucWfGMmAZxanm6juDQWU6WmGgjYIW50MVaAAqZx79LGH(MKgc9np)OVdZ3V89UGOVjZx799eIGXY89bJWyEEovOVhHJSV0Vgn6ldnBQqFjo99UGinmGMiCmeojqt8FT8PxI88JPU1jdfqunNI5lpFP23mAdySJfQoiZ3254lF(YZ3mAdySJfQoiZ3a447X(YZxirnX(5thHcjsoXX8TDFpWDFPQVu7BgTbm2XcvhK5BBY37WxA9LNVGt4KkAuKsjRdr1CkFPqX3mAdySJfQoiZ3299yF55lKOMy)8PJqHejN4y(2UVub39Lwad42adCdqdwPIgLaCbOjchdHtc0aoHtQOrbZ6N6SQPc9LNV37l7j0ktjfAmLDLwDKBP6PgfyLkAu6lpFP234)A5tVe55htDRtgkGOAofZxku89EFTuJLjsOAR(t2TlSlt1cLcSsfnk9LNVX)1YNEjKjmy3GzXiFOAAZxciQMtX8LwF55lKOqHnQy3(ov4B7(QqqskGe1e7XhcjoT5lbevZPy(sHIVkpJ5lpFjNWlRdr1CkMVb4lFhaAYOnFb0KkV6uPnF11JQcGbClvaCdqdwPIgLaCbOjchdHtc0aoHtQOrbZ6N6SQPc9LNVu7l7j0ktjfAmLDLwDKBP6PgfyLkAu6lfk(YEcTYusrqe8uS()uzq9uHcSsfnk9LwF55l1(kFtquxVUvxrpHxwx(MaIQ5umFB33dh8LcfFV3xl1yzcI661T6k6j8YeyLkAu6lpFJ)RLp9sityWUbZIr(q10MVequnNI5lTanz0MVaAsLxDQ0MV66rvbWaU9yGBaAWkv0OeGlanr4yiCsGgWjCsfnksPK1HOAoLV88fsuOWgvSBFNk8TDFviijfqIAI94dHeN28LaIQ5umGMmAZxanPYRovAZxD9OQaya3Eha3a0GvQOrjaxaAIWXq4KanGt4KkAuWS(PoRAQqF55l1(g)xlF6Lip)yQBDYqbevZPy(2UVh4UVuO479(APgltKq1w9NSBxyxMQfkfyLkAu6lpFJ)RLp9sityWUbZIr(q10MVequnNI5lT(sHIVkpJ5lpFjNWlRdr1CkMVb47HJbAYOnFb0WUYyqn2TlStu0FOD1cWaULkbCdqdwPIgLaCbOjchdHtc0aoHtQOrrkLSoevZP8LNVu7Ret7QNLSlXy2sytm4uH(sHIVWCKDemwMiLsMaIQ5umFdGJVhOcFPfOjJ28fqd7kJb1y3UWorr)H2vlad427mWnanyLkAucWfGMiCmeojqd7j0ktjfNemJqJDesCAZxcSsfnkbAYOnFb0qQr2veMKgGbyanNqm(QkPbCdWThaUbOjJ28fqZ5BZxanyLkAucWfad4w(aUbOjJ28fqdmhg2LykbAWkv0OeGlagWTbg4gGMmAZxanKAKDfHjPb0GvQOrjaxamGBPcGBaAWkv0OeGlanz0MVaAsOAR(t2TlSlXuc0eHJHWjbAU3xl1yzcgHQ6x9Weg(T0OaRurJsGMtigFvL062OIanbgWaU9yGBaAWkv0OeGlan)jqddTHeOjchdHtc0yWPcIMWoiUswNGHDfcssF55l1(AWPcIMWoiI)RLp9sijGPnF5liSVuXX(YXxU7lTansKfHZPnFb0CKaNAI0qMVPVgCQGOX8n(Vw(0l(9voGhjk9vPLVuXXcFV5Ay(spz(gVEgw(MmFjQRx3Yx6pmiZ3V8Lko2xgg)s6RcbKz(gBf1iJFFvimFVsMV2)(QMvlFJsOVijjgnMV27B4ag9n9n(Vw(0lb3escyAZx(khWd7H(ofZWuk8Tnt67y0W8fCQjqFVsMV17levZPKi0xiAeWY3d87lQzOVq0iGLVCxCSaObCc7vQIangCQGO1p0zTQiqtgT5lGgWjCsfnc0ao1eyh1meOH7IJbAaNAceO5aGbC7DaCdqdwPIgLaCbO5pbAyOnKanz0MVaAaNWjv0iqd4e2RufbAm4ubrRZxN1QIanr4yiCsGgdovq0egFIRK1jyyxHGK0xE(sTVgCQGOjm(eX)1YNEjKeW0MV8fe2xQ4yF54l39LwGgWPMa7OMHanCxCmqd4utGanhamGBPsa3a0GvQOrjaxaA(tGggAdjqteogcNeO5EFn4ubrtyhexjRtWWUcbjPV881GtfenHXN4kzDcg2viij9LcfFn4ubrty8jUswNGHDfcssF55l1(sTVgCQGOjm(eX)1YNEjKeW0MV8fK(AWPcIMW4tOqqs2LeW0MV8LwFBt(sTVheh7lv91GtfenHXN4kzDfcssFP132KVu7l4eoPIgfgCQGO15RZAvrFP1xA9TDFP2xQ91GtfenHDqe)xlF6LqsatB(Yxq6RbNkiAc7GqHGKSljGPnF5lT(2M8LAFpio2xQ6RbNkiAc7G4kzDfcssFP132KVu7l4eoPIgfgCQGO1p0zTQOV06lTansKfHZPnFb0CKy2OMgY8n91GtfenMVGtnb6RslFJV6zcNk0x7c9n(Vw(0lFFsFTl0xdovq043x5aEKO0xLw(AxOVscyAZx((K(AxOVkeKK(oMVNWh8irMW370jZ30xMbXk0U8v9Ld5GqFT33Wbm6B671eEHqFpHZdhRLV27lZGyfAx(AWPcIgJFFtMV0rT23K5B6R6lhYbH(s(qFhsFtFn4ubrZx6Jw77d9L(O1(wV5lRvf9L(yx(g)xlF6fta0aoH9kvrGgdovq06NW5HJ1cOjJ28fqd4eoPIgbAaNAcSJAgc0CaObCQjqGg(amGBVZa3a0GvQOrjaxaA(tGggAanz0MVaAaNWjv0iqd4utGanwQXYejuTv)j72f2LPAHsbwPIgL(YZ34xsIXeXVa)X0MV6pz3UWUetPaMvqFBNJV3jansKfHZPnFb0CKaNAI0qMVrcielZxgAeN(s(qFTl0xUgrw2yT89j9feC(Xu36KH(Exq8i4lssIrJb0aoH9kvrGgscTUhLqadWaAI)RLp9IbCdWThaUbObRurJsaUa0eHJHWjbAaNWjv0Oqn56pSh)xlF6fRNrBaJ(sHIVNOjcty43sJImAdy0xE(EIMimHHFlnkGOAofZ3a44lF3HVuO4l5eEzDiQMtX8naF57oaAYOnFb0C(28fGbClFa3a0GvQOrjaxaAIWXq4KanX)1YNEjiQRx3QRONWltar1CkMVb4lvYxE(g)xlF6LqMWGDdMfJ8HQPnFjGOAofRJC7eJgk9naFPs(YZxl1yzcI661T6k6j8YeyLkAu6lpFP234)A5tVe55htDRtgkGOAofRJC7eJgk9naFPs(YZxWjCsfnkij06Euc9LcfFV3xWjCsfnkij06Euc9LwFPqX3791snwMGOUEDRUIEcVmbwPIgL(sHIVkpJ5lpFjNWlRdr1CkMVb4BGpgOjJ28fqtcvB1FYUDHDjMsad42adCdqdwPIgLaCbOjJ28fqd7j0DiMNieOjchdHtc0yjmenHnQy3((z06b(yFdW3J9LNVwcdrtyJk2TVlh03299yF55BgTbm2XcvhK5BaC8nWanXwrn2TegIgd42dagWTubWnanyLkAucWfGMmAZxane11RB1v0t4Lb0irweoN28fqZD6xlz(Yf9eEz(s(qFjo91EFp2xgg)sY81EFzTQOV0h7YxqW5htDRtgYVVTr7cH0hgYVVem0x6JD5liMWG(Edmlg5dvtB(sa0eHJHWjbAaNWjv0OGz9tDw1uH(YZxQ9n(Vw(0lrE(Xu36KHciQMtX6i3oXOHsFdW3J9LcfFJ)RLp9sKNFm1TozOaIQ5uSoYTtmAO03299a39LwF55l1(g)xlF6LqMWGDdMfJ8HQPnFjGOAofZ3a8nmk9LcfFviijfYegSBWSyKpunT5lbXPV0cya3EmWnanyLkAucWfGMiCmeojqd4eoPIgfPuY6qunNYxku8v5zmF55l5eEzDiQMtX8naF57aqtgT5lGgI661T6k6j8YamGBVdGBaAWkv0OeGlanr4yiCsGgWjCsfnkyw)uNvnvOV88LAFLVjiQRx3QRONWlRlFtar1CkMVuO479(APgltquxVUvxrpHxMaRurJsFPfOjJ28fqJmHb7gmlg5dvtB(cWaULkbCdqdwPIgLaCbOjchdHtc0aoHtQOrrkLSoevZP8LcfFvEgZxE(soHxwhIQ5umFdWx(oa0KrB(cOrMWGDdMfJ8HQPnFbya3ENbUbObRurJsaUa0eHJHWjbAYOnGXowO6GmF547bF55ReviijfKiZq4uHD6prjfmlJb9TDo(sf(YZxQ99EFbNWjv0OGKqR7rj0xku8fCcNurJcscTUhLqF55l1(g)xlF6LGOUEDRUIEcVmbevZPy(2UVh4UVuO4B8FT8Pxczcd2nywmYhQM28LaIQ5uSoYTtmAO03299a39LNV37RLASmbrD96wDf9eEzcSsfnk9LwFPfOjJ28fqtE(Xu36KHagWT3ja3a0GvQOrjaxaAYOnFb0KNFm1ToziqteogcNeOjJ2ag7yHQdY8TDo(YNV88vIkeKKcsKziCQWo9NOKcMLXG(2UVb2xE(EVVsmTREwYUeJzlHnXGtfc0eBf1y3syiAmGBpaya3EG7a3a0GvQOrjaxaAIWXq4KanqIAI9ZNocfsKCIJ5Ba(EGk8LNVX)1YNEjiQRx3QRONWltar1CkMVb47Ha7lpFJ)RLp9sityWUbZIr(q10MVequnNI1rUDIrdL(gGVhcmqtgT5lGggHQ6x9Weg(T0iGbC7Hda3a0GvQOrjaxaAIWXq4KanGt4KkAuWS(PoRAQqF55ReviijfKiZq4uHD6prjfmlJb9naF5ZxE(sTVNOjYZp2dVEcTiJ2ag9LcfFviijfYegSBWSyKpunT5lbXPV88n(Vw(0lrE(Xu36KHciQMtX8TDFpWDFPfOjJ28fqdrD96w9KXscTbya3EGpGBaAWkv0OeGlanz0MVaAiQRx3QNmwsOnGMiCmeojqtgTbm2XcvhK5B7C8LpF55ReviijfKiZq4uHD6prjfmlJb9naF5ZxE(sTVNOjYZp2dVEcTiJ2ag9LcfFviijfYegSBWSyKpunT5lbXPVuO4B8FT8PxcjM2vplzxIXSLaIQ5umFdW3WO0xAbAITIASBjmengWThamGBpeyGBaAWkv0OeGlanr4yiCsGM799enr41tOfz0gWiqtgT5lGgyomSlXucyagqJbNkiAmGBaU9aWnanyLkAucWfGMmAZxantXIqclv0yNRrKLrO2Li4jIanr4yiCsGgQ9n(Vw(0lbrD96wDf9eEzciQMtX8TDF5J7(sHIVX)1YNEjKjmy3GzXiFOAAZxciQMtX6i3oXOHsFB3x(4UV06lpFP23mAdySJfQoiZ3254lF(sHIVNOjsOARE41tOfz0gWOVuO47jAI88J9WRNqlYOnGrF55l1(APgltquxVUvpzSKqBcSsfnk9LcfFLyAx9G1eEzc5Wsfn2Z3K(sRVuO47jAIWeg(T0OiJ2ag9LwFPqXxLNX8LNVKt4L1HOAofZ3a8LVd(sHIVwcdrtyJk2TVFgToFC33a89yGMkvrGMPyriHLkASZ1iYYiu7se8erad4w(aUbObRurJsaUa0KrB(cOXGtfeTdansKfHZPnFb0CZf6RbNkiA(sFSlFTl03Rj8czMViZg10qPVGtnbYVV0hT2xf0xcgk9LCGmZ3SK(EMdeL(sFSlFbbNFm1TozOVupK(Qqqs67W89WX(YW4xsMVp0xnYy067d9Ll6j8YajiEJVupK(gcX0qOV2vw(E4yFzy8ljJwGMiCmeojqZ9(coHtQOrb7eJd5GYUbNkiA(YZxQ9LAFn4ubrtyhekeKKDjbmT5lFdGJVho2xE(g)xlF6Lip)yQBDYqbevZPy(2UV8XDFPqXxdovq0e2bHcbjzxsatB(Y3299WX(YZxQ9n(Vw(0lbrD96wDf9eEzciQMtX8TDF5J7(sHIVX)1YNEjKjmy3GzXiFOAAZxciQMtX6i3oXOHsFB3x(4UV06lfk(MrBaJDSq1bz(2ohF5ZxE(QqqskKjmy3GzXiFOAAZxcItFP1xE(sTV37RbNkiAcJpXvY6X)1YNE5lfk(AWPcIMW4te)xlF6LaIQ5umFPqXxWjCsfnkm4ubrRFcNhowlF547bFP1xA9LcfFn4ubrtyhekeKKDjbmT5lFBNJVKt4L1HOAofdWaUnWa3a0GvQOrjaxaAIWXq4Kan37l4eoPIgfStmoKdk7gCQGO5lpFP2xQ91GtfenHXNqHGKSljGPnF5BaC89WX(YZ34)A5tVe55htDRtgkGOAofZ329LpU7lfk(AWPcIMW4tOqqs2LeW0MV8TDFpCSV88LAFJ)RLp9squxVUvxrpHxMaIQ5umFB3x(4UVuO4B8FT8Pxczcd2nywmYhQM28LaIQ5uSoYTtmAO0329LpU7lT(sHIVz0gWyhluDqMVTZXx(8LNVkeKKczcd2nywmYhQM28LG40xA9LNVu779(AWPcIMWoiUswp(Vw(0lFPqXxdovq0e2br8FT8PxciQMtX8LcfFbNWjv0OWGtfeT(jCE4yT8LJV85lT(sRVuO4RbNkiAcJpHcbjzxsatB(Y3254l5eEzDiQMtXaAYOnFb0yWPcIgFagWTubWnanyLkAucWfGMmAZxangCQGODaOrISiCoT5lGM2mPVFPB57xOVF5lbd91GtfenFpHp4rImFtFviij53xcg6RDH((2fc99lFJ)RLp9s4BBe67q6BHJDHqFn4ubrZ3t4dEKiZ30xfcss(9LGH(Q82LVF5B8FT8PxcGMiCmeojqZ9(AWPcIMWoiUswNGHDfcssF55l1(AWPcIMW4te)xlF6LaIQ5umFPqX3791GtfenHXN4kzDcg2viij9Lwad42JbUbObRurJsaUa0eHJHWjbAU3xdovq0egFIRK1jyyxHGK0xE(sTVgCQGOjSdI4)A5tVequnNI5lfk(EVVgCQGOjSdIRK1jyyxHGK0xAbAYOnFb0yWPcIgFagGb0irYKqBa3aC7bGBaAYOnFb0OoLStcrKkdc0GvQOrjaxamGB5d4gGgSsfnkb4cqZFc0WqdOjJ28fqd4eoPIgbAaNAceOHAFrUgXCEIsXuSiKWsfn25AezzeQDjcEIOV88n(Vw(0lXuSiKWsfn25AezzeQDjcEIOaIPSLV0c0irweoN28fqZrgIGXY8LDIXHCqPVgCQGOX8vbNk0xcgk9L(yx(Me2RM2e9vpfYaAaNWELQiqd7eJd5GYUbNkiAagWTbg4gGgSsfnkb4cqZFc0WqdOjJ28fqd4eoPIgbAaNAceOj(Vw(0lbJqv9REycd)wAuar1CkMVb47X(YZxl1yzcgHQ6x9Weg(T0OaRurJsF55l1(APgltquxVUvxrpHxMaRurJsF55B8FT8PxcI661T6k6j8YequnNI5Ba(EiW(YZ34)A5tVeYegSBWSyKpunT5lbevZPyDKBNy0qPVb47Ha7lfk(EVVwQXYee11RB1v0t4LjWkv0O0xAbAaNWELQiqZ5)6Pc7qIAI9ZNocbmGBPcGBaAWkv0OeGlan)jqddnGMmAZxanGt4KkAeObCQjqGgl1yzc2tO7qmprOaRurJsF55lKOqFdWx(8LNVwcdrtyJk2TVFgTEGp23a89yF55l5eEzDiQMtX8TDFpgObCc7vQIanN)RNkSdjkKbya3EmWnanyLkAucWfGM)eOHHgqtgT5lGgWjCsfnc0ao1eiqtgTbm2XcvhK5lhFp4lpFP2379fMJSJGXYePuYei3gMX8LcfFH5i7iySmrkLmXu(2UVho2xAbAaNWELQiqdZ6N6SQPcbmGBVdGBaAWkv0OeGlan)jqddnGMmAZxanGt4KkAeObCQjqGMmAdySJfQoiZ3254lF(YZxQ99EFH5i7iySmrkLmbYTHzmFPqXxyoYocgltKsjtGCBygZxE(sTVWCKDemwMiLsMaIQ5umFB33J9LcfFjNWlRdr1CkMVT77bU7lT(slqd4e2RufbAsPK1HOAofGbClvc4gGgSsfnkb4cqZFc0WqdOjJ28fqd4eoPIgbAaNAceOHAFTuJLjyeQQF1dty43sJcSsfnk9LNV377jAIWeg(T0OiJ2ag9LNVX)1YNEjyeQQF1dty43sJciQMtX8LcfFV3xl1yzcgHQ6x9Weg(T0OaRurJsFP1xE(sTVkeKKcI661T6jJLeAtqC6lfk(APgltKq1w9NSBxyxMQfkfyLkAu6lpFprtKNFShE9eArgTbm6lfk(QqqskKjmy3GzXiFOAAZxcItFPqX3mAdySJfQoiZ3254lF(YZxjM2vplzxIXSLWMyWPc9LwGgWjSxPkc0OMC9h2J)RLp9I1ZOnGrad427mWnanyLkAucWfGM)eOHHgqtgT5lGgWjCsfnc0ao1eiqt8bJvwMOMWlRtMOV88vIPD1Zs2LymBjSjgCQqF55RcbjPqIPDX6scuWSmg03a8Lk8LcfFviijfQje(0rzpevz2xyhRRSIOkwMG40xku8vHGKuyxWrR7medIqbXPVuO4RcbjPGeIfvMbLD1Vyg8zJ1sqC6lfk(Qqqsk0yk7kT6i3s1tnkiobAaNWELQiqJAY1Fy)e(rwpJ2agbmGBVtaUbObRurJsaUa0KrB(cO5jmfiMbbAKilcNtB(cO5i6CklNAQqFpImqcnwMVhzDgsG(omFtFpHZdhRfqteogcNeOr(Ma8aj0yz9tDgsGciscr2vQOrF5579(APgltquxVUvxrpHxMaRurJsF5579(cZr2rWyzIukzcKBdZyagWTh4oWnanyLkAucWfGMmAZxanpHPaXmiqteogcNeOr(Ma8aj0yz9tDgsGciscr2vQOrF55BgTbm2XcvhK5B7C8LpF55l1(EVVwQXYee11RB1v0t4LjWkv0O0xku8n(Vw(0lbrD96wDf9eEzciQMtX8LNVkeKKcI661T6k6j8Y6keKKc5tV8LwGMyROg7wcdrJbC7bad42dhaUbObRurJsaUa0KrB(cO5jmfiMbbA0tH9OeO5oaAIWXq4Kanz0gWyx(Ma8aj0yz9tDgsG(gGVz0gWyhluDqMV88nJ2ag7yHQdY8TDo(YNV88LAFV3xl1yzcI661T6k6j8YeyLkAu6lfk(g)xlF6LGOUEDRUIEcVmbevZPy(YZxfcssbrD96wDf9eEzDfcssH8Px(slqJezr4CAZxanTzsFTleI(Mq0xSq1bz(Qom2uH(Ee5iZVV55PULVJ5l1keMV17R6drFTRS89Ri67jc99o8LHXVKmAfagWTh4d4gGgSsfnkb4cqteogcNeObsui5ddrbJ4eHmdMtjWkv0O0xE(sTVY3eKWNzDsemcfqKeISRurJ(sHIVY3ek6)L9tDgsGciscr2vQOrFPfOjJ28fqZtykqmdcya3EiWa3a0GvQOrjaxaAYOnFb0q)jkzNDILeHansKfHZPnFb0CeqsiYUqMVGiM2fZxqKaPH5RcbjPVCDcM5Rcs(q0xjM2fZxjb6lwsgqteogcNeOj(GXkltut4L1jt0xE(kX0U6zj7smMTez0gWyhIQ5umFdWxQ9nmk9Tn57bXX(sRV88vIPD1Zs2LymBjSjgCQqad42dubWnanyLkAucWfGgggbAI)RLp9sWEcDhI5jcfqunNIb0KrB(cOHEogqteogcNeOXsnwMG9e6oeZtekWkv0O0xE(AjmenHnQy3((z06b(yFdW3J9LNVwcdrtyJk2TVlh03299yF55B8FT8Pxc2tO7qmprOaIQ5umFdWxQ9nmk9Tn5l3fuPJ9LwF55BgTbm2XcvhK5lhFpaya3E4yGBaAWkv0OeGlansKfHZPnFb0acLJ5l5d9feX0UOH5lisGGeerYrJ(oK(E7eEz(sLnrFT33q08LzqScTlFviij9vjJb9nz5jqddJanX)1YNEjKyAxSUKafqunNIb0KrB(cOHEogqteogcNeOj(GXkltut4L1jt0xE(g)xlF6LqIPDX6scuar1CkMVb4Byu6lpFZOnGXowO6GmF547bad42d3bWnanyLkAucWfGgggbAI)RLp9sirYrJciQMtXaAYOnFb0qphdOjchdHtc0eFWyLLjQj8Y6Kj6lpFJ)RLp9sirYrJciQMtX8naFdJsF55BgTbm2XcvhK5lhFpaya3EGkbCdqdwPIgLaCbOrISiCoT5lGgqq0MV8LRgMX8nlPVTXtSqiZxQBJNyHqgiBqUgbwrK5lrXiopFOHsFNY3uk)sqlqtgT5lGMyQ19mAZxD9WmGg9WSELQiqJbNkiAmad42d3zGBaAWkv0OeGlanz0MVaAIPw3ZOnF11dZaA0dZ6vQIanXhmwzzmad42d3ja3a0GvQOrjaxaAYOnFb0etTUNrB(QRhMb0OhM1RufbAGzCsndWaULpUdCdqdwPIgLaCbOjJ28fqtm16EgT5RUEygqJEywVsveOj(Vw(0lgGbClFhaUbObRurJsaUa0eHJHWjbAaNWjv0OiLswhIQ5u(YZxQ9n(Vw(0lHet7QNLSlXy2sar1CkMVb47bU7lpFV3xl1yzcjsoAuGvQOrPVuO4B8FT8PxcjsoAuar1CkMVb47bU7lpFTuJLjKi5OrbwPIgL(sHIVXhmwzzIAcVSozI(YZ34)A5tVesmTlwxsGciQMtX8naFpWDFP1xE(EVVsmTREwYUeJzlHnXGtfc0KrB(cObsu9mAZxD9WmGg9WSELQiqt(yNHgXjGbClF8bCdqdwPIgLaCbOjchdHtc0KrBaJDSq1bz(2ohF5ZxE(kX0U6zj7smMTe2edoviqdZGt0aU9aqtgT5lGgir1ZOnF11dZaA0dZ6vQIan5JDfciZamGB5lWa3a0GvQOrjaxaAIWXq4Kanz0gWyhluDqMVTZXx(8LNVu779(kX0U6zj7smMTe2edovOV88LAFJ)RLp9siX0U6zj7smMTequnNI5B7(EG7(YZ3791snwMqIKJgfyLkAu6lfk(g)xlF6LqIKJgfqunNI5B7(EG7(YZxl1yzcjsoAuGvQOrPVuO4B8bJvwMOMWlRtMOV88n(Vw(0lHet7I1LeOaIQ5umFB33dC3xA9LcfFV3xWjCsfnksPK1HOAoLV0c0KrB(cObsu9mAZxD9WmGg9WSELQiqtiwiCI98rad4w(OcGBaAWkv0OeGlanr4yiCsGMmAdySJfQoiZxo(EWxku89EFbNWjv0OiLswhIQ5uanmdord42danz0MVaAIPw3ZOnF11dZaA0dZ6vQIanHyHWjcyagqdmJtQza3aC7bGBaAWkv0OeGlanz0MVaAsymlSBpeILb0irweoN28fqZriJtQzanr4yiCsGgirnX(5thHcjsoXX8TDFVJJ9LNVu77jAIWeg(T0OiJ2ag9LcfFV3xl1yzcgHQ6x9Weg(T0OaRurJsFP1xE(cjkuirYjoMVTZX3JbmGB5d4gGgSsfnkb4cqteogcNeObCcNurJc1KR)WE8FT8PxSEgTbm6lfk(EIMimHHFlnkYOnGrF557jAIWeg(T0OaIQ5umFdGJVkeKKcf9)YojbSLqsatB(Yxku8v5zmF55l5eEzDiQMtX8nao(Qqqsku0)l7KeWwcjbmT5lGMmAZxank6)LDscylad42adCdqdwPIgLaCbOjchdHtc0aoHtQOrHAY1Fyp(Vw(0lwpJ2ag9LcfFprteMWWVLgfz0gWOV889enrycd)wAuar1CkMVbWXxfcssHcczim4uHcjbmT5lFPqXxLNX8LNVKt4L1HOAofZ3a44RcbjPqbHmegCQqHKaM28fqtgT5lGgfeYqyWPcbmGBPcGBaAWkv0OeGlanr4yiCsGgfcssbrD96wDMbXk0UeeNanz0MVaA0t4LX6CDczOkwgGbC7Xa3a0GvQOrjaxaAYOnFb0Kvezgm19yQ1ansKfHZPnFb0acQiYmyQ99UPw7BmlFn4egIqFPcFpFdlBsTVkeKKm(9fZ4LV6Kztf67HJ9LHXVKmHVhX2OhQmO03Rek9n(su6RnQOVjZ30xdoHHi0x79niIN(oMVqmLPIgfanr4yiCsGgWjCsfnkutU(d7X)1YNEX6z0gWOVuO47jAIWeg(T0OiJ2ag9LNVNOjcty43sJciQMtX8nao(E4yFPqXxLNX8LNVKt4L1HOAofZ3a447HJbmGBVdGBaAWkv0OeGlanr4yiCsGMmAdySJfQoiZ3254lF(sHIVu7lKOqHejN4y(2ohFp2xE(cjQj2pF6iuirYjoMVTZX37G7(slqtgT5lGMegZc7NeAgcya3sLaUbObRurJsaUa0eHJHWjbAaNWjv0Oqn56pSh)xlF6fRNrBaJ(sHIVNOjcty43sJImAdy0xE(EIMimHHFlnkGOAofZ3a44RcbjPGCGOI(FPqsatB(Yxku8v5zmF55l5eEzDiQMtX8nao(QqqskihiQO)xkKeW0MVaAYOnFb0qoqur)VeWaU9odCdqdwPIgLaCbOjchdHtc0KrBaJDSq1bz(YX3d(YZxQ9vHGKuquxVUvNzqScTlbXPVuO4RYZy(YZxYj8Y6qunNI5Ba(ESV0c0KrB(cOrjd7pz3GtmidWamadObmczZxa3Yh357a3PsC)aqd9ewtfYaAaHabhHBBZ3sL3wF99Ml03r98HMVKp0xAYh7m0ioPXxiY1igik9L9QOVjH9QPHsFJxzfImHdkxnf67H267D)cmcnu6lnwQXYebIgFT3xASuJLjcKaRurJsA8L6dCJwHdkxnf6lFT137(fyeAO0xAGefs(WqueiA81EFPbsui5ddrrGeyLkAusJVuFGB0kCq5QPqFVJ267D)cmcnu6lnwQXYebIgFT3xASuJLjcKaRurJsA8LA(4gTchuhuqiqWr4228Tu5T1xFV5c9DupFO5l5d9LM8XUcbKz04le5AedeL(YEv03KWE10qPVXRScrMWbLRMc9nWT137(fyeAO0xASuJLjcen(AVV0yPglteibwPIgL04l1bMB0kCq5QPqFPI267D)cmcnu6lnqIcjFyikcen(AVV0ajkK8HHOiqcSsfnkPXxQpWnAfoOoOGqGGJWTT5BPYBRV(EZf67OE(qZxYh6lngCQGOXOXxiY1igik9L9QOVjH9QPHsFJxzfImHdkxnf67H267D)cmcnu6lnwQXYebIgFT3xASuJLjcKaRurJsA8L6dCJwHdkxnf6lFT137(fyeAO0xAm4ubrtCqeiA81EFPXGtfenHDqeiA8L6aZnAfoOC1uOV81wFV7xGrOHsFPXGtfenbFIarJV27lngCQGOjm(ebIgFPMpUrRWbLRMc9nWT137(fyeAO0xAm4ubrtCqeiA81EFPXGtfenHDqeiA8LA(4gTchuUAk03a3wFV7xGrOHsFPXGtfenbFIarJV27lngCQGOjm(ebIgFPoWCJwHdkxnf6lv0wFV7xGrOHsFPXGtfenXbrGOXx79Lgdovq0e2brGOXxQpWnAfoOC1uOVurB99UFbgHgk9Lgdovq0e8jcen(AVV0yWPcIMW4teiA8LA(4gTchuUAk03JBRV39lWi0qPV0yWPcIM4Giq04R9(sJbNkiAc7Giq04l18XnAfoOC1uOVh3wFV7xGrOHsFPXGtfenbFIarJV27lngCQGOjm(ebIgFP(a3Ov4G6Gccbcoc32MVLkVT(67nxOVJ65dnFjFOV0eIfcNin(crUgXarPVSxf9njSxnnu6B8kRqKjCq5QPqF5RT(E3VaJqdL(sdKOqYhgIIarJV27lnqIcjFyikcKaRurJsA8L6dCJwHdQdkiei4iCBB(wQ826RV3CH(oQNp08L8H(st8bJvwgJgFHixJyGO0x2RI(Me2RMgk9nELviYeoOC1uOVhARV39lWi0qPV0yPglteiA81EFPXsnwMiqcSsfnkPXxQpWnAfoOC1uOVbUT(E3VaJqdL(sJLASmrGOXx79Lgl1yzIajWkv0OKgFP(a3Ov4GYvtH(g4267D)cmcnu6lnSNqRmLueiA81EFPH9eALPKIajWkv0OKgFP(a3Ov4GYvtH(sfT137(fyeAO0xASuJLjcen(AVV0yPglteibwPIgL04l1h4gTchuUAk0xQOT(E3VaJqdL(sd7j0ktjfbIgFT3xAypHwzkPiqcSsfnkPXxQ5JB0kCq5QPqFVJ267D)cmcnu6lnwQXYebIgFT3xASuJLjcKaRurJsA8L6dCJwHdkxnf67DUT(E3VaJqdL(sd7j0ktjfbIgFT3xAypHwzkPiqcSsfnkPX3089i1g5kFP(a3Ov4G6Gccbcoc32MVLkVT(67nxOVJ65dnFjFOV0CcX4RQKgn(crUgXarPVSxf9njSxnnu6B8kRqKjCq5QPqFPI267D)cmcnu6lnwQXYebIgFT3xASuJLjcKaRurJsA8nnFpsTrUYxQpWnAfoOC1uOVh3wFV7xGrOHsFBg176lRvzj38fege2x79LRisFvFjHMG57FIW0EOVudctRVuFGB0kCq5QPqFpUT(E3VaJqdL(sJbNkiAIdIarJV27lngCQGOjSdIarJVuZh3Ov4GYvtH(EhT137(fyeAO03Mr9U(YAvwYnFbHbH91EF5kI0x1xsOjy((NimTh6l1GW06l1h4gTchuUAk037OT(E3VaJqdL(sJbNkiAc(ebIgFT3xAm4ubrty8jcen(snFCJwHdkxnf6lvQT(E3VaJqdL(2mQ31xwRYsU5liSV27lxrK(khWdB(Y3)eHP9qFPgK06l18XnAfoOC1uOVuP267D)cmcnu6lngCQGOjoicen(AVV0yWPcIMWoicen(snvWnAfoOC1uOVuP267D)cmcnu6lngCQGOj4teiA81EFPXGtfenHXNiq04l1hZnAfoOC1uOV35267D)cmcnu6lnwQXYebIgFT3xASuJLjcKaRurJsA8L6dCJwHdQdkiei4iCBB(wQ826RV3CH(oQNp08L8H(st8FT8PxmA8fICnIbIsFzVk6BsyVAAO034vwHit4GYvtH(YxB99UFbgHgk9Lgl1yzIarJV27lnwQXYebsGvQOrjn(snFCJwHdkxnf67D0wFV7xGrOHsFPXsnwMiq04R9(sJLASmrGeyLkAusJVuFGB0kCq5QPqFVZT137(fyeAO0xASuJLjcen(AVV0yPglteibwPIgL04l1h4gTchuhuqiqWr4228Tu5T1xFV5c9DupFO5l5d9LMqSq4e75J04le5AedeL(YEv03KWE10qPVXRScrMWbLRMc99qB99UFbgHgk9Lgl1yzIarJV27lnwQXYebsGvQOrjn(s9bUrRWbLRMc9LV267D)cmcnu6lnqIcjFyikcen(AVV0ajkK8HHOiqcSsfnkPXxQpWnAfoOoOGqGGJWTT5BPYBRV(EZf67OE(qZxYh6lnsKmj0gn(crUgXarPVSxf9njSxnnu6B8kRqKjCq5QPqFdCB99UFbgHgk9Lgl1yzIarJV27lnwQXYebsGvQOrjn(sDG5gTchuUAk0xQOT(E3VaJqdL(sJLASmrGOXx79Lgl1yzIajWkv0OKgFP(a3Ov4GYvtH(sLARV39lWi0qPV0yPglteiA81EFPXsnwMiqcSsfnkPXxQdm3Ov4GYvtH(EN0wFV7xGrOHsFPXsnwMiq04R9(sJLASmrGeyLkAusJVuFGB0kCq5QPqFpW9267D)cmcnu6lnwQXYebIgFT3xASuJLjcKaRurJsA8L6dCJwHdkxnf67HdT137(fyeAO0xASuJLjcen(AVV0yPglteibwPIgL04l1h4gTchuUAk03d81wFV7xGrOHsFPbsui5ddrrGOXx79LgirHKpmefbsGvQOrjn(s9bUrRWbLRMc99av0wFV7xGrOHsFPXsnwMiq04R9(sJLASmrGeyLkAusJVuFGB0kCq5QPqF57qB99UFbgHgk9Lgl1yzIarJV27lnwQXYebsGvQOrjn(snFCJwHdkxnf6lFbUT(E3VaJqdL(sJLASmrGOXx79Lgl1yzIajWkv0OKgFPMpUrRWb1b9Ml0xAiyyFmuLrJVz0MV8LEY8TEZxYNOK(oLV21W8DupFOjCqBZQNp0qPVh4UVz0MV8vpmJjCqbAoHp5OrGMJEuFbrmTlFVtvt4L57rCD96woOh9O(ckHULV3z(9LpUZ3bhuh0JEuFV7vwHiRToOh9O(2g8fei56emtflJ5R9(cIficsqejhncsqet7I5lisG(AVVFPB5B8jkZxlHHOX8L(17BcrFrUDIrdL(AVV6bm6R(RqFX6jcV81EFvtZqOVuNp2zOrC67rpqRWb9Oh132GVG4Wsfnk9TjJWHCItQ99iNrZxfmMem0xjMsFdVEcnZx1mi6l5d9LLsFbX7umHd6rpQVTbFpIztf6li0tusFBoXsIqFtLrp2GmFvFi6lPg52OOB5l1P5lvqvFzwgdY8DkMHP03N03JPkThr5liEKB8TqcdMAFZs6RA2Y3ticglZx2RI(wFBaIrFzJrK28ft4GE0J6BBW3Jy2uH(sLfzgcNk03gdobrFNYxqqB8i57q6BRNW3Rem6B921uH(IAg6R9(kFFZs6l9VOX89bJWyE6l9NOKmFhMVG4rUX3cjmyQfoOh9O(2g89UxzfIsFvZQLV0qoHxwhIQ5umA8n(LCS5RuZ81EFZZtDlFNYxLNX8LCcVmMVFPB5l1AKX89UGOV0tMH((LVgmzx0kCqp6r9Tn4liqkrPVz92fc9Tnsykqmd6lwgSLV27ldnFjo9LzWVcrOVhPZrIQtKjCqp6r9Tn47ra1j38T5gFbZe(ccAJhjF1F4e9Lnve9DmFHOEqMVF5B8lYuHqNgk9fMJSJGXYych0JEuFBd(EtBeeBJT1xFPYMr7H(2yqScTlFpHFK57u27RbNkiA(Q)WjkCqDqZOnFXeNqm(QkPrvoG88T5lh0mAZxmXjeJVQsAuLdiH5WWUetPdAgT5lM4eIXxvjnQYbKKAKDfHjP5GMrB(IjoHy8vvsJQCazcvB1FYUDHDjMs(pHy8vvsRBJkYjW8pKCU3snwMGrOQ(vpmHHFln6GEuFpsGtnrAiZ30xdovq0y(g)xlF6f)(khWJeL(Q0YxQ4yHV3CnmFPNmFJxpdlFtMVe11RB5l9hgK57x(sfh7ldJFj9vHaYmFJTIAKXVVkeMVxjZx7FFvZQLVrj0xKKeJgZx79nCaJ(M(g)xlF6LGBcjbmT5lFLd4H9qFNIzykf(2Mj9DmAy(co1eOVxjZ369fIQ5use6lency57b(9f1m0xiAeWYxUlow4GMrB(IjoHy8vvsJQCaj4eoPIg5VsvKJbNkiA9dDwRkY)FYHH2qYp4utGCoWp4utGDuZqoCxCm)XVKJnFXXGtfenXbXvY6emSRqqsYJAdovq0eheX)1YNEjKeW0MVaHbHPIJ5WDADqZOnFXeNqm(QkPrvoGeCcNurJ8xPkYXGtfeToFDwRkY)FYHH2qYp4utGCoWp4utGDuZqoCxCm)XVKJnFXXGtfenbFIRK1jyyxHGKKh1gCQGOj4te)xlF6LqsatB(cegeMkoMd3P1b9O(EKy2OMgY8n91GtfenMVGtnb6RslFJV6zcNk0x7c9n(Vw(0lFFsFTl0xdovq043x5aEKO0xLw(AxOVscyAZx((K(AxOVkeKK(oMVNWh8irMW370jZ30xMbXk0U8v9Ld5GqFT33Wbm6B671eEHqFpHZdhRLV27lZGyfAx(AWPcIgJFFtMV0rT23K5B6R6lhYbH(s(qFhsFtFn4ubrZx6Jw77d9L(O1(wV5lRvf9L(yx(g)xlF6ft4GMrB(IjoHy8vvsJQCaj4eoPIg5VsvKJbNkiA9t48WXAX)FYHH2qYp4utGC4JFWPMa7OMHCoWF8l5yZxCU3GtfenXbXvY6emSRqqsYZGtfenbFIRK1jyyxHGKKcfdovq0e8jUswNGHDfcssEutTbNkiAc(eX)1YNEjKeW0MVaHn4ubrtWNqHGKSljGPnFrBBI6dIJPQbNkiAc(exjRRqqssBBIAWjCsfnkm4ubrRZxN1QI0sB7utTbNkiAIdI4)A5tVescyAZxGWgCQGOjoiuiij7scyAZx02MO(G4yQAWPcIM4G4kzDfcssABtudoHtQOrHbNkiA9dDwRkslToOh13Je4utKgY8nsaHyz(YqJ40xYh6RDH(Y1iYYgRLVpPVGGZpM6wNm037cIhbFrssmAmh0mAZxmXjeJVQsAuLdibNWjv0i)vQICij06Euc5hCQjqowQXYejuTv)j72f2LPAHsEXVKeJjIFb(JPnF1FYUDHDjMsbmRGTZ5oXb1b9Oh13Je3WiHHsFrWiSLV2OI(AxOVz0EOVdZ3eCo6urJch0mAZxmoQtj7KqePYGoOh13JmebJL5l7eJd5GsFn4ubrJ5RcovOVemu6l9XU8njSxnTj6REkK5GMrB(IrvoGeCcNurJ8xPkYHDIXHCqz3Gtfen(bNAcKd1ixJyoprPykwesyPIg7CnISmc1UebprKx8FT8PxIPyriHLkASZ1iYYiu7se8erbetzlADqp6r99iscNurJmh0mAZxmQYbKGt4KkAK)kvroN)RNkSdjQj2pF6iKFWPMa5e)xlF6LGrOQ(vpmHHFlnkGOAoflGJ5zPgltWiuv)QhMWWVLg5rTLASmbrD96wDf9eEz8I)RLp9squxVUvxrpHxMaIQ5uSaoeyEX)1YNEjKjmy3GzXiFOAAZxciQMtX6i3oXOHYaoeykuU3snwMGOUEDRUIEcVmADqZOnFXOkhqcoHtQOr(Ruf5C(VEQWoKOqg)GtnbYXsnwMG9e6oeZteYdsuya8XZsyiAcBuXU99ZO1d8XbCmpYj8Y6qunNI1(XoOz0MVyuLdibNWjv0i)vQICyw)uNvnvi)GtnbYjJ2ag7yHQdY4CGh13dZr2rWyzIukzcKBdZyuOaZr2rWyzIukzIPA)WX06GMrB(IrvoGeCcNurJ8xPkYjLswhIQ5u8do1eiNmAdySJfQoiRDo8XJ67H5i7iySmrkLmbYTHzmkuG5i7iySmrkLmbYTHzmEudZr2rWyzIukzciQMtXA)ykuiNWlRdr1Ckw7h4oT06GMrB(IrvoGeCcNurJ8xPkYrn56pSh)xlF6fRNrBaJ8do1eihQTuJLjyeQQF1dty43sJ8U)enrycd)wAuKrBaJ8I)RLp9sWiuv)QhMWWVLgfqunNIrHY9wQXYemcv1V6Hjm8BPrA5rTcbjPGOUEDREYyjH2eeNuOyPgltKq1w9NSBxyxMQfk5DIMip)yp86j0ImAdyKcffcssHmHb7gmlg5dvtB(sqCsHsgTbm2XcvhK1oh(4jX0U6zj7smMTe2edoviToOz0MVyuLdibNWjv0i)vQICutU(d7NWpY6z0gWi)GtnbYj(GXkltut4L1jtKNet7QNLSlXy2sytm4uH8uiijfsmTlwxsGcMLXGbqfuOOqqskuti8PJYEiQYSVWowxzfrvSmbXjfkkeKKc7coADNHyqekioPqrHGKuqcXIkZGYU6xmd(SXAjioPqrHGKuOXu2vA1rULQNAuqC6GEuFpIoNYYPMk03JidKqJL57rwNHeOVdZ303t48WXA5GMrB(IrvoG8jmfiMb5Fi5iFtaEGeASS(PodjqbejHi7kv0iV7TuJLjiQRx3QRONWlJ39WCKDemwMiLsMa52WmMdAgT5lgv5aYNWuGygK)yROg7wcdrJX5a)djh5BcWdKqJL1p1zibkGijezxPIg5LrBaJDSq1bzTZHpEuFVLASmbrD96wDf9eEzuOe)xlF6LGOUEDRUIEcVmbevZPy8uiijfe11RB1v0t4L1viijfYNErRd6r9Tnt6RDHq03eI(IfQoiZx1HXMk03Jihz(9npp1T8DmFPwHW8TEFvFi6RDLLVFfrFprOV3HVmm(LKrRWbnJ28fJQCa5tykqmdYVEkShLCUd(hsoz0gWyx(Ma8aj0yz9tDgsGbKrBaJDSq1bz8YOnGXowO6GS25WhpQV3snwMGOUEDRUIEcVmkuI)RLp9squxVUvxrpHxMaIQ5umEkeKKcI661T6k6j8Y6keKKc5tVO1bnJ28fJQCa5tykqmdY)qYbsui5ddrbJ4eHmdMtXJA5Bcs4ZSojcgHciscr2vQOrkuKVju0)l7N6mKafqKeISRurJ06GEuFpcijezxiZxqet7I5lisG0W8vHGK0xUobZ8vbjFi6Ret7I5RKa9fljZbnJ28fJQCaj9NOKD2jwseY)qYj(GXkltut4L1jtKNet7QNLSlXy2sKrBaJDiQMtXcG6WOSnDqCmT8KyAx9SKDjgZwcBIbNk0bnJ28fJQCaj9Cm(zyKt8FT8Pxc2tO7qmprOaIQ5um(hsowQXYeSNq3HyEIqEwcdrtyJk2TVFgTEGpoGJ5zjmenHnQy3(UCW2pMx8FT8Pxc2tO7qmprOaIQ5uSaOomkBtCxqLoMwEz0gWyhluDqgNdoOh1xqOCmFjFOVGiM2fnmFbrceKGisoA03H03BNWlZxQSj6R9(gIMVmdIvOD5RcbjPVkzmOVjlpDqZOnFXOkhqsphJFgg5e)xlF6LqIPDX6scuar1Ckg)djN4dgRSmrnHxwNmrEX)1YNEjKyAxSUKafqunNIfqyuYlJ2ag7yHQdY4CWbnJ28fJQCaj9Cm(zyKt8FT8PxcjsoAuar1Ckg)djN4dgRSmrnHxwNmrEX)1YNEjKi5OrbevZPybegL8YOnGXowO6GmohCqpQVGGOnF5lxnmJ5BwsFBJNyHqMVu3gpXcHmq2GCncSIiZxIIrCE(qdL(oLVPu(LGwh0mAZxmQYbKXuR7z0MV66Hz8xPkYXGtfenMdAgT5lgv5aYyQ19mAZxD9Wm(Ruf5eFWyLLXCqZOnFXOkhqgtTUNrB(QRhMXFLQihygNuZCqp6r9nJ28fJQCajd5Aeyfr(hsoz0gWyhluDqgNd8UxIPD1dwt4LjKdlv0ypFtYZsnwMGrOQ(vpmHHFlnYFLQiNWeg2)tSqyBFctbIzW2sImdHtf2zgCcITLezgcNkSZm4eeBlJqv9REycd)wASTjuTv)j72f2LykBRet7Qh)rZ)qYrHGKuWiKsS6Y)vfeNTvIPD1J)OBRet7Qh)r3ww8jGHyNzWjiY)qYrIkeKKcsKziCQWo9NOKcMLXGTtfTLfFcyi2zgCcI8pKCKOcbjPGezgcNkSt)jkPGzzmy7urBjrMHWPc7mdobrh0JEuFZOnFXOkhqYqUgbwrK)HKtgTbm2XcvhKX5aV7LyAx9G1eEzc5Wsfn2Z3K8U3snwMGrOQ(vpmHHFlnYFLQiN)ele2wsKziCQWoZGtqSTKiZq4uHDMbNGyBpFB(QTe11RB1v0t4L1wzcd2nywmYhQM28vBZZpM6wNm0bnJ28fJQCazm16EgT5RUEyg)vQICI)RLp9I5GMrB(IrvoGesu9mAZxD9Wm(Ruf5Kp2zOrCY)qYbCcNurJIukzDiQMtXJ64)A5tVesmTREwYUeJzlbevZPybCG78U3snwMqIKJgPqj(Vw(0lHejhnkGOAoflGdCNNLASmHejhnsHs8bJvwMOMWlRtMiV4)A5tVesmTlwxsGciQMtXc4a3PL39smTREwYUeJzlHnXGtf6GMrB(IrvoGesu9mAZxD9Wm(Ruf5Kp2viGmJFMbNOX5a)djNmAdySJfQoiRDo8XtIPD1Zs2LymBjSjgCQqh0mAZxmQYbKqIQNrB(QRhMXFLQiNqSq4e75J8pKCYOnGXowO6GS25WhpQVxIPD1Zs2LymBjSjgCQqEuh)xlF6LqIPD1Zs2LymBjGOAofR9dCN39wQXYesKC0ifkX)1YNEjKi5OrbevZPyTFG78SuJLjKi5OrkuIpySYYe1eEzDYe5f)xlF6LqIPDX6scuar1Ckw7h4oTuOCp4eoPIgfPuY6qunNIwh0mAZxmQYbKXuR7z0MV66Hz8xPkYjeleor(zgCIgNd8pKCYOnGXowO6GmohOq5EWjCsfnksPK1HOAoLdQd6rpQVGG)i5lxiGmZbnJ28ftKp2viGmJtuN0NkSZUs5tNX)qYjJ2ag7yHQdYcGZXoOz0MVyI8XUcbKzuLdiJ6K(uHD2vkF6m(hsoz0gWyhluDqgN7GNet7QhSMWltqs)jkjk7wcdrJ1oNa7GMrB(IjYh7keqMrvoGK(tuYo7eljc5Fi5yPgltOqaz2uHD2drgpQLyAx9G1eEzcs6prjrz3syiAmoz0gWyhluDqgfksmTREWAcVmbj9NOKOSBjmenw7CcmTuOyPgltOqaz2uHD2drgpl1yzIOoPpvyNDLYNoJNet7QhSMWltqs)jkjk7wcdrJ1oNdoOz0MVyI8XUcbKzuLdiLyAx94pA(hsouRqqskyesjwD5)QciMrJcL7bNWjv0O48F9uHDirnX(5thH0YJAfcssHmHb7gmlg5dvtB(sqCYdsui5ddrHetPEqM1J)O5LrBaJDSq1bzbWjWuOKrBaJDSq1bzC4Jwh0mAZxmr(yxHaYmQYbK45ir1jY)qYbsutSF(0rOqIKtCSaO(a3PQet7QhSMWltqs)jkjk7wcdrJ1McmT8KyAx9G1eEzcs6prjrz3syiASaUdE3doHtQOrX5)6Pc7qIAI9ZNocPqrHGKuWONq1Pc7QdZeeNoOz0MVyI8XUcbKzuLdiXZrIQtK)HKdKOMy)8PJqHejN4ybW3X8KyAx9G1eEzcs6prjrz3syiAS2pM39Gt4KkAuC(VEQWoKOMy)8PJqh0mAZxmr(yxHaYmQYbK45ir1jY)qY5EjM2vpynHxMGK(tusu2TegIgJ39Gt4KkAuC(VEQWoKOMy)8PJqkuiNWlRdr1CkwahtHcmhzhbJLjsPKjqUnmJXdMJSJGXYePuYequnNIfWXoOz0MVyI8XUcbKzuLdiP)eLSZoXsIqh0mAZxmr(yxHaYmQYbK45ir1jY)qY5EWjCsfnko)xpvyhsutSF(0rOdQd6rpQVGG)i5BdAeNoOz0MVyI8XodnItoz1Qllj)djhjM2vpynHxMGK(tusu2TegIgRDoXwrn2XcvhKrHIet7QhSMWltqs)jkjk7wcdrJ1oNJPq5El1yzcfciZMkSZEiYOqbMJSJGXYePuYei3gMX4bZr2rWyzIukzciQMtXcGZHduOqoHxwhIQ5uSa4C4GdAgT5lMiFSZqJ4KQCaPet7Qh)rZ)qY5EWjCsfnko)xpvyhsutSF(0ripQviijfYegSBWSyKpunT5lbXjpirHKpmefsmL6bzwp(JMxgTbm2XcvhKfaNatHsgTbm2XcvhKXHpADqZOnFXe5JDgAeNuLdiXZrIQtK)HKZ9Gt4KkAuC(VEQWoKOMy)8PJqh0mAZxmr(yNHgXjv5assKziCQWoZGtqK)yROg7wcdrJX5a)djhjQqqskirMHWPc70FIskywgdgaNaZl(Vw(0lrE(Xu36KHciQMtXciWoOz0MVyI8XodnItQYbKKiZq4uHDMbNGi)Xwrn2TegIgJZb(hsosuHGKuqImdHtf2P)eLuWSmgmGdoOz0MVyI8XodnItQYbKKiZq4uHDMbNGi)Xwrn2TegIgJZb(hsoqIcf2OID77urauh)xlF6LqIPD1Zs2LymBjGOAofJ39wQXYesKC0ifkX)1YNEjKi5OrbevZPy8SuJLjKi5OrkuIpySYYe1eEzDYe5f)xlF6LqIPDX6scuar1CkgToOh1xqOlS81syiA(YONNmFti6RCyPIgL87RDnmFPpATVA08T1t4l7elPVqIczGK(tusMVtXmmL((K(sphBQqFjFOVGybIGeerYrJGeeX0UOH5lisGch0mAZxmr(yNHgXjv5as6prj7StSKiK)HKd13ZqZMkKjITIAKcfjM2vpynHxMGK(tusu2TegIgRDoXwrn2XcvhKrlpjQqqskirMHWPc70FIskywgd2EG5bjkuyJk2TVh4aI)RLp9sKvRUSKciQMtXCqDqp6r99i)28LdAgT5lMi(Vw(0lgNZ3MV4Fi5aoHtQOrHAY1Fyp(Vw(0lwpJ2agPq5enrycd)wAuKrBaJ8orteMWWVLgfqunNIfah(UdkuiNWlRdr1Ckwa8DhoOh9O(E3)1YNEXCqZOnFXeX)1YNEXOkhqMq1w9NSBxyxIPK)HKt8FT8PxcI661T6k6j8YequnNIfavIx8FT8Pxczcd2nywmYhQM28LaIQ5uSoYTtmAOmaQepl1yzcI661T6k6j8Y4rD8FT8PxI88JPU1jdfqunNI1rUDIrdLbqL4boHtQOrbjHw3Jsifk3doHtQOrbjHw3JsiTuOCVLASmbrD96wDf9eEzuOO8mgpYj8Y6qunNIfqGp2bnJ28fte)xlF6fJQCaj7j0DiMNiK)yROg7wcdrJX5a)djhlHHOjSrf723pJwpWhhWX8SegIMWgvSBFxoy7hZlJ2ag7yHQdYcGtGDqpQV3PFTK5lx0t4L5l5d9L40x799yFzy8ljZx79L1QI(sFSlFbbNFm1Tozi)(2gTlesFyi)(sWqFPp2LVGycd67nWSyKpunT5lHdAgT5lMi(Vw(0lgv5asI661T6k6j8Y4Fi5aoHtQOrbZ6N6SQPc5rD8FT8PxI88JPU1jdfqunNI1rUDIrdLbCmfkX)1YNEjYZpM6wNmuar1Ckwh52jgnu2(bUtlpQJ)RLp9sityWUbZIr(q10MVequnNIfqyusHIcbjPqMWGDdMfJ8HQPnFjioP1bnJ28fte)xlF6fJQCajrD96wDf9eEz8pKCaNWjv0OiLswhIQ5uuOO8mgpYj8Y6qunNIfaFhCqZOnFXeX)1YNEXOkhqktyWUbZIr(q10MV4Fi5aoHtQOrbZ6N6SQPc5rT8nbrD96wDf9eEzD5BciQMtXOq5El1yzcI661T6k6j8YO1bnJ28fte)xlF6fJQCaPmHb7gmlg5dvtB(I)HKd4eoPIgfPuY6qunNIcfLNX4roHxwhIQ5uSa47GdAgT5lMi(Vw(0lgv5aY88JPU1jd5Fi5KrBaJDSq1bzCoWtIkeKKcsKziCQWo9NOKcMLXGTZHk4r99Gt4KkAuqsO19OesHc4eoPIgfKeADpkH8Oo(Vw(0lbrD96wDf9eEzciQMtXA)a3Pqj(Vw(0lHmHb7gmlg5dvtB(sar1Ckwh52jgnu2(bUZ7El1yzcI661T6k6j8YOLwh0mAZxmr8FT8PxmQYbK55htDRtgYFSvuJDlHHOX4CG)HKtgTbm2XcvhK1oh(4jrfcssbjYmeovyN(tusbZYyW2dmV7LyAx9SKDjgZwcBIbNk0bnJ28fte)xlF6fJQCajJqv9REycd)wAK)HKdKOMy)8PJqHejN4ybCGk4f)xlF6LGOUEDRUIEcVmbevZPybCiW8I)RLp9sityWUbZIr(q10MVequnNI1rUDIrdLbCiWoOz0MVyI4)A5tVyuLdijQRx3QNmwsOn(hsoGt4KkAuWS(PoRAQqEsuHGKuqImdHtf2P)eLuWSmgma(4r9jAI88J9WRNqlYOnGrkuuiijfYegSBWSyKpunT5lbXjV4)A5tVe55htDRtgkGOAofR9dCNwh0mAZxmr8FT8PxmQYbKe11RB1tglj0g)Xwrn2TegIgJZb(hsoz0gWyhluDqw7C4JNeviijfKiZq4uHD6prjfmlJbdGpEuFIMip)yp86j0ImAdyKcffcssHmHb7gmlg5dvtB(sqCsHs8FT8PxcjM2vplzxIXSLaIQ5uSacJsADqZOnFXeX)1YNEXOkhqcZHHDjMs(hso3FIMi86j0ImAdy0b9Oh1xqCyPIgL87lxNGz(wV5letTULV1dvtTVk4vcEEOV2vA0W8L(dTlFpjGmIPc9DQ2qyQIch0JEuFZOnFXeX)1YNEXOkhqYYiCiN4K6(zgn(hsoz0gWyhluDqw7C4J39keKKczcd2nywmYhQM28LG4Kx8FT8Pxczcd2nywmYhQM28LaIQ5uS2pMcfLNX4roHxwhIQ5uSacJshuh0JEuFV7dgRSmFbbkJESbzoOz0MVyI4dgRSmghg9eQovyxDyg)djhWjCsfnkyw)uNvnvipirnX(5thHcjsoXXA)WDWJ64)A5tVe55htDRtgkGOAofJcL7TuJLjsOAR(t2TlSlt1cL8I)RLp9sityWUbZIr(q10MVequnNIrlfkkpJXJCcVSoevZPybC4Gd6r9TbnFT3xcg6BsAi0388J(omF)Y37cI(MmFT33ticglZ3hmcJ555uH(EeoY(s)A0OVm0SPc9L4037cI0WCqZOnFXeXhmwzzmQYbKm6juDQWU6Wm(hsoX)1YNEjYZpM6wNmuar1CkgpQZOnGXowO6GS25WhVmAdySJfQoilaohZdsutSF(0rOqIKtCS2pWDQsDgTbm2XcvhK1MUdA5boHtQOrrkLSoevZPOqjJ2ag7yHQdYA)yEqIAI9ZNocfsKCIJ1ovWDADqZOnFXeXhmwzzmQYbKPYRovAZxD9OQW)qYbCcNurJcM1p1zvtfY7E2tOvMsk0yk7kT6i3s1tnYJ64)A5tVe55htDRtgkGOAofJcL7TuJLjsOAR(t2TlSlt1cL8I)RLp9sityWUbZIr(q10MVequnNIrlpirHcBuXU9DQODfcssbKOMyp(qiXPnFjGOAofJcfLNX4roHxwhIQ5uSa47GdAgT5lMi(GXklJrvoGmvE1PsB(QRhvf(hsoGt4KkAuWS(PoRAQqEuZEcTYusHgtzxPvh5wQEQrkuypHwzkPiicEkw)FQmOEQqA5rT8nbrD96wDf9eEzD5BciQMtXA)WbkuU3snwMGOUEDRUIEcVmEX)1YNEjKjmy3GzXiFOAAZxciQMtXO1bnJ28fteFWyLLXOkhqMkV6uPnF11JQc)djhWjCsfnksPK1HOAofpirHcBuXU9DQODfcssbKOMyp(qiXPnFjGOAofZbnJ28fteFWyLLXOkhqYUYyqn2TlStu0FOD1I)HKd4eoPIgfmRFQZQMkKh1X)1YNEjYZpM6wNmuar1Ckw7h4ofk3BPgltKq1w9NSBxyxMQfk5f)xlF6LqMWGDdMfJ8HQPnFjGOAofJwkuuEgJh5eEzDiQMtXc4WXoOz0MVyI4dgRSmgv5as2vgdQXUDHDII(dTRw8pKCaNWjv0OiLswhIQ5u8OwIPD1Zs2LymBjSjgCQqkuG5i7iySmrkLmbevZPybW5avqRdAgT5lMi(GXklJrvoGKuJSRimjn(hsoSNqRmLuCsWmcn2riXPnF5G6GE0J6BZuHA03BsyiAoOz0MVyIqSq4e5iX0U6XF08pKCUhCcNurJIZ)1tf2He1e7NpDeYJAfcssbJqkXQl)xvaXmAuOajQj2pF6iuirYjowaCoeyAPq5enrycd)wAuKrBaJ8GefgaNatHc5eEzDiQMtXc4a35DVeviijfKiZq4uHD6prjfeNoOz0MVyIqSq4ePkhqMvRUSK8pKCO2snwMqIKJgfyLkAusHs8bJvwMOMWlRtMifkqIcjFyikoVWe(QFHmA5r99Gt4KkAuC(VEQWoKOqgfkkpJXJCcVSoevZPybCmToOz0MVyIqSq4ePkhqs)jkzNDILeH8pKCaNWjv0Oqn56pSFc)iRNrBaJ8KOcbjPGezgcNkSt)jkPGzzmy7CoWl(Vw(0lrE(Xu36KHciQMtX6i3oXOHY2pM39Gt4KkAuC(VEQWoKOqMdAgT5lMieleorQYbK0FIs2zNyjri)djhjQqqskirMHWPc70FIskywgd2EG5Dp4eoPIgfN)RNkSdjkKrHIeviijfKiZq4uHD6prjfeN8iNWlRdr1CkwaulrfcssbjYmeovyN(tusbZYyW2uyusRdAgT5lMieleorQYbKsmTRE8hn)djhirnX(5thHcjsoXXcGdFCN39Gt4KkAuC(VEQWoKOMy)8PJqh0mAZxmriwiCIuLdijrMHWPc7mdobr(hsosuHGKuqImdHtf2P)eLuWSmgmaQG39Gt4KkAuC(VEQWoKOqMdAgT5lMieleorQYbKsmTRE8hn)djN7bNWjv0O48F9uHDirnX(5thHoOz0MVyIqSq4ePkhqs)jkzNDILeH8pKCKOcbjPGezgcNkSt)jkPGzzmy7CoWdsuya8X7EWjCsfnko)xpvyhsuiJx8FT8PxI88JPU1jdfqunNI1rUDIrdLTFSdQd6rpQVu5yHWj6li4ps(EKHZdhRLdAgT5lMieleoXE(ih65y8ZWiN4)A5tVeSNq3HyEIqbevZPy8pKCSuJLjypHUdX8eH8SegIMWgvSBF)mA9aFCahZJCcVSoevZPyTFmV4)A5tVeSNq3HyEIqbevZPybqDyu2M4UGkDmT8YOnGXowO6GSa4eyh0mAZxmriwiCI98rQYbKsmTRE8hn)djhQVhCcNurJIZ)1tf2He1e7NpDesHIcbjPGriLy1L)RkGygnA5rTcbjPqMWGDdMfJ8HQPnFjio5bjkK8HHOqIPupiZ6XF08YOnGXowO6GSa4eykuYOnGXowO6Gmo8rRdAgT5lMieleoXE(iv5as8CKO6e5Fi5OqqskyesjwD5)QciMrJcL7bNWjv0O48F9uHDirnX(5thHoOh132mPVwcdrZ3yROEQqFhMVYHLkAuYVVm6JfV8vjJb91EFTl0x2uHASnyjmenFdXcHt0x9WmFNIzykfoOz0MVyIqSq4e75JuLdiHevpJ28vxpmJ)kvroHyHWjYpZGt04CG)HKtSvuJDSq1bzCo4GMrB(IjcXcHtSNpsvoGK(tuYo7eljc5p2kQXULWq0yCoW)qYH64)A5tVe55htDRtgkGOAofR9J5jrfcssbjYmeovyN(tusbXjfksuHGKuqImdHtf2P)eLuWSmgS9atlpQjNWlRdr1CkwaX)1YNEjKyAx9SKDjgZwciQMtXO6bUtHc5eEzDiQMtXAp(Vw(0lrE(Xu36KHciQMtXO1bnJ28fteIfcNypFKQCajjYmeovyNzWjiYFSvuJDlHHOX4CG)HKJeviijfKiZq4uHD6prjfmlJbdGtG5f)xlF6Lip)yQBDYqbevZPybCmfksuHGKuqImdHtf2P)eLuWSmgmGdoOz0MVyIqSq4e75JuLdijrMHWPc7mdobr(JTIASBjmengNd8pKCI)RLp9sKNFm1TozOaIQ5uS2pMNeviijfKiZq4uHD6prjfmlJbd4Gd6r99MRH57W8fjjXOnGrDlFjhTgH(s)AIx(YgvMVG4rUX3cjmyQ53xfcZx21tOL(EcrWyz(M(YIyLW59L(fcrFTl03uk)Y3RK5B921uH(AVVqm(QQyjfoOz0MVyIqSq4e75JuLdijrMHWPc7mdobr(hsoz0gWyx(MGezgcNkSt)jkz7CITIASJfQoiJNeviijfKiZq4uHD6prjfmlJbdGkCqDqpQVhHmoPM5GMrB(IjGzCsnJtcJzHD7HqSm(hsoqIAI9ZNocfsKCIJ1(DCmpQprteMWWVLgfz0gWifk3BPgltWiuv)QhMWWVLgfyLkAuslpirHcjsoXXANZXoOz0MVycygNuZOkhqQO)x2jjGT4Fi5aoHtQOrHAY1Fyp(Vw(0lwpJ2agPq5enrycd)wAuKrBaJ8orteMWWVLgfqunNIfahfcssHI(FzNKa2sijGPnFrHIYZy8iNWlRdr1CkwaCuiijfk6)LDscylHKaM28LdAgT5lMaMXj1mQYbKkiKHWGtfY)qYbCcNurJc1KR)WE8FT8PxSEgTbmsHYjAIWeg(T0OiJ2ag5DIMimHHFlnkGOAoflaokeKKcfeYqyWPcfscyAZxuOO8mgpYj8Y6qunNIfahfcssHcczim4uHcjbmT5lh0mAZxmbmJtQzuLdi1t4LX6CDczOkwg)djhfcssbrD96wDMbXk0UeeNoOh1xqqfrMbtTV3n1AFJz5RbNWqe6lv475ByztQ9vHGKKXVVygV8vNmBQqFpCSVmm(LKj89i2g9qLbL(ELqPVXxIsFTrf9nz(M(AWjmeH(AVVbr803X8fIPmv0OWbnJ28ftaZ4KAgv5aYSIiZGPUhtTM)HKd4eoPIgfQjx)H94)A5tVy9mAdyKcLt0eHjm8BPrrgTbmY7enrycd)wAuar1CkwaCoCmfkkpJXJCcVSoevZPybW5WXoOz0MVycygNuZOkhqMWywy)KqZq(hsoz0gWyhluDqw7C4JcfQHefkKi5ehRDohZdsutSF(0rOqIKtCS25ChCNwh0mAZxmbmJtQzuLdijhiQO)xY)qYbCcNurJc1KR)WE8FT8PxSEgTbmsHYjAIWeg(T0OiJ2ag5DIMimHHFlnkGOAoflaokeKKcYbIk6)LcjbmT5lkuuEgJh5eEzDiQMtXcGJcbjPGCGOI(FPqsatB(YbnJ28ftaZ4KAgv5asLmS)KDdoXGm(hsoz0gWyhluDqgNd8OwHGKuquxVUvNzqScTlbXjfkkpJXJCcVSoevZPybCmToOoOh9O(EdCQGOXCqZOnFXegCQGOX4qWW(yOk)vQICMIfHewQOXoxJilJqTlrWte5Fi5qD8FT8PxcI661T6k6j8YequnNI1oFCNcL4)A5tVeYegSBWSyKpunT5lbevZPyDKBNy0qz78XDA5rDgTbm2XcvhK1oh(Oq5enrcvB1dVEcTiJ2agPq5enrE(XE41tOfz0gWipQTuJLjiQRx3QNmwsOnkuKyAx9G1eEzc5Wsfn2Z3K0sHYjAIWeg(T0OiJ2agPLcfLNX4roHxwhIQ5uSa47afkwcdrtyJk2TVFgToFCpGJDqpQV3CH(AWPcIMV0h7Yx7c99AcVqM5lYSrnnu6l4utG87l9rR9vb9LGHsFjhiZ8nlPVN5arPV0h7YxqW5htDRtg6l1dPVkeKK(omFpCSVmm(LK57d9vJmgT((qF5IEcVmqcI34l1dPVHqmne6RDLLVho2xgg)sYO1bnJ28ftyWPcIgJQCaPbNkiAh4Fi5Cp4eoPIgfStmoKdk7gCQGOXJAQn4ubrtCqOqqs2LeW0MVcGZHJ5f)xlF6Lip)yQBDYqbevZPyTZh3PqXGtfenXbHcbjzxsatB(Q9dhZJ64)A5tVee11RB1v0t4LjGOAofRD(4ofkX)1YNEjKjmy3GzXiFOAAZxciQMtX6i3oXOHY25J70sHsgTbm2XcvhK1oh(4PqqskKjmy3GzXiFOAAZxcItA5r99gCQGOj4tCLSE8FT8PxuOyWPcIMGpr8FT8PxciQMtXOqbCcNurJcdovq06NW5HJ1IZbAPLcfdovq0ehekeKKDjbmT5R25qoHxwhIQ5umh0mAZxmHbNkiAmQYbKgCQGOXh)djN7bNWjv0OGDIXHCqz3GtfenEutTbNkiAc(ekeKKDjbmT5Ra4C4yEX)1YNEjYZpM6wNmuar1Ckw78XDkum4ubrtWNqHGKSljGPnF1(HJ5rD8FT8PxcI661T6k6j8YequnNI1oFCNcL4)A5tVeYegSBWSyKpunT5lbevZPyDKBNy0qz78XDAPqjJ2ag7yHQdYANdF8uiijfYegSBWSyKpunT5lbXjT8O(Edovq0ehexjRh)xlF6ffkgCQGOjoiI)RLp9sar1CkgfkGt4KkAuyWPcIw)eopCSwC4JwAPqXGtfenbFcfcsYUKaM28v7CiNWlRdr1CkMd6r9Tnt67x6w((f67x(sWqFn4ubrZ3t4dEKiZ30xfcss(9LGH(AxOVVDHqF)Y34)A5tVe(2gH(oK(w4yxi0xdovq089e(GhjY8n9vHGKKFFjyOVkVD57x(g)xlF6LWbnJ28ftyWPcIgJQCaPbNkiAh4Fi5CVbNkiAIdIRK1jyyxHGKKh1gCQGOj4te)xlF6LaIQ5umkuU3GtfenbFIRK1jyyxHGKKwh0mAZxmHbNkiAmQYbKgCQGOXh)djN7n4ubrtWN4kzDcg2viij5rTbNkiAIdI4)A5tVequnNIrHY9gCQGOjoiUswNGHDfcssAbAsc76HannJkHoT5R7ctsdWamaaa]] )


end
