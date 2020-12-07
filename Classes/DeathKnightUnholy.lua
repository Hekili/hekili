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


    spec:RegisterPack( "Unholy", 20201207, [[d8uKTbqifrpsrixcPIyteLpPQQrHu1PiQSkvLk1Ruf1SuG2fQ(LIudtvihtvLLPQKNruLPPkORHeSnfH6BevfJJOQQZruvzDQc18uKCpIyFkihuvP0cvf5HkcMOQsXfrQOAJevLKpsuvQrsuvsDsKkkRuvXlvvQiZuvGBQQujTtfWpvvQOgQQsvAPivKEkPAQkOUkrvj2QQsL4RQkvySiH2RK(lvnyihMYIPspMKjJYLbBgQ(mPmAf1PvA1QkvXRrIMnHBtf7w0VLA4k0XrQWYr8CjMUW1HY2rsFNinEKkDEvP1RQuvZhPSFvU(RoCvNzbuh4Rh91J(91JKp8hj)EO8)HYNQE8ocv9rtrPPbv90CGQU8LCUfVv9r7v0gRoCvV0yefu1NJyS84PNwBJzmxUQDMUSoycl2ovedpMUSoQPR6UyRiOZYQBvNzbuh4Rh91J(91JKp8hj)EO8)H)Q6Lrqvh4lk8vvFEzmiRUvDguuv9j6qFdyX8H(oLR2CCi5l5ClEVpt0H(gqboUa5qt8Gh6Rh91JUp3Nj6qFl77bReoqgLdf9H(M8BM(Ba8vat)nGfZLd9nyWHI(qDkEpKQXY4qHr0GOCiPZ9HmcCiGUJGka2HI(qILkCirNAhcYgtB(qrFihlcGCi6Tg8fiWgp0e9toEvxSLOuhUQBn4lqGnwhUoWV6WvDinxbWQpv1vKnaYAvDgyXSNYC1MdoU0glzaZhgrdIYHgsYHuVkb4HeCwOCiA0oeXwMhOczWngRWb6ULOCizhIylZduHm4gJv4eWX2SCOPKCOF)Q6Mk2oR6w(6zjRg1b(QoCvhsZvaS6tvDfzdGSwvNbwm7PmxT5GJlTXsgW8Hr0GOCOHKCiku1nvSDw1T81ZswnQdiV6WvDinxbWQpv1vKnaYAv9jpevJSMRa4JDl2uZJ3eVMr06xbu1nvSDw1HXLboRQg1bEyD4QoKMRay1NQ6Mk2oR64qjaYMA(sqwkHQUISbqwRQZaxmCCooucGSPMxAJLmEjmfLhAkjhsEhs2HuDlyT0KBJTYeVJfGtahBZYHM6qYRQREvcWhgrdIsDGF1OoafQdx1H0CfaR(uv3uX2zvhhkbq2uZxcYsju1vKnaYAvDg4IHJZXHsaKn18sBSKXlHPO8qtDOFvD1Rsa(WiAquQd8Rg1bM46WvDinxbWQpv1nvSDw1XHsaKn18LGSucvDfzdGSwvNGLapwhWhT)HhAQdr)HuDlyT0KZalM9wY8mqzVCc4yBwoKSdn5HctazWza(kaoKMRayhIgTdP6wWAPjNb4Ra4eWX2SCizhkmbKbNb4Ra4qAUcGDi5Q6QxLa8Hr0GOuh4xnQrvxdsGSQ6W1b(vhUQdP5kaw9PQUISbqwRQ7IHJZlymgKEw3oCcyQ4qYo0KhIQrwZva8XUfBQ5XBIxZiA9RaoenAhAecUMr06xbWnvSuHQUPITZQodSy2R6vuJ6aFvhUQdP5kaw9PQUISbqwRQtWYv5hBPaHZa8vTXHM6q)K3HKDOjpevJSMRa4JDl2uZJ3eVMr06xbu1nvSDw1zGfZEvVIAuhqE1HR6qAUcGvFQQRiBaK1Q6QUfSwAYTXwzI3XcWjGJTz5qYoe9hkmbKbNb4Ra4qAUcGDiA0oKQPcPLbpxT5WJBWHOr7qeSeWBIgWhNbJ0oDcfoKMRayhsUQUPITZQULVEwYQrDGhwhUQdP5kaw9PQUISbqwRQZaxmCCooucGSPMxAJLmEjmfLhAOd9WQUPITZQU0glz(YiKmGuJ6auOoCvhsZvaS6tvDfzdGSwvNbUy44CCOeaztnV0glzCSXdj7qQUfSwAYTXwzI3XcWjGJTz5qdDikCizhI(dn5HctazWXY5w86DfR2CWH0Cfa7q0ODOWeqgCJ486BCFmdEM5KaJdP5ka2HOr7qQozyBWvDsTvwSD6BCFmdEgymoKMRayhIgTdrSL5bQqgCJXkCGUBjkhsUQUPITZQU0glz(YiKmGuJ6atCD4QoKMRay1NQ6kYgazTQodCXWX54qjaYMAEPnwY4yJhs2HctazWXY5w86DfR2CWH0Cfa7qYo0KhkmbKb3ioV(g3hZGNzojW4qAUcGDizhAYdrSL5bQqgCJXkCGUBjkhs2HO)qQUfSwAYXY5w86DfR2CWjGJTz5qdDikCizhs1TG1stUn2kt8owaobm27HKDOjpeRdowo3IxVRy1MdobCSnlhIgTdn5HuDlyT0KBJTYeVJfGtaJ9Ei5Q6Mk2oR6sBSK5lJqYasnQdiFQdx1H0CfaR(uvxr2aiRv1jy5Q8JTuGWza(Q24qtDOVE0HKDOjpevJSMRa4JDl2uZJ3eVMr06xbu1nvSDw1zGfZEvVIAuhq(xhUQdP5kaw9PQUISbqwRQZaxmCCooucGSPMxAJLmEjmfLhAQd9RQBQy7SQJdLaiBQ5lbzPeQrDa5xD4QoKMRay1NQ6kYgazTQodCXWX54qjaYMAEPnwY4LWuuEOPo0dpKSdP6wWAPj3gBLjEhlaNao2MLdn1HK3HKDi6p0KhkmbKbhlNBXR3vSAZbhsZvaSdrJ2HctazWnIZRVX9Xm4zMtcmoKMRayhIgTdP6KHTbx1j1wzX2PVX9Xm4zGX4qAUcGDiA0oeXwMhOczWngRWb6ULOCi5Q6Mk2oR64qjaYMA(sqwkHAuh43JQdx1H0CfaR(uvxr2aiRv1zGlgoohhkbq2uZlTXsgVeMIYdn1HE4HKDOWeqgCSCUfVExXQnhCinxbWoKSdn5HctazWnIZRVX9Xm4zMtcmoKMRayhs2HM8qeBzEGkKb3ySchO7wIYHKDiv3cwln52yRmX7yb4eWyVhs2HO)qQUfSwAYXY5w86DfR2CWjGJTz5qtDi5DiA0oedCXWX5y5ClE9UIvBo8mWfdhNJnEi5Q6Mk2oR64qjaYMA(sqwkHAuh43V6WvDinxbWQpv1vKnaYAv9jpevJSMRa4JDl2uZJ3eVMr06xbu1nvSDw1zGfZEvVIAuJQodWnmruhUoWV6WvDtfBNvDNnzECcaFFOQdP5kaw9PAuh4R6WvDinxbWQpv17XQEbIQUPITZQovJSMRaQ6unbgu1vDlyT0KxWCC60RzeT(vaCc4yBwo0uhIchs2HctazWlyooD61mIw)kaoKMRayvDQgXNMdu1h7wSPMhVjEnJO1VcOg1bKxD4QoKMRay1NQ69yvVarv3uX2zvNQrwZvavDQMadQ6MkwQGhsWzHYHKCOFhs2HO)qtEiITmpqfYGBmwHd0Dlr5q0ODiITmpqfYGBmwHV5Hg6q)OWHKRQt1i(0CGQEj8JclZn1QrDGhwhUQdP5kaw9PQUISbqwRQtWYv5hBPaHZa8vTXHg6qtmfoKSdr)HgHGRzeT(vaCtflv4q0ODOjpuycidEbZXPtVMr06xbWH0Cfa7qYDizhIGLaNb4RAJdnKKdrHQUPITZQUruwc(OjeiJAuhGc1HR6qAUcGvFQQRiBaK1Q6JqW1mIw)kaUPILkCiA0oKlgoohlNBXR3kfdteCSXdrJ2HctazWnIZRVX9Xm4zMtcmoKMRayhs2HgHGBJTYRn3ycUPILkCizhI(dncb3ioVET5gtWnvSuHdrJ2HuDlyT0KBeNxFJ7JzWZaJXjGJTz5qdDiv3cwln5UIUzECmYlNHrSy78qtFi5Di5oenAhkmIge8yDaF0E2chAkjhYfdhN7k6M5XXiVCggXITZQUPITZQUROBMhhJ8wJ6atCD4QoKMRay1NQ6kYgazTQ(ieCnJO1VcGBQyPchIgTd5IHJZXY5w86TsXWebhB8q0ODOWeqgCJ486BCFmdEM5KaJdP5ka2HKDOri42yR8AZnMGBQyPchs2HO)qJqWnIZRxBUXeCtflv4q0ODiv3cwln5gX5134(yg8mWyCc4yBwo0qhs1TG1stUlqkaHYn14mmIfBNhA6djVdj3HOr7qHr0GGhRd4J2Zw4qtj5qUy44CxGuacLBQXzyel2oR6Mk2oR6UaPaek3uRg1bKp1HR6qAUcGvFQQRiBaK1Q6Uy44CSCUfV(sqGulM5yJvDtfBNvDXQnhf)3dgtZbYOg1bK)1HR6qAUcGvFQQRiBaK1Q6JqW1mIw)kaUPILkCiA0oKlgoohlNBXR3kfdteCSXdrJ2HctazWnIZRVX9Xm4zMtcmoKMRayhs2HgHGBJTYRn3ycUPILkCizhI(dncb3ioVET5gtWnvSuHdrJ2HuDlyT0KBeNxFJ7JzWZaJXjGJTz5qdDiv3cwln5wQGsqmHxzcbNHrSy78qtFi5Di5oenAhkmIge8yDaF0E2chAkjh6hfQ6Mk2oR6wQGsqmHxzcrnQdi)Qdx1H0CfaR(uvxr2aiRv1nvSubpKGZcLdnKKd91HOr7q0FicwcCgGVQno0qsoefoKSdrWYv5hBPaHZa8vTXHgsYHM4hDi5Q6Mk2oR6grzj4hXefOg1b(9O6WvDinxbWQpv1vKnaYAv9ri4AgrRFfa3uXsfoenAhYfdhNJLZT41BLIHjco24HOr7qHjGm4gX5134(yg8mZjbghsZvaSdj7qJqWTXw51MBmb3uXsfoKSdr)HgHGBeNxV2CJj4MkwQWHOr7qQUfSwAYnIZRVX9Xm4zGX4eWX2SCOHoKQBbRLMC8LaUIUzCggXITZdn9HK3HK7q0ODOWiAqWJ1b8r7zlCOPKCixmCCo(saxr3modJyX2zv3uX2zvhFjGROBwnQd87xD4QoKMRay1NQ6kYgazTQUlgoohlNBXRVeei1Izo24HKDitflvWdj4Sq5qso0VQUPITZQURP5BCFqwfLLAuh43x1HR6qAUcGvFQQRiBaK1Q6So4uxcMaYWpkmnmGtaCcuMnxbCizhAYdfMaYGJLZT417kwT5GdP5ka2HKDOjpeXwMhOczWngRWb6ULOu1nvSDw1BSWLagL1OoWp5vhUQdP5kaw9PQUISbqwRQZ6GtDjycid)OW0WaobWjqz2CfWHKDi6p0KhkmbKbhlNBXR3vSAZbhsZvaSdrJ2HctazWXY5w86DfR2CWH0Cfa7qYoKQBbRLMCSCUfVExXQnhCc4yBwoKChs2HmvSubpKGZcLdnKKd9vv3uX2zvVXcxcyuwJ6a)EyD4QoKMRay1NQ6kYgazTQoblb8MOb8c2iqkbX2KdP5ka2HKDi6peRdooPlHhhOceobWjqz2CfWHOr7qSo4UIUz(rHPHbCcGtGYS5kGdjxv3uX2zvVXcxcyuwJ6a)OqD4QoKMRay1NQ6Mk2oR6kti8Mk2o9ITevDXwcFAoqvx1uH0YOuJ6a)M46WvDinxbWQpv1nvSDw1vMq4nvSD6fBjQ6ITe(0CGQUQBbRLMLAuh4N8PoCvhsZvaS6tvDfzdGSwv3uXsf8qcoluo0qso0xhs2HO)qQUfSwAYzGfZElzEgOSxobCSnlhAQd97rhs2HM8qHjGm4maFfahsZvaSdrJ2HuDlyT0KZa8vaCc4yBwo0uh63JoKSdfMaYGZa8vaCinxbWoKChs2HM8qmWIzVLmpdu2lpwfLBQv1nvSDw1jyP3uX2PxSLOQl2s4tZbQ6wd(ceyJ1OoWp5FD4QoKMRay1NQ6kYgazTQUPILk4HeCwOCOHKCOVoKSdXalM9wY8mqzV8yvuUPwv3uX2zvNGLEtfBNEXwIQUylHpnhOQBn4DXiLOg1b(j)Qdx1H0CfaR(uvxr2aiRv1nvSubpKGZcLdnKKd91HKDi6p0KhIbwm7TK5zGYE5XQOCtTdj7q0Fiv3cwln5mWIzVLmpdu2lNao2MLdn0H(9Odj7qtEOWeqgCgGVcGdP5ka2HOr7qQUfSwAYza(kaobCSnlhAOd97rhs2HctazWza(kaoKMRayhsUdjxv3uX2zvNGLEtfBNEXwIQUylHpnhOQRbjqwL3AOg1b(6r1HR6qAUcGvFQQRiBaK1Q6MkwQGhsWzHYHKCOFvDtfBNvDLjeEtfBNEXwIQUylHpnhOQRbjqwvnQrvFKaQ2X1I6W1b(vhUQBQy7SQp2X2zvhsZvaS6t1OoWx1HR6qAUcGvFQQNMdu1TVFz2iwXJ3z4BC)ylfivDtfBNvD77xMnIv84Dg(g3p2sbsnQdiV6WvDtfBNvDITfWZaJv1H0CfaR(unQrvx1TG1sZsD46a)Qdx1H0CfaR(uvxr2aiRv1hHGRzeT(vaCtflv4q0ODixmCCowo3IxVvkgMi4yJhIgTdfMaYGBeNxFJ7JzWZmNeyCinxbWoKSdr)HgHGBeNxV2CJj4MkwQWHOr7qJqWTXw51MBmb3uXsfoenAhs1TG1stUrCE9nUpMbpdmgNao2MLdn0HcJObbpwhWhTNTWHKRQBQy7SQp2X2znQd8vD4QoKMRay1NQ6Mk2oR6BwueSWCfGNoWSmWC8mG6QGQUISbqwRQt)HuDlyT0KJLZT417kwT5GtahBZYHOr7qQUfSwAYzgHsFqSSG3ehl2o5eWX2SCi5oKSdr)HgHGBeNxV2CJj4MkwQWHOr7qJqWTXw51MBmb3uXsfoKSdn5HctazWnIZRVX9Xm4zMtcmoKMRayhIgTdfgrdcESoGpA)Ok8F9Odn1HOWHKRQNMdu13SOiyH5kapDGzzG54za1vb1OoG8Qdx1H0CfaR(uv3uX2zv3XuMlb8LzacVdwzvvDfzdGSwvx1TG1stUn2kt8owaobCSnlhAQdrHdj7q0FOjpeqhy74iW4BwueSWCfGNoWSmWC8mG6QGdrJ2HuDlyT0KVzrrWcZvaE6aZYaZXZaQRc4eWX2SCi5Q6P5avDhtzUeWxMbi8oyLvvJ6apSoCvhsZvaS6tvDtfBNvDgbmg(sapvOuarvxr2aiRv1vDlyT0KBJTYeVJfGtahBZYHKDicwc8yDaF0(hEOPoKMIDizhI(dn5Ha6aBhhbgFZIIGfMRa80bMLbMJNbuxfCiA0oKQBbRLM8nlkcwyUcWthywgyoEgqDvaNao2MLdjxvpnhOQZiGXWxc4PcLciQrDakuhUQdP5kaw9PQUPITZQoZiu60D6zGIsp1MyQnER6kYgazTQUQBbRLMCBSvM4DSaCc4yBwoKSdr)HM8qaDGTJJaJVzrrWcZvaE6aZYaZXZaQRcoenAhs1TG1st(Mffblmxb4PdmldmhpdOUkGtahBZYHKRQNMdu1zgHsNUtpduu6P2etTXBnQdmX1HR6qAUcGvFQQRiBaK1Q6QUfSwAYTXwzI3XcWjGJTz5qYoe9hAYdb0b2oocm(Mffblmxb4PdmldmhpdOUk4q0ODiv3cwln5BwueSWCfGNoWSmWC8mG6QaobCSnlhsUQUPITZQowb8BaoLAuhq(uhUQdP5kaw9PQUISbqwRQZaxmCCooucGSPMxAJLmo24HKDiv3cwln5y5ClE9UIvBo4eWX2SCOPoK8oKSdP6wWAPjNzek9bXYcEtCSy7KtahBZYHM6qY7qYouycidowo3IxVRy1MdoKMRayhIgTdn5HctazWXY5w86DfR2CWH0CfaRQBQy7SQBeNxFJ7JzWZaJvJ6aY)6WvDinxbWQpv1vKnaYAvDQgznxbWlHFuyzUP2HKDi6pKQBbRLMCJ486BCFmdEgymobCSnlhAOdrHdrJ2HyGfZEkZvBo4STyUcWBDWoKChs2HO)qQUfSwAYzgHsFqSSG3ehl2o5eWX2SCOPoKMIDiA0oKlgooNzek9bXYcEtCSy7KJnEi5oKSdr)HM8qeSeWBIgWzGXelucVQxbhsZvaSdrJ2HM8qHjGm4gX5134(yg8mZjbghsZvaSdrJ2HuDYW2GR6KARSy7034(yg8mWyCILuEOPoefoKCvDtfBNvDSCUfVExXQnh1OoG8RoCvhsZvaS6tvDfzdGSwvNQrwZva8s4hfwMBQDizhI(dP6wWAPj3ioV(g3hZGNbgJtahBZYHg6qu4q0ODigyXSNYC1MdoBlMRa8whSdj3HKDicwc4nrd4mWyIfkHx1RGdP5ka2HKDOWeqgCJ486BCFmdEM5KaJdP5ka2HKDivNmSn4QoP2kl2o9nUpMbpdmgNyjLhAijhIchs2HuDlyT0KBJTYeVJfGtahBZYHM6qYRQBQy7SQJLZT417kwT5Og1b(9O6WvDinxbWQpv1vKnaYAvDtflvWdj4Sq5qdj5qFv1nvSDw1XY5w86DfR2CuJ6a)(vhUQdP5kaw9PQUISbqwRQt1iR5kaEj8JclZn1oKSdr)HyGlgoohlNBXR3vSAZHNbUy44CSXdrJ2HM8qHjGm4y5ClE9UIvBo4qAUcGDi5Q6Mk2oR6mJqPpiwwWBIJfBN1OoWVVQdx1H0CfaR(uvxr2aiRv1nvSubpKGZcLdnKKd9vv3uX2zvNzek9bXYcEtCSy7Sg1b(jV6WvDinxbWQpv1vKnaYAvDtflvWdj4Sq5qso0Vdj7qmWfdhNJdLaiBQ5L2yjJxctr5HgsYHE4HKDOWeqgCSCUfVExXQnhCinxbWoKSdfMaYGBeNxFJ7JzWZmNeyCinxbWoKSdrWsaVjAaNbgtSqj8QEfCinxbWoKSdP6KHTbx1j1wzX2PVX9Xm4zGX4elP8qdj5quOQBQy7SQBJTYeVJfOg1b(9W6WvDinxbWQpv1vKnaYAvDtflvWdj4Sq5qso0Vdj7qmWfdhNJdLaiBQ5L2yjJxctr5HgsYHE4HKDOWeqgCSCUfVExXQnhCinxbWoKSdr)HctazWXY5w86TsXWebhsZvaSdj7qQozyBWvDsTvwSD6BCFmdEgymoXskp0uhIchIgTdfMaYGRzeT(vaCinxbWoKCvDtfBNvDBSvM4DSa1OoWpkuhUQdP5kaw9PQUPITZQUn2kt8owGQUISbqwRQBQyPcEibNfkhAijh6Rdj7qmWfdhNJdLaiBQ5L2yjJxctr5HgsYHE4HKDOjpedSy2BjZZaL9YJvr5MAvD1Rsa(WiAquQd8Rg1b(nX1HR6qAUcGvFQQRiBaK1Q6eSCv(Xwkq4maFvBCOPo0Vhw1nvSDw1lyooD61mIw)kGAuh4N8PoCvhsZvaS6tvDfzdGSwvNQrwZva8s4hfwMBQDizhIbUy44CCOeaztnV0glz8sykkp0uh6Rdj7q0FOri42yR8AZnMGBQyPchIgTdP6KHTbx1j1wzX2PVX9Xm4zGX4qAUcGDizhYfdhNZmcL(GyzbVjowSDYXgpKSdn5HgHGBeNxV2CJj4MkwQWHKRQBQy7SQJLZT41BLIHjIAuh4N8VoCvhsZvaS6tvDtfBNvDSCUfVERummru1vKnaYAvDtflvWdj4Sq5qdj5qFDizhIbUy44CCOeaztnV0glz8sykkp0uh6RQU6vjaFyenik1b(vJ6a)KF1HR6qAUcGvFQQBQy7SQxAmHNa2iqQ6kYgazTQEyeni4X6a(O9JQWlpkCOPoefoKSdfgrdcESoGpApBHdn0HOqvx9QeGpmIgeL6a)QrDGVEuD4QoKMRay1NQ6kYgazTQ(KhAecU2CJj4MkwQqv3uX2zvNyBb8mWy1OoWx)Qdx1H0CfaR(uvxr2aiRv1nvSubpKGZcLdnKKd91HKDOjpKlgooNzek9bXYcEtCSy7KJnEizhAYdP6wWAPjNzek9bXYcEtCSy7KtaJ9w1nvSDw1lMIS4RAnHF0urnQrvxdsGSkV1qD46a)Qdx1H0CfaR(uvxr2aiRv1DXWX5fmgdspRBhobmvu1nvSDw1HXLboRQg1b(QoCvhsZvaS6tvDfzdGSwvFYdr1iR5ka(y3In184nXRzeT(vavDtfBNvDyCzGZQQrDa5vhUQdP5kaw9PQUPITZQU0glz(YiKmGu1vKnaYAvD6pKQBbRLMCBSvM4DSaCc4yBwo0qhIchs2HyGlgoohhkbq2uZlTXsghB8q0ODig4IHJZXHsaKn18sBSKXlHPO8qdDOhEi5oKSdr)HWxT5WtahBZYHM6qQUfSwAYzGfZElzEgOSxobCSnlh65d97rhIgTdHVAZHNao2MLdn0HuDlyT0KBJTYeVJfGtahBZYHKRQREvcWhgrdIsDGF1OoWdRdx1H0CfaR(uv3uX2zvhhkbq2uZxcYsju1vKnaYAvDg4IHJZXHsaKn18sBSKXlHPO8qtj5qY7qYoKQBbRLMCBSvM4DSaCc4yBwo0uhsEhIgTdXaxmCCooucGSPMxAJLmEjmfLhAQd9RQREvcWhgrdIsDGF1OoafQdx1H0CfaR(uv3uX2zvhhkbq2uZxcYsju1vKnaYAvDv3cwln52yRmX7yb4eWX2SCOHoefoKSdXaxmCCooucGSPMxAJLmEjmfLhAQd9RQREvcWhgrdIsDGF1OgvDRbVlgPe1HRd8RoCvhsZvaS6tvDfzdGSwvNGLRYp2sbcNb4RAJdn1HO)q)E0HE(qmWIzpL5QnhCCPnwYaMpmIgeLd9DFi5Di5oKSdXalM9uMR2CWXL2yjdy(WiAquo0uhAIpKSdn5HOAK1CfaFSBXMAE8M41mIw)kGdrJ2HCXWX5fPgXztnVZwco2yv3uX2zvhgxg4SQAuh4R6WvDinxbWQpv1vKnaYAvDcwUk)ylfiCgGVQno0uh6lkCizhIbwm7PmxT5GJlTXsgW8Hr0GOCOHoefoKSdn5HOAK1CfaFSBXMAE8M41mIw)kGQUPITZQomUmWzv1OoG8Qdx1H0CfaR(uvxr2aiRv1N8qmWIzpL5QnhCCPnwYaMpmIgeLdj7qtEiQgznxbWh7wSPMhVjEnJO1Vc4q0ODi8vBo8eWX2SCOPoefoenAhIylZduHm4gJv4aD3suoKSdrSL5bQqgCJXkCc4yBwo0uhIcvDtfBNvDyCzGZQQrDGhwhUQBQy7SQlTXsMVmcjdivDinxbWQpvJ6auOoCvhsZvaS6tvDfzdGSwvFYdr1iR5ka(y3In184nXRzeT(vavDtfBNvDyCzGZQQrnQ6QMkKwgL6W1b(vhUQdP5kaw9PQUISbqwRQt1iR5kaEj8JclZn1oKSdrWYv5hBPaHZa8vTXHg6qtCv3uX2zvVi1ioBQ5D2suJ6aFvhUQdP5kaw9PQUISbqwRQR6wWAPj3gBLjEhlaNao2MLdj7q0FitflvWdj4Sq5qdj5qFDizhYuXsf8qcoluo0usoefoKSdrWYv5hBPaHZa8vTXHg6q0FitflvWdj4Sq5qF3hAIpKChIgTdzQyPcEibNfkhAOdrHdj7qeSCv(Xwkq4maFvBCOHoK8E0HKRQBQy7SQxKAeNn18oBjQrDa5vhUQdP5kaw9PQUISbqwRQt1iR5kaEj8JclZn1oKSdn5HknMWDtgxagZ7(6b6AoJc4qYoKQBbRLMCBSvM4DSaCc4yBwoKSdrWsGhRd4J2)Wdn0HO)qY7qpFixmCCoblxLx1ec2ySDYjGJTz5qYv1nvSDw1n32ztl2o9I1XTg1bEyD4QoKMRay1NQ6kYgazTQovJSMRa4LWpkSm3u7qYouPXeUBY4cWyE3xpqxZzuahs2HO)qQUfSwAYXY5w86DfR2CWjGJTz5q0ODOjpuycidowo3IxVRy1MdoKMRayhs2HuDlyT0KZmcL(GyzbVjowSDYjGJTz5qYv1nvSDw1n32ztl2o9I1XTg1bOqD4QoKMRay1NQ6kYgazTQUPILk4HeCwOCOHKCOVoKSdrWsGhRd4J2)Wdn0HO)qY7qpFixmCCoblxLx1ec2ySDYjGJTz5qYv1nvSDw1n32ztl2o9I1XTg1bM46WvDinxbWQpv1vKnaYAvDQgznxbWlHFuyzUP2HKDiv3cwln52yRmX7yb4eWX2Su1nvSDw1lZMIsb4JzWJLsBsm)wJ6aYN6WvDinxbWQpv1vKnaYAvDtflvWdj4Sq5qdj5qFDizhI(dXalM9wY8mqzV8yvuUP2HOr7qeBzEGkKb3yScNao2MLdnLKd97HhsUQUPITZQEz2uukaFmdESuAtI53AuJAu1PcKY2zDGVE0xp63xpAIR6snsUPwPQ)D8T0PdqNnG89Jp0HgEgo06m2K4q4n5q)1GeiR6)HiaDGTeGDOs7ahYWI2XcGDi1SLAqHFFEWMWHK3Jp0e6KkqcGDO)eSeWBIgWP4)df9H(tWsaVjAaNICinxbW(Fi6)rx543NhSjCik84dnHoPcKayh6Fycidof)FOOp0)WeqgCkYH0Cfa7)HO)l6kh)(8GnHdrHhFOj0jvGea7q)vDYW2GtX)hk6d9x1jdBdof5qAUcG9)q0)JUYXVppyt4qt8Jp0e6KkqcGDO)HjGm4u8)HI(q)dtazWPihsZvaS)hI(VORC87Zd2eoK87XhAcDsfibWo0)WeqgCk()qrFO)HjGm4uKdP5ka2)dr)x0vo(95bBchs(94dnHoPcKayh6VQtg2gCk()qrFO)QozyBWPihsZvaS)hI(F0vo(95bBch63JE8HMqNubsaSd9pmbKbNI)pu0h6Fycidof5qAUcG9)q0)fDLJFFUpFhFlD6a0zdiF)4dDOHNHdToJnjoeEto0FRbFbcSX)hIa0b2sa2HkTdCidlAhla2HuZwQbf(95bBchAIF8HMqNubsaSd9pmbKbNI)pu0h6Fycidof5qAUcG9)q0)fDLJFFUpFhFlD6a0zdiF)4dDOHNHdToJnjoeEto0FgGByI4)HiaDGTeGDOs7ahYWI2XcGDi1SLAqHFFEWMWH(6XhAcDsfibWo0)WeqgCk()qrFO)HjGm4uKdP5ka2)dzXHOZ)o)Gdr)p6kh)(8GnHdrHhFOj0jvGea7q6RZeou5ndJUhIo5qrFOhGzhITu3Y25H6rGyrtoe9tl3HO)hDLJFFEWMWHOWJp0e6KkqcGDO)HjGm4u8)HI(q)dtazWPihsZvaS)hI(F0vo(95bBchAIF8HMqNubsaSdPVot4qL3mm6Ei6Kdf9HEaMDi2sDlBNhQhbIfn5q0pTChI(F0vo(95bBchAIF8HMqNubsaSd9pmbKbNI)pu0h6Fycidof5qAUcG9)q0)JUYXVppyt4qY)hFOj0jvGea7q6RZeou5ndJUhIo5qrFOhGzhITu3Y25H6rGyrtoe9tl3HO)hDLJFFEWMWHK)p(qtOtQaja2H(hMaYGtX)hk6d9pmbKbNICinxbW(Fi6)rx543NhSjCOFp6XhAcDsfibWoK(6mHdvEZWO7HOtou0h6by2Hyl1TSDEOEeiw0Kdr)0YDi6)rx543NhSjCOFp6XhAcDsfibWo0)WeqgCk()qrFO)HjGm4uKdP5ka2)dr)p6kh)(8GnHd97RhFOj0jvGea7q)dtazWP4)df9H(hMaYGtroKMRay)pe9)ORC87Zd2eo0p594dnHoPcKayh6Fycidof)FOOp0)WeqgCkYH0Cfa7)HO)l6kh)(8GnHd97Hp(qtOtQaja2H(tWsaVjAaNI)pu0h6pblb8MObCkYH0Cfa7)HO)hDLJFFEWMWH(jFE8HMqNubsaSd9pmbKbNI)pu0h6Fycidof5qAUcG9)q0)fDLJFFEWMWH(j)E8HMqNubsaSd9pmbKbNI)pu0h6Fycidof5qAUcG9)q0)fDLJFFUpFhFlD6a0zdiF)4dDOHNHdToJnjoeEto0Fv3cwlnl)pebOdSLaSdvAh4qgw0owaSdPMTudk87Zd2eo0VhFOj0jvGea7q)dtazWP4)df9H(hMaYGtroKMRay)pe9)ORC87Zd2eo0xp(qtOtQaja2H(hMaYGtX)hk6d9pmbKbNICinxbW(Fi6)rx543NhSjCi5ZJp0e6KkqcGDO)HjGm4u8)HI(q)dtazWPihsZvaS)hI(F0vo(95bBchs(84dnHoPcKayh6Fycidof)FOOp0)WeqgCkYH0Cfa7)HS4q05FNFWHO)hDLJFFEWMWHK)p(qtOtQaja2H(hMaYGtX)hk6d9pmbKbNICinxbW(Fi6)rx543NhSjCi5)Jp0e6KkqcGDO)eSeWBIgWP4)df9H(tWsaVjAaNICinxbW(Fi6)rx543NhSjCi53Jp0e6KkqcGDO)HjGm4u8)HI(q)dtazWPihsZvaS)hI(F0vo(95bBchs(94dnHoPcKayh6pblb8MObCk()qrFO)eSeWBIgWPihsZvaS)hI(F0vo(95bBch63VhFOj0jvGea7q)dtazWP4)df9H(hMaYGtroKMRay)pe9)ORC87Zd2eo0p594dnHoPcKayh6Fycidof)FOOp0)WeqgCkYH0Cfa7)HO)l6kh)(8GnHd9tEp(qtOtQaja2H(tWsaVjAaNI)pu0h6pblb8MObCkYH0Cfa7)HO)hDLJFFEWMWH(9WhFOj0jvGea7q)dtazWP4)df9H(hMaYGtroKMRay)pe9YJUYXVppyt4q)Kpp(qtOtQaja2H(R6KHTbNI)pu0h6VQtg2gCkYH0Cfa7)HO)hDLJFFUpFhFlD6a0zdiF)4dDOHNHdToJnjoeEto0FvtfslJY)dra6aBja7qL2boKHfTJfa7qQzl1Gc)(8GnHd9WhFOj0jvGea7q)dtazWP4)df9H(hMaYGtroKMRay)pe9)ORC87Z9HoZzSjbWoK8)qMk2opKylrHFFQ6JKgFfqvFIo03awmFOVt5Qnhhs(so3I37ZeDOVbuGJlqoK8zWd91J(6r3N7ZeDOVL99GvchiJYHI(qFt(nt)na(kGP)gWI5YH(gm4qrFOofVhs1yzCOWiAquoK05(qgboeq3rqfa7qrFiXsfoKOtTdbzJPnFOOpKJfbqoe9wd(ceyJhAI(jh)(CFmvSDw4Jeq1oUw8SKPh7y78(yQy7SWhjGQDCT4zjtJva)gGZGP5asSVFz2iwXJ3z4BC)ylfi3htfBNf(ibuTJRfplzAITfWZaJDFUpt0HOZPlOWcGDiGkqEpuSoWHIz4qMkAYH2YHmQ2kmxbWVpMk2olsC2K5Xja89H7ZeDOVlgznxbuUpMk2olplzAQgznxbmyAoGKXUfBQ5XBIxZiA9RagKQjWajQUfSwAYlyooD61mIw)kaobCSnltrbzHjGm4fmhNo9AgrRFfW9XuX2z5zjtt1iR5kGbtZbKuc)OWYCtTbPAcmqIPILk4HeCwOi5Nm6NKylZduHm4gJv4aD3suOrJylZduHm4gJv4Bo0pki39zIoeDQPwtuUpMk2olplzAJOSe8rtiqgdU4siy5Q8JTuGWza(Q2yOjMcYOFecUMr06xbWnvSubA0MmmbKbVG540PxZiA9Ra4qAUcGjNmcwcCgGVQngscfUpMk2olplzAxr3mpog5DWfxYieCnJO1VcGBQyPc0O5IHJZXY5w86TsXWebhBKgTWeqgCJ486BCFmdEM5Kat2ieCBSvET5gtWnvSubz0pcb3ioVET5gtWnvSubA0uDlyT0KBeNxFJ7JzWZaJXjGJTzziv3cwln5UIUzECmYlNHrSy7KorEYrJwyeni4X6a(O9SfMsIlgoo3v0nZJJrE5mmIfBN3htfBNLNLmTlqkaHYn1gCXLmcbxZiA9Ra4MkwQanAUy44CSCUfVERummrWXgPrlmbKb3ioV(g3hZGNzojWKncb3gBLxBUXeCtflvqg9JqWnIZRxBUXeCtflvGgnv3cwln5gX5134(yg8mWyCc4yBwgs1TG1stUlqkaHYn14mmIfBN0jYtoA0cJObbpwhWhTNTWusCXWX5UaPaek3uJZWiwSDEFmvSDwEwY0IvBok(VhmMMdKXGlUexmCCowo3IxFjiqQfZCSX7ZeDOVnvqjiM4qtWeIdPS8qbz10aYHE4Hg7aYynXHCXWXldEiWuZhsyLytTd9JchQaQozf(HKVeRy)(a7qZgHDivZa2HI1boKvoKDOGSAAa5qrFikby8qBCicymZva87JPITZYZsM2sfucIj8ktigCXLmcbxZiA9Ra4MkwQanAUy44CSCUfVERummrWXgPrlmbKb3ioV(g3hZGNzojWKncb3gBLxBUXeCtflvqg9JqWnIZRxBUXeCtflvGgnv3cwln5gX5134(yg8mWyCc4yBwgs1TG1stULkOeet4vMqWzyel2oPtKNC0OfgrdcESoGpApBHPK8Jc3htfBNLNLmTruwc(rmrbgCXLyQyPcEibNfkdj5lA0ONGLaNb4RAJHKqbzeSCv(Xwkq4maFvBmKKj(rYDFmvSDwEwY04lbCfDZgCXLmcbxZiA9Ra4MkwQanAUy44CSCUfVERummrWXgPrlmbKb3ioV(g3hZGNzojWKncb3gBLxBUXeCtflvqg9JqWnIZRxBUXeCtflvGgnv3cwln5gX5134(yg8mWyCc4yBwgs1TG1sto(saxr3modJyX2jDI8KJgTWiAqWJ1b8r7zlmLexmCCo(saxr3modJyX259XuX2z5zjt7AA(g3hKvrzzWfxIlgoohlNBXRVeei1Izo2OmtflvWdj4SqrYV7ZeDOVR2MHT5MAh67YsWeqgh67vyAyWH2YHSdns2MSX79XuX2z5zjt3yHlbmkhCXLW6GtDjycid)OW0WaobWjqz2CfGSjdtazWXY5w86DfR2CiBsITmpqfYGBmwHd0Dlr5(yQy7S8SKPBSWLagLdU4syDWPUembKHFuyAyaNa4eOmBUcqg9tgMaYGJLZT417kwT5GgTWeqgCSCUfVExXQnhYuDlyT0KJLZT417kwT5GtahBZICYmvSubpKGZcLHK819XuX2z5zjt3yHlbmkhCXLqWsaVjAaVGncKsqSnLrpRdooPlHhhOceobWjqz2CfanASo4UIUz(rHPHbCcGtGYS5ka5Upt0H(wvSDEOhSLOCFmvSDwEwY0kti8Mk2o9ITedMMdir1uH0YOCFmvSDwEwY0kti8Mk2o9ITedMMdir1TG1sZY9XuX2z5zjttWsVPITtVylXGP5asSg8fiWghCXLyQyPcEibNfkdj5lz0R6wWAPjNbwm7TK5zGYE5eWX2Sm1VhjBYWeqgCgGVcGgnv3cwln5maFfaNao2MLP(9izHjGm4maFfGCYMKbwm7TK5zGYE5XQOCtT7JPITZYZsMMGLEtfBNEXwIbtZbKyn4DXiLyWfxIPILk4HeCwOmKKVKXalM9wY8mqzV8yvuUP29XuX2z5zjttWsVPITtVylXGP5as0GeiRYBnm4IlXuXsf8qcolugsYxYOFsgyXS3sMNbk7LhRIYn1KrVQBbRLMCgyXS3sMNbk7LtahBZYq)EKSjdtazWza(kaA0uDlyT0KZa8vaCc4yBwg63JKfMaYGZa8vaYj39XuX2z5zjtRmHWBQy70l2smyAoGenibYQgCXLyQyPcEibNfks(DFUpt0H(2Mo)qpHrkX9XuX2zHBn4DXiLqcmUmWzvdU4siy5Q8JTuGWza(Q2yk6)9ONzGfZEkZvBo44sBSKbmFyenikF3YtozmWIzpL5QnhCCPnwYaMpmIgeLPMyzts1iR5ka(y3In184nXRzeT(va0O5IHJZlsnIZMAENTeCSX7JPITZc3AW7IrkXZsMggxg4SQbxCjeSCv(Xwkq4maFvBm1xuqgdSy2tzUAZbhxAJLmG5dJObrzikiBsQgznxbWh7wSPMhVjEnJO1Vc4(yQy7SWTg8UyKs8SKPHXLboRAWfxYKmWIzpL5QnhCCPnwYaMpmIgefzts1iR5ka(y3In184nXRzeT(va0OHVAZHNao2MLPOanAeBzEGkKb3ySchO7wIImITmpqfYGBmwHtahBZYuu4(yQy7SWTg8UyKs8SKPL2yjZxgHKbK7JPITZc3AW7IrkXZsMggxg4SQbxCjts1iR5ka(y3In184nXRzeT(va3N7ZeDOVTPZpKoeyJ3htfBNfU1GVab2OelF9SKn4IlHbwm7PmxT5GJlTXsgW8Hr0GOmKe1RsaEibNfk0OrSL5bQqgCJXkCGUBjkYi2Y8avidUXyfobCSnltj53V7JPITZc3AWxGaB8zjtB5RNLSbxCjmWIzpL5QnhCCPnwYaMpmIgeLHKqH7JPITZc3AWxGaB8zjtdJldCw1GlUKjPAK1CfaFSBXMAE8M41mIw)kG7JPITZc3AWxGaB8zjtJdLaiBQ5lbzPegu9QeGpmIgefj)gCXLWaxmCCooucGSPMxAJLmEjmfLtjrEYuDlyT0KBJTYeVJfGtahBZYuY7(yQy7SWTg8fiWgFwY04qjaYMA(sqwkHbvVkb4dJObrrYVbxCjmWfdhNJdLaiBQ5L2yjJxctr5u)UpMk2olCRbFbcSXNLmnoucGSPMVeKLsyq1Rsa(WiAquK8BWfxcblbESoGpA)dNIEv3cwln5mWIzVLmpdu2lNao2MfztgMaYGZa8va0OP6wWAPjNb4Ra4eWX2SilmbKbNb4RaK7(CFMOd992X2z5qwYouhZa5qDEiScCFmvSDw4QUfSwAwKm2X25GlUKri4AgrRFfa3uXsfOrZfdhNJLZT41BLIHjco2inAHjGm4gX5134(yg8mZjbMm6hHGBeNxV2CJj4MkwQanAJqWTXw51MBmb3uXsfOrt1TG1stUrCE9nUpMbpdmgNao2MLHcJObbpwhWhTNTGC3htfBNfUQBbRLMLNLmnwb8BaodMMdizZIIGfMRa80bMLbMJNbuxfm4IlHEv3cwln5y5ClE9UIvBo4eWX2SqJMQBbRLMCMrO0hell4nXXITtobCSnlYjJ(ri4gX51Rn3ycUPILkqJ2ieCBSvET5gtWnvSubztgMaYGBeNxFJ7JzWZmNey0OfgrdcESoGpA)Ok8F9OPOGC3htfBNfUQBbRLMLNLmnwb8BaodMMdiXXuMlb8LzacVdwzvdU4suDlyT0KBJTYeVJfGtahBZYuuqg9tc0b2oocm(Mffblmxb4PdmldmhpdOUkGgnv3cwln5BwueSWCfGNoWSmWC8mG6QaobCSnlYDFmvSDw4QUfSwAwEwY0yfWVb4myAoGegbmg(sapvOuaXGlUev3cwln52yRmX7yb4eWX2SiJGLapwhWhT)HtPPyYOFsGoW2XrGX3SOiyH5kapDGzzG54za1vb0OP6wWAPjFZIIGfMRa80bMLbMJNbuxfWjGJTzrU7JPITZcx1TG1sZYZsMgRa(naNbtZbKWmcLoDNEgOO0tTjMAJ3bxCjQUfSwAYTXwzI3XcWjGJTzrg9tc0b2oocm(Mffblmxb4PdmldmhpdOUkGgnv3cwln5BwueSWCfGNoWSmWC8mG6QaobCSnlYDFmvSDw4QUfSwAwEwY0yfWVb4ugCXLO6wWAPj3gBLjEhlaNao2Mfz0pjqhy74iW4BwueSWCfGNoWSmWC8mG6QaA0uDlyT0KVzrrWcZvaE6aZYaZXZaQRc4eWX2Si39zIo0e6wWAPz5(yQy7SWvDlyT0S8SKPnIZRVX9Xm4zGXgCXLWaxmCCooucGSPMxAJLmo2Omv3cwln5y5ClE9UIvBo4eWX2SmL8KP6wWAPjNzek9bXYcEtCSy7KtahBZYuYtwycidowo3IxVRy1MdA0MmmbKbhlNBXR3vSAZX9zIoK(BQo0tIvBooK0nMp03yekp0Well4nXXITZdT4hclwX(93u7qDmdKd9ngHYdnmXYcEtCSy78qUy44Lbpum3f4qUWMAh6BaJjwOehAc9kg8qYxrG87Va7qFx7SeKUSX7HAYHOZdGKM4qYxJLAaHFOVvu6dPMbfLLdT4hs1jBJTZYHmcCihiou0hAZsag7qZTGDi8MCOVDSvM4DSa87JPITZcx1TG1sZYZsMglNBXR3vSAZXGlUeQgznxbWlHFuyzUPMm6vDlyT0KBeNxFJ7JzWZaJXjGJTzzikqJgdSy2tzUAZbNTfZvaERdMCYOx1TG1stoZiu6dILf8M4yX2jNao2MLP0umA0CXWX5mJqPpiwwWBIJfBNCSr5Kr)KeSeWBIgWzGXelucVQxbnAtgMaYGBeNxFJ7JzWZmNey0OP6KHTbx1j1wzX2PVX9Xm4zGX4elPCkki39zIoK(BQo0tIvBooK0nMp03o2kt8owGdT4hkMHdP6wWAP5HA8d9TJTYeVJf4qB5qIw6HGSX0M5hIofOdSLaLd9nGXeluIdnHEfdEOj0j1wzX25HA8dfZWH(gWyhYs2H(wIZ7HA8dfZWH(gZjb2HIwdIzGWVpMk2olCv3cwlnlplzASCUfVExXQnhdU4sOAK1CfaVe(rHL5MAYOx1TG1stUrCE9nUpMbpdmgNao2MLHOanAmWIzpL5QnhC2wmxb4ToyYjJGLaEt0aodmMyHs4v9kKfMaYGBeNxFJ7JzWZmNeyYuDYW2GR6KARSy7034(yg8mWyCILuoKekit1TG1stUn2kt8owaobCSnltjV7JPITZcx1TG1sZYZsMglNBXR3vSAZXGlUetflvWdj4SqzijFDFmvSDw4QUfSwAwEwY0mJqPpiwwWBIJfBNdU4sOAK1CfaVe(rHL5MAYONbUy44CSCUfVExXQnhEg4IHJZXgPrBYWeqgCSCUfVExXQnhYDFmvSDw4QUfSwAwEwY0mJqPpiwwWBIJfBNdU4smvSubpKGZcLHK819XuX2zHR6wWAPz5zjtBJTYeVJfyWfxIPILk4HeCwOi5Nmg4IHJZXHsaKn18sBSKXlHPOCijpuwycidowo3IxVRy1MdzHjGm4gX5134(yg8mZjbMmcwc4nrd4mWyIfkHx1RqMQtg2gCvNuBLfBN(g3hZGNbgJtSKYHKqH7JPITZcx1TG1sZYZsM2gBLjEhlWGlUetflvWdj4SqrYpzmWfdhNJdLaiBQ5L2yjJxctr5qsEOSWeqgCSCUfVExXQnhYOpmbKbhlNBXR3kfdteYuDYW2GR6KARSy7034(yg8mWyCILuoffOrlmbKbxZiA9RaK7(yQy7SWvDlyT0S8SKPTXwzI3XcmO6vjaFyeniks(n4IlXuXsf8qcolugsYxYyGlgoohhkbq2uZlTXsgVeMIYHK8qztYalM9wY8mqzV8yvuUP29XuX2zHR6wWAPz5zjtxWCC60RzeT(vadU4siy5Q8JTuGWza(Q2yQFp8(yQy7SWvDlyT0S8SKPXY5w86TsXWeXGlUeQgznxbWlHFuyzUPMmg4IHJZXHsaKn18sBSKXlHPOCQVKr)ieCBSvET5gtWnvSubA0uDYW2GR6KARSy7034(yg8mWyYCXWX5mJqPpiwwWBIJfBNCSrztocb3ioVET5gtWnvSub5UpMk2olCv3cwlnlplzASCUfVERummrmO6vjaFyeniks(n4IlXuXsf8qcolugsYxYyGlgoohhkbq2uZlTXsgVeMIYP(6(yQy7SWvDlyT0S8SKPlnMWtaBeidQEvcWhgrdIIKFdU4scJObbpwhWhTFufE5rHPOGSWiAqWJ1b8r7zlmefUpMk2olCv3cwlnlplzAITfWZaJn4IlzYri4AZnMGBQyPc3htfBNfUQBbRLMLNLmDXuKfFvRj8JMkgCXLyQyPcEibNfkdj5lzt6IHJZzgHsFqSSG3ehl2o5yJYMu1TG1stoZiu6dILf8M4yX2jNag79(CFMOdnHMkKwgh6BDxXgluUpMk2olCvtfslJIKIuJ4SPM3zlXGlUeQgznxbWlHFuyzUPMmcwUk)ylfiCgGVQngAIVpt0H0H4qrFiScCidpaYHSXwDOTCOop0e(MdzLdf9HgjaviJd1ubIYgh3u7q0PFVhs68kGdvGi2u7qyJhAcFZ)Y9XuX2zHRAQqAzuEwY0fPgXztnVZwIbxCjQUfSwAYTXwzI3XcWjGJTzrg9MkwQGhsWzHYqs(sMPILk4HeCwOmLekiJGLRYp2sbcNb4RAJHO3uXsf8qcolu(UNy5OrZuXsf8qcolugIcYiy5Q8JTuGWza(Q2yi59i5UpMk2olCvtfslJYZsM2CBNnTy70lwh3bxCjunYAUcGxc)OWYCtnztwAmH7MmUamM391d01CgfGmv3cwln52yRmX7yb4eWX2SiJGLapwhWhT)HdrV8E2fdhNtWYv5vnHGngBNCc4yBwK7(yQy7SWvnviTmkplzAZTD20ITtVyDChCXLq1iR5kaEj8JclZn1KvAmH7MmUamM391d01CgfGm6vDlyT0KJLZT417kwT5GtahBZcnAtgMaYGJLZT417kwT5qMQBbRLMCMrO0hell4nXXITtobCSnlYDFmvSDw4QMkKwgLNLmT52oBAX2PxSoUdU4smvSubpKGZcLHK8Lmcwc8yDaF0(hoe9Y7zxmCCoblxLx1ec2ySDYjGJTzrU7JPITZcx1uH0YO8SKPlZMIsb4JzWJLsBsm)o4IlHQrwZva8s4hfwMBQjt1TG1stUn2kt8owaobCSnl3htfBNfUQPcPLr5zjtxMnfLcWhZGhlL2Ky(DWfxIPILk4HeCwOmKKVKrpdSy2BjZZaL9YJvr5MA0OrSL5bQqgCJXkCc4yBwMsYVhk395(mrhsFtnbCOHnIge3htfBNfUgKazvsyGfZEvVIbxCjUy448cgJbPN1TdNaMkKnjvJSMRa4JDl2uZJ3eVMr06xbqJ2ieCnJO1VcGBQyPc3htfBNfUgKazvplzAgyXSx1RyWfxcblxLFSLceodWx1gt9tEYMKQrwZva8XUfBQ5XBIxZiA9RaUpMk2olCnibYQEwY0w(6zjBWfxIQBbRLMCBSvM4DSaCc4yBwKrFycidodWxbWH0CfaJgnvtfsldEUAZHh3aA0iyjG3enGpodgPD6ekYDFmvSDw4AqcKv9SKPL2yjZxgHKbKbxCjmWfdhNJdLaiBQ5L2yjJxctr5qp8(yQy7SW1GeiR6zjtlTXsMVmcjdidU4syGlgoohhkbq2uZlTXsghBuMQBbRLMCBSvM4DSaCc4yBwgIcYOFYWeqgCSCUfVExXQnh0OfMaYGBeNxFJ7JzWZmNey0OP6KHTbx1j1wzX2PVX9Xm4zGXOrJylZduHm4gJv4aD3suK7(yQy7SW1GeiR6zjtlTXsMVmcjdidU4syGlgoohhkbq2uZlTXsghBuwycidowo3IxVRy1MdztgMaYGBeNxFJ7JzWZmNeyYMKylZduHm4gJv4aD3suKrVQBbRLMCSCUfVExXQnhCc4yBwgIcYuDlyT0KBJTYeVJfGtaJ9kBswhCSCUfVExXQnhCc4yBwOrBsv3cwln52yRmX7yb4eWyVYDFmvSDw4AqcKv9SKPzGfZEvVIbxCjeSCv(Xwkq4maFvBm1xps2KunYAUcGp2TytnpEt8AgrRFfW9XuX2zHRbjqw1ZsMghkbq2uZxcYsjm4IlHbUy44CCOeaztnV0glz8sykkN639XuX2zHRbjqw1ZsMghkbq2uZxcYsjm4IlHbUy44CCOeaztnV0glz8sykkN6HYuDlyT0KBJTYeVJfGtahBZYuYtg9tgMaYGJLZT417kwT5GgTWeqgCJ486BCFmdEM5KaJgnvNmSn4QoP2kl2o9nUpMbpdmgnAeBzEGkKb3ySchO7wIIC3htfBNfUgKazvplzACOeaztnFjilLWGlUeg4IHJZXHsaKn18sBSKXlHPOCQhklmbKbhlNBXR3vSAZHSjdtazWnIZRVX9Xm4zMtcmztsSL5bQqgCJXkCGUBjkYuDlyT0KBJTYeVJfGtaJ9kJEv3cwln5y5ClE9UIvBo4eWX2SmL8OrJbUy44CSCUfVExXQnhEg4IHJZXgL7(yQy7SW1GeiR6zjtZalM9QEfdU4sMKQrwZva8XUfBQ5XBIxZiA9RaUp3Nj6qY3qcKvDOVTPZp03lzBYgV3htfBNfUgKazvERbjW4YaNvn4IlXfdhNxWymi9SUD4eWuX9XuX2zHRbjqwL3A4zjtdJldCw1GlUKjPAK1CfaFSBXMAE8M41mIw)kG7JPITZcxdsGSkV1WZsMwAJLmFzesgqgu9QeGpmIgefj)gCXLqVQBbRLMCBSvM4DSaCc4yBwgIcYyGlgoohhkbq2uZlTXsghBKgng4IHJZXHsaKn18sBSKXlHPOCOhkNm6XxT5WtahBZYuQUfSwAYzGfZElzEgOSxobCSnlp)7r0OHVAZHNao2MLHuDlyT0KBJTYeVJfGtahBZIC3htfBNfUgKazvERHNLmnoucGSPMVeKLsyq1Rsa(WiAquK8BWfxcdCXWX54qjaYMAEPnwY4LWuuoLe5jt1TG1stUn2kt8owaobCSnltjpA0yGlgoohhkbq2uZlTXsgVeMIYP(DFmvSDw4AqcKv5TgEwY04qjaYMA(sqwkHbvVkb4dJObrrYVbxCjQUfSwAYTXwzI3XcWjGJTzzikiJbUy44CCOeaztnV0glz8sykkN6xv3WI5Mu11xhmHfBNtGy4rnQrTca]] )

end
