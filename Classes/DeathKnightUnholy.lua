-- DeathKnightUnholy.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State


if UnitClassBase( 'player' ) == 'DEATHKNIGHT' then
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
        }
    }, setmetatable( {
        expiry = { 0, 0, 0, 0, 0, 0 },
        cooldown = 10,
        regen = 0,
        max = 6,
        forecast = {},
        fcount = 0,
        times = {},
        values = {},

        reset = function()
            local t = state.runes

            for i = 1, 6 do
                local start, duration, ready = GetRuneCooldown( i )
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
                t.expiry[ 1 ] = ( t.expiry[ 4 ] > 0 and t.expiry[ 4 ] or state.query_time ) + t.cooldown
                table.sort( t.expiry )
            end

            t.actual = nil
        end,
    }, {
        __index = function( t, k, v )
            if k == 'actual' then
                local amount = 0

                for i = 1, 6 do
                    amount = amount + ( t.expiry[ i ] <= state.query_time and 1 or 0 )
                end

                return amount

            elseif k == 'current' then
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

            elseif k == 'time_to_next' then
                return t[ 'time_to_' .. t.current + 1 ]

            elseif k == 'time_to_max' then
                return t.current == 6 and 0 or max( 0, t.expiry[6] - state.query_time )

            else
                local amount = k:match( "time_to_(%d+)" )
                amount = amount and tonumber( amount )

                if amount then return state:TimeToResource( t, amount ) end
            end
        end
    } ) )

    spec:RegisterResource( Enum.PowerType.RunicPower )


    local spendHook = function( amt, resource )
        if amt > 0 and resource == "runes" then
            gain( amt * 10, "runic_power" )

            if set_bonus.tier20_4pc == 1 then
                cooldown.army_of_the_dead.expires = max( 0, cooldown.army_of_the_dead.expires - 1 )
            end
        end
    end

    spec:RegisterHook( "spend", spendHook )

    
    spec:RegisterStateFunction( "apply_festermight", function( n )
        if azerite.festermight.enabled then
            if buff.festermight.up then
                addStack( "festermight", buff.festermight.remains, n )
            else
                applyBuff( "festermight", nil, n )
            end
        end
    end )

    
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
        soul_reaper = 22526, -- 130736

        spell_eater = 22528, -- 207321
        wraith_walk = 22529, -- 212552
        death_pact = 23373, -- 48743

        pestilence = 22532, -- 277234
        defile = 22534, -- 152280
        epidemic = 22536, -- 207317

        army_of_the_damned = 22030, -- 276837
        unholy_frenzy = 22110, -- 207289
        summon_gargoyle = 22538, -- 49206
    } )

    -- PvP Talents
    spec:RegisterPvpTalents( { 
        adaptation = 3537, -- 214027
        relentless = 3536, -- 196029
        gladiators_medallion = 3535, -- 208683

        ghoulish_monstrosity = 3733, -- 280428
        necrotic_aura = 3437, -- 199642
        cadaverous_pallor = 163, -- 201995
        reanimation = 152, -- 210128
        heartstop_aura = 44, -- 199719
        decomposing_aura = 3440, -- 199720
        necrotic_strike = 149, -- 223829
        unholy_mutation = 151, -- 201934
        wandering_plague = 38, -- 199725
        antimagic_zone = 42, -- 51052
        dark_simulacrum = 41, -- 77606
        crypt_fever = 40, -- 199722
        pandemic = 39, -- 199724
    } )

    -- Auras
    spec:RegisterAuras( {
        antimagic_shell = {
            id = 48707,
            duration = function () return 5 + ( talent.spell_eater.enabled and 5 or 0 ) + ( ( level < 116 and equipped.acherus_drapes ) and 5 or 0 ) end,
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
        dark_succor = {
            id = 178819,
        },
        dark_transformation = {
            id = 63560, 
            duration = 20,
            generate = function ()
                local cast = class.abilities.dark_transformation.lastCast or 0
                local up = pet.ghoul.up and cast + 20 > state.query_time

                local dt = buff.dark_transformation
                dt.name = class.abilities.dark_transformation.name
                dt.count = up and 1 or 0
                dt.expires = up and cast + 20 or 0
                dt.applied = up and cast or 0
                dt.caster = "player"
            end,
        },
        death_and_decay_debuff = {
            id = 43265,
            duration = 10,
            max_stack = 1,
        },
        death_and_decay = {
            id = 188290,
            duration = 10
        },
        death_pact = {
            id = 48743,
            duration = 15,
            max_stack = 1,
        },
        deaths_advance = {
            id = 48265,
            duration = 8,
            max_stack = 1,
        },
        defile = {
            id = 156004,
            duration = 10,
        },
        festering_wound = {
            id = 194310,
            duration = 30,
            max_stack = 6,
            meta = {
                stack = function ()
                    -- Designed to work with Unholy Frenzy, time until 4th Festering Wound would be applied.
                    local actual = debuff.festering_wound.count
                    if buff.unholy_frenzy.down then return actual end

                    local slot_time = now + offset
                    local swing, speed = state.swings.mainhand, state.swings.mainhand_speed

                    local last = swing + ( speed * floor( slot_time - swing ) / swing )
                    local window = min( buff.unholy_frenzy.expires, query_time ) - last

                    local bonus = floor( window / speed )

                    return min( 6, actual + bonus )
                end
            }
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
        on_a_pale_horse = {
            id = 51986,
        },
        outbreak = {
            id = 196782,
            duration = 6,
            type = "Disease",
            max_stack = 1,
            tick_time = 1,
        },
        path_of_frost = {
            id = 3714,
            duration = 600,
            max_stack = 1,
        },
        runic_corruption = {
            id = 51460,
            duration = 3,
            max_stack = 1,
        },
        sign_of_the_skirmisher = {
            id = 186401,
            duration = 3600,
            max_stack = 1,
        },
        soul_reaper = {
            id = 130736,
            duration = 8,
            type = "Magic",
            max_stack = 1,
        },
        sudden_doom = {
            id = 81340,
            duration = 10,
            max_stack = 2,
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
        },
        unholy_frenzy = {
            id = 207289,
            duration = 12,
            max_stack = 1,
        },
        unholy_strength = {
            id = 53365,
            duration = 15,
            max_stack = 1,
        },
        virulent_plague = {
            id = 191587,
            duration = 21,
            tick_time = function () return 3 * haste end,
            type = "Disease",
            max_stack = 1,
        },
        wraith_walk = {
            id = 212552,
            duration = 4,
            type = "Magic",
            max_stack = 1,
        },



        -- Azerite Powers
        festermight = {
            id = 274373,
            duration = 20,
            max_stack = 99,
        }
    } )


    spec:RegisterStateTable( 'death_and_decay', 
        setmetatable( { onReset = function( self ) end },
        { __index = function( t, k )
            if k == 'ticking' then
                return buff.death_and_decay.up
            
            elseif k == 'remains' then
                return buff.death_and_decay.remains
            
            end

            return false
        end } ) )

    spec:RegisterStateTable( 'defile', 
        setmetatable( { onReset = function( self ) end },
        { __index = function( t, k )
            if k == 'ticking' then
                return buff.death_and_decay.up

            elseif k == 'remains' then
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


    spec:RegisterStateFunction( "time_to_wounds", function( x )
        if debuff.festering_wound.stack >= x then return 0 end
        if buff.unholy_frenzy.down then return 3600 end

        local deficit = x - debuff.festering_wound.stack
        local swing, speed = state.swings.mainhand, state.swings.mainhand_speed

        local last = swing + ( speed * floor( query_time - swing ) / swing )
        local fw = last + ( speed * deficit ) - query_time

        if fw > buff.unholy_frenzy.remains then return 3600 end
        return fw
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


    spec:RegisterPet( "ghoul", 26125 )    
    spec:RegisterPet( "gargoyle", 49206 )

    spec:RegisterHook( "reset_precast", function ()
        local expires = action.summon_gargoyle.lastCast + 35
        if expires > now then
            summonPet( "gargoyle", expires - now )
        end

        local control_expires = action.control_undead.lastCast + 300
        if control_expires > now and pet.up and not pet.ghoul.up then
            summonPet( "controlled_undead", control_expires - now )
        end
    end )


    -- Abilities
    spec:RegisterAbilities( {
        antimagic_shell = {
            id = 48707,
            cast = 0,
            cooldown = 60,
            gcd = "off",
            
            startsCombat = false,
            texture = 136120,
            
            handler = function ()
                applyBuff( "antimagic_shell" )
            end,
        },
        

        apocalypse = {
            id = 275699,
            cast = 0,
            cooldown = 90,
            gcd = "spell",
            
            toggle = "cooldowns",

            startsCombat = true,
            texture = 1392565,
            
            handler = function ()
                if debuff.festering_wound.stack > 4 then
                    applyDebuff( "target", "festering_wound", debuff.festering_wound.remains, debuff.festering_wound.remains - 4 )
                    apply_festermight( 4 )
                    gain( 12, "runic_power" )
                else                    
                    gain( 3 * debuff.festering_wound.stack, "runic_power" )
                    apply_festermight( debuff.festering_wound.stack )
                    removeDebuff( "target", "festering_wound" )
                end
                -- summon pets?                
            end,
        },
        

        army_of_the_dead = {
            id = 42650,
            cast = 0,
            cooldown = 480,
            gcd = "spell",
            
            spend = 3,
            spendType = "runes",
            
            toggle = "cooldowns",

            startsCombat = false,
            texture = 237511,
            
            handler = function ()
                applyBuff( "army_of_the_dead", 4 )
                if set_bonus.tier20_2pc == 1 then applyBuff( "master_of_ghouls" ) end
            end,
        },
        

        asphyxiate = {
            id = 108194,
            cast = 0,
            cooldown = 45,
            gcd = "spell",
            
            startsCombat = true,
            texture = 538558,

            talent = "asphyxiate",
            
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
            
            recheck = function ()
                return buff.unholy_strength.remains - gcd, buff.unholy_strength.remains
            end,
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
                if debuff.festering_wound.stack > 1 then
                    applyDebuff( "target", "festering_wound", debuff.festering_wound.remains, debuff.festering_wound.stack - 1 )
                else removeDebuff( "target", "festering_wound" ) end
                apply_festermight( 1 )
                gain( 3, "runic_power" )
            end,
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
            end,
        },
        

        death_and_decay = {
            id = 43265,
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
        },
        

        death_coil = {
            id = 47541,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = function () return buff.sudden_doom.up and 0 or 40 end,
            spendType = "runic_power",
            
            startsCombat = true,
            texture = 136145,
            
            handler = function ()
                removeStack( "sudden_doom" )
                if set_bonus.tier21_2pc == 1 then applyDebuff( "target", "coils_of_devastation" ) end
                if cooldown.dark_transformation.remains > 0 then setCooldown( 'dark_transformation', cooldown.dark_transformation.remains - 1 ) end
            end,
        },
        

        --[[ death_gate = {
            id = 50977,
            cast = 4,
            cooldown = 60,
            gcd = "spell",
            
            spend = 1,
            spendType = "runes",
            
            startsCombat = false,
            texture = 135766,
            
            handler = function ()
            end,
        }, ]]
        

        death_grip = {
            id = 49576,
            cast = 0,
            charges = 1,
            cooldown = 25,
            recharge = 25,
            gcd = "spell",
            
            startsCombat = true,
            texture = 237532,
            
            handler = function ()
                applyDebuff( "target", "death_grip" )
                setDistance( 5 )
            end,
        },
        

        death_pact = {
            id = 48743,
            cast = 0,
            cooldown = 120,
            gcd = "spell",
            
            startsCombat = false,
            texture = 136146,

            talent = "death_pact",
            
            handler = function ()
                gain( health.max * 0.5, "health" )
                applyBuff( "death_pact" )
            end,
        },
        

        death_strike = {
            id = 49998,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = function () return buff.dark_succor.up and 0 or 45 end,
            spendType = "runic_power",
            
            startsCombat = true,
            texture = 237517,
            
            handler = function ()
                removeBuff( "dark_succor" )
                if level < 116 and equipped.death_march then
                    local cd = cooldown[ talent.defile.enabled and "defile" or "death_and_decay" ]
                    cd.expires = max( 0, cd.expires - 2 )
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
                applyDebuff( "target", "defile", 1 )
            end,
        },
        

        epidemic = {
            id = 207317,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = 30,
            spendType = "runic_power",
            
            startsCombat = true,
            texture = 136066,

            talent = "epidemic",

            usable = function () return active_dot.virulent_plague > 0 end,
            handler = function ()
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
            
            handler = function ()
                applyDebuff( "target", "festering_wound", 24, debuff.festering_wound.stack + 2 )
            end,
        },
        

        icebound_fortitude = {
            id = 48792,
            cast = 0,
            cooldown = 180,
            gcd = "spell",
            
            toggle = "defensives",

            startsCombat = false,
            texture = 237525,
            
            handler = function ()
                applyBuff( "icebound_fortitude" )
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
            
            usable = function () return target.casting end,
            handler = function ()
                interrupt()
            end,
        },
        

        outbreak = {
            id = 77575,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = -10,
            spendType = "runic_power",
            
            startsCombat = true,
            texture = 348565,

            handler = function ()
                applyDebuff( "target", "outbreak" )
                applyDebuff( "target", "virulent_plague", talent.ebon_fever.enabled and 10.5 or 21 )
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
            id = 46584,
            cast = 0,
            cooldown = 30,
            gcd = "spell",            
            
            startsCombat = false,
            texture = 1100170,

            essential = true, -- new flag, will allow recasting even in precombat APL.
            
            usable = function () return not pet.alive end,
            handler = function ()
                summonPet( "ghoul", 3600 )
                if talent.all_will_serve.enabled then summonPet( "skeleton", 3600 ) end
            end,
        },
        

        --[[ runeforging = {
            id = 53428,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            startsCombat = false,
            texture = 237523,
            
            usable = false,
            handler = function ()
            end,
        }, ]]
        

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

            usable = function () return debuff.festering_wound.up end,
            handler = function ()
                gain( 3, "runic_power" )
                if debuff.festering_wound.stack > 1 then
                    applyDebuff( "target", "festering_wound", debuff.festering_wound.remains, debuff.festering_wound.stack - 1 )
                else removeDebuff( "target", "festering_wound" ) end
                apply_festermight( 1 )
            end,
        },
        

        soul_reaper = {
            id = 130736,
            cast = 0,
            cooldown = 45,
            gcd = "spell",
            
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
            end,
        },
        

        unholy_frenzy = {
            id = 207289,
            cast = 0,
            cooldown = 75,
            gcd = "spell",
            
            toggle = "cooldowns",

            startsCombat = true,
            texture = 136224,

            talent = "unholy_frenzy",
            
            handler = function ()
                applyBuff( "unholy_frenzy" )
                stat.haste = state.haste + 0.20
            end,
        },
        

        wraith_walk = {
            id = 212552,
            cast = 0,
            channeled = 4,
            cooldown = 60,
            gcd = "spell",
            
            startsCombat = false,
            texture = 1100041,

            talent = "wraith_walk",
            
            handler = function ()
                applyBuff( "wraith_walk" )
            end,
        },
    } )


    spec:RegisterOptions( {
        enabled = true,

        aoe = 2,
    
        nameplates = true,
        nameplateRange = 8,
        
        damage = true,
        damageExpiration = 8,
    
        potion = "battle_potion_of_strength",
    
        package = "Unholy",
    } )

    spec:RegisterPack( "Unholy", 20180830.2127, [[dSet0aqijv9ivOSjjYNqefJsvXPuv5vuQAwsuULev1Ui1VubdtIkhtsLLPc5zksAAicxJs02KOkFdrunokf5CukQwhIiMNQQUhIAFuQCqkfQfsP0drePMOkuXfPuuAJiIK(OkujojIO0kveVurcMjLIIUPIeANucdvfQAPks0tryQisxLsHSvvOs1xvHkL9I0FvyWeDyQwSeEmHjJYLH2mqFwvgnL0PvA1ukk8AvLMnj3wL2TOFlmCf1XvHkPLJQNtX0L66a2UIuFxfnEerIZljRNsbZxsz)GMwhLukbZBKAXrLRoBQC20ulN(O6oIKx3ruIUAgPeZU4R)qkr6xKsyJsRHQIsm7vQWzusPeMaGlqkH1UNnKKdh4(P(TTvGcadYfr2y2ArCpy2lGY7nsb3b7dM9koua6LpdN(WmpaxfAoC8CCk9LzoC8t544GEBDmfY9zTh2O0AOQ0M9kOefaRQjztAbLG5nsT4OYvNnvoBAQLtFuDhvELBQucZmkOwCKLhrjyOrqjoguAJsRHQckpoO3wHYPqUpRnCYXGsRDpBijho822kqHwe3dM9cO8EJuWDW(GzVIdfQO4qbOx(mC6dZ8aCvO5WXZXP0xM5WXpLJJd6T1Xui3N1EyJsRHQsB2Rao5yqPng4byAOCQLRmO8OYvNnbLLpuAZjjLRCq5XpfHtGtogussB1ZhAijWjhdklFO0gZyidkNIBYGssQCeTbudNCmOS8HYPeVX0idkN25RxOq9CeQnFdWGpEo)fvkek9KbL3yAKbLIizBVrAGYn7akrxyfk5OY7DAek9IvTDfu(PdO0kQMHYZTTcLoJfju27DZN5NMsOwtBOKsjEyI8vqjLArDusPey6fkKrTLsi4BJ81PefaGGAdaJH5GfXvZrx0qzjOSEO8dukIqXIZuBaU3ihpN)IkfQ54130aL)HslHYsqz7kmBTb4EJC8C(lQuOgtVqHmO8huwRguoJT(58xuPqTl6DAKs4IEJKsWqVToeXQOn1IJOKsjW0luiJAlLqW3g5Rtj4a5kgZXjY1meCfBdL)HY6ibuwck)aLIiuS4m1(CiCv1Sb1C86BAGs7GslHYA1GsgwaacQbrtJ8nFJZaizAt7IVqPDqjjGYFqzjOSEO8dukIqXIZuBaU3ihpN)IkfQ54130aL)HslHYsqz7kmBTb4EJC8C(lQuOgtVqHmO8hLWf9gjLGHEBDiIvrBQftLskLatVqHmQTucbFBKVoLODfMTEgn9QWuGAm9cfYGYsqPicflotTphcxvnBqnhV(MgkHl6nskbd926Wt2GHcVI2ulibLukbMEHczuBPec(2iFDkHicflotTphcxvnBqnhV(MgkHl6nskbdbxfsBQfwsjLsGPxOqg1wkHGVnYxNs8bk)aLmSaaeudIMg5B(gNbqY0aZqzjOueHIfNP2NdHRQMnOMJxFtduAhuAju(dkRvdkzybaiOgennY38nodGKPnTl(cL2bLKak)bLLGsrekwCMANFRgb4OTIdg6mnhV(MgO0oO0skHl6nskHrea8homnF)I0MAr5rjLsGPxOqg1wkHGVnYxNs8bk)aLmSaaeudIMg5B(gNbqY0aZqzjOueHIfNP2NdHRQMnOMJxFtduAhuAju(dkRvdkzybaiOgennY38nodGKPnTl(cL2bLKak)bLLGsrekwCMANFRgb4OTIdg6mnhV(MgO0oO0skHl6nskHq5NB(ggRolon0MAbjNskLatVqHmQTucbFBKVoLGdKRymhNixZqWvSnu(hkpQCqzjOSEO8dukIqXIZuBaU3ihpN)IkfQ54130aL)HslHYsqz7kmBTb4EJC8C(lQuOgtVqHmO8hLWf9gjLGHEBDiIvrBQf2eLukbMEHczuBPec(2iFDkXhO8du(bk)aLmSaaeudIMg5B(gNbqY0M2fFHY)qjjGYsqz9qzbaiOgiTgQQbihtBOsdmdL)GYA1GsgwaacQbrtJ8nFJZaizAt7IVq5FOCQq5pOSeukIqXIZu7ZHWvvZguZXRVPbk)dLtfk)bL1QbLmSaaeudIMg5B(gNbqY0M2fFHY)qzDq5pOSeukIqXIZu78B1iahTvCWqNP54130aL2bLwsjCrVrsjartJ8nFdtZ3ViTPwyZPKsjW0luiJAlLqW3g5RtjQhk)aLIiuS4m1gG7nYXZ5VOsHAoE9nnq5FO0sOSeu2UcZwBaU3ihpN)IkfQX0luidk)rjCrVrsjyO3whIyv0M2ucgc6aQMsk1I6OKsjCrVrsjCGogE3U4lLatVqHmQT0MAXrusPeUO3iPe3nzdqoI2asjW0luiJAlTPwmvkPucm9cfYO2sje8Tr(6ucoqUIXCCICndbxX2qPDqz5zjuwck)aLZyRFo)fvku7IENgHYA1GY6HY2vy2AdW9g5458xuPqnMEHczq5pOSeuYbsuZqWvSnuAhzO0skHl6nskHZfEIJo4CmBAtTGeusPey6fkKrTLsi4BJ81PeZyRFo)fvku7IENgHYA1GY6HY2vy2AdW9g5458xuPqnMEHczucx0BKuIcveSbiaVI2ulSKskLatVqHmQTucbFBKVoLygB9Z5VOsHAx070iuwRguwpu2UcZwBaU3ihpN)IkfQX0luiJs4IEJKsuGCdY)U5J2ulkpkPucx0BKucado2gVgkbMEHczuBPn1csoLukbMEHczuBPeUO3iPeagCSnEPec(2iFDkHicflotTb4EJC8C(lQuOMJxFtduAhuwELdkRvdkRhkBxHzRna3BKJNZFrLc1y6fkKrjs)IuIIQxK4OaXHRUE6cAtTWMOKsjW0luiJAlLWf9gjLaWGJTXlLqW3g5RtjMXw)C(lQuO2f9oncL1QbL1dLTRWS1gG7nYXZ5VOsHAm9cfYOePFrkHnd0mSgNkKtBQf2CkPucm9cfYO2sjCrVrsjam4yB8sje8Tr(6uIzS1pN)IkfQDrVtJqzTAqz9qz7kmBTb4EJC8C(lQuOgtVqHmkr6xKs8CfkCLc5Mrb6FPn1I6khLukbMEHczuBPec(2iFDkHicflotTZVvJaC0wXbdDMMJoRckRvdkNXw)C(lQuO2f9oncL1QbLfaGGAG0AOQgGCmTHknWmLWf9gjLyo6nsAtTOU6OKsjW0luiJAlLqW3g5Rtj(aLSO1tVCafM9yw5pau3R47O3lo44130aL2dL9k(o69Iq5FYqjlA90lhqHzpMv(da1C86BAGYFqzjOKfTE6LdOWShZk)bGAoE9nnq5FYq5tWOeUO3iPebqxWr)lTPwu3rusPey6fkKrTLs4IEJKsiCLA4IEJCOwttjuRPhPFrkHicflotdTPwu3uPKsjW0luiJAlLqW3g5RtjCrVtJdmX7IgO0oYq5rucx0BKucoqoCrVrouRPPeQ10J0ViLWdK2ulQJeusPey6fkKrTLs4IEJKsiCLA4IEJCOwttjuRPhPFrkXdtKVcAtBkXmhfXTWBkPulQJskLatVqHmQT0MAXrusPey6fkKrTL2ulMkLukbMEHczuBPn1csqjLsGPxOqg1wAtTWskPucx0BKuI5O3iPey6fkKrTL2ulkpkPucx0BKucUVgCWqNrjW0luiJAlTPwqYPKsjW0luiJAlLGHkVIsCeLWf9gjLW53QraoAR4GHoJ20MsiIqXIZ0qjLArDusPeUO3iPeo)wncWrBfhm0zucm9cfYO2sBQfhrjLsGPxOqg1wkHGVnYxNsWWcaqqniAAKV5BCgajtBAx8fkTJmusckHl6nskHphcxvnBqAtTyQusPeUO3iPemN)D0CpnGb)69gjLatVqHmQT0MAbjOKsjW0luiJAlLqW3g5Rtj4a5kgZXjY1meCfBdL)HY6ibLWf9gjLWaCVroEo)fvkK2ulSKskLatVqHmQTucbFBKVoLGHfaGGAq00iFZ34masM20U4lu(hkjbLWf9gjLaiTgQQbihtBOI2ulkpkPucm9cfYO2sje8Tr(6ucx0704at8UObkTJmuEeuwck)aLFGsrekwCMAg6T1HNSbdfELMJxFtdu(Nmu(emOSeuwpu2UcZwZqWvHAm9cfYGYFqzTAq5hOueHIfNPMHGRc1C86BAGY)KHYNGbLLGY2vy2AgcUkuJPxOqgu(dk)rjCrVrsjasRHQAaYX0gQOn1csoLukbMEHczuBPec(2iFDkXhOSD(dBDVxC0XGTiu(hkTjOSwnOKdKiu(NmuEeu(dklbL1dLfaGGAG0AOQgGCmTHknWmLWf9gjLWeaQbh9zKtBQf2eLukHl6nskbqAnuvJc1(S2ucm9cfYO2sBAtj8aPKsTOokPucm9cfYO2sje8Tr(6ucrekwCMAFoeUQA2GAoE9nnucx0BKucg6T1HNSbdfEfTPwCeLukHl6nskbdbxfsjW0luiJAlTPwmvkPucm9cfYO2sje8Tr(6ucg6T1HNSbdfELUxX3nFqzjOKdKiu(hkpcklbL1dLFGsrekwCMAdW9g5458xuPqnhV(MgO8puAjuwckBxHzRna3BKJNZFrLc1y6fkKbL)OeUO3iPe48YW7kOn1csqjLsGPxOqg1wkHGVnYxNsWqVTo8KnyOWR09k(U5dklbLCGeHY)q5rqzjOSEO8dukIqXIZuBaU3ihpN)IkfQ54130aL)HslHYsqz7kmBTb4EJC8C(lQuOgtVqHmO8hLWf9gjLGHEBDiIvrBQfwsjLsGPxOqg1wkHGVnYxNsWqVTo8KnyOWR09k(U5dklbLIiuS4m1(CiCv1Sb1C86BAOeUO3iPegraWF4W089lsBQfLhLukbMEHczuBPec(2iFDkbd926Wt2GHcVs3R47MpOSeukIqXIZu7ZHWvvZguZXRVPHs4IEJKsiu(5MVHXQZItdTPwqYPKsjW0luiJAlLqW3g5RtjQhk)aLIiuS4m1gG7nYXZ5VOsHAoE9nnq5FO0sOSeu2UcZwBaU3ihpN)IkfQX0luidk)rjCrVrsjW5LH3vqBQf2eLukbMEHczuBPec(2iFDkbdlaab1GOPr(MVXzaKmTPDXxO8pzOSoOSeukIqXIZuZqVTo8KnyOWR0C86BAOeUO3iPeGOPr(MVHP57xK2ulS5usPey6fkKrTLsi4BJ81PeTRWS1faCtV5BycoA0y6fkKbLLGsZmQuJ25pSn6caUP38nmbhnqPDKHYJGYsqjdlaab1GOPr(MVXzaKmTPDXxO8pzOSokHl6nskbiAAKV5ByA((fPn1I6khLukbMEHczuBPec(2iFDkrbaiO2aWyyoyrC1C0fnuwck5ajQzi4k2gkTJmusckHl6nskbd926qeRI2ulQRokPucm9cfYO2sje8Tr(6uIcaqqTbGXWCWI4Q5OlAOSeuwpu(bkfrOyXzQna3BKJNZFrLc1C86BAGY)qPLqzjOSDfMT2aCVroEo)fvkuJPxOqgu(dkRvdkNXw)C(lQuO2f9onsjCrVrsjyO3whIyv0MArDhrjLsGPxOqg1wkHGVnYxNsWbYvmMJtKRzi4k2gk)dL1rcOSeu(bkfrOyXzQ95q4QQzdQ54130aL2bLwcL1QbLmSaaeudIMg5B(gNbqY0M2fFHs7GssaL)GYsqz9q5hOueHIfNP2aCVroEo)fvkuZXRVPbk)dLwcLLGY2vy2AdW9g5458xuPqnMEHczq5pkHl6nskbd926qeRI2ulQBQusPey6fkKrTLsi4BJ81PeFGYpqjdlaab1GOPr(MVXzaKmnWmuwckfrOyXzQ95q4QQzdQ54130aL2bLwcL)GYA1GsgwaacQbrtJ8nFJZaizAt7IVqPDqjjGYFqzjOueHIfNP253QraoAR4GHotZXRVPbkTdkTKs4IEJKsyeba)HdtZ3ViTPwuhjOKsjW0luiJAlLqW3g5Rtj(aLFGsgwaacQbrtJ8nFJZaizAGzOSeukIqXIZu7ZHWvvZguZXRVPbkTdkTek)bL1QbLmSaaeudIMg5B(gNbqY0M2fFHs7GssaL)GYsqPicflotTZVvJaC0wXbdDMMJxFtduAhuAjLWf9gjLqO8ZnFdJvNfNgAtTOolPKsjW0luiJAlLqW3g5Rtj4a5kgZXjY1meCfBdL)HYJkhuwckRhk)aLIiuS4m1gG7nYXZ5VOsHAoE9nnq5FO0sOSeu2UcZwBaU3ihpN)IkfQX0luidk)rjCrVrsjyO3whIyv0MArDLhLukbMEHczuBPec(2iFDkXhO8du(bk)aLmSaaeudIMg5B(gNbqY0M2fFHY)qjjGYsqz9qzbaiOgiTgQQbihtBOsdmdL)GYA1GsgwaacQbrtJ8nFJZaizAt7IVq5FOCQq5pOSeukIqXIZu7ZHWvvZguZXRVPbk)dLtfk)bL1QbLmSaaeudIMg5B(gNbqY0M2fFHY)qzDq5pOSeukIqXIZu78B1iahTvCWqNP54130aL2bLwsjCrVrsjartJ8nFdtZ3ViTPwuhjNskLatVqHmQTucbFBKVoLOEO8dukIqXIZuBaU3ihpN)IkfQ54130aL)HslHYsqz7kmBTb4EJC8C(lQuOgtVqHmO8hLWf9gjLGHEBDiIvrBAtBkX0i3SrsT4OYvNnvos(r2KUoBE5SKsC68CZNHsCCZgpLwqYAXXfscucLKAfHY9oh8gkbdousYWqqhq1KmqjhpUcSCKbLM4IqPd0X1BKbLcRE(qJgoXM5MiuwhjbkTrPbyEo4nYGsx0BKqjjJd0XW72fFjz0WjWjKS35G3idkTekDrVrcLQ10gnCcLWbARbNsqSxaL3BKK0ChSPeZ8aCviL4yqPnkTgQkO84GEBfkNc5(S2WjhdkT29SHKC4WBBRafArCpy2lGY7nsb3b7dM9kouOIIdfGE5ZWPpmZdWvHMdhphNsFzMdh)uoooO3whtHCFw7HnkTgQkTzVc4KJbL2yGhGPHYPwUYGYJkxD2euw(qPnNKuUYbLh)ueobo5yqjjTvpFOHKaNCmOS8HsBmJHmOCkUjdkjPYr0gqnCYXGYYhkNs8gtJmOCANVEHc1ZrO28nad(458xuPqO0tguEJPrgukIKT9gPbk3SdOeDHvOKJkV3PrO0lw12vq5NoGsROAgkp32ku6mwKqzV3nFMFA4e4KJbL2SKuqbqJmOSabdocLI4w4nuwGVnnAO0gle4CBGYmYY3QZVGakO0f9gPbkJuvPHtCrVrA0ZCue3cVjdQCZx4ex0BKg9mhfXTWB7jFamcgCIl6nsJEMJI4w4T9Kp4aVlMT3BKWjhdkjsF2ynAOK7ldklaabrguAAVnqzbcgCekfXTWBOSaFBAGspzq5mhl)5O7nFq5AGswKOgoXf9gPrpZrrCl82EYhmPpBSg9W0EBGtCrVrA0ZCue3cVTN8H5O3iHtCrVrA0ZCue3cVTN8bUVgCWqNbN4IEJ0ON5OiUfEBp5do)wncWrBfhm0zLXqLxr(i4e4KJbL2SKuqbqJmOeNg5vqzVxekBRiu6Io4q5AGsFAFvEHc1WjUO3inKDGogE3U4lCIl6nsJ9KpC3Kna5iAdiCYXGYP0fRRmLbLKSnEnLbLEYGYOTICOmEcMboXf9gPXEYhCUWtC0bNJzx2csMdKRymhNixZqWvSTDLNLL(mJT(58xuPqTl6DASwT6BxHzRna3BKJNZFrLc1y6fkK9RehirndbxX22r2s4ex0BKg7jFOqfbBacWRkBbjpJT(58xuPqTl6DASwT6BxHzRna3BKJNZFrLc1y6fkKbN4IEJ0yp5dfi3G8VB(kBbjpJT(58xuPqTl6DASwT6BxHzRna3BKJNZFrLc1y6fkKbNCmOKKgW0XfkB(MFX2aLag)HWjUO3in2t(aGbhBJxdCIl6nsJ9KpayWX24TS0Vi5IQxK4OaXHRUE6IYwqYIiuS4m1gG7nYXZ5VOsHAoE9nn2vELRwT6BxHzRna3BKJNZFrLc1y6fkKbN4IEJ0yp5dagCSnEll9ls2MbAgwJtfYlBbjpJT(58xuPqTl6DASwT6BxHzRna3BKJNZFrLc1y6fkKbN4IEJ0yp5dagCSnEll9ls(5ku4kfYnJc0)w2csEgB9Z5VOsHAx070yTA13UcZwBaU3ihpN)IkfQX0luidoXf9gPXEYhMJEJSSfKSicflotTZVvJaC0wXbdDMMJoRQwTzS1pN)IkfQDrVtJ1QvaacQbsRHQAaYX0gQ0aZWjhdkNI(MTVjuECF5akmBO84v(daHtCrVrASN8HaOl4O)TS25pShli5pSO1tVCafM9yw5pau3R47O3lo44130yFVIVJEV4FYSO1tVCafM9yw5pauZXRVP5xjw06PxoGcZEmR8haQ541308N8tWGtCrVrASN8bHRudx0BKd1A6Ys)IKfrOyXzAGtCrVrASN8boqoCrVrouRPll9ls2dSSfKSl6DACGjEx0yh5JGtCrVrASN8bHRudx0BKd1A6Ys)IKFyI8vaNaNCmO0gh2SqjpAV3iHtCrVrA0EGKzO3whEYgmu4vLTGKfrOyXzQ95q4QQzdQ54130aN4IEJ0O9aTN8bgcUkeoXf9gPr7bAp5d48YW7kkBbjZqVTo8KnyOWR09k(U5RehiX)hvQ(pIiuS4m1gG7nYXZ5VOsHAoE9nn)TSu7kmBTb4EJC8C(lQuOgtVqHSFWjUO3inApq7jFGHEBDiIvv2csMHEBD4jBWqHxP7v8DZxjoqI)pQu9FerOyXzQna3BKJNZFrLc1C86BA(BzP2vy2AdW9g5458xuPqnMEHcz)GtCrVrA0EG2t(Grea8homnF)ILTGKzO3whEYgmu4v6EfF38vseHIfNP2NdHRQMnOMJxFtdCIl6nsJ2d0EYhek)CZ3Wy1zXPPSfKmd926Wt2GHcVs3R47MVsIiuS4m1(CiCv1Sb1C86BAGtCrVrA0EG2t(aoVm8UIYwqY1)reHIfNP2aCVroEo)fvkuZXRVP5VLLAxHzRna3BKJNZFrLc1y6fkK9doXf9gPr7bAp5dGOPr(MVHP57xSS25pShlizgwaacQbrtJ8nFJZaizAt7IV)jxxjrekwCMAg6T1HNSbdfELMJxFtdCIl6nsJ2d0EYhartJ8nFdtZ3Vyzli52vy26caUP38nmbhnAm9cfYkzMrLA0o)HTrxaWn9MVHj4OXoYhvIHfaGGAq00iFZ34masM20U47FY1bN4IEJ0O9aTN8bg6T1Hiwvzli5caqqTbGXWCWI4Q5Ol6sCGe1meCfBBhzsaN4IEJ0O9aTN8bg6T1Hiwvzli5caqqTbGXWCWI4Q5Ol6s1)reHIfNP2aCVroEo)fvkuZXRVP5VLLAxHzRna3BKJNZFrLc1y6fkK9RwTzS1pN)IkfQDrVtJWjUO3inApq7jFGHEBDiIvv2csMdKRymhNixZqWvS9)6irPpIiuS4m1(CiCv1Sb1C86BASZYA1yybaiOgennY38nodGKPnTl(Ahj(vQ(pIiuS4m1gG7nYXZ5VOsHAoE9nn)TSu7kmBTb4EJC8C(lQuOgtVqHSFWjUO3inApq7jFWica(dhMMVFXYwqYF(WWcaqqniAAKV5BCgajtdmxseHIfNP2NdHRQMnOMJxFtJDw(RwngwaacQbrtJ8nFJZaizAt7IV2rIFLerOyXzQD(TAeGJ2koyOZ0C86BASZs4ex0BKgThO9Kpiu(5MVHXQZIttzli5pFyybaiOgennY38nodGKPbMljIqXIZu7ZHWvvZguZXRVPXol)vRgdlaab1GOPr(MVXzaKmTPDXx7iXVsIiuS4m1o)wncWrBfhm0zAoE9nn2zjCIl6nsJ2d0EYhyO3whIyvLTGK5a5kgZXjY1meCfB))OYvQ(pIiuS4m1gG7nYXZ5VOsHAoE9nn)TSu7kmBTb4EJC8C(lQuOgtVqHSFWjUO3inApq7jFaennY38nmnF)ILTGK)85ZhgwaacQbrtJ8nFJZaizAt7IV)jrP6laab1aP1qvna5yAdvAG5F1QXWcaqqniAAKV5BCgajtBAx89)u)vseHIfNP2NdHRQMnOMJxFtZ)P(RwngwaacQbrtJ8nFJZaizAt7IV)R7xjrekwCMANFRgb4OTIdg6mnhV(Mg7SeoXf9gPr7bAp5dm0BRdrSQYwqY1)reHIfNP2aCVroEo)fvkuZXRVP5VLLAxHzRna3BKJNZFrLc1y6fkK9doboXf9gPrlIqXIZ0q253QraoAR4GHodoXf9gPrlIqXIZ0yp5d(CiCv1SblBbjZWcaqqniAAKV5BCgajtBAx81oYKaoXf9gPrlIqXIZ0yp5dmN)D0CpnGb)69gjCIl6nsJweHIfNPXEYhma3BKJNZFrLclBbjZbYvmMJtKRzi4k2(FDKaoXf9gPrlIqXIZ0yp5daP1qvna5yAdvLTGKzybaiOgennY38nodGKPnTl((NeWjUO3inArekwCMg7jFaiTgQQbihtBOQSfKSl6DACGjEx0yh5Jk95Jicflotnd926Wt2GHcVsZXRVP5p5NGvQ(2vy2AgcUkuJPxOq2VA1(iIqXIZuZqWvHAoE9nn)j)eSsTRWS1meCvOgtVqHSF)GtCrVrA0IiuS4mn2t(Gjaudo6ZiVS25pShli5pTZFyR79IJogSf)Bt1QXbs8p5J(vQ(caqqnqAnuvdqoM2qLgygoXf9gPrlIqXIZ0yp5daP1qvnku7ZAdNaN4IEJ0OFyI8vqMHEBDiIvv2csUaaeuBaymmhSiUAo6IUu9FerOyXzQna3BKJNZFrLc1C86BA(BzP2vy2AdW9g5458xuPqnMEHcz)QvBgB9Z5VOsHAx070iCIl6nsJ(HjYxH9KpWqVToeXQkBbjZbYvmMJtKRzi4k2(FDKO0hrekwCMAFoeUQA2GAoE9nn2zzTAmSaaeudIMg5B(gNbqY0M2fFTJe)kv)hrekwCMAdW9g5458xuPqnhV(MM)wwQDfMT2aCVroEo)fvkuJPxOq2p4ex0BKg9dtKVc7jFGHEBD4jBWqHxv2csUDfMTEgn9QWuGAm9cfYkjIqXIZu7ZHWvvZguZXRVPboXf9gPr)We5RWEYhyi4QWYwqYIiuS4m1(CiCv1Sb1C86BAGtCrVrA0pmr(kSN8bJia4pCyA((flBbj)5ddlaab1GOPr(MVXzaKmnWCjrekwCMAFoeUQA2GAoE9nn2z5VA1yybaiOgennY38nodGKPnTl(Ahj(vseHIfNP253QraoAR4GHotZXRVPXolHtCrVrA0pmr(kSN8bHYp38nmwDwCAkBbj)5ddlaab1GOPr(MVXzaKmnWCjrekwCMAFoeUQA2GAoE9nn2z5VA1yybaiOgennY38nodGKPnTl(Ahj(vseHIfNP253QraoAR4GHotZXRVPXolHtCrVrA0pmr(kSN8bg6T1HiwvzlizoqUIXCCICndbxX2)pQCLQ)JicflotTb4EJC8C(lQuOMJxFtZFll1UcZwBaU3ihpN)IkfQX0lui7hCIl6nsJ(HjYxH9KpaIMg5B(gMMVFXYwqYF(85ddlaab1GOPr(MVXzaKmTPDX3)KOu9faGGAG0AOQgGCmTHknW8VA1yybaiOgennY38nodGKPnTl((FQ)kjIqXIZu7ZHWvvZguZXRVP5)u)vRgdlaab1GOPr(MVXzaKmTPDX3)19RKicflotTZVvJaC0wXbdDMMJxFtJDwcN4IEJ0OFyI8vyp5dm0BRdrSQYwqY1)reHIfNP2aCVroEo)fvkuZXRVP5VLLAxHzRna3BKJNZFrLc1y6fkK9J20Msb]] )

end
