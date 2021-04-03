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


    spec:RegisterPack( "Unholy", 20210403, [[de1MlcqiaYJqP0LaIk2ej5tsLAuKuofbAvkvcVcanlGQBHsrTlb)cagMujoMsvltPONrannukCnLk2gqu(MsLuJtQKW5aIkToaQENujrmpuQUhISpGWbbOyHafpKayIkvQlcevTrPsk8rcqmsPsk1jvQeTsG0lLkPOzcqPBkvsK2jjv)KaudvQK0svQK8ucnvLcxLaK2QujL8vPsQglqj7vj)vkdwvhMQflKhJQjt0LH2mk(SqnAaDArRgLI8ALsZMu3Me7wYVvz4svhhOulh0ZrA6uUocBhL8De14bICEPI1lvsuZNG2VIx7xBSeLUHl13SlBUVlSrxeyy)(9SXo76LO1PhxI9oFRhJlXYvWLOaAb80DwI9Eh95Y1glr6ra54seOz9uahaaionGerb(PaaAQqODlVIdDgda0uHdGLyerQTDzTIwIs3WL6B2Ln33f2OlcmSF)E2yhq2sK2J8L6BUZMlrGPuI1kAjkrkFjUB0nGZ31SYyG28cOfWt3zafW0dt98Bc(8B2Ln3pGoGkaa9kgPa(akBEEaJKnrqnfSm682n)URDdGDJmPgbWUr3asNF3e482n)v6oZZpIYM3CymA05jd8M3H48ii1JCdLZB386KfoV(Q45X6iIboVDZR4MHW5vZpSrrJOFE2UxWWakBE(DNupsJY5fDomzsE6657Qo3Mpc5obfNxIUC(yGhHMoVIVfNN5GZtD587URjnmGYMNxaLMv88D9JOKZl2JLeHZ7rPoTePZRCqCEgncszKUZ8Q528SbaNNAoFlD(SOg6Y5pM53bGc2vY87URkoFHeg01Z7LCEfVZ89qKfw280tbNVo2me5ZttJWT8kAyaLnpVaknR457AGudHzfpVObZT48znpGradYpFYmFNJyEGolC(6mGzfppQP482nV8M3l58KVQBB(Jfc5E)8KpIssNpPZV7UQ48fsyqxhgqzZZlaa9kgLZR4vN57MjJbAniQ4zr7EE(vY0YRCnDE7M3771DMpR5JokDEMmgOrN)kDN5vtJu68cWUNNStnC(RM3GofOGHbu288agPeLZ71zar48cyclcI(25XYGDM3U5POnpr)8udEvmcNhKVpLOsYPHbu288BiG3TagWNFE1rYZBWS2I28CyAim9WsuNuJU2yj6h2OOr0V2yP((1glrS8inkxGzjYHPHW0xIs0nGTTvgd0cmKpIsIYM5Wy0OZdcsZZ7W1ydlujr68cfop0tzdzHLfCPKgqqkPgDEvZd9u2qwyzbxkPbiQ4zrNNDsZVF)s05wE1s0Ronzjx2s9nxBSeXYJ0OCbMLihMgctFjkr3a22wzmqlWq(ikjkBMdJrJopiin)olrNB5vlrV60KLCzl1f4AJLiwEKgLlWSe5W0qy6lranplhMEKgd93PZkUbjQK36pYiCEvZR28remmbPd32mOxuMdQ4wEvGOFEvZdjkK5GXyqIUuNi1A8l1bS8inkNx18o3swydlujr68StAEboVqHZ7ClzHnSqLePZtA(nNxWLOZT8QLOeDdyJFPEzl1zJ1glrS8inkxGzjYHPHW0xIaAEwom9ing6VtNvCdsujV1FKr4s05wE1se7tjQK8LTuFN1glrS8inkxGzj6ClVAjYGudHzf3Ogm3IlromneM(suIremmbgKAimR4g5JOKbQ58TZZoP5f48QMNFNwEKRG3FCx3PNIbiQ4zrNN95f4sK3HRXM5Wy0Ol13VSL6GS1glrS8inkxGzj6ClVAjYGudHzf3Ogm3IlromneM(suIremmbgKAimR4g5JOKbQ58TZZ(87xI8oCn2mhgJgDP((LTuFxV2yjILhPr5cmlrNB5vlrgKAimR4g1G5wCjYHPHW0xIsmIGHjWGudHzf3iFeLmqnNVDE2jnVaNx18qIcdwQGn7ASX8Spp)oT8ixbV60KLmarfpl6sK3HRXM5Wy0Ol13VSL6DfRnwIy5rAuUaZs05wE1sK8ruYgThljcxIsKYHzVLxTe76aXAEZHXOnpLS3tN3H48YK6rAuc(8gWKop5uRNxJ28DoI5P9yjNhsuifaKpIssNplQHUC(JzEYEAzfppZbNF31UbWUrMuJay3OBa7Mo)UjWWsKdtdHPVevBEanpfnlRyAG3HRX5fkCEj6gW22kJbAbgYhrjrzZCymA05bbP55D4ASHfQKiDEbNx18smIGHjWGudHzf3iFeLmqnNVDEqmVaNx18qIcdwQGn7AcCE2NNFNwEKRGxDAYsgGOINfDzlBj6h2IiGuBTXs99RnwIy5rAuUaZsKdtdHPVevB(icgMaLqkXQjVtjarNBZlu48aAEwom9ing6VtNvCdsujV1FKr48coVQ5vB(icgMG0HBBg0lkZbvClVkq0pVQ5HefYCWymirxQtKAn(L6awEKgLZRAENBjlSHfQKiDE2jnVaNxOW5DULSWgwOsI05jn)MZl4s05wE1suIUbSXVuVSL6BU2yjILhPr5cmlromneM(sesujV1FKryqImjpT5zFE1MFFxMhGZlr3a22wzmqlWq(ikjkBMdJrJo)UyEboVGZRAEj6gW22kJbAbgYhrjrzZCymA05zFEq28QMhqZZYHPhPXq)D6SIBqIk5T(JmcNxOW5JiyycuYoujR4MssTar)s05wE1se7tjQK8LTuxGRnwIy5rAuUaZsKdtdHPVeHevYB9hzegKitYtBE2NFZDMx18s0nGTTvgd0cmKpIsIYM5Wy0OZdI53zEvZdO5z5W0J0yO)oDwXnirL8w)rgHlrNB5vlrSpLOsYx2sD2yTXselpsJYfywICyAim9LiGMxIUbSTTYyGwGH8rusu2mhgJgDEvZdO5z5W0J0yO)oDwXnirL8w)rgHZlu48mzmqRbrfpl68Sp)oZlu48qpLnKfwwWLsAabPKA05vnp0tzdzHLfCPKgGOINfDE2NFNLOZT8QLi2Nsuj5lBP(oRnwIo3YRwIKpIs2O9yjr4selpsJYfyw2sDq2AJLiwEKgLlWSe5W0qy6lranplhMEKgd93PZkUbjQK36pYiCj6ClVAjI9Pevs(Yw2se680101gl13V2yjILhPr5cmlrNB5vlrhY9cB2bHyzlrjs5WS3YRwI7kNNUMUe5W0qy6lrirL8w)rgHbjYK80MheZdY2zEvZR289OfIDy81rJbNBjlCEHcNhqZBUgllqjuuUQf7W4RJgdy5rAuoVGZRAEirHbjYK80MheKMFNLTuFZ1glrS8inkxGzjYHPHW0xISCy6rAmO4SPd243PLh5I2CULSW5fkCEZHXOfSubB21Kjop7KMpIGHjePVt2yiGDcscOB5vlrNB5vlXi9DYgdbSZYwQlW1glrS8inkxGzjYHPHW0xISCy6rAmO4SPd243PLh5I2CULSW5fkCEZHXOfSubB21Kjop7KMpIGHjeHqkc3MvCqsaDlVAj6ClVAjgHqkc3Mv8YwQZgRnwIy5rAuUaZsKdtdHPVeJiyycefWt3PrniwXgWar)s05wE1suNXanAJnriJvWYw2s9DwBSeXYJ0OCbMLOZT8QLOxCKAqx34UwVeLiLdZElVAjcykosnORNxaCTEEUxZBWmogHZZgZ3Fgww665JiyyOGpp6CGZRDQLv8873zEkYVssdZlGAPo7kJY5b6q588tIY5TubN3PZ7ZBWmogHZB38BrSF(0MhIU0J0yyjYHPHW0xISCy6rAmO4SPd243PLh5I2CULSW5fkCEZHXOfSubB21Kjop7KMF)olBPoiBTXselpsJYfywICyAim9LOZTKf2WcvsKopiin)MZlu48QnpKOWGezsEAZdcsZVZ8QMhsujV1FKryqImjpT5bbP5bzDzEbxIo3YRwIoK7f26j0uCzl131RnwIy5rAuUaZsKdtdHPVez5W0J0yqXzthSXVtlpYfT5ClzHZlu48MdJrlyPc2SRjtCE2jnFebdtGjHyK(ozqsaDlVAj6ClVAjYKqmsFNCzl17kwBSeXYJ0OCbMLihMgctFjgrWWeikGNUtJAqSInGbI(5vnVZTKf2WcvsKopP53VeDULxTeJ842X0myY3sx2YwIXyHWKV2yP((1glrS8inkxGzjYHPHW0xIremmbkHuIvtENsaIo3Mx18aAEwom9ing6VtNvCdsujV1FKr48cfoFpAHyhgFD0yW5wYcxIo3YRwIs0nGn(L6LTuFZ1glrS8inkxGzjYHPHW0xI8JfwEzHkJbAnghNx18870YJCfKOBaPnjbgGOINfDE2NxGZRAEirL8w)rgHbjYK80MN9533LLOZT8QLOeDdyJFPEzl1f4AJLiwEKgLlWSe5W0qy6lr1M3CnwwqImPgdy5rAuoVqHZZpwy5LfQmgO1yCCEHcNhsuiZbJXqpq0HNYvinGLhPr58coVQ5vBEanplhMEKgd93PZkUbjkKoVqHZZKXaTgev8SOZZ(87mVGlrNB5vlrV60KLCzl1zJ1glrS8inkxGzjYHPHW0xI8JfwEzHkJbAnghNx18qIk5T(JmcdsKj5Pnp7ZVzxMx18aAEwom9ing6VtNvCdsujV1FKr4s05wE1suIUbSXVuVSL67S2yjILhPr5cmlromneM(sKFSWYlluzmqRX448QMNFNwEKRGeDdiTjjWaev8SOZZ(877Y8QMxIremmbgKAimR4g5JOKbQ58TZZ(8SX8QMhqZZYHPhPXq)D6SIBqIcPZRAE1MhqZlr3a28s2Ki37eSKVnR45fkC(icgMGeDdiTjjWa1C(25jnpBmVGlrNB5vlrgKAimR4g1G5wCzl1bzRnwIy5rAuUaZsKdtdHPVeHevYB9hzegKitYtBE2NFVaNxOW5zYyGwdIkEw05zF(DMx18aAEjgrWWeyqQHWSIBKpIsgi6xIo3YRwIs0nGn(L6LTuFxV2yjILhPr5cmlromneM(suIremmbgKAimR4g5JOKbQ58TZdI5f48QMhqZZYHPhPXq)D6SIBqIcPlrNB5vlrYhrjB0ESKiCzl17kwBSeXYJ0OCbMLihMgctFjkXicgMadsneMvCJ8ruYar)8QMNFNwEKRG3FCx3PNIbiQ4zrBii1JCdLZdI53zEvZdO5z5W0J0yO)oDwXnirH0LOZT8QLi5JOKnApwseUSL6GCxBSeXYJ0OCbMLihMgctFjcjQK36pYimirMKN28Sp)MDzEvZdO5z5W0J0yO)oDwXnirL8w)rgHlrNB5vlrj6gWg)s9YwQVVlRnwIy5rAuUaZsKdtdHPVeLyebdtGbPgcZkUr(ikzGAoF78Sp)(5vnpGMNLdtpsJH(70zf3GefsxIo3YRwImi1qywXnQbZT4YwQVF)AJLiwEKgLlWSe5W0qy6lrjgrWWeyqQHWSIBKpIsgOMZ3op7ZZgZRAE(DA5rUcE)XDDNEkgGOINfTHGupYnuop7ZVZ8QMhqZZYHPhPXq)D6SIBqIcPlrNB5vlrgKAimR4g1G5wCzl13V5AJLiwEKgLlWSe5W0qy6lranplhMEKgd93PZkUbjQK36pYiCj6ClVAjkr3a24xQx2YwI8JfwEz01gl13V2yjILhPr5cmlromneM(sKLdtpsJbQ161EvzfpVQ5HevYB9hzegKitYtBEqm)Eq28QMxT553PLh5k49h31D6PyaIkEw05fkCEanV5ASSGdv60oMMbeBsxPqzalpsJY5vnp)oT8ixbPd32mOxuMdQ4wEvaIkEw05fCEHcNp6O05vnptgd0AquXZIop7ZVF)s05wE1sKs2Hkzf3usQTSL6BU2yjILhPr5cmlrNB5vlrkzhQKvCtjP2suIuom7T8QLOiAZB38euCENXq48E)XNpPZF18cWUN3PZB389qKfw28hleY9((SINFx1vNNmWuJZtrZYkEEI(5fGD3nDjYHPHW0xI870YJCf8(J76o9umarfpl68QMxT5DULSWgwOsI05bbP53CEvZ7ClzHnSqLePZZoP53zEvZdjQK36pYimirMKN28Gy(9DzEaoVAZ7ClzHnSqLePZVlMhKnVGZlu48o3swydlujr68Gy(DMx18qIk5T(JmcdsKj5PnpiMNn6Y8cUSL6cCTXselpsJYfywICyAim9LilhMEKgduR1R9QYkEEvZdO5PhHoklzqJUSf1PHGKR0RXawEKgLZRAE1MNFNwEKRG3FCx3PNIbiQ4zrNxOW5b08MRXYcouPt7yAgqSjDLcLbS8inkNx18870YJCfKoCBZGErzoOIB5vbiQ4zrNxW5vnpKOWGLkyZUgBmpiMxT5f48aC(icgMaKOsEJFqirVLxfGOINfDEbNxOW5JokDEvZZKXaTgev8SOZZ(8BUFj6ClVAj6rNswULx10Ps0YwQZgRnwIy5rAuUaZsKdtdHPVez5W0J0yGATETxvwXZRAE6rOJYsg0OlBrDAii5k9AmGLhPr58QMxT5LNfikGNUtlsNXaTM8Saev8SOZdI53VFEHcNhqZBUgllquapDNwKoJbAbS8inkNx18870YJCfKoCBZGErzoOIB5vbiQ4zrNxWLOZT8QLOhDkz5wEvtNkrlBP(oRnwIy5rAuUaZsKdtdHPVeDULSWgwOsI05bbP53CEvZdjkmyPc2SRXgZdI5vBEbopaNpIGHjajQK34hes0B5vbiQ4zrNxWLOZT8QLOhDkz5wEvtNkrlBPoiBTXselpsJYfywICyAim9LilhMEKgduR1R9QYkEEvZR28870YJCf8(J76o9umarfpl68cfopGM3CnwwWHkDAhtZaInPRuOmGLhPr58QMNFNwEKRG0HBBg0lkZbvClVkarfpl68coVqHZhDu68QMNjJbAniQ4zrNN953VZs05wE1sKc05B1yZaInII8bnGDw2s9D9AJLiwEKgLlWSe5W0qy6lrNBjlSHfQKiDEqqA(nNx18QnVeDdyZlztICVtWs(2SINxOW5HEkBilSSGlL0aev8SOZZoP53ZgZl4s05wE1sKc05B1yZaInII8bnGDw2YwI9qKFkrUT2yP((1glrNB5vlX(ZYRwIy5rAuUaZYwQV5AJLOZT8QLi0tk2KOlxIy5rAuUaZYw2sKFNwEKl6AJL67xBSeXYJ0OCbMLihMgctFjYYHPhPXGIZMoyJFNwEKlAZ5wYcNxOW5JokDEvZZKXaTgev8SOZZ(8BcYwIo3YRwI9NLxTSL6BU2yjILhPr5cmlromneM(sKFNwEKRarb80DAr6mgOfGOINfDE2NFN5vnp)oT8ixbPd32mOxuMdQ4wEvaIkEw0gcs9i3q58Sp)oZRAEZ1yzbIc4P70I0zmqlGLhPr58cfopGM3CnwwGOaE6oTiDgd0cy5rAuoVqHZhDu68QMNjJbAniQ4zrNN95f4olrNB5vlrhQ0PDmndi2KOlx2sDbU2yjILhPr5cmlrNB5vlr6rOBq07r4sKdtdHPVenhgJwWsfSzxRNBnbUZ8Sp)oZRAEZHXOfSubB21KjopiMFN5vnVZTKf2WcvsKop7KMxGlrEhUgBMdJrJUuF)YwQZgRnwIy5rAuUaZs05wE1sKOaE6oTiDgd0wIsKYHzVLxTe7AFAjDEWOZyG28mhCEI(5TB(DMNI8RK05TBEANIpp50aopGP)4UUtpfbFEbSbeHKtkc(8euCEYPbC(D7WTZVb0lkZbvClVkSe5W0qy6lrwom9ingOwRx7vLv88QMxT553PLh5k49h31D6PyaIkEw0gcs9i3q58Sp)oZlu48870YJCf8(J76o9umarfplAdbPEKBOCEqm)(UmVGZRAE1MNFNwEKRG0HBBg0lkZbvClVkarfpl68SpFmxoVqHZhrWWeKoCBZGErzoOIB5vbI(5fCzl13zTXselpsJYfywICyAim9LOZTKf2WcvsKopiin)MZlu48rhLoVQ5zYyGwdIkEw05zF(n3VeDULxTejkGNUtlsNXaTLTuhKT2yjILhPr5cmlromneM(sKLdtpsJbQ161EvzfpVQ5vBE5zbIc4P70I0zmqRjplarfpl68cfopGM3CnwwGOaE6oTiDgd0cy5rAuoVGlrNB5vlrPd32mOxuMdQ4wE1YwQVRxBSeXYJ0OCbMLihMgctFj6ClzHnSqLePZdcsZV58cfoF0rPZRAEMmgO1GOINfDE2NFZ9lrNB5vlrPd32mOxuMdQ4wE1YwQ3vS2yjILhPr5cmlromneM(s05wYcByHkjsNN087Nx18smIGHjWGudHzf3iFeLmqnNVDEqmVaxIo3YRwIE)XDDNEkUSL6GCxBSeXYJ0OCbMLOZT8QLO3FCx3PNIlromneM(s05wYcByHkjsNheKMFZ5vnVeJiyycmi1qywXnYhrjduZ5BNheZlW5vnpGMxIUbS5LSjrU3jyjFBwXlrEhUgBMdJrJUuF)YwQVVlRnwIy5rAuUaZsKdtdHPVeHevYB9hzegKitYtBE2NFpBmVQ5vBE(DA5rUcefWt3PfPZyGwaIkEw05zF(9DzEHcNxEwGOaE6oTiDgd0AYZcquXZIoVGlrNB5vlrkHIYvTyhgFD04YwQVF)AJLiwEKgLlWSe5W0qy6lrwom9ingOwRx7vLv88QMxIremmbgKAimR4g5JOKbQ58TZZ(8BoVQ5vB(E0cE)XBXapcDW5wYcNxOW5JiyycshUTzqVOmhuXT8Qar)8QMhqZ3JwWHkDAXapcDW5wYcNxWLOZT8QLirb80DAoL6eABzl13V5AJLiwEKgLlWSeDULxTejkGNUtZPuNqBlromneM(s05wYcByHkjsNheKMFZ5vnVeJiyycmi1qywXnYhrjduZ5BNN953CjY7W1yZCymA0L67x2s99cCTXselpsJYfywICyAim9LiGMVhTqmWJqhCULSWLOZT8QLi0tk2KOlx2YwIXyHWK38dxBSuF)AJLiwEKgLlWSePiFjYVtlpYvGEe6ge9EegGOINfDj6ClVAjs2tBjYHPHW0xIMRXYc0Jq3GO3JWawEKgLZRAEZHXOfSubB2165wtG7mp7ZVZ8QMNjJbAniQ4zrNheZVZ8QMNFNwEKRa9i0ni69imarfpl68SpVAZhZLZVlMVlHD9oZl48QM35wYcByHkjsNNDsZlWLTuFZ1glrS8inkxGzjYHPHW0xIQnpGMNLdtpsJH(70zf3GevYB9hzeoVqHZhrWWeOesjwn5Dkbi6CBEbNx18QnFebdtq6WTnd6fL5GkULxfi6Nx18qIczoymgKOl1jsTg)sDalpsJY5vnVZTKf2WcvsKop7KMxGZlu48o3swydlujr68KMFZ5fCj6ClVAjkr3a24xQx2sDbU2yjILhPr5cmlromneM(smIGHjqjKsSAY7ucq0528cfopGMNLdtpsJH(70zf3GevYB9hzeUeDULxTeX(uIkjFzl1zJ1glrS8inkxGzjkrkhM9wE1sCxYmV5Wy0MN3HRZkE(KoVmPEKgLGppLCACGZh58TZB38gqCEAwXAKnBomgT5JXcHjFEDsT5ZIAOldlrNB5vlrir1CULx10j1wIudMCBP((LihMgctFjY7W1ydlujr68KMF)suNuRvUcUeJXcHjFzl13zTXselpsJYfywIo3YRwIKpIs2O9yjr4sKdtdHPVevBE(DA5rUcE)XDDNEkgGOINfDEqm)oZRAEjgrWWeyqQHWSIBKpIsgi6NxOW5LyebdtGbPgcZkUr(ikzGAoF78GyEboVGZRAE1MNjJbAniQ4zrNN9553PLh5kir3a28s2Ki37eGOINfDEao)(UmVqHZZKXaTgev8SOZdI553PLh5k49h31D6PyaIkEw05fCjY7W1yZCymA0L67x2sDq2AJLiwEKgLlWSeDULxTezqQHWSIBudMBXLihMgctFjkXicgMadsneMvCJ8ruYa1C(25zN08cCEvZZVtlpYvW7pUR70tXaev8SOZZ(8cCEHcNxIremmbgKAimR4g5JOKbQ58TZZ(87xI8oCn2mhgJgDP((LTuFxV2yjILhPr5cmlrNB5vlrgKAimR4g1G5wCjYHPHW0xI870YJCf8(J76o9umarfpl68Gy(DMx18smIGHjWGudHzf3iFeLmqnNVDE2NF)sK3HRXM5Wy0Ol13VSL6DfRnwIy5rAuUaZs05wE1sKbPgcZkUrnyUfxIsKYHzVLxTe3aysNpPZJmmi3swOUZ8mPwJW5jdm5aNNMk053DxvC(cjmORbF(icBEkWJqlNVhISWYM3NNYXYH5npzGieN3aIZ7s5vZd0PZxNbmR45TBEiYpffSKHLihMgctFj6ClzHn5zbgKAimR4g5JOKZdcsZZ7W1ydlujr68QMxIremmbgKAimR4g5JOKbQ58TZZ(8SXYw2suImoH2wBSuF)AJLOZT8QLOswYgdeXUY4selpsJYfyw2s9nxBSeXYJ0OCbML41VePOTeDULxTez5W0J04sKLRjWLOAZJGnr23JYqwuoKW8in2aBcVmcLMezLCCEvZZVtlpYvilkhsyEKgBGnHxgHstISsogGOl7mVGlrjs5WS3YRwIDviYclBEApYtMeLZBWS2IgD(imR45jOOCEYPbCENWof3s(86Sq6sKLdBLRGlrApYtMeLndM1w0w2sDbU2yjILhPr5cmlXRFjsrBj6ClVAjYYHPhPXLilxtGlr(DA5rUcucfLRAXom(6OXaev8SOZZ(87mVQ5nxJLfOekkx1IDy81rJbS8inkxISCyRCfCj2FNoR4gKOsER)iJWLTuNnwBSeXYJ0OCbML41VePOTeDULxTez5W0J04sKLRjWLO5ASSa9i0ni69imGLhPr58QMhsu48Sp)MZRAEZHXOfSubB2165wtG7mp7ZVZ8QMNjJbAniQ4zrNheZVZsKLdBLRGlX(70zf3Gefsx2s9DwBSeXYJ0OCbML41VePOTeDULxTez5W0J04sKLRjWLOZTKf2WcvsKopP53pVQ5vBEanp0tzdzHLfCPKgqqkPgDEHcNh6PSHSWYcUusdznpiMF)oZl4sKLdBLRGlrQ161EvzfVSL6GS1glrS8inkxGzjE9lrkAlrNB5vlrwom9inUez5AcCj2Jwi2HXxhngCULSW5fkC(icgMarb80DAoL6eAlq0pVqHZBUgll4qLoTJPzaXM0vkugWYJ0OCEvZ3JwW7pElg4rOdo3sw48cfoFebdtq6WTnd6fL5GkULxfi6xISCyRCfCjQ4SPd243PLh5I2CULSWLTuFxV2yjILhPr5cmlrNB5vlXJWIGOVDjkrkhM9wE1sSRuplZZkR457ALqcnw28DvThtGZN05957H5btRZsKdtdHPVeLNfyLqcnwwRx7XeyaImqKc0J048QMhqZBUgllquapDNwKoJbAbS8inkNx18aAEONYgYcll4sjnGGusn6YwQ3vS2yjILhPr5cmlrNB5vlXJWIGOVDjYHPHW0xIYZcSsiHglR1R9ycmargisb6rACEvZ7ClzHnSqLePZdcsZV58QMxT5b08MRXYcefWt3PfPZyGwalpsJY5fkCEZ1yzbIc4P70I0zmqlGLhPr58QMNFNwEKRarb80DAr6mgOfGOINfDEbxI8oCn2mhgJgDP((LTuhK7AJLiwEKgLlWSe5W0qy6lrirHmhmgduIEesnONvalpsJY5vnVAZlplWapQ1yqwimargisb6rACEHcNxEwisFNS1R9ycmargisb6rACEbxIo3YRwIhHfbrF7YwQVVlRnwIy5rAuUaZs05wE1sK8ruYgThljcxIsKYHzVLxTe3videPar687gDdiD(DtGDtNpIGHzE2eb1MpczoioVeDdiDEjbopws6sKdtdHPVe5hlS8Ycvgd0AmooVQ5LOBaBEjBsK7Dco3swydIkEw05zFE1MpMlNFxm)(WoZl48QMxIUbS5LSjrU3jyjFBwXlBP((9RnwIy5rAuUaZsKI8Li)oT8ixb6rOBq07ryaIkEw0LOZT8QLizpTLihMgctFjAUgllqpcDdIEpcdy5rAuoVQ5nhgJwWsfSzxRNBnbUZ8Sp)oZRAEMmgO1GOINfDEqm)oZRAE(DA5rUc0Jq3GO3JWaev8SOZZ(8QnFmxo)Uy(Ue217mVGZRAENBjlSHfQKiDEsZVFzl13V5AJLiwEKgLlWSeLiLdZElVAj2190MN5GZVB0nGDtNF3eia2nYKAC(KzE1ZyG28DnCCE7MpgT5PgeRyd48remmZh58TZ7uVFjsr(sKFNwEKRGeDdiTjjWaev8SOlrNB5vlrYEAlromneM(sKFSWYlluzmqRX448QMNFNwEKRGeDdiTjjWaev8SOZZ(8XC58QM35wYcByHkjsNN087x2s99cCTXselpsJYfywIuKVe53PLh5kirMuJbiQ4zrxIo3YRwIK90wICyAim9Li)yHLxwOYyGwJXX5vnp)oT8ixbjYKAmarfpl68SpFmxoVQ5DULSWgwOsI05jn)(LTuFpBS2yjILhPr5cmlrjs5WS3YRwIagULxnpGnPgDEVKZlG7XcH05vta3JfcPaqebBcS4iDEIIs03FqdLZN18UuEvqWLOZT8QLi316MZT8QMoP2suNuRvUcUenywBrJUSL673zTXselpsJYfywIo3YRwICxRBo3YRA6KAlrDsTw5k4sKFSWYlJUSL67bzRnwIy5rAuUaZs05wE1sK7ADZ5wEvtNuBjQtQ1kxbxIqNNUMUSL6731RnwIy5rAuUaZsuIuom7T8QLOZT8kAqImoH2aijaqrWMalocEYqY5wYcByHkjsjTxfGKOBaBBRmgOfKj1J0yZptcE5kiPRhlec4ouPt7yAgqSjrxc4mi1qywXnQbZTiGZGudHzf3Ogm3Iaorb80DAr6mgOb49NLxb4shUTzqVOmhuXT8ka37pUR70tXLOZT8QLi316MZT8QMoP2suNuRvUcUe53PLh5IUSL677kwBSeXYJ0OCbMLihMgctFj6ClzHnSqLePZdcsZV58QMxT553PLh5kir3a28s2Ki37eGOINfDE2NFFxMx18aAEZ1yzbjYKAmGLhPr58cfop)oT8ixbjYKAmarfpl68Sp)(UmVQ5nxJLfKitQXawEKgLZl48QMhqZlr3a28s2Ki37eSKVnR4LOZT8QLiKOAo3YRA6KAlrDsTw5k4s0pSrrJOFzl13dYDTXselpsJYfywICyAim9LOZTKf2WcvsKopiin)MZRAEj6gWMxYMe5ENGL8TzfVePgm52s99lrNB5vlrir1CULx10j1wI6KATYvWLOFylIasTLTuFZUS2yjILhPr5cmlromneM(s05wYcByHkjsNheKMFZ5vnVAZdO5LOBaBEjBsK7DcwY3Mv88QMxT553PLh5kir3a28s2Ki37eGOINfDEqm)(UmVQ5b08MRXYcsKj1yalpsJY5fkCE(DA5rUcsKj1yaIkEw05bX877Y8QM3CnwwqImPgdy5rAuoVGZl4s05wE1sesunNB5vnDsTLOoPwRCfCjgJfctEZpCzl13C)AJLiwEKgLlWSe5W0qy6lrNBjlSHfQKiDEsZVFjsnyYTL67xIo3YRwICxRBo3YRA6KAlrDsTw5k4smgleM8LTSLObZAlA01gl13V2yjILhPr5cmlrNB5vlXSOCiH5rASb2eEzeknjYk54sKdtdHPVevBE(DA5rUcefWt3PfPZyGwaIkEw05fkCE(DA5rUcshUTzqVOmhuXT8Qaev8SOZl48QMxT57rl4qLoTyGhHo4ClzHZlu489Of8(J3IbEe6GZTKfoVQ5b08MRXYcouPt7yAgqSjDLcLbS8inkNxOW5nhgJwWsfSzxRNBTn7Y8Sp)oZl48cfoF0rPZRAEMmgO1GOINfDE2NFZ9lXYvWLywuoKW8in2aBcVmcLMezLCCzl13CTXselpsJYfywIo3YRwIko3JGyJcerRPqqt(sKdtdHPVe53PLh5k49h31D6PyaIkEw05zF(DMx18QnpGMhbBISVhLHSOCiH5rASb2eEzeknjYk548cfop)oT8ixHSOCiH5rASb2eEzeknjYk5yaIkEw05fCEHcNp6O05vnptgd0AquXZIop7ZV5(Ly5k4suX5EeeBuGiAnfcAYx2sDbU2yjILhPr5cmlrNB5vlrjeDjtcXglKsr9sKdtdHPVe53PLh5k49h31D6PyaIkEw05vnVAZdO5rWMi77rzilkhsyEKgBGnHxgHstISsooVqHZZVtlpYvilkhsyEKgBGnHxgHstISsogGOINfDEbNxOW5JokDEvZZKXaTgev8SOZZ(8cCjwUcUeLq0LmjeBSqkf1lBPoBS2yjILhPr5cmlrNB5vlrPd3QCx1KiFBJ1bDEADwICyAim9Li)oT8ixbV)4UUtpfdquXZIoVQ5vBEanpc2ezFpkdzr5qcZJ0ydSj8YiuAsKvYX5fkCE(DA5rUczr5qcZJ0ydSj8YiuAsKvYXaev8SOZl48cfoF0rPZRAEMmgO1GOINfDE2NFZ9lXYvWLO0HBvURAsKVTX6GopTolBP(oRnwIy5rAuUaZsKdtdHPVevBE(DA5rUcE)XDDNEkgGOINfDEHcNpIGHjiD42Mb9IYCqf3YRce9Zl48QMxT5b08iytK99OmKfLdjmpsJnWMWlJqPjrwjhNxOW553PLh5kKfLdjmpsJnWMWlJqPjrwjhdquXZIoVGlrNB5vlrck2sdvOlBzlBjYcH08QL6B2Ln33fbU5(LizhwzftxIDDaZUs9DP6cia(8ZVbqC(uP)G28mhC(U9dBu0i67EEic2ejeLZtpfCENWof3q58CGEfJ0WakGnlCEbc4ZlaxXcHgkNVBirHmhmgdGv3ZB38DdjkK5GXyaScy5rAu298QThKemmGoG21bm7k13LQlGa4Zp)gaX5tL(dAZZCW572pSfraPw3ZdrWMiHOCE6PGZ7e2P4gkNNd0RyKggqbSzHZVhWNxaUIfcnuoF3qIczoymgaRUN3U57gsuiZbJXayfWYJ0OS75vBpijyyaDaTRdy2vQVlvxabWNF(naIZNk9h0MN5GZ3TbZAlA0UNhIGnrcr580tbN3jStXnuophOxXinmGcyZcNFpGpVaCfleAOC(UnxJLfaRUN3U572CnwwaScy5rAu298QThKemmGoG21bm7k13LQlGa4Zp)gaX5tL(dAZZCW57ogleM8UNhIGnrcr580tbN3jStXnuophOxXinmGcyZcNxGa(8cWvSqOHY57gsuiZbJXay1982nF3qIczoymgaRawEKgLDpVA7bjbddOdODDaZUs9DP6cia(8ZVbqC(uP)G28mhC(U5hlS8YODppebBIeIY5PNcoVtyNIBOCEoqVIrAyafWMfo)EaFEb4kwi0q58DBUgllawDpVDZ3T5ASSayfWYJ0OS75vBpijyyafWMfoVab85fGRyHqdLZ3T5ASSay1982nF3MRXYcGvalpsJYUNxT9GKGHbuaBw48ceWNxaUIfcnuoF30JqhLLmawDpVDZ3n9i0rzjdGvalpsJYUNxT9GKGHbuaBw48SbGpVaCfleAOC(UnxJLfaRUN3U572CnwwaScy5rAu298QThKemmGcyZcNNna85fGRyHqdLZ3n9i0rzjdGv3ZB38DtpcDuwYayfWYJ0OS75vBpijyyafWMfopidWNxaUIfcnuoF3MRXYcGv3ZB38DBUgllawbS8ink7EE12dscggqhq76aMDL67s1fqa85NFdG48Ps)bT5zo48DZVtlpYfT75HiytKquop9uW5Dc7uCdLZZb6vmsddOa2SW53eWNxaUIfcnuoF3MRXYcGv3ZB38DBUgllawbS8ink7EE12eKemmGcyZcNhKb4ZlaxXcHgkNVBZ1yzbWQ75TB(UnxJLfaRawEKgLDpVA7bjbddOdODDaZUs9DP6cia(8ZVbqC(uP)G28mhC(UJXcHjV5h298qeSjsikNNEk48oHDkUHY55a9kgPHbuaBw487b85fGRyHqdLZ3T5ASSay1982nF3MRXYcGvalpsJYUNxT9GKGHbuaBw48Bc4ZlaxXcHgkNVBirHmhmgdGv3ZB38DdjkK5GXyaScy5rAu298QThKemmGoG21bm7k13LQlGa4Zp)gaX5tL(dAZZCW57wImoH26EEic2ejeLZtpfCENWof3q58CGEfJ0WakGnlCEbc4ZlaxXcHgkNVBZ1yzbWQ75TB(UnxJLfaRawEKgLDpVBZdYlGbSZR2EqsWWakGnlCE2aWNxaUIfcnuoF3MRXYcGv3ZB38DBUgllawbS8ink7EE12dscggqbSzHZdYa85fGRyHqdLZ3T5ASSay1982nF3MRXYcGvalpsJYUNxT9GKGHbuaBw487AaFEb4kwi0q58DBUgllawDpVDZ3T5ASSayfWYJ0OS75vBpijyyafWMfoFxbGpVaCfleAOC(UnxJLfaRUN3U572CnwwaScy5rAu298QTjijyyafWMfopixaFEb4kwi0q58DdjkK5GXyaS6EE7MVBirHmhmgdGvalpsJYUNxT9GKGHbuaBw4873d4ZlaxXcHgkNVBZ1yzbWQ75TB(UnxJLfaRawEKgLDpVA7bjbddOa2SW533va4ZlaxXcHgkNVBZ1yzbWQ75TB(UnxJLfaRawEKgLDpVABcscggqbSzHZVzxa85fGRyHqdLZ3T5ASSay1982nF3MRXYcGvalpsJYUNxTnbjbddOdO7sL(dAOC(9DzENB5vZRtQrddOlrNWaEWLOyQqODlVsaGoJTe7HhtQXLiBz787gDd48DnRmgOnVaAb80DgqzlBNhW0dt98Bc(8B2Ln3pGoGYw2oVaa0RyKc4dOSLTZZMNhWizteutblJoVDZV7A3ay3itQraSB0nG053nboVDZFLUZ88JOS5nhgJgDEYaV5Diopcs9i3q582nVozHZRVkEESoIyGZB38kUziCE18dBu0i6NNT7fmmGYw2opBE(DNupsJY5fDomzsE6657Qo3Mpc5obfNxIUC(yGhHMoVIVfNN5GZtD587URjnmGYw2opBEEbuAwXZ31pIsoVypwseoVhL60sKoVYbX5z0iiLr6oZRMBZZgaCEQ58T05ZIAOlN)yMFhakyxjZV7UQ48fsyqxpVxY5v8oZ3drwyzZtpfC(6yZqKppnnc3YROHbu2Y25zZZlGsZkE(Ugi1qywXZlAWCloFwZdyeWG8ZNmZ35iMhOZcNVodywXZJAkoVDZlV59sop5R62M)yHqU3pp5JOK05t687URkoFHeg01Hbu2Y25zZZlaa9kgLZR4vN57MjJbAniQ4zr7EE(vY0YRCnDE7M3771DMpR5JokDEMmgOrN)kDN5vtJu68cWUNNStnC(RM3GofOGHbu2Y25zZZdyKsuoVxNbeHZlGjSii6BNhld2zE7MNI28e9Ztn4vXiCEq((uIkjNggqzlBNNnp)gc4DlGb85NxDK88gmRTOnphMgctpmGoG6ClVIg6Hi)uICdGKaq)z5vdOo3YROHEiYpLi3aijaa9KInj6Ybu2Y25b5z5Ac3q68(8gmRTOrNNFNwEKlWNxMSsjkNpQZ8SXoH53aysNNStNNd8OynVtNNOaE6oZt(GBPZF18SXoZtr(vY5JiGuBEEhUgPGpFeHnpqNoVD38kE1zEUeopYWGCJoVDZhNSW59553PLh5kasbjb0T8Q5LjRKEW5ZIAOldZVlzMpTUPZZY1e48aD681npev8SKiCEiAeWA(9GppQP48q0iG18DjStyaLTSDENB5v0qpe5NsKBaKeay5W0J0i4LRGKmywBrRTVr7uCWVEsu0sgWz5AcK0EWz5AcSHAksQlHDaNFLmT8ksgmRTOf2ha60gbfBremmQuZGzTfTW(a)oT8ixbjb0T8kqoGCyJDi1fbhqzlBN35wEfn0dr(Pe5gajbawom9incE5kijdM1w0AB2ODko4xpjkAjd4SCnbsAp4SCnb2qnfj1LWoGZVsMwEfjdM1w0cBga60gbfBremmQuZGzTfTWMb(DA5rUcscOB5vGCa5Wg7qQlcoGYw2opip1sf3q68(8gmRTOrNNLRjW5J6mp)u6DywXZBaX553PLh5A(JzEdioVbZAlAGpVmzLsuoFuN5nG48scOB5vZFmZBaX5JiyyMpT57HhRuI0W8DTD68(8udIvSbCELtMmjcN3U5Jtw48(8aZyGiC(EyEW06mVDZtniwXgW5nywBrJc(8oDEYOwpVtN3Nx5KjtIW5zo48jZ8(8gmRTOnp5uRN)GZto165RZMN2P4ZtonGZZVtlpYfnmGYw2oVZT8kAOhI8tjYnascaSCy6rAe8YvqsgmRTO16H5btRd4xpjkAjd4SCnbsAtWz5AcSHAksAp48RKPLxrcqgmRTOf2ha60gbfBremmQmywBrlSzaOtBeuSfrWWiuObZAlAHndaDAJGITicggvQPMbZAlAHnd870YJCfKeq3YRa5yWS2IwyZqp84bV60K90GKa6wELG7c12h2bGgmRTOf2ma0PTicggb3fQXYHPhPXGbZAlATnB0ofxqbbHAQzWS2IwyFGFNwEKRGKa6wEfihdM1w0c7d9WJh8Qtt2tdscOB5vcUluBFyhaAWS2IwyFaOtBremmcUluJLdtpsJbdM1w0A7B0ofxqbhqhqhqzlBNhKhKqoHHY5rwiSZ8wQGZBaX5DUDW5t68olp1EKgddOo3YROKuYs2yGi2vghqz78DviYclBEApYtMeLZBWS2IgD(imR45jOOCEYPbCENWof3s(86Sq6aQZT8kkajbawom9incE5kijApYtMeLndM1w0aNLRjqsQHGnr23JYqwuoKW8in2aBcVmcLMezLCuf)oT8ixHSOCiH5rASb2eEzeknjYk5yaIUSJGdOSLTZ31YHPhPr6aQZT8kkajbawom9incE5kiP(70zf3GevYB9hzecolxtGK43PLh5kqjuuUQf7W4RJgdquXZIY(oQmxJLfOekkx1IDy81rJdOo3YROaKeay5W0J0i4LRGK6VtNvCdsuifCwUMajzUgllqpcDdIEpcvbjkK9nvzomgTGLkyZUwp3AcCh23rftgd0AquXZIcIDgqDULxrbijaWYHPhPrWlxbjrTwV2RkRyWz5AcKKZTKf2WcvsKsAVk1ae0tzdzHLfCPKgqqkPgvOqONYgYcll4sjnKfi2VJGdOo3YROaKeay5W0J0i4LRGKuC20bB870YJCrBo3swi4SCnbsQhTqSdJVoAm4ClzHcfgrWWeikGNUtZPuNqBbIEHcnxJLfCOsN2X0mGyt6kfkv1JwW7pElg4rOdo3swOqHremmbPd32mOxuMdQ4wEvGOFaLTZ3vQNL5zLv88DTsiHglB(UQ2JjW5t68(89W8GP1za15wEffGKaWryrq03cEYqsEwGvcj0yzTEThtGbiYarkqpsJQaK5ASSarb80DAr6mgOPcqqpLnKfwwWLsAabPKA0buNB5vuascahHfbrFl48oCn2mhgJgL0EWtgsYZcSsiHglR1R9ycmargisb6rAuLZTKf2WcvsKccsBQsnazUgllquapDNwKoJbAcfAUgllquapDNwKoJbAQ43PLh5kquapDNwKoJbAbiQ4zrfCa15wEffGKaWryrq03cEYqcsuiZbJXaLOhHud6zPsn5zbg4rTgdYcHbiYarkqpsJcfkplePVt261EmbgGidePa9ink4akBNFxHmqKcePZVB0nG053nb2nD(icgM5zteuB(iK5G48s0nG05Le48yjPdOo3YROaKeaiFeLSr7XsIqWtgs8JfwEzHkJbAnghvjr3a28s2Ki37eCULSWgev8SOSRwmxUl2h2rqvs0nGnVKnjY9obl5BZkEa15wEffGKaazpnWPiNe)oT8ixb6rOBq07ryaIkEwuWtgsMRXYc0Jq3GO3JqvMdJrlyPc2SR1ZTMa3H9DuXKXaTgev8SOGyhv870YJCfOhHUbrVhHbiQ4zrzxTyUCx0LWUEhbv5ClzHnSqLePK2pGY2576EAZZCW53n6gWUPZVBcea7gzsnoFYmV6zmqB(UgooVDZhJ28udIvSbC(icgM5JC(25DQ3pG6ClVIcqsaGSNg4uKtIFNwEKRGeDdiTjjWaev8SOGNmK4hlS8Ycvgd0AmoQIFNwEKRGeDdiTjjWaev8SOShZLQCULSWgwOsIus7hqDULxrbijaq2tdCkYjXVtlpYvqImPgdquXZIcEYqIFSWYlluzmqRX4Ok(DA5rUcsKj1yaIkEwu2J5svo3swydlujrkP9dOSDEad3YRMhWMuJoVxY5fW9yHq68QjG7XcHuaiIGnbwCKoprrj67pOHY5ZAExkVki4aQZT8kkajbaUR1nNB5vnDsnWlxbjzWS2IgDa15wEffGKaa316MZT8QMoPg4LRGK4hlS8YOdOo3YROaKea4Uw3CULx10j1aVCfKe05PRPdOSDENB5vuascaueSjWIJGNmKCULSWgwOsIus7vbij6gW22kJbAbzs9in28ZKGxUcs66XcHaUdv60oMMbeBs0LaodsneMvCJAWClc4mi1qywXnQbZTiGtuapDNwKoJbAaE)z5vaU0HBBg0lkZbvClVcW9(J76o9uCa15wEffGKaa316MZT8QMoPg4LRGK43PLh5IoG6ClVIcqsaasunNB5vnDsnWlxbj5h2OOr0dEYqY5wYcByHkjsbbPnvPg)oT8ixbj6gWMxYMe5ENaev8SOSVVlQaK5ASSGezsnkui)oT8ixbjYKAmarfplk777IkZ1yzbjYKAuqvasIUbS5LSjrU3jyjFBwXdOo3YROaKeaGevZ5wEvtNud8Yvqs(HTici1aNAWKBK2dEYqY5wYcByHkjsbbPnvjr3a28s2Ki37eSKVnR4buNB5vuascaqIQ5ClVQPtQbE5kiPySqyYB(HGNmKCULSWgwOsIuqqAtvQbij6gWMxYMe5ENGL8TzfRsn(DA5rUcs0nGnVKnjY9obiQ4zrbX(UOcqMRXYcsKj1OqH870YJCfKitQXaev8SOGyFxuzUgllirMuJck4aQZT8kkajbaUR1nNB5vnDsnWlxbjfJfcto4udMCJ0EWtgso3swydlujrkP9dOdOSLTZdyoq(5bdbKAdOo3YROb)WwebKAKKOBaB8l1GNmKulIGHjqjKsSAY7ucq05MqHaILdtpsJH(70zf3GevYB9hzekOk1IiyycshUTzqVOmhuXT8QarVkirHmhmgds0L6ePwJFPwLZTKf2WcvsKYojbkuOZTKf2WcvsKsAtbhqDULxrd(HTici1aijaG9Pevso4jdjirL8w)rgHbjYK80yxT9DbGs0nGTTvgd0cmKpIsIYM5Wy0O7cbkOkj6gW22kJbAbgYhrjrzZCymAu2bzQaelhMEKgd93PZkUbjQK36pYiuOWicgMaLSdvYkUPKulq0pG6ClVIg8dBreqQbqsaa7tjQKCWtgsqIk5T(JmcdsKj5PX(M7OsIUbSTTYyGwGH8rusu2mhgJgfe7OcqSCy6rAm0FNoR4gKOsER)iJWbuNB5v0GFylIasnascayFkrLKdEYqcqs0nGTTvgd0cmKpIsIYM5Wy0OQaelhMEKgd93PZkUbjQK36pYiuOqMmgO1GOINfL9Deke6PSHSWYcUusdiiLuJQc6PSHSWYcUusdquXZIY(odOo3YROb)WwebKAaKeaiFeLSr7XsIWbuNB5v0GFylIasnascayFkrLKdEYqcqSCy6rAm0FNoR4gKOsER)iJWb0bu2Y25bmhi)8IOr0pG6ClVIg8dBu0i6j5vNMSKGNmKKOBaBBRmgOfyiFeLeLnZHXOrbbjEhUgByHkjsfke6PSHSWYcUusdiiLuJQc6PSHSWYcUusdquXZIYoP97hqDULxrd(HnkAe9aKea8QttwsWtgss0nGTTvgd0cmKpIsIYM5Wy0OGG0odOo3YROb)WgfnIEascas0nGn(LAWtgsaILdtpsJH(70zf3GevYB9hzeQsTicgMG0HBBg0lkZbvClVkq0RcsuiZbJXGeDPorQ14xQv5ClzHnSqLePStsGcf6ClzHnSqLePK2uWbuNB5v0GFyJIgrpajbaSpLOsYbpzibiwom9ing6VtNvCdsujV1FKr4aQZT8kAWpSrrJOhGKaadsneMvCJAWClcoVdxJnZHXOrjTh8KHKeJiyycmi1qywXnYhrjduZ5BzNKavXVtlpYvW7pUR70tXaev8SOSlWbuNB5v0GFyJIgrpajbagKAimR4g1G5weCEhUgBMdJrJsAp4jdjjgrWWeyqQHWSIBKpIsgOMZ3Y((buNB5v0GFyJIgrpajbagKAimR4g1G5weCEhUgBMdJrJsAp4jdjjgrWWeyqQHWSIBKpIsgOMZ3YojbQcsuyWsfSzxJnyNFNwEKRGxDAYsgGOINfDaLTZ31bI18MdJrBEkzVNoVdX5Lj1J0Oe85nGjDEYPwpVgT57CeZt7XsopKOqkaiFeLKoFwudD58hZ8K90YkEEMdo)URDdGDJmPgbWUr3a2nD(DtGHbuNB5v0GFyJIgrpajbaYhrjB0ESKie8KHKAaIIMLvmnW7W1OqHs0nGTTvgd0cmKpIsIYM5Wy0OGGeVdxJnSqLePcQsIremmbgKAimR4g5JOKbQ58TGqGQGefgSubB21ei7870YJCf8QttwYaev8SOdOdOSLTZ3vplVAa15wEfnWVtlpYfLu)z5vGNmKy5W0J0yqXzthSXVtlpYfT5ClzHcfgDuQkMmgO1GOINfL9nbzdOSLTZla3PLh5IoG6ClVIg43PLh5IcqsaWHkDAhtZaInj6sWtgs870YJCfikGNUtlsNXaTaev8SOSVJk(DA5rUcshUTzqVOmhuXT8Qaev8SOneK6rUHs23rL5ASSarb80DAr6mgOjuiGmxJLfikGNUtlsNXanHcJokvftgd0AquXZIYUa3za15wEfnWVtlpYffGKaa9i0ni69ieCEhUgBMdJrJsAp4jdjZHXOfSubB2165wtG7W(oQmhgJwWsfSzxtMii2rLZTKf2WcvsKYojboGY257AFAjDEWOZyG28mhCEI(5TB(DMNI8RK05TBEANIpp50aopGP)4UUtpfbFEbSbeHKtkc(8euCEYPbC(D7WTZVb0lkZbvClVkmG6ClVIg43PLh5IcqsaGOaE6oTiDgd0apziXYHPhPXa1A9AVQSIvPg)oT8ixbV)4UUtpfdquXZI2qqQh5gkzFhHc53PLh5k49h31D6PyaIkEw0gcs9i3qji23fbvPg)oT8ixbPd32mOxuMdQ4wEvaIkEwu2J5sHcJiyycshUTzqVOmhuXT8QarVGdOo3YROb(DA5rUOaKeaikGNUtlsNXanWtgso3swydlujrkiiTPqHrhLQIjJbAniQ4zrzFZ9dOo3YROb(DA5rUOaKeaKoCBZGErzoOIB5vGNmKy5W0J0yGATETxvwXQutEwGOaE6oTiDgd0AYZcquXZIkuiGmxJLfikGNUtlsNXanbhqDULxrd870YJCrbijaiD42Mb9IYCqf3YRapzi5ClzHnSqLePGG0McfgDuQkMmgO1GOINfL9n3pG6ClVIg43PLh5IcqsaW7pUR70trWtgso3swydlujrkP9QKyebdtGbPgcZkUr(ikzGAoFlie4aQZT8kAGFNwEKlkajbaV)4UUtpfbN3HRXM5Wy0OK2dEYqY5wYcByHkjsbbPnvjXicgMadsneMvCJ8ruYa1C(wqiqvasIUbS5LSjrU3jyjFBwXdOo3YROb(DA5rUOaKeaOekkx1IDy81rJGNmKGevYB9hzegKitYtJ99SHk143PLh5kquapDNwKoJbAbiQ4zrzFFxekuEwGOaE6oTiDgd0AYZcquXZIk4aQZT8kAGFNwEKlkajbaIc4P70Ck1j0g4jdjwom9ingOwRx7vLvSkjgrWWeyqQHWSIBKpIsgOMZ3Y(MQuRhTG3F8wmWJqhCULSqHcJiyycshUTzqVOmhuXT8QarVka1JwWHkDAXapcDW5wYcfCa15wEfnWVtlpYffGKaarb80DAoL6eAdCEhUgBMdJrJsAp4jdjNBjlSHfQKifeK2uLeJiyycmi1qywXnYhrjduZ5BzFZbuNB5v0a)oT8ixuascaqpPytIUe8KHeG6rled8i0bNBjlCaLTSD(DNupsJsWNNnrqT5RZMhIUw3z(6GkUE(ieOZkp48gq36Mop5dAaNVNasjYkE(SyZXUcggqzlBN35wEfnWVtlpYffGKaa15WKj5PRB9o3apzi5ClzHnSqLePGG0MQauebdtq6WTnd6fL5GkULxfi6vbi(DA5rUcshUTzqVOmhuXT8QaeDzhHcJokvftgd0AquXZIYEmxoGoGYw2oVaCSWYlBEatuQtlr6aQZT8kAGFSWYlJsIs2Hkzf3usQbEYqILdtpsJbQ161EvzfRcsujV1FKryqImjpnqShKPsn(DA5rUcE)XDDNEkgGOINfvOqazUgll4qLoTJPzaXM0vkuQIFNwEKRG0HBBg0lkZbvClVkarfplQGcfgDuQkMmgO1GOINfL997hqz78IOnVDZtqX5DgdHZ79hF(Ko)vZla7EENoVDZ3drwyzZFSqi377ZkE(DvxDEYatnopfnlR45j6Nxa2D30buNB5v0a)yHLxgfGKaaLSdvYkUPKud8KHe)oT8ixbV)4UUtpfdquXZIQsnNBjlSHfQKifeK2uLZTKf2WcvsKYoPDubjQK36pYimirMKNgi23faQMZTKf2WcvsKUlazckuOZTKf2WcvsKcIDubjQK36pYimirMKNgiyJUi4aQZT8kAGFSWYlJcqsaWJoLSClVQPtLiWtgsSCy6rAmqTwV2RkRyvaIEe6OSKbn6YwuNgcsUsVgvPg)oT8ixbV)4UUtpfdquXZIkuiGmxJLfCOsN2X0mGyt6kfkvXVtlpYvq6WTnd6fL5GkULxfGOINfvqvqIcdwQGn7ASbiutGamIGHjajQK34hes0B5vbiQ4zrfuOWOJsvXKXaTgev8SOSV5(buNB5v0a)yHLxgfGKaGhDkz5wEvtNkrGNmKy5W0J0yGATETxvwXQOhHoklzqJUSf1PHGKR0RrvQjplquapDNwKoJbAn5zbiQ4zrbX(9cfciZ1yzbIc4P70I0zmqtf)oT8ixbPd32mOxuMdQ4wEvaIkEwubhqDULxrd8JfwEzuascaE0PKLB5vnDQebEYqY5wYcByHkjsbbPnvbjkmyPc2SRXgGqnbcWicgMaKOsEJFqirVLxfGOINfvWbuNB5v0a)yHLxgfGKaafOZ3QXMbeBef5dAa7aEYqILdtpsJbQ161EvzfRsn(DA5rUcE)XDDNEkgGOINfvOqazUgll4qLoTJPzaXM0vkuQIFNwEKRG0HBBg0lkZbvClVkarfplQGcfgDuQkMmgO1GOINfL997mG6ClVIg4hlS8YOaKeaOaD(wn2mGyJOiFqdyhWtgso3swydlujrkiiTPk1KOBaBEjBsK7DcwY3MvSqHqpLnKfwwWLsAaIkEwu2jTNneCaDaLTSDEXSI148B4Wy0gqDULxrdXyHWKtsIUbSXVudEYqkIGHjqjKsSAY7ucq05MkaXYHPhPXq)D6SIBqIk5T(JmcfkShTqSdJVoAm4ClzHdOo3YROHySqyYbijair3a24xQbpziXpwy5LfQmgO1yCuf)oT8ixbj6gqAtsGbiQ4zrzxGQGevYB9hzegKitYtJ99Dza15wEfneJfctoajbaV60KLe8KHKAMRXYcsKj1yalpsJsHc5hlS8Ycvgd0AmokuiKOqMdgJHEGOdpLRqQGQudqSCy6rAm0FNoR4gKOqQqHmzmqRbrfplk77i4aQZT8kAigleMCascas0nGn(LAWtgs8JfwEzHkJbAnghvbjQK36pYimirMKNg7B2fvaILdtpsJH(70zf3GevYB9hzeoG6ClVIgIXcHjhGKaadsneMvCJAWClcEYqIFSWYlluzmqRX4Ok(DA5rUcs0nG0MKadquXZIY((UOsIremmbgKAimR4g5JOKbQ58TSZgQaelhMEKgd93PZkUbjkKQsnajr3a28s2Ki37eSKVnRyHcJiyycs0nG0MKaduZ5BjXgcoG6ClVIgIXcHjhGKaGeDdyJFPg8KHeKOsER)iJWGezsEASVxGcfYKXaTgev8SOSVJkajXicgMadsneMvCJ8ruYar)aQZT8kAigleMCascaKpIs2O9yjri4jdjjgrWWeyqQHWSIBKpIsgOMZ3ccbQcqSCy6rAm0FNoR4gKOq6aQZT8kAigleMCascaKpIs2O9yjri4jdjjgrWWeyqQHWSIBKpIsgi6vXVtlpYvW7pUR70tXaev8SOneK6rUHsqSJkaXYHPhPXq)D6SIBqIcPdOo3YROHySqyYbijair3a24xQbpzibjQK36pYimirMKNg7B2fvaILdtpsJH(70zf3GevYB9hzeoG6ClVIgIXcHjhGKaadsneMvCJAWClcEYqsIremmbgKAimR4g5JOKbQ58TSVxfGy5W0J0yO)oDwXnirH0buNB5v0qmwim5aKeayqQHWSIBudMBrWtgssmIGHjWGudHzf3iFeLmqnNVLD2qf)oT8ixbV)4UUtpfdquXZI2qqQh5gkzFhvaILdtpsJH(70zf3GefshqDULxrdXyHWKdqsaqIUbSXVudEYqcqSCy6rAm0FNoR4gKOsER)iJWb0bu2Y25fqWcHjFEaZbYpFxfMhmTodOo3YROHySqyYB(HKi7Pbof5K43PLh5kqpcDdIEpcdquXZIcEYqYCnwwGEe6ge9EeQYCymAblvWMDTEU1e4oSVJkMmgO1GOINffe7OIFNwEKRa9i0ni69imarfplk7QfZL7IUe217iOkNBjlSHfQKiLDscCa15wEfneJfctEZpeGKaGeDdyJFPg8KHKAaILdtpsJH(70zf3GevYB9hzekuyebdtGsiLy1K3PeGOZnbvPwebdtq6WTnd6fL5GkULxfi6vbjkK5GXyqIUuNi1A8l1QCULSWgwOsIu2jjqHcDULSWgwOsIusBk4aQZT8kAigleM8MFiajbaSpLOsYbpzifrWWeOesjwn5Dkbi6CtOqaXYHPhPXq)D6SIBqIk5T(Jmchqz787sM5nhgJ288oCDwXZN05Lj1J0Oe85PKtJdC(iNVDE7M3aIZtZkwJSzZHXOnFmwim5ZRtQnFwudDzya15wEfneJfctEZpeGKaaKOAo3YRA6KAGxUcskgleMCWPgm5gP9GNmK4D4ASHfQKiL0(buNB5v0qmwim5n)qascaKpIs2O9yjri48oCn2mhgJgL0EWtgsQXVtlpYvW7pUR70tXaev8SOGyhvsmIGHjWGudHzf3iFeLmq0luOeJiyycmi1qywXnYhrjduZ5BbHafuLAmzmqRbrfplk7870YJCfKOBaBEjBsK7DcquXZIcW9DrOqMmgO1GOINffe870YJCf8(J76o9umarfplQGdOo3YROHySqyYB(HaKeayqQHWSIBudMBrW5D4ASzomgnkP9GNmKKyebdtGbPgcZkUr(ikzGAoFl7KeOk(DA5rUcE)XDDNEkgGOINfLDbkuOeJiyycmi1qywXnYhrjduZ5BzF)aQZT8kAigleM8MFiajbagKAimR4g1G5weCEhUgBMdJrJsAp4jdj(DA5rUcE)XDDNEkgGOINffe7OsIremmbgKAimR4g5JOKbQ58TSVFaLTZVbWKoFsNhzyqULSqDN5zsTgHZtgyYbopnvOZV7UQ48fsyqxd(8re28uGhHwoFpezHLnVppLJLdZBEYarioVbeN3LYRMhOtNVodywXZB38qKFkkyjddOo3YROHySqyYB(HaKeayqQHWSIBudMBrWtgso3swytEwGbPgcZkUr(ikjiiX7W1ydlujrQkjgrWWeyqQHWSIBKpIsgOMZ3YoBmGoGY253vopDnDa15wEfnaDE6AkjhY9cB2bHyzGNmKGevYB9hzegKitYtdeGSDuPwpAHyhgFD0yW5wYcfkeqMRXYcucfLRAXom(6OXawEKgLcQcsuyqImjpnqqANbuNB5v0a05PRPaKeaI03jBmeWoGNmKy5W0J0yqXzthSXVtlpYfT5ClzHcfAomgTGLkyZUMmr2jfrWWeI03jBmeWobjb0T8QbuNB5v0a05PRPaKeaIqifHBZkg8KHelhMEKgdkoB6Gn(DA5rUOnNBjluOqZHXOfSubB21KjYoPicgMqecPiCBwXbjb0T8QbuNB5v0a05PRPaKea0zmqJ2yteYyfSmWtgsremmbIc4P70OgeRydyGOFaLTZdykosnORNxaCTEEUxZBWmogHZZgZ3Fgww665JiyyOGpp6CGZRDQLv8873zEkYVssdZlGAPo7kJY5b6q588tIY5TubN3PZ7ZBWmogHZB38BrSF(0MhIU0J0yya15wEfnaDE6AkajbaV4i1GUUXDTg8KHelhMEKgdkoB6Gn(DA5rUOnNBjluOqZHXOfSubB21KjYoP97mG6ClVIgGopDnfGKaGd5EHTEcnfbpzi5ClzHnSqLePGG0McfQgKOWGezsEAGG0oQGevYB9hzegKitYtdeKazDrWbuNB5v0a05PRPaKeaysigPVtcEYqILdtpsJbfNnDWg)oT8ix0MZTKfkuO5Wy0cwQGn7AYezNuebdtGjHyK(ozqsaDlVAa15wEfnaDE6AkajbGipUDmndM8TuWtgsremmbIc4P70OgeRydyGOxLZTKf2WcvsKsA)a6akBz78BaZAlA0buNB5v0GbZAlAuseuSLgQaE5kiPSOCiH5rASb2eEzeknjYk5i4jdj143PLh5kquapDNwKoJbAbiQ4zrfkKFNwEKRG0HBBg0lkZbvClVkarfplQGQuRhTGdv60IbEe6GZTKfkuypAbV)4TyGhHo4ClzHQaK5ASSGdv60oMMbeBsxPqPqHMdJrlyPc2SR1ZT2MDH9DeuOWOJsvXKXaTgev8SOSV5(buNB5v0GbZAlAuascaeuSLgQaE5kijfN7rqSrbIO1uiOjh8KHe)oT8ixbV)4UUtpfdquXZIY(oQudqiytK99OmKfLdjmpsJnWMWlJqPjrwjhfkKFNwEKRqwuoKW8in2aBcVmcLMezLCmarfplQGcfgDuQkMmgO1GOINfL9n3pG6ClVIgmywBrJcqsaGGIT0qfWlxbjjHOlzsi2yHukQbpziXVtlpYvW7pUR70tXaev8SOQudqiytK99OmKfLdjmpsJnWMWlJqPjrwjhfkKFNwEKRqwuoKW8in2aBcVmcLMezLCmarfplQGcfgDuQkMmgO1GOINfLDboG6ClVIgmywBrJcqsaGGIT0qfWlxbjjD4wL7QMe5BBSoOZtRd4jdj(DA5rUcE)XDDNEkgGOINfvLAacbBISVhLHSOCiH5rASb2eEzeknjYk5OqH870YJCfYIYHeMhPXgyt4LrO0KiRKJbiQ4zrfuOWOJsvXKXaTgev8SOSV5(buNB5v0GbZAlAuascaeuSLgQqbpziPg)oT8ixbV)4UUtpfdquXZIkuyebdtq6WTnd6fL5GkULxfi6fuLAacbBISVhLHSOCiH5rASb2eEzeknjYk5OqH870YJCfYIYHeMhPXgyt4LrO0KiRKJbiQ4zrfCaLTSD(neW7wad4dOSLTZVbqCEdM1w0MNCAaN3aIZdmJbIuBEKAPIBOCEwUMabFEYPwpFeopbfLZZKqQnVxY579eIY5jNgW5bm9h31D6P48QLmZhrWWmFsNF)oZtr(vs68hCEnsPco)bNhm6mgObGDVX8QLmZhdr3q48gqVMF)oZtr(vsQGdOSLTZ7ClVIgmywBrJcqsaGGIT0qfWP6ZizWS2I2EWtgsaILdtpsJbApYtMeLndM1w0uPMAgmRTOf2h6Hhp4vNMSNgKeq3YRyN0(DuXVtlpYvW7pUR70tXaev8SOGyZUiuObZAlAH9HE4XdE1Pj7Pbjb0T8kqSFhvQXVtlpYvGOaE6oTiDgd0cquXZIcIn7IqH870YJCfKoCBZGErzoOIB5vbiQ4zrbXMDrqbvPgGmywBrlSzaOtB870YJCjuObZAlAHnd870YJCfGOINfvOqwom9ingmywBrR1dZdMwhs7fuqHcnywBrlSp0dpEWRonzpnijGULxbcsmzmqRbrfpl6akBz78o3YRObdM1w0OaKeaiOylnubCQ(msgmRTOTj4jdjaXYHPhPXaTh5jtIYMbZAlAQutndM1w0cBg6Hhp4vNMSNgKeq3YRyN0(DuXVtlpYvW7pUR70tXaev8SOGyZUiuObZAlAHnd9WJh8Qtt2tdscOB5vGy)oQuJFNwEKRarb80DAr6mgOfGOINffeB2fHc53PLh5kiD42Mb9IYCqf3YRcquXZIcIn7IGcQsnazWS2IwyFaOtB870YJCjuObZAlAH9b(DA5rUcquXZIkuilhMEKgdgmRTO16H5btRdPnfuqHcnywBrlSzOhE8GxDAYEAqsaDlVceKyYyGwdIkEw0bu2Y253LmZFLUZ8xHZF18euCEdM1w0MVhESsjsN3NpIGHb85jO48gqC(ZaIW5VAE(DA5rUcZlGHZNmZxyAar48gmRTOnFp8yLsKoVpFebdd4ZtqX5Jod48xnp)oT8ixHbu2Y25DULxrdgmRTOrbijaqqXwAOc4u9zKmywBrBp4jdjazWS2IwyFaOtBeuSfrWWOsndM1w0cBg43PLh5karfplQqHaYGzTfTWMbGoTrqXwebdJGdOSLTZ7ClVIgmywBrJcqsaGGIT0qfWP6ZizWS2I2MGNmKaKbZAlAHndaDAJGITicggvQzWS2IwyFGFNwEKRaev8SOcfcidM1w0c7daDAJGITicggbx2Ywla]] )

end
