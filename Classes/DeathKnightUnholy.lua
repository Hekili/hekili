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
        unholy_blight = {
            id = 115989,
            duration = 6,
            max_stack = 1,
        },
        unholy_blight_dot = {
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

        -- Get real Virulent Plague duration because SPELL_AURA_REFRESH doesn't necessarily fire.
        local name, _, count, _, duration, expires, caster = FindUnitBuffByID( "target", 191587, "PLAYER" )

        if name then
            debuff.virulent_plague.expires = expires
            debuff.virulent_plague.applied = expires - duration
            debuff.virulent_plague.count = count > 0 and count or 1
            debuff.virulent_plague.caster = "player"
        else
            removeDebuff( "target", "virulent_plague" )
        end

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
                applyBuff( "unholy_blight" )
                applyDebuff( "unholy_blight_dot" )
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


    spec:RegisterPack( "Unholy", 20201117, [[dGK3ObqiGQhPuH2evPrbu6uafRsPQs6vkHMfPs7cv)sjYWqs6yiPwMsvEMsfnnLQY1ivvBtPQQVPubghsIY5ivfzDkvvIMNsLUhsSpLGdQuvHfQe1djvfvtuPc6IijQ8rLQkkNuPQs1kjv8sKevzMkvvuDtLQkHDsvXqvQQilfjrv9uiMkvLUkPQOSvLQkL9sYFrmyHomLflWJjmzqxw1Mb8zKA0kPtRy1KQcVMuLzJYTjLDl63snCbDCKez5q9CIMUKRdPTtv13PkgpPQ05vkRhjH5dK9tLvuR8vHaT6kF2JQ7rvQPM6DaFVDsT(PEFkKAl8kKqtONrFfsAAxHOplxB2Mcj02yTbv(QqKnkwCfYAvHY9lxAj6Pwrd4IwBj5OHYSA6uGnGAj5OjwsHeGoSA)EQcuiqRUYN9O6EuLAQPEhWPwFIQuz7BNkez4fkF2t)7Pqwhi8PkqHaVuOq2rxChERwDrQ8YHETCr9z5AZ2C6SJUOpT)RfCSls9oqxxCpQUhvD640zhDX9dO(avwAplPlwTlUdZD4s7WdmSV0o8wTkDXDi6DXQDXozBUOOrZYfldt)s6IEwBx0W3fV(gErDOlwTlYg)3fzDs7IpBu6vxSAxuZQ6yxeSwFI8fAOlUJudgUcHnYsQ8vHy9jYxOHkFv(qTYxfYtlGDOAzfIap1XJPqG3QvIE5qVwCapnAcpKugM(L0fxGIlk2eStEET5sxeeixeBdKC)plUbHs(13rwsx0RlITbsU)Nf3GqjhFnBsPlUlfxKAQviMOMoviwUrGjuvkF2t5Rc5PfWouTScrGN64XuiWB1krVCOxloGNgnHhskdt)s6IlqXf1VcXe10PcXYncmHQs5Zov(QqEAbSdvlRqe4PoEmfc4UOFdpwa78WUztstaAmH2W09g7UOxxeJMJGe2EoMdpWiMYf31f3JQUiiqUyakaaxIcHpjWU144BIsHyIA6uH8WbETrOkLp7t5Rc5PfWouTScrGN64XuiWhGcaWbUSoEsAINgnHCzzc9CXDP4I70f96IIUzW2tYTWwySTq554RztkDXDDXDQqmrnDQqaUSoEsAISWJExHi2eStkdt)sQ8HAvP8r)kFvipTa2HQLvic8uhpMcb(auaaoWL1Xtst80OjKlltONlURlsTcXe10Pcb4Y64jPjYcp6DfIytWoPmm9lPYhQvLYN9x5Rc5PfWouTScrGN64Xuiy088A0oPAY(CXDDrW6IIUzW2tYH3QvILqc8cBJJVMnP0f96IG7ILXEwC4bg25pTa2HUiiqUOOBgS9KC4bg254RztkDrVUyzSNfhEGHD(tlGDOlcgfIjQPtfcWL1XtstKfE07keXMGDszy6xsLpuRkLp7aLVkKNwa7q1YkebEQJhtHaUl63WJfWopSB2K0eGgtOnmDVXUcXe10Pc5Hd8AJqvQsHCP8P4sLVkFOw5Rc5PfWouTScrGN64Xuiy088A0oPAc1U4cUiTa6IEDrmAocsy75yxCxxCFuvHyIA6uHODTgVrAacdvmqceFttQkLp7P8vH80cyhQwwHiWtD8yke4TALyjKaVW241i0BsAxeeixm8f3cBbHETrzCtuJ)7IEDrtuJ)tEET5sxKIlsTcXe10PcjG1nK0aKA9KNxBtvkF2PYxfYtlGDOAzfIap1XJPqaRlk6MbBpj3cBHX2cLNJVMnP0f31f3Fx0Rlk6MbBpj3WABKgGuRNaVb54RztkDXfCrr3my7j5IoHpLhsydWbAS4C81SjLUiyCrqGCrr3my7j5gwBJ0aKA9e4nihFnBsPlURlUNcXe10PcHg1WWXssdqmQ44UwvLYN9P8vH80cyhQwwHiWtD8ykKauaao(c9yxkjanwCoAOlccKlgGcaWXxOh7sjbOXItenAwhZLLj0Zf31fPMAfIjQPtfsTEcAg0OjKa0yXvLYh9R8vH80cyhQwwHiWtD8ykeWDr4TALyjKaVW241i0BsAfIjQPtfcqlqLhsmQ44Poj4MMQu(S)kFvipTa2HQLvic8uhpMcb2fx0P4zHT6qcaZ0ojafNC81SjLUifxKQketutNkerNINf2Qdjamt7Qs5Zoq5Rc5PfWouTScrGN64XuiG7IWB1kXsibEHTXRrO3K0ketutNkKqu8aSnjnjGzYsvkFOYu(QqEAbSdvlRqe4PoEmfszSNf3WABKgGuRNanT8q(tlGDOl61fVu(uCU)roDsAas4XaxutNCTjBSl61fdqba4O5AZ2iYc)KUw5OHUiiqU4LYNIZ9pYPtsdqcpg4IA6KRnzJDrVUy4lUf2cc9AJY4MOg)3fbbYflJ9S4gwBJ0aKA9eOPLhYFAbSdDrVUy4lUf2cc9AJY4MOg)3f96IIUzW2tYnS2gPbi16jWBqo(A2KsxCbxC)PQlccKlwg7zXnS2gPbi16jqtlpK)0cyh6IEDXWxCdRTrOxBug3e14)ketutNkepnMb9)jj4l70sXvLYh9jLVkKNwa7q1YkebEQJhtHaUlcVvRelHe4f2gVgHEts7IEDXauaaoAU2SnISWpPRvoAOl61fb3fVu(uCU)roDsAas4XaxutNCTjBSl61fb3flJ9S4gwBJ0aKA9eOPLhYFAbSdDrqGCXYW0V41ODs1e4CxCxxu0nd2EsUf2cJTfkphFnBsPcXe10PcXtJzq)Fsc(YoTuCvP8HAQQ8vH80cyhQwwHiWtD8ykeWDr4TALyjKaVW241i0BsAfIjQPtfcEcdzNmjrgAIRkLputTYxfIjQPtfc(w4K0eaMPDPc5PfWouTSQuLcbEadLvkFv(qTYxfIjQPtfI2Kqca(NkUc5PfWouTSQu(SNYxfYtlGDOAzfshQqKVuiMOMovi(n8ybSRq8Bm0RqeDZGTNKlr106KqBy6EJDo(A2KsxCxxu)UOxxSm2ZIlr106KqBy6EJD(tlGDOcXVHjPPDfsy3SjPjanMqBy6EJDvP8zNkFvipTa2HQLvic8uhpMcbJMJGe2EoMdpWiMYfxWf3F97IEDrW6IHV40gMU3yNBIA8FxeeixeCxSm2ZIlr106KqBy6EJD(tlGDOlcgx0RlIrZZHhyet5IlqXf1VcXe10PcXWclpPAm(zPkLp7t5Rc5PfWouTScrGN64XuiHV40gMU3yNBIA8FxeeixmafaGJMRnBJysPHYkoAOlccKlwg7zXnS2gPbi16jqtlpK)0cyh6IEDrW6IHV4gwBJqV2OmUjQX)DrqGCrr3my7j5gwBJ0aKA9e4nihFnBsPlUGlwgM(fVgTtQMaN7IGrHyIA6uHeW6gsaqXBQs5J(v(QqEAbSdvlRqe4PoEmfs4loTHP7n25MOg)3fbbYfdqba4O5AZ2iMuAOSIJg6IGa5ILXEwCdRTrAasTEc00Yd5pTa2HUOxxeSUy4lUH12i0RnkJBIA8Fxeeixu0nd2EsUH12inaPwpbEdYXxZMu6Il4ILHPFXRr7KQjW5UiyuiMOMovibhlpwVjPvLYN9x5Rc5PfWouTScrGN64XuibOaaC0CTzBezHFsxRC0qfIjQPtfcBOxljrFGcP1EwQs5Zoq5Rc5PfWouTScrGN64XuiHV40gMU3yNBIA8FxeeixmafaGJMRnBJysPHYkoAOlccKlwg7zXnS2gPbi16jqtlpK)0cyh6IEDrW6IHV4gwBJqV2OmUjQX)DrqGCrr3my7j5gwBJ0aKA9e4nihFnBsPlUGlwgM(fVgTtQMaN7IGrHyIA6uHyP4YcBmIWymvP8Hkt5Rc5PfWouTScrGN64XuiMOg)N88AZLU4cuCX9CrqGCrW6Iy08C4bgXuU4cuCr97IEDrmAocsy75yo8aJykxCbkU4(tvxemketutNkedlS8KquM8Qs5J(KYxfYtlGDOAzfIap1XJPqcFXPnmDVXo3e14)UiiqUyakaahnxB2gXKsdLvC0qxeeixSm2ZIByTnsdqQ1tGMwEi)PfWo0f96IG1fdFXnS2gHETrzCtuJ)7IGa5IIUzW2tYnS2gPbi16jWBqo(A2KsxCbxSmm9lEnANunbo3fbJcXe10PcbyWpG1nuvkFOMQkFvipTa2HQLvic8uhpMcjafaGJMRnBJil8t6ALJg6IEDrtuJ)tEET5sxKIlsTcXe10PcjWOjnaPWJqpPQu(qn1kFvipTa2HQLvic8uhpMcPgT7Il4I7rvxeeixeCx8uj0jm8qo20cNKMyAHSPqHNqp0M)MvKN0tExeeixeCx8uj0jm8qU)roDsAac8AJ8ketutNkeu5jtDnPQu(q9EkFvipTa2HQLviMOMovigvixnSjjaDwKgGe2EowHiWtD8ykeW6IxkFko3)iNojnaj8yGlQPt(tlGDOl61fb3flJ9S4O5AZ2iMuAOSI)0cyh6IGXfbbYfbRlcUlEP8P4CrNWNYdjSb4anwCUMPpASl61fb3fVu(uCU)roDsAas4XaxutN8Nwa7qxemkK00UcXOc5QHnjbOZI0aKW2ZXQs5d17u5Rc5PfWouTScXe10PcXOc5QHnjbOZI0aKW2ZXkebEQJhtHi6MbBpj3cBHX2cLNJVMnP0f31fPEFUOxxeSU4LYNIZfDcFkpKWgGd0yX5AM(OXUiiqU4LYNIZ9pYPtsdqcpg4IA6K)0cyh6IEDXYyploAU2SnIjLgkR4pTa2HUiyuiPPDfIrfYvdBscqNfPbiHTNJvLYhQ3NYxfYtlGDOAzfIjQPtfIrfYvdBscqNfPbiHTNJvic8uhpMcbyOxlc(A2KsxCxxu0nd2EsUf2cJTfkphFnBsPlUOlUZ9Pqst7keJkKRg2KeGolsdqcBphRkLpuRFLVkKNwa7q1YketutNketU63YljyJkAmr0yJPqe4PoEmfc8bOaaCSrfnMiASXiWhGcaWLLj0Zf31fPwHKM2viMC1VLxsWgv0yIOXgtvkFOE)v(QqEAbSdvlRqmrnDQqm5QFlVKGnQOXerJnMcrGN64XuiHV40OggowsAaIrfh31k3e14)UOxxm8f3cBbHETrzCtuJ)Rqst7ketU63YljyJkAmr0yJPkLpuVdu(QqEAbSdvlRqmrnDQqm5QFlVKGnQOXerJnMcrGN64XuiIUzW2tYTWwySTq554BWnx0Rlcwx8s5tX5IoHpLhsydWbAS4CntF0yx0Rlcm0RfbFnBsPlURlk6MbBpjx0j8P8qcBaoqJfNJVMnP0fx0f3JQUiiqUi4U4LYNIZfDcFkpKWgGd0yX5AM(OXUiyuiPPDfIjx9B5LeSrfnMiASXuLYhQPYu(QqEAbSdvlRqmrnDQqm5QFlVKGnQOXerJnMcrGN64Xuiad9ArWxZMu6I76IIUzW2tYTWwySTq554RztkDXfDX9OQcjnTRqm5QFlVKGnQOXerJnMQu(qT(KYxfYtlGDOAzfIjQPtfI)roDsAac8AJ8kebEQJhtHawxu0nd2EsUf2cJTfkphFdU5IEDr4dqba4axwhpjnXtJMqUSmHEU4cuCX95IEDXlLpfN7FKtNKgGeEmWf10j)PfWo0fbJlccKlgGcaWrZ1MTrmP0qzfhn0fbbYfdFXPnmDVXo3e14)kK00UcX)iNojnabETrEvP8zpQQ8vH80cyhQwwHyIA6uHGnTWjPjMwiBku4j0dT5Vzf5j9KxHiWtD8yker3my7j5wylm2wO8C81SjLU4UU4EUiiqUyzSNf3WABKgGuRNanT8q(tlGDOlccKlITbsU)Nf3GqjFsxCxxu)kK00UcbBAHtstmTq2uOWtOhAZFZkYt6jVQu(Sh1kFvipTa2HQLviMOMovibB0DEsWpXyAwAcfIap1XJPqeDZGTNKlr106KqBy6EJDo(A2KsxCbxC)PQlccKlcUlwg7zXLOAADsOnmDVXo)PfWo0f96I1ODxCbxCpQ6IGa5IG7INkHoHHhYXMw4K0etlKnfk8e6H283SI8KEYRqst7kKGn6opj4NymnlnHQu(S3EkFvipTa2HQLviMOMovi6JljRTh2XkebEQJhtHe(ItBy6EJDUjQX)DrqGCrWDXYyplUevtRtcTHP7n25pTa2HUOxxSgT7Il4I7rvxeeixeCx8uj0jm8qo20cNKMyAHSPqHNqp0M)MvKN0tEfsAAxHOpUKS2EyhRkLp7TtLVkKNwa7q1YketutNkeAJDHXyhljb30tHiWtD8ykKWxCAdt3BSZnrn(VlccKlcUlwg7zXLOAADsOnmDVXo)PfWo0f96I1ODxCbxCpQ6IGa5IG7INkHoHHhYXMw4K0etlKnfk8e6H283SI8KEYRqst7keAJDHXyhljb30tvkF2BFkFvipTa2HQLviMOMovi04oPLKq8Ozmc2OVcrGN64Xuiy08U4UuCXD6IEDrW6I1ODxCbxCpQ6IGa5IG7INkHoHHhYXMw4K0etlKnfk8e6H283SI8KEY7IGrHKM2vi04oPLKq8Ozmc2OVQu(SN(v(QqEAbSdvlRqe4PoEmfIOBgS9KCdRTrAasTEc8gKJVb3CrqGCXWxCAdt3BSZnrn(VlccKlgGcaWrZ1MTrmP0qzfhnuHyIA6uHe210PQu(S3(R8vH80cyhQwwHiWtD8ykeyxC)dgL9SiHmJg9C8bWxUAbS7IEDrWDXYyploAU2SnsaBOxl(tlGDOl61fb3fX2aj3)ZIBqOKF9DKLuHyIA6uH0Ova(MEQs5ZE7aLVkKNwa7q1YkebEQJhtHa7I7FWOSNfjKz0ONJpa(YvlGDx0RlcwxeCxSm2ZIJMRnBJeWg61I)0cyh6IGa5ILXEwC0CTzBKa2qVw8Nwa7qx0Rlk6MbBpjhnxB2gjGn0RfhFnBsPlcgx0RlAIA8FYZRnx6IlqXf3tHyIA6uH0Ova(MEQs5ZEuzkFvipTa2HQLvic8uhpMcbJMhOX0NlrdpwwyBs(PsOty4HUOxxeSUiSloaULfb4(pMJpa(YvlGDxeeixe2fpG1nKeYmA0ZXhaF5QfWUlcgfIjQPtfsJwb4B6PkLp7PpP8vH80cyhQwwHyIA6uHimgJyIA6KWgzPqyJSiPPDfIOBgS9KsvP8zNuv5Rc5PfWouTScXe10PcrymgXe10jHnYsHWgzrst7kKlLpfxQkLp7KALVkKNwa7q1YketutNkemAsmrnDsyJSuic8uhpMcrSjyN88AZLU4cuCX9CrVUiyDrr3my7j5WB1kXsibEHTXXxZMu6I76Iutvx0RlcUlwg7zXHhyyN)0cyh6IGa5IIUzW2tYHhyyNJVMnP0f31fPMQUOxxSm2ZIdpWWo)PfWo0fbJl61fb3fH3QvILqc8cBJxJqVjPviSrwK00UcX6tKVqdvLYNDUNYxfYtlGDOAzfIjQPtfcgnjMOMojSrwkebEQJhtHi2eStEET5sxCbkU4EUOxxeERwjwcjWlSnEnc9MKwHWgzrst7keRpjafllvP8zN7u5Rc5PfWouTScXe10PcbJMetutNe2ilfIap1XJPqmrn(p551MlDXfO4I75IEDrW6IG7IWB1kXsibEHTXRrO3K0UOxxeSUOOBgS9KC4TALyjKaVW244RztkDXfCrQPQl61fb3flJ9S4WdmSZFAbSdDrqGCrr3my7j5WdmSZXxZMu6Il4Iutvx0Rlwg7zXHhyyN)0cyh6IGXfbJcHnYIKM2vi0ppEeeRVQu(SZ9P8vH80cyhQwwHyIA6uHimgJyIA6KWgzPqe4PoEmfIjQX)jpV2CPlsXfPwHWgzrst7ke6NhpcvPkfsi(IwlWkLVkFOw5RcXe10PcjSRPtfYtlGDOAzvP8zpLVkKNwa7q1YkK00UcXOc5QHnjbOZI0aKW2ZXketutNkeJkKRg2KeGolsdqcBphRkLp7u5RcXe10PcbBJ8e4nOc5PfWouTSQuLcr0nd2EsPYxLpuR8vHyIA6uHGkpzQRjvipTa2HQLvLYN9u(QqEAbSdvlRqe4PoEmfs4loTHP7n25MOg)3fbbYfdqba4O5AZ2iMuAOSIJg6IGa5ILXEwCdRTrAasTEc00Yd5pTa2HUOxxeSUy4lUH12i0RnkJBIA8Fxeeixu0nd2EsUH12inaPwpbEdYXxZMu6Il4ILHPFXRr7KQjW5UiyuiMOMoviHDnDQkLp7u5Rc5PfWouTScrGN64XuiIUzW2tYrZ1MTrcyd9AXXxZMu6I76I63f96ILXEwC0CTzBKa2qVw8Nwa7qxeeixeCxSm2ZIJMRnBJeWg61I)0cyhQqmrnDQqmS2gPbi16jWBqvP8zFkFvipTa2HQLvic8uhpMcbCxeBdKC)plUbHs(13rwsx0Rlcwxu0nd2EsUH12inaPwpbEdYXxZMu6Il4I63fbbYfH3QvIE5qVwC4iTa2jwxqxemUOxxeSUOOBgS9KClSfgBluEo(gCZf96IG1fHpafaGdCzD8K0epnAc5YYe65IlqXf3NlccKlIrZ7IlqXf3Plcgxeeixu0nd2EsUf2cJTfkphFnBsPlcgx0RlcUlITbsU)Nf3Gqj)67ilPcXe10PcbnxB2gjGn0RLQu(OFLVkKNwa7q1YkebEQJhtHGTbsU)Nf3Gqj)67ilPl61fbRlAIA8FYZRnx6IlqXf3ZfbbYfX2aj3)ZIBqOKpPlUGlsT(DrWOqmrnDQqqZ1MTrcyd9APkLp7VYxfYtlGDOAzfIap1XJPqa3fX2aj3)ZIBqOKF9DKL0f96IIUzW2tYrZ1MTrcyd9AXXxZMu6IEDrW6IG7Iy08anM(C4niBUSiIEy8tLqNWWdDrqGCrmAEGgtFo8gKnxwerpm(PsOty4HUOxxeSUi4UyakaahAy9if2sjqJ1SA6KJg6IEDrWDXYyploAU2SnsOjk(tlGDOlccKlwg7zXrZ1MTrcnrXFAbSdDrW4IGrHyIA6uHanSEKcBPeOXAwnDQkLp7aLVkKNwa7q1YkebEQJhtHaUlITbsU)Nf3Gqj)67ilPl61fb3flJ9S4O5AZ2ibSHET4pTa2HketutNkeOH1JuylLanwZQPtvP8Hkt5Rc5PfWouTScrGN64XuiyBGK7)zXniuYV(oYs6IEDrW6IMOg)N88AZLU4cuCX9CrqGCrSnqY9)S4gek5t6Il4IuRFxemketutNkeOH1JuylLanwZQPtvP8rFs5Rc5PfWouTScrGN64XuiMOg)N88AZLUifxKAx0RlcFakaah4Y64jPjEA0eYLLj0ZfxGIlUpx0RlcwxeSUi4UyzSNfhnxB2gjGn0Rf)PfWo0fbbYflJ9S4gwBJ0aKA9eOPLhYFAbSdDrqGCrrNq0P4Io93cRMojnaPwpbEdYFAbSdDrW4IGa5ILXEwC0CTzBKa2qVw8Nwa7qx0RlcUlwg7zXnS2gPbi16jqtlpK)0cyh6IEDryxC0CTzBKa2qVwC81SjLUiyuiMOMoviwylm2wO8Qs5d1uv5Rc5PfWouTScrGN64XuiMOg)N88AZLU4cuCX9CrVUi8bOaaCGlRJNKM4PrtixwMqpxCbkU4(CrVUi4Ui8wTsSesGxyB8Ae6njTcXe10PcXcBHX2cLxvkFOMALVkKNwa7q1YkebEQJhtHGrZrqcBphZHhyet5I76IuVpfIjQPtfIevtRtcTHP7n2vLYhQ3t5Rc5PfWouTScrGN64XuiMOg)N88AZLUifxKAx0RlcFakaah4Y64jPjEA0eYLLj0Zf31f3Zf96IG1fdFXTWwqOxBug3e14)UiiqUOOti6uCrN(BHvtNKgGuRNaVb5pTa2HUiyuiMOMoviO5AZ2iMuAOSsvkFOENkFvipTa2HQLvic8uhpMcXe14)KNxBU0fxGIlUNl61fHpafaGdCzD8K0epnAc5YYe65I76I7PqmrnDQqqZ1MTrmP0qzLcrSjyNugM(Lu5d1Qs5d17t5Rc5PfWouTScrGN64XuiLHPFXRr7KQjHIISt97I76I63f96ILHPFXRr7KQjW5U4cUO(viMOMoviYgLrW3cpwHi2eStkdt)sQ8HAvP8HA9R8vH80cyhQwwHiWtD8ykeWDXWxC61gLXnrn(VcXe10PcbBJ8e4nOQuLcH(5XJGy9v(Q8HALVkKNwa7q1YkebEQJhtHeGcaWLOq4tcSBno(MOuiMOMovipCGxBeQs5ZEkFvipTa2HQLvic8uhpMcbCx0VHhlGDEy3SjPjanMqBy6EJDfIjQPtfYdh41gHQu(StLVkKNwa7q1YkebEQJhtHawxu0nd2EsUf2cJTfkphFnBsPlUGlQFx0RlcFakaah4Y64jPjEA0eYrdDrqGCr4dqba4axwhpjnXtJMqUSmHEU4cU4(CrW4IEDrW6Iad9ArWxZMu6I76IIUzW2tYH3QvILqc8cBJJVMnP0fx0fPMQUiiqUiWqVwe81SjLU4cUOOBgS9KClSfgBluEo(A2KsxemketutNkepnAcjYWNWJviInb7KYW0VKkFOwvkF2NYxfYtlGDOAzfIap1XJPqGpafaGdCzD8K0epnAc5YYe65I7sXf3Pl61ffDZGTNKBHTWyBHYZXxZMu6I76I70fbbYfHpafaGdCzD8K0epnAc5YYe65I76IuRqmrnDQqaUSoEsAISWJExHi2eStkdt)sQ8HAvP8r)kFvipTa2HQLvic8uhpMcr0nd2EsUf2cJTfkphFnBsPlUGlQFx0RlcFakaah4Y64jPjEA0eYLLj0Zf31fPwHyIA6uHaCzD8K0ezHh9UcrSjyNugM(Lu5d1QsvkeRpjafllLVkFOw5Rc5PfWouTScrGN64Xuiy0CeKW2ZXC4bgXuU4UUiyDrQPQlUOlcVvRe9YHET4aEA0eEiPmm9lPlUF1f3Plcgx0RlcVvRe9YHET4aEA0eEiPmm9lPlURlU)UOxxeCx0VHhlGDEy3SjPjanMqBy6EJDfIjQPtfYdh41gHQu(SNYxfYtlGDOAzfIap1XJPqWO5iiHTNJ5WdmIPCXDDX90Vl61fH3QvIE5qVwCapnAcpKugM(L0fxWf1Vl61fb3f9B4XcyNh2nBsAcqJj0gMU3yxHyIA6uH8WbETrOkLp7u5Rc5PfWouTScrGN64XuiG7IWB1krVCOxloGNgnHhskdt)s6IEDrWDr)gESa25HDZMKMa0ycTHP7n2viMOMovipCGxBeQs5Z(u(QqmrnDQq80OjKidFcpwH80cyhQwwvkF0VYxfYtlGDOAzfIap1XJPqa3f9B4XcyNh2nBsAcqJj0gMU3yxHyIA6uH8WbETrOkvPqOFE8iu(Q8HALVkKNwa7q1YkebEQJhtHeGcaWLOq4tcSBno(MOCrVUi4UOFdpwa78WUztstaAmH2W09g7UiiqUy4loTHP7n25MOg)xHyIA6uHaVvRerpmvP8zpLVkKNwa7q1YkebEQJhtHGrZrqcBphZHhyet5I76IuVtx0RlcUl63WJfWopSB2K0eGgtOnmDVXUcXe10PcbERwjIEyQs5Zov(QqEAbSdvlRqe4PoEmfIOBgS9KClSfgBluEo(A2KsfIjQPtfc8ad7Qs5Z(u(QqEAbSdvlRqe4PoEmfc8bOaaCGlRJNKM4PrtixwMqpxCbxCFketutNkepnAcjYWNWJvLYh9R8vH80cyhQwwHiWtD8yke4dqba4axwhpjnXtJMqoAOl61ffDZGTNKBHTWyBHYZXxZMu6Il4I63f96IG1fb3flJ9S4O5AZ2ibSHET4pTa2HUiiqUyzSNf3WABKgGuRNanT8q(tlGDOlccKlk6eIofx0P)wy10jPbi16jWBq(tlGDOlccKlITbsU)Nf3Gqj)67ilPlcgfIjQPtfINgnHez4t4XQs5Z(R8vH80cyhQwwHiWtD8yke4dqba4axwhpjnXtJMqoAOl61flJ9S4O5AZ2ibSHET4pTa2HUOxxeCxSm2ZIByTnsdqQ1tGMwEi)PfWo0f96IG7IIoHOtXfD6VfwnDsAasTEc8gK)0cyh6IEDrWDrSnqY9)S4gek5xFhzjDrVUiyDrr3my7j5O5AZ2ibSHET44RztkDXfCr97IEDrr3my7j5wylm2wO8C8n4Ml61fb3fHDXrZ1MTrcyd9AXXxZMu6IGa5IG7IIUzW2tYTWwySTq554BWnxemketutNkepnAcjYWNWJvLYNDGYxfYtlGDOAzfIap1XJPqWO5iiHTNJ5WdmIPCXDDX9OQl61fb3f9B4XcyNh2nBsAcqJj0gMU3yxHyIA6uHaVvRerpmvP8Hkt5Rc5PfWouTScrGN64XuiWhGcaWbUSoEsAINgnHCzzc9CXDDrQviMOMoviaxwhpjnrw4rVRkLp6tkFvipTa2HQLvic8uhpMcb(auaaoWL1Xtst80OjKlltONlURlUpx0Rlk6MbBpj3cBHX2cLNJVMnP0f31f3Pl61fbRlcUlwg7zXrZ1MTrcyd9AXFAbSdDrqGCXYyplUH12inaPwpbAA5H8Nwa7qxeeixu0jeDkUOt)TWQPtsdqQ1tG3G8Nwa7qxeeixeBdKC)plUbHs(13rwsxemketutNkeGlRJNKMil8O3vLYhQPQYxfYtlGDOAzfIap1XJPqGpafaGdCzD8K0epnAc5YYe65I76I7Zf96ILXEwC0CTzBKa2qVw8Nwa7qx0RlcUlwg7zXnS2gPbi16jqtlpK)0cyh6IEDrWDrrNq0P4Io93cRMojnaPwpbEdYFAbSdDrVUi4Ui2gi5(FwCdcL8RVJSKUOxxu0nd2EsUf2cJTfkphFdU5IEDrW6IIUzW2tYrZ1MTrcyd9AXXxZMu6I76I70fbbYfHDXrZ1MTrcyd9AXXxZMu6IGrHyIA6uHaCzD8K0ezHh9UQu(qn1kFvipTa2HQLvic8uhpMcbCx0VHhlGDEy3SjPjanMqBy6EJDfIjQPtfc8wTse9WuLQuLcX)XYPtLp7r19Ok1ut9oqH4XW5K0sfY(DTWgxh6IuzUOjQPtxKnYsYD6OqcXnWWUczhDXD4TA1fPYlh61Yf1NLRnBZPZo6I(0(VwWXUi17aDDX9O6Eu1PJtND0f3pG6duzP9SKUy1U4om3HlTdpWW(s7WB1Q0f3HO3fR2f7KT5IIgnlxSmm9lPl6zTDrdFx86B4f1HUy1UiB8FxK1jTl(SrPxDXQDrnRQJDrWA9jYxOHU4osny4oDC6yIA6uYdXx0AbwTiLLc7A60PJjQPtjpeFrRfy1IuwcvEYuxt300ofJkKRg2KeGolsdqcBph70Xe10PKhIVO1cSArklHTrEc8g0PJtND0fPYPVxGwh6I3)XBUynA3fR17IMOASlosx08BdZcyN70Xe10PKI2Kqca(NkUtND0f3Vz4Xcyx60Xe10PCrkl53WJfWUUPPDkHDZMKMa0ycTHP7n211VXqpfr3my7j5sunToj0gMU3yNJVMnPCx97Tm2ZIlr106KqBy6EJD(tlGDOtND0fPY3eJXKoDmrnDkxKYsgwy5jvJXplDhaky0CeKW2ZXC4bgXulS)63lydFXPnmDVXo3e14)GabEzSNfxIQP1jH2W09g78Nwa7qW4fJMNdpWiMAbk63PJjQPt5IuwkG1nKaGI30DaOe(ItBy6EJDUjQX)bbkafaGJMRnBJysPHYkoAiiqLXEwCdRTrAasTEc00Yd5pTa2HEbB4lUH12i0RnkJBIA8FqGeDZGTNKByTnsdqQ1tG3GC81SjLlugM(fVgTtQMaNdgNoMOMoLlszPGJLhR3K06oaucFXPnmDVXo3e14)GafGcaWrZ1MTrmP0qzfhneeOYyplUH12inaPwpbAA5H8Nwa7qVGn8f3WABe61gLXnrn(piqIUzW2tYnS2gPbi16jWBqo(A2KYfkdt)IxJ2jvtGZbJthtutNYfPSeBOxljrFGcP1Ew6oaucqba4O5AZ2iYc)KUw5OHoDmrnDkxKYswkUSWgJimgt3bGs4loTHP7n25MOg)heOauaaoAU2SnIjLgkR4OHGavg7zXnS2gPbi16jqtlpK)0cyh6fSHV4gwBJqV2OmUjQX)bbs0nd2EsUH12inaPwpbEdYXxZMuUqzy6x8A0oPAcCoyC6yIA6uUiLLmSWYtcrzYR7aqXe14)KNxBUCbk7bceyXO55WdmIPwGI(9IrZrqcBphZHhyetTaL9NQGXPJjQPt5IuwcyWpG1nu3bGs4loTHP7n25MOg)heOauaaoAU2SnIjLgkR4OHGavg7zXnS2gPbi16jqtlpK)0cyh6fSHV4gwBJqV2OmUjQX)bbs0nd2EsUH12inaPwpbEdYXxZMuUqzy6x8A0oPAcCoyC6yIA6uUiLLcmAsdqk8i0tQ7aqjafaGJMRnBJil8t6ALJg61e14)KNxBUKc1oD2rxuFoQSAnxSWtQ3lPlIkn670Xe10PCrklHkpzQRj1DaOuJ2xypQcce4NkHoHHhYXMw4K0etlKnfk8e6H283SI8KEYdce4NkHoHHhY9pYPtsdqGxBK3PJjQPt5IuwcvEYuxt300ofJkKRg2KeGolsdqcBphR7aqbSxkFko3)iNojnaj8yGlQPt(tlGDOxWlJ9S4O5AZ2iMuAOSI)0cyhcgqGal4xkFkox0j8P8qcBaoqJfNRz6Jg7f8lLpfN7FKtNKgGeEmWf10j)PfWoemoDmrnDkxKYsOYtM6A6MM2PyuHC1WMKa0zrAasy75yDhakIUzW2tYTWwySTq554Rztk3L695fSxkFkox0j8P8qcBaoqJfNRz6Jgdc0LYNIZ9pYPtsdqcpg4IA6K)0cyh6Tm2ZIJMRnBJysPHYk(tlGDiyC6yIA6uUiLLqLNm110nnTtXOc5QHnjbOZI0aKW2ZX6oauag61IGVMnPCxr3my7j5wylm2wO8C81SjLlUZ950Xe10PCrklHkpzQRPBAANIjx9B5LeSrfnMiASX0DaOaFakaahBurJjIgBmc8bOaaCzzc92LANoMOMoLlszju5jtDnDtt7um5QFlVKGnQOXerJnMUdaLWxCAuddhljnaXOIJ7ALBIA8FVHV4wyli0RnkJBIA8FNoMOMoLlszju5jtDnDtt7um5QFlVKGnQOXerJnMUdafr3my7j5wylm2wO8C8n4MxWEP8P4CrNWNYdjSb4anwCUMPpASxGHETi4Rztk3v0nd2EsUOt4t5He2aCGglohFnBs5I7rvqGa)s5tX5IoHpLhsydWbAS4CntF0yW40Xe10PCrklHkpzQRPBAANIjx9B5LeSrfnMiASX0DaOam0RfbFnBs5UIUzW2tYTWwySTq554RztkxCpQ60Xe10PCrklHkpzQRPBAANI)roDsAac8AJ86oauaROBgS9KClSfgBluEo(gCZl8bOaaCGlRJNKM4PrtixwMqVfOSpVxkFko3)iNojnaj8yGlQPt(tlGDiyabkafaGJMRnBJysPHYkoAiiqHV40gMU3yNBIA8FNoMOMoLlszju5jtDnDtt7uWMw4K0etlKnfk8e6H283SI8KEYR7aqr0nd2EsUf2cJTfkphFnBs5U7bcuzSNf3WABKgGuRNanT8q(tlGDiiqyBGK7)zXniuYNCx970Xe10PCrklHkpzQRPBAANsWgDNNe8tmMMLMq3bGIOBgS9KCjQMwNeAdt3BSZXxZMuUW(tvqGaVm2ZIlr106KqBy6EJD(tlGDO3A0(c7rvqGa)uj0jm8qo20cNKMyAHSPqHNqp0M)MvKN0tENoMOMoLlszju5jtDnDtt7u0hxswBpSJ1DaOe(ItBy6EJDUjQX)bbc8YyplUevtRtcTHP7n25pTa2HERr7lShvbbc8tLqNWWd5ytlCsAIPfYMcfEc9qB(BwrEsp5D6yIA6uUiLLqLNm110nnTtH2yxym2XssWn90DaOe(ItBy6EJDUjQX)bbc8YyplUevtRtcTHP7n25pTa2HERr7lShvbbc8tLqNWWd5ytlCsAIPfYMcfEc9qB(BwrEsp5D6yIA6uUiLLqLNm110nnTtHg3jTKeIhnJrWg91DaOGrZVlLD6fS1O9f2JQGab(PsOty4HCSPfojnX0cztHcpHEOn)nRipPN8GXPJjQPt5IuwkSRPtDhakIUzW2tYnS2gPbi16jWBqo(gCdeOWxCAdt3BSZnrn(piqbOaaC0CTzBetknuwXrdD6SJU4(f2KLn5K0U4(TbJYEwU4(jMrJExCKUO5IH4PXtT50Xe10PCrkl1Ova(ME6oauGDX9pyu2ZIeYmA0ZXhaF5QfWUxWlJ9S4O5AZ2ibSHET4pTa2HEbhBdKC)plUbHs(13rwsNoMOMoLlszPgTcW30t3bGcSlU)bJYEwKqMrJEo(a4lxTa29cwWlJ9S4O5AZ2ibSHET4pTa2HGavg7zXrZ1MTrcyd9AXFAbSd9k6MbBpjhnxB2gjGn0RfhFnBsjy8AIA8FYZRnxUaL9C6yIA6uUiLLA0kaFtpDhaky08anM(CjA4XYcBtYpvcDcdp0lyHDXbWTSia3)XC8bWxUAbSdceSlEaRBijKz0ONJpa(YvlGDW40zhDX9drnD6I7NpYs60Xe10PCrkljmgJyIA6KWgzPBAANIOBgS9KsNoMOMoLlszjHXyetutNe2ilDtt7uUu(uCPthtutNYfPSegnjMOMojSrw6MM2Py9jYxOH6oaueBc2jpV2C5cu2ZlyfDZGTNKdVvRelHe4f2ghFnBs5UutvVGxg7zXHhyyN)0cyhccKOBgS9KC4bg254Rztk3LAQ6Tm2ZIdpWWo)PfWoemEbhERwjwcjWlSnEnc9MK2PJjQPt5IuwcJMetutNe2ilDtt7uS(KauSS0DaOi2eStEET5YfOSNx4TALyjKaVW241i0BsANoMOMoLlszjmAsmrnDsyJS0nnTtH(5XJGy91DaOyIA8FYZRnxUaL98cwWH3QvILqc8cBJxJqVjP9cwr3my7j5WB1kXsibEHTXXxZMuUa1u1l4LXEwC4bg25pTa2HGaj6MbBpjhEGHDo(A2KYfOMQElJ9S4WdmSZFAbSdbdyC6yIA6uUiLLegJrmrnDsyJS0nnTtH(5XJq3bGIjQX)jpV2CjfQD640zhDX9JMkNlUmkwwoDmrnDk5wFsakwwuE4aV2i0DaOGrZrqcBphZHhyetTlyPMQlcVvRe9YHET4aEA0eEiPmm9l5(1DcgVWB1krVCOxloGNgnHhskdt)sU7(7fC)gESa25HDZMKMa0ycTHP7n2D6yIA6uYT(KauSSwKYspCGxBe6oauWO5iiHTNJ5WdmIP2Dp97fERwj6Ld9AXb80Oj8qszy6xYf0VxW9B4XcyNh2nBsAcqJj0gMU3y3PJjQPtj36tcqXYArkl9WbETrO7aqbC4TALOxo0RfhWtJMWdjLHPFj9cUFdpwa78WUztstaAmH2W09g7oDmrnDk5wFsakwwlszjpnAcjYWNWJD6yIA6uYT(KauSSwKYspCGxBe6oaua3VHhlGDEy3SjPjanMqBy6EJDNooD2rxC)OPY5IiVqdD6yIA6uYT(e5l0qkwUrGju3bGc8wTs0lh61Id4Prt4HKYW0VKlqrSjyN88AZLGaHTbsU)Nf3Gqj)67ilPxSnqY9)S4gek54Rztk3Lc1u70Xe10PKB9jYxOHlszjl3iWeQ7aqbERwj6Ld9AXb80Oj8qszy6xYfOOFNoMOMoLCRpr(cnCrkl9WbETrO7aqbC)gESa25HDZMKMa0ycTHP7n29IrZrqcBphZHhyetT7EufeOauaaUefcFsGDRXX3eLthtutNsU1NiFHgUiLLaUSoEsAISWJExxXMGDszy6xskuR7aqb(auaaoWL1Xtst80OjKlltO3Uu2Pxr3my7j5wylm2wO8C81SjL7UtNoMOMoLCRpr(cnCrklbCzD8K0ezHh9UUInb7KYW0VKuOw3bGc8bOaaCGlRJNKM4PrtixwMqVDP2PJjQPtj36tKVqdxKYsaxwhpjnrw4rVRRytWoPmm9ljfQ1DaOGrZZRr7KQj7BxWk6MbBpjhERwjwcjWlSno(A2KsVGxg7zXHhyyN)0cyhccKOBgS9KC4bg254Rztk9wg7zXHhyyN)0cyhcgNoMOMoLCRpr(cnCrkl9WbETrO7aqbC)gESa25HDZMKMa0ycTHP7n2D640zhDX9tDnDkDrlHUyxRh7ID6IOY70Xe10PKl6MbBpPKcQ8KPUM0PJjQPtjx0nd2Es5IuwkSRPtDhakHV40gMU3yNBIA8FqGcqba4O5AZ2iMuAOSIJgccuzSNf3WABKgGuRNanT8q(tlGDOxWg(IByTnc9AJY4MOg)heir3my7j5gwBJ0aKA9e4nihFnBs5cLHPFXRr7KQjW5GXPZo6I6Z7MbBpP0PJjQPtjx0nd2Es5IuwYWABKgGuRNaVb1DaOi6MbBpjhnxB2gjGn0RfhFnBs5U63BzSNfhnxB2gjGn0Rf)PfWoeeiWlJ9S4O5AZ2ibSHET4pTa2HoDmrnDk5IUzW2tkxKYsO5AZ2ibSHET0DaOao2gi5(FwCdcL8RVJSKEbROBgS9KCdRTrAasTEc8gKJVMnPCb9dce8wTs0lh61IdhPfWoX6ccgVGv0nd2EsUf2cJTfkphFdU5fSWhGcaWbUSoEsAINgnHCzzc9wGY(abcJMFbk7emGaj6MbBpj3cBHX2cLNJVMnPemEbhBdKC)plUbHs(13rwsNoMOMoLCr3my7jLlszj0CTzBKa2qVw6oauW2aj3)ZIBqOKF9DKL0lynrn(p551MlxGYEGaHTbsU)Nf3GqjFYfOw)GXPJjQPtjx0nd2Es5IuwcAy9if2sjqJ1SA6u3bGc4yBGK7)zXniuYV(oYs6v0nd2EsoAU2SnsaBOxlo(A2KsVGfCmAEGgtFo8gKnxwerpm(PsOty4HGaHrZd0y6ZH3GS5YIi6HXpvcDcdp0lybpafaGdnSEKcBPeOXAwnDYrd9cEzSNfhnxB2gj0ef)PfWoeeOYyploAU2SnsOjk(tlGDiyaJthtutNsUOBgS9KYfPSe0W6rkSLsGgRz10PUdafWX2aj3)ZIBqOKF9DKL0l4LXEwC0CTzBKa2qVw8Nwa7qNoMOMoLCr3my7jLlszjOH1JuylLanwZQPtDhakyBGK7)zXniuYV(oYs6fSMOg)N88AZLlqzpqGW2aj3)ZIBqOKp5cuRFW40Xe10PKl6MbBpPCrklzHTWyBHYR7aqXe14)KNxBUKc1EHpafaGdCzD8K0epnAc5YYe6TaL95fSGf8YyploAU2SnsaBOxl(tlGDiiqLXEwCdRTrAasTEc00Yd5pTa2HGaj6eIofx0P)wy10jPbi16jWBq(tlGDiyabQm2ZIJMRnBJeWg61I)0cyh6f8YyplUH12inaPwpbAA5H8Nwa7qVWU4O5AZ2ibSHET44RztkbJthtutNsUOBgS9KYfPSKf2cJTfkVUdaftuJ)tEET5YfOSNx4dqba4axwhpjnXtJMqUSmHElqzFEbhERwjwcjWlSnEnc9MK2PJjQPtjx0nd2Es5IuwsIQP1jH2W09g76oauWO5iiHTNJ5WdmIP2L6950Xe10PKl6MbBpPCrklHMRnBJysPHYkDhakMOg)N88AZLuO2l8bOaaCGlRJNKM4PrtixwMqVD3ZlydFXTWwqOxBug3e14)Gaj6eIofx0P)wy10jPbi16jWBq(tlGDiyC6yIA6uYfDZGTNuUiLLqZ1MTrmP0qzLUInb7KYW0VKuOw3bGIjQX)jpV2C5cu2Zl8bOaaCGlRJNKM4PrtixwMqVD3ZPJjQPtjx0nd2Es5Iuws2Omc(w4X6k2eStkdt)ssHADhakLHPFXRr7KQjHIISt9VR(9wgM(fVgTtQMaNVG(D6yIA6uYfDZGTNuUiLLW2ipbEdQ7aqb8WxC61gLXnrn(VthNoMOMoL8lLpfxsr7AnEJ0aegQyGei(MMu3bGcgnpVgTtQMq9c0cOxmAocsy754D3hvD6yIA6uYVu(uC5IuwkG1nK0aKA9KNxBt3bGc8wTsSesGxyB8Ae6njniqHV4wyli0RnkJBIA8FVMOg)N88AZLuO2PJjQPtj)s5tXLlszjAuddhljnaXOIJ7Av3bGcyfDZGTNKBHTWyBHYZXxZMuU7(7v0nd2EsUH12inaPwpbEdYXxZMuUGOBgS9KCrNWNYdjSb4anwCo(A2KsWacKOBgS9KCdRTrAasTEc8gKJVMnPC39C6yIA6uYVu(uC5IuwQwpbndA0esaAS46oaucqba44l0JDPKa0yX5OHGafGcaWXxOh7sjbOXItenAwhZLLj0BxQP2PJjQPtj)s5tXLlszjGwGkpKyuXXtDsWnnDhakGdVvRelHe4f2gVgHEts70Xe10PKFP8P4YfPSKOtXZcB1HeaMPDDhakWU4IofplSvhsayM2jbO4KJVMnPKcvD6yIA6uYVu(uC5IuwkefpaBtstcyMS0DaOao8wTsSesGxyB8Ae6njTthtutNs(LYNIlxKYsEAmd6)tsWx2PLIR7aqPm2ZIByTnsdqQ1tGMwEi)PfWo07LYNIZ9pYPtsdqcpg4IA6KRnzJ9gGcaWrZ1MTrKf(jDTYrdbb6s5tX5(h50jPbiHhdCrnDY1MSXEdFXTWwqOxBug3e14)Gavg7zXnS2gPbi16jqtlpK)0cyh6n8f3cBbHETrzCtuJ)7v0nd2EsUH12inaPwpbEdYXxZMuUW(tvqGkJ9S4gwBJ0aKA9eOPLhYFAbSd9g(IByTnc9AJY4MOg)3PJjQPtj)s5tXLlszjpnMb9)jj4l70sX1DaOao8wTsSesGxyB8Ae6njT3auaaoAU2SnISWpPRvoAOxWVu(uCU)roDsAas4XaxutNCTjBSxWlJ9S4gwBJ0aKA9eOPLhYFAbSdbbQmm9lEnANunboFxr3my7j5wylm2wO8C81SjLoDmrnDk5xkFkUCrklHNWq2jtsKHM46oauahERwjwcjWlSnEnc9MK2PJjQPtj)s5tXLlszj8TWjPjamt7sNooD2rxezsA2DrFnm9lNoMOMoLC6NhpckWB1kr0dt3bGsakaaxIcHpjWU144BIYl4(n8ybSZd7MnjnbOXeAdt3BSdcu4loTHP7n25MOg)3PJjQPtjN(5XJyrklbVvRerpmDhaky0CeKW2ZXC4bgXu7s9o9cUFdpwa78WUztstaAmH2W09g7oDmrnDk50ppEelszj4bg21DaOi6MbBpj3cBHX2cLNJVMnP0PJjQPtjN(5XJyrkl5Prtirg(eESUdaf4dqba4axwhpjnXtJMqUSmHElSpNoMOMoLC6NhpIfPSKNgnHez4t4X6oauGpafaGdCzD8K0epnAc5OHEfDZGTNKBHTWyBHYZXxZMuUG(9cwWlJ9S4O5AZ2ibSHET4pTa2HGavg7zXnS2gPbi16jqtlpK)0cyhccKOti6uCrN(BHvtNKgGuRNaVb5pTa2HGaHTbsU)Nf3Gqj)67iljyC6yIA6uYPFE8iwKYsEA0esKHpHhR7aqb(auaaoWL1Xtst80OjKJg6Tm2ZIJMRnBJeWg61I)0cyh6f8YyplUH12inaPwpbAA5H8Nwa7qVGl6eIofx0P)wy10jPbi16jWBq(tlGDOxWX2aj3)ZIBqOKF9DKL0lyfDZGTNKJMRnBJeWg61IJVMnPCb97v0nd2EsUf2cJTfkphFdU5fCyxC0CTzBKa2qVwC81SjLGabUOBgS9KClSfgBluEo(gCdmoDmrnDk50ppEelszj4TALi6HP7aqbJMJGe2EoMdpWiMA39OQxW9B4XcyNh2nBsAcqJj0gMU3y3PJjQPtjN(5XJyrklbCzD8K0ezHh9UUdaf4dqba4axwhpjnXtJMqUSmHE7sTthtutNso9ZJhXIuwc4Y64jPjYcp6DDhakWhGcaWbUSoEsAINgnHCzzc92DFEfDZGTNKBHTWyBHYZXxZMuU7o9cwWlJ9S4O5AZ2ibSHET4pTa2HGavg7zXnS2gPbi16jqtlpK)0cyhccKOti6uCrN(BHvtNKgGuRNaVb5pTa2HGaHTbsU)Nf3Gqj)67iljyC6yIA6uYPFE8iwKYsaxwhpjnrw4rVR7aqb(auaaoWL1Xtst80OjKlltO3U7ZBzSNfhnxB2gjGn0Rf)PfWo0l4LXEwCdRTrAasTEc00Yd5pTa2HEbx0jeDkUOt)TWQPtsdqQ1tG3G8Nwa7qVGJTbsU)Nf3Gqj)67ilPxr3my7j5wylm2wO8C8n4MxWk6MbBpjhnxB2gjGn0RfhFnBs5U7eeiyxC0CTzBKa2qVwC81SjLGXPJjQPtjN(5XJyrklbVvRerpmDhakG73WJfWopSB2K0eGgtOnmDVXUthNo7OlUF2ZJhHlUF0u5CX9t4PXtT50Xe10PKt)84rqS(uE4aV2i0DaOeGcaWLOq4tcSBno(MOC6yIA6uYPFE8iiw)fPS0dh41gHUdafW9B4XcyNh2nBsAcqJj0gMU3y3PJjQPtjN(5XJGy9xKYsEA0esKHpHhRRytWoPmm9ljfQ1DaOawr3my7j5wylm2wO8C81SjLlOFVWhGcaWbUSoEsAINgnHC0qqGGpafaGdCzD8K0epnAc5YYe6TW(aJxWcm0RfbFnBs5UIUzW2tYH3QvILqc8cBJJVMnPCrQPkiqad9ArWxZMuUGOBgS9KClSfgBluEo(A2KsW40Xe10PKt)84rqS(lszjGlRJNKMil8O31vSjyNugM(LKc16oauGpafaGdCzD8K0epnAc5YYe6TlLD6v0nd2EsUf2cJTfkphFnBs5U7eei4dqba4axwhpjnXtJMqUSmHE7sTthtutNso9ZJhbX6ViLLaUSoEsAISWJExxXMGDszy6xskuR7aqr0nd2EsUf2cJTfkphFnBs5c63l8bOaaCGlRJNKM4PrtixwMqVDPwHyO1AJviiJgkZQPt95ydOuLQuk]] )

end
