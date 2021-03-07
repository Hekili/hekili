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


    spec:RegisterPack( "Unholy", 20210307, [[d8eBSbqifPEerv2er6terJIO4ueLwfrvPELIsZIOYTiQkPDj4xkQmmfv5yaYYue9mIGPHqQRPOyBevvFtrOmoIQcNtrvrRtrI3HquP5HqDpezFaWbriYcbqpeHKjQiKlQOQWhrikJeHOItQOQYkbOxIqu1mjc1njcj2PqXpjQkAOkQQAPkcvpfvnvHsxLiKARevL4RkQknwfjTxf(lvnyvDyklMkEmHjtQldTzK6Zcz0i40sTAIq8Aa1Sj52OYUL8BLgov64iewoONJY0fDDG2oI67iPXRi48cvRNiK08rI9RYdGgXo41wIJyMCEtc08KW8MybGKpiA5FgIEWNXDXbVRja2IWbFzC4GxIUiSQ4dExlUAn9i2bpBbHcCWtitx2uMBUOoja6eel3CSMduzzVLaA05CSMtm3G3bSv58RgodETL4iMjN3KanpjmVjwai5dIw(jA5FWZCrXiMjNzYbpHwRXA4m41itm4LN8UFIqljCpr(QJiK3lrxewv8dq5jV7LOyqbH7bsU7NCEtc0b4bO8K39ejTebKLCyLS7Z9(jQMO5MiKUv4CteAjb29teiEFU3VLk(9IfSY7tdgHj7EQe27niEpobxuKO((CVx1KX7vBfDpwlyeH7Z9EolteEVm2IEgMGU3lpGKnCakp5D)e1mZrH675nbSPBrBQ7N)MiV3bfgidVxJM((iclOIDpNbmEp9cVNz67NiI8SWbO8K39s0SUIUF(UGL(EExS0i8EZPvD2i7EUfI3tRWj0oQ43lJL3t0ZEplnbWS77ILOPVFPVFMzLLi37NO5p)9fcMqtDVv675S437crYyL3Zwo8(ALVcrX9SobTS3Ifg8QMLSrSdEBrpdtq3rSJyaAe7GhlZrH6bah8cyNiSTbVgTKGh4QJiKbAQlyPrTpnyeMS7baP7fXfk0JfY1i7EkuUhAT2JKXkdMwZc4eAwYUx69qR1EKmwzW0AwaICwxS7jM09ab0G3ezV1G3Q4EDPh5iMjhXo4XYCuOEaWbVa2jcBBWRrlj4bU6iczGM6cwAu7tdgHj7Eaq6(zg8Mi7Tg8wf3Rl9ihXiHrSdESmhfQhaCWlGDIW2g8tFpzd2MJcdU7Q6kYdbRw4DxQi8EP3lZ9oG00bTbb2NqRy0lKZYERaO79sVhcwi9cJWGgnTQrw6fBRcyzokuFV07nr2KrpwixJS7jM09s4EkuU3eztg9yHCnYUN09tEVSdEtK9wdEnAjbVyB1ihXq0Jyh8yzokupa4Gxa7eHTn4N(EYgSnhfgC3v1vKhcwTW7Uur4G3ezV1GhDBnY1IroIzMrSdESmhfQhaCWBIS3AWtJSeHDf5zjSbgh8cyNiSTbVgDaPPd0ilryxrEQlyPdS0eaFpXKUxc3l9EXUk9sTcM7kmvCxggGiN1f7EIVxcdErCHc9PbJWKnIbOroIr(hXo4XYCuOEaWbVjYERbpnYse2vKNLWgyCWlGDIW2g8A0bKMoqJSeHDf5PUGLoWsta89eFpqdErCHc9PbJWKnIbOroIzInIDWJL5Oq9aGdEtK9wdEAKLiSRiplHnW4Gxa7eHTn4HGfgYMd956j67j(EzUxSRsVuRGgTKG3kTxJclEaICwxS7LE)03NMcRmOr6wHbSmhfQVNcL7f7Q0l1kOr6wHbiYzDXUx69PPWkdAKUvyalZrH67LDWlIluOpnyeMSrmanYro4Tf9oGqwoIDedqJyh8yzokupa4Gxa7eHTn4L5EhqA6aduRXYR3LlartK3tHY9tFpzd2MJcdU7Q6kYdbRw4DxQi8EzVx69YCVdinDqBqG9j0kg9c5SS3ka6EV07HGfsVWimOrtRAKLEX2QawMJc13l9EtKnz0JfY1i7EIjDVeUNcL7nr2KrpwixJS7jD)K3l7G3ezV1GxJwsWl2wnYrmtoIDWJL5Oq9aGdEbSte22GhcwTW7UuryqJ0TOZ7j(EzUhO5D)S3Rrlj4bU6iczGM6cwAu7tdgHj7E577LW9YEV071OLe8axDeHmqtDblnQ9PbJWKDpX3l)3l9(PVNSbBZrHb3DvDf5HGvl8UlveEpfk37asthyunixxrEUMLbq3bVjYERbp62AKRfJCeJegXo4XYCuOEaWbVa2jcBBWdbRw4DxQimOr6w059eF)KZCV071OLe8axDeHmqtDblnQ9PbJWKDpaUFM7LE)03t2GT5OWG7UQUI8qWQfE3Lkch8Mi7Tg8OBRrUwmYrme9i2bpwMJc1dao4fWoryBd(PVxJwsWdC1reYan1fS0O2Ngmct29sVF67jBW2CuyWDxvxrEiy1cV7sfH3tHY90DeH0droRl29eF)m3tHY9qR1EKmwzW0AwaNqZs29sVhAT2JKXkdMwZcqKZ6IDpX3pZG3ezV1GhDBnY1IroIzMrSdEtK9wdEQlyP9mxS0iCWJL5Oq9aGJCeJ8pIDWJL5Oq9aGdEbSte22GF67jBW2CuyWDxvxrEiy1cV7sfHdEtK9wdE0T1ixlg5ih8ryHWwmIDedqJyh8yzokupa4Gxa7eHTn4DaPPdmqTglVExUaenrEV07N(EYgSnhfgC3v1vKhcwTW7Uur49uOCVlMHidgTXvyWeztgh8Mi7Tg8A0scEX2QroIzYrSdESmhfQhaCWlGDIW2g8qWQfE3LkcdAKUfDEpX3dKeUNcL7P7icPhICwxS7j((zUx69tFVgDaPPd0ilryxrEQlyPdGUdEtK9wdEnAjbVyB1ihXiHrSdESmhfQhaCWlGDIW2g8IDv6LAfm3vyQ4UmmaroRl29sVxM7ttHvg0iDRWawMJc13tHY9ILmwwLHQJiKEAdVNcL7HGfsVWim4san4YTfYcyzokuFVS3l9EzUF67jBW2CuyWDxvxrEiyHS7Pq5E6oIq6HiN1f7EIVFM7LDWBIS3AWBvCVU0JCedrpIDWJL5Oq9aGdEbSte22GxJoG00bAKLiSRip1fS0bwAcGVha3lH7LE)03t2GT5OWG7UQUI8qWczdEtK9wdEQlyP9mxS0iCKJyMze7GhlZrH6bah8cyNiSTbVgDaPPd0ilryxrEQlyPdGU3l9EXUk9sTcM7kmvCxggGiN1fZJtWffjQVha3pZ9sVF67jBW2CuyWDxvxrEiyHSbVjYERbp1fS0EMlwAeoYrmY)i2bpwMJc1dao4fWoryBdEiy1cV7sfHbns3IoVN47NCE3l9(PVNSbBZrHb3DvDf5HGvl8Ulveo4nr2Bn41OLe8ITvJCeZeBe7GhlZrH6bah8cyNiSTbVgDaPPd0ilryxrEQlyPdS0eaFpX3d09sVF67jBW2CuyWDxvxrEiyHSbVjYERbpnYse2vKNLWgyCKJyKpgXo4XYCuOEaWbVa2jcBBWRrhqA6anYse2vKN6cw6alnbW3t89e99sVxSRsVuRG5Uctf3LHbiYzDX84eCrrI67j((zUx69tFpzd2MJcdU7Q6kYdblKn4nr2Bn4PrwIWUI8Se2aJJCeZ85i2bpwMJc1dao4fWoryBd(PVNSbBZrHb3DvDf5HGvl8Ulveo4nr2Bn41OLe8ITvJCKdEXsglRs2i2rmanIDWJL5Oq9aGdEbSte22GNSbBZrHbw6DvwvDfDV07HGvl8Ulveg0iDl68EaCpqY)9sVxM7f7Q0l1kyURWuXDzyaICwxS7Pq5(PVpnfwzWGCX9lTpjGETXvOoGL5Oq99sVxSRsVuRG2Ga7tOvm6fYzzVvaICwxS7L9EkuU3zzS7LEpDhri9qKZ6IDpX3deqdEtK9wdEgvdY1vKNRz5ihXm5i2bpwMJc1dao4nr2Bn4zunixxrEUMLdEnYeW2n7Tg88yEFU3dYW7n6eH3BUR4(MD)w3tut09g7(CV3fIKXkVFjJqH562v09t85)9uj0k8EgMzxr3d6EprnrsYg8cyNiSTbVyxLEPwbZDfMkUlddqKZ6IDV07L5EtKnz0JfY1i7Eaq6(jVx69MiBYOhlKRr29et6(zUx69qWQfE3LkcdAKUfDEpaUhO5D)S3lZ9MiBYOhlKRr29Y33l)3l79uOCVjYMm6Xc5AKDpaUFM7LEpeSAH3DPIWGgPBrN3dG7j65DVSJCeJegXo4XYCuOEaWbVa2jcBBWt2GT5OWal9UkRQUIUx69tFpBbvoDPdk00EN4ECcgNRcdyzokuFV07L5EXUk9sTcM7kmvCxggGiN1f7EkuUF67ttHvgmixC)s7tcOxBCfQdyzokuFV07f7Q0l1kOniW(eAfJEHCw2BfGiN1f7EzVx69qWcdzZH(C9e99a4EzUxc3p79oG00biy1cVyHqq3S3karoRl29YEpfk37Sm29sVNUJiKEiYzDXUN47NeObVjYERbV5SCDzzVLx1CoJCedrpIDWJL5Oq9aGdEbSte22GNSbBZrHbw6DvwvDfDV07zlOYPlDqHM27e3JtW4CvyalZrH67LEVm3R3mawewvCVJQJiKE9MbiYzDXUha3deq3tHY9tFFAkSYayryvX9oQoIqgWYCuO(EP3l2vPxQvqBqG9j0kg9c5SS3karoRl29Yo4nr2Bn4nNLRll7T8QMZzKJyMze7GhlZrH6bah8cyNiSTbVjYMm6Xc5AKDpaiD)K3l9EiyHHS5qFUEI(EaCVm3lH7N9EhqA6aeSAHxSqiOB2BfGiN1f7Ezh8Mi7Tg8MZY1LL9wEvZ5mYrmY)i2bpwMJc1dao4fWoryBdEYgSnhfgyP3vzv1v09sVxM7f7Q0l1kyURWuXDzyaICwxS7Pq5(PVpnfwzWGCX9lTpjGETXvOoGL5Oq99sVxSRsVuRG2Ga7tOvm6fYzzVvaICwxS7L9EkuU3zzS7LEpDhri9qKZ6IDpX3d0mdEtK9wdEgbtaSc9jb0dwuxysi(ihXmXgXo4XYCuOEaWbVa2jcBBWBISjJESqUgz3das3p59sVxM71OLe8wP9AuyXdzlaURO7Pq5EO1ApsgRmyAnlaroRl29et6EGi67LDWBIS3AWZiycGvOpjGEWI6ctcXh5ih8UquSCowoIDedqJyh8Mi7Tg8UB2Bn4XYCuOEaWroIzYrSdEtK9wdEO1m0Rrtp4XYCuOEaWroYbVyxLEPwSrSJyaAe7GhlZrH6bah8cyNiSTbpzd2MJcdCMezHEXUk9sTyEtKnz8EkuU3zzS7LEpDhri9qKZ6IDpX3pP8p4nr2Bn4D3S3AKJyMCe7GhlZrH6bah8cyNiSTbVyxLEPwbWIWQI7DuDeHmaroRl29eF)m3l9EXUk9sTcAdcSpHwXOxiNL9wbiYzDX84eCrrI67j((zUx69PPWkdGfHvf37O6iczalZrH67Pq5(PVpnfwzaSiSQ4EhvhridyzokuFpfk37Sm29sVNUJiKEiYzDXUN47LWmdEtK9wdEdYf3V0(Ka61OPh5igjmIDWJL5Oq9aGdEtK9wdE2cQ8q0Cr4Gxa7eHTn4tdgHziBo0NR3vKEjmZ9eF)m3l9(0GrygYMd9561nEpaUFM7LEVjYMm6Xc5AKDpXKUxcdErCHc9PbJWKnIbOroIHOhXo4XYCuOEaWbVjYERbpyryvX9oQoIqo41itaB3S3AWtKZQ0S7bOQJiK3tVW7bDVp37N5Egk2sZUp37zXlX9u7KW9ej3vyQ4UmuU7LptciKAZq5UhKH3tTtc3prge47JfAfJEHCw2Bfg8cyNiSTbpzd2MJcdS07QSQ6k6EP3lZ9IDv6LAfm3vyQ4UmmaroRlMhNGlksuFpX3pZ9uOCVyxLEPwbZDfMkUlddqKZ6I5Xj4IIe13dG7bAE3l79sVxM7f7Q0l1kOniW(eAfJEHCw2BfGiN1f7EIVpsOVNcL7DaPPdAdcSpHwXOxiNL9wbq37LDKJyMze7GhlZrH6bah8cyNiSTbVjYMm6Xc5AKDpaiD)K3tHY9olJDV07P7icPhICwxS7j((jbAWBIS3AWdwewvCVJQJiKJCeJ8pIDWJL5Oq9aGdEbSte22GNSbBZrHbw6DvwvDfDV07L5E9MbWIWQI7DuDeH0R3maroRl29uOC)03NMcRmawewvCVJQJiKbSmhfQVx2bVjYERbV2Ga7tOvm6fYzzV1ihXmXgXo4XYCuOEaWbVa2jcBBWBISjJESqUgz3das3p59uOCVZYy3l9E6oIq6HiN1f7EIVFsGg8Mi7Tg8AdcSpHwXOxiNL9wJCeJ8Xi2bpwMJc1dao4fWoryBdEtKnz0JfY1i7Es3d09sVxJoG00bAKLiSRip1fS0bwAcGVha3lHbVjYERbV5Uctf3LHJCeZ85i2bpwMJc1dao4nr2Bn4n3vyQ4UmCWlGDIW2g8MiBYOhlKRr29aG09tEV071OdinDGgzjc7kYtDblDGLMa47bW9s4EP3p99A0scER0EnkS4HSfa3v0GxexOqFAWimzJyaAKJyaAEJyh8yzokupa4Gxa7eHTn4HGvl8Ulveg0iDl68EIVhiI(EP3lZ9IDv6LAfalcRkU3r1reYae5SUy3t89anV7Pq5E9MbWIWQI7DuDeH0R3maroRl29Yo4nr2Bn4zGCCB5Jmy0gxHJCedqanIDWJL5Oq9aGdEbSte22GNSbBZrHbw6DvwvDfDV071OdinDGgzjc7kYtDblDGLMa47j((jVx69YCVlMbZDf(iclOkyISjJ3tHY9oG00bTbb2NqRy0lKZYERaO79sVF67DXmyqU4(iclOkyISjJ3l7G3ezV1GhSiSQ4EJXmqvoYrman5i2bpwMJc1dao4nr2Bn4blcRkU3ymduLdEbSte22G3eztg9yHCnYUhaKUFY7LEVgDaPPd0ilryxrEQlyPdS0eaFpX3p5GxexOqFAWimzJyaAKJyascJyh8yzokupa4Gxa7eHTn4N(ExmdrewqvWeztgh8Mi7Tg8qRzOxJMEKJCWhHfcBH3wCe7igGgXo4XYCuOEaWbVjYERbpvRtp9c9IDv6LAn4fWoryBd(0uyLb2cQ8q0CryalZrH67LEFAWimdzZH(C9UI0lHzUN47N5EP3t3respe5SUy3dG7N5EP3l2vPxQvGTGkpenxegGiN1f7EIVxM7Je67LVVFEHj2m3l79sV3eztg9yHCnYUNys3lHbFzC4GNTGkpenxeoYrmtoIDWJL5Oq9aGdEbSte22GxM7N(EYgSnhfgC3v1vKhcwTW7Uur49uOCVdinDGbQ1y517YfGOjY7L9EP3lZ9oG00bTbb2NqRy0lKZYERaO79sVhcwi9cJWGgnTQrw6fBRcyzokuFV07nr2KrpwixJS7jM09s4EkuU3eztg9yHCnYUN09tEVSdEtK9wdEnAjbVyB1ihXiHrSdESmhfQhaCWlGDIW2g8oG00bgOwJLxVlxaIMiVNcL7N(EYgSnhfgC3v1vKhcwTW7Uur4G3ezV1GhDBnY1IroIHOhXo4XYCuOEaWbVjYERbp1fS0EMlwAeo4fWoryBdEzUxSRsVuRG5Uctf3LHbiYzDXUha3pZ9sVxJoG00bAKLiSRip1fS0bq37Pq5En6asthOrwIWUI8uxWshyPja(EaCVeUx27LEVm3t3respe5SUy3t89IDv6LAf0OLe8wP9AuyXdqKZ6ID)S3d08UNcL7P7icPhICwxS7bW9IDv6LAfm3vyQ4UmmaroRl29Yo4fXfk0Ngmct2igGg5iMzgXo4XYCuOEaWbVjYERbpnYse2vKNLWgyCWlGDIW2g8A0bKMoqJSeHDf5PUGLoWsta89et6EjCV07f7Q0l1kyURWuXDzyaICwxS7j(EjCpfk3RrhqA6anYse2vKN6cw6alnbW3t89an4fXfk0Ngmct2igGg5ig5Fe7GhlZrH6bah8Mi7Tg80ilryxrEwcBGXbVa2jcBBWl2vPxQvWCxHPI7YWae5SUy3dG7N5EP3RrhqA6anYse2vKN6cw6alnbW3t89an4fXfk0Ngmct2igGg5ih8jSlGXKnIDedqJyh8yzokupa4G3ezV1GVlMacMMJc9ebOvjiNxJKBbo4fWoryBdEzUxSRsVuRayryvX9oQoIqgGiN1f7EkuUxSRsVuRG2Ga7tOvm6fYzzVvaICwxS7L9EP3lZ9UygmixCFeHfufmr2KX7Pq5ExmdM7k8rewqvWeztgVx69tFFAkSYGb5I7xAFsa9AJRqDalZrH67Pq5(0GrygYMd956DfPFY5DpX3pZ9YEpfk37Sm29sVNUJiKEiYzDXUN47NeObFzC4GVlMacMMJc9ebOvjiNxJKBboYrmtoIDWJL5Oq9aGdEtK9wdEotyoq0ZiGy65azTyWlGDIW2g8IDv6LAfm3vyQ4UmmaroRl29eF)m3l9EzUF67rIaSDDrDOlMacMMJc9ebOvjiNxJKBbEpfk3l2vPxQvOlMacMMJc9ebOvjiNxJKBbgGiN1f7EzVNcL7Dwg7EP3t3respe5SUy3t89tc0GVmoCWZzcZbIEgbetphiRfJCeJegXo4XYCuOEaWbVjYERbVgIMMUHONmYyOAWlGDIW2g8IDv6LAfm3vyQ4UmmaroRl29sVxM7N(EKiaBxxuh6IjGGP5OqpraAvcY51i5wG3tHY9IDv6LAf6IjGGP5OqpraAvcY51i5wGbiYzDXUx27Pq5ENLXUx690DeH0droRl29eFVeg8LXHdEnennDdrpzKXq1ihXq0Jyh8yzokupa4G3ezV1GxBqG52T8AuaSN8cnrNXh8cyNiSTbVyxLEPwbZDfMkUlddqKZ6IDV07L5(PVhjcW21f1HUyciyAok0teGwLGCEnsUf49uOCVyxLEPwHUyciyAok0teGwLGCEnsUfyaICwxS7L9EkuU3zzS7LEpDhri9qKZ6IDpX3pjqd(Y4WbV2GaZTB51Oayp5fAIoJpYrmZmIDWJL5Oq9aGdEbSte22GxM7f7Q0l1kyURWuXDzyaICwxS7Pq5EhqA6G2Ga7tOvm6fYzzVva09EzVx69YC)03Jeby76I6qxmbemnhf6jcqRsqoVgj3c8EkuUxSRsVuRqxmbemnhf6jcqRsqoVgj3cmaroRl29Yo4nr2Bn4bzOVtKJnYro41iTbQYrSJyaAe7G3ezV1GNRlTNgIOevCWJL5Oq9aGJCeZKJyh8yzokupa4GFDh8mmh8Mi7Tg8KnyBokCWt2uG4GxSRsVuRadKJBlFKbJ24kmaroRl29eF)m3l9(0uyLbgih3w(idgTXvyalZrH6bpzd6lJdh8U7Q6kYdbRw4DxQiCKJyKWi2bpwMJc1dao4x3bpdZbVjYERbpzd2MJch8Knfio4ttHvgylOYdrZfHbSmhfQVx69qWcVN47N8EP3NgmcZq2COpxVRi9syM7j((zUx690DeH0droRl29a4(zg8KnOVmoCW7URQRipeSq2ihXq0Jyh8yzokupa4GFDh8mmh8Mi7Tg8KnyBokCWt2uG4G3eztg9yHCnYUN09aDV07L5(PVhAT2JKXkdMwZc4eAwYUNcL7HwR9izSYGP1Sqx3dG7bAM7LDWt2G(Y4Wbpl9UkRQUIg5iMzgXo4XYCuOEaWb)6o4zyo4nr2Bn4jBW2Cu4GNSPaXbVlMHidgTXvyWeztgVNcL7DaPPdGfHvf3BmMbQYaO79uOCFAkSYGb5I7xAFsa9AJRqDalZrH67LEVlMbZDf(iclOkyISjJ3tHY9oG00bTbb2NqRy0lKZYERaO7GNSb9LXHdEotISqVyxLEPwmVjYMmoYrmY)i2bpwMJc1dao4fWoryBdEiy1cV7sfHbns3IoVha3l)ZCV07L5ExmdrgmAJRWGjYMmEpfk3p99PPWkdmqoUT8rgmAJRWawMJc13l79sVhcwyqJ0TOZ7baP7NzWBIS3AWBqHvOpxieRCKJyMyJyh8yzokupa4Gxa7eHTn4jBW2CuyGZKil0l2vPxQfZBISjJ3tHY9PbJWmKnh6Z1RB8EIjDVdinDWrTR2tdcJh0Gql7Tg8Mi7Tg8oQD1EAqy8roIr(ye7GhlZrH6bah8cyNiSTbpzd2MJcdCMezHEXUk9sTyEtKnz8EkuUpnyeMHS5qFUEDJ3tmP7DaPPdoiKHqG7kkObHw2Bn4nr2Bn4DqidHa3v0ihXmFoIDWJL5Oq9aGdEbSte22G3bKMoawewvCplHyfLecGUdEtK9wdEvhrizEjcOoIdRCKJyaAEJyh8yzokupa4G3ezV1G3kbYsOP8ctPg8AKjGTB2Bn4jsLazj0u3tuMsDVWQ7tyhfHW7j67D3eRSn19oG00m5UhnbH7vgl7k6EGM5Egk2sZc3lrNTQLOI67jyq99IvJ67ZMdV3y3B3NWokcH3N79aJO79DEpenT5OWWGxa7eHTn4jBW2CuyGZKil0l2vPxQfZBISjJ3tHY9PbJWmKnh6Z1RB8EIjDpqZmYrmab0i2bpwMJc1dao4fWoryBdEtKnz0JfY1i7Eaq6(jVNcL7L5EiyHbns3IoVhaKUFM7LEpeSAH3DPIWGgPBrN3das3l)Z7Ezh8Mi7Tg8guyf6DbvmCKJyaAYrSdESmhfQhaCWlGDIW2g8KnyBokmWzsKf6f7Q0l1I5nr2KX7Pq5(0GrygYMd9561nEpXKU3bKMoq3q0rTRoObHw2Bn4nr2Bn4PBi6O2vpYrmajHrSdESmhfQhaCWlGDIW2g8oG00bWIWQI7zjeROKqa09EP3BISjJESqUgz3t6EGg8Mi7Tg8owKFP9jSfaZg5igGi6rSdESmhfQhaCWBIS3AWVGPdenGh8AKjGTB2Bn4LOyDLwxDfDV8LgcQWkVF(RSiq8(MDVDVlSxyNXh8cyNiSTbVEZa5gcQWk9UklcedqKgImcMJcVx69tFFAkSYayryvX9oQoIqgWYCuO(EP3p99qR1EKmwzW0AwaNqZs2ihXa0mJyh8yzokupa4Gxa7eHTn41Bgi3qqfwP3vzrGyaI0qKrWCu49sV3eztg9yHCnYUhaKUFY7LEVm3p99PPWkdGfHvf37O6iczalZrH67Pq5(0uyLbWIWQI7DuDeHmGL5Oq99sVxSRsVuRayryvX9oQoIqgGiN1f7Ezh8Mi7Tg8ly6ard4roIbi5Fe7GhlZrH6bah8cyNiSTbpeSq6fgHbgOlczj06kGL5Oq99sVxM71BgOHll90izegGinezemhfEpfk3R3m4O2v7DvweigGinezemhfEVSdEtK9wd(fmDGOb8ihXa0eBe7GhlZrH6bah8AKjGTB2Bn4jsIS36EjUzj7ER03lF6Ifcz3lJ8PlwiKnhpseGyjq29Gfd01DHjQVVR7nTERGSdEtK9wdEHPuEtK9wEvZYbVQzPVmoCWNWUagt2ihXaK8Xi2bpwMJc1dao4nr2Bn4fMs5nr2B5vnlh8QML(Y4WbVyjJLvjBKJyaA(Ce7GhlZrH6bah8AKjGTB2Bn4nr2BXcAK2av5SKMJHebiwcuUMMKjYMm6Xc5AKrciPtRrlj4bU6iczq3mZrHEBtTCLXHKwxSq4umixC)s7tcOxJMEk0ilryxrEwcBGXPqJSeHDf5zjSbgNcyryvX9oQoIqof3n7TMI2Ga7tOvm6fYzzV1um3vyQ4UmCWBIS3AWlmLYBIS3YRAwo4vnl9LXHdEXUk9sTyJCeZKZBe7GhlZrH6bah8cyNiSTbVjYMm6Xc5AKDpaiD)K3l9EzUxSRsVuRGgTKG3kTxJclEaICwxS7j(EGM39sVF67ttHvg0iDRWawMJc13tHY9IDv6LAf0iDRWae5SUy3t89anV7LEFAkSYGgPBfgWYCuO(EzVx69tFVgTKG3kTxJclEiBbWDfn4nr2Bn4HGL3ezVLx1SCWRAw6lJdh82IEgMGUJCeZKanIDWJL5Oq9aGdEbSte22G3eztg9yHCnYUhaKUFY7LEVgTKG3kTxJclEiBbWDfn4nr2Bn4HGL3ezVLx1SCWRAw6lJdh82IEhqilh5iMjNCe7GhlZrH6bah8cyNiSTbVjYMm6Xc5AKDpaiD)K3l9EzUF671OLe8wP9AuyXdzlaURO7LEVm3l2vPxQvqJwsWBL2RrHfparoRl29a4EGM39sVF67ttHvg0iDRWawMJc13tHY9IDv6LAf0iDRWae5SUy3dG7bAE3l9(0uyLbns3kmGL5Oq99YEVSdEtK9wdEiy5nr2B5vnlh8QML(Y4WbFewiSfEBXroIzsjmIDWJL5Oq9aGdEbSte22G3eztg9yHCnYUN09an4nr2Bn4fMs5nr2B5vnlh8QML(Y4WbFewiSfJCKJCWtgHSERrmtoVjbAEtop5JbpvdwDfXg8ZxI0epM5xmezt5(7JLaEFZ5UW8E6fEVK2IEgMGUsEpejcWgI67zlhEVbMlNLO(EbbRIqw4auI7cVxct5EIAlYimr99scblKEHryyQsEFU3ljeSq6fgHHPgWYCuOwY7LbOjiB4auI7cVFInL7jQTiJWe13lzAkSYWuL8(CVxY0uyLHPgWYCuOwY7LzYjiB4a8aC(sKM4Xm)IHiBk3FFSeW7Bo3fM3tVW7L0w07aczPK3drIaSHO(E2YH3BG5YzjQVxqWQiKfoaL4UW7bAk3tuBrgHjQVxsiyH0lmcdtvY7Z9EjHGfsVWimm1awMJc1sEVmanbzdhGhGZxI0epM5xmezt5(7JLaEFZ5UW8E6fEVKryHWwi59qKiaBiQVNTC49gyUCwI67feSkczHdqjUl8EjmL7jQTiJWe13ljeSq6fgHHPk595EVKqWcPxyegMAalZrHAjVxgGMGSHdWdW5lrAIhZ8lgISPC)9XsaVV5CxyEp9cVxsXsglRsMK3drIaSHO(E2YH3BG5YzjQVxqWQiKfoaL4UW7bAk3tuBrgHjQVxY0uyLHPk595EVKPPWkdtnGL5OqTK3ldqtq2WbOe3fEVeMY9e1wKryI67LmnfwzyQsEFU3lzAkSYWudyzokul59Ya0eKnCakXDH3lHPCprTfzeMO(EjzlOYPlDyQsEFU3ljBbvoDPdtnGL5OqTK3ldqtq2WbOe3fEprpL7jQTiJWe13lzAkSYWuL8(CVxY0uyLHPgWYCuOwY7LbOjiB4auI7cVNONY9e1wKryI67LKTGkNU0HPk595EVKSfu50Lom1awMJc1sEVmanbzdhGsCx49Y)uUNO2ImctuFVKPPWkdtvY7Z9EjttHvgMAalZrHAjVxgGMGSHdWdW5lrAIhZ8lgISPC)9XsaVV5CxyEp9cVxsXUk9sTysEpejcWgI67zlhEVbMlNLO(EbbRIqw4auI7cVFYPCprTfzeMO(EjttHvgMQK3N79sMMcRmm1awMJc1sEVmtobzdhGsCx49Y)uUNO2ImctuFVKPPWkdtvY7Z9EjttHvgMAalZrHAjVxgGMGSHdWdW5lrAIhZ8lgISPC)9XsaVV5CxyEp9cVxYiSqyl82IsEpejcWgI67zlhEVbMlNLO(EbbRIqw4auI7cVhOPCVeDXaDDxyI67nr2BDVKuTo90l0l2vPxQLKHdqjUl8EGMY9e1wKryI67LmnfwzyQsEFU3lzAkSYWudyzokul59Ya0eKnCakXDH3p5uUNO2ImctuFVKqWcPxyegMQK3N79scblKEHryyQbSmhfQL8EzaAcYgoapaNVePjEmZVyiYMY93hlb8(MZDH590l8EjtyxaJjtY7Hira2quFpB5W7nWC5Se13liyveYchGsCx49anL7jQTiJWe13lzAkSYWuL8(CVxY0uyLHPgWYCuOwY7LbOjiB4a8aC(sKM4Xm)IHiBk3FFSeW7Bo3fM3tVW7LuJ0gOkL8EiseGne13Zwo8Edmxolr99ccwfHSWbOe3fE)Kt5EIAlYimr99sMMcRmmvjVp37LmnfwzyQbSmhfQL8ElVF(q(uIVxgGMGSHdqjUl8EjmL7jQTiJWe13lzAkSYWuL8(CVxY0uyLHPgWYCuOwY7LbOjiB4auI7cVFMPCprTfzeMO(EjttHvgMQK3N79sMMcRmm1awMJc1sEVmanbzdhGsCx49ar0t5EIAlYimr99sMMcRmmvjVp37LmnfwzyQbSmhfQL8EzaAcYgoaL4UW7bAMPCprTfzeMO(EjttHvgMQK3N79sMMcRmm1awMJc1sEVmtobzdhGsCx49aj)t5EIAlYimr99scblKEHryyQsEFU3ljeSq6fgHHPgWYCuOwY7LbOjiB4auI7cVFY5nL7jQTiJWe13lzAkSYWuL8(CVxY0uyLHPgWYCuOwY7LzYjiB4auI7cVFYjNY9e1wKryI67LmnfwzyQsEFU3lzAkSYWudyzokul59Ym5eKnCaEao)4CxyI67NpV3ezV19QMLSWb4G3fU0Tch8YtE3prOLeUNiF1reY7LOlcRk(bO8K39sumOGW9aj39toVjb6a8auEY7EIKwIaYsoSs295E)evt0Ctes3kCUjcTKa7(jceVp373sf)EXcw59PbJWKDpvc79geVhNGlksuFFU3RAY49QTIUhRfmIW95EpNLjcVxgBrpdtq37LhqYgoaLN8UFIAM5Oq998Ma20TOn19ZFtK37GcdKH3RrtFFeHfuXUNZagVNEH3Zm99terEw4auEY7EjAwxr3pFxWsFpVlwAeEV50QoBKDp3cX7Pv4eAhv87LXY7j6zVNLMay29DXs003V03pZSYsK79t08N)(cbtOPU3k99Cw87DHizSY7zlhEFTYxHO4EwNGw2BXchGYtE3tueSkc13Zzv87LKUJiKEiYzDXK8EXw6o7Tmf7(CV3CDvXVVR7Dwg7E6oIqYUFlv87LrHm29e1eDpvJL49BDFcngbzdhGhGMi7TybxikwohlNL0CUB2BDaAIS3IfCHOy5CSCwsZbTMHEnA6dWdq5jV7NpMakatuFpsgHXVpBo8(KaEVjYfEFZU3iBTYCuy4a0ezVfJexxApnerjQ4bO8K39YxmyBokKDaAIS3InlP5iBW2CuOCLXHKC3v1vKhcwTW7UurOCKnfissSRsVuRadKJBlFKbJ24kmaroRlgXZinnfwzGbYXTLpYGrBCfEaAIS3InlP5iBW2CuOCLXHKC3v1vKhcwitoYMcejLMcRmWwqLhIMlcLcblK4jLMgmcZq2COpxVRi9sygINrkDhri9qKZ6IbGzoanr2BXML0CKnyBokuUY4qsS07QSQ6ksoYMcejzISjJESqUgzKasQmtdTw7rYyLbtRzbCcnlzuOaTw7rYyLbtRzHUaaqZi7bOjYEl2SKMJSbBZrHYvghsIZKil0l2vPxQfZBISjJYr2uGijxmdrgmAJRWGjYMmsHIdinDaSiSQ4EJXmqvgaDPqjnfwzWGCX9lTpjGETXvOwQlMbZDf(iclOkyISjJuO4asth0geyFcTIrVqol7TcGUhGYtE3pXnrBk2bOjYEl2SKMZGcRqFUqiwPCnnjiy1cV7sfHbns3IobG8pJuzCXmezWOnUcdMiBYifktNMcRmWa542YhzWOnUcdyzokulRuiyHbns3IobaPzoanr2BXML0CoQD1EAqyC5AAsKnyBokmWzsKf6f7Q0l1I5nr2KrkusdgHziBo0NRx3iXKCaPPdoQD1EAqy8GgeAzV1bOjYEl2SKMZbHmecCxrY10KiBW2CuyGZKil0l2vPxQfZBISjJuOKgmcZq2COpxVUrIj5asthCqidHa3vuqdcTS36a0ezVfBwsZP6icjZlra1rCyLY10KCaPPdGfHvf3ZsiwrjHaO7bO8UNivcKLqtDprzk19cRUpHDuecVNOV3DtSY2u37astZK7E0eeUxzSSRO7bAM7zOylnlCVeD2QwIkQVNGb13lwnQVpBo8EJDVDFc7OieEFU3dmIU3359q00MJcdhGMi7TyZsAoReilHMYlmLsUMMezd2MJcdCMezHEXUk9sTyEtKnzKcL0GrygYMd9561nsmjGM5a0ezVfBwsZzqHvO3fuXq5AAsMiBYOhlKRrgainjfkYablmOr6w0jainJuiy1cV7sfHbns3Iobaj5FEYEaAIS3InlP5OBi6O2vlxttISbBZrHbotISqVyxLEPwmVjYMmsHsAWimdzZH(C96gjMKdinDGUHOJAxDqdcTS36a0ezVfBwsZ5yr(L2NWwamtUMMKdinDaSiSQ4EwcXkkjeaDLAISjJESqUgzKa6auE3lrX6kTU6k6E5lneuHvE)8xzrG49n7E7ExyVWoJFaAIS3InlP5wW0bIgWY10K0Bgi3qqfwP3vzrGyaI0qKrWCuO0PttHvgalcRkU3r1resPtdTw7rYyLbtRzbCcnlzhGMi7TyZsAUfmDGObSCnnj9MbYneuHv6DvweigGinezemhfk1eztg9yHCnYaaPjLkZ0PPWkdGfHvf37O6icjfkPPWkdGfHvf37O6icPuXUk9sTcGfHvf37O6iczaICwxmzpanr2BXML0Cly6ardy5AAsqWcPxyegyGUiKLqRlPYO3mqdxw6PrYimarAiYiyokKcf9Mbh1UAVRYIaXaePHiJG5OqzpaL39ejr2BDVe3SKDVv67LpDXcHS7Lr(0fleYMJhjcqSei7EWIb66UWe13319MwVvq2dqtK9wSzjnNWukVjYElVQzPCLXHKsyxaJj7a0ezVfBwsZjmLYBIS3YRAwkxzCijXsglRs2bO8U3ezVfBwsZXqIaelbkxttYeztg9yHCnYibK0P1OLe8axDeHmOBM5OqVTPwUY4qsRlwiCkgKlUFP9jb0RrtpfAKLiSRiplHnW4uOrwIWUI8Se2aJtbSiSQ4EhvhriNI7M9wtrBqG9j0kg9c5SS3AkM7kmvCxgEaAIS3InlP5eMs5nr2B5vnlLRmoKKyxLEPwSdqtK9wSzjnheS8Mi7T8QMLYvghsYw0ZWe0vUMMKjYMm6Xc5AKbastkvgXUk9sTcA0scER0EnkS4biYzDXigO5jD60uyLbns3kKcfXUk9sTcAKUvyaICwxmIbAEsttHvg0iDRqzLoTgTKG3kTxJclEiBbWDfDaAIS3InlP5GGL3ezVLx1SuUY4qs2IEhqilLRPjzISjJESqUgzaG0Ks1OLe8wP9AuyXdzlaUROdqtK9wSzjnheS8Mi7T8QMLYvghskcle2cVTOCnnjtKnz0JfY1idaKMuQmtRrlj4Ts71OWIhYwaCxrsLrSRsVuRGgTKG3kTxJclEaICwxmaa08KoDAkSYGgPBfsHIyxLEPwbns3kmaroRlgaaAEsttHvg0iDRqzL9a0ezVfBwsZjmLYBIS3YRAwkxzCiPiSqylKRPjzISjJESqUgzKa6a8auEY7EI0oFCpabHS8a0ezVflyl6DaHSKKgTKGxSTsUMMKmoG00bgOwJLxVlxaIMiPqzAYgSnhfgC3v1vKhcwTW7UurOSsLXbKMoOniW(eAfJEHCw2BfaDLcblKEHryqJMw1il9ITvsnr2KrpwixJmIjjbkumr2KrpwixJmstk7bOjYElwWw07acz5SKMdDBnY1c5AAsqWQfE3LkcdAKUfDsSmanVz1OLe8axDeHmqtDblnQ9PbJWKjFlbzLQrlj4bU6iczGM6cwAu7tdgHjJy5x60KnyBokm4URQRipeSAH3DPIqkuCaPPdmQgKRRipxZYaO7bOjYElwWw07acz5SKMdDBnY1c5AAsqWQfE3LkcdAKUfDs8KZivJwsWdC1reYan1fS0O2NgmctgaMr60KnyBokm4URQRipeSAH3DPIWdqtK9wSGTO3beYYzjnh62AKRfY10KMwJwsWdC1reYan1fS0O2NgmctM0PjBW2CuyWDxvxrEiy1cV7sfHuOq3respe5SUyepdfkqR1EKmwzW0AwaNqZsMuO1ApsgRmyAnlaroRlgXZCaAIS3IfSf9oGqwolP5OUGL2ZCXsJWdqtK9wSGTO3beYYzjnh62AKRfY10KMMSbBZrHb3DvDf5HGvl8UlveEaEakp5DprANpUNhtq3dqtK9wSGTONHjOljRI71LwUMMKgTKGh4QJiKbAQlyPrTpnyeMmaqsexOqpwixJmkuGwR9izSYGP1SaoHMLmPqR1EKmwzW0AwaICwxmIjbeqhGMi7TybBrpdtq3zjnNvX96slxttsJwsWdC1reYan1fS0O2NgmctgainZbOjYElwWw0ZWe0DwsZPrlj4fBRKRPjnnzd2MJcdU7Q6kYdbRw4DxQiuQmoG00bTbb2NqRy0lKZYERaORuiyH0lmcdA00QgzPxSTsQjYMm6Xc5AKrmjjqHIjYMm6Xc5AKrAszpanr2BXc2IEgMGUZsAo0T1ixlKRPjnnzd2MJcdU7Q6kYdbRw4DxQi8a0ezVflyl6zyc6olP5OrwIWUI8Se2aJYjIluOpnyeMmsajxttsJoG00bAKLiSRip1fS0bwAcGjMKeKk2vPxQvWCxHPI7YWae5SUyelHdqtK9wSGTONHjO7SKMJgzjc7kYZsydmkNiUqH(0GryYibKCnnjn6asthOrwIWUI8uxWshyPjaMyGoanr2BXc2IEgMGUZsAoAKLiSRiplHnWOCI4cf6tdgHjJeqY10KGGfgYMd956jAILrSRsVuRGgTKG3kTxJclEaICwxmPtNMcRmOr6wHuOi2vPxQvqJ0TcdqKZ6IjnnfwzqJ0TcL9a8auEY7(5)M9whGMi7TybXUk9sTyKC3S3sUMMezd2MJcdCMezHEXUk9sTyEtKnzKcfNLXKs3respe5SUyepP8Fakp5DprTRsVul2bOjYElwqSRsVul2SKMZGCX9lTpjGEnAA5AAsIDv6LAfalcRkU3r1reYae5SUyepJuXUk9sTcAdcSpHwXOxiNL9wbiYzDX84eCrrIAINrAAkSYayryvX9oQoIqsHY0PPWkdGfHvf37O6icjfkolJjLUJiKEiYzDXiwcZCaAIS3Ife7Q0l1InlP5ylOYdrZfHYjIluOpnyeMmsajxttknyeMHS5qFUExr6LWmepJ00GrygYMd9561ncGzKAISjJESqUgzetschGY7EICwLMDpavDeH8E6fEpO795E)m3ZqXwA295EplEjUNANeUNi5Uctf3LHYDV8zsaHuBgk39Gm8EQDs4(jYGaFFSqRy0lKZYERWbOjYElwqSRsVul2SKMdSiSQ4EhvhriLRPjr2GT5OWal9UkRQUIKkJyxLEPwbZDfMkUlddqKZ6I5Xj4IIe1epdfkIDv6LAfm3vyQ4UmmaroRlMhNGlksudaGMNSsLrSRsVuRG2Ga7tOvm6fYzzVvaICwxmIJeAkuCaPPdAdcSpHwXOxiNL9wbqxzpanr2BXcIDv6LAXML0CGfHvf37O6icPCnnjtKnz0JfY1idaKMKcfNLXKs3respe5SUyepjqhGMi7TybXUk9sTyZsAoTbb2NqRy0lKZYEl5AAsKnyBokmWsVRYQQRiPYO3mawewvCVJQJiKE9MbiYzDXOqz60uyLbWIWQI7DuDeHu2dqtK9wSGyxLEPwSzjnN2Ga7tOvm6fYzzVLCnnjtKnz0JfY1idaKMKcfNLXKs3respe5SUyepjqhGMi7TybXUk9sTyZsAoZDfMkUldLRPjzISjJESqUgzKasQgDaPPd0ilryxrEQlyPdS0eadajCaAIS3Ife7Q0l1InlP5m3vyQ4UmuorCHc9PbJWKrci5AAsMiBYOhlKRrgainPun6asthOrwIWUI8uxWshyPjagasq60A0scER0EnkS4HSfa3v0bOjYElwqSRsVul2SKMJbYXTLpYGrBCfkxttccwTW7UuryqJ0TOtIbIOLkJyxLEPwbWIWQI7DuDeHmaroRlgXanpku0BgalcRkU3r1resVEZae5SUyYEaAIS3Ife7Q0l1InlP5alcRkU3ymduLY10KiBW2CuyGLExLvvxrs1OdinDGgzjc7kYtDblDGLMayINuQmUygm3v4JiSGQGjYMmsHIdinDqBqG9j0kg9c5SS3ka6kDAxmdgKlUpIWcQcMiBYOShGMi7TybXUk9sTyZsAoWIWQI7ngZavPCI4cf6tdgHjJeqY10Kmr2KrpwixJmaqAsPA0bKMoqJSeHDf5PUGLoWstamXtEaAIS3Ife7Q0l1InlP5GwZqVgnTCnnPPDXmerybvbtKnz8auEY7(jQzMJc1YDVebKL3xBEpenLk(91c5m19oibJCVW7tcwkj7EQlmjCVliKb2v09DjFnY4WWbO8K39Mi7TybXUk9sTyZsAoMjGnDlAt5DnrkxttYeztg9yHCnYaaPjLoTdinDqBqG9j0kg9c5SS3ka6kDAXUk9sTcAdcSpHwXOxiNL9wbiA64uO4SmMu6oIq6HiN1fJ4iH(a8auEY7EIAjJLv59ejNw1zJSdqtK9wSGyjJLvjJeJQb56kYZ1SuUMMezd2MJcdS07QSQ6kskeSAH3DPIWGgPBrNaai5xQmIDv6LAfm3vyQ4UmmaroRlgfktNMcRmyqU4(L2NeqV24kulvSRsVuRG2Ga7tOvm6fYzzVvaICwxmzPqXzzmP0DeH0droRlgXab0bO8UNhZ7Z9EqgEVrNi8EZDf33S736EIAIU3y3N79UqKmw59lzekmx3UIUFIp)VNkHwH3ZWm7k6Eq37jQjss2bOjYElwqSKXYQKnlP5yunixxrEUMLY10Ke7Q0l1kyURWuXDzyaICwxmPYyISjJESqUgzaG0Ksnr2KrpwixJmIjnJuiy1cV7sfHbns3IobaqZBwzmr2KrpwixJm5B5xwkumr2KrpwixJmamJuiy1cV7sfHbns3Iobarppzpanr2BXcILmwwLSzjnN5SCDzzVLx1CoY10KiBW2CuyGLExLvvxrsNMTGkNU0bfAAVtCpobJZvHsLrSRsVuRG5Uctf3LHbiYzDXOqz60uyLbdYf3V0(Ka61gxHAPIDv6LAf0geyFcTIrVqol7TcqKZ6IjRuiyHHS5qFUEIgaYiHzDaPPdqWQfEXcHGUzVvaICwxmzPqXzzmP0DeH0droRlgXtc0bOjYElwqSKXYQKnlP5mNLRll7T8QMZrUMMezd2MJcdS07QSQ6kskBbvoDPdk00EN4ECcgNRcLkJEZayryvX9oQoIq61BgGiN1fdaabefktNMcRmawewvCVJQJiKsf7Q0l1kOniW(eAfJEHCw2BfGiN1ft2dqtK9wSGyjJLvjBwsZzolxxw2B5vnNJCnnjtKnz0JfY1idaKMukeSWq2COpxprdazKWSoG00biy1cVyHqq3S3karoRlMShGMi7TybXsglRs2SKMJrWeaRqFsa9Gf1fMeIlxttISbBZrHbw6DvwvDfjvgXUk9sTcM7kmvCxggGiN1fJcLPttHvgmixC)s7tcOxBCfQLk2vPxQvqBqG9j0kg9c5SS3karoRlMSuO4SmMu6oIq6HiN1fJyGM5a0ezVfliwYyzvYML0CmcMayf6tcOhSOUWKqC5AAsMiBYOhlKRrgainPuz0OLe8wP9AuyXdzlaURikuGwR9izSYGP1Sae5SUyetciIw2dWdq5jV757ksH3hRbJW8a0ezVfleHfcBbjnAjbVyBLCnnjhqA6aduRXYR3LlartKsNMSbBZrHb3DvDf5HGvl8UlvesHIlMHidgTXvyWeztgpanr2BXcryHWwmlP50OLe8ITvY10KGGvl8Ulveg0iDl6KyGKafk0DeH0droRlgXZiDAn6asthOrwIWUI8uxWshaDpanr2BXcryHWwmlP5SkUxxA5AAsIDv6LAfm3vyQ4UmmaroRlMuzstHvg0iDRWawMJc1uOiwYyzvgQoIq6PnKcfiyH0lmcdUeqdUCBHmzLkZ0KnyBokm4URQRipeSqgfk0DeH0droRlgXZi7bOjYElwicle2Izjnh1fS0EMlwAekxttsJoG00bAKLiSRip1fS0bwAcGbGeKonzd2MJcdU7Q6kYdblKDaAIS3IfIWcHTywsZrDblTN5ILgHY10K0OdinDGgzjc7kYtDblDa0vQyxLEPwbZDfMkUlddqKZ6I5Xj4IIe1aygPtt2GT5OWG7UQUI8qWczhGMi7TyHiSqylML0CA0scEX2k5AAsqWQfE3LkcdAKUfDs8KZt60KnyBokm4URQRipeSAH3DPIWdqtK9wSqewiSfZsAoAKLiSRiplHnWOCnnjn6asthOrwIWUI8uxWshyPjaMyGKonzd2MJcdU7Q6kYdblKDaAIS3IfIWcHTywsZrJSeHDf5zjSbgLRPjPrhqA6anYse2vKN6cw6alnbWet0sf7Q0l1kyURWuXDzyaICwxmpobxuKOM4zKonzd2MJcdU7Q6kYdblKDaAIS3IfIWcHTywsZPrlj4fBRKRPjnnzd2MJcdU7Q6kYdbRw4DxQi8a8auEY7EImSqylUNiTZh3p)H9c7m(bOjYElwicle2cVTijQwNE6f6f7Q0l1sUY4qsSfu5HO5Iq5AAsPPWkdSfu5HO5IqPPbJWmKnh6Z17ksVeMH4zKs3respe5SUyaygPIDv6LAfylOYdrZfHbiYzDXiwMiHw(EEHj2mYk1eztg9yHCnYiMKeoanr2BXcryHWw4TfNL0CA0scEX2k5AAsYmnzd2MJcdU7Q6kYdbRw4DxQiKcfhqA6aduRXYR3LlartKYkvghqA6G2Ga7tOvm6fYzzVva0vkeSq6fgHbnAAvJS0l2wj1eztg9yHCnYiMKeOqXeztg9yHCnYinPShGMi7TyHiSqyl82IZsAo0T1ixlKRPj5asthyGAnwE9UCbiAIKcLPjBW2CuyWDxvxrEiy1cV7sfHhGMi7TyHiSqyl82IZsAoQlyP9mxS0iuorCHc9PbJWKrci5AAsYi2vPxQvWCxHPI7YWae5SUyaygPA0bKMoqJSeHDf5PUGLoa6sHIgDaPPd0ilryxrEQlyPdS0eadajiRuzO7icPhICwxmIf7Q0l1kOrlj4Ts71OWIhGiN1fBwGMhfk0DeH0droRlgae7Q0l1kyURWuXDzyaICwxmzpanr2BXcryHWw4TfNL0C0ilryxrEwcBGr5eXfk0NgmctgjGKRPjPrhqA6anYse2vKN6cw6alnbWetscsf7Q0l1kyURWuXDzyaICwxmILafkA0bKMoqJSeHDf5PUGLoWstamXaDaAIS3IfIWcHTWBlolP5OrwIWUI8Se2aJYjIluOpnyeMmsajxttsSRsVuRG5Uctf3LHbiYzDXaWms1OdinDGgzjc7kYtDblDGLMayIb6a8auEY7(yHDbmMSdqtK9wSqc7cymzKazOVtKtUY4qsDXeqW0CuONiaTkb58AKClq5AAsYi2vPxQvaSiSQ4EhvhridqKZ6IrHIyxLEPwbTbb2NqRy0lKZYERae5SUyYkvgxmdgKlUpIWcQcMiBYifkUygm3v4JiSGQGjYMmkD60uyLbdYf3V0(Ka61gxHAkusdgHziBo0NR3vK(jNhXZilfkolJjLUJiKEiYzDXiEsGoanr2BXcjSlGXKnlP5azOVtKtUY4qsCMWCGONraX0ZbYAHCnnjXUk9sTcM7kmvCxggGiN1fJ4zKkZ0ira2UUOo0ftabtZrHEIa0QeKZRrYTaPqrSRsVuRqxmbemnhf6jcqRsqoVgj3cmaroRlMSuO4SmMu6oIq6HiN1fJ4jb6a0ezVflKWUagt2SKMdKH(oro5kJdjPHOPPBi6jJmgQKRPjj2vPxQvWCxHPI7YWae5SUysLzAKiaBxxuh6IjGGP5OqpraAvcY51i5wGuOi2vPxQvOlMacMMJc9ebOvjiNxJKBbgGiN1ftwkuCwgtkDhri9qKZ6IrSeoanr2BXcjSlGXKnlP5azOVtKtUY4qsAdcm3ULxJcG9KxOj6mUCnnjXUk9sTcM7kmvCxggGiN1ftQmtJeby76I6qxmbemnhf6jcqRsqoVgj3cKcfXUk9sTcDXeqW0CuONiaTkb58AKClWae5SUyYsHIZYysP7icPhICwxmINeOdqtK9wSqc7cymzZsAoqg67e5yY10KKrSRsVuRG5Uctf3LHbiYzDXOqXbKMoOniW(eAfJEHCw2BfaDLvQmtJeby76I6qxmbemnhf6jcqRsqoVgj3cKcfXUk9sTcDXeqW0CuONiaTkb58AKClWae5SUyYo4nWKWch88nhOYYElIcA05ih5ya]] )

end
