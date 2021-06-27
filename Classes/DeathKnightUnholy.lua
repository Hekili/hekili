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


    spec:RegisterPack( "Unholy", 20210627, [[de18RcqiavpsfPUeceTjuPpregfQWPquTkPuIxHOywej3IiLAxK8leWWOGCmvulJc8mkOMgIsUMkITrKkFdrPmoafX5auKwNksEhGcH5reDpKQ9jLQdIaPfIkYdbuAIiqDraf1gbuO6JsPKmsafkNeqbReb9safsZKif3eqHODci(jIsLHkLszPsPu9ukAQasxvkLuBfrPQ(kcegRuk2Rk9xPAWkDyQwmr9yknzcxgAZi5ZsXOb40kwnrk51sjZMu3gvTBj)wvdxfoorQA5GEoktx46aTDe67iLXJkQZtHwpIsvMpISFrFpFb61u4bEbIbgYGZgs6mGSPolDgC(eGPxZW4bEnpCBlVbVMLZJxZ26cWRnEnpCJ63fxGEnzpi0IxtarCWofbiqZeaaLv2NNaSHhu7X8Lf6ubbydVLaxtzWrhad1v(Ak8aVaXadzWzdjDgq2uNLodoFYjxt2bAVaXGtm4AcyecSUYxtbYSxtcg9aqUaJwtdGi326cWRnMesiyH5AaztQCnWqgCojmjeyb4vdYovsO0oxcQqAbYcEScwUXNlbxembiyKA0ibiy0daSCjyqm34Z9lTXCTpyf5goSbdwU0a856qmxKZhOnqrUXNREiI5Q)QjxSEWga5gFU8Eeimxo8h7mmapY90NjxLekTZLGhMlRrrUMUfouJDCDUTn3g5kJwhKH5kqxKBdGhuZYL3BH5s9WCzUixcgyuMkjuANBBnBQMCjiEWsKR5bwceMRlp6jgKLl)dXCP0iNhzTXC5WJCjlYKllCBlwUtXc0f5(u5Eczihye5sWTnZClemGUoxVe5Y7gZ9aIeXkYL98yU1lTHOnx2eGEmFXujHs7CBRzt1KlW4ilq4un5AgWPfM7u5sqj7aMZDOY14dMlaNiMB9bGPAYf1mm34Zv856LixAFjrK7teHw)ixApyjy5oSCj42MzUfcgqxRscL25cSa8Qbf5Y7LXCLGAAaeDiY7tXKix7xIjMVCnl34Z1po0gZDQCLFglxQPbqWY9lTXC5qJmwUalbNlnNfyUFLBaDgaYvjHs7CjOcbkY1RpaGWCj7adzi6TYfRaAm34ZLHrUGh5Yc4xnimxG5JrG8JLPUM6HfSlqVM(JDggGhxGEbY5lqVMy5YAuC5010cNaHJFnfOha6TQPbqOOO9GLaf9WHnyWYTD65AnA1yhlKFqwUKiLRa9aqVvnnacffThSeOOhoSbdwUTtp3tYLePCbEUHRXkuYGqwmvtN9qKPWYL1OixsKYf6JOJeXkuUqWuiNhwWYLBUqFeDKiwHYfcMcI8(uSCLKEUNpNljs5snnaIoe59Py5kj9CpF(A62y(6A6LXUOe34cedUa9AILlRrXLtxtlCceo(1e45s0HJlRr1X)6PA6qWAS9JNgcZLBUCKRmifLs4Ww9a6fJ6H8EmFPapYLBUqWcPEydQeOl0dYIU9hTclxwJIC5MRBJHi2Xc5hKLRK0Z1W5sIuUUngIyhlKFqwU0Z1GCj)A62y(6Akqpa0T)OVXfig(c0RjwUSgfxoDnTWjq44xtGNlrhoUSgvh)RNQPdbRX2pEAi8A62y(6AIhJa5h7nUaHSUa9AILlRrXLtxt3gZxxtkKfiCQMolGtl8AAHtGWXVMcugKIsrHSaHt10P9GLqXc32kxjPNRHZLBU2)1INwP8J36AJhmubrEFkwUsMRHVMwJwn2dh2Gb7cKZ34cKtUa9AILlRrXLtxt3gZxxtkKfiCQMolGtl8AAHtGWXVMcugKIsrHSaHt10P9GLqXc32kxjZ9810A0QXE4WgmyxGC(gxGiDxGEnXYL1O4YPRPBJ5RRjfYceovtNfWPfEnTWjq44xtiyHQy4XE8DYkxjZLJCT)RfpTsjqpa09s0fO1nQGiVpflxU5c8CdxJvOei1OrfwUSgf5sIuU2)1INwPei1Orfe59Py5Yn3W1yfkbsnAuHLlRrrUKiLR9jILxHQMgarNYXC5MR9FT4Pvkb6bawxaIkiY7tXYL8RP1OvJ9WHnyWUa58nUaHSDb61elxwJIlNUMUnMVUM0EWs0zhyjq41uGmlCoI5RRjbbaSYnCydg5YO5hSCDiMRyyUSgfsLBayy5sB06C1yKRXhmx2bwICHGfYiaThSeSCNIfOlY9PYLMpXun5s9WCj4IGjabJuJgjabJEaqcwUemiQUMw4eiC8Rjh5c8Czyet1WuwJwnMljs5kqpa0BvtdGqrr7blbk6HdBWGLB70Z1A0QXowi)GSCjpxU5kqzqkkffYceovtN2dwcflCBRCBpxdNl3CHGfQIHh7X3nCUsMR9FT4PvkVm2fLqbrEFk2nUX10FSldczXfOxGC(c0RjwUSgfxoDnTWjq44xt3gdrSJfYpilxjPN7jxt3gZxxtR2PnvtNbWfpn2nUaXGlqVMy5YAuC5010cNaHJFnDBmeXowi)GSCPNR0Ll3CfOha6TQPbqOOO9GLaf9WHnyWYTD65A4RPBJ5RRPv70MQPZa4INg7gxGy4lqVMy5YAuC5010cNaHJFndxJvOKbHSyQMo7HitHLlRrrUCZLJCfOha6TQPbqOOO9GLaf9WHnyWYLEUUngIyhlKFqwUKiLRa9aqVvnnacffThSeOOhoSbdwUTtpxdNl55sIuUHRXkuYGqwmvtN9qKPWYL1OixU5gUgRqz1oTPA6maU4PXuy5YAuKl3CfOha6TQPbqOOO9GLaf9WHnyWYTD65E(A62y(6As7blrNDGLaH34ceY6c0RjwUSgfxoDnTWjq44xtoYvgKIsXafcS6I)5vq0TrUKiLlWZLOdhxwJQJ)1t10HG1y7hpneMl55YnxoYvgKIsjCyREa9Ir9qEpMVuGh5YnxiyHupSbvc0f6bzr3(JwHLlRrrUCZ1TXqe7yH8dYYvs65A4Cjrkx3gdrSJfYpilx65AqUKFnDBmFDnfOha62F034cKtUa9AILlRrXLtxtlCceo(1ecwJTF80qOsGuJDICLmxoY9SHYLm5kqpa0BvtdGqrr7blbk6HdBWGLBBjxdNl55Ynxb6bGERAAaekkApyjqrpCydgSCLmxPlxU5c8Cj6WXL1O64F9unDiyn2(XtdH5sIuUYGuukgnhYpvtNFyHc84A62y(6AIhJa5h7nUar6Ua9AILlRrXLtxtlCceo(1ecwJTF80qOsGuJDICLmxdojxU5kqpa0BvtdGqrr7blbk6HdBWGLB75EsUCZf45s0HJlRr1X)6PA6qWAS9JNgcVMUnMVUM4Xiq(XEJlqiBxGEnXYL1O4YPRPfobch)Ac8CfOha6TQPbqOOO9GLaf9WHnyWYLBUapxIoCCznQo(xpvthcwJTF80qyUKiLl10ai6qK3NILRK5EsUKiLl0hrhjIvOCHGPqopSGLl3CH(i6irScLlemfe59Py5kzUNCnDBmFDnXJrG8J9gxGam5c0RPBJ5RRjThSeD2bwceEnXYL1O4YPBCbcW0lqVMy5YAuC5010cNaHJFnbEUeD44YAuD8VEQMoeSgB)4PHWRPBJ5RRjEmcKFS34gxZaovlmyxGEbY5lqVMy5YAuC5010TX811CkMfcgUSg7spOxbiFxGehlEnTWjq44xtoY1(Vw80kfyb41g7Y6PbqOGiVpfl32Z1adLljs5A)xlEALs4Ww9a6fJ6H8EmFPGiVpfRJC(aTbkYT9CnWq5sEUCZLJCDBmeXowi)GSCBNEUgKljs5EGHYH8g7naEqTYTXqeZLePCpWq5hVT3a4b1k3gdrmxU5YrUHRXkuGfGxBS7mMdQdfwUSgf5sIuUc0da9w10aiuIH5YAS7FiYL8Cjrk3dmunoS5nQrLBJHiMl55sIuUYpJLl3CPMgarhI8(uSCLmxdoNljs5goSbdvm8yp((Hn6gyOCLm3tUMLZJxZPywiy4YASl9GEfG8DbsCS4nUaXGlqVMy5YAuC5010TX811K3TUme7maigDEq2yVMw4eiC8RP9FT4Pvk)4TU24bdvqK3NILRK5EsUCZLJCbEUO0dohhOqnfZcbdxwJDPh0RaKVlqIJfZLePCT)RfpTsnfZcbdxwJDPh0RaKVlqIJfvqK3NILl55sIuUYpJLl3CPMgarhI8(uSCLmxdoFnlNhVM8U1LHyNbaXOZdYg7nUaXWxGEnXYL1O4YPRPBJ5RRPaIUGAGyNiYyO(AAHtGWXVM2)1INwP8J36AJhmubrEFkwUCZLJCbEUO0dohhOqnfZcbdxwJDPh0RaKVlqIJfZLePCT)RfpTsnfZcbdxwJDPh0RaKVlqIJfvqK3NILl55sIuUYpJLl3CPMgarhI8(uSCLmxdFnlNhVMci6cQbIDIiJH6BCbczDb61elxwJIlNUMUnMVUMch2I))QlqBRoXh62jmEnTWjq44xt7)AXtRu(XBDTXdgQGiVpflxU5YrUapxu6bNJduOMIzHGHlRXU0d6vaY3fiXXI5sIuU2)1INwPMIzHGHlRXU0d6vaY3fiXXIkiY7tXYL8Cjrkx5NXYLBUutdGOdrEFkwUsMRbNVMLZJxtHdBX)F1fOTvN4dD7egVXfiNCb61elxwJIlNUMw4eiC8RjWZLOdhxwJk2bAhQbf9aovlmYLBUCKlh5gWPAHHkoRKbPO6cqOhZx5kj9CpFsUCZ1(Vw80kLF8wxB8GHkiY7tXYT9CnWq5sIuUbCQwyOIZkzqkQUae6X8vUTN75tYLBUCKR9FT4PvkWcWRn2L1tdGqbrEFkwUTNRbgkxsKY1(Vw80kLWHT6b0lg1d59y(sbrEFkwh58bAduKB75AGHYL8Cjrkx3gdrSJfYpil32PNRb5YnxzqkkLWHT6b0lg1d59y(sbEKl55YnxoYf45gWPAHHkmqbWzD7)AXtRYLePCd4uTWqfgOS)RfpTsbrEFkwUKiLlrhoUSgvbCQwy0pGZdNWyU0Z9CUKNl55sIuUbCQwyOIZkzqkQUae6X8vUTtpxQPbq0HiVpf7A62y(6AgWPAHX5BCbI0Db61elxwJIlNUMw4eiC8RjWZLOdhxwJk2bAhQbf9aovlmYLBUCKlh5gWPAHHkmqjdsr1fGqpMVYvs65E(KC5MR9FT4Pvk)4TU24bdvqK3NILB75AGHYLePCd4uTWqfgOKbPO6cqOhZx52EUNpjxU5YrU2)1INwPalaV2yxwpnacfe59Py52EUgyOCjrkx7)AXtRuch2QhqVyupK3J5lfe59PyDKZhOnqrUTNRbgkxYZLePCDBmeXowi)GSCBNEUgKl3CLbPOuch2QhqVyupK3J5lf4rUKNl3C5ixGNBaNQfgQ4ScGZ62)1INwLljs5gWPAHHkoRS)RfpTsbrEFkwUKiLlrhoUSgvbCQwy0pGZdNWyU0Z1GCjpxYZLePCd4uTWqfgOKbPO6cqOhZx52o9CPMgarhI8(uSRPBJ5RRzaNQfggCJBCnBWcHJ9c0lqoFb61elxwJIlNUMw4eiC8RjWZLOdhxwJQJ)1t10HG1y7hpneMl3C5ixzqkkfduiWQl(Nxbr3g5sIuUqWAS9JNgcvcKAStKRK0Z9SHZL8Cjrk3dmunoS5nQrLBJHiMl3CHGfMRK0Z1W5sIuUutdGOdrEFkwUsM7zdLl3CbEUcugKIsrHSaHt10P9GLqbECnDBmFDnfOha62F034cedUa9AILlRrXLtxtlCceo(1KJCdxJvOei1OrfwUSgf5sIuU2NiwEfQAAaeDkhZLePCHGfs9WguDaaD4Z)fYuy5YAuKl55YnxoYf45s0HJlRr1X)6PA6qWcz5sIuUYpJLl3CPMgarhI8(uSCLm3tYL8RPBJ5RRPxg7IsCJlqm8fOxtSCznkUC6AAHtGWXVMeD44YAuX7sRh2pGVL1DBmeXC5MRaLbPOuuilq4unDApyjuSWTTYTD65EoxU5A)xlEALYpERRnEWqfe59PyDKZhOnqrUTN7j5YnxGNlrhoUSgvh)RNQPdblKDnDBmFDnP9GLOZoWsGWBCbczDb61elxwJIlNUMw4eiC8RPaLbPOuuilq4unDApyjuSWTTYT9CnCUCZf45s0HJlRr1X)6PA6qWcz5sIuUcugKIsrHSaHt10P9GLqbEKl3CPMgarhI8(uSCLmxoYvGYGuukkKfiCQMoThSekw42w52wYTXkYL8RPBJ5RRjThSeD2bwceEJlqo5c0RjwUSgfxoDnTWjq44xtiyn2(XtdHkbsn2jYvs65AGHYLBUapxIoCCznQo(xpvthcwJTF80q410TX811uGEaOB)rFJlqKUlqVMy5YAuC5010cNaHJFnfOmifLIczbcNQPt7blHIfUTvUsMlzLl3CbEUeD44YAuD8VEQMoeSq210TX811KczbcNQPZc40cVXfiKTlqVMy5YAuC5010cNaHJFnbEUeD44YAuD8VEQMoeSgB)4PHWRPBJ5RRPa9aq3(J(gxGam5c0RjwUSgfxoDnTWjq44xtbkdsrPOqwGWPA60EWsOyHBBLB70Z9CUCZfcwyUsMRb5YnxGNlrhoUSgvh)RNQPdblKLl3CT)RfpTs5hV11gpyOcI8(uSoY5d0gOi32Z9KRPBJ5RRjThSeD2bwceEJBCnTprS8kyxGEbY5lqVMy5YAuC5010cNaHJFnj6WXL1OIf9dTx1un5Ynxiyn2(XtdHkbsn2jYT9CplD5YnxoY1(Vw80kLF8wxB8GHkiY7tXYLePCbEUHRXkuoK3y)P6baSlC(cfkSCznkYLBU2)1INwPeoSvpGEXOEiVhZxkiY7tXYL8Cjrkx5NXYLBUutdGOdrEFkwUsM75Zxt3gZxxtgnhYpvtNFyXnUaXGlqVMy5YAuC5010TX811KrZH8t105hwCnfiZcNJy(6AAIrUXNlidZ1PceMRF82ChwUFLlWsW56SCJp3diseRi3NicT(XXun522BB5sdWOXCzyet1Kl4rUalblb7AAHtGWXVM2)1INwP8J36AJhmubrEFkwUCZLJCDBmeXowi)GSCBNEUgKl3CDBmeXowi)GSCLKEUNKl3CHG1y7hpneQei1yNi32Z9SHYLm5YrUUngIyhlKFqwUTLCLUCjpxU5s0HJlRrLleSoe59PYLePCDBmeXowi)GSCBp3tYLBUqWAS9JNgcvcKAStKB75swgkxYVXfig(c0RjwUSgfxoDnTWjq44xtIoCCznQyr)q7vnvtUCZf45YEqT8ucLgDrx2yh5SZFOrfwUSgf5YnxoY1(Vw80kLF8wxB8GHkiY7tXYLePCbEUHRXkuoK3y)P6baSlC(cfkSCznkYLBU2)1INwPeoSvpGEXOEiVhZxkiY7tXYL8C5MleSqvm8yp(ozLB75kdsrPGG1y72hcbpI5lfe59Py5sIuUYpJLl3CPMgarhI8(uSCLmxdoFnDBmFDnD5NFkpMV66Hx(gxGqwxGEnXYL1O4YPRPfobch)As0HJlRrfl6hAVQPAYLBUShulpLqPrx0Ln2ro78hAuHLlRrrUCZLJCfFOalaV2yxwpnaIU4dfe59Py52EUNpNljs5c8CdxJvOalaV2yxwpnacfwUSgf5Ynx7)AXtRuch2QhqVyupK3J5lfe59Py5s(10TX8110LF(P8y(QRhE5BCbYjxGEnXYL1O4YPRPfobch)As0HJlRrLleSoe59PYLBUqWcvXWJ947KvUTNRmifLccwJTBFie8iMVuqK3NIDnDBmFDnD5NFkpMV66Hx(gxGiDxGEnXYL1O4YPRPfobch)As0HJlRrfl6hAVQPAYLBUCKR9FT4Pvk)4TU24bdvqK3NILB75E2q5sIuUap3W1yfkhYBS)u9aa2foFHcfwUSgf5Ynx7)AXtRuch2QhqVyupK3J5lfe59Py5sEUKiLR8Zy5YnxQPbq0HiVpflxjZ98jxt3gZxxtga32sJ9aa2blApmay8gxGq2Ua9AILlRrXLtxtlCceo(1KOdhxwJkxiyDiY7tLl3C5ixb6bGUxIUaTUrvm2wt1Kljs5c9r0rIyfkxiykiY7tXYvs65EMSYL8RPBJ5RRjdGBBPXEaa7GfThgamEJBCnpGO95L94c0lqoFb610TX81184J5RRjwUSgfxoDJlqm4c0RPBJ5RRj0hg2fOlUMy5YAuC50nUaXWxGEnXYL1O4YPRPBJ5RRPd5n2FQEaa7c0fxtlCceo(1e45gUgRqXa55)Q34WM3Ogvy5YAuCnpGO95L9OhdpEnn8nUaHSUa9AILlRrXLtxZ)4AYWyOUMw4eiC8RzaNQfgQ4ScGZ6GmSldsrLl3C5i3aovlmuXzL9FT4Pvkbi0J5RCjiZLSojx65AOCj)AkqMfohX811eyMORb9az565gWPAHblx7)AXtRKkxXqCeOixzJ5swNOYfOagwU0CwUwapdRCDwUGfGxBmxApSfl3VYLSojxgA)sKRmiKf5AnA1itQCLbJCb4SCJ)ZL3lJ5AfWCrkk0gSCJp3MHiMRNR9FT4PvkoReGqpMVYvmeh2dZDkwGUqLlWavUtiblxIUgeZfGZYT(CHiVpLaH5cXaew5EwQCrndZfIbiSY1qQtuxtIoSxopEnd4uTWOFUZmw2RPBJ5RRjrhoUSgVMeDni2rndVMgsDY1KORbXR55BCbYjxGEnXYL1O4YPR5FCnzymuxt3gZxxtIoCCznEnj6WE5841mGt1cJUbDMXYEnTWjq44xZaovlmuHbkaoRdYWUmifvUCZLJCd4uTWqfgOS)RfpTsjaHEmFLlbzUK1j5spxdLl5xtIUge7OMHxtdPo5As01G4188nUar6Ua9AILlRrXLtxZ)4AYWyOUMw4eiC8RjWZnGt1cdvCwbWzDqg2LbPOYLBUbCQwyOcduaCwhKHDzqkQCjrk3aovlmuHbkaoRdYWUmifvUCZLJC5i3aovlmuHbk7)AXtRucqOhZx5sGCd4uTWqfgOKbPO6cqOhZx5sEUTLC5i3ZQtYLm5gWPAHHkmqbWzDzqkQCjp32sUCKlrhoUSgvbCQwy0nOZmw2CjpxYZT9C5ixoYnGt1cdvCwz)xlEALsac9y(kxcKBaNQfgQ4SsgKIQlaHEmFLl552wYLJCpRojxYKBaNQfgQ4ScGZ6YGuu5sEUTLC5ixIoCCznQc4uTWOFUZmw2CjpxYVMcKzHZrmFDnbMzXW7bYY1ZnGt1cdwUeDniMRSXCTp)HdNQj3aaMR9FT4Pv5(u5gaWCd4uTWqQCfdXrGICLnMBaaZvac9y(k3Nk3aaMRmifvUtK7b8jocKPYfymNLRNllGy1eaYL)fd1GWCJp3MHiMRNlGPbacZ9aopCcJ5gFUSaIvtai3aovlmysLRZYLgQ156SC9C5FXqnimxQhM7qLRNBaNQfg5sB06CFyU0gTo36JCzglBU0MaqU2)1INwXuxtIoSxopEnd4uTWOFaNhoHXRPBJ5RRjrhoUSgVMeDni2rndVMNVMeDniEnn4gxGq2Ua9AILlRrXLtxZ)4AYW4A62y(6As0HJlRXRjrxdIxZW1yfkhYBS)u9aa2foFHcfwUSgf5Ynx7xcWju2Vi(wpMV6pvpaGDb6cf0Rw52o9CbMEnfiZcNJy(6Acmt01GEGSCTGqiwrUmmapYL6H5gaWCLEqVIjmM7tLlb94TU24bdZfyj42EUiffAd21KOd7LZJxtkqTUBfWBCJRj0TJRzxGEbY5lqVMy5YAuC5010TX8110HwVWE8qiwX1uGmlCoI5RRzB3TJRzxtlCceo(1ecwJTF80qOsGuJDICBpxP7KC5Mlh5EGHQXHnVrnQCBmeXCjrkxGNB4AScfdKN)REJdBEJAuHLlRrrUKNl3CHGfQei1yNi32PN7j34cedUa9AILlRrXLtxtlCceo(1KOdhxwJkExA9WU9FT4PvSUBJHiMljs5EGHQXHnVrnQCBmeXC5M7bgQgh28g1OcI8(uSCLKEUYGuukz9)Iofi0Osac9y(kxsKYv(zSC5Ml10ai6qK3NILRK0ZvgKIsjR)x0PaHgvcqOhZxxt3gZxxtz9)Iofi04nUaXWxGEnXYL1O4YPRPfobch)As0HJlRrfVlTEy3(Vw80kw3TXqeZLePCpWq14WM3OgvUngIyUCZ9advJdBEJAubrEFkwUsspxzqkkLmcziS1unkbi0J5RCjrkx5NXYLBUutdGOdrEFkwUsspxzqkkLmcziS1unkbi0J5RRPBJ5RRPmcziS1un34ceY6c0RjwUSgfxoDnTWjq44xtzqkkfyb41g7SaIvtaqbECnDBmFDn1tdGG1LwGIgESIBCbYjxGEnXYL1O4YPRPBJ5RRPxwKfqx3TUwFnfiZcNJy(6AsqllYcORZfyDToxRx5gWPPbH5sw5E8bwX46CLbPOysLl6wa5QDwmvtUNpjxgA)sWu52whJEi7HICb4qrU2xGICJHhZ1z565gWPPbH5gFUTq8i3jYfIUWL1O6AAHtGWXVMeD44YAuX7sRh2T)RfpTI1DBmeXCjrk3dmunoS5nQrLBJHiMl3CpWq14WM3OgvqK3NILRK0Z98j5sIuUYpJLl3CPMgarhI8(uSCLKEUNp5gxGiDxGEnXYL1O4YPRPfobch)A62yiIDSq(bz52o9CnixsKYLJCHGfQei1yNi32PN7j5Ynxiyn2(XtdHkbsn2jYTD65kDgkxYVMUnMVUMo06f2pa1m8gxGq2Ua9AILlRrXLtxtlCceo(1KOdhxwJkExA9WU9FT4PvSUBJHiMljs5EGHQXHnVrnQCBmeXC5M7bgQgh28g1OcI8(uSCLKEUYGuukQbIY6)fkbi0J5RCjrkx5NXYLBUutdGOdrEFkwUsspxzqkkf1arz9)cLae6X8110TX811KAGOS(FXnUabyYfOxtSCznkUC6AAHtGWXVMUngIyhlKFqwU0Z9CUCZLJCLbPOuGfGxBSZciwnbaf4rUKiLR8Zy5YnxQPbq0HiVpflxjZ9KCj)A62y(6Ak7n9NQhWX2IDJBCnBWcHJT7pEb6fiNVa9AILlRrXLtxtgAVM2)1INwPypOUdr)aHkiY7tXUMUnMVUM08jUMw4eiC8Rz4AScf7b1Di6hiuHLlRrrUCZnCydgQy4XE89dB0n8j5kzUNKl3CPMgarhI8(uSCBp3tYLBU2)1INwPypOUdr)aHkiY7tXYvYC5i3gRi32sUgsr2ojxYZLBUUngIyhlKFqwUsspxdFJlqm4c0RjwUSgfxoDnTWjq44xtoYf45s0HJlRr1X)6PA6qWAS9JNgcZLePCLbPOumqHaRU4FEfeDBKl55YnxoYvgKIsjCyREa9Ir9qEpMVuGh5YnxiyHupSbvc0f6bzr3(JwHLlRrrUCZ1TXqe7yH8dYYvs65A4Cjrkx3gdrSJfYpilx65AqUKFnDBmFDnfOha62F034cedFb61elxwJIlNUMw4eiC8RPmifLIbkey1f)ZRGOBJCjrkxGNlrhoUSgvh)RNQPdbRX2pEAi8A62y(6AIhJa5h7nUaHSUa9AILlRrXLtxtbYSW5iMVUMadu5goSbJCTgT6PAYDy5kgMlRrHu5YOnHfqUYUTvUXNBaaZLnvJgL2HdBWi3gSq4yZvpSi3Pyb6c110TX811ecwD3gZxD9WIRjlGJnUa5810cNaHJFnTgTASJfYpilx65E(AQhw0lNhVMnyHWXEJlqo5c0RjwUSgfxoDnDBmFDnP9GLOZoWsGWRPfobch)AYrU2)1INwP8J36AJhmubrEFkwUTN7j5YnxbkdsrPOqwGWPA60EWsOapYLePCfOmifLIczbcNQPt7blHIfUTvUTNRHZL8C5Mlh5snnaIoe59Py5kzU2)1INwPeOha6Ej6c06gvqK3NILlzY9SHYLePCPMgarhI8(uSCBpx7)AXtRu(XBDTXdgQGiVpflxYVMwJwn2dh2Gb7cKZ34ceP7c0RjwUSgfxoDnDBmFDnPqwGWPA6SaoTWRPfobch)AkqzqkkffYceovtN2dwcflCBRCLKEUgoxU5A)xlEALYpERRnEWqfe59Py5kzUNKljs5kqzqkkffYceovtN2dwcflCBRCLm3ZxtRrRg7HdBWGDbY5BCbcz7c0RjwUSgfxoDnDBmFDnPqwGWPA6SaoTWRPfobch)AA)xlEALYpERRnEWqfe59Py52EUNKl3CfOmifLIczbcNQPt7blHIfUTvUsM75RP1OvJ9WHnyWUa58nUabyYfOxtSCznkUC6A62y(6AsHSaHt10zbCAHxtbYSW5iMVUMafWWYDy5IuuOngIO2yUuJwJWCPbySaYLn8SCj42MzUfcgqxlvUYGrUmapOwK7bejIvKRNlZILdNpxAaqiMBaaZ1fIVYfGZYT(aWun5gFUq0(88yjuxtlCceo(10TXqe7Ipuuilq4unDApyjYTD65AnA1yhlKFqwUCZvGYGuukkKfiCQMoThSekw42w5kzUK1nUX1uGuoOoUa9cKZxGEnDBmFDn5Ns0PGis2dVMy5YAuC50nUaXGlqVMy5YAuC5018pUMmmUMUnMVUMeD44YA8As01G41KJCrPhCooqHAkMfcgUSg7spOxbiFxGehlMl3CT)RfpTsnfZcbdxwJDPh0RaKVlqIJfvq0fgZL8RPazw4CeZxxZ2gejIvKl7aTd1GICd4uTWGLRmovtUGmuKlTjaKRdgpVhJnx9ui7As0H9Y5XRj7aTd1GIEaNQfg34cedFb61elxwJIlNUM)X1KHX10TX811KOdhxwJxtIUgeVM2)1INwPyG88F1BCyZBuJkiY7tXYvYCpjxU5gUgRqXa55)Q34WM3Ogvy5YAuKl3C5i3W1yfkWcWRn2L1tdGqHLlRrrUCZ1(Vw80kfyb41g7Y6PbqOGiVpflxjZ9SHZLBU2)1INwPeoSvpGEXOEiVhZxkiY7tX6iNpqBGICLm3ZgoxsKYf45gUgRqbwaETXUSEAaekSCznkYL8Rjrh2lNhVMh)RNQPdbRX2pEAi8gxGqwxGEnXYL1O4YPR5FCnzyCnDBmFDnj6WXL141KORbXRz4AScf7b1Di6hiuHLlRrrUCZfcwyUsMRb5Yn3WHnyOIHh7X3pSr3WNKRK5EsUCZLAAaeDiY7tXYT9Cp5As0H9Y5XR5X)6PA6qWcz34cKtUa9AILlRrXLtxZ)4AYW4A62y(6As0HJlRXRjrxdIxt3gdrSJfYpilx65EoxU5YrUapxOpIoseRq5cbtHCEyblxsKYf6JOJeXkuUqWutLB75E(KCj)As0H9Y5XRjl6hAVQPAUXfis3fOxtSCznkUC6A(hxtggxt3gZxxtIoCCznEnj6Aq8A62yiIDSq(bz52o9CnixU5YrUapxOpIoseRq5cbtHCEyblxsKYf6JOJeXkuUqWuiNhwWYLBUCKl0hrhjIvOCHGPGiVpfl32Z9KCjrkxQPbq0HiVpfl32Z9SHYL8Cj)As0H9Y5XRPleSoe59PUXfiKTlqVMy5YAuC5018pUMmmUMUnMVUMeD44YA8As01G41KJCdxJvOyG88F1BCyZBuJkSCznkYLBUap3dmunoS5nQrLBJHiMl3CT)RfpTsXa55)Q34WM3OgvqK3NILljs5c8CdxJvOyG88F1BCyZBuJkSCznkYL8C5Mlh5kdsrPalaV2y3zmhuhkWJCjrk3W1yfkhYBS)u9aa2foFHcfwUSgf5Yn3dmu(XB7naEqTYTXqeZLePCLbPOuch2QhqVyupK3J5lf4rUKiLRBJHi2Xc5hKLB70Z1GC5MRa9aq3lrxGw3OkgBRPAYL8Rjrh2lNhVM8U06HD7)AXtRyD3gdr8gxGam5c0RjwUSgfxoDn)JRjdJRPBJ5RRjrhoUSgVMeDniEnTprS8ku10ai6uoMl3CfOha6Ej6c06gvXyBnvtUCZvgKIsjqpaW6cquXc32kxjZLSYLePCLbPOu8oe(0qrVb5zXxyhlaEzrEScf4rUKiLRmifLkaahTUZqSfcvGh5sIuUYGuukkiwK9gu05)IfWNnHrf4rUKiLRmifLsJUOlBSJC25p0Oc84As0H9Y5XRjVlTEy)a(ww3TXqeVXfiatVa9AILlRrXLtxt3gZxxZhmKHO36AkqMfohX811eyK(uHp1un5s2FGGASICBBAVbeZDy565EaNhoHXRPfobch)Ak(qrCGGASI(H2BarfePGidGlRXC5MlWZnCnwHcSa8AJDz90aiuy5YAuKl3CbEUqFeDKiwHYfcMc58Wc2nUa5SHUa9AILlRrXLtxt3gZxxZhmKHO36AAHtGWXVMIpuehiOgROFO9gqubrkiYa4YAmxU562yiIDSq(bz52o9CnixU5YrUap3W1yfkWcWRn2L1tdGqHLlRrrUKiLR9FT4PvkWcWRn2L1tdGqbrEFkwUCZvgKIsbwaETXUSEAaeDzqkkL4Pv5s(10A0QXE4WgmyxGC(gxGC(8fOxtSCznkUC6A62y(6A(GHme9wxt9uy3kUMs310cNaHJFnDBmeXU4dfXbcQXk6hAVbeZvYCDBmeXowi)GSC5MRBJHi2Xc5hKLB70Z1GC5Mlh5c8CdxJvOalaV2yxwpnacfwUSgf5sIuU2)1INwPalaV2yxwpnacfe59Py5Ynxzqkkfyb41g7Y6Pbq0LbPOuINwLl5xtbYSW5iMVUMadu5gaqiMRdXCXc5hKLl)Wyt1Klz)2Mu56hhAJ5orUCidg5wFU8peZna4vUFzXCpqyUsxUm0(LGrU6gxGC2GlqVMy5YAuC5010cNaHJFnHGfs9WguXapqilG(ukSCznkYLBUCKR4dff8zrNcjIqfePGidGlRXCjrkxXhkz9)I(H2BarfePGidGlRXCj)A62y(6A(GHme9w34cKZg(c0RjwUSgfxoDnDBmFDnP9GLOZoWsGWRPazw4CeZxxZ2osbrgaKLlbJEaGLlbdIsWYvgKIkxPfilYvgPEiMRa9aalxbiMlwc210cNaHJFnTprS8ku10ai6uoMl3CfOha6Ej6c06gvUngIyhI8(uSCLmxoYTXkYTTK7z1j5sEUCZvGEaO7LOlqRBufJT1un34cKZK1fOxtSCznkUC6AYq710(Vw80kf7b1Di6hiubrEFk210TX811KMpX10cNaHJFndxJvOypOUdr)aHkSCznkYLBUHdBWqfdp2JVFyJUHpjxjZ9KC5MB4WgmuXWJ947IbZT9CpjxU5A)xlEALI9G6oe9deQGiVpflxjZLJCBSICBl5Aifz7KCjpxU562yiIDSq(bz5sp3Z34cKZNCb61elxwJIlNUMcKzHZrmFDnji8jYL6H5sWOhaKGLlbdIeGGrQrJ5ou5cKPbqKlW4oMB852GrUSaIvtaixzqkQCLDBRCDMFCnzO9AA)xlEALsGEaG1fGOcI8(uSRPBJ5RRjnFIRPfobch)AAFIy5vOQPbq0PCmxU5A)xlEALsGEaG1fGOcI8(uSCLm3gRixU562yiIDSq(bz5sp3Z34cKZs3fOxtSCznkUC6AYq710(Vw80kLaPgnQGiVpf7A62y(6AsZN4AAHtGWXVM2NiwEfQAAaeDkhZLBU2)1INwPei1Orfe59Py5kzUnwrUCZ1TXqe7yH8dYYLEUNVXfiNjBxGEnXYL1O4YPRPazw4CeZxxtcQnMVYvAgwWY1lrUKDhyHqwUCq2DGfczeWeLEqSSilxWIbEC8Waf5ovUUq8LI8RPBJ5RRP116UBJ5RUEyX1upSOxopEnd4uTWGDJlqodm5c0RjwUSgfxoDnDBmFDnTUw3DBmF11dlUM6Hf9Y5XRP9jILxb7gxGCgy6fOxtSCznkUC6A62y(6AADTU72y(QRhwCn1dl6LZJxtOBhxZUXfigyOlqVMy5YAuC5010TX81106AD3TX8vxpS4AQhw0lNhVM2)1INwXUXfigC(c0RjwUSgfxoDnTWjq44xtIoCCznQCHG1HiVpvUCZLJCT)RfpTsjqpa09s0fO1nQGiVpflxjZ9SHYLBUap3W1yfkbsnAuHLlRrrUKiLR9FT4PvkbsnAubrEFkwUsM7zdLl3CdxJvOei1OrfwUSgf5sIuU2NiwEfQAAaeDkhZLBU2)1INwPeOhayDbiQGiVpflxjZ9SHYL8C5MlWZvGEaO7LOlqRBufJT1unxt3gZxxtiy1DBmF11dlUM6Hf9Y5XRP)yNHb4XnUaXadUa9AILlRrXLtxtlCceo(10TXqe7yH8dYYTD65AqUCZvGEaO7LOlqRBufJT1unxtwahBCbY5RPBJ5RRjeS6UnMV66Hfxt9WIE58410FSldczXnUaXadFb61elxwJIlNUMw4eiC8RPBJHi2Xc5hKLB70Z1GC5Mlh5c8CfOha6Ej6c06gvXyBnvtUCZLJCT)RfpTsjqpa09s0fO1nQGiVpfl32Z9SHYLBUap3W1yfkbsnAuHLlRrrUKiLR9FT4PvkbsnAubrEFkwUTN7zdLl3CdxJvOei1OrfwUSgf5sIuU2NiwEfQAAaeDkhZLBU2)1INwPeOhayDbiQGiVpfl32Z9SHYL8Cj)A62y(6AcbRUBJ5RUEyX1upSOxopEnBWcHJT7pEJlqmGSUa9AILlRrXLtxtlCceo(10TXqe7yH8dYYLEUNVMSao24cKZxt3gZxxtRR1D3gZxD9WIRPEyrVCE8A2Gfch7nUX10(Vw80k2fOxGC(c0RjwUSgfxoDnTWjq44xtIoCCznQ4DP1d72)1INwX6UngIyUKiL7bgQgh28g1OYTXqeZLBUhyOACyZBuJkiY7tXYvs65AG0Lljs5snnaIoe59Py5kzUgiDxt3gZxxZJpMVUXfigCb61elxwJIlNUMw4eiC8RP9FT4PvkWcWRn2L1tdGqbrEFkwUsMlzlxU5A)xlEALs4Ww9a6fJ6H8EmFPGiVpfRJC(aTbkYvYCjB5Yn3W1yfkWcWRn2L1tdGqHLlRrrUCZLJCT)RfpTs5hV11gpyOcI8(uSoY5d0gOixjZLSLl3Cj6WXL1OIcuR7wbmxsKYf45s0HJlRrffOw3TcyUKNljs5c8CdxJvOalaV2yxwpnacfwUSgf5sIuUYpJLl3CPMgarhI8(uSCLmxdFY10TX8110H8g7pvpaGDb6IBCbIHVa9AILlRrXLtxt3gZxxt2dQ7q0pq410cNaHJFndh2GHkgEShF)WgDdFsUsM7j5Yn3WHnyOIHh7X3fdMB75EsUCZ1TXqe7yH8dYYvs65A4RP1OvJ9WHnyWUa58nUaHSUa9AILlRrXLtxt3gZxxtWcWRn2L1tdG4AkqMfohX811eySxly5Yj90aiYL6H5cEKB85EsUm0(LGLB85Ymw2CPnbGCjOhV11gpyOu5s2faqiTHHsLlidZL2eaYLGDyRCbk0lg1d59y(sDnTWjq44xtIoCCznQyr)q7vnvtUCZLJCT)RfpTs5hV11gpyOcI8(uSoY5d0gOixjZ9KCjrkx7)AXtRu(XBDTXdgQGiVpfRJC(aTbkYT9CpBOCjpxU5YrU2)1INwPeoSvpGEXOEiVhZxkiY7tXYvYCBSICjrkxzqkkLWHT6b0lg1d59y(sbEKl534cKtUa9AILlRrXLtxtlCceo(1KOdhxwJkxiyDiY7tLljs5k)mwUCZLAAaeDiY7tXYvYCn4810TX811eSa8AJDz90aiUXfis3fOxtSCznkUC6AAHtGWXVMeD44YAuXI(H2RAQMC5Mlh5k(qbwaETXUSEAaeDXhkiY7tXYLePCbEUHRXkuGfGxBSlRNgaHclxwJICj)A62y(6AkCyREa9Ir9qEpMVUXfiKTlqVMy5YAuC5010cNaHJFnj6WXL1OYfcwhI8(u5sIuUYpJLl3CPMgarhI8(uSCLmxdoFnDBmFDnfoSvpGEXOEiVhZx34ceGjxGEnXYL1O4YPRPfobch)A62yiIDSq(bz5sp3Z5YnxbkdsrPOqwGWPA60EWsOyHBBLB70ZLSYLBUCKlWZLOdhxwJkkqTUBfWCjrkxIoCCznQOa16UvaZLBUCKR9FT4PvkWcWRn2L1tdGqbrEFkwUTN7zdLljs5A)xlEALs4Ww9a6fJ6H8EmFPGiVpfRJC(aTbkYT9CpBOC5MlWZnCnwHcSa8AJDz90aiuy5YAuKl55s(10TX8110pERRnEWWBCbcW0lqVMy5YAuC5010TX8110pERRnEWWRPfobch)A62yiIDSq(bz52o9CnixU5kqzqkkffYceovtN2dwcflCBRCBpxdNl3CbEUc0daDVeDbADJQySTMQ5AAnA1ypCydgSlqoFJlqoBOlqVMy5YAuC5010cNaHJFnHG1y7hpneQei1yNixjZ9mzLl3CT)RfpTsbwaETXUSEAaekiY7tXYvYCpB4C5MR9FT4PvkHdB1dOxmQhY7X8LcI8(uSoY5d0gOixjZ9SHVMUnMVUMmqE(V6noS5nQXBCbY5ZxGEnXYL1O4YPRPfobch)As0HJlRrfl6hAVQPAYLBUcugKIsrHSaHt10P9GLqXc32kxjZ1GC5Mlh5EGHYpEBVbWdQvUngIyUKiLRmifLs4Ww9a6fJ6H8EmFPapYLBU2)1INwP8J36AJhmubrEFkwUTN7zdLl5xt3gZxxtWcWRn2DgZb1XnUa5SbxGEnXYL1O4YPRPBJ5RRjyb41g7oJ5G64AAHtGWXVMUngIyhlKFqwUTtpxdYLBUcugKIsrHSaHt10P9GLqXc32kxjZ1GC5Mlh5EGHYpEBVbWdQvUngIyUKiLRmifLs4Ww9a6fJ6H8EmFPapYLePCT)RfpTsjqpa09s0fO1nQGiVpflxjZTXkYL8RP1OvJ9WHnyWUa58nUa5SHVa9AILlRrXLtxtlCceo(1e45EGHQbWdQvUngI410TX811e6dd7c0f34g34AseHS5RlqmWqgC2qNyidUM0Cynvd7AsqqqB7abyaiTvNk3Cbkam3H)4HrUupmxj8h7mmapKixik9Gdef5YEEmxhmEEpqrUwaE1GmvsO0mfM75tLlW(fregOixjcxJvOAJe5gFUseUgRq1gfwUSgfsKlhN5m5QKqPzkmxdovUa7xeryGICLacwi1dBqvBKi34ZvciyHupSbvTrHLlRrHe5YXzotUkjuAMcZv6ovUa7xeryGICLiCnwHQnsKB85kr4AScvBuy5YAuirUCyaNjxLeMesqqqB7abyaiTvNk3Cbkam3H)4HrUupmxj8h7YGqwirUqu6bhikYL98yUoy88EGICTa8QbzQKqPzkmxdFQCb2ViIWaf5kr4AScvBKi34ZvIW1yfQ2OWYL1OqIC5WWCMCvsO0mfMlzDQCb2ViIWaf5kbeSqQh2GQ2irUXNReqWcPEydQAJclxwJcjYLJZCMCvsysibbbTTdeGbG0wDQCZfOaWCh(Jhg5s9WCLiGt1cdMe5crPhCGOix2ZJ56GXZ7bkY1cWRgKPscLMPWCpFQCb2ViIWaf5kr4AScvBKi34ZvIW1yfQ2OWYL1OqIC54mNjxLekntH5EYPYfy)IicduKRebCQwyOoRAJe5gFUseWPAHHkoRAJe5YHH5m5QKqPzkm3tovUa7xeryGICLiGt1cdLbQ2irUXNRebCQwyOcduTrIC5WaotUkjuAMcZv6ovUa7xeryGICLiGt1cd1zvBKi34ZvIaovlmuXzvBKixomGZKRscLMPWCLUtLlW(fregOixjc4uTWqzGQnsKB85kraNQfgQWavBKixommNjxLeMesqqqB7abyaiTvNk3Cbkam3H)4HrUupmxjAWcHJvICHO0doquKl75XCDW459af5Ab4vdYujHsZuyUgCQCb2ViIWaf5kbeSqQh2GQ2irUXNReqWcPEydQAJclxwJcjYLJZCMCvsysibbbTTdeGbG0wDQCZfOaWCh(Jhg5s9WCLW(eXYRGjrUqu6bhikYL98yUoy88EGICTa8QbzQKqPzkm3ZNkxG9lIimqrUseUgRq1gjYn(CLiCnwHQnkSCznkKixooZzYvjHsZuyUg(u5cSFreHbkYvIW1yfQ2irUXNReHRXkuTrHLlRrHe5YXzotUkjuAMcZ1WNkxG9lIimqrUsWEqT8ucvBKi34Zvc2dQLNsOAJclxwJcjYLJZCMCvsO0mfMlzDQCb2ViIWaf5kr4AScvBKi34ZvIW1yfQ2OWYL1OqIC54mNjxLekntH5swNkxG9lIimqrUsWEqT8ucvBKi34Zvc2dQLNsOAJclxwJcjYLJZCMCvsO0mfMR0DQCb2ViIWaf5kr4AScvBKi34ZvIW1yfQ2OWYL1OqIC54mNjxLeMesqqqB7abyaiTvNk3Cbkam3H)4HrUupmxjoGO95L9qICHO0doquKl75XCDW459af5Ab4vdYujHsZuyUg(u5cSFreHbkYvIW1yfQ2irUXNReHRXkuTrHLlRrHe56rUaZKDstUCCMZKRscLMPWCjRtLlW(fregOixZHhyZLzScNZ5sqsqMB85knGEU8VaudYY9pqOhpmxoiijpxooZzYvjHsZuyUK1PYfy)IicduKRebCQwyOoRAJe5gFUseWPAHHkoRAJe5YHbCMCvsO0mfM7jNkxG9lIimqrUMdpWMlZyfoNZLGKGm34ZvAa9C5FbOgKL7FGqpEyUCqqsEUCCMZKRscLMPWCp5u5cSFreHbkYvIaovlmugOAJe5gFUseWPAHHkmq1gjYLdd4m5QKqPzkmxP7u5cSFreHbkY1C4b2CzgRW5CUeK5gFUsdONRyioS5RC)de6XdZLdcqEUCyaNjxLekntH5kDNkxG9lIimqrUseWPAHH6SQnsKB85kraNQfgQ4SQnsKlhKfNjxLekntH5kDNkxG9lIimqrUseWPAHHYavBKi34ZvIaovlmuHbQ2irUCCcNjxLekntH5s2ovUa7xeryGICLiCnwHQnsKB85kr4AScvBuy5YAuirUCCMZKRsctcjiiOTDGamaK2QtLBUafaM7WF8WixQhMRe2)1INwXKixik9Gdef5YEEmxhmEEpqrUwaE1GmvsO0mfMRbNkxG9lIimqrUseUgRq1gjYn(CLiCnwHQnkSCznkKixomGZKRscLMPWCLUtLlW(fregOixjcxJvOAJe5gFUseUgRq1gfwUSgfsKlhN5m5QKqPzkmxGjNkxG9lIimqrUseUgRq1gjYn(CLiCnwHQnkSCznkKixooZzYvjHjHeee02oqagasB1PYnxGcaZD4pEyKl1dZvIgSq4y7(JsKleLEWbIICzppMRdgpVhOixlaVAqMkjuAMcZ98PYfy)IicduKReHRXkuTrICJpxjcxJvOAJclxwJcjYLJZCMCvsO0mfMRbNkxG9lIimqrUsablK6HnOQnsKB85kbeSqQh2GQ2OWYL1OqIC54mNjxLeMesqqqB7abyaiTvNk3Cbkam3H)4HrUupmxjeiLdQdjYfIsp4arrUSNhZ1bJN3duKRfGxnitLekntH5A4tLlW(fregOixjcxJvOAJe5gFUseUgRq1gfwUSgfsKlhgMZKRscLMPWCjRtLlW(fregOixjcxJvOAJe5gFUseUgRq1gfwUSgfsKlhN5m5QKqPzkmxY2PYfy)IicduKReHRXkuTrICJpxjcxJvOAJclxwJcjYLddZzYvjHsZuyUatpvUa7xeryGICLiCnwHQnsKB85kr4AScvBuy5YAuirUCCMZKRscLMPWCpBOtLlW(fregOixjcxJvOAJe5gFUseUgRq1gfwUSgfsKlhN5m5QKqPzkm3ZNpvUa7xeryGICLiCnwHQnsKB85kr4AScvBuy5YAuirUCCMZKRscLMPWCpBWPYfy)IicduKReqWcPEydQAJe5gFUsablK6HnOQnkSCznkKixooZzYvjHsZuyUNjRtLlW(fregOixjcxJvOAJe5gFUseUgRq1gfwUSgfsKlhN5m5QKqPzkmxdoFQCb2ViIWaf5kr4AScvBKi34ZvIW1yfQ2OWYL1OqIC5WaotUkjuAMcZ1adFQCb2ViIWaf5kr4AScvBKi34ZvIW1yfQ2OWYL1OqIC5WaotUkjeOaWCPET(PnvtUoi0z5sdHyUGmuK7u5gaWCDBmFLREyrUYGrU0qiMB9rUupyjYDQCdayUUq8vUcpCzNHNkjmxPDU8oe(0qrVb5zXxyhlaEzrESIKWCL25gaGJw3zi2cHjHjHafaMReGmSpbYZKix3gZx5sZz5wFKl1dwICNk3aWWYD4pEyOscbg4pEyGICpBOCDBmFLREybtLeEnpGp1OXR5PpDUem6bGCbgTMgarUT1fGxBmj80NoxcblmxdiBsLRbgYGZjHjHN(05cSa8QbzNkj80NoxPDUeuH0cKf8yfSCJpxcUiycqWi1OrcqWOhay5sWGyUXN7xAJ5AFWkYnCydgSCPb4Z1HyUiNpqBGICJpx9qeZv)vtUy9GnaYn(C59iqyUC4p2zyaEK7PptUkj80NoxPDUe8WCznkY10TWHASJRZTT52ixz06Gmmxb6ICBa8GAwU8ElmxQhMlZf5sWaJYujHN(05kTZTTMnvtUeepyjY18albcZ1Lh9edYYL)HyUuAKZJS2yUC4rUKfzYLfUTfl3Pyb6ICFQCpHmKdmICj42MzUfcgqxNRxIC5DJ5EarIyf5YEEm36L2q0MlBcqpMVyQKWtF6CL252wZMQjxGXrwGWPAY1mGtlm3PYLGs2bmN7qLRXhmxaorm36dat1KlQzyUXNR4Z1lrU0(sIi3NicT(rU0EWsWYDy5sWTnZClemGUwLeE6tNR0oxGfGxnOixEVmMReutdGOdrEFkMe5A)smX8LRz5gFU(XH2yUtLR8Zy5snnacwUFPnMlhAKXYfyj4CP5SaZ9RCdOZaqUkj80NoxPDUeuHaf561haqyUKDGHme9w5IvanMB85YWixWJCzb8RgeMlW8Xiq(XYujHN(05kTZfOKDemz3PYnxGG0YnGt1cJCTWjq44QKWKq3gZxm1beTpVShKHobo(y(kj0TX8ftDar7Zl7bzOtaOpmSlqxKe62y(IPoGO95L9Gm0jGd5n2FQEaa7c0fsDar7Zl7rpgEKUHLAOOd8W1yfkgip)x9gh28g1ys4PZfyMORb9az565gWPAHblx7)AXtRKkxXqCeOixzJ5swNOYfOagwU0CwUwapdRCDwUGfGxBmxApSfl3VYLSojxgA)sKRmiKf5AnA1itQCLbJCb4SCJ)ZL3lJ5AfWCrkk0gSCJp3MHiMRNR9FT4PvkoReGqpMVYvmeh2dZDkwGUqLlWavUtiblxIUgeZfGZYT(CHiVpLaH5cXaew5EwQCrndZfIbiSY1qQtujHUnMVyQdiAFEzpidDcq0HJlRrPkNhPhWPAHr)CNzSSs9h0zymusr01Gi9Zsr01Gyh1mKUHuNiL9lXeZx0d4uTWqDwbWzDqg2LbPO4YraNQfgQZk7)AXtRucqOhZxeKeKK1j0ne5jHUnMVyQdiAFEzpidDcq0HJlRrPkNhPhWPAHr3GoZyzL6pOZWyOKIORbr6NLIORbXoQziDdPork7xIjMVOhWPAHHYafaN1bzyxgKIIlhbCQwyOmqz)xlEALsac9y(IGKGKSoHUHipj805cmZIH3dKLRNBaNQfgSCj6AqmxzJ5AF(dhovtUbamx7)AXtRY9PYnaG5gWPAHHu5kgIJaf5kBm3aaMRae6X8vUpvUbamxzqkQCNi3d4tCeitLlWyolxpxwaXQjaKl)lgQbH5gFUndrmxpxatdaeM7bCE4egZn(CzbeRMaqUbCQwyWKkxNLlnuRZ1z565Y)IHAqyUupm3Hkxp3aovlmYL2O15(WCPnADU1h5Ymw2CPnbGCT)RfpTIPscDBmFXuhq0(8YEqg6eGOdhxwJsvopspGt1cJ(bCE4egL6pOZWyOKIORbr6gifrxdIDuZq6NLY(LyI5l6apGt1cd1zfaN1bzyxgKIIBaNQfgkduaCwhKHDzqkksKc4uTWqzGcGZ6GmSldsrXLdoc4uTWqzGY(Vw80kLae6X8fbzaNQfgkduYGuuDbi0J5lYBlCCwDczc4uTWqzGcGZ6YGuuK3w4GOdhxwJQaovlm6g0zgll5K3ohCeWPAHH6SY(Vw80kLae6X8fbzaNQfgQZkzqkQUae6X8f5TfooRoHmbCQwyOoRa4SUmiff5Tfoi6WXL1OkGt1cJ(5oZyzjN8KWtNlWmrxd6bYY1ccHyf5YWa8ixQhMBaaZv6b9kMWyUpvUe0J36AJhmmxGLGB75IuuOnyjHUnMVyQdiAFEzpidDcq0HJlRrPkNhPtbQ1DRakfrxdI0dxJvOCiVX(t1dayx48fk4A)saoHY(fX36X8v)P6baSlqxOGE1QD6attctcp9PZfyMZOfmqrUireAm3y4XCdayUUnEyUdlxNOpAxwJQKq3gZxm68tj6uqej7HjHNo32gejIvKl7aTd1GICd4uTWGLRmovtUGmuKlTjaKRdgpVhJnx9uilj0TX8fJm0jarhoUSgLQCEKo7aTd1GIEaNQfgsr01GiDoqPhCooqHAkMfcgUSg7spOxbiFxGehlY1(Vw80k1umlemCzn2LEqVcq(UajowubrxyK8KWtF6Cj77WXL1ilj0TX8fJm0jarhoUSgLQCEK(X)6PA6qWAS9JNgcLIORbr62)1INwPyG88F1BCyZBuJkiY7tXK8eUHRXkumqE(V6noS5nQrUCeUgRqbwaETXUSEAaeCT)RfpTsbwaETXUSEAaekiY7tXK8SH5A)xlEALs4Ww9a6fJ6H8EmFPGiVpfRJC(aTbkK8SHjrc4HRXkuGfGxBSlRNgab5jHUnMVyKHobi6WXL1OuLZJ0p(xpvthcwitkIUgePhUgRqXEqDhI(bc5cblusd4goSbdvm8yp((Hn6g(ejpHl10ai6qK3NI1(jjHUnMVyKHobi6WXL1OuLZJ0zr)q7vnvJueDnis3TXqe7yH8dYOFMlhah6JOJeXkuUqWuiNhwWirc6JOJeXkuUqWut1(5tipj0TX8fJm0jarhoUSgLQCEKUleSoe59PKIORbr6UngIyhlKFqw70nGlhah6JOJeXkuUqWuiNhwWirc6JOJeXkuUqWuiNhwW4Yb0hrhjIvOCHGPGiVpfR9tirIAAaeDiY7tXA)SHiN8Kq3gZxmYqNaeD44YAuQY5r68U06HD7)AXtRyD3gdrukIUgePZr4AScfdKN)REJdBEJAKlWpWq14WM3OgvUngIix7)AXtRumqE(V6noS5nQrfe59PyKib8W1yfkgip)x9gh28g1i5C5qgKIsbwaETXUZyoOouGhKifUgRq5qEJ9NQhaWUW5luW9adLF82EdGhuRCBmersKKbPOuch2QhqVyupK3J5lf4bjsUngIyhlKFqw70nGRa9aq3lrxGw3OkgBRPAipj0TX8fJm0jarhoUSgLQCEKoVlTEy)a(ww3TXqeLIORbr62NiwEfQAAaeDkh5kqpa09s0fO1nQIX2AQgUYGuukb6bawxaIkw42wsswKijdsrP4Di8PHIEdYZIVWowa8YI8yfkWdsKKbPOuba4O1DgITqOc8GejzqkkffelYEdk68FXc4ZMWOc8GejzqkkLgDrx2yh5SZFOrf4rs4PZfyK(uHp1un5s2FGGASICBBAVbeZDy565EaNhoHXKq3gZxmYqNapyidrVLudfDXhkIdeuJv0p0EdiQGifezaCznYf4HRXkuGfGxBSlRNgabxGd9r0rIyfkxiykKZdlyjHUnMVyKHobEWqgIElPSgTAShoSbdg9Zsnu0fFOioqqnwr)q7nGOcIuqKbWL1ix3gdrSJfYpiRD6gWLdGhUgRqbwaETXUSEAaeKiz)xlEALcSa8AJDz90aiuqK3NIXvgKIsbwaETXUSEAaeDzqkkL4PvKNeE6CbgOYnaGqmxhI5IfYpilx(HXMQjxY(TnPY1po0gZDIC5qgmYT(C5FiMBaWRC)YI5EGWCLUCzO9lbJCvsOBJ5lgzOtGhmKHO3sk9uy3kOlDsnu0DBmeXU4dfXbcQXk6hAVbeL0TXqe7yH8dY462yiIDSq(bzTt3aUCa8W1yfkWcWRn2L1tdGGej7)AXtRuGfGxBSlRNgaHcI8(umUYGuukWcWRn2L1tdGOldsrPepTI8Kq3gZxmYqNapyidrVLudfDiyHupSbvmWdeYcOpfxoeFOOGpl6uireQGifezaCznsIK4dLS(Fr)q7nGOcIuqKbWL1i5jHNo32osbrgaKLlbJEaGLlbdIsWYvgKIkxPfilYvgPEiMRa9aalxbiMlwcwsOBJ5lgzOtaApyj6SdSeiuQHIU9jILxHQMgarNYrUc0daDVeDbADJk3gdrSdrEFkMKC0yfTLZQtiNRa9aq3lrxGw3OkgBRPAscDBmFXidDcqZNqkgAPB)xlEALI9G6oe9deQGiVpftQHIE4AScf7b1Di6hiKB4WgmuXWJ947h2OB4tK8eUHdBWqfdp2JVlgS9t4A)xlEALI9G6oe9deQGiVpftsoASI2IHuKTtiNRBJHi2Xc5hKr)Cs4PZLGWNixQhMlbJEaqcwUemisacgPgnM7qLlqMgarUaJ7yUXNBdg5YciwnbGCLbPOYv2TTY1z(rsOBJ5lgzOtaA(esXqlD7)AXtRuc0daSUaevqK3NIj1qr3(eXYRqvtdGOt5ix7)AXtRuc0daSUaevqK3NIjzJvW1TXqe7yH8dYOFoj0TX8fJm0janFcPyOLU9FT4PvkbsnAubrEFkMudfD7telVcvnnaIoLJCT)RfpTsjqQrJkiY7tXKSXk462yiIDSq(bz0pNeE6CjO2y(kxPzyblxVe5s2DGfcz5Ybz3bwiKratu6bXYISCblg4XXdduK7u56cXxkYtcDBmFXidDcyDTU72y(QRhwiv58i9aovlmyjHUnMVyKHobSUw3DBmF11dlKQCEKU9jILxblj0TX8fJm0jG116UBJ5RUEyHuLZJ0HUDCnlj80Nox3gZxmYqNamu6bXYIsnu0DBmeXowi)Gm6N5cCb6bGERAAaekXWCzn29peCdxJvOyG88F1BCyZBuJsvopsVXHn9)aleEQhmKHO36uuilq4unDwaNw4POqwGWPA6SaoTWtXa55)Q34WM3OgpLd5n2FQEaa7c0fNsGEaOB)rl1qrxgKIsXafcS6I)5vGhNsGEaOB)rFkb6bGU9h9Py2he2GDwaNwOudfDbkdsrPOqwGWPA60EWsOyHBB1ozDkM9bHnyNfWPfk1qrxGYGuukkKfiCQMoThSekw42wTtwNIczbcNQPZc40ctcp9PZ1TX8fJm0jadLEqSSOudfD3gdrSJfYpiJ(zUaxGEaO3QMgaHsmmxwJD)dbxGhUgRqXa55)Q34WM3OgLQCEK(FGfcpffYceovtNfWPfEkkKfiCQMolGtl8uhFmFDkWcWRn2L1tdG4uch2QhqVyupK3J5Rt5hV11gpyysOBJ5lgzOtaRR1D3gZxD9WcPkNhPB)xlEAflj0TX8fJm0jaeS6UnMV66Hfsvops3FSZWa8qQHIorhoUSgvUqW6qK3NIlh2)1INwPeOha6Ej6c06gvqK3NIj5zdXf4HRXkucKA0ijs2)1INwPei1Orfe59PysE2qCdxJvOei1OrsKSprS8ku10ai6uoY1(Vw80kLa9aaRlarfe59PysE2qKZf4c0daDVeDbADJQySTMQjj0TX8fJm0jaeS6UnMV66Hfsvops3FSldczHuSao2G(zPgk6UngIyhlKFqw70nGRa9aq3lrxGw3OkgBRPAscDBmFXidDcabRUBJ5RUEyHuLZJ0BWcHJT7pk1qr3TXqe7yH8dYANUbC5a4c0daDVeDbADJQySTMQHlh2)1INwPeOha6Ej6c06gvqK3NI1(zdXf4HRXkucKA0ijs2)1INwPei1Orfe59PyTF2qCdxJvOei1OrsKSprS8ku10ai6uoY1(Vw80kLa9aaRlarfe59PyTF2qKtEsOBJ5lgzOtaRR1D3gZxD9WcPkNhP3GfchRuSao2G(zPgk6UngIyhlKFqg9ZjHjHN(05sqFG5C5eiKfjHUnMVyk)XUmiKf0TAN2unDgax80ysnu0DBmeXowi)GmjPFssOBJ5lMYFSldczbzOtaR2PnvtNbWfpnMudfD3gdrSJfYpiJU0XvGEaO3QMgaHII2dwcu0dh2GbRD6goj0TX8ft5p2LbHSGm0jaThSeD2bwcek1qrpCnwHsgeYIPA6ShImUCiqpa0BvtdGqrr7blbk6HdBWGr3TXqe7yH8dYirsGEaO3QMgaHII2dwcu0dh2GbRD6gMCsKcxJvOKbHSyQMo7HiJB4AScLv70MQPZa4INgJRa9aqVvnnacffThSeOOhoSbdw70pNe62y(IP8h7YGqwqg6eqGEaOB)rl1qrNdzqkkfduiWQl(Nxbr3gKibCIoCCznQo(xpvthcwJTF80qi5C5qgKIsjCyREa9Ir9qEpMVuGhCHGfs9WgujqxOhKfD7pAUUngIyhlKFqMK0nmjsUngIyhlKFqgDdipj0TX8ft5p2LbHSGm0jaEmcKFSsnu0HG1y7hpneQei1yNqsooBiYiqpa0BvtdGqrr7blbk6HdBWG1wmm5CfOha6TQPbqOOO9GLaf9WHnyWKu64cCIoCCznQo(xpvthcwJTF80qijsYGuukgnhYpvtNFyHc8ij0TX8ft5p2LbHSGm0jaEmcKFSsnu0HG1y7hpneQei1yNqsdoHRa9aqVvnnacffThSeOOhoSbdw7NWf4eD44YAuD8VEQMoeSgB)4PHWKq3gZxmL)yxgeYcYqNa4Xiq(Xk1qrh4c0da9w10aiuu0EWsGIE4WgmyCborhoUSgvh)RNQPdbRX2pEAiKejQPbq0HiVpftYtirc6JOJeXkuUqWuiNhwW4c9r0rIyfkxiykiY7tXK8KKq3gZxmL)yxgeYcYqNa0EWs0zhyjqysOBJ5lMYFSldczbzOta8yei)yLAOOdCIoCCznQo(xpvthcwJTF80qysys4PpDUe0hyoxtmapscDBmFXu(JDggGh09YyxucPgk6c0da9w10aiuu0EWsGIE4WgmyTt3A0QXowi)GmsKeOha6TQPbqOOO9GLaf9WHnyWAN(jKib8W1yfkzqilMQPZEiYirc6JOJeXkuUqWuiNhwW4c9r0rIyfkxiykiY7tXKK(5ZKirnnaIoe59Pyss)85Kq3gZxmL)yNHb4bzOtab6bGU9hTudfDGt0HJlRr1X)6PA6qWAS9JNgc5YHmifLs4Ww9a6fJ6H8EmFPap4cblK6HnOsGUqpil62F0CDBmeXowi)GmjPBysKCBmeXowi)Gm6gqEsOBJ5lMYFSZWa8Gm0jaEmcKFSsnu0borhoUSgvh)RNQPdbRX2pEAimj0TX8ft5p2zyaEqg6eGczbcNQPZc40cLYA0QXE4Wgmy0pl1qrxGYGuukkKfiCQMoThSekw42wss3WCT)RfpTs5hV11gpyOcI8(umjnCsOBJ5lMYFSZWa8Gm0jafYceovtNfWPfkL1OvJ9WHnyWOFwQHIUaLbPOuuilq4unDApyjuSWTTK8CsOBJ5lMYFSZWa8Gm0jafYceovtNfWPfkL1OvJ9WHnyWOFwQHIoeSqvm8yp(ozjjh2)1INwPeOha6Ej6c06gvqK3NIXf4HRXkucKA0ijs2)1INwPei1Orfe59PyCdxJvOei1OrsKSprS8ku10ai6uoY1(Vw80kLa9aaRlarfe59PyKNeE6CjiaGvUHdBWixgn)GLRdXCfdZL1OqQCdadlxAJwNRgJCn(G5YoWsKleSqgbO9GLGL7uSaDrUpvU08jMQjxQhMlbxembiyKA0ibiy0dasWYLGbrvsOBJ5lMYFSZWa8Gm0jaThSeD2bwcek1qrNdGZWiMQHPSgTAKejb6bGERAAaekkApyjqrpCydgS2PBnA1yhlKFqg5CfOmifLIczbcNQPt7blHIfUTv7gMleSqvm8yp(UHL0(Vw80kLxg7IsOGiVpfljmj80No322hZxjHUnMVyk7)AXtRy0p(y(sQHIorhoUSgv8U06HD7)AXtRyD3gdrKePdmunoS5nQrLBJHiY9advJdBEJAubrEFkMK0nq6irIAAaeDiY7tXK0aPlj80NoxG9FT4PvSKq3gZxmL9FT4PvmYqNaoK3y)P6baSlqxi1qr3(Vw80kfyb41g7Y6PbqOGiVpftsYgx7)AXtRuch2QhqVyupK3J5lfe59PyDKZhOnqHKKnUHRXkuGfGxBSlRNgabxoS)RfpTs5hV11gpyOcI8(uSoY5d0gOqsYgxIoCCznQOa16Uvajrc4eD44YAurbQ1DRasojsapCnwHcSa8AJDz90aiirs(zmUutdGOdrEFkMKg(KKq3gZxmL9FT4PvmYqNaShu3HOFGqPSgTAShoSbdg9Zsnu0dh2GHkgEShF)WgDdFIKNWnCydgQy4XE8DXGTFcx3gdrSJfYpits6goj805cm2RfSC5KEAae5s9WCbpYn(CpjxgA)sWYn(CzglBU0MaqUe0J36AJhmuQCj7caiK2WqPYfKH5sBca5sWoSvUaf6fJ6H8EmFPscDBmFXu2)1INwXidDcawaETXUSEAaesnu0j6WXL1OIf9dTx1unC5W(Vw80kLF8wxB8GHkiY7tX6iNpqBGcjpHej7)AXtRu(XBDTXdgQGiVpfRJC(aTbkA)SHiNlh2)1INwPeoSvpGEXOEiVhZxkiY7tXKSXkirsgKIsjCyREa9Ir9qEpMVuGhKNe62y(IPS)RfpTIrg6eaSa8AJDz90aiKAOOt0HJlRrLleSoe59Pirs(zmUutdGOdrEFkMKgCoj0TX8ftz)xlEAfJm0jGWHT6b0lg1d59y(sQHIorhoUSgvSOFO9QMQHlhIpuGfGxBSlRNgarx8HcI8(umsKaE4AScfyb41g7Y6PbqqEsOBJ5lMY(Vw80kgzOtaHdB1dOxmQhY7X8LudfDIoCCznQCHG1HiVpfjsYpJXLAAaeDiY7tXK0GZjHUnMVyk7)AXtRyKHob8J36AJhmuQHIUBJHi2Xc5hKr)mxbkdsrPOqwGWPA60EWsOyHBB1oDYIlhaNOdhxwJkkqTUBfqsKi6WXL1OIcuR7wbKlh2)1INwPalaV2yxwpnacfe59PyTF2qKiz)xlEALs4Ww9a6fJ6H8EmFPGiVpfRJC(aTbkA)SH4c8W1yfkWcWRn2L1tdGGCYtcDBmFXu2)1INwXidDc4hV11gpyOuwJwn2dh2GbJ(zPgk6UngIyhlKFqw70nGRaLbPOuuilq4unDApyjuSWTTA3WCbUa9aq3lrxGw3OkgBRPAscDBmFXu2)1INwXidDcWa55)Q34WM3OgLAOOdbRX2pEAiujqQXoHKNjlU2)1INwPalaV2yxwpnacfe59PysE2WCT)RfpTsjCyREa9Ir9qEpMVuqK3NI1roFG2afsE2WjHUnMVyk7)AXtRyKHobalaV2y3zmhuhsnu0j6WXL1OIf9dTx1unCfOmifLIczbcNQPt7blHIfUTLKgWLJdmu(XB7naEqTYTXqejrsgKIsjCyREa9Ir9qEpMVuGhCT)RfpTs5hV11gpyOcI8(uS2pBiYtcDBmFXu2)1INwXidDcawaETXUZyoOoKYA0QXE4Wgmy0pl1qr3TXqe7yH8dYANUbCfOmifLIczbcNQPt7blHIfUTLKgWLJdmu(XB7naEqTYTXqejrsgKIsjCyREa9Ir9qEpMVuGhKiz)xlEALsGEaO7LOlqRBubrEFkMKnwb5jHUnMVyk7)AXtRyKHobG(WWUaDHudfDGFGHQbWdQvUngIys4PpDUe8WCznkKkxPfilYT(ixi6ATXCRhY76CLraoX5H5ga8qcwU0Eyai3dqidCQMCNsA348Okj80Nox3gZxmL9FT4PvmYqNam3chQXoUUF42qQHIUBJHi2Xc5hK1oDd4cCzqkkLWHT6b0lg1d59y(sbEW1(Vw80kLWHT6b0lg1d59y(sbrEFkw7NqIK8ZyCPMgarhI8(umjBSIKWKWKWtF6Cb2NiwEf5sqLh9edYscDBmFXu2NiwEfm6mAoKFQMo)WcPgk6eD44YAuXI(H2RAQgUqWAS9JNgcvcKASt0(zPJlh2)1INwP8J36AJhmubrEFkgjsapCnwHYH8g7pvpaGDHZxOGR9FT4PvkHdB1dOxmQhY7X8LcI8(umYjrs(zmUutdGOdrEFkMKNpNeE6CnXi34ZfKH56ubcZ1pEBUdl3VYfyj4CDwUXN7bejIvK7teHw)4yQMCB7TTCPby0yUmmIPAYf8ixGLGLGLe62y(IPSprS8kyKHoby0Ci)unD(Hfsnu0T)RfpTs5hV11gpyOcI8(umUC42yiIDSq(bzTt3aUUngIyhlKFqMK0pHleSgB)4PHqLaPg7eTF2qKHd3gdrSJfYpiRTiDKZLOdhxwJkxiyDiY7trIKBJHi2Xc5hK1(jCHG1y7hpneQei1yNODYYqKNe62y(IPSprS8kyKHobC5NFkpMV66HxwQHIorhoUSgvSOFO9QMQHlWzpOwEkHsJUOlBSJC25p0ixoS)RfpTs5hV11gpyOcI8(umsKaE4AScLd5n2FQEaa7cNVqbx7)AXtRuch2QhqVyupK3J5lfe59PyKZfcwOkgEShFNSAxgKIsbbRX2TpecEeZxkiY7tXirs(zmUutdGOdrEFkMKgCoj0TX8ftzFIy5vWidDc4Yp)uEmF11dVSudfDIoCCznQyr)q7vnvdx2dQLNsO0Ol6Yg7iND(dnYLdXhkWcWRn2L1tdGOl(qbrEFkw7NptIeWdxJvOalaV2yxwpnacU2)1INwPeoSvpGEXOEiVhZxkiY7tXipj0TX8ftzFIy5vWidDc4Yp)uEmF11dVSudfDIoCCznQCHG1HiVpfxiyHQy4XE8DYQDzqkkfeSgB3(qi4rmFPGiVpflj0TX8ftzFIy5vWidDcWa42wAShaWoyr7HbaJsnu0j6WXL1OIf9dTx1unC5W(Vw80kLF8wxB8GHkiY7tXA)SHirc4HRXkuoK3y)P6baSlC(cfCT)RfpTsjCyREa9Ir9qEpMVuqK3NIrojsYpJXLAAaeDiY7tXK88jjHUnMVyk7telVcgzOtaga32sJ9aa2blApmayuQHIorhoUSgvUqW6qK3NIlhc0daDVeDbADJQySTMQHejOpIoseRq5cbtbrEFkMK0ptwKNeMeE6tNR5unAmxG6WgmscDBmFXunyHWXsxGEaOB)rl1qrh4eD44YAuD8VEQMoeSgB)4PHqUCidsrPyGcbwDX)8ki62Gejiyn2(XtdHkbsn2jKK(zdtojshyOACyZBuJk3gdrKleSqjPBysKOMgarhI8(umjpBiUaxGYGuukkKfiCQMoThSekWJKq3gZxmvdwiCSKHob8YyxucPgk6CeUgRqjqQrJkSCznkirY(eXYRqvtdGOt5ijsqWcPEydQoaGo85)czKZLdGt0HJlRr1X)6PA6qWczKij)mgxQPbq0HiVpftYtipj0TX8ft1GfchlzOtaApyj6SdSeiuQHIorhoUSgv8U06H9d4BzD3gdrKRaLbPOuuilq4unDApyjuSWTTAN(zU2)1INwP8J36AJhmubrEFkwh58bAdu0(jCborhoUSgvh)RNQPdblKLe62y(IPAWcHJLm0jaThSeD2bwcek1qrxGYGuukkKfiCQMoThSekw42wTByUaNOdhxwJQJ)1t10HGfYirsGYGuukkKfiCQMoThSekWdUutdGOdrEFkMKCiqzqkkffYceovtN2dwcflCBR2sJvqEsOBJ5lMQbleowYqNac0daD7pAPgk6qWAS9JNgcvcKAStijDdmexGt0HJlRr1X)6PA6qWAS9JNgctcDBmFXunyHWXsg6eGczbcNQPZc40cLAOOlqzqkkffYceovtN2dwcflCBljjlUaNOdhxwJQJ)1t10HGfYscDBmFXunyHWXsg6eqGEaOB)rl1qrh4eD44YAuD8VEQMoeSgB)4PHWKq3gZxmvdwiCSKHobO9GLOZoWsGqPgk6cugKIsrHSaHt10P9GLqXc32QD6N5cblusd4cCIoCCznQo(xpvthcwiJR9FT4Pvk)4TU24bdvqK3NI1roFG2afTFssys4PpDUTvyHWXMlb9bMZTTbNhoHXKq3gZxmvdwiCSD)r608jKIHw62)1INwPypOUdr)aHkiY7tXKAOOhUgRqXEqDhI(bc5goSbdvm8yp((Hn6g(ejpHl10ai6qK3NI1(jCT)RfpTsXEqDhI(bcvqK3NIjjhnwrBXqkY2jKZ1TXqe7yH8dYKKUHtcDBmFXunyHWX29hjdDciqpa0T)OLAOOZbWj6WXL1O64F9unDiyn2(XtdHKijdsrPyGcbwDX)8ki62GCUCidsrPeoSvpGEXOEiVhZxkWdUqWcPEydQeOl0dYIU9hnx3gdrSJfYpits6gMej3gdrSJfYpiJUbKNe62y(IPAWcHJT7psg6eapgbYpwPgk6YGuukgOqGvx8pVcIUnirc4eD44YAuD8VEQMoeSgB)4PHWKWtNlWavUHdBWixRrREQMChwUIH5YAuivUmAtybKRSBBLB85gaWCzt1OrPD4WgmYTbleo2C1dlYDkwGUqLe62y(IPAWcHJT7psg6eacwD3gZxD9WcPkNhP3GfchRuSao2G(zPgk6wJwn2Xc5hKr)CsOBJ5lMQbleo2U)izOtaApyj6SdSeiukRrRg7HdBWGr)SudfDoS)RfpTs5hV11gpyOcI8(uS2pHRaLbPOuuilq4unDApyjuGhKijqzqkkffYceovtN2dwcflCBR2nm5C5GAAaeDiY7tXK0(Vw80kLa9aq3lrxGw3OcI8(umYC2qKirnnaIoe59PyTB)xlEALYpERRnEWqfe59PyKNe62y(IPAWcHJT7psg6eGczbcNQPZc40cLYA0QXE4Wgmy0pl1qrxGYGuukkKfiCQMoThSekw42wss3WCT)RfpTs5hV11gpyOcI8(umjpHejbkdsrPOqwGWPA60EWsOyHBBj55Kq3gZxmvdwiCSD)rYqNauilq4unDwaNwOuwJwn2dh2GbJ(zPgk62)1INwP8J36AJhmubrEFkw7NWvGYGuukkKfiCQMoThSekw42wsEoj805cuadl3HLlsrH2yiIAJ5snAncZLgGXcix2WZYLGBBM5wiyaDTu5kdg5Ya8GArUhqKiwrUEUmlwoC(CPbaHyUbamxxi(kxaol36dat1KB85cr7ZZJLqLe62y(IPAWcHJT7psg6eGczbcNQPZc40cLAOO72yiIDXhkkKfiCQMoThSeTt3A0QXowi)GmUcugKIsrHSaHt10P9GLqXc32ssYkjmj80522D74AwsOBJ5lMc62X1m6o06f2JhcXkKAOOdbRX2pEAiujqQXor7s3jC54advJdBEJAu52yiIKib8W1yfkgip)x9gh28g1OclxwJcY5cblujqQXor70pjj0TX8ftbD74AgzOtaz9)Iofi0OudfDIoCCznQ4DP1d72)1INwX6UngIijshyOACyZBuJk3gdrK7bgQgh28g1OcI8(umjPldsrPK1)l6uGqJkbi0J5lsKKFgJl10ai6qK3NIjjDzqkkLS(FrNceAujaHEmFLe62y(IPGUDCnJm0jGmcziS1unsnu0j6WXL1OI3LwpSB)xlEAfR72yiIKiDGHQXHnVrnQCBmerUhyOACyZBuJkiY7tXKKUmifLsgHme2AQgLae6X8fjsYpJXLAAaeDiY7tXKKUmifLsgHme2AQgLae6X8vsOBJ5lMc62X1mYqNa6PbqW6slqrdpwHudfDzqkkfyb41g7SaIvtaqbEKeE6CjOLfzb015cSUwNR1RCd400GWCjRCp(aRyCDUYGuumPYfDlGC1olMQj3ZNKldTFjyQCBRJrpK9qrUaCOix7lqrUXWJ56SC9Cd400GWCJp3wiEK7e5crx4YAuLe62y(IPGUDCnJm0jGxwKfqx3TUwl1qrNOdhxwJkExA9WU9FT4PvSUBJHisI0bgQgh28g1OYTXqe5EGHQXHnVrnQGiVpfts6NpHej5NX4snnaIoe59Pyss)8jjHUnMVykOBhxZidDc4qRxy)auZqPgk6UngIyhlKFqw70nGejoGGfQei1yNOD6NWfcwJTF80qOsGuJDI2PlDgI8Kq3gZxmf0TJRzKHobOgikR)xi1qrNOdhxwJkExA9WU9FT4PvSUBJHisI0bgQgh28g1OYTXqe5EGHQXHnVrnQGiVpfts6YGuukQbIY6)fkbi0J5lsKKFgJl10ai6qK3NIjjDzqkkf1arz9)cLae6X8vsOBJ5lMc62X1mYqNaYEt)P6bCSTysnu0DBmeXowi)Gm6N5YHmifLcSa8AJDwaXQjaOapirs(zmUutdGOdrEFkMKNqEsys4PpDUafovlmyjHUnMVyQaovlmy0bzyFcKxQY5r6tXSqWWL1yx6b9ka57cK4yrPgk6Cy)xlEALcSa8AJDz90aiuqK3NI1UbgIej7)AXtRuch2QhqVyupK3J5lfe59PyDKZhOnqr7gyiY5YHBJHi2Xc5hK1oDdir6adLd5n2Ba8GALBJHisI0bgk)4T9gapOw52yiIC5iCnwHcSa8AJDNXCqDqIKa9aqVvnnacLyyUSg7(hcYjr6advJdBEJAu52yiIKtIK8ZyCPMgarhI8(umjn4mjsHdBWqfdp2JVFyJUbgsYtscDBmFXubCQwyWidDcaYW(eiVuLZJ05DRldXodaIrNhKnwPgk62)1INwP8J36AJhmubrEFkMKNWLdGJsp4CCGc1umlemCzn2LEqVcq(UajowKej7)AXtRutXSqWWL1yx6b9ka57cK4yrfe59PyKtIK8ZyCPMgarhI8(umjn4CsOBJ5lMkGt1cdgzOtaqg2Na5LQCEKUaIUGAGyNiYyOwQHIU9FT4Pvk)4TU24bdvqK3NIXLdGJsp4CCGc1umlemCzn2LEqVcq(UajowKej7)AXtRutXSqWWL1yx6b9ka57cK4yrfe59PyKtIK8ZyCPMgarhI8(umjnCsOBJ5lMkGt1cdgzOtaqg2Na5LQCEKUWHT4)V6c02Qt8HUDcJsnu0T)RfpTs5hV11gpyOcI8(umUCaCu6bNJduOMIzHGHlRXU0d6vaY3fiXXIKiz)xlEALAkMfcgUSg7spOxbiFxGehlQGiVpfJCsKKFgJl10ai6qK3NIjPbNtcDBmFXubCQwyWidDceWPAHXzPgk6aNOdhxwJk2bAhQbf9aovlm4YbhbCQwyOoRKbPO6cqOhZxss)8jCT)RfpTs5hV11gpyOcI8(uS2nWqKifWPAHH6SsgKIQlaHEmF1(5t4YH9FT4PvkWcWRn2L1tdGqbrEFkw7gyisKS)RfpTsjCyREa9Ir9qEpMVuqK3NI1roFG2afTBGHiNej3gdrSJfYpiRD6gWvgKIsjCyREa9Ir9qEpMVuGhKZLdGhWPAHHYafaN1T)RfpTIePaovlmugOS)RfpTsbrEFkgjseD44YAufWPAHr)aopCcJ0pto5KifWPAHH6SsgKIQlaHEmF1oDQPbq0HiVpflj0TX8ftfWPAHbJm0jqaNQfggi1qrh4eD44YAuXoq7qnOOhWPAHbxo4iGt1cdLbkzqkQUae6X8LK0pFcx7)AXtRu(XBDTXdgQGiVpfRDdmejsbCQwyOmqjdsr1fGqpMVA)8jC5W(Vw80kfyb41g7Y6PbqOGiVpfRDdmejs2)1INwPeoSvpGEXOEiVhZxkiY7tX6iNpqBGI2nWqKtIKBJHi2Xc5hK1oDd4kdsrPeoSvpGEXOEiVhZxkWdY5YbWd4uTWqDwbWzD7)AXtRirkGt1cd1zL9FT4PvkiY7tXirIOdhxwJQaovlm6hW5HtyKUbKtojsbCQwyOmqjdsr1fGqpMVANo10ai6qK3NIDnDWaWdVMMdpO2J5lGf6uXnUX9c]] )


end
