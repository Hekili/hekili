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


    spec:RegisterPack( "Unholy", 20210801, [[deL6XcqiavpsfsxcbqBcv5tiPgfsLtHu1QKsbVcjPzHQYTqLsTlc)cbAyOs1XubldvvpJkKPHa6AQqTnvi6BOsHXHkf5COsrToPu6DsPiL5rfCpuX(Ks1bbu0crL4HaknrKeUiGc2icq1hLsrmseaQtkLIALiOxIaqMjsIUPuks1obK(Puk0qbuOLQcHEQumvaXvraWwLsrYxraYyPc1EvP)kvdwPdlAXK4Xu1Kj6YqBgrFMknAaoTIvRcbVMkA2K62K0UL8BvnCv0XrLswoONJY0PCDG2oc9DKY4rL05Lswpcqz(iX(f(E4cKBJmn8cu(5o)h4o3e3pioCKh4(b(VnwRt82CMENPlEBQufVneakaVU1T5mBP)uEbYTH9GqpEBay2jRTeKGUJbaur4FvcYgvqDAZxEysAeKnQEcEBuahT1MRRYTrMgEbk)CN)dCNBI7hehosUZn7OJVnSt0Fbk)hZ)TbWiLyDvUnsK5VnubMgGyjaQgxawSeakaVUvqiWe0fKzXEGVy5N78FiimieybKLlYABqi3owGP8iaYmvSmwS2hlvuubbPcKC0ibPcmnaSyPcqmw7J9lDRy9pyzXAj0fnwS0a8XMqmwKRNO3qzS2hREiIXQ)YnwSEqxaXAFSQPzimw6Yh7m0apJ9OhOxeeYTJLkgwQOrzSnPhoKJFsDSaJP3Ivb9jidJvIPmwxapOMfRA6eJL8HXYszSubbqmrqi3owcaSPCJLa6blzSnNyjrySPYOhBqwSQpeJLuJCDu0TILU0ILaPASml9ozXofZWug7tg7XuL(20ILkagBITqqdM6yZsgRA2k2tisellw2RIXwp3gI(yzJbM28fteeYTJLaaBk3yjGJmdHt5gBJbhNyStflWSncme7qgBRhmwajrm26nat5glQzyS2hR8JnlzS0(IAl2Nic95zS0EWsYIDyXsfaJnXwiObtTiiKBhlWcilxugRAwTILAYXfG1HOAofJ6y9FjhB(k1SyTp288u3k2PIv5zSyjhxagl2V0TILonYyXcSurS0sMHX(vSgmzaOxeeYTJfykLOm2SEdacJTncAkqmDglwgSvS2hldTybpJLzWVCrySadNJevhpteeYTJ9iI6KRX2aKyjYeXcmBJadXQF3XhlBkpg7yXcr9GSy)kw)xKPcOonuglmhzhjILXebHC7ybsBKkAJTn2yjGNE7HX2yqSCnaXEcFpl2PSpwdoLt0Iv)UJxCB0dZyxGCBYh7m0apVa5c0dxGCBWkv0O8YLBJhogcN82iX0a0DwJlatqs7bljk7wcDrJfB7CI13YRXowO6GSyPqjwjMgGUZACbycsApyjrz3sOlASyBNtShhlfkXc8yTuJLjuaHmBk3o7HitGvQOrzSuOelmhzhjILjsPKjqUomJflVyH5i7irSmrkLmbevZPyX6aNypCiwkuILCCbyDiQMtXI1boXE4WTj9281TjRwDzjV2fO8FbYTbRurJYlxUnE4yiCYBdWJLycNurJIZ)1t52HG147NpneglVyPlwfqssHmHo7gmlg5dvtB(saEglVyHGfs(qxuiXuQhKzD)pAbwPIgLXYl20BdrSJfQoilwh4eRJILcLytVneXowO6GSy5el)Xs)Tj9281TrIPbO7)rFTlqD0fi3gSsfnkVC524HJHWjVnapwIjCsfnko)xpLBhcwJVF(0q4Tj9281TbphjQo(RDbkbEbYTbRurJYlxUnP3MVUnKiZq4uUDMbhN4TXdhdHtEBKOcijPGezgcNYTt7blPGzP3zSoWjwhflVy9)RLpTsKNVp1TozOaIQ5uSyDiwhDB8T8ASBj0fn2fOhU2fOhFbYTbRurJYlxUnP3MVUnKiZq4uUDMbhN4TXdhdHtEBKOcijPGezgcNYTt7blPGzP3zSoe7HBJVLxJDlHUOXUa9W1Ua9iVa52GvQOr5Ll3M0BZx3gsKziCk3oZGJt824HJHWjVnqWcf2OID77eySoelDX6)xlFALqIPbONLSlrF2sar1CkwS8If4XAPgltirYrJcSsfnkJLcLy9)RLpTsirYrJciQMtXILxSwQXYesKC0OaRurJYyPqjw)teRSmrnUaSozIXYlw))A5tResmnaSUeefqunNIfl93gFlVg7wcDrJDb6HRDbk34cKBdwPIgLxUCBsVnFDBO9GLSZoXsIWBJezE4CAZx3gciayfRLqx0ILrlpzXMqmw5Wsfnk5lwdWWIL2O1XQrl2wpySStSKXcblKrqApyjzXofZWug7tglTCSPCJL8HXsffvqqQajhnsqQatda1SyPcquCB8WXq4K3g6If4XYqZMYLj8T8AmwkuIvIPbO7SgxaMGK2dwsu2Te6Igl225eRVLxJDSq1bzXsFS8IvIkGKKcsKziCk3oThSKcMLENX2ESokwEXcbluyJk2TV7OyDiw))A5tRez1QllPaIQ5uSRDTBt(yxbeYSlqUa9Wfi3gSsfnkVC524HJHWjVnP3gIyhluDqwSoWj2JVnP3MVUnEDsBk3odqkFASRDbk)xGCBWkv0O8YLBJhogcN82KEBiIDSq1bzXYj2JmwEXkX0a0DwJlatqs7bljk7wcDrJfB7CI1r3M0BZx3gVoPnLBNbiLpn21Ua1rxGCBWkv0O8YLBJhogcN82yPgltOacz2uUD2drMaRurJYy5flDXkX0a0DwJlatqs7bljk7wcDrJflNytVneXowO6GSyPqjwjMgGUZACbycsApyjrz3sOlASyBNtSokw6JLcLyTuJLjuaHmBk3o7HitGvQOrzS8I1snwMWRtAt52zas5tJjWkv0OmwEXkX0a0DwJlatqs7bljk7wcDrJfB7CI9WTj9281TH2dwYo7eljcV2fOe4fi3gSsfnkVC524HJHWjVn0fRcijPGbkLy1L)RkGy6TyPqjwGhlXeoPIgfN)RNYTdbRX3pFAimw6JLxS0fRcijPqMqNDdMfJ8HQPnFjapJLxSqWcjFOlkKyk1dYSU)hTaRurJYy5fB6THi2XcvhKfRdCI1rXsHsSP3gIyhluDqwSCIL)yP)2KEB(62iX0a09)OV2fOhFbYTbRurJYlxUnE4yiCYBdeSgF)8PHqHejh)yX6qS0f7bUhlvJvIPbO7SgxaMGK2dwsu2Te6Igl22qSokw6JLxSsmnaDN14cWeK0EWsIYULqx0yX6qShzS8If4XsmHtQOrX5)6PC7qWA89ZNgcJLcLyvajjfmAjuDk3U6Wmb45Tj9281TbphjQo(RDb6rEbYTbRurJYlxUnE4yiCYBdeSgF)8PHqHejh)yX6qS8FCS8IvIPbO7SgxaMGK2dwsu2Te6Igl22J94y5flWJLycNurJIZ)1t52HG147NpneEBsVnFDBWZrIQJ)AxGYnUa52GvQOr5Ll3gpCmeo5Tb4XkX0a0DwJlatqs7bljk7wcDrJflVybESet4KkAuC(VEk3oeSgF)8PHWyPqjwYXfG1HOAoflwhI94yPqjwyoYoseltKsjtGCDyglwEXcZr2rIyzIukzciQMtXI1Hyp(2KEB(62GNJevh)1UaLB6cKBt6T5RBdThSKD2jwseEBWkv0O8YLRDbk38fi3gSsfnkVC524HJHWjVnapwIjCsfnko)xpLBhcwJVF(0q4Tj9281TbphjQo(RDTBdm9tQzxGCb6HlqUnyLkAuE5YTj9281TjH(SWU9qiw2TrImpCoT5RBZrm9tQz3gpCmeo5TbcwJVF(0qOqIKJFSyBp2J84y5flDXEIMWnHUFlnksVneXyPqjwGhRLASmbduv9RUBcD)wAuGvQOrzS0hlVyHGfkKi54hl225e7Xx7cu(Va52GvQOr5Ll3gpCmeo5THycNurJc18i8WU)FT8PvSE6THiglfkXEIMWnHUFlnksVneXy5f7jAc3e6(T0OaIQ5uSyDGtSkGKKcf9)YojiSLqcctB(kwkuIv5zSy5fl54cW6qunNIfRdCIvbKKuOO)x2jbHTesqyAZx3M0BZx3gf9)YojiS11Ua1rxGCBWkv0O8YLBJhogcN82qmHtQOrHAEeEy3)Vw(0kwp92qeJLcLyprt4Mq3VLgfP3gIyS8I9enHBcD)wAuar1CkwSoWjwfqssHcczi05uUcjimT5RyPqjwLNXILxSKJlaRdr1CkwSoWjwfqssHcczi05uUcjimT5RBt6T5RBJcczi05uUx7cuc8cKBdwPIgLxUCB8WXq4K3gfqssbyb41T6mdILRbqaEEBsVnFDB0JlaJ1pcGsxvSSRDb6XxGCBWkv0O8YLBt6T5RBtwEKzWu39PwFBKiZdNtB(62amlpYmyQJfytTowFwXAWX1fHXsGXE(gw2K6yvajjz8flMEaXQtMnLBShoowg6)sYeXsaWg9qadLXciHYy9VeLXAJkgBYInJ1GJRlcJ1(yDI4zSJfletzQOrXTXdhdHtEBiMWjv0OqnpcpS7)xlFAfRNEBiIXsHsSNOjCtO73sJI0BdrmwEXEIMWnHUFlnkGOAoflwh4e7HJJLcLyvEglwEXsoUaSoevZPyX6aNypC81Ua9iVa52GvQOr5Ll3gpCmeo5Tj92qe7yHQdYITDoXYFSuOelDXcbluirYXpwSTZj2JJLxSqWA89ZNgcfsKC8JfB7CI9i5ES0FBsVnFDBsOplSFcQz41UaLBCbYTbRurJYlxUnE4yiCYBdXeoPIgfQ5r4HD))A5tRy90BdrmwkuI9enHBcD)wAuKEBiIXYl2t0eUj09BPrbevZPyX6aNyvajjfKdev0)lfsqyAZxXsHsSkpJflVyjhxawhIQ5uSyDGtSkGKKcYbIk6)LcjimT5RBt6T5RBd5arf9)YRDbk30fi3gSsfnkVC524HJHWjVnP3gIyhluDqwSCI9qS8ILUyvajjfGfGx3QZmiwUgab4zSuOeRYZyXYlwYXfG1HOAoflwhI94yP)2KEB(62OKU9NSBWX7KDTRDBCXcHJ)cKlqpCbYTbRurJYlxUnE4yiCYBdWJLycNurJIZ)1t52HG147NpneglVyPlwfqssbdukXQl)xvaX0BXsHsSqWA89ZNgcfsKC8JfRdCI9GJIL(yPqj2t0eUj09BPrr6THiglVyHGfgRdCI1rXsHsSKJlaRdr1CkwSoe7bUhlVybESsubKKuqImdHt52P9GLuaEEBsVnFDBKyAa6(F0x7cu(Va52GvQOr5Ll3gpCmeo5THUyTuJLjKi5OrbwPIgLXsHsS(NiwzzIACbyDYeJLcLyHGfs(qxuCcat4R(fYeyLkAugl9XYlw6If4XsmHtQOrX5)6PC7qWczXsHsSkpJflVyjhxawhIQ5uSyDi2JJL(Bt6T5RBtwT6YsETlqD0fi3gSsfnkVC524HJHWjVnet4KkAuibvp70EWsYILxSsubKKuqImdHt52P9GLuWS07m225e7Hy5fR)FT8PvI889PU1jdfqunNI1rUEIEdLX2EShhlVybESet4KkAuC(VEk3oeSq2Tj9281TH2dwYo7eljcV2fOe4fi3gSsfnkVC524HJHWjVnsubKKuqImdHt52P9GLuWS07m22J1rXYlwGhlXeoPIgfN)RNYTdblKflfkXkrfqssbjYmeoLBN2dwsb4zS8ILCCbyDiQMtXI1HyPlwjQasskirMHWPC70EWskyw6DgBBiwxVmw6VnP3MVUn0EWs2zNyjr41Ua94lqUnyLkAuE5YTXdhdHtEBGG147NpnekKi54hlwh4el)CpwEXc8yjMWjv0O48F9uUDiyn((5tdH3M0BZx3gjMgGU)h91Ua9iVa52GvQOr5Ll3gpCmeo5TrIkGKKcsKziCk3oThSKcMLENX6qSeyS8If4XsmHtQOrX5)6PC7qWcz3M0BZx3gsKziCk3oZGJt8AxGYnUa52GvQOr5Ll3gpCmeo5Tb4XsmHtQOrX5)6PC7qWA89ZNgcVnP3MVUnsmnaD)p6RDbk30fi3gSsfnkVC524HJHWjVnsubKKuqImdHt52P9GLuWS07m225e7Hy5fleSWyDiw(JLxSapwIjCsfnko)xpLBhcwilwEX6)xlFALipFFQBDYqbevZPyDKRNO3qzSTh7X3M0BZx3gApyj7StSKi8Ax724FIyLLXUa5c0dxGCBWkv0O8YLBJhogcN82qmHtQOrbZ6N6SQPCJLxSqWA89ZNgcfsKC8JfB7XE4iJLxS0fR)FT8PvI889PU1jdfqunNIflfkXc8yTuJLjsOAR(t2nayxMQfkfyLkAuglVy9)RLpTsitOZUbZIr(q10MVequnNIfl9XsHsSkpJflVyjhxawhIQ5uSyDi2dhUnP3MVUnmAjuDk3U6WSRDbk)xGCBWkv0O8YLBt6T5RBdJwcvNYTRom72irMhoN281TPbTyTpwqggBsAim2889XoSy)kwGLkInzXAFSNqKiwwSpre6ZZZPCJ9icmglnaJgJLHMnLBSGNXcSub1SBJhogcN824)xlFALipFFQBDYqbevZPyXYlw6In92qe7yHQdYITDoXYFS8In92qe7yHQdYI1boXECS8IfcwJVF(0qOqIKJFSyBp2dCpwQglDXMEBiIDSq1bzX2gI9iJL(y5flXeoPIgfPuY6qunNkwkuIn92qe7yHQdYIT9ypowEXcbRX3pFAiuirYXpwSThlbY9yP)AxG6OlqUnyLkAuE5YTXdhdHtEBiMWjv0OGz9tDw1uUXYlwGhl7b1ktjfAmLDLwDKRP6PgfyLkAuglVyPlw))A5tRe557tDRtgkGOAoflwkuIf4XAPgltKq1w9NSBaWUmvlukWkv0OmwEX6)xlFALqMqNDdMfJ8HQPnFjGOAoflw6JLxSqWcf2OID77eySThRcijPacwJV7Fie80MVequnNIflfkXQ8mwS8ILCCbyDiQMtXI1Hy5)WTj9281TjvE1PsB(QRhvLRDbkbEbYTbRurJYlxUnE4yiCYBdXeoPIgfmRFQZQMYnwEXYEqTYusHgtzxPvh5AQEQrbwPIgLXYlw6Iv(MaSa86wDf94cW6Y3equnNIfB7XE4qSuOelWJ1snwMaSa86wDf94cWeyLkAuglVy9)RLpTsitOZUbZIr(q10MVequnNIfl93M0BZx3Mu5vNkT5RUEuvU2fOhFbYTbRurJYlxUnE4yiCYBdXeoPIgfmRFQZQMYnwEXYEqTYusHtK4uS()eWq9uUcSsfnkJLxSsubKKuqImdHt52P9GLuWS07m225elbEBsVnFDBsLxDQ0MV66rv5AxGEKxGCBWkv0O8YLBJhogcN82qmHtQOrrkLSoevZPILxSqWcf2OID77eySThRcijPacwJV7Fie80MVequnNIDBsVnFDBsLxDQ0MV66rv5AxGYnUa52GvQOr5Ll3gpCmeo5THycNurJcM1p1zvt5glVyPlw))A5tRe557tDRtgkGOAofl22J9a3JLcLybESwQXYejuTv)j7gaSlt1cLcSsfnkJLxS()1YNwjKj0z3GzXiFOAAZxciQMtXIL(yPqjwLNXILxSKJlaRdr1CkwSoe7HJVnP3MVUnmaP3Pg7gaSdw0EObO11UaLB6cKBdwPIgLxUCB8WXq4K3gIjCsfnksPK1HOAovS8ILUyLyAa6zj7s0NTe24DoLBSuOelmhzhjILjsPKjGOAoflwh4e7bcmw6VnP3MVUnmaP3Pg7gaSdw0EObO11UaLB(cKBdwPIgLxUCB8WXq4K3g2dQvMskobzgOg7ie80MVeyLkAuEBsVnFDBi1idGhMK21U2T5eI(xvjTlqUa9Wfi3M0BZx3MZ3MVUnyLkAuE5Y1UaL)lqUnP3MVUnWCyyxIP82GvQOr5Llx7cuhDbYTj9281THuJmaEysA3gSsfnkVC5AxGsGxGCBWkv0O8YLBt6T5RBtcvB1FYUba7smL3gpCmeo5Tb4XAPgltWavv)Q7Mq3VLgfyLkAuEBoHO)vvsRBJkEBC01Ua94lqUnyLkAuE5YT5pVnm0gYBJhogcN82yWPCIMWoiaKSoid7kGKKXYlw6I1Gt5enHDq4)xlFALqcctB(kwcWyjWJJLtSCpw6VnsK5HZPnFDBagiMAW0qwSzSgCkNOXI1)Vw(0k(IvoehjkJvPvSe4XIybcGHflTKfRhWZWk2Kflyb41TIL2dDYI9RyjWJJLH(VKXQaczwS(wEnY4lwfqlwajlw7)yvZQvSEjmwKKe9glw7J1DiIXMX6)xlFALGRcjimT5RyLdXH9WyNIzykfX2MjJDmQzXsm1GySaswS1hlevZPKimwiAGWk2d8flQzySq0aHvSCxCS42qmH9kvXBJbNYjA9dDwRYFBsVnFDBiMWjv04THyQbXoQz4TH7IJVnetniEBoCTlqpYlqUnyLkAuE5YT5pVnm0gYBt6T5RBdXeoPIgVnetyVsv82yWPCIwN)oRv5VnE4yiCYBJbNYjAcJFbGK1bzyxbKKmwEXsxSgCkNOjm(f()1YNwjKGW0MVILamwc84y5el3JL(BdXudIDuZWBd3fhFBiMAq82C4AxGYnUa52GvQOr5Ll3M)82WqBiVnE4yiCYBdWJ1Gt5enHDqaizDqg2vajjJLxSgCkNOjm(faswhKHDfqsYyPqjwdoLt0eg)cajRdYWUcijzS8ILUyPlwdoLt0eg)c))A5tResqyAZxXsWyn4uorty8luajj7sqyAZxXsFSTHyPl2dIJJLQXAWPCIMW4xaizDfqsYyPp22qS0flXeoPIgfgCkNO15VZAv(yPpw6JT9yPlw6I1Gt5enHDq4)xlFALqcctB(kwcgRbNYjAc7GqbKKSlbHPnFfl9X2gILUypioowQgRbNYjAc7GaqY6kGKKXsFSTHyPlwIjCsfnkm4uorRFOZAv(yPpw6VnsK5HZPnFDBagy2OMgYInJ1Gt5enwSetnigRsRy9V6zcNYnwdagR)FT8PvX(KXAaWyn4uorJVyLdXrIYyvAfRbaJvcctB(k2NmwdagRcijzSJf7j8josKjILa4KfBglZGy5AaIv9Ld5GWyTpw3HigBglGXfacJ9eopCSwXAFSmdILRbiwdoLt0y8fBYILgQ1XMSyZyvF5qoimwYhg7qgBgRbNYjAXsB06yFyS0gTo26TyzTkFS0gdqS()1YNwXe3gIjSxPkEBm4uorRFcNhowRBt6T5RBdXeoPIgVnetni2rndVnhUnetniEB4)AxGYnDbYTbRurJYlxUn)5THH2Tj9281THycNurJ3gIPgeVnwQXYejuTv)j7gaSlt1cLcSsfnkJLxS(VKGJj8Fr89PnF1FYUba7smLcywoJTDoXYnFBKiZdNtB(62amqm1GPHSy9GqiwwSm0apJL8HXAaWy5wGzzJ1k2NmwG557tDRtgglWsfhXyrss0BSBdXe2RufVnKGAD3lHx7A3g))A5tRyxGCb6HlqUnyLkAuE5YTXdhdHtEBiMWjv0OqnpcpS7)xlFAfRNEBiIXsHsSNOjCtO73sJI0BdrmwEXEIMWnHUFlnkGOAoflwh4el)hzSuOel54cW6qunNIfRdXY)rEBsVnFDBoFB(6AxGY)fi3gSsfnkVC524HJHWjVn()1YNwjalaVUvxrpUambevZPyX6qSCJy5fR)FT8PvczcD2nywmYhQM28LaIQ5uSoY1t0BOmwhILBelVyTuJLjalaVUvxrpUambwPIgLXYlw6I1)Vw(0krE((u36KHciQMtX6ixprVHYyDiwUrS8ILycNurJcsqTU7LWyPqjwGhlXeoPIgfKGAD3lHXsFSuOelWJ1snwMaSa86wDf94cWeyLkAuglfkXQ8mwS8ILCCbyDiQMtXI1HyD0X3M0BZx3MeQ2Q)KDda2LykV2fOo6cKBdwPIgLxUCBsVnFDBypOUdX8eH3gpCmeo5TXsOlAcBuXU99tV1D0XX6qShhlVyTe6IMWgvSBFxoySTh7XXYl20BdrSJfQoilwh4eRJUn(wEn2Te6Ig7c0dx7cuc8cKBdwPIgLxUCBsVnFDBalaVUvxrpUaSBJezE4CAZx3gcGFTKflx0JlalwYhgl4zS2h7XXYq)xswS2hlRv5JL2yaIfyE((u36KH8fBB0aGqAdd5lwqgglTXaelvKqNXceywmYhQM28L424HJHWjVnet4KkAuWS(PoRAk3y5flDX6)xlFALipFFQBDYqbevZPyDKRNO3qzSoe7XXsHsS()1YNwjYZ3N6wNmuar1Ckwh56j6nugB7XEG7XsFS8ILUy9)RLpTsitOZUbZIr(q10MVequnNIfRdX66LXsHsSkGKKczcD2nywmYhQM28La8mw6V2fOhFbYTbRurJYlxUnE4yiCYBdXeoPIgfPuY6qunNkwkuIv5zSy5fl54cW6qunNIfRdXY)HBt6T5RBdyb41T6k6XfGDTlqpYlqUnyLkAuE5YTj9281THbQQ(v3nHUFlnEB8WXq4K3giyn((5tdHcjso(XI1HypqGXYlw))A5tReGfGx3QROhxaMaIQ5uSyDi2dokwEX6)xlFALqMqNDdMfJ8HQPnFjGOAoflwhI9GJUn6PWUxEBC0rYDUFTlq5gxGCBWkv0O8YLBJhogcN82qmHtQOrbZ6N6SQPCJLxS0fR8nbyb41T6k6XfG1LVjGOAoflwkuIf4XAPgltawaEDRUIECbycSsfnkJL(Bt6T5RBJmHo7gmlg5dvtB(6AxGYnDbYTbRurJYlxUnE4yiCYBdXeoPIgfPuY6qunNkwkuIv5zSy5fl54cW6qunNIfRdXY)HBt6T5RBJmHo7gmlg5dvtB(6AxGYnFbYTbRurJYlxUnE4yiCYBt6THi2XcvhKflNypelVyLOcijPGezgcNYTt7blPGzP3zSTZjwcmwEXsxSapwIjCsfnkib16UxcJLcLyjMWjv0OGeuR7EjmwEXsxS()1YNwjalaVUvxrpUambevZPyX2ESh4ESuOeR)FT8PvczcD2nywmYhQM28LaIQ5uSoY1t0BOm22J9a3JLxSapwl1yzcWcWRB1v0JlatGvQOrzS0hl93M0BZx3M889PU1jdV2fOh4(fi3gSsfnkVC52KEB(62KNVp1Toz4TXdhdHtEBsVneXowO6GSyBNtS8hlVyLOcijPGezgcNYTt7blPGzP3zSThRJILxSapwjMgGEwYUe9zlHnENt5EB8T8ASBj0fn2fOhU2fOhoCbYTbRurJYlxUnE4yiCYBdeSgF)8PHqHejh)yX6qShiWy5fR)FT8PvcWcWRB1v0Jlatar1CkwSoe7bhflVy9)RLpTsitOZUbZIr(q10MVequnNI1rUEIEdLX6qShC0Tj9281THbQQ(v3nHUFlnETlqpW)fi3gSsfnkVC524HJHWjVnet4KkAuWS(PoRAk3y5fRevajjfKiZq4uUDApyjfml9oJ1Hy5pwEXsxSNOjYZ33Db8GAr6THiglfkXQasskKj0z3GzXiFOAAZxcWZy5fR)FT8PvI889PU1jdfqunNIfB7XEG7XsHsS()1YNwjYZ3N6wNmuar1CkwSTh7bUhlVy9)RLpTsitOZUbZIr(q10MVequnNIfB7XEG7Xs)Tj9281TbSa86w9KXsqTDTlqp4OlqUnyLkAuE5YTj9281TbSa86w9KXsqTDB8WXq4K3M0BdrSJfQoil225el)XYlwjQasskirMHWPC70EWskyw6DgRdXYFS8ILUyprtKNVV7c4b1I0BdrmwkuIvbKKuitOZUbZIr(q10MVeGNXsHsS()1YNwjKyAa6zj7s0NTequnNIfRdX66LXs)TX3YRXULqx0yxGE4AxGEGaVa52GvQOr5Ll3gpCmeo5Tb4XEIMWfWdQfP3gI4Tj9281TbMdd7smLx7A3gxSq4475JxGCb6HlqUnyLkAuE5YTHH(BJ)FT8Pvc2dQ7qmprOaIQ5uSBt6T5RBdTCSBJhogcN82yPgltWEqDhI5jcfyLkAuglVyTe6IMWgvSBF)0BDhDCSoe7XXYlwYXfG1HOAofl22J94y5fR)FT8Pvc2dQ7qmprOaIQ5uSyDiw6I11lJTnel3fCJJJL(y5fB6THi2XcvhKfRdCI1rx7cu(Va52GvQOr5Ll3gpCmeo5THUybESet4KkAuC(VEk3oeSgF)8PHWyPqjwfqssbdukXQl)xvaX0BXsFS8ILUyvajjfYe6SBWSyKpunT5lb4zS8Ifcwi5dDrHetPEqM19)OfyLkAuglVytVneXowO6GSyDGtSokwkuIn92qe7yHQdYILtS8hl93M0BZx3gjMgGU)h91Ua1rxGCBWkv0O8YLBJhogcN82OasskyGsjwD5)QciMElwkuIf4XsmHtQOrX5)6PC7qWA89ZNgcVnP3MVUn45ir1XFTlqjWlqUnyLkAuE5YTrImpCoT5RBtBMmwlHUOfRVLxpLBSdlw5Wsfnk5lwgTX8aIvj9oJ1(ynaySSPC1i32sOlAX6IfchFS6HzXofZWukUnP3MVUnqWQNEB(QRhMDBygC82fOhUnE4yiCYBJVLxJDSq1bzXYj2d3g9WSELQ4TXfleo(RDb6XxGCBWkv0O8YLBt6T5RBdThSKD2jwseEB8WXq4K3g6I1)Vw(0krE((u36KHciQMtXIT9ypowEXkrfqssbjYmeoLBN2dwsb4zSuOeRevajjfKiZq4uUDApyjfml9oJT9yDuS0hlVyPlwYXfG1HOAoflwhI1)Vw(0kHetdqplzxI(SLaIQ5uSyPASh4ESuOel54cW6qunNIfB7X6)xlFALipFFQBDYqbevZPyXs)TX3YRXULqx0yxGE4AxGEKxGCBWkv0O8YLBt6T5RBdjYmeoLBNzWXjEB8WXq4K3gjQasskirMHWPC70EWskyw6DgRdCI1rXYlw))A5tRe557tDRtgkGOAoflwhI94yPqjwjQasskirMHWPC70EWskyw6DgRdXE424B51y3sOlASlqpCTlq5gxGCBWkv0O8YLBt6T5RBdjYmeoLBNzWXjEB8WXq4K3g))A5tRe557tDRtgkGOAofl22J94y5fRevajjfKiZq4uUDApyjfml9oJ1HypCB8T8ASBj0fn2fOhU2fOCtxGCBWkv0O8YLBt6T5RBdjYmeoLBNzWXjEBKiZdNtB(62aeadl2HflssIEBiI6wXsoAncJLgGXdiw2OYILkagBITqqdMA(Ivb0ILb4b1YypHirSSyZyzESs48XsdacXynaySPu(vSaswS1BaMYnw7JfI(xvflP424HJHWjVnP3gIyx(MGezgcNYTt7blzSTZjwFlVg7yHQdYILxSsubKKuqImdHt52P9GLuWS07mwhILaV21UnsKmb12fixGE4cKBt6T5RBJ6uYojercy4TbRurJYlxU2fO8FbYTbRurJYlxUn)5THH2Tj9281THycNurJ3gIPgeVn0flYTaNZtukMI5HGwQOXo3cmlduTlrIJhJLxS()1YNwjMI5HGwQOXo3cmlduTlrIJhfqmLTIL(BJezE4CAZx3gGrisellw2j6hYbLXAWPCIglwfCk3ybzOmwAJbi2e0E10gFS6Pq2THyc7vQI3g2j6hYbLDdoLt0U2fOo6cKBdwPIgLxUCB(ZBddTBt6T5RBdXeoPIgVnetniEB8)RLpTsWavv)Q7Mq3VLgfqunNIfRdXECS8I1snwMGbQQ(v3nHUFlnkWkv0OmwEXsxSwQXYeGfGx3QROhxaMaRurJYy5fR)FT8PvcWcWRB1v0Jlatar1CkwSoe7bhflVy9)RLpTsitOZUbZIr(q10MVequnNI1rUEIEdLX6qShCuSuOelWJ1snwMaSa86wDf94cWeyLkAugl93gIjSxPkEBo)xpLBhcwJVF(0q41UaLaVa52GvQOr5Ll3M)82Wq72KEB(62qmHtQOXBdXudI3gl1yzc2dQ7qmprOaRurJYy5fleSWyDiw(JLxSwcDrtyJk2TVF6TUJoowhI94y5fl54cW6qunNIfB7XE8THyc7vQI3MZ)1t52HGfYU2fOhFbYTbRurJYlxUn)5THH2Tj9281THycNurJ3gIPgeVnP3gIyhluDqwSCI9qS8ILUybESWCKDKiwMiLsMa56WmwSuOelmhzhjILjsPKjMk22J9WXXs)THyc7vQI3gM1p1zvt5ETlqpYlqUnyLkAuE5YT5pVnm0UnP3MVUnet4KkA82qm1G4Tj92qe7yHQdYITDoXYFS8ILUybESWCKDKiwMiLsMa56WmwSuOelmhzhjILjsPKjqUomJflVyPlwyoYoseltKsjtar1CkwSTh7XXsHsSKJlaRdr1CkwSTh7bUhl9Xs)THyc7vQI3MukzDiQMtDTlq5gxGCBWkv0O8YLBZFEByODBsVnFDBiMWjv04THyQbXBdDXAPgltWavv)Q7Mq3VLgfyLkAuglVybESNOjCtO73sJI0BdrmwEX6)xlFALGbQQ(v3nHUFlnkGOAoflwkuIf4XAPgltWavv)Q7Mq3VLgfyLkAugl9XYlw6IvbKKuawaEDREYyjO2eGNXsHsSwQXYejuTv)j7gaSlt1cLcSsfnkJLxSNOjYZ33Db8GAr6THiglfkXQasskKj0z3GzXiFOAAZxcWZyPqj20BdrSJfQoil225el)XYlwjMgGEwYUe9zlHnENt5gl93gIjSxPkEBuZJWd7()1YNwX6P3gI41UaLB6cKBdwPIgLxUCB(ZBddTBt6T5RBdXeoPIgVnetniEB8prSYYe14cW6KjglVyLyAa6zj7s0NTe24DoLBS8IvbKKuiX0aW6squWS07mwhILaJLcLyvajjfQje(0qz3fvz2xyhlaz5rvSmb4zSuOeRcijPWaahTUZq0jcfGNXsHsSkGKKcsiweWgu2v)IzWNnwlb4zSuOeRcijPqJPSR0QJCnvp1Oa8mwkuIvbKKu4bKpRRKfkapJLcLy9)RLpTsawaEDREYyjO2equnNIfRdXE8THyc7vQI3gjO6zN2dws21UaLB(cKBdwPIgLxUCBsVnFDBEqtbIPZBJezE4CAZx3M20ZPSCQPCJTn1ab1yzXcmQtxqm2HfBg7jCE4yTUnE4yiCYBJ8nbXbcQXY6N60fefqKeImaPIgJLxSapwl1yzcWcWRB1v0JlatGvQOrzS8If4XcZr2rIyzIukzcKRdZyx7c0dC)cKBdwPIgLxUCBsVnFDBEqtbIPZBJhogcN82iFtqCGGASS(PoDbrbejHidqQOXy5fB6THi2XcvhKfB7CIL)y5flDXc8yTuJLjalaVUvxrpUambwPIgLXsHsS()1YNwjalaVUvxrpUambevZPyXYlwfqssbyb41T6k6XfG1vajjfYNwfl93gFlVg7wcDrJDb6HRDb6HdxGCBWkv0O8YLBt6T5RBZdAkqmDEB0tHDV82CK3gpCmeo5Tj92qe7Y3eehiOglRFQtxqmwhIn92qe7yHQdYILxSP3gIyhluDqwSTZjw(JLxS0flWJ1snwMaSa86wDf94cWeyLkAuglfkX6)xlFALaSa86wDf94cWequnNIflVyvajjfGfGx3QROhxawxbKKuiFAvS0FBKiZdNtB(620MjJ1aGqm2eIXIfQoilw1HXMYn22uaJ8fBEEQBf7yXsNcOfB9XQ(qmwdqwX(LhJ9eHXEKXYq)xsg9IRDb6b(Va52GvQOr5Ll3gpCmeo5Tbcwi5dDrbd8eHmdMtjWkv0OmwEXsxSY3eKWNzDsKicfqKeImaPIgJLcLyLVju0)l7N60fefqKeImaPIgJL(Bt6T5RBZdAkqmDETlqp4OlqUnyLkAuE5YTj9281TH2dwYo7eljcVnsK5HZPnFDBoIijezaqwSubMgawSubisnlwfqsYypcGmlwfK8HySsmnaSyLGySyjz3gpCmeo5TX)eXkltuJlaRtMyS8IvIPbONLSlrF2sKEBiIDiQMtXI1HyPlwxVm22qShehhl9XYlwjMgGEwYUe9zlHnENt5ETlqpqGxGCBWkv0O8YLBdd93g))A5tReShu3HyEIqbevZPy3M0BZx3gA5y3gpCmeo5TXsnwMG9G6oeZtekWkv0OmwEXAj0fnHnQy3((P36o64yDi2JJLxSwcDrtyJk2TVlhm22J94y5fR)FT8Pvc2dQ7qmprOaIQ5uSyDiw6I11lJTnel3fCJJJL(y5fB6THi2XcvhKflNypCTlqpC8fi3gSsfnkVC52irMhoN281THakhlwYhglvGPbGAwSubisqQajhng7qglqhxawSeWtmw7J1fTyzgelxdqSkGKKXQKENXMS882Wq)TX)Vw(0kHetdaRlbrbevZPy3M0BZx3gA5y3gpCmeo5TX)eXkltuJlaRtMyS8I1)Vw(0kHetdaRlbrbevZPyX6qSUEzS8In92qe7yHQdYILtShU2fOhoYlqUnyLkAuE5YTHH(BJ)FT8PvcjsoAuar1Ck2Tj9281THwo2TXdhdHtEB8prSYYe14cW6KjglVy9)RLpTsirYrJciQMtXI1HyD9Yy5fB6THi2XcvhKflNypCTlqpWnUa52GvQOr5Ll3gjY8W50MVUnatVnFflvomJfBwYyBJNyHqwS01gpXcHmc2GClqS8ilwWIbEE(qdLXovSPu(LG(Bt6T5RBJp16E6T5RUEy2TrpmRxPkEBm4uorJDTlqpWnDbYTbRurJYlxUnP3MVUn(uR7P3MV66Hz3g9WSELQ4TX)eXklJDTlqpWnFbYTbRurJYlxUnP3MVUn(uR7P3MV66Hz3g9WSELQ4TbM(j1SRDbk)C)cKBdwPIgLxUCBsVnFDB8Pw3tVnF11dZUn6Hz9kvXBJ)FT8PvSRDbk)hUa52GvQOr5Ll3gpCmeo5THycNurJIukzDiQMtflVyPlw))A5tResmna9SKDj6ZwciQMtXI1HypW9y5flWJ1snwMqIKJgfyLkAuglfkX6)xlFALqIKJgfqunNIfRdXEG7XYlwl1yzcjsoAuGvQOrzSuOeR)jIvwMOgxawNmXy5fR)FT8PvcjMgawxcIciQMtXI1HypW9yPpwEXc8yLyAa6zj7s0NTe24DoL7Tj9281Tbcw90BZxD9WSBJEywVsv82Kp2zObEETlq5N)lqUnyLkAuE5YTXdhdHtEBsVneXowO6GSyBNtS8hlVyLyAa6zj7s0NTe24DoL7THzWXBxGE42KEB(62abRE6T5RUEy2TrpmRxPkEBYh7kGqMDTlq53rxGCBWkv0O8YLBJhogcN82KEBiIDSq1bzX2oNy5pwEXsxSapwjMgGEwYUe9zlHnENt5glVyPlw))A5tResmna9SKDj6ZwciQMtXIT9ypW9y5flWJ1snwMqIKJgfyLkAuglfkX6)xlFALqIKJgfqunNIfB7XEG7XYlwl1yzcjsoAuGvQOrzSuOeR)jIvwMOgxawNmXy5fR)FT8PvcjMgawxcIciQMtXIT9ypW9yPpwkuIf4XsmHtQOrrkLSoevZPIL(Bt6T5RBdeS6P3MV66Hz3g9WSELQ4TXfleo(E(41UaLFc8cKBdwPIgLxUCB8WXq4K3M0BdrSJfQoilwoXEiwkuIf4XsmHtQOrrkLSoevZPUnmdoE7c0d3M0BZx3gFQ190BZxD9WSBJEywVsv824Ifch)1U2TXGt5en2fixGE4cKBdwPIgLxUCBsVnFDBMI5HGwQOXo3cmlduTlrIJhVnE4yiCYBdDX6)xlFALaSa86wDf94cWequnNIfB7XYp3JLcLy9)RLpTsitOZUbZIr(q10MVequnNI1rUEIEdLX2ES8Z9yPpwEXsxSP3gIyhluDqwSTZjw(JLcLyprtKq1wDxapOwKEBiIXsHsSNOjYZ33Db8GAr6THiglVyPlwl1yzcWcWRB1tglb1MaRurJYyPqjwjMgGUZACbyc5Wsfn2Z3KXsFSuOe7jAc3e6(T0Oi92qeJL(yPqjwLNXILxSKJlaRdr1CkwSoel)hILcLyTe6IMWgvSBF)0BD(5ESoe7X3MkvXBZumpe0sfn25wGzzGQDjsC841UaL)lqUnyLkAuE5YTj9281TXGt5eTd3gjY8W50MVUnabagRbNYjAXsBmaXAaWybmUaqMflYSrnnuglXudI8flTrRJvbJfKHYyjhiZInlzSN5arzS0gdqSaZZ3N6wNmmw6gYyvajjJDyXE44yzO)ljl2hgRgzm6J9HXYf94cWiivaKyPBiJ1fIPHWynazf7HJJLH(VKm6VnE4yiCYBdWJLycNurJc2j6hYbLDdoLt0ILxS0flDXAWPCIMWoiuajj7sqyAZxX6aNypCCS8I1)Vw(0krE((u36KHciQMtXIT9y5N7XsHsSgCkNOjSdcfqsYUeeM28vSTh7HJJLxS0fR)FT8PvcWcWRB1v0Jlatar1CkwSThl)CpwkuI1)Vw(0kHmHo7gmlg5dvtB(sar1Ckwh56j6nugB7XYp3JL(yPqj20BdrSJfQoil225el)XYlwfqssHmHo7gmlg5dvtB(saEgl9XYlw6If4XAWPCIMW4xaizD))A5tRILcLyn4uorty8l8)RLpTsar1CkwSuOelXeoPIgfgCkNO1pHZdhRvSCI9qS0hl9XsHsSgCkNOjSdcfqsYUeeM28vSTZjwYXfG1HOAof7AxG6OlqUnyLkAuE5YTXdhdHtEBaESet4KkAuWor)qoOSBWPCIwS8ILUyPlwdoLt0eg)cfqsYUeeM28vSoWj2dhhlVy9)RLpTsKNVp1TozOaIQ5uSyBpw(5ESuOeRbNYjAcJFHcijzxcctB(k22J9WXXYlw6I1)Vw(0kbyb41T6k6XfGjGOAofl22JLFUhlfkX6)xlFALqMqNDdMfJ8HQPnFjGOAofRJC9e9gkJT9y5N7XsFSuOeB6THi2XcvhKfB7CIL)y5fRcijPqMqNDdMfJ8HQPnFjapJL(y5flDXc8yn4uortyheasw3)Vw(0QyPqjwdoLt0e2bH)FT8PvciQMtXILcLyjMWjv0OWGt5eT(jCE4yTILtS8hl9XsFSuOeRbNYjAcJFHcijzxcctB(k225el54cW6qunNIDBsVnFDBm4uorJ)RDbkbEbYTbRurJYlxUnP3MVUngCkNOD42irMhoN281TPntg7x6wX(fg7xXcYWyn4uorl2t4tCKil2mwfqss(IfKHXAaWyFdacJ9Ry9)RLpTseBBeg7qgBHJbaHXAWPCIwSNWN4irwSzSkGKK8flidJv5naX(vS()1YNwjUnE4yiCYBdWJ1Gt5enHDqaizDqg2vajjJLxS0fRbNYjAcJFH)FT8PvciQMtXILcLybESgCkNOjm(faswhKHDfqsYyP)AxGE8fi3gSsfnkVC524HJHWjVnapwdoLt0eg)cajRdYWUcijzS8ILUyn4uortyhe()1YNwjGOAoflwkuIf4XAWPCIMWoiaKSoid7kGKKXs)Tj9281TXGt5en(V21U2THiczZxxGYp35)a35gCNB62qlH1uUSBdbeW8ic02mqBtABSXceaySJ65dTyjFySuNp2zObEsDSqKBboqugl7vXytq7vtdLX6bKLlYebHu5uyShABSa7xerOHYyP2snwMWXuhR9XsTLASmHJfyLkAusDS0DGR0lccPYPWy5VTXcSFreHgkJLAiyHKp0ffoM6yTpwQHGfs(qxu4ybwPIgLuhlDh4k9IGqQCkm2JSTXcSFreHgkJLAl1yzchtDS2hl1wQXYeowGvQOrj1Xsh)CLErqyqibeW8ic02mqBtABSXceaySJ65dTyjFySuNp2vaHmJ6yHi3cCGOmw2RIXMG2RMgkJ1dilxKjccPYPWyDuBJfy)Iicnugl1wQXYeoM6yTpwQTuJLjCSaRurJsQJLohXv6fbHu5uySeyBJfy)Iicnugl1qWcjFOlkCm1XAFSudblK8HUOWXcSsfnkPow6oWv6fbHbHeqaZJiqBZaTnPTXglqaGXoQNp0IL8HXsTbNYjAmQJfIClWbIYyzVkgBcAVAAOmwpGSCrMiiKkNcJ9qBJfy)Iicnugl1wQXYeoM6yTpwQTuJLjCSaRurJsQJLUdCLErqivofgl)TnwG9lIi0qzSuBWPCIM4GWXuhR9XsTbNYjAc7GWXuhlDoIR0lccPYPWy5VTXcSFreHgkJLAdoLt0e8lCm1XAFSuBWPCIMW4x4yQJLo(5k9IGqQCkmwh12yb2ViIqdLXsTbNYjAIdchtDS2hl1gCkNOjSdchtDS0XpxPxeesLtHX6O2glW(freAOmwQn4uortWVWXuhR9XsTbNYjAcJFHJPow6CexPxeesLtHXsGTnwG9lIi0qzSuBWPCIM4GWXuhR9XsTbNYjAc7GWXuhlDh4k9IGqQCkmwcSTXcSFreHgkJLAdoLt0e8lCm1XAFSuBWPCIMW4x4yQJLo(5k9IGqQCkm2JBBSa7xerOHYyP2Gt5enXbHJPow7JLAdoLt0e2bHJPow64NR0lccPYPWypUTXcSFreHgkJLAdoLt0e8lCm1XAFSuBWPCIMW4x4yQJLUdCLErqyqibeW8ic02mqBtABSXceaySJ65dTyjFySu7Ifchp1XcrUf4arzSSxfJnbTxnnugRhqwUiteesLtHXYFBJfy)Iicnugl1qWcjFOlkCm1XAFSudblK8HUOWXcSsfnkPow6oWv6fbHbHeqaZJiqBZaTnPTXglqaGXoQNp0IL8HXsT)jIvwgJ6yHi3cCGOmw2RIXMG2RMgkJ1dilxKjccPYPWyp02yb2ViIqdLXsTLASmHJPow7JLAl1yzchlWkv0OK6yP7axPxeesLtHX6O2glW(freAOmwQTuJLjCm1XAFSuBPglt4ybwPIgLuhlDh4k9IGqQCkmwh12yb2ViIqdLXsn7b1ktjfoM6yTpwQzpOwzkPWXcSsfnkPow6oWv6fbHu5uySeyBJfy)Iicnugl1wQXYeoM6yTpwQTuJLjCSaRurJsQJLUdCLErqivofglb22yb2ViIqdLXsn7b1ktjfoM6yTpwQzpOwzkPWXcSsfnkPow6oWv6fbHu5uySh32yb2ViIqdLXsn7b1ktjfoM6yTpwQzpOwzkPWXcSsfnkPow6oWv6fbHu5uySCJ2glW(freAOmwQTuJLjCm1XAFSuBPglt4ybwPIgLuhlDh4k9IGqQCkmwU52glW(freAOmwQzpOwzkPWXuhR9Xsn7b1ktjfowGvQOrj1XMwSadTrQmw6oWv6fbHbHeqaZJiqBZaTnPTXglqaGXoQNp0IL8HXs9je9VQsAuhle5wGdeLXYEvm2e0E10qzSEaz5Imrqivofglb22yb2ViIqdLXsTLASmHJPow7JLAl1yzchlWkv0OK6ytlwGH2ivglDh4k9IGqQCkm2JBBSa7xerOHYyBgvGnwwRYsUglbibyS2hlvcMXQ(sqnil2)eHP9WyPJaK(yP7axPxeesLtHXECBJfy)Iicnugl1gCkNOjoiCm1XAFSuBWPCIMWoiCm1Xsh)CLErqivofg7r22yb2ViIqdLX2mQaBSSwLLCnwcqcWyTpwQemJv9LGAqwS)jct7HXshbi9Xs3bUsViiKkNcJ9iBBSa7xerOHYyP2Gt5enb)chtDS2hl1gCkNOjm(foM6yPJFUsViiKkNcJLB02yb2ViIqdLX2mQaBSSwLLCnwcWyTpwQemJvoeh28vS)jct7HXshbPpw64NR0lccPYPWy5gTnwG9lIi0qzSuBWPCIM4GWXuhR9XsTbNYjAc7GWXuhlDeixPxeesLtHXYnABSa7xerOHYyP2Gt5enb)chtDS2hl1gCkNOjm(foM6yP7yUsViiKkNcJLBQTXcSFreHgkJLAl1yzchtDS2hl1wQXYeowGvQOrj1Xs3bUsViimiKacyEebABgOTjTn2ybcam2r98HwSKpmwQ9)RLpTIrDSqKBboqugl7vXytq7vtdLX6bKLlYebHu5uyS832yb2ViIqdLXsTLASmHJPow7JLAl1yzchlWkv0OK6yPJFUsViiKkNcJLB02yb2ViIqdLXsTLASmHJPow7JLAl1yzchlWkv0OK6yP7axPxeesLtHXYn32yb2ViIqdLXsTLASmHJPow7JLAl1yzchlWkv0OK6yP7axPxeegesabmpIaTnd02K2gBSabag7OE(qlwYhgl1UyHWX3ZhPowiYTahikJL9QySjO9QPHYy9aYYfzIGqQCkm2dTnwG9lIi0qzSuBPglt4yQJ1(yP2snwMWXcSsfnkPow6oWv6fbHu5uyS832yb2ViIqdLXsneSqYh6IchtDS2hl1qWcjFOlkCSaRurJsQJLUdCLErqyqibeW8ic02mqBtABSXceaySJ65dTyjFySulrYeuBuhle5wGdeLXYEvm2e0E10qzSEaz5ImrqivofgRJABSa7xerOHYyP2snwMWXuhR9XsTLASmHJfyLkAusDS05iUsViiKkNcJLaBBSa7xerOHYyP2snwMWXuhR9XsTLASmHJfyLkAusDS0DGR0lccPYPWy5gTnwG9lIi0qzSuBPglt4yQJ1(yP2snwMWXcSsfnkPow6CexPxeesLtHXYn32yb2ViIqdLXsTLASmHJPow7JLAl1yzchlWkv0OK6yP7axPxeesLtHXEG7TnwG9lIi0qzSuBPglt4yQJ1(yP2snwMWXcSsfnkPow6oWv6fbHu5uySho02yb2ViIqdLXsTLASmHJPow7JLAl1yzchlWkv0OK6yP7axPxeesLtHXEG)2glW(freAOmwQHGfs(qxu4yQJ1(yPgcwi5dDrHJfyLkAusDS0DGR0lccPYPWypqGTnwG9lIi0qzSuBPglt4yQJ1(yP2snwMWXcSsfnkPow6oWv6fbHu5uyS8FOTXcSFreHgkJLAl1yzchtDS2hl1wQXYeowGvQOrj1Xsh)CLErqivofgl)oQTXcSFreHgkJLAl1yzchtDS2hl1wQXYeowGvQOrj1Xsh)CLErqyqyBw98HgkJ9a3Jn928vS6Hzmrq4Tjbnap820mQG60MVawysA3Mt4toA82C0JglvGPbiwcGQXfGflbGcWRBfeE0JglWe0fKzXEGVy5N78Fiimi8OhnwGfqwUiRTbHh9OXYTJfykpcGmtflJfR9XsffvqqQajhnsqQatdalwQaeJ1(y)s3kw)dwwSwcDrJflnaFSjeJf56j6nugR9XQhIyS6VCJfRh0fqS2hRAAgcJLU8XodnWZyp6b6fbHh9OXYTJLkgwQOrzSnPhoKJFsDSaJP3Ivb9jidJvIPmwxapOMfRA6eJL8HXYszSubbqmrq4rpASC7yjaWMYnwcOhSKX2CILeHXMkJESbzXQ(qmwsnY1rr3kw6slwcKQXYS07Kf7umdtzSpzShtv6BtlwQaySj2cbnyQJnlzSQzRypHirSSyzVkgB9CBi6JLngyAZxmrq4rpASC7yjaWMYnwc4iZq4uUX2yWXjg7uXcmBJadXoKX26bJfqseJTEdWuUXIAggR9Xk)yZsglTVO2I9jIqFEglThSKSyhwSubWytSfcAWulccp6rJLBhlWcilxugRAwTILAYXfG1HOAofJ6y9FjhB(k1SyTp288u3k2PIv5zSyjhxagl2V0TILonYyXcSurS0sMHX(vSgmzaOxeeE0Jgl3owGPuIYyZ6naim22iOPaX0zSyzWwXAFSm0If8mwMb)YfHXcmCosuD8mrq4rpASC7ypIOo5ASnajwImrSaZ2iWqS63D8XYMYJXowSqupil2VI1)fzQaQtdLXcZr2rIyzmrq4rpASC7ybsBKkAJTn2yjGNE7HX2yqSCnaXEcFpl2PSpwdoLt0Iv)UJxeegeMEB(IjoHO)vvsJQCi45BZxbHP3MVyIti6FvL0OkhccZHHDjMYGW0BZxmXje9VQsAuLdbj1idGhMKwqy6T5lM4eI(xvjnQYHGjuTv)j7gaSlXuY3je9VQsADBurooIVHKdWTuJLjyGQQF1DtO73sJbHhnwGbIPgmnKfBgRbNYjASy9)RLpTIVyLdXrIYyvAflbESiwGayyXslzX6b8mSInzXcwaEDRyP9qNSy)kwc84yzO)lzSkGqMfRVLxJm(Ivb0IfqYI1(pw1SAfRxcJfjjrVXI1(yDhIySzS()1YNwj4QqcctB(kw5qCypm2PygMsrSTzYyhJAwSetniglGKfB9Xcr1CkjcJfIgiSI9aFXIAgglenqyfl3fhlcctVnFXeNq0)QkPrvoeKycNurJ8vPkYXGt5eT(HoRv557p5WqBi5JyQbroh4JyQbXoQzihUloMp)xYXMV4yWPCIM4GaqY6GmSRassYJodoLt0ehe()1YNwjKGW0MViajajWJ5WD6dctVnFXeNq0)QkPrvoeKycNurJ8vPkYXGt5eTo)DwRYZ3FYHH2qYhXudICoWhXudIDuZqoCxCmF(VKJnFXXGt5enb)cajRdYWUcijjp6m4uortWVW)Vw(0kHeeM28fbibibEmhUtFq4rJfyGzJAAil2mwdoLt0yXsm1GySkTI1)QNjCk3ynayS()1YNwf7tgRbaJ1Gt5en(IvoehjkJvPvSgamwjimT5RyFYynaySkGKKXowSNWN4irMiwcGtwSzSmdILRbiw1xoKdcJ1(yDhIySzSagxaim2t48WXAfR9XYmiwUgGyn4uorJXxSjlwAOwhBYInJv9Ld5GWyjFySdzSzSgCkNOflTrRJ9HXsB06yR3IL1Q8XsBmaX6)xlFAfteeMEB(IjoHO)vvsJQCiiXeoPIg5RsvKJbNYjA9t48WXAX3FYHH2qYhXudIC4NpIPge7OMHCoWN)l5yZxCaUbNYjAIdcajRdYWUcijjpdoLt0e8laKSoid7kGKKuOyWPCIMGFbGK1bzyxbKKKhD0zWPCIMGFH)FT8PvcjimT5lcqdoLt0e8luajj7sqyAZx03gO7G4yQAWPCIMGFbGK1vajjPVnqhXeoPIgfgCkNO15VZAvE6PVD6OZGt5enXbH)FT8PvcjimT5lcqdoLt0ehekGKKDjimT5l6Bd0DqCmvn4uortCqaizDfqss6Bd0rmHtQOrHbNYjA9dDwRYtp9bHhnwGbIPgmnKfRhecXYILHg4zSKpmwdagl3cmlBSwX(KXcmpFFQBDYWybwQ4iglssIEJfeMEB(IjoHO)vvsJQCiiXeoPIg5RsvKdjOw39siFetniYXsnwMiHQT6pz3aGDzQwOKN)lj4yc)xeFFAZx9NSBaWUetPaMLZ25WnhegeE0JglWaxrpOHYyrIiSvS2OIXAaWytV9WyhwSjXC0PIgfbHP3MVyCuNs2jHisaddcpASaJqKiwwSSt0pKdkJ1Gt5enwSk4uUXcYqzS0gdqSjO9QPn(y1tHSGW0BZxmQYHGet4KkAKVkvroSt0pKdk7gCkNOXhXudICOd5wGZ5jkftX8qqlv0yNBbMLbQ2LiXXJ88)RLpTsmfZdbTurJDUfywgOAxIehpkGykBrFq4rpASTPs4KkAKfeMEB(IrvoeKycNurJ8vPkY58F9uUDiyn((5tdH8rm1Gih))A5tRemqv1V6Uj09BPrbevZPyoCmpl1yzcgOQ6xD3e6(T0ip6SuJLjalaVUvxrpUamE()1YNwjalaVUvxrpUambevZPyoCWr88)RLpTsitOZUbZIr(q10MVequnNI1rUEIEdLoCWruOaCl1yzcWcWRB1v0JlaJ(GW0BZxmQYHGet4KkAKVkvroN)RNYTdblKXhXudICSuJLjypOUdX8eH8GGf6a)8Se6IMWgvSBF)0BDhDSdhZJCCbyDiQMtXA)4GW0BZxmQYHGet4KkAKVkvromRFQZQMYLpIPge5KEBiIDSq1bzCoWJoGdZr2rIyzIukzcKRdZyuOaZr2rIyzIukzIPA)WX0heMEB(IrvoeKycNurJ8vPkYjLswhIQ5u8rm1GiN0BdrSJfQoiRDo8ZJoGdZr2rIyzIukzcKRdZyuOaZr2rIyzIukzcKRdZy8OdMJSJeXYePuYequnNI1(XuOqoUaSoevZPyTFG70tFqy6T5lgv5qqIjCsfnYxLQih18i8WU)FT8PvSE6THiYhXudICOZsnwMGbQQ(v3nHUFlnYd4NOjCtO73sJI0BdrKN)FT8PvcgOQ6xD3e6(T0OaIQ5umkuaULASmbduv9RUBcD)wAKEE0PasskalaVUvpzSeuBcWtkuSuJLjsOAR(t2nayxMQfk5DIMipFF3fWdQfP3gIifkkGKKczcD2nywmYhQM28La8KcL0BdrSJfQoiRDo8ZtIPbONLSlrF2syJ35uU0heMEB(IrvoeKycNurJ8vPkYrcQE2P9GLKXhXudIC8prSYYe14cW6KjYtIPbONLSlrF2syJ35uU8uajjfsmnaSUeefml9oDGaPqrbKKuOMq4tdLDxuLzFHDSaKLhvXYeGNuOOasskmaWrR7meDIqb4jfkkGKKcsiweWgu2v)IzWNnwlb4jfkkGKKcnMYUsRoY1u9uJcWtkuuajjfEa5Z6kzHcWtku8)RLpTsawaEDREYyjO2equnNI5WXbHhn220ZPSCQPCJTn1ab1yzXcmQtxqm2HfBg7jCE4yTcctVnFXOkhc(GMcetN8nKCKVjioqqnww)uNUGOaIKqKbiv0ipGBPgltawaEDRUIECby8aomhzhjILjsPKjqUomJfeMEB(Irvoe8bnfiMo5Z3YRXULqx0yCoW3qYr(MG4ab1yz9tD6cIciscrgGurJ8sVneXowO6GS25Wpp6aULASmbyb41T6k6XfGrHI)FT8PvcWcWRB1v0Jlatar1Ckgpfqssbyb41T6k6XfG1vajjfYNwrFq4rJTntgRbaHySjeJfluDqwSQdJnLBSTPag5l288u3k2XILofql26Jv9HySgGSI9lpg7jcJ9iJLH(VKm6fbHP3MVyuLdbFqtbIPt(0tHDVKZrY3qYj92qe7Y3eehiOglRFQtxq0H0BdrSJfQoiJx6THi2XcvhK1oh(5rhWTuJLjalaVUvxrpUamku8)RLpTsawaEDRUIECbyciQMtX4PasskalaVUvxrpUaSUcijPq(0k6dctVnFXOkhc(GMcetN8nKCGGfs(qxuWapriZG5u8Ot(MGe(mRtIerOaIKqKbiv0ifkY3ek6)L9tD6cIciscrgGurJ0heE0ypIijezaqwSubMgawSubisnlwfqsYypcGmlwfK8HySsmnaSyLGySyjzbHP3MVyuLdbP9GLSZoXsIq(gso(NiwzzIACbyDYe5jX0a0Zs2LOpBjsVneXoevZPyoqNRx2goioMEEsmna9SKDj6ZwcB8oNYnim928fJQCiiTCm(yONJ)FT8Pvc2dQ7qmprOaIQ5um(gsowQXYeShu3HyEIqEwcDrtyJk2TVF6TUJo2HJ5zj0fnHnQy3(UCW2pMN)FT8Pvc2dQ7qmprOaIQ5umhOZ1lBdCxWnoMEEP3gIyhluDqgNdbHhnwcOCSyjFySubMgaQzXsfGibPcKC0ySdzSaDCbyXsapXyTpwx0ILzqSCnaXQassgRs6DgBYYZGW0BZxmQYHG0YX4JHEo()1YNwjKyAayDjikGOAofJVHKJ)jIvwMOgxawNmrE()1YNwjKyAayDjikGOAofZbxVKx6THi2XcvhKX5qqy6T5lgv5qqA5y8Xqph))A5tResKC0OaIQ5um(gso(NiwzzIACbyDYe55)xlFALqIKJgfqunNI5GRxYl92qe7yHQdY4Cii8OXcm928vSu5WmwSzjJTnEIfczXsxB8eleYiydYTaXYJSyblg455dnug7uXMs5xc6dctVnFXOkhc6tTUNEB(QRhMXxLQihdoLt0ybHP3MVyuLdb9Pw3tVnF11dZ4RsvKJ)jIvwglim928fJQCiOp16E6T5RUEygFvQICGPFsnli8Ohn20BZxmQYHGmKBbILh5Bi5KEBiIDSq1bzCoWd4smnaDN14cWeYHLkASNVj5zPgltWavv)Q7Mq3VLg5RsvKJBcD7)jwiSTpOPaX0zBjrMHWPC7mdooX2sImdHt52zgCCITLbQQ(v3nHUFln22eQ2Q)KDda2LykBRetdq3)JMVHKJcijPGbkLy1L)RkapBRetdq3)JUTsmnaD)p62Y8pi0f7mdoor(gsosubKKuqImdHt52P9GLuWS07SDcSTm)dcDXoZGJtKVHKJevajjfKiZq4uUDApyjfml9oBNaBljYmeoLBNzWXjgeE0JgB6T5lgv5qqgYTaXYJ8nKCsVneXowO6Gmoh4bCjMgGUZACbyc5Wsfn2Z3K8aULASmbduv9RUBcD)wAKVkvro)jwiSTKiZq4uUDMbhNyBjrMHWPC7mdooX2E(28vBblaVUvxrpUaS2ktOZUbZIr(q10MVABE((u36KHbHP3MVyuLdb9Pw3tVnF11dZ4RsvKJ)FT8PvSGW0BZxmQYHGqWQNEB(QRhMXxLQiN8XodnWt(gsoet4KkAuKsjRdr1CkE05)xlFALqIPbONLSlrF2sar1CkMdh4opGBPgltirYrJuO4)xlFALqIKJgfqunNI5WbUZZsnwMqIKJgPqX)eXkltuJlaRtMip))A5tResmnaSUeefqunNI5WbUtppGlX0a0Zs2LOpBjSX7Ck3GW0BZxmQYHGqWQNEB(QRhMXxLQiN8XUciKz8Xm44noh4Bi5KEBiIDSq1bzTZHFEsmna9SKDj6ZwcB8oNYnim928fJQCiieS6P3MV66Hz8vPkYXfleo(E(iFdjN0BdrSJfQoiRDo8ZJoGlX0a0Zs2LOpBjSX7CkxE05)xlFALqIPbONLSlrF2sar1Ckw7h4opGBPgltirYrJuO4)xlFALqIKJgfqunNI1(bUZZsnwMqIKJgPqX)eXkltuJlaRtMip))A5tResmnaSUeefqunNI1(bUtpfkaNycNurJIukzDiQMtrFqy6T5lgv5qqFQ190BZxD9Wm(Quf54IfchpFmdoEJZb(gsoP3gIyhluDqgNduOaCIjCsfnksPK1HOAovqyq4rpASaZhyiwUaczwqy6T5lMiFSRaczghVoPnLBNbiLpngFdjN0BdrSJfQoiZbohheMEB(IjYh7kGqMrvoe0RtAt52zas5tJX3qYj92qe7yHQdY4CK8KyAa6oRXfGjiP9GLeLDlHUOXANJJcctVnFXe5JDfqiZOkhcs7blzNDILeH8nKCSuJLjuaHmBk3o7HiJhDsmnaDN14cWeK0EWsIYULqx0yCsVneXowO6GmkuKyAa6oRXfGjiP9GLeLDlHUOXANJJONcfl1yzcfqiZMYTZEiY4zPglt41jTPC7maP8PX4jX0a0DwJlatqs7bljk7wcDrJ1oNdbHP3MVyI8XUciKzuLdbLyAa6(F08nKCOtbKKuWaLsS6Y)vfqm9gfkaNycNurJIZ)1t52HG147Npnespp6uajjfYe6SBWSyKpunT5lb4jpiyHKp0ffsmL6bzw3)JMx6THi2XcvhK5ahhrHs6THi2XcvhKXHF6dctVnFXe5JDfqiZOkhcINJevhpFdjhiyn((5tdHcjso(XCGUdCNQsmnaDN14cWeK0EWsIYULqx0yTbhrppjMgGUZACbycsApyjrz3sOlAmhosEaNycNurJIZ)1t52HG147NpnesHIcijPGrlHQt52vhMjapdctVnFXe5JDfqiZOkhcINJevhpFdjhiyn((5tdHcjso(XCG)J5jX0a0DwJlatqs7bljk7wcDrJ1(X8aoXeoPIgfN)RNYTdbRX3pFAimim928ftKp2vaHmJQCiiEosuD88nKCaUetdq3znUambjThSKOSBj0fngpGtmHtQOrX5)6PC7qWA89ZNgcPqHCCbyDiQMtXC4ykuG5i7irSmrkLmbY1HzmEWCKDKiwMiLsMaIQ5umhooim928ftKp2vaHmJQCiiThSKD2jwsegeMEB(IjYh7kGqMrvoeephjQoE(gsoaNycNurJIZ)1t52HG147NpnegegeE0JglW8bgITbnWZGW0BZxmr(yNHg4jNSA1LLKVHKJetdq3znUambjThSKOSBj0fnw7C8T8ASJfQoiJcfjMgGUZACbycsApyjrz3sOlAS25Cmfka3snwMqbeYSPC7ShImkuG5i7irSmrkLmbY1HzmEWCKDKiwMiLsMaIQ5umh4C4afkKJlaRdr1CkMdCoCiim928ftKp2zObEsvoeuIPbO7)rZ3qYb4et4KkAuC(VEk3oeSgF)8PHqE0PasskKj0z3GzXiFOAAZxcWtEqWcjFOlkKyk1dYSU)hnV0BdrSJfQoiZbooIcL0BdrSJfQoiJd)0heMEB(IjYh7m0apPkhcINJevhpFdjhGtmHtQOrX5)6PC7qWA89ZNgcdctVnFXe5JDgAGNuLdbjrMHWPC7mdoor(8T8ASBj0fngNd8nKCKOcijPGezgcNYTt7blPGzP3PdCCep))A5tRe557tDRtgkGOAofZbhfeMEB(IjYh7m0apPkhcsImdHt52zgCCI85B51y3sOlAmoh4Bi5irfqssbjYmeoLBN2dwsbZsVthoeeMEB(IjYh7m0apPkhcsImdHt52zgCCI85B51y3sOlAmoh4Bi5abluyJk2TVtGoqN)FT8PvcjMgGEwYUe9zlbevZPy8aULASmHejhnsHI)FT8PvcjsoAuar1Ckgpl1yzcjsoAKcf)teRSmrnUaSozI88)RLpTsiX0aW6squar1Ckg9bHhnwciayfRLqx0ILrlpzXMqmw5Wsfnk5lwdWWIL2O1XQrl2wpySStSKXcblKrqApyjzXofZWug7tglTCSPCJL8HXsffvqqQajhnsqQatda1SyPcqueeMEB(IjYh7m0apPkhcs7blzNDILeH8nKCOd4m0SPCzcFlVgPqrIPbO7SgxaMGK2dwsu2Te6IgRDo(wEn2XcvhKrppjQasskirMHWPC70EWskyw6D2UJ4bbluyJk2TV7ih8)RLpTsKvRUSKciQMtXccdcp6rJfy8T5RGW0BZxmH)FT8PvmoNVnFX3qYHycNurJc18i8WU)FT8PvSE6THisHYjAc3e6(T0Oi92qe5DIMWnHUFlnkGOAofZbo8FKuOqoUaSoevZPyoW)rgeE0JglW(Vw(0kwqy6T5lMW)Vw(0kgv5qWeQ2Q)KDda2Lyk5Bi54)xlFALaSa86wDf94cWequnNI5a3GN)FT8PvczcD2nywmYhQM28LaIQ5uSoY1t0BO0bUbpl1yzcWcWRB1v0JlaJhD()1YNwjYZ3N6wNmuar1Ckwh56j6nu6a3GhXeoPIgfKGAD3lHuOaCIjCsfnkib16UxcPNcfGBPgltawaEDRUIECbyuOO8mgpYXfG1HOAofZbhDCqy6T5lMW)Vw(0kgv5qq2dQ7qmpriF(wEn2Te6IgJZb(gsowcDrtyJk2TVF6TUJo2HJ5zj0fnHnQy3(UCW2pMx6THi2XcvhK5ahhfeE0yja(1swSCrpUaSyjFySGNXAFShhld9FjzXAFSSwLpwAJbiwG557tDRtgYxSTrdacPnmKVybzyS0gdqSurcDglqGzXiFOAAZxIGW0BZxmH)FT8PvmQYHGGfGx3QROhxagFdjhIjCsfnkyw)uNvnLlp68)RLpTsKNVp1TozOaIQ5uSoY1t0BO0HJPqX)Vw(0krE((u36KHciQMtX6ixprVHY2pWD65rN)FT8PvczcD2nywmYhQM28LaIQ5umhC9skuuajjfYe6SBWSyKpunT5lb4j9bHP3MVyc))A5tRyuLdbblaVUvxrpUam(gsoet4KkAuKsjRdr1CkkuuEgJh54cW6qunNI5a)hcctVnFXe()1YNwXOkhcYavv)Q7Mq3VLg5tpf29soo6i5o35Bi5abRX3pFAiuirYXpMdhiqE()1YNwjalaVUvxrpUambevZPyoCWr88)RLpTsitOZUbZIr(q10MVequnNI5WbhfeMEB(Ij8)RLpTIrvoeuMqNDdMfJ8HQPnFX3qYHycNurJcM1p1zvt5YJo5BcWcWRB1v0JlaRlFtar1Ckgfka3snwMaSa86wDf94cWOpim928ft4)xlFAfJQCiOmHo7gmlg5dvtB(IVHKdXeoPIgfPuY6qunNIcfLNX4roUaSoevZPyoW)HGW0BZxmH)FT8PvmQYHG557tDRtgY3qYj92qe7yHQdY4CGNevajjfKiZq4uUDApyjfml9oBNdbYJoGtmHtQOrbjOw39sifket4KkAuqcQ1DVeYJo))A5tReGfGx3QROhxaMaIQ5uS2pWDku8)RLpTsitOZUbZIr(q10MVequnNI1rUEIEdLTFG78aULASmbyb41T6k6XfGrp9bHP3MVyc))A5tRyuLdbZZ3N6wNmKpFlVg7wcDrJX5aFdjN0BdrSJfQoiRDo8ZtIkGKKcsKziCk3oThSKcMLENT7iEaxIPbONLSlrF2syJ35uUbHP3MVyc))A5tRyuLdbzGQQF1DtO73sJ8nKCGG147NpnekKi54hZHdeip))A5tReGfGx3QROhxaMaIQ5umho4iE()1YNwjKj0z3GzXiFOAAZxciQMtX6ixprVHsho4OGW0BZxmH)FT8PvmQYHGGfGx3QNmwcQn(gsoet4KkAuWS(PoRAkxEsubKKuqImdHt52P9GLuWS070b(5r3jAI889DxapOwKEBiIuOOasskKj0z3GzXiFOAAZxcWtE()1YNwjYZ3N6wNmuar1Ckw7h4ofk()1YNwjYZ3N6wNmuar1Ckw7h4op))A5tReYe6SBWSyKpunT5lbevZPyTFG70heMEB(Ij8)RLpTIrvoeeSa86w9KXsqTXNVLxJDlHUOX4CGVHKt6THi2XcvhK1oh(5jrfqssbjYmeoLBN2dwsbZsVth4NhDNOjYZ33Db8GAr6THisHIcijPqMqNDdMfJ8HQPnFjapPqX)Vw(0kHetdqplzxI(SLaIQ5umhC9s6dctVnFXe()1YNwXOkhccZHHDjMs(gsoa)enHlGhulsVneXGWJE0yPIHLkAuYxShbqMfB9wSqm16wXwpun1XQGasIZdJ1aKg1SyP9qdqSNGqg4uUXof32nvrrq4rpASP3MVyc))A5tRyuLdbzPhoKJFsD)m9gFdjN0BdrSJfQoiRDo8Zd4kGKKczcD2nywmYhQM28La8KN)FT8PvczcD2nywmYhQM28LaIQ5uS2pMcfLNX4roUaSoevZPyo46LbHbHh9OXcSprSYYIfyQm6XgKfeMEB(Ij8prSYYyCy0sO6uUD1Hz8nKCiMWjv0OGz9tDw1uU8GG147NpnekKi54hR9dhjp68)RLpTsKNVp1TozOaIQ5umkuaULASmrcvB1FYUba7YuTqjp))A5tReYe6SBWSyKpunT5lbevZPy0tHIYZy8ihxawhIQ5umhoCii8OX2GwS2hlidJnjnegBE((yhwSFflWsfXMSyTp2tisell2Nic9555uUXEebgJLgGrJXYqZMYnwWZybwQGAwqy6T5lMW)eXklJrvoeKrlHQt52vhMX3qYX)Vw(0krE((u36KHciQMtX4rx6THi2XcvhK1oh(5LEBiIDSq1bzoW5yEqWA89ZNgcfsKC8J1(bUtv6sVneXowO6GS2WrsppIjCsfnksPK1HOAoffkP3gIyhluDqw7hZdcwJVF(0qOqIKJFS2jqUtFqy6T5lMW)eXklJrvoemvE1PsB(QRhvf(gsoet4KkAuWS(PoRAkxEaN9GALPKcnMYUsRoY1u9uJ8OZ)Vw(0krE((u36KHciQMtXOqb4wQXYejuTv)j7gaSlt1cL88)RLpTsitOZUbZIr(q10MVequnNIrppiyHcBuXU9DcSDfqssbeSgF3)qi4PnFjGOAofJcfLNX4roUaSoevZPyoW)HGW0BZxmH)jIvwgJQCiyQ8QtL28vxpQk8nKCiMWjv0OGz9tDw1uU8ypOwzkPqJPSR0QJCnvp1ip6KVjalaVUvxrpUaSU8nbevZPyTF4afka3snwMaSa86wDf94cW45)xlFALqMqNDdMfJ8HQPnFjGOAofJ(GW0BZxmH)jIvwgJQCiyQ8QtL28vxpQk8nKCiMWjv0OGz9tDw1uU8ypOwzkPWjsCkw)FcyOEkxEsubKKuqImdHt52P9GLuWS07SDoeyqy6T5lMW)eXklJrvoemvE1PsB(QRhvf(gsoet4KkAuKsjRdr1CkEqWcf2OID77ey7kGKKciyn(U)HqWtB(sar1Ckwqy6T5lMW)eXklJrvoeKbi9o1y3aGDWI2dnaT4Bi5qmHtQOrbZ6N6SQPC5rN)FT8PvI889PU1jdfqunNI1(bUtHcWTuJLjsOAR(t2nayxMQfk55)xlFALqMqNDdMfJ8HQPnFjGOAofJEkuuEgJh54cW6qunNI5WHJdctVnFXe(NiwzzmQYHGmaP3Pg7gaSdw0EObOfFdjhIjCsfnksPK1HOAofp6KyAa6zj7s0NTe24DoLlfkWCKDKiwMiLsMaIQ5umh4CGaPpim928ft4FIyLLXOkhcsQrgapmjn(gsoShuRmLuCcYmqn2ri4PnFfegeE0JgBZuUAmwGKqx0cctVnFXeUyHWXZrIPbO7)rZ3qYb4et4KkAuC(VEk3oeSgF)8PHqE0PasskyGsjwD5)QciMEJcfiyn((5tdHcjso(XCGZbhrpfkNOjCtO73sJI0BdrKheSqh44ikuihxawhIQ5umhoWDEaxIkGKKcsKziCk3oThSKcWZGW0BZxmHlwiC8uLdbZQvxws(gso0zPgltirYrJcSsfnkPqX)eXkltuJlaRtMifkqWcjFOlkobGj8v)cz0ZJoGtmHtQOrX5)6PC7qWczuOO8mgpYXfG1HOAofZHJPpim928ft4Ifchpv5qqApyj7StSKiKVHKdXeoPIgfsq1ZoThSKmEsubKKuqImdHt52P9GLuWS07SDoh45)xlFALipFFQBDYqbevZPyDKRNO3qz7hZd4et4KkAuC(VEk3oeSqwqy6T5lMWfleoEQYHG0EWs2zNyjriFdjhjQasskirMHWPC70EWskyw6D2UJ4bCIjCsfnko)xpLBhcwiJcfjQasskirMHWPC70EWskap5roUaSoevZPyoqNevajjfKiZq4uUDApyjfml9oBdUEj9bHP3MVycxSq44PkhckX0a09)O5Bi5abRX3pFAiuirYXpMdC4N78aoXeoPIgfN)RNYTdbRX3pFAimim928ft4Ifchpv5qqsKziCk3oZGJtKVHKJevajjfKiZq4uUDApyjfml9oDGa5bCIjCsfnko)xpLBhcwilim928ft4Ifchpv5qqjMgGU)hnFdjhGtmHtQOrX5)6PC7qWA89ZNgcdctVnFXeUyHWXtvoeK2dwYo7eljc5Bi5irfqssbjYmeoLBN2dwsbZsVZ25CGheSqh4NhWjMWjv0O48F9uUDiyHmE()1YNwjYZ3N6wNmuar1Ckwh56j6nu2(XbHbHh9OX2MGfchFSaZhyiwGr48WXAfeMEB(IjCXcHJVNpYHwogFm0ZX)Vw(0kb7b1DiMNiuar1CkgFdjhl1yzc2dQ7qmpriplHUOjSrf723p9w3rh7WX8ihxawhIQ5uS2pMN)FT8Pvc2dQ7qmprOaIQ5umhOZ1lBdCxWnoMEEP3gIyhluDqMdCCuqy6T5lMWfleo(E(iv5qqjMgGU)hnFdjh6aoXeoPIgfN)RNYTdbRX3pFAiKcffqssbdukXQl)xvaX0B0ZJofqssHmHo7gmlg5dvtB(saEYdcwi5dDrHetPEqM19)O5LEBiIDSq1bzoWXruOKEBiIDSq1bzC4N(GW0BZxmHlwiC898rQYHG45ir1XZ3qYrbKKuWaLsS6Y)vfqm9gfkaNycNurJIZ)1t52HG147NpnegeE0yBZKXAj0fTy9T86PCJDyXkhwQOrjFXYOnMhqSkP3zS2hRbaJLnLRg52wcDrlwxSq44Jvpml2PygMsrqy6T5lMWfleo(E(iv5qqiy1tVnF11dZ4RsvKJlwiC88Xm44noh4Bi54B51yhluDqgNdbHP3MVycxSq4475JuLdbP9GLSZoXsIq(8T8ASBj0fngNd8nKCOZ)Vw(0krE((u36KHciQMtXA)yEsubKKuqImdHt52P9GLuaEsHIevajjfKiZq4uUDApyjfml9oB3r0ZJoYXfG1HOAofZb))A5tResmna9SKDj6ZwciQMtXO6bUtHc54cW6qunNI1U)FT8PvI889PU1jdfqunNIrFqy6T5lMWfleo(E(iv5qqsKziCk3oZGJtKpFlVg7wcDrJX5aFdjhjQasskirMHWPC70EWskyw6D6ahhXZ)Vw(0krE((u36KHciQMtXC4ykuKOcijPGezgcNYTt7blPGzP3PdhcctVnFXeUyHWX3ZhPkhcsImdHt52zgCCI85B51y3sOlAmoh4Bi54)xlFALipFFQBDYqbevZPyTFmpjQasskirMHWPC70EWskyw6D6WHGWJglqamSyhwSijj6THiQBfl5O1imwAagpGyzJklwQaySj2cbnyQ5lwfqlwgGhulJ9eIeXYInJL5XkHZhlnaieJ1aGXMs5xXcizXwVbyk3yTpwi6FvvSKIGW0BZxmHlwiC898rQYHGKiZq4uUDMbhNiFdjN0BdrSlFtqImdHt52P9GLSDo(wEn2XcvhKXtIkGKKcsKziCk3oThSKcMLENoqGbHbHhn2Jy6NuZcctVnFXeW0pPMXjH(SWU9qiwgFdjhiyn((5tdHcjso(XA)ipMhDNOjCtO73sJI0BdrKcfGBPgltWavv)Q7Mq3VLgfyLkAusppiyHcjso(XANZXbHP3MVycy6NuZOkhcQO)x2jbHT4Bi5qmHtQOrHAEeEy3)Vw(0kwp92qePq5enHBcD)wAuKEBiI8ort4Mq3VLgfqunNI5ahfqssHI(FzNee2sibHPnFrHIYZy8ihxawhIQ5umh4Oassku0)l7KGWwcjimT5RGW0BZxmbm9tQzuLdbvqidHoNYLVHKdXeoPIgfQ5r4HD))A5tRy90BdrKcLt0eUj09BPrr6THiY7enHBcD)wAuar1CkMdCuajjfkiKHqNt5kKGW0MVOqr5zmEKJlaRdr1CkMdCuajjfkiKHqNt5kKGW0MVcctVnFXeW0pPMrvoeupUamw)iakDvXY4Bi5OasskalaVUvNzqSCnacWZGWJglWS8iZGPowGn16y9zfRbhxxeglbg75ByztQJvbKKKXxSy6beRoz2uUXE44yzO)ljtelbaB0dbmuglGekJ1)sugRnQySjl2mwdoUUimw7J1jINXowSqmLPIgfbHP3MVycy6NuZOkhcMLhzgm1DFQ18nKCiMWjv0OqnpcpS7)xlFAfRNEBiIuOCIMWnHUFlnksVnerENOjCtO73sJciQMtXCGZHJPqr5zmEKJlaRdr1CkMdCoCCqy6T5lMaM(j1mQYHGj0Nf2pb1mKVHKt6THi2XcvhK1oh(PqHoiyHcjso(XANZX8GG147NpnekKi54hRDohj3Ppim928ftat)KAgv5qqYbIk6)L8nKCiMWjv0OqnpcpS7)xlFAfRNEBiIuOCIMWnHUFlnksVnerENOjCtO73sJciQMtXCGJcijPGCGOI(FPqcctB(IcfLNX4roUaSoevZPyoWrbKKuqoqur)VuibHPnFfeMEB(IjGPFsnJQCiOs62FYUbhVtgFdjN0BdrSJfQoiJZbE0PasskalaVUvNzqSCnacWtkuuEgJh54cW6qunNI5WX0hegeE0JglqGt5enwqy6T5lMWGt5enghqg2hdv5RsvKZumpe0sfn25wGzzGQDjsC8iFdjh68)RLpTsawaEDRUIECbyciQMtXANFUtHI)FT8PvczcD2nywmYhQM28LaIQ5uSoY1t0BOSD(5o98Ol92qe7yHQdYANd)uOCIMiHQT6UaEqTi92qePq5enrE((UlGhulsVnerE0zPgltawaEDREYyjO2OqrIPbO7SgxaMqoSurJ98nj9uOCIMWnHUFlnksVner6Pqr5zmEKJlaRdr1CkMd8FGcflHUOjSrf723p9wNFU7WXbHhnwGaaJ1Gt5eTyPngGynaySagxaiZIfz2OMgkJLyQbr(IL2O1XQGXcYqzSKdKzXMLm2ZCGOmwAJbiwG557tDRtgglDdzSkGKKXoSypCCSm0)LKf7dJvJmg9X(Wy5IECbyeKkasS0nKX6cX0qySgGSI9WXXYq)xsg9bHP3MVycdoLt0yuLdbn4uor7aFdjhGtmHtQOrb7e9d5GYUbNYjA8OJodoLt0ehekGKKDjimT5lh4C4yE()1YNwjYZ3N6wNmuar1Ckw78ZDkum4uortCqOass2LGW0MVA)WX8OZ)Vw(0kbyb41T6k6XfGjGOAofRD(5ofk()1YNwjKj0z3GzXiFOAAZxciQMtX6ixprVHY25N70tHs6THi2XcvhK1oh(5PasskKj0z3GzXiFOAAZxcWt65rhWn4uortWVaqY6()1YNwrHIbNYjAc(f()1YNwjGOAofJcfIjCsfnkm4uorRFcNhowlohONEkum4uortCqOass2LGW0MVANd54cW6qunNIfeMEB(Ijm4uorJrvoe0Gt5en(5Bi5aCIjCsfnkyNOFihu2n4uorJhD0zWPCIMGFHcijzxcctB(YbohoMN)FT8PvI889PU1jdfqunNI1o)CNcfdoLt0e8luajj7sqyAZxTF4yE05)xlFALaSa86wDf94cWequnNI1o)CNcf))A5tReYe6SBWSyKpunT5lbevZPyDKRNO3qz78ZD6Pqj92qe7yHQdYANd)8uajjfYe6SBWSyKpunT5lb4j98Od4gCkNOjoiaKSU)FT8PvuOyWPCIM4GW)Vw(0kbevZPyuOqmHtQOrHbNYjA9t48WXAXHF6PNcfdoLt0e8luajj7sqyAZxTZHCCbyDiQMtXccpASTzYy)s3k2VWy)kwqggRbNYjAXEcFIJezXMXQassYxSGmmwdag7BaqySFfR)FT8PvIyBJWyhYylCmaimwdoLt0I9e(ehjYInJvbKKKVybzySkVbi2VI1)Vw(0krqy6T5lMWGt5engv5qqdoLt0oW3qYb4gCkNOjoiaKSoid7kGKK8OZGt5enb)c))A5tRequnNIrHcWn4uortWVaqY6GmSRasssFqy6T5lMWGt5engv5qqdoLt04NVHKdWn4uortWVaqY6GmSRassYJodoLt0ehe()1YNwjGOAofJcfGBWPCIM4GaqY6GmSRasss)1U29c]] )


end
