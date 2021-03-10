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
        
        if Hekili.ActiveDebug then debugstr = format( "Runic Corruption expired; updating regen from %.2f to %.2f.", rune.cooldown, rune.cooldown * 2 ) end
        rune.cooldown = rune.cooldown * 2

        for i = 1, 6 do
            local exp = rune.timeTo( i )

            if exp > 0 then                
                rune.expiry[ i ] = rune.expiry[ i ] + exp
                if Hekili.ActiveDebug then debugstr = format( "%s\n - rune %d extended by %.2f.", debugstr, i, exp ) end
            end
        end

        forecastResources( "runes" )
        if debugstr then Hekili:Debug( debugstr ) end
    end, state )

    spec:RegisterHook( "reset_precast", function ()
        if buff.runic_corruption.up then
            state:QueueAuraExpiration( "ca_inc", ExpireRunicCorruption, buff.runic_corruption.expires )
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


    spec:RegisterPack( "Unholy", 20210310, [[dav54bqifvEeQGlbKq2ej5tuQmkujNcv0QqeQELIQMfI0TOuuLDrXVuuAykkCmaAzuk9muHMgLcUMIOTbKOVrPiACiIsNJsrsRda17asOAEOsDpGAFaWbreYcbs9qkfAIicUiLIuFerumsGekNearReiEjLIGzcG0nPuKyNuQ6NukkdfrOSuGe8usmvfHRsPOYwPuuvFfaHXcK0Ev4VsmyvDyQwmL8yctMOldTzu6ZsQrdOtlA1iIQxRinBsDBu1UL63QmCj54iISCqphPPlCDe2ok67iQXROOZtsTEkfHMpkSFLEa4yIHI0dCyVTZWwaNbhbCggajzbeWj54qjuxHdLkxm1RXHs784qXMRbEA1dLkxT(C5yIHc9iGcCOamIkkap7S1zaKWYio(zPjpH2J8Ab0zJzPjVy2HIfrQdaYEynuKEGd7TDg2c4m4iGZWaijlGao5qHwHIH92oPTdfGPuI9WAOirQyOqcOha33MqN1aJ9T5AGNw9cInfhkaUpGZG09TDg2c4cYccjssYjObp2bD)42NeAsywsaztnoljGEaKUpjqG7h3(xRvVV4i6y)WH1yq3NmWBFhI7JZScfbk3pU91jtCF9117J9rudC)42N3JaH7ZLFyHIbr1(CaqonliKqsDlnk3xXfWKnfPR3NeZfX(wOWjO4(s0L7xd8i00959P4(ShCFQl3NeSjqnli2C0SR3hG4iA5(kvylr4(UvQZir6(8he3NvJZmT0Q3Nlp23gMFFA4IP09ZMgOl3)y3FY55eu89jbsmL9BKiGUEFVL7Z7Q3VcImXo2NE84(9zZdII9Pzq4rEn1SGyJa9UgL7Z7T69TJnRbgfiY7ztTBFX1YmYRDnD)423RQ0Q3p79TokDF2Sgyq3)AT695sJu6(2ijSpzNg4(xVFaDkqonlityZibBgaV)(2JK3pGzpfJ9fWmqy6MHIoPbDmXqXpSqXGOAmXWEahtmuW2T0OCa6HIaMbctFOirpawM2znWWWs(iAjklHdRXGUpaaVVqTqJfSr(eP7ZGX(qpLfKj2HXLsQbNzsd6(Q2h6PSGmXomUusnqK3ZMUp3G3hqahkUiYRhkERUiB5ig2B7yIHc2ULgLdqpueWmqy6dfj6bWY0oRbggwYhrlrzjCyng09ba49NCO4IiVEO4T6ISLJyyphhtmuW2T0OCa6HIaMbctFOm3(mDy6wA0uDNo76cKOtrP6iJW9vTpx7BrWYAKoCAjGEtzpiVh51gIQ9vTpKOr2dwJgj6sDI0OiUuBW2T0OCFv77IizIfSr(eP7Zn4954(mySVlIKjwWg5tKUp49TDFohkUiYRhks0dGfXL6rmS3ggtmuW2T0OCa6HIaMbctFOm3(mDy6wA0uDNo76cKOtrP6iJWHIlI86HcwLsKpfJyy)KJjgky7wAuoa9qXfrE9qHfPbcZUUqdyofhkcygim9HIeTiyznSinqy21fYhrln0Wft3NBW7ZX9vTV4oT8i3gV6eUwDffnqK3ZMUp37ZXHIqTqJLWH1yqh2d4ig2dkhtmuW2T0OCa6HIlI86HclsdeMDDHgWCkoueWmqy6dfjArWYAyrAGWSRlKpIwAOHlMUp37d4qrOwOXs4WAmOd7bCed7TjhtmuW2T0OCa6HIlI86HclsdeMDDHgWCkoueWmqy6dfjArWYAyrAGWSRlKpIwAOHlMUp3G3NJ7RAFirJMi5XsCfByFU3xCNwEKBJ3QlYwAGiVNnDOiul0yjCyng0H9aoIH9KSJjgky7wAuoa9qXfrE9qH8r0YcTcBjchksKkGzvKxpuaiaI9(HdRXyFkzVIUVdX9Lj1T0OK09dGjDFYPwVVgJ9vFe7tRWwUpKOr6SKpIws3pBAGUC)JDFYEgzxVp7b3NeAsywsaztnoljGEa0o6(KabAgkcygim9Hcx7p3(umISRPgHAHg3NbJ9LOhalt7SgyyyjFeTeLLWH1yq3haG3xOwOXc2iFI095CFv7lrlcwwdlsdeMDDH8r0sdnCX09bW(CCFv7djA0ejpwIRWX95EFXDA5rUnERUiBPbI8E20rmIHIFyXIasJXed7bCmXqbB3sJYbOhkcygim9Hcx7BrWYAOesj2f5D8gi6IyFgm2FU9z6W0T0OP6oD21firNIs1rgH7Z5(Q2NR9TiyznshoTeqVPShK3J8Adr1(Q2hs0i7bRrJeDPorAuexQny7wAuUVQ9DrKmXc2iFI095g8(CCFgm23frYelyJ8js3h8(2UpNdfxe51dfj6bWI4s9ig2B7yIHc2ULgLdqpueWmqy6dfirNIs1rgHgjYMIm2N795AFaNX(ZVVe9ayzAN1addl5JOLOSeoSgd6(K47ZX95CFv7lrpawM2znWWWs(iAjklHdRXGUp37dk3x1(ZTpthMULgnv3PZUUaj6uuQoYiCFgm23IGL1qj7q(SRl8jnmevdfxe51dfSkLiFkgXWEooMyOGTBPr5a0dfbmdeM(qbs0POuDKrOrISPiJ95EFBNCFv7lrpawM2znWWWs(iAjklHdRXGUpa2FY9vT)C7Z0HPBPrt1D6SRlqIofLQJmchkUiYRhkyvkr(umIH92WyIHc2ULgLdqpueWmqy6dL52xIEaSmTZAGHHL8r0suwchwJbDFv7p3(mDy6wA0uDNo76cKOtrP6iJW9zWyF2SgyuGiVNnDFU3FY9zWyFONYcYe7W4sj1GZmPbDFv7d9uwqMyhgxkPgiY7zt3N79NCO4IiVEOGvPe5tXig2p5yIHIlI86Hc5JOLfAf2seouW2T0OCa6rmShuoMyOGTBPr5a0dfbmdeM(qzU9z6W0T0OP6oD21firNIs1rgHdfxe51dfSkLiFkgXigkbm7PyqhtmShWXedfSDlnkhGEO4IiVEOKnvajc3sJfsIW7GGVirMPahkcygim9Hcx7lUtlpYTHObEA1flDwdmmqK3ZMUpdg7lUtlpYTr6WPLa6nL9G8EKxBGiVNnDFo3x1(CTFfgghYRUud8i0gxejtCFgm2VcdJxDIsnWJqBCrKmX9vT)C7hUg7W4qE1LJTeaXI05BuAW2T0OCFgm2pCyngMi5XsCLkruSDg7Z9(tUpN7ZGX(whLUVQ9zZAGrbI8E2095EFBbCO0opouYMkGeHBPXcjr4DqWxKiZuGJyyVTJjgky7wAuoa9qXfrE9qH3fUfeluGigfEcAkgkcygim9HI4oT8i3gV6eUwDffnqK3ZMUp37p5(Q2NR9NBFKKiYQkuAYMkGeHBPXcjr4DqWxKiZuG7ZGX(I70YJCBYMkGeHBPXcjr4DqWxKiZuGgiY7zt3NZ9zWyFRJs3x1(SznWOarEpB6(CVVTaouANhhk8UWTGyHceXOWtqtXig2ZXXedfSDlnkhGEO4IiVEOiHOlztiwyIukQhkcygim9HI4oT8i3gV6eUwDffnqK3ZMUVQ95A)52hjjISQcLMSPcir4wASqseEhe8fjYmf4(mySV4oT8i3MSPcir4wASqseEhe8fjYmfObI8E2095CFgm236O09vTpBwdmkqK3ZMUp37ZXHs784qrcrxYMqSWePuupIH92WyIHc2ULgLdqpuCrKxpuKoCk)DDrIIPfMh0fzOEOiGzGW0hkI70YJCB8Qt4A1vu0arEpB6(Q2NR9NBFKKiYQkuAYMkGeHBPXcjr4DqWxKiZuG7ZGX(I70YJCBYMkGeHBPXcjr4DqWxKiZuGgiY7zt3NZ9zWyFRJs3x1(SznWOarEpB6(CVVTaouANhhkshoL)UUirX0cZd6ImupIH9toMyOGTBPr5a0dfbmdeM(qHR9f3PLh524vNW1QROObI8E209zWyFlcwwJ0Htlb0Bk7b59iV2quTpN7RAFU2FU9rsIiRQqPjBQaseULglKeH3bbFrImtbUpdg7lUtlpYTjBQaseULglKeH3bbFrImtbAGiVNnDFohkUiYRhkeuSKbYthXigk1yJWumMyypGJjgky7wAuoa9qraZaHPpuSiyznucPe7I8oEdeDrSVQ9NBFMomDlnAQUtNDDbs0POuDKr4(mySFfgMAhwFQ1OXfrYehkUiYRhks0dGfXL6rmS32XedfSDlnkhGEOiGzGW0hkqIofLQJmcnsKnfzSp37dih3NbJ9zZAGrbI8E2095E)j3x1(ZTVeTiyznSinqy21fYhrlnevdfxe51dfj6bWI4s9ig2ZXXedfSDlnkhGEOiGzGW0hkI70YJCB8Qt4A1vu0arEpB6(Q2NR9dxJDyKiBQrd2ULgL7ZGX(IJj2EhMoRbgfwh3NbJ9HenYEWA0ubeD4XFnsny7wAuUpN7RAFU2FU9z6W0T0OP6oD21firJ09zWyF2SgyuGiVNnDFU3FY95CO4IiVEO4T6ISLJyyVnmMyOGTBPr5a0dfbmdeM(qrIweSSgwKgim76c5JOLgA4IP7dG954(Q2FU9z6W0T0OP6oD21firJ0HIlI86Hc5JOLfAf2seoIH9toMyOGTBPr5a0dfbmdeM(qrIweSSgwKgim76c5JOLgIQ9vTV4oT8i3gV6eUwDffnqK3ZMwWzwHIaL7dG9NCFv7p3(mDy6wA0uDNo76cKOr6qXfrE9qH8r0YcTcBjchXWEq5yIHc2ULgLdqpueWmqy6dfirNIs1rgHgjYMIm2N79TDg7RA)52NPdt3sJMQ70zxxGeDkkvhzeouCrKxpuKOhalIl1JyyVn5yIHc2ULgLdqpueWmqy6dfjArWYAyrAGWSRlKpIwAOHlMUp37d4(Q2FU9z6W0T0OP6oD21firJ0HIlI86HclsdeMDDHgWCkoIH9KSJjgky7wAuoa9qraZaHPpuKOfblRHfPbcZUUq(iAPHgUy6(CVVnSVQ9f3PLh524vNW1QROObI8E20coZkueOCFU3FY9vT)C7Z0HPBPrt1D6SRlqIgPdfxe51dfwKgim76cnG5uCed7TPoMyOGTBPr5a0dfbmdeM(qzU9z6W0T0OP6oD21firNIs1rgHdfxe51dfj6bWI4s9igXqrCmX27GoMyypGJjgky7wAuoa9qraZaHPpuy6W0T0OHgLkT3D217RAFirNIs1rgHgjYMIm2ha7diOCFv7Z1(I70YJCB8Qt4A1vu0arEpB6(myS)C7hUg7W4qE1LJTeaXI05BuAW2T0OCFv7lUtlpYTr6WPLa6nL9G8EKxBGiVNnDFo3NbJ9TokDFv7ZM1aJce59SP7Z9(ac4qXfrE9qHs2H8zxx4tAmIH92oMyOGTBPr5a0dfxe51dfkzhYNDDHpPXqrIubmRI86HIcg7h3(euCFNnq4(E1j2pP7F9(2ijSVt3pU9RGitSJ9pMiu4vvzxVpOaj2(KbMACFkgr217tuTVnsc2rhkcygim9HI4oT8i3gV6eUwDffnqK3ZMUVQ95AFxejtSGnYNiDFaaEFB3x1(UisMybBKpr6(CdE)j3x1(qIofLQJmcnsKnfzSpa2hWzS)87Z1(UisMybBKpr6(K47dk3NZ9zWyFxejtSGnYNiDFaS)K7RAFirNIs1rgHgjYMIm2ha7BdZyFohXWEooMyOGTBPr5a0dfbmdeM(qHPdt3sJgAuQ0E3zxVVQ9NBF6rOTYwA0OllwQl4mD(knAW2T0OCFv7Z1(I70YJCB8Qt4A1vu0arEpB6(myS)C7hUg7W4qE1LJTeaXI05BuAW2T0OCFv7lUtlpYTr6WPLa6nL9G8EKxBGiVNnDFo3x1(qIgnrYJL4k2W(ayFU2NJ7p)(weSSgirNII4GqIQiV2arEpB6(CUpdg7BDu6(Q2NnRbgfiY7zt3N79TfWHIlI86HIBD8z7rEDrN8wJyyVnmMyOGTBPr5a0dfbmdeM(qHPdt3sJgAuQ0E3zxVVQ9PhH2kBPrJUSyPUGZ05R0ObB3sJY9vTpx7lVWq0apT6ILoRbgf5fgiY7zt3ha7diG7ZGX(ZTF4ASddrd80Qlw6SgyyW2T0OCFv7lUtlpYTr6WPLa6nL9G8EKxBGiVNnDFohkUiYRhkU1XNTh51fDYBnIH9toMyOGTBPr5a0dfbmdeM(qXfrYelyJ8js3haG3329vTpKOrtK8yjUInSpa2NR954(ZVVfblRbs0POioiKOkYRnqK3ZMUpNdfxe51df364Z2J86Io5TgXWEq5yIHc2ULgLdqpueWmqy6dfMomDlnAOrPs7DND9(Q2NR9f3PLh524vNW1QROObI8E209zWy)52pCn2HXH8QlhBjaIfPZ3O0GTBPr5(Q2xCNwEKBJ0Htlb0Bk7b59iV2arEpB6(CUpdg7BDu6(Q2NnRbgfiY7zt3N79bCYHIlI86HcfOlMQXsaelen5dgavpIH92KJjgky7wAuoa9qraZaHPpuCrKmXc2iFI09ba49TDFv7Z1(s0dGfVLfjkC1MiftZUEFgm2h6PSGmXomUusnqK3ZMUp3G3hqByFohkUiYRhkuGUyQglbqSq0Kpyau9igXqPcIIJ3YJXed7bCmXqXfrE9qP6I86Hc2ULgLdqpIH92oMyO4IiVEOa9KIfj6YHc2ULgLdqpIrmuGUiDnDmXWEahtmuW2T0OCa6HIlI86HIdfEJL4GqSJHIePcywf51dfqbxKUMoueWmqy6dfirNIs1rgHgjYMIm2ha7dkNCFv7Z1(vyyQDy9PwJgxejtCFgm2FU9dxJDyOe88xxQDy9PwJgSDlnk3NZ9vTpKOrJeztrg7daW7p5ig2B7yIHc2ULgLdqpueWmqy6dfMomDlnA4Ds(blI70YJCtlUisM4(mySF4WAmmrYJL4kYe3NBW7BrWYAS03jlSeq1gjb0J86HIlI86HIL(ozHLaQEed754yIHc2ULgLdqpueWmqy6dfMomDlnA4Ds(blI70YJCtlUisM4(mySF4WAmmrYJL4kYe3NBW7BrWYASqifHtZU2ijGEKxpuCrKxpuSqifHtZUEed7THXedfSDlnkhGEOiGzGW0hkweSSgIg4PvxObe76aOHOAO4IiVEOOZAGbTqYjK18yhJyy)KJjgky7wAuoa9qXfrE9qXBbsdORlcxRhksKkGzvKxpuirTaPb017BJUwVVW79dywxJW9TH9RUa7iD9(weSSus3hDbW91onYUEFaNCFkkUwsn7BZfPoTjIY9b6q5(ItIY9JKh33P777hWSUgH7h3(trSA)m2hIU0T0OzOiGzGW0hkmDy6wA0W7K8dwe3PLh5MwCrKmX9zWy)WH1yyIKhlXvKjUp3G3hWjhXWEq5yIHc2ULgLdqpueWmqy6dfxejtSGnYNiDFaaEFB3NbJ95AFirJgjYMIm2haG3FY9vTpKOtrP6iJqJeztrg7daW7dkNX(CouCrKxpuCOWBSurOP4ig2BtoMyOGTBPr5a0dfbmdeM(qHPdt3sJgENKFWI4oT8i30IlIKjUpdg7hoSgdtK8yjUImX95g8(weSSg2eIw67Kgjb0J86HIlI86HcBcrl9DYrmSNKDmXqbB3sJYbOhkcygim9HIfblRHObEA1fAaXUoaAiQ2x1(UisMybBKpr6(G3hWHIlI86HILxxo2satXu6igXqPgBeMIIF4yIH9aoMyOGTBPr5a0dfbmdeM(qHR9NBFMomDlnAQUtNDDbs0POuDKr4(mySVfblRHsiLyxK3XBGOlI95CFv7Z1(weSSgPdNwcO3u2dY7rETHOAFv7djAK9G1OrIUuNinkIl1gSDlnk3x1(UisMybBKpr6(CdEFoUpdg77IizIfSr(eP7dEFB3NZHIlI86HIe9ayrCPEed7TDmXqbB3sJYbOhkcygim9HIfblRHsiLyxK3XBGOlI9zWy)52NPdt3sJMQ70zxxGeDkkvhzeouCrKxpuWQuI8Pyed754yIHc2ULgLdqpuCrKxpuiFeTSqRWwIWHIaMbctFOW1(I70YJCB8Qt4A1vu0arEpB6(ay)j3x1(s0IGL1WI0aHzxxiFeT0quTpdg7lrlcwwdlsdeMDDH8r0sdnCX09bW(CCFo3x1(CTpBwdmkqK3ZMUp37lUtlpYTrIEaS4TSirHR2arEpB6(ZVpGZyFgm2NnRbgfiY7zt3ha7lUtlpYTXRoHRvxrrde59SP7Z5qrOwOXs4WAmOd7bCed7THXedfSDlnkhGEO4IiVEOWI0aHzxxObmNIdfbmdeM(qrIweSSgwKgim76c5JOLgA4IP7Zn4954(Q2xCNwEKBJxDcxRUIIgiY7zt3N7954(mySVeTiyznSinqy21fYhrln0Wft3N79bCOiul0yjCyng0H9aoIH9toMyOGTBPr5a0dfxe51dfwKgim76cnG5uCOiGzGW0hkI70YJCB8Qt4A1vu0arEpB6(ay)j3x1(s0IGL1WI0aHzxxiFeT0qdxmDFU3hWHIqTqJLWH1yqh2d4igXqrISoHogtmShWXedfxe51df(SLfwiI2eXHc2ULgLdqpIH92oMyOGTBPr5a0dLRAOqXyO4IiVEOW0HPBPXHctxtGdfXDA5rUnucE(Rl1oS(uRrde59SP7Z9(tUVQ9dxJDyOe88xxQDy9PwJgSDlnkhkmDyPDECOuDNo76cKOtrP6iJWrmSNJJjgky7wAuoa9q5QgkumgkUiYRhkmDy6wACOW01e4qjCn2HHEe6ce9keAW2T0OCFv7djACFU3329vTF4WAmmrYJL4kvIOWXj3N79NCFv7ZM1aJce59SP7dG9NCOW0HL25XHs1D6SRlqIgPJyyVnmMyOGTBPr5a0dLRAOqXyO4IiVEOW0HPBPXHctxtGdfxejtSGnYNiDFW7d4(Q2NR9NBFONYcYe7W4sj1GZmPbDFgm2h6PSGmXomUusnzVpa2hWj3NZHcthwANhhk0OuP9UZUEed7NCmXqbB3sJYbOhkx1qHIXqXfrE9qHPdt3sJdfMUMahkvyyQDy9PwJgxejtCFgm23IGL1q0apT6ItPoHomev7ZGX(HRXomoKxD5ylbqSiD(gLgSDlnk3x1(vyy8QtuQbEeAJlIKjUpdg7BrWYAKoCAjGEtzpiVh51gIQHcthwANhhk8oj)GfXDA5rUPfxejtCed7bLJjgky7wAuoa9qXfrE9q5icli6thksKkGzvKxpuSP4zhE2zxVVn)esOXo2Net71e4(jDFF)kyEWmupueWmqy6df5fgMjKqJDuQ0EnbAGilePaDlnUVQ9NB)W1yhgIg4PvxS0znWWGTBPr5(Q2FU9HEklitSdJlLudoZKg0rmS3MCmXqbB3sJYbOhkcygim9HI8cdZesOXokvAVManqKfIuGULg3x1(UisMybBKpr6(aa8(2UVQ95A)52pCn2HHObEA1flDwdmmy7wAuUpdg7hUg7Wq0apT6ILoRbggSDlnk3x1(I70YJCBiAGNwDXsN1adde59SP7Z5qXfrE9q5icli6thXWEs2XedfSDlnkhGEOiGzGW0hkqIgzpynAOeviKgqpBd2ULgL7RAFU2xEHHfE0OWImrObISqKc0T04(mySV8cJL(ozPs71eObISqKc0T04(CouCrKxpuoIWcI(0rmS3M6yIHc2ULgLdqpuKivaZQiVEOqIerE9(a0Kg099wUVnRcBes3NlBwf2iKoRcsseylq6(enLOQ6Gbk3p79DP8AdNdfxe51dfHR1fxe51fDsJHIoPrPDECOeWSNIbDed7bCgJjgky7wAuoa9qXfrE9qr4ADXfrEDrN0yOOtAuANhhkIJj2Eh0rmShqahtmuW2T0OCa6HIlI86HIW16IlI86IoPXqrN0O0opouGUiDnDed7b02XedfSDlnkhGEOirQaMvrE9qXfrEn1irwNqhZdEwksseylqstwWUisMybBKprkyavnNe9ayzAN1adJmPULgl(fssBNhbFvyJqa2H8QlhBjaIfj6saMfPbcZUUqdyofbywKgim76cnG5ueGjAGNwDXsN1adaU6I8Aaw6WPLa6nL9G8EKxdWE1jCT6kkouCrKxpueUwxCrKxx0jngk6KgL25XHI4oT8i30rmShqooMyOGTBPr5a0dfbmdeM(qXfrYelyJ8js3haG3329vTpx7lUtlpYTrIEaS4TSirHR2arEpB6(CVpGZyFv7p3(HRXomsKn1ObB3sJY9zWyFXDA5rUnsKn1ObI8E2095EFaNX(Q2pCn2HrISPgny7wAuUpN7RA)52xIEaS4TSirHR2ePyA21dfxe51dfirxCrKxx0jngk6KgL25XHIFyHIbr1ig2dOnmMyOGTBPr5a0dfbmdeM(qXfrYelyJ8js3haG3329vTVe9ayXBzrIcxTjsX0SRhkUiYRhkqIU4IiVUOtAmu0jnkTZJdf)WIfbKgJyypGtoMyOGTBPr5a0dfbmdeM(qXfrYelyJ8js3haG3329vTpx7p3(s0dGfVLfjkC1MiftZUEFv7Z1(I70YJCBKOhalEllsu4QnqK3ZMUpa2hWzSVQ9NB)W1yhgjYMA0GTBPr5(mySV4oT8i3gjYMA0arEpB6(ayFaNX(Q2pCn2HrISPgny7wAuUpN7Z5qXfrE9qbs0fxe51fDsJHIoPrPDECOuJnctrXpCed7beuoMyOGTBPr5a0dfbmdeM(qXfrYelyJ8js3h8(aouCrKxpueUwxCrKxx0jngk6KgL25XHsn2imfJyedfXDA5rUPJjg2d4yIHc2ULgLdqpueWmqy6dfMomDlnA4Ds(blI70YJCtlUisM4(mySV1rP7RAF2SgyuGiVNnDFU33wq5qXfrE9qP6I86rmS32XedfSDlnkhGEOiGzGW0hkI70YJCBiAGNwDXsN1adde59SP7Z9(tUVQ9f3PLh52iD40sa9MYEqEpYRnqK3ZMwWzwHIaL7Z9(tUVQ9dxJDyiAGNwDXsN1add2ULgL7ZGX(ZTF4ASddrd80Qlw6SgyyW2T0OCFgm236O09vTpBwdmkqK3ZMUp37ZXjhkUiYRhkoKxD5ylbqSirxoIH9CCmXqbB3sJYbOhkUiYRhk0JqxGOxHWHIaMbctFOeoSgdtK8yjUsLikCCY95E)j3x1(HdRXWejpwIRitCFaS)K7RAFxejtSGnYNiDFUbVphhkc1cnwchwJbDypGJyyVnmMyOGTBPr5a0dfxe51dfIg4PvxS0znWyOirQaMvrE9qbuStlP7dADwdm2N9G7tuTFC7p5(uuCTKUFC7tv3I9jNbW9jrvNW1QROiP7BZcGiKCsrs3NGI7todG7tcoC6(ta9MYEqEpYRndfbmdeM(qHPdt3sJgAuQ0E3zxVVQ95AFXDA5rUnE1jCT6kkAGiVNnTGZScfbk3N79NCFgm2xCNwEKBJxDcxRUIIgiY7ztl4mRqrGY9bW(aoJ95CFv7Z1(I70YJCBKoCAjGEtzpiVh51giY7zt3N79RfY9zWyFlcwwJ0Htlb0Bk7b59iV2quTpNJyy)KJjgky7wAuoa9qraZaHPpuCrKmXc2iFI09ba49TDFgm236O09vTpBwdmkqK3ZMUp37BlGdfxe51dfIg4PvxS0znWyed7bLJjgky7wAuoa9qraZaHPpuy6W0T0OHgLkT3D217RAFU2xEHHObEA1flDwdmkYlmqK3ZMUpdg7p3(HRXomenWtRUyPZAGHbB3sJY95CO4IiVEOiD40sa9MYEqEpYRhXWEBYXedfSDlnkhGEOiGzGW0hkUisMybBKpr6(aa8(2Updg7BDu6(Q2NnRbgfiY7zt3N79TfWHIlI86HI0Htlb0Bk7b59iVEed7jzhtmuW2T0OCa6HIaMbctFO4IizIfSr(eP7dEFa3x1(s0IGL1WI0aHzxxiFeT0qdxmDFaSphhkUiYRhkE1jCT6kkoIH92uhtmuW2T0OCa6HIlI86HIxDcxRUIIdfbmdeM(qXfrYelyJ8js3haG3329vTVeTiyznSinqy21fYhrln0Wft3ha7ZX9vT)C7lrpaw8wwKOWvBIumn76HIqTqJLWH1yqh2d4ig2d4mgtmuW2T0OCa6HIaMbctFOaj6uuQoYi0ir2uKX(CVpG2W(Q2NR9f3PLh52q0apT6ILoRbggiY7zt3N79bCg7ZGX(YlmenWtRUyPZAGrrEHbI8E2095CO4IiVEOqj45VUu7W6tTghXWEabCmXqbB3sJYbOhkcygim9HcthMULgn0OuP9UZUEFv7lrlcwwdlsdeMDDH8r0sdnCX095EFB3x1(CTFfggV6eLAGhH24IizI7ZGX(weSSgPdNwcO3u2dY7rETHOAFv7p3(vyyCiV6snWJqBCrKmX95CO4IiVEOq0apT6ItPoHogXWEaTDmXqbB3sJYbOhkUiYRhkenWtRU4uQtOJHIaMbctFO4IizIfSr(eP7daW7B7(Q2xIweSSgwKgim76c5JOLgA4IP7Z9(2oueQfASeoSgd6WEahXWEa54yIHc2ULgLdqpueWmqy6dL52VcdtnWJqBCrKmXHIlI86Hc0tkwKOlhXigXqHjcP51d7TDg2c4m44mizhkKDyNDnDOaqqIafShG0EsgaE)9NaiUFYxDWyF2dUVD(Hfkgev2TpejjIeIY9PhpUVtehVhOCFbqVRrQzbbGMnUphb49TXRzIWaL7BhKOr2dwJgq1U9JBF7GenYEWA0aQgSDlnkTBFUaCMCAwqwqaiirGc2dqApjdaV)(tae3p5RoySp7b33o)WIfbKg2TpejjIeIY9PhpUVtehVhOCFbqVRrQzbbGMnUpGa8(241mryGY9Tds0i7bRrdOA3(XTVDqIgzpynAavd2ULgL2TpxaotonliliaeKiqb7biTNKbG3F)jaI7N8vhm2N9G7BxaZEkgu72hIKercr5(0Jh33jIJ3duUVaO31i1SGaqZg3hqaEFB8AMimq5(2fUg7WaQ2TFC7Bx4ASddOAW2T0O0U95cWzYPzbzbbGGebkypaP9Kma8(7pbqC)KV6GX(ShCF7QXgHPWU9HijrKquUp94X9DI449aL7la6Dnsnlia0SX95iaVVnEntegOCF7GenYEWA0aQ2TFC7BhKOr2dwJgq1GTBPrPD7ZfGZKtZcYccabjcuWEas7jza493FcG4(jF1bJ9zp4(2joMy7DqTBFissejeL7tpECFNioEpq5(cGExJuZccanBCFab49TXRzIWaL7Bx4ASddOA3(XTVDHRXomGQbB3sJs72NlaNjNMfeaA24(CeG33gVMjcduUVDHRXomGQD7h3(2fUg7WaQgSDlnkTBFUaCMCAwqaOzJ7ZraEFB8AMimq5(2rpcTv2sdOA3(XTVD0JqBLT0aQgSDlnkTBFUaCMCAwqaOzJ7Bda8(241mryGY9TlCn2HbuTB)423UW1yhgq1GTBPrPD7ZfGZKtZccanBCFBaG33gVMjcduUVD0JqBLT0aQ2TFC7Bh9i0wzlnGQbB3sJs72NlaNjNMfeaA24(GsaEFB8AMimq5(2fUg7WaQ2TFC7Bx4ASddOAW2T0O0U95cWzYPzbzbbGGebkypaP9Kma8(7pbqC)KV6GX(ShCF7e3PLh5MA3(qKKisik3NE84(orC8EGY9fa9UgPMfeaA24(2cW7BJxZeHbk33UW1yhgq1U9JBF7cxJDyavd2ULgL2Tpx2otonlia0SX9bLa8(241mryGY9TlCn2HbuTB)423UW1yhgq1GTBPrPD7ZfGZKtZcYccabjcuWEas7jza493FcG4(jF1bJ9zp4(2vJnctrXp0U9HijrKquUp94X9DI449aL7la6Dnsnlia0SX9beG33gVMjcduUVDqIgzpynAav72pU9Tds0i7bRrdOAW2T0O0U95cWzYPzbzbbGGebkypaP9Kma8(7pbqC)KV6GX(ShCF7KiRtOd72hIKercr5(0Jh33jIJ3duUVaO31i1SGaqZg33waEFB8AMimq5(2fUg7WaQ2TFC7Bx4ASddOAW2T0O0U99yFBABgaDFUaCMCAwqaOzJ7ZraEFB8AMimq5(2fUg7WaQ2TFC7Bx4ASddOAW2T0O0U95cWzYPzbbGMnU)Ka8(241mryGY9TlCn2HbuTB)423UW1yhgq1GTBPrPD7ZfGZKtZccanBCFqjaVVnEntegOCF7cxJDyav72pU9TlCn2Hbuny7wAuA3(Cb4m50SGaqZg33MeG33gVMjcduUVDHRXomGQD7h3(2fUg7WaQgSDlnkTBFUSDMCAwqaOzJ7tYcW7BJxZeHbk33oirJShSgnGQD7h3(2bjAK9G1Obuny7wAuA3(Cb4m50SGaqZg3hqocW7BJxZeHbk33UW1yhgq1U9JBF7cxJDyavd2ULgL2Tpx2otonlia0SX9bCsaEFB8AMimq5(2fUg7WaQ2TFC7Bx4ASddOAW2T0O0U95Y2zYPzbzbbGKV6Gbk3hWzSVlI8691jnOMfKHsf8ytnou4ah2NeqpaUVnHoRbg7BZ1apT6feoWH9TP4qbW9bCgKUVTZWwaxqwq4ah2Nejj5e0Gh7GUFC7tcnjmljGSPgNLeqpas3NeiW9JB)R1Q3xCeDSF4WAmO7tg4TVdX9XzwHIaL7h3(6KjUV(669X(iQbUFC7Z7rGW95YpSqXGOAFoaiNMfeoWH9jHK6wAuUVIlGjBksxVpjMlI9TqHtqX9LOl3Vg4rOP7Z7tX9zp4(uxUpjytGAwq4ah23MJMD9(aehrl3xPcBjc33TsDgjs3N)G4(SACMPLw9(C5X(2W87tdxmLUF20aD5(h7(topNGIVpjqIPSFJeb0177TCFEx9(vqKj2X(0Jh3VpBEquSpndcpYRPMfeoWH9TrGExJY959w9(2XM1aJce59SP2TV4Azg51UMUFC77vvA17N9(whLUpBwdmO7FTw9(CPrkDFBKe2NStdC)R3pGofiNMfeoWH9NWMrc2maE)9ThjVFaZEkg7lGzGW0nliliUiYRPMkikoElpMh8SvxKxVG4IiVMAQGO44T8yEWZc9KIfj6YfeoWH9TPz6Acpq6(((bm7Pyq3xCNwEKBs3xMmtjk33s9(2WKM9Nays3NSt3xa8OyVVt3NObEA17t(GtP7F9(2WK7trX1Y9TiG0yFHAHgPKUVfrSpqNUFC3(8EREFHeUpYYIIGUFC7xNmX999f3PLh52mtJKa6rE9(YKzsp4(ztd0LM9biz3pd7O7Z01e4(aD6(9Tpe59SLiCFigeWEFajDFutX9Hyqa79NHzsZcch4W(UiYRPMkikoElpMh8SmDy6wAK025rWbm7PyuaSqv3csVkWumswsz6AcemGKY01eyb1ue8mmtsQ4Azg51Gdy2tXWaObOtleuSyrWYQIRaM9ummaAe3PLh52ijGEKxdkcuKnmj4zW5cch4W(UiYRPMkikoElpMh8SmDy6wAK025rWbm7PyuSTqv3csVkWumswsz6AcemGKY01eyb1ue8mmtsQ4Azg51Gdy2tXWyRbOtleuSyrWYQIRaM9umm2Ae3PLh52ijGEKxdkcuKnmj4zW5cch4W(200i59aP777hWSNIbDFMUMa33s9(IJVYHzxVFae3xCNwEK79p29dG4(bm7Pyq6(YKzkr5(wQ3paI7ljGEKxV)XUFae33IGLD)m2VcEmtjsn7dkMt333NgqSRdG7ZFYKnr4(XTFDYe333hywdeH7xbZdMH69JBFAaXUoaUFaZEkgus33P7tg169D6(((8NmzteUp7b3pz333pGzpfJ9jNA9(hCFYPwVFFX(u1TyFYzaCFXDA5rUPMfeoWH9DrKxtnvquC8wEmp4zz6W0T0iPTZJGdy2tXOubZdMHAsVkWumswsz6AceSTKY01eyb1uemGKkUwMrEn45cy2tXWaObOtleuSyrWYQkGzpfdJTgGoTqqXIfblldgbm7PyyS1a0PfckwSiyzvXfxbm7PyyS1iUtlpYTrsa9iVguuaZEkggBnvWty8wDrwrnscOh51CsIZfGMjNpGzpfdJTgGoTyrWYYjjoxmDy6wA0eWSNIrX2cvDl4KtaWfxbm7Pyya0iUtlpYTrsa9iVguuaZEkgganvWty8wDrwrnscOh51CsIZfGMjNpGzpfddGgGoTyrWYYjjoxmDy6wA0eWSNIrbWcvDl4KZfKfKfeoWH9TPNjkicuUpYeHQ3psEC)aiUVlIdUFs33z6P2T0OzbXfrEnfmF2YclerBI4cch4W(28Dy6wAKUG4IiVMop4zz6W0T0iPTZJGRUtNDDbs0POuDKriPmDnbcwCNwEKBdLGN)6sTdRp1A0arEpBk3tQkCn2HHsWZFDP2H1NAnUG4IiVMop4zz6W0T0iPTZJGRUtNDDbs0iLuMUMabhUg7WqpcDbIEfcvbjAKBBvfoSgdtK8yjUsLikCCsUNufBwdmkqK3ZMcGjxqCrKxtNh8SmDy6wAK025rW0OuP9UZUMuMUMab7IizIfSr(ePGbufxZb9uwqMyhgxkPgCMjnOmya9uwqMyhgxkPMSbaGtY5cIlI8A68GNLPdt3sJK2opcM3j5hSiUtlpYnT4IizIKY01ei4kmm1oS(uRrJlIKjYGHfblRHObEA1fNsDcDyiQyWiCn2HXH8QlhBjaIfPZ3OuvfggV6eLAGhH24IizImyyrWYAKoCAjGEtzpiVh51gIQfeoSVnfp7WZo769T5Nqcn2X(KyAVMa3pP777xbZdMH6fexe5105bp7rewq0NsAYcwEHHzcj0yhLkTxtGgiYcrkq3sJQMlCn2HHObEA1flDwdmunh0tzbzIDyCPKAWzM0GUG4IiVMop4zpIWcI(ustwWYlmmtiHg7OuP9Ac0arwisb6wAuLlIKjwWg5tKcaW2QIR5cxJDyiAGNwDXsN1adgmcxJDyiAGNwDXsN1advI70YJCBiAGNwDXsN1adde59SPCUG4IiVMop4zpIWcI(ustwWqIgzpynAOeviKgqpBvCjVWWcpAuyrMi0arwisb6wAKbd5fgl9DYsL2RjqdezHifOBProxq4W(KirKxVpanPbDFVL7BZQWgH095YMvHncPZQGKeb2cKUprtjQQoyGY9ZEFxkV2W5cIlI8A68GNv4ADXfrEDrN0G025rWbm7PyqxqCrKxtNh8ScxRlUiYRl6KgK2opcwCmX27GUG4IiVMop4zfUwxCrKxx0jniTDEem0fPRPliCyFxe5105bplfjjcSfiPjlyxejtSGnYNifmGQMtIEaSmTZAGHrMu3sJf)cjPTZJGVkSria7qE1LJTeaXIeDjaZI0aHzxxObmNIamlsdeMDDHgWCkcWenWtRUyPZAGbaxDrEnalD40sa9MYEqEpYRbyV6eUwDffxqCrKxtNh8ScxRlUiYRl6KgK2opcwCNwEKB6cIlI8A68GNfs0fxe51fDsdsBNhb7hwOyqurAYc2frYelyJ8jsbayBvXL4oT8i3gj6bWI3YIefUAde59SPCd4munx4ASdJeztnYGH4oT8i3gjYMA0arEpBk3aodvHRXomsKn1iNQMtIEaS4TSirHR2ePyA21liUiYRPZdEwirxCrKxx0jniTDEeSFyXIasdstwWUisMybBKprkaaBRkj6bWI3YIefUAtKIPzxVG4IiVMop4zHeDXfrEDrN0G025rW1yJWuu8djnzb7IizIfSr(ePaaSTQ4Aoj6bWI3YIefUAtKIPzxRIlXDA5rUns0dGfVLfjkC1giY7ztbaGZq1CHRXomsKn1idgI70YJCBKiBQrde59SPaaWzOkCn2HrISPg5KZfexe5105bpRW16IlI86IoPbPTZJGRXgHPG0KfSlIKjwWg5tKcgWfKfeoWH9jrNn9(GMasJfexe51uJFyXIasdWs0dGfXLAstwWCzrWYAOesj2f5D8gi6IGbJ5y6W0T0OP6oD21firNIs1rgHCQIllcwwJ0Htlb0Bk7b59iV2quPcs0i7bRrJeDPorAuexQv5IizIfSr(ePCdMJmy4IizIfSr(ePGTLZfexe51uJFyXIasJ5bplwLsKpfKMSGHeDkkvhzeAKiBkYGBUaCgZlrpawM2znWWWs(iAjklHdRXGsIZrovjrpawM2znWWWs(iAjklHdRXGYnOu1CmDy6wA0uDNo76cKOtrP6iJqgmSiyznuYoKp76cFsddr1cIlI8AQXpSyraPX8GNfRsjYNcstwWqIofLQJmcnsKnfzWTTtQsIEaSmTZAGHHL8r0suwchwJbfatQAoMomDlnAQUtNDDbs0POuDKr4cIlI8AQXpSyraPX8GNfRsjYNcstwWZjrpawM2znWWWs(iAjklHdRXGQAoMomDlnAQUtNDDbs0POuDKridgSznWOarEpBk3tYGb0tzbzIDyCPKAWzM0GQc6PSGmXomUusnqK3ZMY9KliUiYRPg)WIfbKgZdEwYhrll0kSLiCbXfrEn14hwSiG0yEWZIvPe5tbPjl45y6W0T0OP6oD21firNIs1rgHliliCGd7tIoB69vWGOAbXfrEn14hwOyqub2B1fzljnzblrpawM2znWWWs(iAjklHdRXGcaWc1cnwWg5tKYGb0tzbzIDyCPKAWzM0GQc6PSGmXomUusnqK3ZMYnyabCbXfrEn14hwOyqunp4z9wDr2sstwWs0dGLPDwdmmSKpIwIYs4WAmOaa8KliUiYRPg)WcfdIQ5bpRe9ayrCPM0Kf8CmDy6wA0uDNo76cKOtrP6iJqvCzrWYAKoCAjGEtzpiVh51gIkvqIgzpynAKOl1jsJI4sTkxejtSGnYNiLBWCKbdxejtSGnYNifSTCUG4IiVMA8dlumiQMh8Syvkr(uqAYcEoMomDlnAQUtNDDbs0POuDKr4cIlI8AQXpSqXGOAEWZYI0aHzxxObmNIKkul0yjCynguWasAYcwIweSSgwKgim76c5JOLgA4IPCdMJQe3PLh524vNW1QROObI8E2uU54cIlI8AQXpSqXGOAEWZYI0aHzxxObmNIKkul0yjCynguWasAYcwIweSSgwKgim76c5JOLgA4IPCd4cIlI8AQXpSqXGOAEWZYI0aHzxxObmNIKkul0yjCynguWasAYcwIweSSgwKgim76c5JOLgA4IPCdMJQGenAIKhlXvSbUf3PLh524T6ISLgiY7ztxq4W(aeaXE)WH1ySpLSxr33H4(YK6wAus6(bWKUp5uR3xJX(QpI9Pvyl3hs0iDwYhrlP7NnnqxU)XUpzpJSR3N9G7tcnjmljGSPgNLeqpaAhDFsGanliUiYRPg)WcfdIQ5bpl5JOLfAf2sesAYcMR5Oyezxtnc1cnYGHe9ayzAN1addl5JOLOSeoSgdkaalul0ybBKprkNQKOfblRHfPbcZUUq(iAPHgUyka4OkirJMi5XsCfoYT4oT8i3gVvxKT0arEpB6cYcch4W(KyxKxVG4IiVMAe3PLh5McU6I8AstwWmDy6wA0W7K8dwe3PLh5MwCrKmrgmSokvfBwdmkqK3ZMYTTGYfeoWH9TX70YJCtxqCrKxtnI70YJCtNh8SoKxD5ylbqSirxsAYcwCNwEKBdrd80Qlw6SgyyGiVNnL7jvjUtlpYTr6WPLa6nL9G8EKxBGiVNnTGZScfbk5EsvHRXomenWtRUyPZAGbdgZfUg7Wq0apT6ILoRbgmyyDuQk2SgyuGiVNnLBoo5cIlI8AQrCNwEKB68GNLEe6ce9kesQqTqJLWH1yqbdiPjl4WH1yyIKhlXvQerHJtY9KQchwJHjsESexrMiaMuLlIKjwWg5tKYnyoUGWH9bf70s6(GwN1aJ9zp4(ev7h3(tUpffxlP7h3(u1TyFYzaCFsu1jCT6kks6(2SaicjNuK09jO4(KZa4(KGdNU)eqVPShK3J8AZcIlI8AQrCNwEKB68GNLObEA1flDwdminzbZ0HPBPrdnkvAV7SRvXL4oT8i3gV6eUwDffnqK3ZMwWzwHIaLCpjdgI70YJCB8Qt4A1vu0arEpBAbNzfkcucaaNbNQ4sCNwEKBJ0Htlb0Bk7b59iV2arEpBk31cjdgweSSgPdNwcO3u2dY7rETHOIZfexe51uJ4oT8i305bplrd80Qlw6SgyqAYc2frYelyJ8jsbayBzWW6OuvSznWOarEpBk32c4cIlI8AQrCNwEKB68GNv6WPLa6nL9G8EKxtAYcMPdt3sJgAuQ0E3zxRIl5fgIg4PvxS0znWOiVWarEpBkdgZfUg7Wq0apT6ILoRbgCUG4IiVMAe3PLh5Mop4zLoCAjGEtzpiVh51KMSGDrKmXc2iFIuaa2wgmSokvfBwdmkqK3ZMYTTaUG4IiVMAe3PLh5Mop4z9Qt4A1vuK0KfSlIKjwWg5tKcgqvs0IGL1WI0aHzxxiFeT0qdxmfaCCbXfrEn1iUtlpYnDEWZ6vNW1QROiPc1cnwchwJbfmGKMSGDrKmXc2iFIuaa2wvs0IGL1WI0aHzxxiFeT0qdxmfaCu1Cs0dGfVLfjkC1MiftZUEbXfrEn1iUtlpYnDEWZsj45VUu7W6tTgjnzbdj6uuQoYi0ir2uKb3aAdQ4sCNwEKBdrd80Qlw6SgyyGiVNnLBaNbdgYlmenWtRUyPZAGrrEHbI8E2uoxqCrKxtnI70YJCtNh8SenWtRU4uQtOdstwWmDy6wA0qJsL27o7Avs0IGL1WI0aHzxxiFeT0qdxmLBBvXvfggV6eLAGhH24IizImyyrWYAKoCAjGEtzpiVh51gIkvZvHHXH8Ql1apcTXfrYe5CbXfrEn1iUtlpYnDEWZs0apT6ItPoHoivOwOXs4WAmOGbK0KfSlIKjwWg5tKcaW2QsIweSSgwKgim76c5JOLgA4IPCB7cIlI8AQrCNwEKB68GNf6jfls0LKMSGNRcdtnWJqBCrKmXfeoWH9jHK6wAus6(KCcASFFX(q01A173hK317BHaDM5b3pa6HD09jFWa4(veqkr217NTnVANhnliCGd77IiVMAe3PLh5Mop4zPUaMSPiDDPYfbPjlyxejtSGnYNifaGTv1CweSSgPdNwcO3u2dY7rETHOs1CI70YJCBKoCAjGEtzpiVh51gi6s1myyDuQk2SgyuGiVNnL7AHCbzbHdCyFB8yIT3X(KiRuNrI0fexe51uJ4yIT3bfmLSd5ZUUWN0G0KfmthMULgn0OuP9UZUwfKOtrP6iJqJeztrgaaqqPkUe3PLh524vNW1QROObI8E2ugmMlCn2HXH8QlhBjaIfPZ3OuL4oT8i3gPdNwcO3u2dY7rETbI8E2uozWW6OuvSznWOarEpBk3ac4cch2xbJ9JBFckUVZgiCFV6e7N09VEFBKe23P7h3(vqKj2X(htek8QQSR3huGeBFYatnUpfJi769jQ23gjb7OliUiYRPgXXeBVd68GNLs2H8zxx4tAqAYcwCNwEKBJxDcxRUIIgiY7ztvXLlIKjwWg5tKcaW2QYfrYelyJ8js5g8KQGeDkkvhzeAKiBkYaaaoJ55YfrYelyJ8jsjXbLCYGHlIKjwWg5tKcGjvbj6uuQoYi0ir2uKbaSHzW5cIlI8AQrCmX27Gop4zDRJpBpYRl6K3I0KfmthMULgn0OuP9UZUw1C0JqBLT0OrxwSuxWz68vAufxI70YJCB8Qt4A1vu0arEpBkdgZfUg7W4qE1LJTeaXI05BuQsCNwEKBJ0Htlb0Bk7b59iV2arEpBkNQGenAIKhlXvSbaWfhN3IGL1aj6uuehesuf51giY7zt5KbdRJsvXM1aJce59SPCBlGliUiYRPgXXeBVd68GN1To(S9iVUOtElstwWmDy6wA0qJsL27o7Av0JqBLT0OrxwSuxWz68vAufxYlmenWtRUyPZAGrrEHbI8E2uaaiGmymx4ASddrd80Qlw6SgyOsCNwEKBJ0Htlb0Bk7b59iV2arEpBkNliUiYRPgXXeBVd68GN1To(S9iVUOtElstwWUisMybBKprkaaBRkirJMi5XsCfBaaCXX5TiyznqIoffXbHevrETbI8E2uoxqCrKxtnIJj2Eh05bplfOlMQXsaelen5dgavtAYcMPdt3sJgAuQ0E3zxRIlXDA5rUnE1jCT6kkAGiVNnLbJ5cxJDyCiV6YXwcGyr68nkvjUtlpYTr6WPLa6nL9G8EKxBGiVNnLtgmSokvfBwdmkqK3ZMYnGtUG4IiVMAehtS9oOZdEwkqxmvJLaiwiAYhmaQM0KfSlIKjwWg5tKcaW2QIlj6bWI3YIefUAtKIPzxZGb0tzbzIDyCPKAGiVNnLBWaAdCUGSGWboSVs21AC)jCyngliUiYRPMASrykalrpawexQjnzbBrWYAOesj2f5D8gi6Iq1CmDy6wA0uDNo76cKOtrP6iJqgmQWWu7W6tTgnUisM4cIlI8AQPgBeMI5bpRe9ayrCPM0KfmKOtrP6iJqJeztrgCdihzWGnRbgfiY7zt5EsvZjrlcwwdlsdeMDDH8r0sdr1cIlI8AQPgBeMI5bpR3QlYwsAYcwCNwEKBJxDcxRUIIgiY7ztvXv4ASdJeztnAW2T0OKbdXXeBVdtN1aJcRJmyajAK9G1OPci6WJ)AKYPkUMJPdt3sJMQ70zxxGenszWGnRbgfiY7zt5EsoxqCrKxtn1yJWump4zjFeTSqRWwIqstwWs0IGL1WI0aHzxxiFeT0qdxmfaCu1CmDy6wA0uDNo76cKOr6cIlI8AQPgBeMI5bpl5JOLfAf2sesAYcwIweSSgwKgim76c5JOLgIkvI70YJCB8Qt4A1vu0arEpBAbNzfkcucGjvnhthMULgnv3PZUUajAKUG4IiVMAQXgHPyEWZkrpawexQjnzbdj6uuQoYi0ir2uKb32odvZX0HPBPrt1D6SRlqIofLQJmcxqCrKxtn1yJWump4zzrAGWSRl0aMtrstwWs0IGL1WI0aHzxxiFeT0qdxmLBavnhthMULgnv3PZUUajAKUG4IiVMAQXgHPyEWZYI0aHzxxObmNIKMSGLOfblRHfPbcZUUq(iAPHgUyk32GkXDA5rUnE1jCT6kkAGiVNnTGZScfbk5EsvZX0HPBPrt1D6SRlqIgPliUiYRPMASrykMh8Ss0dGfXLAstwWZX0HPBPrt1D6SRlqIofLQJmcxqwq4ah2NKbBeMI9jrNn9(KyW8GzOEbHdCyFxe51utn2imff)qWK9mkShSiUtlpYnPTZJGPhHUarVcHKMSGdxJDyOhHUarVcHQchwJHjsESexPsefooj3tQInRbgfiY7ztbWKQe3PLh52qpcDbIEfcnqK3ZMYnx1cjj(mm2KtYPkxejtSGnYNiLBWCCbXfrEn1uJnctrXpCEWZkrpawexQjnzbZ1CmDy6wA0uDNo76cKOtrP6iJqgmSiyznucPe7I8oEdeDrWPkUSiyznshoTeqVPShK3J8AdrLkirJShSgns0L6ePrrCPwLlIKjwWg5tKYnyoYGHlIKjwWg5tKc2woxqCrKxtn1yJWuu8dNh8Syvkr(uqAYc2IGL1qjKsSlY74nq0fbdgZX0HPBPrt1D6SRlqIofLQJmcxqCrKxtn1yJWuu8dNh8SKpIwwOvylriPc1cnwchwJbfmGKMSG5sCNwEKBJxDcxRUIIgiY7ztbWKQKOfblRHfPbcZUUq(iAPHOIbdjArWYAyrAGWSRlKpIwAOHlMcaoYPkUyZAGrbI8E2uUf3PLh52irpaw8wwKOWvBGiVNnDEaNbdgSznWOarEpBkae3PLh524vNW1QROObI8E2uoxqCrKxtn1yJWuu8dNh8SSinqy21fAaZPiPc1cnwchwJbfmGKMSGLOfblRHfPbcZUUq(iAPHgUyk3G5OkXDA5rUnE1jCT6kkAGiVNnLBoYGHeTiyznSinqy21fYhrln0Wft5gWfexe51utn2imff)W5bpllsdeMDDHgWCksQqTqJLWH1yqbdiPjlyXDA5rUnE1jCT6kkAGiVNnfatQsIweSSgwKgim76c5JOLgA4IPCd4cYcch2huWfPRPliUiYRPgOlsxtb7qH3yjoie7G0KfmKOtrP6iJqJeztrgaauoPkUQWWu7W6tTgnUisMidgZfUg7Wqj45VUu7W6tTgny7wAuYPkirJgjYMImaa4jxqCrKxtnqxKUMop4zT03jlSeq1KMSGz6W0T0OH3j5hSiUtlpYnT4IizImyeoSgdtK8yjUImrUbBrWYAS03jlSeq1gjb0J86fexe51ud0fPRPZdEwlesr40SRjnzbZ0HPBPrdVtYpyrCNwEKBAXfrYezWiCyngMi5XsCfzICd2IGL1yHqkcNMDTrsa9iVEbXfrEn1aDr6A68GNvN1adAHKtiR5XoinzbBrWYAiAGNwDHgqSRdGgIQfeoSpjQfinGUEFB0169fEVFaZ6AeUVnSF1fyhPR33IGLLs6(OlaUV2Pr217d4K7trX1sQzFBUi1PnruUpqhk3xCsuUFK84(oDFF)aM11iC)42FkIv7NX(q0LULgnliUiYRPgOlsxtNh8SElqAaDDr4AnPjlyMomDlnA4Ds(blI70YJCtlUisMidgHdRXWejpwIRitKBWao5cIlI8AQb6I0105bpRdfEJLkcnfjnzb7IizIfSr(ePaaSTmyWfKOrJeztrgaa8KQGeDkkvhzeAKiBkYaaGbLZGZfexe51ud0fPRPZdEw2eIw67KKMSGz6W0T0OH3j5hSiUtlpYnT4IizImyeoSgdtK8yjUImrUbBrWYAytiAPVtAKeqpYRxqCrKxtnqxKUMop4zT86YXwcykMsjnzbBrWYAiAGNwDHgqSRdGgIkvUisMybBKprkyaxqwq4ah2Fcy2tXGUG4IiVMAcy2tXGcMGILmqEsBNhbNnvajc3sJfsIW7GGVirMPajnzbZL4oT8i3gIg4PvxS0znWWarEpBkdgI70YJCBKoCAjGEtzpiVh51giY7zt5ufxvyyCiV6snWJqBCrKmrgmQWW4vNOud8i0gxejtu1CHRXomoKxD5ylbqSiD(gLmyeoSgdtK8yjUsLik2odUNKtgmSokvfBwdmkqK3ZMYTTaUG4IiVMAcy2tXGop4zjOyjdKN025rW8UWTGyHceXOWtqtbPjlyXDA5rUnE1jCT6kkAGiVNnL7jvX1CijrKvvO0Knvajc3sJfsIW7GGVirMPazWqCNwEKBt2ubKiClnwijcVdc(IezMc0arEpBkNmyyDuQk2SgyuGiVNnLBBbCbXfrEn1eWSNIbDEWZsqXsgipPTZJGLq0LSjelmrkf1KMSGf3PLh524vNW1QROObI8E2uvCnhssezvfknztfqIWT0yHKi8oi4lsKzkqgme3PLh52Knvajc3sJfsIW7GGVirMPanqK3ZMYjdgwhLQInRbgfiY7zt5MJliUiYRPMaM9umOZdEwckwYa5jTDEeS0Ht5VRlsumTW8GUid1KMSGf3PLh524vNW1QROObI8E2uvCnhssezvfknztfqIWT0yHKi8oi4lsKzkqgme3PLh52Knvajc3sJfsIW7GGVirMPanqK3ZMYjdgwhLQInRbgfiY7zt52waxqCrKxtnbm7PyqNh8SeuSKbYtjnzbZL4oT8i3gV6eUwDffnqK3ZMYGHfblRr6WPLa6nL9G8EKxBiQ4ufxZHKerwvHst2ubKiClnwijcVdc(IezMcKbdXDA5rUnztfqIWT0yHKi8oi4lsKzkqde59SPCUGWboS)e2msWMbWliCGd7pbqC)aM9um2NCga3paI7dmRbI0yFKgjVhOCFMUMajDFYPwVVfUpbfL7ZMqASV3Y9R8eIY9jNbW9jrvNW1QRO4(CLS7BrWYUFs3hWj3NIIRL09p4(AKs5C)dUpO1znWywsyI95kz3VgIEGW9dGEVpGtUpffxlPCUGWboSVlI8AQjGzpfd68GNLGILmqEsP6lahWSNIbGKMSG5IRaM9ummaAQGNW4T6ISIAKeqpYR5gmGtQsCNwEKBJxDcxRUIIgiY7ztbGTZGbJaM9ummaAQGNW4T6ISIAKeqpYRbaGtQIlXDA5rUnenWtRUyPZAGHbI8E2uay7myWqCNwEKBJ0Htlb0Bk7b59iV2arEpBkaSDgCYPkUMlGzpfdJTgGoTiUtlpYndgbm7PyyS1iUtlpYTbI8E2ugmy6W0T0OjGzpfJsfmpygQbdiNCYGraZEkgganvWty8wDrwrnscOh51aamBwdmkqK3ZMUGWboSVlI8AQjGzpfd68GNLGILmqEsP6lahWSNIHTKMSG5IRaM9umm2AQGNW4T6ISIAKeqpYR5gmGtQsCNwEKBJxDcxRUIIgiY7ztbGTZGbJaM9umm2AQGNW4T6ISIAKeqpYRbaGtQIlXDA5rUnenWtRUyPZAGHbI8E2uay7myWqCNwEKBJ0Htlb0Bk7b59iV2arEpBkaSDgCYPkUMlGzpfddGgGoTiUtlpYndgbm7Pyya0iUtlpYTbI8E2ugmy6W0T0OjGzpfJsfmpygQbBlNCYGraZEkggBnvWty8wDrwrnscOh51aamBwdmkqK3ZMUGWboSpaj7(xRvV)14(xVpbf3pGzpfJ9RGhZuI0999TiyzjDFckUFae3)cGiC)R3xCNwEKBZ(2m4(j7(nMbqeUFaZEkg7xbpMPeP777BrWYs6(euCFRlaU)17lUtlpYTzbHdCyFxe51utaZEkg05bplbflzG8Ks1xaoGzpfdajnzbpxaZEkgganaDAHGIflcwwvCfWSNIHXwJ4oT8i3giY7ztzWyUaM9umm2Aa60cbflweSSCUGWboSVlI8AQjGzpfd68GNLGILmqEsP6lahWSNIHTKMSGNlGzpfdJTgGoTqqXIfblRkUcy2tXWaOrCNwEKBde59SPmymxaZEkgganaDAHGIflcwwohkora8GdfLKNq7rETncD2yeJymaa]] )

end
