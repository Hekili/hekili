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


    spec:RegisterPack( "Unholy", 20201216, [[d8eu5bqifPEKQGCjQaLnrK(KQuJcP4uiLwfvGOxPkQzPiSlu9lvrgMuP6yQswgsupJkKPPkW1ufABsLsFtvqzCsLIoNQGQ1PiX8Kk5EeX(KkCqvLkluvjpKkutuvP4IsLcTrvLsKpsfOAKQkLOoPQsvwPQIxQQusMPIKUPQsvPDkv0pvvkPgkvGWsvvk1tPktvr0vvvkHTQQuv8vPsbJfjYEv4VKAWqomLftv9ysMmkxgSzO6ZuPrlvDALwTQsv1RrcZMWTjQDl63sgUI64ubSCepxktx46qz7iPVtfnEQGoVQQ1tfinFKQ9RYJxJjhEmlGrNuU7uU7VO8RUL39U5dEWd62Hx8pddVztrH5cdV0KHH33ISVe)dVz7xugBm5WRvyefm86JyUnLNEYDJEmFUQKFQTYycl2kvedpEQTYQNgE(yRi(E5WF4XSagDs5Ut5U)IYV6wE37Mp4bo6Hp8AZGA0jLFKYdV(LXGC4p8yqtn8EOd9nGf9h6BvUU9XH(wK9L4)(8qh6Bafi7dKd9QBN4quU7uU73N7ZdDOVJ99J1cziJ2HI6qFt(np9na(kGN(gWI(2H(gm4qrDOkf)hsvyzCOWiUq0oKZ(6qgboe4Wzqfa7qrDiXsfoKOs3dbzH52FOOoKSfbqoenwb6geyZh6HErlF4j2w0gto8Sc0niWMhto681yYHhKMVayJVgEkYgazTHhdSOxtrUU9bh3zHLmGPdJ4cr7qDi5qQFLa0qcYl0oeD6hIyltduHm4gJ14Gd3w0oK0drSLPbQqgCJXACciBB2ouxso0RxdptfBLdpl)1SKnIrNuEm5WdsZxaSXxdpfzdGS2WJbw0RPix3(GJ7SWsgW0HrCHODOoKCOhhEMk2khEw(RzjBeJoD0yYHhKMVayJVgEkYgazTHNpgooNzek0bXYgErKTyRKJnFiPhIGLaErCbodmMyHwOv1k4qA(cGDiPhYuXsf0qcYl0ouxsoKJgEMk2khEmWIETQwXigD(GXKdpinFbWgFn8uKnaYAdVPpevJSMVa4Zvj20vJxeTRrCRFbm8mvSvo8G5LbYRAeJoFCm5WdsZxaSXxdptfBLdpCOfaztxDlilfWWtr2aiRn8yGpgoohhAbq20v7SWsgVfMIId1LKd5Odj9qQQeSYzYT5szI)5gWjGSTz7qDDihn8u)kbOdJ4crB05Rrm6SBhto8G08faB81WZuXw5WdhAbq20v3cYsbm8uKnaYAdpg4JHJZXHwaKnD1olSKXBHPO4qDDOxdp1Vsa6WiUq0gD(AeJoFyJjhEqA(cGn(A4zQyRC4HdTaiB6QBbzPagEkYgazTHhblbESYGok9douxhIMdPQsWkNjNbw0RTKPzGY(5eq22SDiPhA6dfMaYGZa8vaCinFbWoeD6hsvLGvotodWxbWjGSTz7qspuycidodWxbWH08fa7q0o8u)kbOdJ4crB05RrmIHNlKazvJjhD(Am5WdsZxaSXxdpfzdGS2WZhdhN3Wymi1SQK5eWuXHKEOPpevJSMVa4Zvj20vJxeTRrCRFbCi60p0meCxJ4w)cGBQyPcdptfBLdpgyrVwvRyeJoP8yYHhKMVayJVgEkYgazTHhblxLEUCceodWx1ghQRd9Yrhs6HM(qunYA(cGpxLytxnEr0UgXT(fWWZuXw5WJbw0Rv1kgXOthnMC4bP5la24RHNISbqwB4PQsWkNj3MlLj(NBaNaY2MTdj9q0COWeqgCgGVcGdP5la2HOt)qQIkKwg8CD7dnUbhIo9drWsaViUaFUhmsjxj04qA(cGDiAhEMk2khEw(RzjBeJoFWyYHhKMVayJVgEkYgazTHhd8XWX54qlaYMUANfwY4TWuuCOoo0dgEMk2khEolSKPBZqYaYigD(4yYHhKMVayJVgEkYgazTHhd8XWX54qlaYMUANfwY4yZhs6HuvjyLZKBZLYe)ZnGtazBZ2H64qpEiPhIMdn9HctazWXY(s8R9fRBFWH08fa7q0PFOWeqgCJi)RlCD0dAMjNaJdP5la2HKEivLmSn4QkPwkl2k1fUo6bndmgNyjfhQRd94HOt)qtFOWeqgCJi)RlCD0dAMjNaJdP5la2HKEivLmSn4QkPwkl2k1fUo6bndmgNyjfhQdjh6XdrN(HM(qQkzyBWvvsTuwSvQlCD0dAgymoKMVayhI2HNPITYHNZclz62mKmGmIrND7yYHhKMVayJVgEkYgazTHhd8XWX54qlaYMUANfwY4yZhs6HctazWXY(s8R9fRBFWH08fa7qspenhA6dfMaYGBe5FDHRJEqZm5eyCinFbWoK0dPQKHTbxvj1szXwPUW1rpOzGX4elP4qDDOhpeD6hkmbKb3iY)6cxh9GMzYjW4qA(cGDiPhsvjdBdUQsQLYITsDHRJEqZaJXjwsXH6qYHE8q0EiPhIMdPQsWkNjhl7lXV2xSU9bNaY2MTd1XHE19dj9qtFiwfCSSVe)AFX62hAwfCciBB2oeD6hsvLGvotUnxkt8p3aobKTnBhQJd9Q7hI2HNPITYHNZclz62mKmGmIrNpSXKdpinFbWgFn8uKnaYAdpcwUk9C5eiCgGVQnouxhIYD)qsp00hIQrwZxa85QeB6QXlI21iU1VagEMk2khEmWIETQwXigD2nhto8G08faB81Wtr2aiRn8yGpgoohhAbq20v7SWsgVfMIId11HEn8mvSvo8WHwaKnD1TGSuaJy05dFm5WdsZxaSXxdpfzdGS2WJb(y44CCOfaztxTZclz8wykkouxh6bhs6HuvjyLZKBZLYe)ZnGtazBZ2H66qpEiPhIMdn9HctazWXY(s8R9fRBFWH08fa7q0PFOWeqgCJi)RlCD0dAMjNaJdP5la2HKEivLmSn4QkPwkl2k1fUo6bndmgNyjfhQRd94HOt)qtFOWeqgCJi)RlCD0dAMjNaJdP5la2HKEivLmSn4QkPwkl2k1fUo6bndmgNyjfhQdjh6XdrN(HM(qQkzyBWvvsTuwSvQlCD0dAgymoKMVayhI2HNPITYHho0cGSPRUfKLcyeJoF19XKdpinFbWgFn8uKnaYAdpg4JHJZXHwaKnD1olSKXBHPO4qDDOhCiPhkmbKbhl7lXV2xSU9bhsZxaSdj9q0COPpuycidUrK)1fUo6bnZKtGXH08fa7qspKQsg2gCvLulLfBL6cxh9GMbgJtSKId11HE8q0PFOWeqgCJi)RlCD0dAMjNaJdP5la2HKEivLmSn4QkPwkl2k1fUo6bndmgNyjfhQdjh6Xdr7HKEiAoKQkbRCMCSSVe)AFX62hCciBB2ouxh6v3peD6hsvLGvotUnxkt8p3aobKTnBhQRd9Q7hs6HyvWXY(s8R9fRBFOzvWjGSTz7q0o8mvSvo8WHwaKnD1TGSuaJy05RxJjhEqA(cGn(A4PiBaK1gEtFiQgznFbWNRsSPRgViAxJ4w)cy4zQyRC4Xal61QAfJyedpgGByIym5OZxJjhEMk2khEYBY04eaCqHHhKMVayJVgXOtkpMC4bP5la24RHxnp8Aqm8mvSvo8OAK18fWWJQjWGHNQkbRCM8gMSCLAxJ4w)cGtazBZ2H66qpEiPhkmbKbVHjlxP21iU1Va4qA(cGn8OAeDAYWWBUkXMUA8IODnIB9lGrm60rJjhEqA(cGn(A4vZdVgedptfBLdpQgznFbm8OAcmy4zQyPcAib5fAhsYHEDiPhIMdn9Hi2Y0avidUXyno4WTfTdrN(Hi2Y0avidUXyn(MhQJd96Xdr7WJQr0PjddVwONfwMB6oIrNpym5WdsZxaSXxdpfzdGS2WJGLRspxobcNb4RAJd1XH62hpK0drZHMHG7Ae36xaCtflv4q0PFOPpuycidEdtwUsTRrCRFbWH08fa7q0EiPhIGLaNb4RAJd1HKd94WZuXw5WZiklbDuecKXigD(4yYHhKMVayJVgEkYgazTH3meCxJ4w)cGBQyPchIo9d5JHJZXY(s8RTwZWebhB(q0PFOWeqgCJi)RlCD0dAMjNaJdP5la2HKEOzi42CP0U9fMGBQyPchs6HO5qZqWnI8V2TVWeCtflv4q0PFivvcw5m5gr(xx46Oh0mWyCciBB2ouhhsvLGvotUVOkMghJ8Zzyel2kp0thYrhI2drN(HWx3(qtazBZ2H6sYH8XWX5(IQyACmYpNHrSyRC4zQyRC45lQIPXXi)Jy0z3oMC4bP5la24RHNISbqwB4ndb31iU1Va4MkwQWHOt)q(y44CSSVe)AR1mmrWXMpeD6hkmbKb3iY)6cxh9GMzYjW4qA(cGDiPhAgcUnxkTBFHj4MkwQWHKEiAo0meCJi)RD7lmb3uXsfoeD6hsvLGvotUrK)1fUo6bndmgNaY2MTd1XHuvjyLZK7dKgqOytxodJyXw5HE6qo6q0Ei60pe(62hAciBB2ouxsoKpgoo3hinGqXMUCggXITYHNPITYHNpqAaHInDhXOZh2yYHhKMVayJVgEkYgazTHNpgoohl7lXVUfeiDJEo28WZuXw5WtSU9rt)9JXCLHmgXOZU5yYHhKMVayJVgEkYgazTH3meCxJ4w)cGBQyPchIo9d5JHJZXY(s8RTwZWebhB(q0PFOWeqgCJi)RlCD0dAMjNaJdP5la2HKEOzi42CP0U9fMGBQyPchs6HO5qZqWnI8V2TVWeCtflv4q0PFivvcw5m5gr(xx46Oh0mWyCciBB2ouhhsvLGvotULkOfetOvMqWzyel2kp0thYrhI2drN(HWx3(qtazBZ2H6sYHE94WZuXw5WZsf0cIj0ktigXOZh(yYHhKMVayJVgEkYgazTHNPILkOHeKxODOoKCikFi60penhIGLaNb4RAJd1HKd94HKEicwUk9C5eiCgGVQnouhsou329dr7WZuXw5WZiklb9mMObJy05RUpMC4bP5la24RHNISbqwB4ndb31iU1Va4MkwQWHOt)q(y44CSSVe)AR1mmrWXMpeD6hkmbKb3iY)6cxh9GMzYjW4qA(cGDiPhAgcUnxkTBFHj4MkwQWHKEiAo0meCJi)RD7lmb3uXsfoeD6hsvLGvotUrK)1fUo6bndmgNaY2MTd1XHuvjyLZKJVeWxufJZWiwSvEONoKJoeThIo9dHVU9HMaY2MTd1LKd5JHJZXxc4lQIXzyel2khEMk2khE4lb8fvXgXOZxVgto8G08faB81Wtr2aiRn88XWX5yzFj(1TGaPB0ZXMpK0dzQyPcAib5fAhsYHEn8mvSvo88nxDHRdYQOOnIrNVO8yYHhKMVayJVgEkYgazTHhRco1LGjGm0ZcZfd4eaNaTEZxahs6HM(qHjGm4yzFj(1(I1Tp4qA(cGDiPhA6drSLPbQqgCJXACWHBlAdptfBLdVcl8jGrXigD(YrJjhEqA(cGn(A4PiBaK1gESk4uxcMaYqplmxmGtaCc06nFbCiPhYuXsf0qcYl0ouhsoeLpK0drZHM(qHjGm4yzFj(1(I1Tp4qA(cGDi60puycidow2xIFTVyD7doKMVayhs6HuvjyLZKJL9L4x7lw3(GtazBZ2HOD4zQyRC4vyHpbmkgXOZxpym5WdsZxaSXxdpfzdGS2WJGLaErCbEdBgiTGyBYH08fa7qspenhIvbhNuTqJdubcNa4eO1B(c4q0PFiwfCFrvm9SWCXaobWjqR38fWHOD4zQyRC4vyHpbmkgXOZxpoMC4bP5la24RHNPITYHNYecTPITsTyBXWtSTqNMmm8ufviTmAJy05RUDm5WdsZxaSXxdptfBLdpLjeAtfBLAX2IHNyBHonzy4PQsWkNzBeJoF9Wgto8G08faB81Wtr2aiRn8mvSubnKG8cTd1HKdr5dj9q0Civvcw5m5mWIETLmndu2pNaY2MTd11HE19dj9qtFOWeqgCgGVcGdP5la2HOt)qQQeSYzYza(kaobKTnBhQRd9Q7hs6HctazWza(kaoKMVayhI2dj9qtFigyrV2sMMbk7NhRIInDhEMk2khEeSuBQyRul2wm8eBl0PjddpRaDdcS5rm68v3Cm5WdsZxaSXxdpfzdGS2WZuXsf0qcYl0ouhsoeLpK0dXal61wY0mqz)8yvuSP7WZuXw5WJGLAtfBLAX2IHNyBHonzy4zfO9XiTyeJoF9Whto8G08faB81Wtr2aiRn8mvSubnKG8cTd1HKdr5dj9q0COPpedSOxBjtZaL9ZJvrXMUhs6HO5qQQeSYzYzGf9AlzAgOSFobKTnBhQJd9Q7hs6HM(qHjGm4maFfahsZxaSdrN(HuvjyLZKZa8vaCciBB2ouhh6v3pK0dfMaYGZa8vaCinFbWoeThI2HNPITYHhbl1Mk2k1ITfdpX2cDAYWWZfsGSkTvWigDs5UpMC4bP5la24RHNISbqwB4zQyPcAib5fAhsYHEn8mvSvo8uMqOnvSvQfBlgEITf60KHHNlKazvJyedVzcOkzFlgto681yYHNPITYH3CfBLdpinFbWgFnIrNuEm5WdsZxaSXxdV0KHHN5G26nI104vg6cxpxobYWZuXw5WZCqB9gXAA8kdDHRNlNazeJoD0yYHNPITYHhX2gOzGXgEqA(cGn(AeJy4PQsWkNzBm5OZxJjhEqA(cGn(A4PiBaK1gEZqWDnIB9laUPILkCi60pKpgoohl7lXV2AndteCS5drN(HctazWnI8VUW1rpOzMCcmoKMVayhs6HO5qZqWnI8V2TVWeCtflv4q0PFOzi42CP0U9fMGBQyPchIo9dPQsWkNj3iY)6cxh9GMbgJtazBZ2H64q4RBFOjGSTz7q0o8mvSvo8MRyRCeJoP8yYHhKMVayJVgEMk2khEB2ueSW8fG2bWSmWK1mG6QGHNISbqwB4rZHuvjyLZKJL9L4x7lw3(GtazBZ2HOt)qQQeSYzYzgHcDqSSHxezl2k5eq22SDiApK0drZHMHGBe5FTBFHj4MkwQWHOt)qZqWT5sPD7lmb3uXsfoK0dn9HctazWnI8VUW1rpOzMCcmoKMVayhIo9dfgXfcESYGok9Sk0uU7hQRd94HOD4LMmm82SPiyH5laTdGzzGjRza1vbJy0PJgto8G08faB81WZuXw5Wt2uMpb0TEacTmwBvdpfzdGS2WtvLGvotUnxkt8p3aobKTnBhQRd94HKEiAo00hcCaSDEgy8nBkcwy(cq7aywgyYAgqDvWHOt)qQQeSYzY3SPiyH5laTdGzzGjRza1vbCciBB2oeTdV0KHHNSPmFcOB9aeAzS2QgXOZhmMC4bP5la24RHNPITYHhJagdFjGMk0AGy4PiBaK1gEQQeSYzYT5szI)5gWjGSTz7qspenhA6dboa2opdm(MnfblmFbODamldmzndOUk4q0PFivvcw5m5B2ueSW8fG2bWSmWK1mG6QaobKTnBhI2HxAYWWJraJHVeqtfAnqmIrNpoMC4bP5la24RHNPITYHhZiuixvQzGIcn1IyQn(hEkYgazTHNQkbRCMCBUuM4FUbCciBB2oK0drZHM(qGdGTZZaJVztrWcZxaAhaZYatwZaQRcoeD6hsvLGvot(MnfblmFbODamldmzndOUkGtazBZ2HOD4LMmm8ygHc5QsnduuOPwetTX)igD2TJjhEqA(cGn(A4PiBaK1gEQQeSYzYT5szI)5gWjGSTz7qspenhA6dboa2opdm(MnfblmFbODamldmzndOUk4q0PFivvcw5m5B2ueSW8fG2bWSmWK1mG6QaobKTnBhI2HNPITYHhwd0BaYTrm68HnMC4bP5la24RHNISbqwB4PQsWkNjhl7lXV2xSU9bNaY2MTd11HC0HKEivvcw5m5mJqHoiw2WlISfBLCciBB2ouxhYrhs6HctazWXY(s8R9fRBFWH08fa7q0PFOPpuycidow2xIFTVyD7doKMVaydptfBLdpJi)RlCD0dAgySrm6SBoMC4bP5la24RHNISbqwB4r1iR5laEl0ZclZnDpK0drZHuvjyLZKBe5FDHRJEqZaJXjGSTz7qDCOhpeThs6HO5qQQeSYzYzgHcDqSSHxezl2k5eq22SDOUoKRIDi60pKpgooNzek0bXYgErKTyRKJnFiApK0drZHM(qeSeWlIlWzGXel0cTQwbhsZxaSdrN(HM(qHjGm4gr(xx46Oh0mtobghsZxaSdrN(HuvYW2GRQKAPSyRux46Oh0mWyCILuCOUo0JhI2HNPITYHhw2xIFTVyD7Jrm68HpMC4bP5la24RHNISbqwB4r1iR5laEl0ZclZnDpK0drZHuvjyLZKBe5FDHRJEqZaJXjGSTz7qDCOhpeD6hIbw0RPix3(GZ2M5laTvb7q0EiPhIGLaErCbodmMyHwOv1k4qA(cGDiPhkmbKb3iY)6cxh9GMzYjW4qA(cGDiPhsvjdBdUQsQLYITsDHRJEqZaJXjwsXH6qYHE8qspKQkbRCMCBUuM4FUbCciBB2ouxhYrhs6HO5qQQeSYzYzgHcDqSSHxezl2k5eq22SDOUoKRIDi60pKpgooNzek0bXYgErKTyRKJnFiAhEMk2khEyzFj(1(I1TpgXOZxDFm5WdsZxaSXxdpfzdGS2WZuXsf0qcYl0ouhsoeLhEMk2khEyzFj(1(I1TpgXOZxVgto8G08faB81Wtr2aiRn8OAK18faVf6zHL5MUhs6HO5qSk4yzFj(1(I1Tp0Sk4eq22SDi60p00hkmbKbhl7lXV2xSU9bhsZxaSdr7WZuXw5WJzek0bXYgErKTyRCeJoFr5XKdpinFbWgFn8uKnaYAdptflvqdjiVq7qDi5quE4zQyRC4Xmcf6GyzdViYwSvoIrNVC0yYHhKMVayJVgEkYgazTHNPILkOHeKxODijh61HKEig4JHJZXHwaKnD1olSKXBHPO4qDi5qp4qspuycidow2xIFTVyD7doKMVayhs6HctazWnI8VUW1rpOzMCcmoKMVayhs6HiyjGxexGZaJjwOfAvTcoKMVayhs6HuvYW2GRQKAPSyRux46Oh0mWyCILuCOoKCOhpK0dXQGJL9L4x7lw3(qZQGtazBZ2WZuXw5WZMlLj(NBWigD(6bJjhEqA(cGn(A4PiBaK1gEMkwQGgsqEH2HKCOxhs6HyGpgoohhAbq20v7SWsgVfMIId1HKd9Gdj9qHjGm4yzFj(1(I1Tp4qA(cGDiPhIvbhl7lXV2xSU9HMvbNaY2MTdj9qtFOWeqgCJi)RlCD0dAMjNaJdP5la2HKEivLmSn4QkPwkl2k1fUo6bndmgNyjfhQRd94WZuXw5WZMlLj(NBWigD(6XXKdpinFbWgFn8uKnaYAdptflvqdjiVq7qso0Rdj9qmWhdhNJdTaiB6QDwyjJ3ctrXH6qYHEWHKEiAo00hkmbKbhl7lXV2xSU9bhsZxaSdrN(HctazWnI8VUW1rpOzMCcmoKMVayhs6HO5qtFicwc4fXf4mWyIfAHwvRGdP5la2HOt)qQkzyBWvvsTuwSvQlCD0dAgymoXskouxh6Xdr7HOt)qtFOWeqgCJi)RlCD0dAMjNaJdP5la2HKEivLmSn4QkPwkl2k1fUo6bndmgNyjfhQdjh6Xdr7WZuXw5WZMlLj(NBWigD(QBhto8G08faB81WZuXw5WZMlLj(NBWWtr2aiRn8mvSubnKG8cTd1HKdr5dj9qmWhdhNJdTaiB6QDwyjJ3ctrXH6qYHEWHKEOPpedSOxBjtZaL9ZJvrXMUdp1Vsa6WiUq0gD(AeJoF9Wgto8G08faB81Wtr2aiRn8iy5Q0ZLtGWza(Q24qDDOxp4qspenhsvLGvotow2xIFTVyD7dobKTnBhQRd9Q7hIo9dXQGJL9L4x7lw3(qZQGtazBZ2HOD4zQyRC41WKLRu7Ae36xaJy05RU5yYHhKMVayJVgEkYgazTHhvJSMVa4TqplSm309qsped8XWX54qlaYMUANfwY4TWuuCOUoeLpK0drZHMHGBZLs72xycUPILkCi60pKQsg2gCvLulLfBL6cxh9GMbgJdP5la2HKEiFmCCoZiuOdILn8IiBXwjhB(qsp00hAgcUrK)1U9fMGBQyPchI2HNPITYHhw2xIFT1AgMigXOZxp8XKdpinFbWgFn8mvSvo8WY(s8RTwZWeXWtr2aiRn8mvSubnKG8cTd1HKdr5dj9qmWhdhNJdTaiB6QDwyjJ3ctrXH66quE4P(vcqhgXfI2OZxJy0jL7(yYHhKMVayJVgEMk2khETctOjGndKHNISbqwB4fgXfcESYGok9Sk0o6Xd11HE8qspuyexi4Xkd6O0Sfouhh6XHN6xjaDyexiAJoFnIrNu(1yYHhKMVayJVgEkYgazTH30hAgcUBFHj4MkwQWWZuXw5WJyBd0mWyJy0jLP8yYHhKMVayJVgEkYgazTHNPILkOHeKxODOoKCikFiPhA6d5JHJZzgHcDqSSHxezl2k5yZhs6HM(qQQeSYzYzgHcDqSSHxezl2k5eWy)dptfBLdVMPil(QwtONnvmIrm8CHeiRsBfmMC05RXKdpinFbWgFn8uKnaYAdpFmCCoZiuOdILn8IiBXwjhB(qspeblb8I4cCgymXcTqRQvWH08fa7qspKPILkOHeKxODOUKCihn8mvSvo8yGf9AvTIrm6KYJjhEqA(cGn(A4PiBaK1gE(y448ggJbPMvLmNaMkgEMk2khEW8Ya5vnIrNoAm5WdsZxaSXxdpfzdGS2WB6dr1iR5la(CvInD14fr7Ae36xadptfBLdpyEzG8QgXOZhmMC4bP5la24RHNPITYHNZclz62mKmGm8uKnaYAdpAoKQkbRCMCBUuM4FUbCciBB2ouhh6Xdj9qmWhdhNJdTaiB6QDwyjJJnFi60ped8XWX54qlaYMUANfwY4TWuuCOoo0doeThs6HO5q4RBFOjGSTz7qDDivvcw5m5mWIETLmndu2pNaY2MTd98HE19drN(HWx3(qtazBZ2H64qQQeSYzYT5szI)5gWjGSTz7q0o8u)kbOdJ4crB05Rrm68XXKdpinFbWgFn8mvSvo8WHwaKnD1TGSuadpfzdGS2WJb(y44CCOfaztxTZclz8wykkouxsoKJoK0dPQsWkNj3MlLj(NBaNaY2MTd11HC0HOt)qmWhdhNJdTaiB6QDwyjJ3ctrXH66qVgEQFLa0HrCHOn681igD2TJjhEqA(cGn(A4zQyRC4HdTaiB6QBbzPagEkYgazTHNQkbRCMCBUuM4FUbCciBB2ouhh6Xdj9qmWhdhNJdTaiB6QDwyjJ3ctrXH66qVgEQFLa0HrCHOn681igXWZkq7JrAXyYrNVgto8G08faB81Wtr2aiRn88XWX5mJqHoiw2WlISfBLCS5dj9qeSeWlIlWzGXel0cTQwbhsZxaSdj9qMkwQGgsqEH2H6sYHC0WZuXw5WJbw0Rv1kgXOtkpMC4bP5la24RHNISbqwB4rWYvPNlNaHZa8vTXH66q0COxD)qpFigyrVMICD7doUZclzathgXfI2HCqEihDiApK0dXal61uKRBFWXDwyjdy6WiUq0ouxhQBpK0dn9HOAK18faFUkXMUA8IODnIB9lGdrN(H8XWX5nNgrEtxT82co28WZuXw5WdMxgiVQrm60rJjhEqA(cGn(A4PiBaK1gEeSCv65Yjq4maFvBCOUoeLF8qspedSOxtrUU9bh3zHLmGPdJ4cr7qDCOhpK0dn9HOAK18faFUkXMUA8IODnIB9lGHNPITYHhmVmqEvJy05dgto8G08faB81Wtr2aiRn8M(qmWIEnf562hCCNfwYaMomIleTdj9qtFiQgznFbWNRsSPRgViAxJ4w)c4q0PFi81Tp0eq22SDOUo0JhIo9drSLPbQqgCJXACWHBlAhs6Hi2Y0avidUXynobKTnBhQRd94WZuXw5WdMxgiVQrm68XXKdptfBLdpNfwY0Tzizaz4bP5la24Rrm6SBhto8G08faB81Wtr2aiRn8M(qunYA(cGpxLytxnEr0UgXT(fWWZuXw5WdMxgiVQrmIHNQOcPLrBm5OZxJjhEqA(cGn(A4PiBaK1gEunYA(cG3c9SWYCt3dj9qeSCv65Yjq4maFvBCOoo0RUD4zQyRC41CAe5nD1YBlgXOtkpMC4bP5la24RHNISbqwB4PQsWkNj3MlLj(NBaNaY2MTdj9q0CitflvqdjiVq7qDi5qu(qspKPILkOHeKxODOUKCOhpK0drWYvPNlNaHZa8vTXH64qV6(HE(q0CitflvqdjiVq7qoipu3EiApeD6hYuXsf0qcYl0ouhh6Xdj9qeSCv65Yjq4maFvBCOoo0d6(HOD4zQyRC41CAe5nD1YBlgXOthnMC4bP5la24RHNISbqwB4r1iR5laEl0ZclZnDpK0dn9HAfMWFtgxagt7)RbhAYZcGdP5la2HKEivvcw5m52CPmX)Cd4eq22SDiPhIGLapwzqhL(bhQJdrZHC0HE(q(y44CcwUkTQieS5yRKtazBZ2HOD4zQyRC4z(L8MwSvQfRS)igD(GXKdpinFbWgFn8uKnaYAdpQgznFbWBHEwyzUP7HKEOwHj83KXfGX0()AWHM8Sa4qA(cGDiPhIMdPQsWkNjhl7lXV2xSU9bNaY2MTdrN(HM(qHjGm4yzFj(1(I1Tp4qA(cGDiPhsvLGvotoZiuOdILn8IiBXwjNaY2MTdr7WZuXw5WZ8l5nTyRulwz)rm68XXKdpinFbWgFn8uKnaYAdptflvqdjiVq7qDi5qu(qspeblbESYGok9douhhIMd5Od98H8XWX5eSCvAvriyZXwjNaY2MTdr7WZuXw5WZ8l5nTyRulwz)rm6SBhto8G08faB81Wtr2aiRn8OAK18faVf6zHL5MUhs6HuvjyLZKBZLYe)ZnGtazBZ2WZuXw5WR1BkkeGo6bnw6Sir))igD(Wgto8G08faB81Wtr2aiRn8mvSubnKG8cTd1HKdr5dj9q0CigyrV2sMMbk7NhRIInDpeD6hIyltduHm4gJ14eq22SDOUKCOxp4q0o8mvSvo8A9MIcbOJEqJLols0)pIrmIHhvG02khDs5Ut5U)IYVEWWZPrYnDBdVUHV7B353Rth8PCOdnzpCOvEUiXHWlYHE7cjqw17drahaBja7qTsgoKHfLSfa7qQElDHg)(m1nHd5OPCihxjvGea7qVjyjGxexGtP3hkQd9MGLaErCboL4qA(cG9(q08YH0YVptDt4qpoLd54kPcKayh6DycidoLEFOOo07WeqgCkXH08fa79HOXroKw(9zQBch6XPCihxjvGea7qVvvYW2GtP3hkQd9wvjdBdoL4qA(cG9(q08YH0YVptDt4qD7uoKJRKkqcGDO3HjGm4u69HI6qVdtazWPehsZxaS3hIgh5qA53NPUjCOh(uoKJRKkqcGDO3HjGm4u69HI6qVdtazWPehsZxaS3hIgh5qA53NPUjCOh(uoKJRKkqcGDO3QkzyBWP07df1HERQKHTbNsCinFbWEFiAE5qA53NPUjCOxDFkhYXvsfibWo07WeqgCk9(qrDO3HjGm4uIdP5la27drJJCiT87Z9PB47(2D(960bFkh6qt2dhALNlsCi8ICO3wb6geyZVpebCaSLaSd1kz4qgwuYwaSdP6T0fA87Zu3eoKJMYHCCLubsaSd9MGLaErCboLEFOOo0Bcwc4fXf4uIdP5la27drZlhsl)(m1nHd9WMYHCCLubsaSd9ombKbNsVpuuh6DycidoL4qA(cG9(q0qzhsl)(CF6g(UVDNFVoDWNYHo0K9WHw55IehcVih6ndWnmr8(qeWbWwcWouRKHdzyrjBbWoKQ3sxOXVptDt4quEkhYXvsfibWo07WeqgCk9(qrDO3HjGm4uIdP5la27dzXH6g)wp1drZlhsl)(m1nHd94uoKJRKkqcGDiVv2XhQ9NH5Wd5GDOOo0uXSdXwQBBR8q1mqSOihIMNO9q08YH0YVptDt4qpoLd54kPcKayh6DycidoLEFOOo07WeqgCkXH08fa79HO5LdPLFFM6MWH62PCihxjvGea7qERSJpu7pdZHhYb7qrDOPIzhITu32w5HQzGyrroenpr7HO5LdPLFFM6MWH62PCihxjvGea7qVdtazWP07df1HEhMaYGtjoKMVayVpenVCiT87Zu3eou3CkhYXvsfibWoK3k74d1(ZWC4HCWouuhAQy2Hyl1TTvEOAgiwuKdrZt0EiAE5qA53NPUjCOU5uoKJRKkqcGDO3HjGm4u69HI6qVdtazWPehsZxaS3hIMxoKw(9zQBch6v3NYHCCLubsaSd5TYo(qT)mmhEihSdf1HMkMDi2sDBBLhQMbIff5q08eThIMxoKw(9zQBch6v3NYHCCLubsaSd9ombKbNsVpuuh6DycidoL4qA(cG9(q08YH0YVptDt4qVO8uoKJRKkqcGDO3HjGm4u69HI6qVdtazWPehsZxaS3hIMxoKw(9zQBch6LJMYHCCLubsaSd9ombKbNsVpuuh6DycidoL4qA(cG9(q0qzhsl)(m1nHd96bt5qoUsQaja2HEtWsaViUaNsVpuuh6nblb8I4cCkXH08fa79HO5LdPLFFM6MWHE9WMYHCCLubsaSd9ombKbNsVpuuh6DycidoL4qA(cG9(q0qzhsl)(m1nHd96HpLd54kPcKayh6DycidoLEFOOo07WeqgCkXH08fa79HOHYoKw(95(0n8DF7o)ED6GpLdDOj7HdTYZfjoeEro0Bvvcw5mBVpebCaSLaSd1kz4qgwuYwaSdP6T0fA87Zu3eo0RPCihxjvGea7qVdtazWP07df1HEhMaYGtjoKMVayVpenVCiT87Zu3eoeLNYHCCLubsaSd9ombKbNsVpuuh6DycidoL4qA(cG9(q08YH0YVptDt4qpSPCihxjvGea7qVdtazWP07df1HEhMaYGtjoKMVayVpenVCiT87Zu3eo0dBkhYXvsfibWo07WeqgCk9(qrDO3HjGm4uIdP5la27dzXH6g)wp1drZlhsl)(m1nHd1nNYHCCLubsaSd9ombKbNsVpuuh6DycidoL4qA(cG9(q08YH0YVptDt4qDZPCihxjvGea7qVjyjGxexGtP3hkQd9MGLaErCboL4qA(cG9(q08YH0YVptDt4qp8PCihxjvGea7qVdtazWP07df1HEhMaYGtjoKMVayVpenVCiT87Zu3eo0dFkhYXvsfibWo0Bcwc4fXf4u69HI6qVjyjGxexGtjoKMVayVpenVCiT87Zu3eo0Rxt5qoUsQaja2HEhMaYGtP3hkQd9ombKbNsCinFbWEFiAE5qA53NPUjCOxoAkhYXvsfibWo07WeqgCk9(qrDO3HjGm4uIdP5la27drdLDiT87Zu3eo0lhnLd54kPcKayh6nblb8I4cCk9(qrDO3eSeWlIlWPehsZxaS3hIMxoKw(9zQBch61dMYHCCLubsaSd9ombKbNsVpuuh6DycidoL4qA(cG9(q0qzhsl)(m1nHd96XPCihxjvGea7qVdtazWP07df1HEhMaYGtjoKMVayVpenoYH0YVptDt4qVECkhYXvsfibWo0Bcwc4fXf4u69HI6qVjyjGxexGtjoKMVayVpenVCiT87Zu3eo0RU5uoKJRKkqcGDO3QkzyBWP07df1HERQKHTbNsCinFbWEFiAE5qA53N7t3W39T7871Pd(uo0HMSho0kpxK4q4f5qVDHeiRsBf8(qeWbWwcWouRKHdzyrjBbWoKQ3sxOXVptDt4qVMYHCCLubsaSd9MGLaErCboLEFOOo0Bcwc4fXf4uIdP5la27drZlhsl)(CF6g(UVDNFVoDWNYHo0K9WHw55IehcVih6TvG2hJ0I3hIaoa2sa2HALmCidlkzla2Hu9w6cn(9zQBch61uoKJRKkqcGDO3eSeWlIlWP07df1HEtWsaViUaNsCinFbWEFiAE5qA53N7t3W39T7871Pd(uo0HMSho0kpxK4q4f5qVvfviTmAVpebCaSLaSd1kz4qgwuYwaSdP6T0fA87Zu3eoKJMYHCCLubsaSd9Uvyc)nzCk9(qrDO3Tct4VjJtjoKMVayVpenVCiT87Zu3eo0dMYHCCLubsaSd9ombKbNsVpuuh6DycidoL4qA(cG9(q08YH0YVptDt4qpykhYXvsfibWo07wHj83KXP07df1HE3kmH)MmoL4qA(cG9(q08YH0YVp3NVN8CrcGDOU5HmvSvEiX2Ig)(m8Mjf(kGH3dDOVbSO)qFRY1Tpo03ISVe)3Nh6qFdOazFGCOxD7ehIYDNYD)(CFEOd9DSVFSwidz0ouuh6BYV5PVbWxb803aw03o03GbhkQdvP4)qQclJdfgXfI2HC2xhYiWHahodQayhkQdjwQWHev6Eiilm3(df1HKTiaYHOXkq3GaB(qp0lA53N7JPITYgFMaQs23INL80CfBL3htfBLn(mbuLSVfpl5jSgO3aKNinzqI5G26nI104vg6cxpxobY9XuXwzJptavj7BXZsEIyBd0mWy3N7ZdDOUrhckSayhcOcK)dfRmCOOhoKPIICOTDiJQTcZxa87JPITYMe5nzACcaoOW95Ho03hJSMVaA3htfBLTNL8evJSMVaMinzqYCvInD14fr7Ae36xatq1eyGevvcw5m5nmz5k1UgXT(faNaY2MTUEuAycidEdtwUsTRrCRFbCFmvSv2EwYtunYA(cyI0KbjTqplSm30DcQMadKyQyPcAib5fAsEjLMPj2Y0avidUXyno4WTfn60j2Y0avidUXyn(MD86rAVpp0H(2MAnr7(yQyRS9SKNmIYsqhfHazmXIlHGLRspxobcNb4RAJo62hLsZmeCxJ4w)cGBQyPc0PpDycidEdtwUsTRrCRFbWH08faJwPeSe4maFvB0HKhVpMk2kBpl5jFrvmnog5FIfxYmeCxJ4w)cGBQyPc0P7JHJZXY(s8RTwZWebhBMo9WeqgCJi)RlCD0dAMjNat6meCBUuA3(ctWnvSubP0mdb3iY)A3(ctWnvSub60vvjyLZKBe5FDHRJEqZaJXjGSTzRdvvcw5m5(IQyACmYpNHrSyR0bZr0sNo(62hAciBB26sIpgoo3xuftJJr(5mmIfBL3htfBLTNL8KpqAaHInDNyXLmdb31iU1Va4MkwQaD6(y44CSSVe)AR1mmrWXMPtpmbKb3iY)6cxh9GMzYjWKodb3MlL2TVWeCtflvqknZqWnI8V2TVWeCtflvGoDvvcw5m5gr(xx46Oh0mWyCciBB26qvLGvotUpqAaHInD5mmIfBLoyoIw60Xx3(qtazBZwxs8XWX5(aPbek20LZWiwSvEFmvSv2EwYtI1TpA6VFmMRmKXelUeFmCCow2xIFDliq6g9CS57ZdDOVlvqliM4qo2eIdPS8qbzDDbYHEWHMRaYynXH8XWXBtCiWu9hsyTyt3d96Xd1avLSg)qFlIvSoOa7q9gHDivXa2HIvgoK1oKDOGSUUa5qrDikay(qBCicymZxa87JPITY2ZsEYsf0cIj0ktiMyXLmdb31iU1Va4MkwQaD6(y44CSSVe)AR1mmrWXMPtpmbKb3iY)6cxh9GMzYjWKodb3MlL2TVWeCtflvqknZqWnI8V2TVWeCtflvGoDvvcw5m5gr(xx46Oh0mWyCciBB26qvLGvotULkOfetOvMqWzyel2kDWCeT0PJVU9HMaY2MTUK86X7JPITY2ZsEYiklb9mMObtS4smvSubnKG8cToKqz60PHGLaNb4RAJoK8OucwUk9C5eiCgGVQn6qs32DAVpMk2kBpl5j8La(IQytS4sMHG7Ae36xaCtflvGoDFmCCow2xIFT1AgMi4yZ0PhMaYGBe5FDHRJEqZm5eysNHGBZLs72xycUPILkiLMzi4gr(x72xycUPILkqNUQkbRCMCJi)RlCD0dAgymobKTnBDOQsWkNjhFjGVOkgNHrSyR0bZr0sNo(62hAciBB26sIpgoohFjGVOkgNHrSyR8(yQyRS9SKN8nxDHRdYQOOnXIlXhdhNJL9L4x3ccKUrphBwQPILkOHeKxOj5195Ho03xBZW2Ct3d99zjyciJd5GqyUyWH22HSdnt2ISX)9XuXwz7zjpvyHpbmkMyXLWQGtDjycid9SWCXaobWjqR38fG0PdtazWXY(s8R9fRBFiDAITmnqfYGBmwJdoCBr7(yQyRS9SKNkSWNagftS4syvWPUembKHEwyUyaNa4eO1B(cqQPILkOHeKxO1HeklLMPdtazWXY(s8R9fRBFqNEycidow2xIFTVyD7dPQQeSYzYXY(s8R9fRBFWjGSTzJ27JPITY2ZsEQWcFcyumXIlHGLaErCbEdBgiTGyBkLgwfCCs1cnoqfiCcGtGwV5la60zvW9fvX0ZcZfd4eaNaTEZxa0EFEOd9DQyR8qtDBr7(yQyRS9SKNuMqOnvSvQfBlMinzqIQOcPLr7(yQyRS9SKNuMqOnvSvQfBlMinzqIQkbRCMT7JPITY2ZsEIGLAtfBLAX2IjstgKyfOBqGnpXIlXuXsf0qcYl06qcLLsJQkbRCMCgyrV2sMMbk7NtazBZwxV6U0PdtazWza(ka60vvjyLZKZa8vaCciBB266v3LgMaYGZa8va0kDAgyrV2sMMbk7NhRIInDVpMk2kBpl5jcwQnvSvQfBlMinzqIvG2hJ0IjwCjMkwQGgsqEHwhsOSugyrV2sMMbk7NhRIInDVpMk2kBpl5jcwQnvSvQfBlMinzqIlKazvARGjwCjMkwQGgsqEHwhsOSuAMMbw0RTKPzGY(5XQOytxP0OQsWkNjNbw0RTKPzGY(5eq22S1XRUlD6WeqgCgGVcGoDvvcw5m5maFfaNaY2MToE1DPHjGm4maFfaT0EFmvSv2EwYtkti0Mk2k1ITftKMmiXfsGSQjwCjMkwQGgsqEHMKx3N7ZdDOVR6gp0xyKwCFmvSv24wbAFmslKWal61QAftS4s8XWX5mJqHoiw2WlISfBLCSzPeSeWlIlWzGXel0cTQwHutflvqdjiVqRljo6(yQyRSXTc0(yKw8SKNG5LbYRAIfxcblxLEUCceodWx1gDrZRU)mdSOxtrUU9bh3zHLmGPdJ4crZbPJOvkdSOxtrUU9bh3zHLmGPdJ4crRRUv60unYA(cGpxLytxnEr0UgXT(faD6(y448MtJiVPRwEBbhB((yQyRSXTc0(yKw8SKNG5LbYRAIfxcblxLEUCceodWx1gDr5hLYal61uKRBFWXDwyjdy6WiUq064rPtt1iR5la(CvInD14fr7Ae36xa3htfBLnUvG2hJ0INL8emVmqEvtS4sMMbw0RPix3(GJ7SWsgW0HrCHOjDAQgznFbWNRsSPRgViAxJ4w)cGoD81Tp0eq22S11J0PtSLPbQqgCJXACWHBlAsj2Y0avidUXynobKTnBD949XuXwzJBfO9XiT4zjp5SWsMUndjdi3htfBLnUvG2hJ0INL8emVmqEvtS4sMMQrwZxa85QeB6QXlI21iU1VaUp3Nh6qFx1nEipiWMVpMk2kBCRaDdcSzjw(RzjBIfxcdSOxtrUU9bh3zHLmGPdJ4crRdjQFLa0qcYl0OtNyltduHm4gJ14Gd3w0KsSLPbQqgCJXACciBB26sYRx3htfBLnUvGUbb28ZsEYYFnlztS4syGf9AkY1Tp44olSKbmDyexiADi5X7JPITYg3kq3GaB(zjpXal61QAftS4s8XWX5mJqHoiw2WlISfBLCSzPeSeWlIlWzGXel0cTQwHutflvqdjiVqRljo6(yQyRSXTc0niWMFwYtW8Ya5vnXIlzAQgznFbWNRsSPRgViAxJ4w)c4(yQyRSXTc0niWMFwYt4qlaYMU6wqwkGju)kbOdJ4crtYRjwCjmWhdhNJdTaiB6QDwyjJ3ctrrxsCKuvvcw5m52CPmX)Cd4eq22S1LJUpMk2kBCRaDdcS5NL8eo0cGSPRUfKLcyc1Vsa6WiUq0K8AIfxcd8XWX54qlaYMUANfwY4TWuu01R7JPITYg3kq3GaB(zjpHdTaiB6QBbzPaMq9ReGomIlenjVMyXLqWsGhRmOJs)GUOrvLGvotodSOxBjtZaL9ZjGSTzt60HjGm4maFfaD6QQeSYzYza(kaobKTnBsdtazWza(kaAVp3Nh6qoiQyRSDilzhQIEGCOkpewdUpMk2kBCvvcw5mBsMRyRCIfxYmeCxJ4w)cGBQyPc0P7JHJZXY(s8RTwZWebhBMo9WeqgCJi)RlCD0dAMjNatknZqWnI8V2TVWeCtflvGo9zi42CP0U9fMGBQyPc0PRQsWkNj3iY)6cxh9GMbgJtazBZwh4RBFOjGSTzJ27JPITYgxvLGvoZ2ZsEcRb6na5jstgKSztrWcZxaAhaZYatwZaQRcMyXLqJQkbRCMCSSVe)AFX62hCciBB2OtxvLGvotoZiuOdILn8IiBXwjNaY2MnALsZmeCJi)RD7lmb3uXsfOtFgcUnxkTBFHj4MkwQG0PdtazWnI8VUW1rpOzMCcm60dJ4cbpwzqhLEwfAk39UEK27JPITYgxvLGvoZ2ZsEcRb6na5jstgKiBkZNa6wpaHwgRTQjwCjQQeSYzYT5szI)5gWjGSTzRRhLsZ0GdGTZZaJVztrWcZxaAhaZYatwZaQRcOtxvLGvot(MnfblmFbODamldmzndOUkGtazBZgT3htfBLnUQkbRCMTNL8ewd0BaYtKMmiHraJHVeqtfAnqmXIlrvLGvotUnxkt8p3aobKTnBsPzAWbW25zGX3SPiyH5laTdGzzGjRza1vb0PRQsWkNjFZMIGfMVa0oaMLbMSMbuxfWjGSTzJ27JPITYgxvLGvoZ2ZsEcRb6na5jstgKWmcfYvLAgOOqtTiMAJ)jwCjQQeSYzYT5szI)5gWjGSTztkntdoa2opdm(MnfblmFbODamldmzndOUkGoDvvcw5m5B2ueSW8fG2bWSmWK1mG6QaobKTnB0EFmvSv24QQeSYz2EwYtynqVbi3MyXLOQsWkNj3MlLj(NBaNaY2MnP0mn4ay78mW4B2ueSW8fG2bWSmWK1mG6Qa60vvjyLZKVztrWcZxaAhaZYatwZaQRc4eq22Sr795HoKJRsWkNz7(yQyRSXvvjyLZS9SKNmI8VUW1rpOzGXMyXLOQsWkNjhl7lXV2xSU9bNaY2MTUCKuvvcw5m5mJqHoiw2WlISfBLCciBB26YrsdtazWXY(s8R9fRBFqN(0HjGm4yzFj(1(I1TpUpp0H8(t1H(sSU9XHCUr)H(gJqXHMKyzdViYwSvEOf)qyXkwh0nDpuf9a5qFJrO4qtsSSHxezl2kpKpgoEBIdf9vdoKpSP7H(gWyIfAXHCCTIjo03seiDqxGDOVVv2cs124)qf5qDJbqstCOVLXsxGWp03jA1Hu9GII2Hw8dPQKTXwz7qgboKmehkQdTzlaJDO(sWoeEro03nxkt8p3a(9XuXwzJRQsWkNz7zjpHL9L4x7lw3(yIfxcvJSMVa4TqplSm30vknQQeSYzYnI8VUW1rpOzGX4eq22S1XJ0kLgvvcw5m5mJqHoiw2WlISfBLCciBB26YvXOt3hdhNZmcf6GyzdViYwSvYXMPvknttWsaViUaNbgtSql0QAf0PpDycidUrK)1fUo6bnZKtGrNUQsg2gCvLulLfBL6cxh9GMbgJtSKIUEK27ZdDiV)uDOVeRBFCiNB0FOVBUuM4FUbhAXpu0dhsvLGvoZdv4h67MlLj(NBWH22HeLZdbzH52Zp03gCaSLaTd9nGXel0Id54AftCihxj1szXw5Hk8df9WH(gWyhYs2H(oI8)Hk8df9WH(gtob2HIYfIEGWVpMk2kBCvvcw5mBpl5jSSVe)AFX62htS4sOAK18faVf6zHL5MUsPrvLGvotUrK)1fUo6bndmgNaY2MToEKoDgyrVMICD7doBBMVa0wfmALsWsaViUaNbgtSql0QAfsdtazWnI8VUW1rpOzMCcmPQkzyBWvvsTuwSvQlCD0dAgymoXsk6qYJsvvjyLZKBZLYe)ZnGtazBZwxosknQQeSYzYzgHcDqSSHxezl2k5eq22S1LRIrNUpgooNzek0bXYgErKTyRKJnt79XuXwzJRQsWkNz7zjpHL9L4x7lw3(yIfxIPILkOHeKxO1HekFFmvSv24QQeSYz2EwYtmJqHoiw2WlISfBLtS4sOAK18faVf6zHL5MUsPHvbhl7lXV2xSU9HMvbNaY2Mn60NombKbhl7lXV2xSU9bT3htfBLnUQkbRCMTNL8eZiuOdILn8IiBXw5elUetflvqdjiVqRdju((yQyRSXvvjyLZS9SKNS5szI)5gmXIlXuXsf0qcYl0K8skd8XWX54qlaYMUANfwY4TWuu0HKhinmbKbhl7lXV2xSU9H0WeqgCJi)RlCD0dAMjNatkblb8I4cCgymXcTqRQvivvjdBdUQsQLYITsDHRJEqZaJXjwsrhsEukRcow2xIFTVyD7dnRcobKTnB3htfBLnUQkbRCMTNL8Knxkt8p3GjwCjMkwQGgsqEHMKxszGpgoohhAbq20v7SWsgVfMIIoK8aPHjGm4yzFj(1(I1TpKYQGJL9L4x7lw3(qZQGtazBZM0PdtazWnI8VUW1rpOzMCcmPQkzyBWvvsTuwSvQlCD0dAgymoXsk66X7JPITYgxvLGvoZ2ZsEYMlLj(NBWelUetflvqdjiVqtYlPmWhdhNJdTaiB6QDwyjJ3ctrrhsEGuAMombKbhl7lXV2xSU9bD6HjGm4gr(xx46Oh0mtobMuAMMGLaErCbodmMyHwOv1kOtxvjdBdUQsQLYITsDHRJEqZaJXjwsrxpslD6thMaYGBe5FDHRJEqZm5eysvvYW2GRQKAPSyRux46Oh0mWyCILu0HKhP9(yQyRSXvvjyLZS9SKNS5szI)5gmH6xjaDyexiAsEnXIlXuXsf0qcYl06qcLLYaFmCCoo0cGSPR2zHLmElmffDi5bsNMbw0RTKPzGY(5XQOyt37JPITYgxvLGvoZ2ZsEQHjlxP21iU1VaMyXLqWYvPNlNaHZa8vTrxVEGuAuvjyLZKJL9L4x7lw3(GtazBZwxV6oD6Sk4yzFj(1(I1Tp0Sk4eq22Sr79XuXwzJRQsWkNz7zjpHL9L4xBTMHjIjwCjunYA(cG3c9SWYCtxPmWhdhNJdTaiB6QDwyjJ3ctrrxuwknZqWT5sPD7lmb3uXsfOtxvjdBdUQsQLYITsDHRJEqZaJj1hdhNZmcf6GyzdViYwSvYXMLo9meCJi)RD7lmb3uXsfO9(yQyRSXvvjyLZS9SKNWY(s8RTwZWeXeQFLa0HrCHOj51elUetflvqdjiVqRdjuwkd8XWX54qlaYMUANfwY4TWuu0fLVpMk2kBCvvcw5mBpl5PwHj0eWMbYeQFLa0HrCHOj51elUKWiUqWJvg0rPNvH2rp21JsdJ4cbpwzqhLMTqhpEFmvSv24QQeSYz2EwYteBBGMbgBIfxY0ZqWD7lmb3uXsfUpMk2kBCvvcw5mBpl5PMPil(QwtONnvmXIlXuXsf0qcYl06qcLLoTpgooNzek0bXYgErKTyRKJnlDAvvcw5m5mJqHoiw2WlISfBLCcyS)7Z95HoKJlQqAzCOVZFfBSq7(yQyRSXvfviTmAsAonI8MUA5TftS4sOAK18faVf6zHL5MUsjy5Q0ZLtGWza(Q2OJxD795HoKhehkQdH1Gdz4bqoKnxQdTTdv5HC83CiRDOOo0mbOczCOIkqu288MUh6B7G4qo7xbCOgeXMUhcB(qo(BE3UpMk2kBCvrfslJ2ZsEQ50iYB6QL3wmXIlrvLGvotUnxkt8p3aobKTnBsPXuXsf0qcYl06qcLLAQyPcAib5fADj5rPeSCv65Yjq4maFvB0XRU)mnMkwQGgsqEHMdYULw60nvSubnKG8cToEukblxLEUCceodWx1gD8GUt79XuXwzJRkQqAz0EwYtMFjVPfBLAXk7pXIlHQrwZxa8wONfwMB6kD6wHj83KXfGX0()AWHM8SaKQQsWkNj3MlLj(NBaNaY2MnPeSe4Xkd6O0pOdAC0Z(y44CcwUkTQieS5yRKtazBZgT3htfBLnUQOcPLr7zjpz(L8MwSvQfRS)elUeQgznFbWBHEwyzUPR0wHj83KXfGX0()AWHM8SaKsJQkbRCMCSSVe)AFX62hCciBB2OtF6WeqgCSSVe)AFX62hsvvjyLZKZmcf6GyzdViYwSvYjGSTzJ27JPITYgxvuH0YO9SKNm)sEtl2k1Iv2FIfxIPILkOHeKxO1HeklLGLapwzqhL(bDqJJE2hdhNtWYvPvfHGnhBLCciBB2O9(yQyRSXvfviTmApl5PwVPOqa6Oh0yPZIe9)tS4sOAK18faVf6zHL5MUsvvjyLZKBZLYe)ZnGtazBZ29XuXwzJRkQqAz0EwYtTEtrHa0rpOXsNfj6)NyXLyQyPcAib5fADiHYsPHbw0RTKPzGY(5XQOytx60j2Y0avidUXynobKTnBDj51dO9(CFEOd5TPRao0KgXfI7JPITYg3fsGSkjmWIETQwXelUeFmCCEdJXGuZQsMtatfsNMQrwZxa85QeB6QXlI21iU1VaOtFgcURrCRFbWnvSuH7JPITYg3fsGSQNL8edSOxRQvmXIlHGLRspxobcNb4RAJUE5iPtt1iR5la(CvInD14fr7Ae36xa3htfBLnUlKazvpl5jl)1SKnXIlrvLGvotUnxkt8p3aobKTnBsPjmbKbNb4Ra4qA(cGrNUQOcPLbpx3(qJBaD6eSeWlIlWN7bJuYvcnAVpMk2kBCxibYQEwYtolSKPBZqYaYelUeg4JHJZXHwaKnD1olSKXBHPOOJhCFmvSv24UqcKv9SKNCwyjt3MHKbKjwCjmWhdhNJdTaiB6QDwyjJJnlvvLGvotUnxkt8p3aobKTnBD8OuAMombKbhl7lXV2xSU9bD6HjGm4gr(xx46Oh0mtobMuvLmSn4QkPwkl2k1fUo6bndmgNyjfD9iD6thMaYGBe5FDHRJEqZm5eysvvYW2GRQKAPSyRux46Oh0mWyCILu0HKhPtFAvLmSn4QkPwkl2k1fUo6bndmgT3htfBLnUlKazvpl5jNfwY0TzizazIfxcd8XWX54qlaYMUANfwY4yZsdtazWXY(s8R9fRBFiLMPdtazWnI8VUW1rpOzMCcmPQkzyBWvvsTuwSvQlCD0dAgymoXsk66r60dtazWnI8VUW1rpOzMCcmPQkzyBWvvsTuwSvQlCD0dAgymoXsk6qYJ0kLgvvcw5m5yzFj(1(I1Tp4eq22S1XRUlDAwfCSSVe)AFX62hAwfCciBB2OtxvLGvotUnxkt8p3aobKTnBD8Q70EFmvSv24UqcKv9SKNyGf9AvTIjwCjeSCv65Yjq4maFvB0fL7U0PPAK18faFUkXMUA8IODnIB9lG7JPITYg3fsGSQNL8eo0cGSPRUfKLcyIfxcd8XWX54qlaYMUANfwY4TWuu01R7JPITYg3fsGSQNL8eo0cGSPRUfKLcyIfxcd8XWX54qlaYMUANfwY4TWuu01dKQQsWkNj3MlLj(NBaNaY2MTUEuknthMaYGJL9L4x7lw3(Go9WeqgCJi)RlCD0dAMjNatQQsg2gCvLulLfBL6cxh9GMbgJtSKIUEKo9PdtazWnI8VUW1rpOzMCcmPQkzyBWvvsTuwSvQlCD0dAgymoXsk6qYJ0PpTQsg2gCvLulLfBL6cxh9GMbgJ27JPITYg3fsGSQNL8eo0cGSPRUfKLcyIfxcd8XWX54qlaYMUANfwY4TWuu01dKgMaYGJL9L4x7lw3(qknthMaYGBe5FDHRJEqZm5eysvvYW2GRQKAPSyRux46Oh0mWyCILu01J0PhMaYGBe5FDHRJEqZm5eysvvYW2GRQKAPSyRux46Oh0mWyCILu0HKhPvknQQeSYzYXY(s8R9fRBFWjGSTzRRxDNoDvvcw5m52CPmX)Cd4eq22S11RUlLvbhl7lXV2xSU9HMvbNaY2MnAVpMk2kBCxibYQEwYtmWIETQwXelUKPPAK18faFUkXMUA8IODnIB9lG7Z9XuXwzJ7cjqwL2kqcdSOxRQvmXIlXhdhNZmcf6GyzdViYwSvYXMLsWsaViUaNbgtSql0QAfsnvSubnKG8cTUK4O7ZdDihCibYQo03vDJhYbbzlYg)3htfBLnUlKazvARGNL8emVmqEvtS4s8XWX5nmgdsnRkzobmvCFmvSv24UqcKvPTcEwYtW8Ya5vnXIlzAQgznFbWNRsSPRgViAxJ4w)c4(yQyRSXDHeiRsBf8SKNCwyjt3MHKbKju)kbOdJ4crtYRjwCj0OQsWkNj3MlLj(NBaNaY2MToEukd8XWX54qlaYMUANfwY4yZ0PZaFmCCoo0cGSPR2zHLmElmffD8aALsd(62hAciBB26svLGvotodSOxBjtZaL9ZjGSTz75xDNoD81Tp0eq22S1HQkbRCMCBUuM4FUbCciBB2O9(yQyRSXDHeiRsBf8SKNWHwaKnD1TGSuatO(vcqhgXfIMKxtS4syGpgoohhAbq20v7SWsgVfMIIUK4iPQQeSYzYT5szI)5gWjGSTzRlhrNod8XWX54qlaYMUANfwY4TWuu01R7JPITYg3fsGSkTvWZsEchAbq20v3cYsbmH6xjaDyexiAsEnXIlrvLGvotUnxkt8p3aobKTnBD8Oug4JHJZXHwaKnD1olSKXBHPOORxdpdl6lYWZBLXewSv6yIHhJyeJb]] )

end
