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


    spec:RegisterPack( "Unholy", 20210208, [[daLORbqifPEejfBsH8jsOrrICksuRsrc6vkknlsIBPibAxc9lfvgMQahtvYYiP6zKatJeKRPOyBks03qikJdHK6CKGQwNcv9oeIunpeQ7Hi7trvhuvqTqvHEicPMijL6IiejBeHKOpIqunsescNeHiwPQOxIqsAMKuYnriszNKK(jjO0qvfelvrc9uuAQkuUkjOyRksaFvvqASksAVc(lvgmWHPSyQYJjmzIUm0MrQpRGrJGtl1QriXRvLA2K62Oy3s(TsdNQ64iewoONJQPl66QQTJO(osA8ku58kI1tcQmFKy)QC4vySaR0smOQ6pq9xpq9hquhFPWRa1vi1dS5eFmW6BI32agylJbdSkmfHvpjW6Bt0RjdJfy57hkWalHm95JFU5g6KW3lkwM54nZxBzVLaA05C8MrmxG1736KiPcEbwPLyqv1FG6VEG6pGOo(sHxbQRU6bwUpkcQQ(mQhyj0sjwbVaRe5IaRAuZbuB0schGOA1deYdOWuew9K7PAuZbiQe9GFdo5ae1QCa1FG6VUN3t1OMd8WsIYNNmyL8dK7bu7sTNtTr6wJZP2OLe4hqT)4bY9aBPNCaX(R8aPbhWKFaQe2dyq8a448rrIYdK7b0nz8a6Tgoaw7FGWbY9amwMi8akzl64y(9pGAEPC8EQg1Ca1U5MNgLhG1eWMUfTPpWdXe5b8qH954bKOjpWaH9R5hGXEJhGEHhGBYdO2ev5X7PAuZbuy4DnCGh6(l5by9XsIWdyETUZg5hGzH4bO144Ap9KdOKLhqHM9a80eV5hOlEIM8al9bMzwLjs)aQ9dH9af(tOPpGvYdWytoGpejJvEa(YGhO2PGquCaENFl7T4XaRU5jpmwG1w0XX87hglO6RWybwSmpnkdpgyfWoryBbwjAjb37QhiKrAQ7VKO0LgCat(bMN0beteA0HfY0i)auOCaO1shsgRmAsjpIJR5j)aJoa0APdjJvgnPKhHiJ1f)aet6aVEfynr2BfyTAItwYqguv9WybwSmpnkdpgyfWoryBbwjAjb37QhiKrAQ7VKO0LgCat(bMN0bMjWAIS3kWA1eNSKHmOQccJfyXY80Om8yGva7eHTfyN(aKnyBEAm6VRURbh8xTW5Vur4bgDaLoG3NMokn4BxcTItVqgl7TIF)dm6aWFH0lCaJs0K6g5PtSToIL5Pr5bgDatKnz0HfY0i)aet6ak4auOCatKnz0HfY0i)aKoG6hq5aRjYERaReTKGtSToKbvvOWybwSmpnkdpgyfWoryBb2Ppazd2MNgJ(7Q7AWb)vlC(lvegynr2Bfyr)wImTiKbvNjmwGflZtJYWJbwtK9wbwAKNiSRbhpH9BmWkGDIW2cSs07tthPrEIWUgCu3FjJ80eVpaXKoGcoWOdi2vlxQv08xHPN4ZXiezSU4hG4dOGaRyIqJU0GdyYdQ(kKbvNYWybwSmpnkdpgynr2BfyPrEIWUgC8e2VXaRa2jcBlWkrVpnDKg5jc7AWrD)LmYtt8(aeFGxbwXeHgDPbhWKhu9vidQsKfglWIL5Prz4XaRjYERalnYte21GJNW(ngyfWoryBbw4VWy2mOlxNcDaIpGshqSRwUuROeTKGZkPtIcBseImwx8dm6atFG00yLrjs3AmIL5Pr5bOq5aID1YLAfLiDRXiezSU4hy0bstJvgLiDRXiwMNgLhq5aRyIqJU0GdyYdQ(kKHmWAl68(qEgglO6RWybwSmpnkdpgyfWoryBbwLoG3NMoY)sjwo5UmriAI8auOCGPpazd2MNgJ(7Q7AWb)vlC(lveEaLpWOdO0b8(00rPbF7sOvC6fYyzVv87FGrha(lKEHdyuIMu3ipDIT1rSmpnkpWOdyISjJoSqMg5hGyshqbhGcLdyISjJoSqMg5hG0bu)akhynr2BfyLOLeCIT1HmOQ6HXcSyzEAugEmWkGDIW2cSWF1cN)sfHrjs3IopaXhqPd86bhy2dirlj4Ex9aHmstD)LeLU0GdyYpWu4buWbu(aJoGeTKG7D1deYin19xsu6sdoGj)aeFGP8aJoW0hGSbBZtJr)D1Dn4G)Qfo)LkcpafkhW7tth5unitxdoMMNXVFG1ezVvGf9BjY0IqguvbHXcSyzEAugEmWkGDIW2cSWF1cN)sfHrjs3IopaXhq9zoWOdirlj4Ex9aHmstD)LeLU0GdyYpW8hyMdm6atFaYgSnpng93v31Gd(Rw48xQimWAIS3kWI(TezAridQQqHXcSyzEAugEmWkGDIW2cStFajAjb37QhiKrAQ7VKO0LgCat(bgDGPpazd2MNgJ(7Q7AWb)vlC(lveEakuoaDpqiDqKX6IFaIpWmhGcLdaTw6qYyLrtk5rCCnp5hy0bGwlDizSYOjL8iezSU4hG4dmtG1ezVvGf9BjY0IqguDMWybwtK9wbwQ7VKoUpwsegyXY80Om8yidQoLHXcSyzEAugEmWkGDIW2cStFaYgSnpng93v31Gd(Rw48xQimWAIS3kWI(TezAridzGDale2IWybvFfglWIL5Prz4XaRa2jcBlW69PPJ8VuILtUlteIMipWOdm9biBW280y0FxDxdo4VAHZFPIWdqHYb8XmoyWHDIgJMiBYyG1ezVvGvIwsWj2whYGQQhglWIL5Prz4XaRa2jcBlWc)vlC(lvegLiDl68aeFGxk4auOCa6EGq6GiJ1f)aeFGzoWOdm9bKO3NMosJ8eHDn4OU)sg)(bwtK9wbwjAjbNyBDidQQGWybwSmpnkdpgyfWoryBbwXUA5sTIM)km9eFogHiJ1f)aJoGshinnwzuI0TgJyzEAuEakuoGyjJLvzS6bcPJ2WdqHYbG)cPx4ag9jGgCz2c5rSmpnkpGYhy0bu6atFaYgSnpng93v31Gd(lKFakuoaDpqiDqKX6IFaIpWmhq5aRjYERaRvtCYsgYGQkuySalwMNgLHhdScyNiSTaRe9(00rAKNiSRbh19xYipnX7dm)buWbgDGPpazd2MNgJ(7Q7AWb)fYdSMi7TcSu3FjDCFSKimKbvNjmwGflZtJYWJbwbSte2wGvIEFA6inYte21GJ6(lz87FGrhqSRwUuRO5VctpXNJriYyDXD448rrIYdm)bM5aJoW0hGSbBZtJr)D1Dn4G)c5bwtK9wbwQ7VKoUpwsegYGQtzySalwMNgLHhdScyNiSTal8xTW5VuryuI0TOZdq8bu)bhy0bM(aKnyBEAm6VRURbh8xTW5VuryG1ezVvGvIwsWj2whYGQezHXcSyzEAugEmWkGDIW2cSs07tthPrEIWUgCu3FjJ80eVpaXh41bgDGPpazd2MNgJ(7Q7AWb)fYdSMi7TcS0ipryxdoEc73yidQsuhglWIL5Prz4XaRa2jcBlWkrVpnDKg5jc7AWrD)LmYtt8(aeFaf6aJoGyxTCPwrZFfMEIphJqKX6I7WX5JIeLhG4dmZbgDGPpazd2MNgJ(7Q7AWb)fYdSMi7TcS0ipryxdoEc73yidQQWhglWIL5Prz4XaRa2jcBlWo9biBW280y0FxDxdo4VAHZFPIWaRjYERaReTKGtSToKHmWkwYyzvYdJfu9vySalwMNgLHhdScyNiSTalzd2MNgJ805RTQ6A4aJoa8xTW5VuryuI0TOZdm)bEnLhy0bu6aID1YLAfn)vy6j(CmcrgRl(bOq5atFG00yLrdYmXT0UKa6KgtHYiwMNgLhy0be7QLl1kkn4BxcTItVqgl7TIqKX6IFaLpafkhGUhiKoiYyDXpaXh41RaRjYERalNQbz6AWX08mKbvvpmwGflZtJYWJbwtK9wbwovdY01GJP5zGvICbS9ZERallMhi3d854bm6eHhW8xXbA(b26aeTAFaJFGCpGpejJvEGLmcfMVFxdhyk(qoavcTgpahZSRHd89parR2kYdScyNiSTaRyxTCPwrZFfMEIphJqKX6IFGrhqPdyISjJoSqMg5hyEshq9dm6aMiBYOdlKPr(biM0bM5aJoa8xTW5VuryuI0TOZdm)bE9Gdm7bu6aMiBYOdlKPr(bMcpWuEaLpafkhWeztgDyHmnYpW8hyMdm6aWF1cN)sfHrjs3IopW8hqHEWbuoKbvvqySalwMNgLHhdScyNiSTalzd2MNgJ805RTQ6A4aJoW0hGVFTxxYOgnPZBIdhNX4RXiwMNgLhy0bu6aID1YLAfn)vy6j(CmcrgRl(bOq5atFG00yLrdYmXT0UKa6KgtHYiwMNgLhy0be7QLl1kkn4BxcTItVqgl7TIqKX6IFaLpWOda)fgZMbD56uOdm)bu6ak4aZEaVpnDe(Rw4ele(9ZERiezSU4hq5dqHYbO7bcPdImwx8dq8bu)vG1ezVvG18wMUSS3YPBgVqguvHcJfyXY80Om8yGva7eHTfyjBW280yKNoFTvvxdhy0b47x71LmQrt68M4WXzm(AmIL5Pr5bgDaLoGCZ4ViS6jopDpqiDYnJqKX6IFG5pWRxhGcLdm9bstJvg)fHvpX5P7bczelZtJYdm6aID1YLAfLg8TlHwXPxiJL9wriYyDXpGYbwtK9wbwZBz6YYElNUz8czq1zcJfyXY80Om8yGva7eHTfynr2KrhwitJ8dmpPdO(bgDa4VWy2mOlxNcDG5pGshqbhy2d49PPJWF1cNyHWVF2BfHiJ1f)akhynr2BfynVLPll7TC6MXlKbvNYWybwSmpnkdpgyfWoryBbwYgSnpng5PZxBv11WbgDaLoGyxTCPwrZFfMEIphJqKX6IFakuoW0hinnwz0GmtClTljGoPXuOmIL5Pr5bgDaXUA5sTIsd(2LqR40lKXYERiezSU4hq5dqHYbO7bcPdImwx8dq8bEntG1ezVvGLtWeV1OljGUFrDHjHjHmOkrwySalwMNgLHhdScyNiSTaRjYMm6WczAKFG5jDa1pWOdO0bKOLeCwjDsuytIzlE31WbOq5aqRLoKmwz0KsEeImwx8dqmPd8sHoGYbwtK9wbwobt8wJUKa6(f1fMeMeYqgy9HOyz8Smmwq1xHXcSMi7TcS(B2BfyXY80Om8yidQQEySalwMNgLHhdSLXGbwtHJtWGg3rVv6wAN)sfHbwtK9wbwtHJtWGg3rVv6wAN)sfHHmOQccJfynr2BfyHwZrNenzGflZtJYWJHmKbwXUA5sT4HXcQ(kmwGflZtJYWJbwbSte2wGLSbBZtJrgJOSqNyxTCPwCNjYMmEakuoaDpqiDqKX6IFaIpG6tzG1ezVvG1FZERqguv9WybwSmpnkdpgyfWoryBbwXUA5sTI)IWQN4809aHmcrgRl(bi(aZCGrhqSRwUuRO0GVDj0ko9czSS3kcrgRlUdhNpksuEaIpWmhy0bstJvg)fHvpX5P7bczelZtJYdqHYbM(aPPXkJ)IWQN4809aHmIL5Pr5bOq5a09aH0brgRl(bi(akyMaRjYERaRbzM4wAxsaDs0KHmOQccJfyXY80Om8yGva7eHTfytdoGzmBg0LRZxKofmZbi(aZCGrhin4aMXSzqxUozJhy(dmtG1ezVvGLVFTdIMpcdzqvfkmwGflZtJYWJbwtK9wb2Fry1tCE6EGqgyLixaB)S3kWsuXQL8d8OUhiKhGEHh47FGCpWmhGJITK8dK7b4tkXbO2jHd8W(RW0t85OkhqHnjGqQnhv5aFoEaQDs4aQTbFFGXGwXPxiJL9wXaRa2jcBlWs2GT5PXipD(ARQUgoWOdO0be7QLl1kA(RW0t85yeImwxChooFuKO8aeFGzoafkhqSRwUuRO5VctpXNJriYyDXD448rrIYdm)bE9GdO8bgDaLoGyxTCPwrPbF7sOvC6fYyzVveImwx8dq8bgeYdqHYb8(00rPbF7sOvC6fYyzVv87FaLdzq1zcJfyXY80Om8yGva7eHTfynr2KrhwitJ8dmpPdO(bOq5a09aH0brgRl(bi(aQ)kWAIS3kW(lcREIZt3deYqguDkdJfyXY80Om8yGva7eHTfyjBW280yKNoFTvvxdhy0bu6aYnJ)IWQN4809aH0j3mcrgRl(bOq5atFG00yLXFry1tCE6EGqgXY80O8akhynr2BfyLg8TlHwXPxiJL9wHmOkrwySalwMNgLHhdScyNiSTaRjYMm6WczAKFG5jDa1pafkhGUhiKoiYyDXpaXhq9xbwtK9wbwPbF7sOvC6fYyzVvidQsuhglWIL5Prz4XaRa2jcBlWAISjJoSqMg5hG0bEDGrhqIEFA6inYte21GJ6(lzKNM49bM)akiWAIS3kWA(RW0t85yidQQWhglWIL5Prz4XaRjYERaR5VctpXNJbwbSte2wG1eztgDyHmnYpW8KoG6hy0bKO3NMosJ8eHDn4OU)sg5PjEFG5pGcoWOdm9bKOLeCwjDsuytIzlE31qGvmrOrxAWbm5bvFfYGQVEqySalwMNgLHhdScyNiSTal8xTW5VuryuI0TOZdq8bEPqhy0bu6aID1YLAf)fHvpX5P7bczeImwx8dq8bE9GdqHYbKBg)fHvpX5P7bcPtUzeImwx8dOCG1ezVvGL)zy2YnyWHDIgdzq1xVcJfyXY80Om8yGva7eHTfyjBW280yKNoFTvvxdhy0bKO3NMosJ8eHDn4OU)sg5PjEFaIpG6hy0bu6a(ygn)v4giSFD0eztgpafkhW7tthLg8TlHwXPxiJL9wXV)bgDGPpGpMrdYmXnqy)6OjYMmEaLdSMi7TcS)IWQN4mo3(6mKbvFPEySalwMNgLHhdSMi7TcS)IWQN4mo3(6mWkGDIW2cSMiBYOdlKPr(bMN0bu)aJoGe9(00rAKNiSRbh19xYipnX7dq8bupWkMi0Oln4aM8GQVczq1xkimwGflZtJYWJbwbSte2wGD6d4JzCGW(1rtKnzmWAIS3kWcTMJojAYqgYa7awiSfoBXWybvFfglWIL5Prz4XaRjYERalvRth9cDID1YLAfyfWoryBb200yLr((1oiA(imIL5Pr5bgDG0GdygZMbD568fPtbZCaIpWmhy0bO7bcPdImwx8dm)bM5aJoGyxTCPwr((1oiA(imcrgRl(bi(akDGbH8atHh4brISzoGYhy0bmr2KrhwitJ8dqmPdOGaBzmyGLVFTdIMpcdzqv1dJfyXY80Om8yGva7eHTfyv6atFaYgSnpng93v31Gd(Rw48xQi8auOCaVpnDK)LsSCYDzIq0e5bu(aJoGshW7tthLg8TlHwXPxiJL9wXV)bgDa4Vq6foGrjAsDJ80j2whXY80O8aJoGjYMm6WczAKFaIjDafCakuoGjYMm6WczAKFashq9dOCG1ezVvGvIwsWj2whYGQkimwGflZtJYWJbwbSte2wG17tth5FPelNCxMienrEakuoW0hGSbBZtJr)D1Dn4G)Qfo)LkcdSMi7TcSOFlrMweYGQkuySalwMNgLHhdSMi7TcSu3FjDCFSKimWkGDIW2cSkDaXUA5sTIM)km9eFogHiJ1f)aZFGzoWOdirVpnDKg5jc7AWrD)Lm(9pafkhqIEFA6inYte21GJ6(lzKNM49bM)ak4akFGrhqPdq3deshezSU4hG4di2vlxQvuIwsWzL0jrHnjcrgRl(bM9aVEWbOq5a09aH0brgRl(bM)aID1YLAfn)vy6j(CmcrgRl(buoWkMi0Oln4aM8GQVczq1zcJfyXY80Om8yG1ezVvGLg5jc7AWXty)gdScyNiSTaRe9(00rAKNiSRbh19xYipnX7dqmPdOGdm6aID1YLAfn)vy6j(CmcrgRl(bi(ak4auOCaj69PPJ0ipryxdoQ7VKrEAI3hG4d8kWkMi0Oln4aM8GQVczq1PmmwGflZtJYWJbwtK9wbwAKNiSRbhpH9BmWkGDIW2cSID1YLAfn)vy6j(CmcrgRl(bM)aZCGrhqIEFA6inYte21GJ6(lzKNM49bi(aVcSIjcn6sdoGjpO6RqgYaBc76nM8WybvFfglWIL5Prz4XaRjYERaBxCb8NMNgDeX3Q8Z4Ki5wGbwbSte2wGvPdi2vlxQv8xew9eNNUhiKriYyDXpafkhqSRwUuRO0GVDj0ko9czSS3kcrgRl(bu(aJoGshWhZObzM4giSFD0eztgpafkhWhZO5Vc3aH9RJMiBY4bgDGPpqAASYObzM4wAxsaDsJPqzelZtJYdqHYbsdoGzmBg0LRZxKo1FWbi(aZCaLpafkhGUhiKoiYyDXpaXhq9xb2YyWaBxCb8NMNgDeX3Q8Z4Ki5wGHmOQ6HXcSyzEAugEmWAIS3kWYycZdIoobethZN3IaRa2jcBlWk2vlxQv08xHPN4ZXiezSU4hG4dmZbgDaLoW0hajIF77JYyxCb8NMNgDeX3Q8Z4Ki5wGhGcLdi2vlxQvSlUa(tZtJoI4Bv(zCsKClWiezSU4hq5dqHYbO7bcPdImwx8dq8bu)vGTmgmWYycZdIoobethZN3IqguvbHXcSyzEAugEmWAIS3kWkHOjPBi6iJCoQdScyNiSTaRyxTCPwrZFfMEIphJqKX6IFGrhqPdm9bqI43((Om2fxa)P5Prhr8Tk)mojsUf4bOq5aID1YLAf7IlG)080OJi(wLFgNej3cmcrgRl(bu(auOCa6EGq6GiJ1f)aeFafeylJbdSsiAs6gIoYiNJ6qguvHcJfyXY80Om8yG1ezVvGvAW3m7wojkE7iVqt05KaRa2jcBlWk2vlxQv08xHPN4ZXiezSU4hy0bu6atFaKi(TVpkJDXfWFAEA0reFRYpJtIKBbEakuoGyxTCPwXU4c4pnpn6iIVv5NXjrYTaJqKX6IFaLpafkhGUhiKoiYyDXpaXhq9xb2YyWaR0GVz2TCsu82rEHMOZjHmO6mHXcSyzEAugEmWkGDIW2cSkDaXUA5sTIM)km9eFogHiJ1f)auOCaVpnDuAW3UeAfNEHmw2Bf)(hq5dm6akDGPpase)23hLXU4c4pnpn6iIVv5NXjrYTapafkhqSRwUuRyxCb8NMNgDeX3Q8Z4Ki5wGriYyDXpGYbwtK9wb2phDDIm8qgYaRePTVodJfu9vySaRjYERaltxshnerfomWIL5Prz4Xqguv9WybwSmpnkdpgyx)alhZaRjYERalzd2MNgdSKn9hdSID1YLAf5FgMTCdgCyNOXiezSU4hG4dmZbgDG00yLr(NHzl3Gbh2jAmIL5PrzGLSbDLXGbw)D1Dn4G)Qfo)LkcdzqvfeglWIL5Prz4Xa76hy5ygynr2BfyjBW280yGLSP)yGnnnwzKVFTdIMpcJyzEAuEGrha(l8aeFa1pWOdKgCaZy2mOlxNViDkyMdq8bM5aJoaDpqiDqKX6IFG5pWmbwYg0vgdgy93v31Gd(lKhYGQkuySalwMNgLHhdSRFGLJzG1ezVvGLSbBZtJbwYM(JbwtKnz0HfY0i)aKoWRdm6akDGPpa0APdjJvgnPKhXX18KFakuoa0APdjJvgnPKh76aZFGxZCaLdSKnORmgmWYtNV2QQRHqguDMWybwSmpnkdpgyx)alhZaRjYERalzd2MNgdSKn9hdS(yghm4WorJrtKnz8auOCaVpnD8xew9eNX52xNXV)bOq5aPPXkJgKzIBPDjb0jnMcLrSmpnkpWOd4Jz08xHBGW(1rtKnz8auOCaVpnDuAW3UeAfNEHmw2Bf)(bwYg0vgdgyzmIYcDID1YLAXDMiBYyidQoLHXcSyzEAugEmWkGDIW2cSWF1cN)sfHrjs3IopW8hykN5aJoGshWhZ4Gbh2jAmAISjJhGcLdm9bstJvg5FgMTCdgCyNOXiwMNgLhq5dm6aWFHrjs3IopW8KoWmbwtK9wbwdkScD5cHyLHmOkrwySalwMNgLHhdScyNiSTalzd2MNgJmgrzHoXUA5sT4otKnz8auOCG0GdygZMbD56KnEaIjDaVpnD0tVR0r)HtIYp0YERaRjYERaRNExPJ(dNeYGQe1HXcSyzEAugEmWkGDIW2cSKnyBEAmYyeLf6e7QLl1I7mr2KXdqHYbsdoGzmBg0LRt24biM0b8(00rpeYr47UgIYp0YERaRjYERaRhc5i8DxdHmOQcFySalwMNgLHhdScyNiSTaR3NMo(lcREIJNqSgscXVFG1ezVvGv3desUJO8LdmyLHmO6RheglWIL5Prz4XaRjYERaRvcKNqt7eMwhyLixaB)S3kW(WLa5j00hGOnT(acRoqc7HbeEaf6a(BIv2M(aEFAAUkhanbHdOnE21WbEnZb4OyljpEafMS1TchkpabdkpGyLO8azZGhW4hWoqc7HbeEGCpWBe9pqNhaIM080ymWkGDIW2cSKnyBEAmYyeLf6e7QLl1I7mr2KXdqHYbsdoGzmBg0LRt24biM0bEntidQ(6vySalwMNgLHhdScyNiSTaRjYMm6WczAKFG5jDa1pafkhqPda)fgLiDl68aZt6aZCGrha(Rw48xQimkr6w05bMN0bMYhCaLdSMi7TcSguyf68)AogYGQVupmwGflZtJYWJbwbSte2wGLSbBZtJrgJOSqNyxTCPwCNjYMmEakuoqAWbmJzZGUCDYgpaXKoG3NMos3q0tVRmk)ql7TcSMi7TcS0ne907kdzq1xkimwGflZtJYWJbwbSte2wG17tth)fHvpXXtiwdjH43)aJoGjYMm6WczAKFash4vG1ezVvG1ZgClTlHT4npKbvFPqHXcSyzEAugEmWAIS3kWU)0dI27aRe5cy7N9wbwI0SUsRRUgoWuGg(1yLh4HOTHpEGMFa7a(WEHDojWkGDIW2cSYnJKB4xJv6812WhJqKgICcMNgpWOdm9bstJvg)fHvpX5P7bczelZtJYdm6atFaO1shsgRmAsjpIJR5jpKbvFntySalwMNgLHhdScyNiSTaRCZi5g(1yLoFTn8XiePHiNG5PXdm6aMiBYOdlKPr(bMN0bu)aJoGshy6dKMgRm(lcREIZt3deYiwMNgLhGcLdKMgRm(lcREIZt3deYiwMNgLhy0be7QLl1k(lcREIZt3deYiezSU4hq5aRjYERa7(tpiAVdzq1xtzySalwMNgLHhdScyNiSTal8xi9chWi)7JqEcTUIyzEAuEGrhqPdi3msdxE6OrYimcrAiYjyEA8auOCa5Mrp9UsNV2g(yeI0qKtW804buoWAIS3kWU)0dI27qgu9frwySalwMNgLHhdSsKlGTF2BfyFyr2BDa1Q5j)awjpGcRpwiKFaLuy9XcH85yrI4JLa5h4x8VV)ctuEGUoGjLBfvoWAIS3kWkmT2zIS3YPBEgy1npDLXGb2e21Bm5HmO6lI6WybwSmpnkdpgynr2BfyfMw7mr2B50npdS6MNUYyWaRyjJLvjpKbvFPWhglWIL5Prz4XaRe5cy7N9wbwtK9w8OePTVoNL0CCKi(yjqvAAsMiBYOdlKProPxJMwIwsW9U6bczu2CZtJoBtPkLXGKwFSq44niZe3s7scOtIMC80ipryxdoEc7344PrEIWUgC8e2VXX)lcREIZt3deYX7VzV14Lg8TlHwXPxiJL9wJ38xHPN4ZXaRjYERaRW0ANjYElNU5zGv380vgdgyf7QLl1IhYGQQ)GWybwSmpnkdpgyfWoryBbwtKnz0HfY0i)aZt6aQFGrhqPdi2vlxQvuIwsWzL0jrHnjcrgRl(bi(aVEWbgDGPpqAASYOePBngXY80O8auOCaXUA5sTIsKU1yeImwx8dq8bE9Gdm6aPPXkJsKU1yelZtJYdO8bgDGPpGeTKGZkPtIcBsmBX7UgcSMi7TcSWF5mr2B50npdS6MNUYyWaRTOJJ53pKbvv)vySalwMNgLHhdScyNiSTaRjYMm6WczAKFG5jDa1pWOdirlj4Ss6KOWMeZw8URHaRjYERal8xotK9woDZZaRU5PRmgmWAl68(qEgYGQQREySalwMNgLHhdScyNiSTaRjYMm6WczAKFG5jDa1pWOdO0bM(as0scoRKojkSjXSfV7A4aJoGshqSRwUuROeTKGZkPtIcBseImwx8dm)bE9Gdm6atFG00yLrjs3AmIL5Pr5bOq5aID1YLAfLiDRXiezSU4hy(d86bhy0bstJvgLiDRXiwMNgLhq5dOCG1ezVvGf(lNjYElNU5zGv380vgdgyhWcHTWzlgYGQQRGWybwSmpnkdpgyfWoryBbwtKnz0HfY0i)aKoWRaRjYERaRW0ANjYElNU5zGv380vgdgyhWcHTiKHmKbwYiK3Bfuv9hO(Rh8s9zcSuny11apW(qF4POQejQsKp(dCGXiGhOz8xyEa6fEafTfDCm)(kEaise)gIYdWxg8a2pxglr5beeSAa5X7PA1fEafm(dq0BrgHjkpGIWFH0lCaJtvXdK7bue(lKEHdyCQrSmpnkv8ak9ACkhVNQvx4biYg)bi6TiJWeLhqX00yLXPQ4bY9akMMgRmo1iwMNgLkEaLuFCkhVN3Zh6dpfvLirvI8XFGdmgb8anJ)cZdqVWdOOTOZ7d5PIhaIeXVHO8a8LbpG9ZLXsuEabbRgqE8EQwDHh414parVfzeMO8akc)fsVWbmovfpqUhqr4Vq6foGXPgXY80OuXdO0RXPC8EEpFOp8uuvIevjYh)boWyeWd0m(lmpa9cpGIdyHWwO4bGir8BikpaFzWdy)CzSeLhqqWQbKhVNQvx4buW4parVfzeMO8akc)fsVWbmovfpqUhqr4Vq6foGXPgXY80OuXdO0RXPC8EEpFOp8uuvIevjYh)boWyeWd0m(lmpa9cpGIILmwwLCfpaejIFdr5b4ldEa7NlJLO8accwnG849uT6cpWRXFaIElYimr5bumnnwzCQkEGCpGIPPXkJtnIL5PrPIhqPxJt549uT6cpGcg)bi6TiJWeLhqX00yLXPQ4bY9akMMgRmo1iwMNgLkEaLEnoLJ3t1Ql8aky8hGO3ImctuEaf57x71LmovfpqUhqr((1EDjJtnIL5PrPIhqPxJt549uT6cpGcn(dq0BrgHjkpGIPPXkJtvXdK7bumnnwzCQrSmpnkv8ak9ACkhVNQvx4buOXFaIElYimr5buKVFTxxY4uv8a5Eaf57x71Lmo1iwMNgLkEaLEnoLJ3t1Ql8at54parVfzeMO8akMMgRmovfpqUhqX00yLXPgXY80OuXdO0RXPC8EEpFOp8uuvIevjYh)boWyeWd0m(lmpa9cpGIID1YLAXv8aqKi(neLhGVm4bSFUmwIYdiiy1aYJ3t1Ql8aQp(dq0BrgHjkpGIPPXkJtvXdK7bumnnwzCQrSmpnkv8akP(4uoEpvRUWdmLJ)ae9wKryIYdOyAASY4uv8a5EafttJvgNAelZtJsfpGsVgNYX7598H(WtrvjsuLiF8h4aJrapqZ4VW8a0l8akoGfcBHZwuXdarI43quEa(YGhW(5YyjkpGGGvdipEpvRUWd8A8hqHP4FF)fMO8aMi7ToGIuToD0l0j2vlxQLIX7PA1fEGxJ)ae9wKryIYdOyAASY4uv8a5EafttJvgNAelZtJsfpGsVgNYX7PA1fEa1h)bi6TiJWeLhqr4Vq6foGXPQ4bY9akc)fsVWbmo1iwMNgLkEaLEnoLJ3Z75d9HNIQsKOkr(4pWbgJaEGMXFH5bOx4bumHD9gtUIhaIeXVHO8a8LbpG9ZLXsuEabbRgqE8EQwDHh414parVfzeMO8akMMgRmovfpqUhqX00yLXPgXY80OuXdO0RXPC8EEpFOp8uuvIevjYh)boWyeWd0m(lmpa9cpGIsK2(6uXdarI43quEa(YGhW(5YyjkpGGGvdipEpvRUWdO(4parVfzeMO8akMMgRmovfpqUhqX00yLXPgXY80OuXdy5bisPWQwhqPxJt549uT6cpGcg)bi6TiJWeLhqX00yLXPQ4bY9akMMgRmo1iwMNgLkEaLEnoLJ3t1Ql8aZm(dq0BrgHjkpGIPPXkJtvXdK7bumnnwzCQrSmpnkv8ak9ACkhVNQvx4bEPqJ)ae9wKryIYdOyAASY4uv8a5EafttJvgNAelZtJsfpGsVgNYX7PA1fEGxZm(dq0BrgHjkpGIPPXkJtvXdK7bumnnwzCQrSmpnkv8akP(4uoEpvRUWd8Akh)bi6TiJWeLhqr4Vq6foGXPQ4bY9akc)fsVWbmo1iwMNgLkEaLEnoLJ3t1Ql8aQ)GXFaIElYimr5bumnnwzCQkEGCpGIPPXkJtnIL5PrPIhqj1hNYX7PA1fEa1vF8hGO3ImctuEafttJvgNQIhi3dOyAASY4uJyzEAuQ4bus9XPC8EEpjsy8xyIYdOWFatK9whq38KhVNbwF4s3AmWQg1Ca1gTKWbiQw9aH8akmfHvp5EQg1CaIkrp43GtoarTkhq9hO(R759unQ5apSKO85jdwj)a5Ea1Uu75uBKU14CQnAjb(bu7pEGCpWw6jhqS)kpqAWbm5hGkH9agepaooFuKO8a5EaDtgpGERHdG1(hiCGCpaJLjcpGs2IooMF)dOMxkhVNQrnhqTBU5Pr5bynbSPBrB6d8qmrEapuyFoEajAYdmqy)A(byS34bOx4b4M8aQnrvE8EQg1CafgExdh4HU)sEawFSKi8aMxR7Sr(bywiEaAnoU2tp5akz5buOzpapnXB(b6INOjpWsFGzMvzI0pGA)qypqH)eA6dyL8am2Kd4drYyLhGVm4bQDkiefhG353YElE8EEpnr2BXJ(quSmEwolP583S36EAIS3Ih9HOyz8SCwsZ95ORtKrLYyqsMchNGbnUJER0T0o)LkcVNMi7T4rFikwgplNL0CqR5OtIM8EEpvJAoarQXHIFIYdGKr4KdKndEGKaEatKl8an)agzR1MNgJ3ttK9wCsmDjD0qev4W7PAuZbMcyW280i)EAIS3IplP5iBW280OkLXGK83v31Gd(Rw48xQiufYM(JKe7QLl1kY)mmB5gm4WorJriYyDXjEMrPPXkJ8pdZwUbdoSt0490ezVfFwsZr2GT5PrvkJbj5VRURbh8xixfYM(JKstJvg57x7GO5JWrWFHeR(O0GdygZMbD568fPtbZq8mJO7bcPdImwx85N5EAIS3IplP5iBW280OkLXGK4PZxBv11GkKn9hjzISjJoSqMg5KEnsPPHwlDizSYOjL8ioUMNCkuGwlDizSYOjL8yxZ)AgLVNMi7T4ZsAoYgSnpnQszmijgJOSqNyxTCPwCNjYMmQczt)rs(yghm4WorJrtKnzKcfVpnD8xew9eNX52xNXVpfkPPXkJgKzIBPDjb0jnMcLJ8XmA(RWnqy)6OjYMmsHI3NMokn4BxcTItVqgl7TIF)7PAuZbMIMOnn)EAIS3IplP5mOWk0LleIvQsttc(Rw48xQimkr6w058t5mJuYhZ4Gbh2jAmAISjJuOmDAASYi)ZWSLBWGd7engXY80Ou5rWFHrjs3IoNN0m3ttK9w8zjnNNExPJ(dNOsttISbBZtJrgJOSqNyxTCPwCNjYMmsHsAWbmJzZGUCDYgjMK3NMo6P3v6O)Wjr5hAzV190ezVfFwsZ5HqocF31GknnjYgSnpngzmIYcDID1YLAXDMiBYifkPbhWmMnd6Y1jBKysEFA6Ohc5i8Dxdr5hAzV190ezVfFwsZP7bcj3ru(YbgSsvAAsEFA64ViS6joEcXAije)(3t1CGhUeipHM(aeTP1hqy1bsypmGWdOqhWFtSY20hW7ttZv5aOjiCaTXZUgoWRzoahfBj5XdOWKTUv4q5biyq5beReLhiBg8ag)a2bsypmGWdK7bEJO)b68aq0KMNgJ3ttK9w8zjnNvcKNqt7eMwRsttISbBZtJrgJOSqNyxTCPwCNjYMmsHsAWbmJzZGUCDYgjM0RzUNMi7T4ZsAodkScD(FnhvPPjzISjJoSqMg5ZtsDkuuc(lmkr6w058KMze8xTW5VuryuI0TOZ5jnLpq57PjYEl(SKMJUHONExPknnjYgSnpngzmIYcDID1YLAXDMiBYifkPbhWmMnd6Y1jBKysEFA6iDdrp9UYO8dTS36EAIS3IplP58Sb3s7sylEZvPPj59PPJ)IWQN44jeRHKq87pYeztgDyHmnYj96EQMdqKM1vAD11WbMc0WVgR8apeTn8Xd08dyhWh2lSZj3ttK9w8zjn3(tpiAVvPPjj3msUHFnwPZxBdFmcrAiYjyEAC00PPXkJ)IWQN4809aHC00qRLoKmwz0KsEehxZt(90ezVfFwsZT)0dI2BvAAsYnJKB4xJv6812WhJqKgICcMNghzISjJoSqMg5Zts9rknDAASY4ViS6jopDpqiPqjnnwz8xew9eNNUhiKJe7QLl1k(lcREIZt3deYiezSU4kFpnr2BXNL0C7p9GO9wLMMe8xi9chWi)7JqEcTUgPKCZinC5PJgjJWiePHiNG5PrkuKBg907kD(AB4JrisdrobZtJkFpvZbEyr2BDa1Q5j)awjpGcRpwiKFaLuy9XcH85yrI4JLa5h4x8VV)ctuEGUoGjLBfv(EAIS3IplP5eMw7mr2B50npvPmgKuc76nM87PjYEl(SKMtyATZezVLt38uLYyqsILmwwL87PAoGjYEl(SKMJJeXhlbQsttYeztgDyHmnYj9A00s0scU3vpqiJYMBEA0zBkvPmgK06JfchVbzM4wAxsaDs0KJNg5jc7AWXty)ghpnYte21GJNW(no(Fry1tCE6EGqoE)n7TgV0GVDj0ko9czSS3A8M)km9eFoEpnr2BXNL0CctRDMi7TC6MNQugdssSRwUul(90ezVfFwsZb)LZezVLt38uLYyqs2IooMFFvAAsMiBYOdlKPr(8KuFKsID1YLAfLOLeCwjDsuytIqKX6It8RhmA600yLrjs3AKcfXUA5sTIsKU1yeImwxCIF9GrPPXkJsKU1OYJMwIwsWzL0jrHnjMT4Dxd3ttK9w8zjnh8xotK9woDZtvkJbjzl68(qEQsttYeztgDyHmnYNNK6JKOLeCwjDsuytIzlE31W90ezVfFwsZb)LZezVLt38uLYyqsdyHWw4SfvPPjzISjJoSqMg5Zts9rknTeTKGZkPtIcBsmBX7UggPKyxTCPwrjAjbNvsNef2KiezSU4Z)6bJMonnwzuI0TgPqrSRwUuROePBngHiJ1fF(xpyuAASYOePBnQSY3ttK9w8zjnNW0ANjYElNU5PkLXGKgWcHTqLMMKjYMm6WczAKt6198EQg1CGhEjsDGh)qEEpnr2BXJ2IoVpKNKKOLeCIT1Q00KuY7tth5FPelNCxMienrsHY0KnyBEAm6VRURbh8xTW5VurOYJuY7tthLg8TlHwXPxiJL9wXV)i4Vq6foGrjAsDJ80j2wpYeztgDyHmnYjMKcOqXeztgDyHmnYjPUY3ttK9w8OTOZ7d55SKMd9BjY0cvAAsWF1cN)sfHrjs3IojwPxpywjAjb37QhiKrAQ7VKO0LgCat(uOcuEKeTKG7D1deYin19xsu6sdoGjN4PC00KnyBEAm6VRURbh8xTW5VurifkEFA6iNQbz6AWX08m(9VNMi7T4rBrN3hYZzjnh63sKPfQ00KG)Qfo)LkcJsKUfDsS6ZmsIwsW9U6bczKM6(ljkDPbhWKp)mJMMSbBZtJr)D1Dn4G)Qfo)LkcVNMi7T4rBrN3hYZzjnh63sKPfQ00KMwIwsW9U6bczKM6(ljkDPbhWKpAAYgSnpng93v31Gd(Rw48xQiKcf6EGq6GiJ1fN4zOqbAT0HKXkJMuYJ44AEYhbTw6qYyLrtk5riYyDXjEM7PjYElE0w059H8CwsZrD)L0X9XsIW7PjYElE0w059H8CwsZH(TezAHknnPPjBW280y0FxDxdo4VAHZFPIW759unQ5ap8sK6aSy(9VNMi7T4rBrhhZVpjRM4KLuLMMKeTKG7D1deYin19xsu6sdoGjFEsIjcn6WczAKtHc0APdjJvgnPKhXX18KpcAT0HKXkJMuYJqKX6ItmPxVUNMi7T4rBrhhZV)SKMZQjozjvPPjjrlj4Ex9aHmstD)LeLU0GdyYNN0m3ttK9w8OTOJJ53FwsZjrlj4eBRvPPjnnzd2MNgJ(7Q7AWb)vlC(lveosjVpnDuAW3UeAfNEHmw2Bf)(JG)cPx4agLOj1nYtNyB9itKnz0HfY0iNyskGcftKnz0HfY0iNK6kFpnr2BXJ2IooMF)zjnh63sKPfQ00KMMSbBZtJr)D1Dn4G)Qfo)LkcVNMi7T4rBrhhZV)SKMJg5jc7AWXty)gvrmrOrxAWbm5KEPsttsIEFA6inYte21GJ6(lzKNM4nXKuWiXUA5sTIM)km9eFogHiJ1fNyfCpnr2BXJ2IooMF)zjnhnYte21GJNW(nQIyIqJU0GdyYj9sLMMKe9(00rAKNiSRbh19xYipnXBIFDpnr2BXJ2IooMF)zjnhnYte21GJNW(nQIyIqJU0GdyYj9sLMMe8xymBg0LRtHiwjXUA5sTIs0scoRKojkSjriYyDXhnDAASYOePBnsHIyxTCPwrjs3AmcrgRl(O00yLrjs3Au5759unQ5apKn7TUNMi7T4rXUA5sT4K83S3sLMMezd2MNgJmgrzHoXUA5sT4otKnzKcf6EGq6GiJ1fNy1NY7PAuZbi6D1YLAXVNMi7T4rXUA5sT4ZsAodYmXT0UKa6KOjvPPjj2vlxQv8xew9eNNUhiKriYyDXjEMrID1YLAfLg8TlHwXPxiJL9wriYyDXD448rrIsINzuAASY4ViS6jopDpqiPqz600yLXFry1tCE6EGqsHcDpqiDqKX6ItScM5EAIS3Ihf7QLl1IplP547x7GO5JqvsdoGPRPjLgCaZy2mOlxNViDkygINzuAWbmJzZGUCDYgNFM7PAoarfRwYpWJ6EGqEa6fEGV)bY9aZCaok2sYpqUhGpPehGANeoWd7VctpXNJQCaf2KacP2CuLd854bO2jHdO2g89bgdAfNEHmw2BfVNMi7T4rXUA5sT4ZsAUFry1tCE6EGqQsttISbBZtJrE681wvDnmsjXUA5sTIM)km9eFogHiJ1f3HJZhfjkjEgkue7QLl1kA(RW0t85yeImwxChooFuKOC(xpq5rkj2vlxQvuAW3UeAfNEHmw2BfHiJ1fN4bHKcfVpnDuAW3UeAfNEHmw2Bf)(kFpnr2BXJID1YLAXNL0C)IWQN4809aHuLMMKjYMm6WczAKppj1PqHUhiKoiYyDXjw9x3ttK9w8OyxTCPw8zjnN0GVDj0ko9czSS3sLMMezd2MNgJ805RTQ6AyKsYnJ)IWQN4809aH0j3mcrgRlofktNMgRm(lcREIZt3desLVNMi7T4rXUA5sT4ZsAoPbF7sOvC6fYyzVLknnjtKnz0HfY0iFEsQtHcDpqiDqKX6ItS6VUNMi7T4rXUA5sT4ZsAoZFfMEIphvPPjzISjJoSqMg5KEnsIEFA6inYte21GJ6(lzKNM498k4EAIS3Ihf7QLl1IplP5m)vy6j(CufXeHgDPbhWKt6LknnjtKnz0HfY0iFEsQpsIEFA6inYte21GJ6(lzKNM498ky00s0scoRKojkSjXSfV7A4EAIS3Ihf7QLl1IplP54FgMTCdgCyNOrvAAsWF1cN)sfHrjs3Ioj(LcnsjXUA5sTI)IWQN4809aHmcrgRloXVEafkYnJ)IWQN4809aH0j3mcrgRlUY3ttK9w8OyxTCPw8zjn3ViS6joJZTVovPPjr2GT5PXipD(ARQUggjrVpnDKg5jc7AWrD)LmYtt8My1hPKpMrZFfUbc7xhnr2Krku8(00rPbF7sOvC6fYyzVv87pAAFmJgKzIBGW(1rtKnzu57PjYElEuSRwUul(SKM7xew9eNX52xNQiMi0Oln4aMCsVuPPjzISjJoSqMg5Zts9rs07tthPrEIWUgCu3FjJ80eVjw97PjYElEuSRwUul(SKMdAnhDs0KQ00KM2hZ4aH9RJMiBY49unQ5aQDZnpnkv5aeLpppqT5bGOP1toqTqgtFapKGrUx4bscwQi)auxys4a(Fi)31Wb6Ak4GXGX7PAuZbmr2BXJID1YLAXNL0CCtaB6w0M25BIuLMMKjYMm6WczAKppj1hnT3NMokn4BxcTItVqgl7TIF)rtl2vlxQvuAW3UeAfNEHmw2BfHOjNqHcDpqiDqKX6It8GqEpVNQrnhGOxYyzvEGh2R1D2i)EAIS3IhflzSSk5K4unitxdoMMNQ00KiBW280yKNoFTvvxdJG)Qfo)LkcJsKUfDo)RPCKsID1YLAfn)vy6j(CmcrgRlofktNMgRmAqMjUL2LeqN0ykuosSRwUuRO0GVDj0ko9czSS3kcrgRlUYuOq3deshezSU4e)619unhGfZdK7b(C8agDIWdy(R4an)aBDaIwTpGXpqUhWhIKXkpWsgHcZ3VRHdmfFihGkHwJhGJz21Wb((hGOvBf53ttK9w8OyjJLvjFwsZXPAqMUgCmnpvPPjj2vlxQv08xHPN4ZXiezSU4JuYeztgDyHmnYNNK6Jmr2KrhwitJCIjnZi4VAHZFPIWOePBrNZ)6bZQKjYMm6WczAKpfoLktHIjYMm6WczAKp)mJG)Qfo)LkcJsKUfDoVc9aLVNMi7T4rXsglRs(SKMZ8wMUSS3YPBgpvAAsKnyBEAmYtNV2QQRHrtZ3V2RlzuJM05nXHJZy814iLe7QLl1kA(RW0t85yeImwxCkuMonnwz0GmtClTljGoPXuOCKyxTCPwrPbF7sOvC6fYyzVveImwxCLhb)fgZMbD56uO5vsbZ69PPJWF1cNyHWVF2BfHiJ1fxzkuO7bcPdImwxCIv)190ezVfpkwYyzvYNL0CM3Y0LL9woDZ4PsttISbBZtJrE681wvDnmIVFTxxYOgnPZBIdhNX4RXrkj3m(lcREIZt3desNCZiezSU4Z)6ffktNMgRm(lcREIZt3deYrID1YLAfLg8TlHwXPxiJL9wriYyDXv(EAIS3IhflzSSk5ZsAoZBz6YYElNUz8uPPjzISjJoSqMg5Zts9rWFHXSzqxUofAELuWSEFA6i8xTWjwi87N9wriYyDXv(EAIS3IhflzSSk5ZsAoobt8wJUKa6(f1fMeMOsttISbBZtJrE681wvDnmsjXUA5sTIM)km9eFogHiJ1fNcLPttJvgniZe3s7scOtAmfkhj2vlxQvuAW3UeAfNEHmw2BfHiJ1fxzkuO7bcPdImwxCIFnZ90ezVfpkwYyzvYNL0CCcM4TgDjb09lQlmjmrLMMKjYMm6WczAKppj1hPKeTKGZkPtIcBsmBX7UgOqbAT0HKXkJMuYJqKX6ItmPxkKY3Z7PAuZby7AqJhymdoG590ezVfpoGfcBbjjAjbNyBTknnjVpnDK)LsSCYDzIq0e5OPjBW280y0FxDxdo4VAHZFPIqku8XmoyWHDIgJMiBY490ezVfpoGfcBXSKMtIwsWj2wRsttc(Rw48xQimkr6w0jXVuafk09aH0brgRloXZmAAj69PPJ0ipryxdoQ7VKXV)90ezVfpoGfcBXSKMZQjozjvPPjj2vlxQv08xHPN4ZXiezSU4JuknnwzuI0TgJyzEAusHIyjJLvzS6bcPJ2qkuG)cPx4ag9jGgCz2c5kpsPPjBW280y0FxDxdo4Vqofk09aH0brgRloXZO890ezVfpoGfcBXSKMJ6(lPJ7JLeHQ00KKO3NMosJ8eHDn4OU)sg5PjEpVcgnnzd2MNgJ(7Q7AWb)fYVNMi7T4XbSqylML0Cu3FjDCFSKiuLMMKe9(00rAKNiSRbh19xY43FKyxTCPwrZFfMEIphJqKX6I7WX5JIeLZpZOPjBW280y0FxDxdo4Vq(90ezVfpoGfcBXSKMtIwsWj2wRsttc(Rw48xQimkr6w0jXQ)Grtt2GT5PXO)U6UgCWF1cN)sfH3ttK9w84awiSfZsAoAKNiSRbhpH9BuLMMKe9(00rAKNiSRbh19xYipnXBIFnAAYgSnpng93v31Gd(lKFpnr2BXJdyHWwmlP5OrEIWUgC8e2VrvAAss07tthPrEIWUgCu3FjJ80eVjwHgj2vlxQv08xHPN4ZXiezSU4oCC(OirjXZmAAYgSnpng93v31Gd(lKFpnr2BXJdyHWwmlP5KOLeCIT1Q00KMMSbBZtJr)D1Dn4G)Qfo)LkcVN3t1OMdqKJfcBXbE4Li1bEiWEHDo5EAIS3IhhWcHTWzlsIQ1PJEHoXUA5sTuPmgKeF)AhenFeQsttknnwzKVFTdIMpchLgCaZy2mOlxNViDkygINzeDpqiDqKX6Ip)mJe7QLl1kY3V2brZhHriYyDXjwPbHCk8brISzuEKjYMm6WczAKtmjfCpnr2BXJdyHWw4SfNL0Cs0scoX2AvAAsknnzd2MNgJ(7Q7AWb)vlC(lvesHI3NMoY)sjwo5UmriAIu5rk59PPJsd(2LqR40lKXYER43Fe8xi9chWOenPUrE6eBRhzISjJoSqMg5etsbuOyISjJoSqMg5Kux57PjYElECale2cNT4SKMd9BjY0cvAAsEFA6i)lLy5K7YeHOjskuMMSbBZtJr)D1Dn4G)Qfo)LkcVNMi7T4XbSqylC2IZsAoQ7VKoUpwseQIyIqJU0GdyYj9sLMMKsID1YLAfn)vy6j(CmcrgRl(8ZmsIEFA6inYte21GJ6(lz87tHIe9(00rAKNiSRbh19xYipnX75vGYJuIUhiKoiYyDXjwSRwUuROeTKGZkPtIcBseImwx8zF9akuO7bcPdImwx85f7QLl1kA(RW0t85yeImwxCLVNMi7T4XbSqylC2IZsAoAKNiSRbhpH9BufXeHgDPbhWKt6Lknnjj69PPJ0ipryxdoQ7VKrEAI3etsbJe7QLl1kA(RW0t85yeImwxCIvafks07tthPrEIWUgCu3FjJ80eVj(190ezVfpoGfcBHZwCwsZrJ8eHDn44jSFJQiMi0Oln4aMCsVuPPjj2vlxQv08xHPN4ZXiezSU4ZpZij69PPJ0ipryxdoQ7VKrEAI3e)6EEpvJAoWyWUEJj)EAIS3IhtyxVXKt6ZrxNiJkLXGK6IlG)080OJi(wLFgNej3cuLMMKsID1YLAf)fHvpX5P7bczeImwxCkue7QLl1kkn4BxcTItVqgl7TIqKX6IR8iL8XmAqMjUbc7xhnr2Krku8XmA(RWnqy)6OjYMmoA600yLrdYmXT0UKa6KgtHskusdoGzmBg0LRZxKo1FaXZOmfk09aH0brgRloXQ)6EAIS3IhtyxVXKplP5(C01jYOszmijgtyEq0XjGy6y(8wOsttsSRwUuRO5VctpXNJriYyDXjEMrknnse)23hLXU4c4pnpn6iIVv5NXjrYTaPqrSRwUuRyxCb8NMNgDeX3Q8Z4Ki5wGriYyDXvMcf6EGq6GiJ1fNy1FDpnr2BXJjSR3yYNL0CFo66ezuPmgKKeIMKUHOJmY5OwLMMKyxTCPwrZFfMEIphJqKX6IpsPPrI43((Om2fxa)P5Prhr8Tk)mojsUfifkID1YLAf7IlG)080OJi(wLFgNej3cmcrgRlUYuOq3deshezSU4eRG7PjYElEmHD9gt(SKM7ZrxNiJkLXGKKg8nZULtII3oYl0eDorLMMKyxTCPwrZFfMEIphJqKX6IpsPPrI43((Om2fxa)P5Prhr8Tk)mojsUfifkID1YLAf7IlG)080OJi(wLFgNej3cmcrgRlUYuOq3deshezSU4eR(R7PjYElEmHD9gt(SKM7ZrxNidxLMMKsID1YLAfn)vy6j(CmcrgRlofkEFA6O0GVDj0ko9czSS3k(9vEKstJeXV99rzSlUa(tZtJoI4Bv(zCsKClqkue7QLl1k2fxa)P5Prhr8Tk)mojsUfyeImwxCLdS2pjSWalBZ81w2Br0qJodzidba]] )

end
