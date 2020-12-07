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


    spec:RegisterPack( "Unholy", 20201206, [[d8KCWbqifspsHqxcjOAtePpbLAuKsofr0Qqck9kvPmlfKDHQFPq1WufQJbLSmvr9msPmnfkDnvPABke8nKaACkePZHeG1PkK5Pk4Eiv7tbCqKaTqvrEiPunrfI6IeHQ2OcriFuHiAKkeH6KeHkRuvYlrcImtfkUjsqs7ub6NibrnuKGILsekEkPAQkOUQcrWwrcs8vKGWyrcTxj9xkgmKdt1IPKhtYKr5YGndvFMOgTI60kTAKGuVgjA2eUnLA3I(TudxroorilhXZLy6cxxvTDK03jfJNi48qX6jcLMpsz)QCfR6WvDMhqDWNF8ZpgRNF8iWF(XVtbGffyvpWmbv9jxrPldv90THQ(iHCUfyQ6togr7S6Wv9s)jkOQphXu5rJpU8gZFlUQThVS2FHhBNkIJhJxwB14vDR)kcjUSAv1zEa1bF(Xp)ySE(XJa)5h)ofawv9YeOQd(87px1NxgdYQvvNbfvvFep0idEmFikKYvEoo0iHCUfyUxJ4Hgzqb2wa5qJWqh65h)8JVx3Rr8quqgf6FjSHmkhk6dnY5ip(id4RagFKbpMlhAK)WHI(qDkWCiv)Z4qHtKHOCinZ9HCcCiqctGka2HI(qILkCirNYhcY(lpFOOpKThbqoKwEdMce)PdnIyjjVQl2suQdx1LHeiRQoCDqSQdx1H0TeaR(uvxr2aiRx1T(448YNXG0W62Mtaxfhs6Hg9quDY6wcGp1TytzdEtmYorUXiGdrJ2HMGGl7e5gJa4UkwQqv3vX2zvNbEmBu9kQrDWNRdx1H0TeaR(uvxr2aiRx1j)CvMPwdq4maFvBCOhoewA7qsp0OhIQtw3sa8PUfBkBWBIr2jYngbu1DvSDw1zGhZgvVIAuhuB1HR6q6wcGvFQQRiBaK1R6QUfSwtY9Pw5cmtfGtaBFZYHKEiTou4cidodWxbWH0Tea7q0ODivtfspdEUYZHb3HdrJ2Hi)eWBImWNMbN02DcfoKULayhsYQURITZQUNymSKvJ6GJToCvhs3saS6tvDfzdGSEvNbwFCCooucGSPSrt)tgVeUIYdnWHgBv3vX2zvxt)tMPmbjdi1Oo471HR6q6wcGvFQQRiBaK1R6mW6JJZXHsaKnLnA6FY4)Pdj9qQUfSwtY9Pw5cmtfGtaBFZYHg4qVFiPhsRdn6HcxazW)5ClWySeR8CWH0Tea7q0ODOWfqgCNyJX04Mygmm3obghs3saSdrJ2HuDY(BWvDsTvESDAACtmdgg4moKULayhIgTdr8LzaQqgCNXkCqcBjkhsYQURITZQUM(NmtzcsgqQrDWrOoCvhs3saS6tvDfzdGSEvNbwFCCooucGSPSrt)tg)pDiPhkCbKb)NZTaJXsSYZbhs3saSdj9qJEOWfqgCNyJX04Mygmm3obghs3saSdj9qJEiIVmdqfYG7mwHdsylr5qspKwhs1TG1As(pNBbgJLyLNdobS9nlhAGd9(HKEiv3cwRj5(uRCbMPcWjGZWCiPhA0dX6G)Z5wGXyjw55GtaBFZYHOr7qJEiv3cwRj5(uRCbMPcWjGZWCijR6Uk2oR6A6FYmLjizaPg1bPaRdx1H0TeaR(uvxr2aiRx1j)CvMPwdq4maFvBCOho0Zp(qsp0OhIQtw3sa8PUfBkBWBIr2jYngbu1DvSDw1zGhZgvVIAuhCKwhUQdPBjaw9PQUISbqwVQZaRpoohhkbq2u2OP)jJxcxr5HE4qyv1DvSDw1XHsaKnLnLGSuc1OoifqD4QoKULay1NQ6kYgaz9QodS(44CCOeaztzJM(NmEjCfLh6Hdn2dj9qQUfSwtY9Pw5cmtfGtaBFZYHE4qA7qspKwhA0dfUaYG)Z5wGXyjw55GdPBja2HOr7qHlGm4oXgJPXnXmyyUDcmoKULayhIgTdP6K93GR6KAR8y7004MygmmWzCiDlbWoenAhI4lZauHm4oJv4Ge2suoKKvDxfBNvDCOeaztztjilLqnQdI1JRdx1H0TeaR(uvxr2aiRx1zG1hhNJdLaiBkB00)KXlHRO8qpCOXEiPhkCbKb)NZTaJXsSYZbhs3saSdj9qJEOWfqgCNyJX04Mygmm3obghs3saSdj9qJEiIVmdqfYG7mwHdsylr5qspKQBbR1KCFQvUaZub4eWzyoK0dP1HuDlyTMK)Z5wGXyjw55GtaBFZYHE4qA7q0ODigy9XX5)CUfymwIvEommW6JJZ)thsYQURITZQooucGSPSPeKLsOg1bXcR6WvDiDlbWQpv1vKnaY6v9rpevNSULa4tDl2u2G3eJStKBmcOQ7Qy7SQZapMnQEf1OgvDVbtbI)uD46GyvhUQdPBjaw9PQUISbqwVQZapMnuMR8CWX10)Kbmt4ezikhAa6hsHrjadKG9cLdrJ2Hi(YmavidUZyfoiHTeLdj9qeFzgGkKb3zScNa2(MLd9a9dHfwvDxfBNvDpXyyjRg1bFUoCvhs3saS6tvDfzdGSEvNbEmBOmx55GJRP)jdyMWjYquo0a0p07vDxfBNvDpXyyjRg1b1wD4QoKULay1NQ6kYgaz9Q(OhIQtw3sa8PUfBkBWBIr2jYngbu1DvSDw1HPLb2RQg1bhBD4QoKULay1NQ6Uk2oR64qjaYMYMsqwkHQUISbqwVQZaRpoohhkbq2u2OP)jJxcxr5HEG(H02HKEiv3cwRj5(uRCbMPcWjGTVz5qpCiTv1vyucWeorgIsDqSQrDW3Rdx1H0TeaR(uv3vX2zvhhkbq2u2ucYsju1vKnaY6vDgy9XX54qjaYMYgn9pz8s4kkp0dhcRQUcJsaMWjYquQdIvnQdoc1HR6q6wcGvFQQ7Qy7SQJdLaiBkBkbzPeQ6kYgaz9Qo5NapwBWeTzSh6HdP1HuDlyTMKZapMnEYmmq5y4eW23SCiPhA0dfUaYGZa8vaCiDlbWoenAhs1TG1AsodWxbWjGTVz5qspu4cidodWxbWH0Tea7qsw1vyucWeorgIsDqSQrnQ6QMkKEgL6W1bXQoCvhs3saS6tvDfzdGSEvNQtw3sa8syMeEMBkFiPhI8ZvzMAnaHZa8vTXHg4qJqv3vX2zvVOXj2BkBS3suJ6GpxhUQdPBjaw9PQUISbqwVQR6wWAnj3NALlWmvaobS9nlhs6H06qUkwQGbsWEHYHgG(HE(qspKRILkyGeSxOCOhOFO3pK0dr(5QmtTgGWza(Q24qdCiToKRILkyGeSxOCikShAeoKKhIgTd5QyPcgib7fkhAGd9(HKEiYpxLzQ1aeodWx1ghAGdPThFijR6Uk2oR6fnoXEtzJ9wIAuhuB1HR6q6wcGvFQQRiBaK1R6uDY6wcGxcZKWZCt5dj9qJEOs)fwBY4cWzglmgqcU9KaoK0dP6wWAnj3NALlWmvaobS9nlhs6Hi)e4XAdMOnJ9qdCiToK2o0BhY6JJZj)Cvgvti)Py7KtaBFZYHKSQ7Qy7SQ7wT9MESDAeRTvnQdo26WvDiDlbWQpv1vKnaY6vDQozDlbWlHzs4zUP8HKEOs)fwBY4cWzglmgqcU9KaoK0dP1HuDlyTMK)Z5wGXyjw55GtaBFZYHOr7qJEOWfqg8Fo3cmglXkphCiDlbWoK0dP6wWAnjN5eknbXZcEtS9y7KtaBFZYHKSQ7Qy7SQ7wT9MESDAeRTvnQd(ED4QoKULay1NQ6kYgaz9QURILkyGeSxOCObOFONpK0dr(jWJ1gmrBg7Hg4qADiTDO3oK1hhNt(5QmQMq(tX2jNa2(MLdjzv3vX2zv3TA7n9y70iwBRAuhCeQdx1H0TeaR(uvxr2aiRx1P6K1TeaVeMjHN5MYhs6HuDlyTMK7tTYfyMkaNa2(MLQURITZQEz2vukatmdMFQPjXmMAuhKcSoCvhs3saS6tvDfzdGSEv3vXsfmqc2luo0a0p0Zhs6H06qmWJzJNmdduogESkk3u(q0ODiIVmdqfYG7mwHtaBFZYHEG(HWAShsYQURITZQEz2vukatmdMFQPjXmMAuJQ(ebuTTLh1HRdIvD4QURITZQ(uhBNvDiDlbWQpvJ6GpxhUQdPBjaw9PQE62qv3LylZoXlg8odtJBMAnaPQ7Qy7SQ7sSLzN4fdENHPXntTgGuJ6GARoCv3vX2zvN4BbmmWzvDiDlbWQpvJAu1vDlyTMSuhUoiw1HR6q6wcGvFQQRiBaK1R6tqWLDICJraCxflv4q0ODiRpoo)NZTaJXlf)lc(F6q0ODOWfqgCNyJX04Mygmm3obghs3saSdj9qADOji4oXgJrEU)cURILkCiA0o0eeCFQvg55(l4UkwQWHOr7qQUfSwtYDIngtJBIzWWaNXjGTVz5qdCOWjYqWJ1gmrBylCijR6Uk2oR6tDSDwJ6GpxhUQdPBjaw9PQURITZQ(Mff5hULams03Z4BBya1vbvDfzdGSEvxRdP6wWAnj)NZTaJXsSYZbNa2(MLdrJ2HuDlyTMKZCcLMG4zbVj2ESDYjGTVz5qsEiPhsRdnbb3j2ymYZ9xWDvSuHdrJ2HMGG7tTYip3Fb3vXsfoK0dn6HcxazWDIngtJBIzWWC7eyCiDlbWoenAhkCIme8yTbt0MjvyE(Xh6Hd9(HKSQNUnu13SOi)WTeGrI(EgFBddOUkOg1b1wD4QoKULay1NQ6Uk2oR62UYTiGPmdqyS)Lvv1vKnaY6vDv3cwRj5(uRCbMPcWjGTVz5qpCO3pK0dP1Hg9qGe93PjGX3SOi)WTeGrI(EgFBddOUk4q0ODiv3cwRj5BwuKF4wcWirFpJVTHbuxfWjGTVz5qsw1t3gQ62UYTiGPmdqyS)LvvJ6GJToCvhs3saS6tvDxfBNvDgbCg(sadvOuarvxr2aiRx1vDlyTMK7tTYfyMkaNa2(MLdj9qKFc8yTbt0MXEOhoKSIDiPhsRdn6Haj6VttaJVzrr(HBjaJe99m(2ggqDvWHOr7qQUfSwtY3SOi)WTeGrI(EgFBddOUkGtaBFZYHKSQNUnu1zeWz4lbmuHsbe1Oo471HR6q6wcGvFQQ7Qy7SQZCcL2DNggOO0qTjUAdmvDfzdGSEvx1TG1AsUp1kxGzQaCcy7BwoK0dP1Hg9qGe93PjGX3SOi)WTeGrI(EgFBddOUk4q0ODiv3cwRj5BwuKF4wcWirFpJVTHbuxfWjGTVz5qsw1t3gQ6mNqPD3PHbkknuBIR2atnQdoc1HR6q6wcGvFQQRiBaK1R6QUfSwtY9Pw5cmtfGtaBFZYHKEiTo0OhcKO)onbm(Mff5hULams03Z4BBya1vbhIgTdP6wWAnjFZII8d3sagj67z8TnmG6QaobS9nlhsYQURITZQ(VaMna7snQdsbwhUQdPBjaw9PQUISbqwVQZaRpoohhkbq2u2OP)jJ)NoK0dP6wWAnj)NZTaJXsSYZbNa2(MLd9WH02HKEiv3cwRj5mNqPjiEwWBIThBNCcy7Bwo0dhsBhs6HcxazW)5ClWySeR8CWH0Tea7q0ODOrpu4cid(pNBbgJLyLNdoKULayvDxfBNvDNyJX04MygmmWz1Oo4iToCvhs3saS6tvDfzdGSEvNQtw3sa8syMeEMBkFiPhsRdP6wWAnj3j2ymnUjMbddCgNa2(MLdnWHE)q0ODig4XSHYCLNdoBlULamEhSdj5HKEiToKQBbR1KCMtO0eepl4nX2JTtobS9nlh6HdjRyhIgTdz9XX5mNqPjiEwWBIThBN8)0HK8qspKwhA0dr(jG3ezGZaNjwOegvVcoKULayhIgTdn6HcxazWDIngtJBIzWWC7eyCiDlbWoenAhs1j7Vbx1j1w5X2PPXnXmyyGZ4epP8qpCO3pKKvDxfBNv9Fo3cmglXkph1OoifqD4QoKULay1NQ6kYgaz9QURILkyGeSxOCi6hcRdj9qmW6JJZXHsaKnLnA6FY4LWvuEObOFOXEiPhkCbKb)NZTaJXsSYZbhs3saSdj9qADOWfqg8Fo3cmgVu8Vi4q6wcGDiPhs1j7Vbx1j1w5X2PPXnXmyyGZ4epP8qpCO3penAhkCbKbx2jYngbWH0Tea7qsw1DvSDw1)5ClWySeR8CuJ6Gy946WvDiDlbWQpv1vKnaY6vDxflvWajyVq5qdq)qpx1DvSDw1)5ClWySeR8CuJ6GyHvD4QoKULay1NQ6kYgaz9QovNSULa4LWmj8m3u(qspKwhIbwFCC(pNBbgJLyLNdddS(448)0HOr7qJEOWfqg8Fo3cmglXkphCiDlbWoKKvDxfBNvDMtO0eepl4nX2JTZAuheRNRdx1H0TeaR(uvxr2aiRx1DvSubdKG9cLdna9d9Cv3vX2zvN5eknbXZcEtS9y7Sg1bXsB1HR6q6wcGvFQQRiBaK1R6UkwQGbsWEHYHOFiSoK0dXaRpoohhkbq2u2OP)jJxcxr5HgG(Hg7HKEOWfqg8Fo3cmglXkphCiDlbWoK0dfUaYG7eBmMg3eZGH52jW4q6wcGDiPhI8taVjYaNbotSqjmQEfCiDlbWoK0dP6K93GR6KAR8y7004MygmmWzCINuEObOFO3R6Uk2oR6(uRCbMPcuJ6Gyn26WvDiDlbWQpv1vKnaY6vDgy9XX54qjaYMYgn9pz8s4kkp0a0p0ypK0d5QyPcgib7fkhI(HW6qspu4cid(pNBbgJLyLNdoKULayhs6HuDY(BWvDsTvESDAACtmdgg4moXtkp0a0p07hs6HcxazWDIngtJBIzWWC7eyCiDlbWoK0dr(jG3ezGZaNjwOegvVcoKULayhs6HyG1hhN)Z5wGXyjw55WWaRpoo)pv1DvSDw19Pw5cmtfOg1bX696WvDiDlbWQpv1vKnaY6vDxflvWajyVq5q0pewhs6HyG1hhNJdLaiBkB00)KXlHRO8qdq)qJ9qsp0OhkCbKb)NZTaJXsSYZbhs3saSdrJ2HcxazWDIngtJBIzWWC7eyCiDlbWoK0dP1Hg9qKFc4nrg4mWzIfkHr1RGdPBja2HOr7qQoz)n4QoP2kp2onnUjMbddCgN4jLh6Hd9(HK8q0ODOWfqg8Fo3cmgVu8Vi4q6wcGDiPhs1j7Vbx1j1w5X2PPXnXmyyGZ4epP8qdq)qVx1DvSDw19Pw5cmtfOg1bXAeQdx1H0TeaR(uv3vX2zv3NALlWmvGQUISbqwVQ7QyPcgib7fkhAa6h65dj9qmW6JJZXHsaKnLnA6FY4LWvuEObOFOXEiPhA0dXapMnEYmmq5y4XQOCt5QUcJsaMWjYquQdIvnQdIffyD4QoKULay1NQ6kYgaz9Qo5NRYm1AacNb4RAJd9WHWASvDxfBNv9Y32UtJStKBmcOg1bXAKwhUQdPBjaw9PQUISbqwVQt1jRBjaEjmtcpZnLpK0dXaRpoohhkbq2u2OP)jJxcxr5HE4qpFiPhsRdnbb3NALrEU)cURILkCiA0oKQt2FdUQtQTYJTttJBIzWWaNXH0Tea7qspK1hhNZCcLMG4zbVj2ESDY)ths6Hg9qtqWDIngJ8C)fCxflv4qsw1DvSDw1)5ClWy8sX)IOg1bXIcOoCvhs3saS6tvDxfBNv9Fo3cmgVu8ViQ6kYgaz9QURILkyGeSxOCObOFONpK0dXaRpoohhkbq2u2OP)jJxcxr5HE4qpx1vyucWeorgIsDqSQrDWNFCD4QoKULay1NQ6Uk2oR6L(lmeWNasvxr2aiRx1dNidbpwBWeTzsfgT9(HE4qVFiPhkCIme8yTbt0g2chAGd9EvxHrjat4ezik1bXQg1bFgR6WvDiDlbWQpv1vKnaY6v9rp0eeC55(l4UkwQqv3vX2zvN4BbmmWz1Oo4ZpxhUQdPBjaw9PQUISbqwVQ7QyPcgib7fkhAa6h65dj9qJEiRpooN5eknbXZcEtS9y7K)NoK0dn6HuDlyTMKZCcLMG4zbVj2ESDYjGZWu1DvSDw1lUIS4RADHzYvrnQrvxgsGSkJ3qD46GyvhUQdPBjaw9PQUISbqwVQB9XX5LpJbPH1TnNaUkQ6Uk2oR6W0Ya7vvJ6GpxhUQdPBjaw9PQUISbqwVQp6HO6K1TeaFQBXMYg8MyKDICJravDxfBNvDyAzG9QQrDqTvhUQdPBjaw9PQURITZQUM(NmtzcsgqQ6kYgaz9QUwhs1TG1AsUp1kxGzQaCcy7Bwo0ah69dj9qmW6JJZXHsaKnLnA6FY4)PdrJ2HyG1hhNJdLaiBkB00)KXlHRO8qdCOXEijpK0dP1HWx55WqaBFZYHE4qQUfSwtYzGhZgpzggOCmCcy7Bwo0BhcRhFiA0oe(kphgcy7Bwo0ahs1TG1AsUp1kxGzQaCcy7BwoKKvDfgLamHtKHOuheRAuhCS1HR6q6wcGvFQQ7Qy7SQJdLaiBkBkbzPeQ6kYgaz9QodS(44CCOeaztzJM(NmEjCfLh6b6hsBhs6HuDlyTMK7tTYfyMkaNa2(MLd9WH02HOr7qmW6JJZXHsaKnLnA6FY4LWvuEOhoewvDfgLamHtKHOuheRAuh896WvDiDlbWQpv1DvSDw1XHsaKnLnLGSucvDfzdGSEvx1TG1AsUp1kxGzQaCcy7Bwo0ah69dj9qmW6JJZXHsaKnLnA6FY4LWvuEOhoewvDfgLamHtKHOuheRAuJQU3GX6tkrD46GyvhUQdPBjaw9PQUISbqwVQt(5QmtTgGWza(Q24qpCiToewp(qVDig4XSHYCLNdoUM(NmGzcNidr5quypK2oKKhs6HyGhZgkZvEo44A6FYaMjCImeLd9WHgHdj9qJEiQozDlbWN6wSPSbVjgzNi3yeWHOr7qwFCCErJtS3u2yVLG)NQ6Uk2oR6W0Ya7vvJ6GpxhUQdPBjaw9PQUISbqwVQt(5QmtTgGWza(Q24qpCONF)qsped8y2qzUYZbhxt)tgWmHtKHOCObo07hs6Hg9quDY6wcGp1TytzdEtmYorUXiGQURITZQomTmWEv1OoO2Qdx1H0TeaR(uvxr2aiRx1h9qmWJzdL5kphCCn9pzaZeorgIYHKEOrpevNSULa4tDl2u2G3eJStKBmc4q0ODi8vEomeW23SCOho07hIgTdr8LzaQqgCNXkCqcBjkhs6Hi(YmavidUZyfobS9nlh6Hd9Ev3vX2zvhMwgyVQAuhCS1HR6Uk2oR6A6FYmLjizaPQdPBjaw9PAuh896WvDiDlbWQpv1vKnaY6v9rpevNSULa4tDl2u2G3eJStKBmcOQ7Qy7SQdtldSxvnQrvNb4(xe1HRdIvD4QURITZQU9MmdobajwOQdPBjaw9PAuh856WvDiDlbWQpv17PQEbIQURITZQovNSULaQ6uDXhQ6QUfSwtYlFB7onYorUXiaobS9nlh6Hd9(HKEOWfqg8Y32UtJStKBmcGdPBjawvNQtmPBdv9PUfBkBWBIr2jYngbuJ6GARoCvhs3saS6tv9EQQxGOQ7Qy7SQt1jRBjGQovx8HQURILkyGeSxOCi6hcRdj9qADOrpeXxMbOczWDgRWbjSLOCiA0oeXxMbOczWDgRW38qdCiSE)qsw1P6et62qvVeMjHN5MY1Oo4yRdx1H0TeaR(uvxr2aiRx1j)CvMPwdq4maFvBCObo0i8(HKEiTo0eeCzNi3yea3vXsfoenAhA0dfUaYGx(22DAKDICJraCiDlbWoKKhs6Hi)e4maFvBCObOFO3R6Uk2oR6or5jyIMqGmQrDW3Rdx1H0TeaR(uvxr2aiRx1NGGl7e5gJa4UkwQWHOr7qwFCC(pNBbgJxk(xe8)0HOr7qHlGm4oXgJPXnXmyyUDcmoKULayhs6HMGG7tTYip3Fb3vXsfoK0dP1HMGG7eBmg55(l4UkwQWHOr7qQUfSwtYDIngtJBIzWWaNXjGTVz5qdCiv3cwRj5wIUzg8pbdN9jESDEOXpK2oKKhIgTdforgcES2GjAdBHd9a9dz9XX5wIUzg8pbdN9jESDw1DvSDw1TeDZm4FcMAuhCeQdx1H0TeaR(uvxr2aiRx1NGGl7e5gJa4UkwQWHOr7qwFCC(pNBbgJxk(xe8)0HOr7qHlGm4oXgJPXnXmyyUDcmoKULayhs6HMGG7tTYip3Fb3vXsfoK0dP1HMGG7eBmg55(l4UkwQWHOr7qQUfSwtYDIngtJBIzWWaNXjGTVz5qdCiv3cwRj5waPaek3uMZ(ep2op04hsBhsYdrJ2HcNidbpwBWeTHTWHEG(HS(44ClGuacLBkZzFIhBNvDxfBNvDlGuacLBkxJ6GuG1HR6q6wcGvFQQRiBaK1R6wFCC(pNBbgtjiqkhZ8)uv3vX2zvxSYZrXqH(ZKTHmQrDWrAD4QoKULay1NQ6kYgaz9Q(eeCzNi3yea3vXsfoenAhY6JJZ)5ClWy8sX)IG)NoenAhkCbKb3j2ymnUjMbdZTtGXH0Tea7qsp0eeCFQvg55(l4UkwQWHKEiTo0eeCNyJXip3Fb3vXsfoenAhs1TG1AsUtSXyACtmdgg4mobS9nlhAGdP6wWAnj3tfucIlmkxi4SpXJTZdn(H02HK8q0ODOWjYqWJ1gmrBylCOhOFiSEVQ7Qy7SQ7PckbXfgLle1OoifqD4QoKULay1NQ6kYgaz9QURILkyGeSxOCObOFONpenAhsRdr(jWza(Q24qdq)qVFiPhI8ZvzMAnaHZa8vTXHgG(HgHhFijR6Uk2oR6or5jyM(IcuJ6Gy946WvDiDlbWQpv1vKnaY6v9ji4YorUXiaURILkCiA0oK1hhN)Z5wGX4LI)fb)pDiA0ou4cidUtSXyACtmdgMBNaJdPBja2HKEOji4(uRmYZ9xWDvSuHdj9qADOji4oXgJrEU)cURILkCiA0oKQBbR1KCNyJX04MygmmWzCcy7Bwo0ahs1TG1Aso(salr3mo7t8y78qJFiTDijpenAhkCIme8yTbt0g2ch6b6hY6JJZXxcyj6MXzFIhBNvDxfBNvD8LawIUz1OoiwyvhUQdPBjaw9PQUISbqwVQB9XX5)CUfymLGaPCmZ)ths6HCvSubdKG9cLdr)qyv1DvSDw1TCztJBcYQOSuJ6Gy9CD4QoKULay1NQ6kYgaz9QoRdo1L8fqgMjHl)bobWjqz2TeWHKEOrpu4cid(pNBbgJLyLNdoKULayhs6Hg9qeFzgGkKb3zSchKWwIsv3vX2zvV)HfbCkRrDqS0wD4QoKULay1NQ6kYgaz9QoRdo1L8fqgMjHl)bobWjqz2TeWHKEiTo0OhkCbKb)NZTaJXsSYZbhs3saSdrJ2HcxazW)5ClWySeR8CWH0Tea7qspKQBbR1K8Fo3cmglXkphCcy7BwoKKhs6HCvSubdKG9cLdna9d9Cv3vX2zvV)HfbCkRrDqSgBD4QoKULay1NQ6kYgaz9Qo5NaEtKbE5pbKsq8n5q6wcGDiPhsRdX6GJt6syWbQaHtaCcuMDlbCiA0oeRdULOBMzs4YFGtaCcuMDlbCijR6Uk2oR69pSiGtznQdI171HR6q6wcGvFQQ7Qy7SQRCHW4Qy70i2su1fBjmPBdvDvtfspJsnQdI1iuhUQdPBjaw9PQURITZQUYfcJRITtJylrvxSLWKUnu1vDlyTMSuJ6GyrbwhUQdPBjaw9PQUISbqwVQ7QyPcgib7fkhAa6h65dj9qADiv3cwRj5mWJzJNmdduogobS9nlh6HdH1JpK0dn6HcxazWza(kaoKULayhIgTdP6wWAnjNb4Ra4eW23SCOhoewp(qspu4cidodWxbWH0Tea7qsEiPhA0dXapMnEYmmq5y4XQOCt5QURITZQo5NgxfBNgXwIQUylHjDBOQ7nykq8NQrDqSgP1HR6q6wcGvFQQRiBaK1R6UkwQGbsWEHYHgG(HE(qsped8y24jZWaLJHhRIYnLR6Uk2oR6KFACvSDAeBjQ6ITeM0THQU3GX6tkrnQdIffqD4QoKULay1NQ6kYgaz9QURILkyGeSxOCObOFONpK0dP1Hg9qmWJzJNmdduogESkk3u(qspKwhs1TG1Asod8y24jZWaLJHtaBFZYHg4qy94dj9qJEOWfqgCgGVcGdPBja2HOr7qQUfSwtYza(kaobS9nlhAGdH1JpK0dfUaYGZa8vaCiDlbWoKKhsYQURITZQo5NgxfBNgXwIQUylHjDBOQldjqwLXBOg1bF(X1HR6q6wcGvFQQRiBaK1R6UkwQGbsWEHYHOFiSQ6Uk2oR6kximUk2onITevDXwct62qvxgsGSQAuJAu1PcKY2zDWNF8ZpgRNFmwvDnoj3uUu1PqqbLyguIBWrYhDOdn8mCO1EQjXHWBYHWwgsGSkSpebKO)sa2HkTnCi)hTTha7qQzpLHc)EnMnHdPThDiT3jvGea7qyt(jG3ezGtrSpu0hcBYpb8MidCkYH0Tead7dPfwsqs(9AmBch69hDiT3jvGea7qyhUaYGtrSpu0hc7WfqgCkYH0Tead7dP1Zsqs(9AmBch69hDiT3jvGea7qyR6K93GtrSpu0hcBvNS)gCkYH0Tead7dPfwsqs(9AmBchAeE0H0ENubsaSdHD4cidofX(qrFiSdxazWPihs3samSpKwplbj53RXSjCikGhDiT3jvGea7qyhUaYGtrSpu0hc7WfqgCkYH0Tead7dP1Zsqs(9AmBchIc4rhs7DsfibWoe2Qoz)n4ue7df9HWw1j7VbNICiDlbWW(qAHLeKKFVgZMWHW6Xp6qAVtQaja2HWoCbKbNIyFOOpe2HlGm4uKdPBjag2hsRNLGK8719IcbfuIzqjUbhjF0Ho0WZWHw7PMehcVjhcBVbtbI)e2hIas0Fja7qL2goK)J22dGDi1SNYqHFVgZMWHgHhDiT3jvGea7qyhUaYGtrSpu0hc7WfqgCkYH0Tead7dP1Zsqs(96ErHGckXmOe3GJKp6qhA4z4qR9utIdH3KdHndW9ViW(qeqI(lbyhQ02WH8F02EaSdPM9ugk871y2eo0Zp6qAVtQaja2HWoCbKbNIyFOOpe2HlGm4uKdPBjag2hYJdjXtH8yoKwyjbj53RXSjCO3F0H0ENubsaSdPV2A)qfmz4s4qu4hk6dnMVFi2sDlBNhQNaIhn5qAnUKhslSKGK871y2eo07p6qAVtQaja2HWoCbKbNIyFOOpe2HlGm4uKdPBjag2hslSKGK871y2eo0i8OdP9oPcKayhsFT1(HkyYWLWHOWpu0hAmF)qSL6w2opupbepAYH0ACjpKwyjbj53RXSjCOr4rhs7DsfibWoe2HlGm4ue7df9HWoCbKbNICiDlbWW(qAHLeKKFVgZMWHgPp6qAVtQaja2H0xBTFOcMmCjCik8df9HgZ3peBPULTZd1taXJMCiTgxYdPfwsqs(9AmBchAK(OdP9oPcKayhc7WfqgCkI9HI(qyhUaYGtroKULayyFiTWscsYVxJzt4qy94hDiT3jvGea7q6RT2pubtgUeoef(HI(qJ57hITu3Y25H6jG4rtoKwJl5H0cljij)EnMnHdH1JF0H0ENubsaSdHD4cidofX(qrFiSdxazWPihs3samSpKwyjbj53RXSjCiSE(rhs7DsfibWoe2HlGm4ue7df9HWoCbKbNICiDlbWW(qAHLeKKFVgZMWHWsBp6qAVtQaja2HWoCbKbNIyFOOpe2HlGm4uKdPBjag2hsRNLGK871y2eoewJ9rhs7DsfibWoe2KFc4nrg4ue7df9HWM8taVjYaNICiDlbWW(qAHLeKKFVgZMWHWIc8rhs7DsfibWoe2HlGm4ue7df9HWoCbKbNICiDlbWW(qA9SeKKFVgZMWHWIc4rhs7DsfibWoe2HlGm4ue7df9HWoCbKbNICiDlbWW(qA9SeKKFVUxuiOGsmdkXn4i5Jo0HgEgo0Ap1K4q4n5qyR6wWAnzb7draj6VeGDOsBdhY)rB7bWoKA2tzOWVxJzt4qy9OdP9oPcKayhc7WfqgCkI9HI(qyhUaYGtroKULayyFiTWscsYVxJzt4qp)OdP9oPcKayhc7WfqgCkI9HI(qyhUaYGtroKULayyFiTWscsYVxJzt4quGp6qAVtQaja2HWoCbKbNIyFOOpe2HlGm4uKdPBjag2hslSKGK871y2eoef4JoK27KkqcGDiSdxazWPi2hk6dHD4cidof5q6wcGH9H84qs8uipMdPfwsqs(9AmBchAK(OdP9oPcKayhc7WfqgCkI9HI(qyhUaYGtroKULayyFiTWscsYVxJzt4qJ0hDiT3jvGea7qyt(jG3ezGtrSpu0hcBYpb8MidCkYH0Tead7dPfwsqs(9AmBchIc4rhs7DsfibWoe2HlGm4ue7df9HWoCbKbNICiDlbWW(qAPnjij)EnMnHdHfwp6qAVtQaja2HWoCbKbNIyFOOpe2HlGm4uKdPBjag2hslSKGK871y2eoewA7rhs7DsfibWoe2HlGm4ue7df9HWoCbKbNICiDlbWW(qA9SeKKFVgZMWHWsBp6qAVtQaja2HWM8taVjYaNIyFOOpe2KFc4nrg4uKdPBjag2hslSKGK871y2eoewJ9rhs7DsfibWoe2HlGm4ue7df9HWoCbKbNICiDlbWW(qA9SeKKFVgZMWHWASp6qAVtQaja2HWM8taVjYaNIyFOOpe2KFc4nrg4uKdPBjag2hslSKGK871y2eoewV)OdP9oPcKayhc7WfqgCkI9HI(qyhUaYGtroKULayyFiT0MeKKFVgZMWHW69hDiT3jvGea7qyt(jG3ezGtrSpu0hcBYpb8MidCkYH0Tead7dPfwsqs(9AmBchcRr6JoK27KkqcGDiSvDY(BWPi2hk6dHTQt2Fdof5q6wcGH9H0cljij)EDVOqqbLyguIBWrYhDOdn8mCO1EQjXHWBYHWw1uH0ZOG9HiGe9xcWouPTHd5)OT9ayhsn7Pmu43RXSjCOX(OdP9oPcKayhc7WfqgCkI9HI(qyhUaYGtroKULayyFiTWscsYVx3ljo7PMea7qJ0d5Qy78qITef(9QQprA8vav9r8qJm4X8HOqkx554qJeY5wG5EnIhAKbfyBbKdncdDONF8Zp(EDVgXdrbzuO)LWgYOCOOp0iNJ84JmGVcy8rg8yUCOr(dhk6d1PaZHu9pJdforgIYH0m3hYjWHajmbQayhk6djwQWHeDkFii7V88HI(q2Eea5qA5nykq8No0iILK8719YvX2zHpravBB5XB0hFQJTZ7LRITZcFIaQ22YJ3Op(VaMna7Hs3gO7sSLzN4fdENHPXntTgGCVCvSDw4teq12wE8g9Xj(waddC296EnIhsIxcG6ha7qavGG5qXAdhkMHd5QOjhAlhYP6RWTea)E5Qy7Sq3EtMbNaGelCVgXdrHItw3saL7LRITZYB0hNQtw3sadLUnqFQBXMYg8MyKDICJradr1fFGUQBbR1K8Y32UtJStKBmcGtaBFZYdVlnCbKbV8TT70i7e5gJaUxUk2olVrFCQozDlbmu62a9syMeEMBkpevx8b6UkwQGbsWEHcDSKQ1OeFzgGkKb3zSchKWwIcnAeFzgGkKb3zScFZbW6DjVxJ4HKyC16IY9YvX2z5n6J7eLNGjAcbYyOfNo5NRYm1AacNb4RAJbgH3LQ1eeCzNi3yea3vXsfOrB0Wfqg8Y32UtJStKBmcGdPBjaMKsj)e4maFvBma93VxUk2olVrFClr3md(NGzOfN(eeCzNi3yea3vXsfOrZ6JJZ)5ClWy8sX)IG)NOrlCbKb3j2ymnUjMbdZTtGjDccUp1kJ8C)fCxflvqQwtqWDIngJ8C)fCxflvGgnv3cwRj5oXgJPXnXmyyGZ4eW23SmGQBbR1KClr3md(NGHZ(ep2oPW1MK0OforgcES2GjAdBHhOB9XX5wIUzg8pbdN9jESDEVCvSDwEJ(4waPaek3uEOfN(eeCzNi3yea3vXsfOrZ6JJZ)5ClWy8sX)IG)NOrlCbKb3j2ymnUjMbdZTtGjDccUp1kJ8C)fCxflvqQwtqWDIngJ8C)fCxflvGgnv3cwRj5oXgJPXnXmyyGZ4eW23SmGQBbR1KClGuacLBkZzFIhBNu4AtsA0cNidbpwBWeTHTWd0T(44ClGuacLBkZzFIhBN3lxfBNL3OpUyLNJIHc9NjBdzm0It36JJZ)5ClWykbbs5yM)NUxJ4HOGPckbXfhs7UqCiLNhkiRSmqo0yp0uhqgRloK1hhVm0HaxnFiHxInLpewVFOcO6Kv4hAKqSIvIfyhA2jSdPAgWouS2WH8YH8dfKvwgihk6drjathAJdraN5wcGFVCvSDwEJ(4EQGsqCHr5cXqlo9ji4YorUXiaURILkqJM1hhN)Z5wGX4LI)fb)prJw4cidUtSXyACtmdgMBNat6eeCFQvg55(l4UkwQGuTMGG7eBmg55(l4UkwQanAQUfSwtYDIngtJBIzWWaNXjGTVzzav3cwRj5EQGsqCHr5cbN9jESDsHRnjPrlCIme8yTbt0g2cpqhR3VxUk2olVrFCNO8emtFrbgAXP7QyPcgib7fkdq)zA00I8tGZa8vTXa0Fxk5NRYm1AacNb4RAJbOpcpwY7LRITZYB0hhFjGLOB2qlo9ji4YorUXiaURILkqJM1hhN)Z5wGX4LI)fb)prJw4cidUtSXyACtmdgMBNat6eeCFQvg55(l4UkwQGuTMGG7eBmg55(l4UkwQanAQUfSwtYDIngtJBIzWWaNXjGTVzzav3cwRj54lbSeDZ4SpXJTtkCTjjnAHtKHGhRnyI2Ww4b6wFCCo(salr3mo7t8y78E5Qy7S8g9XTCztJBcYQOSm0It36JJZ)5ClWykbbs5yM)NK6QyPcgib7fk0X6EnIhIcvFZW3Ct5drHYs(ciJdrHr4YF4qB5q(HMiBt2aZ9YvX2z5n6J3)WIaoLdT40zDWPUKVaYWmjC5pWjaobkZULaKoA4cid(pNBbgJLyLNdPJs8LzaQqgCNXkCqcBjk3lxfBNL3OpE)dlc4uo0ItN1bN6s(cidZKWL)aNa4eOm7wcqQwJgUaYG)Z5wGXyjw55GgTWfqg8Fo3cmglXkphsvDlyTMK)Z5wGXyjw55GtaBFZIKsDvSubdKG9cLbO)89YvX2z5n6J3)WIaoLdT40j)eWBImWl)jGucIVPuTyDWXjDjm4avGWjaobkZULaOrJ1b3s0nZmjC5pWjaobkZULaK8EnIhIcQITZdnMTeL7LRITZYB0hx5cHXvX2PrSLyO0Tb6QMkKEgL7LRITZYB0hx5cHXvX2PrSLyO0Tb6QUfSwtwUxUk2olVrFCYpnUk2onITedLUnq3BWuG4pn0It3vXsfmqc2lugG(Zs1s1TG1Asod8y24jZWaLJHtaBFZYdy9yPJgUaYGZa8va0OP6wWAnjNb4Ra4eW23S8awpwA4cidodWxbiP0rzGhZgpzggOCm8yvuUP89YvX2z5n6Jt(PXvX2PrSLyO0Tb6EdgRpPedT40DvSubdKG9cLbO)Sug4XSXtMHbkhdpwfLBkFVCvSDwEJ(4KFACvSDAeBjgkDBGUmKazvgVHHwC6UkwQGbsWEHYa0FwQwJYapMnEYmmq5y4XQOCtzPAP6wWAnjNbEmB8KzyGYXWjGTVzzaSES0rdxazWza(kaA0uDlyTMKZa8vaCcy7BwgaRhlnCbKbNb4RaKuY7LRITZYB0hx5cHXvX2PrSLyO0Tb6YqcKvn0It3vXsfmqc2luOJ196EnIhIc2s8h6PpPe3lxfBNfU3GX6tkbDyAzG9QgAXPt(5QmtTgGWza(Q24bTW6XVXapMnuMR8CWX10)Kbmt4ezikuy1MKszGhZgkZvEo44A6FYaMjCImeLhgbPJs1jRBja(u3InLn4nXi7e5gJaOrZ6JJZlACI9MYg7Te8)09YvX2zH7nyS(Ks8g9XHPLb2RAOfNo5NRYm1AacNb4RAJhE(DPmWJzdL5kphCCn9pzaZeorgIYaVlDuQozDlbWN6wSPSbVjgzNi3yeW9YvX2zH7nyS(Ks8g9XHPLb2RAOfN(OmWJzdL5kphCCn9pzaZeorgII0rP6K1TeaFQBXMYg8MyKDICJra0OHVYZHHa2(MLhENgnIVmdqfYG7mwHdsylrrkXxMbOczWDgRWjGTVz5H3VxUk2olCVbJ1NuI3OpUM(NmtzcsgqUxUk2olCVbJ1NuI3OpomTmWEvdT40hLQtw3sa8PUfBkBWBIr2jYngbCVUxJ4HOGTe)H0H4pDVCvSDw4EdMce)j6EIXWs2qloDg4XSHYCLNdoUM(NmGzcNidrza6kmkbyGeSxOqJgXxMbOczWDgRWbjSLOiL4lZauHm4oJv4eW23S8aDSW6E5Qy7SW9gmfi(tVrFCpXyyjBOfNod8y2qzUYZbhxt)tgWmHtKHOma93VxUk2olCVbtbI)0B0hhMwgyVQHwC6Js1jRBja(u3InLn4nXi7e5gJaUxUk2olCVbtbI)0B0hhhkbq2u2ucYsjmKcJsaMWjYquOJ1qloDgy9XX54qjaYMYgn9pz8s4kkFGU2KQ6wWAnj3NALlWmvaobS9nlpOT7LRITZc3BWuG4p9g9XXHsaKnLnLGSucdPWOeGjCImef6yn0ItNbwFCCooucGSPSrt)tgVeUIYhW6E5Qy7SW9gmfi(tVrFCCOeaztztjilLWqkmkbycNidrHowdT40j)e4XAdMOnJ9bTuDlyTMKZapMnEYmmq5y4eW23SiD0WfqgCgGVcGgnv3cwRj5maFfaNa2(MfPHlGm4maFfGK3R71iEikmDSDwoKNSd1XmqouNh6xG7LRITZcx1TG1AYc9Po2ohAXPpbbx2jYngbWDvSubA0S(448Fo3cmgVu8Vi4)jA0cxazWDIngtJBIzWWC7eys1AccUtSXyKN7VG7QyPc0Onbb3NALrEU)cURILkqJMQBbR1KCNyJX04MygmmWzCcy7BwgiCIme8yTbt0g2csEVCvSDw4QUfSwtwEJ(4)cy2aShkDBG(Mff5hULams03Z4BBya1vbdT401s1TG1As(pNBbgJLyLNdobS9nl0OP6wWAnjN5eknbXZcEtS9y7KtaBFZIKs1AccUtSXyKN7VG7QyPc0Onbb3NALrEU)cURILkiD0WfqgCNyJX04Mygmm3obgnAHtKHGhRnyI2mPcZZp(H3L8E5Qy7SWvDlyTMS8g9X)fWSbypu62aDBx5weWuMbim2)YQgAXPR6wWAnj3NALlWmvaobS9nlp8UuTgfKO)onbm(Mff5hULams03Z4BBya1vb0OP6wWAnjFZII8d3sagj67z8TnmG6QaobS9nlsEVCvSDw4QUfSwtwEJ(4)cy2aShkDBGoJaodFjGHkukGyOfNUQBbR1KCFQvUaZub4eW23SiL8tGhRnyI2m2hKvmPAnkir)DAcy8nlkYpClbyKOVNX32WaQRcOrt1TG1As(Mff5hULams03Z4BBya1vbCcy7BwK8E5Qy7SWvDlyTMS8g9X)fWSbypu62aDMtO0U70WafLgQnXvBGzOfNUQBbR1KCFQvUaZub4eW23SivRrbj6VttaJVzrr(HBjaJe99m(2ggqDvanAQUfSwtY3SOi)WTeGrI(EgFBddOUkGtaBFZIK3lxfBNfUQBbR1KL3Op(VaMna7YqloDv3cwRj5(uRCbMPcWjGTVzrQwJcs0FNMagFZII8d3sagj67z8TnmG6QaA0uDlyTMKVzrr(HBjaJe99m(2ggqDvaNa2(MfjVxJ4H0E3cwRjl3lxfBNfUQBbR1KL3OpUtSXyACtmdgg4SHwC6mW6JJZXHsaKnLnA6FY4)jPQUfSwtY)5ClWySeR8CWjGTVz5bTjv1TG1AsoZjuAcINf8My7X2jNa2(MLh0M0Wfqg8Fo3cmglXkph0OnA4cid(pNBbgJLyLNJ71iEiDmP6qpjw554qA2y(qJStO8qdt8SG3eBp2op0IFOFSIvIDt5d1Xmqo0i7ekp0Wepl4nX2JTZdz9XXldDOyUlWHSGnLp0idotSqjoK27vm0HgjIaPe7cSdrHANLG0LnWCOMCij(aiPlo0iX)ugi8drbfL(qQzqrz5ql(HuDY2y7SCiNahYgIdf9H2SeGZo0ClyhcVjhIco1kxGzQa87LRITZcx1TG1AYYB0h)NZTaJXsSYZXqloDQozDlbWlHzs4zUPSuTuDlyTMK7eBmMg3eZGHboJtaBFZYaVtJgd8y2qzUYZbNTf3sagVdMKs1s1TG1AsoZjuAcINf8My7X2jNa2(MLhKvmA0S(44CMtO0eepl4nX2JTt(FssPAnk5NaEtKbodCMyHsyu9kOrB0WfqgCNyJX04Mygmm3obgnAQoz)n4QoP2kp2onnUjMbddCgN4jLp8UK3Rr8q6ys1HEsSYZXH0SX8HOGtTYfyMkWHw8dfZWHuDlyTM8qn(HOGtTYfyMkWH2YHeTMdbz)LN5hsIbKO)sGYHgzWzIfkXH0EVIHoK27KAR8y78qn(HIz4qJm4Sd5j7quqInMd14hkMHdnYUDcSdfTmeZaHFVCvSDw4QUfSwtwEJ(4)CUfymwIvEogAXP7QyPcgib7fk0XskdS(44CCOeaztzJM(NmEjCfLdqFSsdxazW)5ClWySeR8CivRWfqg8Fo3cmgVu8ViKQ6K93GR6KAR8y7004MygmmWzCINu(W70OfUaYGl7e5gJaK8E5Qy7SWvDlyTMS8g9X)5ClWySeR8Cm0It3vXsfmqc2lugG(Z3lxfBNfUQBbR1KL3OpoZjuAcINf8My7X25qloDQozDlbWlHzs4zUPSuTyG1hhN)Z5wGXyjw55WWaRpoo)prJ2OHlGm4)CUfymwIvEoK8E5Qy7SWvDlyTMS8g9XzoHstq8SG3eBp2ohAXP7QyPcgib7fkdq)57LRITZcx1TG1AYYB0h3NALlWmvGHwC6UkwQGbsWEHcDSKYaRpoohhkbq2u2OP)jJxcxr5a0hR0Wfqg8Fo3cmglXkphsdxazWDIngtJBIzWWC7eysj)eWBImWzGZelucJQxHuvNS)gCvNuBLhBNMg3eZGHboJt8KYbO)(9YvX2zHR6wWAnz5n6J7tTYfyMkWqloDgy9XX54qjaYMYgn9pz8s4kkhG(yL6QyPcgib7fk0XsA4cid(pNBbgJLyLNdPQoz)n4QoP2kp2onnUjMbddCgN4jLdq)DPHlGm4oXgJPXnXmyyUDcmPKFc4nrg4mWzIfkHr1RqkdS(448Fo3cmglXkphggy9XX5)P7LRITZcx1TG1AYYB0h3NALlWmvGHwC6UkwQGbsWEHcDSKYaRpoohhkbq2u2OP)jJxcxr5a0hR0rdxazW)5ClWySeR8CqJw4cidUtSXyACtmdgMBNatQwJs(jG3ezGZaNjwOegvVcA0uDY(BWvDsTvESDAACtmdgg4moXtkF4DjPrlCbKb)NZTaJXlf)lcPQoz)n4QoP2kp2onnUjMbddCgN4jLdq)97LRITZcx1TG1AYYB0h3NALlWmvGHuyucWeorgIcDSgAXP7QyPcgib7fkdq)zPmW6JJZXHsaKnLnA6FY4LWvuoa9XkDug4XSXtMHbkhdpwfLBkFVCvSDw4QUfSwtwEJ(4LVTDNgzNi3yeWqloDYpxLzQ1aeodWx1gpG1yVxUk2olCv3cwRjlVrF8Fo3cmgVu8VigAXPt1jRBjaEjmtcpZnLLYaRpoohhkbq2u2OP)jJxcxr5dplvRji4(uRmYZ9xWDvSubA0uDY(BWvDsTvESDAACtmdgg4mPwFCCoZjuAcINf8My7X2j)pjD0ji4oXgJrEU)cURILki59YvX2zHR6wWAnz5n6J)Z5wGX4LI)fXqkmkbycNidrHowdT40DvSubdKG9cLbO)Sugy9XX54qjaYMYgn9pz8s4kkF457LRITZcx1TG1AYYB0hV0FHHa(eqgsHrjat4ezik0XAOfNE4ezi4XAdMOntQWOT3F4DPHtKHGhRnyI2WwyG3VxUk2olCv3cwRjlVrFCIVfWWaNn0ItF0ji4YZ9xWDvSuH7LRITZcx1TG1AYYB0hV4kYIVQ1fMjxfdT40DvSubdKG9cLbO)S0rT(44CMtO0eepl4nX2JTt(Fs6OQUfSwtYzoHstq8SG3eBp2o5eWzyUx3Rr8qAVPcPNXHOGwRyJfk3lxfBNfUQPcPNrHErJtS3u2yVLyOfNovNSULa4LWmj8m3uwk5NRYm1AacNb4RAJbgH71iEiDiou0h6xGd54bqoKp1QdTLd15H0(iFiVCOOp0ebOczCOMkqu(00MYhsIHcZH0mVc4qfiInLp0F6qAFKXUCVCvSDw4QMkKEgL3OpErJtS3u2yVLyOfNUQBbR1KCFQvUaZub4eW23SivlxflvWajyVqza6pl1vXsfmqc2luEG(7sj)CvMPwdq4maFvBmGwUkwQGbsWEHcf2rqsA0CvSubdKG9cLbExk5NRYm1AacNb4RAJb02JL8E5Qy7SWvnvi9mkVrFC3QT30JTtJyTTgAXPt1jRBjaEjmtcpZnLLoAP)cRnzCb4mJfgdib3EsasvDlyTMK7tTYfyMkaNa2(MfPKFc8yTbt0MXoGwA7nRpooN8ZvzunH8NITtobS9nlsEVCvSDw4QMkKEgL3OpUB12B6X2PrS2wdT40P6K1TeaVeMjHN5MYsl9xyTjJlaNzSWyaj42tcqQwQUfSwtY)5ClWySeR8CWjGTVzHgTrdxazW)5ClWySeR8Civ1TG1AsoZjuAcINf8My7X2jNa2(MfjVxUk2olCvtfspJYB0h3TA7n9y70iwBRHwC6UkwQGbsWEHYa0Fwk5NapwBWeTzSdOL2EZ6JJZj)Cvgvti)Py7KtaBFZIK3lxfBNfUQPcPNr5n6JxMDfLcWeZG5NAAsmJzOfNovNSULa4LWmj8m3uwQQBbR1KCFQvUaZub4eW23SCVCvSDw4QMkKEgL3OpEz2vukatmdMFQPjXmMHwC6UkwQGbsWEHYa0FwQwmWJzJNmdduogESkk3uMgnIVmdqfYG7mwHtaBFZYd0XASsEVUxJ4H03uwahAyNidX9YvX2zHldjqwfDg4XSr1RyOfNU1hhNx(mgKgw32Cc4Qq6OuDY6wcGp1TytzdEtmYorUXiaA0MGGl7e5gJa4UkwQW9YvX2zHldjqw1B0hNbEmBu9kgAXPt(5QmtTgGWza(Q24bS0M0rP6K1TeaFQBXMYg8MyKDICJra3lxfBNfUmKazvVrFCpXyyjBOfNUQBbR1KCFQvUaZub4eW23SivRWfqgCgGVcGdPBjagnAQMkKEg8CLNddUd0Or(jG3ezGpndoPT7eksEVCvSDw4YqcKv9g9X10)KzktqYaYqloDgy9XX54qjaYMYgn9pz8s4kkhyS3lxfBNfUmKazvVrFCn9pzMYeKmGm0ItNbwFCCooucGSPSrt)tg)pjv1TG1AsUp1kxGzQaCcy7Bwg4DPAnA4cid(pNBbgJLyLNdA0cxazWDIngtJBIzWWC7ey0OP6K93GR6KAR8y7004MygmmWz0Or8LzaQqgCNXkCqcBjksEVCvSDw4YqcKv9g9X10)KzktqYaYqloDgy9XX54qjaYMYgn9pz8)K0Wfqg8Fo3cmglXkphshnCbKb3j2ymnUjMbdZTtGjDuIVmdqfYG7mwHdsylrrQwQUfSwtY)5ClWySeR8CWjGTVzzG3LQ6wWAnj3NALlWmvaobCggPJY6G)Z5wGXyjw55GtaBFZcnAJQ6wWAnj3NALlWmvaobCggjVxUk2olCzibYQEJ(4mWJzJQxXqloDYpxLzQ1aeodWx1gp88JLokvNSULa4tDl2u2G3eJStKBmc4E5Qy7SWLHeiR6n6JJdLaiBkBkbzPegAXPZaRpoohhkbq2u2OP)jJxcxr5dyDVCvSDw4YqcKv9g9XXHsaKnLnLGSucdT40zG1hhNJdLaiBkB00)KXlHRO8HXkv1TG1AsUp1kxGzQaCcy7BwEqBs1A0Wfqg8Fo3cmglXkph0OfUaYG7eBmMg3eZGH52jWOrt1j7Vbx1j1w5X2PPXnXmyyGZOrJ4lZauHm4oJv4Ge2suK8E5Qy7SWLHeiR6n6JJdLaiBkBkbzPegAXPZaRpoohhkbq2u2OP)jJxcxr5dJvA4cid(pNBbgJLyLNdPJgUaYG7eBmMg3eZGH52jWKokXxMbOczWDgRWbjSLOiv1TG1AsUp1kxGzQaCc4mms1s1TG1As(pNBbgJLyLNdobS9nlpOnA0yG1hhN)Z5wGXyjw55WWaRpoo)pj59YvX2zHldjqw1B0hNbEmBu9kgAXPpkvNSULa4tDl2u2G3eJStKBmc4EDVgXdnscjqw1HOGTe)HOWq2MSbM7LRITZcxgsGSkJ3aDyAzG9QgAXPB9XX5LpJbPH1TnNaUkUxUk2olCzibYQmEdVrFCyAzG9QgAXPpkvNSULa4tDl2u2G3eJStKBmc4E5Qy7SWLHeiRY4n8g9X10)KzktqYaYqkmkbycNidrHowdT401s1TG1AsUp1kxGzQaCcy7Bwg4DPmW6JJZXHsaKnLnA6FY4)jA0yG1hhNJdLaiBkB00)KXlHROCGXkPuTWx55WqaBFZYdQUfSwtYzGhZgpzggOCmCcy7BwEdRhtJg(kphgcy7Bwgq1TG1AsUp1kxGzQaCcy7BwK8E5Qy7SWLHeiRY4n8g9XXHsaKnLnLGSucdPWOeGjCImef6yn0ItNbwFCCooucGSPSrt)tgVeUIYhORnPQUfSwtY9Pw5cmtfGtaBFZYdAJgngy9XX54qjaYMYgn9pz8s4kkFaR7LRITZcxgsGSkJ3WB0hhhkbq2u2ucYsjmKcJsaMWjYquOJ1qloDv3cwRj5(uRCbMPcWjGTVzzG3LYaRpoohhkbq2u2OP)jJxcxr5dyv19Fm3KQU(A)fESDQDIJh1Og1k]] )

end
