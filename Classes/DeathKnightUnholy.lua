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


    spec:RegisterPack( "Unholy", 20201209, [[d8ed5bqifPEKKu6sujuTjI0NuvAuivDkKkRIkHsVsvHzPiAxO6xQcnmQK6yQswgsKNrLKPPksxtvW2ufrFtveACQIGZrLqwNIeZts09iI9jjCqvfLfQkQhkjvtuvrCrjPO2OQIe5JssbJuvrI6KQkQSsvPEPQIQ0mvK0nvvKKDkj5NQksQHQQiHLQQi1tPktvr4QQkQQTQQOk(QKuKXIe1Ev4VKAWahMYIPQEmjtgLldTzq9zQy0sQtR0QPsO41iHzt42e1Uf9BPgUI64ujy5iEUetx46GSDK03PsnEQeDEvvRxsk08rk7xLhVgtm8ywGJQOKRPKRFrjx7I4U2frjx0RhgEX)mo8MnffMdo8stghEF(zDl(hEZ2VOn2yIHxPHikC4vhXCzkp(OZg1q(Cvl)yzLHewSDQigC8yzLvpo88Hwr85YH)WJzboQIsUMsU(fLCTlI7AxeLEYNsPHxzgvJQO0duA4vVmgMd)HhdlQHx1EGpbTO(aFEZ1PooWNFw3I)7D1EGpbvOSpsoGlAYdqjxtjxFVV3v7b(mMlgOsiJzuoq0h4tYp5XpbHxb(4NGwuxoWNaHhi6d0P4)aQgkJdegXbJYbCx3hWi4bqxoJQazhi6diwQ4beD6CamBiN6de9bKTiqYbO3AuxWaA(av7l64dpXwIYyIHN1OUGb08yIrvVgtm8W08fiB88Wtr2ajRn8yOf1AkY1Po4WUBOKHmDyehmkhOcjhq9ReOgtuEXYbOr7aeBzAKkMb3ySchD5wIYbKEaITmnsfZGBmwHtqzBZYbQuYbE9A4zQy7C4z5VMLSrmQIsJjgEyA(cKnEE4PiBGK1gEm0IAnf56uhCy3nuYqMomIdgLduHKd8WWZuX25WZYFnlzJyuLRgtm8W08fiB88Wtr2ajRn88HGH5mJqHoiwwGBISfBNCO5di9aeOeHBIdYzOXelwcTQxbhtZxGSdi9aMkwQOgtuEXYbQuYbC1WZuX25WJHwuRv9kgXOQNoMy4HP5lq245HNISbswB4n9bOAK18fiFUBXMoA4MODmIt)lWHNPITZHhoVmuEvJyu1dJjgEyA(cKnEE4PiBGK1gEm0hcgMdJLajB6OD3qjJxctrXbQuYbC1bKEav3cw7o52CRmX)Cb5eu22SCGkpGRgEMk2ohEWyjqYMo6sqwkWHN6xjqDyehmkJQEnIrvp5yIHhMMVazJNhEkYgizTHhd9HGH5WyjqYMoA3nuY4LWuuCGkpWRHNPITZHhmwcKSPJUeKLcC4P(vcuhgXbJYOQxJyu1tCmXWdtZxGSXZdpfzdKS2WJaLipwzuhT(PhOYdq)buDlyT7KZqlQ1wY0muz)CckBBwoG0dm9bctGzWzi8kqoMMVazhGgTdO6wWA3jNHWRa5eu22SCaPhimbMbNHWRa5yA(cKDa6gEMk2ohEWyjqYMo6sqwkWHN6xjqDyehmkJQEnIrm8CWejRAmXOQxJjgEyA(cKnEE4PiBGK1gE(qWW8ceJHPM1TmNGMkoG0dm9bOAK18fiFUBXMoA4MODmIt)lWdqJ2bMXG7yeN(xGCtflvC4zQy7C4XqlQ1QEfJyufLgtm8W08fiB88Wtr2ajRn8iq5Q0ZTBKWzi8Q24avEGxU6aspW0hGQrwZxG85UfB6OHBI2Xio9VahEMk2ohEm0IATQxXigv5QXedpmnFbYgpp8uKnqYAdpv3cw7o52CRmX)Cb5eu22SCaPhG(deMaZGZq4vGCmnFbYoanAhq1uX0YGNRtDOHn8a0ODacuIWnXb5Z1OrA5oXchtZxGSdq3WZuX25WZYFnlzJyu1thtm8W08fiB88Wtr2ajRn8yOpemmhglbs20r7UHsgVeMIIduXbE6WZuX25WZDdLmDzgtgsgXOQhgtm8W08fiB88Wtr2ajRn8yOpemmhglbs20r7UHsghA(aspGQBbRDNCBUvM4FUGCckBBwoqfh4Hdi9a0FGPpqycmdouw3IFTVyDQdoMMVazhGgTdeMaZGBe5FDdRJAuZm5ezCmnFbYoG0dO6KbTbx1j1wzX2PUH1rnQzOX4elP4avEGhoanAhy6deMaZGBe5FDdRJAuZm5ezCmnFbYoG0dO6KbTbx1j1wzX2PUH1rnQzOX4elP4avi5apCaA0oW0hq1jdAdUQtQTYITtDdRJAuZqJXX08fi7a0n8mvSDo8C3qjtxMXKHKrmQ6jhtm8W08fiB88Wtr2ajRn8yOpemmhglbs20r7UHsghA(aspqycmdouw3IFTVyDQdoMMVazhq6bO)atFGWeygCJi)RByDuJAMjNiJJP5lq2bKEavNmOn4QoP2kl2o1nSoQrndngNyjfhOYd8WbOr7aHjWm4gr(x3W6Og1mtorghtZxGSdi9aQozqBWvDsTvwSDQByDuJAgAmoXskoqfsoWdhGUdi9a0Fav3cw7o5qzDl(1(I1Po4eu22SCGkoWlxFaPhy6dW6GdL1T4x7lwN6qZ6GtqzBZYbOr7aQUfS2DYT5wzI)5cYjOSTz5avCGxU(a0n8mvSDo8C3qjtxMXKHKrmQ6joMy4HP5lq245HNISbswB4rGYvPNB3iHZq4vTXbQ8auY1hq6bM(aunYA(cKp3TythnCt0ogXP)f4WZuX25WJHwuRv9kgXOQNWyIHhMMVazJNhEkYgizTHhd9HGH5WyjqYMoA3nuY4LWuuCGkpWRHNPITZHhmwcKSPJUeKLcCeJQCrJjgEyA(cKnEE4PiBGK1gEm0hcgMdJLajB6OD3qjJxctrXbQ8ap9aspGQBbRDNCBUvM4FUGCckBBwoqLh4Hdi9a0FGPpqycmdouw3IFTVyDQdoMMVazhGgTdeMaZGBe5FDdRJAuZm5ezCmnFbYoG0dO6KbTbx1j1wzX2PUH1rnQzOX4elP4avEGhoanAhy6deMaZGBe5FDdRJAuZm5ezCmnFbYoG0dO6KbTbx1j1wzX2PUH1rnQzOX4elP4avi5apCaA0oW0hq1jdAdUQtQTYITtDdRJAuZqJXX08fi7a0n8mvSDo8GXsGKnD0LGSuGJyu1lxpMy4HP5lq245HNISbswB4XqFiyyomwcKSPJ2DdLmEjmffhOYd80di9aHjWm4qzDl(1(I1Po4yA(cKDaPhG(dm9bctGzWnI8VUH1rnQzMCImoMMVazhq6buDYG2GR6KARSy7u3W6Og1m0yCILuCGkpWdhGgTdeMaZGBe5FDdRJAuZm5ezCmnFbYoG0dO6KbTbx1j1wzX2PUH1rnQzOX4elP4avi5apCa6oG0dq)buDlyT7KdL1T4x7lwN6GtqzBZYbQ8aVC9bOr7aQUfS2DYT5wzI)5cYjOSTz5avEGxU(aspaRdouw3IFTVyDQdnRdobLTnlhGUHNPITZHhmwcKSPJUeKLcCeJQE9AmXWdtZxGSXZdpfzdKS2WB6dq1iR5lq(C3InD0Wnr7yeN(xGdptfBNdpgArTw1RyeJy4XqydseJjgv9AmXWZuX25WtEtMgMGy1io8W08fiB88igvrPXedpmnFbYgpp865HxbJHNPITZHhvJSMVahEunbeo8uDlyT7KxGKL7u7yeN(xGCckBBwoqLh4Hdi9aHjWm4fiz5o1ogXP)fihtZxGSHhvJOttghEZDl20rd3eTJrC6FboIrvUAmXWdtZxGSXZdVEE4vWy4zQy7C4r1iR5lWHhvtaHdptflvuJjkVy5asoWRdi9a0FGPpaXwMgPIzWngRWrxULOCaA0oaXwMgPIzWngRW38avCGxpCa6gEunIonzC4vc9SWYCtNrmQ6PJjgEyA(cKnEE4PiBGK1gEeOCv652ns4meEvBCGkoWt(WbKEa6pWmgChJ40)cKBQyPIhGgTdm9bctGzWlqYYDQDmIt)lqoMMVazhGUdi9aeOe5meEvBCGkKCGhgEMk2ohEgrzjQJMqWmgXOQhgtm8W08fiB88Wtr2ajRn8MXG7yeN(xGCtflv8a0ODaFiyyouw3IFTvkgKi4qZhGgTdeMaZGBe5FDdRJAuZm5ezCmnFbYoG0dmJb3MBL2PUHeCtflv8aspa9hygdUrK)1o1nKGBQyPIhGgTdO6wWA3j3iY)6gwh1OMHgJtqzBZYbQ4aQUfS2DY9fDZ0WqKFodIyX25bE8aU6a0DaA0oa86uhAckBBwoqLsoGpemm3x0ntddr(5miIfBNdptfBNdpFr3mnme5FeJQEYXedpmnFbYgpp8uKnqYAdVzm4ogXP)fi3uXsfpanAhWhcgMdL1T4xBLIbjco08bOr7aHjWm4gr(x3W6Og1mtorghtZxGSdi9aZyWT5wPDQBib3uXsfpG0dq)bMXGBe5FTtDdj4MkwQ4bOr7aQUfS2DYnI8VUH1rnQzOX4eu22SCGkoGQBbRDNCFKuqcfB6Wzqel2opWJhWvhGUdqJ2bGxN6qtqzBZYbQuYb8HGH5(iPGek20HZGiwSDo8mvSDo88rsbjuSPZigv9ehtm8W08fiB88Wtr2ajRn88HGH5qzDl(1LGGPtuZHMhEMk2ohEI1PokAxmqmhzmJrmQ6jmMy4HP5lq245HNISbswB4nJb3Xio9Va5MkwQ4bOr7a(qWWCOSUf)ARumirWHMpanAhimbMb3iY)6gwh1OMzYjY4yA(cKDaPhygdUn3kTtDdj4MkwQ4bKEa6pWmgCJi)RDQBib3uXsfpanAhq1TG1UtUrK)1nSoQrndngNGY2MLduXbuDlyT7KBPclbXeALjeCgeXITZd84bC1bO7a0ODa41Po0eu22SCGkLCGxpm8mvSDo8SuHLGycTYeIrmQYfnMy4HP5lq245HNISbswB4zQyPIAmr5flhOcjhGshGgTdq)biqjYzi8Q24avi5apCaPhGaLRsp3UrcNHWRAJduHKd8KU(a0n8mvSDo8mIYsupdjk4igv9Y1JjgEyA(cKnEE4PiBGK1gEZyWDmIt)lqUPILkEaA0oGpemmhkRBXV2kfdseCO5dqJ2bctGzWnI8VUH1rnQzMCImoMMVazhq6bMXGBZTs7u3qcUPILkEaPhG(dmJb3iY)AN6gsWnvSuXdqJ2buDlyT7KBe5FDdRJAuZqJXjOSTz5avCav3cw7o5Wlb9fDZ4miIfBNh4Xd4Qdq3bOr7aWRtDOjOSTz5avk5a(qWWC4LG(IUzCgeXITZHNPITZHh8sqFr3SrmQ61RXedpmnFbYgpp8uKnqYAdpFiyyouw3IFDjiy6e1CO5di9aMkwQOgtuEXYbKCGxdptfBNdpFZr3W6GSkkkJyu1lknMy4HP5lq245HNISbswB4X6GtDjqcmd9SWCGqobHjyP28f4bKEGPpqycmdouw3IFTVyDQdoMMVazhq6bM(aeBzAKkMb3ySchD5wIYWZuX25WRHcFcAumIrvVC1yIHhMMVazJNhEkYgizTHhRdo1LajWm0ZcZbc5eeMGLAZxGhq6bmvSurnMO8ILduHKdqPdi9a0FGPpqycmdouw3IFTVyDQdoMMVazhGgTdeMaZGdL1T4x7lwN6GJP5lq2bKEav3cw7o5qzDl(1(I1Po4eu22SCa6gEMk2ohEnu4tqJIrmQ61thtm8W08fiB88Wtr2ajRn8iqjc3ehKxGMrsji2MCmnFbYoG0dq)byDWHjDj0WivKWjimbl1MVapanAhG1b3x0ntplmhiKtqycwQnFbEa6gEMk2ohEnu4tqJIrmQ61dJjgEyA(cKnEE4zQy7C4PmHqBQy7ul2sm8eBj0PjJdpvtftlJYigv96jhtm8W08fiB88WZuX25WtzcH2uX2PwSLy4j2sOttghEQUfS2DwgXOQxpXXedpmnFbYgpp8mvSDo8iqP2uX2PwSLy4PiBGK1gEMkwQOgtuEXYbQqYbO0bKEa6pGQBbRDNCgArT2sMMHk7NtqzBZYbQ8aVC9bKEGPpqycmdodHxbYX08fi7a0ODav3cw7o5meEfiNGY2MLdu5bE56di9aHjWm4meEfihtZxGSdq3bKEGPpadTOwBjtZqL9ZJvrXModpXwcDAY4WZAuxWaAEeJQE9egtm8W08fiB88WZuX25WJaLAtfBNAXwIHNISbswB4zQyPIAmr5flhOcjhGshq6byOf1AlzAgQSFESkk20z4j2sOttghEwJAFisjgXOQxUOXedpmnFbYgpp8mvSDo8iqP2uX2PwSLy4PiBGK1gEMkwQOgtuEXYbQqYbO0bKEa6pW0hGHwuRTKPzOY(5XQOytNdi9a0Fav3cw7o5m0IATLmndv2pNGY2MLduXbE56di9atFGWeygCgcVcKJP5lq2bOr7aQUfS2DYzi8kqobLTnlhOId8Y1hq6bctGzWzi8kqoMMVazhGUdq3WtSLqNMmo8CWejRsBnoIrvuY1JjgEyA(cKnEE4zQy7C4PmHqBQy7ul2sm8uKnqYAdptflvuJjkVy5asoWRHNylHonzC45Gjsw1igXWBMGQw23IXeJQEnMy4zQy7C4n3X25WdtZxGSXZJyufLgtm8W08fiB88WlnzC4zvJLAJyfnCNHUH1ZTBKm8mvSDo8SQXsTrSIgUZq3W652nsgXOkxnMy4zQy7C4rSTGAgASHhMMVazJNhXigEQUfS2DwgtmQ61yIHhMMVazJNhEkYgizTH3mgChJ40)cKBQyPIhGgTd4dbdZHY6w8RTsXGebhA(a0ODGWeygCJi)RByDuJAMjNiJJP5lq2bKEa6pWmgCJi)RDQBib3uXsfpanAhygdUn3kTtDdj4MkwQ4bOr7aQUfS2DYnI8VUH1rnQzOX4eu22SCGkoa86uhAckBBwoaDdptfBNdV5o2ohXOkknMy4HP5lq245HxAY4WBZIIafMVa1UaKLbKSMHuxfo8mvSDo82SOiqH5lqTlazzajRzi1vHdpfzdKS2WJ(dO6wWA3jhkRBXV2xSo1bNGY2MLdqJ2buDlyT7KZmcf6GyzbUjYwSDYjOSTz5a0DaPhG(dmJb3iY)AN6gsWnvSuXdqJ2bMXGBZTs7u3qcUPILkEaPhy6deMaZGBe5FDdRJAuZm5ezCmnFbYoanAhimIdg8yLrD06zvOPKRpqLh4Hdq3igv5QXedpmnFbYgpp8stghEYMY8jOUuJyOLHkRA4zQy7C4jBkZNG6snIHwgQSQHNISbswB4P6wWA3j3MBLj(NliNGY2MLdu5bE4aspa9hy6dGUa0opJm(MffbkmFbQDbildizndPUk8a0ODav3cw7o5BwueOW8fO2fGSmGK1mK6QqobLTnlhGUrmQ6PJjgEyA(cKnEE4LMmo8ye0yWlb1uXsbfdptfBNdpgbng8sqnvSuqXWtr2ajRn8uDlyT7KBZTYe)ZfKtqzBZYbKEacuI8yLrD06NEGkpGJIDaPhG(dm9bqxaANNrgFZIIafMVa1UaKLbKSMHuxfEaA0oGQBbRDN8nlkcuy(cu7cqwgqYAgsDviNGY2MLdq3igv9WyIHhMMVazJNhEPjJdpMrOqU7uZqffAQnXuB8p8mvSDo8ygHc5UtndvuOP2etTX)Wtr2ajRn8uDlyT7KBZTYe)ZfKtqzBZYbKEa6pW0haDbODEgz8nlkcuy(cu7cqwgqYAgsDv4bOr7aQUfS2DY3SOiqH5lqTlazzajRzi1vHCckBBwoaDJyu1toMy4HP5lq245HNISbswB4P6wWA3j3MBLj(NliNGY2MLdi9a0FGPpa6cq78mY4BwueOW8fO2fGSmGK1mK6QWdqJ2buDlyT7KVzrrGcZxGAxaYYaswZqQRc5eu22SCa6gEMk2ohEqfuVbkxgXOQN4yIHhMMVazJNhEkYgizTHNQBbRDNCOSUf)AFX6uhCckBBwoqLhWvhq6buDlyT7KZmcf6GyzbUjYwSDYjOSTz5avEaxDaPhimbMbhkRBXV2xSo1bhtZxGSdqJ2bM(aHjWm4qzDl(1(I1Po4yA(cKn8mvSDo8mI8VUH1rnQzOXgXOQNWyIHhMMVazJNhEkYgizTHhvJSMVa5LqplSm305aspa9hq1TG1UtUrK)1nSoQrndngNGY2MLduXbE4a0DaPhG(dO6wWA3jNzek0bXYcCtKTy7KtqzBZYbQ8aok2bOr7a(qWWCMrOqhellWnr2ITto08bO7aspa9hy6dqGseUjoiNHgtSyj0QEfCmnFbYoanAhy6deMaZGBe5FDdRJAuZm5ezCmnFbYoanAhq1jdAdUQtQTYITtDdRJAuZqJXjwsXbQ8apCa6gEMk2ohEqzDl(1(I1PogXOkx0yIHhMMVazJNhEkYgizTHhvJSMVa5LqplSm305aspa9hq1TG1UtUrK)1nSoQrndngNGY2MLduXbE4a0ODagArTMICDQdoBlMVa1whSdq3bKEacuIWnXb5m0yIflHw1RGJP5lq2bKEGWeygCJi)RByDuJAMjNiJJP5lq2bKEavNmOn4QoP2kl2o1nSoQrndngNyjfhOcjh4Hdi9aQUfS2DYT5wzI)5cYjOSTz5avEaxDaPhG(dO6wWA3jNzek0bXYcCtKTy7KtqzBZYbQ8aok2bOr7a(qWWCMrOqhellWnr2ITto08bOB4zQy7C4bL1T4x7lwN6yeJQE56XedpmnFbYgpp8uKnqYAdptflvuJjkVy5avi5auA4zQy7C4bL1T4x7lwN6yeJQE9AmXWdtZxGSXZdpfzdKS2WJQrwZxG8sONfwMB6CaPhG(dW6GdL1T4x7lwN6qZ6GtqzBZYbOr7atFGWeygCOSUf)AFX6uhCmnFbYoaDdptfBNdpMrOqhellWnr2ITZrmQ6fLgtm8W08fiB88Wtr2ajRn8mvSurnMO8ILduHKdqPHNPITZHhZiuOdILf4MiBX25igv9YvJjgEyA(cKnEE4PiBGK1gEMkwQOgtuEXYbKCGxhq6byOpemmhglbs20r7UHsgVeMIIduHKd80di9aHjWm4qzDl(1(I1Po4yA(cKDaPhimbMb3iY)6gwh1OMzYjY4yA(cKDaPhGaLiCtCqodnMyXsOv9k4yA(cKDaPhq1jdAdUQtQTYITtDdRJAuZqJXjwsXbQqYbE4aspaRdouw3IFTVyDQdnRdobLTnldptfBNdpBUvM4FUGJyu1RNoMy4HP5lq245HNISbswB4zQyPIAmr5flhqYbEDaPhGH(qWWCySeizthT7gkz8sykkoqfsoWtpG0deMaZGdL1T4x7lwN6GJP5lq2bKEawhCOSUf)AFX6uhAwhCckBBwoqfh4LRpG0dq)bctGzWHY6w8RTsXGebhtZxGSdi9aQozqBWvDsTvwSDQByDuJAgAmoXskoqLh4HdqJ2bctGzWDmIt)lqoMMVazhGUHNPITZHNn3kt8pxWrmQ61dJjgEyA(cKnEE4PiBGK1gEMkwQOgtuEXYbKCGxhq6byOpemmhglbs20r7UHsgVeMIIduHKd80di9a0FGPpqycmdouw3IFTVyDQdoMMVazhGgTdeMaZGBe5FDdRJAuZm5ezCmnFbYoG0dq)bM(aeOeHBIdYzOXelwcTQxbhtZxGSdqJ2buDYG2GR6KARSy7u3W6Og1m0yCILuCGkpWdhGUdqJ2bctGzWHY6w8RTsXGebhtZxGSdi9aQozqBWvDsTvwSDQByDuJAgAmoXskoqfsoWdhGUHNPITZHNn3kt8pxWrmQ61toMy4HP5lq245HNISbswB4zQyPIAmr5flhOcjhGshq6byOpemmhglbs20r7UHsgVeMIIduHKd80di9atFagArT2sMMHk7NhRIInDgEMk2ohE2CRmX)CbhEQFLa1HrCWOmQ61igv96joMy4HP5lq245HNISbswB4rGYvPNB3iHZq4vTXbQ8aVE6bKEa6pGQBbRDNCOSUf)AFX6uhCckBBwoqLh4LRpanAhG1bhkRBXV2xSo1HM1bNGY2MLdq3WZuX25WRajl3P2Xio9VahXOQxpHXedpmnFbYgpp8uKnqYAdpQgznFbYlHEwyzUPZbKEag6dbdZHXsGKnD0UBOKXlHPO4avEakDaPhG(dmJb3MBL2PUHeCtflv8a0ODavNmOn4QoP2kl2o1nSoQrndnghtZxGSdi9a(qWWCMrOqhellWnr2ITto08bKEGPpWmgCJi)RDQBib3uXsfpaDdptfBNdpOSUf)ARumirmIrvVCrJjgEyA(cKnEE4PiBGK1gEMkwQOgtuEXYbQqYbO0bKEag6dbdZHXsGKnD0UBOKXlHPO4avEakn8mvSDo8GY6w8RTsXGeXWt9ReOomIdgLrvVgXOkk56XedpmnFbYgpp8uKnqYAdVWioyWJvg1rRNvH2vpCGkpWdhq6bcJ4GbpwzuhTMT4bQ4apm8mvSDo8knKqtqBgjdp1VsG6Wioyugv9AeJQO0RXedpmnFbYgpp8uKnqYAdVPpWmgCN6gsWnvSuXHNPITZHhX2cQzOXgXOkkrPXedpmnFbYgpp8uKnqYAdptflvuJjkVy5avi5au6aspW0hWhcgMZmcf6GyzbUjYwSDYHMpG0dm9buDlyT7KZmcf6GyzbUjYwSDYjOX(hEMk2ohEftrw4vTMqpBQyeJy45GjswL2ACmXOQxJjgEyA(cKnEE4PiBGK1gE(qWWCMrOqhellWnr2ITto08bKEacuIWnXb5m0yIflHw1RGJP5lq2bKEatflvuJjkVy5avk5aUA4zQy7C4XqlQ1QEfJyufLgtm8W08fiB88Wtr2ajRn88HGH5figdtnRBzobnvm8mvSDo8W5LHYRAeJQC1yIHhMMVazJNhEkYgizTH30hGQrwZxG85UfB6OHBI2Xio9VahEMk2ohE48Yq5vnIrvpDmXWdtZxGSXZdpfzdKS2WJ(dO6wWA3j3MBLj(NliNGY2MLduXbE4aspad9HGH5WyjqYMoA3nuY4qZhGgTdWqFiyyomwcKSPJ2DdLmEjmffhOId80dq3bKEa6pa86uhAckBBwoqLhq1TG1UtodTOwBjtZqL9ZjOSTz5aFCGxU(a0ODa41Po0eu22SCGkoGQBbRDNCBUvM4FUGCckBBwoaDdptfBNdp3nuY0Lzmziz4P(vcuhgXbJYOQxJyu1dJjgEyA(cKnEE4PiBGK1gEm0hcgMdJLajB6OD3qjJxctrXbQuYbC1bKEav3cw7o52CRmX)Cb5eu22SCGkpGRoanAhGH(qWWCySeizthT7gkz8sykkoqLh41WZuX25Wdglbs20rxcYsbo8u)kbQdJ4Grzu1RrmQ6jhtm8W08fiB88Wtr2ajRn8uDlyT7KBZTYe)ZfKtqzBZYbQ4apCaPhGH(qWWCySeizthT7gkz8sykkoqLh41WZuX25Wdglbs20rxcYsbo8u)kbQdJ4Grzu1RrmIHN1O2hIuIXeJQEnMy4HP5lq245HNISbswB45dbdZzgHcDqSSa3ezl2o5qZhq6biqjc3ehKZqJjwSeAvVcoMMVazhq6bmvSurnMO8ILduPKd4QHNPITZHhdTOwR6vmIrvuAmXWdtZxGSXZdpfzdKS2WJaLRsp3UrcNHWRAJdu5bO)aVC9b(4am0IAnf56uhCy3nuYqMomIdgLd4I9aU6a0DaPhGHwuRPixN6Gd7UHsgY0HrCWOCGkpWtEaPhy6dq1iR5lq(C3InD0Wnr7yeN(xGhGgTd4dbdZlUnI8MoA5TeCO5HNPITZHhoVmuEvJyuLRgtm8W08fiB88Wtr2ajRn8iq5Q0ZTBKWzi8Q24avEak9WbKEagArTMICDQdoS7gkzithgXbJYbQ4apCaPhy6dq1iR5lq(C3InD0Wnr7yeN(xGdptfBNdpCEzO8QgXOQNoMy4HP5lq245HNISbswB4n9byOf1AkY1Po4WUBOKHmDyehmkhq6bM(aunYA(cKp3TythnCt0ogXP)f4bOr7aWRtDOjOSTz5avEGhoanAhGyltJuXm4gJv4Ol3suoG0dqSLPrQygCJXkCckBBwoqLh4HHNPITZHhoVmuEvJyu1dJjgEMk2ohEUBOKPlZyYqYWdtZxGSXZJyu1toMy4HP5lq245HNISbswB4n9bOAK18fiFUBXMoA4MODmIt)lWHNPITZHhoVmuEvJyedpvtftlJYyIrvVgtm8W08fiB88Wtr2ajRn8OAK18fiVe6zHL5Mohq6biq5Q0ZTBKWzi8Q24avCGxp5WZuX25WR42iYB6OL3smIrvuAmXWdtZxGSXZdpfzdKS2Wt1TG1UtUn3kt8pxqobLTnlhq6bO)aMkwQOgtuEXYbQqYbO0bKEatflvuJjkVy5avk5apCaPhGaLRsp3UrcNHWRAJduXbE56d8XbO)aMkwQOgtuEXYbCXEGN8a0DaA0oGPILkQXeLxSCGkoWdhq6biq5Q0ZTBKWzi8Q24avCGN66dq3WZuX25WR42iYB6OL3smIrvUAmXWdtZxGSXZdpfzdKS2WJQrwZxG8sONfwMB6CaPhy6duAiH)MmUanM2)xJU0KNf4bKEav3cw7o52CRmX)Cb5eu22SCaPhGaLipwzuhT(PhOIdq)bC1b(4a(qWWCcuUkTQjeO5y7KtqzBZYbOB4zQy7C4z(T8MwSDQfRS)igv90XedpmnFbYgpp8uKnqYAdpQgznFbYlHEwyzUPZbKEGsdj83KXfOX0()A0LM8SapG0dq)buDlyT7KdL1T4x7lwN6GtqzBZYbOr7atFGWeygCOSUf)AFX6uhCmnFbYoG0dO6wWA3jNzek0bXYcCtKTy7KtqzBZYbOB4zQy7C4z(T8MwSDQfRS)igv9WyIHhMMVazJNhEkYgizTHNPILkQXeLxSCGkKCakDaPhGaLipwzuhT(PhOIdq)bC1b(4a(qWWCcuUkTQjeO5y7KtqzBZYbOB4zQy7C4z(T8MwSDQfRS)igv9KJjgEyA(cKnEE4PiBGK1gEunYA(cKxc9SWYCtNdi9aQUfS2DYT5wzI)5cYjOSTzz4zQy7C4vQnffcuh1OgkD3KO(FeJQEIJjgEyA(cKnEE4PiBGK1gEMkwQOgtuEXYbQqYbO0bKEa6padTOwBjtZqL9ZJvrXMohGgTdqSLPrQygCJXkCckBBwoqLsoWRNEa6gEMk2ohELAtrHa1rnQHs3njQ)hXigXWJkskBNJQOKRPKRFrjx)egEUnsUPtz4vn9zF6Q(CvvnmLdCGjQXdSYZnjoaCtoWxhmrYQ(Eac6cqlbzhO0Y4bmOOLTazhqvBPdw437PUjEaxnLdu9oPIKazh4lbkr4M4GCk)9arFGVeOeHBIdYPmhtZxGSVhG(xUKo(9EQBIh4HPCGQ3jvKei7aFdtGzWP83de9b(gMaZGtzoMMVazFpa9UYL0XV3tDt8apmLdu9oPIKazh4RQtg0gCk)9arFGVQozqBWPmhtZxGSVhG(xUKo(9EQBIh4jNYbQENursGSd8nmbMbNYFpq0h4BycmdoL5yA(cK99a07kxsh)Ep1nXd4IMYbQENursGSd8nmbMbNYFpq0h4BycmdoL5yA(cK99a07kxsh)Ep1nXd4IMYbQENursGSd8v1jdAdoL)EGOpWxvNmOn4uMJP5lq23dq)lxsh)Ep1nXd8Y1t5avVtQijq2b(gMaZGt5Vhi6d8nmbMbNYCmnFbY(Ea6DLlPJFVV3vtF2NUQpxvvdt5ahyIA8aR8CtIda3Kd81AuxWaA(7biOlaTeKDGslJhWGIw2cKDavTLoyHFVN6M4bC1uoq17KkscKDGVeOeHBIdYP83de9b(sGseUjoiNYCmnFbY(Ea6F5s6437PUjEGN4uoq17KkscKDGVHjWm4u(7bI(aFdtGzWPmhtZxGSVhGEk5s64377D10N9PR6Zvv1WuoWbMOgpWkp3K4aWn5aFziSbjIVhGGUa0sq2bkTmEadkAzlq2bu1w6Gf(9EQBIhGst5avVtQijq2b(gMaZGt5Vhi6d8nmbMbNYCmnFbY(Ealoq18N6PEa6F5s6437PUjEGhMYbQENursGSd4TYv)aL)mmxEax8de9bMkKDa2sDlBNhONrIfn5a0)iDhG(xUKo(9EQBIh4HPCGQ3jvKei7aFdtGzWP83de9b(gMaZGtzoMMVazFpa9VCjD879u3epWtoLdu9oPIKazhWBLR(bk)zyU8aU4hi6dmvi7aSL6w2opqpJelAYbO)r6oa9VCjD879u3epWtoLdu9oPIKazh4BycmdoL)EGOpW3WeygCkZX08fi77bO)LlPJFVN6M4bEct5avVtQijq2b8w5QFGYFgMlpGl(bI(atfYoaBPULTZd0ZiXIMCa6FKUdq)lxsh)Ep1nXd8eMYbQENursGSd8nmbMbNYFpq0h4BycmdoL5yA(cK99a0)YL0XV3tDt8aVC9uoq17KkscKDaVvU6hO8NH5Yd4IFGOpWuHSdWwQBz78a9msSOjhG(hP7a0)YL0XV3tDt8aVC9uoq17KkscKDGVHjWm4u(7bI(aFdtGzWPmhtZxGSVhG(xUKo(9EQBIh4fLMYbQENursGSd8nmbMbNYFpq0h4BycmdoL5yA(cK99a0)YL0XV3tDt8aVC1uoq17KkscKDGVHjWm4u(7bI(aFdtGzWPmhtZxGSVhGEk5s6437PUjEGxpDkhO6DsfjbYoWxcuIWnXb5u(7bI(aFjqjc3ehKtzoMMVazFpa9VCjD879u3epWRN4uoq17KkscKDGVHjWm4u(7bI(aFdtGzWPmhtZxGSVhGEk5s6437PUjEGxUOPCGQ3jvKei7aFdtGzWP83de9b(gMaZGtzoMMVazFpa9uYL0XV337QPp7tx1NRQQHPCGdmrnEGvEUjXbGBYb(Q6wWA3z57biOlaTeKDGslJhWGIw2cKDavTLoyHFVN6M4bEnLdu9oPIKazh4BycmdoL)EGOpW3WeygCkZX08fi77bO)LlPJFVN6M4bO0uoq17KkscKDGVHjWm4u(7bI(aFdtGzWPmhtZxGSVhG(xUKo(9EQBIh4joLdu9oPIKazh4BycmdoL)EGOpW3WeygCkZX08fi77bO)LlPJFVN6M4bEIt5avVtQijq2b(gMaZGt5Vhi6d8nmbMbNYCmnFbY(Ealoq18N6PEa6F5s6437PUjEGNWuoq17KkscKDGVHjWm4u(7bI(aFdtGzWPmhtZxGSVhG(xUKo(9EQBIh4jmLdu9oPIKazh4lbkr4M4GCk)9arFGVeOeHBIdYPmhtZxGSVhG(xUKo(9EQBIhWfnLdu9oPIKazh4BycmdoL)EGOpW3WeygCkZX08fi77bO)LlPJFVN6M4bCrt5avVtQijq2b(sGseUjoiNYFpq0h4lbkr4M4GCkZX08fi77bO)LlPJFVN6M4bE9AkhO6DsfjbYoW3WeygCk)9arFGVHjWm4uMJP5lq23dq)lxsh)Ep1nXd8Yvt5avVtQijq2b(gMaZGt5Vhi6d8nmbMbNYCmnFbY(Ea6PKlPJFVN6M4bE5QPCGQ3jvKei7aFjqjc3ehKt5Vhi6d8LaLiCtCqoL5yA(cK99a0)YL0XV3tDt8aVE6uoq17KkscKDGVHjWm4u(7bI(aFdtGzWPmhtZxGSVhGEx5s6437PUjEGxpmLdu9oPIKazh4BycmdoL)EGOpW3WeygCkZX08fi77bO3vUKo(9EQBIh41dt5avVtQijq2b(sGseUjoiNYFpq0h4lbkr4M4GCkZX08fi77bO)LlPJFVN6M4bE9eMYbQENursGSd8v1jdAdoL)EGOpWxvNmOn4uMJP5lq23dq)lxsh)EFVRM(SpDvFUQQgMYboWe14bw55MehaUjh4RdMizvARXVhGGUa0sq2bkTmEadkAzlq2bu1w6Gf(9EQBIh41uoq17KkscKDGVeOeHBIdYP83de9b(sGseUjoiNYCmnFbY(Ea6F5s64377D10N9PR6Zvv1WuoWbMOgpWkp3K4aWn5aFTg1(qKs89ae0fGwcYoqPLXdyqrlBbYoGQ2shSWV3tDt8aVMYbQENursGSd8LaLiCtCqoL)EGOpWxcuIWnXb5uMJP5lq23dq)lxsh)EFVRM(SpDvFUQQgMYboWe14bw55MehaUjh4RQPIPLr57biOlaTeKDGslJhWGIw2cKDavTLoyHFVN6M4bE6uoq17KkscKDGVHjWm4u(7bI(aFdtGzWPmhtZxGSVhG(xUKo(9(E)5KNBsGSd8eoGPITZdi2su437H3mPHxbo8Q2d8jOf1h4ZBUo1Xb(8Z6w8FVR2d8jOcL9rYbCrtEak5Ak56799UApWNXCXavczmJYbI(aFs(jp(ji8kWh)e0I6Yb(ei8arFGof)hq1qzCGWioyuoG76(agbpa6Yzufi7arFaXsfpGOtNdGzd5uFGOpGSfbsoa9wJ6cgqZhOAFrh)EFVnvSDw4Zeu1Y(w8HKhN7y78EBQy7SWNjOQL9T4djpcvq9gO8KPjJsSQXsTrSIgUZq3W652nsU3Mk2ol8zcQAzFl(qYJeBlOMHg7EFVR2dun7subfi7aivK8FGyLXde14bmv0KdSLdyuTvy(cKFVnvSDwKiVjtdtqSAeV3v7b(8yK18fy5EBQy7S8HKhPAK18f4KPjJsM7wSPJgUjAhJ40)cCsQMacLO6wWA3jVajl3P2Xio9Va5eu22Su5dsdtGzWlqYYDQDmIt)lW7TPITZYhsEKQrwZxGtMMmkPe6zHL5Mots1eqOetflvuJjkVyrYlP0pnXwMgPIzWngRWrxULOqJgXwMgPIzWngRW3SIxpq39UApWN2uRjk3BtfBNLpK8OruwI6OjemJjxyjeOCv652ns4meEvBuXt(Gu6NXG7yeN(xGCtflvKgTPdtGzWlqYYDQDmIt)lqoMMVaz0jLaLiNHWRAJkK8W92uX2z5djp6l6MPHHi)tUWsMXG7yeN(xGCtflvKgnFiyyouw3IFTvkgKi4qZ0OfMaZGBe5FDdRJAuZm5ezsNXGBZTs7u3qcUPILkkL(zm4gr(x7u3qcUPILksJMQBbRDNCJi)RByDuJAgAmobLTnlvO6wWA3j3x0ntddr(5miIfBNU4UIoA0GxN6qtqzBZsLs8HGH5(IUzAyiYpNbrSy78EBQy7S8HKh9rsbjuSPZKlSKzm4ogXP)fi3uXsfPrZhcgMdL1T4xBLIbjco0mnAHjWm4gr(x3W6Og1mtorM0zm42CR0o1nKGBQyPIsPFgdUrK)1o1nKGBQyPI0OP6wWA3j3iY)6gwh1OMHgJtqzBZsfQUfS2DY9rsbjuSPdNbrSy70f3v0rJg86uhAckBBwQuIpemm3hjfKqXMoCgeXITZ7TPITZYhsEuSo1rr7IbI5iJzm5clXhcgMdL1T4xxccMornhA(ExTh4ZsfwcIjoq1nH4aklpqqwhhKCGNEG5oWmwtCaFiy4YKhanv9bewj205aVE4afu1jRWpWNFSITAezhO2iSdOAgYoqSY4bSYbSdeK1Xbjhi6dqbIZhyJdqqJz(cKFVnvSDw(qYJwQWsqmHwzcXKlSKzm4ogXP)fi3uXsfPrZhcgMdL1T4xBLIbjco0mnAHjWm4gr(x3W6Og1mtorM0zm42CR0o1nKGBQyPIsPFgdUrK)1o1nKGBQyPI0OP6wWA3j3iY)6gwh1OMHgJtqzBZsfQUfS2DYTuHLGycTYecodIyX2PlUROJgn41Po0eu22SuPKxpCVnvSDw(qYJgrzjQNHefCYfwIPILkQXeLxSuHekrJg9eOe5meEvBuHKhKsGYvPNB3iHZq4vTrfsEsxt392uX2z5djpcVe0x0nBYfwYmgChJ40)cKBQyPI0O5dbdZHY6w8RTsXGebhAMgTWeygCJi)RByDuJAMjNit6mgCBUvAN6gsWnvSurP0pJb3iY)AN6gsWnvSurA0uDlyT7KBe5FDdRJAuZqJXjOSTzPcv3cw7o5Wlb9fDZ4miIfBNU4UIoA0GxN6qtqzBZsLs8HGH5Wlb9fDZ4miIfBN3BtfBNLpK8OV5OByDqwffLjxyj(qWWCOSUf)6sqW0jQ5qZsnvSurnMO8IfjVU3v7b(uzBg2MB6CGpplbsGzCGpfcZbcpWwoGDGzY2Kn(V3Mk2olFi5Xgk8jOrXKlSewhCQlbsGzONfMdeYjimbl1MVaLoDycmdouw3IFTVyDQdPttSLPrQygCJXkC0LBjk3BtfBNLpK8ydf(e0OyYfwcRdo1LajWm0ZcZbc5eeMGLAZxGsnvSurnMO8ILkKqjP0pDycmdouw3IFTVyDQdA0ctGzWHY6w8R9fRtDiv1TG1Utouw3IFTVyDQdobLTnl0DVnvSDw(qYJnu4tqJIjxyjeOeHBIdYlqZiPeeBtP0Z6Gdt6sOHrQiHtqycwQnFbsJgRdUVOBMEwyoqiNGWeSuB(cKU7D1EGptfBNhyQBjk3BtfBNLpK8OYecTPITtTylXKPjJsunvmTmk3BtfBNLpK8OYecTPITtTylXKPjJsuDlyT7SCVnvSDw(qYJeOuBQy7ul2smzAYOeRrDbdO5jxyjMkwQOgtuEXsfsOKu6vDlyT7KZqlQ1wY0muz)CckBBwQ8LRLoDycmdodHxbsJMQBbRDNCgcVcKtqzBZsLVCT0WeygCgcVcKoPtZqlQ1wY0muz)8yvuSPZ92uX2z5djpsGsTPITtTylXKPjJsSg1(qKsm5clXuXsf1yIYlwQqcLKYqlQ1wY0muz)8yvuSPZ92uX2z5djpsGsTPITtTylXKPjJsCWejRsBno5clXuXsf1yIYlwQqcLKs)0m0IATLmndv2ppwffB6iLEv3cw7o5m0IATLmndv2pNGY2MLkE5APthMaZGZq4vG0OP6wWA3jNHWRa5eu22SuXlxlnmbMbNHWRaPJU7TPITZYhsEuzcH2uX2PwSLyY0KrjoyIKvn5clXuXsf1yIYlwK86EFVR2d8zD18bEgIuI7TPITZc3Au7drkHegArTw1RyYfwIpemmNzek0bXYcCtKTy7KdnlLaLiCtCqodnMyXsOv9kKAQyPIAmr5flvkXv3BtfBNfU1O2hIuIpK8ioVmuEvtUWsiq5Q0ZTBKWzi8Q2Os6F56pyOf1AkY1Po4WUBOKHmDyehmkUyDfDszOf1AkY1Po4WUBOKHmDyehmkv(KsNMQrwZxG85UfB6OHBI2Xio9VaPrZhcgMxCBe5nD0YBj4qZ3BtfBNfU1O2hIuIpK8ioVmuEvtUWsiq5Q0ZTBKWzi8Q2Osk9GugArTMICDQdoS7gkzithgXbJsfpiDAQgznFbYN7wSPJgUjAhJ40)c8EBQy7SWTg1(qKs8HKhX5LHYRAYfwY0m0IAnf56uhCy3nuYqMomIdgfPtt1iR5lq(C3InD0Wnr7yeN(xG0ObVo1HMGY2MLkFGgnITmnsfZGBmwHJUClrrkXwMgPIzWngRWjOSTzPYhU3Mk2olCRrTpePeFi5r3nuY0Lzmzi5EBQy7SWTg1(qKs8HKhX5LHYRAYfwY0unYA(cKp3TythnCt0ogXP)f49(ExTh4Z6Q5d4Hb0892uX2zHBnQlyanlXYFnlztUWsyOf1AkY1Po4WUBOKHmDyehmkvir9ReOgtuEXcnAeBzAKkMb3ySchD5wIIuITmnsfZGBmwHtqzBZsLsE96EBQy7SWTg1fmGM)qYJw(RzjBYfwcdTOwtrUo1bh2DdLmKPdJ4GrPcjpCVnvSDw4wJ6cgqZFi5rgArTw1RyYfwIpemmNzek0bXYcCtKTy7KdnlLaLiCtCqodnMyXsOv9kKAQyPIAmr5flvkXv3BtfBNfU1OUGb08hsEeNxgkVQjxyjtt1iR5lq(C3InD0Wnr7yeN(xG3BtfBNfU1OUGb08hsEeglbs20rxcYsboP6xjqDyehmksEn5clHH(qWWCySeizthT7gkz8sykkQuIRKQ6wWA3j3MBLj(NliNGY2MLkD192uX2zHBnQlyan)HKhHXsGKnD0LGSuGtQ(vcuhgXbJIKxtUWsyOpemmhglbs20r7UHsgVeMIIkFDVnvSDw4wJ6cgqZFi5rySeizthDjilf4KQFLa1HrCWOi51KlSecuI8yLrD06Nwj9QUfS2DYzOf1AlzAgQSFobLTnlsNombMbNHWRaPrt1TG1UtodHxbYjOSTzrAycmdodHxbs39(ExTh4trhBNLdyj7aDuJKd05bGk492uX2zHR6wWA3zrYChBNtUWsMXG7yeN(xGCtflvKgnFiyyouw3IFTvkgKi4qZ0OfMaZGBe5FDdRJAuZm5ezsPFgdUrK)1o1nKGBQyPI0OnJb3MBL2PUHeCtflvKgnv3cw7o5gr(x3W6Og1m0yCckBBwQaEDQdnbLTnl0DVnvSDw4QUfS2Dw(qYJqfuVbkpzAYOKnlkcuy(cu7cqwgqYAgsDv4KlSe6vDlyT7KdL1T4x7lwN6GtqzBZcnAQUfS2DYzgHcDqSSa3ezl2o5eu22SqNu6NXGBe5FTtDdj4MkwQinAZyWT5wPDQBib3uXsfLoDycmdUrK)1nSoQrnZKtKrJwyehm4XkJ6O1ZQqtjxx5d0DVnvSDw4QUfS2Dw(qYJqfuVbkpzAYOeztz(euxQrm0YqLvn5clr1TG1UtUn3kt8pxqobLTnlv(Gu6NgDbODEgz8nlkcuy(cu7cqwgqYAgsDvinAQUfS2DY3SOiqH5lqTlazzajRzi1vHCckBBwO7EBQy7SWvDlyT7S8HKhHkOEduEY0KrjmcAm4LGAQyPGIjxyjQUfS2DYT5wzI)5cYjOSTzrkbkrESYOoA9tR0rXKs)0OlaTZZiJVzrrGcZxGAxaYYaswZqQRcPrt1TG1Ut(MffbkmFbQDbildizndPUkKtqzBZcD3BtfBNfUQBbRDNLpK8iub1BGYtMMmkHzekK7o1murHMAtm1g)tUWsuDlyT7KBZTYe)ZfKtqzBZIu6NgDbODEgz8nlkcuy(cu7cqwgqYAgsDvinAQUfS2DY3SOiqH5lqTlazzajRzi1vHCckBBwO7EBQy7SWvDlyT7S8HKhHkOEduUm5clr1TG1UtUn3kt8pxqobLTnlsPFA0fG25zKX3SOiqH5lqTlazzajRzi1vH0OP6wWA3jFZIIafMVa1UaKLbKSMHuxfYjOSTzHU7D1EGQ3TG1UZY92uX2zHR6wWA3z5djpAe5FDdRJAuZqJn5clr1TG1Utouw3IFTVyDQdobLTnlv6kPQUfS2DYzgHcDqSSa3ezl2o5eu22SuPRKgMaZGdL1T4x7lwN6GgTPdtGzWHY6w8R9fRtDCVR2d49NQd8SyDQJd4EJ6d8jgHIdmbXYcCtKTy78al8bGIvSvJB6CGoQrYb(eJqXbMGyzbUjYwSDEaFiy4YKhiQ7cEaFCtNd8jOXelwIdu9EftEGpLiywnUi7aFQ6SeKUSX)bAYbQMdKKM4aFkdLoiHFGptu6dOQrffLdSWhq1jBJTZYbmcEazmoq0hyZsGg7a1TGDa4MCGpBUvM4FUG87TPITZcx1TG1UZYhsEekRBXV2xSo1XKlSeQgznFbYlHEwyzUPJu6vDlyT7KBe5FDdRJAuZqJXjOSTzPIhOtk9QUfS2DYzgHcDqSSa3ezl2o5eu22SuPJIrJMpemmNzek0bXYcCtKTy7KdntNu6NMaLiCtCqodnMyXsOv9kOrB6WeygCJi)RByDuJAMjNiJgnvNmOn4QoP2kl2o1nSoQrndngNyjfv(aD37Q9aE)P6aplwN64aU3O(aF2CRmX)CbpWcFGOgpGQBbRDNhOHpWNn3kt8pxWdSLdiA3haZgYPMFGpn6cqlblh4tqJjwSehO69kM8avVtQTYITZd0WhiQXd8jOXoGLSd8ze5)d0WhiQXd8jMCISdeTdg1iHFVnvSDw4QUfS2Dw(qYJqzDl(1(I1PoMCHLq1iR5lqEj0ZclZnDKsVQBbRDNCJi)RByDuJAgAmobLTnlv8anAm0IAnf56uhC2wmFbQToy0jLaLiCtCqodnMyXsOv9kKgMaZGBe5FDdRJAuZm5ezsvDYG2GR6KARSy7u3W6Og1m0yCILuuHKhKQ6wWA3j3MBLj(NliNGY2MLkDLu6vDlyT7KZmcf6GyzbUjYwSDYjOSTzPshfJgnFiyyoZiuOdILf4MiBX2jhAMU7TPITZcx1TG1UZYhsEekRBXV2xSo1XKlSetflvuJjkVyPcju6EBQy7SWvDlyT7S8HKhzgHcDqSSa3ezl2oNCHLq1iR5lqEj0ZclZnDKspRdouw3IFTVyDQdnRdobLTnl0OnDycmdouw3IFTVyDQd6U3Mk2olCv3cw7olFi5rMrOqhellWnr2ITZjxyjMkwQOgtuEXsfsO092uX2zHR6wWA3z5djpAZTYe)ZfCYfwIPILkQXeLxSi5Lug6dbdZHXsGKnD0UBOKXlHPOOcjpvAycmdouw3IFTVyDQdPHjWm4gr(x3W6Og1mtorMucuIWnXb5m0yIflHw1RqQQtg0gCvNuBLfBN6gwh1OMHgJtSKIkK8GuwhCOSUf)AFX6uhAwhCckBBwU3Mk2olCv3cw7olFi5rBUvM4FUGtUWsmvSurnMO8IfjVKYqFiyyomwcKSPJ2DdLmEjmffvi5PsdtGzWHY6w8R9fRtDiL1bhkRBXV2xSo1HM1bNGY2MLkE5AP0hMaZGdL1T4xBLIbjcPQozqBWvDsTvwSDQByDuJAgAmoXskQ8bA0ctGzWDmIt)lq6U3Mk2olCv3cw7olFi5rBUvM4FUGtUWsmvSurnMO8IfjVKYqFiyyomwcKSPJ2DdLmEjmffvi5PsPF6WeygCOSUf)AFX6uh0OfMaZGBe5FDdRJAuZm5ezsPFAcuIWnXb5m0yIflHw1RGgnvNmOn4QoP2kl2o1nSoQrndngNyjfv(aD0OfMaZGdL1T4xBLIbjcPQozqBWvDsTvwSDQByDuJAgAmoXskQqYd0DVnvSDw4QUfS2Dw(qYJ2CRmX)CbNu9ReOomIdgfjVMCHLyQyPIAmr5flviHsszOpemmhglbs20r7UHsgVeMIIkK8uPtZqlQ1wY0muz)8yvuSPZ92uX2zHR6wWA3z5djpwGKL7u7yeN(xGtUWsiq5Q0ZTBKWzi8Q2OYxpvk9QUfS2DYHY6w8R9fRtDWjOSTzPYxUMgnwhCOSUf)AFX6uhAwhCckBBwO7EBQy7SWvDlyT7S8HKhHY6w8RTsXGeXKlSeQgznFbYlHEwyzUPJug6dbdZHXsGKnD0UBOKXlHPOOskjL(zm42CR0o1nKGBQyPI0OP6KbTbx1j1wzX2PUH1rnQzOXK6dbdZzgHcDqSSa3ezl2o5qZsNEgdUrK)1o1nKGBQyPI0DVnvSDw4QUfS2Dw(qYJqzDl(1wPyqIys1VsG6WioyuK8AYfwIPILkQXeLxSuHekjLH(qWWCySeizthT7gkz8sykkQKs3BtfBNfUQBbRDNLpK8yPHeAcAZizs1VsG6WioyuK8AYfwsyehm4XkJ6O1ZQq7QhQ8bPHrCWGhRmQJwZwSIhU3Mk2olCv3cw7olFi5rITfuZqJn5clz6zm4o1nKGBQyPI3BtfBNfUQBbRDNLpK8yXuKfEvRj0ZMkMCHLyQyPIAmr5flviHssN2hcgMZmcf6GyzbUjYwSDYHMLoTQBbRDNCMrOqhellWnr2ITtobn2)9(ExThO6nvmTmoWN5VInwSCVnvSDw4QMkMwgfjf3grEthT8wIjxyjunYA(cKxc9SWYCthPeOCv652ns4meEvBuXRN8ExThWdJde9bGk4bm4ajhWMB1b2Yb68av)toGvoq0hyMGuXmoqtfjkBEEtNd8P)uCa31RapqbJytNdanFGQ)jFl3BtfBNfUQPIPLr5djpwCBe5nD0YBjMCHLO6wWA3j3MBLj(NliNGY2MfP0BQyPIAmr5flviHssnvSurnMO8ILkL8GucuUk9C7gjCgcVQnQ4LR)GEtflvuJjkVyXf7tshnAMkwQOgtuEXsfpiLaLRsp3UrcNHWRAJkEQRP7EBQy7SWvnvmTmkFi5rZVL30ITtTyL9NCHLq1iR5lqEj0ZclZnDKoDPHe(BY4c0yA)Fn6stEwGsvDlyT7KBZTYe)ZfKtqzBZIucuI8yLrD06Nwb9U6dFiyyobkxLw1ec0CSDYjOSTzHU7TPITZcx1uX0YO8HKhn)wEtl2o1Iv2FYfwcvJSMVa5LqplSm30rAPHe(BY4c0yA)Fn6stEwGsPx1TG1Utouw3IFTVyDQdobLTnl0OnDycmdouw3IFTVyDQdPQUfS2DYzgHcDqSSa3ezl2o5eu22Sq392uX2zHRAQyAzu(qYJMFlVPfBNAXk7p5clXuXsf1yIYlwQqcLKsGsKhRmQJw)0kO3vF4dbdZjq5Q0QMqGMJTtobLTnl0DVnvSDw4QMkMwgLpK8yP2uuiqDuJAO0DtI6)jxyjunYA(cKxc9SWYCthPQUfS2DYT5wzI)5cYjOSTz5EBQy7SWvnvmTmkFi5XsTPOqG6Og1qP7Me1)tUWsmvSurnMO8ILkKqjP0ZqlQ1wY0muz)8yvuSPdnAeBzAKkMb3yScNGY2MLkL86P0DVV3v7b820rGhycJ4GX92uX2zH7GjswLegArTw1RyYfwIpemmVaXyyQzDlZjOPcPtt1iR5lq(C3InD0Wnr7yeN(xG0OnJb3Xio9Va5MkwQ492uX2zH7Gjsw1hsEKHwuRv9kMCHLqGYvPNB3iHZq4vTrLVCL0PPAK18fiFUBXMoA4MODmIt)lW7TPITZc3btKSQpK8OL)AwYMCHLO6wWA3j3MBLj(NliNGY2MfP0hMaZGZq4vGCmnFbYOrt1uX0YGNRtDOHnKgncuIWnXb5Z1OrA5oXcD3BtfBNfUdMizvFi5r3nuY0LzmzizYfwcd9HGH5WyjqYMoA3nuY4LWuuuXtV3Mk2olChmrYQ(qYJUBOKPlZyYqYKlSeg6dbdZHXsGKnD0UBOKXHMLQ6wWA3j3MBLj(NliNGY2MLkEqk9thMaZGdL1T4x7lwN6GgTWeygCJi)RByDuJAMjNitQQtg0gCvNuBLfBN6gwh1OMHgJtSKIkFGgTPdtGzWnI8VUH1rnQzMCImPQozqBWvDsTvwSDQByDuJAgAmoXskQqYd0OnTQtg0gCvNuBLfBN6gwh1OMHgJU7TPITZc3btKSQpK8O7gkz6YmMmKm5clHH(qWWCySeizthT7gkzCOzPHjWm4qzDl(1(I1PoKs)0HjWm4gr(x3W6Og1mtorMuvNmOn4QoP2kl2o1nSoQrndngNyjfv(anAHjWm4gr(x3W6Og1mtorMuvNmOn4QoP2kl2o1nSoQrndngNyjfvi5b6KsVQBbRDNCOSUf)AFX6uhCckBBwQ4LRLonRdouw3IFTVyDQdnRdobLTnl0OP6wWA3j3MBLj(NliNGY2MLkE5A6U3Mk2olChmrYQ(qYJm0IATQxXKlSecuUk9C7gjCgcVQnQKsUw60unYA(cKp3TythnCt0ogXP)f492uX2zH7Gjsw1hsEeglbs20rxcYsbo5clHH(qWWCySeizthT7gkz8sykkQ8192uX2zH7Gjsw1hsEeglbs20rxcYsbo5clHH(qWWCySeizthT7gkz8sykkQ8PsvDlyT7KBZTYe)ZfKtqzBZsLpiL(PdtGzWHY6w8R9fRtDqJwycmdUrK)1nSoQrnZKtKjv1jdAdUQtQTYITtDdRJAuZqJXjwsrLpqJ20HjWm4gr(x3W6Og1mtorMuvNmOn4QoP2kl2o1nSoQrndngNyjfvi5bA0Mw1jdAdUQtQTYITtDdRJAuZqJr392uX2zH7Gjsw1hsEeglbs20rxcYsbo5clHH(qWWCySeizthT7gkz8sykkQ8PsdtGzWHY6w8R9fRtDiL(PdtGzWnI8VUH1rnQzMCImPQozqBWvDsTvwSDQByDuJAgAmoXskQ8bA0ctGzWnI8VUH1rnQzMCImPQozqBWvDsTvwSDQByDuJAgAmoXskQqYd0jLEv3cw7o5qzDl(1(I1Po4eu22Su5lxtJMQBbRDNCBUvM4FUGCckBBwQ8LRLY6GdL1T4x7lwN6qZ6GtqzBZcD3BtfBNfUdMizvFi5rgArTw1RyYfwY0unYA(cKp3TythnCt0ogXP)f49(EBQy7SWDWejRsBnkHHwuRv9kMCHL4dbdZzgHcDqSSa3ezl2o5qZsjqjc3ehKZqJjwSeAvVcPMkwQOgtuEXsLsC19UApq1aMizvh4Z6Q5d8PGSnzJ)7TPITZc3btKSkT14hsEeNxgkVQjxyj(qWW8ceJHPM1TmNGMkU3Mk2olChmrYQ0wJFi5rCEzO8QMCHLmnvJSMVa5ZDl20rd3eTJrC6FbEVnvSDw4oyIKvPTg)qYJUBOKPlZyYqYKQFLa1HrCWOi51KlSe6vDlyT7KBZTYe)ZfKtqzBZsfpiLH(qWWCySeizthT7gkzCOzA0yOpemmhglbs20r7UHsgVeMIIkEkDsPhEDQdnbLTnlvQ6wWA3jNHwuRTKPzOY(5eu22S8XlxtJg86uhAckBBwQq1TG1UtUn3kt8pxqobLTnl0DVnvSDw4oyIKvPTg)qYJWyjqYMo6sqwkWjv)kbQdJ4GrrYRjxyjm0hcgMdJLajB6OD3qjJxctrrLsCLuv3cw7o52CRmX)Cb5eu22SuPROrJH(qWWCySeizthT7gkz8sykkQ8192uX2zH7GjswL2A8djpcJLajB6OlbzPaNu9ReOomIdgfjVMCHLO6wWA3j3MBLj(NliNGY2MLkEqkd9HGH5WyjqYMoA3nuY4LWuuu5RHNbf1nz45TYqcl2oRoXGJrmIXaa]] )

end
