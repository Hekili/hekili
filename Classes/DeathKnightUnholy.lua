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

    spec:RegisterHook( "reset_precast", function ()
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


    spec:RegisterPack( "Unholy", 20210117, [[d40u(bqiHIhPkeBcv5tQQmkKQofQkRsviXRuvQzjPyxe(LQsgMKkDmvrltvWZqvvttvbxtOQTjusFdvvQXPQqY5ufsToHsnpKk3dPSpjvDqvfQfQQOhQkutuvvYfvfsAJOQsqFuvvQgjQQe4KQQszLQs9suvjYmvvf3evvcTtHk)uOevdvOeLLQQq8uHmvjLUQQcP2kQQe1xrvL0yvvv7vj)LObd5WuwSGEmPMmkxgSzK8zjz0kvNwQvlucVwvYSj52OYUP63kgUs54OQILd1ZLy6IUocBhr9DbmEjvCEbA9cLiZhr2VkVEUQDfXSewX9qDF4zDF(KFlQ7JM)Fup8HvugCdwrBM(LvbRi34Gv0hTVpQGROnlOAm2Q2vuziWAyfTN5wj2F9vvN7eHc9W9vP5iuw2JRXgv(vP50FTIcjAv(38v4kIzjSI7H6(WZ6(8j)wu3hn)53p8OxrLnqVI7H4FyfT3mg4RWvedk6v0JCO)cSC)q8l5D1EEOpAFFubV3pYHEBoHHdEON87Ao0d19HN3779JCOpMflikjh4z5q5CO)Y)RV(lGQvWx)fy5E5q)fbCOCo04QGhspeEEO0WvqwouG95qggoeuNnqNa7q5CivtgoKA8Qdb(quTFOCoeNLjGpe92aYcKeBh6rEYNyfP6sww1UISbKfij2w1UI75Q2ve4wOcyRpxrACNaUTvedSCx(Y7Q9uqfyiCgWKPHRGSCO6PDiDqTcKGdCnuoejshcBntcKbpfgJveqD6swoeVdHTMjbYGNcJXkcmWzTxoeD0o0ZNRitN94RiZdkzoBLR4Eyv7kcClubS1NRinUta32kIbwUlF5D1EkOcmeodyY0Wvqwou90ou8RitN94RiZdkzoBLR44)Q2ve4wOcyRpxrACNaUTvumhISHBlubITzuTxjXeERLBtaaFiEhI(dfsqrjyg(LmXMxOgmNL94cITdX7qychOgCfiyGXunusPEALaClubSdX7qMoBYGeCGRHYHOJ2H4)Hir6qMoBYGeCGRHYHODOhoeFRitN94Rigy5UupTALR4(WQ2ve4wOcyRpxrACNaUTvumhISHBlubITzuTxjXeERLBtaaVImD2JVIGTMbCTELR4IFv7kcClubS1NRinUta32kIbHeuuckOKaU9kzGHWzIsA6xhIoAhI)hI3H0ZOytaxyBJ2ub3kGadCw7Ldr3H4)kY0zp(kIckjGBVswsC)cwr6GAfitdxbzzf3ZvUIlwx1UIa3cvaB95ksJ7eWTTIyqibfLGckjGBVsgyiCMOKM(1HO7qpxrMo7XxruqjbC7vYsI7xWkshuRazA4kilR4EUYvC87vTRiWTqfWwFUI04obCBRimHdIS5azoYpCi6oe9hspJInbCbdSCxAotYaTfuGboR9YH4DOyouAkWtbdOAfia3cva7qKiDi9mk2eWfmGQvGadCw7LdX7qPPapfmGQvGaClubSdX3kY0zp(kIckjGBVswsC)cwr6GAfitdxbzzf3ZvUYvKnGmKaxYvTR4EUQDfbUfQa26ZvKg3jGBBfr)HcjOOefcgdCjBgobgmDEisKoumhISHBlubITzuTxjXeERLBtaaFi(oeVdr)HcjOOemd)sMyZludMZYECbX2H4DimHdudUcemWyQgkPupTsaUfQa2H4DitNnzqcoW1q5q0r7q8)qKiDitNnzqcoW1q5q0o0dhIVvKPZE8vedSCxQNwTYvCpSQDfbUfQa26ZvKg3jGBBfHj8wl3MaawWaQw35HO7q0FON19qFFigy5U8L3v7PGkWq4mGjtdxbz5qpkhI)hIVdX7qmWYD5lVR2tbvGHWzatMgUcYYHO7qX6H4DOyoezd3wOceBZOAVsIj8wl3Maa(qKiDOqckkrjGH5AVsY1LuqSTImD2JVIGTMbCTELR44)Q2ve4wOcyRpxrACNaUTveMWBTCBcaybdOADNhIUd9q8hI3HyGL7YxExTNcQadHZaMmnCfKLdv)HI)q8oumhISHBlubITzuTxjXeERLBtaaVImD2JVIGTMbCTELR4(WQ2ve4wOcyRpxrACNaUTvumhIbwUlF5D1EkOcmeodyY0WvqwoeVdfZHiB42cvGyBgv7vsmH3A52eaWhIePdr1v7PedCw7Ldr3HI)qKiDiS1mjqg8uymwra1Plz5q8oe2AMeidEkmgRiWaN1E5q0DO4xrMo7XxrWwZaUwVYvCXVQDfz6ShFffyiCMSSbodWRiWTqfWwFUYvCX6Q2ve4wOcyRpxrACNaUTvumhISHBlubITzuTxjXeERLBtaaVImD2JVIGTMbCTELRCfvboGB9Q2vCpx1UIa3cvaB95ksJ7eWTTIcjOOefcgdCjBgobgmDEiEhkMdr2WTfQaX2mQ2RKycV1YTjaGpejshAdsrLHRMGkqy6SjdRitN94Rigy5UupTALR4Eyv7kcClubS1NRinUta32kct4TwUnbaSGbuTUZdr3HEY)vKPZE8vedSCxQNwTYvC8Fv7kcClubS1NRinUta32kspJInbCHTnAtfCRacmWzTxoeVdr)HstbEkyavRab4wOcyhIePdPhYGBEk8UApLugCisKoeMWbQbxbITDWWd34qraUfQa2H47q8oe9hkMdr2WTfQaX2mQ2RKychkhIePdr1v7PedCw7Ldr3HI)q8TImD2JVImpOK5SvUI7dRAxrGBHkGT(CfPXDc42wrmiKGIsqbLeWTxjdmeotust)6q1FOpCiEhkMdr2WTfQaX2mQ2RKychkRitN94ROadHZKLnWzaELR4IFv7kcClubS1NRinUta32kIbHeuuckOKaU9kzGHWzcITdX7q6zuSjGlSTrBQGBfqGboR9YHQ)qXFiEhkMdr2WTfQaX2mQ2RKychkhI3HO)qXCO0uGNccFFubLHQUApfGBHkGDisKouAkWtHH5ckhkzUdsMX5ataUfQa2H4Di94mIof6XjpAl7XLdLm3bjdmMaB(Rdr3HI)qKiDOyouAkWtHH5ckhkzUdsMX5ataUfQa2H4Di94mIof6XjpAl7XLdLm3bjdmMaB(RdvpTdf)Hir6qXCi94mIof6XjpAl7XLdLm3bjdmMaClubSdX3kY0zp(kkWq4mzzdCgGx5kUyDv7kcClubS1NRinUta32kIbHeuuckOKaU9kzGHWzcITdX7qPPapfe((OckdvD1Eka3cva7q8oumhISHBlubITzuTxjXeouoeVdr)HI5qPPapfgMlOCOK5oizgNdmb4wOcyhI3H0JZi6uOhN8OTShxouYChKmWycS5VoeDhk(drI0HstbEkmmxq5qjZDqYmohycWTqfWoeVdPhNr0Pqpo5rBzpUCOK5oizGXeyZFDO6PDO4peFhI3HO)q6zuSjGli89rfugQ6Q9uGboR9YHQ)qpR7H4DOyoeBsbHVpQGYqvxTNs2KcmWzTxoejshspJInbCHTnAtfCRacmWzTxou9h6zDpeFRitN94ROadHZKLnWzaELR443RAxrGBHkGT(CfPXDc42wrycV1YTjaGfmGQ1DEi6o0d19q8oumhISHBlubITzuTxjXeERLBtaaVImD2JVIyGL7s90QvUI7JAv7kcClubS1NRinUta32kIbHeuuckOKaU9kzGHWzIsA6xhIUd98q8oumhISHBlubITzuTxjXeouwrMo7XxruqjbC7vYsI7xWkxX9Ox1UIa3cvaB95ksJ7eWTTIyqibfLGckjGBVsgyiCMOKM(1HO7qF4q8oKEgfBc4cBB0Mk4wbeyGZAVCi6ou8hI3HI5qKnCBHkqSnJQ9kjMWHYH4Di6pumhknf4PGW3hvqzOQR2tb4wOcyhIePdLMc8uyyUGYHsM7GKzCoWeGBHkGDiEhspoJOtHECYJ2YEC5qjZDqYaJjWM)6q0DO4pejshkMdLMc8uyyUGYHsM7GKzCoWeGBHkGDiEhspoJOtHECYJ2YEC5qjZDqYaJjWM)6q1t7qXFisKoumhspoJOtHECYJ2YEC5qjZDqYaJja3cva7q8TImD2JVIOGsc42RKLe3VGvUI7zDx1UIa3cvaB95ksJ7eWTTIyqibfLGckjGBVsgyiCMOKM(1HO7qF4q8ouAkWtbHVpQGYqvxTNcWTqfWoeVdfZHiB42cvGyBgv7vsmHdLdX7q0FOyouAkWtHH5ckhkzUdsMX5ataUfQa2H4Di94mIof6XjpAl7XLdLm3bjdmMaB(Rdr3HI)qKiDO0uGNcdZfuouYChKmJZbMaClubSdX7q6XzeDk0JtE0w2JlhkzUdsgymb28xhQEAhk(dX3H4Di6pKEgfBc4ccFFubLHQUApfyGZAVCi6o0Z6EisKoKEgfBc4cBB0Mk4wbeyGZAVCi6o0Z6EiEhInPGW3hvqzOQR2tjBsbg4S2lhIVvKPZE8vefusa3ELSK4(fSYvCpFUQDfbUfQa26ZvKg3jGBBffZHiB42cvGyBgv7vsmH3A52eaWRitN94Rigy5UupTALRCfPhYGBEww1UI75Q2ve4wOcyRpxrACNaUTvezd3wOceLuUPm3BV6q8oeMWBTCBcaybdOADNhQ(d9mwpeVdr)H0ZOytaxyBJ2ub3kGadCw7LdrI0HI5qPPapfgMlOCOK5oizgNdmb4wOcyhI3H0ZOytaxWm8lzInVqnyol7XfyGZAVCi(oejshIQR2tjg4S2lhIUd985kY0zp(kQeWWCTxj56sUYvCpSQDfbUfQa26ZvKg3jGBBfPNrXMaUW2gTPcUvabg4S2lhI3HO)qMoBYGeCGRHYHQN2HE4q8oKPZMmibh4AOCi6ODO4peVdHj8wl3MaawWaQw35HQ)qpR7H((q0FitNnzqcoW1q5qpkhkwpeFhIePdz6SjdsWbUgkhQ(df)H4DimH3A52eaWcgq16opu9h6d19q8TImD2JVIkbmmx7vsUUKRCfh)x1UIa3cvaB95ksJ7eWTTIiB42cvGOKYnL5E7vhI3HI5qLHqf2otOaJjddkH6yCBkqaUfQa2H4Di6pKEgfBc4cBB0Mk4wbeyGZAVCisKoumhknf4PWWCbLdLm3bjZ4CGja3cva7q8oKEgfBc4cMHFjtS5fQbZzzpUadCw7LdX3H4DimHdIS5azoYpCO6pe9hI)h67dfsqrjWeERL6bJj2YECbg4S2lhIVdrI0HO6Q9uIboR9YHO7qp8Cfz6ShFfzHdx7w2Jlvnx4kxX9HvTRiWTqfWwFUI04obCBRiYgUTqfikPCtzU3E1H4DOYqOcBNjuGXKHbLqDmUnfia3cva7q8oe9hInPGW3hvqzOQR2tjBsbg4S2lhQ(d985Hir6qXCO0uGNccFFubLHQUApfGBHkGDiEhspJInbCbZWVKj28c1G5SShxGboR9YH4Bfz6ShFfzHdx7w2Jlvnx4kxXf)Q2ve4wOcyRpxrACNaUTvKPZMmibh4AOCO6PDOhoeVdHjCqKnhiZr(Hdv)HO)q8)qFFOqckkbMWBTupymXw2JlWaN1E5q8TImD2JVISWHRDl7XLQMlCLR4I1vTRiWTqfWwFUI04obCBRiYgUTqfikPCtzU3E1H4Di6pKEgfBc4cBB0Mk4wbeyGZAVCisKoumhknf4PWWCbLdLm3bjZ4CGja3cva7q8oKEgfBc4cMHFjtS5fQbZzzpUadCw7LdX3Hir6quD1EkXaN1E5q0DONXVImD2JVIk7M(LcK5oij8ado3dUYvC87vTRiWTqfWwFUI04obCBRitNnzqcoW1q5q1t7qpCiEhI(dXal3LMZKmqBbfzRF1E1Hir6qyRzsGm4PWySIadCw7LdrhTd98dhIVvKPZE8vuz30VuGm3bjHhyW5EWvUYv0gg0dxOLRAxX9Cv7kY0zp(kABYE8ve4wOcyRpx5kUhw1UIa3cvaB95kYnoyfzXsLDdBfj14PCOKBtaaVImD2JVISyPYUHTIKA8uouYTjaGx5ko(VQDfz6ShFfHTUasgySve4wOcyRpx5kxr6zuSjGxw1UI75Q2ve4wOcyRpxrACNaUTvezd3wOceCwSyWs9mk2eWlstNnz4qKiDiQUApLyGZAVCi6o0dX6kY0zp(kABYE8vUI7HvTRiWTqfWwFUI04obCBRi9mk2eWfe((OckdvD1EkWaN1E5q0Di(FiEhspJInbCbZWVKj28c1G5SShxGboR9YHO7q8)q8ouAkWtbHVpQGYqvxTNcWTqfWoejshkMdLMc8uq47JkOmu1v7PaClubSdrI0HO6Q9uIboR9YHO7q8p(vKPZE8vKH5ckhkzUdsgySvUIJ)RAxrGBHkGT(CfPXDc42wrPHRGuKnhiZrUPtj)J)q0DO4peVdLgUcsr2CGmhjRHdv)HIFfz6ShFfvgcLed2gGx5kUpSQDfbUfQa26ZvKg3jGBBfr2WTfQarjLBkZ92RoeVdr)H0ZOytaxWm8lzInVqnyol7XfyGZAVCi6ouLMDisKouibfLGz4xYeBEHAWCw2Jli2oeFhI3HO)qXCimHdudUcemWyQgkPupTsaUfQa2Hir6qXCO0uGNcdZfuouYChKmJZbMaClubSdrI0H0JZi6uOhN8OTShxouYChKmWycS5VoeDhk(dX3kY0zp(kIW3hvqzOQR2ZvUIl(vTRiWTqfWwFUI04obCBRiYgUTqfikPCtzU3E1H4DimHdudUcemWyQgkPupTsaUfQa2H4DO0uGNcdZfuouYChKmJZbMaClubSdX7q6XzeDk0JtE0w2JlhkzUdsgymb28xhQEAhk(dX7q6zuSjGlSTrBQGBfqGboR9YHOJ2HI)q8oe9hspJInbCbZWVKj28c1G5SShxGboR9YHO7qvA2Hir6qHeuucMHFjtS5fQbZzzpUGy7q8TImD2JVIi89rfugQ6Q9CLR4I1vTRiWTqfWwFUI04obCBRitNnzqcoW1q5q1t7qpCisKoevxTNsmWzTxoeDh6HNRitN94RicFFubLHQUApx5ko(9Q2ve4wOcyRpxrACNaUTvezd3wOceLuUPm3BV6q8oe9hInPGW3hvqzOQR2tjBsbg4S2lhIePdfZHstbEki89rfugQ6Q9uaUfQa2H4Bfz6ShFfXm8lzInVqnyol7Xx5kUpQvTRiWTqfWwFUI04obCBRitNnzqcoW1q5q1t7qpCisKoevxTNsmWzTxoeDh6HNRitN94RiMHFjtS5fQbZzzp(kxX9Ox1UIa3cvaB95ksJ7eWTTImD2Kbj4axdLdr7qppeVdXGqckkbfusa3ELmWq4mrjn9RdvpTd9HdX7qPPapfe((OckdvD1Eka3cva7q8ouAkWtHH5ckhkzUdsMX5ataUfQa2H4DimHdudUcemWyQgkPupTsaUfQa2H4Di94mIof6XjpAl7XLdLm3bjdmMaB(RdvpTdf)H4Di2KccFFubLHQUApLSjfyGZAVSImD2JVISTrBQGBfyLR4Ew3vTRiWTqfWwFUI04obCBRitNnzqcoW1q5q0o0ZdX7qmiKGIsqbLeWTxjdmeotust)6q1t7qF4q8ouAkWtbHVpQGYqvxTNcWTqfWoeVdXMuq47JkOmu1v7PKnPadCw7LdX7qXCO0uGNcdZfuouYChKmJZbMaClubSdX7q6XzeDk0JtE0w2JlhkzUdsgymb28xhIUdf)kY0zp(kY2gTPcUvGvUI75ZvTRiWTqfWwFUI04obCBRitNnzqcoW1q5q0o0ZdX7qmiKGIsqbLeWTxjdmeotust)6q1t7qF4q8oe9hkMdLMc8uq47JkOmu1v7PaClubSdrI0HstbEkmmxq5qjZDqYmohycWTqfWoeVdr)HI5qychOgCfiyGXunusPEALaClubSdrI0H0JZi6uOhN8OTShxouYChKmWycS5VoeDhk(dX3Hir6qXCO0uGNcdZfuouYChKmJZbMaClubSdX7q6XzeDk0JtE0w2JlhkzUdsgymb28xhQEAhk(drI0HO6Q9uIboR9YHO7qpJ1dX3kY0zp(kY2gTPcUvGvUI75dRAxrGBHkGT(CfPXDc42wrMoBYGeCGRHYHQN2HE4q8oedcjOOeuqjbC7vYadHZeL00Vou90o0hoeVdfZHyGL7sZzsgOTGIS1VAVAfz6ShFfzBJ2ub3kWkshuRazA4kilR4EUYvCp5)Q2ve4wOcyRpxrACNaUTveMWBTCBcaybdOADNhIUd98dhI3HO)q6zuSjGli89rfugQ6Q9uGboR9YHO7qpR7Hir6qSjfe((OckdvD1EkztkWaN1E5q8TImD2JVIkeCCJlRmC1eubRCf3ZpSQDfbUfQa26ZvKg3jGBBfr2WTfQarjLBkZ92RoeVdXGqckkbfusa3ELmWq4mrjn9Rdr3HE4q8oe9hAdsHTnAz1(qOeMoBYWHir6q6XzeDk0JtE0w2JlhkzUdsgymb4wOcyhI3HcjOOemd)sMyZludMZYECbX2H4DOyo0gKcdZfuwTpekHPZMmCi(wrMo7Xxre((OckTsXiu5kxX9m(vTRiWTqfWwFUI04obCBRitNnzqcoW1q5q1t7qpCiEhIbHeuuckOKaU9kzGHWzIsA6xhIUd9WkY0zp(kIW3hvqPvkgHkxr6GAfitdxbzzf3ZvUI7zSUQDfbUfQa26ZvKg3jGBBffZH2GuuTpekHPZMmSImD2JVIWwxajdm2kxX9KFVQDfbUfQa26ZvKg3jGBBfz6SjdsWbUgkhQEAh6HdX7qXCOqckkbZWVKj28c1G5SShxqSDiEhkMdPNrXMaUGz4xYeBEHAWCw2JlWGXcEisKoevxTNsmWzTxoeDhQsZwrMo7XxrftJBQw3MsUz6CLRCfvboGBT0gyv7kUNRAxrGBHkGT(Cf5ghSIkdHsIbBdWRitN94ROawNsQbl1ZOytaFfPXDc42wrPPapfLHqjXGTbyb4wOcyhI3HsdxbPiBoqMJCtNs(h)HO7qXFiEhIQR2tjg4S2lhQ(df)H4Di9mk2eWfLHqjXGTbybg4S2lhIUdr)HQ0Sd9OCO6k43XFi(oeVdz6SjdsWbUgkhIoAhI)RCf3dRAxrGBHkGT(CfPXDc42wr0FOyoezd3wOceBZOAVsIj8wl3Maa(qKiDOqckkrHGXaxYMHtGbtNhIVdX7q0FOqckkbZWVKj28c1G5SShxqSDiEhct4a1GRabdmMQHsk1tReGBHkGDiEhY0ztgKGdCnuoeD0oe)pejshY0ztgKGdCnuoeTd9WH4Bfz6ShFfXal3L6PvRCfh)x1UIa3cvaB95ksJ7eWTTIcjOOefcgdCjBgobgmDEisKoumhISHBlubITzuTxjXeERLBtaaVImD2JVIGTMbCTELR4(WQ2ve4wOcyRpxrACNaUTve9hspJInbCHTnAtfCRacmWzTxou9hk(dX7qmiKGIsqbLeWTxjdmeotqSDisKoedcjOOeuqjbC7vYadHZeL00Vou9h6dhIVdX7q0FiQUApLyGZAVCi6oKEgfBc4cgy5U0CMKbAlOadCw7Ld99HEw3drI0HO6Q9uIboR9YHQ)q6zuSjGlSTrBQGBfqGboR9YH4Bfz6ShFffyiCMSSbodWRiDqTcKPHRGSSI75kxXf)Q2ve4wOcyRpxrACNaUTvedcjOOeuqjbC7vYadHZeL00VoeD0oe)peVdPNrXMaUW2gTPcUvabg4S2lhIUdX)drI0HyqibfLGckjGBVsgyiCMOKM(1HO7qpxrMo7XxruqjbC7vYsI7xWkshuRazA4kilR4EUYvCX6Q2ve4wOcyRpxrACNaUTvKEgfBc4cBB0Mk4wbeyGZAVCO6pu8hI3HyqibfLGckjGBVsgyiCMOKM(1HO7qpxrMo7XxruqjbC7vYsI7xWkshuRazA4kilR4EUYvUIsC7VGSSQDf3ZvTRiWTqfWwFUICJdwrTx0yI0cvGKFimpj4KmGCRHvKPZE8vu7fnMiTqfi5hcZtcojdi3AyfPXDc42wr0Fi9mk2eWfe((OckdvD1EkWaN1E5qKiDi9mk2eWfmd)sMyZludMZYECbg4S2lhIVdX7q0FOnifgMlOSAFiuctNnz4qKiDOnif22OLv7dHsy6SjdhI3HI5qPPapfgMlOCOK5oizgNdmb4wOcyhIePdLgUcsr2CGmh5MoLpu3dr3HI)q8DisKoevxTNsmWzTxoeDh6HNRCf3dRAxrGBHkGT(Cf5ghSI4mTfIbzzhGuYruA9kY0zp(kIZ0wigKLDasjhrP1RinUta32kspJInbCHTnAtfCRacmWzTxoeDhk(dX7q0FOyoeWpe92gWeTx0yI0cvGKFimpj4KmGCRHdrI0H0ZOytax0ErJjslubs(HW8KGtYaYTgeyGZAVCi(oejshIQR2tjg4S2lhIUd9WZvUIJ)RAxrGBHkGT(Cf5ghSIyyWyungKKHsbuRitN94RiggmgvJbjzOua1ksJ7eWTTI0ZOytaxyBJ2ub3kGadCw7LdX7q0FOyoeWpe92gWeTx0yI0cvGKFimpj4KmGCRHdrI0H0ZOytax0ErJjslubs(HW8KGtYaYTgeyGZAVCi(oejshIQR2tjg4S2lhIUdX)vUI7dRAxrGBHkGT(Cf5ghSIyg(f3mUKb6xsYd20DgCfz6ShFfXm8lUzCjd0VKKhSP7m4ksJ7eWTTI0ZOytaxyBJ2ub3kGadCw7LdX7q0FOyoeWpe92gWeTx0yI0cvGKFimpj4KmGCRHdrI0H0ZOytax0ErJjslubs(HW8KGtYaYTgeyGZAVCi(oejshIQR2tjg4S2lhIUd9WZvUIl(vTRiWTqfWwFUI04obCBRi6pKEgfBc4cBB0Mk4wbeyGZAVCisKouibfLGz4xYeBEHAWCw2Jli2oeFhI3HO)qXCiGFi6TnGjAVOXePfQaj)qyEsWjza5wdhIePdPNrXMaUO9IgtKwOcK8dH5jbNKbKBniWaN1E5q8TImD2JVIikGStGRSYvUIyaLrOYvTR4EUQDfz6ShFfX1otsHbiwcwrGBHkGT(CLR4Eyv7kcClubS1NROzBfvGCfz6ShFfr2WTfQGveztraRi9mk2eWffcoUXLvgUAcQabg4S2lhIUdf)H4DO0uGNIcbh34YkdxnbvGaClubSvezdlDJdwrBZOAVsIj8wl3MaaELR44)Q2ve4wOcyRpxrZ2kQa5kY0zp(kISHBlubRiYMIawrPPapfLHqjXGTbyb4wOcyhI3HWeoCi6o0dhI3HsdxbPiBoqMJCtNs(h)HO7qXFiEhIQR2tjg4S2lhQ(df)kISHLUXbROTzuTxjXeouw5kUpSQDfbUfQa26Zv0STIkqUImD2JVIiB42cvWkISPiGvKPZMmibh4AOCiAh65H4Di6pumhcBntcKbpfgJveqD6swoejshcBntcKbpfgJveTFO6p0Z4peFRiYgw6ghSIkPCtzU3E1kxXf)Q2ve4wOcyRpxrZ2kQa5kY0zp(kISHBlubRiYMIawrBqkQmC1eubctNnz4qKiDOqckkbHVpQGsRumcvki2oejshknf4PWWCbLdLm3bjZ4CGja3cva7q8o0gKcBB0YQ9HqjmD2KHdrI0HcjOOemd)sMyZludMZYECbX2kISHLUXbRiolwmyPEgfBc4fPPZMmSYvCX6Q2ve4wOcyRpxrACNaUTveMWBTCBcaybdOADNhQ(dfRXFiEhI(dTbPOYWvtqfimD2KHdrI0HI5qPPapffcoUXLvgUAcQab4wOcyhIVdX7qychemGQ1DEO6PDO4xrMo7XxrgwBoiZbJbpx5ko(9Q2ve4wOcyRpxrACNaUTvezd3wOceCwSyWs9mk2eWlstNnz4qKiDO0WvqkYMdK5iznCi6ODOqckkrOAgMKIahuWiWw2JVImD2JVIcvZWKue4GRCf3h1Q2ve4wOcyRpxrACNaUTvezd3wOceCwSyWs9mk2eWlstNnz4qKiDO0WvqkYMdK5iznCi6ODOqckkriGla(v7vcgb2YE8vKPZE8vuiGla(v7vRCf3JEv7kcClubS1NRinUta32kkKGIsq47JkOSKyWRYDbX2kY0zp(ks1v7zrgliyvCGNRCf3Z6UQDfbUfQa26ZvKg3jGBBfr2WTfQabNflgSupJInb8I00ztgoejshknCfKIS5azoswdhIoAh6z8RitN94RiZ1qjXMsQnLALR4E(Cv7kcClubS1NRinUta32kY0ztgKGdCnuou90o0dhIePdr)HWeoiyavR78q1t7qXFiEhct4TwUnbaSGbuTUZdvpTdfR19q8TImD2JVImS2CqUrOkWkxX98HvTRiWTqfWwFUI04obCBRiYgUTqfi4SyXGL6zuSjGxKMoBYWHir6qPHRGuKnhiZrYA4q0r7qHeuucQgdHQzycgb2YE8vKPZE8vevJHq1mSvUI7j)x1UIa3cvaB95ksJ7eWTTIcjOOee((Ockljg8QCxqSDiEhY0ztgKGdCnuoeTd9Cfz6ShFffAvYHsM4w)QSYvCp)WQ2ve4wOcyRpxrACNaUTveBsb5gtOapLBkRIaeyGcdLDlubhI3HI5qPPapfe((OckdvD1Eka3cva7q8oumhcBntcKbpfgJveqD6swwrMo7XxrdrgIb71kxX9m(vTRiWTqfWwFUI04obCBRi2KcYnMqbEk3uwfbiWafgk7wOcoeVdz6SjdsWbUgkhQEAh6HdX7q0FOyouAkWtbHVpQGYqvxTNcWTqfWoejshknf4PGW3hvqzOQR2tb4wOcyhI3H0ZOytaxq47JkOmu1v7PadCw7LdX3kY0zp(kAiYqmyVw5kUNX6Q2ve4wOcyRpxrACNaUTveMWbQbxbIcXgGlj2AxaUfQa2H4Di6peBsbfEkPKcidybgOWqz3cvWHir6qSjfHQzyYnLvracmqHHYUfQGdX3kY0zp(kAiYqmyVw5kUN87vTRiWTqfWwFUImD2JVI0MsjnD2JlvDjxrQUKs34GvuIB)fKLvUI75h1Q2ve4wOcyRpxrMo7XxrAtPKMo7XLQUKRivxsPBCWkspKb38SSYvCpF0RAxrGBHkGT(Cfz6ShFfPnLsA6ShxQ6sUIuDjLUXbRi9mk2eWlRCf3d1Dv7kcClubS1NRitN94RimHlnD2JlvDjxrACNaUTvKPZMmibh4AOCO6PDOhoeVdr)H0ZOytaxWal3LMZKmqBbfyGZAVCi6o0Z6EiEhkMdLMc8uWaQwbcWTqfWoejshspJInbCbdOAfiWaN1E5q0DON19q8ouAkWtbdOAfia3cva7q8DiEhkMdXal3LMZKmqBbfzRF1E1ks1Lu6ghSISbKfij2w5kUhEUQDfbUfQa26ZvKPZE8veMWLMo7XLQUKRinUta32kY0ztgKGdCnuou90o0dhI3HyGL7sZzsgOTGIS1VAVAfP6skDJdwr2aYqcCjx5kUhEyv7kcClubS1NRitN94RimHlnD2JlvDjxrACNaUTvKPZMmibh4AOCO6PDOhoeVdr)HI5qmWYDP5mjd0wqr26xTxDiEhI(dPNrXMaUGbwUlnNjzG2ckWaN1E5q1FON19q8oumhknf4PGbuTceGBHkGDisKoKEgfBc4cgq1kqGboR9YHQ)qpR7H4DO0uGNcgq1kqaUfQa2H47q8TIuDjLUXbROkWbCRL2aRCf3d8Fv7kcClubS1NRitN94RiTPustN94svxYvKg3jGBBfz6SjdsWbUgkhI2HEUIuDjLUXbROkWbCRx5kx5kImGl94R4EOUpu3Np8WdROag2BVQSI4x)4psC)T4(7X(qhQ2D4qn32GZdrn4d9ZgqwGKy73HWa)q0yGDOYWbhYiYHZsGDi9U5vqrCV)t7WH4FSp0JhNmGtGDOFychOgCfi()3HY5q)Weoqn4kq8VaClubSFhI(N1HpX9(pTdhIFh7d94Xjd4eyh6xAkWtX))ouoh6xAkWtX)cWTqfW(Di6FOo8jU33B(1p(Je3FlU)ESp0HQDhouZTn48qud(q)SbKHe4s(7qyGFiAmWouz4Gdze5WzjWoKE38kOiU3)PD4qpJ9HE84KbCcSd9dt4a1GRaX))ouoh6hMWbQbxbI)fGBHkG97q0)So8jU33B(1p(Je3FlU)ESp0HQDhouZTn48qud(q)QahWT(3HWa)q0yGDOYWbhYiYHZsGDi9U5vqrCV)t7WH4FSp0JhNmGtGDOFychOgCfi()3HY5q)Weoqn4kq8VaClubSFhI(N1HpX9(pTdhk(yFOhpozaNa7q)stbEk()3HY5q)stbEk(xaUfQa2Vdrp)RdFI79FAhou8X(qpECYaob2H(PhNr0P4)FhkNd9tpoJOtX)cWTqfW(Di6Fwh(e37)0oCOyn2h6XJtgWjWo0V0uGNI))DOCo0V0uGNI)fGBHkG97q0Z)6WN4E)N2Hd9OJ9HE84KbCcSd9lnf4P4)FhkNd9lnf4P4Fb4wOcy)oe98Vo8jU3)PD4qp6yFOhpozaNa7q)0JZi6u8)VdLZH(PhNr0P4Fb4wOcy)oe9pRdFI79FAho0Z6g7d94Xjd4eyh6xAkWtX))ouoh6xAkWtX)cWTqfW(Di65FD4tCVV38RF8hjU)wC)9yFOdv7oCOMBBW5HOg8H(PhYGBEw(DimWpengyhQmCWHmIC4SeyhsVBEfue37)0oCONX(qpECYaob2H(LMc8u8)VdLZH(LMc8u8VaClubSFhI(N1HpX9(pTdhI)X(qpECYaob2H(LMc8u8)VdLZH(LMc8u8VaClubSFhI(N1HpX9(pTdhI)X(qpECYaob2H(vgcvy7mX))ouoh6xziuHTZe)la3cva73HO)zD4tCV)t7WH(qSp0JhNmGtGDOFPPapf))7q5COFPPapf)la3cva73HO)zD4tCV)t7WH(qSp0JhNmGtGDOFLHqf2ot8)VdLZH(vgcvy7mX)cWTqfW(Di6Fwh(e37)0oCOyn2h6XJtgWjWo0V0uGNI))DOCo0V0uGNI)fGBHkG97q0)So8jU33B(1p(Je3FlU)ESp0HQDhouZTn48qud(q)0ZOytaV87qyGFiAmWouz4Gdze5WzjWoKE38kOiU3)PD4qpe7d94Xjd4eyh6xAkWtX))ouoh6xAkWtX)cWTqfW(Di6FOo8jU3)PD4qFi2h6XJtgWjWo0V0uGNI))DOCo0V0uGNI)fGBHkG97q0)So8jU3)PD4qFi2h6XJtgWjWo0pmHdudUce))7q5COFychOgCfi(xaUfQa2Vdr)Z6WN4E)N2HdfFSp0JhNmGtGDOFPPapf))7q5COFPPapf)la3cva73HO)zD4tCV)t7WHIp2h6XJtgWjWo0pmHdudUce))7q5COFychOgCfi(xaUfQa2Vdr)Z6WN4E)N2HdXVJ9HE84KbCcSd9lnf4P4)FhkNd9lnf4P4Fb4wOcy)oe9pRdFI79FAho0Jo2h6XJtgWjWo0V0uGNI))DOCo0V0uGNI)fGBHkG97q0)qD4tCV)t7WHE0X(qpECYaob2H(HjCGAWvG4)FhkNd9dt4a1GRaX)cWTqfW(Di6Fwh(e37)0oCON1n2h6XJtgWjWo0V0uGNI))DOCo0V0uGNI)fGBHkG97q0)qD4tCV)t7WHE(m2h6XJtgWjWo0V0uGNI))DOCo0V0uGNI)fGBHkG97q0Z)6WN4E)N2Hd98zSp0JhNmGtGDOFychOgCfi()3HY5q)Weoqn4kq8VaClubSFhI(N1HpX9(pTdh65hI9HE84KbCcSd9tpoJOtX))ouoh6NECgrNI)fGBHkG97q0)So8jU33B(1p(Je3FlU)ESp0HQDhouZTn48qud(q)QahWTwAd87qyGFiAmWouz4Gdze5WzjWoKE38kOiU3)PD4qpJ9H(O9cX22GtGDitN94h6xaRtj1GL6zuSjG)tCV)t7WHEg7d94Xjd4eyh6xAkWtX))ouoh6xAkWtX)cWTqfW(Di6Fwh(e37)0oCOhI9HE84KbCcSd9dt4a1GRaX))ouoh6hMWbQbxbI)fGBHkG97q0)So8jU33B(1p(Je3FlU)ESp0HQDhouZTn48qud(q)sC7VGS87qyGFiAmWouz4Gdze5WzjWoKE38kOiU3)PD4qpJ9HE84KbCcSd9lnf4P4)FhkNd9lnf4P4Fb4wOcy)oe9pRdFI799MF9J)iX93I7Vh7dDOA3Hd1CBdope1Gp0pgqzeQ83HWa)q0yGDOYWbhYiYHZsGDi9U5vqrCV)t7WHEi2h6XJtgWjWo0V0uGNI))DOCo0V0uGNI)fGBHkG97qwEOh1y5)5q0)So8jU3)PD4q8p2h6XJtgWjWo0V0uGNI))DOCo0V0uGNI)fGBHkG97q0)So8jU3)PD4qXh7d94Xjd4eyh6xAkWtX))ouoh6xAkWtX)cWTqfW(Di6Fwh(e37)0oCONFi2h6XJtgWjWo0V0uGNI))DOCo0V0uGNI)fGBHkG97q0)So8jU3)PD4qpJp2h6XJtgWjWo0V0uGNI))DOCo0V0uGNI)fGBHkG97q0)qD4tCV)t7WHEgRX(qpECYaob2H(HjCGAWvG4)FhkNd9dt4a1GRaX)cWTqfW(Di6Fwh(e37)0oCOhQBSp0JhNmGtGDOFPPapf))7q5COFPPapf)la3cva73HO)H6WN4E)N2Hd9WdX(qpECYaob2H(LMc8u8)VdLZH(LMc8u8VaClubSFhI(hQdFI799(VXTn4eyh6rFitN94hs1LSiU3ROn8q1kyf9ih6Val3pe)sExTNh6J23hvW79JCO3Mty4Gh6j)UMd9qDF459(E)ih6JzXcIsYbEwouoh6V8)6R)cOAf81FbwUxo0FrahkNdnUk4H0dHNhknCfKLdfyFoKHHdb1zd0jWouohs1KHdPgV6qGpev7hkNdXzzc4drVnGSajX2HEKN8jU33BtN94fXgg0dxOLFt7RTj7XV3Mo7XlInmOhUql)M2xefq2jWvJBCanlwQSByRiPgpLdLCBca47TPZE8Iydd6Hl0YVP9f26cizGXU337h5qpQ1b0ejWoeqgWbpu2CWHYD4qMoh8H6YHmYwRSqfiU3Mo7Xl04ANjPWaelb37h5q8lB42cvq5EB6ShV8nTViB42cvqnUXb02Mr1ELet4TwUnbaCnKnfbqtpJInbCrHGJBCzLHRMGkqGboR9cDXZlnf4POqWXnUSYWvtqfCVnD2Jx(M2xKnCBHkOg34aABZOAVsIjCOudztra0stbEkkdHsIbBdW8Weoq3d8sdxbPiBoqMJCtNs(hpDXZJQR2tjg4S2l1h)920zpE5BAFr2WTfQGACJdOvs5MYCV9QAiBkcGMPZMmibh4AOq7jp6JbBntcKbpfgJveqD6swircBntcKbpfgJveTx)Z457EB6ShV8nTViB42cvqnUXb04SyXGL6zuSjGxKMoBYqnKnfbqBdsrLHRMGkqy6SjdKifsqrji89rfuALIrOsbXgjsPPapfgMlOCOK5oizgNdmEBqkSTrlR2hcLW0ztgirkKGIsWm8lzInVqnyol7XfeB37h5qFet3MQCVnD2Jx(M2xgwBoiZbJbpRPPOHj8wl3MaawWaQw3z9XA88OFdsrLHRMGkqy6SjdKiftAkWtrHGJBCzLHRMGkqaUfQagF8WeoiyavR7SEAXFVnD2Jx(M2xHQzyskcCWAAkAKnCBHkqWzXIbl1ZOytaVinD2KbsKsdxbPiBoqMJK1aD0cjOOeHQzyskcCqbJaBzp(920zpE5BAFfc4cGF1EvnnfnYgUTqfi4SyXGL6zuSjGxKMoBYajsPHRGuKnhiZrYAGoAHeuuIqaxa8R2RemcSL943BtN94LVP9LQR2ZImwqWQ4apRPPOfsqrji89rfuwsm4v5UGy7E)ih6JDnusSPo0JnL6qAZpuI7QkaFOpCOTjbpBtDOqckQsnhcm9(HuwjBV6qpJ)qfqpoRio0hD2QowcyhA3WSdPhgWou2CWHSYHSdL4UQcWhkNd9cGTd15HWGXSqfiU3Mo7XlFt7lZ1qjXMsQnLQMMIgzd3wOceCwSyWs9mk2eWlstNnzGeP0WvqkYMdK5iznqhTNXFVnD2Jx(M2xgwBoi3iufOMMIMPZMmibh4AOupThirIEmHdcgq16oRNw88WeERLBtaalyavR7SEAXAD57EB6ShV8nTVOAmeQMHvttrJSHBlubcolwmyPEgfBc4fPPZMmqIuA4kifzZbYCKSgOJwibfLGQXqOAgMGrGTSh)EB6ShV8nTVcTk5qjtCRFvQPPOfsqrji89rfuwsm4v5UGyJNPZMmibh4AOq759(roe)Iw7P1E7vhIF5gtOappuSmLvrahQlhYo0gUhCNbV3Mo7XlFt7RHidXG9QMMIgBsb5gtOapLBkRIaeyGcdLDlub8Ijnf4PGW3hvqzOQR2tEXGTMjbYGNcJXkcOoDjl3BtN94LVP91qKHyWEvttrJnPGCJjuGNYnLvracmqHHYUfQaEMoBYGeCGRHs90EGh9XKMc8uq47JkOmu1v7jjsPPapfe((OckdvD1EYtpJInbCbHVpQGYqvxTNcmWzTx47EB6ShV8nTVgImed2RAAkAychOgCfikeBaUKyRDE0ZMuqHNskPaYawGbkmu2TqfqIeBsrOAgMCtzveGaduyOSBHkGV79JCOpwN94h6pDjlhYC2HILVboGlhI(y5BGd4Yxra)qaUgkhIWleBBdob2HA)qgJnUGV7TPZE8Y30(sBkL00zpUu1LSg34aAjU9xqwU3Mo7XlFt7lTPustN94svxYACJdOPhYGBEwU3pYHmD2Jx(M2xfGFiaxd10u0mD2Kbj4axdfAp5fddSCx(Y7Q9uW6IfQaPnjRg34aAZg4ao2gMlOCOK5oizGXInfusa3ELSK4(feBkOKaU9kzjX9li2e((OckdvD1Eg7Tj7XJnZWVKj28c1G5SShp222OnvWTcCVnD2Jx(M2xAtPKMo7XLQUK14ghqtpJInb8Y920zpE5BAFHjCPPZECPQlznUXb0SbKfij2QPPOz6SjdsWbUgk1t7bE0RNrXMaUGbwUlnNjzG2ckWaN1EHUN1LxmPPapfmGQvajs6zuSjGlyavRabg4S2l09SU8stbEkyavRa(4fddSCxAotYaTfuKT(v7v3BtN94LVP9fMWLMo7XLQUK14ghqZgqgsGlznnfntNnzqcoW1qPEApWJbwUlnNjzG2ckYw)Q9Q7TPZE8Y30(ct4stN94svxYACJdOvboGBT0gOMMIMPZMmibh4AOupTh4rFmmWYDP5mjd0wqr26xTxXJE9mk2eWfmWYDP5mjd0wqbg4S2l1)SU8Ijnf4PGbuTcirspJInbCbdOAfiWaN1EP(N1LxAkWtbdOAfWhF3BtN94LVP9L2ukPPZECPQlznUXb0QahWTUMMIMPZMmibh4AOq759(E)ih6JNh1d9jbUK3BtN94fHnGmKaxsAmWYDPEAvnnfn6djOOefcgdCjBgobgmDsIumKnCBHkqSnJQ9kjMWBTCBcay(4rFibfLGz4xYeBEHAWCw2Jli24HjCGAWvGGbgt1qjL6Pv8mD2Kbj4axdf6OXFsKmD2Kbj4axdfApW3920zpErydidjWL8BAFbBnd4ADnnfnmH3A52eaWcgq16oPJ(N19Bgy5U8L3v7PGkWq4mGjtdxbz5rH)8XJbwUlF5D1EkOcmeodyY0WvqwOlw5fdzd3wOceBZOAVsIj8wl3MaaMePqckkrjGH5AVsY1LuqSDVnD2Jxe2aYqcCj)M2xWwZaUwxttrdt4TwUnbaSGbuTUt6EiEEmWYD5lVR2tbvGHWzatMgUcYs9XZlgYgUTqfi2Mr1ELet4TwUnba8920zpErydidjWL8BAFbBnd4ADnnfTyyGL7YxExTNcQadHZaMmnCfKfEXq2WTfQaX2mQ2RKycV1YTjaGjrIQR2tjg4S2l0fpjsyRzsGm4PWySIaQtxYcpS1mjqg8uymwrGboR9cDXFVnD2Jxe2aYqcCj)M2xbgcNjlBGZa8920zpErydidjWL8BAFbBnd4ADnnfTyiB42cvGyBgv7vsmH3A52eaW3779JCOpEEupueKeB3BtN94fHnGSajXgnZdkzoRMMIgdSCx(Y7Q9uqfyiCgWKPHRGSupnDqTcKGdCnuircBntcKbpfgJveqD6sw4HTMjbYGNcJXkcmWzTxOJ2ZN3BtN94fHnGSajX230(Y8GsMZQPPOXal3LV8UApfubgcNbmzA4kil1tl(7TPZE8IWgqwGKy7BAFXal3L6Pv10u0IHSHBlubITzuTxjXeERLBtaaZJ(qckkbZWVKj28c1G5SShxqSXdt4a1GRabdmMQHsk1tR4z6SjdsWbUgk0rJ)Kiz6SjdsWbUgk0EGV7TPZE8IWgqwGKy7BAFbBnd4ADnnfTyiB42cvGyBgv7vsmH3A52eaW3BtN94fHnGSajX230(IckjGBVswsC)cQrhuRazA4kil0EwttrJbHeuuckOKaU9kzGHWzIsA6x0rJ)80ZOytaxyBJ2ub3kGadCw7f64)920zpErydilqsS9nTVOGsc42RKLe3VGA0b1kqMgUcYcTN10u0yqibfLGckjGBVsgyiCMOKM(fDpV3Mo7XlcBazbsITVP9ffusa3ELSK4(fuJoOwbY0WvqwO9SMMIgMWbr2CGmh5hOJE9mk2eWfmWYDP5mjd0wqbg4S2l8Ijnf4PGbuTcirspJInbCbdOAfiWaN1EHxAkWtbdOAfW39(E)ihkw2K943BtN94fHEgfBc4fABt2JxttrJSHBlubcolwmyPEgfBc4fPPZMmqIevxTNsmWzTxO7Hy9E)ih6XZOytaVCVnD2Jxe6zuSjGx(M2xgMlOCOK5oizGXQPPOPNrXMaUGW3hvqzOQR2tbg4S2l0XFE6zuSjGlyg(LmXMxOgmNL94cmWzTxOJ)8stbEki89rfugQ6Q9KePystbEki89rfugQ6Q9KejQUApLyGZAVqh)J)EB6ShVi0ZOytaV8nTVkdHsIbBdW1KgUcsztrlnCfKIS5azoYnDk5F80fpV0WvqkYMdK5iznuF837h5qrbD9H(u1v75Hc05(H(ld)6q1InVqnyol7XputDiISvDSu7vhAYDaFO)YWVouTyZludMZYE8dfsqrvQ5q5(uGdfcTxDO)cmMQHsEOhpTQMdXVqm4XsnWoe)IJxs8u6m4Hg8HEuta7M6q8lGWRaS4qFSQmhsVd6xLd1uhspoRZE8YHmmCioipuohQ9scg7q7JIDiQbFOpEB0Mk4wbe3BtN94fHEgfBc4LVP9fHVpQGYqvxTN10u0iB42cvGOKYnL5E7v8OxpJInbCbZWVKj28c1G5SShxGboR9cDvAgjsHeuucMHFjtS5fQbZzzpUGyJpE0hdMWbQbxbcgymvdLuQNwrIumPPapfgMlOCOK5oizgNdmsK0JZi6uOhN8OTShxouYChKmWycS5VOlE(U3pYHIc66d9PQR2ZdfOZ9d9XBJ2ub3kWHAQdL7WH0ZOyta)qd1H(4TrBQGBf4qD5qQjWHaFiQ2fh6Ja8drJHYH(lWyQgk5HE80QAo0JhN8OTSh)qd1HYD4q)fySdzo7qFmMl4HgQdL7WH(lJZb2HYPcYDalU3Mo7Xlc9mk2eWlFt7lcFFubLHQUApRPPOr2WTfQarjLBkZ92R4HjCGAWvGGbgt1qjL6Pv8stbEkmmxq5qjZDqYmohy80JZi6uOhN8OTShxouYChKmWycS5VQNw880ZOytaxyBJ2ub3kGadCw7f6Ofpp61ZOytaxWm8lzInVqnyol7XfyGZAVqxLMrIuibfLGz4xYeBEHAWCw2Jli247EB6ShVi0ZOytaV8nTVi89rfugQ6Q9SMMIMPZMmibh4AOupThirIQR2tjg4S2l09WZ7TPZE8IqpJInb8Y30(Iz4xYeBEHAWCw2JxttrJSHBlubIsk3uM7TxXJE2KccFFubLHQUApLSjfyGZAVqIumPPapfe((OckdvD1EY3920zpErONrXMaE5BAFXm8lzInVqnyol7XRPPOz6SjdsWbUgk1t7bsKO6Q9uIboR9cDp88EB6ShVi0ZOytaV8nTVSTrBQGBfOMMIMPZMmibh4AOq7jpgesqrjOGsc42RKbgcNjkPPFvpTpWlnf4PGW3hvqzOQR2tEPPapfgMlOCOK5oizgNdmEychOgCfiyGXunusPEAfp94mIof6XjpAl7XLdLm3bjdmMaB(R6Pfpp2KccFFubLHQUApLSjfyGZAVCVnD2Jxe6zuSjGx(M2x22OnvWTcuttrZ0ztgKGdCnuO9KhdcjOOeuqjbC7vYadHZeL00VQN2h4LMc8uq47JkOmu1v7jp2KccFFubLHQUApLSjfyGZAVWlM0uGNcdZfuouYChKmJZbgp94mIof6XjpAl7XLdLm3bjdmMaB(l6I)EB6ShVi0ZOytaV8nTVSTrBQGBfOMMIMPZMmibh4AOq7jpgesqrjOGsc42RKbgcNjkPPFvpTpWJ(ystbEki89rfugQ6Q9KeP0uGNcdZfuouYChKmJZbgp6Jbt4a1GRabdmMQHsk1tRirspoJOtHECYJ2YEC5qjZDqYaJjWM)IU45JePystbEkmmxq5qjZDqYmohy80JZi6uOhN8OTShxouYChKmWycS5VQNw8Kir1v7PedCw7f6EgR8DVnD2Jxe6zuSjGx(M2x22OnvWTcuJoOwbY0WvqwO9SMMIMPZMmibh4AOupTh4XGqckkbfusa3ELmWq4mrjn9R6P9bEXWal3LMZKmqBbfzRF1E1920zpErONrXMaE5BAFvi44gxwz4QjOcQPPOHj8wl3MaawWaQw3jDp)ap61ZOytaxq47JkOmu1v7PadCw7f6EwxsKytki89rfugQ6Q9uYMuGboR9cF3BtN94fHEgfBc4LVP9fHVpQGsRumcvwttrJSHBlubIsk3uM7TxXJbHeuuckOKaU9kzGHWzIsA6x09ap63GuyBJwwTpekHPZMmqIKECgrNc94KhTL94YHsM7GKbgJxibfLGz4xYeBEHAWCw2Jli24fZgKcdZfuwTpekHPZMmW3920zpErONrXMaE5BAFr47JkO0kfJqL1OdQvGmnCfKfApRPPOz6SjdsWbUgk1t7bEmiKGIsqbLeWTxjdmeotust)IUhU3Mo7Xlc9mk2eWlFt7lS1fqYaJvttrlMnifv7dHsy6Sjd3BtN94fHEgfBc4LVP9vX04MQ1TPKBMoRPPOz6SjdsWbUgk1t7bEXesqrjyg(LmXMxOgmNL94cInEXONrXMaUGz4xYeBEHAWCw2JlWGXcsIevxTNsmWzTxORsZU337h5qpEidU55H(4Ww1zdL7TPZE8IqpKb38SqReWWCTxj56swttrJSHBlubIsk3uM7TxXdt4TwUnbaSGbuTUZ6FgR8OxpJInbCHTnAtfCRacmWzTxirkM0uGNcdZfuouYChKmJZbgp9mk2eWfmd)sMyZludMZYECbg4S2l8rIevxTNsmWzTxO75Z79JCOiipuohIOahYOsaFiBB0hQlhA8d94)6qw5q5COnmqg88qdzaRTTT2Ro0hjw2HcS3k4qfiZ2RoeX2HE8F9RCVnD2Jxe6Hm4MNLVP9vjGH5AVsY1LSMMIMEgfBc4cBB0Mk4wbeyGZAVWJEtNnzqcoW1qPEApWZ0ztgKGdCnuOJw88WeERLBtaalyavR7S(N19B6nD2Kbj4axdLhLyLpsKmD2Kbj4axdL6JNhMWBTCBcaybdOADN1)H6Y3920zpErOhYGBEw(M2xw4W1UL94svZfwttrJSHBlubIsk3uM7TxXlMYqOcBNjuGXKHbLqDmUnfWJE9mk2eWf22OnvWTciWaN1EHePystbEkmmxq5qjZDqYmohy80ZOytaxWm8lzInVqnyol7XfyGZAVWhpmHdIS5azoYpup98)7qckkbMWBTupymXw2JlWaN1EHpsKO6Q9uIboR9cDp88EB6ShVi0dzWnplFt7llC4A3YECPQ5cRPPOr2WTfQarjLBkZ92R4vgcvy7mHcmMmmOeQJXTPaE0ZMuq47JkOmu1v7PKnPadCw7L6F(KePystbEki89rfugQ6Q9KNEgfBc4cMHFjtS5fQbZzzpUadCw7f(U3Mo7Xlc9qgCZZY30(YchU2TShxQAUWAAkAMoBYGeCGRHs90EGhMWbr2CGmh5hQNE()DibfLat4TwQhmMyl7XfyGZAVW3920zpErOhYGBEw(M2xLDt)sbYChKeEGbN7bRPPOr2WTfQarjLBkZ92R4rVEgfBc4cBB0Mk4wbeyGZAVqIumPPapfgMlOCOK5oizgNdmE6zuSjGlyg(LmXMxOgmNL94cmWzTx4JejQUApLyGZAVq3Z4V3Mo7Xlc9qgCZZY30(QSB6xkqM7GKWdm4CpynnfntNnzqcoW1qPEApWJEgy5U0CMKbAlOiB9R2RircBntcKbpfgJveyGZAVqhTNFGV799(rouu7vk4q1A4kiV3Mo7XlIkWbCRPXal3L6Pv10u0cjOOefcgdCjBgobgmDYlgYgUTqfi2Mr1ELet4TwUnbamjsBqkQmC1eubctNnz4EB6ShViQahWT(BAFXal3L6Pv10u0WeERLBtaalyavR7KUN8)EB6ShViQahWT(BAFzEqjZz10u00ZOytaxyBJ2ub3kGadCw7fE0NMc8uWaQwbcWTqfWirspKb38u4D1EkPmGejmHdudUceB7GHhUXHcF8OpgYgUTqfi2Mr1ELet4qHejQUApLyGZAVqx88DVnD2JxevGd4w)nTVcmeotw2aNb4AAkAmiKGIsqbLeWTxjdmeotust)Q(pWlgYgUTqfi2Mr1ELet4q5EB6ShViQahWT(BAFfyiCMSSbodW10u0yqibfLGckjGBVsgyiCMGyJNEgfBc4cBB0Mk4wbeyGZAVuF88IHSHBlubITzuTxjXeou4rFmPPapfe((OckdvD1EsIuAkWtHH5ckhkzUdsMX5aJNECgrNc94KhTL94YHsM7GKbgtGn)fDXtIumPPapfgMlOCOK5oizgNdmE6XzeDk0JtE0w2JlhkzUdsgymb28x1tlEsKIrpoJOtHECYJ2YEC5qjZDqYaJX3920zpEruboGB930(kWq4mzzdCgGRPPOXGqckkbfusa3ELmWq4mbXgV0uGNccFFubLHQUAp5fdzd3wOceBZOAVsIjCOWJ(ystbEkmmxq5qjZDqYmohy80JZi6uOhN8OTShxouYChKmWycS5VOlEsKstbEkmmxq5qjZDqYmohy80JZi6uOhN8OTShxouYChKmWycS5VQNw88XJE9mk2eWfe((OckdvD1EkWaN1EP(N1LxmSjfe((OckdvD1EkztkWaN1EHej9mk2eWf22OnvWTciWaN1EP(N1LV7TPZE8IOcCa36VP9fdSCxQNwvttrdt4TwUnbaSGbuTUt6EOU8IHSHBlubITzuTxjXeERLBtaaFVnD2JxevGd4w)nTVOGsc42RKLe3VGAAkAmiKGIsqbLeWTxjdmeotust)IUN8IHSHBlubITzuTxjXeouU3Mo7XlIkWbCR)M2xuqjbC7vYsI7xqnnfngesqrjOGsc42RKbgcNjkPPFr3h4PNrXMaUW2gTPcUvabg4S2l0fpVyiB42cvGyBgv7vsmHdfE0htAkWtbHVpQGYqvxTNKiLMc8uyyUGYHsM7GKzCoW4PhNr0Pqpo5rBzpUCOK5oizGXeyZFrx8KiftAkWtHH5ckhkzUdsMX5aJNECgrNc94KhTL94YHsM7GKbgtGn)v90INePy0JZi6uOhN8OTShxouYChKmWy8DVnD2JxevGd4w)nTVOGsc42RKLe3VGAAkAmiKGIsqbLeWTxjdmeotust)IUpWlnf4PGW3hvqzOQR2tEXq2WTfQaX2mQ2RKychk8OpM0uGNcdZfuouYChKmJZbgp94mIof6XjpAl7XLdLm3bjdmMaB(l6INeP0uGNcdZfuouYChKmJZbgp94mIof6XjpAl7XLdLm3bjdmMaB(R6PfpF8OxpJInbCbHVpQGYqvxTNcmWzTxO7zDjrspJInbCHTnAtfCRacmWzTxO7zD5XMuq47JkOmu1v7PKnPadCw7f(U3Mo7XlIkWbCR)M2xmWYDPEAvnnfTyiB42cvGyBgv7vsmH3A52eaW3779JCO)o4aU1h6JNh1dfld3dUZG3BtN94frf4aU1sBaAbSoLudwQNrXMaEnUXb0kdHsIbBdW10u0stbEkkdHsIbBdW8sdxbPiBoqMJCtNs(hpDXZJQR2tjg4S2l1hpp9mk2eWfLHqjXGTbybg4S2l0rFLM9Ouxb)oE(4z6SjdsWbUgk0rJ)3BtN94frf4aU1sBGVP9fdSCxQNwvttrJ(yiB42cvGyBgv7vsmH3A52eaWKifsqrjkemg4s2mCcmy6KpE0hsqrjyg(LmXMxOgmNL94cInEychOgCfiyGXunusPEAfptNnzqcoW1qHoA8NejtNnzqcoW1qH2d8DVnD2JxevGd4wlTb(M2xWwZaUwxttrlKGIsuiymWLSz4eyW0jjsXq2WTfQaX2mQ2RKycV1YTjaGV3Mo7XlIkWbCRL2aFt7RadHZKLnWzaUgDqTcKPHRGSq7znnfn61ZOytaxyBJ2ub3kGadCw7L6JNhdcjOOeuqjbC7vYadHZeeBKiXGqckkbfusa3ELmWq4mrjn9R6)aF8ONQR2tjg4S2l0PNrXMaUGbwUlnNjzG2ckWaN1E57N1LejQUApLyGZAVuVEgfBc4cBB0Mk4wbeyGZAVW3920zpEruboGBT0g4BAFrbLeWTxjljUFb1OdQvGmnCfKfApRPPOXGqckkbfusa3ELmWq4mrjn9l6OXFE6zuSjGlSTrBQGBfqGboR9cD8NejgesqrjOGsc42RKbgcNjkPPFr3Z7TPZE8IOcCa3APnW30(IckjGBVswsC)cQrhuRazA4kil0EwttrtpJInbCHTnAtfCRacmWzTxQpEEmiKGIsqbLeWTxjdmeotust)IUN3779JCOAXT)cYY920zpErK42FbzHgrbKDcC14ghqR9IgtKwOcK8dH5jbNKbKBnuttrJE9mk2eWfe((OckdvD1EkWaN1EHej9mk2eWfmd)sMyZludMZYECbg4S2l8XJ(nifgMlOSAFiuctNnzGePnif22OLv7dHsy6Sjd8Ijnf4PWWCbLdLm3bjZ4CGrIuA4kifzZbYCKB6u(qDPlE(irIQR2tjg4S2l09WZ7TPZE8IiXT)cYY30(IOaYobUACJdOXzAledYYoaPKJO06AAkA6zuSjGlSTrBQGBfqGboR9cDXZJ(ya(HO32aMO9IgtKwOcK8dH5jbNKbKBnqIKEgfBc4I2lAmrAHkqYpeMNeCsgqU1GadCw7f(irIQR2tjg4S2l09WZ7TPZE8IiXT)cYY30(IOaYobUACJdOXWGXOAmijdLcOQPPOPNrXMaUW2gTPcUvabg4S2l8OpgGFi6TnGjAVOXePfQaj)qyEsWjza5wdKiPNrXMaUO9IgtKwOcK8dH5jbNKbKBniWaN1EHpsKO6Q9uIboR9cD8)EB6ShVisC7VGS8nTVikGStGRg34aAmd)IBgxYa9lj5bB6odwttrtpJInbCHTnAtfCRacmWzTx4rFma)q0BBat0ErJjslubs(HW8KGtYaYTgirspJInbCr7fnMiTqfi5hcZtcojdi3AqGboR9cFKir1v7PedCw7f6E45920zpErK42Fbz5BAFruazNaxPMMIg96zuSjGlSTrBQGBfqGboR9cjsHeuucMHFjtS5fQbZzzpUGyJpE0hdWpe92gWeTx0yI0cvGKFimpj4KmGCRbsK0ZOytax0ErJjslubs(HW8KGtYaYTgeyGZAVW3kYiY9bVIIAocLL94pgBu5kx5Ab]] )

end
