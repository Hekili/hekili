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

    spec:RegisterPack( "Unholy", 20180928.2043, [[dy05VaqijHhPsfBssAucItrs1Rqv1SijULkPYUi1VujgMKsDmbPLjj6zQKY0KuCnvs2MKs8nsk04uPQoNkvY6iPiZJK09aP9HQYbLusTqqvpuLkLjssPCrskkBKKsQtssjzLsQEPKsYnjPuTtqPHQsQAPKuWtvLPckUkjLyRQuPQ9c8xHgmvDyklMepgPjt0LH2Sk(SQA0OkNwXQjPO61QuMnHBlWUL63IgUewoINtLPR01rLTdQ8DqmEvQu58s06vPkZxqTFugekagWtAlcGTYAh69R9Dv5DPRS21CTRvd4TLfi4vy0B2hbV2cqWtT08srj4vyLI0KayapxYrOi4XB3cNA6YfIbr)NLhNcNdj0SxSxnndU4MaoHTt2uID2lUjGEr5yxNeH7sbjpJaDxUEcQgSr6UC9QHOAdTLxSw1ZN3gvlnVuuQDtaf8u4gXQw1afWtAlcGTYAh69R9Dv5DPRS21CTkVp45kqka2kVQsWJ3iLyduapj6OG3DyE1sZlfLmVAdTLhZxR65ZBz1VdZZB3cNA6YL)S84u00m4IBc4e2oztj2zV4Ma6ffrQCr5yxNeH7sbjpJaDxUEcQgSr6UC9QHOAdTLxSw1ZN3gvlnVuuQDtaLv)om)dlwmqbjmFL3LkmFL1o07Z8xhZFF1unHY8xVANvNv)om)DJN1F0PMy1VdZFDmFTwkrjZR2NwY8Q1eeVhQbpX4whagW7JnsgkagaSHcGb8W2ueOeap4rjZIKXapfUZr74KsSJYmd0e0OlZxL5RG5HZiJPiqDrMIP)XtsIFJ8ZsbY8HdZ8f4Q)g5NLcuB0DGdbpJUt2GNeTLxKMJaSayRead4HTPiqjaEWJsMfjJbEeUEOXIecs0s8m0zzEvz(qRH5RY8HW80mfYesRTIKAIYchQjyGnTJ55J5VI5dhM5LOc35OpOBrY0)iKKRLA3A0BmpFmFnmV6mFvMVcMhoJmMIa1fzkM(hpjj(nYplfi4z0DYg8KOT8I0CeGfa71aWaEyBkcucGh8OKzrYyG3AcSxDb62rGnf1yBkcuY8vzEAMczcP1wrsnrzHd1emWM2bEgDNSbpjAlVO1YOePwjybWwdagWdBtrGsa8GhLmlsgd8OzkKjKwBfj1eLfoutWaBAh4z0DYg8K4zeiybWEfagWdBtrGsa8GhLmlsgd8cH5dH5LOc35OpOBrY0)iKKRLAUcMVkZtZuitiT2ksQjklCOMGb20oMNpM)kMxDMpCyMxIkCNJ(GUfjt)JqsUwQDRrVX88X81W8QZ8vzEAMczcP1gjOmMN4YdJs0KAcgyt7yE(y(RapJUt2GNJMCKpgDlzUHGfaBTaGb8W2ueOeap4rjZIKXaVqy(qyEjQWDo6d6wKm9pcj5APMRG5RY80mfYesRTIKAIYchQjyGnTJ55J5VI5vN5dhM5LOc35OpOBrY0)iKKRLA3A0BmpFmFnmV6mFvMNMPqMqATrckJ5jU8WOenPMGb20oMNpM)kWZO7Kn4rfgKP)rhptMqCGfaRAead4HTPiqjaEWJsMfjJbEeUEOXIecs0s8m0zzEvz(kRnZxL5RG5HZiJPiqDrMIP)XtsIFJ8ZsbcEgDNSbpjAlVinhbybWEFamGh2MIaLa4bpkzwKmg4fcZhcZhcZhcZlrfUZrFq3IKP)rijxl1U1O3yEvz(Ay(QmFfmVc35O5AEPOmEiyFVsnxbZRoZhomZlrfUZrFq3IKP)rijxl1U1O3yEvz(RX8QZ8vzEAMczcP1wrsnrzHd1emWM2X8QY8xJ5vN5dhM5LOc35OpOBrY0)iKKRLA3A0BmVQmFOmV6mFvMNMPqMqATrckJ5jU8WOenPMGb20oMNpM)kWZO7Kn4Dq3IKP)r3sMBiybWExayapSnfbkbWdEuYSizmWRcMhoJmMIa1fzkM(hpjj(nYplfi4z0DYg8KOT8I0CeGfSGNepgNybWaGnuamGNr3jBWlyAz8qq8Ei4HTPiqjaEWcGTsamGh2MIaLa4bp4mbhcE0mfYesRDCbbzh)g5NLcutWaBAhZRkZFfZxL5xtG9QDCbbzh)g5NLcuJTPiqj4z0DYg8GZiJPiqWdoJeBlabVImft)JNKe)g5NLceSayVgagWdBtrGsa8GhLmlsgd8iC9qJfjeKOL4zOZY88X81YvmFvMpeMVax93i)SuGAJUdCiZhomZxbZVMa7v74ccYo(nYplfOgBtrGsMxDMVkZt4AulXZqNL55dkZFf4z0DYg8mc1AmUjHG9cwaS1aGb8W2ueOeap4rjZIKXaVcC1FJ8ZsbQn6oWHmF4WmFfm)AcSxTJlii743i)SuGASnfbkbpJUt2GNIitz8Wrkbla2RaWaEyBkcucGh8OKzrYyGxbU6Vr(zPa1gDh4qMpCyMVcMFnb2R2XfeKD8BKFwkqn2MIaLGNr3jBWtbjoKCB6pybWwlayapJUt2GhNdJZIboWdBtrGsa8GfaRAead4HTPiqjaEWZO7Kn4Pu(ZgJkignrG1gf8OKzrYyGhntHmH0Ahxqq2XVr(zPa1emWM2X88X81sTz(WHz(ky(1eyVAhxqq2XVr(zPa1yBkcucETfGGNs5pBmQGy0ebwBuWcG9(ayapSnfbkbWdEgDNSbp1C0f5Lqeib8OKzrYyGxbU6Vr(zPa1gDh4qMpCyMVcMFnb2R2XfeKD8BKFwkqn2MIaLGxBbi4PMJUiVeIajGfa7DbGb8W2ueOeap4z0DYg8(MaPMqGexubTBGhLmlsgd8kWv)nYplfO2O7ahY8HdZ8vW8RjWE1oUGGSJFJ8ZsbQX2ueOe8AlabVVjqQjeiXfvq7gybWgATbWaEyBkcucGh8OKzrYyGhntHmH0AJeugZtC5HrjAsnbnzjZhomZxGR(BKFwkqTr3boK5dhM5v4ohnxZlfLXdb77vQ5kapJUt2GxrUt2GfaBOHcGb8W2ueOeap4rjZIKXaVqyEzUA4gcNa7nwiSphQ3HElUtagjyGnTJ55N53HElUtaY8QcL5L5QHBiCcS3yHW(COMGb20oMxDMVkZlZvd3q4eyVXcH95qnbdSPDmVQqz(pvcEgDNSbVKBviODdSaydTsamGh2MIaLa4bpJUt2Gh1eIOr3j7OyCl4jg3gBlabpAMczcPDGfaBOxdad4HTPiqjaEWJsMfjJbEgDh4Wi2yWGoMNpOmFLGNr3jBWJW1rJUt2rX4wWtmUn2wacEwIGfaBO1aGb8W2ueOeap4z0DYg8OMqen6ozhfJBbpX42yBbi49XgjdfSGf8kiinduSfada2qbWaEyBkcucGhSayRead4HTPiqjaEWcG9AayapSnfbkbWdwaS1aGb8W2ueOeapybWEfagWZO7Kn4vK7Kn4HTPiqjaEWcGTwaWaEgDNSbpInomkrtcEyBkcucGhSayvJayapSnfbkbWdEsuyLGxLGNr3jBWZibLX8exEyuIMeSGf8OzkKjK2bGbaBOayapJUt2GNrckJ5jU8WOenj4HTPiqjaEWcGTsamGh2MIaLa4bpkzwKmg4jrfUZrFq3IKP)rijxl1U1O3yE(GY81aEgDNSbpRiPMOSWHGfa71aWaEgDNSbpPrUfxI1UtscSDYg8W2ueOeapybWwdagWdBtrGsa8GhLmlsgd8iC9qJfjeKOL4zOZY8QY8Hwd4z0DYg8CCbbzh)g5NLceSayVcad4HTPiqjaEWJsMfjJbEsuH7C0h0Tiz6FesY1sTBn6nMxvMVgWZO7Kn4X18srz8qW(ELGfaBTaGb8W2ueOeap4rjZIKXapJUdCyeBmyqhZZhuMVsMVkZhcZhcZtZuitiTwI2YlATmkrQvQjyGnTJ5vfkZ)PsMVkZxbZVMa7vlXZiqn2MIaLmV6mF4WmFimpntHmH0AjEgbQjyGnTJ5vfkZ)PsMVkZVMa7vlXZiqn2MIaLmV6mV6GNr3jBWJR5LIY4HG99kblaw1iagWdBtrGsa8GhLmlsgd8cH5xJ8XvVtag3mkhK5vL5VpZhomZt4AK5vfkZxjZRoZxL5RG5v4ohnxZlfLXdb77vQ5kapJUt2GNl5ercAfibSayVpagWZO7Kn4X18srzurmFEl4HTPiqjaEWcwWZseada2qbWaEyBkcucGh8OKzrYyGhntHmH0ARiPMOSWHAcgyt7apJUt2GNeTLx0AzuIuReSayRead4z0DYg8K4zei4HTPiqjaEWcG9AayapSnfbkbWdEuYSizmWtI2YlATmkrQvQ3HEB6pZxL5jCnY8QY8vY8vz(kyE4mYykcuxKPy6F8KK43i)SuGGNr3jBWdlgjgmuWcGTgamGh2MIaLa4bpkzwKmg4jrB5fTwgLi1k17qVn9N5RY8eUgzEvz(kz(QmFfmpCgzmfbQlYum9pEss8BKFwkqWZO7Kn4jrB5fP5iala2RaWaEyBkcucGh8OKzrYyGNeTLx0AzuIuRuVd920FMVkZtZuitiT2ksQjklCOMGb20oWZO7Kn45Ojh5Jr3sMBiybWwlayapSnfbkbWdEuYSizmWtI2YlATmkrQvQ3HEB6pZxL5PzkKjKwBfj1eLfoutWaBAh4z0DYg8OcdY0)OJNjtioWcGvncGb8W2ueOeap4rjZIKXaVkyE4mYykcuxKPy6F8KK43i)SuGGNr3jBWdlgjgmuWcG9(ayapSnfbkbWdEuYSizmWtIkCNJ(GUfjt)JqsUwQDRrVX8QcL5dL5RY80mfYesRLOT8IwlJsKALAcgyt7apJUt2G3bDlsM(hDlzUHGfa7DbGb8W2ueOeap4rjZIKXaV1eyVAfoIBN(hDjbDASnfbkz(QmVRafI4AKpUoTchXTt)JUKGoMNpOmFLmFvMxIkCNJ(GUfjt)JqsUwQDRrVX8QcL5df8m6ozdEh0Tiz6F0TK5gcwaSHwBamGh2MIaLa4bpkzwKmg4PWDoAhNuIDuMzGMGgDz(QmpHRrTepdDwMNpOmFnGNr3jBWtI2YlsZrawaSHgkagWdBtrGsa8GhLmlsgd8u4ohTJtkXokZmqtqJUmFvMVcMhoJmMIa1fzkM(hpjj(nYplfiZhomZxGR(BKFwkqTr3boe8m6ozdEs0wErAocWcGn0kbWaEyBkcucGh8OKzrYyGhHRhASiHGeTepdDwMxvMp0Ay(QmFimpntHmH0ARiPMOSWHAcgyt7yE(y(Ry(WHzEjQWDo6d6wKm9pcj5AP2Tg9gZZhZxdZRoZxL5RG5HZiJPiqDrMIP)XtsIFJ8ZsbcEgDNSbpjAlVinhbybWg61aWaEyBkcucGh8OKzrYyGximFimVev4oh9bDlsM(hHKCTuZvW8vzEAMczcP1wrsnrzHd1emWM2X88X8xX8QZ8HdZ8suH7C0h0Tiz6FesY1sTBn6nMNpMVgMxDMVkZtZuitiT2ibLX8exEyuIMutWaBAhZZhZFf4z0DYg8C0KJ8XOBjZneSaydTgamGh2MIaLa4bpkzwKmg4fcZhcZlrfUZrFq3IKP)rijxl1CfmFvMNMPqMqATvKutuw4qnbdSPDmpFm)vmV6mF4WmVev4oh9bDlsM(hHKCTu7wJEJ55J5RH5vN5RY80mfYesRnsqzmpXLhgLOj1emWM2X88X8xbEgDNSbpQWGm9p64zYeIdSayd9kamGh2MIaLa4bpkzwKmg4r46HglsiirlXZqNL5vL5RS2mFvMVcMhoJmMIa1fzkM(hpjj(nYplfi4z0DYg8KOT8I0CeGfaBO1cagWdBtrGsa8GhLmlsgd8cH5dH5dH5dH5LOc35OpOBrY0)iKKRLA3A0BmVQmFnmFvMVcMxH7C0CnVuugpeSVxPMRG5vN5dhM5LOc35OpOBrY0)iKKRLA3A0BmVQm)1yE1z(QmpntHmH0ARiPMOSWHAcgyt7yEvz(RX8QZ8HdZ8suH7C0h0Tiz6FesY1sTBn6nMxvMpuMxDMVkZtZuitiT2ibLX8exEyuIMutWaBAhZZhZFf4z0DYg8oOBrY0)OBjZneSaydvncGb8W2ueOeap4rjZIKXaVkyE4mYykcuxKPy6F8KK43i)SuGGNr3jBWtI2YlsZrawWcwWdoK4MSbWwzTd9(1((xR26kdTs1i4bXi90Fh4PwfuKKfLm)vmVr3jBMxmU1Pz1bpJB5LeW7nbCcBNSVBe7SGxbjpJabV7W8QLMxkkzE1gAlpMVw1ZN3YQFhMN3Ufo10Ll)z5XPOPzWf3eWjSDYMsSZEXnb0lkIu5IYXUojc3LcsEgb6UC9eunyJ0D56vdr1gAlVyTQNpVnQwAEPOu7MakR(Dy(hwSyGcsy(kVlvy(kRDO3N5VoM)(QPAcL5VE1oRoR(Dy(7gpR)OtnXQFhM)6y(ATuIsMxTpTK5vRjiEpuZQZQFhMxn7UdPClkzEf8KeK5PzGITmVc(N2Pz(AnLIfRJ57SVoEgj4WjyEJUt2oMpBrPMv3O7KTtxqqAgOyl0JWC3y1n6oz70feKMbk2Yp0lNmLS6gDNSD6ccsZafB5h6fJ7hG9A7KnR(Dy(xBfoE5Y8eBKmVc35GsM3T26yEf8KeK5PzGITmVc(N2X8wlz(ccEDf5Ut)z(XX8YSrnRUr3jBNUGG0mqXw(HEX1wHJxUr3ARJv3O7KTtxqqAgOyl)qVuK7KnRUr3jBNUGG0mqXw(HEHyJdJs0KS6gDNSD6ccsZafB5h6fJeugZtC5HrjAsvKOWkHwjRoR(DyE1S7oKYTOK5r4qsjZVtaY8lpK5n6MeMFCmVbNnctrGAwDJUt2oObtlJhcI3dz1n6oz74h6f4mYykcuL2cqOfzkM(hpjj(nYplfOkWzcoekntHmH0Ahxqq2XVr(zPa1emWM2P6vvxtG9QDCbbzh)g5NLcuJTPiqjR(DyE1Grht4uH5vRwmWPcZBTK5ZLhsy(8tLowDJUt2o(HEXiuRX4Mec2RkZbkHRhASiHGeTepdDw(QLRQgsbU6Vr(zPa1gDh4WWHRynb2R2XfeKD8BKFwkqn2MIaLQxLW1OwINHolFqVIv3O7KTJFOxuezkJhosPkZbAbU6Vr(zPa1gDh4WWHRynb2R2XfeKD8BKFwkqn2MIaLS6gDNSD8d9IcsCi520FvMd0cC1FJ8ZsbQn6oWHHdxXAcSxTJlii743i)SuGASnfbkz1VdZF34CBgW8lz6B46yEoN9rwDJUt2o(HEHZHXzXahRUr3jBh)qVW5W4SyGkTfGqvk)zJrfeJMiWAJQYCGsZuitiT2XfeKD8BKFwkqnbdSPD8vl1oC4kwtG9QDCbbzh)g5NLcuJTPiqjRUr3jBh)qVW5W4SyGkTfGqvZrxKxcrGevMd0cC1FJ8ZsbQn6oWHHdxXAcSxTJlii743i)SuGASnfbkz1n6oz74h6fohgNfduPTae63ei1ecK4IkODtL5aTax93i)SuGAJUdCy4WvSMa7v74ccYo(nYplfOgBtrGswDJUt2o(HEPi3jBvMduAMczcP1gjOmMN4YdJs0KAcAYYWHlWv)nYplfO2O7ahgoSc35O5AEPOmEiyFVsnxbR(DyE1Un9AtZ839dHtG9Y8xVW(CiRUr3jBh)qVKCRcbTBQSg5JBCoqdrMRgUHWjWEJfc7ZH6DO3I7eGrcgyt74Fh6T4obOQqL5QHBiCcS3yHW(COMGb20o1RkZvd3q4eyVXcH95qnbdSPDQc9tLS6gDNSD8d9c1eIOr3j7OyCRkTfGqPzkKjK2XQB0DY2Xp0leUoA0DYokg3QsBbiulrvMduJUdCyeBmyqhFqRKv3O7KTJFOxOMqen6ozhfJBvPTae6hBKmuwDw97W816unJ5j5A7KnRUr3jBN2seQeTLx0AzuIuRuL5aLMPqMqATvKutuw4qnbdSPDS6gDNSDAlr(HErINrGS6gDNSDAlr(HEblgjgmuvMdujAlVO1YOePwPEh6TP)vjCnQALvRaoJmMIa1fzkM(hpjj(nYplfiRUr3jBN2sKFOxKOT8I0CeQmhOs0wErRLrjsTs9o0Bt)Rs4Au1kRwbCgzmfbQlYum9pEss8BKFwkqwDJUt2oTLi)qV4Ojh5Jr3sMBOkZbQeTLx0AzuIuRuVd920)Q0mfYesRTIKAIYchQjyGnTJv3O7KTtBjYp0luHbz6F0XZKjeNkZbQeTLx0AzuIuRuVd920)Q0mfYesRTIKAIYchQjyGnTJv3O7KTtBjYp0lyXiXGHQYCGwbCgzmfbQlYum9pEss8BKFwkqwDJUt2oTLi)qVCq3IKP)r3sMBOkRr(4gNdujQWDo6d6wKm9pcj5AP2Tg9MQqdTkntHmH0AjAlVO1YOePwPMGb20owDJUt2oTLi)qVCq3IKP)r3sMBOkZb6AcSxTchXTt)JUKGon2MIaLvDfOqexJ8X1Pv4iUD6F0Le0Xh0kRkrfUZrFq3IKP)rijxl1U1O3ufAOS6gDNSDAlr(HErI2YlsZrOYCGQWDoAhNuIDuMzGMGgDRs4AulXZqNLpO1WQB0DY2PTe5h6fjAlVinhHkZbQc35ODCsj2rzMbAcA0TAfWzKXueOUitX0)4jjXVr(zPadhUax93i)SuGAJUdCiRUr3jBN2sKFOxKOT8I0CeQmhOeUEOXIecs0s8m0zvn0AQgcntHmH0ARiPMOSWHAcgyt747QWHLOc35OpOBrY0)iKKRLA3A0B8vJ6vRaoJmMIa1fzkM(hpjj(nYplfiRUr3jBN2sKFOxC0KJ8XOBjZnuL5anKqKOc35OpOBrY0)iKKRLAUIQ0mfYesRTIKAIYchQjyGnTJVRupCyjQWDo6d6wKm9pcj5AP2Tg9gF1OEvAMczcP1gjOmMN4YdJs0KAcgyt747kwDJUt2oTLi)qVqfgKP)rhptMqCQmhOHeIev4oh9bDlsM(hHKCTuZvuLMPqMqATvKutuw4qnbdSPD8DL6HdlrfUZrFq3IKP)rijxl1U1O34Rg1RsZuitiT2ibLX8exEyuIMutWaBAhFxXQB0DY2PTe5h6fjAlVinhHkZbkHRhASiHGeTepdDwvRS2vRaoJmMIa1fzkM(hpjj(nYplfiRUr3jBN2sKFOxoOBrY0)OBjZnuL5anKqcjejQWDo6d6wKm9pcj5AP2Tg9MQ1uTcfUZrZ18srz8qW(ELAUc1dhwIkCNJ(GUfjt)JqsUwQDRrVP61uVkntHmH0ARiPMOSWHAcgyt7u9AQhoSev4oh9bDlsM(hHKCTu7wJEt1qvVkntHmH0AJeugZtC5HrjAsnbdSPD8DfRUr3jBN2sKFOxKOT8I0CeQmhOvaNrgtrG6Imft)JNKe)g5NLcKvNv3O7KTttZuitiTdQrckJ5jU8WOenjRUr3jBNMMPqMqAh)qVyfj1eLfouL5avIkCNJ(GUfjt)JqsUwQDRrVXh0Ay1n6oz700mfYes74h6fPrUfxI1UtscSDYMv3O7KTttZuitiTJFOxCCbbzh)g5NLcuL5aLW1dnwKqqIwINHoRQHwdRUr3jBNMMPqMqAh)qVW18srz8qW(ELQmhOsuH7C0h0Tiz6FesY1sTBn6nvRHv3O7KTttZuitiTJFOx4AEPOmEiyFVsvMduJUdCyeBmyqhFqRSAiHqZuitiTwI2YlATmkrQvQjyGnTtvOFQSAfRjWE1s8mcuJTPiqP6HdhcntHmH0AjEgbQjyGnTtvOFQS6AcSxTepJa1yBkcuQU6S6gDNSDAAMczcPD8d9Il5ercAfirL1iFCJZbAiRr(4Q3jaJBgLdQ69dhMW1OQqRu9QvOWDoAUMxkkJhc23RuZvWQB0DY2PPzkKjK2Xp0lCnVuugveZN3YQZQB0DY2P)yJKHcvI2YlsZrOYCGQWDoAhNuIDuMzGMGgDRwbCgzmfbQlYum9pEss8BKFwkWWHlWv)nYplfO2O7ahYQB0DY2P)yJKHYp0ls0wErAocvMducxp0yrcbjAjEg6SQgAnvdHMPqMqATvKutuw4qnbdSPD8Dv4WsuH7C0h0Tiz6FesY1sTBn6n(Qr9QvaNrgtrG6Imft)JNKe)g5NLcKv3O7KTt)XgjdLFOxKOT8IwlJsKALQmhORjWE1fOBhb2uuJTPiqzvAMczcP1wrsnrzHd1emWM2XQB0DY2P)yJKHYp0ls8mcuL5aLMPqMqATvKutuw4qnbdSPDS6gDNSD6p2izO8d9IJMCKpgDlzUHQmhOHeIev4oh9bDlsM(hHKCTuZvuLMPqMqATvKutuw4qnbdSPD8DL6HdlrfUZrFq3IKP)rijxl1U1O34Rg1RsZuitiT2ibLX8exEyuIMutWaBAhFxXQB0DY2P)yJKHYp0luHbz6F0XZKjeNkZbAiHirfUZrFq3IKP)rijxl1CfvPzkKjKwBfj1eLfoutWaBAhFxPE4WsuH7C0h0Tiz6FesY1sTBn6n(Qr9Q0mfYesRnsqzmpXLhgLOj1emWM2X3vS6gDNSD6p2izO8d9IeTLxKMJqL5aLW1dnwKqqIwINHoRQvw7QvaNrgtrG6Imft)JNKe)g5NLcKv3O7KTt)XgjdLFOxoOBrY0)OBjZnuL5anKqcjejQWDo6d6wKm9pcj5AP2Tg9MQ1uTcfUZrZ18srz8qW(ELAUc1dhwIkCNJ(GUfjt)JqsUwQDRrVP61uVkntHmH0ARiPMOSWHAcgyt7u9AQhoSev4oh9bDlsM(hHKCTu7wJEt1qvVkntHmH0AJeugZtC5HrjAsnbdSPD8DfRUr3jBN(Jnsgk)qVirB5fP5iuzoqRaoJmMIa1fzkM(hpjj(nYplfiyblaa]] )

end
