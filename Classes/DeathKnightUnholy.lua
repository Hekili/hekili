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

    spec:RegisterPack( "Unholy", 20180930.1240, [[dy0tWaqiPcpsLqBsQ0Oiv1Piv5vOQAwKkULirTls(LkPHjvKJjsAzsv8mvcMMuLUMkrBtQO6BIeyCIe5CIeQ1HOKMhPs3dH2hQkherbTqevpuKqMOurPlIOu1gLkk6KsffwPuvVerbUjIsLDIinueLyPik0tvLPQs1vfjOTIOu0Eb(ROgmvDyklMuEmktMWLH2Sk(SQA0OkNwXQruk9AvkZMOBlIDl53cdxkwoONtLPR01rLTJi(ocgpIsHZlLwpIIMVi1(rAqQG7GNWweqApDk1uQtP4l0jvQ90BQ9aEBBdcEng7M9rWRSee8sHfVq2cEnwRmmb4o45coidbpE724iRxVcncQ)S8404CiKf1I1QyrYv3KWjTDIIbTZE1njSRAhlLfijxBGXzKO7kzbIKrBeURKfYyUZI2YltguZN3MtHfVq2QCtcd804g52zuanWtylciTNoLAk1Pu8f6Kk1E6n1uVe8CnidqApx2d4XBecSaAGNaDmW7IuFkS4fYwQVZI2YJ6jdQ5ZBP9Vi1ZB3ghz961)S840uSi5QBs4K2orXG2zV6Me2vnzODv7yPSaj5AdmoJeDxjlqKmAJWDLSqgZDw0wEzYGA(82CkS4fYwLBsy0(xK6FyZIjAiK6VqN0H67PtPMsuFkt9P2dzT3EO9P9Vi1NI4z1hDKvA)ls9Pm1tgkeOG6j7Msq9DMqejtur7FrQpLP(uuuKGWffu)AWpU55q9SOeZor5O(nOEi(5KgK6zrjMDIYPap54wh4o49XcHddChqAQG7GhwMMefaYbpgCweog4PXDokhNqGvwerIcIgBP(UuFhupjgCmnjQAIqo1pFcy(BWF0krQpDAQVbx13G)OvIkJTdji4zSDIc8eOT8YSyKGfqApG7GhwMMefaYbpgCweog4b5QHLBcciujWZWML61L6tTxQVl1Rp1ZIqkccLYAcMjBBCOcIj2uoQNpQ)sQpDAQxGACNJ6GUfHt9ZecUsOCRXUr98r99s96r9DP(oOEsm4yAsu1eHCQF(eW83G)OvIGNX2jkWtG2YlZIrcwaPxaCh8WY0KOaqo4XGZIWXaV1KyTQg0TJelgQWY0KOG67s9SiKIGqPSMGzY2ghQGyInLd8m2orbEc0wEzRezbYSwWciTxWDWdlttIca5Ghdolchd8yrifbHsznbZKTnoubXeBkh4zSDIc8e4zKiybKEj4o4HLPjrbGCWJbNfHJbE6t96t9cuJ7Cuh0TiCQFMqWvcfxd13L6zrifbHsznbZKTnoubXeBkh1Zh1Fj1Rh1Non1lqnUZrDq3IWP(zcbxjuU1y3OE(O(EPE9O(UuplcPiiukdM0MJtE5HzbAcfetSPCupFu)LGNX2jkWZXco4hZUfo3qWciTZb3bpSmnjkaKdEm4SiCmWtFQxFQxGACNJ6GUfHt9ZecUsO4AO(UuplcPiiukRjyMSTXHkiMyt5OE(O(lPE9O(0PPEbQXDoQd6weo1pti4kHYTg7g1Zh13l1Rh13L6zrifbHszWK2CCYlpmlqtOGyInLJ65J6Ve8m2orbEmPryQF2XZebbhybKMca3bpSmnjkaKdEm4SiCmWdYvdl3eeqOsGNHnl1Rl13tNO(UuFhupjgCmnjQAIqo1pFcy(BWF0krWZy7ef4jqB5LzXiblG0ucCh8WY0KOaqo4XGZIWXap9PE9PE9PE9PEbQXDoQd6weo1pti4kHYTg7g1Rl13l13L67G614ohfxXlKT5delYSvX1q96r9Ptt9cuJ7Cuh0TiCQFMqWvcLBn2nQxxQ)cuVEuFxQNfHueekL1emt224qfetSPCuVUu)fOE9O(0PPEbQXDoQd6weo1pti4kHYTg7g1Rl1Nk1Rh13L6zrifbHszWK2CCYlpmlqtOGyInLJ65J6Ve8m2orbEh0TiCQF2TW5gcwaPPyWDWdlttIca5Ghdolchd86G6jXGJPjrvteYP(5taZFd(JwjcEgBNOapbAlVmlgjybl4jWJXjxWDaPPcUdEgBNOaVKPe5derYebpSmnjkaKdwaP9aUdEyzAsuaih8iXKCi4XIqkccLYXLKev(BWF0krfetSPCuVUu)LuFxQFnjwRYXLKev(BWF0krfwMMefGNX2jkWJedoMMebpsmyUSee8AIqo1pFcy(BWF0krWci9cG7GhwMMefaYbpgCweog4b5QHLBcciujWZWML65J678lP(UuV(uFdUQVb)rRevgBhsqQpDAQVdQFnjwRYXLKev(BWF0krfwMMefuVEuFxQhYvOsGNHnl1ZhrQ)sWZy7ef4zqMvyEdieRfSas7fCh8WY0KOaqo4XGZIWXaVgCvFd(JwjQm2oKGuF60uFhu)AsSwLJljjQ83G)OvIkSmnjkapJTtuGNMmcr(WbBblG0lb3bpSmnjkaKdEm4SiCmWRbx13G)OvIkJTdji1Non13b1VMeRv54ssIk)n4pALOclttIcWZy7ef4PHqhcVn1hSas7CWDWZy7ef4X5W8SyId8WY0KOaqoybKMca3bpSmnjkaKdEgBNOapT2FuywdXSjtSYyGhdolchd8yrifbHs54ssIk)n4pALOcIj2uoQNpQVZ7e1Non13b1VMeRv54ssIk)n4pALOclttIcWRSee80A)rHzneZMmXkJbwaPPe4o4HLPjrbGCWZy7ef4r2IUmVGGeHGhdolchd8AWv9n4pALOYy7qcs9Ptt9Dq9RjXAvoUKKOYFd(JwjQWY0KOa8klbbpYw0L5feKieSastXG7GhwMMefaYbpJTtuG33KiZKse6YAODd8yWzr4yGxdUQVb)rRevgBhsqQpDAQVdQFnjwRYXLKev(BWF0krfwMMefGxzji49njYmPeHUSgA3alG0u7e4o4HLPjrbGCWJbNfHJbESiKIGqPmysBoo5LhMfOjuq0eTuF60uFdUQVb)rRevgBhsqQpDAQxJ7CuCfVq2MpqSiZwfxd4zSDIc8AIDIcSastnvWDWdlttIca5Ghdolchd80N6fXQizGCsS2CJ0(COAh2T8ojygIj2uoQNFQFh2T8oji1RlrQxeRIKbYjXAZns7ZHkiMyt5OE9O(UuViwfjdKtI1MBK2NdvqmXMYr96sK6)mb4zSDIc8cUvdI2nWcin1Ea3bpSmnjkaKdEgBNOapMjLzJTtuz54wWtoUnxwccESiKIGq5alG0uVa4o4HLPjrbGCWJbNfHJbEgBhsWmwyYGoQNpIuFpGNX2jkWdYvzJTtuz54wWtoUnxwccEwGGfqAQ9cUdEyzAsuaih8m2orbEmtkZgBNOYYXTGNCCBUSee8(yHWHbwWcEnqKfjA2cUdinvWDWdlttIca5GfqApG7GhwMMefaYblG0laUdEyzAsuaihSas7fCh8WY0KOaqoybKEj4o4zSDIc8AIDIc8WY0KOaqoybK25G7GNX2jkWdAJdZc0eGhwMMefaYblG0ua4o4HLPjrbGCWtGsRf86b8m2orbEgmPnhN8YdZc0eGfSGhlcPiiuoWDaPPcUdEgBNOapdM0MJtE5HzbAcWdlttIca5GfqApG7GhwMMefaYbpgCweog4jqnUZrDq3IWP(zcbxjuU1y3OE(is99cEgBNOapRjyMSTXHGfq6fa3bpJTtuGNWG3Yl0k3jGj2orbEyzAsuaihSas7fCh8WY0KOaqo4XGZIWXapixnSCtqaHkbEg2SuVUuFQ9cEgBNOaphxssu5Vb)rReblG0lb3bpSmnjkaKdEm4SiCmWtGACNJ6GUfHt9ZecUsOCRXUr96s99cEgBNOapUIxiBZhiwKzlybK25G7GhwMMefaYbpgCweog4zSDibZyHjd6OE(is99q9DPE9PE9PEwesrqOuc0wEzRezbYSwfetSPCuVUeP(ptq9DP(oO(1KyTkbEgjQWY0KOG61J6tNM61N6zrifbHsjWZirfetSPCuVUeP(ptq9DP(1KyTkbEgjQWY0KOG61J61d8m2orbECfVq2MpqSiZwWcinfaUdEyzAsuaih8yWzr4yGN(u)AWpUQDsW8gzXGuVUuFkr9Ptt9qUcPEDjs99q96r9DP(oOEnUZrXv8czB(aXImBvCnGNX2jkWZfCYmeTgecwaPPe4o4zSDIc84kEHSnRjNpVf8WY0KOaqoybl4zbcUdinvWDWdlttIca5Ghdolchd8yrifbHsznbZKTnoubXeBkh4zSDIc8eOT8YwjYcKzTGfqApG7GNX2jkWtGNrIGhwMMefaYblG0laUdEyzAsuaih8yWzr4yGNaTLx2krwGmRvTd72uFQVl1d5kK61L67H67s9Dq9KyWX0KOQjc5u)8jG5Vb)rRebpJTtuGh2mcmzyGfqAVG7GhwMMefaYbpgCweog4jqB5LTsKfiZAv7WUn1N67s9qUcPEDP(EO(UuFhupjgCmnjQAIqo1pFcy(BWF0krWZy7ef4jqB5LzXiblG0lb3bpSmnjkaKdEm4SiCmWtG2YlBLilqM1Q2HDBQp13L6zrifbHsznbZKTnoubXeBkh4zSDIc8CSGd(XSBHZneSas7CWDWdlttIca5Ghdolchd8eOT8YwjYcKzTQDy3M6t9DPEwesrqOuwtWmzBJdvqmXMYbEgBNOapM0im1p74zIGGdSastbG7GhwMMefaYbpgCweog41b1tIbhttIQMiKt9ZNaM)g8hTse8m2orbEyZiWKHbwaPPe4o4HLPjrbGCWJbNfHJbEcuJ7Cuh0TiCQFMqWvcLBn2nQxxIuFQuFxQNfHueekLaTLx2krwGmRvbXeBkh4zSDIc8oOBr4u)SBHZneSastXG7GhwMMefaYbpgCweog4TMeRvPXbD7u)SlGOtHLPjrb13L6DnOuMxd(X1P04GUDQF2fq0r98rK67H67s9cuJ7Cuh0TiCQFMqWvcLBn2nQxxIuFQGNX2jkW7GUfHt9ZUfo3qWcin1obUdEyzAsuaih8yWzr4yGNg35OCCcbwzrejkiASL67s9qUcvc8mSzPE(is99cEgBNOapbAlVmlgjybKMAQG7GhwMMefaYbpgCweog4PXDokhNqGvwerIcIgBP(UuFhupjgCmnjQAIqo1pFcy(BWF0krQpDAQVbx13G)OvIkJTdji4zSDIc8eOT8YSyKGfqAQ9aUdEyzAsuaih8yWzr4yGhKRgwUjiGqLapdBwQxxQp1EP(UuV(uplcPiiukRjyMSTXHkiMyt5OE(O(lP(0PPEbQXDoQd6weo1pti4kHYTg7g1Zh13l1Rh13L67G6jXGJPjrvteYP(5taZFd(JwjcEgBNOapbAlVmlgjybKM6fa3bpSmnjkaKdEm4SiCmWtFQxFQxGACNJ6GUfHt9ZecUsO4AO(UuplcPiiukRjyMSTXHkiMyt5OE(O(lPE9O(0PPEbQXDoQd6weo1pti4kHYTg7g1Zh13l1Rh13L6zrifbHszWK2CCYlpmlqtOGyInLJ65J6Ve8m2orbEowWb)y2TW5gcwaPP2l4o4HLPjrbGCWJbNfHJbE6t96t9cuJ7Cuh0TiCQFMqWvcfxd13L6zrifbHsznbZKTnoubXeBkh1Zh1Fj1Rh1Non1lqnUZrDq3IWP(zcbxjuU1y3OE(O(EPE9O(UuplcPiiukdM0MJtE5HzbAcfetSPCupFu)LGNX2jkWJjnct9ZoEMii4alG0uVeCh8WY0KOaqo4XGZIWXapixnSCtqaHkbEg2SuVUuFpDI67s9Dq9KyWX0KOQjc5u)8jG5Vb)rRebpJTtuGNaTLxMfJeSastTZb3bpSmnjkaKdEm4SiCmWtFQxFQxFQxFQxGACNJ6GUfHt9ZecUsOCRXUr96s99s9DP(oOEnUZrXv8czB(aXImBvCnuVEuF60uVa14oh1bDlcN6NjeCLq5wJDJ61L6Va1Rh13L6zrifbHsznbZKTnoubXeBkh1Rl1FbQxpQpDAQxGACNJ6GUfHt9ZecUsOCRXUr96s9Ps96r9DPEwesrqOugmPnhN8YdZc0ekiMyt5OE(O(lbpJTtuG3bDlcN6NDlCUHGfqAQPaWDWdlttIca5Ghdolchd86G6jXGJPjrvteYP(5taZFd(JwjcEgBNOapbAlVmlgjyblybpsqOBIcqApDk1uQtP4EsjvpDQ3laEemyn13bEDgjnbCrb1Fj1BSDII6LJBDkAFWRbgNrIG3fP(uyXlKTuFNfTLh1tguZN3s7FrQN3UnoY61R)z5XPPyrYv3KWjTDIIbTZE1njSRAYq7Q2XszbsY1gyCgj6UswGiz0gH7kzHmM7SOT8YKb185T5uyXlKTk3KWO9Vi1)WMft0qi1FHoPd13tNsnLO(uM6tThYAV9q7t7FrQpfXZQp6iR0(xK6tzQNmuiqb1t2nLG67mHisMOI2)IuFkt9POOibHlkO(1GFCZZH6zrjMDIYr9Bq9q8Zjni1ZIsm7eLtr7t7FrQNSNSbY4wuq9A4jGi1ZIenBPEn8pLtr9KHmg2SoQVIkL5zWKdNK6n2or5O(OKTkAFJTtuovdezrIMTepsZDJ23y7eLt1arwKOzl)eVEIqq7BSDIYPAGils0SLFIxnUFcwRTtu0(xK6FL144fl1dTrq9ACNdkOE3ARJ61WtarQNfjA2s9A4Fkh1BLG6BGyk3e7o1N6hh1lIcv0(gBNOCQgiYIenB5N4vxznoEXMDRToAFJTtuovdezrIMT8t8AtStu0(gBNOCQgiYIenB5N4vOnomlqtq7BSDIYPAGils0SLFIxnysBoo5LhMfOj0rGsRLyp0(0(xK6j7jBGmUffupsccBP(DsqQF5HuVX2as9JJ6nsSrAAsur7BSDIYrmzkr(arKmrAFJTtuo(jELedoMMe1PSeKyteYP(5taZFd(JwjQdjMKdjYIqkccLYXLKev(BWF0krfetSPC6Ez31KyTkhxssu5Vb)rRevyzAsuq7FrQNmASXKoDO(oJftC6q9wjO(y5HqQp(mHJ23y7eLJFIxniZkmVbeI1QZCic5QHLBcciujWZWMLVo)YU63GR6BWF0krLX2HemD6owtI1QCCjjrL)g8hTsuHLPjrHEDHCfQe4zyZYhXlP9n2or54N4vnzeI8Hd2QZCi2GR6BWF0krLX2HemD6owtI1QCCjjrL)g8hTsuHLPjrbTVX2jkh)eVQHqhcVn1xN5qSbx13G)OvIkJTdjy60DSMeRv54ssIk)n4pALOclttIcA)ls9Pio3gju)cN6gUoQNZzFK23y7eLJFIx5CyEwmXr7BSDIYXpXRComplMOtzjirT2FuywdXSjtSYy6mhISiKIGqPCCjjrL)g8hTsubXeBkhFDENsNUJ1KyTkhxssu5Vb)rRevyzAsuq7BSDIYXpXRComplMOtzjirYw0L5feKiuN5qSbx13G)OvIkJTdjy60DSMeRv54ssIk)n4pALOclttIcAFJTtuo(jELZH5zXeDklbj(njYmPeHUSgA30zoeBWv9n4pALOYy7qcMoDhRjXAvoUKKOYFd(JwjQWY0KOG23y7eLJFIxBIDIsN5qKfHueekLbtAZXjV8WSanHcIMOnD6gCvFd(JwjQm2oKGPtRXDokUIxiBZhiwKzRIRH2)IupzNn1Atr9KnhiNeRL6jls7ZH0(gBNOC8t8AWTAq0UPZCiQViwfjdKtI1MBK2Ndv7WUL3jbZqmXMYX)oSB5DsqDjkIvrYa5KyT5gP95qfetSPC61veRIKbYjXAZns7ZHkiMyt50L4NjO9n2or54N4vMjLzJTtuz54wDklbjYIqkccLJ23y7eLJFIxHCv2y7evwoUvNYsqIwG6mhIgBhsWmwyYGo(i2dTVX2jkh)eVYmPmBSDIklh3QtzjiXpwiCy0(0(xK6jddYEQhgRTtu0(gBNOCklqIc0wEzRezbYSwDMdrwesrqOuwtWmzBJdvqmXMYr7BSDIYPSa5N4vbEgjs7BSDIYPSa5N4vSzeyYW0zoefOT8YwjYcKzTQDy3M63fYvOU90Tdsm4yAsu1eHCQF(eW83G)OvI0(gBNOCklq(jEvG2YlZIrQZCikqB5LTsKfiZAv7WUn1VlKRqD7PBhKyWX0KOQjc5u)8jG5Vb)rReP9n2or5uwG8t8QJfCWpMDlCUH6mhIc0wEzRezbYSw1oSBt97YIqkccLYAcMjBBCOcIj2uoAFJTtuoLfi)eVYKgHP(zhpteeC6mhIc0wEzRezbYSw1oSBt97YIqkccLYAcMjBBCOcIj2uoAFJTtuoLfi)eVInJatgMoZHyhKyWX0KOQjc5u)8jG5Vb)rReP9n2or5uwG8t86bDlcN6NDlCUH6mhIcuJ7Cuh0TiCQFMqWvcLBn2nDjMAxwesrqOuc0wEzRezbYSwfetSPC0(gBNOCklq(jE9GUfHt9ZUfo3qDMdX1KyTknoOBN6NDbeDkSmnjk66AqPmVg8JRtPXbD7u)SlGOJpI90vGACNJ6GUfHt9ZecUsOCRXUPlXuP9n2or5uwG8t8QaTLxMfJuN5quJ7CuooHaRSiIefen22fYvOsGNHnlFe7L23y7eLtzbYpXRc0wEzwmsDMdrnUZr54ecSYIisuq0yB3oiXGJPjrvteYP(5taZFd(JwjMoDdUQVb)rRevgBhsqAFJTtuoLfi)eVkqB5LzXi1zoeHC1WYnbbeQe4zyZQBQ92vFwesrqOuwtWmzBJdvqmXMYX3LPtlqnUZrDq3IWP(zcbxjuU1y34Rx962bjgCmnjQAIqo1pFcy(BWF0krAFJTtuoLfi)eV6ybh8Jz3cNBOoZHO(6lqnUZrDq3IWP(zcbxjuCnDzrifbHsznbZKTnoubXeBkhFxQx60cuJ7Cuh0TiCQFMqWvcLBn2n(6vVUSiKIGqPmysBoo5LhMfOjuqmXMYX3L0(gBNOCklq(jELjnct9ZoEMii40zoe1xFbQXDoQd6weo1pti4kHIRPllcPiiukRjyMSTXHkiMyt547s9sNwGACNJ6GUfHt9ZecUsOCRXUXxV61LfHueekLbtAZXjV8WSanHcIj2uo(UK23y7eLtzbYpXRc0wEzwmsDMdrixnSCtqaHkbEg2S62tN62bjgCmnjQAIqo1pFcy(BWF0krAFJTtuoLfi)eVEq3IWP(z3cNBOoZHO(6RV(cuJ7Cuh0TiCQFMqWvcLBn2nD7TBhACNJIR4fY28bIfz2Q4A0lDAbQXDoQd6weo1pti4kHYTg7MUxqVUSiKIGqPSMGzY2ghQGyInLt3lOx60cuJ7Cuh0TiCQFMqWvcLBn2nDtvVUSiKIGqPmysBoo5LhMfOjuqmXMYX3L0(gBNOCklq(jEvG2YlZIrQZCi2bjgCmnjQAIqo1pFcy(BWF0krAFAFJTtuoflcPiiuoIgmPnhN8YdZc0e0(gBNOCkwesrqOC8t8Q1emt224qDMdrbQXDoQd6weo1pti4kHYTg7gFe7L23y7eLtXIqkccLJFIxfg8wEHw5obmX2jkAFJTtuoflcPiiuo(jE1XLKev(BWF0krDMdrixnSCtqaHkbEg2S6MAV0(gBNOCkwesrqOC8t8kxXlKT5delYSvN5quGACNJ6GUfHt9ZecUsOCRXUPBV0(gBNOCkwesrqOC8t8kxXlKT5delYSvN5q0y7qcMXctg0XhXE6QV(SiKIGqPeOT8YwjYcKzTkiMyt50L4Nj62XAsSwLapJevyzAsuOx606ZIqkccLsGNrIkiMyt50L4Nj6UMeRvjWZirfwMMef6PhTVX2jkNIfHueekh)eV6cozgIwdc1zoe1Fn4hx1ojyEJSyqDtP0PHCfQlXE0RBhACNJIR4fY28bIfz2Q4AO9n2or5uSiKIGq54N4vUIxiBZAY5ZBP9P9n2or5uFSq4WikqB5LzXi1zoe14ohLJtiWklIirbrJTD7GedoMMevnriN6Npbm)n4pALy60n4Q(g8hTsuzSDibP9n2or5uFSq4W4N4vbAlVmlgPoZHiKRgwUjiGqLapdBwDtT3U6ZIqkccLYAcMjBBCOcIj2uo(UmDAbQXDoQd6weo1pti4kHYTg7gF9Qx3oiXGJPjrvteYP(5taZFd(Jwjs7BSDIYP(yHWHXpXRc0wEzRezbYSwDMdX1KyTQg0TJelgQWY0KOOllcPiiukRjyMSTXHkiMyt5O9n2or5uFSq4W4N4vbEgjQZCiYIqkccLYAcMjBBCOcIj2uoAFJTtuo1hleom(jE1Xco4hZUfo3qDMdr91xGACNJ6GUfHt9ZecUsO4A6YIqkccLYAcMjBBCOcIj2uo(UuV0PfOg35OoOBr4u)mHGRek3ASB81REDzrifbHszWK2CCYlpmlqtOGyInLJVlP9n2or5uFSq4W4N4vM0im1p74zIGGtN5quF9fOg35OoOBr4u)mHGRekUMUSiKIGqPSMGzY2ghQGyInLJVl1lDAbQXDoQd6weo1pti4kHYTg7gF9QxxwesrqOugmPnhN8YdZc0ekiMyt547sAFJTtuo1hleom(jEvG2YlZIrQZCic5QHLBcciujWZWMv3E6u3oiXGJPjrvteYP(5taZFd(Jwjs7BSDIYP(yHWHXpXRh0TiCQF2TW5gQZCiQV(6RVa14oh1bDlcN6NjeCLq5wJDt3E72Hg35O4kEHSnFGyrMTkUg9sNwGACNJ6GUfHt9ZecUsOCRXUP7f0RllcPiiukRjyMSTXHkiMyt509c6LoTa14oh1bDlcN6NjeCLq5wJDt3u1RllcPiiukdM0MJtE5HzbAcfetSPC8DjTVX2jkN6Jfchg)eVkqB5LzXi1zoe7GedoMMevnriN6Npbm)n4pALi4zClVacEVjHtA7evkcANfSGfaa]] )

end
