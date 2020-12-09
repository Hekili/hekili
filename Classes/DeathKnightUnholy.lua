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


    spec:RegisterPack( "Unholy", 20201208, [[d8e8VbqifrpIivDjKGQnru(KQQgfsvNcPYQqck9kvrnlfKDHQFPi1WufQJPQYYuvYZiszAQc5AQk12qc4BQcOXrKuDoIuP1PkO5Pi5EeX(uahejqluvKhQiyIQc0fjsfTrvbq(OQa0ivfa1jjsfwPQIxIeezMkcDtKGK2Pc0prcIAOibflLiP4PKYuvqDvvbGTIeK4RibHXIeAVs6Vu1GHCyklMk9ysMmkxgSzO6ZKQrROoTsRgji1RrIMnHBtf7w0VLA4k0XjsYYr8CjMUW1HY2rsFNOA8ejoVQ06jsknFKY(v56V6WvnMfqDWVE8xp(3xpwQZ)jDLM0vAuGQw8ocvTrtrPPdvT0CGQ2dGCUfVvTr7v0gRoCvR0yefu1MJyS8WPNwFJzmxUQDMUSoycl2ovedpMUSoQPRAUyRiKoYQBvJzbuh8Rh)1J)91JL68FsxPjDL2JQALrqvh8RV)QQnVmgKv3QgdkQQM0FOheSy(quiLR(CCOha5ClEVps)HEqqboUa5qs9Ho0xp(RhFFUps)HOGmk0yLWbYOCOOp0dMp40piGVcy6heSyUCOhedou0hQtX7HunwghkmIoeLdjFUpKrGdbszeubWou0hsSuHdj6u)qq2y6Zhk6d5yraKdrV1GVab24HK(F0XRAITeL6WvnvtfslJsD46G)Qdx1G0CfaR(uvtr2aiRv1OAK1CfaVe(rHL5M6hs2Hiy5Q8JTCGWza(Q24qdCikqvZuX2zvRi3ioBQ7D2suJ6GFvhUQbP5kaw9PQMISbqwRQP6wWA5j3gBLjEhlaNao2MLdj7q0FitflvWdj4Sq5qdi5qFDizhYuXsf8qcoluo0uso03hs2Hiy5Q8JTCGWza(Q24qdCi6pKPILk4HeCwOCikShIcCi6oenAhYuXsf8qcoluo0ah67dj7qeSCv(Xwoq4maFvBCOboK0E8HORQzQy7SQvKBeNn19oBjQrDqPvhUQbP5kaw9PQMISbqwRQr1iR5kaEj8JclZn1pKSdn5HknMWDtgxagZ7(6bPyoJc4qYoKQBbRLNCBSvM4DSaCc4yBwoKSdrWsGhRd4J2)OdnWHO)qs7qpFixmCCoblxLx1ec2ySDYjGJTz5q0v1mvSDw1m32ztl2o9I1XTg1bFuD4QgKMRay1NQAkYgazTQgvJSMRa4LWpkSm3u)qYouPXeUBY4cWyE3xpifZzuahs2HO)qQUfSwEYXY5w86DfR(CWjGJTz5q0ODOjpuycidowo3IxVRy1NdoKMRayhs2HuDlyT8KZmcL(GyzbVjowSDYjGJTz5q0v1mvSDw1m32ztl2o9I1XTg1b)UoCvdsZvaS6tvnfzdGSwvZuXsf8qcoluo0aso0xhs2HiyjWJ1b8r7F0Hg4q0FiPDONpKlgooNGLRYRAcbBm2o5eWX2SCi6QAMk2oRAMB7SPfBNEX64wJ6GuG6WvninxbWQpv1uKnaYAvnQgznxbWlHFuyzUP(HKDiv3cwlp52yRmX7yb4eWX2Su1mvSDw1kZMIsb4JzWJLYBsm)wJ6GpW6WvninxbWQpv1uKnaYAvntflvWdj4Sq5qdi5qFDizhI(dXalM9wY8mqzV8yvuUP(HOr7qeBzEGkKb3yScNao2MLdnLKd97rhIUQMPITZQwz2uukaFmdESuEtI53AuJQM1GVab2yD46G)Qdx1G0CfaR(uvtr2aiRv1yGfZEkZvFo44YBSKbmFyeDikhAajhs9QeGhsWzHYHOr7qeBzEGkKb3ySchKYwIYHKDiITmpqfYGBmwHtahBZYHMsYH(9RQzQy7SQz5RNLSAuh8R6WvninxbWQpv1uKnaYAvngyXSNYC1NdoU8glzaZhgrhIYHgqYH(UQzQy7SQz5RNLSAuhuA1HRAqAUcGvFQQPiBaK1QAtEiQgznxbWh7wSPUhVjEDJO3VcOQzQy7SQbJldCwvnQd(O6WvninxbWQpv1mvSDw1WHsaKn19LGSucvnfzdGSwvJbUy44CCOeaztDV8glz8sykkp0usoK0oKSdP6wWA5j3gBLjEhlaNao2MLdn1HKwvt9QeGpmIoeL6G)QrDWVRdx1G0CfaR(uvZuX2zvdhkbq2u3xcYsju1uKnaYAvng4IHJZXHsaKn19YBSKXlHPO8qtDOFvn1Rsa(Wi6quQd(Rg1bPa1HRAqAUcGvFQQzQy7SQHdLaiBQ7lbzPeQAkYgazTQgblbESoGpA)Jo0uhI(dP6wWA5jNbwm7TK5zGYE5eWX2SCizhAYdfMaYGZa8vaCinxbWoenAhs1TG1YtodWxbWjGJTz5qYouycidodWxbWH0Cfa7q0v1uVkb4dJOdrPo4VAuJQgdWnmruhUo4V6WvntfBNvnNnzECcasTqvdsZvaS6t1Oo4x1HRAqAUcGvFQQ1JvTcevntfBNvnQgznxbu1OAcmOQP6wWA5jVG540Px3i69Ra4eWX2SCOPo03hs2HctazWlyooD61nIE)kaoKMRayvnQgXNMdu1g7wSPUhVjEDJO3VcOg1bLwD4QgKMRay1NQA9yvRarvZuX2zvJQrwZvavnQMadQAMkwQGhsWzHYHKCOFhs2HO)qtEiITmpqfYGBmwHdszlr5q0ODiITmpqfYGBmwHV5Hg4q)((q0v1OAeFAoqvRe(rHL5M61Oo4JQdx1G0CfaR(uvtr2aiRv1iy5Q8JTCGWza(Q24qdCikW3hs2HO)qJqW1nIE)kaUPILkCiA0o0KhkmbKbVG540Px3i69Ra4qAUcGDi6oKSdrWsGZa8vTXHgqYH(UQzQy7SQzeLLGpAcbYOg1b)UoCvdsZvaS6tvnfzdGSwvBecUUr07xbWnvSuHdrJ2HCXWX5y5ClE9wPyyIGJnEiA0ouycidUrCE9nUpMbpZCsGXH0Cfa7qYo0ieCBSvE95gtWnvSuHdj7q0FOri4gX51Rp3ycUPILkCiA0oKQBbRLNCJ486BCFmdEgymobCSnlhAGdP6wWA5j3v0nZJJrE5mmIfBNhA6djTdr3HOr7q4R(C4jGJTz5qtj5qUy44Cxr3mpog5LZWiwSDw1mvSDw1CfDZ84yK3AuhKcuhUQbP5kaw9PQMISbqwRQncbx3i69Ra4MkwQWHOr7qUy44CSCUfVERummrWXgpenAhkmbKb3ioV(g3hZGNzojW4qAUcGDizhAecUn2kV(CJj4MkwQWHKDi6p0ieCJ4861NBmb3uXsfoenAhs1TG1YtUrCE9nUpMbpdmgNao2MLdnWHuDlyT8K7cKcqOCtDodJyX25HM(qs7q0DiA0oe(QphEc4yBwo0usoKlgoo3fifGq5M6CggXITZQMPITZQMlqkaHYn1RrDWhyD4QgKMRay1NQAkYgazTQMlgoohlNBXRVeei1Jzo2yvZuX2zvtS6ZrXtHgJP7azuJ6Gs96WvninxbWQpv1uKnaYAvTri46grVFfa3uXsfoenAhYfdhNJLZT41BLIHjco24HOr7qHjGm4gX5134(yg8mZjbghsZvaSdj7qJqWTXw51NBmb3uXsfoKSdr)HgHGBeNxV(CJj4MkwQWHOr7qQUfSwEYnIZRVX9Xm4zGX4eWX2SCOboKQBbRLNClvqjiMWRmHGZWiwSDEOPpK0oeDhIgTdHV6ZHNao2MLdnLKd977QMPITZQMLkOeet4vMquJ6Gs36WvninxbWQpv1uKnaYAvntflvWdj4Sq5qdi5qFDiA0oe9hIGLaNb4RAJdnGKd99HKDicwUk)ylhiCgGVQno0asoef4XhIUQMPITZQMruwc(rmrbQrDWFpUoCvdsZvaS6tvnfzdGSwvBecUUr07xbWnvSuHdrJ2HCXWX5y5ClE9wPyyIGJnEiA0ouycidUrCE9nUpMbpZCsGXH0Cfa7qYo0ieCBSvE95gtWnvSuHdj7q0FOri4gX51Rp3ycUPILkCiA0oKQBbRLNCJ486BCFmdEgymobCSnlhAGdP6wWA5jhFjGROBgNHrSy78qtFiPDi6oenAhcF1NdpbCSnlhAkjhYfdhNJVeWv0nJZWiwSDw1mvSDw1Wxc4k6MvJ6G)(vhUQbP5kaw9PQMISbqwRQ5IHJZXY5w86lbbs9yMJnEizhYuXsf8qcoluoKKd9RQzQy7SQ5A6(g3hKvrzPg1b)9vD4QgKMRay1NQAkYgazTQgRdo1LGjGm8Jcthd4eaNaLzZvahs2HM8qHjGm4y5ClE9UIvFo4qAUcGDizhAYdrSL5bQqgCJXkCqkBjkvntfBNvTglCjGrznQd(tA1HRAqAUcGvFQQPiBaK1QASo4uxcMaYWpkmDmGtaCcuMnxbCizhI(dn5HctazWXY5w86DfR(CWH0Cfa7q0ODOWeqgCSCUfVExXQphCinxbWoKSdP6wWA5jhlNBXR3vS6ZbNao2MLdr3HKDitflvWdj4Sq5qdi5qFv1mvSDw1ASWLagL1Oo4VhvhUQbP5kaw9PQMISbqwRQrWsaVj6aVGncKsqSn5qAUcGDizhI(dX6GJt6s4XbQaHtaCcuMnxbCiA0oeRdUROBMFuy6yaNa4eOmBUc4q0v1mvSDw1ASWLagL1Oo4VVRdx1G0CfaR(uvZuX2zvtzcH3uX2PxSLOQj2s4tZbQAQMkKwgLAuh8hfOoCvdsZvaS6tvntfBNvnLjeEtfBNEXwIQMylHpnhOQP6wWA5zPg1b)9aRdx1G0CfaR(uvtr2aiRv1mvSubpKGZcLdnGKd91HKDi6pKQBbRLNCgyXS3sMNbk7LtahBZYHM6q)E8HKDOjpuycidodWxbWH0Cfa7q0ODiv3cwlp5maFfaNao2MLdn1H(94dj7qHjGm4maFfahsZvaSdr3HKDOjpedSy2BjZZaL9YJvr5M6vntfBNvncw6nvSD6fBjQAITe(0CGQM1GVab2ynQd(tQxhUQbP5kaw9PQMISbqwRQzQyPcEibNfkhAajh6Rdj7qmWIzVLmpdu2lpwfLBQx1mvSDw1iyP3uX2PxSLOQj2s4tZbQAwdExmsjQrDWFs36WvninxbWQpv1uKnaYAvntflvWdj4Sq5qdi5qFDizhI(dn5HyGfZElzEgOSxESkk3u)qYoe9hs1TG1YtodSy2BjZZaL9YjGJTz5qdCOFp(qYo0KhkmbKbNb4Ra4qAUcGDiA0oKQBbRLNCgGVcGtahBZYHg4q)E8HKDOWeqgCgGVcGdP5ka2HO7q0v1mvSDw1iyP3uX2PxSLOQj2s4tZbQA6qcKv5TgQrDWVECD4QgKMRay1NQAkYgazTQMPILk4HeCwOCijh6xvZuX2zvtzcH3uX2PxSLOQj2s4tZbQA6qcKvvJAu1gjGQDCTOoCDWF1HRAMk2oRAJDSDw1G0CfaR(unQd(vD4QgKMRay1NQAP5avntQTmBeR4X7m8nUFSLdKQMPITZQMj1wMnIv84Dg(g3p2YbsnQdkT6WvntfBNvnITfWZaJv1G0CfaR(unQrvt1TG1YZsD46G)Qdx1G0CfaR(uvtr2aiRv1gHGRBe9(vaCtflv4q0ODixmCCowo3IxVvkgMi4yJhIgTdfMaYGBeNxFJ7JzWZmNeyCinxbWoKSdr)HgHGBeNxV(CJj4MkwQWHOr7qJqWTXw51NBmb3uXsfoenAhs1TG1YtUrCE9nUpMbpdmgNao2MLdnWHWx95WtahBZYHORQzQy7SQn2X2znQd(vD4QgKMRay1NQAMk2oRABwueSWCfGxQWSmWC8mG6QGQMISbqwRQr)HuDlyT8KJLZT417kw95GtahBZYHOr7qQUfSwEYzgHsFqSSG3ehl2o5eWX2SCi6oKSdr)HgHGBeNxV(CJj4MkwQWHOr7qJqWTXw51NBmb3uXsfoKSdn5HctazWnIZRVX9Xm4zMtcmoKMRayhIgTdfgrhcESoGpA)Ok8F94dn1H((q0v1sZbQABwueSWCfGxQWSmWC8mG6QGAuhuA1HRAqAUcGvFQQzQy7SQ5ykZLa(YmaH3bRSQQMISbqwRQP6wWA5j3gBLjEhlaNao2MLdn1H((qYoe9hAYdbsf2oocm(Mffblmxb4LkmldmhpdOUk4q0ODiv3cwlp5BwueSWCfGxQWSmWC8mG6QaobCSnlhIUQwAoqvZXuMlb8LzacVdwzv1Oo4JQdx1G0CfaR(uvZuX2zvJraJHVeWtfkfqu1uKnaYAvnv3cwlp52yRmX7yb4eWX2SCizhIGLapwhWhT)rhAQdPRyhs2HO)qtEiqQW2XrGX3SOiyH5kaVuHzzG54za1vbhIgTdP6wWA5jFZIIGfMRa8sfMLbMJNbuxfWjGJTz5q0v1sZbQAmcym8LaEQqPaIAuh876WvninxbWQpv1mvSDw1ygHsNUtpduu6P2etTXBvtr2aiRv1uDlyT8KBJTYeVJfGtahBZYHKDi6p0KhcKkSDCey8nlkcwyUcWlvywgyoEgqDvWHOr7qQUfSwEY3SOiyH5kaVuHzzG54za1vbCc4yBwoeDvT0CGQgZiu60D6zGIsp1MyQnERrDqkqD4QgKMRay1NQAkYgazTQMQBbRLNCBSvM4DSaCc4yBwoKSdr)HM8qGuHTJJaJVzrrWcZvaEPcZYaZXZaQRcoenAhs1TG1Yt(Mffblmxb4LkmldmhpdOUkGtahBZYHORQzQy7SQHva)gGtPg1bFG1HRAqAUcGvFQQPiBaK1QAmWfdhNJdLaiBQ7L3yjJJnEizhs1TG1Ytowo3IxVRy1NdobCSnlhAQdjTdj7qQUfSwEYzgHsFqSSG3ehl2o5eWX2SCOPoK0oKSdfMaYGJLZT417kw95GdP5ka2HOr7qtEOWeqgCSCUfVExXQphCinxbWQAMk2oRAgX5134(yg8mWy1OoOuVoCvdsZvaS6tvnfzdGSwvJQrwZva8s4hfwMBQFizhI(dP6wWA5j3ioV(g3hZGNbgJtahBZYHg4qFFi6oKSdr)HuDlyT8KZmcL(GyzbVjowSDYjGJTz5qtDiDf7q0ODixmCCoZiu6dILf8M4yX2jhB8q0DizhI(dn5HiyjG3eDGZaJjwOeEvVcoKMRayhIgTdn5HctazWnIZRVX9Xm4zMtcmoKMRayhIgTdP6KHTbx1j1wzX2PVX9Xm4zGX4elP8qtDOVpeDvntfBNvnSCUfVExXQph1OoO0ToCvdsZvaS6tvnfzdGSwvJQrwZva8s4hfwMBQFizhI(dP6wWA5j3ioV(g3hZGNbgJtahBZYHg4qFFi6oKSdrWsaVj6aNbgtSqj8QEfCinxbWoKSdfMaYGBeNxFJ7JzWZmNeyCinxbWoKSdP6KHTbx1j1wzX2PVX9Xm4zGX4elP8qdi5qFFizhs1TG1YtUn2kt8owaobCSnlhAQdjTQMPITZQgwo3IxVRy1NJAuh83JRdx1G0CfaR(uvtr2aiRv1mvSubpKGZcLdnGKd9vvZuX2zvdlNBXR3vS6ZrnQd(7xD4QgKMRay1NQAkYgazTQgvJSMRa4LWpkSm3u)qYoe9hIbUy44CSCUfVExXQphEg4IHJZXgpenAhAYdfMaYGJLZT417kw95GdP5ka2HORQzQy7SQXmcL(GyzbVjowSDwJ6G)(QoCvdsZvaS6tvnfzdGSwvZuXsf8qcoluo0aso0xvntfBNvnMrO0hell4nXXITZAuh8N0Qdx1G0CfaR(uvtr2aiRv1mvSubpKGZcLdj5q)oKSdXaxmCCooucGSPUxEJLmEjmfLhAajh6rhs2HctazWXY5w86DfR(CWH0Cfa7qYouycidUrCE9nUpMbpZCsGXH0Cfa7qYoeblb8MOdCgymXcLWR6vWH0Cfa7qYoKQtg2gCvNuBLfBN(g3hZGNbgJtSKYdnGKd9DvZuX2zvZgBLjEhlqnQd(7r1HRAqAUcGvFQQPiBaK1QAMkwQGhsWzHYHKCOFhs2HyGlgoohhkbq2u3lVXsgVeMIYdnGKd9Odj7qHjGm4y5ClE9UIvFo4qAUcGDizhI(dfMaYGJLZT41BLIHjcoKMRayhs2HuDYW2GR6KARSy7034(yg8mWyCILuEOPo03hIgTdfMaYGRBe9(vaCinxbWoeDvntfBNvnBSvM4DSa1Oo4VVRdx1G0CfaR(uvtr2aiRv1mvSubpKGZcLdj5q)oKSdXaxmCCooucGSPUxEJLmEjmfLhAajh6rhs2HO)qtEOWeqgCSCUfVExXQphCinxbWoenAhkmbKb3ioV(g3hZGNzojW4qAUcGDizhI(dn5HiyjG3eDGZaJjwOeEvVcoKMRayhIgTdP6KHTbx1j1wzX2PVX9Xm4zGX4elP8qtDOVpeDhIgTdfMaYGJLZT41BLIHjcoKMRayhs2HuDYW2GR6KARSy7034(yg8mWyCILuEObKCOVpeDvntfBNvnBSvM4DSa1Oo4pkqD4QgKMRay1NQAMk2oRA2yRmX7ybQAkYgazTQMPILk4HeCwOCObKCOVoKSdXaxmCCooucGSPUxEJLmEjmfLhAajh6rhs2HM8qmWIzVLmpdu2lpwfLBQx1uVkb4dJOdrPo4VAuh83dSoCvdsZvaS6tvnfzdGSwvJGLRYp2YbcNb4RAJdn1H(9OQMPITZQwbZXPtVUr07xbuJ6G)K61HRAqAUcGvFQQPiBaK1QAunYAUcGxc)OWYCt9dj7qmWfdhNJdLaiBQ7L3yjJxctr5HM6qFDizhI(dncb3gBLxFUXeCtflv4q0ODivNmSn4QoP2kl2o9nUpMbpdmghsZvaSdj7qUy44CMrO0hell4nXXITto24HKDOjp0ieCJ4861NBmb3uXsfoeDvntfBNvnSCUfVERummruJ6G)KU1HRAqAUcGvFQQzQy7SQHLZT41BLIHjIQMISbqwRQzQyPcEibNfkhAajh6Rdj7qmWfdhNJdLaiBQ7L3yjJxctr5HM6qFv1uVkb4dJOdrPo4VAuh8RhxhUQbP5kaw9PQMPITZQwPXeEcyJaPQPiBaK1QAHr0HGhRd4J2pQcV0((qtDOVpKSdfgrhcESoGpApBHdnWH(UQPEvcWhgrhIsDWF1Oo4x)Qdx1G0CfaR(uvtr2aiRv1M8qJqW1NBmb3uXsfQAMk2oRAeBlGNbgRg1b)6R6WvninxbWQpv1uKnaYAvntflvWdj4Sq5qdi5qFDizhAYd5IHJZzgHsFqSSG3ehl2o5yJhs2HM8qQUfSwEYzgHsFqSSG3ehl2o5eWyVvntfBNvTIPil(Qwt4hnvuJAu10HeiRYBnuhUo4V6WvninxbWQpv1uKnaYAvnxmCCEbJXG0Z62HtatfvntfBNvnyCzGZQQrDWVQdx1G0CfaR(uvtr2aiRv1M8qunYAUcGp2TytDpEt86grVFfqvZuX2zvdgxg4SQAuhuA1HRAqAUcGvFQQzQy7SQjVXsMVmcjdivnfzdGSwvJ(dP6wWA5j3gBLjEhlaNao2MLdnWH((qYoedCXWX54qjaYM6E5nwY4yJhIgTdXaxmCCooucGSPUxEJLmEjmfLhAGd9Odr3HKDi6pe(QphEc4yBwo0uhs1TG1YtodSy2BjZZaL9YjGJTz5qpFOFp(q0ODi8vFo8eWX2SCOboKQBbRLNCBSvM4DSaCc4yBwoeDvn1Rsa(Wi6quQd(Rg1bFuD4QgKMRay1NQAMk2oRA4qjaYM6(sqwkHQMISbqwRQXaxmCCooucGSPUxEJLmEjmfLhAkjhsAhs2HuDlyT8KBJTYeVJfGtahBZYHM6qs7q0ODig4IHJZXHsaKn19YBSKXlHPO8qtDOFvn1Rsa(Wi6quQd(Rg1b)UoCvdsZvaS6tvntfBNvnCOeaztDFjilLqvtr2aiRv1uDlyT8KBJTYeVJfGtahBZYHg4qFFizhIbUy44CCOeaztDV8glz8sykkp0uh6xvt9QeGpmIoeL6G)QrnQAwdExmsjQdxh8xD4QgKMRay1NQAkYgazTQgblxLFSLdeodWx1ghAQdr)H(94d98HyGfZEkZvFo44YBSKbmFyeDikhIc7HK2HO7qYoedSy2tzU6ZbhxEJLmG5dJOdr5qtDikWHKDOjpevJSMRa4JDl2u3J3eVUr07xbCiA0oKlgooVi3ioBQ7D2sWXgRAMk2oRAW4YaNvvJ6GFvhUQbP5kaw9PQMISbqwRQrWYv5hB5aHZa8vTXHM6qF99HKDigyXSNYC1NdoU8glzaZhgrhIYHg4qFFizhAYdr1iR5ka(y3In194nXRBe9(vavntfBNvnyCzGZQQrDqPvhUQbP5kaw9PQMISbqwRQn5HyGfZEkZvFo44YBSKbmFyeDikhs2HM8qunYAUcGp2TytDpEt86grVFfWHOr7q4R(C4jGJTz5qtDOVpenAhIylZduHm4gJv4Gu2suoKSdrSL5bQqgCJXkCc4yBwo0uh67QMPITZQgmUmWzv1Oo4JQdx1mvSDw1K3yjZxgHKbKQgKMRay1NQrDWVRdx1G0CfaR(uvtr2aiRv1M8qunYAUcGp2TytDpEt86grVFfqvZuX2zvdgxg4SQAuJQMoKazv1HRd(RoCvdsZvaS6tvnfzdGSwvZfdhNxWymi9SUD4eWuXHKDOjpevJSMRa4JDl2u3J3eVUr07xbCiA0o0ieCDJO3VcGBQyPcvntfBNvngyXSx1ROg1b)QoCvdsZvaS6tvnfzdGSwvJGLRYp2YbcNb4RAJdn1H(jTdj7qtEiQgznxbWh7wSPUhVjEDJO3VcOQzQy7SQXalM9QEf1OoO0Qdx1G0CfaR(uvtr2aiRv1uDlyT8KBJTYeVJfGtahBZYHKDi6puycidodWxbWH0Cfa7q0ODivtfsldEU6ZHh3GdrJ2HiyjG3eDGpodgPD6ekCinxbWoeDvntfBNvnlF9SKvJ6GpQoCvdsZvaS6tvnfzdGSwvJbUy44CCOeaztDV8glz8sykkp0ah6rvntfBNvn5nwY8LrizaPg1b)UoCvdsZvaS6tvnfzdGSwvJbUy44CCOeaztDV8glzCSXdj7qQUfSwEYTXwzI3XcWjGJTz5qdCOVpKSdr)HM8qHjGm4y5ClE9UIvFo4qAUcGDiA0ouycidUrCE9nUpMbpZCsGXH0Cfa7q0ODivNmSn4QoP2kl2o9nUpMbpdmghsZvaSdrJ2Hi2Y8avidUXyfoiLTeLdrxvZuX2zvtEJLmFzesgqQrDqkqD4QgKMRay1NQAkYgazTQgdCXWX54qjaYM6E5nwY4yJhs2HctazWXY5w86DfR(CWH0Cfa7qYo0KhkmbKb3ioV(g3hZGNzojW4qAUcGDizhAYdrSL5bQqgCJXkCqkBjkhs2HO)qQUfSwEYXY5w86DfR(CWjGJTz5qdCOVpKSdP6wWA5j3gBLjEhlaNag79qYo0KhI1bhlNBXR3vS6ZbNao2MLdrJ2HM8qQUfSwEYTXwzI3XcWjGXEpeDvntfBNvn5nwY8LrizaPg1bFG1HRAqAUcGvFQQPiBaK1QAeSCv(Xwoq4maFvBCOPo0xp(qYo0KhIQrwZva8XUfBQ7XBIx3i69RaQAMk2oRAmWIzVQxrnQdk1Rdx1G0CfaR(uvtr2aiRv1yGlgoohhkbq2u3lVXsgVeMIYdn1H(v1mvSDw1WHsaKn19LGSuc1OoO0ToCvdsZvaS6tvnfzdGSwvJbUy44CCOeaztDV8glz8sykkp0uh6rhs2HuDlyT8KBJTYeVJfGtahBZYHM6qs7qYoe9hAYdfMaYGJLZT417kw95GdP5ka2HOr7qHjGm4gX5134(yg8mZjbghsZvaSdrJ2HuDYW2GR6KARSy7034(yg8mWyCinxbWoenAhIylZduHm4gJv4Gu2suoeDvntfBNvnCOeaztDFjilLqnQd(7X1HRAqAUcGvFQQPiBaK1QAmWfdhNJdLaiBQ7L3yjJxctr5HM6qp6qYouycidowo3IxVRy1NdoKMRayhs2HM8qHjGm4gX5134(yg8mZjbghsZvaSdj7qtEiITmpqfYGBmwHdszlr5qYoKQBbRLNCBSvM4DSaCcyS3dj7q0Fiv3cwlp5y5ClE9UIvFo4eWX2SCOPoK0oenAhIbUy44CSCUfVExXQphEg4IHJZXgpeDvntfBNvnCOeaztDFjilLqnQd(7xD4QgKMRay1NQAkYgazTQ2KhIQrwZva8XUfBQ7XBIx3i69RaQAMk2oRAmWIzVQxrnQrnQAubsz7So4xp(Rh)7Rh)a5)QAYnsUPEPQrHGck1mO0XGpGp8qhA4z4qRZytIdH3Kd9xhsGSQ)hIasf2sa2HkTdCidlAhla2HuZwQdf(9zIBchsAp8qtOtQaja2H(tWsaVj6aNI)pu0h6pblb8MOdCkYH0Cfa7)HO)NuOJFFM4MWH((HhAcDsfibWo0)WeqgCk()qrFO)HjGm4uKdP5ka2)dr)xsHo(9zIBch67hEOj0jvGea7q)vDYW2GtX)hk6d9x1jdBdof5qAUcG9)q0)tk0XVptCt4quGhEOj0jvGea7q)dtazWP4)df9H(hMaYGtroKMRay)pe9Fjf643NjUjCiP7dp0e6KkqcGDO)HjGm4u8)HI(q)dtazWPihsZvaS)hI(VKcD87Ze3eoK09HhAcDsfibWo0FvNmSn4u8)HI(q)vDYW2GtroKMRay)pe9)KcD87Ze3eo0Vh)WdnHoPcKayh6Fycidof)FOOp0)WeqgCkYH0Cfa7)HO)lPqh)(CFOqqbLAgu6yWhWhEOdn8mCO1zSjXHWBYH(Bn4lqGn()qeqQWwcWouPDGdzyr7ybWoKA2sDOWVptCt4quGhEOj0jvGea7q)dtazWP4)df9H(hMaYGtroKMRay)pe9Fjf643N7dfckOuZGshd(a(WdDOHNHdToJnjoeEto0FgGByI4)HiGuHTeGDOs7ahYWI2XcGDi1SL6qHFFM4MWH(6HhAcDsfibWo0)WeqgCk()qrFO)HjGm4uKdP5ka2)dzXHKoPqEIhI(FsHo(9zIBch67hEOj0jvGea7qARZeou5ndtkhIc)qrFOjIzhITu3Y25H6rGyrtoe9tt3HO)NuOJFFM4MWH((HhAcDsfibWo0)WeqgCk()qrFO)HjGm4uKdP5ka2)dr)pPqh)(mXnHdrbE4HMqNubsaSdPTot4qL3mmPCik8df9HMiMDi2sDlBNhQhbIfn5q0pnDhI(FsHo(9zIBchIc8WdnHoPcKayh6Fycidof)FOOp0)WeqgCkYH0Cfa7)HO)NuOJFFM4MWHK6p8qtOtQaja2H0wNjCOYBgMuoef(HI(qteZoeBPULTZd1JaXIMCi6NMUdr)pPqh)(mXnHdj1F4HMqNubsaSd9pmbKbNI)pu0h6Fycidof5qAUcG9)q0)tk0XVptCt4q)E8dp0e6KkqcGDiT1zchQ8MHjLdrHFOOp0eXSdXwQBz78q9iqSOjhI(PP7q0)tk0XVptCt4q)E8dp0e6KkqcGDO)HjGm4u8)HI(q)dtazWPihsZvaS)hI(FsHo(9zIBch63xp8qtOtQaja2H(hMaYGtX)hk6d9pmbKbNICinxbW(Fi6)jf643NjUjCOFs7HhAcDsfibWo0)WeqgCk()qrFO)HjGm4uKdP5ka2)dr)xsHo(9zIBch63JE4HMqNubsaSd9NGLaEt0bof)FOOp0Fcwc4nrh4uKdP5ka2)dr)pPqh)(mXnHd97b(WdnHoPcKayh6Fycidof)FOOp0)WeqgCkYH0Cfa7)HO)lPqh)(mXnHd9t6(WdnHoPcKayh6Fycidof)FOOp0)WeqgCkYH0Cfa7)HO)lPqh)(CFOqqbLAgu6yWhWhEOdn8mCO1zSjXHWBYH(R6wWA5z5)HiGuHTeGDOs7ahYWI2XcGDi1SL6qHFFM4MWH(9WdnHoPcKayh6Fycidof)FOOp0)WeqgCkYH0Cfa7)HO)NuOJFFM4MWH(6HhAcDsfibWo0)WeqgCk()qrFO)HjGm4uKdP5ka2)dr)pPqh)(mXnHd9aF4HMqNubsaSd9pmbKbNI)pu0h6Fycidof5qAUcG9)q0)tk0XVptCt4qpWhEOj0jvGea7q)dtazWP4)df9H(hMaYGtroKMRay)pKfhs6Kc5jEi6)jf643NjUjCiP(dp0e6KkqcGDO)HjGm4u8)HI(q)dtazWPihsZvaS)hI(FsHo(9zIBchsQ)WdnHoPcKayh6pblb8MOdCk()qrFO)eSeWBIoWPihsZvaS)hI(FsHo(9zIBchs6(WdnHoPcKayh6Fycidof)FOOp0)WeqgCkYH0Cfa7)HO)NuOJFFM4MWHKUp8qtOtQaja2H(tWsaVj6aNI)pu0h6pblb8MOdCkYH0Cfa7)HO)NuOJFFM4MWH(97HhAcDsfibWo0)WeqgCk()qrFO)HjGm4uKdP5ka2)dr)pPqh)(mXnHd9tAp8qtOtQaja2H(hMaYGtX)hk6d9pmbKbNICinxbW(Fi6)sk0XVptCt4q)K2dp0e6KkqcGDO)eSeWBIoWP4)df9H(tWsaVj6aNICinxbW(Fi6)jf643NjUjCOFp6HhAcDsfibWo0)WeqgCk()qrFO)HjGm4uKdP5ka2)drV0KcD87Ze3eo0VVF4HMqNubsaSd9pmbKbNI)pu0h6Fycidof5qAUcG9)q0lnPqh)(mXnHd977hEOj0jvGea7q)jyjG3eDGtX)hk6d9NGLaEt0bof5qAUcG9)q0)tk0XVptCt4q)K6p8qtOtQaja2H(R6KHTbNI)pu0h6VQtg2gCkYH0Cfa7)HO)NuOJFFUpuiOGsndkDm4d4dp0HgEgo06m2K4q4n5q)vnviTmk)pebKkSLaSdvAh4qgw0owaSdPMTuhk87Ze3eo0JE4HMqNubsaSd9pmbKbNI)pu0h6Fycidof5qAUcG9)q0)tk0XVp3hPdNXMea7qs9dzQy78qITef(9PQzyXCtQAARdMWITZjqm8OQnsA8vavnP)qpiyX8HOqkx954qpaY5w8EFK(d9GGcCCbYHK6dDOVE8xp((CFK(drbzuOXkHdKr5qrFOhmFWPFqaFfW0piyXC5qpigCOOpuNI3dPASmouyeDikhs(CFiJahcKYiOcGDOOpKyPchs0P(HGSX0Npu0hYXIaihIERbFbcSXdj9)OJFFUpMk2ol8rcOAhxlEwY0JDSDEFmvSDw4Jeq1oUw8SKPXkGFdWzO0CajMuBz2iwXJ3z4BC)ylhi3htfBNf(ibuTJRfplzAITfWZaJDFUps)HKoLcOWcGDiGkqEpuSoWHIz4qMkAYH2YHmQ2kmxbWVpMk2olsC2K5Xjai1c3hP)quOyK1Cfq5(yQy7S8SKPPAK1CfWqP5asg7wSPUhVjEDJO3VcyiQMadKO6wWA5jVG540Px3i69Ra4eWX2Sm13YctazWlyooD61nIE)kG7JPITZYZsMMQrwZvadLMdiPe(rHL5M6dr1eyGetflvWdj4SqrYpz0pjXwMhOczWngRWbPSLOqJgXwMhOczWngRW3CGFFt39r6pKuJPwtuUpMk2olplzAJOSe8rtiqgdT4siy5Q8JTCGWza(Q2yakW3YOFecUUr07xbWnvSubA0MmmbKbVG540Px3i69Ra4qAUcGrNmcwcCgGVQngqY33htfBNLNLmTROBMhhJ8o0IlzecUUr07xbWnvSubA0CXWX5y5ClE9wPyyIGJnsJwycidUrCE9nUpMbpZCsGjBecUn2kV(CJj4MkwQGm6hHGBeNxV(CJj4MkwQanAQUfSwEYnIZRVX9Xm4zGX4eWX2SmGQBbRLNCxr3mpog5LZWiwSDsHln6OrdF1NdpbCSnltjXfdhN7k6M5XXiVCggXITZ7JPITZYZsM2fifGq5M6dT4sgHGRBe9(vaCtflvGgnxmCCowo3IxVvkgMi4yJ0OfMaYGBeNxFJ7JzWZmNeyYgHGBJTYRp3ycUPILkiJ(ri4gX51Rp3ycUPILkqJMQBbRLNCJ486BCFmdEgymobCSnldO6wWA5j3fifGq5M6CggXITtkCPrhnA4R(C4jGJTzzkjUy44CxGuacLBQZzyel2oVpMk2olplzAXQphfpfAmMUdKXqlUexmCCowo3IxFjiqQhZCSX7J0FikyQGsqmXHMGjehsz5HcYQRdKd9Odn2bKXAId5IHJxg6qGPMpKWkXM6h633hQaQozf(HEaeRyLAb2HMnc7qQMbSdfRdCiRCi7qbz11bYHI(qucW4H24qeWyMRa43htfBNLNLmTLkOeet4vMqm0IlzecUUr07xbWnvSubA0CXWX5y5ClE9wPyyIGJnsJwycidUrCE9nUpMbpZCsGjBecUn2kV(CJj4MkwQGm6hHGBeNxV(CJj4MkwQanAQUfSwEYnIZRVX9Xm4zGX4eWX2SmGQBbRLNClvqjiMWRmHGZWiwSDsHln6OrdF1NdpbCSnltj5333htfBNLNLmTruwc(rmrbgAXLyQyPcEibNfkdi5lA0ONGLaNb4RAJbK8TmcwUk)ylhiCgGVQngqcf4X0DFmvSDwEwY04lbCfDZgAXLmcbx3i69Ra4MkwQanAUy44CSCUfVERummrWXgPrlmbKb3ioV(g3hZGNzojWKncb3gBLxFUXeCtflvqg9JqWnIZRxFUXeCtflvGgnv3cwlp5gX5134(yg8mWyCc4yBwgq1TG1Yto(saxr3modJyX2jfU0OJgn8vFo8eWX2SmLexmCCo(saxr3modJyX259XuX2z5zjt7A6(g3hKvrzzOfxIlgoohlNBXRVeei1Jzo2OmtflvWdj4SqrYV7J0FikuTndBZn1pefklbtazCikmcthdo0woKDOrY2KnEVpMk2olplz6glCjGr5qlUewhCQlbtaz4hfMogWjaobkZMRaKnzycidowo3IxVRy1NdztsSL5bQqgCJXkCqkBjk3htfBNLNLmDJfUeWOCOfxcRdo1LGjGm8Jcthd4eaNaLzZvaYOFYWeqgCSCUfVExXQph0OfMaYGJLZT417kw95qMQBbRLNCSCUfVExXQphCc4yBwOtMPILk4HeCwOmGKVUpMk2olplz6glCjGr5qlUecwc4nrh4fSrGucITPm6zDWXjDj84avGWjaobkZMRaOrJ1b3v0nZpkmDmGtaCcuMnxbq39r6pefufBNhAIBjk3htfBNLNLmTYecVPITtVylXqP5asunviTmk3htfBNLNLmTYecVPITtVylXqP5asuDlyT8SCFmvSDwEwY0eS0BQy70l2smuAoGeRbFbcSXHwCjMkwQGhsWzHYas(sg9QUfSwEYzGfZElzEgOSxobCSnlt97XYMmmbKbNb4RaOrt1TG1YtodWxbWjGJTzzQFpwwycidodWxbqNSjzGfZElzEgOSxESkk3u)(yQy7S8SKPjyP3uX2PxSLyO0CajwdExmsjgAXLyQyPcEibNfkdi5lzmWIzVLmpdu2lpwfLBQFFmvSDwEwY0eS0BQy70l2smuAoGeDibYQ8wddT4smvSubpKGZcLbK8Lm6NKbwm7TK5zGYE5XQOCtDz0R6wWA5jNbwm7TK5zGYE5eWX2SmWVhlBYWeqgCgGVcGgnv3cwlp5maFfaNao2MLb(9yzHjGm4maFfaD0DFmvSDwEwY0kti8Mk2o9ITedLMdirhsGSQHwCjMkwQGhsWzHIKF3N7J0FikylDEONWiL4(yQy7SWTg8UyKsibgxg4SQHwCjeSCv(Xwoq4maFvBmf9)E8ZmWIzpL5QphCC5nwYaMpmIoefkSsJozmWIzpL5QphCC5nwYaMpmIoeLPOaYMKQrwZva8XUfBQ7XBIx3i69RaOrZfdhNxKBeNn19oBj4yJ3htfBNfU1G3fJuINLmnmUmWzvdT4siy5Q8JTCGWza(Q2yQV(wgdSy2tzU6ZbhxEJLmG5dJOdrzGVLnjvJSMRa4JDl2u3J3eVUr07xbCFmvSDw4wdExmsjEwY0W4YaNvn0IlzsgyXSNYC1NdoU8glzaZhgrhIISjPAK1CfaFSBXM6E8M41nIE)kaA0Wx95WtahBZYuFtJgXwMhOczWngRWbPSLOiJylZduHm4gJv4eWX2Sm133htfBNfU1G3fJuINLmT8glz(YiKmGCFmvSDw4wdExmsjEwY0W4YaNvn0IlzsQgznxbWh7wSPUhVjEDJO3Vc4(CFK(drbBPZdPbb249XuX2zHBn4lqGnkXYxplzdT4syGfZEkZvFo44YBSKbmFyeDikdir9QeGhsWzHcnAeBzEGkKb3ySchKYwIImITmpqfYGBmwHtahBZYus(97(yQy7SWTg8fiWgFwY0w(6zjBOfxcdSy2tzU6ZbhxEJLmG5dJOdrzajFFFmvSDw4wd(ceyJplzAyCzGZQgAXLmjvJSMRa4JDl2u3J3eVUr07xbCFmvSDw4wd(ceyJplzACOeaztDFjilLWqQxLa8Hr0HOi53qlUeg4IHJZXHsaKn19YBSKXlHPOCkjstMQBbRLNCBSvM4DSaCc4yBwMsA3htfBNfU1GVab24ZsMghkbq2u3xcYsjmK6vjaFyeDiks(n0IlHbUy44CCOeaztDV8glz8sykkN639XuX2zHBn4lqGn(SKPXHsaKn19LGSucdPEvcWhgrhIIKFdT4siyjWJ1b8r7F0u0R6wWA5jNbwm7TK5zGYE5eWX2SiBYWeqgCgGVcGgnv3cwlp5maFfaNao2MfzHjGm4maFfaD3N7J0FikmDSDwoKLSd1XmqouNhcRa3htfBNfUQBbRLNfjJDSDo0IlzecUUr07xbWnvSubA0CXWX5y5ClE9wPyyIGJnsJwycidUrCE9nUpMbpZCsGjJ(ri4gX51Rp3ycUPILkqJ2ieCBSvE95gtWnvSubA0uDlyT8KBeNxFJ7JzWZaJXjGJTzza8vFo8eWX2Sq39XuX2zHR6wWA5z5zjtJva)gGZqP5as2SOiyH5kaVuHzzG54za1vbdT4sOx1TG1Ytowo3IxVRy1NdobCSnl0OP6wWA5jNzek9bXYcEtCSy7KtahBZcDYOFecUrCE96ZnMGBQyPc0Oncb3gBLxFUXeCtflvq2KHjGm4gX5134(yg8mZjbgnAHr0HGhRd4J2pQc)xpEQVP7(yQy7SWvDlyT8S8SKPXkGFdWzO0CajoMYCjGVmdq4DWkRAOfxIQBbRLNCBSvM4DSaCc4yBwM6Bz0pjivy74iW4BwueSWCfGxQWSmWC8mG6QaA0uDlyT8KVzrrWcZvaEPcZYaZXZaQRc4eWX2Sq39XuX2zHR6wWA5z5zjtJva)gGZqP5asyeWy4lb8uHsbedT4suDlyT8KBJTYeVJfGtahBZImcwc8yDaF0(hnLUIjJ(jbPcBhhbgFZIIGfMRa8sfMLbMJNbuxfqJMQBbRLN8nlkcwyUcWlvywgyoEgqDvaNao2Mf6UpMk2olCv3cwlplplzASc43aCgknhqcZiu60D6zGIsp1MyQnEhAXLO6wWA5j3gBLjEhlaNao2Mfz0pjivy74iW4BwueSWCfGxQWSmWC8mG6QaA0uDlyT8KVzrrWcZvaEPcZYaZXZaQRc4eWX2Sq39XuX2zHR6wWA5z5zjtJva)gGtzOfxIQBbRLNCBSvM4DSaCc4yBwKr)KGuHTJJaJVzrrWcZvaEPcZYaZXZaQRcOrt1TG1Yt(Mffblmxb4LkmldmhpdOUkGtahBZcD3hP)qtOBbRLNL7JPITZcx1TG1YZYZsM2ioV(g3hZGNbgBOfxcdCXWX54qjaYM6E5nwY4yJYuDlyT8KJLZT417kw95GtahBZYustMQBbRLNCMrO0hell4nXXITtobCSnltjnzHjGm4y5ClE9UIvFoOrBYWeqgCSCUfVExXQph3hP)qAVP6qpjw954qY3y(qpOrO8qdtSSG3ehl2op0IFiSyfRu7M6hQJzGCOh0iuEOHjwwWBIJfBNhYfdhVm0HI5UahYf2u)qpiymXcL4qtOxXqh6bicKsTlWoefQDwcsx249qn5qsNbqstCOhGXsDGWpefuu6dPMbfLLdT4hs1jBJTZYHmcCihiou0hAZsag7qZTGDi8MCik4yRmX7yb43htfBNfUQBbRLNLNLmnwo3IxVRy1NJHwCjunYAUcGxc)OWYCtDz0R6wWA5j3ioV(g3hZGNbgJtahBZYaFtNm6vDlyT8KZmcL(GyzbVjowSDYjGJTzzkDfJgnxmCCoZiu6dILf8M4yX2jhBKoz0pjblb8MOdCgymXcLWR6vqJ2KHjGm4gX5134(yg8mZjbgnAQozyBWvDsTvwSD6BCFmdEgymoXskN6B6Ups)H0Et1HEsS6ZXHKVX8HOGJTYeVJf4ql(HIz4qQUfSwEEOg)quWXwzI3XcCOTCirl)qq2y6Z8dj1asf2sGYHEqWyIfkXHMqVIHo0e6KARSy78qn(HIz4qpiySdzj7quqIZ7HA8dfZWHEqZjb2HIwhIzGWVpMk2olCv3cwlplplzASCUfVExXQphdT4sOAK1CfaVe(rHL5M6YOx1TG1YtUrCE9nUpMbpdmgNao2MLb(MozeSeWBIoWzGXelucVQxHSWeqgCJ486BCFmdEM5KatMQtg2gCvNuBLfBN(g3hZGNbgJtSKYbK8Tmv3cwlp52yRmX7yb4eWX2SmL0UpMk2olCv3cwlplplzASCUfVExXQphdT4smvSubpKGZcLbK819XuX2zHR6wWA5z5zjtZmcL(GyzbVjowSDo0IlHQrwZva8s4hfwMBQlJEg4IHJZXY5w86DfR(C4zGlgoohBKgTjdtazWXY5w86DfR(Cq39XuX2zHR6wWA5z5zjtZmcL(GyzbVjowSDo0IlXuXsf8qcolugqYx3htfBNfUQBbRLNLNLmTn2kt8owGHwCjMkwQGhsWzHIKFYyGlgoohhkbq2u3lVXsgVeMIYbK8izHjGm4y5ClE9UIvFoKfMaYGBeNxFJ7JzWZmNeyYiyjG3eDGZaJjwOeEvVczQozyBWvDsTvwSD6BCFmdEgymoXskhqY33htfBNfUQBbRLNLNLmTn2kt8owGHwCjMkwQGhsWzHIKFYyGlgoohhkbq2u3lVXsgVeMIYbK8izHjGm4y5ClE9UIvFoKrFycidowo3IxVvkgMiKP6KHTbx1j1wzX2PVX9Xm4zGX4elPCQVPrlmbKbx3i69RaO7(yQy7SWvDlyT8S8SKPTXwzI3Xcm0IlXuXsf8qcoluK8tgdCXWX54qjaYM6E5nwY4LWuuoGKhjJ(jdtazWXY5w86DfR(CqJwycidUrCE9nUpMbpZCsGjJ(jjyjG3eDGZaJjwOeEvVcA0uDYW2GR6KARSy7034(yg8mWyCILuo130rJwycidowo3IxVvkgMiKP6KHTbx1j1wzX2PVX9Xm4zGX4elPCajFt39XuX2zHR6wWA5z5zjtBJTYeVJfyi1Rsa(Wi6quK8BOfxIPILk4HeCwOmGKVKXaxmCCooucGSPUxEJLmEjmfLdi5rYMKbwm7TK5zGYE5XQOCt97JPITZcx1TG1YZYZsMUG540Px3i69RagAXLqWYv5hB5aHZa8vTXu)E09XuX2zHR6wWA5z5zjtJLZT41BLIHjIHwCjunYAUcGxc)OWYCtDzmWfdhNJdLaiBQ7L3yjJxctr5uFjJ(ri42yR86ZnMGBQyPc0OP6KHTbx1j1wzX2PVX9Xm4zGXK5IHJZzgHsFqSSG3ehl2o5yJYMCecUrCE96ZnMGBQyPc0DFmvSDw4QUfSwEwEwY0y5ClE9wPyyIyi1Rsa(Wi6quK8BOfxIPILk4HeCwOmGKVKXaxmCCooucGSPUxEJLmEjmfLt919XuX2zHR6wWA5z5zjtxAmHNa2iqgs9QeGpmIoefj)gAXLegrhcESoGpA)Ok8s77P(wwyeDi4X6a(O9Sfg477JPITZcx1TG1YZYZsMMyBb8mWydT4sMCecU(CJj4MkwQW9XuX2zHR6wWA5z5zjtxmfzXx1Ac)OPIHwCjMkwQGhsWzHYas(s2KUy44CMrO0hell4nXXITto2OSjvDlyT8KZmcL(GyzbVjowSDYjGXEVp3hP)qtOPcPLXHOGURyJfk3htfBNfUQPcPLrrsrUrC2u37SLyOfxcvJSMRa4LWpkSm3uxgblxLFSLdeodWx1gdqbUps)H0G4qrFiScCidpaYHSXwDOTCOop0eEWdzLdf9HgjaviJd1ubIYgh3u)qsnuyoK85vahQarSP(HWgp0eEW)L7JPITZcx1uH0YO8SKPlYnIZM6ENTedT4suDlyT8KBJTYeVJfGtahBZIm6nvSubpKGZcLbK8LmtflvWdj4SqzkjFlJGLRYp2YbcNb4RAJbO3uXsf8qcoluOWsbOJgntflvWdj4SqzGVLrWYv5hB5aHZa8vTXas7X0DFmvSDw4QMkKwgLNLmT52oBAX2PxSoUdT4sOAK1CfaVe(rHL5M6YMS0yc3nzCbymV7RhKI5mkazQUfSwEYTXwzI3XcWjGJTzrgblbESoGpA)JgGEP9SlgooNGLRYRAcbBm2o5eWX2Sq39XuX2zHRAQqAzuEwY0MB7SPfBNEX64o0IlHQrwZva8s4hfwMBQlR0yc3nzCbymV7RhKI5mkaz0R6wWA5jhlNBXR3vS6ZbNao2MfA0MmmbKbhlNBXR3vS6ZHmv3cwlp5mJqPpiwwWBIJfBNCc4yBwO7(yQy7SWvnviTmkplzAZTD20ITtVyDChAXLyQyPcEibNfkdi5lzeSe4X6a(O9pAa6L2ZUy44CcwUkVQjeSXy7KtahBZcD3htfBNfUQPcPLr5zjtxMnfLcWhZGhlL3Ky(DOfxcvJSMRa4LWpkSm3uxMQBbRLNCBSvM4DSaCc4yBwUpMk2olCvtfslJYZsMUmBkkfGpMbpwkVjX87qlUetflvWdj4SqzajFjJEgyXS3sMNbk7LhRIYn1PrJylZduHm4gJv4eWX2SmLKFpIU7Z9r6pK2M6c4qdBeDiUpMk2olCDibYQKWalM9QEfdT4sCXWX5fmgdspRBhobmviBsQgznxbWh7wSPUhVjEDJO3VcGgTri46grVFfa3uXsfUpMk2olCDibYQEwY0mWIzVQxXqlUecwUk)ylhiCgGVQnM6N0KnjvJSMRa4JDl2u3J3eVUr07xbCFmvSDw46qcKv9SKPT81Zs2qlUev3cwlp52yRmX7yb4eWX2SiJ(WeqgCgGVcGdP5kagnAQMkKwg8C1NdpUb0OrWsaVj6aFCgms70juO7(yQy7SW1HeiR6zjtlVXsMVmcjdidT4syGlgoohhkbq2u3lVXsgVeMIYbE09XuX2zHRdjqw1ZsMwEJLmFzesgqgAXLWaxmCCooucGSPUxEJLmo2Omv3cwlp52yRmX7yb4eWX2SmW3YOFYWeqgCSCUfVExXQph0OfMaYGBeNxFJ7JzWZmNey0OP6KHTbx1j1wzX2PVX9Xm4zGXOrJylZduHm4gJv4Gu2suO7(yQy7SW1HeiR6zjtlVXsMVmcjdidT4syGlgoohhkbq2u3lVXsghBuwycidowo3IxVRy1NdztgMaYGBeNxFJ7JzWZmNeyYMKylZduHm4gJv4Gu2suKrVQBbRLNCSCUfVExXQphCc4yBwg4BzQUfSwEYTXwzI3XcWjGXELnjRdowo3IxVRy1NdobCSnl0OnPQBbRLNCBSvM4DSaCcySx6UpMk2olCDibYQEwY0mWIzVQxXqlUecwUk)ylhiCgGVQnM6RhlBsQgznxbWh7wSPUhVjEDJO3Vc4(yQy7SW1HeiR6zjtJdLaiBQ7lbzPegAXLWaxmCCooucGSPUxEJLmEjmfLt97(yQy7SW1HeiR6zjtJdLaiBQ7lbzPegAXLWaxmCCooucGSPUxEJLmEjmfLt9izQUfSwEYTXwzI3XcWjGJTzzkPjJ(jdtazWXY5w86DfR(CqJwycidUrCE9nUpMbpZCsGrJMQtg2gCvNuBLfBN(g3hZGNbgJgnITmpqfYGBmwHdszlrHU7JPITZcxhsGSQNLmnoucGSPUVeKLsyOfxcdCXWX54qjaYM6E5nwY4LWuuo1JKfMaYGJLZT417kw95q2KHjGm4gX5134(yg8mZjbMSjj2Y8avidUXyfoiLTefzQUfSwEYTXwzI3XcWjGXELrVQBbRLNCSCUfVExXQphCc4yBwMsA0OXaxmCCowo3IxVRy1NdpdCXWX5yJ0DFmvSDw46qcKv9SKPzGfZEvVIHwCjts1iR5ka(y3In194nXRBe9(va3N7J0FOhqibYQoefSLopefgY2KnEVpMk2olCDibYQ8wdsGXLboRAOfxIlgooVGXyq6zD7WjGPI7JPITZcxhsGSkV1WZsMggxg4SQHwCjts1iR5ka(y3In194nXRBe9(va3htfBNfUoKazvERHNLmT8glz(YiKmGmK6vjaFyeDiks(n0IlHEv3cwlp52yRmX7yb4eWX2SmW3YyGlgoohhkbq2u3lVXsghBKgng4IHJZXHsaKn19YBSKXlHPOCGhrNm6Xx95WtahBZYuQUfSwEYzGfZElzEgOSxobCSnlp)7X0OHV6ZHNao2MLbuDlyT8KBJTYeVJfGtahBZcD3htfBNfUoKazvERHNLmnoucGSPUVeKLsyi1Rsa(Wi6quK8BOfxcdCXWX54qjaYM6E5nwY4LWuuoLePjt1TG1YtUn2kt8owaobCSnltjnA0yGlgoohhkbq2u3lVXsgVeMIYP(DFmvSDw46qcKv5TgEwY04qjaYM6(sqwkHHuVkb4dJOdrrYVHwCjQUfSwEYTXwzI3XcWjGJTzzGVLXaxmCCooucGSPUxEJLmEjmfLt9Rg1Owb]] )

end
