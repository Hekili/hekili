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


    spec:RegisterPack( "Unholy", 20210314, [[dav3)bqifv9iuKUKIIQ2er5tevnkujNcf1QaeQxbqMfq1TiQu2fv(LIkdtrHJbGLrvLNruX0ak5AkI2gGO(MIIyCevQ6COiKwNIsEhkcrZdvQ7Hi7dG6GOiyHafpefrteOuxKOsLpIIqnsuecNurrzLaQxsujPzci4MevsStQQ6NkksdfqilfqKEkrMQIWvvuuzRevs1xbeXybKSxf(RKgSQomLftvEmHjtQldTzu6Zs0ObYPfTAIkXRvKMnj3gvTBP(TkdxchhqQLd65inDHRJW2rHVJOgVIsDEQkRNOskZhvSFLEaWyIHK2cC4VFZWpaMHCaaSC(ndWsoZaSgsHVcCivyIPwjoKAJhhsZCnOt5Bivy(uNPhtmKOhbuGdjqruqN1CZvMbicpN44NJM8eklYRfqJnMJM8I5gsEePkMz9WBiPTah(73m8dGzihaalNFZaS8dSyIoKOfOy4VFt63qcuQ1yp8gsAKkgsGnAbO9LR2zjOy)zUg0P8TalxXGcq7dayb(((nd)aybEbMjbzDjsN1cSCBFMGwUqqdESd6(XTpy3G9CGnYMkCoWgTaeDFWMa3pU9Vw5BFXr0X(HblXGUpzq3(ge3hNDbkcuVFC7Rsg4(QRl3h7JOe0(XTpVfbc3Nl7WkfdII9zkam7wGLB7d2j18uOEFjtat2uKMAFGite77HcJGI7RrtVFjOJqr3N3MI7ZEW9PMEFWwUk1Tal32FMJMD5(ajhrR3xQaBnc338svgjs3N)G4(SkC2PNY3(CzX(GfG2NgMykD)SPbA69p29NeqmZe5(GnqK0(nseqtTV1695nF7xargyh7tpEC)(KBquSpndclYRPUfy52(mjiRlr9(8w7BF5zZsqrfI8w2u53xCToJ8Atr3pU9TIcLV9ZEFVJs3Nnlbf09Vw5BFUuiLUptc27t2ObU)17hqJcIz3cSCB)jMPG9mDw7VV)i59dy2tXyFbmdeMMBiPsAqhtmKSdRumikgtm8hGXedjSnpfQhGzijGzGW0gsA0cq1PDwckCSKpIwJ6AyWsmO7dys7l8juyfBKpr6(C4Sp0sDfzGD4mTM6WzN0GUVS9HwQRidSdNP1uhe5TSP7ZnP9baGHKjI86HK1(Q6wpIH)(nMyiHT5Pq9amdjbmdeM2qsJwaQoTZsqHJL8r0AuxddwIbDFatA)jhsMiYRhsw7RQB9ig(lNXedjSnpfQhGzijGzGW0gsZVpddMMNcDf3PYUScj6uuloYiCFz7Z1(EeSSoTbNwdO1u2dYBrETJOyFz7djAK9GLOtJMwLinQIlvoSnpfQ3x2(MisgyfBKpr6(CtAF5Spho7BIizGvSr(eP7tAF)2N5HKjI86HKgTauvCPAed)bRXedjSnpfQhGzijGzGW0gsZVpddMMNcDf3PYUScj6uuloYiCizIiVEiHfPg5tXig(p5yIHe2MNc1dWmKmrKxpKyrAGWSlR0aMtXHKaMbctBiPrpcwwhlsdeMDzL8r0AhnmX095M0(YzFz7lUtPpYTZkoHP8vqrhe5TSP7Z9(Yzij8juynmyjg0H)amIH)a5XedjSnpfQhGzizIiVEiXI0aHzxwPbmNIdjbmdeM2qsJEeSSowKgim7Yk5JO1oAyIP7Z9(amKe(ekSggSed6WFagXW)zYyIHe2MNc1dWmKmrKxpKyrAGWSlR0aMtXHKaMbctBiPrpcwwhlsdeMDzL8r0AhnmX095M0(YzFz7djA0fjpwJRcw7Z9(I7u6JC7S2xv3Ahe5TSPdjHpHcRHblXGo8hGrm8xUFmXqcBZtH6bygsMiYRhsKpIwxPfyRr4qsJubmlI86HeqciS3pmyjg7tjBf09niUVoPMNc1GVFakP7tovQ9vySVVJyFAb269HensNJ8r0A6(ztd007FS7t2Yi7Y9zp4(GDd2Zb2iBQW5aB0cqYt3hSjq3qsaZaHPnK4A)53NIrKDj1j8ju4(C4SVgTauDANLGchl5JO1OUggSed6(aM0(cFcfwXg5tKUpZ7lBFn6rWY6yrAGWSlRKpIw7OHjMUpG3xo7lBFirJUi5XACv5Sp37lUtPpYTZAFvDRDqK3YMoIrmKSdREeqAmMy4paJjgsyBEkupaZqsaZaHPnK4AFpcwwhLqRXUQVJ3brte7ZHZ(ZVpddMMNcDf3PYUScj6uuloYiCFM3x2(CTVhblRtBWP1aAnL9G8wKx7ik2x2(qIgzpyj60OPvjsJQ4sLdBZtH69LTVjIKbwXg5tKUp3K2xo7ZHZ(MisgyfBKpr6(K23V9zEizIiVEiPrlavfxQgXWF)gtmKW28uOEaMHKaMbctBibj6uuloYi0Pr2uKX(CVpx7dWm2hq7RrlavN2zjOWXs(iAnQRHblXGUpq8(YzFM3x2(A0cq1PDwckCSKpIwJ6AyWsmO7Z9(a59LT)87ZWGP5PqxXDQSlRqIof1IJmc3NdN99iyzDuYgKp7YkFsdhrXqYerE9qclsnYNIrm8xoJjgsyBEkupaZqsaZaHPnKGeDkQfhze60iBkYyFU33Vj3x2(A0cq1PDwckCSKpIwJ6AyWsmO7d49NCFz7p)(mmyAEk0vCNk7YkKOtrT4iJWHKjI86HewKAKpfJy4pynMyiHT5Pq9amdjbmdeM2qA(91OfGQt7Seu4yjFeTg11WGLyq3x2(ZVpddMMNcDf3PYUScj6uuloYiCFoC2NnlbfviYBzt3N79NCFoC2hAPUImWoCMwtD4StAq3x2(ql1vKb2HZ0AQdI8w2095E)jhsMiYRhsyrQr(umIH)toMyizIiVEir(iADLwGTgHdjSnpfQhGzed)bYJjgsyBEkupaZqsaZaHPnKMFFggmnpf6kUtLDzfs0POwCKr4qYerE9qclsnYNIrmIHuaZEkg0Xed)bymXqcBZtH6bygsMiYRhsztfqIW8uyfOjSoi4RAKrkWHKaMbctBiX1(I7u6JC7iAqNYx1tLLGche5TSP7ZHZ(I7u6JC70gCAnGwtzpiVf51oiYBzt3N59LTpx7xGHZG8(QLGocLZerYa3NdN9lWWzfNOwc6iuotejdCFz7p)(HPWoCgK3x9yRbiSQn(g1oSnpfQ3NdN9ddwIHlsESgxTqev)MX(CV)K7Z8(C4SV3rP7lBF2SeuuHiVLnDFU33pagsTXJdPSPciryEkSc0ewhe8vnYif4ig(73yIHe2MNc1dWmKmrKxpK4nH5bXkfeIrLNGMIHKaMbctBijUtPpYTZkoHP8vqrhe5TSP7Z9(tUVS95A)53hbAISOa1USPciryEkSc0ewhe8vnYif4(C4SV4oL(i3USPciryEkSc0ewhe8vnYifOdI8w209zEFoC237O09LTpBwckQqK3YMUp377hadP24XHeVjmpiwPGqmQ8e0umIH)YzmXqcBZtH6bygsMiYRhsAiAA2eIvgiLIQHKaMbctBijUtPpYTZkoHP8vqrhe5TSP7lBFU2F(9rGMilkqTlBQaseMNcRanH1bbFvJmsbUpho7lUtPpYTlBQaseMNcRanH1bbFvJmsb6GiVLnDFM3NdN99okDFz7ZMLGIke5TSP7Z9(Yzi1gpoK0q00SjeRmqkfvJy4pynMyiHT5Pq9amdjte51djTbNYFxx1OyALXbnrg(gscygimTHK4oL(i3oR4eMYxbfDqK3YMUVS95A)53hbAISOa1USPciryEkSc0ewhe8vnYif4(C4SV4oL(i3USPciryEkSc0ewhe8vnYifOdI8w209zEFoC237O09LTpBwckQqK3YMUp377hadP24XHK2Gt5VRRAumTY4GMidFJy4)KJjgsyBEkupaZqsaZaHPnK4AFXDk9rUDwXjmLVck6GiVLnDFoC23JGL1Pn40AaTMYEqElYRDef7Z8(Y2NR9NFFeOjYIcu7YMkGeH5PWkqtyDqWx1iJuG7ZHZ(I7u6JC7YMkGeH5PWkqtyDqWx1iJuGoiYBzt3N5HKjI86HebfRzG80rmIHuj2imfJjg(dWyIHe2MNc1dWmKeWmqyAdjpcwwhLqRXUQVJ3brte7lB)53NHbtZtHUI7uzxwHeDkQfhzeUpho7xGHR0GLNpf6mrKmWHKjI86HKgTauvCPAed)9BmXqcBZtH6bygscygimTHeKOtrT4iJqNgztrg7Z9(aiN95WzF2SeuuHiVLnDFU3FY9LT)87RrpcwwhlsdeMDzL8r0AhrXqYerE9qsJwaQkUunIH)YzmXqcBZtH6bygscygimTHK4oL(i3oR4eMYxbfDqK3YMUVS95A)WuyhonYMk0HT5Pq9(C4SV4yGT1HRZsqrL1W95WzFirJShSeDfGqdE8xJuh2MNc17Z8(Y2NR9NFFggmnpf6kUtLDzfs0iDFoC2NnlbfviYBzt3N79NCFMhsMiYRhsw7RQB9ig(dwJjgsyBEkupaZqsaZaHPnK0OhblRJfPbcZUSs(iATJgMy6(aEF5SVS9NFFggmnpf6kUtLDzfs0iDizIiVEir(iADLwGTgHJy4)KJjgsyBEkupaZqsaZaHPnK0OhblRJfPbcZUSs(iATJOyFz7lUtPpYTZkoHP8vqrhe5TSPvC2fOiq9(aE)j3x2(ZVpddMMNcDf3PYUScjAKoKmrKxpKiFeTUslWwJWrm8hipMyiHT5Pq9amdjbmdeM2qcs0POwCKrOtJSPiJ95EF)MX(Y2F(9zyW08uOR4ov2LvirNIAXrgHdjte51djnAbOQ4s1ig(ptgtmKW28uOEaMHKaMbctBiPrpcwwhlsdeMDzL8r0AhnmX095EFa2x2(ZVpddMMNcDf3PYUScjAKoKmrKxpKyrAGWSlR0aMtXrm8xUFmXqcBZtH6bygscygimTHKg9iyzDSinqy2LvYhrRD0Wet3N79bR9LTV4oL(i3oR4eMYxbfDqK3YMwXzxGIa17Z9(tUVS9NFFggmnpf6kUtLDzfs0iDizIiVEiXI0aHzxwPbmNIJy4pt0XedjSnpfQhGzijGzGW0gsZVpddMMNcDf3PYUScj6uuloYiCizIiVEiPrlavfxQgXigsIJb2wh0Xed)bymXqcBZtH6bygscygimTHeddMMNcD0OwOSUZUCFz7dj6uuloYi0Pr2uKX(aEFaaY7lBFU2xCNsFKBNvCct5RGIoiYBzt3NdN9NF)WuyhodY7RES1aew1gFJAh2MNc17lBFXDk9rUDAdoTgqRPShK3I8Ahe5TSP7Z8(C4SV3rP7lBF2SeuuHiVLnDFU3haagsMiYRhsuYgKp7YkFsJrm83VXedjSnpfQhGzizIiVEirjBq(SlR8jngsAKkGzrKxpKKWy)42NGI7BSbc33koX(jD)R3Njb79n6(XTFbezGDS)XaHcROi7Y9bsbI2NmOuH7tXiYUCFII9zsWwE6qsaZaHPnKe3P0h52zfNWu(kOOdI8w209LTpx7BIizGvSr(eP7dys773(Y23erYaRyJ8js3NBs7p5(Y2hs0POwCKrOtJSPiJ9b8(amJ9b0(CTVjIKbwXg5tKUpq8(a59zEFoC23erYaRyJ8js3hW7p5(Y2hs0POwCKrOtJSPiJ9b8(G1m2N5rm8xoJjgsyBEkupaZqsaZaHPnKyyW08uOJg1cL1D2L7lB)53NEekVS1ofA6QNVkoBJVqHoSnpfQ3x2(CTV4oL(i3oR4eMYxbfDqK3YMUpho7p)(HPWoCgK3x9yRbiSQn(g1oSnpfQ3x2(I7u6JC70gCAnGwtzpiVf51oiYBzt3N59LTpKOrxK8ynUkyTpG3NR9LZ(aAFpcwwhKOtrvCqirrKx7GiVLnDFM3NdN99okDFz7ZMLGIke5TSP7Z9((bWqYerE9qY8o(STiVUQsEVrm8hSgtmKW28uOEaMHKaMbctBiXWGP5PqhnQfkR7Sl3x2(0Jq5LT2Pqtx98vXzB8fk0HT5Pq9(Y2NR91x4iAqNYx1tLLGIQ(che5TSP7d49baG95Wz)53pmf2HJObDkFvpvwckCyBEkuVVS9f3P0h52Pn40AaTMYEqElYRDqK3YMUpZdjte51djZ74Z2I86Qk59gXW)jhtmKW28uOEaMHKaMbctBizIizGvSr(eP7dys773(Y2hs0OlsESgxfS2hW7Z1(YzFaTVhblRds0POkoiKOiYRDqK3YMUpZdjte51djZ74Z2I86Qk59gXWFG8yIHe2MNc1dWmKeWmqyAdjggmnpf6OrTqzDND5(Y2NR9f3P0h52zfNWu(kOOdI8w2095Wz)53pmf2HZG8(QhBnaHvTX3O2HT5Pq9(Y2xCNsFKBN2GtRb0Ak7b5TiV2brElB6(mVpho77Du6(Y2NnlbfviYBzt3N79byYHKjI86HefKjMQWAacRen5dgG8nIH)ZKXedjSnpfQhGzijGzGW0gsMisgyfBKpr6(aM0((TVS95AFnAbOQ16QgfMpxKIPzxUpho7dTuxrgyhotRPoiYBzt3NBs7dayTpZdjte51djkitmvH1aewjAYhma5BeJyivarXX7zXyIH)amMyizIiVEivCrE9qcBZtH6bygXWF)gtmKmrKxpKGwsXQgn9qcBZtH6bygXigsqtKMIoMy4paJjgsyBEkupaZqYerE9qYGcRXACqi2XqsJubmlI86HeqQjstrhscygimTHeKOtrT4iJqNgztrg7d49bYtUVS95A)cmCLgS88PqNjIKbUpho7p)(HPWoCucE(RRLgS88Pqh2MNc17Z8(Y2hs0OtJSPiJ9bmP9NCed)9BmXqcBZtH6bygscygimTHeddMMNcD8MC5GvXDk9rUPvtejdCFoC2pmyjgUi5XACvDI7ZnP99iyzDEQ70vwcOpNMaArE9qYerE9qYtDNUYsa9nIH)YzmXqcBZtH6bygscygimTHeddMMNcD8MC5GvXDk9rUPvtejdCFoC2pmyjgUi5XACvDI7ZnP99iyzDEiKIWPzx60eqlYRhsMiYRhsEiKIWPzxoIH)G1yIHe2MNc1dWmKeWmqyAdjpcwwhrd6u(Q0aIDzaYrumKmrKxpKuzjOGwLle6sESJrm8FYXedjSnpfQhGzizIiVEizTaPb0uvHPudjnsfWSiYRhsmHwG0aAQ9zstP2xy9(bmllr4(G1(fxGDKMAFpcwwk47JMa0(kJgzxUpatUpffxRPU9N5IuLY1q9(GmOEFXPr9(rYJ7B09T9dywwIW9JB)PiwSFg7drtBEk0nKeWmqyAdjggmnpf64n5YbRI7u6JCtRMisg4(C4SFyWsmCrYJ14Q6e3NBs7dWKJy4pqEmXqcBZtH6bygscygimTHKjIKbwXg5tKUpGjTVF7ZHZ(CTpKOrNgztrg7dys7p5(Y2hs0POwCKrOtJSPiJ9bmP9bYZyFMhsMiYRhsguynwliuuCed)NjJjgsyBEkupaZqsaZaHPnKyyW08uOJ3KlhSkUtPpYnTAIizG7ZHZ(HblXWfjpwJRQtCFUjTVhblRJnHON6oTttaTiVEizIiVEiXMq0tDNEed)L7htmKW28uOEaMHKaMbctBi5rWY6iAqNYxLgqSldqoII9LTVjIKbwXg5tKUpP9byizIiVEi5zL1JTgWumLoIrmKkXgHPOAhoMy4paJjgsyBEkupaZqIIIHK4oL(i3o6rOQq0kqOdI8w20HKjI86HezlJHKaMbctBifMc7WrpcvfIwbcDyBEkuVVS9ddwIHlsESgxTqev5m5(CV)K7lBF2SeuuHiVLnDFaV)K7lBFXDk9rUD0JqvHOvGqhe5TSP7Z9(CTFPqVpq8(ZWntMCFM3x2(MisgyfBKpr6(CtAF5mIH)(nMyiHT5Pq9amdjbmdeM2qIR9NFFggmnpf6kUtLDzfs0POwCKr4(C4SVhblRJsO1yx13X7GOjI9zEFz7Z1(EeSSoTbNwdO1u2dYBrETJOyFz7djAK9GLOtJMwLinQIlvoSnpfQ3x2(MisgyfBKpr6(CtAF5Spho7BIizGvSr(eP7tAF)2N5HKjI86HKgTauvCPAed)LZyIHe2MNc1dWmKeWmqyAdjpcwwhLqRXUQVJ3brte7ZHZ(ZVpddMMNcDf3PYUScj6uuloYiCizIiVEiHfPg5tXig(dwJjgsyBEkupaZqsJubmlI86H0mJD)WGLySVWNqLD5(jDFDsnpfQbFFk5meG23Zet3pU9dq4(0SlvOClmyjg7xInctX(QKg7Nnnqt7gsMiYRhsqIUAIiVUQsAmKObmfXWFagscygimTHKWNqHvSr(eP7tAFagsQKg124XHuj2imfJy4)KJjgsyBEkupaZqYerE9qI8r06kTaBnchscygimTHex7lUtPpYTZkoHP8vqrhe5TSP7d49NCFz7RrpcwwhlsdeMDzL8r0AhrX(C4SVg9iyzDSinqy2LvYhrRD0Wet3hW7lN9zEFz7Z1(SzjOOcrElB6(CVV4oL(i3onAbOQ16QgfMphe5TSP7dO9byg7ZHZ(SzjOOcrElB6(aEFXDk9rUDwXjmLVck6GiVLnDFMhscFcfwddwIbD4paJy4pqEmXqcBZtH6bygsMiYRhsSinqy2LvAaZP4qsaZaHPnK0OhblRJfPbcZUSs(iATJgMy6(CtAF5SVS9f3P0h52zfNWu(kOOdI8w2095EF5Spho7RrpcwwhlsdeMDzL8r0AhnmX095EFagscFcfwddwIbD4paJy4)mzmXqcBZtH6bygsMiYRhsSinqy2LvAaZP4qsaZaHPnKe3P0h52zfNWu(kOOdI8w209b8(tUVS91OhblRJfPbcZUSs(iATJgMy6(CVpadjHpHcRHblXGo8hGrmIHKgzncvmMy4paJjgsMiYRhs8zRRSqeLRHdjSnpfQhGzed)9BmXqcBZtH6bygsxXqIIXqYerE9qIHbtZtHdjgMIahsCTpc0ezrbQDztfqIW8uyfOjSoi4RAKrkW9LTV4oL(i3USPciryEkSc0ewhe8vnYifOdIM23(mpK0ivaZIiVEibebrgyh7tlqrYMOE)aM9umO77HzxUpbf17todq7BeXXBrk2xLnshsmmyTnECirlqrYMOUgWSNIXig(lNXedjSnpfQhGziDfdjkgdjte51djggmnpfoKyykcCijUtPpYTJsWZFDT0GLNpf6GiVLnDFU3FY9LTFykSdhLGN)6APblpFk0HT5Pq9qIHbRTXJdPI7uzxwHeDkQfhzeoIH)G1yIHe2MNc1dWmKUIHefJHKjI86HeddMMNchsmmfboKctHD4OhHQcrRaHoSnpfQ3x2(qIg3N799BFz7hgSedxK8ynUAHiQYzY95E)j3x2(SzjOOcrElB6(aE)jhsmmyTnECivCNk7YkKOr6ig(p5yIHe2MNc1dWmKUIHefJHKjI86HeddMMNchsmmfboKmrKmWk2iFI09jTpa7lBFU2F(9HwQRidSdNP1uho7Kg095WzFOL6kYa7WzAn1L9(aEFaMCFMhsmmyTnECirJAHY6o7Yrm8hipMyiHT5Pq9amdPRyirXyizIiVEiXWGP5PWHedtrGdPcmCLgS88PqNjIKbUpho77rWY6iAqNYx1OuJqfoII95Wz)WuyhodY7RES1aew1gFJAh2MNc17lB)cmCwXjQLGocLZerYa3NdN99iyzDAdoTgqRPShK3I8AhrXqIHbRTXJdjEtUCWQ4oL(i30QjIKboIH)ZKXedjSnpfQhGzizIiVEiDeHheTPdjnsfWSiYRhsYvSSdl7Sl3xUEcjuyh7dePSscC)KUVTFbmpyg(gscygimTHK(chJesOWoQfkRKaDqKfIuqMNc3x2(ZVFykSdhrd6u(QEQSeu4W28uOEFz7p)(ql1vKb2HZ0AQdNDsd6ig(l3pMyiHT5Pq9amdjbmdeM2qsFHJrcjuyh1cLvsGoiYcrkiZtH7lBFtejdSInYNiDFatAF)2x2(CT)87hMc7Wr0GoLVQNklbfoSnpfQ3NdN9dtHD4iAqNYx1tLLGch2MNc17lBFXDk9rUDenOt5R6PYsqHdI8w209zEizIiVEiDeHheTPJy4pt0XedjSnpfQhGzijGzGW0gsqIgzpyj6OefiKgqlBh2MNc17lBFU2xFHJfE0OYImqOdISqKcY8u4(C4SV(cNN6oDTqzLeOdISqKcY8u4(mpKmrKxpKoIWdI20rm8hGzmMyiHT5Pq9amdjkkgsI7u6JC7OhHQcrRaHoiYBzthsMiYRhsKTmgscygimTHuykSdh9iuviAfi0HT5Pq9(Y2pmyjgUi5XAC1cruLZK7Z9(tUVS9zZsqrfI8w209b8(tUVS9f3P0h52rpcvfIwbcDqK3YMUp37Z1(Lc9(aX7pd3mzY9zEFz7BIizGvSr(eP7tAFagXWFaaymXqcBZtH6bygsAKkGzrKxpKycIiVEFGqsd6(wR3FMwGncP7Z1mTaBesNtcbAcSfiDFIMsuuCWa17N9(MwFTJ5HKjI86HKWuQQjI86QkPXqsL0O2gpoKcy2tXGoIH)a43yIHe2MNc1dWmKmrKxpKeMsvnrKxxvjngsQKg124XHK4yGT1bDed)bqoJjgsyBEkupaZqYerE9qsykv1erEDvL0yiPsAuBJhhsqtKMIoIH)aawJjgsyBEkupaZqsJubmlI86HKjI8AQtJSgHkaeP5OiqtGTabpzjzIizGvSr(ePKaq28A0cq1PDwckC6KAEkSAxObVnEK0vGncNLb59vp2AacRA00ZIfPbcZUSsdyofNflsdeMDzLgWCkolIg0P8v9uzjOywfxKxplTbNwdO1u2dYBrE9SSItykFfuCizIiVEijmLQAIiVUQsAmKujnQTXJdjXDk9rUPJy4patoMyiHT5Pq9amdjbmdeM2qYerYaRyJ8js3hWK23V9LTpx7lUtPpYTtJwaQATUQrH5ZbrElB6(CVpaZyFz7p)(HPWoCAKnvOdBZtH695WzFXDk9rUDAKnvOdI8w2095EFaMX(Y2pmf2HtJSPcDyBEkuVpZ7lB)53xJwaQATUQrH5ZfPyA2Ldjte51djirxnrKxxvjngsQKg124XHKDyLIbrXig(daqEmXqcBZtH6bygscygimTHKjIKbwXg5tKUpGjTVF7lBFnAbOQ16QgfMpxKIPzxoKObmfXWFagsMiYRhsqIUAIiVUQsAmKujnQTXJdj7WQhbKgJy4paZKXedjSnpfQhGzijGzGW0gsMisgyfBKpr6(aM0((TVS95A)53xJwaQATUQrH5ZfPyA2L7lBFU2xCNsFKBNgTau1ADvJcZNdI8w209b8(amJ9LT)87hMc7WPr2uHoSnpfQ3NdN9f3P0h52Pr2uHoiYBzt3hW7dWm2x2(HPWoCAKnvOdBZtH69zEFMhsMiYRhsqIUAIiVUQsAmKujnQTXJdPsSrykQ2HJy4paY9JjgsyBEkupaZqsaZaHPnKmrKmWk2iFI09jTpadjAatrm8hGHKjI86HKWuQQjI86QkPXqsL0O2gpoKkXgHPyeJyijUtPpYnDmXWFagtmKW28uOEaMHKaMbctBiXWGP5PqhVjxoyvCNsFKBA1erYa3NdN99okDFz7ZMLGIke5TSP7Z9((bKhsMiYRhsfxKxpIH)(nMyiHT5Pq9amdjbmdeM2qsCNsFKBhrd6u(QEQSeu4GiVLnDFU3FY9LTV4oL(i3oTbNwdO1u2dYBrETdI8w20ko7cueOEFU3FY9LTFykSdhrd6u(QEQSeu4W28uOEFoC2F(9dtHD4iAqNYx1tLLGch2MNc17ZHZ(EhLUVS9zZsqrfI8w2095EF5m5qYerE9qYG8(QhBnaHvnA6rm8xoJjgsyBEkupaZqYerE9qIEeQkeTceoKeWmqyAdPWGLy4IKhRXvlervotUp37p5(Y2pmyjgUi5XACvDI7d49NCFz7BIizGvSr(eP7ZnP9LZqs4tOWAyWsmOd)byed)bRXedjSnpfQhGzizIiVEir0GoLVQNklbfdjnsfWSiYRhsmrCknDFWOYsqX(ShCFII9JB)j3NIIR109JBFQVwSp5maTptO4eMYxbfbF)zAacHKtkc((euCFYzaAFW2Gt3FcO1u2dYBrETBijGzGW0gsmmyAEk0rJAHY6o7Y9LTpx7lUtPpYTZkoHP8vqrhe5TSPvC2fOiq9(CV)K7ZHZ(I7u6JC7SItykFfu0brElBAfNDbkcuVpG3hGzSpZ7lBFU2xCNsFKBN2GtRb0Ak7b5TiV2brElB6(CVFPqVpho77rWY60gCAnGwtzpiVf51oII9zEed)NCmXqcBZtH6bygscygimTHKjIKbwXg5tKUpGjTVF7ZHZ(EhLUVS9zZsqrfI8w2095EF)ayizIiVEir0GoLVQNklbfJy4pqEmXqcBZtH6bygscygimTHeddMMNcD0OwOSUZUCFz7Z1(6lCenOt5R6PYsqrvFHdI8w2095Wz)53pmf2HJObDkFvpvwckCyBEkuVpZdjte51djTbNwdO1u2dYBrE9ig(ptgtmKW28uOEaMHKaMbctBizIizGvSr(eP7dys773(C4SV3rP7lBF2SeuuHiVLnDFU33pagsMiYRhsAdoTgqRPShK3I86rm8xUFmXqcBZtH6bygscygimTHKjIKbwXg5tKUpP9byFz7RrpcwwhlsdeMDzL8r0AhnmX09b8(YzizIiVEizfNWu(kO4ig(ZeDmXqcBZtH6bygsMiYRhswXjmLVckoKeWmqyAdjtejdSInYNiDFatAF)2x2(A0JGL1XI0aHzxwjFeT2rdtmDFaVVC2x2(ZVVgTau1ADvJcZNlsX0SlhscFcfwddwIbD4paJy4paZymXqcBZtH6bygscygimTHeKOtrT4iJqNgztrg7Z9(aaw7lBFU2xCNsFKBhrd6u(QEQSeu4GiVLnDFU3hGzSpho7RVWr0GoLVQNklbfv9foiYBzt3N5HKjI86HeLGN)6APblpFkCed)baGXedjSnpfQhGzijGzGW0gsmmyAEk0rJAHY6o7Y9LTVg9iyzDSinqy2LvYhrRD0Wet3N799BFz7Z1(fy4SItulbDekNjIKbUpho77rWY60gCAnGwtzpiVf51oII9LT)87xGHZG8(QLGocLZerYa3N5HKjI86Herd6u(QgLAeQyed)bWVXedjSnpfQhGzizIiVEir0GoLVQrPgHkgscygimTHKjIKbwXg5tKUpGjTVF7lBFn6rWY6yrAGWSlRKpIw7OHjMUp3773qs4tOWAyWsmOd)byed)bqoJjgsyBEkupaZqsaZaHPnKMF)cmCLGocLZerYahsMiYRhsqlPyvJMEeJyedjgiKMxp83Vz4haZqoaaGdGHezd2zxshsajmbGu)Nz(ZepR93Fcq4(jFXbJ9zp4(YBhwPyqui)(qeOjsiQ3NE84(grC8wG69fGSUePUfyGq24(Yzw7ZKxZaHbQ3xEirJShSeDaL87h3(YdjAK9GLOdOCyBEkul)(CbWSz2TaVadKWeas9FM5pt8S2F)jaH7N8fhm2N9G7lVDy1Jasd53hIanrcr9(0Jh33iIJ3cuVVaK1Li1TadeYg3hGzTptEndegOEF5HenYEWs0buYVFC7lpKOr2dwIoGYHT5PqT87ZfaZMz3c8cmqctai1)zM)mXZA)9NaeUFYxCWyF2dUV8bm7PyqLFFic0eje17tpECFJioElq9(cqwxIu3cmqiBCFaM1(m51mqyG69Lpmf2HdOKF)42x(WuyhoGYHT5PqT87ZfaZMz3c8cmqctai1)zM)mXZA)9NaeUFYxCWyF2dUV8LyJWui)(qeOjsiQ3NE84(grC8wG69fGSUePUfyGq24(Yzw7ZKxZaHbQ3xEirJShSeDaL87h3(YdjAK9GLOdOCyBEkul)(CbWSz2TaVadKWeas9FM5pt8S2F)jaH7N8fhm2N9G7lV4yGT1bv(9HiqtKquVp94X9nI44Ta17lazDjsDlWaHSX9byw7ZKxZaHbQ3x(WuyhoGs(9JBF5dtHD4akh2MNc1YVpxamBMDlWaHSX9LZS2NjVMbcduVV8HPWoCaL87h3(YhMc7WbuoSnpfQLFFUay2m7wGbczJ7lNzTptEndegOEF5PhHYlBTdOKF)42xE6rO8Yw7akh2MNc1YVpxamBMDlWaHSX9bRzTptEndegOEF5dtHD4ak53pU9Lpmf2HdOCyBEkul)(CbWSz2TadeYg3hSM1(m51mqyG69LNEekVS1oGs(9JBF5PhHYlBTdOCyBEkul)(CbWSz2TadeYg3hipR9zYRzGWa17lFykSdhqj)(XTV8HPWoCaLdBZtHA53NlaMnZUf4fyGeMaqQ)Zm)zIN1(7pbiC)KV4GX(ShCF5f3P0h5Mk)(qeOjsiQ3NE84(grC8wG69fGSUePUfyGq24((nR9zYRzGWa17lFykSdhqj)(XTV8HPWoCaLdBZtHA53Nl)MnZUfyGq24(a5zTptEndegOEF5dtHD4ak53pU9Lpmf2HdOCyBEkul)(CbWSz2TaVadKWeas9FM5pt8S2F)jaH7N8fhm2N9G7lFj2imfv7q53hIanrcr9(0Jh33iIJ3cuVVaK1Li1TadeYg3hGzTptEndegOEF5dtHD4ak53pU9Lpmf2HdOCyBEkul)(CbWSz2TadeYg33VzTptEndegOEF5HenYEWs0buYVFC7lpKOr2dwIoGYHT5PqT87ZfaZMz3c8cmqctai1)zM)mXZA)9NaeUFYxCWyF2dUV8AK1iuH87drGMiHOEF6XJ7BeXXBbQ3xaY6sK6wGbczJ7lNzTptEndegOEF5dtHD4ak53pU9Lpmf2HdOCyBEkul)(wSVC3mfiSpxamBMDlWaHSX9bRzTptEndegOEF5dtHD4ak53pU9Lpmf2HdOCyBEkul)(CbWSz2TadeYg3hipR9zYRzGWa17lFykSdhqj)(XTV8HPWoCaLdBZtHA53NlaMnZUfyGq24(ZKzTptEndegOEF5dtHD4ak53pU9Lpmf2HdOCyBEkul)(CbWSz2TadeYg3xUFw7ZKxZaHbQ3x(WuyhoGs(9JBF5dtHD4akh2MNc1YVpx(nBMDlWaHSX9zIoR9zYRzGWa17lpKOr2dwIoGs(9JBF5HenYEWs0buoSnpfQLFFUay2m7wGbczJ7dWmM1(m51mqyG69Lpmf2HdOKF)42x(WuyhoGYHT5PqT87ZfaZMz3cmqiBCFaMCw7ZKxZaHbQ3x(WuyhoGs(9JBF5dtHD4akh2MNc1YVpx(nBMDlWaHSX9byMmR9zYRzGWa17lFykSdhqj)(XTV8HPWoCaLdBZtHA53Nl)MnZUf4f4zgFXbduVpaZyFte517RsAqDlWdPc4XMkCiXuMUpyJwaAF5QDwck2FMRbDkFlWmLP7lxXGcq7dayb(((nd)aybEbMPmDFMeK1LiDwlWmLP7l32NjOLle0Gh7GUFC7d2nyphyJSPcNdSrlar3hSjW9JB)Rv(2xCeDSFyWsmO7tg0TVbX9XzxGIa17h3(QKbUV66Y9X(ikbTFC7ZBrGW95YoSsXGOyFMcaZUfyMY09LB7d2j18uOEFjtat2uKMAFGite77HcJGI7RrtVFjOJqr3N3MI7ZEW9PMEFWwUk1TaZuMUVCB)zoA2L7dKCeTEFPcS1iCFZlvzKiDF(dI7ZQWzNEkF7ZLf7dwaAFAyIP09ZMgOP3)y3FsaXmtK7d2ars73iran1(wR3N38TFbezGDSp94X97tUbrX(0miSiVM6wGzkt3xUTptcY6suVpV1(2xE2SeuuHiVLnv(9fxRZiV2u09JBFROq5B)S337O09zZsqbD)Rv(2NlfsP7ZKG9(KnAG7F9(b0OGy2TaZuMUVCB)jMPG9mDw7VV)i59dy2tXyFbmdeMMBbEb2erEn1varXX7zbGinxXf51lWMiYRPUcikoEplaeP5GwsXQgn9cmtz6(YDmmfHfiDFB)aM9umO7lUtPpYn47RtgPg1775BFWAs3(takP7t2O7laDuS33O7t0GoLV9jFWP09VEFWAY9PO4A9(EeqASVWNqHuW33Ji2hKr3pUBFER9TVqd3hzzrrq3pU9ltg4(2(I7u6JC7MTttaTiVEFDYiPhC)SPbAA3(Zm29ZqE6(mmfbUpiJUFF7drElBnc3hIbbS3haW3hvuCFigeWE)z4M0TaZuMUVjI8AQRaIIJ3ZcarAoggmnpfcEB8iPaM9umQauP(Ab4xbjkgjl4mmfbscaWzykcSIkksAgUjbxCToJ8Asbm7Py4aWbYOvckw9iyzLXvaZEkgoaCI7u6JC70eqlYRN5N5bRjjndMxGzkt33erEn1varXX7zbGinhddMMNcbVnEKuaZEkgv)QuFTa8RGefJKfCgMIajba4mmfbwrffjnd3KGlUwNrEnPaM9umC(5az0kbfREeSSY4kGzpfdNFoXDk9rUDAcOf51Z8Z8G1KKMbZlWmLP7l3rJK3cKUVTFaZEkg09zykcCFpF7lo(cdMD5(biCFXDk9rU3)y3paH7hWSNIb47RtgPg1775B)aeUVMaArE9(h7(biCFpcw29Zy)c4Xi1i1TptegDFBFAaXUmaTp)Pt2eH7h3(LjdCFBFqzjieUFbmpyg(2pU9Pbe7Ya0(bm7PyqbFFJUpzuP23O7B7ZF6Knr4(ShC)KDFB)aM9um2NCQu7FW9jNk1(9f7t91I9jNbO9f3P0h5M6wGzkt33erEn1varXX7zbGinhddMMNcbVnEKuaZEkg1cyEWm8b(vqIIrYcodtrGK8dCgMIaROIIKaaCX16mYRjnFaZEkgoaCGmALGIvpcwwzbm7Py48ZbYOvckw9iyz5WjGzpfdNFoqgTsqXQhblRmU4kGzpfdNFoXDk9rUDAcOf51Z8bm7Py48ZvapHZAFvDb1PjGwKxZmqmxa4Meqbm7Py48ZbYOvpcwwMbI5IHbtZtHUaM9umQ(vP(AbZmdyU4kGzpfdhaoXDk9rUDAcOf51Z8bm7Py4aWvapHZAFvDb1PjGwKxZmqmxa4Meqbm7Py4aWbYOvpcwwMbI5IHbtZtHUaM9umQauP(AbZmVaVaVaZuMUVC3SrbrG69rgi03(rYJ7hGW9nrCW9t6(gdlvMNcDlWMiYRPK4ZwxzHikxdxGz6(arqKb2X(0cuKSjQ3pGzpfd6(Ey2L7tqr9(KZa0(grC8wKI9vzJ0fyte51uarAoggmnpfcEB8ijAbks2e11aM9umaNHPiqsCHanrwuGAx2ubKimpfwbAcRdc(QgzKcuM4oL(i3USPciryEkSc0ewhe8vnYifOdIM2hZlWmLP7lx3GP5Pq6cSjI8AkGinhddMMNcbVnEKuXDQSlRqIof1IJmcbNHPiqsI7u6JC7Oe88xxlny55tHoiYBzt5EszHPWoCucE(RRLgS88PWfyte51uarAoggmnpfcEB8iPI7uzxwHensbNHPiqsHPWoC0JqvHOvGqzqIg52pzHblXWfjpwJRwiIQCMK7jLXMLGIke5TSPaEYfyte51uarAoggmnpfcEB8ijAuluw3zxcodtrGKmrKmWk2iFIusaiJR5HwQRidSdNP1uho7KguoCGwQRidSdNP1ux2agGjzEb2erEnfqKMJHbtZtHG3gpsI3KlhSkUtPpYnTAIizGGZWueiPcmCLgS88PqNjIKbYHJhblRJObDkFvJsncv4ik4Wjmf2HZG8(QhBnaHvTX3OwwbgoR4e1sqhHYzIizGC44rWY60gCAnGwtzpiVf51oIIfyMUVCfl7WYo7Y9LRNqcf2X(arkRKa3pP7B7xaZdMHVfyte51uarAUJi8GOnf8KLK(chJesOWoQfkRKaDqKfIuqMNcLnFykSdhrd6u(QEQSeuiBEOL6kYa7WzAn1HZoPbDb2erEnfqKM7icpiAtbpzjPVWXiHekSJAHYkjqhezHifK5PqzMisgyfBKprkGj5NmUMpmf2HJObDkFvpvwck4Wjmf2HJObDkFvpvwckKjUtPpYTJObDkFvpvwckCqK3YMY8cSjI8AkGin3reEq0McEYscs0i7blrhLOaH0aAzlJl9fow4rJklYaHoiYcrkiZtHC4OVW5PUtxluwjb6GilePGmpfY8cSjI8AkGinhzldWPOGK4oL(i3o6rOQq0kqOdI8w2uWtwsHPWoC0JqvHOvGqzHblXWfjpwJRwiIQCMK7jLXMLGIke5TSPaEszI7u6JC7OhHQcrRaHoiYBzt5MRsHgiEgUzYKmlZerYaRyJ8jsjbWcmt3NjiI869bcjnO7BTE)zAb2iKUpxZ0cSriDojeOjWwG09jAkrrXbduVF27BA91oMxGnrKxtbeP5eMsvnrKxxvjnaVnEKuaZEkg0fyte51uarAoHPuvte51vvsdWBJhjjogyBDqxGnrKxtbeP5eMsvnrKxxvjnaVnEKe0ePPOlWmDFte51uarAokc0eylqWtwsMisgyfBKprkjaKnVgTauDANLGcNoPMNcR2fAWBJhjDfyJWzzqEF1JTgGWQgn9SyrAGWSlR0aMtXzXI0aHzxwPbmNIZIObDkFvpvwckMvXf51ZsBWP1aAnL9G8wKxplR4eMYxbfxGnrKxtbeP5eMsvnrKxxvjnaVnEKK4oL(i30fyte51uarAoirxnrKxxvjnaVnEKKDyLIbrb4jljtejdSInYNifWK8tgxI7u6JC70OfGQwRRAuy(CqK3YMYnaZq28HPWoCAKnvihoI7u6JC70iBQqhe5TSPCdWmKfMc7WPr2uHmlBEnAbOQ16QgfMpxKIPzxUaBIiVMcisZbj6QjI86QkPb4TXJKSdREeqAaonGPiiba4jljtejdSInYNifWK8tMgTau1ADvJcZNlsX0SlxGnrKxtbeP5GeD1erEDvL0a824rsLyJWuuTdbpzjzIizGvSr(ePaMKFY4AEnAbOQ16QgfMpxKIPzxkJlXDk9rUDA0cqvR1vnkmFoiYBztbmaZq28HPWoCAKnvihoI7u6JC70iBQqhe5TSPagGzilmf2HtJSPczM5fyte51uarAoHPuvte51vvsdWBJhjvInctb40aMIGeaGNSKmrKmWk2iFIusaSaVaZuMUpt4K72hmeqASaBIiVM6SdREeqAqsJwaQkUubEYsIlpcwwhLqRXUQVJ3brteC4mpddMMNcDf3PYUScj6uuloYiKzzC5rWY60gCAnGwtzpiVf51oIczqIgzpyj60OPvjsJQ4sLmtejdSInYNiLBsYHdhtejdSInYNiLKFmVaBIiVM6SdREeqAaisZHfPg5tb4jljirNIAXrgHonYMIm4MlaMbG0OfGQt7Seu4yjFeTg11WGLyqbILdZY0OfGQt7Seu4yjFeTg11WGLyq5gilBEggmnpf6kUtLDzfs0POwCKrihoEeSSokzdYNDzLpPHJOyb2erEn1zhw9iG0aqKMdlsnYNcWtwsqIof1IJmcDAKnfzWTFtktJwaQoTZsqHJL8r0AuxddwIbfWtkBEggmnpf6kUtLDzfs0POwCKr4cSjI8AQZoS6raPbGinhwKAKpfGNSKMxJwaQoTZsqHJL8r0AuxddwIbv28mmyAEk0vCNk7YkKOtrT4iJqoCyZsqrfI8w2uUNKdhOL6kYa7WzAn1HZoPbvg0sDfzGD4mTM6GiVLnL7jxGnrKxtD2HvpcinaeP5iFeTUslWwJWfyte51uNDy1JasdarAoSi1iFkapzjnpddMMNcDf3PYUScj6uuloYiCbEbMPmDFMWj3TVegeflWMiYRPo7WkfdIcsw7RQBn4jljnAbO60olbfowYhrRrDnmyjguats4tOWk2iFIuoCGwQRidSdNP1uho7Kguzql1vKb2HZ0AQdI8w2uUjbaalWMiYRPo7WkfdIcarAoR9v1Tg8KLKgTauDANLGchl5JO1OUggSedkGjn5cSjI8AQZoSsXGOaqKMtJwaQkUubEYsAEggmnpf6kUtLDzfs0POwCKrOmU8iyzDAdoTgqRPShK3I8AhrHmirJShSeDA00QePrvCPsMjIKbwXg5tKYnj5WHJjIKbwXg5tKsYpMxGnrKxtD2HvkgefaI0CyrQr(uaEYsAEggmnpf6kUtLDzfs0POwCKr4cSjI8AQZoSsXGOaqKMJfPbcZUSsdyofbx4tOWAyWsmOKaa8KLKg9iyzDSinqy2LvYhrRD0Wet5MKCKjUtPpYTZkoHP8vqrhe5TSPClNfyte51uNDyLIbrbGinhlsdeMDzLgWCkcUWNqH1WGLyqjba4jljn6rWY6yrAGWSlRKpIw7OHjMYnalWMiYRPo7WkfdIcarAowKgim7YknG5ueCHpHcRHblXGscaWtwsA0JGL1XI0aHzxwjFeT2rdtmLBsYrgKOrxK8ynUkyXT4oL(i3oR9v1T2brElB6cmt3hibe27hgSeJ9PKTc6(ge3xNuZtHAW3paL09jNk1(km233rSpTaB9(qIgPZr(iAnD)SPbA69p29jBzKD5(ShCFWUb75aBKnv4CGnAbi5P7d2eOBb2erEn1zhwPyquaisZr(iADLwGTgHGNSK4AEkgr2LuNWNqHC4OrlavN2zjOWXs(iAnQRHblXGcyscFcfwXg5tKYSmn6rWY6yrAGWSlRKpIw7OHjMcy5ids0OlsESgxvoClUtPpYTZAFvDRDqK3YMUaVaZuMUpq0f51lWMiYRPoXDk9rUPKkUiVg8KLeddMMNcD8MC5GvXDk9rUPvtejdKdhVJsLXMLGIke5TSPC7hqEbMPmDFM8oL(i30fyte51uN4oL(i3uarAodY7RES1aew1OPbpzjjUtPpYTJObDkFvpvwckCqK3YMY9KYe3P0h52Pn40AaTMYEqElYRDqK3YMwXzxGIa1CpPSWuyhoIg0P8v9uzjOGdN5dtHD4iAqNYx1tLLGcoC8okvgBwckQqK3YMYTCMCb2erEn1jUtPpYnfqKMJEeQkeTcecUWNqH1WGLyqjba4jlPWGLy4IKhRXvlervotY9KYcdwIHlsESgxvNiGNuMjIKbwXg5tKYnj5SaZ09zI4uA6(GrLLGI9zp4(ef7h3(tUpffxRP7h3(uFTyFYzaAFMqXjmLVckc((Z0aecjNue89jO4(KZa0(GTbNU)eqRPShK3I8A3cSjI8AQtCNsFKBkGinhrd6u(QEQSeuaEYsIHbtZtHoAuluw3zxkJlXDk9rUDwXjmLVck6GiVLnTIZUafbQ5EsoCe3P0h52zfNWu(kOOdI8w20ko7cueOgWamdMLXL4oL(i3oTbNwdO1u2dYBrETdI8w2uUlfAoC8iyzDAdoTgqRPShK3I8AhrbZlWMiYRPoXDk9rUPaI0CenOt5R6PYsqb4jljtejdSInYNifWK8JdhVJsLXMLGIke5TSPC7halWMiYRPoXDk9rUPaI0CAdoTgqRPShK3I8AWtwsmmyAEk0rJAHY6o7szCPVWr0GoLVQNklbfv9foiYBzt5Wz(WuyhoIg0P8v9uzjOG5fyte51uN4oL(i3uarAoTbNwdO1u2dYBrEn4jljtejdSInYNifWK8JdhVJsLXMLGIke5TSPC7halWMiYRPoXDk9rUPaI0CwXjmLVckcEYsYerYaRyJ8jsjbGmn6rWY6yrAGWSlRKpIw7OHjMcy5SaBIiVM6e3P0h5McisZzfNWu(kOi4cFcfwddwIbLeaGNSKmrKmWk2iFIuatYpzA0JGL1XI0aHzxwjFeT2rdtmfWYr28A0cqvR1vnkmFUiftZUCb2erEn1jUtPpYnfqKMJsWZFDT0GLNpfcEYscs0POwCKrOtJSPidUbaSKXL4oL(i3oIg0P8v9uzjOWbrElBk3amdoC0x4iAqNYx1tLLGIQ(che5TSPmVaBIiVM6e3P0h5McisZr0GoLVQrPgHkapzjXWGP5PqhnQfkR7SlLPrpcwwhlsdeMDzL8r0AhnmXuU9tgxfy4SItulbDekNjIKbYHJhblRtBWP1aAnL9G8wKx7ikKnFbgodY7Rwc6iuotejdK5fyte51uN4oL(i3uarAoIg0P8vnk1iub4cFcfwddwIbLeaGNSKmrKmWk2iFIuatYpzA0JGL1XI0aHzxwjFeT2rdtmLB)wGnrKxtDI7u6JCtbeP5GwsXQgnn4jlP5lWWvc6iuotejdCbMPmDFWoPMNc1GVVCHGg73xSpenLY3(9b5n1(EiiJrEW9dqwipDFYhmaTFbbKsKD5(zl3knE0TaZuMUVjI8AQtCNsFKBkGinh1eWKnfPPQfMiapzjzIizGvSr(ePaMKFYM3JGL1Pn40AaTMYEqElYRDefYMxCNsFKBN2GtRb0Ak7b5TiV2brt7JdhVJsLXMLGIke5TSPCxk0lWlWmLP7ZKhdSTo2Nj4LQmsKUaBIiVM6ehdSToOKOKniF2Lv(KgGNSKyyW08uOJg1cL1D2LYGeDkQfhze60iBkYaWaaKLXL4oL(i3oR4eMYxbfDqK3YMYHZ8HPWoCgK3x9yRbiSQn(g1Ye3P0h52Pn40AaTMYEqElYRDqK3YMYmhoEhLkJnlbfviYBzt5gaawGz6(sySFC7tqX9n2aH7BfNy)KU)17ZKG9(gD)42VaImWo2)yGqHvuKD5(aPar7tguQW9PyezxUprX(mjylpDb2erEn1jogyBDqbeP5OKniF2Lv(KgGNSKe3P0h52zfNWu(kOOdI8w2uzCzIizGvSr(ePaMKFYmrKmWk2iFIuUjnPmirNIAXrgHonYMImamaZaqCzIizGvSr(ePaXazM5WXerYaRyJ8jsb8KYGeDkQfhze60iBkYaWG1myEb2erEn1jogyBDqbeP5mVJpBlYRRQK3d8KLeddMMNcD0OwOSUZUu280Jq5LT2Pqtx98vXzB8fkugxI7u6JC7SItykFfu0brElBkhoZhMc7WzqEF1JTgGWQ24BultCNsFKBN2GtRb0Ak7b5TiV2brElBkZYGen6IKhRXvblaZLCaKhblRds0POkoiKOiYRDqK3YMYmhoEhLkJnlbfviYBzt52pawGnrKxtDIJb2whuarAoZ74Z2I86Qk59apzjXWGP5PqhnQfkR7SlLrpcLx2ANcnD1ZxfNTXxOqzCPVWr0GoLVQNklbfv9foiYBztbmaaWHZ8HPWoCenOt5R6PYsqHmXDk9rUDAdoTgqRPShK3I8Ahe5TSPmVaBIiVM6ehdSToOaI0CM3XNTf51vvY7bEYsYerYaRyJ8jsbmj)KbjA0fjpwJRcwaMl5aipcwwhKOtrvCqirrKx7GiVLnL5fyte51uN4yGT1bfqKMJcYetvynaHvIM8bdq(apzjXWGP5PqhnQfkR7SlLXL4oL(i3oR4eMYxbfDqK3YMYHZ8HPWoCgK3x9yRbiSQn(g1Ye3P0h52Pn40AaTMYEqElYRDqK3YMYmhoEhLkJnlbfviYBzt5gGjxGnrKxtDIJb2whuarAokitmvH1aewjAYhma5d8KLKjIKbwXg5tKcys(jJlnAbOQ16QgfMpxKIPzxYHd0sDfzGD4mTM6GiVLnLBsaawmVaVaZuMUVu2LkC)jmyjglWMiYRPUsSrykiPrlavfxQapzj5rWY6OeAn2v9D8oiAIq28mmyAEk0vCNk7YkKOtrT4iJqoCkWWvAWYZNcDMisg4cSjI8AQReBeMcarAonAbOQ4sf4jljirNIAXrgHonYMIm4ga5WHdBwckQqK3YMY9KYMxJEeSSowKgim7Yk5JO1oIIfyte51uxj2imfaI0Cw7RQBn4jljXDk9rUDwXjmLVck6GiVLnvgxHPWoCAKnvOdBZtHAoCehdSToCDwckQSgYHdKOr2dwIUcqObp(RrkZY4AEggmnpf6kUtLDzfs0iLdh2SeuuHiVLnL7jzEb2erEn1vInctbGinh5JO1vAb2AecEYssJEeSSowKgim7Yk5JO1oAyIPawoYMNHbtZtHUI7uzxwHensxGnrKxtDLyJWuaisZr(iADLwGTgHGNSK0OhblRJfPbcZUSs(iATJOqM4oL(i3oR4eMYxbfDqK3YMwXzxGIa1aEszZZWGP5PqxXDQSlRqIgPlWMiYRPUsSrykaeP50OfGQIlvGNSKGeDkQfhze60iBkYGB)MHS5zyW08uOR4ov2LvirNIAXrgHlWMiYRPUsSrykaeP5yrAGWSlR0aMtrWtwsA0JGL1XI0aHzxwjFeT2rdtmLBaKnpddMMNcDf3PYUScjAKUaBIiVM6kXgHPaqKMJfPbcZUSsdyofbpzjPrpcwwhlsdeMDzL8r0AhnmXuUblzI7u6JC7SItykFfu0brElBAfNDbkcuZ9KYMNHbtZtHUI7uzxwHensxGnrKxtDLyJWuaisZPrlavfxQapzjnpddMMNcDf3PYUScj6uuloYiCbEbMPmDFMySryk2NjCYD7debZdMHVfyte51uxj2imfv7qsKTmaNIcsI7u6JC7OhHQcrRaHoiYBztbpzjfMc7WrpcvfIwbcLfgSedxK8ynUAHiQYzsUNugBwckQqK3YMc4jLjUtPpYTJEeQkeTce6GiVLnLBUkfAG4z4MjtYSmtejdSInYNiLBsYzb2erEn1vInctr1oeqKMtJwaQkUubEYsIR5zyW08uOR4ov2LvirNIAXrgHC44rWY6OeAn2v9D8oiAIGzzC5rWY60gCAnGwtzpiVf51oIczqIgzpyj60OPvjsJQ4sLmtejdSInYNiLBsYHdhtejdSInYNiLKFmVaBIiVM6kXgHPOAhcisZHfPg5tb4jljpcwwhLqRXUQVJ3brteC4mpddMMNcDf3PYUScj6uuloYiCbMP7pZy3pmyjg7l8juzxUFs3xNuZtHAW3NsodbO99mX09JB)aeUpn7sfk3cdwIX(LyJWuSVkPX(ztd00Ufyte51uxj2imfv7qarAoirxnrKxxvjnaVnEKuj2imfGtdykcsaaEYss4tOWk2iFIusaSaBIiVM6kXgHPOAhcisZr(iADLwGTgHGl8juynmyjgusaaEYsIlXDk9rUDwXjmLVck6GiVLnfWtktJEeSSowKgim7Yk5JO1oIcoC0OhblRJfPbcZUSs(iATJgMykGLdZY4InlbfviYBzt5wCNsFKBNgTau1ADvJcZNdI8w2uabWm4WHnlbfviYBztbS4oL(i3oR4eMYxbfDqK3YMY8cSjI8AQReBeMIQDiGinhlsdeMDzLgWCkcUWNqH1WGLyqjba4jljn6rWY6yrAGWSlRKpIw7OHjMYnj5itCNsFKBNvCct5RGIoiYBzt5woC4OrpcwwhlsdeMDzL8r0AhnmXuUbyb2erEn1vInctr1oeqKMJfPbcZUSsdyofbx4tOWAyWsmOKaa8KLK4oL(i3oR4eMYxbfDqK3YMc4jLPrpcwwhlsdeMDzL8r0AhnmXuUbybEbMP7dKAI0u0fyte51uh0ePPOKmOWASgheIDaEYscs0POwCKrOtJSPidadKNugxfy4kny55tHotejdKdN5dtHD4Oe88xxlny55tHoSnpfQzwgKOrNgztrgaM0KlWMiYRPoOjstrbeP58u3PRSeqFGNSKyyW08uOJ3KlhSkUtPpYnTAIizGC4egSedxK8ynUQorUj5rWY68u3PRSeqFonb0I86fyte51uh0ePPOaI0CEiKIWPzxcEYsIHbtZtHoEtUCWQ4oL(i30QjIKbYHtyWsmCrYJ14Q6e5MKhblRZdHueon7sNMaArE9cSjI8AQdAI0uuarAovwckOv5cHUKh7a8KLKhblRJObDkFvAaXUma5ikwGz6(mHwG0aAQ9zstP2xy9(bmllr4(G1(fxGDKMAFpcwwk47JMa0(kJgzxUpatUpffxRPU9N5IuLY1q9(GmOEFXPr9(rYJ7B09T9dywwIW9JB)PiwSFg7drtBEk0TaBIiVM6GMinffqKMZAbsdOPQctPapzjXWGP5PqhVjxoyvCNsFKBA1erYa5WjmyjgUi5XACvDICtcGjxGnrKxtDqtKMIcisZzqH1yTGqrrWtwsMisgyfBKprkGj5hhoCbjA0Pr2uKbGjnPmirNIAXrgHonYMImamjG8myEb2erEn1bnrAkkGinhBcrp1DAWtwsmmyAEk0XBYLdwf3P0h5MwnrKmqoCcdwIHlsESgxvNi3K8iyzDSje9u3PDAcOf51lWMiYRPoOjstrbeP58SY6XwdykMsbpzj5rWY6iAqNYxLgqSldqoIczMisgyfBKprkjawGxGzkt3Fcy2tXGUaBIiVM6cy2tXGsIGI1mqEWBJhjLnvajcZtHvGMW6GGVQrgPabpzjXL4oL(i3oIg0P8v9uzjOWbrElBkhoI7u6JC70gCAnGwtzpiVf51oiYBztzwgxfy4miVVAjOJq5mrKmqoCkWWzfNOwc6iuotejdu28HPWoCgK3x9yRbiSQn(g1C4egSedxK8ynUAHiQ(ndUNKzoC8okvgBwckQqK3YMYTFaSaBIiVM6cy2tXGcisZrqXAgip4TXJK4nH5bXkfeIrLNGMcWtwsI7u6JC7SItykFfu0brElBk3tkJR5rGMilkqTlBQaseMNcRanH1bbFvJmsbYHJ4oL(i3USPciryEkSc0ewhe8vnYifOdI8w2uM5WX7OuzSzjOOcrElBk3(bWcSjI8AQlGzpfdkGinhbfRzG8G3gpssdrtZMqSYaPuubEYssCNsFKBNvCct5RGIoiYBztLX18iqtKffO2LnvajcZtHvGMW6GGVQrgPa5WrCNsFKBx2ubKimpfwbAcRdc(QgzKc0brElBkZC44DuQm2SeuuHiVLnLB5SaBIiVM6cy2tXGcisZrqXAgip4TXJK0gCk)DDvJIPvgh0ez4d8KLK4oL(i3oR4eMYxbfDqK3YMkJR5rGMilkqTlBQaseMNcRanH1bbFvJmsbYHJ4oL(i3USPciryEkSc0ewhe8vnYifOdI8w2uM5WX7OuzSzjOOcrElBk3(bWcSjI8AQlGzpfdkGinhbfRzG8uWtwsCjUtPpYTZkoHP8vqrhe5TSPC44rWY60gCAnGwtzpiVf51oIcMLX18iqtKffO2LnvajcZtHvGMW6GGVQrgPa5WrCNsFKBx2ubKimpfwbAcRdc(QgzKc0brElBkZlWmLP7pXmfSNPZAbMPmD)jaH7hWSNIX(KZa0(biCFqzjiKg7J0i5Ta17ZWuei47tovQ99W9jOOEF2esJ9TwVFHLquVp5maTptO4eMYxbf3NRKDFpcw29t6(am5(uuCTMU)b3xHukZ7FW9bJklbfZb2tSpxj7(Lq0ceUFaY69byY9PO4AnL5fyMY09nrKxtDbm7PyqbeP5iOyndKhCQ6csbm7Pyaa4jlP5zyW08uOJwGIKnrDnGzpfdzCXvaZEkgoaCfWt4S2xvxqDAcOf51CtcGjLjUtPpYTZkoHP8vqrhe5TSPa2VzWHtaZEkgoaCfWt4S2xvxqDAcOf51agGjLXL4oL(i3oIg0P8v9uzjOWbrElBkG9BgC4iUtPpYTtBWP1aAnL9G8wKx7GiVLnfW(ndMzwgxZhWSNIHZphiJwf3P0h5MdNaM9umC(5e3P0h52brElBkhommyAEk0fWSNIrTaMhmdFKaGzM5WjGzpfdhaUc4jCw7RQlOonb0I8AatInlbfviYBztxGzkt33erEn1fWSNIbfqKMJGI1mqEWPQlifWSNIHFGNSKMNHbtZtHoAbks2e11aM9umKXfxbm7Py48ZvapHZAFvDb1PjGwKxZnjaMuM4oL(i3oR4eMYxbfDqK3YMcy)Mbhobm7Py48ZvapHZAFvDb1PjGwKxdyaMugxI7u6JC7iAqNYx1tLLGche5TSPa2VzWHJ4oL(i3oTbNwdO1u2dYBrETdI8w2ua73myMzzCnFaZEkgoaCGmAvCNsFKBoCcy2tXWbGtCNsFKBhe5TSPC4WWGP5PqxaZEkg1cyEWm8rYpMzMdNaM9umC(5kGNWzTVQUG60eqlYRbmj2SeuuHiVLnDbMPmD)zg7(xR8T)14(xVpbf3pGzpfJ9lGhJuJ09T99iyzbFFckUFac3)cqiC)R3xCNsFKB3(Zu4(j7(nMbieUFaZEkg7xapgPgP7B77rWYc((euCFVlaT)17lUtPpYTBbMPmDFte51uxaZEkguarAockwZa5bNQUGuaZEkgaaEYsA(aM9umCa4az0kbfREeSSY4kGzpfdNFoXDk9rUDqK3YMYHZ8bm7Py48ZbYOvckw9iyzzEbMPmDFte51uxaZEkguarAockwZa5bNQUGuaZEkg(bEYsA(aM9umC(5az0kbfREeSSY4kGzpfdhaoXDk9rUDqK3YMYHZ8bm7Py4aWbYOvckw9iyzzEizebOdoKKsEcLf51mj0yJrmIXaa]] )

end
