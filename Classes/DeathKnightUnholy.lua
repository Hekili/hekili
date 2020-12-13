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


    spec:RegisterPack( "Unholy", 20201213, [[d8e84bqifjpsQu1LOcK2er6tQknkKQofsLvrfi6vQkmlfr7cv)svOHrfQJPkAzirEgvqttvcxtvW2uLO(MQePXPkrCoPsLwNIuMNur3Ji2NuHdQQOSqvj9qPszIQkIlkvQOnQQir(ivGYivvKOoPQIkRuvQxQQOkntfP6MQksYoLk5NQksQHQQiHLQQi1tPktvr4QQkQQTQQOk(QuPcJfjQ9QWFj1GHCyklMQ6XKmzuUmyZq1NPsJwQ60kTAQaHxJeMnHBtu7w0VLmCf1XPcy5iEUuMUW1HY2rsFNkA8uHCEvvRNkq18rk7xLhphtm8ywaJUOKJPKJFsPNoK)0XVO76yho8I)zy4nBkkmxy4LMmm8(8Z(s8p8MTFrzSXedVwHruWWRpI520E8r3n6X85Qs(X2kJjSyRurm84X2kREC45JTI4ZLd)HhZcy0fLCmLC8tk90H8No(fDxhtPHxBguJUO0duA41VmgKd)HhdAQHx3FOpbSO)qFEZ1Tpo0NF2xI)7D3FOpbuGSpqo0tho5HOKJPKJV337U)qFgZbbwlKHmAhkQd9j5N84Na4RaE8tal6Bh6tWGdf1HQu8FivHLXHcJ4cr7qo7Rdze4qGJMbvaSdf1Helv4qIkDpeKfMB)HI6qYwea5q0BfOBqGnFOU)jD8HNyBrBmXWtvuH0YOnMy01ZXedpinFbWgVo8uKnaYAdpQgznFbWBHEwyzUP7HKEicwUk9C5eiCgGVQnouhh65lp8mvSvo8AonI8MUA5TfJy0fLgtm8G08faB86Wtr2aiRn8uvjyLZKBZLYe)ZnGtazBZ2HKEi6pKPILkOHeKxODOoKCikDiPhYuXsf0qcYl0ouNso0dhs6Hiy5Q0ZLtGWza(Q24qDCONo(qFCi6pKPILkOHeKxODihKh6LpeDhIgTdzQyPcAib5fAhQJd9WHKEicwUk9C5eiCgGVQnouhh6fo(q0n8mvSvo8AonI8MUA5TfJy0Ldhtm8G08faB86Wtr2aiRn8OAK18faVf6zHL5MUhs6HM6qTct4VjJlaJP9)1GJm5zbCiPhsvLGvotUnxkt8p3aobKTnBhs6HiyjWJvg0rPFXH64q0FihEOpoKpgooNGLRsRkcbBo2k5eq22SDi6gEMk2khEMFjVPfBLAXk7pIrxVymXWdsZxaSXRdpfzdGS2WJQrwZxa8wONfwMB6EiPhQvyc)nzCbymT)VgCKjplGdj9q0Fivvcw5m5yzFj(1(I1Tp4eq22SDiA0o0uhkmbKbhl7lXV2xSU9bhsZxaSdj9qQQeSYzYzgHcDqSSHxezl2k5eq22SDi6gEMk2khEMFjVPfBLAXk7pIrxpmMy4bP5la241HNISbqwB4zQyPcAib5fAhQdjhIshs6HiyjWJvg0rPFXH64q0FihEOpoKpgooNGLRsRkcbBo2k5eq22SDi6gEMk2khEMFjVPfBLAXk7pIrxV8yIHhKMVayJxhEkYgazTHhvJSMVa4TqplSm309qspKQkbRCMCBUuM4FUbCciBB2gEMk2khETEtrHa0rpOXsNfj6)hXORx6yIHhKMVayJxhEkYgazTHNPILkOHeKxODOoKCikDiPhI(dXal61wY0mqz)8yvuSP7HOr7qeBzAGkKb3ySgNaY2MTd1PKd98fhIUHNPITYHxR3uuiaD0dAS0zrI()rmIHNvGUbb28yIrxphtm8G08faB86Wtr2aiRn8yGf9AkY1Tp44olSKbmDyexiAhQdjhs9ReGgsqEH2HOr7qeBzAGkKb3ySghC02I2HKEiITmnqfYGBmwJtazBZ2H6uYHE(C4zQyRC4z5VMLSrm6IsJjgEqA(cGnED4PiBaK1gEmWIEnf562hCCNfwYaMomIleTd1HKd9WWZuXw5WZYFnlzJy0Ldhtm8G08faB86Wtr2aiRn88XWX5mJqHoiw2WlISfBLCS5dj9qeSeWlIlWzGXel0cTQwbhsZxaSdj9qMkwQGgsqEH2H6uYHC4WZuXw5WJbw0Rv1kgXORxmMy4bP5la241HNISbqwB4n1HOAK18faFUkXMUA8IODnIB9lGHNPITYHhmVmqEvJy01dJjgEqA(cGnED4zQyRC4HdTaiB6QBbzPagEkYgazTHhd8XWX54qlaYMUANfwY4TWuuCOoLCihEiPhsvLGvotUnxkt8p3aobKTnBhQZd5WHN6xjaDyexiAJUEoIrxV8yIHhKMVayJxhEMk2khE4qlaYMU6wqwkGHNISbqwB4XaFmCCoo0cGSPR2zHLmElmffhQZd9C4P(vcqhgXfI2ORNJy01lDmXWdsZxaSXRdptfBLdpCOfaztxDlilfWWtr2aiRn8iyjWJvg0rPFXH68q0Fivvcw5m5mWIETLmndu2pNaY2MTdj9qtDOWeqgCgGVcGdP5la2HOr7qQQeSYzYza(kaobKTnBhs6HctazWza(kaoKMVayhIUHN6xjaDyexiAJUEoIrm8yaUHjIXeJUEoMy4zQyRC4jVjtJtaWbhgEqA(cGnEDeJUO0yIHhKMVayJxhE18WRbXWZuXw5WJQrwZxadpQMadgEQQeSYzYByYYvQDnIB9laobKTnBhQZd9WHKEOWeqg8gMSCLAxJ4w)cGdP5la2WJQr0PjddV5QeB6QXlI21iU1VagXOlhoMy4bP5la241Hxnp8Aqm8mvSvo8OAK18fWWJQjWGHNPILkOHeKxODijh65HKEi6p0uhIyltduHm4gJ14GJ2w0oenAhIyltduHm4gJ14BEOoo0ZhoeDdpQgrNMmm8AHEwyzUP7igD9IXedpinFbWgVo8uKnaYAdpcwUk9C5eiCgGVQnouhh6LF4qspe9hAgcURrCRFbWnvSuHdrJ2HM6qHjGm4nmz5k1UgXT(fahsZxaSdr3HKEicwcCgGVQnouhso0ddptfBLdpJOSe0rriqgJy01dJjgEqA(cGnED4PiBaK1gEZqWDnIB9laUPILkCiA0oKpgoohl7lXV2AndteCS5drJ2HctazWnI8VUW1rpOzMCcmoKMVayhs6HMHGBZLs72xycUPILkCiPhI(dndb3iY)A3(ctWnvSuHdrJ2HuvjyLZKBe5FDHRJEqZaJXjGSTz7qDCivvcw5m5(IQyACmYpNHrSyR8qpEihEi6oenAhcFD7dnbKTnBhQtjhYhdhN7lQIPXXi)CggXITYHNPITYHNVOkMghJ8pIrxV8yIHhKMVayJxhEkYgazTH3meCxJ4w)cGBQyPchIgTd5JHJZXY(s8RTwZWebhB(q0ODOWeqgCJi)RlCD0dAMjNaJdP5la2HKEOzi42CP0U9fMGBQyPchs6HO)qZqWnI8V2TVWeCtflv4q0ODivvcw5m5gr(xx46Oh0mWyCciBB2ouhhsvLGvotUpqAaHInD5mmIfBLh6Xd5Wdr3HOr7q4RBFOjGSTz7qDk5q(y44CFG0acfB6Yzyel2khEMk2khE(aPbek20DeJUEPJjgEqA(cGnED4PiBaK1gE(y44CSSVe)6wqG0n65yZdptfBLdpX62hnTdcmMRmKXigD9sgtm8G08faB86Wtr2aiRn8MHG7Ae36xaCtflv4q0ODiFmCCow2xIFT1AgMi4yZhIgTdfMaYGBe5FDHRJEqZm5eyCinFbWoK0dndb3MlL2TVWeCtflv4qspe9hAgcUrK)1U9fMGBQyPchIgTdPQsWkNj3iY)6cxh9GMbgJtazBZ2H64qQQeSYzYTubTGycTYecodJyXw5HE8qo8q0DiA0oe(62hAciBB2ouNso0ZhgEMk2khEwQGwqmHwzcXigD1Dhtm8G08faB86Wtr2aiRn8mvSubnKG8cTd1HKdrPdrJ2HO)qeSe4maFvBCOoKCOhoK0drWYvPNlNaHZa8vTXH6qYHEzhFi6gEMk2khEgrzjONXenyeJUE64XedpinFbWgVo8uKnaYAdVzi4UgXT(fa3uXsfoenAhYhdhNJL9L4xBTMHjco28HOr7qHjGm4gr(xx46Oh0mtobghsZxaSdj9qZqWT5sPD7lmb3uXsfoK0dr)HMHGBe5FTBFHj4MkwQWHOr7qQQeSYzYnI8VUW1rpOzGX4eq22SDOooKQkbRCMC8La(IQyCggXITYd94HC4HO7q0ODi81Tp0eq22SDOoLCiFmCCo(saFrvmodJyXw5WZuXw5WdFjGVOk2igD985yIHhKMVayJxhEkYgazTHNpgoohl7lXVUfeiDJEo28HKEitflvqdjiVq7qso0ZHNPITYHNV5QlCDqwffTrm66jLgtm8G08faB86Wtr2aiRn8yvWPUembKHEwyUyaNa4eO1B(c4qsp0uhkmbKbhl7lXV2xSU9bhsZxaSdj9qtDiITmnqfYGBmwJdoABrB4zQyRC4vyHpbmkgXORNoCmXWdsZxaSXRdpfzdGS2WJvbN6sWeqg6zH5IbCcGtGwV5lGdj9qMkwQGgsqEH2H6qYHO0HKEi6p0uhkmbKbhl7lXV2xSU9bhsZxaSdrJ2HctazWXY(s8R9fRBFWH08fa7qspKQkbRCMCSSVe)AFX62hCciBB2oeDdptfBLdVcl8jGrXigD98fJjgEqA(cGnED4PiBaK1gEeSeWlIlWByZaPfeBtoKMVayhs6HO)qSk44KQfACGkq4eaNaTEZxahIgTdXQG7lQIPNfMlgWjaobA9MVaoeDdptfBLdVcl8jGrXigD98HXedpinFbWgVo8mvSvo8uMqOnvSvQfBlgEITf60KHHNQOcPLrBeJUE(YJjgEqA(cGnED4zQyRC4PmHqBQyRul2wm8eBl0Pjddpvvcw5mBJy01Zx6yIHhKMVayJxhEkYgazTHNPILkOHeKxODOoKCikDiPhI(dPQsWkNjNbw0RTKPzGY(5eq22SDOop0thFiPhAQdfMaYGZa8vaCinFbWoenAhsvLGvotodWxbWjGSTz7qDEONo(qspuycidodWxbWH08fa7q0DiPhAQdXal61wY0mqz)8yvuSP7WZuXw5WJGLAtfBLAX2IHNyBHonzy4zfOBqGnpIrxpFjJjgEqA(cGnED4PiBaK1gEMkwQGgsqEH2H6qYHO0HKEigyrV2sMMbk7NhRIInDhEMk2khEeSuBQyRul2wm8eBl0PjddpRaTpgPfJy01ZU7yIHhKMVayJxhEkYgazTHNPILkOHeKxODOoKCikDiPhI(dn1HyGf9AlzAgOSFESkk209qspe9hsvLGvotodSOxBjtZaL9ZjGSTz7qDCONo(qsp0uhkmbKbNb4Ra4qA(cGDiA0oKQkbRCMCgGVcGtazBZ2H64qpD8HKEOWeqgCgGVcGdP5la2HO7q0n8mvSvo8iyP2uXwPwSTy4j2wOttggEUqcKvPTcgXOlk54XedpinFbWgVo8uKnaYAdptflvqdjiVq7qso0ZHNPITYHNYecTPITsTyBXWtSTqNMmm8CHeiRAeJy4ntavj7BXyIrxphtm8mvSvo8MRyRC4bP5la241rm6IsJjgEqA(cGnED4LMmm8mh8wVrSMgVYqx465YjqgEMk2khEMdER3iwtJxzOlC9C5eiJy0Ldhtm8mvSvo8i22andm2WdsZxaSXRJyedpvvcw5mBJjgD9CmXWdsZxaSXRdpfzdGS2WBgcURrCRFbWnvSuHdrJ2H8XWX5yzFj(1wRzyIGJnFiA0ouycidUrK)1fUo6bnZKtGXH08fa7qspe9hAgcUrK)1U9fMGBQyPchIgTdndb3MlL2TVWeCtflv4q0ODivvcw5m5gr(xx46Oh0mWyCciBB2ouhhcFD7dnbKTnBhIUHNPITYH3CfBLJy0fLgtm8G08faB86WZuXw5WBZMIGfMVa0oaMLbMSMbuxfm8uKnaYAdp6pKQkbRCMCSSVe)AFX62hCciBB2oenAhsvLGvotoZiuOdILn8IiBXwjNaY2MTdr3HKEi6p0meCJi)RD7lmb3uXsfoenAhAgcUnxkTBFHj4MkwQWHKEOPouycidUrK)1fUo6bnZKtGXH08fa7q0ODOWiUqWJvg0rPNvHMso(qDEOhoeDdV0KHH3MnfblmFbODamldmzndOUkyeJUC4yIHhKMVayJxhEMk2khEYMY8jGU1dqOLXARA4PiBaK1gEQQeSYzYT5szI)5gWjGSTz7qDEOhoK0dr)HM6qGdGTZZaJVztrWcZxaAhaZYatwZaQRcoenAhsvLGvot(MnfblmFbODamldmzndOUkGtazBZ2HOB4LMmm8KnL5taDRhGqlJ1w1igD9IXedpinFbWgVo8mvSvo8yeWy4lb0uHwdedpfzdGS2WtvLGvotUnxkt8p3aobKTnBhs6HiyjWJvg0rPFXH68qUk2HKEi6p0uhcCaSDEgy8nBkcwy(cq7aywgyYAgqDvWHOr7qQQeSYzY3SPiyH5laTdGzzGjRza1vbCciBB2oeDdV0KHHhJagdFjGMk0AGyeJUEymXWdsZxaSXRdptfBLdpMrOqUQuZaffAQfXuB8p8uKnaYAdpvvcw5m52CPmX)Cd4eq22SDiPhI(dn1HahaBNNbgFZMIGfMVa0oaMLbMSMbuxfCiA0oKQkbRCM8nBkcwy(cq7aywgyYAgqDvaNaY2MTdr3Wlnzy4XmcfYvLAgOOqtTiMAJ)rm66Lhtm8G08faB86Wtr2aiRn8uvjyLZKBZLYe)ZnGtazBZ2HKEi6p0uhcCaSDEgy8nBkcwy(cq7aywgyYAgqDvWHOr7qQQeSYzY3SPiyH5laTdGzzGjRza1vbCciBB2oeDdptfBLdpSgO3aKBJy01lDmXWdsZxaSXRdpfzdGS2WtvLGvotow2xIFTVyD7dobKTnBhQZd5Wdj9qQQeSYzYzgHcDqSSHxezl2k5eq22SDOopKdpK0dfMaYGJL9L4x7lw3(GdP5la2HOr7qtDOWeqgCSSVe)AFX62hCinFbWgEMk2khEgr(xx46Oh0mWyJy01lzmXWdsZxaSXRdpfzdGS2WJQrwZxa8wONfwMB6EiPhI(dPQsWkNj3iY)6cxh9GMbgJtazBZ2H64qpCi6oK0dr)HuvjyLZKZmcf6GyzdViYwSvYjGSTz7qDEixf7q0ODiFmCCoZiuOdILn8IiBXwjhB(q0DiPhI(dn1HiyjGxexGZaJjwOfAvTcoKMVayhIgTdn1HctazWnI8VUW1rpOzMCcmoKMVayhIgTdPQKHTbxvj1szXwPUW1rpOzGX4elP4qDEOhoeDdptfBLdpSSVe)AFX62hJy0v3DmXWdsZxaSXRdpfzdGS2WJQrwZxa8wONfwMB6EiPhI(dPQsWkNj3iY)6cxh9GMbgJtazBZ2H64qpCiA0oedSOxtrUU9bNTnZxaARc2HO7qspeblb8I4cCgymXcTqRQvWH08fa7qspuycidUrK)1fUo6bnZKtGXH08fa7qspKQsg2gCvLulLfBL6cxh9GMbgJtSKId1HKd9WHKEivvcw5m52CPmX)Cd4eq22SDOopKdpK0dr)HuvjyLZKZmcf6GyzdViYwSvYjGSTz7qDEixf7q0ODiFmCCoZiuOdILn8IiBXwjhB(q0n8mvSvo8WY(s8R9fRBFmIrxpD8yIHhKMVayJxhEkYgazTHNPILkOHeKxODOoKCikn8mvSvo8WY(s8R9fRBFmIrxpFoMy4bP5la241HNISbqwB4r1iR5laEl0ZclZnDpK0dr)HyvWXY(s8R9fRBFOzvWjGSTz7q0ODOPouycidow2xIFTVyD7doKMVayhIUHNPITYHhZiuOdILn8IiBXw5igD9KsJjgEqA(cGnED4PiBaK1gEMkwQGgsqEH2H6qYHO0WZuXw5WJzek0bXYgErKTyRCeJUE6WXedpinFbWgVo8uKnaYAdptflvqdjiVq7qso0Zdj9qmWhdhNJdTaiB6QDwyjJ3ctrXH6qYHEXHKEOWeqgCSSVe)AFX62hCinFbWoK0dfMaYGBe5FDHRJEqZm5eyCinFbWoK0drWsaViUaNbgtSql0QAfCinFbWoK0dPQKHTbxvj1szXwPUW1rpOzGX4elP4qDi5qpCiPhIvbhl7lXV2xSU9HMvbNaY2MTHNPITYHNnxkt8p3Grm665lgtm8G08faB86Wtr2aiRn8mvSubnKG8cTdj5qppK0dXaFmCCoo0cGSPR2zHLmElmffhQdjh6fhs6HctazWXY(s8R9fRBFWH08fa7qspeRcow2xIFTVyD7dnRcobKTnBhQJd90Xhs6HM6qHjGm4gr(xx46Oh0mtobghsZxaSdj9qQkzyBWvvsTuwSvQlCD0dAgymoXskouNh6HHNPITYHNnxkt8p3Grm665dJjgEqA(cGnED4PiBaK1gEMkwQGgsqEH2HKCONhs6HyGpgoohhAbq20v7SWsgVfMIId1HKd9Idj9q0FOPouycidow2xIFTVyD7doKMVayhIgTdfMaYGBe5FDHRJEqZm5eyCinFbWoK0dr)HM6qeSeWlIlWzGXel0cTQwbhsZxaSdrJ2HuvYW2GRQKAPSyRux46Oh0mWyCILuCOop0dhIUdrJ2HM6qHjGm4gr(xx46Oh0mtobghsZxaSdj9qQkzyBWvvsTuwSvQlCD0dAgymoXskouhso0dhIUHNPITYHNnxkt8p3Grm665lpMy4bP5la241HNPITYHNnxkt8p3GHNISbqwB4zQyPcAib5fAhQdjhIshs6HyGpgoohhAbq20v7SWsgVfMIId1HKd9Idj9qtDigyrV2sMMbk7NhRIInDhEQFLa0HrCHOn665igD98LoMy4bP5la241HNISbqwB4rWYvPNlNaHZa8vTXH68qpFXHKEi6pKQkbRCMCSSVe)AFX62hCciBB2ouNh6PJpenAhIvbhl7lXV2xSU9HMvbNaY2MTdr3WZuXw5WRHjlxP21iU1VagXORNVKXedpinFbWgVo8uKnaYAdpQgznFbWBHEwyzUP7HKEig4JHJZXHwaKnD1olSKXBHPO4qDEikDiPhI(dndb3MlL2TVWeCtflv4q0ODivLmSn4QkPwkl2k1fUo6bndmghsZxaSdj9q(y44CMrOqhelB4fr2ITso28HKEOPo0meCJi)RD7lmb3uXsfoeDdptfBLdpSSVe)AR1mmrmIrxp7UJjgEqA(cGnED4zQyRC4HL9L4xBTMHjIHNISbqwB4zQyPcAib5fAhQdjhIshs6HyGpgoohhAbq20v7SWsgVfMIId15HO0Wt9ReGomIleTrxphXOlk54XedpinFbWgVo8mvSvo8AfMqtaBgidpfzdGS2WlmIle8yLbDu6zvOD4dhQZd9WHKEOWiUqWJvg0rPzlCOoo0ddp1Vsa6WiUq0gD9CeJUO0ZXedpinFbWgVo8uKnaYAdVPo0meC3(ctWnvSuHHNPITYHhX2gOzGXgXOlkrPXedpinFbWgVo8uKnaYAdptflvqdjiVq7qDi5qu6qsp0uhYhdhNZmcf6GyzdViYwSvYXMpK0dn1HuvjyLZKZmcf6GyzdViYwSvYjGX(hEMk2khEntrw8vTMqpBQyeJy45cjqwL2kymXORNJjgEqA(cGnED4PiBaK1gE(y44CMrOqhelB4fr2ITso28HKEicwc4fXf4mWyIfAHwvRGdP5la2HKEitflvqdjiVq7qDk5qoC4zQyRC4Xal61QAfJy0fLgtm8G08faB86Wtr2aiRn88XWX5nmgdsnRkzobmvm8mvSvo8G5LbYRAeJUC4yIHhKMVayJxhEkYgazTH3uhIQrwZxa85QeB6QXlI21iU1VagEMk2khEW8Ya5vnIrxVymXWdsZxaSXRdptfBLdpNfwY0Tzizaz4PiBaK1gE0Fivvcw5m52CPmX)Cd4eq22SDOoo0dhs6HyGpgoohhAbq20v7SWsghB(q0ODig4JHJZXHwaKnD1olSKXBHPO4qDCOxCi6oK0dr)HWx3(qtazBZ2H68qQQeSYzYzGf9AlzAgOSFobKTnBh6Jd90XhIgTdHVU9HMaY2MTd1XHuvjyLZKBZLYe)ZnGtazBZ2HOB4P(vcqhgXfI2ORNJy01dJjgEqA(cGnED4zQyRC4HdTaiB6QBbzPagEkYgazTHhd8XWX54qlaYMUANfwY4TWuuCOoLCihEiPhsvLGvotUnxkt8p3aobKTnBhQZd5WdrJ2HyGpgoohhAbq20v7SWsgVfMIId15HEo8u)kbOdJ4crB01Zrm66Lhtm8G08faB86WZuXw5WdhAbq20v3cYsbm8uKnaYAdpvvcw5m52CPmX)Cd4eq22SDOoo0dhs6HyGpgoohhAbq20v7SWsgVfMIId15HEo8u)kbOdJ4crB01ZrmIHNvG2hJ0IXeJUEoMy4bP5la241HNISbqwB45JHJZzgHcDqSSHxezl2k5yZhs6HiyjGxexGZaJjwOfAvTcoKMVayhs6HmvSubnKG8cTd1PKd5WHNPITYHhdSOxRQvmIrxuAmXWdsZxaSXRdpfzdGS2WJGLRspxobcNb4RAJd15HO)qpD8H(4qmWIEnf562hCCNfwYaMomIleTd5G8qo8q0DiPhIbw0RPix3(GJ7SWsgW0HrCHODOop0lFiPhAQdr1iR5la(CvInD14fr7Ae36xahIgTd5JHJZBonI8MUA5TfCS5HNPITYHhmVmqEvJy0Ldhtm8G08faB86Wtr2aiRn8iy5Q0ZLtGWza(Q24qDEik9WHKEigyrVMICD7doUZclzathgXfI2H64qpCiPhAQdr1iR5la(CvInD14fr7Ae36xadptfBLdpyEzG8QgXORxmMy4bP5la241HNISbqwB4n1HyGf9AkY1Tp44olSKbmDyexiAhs6HM6qunYA(cGpxLytxnEr0UgXT(fWHOr7q4RBFOjGSTz7qDEOhoenAhIyltduHm4gJ14GJ2w0oK0drSLPbQqgCJXACciBB2ouNh6HHNPITYHhmVmqEvJy01dJjgEMk2khEolSKPBZqYaYWdsZxaSXRJy01lpMy4bP5la241HNISbqwB4n1HOAK18faFUkXMUA8IODnIB9lGHNPITYHhmVmqEvJyedpxibYQgtm665yIHhKMVayJxhEkYgazTHNpgooVHXyqQzvjZjGPIdj9qtDiQgznFbWNRsSPRgViAxJ4w)c4q0ODOzi4UgXT(fa3uXsfgEMk2khEmWIETQwXigDrPXedpinFbWgVo8uKnaYAdpcwUk9C5eiCgGVQnouNh6PdpK0dn1HOAK18faFUkXMUA8IODnIB9lGHNPITYHhdSOxRQvmIrxoCmXWdsZxaSXRdpfzdGS2WtvLGvotUnxkt8p3aobKTnBhs6HO)qHjGm4maFfahsZxaSdrJ2HufviTm4562hACdoenAhIGLaErCb(CpyKsUsOXH08fa7q0n8mvSvo8S8xZs2igD9IXedpinFbWgVo8uKnaYAdpg4JHJZXHwaKnD1olSKXBHPO4qDCOxm8mvSvo8Cwyjt3MHKbKrm66HXedpinFbWgVo8uKnaYAdpg4JHJZXHwaKnD1olSKXXMpK0dPQsWkNj3MlLj(NBaNaY2MTd1XHE4qspe9hAQdfMaYGJL9L4x7lw3(GdP5la2HOr7qHjGm4gr(xx46Oh0mtobghsZxaSdj9qQkzyBWvvsTuwSvQlCD0dAgymoXskouNh6HdrJ2HM6qHjGm4gr(xx46Oh0mtobghsZxaSdj9qQkzyBWvvsTuwSvQlCD0dAgymoXskouhso0dhIgTdn1HuvYW2GRQKAPSyRux46Oh0mWyCinFbWoeDdptfBLdpNfwY0TzizazeJUE5XedpinFbWgVo8uKnaYAdpg4JHJZXHwaKnD1olSKXXMpK0dfMaYGJL9L4x7lw3(GdP5la2HKEi6p0uhkmbKb3iY)6cxh9GMzYjW4qA(cGDiPhsvjdBdUQsQLYITsDHRJEqZaJXjwsXH68qpCiA0ouycidUrK)1fUo6bnZKtGXH08fa7qspKQsg2gCvLulLfBL6cxh9GMbgJtSKId1HKd9WHO7qspe9hsvLGvotow2xIFTVyD7dobKTnBhQJd90Xhs6HM6qSk4yzFj(1(I1Tp0Sk4eq22SDiA0oKQkbRCMCBUuM4FUbCciBB2ouhh6PJpeDdptfBLdpNfwY0TzizazeJUEPJjgEqA(cGnED4PiBaK1gEeSCv65Yjq4maFvBCOopeLC8HKEOPoevJSMVa4Zvj20vJxeTRrCRFbm8mvSvo8yGf9AvTIrm66LmMy4bP5la241HNISbqwB4XaFmCCoo0cGSPR2zHLmElmffhQZd9C4zQyRC4HdTaiB6QBbzPagXORU7yIHhKMVayJxhEkYgazTHhd8XWX54qlaYMUANfwY4TWuuCOop0loK0dPQsWkNj3MlLj(NBaNaY2MTd15HE4qspe9hAQdfMaYGJL9L4x7lw3(GdP5la2HOr7qHjGm4gr(xx46Oh0mtobghsZxaSdj9qQkzyBWvvsTuwSvQlCD0dAgymoXskouNh6HdrJ2HM6qHjGm4gr(xx46Oh0mtobghsZxaSdj9qQkzyBWvvsTuwSvQlCD0dAgymoXskouhso0dhIgTdn1HuvYW2GRQKAPSyRux46Oh0mWyCinFbWoeDdptfBLdpCOfaztxDlilfWigD90XJjgEqA(cGnED4PiBaK1gEmWhdhNJdTaiB6QDwyjJ3ctrXH68qV4qspuycidow2xIFTVyD7doKMVayhs6HO)qtDOWeqgCJi)RlCD0dAMjNaJdP5la2HKEivLmSn4QkPwkl2k1fUo6bndmgNyjfhQZd9WHOr7qHjGm4gr(xx46Oh0mtobghsZxaSdj9qQkzyBWvvsTuwSvQlCD0dAgymoXskouhso0dhIUdj9q0Fivvcw5m5yzFj(1(I1Tp4eq22SDOop0thFiA0oKQkbRCMCBUuM4FUbCciBB2ouNh6PJpK0dXQGJL9L4x7lw3(qZQGtazBZ2HOB4zQyRC4HdTaiB6QBbzPagXORNphtm8G08faB86Wtr2aiRn8M6qunYA(cGpxLytxnEr0UgXT(fWWZuXw5WJbw0Rv1kgXigXWJkqABLJUOKJPKJFsjh3DhEonsUPBB41D8zF6U(CD5GnTdDOj6HdTYZfjoeEro0xxibYQ(Eic4aylbyhQvYWHmSOKTayhs1BPl0437PVjCihoTd1TkPcKayh6lblb8I4cCk)9qrDOVeSeWlIlWPmhsZxaSVhI(NoIo(9E6Bch6HPDOUvjvGea7qFdtazWP83df1H(gMaYGtzoKMVayFpe9o0r0XV3tFt4qpmTd1TkPcKayh6RQsg2gCk)9qrDOVQkzyBWPmhsZxaSVhI(NoIo(9E6Bch6LN2H6wLubsaSd9nmbKbNYFpuuh6BycidoL5qA(cG99q07qhrh)Ep9nHd1DN2H6wLubsaSd9nmbKbNYFpuuh6BycidoL5qA(cG99q07qhrh)Ep9nHd1DN2H6wLubsaSd9vvjdBdoL)EOOo0xvLmSn4uMdP5la23dr)thrh)Ep9nHd90Xt7qDRsQaja2H(gMaYGt5VhkQd9nmbKbNYCinFbW(Ei6DOJOJFVV3DhF2NURpxxoyt7qhAIE4qR8CrIdHxKd91kq3GaB(7HiGdGTeGDOwjdhYWIs2cGDivVLUqJFVN(MWHC40ou3QKkqcGDOVeSeWlIlWP83df1H(sWsaViUaNYCinFbW(Ei6F6i6437PVjCOx60ou3QKkqcGDOVHjGm4u(7HI6qFdtazWPmhsZxaSVhIEk5i64377D3XN9P76Z1Ld20o0HMOho0kpxK4q4f5qFzaUHjIVhIaoa2sa2HALmCidlkzla2Hu9w6cn(9E6BchIst7qDRsQaja2H(gMaYGt5VhkQd9nmbKbNYCinFbW(Eilou35N6PFi6F6i6437PVjCOhM2H6wLubsaSd5TYD7qT)mmhDih0df1HMoMDi2sDBBLhQMbIff5q0)iDhI(NoIo(9E6Bch6HPDOUvjvGea7qFdtazWP83df1H(gMaYGtzoKMVayFpe9pDeD87903eo0lpTd1TkPcKayhYBL72HA)zyo6qoOhkQdnDm7qSL622kpundelkYHO)r6oe9pDeD87903eo0lpTd1TkPcKayh6BycidoL)EOOo03WeqgCkZH08fa77HO)PJOJFVN(MWHEjt7qDRsQaja2H8w5UDO2FgMJoKd6HI6qthZoeBPUTTYdvZaXIICi6FKUdr)thrh)Ep9nHd9sM2H6wLubsaSd9nmbKbNYFpuuh6BycidoL5qA(cG99q0)0r0XV3tFt4qpD80ou3QKkqcGDiVvUBhQ9NH5Od5GEOOo00XSdXwQBBR8q1mqSOihI(hP7q0)0r0XV3tFt4qpD80ou3QKkqcGDOVHjGm4u(7HI6qFdtazWPmhsZxaSVhI(NoIo(9E6Bch6jLM2H6wLubsaSd9nmbKbNYFpuuh6BycidoL5qA(cG99q0)0r0XV3tFt4qpD40ou3QKkqcGDOVHjGm4u(7HI6qFdtazWPmhsZxaSVhIEk5i6437PVjCONVyAhQBvsfibWo0xcwc4fXf4u(7HI6qFjyjGxexGtzoKMVayFpe9pDeD87903eo0Zx60ou3QKkqcGDOVHjGm4u(7HI6qFdtazWPmhsZxaSVhIEk5i6437PVjCOND3PDOUvjvGea7qFdtazWP83df1H(gMaYGtzoKMVayFpe9uYr0XV337UJp7t31NRlhSPDOdnrpCOvEUiXHWlYH(QQsWkNz77HiGdGTeGDOwjdhYWIs2cGDivVLUqJFVN(MWHEoTd1TkPcKayh6BycidoL)EOOo03WeqgCkZH08fa77HO)PJOJFVN(MWHO00ou3QKkqcGDOVHjGm4u(7HI6qFdtazWPmhsZxaSVhI(NoIo(9E6Bch6LoTd1TkPcKayh6BycidoL)EOOo03WeqgCkZH08fa77HO)PJOJFVN(MWHEPt7qDRsQaja2H(gMaYGt5VhkQd9nmbKbNYCinFbW(Eilou35N6PFi6F6i6437PVjCOxY0ou3QKkqcGDOVHjGm4u(7HI6qFdtazWPmhsZxaSVhI(NoIo(9E6Bch6LmTd1TkPcKayh6lblb8I4cCk)9qrDOVeSeWlIlWPmhsZxaSVhI(NoIo(9E6BchQ7oTd1TkPcKayh6BycidoL)EOOo03WeqgCkZH08fa77HO)PJOJFVN(MWH6Ut7qDRsQaja2H(sWsaViUaNYFpuuh6lblb8I4cCkZH08fa77HO)PJOJFVN(MWHE(CAhQBvsfibWo03WeqgCk)9qrDOVHjGm4uMdP5la23dr)thrh)Ep9nHd90Ht7qDRsQaja2H(gMaYGt5VhkQd9nmbKbNYCinFbW(Ei6PKJOJFVN(MWHE6WPDOUvjvGea7qFjyjGxexGt5VhkQd9LGLaErCboL5qA(cG99q0)0r0XV3tFt4qpFX0ou3QKkqcGDOVHjGm4u(7HI6qFdtazWPmhsZxaSVhIEk5i6437PVjCONpmTd1TkPcKayh6BycidoL)EOOo03WeqgCkZH08fa77HO3HoIo(9E6Bch65dt7qDRsQaja2H(sWsaViUaNYFpuuh6lblb8I4cCkZH08fa77HO)PJOJFVN(MWHE(sM2H6wLubsaSd9vvjdBdoL)EOOo0xvLmSn4uMdP5la23dr)thrh)EFV7o(SpDxFUUCWM2Ho0e9WHw55IehcVih6RlKazvARGVhIaoa2sa2HALmCidlkzla2Hu9w6cn(9E6Bch650ou3QKkqcGDOVeSeWlIlWP83df1H(sWsaViUaNYCinFbW(Ei6F6i64377D3XN9P76Z1Ld20o0HMOho0kpxK4q4f5qFTc0(yKw89qeWbWwcWouRKHdzyrjBbWoKQ3sxOXV3tFt4qpN2H6wLubsaSd9LGLaErCboL)EOOo0xcwc4fXf4uMdP5la23dr)thrh)EFV7o(SpDxFUUCWM2Ho0e9WHw55IehcVih6RQOcPLr77HiGdGTeGDOwjdhYWIs2cGDivVLUqJFVN(MWHEX0ou3QKkqcGDOVHjGm4u(7HI6qFdtazWPmhsZxaSVhI(NoIo(9(E)5KNlsaSd9soKPITYdj2w0437HNHf9fz45TYycl2k7gXWJH3mPWxbm86(d9jGf9h6ZBUU9XH(8Z(s8FV7(d9jGcK9bYHE6WjpeLCmLC89(E39h6ZyoiWAHmKr7qrDOpj)Kh)eaFfWJFcyrF7qFcgCOOouLI)dPkSmouyexiAhYzFDiJahcC0mOcGDOOoKyPchsuP7HGSWC7puuhs2IaihIERaDdcS5d19pPJFVV3Mk2kB8zcOkzFl(qYJZvSvEVnvSv24ZeqvY(w8HKhXAGEdqEY0KbjMdER3iwtJxzOlC9C5ei3BtfBLn(mbuLSVfFi5rITnqZaJDVV3D)H6oDeOWcGDiGkq(puSYWHIE4qMkkYH22HmQ2kmFbWV3Mk2kBsK3KPXja4Gd37U)qFEmYA(cODVnvSv2(qYJunYA(cyY0KbjZvj20vJxeTRrCRFbmjvtGbsuvjyLZK3WKLRu7Ae36xaCciBB268bPHjGm4nmz5k1UgXT(fW92uXwz7djps1iR5lGjttgK0c9SWYCt3jPAcmqIPILkOHeKxOj5Pu6NIyltduHm4gJ14GJ2w0OrJyltduHm4gJ14B2XZhO7E39h6tBQ1eT7TPITY2hsE0iklbDuecKXKlUecwUk9C5eiCgGVQn64LFqk9ZqWDnIB9laUPILkqJ2uHjGm4nmz5k1UgXT(fahsZxam6KsWsGZa8vTrhsE4EBQyRS9HKh9fvX04yK)jxCjZqWDnIB9laUPILkqJMpgoohl7lXV2AndteCSzA0ctazWnI8VUW1rpOzMCcmPZqWT5sPD7lmb3uXsfKs)meCJi)RD7lmb3uXsfOrtvLGvotUrK)1fUo6bndmgNaY2MTouvjyLZK7lQIPXXi)CggXITshuhshnA4RBFOjGSTzRtj(y44CFrvmnog5NZWiwSvEVnvSv2(qYJ(aPbek20DYfxYmeCxJ4w)cGBQyPc0O5JHJZXY(s8RTwZWebhBMgTWeqgCJi)RlCD0dAMjNat6meCBUuA3(ctWnvSubP0pdb3iY)A3(ctWnvSubA0uvjyLZKBe5FDHRJEqZaJXjGSTzRdvvcw5m5(aPbek20LZWiwSv6G6q6OrdFD7dnbKTnBDkXhdhN7dKgqOytxodJyXw592uXwz7djpkw3(OPDqGXCLHmMCXL4JHJZXY(s8RBbbs3ONJnFV7(d9zPcAbXehQBMqCiLLhkiRRlqo0lo0CfqgRjoKpgoEBYdbMQ)qcRfB6EONpCOgOQK14h6ZpwX6GdSd1Be2Hufdyhkwz4qw7q2HcY66cKdf1HOaG5dTXHiGXmFbWV3Mk2kBFi5rlvqliMqRmHyYfxYmeCxJ4w)cGBQyPc0O5JHJZXY(s8RTwZWebhBMgTWeqgCJi)RlCD0dAMjNat6meCBUuA3(ctWnvSubP0pdb3iY)A3(ctWnvSubA0uvjyLZKBe5FDHRJEqZaJXjGSTzRdvvcw5m5wQGwqmHwzcbNHrSyR0b1H0rJg(62hAciBB26uYZhU3Mk2kBFi5rJOSe0ZyIgm5IlXuXsf0qcYl06qcLOrJEcwcCgGVQn6qYdsjy5Q0ZLtGWza(Q2OdjVSJP7EBQyRS9HKhXxc4lQIn5IlzgcURrCRFbWnvSubA08XWX5yzFj(1wRzyIGJntJwycidUrK)1fUo6bnZKtGjDgcUnxkTBFHj4MkwQGu6NHGBe5FTBFHj4MkwQanAQQeSYzYnI8VUW1rpOzGX4eq22S1HQkbRCMC8La(IQyCggXITshuhshnA4RBFOjGSTzRtj(y44C8La(IQyCggXITY7TPITY2hsE03C1fUoiRII2KlUeFmCCow2xIFDliq6g9CSzPMkwQGgsqEHMKN37U)qFQSndBZnDp0NNLGjGmo0NcH5IbhABhYo0mzlYg)3BtfBLTpK8yHf(eWOyYfxcRco1LGjGm0ZcZfd4eaNaTEZxasNkmbKbhl7lXV2xSU9H0Pi2Y0avidUXyno4OTfT7TPITY2hsESWcFcyum5IlHvbN6sWeqg6zH5IbCcGtGwV5laPMkwQGgsqEHwhsOKu6NkmbKbhl7lXV2xSU9bnAHjGm4yzFj(1(I1TpKQQsWkNjhl7lXV2xSU9bNaY2Mn6U3Mk2kBFi5Xcl8jGrXKlUecwc4fXf4nSzG0cITPu6zvWXjvl04avGWjaobA9MVaOrJvb3xuftplmxmGtaCc06nFbq39U7p0NPITYdn9TfT7TPITY2hsEuzcH2uXwPwSTyY0KbjQIkKwgT7TPITY2hsEuzcH2uXwPwSTyY0KbjQQeSYz2U3Mk2kBFi5rcwQnvSvQfBlMmnzqIvGUbb28KlUetflvqdjiVqRdjusk9QQeSYzYzGf9AlzAgOSFobKTnBD(0XsNkmbKbNb4RaOrtvLGvotodWxbWjGSTzRZNowAycidodWxbqN0PyGf9AlzAgOSFESkk209EBQyRS9HKhjyP2uXwPwSTyY0KbjwbAFmslMCXLyQyPcAib5fADiHsszGf9AlzAgOSFESkk209EBQyRS9HKhjyP2uXwPwSTyY0KbjUqcKvPTcMCXLyQyPcAib5fADiHssPFkgyrV2sMMbk7NhRIInDLsVQkbRCMCgyrV2sMMbk7NtazBZwhpDS0PctazWza(kaA0uvjyLZKZa8vaCciBB264PJLgMaYGZa8va0r392uXwz7djpQmHqBQyRul2wmzAYGexibYQMCXLyQyPcAib5fAsEEVV3D)H(SQ78qVIrAX92uXwzJBfO9XiTqcdSOxRQvm5IlXhdhNZmcf6GyzdViYwSvYXMLsWsaViUaNbgtSql0QAfsnvSubnKG8cToL4W7TPITYg3kq7JrAXhsEeMxgiVQjxCjeSCv65Yjq4maFvB0j9pD8hmWIEnf562hCCNfwYaMomIlenhKoKoPmWIEnf562hCCNfwYaMomIleToFzPtr1iR5la(CvInD14fr7Ae36xa0O5JHJZBonI8MUA5TfCS57TPITYg3kq7JrAXhsEeMxgiVQjxCjeSCv65Yjq4maFvB0jLEqkdSOxtrUU9bh3zHLmGPdJ4crRJhKofvJSMVa4Zvj20vJxeTRrCRFbCVnvSv24wbAFmsl(qYJW8Ya5vn5IlzkgyrVMICD7doUZclzathgXfIM0POAK18faFUkXMUA8IODnIB9laA0Wx3(qtazBZwNpqJgXwMgOczWngRXbhTTOjLyltduHm4gJ14eq22S15d3BtfBLnUvG2hJ0IpK8OZclz62mKmGCVnvSv24wbAFmsl(qYJW8Ya5vn5IlzkQgznFbWNRsSPRgViAxJ4w)c4EFV7(d9zv35H8GaB(EBQyRSXTc0niWMLy5VMLSjxCjmWIEnf562hCCNfwYaMomIleToKO(vcqdjiVqJgnITmnqfYGBmwJdoABrtkXwMgOczWngRXjGSTzRtjpFEVnvSv24wb6geyZFi5rl)1SKn5IlHbw0RPix3(GJ7SWsgW0HrCHO1HKhU3Mk2kBCRaDdcS5pK8idSOxRQvm5IlXhdhNZmcf6GyzdViYwSvYXMLsWsaViUaNbgtSql0QAfsnvSubnKG8cToL4W7TPITYg3kq3GaB(djpcZldKx1KlUKPOAK18faFUkXMUA8IODnIB9lG7TPITYg3kq3GaB(djpIdTaiB6QBbzPaMu9ReGomIlenjpNCXLWaFmCCoo0cGSPR2zHLmElmffDkXHsvvjyLZKBZLYe)ZnGtazBZwNo8EBQyRSXTc0niWM)qYJ4qlaYMU6wqwkGjv)kbOdJ4crtYZjxCjmWhdhNJdTaiB6QDwyjJ3ctrrNpV3Mk2kBCRaDdcS5pK8io0cGSPRUfKLcys1Vsa6WiUq0K8CYfxcblbESYGok9l6KEvvcw5m5mWIETLmndu2pNaY2MnPtfMaYGZa8va0OPQsWkNjNb4Ra4eq22SjnmbKbNb4RaO7EFV7(d9POITY2HSKDOk6bYHQ8qyn4EBQyRSXvvjyLZSjzUITYjxCjZqWDnIB9laUPILkqJMpgoohl7lXV2AndteCSzA0ctazWnI8VUW1rpOzMCcmP0pdb3iY)A3(ctWnvSubA0MHGBZLs72xycUPILkqJMQkbRCMCJi)RlCD0dAgymobKTnBDGVU9HMaY2Mn6U3Mk2kBCvvcw5mBFi5rSgO3aKNmnzqYMnfblmFbODamldmzndOUkyYfxc9QQeSYzYXY(s8R9fRBFWjGSTzJgnvvcw5m5mJqHoiw2WlISfBLCciBB2Otk9ZqWnI8V2TVWeCtflvGgTzi42CP0U9fMGBQyPcsNkmbKb3iY)6cxh9GMzYjWOrlmIle8yLbDu6zvOPKJ78b6U3Mk2kBCvvcw5mBFi5rSgO3aKNmnzqISPmFcOB9aeAzS2QMCXLOQsWkNj3MlLj(NBaNaY2MToFqk9tboa2opdm(MnfblmFbODamldmzndOUkGgnvvcw5m5B2ueSW8fG2bWSmWK1mG6QaobKTnB0DVnvSv24QQeSYz2(qYJynqVbipzAYGegbmg(sanvO1aXKlUevvcw5m52CPmX)Cd4eq22SjLGLapwzqhL(fD6QysPFkWbW25zGX3SPiyH5laTdGzzGjRza1vb0OPQsWkNjFZMIGfMVa0oaMLbMSMbuxfWjGSTzJU7TPITYgxvLGvoZ2hsEeRb6na5jttgKWmcfYvLAgOOqtTiMAJ)jxCjQQeSYzYT5szI)5gWjGSTztk9tboa2opdm(MnfblmFbODamldmzndOUkGgnvvcw5m5B2ueSW8fG2bWSmWK1mG6QaobKTnB0DVnvSv24QQeSYz2(qYJynqVbi3MCXLOQsWkNj3MlLj(NBaNaY2MnP0pf4ay78mW4B2ueSW8fG2bWSmWK1mG6QaA0uvjyLZKVztrWcZxaAhaZYatwZaQRc4eq22Sr39U7pu3QsWkNz7EBQyRSXvvjyLZS9HKhnI8VUW1rpOzGXMCXLOQsWkNjhl7lXV2xSU9bNaY2MToDOuvvcw5m5mJqHoiw2WlISfBLCciBB260HsdtazWXY(s8R9fRBFqJ2uHjGm4yzFj(1(I1TpU3D)H8(t1HEvSU9XHCUr)H(eJqXHMGyzdViYwSvEOf)qyXkwh8nDpuf9a5qFIrO4qtqSSHxezl2kpKpgoEBYdf9vdoKpSP7H(eWyIfAXH6wTIjp0NseiDWxGDOpvv2cs124)qf5qDNbqstCOpLXsxGWp0NjA1Hu9GII2Hw8dPQKTXwz7qgboKmehkQdTzlaJDO(sWoeEro0Nnxkt8p3a(92uXwzJRQsWkNz7djpIL9L4x7lw3(yYfxcvJSMVa4TqplSm30vk9QQeSYzYnI8VUW1rpOzGX4eq22S1Xd0jLEvvcw5m5mJqHoiw2WlISfBLCciBB260vXOrZhdhNZmcf6GyzdViYwSvYXMPtk9trWsaViUaNbgtSql0QAf0OnvycidUrK)1fUo6bnZKtGrJMQsg2gCvLulLfBL6cxh9GMbgJtSKIoFGU7D3FiV)uDOxfRBFCiNB0FOpBUuM4FUbhAXpu0dhsvLGvoZdv4h6ZMlLj(NBWH22HeLZdbzH52Zp0NgCaSLaTd9jGXel0Id1TAftEOUvj1szXw5Hk8df9WH(eWyhYs2H(mI8)Hk8df9WH(etob2HIYfIEGWV3Mk2kBCvvcw5mBFi5rSSVe)AFX62htU4sOAK18faVf6zHL5MUsPxvLGvotUrK)1fUo6bndmgNaY2MToEGgngyrVMICD7doBBMVa0wfm6KsWsaViUaNbgtSql0QAfsdtazWnI8VUW1rpOzMCcmPQkzyBWvvsTuwSvQlCD0dAgymoXsk6qYdsvvjyLZKBZLYe)ZnGtazBZwNouk9QQeSYzYzgHcDqSSHxezl2k5eq22S1PRIrJMpgooNzek0bXYgErKTyRKJnt392uXwzJRQsWkNz7djpIL9L4x7lw3(yYfxIPILkOHeKxO1HekDVnvSv24QQeSYz2(qYJmJqHoiw2WlISfBLtU4sOAK18faVf6zHL5MUsPNvbhl7lXV2xSU9HMvbNaY2MnA0MkmbKbhl7lXV2xSU9bD3BtfBLnUQkbRCMTpK8iZiuOdILn8IiBXw5KlUetflvqdjiVqRdju6EBQyRSXvvjyLZS9HKhT5szI)5gm5IlXuXsf0qcYl0K8ukd8XWX54qlaYMUANfwY4TWuu0HKxinmbKbhl7lXV2xSU9H0WeqgCJi)RlCD0dAMjNatkblb8I4cCgymXcTqRQvivvjdBdUQsQLYITsDHRJEqZaJXjwsrhsEqkRcow2xIFTVyD7dnRcobKTnB3BtfBLnUQkbRCMTpK8Onxkt8p3GjxCjMkwQGgsqEHMKNszGpgoohhAbq20v7SWsgVfMIIoK8cPHjGm4yzFj(1(I1TpKYQGJL9L4x7lw3(qZQGtazBZwhpDS0PctazWnI8VUW1rpOzMCcmPQkzyBWvvsTuwSvQlCD0dAgymoXsk68H7TPITYgxvLGvoZ2hsE0MlLj(NBWKlUetflvqdjiVqtYtPmWhdhNJdTaiB6QDwyjJ3ctrrhsEHu6NkmbKbhl7lXV2xSU9bnAHjGm4gr(xx46Oh0mtobMu6NIGLaErCbodmMyHwOv1kOrtvjdBdUQsQLYITsDHRJEqZaJXjwsrNpqhnAtfMaYGBe5FDHRJEqZm5eysvvYW2GRQKAPSyRux46Oh0mWyCILu0HKhO7EBQyRSXvvjyLZS9HKhT5szI)5gmP6xjaDyexiAsEo5IlXuXsf0qcYl06qcLKYaFmCCoo0cGSPR2zHLmElmffDi5fsNIbw0RTKPzGY(5XQOyt37TPITYgxvLGvoZ2hsESHjlxP21iU1VaMCXLqWYvPNlNaHZa8vTrNpFHu6vvjyLZKJL9L4x7lw3(GtazBZwNpDmnASk4yzFj(1(I1Tp0Sk4eq22Sr392uXwzJRQsWkNz7djpIL9L4xBTMHjIjxCjunYA(cG3c9SWYCtxPmWhdhNJdTaiB6QDwyjJ3ctrrNusk9ZqWT5sPD7lmb3uXsfOrtvjdBdUQsQLYITsDHRJEqZaJj1hdhNZmcf6GyzdViYwSvYXMLo1meCJi)RD7lmb3uXsfO7EBQyRSXvvjyLZS9HKhXY(s8RTwZWeXKQFLa0HrCHOj55KlUetflvqdjiVqRdjuskd8XWX54qlaYMUANfwY4TWuu0jLU3Mk2kBCvvcw5mBFi5XwHj0eWMbYKQFLa0HrCHOj55KlUKWiUqWJvg0rPNvH2Hp05dsdJ4cbpwzqhLMTqhpCVnvSv24QQeSYz2(qYJeBBGMbgBYfxYuZqWD7lmb3uXsfU3Mk2kBCvvcw5mBFi5XMPil(QwtONnvm5IlXuXsf0qcYl06qcLKoLpgooNzek0bXYgErKTyRKJnlDkvvcw5m5mJqHoiw2WlISfBLCcyS)799U7pu3kQqAzCOpZFfBSq7EBQyRSXvfviTmAsAonI8MUA5TftU4sOAK18faVf6zHL5MUsjy5Q0ZLtGWza(Q2OJNV89U7pKhehkQdH1Gdz4bqoKnxQdTTdv5H62NCiRDOOo0mbOczCOIkqu288MUh6t)P4qo7xbCOgeXMUhcB(qD7t(2U3Mk2kBCvrfslJ2hsES50iYB6QL3wm5IlrvLGvotUnxkt8p3aobKTnBsP3uXsf0qcYl06qcLKAQyPcAib5fADk5bPeSCv65Yjq4maFvB0Xth)b9MkwQGgsqEHMdYxMoA0mvSubnKG8cToEqkblxLEUCceodWx1gD8cht392uXwzJRkQqAz0(qYJMFjVPfBLAXk7p5IlHQrwZxa8wONfwMB6kDQwHj83KXfGX0()AWrM8SaKQQsWkNj3MlLj(NBaNaY2MnPeSe4Xkd6O0VOd6D4h(y44CcwUkTQieS5yRKtazBZgD3BtfBLnUQOcPLr7djpA(L8MwSvQfRS)KlUeQgznFbWBHEwyzUPR0wHj83KXfGX0()AWrM8SaKsVQkbRCMCSSVe)AFX62hCciBB2OrBQWeqgCSSVe)AFX62hsvvjyLZKZmcf6GyzdViYwSvYjGSTzJU7TPITYgxvuH0YO9HKhn)sEtl2k1Iv2FYfxIPILkOHeKxO1HekjLGLapwzqhL(fDqVd)WhdhNtWYvPvfHGnhBLCciBB2O7EBQyRSXvfviTmAFi5XwVPOqa6Oh0yPZIe9)tU4sOAK18faVf6zHL5MUsvvjyLZKBZLYe)ZnGtazBZ292uXwzJRkQqAz0(qYJTEtrHa0rpOXsNfj6)NCXLyQyPcAib5fADiHssPNbw0RTKPzGY(5XQOytxA0i2Y0avidUXynobKTnBDk55lO7EFV7(d5TPRao0egXfI7TPITYg3fsGSkjmWIETQwXKlUeFmCCEdJXGuZQsMtatfsNIQrwZxa85QeB6QXlI21iU1VaOrBgcURrCRFbWnvSuH7TPITYg3fsGSQpK8idSOxRQvm5IlHGLRspxobcNb4RAJoF6qPtr1iR5la(CvInD14fr7Ae36xa3BtfBLnUlKazvFi5rl)1SKn5IlrvLGvotUnxkt8p3aobKTnBsPpmbKbNb4Ra4qA(cGrJMQOcPLbpx3(qJBanAeSeWlIlWN7bJuYvcn6U3Mk2kBCxibYQ(qYJolSKPBZqYaYKlUeg4JHJZXHwaKnD1olSKXBHPOOJxCVnvSv24UqcKv9HKhDwyjt3MHKbKjxCjmWhdhNJdTaiB6QDwyjJJnlvvLGvotUnxkt8p3aobKTnBD8Gu6NkmbKbhl7lXV2xSU9bnAHjGm4gr(xx46Oh0mtobMuvLmSn4QkPwkl2k1fUo6bndmgNyjfD(anAtfMaYGBe5FDHRJEqZm5eysvvYW2GRQKAPSyRux46Oh0mWyCILu0HKhOrBkvLmSn4QkPwkl2k1fUo6bndmgD3BtfBLnUlKazvFi5rNfwY0TzizazYfxcd8XWX54qlaYMUANfwY4yZsdtazWXY(s8R9fRBFiL(PctazWnI8VUW1rpOzMCcmPQkzyBWvvsTuwSvQlCD0dAgymoXsk68bA0ctazWnI8VUW1rpOzMCcmPQkzyBWvvsTuwSvQlCD0dAgymoXsk6qYd0jLEvvcw5m5yzFj(1(I1Tp4eq22S1XthlDkwfCSSVe)AFX62hAwfCciBB2OrtvLGvotUnxkt8p3aobKTnBD80X0DVnvSv24UqcKv9HKhzGf9AvTIjxCjeSCv65Yjq4maFvB0jLCS0POAK18faFUkXMUA8IODnIB9lG7TPITYg3fsGSQpK8io0cGSPRUfKLcyYfxcd8XWX54qlaYMUANfwY4TWuu05Z7TPITYg3fsGSQpK8io0cGSPRUfKLcyYfxcd8XWX54qlaYMUANfwY4TWuu05lKQQsWkNj3MlLj(NBaNaY2MToFqk9tfMaYGJL9L4x7lw3(GgTWeqgCJi)RlCD0dAMjNatQQsg2gCvLulLfBL6cxh9GMbgJtSKIoFGgTPctazWnI8VUW1rpOzMCcmPQkzyBWvvsTuwSvQlCD0dAgymoXsk6qYd0OnLQsg2gCvLulLfBL6cxh9GMbgJU7TPITYg3fsGSQpK8io0cGSPRUfKLcyYfxcd8XWX54qlaYMUANfwY4TWuu05lKgMaYGJL9L4x7lw3(qk9tfMaYGBe5FDHRJEqZm5eysvvYW2GRQKAPSyRux46Oh0mWyCILu05d0OfMaYGBe5FDHRJEqZm5eysvvYW2GRQKAPSyRux46Oh0mWyCILu0HKhOtk9QQeSYzYXY(s8R9fRBFWjGSTzRZNoMgnvvcw5m52CPmX)Cd4eq22S15thlLvbhl7lXV2xSU9HMvbNaY2Mn6U3Mk2kBCxibYQ(qYJmWIETQwXKlUKPOAK18faFUkXMUA8IODnIB9lG7992uXwzJ7cjqwL2kqcdSOxRQvm5IlXhdhNZmcf6GyzdViYwSvYXMLsWsaViUaNbgtSql0QAfsnvSubnKG8cToL4W7D3FihmibYQo0NvDNh6tbzlYg)3BtfBLnUlKazvARGpK8imVmqEvtU4s8XWX5nmgdsnRkzobmvCVnvSv24UqcKvPTc(qYJW8Ya5vn5IlzkQgznFbWNRsSPRgViAxJ4w)c4EBQyRSXDHeiRsBf8HKhDwyjt3MHKbKjv)kbOdJ4crtYZjxCj0RQsWkNj3MlLj(NBaNaY2MToEqkd8XWX54qlaYMUANfwY4yZ0OXaFmCCoo0cGSPR2zHLmElmffD8c6Ksp(62hAciBB26uvLGvotodSOxBjtZaL9ZjGSTz7JNoMgn81Tp0eq22S1HQkbRCMCBUuM4FUbCciBB2O7EBQyRSXDHeiRsBf8HKhXHwaKnD1TGSuatQ(vcqhgXfIMKNtU4syGpgoohhAbq20v7SWsgVfMIIoL4qPQQeSYzYT5szI)5gWjGSTzRthsJgd8XWX54qlaYMUANfwY4TWuu05Z7TPITYg3fsGSkTvWhsEehAbq20v3cYsbmP6xjaDyexiAsEo5IlrvLGvotUnxkt8p3aobKTnBD8Gug4JHJZXHwaKnD1olSKXBHPOOZNJyeJba]] )

end
