-- DeathKnightUnholy.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local roundUp = ns.roundUp

local FindUnitBuffBySpellID = ns.FindUnitBuffBySpellID
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
                local cast = class.abilities.dark_transformation.lastCast or 0
                local up = pet.ghoul.up and cast + t.duration > state.query_time

                t.name = t.name or class.abilities.dark_transformation.name
                t.count = up and 1 or 0
                t.expires = up and cast + t.duration or 0
                t.applied = up and cast or 0
                t.caster = "player"
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
            copy = "unholy_blight_debuff"
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
                applyDebuff( "unholy_blight" )
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

        potion = "potion_of_unbridled_fury",

        package = "Unholy",
    } )


    spec:RegisterSetting( "festermight_cycle", false, {
        name = "Festermight: Spread |T237530:0|t Wounds",
        desc = function ()
            return  "If checked, the addon will encourage you to spread Festering Wounds to multiple targets before |T136144:0|t Death and Decay.\n\n" ..
                    "Requires |cFF" .. ( state.azerite.festermight.enabled and "00FF00" or "FF0000" ) .. "Festermight|r (Azerite)\n" ..
                    "Requires |cFF" .. ( state.settings.cycle and "00FF00" or "FF0000" ) .. "Recommend Target Swaps|r in |cFFFFD100Targeting|r section."
        end,
        type = "toggle",
        width = "full"
    } )


    spec:RegisterPack( "Unholy", 20201207.1, [[d8e5VbqifrpsrqxcPIytePpPQQrru5uivTkKGsVsvuZsbzxO6xksnmvHCmvvwMQKEgrvMMQqDnvj2MQa9nKkQXHeGZHeqRtvqZtrY9iI9PaoisGwOQipKOQMOQaUOIaAJkcK6JkcuJurGKtQiaRuvQxIeKyMkcDtKGK2Pc0prcIAOibflfPI0tjLPQG6QkceBfjiYxrccJfj0EL0FPQbd5Wuwmv6XKmzuUmyZq1NjvJwrDALwnsqQxJenBc3Mk2TOFl1WvOJJuHLJ45smDHRdLTJK(orz8iv68QkRhjOA(iL9RY1F1HRAmlG6GV(OxF0VxFeDM)Jo)OxRAX3iu1gnfLMou1sZbQAtqY5w8v1gTprBS6WvTsJruqvBoIXYdNEA9nMXC5Q2z6Y6GjSy7urm8y6Y6OMUQ5ITIyciRUvnMfqDWxF0Rp63RpIoZ)9GVqNFrEvTYiOQd(6lVw1MxgdYQBvJbfvvBcp0dawmFikuYvFoo0eKCUfF37j8qpaOahxGCi68qh61h96JU337j8quqgfASs4azuou0h6bYhy6haWxbm9dawmxo0dGbhk6d1P47qQglJdfgrhIYHKn3hYiWHa6ocQayhk6djwQWHeDQFiiBm95df9HCSiaYHKZAWxGaB8qt4p65vnXwIsD4QMoKazv1HRd(RoCvdsZvaS6tvnfzdGSwvZfdhNxWymi9SUD4eWuXHKEOjpevJSMRa4JDl2u3J3eVUr07pbCiA0o0ieCDJO3FcGBQyPcvntfBNvngyXSx1ROg1bFToCvdsZvaS6tvnfzdGSwvJGLRYp2YacNb4RAJdn1H(jVdj9qtEiQgznxbWh7wSPUhVjEDJO3FcOQzQy7SQXalM9QEf1OoO8Qdx1G0CfaR(uvtr2aiRv1uDlyTSKBJTYeFJfGtahBZYHKEi5ouycidodWxbWH0Cfa7q0ODivtfsldEU6ZHh3GdrJ2HiyjG3eDGpodgPD6ekCinxbWoe9vntfBNvnl)8SKvJ6GpUoCvdsZvaS6tvnfzdGSwvJbUy44CCOeaztDVSglz8sykkp0ah6XvntfBNvnznwY8LrizaPg1bFPoCvdsZvaS6tvnfzdGSwvJbUy44CCOeaztDVSglzCSXdj9qQUfSwwYTXwzIVXcWjGJTz5qdCOxoK0dj3HM8qHjGm4y5Cl(8UIvFo4qAUcGDiA0ouycidUrC(8nUpMbpZCsGXH0Cfa7q0ODivNmSn4QoP2kl2o9nUpMbpdmghsZvaSdrJ2Hi2Y8avidUXyfoq3TeLdrFvZuX2zvtwJLmFzesgqQrDWhSoCvdsZvaS6tvnfzdGSwvJbUy44CCOeaztDVSglzCSXdj9qHjGm4y5Cl(8UIvFo4qAUcGDiPhAYdfMaYGBeNpFJ7JzWZmNeyCinxbWoK0dn5Hi2Y8avidUXyfoq3TeLdj9qYDiv3cwll5y5Cl(8UIvFo4eWX2SCObo0lhs6HuDlyTSKBJTYeFJfGtaJ9DiPhAYdX6GJLZT4Z7kw95GtahBZYHOr7qtEiv3cwll52yRmX3yb4eWyFhI(QMPITZQMSglz(YiKmGuJ6G056WvninxbWQpv1uKnaYAvncwUk)yldiCgGVQno0uh61hDiPhAYdr1iR5ka(y3In194nXRBe9(tavntfBNvngyXSx1ROg1bPaQdx1G0CfaR(uvtr2aiRv1yGlgoohhkbq2u3lRXsgVeMIYdn1H(v1mvSDw1WHsaKn19LGSuc1OoifyD4QgKMRay1NQAkYgazTQgdCXWX54qjaYM6EznwY4LWuuEOPo0JpK0dP6wWAzj3gBLj(glaNao2MLdn1HK3HKEi5o0KhkmbKbhlNBXN3vS6ZbhsZvaSdrJ2HctazWnIZNVX9Xm4zMtcmoKMRayhIgTdP6KHTbx1j1wzX2PVX9Xm4zGX4qAUcGDiA0oeXwMhOczWngRWb6ULOCi6RAMk2oRA4qjaYM6(sqwkHAuh83JQdx1G0CfaR(uvtr2aiRv1yGlgoohhkbq2u3lRXsgVeMIYdn1HE8HKEOWeqgCSCUfFExXQphCinxbWoK0dn5HctazWnIZNVX9Xm4zMtcmoKMRayhs6HM8qeBzEGkKb3ySchO7wIYHKEiv3cwll52yRmX3yb4eWyFhs6HK7qQUfSwwYXY5w85DfR(CWjGJTz5qtDi5DiA0oedCXWX5y5Cl(8UIvFo8mWfdhNJnEi6RAMk2oRA4qjaYM6(sqwkHAuh83V6WvninxbWQpv1uKnaYAvTjpevJSMRa4JDl2u3J3eVUr07pbu1mvSDw1yGfZEvVIAuJQM1GVab2yD46G)Qdx1G0CfaR(uvtr2aiRv1yGfZEkZvFo44YASKbmFyeDikhAajhs9PeGhsWzHYHOr7qeBzEGkKb3ySchO7wIYHKEiITmpqfYGBmwHtahBZYHMsYH(9RQzQy7SQz5NNLSAuh816WvninxbWQpv1uKnaYAvngyXSNYC1NdoUSglzaZhgrhIYHgqYHEPQzQy7SQz5NNLSAuhuE1HRAqAUcGvFQQPiBaK1QAtEiQgznxbWh7wSPUhVjEDJO3FcOQzQy7SQbJldCwvnQd(46WvninxbWQpv1mvSDw1WHsaKn19LGSucvnfzdGSwvJbUy44CCOeaztDVSglz8sykkp0usoK8oK0dP6wWAzj3gBLj(glaNao2MLdn1HKxvt9PeGpmIoeL6G)QrDWxQdx1G0CfaR(uvZuX2zvdhkbq2u3xcYsju1uKnaYAvng4IHJZXHsaKn19YASKXlHPO8qtDOFvn1Nsa(Wi6quQd(Rg1bFW6WvninxbWQpv1mvSDw1WHsaKn19LGSucvnfzdGSwvJGLapwhWhT)XhAQdj3HuDlyTSKZalM9wY8mqzFCc4yBwoK0dn5HctazWza(kaoKMRayhIgTdP6wWAzjNb4Ra4eWX2SCiPhkmbKbNb4Ra4qAUcGDi6RAQpLa8Hr0HOuh8xnQrvt1uH0YOuhUo4V6WvninxbWQpv1uKnaYAvnQgznxbWlHFuyzUP(HKEicwUk)yldiCgGVQno0ah6bRAMk2oRAfzgXztDVZwIAuh816WvninxbWQpv1uKnaYAvnv3cwll52yRmX3yb4eWX2SCiPhsUdzQyPcEibNfkhAajh61dj9qMkwQGhsWzHYHMsYHE5qspeblxLFSLbeodWx1ghAGdj3HmvSubpKGZcLdrH9qp4HO)q0ODitflvWdj4Sq5qdCOxoK0drWYv5hBzaHZa8vTXHg4qY7rhI(QMPITZQwrMrC2u37SLOg1bLxD4QgKMRay1NQAkYgazTQgvJSMRa4LWpkSm3u)qsp0KhQ0yc3nzCbymV7NhOR5mkGdj9qQUfSwwYTXwzIVXcWjGJTz5qspeblbESoGpA)Jp0ahsUdjVd98HCXWX5eSCvEvtiyJX2jNao2MLdrFvZuX2zvZCBNnTy70lwh3Auh8X1HRAqAUcGvFQQPiBaK1QAunYAUcGxc)OWYCt9dj9qLgt4UjJlaJ5D)8aDnNrbCiPhsUdP6wWAzjhlNBXN3vS6ZbNao2MLdrJ2HM8qHjGm4y5Cl(8UIvFo4qAUcGDiPhs1TG1YsoZiu6dILf8M4yX2jNao2MLdrFvZuX2zvZCBNnTy70lwh3Auh8L6WvninxbWQpv1uKnaYAvntflvWdj4Sq5qdi5qVEiPhIGLapwhWhT)XhAGdj3HK3HE(qUy44CcwUkVQjeSXy7KtahBZYHOVQzQy7SQzUTZMwSD6fRJBnQd(G1HRAqAUcGvFQQPiBaK1QAunYAUcGxc)OWYCt9dj9qQUfSwwYTXwzIVXcWjGJTzPQzQy7SQvMnfLcWhZGhlL1Ky(Rg1bPZ1HRAqAUcGvFQQPiBaK1QAMkwQGhsWzHYHgqYHE9qspKChIbwm7TK5zGY(4XQOCt9drJ2Hi2Y8avidUXyfobCSnlhAkjh63Jpe9vntfBNvTYSPOua(yg8yPSMeZF1OgvTrcOAhxlQdxh8xD4QMPITZQ2yhBNvninxbWQpvJ6GVwhUQbP5kaw9PQwAoqvZOWlZgXkE8odFJ7hBzaPQzQy7SQzu4LzJyfpENHVX9JTmGuJ6GYRoCvZuX2zvJyBb8mWyvninxbWQpvJAu1uDlyTSSuhUo4V6WvninxbWQpv1uKnaYAvTri46grV)ea3uXsfoenAhYfdhNJLZT4ZBLIHjco24HOr7qHjGm4gX5Z34(yg8mZjbghsZvaSdj9qYDOri4gX5ZRp3ycUPILkCiA0o0ieCBSvE95gtWnvSuHdrJ2HuDlyTSKBeNpFJ7JzWZaJXjGJTz5qdCi8vFo8eWX2SCi6RAMk2oRAJDSDwJ6GVwhUQbP5kaw9PQMPITZQ2Mffblmxb4PdmldmhpdOUkOQPiBaK1QAYDiv3cwll5y5Cl(8UIvFo4eWX2SCiA0oKQBbRLLCMrO0hell4nXXITtobCSnlhI(dj9qYDOri4gX5ZRp3ycUPILkCiA0o0ieCBSvE95gtWnvSuHdj9qtEOWeqgCJ485BCFmdEM5KaJdP5ka2HOr7qHr0HGhRd4J2pQc)Rp6qtDOxoe9vT0CGQ2Mffblmxb4PdmldmhpdOUkOg1bLxD4QgKMRay1NQAMk2oRAoMYCjGVmdq4DWkRQQPiBaK1QAQUfSwwYTXwzIVXcWjGJTz5qtDOxoK0dj3HM8qaDGTJJaJVzrrWcZvaE6aZYaZXZaQRcoenAhs1TG1Ys(Mffblmxb4PdmldmhpdOUkGtahBZYHOVQLMdu1CmL5saFzgGW7GvwvnQd(46WvninxbWQpv1mvSDw1yeWy4lb8uHsbevnfzdGSwvt1TG1YsUn2kt8nwaobCSnlhs6HiyjWJ1b8r7F8HM6q6k2HKEi5o0KhcOdSDCey8nlkcwyUcWthywgyoEgqDvWHOr7qQUfSwwY3SOiyH5kapDGzzG54za1vbCc4yBwoe9vT0CGQgJagdFjGNkukGOg1bFPoCvdsZvaS6tvntfBNvnMrO0P70ZafLEQnXuB8v1uKnaYAvnv3cwll52yRmX3yb4eWX2SCiPhsUdn5Ha6aBhhbgFZIIGfMRa80bMLbMJNbuxfCiA0oKQBbRLL8nlkcwyUcWthywgyoEgqDvaNao2MLdrFvlnhOQXmcLoDNEgOO0tTjMAJVAuh8bRdx1G0CfaR(uvtr2aiRv1uDlyTSKBJTYeFJfGtahBZYHKEi5o0KhcOdSDCey8nlkcwyUcWthywgyoEgqDvWHOr7qQUfSwwY3SOiyH5kapDGzzG54za1vbCc4yBwoe9vntfBNvnSc43aCk1OoiDUoCvdsZvaS6tvnfzdGSwvJbUy44CCOeaztDVSglzCSXdj9qQUfSwwYXY5w85DfR(CWjGJTz5qtDi5DiPhs1TG1YsoZiu6dILf8M4yX2jNao2MLdn1HK3HKEOWeqgCSCUfFExXQphCinxbWoenAhAYdfMaYGJLZT4Z7kw95GdP5kawvZuX2zvZioF(g3hZGNbgRg1bPaQdx1G0CfaR(uvtr2aiRv1OAK1CfaVe(rHL5M6hs6HK7qQUfSwwYnIZNVX9Xm4zGX4eWX2SCObo0lhI(dj9qYDiv3cwll5mJqPpiwwWBIJfBNCc4yBwo0uhsxXoenAhYfdhNZmcL(GyzbVjowSDYXgpe9hs6HK7qtEicwc4nrh4mWyIfkHx1RGdP5ka2HOr7qtEOWeqgCJ485BCFmdEM5KaJdP5ka2HOr7qQozyBWvDsTvwSD6BCFmdEgymoXskp0uh6LdrFvZuX2zvdlNBXN3vS6ZrnQdsbwhUQbP5kaw9PQMISbqwRQr1iR5kaEj8JclZn1pK0dj3HuDlyTSKBeNpFJ7JzWZaJXjGJTz5qdCOxoe9hs6HiyjG3eDGZaJjwOeEvVcoKMRayhs6HctazWnIZNVX9Xm4zMtcmoKMRayhs6HuDYW2GR6KARSy7034(yg8mWyCILuEObKCOxoK0dP6wWAzj3gBLj(glaNao2MLdn1HKxvZuX2zvdlNBXN3vS6ZrnQd(7r1HRAqAUcGvFQQPiBaK1QAMkwQGhsWzHYHgqYHETQzQy7SQHLZT4Z7kw95Og1b)9RoCvdsZvaS6tvnfzdGSwvJQrwZva8s4hfwMBQFiPhsUdXaxmCCowo3IpVRy1NdpdCXWX5yJhIgTdn5HctazWXY5w85DfR(CWH0Cfa7q0x1mvSDw1ygHsFqSSG3ehl2oRrDWFVwhUQbP5kaw9PQMISbqwRQzQyPcEibNfkhAajh61QMPITZQgZiu6dILf8M4yX2znQd(tE1HRAqAUcGvFQQPiBaK1QAMkwQGhsWzHYHKCOFhs6HyGlgoohhkbq2u3lRXsgVeMIYdnGKd94dj9qHjGm4y5Cl(8UIvFo4qAUcGDiPhkmbKb3ioF(g3hZGNzojW4qAUcGDiPhIGLaEt0bodmMyHs4v9k4qAUcGDiPhs1jdBdUQtQTYITtFJ7JzWZaJXjws5HgqYHEPQzQy7SQzJTYeFJfOg1b)946WvninxbWQpv1uKnaYAvntflvWdj4Sq5qso0Vdj9qmWfdhNJdLaiBQ7L1yjJxctr5HgqYHE8HKEOWeqgCSCUfFExXQphCinxbWoK0dj3HctazWXY5w85TsXWebhsZvaSdj9qQozyBWvDsTvwSD6BCFmdEgymoXskp0uh6LdrJ2HctazW1nIE)jaoKMRayhI(QMPITZQMn2kt8nwGAuh83l1HRAqAUcGvFQQPiBaK1QAMkwQGhsWzHYHKCOFhs6HyGlgoohhkbq2u3lRXsgVeMIYdnGKd94dj9qYDOjpuycidowo3IpVRy1NdoKMRayhIgTdfMaYGBeNpFJ7JzWZmNeyCinxbWoK0dn5HiyjG3eDGZaJjwOeEvVcoKMRayhIgTdP6KHTbx1j1wzX2PVX9Xm4zGX4elP8qtDOxoenAhkmbKbhlNBXN3kfdteCinxbWoK0dP6KHTbx1j1wzX2PVX9Xm4zGX4elP8qdi5qVCi6RAMk2oRA2yRmX3ybQrDWFpyD4QgKMRay1NQAMk2oRA2yRmX3ybQAkYgazTQMPILk4HeCwOCObKCOxpK0dXaxmCCooucGSPUxwJLmEjmfLhAajh6Xhs6HM8qmWIzVLmpdu2hpwfLBQx1uFkb4dJOdrPo4VAuh8hDUoCvdsZvaS6tvnfzdGSwvJGLRYp2YacNb4RAJdn1H(94QMPITZQwbZXPtVUr07pbuJ6G)OaQdx1G0CfaR(uvtr2aiRv1OAK1CfaVe(rHL5M6hs6HyGlgoohhkbq2u3lRXsgVeMIYdn1HE9qspKChAecUn2kV(CJj4MkwQWHOr7qQozyBWvDsTvwSD6BCFmdEgymoKMRayhs6HCXWX5mJqPpiwwWBIJfBNCSXdj9qtEOri4gX5ZRp3ycUPILkCi6RAMk2oRAy5Cl(8wPyyIOg1b)rbwhUQbP5kaw9PQMPITZQgwo3IpVvkgMiQAkYgazTQMPILk4HeCwOCObKCOxpK0dXaxmCCooucGSPUxwJLmEjmfLhAQd9Avt9PeGpmIoeL6G)QrDWxFuD4QgKMRay1NQAMk2oRALgt4jGncKQMISbqwRQfgrhcESoGpA)Ok8Y7Ldn1HE5qspuyeDi4X6a(O9Sfo0ah6LQM6tjaFyeDik1b)vJ6GV(RoCvdsZvaS6tvnfzdGSwvBYdncbxFUXeCtflvOQzQy7SQrSTaEgySAuh81xRdx1G0CfaR(uvtr2aiRv1mvSubpKGZcLdnGKd96HKEOjpKlgooNzek9bXYcEtCSy7KJnEiPhAYdP6wWAzjNzek9bXYcEtCSy7KtaJ9v1mvSDw1kMIS4RAnHF0urnQrvthsGSkV1qD46G)Qdx1G0CfaR(uvtr2aiRv1CXWX5fmgdspRBhobmvu1mvSDw1GXLboRQg1bFToCvdsZvaS6tvnfzdGSwvBYdr1iR5ka(y3In194nXRBe9(tavntfBNvnyCzGZQQrDq5vhUQbP5kaw9PQMPITZQMSglz(YiKmGu1uKnaYAvn5oKQBbRLLCBSvM4BSaCc4yBwo0ah6Ldj9qmWfdhNJdLaiBQ7L1yjJJnEiA0oedCXWX54qjaYM6EznwY4LWuuEObo0Jpe9hs6HK7q4R(C4jGJTz5qtDiv3cwll5mWIzVLmpdu2hNao2MLd98H(9OdrJ2HWx95WtahBZYHg4qQUfSwwYTXwzIVXcWjGJTz5q0x1uFkb4dJOdrPo4VAuh8X1HRAqAUcGvFQQzQy7SQHdLaiBQ7lbzPeQAkYgazTQgdCXWX54qjaYM6EznwY4LWuuEOPKCi5DiPhs1TG1YsUn2kt8nwaobCSnlhAQdjVdrJ2HyGlgoohhkbq2u3lRXsgVeMIYdn1H(v1uFkb4dJOdrPo4VAuh8L6WvninxbWQpv1mvSDw1WHsaKn19LGSucvnfzdGSwvt1TG1YsUn2kt8nwaobCSnlhAGd9YHKEig4IHJZXHsaKn19YASKXlHPO8qtDOFvn1Nsa(Wi6quQd(Rg1OQzn4DXiLOoCDWF1HRAqAUcGvFQQPiBaK1QAeSCv(Xwgq4maFvBCOPoKCh63Jo0ZhIbwm7Pmx95GJlRXsgW8Hr0HOCikShsEhI(dj9qmWIzpL5QphCCznwYaMpmIoeLdn1HEWdj9qtEiQgznxbWh7wSPUhVjEDJO3Fc4q0ODixmCCErMrC2u37SLGJnw1mvSDw1GXLboRQg1bFToCvdsZvaS6tvnfzdGSwvJGLRYp2YacNb4RAJdn1HE9Ldj9qmWIzpL5QphCCznwYaMpmIoeLdnWHE5qsp0KhIQrwZva8XUfBQ7XBIx3i69NaQAMk2oRAW4YaNvvJ6GYRoCvdsZvaS6tvnfzdGSwvBYdXalM9uMR(CWXL1yjdy(Wi6quoK0dn5HOAK1CfaFSBXM6E8M41nIE)jGdrJ2HWx95WtahBZYHM6qVCiA0oeXwMhOczWngRWb6ULOCiPhIylZduHm4gJv4eWX2SCOPo0lvntfBNvnyCzGZQQrDWhxhUQzQy7SQjRXsMVmcjdivninxbWQpvJ6GVuhUQbP5kaw9PQMISbqwRQn5HOAK1CfaFSBXM6E8M41nIE)jGQMPITZQgmUmWzv1OgvngGByIOoCDWF1HRAMk2oRAoBY84eaOWHQgKMRay1NQrDWxRdx1G0CfaR(uvRhRAfiQAMk2oRAunYAUcOQr1eyqvt1TG1YsEbZXPtVUr07pbWjGJTz5qtDOxoK0dfMaYGxWCC60RBe9(taCinxbWQAunIpnhOQn2TytDpEt86grV)eqnQdkV6WvninxbWQpv16XQwbIQMPITZQgvJSMRaQAunbgu1mvSubpKGZcLdj5q)oK0dj3HM8qeBzEGkKb3ySchO7wIYHOr7qeBzEGkKb3yScFZdnWH(9YHOVQr1i(0CGQwj8JclZn1RrDWhxhUQbP5kaw9PQMISbqwRQrWYv5hBzaHZa8vTXHg4qp4lhs6HK7qJqW1nIE)jaUPILkCiA0o0KhkmbKbVG540Px3i69Na4qAUcGDi6pK0drWsGZa8vTXHgqYHEPQzQy7SQzeLLGpAcbYOg1bFPoCvdsZvaS6tvnfzdGSwvBecUUr07pbWnvSuHdrJ2HCXWX5y5Cl(8wPyyIGJnEiA0ouycidUrC(8nUpMbpZCsGXH0Cfa7qsp0ieCBSvE95gtWnvSuHdj9qYDOri4gX5ZRp3ycUPILkCiA0oKQBbRLLCJ485BCFmdEgymobCSnlhAGdP6wWAzj3v0nZJJr(4mmIfBNhA6djVdr)HOr7q4R(C4jGJTz5qtj5qUy44Cxr3mpog5JZWiwSDw1mvSDw1CfDZ84yKVAuh8bRdx1G0CfaR(uvtr2aiRv1gHGRBe9(taCtflv4q0ODixmCCowo3IpVvkgMi4yJhIgTdfMaYGBeNpFJ7JzWZmNeyCinxbWoK0dncb3gBLxFUXeCtflv4qspKChAecUrC(86ZnMGBQyPchIgTdP6wWAzj3ioF(g3hZGNbgJtahBZYHg4qQUfSwwYDbsbiuUPoNHrSy78qtFi5Di6penAhcF1NdpbCSnlhAkjhYfdhN7cKcqOCtDodJyX2zvZuX2zvZfifGq5M61OoiDUoCvdsZvaS6tvnfzdGSwvZfdhNJLZT4ZxccK6XmhBSQzQy7SQjw95O4PqJX0DGmQrDqkG6WvninxbWQpv1uKnaYAvTri46grV)ea3uXsfoenAhYfdhNJLZT4ZBLIHjco24HOr7qHjGm4gX5Z34(yg8mZjbghsZvaSdj9qJqWTXw51NBmb3uXsfoK0dj3HgHGBeNpV(CJj4MkwQWHOr7qQUfSwwYnIZNVX9Xm4zGX4eWX2SCOboKQBbRLLClvqjiMWRmHGZWiwSDEOPpK8oe9hIgTdHV6ZHNao2MLdnLKd97LQMPITZQMLkOeet4vMquJ6GuG1HRAqAUcGvFQQPiBaK1QAMkwQGhsWzHYHgqYHE9q0ODi5oeblbodWx1ghAajh6Ldj9qeSCv(Xwgq4maFvBCObKCOh8rhI(QMPITZQMruwc(rmrbQrDWFpQoCvdsZvaS6tvnfzdGSwvBecUUr07pbWnvSuHdrJ2HCXWX5y5Cl(8wPyyIGJnEiA0ouycidUrC(8nUpMbpZCsGXH0Cfa7qsp0ieCBSvE95gtWnvSuHdj9qYDOri4gX5ZRp3ycUPILkCiA0oKQBbRLLCJ485BCFmdEgymobCSnlhAGdP6wWAzjhFjGROBgNHrSy78qtFi5Di6penAhcF1NdpbCSnlhAkjhYfdhNJVeWv0nJZWiwSDw1mvSDw1Wxc4k6MvJ6G)(vhUQbP5kaw9PQMISbqwRQ5IHJZXY5w85lbbs9yMJnEiPhYuXsf8qcoluoKKd9RQzQy7SQ5A6(g3hKvrzPg1b)9AD4QgKMRay1NQAkYgazTQgRdo1LGjGm8Jcthd4eaNaLzZvahs6HM8qHjGm4y5Cl(8UIvFo4qAUcGDiPhAYdrSL5bQqgCJXkCGUBjkvntfBNvTglCjGrznQd(tE1HRAqAUcGvFQQPiBaK1QASo4uxcMaYWpkmDmGtaCcuMnxbCiPhsUdn5HctazWXY5w85DfR(CWH0Cfa7q0ODOWeqgCSCUfFExXQphCinxbWoK0dP6wWAzjhlNBXN3vS6ZbNao2MLdr)HKEitflvWdj4Sq5qdi5qVw1mvSDw1ASWLagL1Oo4VhxhUQbP5kaw9PQMISbqwRQrWsaVj6aVGncKsqSn5qAUcGDiPhsUdX6GJt6s4XbQaHtaCcuMnxbCiA0oeRdUROBMFuy6yaNa4eOmBUc4q0x1mvSDw1ASWLagL1Oo4VxQdx1G0CfaR(uvZuX2zvtzcH3uX2PxSLOQj2s4tZbQAQMkKwgLAuh83dwhUQbP5kaw9PQMPITZQMYecVPITtVylrvtSLWNMdu1uDlyTSSuJ6G)OZ1HRAqAUcGvFQQPiBaK1QAMkwQGhsWzHYHgqYHE9qspKChs1TG1YsodSy2BjZZaL9XjGJTz5qtDOFp6qsp0KhkmbKbNb4Ra4qAUcGDiA0oKQBbRLLCgGVcGtahBZYHM6q)E0HKEOWeqgCgGVcGdP5ka2HO)qsp0KhIbwm7TK5zGY(4XQOCt9QMPITZQgbl9Mk2o9ITevnXwcFAoqvZAWxGaBSg1b)rbuhUQbP5kaw9PQMISbqwRQzQyPcEibNfkhAajh61dj9qmWIzVLmpdu2hpwfLBQx1mvSDw1iyP3uX2PxSLOQj2s4tZbQAwdExmsjQrDWFuG1HRAqAUcGvFQQPiBaK1QAMkwQGhsWzHYHgqYHE9qspKChAYdXalM9wY8mqzF8yvuUP(HKEi5oKQBbRLLCgyXS3sMNbk7JtahBZYHg4q)E0HKEOjpuycidodWxbWH0Cfa7q0ODiv3cwll5maFfaNao2MLdnWH(9Odj9qHjGm4maFfahsZvaSdr)HOVQzQy7SQrWsVPITtVylrvtSLWNMdu10HeiRYBnuJ6GV(O6WvninxbWQpv1uKnaYAvntflvWdj4Sq5qso0VQMPITZQMYecVPITtVylrvtSLWNMdu10HeiRQg1OgvnQaPSDwh81h96J(96JOZvnzgj3uVu1OqqbPthCcyWj4hEOdn8mCO1zSjXHWBYH(Rdjqw1)dra6aBja7qL2boKHfTJfa7qQzl1Hc)EpXnHdjVhEi53jvGea7q)jyjG3eDGtX)hk6d9NGLaEt0bof5qAUcG9)qY9JU0ZV3tCt4qV8Wdj)oPcKayh6Fycidof)FOOp0)WeqgCkYH0Cfa7)HK7v6sp)EpXnHd9YdpK87KkqcGDO)QozyBWP4)df9H(R6KHTbNICinxbW(Fi5(rx6537jUjCOh8Hhs(DsfibWo0)WeqgCk()qrFO)HjGm4uKdP5ka2)dj3R0LE(9EIBchIc8Hhs(DsfibWo0)WeqgCk()qrFO)HjGm4uKdP5ka2)dj3R0LE(9EIBchIc8Hhs(DsfibWo0FvNmSn4u8)HI(q)vDYW2GtroKMRay)pKC)Ol9879e3eo0Vh9Wdj)oPcKayh6Fycidof)FOOp0)WeqgCkYH0Cfa7)HK7v6sp)EFVPqqbPthCcyWj4hEOdn8mCO1zSjXHWBYH(Bn4lqGn()qeGoWwcWouPDGdzyr7ybWoKA2sDOWV3tCt4qp4dpK87KkqcGDO)HjGm4u8)HI(q)dtazWPihsZvaS)hsUxPl98799McbfKoDWjGbNGF4Ho0WZWHwNXMehcVjh6pdWnmr8)qeGoWwcWouPDGdzyr7ybWoKA2sDOWV3tCt4qV(Wdj)oPcKayh6Fycidof)FOOp0)WeqgCkYH0Cfa7)HS4qtGuipXdj3p6sp)EpXnHd9YdpK87KkqcGDiT1r(hQ8LHr3drNCOOp0eXSdXwQBz78q9iqSOjhsUPP)qY9JU0ZV3tCt4qV8Wdj)oPcKayh6Fycidof)FOOp0)WeqgCkYH0Cfa7)HK7hDPNFVN4MWHEWhEi53jvGea7qARJ8pu5ldJUhIo5qrFOjIzhITu3Y25H6rGyrtoKCtt)HK7hDPNFVN4MWHEWhEi53jvGea7q)dtazWP4)df9H(hMaYGtroKMRay)pKC)Ol9879e3eoefWdpK87KkqcGDiT1r(hQ8LHr3drNCOOp0eXSdXwQBz78q9iqSOjhsUPP)qY9JU0ZV3tCt4quap8qYVtQaja2H(hMaYGtX)hk6d9pmbKbNICinxbW(Fi5(rx6537jUjCOFp6Hhs(DsfibWoK26i)dv(YWO7HOtou0hAIy2Hyl1TSDEOEeiw0Kdj300Fi5(rx6537jUjCOFp6Hhs(DsfibWo0)WeqgCk()qrFO)HjGm4uKdP5ka2)dj3p6sp)EpXnHd971hEi53jvGea7q)dtazWP4)df9H(hMaYGtroKMRay)pKC)Ol9879e3eo0p59Wdj)oPcKayh6Fycidof)FOOp0)WeqgCkYH0Cfa7)HK7v6sp)EpXnHd97Xp8qYVtQaja2H(tWsaVj6aNI)pu0h6pblb8MOdCkYH0Cfa7)HK7hDPNFVN4MWH(rNF4HKFNubsaSd9pmbKbNI)pu0h6Fycidof5qAUcG9)qY9kDPNFVN4MWH(rb(Wdj)oPcKayh6Fycidof)FOOp0)WeqgCkYH0Cfa7)HK7v6sp)EFVPqqbPthCcyWj4hEOdn8mCO1zSjXHWBYH(R6wWAzz5)HiaDGTeGDOs7ahYWI2XcGDi1SL6qHFVN4MWH(9Wdj)oPcKayh6Fycidof)FOOp0)WeqgCkYH0Cfa7)HK7hDPNFVN4MWHE9Hhs(DsfibWo0)WeqgCk()qrFO)HjGm4uKdP5ka2)dj3p6sp)EpXnHdrNF4HKFNubsaSd9pmbKbNI)pu0h6Fycidof5qAUcG9)qY9JU0ZV3tCt4q05hEi53jvGea7q)dtazWP4)df9H(hMaYGtroKMRay)pKfhAcKc5jEi5(rx6537jUjCikGhEi53jvGea7q)dtazWP4)df9H(hMaYGtroKMRay)pKC)Ol9879e3eoefWdpK87KkqcGDO)eSeWBIoWP4)df9H(tWsaVj6aNICinxbW(Fi5(rx6537jUjCikWhEi53jvGea7q)dtazWP4)df9H(hMaYGtroKMRay)pKC)Ol9879e3eoef4dpK87KkqcGDO)eSeWBIoWP4)df9H(tWsaVj6aNICinxbW(Fi5(rx6537jUjCOF)E4HKFNubsaSd9pmbKbNI)pu0h6Fycidof5qAUcG9)qY9JU0ZV3tCt4q)K3dpK87KkqcGDO)HjGm4u8)HI(q)dtazWPihsZvaS)hsUxPl9879e3eo0p59Wdj)oPcKayh6pblb8MOdCk()qrFO)eSeWBIoWPihsZvaS)hsUF0LE(9EIBch63JF4HKFNubsaSd9pmbKbNI)pu0h6Fycidof5qAUcG9)qYjp6sp)EpXnHd97LhEi53jvGea7q)dtazWP4)df9H(hMaYGtroKMRay)pKCYJU0ZV3tCt4q)E5Hhs(DsfibWo0Fcwc4nrh4u8)HI(q)jyjG3eDGtroKMRay)pKC)Ol9879e3eo0pkGhEi53jvGea7q)vDYW2GtX)hk6d9x1jdBdof5qAUcG9)qY9JU0ZV33Bkeuq60bNagCc(Hh6qdpdhADgBsCi8MCO)QMkKwgL)hIa0b2sa2HkTdCidlAhla2HuZwQdf(9EIBch6Xp8qYVtQaja2H(hMaYGtX)hk6d9pmbKbNICinxbW(Fi5(rx653779eGZytcGDikGdzQy78qITef(9UQnsA8vavTj8qpayX8HOqjx954qtqY5w8DVNWd9aGcCCbYHOZdDOxF0Rp6EFVNWdrbzuOXkHdKr5qrFOhiFGPFaaFfW0payXC5qpagCOOpuNIVdPASmouyeDikhs2CFiJahcO7iOcGDOOpKyPchs0P(HGSX0Npu0hYXIaihsoRbFbcSXdnH)ONFVV3Mk2ol8rcOAhxlEwY0JDSDEVnvSDw4Jeq1oUw8SKPXkGFdWzO0CajgfEz2iwXJ3z4BC)yldi3BtfBNf(ibuTJRfplzAITfWZaJDVV3t4HMaPlOWcGDiGkq(ouSoWHIz4qMkAYH2YHmQ2kmxbWV3Mk2olsC2K5XjaqHd37j8quizK1Cfq5EBQy7S8SKPPAK1CfWqP5asg7wSPUhVjEDJO3FcyiQMadKO6wWAzjVG540Px3i69Na4eWX2Sm1lsdtazWlyooD61nIE)jG7TPITZYZsMMQrwZvadLMdiPe(rHL5M6dr1eyGetflvWdj4SqrYpPYnjXwMhOczWngRWb6ULOqJgXwMhOczWngRW3CGFVq)9EcpeDQPwtuU3Mk2olplzAJOSe8rtiqgdT4siy5Q8JTmGWza(Q2yGh8fPYncbx3i69Na4MkwQanAtgMaYGxWCC60RBe9(taCinxbWOxkblbodWx1gdi5L7TPITZYZsM2v0nZJJr(gAXLmcbx3i69Na4MkwQanAUy44CSCUfFERummrWXgPrlmbKb3ioF(g3hZGNzojWKocb3gBLxFUXeCtflvqQCJqWnIZNxFUXeCtflvGgnv3cwll5gX5Z34(yg8mWyCc4yBwgq1TG1YsUROBMhhJ8Xzyel2oPtKh90OHV6ZHNao2MLPK4IHJZDfDZ84yKpodJyX2592uX2z5zjt7cKcqOCt9HwCjJqW1nIE)jaUPILkqJMlgoohlNBXN3kfdteCSrA0ctazWnIZNVX9Xm4zMtcmPJqWTXw51NBmb3uXsfKk3ieCJ4851NBmb3uXsfOrt1TG1YsUrC(8nUpMbpdmgNao2MLbuDlyTSK7cKcqOCtDodJyX2jDI8ONgn8vFo8eWX2SmLexmCCUlqkaHYn15mmIfBN3BtfBNLNLmTy1NJINcngt3bYyOfxIlgoohlNBXNVeei1Jzo249EcpefmvqjiM4qY3eIdPS8qbz11bYHE8Hg7aYynXHCXWXldDiWuZhsyLyt9d97LdvavNSc)qtqIvSu4a7qZgHDivZa2HI1boKvoKDOGS66a5qrFikby8qBCicymZva87TPITZYZsM2sfucIj8ktigAXLmcbx3i69Na4MkwQanAUy44CSCUfFERummrWXgPrlmbKb3ioF(g3hZGNzojWKocb3gBLxFUXeCtflvqQCJqWnIZNxFUXeCtflvGgnv3cwll5gX5Z34(yg8mWyCc4yBwgq1TG1YsULkOeet4vMqWzyel2oPtKh90OHV6ZHNao2MLPK87L7TPITZYZsM2iklb)iMOadT4smvSubpKGZcLbK8knAYrWsGZa8vTXasErkblxLFSLbeodWx1gdi5bFe93BtfBNLNLmn(saxr3SHwCjJqW1nIE)jaUPILkqJMlgoohlNBXN3kfdteCSrA0ctazWnIZNVX9Xm4zMtcmPJqWTXw51NBmb3uXsfKk3ieCJ4851NBmb3uXsfOrt1TG1YsUrC(8nUpMbpdmgNao2MLbuDlyTSKJVeWv0nJZWiwSDsNip6PrdF1NdpbCSnltjXfdhNJVeWv0nJZWiwSDEVnvSDwEwY0UMUVX9bzvuwgAXL4IHJZXY5w85lbbs9yMJnk1uXsf8qcoluK87EpHhIcvBZW2Ct9drH0sWeqghIcJW0XGdTLdzhAKSnzJV7TPITZYZsMUXcxcyuo0IlH1bN6sWeqg(rHPJbCcGtGYS5kaPtgMaYGJLZT4Z7kw95q6KeBzEGkKb3ySchO7wIY92uX2z5zjt3yHlbmkhAXLW6GtDjycid)OW0XaobWjqz2CfGu5MmmbKbhlNBXN3vS6ZbnAHjGm4y5Cl(8UIvFoKQ6wWAzjhlNBXN3vS6ZbNao2Mf6LAQyPcEibNfkdi517TPITZYZsMUXcxcyuo0IlHGLaEt0bEbBeiLGyBkvowhCCsxcpoqfiCcGtGYS5kaA0yDWDfDZ8Jcthd4eaNaLzZva0FVNWdrbvX25HM4wIY92uX2z5zjtRmHWBQy70l2smuAoGevtfslJY92uX2z5zjtRmHWBQy70l2smuAoGev3cwlll3BtfBNLNLmnbl9Mk2o9ITedLMdiXAWxGaBCOfxIPILk4HeCwOmGKxLkNQBbRLLCgyXS3sMNbk7JtahBZYu)EK0jdtazWza(kaA0uDlyTSKZa8vaCc4yBwM63JKgMaYGZa8va0lDsgyXS3sMNbk7JhRIYn1V3Mk2olplzAcw6nvSD6fBjgknhqI1G3fJuIHwCjMkwQGhsWzHYasEvkdSy2BjZZaL9XJvr5M63BtfBNLNLmnbl9Mk2o9ITedLMdirhsGSkV1WqlUetflvWdj4SqzajVkvUjzGfZElzEgOSpESkk3uxQCQUfSwwYzGfZElzEgOSpobCSnld87rsNmmbKbNb4RaOrt1TG1YsodWxbWjGJTzzGFpsAycidodWxbqp93BtfBNLNLmTYecVPITtVylXqP5as0HeiRAOfxIPILk4HeCwOi539(EpHhIc2tGh6jmsjU3Mk2olCRbVlgPesGXLboRAOfxcblxLFSLbeodWx1gtj3Vh9mdSy2tzU6ZbhxwJLmG5dJOdrHcR8OxkdSy2tzU6ZbhxwJLmG5dJOdrzQhu6KunYAUcGp2TytDpEt86grV)eanAUy448ImJ4SPU3zlbhB8EBQy7SWTg8UyKs8SKPHXLboRAOfxcblxLFSLbeodWx1gt96lszGfZEkZvFo44YASKbmFyeDikd8I0jPAK1CfaFSBXM6E8M41nIE)jG7TPITZc3AW7IrkXZsMggxg4SQHwCjtYalM9uMR(CWXL1yjdy(Wi6quKojvJSMRa4JDl2u3J3eVUr07pbqJg(QphEc4yBwM6fA0i2Y8avidUXyfoq3TefPeBzEGkKb3yScNao2MLPE5EBQy7SWTg8UyKs8SKPL1yjZxgHKbK7TPITZc3AW7IrkXZsMggxg4SQHwCjts1iR5ka(y3In194nXRBe9(ta3779eEikypbEiniWgV3Mk2olCRbFbcSrjw(5zjBOfxcdSy2tzU6ZbhxwJLmG5dJOdrzajQpLa8qcoluOrJylZduHm4gJv4aD3suKsSL5bQqgCJXkCc4yBwMsYVF3BtfBNfU1GVab24ZsM2YpplzdT4syGfZEkZvFo44YASKbmFyeDikdi5L7TPITZc3AWxGaB8zjtdJldCw1qlUKjPAK1CfaFSBXM6E8M41nIE)jG7TPITZc3AWxGaB8zjtJdLaiBQ7lbzPegs9PeGpmIoefj)gAXLWaxmCCooucGSPUxwJLmEjmfLtjrEsvDlyTSKBJTYeFJfGtahBZYuY7EBQy7SWTg8fiWgFwY04qjaYM6(sqwkHHuFkb4dJOdrrYVHwCjmWfdhNJdLaiBQ7L1yjJxctr5u)U3Mk2olCRbFbcSXNLmnoucGSPUVeKLsyi1Nsa(Wi6quK8BOfxcblbESoGpA)JNsov3cwll5mWIzVLmpdu2hNao2MfPtgMaYGZa8va0OP6wWAzjNb4Ra4eWX2SinmbKbNb4RaO)EFVNWdrHPJTZYHSKDOoMbYH68qyf4EBQy7SWvDlyTSSizSJTZHwCjJqW1nIE)jaUPILkqJMlgoohlNBXN3kfdteCSrA0ctazWnIZNVX9Xm4zMtcmPYncb3ioFE95gtWnvSubA0gHGBJTYRp3ycUPILkqJMQBbRLLCJ485BCFmdEgymobCSnldGV6ZHNao2Mf6V3Mk2olCv3cwlllplzASc43aCgknhqYMffblmxb4PdmldmhpdOUkyOfxICQUfSwwYXY5w85DfR(CWjGJTzHgnv3cwll5mJqPpiwwWBIJfBNCc4yBwOxQCJqWnIZNxFUXeCtflvGgTri42yR86ZnMGBQyPcsNmmbKb3ioF(g3hZGNzojWOrlmIoe8yDaF0(rv4F9rt9c93BtfBNfUQBbRLLLNLmnwb8BaodLMdiXXuMlb8LzacVdwzvdT4suDlyTSKBJTYeFJfGtahBZYuVivUjb6aBhhbgFZIIGfMRa80bMLbMJNbuxfqJMQBbRLL8nlkcwyUcWthywgyoEgqDvaNao2Mf6V3Mk2olCv3cwlllplzASc43aCgknhqcJagdFjGNkukGyOfxIQBbRLLCBSvM4BSaCc4yBwKsWsGhRd4J2)4P0vmPYnjqhy74iW4BwueSWCfGNoWSmWC8mG6QaA0uDlyTSKVzrrWcZvaE6aZYaZXZaQRc4eWX2Sq)92uX2zHR6wWAzz5zjtJva)gGZqP5asygHsNUtpduu6P2etTX3qlUev3cwll52yRmX3yb4eWX2SivUjb6aBhhbgFZIIGfMRa80bMLbMJNbuxfqJMQBbRLL8nlkcwyUcWthywgyoEgqDvaNao2Mf6V3Mk2olCv3cwlllplzASc43aCkdT4suDlyTSKBJTYeFJfGtahBZIu5MeOdSDCey8nlkcwyUcWthywgyoEgqDvanAQUfSwwY3SOiyH5kapDGzzG54za1vbCc4yBwO)EpHhs(DlyTSSCVnvSDw4QUfSwwwEwY0gX5Z34(yg8mWydT4syGlgoohhkbq2u3lRXsghBuQQBbRLLCSCUfFExXQphCc4yBwMsEsvDlyTSKZmcL(GyzbVjowSDYjGJTzzk5jnmbKbhlNBXN3vS6ZbnAtgMaYGJLZT4Z7kw954EpHhs7lvh6jXQphhs2gZh6bmcLhAyILf8M4yX25Hw8dHfRyPW3u)qDmdKd9agHYdnmXYcEtCSy78qUy44LHoum3f4qUWM6h6baJjwOehs(9kg6qtqtGKcFb2HOqTZsq6YgFhQjhAcmasAIdnbfwQde(HOGIsFi1mOOSCOf)qQozBSDwoKrGd5aXHI(qBwcWyhAUfSdH3KdrbhBLj(gla)EBQy7SWvDlyTSS8SKPXY5w85DfR(Cm0IlHQrwZva8s4hfwMBQlvov3cwll5gX5Z34(yg8mWyCc4yBwg4f6LkNQBbRLLCMrO0hell4nXXITtobCSnltPRy0O5IHJZzgHsFqSSG3ehl2o5yJ0lvUjjyjG3eDGZaJjwOeEvVcA0MmmbKb3ioF(g3hZGNzojWOrt1jdBdUQtQTYITtFJ7JzWZaJXjws5uVq)9EcpK2xQo0tIvFooKSnMpefCSvM4BSahAXpumdhs1TG1YYd14hIco2kt8nwGdTLdjAzhcYgtFMFi6uGoWwcuo0dagtSqjoK87vm0HKFNuBLfBNhQXpumdh6baJDilzhIcsC(ouJFOygo0dyojWou06qmde(92uX2zHR6wWAzz5zjtJLZT4Z7kw95yOfxcvJSMRa4LWpkSm3uxQCQUfSwwYnIZNVX9Xm4zGX4eWX2SmWl0lLGLaEt0bodmMyHs4v9kKgMaYGBeNpFJ7JzWZmNeysvDYW2GR6KARSy7034(yg8mWyCILuoGKxKQ6wWAzj3gBLj(glaNao2MLPK392uX2zHR6wWAzz5zjtJLZT4Z7kw95yOfxIPILk4HeCwOmGKxV3Mk2olCv3cwlllplzAMrO0hell4nXXITZHwCjunYAUcGxc)OWYCtDPYXaxmCCowo3IpVRy1NdpdCXWX5yJ0Onzycidowo3IpVRy1Nd6V3Mk2olCv3cwlllplzAMrO0hell4nXXITZHwCjMkwQGhsWzHYasE9EBQy7SWvDlyTSS8SKPTXwzIVXcm0IlXuXsf8qcoluK8tkdCXWX54qjaYM6EznwY4LWuuoGKhlnmbKbhlNBXN3vS6ZH0WeqgCJ485BCFmdEM5Katkblb8MOdCgymXcLWR6viv1jdBdUQtQTYITtFJ7JzWZaJXjws5asE5EBQy7SWvDlyTSS8SKPTXwzIVXcm0IlXuXsf8qcoluK8tkdCXWX54qjaYM6EznwY4LWuuoGKhlnmbKbhlNBXN3vS6ZHu5ctazWXY5w85TsXWeHuvNmSn4QoP2kl2o9nUpMbpdmgNyjLt9cnAHjGm46grV)ea93BtfBNfUQBbRLLLNLmTn2kt8nwGHwCjMkwQGhsWzHIKFszGlgoohhkbq2u3lRXsgVeMIYbK8yPYnzycidowo3IpVRy1NdA0ctazWnIZNVX9Xm4zMtcmPtsWsaVj6aNbgtSqj8QEf0OP6KHTbx1j1wzX2PVX9Xm4zGX4elPCQxOrlmbKbhlNBXN3kfdtesvDYW2GR6KARSy7034(yg8mWyCILuoGKxO)EBQy7SWvDlyTSS8SKPTXwzIVXcmK6tjaFyeDiks(n0IlXuXsf8qcolugqYRszGlgoohhkbq2u3lRXsgVeMIYbK8yPtYalM9wY8mqzF8yvuUP(92uX2zHR6wWAzz5zjtxWCC60RBe9(tadT4siy5Q8JTmGWza(Q2yQFp(EBQy7SWvDlyTSS8SKPXY5w85TsXWeXqlUeQgznxbWlHFuyzUPUug4IHJZXHsaKn19YASKXlHPOCQxLk3ieCBSvE95gtWnvSubA0uDYW2GR6KARSy7034(yg8mWysDXWX5mJqPpiwwWBIJfBNCSrPtocb3ioFE95gtWnvSub6V3Mk2olCv3cwlllplzASCUfFERummrmK6tjaFyeDiks(n0IlXuXsf8qcolugqYRszGlgoohhkbq2u3lRXsgVeMIYPE9EBQy7SWvDlyTSS8SKPlnMWtaBeidP(ucWhgrhIIKFdT4scJOdbpwhWhTFufE59YuVinmIoe8yDaF0E2cd8Y92uX2zHR6wWAzz5zjttSTaEgySHwCjtocbxFUXeCtflv4EBQy7SWvDlyTSS8SKPlMIS4RAnHF0uXqlUetflvWdj4SqzajVkDsxmCCoZiu6dILf8M4yX2jhBu6KQUfSwwYzgHsFqSSG3ehl2o5eWyF3779eEi53uH0Y4quq3vSXcL7TPITZcx1uH0YOiPiZioBQ7D2sm0IlHQrwZva8s4hfwMBQlLGLRYp2YacNb4RAJbEW79eEiniou0hcRahYWdGCiBSvhAlhQZdj)h4qw5qrFOrcqfY4qnvGOSXXn1peDkfMdjBEfWHkqeBQFiSXdj)h4F5EBQy7SWvnviTmkplz6ImJ4SPU3zlXqlUev3cwll52yRmX3yb4eWX2SivotflvWdj4SqzajVk1uXsf8qcoluMsYlsjy5Q8JTmGWza(Q2ya5mvSubpKGZcfkSpi90OzQyPcEibNfkd8IucwUk)yldiCgGVQngqEpI(7TPITZcx1uH0YO8SKPn32ztl2o9I1XDOfxcvJSMRa4LWpkSm3ux6KLgt4UjJlaJ5D)8aDnNrbiv1TG1YsUn2kt8nwaobCSnlsjyjWJ1b8r7F8aYjVNDXWX5eSCvEvtiyJX2jNao2Mf6V3Mk2olCvtfslJYZsM2CBNnTy70lwh3HwCjunYAUcGxc)OWYCtDPLgt4UjJlaJ5D)8aDnNrbivov3cwll5y5Cl(8UIvFo4eWX2SqJ2KHjGm4y5Cl(8UIvFoKQ6wWAzjNzek9bXYcEtCSy7KtahBZc93BtfBNfUQPcPLr5zjtBUTZMwSD6fRJ7qlUetflvWdj4SqzajVkLGLapwhWhT)XdiN8E2fdhNtWYv5vnHGngBNCc4yBwO)EBQy7SWvnviTmkplz6YSPOua(yg8yPSMeZFdT4sOAK1CfaVe(rHL5M6svDlyTSKBJTYeFJfGtahBZY92uX2zHRAQqAzuEwY0LztrPa8Xm4XsznjM)gAXLyQyPcEibNfkdi5vPYXalM9wY8mqzF8yvuUPonAeBzEGkKb3yScNao2MLPK87X0FVV3t4H02uxahAyJOdX92uX2zHRdjqwLegyXSx1RyOfxIlgooVGXyq6zD7WjGPcPts1iR5ka(y3In194nXRBe9(ta0Oncbx3i69Na4MkwQW92uX2zHRdjqw1ZsMMbwm7v9kgAXLqWYv5hBzaHZa8vTXu)KN0jPAK1CfaFSBXM6E8M41nIE)jG7TPITZcxhsGSQNLmTLFEwYgAXLO6wWAzj3gBLj(glaNao2MfPYfMaYGZa8vaCinxbWOrt1uH0YGNR(C4XnGgncwc4nrh4JZGrANoHc93BtfBNfUoKazvplzAznwY8LrizazOfxcdCXWX54qjaYM6EznwY4LWuuoWJV3Mk2olCDibYQEwY0YASK5lJqYaYqlUeg4IHJZXHsaKn19YASKXXgLQ6wWAzj3gBLj(glaNao2MLbErQCtgMaYGJLZT4Z7kw95GgTWeqgCJ485BCFmdEM5KaJgnvNmSn4QoP2kl2o9nUpMbpdmgnAeBzEGkKb3ySchO7wIc93BtfBNfUoKazvplzAznwY8LrizazOfxcdCXWX54qjaYM6EznwY4yJsdtazWXY5w85DfR(CiDYWeqgCJ485BCFmdEM5Kat6KeBzEGkKb3ySchO7wIIu5uDlyTSKJLZT4Z7kw95GtahBZYaViv1TG1YsUn2kt8nwaobm2N0jzDWXY5w85DfR(CWjGJTzHgTjvDlyTSKBJTYeFJfGtaJ9r)92uX2zHRdjqw1ZsMMbwm7v9kgAXLqWYv5hBzaHZa8vTXuV(iPts1iR5ka(y3In194nXRBe9(ta3BtfBNfUoKazvplzACOeaztDFjilLWqlUeg4IHJZXHsaKn19YASKXlHPOCQF3BtfBNfUoKazvplzACOeaztDFjilLWqlUeg4IHJZXHsaKn19YASKXlHPOCQhlv1TG1YsUn2kt8nwaobCSnltjpPYnzycidowo3IpVRy1NdA0ctazWnIZNVX9Xm4zMtcmA0uDYW2GR6KARSy7034(yg8mWy0OrSL5bQqgCJXkCGUBjk0FVnvSDw46qcKv9SKPXHsaKn19LGSucdT4syGlgoohhkbq2u3lRXsgVeMIYPES0WeqgCSCUfFExXQphsNmmbKb3ioF(g3hZGNzojWKojXwMhOczWngRWb6ULOiv1TG1YsUn2kt8nwaobm2Nu5uDlyTSKJLZT4Z7kw95GtahBZYuYJgng4IHJZXY5w85DfR(C4zGlgoohBK(7TPITZcxhsGSQNLmndSy2R6vm0IlzsQgznxbWh7wSPUhVjEDJO3Fc4EFVNWdnbdjqw1HOG9e4HOWq2MSX392uX2zHRdjqwL3AqcmUmWzvdT4sCXWX5fmgdspRBhobmvCVnvSDw46qcKv5TgEwY0W4YaNvn0IlzsQgznxbWh7wSPUhVjEDJO3Fc4EBQy7SW1HeiRYBn8SKPL1yjZxgHKbKHuFkb4dJOdrrYVHwCjYP6wWAzj3gBLj(glaNao2MLbErkdCXWX54qjaYM6EznwY4yJ0OXaxmCCooucGSPUxwJLmEjmfLd8y6Lkh(QphEc4yBwMs1TG1YsodSy2BjZZaL9XjGJTz55FpIgn8vFo8eWX2SmGQBbRLLCBSvM4BSaCc4yBwO)EBQy7SW1HeiRYBn8SKPXHsaKn19LGSucdP(ucWhgrhIIKFdT4syGlgoohhkbq2u3lRXsgVeMIYPKipPQUfSwwYTXwzIVXcWjGJTzzk5rJgdCXWX54qjaYM6EznwY4LWuuo1V7TPITZcxhsGSkV1WZsMghkbq2u3xcYsjmK6tjaFyeDiks(n0Ilr1TG1YsUn2kt8nwaobCSnld8Iug4IHJZXHsaKn19YASKXlHPOCQFvndlMBsvtBDWewSDkFIHh1Og1k]] )

end
