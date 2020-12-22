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


    spec:RegisterPack( "Unholy", 20201222, [[d8uA8bqiLs9ivjXLiuPSjQKpPk1OqQ6uivwfHkrVsvHzPuyxO6xkv1WOsPJPuzzkv5zuPyAQsQRPkX2Osv(MQKuJJkvvNtvsY6ukX8iuUhHSpjjheuPSqvf9qQuzIGkXfPsvXgbvsKpsOs1ibvsuNeuPYkvv6LGkvXmvkPBcQKKDkj1pbvsQHcQuvlfuj1tPQMQsrxfujHTcQuL(kvQknwqf7vj)LKbdCyklMQ8ysnzuUm0MrYNPIrlPoTIvtOs41GQMnr3MGDl63snCvXXjuXYr8CjMUW1bz7iLVljgpHQopOSEcvsZxv1(v51U1MlFMf4Q69C7EUD3E7TJ7w3)lU1TUz5hWEWL)JPH3CWLFAc4YhUISULWw(pgmzBS1Ml)sdr04YVoINYw2FFNjQH846wy)YiajTy6utmQy)YiO3F57bnYaUlxElFMf4Q69C7EUD3E7TJ7w3)RFv75(x(LhuVQEVx2B5xpmgMlVLpdl6L)RCa4cAr9bG7jhN64aWvK1Te299voaCb1OGhsoWEUDJdSNB3ZT3377RCa4gtCbujeWmkhi6daxs4Y(WfKAK4(Wf0I6YbGlq4bI(aDkHDaDdLXbcJ4Gr5avQ7dye8aO4FqDGSde9bKdn8aYoDoaMnKt9bI(acwei5a0BnQkya9CGxzhD8LVCkrzT5Y3AuvWa6zT5Q6DRnx(yAEsKT(C5RjtGKXw(m0IAf854uhCQknuYqMkmIdgLduLOdOHPLOctuyWYb()paXgMcPHzWngRWrXpLOCaxhGydtH0Wm4gJv4euWMSCaXeDGD7w(MoMox(wctXs2kwvV3AZLpMMNezRpx(AYeizSLpdTOwbFoo1bNQsdLmKPcJ4Gr5avj6aVS8nDmDU8TeMILSvSQ2nRnx(yAEsKT(C5RjtGKXw(EquuCMrGxfellunrWIPto0ZbCDacuIunXb5m0yYblHs3JKJP5jr2bCDathdnuHjkmy5aIj6aUz5B6y6C5ZqlQv6EKRyv9RxBU8X08KiB95YxtMajJT83(a0mYyEsK)0TCshfvtuogXPHjXLVPJPZLp(mmuy0Ryv9lRnx(yAEsKT(C5RjtGKXw(m0dIIItHLajt6OQ0qjJxctd)bet0bCZbCDaD3swxj52tRnjSNcYjOGnz5aIDa3S8nDmDU8PWsGKjDuLGmWJlFnmTevHrCWOSQE3kwv7ERnx(yAEsKT(C5RjtGKXw(m0dIIItHLajt6OQ0qjJxctd)be7a7w(MoMox(uyjqYKoQsqg4XLVgMwIQWioyuwvVBfRQF1Rnx(yAEsKT(C5RjtGKXw(eOe5XiGQOvV(aIDa6pGUBjRRKCgArTYsMIHAdgNGc2KLd46aBFGWKygCgsnsKJP5jr2b()pGUBjRRKCgsnsKtqbBYYbCDGWKygCgsnsKJP5jr2bOB5B6y6C5tHLajt6OkbzGhx(AyAjQcJ4Grzv9UvSILVdMiz0RnxvVBT5YhtZtIS1NlFnzcKm2Y3dIIIxGymmvSUf4e00XbCDGTpanJmMNe5pDlN0rr1eLJrCAys8a))h4bdUJrCAysKB6yOHlFthtNlFgArTs3JCfRQ3BT5YhtZtIS1NlFnzcKm2YNaLJw90vqcNHuJEIdi2b25Md46aBFaAgzmpjYF6woPJIQjkhJ40WK4Y30X05YNHwuR09ixXQA3S2C5JP5jr26ZLVMmbsgB5R7wY6kj3EATjH9uqobfSjlhW1bO)aHjXm4mKAKihtZtISd8)FaDtdtldEoo1HIYWd8)FacuIunXb5p1OrAHoXchtZtISdq3Y30X05Y3sykwYwXQ6xV2C5JP5jr26ZLVMmbsgB5ZqpikkofwcKmPJQsdLmEjmn8hOQd86LVPJPZLFLgkzQYdMmKSIv1VS2C5JP5jr26ZLVMmbsgB5ZqpikkofwcKmPJQsdLmo0ZbCDaD3swxj52tRnjSNcYjOGnz5avDGxoGRdq)b2(aHjXm4qzDlHP8KJtDWX08Ki7a))himjMb3icWunLkQrfZesKXX08Ki7aUoGUtg0eCDN0ATftNQMsf1OIHgJtSe(di2bE5a))hy7deMeZGBebyQMsf1OIzcjY4yAEsKDaxhq3jdAcUUtAT2IPtvtPIAuXqJXjwc)bQs0bE5a))hy7dO7Kbnbx3jTwBX0PQPurnQyOX4yAEsKDa6w(MoMox(vAOKPkpyYqYkwv7ERnx(yAEsKT(C5RjtGKXw(m0dIIItHLajt6OQ0qjJd9CaxhimjMbhkRBjmLNCCQdoMMNezhW1bO)aBFGWKygCJiat1uQOgvmtirghtZtISd46a6ozqtW1DsR1wmDQAkvuJkgAmoXs4pGyh4Ld8)FGWKygCJiat1uQOgvmtirghtZtISd46a6ozqtW1DsR1wmDQAkvuJkgAmoXs4pqvIoWlhGUd46a0FaD3swxj5qzDlHP8KJtDWjOGnz5avDGDU9aUoW2hG1bhkRBjmLNCCQdfRdobfSjlh4))a6ULSUsYTNwBsypfKtqbBYYbQ6a7C7bOB5B6y6C5xPHsMQ8GjdjRyv9RET5YhtZtIS1NlFnzcKm2YNaLJw90vqcNHuJEIdi2b2ZThW1b2(a0mYyEsK)0TCshfvtuogXPHjXLVPJPZLpdTOwP7rUIv1U)1MlFmnpjYwFU81KjqYylFg6brrXPWsGKjDuvAOKXlHPH)aIDGDlFthtNlFkSeizshvjid84kwv)QwBU8X08KiB95YxtMajJT8zOheffNclbsM0rvPHsgVeMg(di2bE9bCDaD3swxj52tRnjSNcYjOGnz5aIDGxoGRdq)b2(aHjXm4qzDlHP8KJtDWX08Ki7a))himjMb3icWunLkQrfZesKXX08Ki7aUoGUtg0eCDN0ATftNQMsf1OIHgJtSe(di2bE5a))hy7deMeZGBebyQMsf1OIzcjY4yAEsKDaxhq3jdAcUUtAT2IPtvtPIAuXqJXjwc)bQs0bE5a))hy7dO7Kbnbx3jTwBX0PQPurnQyOX4yAEsKDa6w(MoMox(uyjqYKoQsqg4XvSQENBxBU8X08KiB95YxtMajJT8zOheffNclbsM0rvPHsgVeMg(di2bE9bCDGWKygCOSULWuEYXPo4yAEsKDaxhG(dS9bctIzWnIamvtPIAuXmHezCmnpjYoGRdO7Kbnbx3jTwBX0PQPurnQyOX4elH)aIDGxoW))bctIzWnIamvtPIAuXmHezCmnpjYoGRdO7Kbnbx3jTwBX0PQPurnQyOX4elH)avj6aVCa6oGRdq)b0DlzDLKdL1TeMYtoo1bNGc2KLdi2b252d8)FaD3swxj52tRnjSNcYjOGnz5aIDGDU9aUoaRdouw3sykp54uhkwhCckytwoaDlFthtNlFkSeizshvjid84kwvVB3AZLpMMNezRpx(AYeizSL)2hGMrgZtI8NULt6OOAIYXionmjU8nDmDU8zOf1kDpYvSILpdPmizS2Cv9U1MlFthtNlFHjzkkcIIR4YhtZtIS1NRyv9ERnx(yAEsKT(C53pl)cglFthtNlFAgzmpjU8PzsiC5R7wY6kjVaji0PYXionmjYjOGnz5aIDGxoGRdeMeZGxGee6u5yeNgMe5yAEsKT8PzevAc4Y)PB5KokQMOCmItdtIRyvTBwBU8X08KiB95YVFw(fmw(MoMox(0mYyEsC5tZKq4Y30XqdvyIcdwoGOdS7aUoa9hy7dqSHPqAygCJXkCu8tjkh4))aeBykKgMb3yScFYdu1b29YbOB5tZiQ0eWLFjupslZjDwXQ6xV2C5JP5jr26ZLVMmbsgB5tGYrRE6kiHZqQrpXbQ6aU3lhW1bO)apyWDmItdtICthdn8a))hy7deMeZGxGee6u5yeNgMe5yAEsKDa6oGRdqGsKZqQrpXbQs0bEz5B6y6C5BeTLOkAcbZyfRQFzT5YhtZtIS1NlFnzcKm2Y)bdUJrCAysKB6yOHh4))aEquuCOSULWuwPyqYGd9CG))deMeZGBebyQMsf1OIzcjY4yAEsKDaxh4bdU90ALtDdj5MogA4bCDa6pWdgCJiat5u3qsUPJHgEG))dO7wY6kj3icWunLkQrfdngNGc2KLdu1b0DlzDLK7j7MPOGiW4miIftNhy)d4Mdq3b()pa14uhkckytwoGyIoGheff3t2ntrbrGXzqelMox(MoMox(EYUzkkicSvSQ29wBU8X08KiB95YxtMajJT8FWG7yeNgMe5MogA4b()pGheffhkRBjmLvkgKm4qph4))aHjXm4graMQPurnQyMqImoMMNezhW1bEWGBpTw5u3qsUPJHgEaxhG(d8Gb3icWuo1nKKB6yOHh4))a6ULSUsYnIamvtPIAuXqJXjOGnz5avDaD3swxj5EiPGe4N0HZGiwmDEG9pGBoaDh4))auJtDOiOGnz5aIj6aEquuCpKuqc8t6WzqelMox(MoMox(EiPGe4N0zfRQF1Rnx(yAEsKT(C5RjtGKXw(EquuCOSULWuLGGPtuZHEw(MoMox(YXPokkXfqmhbmJvSQ29V2C5JP5jr26ZLVMmbsgB5)Gb3XionmjYnDm0Wd8)Fapikkouw3sykRumizWHEoW))bctIzWnIamvtPIAuXmHezCmnpjYoGRd8Gb3EATYPUHKCthdn8aUoa9h4bdUreGPCQBij30XqdpW))b0DlzDLKBebyQMsf1OIHgJtqbBYYbQ6a6ULSUsYTuJLGysL2KsodIyX05b2)aU5a0DG))dqno1HIGc2KLdiMOdS7LLVPJPZLVLASeetQ0MuUIv1VQ1MlFmnpjYwFU81KjqYylFthdnuHjkmy5avj6a7DG))dq)biqjYzi1ON4avj6aVCaxhGaLJw90vqcNHuJEIduLOd4EU9a0T8nDmDU8nI2su9ajl4kwvVZTRnx(yAEsKT(C5RjtGKXw(pyWDmItdtICthdn8a))hWdIIIdL1TeMYkfdsgCONd8)FGWKygCJiat1uQOgvmtirghtZtISd46apyWTNwRCQBij30XqdpGRdq)bEWGBebykN6gsYnDm0Wd8)FaD3swxj5graMQPurnQyOX4euWMSCGQoGUBjRRKCQHGEYUzCgeXIPZdS)bCZbO7a))hGACQdfbfSjlhqmrhWdIIItne0t2nJZGiwmDU8nDmDU8Pgc6j7MTIv172T2C5JP5jr26ZLVMmbsgB57brrXHY6wctvccMornh65aUoGPJHgQWefgSCarhy3Y30X05Y3ZCunLkiJg(YkwvVBV1MlFmnpjYwFU81KjqYylFwhCAdbsIzOEKMdeYjifbl1MNepGRdS9bctIzWHY6wct5jhN6GJP5jr2bCDGTpaXgMcPHzWngRWrXpLOS8nDmDU8BOWJGg8Ryv9o3S2C5JP5jr26ZLVMmbsgB5Z6GtBiqsmd1J0CGqobPiyP28K4bCDathdnuHjkmy5avj6a7DaxhG(dS9bctIzWHY6wct5jhN6GJP5jr2b()pqysmdouw3sykp54uhCmnpjYoGRdO7wY6kjhkRBjmLNCCQdobfSjlhGULVPJPZLFdfEe0GFfRQ3961MlFmnpjYwFU81KjqYylFcuIunXb5fOhKucInjhtZtISd46a0FawhCksxcffsdjCcsrWsT5jXd8)FawhCpz3m1J0CGqobPiyP28K4bOB5B6y6C53qHhbn4xXQ6DVS2C5JP5jr26ZLVPJPZLV2KsLPJPtLCkXYxoLqLMaU81nnmTmkRyv9o3BT5YhtZtIS1NlFthtNlFTjLkthtNk5uILVCkHknbC5R7wY6kzzfRQ39QxBU8X08KiB95Y30X05YNaLkthtNk5uILVMmbsgB5B6yOHkmrHblhOkrhyVd46a0FaD3swxj5m0IALLmfd1gmobfSjlhqSdSZThW1b2(aHjXm4mKAKihtZtISd8)FaD3swxj5mKAKiNGc2KLdi2b252d46aHjXm4mKAKihtZtISdq3bCDGTpadTOwzjtXqTbJhJg(jDw(YPeQ0eWLV1OQGb0ZkwvVZ9V2C5JP5jr26ZLVPJPZLpbkvMoMovYPelFnzcKm2Y30XqdvyIcdwoqvIoWEhW1byOf1klzkgQny8y0WpPZYxoLqLMaU8TgvEqKsSIv17EvRnx(yAEsKT(C5B6y6C5tGsLPJPtLCkXYxtMajJT8nDm0qfMOWGLduLOdS3bCDa6pW2hGHwuRSKPyO2GXJrd)KohW1bO)a6ULSUsYzOf1klzkgQnyCckytwoqvhyNBpGRdS9bctIzWzi1iroMMNezh4))a6ULSUsYzi1irobfSjlhOQdSZThW1bctIzWzi1iroMMNezhGUdq3YxoLqLMaU8DWejJwznUIv17521MlFmnpjYwFU8nDmDU81MuQmDmDQKtjw(AYeizSLVPJHgQWefgSCarhy3YxoLqLMaU8DWejJEfRy5)qqDl4zXAZv17wBU8nDmDU8F6y6C5JP5jr26ZvSQEV1MlFmnpjYwFU8ttax(M4AP2iwrr1zOAk1txbjlFthtNlFtCTuBeROO6munL6PRGKvSQ2nRnx(MoMox(eBkOIHgB5JP5jr26ZvSILVUBjRRKL1MRQ3T2C5JP5jr26ZLVMmbsgB5)Gb3XionmjYnDm0Wd8)Fapikkouw3sykRumizWHEoW))bctIzWnIamvtPIAuXmHezCmnpjYoGRdq)bEWGBebykN6gsYnDm0Wd8)FGhm42tRvo1nKKB6yOHh4))a6ULSUsYnIamvtPIAuXqJXjOGnz5avDGWioyWJravrRydEa6oW))bOgN6qrqbBYYbe7a75ElFthtNl)NoMoxXQ69wBU8X08KiB95YpnbC5pzrtGcZtIkXbYYasqXqAJgx(MoMox(tw0eOW8KOsCGSmGeumK2OXLVMmbsgB5t)b0DlzDLKdL1TeMYtoo1bNGc2KLd8)FaD3swxj5mJaVkiwwOAIGftNCckytwoaDhW1bO)apyWnIamLtDdj5MogA4b()pWdgC7P1kN6gsYnDm0Wd46aBFGWKygCJiat1uQOgvmtirghtZtISd8)FGWioyWJravrRE0HAp3EaXoWlhGUd8)FaQXPoueuWMSCaXoWE7wXQA3S2C5JP5jr26ZLFAc4YxW0MhbvLAedLauz0lFthtNlFbtBEeuvQrmucqLrV81KjqYylFD3swxj52tRnjSNcYjOGnz5aIDGxoGRdq)b2(aO4anppiJpzrtGcZtIkXbYYasqXqAJgpW))b0DlzDLKpzrtGcZtIkXbYYasqXqAJg5euWMSCa6oW))bOgN6qrqbBYYbe7a7TBfRQF9AZLpMMNezRpx(PjGlFgbng1qqfnSuq5Y30X05YNrqJrneurdlfuU81KjqYylFD3swxj52tRnjSNcYjOGnz5aUoa9hy7dGId088Gm(KfnbkmpjQehildibfdPnA8a))hq3TK1vs(KfnbkmpjQehildibfdPnAKtqbBYYbO7a))hGACQdfbfSjlhqSd4MvSQ(L1MlFmnpjYwFU8ttax(mJaVq3PIHA4v0AIPNa2Y30X05YNze4f6ovmudVIwtm9eWw(AYeizSLVUBjRRKC7P1Me2tb5euWMSCaxhG(dS9bqXbAEEqgFYIMafMNevIdKLbKGIH0gnEG))dO7wY6kjFYIMafMNevIdKLbKGIH0gnYjOGnz5a0DG))dqno1HIGc2KLdi2b2B3kwv7ERnx(yAEsKT(C5RjtGKXw(6ULSUsYTNwBsypfKtqbBYYbCDa6pW2hafhO55bz8jlAcuyEsujoqwgqckgsB04b()pGUBjRRK8jlAcuyEsujoqwgqckgsB0iNGc2KLdq3Y30X05YhQGQjqHYkwv)QxBU8X08KiB95YxtMajJT81DlzDLKdL1TeMYtoo1bNGc2KLdi2bCZbCDaD3swxj5mJaVkiwwOAIGftNCckytwoGyhWnhW1bctIzWHY6wct5jhN6GJP5jr2bCDGTpqPHKEtY4s0ykpyku8MWJe5yAEsKDG))dS9bctIzWHY6wct5jhN6GJP5jr2b()pa14uhkckytwoGyhWnVS8nDmDU8nIamvtPIAuXqJTIv1U)1MlFmnpjYwFU81KjqYylFD3swxj5qzDlHP8KJtDWjOGnz5aIDa3Caxhq3TK1vsU51ctAX0PsocECcAmyhW1bknK0BsgxIgt5btHI3eEKihtZtISLVPJPZLVreGPAkvuJkgASvSQ(vT2C5JP5jr26ZLVMmbsgB5tZiJ5jrEjupslZjDoGRdq)b0DlzDLKZmc8QGyzHQjcwmDYjOGnz5aIDahn7a))hWdIIIZmc8QGyzHQjcwmDYHEoaDhW1bO)aBFacuIunXb5m0yYblHs3JKJP5jr2b()pW2himjMb3icWunLkQrfZesKXX08Ki7a))hq3jdAcUUtAT2IPtvtPIAuXqJXjwc)be7aVCa6w(MoMox(qzDlHP8KJtDSIv17C7AZLpMMNezRpx(AYeizSLpnJmMNe5Lq9iTmN05aUoabkrQM4GCgAm5GLqP7rYX08Ki7aUoqysmdUreGPAkvuJkMjKiJJP5jr2bCDaDNmOj46oP1AlMovnLkQrfdngNyj8hOkrh4Ld46a6ULSUsYTNwBsypfKtqbBYYbe7aU5aUoa9hq3TK1vsoZiWRcILfQMiyX0jNGc2KLdi2bC0Sd8)FapikkoZiWRcILfQMiyX0jh65a0T8nDmDU8HY6wct5jhN6yfRQ3TBT5YhtZtIS1NlFnzcKm2Y30XqdvyIcdwoqvIoWEh4))auJtDOiOGnz5aIDG92T8nDmDU8HY6wct5jhN6yfRQ3T3AZLpMMNezRpx(AYeizSLpnJmMNe5Lq9iTmN05aUoa9hG1bhkRBjmLNCCQdfRdobfSjlh4))aBFGWKygCOSULWuEYXPo4yAEsKDa6w(MoMox(mJaVkiwwOAIGftNRyv9o3S2C5JP5jr26ZLVMmbsgB5B6yOHkmrHblhOkrhyVd8)FaQXPoueuWMSCaXoWE7w(MoMox(mJaVkiwwOAIGftNRyv9UxV2C5JP5jr26ZLVMmbsgB5B6yOHkmrHblhq0b2DaxhGHEquuCkSeizshvLgkz8syA4pqvIoWRpGRdeMeZGdL1TeMYtoo1bhtZtISd46aHjXm4graMQPurnQyMqImoMMNezhW1biqjs1ehKZqJjhSekDpsoMMNezhW1b0DYGMGR7KwRTy6u1uQOgvm0yCILWFGQeDGxoGRdW6GdL1TeMYtoo1HI1bNGc2KLLVPJPZLV90Atc7PGRyv9UxwBU8X08KiB95YxtMajJT8nDm0qfMOWGLdi6a7oGRdWqpikkofwcKmPJQsdLmEjmn8hOkrh41hW1bctIzWHY6wct5jhN6GJP5jr2bCDawhCOSULWuEYXPouSo4euWMSCaxhy7deMeZGBebyQMsf1OIzcjY4yAEsKDaxhq3jdAcUUtAT2IPtvtPIAuXqJXjwc)be7aVS8nDmDU8TNwBsypfCfRQ35ERnx(yAEsKT(C5RjtGKXw(MogAOctuyWYbeDGDhW1byOheffNclbsM0rvPHsgVeMg(duLOd86d46a0FGTpqysmdouw3sykp54uhCmnpjYoW))bctIzWnIamvtPIAuXmHezCmnpjYoGRdq)b2(aeOePAIdYzOXKdwcLUhjhtZtISd8)FaDNmOj46oP1AlMovnLkQrfdngNyj8hqSd8YbO7a))hy7deMeZGBebyQMsf1OIzcjY4yAEsKDaxhq3jdAcUUtAT2IPtvtPIAuXqJXjwc)bQs0bE5a))hGACQdfbfSjlhqSdSZ9oaDlFthtNlF7P1Me2tbxXQ6DV61MlFmnpjYwFU81KjqYylFthdnuHjkmy5avj6a7DaxhGHEquuCkSeizshvLgkz8syA4pqvIoWRpGRdS9byOf1klzkgQny8y0WpPZY30X05Y3EATjH9uWLVgMwIQWioyuwvVBfRQ35(xBU8X08KiB95YxtMajJT8jq5OvpDfKWzi1ON4aIDGDV(aUoa9hq3TK1vsouw3sykp54uhCckytwoGyhyNBpW))byDWHY6wct5jhN6qX6GtqbBYYbOB5B6y6C5xGee6u5yeNgMexXQ6DVQ1MlFmnpjYwFU81KjqYylFAgzmpjYlH6rAzoPZbCDag6brrXPWsGKjDuvAOKXlHPH)aIDG9oGRdq)bEWGBpTw5u3qsUPJHgEG))dO7Kbnbx3jTwBX0PQPurnQyOX4yAEsKDaxhWdIIIZmc8QGyzHQjcwmDYHEoGRdS9bEWGBebykN6gsYnDm0Wdq3Y30X05YhkRBjmLvkgKmwXQ69C7AZLpMMNezRpx(AYeizSLVPJHgQWefgSCGQeDG9oGRdWqpikkofwcKmPJQsdLmEjmn8hqSdS3Y30X05YhkRBjmLvkgKmw(AyAjQcJ4Grzv9UvSQEVDRnx(yAEsKT(C5RjtGKXw(HrCWGhJaQIw9OdLBE5aIDGxoGRdegXbdEmcOkAfBWdu1bEz5B6y6C5xAiPIG2dsw(AyAjQcJ4Grzv9UvSQEV9wBU8X08KiB95YxtMajJT83(apyWDQBij30Xqdx(MoMox(eBkOIHgBfRQ3ZnRnx(yAEsKT(C5RjtGKXw(MogAOctuyWYbQs0b27aUoW2hWdIIIZmc8QGyzHQjcwmDYHEoGRdS9b0DlzDLKZmc8QGyzHQjcwmDYjOXGDG))dqno1HIGc2KLdi2bC0SLVPJPZLFX0KHA0JjvpMowXkw(oyIKrRSgxBUQE3AZLpMMNezRpx(AYeizSLVheffNze4vbXYcvteSy6Kd9CaxhGaLivtCqodnMCWsO09i5yAEsKDaxhW0XqdvyIcdwoGyIoGBw(MoMox(m0IALUh5kwvV3AZLpMMNezRpx(AYeizSLVheffVaXyyQyDlWjOPJLVPJPZLp(mmuy0RyvTBwBU8X08KiB95YxtMajJT83(a0mYyEsK)0TCshfvtuogXPHjXLVPJPZLp(mmuy0Ryv9RxBU8X08KiB95YxtMajJT8P)a6ULSUsYTNwBsypfKtqbBYYbQ6aVCaxhGHEquuCkSeizshvLgkzCONd8)Fag6brrXPWsGKjDuvAOKXlHPH)avDGxFa6oGRdq)bOgN6qrqbBYYbe7a6ULSUsYzOf1klzkgQnyCckytwoWhhyNBpW))bOgN6qrqbBYYbQ6a6ULSUsYTNwBsypfKtqbBYYbOB5B6y6C5xPHsMQ8GjdjlFnmTevHrCWOSQE3kwv)YAZLpMMNezRpx(AYeizSLpd9GOO4uyjqYKoQknuY4LW0WFaXeDa3Caxhq3TK1vsU90Atc7PGCckytwoGyhWnh4))am0dIIItHLajt6OQ0qjJxctd)be7a7w(MoMox(uyjqYKoQsqg4XLVgMwIQWioyuwvVBfRQDV1MlFmnpjYwFU81KjqYylFD3swxj52tRnjSNcYjOGnz5avDGxoGRdWqpikkofwcKmPJQsdLmEjmn8hqSdSB5B6y6C5tHLajt6OkbzGhx(AyAjQcJ4Grzv9UvSILV1OYdIuI1MRQ3T2C5JP5jr26ZLVMmbsgB57brrXzgbEvqSSq1eblMo5qphW1biqjs1ehKZqJjhSekDpsoMMNezhW1bmDm0qfMOWGLdiMOd4MLVPJPZLpdTOwP7rUIv17T2C5JP5jr26ZLVMmbsgB5tGYrRE6kiHZqQrpXbe7a0FGDU9aFCagArTc(CCQdovLgkzitfgXbJYbexEa3Ca6oGRdWqlQvWNJtDWPQ0qjdzQWioyuoGyhW9oGRdS9bOzKX8Ki)PB5KokQMOCmItdtIh4))aEquu8sfJimPJsykbh6z5B6y6C5Jpddfg9kwv7M1MlFmnpjYwFU81KjqYylFcuoA1txbjCgsn6joGyhyVxoGRdWqlQvWNJtDWPQ0qjdzQWioyuoqvh4Ld46aBFaAgzmpjYF6woPJIQjkhJ40WK4Y30X05YhFggkm6vSQ(1Rnx(yAEsKT(C5RjtGKXw(BFagArTc(CCQdovLgkzitfgXbJYbCDGTpanJmMNe5pDlN0rr1eLJrCAys8a))hGACQdfbfSjlhqSd8Yb()paXgMcPHzWngRWrXpLOCaxhGydtH0Wm4gJv4euWMSCaXoWllFthtNlF8zyOWOxXQ6xwBU8nDmDU8R0qjtvEWKHKLpMMNezRpxXQA3BT5YhtZtIS1NlFnzcKm2YF7dqZiJ5jr(t3YjDuunr5yeNgMex(MoMox(4ZWqHrVIvS81nnmTmkRnxvVBT5YhtZtIS1NlFnzcKm2YNMrgZtI8sOEKwMt6CaxhGaLJw90vqcNHuJEIdu1b25Eh4))auJtDOiOGnz5aIDGD7w(MoMox(LkgryshLWuIvSQEV1MlFmnpjYwFU81KjqYylFD3swxj52tRnjSNcYjOGnz5aUoa9hW0XqdvyIcdwoqvIoWEhW1bmDm0qfMOWGLdiMOd8YbCDacuoA1txbjCgsn6joqvhyNBpWhhG(dy6yOHkmrHblhqC5bCVdq3b()pGPJHgQWefgSCGQoWlhW1biq5OvpDfKWzi1ON4avDGx72dq3Y30X05YVuXict6OeMsSIv1UzT5YhtZtIS1NlFnzcKm2YNMrgZtI8sOEKwMt6Caxhy7duAiP3KmUenMYdMcfVj8iroMMNezhW1b0DlzDLKBpT2KWEkiNGc2KLd46aeOe5XiGQOvV(avDa6pGBoWhhWdIIItGYrR0nHa9etNCckytwoaDh4))auJtDOiOGnz5aIDG92T8nDmDU8nVwyslMovYrWBfRQF9AZLpMMNezRpx(AYeizSLpnJmMNe5Lq9iTmN05aUoqPHKEtY4s0ykpyku8MWJe5yAEsKDaxhG(dW6GdL1TeMYtoo1HI1bNGc2KLdu1b2T7a))hy7deMeZGdL1TeMYtoo1bhtZtISd46a6ULSUsYzgbEvqSSq1eblMo5euWMSCa6w(MoMox(MxlmPftNk5i4TIv1VS2C5JP5jr26ZLVMmbsgB5B6yOHkmrHblhOkrhyVd46aeOe5XiGQOvV(avDa6pGBoWhhWdIIItGYrR0nHa9etNCckytwoaDlFthtNlFZRfM0IPtLCe8wXQA3BT5YhtZtIS1NlFnzcKm2YNMrgZtI8sOEKwMt6Caxhq3TK1vsU90Atc7PGCckytwoW))bOgN6qrqbBYYbe7a7Ez5B6y6C5xQnn8suf1OckR0KOg2kwv)QxBU8X08KiB95YxtMajJT8nDm0qfMOWGLduLOdS3bCDa6padTOwzjtXqTbJhJg(jDoW))bi2WuinmdUXyfobfSjlhqmrhy3RpaDlFthtNl)sTPHxIQOgvqzLMe1WwXkwXYNgsktNRQ3ZT752D7TZ9w(vmsoPtz57(c3GRRgURAX9TCGdSznEGr4PjXbOAYbE7Gjsg97dqqXbAii7aLwapGbfTGfi7a6AlDWc)(U1jXd4MTCa31jnKei7aVjqjs1ehKdN3hi6d8MaLivtCqoC4yAEsK9(a0Vt80XVVBDs8aVSLd4UoPHKazh4DysmdoCEFGOpW7WKygC4WX08Ki79bO3nINo(9DRtIh4LTCa31jnKei7aV1DYGMGdN3hi6d8w3jdAcoC4yAEsK9(a0Vt80XVVBDs8aU3woG76KgscKDG3HjXm4W59bI(aVdtIzWHdhtZtIS3hGE3iE6433TojEGx1woG76KgscKDG3HjXm4W59bI(aVdtIzWHdhtZtIS3hGE3iE6433TojEGx1woG76KgscKDG36ozqtWHZ7de9bER7KbnbhoCmnpjYEFa63jE6433TojEGDUDlhWDDsdjbYoW7WKygC48(arFG3HjXm4WHJP5jr27dqVBepD877919fUbxxnCx1I7B5ahyZA8aJWttIdq1Kd82AuvWa659biO4aneKDGslGhWGIwWcKDaDTLoyHFF36K4bCZwoG76KgscKDG3eOePAIdYHZ7de9bEtGsKQjoihoCmnpjYEFa63jE6433TojEGx9woG76KgscKDG3HjXm4W59bI(aVdtIzWHdhtZtIS3hG(9epD877919fUbxxnCx1I7B5ahyZA8aJWttIdq1Kd8MHugKmEFackoqdbzhO0c4bmOOfSazhqxBPdw433TojEG92YbCxN0qsGSd8omjMbhoVpq0h4DysmdoC4yAEsK9(awCa3h4Q36bOFN4PJFF36K4bEzlhWDDsdjbYoG)i4UduGLHj(diUDGOpWwHSdWgAtz68a9dsSOjhG(9P7a0Vt80XVVBDs8aVSLd4UoPHKazh4DysmdoCEFGOpW7WKygC4WX08Ki79bOFN4PJFF36K4bCVTCa31jnKei7a(JG7oqbwgM4pG42bI(aBfYoaBOnLPZd0piXIMCa63NUdq)oXth)(U1jXd4EB5aURtAijq2bEhMeZGdN3hi6d8omjMbhoCmnpjYEFa63jE6433TojEa3)woG76KgscKDa)rWDhOaldt8hqC7arFGTczhGn0MY05b6hKyrtoa97t3bOFN4PJFF36K4bC)B5aURtAijq2bEhMeZGdN3hi6d8omjMbhoCmnpjYEFa63jE6433TojEGDUDlhWDDsdjbYoG)i4UduGLHj(diUDGOpWwHSdWgAtz68a9dsSOjhG(9P7a0Vt80XVVBDs8a7C7woG76KgscKDG3HjXm4W59bI(aVdtIzWHdhtZtIS3hG(DINo(9DRtIhy3EB5aURtAijq2bEhMeZGdN3hi6d8omjMbhoCmnpjYEFa63jE6433TojEGDUzlhWDDsdjbYoW7WKygC48(arFG3HjXm4WHJP5jr27dq)EINo(9DRtIhy3R3YbCxN0qsGSd8MaLivtCqoCEFGOpWBcuIunXb5WHJP5jr27dq)oXth)(U1jXdS7vVLd4UoPHKazh4DysmdoCEFGOpW7WKygC4WX08Ki79bOFpXth)(U1jXdS7vTLd4UoPHKazh4DysmdoCEFGOpW7WKygC4WX08Ki79bOFpXth)(EFDFHBW1vd3vT4(woWb2SgpWi80K4aun5aV1DlzDLS8(aeuCGgcYoqPfWdyqrlybYoGU2shSWVVBDs8a72YbCxN0qsGSd8omjMbhoVpq0h4DysmdoC4yAEsK9(a0Vt80XVVBDs8a7TLd4UoPHKazh4DysmdoCEFGOpW7WKygC4WX08Ki79bOFN4PJFF36K4bE1B5aURtAijq2bEhMeZGdN3hi6d8omjMbhoCmnpjYEFa63t80XVVBDs8aV6TCa31jnKei7aVlnK0BsghoVpq0h4DPHKEtY4WHJP5jr27dq)oXth)(U1jXd4(3YbCxN0qsGSd8U0qsVjzC48(arFG3Lgs6njJdhoMMNezVpGfhW9bU6TEa63jE6433TojEGx1woG76KgscKDG3HjXm4W59bI(aVdtIzWHdhtZtIS3hG(DINo(9DRtIh4vTLd4UoPHKazh4nbkrQM4GC48(arFG3eOePAIdYHdhtZtIS3hG(DINo(9DRtIhyNB3YbCxN0qsGSd8omjMbhoVpq0h4DysmdoC4yAEsK9(a0Vt80XVVBDs8a7C7woG76KgscKDG3eOePAIdYHZ7de9bEtGsKQjoihoCmnpjYEFa63jE6433TojEGD7TLd4UoPHKazh4DysmdoCEFGOpW7WKygC4WX08Ki79bOFN4PJFF36K4b296TCa31jnKei7aVdtIzWHZ7de9bEhMeZGdhoMMNezVpa97jE6433TojEGDVElhWDDsdjbYoWBcuIunXb5W59bI(aVjqjs1ehKdhoMMNezVpa97epD877wNepWUx2YbCxN0qsGSd8omjMbhoVpq0h4DysmdoC4yAEsK9(a0VN4PJFF36K4b25EB5aURtAijq2bEhMeZGdN3hi6d8omjMbhoCmnpjYEFa6DJ4PJFF36K4b25EB5aURtAijq2bEtGsKQjoihoVpq0h4nbkrQM4GC4WX08Ki79bOFN4PJFF36K4b29Q2YbCxN0qsGSd8w3jdAcoCEFGOpWBDNmOj4WHJP5jr27dq)oXth)(EFDFHBW1vd3vT4(woWb2SgpWi80K4aun5aVDWejJwzn((aeuCGgcYoqPfWdyqrlybYoGU2shSWVVBDs8a72YbCxN0qsGSd8MaLivtCqoCEFGOpWBcuIunXb5WHJP5jr27dq)oXth)(EFDFHBW1vd3vT4(woWb2SgpWi80K4aun5aVTgvEqKs8(aeuCGgcYoqPfWdyqrlybYoGU2shSWVVBDs8a72YbCxN0qsGSd8MaLivtCqoCEFGOpWBcuIunXb5WHJP5jr27dq)oXth)(EFDFHBW1vd3vT4(woWb2SgpWi80K4aun5aV1nnmTmkVpabfhOHGSduAb8agu0cwGSdORT0bl877wNepGB2YbCxN0qsGSd8U0qsVjzC48(arFG3Lgs6njJdhoMMNezVpa97epD877wNepWR3YbCxN0qsGSd8omjMbhoVpq0h4DysmdoC4yAEsK9(a0Vt80XVVBDs8aVElhWDDsdjbYoW7sdj9MKXHZ7de9bExAiP3KmoC4yAEsK9(a0Vt80XVV3x4oHNMei7aU)dy6y68aYPef(9D5)qAQrIl)x5aWf0I6da3too1XbGRiRBjS77RCa4cQrbpKCG9C7ghyp3UNBVV33x5aWnM4cOsiGzuoq0haUKWL9Hli1iX9HlOf1LdaxGWde9b6uc7a6gkJdegXbJYbQu3hWi4bqX)G6azhi6dihA4bKD6CamBiN6de9beSiqYbO3AuvWa65aVYo64337RPJPZc)HG6wWZIpeT)thtN3xthtNf(db1TGNfFiAFOcQMaf2inbuKjUwQnIvuuDgQMs90vqY910X0zH)qqDl4zXhI2Nytbvm0y3377RCa3hXJAOazhaPHeyhigb8arnEathn5at5agnBKMNe53xthtNfrctYuueefxX77RCa4EnYyEsSCFnDmDw(q0(0mYyEsCJ0eqrpDlN0rr1eLJrCAysCdAMecfP7wY6kjVaji0PYXionmjYjOGnzrSxCfMeZGxGee6u5yeNgMeVVMoMolFiAFAgzmpjUrAcOOsOEKwMt6SbntcHImDm0qfMOWGfr7Cr)2eBykKgMb3ySchf)uIY)pXgMcPHzWngRWNSQDVq399voaCTPhtwUVMoMolFiAFJOTevrtiygBmuIiq5OvpDfKWzi1ONOk37fx0)Gb3XionmjYnDm0W))TdtIzWlqccDQCmItdtICmnpjYOZfbkrodPg9evj6L7RPJPZYhI23t2ntrbrGTXqj6bdUJrCAysKB6yOH))EquuCOSULWuwPyqYGd98)hMeZGBebyQMsf1OIzcjYC9Gb3EATYPUHKCthdn0f9pyWnIamLtDdj5MogA4)VUBjRRKCJiat1uQOgvm0yCckytwQs3TK1vsUNSBMIcIaJZGiwmDkU5g6()PgN6qrqbBYIyI8GOO4EYUzkkicmodIyX05910X0z5dr77HKcsGFsNngkrpyWDmItdtICthdn8)3dIIIdL1TeMYkfdsgCON))WKygCJiat1uQOgvmtirMRhm42tRvo1nKKB6yOHUO)bdUreGPCQBij30Xqd))1DlzDLKBebyQMsf1OIHgJtqbBYsv6ULSUsY9qsbjWpPdNbrSy6uCZn09)tno1HIGc2KfXe5brrX9qsbjWpPdNbrSy68(A6y6S8HO9LJtDuuIlGyocygBmuI8GOO4qzDlHPkbbtNOMd9CFFLda3snwcIjpG7mP8aAlpqqghhKCGxFGNoWmgtEapikQYghanD9bKwjM05a7E5afu3jRWpaCfXihXvKDGAJWoGUzi7aXiGhWkhWoqqghhKCGOpa8i(CGjoabnM5jr(910X0z5dr7BPglbXKkTjLBmuIEWG7yeNgMe5MogA4)VheffhkRBjmLvkgKm4qp))HjXm4graMQPurnQyMqImxpyWTNwRCQBij30XqdDr)dgCJiat5u3qsUPJHg()R7wY6kj3icWunLkQrfdngNGc2KLQ0DlzDLKBPglbXKkTjLCgeXIPtXn3q3)p14uhkckytwet0UxUVMoMolFiAFJOTevpqYcUXqjY0XqdvyIcdwQs0E))0tGsKZqQrprvIEXfbkhT6PRGeodPg9evjY9ClD3xthtNLpeTp1qqpz3SngkrpyWDmItdtICthdn8)3dIIIdL1TeMYkfdsgCON))WKygCJiat1uQOgvmtirMRhm42tRvo1nKKB6yOHUO)bdUreGPCQBij30Xqd))1DlzDLKBebyQMsf1OIHgJtqbBYsv6ULSUsYPgc6j7MXzqelMof3CdD))uJtDOiOGnzrmrEquuCQHGEYUzCgeXIPZ7RPJPZYhI23ZCunLkiJg(YgdLipikkouw3syQsqW0jQ5qpUmDm0qfMOWGfr7UVVYbGRYMmSjN05aW9oeijMXbG7lnhi8at5a2bEittMa2910X0z5dr73qHhbn43yOeX6GtBiqsmd1J0CGqobPiyP28KORTdtIzWHY6wct5jhN6W12eBykKgMb3ySchf)uIY910X0z5dr73qHhbn43yOeX6GtBiqsmd1J0CGqobPiyP28KOlthdnuHjkmyPkr75I(TdtIzWHY6wct5jhN64)pmjMbhkRBjmLNCCQdx6ULSUsYHY6wct5jhN6GtqbBYcD3xthtNLpeTFdfEe0GFJHsebkrQM4G8c0dskbXM0f9So4uKUekkKgs4eKIGLAZtI))So4EYUzQhP5aHCcsrWsT5jr6UVVYbGB6y68aBDkr5(A6y6S8HO91MuQmDmDQKtj2inbuKUPHPLr5(A6y6S8HO91MuQmDmDQKtj2inbuKUBjRRKL7RPJPZYhI2NaLkthtNk5uInstafznQkya9SXqjY0XqdvyIcdwQs0EUOx3TK1vsodTOwzjtXqTbJtqbBYIy7CRRTdtIzWzi1iX)FD3swxj5mKAKiNGc2KfX25wxHjXm4mKAKiDU2MHwuRSKPyO2GXJrd)Ko3xthtNLpeTpbkvMoMovYPeBKMakYAu5brkXgdLithdnuHjkmyPkr75IHwuRSKPyO2GXJrd)Ko3xthtNLpeTpbkvMoMovYPeBKMakYbtKmAL14gdLithdnuHjkmyPkr75I(TzOf1klzkgQny8y0WpPJl61DlzDLKZqlQvwYumuBW4euWMSu1o36A7WKygCgsns8)x3TK1vsodPgjYjOGnzPQDU1vysmdodPgjshD3xthtNLpeTV2KsLPJPtLCkXgPjGICWejJEJHsKPJHgQWefgSiA399((khaU1Uph4tisjUVMoMolCRrLhePeIyOf1kDpYngkrEquuCMrGxfellunrWIPto0JlcuIunXb5m0yYblHs3J0LPJHgQWefgSiMi3CFnDmDw4wJkpisj(q0(4ZWqHrVXqjIaLJw90vqcNHuJEcXOFNB)GHwuRGphN6GtvPHsgYuHrCWOiU0n05IHwuRGphN6GtvPHsgYuHrCWOiM75ABAgzmpjYF6woPJIQjkhJ40WK4)VheffVuXict6OeMsWHEUVMoMolCRrLhePeFiAF8zyOWO3yOerGYrRE6kiHZqQrpHy79IlgArTc(CCQdovLgkzitfgXbJsvV4ABAgzmpjYF6woPJIQjkhJ40WK4910X0zHBnQ8GiL4dr7Jpddfg9gdLOTzOf1k4ZXPo4uvAOKHmvyehmkU2MMrgZtI8NULt6OOAIYXionmj()tno1HIGc2KfXE5)NydtH0Wm4gJv4O4NsuCrSHPqAygCJXkCckytwe7L7RPJPZc3Au5brkXhI2VsdLmv5btgsUVMoMolCRrLhePeFiAF8zyOWO3yOeTnnJmMNe5pDlN0rr1eLJrCAys8(EFFLda3A3Nd4Jb0Z910X0zHBnQkya9iYsykwY2yOeXqlQvWNJtDWPQ0qjdzQWioyuQsKgMwIkmrHbl))eBykKgMb3ySchf)uIIlInmfsdZGBmwHtqbBYIyI2T7(A6y6SWTgvfmGE(q0(wctXs2gdLigArTc(CCQdovLgkzitfgXbJsvIE5(A6y6SWTgvfmGE(q0(m0IALUh5gdLipikkoZiWRcILfQMiyX0jh6XfbkrQM4GCgAm5GLqP7r6Y0XqdvyIcdwetKBUVMoMolCRrvbdONpeTp(mmuy0BmuI2MMrgZtI8NULt6OOAIYXionmjEFnDmDw4wJQcgqpFiAFkSeizshvjid84gAyAjQcJ4Grr0Ungkrm0dIIItHLajt6OQ0qjJxctdVyICJlD3swxj52tRnjSNcYjOGnzrm3CFnDmDw4wJQcgqpFiAFkSeizshvjid84gAyAjQcJ4Grr0Ungkrm0dIIItHLajt6OQ0qjJxctdVy7UVMoMolCRrvbdONpeTpfwcKmPJQeKbECdnmTevHrCWOiA3gdLicuI8yeqv0Qxlg96ULSUsYzOf1klzkgQnyCckytwCTDysmdodPgj()R7wY6kjNHuJe5euWMS4kmjMbNHuJeP7(EFFLda3VJPZYbSKDGoQrYb68aqf8(A6y6SW1DlzDLSi6PJPZngkrpyWDmItdtICthdn8)3dIIIdL1TeMYkfdsgCON))WKygCJiat1uQOgvmtirMl6FWGBebykN6gsYnDm0W))hm42tRvo1nKKB6yOH))6ULSUsYnIamvtPIAuXqJXjOGnzPQWioyWJravrRyds3)p14uhkckytweBp37(A6y6SW1DlzDLS8HO9HkOAcuyJ0eqrtw0eOW8KOsCGSmGeumK2OXngkr0R7wY6kjhkRBjmLNCCQdobfSjl))6ULSUsYzgbEvqSSq1eblMo5euWMSqNl6FWGBebykN6gsYnDm0W))hm42tRvo1nKKB6yOHU2omjMb3icWunLkQrfZesK9)hgXbdEmcOkA1Jou75wXEHU)FQXPoueuWMSi2E7UVMoMolCD3swxjlFiAFOcQMaf2inbuKGPnpcQk1igkbOYO3yOeP7wY6kj3EATjH9uqobfSjlI9Il63gfhO55bz8jlAcuyEsujoqwgqckgsB04)VUBjRRK8jlAcuyEsujoqwgqckgsB0iNGc2Kf6()PgN6qrqbBYIy7T7(A6y6SW1DlzDLS8HO9HkOAcuyJ0eqrmcAmQHGkAyPGYngkr6ULSUsYTNwBsypfKtqbBYIl63gfhO55bz8jlAcuyEsujoqwgqckgsB04)VUBjRRK8jlAcuyEsujoqwgqckgsB0iNGc2Kf6()PgN6qrqbBYIyU5(A6y6SW1DlzDLS8HO9HkOAcuyJ0eqrmJaVq3PIHA4v0AIPNa2gdLiD3swxj52tRnjSNcYjOGnzXf9BJId088Gm(KfnbkmpjQehildibfdPnA8)x3TK1vs(KfnbkmpjQehildibfdPnAKtqbBYcD))uJtDOiOGnzrS92DFnDmDw46ULSUsw(q0(qfunbku2yOeP7wY6kj3EATjH9uqobfSjlUOFBuCGMNhKXNSOjqH5jrL4azzajOyiTrJ))6ULSUsYNSOjqH5jrL4azzajOyiTrJCckytwO7((khWDDlzDLSCFnDmDw46ULSUsw(q0(graMQPurnQyOX2yOeP7wY6kjhkRBjmLNCCQdobfSjlI5gx6ULSUsYzgbEvqSSq1eblMo5euWMSiMBCfMeZGdL1TeMYtoo1HRTlnK0BsgxIgt5btHI3eEK4))2HjXm4qzDlHP8KJtD8)tno1HIGc2KfXCZl3xthtNfUUBjRRKLpeTVreGPAkvuJkgASngkr6ULSUsYHY6wct5jhN6GtqbBYIyUXLUBjRRKCZRfM0IPtLCe84e0yWCvAiP3KmUenMYdMcfVj8iX77RCaFyP(aFkhN64avMO(aWfJa)b2KyzHQjcwmDEGH6aqXihX1jDoqh1i5aWfJa)b2KyzHQjcwmDEapikQYghiQ7cEapCsNdaxqJjhSehWD9i34aWvIGP46GSdaxvNLG0LjGDGMCa3NajPjpaCLHshKWpaCtw6dORrn8Ldmuhq3jBIPZYbmcEabmoq0hyYsGg7a1TKDaQMCa42tRnjSNcYVVMoMolCD3swxjlFiAFOSULWuEYXPo2yOerZiJ5jrEjupslZjDCrVUBjRRKCMrGxfellunrWIPtobfSjlI5Oz))EquuCMrGxfellunrWIPto0dDUOFBcuIunXb5m0yYblHs3J8)F7WKygCJiat1uQOgvmtir2)VUtg0eCDN0ATftNQMsf1OIHgJtSeEXEHU77RCaFyP(aFkhN64avMO(aWTNwBsypf8ad1bIA8a6ULSUsEGM6aWTNwBsypf8at5aYUYbWSHCQ5haUgfhOHGLdaxqJjhSehWD9i34aURtAT2IPZd0uhiQXdaxqJDalzhaUreGDGM6arnEa4IjKi7ar7Grns43xthtNfUUBjRRKLpeTpuw3sykp54uhBmuIOzKX8KiVeQhPL5KoUiqjs1ehKZqJjhSekDpsxHjXm4graMQPurnQyMqImx6ozqtW1DsR1wmDQAkvuJkgAmoXs4Rs0lU0DlzDLKBpT2KWEkiNGc2KfXCJl61DlzDLKZmc8QGyzHQjcwmDYjOGnzrmhn7)3dIIIZmc8QGyzHQjcwmDYHEO7(A6y6SW1DlzDLS8HO9HY6wct5jhN6yJHsKPJHgQWefgSuLO9()PgN6qrqbBYIy7T7(A6y6SW1DlzDLS8HO9zgbEvqSSq1eblMo3yOerZiJ5jrEjupslZjDCrpRdouw3sykp54uhkwhCckytw()3omjMbhkRBjmLNCCQd6UVMoMolCD3swxjlFiAFMrGxfellunrWIPZngkrMogAOctuyWsvI27)NACQdfbfSjlIT3U7RPJPZcx3TK1vYYhI23EATjH9uWngkrMogAOctuyWIODUyOheffNclbsM0rvPHsgVeMg(Qe9AxHjXm4qzDlHP8KJtD4kmjMb3icWunLkQrfZesK5IaLivtCqodnMCWsO09iDP7Kbnbx3jTwBX0PQPurnQyOX4elHVkrV4I1bhkRBjmLNCCQdfRdobfSjl3xthtNfUUBjRRKLpeTV90Atc7PGBmuImDm0qfMOWGfr7CXqpikkofwcKmPJQsdLmEjmn8vj61UctIzWHY6wct5jhN6WfRdouw3sykp54uhkwhCckytwCTDysmdUreGPAkvuJkMjKiZLUtg0eCDN0ATftNQMsf1OIHgJtSeEXE5(A6y6SW1DlzDLS8HO9TNwBsypfCJHsKPJHgQWefgSiANlg6brrXPWsGKjDuvAOKXlHPHVkrV2f9BhMeZGdL1TeMYtoo1X)FysmdUreGPAkvuJkMjKiZf9BtGsKQjoiNHgtoyju6EK))6ozqtW1DsR1wmDQAkvuJkgAmoXs4f7f6()3omjMb3icWunLkQrfZesK5s3jdAcUUtAT2IPtvtPIAuXqJXjwcFvIE5)NACQdfbfSjlITZ9O7(A6y6SW1DlzDLS8HO9TNwBsypfCdnmTevHrCWOiA3gdLithdnuHjkmyPkr75IHEquuCkSeizshvLgkz8syA4Rs0RDTndTOwzjtXqTbJhJg(jDUVMoMolCD3swxjlFiA)cKGqNkhJ40WK4gdLicuoA1txbjCgsn6jeB3RDrVUBjRRKCOSULWuEYXPo4euWMSi2o3()Z6GdL1TeMYtoo1HI1bNGc2Kf6UVMoMolCD3swxjlFiAFOSULWuwPyqYyJHsenJmMNe5Lq9iTmN0Xfd9GOO4uyjqYKoQknuY4LW0Wl2EUO)bdU90ALtDdj5MogA4)VUtg0eCDN0ATftNQMsf1OIHgZLheffNze4vbXYcvteSy6Kd94A7hm4graMYPUHKCthdnKU7RPJPZcx3TK1vYYhI2hkRBjmLvkgKm2qdtlrvyehmkI2TXqjY0XqdvyIcdwQs0EUyOheffNclbsM0rvPHsgVeMgEX27(A6y6SW1DlzDLS8HO9lnKurq7bjBOHPLOkmIdgfr72yOefgXbdEmcOkA1JouU5fXEXvyehm4XiGQOvSbR6L7RPJPZcx3TK1vYYhI2Nytbvm0yBmuI2(bdUtDdj5MogA4910X0zHR7wY6kz5dr7xmnzOg9ys1JPJngkrMogAOctuyWsvI2Z12EquuCMrGxfellunrWIPto0JRT1DlzDLKZmc8QGyzHQjcwmDYjOXG9)tno1HIGc2KfXC0S7799voG7AAyAzCa4M3iNyWY910X0zHRBAyAzuevQyeHjDuctj2yOerZiJ5jrEjupslZjDCrGYrRE6kiHZqQrprv7CV)FQXPoueuWMSi2UD33x5a(yCGOpaubpGrfi5a2tRpWuoqNhWDWLdyLde9bEiinmJd00qI2EEM05aW1W9pqL6rIhOGrmPZbGEoG7GlVl3xthtNfUUPHPLr5dr7xQyeHjDuctj2yOeP7wY6kj3EATjH9uqobfSjlUO30XqdvyIcdwQs0EUmDm0qfMOWGfXe9IlcuoA1txbjCgsn6jQANB)GEthdnuHjkmyrCP7r3)VPJHgQWefgSu1lUiq5OvpDfKWzi1ONOQx7w6UVMoMolCDtdtlJYhI238AHjTy6ujhbVngkr0mYyEsKxc1J0YCshxBxAiP3KmUenMYdMcfVj8irx6ULSUsYTNwBsypfKtqbBYIlcuI8yeqv0Qxxf9U5dpikkobkhTs3ec0tmDYjOGnzHU)FQXPoueuWMSi2E7UVMoMolCDtdtlJYhI238AHjTy6ujhbVngkr0mYyEsKxc1J0YCshxLgs6njJlrJP8GPqXBcps0f9So4qzDlHP8KJtDOyDWjOGnzPQD7()3omjMbhkRBjmLNCCQdx6ULSUsYzgbEvqSSq1eblMo5euWMSq3910X0zHRBAyAzu(q0(MxlmPftNk5i4TXqjY0XqdvyIcdwQs0EUiqjYJravrREDv07Mp8GOO4eOC0kDtiqpX0jNGc2Kf6UVMoMolCDtdtlJYhI2VuBA4LOkQrfuwPjrnSngkr0mYyEsKxc1J0YCshx6ULSUsYTNwBsypfKtqbBYY)p14uhkckytweB3l3xthtNfUUPHPLr5dr7xQnn8suf1OckR0KOg2gdLithdnuHjkmyPkr75IEgArTYsMIHAdgpgn8t68)tSHPqAygCJXkCckytwet0Uxt399((khWFshjEGnnIdg3xthtNfUdMiz0IyOf1kDpYngkrEquu8ceJHPI1TaNGMoCTnnJmMNe5pDlN0rr1eLJrCAys8))bdUJrCAysKB6yOH3xthtNfUdMiz0FiAFgArTs3JCJHsebkhT6PRGeodPg9eITZnU2MMrgZtI8NULt6OOAIYXionmjEFnDmDw4oyIKr)HO9TeMILSngkr6ULSUsYTNwBsypfKtqbBYIl6dtIzWzi1iroMMNez))6MgMwg8CCQdfLH))eOePAIdYFQrJ0cDIf6UVMoMolChmrYO)q0(vAOKPkpyYqYgdLig6brrXPWsGKjDuvAOKXlHPHVQxFFnDmDw4oyIKr)HO9R0qjtvEWKHKngkrm0dIIItHLajt6OQ0qjJd94s3TK1vsU90Atc7PGCckytwQ6fx0VDysmdouw3sykp54uh))HjXm4graMQPurnQyMqImx6ozqtW1DsR1wmDQAkvuJkgAmoXs4f7L))TdtIzWnIamvtPIAuXmHezU0DYGMGR7KwRTy6u1uQOgvm0yCILWxLOx()3w3jdAcUUtAT2IPtvtPIAuXqJr3910X0zH7Gjsg9hI2VsdLmv5btgs2yOeXqpikkofwcKmPJQsdLmo0JRWKygCOSULWuEYXPoCr)2HjXm4graMQPurnQyMqImx6ozqtW1DsR1wmDQAkvuJkgAmoXs4f7L))WKygCJiat1uQOgvmtirMlDNmOj46oP1AlMovnLkQrfdngNyj8vj6f6CrVUBjRRKCOSULWuEYXPo4euWMSu1o36ABwhCOSULWuEYXPouSo4euWMS8)R7wY6kj3EATjH9uqobfSjlvTZT0DFnDmDw4oyIKr)HO9zOf1kDpYngkreOC0QNUcs4mKA0ti2EU1120mYyEsK)0TCshfvtuogXPHjX7RPJPZc3btKm6peTpfwcKmPJQeKbECJHsed9GOO4uyjqYKoQknuY4LW0Wl2U7RPJPZc3btKm6peTpfwcKmPJQeKbECJHsed9GOO4uyjqYKoQknuY4LW0Wl2RDP7wY6kj3EATjH9uqobfSjlI9Il63omjMbhkRBjmLNCCQJ))WKygCJiat1uQOgvmtirMlDNmOj46oP1AlMovnLkQrfdngNyj8I9Y))2HjXm4graMQPurnQyMqImx6ozqtW1DsR1wmDQAkvuJkgAmoXs4Rs0l))BR7Kbnbx3jTwBX0PQPurnQyOXO7(A6y6SWDWejJ(dr7tHLajt6OkbzGh3yOeXqpikkofwcKmPJQsdLmEjmn8I9AxHjXm4qzDlHP8KJtD4I(TdtIzWnIamvtPIAuXmHezU0DYGMGR7KwRTy6u1uQOgvm0yCILWl2l))HjXm4graMQPurnQyMqImx6ozqtW1DsR1wmDQAkvuJkgAmoXs4Rs0l05IED3swxj5qzDlHP8KJtDWjOGnzrSDU9)x3TK1vsU90Atc7PGCckytweBNBDX6GdL1TeMYtoo1HI1bNGc2Kf6UVMoMolChmrYO)q0(m0IALUh5gdLOTPzKX8Ki)PB5KokQMOCmItdtI3377RCaXDmrYOpaCRDFoaCFY0KjGDFnDmDw4oyIKrRSgfXqlQv6EKBmuI8GOO4mJaVkiwwOAIGftNCOhxeOePAIdYzOXKdwcLUhPlthdnuHjkmyrmrU5(A6y6SWDWejJwzn(HO9XNHHcJEJHsKheffVaXyyQyDlWjOPJ7RPJPZc3btKmAL14hI2hFggkm6ngkrBtZiJ5jr(t3YjDuunr5yeNgMeVVMoMolChmrYOvwJFiA)knuYuLhmzizdnmTevHrCWOiA3gdLi61DlzDLKBpT2KWEkiNGc2KLQEXfd9GOO4uyjqYKoQknuY4qp))m0dIIItHLajt6OQ0qjJxctdFvVMox0tno1HIGc2KfX0DlzDLKZqlQvwYumuBW4euWMS8Xo3()tno1HIGc2KLQ0DlzDLKBpT2KWEkiNGc2Kf6UVMoMolChmrYOvwJFiAFkSeizshvjid84gAyAjQcJ4Grr0Ungkrm0dIIItHLajt6OQ0qjJxctdVyICJlD3swxj52tRnjSNcYjOGnzrm38)ZqpikkofwcKmPJQsdLmEjmn8IT7(A6y6SWDWejJwzn(HO9PWsGKjDuLGmWJBOHPLOkmIdgfr72yOeP7wY6kj3EATjH9uqobfSjlv9Ilg6brrXPWsGKjDuvAOKXlHPHxSDlFdkQBYY3FeGKwmD6oIrfRyfRf]] )

end
