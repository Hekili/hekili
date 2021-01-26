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


    spec:RegisterPack( "Unholy", 20210125, [[d0uoQbqifrpsrjBsH8jsHrrk6uKswfPkkVsrvZIuQDj0VuummfL6yQIwgPspJuLMMQqDnfP2MIe9neIyCQcHoNIe06ueAEiu3dr2NIkhuviTqvbpeHuteHOUicrYhriHrIqKQtQkeTsvjVuviOzsQc3eHiLDsQ4NKQinufjWsvKqpfftLuvxLufvBvviWxrirJvrs7LQ(lvgmuhMYIf0JjmzIUmyZi1NvWOrWPLA1iK0RvLA2KCBuA3s(TsdxGJJqy5qEoQMUORRQ2os8DK04veCEfQ1tQIy(iQ9RY(NE99mslbVo6oBDFo7N6oDu3NZw3hpf6zYXbGNjWeVTbWZugl4z0ZlcRASNjWgRwt613ZW3psaEgczgWN4mZm0jHFyuSSZWB2VYYElbYOZz4nRygpt4Vv5JS8HEgPLGxhDNTUpN9tDNoQ7ZzR7JFe9m8aq41r3P11ZqOLsO8HEgjWfEMznRdtKbljC4hHvpqipSEEryvJVxZAwh(LvFdn(W6oT2hw3zR7Z719AwZ6WpQKO(5jluj)W5EyICrKNHid0TcMHidwsGFyI8hoCUhEl14dl2FLhon0aK8dtLWEydbhgMqaisqE4CpSQPahwT1WHHA)deoCUhM1YeqhwtBbhhYFWHN1tTIEgvZtUxFpJTGJd5pWRVxNNE99mqzHkq6FWZiqDcO28msWscU3vpqiJ0u3FjbPln0aK8dphPdlgluGdkGTb(Hjt(WiRLoGcuz0KsEeMqZt(HhDyK1shqbQmAsjpIawRl(HjM0HF(0ZyIS3YZy1yNSK(0RJUE99mqzHkq6FWZiqDcO28msWscU3vpqiJ0u3FjbPln0aK8dphPdpTNXezVLNXQXozj9Pxh9613ZaLfQaP)bpJa1jGAZZm5HPyO2cvqmyxvxdo0VAHlyPcOdp6WAE4WpnDuAO3UezfNErSw2Bf)bhE0Hr)cOx0aeLGjvnWtNyBveklubYdp6WMiBkGdkGTb(HjM0H17Hjt(WMiBkGdkGTb(HjDyDpSwEgtK9wEgjyjbNyBLp968yV(EgOSqfi9p4zeOobuBEMjpmfd1wOcIb7Q6AWH(vlCblva5zmr2B5zGGwcSTWNEDM2RVNbklubs)dEgtK9wEgAGNaQRbhpr9BWZiqDcO28msi8tthPbEcOUgCu3FjJ80eVpmXKoSEp8Odl2vjxQv0cwHPghWHicyTU4hM4dRxpJySqbU0qdqY9680NEDMsV(EgOSqfi9p4zmr2B5zObEcOUgC8e1VbpJa1jGAZZiHWpnDKg4jG6AWrD)LmYtt8(WeF4NEgXyHcCPHgGK715Pp96qK413ZaLfQaP)bpJjYElpdnWta11GJNO(n4zeOobuBEg0VGy2SGlx3JpmXhwZdl2vjxQvucwsWzL0jbHnoIawRl(HhD4jpCAkOYOeOBfeHYcvG8WKjFyXUk5sTIsGUvqebSwx8dp6WPPGkJsGUvqeklubYdRLNrmwOaxAObi5EDE6tF6zSfCHFep96715PxFpduwOcK(h8mcuNaQnpJMho8tth5FPekNCx2icmrEyYKp8KhMIHAlubXGDvDn4q)QfUGLkGoSwhE0H18WHFA6O0qVDjYko9IyTS3k(do8OdJ(fqVObikbtQAGNoX2QiuwOcKhE0Hnr2uahuaBd8dtmPdR3dtM8Hnr2uahuaBd8dt6W6EyT8mMi7T8msWscoX2kF61rxV(EgOSqfi9p4zeOobuBEg0VAHlyPcOOeOBrNhM4dR5HFo7dp)HLGLeCVREGqgPPU)scsxAObi5hwp7W69WAD4rhwcwsW9U6bczKM6(ljiDPHgGKFyIp8uE4rhEYdtXqTfQGyWUQUgCOF1cxWsfqhMm5dh(PPJCQgITRbhBZZ4pWZyIS3YZabTeyBHp96OxV(EgOSqfi9p4zeOobuBEg0VAHlyPcOOeOBrNhM4dR70hE0HLGLeCVREGqgPPU)scsxAObi5hEUdp9HhD4jpmfd1wOcIb7Q6AWH(vlCblva5zmr2B5zGGwcSTWNEDESxFpduwOcK(h8mcuNaQnpZKhwcwsW9U6bczKM6(ljiDPHgGKF4rhEYdtXqTfQGyWUQUgCOF1cxWsfqhMm5dt3deshcyTU4hM4dp9Hjt(WiRLoGcuz0KsEeMqZt(HhDyK1shqbQmAsjpIawRl(Hj(Wt7zmr2B5zGGwcSTWNEDM2RVNXezVLNH6(lPJhaLeqEgOSqfi9p4tVotPxFpduwOcK(h8mcuNaQnpZKhMIHAlubXGDvDn4q)QfUGLkG8mMi7T8mqqlb2w4tF6zgGcqTWRVxNNE99mqzHkq6FWZiqDcO28mHFA6i)lLq5K7YgrGjYdp6WtEykgQTqfed2v11Gd9Rw4cwQa6WKjF4aiJdgAyhRGOjYMc4zmr2B5zKGLeCITv(0RJUE99mqzHkq6FWZiqDcO28mOF1cxWsfqrjq3IopmXh(PEpmzYhMUhiKoeWADXpmXhE6dp6WtEyje(PPJ0apbuxdoQ7VKXFGNXezVLNrcwsWj2w5tVo61RVNbklubs)dEgbQta1MNrSRsUuROfSctnoGdreWADXp8OdR5HttbvgLaDRGiuwOcKhMm5dlwkqzvgREGq6On4WKjFy0Va6fnaXacGHw2TaEeklubYdR1HhDynp8KhMIHAlubXGDvDn4q)c4hMm5dt3deshcyTU4hM4dp9H1YZyIS3YZy1yNSK(0RZJ967zGYcvG0)GNrG6eqT5zKq4NMosd8eqDn4OU)sg5PjEF45o8Jp8Odp5HPyO2cvqmyxvxdo0VaUNXezVLNH6(lPJhaLeq(0RZ0E99mqzHkq6FWZiqDcO28msi8tthPbEcOUgCu3FjJ)Gdp6WIDvYLAfTGvyQXbCiIawRlUdMqaisqE45o80hE0HN8WumuBHkigSRQRbh6xa3ZyIS3YZqD)L0XdGsciF61zk967zGYcvG0)GNrG6eqT5zq)QfUGLkGIsGUfDEyIpSUZ(WJo8KhMIHAlubXGDvDn4q)QfUGLkG8mMi7T8msWscoX2kF61HiXRVNbklubs)dEgbQta1MNrcHFA6inWta11GJ6(lzKNM49Hj(Wpp8Odp5HPyO2cvqmyxvxdo0VaUNXezVLNHg4jG6AWXtu)g8PxNhrV(EgOSqfi9p4zeOobuBEgje(PPJ0apbuxdoQ7VKrEAI3hM4d)4dp6WIDvYLAfTGvyQXbCiIawRlUdMqaisqEyIp80hE0HN8WumuBHkigSRQRbh6xa3ZyIS3YZqd8eqDn44jQFd(0RZuOxFpduwOcK(h8mcuNaQnpZKhMIHAlubXGDvDn4q)QfUGLkG8mMi7T8msWscoX2kF6tpJyPaLvj3RVxNNE99mqzHkq6FWZiqDcO28mumuBHkiYtxGYQQRHdp6WOF1cxWsfqrjq3Iop8Ch(5uE4rhwZdl2vjxQv0cwHPghWHicyTU4hMm5dp5Httbvgne7y3s7scGtASfiJqzHkqE4rhwSRsUuRO0qVDjYko9IyTS3kIawRl(H16WKjFy6EGq6qaR1f)WeF4Np9mMi7T8mCQgITRbhBZtF61rxV(EgOSqfi9p4zmr2B5z4uneBxdo2MNEgjWfOoi7T8mmqE4Cp8Ndh2OtaDylyfhU5hERdt0e5dB8dN7HdqafOYdVuaKWcc6A4WtXPGdtLqRGdZHm7A4W)Gdt0ezn4EgbQta1MNrSRsUuROfSctnoGdreWADXp8OdR5Hnr2uahuaBd8dphPdR7HhDytKnfWbfW2a)Wet6WtF4rhg9Rw4cwQakkb6w05HN7WpN9HN)WAEytKnfWbfW2a)W6zhEkpSwhMm5dBISPaoOa2g4hEUdp9HhDy0VAHlyPcOOeOBrNhEUd)4zFyT8Pxh9613ZaLfQaP)bpJa1jGAZZqXqTfQGipDbkRQUgo8Odp5H57xf2LmQat6ch7GjySbkicLfQa5HhDynpSyxLCPwrlyfMACahIiG16IFyYKp8Khonfuz0qSJDlTljaoPXwGmcLfQa5HhDyXUk5sTIsd92LiR40lI1YERicyTU4hwRdp6WOFbXSzbxUUhF45oSMhwVhE(dh(PPJOF1cNyrOFq2BfraR1f)WADyYKpmDpqiDiG16IFyIpSUp9mMi7T8mw4Y2LL9wovZg6tVop2RVNbklubs)dEgbQta1MNHIHAlubrE6cuwvDnC4rhMVFvyxYOcmPlCSdMGXgOGiuwOcKhE0H18WYnJ)IWQg7cv9aH0j3mIawRl(HN7WpFEyYKp8Khonfuz8xew1yxOQhiKrOSqfip8Odl2vjxQvuAO3UezfNErSw2BfraR1f)WA5zmr2B5zSWLTll7TCQMn0NEDM2RVNbklubs)dEgbQta1MNXeztbCqbSnWp8CKoSUhE0Hr)cIzZcUCDp(WZDynpSEp88ho8tthr)QfoXIq)GS3kIawRl(H1YZyIS3YZyHlBxw2B5unBOp96mLE99mqzHkq6FWZiqDcO28mumuBHkiYtxGYQQRHdp6WAEyXUk5sTIwWkm14aoeraR1f)WKjF4jpCAkOYOHyh7wAxsaCsJTazeklubYdp6WIDvYLAfLg6TlrwXPxeRL9wreWADXpSwhMm5dt3deshcyTU4hM4d)CApJjYElpdNGjERaxsaC)I6IscJ9PxhIeV(EgOSqfi9p4zeOobuBEgtKnfWbfW2a)WZr6W6E4rhwZdlblj4Ss6KGWghZw8URHdtM8HrwlDafOYOjL8icyTU4hMysh(5JpSwEgtK9wEgobt8wbUKa4(f1fLeg7tF6zcqGyzdT0RVxNNE99mMi7T8mbB2B5zGYcvG0)Gp96ORxFpduwOcK(h8mLXcEgtpHtWqg3rVv6wAxWsfqEgtK9wEgtpHtWqg3rVv6wAxWsfq(0RJE967zmr2B5zqwZbNemPNbklubs)d(0NEgXUk5sT4E99680RVNbklubs)dEgbQta1MNHIHAlubrwJOUiNyxLCPwCNjYMcCyYKpmDpqiDiG16IFyIpSUtPNXezVLNjyZElF61rxV(EgOSqfi9p4zeOobuBEgXUk5sTI)IWQg7cv9aHmIawRl(Hj(WtF4rhwSRsUuRO0qVDjYko9IyTS3kIawRlUdMqaisqEyIp80hE0Httbvg)fHvn2fQ6bczeklubYdtM8HN8WPPGkJ)IWQg7cv9aHmcLfQa5Hjt(W09aH0HawRl(Hj(W6DApJjYElpJHyh7wAxsaCsWK(0RJE967zGYcvG0)GNrG6eqT5zsdnazmBwWLRlqKo9o9Hj(WtF4rhon0aKXSzbxUozdhEUdpTNXezVLNHVFLdbwaG8PxNh713ZaLfQaP)bpJjYElpZViSQXUqvpqi9msGlqDq2B5zisFvs(HFq1deYdtVOd)doCUhE6dZbXws(HZ9W8XL4Wu7KWHF0GvyQXbCq7dRNMeae1MdAF4phom1ojCyISHEFy9rwXPxeRL9wrpJa1jGAZZqXqTfQGipDbkRQUgo8OdR5Hf7QKl1kAbRWuJd4qebSwxChmHaqKG8WeF4PpmzYhwSRsUuROfSctnoGdreWADXDWecarcYdp3HFo7dR1HhDynpSyxLCPwrPHE7sKvC6fXAzVvebSwx8dt8HheYdtM8Hd)00rPHE7sKvC6fXAzVv8hCyT8PxNP967zGYcvG0)GNrG6eqT5zmr2uahuaBd8dphPdR7Hjt(W09aH0HawRl(Hj(W6(0ZyIS3YZ8lcRASlu1desF61zk967zGYcvG0)GNrG6eqT5zOyO2cvqKNUaLvvxdhE0H18WYnJ)IWQg7cv9aH0j3mIawRl(Hjt(WtE40uqLXFryvJDHQEGqgHYcvG8WA5zmr2B5zKg6TlrwXPxeRL9w(0RdrIxFpduwOcK(h8mcuNaQnpJjYMc4GcyBGF45iDyDpmzYhMUhiKoeWADXpmXhw3NEgtK9wEgPHE7sKvC6fXAzVLp968i613ZaLfQaP)bpJa1jGAZZyISPaoOa2g4hM0HFE4rhwcHFA6inWta11GJ6(lzKNM49HNJ0HFSNXezVLNXcwHPghWbF61zk0RVNbklubs)dEgtK9wEglyfMACah8mcuNaQnpJjYMc4GcyBGF45iDyDp8OdlHWpnDKg4jG6AWrD)LmYtt8(WZr6Wp(WJo8KhwcwsWzL0jbHnoMT4DxdEgXyHcCPHgGK715Pp968C2E99mqzHkq6FWZiqDcO28mOF1cxWsfqrjq3IopmXh(5Jp8OdR5Hf7QKl1k(lcRASlu1deYicyTU4hM4d)C2hMm5dl3m(lcRASlu1desNCZicyTU4hwlpJjYElpd)ZYULBWqd7yf4tVopF613ZaLfQaP)bpJa1jGAZZqXqTfQGipDbkRQUgo8OdlHWpnDKg4jG6AWrD)LmYtt8(WeFyDp8OdR5HdGmAbRWnqy)QOjYMcCyYKpC4NMokn0BxISItViwl7TI)Gdp6WtE4aiJgIDSBGW(vrtKnf4WA5zmr2B5z(fHvn2zCU9vPp968uxV(EgOSqfi9p4zmr2B5z(fHvn2zCU9vPNrG6eqT5zmr2uahuaBd8dphPdR7HhDyje(PPJ0apbuxdoQ7VKrEAI3hM4dRRNrmwOaxAObi5EDE6tVop1RxFpduwOcK(h8mcuNaQnpZKhoaY4aH9RIMiBkGNXezVLNbznhCsWK(0RZZh713ZaLfQaP)bpJa1jGAZZyISPaoOa2g4hEoshw3dp6WtE4WpnDuAO3UezfNErSw2Bf)bhE0HN8WIDvYLAfLg6TlrwXPxeRL9wreyYXhMm5dt3deshcyTU4hM4dpiKEgtK9wEgUjqnDlAt5cmr6tF6zgGcqTWzl413RZtV(EgOSqfi9p4zmr2B5zOAD6OxKtSRsUulpJa1jGAZZKMcQmY3VYHalaqrOSqfip8OdNgAaYy2SGlxxGiD6D6dt8HN(WJomDpqiDiG16IF45o80hE0Hf7QKl1kY3VYHalaqreWADXpmXhwZdpiKhwp7WZosKm9H16WJoSjYMc4GcyBGFyIjDy96zkJf8m89RCiWcaKp96ORxFpduwOcK(h8mcuNaQnpJMhEYdtXqTfQGyWUQUgCOF1cxWsfqhMm5dh(PPJ8VucLtUlBebMipSwhE0H18WHFA6O0qVDjYko9IyTS3k(do8OdJ(fqVObikbtQAGNoX2QiuwOcKhE0Hnr2uahuaBd8dtmPdR3dtM8Hnr2uahuaBd8dt6W6EyT8mMi7T8msWscoX2kF61rVE99mqzHkq6FWZiqDcO28mHFA6i)lLq5K7YgrGjYdtM8HN8WumuBHkigSRQRbh6xTWfSubKNXezVLNbcAjW2cF615XE99mqzHkq6FWZyIS3YZqD)L0XdGscipJa1jGAZZO5Hf7QKl1kAbRWuJd4qebSwx8dp3HN(WJoSec)00rAGNaQRbh19xY4p4WKjFyje(PPJ0apbuxdoQ7VKrEAI3hEUd)4dR1HhDynpmDpqiDiG16IFyIpSyxLCPwrjyjbNvsNee24icyTU4hE(d)C2hMm5dt3deshcyTU4hEUdl2vjxQv0cwHPghWHicyTU4hwlpJySqbU0qdqY9680NEDM2RVNbklubs)dEgtK9wEgAGNaQRbhpr9BWZiqDcO28msi8tthPbEcOUgCu3FjJ80eVpmXKoSEp8Odl2vjxQv0cwHPghWHicyTU4hM4dR3dtM8HLq4NMosd8eqDn4OU)sg5PjEFyIp8tpJySqbU0qdqY9680NEDMsV(EgOSqfi9p4zmr2B5zObEcOUgC8e1VbpJa1jGAZZi2vjxQv0cwHPghWHicyTU4hEUdp9HhDyje(PPJ0apbuxdoQ7VKrEAI3hM4d)0ZigluGln0aKCVop9Pp9msG2(Q0RVxNNE99mMi7T8mSDjD0ia0tapduwOcK(h8PxhD967zGYcvG0)GNzd8mCi9mMi7T8mumuBHkWZqXuFWZi2vjxQvK)zz3YnyOHDScIiG16IFyIp80hE0Httbvg5Fw2TCdgAyhRGiuwOcKEgkgYvgl4zc2v11Gd9Rw4cwQaYNED0RxFpduwOcK(h8mBGNHdPNXezVLNHIHAlubEgkM6dEM0uqLr((voeybakcLfQa5HhDy0VGdt8H19WJoCAObiJzZcUCDbI0P3PpmXhE6dp6W09aH0HawRl(HN7Wt7zOyixzSGNjyxvxdo0VaUp968yV(EgOSqfi9p4z2apdhspJjYElpdfd1wOc8mum1h8mMiBkGdkGTb(HjD4NhE0H18WtEyK1shqbQmAsjpctO5j)WKjFyK1shqbQmAsjp21HN7WpN(WA5zOyixzSGNHNUaLvvxd(0RZ0E99mqzHkq6FWZSbEgoKEgtK9wEgkgQTqf4zOyQp4zcGmoyOHDScIMiBkWHjt(WHFA64ViSQXoJZTVkJ)GdtM8Httbvgne7y3s7scGtASfiJqzHkqE4rhoaYOfSc3aH9RIMiBkWHjt(WHFA6O0qVDjYko9IyTS3k(d8mumKRmwWZWAe1f5e7QKl1I7mr2uaF61zk967zGYcvG0)GNrG6eqT5zq)QfUGLkGIsGUfDE45o8uo9HhDynpCaKXbdnSJvq0eztbomzYhEYdNMcQmY)SSB5gm0WowbrOSqfipSwhE0Hr)cIsGUfDE45iD4P9mMi7T8mgsyf4YfHGk9PxhIeV(EgOSqfi9p4zeOobuBEgkgQTqfeznI6ICIDvYLAXDMiBkWHjt(WPHgGmMnl4Y1jB4Wet6WHFA6yOAxPJ(JghLFKL9wEgtK9wEMq1Ush9hn2NEDEe967zGYcvG0)GNrG6eqT5zOyO2cvqK1iQlYj2vjxQf3zISPahMm5dNgAaYy2SGlxNSHdtmPdh(PPJHaIdO3DneLFKL9wEgtK9wEMqaXb07Ug8PxNPqV(EgOSqfi9p4zeOobuBEMWpnD8xew1yhprqnKeI)apJjYElpJQhiKChr9lhyHk9PxNNZ2RVNbklubs)dEgtK9wEgReaprMYjmLYZibUa1bzVLN5rlbWtKPomrBk1HfwD4e1dda6Wp(WbBcv2M6WHFAAU2hgmbHdRmE21WHFo9H5GyljpEy98SvTEcipmbdjpSyLG8WzZch24h2oCI6HbaD4Cp8BacoCNhgbM0cvq0ZiqDcO28mumuBHkiYAe1f5e7QKl1I7mr2uGdtM8HtdnazmBwWLRt2WHjM0HFoTp9688PxFpduwOcK(h8mcuNaQnpJjYMc4GcyBGF45iDyDpmzYhwZdJ(feLaDl68WZr6WtF4rhg9Rw4cwQakkb6w05HNJ0HNYzFyT8mMi7T8mgsyf4c(ko4tVop11RVNbklubs)dEgbQta1MNHIHAlubrwJOUiNyxLCPwCNjYMcCyYKpCAObiJzZcUCDYgomXKoC4NMos3iiuTRmk)il7T8mMi7T8m0nccv7k9PxNN61RVNbklubs)dEgbQta1MNj8tth)fHvn2XteudjH4p4WJoSjYMc4GcyBGFysh(PNXezVLNj0gClTlrT4n3NEDE(yV(EgOSqfi9p4zmr2B5z2FgIa7TNrcCbQdYElpdrAwxP1vxdh(rqJ(kOYdpfOSHpC4MFy7WbOErDo2ZiqDcO28mYnJuA0xbv6cu2WhIiGgbCcwOco8Odp5Httbvg)fHvn2fQ6bczeklubYdp6WtEyK1shqbQmAsjpctO5j3NEDEoTxFpduwOcK(h8mcuNaQnpJCZiLg9vqLUaLn8HicOraNGfQGdp6WMiBkGdkGTb(HNJ0H19WJoSMhEYdNMcQm(lcRASlu1deYiuwOcKhMm5dNMcQm(lcRASlu1deYiuwOcKhE0Hf7QKl1k(lcRASlu1deYicyTU4hwlpJjYElpZ(ZqeyV9PxNNtPxFpduwOcK(h8mcuNaQnpd6xa9IgGi)haiEISUIqzHkqE4rhwZdl3msJwE6ObkakIaAeWjyHk4WKjFy5MXq1UsxGYg(qeb0iGtWcvWH1YZyIS3YZS)meb2BF615jrIxFpduwOcK(h8msGlqDq2B5zEur2BDy9O5j)WwjpSEAauaIFyn1tdGcq8zyaI4dLa4h(x8FqWIsqE4UoSjLBf1YZyIS3YZimLYzIS3YPAE6zunpDLXcEMe11Bi5(0RZZhrV(EgOSqfi9p4zmr2B5zeMs5mr2B5unp9mQMNUYybpJyPaLvj3NEDEof613ZaLfQaP)bpJe4cuhK9wEgtK9w8OeOTVkNN0mCGi(qjaTBAsMiBkGdkGTboPNJMucwsW9U6bczu2CluboBtP2LXcK2aOa0ene7y3s7scGtcMCI0apbuxdoEI63WePbEcOUgC8e1VHj(lcRASlu1deYjgSzV1eLg6TlrwXPxeRL9wt0cwHPghWbpJjYElpJWukNjYElNQ5PNr180vgl4ze7QKl1I7tVo6oBV(EgOSqfi9p4zeOobuBEgtKnfWbfW2a)WZr6W6E4rhwZdl2vjxQvucwsWzL0jbHnoIawRl(Hj(WpN9HhD4jpCAkOYOeOBfeHYcvG8WKjFyXUk5sTIsGUvqebSwx8dt8HFo7dp6WPPGkJsGUvqeklubYdR1HhD4jpSeSKGZkPtccBCmBX7Ug8mMi7T8mOF5mr2B5unp9mQMNUYybpJTGJd5pWNED09PxFpduwOcK(h8mcuNaQnpJjYMc4GcyBGF45iDyDp8Odlblj4Ss6KGWghZw8URbpJjYElpd6xotK9wovZtpJQ5PRmwWZyl4c)iE6tVo6QRxFpduwOcK(h8mcuNaQnpJjYMc4GcyBGF45iDyDp8OdR5HN8WsWscoRKojiSXXSfV7A4WJoSMhwSRsUuROeSKGZkPtccBCebSwx8dp3HFo7dp6WtE40uqLrjq3kicLfQa5Hjt(WIDvYLAfLaDRGicyTU4hEUd)C2hE0HttbvgLaDRGiuwOcKhwRdRLNXezVLNb9lNjYElNQ5PNr180vgl4zgGcqTWzl4tVo6QxV(EgOSqfi9p4zeOobuBEgtKnfWbfW2a)WKo8tpJjYElpJWukNjYElNQ5PNr180vgl4zgGcqTWN(0ZKOUEdj3RVxNNE99mqzHkq6FWZyIS3YZ0fxG(PfQahr8Tk)SojqPfGNrG6eqT5z08WIDvYLAf)fHvn2fQ6bczebSwx8dtM8Hf7QKl1kkn0BxISItViwl7TIiG16IFyTo8OdR5HdGmAi2XUbc7xfnr2uGdtM8HdGmAbRWnqy)QOjYMcC4rhEYdNMcQmAi2XUL2LeaN0ylqgHYcvG8WKjF40qdqgZMfC56cePt3zFyIp80hwRdtM8HP7bcPdbSwx8dt8H19PNPmwWZ0fxG(PfQahr8Tk)SojqPfGp96ORxFpduwOcK(h8mMi7T8mSMWcrGJtaG0X(5TWZiqDcO28mIDvYLAfTGvyQXbCiIawRl(Hj(WtF4rhwZdp5HbI43bbGm2fxG(PfQahr8Tk)SojqPfWHjt(WIDvYLAf7Ilq)0cvGJi(wLFwNeO0ciIawRl(H16WKjFy6EGq6qaR1f)WeFyDF6zkJf8mSMWcrGJtaG0X(5TWNED0RxFpduwOcK(h8mMi7T8mseys6gbokaNdkpJa1jGAZZi2vjxQv0cwHPghWHicyTU4hE0H18WtEyGi(DqaiJDXfOFAHkWreFRYpRtcuAbCyYKpSyxLCPwXU4c0pTqf4iIVv5N1jbkTaIiG16IFyTomzYhMUhiKoeWADXpmXhwVEMYybpJebMKUrGJcW5GYNEDESxFpduwOcK(h8mMi7T8msd9MD3YjbXBhLfzIoh7zeOobuBEgXUk5sTIwWkm14aoeraR1f)WJoSMhEYddeXVdcazSlUa9tluboI4Bv(zDsGslGdtM8Hf7QKl1k2fxG(PfQahr8Tk)SojqPfqebSwx8dR1Hjt(W09aH0HawRl(Hj(W6(0Zugl4zKg6n7ULtcI3oklYeDo2NEDM2RVNbklubs)dEgbQta1MNrZdl2vjxQv0cwHPghWHicyTU4hMm5dh(PPJsd92LiR40lI1YER4p4WAD4rhwZdp5HbI43bbGm2fxG(PfQahr8Tk)SojqPfWHjt(WIDvYLAf7Ilq)0cvGJi(wLFwNeO0ciIawRl(H1YZyIS3YZ85GRtGL7tF6tpdfaX7T86O7S195SF(KiXZq1qvxdCpdr5Jof15rQdrXep8H1NaC4Mnyr5HPx0H1WwWXH8hOXHrar8BeipmFzHdB)CzTeKhwqWQbGhVx6rxWH17epmrVffaLG8WAG(fqVObiovnoCUhwd0Va6fnaXPgHYcvGuJdR5ZjOv8EPhDbhMizIhMO3IcGsqEynstbvgNQgho3dRrAkOY4uJqzHkqQXH1u3jOv8EDVikF0POopsDikM4HpS(eGd3Sblkpm9IoSg2cUWpINACyeqe)gbYdZxw4W2pxwlb5HfeSAa4X7LE0fC4Nt8We9wuaucYdRb6xa9IgG4u14W5Eynq)cOx0aeNAeklubsnoSMpNGwX719IO8rNI68i1HOyIh(W6taoCZgSO8W0l6WAmafGAHghgbeXVrG8W8LfoS9ZL1sqEybbRgaE8EPhDbhwVt8We9wuaucYdRb6xa9IgG4u14W5Eynq)cOx0aeNAeklubsnoSMpNGwX719IO8rNI68i1HOyIh(W6taoCZgSO8W0l6WAiwkqzvY14WiGi(ncKhMVSWHTFUSwcYdliy1aWJ3l9Ol4WpN4Hj6TOaOeKhwJ0uqLXPQXHZ9WAKMcQmo1iuwOcKACynFobTI3l9Ol4W6DIhMO3IcGsqEynstbvgNQgho3dRrAkOY4uJqzHkqQXH185e0kEV0JUGdR3jEyIElkakb5H1GVFvyxY4u14W5Eyn47xf2Lmo1iuwOcKACynFobTI3l9Ol4WpEIhMO3IcGsqEynstbvgNQgho3dRrAkOY4uJqzHkqQXH185e0kEV0JUGd)4jEyIElkakb5H1GVFvyxY4u14W5Eyn47xf2Lmo1iuwOcKACynFobTI3l9Ol4Wt5epmrVffaLG8WAKMcQmovnoCUhwJ0uqLXPgHYcvGuJdR5ZjOv8EDVikF0POopsDikM4HpS(eGd3Sblkpm9IoSgIDvYLAX14WiGi(ncKhMVSWHTFUSwcYdliy1aWJ3l9Ol4W6oXdt0BrbqjipSgPPGkJtvJdN7H1infuzCQrOSqfi14WAQ7e0kEV0JUGdpLt8We9wuaucYdRrAkOY4u14W5EynstbvgNAeklubsnoSMpNGwX719IO8rNI68i1HOyIh(W6taoCZgSO8W0l6WAmafGAHZwqJdJaI43iqEy(Ych2(5YAjipSGGvdapEV0JUGd)CIhwpV4)GGfLG8WMi7ToSguToD0lYj2vjxQLgX7LE0fC4Nt8We9wuaucYdRrAkOY4u14W5EynstbvgNAeklubsnoSMpNGwX7LE0fCyDN4Hj6TOaOeKhwd0Va6fnaXPQXHZ9WAG(fqVObio1iuwOcKACynFobTI3R7fr5Jof15rQdrXep8H1NaC4Mnyr5HPx0H1irD9gsUghgbeXVrG8W8LfoS9ZL1sqEybbRgaE8EPhDbh(5epmrVffaLG8WAKMcQmovnoCUhwJ0uqLXPgHYcvGuJdR5ZjOv8EDVikF0POopsDikM4HpS(eGd3Sblkpm9IoSgsG2(QuJdJaI43iqEy(Ych2(5YAjipSGGvdapEV0JUGdR7epmrVffaLG8WAKMcQmovnoCUhwJ0uqLXPgHYcvGuJdB5HjsPNQhhwZNtqR49sp6coSEN4Hj6TOaOeKhwJ0uqLXPQXHZ9WAKMcQmo1iuwOcKACynFobTI3l9Ol4WtpXdt0BrbqjipSgPPGkJtvJdN7H1infuzCQrOSqfi14WA(CcAfVx6rxWHF(4jEyIElkakb5H1infuzCQAC4CpSgPPGkJtncLfQaPghwZNtqR49sp6co8ZPN4Hj6TOaOeKhwJ0uqLXPQXHZ9WAKMcQmo1iuwOcKACyn1DcAfVx6rxWHFoLt8We9wuaucYdRb6xa9IgG4u14W5Eynq)cOx0aeNAeklubsnoSMpNGwX7LE0fCyDN9epmrVffaLG8WAKMcQmovnoCUhwJ0uqLXPgHYcvGuJdRPUtqR49sp6coSU6oXdt0BrbqjipSgPPGkJtvJdN7H1infuzCQrOSqfi14WAQ7e0kEVUxps2GfLG8WtHh2ezV1Hvnp5X7LNX(jHf5zyA2VYYElIgz0PNjaT0Tc8mZAwhMidws4WpcREGqEy98IWQgFVM1So8lR(gA8H1DATpSUZw3N3R71SM1HFujr9ZtwOs(HZ9We5IipdrgOBfmdrgSKa)We5pC4Cp8wQXhwS)kpCAObi5hMkH9WgcommHaqKG8W5EyvtboSARHdd1(hiC4CpmRLjGoSM2cooK)GdpRNAfVx3ltK9w8yacelBOLZtAMGn7TUxMi7T4Xaeiw2qlNN0mFo46ey1UmwGKPNWjyiJ7O3kDlTlyPcO7LjYElEmabILn0Y5jndYAo4KGjVx3RznRdtKAcG4NG8Wafan(WzZchojah2e5IoCZpSrXALfQG49YezVfNeBxshnca9e4EnRzD4hbgQTqfWVxMi7T4ZtAgkgQTqfODzSaPGDvDn4q)QfUGLkG0MIP(ajXUk5sTI8pl7wUbdnSJvqebSwxCINEuAkOYi)ZYULBWqd7yfCVmr2BXNN0mumuBHkq7Yybsb7Q6AWH(fW1MIP(aP0uqLr((voeybaAe6xaX6okn0aKXSzbxUUar6070ep9i6EGq6qaR1fFUPVxMi7T4ZtAgkgQTqfODzSajE6cuwvDnOnft9bsMiBkGdkGTboPNJ0CsK1shqbQmAsjpctO5jNmzK1shqbQmAsjp21CpNwR7LjYEl(8KMHIHAlubAxglqI1iQlYj2vjxQf3zISPaAtXuFGuaKXbdnSJvq0eztbito8tth)fHvn2zCU9vz8hqMCAkOYOHyh7wAxsaCsJTa5OaiJwWkCde2VkAISPaKjh(PPJsd92LiR40lI1YER4p4EnRzD4POjAtXVxMi7T4ZtAgdjScC5IqqLA30Kq)QfUGLkGIsGUfDo3uo9indGmoyOHDScIMiBkazYtMMcQmY)SSB5gm0WowbrOSqfi1Ae6xquc0TOZ5in99YezVfFEsZeQ2v6O)OXA30KOyO2cvqK1iQlYj2vjxQf3zISPaKjNgAaYy2SGlxNSbIjf(PPJHQDLo6pACu(rw2BDVmr2BXNN0mHaIdO3DnODttIIHAlubrwJOUiNyxLCPwCNjYMcqMCAObiJzZcUCDYgiMu4NMogcioGE31qu(rw2BDVmr2BXNN0mQEGqYDe1VCGfQu7MMu4NMo(lcRASJNiOgscXFW9Awh(rlbWtKPomrBk1HfwD4e1dda6Wp(WbBcv2M6WHFAAU2hgmbHdRmE21WHFo9H5GyljpEy98SvTEcipmbdjpSyLG8WzZch24h2oCI6HbaD4Cp8BacoCNhgbM0cvq8EzIS3IppPzSsa8ezkNWukTBAsumuBHkiYAe1f5e7QKl1I7mr2uaYKtdnazmBwWLRt2aXKEo99YezVfFEsZyiHvGl4R4G2nnjtKnfWbfW2aFos6sMSMOFbrjq3IoNJ00Jq)QfUGLkGIsGUfDohPPC2ADVmr2BXNN0m0nccv7k1UPjrXqTfQGiRruxKtSRsUulUZeztbiton0aKXSzbxUozdetk8tthPBeeQ2vgLFKL9w3ltK9w85jntOn4wAxIAXBU2nnPWpnD8xew1yhprqnKeI)GrMiBkGdkGTboPN3RzDyI0SUsRRUgo8JGg9vqLhEkqzdF4Wn)W2Hdq9I6C89YezVfFEsZS)meb2BTBAsYnJuA0xbv6cu2WhIiGgbCcwOcgnzAkOY4ViSQXUqvpqihnjYAPdOavgnPKhHj08KFVmr2BXNN0m7pdrG9w7MMKCZiLg9vqLUaLn8HicOraNGfQGrMiBkGdkGTb(CK0DKMtMMcQm(lcRASlu1desYKttbvg)fHvn2fQ6bc5iXUk5sTI)IWQg7cv9aHmIawRlUw3ltK9w85jnZ(ZqeyV1UPjH(fqVObiY)baINiRRrAk3msJwE6ObkakIaAeWjyHkGmz5MXq1UsxGYg(qeb0iGtWcvGw3RzD4hvK9whwpAEYpSvYdRNgafG4hwt90aOaeFggGi(qja(H)f)heSOeKhURdBs5wrTUxMi7T4ZtAgHPuotK9wovZtTlJfiLOUEdj)EzIS3IppPzeMs5mr2B5unp1UmwGKyPaLvj)EnRdBIS3IppPz4ar8HsaA30Kmr2uahuaBdCsphnPeSKG7D1deYOS5wOcC2MsTlJfiTbqbOjAi2XUL2LeaNem5ePbEcOUgC8e1VHjsd8eqDn44jQFdt8xew1yxOQhiKtmyZERjkn0BxISItViwl7TMOfSctnoGd3ltK9w85jnJWukNjYElNQ5P2LXcKe7QKl1IFVmr2BXNN0mOF5mr2B5unp1UmwGKTGJd5pq7MMKjYMc4GcyBGphjDhPPyxLCPwrjyjbNvsNee24icyTU4e)C2JMmnfuzuc0TcitwSRsUuROeOBferaR1fN4NZEuAkOYOeOBfO1OjLGLeCwjDsqyJJzlE31W9YezVfFEsZG(LZezVLt18u7Yybs2cUWpINA30Kmr2uahuaBd85iP7ijyjbNvsNee24y2I3DnCVmr2BXNN0mOF5mr2B5unp1UmwG0auaQfoBbTBAsMiBkGdkGTb(CK0DKMtkblj4Ss6KGWghZw8URHrAk2vjxQvucwsWzL0jbHnoIawRl(CpN9OjttbvgLaDRaYKf7QKl1kkb6wbreWADXN75ShLMcQmkb6wbAP19YezVfFEsZimLYzIS3YPAEQDzSaPbOaul0UPjzISPaoOa2g4KEEVUxZAwh(rxIuh(HpIN3ltK9w8OTGl8J4jjjyjbNyBL2nnjnd)00r(xkHYj3LnIatKKjpjfd1wOcIb7Q6AWH(vlCblvaP1ind)00rPHE7sKvC6fXAzVv8hmc9lGErdqucMu1apDITvJmr2uahuaBdCIjPxYKnr2uahuaBdCs6Q19YezVfpAl4c)iEopPzGGwcSTq7MMe6xTWfSubuuc0TOtI185SNxcwsW9U6bczKM6(ljiDPHgGKRNPxTgjblj4Ex9aHmstD)LeKU0qdqYjEkhnjfd1wOcIb7Q6AWH(vlCblvarMC4NMoYPAi2UgCSnpJ)G7LjYElE0wWf(r8CEsZabTeyBH2nnj0VAHlyPcOOeOBrNeR70JKGLeCVREGqgPPU)scsxAObi5Zn9OjPyO2cvqmyxvxdo0VAHlyPcO7LjYElE0wWf(r8CEsZabTeyBH2nnPjLGLeCVREGqgPPU)scsxAObi5JMKIHAlubXGDvDn4q)QfUGLkGitMUhiKoeWADXjEAYKrwlDafOYOjL8imHMN8riRLoGcuz0KsEebSwxCIN(EzIS3IhTfCHFepNN0mu3FjD8aOKa6EzIS3IhTfCHFepNN0mqqlb2wODttAskgQTqfed2v11Gd9Rw4cwQa6EDVM1So8JUePomdK)G7LjYElE0wWXH8hqYQXozj1UPjjblj4Ex9aHmstD)LeKU0qdqYNJKySqboOa2g4KjJSw6akqLrtk5rycnp5JqwlDafOYOjL8icyTU4et65Z7LjYElE0wWXH8hmpPzSAStwsTBAssWscU3vpqiJ0u3FjbPln0aK85in99YezVfpAl44q(dMN0msWscoX2kTBAstsXqTfQGyWUQUgCOF1cxWsfqJ0m8tthLg6TlrwXPxeRL9wXFWi0Va6fnarjysvd80j2wnYeztbCqbSnWjMKEjt2eztbCqbSnWjPRw3ltK9w8OTGJd5pyEsZabTeyBH2nnPjPyO2cvqmyxvxdo0VAHlyPcO7LjYElE0wWXH8hmpPzObEcOUgC8e1VbTfJfkWLgAasoPNA30KKq4NMosd8eqDn4OU)sg5PjEtmj9osSRsUuROfSctnoGdreWADXjwV3ltK9w8OTGJd5pyEsZqd8eqDn44jQFdAlgluGln0aKCsp1UPjjHWpnDKg4jG6AWrD)LmYtt8M4N3ltK9w8OTGJd5pyEsZqd8eqDn44jQFdAlgluGln0aKCsp1UPjH(feZMfC56EmXAk2vjxQvucwsWzL0jbHnoIawRl(OjttbvgLaDRaYKf7QKl1kkb6wbreWADXhLMcQmkb6wbADVUxZAwhEkyZER7LjYElEuSRsUuloPGn7T0UPjrXqTfQGiRruxKtSRsUulUZeztbitMUhiKoeWADXjw3P8EnRzDyIExLCPw87LjYElEuSRsUul(8KMXqSJDlTljaojysTBAsIDvYLAf)fHvn2fQ6bczebSwxCINEKyxLCPwrPHE7sKvC6fXAzVvebSwxChmHaqKGK4PhLMcQm(lcRASlu1desYKNmnfuz8xew1yxOQhiKKjt3deshcyTU4eR3PVxMi7T4rXUk5sT4ZtAg((voeybas70qdq6AAsPHgGmMnl4Y1fisNENM4PhLgAaYy2SGlxNSH5M(EnRdtK(QK8d)GQhiKhMErh(hC4Cp80hMdITK8dN7H5JlXHP2jHd)ObRWuJd4G2hwpnjaiQnh0(WFoCyQDs4Wezd9(W6JSItViwl7TI3ltK9w8OyxLCPw85jnZViSQXUqvpqi1UPjrXqTfQGipDbkRQUggPPyxLCPwrlyfMACahIiG16I7GjeaIeKepnzYIDvYLAfTGvyQXbCiIawRlUdMqaisqo3ZzR1inf7QKl1kkn0BxISItViwl7TIiG16It8GqsMC4NMokn0BxISItViwl7TI)aTUxMi7T4rXUk5sT4ZtAMFryvJDHQEGqQDttYeztbCqbSnWNJKUKjt3deshcyTU4eR7Z7LjYElEuSRsUul(8KMrAO3UezfNErSw2BPDttIIHAlubrE6cuwvDnmst5MXFryvJDHQEGq6KBgraR1fNm5jttbvg)fHvn2fQ6bcPw3ltK9w8OyxLCPw85jnJ0qVDjYko9IyTS3s7MMKjYMc4GcyBGphjDjtMUhiKoeWADXjw3N3ltK9w8OyxLCPw85jnJfSctnoGdA30Kmr2uahuaBdCsphjHWpnDKg4jG6AWrD)LmYtt8Eosp(EzIS3Ihf7QKl1IppPzSGvyQXbCqBXyHcCPHgGKt6P2nnjtKnfWbfW2aFos6oscHFA6inWta11GJ6(lzKNM49CKE8OjLGLeCwjDsqyJJzlE31W9YezVfpk2vjxQfFEsZW)SSB5gm0WowbA30Kq)QfUGLkGIsGUfDs8ZhpstXUk5sTI)IWQg7cv9aHmIawRloXpNnzYYnJ)IWQg7cv9aH0j3mIawRlUw3ltK9w8OyxLCPw85jnZViSQXoJZTVk1UPjrXqTfQGipDbkRQUggjHWpnDKg4jG6AWrD)LmYtt8MyDhPzaKrlyfUbc7xfnr2uaYKd)00rPHE7sKvC6fXAzVv8hmAYaiJgIDSBGW(vrtKnfqR7LjYElEuSRsUul(8KM5xew1yNX52xLAlgluGln0aKCsp1UPjzISPaoOa2g4Zrs3rsi8tthPbEcOUgCu3FjJ80eVjw37LjYElEuSRsUul(8KMbznhCsWKA30KMmaY4aH9RIMiBkW9YezVfpk2vjxQfFEsZWnbQPBrBkxGjsTBAsMiBkGdkGTb(CK0D0KHFA6O0qVDjYko9IyTS3k(dgnPyxLCPwrPHE7sKvC6fXAzVvebMCmzY09aH0HawRloXdc596EnRzDyIEPaLv5HF0Ww1zd87LjYElEuSuGYQKtIt1qSDn4yBEQDttIIHAlubrE6cuwvDnmc9Rw4cwQakkb6w05CpNYrAk2vjxQv0cwHPghWHicyTU4KjpzAkOYOHyh7wAxsaCsJTa5iXUk5sTIsd92LiR40lI1YERicyTU4ArMmDpqiDiG16It8ZN3RzDygipCUh(ZHdB0jGoSfSId38dV1HjAI8Hn(HZ9WbiGcu5HxkasybbDnC4P4uWHPsOvWH5qMDnC4FWHjAISg87LjYElEuSuGYQKppPz4uneBxdo2MNA30Ke7QKl1kAbRWuJd4qebSwx8rAAISPaoOa2g4Zrs3rMiBkGdkGTboXKMEe6xTWfSubuuc0TOZ5Eo7510eztbCqbSnW1ZMsTit2eztbCqbSnWNB6rOF1cxWsfqrjq3IoN7XZwR7LjYElEuSuGYQKppPzSWLTll7TCQMnu7MMefd1wOcI80fOSQ6Ay0K89Rc7sgvGjDHJDWem2afmstXUk5sTIwWkm14aoeraR1fNm5jttbvgne7y3s7scGtASfihj2vjxQvuAO3UezfNErSw2BfraR1fxRrOFbXSzbxUUhpNM6D(WpnDe9Rw4elc9dYERicyTU4ArMmDpqiDiG16ItSUpVxMi7T4rXsbkRs(8KMXcx2USS3YPA2qTBAsumuBHkiYtxGYQQRHr89Rc7sgvGjDHJDWem2afmst5MXFryvJDHQEGq6KBgraR1fFUNpjtEY0uqLXFryvJDHQEGqosSRsUuRO0qVDjYko9IyTS3kIawRlUw3ltK9w8OyPaLvjFEsZyHlBxw2B5unBO2nnjtKnfWbfW2aFos6oc9liMnl4Y19450uVZh(PPJOF1cNyrOFq2BfraR1fxR7LjYElEuSuGYQKppPz4emXBf4scG7xuxusyS2nnjkgQTqfe5Plqzv11Winf7QKl1kAbRWuJd4qebSwxCYKNmnfuz0qSJDlTljaoPXwGCKyxLCPwrPHE7sKvC6fXAzVvebSwxCTitMUhiKoeWADXj(503ltK9w8OyPaLvjFEsZWjyI3kWLea3VOUOKWyTBAsMiBkGdkGTb(CK0DKMsWscoRKojiSXXSfV7AGmzK1shqbQmAsjpIawRloXKE(yTUx3RznRdZ01GcoS(gAaY7LjYElECaka1cssWscoX2kTBAsHFA6i)lLq5K7YgrGjYrtsXqTfQGyWUQUgCOF1cxWsfqKjhazCWqd7yfenr2uG7LjYElECaka1I5jnJeSKGtSTs7MMe6xTWfSubuuc0TOtIFQxYKP7bcPdbSwxCINE0Ksi8tthPbEcOUgCu3FjJ)G7LjYElECaka1I5jnJvJDYsQDttsSRsUuROfSctnoGdreWADXhPzAkOYOeOBfeHYcvGKmzXsbkRYy1deshTbKjJ(fqVObigqam0YUfW1AKMtsXqTfQGyWUQUgCOFbCYKP7bcPdbSwxCINwR7LjYElECaka1I5jnd19xshpakjG0UPjjHWpnDKg4jG6AWrD)LmYtt8EUhpAskgQTqfed2v11Gd9lGFVmr2BXJdqbOwmpPzOU)s64bqjbK2nnjje(PPJ0apbuxdoQ7VKXFWiXUk5sTIwWkm14aoeraR1f3btiaejiNB6rtsXqTfQGyWUQUgCOFb87LjYElECaka1I5jnJeSKGtSTs7MMe6xTWfSubuuc0TOtI1D2JMKIHAlubXGDvDn4q)QfUGLkGUxMi7T4XbOaulMN0m0apbuxdoEI63G2nnjje(PPJ0apbuxdoQ7VKrEAI3e)C0KumuBHkigSRQRbh6xa)EzIS3IhhGcqTyEsZqd8eqDn44jQFdA30KKq4NMosd8eqDn4OU)sg5PjEt8Jhj2vjxQv0cwHPghWHicyTU4oycbGibjXtpAskgQTqfed2v11Gd9lGFVmr2BXJdqbOwmpPzKGLeCITvA30KMKIHAlubXGDvDn4q)QfUGLkGUx3RznRdtuafGAXHF0Li1HNcq9I6C89YezVfpoafGAHZwGevRth9ICIDvYLAPDzSaj((voeybas7MMuAkOYiF)khcSaankn0aKXSzbxUUar6070ep9i6EGq6qaR1fFUPhj2vjxQvKVFLdbwaGIiG16ItSMdcPE2SJejtR1itKnfWbfW2aNys69EzIS3IhhGcqTWzlmpPzKGLeCITvA30K0CskgQTqfed2v11Gd9Rw4cwQaIm5WpnDK)LsOCYDzJiWePwJ0m8tthLg6TlrwXPxeRL9wXFWi0Va6fnarjysvd80j2wnYeztbCqbSnWjMKEjt2eztbCqbSnWjPRw3ltK9w84auaQfoBH5jnde0sGTfA30Kc)00r(xkHYj3LnIatKKjpjfd1wOcIb7Q6AWH(vlCblvaDVmr2BXJdqbOw4SfMN0mu3FjD8aOKasBXyHcCPHgGKt6P2nnjnf7QKl1kAbRWuJd4qebSwx85MEKec)00rAGNaQRbh19xY4pGmzje(PPJ0apbuxdoQ7VKrEAI3Z9yTgPjDpqiDiG16ItSyxLCPwrjyjbNvsNee24icyTU4Z)C2Kjt3deshcyTU4Zj2vjxQv0cwHPghWHicyTU4ADVmr2BXJdqbOw4SfMN0m0apbuxdoEI63G2IXcf4sdnajN0tTBAssi8tthPbEcOUgCu3FjJ80eVjMKEhj2vjxQv0cwHPghWHicyTU4eRxYKLq4NMosd8eqDn4OU)sg5PjEt8Z7LjYElECaka1cNTW8KMHg4jG6AWXtu)g0wmwOaxAObi5KEQDttsSRsUuROfSctnoGdreWADXNB6rsi8tthPbEcOUgCu3FjJ80eVj(596EnRzDy9rD9gs(9YezVfpMOUEdjN0NdUobwTlJfi1fxG(PfQahr8Tk)SojqPfG2nnjnf7QKl1k(lcRASlu1deYicyTU4Kjl2vjxQvuAO3UezfNErSw2BfraR1fxRrAgaz0qSJDde2VkAISPaKjhaz0cwHBGW(vrtKnfy0KPPGkJgIDSBPDjbWjn2cKKjNgAaYy2SGlxxGiD6oBINwlYKP7bcPdbSwxCI1959YezVfpMOUEdjFEsZ85GRtGv7YybsSMWcrGJtaG0X(5Tq7MMKyxLCPwrlyfMACahIiG16It80J0CsGi(DqaiJDXfOFAHkWreFRYpRtcuAbqMSyxLCPwXU4c0pTqf4iIVv5N1jbkTaIiG16IRfzY09aH0HawRloX6(8EzIS3IhtuxVHKppPz(CW1jWQDzSajjcmjDJahfGZbL2nnjXUk5sTIwWkm14aoeraR1fFKMtceXVdcazSlUa9tluboI4Bv(zDsGslaYKf7QKl1k2fxG(PfQahr8Tk)SojqPfqebSwxCTitMUhiKoeWADXjwV3ltK9w8yI66nK85jnZNdUobwTlJfijn0B2DlNeeVDuwKj6CS2nnjXUk5sTIwWkm14aoeraR1fFKMtceXVdcazSlUa9tluboI4Bv(zDsGslaYKf7QKl1k2fxG(PfQahr8Tk)SojqPfqebSwxCTitMUhiKoeWADXjw3N3ltK9w8yI66nK85jnZNdUobwU2nnjnf7QKl1kAbRWuJd4qebSwxCYKd)00rPHE7sKvC6fXAzVv8hO1inNeiIFheaYyxCb6NwOcCeX3Q8Z6KaLwaKjl2vjxQvSlUa9tluboI4Bv(zDsGslGicyTU4A5tF69]] )

end
