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


    spec:RegisterPack( "Unholy", 20210311.1, [[daLw6bqifvEeIOlbGQSjQkFsryuOsofQOvHkiELIQMfI0TqeQSlQ8lffdtrjhdGwgrvpJOIPHkKRPiABaO8nubLXPOu4CaOQSoGeVdavvZdvQ7bu7daoiIqwiqQhIkuterWfjQK8rubPrQOuKtsuPALaXlrfu1mvuQUjQGk7KQk)KOszOicLLcGkpLitLQQUkrLuBvrPO(QIsPXcK0Ev4VsAWQ6Wuwmv5XeMmjxgAZO4Zs0Ob0PfTAIkXRvKMnPUnQA3s9BvgUeooQalh0ZrA6cxhHTJs9De14bqoprz9icvnFuY(v6bGd)hsklWHFYpl5bCwYbqaDao5KCyZA2yifYkWHuHjMAL4qQnECijx3apTSHuHjtFMA4)qIEeqboKagrbfuMzMYmas45eh)m0KNqBrETaAmXm0KxmZqYJi1HCVhEdjLf4Wp5NL8aol5aiGdjAbkg(j)KYpKaMkf2dVHKcPIHejGwaCFo8Dwcm2xUUbEAzliC4mOa4(aciP7l)SKhWfKfesKsUqqdESd6(XTpj0KWmKaYKACgsaTaiDFsGa3pU9VwlBFXr0X(HblXGUpzG3(ge3hbOcueOA)42xNSX91xxUp2hrjW9JBFElceUpx2Hvkgef7tsa50TGqcj180OAFjtatMuKMEFsmte77HcJGI7RqtTFjWJqt3N3MI7ZCW9PMAFsGdp1TGixtZUC)z7r0Q9LkWwHW9nVuNrI095piUpJgbO0tlBFUSyFoA(9PHjMs3pBAGMA)Jz)jNNta(3NeiXK2VrIaA69TwTpVjB)ciYg7yF6XJ73hjoik2NMbHf51u3cchd06suTpV1Y2FcMSeyuHiVLnDI9fxRYiV2009JBFROqlB)S337O09zYsGbD)R1Y2NlnsP7ZXKW(KnAG7F9(b0Oa50TG4VCJeKBGY(77hsE)aM9um2xaZaHP5gs6Kg0H)dj7WkfdIIH)d)aC4)qcBZtJQbOhscygimTHKcTayDANLadhd5JOvOQggSed6(aa8(czcnwXg5tKUplw7dTuvr2yhotPOoeGsAq333(qlvvKn2HZukQdI8w2095g8(ac4qYerE9qYAzvvRgXWp5h(pKW280OAa6HKaMbctBiPqlawN2zjWWXq(iAfQQHblXGUpaaV)Kdjte51djRLvvTAed)KZW)He2MNgvdqpKeWmqyAdP52NTbtZtJUI70zxwHeDkQfhzeUVV95AFpcggNYGtRb0AkZb5TiV2ruSVV9HenYCWs0PqtPtKgvXLAh2MNgv77BFtejBSInYNiDFUbVVC2NfR9nrKSXk2iFI09bVV87Z5qYerE9qsHwaSkUupIHFC0W)He2MNgvdqpKeWmqyAdP52NTbtZtJUI70zxwHeDkQfhzeoKmrKxpKWIuH8Pyed)MC4)qcBZtJQbOhsMiYRhsminqy2LvAaZP4qsaZaHPnKuOhbdJJbPbcZUSs(iALJgMy6(CdEF5SVV9f3Pvh52zfNW0YkOOdI8w2095EF5mKeYeASggSed6WpahXWpa2W)He2MNgvdqpKmrKxpKyqAGWSlR0aMtXHKaMbctBiPqpcgghdsdeMDzL8r0khnmX095EFahsczcnwddwIbD4hGJy4hh2W)He2MNgvdqpKmrKxpKyqAGWSlR0aMtXHKaMbctBiPqpcgghdsdeMDzL8r0khnmX095g8(YzFF7djA0fjpwJRYr7Z9(I70QJC7Swwv1khe5TSPdjHmHgRHblXGo8dWrm8B2y4)qcBZtJQbOhskKkGzrKxpKMTaXE)WGLySpLSvq33G4(QKAEAur6(bWKUp5uR3xJX(YoI9PfyR2hs0iDgYhrRO7NnnqtT)XSpzlJSl3N5G7tcnjmdjGmPgNHeqlaobDFsGaDdjbmdeM2qIR9NBFkgr2LuNqMqJ7ZI1(k0cG1PDwcmCmKpIwHQAyWsmO7daW7lKj0yfBKpr6(CUVV9vOhbdJJbPbcZUSs(iALJgMy6(ayF5SVV9Hen6IKhRXvLZ(CVV4oT6i3oRLvvTYbrElB6qYerE9qI8r0QkTaBfchXigs2Hvpcing(p8dWH)djSnpnQgGEijGzGW0gsCTVhbdJJsOuyxv3X7GOjI9zXA)52NTbtZtJUI70zxwHeDkQfhzeUpN77BFU23JGHXPm40AaTMYCqElYRDef77BFirJmhSeDk0u6ePrvCP2HT5Pr1((23erYgRyJ8js3NBW7lN9zXAFtejBSInYNiDFW7l)(CoKmrKxpKuOfaRIl1Jy4N8d)hsyBEAuna9qsaZaHPnKGeDkQfhze6uitkYyFU3NR9bCw7p)(k0cG1PDwcmCmKpIwHQAyWsmO7ZHSVC2NZ99TVcTayDANLadhd5JOvOQggSed6(CVpaBFF7p3(SnyAEA0vCNo7YkKOtrT4iJW9zXAFpcgghLSb5ZUSYN0WrumKmrKxpKWIuH8Pyed)KZW)He2MNgvdqpKeWmqyAdjirNIAXrgHofYKIm2N79LFY99TVcTayDANLadhd5JOvOQggSed6(ay)j333(ZTpBdMMNgDf3PZUScj6uuloYiCizIiVEiHfPc5tXig(Xrd)hsyBEAuna9qsaZaHPnKMBFfAbW60olbgogYhrRqvnmyjg099T)C7Z2GP5PrxXD6SlRqIof1IJmc3NfR9zYsGrfI8w2095E)j3NfR9HwQQiBSdNPuuhcqjnO77BFOLQkYg7Wzkf1brElB6(CV)Kdjte51djSiviFkgXWVjh(pKmrKxpKiFeTQslWwHWHe2MNgvdqpIHFaSH)djSnpnQgGEijGzGW0gsZTpBdMMNgDf3PZUScj6uuloYiCizIiVEiHfPc5tXigXqkGzpfd6W)HFao8FiHT5Pr1a0djbmdeM2qIR9f3Pvh52r0apTSQNolbgoiYBzt3NfR9f3Pvh52Pm40AaTMYCqElYRDqK3YMUpN77BFU2VadNb5LvlbEeANjIKnUplw7xGHZkorTe4rODMis24((2FU9dtJD4miVS6XudGyvz8nQCyBEAuTplw7hgSedxK8ynUAHiQYpR95E)j3NZ9zXAFVJs333(mzjWOcrElB6(CVV8aoKAJhhsztfqIW80yLdiSoi4RkKDkWHKjI86Hu2ubKimpnw5acRdc(QczNcCed)KF4)qcBZtJQbOhscygimTHK4oT6i3oR4eMwwbfDqK3YMUp37p5((2NR9NBFKdiYIcu5YMkGeH5PXkhqyDqWxvi7uG7ZI1(I70QJC7YMkGeH5PXkhqyDqWxvi7uGoiYBzt3NZ9zXAFVJs333(mzjWOcrElB6(CVV8aoKAJhhs8MW8GyLceXOYtqtXqYerE9qI3eMheRuGigvEcAkgXWp5m8FiHT5Pr1a0djbmdeM2qsCNwDKBNvCctlRGIoiYBzt333(CT)C7JCarwuGkx2ubKimpnw5acRdc(QczNcCFwS2xCNwDKBx2ubKimpnw5acRdc(QczNc0brElB6(CUplw77Du6((2NjlbgviYBzt3N79LZqQnECiPGOPysiwzJukQhsMiYRhskiAkMeIv2iLI6rm8JJg(pKW280OAa6HKaMbctBijUtRoYTZkoHPLvqrhe5TSP77BFU2FU9roGilkqLlBQaseMNgRCaH1bbFvHStbUplw7lUtRoYTlBQaseMNgRCaH1bbFvHStb6GiVLnDFo3NfR99okDFF7ZKLaJke5TSP7Z9(Yd4qQnECiPm4u(76QcftRSpOjYq2qYerE9qszWP831vfkMwzFqtKHSrm8BYH)djSnpnQgGEijGzGW0gsCTV4oT6i3oR4eMwwbfDqK3YMUplw77rWW4ugCAnGwtzoiVf51oII95CFF7Z1(ZTpYbezrbQCztfqIW80yLdiSoi4RkKDkW9zXAFXDA1rUDztfqIW80yLdiSoi4RkKDkqhe5TSP7Z5qYerE9qIGI1mqE6igXqQeBeMIH)d)aC4)qcBZtJQbOhscygimTHKhbdJJsOuyxv3X7GOjI99T)C7Z2GP5PrxXD6SlRqIof1IJmc3NfR9lWWvAWYtMgDMis24qYerE9qsHwaSkUupIHFYp8FiHT5Pr1a0djbmdeM2qcs0POwCKrOtHmPiJ95EFaLZ(SyTptwcmQqK3YMUp37p5((2FU9vOhbdJJbPbcZUSs(iALJOyizIiVEiPqlawfxQhXWp5m8FiHT5Pr1a0djbmdeM2qsCNwDKBNvCctlRGIoiYBzt333(CTFyASdNczsn6W280OAFwS2xCSX26W1zjWOYy4(SyTpKOrMdwIUcGObp(RrQdBZtJQ95CFF7Z1(ZTpBdMMNgDf3PZUScjAKUplw7ZKLaJke5TSP7Z9(tUpNdjte51djRLvvTAed)4OH)djSnpnQgGEijGzGW0gsk0JGHXXG0aHzxwjFeTYrdtmDFaSVC233(ZTpBdMMNgDf3PZUScjAKoKmrKxpKiFeTQslWwHWrm8BYH)djSnpnQgGEijGzGW0gsk0JGHXXG0aHzxwjFeTYruSVV9f3Pvh52zfNW0YkOOdI8w20kcqfOiq1(ay)j333(ZTpBdMMNgDf3PZUScjAKoKmrKxpKiFeTQslWwHWrm8dGn8FiHT5Pr1a0djbmdeM2qcs0POwCKrOtHmPiJ95EF5N1((2FU9zBW080OR4oD2LvirNIAXrgHdjte51djfAbWQ4s9ig(XHn8FiHT5Pr1a0djbmdeM2qsHEemmogKgim7Yk5JOvoAyIP7Z9(aUVV9NBF2gmnpn6kUtNDzfs0iDizIiVEiXG0aHzxwPbmNIJy43SXW)He2MNgvdqpKeWmqyAdjf6rWW4yqAGWSlRKpIw5OHjMUp37Zr77BFXDA1rUDwXjmTSck6GiVLnTIaubkcuTp37p5((2FU9zBW080OR4oD2LvirJ0HKjI86HedsdeMDzLgWCkoIHFa8n8FiHT5Pr1a0djbmdeM2qAU9zBW080OR4oD2LvirNIAXrgHdjte51djfAbWQ4s9igXqsCSX26Go8F4hGd)hsyBEAuna9qsaZaHPnKyBW080OJg1cT1D2L77BFirNIAXrgHofYKIm2ha7diaBFF7Z1(I70QJC7SItyAzfu0brElB6(SyT)C7hMg7WzqEz1JPgaXQY4Bu5W280OAFF7lUtRoYTtzWP1aAnL5G8wKx7GiVLnDFo3NfR99okDFF7ZKLaJke5TSP7Z9(ac4qYerE9qIs2G8zxw5tAmIHFYp8FiHT5Pr1a0djfsfWSiYRhssySFC7tqX9nMaH7BfNy)KU)17ZXKW(gD)42VaISXo2)yJqHvuKD5(aCKy7tgyQX9PyezxUprX(CmjmbDijGzGW0gsI70QJC7SItyAzfu0brElB6((2NR9nrKSXk2iFI09ba49LFFF7BIizJvSr(eP7Zn49NCFF7dj6uuloYi0PqMuKX(ayFaN1(ZVpx7BIizJvSr(eP7ZHSpaBFo3NfR9nrKSXk2iFI09bW(tUVV9HeDkQfhze6uitkYyFaSphnR95CizIiVEirjBq(SlR8jngXWp5m8FiHT5Pr1a0djbmdeM2qITbtZtJoAul0w3zxUVV9NBF6rO9Yw50OPQEYQiaz8fA0HT5Pr1((2NR9f3Pvh52zfNW0YkOOdI8w209zXA)52pmn2HZG8YQhtnaIvLX3OYHT5Pr1((2xCNwDKBNYGtRb0AkZb5TiV2brElB6(CUVV9Hen6IKhRXv5O9bW(CTVC2F(99iyyCqIofvXbHefrETdI8w2095CFwS237O099TptwcmQqK3YMUp37lpGdjte51djZ74Z2I86Qo59gXWpoA4)qcBZtJQbOhscygimTHeBdMMNgD0OwOTUZUCFF7tpcTx2kNgnv1twfbiJVqJoSnpnQ233(CTV6chrd80YQE6Seyuvx4GiVLnDFaSpGaUplw7p3(HPXoCenWtlR6PZsGHdBZtJQ99TV4oT6i3oLbNwdO1uMdYBrETdI8w2095CizIiVEizEhF2wKxx1jV3ig(n5W)He2MNgvdqpKeWmqyAdjtejBSInYNiDFaaEF5333(qIgDrYJ14QC0(ayFU2xo7p)(EemmoirNIQ4GqIIiV2brElB6(CoKmrKxpKmVJpBlYRR6K3Bed)ayd)hsyBEAuna9qsaZaHPnKyBW080OJg1cT1D2L77BFU2xCNwDKBNvCctlRGIoiYBzt3NfR9NB)W0yhodYlREm1aiwvgFJkh2MNgv77BFXDA1rUDkdoTgqRPmhK3I8Ahe5TSP7Z5(SyTV3rP77BFMSeyuHiVLnDFU3hWjhsMiYRhsuGMyQgRbqSs0Kpyau2ig(XHn8FiHT5Pr1a0djbmdeM2qYerYgRyJ8js3haG3x(99Tpx7RqlawTwvvOWK5Iumn7Y9zXAFOLQkYg7Wzkf1brElB6(CdEFa5O95CizIiVEirbAIPASgaXkrt(GbqzJyedPcikoEplg(p8dWH)djte51dPIlYRhsyBEAuna9ig(j)W)HKjI86He0skwvOPgsyBEAuna9igXqcAI000H)d)aC4)qcBZtJQbOhskKkGzrKxpKa4mrAA6qsaZaHPnKGeDkQfhze6uitkYyFaSpaBY99Tpx7xGHR0GLNmn6mrKSX9zXA)52pmn2HJsWZFDT0GLNmn6W280OAFo333(qIgDkKjfzSpaaV)Kdjte51djdkSgRXbHyhJy4N8d)hsyBEAuna9qsaZaHPnKyBW080OJ3KlhSkUtRoYnTAIizJ7ZI1(HblXWfjpwJRQsCFUbVVhbdJZtFNQYqaL5ueqlYRhsMiYRhsE67uvgcOSrm8tod)hsyBEAuna9qsaZaHPnKyBW080OJ3KlhSkUtRoYnTAIizJ7ZI1(HblXWfjpwJRQsCFUbVVhbdJZdHueon7sNIaArE9qYerE9qYdHueon7Yrm8JJg(pKW280OAa6HKaMbctBi5rWW4iAGNwwLgqSldGoIIHKjI86HKolbg0QCHqvYJDmIHFto8FiHT5Pr1a0djfsfWSiYRhsKOwG0aA695ytR3xy9(bmllr4(C0(fxGDKMEFpcggkP7JMa4(AJgzxUpGtUpffxROU9LRJuNK4r1(anOAFXPq1(rYJ7B09T9dywwIW9JB)PiwSFg7drtzEA0nKeWmqyAdj2gmnpn64n5YbRI70QJCtRMis24(SyTFyWsmCrYJ14QQe3NBW7d4Kdjte51djRfinGMUkmTEed)ayd)hsyBEAuna9qsaZaHPnKmrKSXk2iFI09ba49LFFwS2NR9Hen6uitkYyFaaE)j333(qIof1IJmcDkKjfzSpaaVpaBw7Z5qYerE9qYGcRXAbHMIJy4hh2W)He2MNgvdqpKeWmqyAdj2gmnpn64n5YbRI70QJCtRMis24(SyTFyWsmCrYJ14QQe3NBW77rWW4ysi6PVt5ueqlYRhsMiYRhsmje903PgXWVzJH)djSnpnQgGEijGzGW0gsEemmoIg4PLvPbe7YaOJOyFF7BIizJvSr(eP7dEFahsMiYRhsEwz9yQbmftPJyedPsSrykQ2Hd)h(b4W)He2MNgvdqpKeWmqyAdjU2FU9zBW080OR4oD2LvirNIAXrgH7ZI1(EemmokHsHDvDhVdIMi2NZ99Tpx77rWW4ugCAnGwtzoiVf51oII99TpKOrMdwIofAkDI0OkUu7W280OAFF7BIizJvSr(eP7Zn49LZ(SyTVjIKnwXg5tKUp49LFFohsMiYRhsk0cGvXL6rm8t(H)djSnpnQgGEijGzGW0gsEemmokHsHDvDhVdIMi2NfR9NBF2gmnpn6kUtNDzfs0POwCKr4qYerE9qclsfYNIrm8tod)hsyBEAuna9qsHubmlI86HKCNz)WGLySVqMqND5(jDFvsnpnQiDFk5mea33Zet3pU9dG4(0Sl1ijUWGLySFj2imf7RtASF20anLBizIiVEibj6QjI86QoPXqsaZaHPnKeYeASInYNiDFW7d4qsN0O2gpoKkXgHPyed)4OH)djSnpnQgGEizIiVEir(iAvLwGTcHdjbmdeM2qIR9f3Pvh52zfNW0YkOOdI8w209bW(tUVV9vOhbdJJbPbcZUSs(iALJOyFwS2xHEemmogKgim7Yk5JOvoAyIP7dG9LZ(CUVV95AFMSeyuHiVLnDFU3xCNwDKBNcTay1AvvHctMdI8w209NFFaN1(SyTptwcmQqK3YMUpa2xCNwDKBNvCctlRGIoiYBzt3NZHKqMqJ1WGLyqh(b4ig(n5W)He2MNgvdqpKmrKxpKyqAGWSlR0aMtXHKaMbctBiPqpcgghdsdeMDzL8r0khnmX095g8(YzFF7lUtRoYTZkoHPLvqrhe5TSP7Z9(YzFwS2xHEemmogKgim7Yk5JOvoAyIP7Z9(aoKeYeASggSed6WpahXWpa2W)He2MNgvdqpKmrKxpKyqAGWSlR0aMtXHKaMbctBijUtRoYTZkoHPLvqrhe5TSP7dG9NCFF7RqpcgghdsdeMDzL8r0khnmX095EFahsczcnwddwIbD4hGJyedjfYye6y4)Wpah(pKmrKxpK4ZwvzGisIhhsyBEAuna9ig(j)W)He2MNgvdqpKUIHefJHKjI86HeBdMMNghsSnnboKe3Pvh52rj45VUwAWYtMgDqK3YMUp37p5((2pmn2HJsWZFDT0GLNmn6W280OAiX2G124XHuXD6SlRqIof1IJmchXWp5m8FiHT5Pr1a0dPRyirXyizIiVEiX2GP5PXHeBttGdPW0yho6rORq0kqOdBZtJQ99TpKOX95EF5333(HblXWfjpwJRwiIQCMCFU3FY99TptwcmQqK3YMUpa2FYHeBdwBJhhsf3PZUScjAKoIHFC0W)He2MNgvdqpKUIHefJHKjI86HeBdMMNghsSnnboKmrKSXk2iFI09bVpG77BFU2FU9HwQQiBSdNPuuhcqjnO7ZI1(qlvvKn2HZukQl79bW(ao5(CoKyBWAB84qIg1cT1D2LJy43Kd)hsyBEAuna9q6kgsumgsMiYRhsSnyAEACiX20e4qQadxPblpzA0zIizJ7ZI1(EemmoIg4PLvnk1i0HJOyFwS2pmn2HZG8YQhtnaIvLX3OYHT5Pr1((2VadNvCIAjWJq7mrKSX9zXAFpcggNYGtRb0AkZb5TiV2rumKyBWAB84qI3KlhSkUtRoYnTAIizJJy4haB4)qcBZtJQbOhskKkGzrKxpK4Wzzhw2zxU)S5esOXo2NetBLe4(jDFB)cyEWmKnKeWmqyAdj1fo2jKqJDul0wjb6GidePanpnUVV9NB)W0yhoIg4PLv90zjWWHT5Pr1((2FU9HwQQiBSdNPuuhcqjnOdjte51dPJi8GOnDed)4Wg(pKW280OAa6HKaMbctBiPUWXoHeASJAH2kjqhezGifO5PX99TVjIKnwXg5tKUpaaVV877BFU2FU9dtJD4iAGNww1tNLadh2MNgv7ZI1(HPXoCenWtlR6PZsGHdBZtJQ99TV4oT6i3oIg4PLv90zjWWbrElB6(CoKmrKxpKoIWdI20rm8B2y4)qcBZtJQbOhscygimTHeKOrMdwIokrbcPb0Y2HT5Pr1((2NR9vx4yGhnQmiBe6GidePanpnUplw7RUW5PVtvl0wjb6GidePanpnUpNdjte51dPJi8GOnDed)a4B4)qcBZtJQbOhskKkGzrKxpKirIiVE)zpPbDFRv7l3kWgH095sUvGncPZiHCab2cKUprtjkkoyGQ9ZEFtPU2X5qYerE9qsyAD1erEDvN0yiPtAuBJhhsbm7PyqhXWpaN1W)He2MNgvdqpKmrKxpKeMwxnrKxx1jngs6Kg124XHK4yJT1bDed)aeWH)djSnpnQgGEizIiVEijmTUAIiVUQtAmK0jnQTXJdjOjstthXWpaLF4)qcBZtJQbOhskKkGzrKxpKmrKxtDkKXi0X8GNHICab2cK0KbSjIKnwXg5tKcgqFZPqlawN2zjWWPsQ5PXQDHI024rWxb2ieumiVS6XudGyvHMcuyqAGWSlR0aMtrqHbPbcZUSsdyofbfIg4PLv90zjWaukUiVguugCAnGwtzoiVf51GIvCctlRGIdjte51djHP1vte51vDsJHKoPrTnECijUtRoYnDed)auod)hsyBEAuna9qsaZaHPnKmrKSXk2iFI09ba49LFFF7Z1(I70QJC7uOfaRwRQkuyYCqK3YMUp37d4S233(ZTFyASdNczsn6W280OAFwS2xCNwDKBNczsn6GiVLnDFU3hWzTVV9dtJD4uitQrh2MNgv7Z5((2FU9vOfaRwRQkuyYCrkMMD5qYerE9qcs0vte51vDsJHKoPrTnECizhwPyqumIHFaYrd)hsyBEAuna9qsaZaHPnKmrKSXk2iFI09ba49LFFF7RqlawTwvvOWK5Iumn7YHKjI86HeKORMiYRR6KgdjDsJAB84qYoS6raPXig(b4Kd)hsyBEAuna9qsaZaHPnKmrKSXk2iFI09ba49LFFF7Z1(ZTVcTay1AvvHctMlsX0Sl333(CTV4oT6i3ofAbWQ1QQcfMmhe5TSP7dG9bCw77B)52pmn2HtHmPgDyBEAuTplw7lUtRoYTtHmPgDqK3YMUpa2hWzTVV9dtJD4uitQrh2MNgv7Z5(CoKmrKxpKGeD1erEDvN0yiPtAuBJhhsLyJWuuTdhXWpabyd)hsyBEAuna9qsaZaHPnKmrKSXk2iFI09bVpGdjte51djHP1vte51vDsJHKoPrTnECivInctXigXqsCNwDKB6W)HFao8FiHT5Pr1a0djbmdeM2qITbtZtJoEtUCWQ4oT6i30QjIKnUplw77Du6((2NjlbgviYBzt3N79LhGnKmrKxpKkUiVEed)KF4)qcBZtJQbOhscygimTHK4oT6i3oIg4PLv90zjWWbrElB6(CV)K77BFXDA1rUDkdoTgqRPmhK3I8Ahe5TSPveGkqrGQ95E)j333(HPXoCenWtlR6PZsGHdBZtJQ9zXA)52pmn2HJObEAzvpDwcmCyBEAuTplw77Du6((2NjlbgviYBzt3N79LZKdjte51djdYlREm1aiwvOPgXWp5m8FiHT5Pr1a0djte51dj6rORq0kq4qsaZaHPnKcdwIHlsESgxTqev5m5(CV)K77B)WGLy4IKhRXvvjUpa2FY99TVjIKnwXg5tKUp3G3xodjHmHgRHblXGo8dWrm8JJg(pKW280OAa6HKcPcywe51dPztNwr3h06SeySpZb3NOy)42FY9PO4AfD)42NkRf7todG7tIkoHPLvqrs3xUfari5KIKUpbf3NCga3Nem4099hAnL5G8wKx7gscygimTHeBdMMNgD0OwOTUZUCFF7Z1(I70QJC7SItyAzfu0brElBAfbOcueOAFU3FY9zXAFXDA1rUDwXjmTSck6GiVLnTIaubkcuTpa2hWzTpN77BFU2xCNwDKBNYGtRb0AkZb5TiV2brElB6(CVFPqTplw77rWW4ugCAnGwtzoiVf51oII95CizIiVEir0apTSQNolbgJy43Kd)hsyBEAuna9qsaZaHPnKmrKSXk2iFI09ba49LFFwS237O099TptwcmQqK3YMUp37lpGdjte51djIg4PLv90zjWyed)ayd)hsyBEAuna9qsaZaHPnKyBW080OJg1cT1D2L77BFU2xDHJObEAzvpDwcmQQlCqK3YMUplw7p3(HPXoCenWtlR6PZsGHdBZtJQ95CizIiVEiPm40AaTMYCqElYRhXWpoSH)djSnpnQgGEijGzGW0gsMis2yfBKpr6(aa8(YVplw77Du6((2NjlbgviYBzt3N79LhWHKjI86HKYGtRb0AkZb5TiVEed)Mng(pKW280OAa6HKaMbctBizIizJvSr(eP7dEFa333(k0JGHXXG0aHzxwjFeTYrdtmDFaSVCgsMiYRhswXjmTSckoIHFa8n8FiHT5Pr1a0djte51djR4eMwwbfhscygimTHKjIKnwXg5tKUpaaVV877BFf6rWW4yqAGWSlRKpIw5OHjMUpa2xo77B)52xHwaSATQQqHjZfPyA2LdjHmHgRHblXGo8dWrm8dWzn8FiHT5Pr1a0djbmdeM2qcs0POwCKrOtHmPiJ95EFa5O99Tpx7lUtRoYTJObEAzvpDwcmCqK3YMUp37d4S2NfR9vx4iAGNww1tNLaJQ6che5TSP7Z5qYerE9qIsWZFDT0GLNmnoIHFac4W)He2MNgvdqpKeWmqyAdj2gmnpn6OrTqBDND5((2xHEemmogKgim7Yk5JOvoAyIP7Z9(YVVV95A)cmCwXjQLapcTZerYg3NfR99iyyCkdoTgqRPmhK3I8AhrX((2FU9lWWzqEz1sGhH2zIizJ7Z5qYerE9qIObEAzvJsncDmIHFak)W)He2MNgvdqpKmrKxpKiAGNww1OuJqhdjbmdeM2qYerYgRyJ8js3haG3x(99TVc9iyyCminqy2LvYhrRC0Wet3N79LFijKj0ynmyjg0HFaoIHFakNH)djSnpnQgGEijGzGW0gsZTFbgUsGhH2zIizJdjte51djOLuSQqtnIrmIHeBesZRh(j)SKhWzjhabCir2GD2L0H0SLebW5NC3pouqz)99hiUFYxCWyFMdU)e2HvkgeftSpe5aIeIQ9PhpUVrehVfOAFbqRlrQBbz2Zg3xoGY(C81SryGQ9Nas0iZblrhOoX(XT)eqIgzoyj6avh2MNgvtSpxacqC6wqwqMTKiao)K7(XHck7VV)aX9t(Idg7ZCW9NWoS6raPXe7droGiHOAF6XJ7BeXXBbQ2xa06sK6wqM9SX9beu2NJVMncduT)eqIgzoyj6a1j2pU9Nas0iZblrhO6W280OAI95cqaIt3cYcYSLebW5NC3pouqz)99hiUFYxCWyFMdU)ebm7PyqNyFiYbejev7tpECFJioElq1(cGwxIu3cYSNnUpGGY(C81SryGQ9Nimn2HduNy)42FIW0yhoq1HT5Pr1e7ZfGaeNUfKfKzljcGZp5UFCOGY(77pqC)KV4GX(mhC)jkXgHPyI9HihqKquTp94X9nI44Tav7laADjsDliZE24(Ybu2NJVMncduT)eqIgzoyj6a1j2pU9Nas0iZblrhO6W280OAI95cqaIt3cYcYSLebW5NC3pouqz)99hiUFYxCWyFMdU)eIJn2wh0j2hICarcr1(0Jh33iIJ3cuTVaO1Li1TGm7zJ7diOSphFnBegOA)jctJD4a1j2pU9Nimn2HduDyBEAunX(CbiaXPBbz2Zg3xoGY(C81SryGQ9Nimn2HduNy)42FIW0yhoq1HT5Pr1e7ZfGaeNUfKzpBCF5ak7ZXxZgHbQ2Fc6rO9Yw5a1j2pU9NGEeAVSvoq1HT5Pr1e7ZfGaeNUfKzpBCFocu2NJVMncduT)eHPXoCG6e7h3(teMg7WbQoSnpnQMyFUaeG40TGm7zJ7ZrGY(C81SryGQ9NGEeAVSvoqDI9JB)jOhH2lBLduDyBEAunX(CbiaXPBbz2Zg3hGbk7ZXxZgHbQ2FIW0yhoqDI9JB)jctJD4avh2MNgvtSpxacqC6wqwqMTKiao)K7(XHck7VV)aX9t(Idg7ZCW9NqCNwDKB6e7droGiHOAF6XJ7BeXXBbQ2xa06sK6wqM9SX9Lhu2NJVMncduT)eHPXoCG6e7h3(teMg7WbQoSnpnQMyFUKhG40TGm7zJ7dWaL954RzJWav7pryASdhOoX(XT)eHPXoCGQdBZtJQj2NlabioDliliZwseaNFYD)4qbL933FG4(jFXbJ9zo4(tuInctr1oCI9HihqKquTp94X9nI44Tav7laADjsDliZE24(ack7ZXxZgHbQ2FcirJmhSeDG6e7h3(tajAK5GLOduDyBEAunX(CbiaXPBbzbz2sIa48tU7hhkOS)((de3p5loySpZb3FcfYye6yI9HihqKquTp94X9nI44Tav7laADjsDliZE24(Ydk7ZXxZgHbQ2FIW0yhoqDI9JB)jctJD4avh2MNgvtSVf7lxj3M995cqaIt3cYSNnUVCaL954RzJWav7pryASdhOoX(XT)eHPXoCGQdBZtJQj2NlabioDliZE24(tck7ZXxZgHbQ2FIW0yhoqDI9JB)jctJD4avh2MNgvtSpxacqC6wqM9SX9byGY(C81SryGQ9Nimn2HduNy)42FIW0yhoq1HT5Pr1e7ZfGaeNUfKzpBCFomqzFo(A2imq1(teMg7WbQtSFC7pryASdhO6W280OAI95sEaIt3cYSNnU)SbOSphFnBegOA)jGenYCWs0bQtSFC7pbKOrMdwIoq1HT5Pr1e7ZfGaeNUfKzpBCFaLdOSphFnBegOA)jctJD4a1j2pU9Nimn2HduDyBEAunX(CjpaXPBbz2Zg3hWjbL954RzJWav7pryASdhOoX(XT)eHPXoCGQdBZtJQj2Nl5bioDliliYD(IdgOAFaN1(MiYR3xN0G6wqgsfWJj14qIKKCFsaTa4(C47SeySVCDd80Ywqijj3NdNbfa3hqajDF5NL8aUGSGqssUpjsjxiObp2bD)42NeAsygsazsnodjGwaKUpjqG7h3(xRLTV4i6y)WGLyq3NmWBFdI7JaubkcuTFC7Rt24(6Rl3h7JOe4(XTpVfbc3Nl7WkfdII9jjGC6wqijj3NesQ5Pr1(sMaMmPin9(KyMi23dfgbf3xHMA)sGhHMUpVnf3N5G7tn1(KahEQBbHKKCF5AA2L7pBpIwTVub2keUV5L6msKUp)bX9z0iaLEAz7ZLf7ZrZVpnmXu6(ztd0u7Fm7p58CcW)(KajM0(nseqtVV1Q95nz7xar2yh7tpEC)(iXbrX(0miSiVM6wqijj3NJbADjQ2N3Az7pbtwcmQqK3YMoX(IRvzKxBA6(XTVvuOLTF277Du6(mzjWGU)1Az7ZLgP095ysyFYgnW9VE)aAuGC6wqijj33F5gji3aL933pK8(bm7PySVaMbctZTGSGyIiVM6kGO449SyEWZuCrE9cIjI8AQRaIIJ3ZI5bpd0skwvOPwqijj3xUITPjSaP7B7hWSNIbDFXDA1rUjDFvYovOAFpz7Zrt623FGjDFYgDFbWJI9(gDFIg4PLTp5doLU)17ZrtUpffxR23JasJ9fYeAKs6(EeX(an6(XD7ZBTS9fk4(iddkc6(XTFzYg332xCNwDKBha5ueqlYR3xLSt6b3pBAGMYTVCNz)mMGUpBttG7d0O733(qK3YwHW9Hyqa79bK09rnf3hIbbS3FwUjDliKKK7BIiVM6kGO449SyEWZW2GP5PrsBJhbhWSNIrfWkvwli9katXiziLTPjqWaskBttGvutrWZYnjPIRvzKxdoGzpfdhGoGgTsqXQhbdJpUcy2tXWbOtCNwDKBNIaArEnapaEC0KGNfNliKKK7BIiVM6kGO449SyEWZW2GP5PrsBJhbhWSNIrv(kvwli9katXiziLTPjqWaskBttGvutrWZYnjPIRvzKxdoGzpfdN8oGgTsqXQhbdJpUcy2tXWjVtCNwDKBNIaArEnapaEC0KGNfNliKKK7lxrJK3cKUVTFaZEkg09zBAcCFpz7lo(cdMD5(bqCFXDA1rU3)y2paI7hWSNIbP7Rs2Pcv77jB)aiUVIaArE9(hZ(bqCFpcgM9Zy)c4Xovi1T)SjJUVTpnGyxga3N)ujtIW9JB)YKnUVTpWSeic3VaMhmdz7h3(0aIDzaC)aM9umOKUVr3NmQ17B09T95pvYKiCFMdUFYSVTFaZEkg7to169p4(KtTE)(I9PYAX(KZa4(I70QJCtDliKKK7BIiVM6kGO449SyEWZW2GP5PrsBJhbhWSNIrTaMhmdzKEfGPyKmKY20eiy5jLTPjWkQPiyajvCTkJ8AWZfWSNIHdqhqJwjOy1JGHXxaZEkgo5DanALGIvpcggwScy2tXWjVdOrReuS6rWW4JlUcy2tXWjVtCNwDKBNIaArEnaVaM9umCY7kGNWzTSQQG6ueqlYR5KdHlaDtoFaZEkgo5DanA1JGHHtoeUyBW080OlGzpfJQ8vQSwWjNaGlUcy2tXWbOtCNwDKBNIaArEnaVaM9umCa6kGNWzTSQQG6ueqlYR5KdHlaDtoFaZEkgoaDanA1JGHHtoeUyBW080OlGzpfJkGvQSwWjNlililiKKK7lxbqOGiq1(iBekB)i5X9dG4(Mio4(jDFJTLAZtJUfete51uW8zRQmqejXJliKKK7pB2GP5Pr6cIjI8A68GNHTbtZtJK2gpcU4oD2LvirNIAXrgHKY20eiyXDA1rUDucE(RRLgS8KPrhe5TSPCpPVW0yhokbp)11sdwEY04cIjI8A68GNHTbtZtJK2gpcU4oD2LvirJuszBAceCyASdh9i0viAfi0hKOrUL3xyWsmCrYJ14QfIOkNj5EsFmzjWOcrElBkaMCbXerEnDEWZW2GP5PrsBJhbtJAH26o7sszBAceSjIKnwXg5tKcgqFCnh0svfzJD4mLI6qakPbLflOLQkYg7Wzkf1LnaaCsoxqmrKxtNh8mSnyAEAK024rW8MC5GvXDA1rUPvtejBKu2MMabxGHR0GLNmn6mrKSrwS8iyyCenWtlRAuQrOdhrblwHPXoCgKxw9yQbqSQm(gv(kWWzfNOwc8i0otejBKflpcggNYGtRb0AkZb5TiV2ruSGqY95Wzzhw2zxU)S5esOXo2NetBLe4(jDFB)cyEWmKTGyIiVMop4zoIWdI2ustgWQlCStiHg7OwOTsc0brgisbAEA03CHPXoCenWtlR6PZsGHV5GwQQiBSdNPuuhcqjnOliMiYRPZdEMJi8GOnL0KbS6ch7esOXoQfARKaDqKbIuGMNg9zIizJvSr(ePaaS8(4AUW0yhoIg4PLv90zjWGfRW0yhoIg4PLv90zjWWN4oT6i3oIg4PLv90zjWWbrElBkNliMiYRPZdEMJi8GOnL0KbmKOrMdwIokrbcPb0Y2hxQlCmWJgvgKncDqKbIuGMNgzXsDHZtFNQwOTsc0brgisbAEAKZfesUpjse517p7jnO7BTAF5wb2iKUpxYTcSriDgjKdiWwG09jAkrrXbduTF27Bk11ooxqmrKxtNh8mctRRMiYRR6KgK2gpcoGzpfd6cIjI8A68GNryAD1erEDvN0G024rWIJn2wh0fete5105bpJW06QjI86QoPbPTXJGHMinnDbHK7BIiVMop4zOihqGTajnzaBIizJvSr(ePGb03Ck0cG1PDwcmCQKAEASAxOiTnEe8vGncbfdYlREm1aiwvOPafgKgim7YknG5ueuyqAGWSlR0aMtrqHObEAzvpDwcmaLIlYRbfLbNwdO1uMdYBrEnOyfNW0YkO4cIjI8A68GNryAD1erEDvN0G024rWI70QJCtxqmrKxtNh8mqIUAIiVUQtAqAB8iy7WkfdIcstgWMis2yfBKprkaalVpUe3Pvh52PqlawTwvvOWK5GiVLnLBaNLV5ctJD4uitQrwSe3Pvh52PqMuJoiYBzt5gWz5lmn2HtHmPg503Ck0cGvRvvfkmzUiftZUCbXerEnDEWZaj6QjI86QoPbPTXJGTdREeqAqAYa2erYgRyJ8jsbay59PqlawTwvvOWK5Iumn7Yfete5105bpdKORMiYRR6KgK2gpcUeBeMIQDiPjdytejBSInYNifaGL3hxZPqlawTwvvOWK5Iumn7sFCjUtRoYTtHwaSATQQqHjZbrElBkaaCw(Mlmn2HtHmPgzXsCNwDKBNczsn6GiVLnfaaolFHPXoCkKj1iNCUGyIiVMop4zeMwxnrKxx1jniTnEeCj2imfKMmGnrKSXk2iFIuWaUGSGqssUpj6KR2h0eqASGyIiVM6SdREeqAawHwaSkUutAYaMlpcgghLqPWUQUJ3brteSynhBdMMNgDf3PZUScj6uuloYiKtFC5rWW4ugCAnGwtzoiVf51oIcFqIgzoyj6uOP0jsJQ4sTptejBSInYNiLBWYHfltejBSInYNifS8CUGyIiVM6SdREeqAmp4zWIuH8PG0KbmKOtrT4iJqNczsrgCZfGZAEfAbW60olbgogYhrRqvnmyjguoe5WPpfAbW60olbgogYhrRqvnmyjguUby(MJTbtZtJUI70zxwHeDkQfhzeYILhbdJJs2G8zxw5tA4ikwqmrKxtD2HvpcinMh8myrQq(uqAYags0POwCKrOtHmPidULFsFk0cG1PDwcmCmKpIwHQAyWsmOaysFZX2GP5PrxXD6SlRqIof1IJmcxqmrKxtD2HvpcinMh8myrQq(uqAYaEofAbW60olbgogYhrRqvnmyjguFZX2GP5PrxXD6SlRqIof1IJmczXIjlbgviYBzt5EswSGwQQiBSdNPuuhcqjnO(GwQQiBSdNPuuhe5TSPCp5cIjI8AQZoS6raPX8GNH8r0QkTaBfcxqmrKxtD2HvpcinMh8myrQq(uqAYaEo2gmnpn6kUtNDzfs0POwCKr4cYccjj5(KOtUAFjmikwqmrKxtD2HvkgefGTwwv1kstgWk0cG1PDwcmCmKpIwHQAyWsmOaaSqMqJvSr(ePSybTuvr2yhotPOoeGsAq9bTuvr2yhotPOoiYBzt5gmGaUGyIiVM6SdRumikMh8mwlRQAfPjdyfAbW60olbgogYhrRqvnmyjguaaEYfete51uNDyLIbrX8GNrHwaSkUutAYaEo2gmnpn6kUtNDzfs0POwCKrOpU8iyyCkdoTgqRPmhK3I8AhrHpirJmhSeDk0u6ePrvCP2NjIKnwXg5tKYny5WILjIKnwXg5tKcwEoxqmrKxtD2HvkgefZdEgSiviFkinzaphBdMMNgDf3PZUScj6uuloYiCbXerEn1zhwPyqump4zyqAGWSlR0aMtrsfYeASggSedkyajnzaRqpcgghdsdeMDzL8r0khnmXuUblhFI70QJC7SItyAzfu0brElBk3YzbXerEn1zhwPyqump4zyqAGWSlR0aMtrsfYeASggSedkyajnzaRqpcgghdsdeMDzL8r0khnmXuUbCbXerEn1zhwPyqump4zyqAGWSlR0aMtrsfYeASggSedkyajnzaRqpcgghdsdeMDzL8r0khnmXuUblhFqIgDrYJ14QCe3I70QJC7Swwv1khe5TSPliKC)zlqS3pmyjg7tjBf09niUVkPMNgvKUFamP7to1691ySVSJyFAb2Q9HensNH8r0k6(ztd0u7Fm7t2Yi7Y9zo4(KqtcZqcitQXzib0cGtq3Neiq3cIjI8AQZoSsXGOyEWZq(iAvLwGTcHKMmG5Aokgr2LuNqMqJSyPqlawN2zjWWXq(iAfQQHblXGcaWczcnwXg5tKYPpf6rWW4yqAGWSlRKpIw5OHjMca54ds0OlsESgxvoClUtRoYTZAzvvRCqK3YMUGSGqssUpj2f51liMiYRPoXDA1rUPGlUiVM0KbmBdMMNgD8MC5GvXDA1rUPvtejBKflVJs9XKLaJke5TSPClpaBbHKKCFo(oT6i30fete51uN4oT6i305bpJb5LvpMAaeRk0uKMmGf3Pvh52r0apTSQNolbgoiYBzt5EsFI70QJC7ugCAnGwtzoiVf51oiYBztRiavGIavCpPVW0yhoIg4PLv90zjWGfR5ctJD4iAGNww1tNLadwS8ok1htwcmQqK3YMYTCMCbXerEn1jUtRoYnDEWZqpcDfIwbcjvitOXAyWsmOGbK0KbCyWsmCrYJ14QfIOkNj5EsFHblXWfjpwJRQseat6ZerYgRyJ8js5gSCwqi5(ZMoTIUpO1zjWyFMdUprX(XT)K7trX1k6(XTpvwl2NCga3NevCctlRGIKUVClaIqYjfjDFckUp5maUpjyWP77p0AkZb5TiV2TGyIiVM6e3Pvh5Mop4ziAGNww1tNLadstgWSnyAEA0rJAH26o7sFCjUtRoYTZkoHPLvqrhe5TSPveGkqrGkUNKflXDA1rUDwXjmTSck6GiVLnTIaubkcubaaNfN(4sCNwDKBNYGtRb0AkZb5TiV2brElBk3LcflwEemmoLbNwdO1uMdYBrETJOGZfete51uN4oT6i305bpdrd80YQE6SeyqAYa2erYgRyJ8jsbay5zXY7OuFmzjWOcrElBk3Yd4cIjI8AQtCNwDKB68GNrzWP1aAnL5G8wKxtAYaMTbtZtJoAul0w3zx6Jl1foIg4PLv90zjWOQUWbrElBklwZfMg7Wr0apTSQNolbgCUGyIiVM6e3Pvh5Mop4zugCAnGwtzoiVf51KMmGnrKSXk2iFIuaawEwS8ok1htwcmQqK3YMYT8aUGyIiVM6e3Pvh5Mop4zSItyAzfuK0KbSjIKnwXg5tKcgqFk0JGHXXG0aHzxwjFeTYrdtmfaYzbXerEn1jUtRoYnDEWZyfNW0YkOiPczcnwddwIbfmGKMmGnrKSXk2iFIuaawEFk0JGHXXG0aHzxwjFeTYrdtmfaYX3Ck0cGvRvvfkmzUiftZUCbXerEn1jUtRoYnDEWZqj45VUwAWYtMgjnzadj6uuloYi0PqMuKb3aYr(4sCNwDKBhrd80YQE6Sey4GiVLnLBaNflwQlCenWtlR6PZsGrvDHdI8w2uoxqmrKxtDI70QJCtNh8menWtlRAuQrOdstgWSnyAEA0rJAH26o7sFk0JGHXXG0aHzxwjFeTYrdtmLB59XvbgoR4e1sGhH2zIizJSy5rWW4ugCAnGwtzoiVf51oIcFZvGHZG8YQLapcTZerYg5CbXerEn1jUtRoYnDEWZq0apTSQrPgHoivitOXAyWsmOGbK0KbSjIKnwXg5tKcaWY7tHEemmogKgim7Yk5JOvoAyIPCl)cIjI8AQtCNwDKB68GNbAjfRk0uKMmGNRadxjWJq7mrKSXfessY9jHKAEAur6(YfcASFFX(q00Az73hK3077Han25b3paAXe09jFWa4(feqkr2L7NnjUsJhDliKKK7BIiVM6e3Pvh5Mop4zOMaMmPinDTWebPjdytejBSInYNifaGL33CEemmoLbNwdO1uMdYBrETJOW3CI70QJC7ugCAnGwtzoiVf51oiAkzSy5DuQpMSeyuHiVLnL7sHAbzbHKKCFo(yJT1X(KiVuNrI0fete51uN4yJT1bfmLSb5ZUSYN0G0KbmBdMMNgD0OwOTUZU0hKOtrT4iJqNczsrgaaqaMpUe3Pvh52zfNW0YkOOdI8w2uwSMlmn2HZG8YQhtnaIvLX3OYN4oT6i3oLbNwdO1uMdYBrETdI8w2uozXY7OuFmzjWOcrElBk3ac4ccj3xcJ9JBFckUVXeiCFR4e7N09VEFoMe23O7h3(fqKn2X(hBekSIISl3hGJeBFYatnUpfJi7Y9jk2NJjHjOliMiYRPoXXgBRd68GNHs2G8zxw5tAqAYawCNwDKBNvCctlRGIoiYBzt9XLjIKnwXg5tKcaWY7ZerYgRyJ8js5g8K(GeDkQfhze6uitkYaaaoR55YerYgRyJ8js5qayCYILjIKnwXg5tKcGj9bj6uuloYi0PqMuKba4OzX5cIjI8AQtCSX26Gop4zmVJpBlYRR6K3J0KbmBdMMNgD0OwOTUZU03C0Jq7LTYPrtv9KvraY4l0OpUe3Pvh52zfNW0YkOOdI8w2uwSMlmn2HZG8YQhtnaIvLX3OYN4oT6i3oLbNwdO1uMdYBrETdI8w2uo9bjA0fjpwJRYraGl5mVhbdJds0POkoiKOiYRDqK3YMYjlwEhL6JjlbgviYBzt5wEaxqmrKxtDIJn2wh05bpJ5D8zBrEDvN8EKMmGzBW080OJg1cT1D2L(OhH2lBLtJMQ6jRIaKXxOrFCPUWr0apTSQNolbgv1foiYBztbaGaYI1CHPXoCenWtlR6PZsGHpXDA1rUDkdoTgqRPmhK3I8Ahe5TSPCUGyIiVM6ehBSToOZdEgZ74Z2I86Qo59inzaBIizJvSr(ePaaS8(Gen6IKhRXv5iaWLCM3JGHXbj6uufhesue51oiYBzt5CbXerEn1jo2yBDqNh8muGMyQgRbqSs0KpyaugPjdy2gmnpn6OrTqBDNDPpUe3Pvh52zfNW0YkOOdI8w2uwSMlmn2HZG8YQhtnaIvLX3OYN4oT6i3oLbNwdO1uMdYBrETdI8w2uozXY7OuFmzjWOcrElBk3ao5cIjI8AQtCSX26Gop4zOanXunwdGyLOjFWaOmstgWMis2yfBKprkaalVpUuOfaRwRQkuyYCrkMMDjlwqlvvKn2HZukQdI8w2uUbdihX5cYccjj5(szxQX993GLySGyIiVM6kXgHPaScTayvCPM0KbShbdJJsOuyxv3X7GOjcFZX2GP5PrxXD6SlRqIof1IJmczXQadxPblpzA0zIizJliMiYRPUsSrykMh8mk0cGvXLAstgWqIof1IJmcDkKjfzWnGYHflMSeyuHiVLnL7j9nNc9iyyCminqy2LvYhrRCefliMiYRPUsSrykMh8mwlRQAfPjdyXDA1rUDwXjmTSck6GiVLn1hxHPXoCkKj1OdBZtJkwSehBSToCDwcmQmgYIfKOrMdwIUcGObp(RrkN(4Ao2gmnpn6kUtNDzfs0iLflMSeyuHiVLnL7j5CbXerEn1vInctX8GNH8r0QkTaBfcjnzaRqpcgghdsdeMDzL8r0khnmXuaihFZX2GP5PrxXD6SlRqIgPliMiYRPUsSrykMh8mKpIwvPfyRqiPjdyf6rWW4yqAGWSlRKpIw5ik8jUtRoYTZkoHPLvqrhe5TSPveGkqrGkamPV5yBW080OR4oD2LvirJ0fete51uxj2imfZdEgfAbWQ4snPjdyirNIAXrgHofYKIm4w(z5Bo2gmnpn6kUtNDzfs0POwCKr4cIjI8AQReBeMI5bpddsdeMDzLgWCksAYawHEemmogKgim7Yk5JOvoAyIPCdOV5yBW080OR4oD2LvirJ0fete51uxj2imfZdEggKgim7YknG5uK0KbSc9iyyCminqy2LvYhrRC0Wet5MJ8jUtRoYTZkoHPLvqrhe5TSPveGkqrGkUN03CSnyAEA0vCNo7YkKOr6cIjI8AQReBeMI5bpJcTayvCPM0Kb8CSnyAEA0vCNo7YkKOtrT4iJWfKfessY95qXgHPyFs0jxTpjgmpygYwqijj33erEn1vInctr1oemzlJkZbRI70QJCtAB8iy6rORq0kqiPjd4W0yho6rORq0kqOVWGLy4IKhRXvlervotY9K(yYsGrfI8w2uamPpXDA1rUD0JqxHOvGqhe5TSPCZvPqXHmlhh2KC6ZerYgRyJ8js5gSCwqmrKxtDLyJWuuTdNh8mk0cGvXLAstgWCnhBdMMNgDf3PZUScj6uuloYiKflpcgghLqPWUQUJ3brteC6JlpcggNYGtRb0AkZb5TiV2ru4ds0iZblrNcnLorAufxQ9zIizJvSr(ePCdwoSyzIizJvSr(ePGLNZfete51uxj2imfv7W5bpdwKkKpfKMmG9iyyCucLc7Q6oEhenrWI1CSnyAEA0vCNo7YkKOtrT4iJWfesUVCNz)WGLySVqMqND5(jDFvsnpnQiDFk5mea33Zet3pU9dG4(0Sl1ijUWGLySFj2imf7RtASF20anLBbXerEn1vInctr1oCEWZaj6QjI86QoPbPTXJGlXgHPG0KbSqMqJvSr(ePGbCbXerEn1vInctr1oCEWZq(iAvLwGTcHKkKj0ynmyjguWasAYaMlXDA1rUDwXjmTSck6GiVLnfat6tHEemmogKgim7Yk5JOvoIcwSuOhbdJJbPbcZUSs(iALJgMykaKdN(4IjlbgviYBzt5wCNwDKBNcTay1AvvHctMdI8w205bCwSyXKLaJke5TSPaqCNwDKBNvCctlRGIoiYBzt5CbXerEn1vInctr1oCEWZWG0aHzxwPbmNIKkKj0ynmyjguWasAYawHEemmogKgim7Yk5JOvoAyIPCdwo(e3Pvh52zfNW0YkOOdI8w2uULdlwk0JGHXXG0aHzxwjFeTYrdtmLBaxqmrKxtDLyJWuuTdNh8mminqy2LvAaZPiPczcnwddwIbfmGKMmGf3Pvh52zfNW0YkOOdI8w2uamPpf6rWW4yqAGWSlRKpIw5OHjMYnGliliKCFaotKMMUGyIiVM6GMinnfSbfwJ14GqSdstgWqIof1IJmcDkKjfzaaa2K(4QadxPblpzA0zIizJSynxyASdhLGN)6APblpzA0HT5PrfN(Gen6uitkYaaGNCbXerEn1bnrAA68GNXtFNQYqaLrAYaMTbtZtJoEtUCWQ4oT6i30QjIKnYIvyWsmCrYJ14QQe5gShbdJZtFNQYqaL5ueqlYRxqmrKxtDqtKMMop4z8qifHtZUK0KbmBdMMNgD8MC5GvXDA1rUPvtejBKfRWGLy4IKhRXvvjYnypcggNhcPiCA2Lofb0I86fete51uh0ePPPZdEgDwcmOv5cHQKh7G0KbShbdJJObEAzvAaXUma6ikwqi5(KOwG0aA695ytR3xy9(bmllr4(C0(fxGDKMEFpcggkP7JMa4(AJgzxUpGtUpffxROU9LRJuNK4r1(anOAFXPq1(rYJ7B09T9dywwIW9JB)PiwSFg7drtzEA0TGyIiVM6GMinnDEWZyTaPb00vHP1KMmGzBW080OJ3KlhSkUtRoYnTAIizJSyfgSedxK8ynUQkrUbd4KliMiYRPoOjsttNh8mguynwli0uK0KbSjIKnwXg5tKcaWYZIfxqIgDkKjfzaaWt6ds0POwCKrOtHmPidaagGnloxqmrKxtDqtKMMop4zysi6PVtrAYaMTbtZtJoEtUCWQ4oT6i30QjIKnYIvyWsmCrYJ14QQe5gShbdJJjHON(oLtraTiVEbXerEn1bnrAA68GNXZkRhtnGPykL0KbShbdJJObEAzvAaXUma6ik8zIizJvSr(ePGbCbzbHKKCF)Hzpfd6cIjI8AQlGzpfdkyckwZa5jTnEeC2ubKimpnw5acRdc(QczNcK0KbmxI70QJC7iAGNww1tNLadhe5TSPSyjUtRoYTtzWP1aAnL5G8wKx7GiVLnLtFCvGHZG8YQLapcTZerYgzXQadNvCIAjWJq7mrKSrFZfMg7WzqEz1JPgaXQY4BuXIvyWsmCrYJ14QfIOk)S4EsozXY7OuFmzjWOcrElBk3Yd4cIjI8AQlGzpfd68GNHGI1mqEsBJhbZBcZdIvkqeJkpbnfKMmGf3Pvh52zfNW0YkOOdI8w2uUN0hxZHCarwuGkx2ubKimpnw5acRdc(QczNcKflXDA1rUDztfqIW80yLdiSoi4RkKDkqhe5TSPCYIL3rP(yYsGrfI8w2uULhWfete51uxaZEkg05bpdbfRzG8K2gpcwbrtXKqSYgPuutAYawCNwDKBNvCctlRGIoiYBzt9X1CihqKffOYLnvajcZtJvoGW6GGVQq2PazXsCNwDKBx2ubKimpnw5acRdc(QczNc0brElBkNSy5DuQpMSeyuHiVLnLB5SGyIiVM6cy2tXGop4ziOyndKN024rWkdoL)UUQqX0k7dAImKrAYawCNwDKBNvCctlRGIoiYBzt9X1CihqKffOYLnvajcZtJvoGW6GGVQq2PazXsCNwDKBx2ubKimpnw5acRdc(QczNc0brElBkNSy5DuQpMSeyuHiVLnLB5bCbXerEn1fWSNIbDEWZqqXAgipL0KbmxI70QJC7SItyAzfu0brElBklwEemmoLbNwdO1uMdYBrETJOGtFCnhYbezrbQCztfqIW80yLdiSoi4RkKDkqwSe3Pvh52LnvajcZtJvoGW6GGVQq2PaDqK3YMY5ccjj5((l3ib5gOSGqssUV)aX9dy2tXyFYzaC)aiUpWSeisJ9rAK8wGQ9zBAcK09jNA9(E4(euuTptcPX(wR2VWsiQ2NCga3NevCctlRGI7ZvYSVhbdZ(jDFaNCFkkUwr3)G7RrkLZ9p4(GwNLaJzib)3NRKz)siAbc3paA9(ao5(uuCTIY5ccjj5(MiYRPUaM9umOZdEgckwZa5jLQVaCaZEkgasAYaMlUcy2tXWbORaEcN1YQQcQtraTiVMBWaoPpXDA1rUDwXjmTSck6GiVLnfaYplwScy2tXWbORaEcN1YQQcQtraTiVgaaoPpUe3Pvh52r0apTSQNolbgoiYBztbG8ZIflXDA1rUDkdoTgqRPmhK3I8Ahe5TSPaq(zXjN(4AUaM9umCY7aA0Q4oT6i3SyfWSNIHtEN4oT6i3oiYBztzXITbtZtJUaM9umQfW8GzidmGCYjlwbm7Py4a0vapHZAzvvb1PiGwKxdaWmzjWOcrElB6ccjj5(MiYRPUaM9umOZdEgckwZa5jLQVaCaZEkgYtAYaMlUcy2tXWjVRaEcN1YQQcQtraTiVMBWaoPpXDA1rUDwXjmTSck6GiVLnfaYplwScy2tXWjVRaEcN1YQQcQtraTiVgaaoPpUe3Pvh52r0apTSQNolbgoiYBztbG8ZIflXDA1rUDkdoTgqRPmhK3I8Ahe5TSPaq(zXjN(4AUaM9umCa6aA0Q4oT6i3SyfWSNIHdqN4oT6i3oiYBztzXITbtZtJUaM9umQfW8GzidS8CYjlwbm7Py4K3vapHZAzvvb1PiGwKxdaWmzjWOcrElB6ccjj5(YDM9VwlB)RX9VEFckUFaZEkg7xap2PcP7B77rWWq6(euC)aiU)far4(xVV4oT6i3U9LBW9tM9BmdGiC)aM9um2VaEStfs3323JGHH09jO4(ExaC)R3xCNwDKB3ccjj5(MiYRPUaM9umOZdEgckwZa5jLQVaCaZEkgasAYaEUaM9umCa6aA0kbfREemm(4kGzpfdN8oXDA1rUDqK3YMYI1Cbm7Py4K3b0Ovckw9iyy4CbHKKCFte51uxaZEkg05bpdbfRzG8Ks1xaoGzpfd5jnzapxaZEkgo5DanALGIvpcggFCfWSNIHdqN4oT6i3oiYBztzXAUaM9umCa6aA0kbfREemmCoKmIa4bhssjpH2I8AogAmXigXyaa]] )

end
