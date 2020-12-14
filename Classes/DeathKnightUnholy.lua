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


    spec:RegisterPack( "Unholy", 20201214, [[d8K54bqifjpsQu1LOsOSjI0NuvAuivDkKkRIkHOxPkQzPiAxO6xQImmQK6yQswgsKNrLKPPkW1ufABQcY3KkvACQckNtvq16uKY8Kk6EeX(KkCqvfLfQQWdLkLjQQiUOuPI2OQIe1hPsOAKQksKtQQOYkvL6LQkQsZurQUPQIKANsL8tvfjzOujewQQIupLQmvfHRQQiHTQQOk(QuPcJfjQ9QWFj1GHCyklMQ6XKmzuUmyZq1NPIrlvDALwTQIQ61iHzt42e1Uf9BjdxrDCQeSCepxktx46qz7iPVtLA8uj68QQwpvcP5Ju2VkpEnMy4XSagDrjxtjx)IsVEa31UMspKRF4dV4FggEZMIcZbgEPjddVpfzFj(hEZ2VOm2yIHxRWiky41hXCBAp9KZg9y(Cvj)uBLXewSvQigE8uBLvpn88Xwr85YH)WJzbm6IsUMsU(fLE9aURDnLEix3DhETzqn6IspsPHx)Yyqo8hEmOPgED)H(eWI(d95nxN(4qFkY(s8FV7(d9jGcK9bYHE9GjpeLCnLC99(E39h6ZyF(yTqgYODOOo0NKFYtFcGVc4PpbSOVDOpbdouuhQsX)HufwghkmIdeTd5UVoKrGdbUCgubWouuhsSuHdjQ05qqwyo9hkQdjBraKdrVvGUbb28H6(x0XhEITfTXedpgGByIymXORxJjgEMk2khEYBY04eaCrHHhKMVayJpgXOlknMy4bP5la24JHxnp8Aqm8mvSvo8OAK18fWWJQjWGHNQkbRCN8gMSCLAhJ4u)cGtazBZ2H68qpEiPhkmbKbVHjlxP2Xio1Va4qA(cGn8OAeDAYWWBUkXMoA8IODmIt9lGrm6YvJjgEqA(cGn(y4vZdVgedptfBLdpQgznFbm8OAcmy4zQyPcAib5fAhsYHEDiPhI(dn1Hi2Y0avidUXyno4YTfTdrJ2Hi2Y0avidUXyn(MhQJd96Xdr3WJQr0PjddVwONfwMB6mIrxpymXWdsZxaSXhdpfzdGS2WJGLRspxUbcNb4RAJd1XHEOhpK0dr)HMHG7yeN6xaCtflv4q0ODOPouycidEdtwUsTJrCQFbWH08fa7q0DiPhIGLaNb4RAJd1HKd94WZuXw5WZiklbDuecKXigD94yIHhKMVayJpgEkYgazTH3meChJ4u)cGBQyPchIgTd5JHJZXY(s8RTwZWebhB(q0ODOWeqgCJi)RlCD0dAMjNaJdP5la2HKEOzi42CP0o9fMGBQyPchs6HO)qZqWnI8V2PVWeCtflv4q0ODivvcw5o5gr(xx46Oh0mWyCciBB2ouhhsvLGvUtUVOkMghJ8Zzyel2kp0thYvhIUdrJ2HWxN(qtazBZ2H6uYH8XWX5(IQyACmYpNHrSyRC4zQyRC45lQIPXXi)Jy01dnMy4bP5la24JHNISbqwB4ndb3Xio1Va4MkwQWHOr7q(y44CSSVe)AR1mmrWXMpenAhkmbKb3iY)6cxh9GMzYjW4qA(cGDiPhAgcUnxkTtFHj4MkwQWHKEi6p0meCJi)RD6lmb3uXsfoenAhsvLGvUtUrK)1fUo6bndmgNaY2MTd1XHuvjyL7K7dKgqOythodJyXw5HE6qU6q0DiA0oe(60hAciBB2ouNsoKpgoo3hinGqXMoCggXITYHNPITYHNpqAaHInDgXORU7yIHhKMVayJpgEkYgazTHNpgoohl7lXVUfeiDIEo28WZuXw5WtSo9rt)5JXCKHmgXORh2yIHhKMVayJpgEkYgazTH3meChJ4u)cGBQyPchIgTd5JHJZXY(s8RTwZWebhB(q0ODOWeqgCJi)RlCD0dAMjNaJdP5la2HKEOzi42CP0o9fMGBQyPchs6HO)qZqWnI8V2PVWeCtflv4q0ODivvcw5o5gr(xx46Oh0mWyCciBB2ouhhsvLGvUtULkOfetOvMqWzyel2kp0thYvhIUdrJ2HWxN(qtazBZ2H6uYHE94WZuXw5WZsf0cIj0ktigXORh(yIHhKMVayJpgEkYgazTHNPILkOHeKxODOoKCikDiA0oe9hIGLaNb4RAJd1HKd94HKEicwUk9C5giCgGVQnouhso0d56dr3WZuXw5WZiklb9mMObJy01lxpMy4bP5la24JHNISbqwB4ndb3Xio1Va4MkwQWHOr7q(y44CSSVe)AR1mmrWXMpenAhkmbKb3iY)6cxh9GMzYjW4qA(cGDiPhAgcUnxkTtFHj4MkwQWHKEi6p0meCJi)RD6lmb3uXsfoenAhsvLGvUtUrK)1fUo6bndmgNaY2MTd1XHuvjyL7KJVeWxufJZWiwSvEONoKRoeDhIgTdHVo9HMaY2MTd1PKd5JHJZXxc4lQIXzyel2khEMk2khE4lb8fvXgXORxVgtm8G08faB8XWtr2aiRn88XWX5yzFj(1TGaPt0ZXMpK0dzQyPcAib5fAhsYHEn8mvSvo88nhDHRdYQOOnIrxVO0yIHhKMVayJpgEkYgazTHhRco1LGjGm0ZcZbd4eaNaTEZxahs6HM6qHjGm4yzFj(1(I1Pp4qA(cGDiPhAQdrSLPbQqgCJXACWLBlAdptfBLdVcl8jGrXigD9YvJjgEqA(cGn(y4PiBaK1gESk4uxcMaYqplmhmGtaCc06nFbCiPhYuXsf0qcYl0ouhsoeLoK0dr)HM6qHjGm4yzFj(1(I1Pp4qA(cGDiA0ouycidow2xIFTVyD6doKMVayhs6HuvjyL7KJL9L4x7lwN(GtazBZ2HOB4zQyRC4vyHpbmkgXORxpymXWdsZxaSXhdpfzdGS2WJGLaErCaEdBgiTGyBYH08fa7qspe9hIvbhNuTqJdubcNa4eO1B(c4q0ODiwfCFrvm9SWCWaobWjqR38fWHOB4zQyRC4vyHpbmkgXORxpoMy4bP5la24JHNPITYHNYecTPITsTyBXWtSTqNMmm8ufviTmAJy01RhAmXWdsZxaSXhdptfBLdpLjeAtfBLAX2IHNyBHonzy4PQsWk3zBeJUE1Dhtm8G08faB8XWtr2aiRn8mvSubnKG8cTd1HKdrPdj9q0Fivvcw5o5mWIETLmndu2pNaY2MTd15HE56dj9qtDOWeqgCgGVcGdP5la2HOr7qQQeSYDYza(kaobKTnBhQZd9Y1hs6HctazWza(kaoKMVayhIUdj9qtDigyrV2sMMbk7NhRIInDgEMk2khEeSuBQyRul2wm8eBl0PjddpRaDdcS5rm661dBmXWdsZxaSXhdpfzdGS2WZuXsf0qcYl0ouhsoeLoK0dXal61wY0mqz)8yvuSPZWZuXw5WJGLAtfBLAX2IHNyBHonzy4zfO9XiTyeJUE9Whtm8G08faB8XWtr2aiRn8mvSubnKG8cTd1HKdrPdj9q0FOPoedSOxBjtZaL9ZJvrXMohs6HO)qQQeSYDYzGf9AlzAgOSFobKTnBhQJd9Y1hs6HM6qHjGm4maFfahsZxaSdrJ2HuvjyL7KZa8vaCciBB2ouhh6LRpK0dfMaYGZa8vaCinFbWoeDhIUHNPITYHhbl1Mk2k1ITfdpX2cDAYWWZbsGSkTvWigDrjxpMy4bP5la24JHNISbqwB4zQyPcAib5fAhsYHEn8mvSvo8uMqOnvSvQfBlgEITf60KHHNdKazvJyedphibYQgtm661yIHhKMVayJpgEkYgazTHNpgooVHXyqQzvjZjGPIdj9qtDiQgznFbWNRsSPJgViAhJ4u)c4q0ODOzi4ogXP(fa3uXsfgEMk2khEmWIETQwXigDrPXedpinFbWgFm8uKnaYAdpcwUk9C5giCgGVQnouNh6LRoK0dn1HOAK18faFUkXMoA8IODmIt9lGHNPITYHhdSOxRQvmIrxUAmXWdsZxaSXhdpfzdGS2WtvLGvUtUnxkt8p3aobKTnBhs6HO)qHjGm4maFfahsZxaSdrJ2HufviTm4560hACdoenAhIGLaErCa(CpyKsUsOXH08fa7q0n8mvSvo8S8xZs2igD9GXedpinFbWgFm8uKnaYAdpg4JHJZXHwaKnD0UlSKXBHPO4qDCOhm8mvSvo8Cxyjt3MHKbKrm66XXedpinFbWgFm8uKnaYAdpg4JHJZXHwaKnD0UlSKXXMpK0dPQsWk3j3MlLj(NBaNaY2MTd1XHE8qspe9hAQdfMaYGJL9L4x7lwN(GdP5la2HOr7qHjGm4gr(xx46Oh0mtobghsZxaSdj9qQkzyBWvvsTuwSvQlCD0dAgymoXskouNh6XdrJ2HM6qHjGm4gr(xx46Oh0mtobghsZxaSdj9qQkzyBWvvsTuwSvQlCD0dAgymoXskouhso0JhIgTdn1HuvYW2GRQKAPSyRux46Oh0mWyCinFbWoeDdptfBLdp3fwY0TzizazeJUEOXedpinFbWgFm8uKnaYAdpg4JHJZXHwaKnD0UlSKXXMpK0dfMaYGJL9L4x7lwN(GdP5la2HKEi6p0uhkmbKb3iY)6cxh9GMzYjW4qA(cGDiPhsvjdBdUQsQLYITsDHRJEqZaJXjwsXH68qpEiA0ouycidUrK)1fUo6bnZKtGXH08fa7qspKQsg2gCvLulLfBL6cxh9GMbgJtSKId1HKd94HO7qspe9hsvLGvUtow2xIFTVyD6dobKTnBhQJd9Y1hs6HM6qSk4yzFj(1(I1Pp0Sk4eq22SDiA0oKQkbRCNCBUuM4FUbCciBB2ouhh6LRpeDdptfBLdp3fwY0TzizazeJU6UJjgEqA(cGn(y4PiBaK1gEeSCv65Ynq4maFvBCOopeLC9HKEOPoevJSMVa4Zvj20rJxeTJrCQFbm8mvSvo8yGf9AvTIrm66HnMy4bP5la24JHNISbqwB4XaFmCCoo0cGSPJ2DHLmElmffhQZd9A4zQyRC4HdTaiB6OBbzPagXORh(yIHhKMVayJpgEkYgazTHhd8XWX54qlaYMoA3fwY4TWuuCOop0doK0dPQsWk3j3MlLj(NBaNaY2MTd15HE8qspe9hAQdfMaYGJL9L4x7lwN(GdP5la2HOr7qHjGm4gr(xx46Oh0mtobghsZxaSdj9qQkzyBWvvsTuwSvQlCD0dAgymoXskouNh6XdrJ2HM6qHjGm4gr(xx46Oh0mtobghsZxaSdj9qQkzyBWvvsTuwSvQlCD0dAgymoXskouhso0JhIgTdn1HuvYW2GRQKAPSyRux46Oh0mWyCinFbWoeDdptfBLdpCOfazthDlilfWigD9Y1JjgEqA(cGn(y4PiBaK1gEmWhdhNJdTaiB6ODxyjJ3ctrXH68qp4qspuycidow2xIFTVyD6doKMVayhs6HO)qtDOWeqgCJi)RlCD0dAMjNaJdP5la2HKEivLmSn4QkPwkl2k1fUo6bndmgNyjfhQZd94HOr7qHjGm4gr(xx46Oh0mtobghsZxaSdj9qQkzyBWvvsTuwSvQlCD0dAgymoXskouhso0JhIUdj9q0Fivvcw5o5yzFj(1(I1Pp4eq22SDOop0lxFiA0oKQkbRCNCBUuM4FUbCciBB2ouNh6LRpK0dXQGJL9L4x7lwN(qZQGtazBZ2HOB4zQyRC4HdTaiB6OBbzPagXORxVgtm8G08faB8XWtr2aiRn8M6qunYA(cGpxLythnEr0ogXP(fWWZuXw5WJbw0Rv1kgXigEQIkKwgTXeJUEnMy4bP5la24JHNISbqwB4r1iR5laEl0ZclZnDoK0drWYvPNl3aHZa8vTXH64qVEOHNPITYHxZTrK30rlVTyeJUO0yIHhKMVayJpgEkYgazTHNQkbRCNCBUuM4FUbCciBB2oK0dr)HmvSubnKG8cTd1HKdrPdj9qMkwQGgsqEH2H6uYHE8qspeblxLEUCdeodWx1ghQJd9Y1h65dr)HmvSubnKG8cTd5I8qp0HO7q0ODitflvqdjiVq7qDCOhpK0drWYvPNl3aHZa8vTXH64qpW1hIUHNPITYHxZTrK30rlVTyeJUC1yIHhKMVayJpgEkYgazTHhvJSMVa4TqplSm305qsp0uhQvyc)nzCbymT)VgCPjplGdj9qQQeSYDYT5szI)5gWjGSTz7qspeblbESYGok9douhhI(d5Qd98H8XWX5eSCvAvriyZXwjNaY2MTdr3WZuXw5WZ8l5nTyRulwz)rm66bJjgEqA(cGn(y4PiBaK1gEunYA(cG3c9SWYCtNdj9qTct4VjJlaJP9)1Gln5zbCiPhI(dPQsWk3jhl7lXV2xSo9bNaY2MTdrJ2HM6qHjGm4yzFj(1(I1Pp4qA(cGDiPhsvLGvUtoZiuOdILn8IiBXwjNaY2MTdr3WZuXw5WZ8l5nTyRulwz)rm66XXedpinFbWgFm8uKnaYAdptflvqdjiVq7qDi5qu6qspeblbESYGok9douhhI(d5Qd98H8XWX5eSCvAvriyZXwjNaY2MTdr3WZuXw5WZ8l5nTyRulwz)rm66Hgtm8G08faB8XWtr2aiRn8OAK18faVf6zHL5Mohs6HuvjyL7KBZLYe)ZnGtazBZ2WZuXw5WR1BkkeGo6bnw6Uir))igD1Dhtm8G08faB8XWtr2aiRn8mvSubnKG8cTd1HKdrPdj9q0FigyrV2sMMbk7NhRIInDoenAhIyltduHm4gJ14eq22SDOoLCOxp4q0n8mvSvo8A9MIcbOJEqJLUls0)pIrm8MjGQK9TymXORxJjgEMk2khEZvSvo8G08faB8XigDrPXedpinFbWgFm8stggEMlAR3iwtJxzOlC9C5gidptfBLdpZfT1BeRPXRm0fUEUCdKrm6YvJjgEMk2khEeBBGMbgB4bP5la24JrmIHNQkbRCNTXeJUEnMy4bP5la24JHNISbqwB4ndb3Xio1Va4MkwQWHOr7q(y44CSSVe)AR1mmrWXMpenAhkmbKb3iY)6cxh9GMzYjW4qA(cGDiPhI(dndb3iY)AN(ctWnvSuHdrJ2HMHGBZLs70xycUPILkCiA0oKQkbRCNCJi)RlCD0dAgymobKTnBhQJdHVo9HMaY2MTdr3WZuXw5WBUITYrm6IsJjgEqA(cGn(y4zQyRC4TztrWcZxaAxaZYatwZaQRcgEkYgazTHh9hsvLGvUtow2xIFTVyD6dobKTnBhIgTdPQsWk3jNzek0bXYgErKTyRKtazBZ2HO7qspe9hAgcUrK)1o9fMGBQyPchIgTdndb3MlL2PVWeCtflv4qsp0uhkmbKb3iY)6cxh9GMzYjW4qA(cGDiA0ouyehi4Xkd6O0ZQqtjxFOop0JhIUHxAYWWBZMIGfMVa0UaMLbMSMbuxfmIrxUAmXWdsZxaSXhdptfBLdpztz(eq36bi0YyTvn8uKnaYAdpvvcw5o52CPmX)Cd4eq22SDOop0Jhs6HO)qtDiWfW25zGX3SPiyH5laTlGzzGjRza1vbhIgTdPQsWk3jFZMIGfMVa0UaMLbMSMbuxfWjGSTz7q0n8stggEYMY8jGU1dqOLXARAeJUEWyIHhKMVayJpgEMk2khEmcym8LaAQqRbIHNISbqwB4PQsWk3j3MlLj(NBaNaY2MTdj9qeSe4Xkd6O0p4qDEihf7qspe9hAQdbUa2opdm(MnfblmFbODbmldmzndOUk4q0ODivvcw5o5B2ueSW8fG2fWSmWK1mG6QaobKTnBhIUHxAYWWJraJHVeqtfAnqmIrxpoMy4bP5la24JHNPITYHhZiuixvQzGIcn1IyQn(hEkYgazTHNQkbRCNCBUuM4FUbCciBB2oK0dr)HM6qGlGTZZaJVztrWcZxaAxaZYatwZaQRcoenAhsvLGvUt(MnfblmFbODbmldmzndOUkGtazBZ2HOB4LMmm8ygHc5QsnduuOPwetTX)igD9qJjgEqA(cGn(y4PiBaK1gEQQeSYDYT5szI)5gWjGSTz7qspe9hAQdbUa2opdm(MnfblmFbODbmldmzndOUk4q0ODivvcw5o5B2ueSW8fG2fWSmWK1mG6QaobKTnBhIUHNPITYHhwd0BaYTrm6Q7oMy4bP5la24JHNISbqwB4PQsWk3jhl7lXV2xSo9bNaY2MTd15HC1HKEivvcw5o5mJqHoiw2WlISfBLCciBB2ouNhYvhs6HctazWXY(s8R9fRtFWH08fa7q0ODOPouycidow2xIFTVyD6doKMVaydptfBLdpJi)RlCD0dAgySrm66HnMy4bP5la24JHNISbqwB4r1iR5laEl0ZclZnDoK0dr)HuvjyL7KBe5FDHRJEqZaJXjGSTz7qDCOhpeDhs6HO)qQQeSYDYzgHcDqSSHxezl2k5eq22SDOopKJIDiA0oKpgooNzek0bXYgErKTyRKJnFi6oK0dr)HM6qeSeWlIdWzGXel0cTQwbhsZxaSdrJ2HM6qHjGm4gr(xx46Oh0mtobghsZxaSdrJ2HuvYW2GRQKAPSyRux46Oh0mWyCILuCOop0JhIUHNPITYHhw2xIFTVyD6Jrm66HpMy4bP5la24JHNISbqwB4r1iR5laEl0ZclZnDoK0dr)HuvjyL7KBe5FDHRJEqZaJXjGSTz7qDCOhpenAhIbw0RPixN(GZ2M5laTvb7q0DiPhIGLaErCaodmMyHwOv1k4qA(cGDiPhkmbKb3iY)6cxh9GMzYjW4qA(cGDiPhsvjdBdUQsQLYITsDHRJEqZaJXjwsXH6qYHE8qspKQkbRCNCBUuM4FUbCciBB2ouNhYvhs6HO)qQQeSYDYzgHcDqSSHxezl2k5eq22SDOopKJIDiA0oKpgooNzek0bXYgErKTyRKJnFi6gEMk2khEyzFj(1(I1PpgXORxUEmXWdsZxaSXhdpfzdGS2WZuXsf0qcYl0ouhsoeLgEMk2khEyzFj(1(I1PpgXORxVgtm8G08faB8XWtr2aiRn8OAK18faVf6zHL5Mohs6HO)qSk4yzFj(1(I1Pp0Sk4eq22SDiA0o0uhkmbKbhl7lXV2xSo9bhsZxaSdr3WZuXw5WJzek0bXYgErKTyRCeJUErPXedpinFbWgFm8uKnaYAdptflvqdjiVq7qDi5quA4zQyRC4Xmcf6GyzdViYwSvoIrxVC1yIHhKMVayJpgEkYgazTHNPILkOHeKxODijh61HKEig4JHJZXHwaKnD0UlSKXBHPO4qDi5qp4qspuycidow2xIFTVyD6doKMVayhs6HctazWnI8VUW1rpOzMCcmoKMVayhs6HiyjGxehGZaJjwOfAvTcoKMVayhs6HuvYW2GRQKAPSyRux46Oh0mWyCILuCOoKCOhpK0dXQGJL9L4x7lwN(qZQGtazBZ2WZuXw5WZMlLj(NBWigD96bJjgEqA(cGn(y4PiBaK1gEMkwQGgsqEH2HKCOxhs6HyGpgoohhAbq20r7UWsgVfMIId1HKd9Gdj9qHjGm4yzFj(1(I1Pp4qA(cGDiPhIvbhl7lXV2xSo9HMvbNaY2MTdj9qtDOWeqgCJi)RlCD0dAMjNaJdP5la2HKEivLmSn4QkPwkl2k1fUo6bndmgNyjfhQZd94WZuXw5WZMlLj(NBWigD96XXedpinFbWgFm8uKnaYAdptflvqdjiVq7qso0Rdj9qmWhdhNJdTaiB6ODxyjJ3ctrXH6qYHEWHKEi6p0uhkmbKbhl7lXV2xSo9bhsZxaSdrJ2HctazWnI8VUW1rpOzMCcmoKMVayhs6HO)qtDicwc4fXb4mWyIfAHwvRGdP5la2HOr7qQkzyBWvvsTuwSvQlCD0dAgymoXskouNh6Xdr3HOr7qtDOWeqgCJi)RlCD0dAMjNaJdP5la2HKEivLmSn4QkPwkl2k1fUo6bndmgNyjfhQdjh6Xdr3WZuXw5WZMlLj(NBWigD96Hgtm8G08faB8XWZuXw5WZMlLj(NBWWtr2aiRn8mvSubnKG8cTd1HKdrPdj9qmWhdhNJdTaiB6ODxyjJ3ctrXH6qYHEWHKEOPoedSOxBjtZaL9ZJvrXModp1Vsa6Wioq0gD9AeJUE1Dhtm8G08faB8XWtr2aiRn8iy5Q0ZLBGWza(Q24qDEOxp4qspe9hsvLGvUtow2xIFTVyD6dobKTnBhQZd9Y1hIgTdXQGJL9L4x7lwN(qZQGtazBZ2HOB4zQyRC41WKLRu7yeN6xaJy01Rh2yIHhKMVayJpgEkYgazTHhvJSMVa4TqplSm305qsped8XWX54qlaYMoA3fwY4TWuuCOopeLoK0dr)HMHGBZLs70xycUPILkCiA0oKQsg2gCvLulLfBL6cxh9GMbgJdP5la2HKEiFmCCoZiuOdILn8IiBXwjhB(qsp0uhAgcUrK)1o9fMGBQyPchIUHNPITYHhw2xIFT1AgMigXORxp8XedpinFbWgFm8mvSvo8WY(s8RTwZWeXWtr2aiRn8mvSubnKG8cTd1HKdrPdj9qmWhdhNJdTaiB6ODxyjJ3ctrXH68quA4P(vcqhgXbI2ORxJy0fLC9yIHhKMVayJpgEMk2khETctOjGndKHNISbqwB4fgXbcESYGok9Sk0U6Xd15HE8qspuyehi4Xkd6O0Sfouhh6XHN6xjaDyehiAJUEnIrxu61yIHhKMVayJpgEkYgazTH3uhAgcUtFHj4MkwQWWZuXw5WJyBd0mWyJy0fLO0yIHhKMVayJpgEkYgazTHNPILkOHeKxODOoKCikDiPhAQd5JHJZzgHcDqSSHxezl2k5yZhs6HM6qQQeSYDYzgHcDqSSHxezl2k5eWy)dptfBLdVMPil(QwtONnvmIrm8CGeiRsBfmMy01RXedpinFbWgFm8uKnaYAdpFmCCoZiuOdILn8IiBXwjhB(qspeblb8I4aCgymXcTqRQvWH08fa7qspKPILkOHeKxODOoLCixn8mvSvo8yGf9AvTIrm6IsJjgEqA(cGn(y4PiBaK1gE(y448ggJbPMvLmNaMkgEMk2khEW8Ya5vnIrxUAmXWdsZxaSXhdpfzdGS2WBQdr1iR5la(CvInD04fr7yeN6xadptfBLdpyEzG8QgXORhmMy4bP5la24JHNPITYHN7clz62mKmGm8uKnaYAdp6pKQkbRCNCBUuM4FUbCciBB2ouhh6Xdj9qmWhdhNJdTaiB6ODxyjJJnFiA0oed8XWX54qlaYMoA3fwY4TWuuCOoo0doeDhs6HO)q4RtFOjGSTz7qDEivvcw5o5mWIETLmndu2pNaY2MTd98HE56drJ2HWxN(qtazBZ2H64qQQeSYDYT5szI)5gWjGSTz7q0n8u)kbOdJ4arB01Rrm66XXedpinFbWgFm8mvSvo8WHwaKnD0TGSuadpfzdGS2WJb(y44CCOfazthT7clz8wykkouNsoKRoK0dPQsWk3j3MlLj(NBaNaY2MTd15HC1HOr7qmWhdhNJdTaiB6ODxyjJ3ctrXH68qVgEQFLa0HrCGOn661igD9qJjgEqA(cGn(y4zQyRC4HdTaiB6OBbzPagEkYgazTHNQkbRCNCBUuM4FUbCciBB2ouhh6Xdj9qmWhdhNJdTaiB6ODxyjJ3ctrXH68qVgEQFLa0HrCGOn661igXWZkq7JrAXyIrxVgtm8G08faB8XWtr2aiRn88XWX5mJqHoiw2WlISfBLCS5dj9qeSeWlIdWzGXel0cTQwbhsZxaSdj9qMkwQGgsqEH2H6uYHC1WZuXw5WJbw0Rv1kgXOlknMy4bP5la24JHNISbqwB4rWYvPNl3aHZa8vTXH68q0FOxU(qpFigyrVMICD6doU7clzathgXbI2HCrEixDi6oK0dXal61uKRtFWXDxyjdy6Wioq0ouNh6HoK0dn1HOAK18faFUkXMoA8IODmIt9lGdrJ2H8XWX5n3grEthT82co28WZuXw5WdMxgiVQrm6YvJjgEqA(cGn(y4PiBaK1gEeSCv65Ynq4maFvBCOopeLE8qspedSOxtrUo9bh3DHLmGPdJ4ar7qDCOhpK0dn1HOAK18faFUkXMoA8IODmIt9lGHNPITYHhmVmqEvJy01dgtm8G08faB8XWtr2aiRn8M6qmWIEnf560hCC3fwYaMomIdeTdj9qtDiQgznFbWNRsSPJgViAhJ4u)c4q0ODi81Pp0eq22SDOop0JhIgTdrSLPbQqgCJXACWLBlAhs6Hi2Y0avidUXynobKTnBhQZd94WZuXw5WdMxgiVQrm66XXedptfBLdp3fwY0Tzizaz4bP5la24Jrm66Hgtm8G08faB8XWtr2aiRn8M6qunYA(cGpxLythnEr0ogXP(fWWZuXw5WdMxgiVQrmIHNvGUbb28yIrxVgtm8G08faB8XWtr2aiRn8yGf9AkY1Pp44UlSKbmDyehiAhQdjhs9ReGgsqEH2HOr7qeBzAGkKb3ySghC52I2HKEiITmnqfYGBmwJtazBZ2H6uYHE9A4zQyRC4z5VMLSrm6IsJjgEqA(cGn(y4PiBaK1gEmWIEnf560hCC3fwYaMomIdeTd1HKd94WZuXw5WZYFnlzJy0LRgtm8G08faB8XWtr2aiRn88XWX5mJqHoiw2WlISfBLCS5dj9qeSeWlIdWzGXel0cTQwbhsZxaSdj9qMkwQGgsqEH2H6uYHC1WZuXw5WJbw0Rv1kgXORhmMy4bP5la24JHNISbqwB4n1HOAK18faFUkXMoA8IODmIt9lGHNPITYHhmVmqEvJy01JJjgEqA(cGn(y4zQyRC4HdTaiB6OBbzPagEkYgazTHhd8XWX54qlaYMoA3fwY4TWuuCOoLCixDiPhsvLGvUtUnxkt8p3aobKTnBhQZd5QHN6xjaDyehiAJUEnIrxp0yIHhKMVayJpgEMk2khE4qlaYMo6wqwkGHNISbqwB4XaFmCCoo0cGSPJ2DHLmElmffhQZd9A4P(vcqhgXbI2ORxJy0v3DmXWdsZxaSXhdptfBLdpCOfazthDlilfWWtr2aiRn8iyjWJvg0rPFWH68q0Fivvcw5o5mWIETLmndu2pNaY2MTdj9qtDOWeqgCgGVcGdP5la2HOr7qQQeSYDYza(kaobKTnBhs6HctazWza(kaoKMVayhIUHN6xjaDyehiAJUEnIrmIHhvG02khDrjxtjx)IsVC1WZTrYnDAdVUJp7t31NRlx8PDOdnrpCOvEUiXHWlYH(6ajqw13draxaBja7qTsgoKHfLSfa7qQElDGg)Ep9nHd5QPDOUvjvGea7qFjyjGxehGt5VhkQd9LGLaErCaoL5qA(cG99q0)YL0XV3tFt4qpoTd1TkPcKayh6BycidoL)EOOo03WeqgCkZH08fa77HO3vUKo(9E6Bch6XPDOUvjvGea7qFvvYW2Gt5VhkQd9vvjdBdoL5qA(cG99q0)YL0XV3tFt4qp00ou3QKkqcGDOVHjGm4u(7HI6qFdtazWPmhsZxaSVhIEx5s6437PVjCOh(0ou3QKkqcGDOVHjGm4u(7HI6qFdtazWPmhsZxaSVhIEx5s6437PVjCOh(0ou3QKkqcGDOVQkzyBWP83df1H(QQKHTbNYCinFbW(Ei6F5s6437PVjCOxUEAhQBvsfibWo03WeqgCk)9qrDOVHjGm4uMdP5la23drVRCjD8799U74Z(0D956YfFAh6qt0dhALNlsCi8ICOVwb6geyZFpebCbSLaSd1kz4qgwuYwaSdP6T0bA87903eoKRM2H6wLubsaSd9LGLaErCaoL)EOOo0xcwc4fXb4uMdP5la23dr)lxsh)Ep9nHd1DN2H6wLubsaSd9nmbKbNYFpuuh6BycidoL5qA(cG99q0tjxsh)EFV7o(SpDxFUUCXN2Ho0e9WHw55IehcVih6ldWnmr89qeWfWwcWouRKHdzyrjBbWoKQ3shOXV3tFt4quAAhQBvsfibWo03WeqgCk)9qrDOVHjGm4uMdP5la23dzXH6o)un9dr)lxsh)Ep9nHd940ou3QKkqcGDiVvUBhQ9NH5Yd5IDOOo00XSdXwQBBR8q1mqSOihI(NO7q0)YL0XV3tFt4qpoTd1TkPcKayh6BycidoL)EOOo03WeqgCkZH08fa77HO)LlPJFVN(MWHEOPDOUvjvGea7qERC3ou7pdZLhYf7qrDOPJzhITu32w5HQzGyrroe9pr3HO)LlPJFVN(MWHEOPDOUvjvGea7qFdtazWP83df1H(gMaYGtzoKMVayFpe9VCjD87903eo0dBAhQBvsfibWoK3k3Td1(ZWC5HCXouuhA6y2Hyl1TTvEOAgiwuKdr)t0Di6F5s6437PVjCOh20ou3QKkqcGDOVHjGm4u(7HI6qFdtazWPmhsZxaSVhI(xUKo(9E6Bch6LRN2H6wLubsaSd5TYD7qT)mmxEixSdf1HMoMDi2sDBBLhQMbIff5q0)eDhI(xUKo(9E6Bch6LRN2H6wLubsaSd9nmbKbNYFpuuh6BycidoL5qA(cG99q0)YL0XV3tFt4qVO00ou3QKkqcGDOVHjGm4u(7HI6qFdtazWPmhsZxaSVhI(xUKo(9E6Bch6LRM2H6wLubsaSd9nmbKbNYFpuuh6BycidoL5qA(cG99q0tjxsh)Ep9nHd96bt7qDRsQaja2H(sWsaVioaNYFpuuh6lblb8I4aCkZH08fa77HO)LlPJFVN(MWHE1DN2H6wLubsaSd9nmbKbNYFpuuh6BycidoL5qA(cG99q0tjxsh)Ep9nHd96HpTd1TkPcKayh6BycidoL)EOOo03WeqgCkZH08fa77HONsUKo(9(E3D8zF6U(CD5IpTdDOj6HdTYZfjoeEro0xvvcw5oBFpebCbSLaSd1kz4qgwuYwaSdP6T0bA87903eo0RPDOUvjvGea7qFdtazWP83df1H(gMaYGtzoKMVayFpe9VCjD87903eoeLM2H6wLubsaSd9nmbKbNYFpuuh6BycidoL5qA(cG99q0)YL0XV3tFt4qD3PDOUvjvGea7qFdtazWP83df1H(gMaYGtzoKMVayFpe9VCjD87903eou3DAhQBvsfibWo03WeqgCk)9qrDOVHjGm4uMdP5la23dzXH6o)un9dr)lxsh)Ep9nHd9WM2H6wLubsaSd9nmbKbNYFpuuh6BycidoL5qA(cG99q0)YL0XV3tFt4qpSPDOUvjvGea7qFjyjGxehGt5VhkQd9LGLaErCaoL5qA(cG99q0)YL0XV3tFt4qp8PDOUvjvGea7qFdtazWP83df1H(gMaYGtzoKMVayFpe9VCjD87903eo0dFAhQBvsfibWo0xcwc4fXb4u(7HI6qFjyjGxehGtzoKMVayFpe9VCjD87903eo0Rxt7qDRsQaja2H(gMaYGt5VhkQd9nmbKbNYCinFbW(Ei6F5s6437PVjCOxUAAhQBvsfibWo03WeqgCk)9qrDOVHjGm4uMdP5la23drpLCjD87903eo0lxnTd1TkPcKayh6lblb8I4aCk)9qrDOVeSeWlIdWPmhsZxaSVhI(xUKo(9E6Bch61dM2H6wLubsaSd9nmbKbNYFpuuh6BycidoL5qA(cG99q0tjxsh)Ep9nHd96XPDOUvjvGea7qFdtazWP83df1H(gMaYGtzoKMVayFpe9UYL0XV3tFt4qVECAhQBvsfibWo0xcwc4fXb4u(7HI6qFjyjGxehGtzoKMVayFpe9VCjD87903eo0Rh20ou3QKkqcGDOVQkzyBWP83df1H(QQKHTbNYCinFbW(Ei6F5s64377D3XN9P76Z1Ll(0o0HMOho0kpxK4q4f5qFDGeiRsBf89qeWfWwcWouRKHdzyrjBbWoKQ3shOXV3tFt4qVM2H6wLubsaSd9LGLaErCaoL)EOOo0xcwc4fXb4uMdP5la23dr)lxsh)EFV7o(SpDxFUUCXN2Ho0e9WHw55IehcVih6RvG2hJ0IVhIaUa2sa2HALmCidlkzla2Hu9w6an(9E6Bch610ou3QKkqcGDOVeSeWlIdWP83df1H(sWsaVioaNYCinFbW(Ei6F5s64377D3XN9P76Z1Ll(0o0HMOho0kpxK4q4f5qFvfviTmAFpebCbSLaSd1kz4qgwuYwaSdP6T0bA87903eo0dM2H6wLubsaSd9nmbKbNYFpuuh6BycidoL5qA(cG99q0)YL0XV337pN8CrcGDOh2HmvSvEiX2Ig)Ep8mSOVidpVvgtyXwz3igEm8Mjf(kGHx3FOpbSO)qFEZ1Ppo0NISVe)37U)qFcOazFGCOxpyYdrjxtjxFVV3D)H(m2NpwlKHmAhkQd9j5N80Na4RaE6tal6Bh6tWGdf1HQu8FivHLXHcJ4ar7qU7Rdze4qGlNbvaSdf1Helv4qIkDoeKfMt)HI6qYwea5q0BfOBqGnFOU)fD87992uXwzJptavj7BXZsEAUITY7TPITYgFMaQs23INL8ewd0BaYtMMmiXCrB9gXAA8kdDHRNl3a5EBQyRSXNjGQK9T4zjprSTbAgyS799U7pu3PlbfwaSdbubY)HIvgou0dhYurro02oKr1wH5la(92uXwztI8Mmnobaxu4E39h6ZJrwZxaT7TPITY2ZsEIQrwZxatMMmizUkXMoA8IODmIt9lGjPAcmqIQkbRCN8gMSCLAhJ4u)cGtazBZwNpknmbKbVHjlxP2Xio1VaU3Mk2kBpl5jQgznFbmzAYGKwONfwMB6mjvtGbsmvSubnKG8cnjVKs)ueBzAGkKb3ySghC52IgnAeBzAGkKb3ySgFZoE9iD37U)qFAtTMODVnvSv2EwYtgrzjOJIqGmMCXLqWYvPNl3aHZa8vTrhp0JsPFgcUJrCQFbWnvSubA0MkmbKbVHjlxP2Xio1Va4qA(cGrNucwcCgGVQn6qYJ3BtfBLTNL8KVOkMghJ8p5IlzgcUJrCQFbWnvSubA08XWX5yzFj(1wRzyIGJntJwycidUrK)1fUo6bnZKtGjDgcUnxkTtFHj4MkwQGu6NHGBe5FTtFHj4MkwQanAQQeSYDYnI8VUW1rpOzGX4eq22S1HQkbRCNCFrvmnog5NZWiwSv6I5k6OrdFD6dnbKTnBDkXhdhN7lQIPXXi)CggXITY7TPITY2ZsEYhinGqXMotU4sMHG7yeN6xaCtflvGgnFmCCow2xIFT1AgMi4yZ0OfMaYGBe5FDHRJEqZm5eysNHGBZLs70xycUPILkiL(zi4gr(x70xycUPILkqJMQkbRCNCJi)RlCD0dAgymobKTnBDOQsWk3j3hinGqXMoCggXITsxmxrhnA4RtFOjGSTzRtj(y44CFG0acfB6Wzyel2kV3Mk2kBpl5jX60hn9NpgZrgYyYfxIpgoohl7lXVUfeiDIEo289U7p0NLkOfetCOUzcXHuwEOGSooa5qp4qZvazSM4q(y44TjpeyQ(djSwSPZHE94HAGQswJFOpfXkwxuGDOEJWoKQya7qXkdhYAhYouqwhhGCOOoefamFOnoebmM5la(92uXwz7zjpzPcAbXeALjetU4sMHG7yeN6xaCtflvGgnFmCCow2xIFT1AgMi4yZ0OfMaYGBe5FDHRJEqZm5eysNHGBZLs70xycUPILkiL(zi4gr(x70xycUPILkqJMQkbRCNCJi)RlCD0dAgymobKTnBDOQsWk3j3sf0cIj0kti4mmIfBLUyUIoA0WxN(qtazBZwNsE9492uXwz7zjpzeLLGEgt0GjxCjMkwQGgsqEHwhsOenA0tWsGZa8vTrhsEukblxLEUCdeodWx1gDi5HCnD3BtfBLTNL8e(saFrvSjxCjZqWDmIt9laUPILkqJMpgoohl7lXV2AndteCSzA0ctazWnI8VUW1rpOzMCcmPZqWT5sPD6lmb3uXsfKs)meCJi)RD6lmb3uXsfOrtvLGvUtUrK)1fUo6bndmgNaY2MTouvjyL7KJVeWxufJZWiwSv6I5k6OrdFD6dnbKTnBDkXhdhNJVeWxufJZWiwSvEVnvSv2EwYt(MJUW1bzvu0MCXL4JHJZXY(s8RBbbsNONJnl1uXsf0qcYl0K86E39h6tTTzyBUPZH(8SembKXHCrimhm4qB7q2HMjBr24)EBQyRS9SKNkSWNagftU4syvWPUembKHEwyoyaNa4eO1B(cq6uHjGm4yzFj(1(I1PpKofXwMgOczWngRXbxUTODVnvSv2EwYtfw4taJIjxCjSk4uxcMaYqplmhmGtaCc06nFbi1uXsf0qcYl06qcLKs)uHjGm4yzFj(1(I1PpOrlmbKbhl7lXV2xSo9Huvvcw5o5yzFj(1(I1Pp4eq22Sr392uXwz7zjpvyHpbmkMCXLqWsaVioaVHndKwqSnLspRcooPAHghOceobWjqR38fanASk4(IQy6zH5GbCcGtGwV5la6U3D)H(mvSvEOPVTODVnvSv2EwYtkti0Mk2k1ITftMMmirvuH0YODVnvSv2EwYtkti0Mk2k1ITftMMmirvLGvUZ292uXwz7zjprWsTPITsTyBXKPjdsSc0niWMNCXLyQyPcAib5fADiHssPxvLGvUtodSOxBjtZaL9ZjGSTzRZxUw6uHjGm4maFfanAQQeSYDYza(kaobKTnBD(Y1sdtazWza(ka6KofdSOxBjtZaL9ZJvrXMo3BtfBLTNL8ebl1Mk2k1ITftMMmiXkq7JrAXKlUetflvqdjiVqRdjuskdSOxBjtZaL9ZJvrXMo3BtfBLTNL8ebl1Mk2k1ITftMMmiXbsGSkTvWKlUetflvqdjiVqRdjusk9tXal61wY0mqz)8yvuSPJu6vvjyL7KZal61wY0mqz)CciBB264LRLovycidodWxbqJMQkbRCNCgGVcGtazBZwhVCT0WeqgCgGVcGo6U3Mk2kBpl5jLjeAtfBLAX2IjttgK4ajqw1KlUetflvqdjiVqtYR799U7p0NvDNh6dmslU3Mk2kBCRaTpgPfsyGf9AvTIjxCj(y44CMrOqhelB4fr2ITso2Sucwc4fXb4mWyIfAHwvRqQPILkOHeKxO1PexDVnvSv24wbAFmslEwYtW8Ya5vn5IlHGLRspxUbcNb4RAJoP)LRFMbw0RPixN(GJ7UWsgW0HrCGO5I0v0jLbw0RPixN(GJ7UWsgW0HrCGO15djDkQgznFbWNRsSPJgViAhJ4u)cGgnFmCCEZTrK30rlVTGJnFVnvSv24wbAFmslEwYtW8Ya5vn5IlHGLRspxUbcNb4RAJoP0JszGf9AkY1Pp44UlSKbmDyehiAD8O0POAK18faFUkXMoA8IODmIt9lG7TPITYg3kq7JrAXZsEcMxgiVQjxCjtXal61uKRtFWXDxyjdy6Wioq0KofvJSMVa4Zvj20rJxeTJrCQFbqJg(60hAciBB268rA0i2Y0avidUXyno4YTfnPeBzAGkKb3ySgNaY2MToF8EBQyRSXTc0(yKw8SKNCxyjt3MHKbK7TPITYg3kq7JrAXZsEcMxgiVQjxCjtr1iR5la(CvInD04fr7yeN6xa377D3FOpR6opKheyZ3BtfBLnUvGUbb2Sel)1SKn5IlHbw0RPixN(GJ7UWsgW0HrCGO1He1VsaAib5fA0OrSLPbQqgCJXACWLBlAsj2Y0avidUXynobKTnBDk51R7TPITYg3kq3GaB(zjpz5VMLSjxCjmWIEnf560hCC3fwYaMomIdeToK8492uXwzJBfOBqGn)SKNyGf9AvTIjxCj(y44CMrOqhelB4fr2ITso2Sucwc4fXb4mWyIfAHwvRqQPILkOHeKxO1PexDVnvSv24wb6geyZpl5jyEzG8QMCXLmfvJSMVa4Zvj20rJxeTJrCQFbCVnvSv24wb6geyZpl5jCOfazthDlilfWKQFLa0HrCGOj51KlUeg4JHJZXHwaKnD0UlSKXBHPOOtjUsQQkbRCNCBUuM4FUbCciBB260v3BtfBLnUvGUbb28ZsEchAbq20r3cYsbmP6xjaDyehiAsEn5IlHb(y44CCOfazthT7clz8wykk68192uXwzJBfOBqGn)SKNWHwaKnD0TGSuatQ(vcqhgXbIMKxtU4siyjWJvg0rPFqN0RQsWk3jNbw0RTKPzGY(5eq22SjDQWeqgCgGVcGgnvvcw5o5maFfaNaY2MnPHjGm4maFfaD377D3FixevSv2oKLSdvrpqouLhcRb3BtfBLnUQkbRCNnjZvSvo5IlzgcUJrCQFbWnvSubA08XWX5yzFj(1wRzyIGJntJwycidUrK)1fUo6bnZKtGjL(zi4gr(x70xycUPILkqJ2meCBUuAN(ctWnvSubA0uvjyL7KBe5FDHRJEqZaJXjGSTzRd81Pp0eq22Sr392uXwzJRQsWk3z7zjpH1a9gG8KPjds2SPiyH5laTlGzzGjRza1vbtU4sOxvLGvUtow2xIFTVyD6dobKTnB0OPQsWk3jNzek0bXYgErKTyRKtazBZgDsPFgcUrK)1o9fMGBQyPc0Ondb3MlL2PVWeCtflvq6uHjGm4gr(xx46Oh0mtobgnAHrCGGhRmOJspRcnLCDNps392uXwzJRQsWk3z7zjpH1a9gG8KPjdsKnL5taDRhGqlJ1w1KlUevvcw5o52CPmX)Cd4eq22S15JsPFkWfW25zGX3SPiyH5laTlGzzGjRza1vb0OPQsWk3jFZMIGfMVa0UaMLbMSMbuxfWjGSTzJU7TPITYgxvLGvUZ2ZsEcRb6na5jttgKWiGXWxcOPcTgiMCXLOQsWk3j3MlLj(NBaNaY2MnPeSe4Xkd6O0pOthftk9tbUa2opdm(MnfblmFbODbmldmzndOUkGgnvvcw5o5B2ueSW8fG2fWSmWK1mG6QaobKTnB0DVnvSv24QQeSYD2EwYtynqVbipzAYGeMrOqUQuZaffAQfXuB8p5IlrvLGvUtUnxkt8p3aobKTnBsPFkWfW25zGX3SPiyH5laTlGzzGjRza1vb0OPQsWk3jFZMIGfMVa0UaMLbMSMbuxfWjGSTzJU7TPITYgxvLGvUZ2ZsEcRb6na52KlUevvcw5o52CPmX)Cd4eq22SjL(PaxaBNNbgFZMIGfMVa0UaMLbMSMbuxfqJMQkbRCN8nBkcwy(cq7cywgyYAgqDvaNaY2Mn6U3D)H6wvcw5oB3BtfBLnUQkbRCNTNL8KrK)1fUo6bndm2KlUevvcw5o5yzFj(1(I1Pp4eq22S1PRKQQsWk3jNzek0bXYgErKTyRKtazBZwNUsAycidow2xIFTVyD6dA0MkmbKbhl7lXV2xSo9X9U7pK3FQo0hI1PpoK7n6p0Nyeko0eelB4fr2ITYdT4hclwX6IUPZHQOhih6tmcfhAcILn8IiBXw5H8XWXBtEOOVAWH8HnDo0NagtSqlou3Qvm5H(uMaPl6cSd9PUYwqQ2g)hQihQ7masAId9Pew6ae(H(mrRoKQhuu0o0IFivLSn2kBhYiWHKH4qrDOnBbySd1xc2HWlYH(S5szI)5gWV3Mk2kBCvvcw5oBpl5jSSVe)AFX60htU4sOAK18faVf6zHL5MosPxvLGvUtUrK)1fUo6bndmgNaY2MToEKoP0RQsWk3jNzek0bXYgErKTyRKtazBZwNokgnA(y44CMrOqhelB4fr2ITso2mDsPFkcwc4fXb4mWyIfAHwvRGgTPctazWnI8VUW1rpOzMCcmA0uvYW2GRQKAPSyRux46Oh0mWyCILu05J0DV7(d59NQd9HyD6Jd5EJ(d9zZLYe)Zn4ql(HIE4qQQeSYDEOc)qF2CPmX)Cdo02oKOCFiilmNE(H(0GlGTeODOpbmMyHwCOUvRyYd1TkPwkl2kpuHFOOho0Nag7qwYo0NrK)puHFOOho0NyYjWouuoq0de(92uXwzJRQsWk3z7zjpHL9L4x7lwN(yYfxcvJSMVa4TqplSm30rk9QQeSYDYnI8VUW1rpOzGX4eq22S1XJ0OXal61uKRtFWzBZ8fG2QGrNucwc4fXb4mWyIfAHwvRqAycidUrK)1fUo6bnZKtGjvvjdBdUQsQLYITsDHRJEqZaJXjwsrhsEuQQkbRCNCBUuM4FUbCciBB260vsPxvLGvUtoZiuOdILn8IiBXwjNaY2MToDumA08XWX5mJqHoiw2WlISfBLCSz6U3Mk2kBCvvcw5oBpl5jSSVe)AFX60htU4smvSubnKG8cToKqP7TPITYgxvLGvUZ2ZsEIzek0bXYgErKTyRCYfxcvJSMVa4TqplSm30rk9Sk4yzFj(1(I1Pp0Sk4eq22SrJ2uHjGm4yzFj(1(I1PpO7EBQyRSXvvjyL7S9SKNygHcDqSSHxezl2kNCXLyQyPcAib5fADiHs3BtfBLnUQkbRCNTNL8Knxkt8p3GjxCjMkwQGgsqEHMKxszGpgoohhAbq20r7UWsgVfMIIoK8aPHjGm4yzFj(1(I1PpKgMaYGBe5FDHRJEqZm5eysjyjGxehGZaJjwOfAvTcPQkzyBWvvsTuwSvQlCD0dAgymoXsk6qYJszvWXY(s8R9fRtFOzvWjGSTz7EBQyRSXvvjyL7S9SKNS5szI)5gm5IlXuXsf0qcYl0K8skd8XWX54qlaYMoA3fwY4TWuu0HKhinmbKbhl7lXV2xSo9HuwfCSSVe)AFX60hAwfCciBB2KovycidUrK)1fUo6bnZKtGjvvjdBdUQsQLYITsDHRJEqZaJXjwsrNpEVnvSv24QQeSYD2EwYt2CPmX)CdMCXLyQyPcAib5fAsEjLb(y44CCOfazthT7clz8wykk6qYdKs)uHjGm4yzFj(1(I1PpOrlmbKb3iY)6cxh9GMzYjWKs)ueSeWlIdWzGXel0cTQwbnAQkzyBWvvsTuwSvQlCD0dAgymoXsk68r6OrBQWeqgCJi)RlCD0dAMjNatQQsg2gCvLulLfBL6cxh9GMbgJtSKIoK8iD3BtfBLnUQkbRCNTNL8Knxkt8p3Gjv)kbOdJ4artYRjxCjMkwQGgsqEHwhsOKug4JHJZXHwaKnD0UlSKXBHPOOdjpq6umWIETLmndu2ppwffB6CVnvSv24QQeSYD2EwYtnmz5k1ogXP(fWKlUecwUk9C5giCgGVQn681dKsVQkbRCNCSSVe)AFX60hCciBB268LRPrJvbhl7lXV2xSo9HMvbNaY2Mn6U3Mk2kBCvvcw5oBpl5jSSVe)AR1mmrm5IlHQrwZxa8wONfwMB6iLb(y44CCOfazthT7clz8wykk6KssPFgcUnxkTtFHj4MkwQanAQkzyBWvvsTuwSvQlCD0dAgymP(y44CMrOqhelB4fr2ITso2S0PMHGBe5FTtFHj4MkwQaD3BtfBLnUQkbRCNTNL8ew2xIFT1AgMiMu9ReGomIdenjVMCXLyQyPcAib5fADiHsszGpgoohhAbq20r7UWsgVfMIIoP092uXwzJRQsWk3z7zjp1kmHMa2mqMu9ReGomIdenjVMCXLegXbcESYGok9Sk0U6XoFuAyehi4Xkd6O0Sf64X7TPITYgxvLGvUZ2ZsEIyBd0mWytU4sMAgcUtFHj4MkwQW92uXwzJRQsWk3z7zjp1mfzXx1Ac9SPIjxCjMkwQGgsqEHwhsOK0P8XWX5mJqHoiw2WlISfBLCSzPtPQsWk3jNzek0bXYgErKTyRKtaJ9FVV3D)H6wrfslJd9z(RyJfA3BtfBLnUQOcPLrtsZTrK30rlVTyYfxcvJSMVa4TqplSm30rkblxLEUCdeodWx1gD86HU3D)H8G4qrDiSgCidpaYHS5sDOTDOkpu3(KdzTdf1HMjaviJdvubIYMN305qFAxehYD)kGd1Gi205qyZhQBFY3292uXwzJRkQqAz0EwYtn3grEthT82IjxCjQQeSYDYT5szI)5gWjGSTztk9MkwQGgsqEHwhsOKutflvqdjiVqRtjpkLGLRspxUbcNb4RAJoE56NP3uXsf0qcYl0Cr(q0rJMPILkOHeKxO1XJsjy5Q0ZLBGWza(Q2OJh4A6U3Mk2kBCvrfslJ2ZsEY8l5nTyRulwz)jxCjunYA(cG3c9SWYCthPt1kmH)MmUamM2)xdU0KNfGuvvcw5o52CPmX)Cd4eq22SjLGLapwzqhL(bDqVRE2hdhNtWYvPvfHGnhBLCciBB2O7EBQyRSXvfviTmApl5jZVK30ITsTyL9NCXLq1iR5laEl0ZclZnDK2kmH)MmUamM2)xdU0KNfGu6vvjyL7KJL9L4x7lwN(GtazBZgnAtfMaYGJL9L4x7lwN(qQQkbRCNCMrOqhelB4fr2ITsobKTnB0DVnvSv24QIkKwgTNL8K5xYBAXwPwSY(tU4smvSubnKG8cToKqjPeSe4Xkd6O0pOd6D1Z(y44CcwUkTQieS5yRKtazBZgD3BtfBLnUQOcPLr7zjp16nffcqh9GglDxKO)FYfxcvJSMVa4TqplSm30rQQkbRCNCBUuM4FUbCciBB2U3Mk2kBCvrfslJ2ZsEQ1BkkeGo6bnw6Uir))KlUetflvqdjiVqRdjusk9mWIETLmndu2ppwffB6qJgXwMgOczWngRXjGSTzRtjVEaD377D3FiVnDeWHMWioqCVnvSv24oqcKvjHbw0Rv1kMCXL4JHJZBymgKAwvYCcyQq6uunYA(cGpxLythnEr0ogXP(fanAZqWDmIt9laUPILkCVnvSv24oqcKv9SKNyGf9AvTIjxCjeSCv65Ynq4maFvB05lxjDkQgznFbWNRsSPJgViAhJ4u)c4EBQyRSXDGeiR6zjpz5VMLSjxCjQQeSYDYT5szI)5gWjGSTztk9HjGm4maFfahsZxamA0ufviTm4560hACdOrJGLaErCa(CpyKsUsOr392uXwzJ7ajqw1ZsEYDHLmDBgsgqMCXLWaFmCCoo0cGSPJ2DHLmElmffD8G7TPITYg3bsGSQNL8K7clz62mKmGm5IlHb(y44CCOfazthT7clzCSzPQQeSYDYT5szI)5gWjGSTzRJhLs)uHjGm4yzFj(1(I1PpOrlmbKb3iY)6cxh9GMzYjWKQQKHTbxvj1szXwPUW1rpOzGX4elPOZhPrBQWeqgCJi)RlCD0dAMjNatQQsg2gCvLulLfBL6cxh9GMbgJtSKIoK8inAtPQKHTbxvj1szXwPUW1rpOzGXO7EBQyRSXDGeiR6zjp5UWsMUndjditU4syGpgoohhAbq20r7UWsghBwAycidow2xIFTVyD6dP0pvycidUrK)1fUo6bnZKtGjvvjdBdUQsQLYITsDHRJEqZaJXjwsrNpsJwycidUrK)1fUo6bnZKtGjvvjdBdUQsQLYITsDHRJEqZaJXjwsrhsEKoP0RQsWk3jhl7lXV2xSo9bNaY2MToE5APtXQGJL9L4x7lwN(qZQGtazBZgnAQQeSYDYT5szI)5gWjGSTzRJxUMU7TPITYg3bsGSQNL8edSOxRQvm5IlHGLRspxUbcNb4RAJoPKRLofvJSMVa4Zvj20rJxeTJrCQFbCVnvSv24oqcKv9SKNWHwaKnD0TGSuatU4syGpgoohhAbq20r7UWsgVfMIIoFDVnvSv24oqcKv9SKNWHwaKnD0TGSuatU4syGpgoohhAbq20r7UWsgVfMIIoFGuvvcw5o52CPmX)Cd4eq22S15JsPFQWeqgCSSVe)AFX60h0OfMaYGBe5FDHRJEqZm5eysvvYW2GRQKAPSyRux46Oh0mWyCILu05J0OnvycidUrK)1fUo6bnZKtGjvvjdBdUQsQLYITsDHRJEqZaJXjwsrhsEKgTPuvYW2GRQKAPSyRux46Oh0mWy0DVnvSv24oqcKv9SKNWHwaKnD0TGSuatU4syGpgoohhAbq20r7UWsgVfMIIoFG0WeqgCSSVe)AFX60hsPFQWeqgCJi)RlCD0dAMjNatQQsg2gCvLulLfBL6cxh9GMbgJtSKIoFKgTWeqgCJi)RlCD0dAMjNatQQsg2gCvLulLfBL6cxh9GMbgJtSKIoK8iDsPxvLGvUtow2xIFTVyD6dobKTnBD(Y10OPQsWk3j3MlLj(NBaNaY2MToF5APSk4yzFj(1(I1Pp0Sk4eq22Sr392uXwzJ7ajqw1ZsEIbw0Rv1kMCXLmfvJSMVa4Zvj20rJxeTJrCQFbCVV3Mk2kBChibYQ0wbsyGf9AvTIjxCj(y44CMrOqhelB4fr2ITso2Sucwc4fXb4mWyIfAHwvRqQPILkOHeKxO1PexDV7(d5Idjqw1H(SQ78qUiiBr24)EBQyRSXDGeiRsBf8SKNG5LbYRAYfxIpgooVHXyqQzvjZjGPI7TPITYg3bsGSkTvWZsEcMxgiVQjxCjtr1iR5la(CvInD04fr7yeN6xa3BtfBLnUdKazvARGNL8K7clz62mKmGmP6xjaDyehiAsEn5IlHEvvcw5o52CPmX)Cd4eq22S1XJszGpgoohhAbq20r7UWsghBMgng4JHJZXHwaKnD0UlSKXBHPOOJhqNu6XxN(qtazBZwNQQeSYDYzGf9AlzAgOSFobKTnBp)Y10OHVo9HMaY2MTouvjyL7KBZLYe)ZnGtazBZgD3BtfBLnUdKazvARGNL8eo0cGSPJUfKLcys1Vsa6Wioq0K8AYfxcd8XWX54qlaYMoA3fwY4TWuu0PexjvvLGvUtUnxkt8p3aobKTnBD6kA0yGpgoohhAbq20r7UWsgVfMIIoFDVnvSv24oqcKvPTcEwYt4qlaYMo6wqwkGjv)kbOdJ4artYRjxCjQQeSYDYT5szI)5gWjGSTzRJhLYaFmCCoo0cGSPJ2DHLmElmffD(AeJyma]] )

end
