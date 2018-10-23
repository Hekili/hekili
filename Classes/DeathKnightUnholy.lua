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

    spec:RegisterPack( "Unholy", 20181021.2013, [[dCuxXaqifspsLK2Kc1OejoLiPxrQywKkDlsv0Ui5xQedtHOJHOAzkQ8mePmnvsDnfvTnvs4BKQKghPkCofcSoePQ5rQQ7Hq7Jq6GisKfsiEiPkLjQqixKuLWgrKOCsfcYkvuEPkjYnviu7er5NkeudfrclfrQ8uvzQQuDvsvQ2kIev7f4VIAWu1HPSys5XOmzuDzOnRIpRQgnH60sTAsvIETkLzt0TfXUL8BHHRGLd65uz6kDDc2oI47iy8QKOoVISEejnFrQ9J0aYb3bpUTiGS5gj56b5JCoYvZnsYNBE9a82Pbe8gm2n7JGxzji4P3lXHCc8gSjzyCWDWZfcqgcEI3DWr6VCbAeu)EflOj4qilQfRvXIKlUorqABhfdAN9IRtyx0oMEYrsUmaJtlr3fsbejDwZDxifKU8icTvC(kv9x8M17L4qoPCDcd80eA5ocvanWJBlciBUrsUEq(iNJC1CJK85iFeaEUbKbiBU5Nd8e3CowanWJJog4DvQxVxId5e1pIqBft9xPQ)Ix6SRs9I3DWr6VC53RybnflsU46ebPTDumOD2lUoHDrtgAx0oMEYrsUmaJtlr3fsbejDwZDxifKU8icTvC(kv9x8M17L4qoPCDcJo7Qu)imBdnes9ZrUUu)CJKC9G61tQxpi9Kto1tkgX0z0zxL61BIT6JospD2vPE9K6jL4CKt9J4U4upPmiIKkQOZUk1RNuVElksq4ICQFn4h3CFOEwu8E7OCu)gupe)csds9SO492r5uGNSDRdCh8(yHWMbUdiJCWDWdlttICGiGhd2lcBd80eohLtGZXkZJirbrJTu)yQFuQNed2MMevdri76Npbm)n4pMKi1Non1pGR6BWFmjrLX2Mee8m22rbEC0wXzw0sWciBoWDWdlttICGiGhd2lcBd8GcvZYdbbeQ44Pz9s96t9KFn1pM6tH6zri5bHszdbZKtdoubXeRlh1lk1pp1Non1ZrnHZrDq3IWU(zcHqXvU1y3OErP(RP(uP(Xu)OupjgSnnjQgIq21pFcy(BWFmjrWZyBhf4XrBfNzrlblGmsdCh8WY0Kihic4XG9IW2aV1KyTQb0TTelgQWY0KiN6ht9SiK8GqPSHGzYPbhQGyI1Ld8m22rbEC0wXzR4zoYSjWci7AWDWdlttICGiGhd2lcBd8yri5bHszdbZKtdoubXeRlh4zSTJc844PLiybKnp4o4HLPjroqeWJb7fHTbEPq9Pq9Cut4Cuh0TiSRFMqiuCLWa1pM6zri5bHszdbZKtdoubXeRlh1lk1pp1Nk1Non1ZrnHZrDq3IWU(zcHqXvU1y3OErP(RP(uP(XuplcjpiukdMmLJtEfJzoACfetSUCuVOu)8GNX2okWZXcb4hZUf23qWci7ka3bpSmnjYbIaEmyViSnWlfQpfQNJAcNJ6GUfHD9ZecHIRegO(XuplcjpiukBiyMCAWHkiMyD5OErP(5P(uP(0PPEoQjCoQd6we21ptiekUYTg7g1lk1Fn1Nk1pM6zri5bHszWKPCCYRymZrJRGyI1LJ6fL6Nh8m22rbEmPrORF2j24bbhybKPxb3bpSmnjYbIaEmyViSnWdkunlpeeqOIJNM1l1Rp1p3iP(Xu)OupjgSnnjQgIq21pFcy(BWFmjrWZyBhf4XrBfNzrlblGm9aCh8WY0Kihic4XG9IW2aVuO(uO(uO(uOEoQjCoQd6we21ptiekUYTg7g1Rp1Fn1pM6hL61eohLqjoKt5delsDsjmq9Ps9Ptt9Cut4Cuh0TiSRFMqiuCLBn2nQxFQN0O(uP(XuplcjpiukBiyMCAWHkiMyD5OE9PEsJ6tL6tNM65OMW5OoOBryx)mHqO4k3ASBuV(up5uFQu)yQNfHKhekLbtMYXjVIXmhnUcIjwxoQxuQFEWZyBhf4Dq3IWU(z3c7BiybKnca3bpSmnjYbIaEmyViSnWBuQNed2MMevdri76Npbm)n4pMKi4zSTJc84OTIZSOLGfSGhhpMGCb3bKro4o4zSTJc8s6INpqejve8WY0KihicybKnh4o4HLPjroqeWJetkGGhlcjpiukNqssu5Vb)XKevqmX6Yr96t9Zt9JP(1KyTkNqssu5Vb)XKevyzAsKdEgB7OapsmyBAse8iXG5YsqWBiczx)8jG5Vb)XKeblGmsdCh8WY0Kihic4XG9IW2apOq1S8qqaHkoEAwVuVOu)vmp1pM6tH6zri5bHs5essIk)n4pMKOcIjwxoQpDAQFuQFnjwRYjKKev(BWFmjrfwMMe5uFQu)yQhkuOIJNM1l1lkrQFEWZyBhf4zqMvyEdieRfSaYUgCh8WY0Kihic4XG9IW2aVbCvFd(JjjQm22KGuF60u)Ou)AsSwLtijjQ83G)ysIkSmnjYbpJTDuGNMmcE(iaNalGS5b3bpSmnjYbIaEmyViSnWBax13G)ysIkJTnji1Non1pk1VMeRv5essIk)n4pMKOclttICWZyBhf4PHqhcV11hSaYUcWDWZyBhf4j4WCVyId8WY0KihicybKPxb3bpSmnjYbIaEgB7OapTPFuywdXSjtSYyGhd2lcBd8yri5bHs5essIk)n4pMKOcIjwxoQxuQ)kgj1Non1pk1VMeRv5essIk)n4pMKOclttICWRSee80M(rHzneZMmXkJbwaz6b4o4HLPjroqeWZyBhf4PxIUS4GGeHGhd2lcBd8gWv9n4pMKOYyBtcs9Ptt9Js9RjXAvoHKKOYFd(JjjQWY0Kih8klbbp9s0LfheKieSaYgbG7GhwMMe5arapJTDuG33KiZKse6YAODd8yWEryBG3aUQVb)XKevgBBsqQpDAQFuQFnjwRYjKKev(BWFmjrfwMMe5Gxzji49njYmPeHUSgA3alGmYhj4o4HLPjroqeWJb7fHTbESiK8GqPmyYuoo5vmM5OXvq04tuF60u)aUQVb)XKevgBBsqQpDAQxt4CucL4qoLpqSi1jLWa4zSTJc8gITJcSaYiNCWDWdlttICGiGhd2lcBd8sH65XQiPHcsS28G0(cOAB2T82jygIjwxoQxhQFB2T82ji1RprQNhRIKgkiXAZds7lGkiMyD5O(uP(XuppwfjnuqI1MhK2xavqmX6Yr96tK6)mo4zSTJc8cHvdI2nWciJ85a3bpSmnjYbIaEgB7OapMjLzJTDuzz7wWt2UnxwccESiK8Gq5alGmYjnWDWdlttICGiGhd2lcBd8m22KGzSWKgDuVOeP(5apJTDuGhuOYgB7OYY2TGNSDBUSee8SablGmYVgCh8WY0Kihic4zSTJc8yMuMn22rLLTBbpz72Czji49XcHndSGf8gGils0SfChqg5G7GhwMMe5aralGS5a3bpSmnjYbIawazKg4o4HLPjroqeWci7AWDWdlttICGiGfq28G7GNX2okWBi2okWdlttICGiGfq2vaUdEgB7OapO1omZrJdEyzAsKdebSaY0RG7GhwMMe5arapokTjWBoWZyBhf4zWKPCCYRymZrJdwWcESiK8Gq5a3bKro4o4zSTJc8myYuoo5vmM5OXbpSmnjYbIawazZbUdEyzAsKdeb8yWEryBGhh1eoh1bDlc76Njecfx5wJDJ6fLi1Fn4zSTJc8SHGzYPbhcwazKg4o4zSTJc84g8wEHw5obmX2okWdlttICGiGfq21G7GhwMMe5arapgSxe2g4bfQMLhcciuXXtZ6L61N6j)AWZyBhf45essIk)n4pMKiybKnp4o4HLPjroqeWJb7fHTbECut4Cuh0TiSRFMqiuCLBn2nQxFQ)AWZyBhf4juId5u(aXIuNalGSRaCh8WY0Kihic4XG9IW2apJTnjyglmPrh1lkrQFoQFm1Nc1Nc1ZIqYdcLIJ2koBfpZrMnPGyI1LJ61Ni1)zCQFm1pk1VMeRvXXtlrfwMMe5uFQuF60uFkuplcjpiukoEAjQGyI1LJ61Ni1)zCQFm1VMeRvXXtlrfwMMe5uFQuFQGNX2okWtOehYP8bIfPobwaz6vWDWdlttICGiGhd2lcBd8wd(XvTDcM3iZBK61N61dQFm1Vg8JRA7emVrM3i1lk1Fn4zSTJc8CHGmdrBaHGfqMEaUdEyzAsKdeb8yWEryBGxku)Oup0AEgjbRvzCUtHx52ToQpDAQhAnpJKG1Qmo3P6I6fL6NBKuFQu)yQhkui1RprQpfQNCQxpPEnHZrjuId5u(aXIuNucduFQGNX2okWZfcYmeTbecwazJaWDWZyBhf4juId5uwt2FXl4HLPjroqeWcwWZceChqg5G7GhwMMe5arapgSxe2g4XIqYdcLYgcMjNgCOcIjwxoWZyBhf4XrBfNTIN5iZMalGS5a3bpJTDuGhhpTebpSmnjYbIawazKg4o4HLPjroqeWJb7fHTbEC0wXzR4zoYSj12SBD9P(XupuOqQxFQFoQFm1pk1tIbBttIQHiKD9ZNaM)g8htse8m22rbE4qZXKMbwazxdUdEyzAsKdeb8yWEryBGhhTvC2kEMJmBsTn7wxFQFm1dfkK61N6NJ6ht9Js9KyW20KOAiczx)8jG5Vb)XKebpJTDuGhhTvCMfTeSaYMhCh8WY0Kihic4XG9IW2apoAR4Sv8mhz2KAB2TU(u)yQNfHKhekLnemton4qfetSUCGNX2okWZXcb4hZUf23qWci7ka3bpSmnjYbIaEmyViSnWJJ2koBfpZrMnP2MDRRp1pM6zri5bHszdbZKtdoubXeRlh4zSTJc8ysJqx)StSXdcoWcitVcUdEyzAsKdeb8yWEryBG3OupjgSnnjQgIq21pFcy(BWFmjrWZyBhf4HdnhtAgybKPhG7GhwMMe5arapgSxe2g4XrnHZrDq3IWU(zcHqXvU1y3OE9js9Kt9JPEwesEqOuC0wXzR4zoYSjfetSUCGNX2okW7GUfHD9ZUf23qWciBeaUdEyzAsKdeb8yWEryBG3AsSwLMa0TD9ZUaIofwMMe5u)yQ3nGszEn4hxNsta62U(zxarh1lkrQFoQFm1ZrnHZrDq3IWU(zcHqXvU1y3OE9js9KdEgB7OaVd6we21p7wyFdblGmYhj4o4HLPjroqeWJb7fHTbEAcNJYjW5yL5rKOGOXwQFm1dfkuXXtZ6L6fLi1Fn4zSTJc84OTIZSOLGfqg5KdUdEyzAsKdeb8yWEryBGNMW5OCcCowzEejkiASL6ht9Js9KyW20KOAiczx)8jG5Vb)XKeP(0PP(bCvFd(JjjQm22KGGNX2okWJJ2koZIwcwazKph4o4HLPjroqeWJb7fHTbEqHQz5HGacvC80SEPE9PEYVM6ht9Pq9SiK8GqPSHGzYPbhQGyI1LJ6fL6NN6tNM65OMW5OoOBryx)mHqO4k3ASBuVOu)1uFQu)yQFuQNed2MMevdri76Npbm)n4pMKi4zSTJc84OTIZSOLGfqg5Kg4o4HLPjroqeWJb7fHTbEPq9Pq9Cut4Cuh0TiSRFMqiuCLWa1pM6zri5bHszdbZKtdoubXeRlh1lk1pp1Nk1Non1ZrnHZrDq3IWU(zcHqXvU1y3OErP(RP(uP(XuplcjpiukdMmLJtEfJzoACfetSUCuVOu)8GNX2okWZXcb4hZUf23qWciJ8Rb3bpSmnjYbIaEmyViSnWlfQpfQNJAcNJ6GUfHD9ZecHIRegO(XuplcjpiukBiyMCAWHkiMyD5OErP(5P(uP(0PPEoQjCoQd6we21ptiekUYTg7g1lk1Fn1Nk1pM6zri5bHszWKPCCYRymZrJRGyI1LJ6fL6Nh8m22rbEmPrORF2j24bbhybKr(8G7GhwMMe5arapgSxe2g4bfQMLhcciuXXtZ6L61N6NBKu)yQFuQNed2MMevdri76Npbm)n4pMKi4zSTJc84OTIZSOLGfqg5xb4o4HLPjroqeWJb7fHTbEPq9Pq9Pq9Pq9Cut4Cuh0TiSRFMqiuCLBn2nQxFQ)AQFm1pk1RjCokHsCiNYhiwK6KsyG6tL6tNM65OMW5OoOBryx)mHqO4k3ASBuV(upPr9Ps9JPEwesEqOu2qWm50GdvqmX6Yr96t9Kg1Nk1Non1ZrnHZrDq3IWU(zcHqXvU1y3OE9PEYP(uP(XuplcjpiukdMmLJtEfJzoACfetSUCuVOu)8GNX2okW7GUfHD9ZUf23qWciJC9k4o4HLPjroqeWJb7fHTbEJs9KyW20KOAiczx)8jG5Vb)XKebpJTDuGhhTvCMfTeSGfSGhji01rbiBUrsUEmYraPnsf5ZDn4rWGvxFh4ncLmeWf5u)8uVX2okQx2U1POZaptyfhqW71jcsB7O0Bq7SG3amoTebVRs969sCiNO(reARyQ)kv9x8sNDvQx8Udos)Ll)EflOPyrYfxNiiTTJIbTZEX1jSlAYq7I2X0tosYLbyCAj6UqkGiPZAU7cPG0LhrOTIZxPQ)I3SEVehYjLRty0zxL6hHzBOHqQFoY1L6NBKKRhuVEs96bPNCYPEsXiMoJo7QuVEtSvF0r6PZUk1RNupPeNJCQFe3fN6jLbrKurfD2vPE9K61BrrccxKt9Rb)4M7d1ZII3BhLJ63G6H4xqAqQNffV3okNIoJo7QuVEXvgzclYPEn8eqK6zrIMTuVg(7YPOEsjgdhwh1xrPNInyYrqs9gB7OCuFuYjfDMX2okNAaISirZwIhP5UrNzSTJYPgGils0SvhIxorWPZm22r5udqKfjA2QdXlMWpbR12ok6SRs9VYgCIJL6HwZPEnHZb5uVBT1r9A4jGi1ZIenBPEn83LJ6TIt9dquphID76t9TJ65rHk6mJTDuo1aezrIMT6q8IRSbN4yZU1whDMX2okNAaISirZwDiEzi2ok6mJTDuo1aezrIMT6q8c0AhM5OXPZm22r5udqKfjA2QdXlgmzkhN8kgZC046YrPnrCo6m6SRs96fxzKjSiN6rsq4e1VDcs9RyK6n2gqQVDuVrI1sttIk6mJTDuoIjDXZhiIKksNzSTJYPdXlKyW20KOULLGehIq21pFcy(BWFmjrDjXKcirwesEqOuoHKKOYFd(JjjQGyI1Lt)5hVMeRv5essIk)n4pMKOclttIC6SRs9KoJ1M0Pl1pcTyItxQ3ko1hRyes9XNXD0zgB7OC6q8IbzwH5nGqSwD7drOq1S8qqaHkoEAwVIEfZpofwesEqOuoHKKOYFd(JjjQGyI1LlD6rxtI1QCcjjrL)g8htsuHLPjrEQJHcfQ44Pz9kkX5PZm22r50H4fnze88raoPBFioGR6BWFmjrLX2MemD6rxtI1QCcjjrL)g8htsuHLPjroDMX2okNoeVOHqhcV11x3(qCax13G)ysIkJTnjy60JUMeRv5essIk)n4pMKOclttIC6SRs96nb3gju)c76gUoQxWzFKoZyBhLthIxeCyUxmXrNzSTJYPdXlcom3lMOBzjirTPFuywdXSjtSYy62hISiK8GqPCcjjrL)g8htsubXeRlNOxXitNE01KyTkNqssu5Vb)XKevyzAsKtNzSTJYPdXlcom3lMOBzjir9s0LfheKiu3(qCax13G)ysIkJTnjy60JUMeRv5essIk)n4pMKOclttIC6mJTDuoDiErWH5EXeDllbj(njYmPeHUSgA30TpehWv9n4pMKOYyBtcMo9ORjXAvoHKKOYFd(JjjQWY0KiNoZyBhLthIxgITJs3(qKfHKhekLbtMYXjVIXmhnUcIgFkD6bCvFd(JjjQm22KGPtRjCokHsCiNYhiwK6KsyGo7Qu)i26ATUOEs5nuqI1s9KcP9fq6mJTDuoDiEjewniA30TpetHhRIKgkiXAZds7lGQTz3YBNGziMyD50zB2T82jO(e5XQiPHcsS28G0(cOcIjwxUuhZJvrsdfKyT5bP9fqfetSUC6t8Z40zgB7OC6q8cZKYSX2oQSSDRULLGezri5bHYrNzSTJYPdXlqHkBSTJklB3QBzjirlqD7drJTnjyglmPrNOeNJoZyBhLthIxyMuMn22rLLTB1TSeK4hle2m6m6SRs9KsHEb1dJ12ok6mJTDuoLfiroAR4Sv8mhz2KU9HilcjpiukBiyMCAWHkiMyD5OZm22r5uwG6q8chpTePZm22r5uwG6q8co0CmPz62hIC0wXzR4zoYSj12SBD9hdfku)5gpkjgSnnjQgIq21pFcy(BWFmjr6mJTDuoLfOoeVWrBfNzrl1Tpe5OTIZwXZCKztQTz366pgkuO(ZnEusmyBAsuneHSRF(eW83G)ysI0zgB7OCklqDiEXXcb4hZUf23qD7droAR4Sv8mhz2KAB2TU(Jzri5bHszdbZKtdoubXeRlhDMX2okNYcuhIxysJqx)StSXdcoD7droAR4Sv8mhz2KAB2TU(Jzri5bHszdbZKtdoubXeRlhDMX2okNYcuhIxWHMJjnt3(qCusmyBAsuneHSRF(eW83G)ysI0zgB7OCklqDiE5GUfHD9ZUf23qD7droQjCoQd6we21ptiekUYTg7M(ejFmlcjpiukoAR4Sv8mhz2KcIjwxo6mJTDuoLfOoeVCq3IWU(z3c7BOU9H4AsSwLMa0TD9ZUaIofwMMe5JDdOuMxd(X1P0eGUTRF2fq0jkX5gZrnHZrDq3IWU(zcHqXvU1y30Ni50zgB7OCklqDiEHJ2koZIwQBFiQjCokNaNJvMhrIcIgBhdfkuXXtZ6vuIxtNzSTJYPSa1H4foAR4mlAPU9HOMW5OCcCowzEejkiASD8OKyW20KOAiczx)8jG5Vb)XKetNEax13G)ysIkJTnjiDMX2okNYcuhIx4OTIZSOL62hIqHQz5HGacvC80SE1N8RhNclcjpiukBiyMCAWHkiMyD5eD(0P5OMW5OoOBryx)mHqO4k3ASBIEDQJhLed2MMevdri76Npbm)n4pMKiDMX2okNYcuhIxCSqa(XSBH9nu3(qmLu4OMW5OoOBryx)mHqO4kHHXSiK8GqPSHGzYPbhQGyI1Lt05tnDAoQjCoQd6we21ptiekUYTg7MOxN6ywesEqOugmzkhN8kgZC04kiMyD5eDE6mJTDuoLfOoeVWKgHU(zNyJheC62hIPKch1eoh1bDlc76NjecfxjmmMfHKhekLnemton4qfetSUCIoFQPtZrnHZrDq3IWU(zcHqXvU1y3e96uhZIqYdcLYGjt54KxXyMJgxbXeRlNOZtNzSTJYPSa1H4foAR4mlAPU9HiuOAwEiiGqfhpnRx9NBKJhLed2MMevdri76Npbm)n4pMKiDMX2okNYcuhIxoOBryx)SBH9nu3(qmLusjfoQjCoQd6we21ptiekUYTg7M(xpEunHZrjuId5u(aXIuNucdPMonh1eoh1bDlc76Njecfx5wJDtFsl1XSiK8GqPSHGzYPbhQGyI1LtFsl10P5OMW5OoOBryx)mHqO4k3ASB6tEQJzri5bHszWKPCCYRymZrJRGyI1Lt05PZm22r5uwG6q8chTvCMfTu3(qCusmyBAsuneHSRF(eW83G)ysI0z0zgB7OCkwesEqOCenyYuoo5vmM5OXPZm22r5uSiK8Gq50H4fBiyMCAWH62hICut4Cuh0TiSRFMqiuCLBn2nrjEnDMX2okNIfHKhekNoeVWn4T8cTYDcyITDu0zgB7OCkwesEqOC6q8ItijjQ83G)ysI62hIqHQz5HGacvC80SE1N8RPZm22r5uSiK8Gq50H4fHsCiNYhiwK6KU9Hih1eoh1bDlc76Njecfx5wJDt)RPZm22r5uSiK8Gq50H4fHsCiNYhiwK6KU9HOX2MemJfM0OtuIZnoLuyri5bHsXrBfNTIN5iZMuqmX6YPpXpJpE01KyTkoEAjQWY0Kip10PtHfHKhekfhpTevqmX6YPpXpJpEnjwRIJNwIkSmnjYtnv6mJTDuoflcjpiuoDiEXfcYmeTbeQBFiUg8JRA7emVrM3O(6X41GFCvBNG5nY8gf9A6mJTDuoflcjpiuoDiEXfcYmeTbeQBFiMYOqR5zKeSwLX5ofELB36sNgAnpJKG1Qmo3P6s05gzQJHcfQpXuixp1eohLqjoKt5delsDsjmKkDMX2okNIfHKhekNoeViuId5uwt2FXlDgDMX2okN6JfcBgroAR4mlAPU9HOMW5OCcCowzEejkiASD8OKyW20KOAiczx)8jG5Vb)XKetNEax13G)ysIkJTnjiDMX2okN6JfcBMoeVWrBfNzrl1TpeHcvZYdbbeQ44Pz9Qp5xpofwesEqOu2qWm50GdvqmX6Yj68PtZrnHZrDq3IWU(zcHqXvU1y3e96uhpkjgSnnjQgIq21pFcy(BWFmjr6mJTDuo1hle2mDiEHJ2koBfpZrMnPBFiUMeRvnGUTLyXqfwMMe5Jzri5bHszdbZKtdoubXeRlhDMX2okN6JfcBMoeVWXtlrD7drwesEqOu2qWm50GdvqmX6YrNzSTJYP(yHWMPdXlowia)y2TW(gQBFiMskCut4Cuh0TiSRFMqiuCLWWywesEqOu2qWm50GdvqmX6Yj68PMonh1eoh1bDlc76Njecfx5wJDt0RtDmlcjpiukdMmLJtEfJzoACfetSUCIopDMX2okN6JfcBMoeVWKgHU(zNyJheC62hIPKch1eoh1bDlc76NjecfxjmmMfHKhekLnemton4qfetSUCIoFQPtZrnHZrDq3IWU(zcHqXvU1y3e96uhZIqYdcLYGjt54KxXyMJgxbXeRlNOZtNzSTJYP(yHWMPdXlC0wXzw0sD7drOq1S8qqaHkoEAwV6p3ihpkjgSnnjQgIq21pFcy(BWFmjr6mJTDuo1hle2mDiE5GUfHD9ZUf23qD7dXusjLu4OMW5OoOBryx)mHqO4k3ASB6F94r1eohLqjoKt5delsDsjmKA60Cut4Cuh0TiSRFMqiuCLBn2n9jTuhZIqYdcLYgcMjNgCOcIjwxo9jTutNMJAcNJ6GUfHD9ZecHIRCRXUPp5PoMfHKhekLbtMYXjVIXmhnUcIjwxorNNoZyBhLt9XcHnthIx4OTIZSOL62hIJsIbBttIQHiKD9ZNaM)g8htseSGfaa]] )

end
