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


    spec:RegisterPack( "Unholy", 20210308, [[d8e)UbqifjpsruBIG(ebAuubNIk0QueHELIkZIkYTueb2Lq)srXWaahdqwMIWZqOmneQ6AkkTnfr6Bck04aukNdaswNIuEhcvcZJaUhISpfvDqaLSqa0dbu1ebu5IaqQpcOunseQeDsaOALa0lrOsAMck6MiuPStQO(PGcAOaqzPaq8uu1ufuDvbfyRkIG(QIiASks1Ev4Vu1Gv1HPSyc9yIMmjxgAZi1NPsJgbNwQvJqfVgHmBsDBuz3s(TkdxGJdOy5GEoktx01bA7iQVJeJxqPZliRhHkvZhjTFLEa0i8bVYsC48eaWeabaedaa2ItmbqHrIpmo4Zqb4GpWKezU4GVmoCWhgueoDObFGfsFMAe(GNDGqjo4jKzaBAZmJBNeafJYJBgwZbQTSVscn6CgwZjNzWlc26eaVgIdELL4W5jaGjacaigaaSfNycGcJtmPdEwakhopXStm4j0kfwdXbVczYbpWHwsyFIRv7si3pmOiC6qlGe3mOKW(aBoT)eaWeaTaUacSuehqwYHvY2pV9bUc4Mb4q6wJZaCOLey7dCG4(5T)v6q7lpWk3pnOlMS9Pq423G4(yydqzIQ9ZBFDtg3xFL7(yDGUe2pV95Smr4(oyh6zycgS)KbYX4ciW1mtuJQ95njSPBzB69bWmzUViknqgUVcn1(UeoqnBFoJiCF6dUpZu7dCexzXfWWawxU7pjpWsTpFawkeUVj26oBKTp3bX9P1yyBrDO9DWY9j(52NLMKi2(DXs0u7F07p7CosCX(ahag)(fcMqtVVvQ95Sq7harYyL7ZooC)6Mear5(SobTSVIfxabEcw5IQ95Sk0(cs3Uespe5SUycUV8kvN9vMMTFE7Bbb6q731(IhJTpD7siz7FLo0(oOrgBFGh42NIXsC)R2pHgJGJXbVUzjBe(G3o0ZWemye(WzGgHp4XYe1OAaWbVe2jcBBWRqlj4jQAxczKMYbwku5td6IjB)5jTVmKuJESqUgz7tL6(qRvEKmwz0ukwedBZs2(c3hATYJKXkJMsXIqKZ6ITVaK2hiGg8Mm7Rg8wfYRk1ihopXi8bpwMOgvdao4LWoryBdEfAjbprv7siJ0uoWsHkFAqxmz7ppP9NDWBYSVAWBviVQuJC4mXgHp4XYe1OAaWbVe2jcBBWp1(KnyBIAmgCNUlxpeSAPp4OGW9fUVd7lcsthvgKiFcTIrFqol7RIGb7lCFiyH0h0fJk0u6gzPxEToILjQr1(c33Kztg9yHCnY2xas7tS9PsDFtMnz0JfY1iBFs7pX(oo4nz2xn4vOLe8YR1JC4mXpcFWJLjQr1aGdEjSte22GFQ9jBW2e1ym4oDxUEiy1sFWrbHdEtM9vdEmOvixlh5W5zhHp4XYe1OAaWbVjZ(QbpnYse2LRNLWMiCWlHDIW2g8kueKMosJSeHD56PCGLkYsts0(cqAFITVW9L3PvhLkAbN00HcyyeICwxS9fyFIn4LHKA0Ng0ft2WzGg5W5jDe(GhltuJQbah8Mm7Rg80ilryxUEwcBIWbVe2jcBBWRqrqA6inYse2LRNYbwQilnjr7lW(an4LHKA0Ng0ft2WzGg5W5W4i8bpwMOgvdao4nz2xn4PrwIWUC9Se2eHdEjSte22GhcwymBo0NNN43xG9DyF5DA1rPIk0scERuEfkTqriYzDX2x4(tTFAASYOcPBngXYe1OAFQu3xENwDuQOcPBngHiN1fBFH7NMgRmQq6wJrSmrnQ23XbVmKuJ(0GUyYgod0ihodSncFWJLjQr1aGdEtM9vdEkhyP8SaSuiCWRqMe2bzF1GFssaR9td6I5(mkwaBFdI7RAMjQrLt7NeA2(uATEFnM7h6a3NfGLAFiyHSzOCGLITFxSen1(h9(uSo7YDF6dUpWva3mahs3ACgGdTKGGS9boqmo4LWoryBd(P2NHz2Lllkdj14(c3xHIG00rAKLiSlxpLdSurwAsI2F(9j2(c3hcwymBo0NNNy7lW(Y70QJsfTkKxvQie5SUyJCKdE7qViiKLJWhod0i8bpwMOgvdao4LWoryBdEh2xeKMoYavkS8Q74Iq0K5(uPU)u7t2GTjQXyWD6UC9qWQL(GJcc33X9fUVd7lcsthvgKiFcTIrFqol7RIGb7lCFiyH0h0fJk0u6gzPxEToILjQr1(c33Kztg9yHCnY2xas7tS9PsDFtMnz0JfY1iBFs7pX(oo4nz2xn4vOLe8YR1JC48eJWh8yzIAuna4Gxc7eHTn4HGvl9bhfegviDl7CFb23H9bca2FU9vOLe8evTlHmst5alfQ8PbDXKT)K4(eBFh3x4(k0scEIQ2LqgPPCGLcv(0GUyY2xG9N09fU)u7t2GTjQXyWD6UC9qWQL(GJcc3Nk19fbPPJmkgKRlxpxZYiyWG3KzF1GhdAfY1YroCMyJWh8yzIAuna4Gxc7eHTn4HGvl9bhfegviDl7CFb2FIz3x4(k0scEIQ2LqgPPCGLcv(0GUyY2F(9NDFH7p1(KnyBIAmgCNUlxpeSAPp4OGWbVjZ(Qbpg0kKRLJC4mXpcFWJLjQr1aGdEjSte22GFQ9vOLe8evTlHmst5alfQ8PbDXKTVW9NAFYgSnrngdUt3LRhcwT0hCuq4(uPUpD7si9qKZ6ITVa7p7(uPUp0ALhjJvgnLIfXW2SKTVW9HwR8izSYOPuSie5SUy7lW(Zo4nz2xn4XGwHCTCKdNNDe(G3KzF1GNYbwkplalfch8yzIAuna4ihopPJWh8yzIAuna4Gxc7eHTn4NAFYgSnrngdUt3LRhcwT0hCuq4G3KzF1GhdAfY1YroYbVlwiSLJWhod0i8bpwMOgvdao4LWoryBdErqA6iduPWYRUJlcrtM7lC)P2NSbBtuJXG70D56HGvl9bhfeUpvQ7hGz01GUxingnz2KXbVjZ(QbVcTKGxETEKdNNye(GhltuJQbah8syNiSTbpeSAPp4OGWOcPBzN7lW(arS9PsDF62Lq6HiN1fBFb2F29fU)u7RqrqA6inYse2LRNYbwQiyWG3KzF1GxHwsWlVwpYHZeBe(GhltuJQbah8syNiSTbV8oT6Ourl4KMouadJqKZ6ITVW9Dy)00yLrfs3AmILjQr1(uPUV8iJLvzSAxcPN2W9PsDFiyH0h0fJbeqdECxHSiwMOgv774(c33H9NAFYgSnrngdUt3LRhcwiBFQu3NUDjKEiYzDX2xG9NDFhh8Mm7Rg8wfYRk1ihot8JWh8yzIAuna4Gxc7eHTn4vOiinDKgzjc7Y1t5alvKLMKO9NFFITVW9NAFYgSnrngdUt3LRhcwiBWBYSVAWt5alLNfGLcHJC48SJWh8yzIAuna4Gxc7eHTn4vOiinDKgzjc7Y1t5alvemyFH7lVtRokv0coPPdfWWie5SUyEmSbOmr1(ZV)S7lC)P2NSbBtuJXG70D56HGfYg8Mm7Rg8uoWs5zbyPq4ihopPJWh8yzIAuna4Gxc7eHTn4HGvl9bhfegviDl7CFb2FcayFH7p1(KnyBIAmgCNUlxpeSAPp4OGWbVjZ(QbVcTKGxETEKdNdJJWh8yzIAuna4Gxc7eHTn4vOiinDKgzjc7Y1t5alvKLMKO9fyFG2x4(tTpzd2MOgJb3P7Y1dblKn4nz2xn4PrwIWUC9Se2eHJC4mW2i8bpwMOgvdao4LWoryBdEfkcsthPrwIWUC9uoWsfzPjjAFb2N43x4(Y70QJsfTGtA6qbmmcroRlMhdBaktuTVa7p7(c3FQ9jBW2e1ym4oDxUEiyHSbVjZ(QbpnYse2LRNLWMiCKdNbqncFWJLjQr1aGdEjSte22GFQ9jBW2e1ym4oDxUEiy1sFWrbHdEtM9vdEfAjbV8A9ih5GxEKXYQKncF4mqJWh8yzIAuna4Gxc7eHTn4jBW2e1yKL(aTvvxU7lCFiy1sFWrbHrfs3Yo3F(9bAs3x4(oSV8oT6Ourl4KMouadJqKZ6ITpvQ7p1(PPXkJgKlK)O9jb0RmUcvrSmrnQ2x4(Y70QJsfvgKiFcTIrFqol7RIqKZ6ITVJ7tL6(IhJTVW9PBxcPhICwxS9fyFGaAWBYSVAWZOyqUUC9Cnlh5W5jgHp4XYe1OAaWbVjZ(QbpJIb56Y1Z1SCWRqMe2bzF1GNhZ9ZBFqgUVrNiCFl4K73S9VAFGh423y7N3(bqKmw5(hzekTGGUC3habaBFkeAnUpdZSl39bd2h4bobzdEjSte22GxENwDuQOfCsthkGHriYzDX2x4(oSVjZMm6Xc5AKT)8K2FI9fUVjZMm6Xc5AKTVaK2F29fUpeSAPp4OGWOcPBzN7p)(aba7p3(oSVjZMm6Xc5AKT)K4(t6(oUpvQ7BYSjJESqUgz7p)(ZUVW9HGvl9bhfegviDl7C)53N4bG9DCKdNj2i8bpwMOgvdao4LWoryBdEYgSnrngzPpqBv1L7(c3FQ9zhOwSlvuJMYlgYJH14c0yeltuJQ9fUVd7lVtRokv0coPPdfWWie5SUy7tL6(tTFAASYOb5c5pAFsa9kJRqveltuJQ9fUV8oT6OurLbjYNqRy0hKZY(Qie5SUy774(c3hcwymBo0NNN43F(9DyFIT)C7lcsthHGvl9YdcbdY(Qie5SUy774(uPUV4Xy7lCF62Lq6HiN1fBFb2FcGg8Mm7Rg8M4X1LL9vEDZjoYHZe)i8bpwMOgvdao4LWoryBdEYgSnrngzPpqBv1L7(c3NDGAXUurnAkVyipgwJlqJrSmrnQ2x4(oSV6Yiyr40H8I62Lq6vxgHiN1fB)53hiG2Nk19NA)00yLrWIWPd5f1TlHmILjQr1(c3xENwDuQOYGe5tOvm6dYzzFveICwxS9DCWBYSVAWBIhxxw2x51nN4ihop7i8bpwMOgvdao4LWoryBdEtMnz0JfY1iB)5jT)e7lCFiyHXS5qFEEIF)533H9j2(ZTViinDecwT0lpiemi7RIqKZ6ITVJdEtM9vdEt846YY(kVU5eh5W5jDe(GhltuJQbah8syNiSTbpzd2MOgJS0hOTQ6YDFH77W(Y70QJsfTGtA6qbmmcroRl2(uPU)u7NMgRmAqUq(J2NeqVY4kufXYe1OAFH7lVtRokvuzqI8j0kg9b5SSVkcroRl2(oUpvQ7lEm2(c3NUDjKEiYzDX2xG9bA2bVjZ(QbpJGjjsJ(Ka6blkhmjeAKdNdJJWh8yzIAuna4Gxc7eHTn4nz2KrpwixJS9NN0(tSVW9DyFfAjbVvkVcLwOy2sI6YDFQu3hATYJKXkJMsXIqKZ6ITVaK2hiIFFhh8Mm7Rg8mcMKin6tcOhSOCWKqOroYbFaeLhNOLJWhod0i8bVjZ(QbFWL9vdESmrnQgaCKdNNye(G3KzF1GhAnd9k0udESmrnQgaCKJCWlVtRokfBe(WzGgHp4XYe1OAaWbVe2jcBBWt2GTjQXiNrCoOxENwDukM3Kztg3Nk19fpgBFH7t3Uespe5SUy7lW(tmPdEtM9vd(Gl7Rg5W5jgHp4XYe1OAaWbVe2jcBBWlVtRokveSiC6qErD7siJqKZ6ITVa7p7(c3xENwDuQOYGe5tOvm6dYzzFveICwxmpg2auMOAFb2F29fUFAASYiyr40H8I62LqgXYe1OAFQu3FQ9ttJvgblcNoKxu3UeYiwMOgv7tL6(IhJTVW9PBxcPhICwxS9fyFIn7G3KzF1G3GCH8hTpjGEfAQroCMyJWh8yzIAuna4G3KzF1GNDGApeTaeo4LWoryBd(0GUygZMd955dKPNyZUVa7p7(c3pnOlMXS5qFEEvJ7p)(ZUVW9nz2KrpwixJS9fG0(eBWldj1OpnOlMSHZanYHZe)i8bpwMOgvdao4nz2xn4blcNoKxu3UeYbVczsyhK9vdEIlpTITpa1TlHCF6dUpyW(5T)S7Zq5vk2(5Tpluj3NsNe2hyfCsthkGHoTFyysaHuAg60(GmCFkDsyFGZGeTF4qRy0hKZY(Q4Gxc7eHTn4jBW2e1yKL(aTvvxU7lCFh2xENwDuQOfCsthkGHriYzDX8yydqzIQ9fy)z3Nk19L3PvhLkAbN00HcyyeICwxmpg2auMOA)53hiayFh3x4(oSV8oT6OurLbjYNqRy0hKZY(Qie5SUy7lW(Us1(uPUViinDuzqI8j0kg9b5SSVkcgSVJJC48SJWh8yzIAuna4Gxc7eHTn4nz2KrpwixJS9NN0(tSpvQ7lEm2(c3NUDjKEiYzDX2xG9NaObVjZ(Qbpyr40H8I62LqoYHZt6i8bpwMOgvdao4LWoryBdEYgSnrngzPpqBv1L7(c33H9vxgblcNoKxu3UesV6Yie5SUy7tL6(tTFAASYiyr40H8I62LqgXYe1OAFhh8Mm7Rg8kdsKpHwXOpiNL9vJC4CyCe(GhltuJQbah8syNiSTbVjZMm6Xc5AKT)8K2FI9PsDFXJX2x4(0TlH0droRl2(cS)ean4nz2xn4vgKiFcTIrFqol7Rg5WzGTr4dESmrnQgaCWlHDIW2g8MmBYOhlKRr2(K2hO9fUVcfbPPJ0ilryxUEkhyPIS0KeT)87tSbVjZ(QbVfCsthkGHJC4maQr4dESmrnQgaCWBYSVAWBbN00Hcy4Gxc7eHTn4nz2KrpwixJS9NN0(tSVW9vOiinDKgzjc7Y1t5alvKLMKO9NFFITVW9NAFfAjbVvkVcLwOy2sI6YDWldj1OpnOlMSHZanYHZabaJWh8yzIAuna4Gxc7eHTn4HGvl9bhfegviDl7CFb2hiIFFH77W(Y70QJsfblcNoKxu3UeYie5SUy7lW(aba7tL6(QlJGfHthYlQBxcPxDzeICwxS9DCWBYSVAWZa54UY7Aq3lKgh5WzGaAe(GhltuJQbah8syNiSTbpzd2MOgJS0hOTQ6YDFH7RqrqA6inYse2LRNYbwQilnjr7lW(tSVW9Dy)amJwWj9UeoqD0Kztg3Nk19fbPPJkdsKpHwXOpiNL9vrWG9fU)u7hGz0GCH8UeoqD0Kztg33XbVjZ(Qbpyr40H8gJzG6CKdNbAIr4dESmrnQgaCWBYSVAWdweoDiVXygOoh8syNiSTbVjZMm6Xc5AKT)8K2FI9fUVcfbPPJ0ilryxUEkhyPIS0KeTVa7pXGxgsQrFAqxmzdNbAKdNbIyJWh8yzIAuna4Gxc7eHTn4NA)amJUeoqD0Kztgh8Mm7Rg8qRzOxHMAKJCW7IfcBP3oCe(WzGgHp4XYe1OAaWbVjZ(QbpfRtp9b9Y70QJsn4LWoryBd(00yLr2bQ9q0cqyeltuJQ9fUFAqxmJzZH(88bY0tSz3xG9NDFH7t3Uespe5SUy7p)(ZUVW9L3PvhLkYoqThIwacJqKZ6ITVa77W(Us1(tI7daXW4S774(c33Kztg9yHCnY2xas7tSbFzC4GNDGApeTaeoYHZtmcFWJLjQr1aGdEjSte22G3H9NAFYgSnrngdUt3LRhcwT0hCuq4(uPUViinDKbQuy5v3XfHOjZ9DCFH77W(IG00rLbjYNqRy0hKZY(QiyW(c3hcwi9bDXOcnLUrw6LxRJyzIAuTVW9nz2KrpwixJS9fG0(eBFQu33Kztg9yHCnY2N0(tSVJdEtM9vdEfAjbV8A9ihotSr4dESmrnQgaCWlHDIW2g8IG00rgOsHLxDhxeIMm3Nk19NAFYgSnrngdUt3LRhcwT0hCuq4G3KzF1GhdAfY1YroCM4hHp4XYe1OAaWbVjZ(QbpLdSuEwawkeo4LWoryBdEh2xENwDuQOfCsthkGHriYzDX2F(9NDFH7RqrqA6inYse2LRNYbwQiyW(uPUVcfbPPJ0ilryxUEkhyPIS0KeT)87tS9DCFH77W(0TlH0droRl2(cSV8oT6OurfAjbVvkVcLwOie5SUy7p3(aba7tL6(0TlH0droRl2(ZVV8oT6Ourl4KMouadJqKZ6ITVJdEziPg9PbDXKnCgOroCE2r4dESmrnQgaCWBYSVAWtJSeHD56zjSjch8syNiSTbVcfbPPJ0ilryxUEkhyPIS0KeTVaK2Ny7lCF5DA1rPIwWjnDOaggHiN1fBFb2Ny7tL6(kueKMosJSeHD56PCGLkYsts0(cSpqdEziPg9PbDXKnCgOroCEshHp4XYe1OAaWbVjZ(QbpnYse2LRNLWMiCWlHDIW2g8Y70QJsfTGtA6qbmmcroRl2(ZV)S7lCFfkcsthPrwIWUC9uoWsfzPjjAFb2hObVmKuJ(0GUyYgod0ih5GxH0gOohHpCgOr4dEtM9vdEUUuEAiIe3XbpwMOgvdaoYHZtmcFWJLjQr1aGd(lyWZWCWBYSVAWt2GTjQXbpztdIdE5DA1rPImqoUR8Ug09cPXie5SUy7lW(ZUVW9ttJvgzGCCx5DnO7fsJrSmrnQg8KnOVmoCWhCNUlxpeSAPp4OGWroCMyJWh8yzIAuna4G)cg8mmh8Mm7Rg8KnyBIACWt20G4GpnnwzKDGApeTaegXYe1OAFH7dblCFb2FI9fUFAqxmJzZH(88bY0tSz3xG9NDFH7t3Uespe5SUy7p)(Zo4jBqFzC4Gp4oDxUEiyHSroCM4hHp4XYe1OAaWb)fm4zyo4nz2xn4jBW2e14GNSPbXbVjZMm6Xc5AKTpP9bAFH77W(tTp0ALhjJvgnLIfXW2SKTpvQ7dTw5rYyLrtPyXU2F(9bA29DCWt2G(Y4Wbpl9bARQUCh5W5zhHp4XYe1OAaWb)fm4zyo4nz2xn4jBW2e14GNSPbXbFaMrxd6EH0y0Kztg3Nk19fbPPJGfHthYBmMbQZiyW(uPUFAASYOb5c5pAFsa9kJRqveltuJQ9fUFaMrl4KExchOoAYSjJ7tL6(IG00rLbjYNqRy0hKZY(QiyWGNSb9LXHdEoJ4CqV8oT6OumVjZMmoYHZt6i8bpwMOgvdao4LWoryBdEiy1sFWrbHrfs3Yo3F(9N0z3x4(oSFaMrxd6EH0y0Kztg3Nk19NA)00yLrgih3vExd6EH0yeltuJQ9DCFH7dblmQq6w25(ZtA)zh8Mm7Rg8guAf6ZdcXkh5W5W4i8bpwMOgvdao4LWoryBdEYgSnrng5mIZb9Y70QJsX8MmBY4(uPUFAqxmJzZH(88Qg3xas7lcsthf13P80GWqrfi0Y(QbVjZ(QbVO(oLNgegAKdNb2gHp4XYe1OAaWbVe2jcBBWt2GTjQXiNrCoOxENwDukM3Kztg3Nk19td6IzmBo0NNx14(cqAFrqA6OicziKOUCJkqOL9vdEtM9vdEreYqirD5oYHZaOgHp4XYe1OAaWbVe2jcBBWlcsthblcNoKNLqSCtcrWGbVjZ(QbVUDjKmpXbu5YHvoYHZabaJWh8yzIAuna4G3KzF1G3kjYsOP9stRh8kKjHDq2xn4bwLezj007d8MwVV0Q9ty76IW9j(9dUeRSn9(IG00mN2hnjH91gl7YDFGMDFgkVsXI7hgKTUjUJQ9jyq1(YtHQ9ZMd33y7B7NW21fH7N3(eHyW(DUpenLjQX4Gxc7eHTn4jBW2e1yKZioh0lVtRokfZBYSjJ7tL6(PbDXmMnh6ZZRACFbiTpqZoYHZab0i8bpwMOgvdao4LWoryBdEtMnz0JfY1iB)5jT)e7tL6(oSpeSWOcPBzN7ppP9NDFH7dbRw6dokimQq6w25(ZtA)jfa23XbVjZ(QbVbLwH(aqndh5WzGMye(GhltuJQbah8syNiSTbpzd2MOgJCgX5GE5DA1rPyEtMnzCFQu3pnOlMXS5qFEEvJ7laP9fbPPJ0nef13PIkqOL9vdEtM9vdE6gII67uJC4mqeBe(GhltuJQbah8syNiSTbViinDeSiC6qEwcXYnjebd2x4(MmBYOhlKRr2(K2hObVjZ(QbVO56pAFcBjrSroCgiIFe(GhltuJQbah8Mm7Rg8hykcrJObVczsyhK9vdEIBwxP1vxU7pjSHGASY9bW0MliUFZ232pa2hSZqdEjSte22GxDzKCdb1yL(aT5cIrisdrgbtuJ7lC)P2pnnwzeSiC6qErD7siJyzIAuTVW9NAFO1kpsgRmAkflIHTzjBKdNbA2r4dESmrnQgaCWlHDIW2g8QlJKBiOgR0hOnxqmcrAiYiyIACFH7BYSjJESqUgz7ppP9NyFH77W(tTFAASYiyr40H8I62LqgXYe1OAFQu3pnnwzeSiC6qErD7siJyzIAuTVW9L3PvhLkcweoDiVOUDjKriYzDX23XbVjZ(Qb)bMIq0iAKdNbAshHp4XYe1OAaWbVe2jcBBWdblK(GUyKbgGqwcTUIyzIAuTVW9DyF1LrA4XspnsgHrisdrgbtuJ7tL6(QlJI67u(aT5cIrisdrgbtuJ774G3KzF1G)atriAenYHZafghHp4XYe1OAaWbVczsyhK9vdEGLm7R2pmBwY23k1(HHbyHq2(oeggGfczZWJadiwsKTpyXadcoyIQ97AFtPUk64G3KzF1GxAAT3KzFLx3SCWRBw6lJdh8jSlIWKnYHZabSncFWJLjQr1aGdEtM9vdEPP1EtM9vEDZYbVUzPVmoCWlpYyzvYg5WzGaqncFWJLjQr1aGdEfYKWoi7Rg8Mm7RyrfsBG6CosZWqGbelj6uttYKztg9yHCnYibKWPuOLe8evTlHmQAMjQrVDPYPY4qsxawiCAgKlK)O9jb0RqtnnAKLiSlxplHnr40OrwIWUC9Se2eHtdSiC6qErD7siNwWL9vttzqI8j0kg9b5SSVAAwWjnDOago4nz2xn4LMw7nz2x51nlh86ML(Y4WbV8oT6OuSroCEcaye(GhltuJQbah8syNiSTbVjZMm6Xc5AKT)8K2FI9fUVd7lVtRokvuHwsWBLYRqPfkcroRl2(cSpqaW(c3FQ9ttJvgviDRXiwMOgv7tL6(Y70QJsfviDRXie5SUy7lW(aba7lC)00yLrfs3AmILjQr1(oUVW9NAFfAjbVvkVcLwOy2sI6YDWBYSVAWdblVjZ(kVUz5Gx3S0xgho4Td9mmbdg5W5jaAe(GhltuJQbah8syNiSTbVjZMm6Xc5AKT)8K2FI9fUVcTKG3kLxHslumBjrD5o4nz2xn4HGL3KzFLx3SCWRBw6lJdh82HErqilh5W5jMye(GhltuJQbah8syNiSTbVjZMm6Xc5AKT)8K2FI9fUVd7p1(k0scERuEfkTqXSLe1L7(c33H9L3PvhLkQqlj4Ts5vO0cfHiN1fB)53hiayFH7p1(PPXkJkKU1yeltuJQ9PsDF5DA1rPIkKU1yeICwxS9NFFGaG9fUFAASYOcPBngXYe1OAFh33XbVjZ(QbpeS8Mm7R86MLdEDZsFzC4G3fle2sVD4ihopbXgHp4XYe1OAaWbVe2jcBBWBYSjJESqUgz7tAFGg8Mm7Rg8stR9Mm7R86MLdEDZsFzC4G3fle2YroYbFc7IimzJWhod0i8bpwMOgvdao4nz2xn47IjHGPjQrpWaAvcY5vi5wIdEjSte22G3H9L3PvhLkcweoDiVOUDjKriYzDX2Nk19L3PvhLkQmir(eAfJ(GCw2xfHiN1fBFh3x4(oSFaMrdYfY7s4a1rtMnzCFQu3paZOfCsVlHduhnz2KX9fU)u7NMgRmAqUq(J2NeqVY4kufXYe1OAFQu3pnOlMXS5qFE(az6Naa2xG9NDFh3Nk19fpgBFH7t3Uespe5SUy7lW(ta0GVmoCW3ftcbttuJEGb0QeKZRqYTeh5W5jgHp4XYe1OAaWbVjZ(QbpNjnri6zeqm9CGSwo4LWoryBdE5DA1rPIwWjnDOaggHiN1fBFb2F29fUVd7p1(iWa2bbOk2ftcbttuJEGb0QeKZRqYTe3Nk19L3PvhLk2ftcbttuJEGb0QeKZRqYTeJqKZ6ITVJ7tL6(IhJTVW9PBxcPhICwxS9fy)jaAWxgho45mPjcrpJaIPNdK1YroCMyJWh8yzIAuna4G3KzF1Gxbrtr3q0tgzmup4LWoryBdE5DA1rPIwWjnDOaggHiN1fBFH77W(tTpcmGDqaQIDXKqW0e1OhyaTkb58kKClX9PsDF5DA1rPIDXKqW0e1OhyaTkb58kKClXie5SUy774(uPUV4Xy7lCF62Lq6HiN1fBFb2Nyd(Y4WbVcIMIUHONmYyOEKdNj(r4dESmrnQgaCWBYSVAWRmirC3vEfkjYt(GMSZqdEjSte22GxENwDuQOfCsthkGHriYzDX2x4(oS)u7JadyheGQyxmjemnrn6bgqRsqoVcj3sCFQu3xENwDuQyxmjemnrn6bgqRsqoVcj3smcroRl2(oUpvQ7lEm2(c3NUDjKEiYzDX2xG9NaObFzC4GxzqI4UR8kusKN8bnzNHg5W5zhHp4XYe1OAaWbVe2jcBBW7W(Y70QJsfTGtA6qbmmcroRl2(uPUViinDuzqI8j0kg9b5SSVkcgSVJ7lCFh2FQ9rGbSdcqvSlMecMMOg9adOvjiNxHKBjUpvQ7lVtRokvSlMecMMOg9adOvjiNxHKBjgHiN1fBFhh8Mm7Rg8Gm03jYXg5ih5GNmcz9vdNNaaMaiaGyaqyCWtXGvxUSb)KeybG4maUZa7tB)9dNaUFZfCWCF6dUVG2HEgMGbcUpebgWgIQ9zhhUVbMhNLOAFjbRCrwCbmm7c3NytBFG)kYimr1(ccblK(GUyC6cUFE7lieSq6d6IXPhXYe1OsW9DaOW6yCbmm7c3pmoT9b(RiJWev7lyAASY40fC)82xW00yLXPhXYe1OsW9DyIW6yCbCbCscSaqCga3zG9PT)(Hta3V5coyUp9b3xq7qViiKLcUpebgWgIQ9zhhUVbMhNLOAFjbRCrwCbmm7c3hOPTpWFfzeMOAFbHGfsFqxmoDb3pV9fecwi9bDX40JyzIAuj4(oauyDmUaUaojbwaiodG7mW(02F)WjG73Cbhm3N(G7lOlwiSLcUpebgWgIQ9zhhUVbMhNLOAFjbRCrwCbmm7c3NytBFG)kYimr1(ccblK(GUyC6cUFE7lieSq6d6IXPhXYe1OsW9DaOW6yCbCbCscSaqCga3zG9PT)(Hta3V5coyUp9b3xq5rglRsMG7drGbSHOAF2XH7BG5XzjQ2xsWkxKfxadZUW9bAA7d8xrgHjQ2xW00yLXPl4(5TVGPPXkJtpILjQrLG77aqH1X4cyy2fUpXM2(a)vKryIQ9fmnnwzC6cUFE7lyAASY40JyzIAuj4(oauyDmUagMDH7tSPTpWFfzeMOAFbzhOwSlvC6cUFE7li7a1IDPItpILjQrLG77aqH1X4cyy2fUpXpT9b(RiJWev7lyAASY40fC)82xW00yLXPhXYe1OsW9DaOW6yCbmm7c3N4N2(a)vKryIQ9fKDGAXUuXPl4(5TVGSdul2Lko9iwMOgvcUVdafwhJlGHzx4(t602h4VImctuTVGPPXkJtxW9ZBFbttJvgNEeltuJkb33bGcRJXfWfWjjWcaXzaCNb2N2(7hobC)Ml4G5(0hCFbL3PvhLIj4(qeyaBiQ2NDC4(gyECwIQ9LeSYfzXfWWSlC)jM2(a)vKryIQ9fmnnwzC6cUFE7lyAASY40JyzIAuj4(omryDmUagMDH7pPtBFG)kYimr1(cMMgRmoDb3pV9fmnnwzC6rSmrnQeCFhakSogxaxaNKalaeNbWDgyFA7VF4eW9BUGdM7tFW9f0fle2sVDOG7drGbSHOAF2XH7BG5XzjQ2xsWkxKfxadZUW9bAA7hgumWGGdMOAFtM9v7lifRtp9b9Y70QJsjyCbmm7c3hOPTpWFfzeMOAFbttJvgNUG7N3(cMMgRmo9iwMOgvcUVdafwhJlGHzx4(tmT9b(RiJWev7lieSq6d6IXPl4(5TVGqWcPpOlgNEeltuJkb33bGcRJXfWfWjjWcaXzaCNb2N2(7hobC)Ml4G5(0hCFbtyxeHjtW9HiWa2quTp74W9nW84Sev7ljyLlYIlGHzx4(anT9b(RiJWev7lyAASY40fC)82xW00yLXPhXYe1OsW9DaOW6yCbCbCscSaqCga3zG9PT)(Hta3V5coyUp9b3xqfsBG6uW9HiWa2quTp74W9nW84Sev7ljyLlYIlGHzx4(tmT9b(RiJWev7lyAASY40fC)82xW00yLXPhXYe1OsW9TCFa0HHH5(oauyDmUagMDH7tSPTpWFfzeMOAFbttJvgNUG7N3(cMMgRmo9iwMOgvcUVdafwhJlGHzx4(ZoT9b(RiJWev7lyAASY40fC)82xW00yLXPhXYe1OsW9DaOW6yCbmm7c3hiIFA7d8xrgHjQ2xW00yLXPl4(5TVGPPXkJtpILjQrLG77aqH1X4cyy2fUpqZoT9b(RiJWev7lyAASY40fC)82xW00yLXPhXYe1OsW9DyIW6yCbmm7c3hOjDA7d8xrgHjQ2xqiyH0h0fJtxW9ZBFbHGfsFqxmo9iwMOgvcUVdafwhJlGHzx4(taatBFG)kYimr1(cMMgRmoDb3pV9fmnnwzC6rSmrnQeCFhMiSogxadZUW9NyIPTpWFfzeMOAFbttJvgNUG7N3(cMMgRmo9iwMOgvcUVdtewhJlGlGa4Cbhmr1(aO23KzF1(6MLS4c4G3atchCWZ3CGAl7RaEOrNd(a4r3ACWp5jVpWHwsyFIRv7si3pmOiC6qlGtEY7tCZGsc7dS50(taata0c4c4KN8(alfXbKLCyLS9ZBFGRaUzaoKU14mahAjb2(ahiUFE7FLo0(YdSY9td6IjBFkeU9niUpg2auMOA)82x3KX91x5UpwhOlH9ZBFolteUVd2HEgMGb7pzGCmUao5jVpW1mtuJQ95njSPBzB69bWmzUViknqgUVcn1(UeoqnBFoJiCF6dUpZu7dCexzXfWjp59ddyD5U)K8al1(8byPq4(MyR7Sr2(Che3NwJHTf1H23bl3N4NBFwAsIy73flrtT)rV)SZ5iXf7dCay87xiycn9(wP2NZcTFaejJvUp74W9RBsaeL7Z6e0Y(kwCbCYtEFGNGvUOAFoRcTVG0TlH0droRlMG7lVs1zFLPz7N3(wqGo0(DTV4Xy7t3Ues2(xPdTVdAKX2h4bU9PySe3)Q9tOXi4yCbCb0KzFflgar5XjA5CKMj4Y(QfqtM9vSyaeLhNOLZrAgO1m0RqtTaUao5jVpa6WIsWev7JKryO9ZMd3pjG7BY8G73S9nYwRnrngxanz2xXiX1LYtdrK4oUao5jV)Kqd2MOgzlGMm7RyZrAgYgSnrn6uzCiPG70D56HGvl9bhfe6eztdIKK3PvhLkYa54UY7Aq3lKgJqKZ6IjWScttJvgzGCCx5DnO7fsJlGMm7RyZrAgYgSnrn6uzCiPG70D56HGfYCISPbrsPPXkJSdu7HOfGqHqWcfycHPbDXmMnh6ZZhitpXMvGzfs3Uespe5SUyZp7cOjZ(k2CKMHSbBtuJovghsIL(aTvvxUor20GijtMnz0JfY1iJeqcDykO1kpsgRmAkflIHTzjJkvO1kpsgRmAkfl218anRJlGMm7RyZrAgYgSnrn6uzCijoJ4CqV8oT6OumVjZMm6eztdIKcWm6Aq3lKgJMmBYivQIG00rWIWPd5ngZa1zemGk100yLrdYfYF0(Ka6vgxHkHbygTGt6DjCG6OjZMmsLQiinDuzqI8j0kg9b5SSVkcgSao5jVpaIjBtZwanz2xXMJ0mguAf6ZdcXkDQPjbbRw6dokimQq6w258t6ScDiaZORbDVqAmAYSjJuPovAASYidKJ7kVRbDVqAmILjQrLJcHGfgviDl7CEsZUaAYSVInhPze13P80GWqo10KiBW2e1yKZioh0lVtRokfZBYSjJuPMg0fZy2COppVQrbijcsthf13P80GWqrfi0Y(QfqtM9vS5inJicziKOUCDQPjr2GTjQXiNrCoOxENwDukM3KztgPsnnOlMXS5qFEEvJcqseKMokIqgcjQl3OceAzF1cOjZ(k2CKMr3UesMN4aQC5WkDQPjjcsthblcNoKNLqSCtcrWGfWjVpWQKilHMEFG3069LwTFcBxxeUpXVFWLyLTP3xeKMM50(OjjSV2yzxU7d0S7Zq5vkwC)WGS1nXDuTpbdQ2xEkuTF2C4(gBFB)e2UUiC)82Nied2VZ9HOPmrngxanz2xXMJ0mwjrwcnTxAATtnnjYgSnrng5mIZb9Y70QJsX8MmBYivQPbDXmMnh6ZZRAuasan7cOjZ(k2CKMXGsRqFaOMHo10Kmz2KrpwixJS5jnbvQoablmQq6w258KMvieSAPp4OGWOcPBzNZtAsbahxanz2xXMJ0m0nef13PCQPjr2GTjQXiNrCoOxENwDukM3KztgPsnnOlMXS5qFEEvJcqseKMos3quuFNkQaHw2xTaAYSVInhPzenx)r7tyljI5uttseKMocweoDiplHy5MeIGbcnz2KrpwixJmsaTao59jUzDLwxD5U)KWgcQXk3hatBUG4(nBFB)ayFWodTaAYSVInhPzoWueIgro10Kuxgj3qqnwPpqBUGyeI0qKrWe1OWPstJvgblcNoKxu3UesHtbTw5rYyLrtPyrmSnlzlGMm7RyZrAMdmfHOrKtnnj1LrYneuJv6d0MligHinezemrnk0Kztg9yHCnYMN0ecDyQ00yLrWIWPd5f1TlHKk100yLrWIWPd5f1TlHuO8oT6OurWIWPd5f1TlHmcroRlMJlGMm7RyZrAMdmfHOrKtnnjiyH0h0fJmWaeYsO1LqhuxgPHhl90izegHinezemrnsLQ6YOO(oLpqBUGyeI0qKrWe1OJlGtEFGLm7R2pmBwY23k1(HHbyHq2(oeggGfczZWJadiwsKTpyXadcoyIQ97AFtPUk64cOjZ(k2CKMrAAT3KzFLx3S0PY4qsjSlIWKTaAYSVInhPzKMw7nz2x51nlDQmoKK8iJLvjBbCY7BYSVInhPzyiWaILeDQPjzYSjJESqUgzKas4uk0scEIQ2LqgvnZe1O3Uu5uzCiPlaleondYfYF0(Ka6vOPMgnYse2LRNLWMiCA0ilryxUEwcBIWPbweoDiVOUDjKtl4Y(QPPmir(eAfJ(GCw2xnnl4KMouadxanz2xXMJ0mstR9Mm7R86MLovghssENwDuk2cOjZ(k2CKMbcwEtM9vEDZsNkJdjzh6zycg4uttYKztg9yHCnYMN0ecDqENwDuQOcTKG3kLxHslueICwxmbacaeovAASYOcPBnsLQ8oT6Ourfs3AmcroRlMaabacttJvgviDRrhfoLcTKG3kLxHslumBjrD5UaAYSVInhPzGGL3KzFLx3S0PY4qs2HErqilDQPjzYSjJESqUgzZtAcHk0scERuEfkTqXSLe1L7cOjZ(k2CKMbcwEtM9vEDZsNkJdj5IfcBP3o0PMMKjZMm6Xc5AKnpPje6Wuk0scERuEfkTqXSLe1LRqhK3PvhLkQqlj4Ts5vO0cfHiN1fBEGaaHtLMgRmQq6wJuPkVtRokvuH0TgJqKZ6InpqaGW00yLrfs3A0rhxanz2xXMJ0mstR9Mm7R86MLovghsYfle2sNAAsMmBYOhlKRrgjGwaxaN8K3hyDaO3hGGqwUaAYSVIfTd9IGqwssHwsWlVw7uttYbrqA6iduPWYRUJlcrtMuPofzd2MOgJb3P7Y1dbRw6doki0rHoicsthvgKiFcTIrFqol7RIGbcHGfsFqxmQqtPBKLE51AHMmBYOhlKRrMaKigvQMmBYOhlKRrgPjCCb0KzFflAh6fbHSCosZGbTc5APtnnjiy1sFWrbHrfs3YofWbGaG5uOLe8evTlHmst5alfQ8PbDXKnjsmhfQqlj4jQAxczKMYbwku5td6IjtGjv4uKnyBIAmgCNUlxpeSAPp4OGqQufbPPJmkgKRlxpxZYiyWcOjZ(kw0o0lccz5CKMbdAfY1sNAAsqWQL(GJccJkKULDkWeZkuHwsWtu1UeYinLdSuOYNg0ft28ZkCkYgSnrngdUt3LRhcwT0hCuq4cOjZ(kw0o0lccz5CKMbdAfY1sNAAstPqlj4jQAxczKMYbwku5td6Ijt4uKnyBIAmgCNUlxpeSAPp4OGqQuPBxcPhICwxmbMLkvO1kpsgRmAkflIHTzjti0ALhjJvgnLIfHiN1ftGzxanz2xXI2HErqilNJ0muoWs5zbyPq4cOjZ(kw0o0lccz5CKMbdAfY1sNAAstr2GTjQXyWD6UC9qWQL(GJccxaxaN8K3hyDaO3NhtWGfqtM9vSODONHjyajRc5vLYPMMKcTKGNOQDjKrAkhyPqLpnOlMS5jjdj1OhlKRrgvQqRvEKmwz0ukwedBZsMqO1kpsgRmAkflcroRlMaKacOfqtM9vSODONHjyWCKMXQqEvPCQPjPqlj4jQAxczKMYbwku5td6IjBEsZUaAYSVIfTd9mmbdMJ0mk0scE51ANAAstr2GTjQXyWD6UC9qWQL(GJccf6GiinDuzqI8j0kg9b5SSVkcgiecwi9bDXOcnLUrw6LxRfAYSjJESqUgzcqIyuPAYSjJESqUgzKMWXfqtM9vSODONHjyWCKMbdAfY1sNAAstr2GTjQXyWD6UC9qWQL(GJccxanz2xXI2HEgMGbZrAgAKLiSlxplHnrOtYqsn6td6IjJeqo10KuOiinDKgzjc7Y1t5alvKLMKibirmHY70QJsfTGtA6qbmmcroRlMaeBb0KzFflAh6zycgmhPzOrwIWUC9Se2eHojdj1OpnOlMmsa5uttsHIG00rAKLiSlxpLdSurwAsIeaOfqtM9vSODONHjyWCKMHgzjc7Y1Zsyte6KmKuJ(0GUyYibKtnnjiyHXS5qFEEIxahK3PvhLkQqlj4Ts5vO0cfHiN1ft4uPPXkJkKU1ivQY70QJsfviDRXie5SUycttJvgviDRrhxaN8(tscyTFAqxm3NrXcy7BqCFvZmrnQCA)KqZ2NsR17RXC)qh4(SaSu7dblKndLdSuS97ILOP2)O3NI1zxU7tFW9bUc4Mb4q6wJZaCOLeeKTpWbIXfqtM9vSODONHjyWCKMHYbwkplalfcDQPjnfdZSlxwugsQrHkueKMosJSeHD56PCGLkYsts08etieSWy2COpppXeqENwDuQOvH8QsfHiN1fBbCbCYtEFaSl7Rwanz2xXIY70QJsXifCzFLtnnjYgSnrng5mIZb9Y70QJsX8MmBYivQIhJjKUDjKEiYzDXeyIjDbCYtEFG)oT6OuSfqtM9vSO8oT6OuS5inJb5c5pAFsa9k0uo10KK3PvhLkcweoDiVOUDjKriYzDXeywHY70QJsfvgKiFcTIrFqol7RIqKZ6I5XWgGYevcmRW00yLrWIWPd5f1TlHKk1PstJvgblcNoKxu3UesQufpgtiD7si9qKZ6IjaXMDb0KzFflkVtRokfBosZWoqThIwacDsgsQrFAqxmzKaYPMMuAqxmJzZH(88bY0tSzfywHPbDXmMnh6ZZRAC(zfAYSjJESqUgzcqIylGtEFIlpTITpa1TlHCF6dUpyW(5T)S7Zq5vk2(5Tpluj3NsNe2hyfCsthkGHoTFyysaHuAg60(GmCFkDsyFGZGeTF4qRy0hKZY(Q4cOjZ(kwuENwDuk2CKMbSiC6qErD7siDQPjr2GTjQXil9bARQUCf6G8oT6Ourl4KMouadJqKZ6I5XWgGYevcmlvQY70QJsfTGtA6qbmmcroRlMhdBaktunpqaGJcDqENwDuQOYGe5tOvm6dYzzFveICwxmbCLkQufbPPJkdsKpHwXOpiNL9vrWahxanz2xXIY70QJsXMJ0mGfHthYlQBxcPtnnjtMnz0JfY1iBEstqLQ4XycPBxcPhICwxmbMaOfqtM9vSO8oT6OuS5inJYGe5tOvm6dYzzFLtnnjYgSnrngzPpqBv1LRqhuxgblcNoKxu3UesV6Yie5SUyuPovAASYiyr40H8I62Lq64cOjZ(kwuENwDuk2CKMrzqI8j0kg9b5SSVYPMMKjZMm6Xc5AKnpPjOsv8ymH0TlH0droRlMata0cOjZ(kwuENwDuk2CKMXcoPPdfWqNAAsMmBYOhlKRrgjGeQqrqA6inYse2LRNYbwQilnjrZtSfqtM9vSO8oT6OuS5inJfCsthkGHojdj1OpnOlMmsa5uttYKztg9yHCnYMN0ecvOiinDKgzjc7Y1t5alvKLMKO5jMWPuOLe8wP8kuAHIzljQl3fqtM9vSO8oT6OuS5inddKJ7kVRbDVqA0PMMeeSAPp4OGWOcPBzNcaeXl0b5DA1rPIGfHthYlQBxczeICwxmbacaOsvDzeSiC6qErD7si9QlJqKZ6I54cOjZ(kwuENwDuk2CKMbSiC6qEJXmqD6uttISbBtuJrw6d0wvD5kuHIG00rAKLiSlxpLdSurwAsIeycHoeGz0coP3LWbQJMmBYivQIG00rLbjYNqRy0hKZY(QiyGWPcWmAqUqExchOoAYSjJoUaAYSVIfL3PvhLInhPzalcNoK3ymduNojdj1OpnOlMmsa5uttYKztg9yHCnYMN0ecvOiinDKgzjc7Y1t5alvKLMKibMyb0KzFflkVtRokfBosZaTMHEfAkNAAstfGz0LWbQJMmBY4c4KN8(axZmrnQCAFIdil3VUCFiAADO9RdYz69frcg5(G7NeSuq2(uoysy)aqidSl397AsGRXHXfWjp59nz2xXIY70QJsXMJ0mmtcB6w2M2hyY0PMMKjZMm6Xc5AKnpPjeoLiinDuzqI8j0kg9b5SSVkcgiCk5DA1rPIkdsKpHwXOpiNL9vriAQquPkEmMq62Lq6HiN1ftaxPAbCbCYtEFG)iJLv5(alXw3zJSfqtM9vSO8iJLvjJeJIb56Y1Z1S0PMMezd2MOgJS0hOTQ6YvieSAPp4OGWOcPBzNZd0Kk0b5DA1rPIwWjnDOaggHiN1fJk1PstJvgnixi)r7tcOxzCfQekVtRokvuzqI8j0kg9b5SSVkcroRlMJuPkEmMq62Lq6HiN1ftaGaAbCY7ZJ5(5Tpid33OteUVfCY9B2(xTpWdC7BS9ZB)aisgRC)JmcLwqqxU7dGaGTpfcTg3NHz2L7(Gb7d8aNGSfqtM9vSO8iJLvjBosZWOyqUUC9CnlDQPjjVtRokv0coPPdfWWie5SUycDWKztg9yHCnYMN0ecnz2KrpwixJmbinRqiy1sFWrbHrfs3YoNhiayohmz2KrpwixJSjXj1rQunz2KrpwixJS5NvieSAPp4OGWOcPBzNZt8aGJlGMm7Ryr5rglRs2CKMXepUUSSVYRBorNAAsKnyBIAmYsFG2QQlxHtXoqTyxQOgnLxmKhdRXfOrHoiVtRokv0coPPdfWWie5SUyuPovAASYOb5c5pAFsa9kJRqLq5DA1rPIkdsKpHwXOpiNL9vriYzDXCuieSWy2COpppXpVdeBorqA6ieSAPxEqiyq2xfHiN1fZrQufpgtiD7si9qKZ6IjWeaTaAYSVIfLhzSSkzZrAgt846YY(kVU5eDQPjr2GTjQXil9bARQUCfYoqTyxQOgnLxmKhdRXfOrHoOUmcweoDiVOUDjKE1LriYzDXMhiGOsDQ00yLrWIWPd5f1TlHuO8oT6OurLbjYNqRy0hKZY(Qie5SUyoUaAYSVIfLhzSSkzZrAgt846YY(kVU5eDQPjzYSjJESqUgzZtAcHqWcJzZH(88e)8oqS5ebPPJqWQLE5bHGbzFveICwxmhxanz2xXIYJmwwLS5indJGjjsJ(Ka6blkhmjeYPMMezd2MOgJS0hOTQ6YvOdY70QJsfTGtA6qbmmcroRlgvQtLMgRmAqUq(J2NeqVY4kujuENwDuQOYGe5tOvm6dYzzFveICwxmhPsv8ymH0TlH0droRlMaan7cOjZ(kwuEKXYQKnhPzyemjrA0Neqpyr5GjHqo10Kmz2KrpwixJS5jnHqhuOLe8wP8kuAHIzljQlxQuHwR8izSYOPuSie5SUycqciI3XfWfWjp5957YvJ7hUbDXCb0KzFfl6IfcBjjfAjbV8ATtnnjrqA6iduPWYRUJlcrtMcNISbBtuJXG70D56HGvl9bhfesLAaMrxd6EH0y0Kztgxanz2xXIUyHWwohPzuOLe8YR1o10KGGvl9bhfegviDl7uaGigvQ0TlH0droRlMaZkCkfkcsthPrwIWUC9uoWsfbdwanz2xXIUyHWwohPzSkKxvkNAAsY70QJsfTGtA6qbmmcroRlMqhstJvgviDRXiwMOgvuPkpYyzvgR2Lq6PnKkviyH0h0fJbeqdECxHmhf6WuKnyBIAmgCNUlxpeSqgvQ0TlH0droRlMaZ64cOjZ(kw0fle2Y5indLdSuEwawke6uttsHIG00rAKLiSlxpLdSurwAsIMNycNISbBtuJXG70D56HGfYwanz2xXIUyHWwohPzOCGLYZcWsHqNAAskueKMosJSeHD56PCGLkcgiuENwDuQOfCsthkGHriYzDX8yydqzIQ5Nv4uKnyBIAmgCNUlxpeSq2cOjZ(kw0fle2Y5inJcTKGxET2PMMeeSAPp4OGWOcPBzNcmbaiCkYgSnrngdUt3LRhcwT0hCuq4cOjZ(kw0fle2Y5indnYse2LRNLWMi0PMMKcfbPPJ0ilryxUEkhyPIS0KejaqcNISbBtuJXG70D56HGfYwanz2xXIUyHWwohPzOrwIWUC9Se2eHo10KuOiinDKgzjc7Y1t5alvKLMKibiEHY70QJsfTGtA6qbmmcroRlMhdBaktujWScNISbBtuJXG70D56HGfYwanz2xXIUyHWwohPzuOLe8YR1o10KMISbBtuJXG70D56HGvl9bhfeUaUao5jVpWowiSL7dSoa07dGb7d2zOfqtM9vSOlwiSLE7qsuSo90h0lVtRokLtLXHKyhO2drlaHo10KstJvgzhO2drlaHctd6IzmBo0NNpqMEInRaZkKUDjKEiYzDXMFwHY70QJsfzhO2drlaHriYzDXeWbxPAseaIHXzDuOjZMm6Xc5AKjajITaAYSVIfDXcHT0BhohPzuOLe8YR1o10KCykYgSnrngdUt3LRhcwT0hCuqivQIG00rgOsHLxDhxeIMmDuOdIG00rLbjYNqRy0hKZY(QiyGqiyH0h0fJk0u6gzPxETwOjZMm6Xc5AKjajIrLQjZMm6Xc5AKrAchxanz2xXIUyHWw6TdNJ0myqRqUw6uttseKMoYavkS8Q74Iq0KjvQtr2GTjQXyWD6UC9qWQL(GJccxanz2xXIUyHWw6TdNJ0muoWs5zbyPqOtYqsn6td6IjJeqo10KCqENwDuQOfCsthkGHriYzDXMFwHkueKMosJSeHD56PCGLkcgqLQcfbPPJ0ilryxUEkhyPIS0KenpXCuOd0TlH0droRlMaY70QJsfvOLe8wP8kuAHIqKZ6InhqaavQ0TlH0droRl28Y70QJsfTGtA6qbmmcroRlMJlGMm7RyrxSqyl92HZrAgAKLiSlxplHnrOtYqsn6td6IjJeqo10KuOiinDKgzjc7Y1t5alvKLMKibirmHY70QJsfTGtA6qbmmcroRlMaeJkvfkcsthPrwIWUC9uoWsfzPjjsaGwanz2xXIUyHWw6TdNJ0m0ilryxUEwcBIqNKHKA0Ng0ftgjGCQPjjVtRokv0coPPdfWWie5SUyZpRqfkcsthPrwIWUC9uoWsfzPjjsaGwaxaN8K3pCyxeHjBb0KzFflMWUictgjqg67e5CQmoKuxmjemnrn6bgqRsqoVcj3s0PMMKdY70QJsfblcNoKxu3UeYie5SUyuPkVtRokvuzqI8j0kg9b5SSVkcroRlMJcDiaZOb5c5DjCG6OjZMmsLAaMrl4KExchOoAYSjJcNknnwz0GCH8hTpjGELXvOIk10GUygZMd955dKPFcaqGzDKkvXJXes3Uespe5SUycmbqlGMm7RyXe2fryYMJ0mGm03jY5uzCijotAIq0ZiGy65azT0PMMK8oT6Ourl4KMouadJqKZ6IjWScDykeya7Gauf7IjHGPjQrpWaAvcY5vi5wIuPkVtRokvSlMecMMOg9adOvjiNxHKBjgHiN1fZrQufpgtiD7si9qKZ6IjWeaTaAYSVIftyxeHjBosZaYqFNiNtLXHKuq0u0ne9Krgd1o10KK3PvhLkAbN00HcyyeICwxmHomfcmGDqaQIDXKqW0e1OhyaTkb58kKClrQuL3PvhLk2ftcbttuJEGb0QeKZRqYTeJqKZ6I5ivQIhJjKUDjKEiYzDXeGylGMm7RyXe2fryYMJ0mGm03jY5uzCijLbjI7UYRqjrEYh0KDgYPMMK8oT6Ourl4KMouadJqKZ6Ij0HPqGbSdcqvSlMecMMOg9adOvjiNxHKBjsLQ8oT6OuXUysiyAIA0dmGwLGCEfsULyeICwxmhPsv8ymH0TlH0droRlMata0cOjZ(kwmHDreMS5indid9DICmNAAsoiVtRokv0coPPdfWWie5SUyuPkcsthvgKiFcTIrFqol7RIGbok0HPqGbSdcqvSlMecMMOg9adOvjiNxHKBjsLQ8oT6OuXUysiyAIA0dmGwLGCEfsULyeICwxmhh5ihda]] )

end
