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
            resource = 'runes',

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
            local r = runes
            r.actual = nil

            r.spend( amt )

            gain( amt * 10, "runic_power" )

            if set_bonus.tier20_4pc == 1 then
                cooldown.army_of_the_dead.expires = max( 0, cooldown.army_of_the_dead.expires - 1 )
            end
        
        end
    end

    spec:RegisterHook( "spend", spendHook )

    
    local gainHook = function( amt, resource )
        if resource == 'runes' then
            local r = runes
            r.actual = nil

            r.gain( amt )
        end
    end

    spec:RegisterHook( "gain", gainHook )

    
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
                local up = ( pet.ghoul.up or pet.abomination.up ) and cast + 20 > state.query_time

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
            tick_time = 2,
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

    spec:RegisterStateExpr( "rune", function ()
        return runes.current
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
                    gain( 12, "runic_power" )
                else                    
                    gain( 3 * debuff.festering_wound.stack, "runic_power" )
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
                if debuff.festering_wound.stack > 1 then applyDebuff( "target", "festering_wound", debuff.festering_wound.remains, debuff.festering_wound.stack - 1 )
                else removeDebuff( "target", "festering_wound" ) end
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
            
            usable = function () return pet.alive end,
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
            
            usable = function () return not pet.exists end,
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
    
        package = "Unholy",
    } )

    spec:RegisterPack( "Unholy", 20180728.1905, [[dOePZaqijQEeQuytcvFcuPyuOQCkuv9ksjZsO4wGkv2fj)cvYWqLQJrk1Yav8mvumnvuDnjkBdvk9nvuACcLY5ekPwNqPI5rkCpqzFOkoiQuKfIQ0dfkjnrqLuUOqjXhbvs0ibvs4KGkLwPQWlbvs1mfkvYnbvsYobvnuuPOAPOsr5PQ0uvfDvqLQ2kOss9vHsLAVa)vWGPYHPSys1JHAYeUmYML0NvvJwv60kETkYSj62cz3k9BrdxchhujwoKNtvtxQRdY2jf9DuX4fkvDEvy9cLy(sK9JYaTbpbxH1eaE4WDTJnUFw4eBkTJ1CVm4ug42hfe4wy4t2Na31IiWfUFFt5b4wyhY0eGNGRpHqycCF7UWh7Wfx)PFH0v4mIl)ebjTEYfJSAZLFIWCPltDU0RgCNG0KRcuwhj5565qi4OnxpHJ2b4AK1Vb4678F7aC)(MYdLFIWGRo0iB42fOdUcRja8WH7AhBC)SWj2uAhR5(5C)SGRVGWa4HtzWbCfKhdUpFhpZnEMRFjMtqvds2mNH7jxMRWWNyUAIyo4(9nLhmhCn46m3SmhVvUjf4khF7bpbxCkfHxYqn4jaETbpbxAnDjja8cUy00eAmWvhQwvq7Bkpc(gr7VFvikYM1ZCAWCFSG5IZC6q1QcAFt5rW3iA)9RcrgUzU4mNouTQWPueEjd1HPPiLVn8jMJhMtBUfCnCp5cU4xBwFiRHbtGgapCapbxAnDjja8cUy00eAmWvhQwvrMVjuiRH)Bcj9kefzZ6zonyUpwWCXzoDOAvfz(MqHSg(VjK0RGkyU4mNouTQWPueEjd1HPPiLVn8jMJhMt7ZcUgUNCbx8RnRpK1WGjqdG)mGNGlTMUKeaEbxmAAcng4QdvRkCkfHxYqDyAks5BdFI5GXCWH7mxCMthQwvq7Bkpc(gr7VFviYWn4A4EYfCXV2S(qwddManObxbvnizdEcGxBWtW1W9Kl4AqDgSUn8jWLwtxscaVGgapCapbxd3tUGB0SIqfruSqGlTMUKeaEbna(ZaEcU0A6ssa4fC10Kqe4YhZHZuksoRYdffLB4BOFEijfIISz9mNgmxzmxCMJpMdNPuKCwLWqNcnYwFnrrwp5QquKnRN50G5kJ5kvI5kN5i4c0uuqcvBN6xcnnAI9(G)nHKccvycpZXpZXpZfN5AtsBR8qrr5g(g6NhssrRPljb4A4EYfC10qJPljWvtdfwlIa3ImLZ(d1ef(g6Nhsc0a4ph8eCP10LKaWl4IrttOXaxe0o4qrYHqkbvh80mhpmh3wgZfN54J5kOw9n0ppKKYW9OjXCLkXCLZCTjPTvEOOOCdFd9ZdjPO10LKG54N5IZCiOLucQo4PzoEGXCLbUgUNCbxdHTLcDIq02GgaFzGNGlTMUKeaEbxmAAcng4wqT6BOFEijLH7rtI5kvI5kN5AtsBR8qrr5g(g6NhssrRPljb4A4EYfC1Lzkcvi0bObWZTGNGlTMUKeaEbxmAAcng4wqT6BOFEijLH7rtI5kvI5kN5AtsBR8qrr5g(g6NhssrRPljb4A4EYfC1jKNqNM9dAa8Nf8eCnCp5cUqEkmnf5bxAnDjja8cAa8Xg4j4sRPljbGxW1W9Kl4wjzosseMTsO1KHid)olbUy00eAmWTGA13q)8qskd3JMeZvQeZvoZ1MK2w5HIIYn8n0ppKKIwtxscWDTicCRKmhjjcZwj0AYqKHFNLana(yn4j4sRPljbGxW1W9Kl4IM9hYAaNsPv4N9hQqneI8GlgnnHgdC5J50HQvvtrfT1tUkFB4tmhmMJ7mxCMRn0NAvpruOZGyiMJhMJB5oZXpZvQeZ1g6tTQNik0zqmeZPbZXTChCxlIax0S)qwd4ukTc)S)qfQHqKh0a41M7GNGlTMUKeaEbxmAAcng4IZuksoRYqrhHSg6xkiitOqKjoyUsLyUcQvFd9ZdjPmCpAsmxPsmNouTQG23uEeQiAJLdfub4A4EYfClYEYf0a41wBWtWLwtxscaVGlgnnHgdC5J5ezR0CqqsA7qH0(qKQh8Pqpruarr2SEMtlMRh8PqpreZPbmMtKTsZbbjPTdfs7drkefzZ6zo(zU4mNiBLMdcssBhkK2hIuikYM1ZCAaJ5(yb4A4EYfCtOwhr2jqdGxB4aEcU0A6ssa4fCnCp5cUytkdgUNCdYX3GRC8DyTicCXzkfjN1dAa8AFgWtWLwtxscaVGlgnnHgdCnCpAsbAPOH8mhpWyo4aUgUNCbxe0gmCp5gKJVbx547WAre4AjbAa8AFo4j4sRPljbGxW1W9Kl4InPmy4EYnihFdUYX3H1IiW9tlHgmObn4wGiCgPBn4jaETbpbxAnDjja8cAa8Wb8eCP10LKaWlObWFgWtWLwtxscaVGga)5GNGlTMUKeaEbna(Yapbxd3tUGBr2tUGlTMUKeaEbnaEUf8eCnCp5cUiB8uqqMaCP10LKaWlObWFwWtW1W9Kl4AOOJqwd9lfeKjaxAnDjja8cAqdUwsGNa41g8eCP10LKaWl4IrttOXaxCMsrYzvwrIn5rHNuikYM1dUgUNCbxbz9BWwrqqy7a0a4Hd4j4A4EYfCfuDKe4sRPljbGxqdG)mGNGlTMUKeaEbxmAAcng4kiRFd2kcccBhQEWNM9ZCXzoe0smNgmhCyU4mx5mNMgAmDjPkYuo7putu4BOFEijW1W9Kl4sfJGIgmObWFo4j4sRPljbGxWfJMMqJbUcY63GTIGGW2HQh8Pz)mxCMdbTeZPbZbhMloZvoZPPHgtxsQImLZ(d1ef(g6NhscCnCp5cUcY63aohjObWxg4j4sRPljbGxWfJMMqJbUcY63GTIGGW2HQh8Pz)mxCMdNPuKCwLvKytEu4jfIISz9GRH7jxW1Jti0Nc(gnNiqdGNBbpbxAnDjja8cUy00eAmWvqw)gSveee2ou9Gpn7N5IZC4mLIKZQSIeBYJcpPquKnRhCnCp5cUyPXz2FW)AIKJh0a4pl4j4sRPljbGxWfJMMqJbULZCAAOX0LKQit5S)qnrHVH(5HKaxd3tUGlvmckAWGgaFSbEcU0A6ssa4fCXOPj0yGBBsABLoeY3Z(d(erEfTMUKemxCMZxqszOn0NAVshc57z)bFIipZXdmMdomxCMtq6q1QQs(MqZ(dCsOvO8THpXCAaJ50gCnCp5cUvY3eA2FW3O5ebAa8XAWtWLwtxscaVGlgnnHgdC1HQvLhsiOniYmsHid3mxCMdbTKsq1bpnZXdmM7CW1W9Kl4kiRFd4CKGgaV2Ch8eCP10LKaWl4IrttOXaxDOAv5HecAdImJuiYWnZfN5kN500qJPljvrMYz)HAIcFd9ZdjXCLkXCfuR(g6Nhssz4E0Kaxd3tUGRGS(nGZrcAa8ARn4j4sRPljbGxWfJMMqJbUiODWHIKdHucQo4PzonyoTpN5IZC8XC4mLIKZQSIeBYJcpPquKnRN54H5kJ5kvI5eKouTQQKVj0S)aNeAfkFB4tmhpm35mh)mxCMRCMttdnMUKufzkN9hQjk8n0ppKe4A4EYfCfK1VbCosqdGxB4aEcU0A6ssa4fCXOPj0yGlFmhFmNG0HQvvL8nHM9h4KqRqbvWCXzoCMsrYzvwrIn5rHNuikYM1ZC8WCLXC8ZCLkXCcshQwvvY3eA2FGtcTcLVn8jMJhM7CMJFMloZHZuksoRYqrhHSg6xkiitOquKnRN54H5kdCnCp5cUECcH(uW3O5ebAa8AFgWtWLwtxscaVGlgnnHgdC5J54J5eKouTQQKVj0S)aNeAfkOcMloZHZuksoRYksSjpk8Kcrr2SEMJhMRmMJFMRujMtq6q1QQs(MqZ(dCsOvO8THpXC8WCNZC8ZCXzoCMsrYzvgk6iK1q)sbbzcfIISz9mhpmxzGRH7jxWflnoZ(d(xtKC8GgaV2NdEcU0A6ssa4fCXOPj0yGlcAhCOi5qiLGQdEAMtdMdoCN5IZCLZCAAOX0LKQit5S)qnrHVH(5HKaxd3tUGRGS(nGZrcAa8Axg4j4sRPljbGxWfJMMqJbU8XC8XC8XC8XCcshQwvvY3eA2FGtcTcLVn8jMtdM7CMloZvoZPdvRkO9nLhHkI2y5qbvWC8ZCLkXCcshQwvvY3eA2FGtcTcLVn8jMtdM7mmh)mxCMdNPuKCwLvKytEu4jfIISz9mNgm3zyo(zUsLyobPdvRQk5Bcn7pWjHwHY3g(eZPbZPnZXpZfN5WzkfjNvzOOJqwd9lfeKjuikYM1ZC8WCLbUgUNCb3k5Bcn7p4B0CIanaET5wWtWLwtxscaVGlgnnHgdClN500qJPljvrMYz)HAIcFd9ZdjbUgUNCbxbz9BaNJe0GgC)0sObdEcGxBWtWLwtxscaVGlgnnHgdC1HQvLhsiOniYmsHid3mxCMRCMttdnMUKufzkN9hQjk8n0ppKeZvQeZvqT6BOFEijLH7rtcCnCp5cUcY63aohjObWdhWtWLwtxscaVGlgnnHgdCrq7GdfjhcPeuDWtZCAWCAFoZfN54J5WzkfjNvzfj2KhfEsHOiBwpZXdZvgZvQeZjiDOAvvjFtOz)boj0ku(2WNyoEyUZzo(zU4mx5mNMgAmDjPkYuo7putu4BOFEijW1W9Kl4kiRFd4CKGga)zapbxAnDjja8cUy00eAmWTnjTTQG89iPftkAnDjjyU4mhotPi5SkRiXM8OWtkefzZ6bxd3tUGRGS(nyRiiiSDaAa8NdEcU0A6ssa4fCXOPj0yGlotPi5SkRiXM8OWtkefzZ6bxd3tUGRGQJKana(YapbxAnDjja8cUy00eAmWLpMJpMtq6q1QQs(MqZ(dCsOvOGkyU4mhotPi5SkRiXM8OWtkefzZ6zoEyUYyo(zUsLyobPdvRQk5Bcn7pWjHwHY3g(eZXdZDoZXpZfN5WzkfjNvzOOJqwd9lfeKjuikYM1ZC8WCLbUgUNCbxpoHqFk4B0CIanaEUf8eCP10LKaWl4IrttOXax(yo(yobPdvRQk5Bcn7pWjHwHcQG5IZC4mLIKZQSIeBYJcpPquKnRN54H5kJ54N5kvI5eKouTQQKVj0S)aNeAfkFB4tmhpm35mh)mxCMdNPuKCwLHIoczn0VuqqMqHOiBwpZXdZvg4A4EYfCXsJZS)G)1ejhpObWFwWtWLwtxscaVGlgnnHgdCrq7GdfjhcPeuDWtZCAWCWH7mxCMRCMttdnMUKufzkN9hQjk8n0ppKe4A4EYfCfK1VbCosqdGp2apbxAnDjja8cUy00eAmWLpMJpMJpMJpMtq6q1QQs(MqZ(dCsOvO8THpXCAWCNZCXzUYzoDOAvbTVP8iur0glhkOcMJFMRujMtq6q1QQs(MqZ(dCsOvO8THpXCAWCNH54N5IZC4mLIKZQSIeBYJcpPquKnRN50G5odZXpZvQeZjiDOAvvjFtOz)boj0ku(2WNyonyoTzo(zU4mhotPi5SkdfDeYAOFPGGmHcrr2SEMJhMRmW1W9Kl4wjFtOz)bFJMteObWhRbpbxAnDjja8cUy00eAmWTCMttdnMUKufzkN9hQjk8n0ppKe4A4EYfCfK1VbCosqdAWfNPuKCwp4jaETbpbxAnDjja8cUy00eAmWLGlqtrbju4ukcVKHAMloZPdvRkCkfHxYqDyAks5BdFI54H50M7GRH7jxWfBszWW9KBqo(gCLJVdRfrGloLIWlzOg0a4Hd4j4A4EYfCnu0riRH(LccYeGlTMUKeaEbna(ZaEcU0A6ssa4fCXOPj0yGRG0HQvvL8nHM9h4KqRq5BdFI54bgZDo4A4EYfCTIeBYJcpbAa8NdEcU0A6ssa4fCXOPj0yGlFmhbxGMIcsOA7u)sOPrtS3h8VjKuqOct4zU4mhotPi5SkpuuuUHVH(5HKuikYM1ZC8WCNZDMJFMRujMJpMRCMJGlqtrbjuTDQFj00Oj27d(3eskiuHj8mxPsmx5mxBsABLhkkk3W3q)8qskAnDjjyo(bxd3tUGRWqNcnYwFnrrwp5cAa8LbEcU0A6ssa4fCXOPj0yGlcAhCOi5qiLGQdEAMtdMt7Zbxd3tUGRhkkk3W3q)8qsGgap3cEcU0A6ssa4fCXOPj0yGRG0HQvvL8nHM9h4KqRq5BdFI50G5ohCnCp5cUq7BkpcveTXYbObWFwWtWLwtxscaVGlgnnHgdCnCpAsbAPOH8mhpWyo4WCXzo(yo(yoCMsrYzvcY63GTIGGW2Hcrr2SEMtdym3hlyU4mx5mxBsABLGQJKu0A6ssWC8ZCLkXC8XC4mLIKZQeuDKKcrr2SEMtdym3hlyU4mxBsABLGQJKu0A6ssWC8ZC8dUgUNCbxO9nLhHkI2y5a0a4JnWtWLwtxscaVGlgnnHgdC5J5Ad9Pw1tef6migI50G5InMRujMdbTeZPbmMdomh)mxCMRCMthQwvq7BkpcveTXYHcQaCnCp5cU(esgqKvqiqdGpwdEcUgUNCbxO9nLhbD58FBWLwtxscaVGg0GgC1Kq(jxa8WH7AhBC)SAFwL2NPmWLJH2z)EWn2n3e3m4HBHhUYyhMJ5E(sm3evKOM5QjI5GBeu1GKnCdZHi4c0GibZ5ZiI5mOoJSMemh(12p5vShXUMLyoTJDyo4(1dvuKOMemNH7jxMdUXG6myDB4tWnk2d2d42OIe1KG54wMZW9KlZjhF7vShGRb1VjcCVteK06j3yvKvBWTaL1rsGl3G5IvI9egQjbZPt1ermhoJ0TM50P)SEfZXnHXur7zUnx4UxdfvHKmNH7jxpZLR8qXEy4EY1RkqeoJ0TgwvA(tShgUNC9QceHZiDR1cgx1mfShgUNC9QceHZiDR1cgxg0pI226jx2dUbZDxRW)MnZHSrWC6q1kjyoFBTN50PAIiMdNr6wZC60FwpZzRG5kqeCxr29SFMB8mNixsXEy4EY1RkqeoJ0TwlyC5xRW)MDW3w7zpmCp56vficNr6wRfmUkYEYL9WW9KRxvGiCgPBTwW4czJNccYeShgUNC9QceHZiDR1cgxgk6iK1q)sbbzc2d2dUbZfRe7jmutcMJ0KqhmxpreZ1VeZz4orm34zottBKMUKuShgUNC9WmOodw3g(e7HH7jxVwW4kAwrOIikwi2dd3tUETGXLMgAmDjfZAreSImLZ(d1ef(g6NhskgnnjebJpCMsrYzvEOOOCdFd9ZdjPquKnRxJYIZhotPi5SkHHofAKT(AIISEYvHOiBwVgLvQu5eCbAkkiHs7ZCwUF2Y4N)4TjPTvEOOOCdFd9ZdjPO10LKG9GBWCCZm8ysFmmhCBtr(yyoBfmx2VeI5Ypw4zpmCp561cgxgcBlf6eHOTJzQWqq7GdfjhcPeuDWtZd3wwC(kOw9n0ppKKYW9OjvQu5TjPTvEOOOCdFd9ZdjPO10LKG)4iOLucQo4P5bwzShgUNC9AbJlDzMIqfcDeZuHvqT6BOFEijLH7rtQuPYBtsBR8qrr5g(g6NhssrRPljb7HH7jxVwW4sNqEcDA2Fmtfwb1QVH(5HKugUhnPsLkVnjTTYdffLB4BOFEijfTMUKeShgUNC9AbJlipfMMI8ShgUNC9AbJlipfMMIIzTicwLK5ijry2kHwtgIm87Sumtfwb1QVH(5HKugUhnPsLkVnjTTYdffLB4BOFEijfTMUKeShgUNC9AbJlipfMMIIzTicgA2FiRbCkLwHF2FOc1qiYhZuHXNouTQAkQOTEYv5BdFcg3J3g6tTQNik0zqmepCl35VuP2qFQv9erHodIH0GB5o7HH7jxVwW4Qi7j3yMkmCMsrYzvgk6iK1q)sbbzcfImXrPsfuR(g6Nhssz4E0KkvshQwvq7BkpcveTXYHcQG9GBWCWvzZ22SmhC1dcssBZCCZL2hIypmCp561cgxjuRJi7umTH(uhMkm(ezR0CqqsA7qH0(qKQh8Pqpruarr2SET6bFk0tePbmr2knheKK2ouiTpePquKnRN)4ISvAoiijTDOqAFisHOiBwVgW(yb7HH7jxVwW4cBszWW9KBqo(oM1Iiy4mLIKZ6zpmCp561cgxiOny4EYnihFhZAremlPyMkmd3JMuGwkAippWGd7HH7jxVwW4cBszWW9KBqo(oM1IiyFAj0Gzpyp4gmh3ugRWCOSTEYL9WW9KRxzjbtqw)gSveee2oIzQWWzkfjNvzfj2KhfEsHOiBwp7HH7jxVYsslyCjO6ij2dd3tUELLKwW4Ikgbfn4yMkmbz9BWwrqqy7q1d(0S)4iOL0aoXlxtdnMUKufzkN9hQjk8n0ppKe7HH7jxVYsslyCjiRFd4CKXmvycY63GTIGGW2HQh8Pz)XrqlPbCIxUMgAmDjPkYuo7putu4BOFEij2dd3tUELLKwW4YJti0Nc(gnNOyMkmbz9BWwrqqy7q1d(0S)44mLIKZQSIeBYJcpPquKnRN9WW9KRxzjPfmUWsJZS)G)1ejhFmtfMGS(nyRiiiSDO6bFA2FCCMsrYzvwrIn5rHNuikYM1ZEy4EY1RSK0cgxuXiOObhZuHvUMgAmDjPkYuo7putu4BOFEij2dd3tUELLKwW4Qs(MqZ(d(gnNOyMkS2K02kDiKVN9h8jI8kAnDjjI7liPm0g6tTxPdH89S)GprKNhyWjUG0HQvvL8nHM9h4KqRq5BdFsdyAZEy4EY1RSK0cgxcY63aohzmtfMouTQ8qcbTbrMrkez4oocAjLGQdEAEGDo7HH7jxVYsslyCjiRFd4CKXmvy6q1QYdje0gezgPqKH74LRPHgtxsQImLZ(d1ef(g6NhsQuPcQvFd9ZdjPmCpAsShgUNC9kljTGXLGS(nGZrgZuHHG2bhksoesjO6GNwdTppoF4mLIKZQSIeBYJcpPquKnRNNYkvsq6q1QQs(MqZ(dCsOvO8THpXZ58hVCnn0y6ssvKPC2FOMOW3q)8qsShgUNC9kljTGXLhNqOpf8nAorXmvy8XNG0HQvvL8nHM9h4KqRqbvehNPuKCwLvKytEu4jfIISz98ug)LkjiDOAvvjFtOz)boj0ku(2WN45C(JJZuksoRYqrhHSg6xkiitOquKnRNNYypmCp56vwsAbJlS04m7p4FnrYXhZuHXhFcshQwvvY3eA2FGtcTcfurCCMsrYzvwrIn5rHNuikYM1Ztz8xQKG0HQvvL8nHM9h4KqRq5BdFINZ5pootPi5SkdfDeYAOFPGGmHcrr2SEEkJ9WW9KRxzjPfmUeK1VbCoYyMkme0o4qrYHqkbvh80AahUhVCnn0y6ssvKPC2FOMOW3q)8qsShgUNC9kljTGXvL8nHM9h8nAorXmvy8XhF8jiDOAvvjFtOz)boj0ku(2WN0484LRdvRkO9nLhHkI2y5qbvWFPscshQwvvY3eA2FGtcTcLVn8jnod)XXzkfjNvzfj2KhfEsHOiBwVgNH)sLeKouTQQKVj0S)aNeAfkFB4tAOn)XXzkfjNvzOOJqwd9lfeKjuikYM1ZtzShgUNC9kljTGXLGS(nGZrgZuHvUMgAmDjPkYuo7putu4BOFEij2d2dUbZfRMsbZbxbzOM5K0NwHHoypmCp56v4ukcVKHAy4xBwFiRHbtXmvy6q1QcAFt5rW3iA)9Rcrr2SEn(yrCDOAvbTVP8i4BeT)(vHid3X1HQvfoLIWlzOomnfP8THpXJ2Cl7HH7jxVcNsr4LmuRfmUWV2S(qwddMIzQW0HQvvK5BcfYA4)MqsVcrr2SEn(yrCDOAvfz(MqHSg(VjK0RGkIRdvRkCkfHxYqDyAks5BdFIhTpl7HH7jxVcNsr4LmuRfmUWV2S(qwddMIzQW0HQvfoLIWlzOomnfP8THpbdoCpUouTQG23uEe8nI2F)QqKHB2d2dUbZfRMsbZ9sgQzoBfmx2VeI5YfU7JfmhotPi5SE2dd3tUEfotPi5SEyytkdgUNCdYX3XSwebdNsr4LmuhZuHrWfOPOGekCkfHxYqDCDOAvHtPi8sgQdttrkFB4t8On3zpmCp56v4mLIKZ61cgxgk6iK1q)sbbzc2dd3tUEfotPi5SETGXLvKytEu4PyMkmbPdvRQk5Bcn7pWjHwHY3g(epWoN9WW9KRxHZuksoRxlyCjm0PqJS1xtuK1tUXmvy8rWfOPOGekTpZz5(zllootPi5SkpuuuUHVH(5HKuikYM1ZZ5CN)sL4RCcUanffKqP9zol3pBzLkvEBsABLhkkk3W3q)8qskAnDjj4N9WW9KRxHZuksoRxlyC5HIIYn8n0ppKumtfgcAhCOi5qiLGQdEAn0(C2dd3tUEfotPi5SETGXf0(MYJqfrBSCeZuHjiDOAvvjFtOz)boj0ku(2WN04C2dd3tUEfotPi5SETGXf0(MYJqfrBSCeZuHz4E0Kc0srd55bgCIZhF4mLIKZQeK1VbBfbbHTdfIISz9Aa7JfXlVnjTTsq1rskAnDjj4Vuj(WzkfjNvjO6ijfIISz9Aa7JfXBtsBReuDKKIwtxsc(5N9WW9KRxHZuksoRxlyC5tizarwbHIPn0N6WuHXxBOp1QEIOqNbXqAeBLkHGwsdyWH)4LRdvRkO9nLhHkI2y5qbvWEy4EY1RWzkfjN1RfmUG23uEe0LZ)TzpypmCp56vFAj0GHjiRFd4CKXmvy6q1QYdje0gezgPqKH74LRPHgtxsQImLZ(d1ef(g6NhsQuPcQvFd9ZdjPmCpAsShgUNC9QpTeAWAbJlbz9BaNJmMPcdbTdouKCiKsq1bpTgAFEC(WzkfjNvzfj2KhfEsHOiBwppLvQKG0HQvvL8nHM9h4KqRq5BdFINZ5pE5AAOX0LKQit5S)qnrHVH(5HKypmCp56vFAj0G1cgxcY63GTIGGW2rmtfwBsABvb57rslMu0A6ssehNPuKCwLvKytEu4jfIISz9ShgUNC9QpTeAWAbJlbvhjfZuHHZuksoRYksSjpk8Kcrr2SE2dd3tUE1NwcnyTGXLhNqOpf8nAorXmvy8XNG0HQvvL8nHM9h4KqRqbvehNPuKCwLvKytEu4jfIISz98ug)LkjiDOAvvjFtOz)boj0ku(2WN45C(JJZuksoRYqrhHSg6xkiitOquKnRNNYypmCp56vFAj0G1cgxyPXz2FW)AIKJpMPcJp(eKouTQQKVj0S)aNeAfkOI44mLIKZQSIeBYJcpPquKnRNNY4VujbPdvRQk5Bcn7pWjHwHY3g(epNZFCCMsrYzvgk6iK1q)sbbzcfIISz98ug7HH7jxV6tlHgSwW4sqw)gW5iJzQWqq7GdfjhcPeuDWtRbC4E8Y10qJPljvrMYz)HAIcFd9ZdjXEy4EY1R(0sObRfmUQKVj0S)GVrZjkMPcJp(4JpbPdvRQk5Bcn7pWjHwHY3g(KgNhVCDOAvbTVP8iur0glhkOc(lvsq6q1QQs(MqZ(dCsOvO8THpPXz4pootPi5SkRiXM8OWtkefzZ614m8xQKG0HQvvL8nHM9h4KqRq5BdFsdT5pootPi5SkdfDeYAOFPGGmHcrr2SEEkJ9WW9KRx9PLqdwlyCjiRFd4CKXmvyLRPHgtxsQImLZ(d1ef(g6Nhsc0Ggaaa]] )

end
