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


    spec:RegisterPack( "Unholy", 20210413, [[deLvocqiLQ6rOiDjavuBIO8jPOgfrLtrGwLsvWRauMfq1TiaAxc(LsLgMuKogGSmIQEgb00ak11uQyBkvrFdiQmoPikNdqfzDarEhbiY8qrDpezFaHdcOsleO4HOiAIkvPlcevTrPiQ8rcqAKsru1jLIiRei9sPiuntGOCtcqu7uPWpLIGHsaQLcOcpLitvPORkfHSvcq4RkvHglqj7vj)vQgSQomvlwipgvtMKldTzu6Zc1Ob40IwnbGxRuA2K62eA3s(TkdxkDCuewoONJ00PCDe2oI67OW4bu15LcRxkcL5tq7xXlGwBUKuUHRnKVPYdutbBGeyqEGKhSf4sYA0IlPwNV1JXLu5I4sQjQaC6glPwVH(C1AZLe9iGCCjbWSwkiT7UXPbGikWpXDPPiH2T8ko0zTDPPiF3LuerQTMuTIwsk3W1gY3u5bQPGnqcmipqYd2nf40sI2I81gYVJ8ljaPsH1kAjPqkFjTx0naZ3eVYya28nrfGt3yaf42ct98ajp4ZlFtLhOb0buMeGxXifKgqfGZdCvcacQjILrN3U53BT3D3lYMAC39IUbGo)EjW5TB(R0nMNFeLnV5Wy0OZZaWnVdX5rGVf5gQM3U51jzCE9vXZJ1redyE7Mx0ndHZlNFyNIgr78mfibddOcW53Bs9inQMxY5WKn5PRNxa7CB(iK7euCEf6Q5JbCeA68I(wCE2dop1vZV3M40WaQaC(MiAwXZVhpIsnVulwkeoVhL60sKoV4bX5z1iWNr6gZlNBZd2aBEQ58T05ZIAORM)yNFhGjOasZVxbS08fsyqxpVxQ5f9gZ3crYyzZtprC(6eGqKppnnc3YROHbub48nr0SINVjhsneMv88sgm3IZN18a3Mai)8j78noI5b4KX5RZaKv88OMIZB38QBEVuZZ4QMT5pYiK7TZZ4ikfD(Ko)EfWsZxiHbDDyavaoptcWRyunVOxnMVz2mgG1HOONfT555xPslVY105TBEVTv3y(SMp6O05zZyagD(R0nMxonsPZZK7DEgo1W5VAEd6uacggqfGZdCvkunVxNbaHZ3eiSii6BNhld2yE7MNI28eTZtn4vXiCEq(2uHIjNggqfGZVztyVnbqA(53azmVbZAlAZZHPHW0dljDsn6AZLKFyNIgr7AZ1gaT2CjHLhPr1cmljomneM(ssHUbOVTYyawGLXruku1nhgJgDEqqAEEdUg7yHIjsNxOW5HEQ6izSSGRu0ac8j1OZlBEONQosgll4kfnarrpl68mtAEGaAj5ClVAj5vJUQulBTH8Rnxsy5rAuTaZsIdtdHPVKuOBa6BRmgGfyzCeLcvDZHXOrNheKMFNLKZT8QLKxn6QsTS1gcCT5sclpsJQfywsCyAim9L0(Zt2HPhPXq7D6SI7qIk592JbcNx28YnFeblBq5WTDd6fL9GIULxfiANx28qIczpymguOR0jsTo)sDalpsJQ5LnVZTKm2XcftKopZKMxGZlu48o3sYyhlumr68KMx(5fCj5ClVAjPq3a05xQx2AdWET5sclpsJQfywsCyAim9L0(Zt2HPhPXq7D6SI7qIk592Jbcxso3YRwsyBQqXKVS1g7S2CjHLhPr1cmljNB5vljwKAimR4o1G5wCjXHPHW0xskmIGLnWIudHzf3zCeLkqnNVDEMjnVaNx28870QJrf82J76gTumarrpl68mpVaxs8gCn2nhgJgDTbqlBTXEU2CjHLhPr1cmljNB5vljwKAimR4o1G5wCjXHPHW0xskmIGLnWIudHzf3zCeLkqnNVDEMNhOLeVbxJDZHXOrxBa0YwBaYT2CjHLhPr1cmljNB5vljwKAimR4o1G5wCjXHPHW0xskmIGLnWIudHzf3zCeLkqnNVDEMjnVaNx28qIcdwkID76G98mpp)oT6yubVA0vLkarrpl6sI3GRXU5Wy0ORnaAzRnAYwBUKWYJ0OAbMLKZT8QLeJJOuDAlwkeUKuiLdZwlVAjThbG18MdJrBEkdVLoVdX5vj1J0Oc85najDEgPwpVgT5BCeZtBXsnpKOq6UmoIsrNplQHUA(JDEgEAzfpp7bNFV1E3DViBQXD3l6gGMPZVxcmSK4W0qy6lj5MF)5POzzftd8gCnoVqHZRq3a03wzmalWY4ikfQ6MdJrJopiinpVbxJDSqXePZl48YMxHreSSbwKAimR4oJJOubQ58TZdI5f48YMhsuyWsrSBxxGZZ88870QJrf8QrxvQaef9SOlBzlj)WEebKARnxBa0AZLewEKgvlWSK4W0qy6lj5MpIGLnqjukS6Q7edq0528cfo)(Zt2HPhPXq7D6SI7qIk592JbcNxW5LnVCZhrWYguoCB3GErzpOOB5vbI25LnpKOq2dgJbf6kDIuRZVuhWYJ0OAEzZ7CljJDSqXePZZmP5f48cfoVZTKm2XcftKopP5LFEbxso3YRwsk0naD(L6LT2q(1MljS8inQwGzjXHPHW0xsqIk592JbcdkKn5PnpZZl38a105b28k0na9TvgdWcSmoIsHQU5Wy0OZVhMxGZl48YMxHUbOVTYyawGLXruku1nhgJgDEMNFpNx287ppzhMEKgdT3PZkUdjQK3BpgiCEHcNpIGLnqz4qXSI7Ij1ceTljNB5vljSnvOyYx2AdbU2CjHLhPr1cmljomneM(scsujV3EmqyqHSjpT5zEE53zEzZRq3a03wzmalWY4ikfQ6MdJrJopiMFN5Ln)(Zt2HPhPXq7D6SI7qIk592Jbcxso3YRwsyBQqXKVS1gG9AZLewEKgvlWSK4W0qy6lP9NxHUbOVTYyawGLXruku1nhgJgDEzZV)8KDy6rAm0ENoR4oKOsEV9yGW5fkCE2mgG1HOONfDEMNFN5fkCEONQosgll4kfnGaFsn68YMh6PQJKXYcUsrdqu0ZIopZZVZsY5wE1scBtfkM8LT2yN1MljNB5vljghrP60wSuiCjHLhPr1cmlBTXEU2CjHLhPr1cmljomneM(sA)5j7W0J0yO9oDwXDirL8E7XaHljNB5vljSnvOyYx2Yws870QJrrxBU2aO1MljS8inQwGzjXHPHW0xsKDy6rAmi6cGd253PvhJI2DULKX5fkC(OJsNx28SzmaRdrrpl68mpV875sY5wE1sQ9S8QLT2q(1MljS8inQwGzjXHPHW0xs870QJrfikaNUrpsNXaSaef9SOZZ887mVS553PvhJkOC42Ub9IYEqr3YRcqu0ZI2rGVf5gQMN553zEzZBUgllquaoDJEKoJbybS8inQMxOW53FEZ1yzbIcWPB0J0zmalGLhPr18cfoF0rPZlBE2mgG1HOONfDEMNxG7SKCULxTKCOyJ(X2nayxHUAzRne4AZLewEKgvlWSKCULxTKOhHUdrVfHljomneM(sYCymAblfXUD9wU1f4oZZ887mVS5nhgJwWsrSBxxL48Gy(DMx28o3sYyhlumr68mtAEbUK4n4ASBomgn6AdGw2AdWET5sclpsJQfywso3YRwsefGt3OhPZya2ssHuomBT8QLut(tROZdgDgdWMN9GZt0oVDZVZ8uKFLIoVDZtBu85zKgG5bUTh31nAPi4Z3emaiKrsrWNNGIZZinaZVxhUD(nHErzpOOB5vHLehMgctFjr2HPhPXa16TAVQSINx28Ynp)oT6yubV94UUrlfdqu0ZI2rGVf5gQMN553zEHcNNFNwDmQG3ECx3OLIbik6zr7iW3ICdvZdI5bQPZl48YMxU553PvhJkOC42Ub9IYEqr3YRcqu0ZIopZZhZvZlu48reSSbLd32nOxu2dk6wEvGODEbx2AJDwBUKWYJ0OAbMLehMgctFj5CljJDSqXePZdcsZl)8cfoF0rPZlBE2mgG1HOONfDEMNxEGwso3YRwsefGt3OhPZya2YwBSNRnxsy5rAuTaZsIdtdHPVKi7W0J0yGA9wTxvwXZlBE5MxDwGOaC6g9iDgdW6QZcqu0ZIoVqHZV)8MRXYcefGt3OhPZyawalpsJQ5fCj5ClVAjPC42Ub9IYEqr3YRw2AdqU1MljS8inQwGzjXHPHW0xso3sYyhlumr68GG08YpVqHZhDu68YMNnJbyDik6zrNN55LhOLKZT8QLKYHB7g0lk7bfDlVAzRnAYwBUKWYJ0OAbMLehMgctFj5CljJDSqXePZtAEGMx28kmIGLnWIudHzf3zCeLkqnNVDEqmVaxso3YRwsE7XDDJwkUS1gaNwBUKWYJ0OAbMLKZT8QLK3ECx3OLIljomneM(sY5wsg7yHIjsNheKMx(5LnVcJiyzdSi1qywXDghrPcuZ5BNheZlW5Ln)(ZRq3a09s1vi3BeSKVnR4LeVbxJDZHXOrxBa0YwBautxBUKWYJ0OAbMLehMgctFjbjQK3BpgimOq2KN28mppqG98YMxU553PvhJkquaoDJEKoJbybik6zrNN55bQPZlu48QZcefGt3OhPZyawxDwaIIEw05fCj5ClVAjrjefVQh7W4RHgx2AdGaAT5sclpsJQfywsCyAim9LezhMEKgduR3Q9QYkEEzZRWicw2alsneMvCNXruQa1C(25zEE5Nx28YnFlAbV949yahHo4CljJZlu48reSSbLd32nOxu2dk6wEvGODEzZV)8TOfCOyJEmGJqhCULKX5fCj5ClVAjruaoDJUtPoH2w2AdGKFT5sclpsJQfywso3YRwsefGt3O7uQtOTLehMgctFj5CljJDSqXePZdcsZl)8YMxHreSSbwKAimR4oJJOubQ58TZZ88YVK4n4ASBomgn6AdGw2AdGe4AZLewEKgvlWSK4W0qy6lP9NVfTqmGJqhCULKXLKZT8QLe0tk2vORw2YwsXyHWKV2CTbqRnxsy5rAuTaZsIdtdHPVKIiyzducLcRU6oXaeDUnVS53FEYom9ingAVtNvChsujV3Emq48cfoFlAHyhgFn0yW5wsgxso3YRwsk0naD(L6LT2q(1MljS8inQwGzjXHPHW0xs8JmwEzHkJbyDwhNx28870QJrfuOBaODfbgGOONfDEMNxGZlBEirL8E7XaHbfYM80MN55bQPljNB5vljf6gGo)s9YwBiW1MljS8inQwGzjXHPHW0xsYnV5ASSGcztngWYJ0OAEHcNNFKXYlluzmaRZ648cfopKOq2dgJHwaOdpXRqAalpsJQ5fCEzZl387ppzhMEKgdT3PZkUdjkKoVqHZZMXaSoef9SOZZ887mVGljNB5vljVA0vLAzRna71MljS8inQwGzjXHPHW0xs8JmwEzHkJbyDwhNx28qIk592JbcdkKn5PnpZZlFtNx287ppzhMEKgdT3PZkUdjQK3BpgiCj5ClVAjPq3a05xQx2AJDwBUKWYJ0OAbMLehMgctFjXpYy5LfQmgG1zDCEzZZVtRogvqHUbG2veyaIIEw05zEEGA68YMxHreSSbwKAimR4oJJOubQ58TZZ88G98YMF)5j7W0J0yO9oDwXDirH05LnVCZV)8k0naDVuDfY9gbl5BZkEEHcNpIGLnOq3aq7kcmqnNVDEsZd2Zl4sY5wE1sIfPgcZkUtnyUfx2AJ9CT5sclpsJQfywsCyAim9LeKOsEV9yGWGcztEAZZ88ajW5fkCE2mgG1HOONfDEMNFN5Ln)(ZRWicw2alsneMvCNXruQar7sY5wE1ssHUbOZVuVS1gGCRnxsy5rAuTaZsIdtdHPVKuyeblBGfPgcZkUZ4ikvGAoF78GyEboVS53FEYom9ingAVtNvChsuiDj5ClVAjX4ikvN2ILcHlBTrt2AZLewEKgvlWSK4W0qy6ljfgrWYgyrQHWSI7moIsfiANx28870QJrf82J76gTumarrplAhb(wKBOAEqm)oZlB(9NNSdtpsJH270zf3Hefsxso3YRwsmoIs1PTyPq4YwBaCAT5sclpsJQfywsCyAim9LeKOsEV9yGWGcztEAZZ88Y305Ln)(Zt2HPhPXq7D6SI7qIk592Jbcxso3YRwsk0naD(L6LT2aOMU2CjHLhPr1cmljomneM(ssHreSSbwKAimR4oJJOubQ58TZZ88anVS53FEYom9ingAVtNvChsuiDj5ClVAjXIudHzf3Pgm3IlBTbqaT2CjHLhPr1cmljomneM(ssHreSSbwKAimR4oJJOubQ58TZZ88G98YMNFNwDmQG3ECx3OLIbik6zr7iW3ICdvZZ887mVS53FEYom9ingAVtNvChsuiDj5ClVAjXIudHzf3Pgm3IlBTbqYV2CjHLhPr1cmljomneM(sA)5j7W0J0yO9oDwXDirL8E7XaHljNB5vljf6gGo)s9Yw2sIFKXYlJU2CTbqRnxsy5rAuTaZsIdtdHPVKi7W0J0yGA9wTxvwXZlBEirL8E7XaHbfYM80MheZd0EoVS5LBE(DA1XOcE7XDDJwkgGOONfDEHcNF)5nxJLfCOyJ(X2nayx5IfQcy5rAunVS553PvhJkOC42Ub9IYEqr3YRcqu0ZIoVGZlu48rhLoVS5zZyawhIIEw05zEEGaAj5ClVAjrz4qXSI7Ij1w2Ad5xBUKWYJ0OAbMLKZT8QLeLHdfZkUlMuBjPqkhMTwE1sscT5TBEckoVZAiCEV94ZN05VAEMCVZ705TB(wisglB(Jmc5EBBwXZdCiGNNbGuJZtrZYkEEI25zY92mDjXHPHW0xs870QJrf82J76gTumarrpl68YMxU5DULKXowOyI05bbP5LFEzZ7CljJDSqXePZZmP53zEzZdjQK3BpgimOq2KN28GyEGA68aBE5M35wsg7yHIjsNFpm)EoVGZlu48o3sYyhlumr68Gy(DMx28qIk592JbcdkKn5PnpiMhSB68cUS1gcCT5sclpsJQfywsCyAim9LezhMEKgduR3Q9QYkEEzZV)80JqhLLkOrx1JA0rG3fB1yalpsJQ5LnVCZZVtRogvWBpURB0sXaef9SOZlu487pV5ASSGdfB0p2Uba7kxSqvalpsJQ5Lnp)oT6yubLd32nOxu2dk6wEvaIIEw05fCEzZdjkmyPi2TRd2ZdI5LBEbopWMpIGLnajQK35hes0A5vbik6zrNxW5fkC(OJsNx28SzmaRdrrpl68mpV8aTKCULxTK8Otml3YR66umAzRna71MljS8inQwGzjXHPHW0xsKDy6rAmqTER2RkR45Lnp9i0rzPcA0v9OgDe4DXwngWYJ0OAEzZl38QZcefGt3OhPZyawxDwaIIEw05bX8ab08cfo)(ZBUgllquaoDJEKoJbybS8inQMx28870QJrfuoCB3GErzpOOB5vbik6zrNxWLKZT8QLKhDIz5wEvxNIrlBTXoRnxsy5rAuTaZsIdtdHPVKCULKXowOyI05bbP5LFEzZdjkmyPi2TRd2ZdI5LBEbopWMpIGLnajQK35hes0A5vbik6zrNxWLKZT8QLKhDIz5wEvxNIrlBTXEU2CjHLhPr1cmljomneM(sISdtpsJbQ1B1EvzfpVS5LBE(DA1XOcE7XDDJwkgGOONfDEHcNF)5nxJLfCOyJ(X2nayx5IfQcy5rAunVS553PvhJkOC42Ub9IYEqr3YRcqu0ZIoVGZlu48rhLoVS5zZyawhIIEw05zEEG2zj5ClVAjrb48TASBaWorX4GgGglBTbi3AZLewEKgvlWSK4W0qy6ljNBjzSJfkMiDEqqAE5Nx28YnVcDdq3lvxHCVrWs(2SINxOW5HEQ6izSSGRu0aef9SOZZmP5bcSNxWLKZT8QLefGZ3QXUba7efJdAaASSLTKAHi)eJCBT5AdGwBUKCULxTKAplVAjHLhPr1cmlBTH8Rnxso3YRwsqpPyxHUAjHLhPr1cmlBzljOZtxtxBU2aO1MljS8inQwGzj5ClVAj5qUxy3oielBjPqkhMTwE1sc4W5PRPljomneM(scsujV3EmqyqHSjpT5bX875oZlBE5MVfTqSdJVgAm4CljJZlu487pV5ASSaLqu8QESdJVgAmGLhPr18coVS5HefguiBYtBEqqA(Dw2Ad5xBUKWYJ0OAbMLehMgctFjr2HPhPXGOlaoyNFNwDmkA35wsgNxOW5nhgJwWsrSBxxL48mtA(icw2qK(ovNLa2iOiGULxTKCULxTKI03P6SeWglBTHaxBUKWYJ0OAbMLehMgctFjr2HPhPXGOlaoyNFNwDmkA35wsgNxOW5nhgJwWsrSBxxL48mtA(icw2qecPiCBwXbfb0T8QLKZT8QLuecPiCBwXlBTbyV2CjHLhPr1cmljomneM(skIGLnquaoDJo1GyfBaceTljNB5vljDgdWODbaHkwelBzRn2zT5sclpsJQfywso3YRwsEXrQbDDN7A9ssHuomBT8QLeWT4i1GUEEM01655EnVbZ4yeopypF7zyzPRNpIGLLc(8OZbmV2PwwXZd0oZtr(vkAy(Mil1ztmunpahQMNFkunVLI48oDEFEdMXXiCE7MFlITZN28q0vEKgdljomneM(sISdtpsJbrxaCWo)oT6yu0UZTKmoVqHZBomgTGLIy3UUkX5zM08aTZYwBSNRnxsy5rAuTaZsIdtdHPVKCULKXowOyI05bbP5LFEHcNxU5HefguiBYtBEqqA(DMx28qIk592JbcdkKn5Pnpiin)E205fCj5ClVAj5qUxyVLqtXLT2aKBT5sclpsJQfywsCyAim9LezhMEKgdIUa4GD(DA1XOODNBjzCEHcN3CymAblfXUDDvIZZmP5JiyzdSjeJ03PckcOB5vljNB5vlj2eIr67ulBTrt2AZLewEKgvlWSK4W0qy6lPicw2arb40n6udIvSbiq0oVS5DULKXowOyI05jnpqljNB5vlPipUFSDdM8T0LTSLKbZAlA01MRnaAT5sclpsJQfywso3YRwszr5qcZJ0yNji8Yie7kKCYXLehMgctFjj38870QJrfikaNUrpsNXaSaef9SOZlu48870QJrfuoCB3GErzpOOB5vbik6zrNxW5LnVCZ3IwWHIn6XaocDW5wsgNxOW5Brl4ThVhd4i0bNBjzCEzZV)8MRXYcouSr)y7gaSRCXcvbS8inQMxOW5nhgJwWsrSBxVLBD5B68mp)oZl48cfoF0rPZlBE2mgG1HOONfDEMNxEGwsLlIlPSOCiH5rASZeeEzeIDfso54YwBi)AZLewEKgvlWSKCULxTKeDUhbXofaIwxKGM8LehMgctFjXVtRogvWBpURB0sXaef9SOZZ887mVS5LB(9NhzcISTfvHSOCiH5rASZeeEzeIDfso548cfop)oT6yuHSOCiH5rASZeeEzeIDfso5yaIIEw05fCEHcNp6O05LnpBgdW6qu0ZIopZZlpqlPYfXLKOZ9ii2Paq06Ie0KVS1gcCT5sclpsJQfywso3YRwski6k2eIDYiLI6LehMgctFjXVtRogvWBpURB0sXaef9SOZlBE5MF)5rMGiBBrvilkhsyEKg7mbHxgHyxHKtooVqHZZVtRogvilkhsyEKg7mbHxgHyxHKtogGOONfDEbNxOW5JokDEzZZMXaSoef9SOZZ88cCjvUiUKuq0vSje7Krkf1lBTbyV2CjHLhPr1cmljNB5vljLd3kEx1viFBN8bDEAnwsCyAim9Le)oT6yubV94UUrlfdqu0ZIoVS5LB(9NhzcISTfvHSOCiH5rASZeeEzeIDfso548cfop)oT6yuHSOCiH5rASZeeEzeIDfso5yaIIEw05fCEHcNp6O05LnpBgdW6qu0ZIopZZlpqlPYfXLKYHBfVR6kKVTt(GopTglBTXoRnxsy5rAuTaZsIdtdHPVKKBE(DA1XOcE7XDDJwkgGOONfDEHcNpIGLnOC42Ub9IYEqr3YRceTZl48YMxU53FEKjiY2wufYIYHeMhPXotq4Lri2vi5KJZlu48870QJrfYIYHeMhPXotq4Lri2vi5KJbik6zrNxWLKZT8QLebf7PHI0LTSLKczDcTT2CTbqRnxso3YRwsIzP6SqeBIHljS8inQwGzzRnKFT5sclpsJQfywsx7sII2sY5wE1sISdtpsJljYUMaxsYnpYeezBlQczr5qcZJ0yNji8Yie7kKCYX5Lnp)oT6yuHSOCiH5rASZeeEzeIDfso5yaIUQX8cUKuiLdZwlVAjjGHizSS5PTipztunVbZAlA05JWSINNGIQ5zKgG5Dc7eDl5ZRZcPljYoSxUiUKOTipztu1nywBrBzRne4AZLewEKgvlWSKU2LefTLKZT8QLezhMEKgxsKDnbUK43PvhJkqjefVQh7W4RHgdqu0ZIopZZVZ8YM3CnwwGsikEvp2HXxdngWYJ0OAjr2H9YfXLu7D6SI7qIk592Jbcx2AdWET5sclpsJQfywsx7sII2sY5wE1sISdtpsJljYUMaxsMRXYc0Jq3HO3IWawEKgvZlBEirHZZ88YpVS5nhgJwWsrSBxVLBDbUZ8mp)oZlBE2mgG1HOONfDEqm)oljYoSxUiUKAVtNvChsuiDzRn2zT5sclpsJQfywsx7sII2sY5wE1sISdtpsJljYUMaxso3sYyhlumr68KMhO5LnVCZV)8qpvDKmwwWvkAab(KA05fkCEONQosgll4kfnK18GyEG2zEbxsKDyVCrCjrTER2RkR4LT2ypxBUKWYJ0OAbML01UKOOTKCULxTKi7W0J04sISRjWLulAHyhgFn0yW5wsgNxOW5JiyzdefGt3O7uQtOTar78cfoV5ASSGdfB0p2Uba7kxSqvalpsJQ5LnFlAbV949yahHo4CljJZlu48reSSbLd32nOxu2dk6wEvGODjr2H9YfXLKOlaoyNFNwDmkA35wsgx2AdqU1MljS8inQwGzj5ClVAjDewee9Tljfs5WS1YRwsci7zzEwzfpVaIesOXYMxaR9ycC(KoVpFlmpyAnwsCyAim9LK6Sa5esOXY6TApMadqKfIuaEKgNx287pV5ASSarb40n6r6mgGfWYJ0OAEzZV)8qpvDKmwwWvkAab(KA0LT2OjBT5sclpsJQfywso3YRwshHfbrF7sIdtdHPVKuNfiNqcnwwVv7XeyaISqKcWJ048YM35wsg7yHIjsNheKMx(5LnVCZV)8MRXYcefGt3OhPZyawalpsJQ5fkCEZ1yzbIcWPB0J0zmalGLhPr18YMNFNwDmQarb40n6r6mgGfGOONfDEbxs8gCn2nhgJgDTbqlBTbWP1MljS8inQwGzj5ClVAjDewee9TljDwyNRws75sIdtdHPVKCULKXU6Sa5esOXY6TApMaNN55DULKXowOyI05LnVZTKm2XcftKopiinV8ZlBE5MF)5nxJLfikaNUrpsNXaSawEKgvZlu48MRXYcefGt3OhPZyawalpsJQ5Lnp)oT6yubIcWPB0J0zmalarrpl68cUKuiLdZwlVAj1KyN3aGqCEhIZJfkMiDEXKsZkEEbecyWN3BB1nMpT5LlIWMVU5fpioVbWR5VIJZ3IW53Z5Pi)kfvWWYwBautxBUKWYJ0OAbMLehMgctFjbjkK9GXyGs0IqQb9Scy5rAunVS5LBE1zbw4rTolsgHbiYcrkapsJZlu48QZcr67u9wThtGbiYcrkapsJZl4sY5wE1s6iSii6Bx2AdGaAT5sclpsJQfywso3YRwsmoIs1PTyPq4ssHuomBT8QLeWbYcrkaKo)Er3aqNFVeyZ05JiyzNxaqqT5Jq2dIZRq3aqNxrGZJLIUK4W0qy6lj(rglVSqLXaSoRJZlBEf6gGUxQUc5EJGZTKm2HOONfDEMNxU5J5Q53dZduyN5fCEzZRq3a09s1vi3BeSKVnR4LT2ai5xBUKWYJ0OAbMLef5lj(DA1XOc0Jq3HO3IWaef9SOljNB5vljgEAljomneM(sYCnwwGEe6oe9wegWYJ0OAEzZBomgTGLIy3UEl36cCN5zE(DMx28MdJrlyPi2TRRsCEqm)oZlBE(DA1XOc0Jq3HO3IWaef9SOZZ88YnFmxn)Ey(Mga52zEbNx28o3sYyhlumr68KMhOLT2aibU2CjHLhPr1cmljfs5WS1YRws7rpT5zp487fDdqZ053lbU7Er2uJZNSZVrgdWMVjNJZB38XOnp1GyfBaMpIGLD(iNVDEN6TljkYxs870QJrfuOBaODfbgGOONfDj5ClVAjXWtBjXHPHW0xs8JmwEzHkJbyDwhNx28870QJrfuOBaODfbgGOONfDEMNpMRMx28o3sYyhlumr68KMhOLT2aiWET5sclpsJQfywsuKVK43PvhJkOq2uJbik6zrxso3YRwsm80wsCyAim9Le)iJLxwOYyawN1X5Lnp)oT6yubfYMAmarrpl68mpFmxnVS5DULKXowOyI05jnpqlBTbq7S2CjHLhPr1cmljfs5WS1YRwsaxULxnpilPgDEVuZ3eAXcH05LRj0IfcP7kHmbbwCKoprrjABpOHQ5ZAExPUki4sY5wE1sI7AD35wEvxNuBjPtQ1lxexsgmRTOrx2AdG2Z1MljS8inQwGzj5ClVAjXDTU7ClVQRtQTK0j16LlIlj(rglVm6YwBaei3AZLewEKgvlWSKCULxTK4Uw3DULx11j1ws6KA9YfXLe05PRPlBTbqnzRnxsy5rAuTaZssHuomBT8QLKZT8kAqHSoH2agPDPitqGfhbpzj5CljJDSqXePKas2(k0na9TvgdWcQK6rAS7NPaVCrK01Ifcbjhk2OFSDda2vORajwKAimR4o1G5weKyrQHWSI7udMBrqIOaC6g9iDgdWaP2ZYRajLd32nOxu2dk6wEfi5Th31nAP4sY5wE1sI7AD35wEvxNuBjPtQ1lxexs870QJrrx2AdGaoT2CjHLhPr1cmljomneM(sY5wsg7yHIjsNheKMx(5LnVCZZVtRogvqHUbO7LQRqU3iarrpl68mppqnDEzZV)8MRXYckKn1yalpsJQ5fkCE(DA1XOckKn1yaIIEw05zEEGA68YM3CnwwqHSPgdy5rAunVGZlB(9NxHUbO7LQRqU3iyjFBwXljNB5vljir1DULx11j1ws6KA9YfXLKFyNIgr7YwBiFtxBUKWYJ0OAbMLehMgctFj5CljJDSqXePZdcsZl)8YMxHUbO7LQRqU3iyjFBwXljQbtUT2aOLKZT8QLeKO6o3YR66KAljDsTE5I4sYpShraP2YwBipqRnxsy5rAuTaZsIdtdHPVKCULKXowOyI05bbP5LFEzZl387pVcDdq3lvxHCVrWs(2SINx28Ynp)oT6yubf6gGUxQUc5EJaef9SOZdI5bQPZlB(9N3CnwwqHSPgdy5rAunVqHZZVtRogvqHSPgdqu0ZIopiMhOMoVS5nxJLfuiBQXawEKgvZl48cUKCULxTKGev35wEvxNuBjPtQ1lxexsXyHWK39dx2Ad5LFT5sclpsJQfywsCyAim9LKZTKm2XcftKopP5bAjrnyYT1gaTKCULxTK4Uw3DULx11j1ws6KA9YfXLumwim5lBzlPySqyY7(HRnxBa0AZLewEKgvlWSKOiFjXVtRogvGEe6oe9wegGOONfDj5ClVAjXWtBjXHPHW0xsMRXYc0Jq3HO3IWawEKgvZlBEZHXOfSue721B5wxG7mpZZVZ8YMNnJbyDik6zrNheZVZ8YMNFNwDmQa9i0Di6Timarrpl68mpVCZhZvZVhMVPbqUDMxW5LnVZTKm2XcftKopZKMxGlBTH8Rnxsy5rAuTaZsIdtdHPVKKB(9NNSdtpsJH270zf3HevY7ThdeoVqHZhrWYgOekfwD1DIbi6CBEbNx28YnFeblBq5WTDd6fL9GIULxfiANx28qIczpymguOR0jsTo)sDalpsJQ5LnVZTKm2XcftKopZKMxGZlu48o3sYyhlumr68KMx(5fCj5ClVAjPq3a05xQx2AdbU2CjHLhPr1cmljomneM(skIGLnqjukS6Q7edq0528cfo)(Zt2HPhPXq7D6SI7qIk592Jbcxso3YRwsyBQqXKVS1gG9AZLewEKgvlWSKuiLdZwlVAj1KyN3CymAZZBW1zfpFsNxLupsJkWNNYinoG5JC(25TBEdaopnRynkanhgJ28XyHWKpVoP28zrn0vHLKZT8QLeKO6o3YR66KAljQbtUT2aOLehMgctFjXBW1yhlumr68KMhOLKoPwVCrCjfJfct(YwBSZAZLewEKgvlWSKCULxTKyCeLQtBXsHWLehMgctFjj38870QJrf82J76gTumarrpl68Gy(DMx28kmIGLnWIudHzf3zCeLkq0oVqHZRWicw2alsneMvCNXruQa1C(25bX8cCEbNx28YnpBgdW6qu0ZIopZZZVtRogvqHUbO7LQRqU3iarrpl68aBEGA68cfopBgdW6qu0ZIopiMNFNwDmQG3ECx3OLIbik6zrNxWLeVbxJDZHXOrxBa0YwBSNRnxsy5rAuTaZsY5wE1sIfPgcZkUtnyUfxsCyAim9LKcJiyzdSi1qywXDghrPcuZ5BNNzsZlW5Lnp)oT6yubV94UUrlfdqu0ZIopZZlW5fkCEfgrWYgyrQHWSI7moIsfOMZ3opZZd0sI3GRXU5Wy0ORnaAzRna5wBUKWYJ0OAbMLKZT8QLelsneMvCNAWClUK4W0qy6lj(DA1XOcE7XDDJwkgGOONfDEqm)oZlBEfgrWYgyrQHWSI7moIsfOMZ3opZZd0sI3GRXU5Wy0ORnaAzRnAYwBUKWYJ0OAbMLKZT8QLelsneMvCNAWClUKuiLdZwlVAjTjGKoFsNhzzrULKrDJ5ztTgHZZaqYbmpnfPZVxbS08fsyqxd(8re28uahHwnFlejJLnVppLJLdZBEgaqioVbaN3vQRMhGtNVodqwXZB38qKFIIyPcljomneM(sY5wsg7QZcSi1qywXDghrPMheKMN3GRXowOyI05LnVcJiyzdSi1qywXDghrPcuZ5BNN55b7LTSLTKiJqAE1Ad5BQ8a1uWUPcCjXWHvwX0L0Ee4cCSrtAdbuqA(53eaoFk2EqBE2doFZ(HDkAeTnppezcIeIQ5PNioVtyNOBOAEoaVIrAyafKLfoVabP5zYRiJqdvZ3mKOq2dgJbWQ55TB(MHefYEWymawbS8inQAEE5ac4fmmGoGUhbUahB0K2qafKMF(nbGZNITh0MN9GZ3SFypIasTMNhImbrcr180teN3jSt0nunphGxXinmGcYYcNhiqAEM8kYi0q18ndjkK9GXyaSAEE7MVzirHShmgdGvalpsJQMNxoGaEbddOdO7rGlWXgnPneqbP5NFta48Py7bT5zp48nBWS2IgT55HitqKqunp9eX5Dc7eDdvZZb4vmsddOGSSW5bcKMNjVImcnunFZMRXYcGvZZB38nBUgllawbS8inQAEE5ac4fmmGoGUhbUahB0K2qafKMF(nbGZNITh0MN9GZ3Cmwim5nppezcIeIQ5PNioVtyNOBOAEoaVIrAyafKLfoVabP5zYRiJqdvZ3mKOq2dgJbWQ55TB(MHefYEWymawbS8inQAEE5ac4fmmGoGUhbUahB0K2qafKMF(nbGZNITh0MN9GZ3m)iJLxgT55HitqKqunp9eX5Dc7eDdvZZb4vmsddOGSSW5bcKMNjVImcnunFZMRXYcGvZZB38nBUgllawbS8inQAEE5ac4fmmGcYYcNxGG08m5vKrOHQ5B2CnwwaSAEE7MVzZ1yzbWkGLhPrvZZlhqaVGHbuqww48ceKMNjVImcnunFZ0JqhLLkawnpVDZ3m9i0rzPcGvalpsJQMNxoGaEbddOGSSW5bBqAEM8kYi0q18nBUgllawnpVDZ3S5ASSayfWYJ0OQ55LdiGxWWakillCEWgKMNjVImcnunFZ0JqhLLkawnpVDZ3m9i0rzPcGvalpsJQMNxoGaEbddOGSSW53tqAEM8kYi0q18nBUgllawnpVDZ3S5ASSayfWYJ0OQ55LdiGxWWa6a6Ee4cCSrtAdbuqA(53eaoFk2EqBE2doFZ870QJrrBEEiYeejevZtprCENWor3q18CaEfJ0WakillCE5bP5zYRiJqdvZ3S5ASSay1882nFZMRXYcGvalpsJQMNxo5bEbddOGSSW53tqAEM8kYi0q18nBUgllawnpVDZ3S5ASSayfWYJ0OQ55LdiGxWWa6a6Ee4cCSrtAdbuqA(53eaoFk2EqBE2doFZXyHWK39dBEEiYeejevZtprCENWor3q18CaEfJ0WakillCEGaP5zYRiJqdvZ3S5ASSay1882nFZMRXYcGvalpsJQMNxoGaEbddOGSSW5LhKMNjVImcnunFZqIczpymgaRMN3U5Bgsui7bJXayfWYJ0OQ55LdiGxWWa6a6Ee4cCSrtAdbuqA(53eaoFk2EqBE2doFZkK1j0wZZdrMGiHOAE6jIZ7e2j6gQMNdWRyKggqbzzHZlqqAEM8kYi0q18nBUgllawnpVDZ3S5ASSayfWYJ0OQ55DBEq(MaiBE5ac4fmmGcYYcNhSbP5zYRiJqdvZ3S5ASSay1882nFZMRXYcGvalpsJQMNxoGaEbddOGSSW53tqAEM8kYi0q18nBUgllawnpVDZ3S5ASSayfWYJ0OQ55LdiGxWWakillCEqoqAEM8kYi0q18nBUgllawnpVDZ3S5ASSayfWYJ0OQ55LdiGxWWakillC(MmqAEM8kYi0q18nBUgllawnpVDZ3S5ASSayfWYJ0OQ55LtEGxWWakillCEGtG08m5vKrOHQ5B2CnwwaSAEE7MVzZ1yzbWkGLhPrvZZlN8aVGHbuqww48a1uqAEM8kYi0q18ndjkK9GXyaSAEE7MVzirHShmgdGvalpsJQMNxoGaEbddOGSSW5bsEqAEM8kYi0q18nBUgllawnpVDZ3S5ASSayfWYJ0OQ55LdiGxWWakillCEGaobsZZKxrgHgQMVzZ1yzbWQ55TB(MnxJLfaRawEKgvnpVCYd8cggqbzzHZlpqG08m5vKrOHQ5B2CnwwaSAEE7MVzZ1yzbWkGLhPrvZZlN8aVGHb0b0MKy7bnunpqnDENB5vZRtQrddOljNWaCWLKuksODlVIjHoRTKAHhBQXLetz687fDdW8nXRmgGnFtub40ngqzktNh42ct98ajp4ZlFtLhOb0buMY05zsaEfJuqAaLPmDEb48axLaGGAIyz05TB(9w7D39ISPg3DVOBaOZVxcCE7M)kDJ55hrzZBomgn68maCZ7qCEe4BrUHQ5TBEDsgNxFv88yDeXaM3U5fDZq48Y5h2POr0optbsWWaktz68cW53Bs9inQMxY5WKn5PRNxa7CB(iK7euCEf6Q5JbCeA68I(wCE2dop1vZV3M40Waktz68cW5BIOzfp)E8ik18sTyPq48EuQtlr68IheNNvJaFgPBmVCUnpydS5PMZ3sNplQHUA(JD(DaMGcin)EfWsZxiHbD98EPMx0BmFlejJLnp9eX5Rtacr(800iClVIggqzktNxaoFtenR45BYHudHzfpVKbZT48znpWTjaYpFYoFJJyEaozC(6mazfppQP482nV6M3l18mUQzB(Jmc5E78moIsrNpPZVxbS08fsyqxhgqzktNxaoptcWRyunVOxnMVz2mgG1HOONfT555xPslVY105TBEVTv3y(SMp6O05zZyagD(R0nMxonsPZZK7DEgo1W5VAEd6uacggqzktNxaopWvPq18EDgaeoFtGWIGOVDESmyJ5TBEkAZt0op1GxfJW5b5BtfkMCAyaLPmDEb48B2e2BtaKMF(nqgZBWS2I28CyAim9Wa6aQZT8kAOfI8tmYnGrA32ZYRgqDULxrdTqKFIrUbms7c9KIDf6QbuMY05b5j7Ac3q68(8gmRTOrNNFNwDmkWNxLKtfQMpQX8G9oH53eqsNNHtNNd4OynVtNNOaC6gZZ4GBPZF18G9oZtr(vQ5JiGuBEEdUgPGpFeHnpaNoVD38IE1yEUcopYYICJoVDZhNKX59553PvhJka8bfb0T8Q5vj5KEW5ZIAORcZ3KyNpTMPZt21e48aC681npef9SuiCEiAeWAEGaFEutX5HOraR5BAyNWaktz68o3YROHwiYpXi3agPDj7W0J0i4LlIKmywBrRduN2O4GFTKOOLSGt21eijGaNSRjWoQPiPMg2bC(vQ0YRizWS2IwaOaaN2jOypIGLvMCgmRTOfakWVtRogvqraDlVc4mWzWEhsnvWbuMY05DULxrdTqKFIrUbms7s2HPhPrWlxejzWS2Iwx(oTrXb)AjrrlzbNSRjqsabozxtGDutrsnnSd48RuPLxrYGzTfTG8baoTtqXEeblRm5mywBrliFGFNwDmQGIa6wEfWzGZG9oKAQGdOmLPZdYtTu0nKoVpVbZAlA05j7AcC(OgZZpXwhMv88gaCE(DA1XOM)yN3aGZBWS2Ig4ZRsYPcvZh1yEdaoVIa6wE18h78gaC(icw25tB(w4rovinmFtENoVpp1GyfBaMx8ujBIW5TB(4KmoVppGmgacNVfMhmTgZB38udIvSbyEdM1w0OGpVtNNbQ1Z70595fpvYMiCE2doFYoVpVbZAlAZZi165p48msTE(6S5Pnk(8msdW8870QJrrddOmLPZ7ClVIgAHi)eJCdyK2LSdtpsJGxUisYGzTfTElmpyAna)AjrrlzbNSRjqsYdozxtGDutrsabo)kvA5vK23GzTfTaqbaoTtqXEeblRmdM1w0cYha40obf7reSScfAWS2Iwq(aaN2jOypIGLvMCYzWS2Iwq(a)oT6yubfb0T8kGZgmRTOfKp0cpEWRgDvlnOiGULxj4EqoGc7amdM1w0cYha40EeblRG7b5i7W0J0yWGzTfTU8DAJIlOGGqo5mywBrlauGFNwDmQGIa6wEfWzdM1w0cafAHhp4vJUQLgueq3YReCpihqHDaMbZAlAbGcaCApIGLvW9GCKDy6rAmyWS2IwhOoTrXfuWb0b0buMY05b5bEKtyOAEKmcBmVLI48gaCENBhC(KoVt2tThPXWaQZT8kkjXSuDwiInXWbuMoVagIKXYMN2I8Knr18gmRTOrNpcZkEEckQMNrAaM3jSt0TKpVolKoG6ClVIcms7s2HPhPrWlxejrBrEYMOQBWS2Ig4KDnbssoKjiY2wufYIYHeMhPXotq4Lri2vi5KJY43PvhJkKfLdjmpsJDMGWlJqSRqYjhdq0vneCaLPmDEbeom9inshqDULxrbgPDj7W0J0i4LlIKAVtNvChsujV3Emqi4KDnbsIFNwDmQaLqu8QESdJVgAmarrplkZ7iZCnwwGsikEvp2HXxdnoG6ClVIcms7s2HPhPrWlxej1ENoR4oKOqk4KDnbsYCnwwGEe6oe9wekdsuiZYlZCymAblfXUD9wU1f4omVJm2mgG1HOONffe7mG6ClVIcms7s2HPhPrWlxejrTER2RkRyWj7AcKKZTKm2XcftKscizYTp0tvhjJLfCLIgqGpPgvOqONQosgll4kfnKfiaAhbhqDULxrbgPDj7W0J0i4LlIKeDbWb7870QJrr7o3sYi4KDnbsQfTqSdJVgAm4CljJcfgrWYgikaNUr3PuNqBbIwHcnxJLfCOyJ(X2nayx5IfQK1IwWBpEpgWrOdo3sYOqHreSSbLd32nOxu2dk6wEvGODaLPZlGSNL5zLv88cisiHglBEbS2JjW5t68(8TW8GP1ya15wEffyK29iSii6BbpzjPolqoHeASSER2JjWaezHifGhPrz7BUgllquaoDJEKoJbyY2h6PQJKXYcUsrdiWNuJoG6ClVIcms7Eewee9TGZBW1y3CymAusabEYssDwGCcj0yz9wThtGbiYcrkapsJYCULKXowOyIuqqsEzYTV5ASSarb40n6r6mgGjuO5ASSarb40n6r6mgGjJFNwDmQarb40n6r6mgGfGOONfvWbuMoFtIDEdacX5DiopwOyI05ftknR45fqiGbFEVTv3y(0MxUicB(6Mx8G48gaVM)kooFlcNFpNNI8RuubddOo3YROaJ0UhHfbrFl46SWoxrApbpzj5CljJD1zbYjKqJL1B1EmbYSZTKm2XcftKkZ5wsg7yHIjsbbj5Lj3(MRXYcefGt3OhPZyaMqHMRXYcefGt3OhPZyaMm(DA1XOcefGt3OhPZyawaIIEwubhqDULxrbgPDpclcI(wWtwsqIczpymgOeTiKAqplzYPolWcpQ1zrYimarwisb4rAuOq1zHi9DQER2JjWaezHifGhPrbhqz68ahilePaq687fDdaD(9sGntNpIGLDEbab1MpczpioVcDdaDEfbopwk6aQZT8kkWiTlJJOuDAlwkecEYsIFKXYlluzmaRZ6Omf6gGUxQUc5EJGZTKm2HOONfLz5I5Q9aqHDeuMcDdq3lvxHCVrWs(2SIhqDULxrbgPDz4Pbof5K43PvhJkqpcDhIElcdqu0ZIcEYsYCnwwGEe6oe9wekZCymAblfXUD9wU1f4omVJmZHXOfSue721vjcIDKXVtRogvGEe6oe9wegGOONfLz5I5Q9qtdGC7iOmNBjzSJfkMiLeqdOmD(9ON28ShC(9IUbOz687La3DViBQX5t253iJbyZ3KZX5TB(y0MNAqSInaZhrWYoFKZ3oVt92buNB5vuGrAxgEAGtroj(DA1XOck0na0UIadqu0ZIcEYsIFKXYlluzmaRZ6Om(DA1XOck0na0UIadqu0ZIYCmxjZ5wsg7yHIjsjb0aQZT8kkWiTldpnWPiNe)oT6yubfYMAmarrplk4jlj(rglVSqLXaSoRJY43PvhJkOq2uJbik6zrzoMRK5CljJDSqXePKaAaLPZdC5wE18GSKA059snFtOflesNxUMqlwiKUReYeeyXr68efLOT9GgQMpR5DL6QGGdOo3YROaJ0UCxR7o3YR66KAGxUisYGzTfn6aQZT8kkWiTl316UZT8QUoPg4LlIK4hzS8YOdOo3YROaJ0UCxR7o3YR66KAGxUisc68010buMoVZT8kkWiTlfzccS4i4jljNBjzSJfkMiLeqY2xHUbOVTYyawqLupsJD)mf4LlIKUwSqii5qXg9JTBaWUcDfiXIudHzf3Pgm3IGelsneMvCNAWClcsefGt3OhPZyagi1EwEfiPC42Ub9IYEqr3YRajV94UUrlfhqDULxrbgPD5Uw3DULx11j1aVCrKe)oT6yu0buNB5vuGrAxir1DULx11j1aVCrKKFyNIgrl4jljNBjzSJfkMifeKKxMC870QJrfuOBa6EP6kK7ncqu0ZIYmqnv2(MRXYckKn1OqH870QJrfuiBQXaef9SOmdutLzUgllOq2uJckBFf6gGUxQUc5EJGL8TzfpG6ClVIcms7cjQUZT8QUoPg4LlIK8d7reqQbo1Gj3ibe4jljNBjzSJfkMifeKKxMcDdq3lvxHCVrWs(2SIhqDULxrbgPDHev35wEvxNud8YfrsXyHWK39dbpzj5CljJDSqXePGGK8YKBFf6gGUxQUc5EJGL8Tzflto(DA1XOck0naDVuDfY9gbik6zrbbqnv2(MRXYckKn1OqH870QJrfuiBQXaef9SOGaOMkZCnwwqHSPgfuWbuNB5vuGrAxUR1DNB5vDDsnWlxejfJfcto4udMCJeqGNSKCULKXowOyIusanGoGYuMopW9a5NhmeqQnG6ClVIg8d7reqQrsHUbOZVudEYssUicw2aLqPWQRUtmarNBcfUpzhMEKgdT3PZkUdjQK3BpgiuqzYfrWYguoCB3GErzpOOB5vbIwzqIczpymguOR0jsTo)sTmNBjzSJfkMiLzscuOqNBjzSJfkMiLK8coG6ClVIg8d7reqQbms7ITPcfto4jljirL8E7XaHbfYM80ywoGAkWuOBa6BRmgGfyzCeLcvDZHXOr3dcuqzk0na9TvgdWcSmoIsHQU5Wy0OmVNY2NSdtpsJH270zf3HevY7ThdekuyeblBGYWHIzf3ftQfiAhqDULxrd(H9ici1agPDX2uHIjh8KLeKOsEV9yGWGcztEAml)oYuOBa6BRmgGfyzCeLcvDZHXOrbXoY2NSdtpsJH270zf3HevY7ThdeoG6ClVIg8d7reqQbms7ITPcfto4jlP9vOBa6BRmgGfyzCeLcvDZHXOrLTpzhMEKgdT3PZkUdjQK3BpgiuOq2mgG1HOONfL5Deke6PQJKXYcUsrdiWNuJkd6PQJKXYcUsrdqu0ZIY8odOo3YROb)WEebKAaJ0UmoIs1PTyPq4aQZT8kAWpShraPgWiTl2Mkum5GNSK2NSdtpsJH270zf3HevY7ThdeoGoGYuMopW9a5NxcnI2buNB5v0GFyNIgrljVA0vLc8KLKcDdqFBLXaSalJJOuOQBomgnkiiXBW1yhlumrQqHqpvDKmwwWvkAab(KAuzqpvDKmwwWvkAaIIEwuMjbeqdOo3YROb)WofnIwGrAxVA0vLc8KLKcDdqFBLXaSalJJOuOQBomgnkiiTZaQZT8kAWpStrJOfyK2vHUbOZVudEYsAFYom9ingAVtNvChsujV3EmqOm5IiyzdkhUTBqVOShu0T8QarRmirHShmgdk0v6ePwNFPwMZTKm2XcftKYmjbkuOZTKm2XcftKssEbhqDULxrd(HDkAeTaJ0UyBQqXKdEYsAFYom9ingAVtNvChsujV3Emq4aQZT8kAWpStrJOfyK2LfPgcZkUtnyUfbN3GRXU5Wy0OKac8KLKcJiyzdSi1qywXDghrPcuZ5BzMKaLXVtRogvWBpURB0sXaef9SOmlWbuNB5v0GFyNIgrlWiTllsneMvCNAWClcoVbxJDZHXOrjbe4jljfgrWYgyrQHWSI7moIsfOMZ3YmqdOo3YROb)WofnIwGrAxwKAimR4o1G5weCEdUg7MdJrJsciWtwskmIGLnWIudHzf3zCeLkqnNVLzscugKOWGLIy3UoyZm)oT6yubVA0vLkarrpl6aktNFpcaR5nhgJ28ugElDEhIZRsQhPrf4ZBas68msTEEnAZ34iMN2ILAEirH0DzCeLIoFwudD18h78m80YkEE2do)ER9U7Er2uJ7Ux0nantNFVeyya15wEfn4h2POr0cms7Y4ikvN2ILcHGNSKKBFkAwwX0aVbxJcfQq3a03wzmalWY4ikfQ6MdJrJccs8gCn2XcftKkOmfgrWYgyrQHWSI7moIsfOMZ3ccbkdsuyWsrSBxxGmZVtRogvWRgDvPcqu0ZIoGoGYuMoVa(S8QbuNB5v0a)oT6yuusTNLxbEYsISdtpsJbrxaCWo)oT6yu0UZTKmkuy0rPYyZyawhIIEwuMLFphqzktNNjVtRogfDa15wEfnWVtRogffyK21HIn6hB3aGDf6kWtws870QJrfikaNUrpsNXaSaef9SOmVJm(DA1XOckhUTBqVOShu0T8Qaef9SODe4BrUHkM3rM5ASSarb40n6r6mgGju4(MRXYcefGt3OhPZyaMqHrhLkJnJbyDik6zrzwG7mG6ClVIg43PvhJIcms7spcDhIElcbN3GRXU5Wy0OKac8KLK5Wy0cwkID76TCRlWDyEhzMdJrlyPi2TRRsee7iZ5wsg7yHIjszMKahqz68n5pTIopy0zmaBE2dopr782n)oZtr(vk682npTrXNNrAaMh42ECx3OLIGpFtWaGqgjfbFEckopJ0am)ED4253e6fL9GIULxfgqDULxrd870QJrrbgPDjkaNUrpsNXamWtwsKDy6rAmqTER2RkRyzYXVtRogvWBpURB0sXaef9SODe4BrUHkM3rOq(DA1XOcE7XDDJwkgGOONfTJaFlYnubcGAQGYKJFNwDmQGYHB7g0lk7bfDlVkarrplkZXCLqHreSSbLd32nOxu2dk6wEvGOvWbuNB5v0a)oT6yuuGrAxIcWPB0J0zmad8KLKZTKm2XcftKccsYluy0rPYyZyawhIIEwuMLhObuNB5v0a)oT6yuuGrAxLd32nOxu2dk6wEf4jljYom9ingOwVv7vLvSm5uNfikaNUrpsNXaSU6Saef9SOcfUV5ASSarb40n6r6mgGj4aQZT8kAGFNwDmkkWiTRYHB7g0lk7bfDlVc8KLKZTKm2XcftKccsYluy0rPYyZyawhIIEwuMLhObuNB5v0a)oT6yuuGrAxV94UUrlfbpzj5CljJDSqXePKasMcJiyzdSi1qywXDghrPcuZ5BbHahqDULxrd870QJrrbgPD92J76gTueCEdUg7MdJrJsciWtwso3sYyhlumrkiijVmfgrWYgyrQHWSI7moIsfOMZ3ccbkBFf6gGUxQUc5EJGL8TzfpG6ClVIg43PvhJIcms7sjefVQh7W4RHgbpzjbjQK3BpgimOq2KNgZab2YKJFNwDmQarb40n6r6mgGfGOONfLzGAQqHQZcefGt3OhPZyawxDwaIIEwubhqDULxrd870QJrrbgPDjkaNUr3PuNqBGNSKi7W0J0yGA9wTxvwXYuyeblBGfPgcZkUZ4ikvGAoFlZYltUw0cE7X7XaocDW5wsgfkmIGLnOC42Ub9IYEqr3YRceTY2VfTGdfB0JbCe6GZTKmk4aQZT8kAGFNwDmkkWiTlrb40n6oL6eAdCEdUg7MdJrJsciWtwso3sYyhlumrkiijVmfgrWYgyrQHWSI7moIsfOMZ3YS8dOo3YROb(DA1XOOaJ0UqpPyxHUc8KL0(TOfIbCe6GZTKmoGYuMo)EtQhPrf4ZlaiO281zZdrxRBmFDqrxpFecWjNhCEdGBntNNXbnaZ3saPezfpFwcWyxeddOmLPZ7ClVIg43PvhJIcms7sDomztE66ERZnWtwso3sYyhlumrkiijVS9JiyzdkhUTBqVOShu0T8QarRS953PvhJkOC42Ub9IYEqr3YRcq0vnekm6OuzSzmaRdrrplkZXC1a6aktz68m5rglVS5bUrPoTePdOo3YROb(rglVmkjkdhkMvCxmPg4jljYom9ingOwVv7vLvSmirL8E7XaHbfYM80abq7Pm543PvhJk4Th31nAPyaIIEwuHc33CnwwWHIn6hB3aGDLlwOsg)oT6yubLd32nOxu2dk6wEvaIIEwubfkm6OuzSzmaRdrrplkZab0aktNxcT5TBEckoVZAiCEV94ZN05VAEMCVZ705TB(wisglB(Jmc5EBBwXZdCiGNNbGuJZtrZYkEEI25zY92mDa15wEfnWpYy5LrbgPDPmCOywXDXKAGNSK43PvhJk4Th31nAPyaIIEwuzY5CljJDSqXePGGK8YCULKXowOyIuMjTJmirL8E7XaHbfYM80abqnfyY5CljJDSqXeP7H9uqHcDULKXowOyIuqSJmirL8E7XaHbfYM80aby3ubhqDULxrd8JmwEzuGrAxp6eZYT8QUofJapzjr2HPhPXa16TAVQSILTp9i0rzPcA0v9OgDe4DXwnkto(DA1XOcE7XDDJwkgGOONfvOW9nxJLfCOyJ(X2nayx5IfQKXVtRogvq5WTDd6fL9GIULxfGOONfvqzqIcdwkID76GniKtGalIGLnajQK35hes0A5vbik6zrfuOWOJsLXMXaSoef9SOmlpqdOo3YROb(rglVmkWiTRhDIz5wEvxNIrGNSKi7W0J0yGA9wTxvwXYOhHoklvqJUQh1OJaVl2QrzYPolquaoDJEKoJbyD1zbik6zrbbqaju4(MRXYcefGt3OhPZyaMm(DA1XOckhUTBqVOShu0T8Qaef9SOcoG6ClVIg4hzS8YOaJ0UE0jMLB5vDDkgbEYsY5wsg7yHIjsbbj5LbjkmyPi2TRd2GqobcSicw2aKOsENFqirRLxfGOONfvWbuNB5v0a)iJLxgfyK2LcW5B1y3aGDIIXbnanapzjr2HPhPXa16TAVQSILjh)oT6yubV94UUrlfdqu0ZIku4(MRXYcouSr)y7gaSRCXcvY43PvhJkOC42Ub9IYEqr3YRcqu0ZIkOqHrhLkJnJbyDik6zrzgODgqDULxrd8JmwEzuGrAxkaNVvJDda2jkgh0a0a8KLKZTKm2XcftKccsYltof6gGUxQUc5EJGL8Tzflui0tvhjJLfCLIgGOONfLzsab2coGoGYuMoVuwXAC(nDymAdOo3YROHySqyYjPq3a05xQbpzjfrWYgOekfwD1DIbi6Ct2(KDy6rAm0ENoR4oKOsEV9yGqHcBrle7W4RHgdo3sY4aQZT8kAigleMCGrAxf6gGo)sn4jlj(rglVSqLXaSoRJY43PvhJkOq3aq7kcmarrplkZcugKOsEV9yGWGcztEAmduthqDULxrdXyHWKdms76vJUQuGNSKKZCnwwqHSPgdy5rAujui)iJLxwOYyawN1rHcHefYEWym0caD4jEfsfuMC7t2HPhPXq7D6SI7qIcPcfYMXaSoef9SOmVJGdOo3YROHySqyYbgPDvOBa68l1GNSK4hzS8YcvgdW6SokdsujV3EmqyqHSjpnMLVPY2NSdtpsJH270zf3HevY7ThdeoG6ClVIgIXcHjhyK2LfPgcZkUtnyUfbpzjXpYy5LfQmgG1zDug)oT6yubf6gaAxrGbik6zrzgOMktHreSSbwKAimR4oJJOubQ58Tmd2Y2NSdtpsJH270zf3HefsLj3(k0naDVuDfY9gbl5BZkwOWicw2GcDdaTRiWa1C(wsGTGdOo3YROHySqyYbgPDvOBa68l1GNSKGevY7ThdeguiBYtJzGeOqHSzmaRdrrplkZ7iBFfgrWYgyrQHWSI7moIsfiAhqDULxrdXyHWKdms7Y4ikvN2ILcHGNSKuyeblBGfPgcZkUZ4ikvGAoFlieOS9j7W0J0yO9oDwXDirH0buNB5v0qmwim5aJ0UmoIs1PTyPqi4jljfgrWYgyrQHWSI7moIsfiALXVtRogvWBpURB0sXaef9SODe4BrUHkqSJS9j7W0J0yO9oDwXDirH0buNB5v0qmwim5aJ0Uk0naD(LAWtwsqIk592JbcdkKn5PXS8nv2(KDy6rAm0ENoR4oKOsEV9yGWbuNB5v0qmwim5aJ0USi1qywXDQbZTi4jljfgrWYgyrQHWSI7moIsfOMZ3YmqY2NSdtpsJH270zf3HefshqDULxrdXyHWKdms7YIudHzf3Pgm3IGNSKuyeblBGfPgcZkUZ4ikvGAoFlZGTm(DA1XOcE7XDDJwkgGOONfTJaFlYnuX8oY2NSdtpsJH270zf3HefshqDULxrdXyHWKdms7Qq3a05xQbpzjTpzhMEKgdT3PZkUdjQK3BpgiCaDaLPmDEbuSqyYNh4EG8ZlGH5btRXaQZT8kAigleM8UFijgEAGtroj(DA1XOc0Jq3HO3IWaef9SOGNSKmxJLfOhHUdrVfHYmhgJwWsrSBxVLBDbUdZ7iJnJbyDik6zrbXoY43PvhJkqpcDhIElcdqu0ZIYSCXC1EOPbqUDeuMZTKm2XcftKYmjboG6ClVIgIXcHjV7hcms7Qq3a05xQbpzjj3(KDy6rAm0ENoR4oKOsEV9yGqHcJiyzducLcRU6oXaeDUjOm5IiyzdkhUTBqVOShu0T8QarRmirHShmgdk0v6ePwNFPwMZTKm2XcftKYmjbkuOZTKm2XcftKssEbhqDULxrdXyHWK39dbgPDX2uHIjh8KLueblBGsOuy1v3jgGOZnHc3NSdtpsJH270zf3HevY7ThdeoGY05BsSZBomgT55n46SINpPZRsQhPrf4ZtzKghW8roF782nVbaNNMvSgfGMdJrB(ySqyYNxNuB(SOg6QWaQZT8kAigleM8UFiWiTlKO6o3YR66KAGxUiskgleMCWPgm5gjGapzjXBW1yhlumrkjGgqDULxrdXyHWK39dbgPDzCeLQtBXsHqW5n4ASBomgnkjGapzjjh)oT6yubV94UUrlfdqu0ZIcIDKPWicw2alsneMvCNXruQarRqHkmIGLnWIudHzf3zCeLkqnNVfecuqzYXMXaSoef9SOmZVtRogvqHUbO7LQRqU3iarrplkWaQPcfYMXaSoef9SOGGFNwDmQG3ECx3OLIbik6zrfCa15wEfneJfctE3peyK2LfPgcZkUtnyUfbN3GRXU5Wy0OKac8KLKcJiyzdSi1qywXDghrPcuZ5BzMKaLXVtRogvWBpURB0sXaef9SOmlqHcvyeblBGfPgcZkUZ4ikvGAoFlZanG6ClVIgIXcHjV7hcms7YIudHzf3Pgm3IGZBW1y3CymAusabEYsIFNwDmQG3ECx3OLIbik6zrbXoYuyeblBGfPgcZkUZ4ikvGAoFlZanGY053eqsNpPZJSSi3sYOUX8SPwJW5zai5aMNMI053RawA(cjmORbF(icBEkGJqRMVfIKXYM3NNYXYH5npdaieN3aGZ7k1vZdWPZxNbiR45TBEiYprrSuHbuNB5v0qmwim5D)qGrAxwKAimR4o1G5we8KLKZTKm2vNfyrQHWSI7moIsbcs8gCn2XcftKktHreSSbwKAimR4oJJOubQ58Tmd2dOdOmDEGdNNUMoG6ClVIgGopDnLKd5EHD7GqSmWtwsqIk592JbcdkKn5PbI9ChzY1Iwi2HXxdngCULKrHc33CnwwGsikEvp2HXxdngWYJ0OsqzqIcdkKn5Pbcs7mG6ClVIgGopDnfyK2nsFNQZsaBaEYsISdtpsJbrxaCWo)oT6yu0UZTKmkuO5Wy0cwkID76QezMueblBisFNQZsaBeueq3YRgqDULxrdqNNUMcms7gHqkc3Mvm4jljYom9ingeDbWb7870QJrr7o3sYOqHMdJrlyPi2TRRsKzsreSSHiesr42SIdkcOB5vdOo3YRObOZtxtbgPD1zmaJ2faeQyrSmWtwsreSSbIcWPB0PgeRydqGODaLPZdClosnORNNjDTEEUxZBWmogHZd2Z3Egww665JiyzPGpp6CaZRDQLv88aTZ8uKFLIgMVjYsD2edvZdWHQ55NcvZBPioVtN3N3GzCmcN3U53Iy78PnpeDLhPXWaQZT8kAa6801uGrAxV4i1GUUZDTg8KLezhMEKgdIUa4GD(DA1XOODNBjzuOqZHXOfSue721vjYmjG2za15wEfnaDE6AkWiTRd5EH9wcnfbpzj5CljJDSqXePGGK8cfkhKOWGcztEAGG0oYGevY7ThdeguiBYtdeK2ZMk4aQZT8kAa6801uGrAx2eIr67uGNSKi7W0J0yq0fahSZVtRogfT7CljJcfAomgTGLIy3UUkrMjfrWYgytigPVtfueq3YRgqDULxrdqNNUMcms7g5X9JTBWKVLcEYskIGLnquaoDJo1GyfBaceTYCULKXowOyIusanGoGYuMo)MWS2IgDa15wEfnyWS2IgLebf7PHIGxUisklkhsyEKg7mbHxgHyxHKtocEYsso(DA1XOcefGt3OhPZyawaIIEwuHc53PvhJkOC42Ub9IYEqr3YRcqu0ZIkOm5Arl4qXg9yahHo4CljJcf2IwWBpEpgWrOdo3sYOS9nxJLfCOyJ(X2nayx5IfQek0CymAblfXUD9wU1LVPmVJGcfgDuQm2mgG1HOONfLz5bAa15wEfnyWS2IgfyK2LGI90qrWlxejj6CpcIDkaeTUibn5GNSK43PvhJk4Th31nAPyaIIEwuM3rMC7Jmbr22IQqwuoKW8in2zccVmcXUcjNCuOq(DA1XOczr5qcZJ0yNji8Yie7kKCYXaef9SOckuy0rPYyZyawhIIEwuMLhObuNB5v0GbZAlAuGrAxck2tdfbVCrKKcIUInHyNmsPOg8KLe)oT6yubV94UUrlfdqu0ZIktU9rMGiBBrvilkhsyEKg7mbHxgHyxHKtokui)oT6yuHSOCiH5rASZeeEzeIDfso5yaIIEwubfkm6OuzSzmaRdrrplkZcCa15wEfnyWS2IgfyK2LGI90qrWlxejPC4wX7QUc5B7KpOZtRb4jlj(DA1XOcE7XDDJwkgGOONfvMC7Jmbr22IQqwuoKW8in2zccVmcXUcjNCuOq(DA1XOczr5qcZJ0yNji8Yie7kKCYXaef9SOckuy0rPYyZyawhIIEwuMLhObuNB5v0GbZAlAuGrAxck2tdfPGNSKKJFNwDmQG3ECx3OLIbik6zrfkmIGLnOC42Ub9IYEqr3YRceTcktU9rMGiBBrvilkhsyEKg7mbHxgHyxHKtokui)oT6yuHSOCiH5rASZeeEzeIDfso5yaIIEwubhqzktNFZMWEBcG0aktz68BcaN3GzTfT5zKgG5na48aYyai1MhPwk6gQMNSRjqWNNrQ1ZhHZtqr18SjKAZ7LA(wpHOAEgPbyEGB7XDDJwkoVCj78reSSZN05bAN5Pi)kfD(doVgPubN)GZdgDgdW2DVBoVCj78Xq0neoVbWR5bAN5Pi)kfvWbuMY05DULxrdgmRTOrbgPDjOypnueCQ(msgmRTObe4jlP9j7W0J0yG2I8Knrv3GzTfnzYjNbZAlAbGcTWJh8Qrx1sdkcOB5vmtcODKXVtRogvWBpURB0sXaef9SOGq(MkuObZAlAbGcTWJh8Qrx1sdkcOB5vGaODKjh)oT6yubIcWPB0J0zmalarrplkiKVPcfYVtRogvq5WTDd6fL9GIULxfGOONffeY3ubfuMC7BWS2Iwq(aaN253PvhJsOqdM1w0cYh43PvhJkarrplQqHKDy6rAmyWS2IwVfMhmTgKasqbfk0GzTfTaqHw4XdE1ORAPbfb0T8kqqInJbyDik6zrhqzktN35wEfnyWS2IgfyK2LGI90qrWP6ZizWS2IM8GNSK2NSdtpsJbAlYt2evDdM1w0KjNCgmRTOfKp0cpEWRgDvlnOiGULxXmjG2rg)oT6yubV94UUrlfdqu0ZIcc5BQqHgmRTOfKp0cpEWRgDvlnOiGULxbcG2rMC870QJrfikaNUrpsNXaSaef9SOGq(Mkui)oT6yubLd32nOxu2dk6wEvaIIEwuqiFtfuqzYTVbZAlAbGcaCANFNwDmkHcnywBrlauGFNwDmQaef9SOcfs2HPhPXGbZAlA9wyEW0AqsEbfuOqdM1w0cYhAHhp4vJUQLgueq3YRabj2mgG1HOONfDaLPmD(Me78xPBm)v48xnpbfN3GzTfT5BHh5uH0595JiyzbFEckoVbaN)maiC(RMNFNwDmQW8nb48j78fMgaeoVbZAlAZ3cpYPcPZ7ZhrWYc(8euC(OZam)vZZVtRogvyaLPmDENB5v0GbZAlAuGrAxck2tdfbNQpJKbZAlAabEYsAFdM1w0cafa40obf7reSSYKZGzTfTG8b(DA1XOcqu0ZIku4(gmRTOfKpaWPDck2JiyzfCaLPmDENB5v0GbZAlAuGrAxck2tdfbNQpJKbZAlAYdEYsAFdM1w0cYha40obf7reSSYKZGzTfTaqb(DA1XOcqu0ZIku4(gmRTOfakaWPDck2JiyzfCzlBTaa]] )


end
