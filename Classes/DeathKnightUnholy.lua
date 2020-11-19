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
            dot = "buff"
        },
        unholy_blight = {
            id = 115994,
            duration = 14,
            tick_time = function () return 2 * haste end,
            max_stack = 4,
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

            toggle = "cooldowns",

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


    spec:RegisterPack( "Unholy", 20201118, [[dGK4ObqiGQhPuvSjQsJcO0PakwfsIIELsOzrQ0Uq1VuImmKKogsQLPuLNPurttPQ6AKQQTPuv6BkvOghPQOZPuHyDijk08uQ09qI9PeCqLkqlujQhQubyIkvqxejrLpQuHuojsIsTssfVejrvMPsfs1nrsuWoPQyOkvaTuKev1tHyQuv6QkvizRijkzVK8xedwOdtzXc8yctg0LvTzaFgPgTs60kwnPQWRjvz2OCBsz3I(TudxqhhjrwoupNOPl56qA7uv9DQIXtQkDELY6rsy(az)uzf1kFviqRUYN9O6EuLAQPwFYPwFs9oE)7RcP2cVcj0e6z0xHKM2vi7OY1MTPqcTnwBqLVkezJIfxHSwvOKkJlTe9uRObCrRTKC0qzwnDkWgqTKC0elPqcqhwrLDQcuiqRUYN9O6EuLAQPwFYPwFs9oEN6xHidVq5ZE6FpfY6aHpvbke4LcfY(4I7WB1QlsLxo0RLlUJkxB2MtN9Xf9P9FTGJDrQ1N66I7r19OQthNo7JlUdc1hOYs7zjDXQDXDyUdxAhEGH9L2H3QvPlUdrVlwTl2jBZffnAwUyzy6xsx0ZA7Ig(U413WlQdDXQDr24)UiRtAx8zJsV6Iv7IAwvh7IG16tKVqdDX9HAWWviSrwsLVkeRpr(cnu5RYhQv(QqEAbSdvlRqe4PoEmfc8wTs0lh61Id4Prt4HKYW0VKU4cuCrXMGDYZRnx6IGa5IyBGK7)zXniuYV(oYs6IEDrSnqY9)S4gek54RztkDXDP4IutTcXe10PcXYncmHQs5ZEkFvipTa2HQLvic8uhpMcbERwj6Ld9AXb80Oj8qszy6xsxCbkUO(viMOMoviwUrGjuvkF2PYxfYtlGDOAzfIap1XJPqa3f9B4XcyNh2nBsAcqJj0gMU3y3f96Iy0CeKW2ZXC4bgXuU4UU4Eu1fbbYfdqba4sui8jb2TghFtuketutNkKhoWRncvP8z)kFvipTa2HQLviMOMoviaxwhpjnrw4rVRqe4PoEmfc8bOaaCGlRJNKM4PrtixwMqpxCxkU4oDrVUOOBgS9KClSfgBluEo(A2KsxCxxCNkeXMGDszy6xsLpuRkLp6x5Rc5PfWouTScXe10Pcb4Y64jPjYcp6DfIap1XJPqGpafaGdCzD8K0epnAc5YYe65I76IuRqeBc2jLHPFjv(qTQu(SVkFvipTa2HQLviMOMoviaxwhpjnrw4rVRqe4PoEmfcgnpVgTtQMSFxCxxeSUOOBgS9KC4TALyjKaVW244RztkDrVUi4UyzSNfhEGHD(tlGDOlccKlk6MbBpjhEGHDo(A2Ksx0Rlwg7zXHhyyN)0cyh6IGrHi2eStkdt)sQ8HAvP8zhR8vH80cyhQwwHiWtD8ykeWDr)gESa25HDZMKMa0ycTHP7n2viMOMovipCGxBeQsvkKlLpfxQ8v5d1kFvipTa2HQLvic8uhpMcbJMNxJ2jvtO2fxWfPfqx0RlIrZrqcBph7I76I7NQketutNkeTR14nsdqyOIbsG4BAsvP8zpLVkKNwa7q1YkebEQJhtHaVvRelHe4f2gVgHEts7IGa5IHV4wyli0RnkJBIA8Fx0RlAIA8FYZRnx6IuCrQviMOMovibSUHKgGuRN88ABQs5Zov(QqEAbSdvlRqe4PoEmfcyDrr3my7j5wylm2wO8C81SjLU4UU4(6IEDrr3my7j5gwBJ0aKA9e4nihFnBsPlUGlk6MbBpjx0j8P8qcBaoqJfNJVMnP0fbJlccKlk6MbBpj3WABKgGuRNaVb54RztkDXDDX9uiMOMovi0OggowsAaIrfh31QQu(SFLVkKNwa7q1YkebEQJhtHeGcaWXxOh7sjbOXIZrdDrqGCXauaao(c9yxkjanwCIOrZ6yUSmHEU4UUi1uRqmrnDQqQ1tqZGgnHeGglUQu(OFLVkKNwa7q1YkebEQJhtHaUlcVvRelHe4f2gVgHEtsRqmrnDQqaAbQ8qIrfhp1jb30uLYN9v5Rc5PfWouTScrGN64XuiWU4IofplSvhsayM2jbO4KJVMnP0fP4IuvHyIA6uHi6u8SWwDibGzAxvkF2XkFvipTa2HQLvic8uhpMcbCxeERwjwcjWlSnEnc9MKwHyIA6uHeIIhGTjPjbmtwQs5J(u5Rc5PfWouTScrGN64XuiLXEwCdRTrAasTEc00Yd5pTa2HUOxx8s5tX5(h50jPbiHhdCrnDY1MSXUOxxmafaGJMRnBJil8t6ALJg6IGa5IxkFko3)iNojnaj8yGlQPtU2Kn2f96IHV4wyli0RnkJBIA8FxeeixSm2ZIByTnsdqQ1tGMwEi)PfWo0f96IHV4wyli0RnkJBIA8Fx0Rlk6MbBpj3WABKgGuRNaVb54RztkDXfCX9LQUiiqUyzSNf3WABKgGuRNanT8q(tlGDOl61fdFXnS2gHETrzCtuJ)RqmrnDQq80yg0)NKGVStlfxvkF2ru(QqEAbSdvlRqe4PoEmfc4Ui8wTsSesGxyB8Ae6njTl61fdqba4O5AZ2iYc)KUw5OHUOxxeCx8s5tX5(h50jPbiHhdCrnDY1MSXUOxxeCxSm2ZIByTnsdqQ1tGMwEi)PfWo0fbbYfldt)IxJ2jvtGZDXDDrr3my7j5wylm2wO8C81SjLketutNkepnMb9)jj4l70sXvLYhQPQYxfYtlGDOAzfIap1XJPqa3fH3QvILqc8cBJxJqVjPviMOMovi4jmKDYKezOjUQu(qn1kFviMOMovi4BHtstayM2LkKNwa7q1YQsvke4bmuwP8v5d1kFviMOMoviAtcja4FQ4kKNwa7q1YQs5ZEkFvipTa2HQLviDOcr(sHyIA6uH43WJfWUcXVXqVcr0nd2EsUevtRtcTHP7n254RztkDXDDr97IEDXYyplUevtRtcTHP7n25pTa2Hke)gMKM2viHDZMKMa0ycTHP7n2vLYNDQ8vH80cyhQwwHiWtD8ykemAocsy75yo8aJykxCbxCF1Vl61fbRlg(ItBy6EJDUjQX)DrqGCrWDXYyplUevtRtcTHP7n25pTa2HUiyCrVUignphEGrmLlUafxu)ketutNkedlS8KQX4NLQu(SFLVkKNwa7q1YkebEQJhtHe(ItBy6EJDUjQX)DrqGCXauaaoAU2SnIjLgkR4OHUiiqUyzSNf3WABKgGuRNanT8q(tlGDOl61fbRlg(IByTnc9AJY4MOg)3fbbYffDZGTNKByTnsdqQ1tG3GC81SjLU4cUyzy6x8A0oPAcCUlcgfIjQPtfsaRBibafVPkLp6x5Rc5PfWouTScrGN64XuiHV40gMU3yNBIA8FxeeixmafaGJMRnBJysPHYkoAOlccKlwg7zXnS2gPbi16jqtlpK)0cyh6IEDrW6IHV4gwBJqV2OmUjQX)DrqGCrr3my7j5gwBJ0aKA9e4nihFnBsPlUGlwgM(fVgTtQMaN7IGrHyIA6uHeCS8y9MKwvkF2xLVkKNwa7q1YkebEQJhtHeGcaWrZ1MTrKf(jDTYrdviMOMoviSHETKe9bkKw7zPkLp7yLVkKNwa7q1YkebEQJhtHe(ItBy6EJDUjQX)DrqGCXauaaoAU2SnIjLgkR4OHUiiqUyzSNf3WABKgGuRNanT8q(tlGDOl61fbRlg(IByTnc9AJY4MOg)3fbbYffDZGTNKByTnsdqQ1tG3GC81SjLU4cUyzy6x8A0oPAcCUlcgfIjQPtfILIllSXicJXuLYh9PYxfYtlGDOAzfIap1XJPqmrn(p551MlDXfO4I75IGa5IG1fXO55WdmIPCXfO4I63f96Iy0CeKW2ZXC4bgXuU4cuCX9LQUiyuiMOMovigwy5jHOm5vLYNDeLVkKNwa7q1YkebEQJhtHe(ItBy6EJDUjQX)DrqGCXauaaoAU2SnIjLgkR4OHUiiqUyzSNf3WABKgGuRNanT8q(tlGDOl61fbRlg(IByTnc9AJY4MOg)3fbbYffDZGTNKByTnsdqQ1tG3GC81SjLU4cUyzy6x8A0oPAcCUlcgfIjQPtfcWGFaRBOQu(qnvv(QqEAbSdvlRqe4PoEmfsakaahnxB2grw4N01khn0f96IMOg)N88AZLUifxKAfIjQPtfsGrtAasHhHEsvP8HAQv(QqEAbSdvlRqe4PoEmfsnA3fxWf3JQUiiqUi4U4PsOty4HCSPfojnX0cztHcpHEOn)nRipPN8UiiqUi4U4PsOty4HC)JC6K0ae41g5viMOMoviOYtM6AsvP8H69u(QqEAbSdvlRqmrnDQqmQqUAytsa6SinajS9CScrGN64XuiG1fVu(uCU)roDsAas4XaxutN8Nwa7qx0RlcUlwg7zXrZ1MTrmP0qzf)PfWo0fbJlccKlcwxeCx8s5tX5IoHpLhsydWbAS4CntF0yx0RlcUlEP8P4C)JC6K0aKWJbUOMo5pTa2HUiyuiPPDfIrfYvdBscqNfPbiHTNJvLYhQ3PYxfYtlGDOAzfIjQPtfIrfYvdBscqNfPbiHTNJvic8uhpMcr0nd2EsUf2cJTfkphFnBsPlURls9(DrVUiyDXlLpfNl6e(uEiHnahOXIZ1m9rJDrqGCXlLpfN7FKtNKgGeEmWf10j)PfWo0f96ILXEwC0CTzBetknuwXFAbSdDrWOqst7keJkKRg2KeGolsdqcBphRkLpuVFLVkKNwa7q1YketutNkeJkKRg2KeGolsdqcBphRqe4PoEmfcWqVwe81SjLU4UUOOBgS9KClSfgBluEo(A2KsxCrxCN7xHKM2vigvixnSjjaDwKgGe2EowvkFOw)kFvipTa2HQLviMOMoviMC1VLxsWgv0yIOXgtHiWtD8yke4dqba4yJkAmr0yJrGpafaGlltONlURlsTcjnTRqm5QFlVKGnQOXerJnMQu(q9(Q8vH80cyhQwwHyIA6uHyYv)wEjbBurJjIgBmfIap1XJPqcFXPrnmCSK0aeJkoURvUjQX)DrVUy4lUf2cc9AJY4MOg)xHKM2viMC1VLxsWgv0yIOXgtvkFOEhR8vH80cyhQwwHyIA6uHyYv)wEjbBurJjIgBmfIap1XJPqeDZGTNKBHTWyBHYZX3GBUOxxeSU4LYNIZfDcFkpKWgGd0yX5AM(OXUOxxeyOxlc(A2KsxCxxu0nd2EsUOt4t5He2aCGglohFnBsPlUOlUhvDrqGCrWDXlLpfNl6e(uEiHnahOXIZ1m9rJDrWOqst7ketU63YljyJkAmr0yJPkLpuRpv(QqEAbSdvlRqmrnDQqm5QFlVKGnQOXerJnMcrGN64Xuiad9ArWxZMu6I76IIUzW2tYTWwySTq554RztkDXfDX9OQcjnTRqm5QFlVKGnQOXerJnMQu(q9oIYxfYtlGDOAzfIjQPtfI)roDsAac8AJ8kebEQJhtHawxu0nd2EsUf2cJTfkphFdU5IEDr4dqba4axwhpjnXtJMqUSmHEU4cuCX97IEDXlLpfN7FKtNKgGeEmWf10j)PfWo0fbJlccKlgGcaWrZ1MTrmP0qzfhn0fbbYfdFXPnmDVXo3e14)kK00UcX)iNojnabETrEvP8zpQQ8vH80cyhQwwHyIA6uHGnTWjPjMwiBku4j0dT5Vzf5j9KxHiWtD8yker3my7j5wylm2wO8C81SjLU4UU4EUiiqUyzSNf3WABKgGuRNanT8q(tlGDOlccKlITbsU)Nf3GqjFsxCxxu)kK00UcbBAHtstmTq2uOWtOhAZFZkYt6jVQu(Sh1kFvipTa2HQLviMOMovibB0DEsWpXyAwAcfIap1XJPqeDZGTNKlr106KqBy6EJDo(A2KsxCbxCFPQlccKlcUlwg7zXLOAADsOnmDVXo)PfWo0f96I1ODxCbxCpQ6IGa5IG7INkHoHHhYXMw4K0etlKnfk8e6H283SI8KEYRqst7kKGn6opj4NymnlnHQu(S3EkFvipTa2HQLviMOMovi6JljRTh2XkebEQJhtHe(ItBy6EJDUjQX)DrqGCrWDXYyplUevtRtcTHP7n25pTa2HUOxxSgT7Il4I7rvxeeixeCx8uj0jm8qo20cNKMyAHSPqHNqp0M)MvKN0tEfsAAxHOpUKS2EyhRkLp7TtLVkKNwa7q1YketutNkeAJDHXyhljb30tHiWtD8ykKWxCAdt3BSZnrn(VlccKlcUlwg7zXLOAADsOnmDVXo)PfWo0f96I1ODxCbxCpQ6IGa5IG7INkHoHHhYXMw4K0etlKnfk8e6H283SI8KEYRqst7keAJDHXyhljb30tvkF2B)kFvipTa2HQLviMOMovi04oPLKq8Ozmc2OVcrGN64Xuiy08U4UuCXD6IEDrW6I1ODxCbxCpQ6IGa5IG7INkHoHHhYXMw4K0etlKnfk8e6H283SI8KEY7IGrHKM2vi04oPLKq8Ozmc2OVQu(SN(v(QqEAbSdvlRqe4PoEmfIOBgS9KCdRTrAasTEc8gKJVb3CrqGCXWxCAdt3BSZnrn(VlccKlgGcaWrZ1MTrmP0qzfhnuHyIA6uHe210PQu(S3(Q8vH80cyhQwwHiWtD8ykeyxC)dgL9SiHmJg9C8bWxUAbS7IEDrWDXYyploAU2SnsaBOxl(tlGDOl61fb3fX2aj3)ZIBqOKF9DKLuHyIA6uH0Ova(MEQs5ZE7yLVkKNwa7q1YkebEQJhtHa7I7FWOSNfjKz0ONJpa(YvlGDx0RlcwxeCxSm2ZIJMRnBJeWg61I)0cyh6IGa5ILXEwC0CTzBKa2qVw8Nwa7qx0Rlk6MbBpjhnxB2gjGn0RfhFnBsPlcgx0RlAIA8FYZRnx6IlqXf3tHyIA6uH0Ova(MEQs5ZE6tLVkKNwa7q1YkebEQJhtHGrZd0y6ZLOHhllSnj)uj0jm8qx0Rlcwxe2fha3YIaC)hZXhaF5QfWUlccKlc7IhW6gsczgn654dGVC1cy3fbJcXe10PcPrRa8n9uLYN92ru(QqEAbSdvlRqmrnDQqegJrmrnDsyJSuiSrwK00Ucr0nd2EsPQu(StQQ8vH80cyhQwwHyIA6uHimgJyIA6KWgzPqyJSiPPDfYLYNIlvLYNDsTYxfYtlGDOAzfIap1XJPqmrn(p551MlDXfO4I75IEDrW6IIUzW2tYH3QvILqc8cBJJVMnP0f31fPMQUOxxeCxSm2ZIdpWWo)PfWo0fbbYffDZGTNKdpWWohFnBsPlURlsnvDrVUyzSNfhEGHD(tlGDOlcgx0RlcUlcVvRelHe4f2gVgHEtsRqmrnDQqWOjXe10jHnYsHWgzrst7keRpr(cnuvkF25EkFvipTa2HQLvic8uhpMcXe14)KNxBU0fxGIlUNl61fH3QvILqc8cBJxJqVjPviMOMoviy0KyIA6KWgzPqyJSiPPDfI1NeGILLQu(SZDQ8vH80cyhQwwHiWtD8yketuJ)tEET5sxCbkU4EUOxxeSUi4Ui8wTsSesGxyB8Ae6njTl61fbRlk6MbBpjhERwjwcjWlSno(A2KsxCbxKAQ6IEDrWDXYyplo8ad78Nwa7qxeeixu0nd2Eso8ad7C81SjLU4cUi1u1f96ILXEwC4bg25pTa2HUiyCrWOqmrnDQqWOjXe10jHnYsHWgzrst7ke6NhpcI1xvkF25(v(QqEAbSdvlRqe4PoEmfIjQX)jpV2CPlsXfPwHyIA6uHimgJyIA6KWgzPqyJSiPPDfc9ZJhHQuLcjeFrRfyLYxLpuR8vHyIA6uHe210Pc5PfWouTSQu(SNYxfYtlGDOAzfsAAxHyuHC1WMKa0zrAasy75yfIjQPtfIrfYvdBscqNfPbiHTNJvLYNDQ8vHyIA6uHGTrEc8guH80cyhQwwvQsHi6MbBpPu5RYhQv(QqmrnDQqqLNm11KkKNwa7q1YQs5ZEkFvipTa2HQLvic8uhpMcj8fN2W09g7CtuJ)7IGa5IbOaaC0CTzBetknuwXrdDrqGCXYyplUH12inaPwpbAA5H8Nwa7qx0Rlcwxm8f3WABe61gLXnrn(VlccKlk6MbBpj3WABKgGuRNaVb54RztkDXfCXYW0V41ODs1e4CxemketutNkKWUMovLYNDQ8vH80cyhQwwHiWtD8yker3my7j5O5AZ2ibSHET44RztkDXDDr97IEDXYyploAU2SnsaBOxl(tlGDOlccKlcUlwg7zXrZ1MTrcyd9AXFAbSdviMOMovigwBJ0aKA9e4nOQu(SFLVkKNwa7q1YkebEQJhtHaUlITbsU)Nf3Gqj)67ilPl61fbRlk6MbBpj3WABKgGuRNaVb54RztkDXfCr97IGa5IWB1krVCOxloCKwa7eRlOlcgx0Rlcwxu0nd2EsUf2cJTfkphFdU5IEDrW6IWhGcaWbUSoEsAINgnHCzzc9CXfO4I73fbbYfXO5DXfO4I70fbJlccKlk6MbBpj3cBHX2cLNJVMnP0fbJl61fb3fX2aj3)ZIBqOKF9DKLuHyIA6uHGMRnBJeWg61svkF0VYxfYtlGDOAzfIap1XJPqW2aj3)ZIBqOKF9DKL0f96IG1fnrn(p551MlDXfO4I75IGa5IyBGK7)zXniuYN0fxWfPw)UiyuiMOMoviO5AZ2ibSHETuLYN9v5Rc5PfWouTScrGN64XuiG7IyBGK7)zXniuYV(oYs6IEDrr3my7j5O5AZ2ibSHET44RztkDrVUiyDrWDrmAEGgtFo8gKnxwerpm(PsOty4HUiiqUignpqJPphEdYMllIOhg)uj0jm8qx0RlcwxeCxmafaGdnSEKcBPeOXAwnDYrdDrVUi4UyzSNfhnxB2gj0ef)PfWo0fbbYflJ9S4O5AZ2iHMO4pTa2HUiyCrWOqmrnDQqGgwpsHTuc0ynRMovLYNDSYxfYtlGDOAzfIap1XJPqa3fX2aj3)ZIBqOKF9DKL0f96IG7ILXEwC0CTzBKa2qVw8Nwa7qfIjQPtfc0W6rkSLsGgRz10PQu(Opv(QqEAbSdvlRqe4PoEmfc2gi5(FwCdcL8RVJSKUOxxeSUOjQX)jpV2CPlUafxCpxeeixeBdKC)plUbHs(KU4cUi163fbJcXe10PcbAy9if2sjqJ1SA6uvkF2ru(QqEAbSdvlRqe4PoEmfIjQX)jpV2CPlsXfP2f96IWhGcaWbUSoEsAINgnHCzzc9CXfO4I73f96IG1fbRlcUlwg7zXrZ1MTrcyd9AXFAbSdDrqGCXYyplUH12inaPwpbAA5H8Nwa7qxeeixu0jeDkUOt)TWQPtsdqQ1tG3G8Nwa7qxemUiiqUyzSNfhnxB2gjGn0Rf)PfWo0f96IG7ILXEwCdRTrAasTEc00Yd5pTa2HUOxxe2fhnxB2gjGn0RfhFnBsPlcgfIjQPtfIf2cJTfkVQu(qnvv(QqEAbSdvlRqe4PoEmfIjQX)jpV2CPlUafxCpx0RlcFakaah4Y64jPjEA0eYLLj0ZfxGIlUFx0RlcUlcVvRelHe4f2gVgHEtsRqmrnDQqSWwySTq5vLYhQPw5Rc5PfWouTScrGN64Xuiy0CeKW2ZXC4bgXuU4UUi17xHyIA6uHir106KqBy6EJDvP8H69u(QqEAbSdvlRqe4PoEmfIjQX)jpV2CPlsXfP2f96IWhGcaWbUSoEsAINgnHCzzc9CXDDX9CrVUiyDXWxClSfe61gLXnrn(VlccKlk6eIofx0P)wy10jPbi16jWBq(tlGDOlcgfIjQPtfcAU2SnIjLgkRuLYhQ3PYxfYtlGDOAzfIjQPtfcAU2SnIjLgkRuic8uhpMcXe14)KNxBU0fxGIlUNl61fHpafaGdCzD8K0epnAc5YYe65I76I7PqeBc2jLHPFjv(qTQu(q9(v(QqEAbSdvlRqmrnDQqKnkJGVfEScrGN64XuiLHPFXRr7KQjHIISt97I76I63f96ILHPFXRr7KQjW5U4cUO(viInb7KYW0VKkFOwvkFOw)kFvipTa2HQLvic8uhpMcbCxm8fNETrzCtuJ)RqmrnDQqW2ipbEdQkvPqOFE8iiwFLVkFOw5Rc5PfWouTScrGN64XuibOaaCjke(Ka7wJJVjkfIjQPtfYdh41gHQu(SNYxfYtlGDOAzfIap1XJPqa3f9B4XcyNh2nBsAcqJj0gMU3yxHyIA6uH8WbETrOkLp7u5Rc5PfWouTScXe10PcXtJMqIm8j8yfIap1XJPqaRlk6MbBpj3cBHX2cLNJVMnP0fxWf1Vl61fHpafaGdCzD8K0epnAc5OHUiiqUi8bOaaCGlRJNKM4PrtixwMqpxCbxC)UiyCrVUiyDrGHETi4RztkDXDDrr3my7j5WB1kXsibEHTXXxZMu6Il6IutvxeeixeyOxlc(A2KsxCbxu0nd2EsUf2cJTfkphFnBsPlcgfIytWoPmm9lPYhQvLYN9R8vH80cyhQwwHyIA6uHaCzD8K0ezHh9UcrGN64XuiWhGcaWbUSoEsAINgnHCzzc9CXDP4I70f96IIUzW2tYTWwySTq554RztkDXDDXD6IGa5IWhGcaWbUSoEsAINgnHCzzc9CXDDrQviInb7KYW0VKkFOwvkF0VYxfYtlGDOAzfIjQPtfcWL1XtstKfE07kebEQJhtHi6MbBpj3cBHX2cLNJVMnP0fxWf1Vl61fHpafaGdCzD8K0epnAc5YYe65I76IuRqeBc2jLHPFjv(qTQuLcX6tcqXYs5RYhQv(QqEAbSdvlRqe4PoEmfcgnhbjS9CmhEGrmLlURlcwxKAQ6Il6IWB1krVCOxloGNgnHhskdt)s6Iuz6I70fbJl61fH3QvIE5qVwCapnAcpKugM(L0f31f3xx0RlcUl63WJfWopSB2K0eGgtOnmDVXUcXe10Pc5Hd8AJqvkF2t5Rc5PfWouTScrGN64Xuiy0CeKW2ZXC4bgXuU4UU4E63f96IWB1krVCOxloGNgnHhskdt)s6Il4I63f96IG7I(n8ybSZd7MnjnbOXeAdt3BSRqmrnDQqE4aV2iuLYNDQ8vH80cyhQwwHiWtD8ykeWDr4TALOxo0RfhWtJMWdjLHPFjDrVUi4UOFdpwa78WUztstaAmH2W09g7ketutNkKhoWRncvP8z)kFviMOMoviEA0esKHpHhRqEAbSdvlRkLp6x5Rc5PfWouTScrGN64XuiG7I(n8ybSZd7MnjnbOXeAdt3BSRqmrnDQqE4aV2iuLQui0ppEekFv(qTYxfYtlGDOAzfIap1XJPqcqba4sui8jb2TghFtuUOxxeCx0VHhlGDEy3SjPjanMqBy6EJDxeeixm8fN2W09g7CtuJ)RqmrnDQqG3QvIOhMQu(SNYxfYtlGDOAzfIap1XJPqWO5iiHTNJ5WdmIPCXDDrQ3Pl61fb3f9B4XcyNh2nBsAcqJj0gMU3yxHyIA6uHaVvRerpmvP8zNkFvipTa2HQLvic8uhpMcr0nd2EsUf2cJTfkphFnBsPcXe10PcbEGHDvP8z)kFvipTa2HQLvic8uhpMcb(auaaoWL1Xtst80OjKlltONlUGlUFfIjQPtfINgnHez4t4XQs5J(v(QqEAbSdvlRqe4PoEmfc8bOaaCGlRJNKM4Prtihn0f96IIUzW2tYTWwySTq554RztkDXfCr97IEDrW6IG7ILXEwC0CTzBKa2qVw8Nwa7qxeeixSm2ZIByTnsdqQ1tGMwEi)PfWo0fbbYffDcrNIl60FlSA6K0aKA9e4ni)PfWo0fbbYfX2aj3)ZIBqOKF9DKL0fbJcXe10PcXtJMqIm8j8yvP8zFv(QqEAbSdvlRqe4PoEmfc8bOaaCGlRJNKM4Prtihn0f96ILXEwC0CTzBKa2qVw8Nwa7qx0RlcUlwg7zXnS2gPbi16jqtlpK)0cyh6IEDrWDrrNq0P4Io93cRMojnaPwpbEdYFAbSdDrVUi4Ui2gi5(FwCdcL8RVJSKUOxxeSUOOBgS9KC0CTzBKa2qVwC81SjLU4cUO(DrVUOOBgS9KClSfgBluEo(gCZf96IG7IWU4O5AZ2ibSHET44RztkDrqGCrWDrr3my7j5wylm2wO8C8n4MlcgfIjQPtfINgnHez4t4XQs5Zow5Rc5PfWouTScrGN64Xuiy0CeKW2ZXC4bgXuU4UU4Eu1f96IG7I(n8ybSZd7MnjnbOXeAdt3BSRqmrnDQqG3QvIOhMQu(Opv(QqEAbSdvlRqe4PoEmfc8bOaaCGlRJNKM4PrtixwMqpxCxxKAfIjQPtfcWL1XtstKfE07Qs5ZoIYxfYtlGDOAzfIap1XJPqGpafaGdCzD8K0epnAc5YYe65I76I73f96IIUzW2tYTWwySTq554RztkDXDDXD6IEDrW6IG7ILXEwC0CTzBKa2qVw8Nwa7qxeeixSm2ZIByTnsdqQ1tGMwEi)PfWo0fbbYffDcrNIl60FlSA6K0aKA9e4ni)PfWo0fbbYfX2aj3)ZIBqOKF9DKL0fbJcXe10Pcb4Y64jPjYcp6DvP8HAQQ8vH80cyhQwwHiWtD8yke4dqba4axwhpjnXtJMqUSmHEU4UU4(DrVUyzSNfhnxB2gjGn0Rf)PfWo0f96IG7ILXEwCdRTrAasTEc00Yd5pTa2HUOxxeCxu0jeDkUOt)TWQPtsdqQ1tG3G8Nwa7qx0RlcUlITbsU)Nf3Gqj)67ilPl61ffDZGTNKBHTWyBHYZX3GBUOxxeSUOOBgS9KC0CTzBKa2qVwC81SjLU4UU4oDrqGCryxC0CTzBKa2qVwC81SjLUiyuiMOMoviaxwhpjnrw4rVRkLputTYxfYtlGDOAzfIap1XJPqa3f9B4XcyNh2nBsAcqJj0gMU3yxHyIA6uHaVvRerpmvPkvPq8FSC6u5ZEuDpQsn1uVJviEmCojTuHqLTwyJRdDr9PlAIA60fzJSKCNokedTwBScbz0qzwnDUdaBaLcje3ad7kK9Xf3H3QvxKkVCOxlxChvU2SnNo7Jl6t7)Abh7IuRp11f3JQ7rvNooD2hxCheQpqLL2Zs6Iv7I7WChU0o8ad7lTdVvRsxChIExSAxSt2MlkA0SCXYW0VKUON12fn8DXRVHxuh6Iv7ISX)DrwN0U4ZgLE1fR2f1SQo2fbR1NiFHg6I7d1GH70XPJjQPtjpeFrRfy1IuwkSRPtNoMOMoL8q8fTwGvlszju5jtDnDtt7umQqUAytsa6SinajS9CSthtutNsEi(IwlWQfPSe2g5jWBqNooD2hxKkN(EbADOlE)hV5I1ODxSwVlAIQXU4iDrZVnmlGDUthtutNskAtcja4FQ4oD2hxKkldpwa7sNoMOMoLlszj)gESa21nnTtjSB2K0eGgtOnmDVXUU(ng6Pi6MbBpjxIQP1jH2W09g7C81SjL7QFVLXEwCjQMwNeAdt3BSZFAbSdD6SpUiv(MymM0PJjQPt5IuwYWclpPAm(zP7aqbJMJGe2EoMdpWiMAH9v)EbB4loTHP7n25MOg)heiWlJ9S4sunToj0gMU3yN)0cyhcgVy08C4bgXulqr)oDmrnDkxKYsbSUHeau8MUdaLWxCAdt3BSZnrn(piqbOaaC0CTzBetknuwXrdbbQm2ZIByTnsdqQ1tGMwEi)PfWo0lydFXnS2gHETrzCtuJ)dcKOBgS9KCdRTrAasTEc8gKJVMnPCHYW0V41ODs1e4CW40Xe10PCrklfCS8y9MKw3bGs4loTHP7n25MOg)heOauaaoAU2SnIjLgkR4OHGavg7zXnS2gPbi16jqtlpK)0cyh6fSHV4gwBJqV2OmUjQX)bbs0nd2EsUH12inaPwpbEdYXxZMuUqzy6x8A0oPAcCoyC6yIA6uUiLLyd9Ajj6duiT2Zs3bGsakaahnxB2grw4N01khn0PJjQPt5IuwYsXLf2yeHXy6oaucFXPnmDVXo3e14)GafGcaWrZ1MTrmP0qzfhneeOYyplUH12inaPwpbAA5H8Nwa7qVGn8f3WABe61gLXnrn(piqIUzW2tYnS2gPbi16jWBqo(A2KYfkdt)IxJ2jvtGZbJthtutNYfPSKHfwEsiktEDhakMOg)N88AZLlqzpqGalgnphEGrm1cu0VxmAocsy75yo8aJyQfOSVufmoDmrnDkxKYsad(bSUH6oaucFXPnmDVXo3e14)GafGcaWrZ1MTrmP0qzfhneeOYyplUH12inaPwpbAA5H8Nwa7qVGn8f3WABe61gLXnrn(piqIUzW2tYnS2gPbi16jWBqo(A2KYfkdt)IxJ2jvtGZbJthtutNYfPSuGrtAasHhHEsDhakbOaaC0CTzBezHFsxRC0qVMOg)N88AZLuO2PZ(4I7aqLvR5IfEs9EjDruPrFNoMOMoLlszju5jtDnPUdaLA0(c7rvqGa)uj0jm8qo20cNKMyAHSPqHNqp0M)MvKN0tEqGa)uj0jm8qU)roDsAac8AJ8oDmrnDkxKYsOYtM6A6MM2PyuHC1WMKa0zrAasy75yDhakG9s5tX5(h50jPbiHhdCrnDYFAbSd9cEzSNfhnxB2gXKsdLv8Nwa7qWaceyb)s5tX5IoHpLhsydWbAS4CntF0yVGFP8P4C)JC6K0aKWJbUOMo5pTa2HGXPJjQPt5IuwcvEYuxt300ofJkKRg2KeGolsdqcBphR7aqr0nd2EsUf2cJTfkphFnBs5UuVFVG9s5tX5IoHpLhsydWbAS4CntF0yqGUu(uCU)roDsAas4XaxutN8Nwa7qVLXEwC0CTzBetknuwXFAbSdbJthtutNYfPSeQ8KPUMUPPDkgvixnSjjaDwKgGe2Eow3bGcWqVwe81SjL7k6MbBpj3cBHX2cLNJVMnPCXDUFNoMOMoLlszju5jtDnDtt7um5QFlVKGnQOXerJnMUdaf4dqba4yJkAmr0yJrGpafaGlltO3Uu70Xe10PCrklHkpzQRPBAANIjx9B5LeSrfnMiASX0DaOe(ItJAy4yjPbigvCCxRCtuJ)7n8f3cBbHETrzCtuJ)70Xe10PCrklHkpzQRPBAANIjx9B5LeSrfnMiASX0DaOi6MbBpj3cBHX2cLNJVb38c2lLpfNl6e(uEiHnahOXIZ1m9rJ9cm0RfbFnBs5UIUzW2tYfDcFkpKWgGd0yX54RztkxCpQcce4xkFkox0j8P8qcBaoqJfNRz6JgdgNoMOMoLlszju5jtDnDtt7um5QFlVKGnQOXerJnMUdafGHETi4Rztk3v0nd2EsUf2cJTfkphFnBs5I7rvNoMOMoLlszju5jtDnDtt7u8pYPtsdqGxBKx3bGcyfDZGTNKBHTWyBHYZX3GBEHpafaGdCzD8K0epnAc5YYe6TaL979s5tX5(h50jPbiHhdCrnDYFAbSdbdiqbOaaC0CTzBetknuwXrdbbk8fN2W09g7CtuJ)70Xe10PCrklHkpzQRPBAANc20cNKMyAHSPqHNqp0M)MvKN0tEDhakIUzW2tYTWwySTq554Rztk3DpqGkJ9S4gwBJ0aKA9eOPLhYFAbSdbbcBdKC)plUbHs(K7QFNoMOMoLlszju5jtDnDtt7uc2O78KGFIX0S0e6oaueDZGTNKlr106KqBy6EJDo(A2KYf2xQcce4LXEwCjQMwNeAdt3BSZFAbSd9wJ2xypQcce4NkHoHHhYXMw4K0etlKnfk8e6H283SI8KEY70Xe10PCrklHkpzQRPBAANI(4sYA7HDSUdaLWxCAdt3BSZnrn(piqGxg7zXLOAADsOnmDVXo)PfWo0BnAFH9OkiqGFQe6egEihBAHtstmTq2uOWtOhAZFZkYt6jVthtutNYfPSeQ8KPUMUPPDk0g7cJXowscUPNUdaLWxCAdt3BSZnrn(piqGxg7zXLOAADsOnmDVXo)PfWo0BnAFH9OkiqGFQe6egEihBAHtstmTq2uOWtOhAZFZkYt6jVthtutNYfPSeQ8KPUMUPPDk04oPLKq8Ozmc2OVUdafmA(DPStVGTgTVWEufeiWpvcDcdpKJnTWjPjMwiBku4j0dT5Vzf5j9KhmoDmrnDkxKYsHDnDQ7aqr0nd2EsUH12inaPwpbEdYX3GBGaf(ItBy6EJDUjQX)bbkafaGJMRnBJysPHYkoAOtN9XfPYGnzztojTlsL1GrzplxChiZOrVlosx0CXq804P2C6yIA6uUiLLA0kaFtpDhakWU4(hmk7zrczgn654dGVC1cy3l4LXEwC0CTzBKa2qVw8Nwa7qVGJTbsU)Nf3Gqj)67ilPthtutNYfPSuJwb4B6P7aqb2f3)GrzplsiZOrphFa8LRwa7Ebl4LXEwC0CTzBKa2qVw8Nwa7qqGkJ9S4O5AZ2ibSHET4pTa2HEfDZGTNKJMRnBJeWg61IJVMnPemEnrn(p551MlxGYEoDmrnDkxKYsnAfGVPNUdafmAEGgtFUen8yzHTj5NkHoHHh6fSWU4a4wweG7)yo(a4lxTa2bbc2fpG1nKeYmA0ZXhaF5QfWoyC6SpU4oOOMoDXD0hzjD6yIA6uUiLLegJrmrnDsyJS0nnTtr0nd2EsPthtutNYfPSKWymIjQPtcBKLUPPDkxkFkU0PJjQPt5IuwcJMetutNe2ilDtt7uS(e5l0qDhakMOg)N88AZLlqzpVGv0nd2Eso8wTsSesGxyBC81SjL7snv9cEzSNfhEGHD(tlGDiiqIUzW2tYHhyyNJVMnPCxQPQ3Yyplo8ad78Nwa7qW4fC4TALyjKaVW241i0BsANoMOMoLlszjmAsmrnDsyJS0nnTtX6tcqXYs3bGIjQX)jpV2C5cu2Zl8wTsSesGxyB8Ae6njTthtutNYfPSegnjMOMojSrw6MM2Pq)84rqS(6oaumrn(p551MlxGYEEbl4WB1kXsibEHTXRrO3K0EbROBgS9KC4TALyjKaVW244RztkxGAQ6f8Yyplo8ad78Nwa7qqGeDZGTNKdpWWohFnBs5cutvVLXEwC4bg25pTa2HGbmoDmrnDkxKYscJXiMOMojSrw6MM2Pq)84rO7aqXe14)KNxBUKc1oDC6SpU4oytLZfxgfllNoMOMoLCRpjafllkpCGxBe6oauWO5iiHTNJ5WdmIP2fSut1fH3QvIE5qVwCapnAcpKugM(LKkZDcgVWB1krVCOxloGNgnHhskdt)sU7(6fC)gESa25HDZMKMa0ycTHP7n2D6yIA6uYT(KauSSwKYspCGxBe6oauWO5iiHTNJ5WdmIP2Dp97fERwj6Ld9AXb80Oj8qszy6xYf0VxW9B4XcyNh2nBsAcqJj0gMU3y3PJjQPtj36tcqXYArkl9WbETrO7aqbC4TALOxo0RfhWtJMWdjLHPFj9cUFdpwa78WUztstaAmH2W09g7oDmrnDk5wFsakwwlszjpnAcjYWNWJD6yIA6uYT(KauSSwKYspCGxBe6oaua3VHhlGDEy3SjPjanMqBy6EJDNooD2hxChSPY5IiVqdD6yIA6uYT(e5l0qkwUrGju3bGc8wTs0lh61Id4Prt4HKYW0VKlqrSjyN88AZLGaHTbsU)Nf3Gqj)67ilPxSnqY9)S4gek54Rztk3Lc1u70Xe10PKB9jYxOHlszjl3iWeQ7aqbERwj6Ld9AXb80Oj8qszy6xYfOOFNoMOMoLCRpr(cnCrkl9WbETrO7aqbC)gESa25HDZMKMa0ycTHP7n29IrZrqcBphZHhyetT7EufeOauaaUefcFsGDRXX3eLthtutNsU1NiFHgUiLLaUSoEsAISWJExxXMGDszy6xskuR7aqb(auaaoWL1Xtst80OjKlltO3Uu2Pxr3my7j5wylm2wO8C81SjL7UtNoMOMoLCRpr(cnCrklbCzD8K0ezHh9UUInb7KYW0VKuOw3bGc8bOaaCGlRJNKM4PrtixwMqVDP2PJjQPtj36tKVqdxKYsaxwhpjnrw4rVRRytWoPmm9ljfQ1DaOGrZZRr7KQj7FxWk6MbBpjhERwjwcjWlSno(A2KsVGxg7zXHhyyN)0cyhccKOBgS9KC4bg254Rztk9wg7zXHhyyN)0cyhcgNoMOMoLCRpr(cnCrkl9WbETrO7aqbC)gESa25HDZMKMa0ycTHP7n2D640zFCXDGDnDkDrlHUyxRh7ID6IOY70Xe10PKl6MbBpPKcQ8KPUM0PJjQPtjx0nd2Es5IuwkSRPtDhakHV40gMU3yNBIA8FqGcqba4O5AZ2iMuAOSIJgccuzSNf3WABKgGuRNanT8q(tlGDOxWg(IByTnc9AJY4MOg)heir3my7j5gwBJ0aKA9e4nihFnBs5cLHPFXRr7KQjW5GXPZ(4I7a6MbBpP0PJjQPtjx0nd2Es5IuwYWABKgGuRNaVb1DaOi6MbBpjhnxB2gjGn0RfhFnBs5U63BzSNfhnxB2gjGn0Rf)PfWoeeiWlJ9S4O5AZ2ibSHET4pTa2HoDmrnDk5IUzW2tkxKYsO5AZ2ibSHET0DaOao2gi5(FwCdcL8RVJSKEbROBgS9KCdRTrAasTEc8gKJVMnPCb9dce8wTs0lh61IdhPfWoX6ccgVGv0nd2EsUf2cJTfkphFdU5fSWhGcaWbUSoEsAINgnHCzzc9wGY(bbcJMFbk7emGaj6MbBpj3cBHX2cLNJVMnPemEbhBdKC)plUbHs(13rwsNoMOMoLCr3my7jLlszj0CTzBKa2qVw6oauW2aj3)ZIBqOKF9DKL0lynrn(p551MlxGYEGaHTbsU)Nf3GqjFYfOw)GXPJjQPtjx0nd2Es5IuwcAy9if2sjqJ1SA6u3bGc4yBGK7)zXniuYV(oYs6v0nd2EsoAU2SnsaBOxlo(A2KsVGfCmAEGgtFo8gKnxwerpm(PsOty4HGaHrZd0y6ZH3GS5YIi6HXpvcDcdp0lybpafaGdnSEKcBPeOXAwnDYrd9cEzSNfhnxB2gj0ef)PfWoeeOYyploAU2SnsOjk(tlGDiyaJthtutNsUOBgS9KYfPSe0W6rkSLsGgRz10PUdafWX2aj3)ZIBqOKF9DKL0l4LXEwC0CTzBKa2qVw8Nwa7qNoMOMoLCr3my7jLlszjOH1JuylLanwZQPtDhakyBGK7)zXniuYV(oYs6fSMOg)N88AZLlqzpqGW2aj3)ZIBqOKp5cuRFW40Xe10PKl6MbBpPCrklzHTWyBHYR7aqXe14)KNxBUKc1EHpafaGdCzD8K0epnAc5YYe6TaL97fSGf8YyploAU2SnsaBOxl(tlGDiiqLXEwCdRTrAasTEc00Yd5pTa2HGaj6eIofx0P)wy10jPbi16jWBq(tlGDiyabQm2ZIJMRnBJeWg61I)0cyh6f8YyplUH12inaPwpbAA5H8Nwa7qVWU4O5AZ2ibSHET44RztkbJthtutNsUOBgS9KYfPSKf2cJTfkVUdaftuJ)tEET5YfOSNx4dqba4axwhpjnXtJMqUSmHElqz)EbhERwjwcjWlSnEnc9MK2PJjQPtjx0nd2Es5IuwsIQP1jH2W09g76oauWO5iiHTNJ5WdmIP2L6970Xe10PKl6MbBpPCrklHMRnBJysPHYkDhakMOg)N88AZLuO2l8bOaaCGlRJNKM4PrtixwMqVD3ZlydFXTWwqOxBug3e14)Gaj6eIofx0P)wy10jPbi16jWBq(tlGDiyC6yIA6uYfDZGTNuUiLLqZ1MTrmP0qzLUInb7KYW0VKuOw3bGIjQX)jpV2C5cu2Zl8bOaaCGlRJNKM4PrtixwMqVD3ZPJjQPtjx0nd2Es5Iuws2Omc(w4X6k2eStkdt)ssHADhakLHPFXRr7KQjHIISt9VR(9wgM(fVgTtQMaNVG(D6yIA6uYfDZGTNuUiLLW2ipbEdQ7aqb8WxC61gLXnrn(VthNoMOMoL8lLpfxsr7AnEJ0aegQyGei(MMu3bGcgnpVgTtQMq9c0cOxmAocsy754D3pvD6yIA6uYVu(uC5IuwkG1nK0aKA9KNxBt3bGc8wTsSesGxyB8Ae6njniqHV4wyli0RnkJBIA8FVMOg)N88AZLuO2PJjQPtj)s5tXLlszjAuddhljnaXOIJ7Av3bGcyfDZGTNKBHTWyBHYZXxZMuU7(6v0nd2EsUH12inaPwpbEdYXxZMuUGOBgS9KCrNWNYdjSb4anwCo(A2KsWacKOBgS9KCdRTrAasTEc8gKJVMnPC39C6yIA6uYVu(uC5IuwQwpbndA0esaAS46oaucqba44l0JDPKa0yX5OHGafGcaWXxOh7sjbOXItenAwhZLLj0BxQP2PJjQPtj)s5tXLlszjGwGkpKyuXXtDsWnnDhakGdVvRelHe4f2gVgHEts70Xe10PKFP8P4YfPSKOtXZcB1HeaMPDDhakWU4IofplSvhsayM2jbO4KJVMnPKcvD6yIA6uYVu(uC5IuwkefpaBtstcyMS0DaOao8wTsSesGxyB8Ae6njTthtutNs(LYNIlxKYsEAmd6)tsWx2PLIR7aqPm2ZIByTnsdqQ1tGMwEi)PfWo07LYNIZ9pYPtsdqcpg4IA6KRnzJ9gGcaWrZ1MTrKf(jDTYrdbb6s5tX5(h50jPbiHhdCrnDY1MSXEdFXTWwqOxBug3e14)Gavg7zXnS2gPbi16jqtlpK)0cyh6n8f3cBbHETrzCtuJ)7v0nd2EsUH12inaPwpbEdYXxZMuUW(svqGkJ9S4gwBJ0aKA9eOPLhYFAbSd9g(IByTnc9AJY4MOg)3PJjQPtj)s5tXLlszjpnMb9)jj4l70sX1DaOao8wTsSesGxyB8Ae6njT3auaaoAU2SnISWpPRvoAOxWVu(uCU)roDsAas4XaxutNCTjBSxWlJ9S4gwBJ0aKA9eOPLhYFAbSdbbQmm9lEnANunboFxr3my7j5wylm2wO8C81SjLoDmrnDk5xkFkUCrklHNWq2jtsKHM46oauahERwjwcjWlSnEnc9MK2PJjQPtj)s5tXLlszj8TWjPjamt7sNooD2hxezsA2DrFnm9lNoMOMoLC6NhpckWB1kr0dt3bGsakaaxIcHpjWU144BIYl4(n8ybSZd7MnjnbOXeAdt3BSdcu4loTHP7n25MOg)3PJjQPtjN(5XJyrklbVvRerpmDhaky0CeKW2ZXC4bgXu7s9o9cUFdpwa78WUztstaAmH2W09g7oDmrnDk50ppEelszj4bg21DaOi6MbBpj3cBHX2cLNJVMnP0PJjQPtjN(5XJyrkl5Prtirg(eESUdaf4dqba4axwhpjnXtJMqUSmHElSFNoMOMoLC6NhpIfPSKNgnHez4t4X6oauGpafaGdCzD8K0epnAc5OHEfDZGTNKBHTWyBHYZXxZMuUG(9cwWlJ9S4O5AZ2ibSHET4pTa2HGavg7zXnS2gPbi16jqtlpK)0cyhccKOti6uCrN(BHvtNKgGuRNaVb5pTa2HGaHTbsU)Nf3Gqj)67iljyC6yIA6uYPFE8iwKYsEA0esKHpHhR7aqb(auaaoWL1Xtst80OjKJg6Tm2ZIJMRnBJeWg61I)0cyh6f8YyplUH12inaPwpbAA5H8Nwa7qVGl6eIofx0P)wy10jPbi16jWBq(tlGDOxWX2aj3)ZIBqOKF9DKL0lyfDZGTNKJMRnBJeWg61IJVMnPCb97v0nd2EsUf2cJTfkphFdU5fCyxC0CTzBKa2qVwC81SjLGabUOBgS9KClSfgBluEo(gCdmoDmrnDk50ppEelszj4TALi6HP7aqbJMJGe2EoMdpWiMA39OQxW9B4XcyNh2nBsAcqJj0gMU3y3PJjQPtjN(5XJyrklbCzD8K0ezHh9UUdaf4dqba4axwhpjnXtJMqUSmHE7sTthtutNso9ZJhXIuwc4Y64jPjYcp6DDhakWhGcaWbUSoEsAINgnHCzzc92D)EfDZGTNKBHTWyBHYZXxZMuU7o9cwWlJ9S4O5AZ2ibSHET4pTa2HGavg7zXnS2gPbi16jqtlpK)0cyhccKOti6uCrN(BHvtNKgGuRNaVb5pTa2HGaHTbsU)Nf3Gqj)67iljyC6yIA6uYPFE8iwKYsaxwhpjnrw4rVR7aqb(auaaoWL1Xtst80OjKlltO3U73BzSNfhnxB2gjGn0Rf)PfWo0l4LXEwCdRTrAasTEc00Yd5pTa2HEbx0jeDkUOt)TWQPtsdqQ1tG3G8Nwa7qVGJTbsU)Nf3Gqj)67ilPxr3my7j5wylm2wO8C8n4MxWk6MbBpjhnxB2gjGn0RfhFnBs5U7eeiyxC0CTzBKa2qVwC81SjLGXPJjQPtjN(5XJyrklbVvRerpmDhakG73WJfWopSB2K0eGgtOnmDVXUthNo7JlUJ2ZJhHlUd2u5CXDG4PXtT50Xe10PKt)84rqS(uE4aV2i0DaOeGcaWLOq4tcSBno(MOC6yIA6uYPFE8iiw)fPS0dh41gHUdafW9B4XcyNh2nBsAcqJj0gMU3y3PJjQPtjN(5XJGy9xKYsEA0esKHpHhRRytWoPmm9ljfQ1DaOawr3my7j5wylm2wO8C81SjLlOFVWhGcaWbUSoEsAINgnHC0qqGGpafaGdCzD8K0epnAc5YYe6TW(bJxWcm0RfbFnBs5UIUzW2tYH3QvILqc8cBJJVMnPCrQPkiqad9ArWxZMuUGOBgS9KClSfgBluEo(A2KsW40Xe10PKt)84rqS(lszjGlRJNKMil8O31vSjyNugM(LKc16oauGpafaGdCzD8K0epnAc5YYe6TlLD6v0nd2EsUf2cJTfkphFnBs5U7eei4dqba4axwhpjnXtJMqUSmHE7sTthtutNso9ZJhbX6ViLLaUSoEsAISWJExxXMGDszy6xskuR7aqr0nd2EsUf2cJTfkphFnBs5c63l8bOaaCGlRJNKM4PrtixwMqVDPwvQsPa]] )

end
