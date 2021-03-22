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


    spec:RegisterPack( "Unholy", 20210321, [[defdfcqiaXJqrCjajLnru9jbvJcvvNcvLvbirVsPQMfq1TqrIDj0VuQ0Weu6ya0Yik9muuMgkQCnLk2gaKVba04qrv15qrvyDaOEhkQIAEef3dr2NsvoiauleO0drrQjcu0fbaSruuf5JOOQmsbfvDsbfzLaQxkOOYmbaDtbfL2PsHFIIKgQGcwkGK8uImvLIUkkQsBfqs1xbKWybKAVk5Vs1Gv1HPAXc8yctMKldTzu6ZsPrdKtlA1ck0RvknBsDBuz3s(TkdxkooqHLd65inDkxhHTJO(okmEaKZliRxqrX8rv2VIxaU2CjPCdxBiByLfWWYmzbmklGHLzHfWLKfQbxsnUyR3IlPY5WLeZBb60HwsnEi95Q1Mlj6raf4scKznuaE3DBtderquCC7stocTB5vcOZA7stoXUlPaIuBHPAfSKuUHRnKnSYcyyzMSagLfWWk7oaOLeTbfRnKDhzxsGsLcRvWssHuXscmr3anFyUkBbzZZ8wGoDOb4WSouaAEzbe85LnSYc4a8amtdYRwKcWdWmL5bWQWib14WYOZB38GzbM7cMiBQXDbt0nq05btcCE7M)kDO5fhrzZBoSfn68maDZ7qCEeGAqHHQ5TBEDsgNxFv78yDeTGM3U55CZq4887h2POr0mptaKV4amtzEWmPEGgvZl5cyYMI01ZhgCHnFakCckoVcD18TGocnDEoFlop7bNN6Q5bZWC04amtzEMxAwTZduCeLAEPgSuiCEpi1PLiDEUdIZZQrakd0HMNF3MN52FEQ5IT05ZIAORM)yNFN95J555bZWG08fsyqxpVxQ558qZ3arYyzZtpoC(6ykqumpnnc3YROXbyMY8mV0SANN5jKAimR25LmyUfNpR5bWmvaG5t25dDeZdYjJZxNbkR25rnfN3U5v38EPMNXvHBZFKrOWBMNXruk68jDEWmminFHeg01XbyMY8mniVAr18CEfA(WzZwqwhICEw0WNxCLkT8kxtN3U59MgDO5ZA(GJsNNnBbz05VshAE(1iLoptdMZZWPgo)vZBqNcIV4amtzEaSsHQ596mqiCEMkHfarF78yzWqZB38u0MNOzEQbVQfHZda0KkKlf04amtz(nzQGjtfGNF(nqgZBWS2I28cyAim94ssNuJU2Cj5h2POr0S2CTbGRnxsy5bAuTa7ssatdHPVKuOBG6BRSfKfzzCeLcvDZHTOrNFpsZlcj0yhlKlr6884np0tvhjJLfDLIgrakPgDE5Zd9u1rYyzrxPOriY5zrNxgsZdiGljxy5vljVc1vLAzRnKDT5sclpqJQfyxscyAim9LKcDduFBLTGSilJJOuOQBoSfn687rA(DwsUWYRwsEfQRk1YwBWS1MljS8anQwGDjjGPHW0xsazEYom9angBUtNvBhsuPO3Cmq48YNN)5diyzJkhUTBqVOShKZT8QirZ8YNhsui7bBXOcDLorQ1fxQJy5bAunV85DHLKXowixI05LH08mBEE8M3fwsg7yHCjsNN08YopFljxy5vljf6gOU4s9YwBWCRnxsy5bAuTa7ssatdHPVKaY8KDy6bAm2CNoR2oKOsrV5yGWLKlS8QLe2KkKlflBTXoRnxsy5bAuTa7sYfwE1sIfPgcZQTtnyUfxscyAim9LKcdiyzJSi1qywTDghrPIuZfBNxgsZZS5LpV4oT6yurV5eUoudfJqKZZIoVmZZSLKiKqJDZHTOrxBa4YwBaGwBUKWYd0OAb2LKlS8QLelsneMvBNAWClUKeW0qy6ljfgqWYgzrQHWSA7moIsfPMl2oVmZd4ssesOXU5Ww0ORnaCzRnaaxBUKWYd0OAb2LKlS8QLelsneMvBNAWClUKeW0qy6ljfgqWYgzrQHWSA7moIsfPMl2oVmKMNzZlFEirHrl5WUDDMBEzMxCNwDmQOxH6QsfHiNNfDjjcj0y3CylA01gaUS1gm)Rnxsy5bAuTa7sYfwE1sIXruQoTblfcxskKkGzJLxTKakaH18MdBrBEkdVHoVdX5vj1d0Oc85nqjDEgPwpVgT5dDeZtBWsnpKOq6UmoIsrNplQHUA(JDEgEAz1op7bNhmlWCxWeztnUlyIUbkC68GjbgxscyAim9Le)ZdK5POzz1sJIqcnoppEZRq3a13wzlilYY4ikfQ6MdBrJo)EKMxesOXowixI055BE5ZRWacw2ilsneMvBNXruQi1CX253BEMnV85HefgTKd721z28YmV4oT6yurVc1vLkcropl6Yw2sYpShqaP2AZ1gaU2CjHLhOr1cSljbmneM(sI)5diyzJucLcRU6oUieDHnppEZdK5j7W0d0yS5oDwTDirLIEZXaHZZ38YNN)5diyzJkhUTBqVOShKZT8QirZ8YNhsui7bBXOcDLorQ1fxQJy5bAunV85DHLKXowixI05LH08mBEE8M3fwsg7yHCjsNN08YopFljxy5vljf6gOU4s9YwBi7AZLewEGgvlWUKeW0qy6ljirLIEZXaHrfYMI0MxM55FEad787pVcDduFBLTGSilJJOuOQBoSfn68aLZZS55BE5ZRq3a13wzlilYY4ikfQ6MdBrJoVmZdGMx(8azEYom9angBUtNvBhsuPO3Cmq4884nFablBKYWHCz125sQfjAwsUWYRwsytQqUuSS1gmBT5sclpqJQfyxscyAim9LeKOsrV5yGWOcztrAZlZ8YUZ8YNxHUbQVTYwqwKLXruku1nh2IgD(9MFN5LppqMNSdtpqJXM70z12Hevk6nhdeUKCHLxTKWMuHCPyzRnyU1MljS8anQwGDjjGPHW0xsazEf6gO(2kBbzrwghrPqv3CylA05LppqMNSdtpqJXM70z12Hevk6nhdeoppEZZMTGSoe58SOZlZ87mppEZd9u1rYyzrxPOreGsQrNx(8qpvDKmww0vkAeICEw05Lz(DwsUWYRwsytQqUuSS1g7S2Cj5clVAjX4ikvN2GLcHljS8anQwGDzRnaqRnxsy5bAuTa7ssatdHPVKaY8KDy6bAm2CNoR2oKOsrV5yGWLKlS8QLe2KkKlflBzljOlsxtxBU2aW1MljS8anQwGDj5clVAj5qHxy3oielBjPqQaMnwE1scOYfPRPljbmneM(scsuPO3CmqyuHSPiT53BEa0oZlFE(NVbTyRdBVqAm6cljJZZJ38azEZ1yzrkbh3v9wh2EH0yelpqJQ55BE5ZdjkmQq2uK287rA(Dw2AdzxBUKWYd0OAb2LKaMgctFjr2HPhOXiNhgpyxCNwDmkA3fwsgNNhV5nh2Iw0soSBxxL48YqA(acw2yG(ovNLagkQiGULxTKCHLxTKc03P6SeWqlBTbZwBUKWYd0OAb2LKaMgctFjr2HPhOXiNhgpyxCNwDmkA3fwsgNNhV5nh2Iw0soSBxxL48YqA(acw2yacPiCBwTrfb0T8QLKlS8QLuacPiCBwTlBTbZT2CjHLhOr1cSljbmneM(skGGLnsuGoDOo1Gy1AGIenljxy5vljD2cYO9WiHQLdlBzRn2zT5sclpqJQfyxsUWYRwsEjqQbDDx4A9ssHubmBS8QLeaUei1GUEEM2165fEnVbZ2weopZnFZzyzPRNpGGLLc(8OlanV2PwwTZd4oZtrXvkACEMxl1zygunpihQMxCkunVLC48oDEFEdMTTiCE7MFlInZN28q0vEGgJljbmneM(sISdtpqJropmEWU4oT6yu0UlSKmoppEZBoSfTOLCy3UUkX5LH08aUZYwBaGwBUKWYd0OAb2LKaMgctFj5cljJDSqUePZVhP5LDEE8MN)5HefgviBksB(9in)oZlFEirLIEZXaHrfYMI0MFpsZdGc788TKCHLxTKCOWlS3qOP4YwBaaU2CjHLhOr1cSljbmneM(sISdtpqJropmEWU4oT6yu0UlSKmoppEZBoSfTOLCy3UUkX5LH08beSSr2eIb67urfb0T8QLKlS8QLeBcXa9DQLT2G5FT5sclpqJQfyxscyAim9LuablBKOaD6qDQbXQ1afjAMx(8UWsYyhlKlr68KMhWLKlS8QLuG32p2UbtXw6Yw2sQfleMI1MRnaCT5sclpqJQfyxscyAim9LuablBKsOuy1v3XfHOlS5LppqMNSdtpqJXM70z12Hevk6nhdeoppEZ3GwS1HTxingDHLKXLKlS8QLKcDduxCPEzRnKDT5sclpqJQfyxscyAim9LeKOsrV5yGWOcztrAZlZ8aYS55XBE2SfK1HiNNfDEzMFN5LppqMxHbeSSrwKAimR2oJJOurIMLKlS8QLKcDduxCPEzRny2AZLewEGgvlWUKeW0qy6ljXDA1XOIEZjCDOgkgHiNNfDE5ZZ)8MRXYIkKn1yelpqJQ55XBEXrglVSyLTGSoRJZZJ38qIczpylgBaHo84UcPrS8anQMNV5Lpp)ZdK5j7W0d0yS5oDwTDirH055XBE2SfK1HiNNfDEzMFN55Bj5clVAj5vOUQulBTbZT2CjHLhOr1cSljbmneM(ssHbeSSrwKAimR2oJJOurQ5ITZV38mBE5ZdK5j7W0d0yS5oDwTDirH0LKlS8QLeJJOuDAdwkeUS1g7S2CjHLhOr1cSljbmneM(ssHbeSSrwKAimR2oJJOurIM5LpV4oT6yurV5eUoudfJqKZZI2raQbfgQMFV53zE5ZdK5j7W0d0yS5oDwTDirH0LKlS8QLeJJOuDAdwkeUS1gaO1MljS8anQwGDjjGPHW0xsqIkf9MJbcJkKnfPnVmZlByNx(8azEYom9angBUtNvBhsuPO3Cmq4sYfwE1ssHUbQlUuVS1gaGRnxsy5bAuTa7ssatdHPVKuyablBKfPgcZQTZ4ikvKAUy78YmpGZlFEGmpzhMEGgJn3PZQTdjkKUKCHLxTKyrQHWSA7udMBXLT2G5FT5sclpqJQfyxscyAim9LKcdiyzJSi1qywTDghrPIuZfBNxM5zU5LpV4oT6yurV5eUoudfJqKZZI2raQbfgQMxM53zE5ZdK5j7W0d0yS5oDwTDirH0LKlS8QLelsneMvBNAWClUS1gmpwBUKWYd0OAb2LKaMgctFjbK5j7W0d0yS5oDwTDirLIEZXaHljxy5vljf6gOU4s9Yw2ssCKXYlJU2CTbGRnxsy5bAuTa7ssatdHPVKi7W0d0yKA9gTxvwTZlFEirLIEZXaHrfYMI0MFV5beanV855FEXDA1XOIEZjCDOgkgHiNNfDEE8MhiZBUgll6qUq9JTBGWUY5kufXYd0OAE5ZlUtRogvu5WTDd6fL9GCULxfHiNNfDE(MNhV5dokDE5ZZMTGSoe58SOZlZ8ac4sYfwE1sIYWHCz125sQTS1gYU2CjHLhOr1cSljxy5vljkdhYLvBNlP2ssHubmBS8QLKeAZB38euCEN1q48EZjMpPZF18mnyoVtN3U5BGizSS5pYiu4nnz1opqvyyEgGsnopfnlR25jAMNPbZWPljbmneM(ssCNwDmQO3CcxhQHIriY5zrNx(88pVlSKm2Xc5sKo)EKMx25LpVlSKm2Xc5sKoVmKMFN5LppKOsrV5yGWOcztrAZV38ag253FE(N3fwsg7yHCjsNhOCEa088nppEZ7cljJDSqUePZV387mV85Hevk6nhdegviBksB(9MN5c788TS1gmBT5sclpqJQfyxscyAim9LezhMEGgJuR3O9QYQDE5ZdK5PhHoilvuJUQheQJaKZ1OXiwEGgvZlFE(NxCNwDmQO3CcxhQHIriY5zrNNhV5bY8MRXYIoKlu)y7giSRCUcvrS8anQMx(8I70QJrfvoCB3GErzpiNB5vriY5zrNNV5LppKOWOLCy3UoZn)EZZ)8mB(9NpGGLncjQu0fhes0y5vriY5zrNNV55XB(GJsNx(8SzliRdropl68YmVSaUKCHLxTK8GJll3YR66KlyzRnyU1MljS8anQwGDjjGPHW0xsKDy6bAmsTEJ2RkR25Lpp9i0bzPIA0v9GqDeGCUgngXYd0OAE5ZZ)8QZIefOthQhOZwqwxDweICEw053BEabCEE8MhiZBUgllsuGoDOEGoBbzrS8anQMx(8I70QJrfvoCB3GErzpiNB5vriY5zrNNVLKlS8QLKhCCz5wEvxNCblBTXoRnxsy5bAuTa7ssatdHPVKCHLKXowixI053J08YoV85HefgTKd721zU53BE(NNzZV)8beSSrirLIU4GqIglVkcropl688TKCHLxTK8GJll3YR66KlyzRnaqRnxsy5bAuTa7ssatdHPVKi7W0d0yKA9gTxvwTZlFE(NxCNwDmQO3CcxhQHIriY5zrNNhV5bY8MRXYIoKlu)y7giSRCUcvrS8anQMx(8I70QJrfvoCB3GErzpiNB5vriY5zrNNV55XB(GJsNx(8SzliRdropl68YmpG7SKCHLxTKOGCXwn2nqyNOyCqduOLT2aaCT5sclpqJQfyxscyAim9LKlSKm2Xc5sKo)EKMx25Lpp)ZRq3a19s1vOWdfTuSnR255XBEONQosgll6kfncropl68YqAEazU55Bj5clVAjrb5ITASBGWorX4GgOqlBzlPgikoUa3wBU2aW1Mljxy5vlPMZYRwsy5bAuTa7YwBi7AZLKlS8QLe0tk2vORwsy5bAuTa7Yw2ssCNwDmk6AZ1gaU2CjHLhOr1cSljbmneM(sISdtpqJropmEWU4oT6yu0UlSKmoppEZhCu68YNNnBbzDiY5zrNxM5LfaTKCHLxTKAolVAzRnKDT5sclpqJQfyxscyAim9LK4oT6yurIc0Pd1d0zlilcropl68Ym)oZlFEXDA1XOIkhUTBqVOShKZT8Qie58SODeGAqHHQ5Lz(DMx(8MRXYIefOthQhOZwqwelpqJQ55XBEGmV5ASSirb60H6b6SfKfXYd0OAEE8Mp4O05LppB2cY6qKZZIoVmZZSDwsUWYRwsoKlu)y7giSRqxTS1gmBT5sclpqJQfyxsUWYRws0Jq3HO3GWLKaMgctFjzoSfTOLCy3UEJW6mBN5Lz(DMx(8MdBrlAjh2TRRsC(9MFN5LpVlSKm2Xc5sKoVmKMNzljriHg7MdBrJU2aWLT2G5wBUKWYd0OAb2LKlS8QLerb60H6b6SfKTKuivaZglVAjfM)0k68GvNTGS5zp48enZB387mpffxPOZB380qLyEgPbAEaCZjCDOgkc(8mvdeczKue85jO48msd08GPd3o)MqVOShKZT8Q4ssatdHPVKi7W0d0yKA9gTxvwTZlFE(NxCNwDmQO3CcxhQHIriY5zr7ia1GcdvZlZ87mppEZlUtRogv0BoHRd1qXie58SODeGAqHHQ53BEad788nV855FEXDA1XOIkhUTBqVOShKZT8Qie58SOZlZ8Tc1884nFablBu5WTDd6fL9GCULxfjAMNVLT2yN1MljS8anQwGDjjGPHW0xsUWsYyhlKlr687rAEzNNhV5dokDE5ZZMTGSoe58SOZlZ8Yc4sYfwE1sIOaD6q9aD2cYw2Ada0AZLewEGgvlWUKeW0qy6ljYom9angPwVr7vLv78YNN)5vNfjkqNoupqNTGSU6Sie58SOZZJ38azEZ1yzrIc0Pd1d0zlilILhOr188TKCHLxTKuoCB3GErzpiNB5vlBTba4AZLewEGgvlWUKeW0qy6ljxyjzSJfYLiD(9inVSZZJ38bhLoV85zZwqwhICEw05LzEzbCj5clVAjPC42Ub9IYEqo3YRw2AdM)1MljS8anQwGDjjGPHW0xsUWsYyhlKlr68KMhW5LpVcdiyzJSi1qywTDghrPIuZfBNFV5z2sYfwE1sYBoHRd1qXLT2G5XAZLewEGgvlWUKCHLxTK8Mt46qnuCjjGPHW0xsUWsYyhlKlr687rAEzNx(8kmGGLnYIudHz12zCeLksnxSD(9MNzZlFEGmVcDdu3lvxHcpu0sX2SAxsIqcn2nh2IgDTbGlBTbGHDT5sclpqJQfyxscyAim9LeKOsrV5yGWOcztrAZlZ8aYCZlFE(NxCNwDmQirb60H6b6SfKfHiNNfDEzMhWWoppEZRolsuGoDOEGoBbzD1zriY5zrNNVLKlS8QLeLGJ7QERdBVqACzRnaeW1MljS8anQwGDjjGPHW0xsKDy6bAmsTEJ2RkR25LpVcdiyzJSi1qywTDghrPIuZfBNxM5LDE5ZZ)8nOf9Mt0BbDe6OlSKmoppEZhqWYgvoCB3GErzpiNB5vrIM5LppqMVbTOd5c1BbDe6OlSKmopFljxy5vljIc0Pd1Dk1j02YwBaOSRnxsy5bAuTa7sYfwE1sIOaD6qDNsDcTTKeW0qy6ljxyjzSJfYLiD(9inVSZlFEfgqWYgzrQHWSA7moIsfPMl2oVmZl7ssesOXU5Ww0ORnaCzRnaKzRnxsy5bAuTa7ssatdHPVKaY8nOfBbDe6OlSKmUKCHLxTKGEsXUcD1Yw2sQfleMIUF4AZ1gaU2CjHLhOr1cSljkkwsI70QJrfPhHUdrVbHriY5zrxsUWYRwsm80wscyAim9LK5ASSi9i0Di6nimILhOr18YN3CylArl5WUD9gH1z2oZlZ87mV85zZwqwhICEw053B(DMx(8I70QJrfPhHUdrVbHriY5zrNxM55F(wHAEGY5dBeaCN55BE5Z7cljJDSqUePZldP5z2YwBi7AZLewEGgvlWUKeW0qy6lj(NhiZt2HPhOXyZD6SA7qIkf9MJbcNNhV5diyzJucLcRU6oUieDHnpFZlFE(NpGGLnQC42Ub9IYEqo3YRIenZlFEirHShSfJk0v6ePwxCPoILhOr18YN3fwsg7yHCjsNxgsZZS55XBExyjzSJfYLiDEsZl788TKCHLxTKuOBG6Il1lBTbZwBUKWYd0OAb2LKaMgctFjfqWYgPekfwD1DCri6cBEE8MhiZt2HPhOXyZD6SA7qIkf9MJbcxsUWYRwsytQqUuSS1gm3AZLewEGgvlWUKuivaZglVAjfMyN3CylAZlcj0z1oFsNxLupqJkWNNYinbO5dCX25TBEdeopnRwnYumh2I28TyHWumVoP28zrn0vXLKlS8QLeKO6UWYR66KAljQbtHT2aWLKaMgctFjjcj0yhlKlr68KMhWLKoPwVCoCj1IfctXYwBSZAZLewEGgvlWUKCHLxTKyCeLQtBWsHWLKaMgctFjX)8I70QJrf9Mt46qnumcropl687n)oZlFEfgqWYgzrQHWSA7moIsfjAMNhV5vyablBKfPgcZQTZ4ikvKAUy787npZMNV5Lpp)ZZMTGSoe58SOZlZ8I70QJrfvOBG6EP6ku4HIqKZZIo)(ZdyyNNhV5zZwqwhICEw053BEXDA1XOIEZjCDOgkgHiNNfDE(wsIqcn2nh2IgDTbGlBTbaAT5sclpqJQfyxsUWYRwsSi1qywTDQbZT4ssatdHPVKuyablBKfPgcZQTZ4ikvKAUy78YqAEMnV85f3PvhJk6nNW1HAOyeICEw05LzEMnppEZRWacw2ilsneMvBNXruQi1CX25LzEaxsIqcn2nh2IgDTbGlBTba4AZLewEGgvlWUKCHLxTKyrQHWSA7udMBXLKaMgctFjjUtRogv0BoHRd1qXie58SOZV387mV85vyablBKfPgcZQTZ4ikvKAUy78YmpGljriHg7MdBrJU2aWLT2G5FT5sclpqJQfyxsUWYRwsSi1qywTDQbZT4ssHubmBS8QL0MGs68jDEKLffwsg1HMNn1AeopdqPa080KJopyggKMVqcd6AWNpGWMNc6i0Q5BGizSS595PcSCyEZZaecX5nq48UsD18GC681zGYQDE7MhIIJJdlvCjjGPHW0xsUWsYyxDwKfPgcZQTZ4ik187rAEriHg7yHCjsNx(8kmGGLnYIudHz12zCeLksnxSDEzMN5w2YwskK1j02AZ1gaU2Cj5clVAjXLLQZcrmmdUKWYd0OAb2LT2q21MljS8anQwGDjDnljkAljxy5vljYom9anUKi7AcCjX)8iyqKnnOkMfvajmpqJDWGWlJGRRqYPaNx(8I70QJrfZIkGeMhOXoyq4LrW1vi5uGri6QqZZ3ssHubmBS8QLuyaIKXYMN2GIKnr18gmRTOrNpaZQDEckQMNrAGM3jSJZTumVolKUKi7WE5C4sI2GIKnrv3GzTfTLT2GzRnxsy5bAuTa7s6Awsu0wsUWYRwsKDy6bACjr21e4ssCNwDmQiLGJ7QERdBVqAmcropl68Ym)oZlFEZ1yzrkbh3v9wh2EH0yelpqJQLezh2lNdxsn3PZQTdjQu0BogiCzRnyU1MljS8anQwGDjDnljkAljxy5vljYom9anUKi7AcCjzUgllspcDhIEdcJy5bAunV85HefoVmZl78YN3CylArl5WUD9gH1z2oZlZ87mV85zZwqwhICEw053B(DwsKDyVCoCj1CNoR2oKOq6YwBSZAZLewEGgvlWUKUMLefTLKlS8QLezhMEGgxsKDnbUKCHLKXowixI05jnpGZlFE(NhiZd9u1rYyzrxPOreGsQrNNhV5HEQ6izSSORu0ywZV38aUZ88TKi7WE5C4sIA9gTxvwTlBTbaAT5sclpqJQfyxsxZsII2sYfwE1sISdtpqJljYUMaxsnOfBDy7fsJrxyjzCEE8MpGGLnsuGoDOUtPoH2IenZZJ38MRXYIoKlu)y7giSRCUcvrS8anQMx(8nOf9Mt0BbDe6OlSKmoppEZhqWYgvoCB3GErzpiNB5vrIMLezh2lNdxsCEy8GDXDA1XOODxyjzCzRnaaxBUKWYd0OAb2LKlS8QL0rybq03UKuivaZglVAjfM1ZY8SYQDEG6jKqJLnFyq7Te48jDEF(gyEW0cTKeW0qy6lj1zrYjKqJL1B0ElbgHilePG8anoV85bY8MRXYIefOthQhOZwqwelpqJQ5LppqMh6PQJKXYIUsrJiaLuJUS1gm)Rnxsy5bAuTa7ssatdHPVKuNfjNqcnwwVr7TeyeISqKcYd048YN3fwsg7yHCjsNFpsZl78YNN)5bY8MRXYIefOthQhOZwqwelpqJQ55XBEZ1yzrIc0Pd1d0zlilILhOr18YNxCNwDmQirb60H6b6SfKfHiNNfDE(wsUWYRwshHfarF7YwBW8yT5sclpqJQfyxscyAim9LeKOq2d2IrkrdcPg0ZkILhOr18YNN)5vNfzHh16SizegHilePG8anoppEZRolgOVt1B0ElbgHilePG8anopFljxy5vlPJWcGOVDzRnamSRnxsy5bAuTa7sYfwE1s6iSai6Bxs6SWUqTK2zjjGPHW0xsUWsYyhlKlr68mL5DHLKXU6Si5esOXY6nAVLaNFV5LDjPqQaMnwE1skmXoVbcH48oeNNz7pV5Ww0OZZLuAwTZdupma(8mvclaI(25TBEkAenZhGMHW5baAsfYLcACzRnaeW1MljS8anQwGDjrrXssCNwDmQi9i0Di6nimcropl6sYfwE1sIHN2ssatdHPVKmxJLfPhHUdrVbHrS8anQMx(8MdBrlAjh2TR3iSoZ2zEzMFN5LppB2cY6qKZZIo)EZVZ8YNxCNwDmQi9i0Di6nimcropl68Ymp)Z3kuZduoFyJaG7mpFZlFExyjzSJfYLiDEsZd4YwBaOSRnxsy5bAuTa7ssHubmBS8QLeawy5vZdatQrN3l18m1gSqiDE(zQnyHq6UsiyqGLaPZtuuIMMdAOA(SM3vQRI8TKCHLxTKeUw3DHLx11j1ws6KA9Y5WLKbZAlA0LT2aqMT2CjHLhOr1cSljxy5vljHR1Dxy5vDDsTLKoPwVCoCjjoYy5Lrx2AdazU1MljS8anQwGDj5clVAjjCTU7clVQRtQTK0j16LZHljOlsxtx2Ada3zT5sclpqJQfyxskKkGzJLxTKCHLxrJkK1j02(K2LIGbbwce8KLKlSKm2Xc5sKscq5arHUbQVTYwqwuLupqJD)mf4LZHKUgSqia7qUq9JTBGWUcDfaZIudHz12Pgm3IamlsneMvBNAWClcWefOthQhOZwqga3CwEfaRC42Ub9IYEqo3YRayV5eUoudfxsUWYRwscxR7UWYR66KAljDsTE5C4ssCNwDmk6YwBaiaAT5sclpqJQfyxscyAim9LKlSKm2Xc5sKo)EKMx25Lpp)ZlUtRogvuHUbQ7LQRqHhkcropl68YmpGHDE5ZdK5nxJLfviBQXiwEGgvZZJ38I70QJrfviBQXie58SOZlZ8ag25LpV5ASSOcztngXYd0OAE(Mx(8azEf6gOUxQUcfEOOLITz1UKCHLxTKGev3fwEvxNuBjPtQ1lNdxs(HDkAenlBTbGaGRnxsy5bAuTa7ssatdHPVKCHLKXowixI053J08YoV85vOBG6EP6ku4HIwk2Mv7sIAWuyRnaCj5clVAjbjQUlS8QUoP2ssNuRxohUK8d7beqQTS1gaY8V2CjHLhOr1cSljbmneM(sYfwsg7yHCjsNFpsZl78YNN)5bY8k0nqDVuDfk8qrlfBZQDE5ZZ)8I70QJrfvOBG6EP6ku4HIqKZZIo)EZdyyNx(8azEZ1yzrfYMAmILhOr1884nV4oT6yurfYMAmcropl687npGHDE5ZBUgllQq2uJrS8anQMNV55Bj5clVAjbjQUlS8QUoP2ssNuRxohUKAXcHPO7hUS1gaY8yT5sclpqJQfyxscyAim9LKlSKm2Xc5sKopP5bCjrnykS1gaUKCHLxTKeUw3DHLx11j1ws6KA9Y5WLulwimflBzljdM1w0ORnxBa4AZLewEGgvlWUKCHLxTKYIkGeMhOXoyq4LrW1vi5uGljbmneM(sI)5f3PvhJksuGoDOEGoBbzriY5zrNNhV5f3PvhJkQC42Ub9IYEqo3YRIqKZZIopFZlFE(NVbTOd5c1BbDe6OlSKmoppEZ3Gw0BorVf0rOJUWsY48YNhiZBUgll6qUq9JTBGWUY5kufXYd0OAEE8M3CylArl5WUD9gH1LnSZlZ87mpFZZJ38bhLoV85zZwqwhICEw05LzEzbCjvohUKYIkGeMhOXoyq4LrW1vi5uGlBTHSRnxsy5bAuTa7sYfwE1sIZfEae7uqiADocAkwscyAim9LK4oT6yurV5eUoudfJqKZZIoVmZVZ8YNN)5bY8iyqKnnOkMfvajmpqJDWGWlJGRRqYPaNNhV5f3PvhJkMfvajmpqJDWGWlJGRRqYPaJqKZZIopFZZJ38bhLoV85zZwqwhICEw05LzEzbCjvohUK4CHhaXofeIwNJGMILT2GzRnxsy5bAuTa7sYfwE1ssbrxXMqStgPuuVKeW0qy6ljXDA1XOIEZjCDOgkgHiNNfDE5ZZ)8azEemiYMgufZIkGeMhOXoyq4LrW1vi5uGZZJ38I70QJrfZIkGeMhOXoyq4LrW1vi5uGriY5zrNNV55XB(GJsNx(8SzliRdropl68YmpZwsLZHljfeDfBcXozKsr9YwBWCRnxsy5bAuTa7sYfwE1ss5WTC3vDfk22jFqxKwOLKaMgctFjjUtRogv0BoHRd1qXie58SOZlFE(NhiZJGbr20GQywubKW8an2bdcVmcUUcjNcCEE8MxCNwDmQywubKW8an2bdcVmcUUcjNcmcropl688nppEZhCu68YNNnBbzDiY5zrNxM5LfWLu5C4ss5WTC3vDfk22jFqxKwOLT2yN1MljS8anQwGDjjGPHW0xs8pV4oT6yurV5eUoudfJqKZZIoppEZhqWYgvoCB3GErzpiNB5vrIM55BE5ZZ)8azEemiYMgufZIkGeMhOXoyq4LrW1vi5uGZZJ38I70QJrfZIkGeMhOXoyq4LrW1vi5uGriY5zrNNVLKlS8QLebf7PHC0LTSLTKiJqAE1AdzdRSagwMjByxsmCyLvlDjbuaGbQ2imTbZhap)8BccNp5AoOnp7bNpC)WofnIMWNhIGbrcr180JdN3jSJZnunVaKxTinoadaZcNNza88m9vKrOHQ5dhsui7bBXiqh(82nF4qIczpylgb6iwEGgvHpp)acq8fhGhGbkaWavBeM2G5dGNF(nbHZNCnh0MN9GZhUFypGasTWNhIGbrcr180JdN3jSJZnunVaKxTinoadaZcNhqaEEM(kYi0q18HdjkK9GTyeOdFE7MpCirHShSfJaDelpqJQWNNFabi(IdWdWafayGQnctBW8bWZp)MGW5tUMdAZZEW5d3GzTfnA4ZdrWGiHOAE6XHZ7e2X5gQMxaYRwKghGbGzHZdiapptFfzeAOA(WnxJLfb6WN3U5d3CnwweOJy5bAuf(88diaXxCaEagOaaduTryAdMpaE(53eeoFY1CqBE2doF4TyHWue(8qemisiQMNEC48oHDCUHQ5fG8QfPXbyayw48mdGNNPVImcnunF4qIczpylgb6WN3U5dhsui7bBXiqhXYd0Ok855hqaIV4a8amqbagOAJW0gmFa88ZVjiC(KR5G28ShC(WfhzS8YOHppebdIeIQ5PhhoVtyhNBOAEbiVArACagaMfopGa88m9vKrOHQ5d3CnwweOdFE7MpCZ1yzrGoILhOrv4ZZpGaeFXbyayw48mdGNNPVImcnunF4MRXYIaD4ZB38HBUgllc0rS8anQcFE(beG4loadaZcNNza88m9vKrOHQ5dNEe6GSurGo85TB(WPhHoilveOJy5bAuf(88diaXxCagaMfopZbWZZ0xrgHgQMpCZ1yzrGo85TB(WnxJLfb6iwEGgvHpp)acq8fhGbGzHZZCa88m9vKrOHQ5dNEe6GSurGo85TB(WPhHoilveOJy5bAuf(88diaXxCagaMfopacGNNPVImcnunF4MRXYIaD4ZB38HBUgllc0rS8anQcFE(beG4loapaduaGbQ2imTbZhap)8BccNp5AoOnp7bNpCXDA1XOOHppebdIeIQ5PhhoVtyhNBOAEbiVArACagaMfoVSa88m9vKrOHQ5d3CnwweOdFE7MpCZ1yzrGoILhOrv4ZZVSaeFXbyayw48aiaEEM(kYi0q18HBUgllc0HpVDZhU5ASSiqhXYd0Ok855hqaIV4a8amqbagOAJW0gmFa88ZVjiC(KR5G28ShC(WBXcHPO7hg(8qemisiQMNEC48oHDCUHQ5fG8QfPXbyayw48acWZZ0xrgHgQMpCZ1yzrGo85TB(WnxJLfb6iwEGgvHpp)acq8fhGbGzHZllapptFfzeAOA(WHefYEWwmc0HpVDZhoKOq2d2IrGoILhOrv4ZZpGaeFXb4byGcamq1gHPny(a45NFtq48jxZbT5zp48HRqwNqBHppebdIeIQ5PhhoVtyhNBOAEbiVArACagaMfopZa45z6RiJqdvZhU5ASSiqh(82nF4MRXYIaDelpqJQWN3T5bayQaW55hqaIV4amamlCEMdGNNPVImcnunF4MRXYIaD4ZB38HBUgllc0rS8anQcFE(beG4loadaZcNhabWZZ0xrgHgQMpCZ1yzrGo85TB(WnxJLfb6iwEGgvHpp)acq8fhGbGzHZdacWZZ0xrgHgQMpCZ1yzrGo85TB(WnxJLfb6iwEGgvHpp)acq8fhGbGzHZZ8dWZZ0xrgHgQMpCZ1yzrGo85TB(WnxJLfb6iwEGgvHpp)Ycq8fhGbGzHZZ8aGNNPVImcnunF4qIczpylgb6WN3U5dhsui7bBXiqhXYd0Ok855hqaIV4amamlCEabeGNNPVImcnunF4MRXYIaD4ZB38HBUgllc0rS8anQcFE(beG4loadaZcNhqaeapptFfzeAOA(WnxJLfb6WN3U5d3CnwweOJy5bAuf(88llaXxCagaMfopGm)a88m9vKrOHQ5d3CnwweOdFE7MpCZ1yzrGoILhOrv4ZZVSaeFXb4b4WexZbnunpGHDExy5vZRtQrJdWljNWaDWLKuYrODlVIPHoRTKAGhBQXLetyY8Gj6gO5dZvzliBEM3c0PdnaZeMmFywhkanVSac(8YgwzbCaEaMjmzEMgKxTifGhGzctMNPmpawfgjOghwgDE7MhmlWCxWeztnUlyIUbIopysGZB38xPdnV4ikBEZHTOrNNbOBEhIZJaudkmunVDZRtY486RANhRJOf082npNBgcNNF)WofnIM5zcG8fhGzctMNPmpyMupqJQ5LCbmztr665ddUWMpafobfNxHUA(wqhHMopNVfNN9GZtD18GzyoACaMjmzEMY8mV0SANhO4ik18snyPq48EqQtlr68CheNNvJaugOdnp)UnpZT)8uZfBPZNf1qxn)Xo)o7ZhZZZdMHbP5lKWGUEEVuZZ5HMVbIKXYMNEC481XuGOyEAAeULxrJdWmHjZZuMN5LMv78mpHudHz1oVKbZT48znpaMPcamFYoFOJyEqozC(6mqz1opQP482nV6M3l18mUkCB(JmcfEZ8moIsrNpPZdMHbP5lKWGUooaZeMmptzEMgKxTOAEoVcnF4SzliRdroplA4ZlUsLwELRPZB38EtJo08znFWrPZZMTGm68xPdnp)AKsNNPbZ5z4udN)Q5nOtbXxCaMjmzEMY8ayLcvZ71zGq48mvclaI(25XYGHM3U5POnprZ8udEvlcNhaOjvixkOXbyMWK5zkZVjtfmzQa88ZVbYyEdM1w0MxatdHPhhGhGDHLxrJnquCCbUTpPDBolVAa2fwEfn2arXXf42(K2f6jf7k0vdWmHjZdaq21eUH0595nywBrJoV4oT6yuGpVkjNkunFqO5zUDIZVjOKopdNoVa0rXAENoprb60HMNXb3sN)Q5zUDMNIIRuZhqaP28IqcnsbF(acBEqoDE7U558k08cfCEKLffgDE7MVnjJZ7ZlUtRogveGIkcOB5vZRsYj9GZNf1qxfNpmXoFAHtNNSRjW5b505RBEiY5zPq48q0iG18ac(8OMIZdrJawZh24oXbyMWK5DHLxrJnquCCbUTpPDj7W0d0i4LZHKmywBrRdyNgQeGFnKOOLSGt21eijabNSRjWoQPiPWg3bCXvQ0YRizWS2IweWiiN2jOypGGLvo)gmRTOfbmkUtRogvuraDlVcOgqnMBhsHLVbyMWK5DHLxrJnquCCbUTpPDj7W0d0i4LZHKmywBrRlBNgQeGFnKOOLSGt21eijabNSRjWoQPiPWg3bCXvQ0YRizWS2Iwu2iiN2jOypGGLvo)gmRTOfLnkUtRogvuraDlVcOgqnMBhsHLVbyMWK5baOwY5gsN3N3GzTfn68KDnboFqO5fhxJdZQDEdeoV4oT6yuZFSZBGW5nywBrd85vj5uHQ5dcnVbcNxraDlVA(JDEdeoFabl78PnFd8iNkKgNpmVtN3NNAqSAnqZZDQKnr482nFBsgN3Nhu2ccHZ3aZdMwO5TBEQbXQ1anVbZAlAuWN3PZZa165D68(8CNkzteop7bNpzN3N3GzTfT5zKA98hCEgPwpFD280qLyEgPbAEXDA1XOOXbyMWK5DHLxrJnquCCbUTpPDj7W0d0i4LZHKmywBrR3aZdMwiWVgsu0swWj7AcKKSGt21eyh1uKeGGlUsLwEfjGyWS2IweWiiN2jOypGGLvUbZAlArzJGCANGI9acwwE8mywBrlkBeKt7euShqWYkNF(nywBrlkBuCNwDmQOIa6wEfqndM1w0IYgBGNi6vOUQHgveq3YR4dOKFaJ7SVbZAlArzJGCApGGLLpGs(j7W0d0y0GzTfTUSDAOsWhF7Xp)gmRTOfbmkUtRogvuraDlVcOMbZAlAraJnWte9kux1qJkcOB5v8buYpGXD23GzTfTiGrqoThqWYYhqj)KDy6bAmAWS2IwhWonuj4JVb4b4byMWK5baaiuqyOAEKmcdnVLC48giCExyhC(KoVt2tThOX4aSlS8kkjUSuDwiIHzWbyMmFyaIKXYMN2GIKnr18gmRTOrNpaZQDEckQMNrAGM3jSJZTumVolKoa7clVIUpPDj7W0d0i4LZHKOnOiztu1nywBrdCYUMajXpcgeztdQIzrfqcZd0yhmi8Yi46kKCkq5I70QJrfZIkGeMhOXoyq4LrW1vi5uGri6Qq8naZeMmpqDhMEGgPdWUWYRO7tAxYom9ancE5CiPM70z12Hevk6nhdecozxtGKe3PvhJksj44UQ36W2lKgJqKZZIkZoYnxJLfPeCCx1BDy7fsJdWUWYRO7tAxYom9ancE5CiPM70z12HefsbNSRjqsMRXYI0Jq3HO3Gq5qIcLrw5MdBrlAjh2TR3iSoZ2rMDKZMTGSoe58SO7TZaSlS8k6(K2LSdtpqJGxohsIA9gTxvwTGt21eijxyjzSJfYLiLeGY5hiqpvDKmww0vkAebOKAuE8GEQ6izSSORu0yw7b4o8na7clVIUpPDj7W0d0i4LZHK48W4b7I70QJrr7UWsYi4KDnbsQbTyRdBVqAm6cljJ84fqWYgjkqNou3PuNqBrIgE8mxJLfDixO(X2nqyx5CfQK3Gw0BorVf0rOJUWsYipEbeSSrLd32nOxu2dY5wEvKOzaMjZhM1ZY8SYQDEG6jKqJLnFyq7Te48jDEF(gyEW0cna7clVIUpPDpclaI(wWtwsQZIKtiHglR3O9wcmcrwisb5bAuoqmxJLfjkqNoupqNTGm5ab6PQJKXYIUsrJiaLuJoa7clVIUpPDpclaI(wWtwsQZIKtiHglR3O9wcmcrwisb5bAuUlSKm2Xc5sKUhjzLZpqmxJLfjkqNoupqNTGmE8mxJLfjkqNoupqNTGm5I70QJrfjkqNoupqNTGSie58SO8na7clVIUpPDpclaI(wWtwsqIczpylgPeniKAqpl58RolYcpQ1zrYimcrwisb5bAKhp1zXa9DQEJ2BjWiezHifKhOr(gGzY8Hj25nqieN3H48mB)5nh2IgDEUKsZQDEG6HbWNNPsybq03oVDZtrJOz(a0meopaqtQqUuqJdWUWYRO7tA3JWcGOVfCDwyxOiTd4jljxyjzSJfYLiLP4cljJD1zrYjKqJL1B0ElbUNSdWUWYRO7tAxgEAGtrbjXDA1XOI0Jq3HO3GWie58SOGNSKmxJLfPhHUdrVbHYnh2Iw0soSBxVryDMTJm7iNnBbzDiY5zr3Bh5I70QJrfPhHUdrVbHriY5zrLH)wHcOmSraWD4tUlSKm2Xc5sKscWbyMmpawy5vZdatQrN3l18m1gSqiDE(zQnyHq6UsiyqGLaPZtuuIMMdAOA(SM3vQRI8na7clVIUpPDfUw3DHLx11j1aVCoKKbZAlA0byxy5v09jTRW16UlS8QUoPg4LZHKehzS8YOdWUWYRO7tAxHR1Dxy5vDDsnWlNdjbDr6A6amtM3fwEfDFs7srWGalbcEYsYfwsg7yHCjsjbOCGOq3a13wzlilQsQhOXUFMc8Y5qsxdwieGDixO(X2nqyxHUcGzrQHWSA7udMBraMfPgcZQTtnyUfbyIc0Pd1d0zlidGBolVcGvoCB3GErzpiNB5vaS3CcxhQHIdWUWYRO7tAxHR1Dxy5vDDsnWlNdjjUtRogfDa2fwEfDFs7cjQUlS8QUoPg4LZHK8d7u0iAapzj5cljJDSqUeP7rsw58lUtRogvuHUbQ7LQRqHhkcroplQmagw5aXCnwwuHSPg5XtCNwDmQOcztngHiNNfvgadRCZ1yzrfYMAKp5arHUbQ7LQRqHhkAPyBwTdWUWYRO7tAxir1DHLx11j1aVCoKKFypGasnWPgmfgjabpzj5cljJDSqUeP7rsw5k0nqDVuDfk8qrlfBZQDa2fwEfDFs7cjQUlS8QUoPg4LZHKAXcHPO7hcEYsYfwsg7yHCjs3JKSY5hik0nqDVuDfk8qrlfBZQvo)I70QJrfvOBG6EP6ku4HIqKZZIUhGHvoqmxJLfviBQrE8e3PvhJkQq2uJriY5zr3dWWk3CnwwuHSPg5JVbyxy5v09jTRW16UlS8QUoPg4LZHKAXcHPaCQbtHrcqWtwsUWsYyhlKlrkjahGhGzctMhaFaaZdwci1gGDHLxrJ(H9aci1iPq3a1fxQbpzjXFablBKsOuy1v3XfHOlmE8aczhMEGgJn3PZQTdjQu0BogiKp58hqWYgvoCB3GErzpiNB5vrIg5qIczpylgvOR0jsTU4sTCxyjzSJfYLivgsmJhpxyjzSJfYLiLKS8na7clVIg9d7beqQTpPDXMuHCPa8KLeKOsrV5yGWOcztrAYWpGHDFf6gO(2kBbzrwghrPqv3CylAuGsMXNCf6gO(2kBbzrwghrPqv3CylAuzaqYbczhMEGgJn3PZQTdjQu0BogiKhVacw2iLHd5YQTZLuls0ma7clVIg9d7beqQTpPDXMuHCPa8KLeKOsrV5yGWOcztrAYi7oYvOBG6BRSfKfzzCeLcvDZHTOr3Bh5aHSdtpqJXM70z12Hevk6nhdeoa7clVIg9d7beqQTpPDXMuHCPa8KLequOBG6BRSfKfzzCeLcvDZHTOrLdeYom9angBUtNvBhsuPO3CmqipESzliRdroplQm7WJh0tvhjJLfDLIgrakPgvo0tvhjJLfDLIgHiNNfvMDgGDHLxrJ(H9aci12N0UmoIs1PnyPq4aSlS8kA0pShqaP2(K2fBsfYLcWtwsaHSdtpqJXM70z12Hevk6nhdeoapaZeMmpa(aaMxcnIMbyxy5v0OFyNIgrdjVc1vLc8KLKcDduFBLTGSilJJOuOQBoSfn6EKeHeASJfYLiLhpONQosgll6kfnIausnQCONQosgll6kfncroplQmKaeWbyxy5v0OFyNIgrZ(K21RqDvPapzjPq3a13wzlilYY4ikfQ6MdBrJUhPDgGDHLxrJ(HDkAen7tAxf6gOU4sn4jljGq2HPhOXyZD6SA7qIkf9MJbcLZFablBu5WTDd6fL9GCULxfjAKdjkK9GTyuHUsNi16Il1YDHLKXowixIuziXmE8CHLKXowixIusYY3aSlS8kA0pStrJOzFs7InPc5sb4jljGq2HPhOXyZD6SA7qIkf9MJbchGDHLxrJ(HDkAen7tAxwKAimR2o1G5weCriHg7MdBrJscqWtwskmGGLnYIudHz12zCeLksnxSvgsmtU4oT6yurV5eUoudfJqKZZIkdZgGDHLxrJ(HDkAen7tAxwKAimR2o1G5weCriHg7MdBrJscqWtwskmGGLnYIudHz12zCeLksnxSvgahGDHLxrJ(HDkAen7tAxwKAimR2o1G5weCriHg7MdBrJscqWtwskmGGLnYIudHz12zCeLksnxSvgsmtoKOWOLCy3UoZjJ4oT6yurVc1vLkcropl6amtMhOaewZBoSfT5Pm8g68oeNxLupqJkWN3aL05zKA98A0Mp0rmpTbl18qIcP7Y4ikfD(SOg6Q5p25z4PLv78ShCEWSaZDbtKn14UGj6gOWPZdMeyCa2fwEfn6h2POr0SpPDzCeLQtBWsHqWtws8dekAwwT0OiKqJ84Pq3a13wzlilYY4ikfQ6MdBrJUhjriHg7yHCjs5tUcdiyzJSi1qywTDghrPIuZfB3JzYHefgTKd721zMmI70QJrf9kuxvQie58SOdWdWmHjZhgolVAa2fwEfnkUtRogfLuZz5vGNSKi7W0d0yKZdJhSlUtRogfT7cljJ84fCuQC2SfK1HiNNfvgzbqdWmHjZZ03PvhJIoa7clVIgf3PvhJIUpPDDixO(X2nqyxHUc8KLK4oT6yurIc0Pd1d0zlilcroplQm7ixCNwDmQOYHB7g0lk7b5ClVkcroplAhbOguyOsMDKBUgllsuGoDOEGoBbz84beZ1yzrIc0Pd1d0zliJhVGJsLZMTGSoe58SOYWSDgGDHLxrJI70QJrr3N0U0Jq3HO3GqWfHeASBoSfnkjabpzjzoSfTOLCy3UEJW6mBhz2rU5Ww0IwYHD76Qe3Bh5UWsYyhlKlrQmKy2amtMpm)Pv05bRoBbzZZEW5jAM3U53zEkkUsrN3U5PHkX8msd08a4Mt46qnue85zQgieYiPi4ZtqX5zKgO5bthUD(nHErzpiNB5vXbyxy5v0O4oT6yu09jTlrb60H6b6SfKbEYsISdtpqJrQ1B0Evz1kNFXDA1XOIEZjCDOgkgHiNNfTJaudkmujZo84jUtRogv0BoHRd1qXie58SODeGAqHHQ9amS8jNFXDA1XOIkhUTBqVOShKZT8Qie58SOY0ku84fqWYgvoCB3GErzpiNB5vrIg(gGDHLxrJI70QJrr3N0UefOthQhOZwqg4jljxyjzSJfYLiDpsYYJxWrPYzZwqwhICEwuzKfWbyxy5v0O4oT6yu09jTRYHB7g0lk7b5ClVc8KLezhMEGgJuR3O9QYQvo)QZIefOthQhOZwqwxDweICEwuE8aI5ASSirb60H6b6SfKX3aSlS8kAuCNwDmk6(K2v5WTDd6fL9GCULxbEYsYfwsg7yHCjs3JKS84fCuQC2SfK1HiNNfvgzbCa2fwEfnkUtRogfDFs76nNW1HAOi4jljxyjzSJfYLiLeGYvyablBKfPgcZQTZ4ikvKAUy7EmBa2fwEfnkUtRogfDFs76nNW1HAOi4Iqcn2nh2IgLeGGNSKCHLKXowixI09ijRCfgqWYgzrQHWSA7moIsfPMl2UhZKdef6gOUxQUcfEOOLITz1oa7clVIgf3PvhJIUpPDPeCCx1BDy7fsJGNSKGevk6nhdegviBkstgazo58lUtRogvKOaD6q9aD2cYIqKZZIkdGHLhp1zrIc0Pd1d0zliRRolcroplkFdWUWYROrXDA1XOO7tAxIc0Pd1Dk1j0g4jljYom9angPwVr7vLvRCfgqWYgzrQHWSA7moIsfPMl2kJSY5VbTO3CIElOJqhDHLKrE8ciyzJkhUTBqVOShKZT8QirJCG0Gw0HCH6TGocD0fwsg5Ba2fwEfnkUtRogfDFs7suGoDOUtPoH2axesOXU5Ww0OKae8KLKlSKm2Xc5sKUhjzLRWacw2ilsneMvBNXruQi1CXwzKDa2fwEfnkUtRogfDFs7c9KIDf6kWtwsaPbTylOJqhDHLKXbyMWK5bZK6bAub(8HrcQnFD28q016qZxhKZ1ZhGGCY5bN3a5w405zCqd08neqkrwTZNftP15W4amtyY8UWYROrXDA1XOO7tAxQlGjBksx3BCHbEYsYfwsg7yHCjs3JKSYbsablBu5WTDd6fL9GCULxfjAKdeXDA1XOIkhUTBqVOShKZT8QieDviE8cokvoB2cY6qKZZIktRqnapaZeMmptFKXYlBEaCqQtlr6aSlS8kAuCKXYlJsIYWHCz125sQbEYsISdtpqJrQ1B0Evz1khsuPO3CmqyuHSPiT9aeajNFXDA1XOIEZjCDOgkgHiNNfLhpGyUgll6qUq9JTBGWUY5kujxCNwDmQOYHB7g0lk7b5ClVkcroplkF84fCuQC2SfK1HiNNfvgabCaMjZlH282npbfN3zneoV3CI5t68xnptdMZ705TB(gisglB(JmcfEttwTZdufgMNbOuJZtrZYQDEIM5zAWmC6aSlS8kAuCKXYlJUpPDPmCixwTDUKAGNSKe3PvhJk6nNW1HAOyeICEwu587cljJDSqUeP7rsw5UWsYyhlKlrQmK2roKOsrV5yGWOcztrA7byy3NFxyjzSJfYLifOeaXhpEUWsYyhlKlr6E7ihsuPO3CmqyuHSPiT9yUWY3aSlS8kAuCKXYlJUpPD9GJll3YR66Kla8KLezhMEGgJuR3O9QYQvoqOhHoilvuJUQheQJaKZ1Or58lUtRogv0BoHRd1qXie58SO84beZ1yzrhYfQFSDde2voxHk5I70QJrfvoCB3GErzpiNB5vriY5zr5toKOWOLCy3UoZTh)mB)acw2iKOsrxCqirJLxfHiNNfLpE8cokvoB2cY6qKZZIkJSaoa7clVIgfhzS8YO7tAxp44YYT8QUo5capzjr2HPhOXi16nAVQSALtpcDqwQOgDvpiuhbiNRrJY5xDwKOaD6q9aD2cY6QZIqKZZIUhGaYJhqmxJLfjkqNoupqNTGm5I70QJrfvoCB3GErzpiNB5vriY5zr5Ba2fwEfnkoYy5Lr3N0UEWXLLB5vDDYfaEYsYfwsg7yHCjs3JKSYHefgTKd721zU94Nz7hqWYgHevk6IdcjAS8Qie58SO8na7clVIgfhzS8YO7tAxkixSvJDde2jkgh0afc8KLezhMEGgJuR3O9QYQvo)I70QJrf9Mt46qnumcroplkpEaXCnww0HCH6hB3aHDLZvOsU4oT6yurLd32nOxu2dY5wEveICEwu(4Xl4Ou5SzliRdroplQmaUZaSlS8kAuCKXYlJUpPDPGCXwn2nqyNOyCqduiWtwsUWsYyhlKlr6EKKvo)k0nqDVuDfk8qrlfBZQLhpONQosgll6kfncroplQmKaK54BaEaMjmzEPSA148B6Ww0gGDHLxrJTyHWuqsHUbQlUudEYskGGLnsjukS6Q74Iq0fMCGq2HPhOXyZD6SA7qIkf9MJbc5XRbTyRdBVqAm6cljJdWUWYROXwSqyk2N0Uk0nqDXLAWtwsqIkf9MJbcJkKnfPjdGmJhp2SfK1HiNNfvMDKdefgqWYgzrQHWSA7moIsfjAgGDHLxrJTyHWuSpPD9kuxvkWtwsI70QJrf9Mt46qnumcroplQC(nxJLfviBQXiwEGgv84joYy5LfRSfK1zDKhpirHShSfJnGqhECxHu(KZpqi7W0d0yS5oDwTDirHuE8yZwqwhICEwuz2HVbyxy5v0ylwimf7tAxghrP60gSuie8KLKcdiyzJSi1qywTDghrPIuZfB3JzYbczhMEGgJn3PZQTdjkKoa7clVIgBXcHPyFs7Y4ikvN2GLcHGNSKuyablBKfPgcZQTZ4ikvKOrU4oT6yurV5eUoudfJqKZZI2raQbfgQ2Bh5aHSdtpqJXM70z12HefshGDHLxrJTyHWuSpPDvOBG6Il1GNSKGevk6nhdegviBkstgzdRCGq2HPhOXyZD6SA7qIkf9MJbchGDHLxrJTyHWuSpPDzrQHWSA7udMBrWtwskmGGLnYIudHz12zCeLksnxSvgaLdeYom9angBUtNvBhsuiDa2fwEfn2IfctX(K2LfPgcZQTtnyUfbpzjPWacw2ilsneMvBNXruQi1CXwzyo5I70QJrf9Mt46qnumcroplAhbOguyOsMDKdeYom9angBUtNvBhsuiDa2fwEfn2IfctX(K2vHUbQlUudEYsciKDy6bAm2CNoR2oKOsrV5yGWb4byMWK5z(WcHPyEa8bamFyaMhmTqdWUWYROXwSqyk6(HKy4PboffKe3PvhJkspcDhIEdcJqKZZIcEYsYCnwwKEe6oe9gek3CylArl5WUD9gH1z2oYSJC2SfK1HiNNfDVDKlUtRogvKEe6oe9gegHiNNfvg(BfkGYWgba3Hp5UWsYyhlKlrQmKy2aSlS8kASfleMIUF4(K2vHUbQlUudEYsIFGq2HPhOXyZD6SA7qIkf9MJbc5XlGGLnsjukS6Q74Iq0fgFY5pGGLnQC42Ub9IYEqo3YRIenYHefYEWwmQqxPtKADXLA5UWsYyhlKlrQmKygpEUWsYyhlKlrkjz5Ba2fwEfn2Ifctr3pCFs7InPc5sb4jlPacw2iLqPWQRUJlcrxy84beYom9angBUtNvBhsuPO3Cmq4amtMpmXoV5Ww0MxesOZQD(KoVkPEGgvGppLrAcqZh4ITZB38giCEAwTAKPyoSfT5BXcHPyEDsT5ZIAORIdWUWYROXwSqyk6(H7tAxir1DHLx11j1aVCoKulwimfGtnykmsacEYssesOXowixIusaoa7clVIgBXcHPO7hUpPDzCeLQtBWsHqWfHeASBoSfnkjabpzjXV4oT6yurV5eUoudfJqKZZIU3oYvyablBKfPgcZQTZ4ikvKOHhpfgqWYgzrQHWSA7moIsfPMl2UhZ4to)SzliRdroplQmI70QJrfvOBG6EP6ku4HIqKZZIUpGHLhp2SfK1HiNNfDpXDA1XOIEZjCDOgkgHiNNfLVbyxy5v0ylwimfD)W9jTllsneMvBNAWClcUiKqJDZHTOrjbi4jljfgqWYgzrQHWSA7moIsfPMl2kdjMjxCNwDmQO3CcxhQHIriY5zrLHz84PWacw2ilsneMvBNXruQi1CXwzaCa2fwEfn2Ifctr3pCFs7YIudHz12Pgm3IGlcj0y3CylAusacEYssCNwDmQO3CcxhQHIriY5zr3Bh5kmGGLnYIudHz12zCeLksnxSvgahGzY8BckPZN05rwwuyjzuhAE2uRr48maLcqZtto68GzyqA(cjmORbF(acBEkOJqRMVbIKXYM3NNkWYH5npdqieN3aHZ7k1vZdYPZxNbkR25TBEikoooSuXbyxy5v0ylwimfD)W9jTllsneMvBNAWClcEYsYfwsg7QZISi1qywTDghrP2JKiKqJDSqUePYvyablBKfPgcZQTZ4ikvKAUyRmm3a8amtMhOYfPRPdWUWYROrOlsxtj5qHxy3oield8KLeKOsrV5yGWOcztrA7bG2ro)nOfBDy7fsJrxyjzKhpGyUgllsj44UQ36W2lKgJy5bAuXNCirHrfYMI02J0odWUWYROrOlsxt3N0Ub67uDwcyiWtwsKDy6bAmY5HXd2f3PvhJI2DHLKrE8mh2Iw0soSBxxLOmKciyzJb67uDwcyOOIa6wE1aSlS8kAe6I0109jTBacPiCBwTGNSKi7W0d0yKZdJhSlUtRogfT7cljJ84zoSfTOLCy3UUkrzifqWYgdqifHBZQnQiGULxna7clVIgHUiDnDFs7QZwqgThgjuTCyzGNSKciyzJefOthQtniwTgOirZamtMhaxcKAqxppt7A98cVM3GzBlcNN5MV5mSS01ZhqWYsbFE0fGMx7ulR25bCN5PO4kfnopZRL6mmdQMhKdvZlofQM3soCENoVpVbZ2weoVDZVfXM5tBEi6kpqJXbyxy5v0i0fPRP7tAxVei1GUUlCTg8KLezhMEGgJCEy8GDXDA1XOODxyjzKhpZHTOfTKd721vjkdja3za2fwEfncDr6A6(K21HcVWEdHMIGNSKCHLKXowixI09ijlpE8djkmQq2uK2EK2roKOsrV5yGWOcztrA7rcafw(gGDHLxrJqxKUMUpPDztigOVtbEYsISdtpqJropmEWU4oT6yu0UlSKmYJN5Ww0IwYHD76QeLHuablBKnHyG(ovuraDlVAa2fwEfncDr6A6(K2nWB7hB3GPylf8KLuablBKOaD6qDQbXQ1afjAK7cljJDSqUePKaCaEaMjmz(nHzTfn6aSlS8kA0GzTfnkjck2td5aVCoKuwubKW8an2bdcVmcUUcjNce8KLe)I70QJrfjkqNoupqNTGSie58SO84jUtRogvu5WTDd6fL9GCULxfHiNNfLp583Gw0HCH6TGocD0fwsg5XRbTO3CIElOJqhDHLKr5aXCnww0HCH6hB3aHDLZvOIhpZHTOfTKd721Bewx2WkZo8XJxWrPYzZwqwhICEwuzKfWbyxy5v0ObZAlA09jTlbf7PHCGxohsIZfEae7uqiADocAkapzjjUtRogv0BoHRd1qXie58SOYSJC(bccgeztdQIzrfqcZd0yhmi8Yi46kKCkqE8e3PvhJkMfvajmpqJDWGWlJGRRqYPaJqKZZIYhpEbhLkNnBbzDiY5zrLrwahGDHLxrJgmRTOr3N0UeuSNgYbE5CijfeDfBcXozKsrn4jljXDA1XOIEZjCDOgkgHiNNfvo)abbdISPbvXSOciH5bASdgeEzeCDfsofipEI70QJrfZIkGeMhOXoyq4LrW1vi5uGriY5zr5JhVGJsLZMTGSoe58SOYWSbyxy5v0ObZAlA09jTlbf7PHCGxohss5WTC3vDfk22jFqxKwiWtwsI70QJrf9Mt46qnumcroplQC(bccgeztdQIzrfqcZd0yhmi8Yi46kKCkqE8e3PvhJkMfvajmpqJDWGWlJGRRqYPaJqKZZIYhpEbhLkNnBbzDiY5zrLrwahGDHLxrJgmRTOr3N0UeuSNgYrbpzjXV4oT6yurV5eUoudfJqKZZIYJxablBu5WTDd6fL9GCULxfjA4to)abbdISPbvXSOciH5bASdgeEzeCDfsofipEI70QJrfZIkGeMhOXoyq4LrW1vi5uGriY5zr5BaMjmz(nzQGjtfGhGzctMFtq48gmRTOnpJ0anVbcNhu2ccP28i1so3q18KDnbc(8msTE(aCEckQMNnHuBEVuZ34jevZZinqZdGBoHRd1qX55pzNpGGLD(KopG7mpffxPOZFW51iLY38hCEWQZwq2UG5MZZFYoFleDdHZBG8AEa3zEkkUsr5BaMjmzExy5v0ObZAlA09jTlbf7PHCGt1NrYGzTfnabpzjbeYom9angPnOiztu1nywBrto)8BWS2IweWyd8erVc1vn0OIa6wELmKaCh5I70QJrf9Mt46qnumcropl6EYgwE8mywBrlcySbEIOxH6QgAuraDlVApa3ro)I70QJrfjkqNoupqNTGSie58SO7jBy5XtCNwDmQOYHB7g0lk7b5ClVkcropl6EYgw(4to)aXGzTfTOSrqoTlUtRogfpEgmRTOfLnkUtRogveICEwuE8i7W0d0y0GzTfTEdmpyAHibiF8XJNbZAlAraJnWte9kux1qJkcOB5v7rInBbzDiY5zrhGzctM3fwEfnAWS2IgDFs7sqXEAih4u9zKmywBrtwWtwsaHSdtpqJrAdks2evDdM1w0KZp)gmRTOfLn2apr0RqDvdnQiGULxjdja3rU4oT6yurV5eUoudfJqKZZIUNSHLhpdM1w0IYgBGNi6vOUQHgveq3YR2dWDKZV4oT6yurIc0Pd1d0zlilcropl6EYgwE8e3PvhJkQC42Ub9IYEqo3YRIqKZZIUNSHLp(KZpqmywBrlcyeKt7I70QJrXJNbZAlAraJI70QJrfHiNNfLhpYom9angnywBrR3aZdMwisYYhF84zWS2Iwu2yd8erVc1vn0OIa6wE1EKyZwqwhICEw0byMWK5dtSZFLo08xHZF18euCEdM1w0MVbEKtfsN3NpGGLf85jO48giC(ZaHW5VAEXDA1XOIZZuHZNSZxyAGq48gmRTOnFd8iNkKoVpFabll4ZtqX5dod08xnV4oT6yuXbyMWK5DHLxrJgmRTOr3N0UeuSNgYbovFgjdM1w0ae8KLeqmywBrlcyeKt7euShqWYkNFdM1w0IYgf3PvhJkcroplkpEaXGzTfTOSrqoTtqXEabllFdWmHjZ7clVIgnywBrJUpPDjOypnKdCQ(msgmRTOjl4jljGyWS2Iwu2iiN2jOypGGLvo)gmRTOfbmkUtRogveICEwuE8aIbZAlAraJGCANGI9acww(w2Ywla]] )

end
