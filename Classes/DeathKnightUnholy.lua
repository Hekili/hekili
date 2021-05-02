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


    spec:RegisterPack( "Unholy", 20210502, [[defyocqiLQ6rOuCjGOInrs(KuuJIaDkcyvkvIEfGYSaQUfjfzxu5xkvzyKu1XaKLjf5zKuAAOuY1uQyBkvkFtPsyCKujDoGOsRdiY7iPaAEOuDpezFaHdceLfcu8quk1ebu5IarvBKKkrFKKcAKKuaojjvQvcKEjjvuntLkv3KKkHDQu4NKuHHssrTuLkPEkjMQsrxLKkYwjPa9vLkjJfOK9QK)kvdwvhwyXuLhJQjt0LH2mk(mv1Ob40Iwnjf61kLMnPUnH2TKFRYWLshhOulh0ZrA6uUocBhL8De14bu15LcRNKkkZNG2VIxaT2CPiddxB0K6Bci1VJ6BYb0UGTaAh2APynAXLsBW3g(4sPcrCPOovaoDJLsB0qFHCT5sHEeqoUuaywlfK2Bp)0aq454N4E0uKqhwEfhgm2E0uKV3sXJi1M6UwElfzy4AJMuFtaP(DuFtoG2fnTttlfAlYxB00onTuaKsjwlVLIeP8LcWHHbyE15v6dWMxDQaC6gdOQlIgZ3e4Z3K6BcOb0bu2gqu(ifKgqvtZdYKQrcQjILrN3U5bUc42d4qMuJ7bCyyaOZdCe482n)v6gZZpIYM3cOpA05jd4MpG48iW3ICdLZB386KfoV(k)5X6i8bmVDZlgMHW5fmoStrJODE2aKaUbu108axsdpnkNxj4WKj5zONxnhCBEpKheuCEjgY59bCeA68IXwCEMdopnKZdCQZPUbu108Qt0S8NFxDeLCELwSKiC(Wl1PLiDEXdIZZOrGp90nMxWWMNTa28ul4BPZNf1Wqo)Xm)oata1aNh4uZkZxiHbd98rjNxmAmFlezHLnp9eX5Rtnbr(800iclVI6gqvtZRorZYFE1Li1qyw(ZRyWCloFwZdYuhG8ZNmZ34iMhqWcNVodqw(ZJAkoVDZlV5Jsop5RA2M)yHqE0op5JOK05t68aNAwz(cjmyODdOQP5zBar5JY5fJQX8nZK(aSoefJSOnpp)kzA5vHMoVDZhTT6gZN18EhLopt6dWOZFLUX8cQrkDE2g4MNCqnC(RM3GbfGaUbu108GmPeLZh1zaq48QdcZdIX25XYGnM3U5POnpr78udELpcNhKVnLOyYPUbu108BQoao1bin)8BGKN3GzTfT55W0qygULIoPgDT5sjoStrJODT5AdGwBUuWk80OCbMLchMgcZyPiXWa03wPpaZXq(ikjk7wa9rJopiinpVbxJDSqXePZlu48WiLDKfwMlKsQdb(KA05vnpmszhzHL5cPK6GOyKfDE2jnpqaTucULxTuIQrxwYLT2OP1MlfScpnkxGzPWHPHWmwksmma9Tv6dWCmKpIsIYUfqF0OZdcsZVZsj4wE1sjQgDzjx2Ad1U2CPGv4Pr5cmlfomneMXsz)5zfWm80OR9oDw(DirL8E7rgHZRAEbN3JGHXjd42UbJIYCqXWYRCeTZRAEirHmh0hDsmK6ePwNFP2Hv4Pr58QMp4wYc7yHIjsNNDsZR25fkC(GBjlSJfkMiDEsZ308cSucULxTuKyya68l1lBTbBT2CPGv4Pr5cmlfomneMXsz)5zfWm80OR9oDw(DirL8E7rgHlLGB5vlfSnLOyYx2AJDwBUuWk80OCbMLchMgcZyPirpcgghdsneMLFN8rush1c(25zN08QDEvZZVtlpYLlApEOB0srhefJSOZZ(8QDPeClVAPWGudHz53Pgm3IlfEdUg7wa9rJU2aOLT2y3wBUuWk80OCbMLchMgcZyPirpcgghdsneMLFN8rush1c(25zFEGwkb3YRwkmi1qyw(DQbZT4sH3GRXUfqF0ORnaAzRn2fRnxkyfEAuUaZsHdtdHzSuKOhbdJJbPgcZYVt(ikPJAbF78StAE1oVQ5Hef6Sue721zR5zFE(DA5rUCr1OllPdIIrw0LsWT8QLcdsneMLFNAWClUu4n4ASBb0hn6AdGw2Ad111MlfScpnkxGzPWHPHWmwkco)(ZtrZYYN64n4ACEHcNxIHbOVTsFaMJH8rusu2Ta6JgDEqqAEEdUg7yHIjsNxG5vnVe9iyyCmi1qyw(DYhrjDul4BNheZR25vnpKOqNLIy3UUANN9553PLh5YfvJUSKoikgzrxkb3YRwkKpIs2PTyjr4srIuomBT8QLYUcawZBb0hT5PKJw68beNxM0WtJsWN3aK05jNA98A0MVXrmpTfl58qIcP7r(ikjD(SOggY5pM5jhPLL)8mhCEGRaU9aoKj14EahggGMPZdCeOBzlBPeh29iGuBT5AdGwBUuWk80OCbMLchMgcZyPi48EemmokHuIvxENOdIb3MxOW53FEwbmdpn6AVtNLFhsujV3EKr48cmVQ5fCEpcggNmGB7gmkkZbfdlVYr0oVQ5HefYCqF0jXqQtKAD(LAhwHNgLZRA(GBjlSJfkMiDE2jnVANxOW5dULSWowOyI05jnFtZlWsj4wE1srIHbOZVuVS1gnT2CPGv4Pr5cmlfomneMXsbsujV3EKrOtImjpT5zFEbNhi1ppWMxIHbOVTsFaMJH8rusu2Ta6JgD(D58QDEbMx18smma9Tv6dWCmKpIsIYUfqF0OZZ(8728QMF)5zfWm80OR9oDw(DirL8E7rgHZlu48Eemmok5akMLFxmPMJODPeClVAPGTPeft(YwBO21MlfScpnkxGzPWHPHWmwkqIk592JmcDsKj5Pnp7Z30oZRAEjggG(2k9byogYhrjrz3cOpA05bX87mVQ53FEwbmdpn6AVtNLFhsujV3EKr4sj4wE1sbBtjkM8LT2GTwBUuWk80OCbMLchMgcZyPS)8smma9Tv6dWCmKpIsIYUfqF0OZRA(9NNvaZWtJU270z53HevY7ThzeoVqHZZK(aSoefJSOZZ(87mVqHZdJu2rwyzUqkPoe4tQrNx18WiLDKfwMlKsQdIIrw05zF(Dwkb3YRwkyBkrXKVS1g7S2CPeClVAPq(ikzN2ILeHlfScpnkxGzzRn2T1MlfScpnkxGzPWHPHWmwk7ppRaMHNgDT3PZYVdjQK3BpYiCPeClVAPGTPeft(Yw2sXGzTfn6AZ1gaT2CPGv4Pr5cmlLkeXLswuoKWcpn2bBIOmcXUezLCCPeClVAPKfLdjSWtJDWMikJqSlrwjhxkCyAimJLIGZZVtlpYLJOaC6gDpD6dWCqumYIoVqHZZVtlpYLtgWTDdgfL5GIHLx5GOyKfDEbMx18coFlAUak2O7d4i0UGBjlCEHcNVfnx0E8UpGJq7cULSW5vn)(ZBHglZfqXg9JPBaWUmelu6Wk80OCEHcN3cOpAolfXUD9wU1Bs9ZZ(87mVaZlu48EhLoVQ5zsFawhIIrw05zF(MaAzRnAAT5sbRWtJYfywkviIlfXGhEqStbGO1fjOjFPeClVAPig8WdIDkaeTUibn5lfomneMXsHFNwEKlx0E8q3OLIoikgzrNN953zEvZl487ppc2ezBlkDzr5qcl80yhSjIYie7sKvYX5fkCE(DA5rUCzr5qcl80yhSjIYie7sKvYrhefJSOZlW8cfoV3rPZRAEM0hG1HOyKfDE2NVjGw2Ad1U2CPGv4Pr5cmlLkeXLIeIHKjHyNfsPOEPeClVAPiHyizsi2zHukQxkCyAimJLc)oT8ixUO94HUrlfDqumYIoVQ5fC(9NhbBISTfLUSOCiHfEASd2erzeIDjYk548cfop)oT8ixUSOCiHfEASd2erzeIDjYk5OdIIrw05fyEHcN37O05vnpt6dW6qumYIop7ZR2LT2GTwBUuWk80OCbMLsfI4srgWTI3vDjY32zDWGNwJLsWT8QLImGBfVR6sKVTZ6GbpTglfomneMXsHFNwEKlx0E8q3OLIoikgzrNx18co)(ZJGnr22IsxwuoKWcpn2bBIOmcXUezLCCEHcNNFNwEKlxwuoKWcpn2bBIOmcXUezLC0brXil68cmVqHZ7Du68QMNj9byDikgzrNN95BcOLT2yN1MlfScpnkxGzPWHPHWmwkcop)oT8ixUO94HUrlfDqumYIoVqHZ7rWW4KbCB3GrrzoOyy5voI25fyEvZl487ppc2ezBlkDzr5qcl80yhSjIYie7sKvYX5fkCE(DA5rUCzr5qcl80yhSjIYie7sKvYrhefJSOZlWsj4wE1sHGI90qr6Yw2sXhleM81MRnaAT5sbRWtJYfywkCyAimJLIhbdJJsiLy1L3j6GyWT5vn)(ZZkGz4Prx7D6S87qIk592JmcNxOW5BrZ5hq)RHgDb3sw4sj4wE1srIHbOZVuVS1gnT2CPGv4Pr5cmlfomneMXsHFSWkkZvPpaRZe48QMNFNwEKlNeddaTljqhefJSOZZ(8QDEvZdjQK3BpYi0jrMKN28SppqQFPeClVAPiXWa05xQx2Ad1U2CPGv4Pr5cmlfomneMXsrW5TqJL5KitQrhwHNgLZlu488JfwrzUk9byDMaNxOW5HefYCqF01cad4jEfsDyfEAuoVaZRAEbNF)5zfWm80OR9oDw(DirH05fkCEM0hG1HOyKfDE2NFN5fyPeClVAPevJUSKlBTbBT2CPGv4Pr5cmlfomneMXsHFSWkkZvPpaRZe48QMhsujV3EKrOtImjpT5zF(Mu)8QMF)5zfWm80OR9oDw(DirL8E7rgHlLGB5vlfjggGo)s9YwBSZAZLcwHNgLlWSu4W0qyglf(XcROmxL(aSotGZRAE(DA5rUCsmma0UKaDqumYIop7ZdK6Nx18s0JGHXXGudHz53jFeL0rTGVDE2NNTMx187ppRaMHNgDT3PZYVdjkKoVQ5fC(9NxIHbOhLSlrE0WzjFBw(Zlu48EemmojggaAxsGoQf8TZtAE2AEbwkb3YRwkmi1qyw(DQbZT4YwBSBRnxkyfEAuUaZsHdtdHzSuGevY7Thze6KitYtBE2Nhi1oVqHZZK(aSoefJSOZZ(87mVQ53FEj6rWW4yqQHWS87KpIs6iAxkb3YRwksmmaD(L6LT2yxS2CPGv4Pr5cmlfomneMXsrIEemmogKAiml)o5JOKoQf8TZdI5v78QMF)5zfWm80OR9oDw(DirH0LsWT8QLc5JOKDAlwseUS1gQRRnxkyfEAuUaZsHdtdHzSuKOhbdJJbPgcZYVt(ikPJODEvZZVtlpYLlApEOB0srhefJSODe4BrUHY5bX87mVQ53FEwbmdpn6AVtNLFhsuiDPeClVAPq(ikzN2ILeHlBTbi31MlfScpnkxGzPWHPHWmwkqIk592JmcDsKj5Pnp7Z3K6Nx187ppRaMHNgDT3PZYVdjQK3BpYiCPeClVAPiXWa05xQx2AdGu)AZLcwHNgLlWSu4W0qyglfj6rWW4yqQHWS87KpIs6OwW3op7Zd08QMF)5zfWm80OR9oDw(DirH0LsWT8QLcdsneMLFNAWClUS1gab0AZLcwHNgLlWSu4W0qyglfj6rWW4yqQHWS87KpIs6OwW3op7ZZwZRAE(DA5rUCr7XdDJwk6GOyKfTJaFlYnuop7ZVZ8QMF)5zfWm80OR9oDw(DirH0LsWT8QLcdsneMLFNAWClUS1ga10AZLcwHNgLlWSu4W0qyglL9NNvaZWtJU270z53HevY7ThzeUucULxTuKyya68l1lBzlf(XcROm6AZ1gaT2CPGv4Pr5cmlfomneMXsHvaZWtJoQ1B1rvz5pVQ5HevY7Thze6KitYtBEqmpq728QMxW553PLh5YfThp0nAPOdIIrw05fkC(9N3cnwMlGIn6ht3aGDziwO0Hv4Pr58QMNFNwEKlNmGB7gmkkZbfdlVYbrXil68cmVqHZ7Du68QMNj9byDikgzrNN95bcOLsWT8QLcLCafZYVlMuBzRnAAT5sbRWtJYfywkCyAimJLc)oT8ixUO94HUrlfDqumYIoVQ5fC(GBjlSJfkMiDEqqA(MMx18b3swyhlumr68StA(DMx18qIk592JmcDsKj5PnpiMhi1ppWMxW5dULSWowOyI053LZVBZlW8cfoFWTKf2XcftKopiMFN5vnpKOsEV9iJqNezsEAZdI5zl1pValLGB5vlfk5akMLFxmP2srIuomBT8QLIcAZB38euC(GXq48r7XNpPZF18SnWnFqN3U5BHilSS5pwiKhTTz5p)UwnppzaPgNNIMLL)8eTZZ2axZ0LT2qTRnxkyfEAuUaZsHdtdHzSuyfWm80OJA9wDuvw(ZRA(9NNEeAVSKongYUxJoc8HyRgDyfEAuoVQ5fCE(DA5rUCr7XdDJwk6GOyKfDEHcNF)5TqJL5cOyJ(X0nayxgIfkDyfEAuoVQ553PLh5Yjd42UbJIYCqXWYRCqumYIoVaZRAEirHolfXUDD2AEqmVGZR25b28EemmoirL8o)GqIwlVYbrXil68cmVqHZ7Du68QMNj9byDikgzrNN95BcOLsWT8QLs4DIzfwEvxNIElBTbBT2CPGv4Pr5cmlfomneMXsHvaZWtJoQ1B1rvz5pVQ5PhH2llPtJHS71OJaFi2QrhwHNgLZRAEbNxEMJOaC6gDpD6dW6YZCqumYIopiMhiGMxOW53FEl0yzoIcWPB090PpaZHv4Pr58QMNFNwEKlNmGB7gmkkZbfdlVYbrXil68cSucULxTucVtmRWYR66u0BzRn2zT5sbRWtJYfywkCyAimJLsWTKf2XcftKopiinFtZRAEirHolfXUDD2AEqmVGZR25b28EemmoirL8o)GqIwlVYbrXil68cSucULxTucVtmRWYR66u0BzRn2T1MlfScpnkxGzPWHPHWmwkScygEA0rTERoQkl)5vnVGZZVtlpYLlApEOB0srhefJSOZlu487pVfASmxafB0pMUba7YqSqPdRWtJY5vnp)oT8ixoza32nyuuMdkgwELdIIrw05fyEHcN37O05vnpt6dW6qumYIop7Zd0olLGB5vlfkGGVvJDda2jkYh0a0yzRn2fRnxkyfEAuUaZsHdtdHzSucULSWowOyI05bbP5BAEvZl48smma9OKDjYJgol5BZYFEHcNhgPSJSWYCHusDqumYIop7KMhi2AEbwkb3YRwkuabFRg7gaStuKpObOXYw2sPfI8t0lS1MRnaAT5sj4wE1sP9S8QLcwHNgLlWSS1gnT2CPeClVAPaJKIDjgYLcwHNgLlWSSLTuGbpdnDT5AdGwBUuWk80OCbMLchMgcZyPajQK3BpYi0jrMKN28Gy(DBN5vnVGZ3IMZpG(xdn6cULSW5fkC(9N3cnwMJsikEv3pG(xdn6Wk80OCEbMx18qIcDsKj5Pnpiin)olLGB5vlLaYJc72bHyzlfjs5WS1YRwk76GNHMUS1gnT2CPGv4Pr5cmlfomneMXsHvaZWtJoXqnEWo)oT8ix0EWTKfoVqHZBb0hnNLIy3UUmX5zN08Eemmop9DYodbSHtsadlVAPeClVAP4PVt2ziGnw2Ad1U2CPGv4Pr5cmlfomneMXsHvaZWtJoXqnEWo)oT8ix0EWTKfoVqHZBb0hnNLIy3UUmX5zN08Eemmopesr42S8Dscyy5vlLGB5vlfpesr42S8x2Ad2AT5sbRWtJYfywkCyAimJLIhbdJJOaC6gDQbXY3a4iAxkb3YRwk60hGr7QrcPViw2YwBSZAZLcwHNgLlWSu4W0qyglfwbmdpn6ed14b7870YJCr7b3sw48cfoVfqF0CwkID76YeNNDsZd0olLGB5vlLO4i1GHUZdTEPirkhMTwE1sbKvCKAWqppBhA988OM3GPVpcNNTMV9mSSm0Z7rWWqbFEm4aMxhull)5bAN5Pi)kj1nV6KL6uDgkNhqaLZZpjkN3srC(GoFmVbtFFeoVDZVfX25tBEigYWtJULT2y3wBUuWk80OCbMLchMgcZyPeClzHDSqXePZdcsZ308cfoVGZdjk0jrMKN28GG087mVQ5HevY7Thze6KitYtBEqqA(Dt9ZlWsj4wE1sjG8OWElHMIlBTXUyT5sbRWtJYfywkCyAimJLcRaMHNgDIHA8GD(DA5rUO9GBjlCEHcN3cOpAolfXUDDzIZZoP59iyyCmje903jDscyy5vlLGB5vlfMeIE67KlBTH66AZLcwHNgLlWSu4W0qyglfpcgghrb40n6udILVbWr0oVQ5dULSWowOyI05jnpqlLGB5vlfVWVFmDdM8T0LTSLIpwim594W1MRnaAT5sbRWtJYfywkuKVu43PLh5YrpcDhIrlcDqumYIUucULxTuihPTu4W0qyglfl0yzo6rO7qmArOdRWtJY5vnVfqF0CwkID76TCRR2DMN953zEvZZK(aSoefJSOZdI53zEvZZVtlpYLJEe6oeJwe6GOyKfDE2NxW595Y53LZRE3UyN5fyEvZhClzHDSqXePZZoP5v7YwB00AZLcwHNgLlWSu4W0qyglfbNF)5zfWm80OR9oDw(DirL8E7rgHZlu48EemmokHuIvxENOdIb3MxG5vnVGZ7rWW4KbCB3GrrzoOyy5voI25vnpKOqMd6JojgsDIuRZVu7Wk80OCEvZhClzHDSqXePZZoP5v78cfoFWTKf2XcftKopP5BAEbwkb3YRwksmmaD(L6LT2qTRnxkyfEAuUaZsHdtdHzSu8iyyCucPeRU8orhedUnVqHZV)8ScygEA01ENol)oKOsEV9iJWLsWT8QLc2Msum5lBTbBT2CPGv4Pr5cmlfjs5WS1YRwkQBM5Ta6J288gCDw(ZN05Ljn80Oe85PKtJdyEVGVDE7M3aGZtZYxJQjlG(OnVpwim5ZRtQnFwuddPBPeClVAPajQEWT8QUoP2sHAWKBRnaAPWHPHWmwk8gCn2XcftKopP5bAPOtQ1Rqexk(yHWKVS1g7S2CPGv4Pr5cmlfomneMXsrW553PLh5YfThp0nAPOdIIrw05bX87mVQ5LOhbdJJbPgcZYVt(ikPJODEHcNxIEemmogKAiml)o5JOKoQf8TZdI5v78cmVQ5fCEM0hG1HOyKfDE2NNFNwEKlNeddqpkzxI8OHdIIrw05b28aP(5fkCEM0hG1HOyKfDEqmp)oT8ixUO94HUrlfDqumYIoValLGB5vlfYhrj70wSKiCPWBW1y3cOpA01gaTS1g72AZLcwHNgLlWSu4W0qyglfj6rWW4yqQHWS87KpIs6OwW3op7KMxTZRAE(DA5rUCr7XdDJwk6GOyKfDE2NxTZlu48s0JGHXXGudHz53jFeL0rTGVDE2NhOLsWT8QLcdsneMLFNAWClUu4n4ASBb0hn6AdGw2AJDXAZLcwHNgLlWSu4W0qyglf(DA5rUCr7XdDJwk6GOyKfDEqm)oZRAEj6rWW4yqQHWS87KpIs6OwW3op7Zd0sj4wE1sHbPgcZYVtnyUfxk8gCn2Ta6JgDTbqlBTH66AZLcwHNgLlWSu4W0qyglLGBjlSlpZXGudHz53jFeLCEqqAEEdUg7yHIjsNx18s0JGHXXGudHz53jFeL0rTGVDE2NNTwkb3YRwkmi1qyw(DQbZT4srIuomBT8QLYMas68jDEKHb5wYc1nMNj1AeopzajhW80uKopWPMvMVqcdgAWN3JWMNc4i0Y5BHilSS5J5PCScyEZtgacX5na48HuE18ac681zaYYFE7MhI8tuelPBzlBPirMGqBRnxBa0AZLsWT8QLIywYoder1z4sbRWtJYfyw2AJMwBUuWk80OCbMLY1UuOOTucULxTuyfWm804sHvOjWLIGZJGnr22IsxwuoKWcpn2bBIOmcXUezLCCEvZZVtlpYLllkhsyHNg7GnrugHyxISso6GyiBmValfwbSxHiUuOTipzsu2nywBrBPirkhMTwE1srndrwyzZtBrEYKOCEdM1w0OZ7Hz5ppbfLZtonaZhe2jgwYNxNfsx2Ad1U2CPGv4Pr5cmlLRDPqrBPeClVAPWkGz4PXLcRqtGlf(DA5rUCucrXR6(b0)AOrhefJSOZZ(87mVQ5TqJL5OeIIx19dO)1qJoScpnkxkScyVcrCP0ENol)oKOsEV9iJWLT2GTwBUuWk80OCbMLY1UuOOTucULxTuyfWm804sHvOjWLIfASmh9i0DigTi0Hv4Pr58QMhsu48SpFtZRAElG(O5Sue721B5wxT7mp7ZVZ8QMNj9byDikgzrNheZVZsHva7viIlL270z53Hefsx2AJDwBUuWk80OCbMLY1UuOOTucULxTuyfWm804sHvOjWLsWTKf2XcftKopP5bAEvZl487ppmszhzHL5cPK6qGpPgDEHcNhgPSJSWYCHusDznpiMhODMxGLcRa2RqexkuR3QJQYYFzRn2T1MlfScpnkxGzPCTlfkAlLGB5vlfwbmdpnUuyfAcCP0IMZpG(xdn6cULSW5fkCEpcgghrb40n6bLgeAZr0oVqHZBHglZfqXg9JPBaWUmelu6Wk80OCEvZ3IMlApE3hWrODb3sw48cfoVhbdJtgWTDdgfL5GIHLx5iAxkScyVcrCPigQXd253PLh5I2dULSWLT2yxS2CPGv4Pr5cmlfomneMXsrEMJvcj0yz9wD4tGoiYarkGWtJZRA(9N3cnwMJOaC6gDpD6dWCyfEAuoVQ53FEyKYoYclZfsj1HaFsn6sj4wE1s5impigBxksKYHzRLxTuuxezzrwz5pVAWesOXYMxnRdFcC(KoFmFlmpyAnw2Ad111MlfScpnkxGzPWHPHWmwkYZCSsiHglR3QdFc0brgisbeEACEvZhClzHDSqXePZdcsZ308QMxW53FEl0yzoIcWPB090PpaZHv4Pr58cfop)oT8ixoIcWPB090PpaZbrXil68QM3JGHXruaoDJUNo9byDpcggN8ixZlWsj4wE1s5impigBxk8gCn2Ta6JgDTbqlBTbi31MlfScpnkxGzPeClVAPCeMheJTlfDwyNlxk72srIuomBT8QLI6MzEdacX5diopwOyI05ftknl)5vdQMbF(OTv3y(0MxqpcB(6Mx8G48gGOM)kooFlcNF3MNI8RKubClfomneMXsj4wYc7YZCSsiHglR3QdFcCE2Np4wYc7yHIjsNx18b3swyhlumr68GG08nnVQ5fC(9N3cnwMJOaC6gDpD6dWCyfEAuoVqHZZVtlpYLJOaC6gDpD6dWCqumYIoVQ59iyyCefGt3O7PtFaw3JGHXjpY18cSS1gaP(1MlfScpnkxGzPWHPHWmwkqIczoOp6OeTiKAWilhwHNgLZRAEbNxEMJbEuRZGSqOdImqKci8048cfoV8mNN(ozVvh(eOdImqKci8048cSucULxTuocZdIX2LT2aiGwBUuWk80OCbMLchMgcZyPWpwyfL5Q0hG1zcCEvZlXWa0Js2LipA4cULSWoefJSOZZ(8coVpxo)UCEGC7mVaZRAEjggGEuYUe5rdNL8Tz5VucULxTuiFeLStBXsIWLIePCy2A5vlLDnYarkaKopWHHbGopWrGntN3JGHzE1ib1M3dzoioVeddaDEjbopws6YwBautRnxkyfEAuUaZsHI8Lc)oT8ixo6rO7qmArOdIIrw0LsWT8QLc5iTLchMgcZyPyHglZrpcDhIrlcDyfEAuoVQ5Ta6JMZsrSBxVLBD1UZ8Sp)oZRAElG(O5Sue721LjopiMFN5vnp)oT8ixo6rO7qmArOdIIrw05zFEbN3NlNFxoV6D7IDMxG5vnFWTKf2XcftKopP5bAzRnasTRnxkyfEAuUaZsj4wE1sHCK2sHI8Lc)oT8ixojggaAxsGoikgzrxksKYHzRLxTu2vrAZZCW5bommantNh4iW9aoKj148jZ8BK(aS5vxg482nVpAZtniw(gG59iyyM3l4BNpOr7sHdtdHzSu4hlSIYCv6dW6mboVQ553PLh5YjXWaq7sc0brXil68SpVpxoVQ5dULSWowOyI05jnpqlBTbqS1AZLcwHNgLlWSuOiFPWVtlpYLtImPgDqumYIUucULxTuihPTu4W0qyglf(XcROmxL(aSotGZRAE(DA5rUCsKj1OdIIrw05zFEFUCEvZhClzHDSqXePZtAEGw2AdG2zT5sbRWtJYfywkb3YRwk8qR7b3YR66KAlfjs5WS1YRwkGmULxn)UNuJoFuY5vhTyHq68cQoAXcH09uqWMalosNNOOeTTh0q58znFiLx5eyPOtQ1RqexkgmRTOrx2AdG2T1MlfScpnkxGzPeClVAPWdTUhClVQRtQTu0j16viIlf(XcROm6YwBa0UyT5sbRWtJYfywkb3YRwk8qR7b3YR66KAlfDsTEfI4sbg8m00LT2ai111MlfScpnkxGzPeClVAPWdTUhClVQRtQTuKiLdZwlVAPeClVI6KitqOnGrApkc2eyXrWtgsb3swyhlumrkjGuTVeddqFBL(amNmPHNg7XzsWRqejDTyHqqkGIn6ht3aGDjgsqIbPgcZYVtnyUfbjgKAiml)o1G5weKikaNUr3tN(amqQ9S8kqsgWTDdgfL5GIHLxbsr7XdDJwkUu0j16viIlf(DA5rUOlBTbqGCxBUuWk80OCbMLsWT8QLcKO6b3YR66KAlfomneMXsj4wYc7yHIjsNheKMVP5vnVGZZVtlpYLtIHbOhLSlrE0WbrXil68SppqQFEvZV)8wOXYCsKj1OdRWtJY5fkCE(DA5rUCsKj1OdIIrw05zFEGu)8QM3cnwMtImPgDyfEAuoVaZRA(9NxIHbOhLSlrE0WzjFBw(lfDsTEfI4sjoStrJODzRnAs9RnxkyfEAuUaZsHdtdHzSucULSWowOyI05bbP5BAEvZlXWa0Js2LipA4SKVnl)Lc1Gj3wBa0sj4wE1sbsu9GB5vDDsTLIoPwVcrCPeh29iGuBzRnAcO1MlfScpnkxGzPeClVAPajQEWT8QUoP2sHdtdHzSucULSWowOyI05bbP5BAEvZl487pVeddqpkzxI8OHZs(2S8Nx18cop)oT8ixojggGEuYUe5rdhefJSOZdI5bs9ZRA(9N3cnwMtImPgDyfEAuoVqHZZVtlpYLtImPgDqumYIopiMhi1pVQ5TqJL5KitQrhwHNgLZlW8cSu0j16viIlfFSqyY7XHlBTrtnT2CPGv4Pr5cmlfomneMXsj4wYc7yHIjsNN08aTuOgm52AdGwkb3YRwk8qR7b3YR66KAlfDsTEfI4sXhleM8LTSLc)oT8ix01MRnaAT5sbRWtJYfywkCyAimJLcRaMHNgDIHA8GD(DA5rUO9GBjlCEHcN37O05vnpt6dW6qumYIop7Z30UTucULxTuAplVAzRnAAT5sbRWtJYfywkCyAimJLc)oT8ixoIcWPB090PpaZbrXil68Sp)oZRAE(DA5rUCYaUTBWOOmhumS8khefJSODe4BrUHY5zF(DMx18wOXYCefGt3O7PtFaMdRWtJY5fkC(9N3cnwMJOaC6gDpD6dWCyfEAuoVqHZ7Du68QMNj9byDikgzrNN95v7olLGB5vlLak2OFmDda2Lyix2Ad1U2CPGv4Pr5cmlfomneMXsXcOpAolfXUD9wU1v7oZZ(87mVQ5Ta6JMZsrSBxxM48Gy(DMx18b3swyhlumr68StAE1UucULxTuOhHUdXOfHlfEdUg7wa9rJU2aOLT2GTwBUuWk80OCbMLchMgcZyPWkGz4Prh16T6OQS8Nx18cop)oT8ixUO94HUrlfDqumYI2rGVf5gkNN953zEHcNNFNwEKlx0E8q3OLIoikgzr7iW3ICdLZdI5bs9ZlW8QMxW553PLh5Yjd42UbJIYCqXWYRCqumYIop7Z7ZLZlu48Eemmoza32nyuuMdkgwELJODEbwkb3YRwkefGt3O7PtFa2srIuomBT8QLIAaNwsNhm60hGnpZbNNODE7MFN5Pi)kjDE7MN2O4ZtonaZdYApEOB0srWNxDyaqi5KIGppbfNNCAaMh4c4253egfL5GIHLx5w2AJDwBUuWk80OCbMLchMgcZyPeClzHDSqXePZdcsZ308cfoV3rPZRAEM0hG1HOyKfDE2NVjGwkb3YRwkefGt3O7PtFa2YwBSBRnxkyfEAuUaZsHdtdHzSuyfWm80OJA9wDuvw(ZRAEbNxEMJOaC6gDpD6dW6YZCqumYIoVqHZV)8wOXYCefGt3O7PtFaMdRWtJY5fyPeClVAPid42UbJIYCqXWYRw2AJDXAZLcwHNgLlWSu4W0qyglLGBjlSJfkMiDEqqA(MMxOW59okDEvZZK(aSoefJSOZZ(8nb0sj4wE1srgWTDdgfL5GIHLxTS1gQRRnxkyfEAuUaZsHdtdHzSucULSWowOyI05jnpqZRAEj6rWW4yqQHWS87KpIs6OwW3opiMxTlLGB5vlLO94HUrlfx2AdqURnxkyfEAuUaZsHdtdHzSucULSWowOyI05bbP5BAEvZlrpcgghdsneMLFN8rush1c(25bX8QDEvZV)8smma9OKDjYJgol5BZYFPeClVAPeThp0nAP4sH3GRXUfqF0ORnaAzRnas9RnxkyfEAuUaZsHdtdHzSuGevY7Thze6KitYtBE2Nhi2AEvZl48870YJC5ikaNUr3tN(amhefJSOZZ(8aP(5fkCE5zoIcWPB090PpaRlpZbrXil68cSucULxTuOeIIx19dO)1qJlBTbqaT2CPGv4Pr5cmlfomneMXsHvaZWtJoQ1B1rvz5pVQ5LOhbdJJbPgcZYVt(ikPJAbF78SpFtZRAEbNVfnx0E8UpGJq7cULSW5fkCEpcggNmGB7gmkkZbfdlVYr0oVQ53F(w0CbuSr3hWrODb3sw48cSucULxTuikaNUrpO0GqBlBTbqnT2CPGv4Pr5cmlfomneMXsj4wYc7yHIjsNheKMVP5vnVe9iyyCmi1qyw(DYhrjDul4BNN95BAPeClVAPquaoDJEqPbH2wk8gCn2Ta6JgDTbqlBTbqQDT5sbRWtJYfywkCyAimJLY(Z3IMZhWrODb3sw4sj4wE1sbgjf7smKlBzlBPWcH08Q1gnP(Mas9SfqQDPqoGvw(0LYUcKTR3qDVHAiin)8BcaNpfBpOnpZbNV54WofnI2MNhIGnrcr580teNpiStmmuophqu(i1nGU7zHZRwqAE2(kwi0q58ndjkK5G(OdSAEE7MVzirHmh0hDGLdRWtJYMNxqGaEbCdOdO7kq2UEd19gQHG08ZVjaC(uS9G28mhC(MJd7EeqQ188qeSjsikNNEI48bHDIHHY55aIYhPUb0DplCEGaP5z7RyHqdLZ3mKOqMd6JoWQ55TB(MHefYCqF0bwoScpnkBEEbbc4fWnGoGURaz76nu3BOgcsZp)MaW5tX2dAZZCW5B2GzTfnAZZdrWMiHOCE6jIZhe2jggkNNdikFK6gq39SW5bcKMNTVIfcnuoFZwOXYCGvZZB38nBHglZbwoScpnkBEEbbc4fWnGoGURaz76nu3BOgcsZp)MaW5tX2dAZZCW5B2hleM8MNhIGnrcr580teNpiStmmuophqu(i1nGU7zHZRwqAE2(kwi0q58ndjkK5G(OdSAEE7MVzirHmh0hDGLdRWtJYMNxqGaEbCdOdO7kq2UEd19gQHG08ZVjaC(uS9G28mhC(M5hlSIYOnppebBIeIY5PNioFqyNyyOCEoGO8rQBaD3ZcNhiqAE2(kwi0q58nBHglZbwnpVDZ3SfASmhy5Wk80OS55feiGxa3a6UNfoVAbP5z7RyHqdLZ3SfASmhy1882nFZwOXYCGLdRWtJYMNxqGaEbCdO7Ew48QfKMNTVIfcnuoFZ0Jq7LL0bwnpVDZ3m9i0EzjDGLdRWtJYMNxqGaEbCdO7Ew48SfinpBFfleAOC(MTqJL5aRMN3U5B2cnwMdSCyfEAu288cceWlGBaD3ZcNNTaP5z7RyHqdLZ3m9i0EzjDGvZZB38ntpcTxwshy5Wk80OS55feiGxa3a6UNfo)UbsZZ2xXcHgkNVzl0yzoWQ55TB(MTqJL5alhwHNgLnpVGab8c4gqhq3vGSD9gQ7nudbP5NFta48Py7bT5zo48nZVtlpYfT55HiytKquop9eX5dc7eddLZZbeLpsDdO7Ew48nbsZZ2xXcHgkNVzl0yzoWQ55TB(MTqJL5alhwHNgLnpVGnb8c4gq39SW53nqAE2(kwi0q58nBHglZbwnpVDZ3SfASmhy5Wk80OS55feiGxa3a6a6UcKTR3qDVHAiin)8BcaNpfBpOnpZbNVzFSqyY7XHnppebBIeIY5PNioFqyNyyOCEoGO8rQBaD3ZcNhiqAE2(kwi0q58nBHglZbwnpVDZ3SfASmhy5Wk80OS55feiGxa3a6UNfoFtG08S9vSqOHY5BgsuiZb9rhy1882nFZqIczoOp6alhwHNgLnpVGab8c4gqhq3vGSD9gQ7nudbP5NFta48Py7bT5zo48nlrMGqBnppebBIeIY5PNioFqyNyyOCEoGO8rQBaD3ZcNxTG08S9vSqOHY5B2cnwMdSAEE7MVzl0yzoWYHv4PrzZZh28G8QJDFEbbc4fWnGU7zHZZwG08S9vSqOHY5B2cnwMdSAEE7MVzl0yzoWYHv4PrzZZliqaVaUb0DplC(DdKMNTVIfcnuoFZwOXYCGvZZB38nBHglZbwoScpnkBEEbbc4fWnGU7zHZVlaP5z7RyHqdLZ3SfASmhy1882nFZwOXYCGLdRWtJYMNxqGaEbCdO7Ew48QRG08S9vSqOHY5B2cnwMdSAEE7MVzl0yzoWYHv4PrzZZliqaVaUb0DplCEqUG08S9vSqOHY5B2cnwMdSAEE7MVzl0yzoWYHv4PrzZZliqaVaUb0DplCEGupinpBFfleAOC(MHefYCqF0bwnpVDZ3mKOqMd6JoWYHv4PrzZZliqaVaUb0DplCEGAcKMNTVIfcnuoFZwOXYCGvZZB38nBHglZbwoScpnkBEEbbc4fWnGU7zHZdeixqAE2(kwi0q58nBHglZbwnpVDZ3SfASmhy5Wk80OS55fSjGxa3a6UNfoFtabsZZ2xXcHgkNVzl0yzoWQ55TB(MTqJL5alhwHNgLnpVGnb8c4gqhqv3ITh0q58aP(5dULxnVoPg1nGUuAHhtQXLcByZ8ahggG5vNxPpaBE1PcWPBmGYg2mV6IOX8nb(8nP(MaAaDaLnSzE2gqu(ifKgqzdBMxnnpitQgjOMiwgDE7Mh4kGBpGdzsnUhWHHbGopWrGZB38xPBmp)ikBElG(OrNNmGB(aIZJaFlYnuoVDZRtw486R8NhRJWhW82nVyygcNxW4WofnI25zdqc4gqzdBMxnnpWL0WtJY5vcomzsEg65vZb3M3d5bbfNxIHCEFahHMoVySfNN5GZtd58aN6CQBaLnSzE108Qt0S8NFxDeLCELwSKiC(Wl1PLiDEXdIZZOrGp90nMxWWMNTa28ul4BPZNf1Wqo)Xm)oata1aNh4uZkZxiHbd98rjNxmAmFlezHLnp9eX5Rtnbr(800iclVI6gqzdBMxnnV6enl)5vxIudHz5pVIbZT48znpitDaYpFYmFJJyEablC(6maz5ppQP482nV8Mpk58KVQzB(Jfc5r78KpIssNpPZdCQzL5lKWGH2nGYg2mVAAE2gqu(OCEXOAmFZmPpaRdrXilAZZZVsMwEvOPZB38rBRUX8znV3rPZZK(am68xPBmVGAKsNNTbU5jhudN)Q5nyqbiGBaLnSzE108GmPeLZh1zaq48QdcZdIX25XYGnM3U5POnpr78udELpcNhKVnLOyYPUbu2WM5vtZVP6a4uhG08ZVbsEEdM1w0MNdtdHz4gqhqdULxrDTqKFIEHbms71EwE1aAWT8kQRfI8t0lmGrApyKuSlXqoGYg2mpipRqtegsNpM3GzTfn68870YJCb(8YKvkr58EnMNT2Xn)Mas68Kd68CahfR5d68efGt3yEYhClD(RMNT2zEkYVsoVhbKAZZBW1if859iS5be05T7MxmQgZZLW5rggKB05TBE)KfoFmp)oT8ixoG3jjGHLxnVmzL0doFwuddPBE1nZ8P1mDEwHMaNhqqNVU5HOyKLeHZdrJawZde4ZJAkopencynV6D74gqzdBMp4wEf11cr(j6fgWiThRaMHNgbVcrKKbZAlADG60gfh8RLefTKbCwHMajbe4Scnb2rnfjPE3oGZVsMwEfjdM1w0Ca5ae0obf7EemmQe0GzTfnhqo(DA5rUCscyy5vGCa5Ww7qs9cmGYg2mFWT8kQRfI8t0lmGrApwbmdpncEfIijdM1w06n1Pnko4xljkAjd4ScnbsciWzfAcSJAkss9UDaNFLmT8ksgmRTO5AYbiODck29iyyujObZAlAUMC870YJC5KeWWYRa5aYHT2HK6fyaLnSzEqEQLIHH05J5nywBrJopRqtGZ71yE(j2gWS8N3aGZZVtlpY18hZ8gaCEdM1w0aFEzYkLOCEVgZBaW5LeWWYRM)yM3aGZ7rWWmFAZ3cpwPePU5vdiOZhZtniw(gG5fpzYKiCE7M3pzHZhZdi9bGW5BH5btRX82np1Gy5BaM3GzTfnk4Zh05jJA98bD(yEXtMmjcNN5GZNmZhZBWS2I28KtTE(dop5uRNVoBEAJIpp50amp)oT8ixu3akByZ8b3YROUwiYprVWagP9yfWm80i4viIKmywBrR3cZdMwdWVwsu0sgWzfAcKutGZk0eyh1uKeqGZVsMwEfP9nywBrZbKdqq7euS7rWWOYGzTfnxtoabTtqXUhbdJqHgmRTO5AYbiODck29iyyujOGgmRTO5AYXVtlpYLtsadlVcKJbZAlAUMCTWJ7IQrx2sDscyy5vcSlfei3oaZGzTfnxtoabT7rWWiWUuqwbmdpn6mywBrR3uN2O4ciaieuqdM1w0Ca543PLh5YjjGHLxbYXGzTfnhqUw4XDr1OlBPojbmS8kb2LccKBhGzWS2IMdihGG29iyyeyxkiRaMHNgDgmRTO1bQtBuCbeyaDaDaLnSzEqEGh5egkNhzHWgZBPioVbaNp42bNpPZhSIuhEA0nGgClVIssmlzNbIO6mCaLnZRMHilSS5PTipzsuoVbZAlA059WS8NNGIY5jNgG5dc7edl5ZRZcPdOb3YROaJ0EScygEAe8kers0wKNmjk7gmRTOboRqtGKeebBISTfLUSOCiHfEASd2erzeIDjYk5Ok(DA5rUCzr5qcl80yhSjIYie7sKvYrhedzdbgqzdBMxnyaZWtJ0b0GB5vuGrApwbmdpncEfIiP270z53HevY7ThzecoRqtGK43PLh5YrjefVQ7hq)RHgDqumYIY(oQSqJL5OeIIx19dO)1qJdOb3YROaJ0EScygEAe8kersT3PZYVdjkKcoRqtGKSqJL5OhHUdXOfHQGefYEtQSa6JMZsrSBxVLBD1Ud77OIj9byDikgzrbXodOb3YROaJ0EScygEAe8kersuR3QJQYYhCwHMajfClzHDSqXePKasLG7dJu2rwyzUqkPoe4tQrfkegPSJSWYCHusDzbcG2rGb0GB5vuGrApwbmdpncEfIijXqnEWo)oT8ix0EWTKfcoRqtGKArZ5hq)RHgDb3swOqHEemmoIcWPB0dkni0MJOvOql0yzUak2OFmDda2LHyHsvTO5I2J39bCeAxWTKfkuOhbdJtgWTDdgfL5GIHLx5iAhqzZ8QlISSiRS8Nxnycj0yzZRM1HpboFsNpMVfMhmTgdOb3YROaJ0EhH5bXyl4jdj5zowjKqJL1B1Hpb6GidePacpnQAFl0yzoIcWPB090Ppat1(WiLDKfwMlKsQdb(KA0b0GB5vuGrAVJW8GySfCEdUg7wa9rJsciWtgsYZCSsiHglR3QdFc0brgisbeEAuvWTKf2XcftKccsnPsW9TqJL5ikaNUr3tN(amHc53PLh5YruaoDJUNo9byoikgzrv5rWW4ikaNUr3tN(aSUhbdJtEKlbgqzZ8QBM5naieNpG48yHIjsNxmP0S8NxnOAg85J2wDJ5tBEb9iS5RBEXdIZBaIA(R448TiC(DBEkYVssfWnGgClVIcms7DeMheJTGRZc7CjPDd8KHuWTKf2LN5yLqcnwwVvh(ei7b3swyhlumrQQGBjlSJfkMifeKAsLG7BHglZruaoDJUNo9bycfYVtlpYLJOaC6gDpD6dWCqumYIQYJGHXruaoDJUNo9byDpcggN8ixcmGgClVIcms7DeMheJTGNmKGefYCqF0rjAri1GrwQeuEMJbEuRZGSqOdImqKci80OqHYZCE67K9wD4tGoiYarkGWtJcmGYM531idePaq68ahgga68ahb2mDEpcgM5vJeuBEpK5G48smma05Le48yjPdOb3YROaJ0EKpIs2PTyjri4jdj(XcROmxL(aSotGQKyya6rj7sKhnCb3swyhIIrwu2f0Nl3La52ravsmma9OKDjYJgol5BZYFan4wEffyK2JCKg4uKtIFNwEKlh9i0DigTi0brXilk4jdjl0yzo6rO7qmArOklG(O5Sue721B5wxT7W(oQSa6JMZsrSBxxMii2rf)oT8ixo6rO7qmArOdIIrwu2f0Nl3LQ3Tl2ravb3swyhlumrkjGgqzZ87QiT5zo48ahggGMPZdCe4EahYKAC(Kz(nsFa28QldCE7M3hT5PgelFdW8EemmZ7f8TZh0ODan4wEffyK2JCKg4uKtIFNwEKlNeddaTljqhefJSOGNmK4hlSIYCv6dW6mbQIFNwEKlNeddaTljqhefJSOS7ZLQcULSWowOyIusanGgClVIcms7rosdCkYjXVtlpYLtImPgDqumYIcEYqIFSWkkZvPpaRZeOk(DA5rUCsKj1OdIIrwu295svb3swyhlumrkjGgqzZ8GmULxn)UNuJoFuY5vhTyHq68cQoAXcH09uqWMalosNNOOeTTh0q58znFiLx5eyan4wEffyK2JhADp4wEvxNud8kersgmRTOrhqdULxrbgP94Hw3dULx11j1aVcrKe)yHvugDan4wEffyK2JhADp4wEvxNud8kersWGNHMoGYM5dULxrbgP9OiytGfhbpzifClzHDSqXePKas1(smma9Tv6dWCYKgEAShNjbVcrK01IfcbPak2OFmDda2LyibjgKAiml)o1G5weKyqQHWS87udMBrqIOaC6gDpD6dWaP2ZYRajza32nyuuMdkgwEfifThp0nAP4aAWT8kkWiThp06EWT8QUoPg4viIK43PLh5IoGgClVIcms7bjQEWT8QUoPg4viIKId7u0iAbpzifClzHDSqXePGGutQeKFNwEKlNeddqpkzxI8OHdIIrwu2bs9Q23cnwMtImPgfkKFNwEKlNezsn6GOyKfLDGuVkl0yzojYKAuav7lXWa0Js2LipA4SKVnl)b0GB5vuGrApir1dULx11j1aVcrKuCy3JasnWPgm5gjGapzifClzHDSqXePGGutQKyya6rj7sKhnCwY3ML)aAWT8kkWiThKO6b3YR66KAGxHisYhleM8ECi4jdPGBjlSJfkMifeKAsLG7lXWa0Js2LipA4SKVnlFvcYVtlpYLtIHbOhLSlrE0WbrXilkias9Q23cnwMtImPgfkKFNwEKlNezsn6GOyKffeaPEvwOXYCsKj1OacmGgClVIcms7XdTUhClVQRtQbEfIijFSqyYbNAWKBKac8KHuWTKf2XcftKscOb0bu2WM5bzhi)8GHasTb0GB5vuxCy3JasnssmmaD(LAWtgsc6rWW4OesjwD5DIoigCtOW9zfWm80OR9oDw(DirL8E7rgHcOsqpcggNmGB7gmkkZbfdlVYr0QcsuiZb9rNedPorQ15xQvfClzHDSqXePStsTcfgClzHDSqXePKAsGb0GB5vuxCy3JasnGrApSnLOyYbpzibjQK3BpYi0jrMKNg7ccK6bMeddqFBL(amhd5JOKOSBb0hn6UuTcOsIHbOVTsFaMJH8rusu2Ta6JgL9Dt1(ScygEA01ENol)oKOsEV9iJqHc9iyyCuYbuml)Uysnhr7aAWT8kQloS7raPgWiTh2Msum5GNmKGevY7Thze6KitYtJ9M2rLeddqFBL(amhd5JOKOSBb0hnki2r1(ScygEA01ENol)oKOsEV9iJWb0GB5vuxCy3JasnGrApSnLOyYbpziTVeddqFBL(amhd5JOKOSBb0hnQQ9zfWm80OR9oDw(DirL8E7rgHcfYK(aSoefJSOSVJqHWiLDKfwMlKsQdb(KAuvWiLDKfwMlKsQdIIrwu23zan4wEf1fh29iGudyK2J8ruYoTfljchqdULxrDXHDpci1agP9W2uIIjh8KH0(ScygEA01ENol)oKOsEV9iJWb0bu2WM5bzhi)8kOr0oGgClVI6Id7u0iAjfvJUSKGNmKKyya6BR0hG5yiFeLeLDlG(OrbbjEdUg7yHIjsfkegPSJSWYCHusDiWNuJQcgPSJSWYCHusDqumYIYojGaAan4wEf1fh2POr0cms7fvJUSKGNmKKyya6BR0hG5yiFeLeLDlG(OrbbPDgqdULxrDXHDkAeTaJ0EsmmaD(LAWtgs7ZkGz4Prx7D6S87qIk592JmcvjOhbdJtgWTDdgfL5GIHLx5iAvbjkK5G(OtIHuNi168l1QcULSWowOyIu2jPwHcdULSWowOyIusnjWaAWT8kQloStrJOfyK2dBtjkMCWtgs7ZkGz4Prx7D6S87qIk592JmchqdULxrDXHDkAeTaJ0Emi1qyw(DQbZTi48gCn2Ta6JgLeqGNmKKOhbdJJbPgcZYVt(ikPJAbFl7KuRk(DA5rUCr7XdDJwk6GOyKfLD1oGgClVI6Id7u0iAbgP9yqQHWS87udMBrW5n4ASBb0hnkjGapzijrpcgghdsneMLFN8rush1c(w2bAan4wEf1fh2POr0cms7XGudHz53Pgm3IGZBW1y3cOpAusabEYqsIEemmogKAiml)o5JOKoQf8TStsTQGef6Sue721zl253PLh5YfvJUSKoikgzrhqzZ87kaynVfqF0MNsoAPZhqCEzsdpnkbFEdqsNNCQ1ZRrB(ghX80wSKZdjkKUh5JOK05ZIAyiN)yMNCKww(ZZCW5bUc42d4qMuJ7bCyyaAMopWrGUb0GB5vuxCyNIgrlWiTh5JOKDAlwsecEYqsW9POzz5tD8gCnkuOeddqFBL(amhd5JOKOSBb0hnkiiXBW1yhlumrQaQKOhbdJJbPgcZYVt(ikPJAbFliuRkirHolfXUDD1Yo)oT8ixUOA0LL0brXil6a6akByZ8Q5ZYRgqdULxrD870YJCrj1EwEf4jdjwbmdpn6ed14b7870YJCr7b3swOqHEhLQIj9byDikgzrzVPDBaLnSzE2(oT8ix0b0GB5vuh)oT8ixuGrAVak2OFmDda2LyibpziXVtlpYLJOaC6gDpD6dWCqumYIY(oQ43PLh5Yjd42UbJIYCqXWYRCqumYI2rGVf5gkzFhvwOXYCefGt3O7PtFaMqH7BHglZruaoDJUNo9bycf6DuQkM0hG1HOyKfLD1UZaAWT8kQJFNwEKlkWiTh9i0DigTieCEdUg7wa9rJsciWtgswa9rZzPi2TR3YTUA3H9Duzb0hnNLIy3UUmrqSJQGBjlSJfkMiLDsQDaLnZRgWPL05bJo9byZZCW5jAN3U53zEkYVssN3U5Pnk(8KtdW8GS2Jh6gTue85vhgaesoPi4ZtqX5jNgG5bUaUD(nHrrzoOyy5vUb0GB5vuh)oT8ixuGrApIcWPB090Ppad8KHeRaMHNgDuR3QJQYYxLG870YJC5I2Jh6gTu0brXilAhb(wKBOK9DekKFNwEKlx0E8q3OLIoikgzr7iW3ICdLGai1lGkb53PLh5Yjd42UbJIYCqXWYRCqumYIYUpxkuOhbdJtgWTDdgfL5GIHLx5iAfyan4wEf1XVtlpYffyK2JOaC6gDpD6dWapzifClzHDSqXePGGutcf6DuQkM0hG1HOyKfL9MaAan4wEf1XVtlpYffyK2tgWTDdgfL5GIHLxbEYqIvaZWtJoQ1B1rvz5Rsq5zoIcWPB090PpaRlpZbrXilQqH7BHglZruaoDJUNo9bycmGgClVI643PLh5Icms7jd42UbJIYCqXWYRapzifClzHDSqXePGGutcf6DuQkM0hG1HOyKfL9MaAan4wEf1XVtlpYffyK2lApEOB0srWtgsb3swyhlumrkjGujrpcgghdsneMLFN8rush1c(wqO2b0GB5vuh)oT8ixuGrAVO94HUrlfbN3GRXUfqF0OKac8KHuWTKf2XcftKccsnPsIEemmogKAiml)o5JOKoQf8TGqTQ2xIHbOhLSlrE0WzjFBw(dOb3YROo(DA5rUOaJ0EucrXR6(b0)AOrWtgsqIk592JmcDsKj5PXoqSLkb53PLh5YruaoDJUNo9byoikgzrzhi1luO8mhrb40n6E60hG1LN5GOyKfvGb0GB5vuh)oT8ixuGrApIcWPB0dkni0g4jdjwbmdpn6OwVvhvLLVkj6rWW4yqQHWS87KpIs6OwW3YEtQeSfnx0E8UpGJq7cULSqHc9iyyCYaUTBWOOmhumS8khrRQ9BrZfqXgDFahH2fClzHcmGgClVI643PLh5Icms7ruaoDJEqPbH2aN3GRXUfqF0OKac8KHuWTKf2XcftKccsnPsIEemmogKAiml)o5JOKoQf8TS30aAWT8kQJFNwEKlkWiThmsk2LyibpziTFlAoFahH2fClzHdOSHnZdCjn80Oe85vJeuB(6S5HyO1nMVoOyON3dbeSYdoVbiSMPZt(GgG5BjGuIS8Npl1KFiIUbu2WM5dULxrD870YJCrbgP9ObhMmjpdDVn4g4jdPGBjlSJfkMifeKAs1(Eemmoza32nyuuMdkgwELJOv1(870YJC5KbCB3GrrzoOyy5voigYgcf6DuQkM0hG1HOyKfLDFUCaDaLnSzE2(yHvu28GmVuNwI0b0GB5vuh)yHvugLeLCafZYVlMud8KHeRaMHNgDuR3QJQYYxfKOsEV9iJqNezsEAGaODtLG870YJC5I2Jh6gTu0brXilQqH7BHglZfqXg9JPBaWUmeluQIFNwEKlNmGB7gmkkZbfdlVYbrXilQacf6DuQkM0hG1HOyKfLDGaAaLnZRG282npbfNpymeoF0E85t68xnpBdCZh05TB(wiYclB(Jfc5rBBw(ZVRvZZtgqQX5POzz5ppr78SnW1mDan4wEf1XpwyfLrbgP9OKdOyw(DXKAGNmK43PLh5YfThp0nAPOdIIrwuvcgClzHDSqXePGGutQcULSWowOyIu2jTJkirL8E7rgHojYK80abqQhycgClzHDSqXeP7YDtaHcdULSWowOyIuqSJkirL8E7rgHojYK80abBPEbgqdULxrD8JfwrzuGrAVW7eZkS8QUof9apziXkGz4Prh16T6OQS8vTp9i0EzjDAmKDVgDe4dXwnQsq(DA5rUCr7XdDJwk6GOyKfvOW9TqJL5cOyJ(X0nayxgIfkvXVtlpYLtgWTDdgfL5GIHLx5GOyKfvavqIcDwkID76SfieuTaZJGHXbjQK35hes0A5voikgzrfqOqVJsvXK(aSoefJSOS3eqdOb3YROo(XcROmkWiTx4DIzfwEvxNIEGNmKyfWm80OJA9wDuvw(QOhH2llPtJHS71OJaFi2QrvckpZruaoDJUNo9byD5zoikgzrbbqaju4(wOXYCefGt3O7PtFaMk(DA5rUCYaUTBWOOmhumS8khefJSOcmGgClVI64hlSIYOaJ0EH3jMvy5vDDk6bEYqk4wYc7yHIjsbbPMubjk0zPi2TRZwGqq1cmpcgghKOsENFqirRLx5GOyKfvGb0GB5vuh)yHvugfyK2Jci4B1y3aGDII8bnanapziXkGz4Prh16T6OQS8vji)oT8ixUO94HUrlfDqumYIku4(wOXYCbuSr)y6gaSldXcLQ43PLh5Yjd42UbJIYCqXWYRCqumYIkGqHEhLQIj9byDikgzrzhODgqdULxrD8JfwrzuGrApkGGVvJDda2jkYh0a0a8KHuWTKf2XcftKccsnPsqjggGEuYUe5rdNL8Tz5luimszhzHL5cPK6GOyKfLDsaXwcmGoGYg2mVsw(AC(ndOpAdOb3YROoFSqyYjjXWa05xQbpzi5rWW4OesjwD5DIoigCt1(ScygEA01ENol)oKOsEV9iJqHcBrZ5hq)RHgDb3sw4aAWT8kQZhleMCGrApjggGo)sn4jdj(XcROmxL(aSotGQ43PLh5YjXWaq7sc0brXilk7QvfKOsEV9iJqNezsEASdK6hqdULxrD(yHWKdms7fvJUSKGNmKe0cnwMtImPgDyfEAukui)yHvuMRsFawNjqHcHefYCqF01cad4jEfsfqLG7ZkGz4Prx7D6S87qIcPcfYK(aSoefJSOSVJadOb3YROoFSqyYbgP9Kyya68l1GNmK4hlSIYCv6dW6mbQcsujV3EKrOtImjpn2Bs9Q2NvaZWtJU270z53HevY7ThzeoGgClVI68XcHjhyK2JbPgcZYVtnyUfbpziXpwyfL5Q0hG1zcuf)oT8ixojggaAxsGoikgzrzhi1RsIEemmogKAiml)o5JOKoQf8TSZwQ2NvaZWtJU270z53Hefsvj4(smma9OKDjYJgol5BZYxOqpcggNeddaTljqh1c(wsSLadOb3YROoFSqyYbgP9Kyya68l1GNmKGevY7Thze6KitYtJDGuRqHmPpaRdrXilk77OAFj6rWW4yqQHWS87KpIs6iAhqdULxrD(yHWKdms7r(ikzN2ILeHGNmKKOhbdJJbPgcZYVt(ikPJAbFliuRQ9zfWm80OR9oDw(DirH0b0GB5vuNpwim5aJ0EKpIs2PTyjri4jdjj6rWW4yqQHWS87KpIs6iAvXVtlpYLlApEOB0srhefJSODe4BrUHsqSJQ9zfWm80OR9oDw(DirH0b0GB5vuNpwim5aJ0EsmmaD(LAWtgsqIk592JmcDsKj5PXEtQx1(ScygEA01ENol)oKOsEV9iJWb0GB5vuNpwim5aJ0Emi1qyw(DQbZTi4jdjj6rWW4yqQHWS87KpIs6OwW3YoqQ2NvaZWtJU270z53HefshqdULxrD(yHWKdms7XGudHz53Pgm3IGNmKKOhbdJJbPgcZYVt(ikPJAbFl7SLk(DA5rUCr7XdDJwk6GOyKfTJaFlYnuY(oQ2NvaZWtJU270z53HefshqdULxrD(yHWKdms7jXWa05xQbpziTpRaMHNgDT3PZYVdjQK3BpYiCaDaLnSzE1qSqyYNhKDG8ZRMH5btRXaAWT8kQZhleM8ECijYrAGtroj(DA5rUC0Jq3Hy0IqhefJSOGNmKSqJL5OhHUdXOfHQSa6JMZsrSBxVLBD1Ud77OIj9byDikgzrbXoQ43PLh5YrpcDhIrlcDqumYIYUG(C5Uu9UDXocOk4wYc7yHIjszNKAhqdULxrD(yHWK3JdbgP9Kyya68l1GNmKeCFwbmdpn6AVtNLFhsujV3EKrOqHEemmokHuIvxENOdIb3eqLGEemmoza32nyuuMdkgwELJOvfKOqMd6JojgsDIuRZVuRk4wYc7yHIjszNKAfkm4wYc7yHIjsj1KadOb3YROoFSqyY7XHaJ0EyBkrXKdEYqYJGHXrjKsS6Y7eDqm4MqH7ZkGz4Prx7D6S87qIk592JmchqzZ8QBM5Ta6J288gCDw(ZN05Ljn80Oe85PKtJdyEVGVDE7M3aGZtZYxJQjlG(OnVpwim5ZRtQnFwuddPBan4wEf15JfctEpoeyK2dsu9GB5vDDsnWRqej5Jfcto4udMCJeqGNmK4n4ASJfkMiLeqdOb3YROoFSqyY7XHaJ0EKpIs2PTyjri48gCn2Ta6JgLeqGNmKeKFNwEKlx0E8q3OLIoikgzrbXoQKOhbdJJbPgcZYVt(ikPJOvOqj6rWW4yqQHWS87KpIs6OwW3cc1kGkbzsFawhIIrwu253PLh5YjXWa0Js2LipA4GOyKffyaPEHczsFawhIIrwuqWVtlpYLlApEOB0srhefJSOcmGgClVI68XcHjVhhcms7XGudHz53Pgm3IGZBW1y3cOpAusabEYqsIEemmogKAiml)o5JOKoQf8TStsTQ43PLh5YfThp0nAPOdIIrwu2vRqHs0JGHXXGudHz53jFeL0rTGVLDGgqdULxrD(yHWK3JdbgP9yqQHWS87udMBrW5n4ASBb0hnkjGapziXVtlpYLlApEOB0srhefJSOGyhvs0JGHXXGudHz53jFeL0rTGVLDGgqzZ8BciPZN05rggKBjlu3yEMuRr48KbKCaZttr68aNAwz(cjmyObFEpcBEkGJqlNVfISWYMpMNYXkG5npzaieN3aGZhs5vZdiOZxNbil)5TBEiYprrSKUb0GB5vuNpwim594qGrApgKAiml)o1G5we8KHuWTKf2LN5yqQHWS87KpIsccs8gCn2XcftKQsIEemmogKAiml)o5JOKoQf8TSZwdOdOSz(DDWZqthqdULxrDWGNHMskG8OWUDqiwg4jdjirL8E7rgHojYK80aXUTJkbBrZ5hq)RHgDb3swOqH7BHglZrjefVQ7hq)RHgDyfEAukGkirHojYK80abPDgqdULxrDWGNHMcms75PVt2ziGnapziXkGz4PrNyOgpyNFNwEKlAp4wYcfk0cOpAolfXUDDzIStYJGHX5PVt2ziGnCscyy5vdOb3YROoyWZqtbgP98qifHBZYh8KHeRaMHNgDIHA8GD(DA5rUO9GBjluOqlG(O5Sue721LjYojpcggNhcPiCBw(ojbmS8Qb0GB5vuhm4zOPaJ0E60hGr7QrcPViwg4jdjpcgghrb40n6udILVbWr0oGYM5bzfhPgm0ZZ2HwpppQ5ny67JW5zR5Bpdlld98EemmuWNhdoG51b1YYFEG2zEkYVssDZRozPovNHY5beq588tIY5TueNpOZhZBW03hHZB38BrSD(0MhIHm80OBan4wEf1bdEgAkWiTxuCKAWq35HwdEYqIvaZWtJoXqnEWo)oT8ix0EWTKfkuOfqF0CwkID76YezNeq7mGgClVI6GbpdnfyK2lG8OWElHMIGNmKcULSWowOyIuqqQjHcfesuOtImjpnqqAhvqIk592JmcDsKj5Pbcs7M6fyan4wEf1bdEgAkWiThtcrp9DsWtgsScygEA0jgQXd253PLh5I2dULSqHcTa6JMZsrSBxxMi7K8iyyCmje903jDscyy5vdOb3YROoyWZqtbgP98c)(X0nyY3sbpzi5rWW4ikaNUrNAqS8naoIwvb3swyhlumrkjGgqhqzdBMFtywBrJoGgClVI6mywBrJsIGI90qrWRqejLfLdjSWtJDWMikJqSlrwjhbpziji)oT8ixoIcWPB090PpaZbrXilQqH870YJC5KbCB3GrrzoOyy5voikgzrfqLGTO5cOyJUpGJq7cULSqHcBrZfThV7d4i0UGBjlu1(wOXYCbuSr)y6gaSldXcLcfAb0hnNLIy3UEl36nPE23raHc9okvft6dW6qumYIYEtanGgClVI6mywBrJcms7rqXEAOi4viIKedE4bXofaIwxKGMCWtgs870YJC5I2Jh6gTu0brXilk77OsW9rWMiBBrPllkhsyHNg7GnrugHyxISsokui)oT8ixUSOCiHfEASd2erzeIDjYk5OdIIrwubek07OuvmPpaRdrXilk7nb0aAWT8kQZGzTfnkWiThbf7PHIGxHisscXqYKqSZcPuudEYqIFNwEKlx0E8q3OLIoikgzrvj4(iytKTTO0LfLdjSWtJDWMikJqSlrwjhfkKFNwEKlxwuoKWcpn2bBIOmcXUezLC0brXilQacf6DuQkM0hG1HOyKfLD1oGgClVI6mywBrJcms7rqXEAOi4viIKKbCR4DvxI8TDwhm4P1a8KHe)oT8ixUO94HUrlfDqumYIQsW9rWMiBBrPllkhsyHNg7GnrugHyxISsokui)oT8ixUSOCiHfEASd2erzeIDjYk5OdIIrwubek07OuvmPpaRdrXilk7nb0aAWT8kQZGzTfnkWiThbf7PHIuWtgscYVtlpYLlApEOB0srhefJSOcf6rWW4KbCB3GrrzoOyy5voIwbuj4(iytKTTO0LfLdjSWtJDWMikJqSlrwjhfkKFNwEKlxwuoKWcpn2bBIOmcXUezLC0brXilQadOSHnZVP6a4uhG0akByZ8BcaN3GzTfT5jNgG5na48asFai1MhPwkggkNNvOjqWNNCQ1Z7HZtqr58mjKAZhLC(2iHOCEYPbyEqw7XdDJwkoVGjZ8EemmZN05bAN5Pi)kjD(doVgPubM)GZdgD6dW2d42CEbtM59HyyiCEdquZd0oZtr(vsQadOSHnZhClVI6mywBrJcms7rqXEAOi4u9zKmywBrdiWtgs7ZkGz4PrhTf5jtIYUbZAlAQeuqdM1w0Ca5AHh3fvJUSL6KeWWYRyNeq7OIFNwEKlx0E8q3OLIoikgzrbrtQxOqdM1w0Ca5AHh3fvJUSL6KeWWYRabq7Osq(DA5rUCefGt3O7PtFaMdIIrwuq0K6fkKFNwEKlNmGB7gmkkZbfdlVYbrXilkiAs9ciGkb33GzTfnxtoabTZVtlpYLqHgmRTO5AYXVtlpYLdIIrwuHczfWm80OZGzTfTElmpyAnibKaciuObZAlAoGCTWJ7IQrx2sDscyy5vGGet6dW6qumYIoGYg2mFWT8kQZGzTfnkWiThbf7PHIGt1NrYGzTfTMapziTpRaMHNgD0wKNmjk7gmRTOPsqbnywBrZ1KRfECxun6YwQtsadlVIDsaTJk(DA5rUCr7XdDJwk6GOyKffenPEHcnywBrZ1KRfECxun6YwQtsadlVceaTJkb53PLh5YruaoDJUNo9byoikgzrbrtQxOq(DA5rUCYaUTBWOOmhumS8khefJSOGOj1lGaQeCFdM1w0Ca5ae0o)oT8ixcfAWS2IMdih)oT8ixoikgzrfkKvaZWtJodM1w06TW8GP1GutciGqHgmRTO5AY1cpUlQgDzl1jjGHLxbcsmPpaRdrXil6akByZ8QBM5Vs3y(RW5VAEckoVbZAlAZ3cpwPePZhZ7rWWa(8euCEdao)zaq48xnp)oT8ixU5vhW5tM5lmnaiCEdM1w0MVfESsjsNpM3JGHb85jO48ENby(RMNFNwEKl3akByZ8b3YROodM1w0OaJ0EeuSNgkcovFgjdM1w0ac8KH0(gmRTO5aYbiODck29iyyujObZAlAUMC870YJC5GOyKfvOW9nywBrZ1Kdqq7euS7rWWiWakByZ8b3YROodM1w0OaJ0EeuSNgkcovFgjdM1w0Ac8KH0(gmRTO5AYbiODck29iyyujObZAlAoGC870YJC5GOyKfvOW9nywBrZbKdqq7euS7rWWiWsjimahCPOKIe6WYRyByWylBzRf]] )


end
