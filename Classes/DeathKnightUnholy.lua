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
        cadaverous_pallor = 163, -- 201995
        dark_simulacrum = 41, -- 77606
        decomposing_aura = 3440, -- 199720
        dome_of_ancient_shadow = 5367, -- 328718
        life_and_death = 40, -- 288855
        necromancers_bargain = 3746, -- 288848
        necrotic_aura = 3437, -- 199642
        necrotic_strike = 149, -- 223829
        raise_abomination = 3747, -- 288853
        reanimation = 152, -- 210128
        transfusion = 3748, -- 288977
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
            duration = 3600,
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
            cooldown = 120,
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
            cooldown = 480,
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
            cooldown = 20,
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


        necrotic_strike = {
            id = 223829,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 1,
            spendType = "runes",

            startsCombat = true,
            texture = 132481,

            pvptalent = function ()
                if essence.conflict_and_strife.major then return end
                return "necrotic_strike"
            end,
            debuff = "festering_wound",

            handler = function ()
                if debuff.festering_wound.up then
                    if debuff.festering_wound.stack == 1 then removeDebuff( "target", "festering_wound" )
                    else applyDebuff( "target", "festering_wound", debuff.festering_wound.remains, debuff.festering_wound.stack - 1 ) end

                    if conduit.convocation_of_the_dead.enabled and cooldown.apocalypse.remains > 0 then
                        reduceCooldown( "apocalypse", conduit.convocation_of_the_dead.mod * 0.1 )
                    end

                    applyDebuff( "target", "necrotic_wound" )
                end
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


    spec:RegisterPack( "Unholy", 20210320, [[devbdcqia0Jqr6saLk2er5tevnkuPofQKvbeIxbaZcO6wOOk7sWVuQYWeQ0XaOLju1ZqrzAOiCnLk2gqO(MsLW4qrfoNqfrRdi4DaLk18iQCpezFkv1bbkLfcu8quenrGOUiqPQncuQKpIIkzKcvK6KcvuRei9sHkcZuPs6MOOs1ovk8tHk0qfQGLcespLitvPORIIkARcvK8vLkrJfiYEvYFLQbRQdtzXc5XeMmjxgAZO0NLsJgqNw0Qrrv9ALsZMu3gvTBj)wLHlfhhOKLd65inDQUocBhf(oIA8kvQZluwpkQuMpQy)kEb4AZLKYCCTr8XnEaJlZIpUbaJ7ombtWeljpwdUKAmXwRfxsLXJljMZc4PJTKASy6ZuRnxs0JakWLeq3BOGWE71MoqIOG443JM8eAZZReqJ13JM8I9wsreP2JZ1kAjPmhxBeFCJhW4YS4JBaW4UdZ2H5yjrBqXAJ43j(LeWuPWAfTKuivSKaz0CGZhNOYwG(8mNfWthBaL5UbfaNp(4c(8Xh34bCaDaLjbAvlsbHbuM38GnfZNG68y5059BEqUa59azKn14EGmAoq68GmboVFZFLo28IJO85Dd2IoDEYaV5niopU7gu4OAE)MxNmW51x1opwhrlW59BEEZDeop32HDk6enZZua5kmGY8MhKtQfPr18sMaMSPin98Xbt4ZhHcJGIZRqtnFlWJqtNN32IZZEW5PMAEqoobnmGY8MN5KMv787YJOuZl1GLcHZBrPo9ePZZFqCEwnU7mshBEUnFEMaaZtDtSLoFwuhn18h787aaUa7EEqooinFHeo00ZBLAEEl28nqKbw(80JhNVoMhefZttNW88kAyaL5npZjnR25b7cPocZQDEjhMBX5ZAEWwCeSF(KD(yhX8ang4815aZQDEutX59BE1nVvQ5jFL8(8hdekSM5jFeLIoFsNhKJdsZxiHdnDyaL5nptc0QwunpVvXMxE2SfO3HiVLfv(5fxPspVY0059BERPrhB(SMp6O05zZwGoD(R0XMNBnsPZZKG88KnQJZF18o0Oa5kmGY8MFZ4iihhbH5NFdK88omRTOpVaMoctlSK0j1PRnxs2HDk6enRnxBa4AZLewwKgvlWSKeW0ryAljfAoW(2kBb6bwYhrPqv3nyl6053N08Iycn2Xc5tKophoZdTu1rgy5btPObC3j1PZlBEOLQoYalpykfnarEll68YrAEabCjzcpVAjzvSUQulFTr8RnxsyzrAuTaZssathHPTKuO5a7BRSfOhyjFeLcvD3GTOtNFFsZVZsYeEE1sYQyDvPw(AdMT2CjHLfPr1cmljbmDeM2scGZZWGPfPXqZD6SA7qIkf9MJmcNx28CpFeblBqzWTDhAfL9G8MNxfiAMx28qIczpylguOP0js9U4sDallsJQ5LnVj8Kb2Xc5tKoVCKMNzZZHZ8MWtgyhlKpr68KMp(55AjzcpVAjPqZb2fxQx(AdMyT5scllsJQfywscy6imTLeaNNHbtlsJHM70z12Hevk6nhzeUKmHNxTKWMuH8Py5Rn2zT5scllsJQfywscy6imTLKcJiyzdSi1rywTDYhrPcu3eBNxosZZS5LnV4oT6ixbR5eMowdfdqK3YIoVCZZSLKj88QLelsDeMvBN6WClUKeXeAS7gSfD6Adax(Adq8AZLewwKgvlWSKeW0ryAljfgrWYgyrQJWSA7KpIsfOUj2oVCZd4sYeEE1sIfPocZQTtDyUfxsIycn2Dd2IoDTbGlFTXUyT5scllsJQfywscy6imTLKcJiyzdSi1rywTDYhrPcu3eBNxosZZS5LnpKOWGN8y3VotmVCZlUtRoYvWQyDvPcqK3YIUKmHNxTKyrQJWSA7uhMBXLKiMqJD3GTOtxBa4YxBWCS2CjHLfPr1cmljbmDeM2sI75b48u09SAPbrmHgNNdN5vO5a7BRSfOhyjFeLcvD3GTOtNFFsZlIj0yhlKpr68CnVS5vyeblBGfPocZQTt(ikvG6My787ppZMx28qIcdEYJD)6mBE5MxCNwDKRGvX6QsfGiVLfDjzcpVAjr(ikvN2GLcHljfsfWSXZRws7sGynVBWw0NNs2AOZBqCEvsTinQaFEhysNNCQ1ZRrF(yhX80gSuZdjkKUh5JOu05ZI6OPM)yNNSLEwTZZEW5b5cK3dKr2uJ7bYO5aLNopitGHLV8LKDypIas91MRnaCT5scllsJQfywscy6imTLe3ZhrWYgOekfwD1D8biAcFEoCMhGZZWGPfPXqZD6SA7qIkf9MJmcNNR5Lnp3ZhrWYgugCB3HwrzpiV55vbIM5LnpKOq2d2IbfAkDIuVlUuhWYI0OAEzZBcpzGDSq(ePZlhP5z28C4mVj8Kb2Xc5tKopP5JFEUwsMWZRwsk0CGDXL6LV2i(1MljSSinQwGzjjGPJW0wsqIkf9MJmcdkKnfPpVCZZ98ag35bW8k0CG9Tv2c0dSKpIsHQUBWw0PZdImpZMNR5LnVcnhyFBLTa9al5JOuOQ7gSfD68YnpiEEzZdW5zyW0I0yO5oDwTDirLIEZrgHZZHZ8reSSbkzdYNvBNpPEGOzjzcpVAjHnPc5tXYxBWS1MljSSinQwGzjjGPJW0wsqIkf9MJmcdkKnfPpVCZh)oZlBEfAoW(2kBb6bwYhrPqv3nyl6053F(DMx28aCEggmTingAUtNvBhsuPO3CKr4sYeEE1scBsfYNILV2GjwBUKWYI0OAbMLKaMoctBjbW5vO5a7BRSfOhyjFeLcvD3GTOtNx28aCEggmTingAUtNvBhsuPO3CKr48C4mpB2c07qK3YIoVCZVZ8C4mp0svhzGLhmLIgWDNuNoVS5HwQ6idS8GPu0ae5TSOZl387SKmHNxTKWMuH8Py5Rn2zT5sYeEE1sI8ruQoTblfcxsyzrAuTaZYxBaIxBUKWYI0OAbMLKaMoctBjbW5zyW0I0yO5oDwTDirLIEZrgHljt45vljSjviFkw(YxsI70QJCrxBU2aW1MljSSinQwGzjjGPJW0wsmmyArAmWBm)d2f3Pvh5I2nHNmW55Wz(OJsNx28SzlqVdrEll68YnF8G4LKj88QLuZ55vlFTr8RnxsyzrAuTaZssathHPTKe3Pvh5kquapDSEKoBb6biYBzrNxU53zEzZlUtRoYvqzWTDhAfL9G8MNxfGiVLfTJ7UbfoQMxU53zEzZ7MglpquapDSEKoBb6bSSinQMNdN5b48UPXYdefWthRhPZwGEallsJQ55Wz(OJsNx28SzlqVdrEll68YnpZ2zjzcpVAjzq(y9JT7aXUcn1YxBWS1MljSSinQwGzjjGPJW0wsUbBrp4jp29R3i8oZ2zE5MFN5LnVBWw0dEYJD)6QeNF)53zEzZBcpzGDSq(ePZlhP5z2sYeEE1sIEe6oeTgeUKeXeAS7gSfD6Adax(AdMyT5scllsJQfywscy6imTLeddMwKgduV3OTQYQDEzZZ98I70QJCfSMty6ynumarEllAh3DdkCunVCZVZ8C4mV4oT6ixbR5eMowdfdqK3YI2XD3GchvZV)8ag355AEzZZ98I70QJCfugCB3HwrzpiV55vbiYBzrNxU5BfQ55Wz(icw2GYGB7o0kk7b5npVkq0mpxljt45vljIc4PJ1J0zlqFjPqQaMnEE1sko9Pv05bJoBb6ZZEW5jAM3V53zEkkUsrN3V5PXkX8Kth48GTMty6ynue85JJoqesoPi4ZtqX5jNoW5bzdUD(nHwrzpiV55vHLV2yN1MljSSinQwGzjjGPJW0wsMWtgyhlKpr687tA(4NNdN5JokDEzZZMTa9oe5TSOZl38Xd4sYeEE1sIOaE6y9iD2c0x(Adq8AZLewwKgvlWSKeW0ryAljggmTingOEVrBvLv78YMN75vNhikGNowpsNTa9U68ae5TSOZZHZ8aCE30y5bIc4PJ1J0zlqpGLfPr18CTKmHNxTKugCB3HwrzpiV55vlFTXUyT5scllsJQfywscy6imTLKj8Kb2Xc5tKo)(KMp(55Wz(OJsNx28SzlqVdrEll68YnF8aUKmHNxTKugCB3HwrzpiV55vlFTbZXAZLewwKgvlWSKeW0ryAljt4jdSJfYNiDEsZd48YMxHreSSbwK6imR2o5JOubQBITZV)8mBjzcpVAjznNW0XAO4YxBeNCT5scllsJQfywscy6imTLKj8Kb2Xc5tKo)(KMp(5LnVcJiyzdSi1rywTDYhrPcu3eBNF)5z28YMhGZRqZb2Ts1vOWIf8uSnR2LKj88QLK1CcthRHIljrmHg7UbBrNU2aWLV2aW4U2CjHLfPr1cmljbmDeM2scsuPO3CKryqHSPi95LBEazI5Lnp3ZlUtRoYvGOaE6y9iD2c0dqK3YIoVCZdyCNNdN5vNhikGNowpsNTa9U68ae5TSOZZ1sYeEE1sIsWZFvV1GTxmnU81gac4AZLewwKgvlWSKeW0ryAljggmTingOEVrBvLv78YMxHreSSbwK6imR2o5JOubQBITZl38XpVS55E(g0dwZj6TapcDWeEYaNNdN5JiyzdkdUT7qROShK388QarZ8YMhGZ3GEWG8X6TapcDWeEYaNNRLKj88QLerb80X6gLAeAF5Rnam(1MljSSinQwGzjjGPJW0wsMWtgyhlKpr687tA(4Nx28kmIGLnWIuhHz12jFeLkqDtSDE5Mp(LKj88QLerb80X6gLAeAFjjIj0y3nyl601gaU81gaYS1MljSSinQwGzjjGPJW0wsaC(g0dTapcDWeEYaxsMWZRwsqlPyxHMA5lFj1IfctXAZ1gaU2CjHLfPr1cmljbmDeM2skIGLnqjukS6Q74dq0e(8YMhGZZWGPfPXqZD6SA7qIkf9MJmcNNdN5Bqp0AW2lMgdMWtg4sYeEE1ssHMdSlUuV81gXV2CjHLfPr1cmljbmDeM2scsuPO3CKryqHSPi95LBEaz28C4mpB2c07qK3YIoVCZVZ8YMhGZRWicw2alsDeMvBN8ruQarZsYeEE1ssHMdSlUuV81gmBT5scllsJQfywscy6imTLK4oT6ixbR5eMowdfdqK3YIoVS55EE30y5bfYMAmGLfPr18C4mV4yGLvEOYwGEN1W55WzEirHShSfdnardE8xH0awwKgvZZ18YMN75b48mmyArAm0CNoR2oKOq68C4mpB2c07qK3YIoVCZVZ8CTKmHNxTKSkwxvQLV2GjwBUKWYI0OAbMLKaMoctBjPWicw2alsDeMvBN8ruQa1nX253FEMnVS5b48mmyArAm0CNoR2oKOq6sYeEE1sI8ruQoTblfcx(AJDwBUKWYI0OAbMLKaMoctBjPWicw2alsDeMvBN8ruQarZ8YMxCNwDKRG1CcthRHIbiYBzr74UBqHJQ53F(DMx28aCEggmTingAUtNvBhsuiDjzcpVAjr(ikvN2GLcHlFTbiET5scllsJQfywscy6imTLeKOsrV5iJWGcztr6Zl38Xh35LnpaNNHbtlsJHM70z12Hevk6nhzeUKmHNxTKuO5a7Il1lFTXUyT5scllsJQfywscy6imTLKcJiyzdSi1rywTDYhrPcu3eBNxU5bCEzZdW5zyW0I0yO5oDwTDirH0LKj88QLelsDeMvBN6WClU81gmhRnxsyzrAuTaZssathHPTKuyeblBGfPocZQTt(ikvG6My78YnptmVS5f3Pvh5kynNW0XAOyaI8ww0oU7gu4OAE5MFN5LnpaNNHbtlsJHM70z12HefsxsMWZRwsSi1rywTDQdZT4YxBeNCT5scllsJQfywscy6imTLeaNNHbtlsJHM70z12Hevk6nhzeUKmHNxTKuO5a7Il1lF5ljXXalRC6AZ1gaU2CjHLfPr1cmljbmDeM2sIHbtlsJbQ3B0wvz1oVS5Hevk6nhzeguiBksF(9Nhqq88YMN75f3Pvh5kynNW0XAOyaI8ww055WzEaoVBAS8Gb5J1p2Ude7kJVqvallsJQ5LnV4oT6ixbLb32DOvu2dYBEEvaI8ww055AEoCMp6O05LnpB2c07qK3YIoVCZdiGljt45vljkzdYNvBNpP(YxBe)AZLewwKgvlWSKeW0ryAljXDA1rUcwZjmDSgkgGiVLfDEzZZ98MWtgyhlKpr687tA(4Nx28MWtgyhlKpr68YrA(DMx28qIkf9MJmcdkKnfPp)(ZdyCNhaZZ98MWtgyhlKpr68GiZdINNR55WzEt4jdSJfYNiD(9NFN5LnpKOsrV5iJWGcztr6ZV)8mrCNNRLKj88QLeLSb5ZQTZNuFjPqQaMnEE1ssc959BEckoVX6iCER5eZN05VAEMeKN3OZ738nqKbw(8hdekSMMSANhenompzGPgNNIUNv78enZZKGS80LV2GzRnxsyzrAuTaZssathHPTKyyW0I0yG69gTvvwTZlBEaop9i0rzPcA0u9OyDC3gFJgdyzrAunVS55EEXDA1rUcwZjmDSgkgGiVLfDEoCMhGZ7Mglpyq(y9JT7aXUY4lufWYI0OAEzZlUtRoYvqzWTDhAfL9G8MNxfGiVLfDEUMx28qIcdEYJD)6mX87pp3ZZS5bW8reSSbirLIU4GqIgpVkarEll68CnphoZhDu68YMNnBb6DiYBzrNxU5JhWLKj88QLKfD8zzEEvxN8rlFTbtS2CjHLfPr1cmljbmDeM2sIHbtlsJbQ3B0wvz1oVS5PhHoklvqJMQhfRJ724B0yallsJQ5Lnp3ZRopquapDSEKoBb6D15biYBzrNF)5beW55WzEaoVBAS8arb80X6r6SfOhWYI0OAEzZlUtRoYvqzWTDhAfL9G8MNxfGiVLfDEUwsMWZRwsw0XNL55vDDYhT81g7S2CjHLfPr1cmljbmDeM2sYeEYa7yH8jsNFFsZh)8YMhsuyWtES7xNjMF)55EEMnpaMpIGLnajQu0fhes045vbiYBzrNNRLKj88QLKfD8zzEEvxN8rlFTbiET5scllsJQfywscy6imTLeddMwKgduV3OTQYQDEzZZ98I70QJCfSMty6ynumarEll68C4mpaN3nnwEWG8X6hB3bIDLXxOkGLfPr18YMxCNwDKRGYGB7o0kk7b5npVkarEll68CnphoZhDu68YMNnBb6DiYBzrNxU5bCNLKj88QLefOj2QXUde7ef5d6aJT81g7I1MljSSinQwGzjjGPJW0wsMWtgyhlKpr687tA(4Nx28CpVcnhy3kvxHclwWtX2SANNdN5HwQ6idS8GPu0ae5TSOZlhP5bKjMNRLKj88QLefOj2QXUde7ef5d6aJT8LVKAGO44JmFT5AdaxBUKmHNxTKAopVAjHLfPr1cmlFTr8RnxsMWZRwsqlPyxHMAjHLfPr1cmlF5ljOjsttxBU2aW1MljSSinQwGzjjGPJW0wsqIkf9MJmcdkKnfPp)(ZdI3zEzZZ98nOhAny7ftJbt4jdCEoCMhGZ7Mglpqj45VQ3AW2lMgdyzrAunpxZlBEirHbfYMI0NFFsZVZsYeEE1sYGcRWUFqiw(ssHubmB88QLeiQjsttx(AJ4xBUKWYI0OAbMLKaMoctBjXWGPfPXaVX8pyxCNwDKlA3eEYaNNdN5Dd2IEWtES7xxL48YrA(icw2qK(ovNLaglOiGMNxTKmHNxTKI03P6SeWylFTbZwBUKWYI0OAbMLKaMoctBjXWGPfPXaVX8pyxCNwDKlA3eEYaNNdN5Dd2IEWtES7xxL48YrA(icw2qecPiCBwTbfb088QLKj88QLuecPiCBwTlFTbtS2CjHLfPr1cmljbmDeM2skIGLnquapDSo1Hy16adenljt45vljD2c0PDMpHQLhlF5Rn2zT5scllsJQfywscy6imTLeddMwKgd8gZ)GDXDA1rUODt4jdCEoCM3nyl6bp5XUFDvIZlhP5bCNLKj88QLKvcK6qt3fMwVKuivaZgpVAjb2kbsDOPNNjnTEEHvZ7WSTfHZZeZ3CowEA65JiyzPGppAcGZRnQNv78aUZ8uuCLIgMN50tDYCdvZd0GQ5fNcvZ7jpoVrN3M3HzBlcN3V53IyZ8PppenLfPXWYxBaIxBUKWYI0OAbMLKaMoctBjzcpzGDSq(ePZVpP5JFEoCMN75HefguiBksF(9jn)oZlBEirLIEZrgHbfYMI0NFFsZdIJ78CTKmHNxTKmOWkS3qOP4YxBSlwBUKWYI0OAbMLKaMoctBjXWGPfPXaVX8pyxCNwDKlA3eEYaNNdN5Dd2IEWtES7xxL48YrA(icw2aBcXi9DQGIaAEE1sYeEE1sInHyK(o1YxBWCS2CjHLfPr1cmljbmDeM2skIGLnquapDSo1Hy16adenZlBEt4jdSJfYNiDEsZd4sYeEE1skYA7hB3HPylD5lFj5WS2IoDT5AdaxBUKWYI0OAbMLuz84sklQas4wKg7GfHvobFxHmsbUKmHNxTKYIkGeUfPXoyryLtW3viJuGljbmDeM2sI75f3Pvh5kquapDSEKoBb6biYBzrNNdN5f3Pvh5kOm42UdTIYEqEZZRcqK3YIopxZlBEUNVb9Gb5J1BbEe6Gj8KbophoZ3GEWAorVf4rOdMWtg48YMhGZ7Mglpyq(y9JT7aXUY4lufWYI0OAEoCM3nyl6bp5XUF9gH3JpUZl387mpxZZHZ8rhLoVS5zZwGEhI8ww05LB(4bC5RnIFT5scllsJQfywsLXJljEtyrqStbIO35jOPyjzcpVAjXBclcIDkqe9opbnfljbmDeM2ssCNwDKRG1CcthRHIbiYBzrNxU53zEzZZ98aCEeSiYMgufYIkGeUfPXoyryLtW3viJuGZZHZ8I70QJCfYIkGeUfPXoyryLtW3viJuGbiYBzrNNR55Wz(OJsNx28SzlqVdrEll68YnF8aU81gmBT5scllsJQfywsLXJljfenfBcXodKsr9sYeEE1ssbrtXMqSZaPuuVKeW0ryAljXDA1rUcwZjmDSgkgGiVLfDEzZZ98aCEeSiYMgufYIkGeUfPXoyryLtW3viJuGZZHZ8I70QJCfYIkGeUfPXoyryLtW3viJuGbiYBzrNNR55Wz(OJsNx28SzlqVdrEll68YnpZw(AdMyT5scllsJQfywsLXJljLb3YFx1vOyBNXbnr6XwsMWZRwskdUL)UQRqX2oJdAI0JTKeW0ryAljXDA1rUcwZjmDSgkgGiVLfDEzZZ98aCEeSiYMgufYIkGeUfPXoyryLtW3viJuGZZHZ8I70QJCfYIkGeUfPXoyryLtW3viJuGbiYBzrNNR55Wz(OJsNx28SzlqVdrEll68YnF8aU81g7S2CjHLfPr1cmljbmDeM2sI75f3Pvh5kynNW0XAOyaI8ww055Wz(icw2GYGB7o0kk7b5npVkq0mpxZlBEUNhGZJGfr20GQqwubKWTin2blcRCc(UczKcCEoCMxCNwDKRqwubKWTin2blcRCc(UczKcmarEll68CTKmHNxTKiOypDKNU8LVKuiRrO91MRnaCT5sYeEE1sIplvNfIiZnCjHLfPr1cmlFTr8RnxsyzrAuTaZs6Awsu0xsMWZRwsmmyArACjXW0e4sI75rWIiBAqvilQas4wKg7GfHvobFxHmsboVS5f3Pvh5kKfvajClsJDWIWkNGVRqgPadq0uXMNRLedd2lJhxs0guKSjQ6omRTOVKuivaZgpVAjfhGidS85PnOiztunVdZAl605JWSANNGIQ5jNoW5nc)4npfZRZcPlFTbZwBUKWYI0OAbML01SKOOVKmHNxTKyyW0I04sIHPjWLK4oT6ixbkbp)v9wd2EX0yaI8ww05LB(DMx28UPXYducE(R6TgS9IPXawwKgvljggSxgpUKAUtNvBhsuPO3CKr4YxBWeRnxsyzrAuTaZs6Awsu0xsMWZRwsmmyArACjXW0e4sYnnwEGEe6oeTgegWYI0OAEzZdjkCE5Mp(5LnVBWw0dEYJD)6ncVZSDMxU53zEzZZMTa9oe5TSOZV)87SKyyWEz84sQ5oDwTDirH0LV2yN1MljSSinQwGzjDnljk6ljt45vljggmTinUKyyAcCjzcpzGDSq(ePZtAEaNx28CppaNhAPQJmWYdMsrd4UtQtNNdN5HwQ6idS8GPu0qwZV)8aUZ8CTKyyWEz84sI69gTvvwTlFTbiET5scllsJQfywsxZsII(sYeEE1sIHbtlsJljgMMaxsnOhAny7ftJbt4jdCEoCMpIGLnquapDSUrPgH2denZZHZ8UPXYdgKpw)y7oqSRm(cvbSSinQMx28nOhSMt0BbEe6Gj8KbophoZhrWYgugCB3HwrzpiV55vbIMLedd2lJhxs8gZ)GDXDA1rUODt4jdC5Rn2fRnxsyzrAuTaZssathHPTKuNhyKqcnwEVrBTeyaISqKc0I048YMhGZ7MglpquapDSEKoBb6bSSinQMx28aCEOLQoYalpykfnG7oPoDjzcpVAjDeEeeTTljfsfWSXZRwsm3TSClRSANpovcj0y5Zhh0wlboFsN3MVbMhm9ylFTbZXAZLewwKgvlWSKeW0ryAlj15bgjKqJL3B0wlbgGilePaTinoVS5nHNmWowiFI053N08XpVS55EEaoVBAS8arb80X6r6SfOhWYI0OAEoCM3nnwEGOaE6y9iD2c0dyzrAunVS5f3Pvh5kquapDSEKoBb6biYBzrNNRLKj88QL0r4rq02U81gXjxBUKWYI0OAbMLKaMoctBjbjkK9GTyGs0GqQdTScyzrAunVS55EE15bw4r9olYaHbiYcrkqlsJZZHZ8QZdr67u9gT1sGbiYcrkqlsJZZ1sYeEE1s6i8iiABx(AdaJ7AZLewwKgvlWSKOOyjjUtRoYvGEe6oeTgegGiVLfDjzcpVAjr2sFjjGPJW0wsUPXYd0Jq3HO1GWawwKgvZlBE3GTOh8Kh7(1BeENz7mVCZVZ8YMNnBb6DiYBzrNF)53zEzZlUtRoYvGEe6oeTgegGiVLfDE5MN75BfQ5brMpUHDXoZZ18YM3eEYa7yH8jsNN08aU81gac4AZLewwKgvlWSKmHNxTKeMw3nHNx11j1xskKkGzJNxTKaBcpVA(DnPoDERuZhhBWcH055oo2GfcP7jHGfbwcKoprrjAAoOJQ5ZAEtPUkW1ssNuVxgpUKCywBrNU81gag)AZLewwKgvlWSKmHNxTKeMw3nHNx11j1xs6K69Y4XLK4yGLvoD5RnaKzRnxsyzrAuTaZsYeEE1ssyAD3eEEvxNuFjPtQ3lJhxsqtKMMU81gaYeRnxsyzrAuTaZsYeEE1ssyAD3eEEvxNuFjPqQaMnEE1sYeEEfnOqwJq7aG0EueSiWsGGNSKmHNmWowiFIusakdGk0CG9Tv2c0dQKArASBNRaVmEK01GfcbbdYhRFSDhi2vOPabwK6imR2o1H5weeyrQJWSA7uhMBrqGOaE6y9iD2c0bHMZZRabLb32DOvu2dYBEEfiynNW0XAO4ssNuVxgpUKe3Pvh5IU81gaUZAZLewwKgvlWSKmHNxTKGev3eEEvxNuFjjGPJW0wsMWtgyhlKpr687tA(4Nx28CpV4oT6ixbfAoWUvQUcfwSae5TSOZl38ag35LnpaN3nnwEqHSPgdyzrAunphoZlUtRoYvqHSPgdqK3YIoVCZdyCNx28UPXYdkKn1yallsJQ55AEzZdW5vO5a7wP6kuyXcEk2Mv7ssNuVxgpUKSd7u0jAw(AdabXRnxsyzrAuTaZssathHPTKmHNmWowiFI053N08XpVS5vO5a7wP6kuyXcEk2Mv7sI6Wu4RnaCjzcpVAjbjQUj88QUoP(ssNuVxgpUKSd7reqQV81gaUlwBUKWYI0OAbMLKj88QLeKO6MWZR66K6ljbmDeM2sYeEYa7yH8jsNFFsZh)8YMN75b48k0CGDRuDfkSybpfBZQDEzZZ98I70QJCfuO5a7wP6kuyXcqK3YIo)(ZdyCNx28aCE30y5bfYMAmGLfPr18C4mV4oT6ixbfYMAmarEll687ppGXDEzZ7MglpOq2uJbSSinQMNR55AjPtQ3lJhxsTyHWu0Tdx(AdazowBUKWYI0OAbMLKaMoctBjzcpzGDSq(ePZtAEaxsuhMcFTbGljt45vljHP1Dt45vDDs9LKoPEVmECj1IfctXYx(sQfleMIUD4AZ1gaU2CjHLfPr1cmljkkwsI70QJCfOhHUdrRbHbiYBzrxsMWZRwsKT0xscy6imTLKBAS8a9i0DiAnimGLfPr18YM3nyl6bp5XUF9gH3z2oZl387mVS5zZwGEhI8ww053F(DMx28I70QJCfOhHUdrRbHbiYBzrNxU55E(wHAEqK5JByxSZ8CnVS5nHNmWowiFI05LJ08mB5RnIFT5scllsJQfywscy6imTLe3ZdW5zyW0I0yO5oDwTDirLIEZrgHZZHZ8reSSbkHsHvxDhFaIMWNNR5Lnp3ZhrWYgugCB3HwrzpiV55vbIM5LnpKOq2d2IbfAkDIuVlUuhWYI0OAEzZBcpzGDSq(ePZlhP5z28C4mVj8Kb2Xc5tKopP5JFEUwsMWZRwsk0CGDXL6LV2GzRnxsyzrAuTaZssathHPTKIiyzducLcRU6o(aenHpphoZdW5zyW0I0yO5oDwTDirLIEZrgHljt45vljSjviFkw(AdMyT5scllsJQfywskKkGzJNxTKIZSZ7gSf95fXe6SANpPZRsQfPrf4ZtjNUa48rMy78(nVdeNNMvRgzEUbBrF(wSqykMxNuF(SOoAQWsYeEE1scsuDt45vDDs9Le1HPWxBa4ssathHPTKeXeASJfYNiDEsZd4ssNuVxgpUKAXcHPy5Rn2zT5scllsJQfywscy6imTLe3ZlUtRoYvWAoHPJ1qXae5TSOZV)87mVS5vyeblBGfPocZQTt(ikvGOzEoCMxHreSSbwK6imR2o5JOubQBITZV)8mBEUMx28CppB2c07qK3YIoVCZlUtRoYvqHMdSBLQRqHflarEll68ayEaJ78C4mpB2c07qK3YIo)(ZlUtRoYvWAoHPJ1qXae5TSOZZ1sYeEE1sI8ruQoTblfcxsIycn2Dd2IoDTbGlFTbiET5scllsJQfywscy6imTLKcJiyzdSi1rywTDYhrPcu3eBNxosZZS5LnV4oT6ixbR5eMowdfdqK3YIoVCZZS55WzEfgrWYgyrQJWSA7KpIsfOUj2oVCZd4sYeEE1sIfPocZQTtDyUfxsIycn2Dd2IoDTbGlFTXUyT5scllsJQfywscy6imTLK4oT6ixbR5eMowdfdqK3YIo)(ZVZ8YMxHreSSbwK6imR2o5JOubQBITZl38aUKmHNxTKyrQJWSA7uhMBXLKiMqJD3GTOtxBa4YxBWCS2CjHLfPr1cmljbmDeM2sYeEYa7QZdSi1rywTDYhrPMFFsZlIj0yhlKpr68YMxHreSSbwK6imR2o5JOubQBITZl38mXsYeEE1sIfPocZQTtDyUfxskKkGzJNxTK2eysNpPZJSSOWtgOo28SPwJW5jdmfaNNM805b54G08fs4qtd(8re(8uGhHwnFdezGLpVnpvGLbZBEYarioVdeN3uQRMhOrNVohywTZ738quC88yPclF5lFjXaH08Q1gXh34bmUmdqMyjr2GvwT0L0UeSbIUrCEdMlqy(53eioFY3CqFE2doV82HDk6enYppeblIeIQ5PhpoVr4hV5OAEbqRArAyaDxZcNNzGW8m5vmqOJQ5Lhsui7bBXaij)8(nV8qIczpylgaPawwKgvYpp3aUBUcdOdO7sWgi6gX5nyUaH5NFtG48jFZb95zp48YBh2JiGux(5HiyrKqunp94X5nc)4nhvZlaAvlsddO7Aw48accZZKxXaHoQMxEirHShSfdGK8Z738YdjkK9GTyaKcyzrAuj)8Cd4U5kmGoGUlbBGOBeN3G5ceMF(nbIZN8nh0NN9GZlVdZAl6u5NhIGfrcr180JhN3i8J3CunVaOvTinmGURzHZdiimptEfde6OAE5DtJLhaj5N3V5L3nnwEaKcyzrAuj)8Cd4U5kmGoGUlbBGOBeN3G5ceMF(nbIZN8nh0NN9GZlFlwimfYppeblIeIQ5PhpoVr4hV5OAEbqRArAyaDxZcNNzGW8m5vmqOJQ5Lhsui7bBXaij)8(nV8qIczpylgaPawwKgvYpp3aUBUcdOdO7sWgi6gX5nyUaH5NFtG48jFZb95zp48YlogyzLtLFEicwejevZtpECEJWpEZr18cGw1I0Wa6UMfopGGW8m5vmqOJQ5L3nnwEaKKFE)MxE30y5bqkGLfPrL8ZZnG7MRWa6UMfopZaH5zYRyGqhvZlVBAS8aij)8(nV8UPXYdGuallsJk5NNBa3nxHb0DnlCEMbcZZKxXaHoQMxE6rOJYsfaj5N3V5LNEe6OSubqkGLfPrL8ZZnG7MRWa6UMfoptacZZKxXaHoQMxE30y5bqs(59BE5DtJLhaPawwKgvYpp3aUBUcdO7Aw48mbimptEfde6OAE5PhHoklvaKKFE)MxE6rOJYsfaPawwKgvYpp3aUBUcdO7Aw48GyqyEM8kgi0r18Y7MglpasYpVFZlVBAS8aifWYI0Os(55gWDZvyaDaDxc2ar3ioVbZfim)8BceNp5BoOpp7bNxEXDA1rUOYppeblIeIQ5PhpoVr4hV5OAEbqRArAyaDxZcNpEqyEM8kgi0r18Y7MglpasYpVFZlVBAS8aifWYI0Os(55o(DZvyaDxZcNhedcZZKxXaHoQMxE30y5bqs(59BE5DtJLhaPawwKgvYpp3aUBUcdOdO7sWgi6gX5nyUaH5NFtG48jFZb95zp48Y3Ifctr3ou(5HiyrKqunp94X5nc)4nhvZlaAvlsddO7Aw48accZZKxXaHoQMxE30y5bqs(59BE5DtJLhaPawwKgvYpp3aUBUcdO7Aw48XdcZZKxXaHoQMxEirHShSfdGK8Z738YdjkK9GTyaKcyzrAuj)8Cd4U5kmGoGUlbBGOBeN3G5ceMF(nbIZN8nh0NN9GZlVczncTl)8qeSisiQMNE848gHF8MJQ5faTQfPHb0DnlCEMbcZZKxXaHoQMxE30y5bqs(59BE5DtJLhaPawwKgvYpV5Zd2hh3155gWDZvyaDxZcNNjaH5zYRyGqhvZlVBAS8aij)8(nV8UPXYdGuallsJk5NNBa3nxHb0DnlCEqmimptEfde6OAE5DtJLhaj5N3V5L3nnwEaKcyzrAuj)8Cd4U5kmGURzHZVlaH5zYRyGqhvZlVBAS8aij)8(nV8UPXYdGuallsJk5NNBa3nxHb0DnlCEMdqyEM8kgi0r18Y7MglpasYpVFZlVBAS8aifWYI0Os(55o(DZvyaDxZcNpojimptEfde6OAE5HefYEWwmasYpVFZlpKOq2d2IbqkGLfPrL8ZZnG7MRWa6UMfopGXfeMNjVIbcDunV8UPXYdGK8Z738Y7MglpasbSSinQKFEUbC3Cfgq31SW5bChqyEM8kgi0r18Y7MglpasYpVFZlVBAS8aifWYI0Os(55o(DZvyaDxZcNhWDbimptEfde6OAE5DtJLhaj5N3V5L3nnwEaKcyzrAuj)8Ch)U5kmGoGgN5BoOJQ5bmUZBcpVAEDsDAyaDjzeoWdUKKsEcT55vmj0y9Lud8ytnUKyktNhKrZboFCIkBb6ZZCwapDSbuMY05zUBqbW5JpUGpF8XnEahqhqzktNNjbAvlsbHbuMY05zEZd2umFcQZJLtN3V5b5cK3dKr2uJ7bYO5aPZdYe48(n)v6yZloIYN3nyl605jd8M3G484UBqHJQ59BEDYaNxFv78yDeTaN3V55n3r48CBh2POt0mptbKRWaktz68mV5b5KArAunVKjGjBkstpFCWe(8rOWiO48k0uZ3c8i0055TT48ShCEQPMhKJtqddOmLPZZ8MN5KMv787YJOuZl1GLcHZBrPo9ePZZFqCEwnU7mshBEUnFEMaaZtDtSLoFwuhn18h787aaUa7EEqooinFHeo00ZBLAEEl28nqKbw(80JhNVoMhefZttNW88kAyaLPmDEM38mN0SANhSlK6imR25LCyUfNpR5bBXrW(5t25JDeZd0yGZxNdmR25rnfN3V5v38wPMN8vY7ZFmqOWAMN8ruk68jDEqooinFHeo00HbuMY05zEZZKaTQfvZZBvS5LNnBb6DiYBzrLFEXvQ0ZRmnDE)M3AA0XMpR5JokDE2SfOtN)kDS55wJu68mjippzJ648xnVdnkqUcdOmLPZZ8MFZ4iihhbH5NFdK88omRTOpVaMoctlmGoGAcpVIgAGO44JmhaK2R588Qbut45v0qdefhFK5aG0EqlPyxHMAaLPmDEWEgMMWCKoVnVdZAl605f3Pvh5c85vjJuHQ5JInptSty(nbM05jB05fapkwZB05jkGNo28Kp4w68xnptSZ8uuCLA(ici1NxetOrk4Zhr4Zd0OZ73npVvXMxOGZJSSOWPZ738TjdCEBEXDA1rUc7oOiGMNxnVkzK0doFwuhnvy(4m78PlpDEgMMaNhOrNVU5HiVLLcHZdrNawZdi4ZJAkopeDcynFCd7egqzktN3eEEfn0arXXhzoaiThddMwKgbVmEKKdZAl6Da70yLa8RHef9KfCgMMajbi4mmnb2rnfjf3WoGlUsLEEfjhM1w0dagaA0obf7reSSY42HzTf9aGbXDA1rUckcO55vGDa7We7qkUCnGYuMoVj88kAObIIJpYCaqApggmTincEz8ijhM1w07X3PXkb4xdjk6jl4mmnbscqWzyAcSJAkskUHDaxCLk98ksomRTOhIpa0ODck2JiyzLXTdZAl6H4dI70QJCfueqZZRa7a2Hj2HuC5AaLPmDEWEQN8MJ05T5DywBrNopdttGZhfBEXX3yWSAN3bIZlUtRoY18h78oqCEhM1w0bFEvYivOA(OyZ7aX5veqZZRM)yN3bIZhrWYoF6Z3apgPcPH5JtB05T5PoeRwh488NkzteoVFZ3MmW5T5bMTar48nW8GPhBE)MN6qSADGZ7WS2Iof85n68KrTEEJoVnp)Ps2eHZZEW5t25T5DywBrFEYPwp)bNNCQ1ZxNppnwjMNC6aNxCNwDKlAyaLPmDEt45v0qdefhFK5aG0EmmyArAe8Y4rsomRTO3BG5btpg4xdjk6jl4mmnbskEWzyAcSJAkscqWfxPspVIeaDywBrpayaOr7euShrWYkZHzTf9q8bGgTtqXEebllhoomRTOhIpa0ODck2JiyzLXn3omRTOhIpiUtRoYvqranpVcSJdZAl6H4dnWteSkwx1qdkcO55vCbIWnGHDaGdZAl6H4danApIGLLlqeUzyW0I0yWHzTf9E8DASsWfx7Zn3omRTOhamiUtRoYvqranpVcSJdZAl6badnWteSkwx1qdkcO55vCbIWnGHDaGdZAl6badanApIGLLlqeUzyW0I0yWHzTf9oGDASsWfxdOdOdOmLPZd2VBuq4OAEKbcJnVN848oqCEt4hC(KoVXWsTfPXWaQj88kkj(SuDwiIm3WbuMoFCaImWYNN2GIKnr18omRTOtNpcZQDEckQMNC6aN3i8J38umVolKoGAcpVIcas7XWGPfPrWlJhjrBqrYMOQ7WS2Io4mmnbsIBeSiYMgufYIkGeUfPXoyryLtW3viJuGYe3Pvh5kKfvajClsJDWIWkNGVRqgPadq0uX4AaLPmD(4ugmTinshqnHNxrbaP9yyW0I0i4LXJKAUtNvBhsuPO3CKri4mmnbssCNwDKRaLGN)QERbBVyAmarEllQC7iZnnwEGsWZFvV1GTxmnoGAcpVIcas7XWGPfPrWlJhj1CNoR2oKOqk4mmnbsYnnwEGEe6oeTgekdsuOCXlZnyl6bp5XUF9gH3z2oYTJm2SfO3HiVLfD)DgqnHNxrbaP9yyW0I0i4LXJKOEVrBvLvl4mmnbsYeEYa7yH8jsjbOmUbi0svhzGLhmLIgWDNuNYHd0svhzGLhmLIgYAFa3HRbut45vuaqApggmTincEz8ijEJ5FWU4oT6ix0Uj8KbcodttGKAqp0AW2lMgdMWtgihoreSSbIc4PJ1nk1i0EGOHdh30y5bdYhRFSDhi2vgFHkznOhSMt0BbEe6Gj8KbYHteblBqzWTDhAfL9G8MNxfiAgqz68m3TSClRSANpovcj0y5Zhh0wlboFsN3MVbMhm9ydOMWZROaG0EhHhbrBl4jlj15bgjKqJL3B0wlbgGilePaTinkdGUPXYdefWthRhPZwGUmacTu1rgy5btPObC3j1PdOMWZROaG0EhHhbrBl4jlj15bgjKqJL3B0wlbgGilePaTinkZeEYa7yH8js3Nu8Y4gGUPXYdefWthRhPZwGohoUPXYdefWthRhPZwGUmXDA1rUcefWthRhPZwGEaI8wwuUgqnHNxrbaP9ocpcI2wWtwsqIczpylgOeniK6qllzCRopWcpQ3zrgimarwisbArAKdh15Hi9DQEJ2AjWaezHifOfPrUgqnHNxrbaP9iBPdoffKe3Pvh5kqpcDhIwdcdqK3YIcEYsYnnwEGEe6oeTgekZnyl6bp5XUF9gH3z2oYTJm2SfO3HiVLfD)DKjUtRoYvGEe6oeTgegGiVLfvoUBfkqK4g2f7WLmt4jdSJfYNiLeGdOmDEWMWZRMFxtQtN3k18XXgSqiDEUJJnyHq6EsiyrGLaPZtuuIMMd6OA(SM3uQRcCnGAcpVIcas7jmTUBcpVQRtQdEz8ijhM1w0PdOMWZROaG0EctR7MWZR66K6GxgpssCmWYkNoGAcpVIcas7jmTUBcpVQRtQdEz8ijOjstthqz68MWZROaG0EueSiWsGGNSKmHNmWowiFIusakdGk0CG9Tv2c0dQKArASBNRaVmEK01GfcbbdYhRFSDhi2vOPabwK6imR2o1H5weeyrQJWSA7uhMBrqGOaE6y9iD2c0bHMZZRabLb32DOvu2dYBEEfiynNW0XAO4aQj88kkaiTNW06Uj88QUoPo4LXJKe3Pvh5IoGAcpVIcas7bjQUj88QUoPo4LXJKSd7u0jAapzjzcpzGDSq(eP7tkEzClUtRoYvqHMdSBLQRqHflarEllQCagxza0nnwEqHSPg5WrCNwDKRGcztngGiVLfvoaJRm30y5bfYMAKlzauHMdSBLQRqHfl4PyBwTdOMWZROaG0EqIQBcpVQRtQdEz8ij7WEebK6GtDykCsacEYsYeEYa7yH8js3Nu8YuO5a7wP6kuyXcEk2Mv7aQj88kkaiThKO6MWZR66K6GxgpsQfleMIUDi4jljt4jdSJfYNiDFsXlJBaQqZb2Ts1vOWIf8uSnRwzClUtRoYvqHMdSBLQRqHflarEll6(agxza0nnwEqHSPg5WrCNwDKRGcztngGiVLfDFaJRm30y5bfYMAKlUgqnHNxrbaP9eMw3nHNx11j1bVmEKulwimfGtDykCsacEYsYeEYa7yH8jsjb4a6aktz68GTdSFEWqaP(aQj88kAWoShraPojfAoWU4sn4jljUJiyzducLcRU6o(aenHZHdazyW0I0yO5oDwTDirLIEZrgHCjJ7icw2GYGB7o0kk7b5npVkq0idsui7bBXGcnLorQ3fxQLzcpzGDSq(ePYrIzC4ycpzGDSq(ePKINRbut45v0GDypIasDaqApSjviFkapzjbjQu0BoYimOq2uKUCCdyCbGcnhyFBLTa9al5JOuOQ7gSfDkicZ4sMcnhyFBLTa9al5JOuOQ7gSfDQCGyzaKHbtlsJHM70z12Hevk6nhzeYHteblBGs2G8z125tQhiAgqnHNxrd2H9ici1baP9WMuH8Pa8KLeKOsrV5iJWGcztr6Yf)oYuO5a7BRSfOhyjFeLcvD3GTOt3FhzaKHbtlsJHM70z12Hevk6nhzeoGAcpVIgSd7reqQdas7HnPc5tb4jljaQqZb23wzlqpWs(ikfQ6UbBrNkdGmmyArAm0CNoR2oKOsrV5iJqoCyZwGEhI8wwu52HdhOLQoYalpykfnG7oPovg0svhzGLhmLIgGiVLfvUDgqnHNxrd2H9ici1baP9iFeLQtBWsHWbut45v0GDypIasDaqApSjviFkapzjbqggmTingAUtNvBhsuPO3CKr4a6aktz68GTdSFEj0jAgqnHNxrd2HDk6enKSkwxvkWtwsk0CG9Tv2c0dSKpIsHQUBWw0P7tsetOXowiFIuoCGwQ6idS8GPu0aU7K6uzqlvDKbwEWukAaI8wwu5ibiGdOMWZROb7WofDIgaqApRI1vLc8KLKcnhyFBLTa9al5JOuOQ7gSfD6(K2za1eEEfnyh2POt0aas7PqZb2fxQbpzjbqggmTingAUtNvBhsuPO3CKrOmUJiyzdkdUT7qROShK388QarJmirHShSfdk0u6ePExCPwMj8Kb2Xc5tKkhjMXHJj8Kb2Xc5tKskEUgqnHNxrd2HDk6enaG0EytQq(uaEYscGmmyArAm0CNoR2oKOsrV5iJWbut45v0GDyNIordaiThlsDeMvBN6WClcUiMqJD3GTOtjbi4jljfgrWYgyrQJWSA7KpIsfOUj2khjMjtCNwDKRG1CcthRHIbiYBzrLJzdOMWZROb7WofDIgaqApwK6imR2o1H5weCrmHg7UbBrNscqWtwskmIGLnWIuhHz12jFeLkqDtSvoahqnHNxrd2HDk6enaG0ESi1rywTDQdZTi4Iycn2Dd2IoLeGGNSKuyeblBGfPocZQTt(ikvG6MyRCKyMmirHbp5XUFDMqoXDA1rUcwfRRkvaI8ww0buMo)UeiwZ7gSf95PKTg68geNxLulsJkWN3bM05jNA98A0Np2rmpTbl18qIcP7r(ikfD(SOoAQ5p25jBPNv78ShCEqUa59azKn14EGmAoq5PZdYeyya1eEEfnyh2POt0aas7r(ikvN2GLcHGNSK4gGu09SAPbrmHg5WrHMdSVTYwGEGL8ruku1Dd2IoDFsIycn2Xc5tKYLmfgrWYgyrQJWSA7KpIsfOUj2UpZKbjkm4jp29RZm5e3Pvh5kyvSUQubiYBzrhqhqzktNpoCEE1aQj88kAqCNwDKlkPMZZRapzjXWGPfPXaVX8pyxCNwDKlA3eEYa5Wj6OuzSzlqVdrEllQCXdIhqzktNNjVtRoYfDa1eEEfniUtRoYffaK2ZG8X6hB3bIDfAkWtwsI70QJCfikGNowpsNTa9ae5TSOYTJmXDA1rUckdUT7qROShK388Qae5TSODC3nOWrLC7iZnnwEGOaE6y9iD2c05WbGUPXYdefWthRhPZwGohorhLkJnBb6DiYBzrLJz7mGAcpVIge3Pvh5Icas7rpcDhIwdcbxetOXUBWw0PKae8KLKBWw0dEYJD)6ncVZSDKBhzUbBrp4jp29RRsC)DKzcpzGDSq(ePYrIzdOmD(40NwrNhm6SfOpp7bNNOzE)MFN5PO4kfDE)MNgReZtoDGZd2AoHPJ1qrWNpo6ari5KIGppbfNNC6aNhKn4253eAfL9G8MNxfgqnHNxrdI70QJCrbaP9ikGNowpsNTaDWtwsmmyArAmq9EJ2QkRwzClUtRoYvWAoHPJ1qXae5TSODC3nOWrLC7WHJ4oT6ixbR5eMowdfdqK3YI2XD3Gchv7dyC5sg3I70QJCfugCB3HwrzpiV55vbiYBzrLRvO4WjIGLnOm42UdTIYEqEZZRcenCnGAcpVIge3Pvh5Icas7ruapDSEKoBb6GNSKmHNmWowiFI09jfphorhLkJnBb6DiYBzrLlEahqnHNxrdI70QJCrbaP9ugCB3HwrzpiV55vGNSKyyW0I0yG69gTvvwTY4wDEGOaE6y9iD2c07QZdqK3YIYHdaDtJLhikGNowpsNTaDUgqnHNxrdI70QJCrbaP9ugCB3HwrzpiV55vGNSKmHNmWowiFI09jfphorhLkJnBb6DiYBzrLlEahqnHNxrdI70QJCrbaP9SMty6ynue8KLKj8Kb2Xc5tKscqzkmIGLnWIuhHz12jFeLkqDtSDFMnGAcpVIge3Pvh5Icas7znNW0XAOi4Iycn2Dd2IoLeGGNSKmHNmWowiFI09jfVmfgrWYgyrQJWSA7KpIsfOUj2UpZKbqfAoWUvQUcfwSGNITz1oGAcpVIge3Pvh5Icas7rj45VQ3AW2lMgbpzjbjQu0BoYimOq2uKUCaYeY4wCNwDKRarb80X6r6SfOhGiVLfvoaJlhoQZdefWthRhPZwGExDEaI8wwuUgqnHNxrdI70QJCrbaP9ikGNow3OuJq7GNSKyyW0I0yG69gTvvwTYuyeblBGfPocZQTt(ikvG6MyRCXlJ7g0dwZj6TapcDWeEYa5WjIGLnOm42UdTIYEqEZZRcenYayd6bdYhR3c8i0bt4jdKRbut45v0G4oT6ixuaqApIc4PJ1nk1i0o4Iycn2Dd2IoLeGGNSKmHNmWowiFI09jfVmfgrWYgyrQJWSA7KpIsfOUj2kx8dOMWZRObXDA1rUOaG0EqlPyxHMc8KLeaBqp0c8i0bt4jdCaLPmDEqoPwKgvGppZNG6ZxNppenTo281b5n98riqJrEW5DGMlpDEYh0boFdbKsKv78zX8AnEmmGYuMoVj88kAqCNwDKlkaiTh1eWKnfPP7nMWbpzjzcpzGDSq(eP7tkEzamIGLnOm42UdTIYEqEZZRcenYaO4oT6ixbLb32DOvu2dYBEEvaIMkghorhLkJnBb6DiYBzrLRvOgqhqzktNNjpgyzLppylk1PNiDa1eEEfniogyzLtjrjBq(SA78j1bpzjXWGPfPXa17nARQSALbjQu0BoYimOq2uK((acILXT4oT6ixbR5eMowdfdqK3YIYHdaDtJLhmiFS(X2DGyxz8fQKjUtRoYvqzWTDhAfL9G8MNxfGiVLfLloCIokvgB2c07qK3YIkhGaoGY05LqFE)MNGIZBSocN3AoX8jD(RMNjb55n68(nFdezGLp)XaHcRPjR25brJdZtgyQX5PO7z1oprZ8mjilpDa1eEEfniogyzLtbaP9OKniFwTD(K6GNSKe3Pvh5kynNW0XAOyaI8wwuzCBcpzGDSq(eP7tkEzMWtgyhlKprQCK2rgKOsrV5iJWGcztr67dyCba3MWtgyhlKprkiciMloCmHNmWowiFI093rgKOsrV5iJWGcztr67ZeXLRbut45v0G4yGLvofaK2ZIo(SmpVQRt(iWtwsmmyArAmq9EJ2QkRwzaKEe6OSubnAQEuSoUBJVrJY4wCNwDKRG1CcthRHIbiYBzr5WbGUPXYdgKpw)y7oqSRm(cvYe3Pvh5kOm42UdTIYEqEZZRcqK3YIYLmirHbp5XUFDMyFUzgaIiyzdqIkfDXbHenEEvaI8wwuU4Wj6OuzSzlqVdrEllQCXd4aQj88kAqCmWYkNcas7zrhFwMNx11jFe4jljggmTingOEVrBvLvRm6rOJYsf0OP6rX64Un(gnkJB15bIc4PJ1J0zlqVRoparEll6(acihoa0nnwEGOaE6y9iD2c0LjUtRoYvqzWTDhAfL9G8MNxfGiVLfLRbut45v0G4yGLvofaK2ZIo(SmpVQRt(iWtwsMWtgyhlKpr6(KIxgKOWGN8y3VotSp3mdareSSbirLIU4GqIgpVkarEllkxdOMWZRObXXalRCkaiThfOj2QXUde7ef5d6aJbEYsIHbtlsJbQ3B0wvz1kJBXDA1rUcwZjmDSgkgGiVLfLdha6Mglpyq(y9JT7aXUY4lujtCNwDKRGYGB7o0kk7b5npVkarEllkxC4eDuQm2SfO3HiVLfvoa3za1eEEfniogyzLtbaP9OanXwn2DGyNOiFqhymWtwsMWtgyhlKpr6(KIxg3k0CGDRuDfkSybpfBZQLdhOLQoYalpykfnarEllQCKaKj4AaDaLPmDEPSA148BAWw0hqnHNxrdTyHWuqsHMdSlUudEYskIGLnqjukS6Q74dq0eUmaYWGPfPXqZD6SA7qIkf9MJmc5WPb9qRbBVyAmycpzGdOMWZROHwSqykaaP9uO5a7Il1GNSKGevk6nhzeguiBksxoazghoSzlqVdrEllQC7idGkmIGLnWIuhHz12jFeLkq0mGAcpVIgAXcHPaaK2ZQyDvPapzjjUtRoYvWAoHPJ1qXae5TSOY42nnwEqHSPgdyzrAuXHJ4yGLvEOYwGEN1qoCGefYEWwm0aen4XFfs5sg3aKHbtlsJHM70z12Hefs5WHnBb6DiYBzrLBhUgqnHNxrdTyHWuaas7r(ikvN2GLcHGNSKuyeblBGfPocZQTt(ikvG6My7(mtgazyW0I0yO5oDwTDirH0but45v0qlwimfaG0EKpIs1PnyPqi4jljfgrWYgyrQJWSA7KpIsfiAKjUtRoYvWAoHPJ1qXae5TSODC3nOWr1(7idGmmyArAm0CNoR2oKOq6aQj88kAOfleMcaqApfAoWU4sn4jljirLIEZrgHbfYMI0Ll(4kdGmmyArAm0CNoR2oKOsrV5iJWbut45v0qlwimfaG0ESi1rywTDQdZTi4jljfgrWYgyrQJWSA7KpIsfOUj2khGYaiddMwKgdn3PZQTdjkKoGAcpVIgAXcHPaaK2JfPocZQTtDyUfbpzjPWicw2alsDeMvBN8ruQa1nXw5yczI70QJCfSMty6ynumarEllAh3DdkCuj3oYaiddMwKgdn3PZQTdjkKoGAcpVIgAXcHPaaK2tHMdSlUudEYscGmmyArAm0CNoR2oKOsrV5iJWb0buMY05zUWcHPyEW2b2pFCaMhm9ydOMWZROHwSqyk62HKiBPdoffKe3Pvh5kqpcDhIwdcdqK3YIcEYsYnnwEGEe6oeTgekZnyl6bp5XUF9gH3z2oYTJm2SfO3HiVLfD)DKjUtRoYvGEe6oeTgegGiVLfvoUBfkqK4g2f7WLmt4jdSJfYNivosmBa1eEEfn0Ifctr3oeaK2tHMdSlUudEYsIBaYWGPfPXqZD6SA7qIkf9MJmc5WjIGLnqjukS6Q74dq0eoxY4oIGLnOm42UdTIYEqEZZRcenYGefYEWwmOqtPtK6DXLAzMWtgyhlKprQCKyghoMWtgyhlKprkP45Aa1eEEfn0Ifctr3oeaK2dBsfYNcWtwsreSSbkHsHvxDhFaIMW5WbGmmyArAm0CNoR2oKOsrV5iJWbuMoFCMDE3GTOpViMqNv78jDEvsTinQaFEk50faNpYeBN3V5DG480SA1iZZnyl6Z3IfctX86K6ZNf1rtfgqnHNxrdTyHWu0TdbaP9Gev3eEEvxNuh8Y4rsTyHWuao1HPWjbi4jljrmHg7yH8jsjb4aQj88kAOfleMIUDiaiTh5JOuDAdwkecUiMqJD3GTOtjbi4jljUf3Pvh5kynNW0XAOyaI8ww093rMcJiyzdSi1rywTDYhrPcenC4OWicw2alsDeMvBN8ruQa1nX29zgxY4MnBb6DiYBzrLtCNwDKRGcnhy3kvxHclwaI8wwuaayC5WHnBb6DiYBzr3xCNwDKRG1CcthRHIbiYBzr5Aa1eEEfn0Ifctr3oeaK2JfPocZQTtDyUfbxetOXUBWw0PKae8KLKcJiyzdSi1rywTDYhrPcu3eBLJeZKjUtRoYvWAoHPJ1qXae5TSOYXmoCuyeblBGfPocZQTt(ikvG6MyRCaoGAcpVIgAXcHPOBhcas7XIuhHz12Pom3IGlIj0y3nyl6usacEYssCNwDKRG1CcthRHIbiYBzr3FhzkmIGLnWIuhHz12jFeLkqDtSvoahqz68BcmPZN05rwwu4jduhBE2uRr48KbMcGZttE68GCCqA(cjCOPbF(icFEkWJqRMVbImWYN3MNkWYG5npzGieN3bIZBk1vZd0OZxNdmR259BEikoEESuHbut45v0qlwimfD7qaqApwK6imR2o1H5we8KLKj8Kb2vNhyrQJWSA7KpIsTpjrmHg7yH8jsLPWicw2alsDeMvBN8ruQa1nXw5yIb0buMopiQjstthqnHNxrdqtKMMsYGcRWUFqiwo4jljirLIEZrgHbfYMI03heVJmUBqp0AW2lMgdMWtgihoa0nnwEGsWZFvV1GTxmngWYI0OIlzqIcdkKnfPVpPDgqnHNxrdqtKMMcas7fPVt1zjGXapzjXWGPfPXaVX8pyxCNwDKlA3eEYa5WXnyl6bp5XUFDvIYrkIGLnePVt1zjGXckcO55vdOMWZRObOjsttbaP9IqifHBZQf8KLeddMwKgd8gZ)GDXDA1rUODt4jdKdh3GTOh8Kh7(1vjkhPicw2qecPiCBwTbfb088Qbut45v0a0ePPPaG0E6SfOt7mFcvlpwo4jlPicw2arb80X6uhIvRdmq0mGY05bBLaPo00ZZKMwpVWQ5Dy22IW5zI5Bohlpn98reSSuWNhnbW51g1ZQDEa3zEkkUsrdZZC6PozUHQ5bAq18ItHQ59KhN3OZBZ7WSTfHZ738BrSz(0NhIMYI0yya1eEEfnanrAAkaiTNvcK6qt3fMwdEYsIHbtlsJbEJ5FWU4oT6ix0Uj8KbYHJBWw0dEYJD)6QeLJeG7mGAcpVIgGMinnfaK2ZGcRWEdHMIGNSKmHNmWowiFI09jfphoCdjkmOq2uK((K2rgKOsrV5iJWGcztr67tcehxUgqnHNxrdqtKMMcas7XMqmsFNc8KLeddMwKgd8gZ)GDXDA1rUODt4jdKdh3GTOh8Kh7(1vjkhPicw2aBcXi9DQGIaAEE1aQj88kAaAI00uaqAViRTFSDhMITuWtwsreSSbIc4PJ1PoeRwhyGOrMj8Kb2Xc5tKscWb0buMY053eM1w0PdOMWZRObhM1w0PKiOypDKh8Y4rszrfqc3I0yhSiSYj47kKrkqWtwsClUtRoYvGOaE6y9iD2c0dqK3YIYHJ4oT6ixbLb32DOvu2dYBEEvaI8wwuUKXDd6bdYhR3c8i0bt4jdKdNg0dwZj6TapcDWeEYaLbq30y5bdYhRFSDhi2vgFHkoCCd2IEWtES7xVr494JRC7WfhorhLkJnBb6DiYBzrLlEahqnHNxrdomRTOtbaP9iOypDKh8Y4rs8MWIGyNcerVZtqtb4jljXDA1rUcwZjmDSgkgGiVLfvUDKXnarWIiBAqvilQas4wKg7GfHvobFxHmsbYHJ4oT6ixHSOciHBrASdwew5e8DfYifyaI8wwuU4Wj6OuzSzlqVdrEllQCXd4aQj88kAWHzTfDkaiThbf7PJ8GxgpssbrtXMqSZaPuudEYssCNwDKRG1CcthRHIbiYBzrLXnarWIiBAqvilQas4wKg7GfHvobFxHmsbYHJ4oT6ixHSOciHBrASdwew5e8DfYifyaI8wwuU4Wj6OuzSzlqVdrEllQCmBa1eEEfn4WS2IofaK2JGI90rEWlJhjPm4w(7QUcfB7moOjspg4jljXDA1rUcwZjmDSgkgGiVLfvg3aeblISPbvHSOciHBrASdwew5e8DfYifihoI70QJCfYIkGeUfPXoyryLtW3viJuGbiYBzr5IdNOJsLXMTa9oe5TSOYfpGdOMWZRObhM1w0PaG0EeuSNoYtbpzjXT4oT6ixbR5eMowdfdqK3YIYHteblBqzWTDhAfL9G8MNxfiA4sg3aeblISPbvHSOciHBrASdwew5e8DfYifihoI70QJCfYIkGeUfPXoyryLtW3viJuGbiYBzr5AaLPmD(nJJGCCeegqzktNFtG48omRTOpp50boVdeNhy2ceP(8i1tEZr18mmnbc(8KtTE(iCEckQMNnHuFERuZ3yjevZtoDGZd2AoHPJ1qX55ozNpIGLD(KopG7mpffxPOZFW51iLY18hCEWOZwG(EG8MZZDYoFlenhHZ7aTAEa3zEkkUsr5AaLPmDEt45v0GdZAl6uaqApck2th5bNQpNKdZAl6acEYscGmmyArAmqBqrYMOQ7WS2IUmU52HzTf9aGHg4jcwfRRAObfb088k5ib4oYe3Pvh5kynNW0XAOyaI8ww09JpUC44WS2IEaWqd8ebRI1vn0GIaAEE1(aUJmUf3Pvh5kquapDSEKoBb6biYBzr3p(4YHJ4oT6ixbLb32DOvu2dYBEEvaI8ww09JpUCXLmUbOdZAl6H4danAxCNwDKloCCywBrpeFqCNwDKRae5TSOC4WWGPfPXGdZAl69gyEW0JrcqU4IdhhM1w0dagAGNiyvSUQHgueqZZR2NeB2c07qK3YIoGYuMoVj88kAWHzTfDkaiThbf7PJ8Gt1NtYHzTf94bpzjbqggmTingOnOiztu1DywBrxg3C7WS2IEi(qd8ebRI1vn0GIaAEELCKaChzI70QJCfSMty6ynumarEll6(XhxoCCywBrpeFObEIGvX6QgAqranpVAFa3rg3I70QJCfikGNowpsNTa9ae5TSO7hFC5WrCNwDKRGYGB7o0kk7b5npVkarEll6(XhxU4sg3a0HzTf9aGbGgTlUtRoYfhoomRTOhamiUtRoYvaI8wwuoCyyW0I0yWHzTf9Edmpy6XifpxCXHJdZAl6H4dnWteSkwx1qdkcO55v7tInBb6DiYBzrhqzktNpoZo)v6yZFfo)vZtqX5DywBrF(g4XiviDEB(icwwWNNGIZ7aX5phicN)Q5f3Pvh5kmFCeoFYoFHPdeHZ7WS2I(8nWJrQq6828reSSGppbfNp6CGZF18I70QJCfgqzktN3eEEfn4WS2IofaK2JGI90rEWP6Zj5WS2IoGGNSKaOdZAl6badanANGI9icwwzC7WS2IEi(G4oT6ixbiYBzr5WbGomRTOhIpa0ODck2Jiyz5AaLPmDEt45v0GdZAl6uaqApck2th5bNQpNKdZAl6XdEYscGomRTOhIpa0ODck2JiyzLXTdZAl6badI70QJCfGiVLfLdha6WS2IEaWaqJ2jOypIGLLRLV81ca]] )

end
