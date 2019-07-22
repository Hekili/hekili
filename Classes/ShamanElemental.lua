-- ShamanElemental.lua
-- May 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local PTR = ns.PTR


if UnitClassBase( 'player' ) == 'SHAMAN' then
    local spec = Hekili:NewSpecialization( 262, true )

    spec:RegisterResource( Enum.PowerType.Maelstrom, {
        resonance_totem = {
            aura = 'resonance_totem',

            last = function ()
                local app = state.buff.resonance_totem.applied
                local t = state.query_time

                return app + floor( t - app )
            end,

            interval = 1,
            value = 1,
        },
    } )
    spec:RegisterResource( Enum.PowerType.Mana )

    -- Talents
    spec:RegisterTalents( {
        earthen_rage = 22356, -- 170374
        echo_of_the_elements = 22357, -- 108283
        elemental_blast = 22358, -- 117014

        aftershock = 23108, -- 273221
        call_the_thunder = 22139, -- 260897
        totem_mastery = 23190, -- 210643

        spirit_wolf = 23162, -- 260878
        earth_shield = 23163, -- 974
        static_charge = 23164, -- 265046

        master_of_the_elements = 19271, -- 16166
        storm_elemental = 19272, -- 192249
        liquid_magma_totem = 19273, -- 192222

        natures_guardian = 22144, -- 30884
        ancestral_guidance = 22172, -- 108281
        wind_rush_totem = 21966, -- 192077

        surge_of_power = 22145, -- 262303
        primal_elementalist = 19266, -- 117013
        icefury = 23111, -- 210714

        unlimited_power = 21198, -- 260895
        stormkeeper = 22153, -- 191634
        ascendance = 21675, -- 114050
    } )

    -- PvP Talents
    spec:RegisterPvpTalents( { 
        relentless = 3596, -- 196029
        adaptation = 3597, -- 214027
        gladiators_medallion = 3598, -- 208683

        spectral_recovery = 3062, -- 204261
        control_of_lava = 728, -- 204393
        earthfury = 729, -- 204398
        traveling_storms = 730, -- 204403
        lightning_lasso = 731, -- 204437
        elemental_attunement = 727, -- 204385
        skyfury_totem = 3488, -- 204330
        grounding_totem = 3620, -- 204336
        counterstrike_totem = 3490, -- 204331
        purifying_waters = 3491, -- 204247
        swelling_waves = 3621, -- 204264
    } )

    -- Auras
    spec:RegisterAuras( {
        ancestral_guidance = {
            id = 108281,
            duration = 10,
            max_stack = 1,
        },

        ascendance = {
            id = 114050,
            duration = 15,
            max_stack = 1,
        },

        astral_shift = {
            id = 108271,
            duration = 8,
            max_stack = 1,
        },

        earth_shield = {
            id = 974,
            duration = 600,
            type = "Magic",
            max_stack = 9,
        },

        earthbind = {
            id = 3600,
            duration = 5,
            type = "Magic",
            max_stack = 1,
        },

        earthquake = {
            id = 61882,
            duration = 3600,
            max_stack = 1,
        },

        elemental_blast = {
            duration = 10,
            type = "Magic",
            max_stack = 3,
            generate = function ()
                local eb = buff.elemental_blast

                local count = ( buff.elemental_blast_critical_strike.up and 1 or 0 ) +
                              ( buff.elemental_blast_haste.up and 1 or 0 ) +
                              ( buff.elemental_blast_mastery.up and 1 or 0 )
                local applied = max( buff.elemental_blast_critical_strike.applied,
                                buff.elemental_blast_haste.applied,
                                buff.elemental_blast_mastery.applied )

                eb.name = class.abilities.elemental_blast.name or "Elemental Blast"
                eb.count = count
                eb.applied = applied
                eb.expires = applied + 15
                eb.caster = count > 0 and 'player' or 'nobody'
            end
        },

        elemental_blast_critical_strike = {
            id = 118522,
            duration = 10,
            type = "Magic",
            max_stack = 1,
        },

        elemental_blast_haste = {
            id = 173183,
            duration = 10,
            type = "Magic",
            max_stack = 1,
        },

        elemental_blast_mastery = {
            id = 173184,
            duration = 10,
            type = "Magic",
            max_stack = 1,
        },

        ember_totem = {
            id = 210658,
            duration = 0,
            max_stack = 1,
        },

        exposed_elements = {
            id = 269808,
            duration = 15,
            max_stack = 1,
        },

        far_sight = {
            id = 6196,
            duration = 60,
            max_stack = 1,
        },

        flame_shock = {
            id = 188389,
            duration = 24,
            tick_time = function () return 2 * haste end,
            type = "Magic",
            max_stack = 1,
        },

        frost_shock = {
            id = 196840,
            duration = 6,
            type = "Magic",
            max_stack = 1,
        },

        ghost_wolf = {
            id = 2645,
            duration = 3600,
            type = "Magic",
            max_stack = 1,
        },

        icefury = {
            id = 210714,
            duration = 15,
            max_stack = 4,
        },

        lava_surge = {
            id = 77762,
            duration = 10,
            max_stack = 1,
        },

        lightning_lasso = {
            id = 305484,
            duration = 5,
            max_stack = 1
        },

        master_of_the_elements = {
            id = 260734,
            duration = 15,
            type = "Magic",
            max_stack = 1,
        },

        resonance_totem = {
            id = 202192,
            duration = 120,
            max_stack = 1,
        },

        spirit_wolf = {
            id = 260881,
            duration = 3600,
            max_stack = 4,
        },

        static_charge = {
            id = 265046,
            duration = 3,
            type = "Magic",
            max_stack = 1,
        },

        storm_totem = {
            id = 210652,
            duration = 120,
            max_stack = 1,
        },

        stormkeeper = {
            id = 191634,
            duration = 15,
            max_stack = 2,
        },

        surge_of_power = {
            id = 285514,
            duration = 15,
            max_stack = 1,
        },

        surge_of_power_debuff = {
            id = 285515,
            duration = 6,
            max_stack = 1,
        },

        tailwind_totem = {
            id = 210659,
            duration = 120,
            max_stack = 1,
        },

        thunderstorm = {
            id = 51490,
            duration = 5,
            max_stack = 1,
        },

        unlimited_power = {
            id = 272737,
            duration = 10,
            max_stack = 10, -- this is a guess.
        },        

        water_walking = {
            id = 546,
            duration = 600,
            max_stack = 1,
        },

        wind_rush = {
            id = 192082,
            duration = 5,
            max_stack = 1,
        },

        totem_mastery = {
            duration = 120,
            generate = function ()
                local expires, remains = 0, 0

                for i = 1, 5 do
                    local _, name, cast, duration = GetTotemInfo(i)

                    if name == class.abilities.totem_mastery.name then
                        if cast + duration > expires then
                            expires = cast + duration
                            remains = expires - now
                        end
                    end
                end

                local up = buff.resonance_totem.up and remains > 0

                local tm = buff.totem_mastery
                tm.name = class.abilities.totem_mastery.name

                if expires > 0 and up then
                    tm.count = 4
                    tm.expires = expires
                    tm.applied = expires - 120
                    tm.caster = "player"

                    applyBuff( "resonance_totem", remains )
                    applyBuff( "tailwind_totem", remains )
                    applyBuff( "storm_totem", remains )
                    applyBuff( "ember_totem", remains )
                    return
                end

                tm.count = 0
                tm.expires = 0
                tm.applied = 0
                tm.caster = "nobody"
            end,
        },

        wind_gust = {
            id = 263806,
            duration = 30,
            max_stack = 20
        },


        -- Azerite Powers
        ancestral_resonance = {
            id = 277943,
            duration = 15,
            max_stack = 1,
        },

        tectonic_thunder = {
            id = 286976,
            duration = 15,
            max_stack = 1,
        },


        -- Pet aura.
        call_lightning = {
            duration = 15,
            generate = function( t, db )
                if storm_elemental.up then
                    local name, _, count, _, duration, expires = FindUnitBuffByID( "pet", 157348 )

                    if name then
                        t.count = count
                        t.expires = expires
                        t.applied = expires - duration
                        t.caster = "pet"
                        return
                    end    
                end

                t.count = 0
                t.expires = 0
                t.applied = 0
                t.caster = "nobody"
            end,
        },        
    } )


    -- Pets
    spec:RegisterPet( "primal_storm_elemental", 77942, "storm_elemental", 30 )
    spec:RegisterTotem( "greater_storm_elemental", 1020304 ) -- Texture ID

    spec:RegisterPet( "primal_fire_elemental", 61029, "fire_elemental", 30 )
    spec:RegisterTotem( "greater_fire_elemental", 135790 ) -- Texture ID

    spec:RegisterPet( "primal_earth_elemental", 61056, "earth_elemental", 60 )
    spec:RegisterTotem( "greater_earth_elemental", 136024 ) -- Texture ID


    spec:RegisterStateTable( 'fire_elemental', setmetatable( { onReset = function( self ) self.cast_time = nil end }, {
        __index = function( t, k )
            if k == 'cast_time' then
                t.cast_time = class.abilities.fire_elemental.lastCast or 0
                return t.cast_time
            end

            local elem = talent.primal_elementalist.enabled and pet.primal_fire_elemental or pet.greater_fire_elemental

            if k == 'active' or k == 'up' then
                return elem.up

            elseif k == 'down' then
                return not elem.up

            elseif k == 'remains' then
                return max( 0, elem.remains )

            end

            return false
        end 
    } ) )

    spec:RegisterStateTable( 'storm_elemental', setmetatable( { onReset = function( self ) self.cast_time = nil end }, {
        __index = function( t, k )
            if k == 'cast_time' then
                t.cast_time = class.abilities.storm_elemental.lastCast or 0
                return t.cast_time
            end

            local elem = talent.primal_elementalist.enabled and pet.primal_storm_elemental or pet.greater_storm_elemental

            if k == 'active' or k == 'up' then
                return elem.up

            elseif k == 'down' then
                return not elem.up

            elseif k == 'remains' then
                return max( 0, elem.remains )

            end

            return false
        end 
    } ) )

    spec:RegisterStateTable( 'earth_elemental', setmetatable( { onReset = function( self ) self.cast_time = nil end }, {
        __index = function( t, k )
            if k == 'cast_time' then
                t.cast_time = class.abilities.earth_elemental.lastCast or 0
                return t.cast_time
            end

            local elem = talent.primal_elementalist.enabled and pet.primal_earth_elemental or pet.greater_earth_elemental

            if k == 'active' or k == 'up' then
                return elem.up

            elseif k == 'down' then
                return not elem.up

            elseif k == 'remains' then
                return max( 0, elem.remains )

            end

            return false
        end 
    } ) )


    local function natural_harmony( elem1, elem2, elem3 )
        if not azerite.natural_harmony.enabled then return end

        if elem1 then applyBuff( "natural_harmony_" .. elem1 ) end
        if elem2 then applyBuff( "natural_harmony_" .. elem2 ) end
        if elem3 then applyBuff( "natural_harmony_" .. elem3 ) end
    end

    setfenv( natural_harmony, state )


    local hadTotem = false
    local hadTotemAura = false

    spec:RegisterHook( "reset_precast", function ()
        for i = 1, 5 do
            local hasTotem, name = GetTotemInfo( i )

            if name == class.abilities.totem_mastery.name and hasTotem ~= up then
                ScrapeUnitAuras( "player" )
                return
            end
        end
        
        local hasTotemAura = FindUnitBuffByID( "player", 210652 ) ~= nil
        if hasTotemAura ~= hadTotemAura then ScrapeUnitAuras( "player" ) end

        if query_time - action.totem_mastery.lastCast < 3 then
            local dur = action.totem_mastery.lastCast + 120 - query_time
            applyBuff( "resonance_totem", dur )
            applyBuff( "tailwind_totem", dur )
            applyBuff( "storm_totem", dur )
            applyBuff( "ember_totem", dur )
            applyBuff( "totem_mastery", dur )
        end

        if talent.master_of_the_elements.enabled and action.lava_burst.in_flight and buff.master_of_the_elements.down then
            applyBuff( "master_of_the_elements" )
        end
    end )


    spec:RegisterGear( "the_deceivers_blood_pact", 137035 ) -- 20% chance; not modeled.
    spec:RegisterGear( "alakirs_acrimony", 137102 ) -- passive dmg increase.
    spec:RegisterGear( "echoes_of_the_great_sundering", 137074 )
        spec:RegisterAura( "echoes_of_the_great_sundering", {
            id = 208723, 
            duration =  10
        } )

    spec:RegisterGear( "pristine_protoscale_girdle", 137083 ) -- not modeled.
    spec:RegisterGear( "eye_of_the_twisting_nether", 137050 )
        spec:RegisterAura( "fire_of_the_twisting_nether", {
            id = 207995,
            duration = 8 
        } )
        spec:RegisterAura( "chill_of_the_twisting_nether", {
            id = 207998,
            duration = 8 
        } )
        spec:RegisterAura( "shock_of_the_twisting_nether", {
            id = 207999,
            duration = 8 
        } )

        spec:RegisterStateTable( "twisting_nether", setmetatable( {}, {
            __index = function( t, k )
                if k == 'count' then
                    return ( buff.fire_of_the_twisting_nether.up and 1 or 0 ) + ( buff.chill_of_the_twisting_nether.up and 1 or 0 ) + ( buff.shock_of_the_twisting_nether.up and 1 or 0 )
                end

                return 0
            end
        } ) )

    spec:RegisterGear( "uncertain_reminder", 143732 )


    -- Abilities
    spec:RegisterAbilities( {
        ancestral_guidance = {
            id = 108281,
            cast = 0,
            cooldown = 120,
            gcd = "spell",

            talent = 'ancestral_guidance',

            startsCombat = false,
            texture = 538564,

            handler = function ()
                applyBuff( 'ancestral_guidance' )
            end,
        },


        ancestral_spirit = {
            id = 2008,
            cast = 10.000215022888,
            cooldown = 0,
            gcd = "spell",

            spend = 0.04,
            spendType = "mana",

            startsCombat = false,
            texture = 136077,

            handler = function ()
            end,
        },


        ascendance = {
            id = 114050,
            cast = 0,
            cooldown = 180,
            gcd = "spell",

            toggle = 'cooldowns',
            talent = 'ascendance',

            startsCombat = false,
            texture = 135791,

            handler = function ()
                applyBuff( 'ascendance' )
                gainCharges( "lava_burst", 2 )
            end,
        },


        astral_recall = {
            id = 556,
            cast = function () return 10 * haste end,
            cooldown = 600,
            gcd = "spell",

            startsCombat = false,
            texture = 136010,

            handler = function ()
            end,
        },


        astral_shift = {
            id = 108271,
            cast = 0,
            cooldown = 90,
            gcd = "spell",

            startsCombat = false,
            texture = 538565,

            handler = function ()
                applyBuff( 'astral_shift' )
            end,
        },


        bloodlust = {
            id = 2825,
            cast = 0,
            cooldown = 300,
            gcd = "spell",

            spend = 0.22,
            spendType = "mana",

            startsCombat = false,
            texture = 136012,

            handler = function ()
                applyBuff( 'bloodlust' )
                applyDebuff( 'player', 'sated' )
            end,
        },


        capacitor_totem = {
            id = 192058,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            spend = 0.1,
            spendType = "mana",

            startsCombat = false,
            texture = 136013,

            handler = function ()
            end,
        },


        chain_lightning = {
            id = 188443,
            cast = function () return ( buff.tectonic_thunder.up or buff.stormkeeper.up ) and 0 or ( 2 * haste ) end,
            cooldown = 0,
            gcd = "spell",

            spend = function () return -4 * ( min( 5, active_enemies ) ) end,
            spendType = 'maelstrom',

            nobuff = 'ascendance',
            bind = 'lava_beam',

            startsCombat = true,
            texture = 136015,

            handler = function ()
                removeBuff( "master_of_the_elements" )

                if buff.stormkeeper.up then
                    gain( 2 * min( 5, active_enemies ), "maelstrom" )
                    removeStack( "stormkeeper" )
                else
                    removeBuff( "tectonic_thunder" )
                end

                if pet.storm_elemental.up then
                    addStack( "wind_gust", nil, 1 )
                end

                natural_harmony( "nature" )

                if level < 116 and equipped.eye_of_the_twisting_nether then applyBuff( "shock_of_the_twisting_nether" ) end
            end,
        },


        cleanse_spirit = {
            id = 51886,
            cast = 0,
            cooldown = 8,
            gcd = "spell",

            spend = 0.06,
            spendType = "mana",

            startsCombat = false,
            texture = 236288,

            handler = function ()
            end,
        },


        earth_elemental = {
            id = 198103,
            cast = 0,
            cooldown = 300,
            gcd = "spell",

            startsCombat = false,
            texture = 136024,

            handler = function ()
                summonPet( talent.primal_elementalist.enabled and "primal_earth_elemental" or "greater_earth_elemental", 60 )
            end,
        },


        earth_shield = {
            id = 974,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 0.1,
            spendType = "mana",

            talent = 'earth_shield',

            startsCombat = false,
            texture = 136089,

            handler = function ()
                applyBuff( 'earth_shield' )                
            end,
        },


        earth_shock = {
            id = 8042,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 60,
            spendType = "maelstrom",

            startsCombat = true,
            texture = 136026,

            handler = function ()
                if talent.exposed_elements.enabled then applyBuff( 'exposed_elements' ) end
                if level < 116 and equipped.eye_of_the_twisting_nether then applyBuff( "shock_of_the_twisting_nether" ) end
                if talent.surge_of_power.enabled then applyBuff( "surge_of_power" ) end

                natural_harmony( "nature" )
            end,
        },


        earthbind_totem = {
            id = 2484,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            startsCombat = true,
            texture = 136102,

            handler = function ()
            end,
        },


        earthquake = {
            id = 61882,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function () return buff.echoes_of_the_great_sundering.up and 0 or 60 end,
            spendType = "maelstrom",

            startsCombat = true,
            texture = 451165,

            handler = function ()
                removeBuff( "echoes_of_the_great_sundering" )
                removeBuff( "master_of_the_elements" )
                if level < 116 and equipped.eye_of_the_twisting_nether then applyBuff( "shock_of_the_twisting_nether" ) end
                natural_harmony( "nature" )
            end,
        },


        elemental_blast = {
            id = 117014,
            cast = function () return 2 * haste end,
            cooldown = 12,
            gcd = "spell",

            startsCombat = true,
            texture = 651244,

            handler = function ()
                applyBuff( 'elemental_blast' )

                if level < 116 and equipped.eye_of_the_twisting_nether then
                    applyBuff( "fire_of_the_twisting_nether" )
                    applyBuff( "chill_of_the_twisting_nether" )
                    applyBuff( "shock_of_the_twisting_nether" )
                end

                natural_harmony( "fire", "frost", "nature" )
            end,
        },


        far_sight = {
            id = 6196,
            cast = function () return 2 * haste end,
            cooldown = 0,
            gcd = "spell",

            startsCombat = true,
            texture = 136034,

            handler = function ()
            end,
        },


        fire_elemental = {
            id = 198067,
            cast = 0,
            charges = 1,
            cooldown = function () return ( essence.vision_of_perfection.enabled and 0.9 or 1 ) * 150 end,
            recharge = function () return ( essence.vision_of_perfection.enabled and 0.9 or 1 ) * 150 end,
            gcd = "spell",

            toggle = 'cooldowns',
            notalent = 'storm_elemental',

            startsCombat = false,
            texture = 135790,

            handler = function ()
                summonPet( talent.primal_elementalist.enabled and "primal_fire_elemental" or "greater_fire_elemental", 30 )
            end,
        },


        flame_shock = {
            id = 188389,
            cast = 0,
            cooldown = 6,
            gcd = "spell",

            startsCombat = true,
            texture = 135813,

            cycle = "flame_shock",
            min_ttd = function () return debuff.flame_shock.duration / 3 end,

            handler = function ()
                applyDebuff( 'target', 'flame_shock' )
                if buff.surge_of_power.up then
                    active_dot.surge_of_power = min( active_enemies, active_dot.flame_shock + 1 )
                    removeBuff( "surge_of_power" )
                end
                if level < 116 and equipped.eye_of_the_twisting_nether then applyBuff( "fire_of_the_twisting_nether" ) end
                natural_harmony( "fire" )
            end,
        },


        frost_shock = {
            id = 196840,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = true,
            texture = 135849,

            handler = function ()
                removeBuff( 'master_of_the_elements' )
                applyDebuff( 'target', 'frost_shock' )

                if buff.icefury.up then
                    gain( 8, "maelstrom" )
                    removeStack( "icefury", 1 )
                end

                if buff.surge_of_power.up then
                    applyDebuff( "target", "surge_of_power_debuff" )
                    removeBuff( "surge_of_power" )
                end

                if level < 116 and equipped.eye_of_the_twisting_nether then applyBuff( "chill_of_the_twisting_nether" ) end
                natural_harmony( "frost" )
            end,
        },


        ghost_wolf = {
            id = 2645,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = false,
            texture = 136095,

            handler = function ()
                applyBuff( 'ghost_wolf' )
                if talent.spirit_wolf.enabled then applyBuff( 'spirit_wolf' ) end
            end,
        },


        healing_surge = {
            id = 8004,
            cast = function () return 1.5 * haste end,
            cooldown = 0,
            gcd = "spell",

            spend = 0.2,
            spendType = "mana",

            startsCombat = false,
            texture = 136044,

            handler = function ()
            end,
        },


        hex = {
            id = 51514,
            cast = function () return 1.7 * haste end,
            cooldown = 30,
            gcd = "spell",

            startsCombat = false,
            texture = 237579,

            handler = function ()
                applyDebuff( 'target', 'hex' )
            end,
        },


        icefury = {
            id = 210714,
            cast = 1.9996204751587,
            cooldown = 30,
            gcd = "spell",

            spend = -25,
            spendType = 'maelstrom',

            startsCombat = true,
            texture = 135855,

            handler = function ()
                removeBuff( 'master_of_the_elements' )
                applyBuff( 'icefury', 15, 4 )
                natural_harmony( "frost" )
            end,
        },


        lava_beam = {
            id = 114074,
            cast = function () return 2 * haste end,
            cooldown = 0,
            gcd = "spell",

            spend = function () return -4 * ( min( 5, active_enemies ) ) end,
            spendType = 'maelstrom',

            buff = 'ascendance',
            bind = 'chain_lightning',

            startsCombat = true,
            texture = 236216,

            handler = function ()
                removeStack( 'stormkeeper' )
                if level < 116 and equipped.eye_of_the_twisting_nether then applyBuff( "fire_of_the_twisting_nether" ) end
                natural_harmony( "fire" )
            end,
        },


        lava_burst = {
            id = 51505,
            cast = function () return buff.lava_surge.up and 0 or ( 2 * haste ) end,
            charges = function () return talent.echo_of_the_elements.enabled and 2 or nil end,
            cooldown = function () return buff.ascendance.up and 0 or ( 8 * haste ) end,
            recharge = function () return buff.ascendance.up and 0 or ( 8 * haste ) end,
            gcd = "spell",

            spend = -10,
            spendType = "maelstrom",

            startsCombat = true,
            texture = 237582,

            handler = function ()
                removeBuff( "lava_surge" )
                if talent.master_of_the_elements.enabled then applyBuff( "master_of_the_elements" ) end
                if talent.surge_of_power.enabled then
                    gainChargeTime( "fire_elemental", 6 )
                    removeBuff( "surge_of_power" )
                end
                if level < 116 and equipped.eye_of_the_twisting_nether then applyBuff( "fire_of_the_twisting_nether" ) end
                natural_harmony( "fire" )
            end,
        },


        lightning_bolt = {
            id = 188196,
            cast = function () return buff.stormkeeper.up and 0 or ( 2 * haste ) end,
            cooldown = 0,
            gcd = "spell",

            spend = -8,
            spendType = "maelstrom",

            startsCombat = true,
            texture = 136048,

            handler = function ()
                removeBuff( "master_of_the_elements" )

                if buff.stormkeeper.up then
                    gain( 3, "maelstrom" )
                    removeStack( 'stormkeeper' )
                end

                if buff.surge_of_power.up then
                    gain( 3, "maelstrom" )
                    removeBuff( "surge_of_power" )
                end

                if pet.storm_elemental.up then
                    addStack( "wind_gust", nil, 1 )
                end

                if level < 116 and equipped.eye_of_the_twisting_nether then applyBuff( "shock_of_the_twisting_nether" ) end
                natural_harmony( "nature" )
            end,
        },


        lightning_lasso = {
            id = 305483,
            cast = 5,
            channeled = true,
            cooldown = 30,
            gcd = "spell",

            startsCombat = true,
            texture = 1385911,

            pvptalent = function ()
                if essence.conflict_and_strife.major then return end
                return "lightning_lasso"
            end,

            handler = function ()
                applyDebuff( "target", "lightning_lasso" )
            end,
        },


        liquid_magma_totem = {
            id = 192222,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            startsCombat = true,
            texture = 971079,

            handler = function ()
            end,
        },


        purge = {
            id = 370,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 0.1,
            spendType = "mana",

            startsCombat = true,
            texture = 136075,

            handler = function ()
            end,
        },


        storm_elemental = {
            id = 192249,
            cast = 0,
            charges = 1,
            cooldown = function () return ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * 150 end,
            recharge = function () return ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * 150 end,
            gcd = "spell",

            toggle = 'cooldowns',
            talent = 'storm_elemental',

            startsCombat = true,
            texture = 2065626,

            handler = function ()
                summonPet( talent.primal_elementalist.enabled and "primal_storm_elemental" or "greater_storm_elemental", 30 )
            end,
        },


        stormkeeper = {
            id = 191634,
            cast = function () return 1.5 * haste end,
            cooldown = 60,
            gcd = "spell",

            talent = 'stormkeeper',

            startsCombat = false,
            texture = 839977,

            handler = function ()
                applyBuff( 'stormkeeper', 20, 2 )
            end,
        },


        thunderstorm = {
            id = 51490,
            cast = 0,
            cooldown = 45,
            gcd = "spell",

            startsCombat = true,
            texture = 237589,

            handler = function ()
                if target.within10 then applyDebuff( 'target', 'thunderstorm' ) end
            end,
        },


        totem_mastery = {
            id = 210643,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            talent = 'totem_mastery',
            essential = true,

            startsCombat = false,
            texture = 511726,

            readyTime = function () return buff.totem_mastery.remains - 15 end,
            usable = function () return query_time - action.totem_mastery.lastCast > 3 end,
            handler = function ()
                applyBuff( 'resonance_totem', 120 )
                applyBuff( 'storm_totem', 120 )
                applyBuff( 'ember_totem', 120 )
                if buff.tailwind_totem.down then stat.spell_haste = stat.spell_haste + 0.02 end
                applyBuff( 'tailwind_totem', 120 )
                applyBuff( 'totem_mastery', 120 )
            end,
        },


        tremor_totem = {
            id = 8143,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            spend = 0.02,
            spendType = "mana",

            startsCombat = true,
            texture = 136108,

            handler = function ()
            end,
        },


        --[[ wartime_ability = {
            id = 264739,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = true,
            texture = 1518639,

            handler = function ()
            end,
        }, ]]


        water_walking = {
            id = 546,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = false,
            texture = 135863,

            handler = function ()
                applyBuff( 'water_walking' )
            end,
        },


        wind_rush_totem = {
            id = 192077,
            cast = 0,
            cooldown = 120,
            gcd = "spell",

            talent = 'wind_rush_totem',

            startsCombat = false,
            texture = 538576,

            handler = function ()                
            end,
        },


        wind_shear = {
            id = 57994,
            cast = 0,
            cooldown = 12,
            gcd = "spell",

            startsCombat = true,
            texture = 136018,

            toggle = 'interrupts',

            debuff = "casting",
            readyTime = state.timeToInterrupt,

            handler = function ()
                interrupt()
            end,
        },


        -- Pet Abilities
        meteor = {
            id = 117588,
            known = function () return talent.primal_elementalist.enabled and not talent.storm_elemental.enabled and fire_elemental.up end,
            cast = 0,
            cooldown = 60,
            gcd = "off",

            startsCombat = true,
            texture = 1033911,

            talent = "primal_elementalist",

            usable = function () return fire_elemental.up end,
            handler = function () end,
        },

        eye_of_the_storm = {
            id = 157375,
            known = function () return talent.primal_elementalist.enabled and talent.storm_elemental.enabled and storm_elemental.up end,
            cast = 0,
            cooldown = 40,
            gcd = "off",

            startsCombat = true,
            -- texture = ,

            talent = "primal_elementalist",

            usable = function () return storm_elemental.up and buff.call_lightning.remains >= 8 end,
            handler = function () end,
        },
    } )


    spec:RegisterPack( "Elemental", 20190722, [[dev(0bqiHWJesCjsrPnjL8jHiAuGuNcQyvKI8kfrZskv3sPODrYVuegMsHJbswgujptiPPjLsxtiQTrkQ(MqKmoOsHZbvkToOsrVJuueMhi09uK2huL(hiqQoiiqTqHupeeuMiiGUOuk2iPOWhbbvnsqGuojiaRee9ssrrntqqUjufStff)eeigkufAPGGkpLunvfLUQqK6RGajJLuuKolPOiAVk5VkmyrhMYIrQhlyYq5YQ2mO(SqnAP40O8AfvZg42s1UL8BidxP64cry5iEoQMoX1rY2HQ67kLgpuP68KcRhQIMpP0(P6fuRzx6yM81m4AdOWTBePWfUuBSrBXTrg3yPlAS)L(UfMBXFPxw)l92aE)LyGL(UPbazyRzx6Cefj8LEJi7CCZjMiMjnu0QaQpbN1PaMWqvGyWYeCwpmXsNMIbeiGArV0Xm5RzW1gqHB3isHlCP2yJ2IBBRMV057pSMbxAoUw6nmmSxl6Lo25HLEu8SnG3FjgWt9gRBLdzu8SrKDoU5eteZKgkAva1NGZ6uatyOkqmyzcoRhMWHmkEcjfqdpXfuT7jU2akCRNB6jUGc3eQiLdPdzu8ecRXQ4ZXnDiJINB6zKMFp1mDCW7VedOO29KysZjEknw5zO5H5Sk2ZacbWqBlUNcYt(VNmypp49xIb4EAK7Pfeg(x5qgfp30tiqg3ObhZZ2yePXZ2aE)LyapFje25khYO45MEcH7De(3tiyE4fMvH7PW6FIOHqEgAEyUYHmkEUPNqWyyE2gnUNiypLM7PUGiDpNWt8WLJiQL(obbZaFPhfpBd49xIb8uVX6w5qgfpBezNJBoXeXmPHIwfq9j4SofWegQcedwMGZ6HjCiJINqsb0WtCbv7EIRnGc365MEIlOWnHks5q6qgfpHWASk(CCthYO45MEgP53tnthh8(lXakQDpjM0CINsJvEgAEyoRI9mGqam02I7PG8K)7jd2ZdE)LyaUNg5EAbHH)voKrXZn9ecKXnAWX8SngrA8SnG3FjgWZxcHDUYHmkEUPNq4EhH)9ecMhEHzv4EkS(NiAiKNHMhMRCiJINB6jemgMNTrJ7jc2tP5EQlis3Zj8epC5iIYH0HmkE2gC)bk5yEsFye5EgqDAt8K(XSIR8ecoe(UW9Sq1MngPdtb80ccdvCprfqdLdzu80ccdvC1o5buN2KPWaJp3HmkEAbHHkUAN8aQtBYKtNagHWCiJINwqyOIR2jpG60Mm50jmQ4(lXegQCiJIN6LTZBqINeJH5jnfm8X8KlMW9K(WiY9mG60M4j9Jzf3tRW8CN8n3rIWQypzCpXq1voKrXtlimuXv7KhqDAtMC6e8Y25nizWft4oKwqyOIR2jpG60Mm50jeK8(OBC5enCiJINwqyOIR2jpG60Mm50jUrKMXbV)smq7m4Prig4LO2jSUbgh8(lXamUOEz0GJ5q6qgfpJ087PUGi95)7N45o5buN2epPkW5Cp5O(90WW4EULbaEY3TTLNCeQuoKwqyOIR2jpG60Mm50j4cI0N)VFs7m4PIbEjkUGi95)7NOEz0GJ1cAIXWgh)xIYWW4QaIQeigvTAjgdBC8FjkddJRyfEJ8g44q6qAbHHkUAN8aQtBYKtNaMr(4G3FjgODg80ied8suCbr6JdE)Lya1lJgCmhslimuXv7KhqDAtMC6eCbr6JdE)LyG2zWtfd8suCbr6JdE)Lya1lJgCmhslimuXv7KhqDAtMC6e7iHHkhslimuXv7KhqDAtMC6eh8(lXadAGXL2zWtfd8suh8(lXadAGXf1lJgCmhslimuXv7KhqDAtMC6eadFBqtr4s7m4Prig4LOo49xIbg0aJlQxgn4yT47hagIrIVWvHgJvdalUrkwfdXO6qAbHHkUAN8aQtBYKtNi0ySAayXnsXQ42zWt57hagIrIVWvHgJvdalUrkwfJxC5q6qgfpBdU)aLCmpp(NOHNcRFpLM7PfeeXtg3tdFJbmAWvoKrXtimJlEgnaHWauCXZUvugaOHNmypLM7jemEEctUNZsmM4jeCfoxigWtiCNJkRc3tg3ZDY5VeLdPfegQ4tPbiegGIlTZGNA45jm5kRcNledmiNJkRcx9YObhZHmkEcbuBgqDAt8Chjmu5jJ75o5WN8sygaOHNawn)yEkip1arr8SnG3FjgODpPkW5CpdOoTjEULbaE(cZtEdIianCiTGWqfFYPtSJegQANbp94((dYXgbuN2Kb4vS0SPW6hIrDdTAHzKpo49xIbuu7A1YfePpo49xIbuu7oKrXtiGsoHqTlEIG9myCHRCiTGWqfFYPtSLvydEZnIdPfegQ4toDcbjVp6gxorJ2zWtfd8sucsEF0nUCIgQxgn4yTOPGHvKZrLvHpeK8UI8UXkoeXLdPfegQ4toDck(hm5DUdPfegQ4toDcyg5JdE)LyG2zWtJqmWlrXfePpo49xIbuVmAWXCiTGWqfFYPtWfePpo49xIbANbpvmWlrXfePpo49xIbuVmAWXAbDeIbEjkw4WuenuVmAWX0QncAkyyflCykIgkQ9wreqiagABPyHdtr0qrTJtlOJqmWlrz8WlmRcx9YObhtR2icieadTTugp8cZQWvu744qgfpTGWqfFYPtCJinJdE)LyG2zWtJqmWlrTtyDdmo49xIbyCr9YObhtRwXaVe1oH1nW4G3FjgGXf1lJgCSwqdZiFCW7VedOWqBRwrig4LO4cI0hh8(lXaQxgn4yA1YfePpo49xIbuyOTvlXaVefxqK(4G3Fjgq9YObhdhhslimuXNC6ebufEjeto2agy97qAbHHk(KtNGgGqyde8qA(417A4qAbHHk(KtNiMYiymRgi4HHNNGKghslimuXNC6eWOaf)yddppHjFqFR7qAbHHk(KtNyNIWG1GvXdAGXfhslimuXNC6esZhufnIQWgWis4oKwqyOIp50j6VJiAmqWdavGHnWi36ChslimuXNC6ee2(o4dwn47w4oKwqyOIp50j2Iiam8pRgKZrLvH7qAbHHk(KtNGgGqydykIgTZGNgHyGxIY4HxywfU6LrdoMwT0uWWkJhEHzv4kQDTAdieadTTugp8cZQWvK3nwXXBK3WH0ccdv8jNob9j8tMZQ42zWtJqmWlrz8WlmRcx9YObhtRwAkyyLXdVWSkCf1UdPfegQ4toDcyg50aecRDg80ied8sugp8cZQWvVmAWX0QLMcgwz8WlmRcxrTRvBaHayOTLY4HxywfUI8UXkoEJ8goKwqyOIp50jSkCUqmWiyaq7m4Prig4LOmE4fMvHREz0GJPvlnfmSY4HxywfUIAxR2acbWqBlLXdVWSkCf5DJvC8g5nCiTGWqfFYPtCn(abpKMp4cI0BNbpLlisFCW7VedOO2BrtbdRcgamaS4gPyvSI8UXkoENIB4qAbHHk(KtNOF5iIdPfegQ4toDccvnSGWq1aW4s7L1)ud92zWtTGWW)JxVZohV4Qf089dadXiXx4QqJXQbGf3ifRIXlU0QLVFayigj(cxbm8Tb9ToEXfooKwqyOIp50jiu1WccdvdaJlTxw)t5Skg8HyK4loKoKrXt8afqyEkgj(INwqyOYZDcdryIgEcyCXH0ccdvCLH(uUGi95)7N0odEQyGxIIlisF()(jQxgn4yoKrXt9DYnmp1maw)EQ3GcZ9KvEcXPE2wpfJeFXtywCJWB3tAkXZcjEIrryvSN6TXtQDH1F7uf4CUNAGOIKK7jmlUryvSNr1tXiXx4EAfMNng(3tW5CpLgR8eQ26jeuScZti8uCXtUyH5CLdPfegQ4kd9jNobmW6FWBqH5Th0ia(qms8f(uOANbpLCyY5ngn4TGMVFayigj(cxfAmwnaS4gPyvmeHoYBgHyGxIsqY7JUXLt0q9YObhdhTAJqmWlrXfePpo49xIbuVmAWXAbnmJ8XbV)smGI8UXkoEHgQ2Qj((bGrJXLJJwTbecGH2wkyg5JdE)Lyaf5DJvCicnUA7Mq1wnX3pamAmUCCWbNwqhHyGxIIlisFCW7VedOEz0GJPvlxqK(4G3FjgqHH2wA1Y3pameJeFHRcngRgawCJuSkEAuBrtbdR2YkSrmfxuCXcZHiuTfhhslimuXvg6toDcJhEHzv4TZGNkg4LOmE4fMvHREz0GJ1cAXaVefxqK(4G3Fjgq9YObhRfxqK(4G3FjgqHH2wTcieadTTuCbr6JdE)Lyaf5DJvC8cvK1QncXaVefxqK(4G3Fjgq9YObhdNwqhHyGxIIfomfrd1lJgCmTAJGMcgwXchMIOHIAVvebecGH2wkw4Wuenuu744qAbHHkUYqFYPtayrckg2OBXDBii592zWtfd8suawKGIHn6wC3gcsEx9YObhZH0HmkEolrdpfKNXw)E2gJinrckB(9CltA8epyC5eprWEkn3Z2aE)LW9KMcg2ZTnV8eMf3iSk2ZO6PyK4lCLNqGOkskEIW)KGT7jEWoGleupchslimuXvg6toDIBePjsqzZF7m4Prig4LO6gxozGGhsZhh8(lHREz0GJPvlnfmSIlisF()(jkQDTA72bCHG64Dk0qTXgB2wnX3pameJeFHRcngRgawCJuSkghTAPPGHvDJlNmqWdP5JdE)LWvu7A1Y3pameJeFHRcngRgawCJuSkgVr1H0HmkEIhS53tof5EQbIYtmufjfpbi(908uxqK(8)9tuoKwqyOIRm0NC6eHgJvdalUrkwf3odEknfmSIlisF()(jkY7gR4qmQAkoGPjAkyyfxqK(8)9tuCXcZDiDiJINqqkGgEgmU4jeYW38mAkcx8evEknKFpfJeFH7jd2tM4jJ7PvEYkUyL4PvyEQlis3Z2aE)LyapzCpNbcYSEAbHH)voKwqyOIRm0NC6eadFBqtr4s7m4P0uWWkGHVn4uK4RO2BX3pameJeFHRcngRgawCJuSkgITTf0rig4LO4cI0hh8(lXaQxgn4yA1YfePpo49xIbuyOTfoTWqIcgy9p4nOWCLWcZzvSdPfegQ4kd9jNoblCykIgTZGNY3pameJeFHRcngRgawCJuSkgITTve0uWWkJhEHzv4kQDhslimuXvg6toDcycIldEdkmVDg8u((bGHyK4lCvOXy1aWIBKIvXqSTTOPGHvSWHPiAOO2BfbnfmSY4HxywfUIA3H0HmkEgP53Z2aE)LyapJgyCXtl2yfx8KA3tb5zu9ums8fUNg3taQI904EQlis3Z2aE)LyapzCplK4Pfeg(x5qAbHHkUYqFYPtCW7VedmObgxANbpvmWlrDW7VedmObgxuVmAWXAX3pameJeFHRcngRgawCJuSkgITTf0rig4LO4cI0hh8(lXaQxgn4yA1YfePpo49xIbuyOTfooKwqyOIRm0NC6eadFBqFR3odEQyGxIY4HxywfU6LrdoMdPfegQ4kd9jNorOXy1aWIBKIvXoKwqyOIRm0NC6eadFBqtr4s7De(SkEkuTZGNkg4LOmE4fMvHREz0GJ5qAbHHkUYqFYPtadS(h8guyE7De(SkEkuTh0ia(qms8f(uOANbpLCyY5ngn4oKwqyOIRm0NC6eWeexg8guyE7De(SkEkuoKoKrXtDwfdUNZAK4lEcbhegQ8epsyict0WtieJloKrXZ2uCkY9uZq3tg3tlim8VNuf4CUNAGO8SXW)EcvB9er8SJi3tUyH5CprWEcbfRW8ecpfx8eMG6EQlis3Z2aE)LyaLNq3gS47zW4h30tQ9aQZQypHG5bpPPepTGWW)EQ3gnt4jgQIKIN44qAbHHkUIZQyWhIrIVmfgy9p4nOW82dAeaFigj(cFkuTZGNcDeclmNvXA1kg4LO4cI0hh8(lXaQxgn4yTcieadTTuCbr6JdE)Lyaf5DJvCiIlnfhW0QfdjkyG1)G3GcZvK3nwXH404aMwTIbEjkJhEHzv4Qxgn4yTWqIcgy9p4nOWCf5DJvCicDaHayOTLY4HxywfUI8UXk(K0uWWkJhEHzv4kmkIjmuHtRacbWqBlLXdVWSkCf5DJvCi22wqhHyGxIIlisFCW7VedOEz0GJPvRyGxIIlisFCW7VedOEz0GJ1IlisFCW7VedOWqBlCWPf00uWWQTScBetXffxSWCicvB1Q1WZtyYvS46ik(yhjVeMbueRMJ3P4sRwAkyyfWW3gCks8vu7A1gbnfmSIgGqyakUOO2XPve0uWWkofj(de8yhT9ef1UdPdzu8msZVNqW8WlmRc3tdwoXtnqurs8VN89xINga4jeYW38mAkcx8m0yK4Z90kmprfqdpzWEwNjnN4PUGiDpBd49xIb8SqepHachMIOHNg5EgOiKxcqdpTGWW)khslimuXvCwfd(qms8LjNoHXdVWSk82zWtfd8sugp8cZQWvVmAWXAfqiagABPag(2GMIWff5DJvC8UrlO5cI0hh8(lXakm02sR2ied8suCbr6JdE)Lya1lJgCmCAbDeIbEjkw4WuenuVmAWX0QncAkyyflCykIgkQ9wreqiagABPyHdtr0qrTJJdPdzu8ecevrsXtk(9SnG3FjgWZObgx8Kb7PgikpdikaMNbJlEAEIhmUCINiypLM7zBaV)s4E((oA7jhZZ2yePXt9guyUNSIl3WuEcbIQiP4zW4INTb8(lXaEgnW4INyuewf7PUGiDpBd49xIb8KQaNZ9udeLNng(3ZOI7EoJjued4je0mshvAO8mAkXtw5P0W4Egm(9KlODpP4Sk2Z2aE)LyapJgyCXtufUNAGO8KCl04juT1tUyH5CprWEcbfRW8ecpfxuoKwqyOIR4Skg8HyK4ltoDIdE)LyGbnW4s7m4PIbEjQdE)LyGbnW4I6LrdowlOfd8suDJlNmqWdP5JdE)LWvVmAWXArtbdR6gxozGGhsZhh8(lHRO2B1Td4cb1HOMVHwTrig4LO6gxozGGhsZhh8(lHREz0GJHtlOJaAUGi9XbV)smGIAVLyGxIIlisFCW7VedOEz0GJHJwTgEEctUQmHIyGrJr6OsdfXQ5tJAlAkyy1wwHnIP4IIlwyoeHQT44q6qgfp1m)V7PUMzpHrepbgj(EIiEYrOYtddZZTg(NR8msxGZ5EQbIYZgd)7Pofj(EIG9epI2Es7EYkp32WcnEgm(9udeLNBTs8uqEIHOOb3tAkyypHqS4gPyvSNrJaIN0A45ocbyvSN4b7aUqqDpPpmI8gRWuE2gC367G7j)rcQxHJB6juBSbEqVDpBJE7EQRzUDpHqr3UNqi8JUDpBJE7EcHI2H0ccdvCfNvXGpeJeFzYPtWfePp)F)K2zWtfd8suCbr6Z)3pr9YObhRf0eJHno(VeLHHXvbevjqmQA1smg244)sugggxXk8g5nWPf0rig4LO4uK4pqWJD02tuVmAWX0QLMcgwXPiXFGGh7OTNOO21QTBhWfcQJ3PTTT44q6qAbHHkUIZQyWhIrIVm50jaSibfdB0T4UneK8E7m4PIbEjkalsqXWgDlUBdbjVREz0GJ1cAIXWgh)xIYWW4QaIQeigvTAjgdBC8FjkddJRyfEJ8g44q6qgfpHWqDAwDp1fePp)F)ep3YKgpXdgxoXteSNsZ9SnG3FjCprep1PiX3teSN4r02t8KQaNZ9udeLNng(3tP5EcHm8np1BqH5EkeJjEAfMNDkGW2b3tUyH5CLdPfegQ4koRIbFigj(YKtNaWIBKIvXdAeqANbpLMcgwXfePp)F)ef1El((bGHyK4lCvOXy1aWIBKIvXqexTG2WZtyYvadFBWBqH5kIvZ1enfmScy4BdEdkmxXflmhhiIlnVf00uWWQUXLtgi4H08XbV)s4kQ9wrig4LO4uK4pqWJD02tuVmAWX0QLMcgwXPiXFGGh7OTNOO2XXH0HmkEgP53Z2yePjsqzZVN4FcNI7jU8ums8fE7EsvGZ5EQbIYZgd)7jeYW38uVbfMR8msZVNTXistKGYMFpX)eof3tO8ums8fpzWEQbIYZgd)75SpiOIf8C2gQc7epJQNcRFUNwH55mqq8uNIeFprWEIhrBpXZxgn4yEAfMNZabXtiKHV5PEdkmx5qAbHHkUIZQyWhIrIVm50jUrKMibLn)TZGNcnF)aWqms8fUk0ySAayXnsXQy8cLwTgEEctUsEqqflmKgQc7efXQ54DAuBfHyGxIItrI)abp2rBpr9YObhRLHNNWKRag(2G3GcZveRMdrOWPLHNNWKRag(2G3GcZveRMRjAkyyfWW3g8guyUIlwyoeHoQA(KrvtgEEctUsEqqflmKgQc7efXQ5AIVFayigj(cxfAmwnaS4gPyvmoTGocXaVefNIe)bcESJ2EI6LrdoMwTrGHefmW6FWBqH5kYHjN3y0GRvlxqK(4G3FjgqrTJtlOJqmWlr1nUCYabpKMpo49xcx9YObhtRwAkyyv34Yjde8qA(4G3FjCf1UwTbecGH2wkGHVnOPiCrrE3yfhVB0QBhWfcQJ3P4wCnzu3qtIbEjQGbadP5dPHQWor9YObhdhhshYO4jeMXfpBJrKgp1BqH5EULjnEIhmUCINiypLM7zBaV)s4Ekg4L4jnL4zH80ccd)7Pofj(EIG9epI2EIN0uWWT7PvyEAbHH)9uxqK(8)9t8KMcg2tRW8ecz4BEgnfHlEgqDwf7jcg2timiqp3YKgw5P0CpRJ7INq4HWGaB3tRW88mP5epTGWW)EIhmUCINiypLM7zBaV)s4Estbd3UNiINfYtdFJbmAW9ecz4BEgnfHlEUTHbUN1nIN4bDpd2E7EIiEYzvm4Ekgj(INwH5zNciSDW9ecz4BEQ3GcZ9uigt4EAfMNDR0WtUyH5CLdPfegQ4koRIbFigj(YKtN4grAg8guyE7m4PrqtbdR4uK4pqWJD02tuu7Ted8suDJlNmqWdP5JdE)LWvVmAWXAbnnfmSQBC5KbcEinFCW7VeUIAxR2acbWqBlfWW3g0ueUOiVBSIJ3nA1Td4cb1X7uClUMmQBOjXaVevWaGH08H0qvyNOEz0GJPvlF)aWqms8fUk0ySAayXnsXQyiIRwqB45jm5kGHVn4nOWCfXQ5AIMcgwbm8TbVbfMR4IfMdrCP540IMcgwXfePp)F)ef1ERacbWqBlfWW3g0ueUOiVBSIdXPXbmCCiDiJINAMer558cT1ZTnMabDpHa8SXW8KJ63tEdIiEECFhyLjmu5zZj3tufUYZOPepLMxEkn3ZaQWycdvEgt(2290kmpHa8SXW8uqEY3bmXtP5EIQ7zBmI04PEdkm3taRUNSsqEcJOikLIJ8udeLNng(3tb5j2nGNBzsJNsdJ7PrJ6SYegQ8SqBXn9ecZ4INTXisJN6nOWCp3YKgeL4jEW4YjEIG9uAUNTb8(lH7PyGxs7EAfMNBzsdIs8SXWNvXEke2o4EcbexhrX9epIKxcZaEAfMNwqy4FpHG5HxywfE7EAfMNwqy4Fp1fePp)F)epPPGH9er8SUr8epO7zW2B3teXtDbr6E2gW7Ved4jJ7jRSGWW)T7PvyEU9EgSkskEECF)bXtb5z8fpTYtddJjmuzapP43teSN6cI09SnG3FjgWtw5P0CpjVBSIvXEcZIBepHjOUN6uK47jc2t8iA7jkhslimuXvCwfd(qms8LjNoXnI0m4nOW82zWtJqmWlr1nUCYabpKMpo49xcx9YObhRveqB45jm5kwCDefFSJKxcZakIvZXlUArtbdRmE4fMvHRO2XPf00uWWkUGi95)7NOO21QTBhWfcQJ3P42nMmQBOjXaVevWaGH08H0qvyNOEz0GJPvBeqZfePpo49xIbuu7Ted8suCbr6JdE)Lya1lJgCmCADCF)b5yJaQtBYa8kwA2uy9VzaHayOTLIlisFCW7VedOiVBSIVjurEdnbdqic0qFCF)b5yJaQtBYa8kwA2uy9VzaHayOTLIlisFCW7VedOiVBSIJJMfQiVbo4DAu3qtqd1KqB45jm5QhAqde8qA(4G3FjgGRiwnhVtXfo4GJdPdzu8msZVNTXisJN6nOWCpzWEQtrIVNiypXJOTN4jJ7PyGxYXA3tAkXZ6mP5epzINfI4P5jeiEu3Z2aE)LyapzCpTGWW)EAINsZ9SJ6VK290kmpHqg(MNrtr4INmUNKByA4jI45wga4j99KCdtdp3YKgw5P0CpRJ7INq4HWGavoKwqyOIR4Skg8HyK4ltoDIBePzWBqH5TZGNkg4LO4uK4pqWJD02tuVmAWXAfbnfmSItrI)abp2rBprrT3kGqam02sbm8TbnfHlkY7gR4qCACaRf0rig4LO4cI0hh8(lXaQxgn4yTIaAyg5JdE)Lyaf1ooA1kg4LO4cI0hh8(lXaQxgn4yTIaAUGi9XbV)smGIAhhCCiTGWqfxXzvm4dXiXxMC6eawCJuSkEamoh5q6qgfp13TUNqiwCJuSk2ZOraH7jgfHvXEQlis3Z2aE)LyapXOiMWqv7EYG9udeLNyOkskE2y4FpHaIRJO4EIhrYlHzaprepBm8VNmXtub0WtufE7EAfMNyOkskEsXVNqiwCJuSk2ZOraXtmkcRI9mAacHbO4INmyp1ar5zJH)908ecz4BEQtrIVN4rckOCiTGWqfxXzvm4dXiXxMC6eawCJuSkEqJas7m4PCbr6JdE)Lyaf1ElXaVefxqK(4G3Fjgq9YObhRf0gEEctUIfxhrXh7i5LWmGIy1CiIlTAJGMcgwbm8TbNIeFf1ElAkyyfnaHWauCrrTJJdPdzu8ecZ4INqiwCJuSk2ZOraXtYJncg4CUNiypLM75o54ZquCpdOcJjmu5jd2tnqursmpbi(908uxqK(8)9t8KlwyUNiINng(3tDbr6Z)3pXtRW8epyC5eprWEkn3Z2aE)LW90ccd)RCiTGWqfxXzvm4dXiXxMC6eawCJuSkEqJas7m4PqttbdR4cI0N)VFII8UXkoeHsbLMIdyAIMcgwXfePp)F)efxSWCTAPPGHvCbr6Z)3prrT3IMcgw1nUCYabpKMpo49xcxrTJJdPdzu8msZVNAgeex8uVbfM75wM04jeq4Wuen80kmpXdgxoXteSNsZ9SnG3FjCLdPfegQ4koRIbFigj(YKtNaMG4YG3GcZBNbpvmWlrXchMIOH6LrdowlXaVev34Yjde8qA(4G3FjC1lJgCSw0uWWkw4Wuenuu7TOPGHvDJlNmqWdP5JdE)LWvu7oKoKwqyOIR4Skg8HyK4ltoDcGHVnOPiCPDg8uAkyyLXdVWSkCf1UdPdzu8mslmadpVN6uK47jc2t8iA7jEkip57KByEQzaS(9uVbfM7jd2Zofqy7G75R3zN7PrUN7KZFjkhslimuXvCwfd(qms8LjNobmW6FWBqH5Th0ia(qms8f(uOANbpLCyY5ngn4TSGWW)JxVZohVq1IMcgwXPiXFGGh7OTNOO2DiDiJINrA(9ecz4BEgnfHlEULjnEQtrIVNiypXJOTN4jd2tP5EcmU45osEjmd4jf3IVNiyp1feP7zBaV)smGNngVIKINMNWuaGNyuetyOYtiiq48Kb7PgikpdikaMNXx80kK0CINuCl(EIG9uAUNqG4rDpBd49xIb8Kb7P0CpjVBSIvXEcZIBep3ACpHsZ1SEcqv8jkhslimuXvCwfd(qms8LjNobWW3g0ueU0odEQyGxIIlisFCW7VedOEz0GJ1kGqam02AqUfKw0uWWkofj(de8yhT9ef1ElOpUV)GCSra1PnzaEflnBkS(3mGqam02sXfePpo49xIbuK3nwX3eQiVHMGbiebAOpUV)GCSra1PnzaEflnBkS(3mGqam02sXfePpo49xIbuK3nwXXrZcvK3ahig1n0e0qnj0gEEctU6Hg0abpKMpo49xIb4kIvZX7uCHdoA1cnukO0Cnb9X99hKJncOoTjdWRyPztH1poBgqiagABP4cI0hh8(lXakY7gR4BcvK3qtWaeIan0qPGsZ1e0h33Fqo2iG60MmaVILMnfw)4SzaHayOTLIlisFCW7VedOiVBSIJJMfQiVbo4arOpUV)GCSra1PnzaEflnBkS(3mGqam02sXfePpo49xIbuK3nwX3eQiVHMGbiebAOpUV)GCSra1PnzaEflnBkS(3mGqam02sXfePpo49xIbuK3nwXXrZcvK3ahCWXH0HmkEgP53tiKHV5z0ueU45wM04Pofj(EIG9epI2EINmypLM7jW4IN7i5LWmGNuCl(EIG9uZGrUNTb8(lXaE2y8kskEAEctbaEIrrmHHkpHGaHZtgSNAGO8mGOayEgFXtRqsZjEsXT47jc2tP5EcbIh19SnG3FjgWtgSNsZ9K8UXkwf7jmlUr8CRX9eknxZ6javXNOCiTGWqfxXzvm4dXiXxMC6eadFBqtr4s7m4Prig4LO4cI0hh8(lXaQxgn4yTcieadTTgKBbPfnfmSItrI)abp2rBprrT3c6J77pihBeqDAtgGxXsZMcR)ndieadTTuWmYhh8(lXakY7gR4BcvK3qtWaeIan0h33Fqo2iG60MmaVILMnfw)BgqiagABPGzKpo49xIbuK3nwXXrZcvK3ahig1n0e0qnj0gEEctU6Hg0abpKMpo49xIb4kIvZX7uCHdoA1cnukO0Cnb9X99hKJncOoTjdWRyPztH1poBgqiagABPGzKpo49xIbuK3nwX3eQiVHMGbiebAOHsbLMRjOpUV)GCSra1PnzaEflnBkS(XzZacbWqBlfmJ8XbV)smGI8UXkooAwOI8g4GdeH(4((dYXgbuN2Kb4vS0SPW6FZacbWqBlfmJ8XbV)smGI8UXk(Mqf5n0emaHiqd9X99hKJncOoTjdWRyPztH1)MbecGH2wkyg5JdE)Lyaf5DJvCC0Sqf5nWbhCCiDiTGWqfxXzvm4dXiXxMC6eawCJuSkEqJas7m4P0uWWkofj(de8yhT9ef1UdPfegQ4koRIbFigj(YKtNay4BdAkcxANbpnGqam02AqUfKwrig4LO6gxozGGhsZhh8(lHREz0GJ5q6qgfp1bS4gbOHNXw)EcbeomfrdpPPGH9uqE2G2pmfaOHN0uWWEYr97577OTNCmp1miiU4PEdkmN75wM04jEW4YjEIG9uAUNTb8(lHRCiTGWqfxXzvm4dXiXxMC6eSWHPiA0odEQyGxIIfomfrd1lJgCSwraD3oGleuhVrQi3kGqam02sbm8TbnfHlkY7gR4qC6g40c6ied8suCbr6JdE)Lya1lJgCmTA5cI0hh8(lXakm02chhshslimuXvCwfd(qms8LjNobWW3g0ueU0odEAaHayOT1GCliTcngj(C8kg4LOEObnqWdP5JdE)LWvVmAWXCiDiJIN6awCJa0WtSdmn8KIZQypHachMIOHNVVJ2EYX8uZGG4IN6nOWCUNcYZ33rBpXtP5Dp3YKgpXdgxoXteSNsZ9SnG3FjCpfes5qAbHHkUIZQyWhIrIVm50jGjiUm4nOW82zWtfd8suSWHPiAOEz0GJ1IMcgwXchMIOHIAVfnfmSIfomfrdf5DJvCicLcknfhW0enfmSIfomfrdfxSWChshslimuXvCwfd(qms8LjNobWW3g0ueU0odEAaHayOT1GClioKoKrXtiqufjfpTqGH9smaqdpP43tDks89eb7jEeT9ep3YKgp1maw)EQ3GcZ9eJIWQyp5SkgCpfJeFr5qAbHHkUIZQyWhIrIVm50jGbw)dEdkmV9GgbWhIrIVWNcv7m4PKdtoVXObVve0uWWkofj(de8yhT9ef1UdPfegQ4koRIbFigj(YKtNqqY7JUXLt0ODg8uXaVeLGK3hDJlNOH6LrdowlOPPGHvKZrLvHpeK8UI8UXkoe1CTAHMMcgwrohvwf(qqY7kY7gR4qeAAkyyLXdVWSkCfgfXegQMmGqam02sz8WlmRcxrE3yfhNwbecGH2wkJhEHzv4kY7gR4qeQiJdooKoKwqyOIR4Skg8HyK4ltoDcycIldEdkmVDg8uXaVeflCykIgQxgn4yTOPGHvSWHPiAOO2BbnnfmSIfomfrdf5DJvCighW0uB1enfmSIfomfrdfxSWCTAPPGHvCbr6Z)3prrTRvBeIbEjQUXLtgi4H08XbV)s4Qxgn4y44qAbHHkUIZQyWhIrIVm50jcngRgawCJuSkUDg8uAkyyL8GGkwyinuf2jkQ9wrqtbdR4cI0N)VFIIAVfF)aWqms8fUk0ySAayXnsXQy8cLdPfegQ4koRIbFigj(YKtNaWIBKIvXdAeqCiTGWqfxXzvm4dXiXxMC6eWaR)bVbfM3EhHpRINcv7bncGpeJeFHpfQ2zWtjhMCEJrdUdPfegQ4koRIbFigj(YKtNagy9p4nOW827i8zv8uOANbpTJW)9xIcJXfRchVAUdzu8uZGG4IN6nOWCpzCpruep7i8F)L4jmdaor5qAbHHkUIZQyWhIrIVm50jGjiUm4nOW827i8zv8uOw64FcNHQ1m4AdOWTBeP2a3QGsZJ6sFRrkwfZx6qa9DeroMNT1tlimu5jGXfUYHCPBusdIS01zDkGjmubHrmyzPdyCHVMDPZzvm4dXiXxwZUMbQ1Sl9xgn4yROx6wqyOAPddS(h8guy(spqyYjmBPdTNr4PWcZzvSNA16PyGxIIlisFCW7VedOEz0GJ5zlpdieadTTuCbr6JdE)Lyaf5DJvCpHON4Ytn5zCaZtTA9edjkyG1)G3GcZvK3nwX9eIt9moG5PwTEkg4LOmE4fMvHREz0GJ5zlpXqIcgy9p4nOWCf5DJvCpHONq7zaHayOTLY4HxywfUI8UXkUNt6jnfmSY4HxywfUcJIycdvEIJNT8mGqam02sz8WlmRcxrE3yf3ti6zB9SLNq7zeEkg4LO4cI0hh8(lXaQxgn4yEQvRNIbEjkUGi9XbV)smG6LrdoMNT8KlisFCW7VedOWqBlpXXtC8SLNq7jnfmSAlRWgXuCrXflm3ti6juT1tTA90WZtyYvS46ik(yhjVeMbueRM7jEN6jU8uRwpPPGHvadFBWPiXxrT7PwTEgHN0uWWkAacHbO4IIA3tC8SLNr4jnfmSItrI)abp2rBprrTV0dAeaFigj(cFndulzndUwZU0Fz0GJTIEPhim5eMT0fd8sugp8cZQWvVmAWX8SLNbecGH2wkGHVnOPiCrrE3yf3t865gE2YtO9KlisFCW7VedOWqBlp1Q1Zi8umWlrXfePpo49xIbuVmAWX8ehpB5j0EgHNIbEjkw4WuenuVmAWX8uRwpJWtAkyyflCykIgkQDpB5zeEgqiagABPyHdtr0qrT7jolDlimuT0nE4fMvHVK1mrDn7s)Lrdo2k6LEGWKty2sxmWlrDW7VedmObgxuVmAWX8SLNq7PyGxIQBC5KbcEinFCW7VeU6LrdoMNT8KMcgw1nUCYabpKMpo49xcxrT7zlp72bCHG6Ecrp18n8uRwpJWtXaVev34Yjde8qA(4G3FjC1lJgCmpXXZwEcTNr4j0EYfePpo49xIbuu7E2YtXaVefxqK(4G3Fjgq9YObhZtC8uRwpn88eMCvzcfXaJgJ0rLgkIvZ9CQNr1ZwEstbdR2YkSrmfxuCXcZ9eIEcvB9eNLUfegQw6h8(lXadAGXLLSMPTRzx6VmAWXwrV0deMCcZw6IbEjkUGi95)7NOEz0GJ5zlpH2tIXWgh)xIYWW4QaIQepHONr1tTA9KymSXX)LOmmmUIvEIxpJ8gEIJNT8eApJWtXaVefNIe)bcESJ2EI6LrdoMNA16jnfmSItrI)abp2rBprrT7PwTE2Td4cb19eVt9STT1tCw6wqyOAPZfePp)F)KLSMjYRzx6VmAWXwrV0deMCcZw6IbEjkalsqXWgDlUBdbjVREz0GJ5zlpH2tIXWgh)xIYWW4QaIQepHONr1tTA9KymSXX)LOmmmUIvEIxpJ8gEIZs3ccdvlDalsqXWgDlUBdbjVVK1mA(A2L(lJgCSv0l9aHjNWSLonfmSIlisF()(jkQDpB5jF)aWqms8fUk0ySAayXnsXQypHON4YZwEcTNgEEctUcy4BdEdkmxrSAUNAYtAkyyfWW3g8guyUIlwyUN44je9exAUNT8eApPPGHvDJlNmqWdP5JdE)LWvu7E2YZi8umWlrXPiXFGGh7OTNOEz0GJ5PwTEstbdR4uK4pqWJD02tuu7EIZs3ccdvlDalUrkwfpOrazjRzIuRzx6VmAWXwrV0deMCcZw6q7jF)aWqms8fUk0ySAayXnsXQypXRNq5PwTEA45jm5k5bbvSWqAOkStueRM7jEN6zu9SLNr4PyGxIItrI)abp2rBpr9YObhZZwEA45jm5kGHVn4nOWCfXQ5EcrpHYtC8SLNgEEctUcy4BdEdkmxrSAUNAYtAkyyfWW3g8guyUIlwyUNq0tO9mQAUNt6zu9utEA45jm5k5bbvSWqAOkStueRM7PM8KVFayigj(cxfAmwnaS4gPyvSN44zlpH2Zi8umWlrXPiXFGGh7OTNOEz0GJ5PwTEgHNyirbdS(h8guyUICyY5ngn4EQvRNCbr6JdE)Lyaf1UN44zlpH2Zi8umWlr1nUCYabpKMpo49xcx9YObhZtTA9KMcgw1nUCYabpKMpo49xcxrT7PwTEgqiagABPag(2GMIWff5DJvCpXRNB4zlp72bCHG6EI3PEIBXLNt6zu3Wtn5PyGxIkyaWqA(qAOkStuVmAWX8eNLUfegQw63istKGYM)LSMb3yn7s)Lrdo2k6LEGWKty2spcpPPGHvCks8hi4XoA7jkQDpB5PyGxIQBC5KbcEinFCW7VeU6LrdoMNT8eApPPGHvDJlNmqWdP5JdE)LWvu7EQvRNbecGH2wkGHVnOPiCrrE3yf3t865gE2YZUDaxiOUN4DQN4wC55KEg1n8utEkg4LOcgamKMpKgQc7e1lJgCmp1Q1t((bGHyK4lCvOXy1aWIBKIvXEcrpXLNT8eApn88eMCfWW3g8guyUIy1Cp1KN0uWWkGHVn4nOWCfxSWCpHON4sZ9ehpB5jnfmSIlisF()(jkQDpB5zaHayOTLcy4BdAkcxuK3nwX9eIt9moG5jolDlimuT0VrKMbVbfMVK1m421Sl9xgn4yROx6bctoHzl9i8umWlr1nUCYabpKMpo49xcx9YObhZZwEgHNq7PHNNWKRyX1ru8XosEjmdOiwn3t86jU8SLN0uWWkJhEHzv4kQDpXXZwEcTN0uWWkUGi95)7NOO29uRwp72bCHG6EI3PEIB3WZj9mQB4PM8umWlrfmayinFinuf2jQxgn4yEQvRNr4j0EYfePpo49xIbuu7E2YtXaVefxqK(4G3Fjgq9YObhZtC8SLNh33Fqo2iG60MmaVILgp30tH1VNB6zaHayOTLIlisFCW7VedOiVBSI75MEcvK3Wtn5jmaHiEcTNq75X99hKJncOoTjdWRyPXZn9uy975MEgqiagABP4cI0hh8(lXakY7gR4EIJNAwpHkYB4joEI3PEg1n8utEcTNq55KEcTNgEEctU6Hg0abpKMpo49xIb4kIvZ9eVt9exEIJN44jolDlimuT0VrKMbVbfMVK1mqTXA2L(lJgCSv0l9aHjNWSLUyGxIItrI)abp2rBpr9YObhZZwEgHN0uWWkofj(de8yhT9ef1UNT8mGqam02sbm8TbnfHlkY7gR4EcXPEghW8SLNq7zeEkg4LO4cI0hh8(lXaQxgn4yE2YZi8eApHzKpo49xIbuu7EIJNA16PyGxIIlisFCW7VedOEz0GJ5zlpJWtO9KlisFCW7VedOO29ehpXzPBbHHQL(nI0m4nOW8LSMbkOwZU0TGWq1shWIBKIvXdGX5OL(lJgCSv0lzndu4An7s)Lrdo2k6LEGWKty2sNlisFCW7VedOO29SLNIbEjkUGi9XbV)smG6LrdoMNT8eApn88eMCflUoIIp2rYlHzafXQ5EcrpXLNA16zeEstbdRag(2GtrIVIA3ZwEstbdRObiegGIlkQDpXzPBbHHQLoGf3ifRIh0iGSK1mqf11Sl9xgn4yROx6bctoHzlDO9KMcgwXfePp)F)ef5DJvCpHONqPGYtn5zCaZtn5jnfmSIlisF()(jkUyH5EQvRN0uWWkUGi95)7NOO29SLN0uWWQUXLtgi4H08XbV)s4kQDpXzPBbHHQLoGf3ifRIh0iGSK1mq121Sl9xgn4yROx6bctoHzlDXaVeflCykIgQxgn4yE2YtXaVev34Yjde8qA(4G3FjC1lJgCmpB5jnfmSIfomfrdf1UNT8KMcgw1nUCYabpKMpo49xcxrTV0TGWq1shMG4YG3GcZxYAgOI8A2L(lJgCSv0l9aHjNWSLonfmSY4HxywfUIAFPBbHHQLoWW3g0ueUSK1mqP5Rzx6VmAWXwrV0TGWq1shgy9p4nOW8LEGWKty2sNCyY5ngn4E2Ytlim8)417SZ9eVEcLNT8KMcgwXPiXFGGh7OTNOO2x6bncGpeJeFHVMbQLSMbQi1A2L(lJgCSv0l9aHjNWSLUyGxIIlisFCW7VedOEz0GJ5zlpdieadTTgKBbXZwEstbdR4uK4pqWJD02tuu7E2YtO984((dYXgbuN2Kb4vS045MEkS(9CtpdieadTTuCbr6JdE)Lyaf5DJvCp30tOI8gEQjpHbieXtO9eAppUV)GCSra1PnzaEflnEUPNcRFp30ZacbWqBlfxqK(4G3FjgqrE3yf3tC8uZ6jurEdpXXti6zu3Wtn5j0EcLNt6j0EA45jm5QhAqde8qA(4G3FjgGRiwn3t8o1tC5joEIJNA16j0EcLckn3tn5j0EECF)b5yJaQtBYa8kwA8Ctpfw)EIJNB6zaHayOTLIlisFCW7VedOiVBSI75MEcvK3Wtn5jmaHiEcTNq7jukO0Cp1KNq75X99hKJncOoTjdWRyPXZn9uy97joEUPNbecGH2wkUGi9XbV)smGI8UXkUN44PM1tOI8gEIJN44je9eAppUV)GCSra1PnzaEflnEUPNcRFp30ZacbWqBlfxqK(4G3FjgqrE3yf3Zn9eQiVHNAYtyacr8eApH2ZJ77pihBeqDAtgGxXsJNB6PW63Zn9mGqam02sXfePpo49xIbuK3nwX9ehp1SEcvK3WtC8ehpXzPBbHHQLoWW3g0ueUSK1mqHBSMDP)YObhBf9spqyYjmBPhHNIbEjkUGi9XbV)smG6LrdoMNT8mGqam02AqUfepB5jnfmSItrI)abp2rBprrT7zlpH2ZJ77pihBeqDAtgGxXsJNB6PW63Zn9mGqam02sbZiFCW7VedOiVBSI75MEcvK3Wtn5jmaHiEcTNq75X99hKJncOoTjdWRyPXZn9uy975MEgqiagABPGzKpo49xIbuK3nwX9ehp1SEcvK3WtC8eIEg1n8utEcTNq55KEcTNgEEctU6Hg0abpKMpo49xIb4kIvZ9eVt9exEIJN44PwTEcTNqPGsZ9utEcTNh33Fqo2iG60MmaVILgp30tH1VN445MEgqiagABPGzKpo49xIbuK3nwX9CtpHkYB4PM8egGqepH2tO9ekfuAUNAYtO984((dYXgbuN2Kb4vS045MEkS(9ehp30ZacbWqBlfmJ8XbV)smGI8UXkUN44PM1tOI8gEIJN44je9eAppUV)GCSra1PnzaEflnEUPNcRFp30ZacbWqBlfmJ8XbV)smGI8UXkUNB6jurEdp1KNWaeI4j0EcTNh33Fqo2iG60MmaVILgp30tH1VNB6zaHayOTLcMr(4G3FjgqrE3yf3tC8uZ6jurEdpXXtC8eNLUfegQw6adFBqtr4YswZafUDn7s)Lrdo2k6LEGWKty2sNMcgwXPiXFGGh7OTNOO2x6wqyOAPdyXnsXQ4bncilzndU2yn7s)Lrdo2k6LEGWKty2spGqam02AqUfepB5zeEkg4LO6gxozGGhsZhh8(lHREz0GJT0TGWq1shy4BdAkcxwYAgCb1A2L(lJgCSv0l9aHjNWSLUyGxIIfomfrd1lJgCmpB5zeEcTND7aUqqDpXRNrQi7zlpdieadTTuadFBqtr4II8UXkUNqCQNB4joE2YtO9mcpfd8suCbr6JdE)Lya1lJgCmp1Q1tUGi9XbV)smGcdTT8eNLUfegQw6SWHPiASK1m4cxRzx6VmAWXwrV0deMCcZw6becGH2wdYTG4zlpdngj(CpXRNIbEjQhAqde8qA(4G3FjC1lJgCSLUfegQw6adFBqtr4YswZGROUMDP)YObhBf9spqyYjmBPlg4LOyHdtr0q9YObhZZwEstbdRyHdtr0qrT7zlpPPGHvSWHPiAOiVBSI7je9ekfuEQjpJdyEQjpPPGHvSWHPiAO4IfMV0TGWq1shMG4YG3GcZxYAgC121Sl9xgn4yROx6bctoHzl9acbWqBRb5wqw6wqyOAPdm8TbnfHllzndUI8A2L(lJgCSv0lDlimuT0Hbw)dEdkmFPhim5eMT0jhMCEJrdUNT8mcpPPGHvCks8hi4XoA7jkQ9LEqJa4dXiXx4RzGAjRzWLMVMDP)YObhBf9spqyYjmBPlg4LOeK8(OBC5enuVmAWX8SLNq7jnfmSICoQSk8HGK3vK3nwX9eIEQ5EQvRNq7jnfmSICoQSk8HGK3vK3nwX9eIEcTN0uWWkJhEHzv4kmkIjmu55KEgqiagABPmE4fMvHRiVBSI7joE2YZacbWqBlLXdVWSkCf5DJvCpHONqfzpXXtCw6wqyOAPli59r34YjASK1m4ksTMDP)YObhBf9spqyYjmBPlg4LOyHdtr0q9YObhZZwEstbdRyHdtr0qrT7zlpH2tAkyyflCykIgkY7gR4EcrpJdyEQjpBRNAYtAkyyflCykIgkUyH5EQvRN0uWWkUGi95)7NOO29uRwpJWtXaVev34Yjde8qA(4G3FjC1lJgCmpXzPBbHHQLombXLbVbfMVK1m4c3yn7s)Lrdo2k6LEGWKty2sNMcgwjpiOIfgsdvHDIIA3ZwEgHN0uWWkUGi95)7NOO29SLN89dadXiXx4QqJXQbGf3ifRI9eVEc1s3ccdvl9qJXQbGf3ifRIxYAgCHBxZU0TGWq1shWIBKIvXdAeqw6VmAWXwrVK1mrDJ1Sl9xgn4yROx6wqyOAPddS(h8guy(spOra8HyK4l81mqT0deMCcZw6KdtoVXObFP3r4ZQ4LoulzntuHAn7s)Lrdo2k6LEGWKty2sVJW)9xIcJXfRc3t86PMV0TGWq1shgy9p4nOW8LEhHpRIx6qTK1mrfxRzx6De(SkEPd1s3ccdvlDycIldEdkmFP)YObhBf9swYs3qFn7AgOwZU0Fz0GJTIEPhim5eMT0fd8suCbr6Z)3pr9YObhBPBbHHQLoxqK(8)9twYAgCTMDP)YObhBf9s3ccdvlDyG1)G3GcZx6bctoHzlDYHjN3y0G7zlpH2t((bGHyK4lCvOXy1aWIBKIvXEcrpH2Zi75MEgHNIbEjkbjVp6gxord1lJgCmpXXtTA9mcpfd8suCbr6JdE)Lya1lJgCmpB5j0EcZiFCW7VedOiVBSI7jE9eApHQTEQjp57hagngxUN44PwTEgqiagABPGzKpo49xIbuK3nwX9eIEcTN4QTEUPNq1wp1KN89daJgJl3tC8ehpXXZwEcTNr4PyGxIIlisFCW7VedOEz0GJ5PwTEYfePpo49xIbuyOTLNA16jF)aWqms8fUk0ySAayXnsXQypN6zu9SLN0uWWQTScBetXffxSWCpHONq1wpXzPh0ia(qms8f(AgOwYAMOUMDP)YObhBf9spqyYjmBPlg4LOmE4fMvHREz0GJ5zlpH2tXaVefxqK(4G3Fjgq9YObhZZwEYfePpo49xIbuyOTLNT8mGqam02sXfePpo49xIbuK3nwX9eVEcvK9uRwpJWtXaVefxqK(4G3Fjgq9YObhZtC8SLNq7zeEkg4LOyHdtr0q9YObhZtTA9mcpPPGHvSWHPiAOO29SLNr4zaHayOTLIfomfrdf1UN4S0TGWq1s34Hxywf(swZ021Sl9xgn4yROx6bctoHzlDXaVefGfjOyyJUf3THGK3vVmAWXw6wqyOAPdyrckg2OBXDBii59LSMjYRzx6VmAWXwrV0deMCcZw6r4PyGxIQBC5KbcEinFCW7VeU6LrdoMNA16jnfmSIlisF()(jkQDp1Q1ZUDaxiOUN4DQNq7juBSHNB6zB9utEY3pameJeFHRcngRgawCJuSk2tC8uRwpPPGHvDJlNmqWdP5JdE)LWvu7EQvRN89dadXiXx4QqJXQbGf3ifRI9eVEg1LUfegQw63istKGYM)LSMrZxZU0Fz0GJTIEPhim5eMT0PPGHvCbr6Z)3prrE3yf3ti6zu9utEghW8utEstbdR4cI0N)VFIIlwy(s3ccdvl9qJXQbGf3ifRIxYAMi1A2L(lJgCSv0l9aHjNWSLonfmScy4Bdofj(kQDpB5jF)aWqms8fUk0ySAayXnsXQypHONT1ZwEcTNr4PyGxIIlisFCW7VedOEz0GJ5PwTEYfePpo49xIbuyOTLN44zlpXqIcgy9p4nOWCLWcZzv8s3ccdvlDGHVnOPiCzjRzWnwZU0Fz0GJTIEPhim5eMT057hagIrIVWvHgJvdalUrkwf7je9STE2YZi8KMcgwz8WlmRcxrTV0TGWq1sNfomfrJLSMb3UMDP)YObhBf9spqyYjmBPZ3pameJeFHRcngRgawCJuSk2ti6zB9SLN0uWWkw4Wuenuu7E2YZi8KMcgwz8WlmRcxrTV0TGWq1shMG4YG3GcZxYAgO2yn7s)Lrdo2k6LEGWKty2sxmWlrDW7VedmObgxuVmAWX8SLN89dadXiXx4QqJXQbGf3ifRI9eIE2wpB5j0EgHNIbEjkUGi9XbV)smG6LrdoMNA16jxqK(4G3FjgqHH2wEIZs3ccdvl9dE)LyGbnW4YswZafuRzx6VmAWXwrV0deMCcZw6IbEjkJhEHzv4Qxgn4ylDlimuT0bg(2G(wFjRzGcxRzx6wqyOAPhAmwnaS4gPyv8s)Lrdo2k6LSMbQOUMDP)YObhBf9spqyYjmBPlg4LOmE4fMvHREz0GJT0TGWq1shy4BdAkcxw6De(SkEPd1swZavBxZU0Fz0GJTIEPBbHHQLomW6FWBqH5l9GgbWhIrIVWxZa1spqyYjmBPtom58gJg8LEhHpRIx6qTK1mqf51Sl9ocFwfV0HAPBbHHQLombXLbVbfMV0Fz0GJTIEjlzPJDyJciRzxZa1A2L(lJgCSf9spqyYjmBPB45jm5kRcNledmiNJkRcx9YObhBPBbHHQLonaHWauCzjRzW1A2L(lJgCSv0l9aHjNWSL(X99hKJncOoTjdWRyPXZn9uy97je9mQB4PwTEcZiFCW7VedOO29uRwp5cI0hh8(lXakQ9LUfegQw67iHHQLSMjQRzx6wqyOAPVLvydEZnYs)Lrdo2k6LSMPTRzx6VmAWXwrV0deMCcZw6IbEjkbjVp6gxord1lJgCmpB5jnfmSICoQSk8HGK3vK3nwX9eIEIRLUfegQw6csEF0nUCIglzntKxZU0TGWq1sNI)btENV0Fz0GJTIEjRz081Sl9xgn4yROx6bctoHzl9i8umWlrXfePpo49xIbuVmAWXw6wqyOAPdZiFCW7VedSK1mrQ1Sl9xgn4yROx6bctoHzlDXaVefxqK(4G3Fjgq9YObhZZwEcTNr4PyGxIIfomfrd1lJgCmp1Q1Zi8KMcgwXchMIOHIA3ZwEgHNbecGH2wkw4Wuenuu7EIJNT8eApJWtXaVeLXdVWSkC1lJgCmp1Q1Zi8mGqam02sz8WlmRcxrT7jolDlimuT05cI0hh8(lXalzndUXA2LUfegQw6bufEjeto2agy9V0Fz0GJTIEjRzWTRzx6wqyOAPtdqiSbcEinF86Dnw6VmAWXwrVK1mqTXA2LUfegQw6XugbJz1abpm88eK0S0Fz0GJTIEjRzGcQ1SlDlimuT0Hrbk(XggEEct(G(wFP)YObhBf9swZafUwZU0TGWq1sFNIWG1GvXdAGXLL(lJgCSv0lzndurDn7s3ccdvlDP5dQIgrvydyej8L(lJgCSv0lznduTDn7s3ccdvl9(7iIgde8aqfyydmYToFP)YObhBf9swZavKxZU0TGWq1sNW23bFWQbF3cFP)YObhBf9swZaLMVMDPBbHHQL(webGH)z1GCoQSk8L(lJgCSv0lzndurQ1Sl9xgn4yROx6bctoHzl9i8umWlrz8WlmRcx9YObhZtTA9KMcgwz8WlmRcxrT7PwTEgqiagABPmE4fMvHRiVBSI7jE9mYBS0TGWq1sNgGqydykIglzndu4gRzx6VmAWXwrV0deMCcZw6r4PyGxIY4HxywfU6LrdoMNA16jnfmSY4HxywfUIAFPBbHHQLo9j8tMZQ4LSMbkC7A2L(lJgCSv0l9aHjNWSLEeEkg4LOmE4fMvHREz0GJ5PwTEstbdRmE4fMvHRO29uRwpdieadTTugp8cZQWvK3nwX9eVEg5nw6wqyOAPdZiNgGqylzndU2yn7s)Lrdo2k6LEGWKty2spcpfd8sugp8cZQWvVmAWX8uRwpPPGHvgp8cZQWvu7EQvRNbecGH2wkJhEHzv4kY7gR4EIxpJ8glDlimuT0TkCUqmWiyaWswZGlOwZU0Fz0GJTIEPhim5eMT05cI0hh8(lXakQDpB5jnfmSkyaWaWIBKIvXkY7gR4EI3PEIBS0TGWq1s)A8bcEinFWfePVK1m4cxRzx6wqyOAP3VCezP)YObhBf9swZGROUMDP)YObhBf9spqyYjmBPBbHH)hVENDUN41tC5zlpH2t((bGHyK4lCvOXy1aWIBKIvXEIxpXLNA16jF)aWqms8fUcy4Bd6BDpXRN4YtCw6wqyOAPtOQHfegQgagxw6agxgL1)s3qFjRzWvBxZU0Fz0GJTIEPBbHHQLoHQgwqyOAayCzPdyCzuw)lDoRIbFigj(YswYsFN8aQtBYA21mqTMDPBbHHQLUGK3hDJlNOXs)Lrdo2k6LSMbxRzx6VmAWXwrV0deMCcZw6IbEjkUGi95)7NOEz0GJ5zlpH2tIXWgh)xIYWW4QaIQepHONr1tTA9KymSXX)LOmmmUIvEIxpJ8gEIZs3ccdvlDUGi95)7NSK1mrDn7s)Lrdo2k6LEGWKty2spcpfd8suCbr6JdE)Lya1lJgCSLUfegQw6WmYhh8(lXalzntBxZU0Fz0GJTIEPhim5eMT0fd8suCbr6JdE)Lya1lJgCSLUfegQw6Cbr6JdE)LyGLSMjYRzx6wqyOAPVJegQw6VmAWXwrVK1mA(A2L(lJgCSv0l9aHjNWSLUyGxI6G3FjgyqdmUOEz0GJT0TGWq1s)G3FjgyqdmUSK1mrQ1Sl9xgn4yROx6bctoHzl9i8umWlrDW7VedmObgxuVmAWX8SLN89dadXiXx4QqJXQbGf3ifRI9eIEg1LUfegQw6adFBqtr4YswZGBSMDP)YObhBf9spqyYjmBPZ3pameJeFHRcngRgawCJuSk2t86jUw6wqyOAPhAmwnaS4gPyv8swYswYswla]] )


    spec:RegisterPack( "Elemental Funnel", 20190709.1630, [[deveXbqiHWJukYLifHnjf9jHO0OaPofizvKI6vsHMLuWTuQyxK8lfKHPq6yqfltiYZesmnfIUguvTnOs13eIkJdQuQZPuuToHOW7eII08uQ09uG9bvL)PqivheQuYcfs9qOsstuHqDrHK2Ocb(iujHrQqiLtkevTsLQEPquuZuPOCtOsQDQu4NkeIHcvkwkujrpLunvfuxvHG(QcHKXkefHZkefr7vj)vrdwYHPSye9ybtguxw1MHYNfQrlLonkVwP0SbUTuTBr)gYWbXXjfrlhPNJQPtCDe2ouLVRqnEOsCEsH1tksZNuA)u9cN1WlDyt(AJinkoB(OrUr3Cfo4(ihjorULUObKV0HyHTw8x6P1)spQG3FkgWRrarMhS0HyAaqg8A4LohrqdFPV0jjyajYNlYLoSjFTrKgfNnF0i3OBUchCpklDoKhwBejCpsl9wgm8Zf5sh(8WsFtEfvW7pfd4LER1T0lOhbezEalJHY3VjVAfbcpYyOHIzslbPkG6dXzDcGjmugOgMmeN1dd573Kx7jaA41M3GxrAuC2CV2XlCW9iJOm6shcfHXaFPVjVIk49NIb8sV16w6f0JaImpGLXq573KxTIaHhzm0qXmPLGufq9H4SobWegkdudtgIZ6HH89BYR9ean8AZBWRinkoBUx74fo4EKrug13773Kx4QTwgFEKHVFtETJxJq(9kYeZdE)PyafbeVOM0EQxsRLEfAFyllJ9kGqay04K7LG8I)7fdZRdE)PyaUxg9EzbHH3v((n51oEnIzCJeCyVIQrLwVIk49NIb86PqzNR89BYRD8cx57i8Ux4w8Wtyld3lH1)qrVzEfAFyRY3VjV2XlClyyVIQg3leMxs79sxq0Uxd5fU(YruLV33VjVIkU8aHCyVipgIEVcOoPjEr(ywYvEHBfchIW9kr5oTgTJra8YccdLCVqjqdLV3ccdLCfe6dOoPjdWagFRV3ccdLCfe6dOoPjnoyimec23BbHHsUcc9buN0KghmKre3FkMWqPVFtEPNgeEls8IAmyVijWWoSxCXeUxKhdrVxbuN0eViFml5EzjSxqOFhiiryzSxmUxWO8kFVfegk5ki0hqDstACWq80GWBrYKlMW99wqyOKRGqFa1jnPXbdji59z34YPA473KxwqyOKRGqFa1jnPXbdDJkTZdE)PyGgyydIqmWtrbHY6gyEW7pfdW4I6PrcoSV33VjVgH87LUGO9T)qo1li0hqDst8IibNZ9IJ63ldgM71yga4fhIno9IJqPY3BbHHsUcc9buN0Kghmexq0(2FiN2adBGyGNIIliAF7pKtvpnsWHBcn1yWZJ3trzWWCvarKYUrrRwQXGNhVNIYGH5kwIp8pku(EFVfegk5ki0hqDstACWqym6Nh8(tXanWWgeHyGNIIliAFEW7pfdOEAKGd77TGWqjxbH(aQtAsJdgIliAFEW7pfd0adBGyGNIIliAFEW7pfdOEAKGd77TGWqjxbH(aQtAsJdgccsyO03BbHHsUcc9buN0Kghm0bV)umWKeyCPbg2aXapf1bV)umWKeyCr90ibh23BbHHsUcc9buN0KghmeWWZMKeuU0adBqeIbEkQdE)PyGjjW4I6PrcoCtoKdatXOXx4QqRXYjGf3kjlJ3nk(ElimuYvqOpG6KM04GHcTglNawCRKSmUbg2aoKdatXOXx4QqRXYjGf3kjlJXxK89((n5vuXLhiKd71X7un8sy97L0EVSGGOEX4Ez4zmGrcUY3VjVWvnU4v0aecgqWfV6wsyaGgEXW8sAVx4wA6Pm5Enm1yIx4wz4CHAaVWvEokTmCVyCVGqp)PO89wqyOKpGeGqWacU0adBGPPNYKRSmCUqnWKEokTmC1tJeCyF)M8kYN7eqDst8ccsyO0lg3li0JD6tHzaGgEby52d7LG8sdeb1ROcE)PyGg8IibNZ9kG6KM41yga41tyV4TiQa0W3BbHHsEJdgccsyOSbg2GJlqEqo8mG6KMmbpJL2Dew)7gLr1QfJr)8G3FkgqrarRwUGO95bV)umGIaIVFtEf5t5ukbeXleMxbJlCLV3ccdL8ghm0ywcp5T3O(ElimuYBCWqcsEF2nUCQgnWWgig4POeK8(SBC5unupnsWHBssGHPONJsldFki5Df9DJL8DJKV3ccdL8ghmegJ(5bV)umqdmSbrig4PO4cI2Nh8(tXaQNgj4W(ElimuYBCWqCbr7ZdE)PyGgyyded8uuCbr7ZdE)Pya1tJeC4MqhHyGNIIfogbvd1tJeCyTAJGKadtXchJGQHIasZicieagnovSWXiOAOiGavtOJqmWtrz8Wtyldx90ibhwR2icieagnovgp8e2YWveqGY3VjVSGWqjVXbdDJkTZdE)PyGgyydIqmWtrbHY6gyEW7pfdW4I6PrcoSwTIbEkkiuw3aZdE)PyagxupnsWHBcngJ(5bV)umGcgnoBgHyGNIIliAFEW7pfdOEAKGdRvlxq0(8G3FkgqbJgNnfd8uuCbr7ZdE)Pya1tJeCyO89wqyOK34GHi4FYK35(ElimuYBCWqbugEkuto8edy977TGWqjVXbdrcqi4jcBkTF(8Dn89wqyOK34GHIjmkmZYjcBAA6PiP13BbHHsEJdgcdfi4hEAA6Pm5tYBDFVfegk5noyiieugMgSmEscmU47TGWqjVXbdjTFsKKiIeEIHOH77TGWqjVXbd1Fhr1yIWMaIadEctV15(ElimuYBCWqugeiGpz5KdXc33BbHHsEJdgAmIcGX7SCsphLwgUV3ccdL8ghmejaHGNyeunAGHnicXapfLXdpHTmC1tJeCyTAjjWWugp8e2YWveq0QnGqay04uz8WtyldxrF3yjhF4FuFVfegk5noyiYt5NULLXnWWgeHyGNIY4HNWwgU6PrcoSwTKeyykJhEcBz4kci(ElimuYBCWqym6jbieCdmSbrig4POmE4jSLHREAKGdRvljbgMY4HNWwgUIaIwTbecaJgNkJhEcBz4k67gl54d)J67TGWqjVXbdzz4CHAGzWaGgyydIqmWtrz8Wtyldx90ibhwRwscmmLXdpHTmCfbeTAdieagnovgp8e2YWv03nwYXh(h13BbHHsEJdg6A8jcBkTFYfeT3adBaxq0(8G3FkgqraPjjbgMkyaWeWIBLKLXk67gl54BaUTV3ccdL8ghmu)YruFVfegk5noyikroTGWq5eW4sdP1)ad9gyydSGWW7ZNVZohF4Vj0CihaMIrJVWvHwJLtalUvswgJp8RvlhYbGPy04lCfWWZMK364d)q57TGWqjVXbdrjYPfegkNagxAiT(hWzzm4tXOXx89((n5fUMaimVeJgFXllimu6fekdrzIgEbyCX3BbHHsUYqFaxq0(2FiN2adBGyGNIIliAF7pKtvpnsWH99BYlDi0BWEncaw)EP3IcB9ILET7aVgPxIrJV4fglUv4n4fjH4vIeVGjOSm2l9O6fbeH1Fdej4CUxAGiIS07fglUvyzSxrXlXOXx4EzjSxTgE3lW5CVKwl9cNr61ikwc7fUccU4fxSWwUY3BbHHsUYqVXbdHbS(N8wuyBdbncGpfJgFHpaNgyydOhJEERrcEtO5qoamfJgFHRcTglNawCRKSmExOX)orig4POeK8(SBC5unupnsWHHsR2ied8uuCbr7ZdE)Pya1tJeC4MqJXOFEW7pfdOOVBSKJpOXzKAMd5aWS14YHsR2acbGrJtfgJ(5bV)umGI(UXs(UqhPrUdoJuZCihaMTgxouqbvtOJqmWtrXfeTpp49NIbupnsWH1QLliAFEW7pfdOGrJtTA5qoamfJgFHRcTglNawCRKSmEquAssGHPgZs4zmbxuCXcB3fNrcLV3ccdLCLHEJdgY4HNWwgEdmSbIbEkkJhEcBz4QNgj4WnHwmWtrXfeTpp49NIbupnsWHBYfeTpp49NIbuWOXzZacbGrJtfxq0(8G3FkgqrF3yjhF4GFTAJqmWtrXfeTpp49NIbupnsWHHQj0rig4POyHJrq1q90ibhwR2iijWWuSWXiOAOiG0mIacbGrJtflCmcQgkciq57TGWqjxzO34GHamnjbdE2T4UnfK8EdmSbIbEkkattsWGNDlUBtbjVREAKGd7799BYRHPA4LG8k263ROAuPvtsyBVxJzsRx4AJlN6fcZlP9EfvW7pfUxKeyyEnU9PxyS4wHLXEffVeJgFHR8AeJYiR4fcVtdgeVW12bCHI6r47TGWqjxzO34GHUrLwnjHT9nWWgeHyGNIQBC50jcBkTFEW7pfU6PrcoSwTKeyykUGO9T)qovrarR2UDaxOOo(ganoJo6oJuZCihaMIrJVWvHwJLtalUvswgdLwTKeyyQUXLtNiSP0(5bV)u4kciA1YHCaykgn(cxfAnwobS4wjzzm(IIV33VjVW1227fNGEV0ar4fmkJSIxae)EzEPliAF7pKtv(ElimuYvg6noyOqRXYjGf3kjlJBGHnGKadtXfeTV9hYPk67gl57gfnhhG1mjbgMIliAF7pKtvCXcB99((n51isc0WRGXfV2mdpZROjOCXlu6L0s)9smA8fUxmmVyIxmUxw6fl5ILIxwc7LUGODVIk49NIb8IX9AJrKH9YccdVR89wqyOKRm0BCWqadpBssq5sdmSbKeyykGHNn5e04RiG0Kd5aWumA8fUk0ASCcyXTsYY4DhztOJqmWtrXfeTpp49NIbupnsWH1QLliAFEW7pfdOGrJtOAcJefgW6FYBrHTkHf2YYyFVfegk5kd9ghmelCmcQgnWWgWHCaykgn(cxfAnwobS4wjzz8UJSzeKeyykJhEcBz4kci(ElimuYvg6noyimkIltElkSTbg2aoKdatXOXx4QqRXYjGf3kjlJ3DKnjjWWuSWXiOAOiG0mcscmmLXdpHTmCfbeFVVFtEnc53ROcE)PyaVIgyCXll2yjx8IaIxcYRO4Ly04lCVmUxaug7LX9sxq0Uxrf8(tXaEX4ELiXllim8UY3BbHHsUYqVXbdDW7pfdmjbgxAGHnqmWtrDW7pfdmjbgxupnsWHBYHCaykgn(cxfAnwobS4wjzz8UJSj0rig4PO4cI2Nh8(tXaQNgj4WA1YfeTpp49NIbuWOXju(ElimuYvg6noyiGHNnjV1BGHnqmWtrz8Wtyldx90ibh23BbHHsUYqVXbdfAnwobS4wjzzSV3ccdLCLHEJdgcy4ztsckxAOJWJLXdWPbg2aXapfLXdpHTmC1tJeCyFVfegk5kd9ghmegW6FYBrHTn0r4XY4b40qqJa4tXOXx4dWPbg2a6XON3AKG77TGWqjxzO34GHWOiUm5TOW2g6i8yz8aC89((n5LolJb3RHnA8fVWTccdLEHBOmeLjA41MX4IVFtEf1KtqVxJaDVyCVSGWW7ErKGZ5EPbIWRwdV7foJ0le1RoIEV4If2Y9cH51ikwc7fUccU4fgf19sxq0Uxrf8(tXakVGoQWX3RGXFKHxeqcOolJ9c3Ih8IKq8YccdV7LEuJm1lyugzfVGY3BbHHsUIZYyWNIrJVmady9p5TOW2gcAeaFkgn(cFaonWWgaDeclSLLXA1kg4PO4cI2Nh8(tXaQNgj4WndieagnovCbr7ZdE)Pyaf9DJL8DJKMJdWA1cJefgW6FYBrHTk67gl57oioaRvRyGNIY4HNWwgU6PrcoCtyKOWaw)tElkSvrF3yjFxOdieagnovgp8e2YWv03nwYBKKadtz8WtyldxbtqnHHsOAgqiamACQmE4jSLHROVBSKV7iBcDeIbEkkUGO95bV)umG6PrcoSwTIbEkkUGO95bV)umG6PrcoCtUGO95bV)umGcgnoHcQMqtsGHPgZs4zmbxuCXcB3fNrQvRPPNYKRyX5re8jeK8uygqrTCl(gejTAjjWWuadpBYjOXxrarR2iijWWuKaecgqWffbeOAgbjbgMItqJ)eHnHGgFQIaIV33VjVgH87fUfp8e2YW9YWKt9sderKfV7fhYtXlda8AZm8mVIMGYfVcTgn(CVSe2luc0WlgMx5zs7PEPliA3ROcE)PyaVse1RiF4yeun8YO3RabL(uaA4LfegEx57TGWqjxXzzm4tXOXxACWqgp8e2YWBGHnqmWtrz8Wtyldx90ibhUzaHaWOXPcy4ztsckxu03nwYX3OnHMliAFEW7pfdOGrJtTAJqmWtrXfeTpp49NIbupnsWHHQj0rig4POyHJrq1q90ibhwR2iijWWuSWXiOAOiG0mIacbGrJtflCmcQgkciq5799BYRrmkJSIxe87vubV)umGxrdmU4fdZlnqeEfqeayVcgx8Y8cxBC5uVqyEjT3ROcE)PW96DiOXNEyVIQrLwV0BrHTEXsUCdw51igLrwXRGXfVIk49NIb8kAGXfVGjOSm2lDbr7EfvW7pfd4frcoN7LgicVAn8Uxrbx8AdtiOgWRr0mAhLAO8kAcXlw6L0Y4Efm(9IliiErWzzSxrf8(tXaEfnW4IxOmCV0ar4f9wO1lCgPxCXcB5EHW8AeflH9cxbbxu(ElimuYvCwgd(umA8Lghm0bV)umWKeyCPbg2aXapf1bV)umWKeyCr90ibhUj0IbEkQUXLtNiSP0(5bV)u4QNgj4WnjjWWuDJlNorytP9ZdE)PWveqA2Td4cf13f3hvR2ied8uuDJlNorytP9ZdE)PWvpnsWHHQj0ranxq0(8G3FkgqraPPyGNIIliAFEW7pfdOEAKGddLwTMMEktUknHGAGzRr7Oudf1YTdIstscmm1ywcpJj4IIlwy7U4msO89((n5vK5FiEPhz2lme1lGrJVxiQxCek9YGH9ASH35kVgHj4CUxAGi8Q1W7EPtqJVximVWnOXN2GxS0RXTSqRxbJFV0ar41ylfVeKxWicsW9IKadZRnJf3kjlJ9kAeq8IudVGGqawg7fU2oGluu3lYJHOV1syLxrfxSoeW9IFnjXZWJm8cNrhfxR3GxrvVbV0Jm3GxBw0n41MHx0n4vu1BWRnlAFVfegk5kolJbFkgn(sJdgIliAF7pKtBGHnqmWtrXfeTV9hYPQNgj4WnHMAm45X7POmyyUkGisz3OOvl1yWZJ3trzWWCflXh(hfQMqhHyGNIItqJ)eHnHGgFQ6PrcoSwTKeyykobn(te2ecA8PkciA12Td4cf1X3GrosO89(ElimuYvCwgd(umA8LghmeGPjjyWZUf3TPGK3BGHnqmWtrbyAscg8SBXDBki5D1tJeC4Mqtng8849uugmmxfqePSBu0QLAm45X7POmyyUIL4d)JcLV33VjVWvrDswEV0feTV9hYPEnMjTEHRnUCQximVK27vubV)u4EHOEPtqJVximVWnOXN6frcoN7LgicVAn8Uxs79AZm8mV0BrHTEjuJjEzjSxDcGWGaUxCXcB5kFVfegk5kolJbFkgn(sJdgcWIBLKLXtseqAGHnGKadtXfeTV9hYPkcin5qoamfJgFHRcTglNawCRKSmE3i1eAttpLjxbm8SjVff2QOwUvZKeyykGHNn5TOWwfxSWwO2ns4EtOjjWWuDJlNorytP9ZdE)PWveqAgHyGNIItqJ)eHnHGgFQ6PrcoSwTKeyykobn(te2ecA8Pkciq5799BYRri)EfvJkTAscB79cVt5eCVIKxIrJVWBWlIeCo3lnqeE1A4DV2mdpZl9wuyRYRri)EfvJkTAscB79cVt5eCVWXlXOXx8IH5LgicVAn8Uxd)GGswWRHBjs4t9kkEjS(5EzjSxBmI4Lobn(EHW8c3GgFQxpnsWH9YsyV2yeXRnZWZ8sVff2Q89wqyOKR4Smg8Py04lnoyOBuPvtsyBFdmSbqZHCaykgn(cxfAnwobS4wjzzm(WrRwttpLjxjpiOKfMslrcFQIA5w8niknJqmWtrXjOXFIWMqqJpv90ibhUPPPNYKRagE2K3IcBvul3Uloq1000tzYvadpBYBrHTkQLB1mjbgMcy4ztElkSvXflSDxOJcU3yu0SPPNYKRKheuYctPLiHpvrTCRM5qoamfJgFHRcTglNawCRKSmgQMqhHyGNIItqJ)eHnHGgFQ6PrcoSwTraJefgW6FYBrHTk6XON3AKGRvlxq0(8G3FkgqrabQMqhHyGNIQBC50jcBkTFEW7pfU6PrcoSwTKeyyQUXLtNiSP0(5bV)u4kciA1gqiamACQagE2KKGYff9DJLC8nAZUDaxOOo(gS5rQXOmQMfd8uubdaMs7NslrcFQ6Prcomu(EF)M8cx14Ixr1OsRx6TOWwVgZKwVW1gxo1leMxs79kQG3FkCVed8u8IKq8krEzbHH39sNGgFVqyEHBqJp1lscmSg8YsyVSGWW7EPliAF7pKt9IKadZllH9AZm8mVIMGYfVcOolJ9cHH5fU6i2RXmPLLEjT3R84I4fUcC1rCdEzjSxNjTN6LfegE3lCTXLt9cH5L0EVIk49Nc3lscmSg8cr9krEz4zmGrcUxBMHN5v0euU414wg4EL3OEHR19kyqAWle1lolJb3lXOXx8YsyV6eaHbbCV2mdpZl9wuyRxc1yc3llH9QBPgEXflSLR89wqyOKR4Smg8Py04lnoyOBuPDYBrHTnWWgebjbgMItqJ)eHnHGgFQIastXapfv34YPte2uA)8G3FkC1tJeC4MqtsGHP6gxoDIWMs7Nh8(tHRiGOvBaHaWOXPcy4ztsckxu03nwYX3On72bCHI64BWMhPgJYOAwmWtrfmaykTFkTej8PQNgj4WA1YHCaykgn(cxfAnwobS4wjzz8UrQj0MMEktUcy4ztElkSvrTCRMjjWWuadpBYBrHTkUyHT7gjChQMKeyykUGO9T)qovraPzaHaWOXPcy4ztsckxu03nwY3DqCagkFVVFtEfzseHxBt0yVg3AYi6Ef59Q1G9IJ63lElIkEDCbcWstyO0R2tVxOmCLxrtiEjTp9sAVxbucZegk9kM(Xn4LLWEf59Q1G9sqEXHayIxs79cL3ROAuP1l9wuyRxawEVyPG8cdrqvkfh5LgicVAn8UxcYl4BaVgZKwVKwg3lJe1zPjmu6vIghz4fUQXfVIQrLwV0BrHTEnMjTicXlCTXLt9cH5L0EVIk49Nc3lXapLg8YsyVgZKweH4vRHhlJ9sOmiG7vKpopIG7fUbjpfMb8YsyVSGWW7EHBXdpHTm8g8YsyVSGWW7EPliAF7pKt9IKadZle1R8g1lCTUxbdsdEHOEPliA3ROcE)PyaVyCVyPfegEVbVSe2RX3RGLrwXRJlqEq8sqEfFXll9YGHzcdLgWlc(9cH5LUGODVIk49NIb8ILEjT3l67glzzSxyS4wXlmkQ7Lobn(EHW8c3GgFQY3BbHHsUIZYyWNIrJV04GHUrL2jVff22adBqeIbEkQUXLtNiSP0(5bV)u4QNgj4WnJaAttpLjxXIZJi4tii5PWmGIA5w8fPMKeyykJhEcBz4kciq1eAscmmfxq0(2FiNQiGOvB3oGluuhFd28rBmkJQzXapfvWaGP0(P0sKWNQEAKGdRvBeqZfeTpp49NIbueqAkg4PO4cI2Nh8(tXaQNgj4Wq184cKhKdpdOoPjtWZyPDhH1)obecaJgNkUGO95bV)umGI(UXs(o4G)r1mgaHOqd9XfipihEgqDstMGNXs7ocR)DcieagnovCbr7ZdE)Pyaf9DJLCO0e4G)rHcFdIYOAgACAeAttpLjx9qlAIWMs7Nh8(tXaCf1YT4BqKGckO89((n51iKFVIQrLwV0BrHTEXW8sNGgFVqyEHBqJp1lg3lXapLd3GxKeIx5zs7PEXeVse1lZRrmUr3ROcE)PyaVyCVSGWW7EzIxs79QJ6pLg8YsyV2mdpZROjOCXlg3l6nyn8cr9Amda8I8ErVbRHxJzsll9sAVx5XfXlCf4QJyLV3ccdLCfNLXGpfJgFPXbdDJkTtElkSTbg2aXapffNGg)jcBcbn(u1tJeC4MrqsGHP4e04prytiOXNQiG0mGqay04ubm8SjjbLlk67gl57oioa3e6ied8uuCbr7ZdE)Pya1tJeC4MrangJ(5bV)umGIacuA1kg4PO4cI2Nh8(tXaQNgj4WnJaAUGO95bV)umGIacuq57TGWqjxXzzm4tXOXxACWqawCRKSmEcmoh5799BYlDiw3RnJf3kjlJ9kAeq4EbtqzzSx6cI29kQG3FkgWlycQjmu2GxmmV0ar4fmkJSIxTgE3RiFCEeb3lCdsEkmd4fI6vRH39IjEHsGgEHYWBWllH9cgLrwXlc(9AZyXTsYYyVIgbeVGjOSm2RObiemGGlEXW8sdeHxTgE3lZRnZWZ8sNGgFVWnuuq57TGWqjxXzzm4tXOXxACWqawCRKSmEsIasdmSbCbr7ZdE)PyafbKMIbEkkUGO95bV)umG6PrcoCtOnn9uMCflopIGpHGKNcZakQLB3nsA1gbjbgMcy4ztobn(kcinjjWWuKaecgqWffbeO89((n5fUQXfV2mwCRKSm2ROraXl6Jnkm4CUximVK27fe6XJHi4EfqjmtyO0lgMxAGiISWEbq87L5LUGO9T)qo1lUyHTEHOE1A4DV0feTV9hYPEzjSx4AJlN6fcZlP9EfvW7pfUxwqy4DLV3ccdLCfNLXGpfJgFPXbdbyXTsYY4jjcinWWganjbgMIliAF7pKtv03nwY3fhfoAooaRzscmmfxq0(2FiNQ4If2QvljbgMIliAF7pKtveqAssGHP6gxoDIWMs7Nh8(tHRiGaLV33VjVgH871iGI4Ix6TOWwVgZKwVI8HJrq1WllH9cxBC5uVqyEjT3ROcE)PWv(ElimuYvCwgd(umA8LghmegfXLjVff22adBGyGNIIfogbvd1tJeC4MIbEkQUXLtNiSP0(5bV)u4QNgj4WnjjWWuSWXiOAOiG0KKadt1nUC6eHnL2pp49NcxraX377TGWqjxXzzm4tXOXxACWqadpBssq5sdmSbKeyykJhEcBz4kci(EF)M8AekmattVx6e047fcZlCdA8PEjiV4qO3G9AeaS(9sVff26fdZRobqyqa3RNVZo3lJEVGqp)PO89wqyOKR4Smg8Py04lnoyimG1)K3IcBBiOra8Py04l8b40adBa9y0ZBnsWBAbHH3NpFNDo(WPjjbgMItqJ)eHnHGgFQIaIV33VjVgH871Mz4zEfnbLlEnMjTEPtqJVximVWnOXN6fdZlP9EbmU4feK8uygWlcUfFVqyEPliA3ROcE)PyaVAnEgzfVmVWiaaVGjOMWqPxJi4k9IH5LgicVcicaSxXx8YsK0EQxeCl(EHW8sAVxJyCJUxrf8(tXaEXW8sAVx03nwYYyVWyXTIxJnUx4G7AcVaOm(uLV3ccdLCfNLXGpfJgFPXbdbm8SjjbLlnWWgig4PO4cI2Nh8(tXaQNgj4WndieagnoN0BbPjjbgMItqJ)eHnHGgFQIastOpUa5b5WZaQtAYe8mwA3ry9VtaHaWOXPIliAFEW7pfdOOVBSKVdo4FunJbqik0qFCbYdYHNbuN0Kj4zS0UJW6FNacbGrJtfxq0(8G3FkgqrF3yjhknbo4FuO2nkJQzOXPrOnn9uMC1dTOjcBkTFEW7pfdWvul3IVbrckO0QfACu4G7Ag6JlqEqo8mG6KMmbpJL2Dew)qTtaHaWOXPIliAFEW7pfdOOVBSKVdo4FunJbqik0qJJchCxZqFCbYdYHNbuN0Kj4zS0UJW6hQDcieagnovCbr7ZdE)Pyaf9DJLCO0e4G)rHcQDH(4cKhKdpdOoPjtWZyPDhH1)obecaJgNkUGO95bV)umGI(UXs(o4G)r1mgaHOqd9XfipihEgqDstMGNXs7ocR)DcieagnovCbr7ZdE)Pyaf9DJLCO0e4G)rHckO89((n51iKFV2mdpZROjOCXRXmP1lDcA89cH5fUbn(uVyyEjT3lGXfVGGKNcZaErWT47fcZRraJEVIk49NIb8Q14zKv8Y8cJaa8cMGAcdLEnIGR0lgMxAGi8kGiaWEfFXllrs7PErWT47fcZlP9EnIXn6EfvW7pfd4fdZlP9ErF3yjlJ9cJf3kEn24EHdURj8cGY4tv(ElimuYvCwgd(umA8LghmeWWZMKeuU0adBqeIbEkkUGO95bV)umG6PrcoCZacbGrJZj9wqAssGHP4e04prytiOXNQiG0e6JlqEqo8mG6KMmbpJL2Dew)7eqiamACQWy0pp49NIbu03nwY3bh8pQMXaiefAOpUa5b5WZaQtAYe8mwA3ry9VtaHaWOXPcJr)8G3FkgqrF3yjhknbo4FuO2nkJQzOXPrOnn9uMC1dTOjcBkTFEW7pfdWvul3IVbrckO0QfACu4G7Ag6JlqEqo8mG6KMmbpJL2Dew)qTtaHaWOXPcJr)8G3FkgqrF3yjFhCW)OAgdGquOHghfo4UMH(4cKhKdpdOoPjtWZyPDhH1pu7eqiamACQWy0pp49NIbu03nwYHstGd(hfkO2f6JlqEqo8mG6KMmbpJL2Dew)7eqiamACQWy0pp49NIbu03nwY3bh8pQMXaiefAOpUa5b5WZaQtAYe8mwA3ry9VtaHaWOXPcJr)8G3FkgqrF3yjhknbo4FuOGckFVV3ccdLCfNLXGpfJgFPXbdbyXTsYY4jjcinWWgqsGHP4e04prytiOXNQiG47TGWqjxXzzm4tXOXxACWqadpBssq5sdmSbbecaJgNt6TG0mcXapfv34YPte2uA)8G3FkC1tJeCyFVVFtEPdyXTcqdVIT(9kYhogbvdVijWW8sqE1IGCmcaqdVijWW8IJ63R3HGgF6H9AeqrCXl9wuyl3RXmP1lCTXLt9cH5L0EVIk49Ncx57TGWqjxXzzm4tXOXxACWqSWXiOA0adBGyGNIIfogbvd1tJeC4MraD3oGluuhFro83mGqay04ubm8SjjbLlk67gl57oyuOAcDeIbEkkUGO95bV)umG6PrcoSwTCbr7ZdE)PyafmACcLV33BbHHsUIZYyWNIrJV04GHagE2KKGYLgyydcieagnoN0BbPzO1OXNJpXapf1dTOjcBkTFEW7pfU6PrcoSV33VjV0bS4wbOHxWhyA4fbNLXEf5dhJGQHxVdbn(0d71iGI4Ix6TOWwUxcYR3HGgFQxs77EnMjTEHRnUCQximVK27vubV)u4EjiKY3BbHHsUIZYyWNIrJV04GHWOiUm5TOW2gyyded8uuSWXiOAOEAKGd3KKadtXchJGQHIastscmmflCmcQgk67gl57IJchnhhG1mjbgMIfogbvdfxSWwFVV3ccdLCfNLXGpfJgFPXbdbm8SjjbLlnWWgeqiamACoP3cIV33VjVgXOmYkEzHad(PyaGgErWVx6e047fcZlCdA8PEnMjTEncaw)EP3IcB9cMGYYyV4SmgCVeJgFr57TGWqjxXzzm4tXOXxACWqyaR)jVff22qqJa4tXOXx4dWPbg2a6XON3AKG3mcscmmfNGg)jcBcbn(ufbeFVfegk5kolJbFkgn(sJdgsqY7ZUXLt1Obg2aXapfLGK3NDJlNQH6PrcoCtOjjWWu0ZrPLHpfK8UI(UXs(U4UwTqtsGHPONJsldFki5Df9DJL8DHMKadtz8WtyldxbtqnHHYgdieagnovgp8e2YWv03nwYHQzaHaWOXPY4HNWwgUI(UXs(U4GFOGY377TGWqjxXzzm4tXOXxACWqyuexM8wuyBdmSbIbEkkw4yeunupnsWHBssGHPyHJrq1qraPj0Keyykw4yeunu03nwY3noaR5rQzscmmflCmcQgkUyHTA1ssGHP4cI23(d5ufbeTAJqmWtr1nUC6eHnL2pp49Ncx90ibhgkFVfegk5kolJbFkgn(sJdgk0ASCcyXTsYY4gyydijWWuYdckzHP0sKWNQiG0mcscmmfxq0(2FiNQiG0Kd5aWumA8fUk0ASCcyXTsYYy8HJV3ccdLCfNLXGpfJgFPXbdbyXTsYY4jjci(ElimuYvCwgd(umA8LghmegW6FYBrHTn0r4XY4b40qqJa4tXOXx4dWPbg2a6XON3AKG77TGWqjxXzzm4tXOXxACWqyaR)jVff22qhHhlJhGtdmSbDeEV)uuWmUyz44d399BYRrafXfV0BrHTEX4EHiOE1r49(tXlmgaCQY3BbHHsUIZYyWNIrJV04GHWOiUm5TOW2g6i8yz8aCw64DkNHY1grAuC28rJCJU5kCW9OS0hB0KLX8LEKVdbrLd71i9YccdLEbyCHR89lDaJl81WlDolJbFkgn(YA41g4SgEP)0ibhEf9spqzYPmBPdTxr4LWcBzzSxA16LyGNIIliAFEW7pfdOEAKGd7vtVcieagnovCbr7ZdE)Pyaf9DJLCV21Ri5LM9koa7LwTEbJefgW6FYBrHTk67gl5ET7aVIdWEPvRxIbEkkJhEcBz4QNgj4WE10lyKOWaw)tElkSvrF3yj3RD9cAVcieagnovgp8e2YWv03nwY9QrVijWWugp8e2YWvWeutyO0lO8QPxbecaJgNkJhEcBz4k67gl5ETRxJ0RMEbTxr4LyGNIIliAFEW7pfdOEAKGd7LwTEjg4PO4cI2Nh8(tXaQNgj4WE10lUGO95bV)umGcgno9ckVGYRMEbTxKeyyQXSeEgtWffxSWwV21lCgPxA16LPPNYKRyX5re8jeK8uygqrTCRx4BGxrYlTA9IKadtbm8SjNGgFfbeV0Q1Ri8IKadtrcqiyabxueq8ckVA6veErsGHP4e04prytiOXNQiGS0TGWq5shdy9p5TOW2LS2isRHx6pnsWHxrV0duMCkZw6IbEkkJhEcBz4QNgj4WE10RacbGrJtfWWZMKeuUOOVBSK7f(8AuVA6f0EXfeTpp49NIbuWOXPxA16veEjg4PO4cI2Nh8(tXaQNgj4WEbLxn9cAVIWlXapfflCmcQgQNgj4WEPvRxr4fjbgMIfogbvdfbeVA6veEfqiamACQyHJrq1qraXlOw6wqyOCPB8WtyldFjRnIYA4L(tJeC4v0l9aLjNYSLUyGNI6G3FkgyscmUOEAKGd7vtVG2lXapfv34YPte2uA)8G3FkC1tJeCyVA6fjbgMQBC50jcBkTFEW7pfUIaIxn9QBhWfkQ71UEH7J6LwTEfHxIbEkQUXLtNiSP0(5bV)u4QNgj4WEbLxn9cAVIWlO9IliAFEW7pfdOiG4vtVed8uuCbr7ZdE)Pya1tJeCyVGYlTA9Y00tzYvPjeudmBnAhLAOOwU1RbEffVA6fjbgMAmlHNXeCrXflS1RD9cNr6fulDlimuU0p49NIbMKaJllzTXixdV0FAKGdVIEPhOm5uMT0fd8uuCbr7B)HCQ6PrcoSxn9cAVOgdEE8EkkdgMRciIu8AxVIIxA16f1yWZJ3trzWWCfl9cFEH)r9ckVA6f0EfHxIbEkkobn(te2ecA8PQNgj4WEPvRxKeyykobn(te2ecA8PkciEPvRxD7aUqrDVW3aVg5i9cQLUfegkx6Cbr7B)HC6swBG)1Wl9Ngj4WROx6bktoLzlDXapffGPjjyWZUf3TPGK3vpnsWH9QPxq7f1yWZJ3trzWWCvarKIx76vu8sRwVOgdEE8EkkdgMRyPx4Zl8pQxqT0TGWq5shW0Kem4z3I72uqY7lzTbUVgEP)0ibhEf9spqzYPmBPtsGHP4cI23(d5ufbeVA6fhYbGPy04lCvO1y5eWIBLKLXETRx4Uxn9cAVmn9uMCfWWZM8wuyRIA5wV0SxKeyykGHNn5TOWwfxSWwVGYRD9kk4Uxn9cAVijWWuDJlNorytP9ZdE)PWveq8QPxr4LyGNIItqJ)eHnHGgFQ6PrcoSxA16fjbgMItqJ)eHnHGgFQIaIxqT0TGWq5shWIBLKLXtseqwYAJi3A4L(tJeC4v0l9aLjNYSLEeErsGHP4e04prytiOXNQiG4vtVed8uuDJlNorytP9ZdE)PWvpnsWH9QPxq7fjbgMQBC50jcBkTFEW7pfUIaIxA16vaHaWOXPcy4ztsckxu03nwY9cFEnQxn9QBhWfkQ7f(g41MhjVA0ROmQxA2lXapfvWaGP0(P0sKWNQEAKGd7LwTEbTxMMEktUcy4ztElkSvrTCRxA2lscmmfWWZM8wuyRIlwyRx76vuWDVGYRMErsGHP4cI23(d5ufbeVA6vaHaWOXPcy4ztsckxu03nwY9A3bEfhG9ckV0Q1Ri8smWtr1nUC6eHnL2pp49Ncx90ibh2RMEfHxq7LPPNYKRyX5re8jeK8uygqrTCRx4ZRi5vtVijWWugp8e2YWveq8ckVA6f0ErsGHP4cI23(d5ufbeV0Q1RUDaxOOUx4BGxB(OE1OxrzuV0SxIbEkQGbatP9tPLiHpv90ibh2lTA9kcVG2lUGO95bV)umGIaIxn9smWtrXfeTpp49NIbupnsWH9ckVA61XfipihEgqDstMGNXsRx74LW63RD8kGqay04uXfeTpp49NIbu03nwY9AhVWb)J6LM9cdGquVG2lO964cKhKdpdOoPjtWZyP1RD8sy971oEfqiamACQ4cI2Nh8(tXak67gl5EbLxAcVWb)J6fuEHVbEfLr9sZEbTx44vJEbTxMMEktU6Hw0eHnL2pp49NIb4kQLB9cFd8ksEbLxq5fulDlimuU0VrL2jVff2UK1g42RHx6pnsWHxrV0duMCkZw6IbEkkobn(te2ecA8PQNgj4WE10Ri8IKadtXjOXFIWMqqJpvraXRMEfqiamACQagE2KKGYff9DJLCV2DGxXbyVA6f0EfHxIbEkkUGO95bV)umG6PrcoSxn9kcVG2lmg9ZdE)PyafbeVGYlTA9smWtrXfeTpp49NIbupnsWH9QPxr4f0EXfeTpp49NIbueq8ckVGAPBbHHYL(nQ0o5TOW2LS2yZxdV0FAKGdVIEPhOm5uMT05cI2Nh8(tXakciE10lXapffxq0(8G3Fkgq90ibh2RMEbTxMMEktUIfNhrWNqqYtHzaf1YTETRxrYlTA9kcVijWWuadpBYjOXxraXRMErsGHPibiemGGlkciEb1s3ccdLlDalUvswgpjrazjRnWz01Wl9Ngj4WROx6bktoLzlDXapfflCmcQgQNgj4WE10lXapfv34YPte2uA)8G3FkC1tJeCyVA6fjbgMIfogbvdfbeVA6fjbgMQBC50jcBkTFEW7pfUIaYs3ccdLlDmkIltElkSDjRnWbN1Wl9Ngj4WROx6bktoLzlDscmmLXdpHTmCfbKLUfegkx6adpBssq5YswBGtKwdV0FAKGdVIEPhOm5uMT0PhJEERrcUxn9YccdVpF(o7CVWNx44vtVijWWuCcA8NiSje04tveqw6wqyOCPJbS(N8wuy7swBGtuwdV0FAKGdVIEPhOm5uMT0fd8uuCbr7ZdE)Pya1tJeCyVA6vaHaWOX5KEliE10lscmmfNGg)jcBcbn(ufbeVA6f0EDCbYdYHNbuN0Kj4zS061oEjS(9AhVcieagnovCbr7ZdE)Pyaf9DJLCV2XlCW)OEPzVWaie1lO9cAVoUa5b5WZaQtAYe8mwA9AhVew)ETJxbecaJgNkUGO95bV)umGI(UXsUxq5LMWlCW)OEbLx76vug1ln7f0EHJxn6f0EzA6Pm5QhArte2uA)8G3FkgGROwU1l8nWRi5fuEbLxA16f0EHJchC3ln7f0EDCbYdYHNbuN0Kj4zS061oEjS(9ckV2XRacbGrJtfxq0(8G3FkgqrF3yj3RD8ch8pQxA2lmacr9cAVG2lCu4G7EPzVG2RJlqEqo8mG6KMmbpJLwV2XlH1Vxq51oEfqiamACQ4cI2Nh8(tXak67gl5EbLxAcVWb)J6fuEbLx76f0EDCbYdYHNbuN0Kj4zS061oEjS(9AhVcieagnovCbr7ZdE)Pyaf9DJLCV2XlCW)OEPzVWaie1lO9cAVoUa5b5WZaQtAYe8mwA9AhVew)ETJxbecaJgNkUGO95bV)umGI(UXsUxq5LMWlCW)OEbLxq5fulDlimuU0bgE2KKGYLLS2aNrUgEP)0ibhEf9spqzYPmBPhHxIbEkkUGO95bV)umG6PrcoSxn9kGqay04CsVfeVA6fjbgMItqJ)eHnHGgFQIaIxn9cAVoUa5b5WZaQtAYe8mwA9AhVew)ETJxbecaJgNkmg9ZdE)Pyaf9DJLCV2XlCW)OEPzVWaie1lO9cAVoUa5b5WZaQtAYe8mwA9AhVew)ETJxbecaJgNkmg9ZdE)Pyaf9DJLCVGYlnHx4G)r9ckV21ROmQxA2lO9chVA0lO9Y00tzYvp0IMiSP0(5bV)umaxrTCRx4BGxrYlO8ckV0Q1lO9chfo4UxA2lO964cKhKdpdOoPjtWZyP1RD8sy97fuETJxbecaJgNkmg9ZdE)Pyaf9DJLCV2XlCW)OEPzVWaie1lO9cAVWrHdU7LM9cAVoUa5b5WZaQtAYe8mwA9AhVew)EbLx74vaHaWOXPcJr)8G3FkgqrF3yj3lO8st4fo4FuVGYlO8AxVG2RJlqEqo8mG6KMmbpJLwV2XlH1Vx74vaHaWOXPcJr)8G3FkgqrF3yj3RD8ch8pQxA2lmacr9cAVG2RJlqEqo8mG6KMmbpJLwV2XlH1Vx74vaHaWOXPcJr)8G3FkgqrF3yj3lO8st4fo4FuVGYlO8cQLUfegkx6adpBssq5YswBGd(xdV0FAKGdVIEPhOm5uMT0jjWWuCcA8NiSje04tveqw6wqyOCPdyXTsYY4jjcilzTbo4(A4L(tJeC4v0l9aLjNYSLEaHaWOX5KEliE10Ri8smWtr1nUC6eHnL2pp49Ncx90ibhEPBbHHYLoWWZMKeuUSK1g4e5wdV0FAKGdVIEPhOm5uMT0fd8uuSWXiOAOEAKGd7vtVIWlO9QBhWfkQ7f(8kYHFVA6vaHaWOXPcy4ztsckxu03nwY9A3bEnQxq5vtVG2Ri8smWtrXfeTpp49NIbupnsWH9sRwV4cI2Nh8(tXaky040lOw6wqyOCPZchJGQXswBGdU9A4L(tJeC4v0l9aLjNYSLEaHaWOX5KEliE10RqRrJp3l85LyGNI6Hw0eHnL2pp49Ncx90ibhEPBbHHYLoWWZMKeuUSK1g4S5RHx6pnsWHxrV0duMCkZw6IbEkkw4yeunupnsWH9QPxKeyykw4yeunueq8QPxKeyykw4yeunu03nwY9AxVWrHJxA2R4aSxA2lscmmflCmcQgkUyHTlDlimuU0XOiUm5TOW2LS2isJUgEP)0ibhEf9spqzYPmBPhqiamACoP3cYs3ccdLlDGHNnjjOCzjRnIeoRHx6pnsWHxrV0duMCkZw60JrpV1ib3RMEfHxKeyykobn(te2ecA8PkcilDlimuU0Xaw)tElkSDjRnIuKwdV0FAKGdVIEPhOm5uMT0fd8uucsEF2nUCQgQNgj4WE10lO9IKadtrphLwg(uqY7k67gl5ETRx4UxA16f0ErsGHPONJsldFki5Df9DJLCV21lO9IKadtz8WtyldxbtqnHHsVA0RacbGrJtLXdpHTmCf9DJLCVGYRMEfqiamACQmE4jSLHROVBSK71UEHd(9ckVGAPBbHHYLUGK3NDJlNQXswBePOSgEP)0ibhEf9spqzYPmBPlg4POyHJrq1q90ibh2RMErsGHPyHJrq1qraXRMEbTxKeyykw4yeunu03nwY9AxVIdWEPzVgPxA2lscmmflCmcQgkUyHTEPvRxKeyykUGO9T)qovraXlTA9kcVed8uuDJlNorytP9ZdE)PWvpnsWH9cQLUfegkx6yuexM8wuy7swBePrUgEPBbHHYLoGf3kjlJNKiGS0FAKGdVIEjRnIe(xdV07i8yz8shNL(tJeC4v0l9aLjNYSLo9y0ZBnsWx6wqyOCPJbS(N8wuy7swBejCFn8sVJWJLXlDCw6pnsWHxrV0duMCkZw6DeEV)uuWmUyz4EHpVW9LUfegkx6yaR)jVff2UK1grkYTgEP3r4XY4LoolDlimuU0XOiUm5TOW2L(tJeC4v0lzjlDd91WRnWzn8s)Prco8k6LEGYKtz2sxmWtrXfeTV9hYPQNgj4WlDlimuU05cI23(d50LS2isRHx6pnsWHxrV0duMCkZw60JrpV1ib3RMEbTxCihaMIrJVWvHwJLtalUvswg71UEbTx43RD8kcVed8uucsEF2nUCQgQNgj4WEbLxA16veEjg4PO4cI2Nh8(tXaQNgj4WE10lO9kGqay04uHXOFEW7pfdOOVBSK7f(8cAVWjsJ6vJEHZi9sZEXHCay2AC5EbLxA16vaHaWOXPcJr)8G3FkgqrF3yj3RD9cAVI0i9AhVWzKEPzV4qoamBnUCVGYlO8ckVA6f0EfHxIbEkkUGO95bV)umG6PrcoSxA16fxq0(8G3FkgqbJgNEPvRxCihaMIrJVWvHwJLtalUvswg71aVIIxn9IKadtnMLWZycUO4If261UEHZi9cQLUfegkx6yaR)jVff2U0dAeaFkgn(cFTbolzTruwdV0FAKGdVIEPhOm5uMT0fd8uugp8e2YWvpnsWH9QPxq7LyGNIIliAFEW7pfdOEAKGd7vtV4cI2Nh8(tXaky040RMEfqiamACQ4cI2Nh8(tXak67gl5EHpVWb)EPvRxr4LyGNIIliAFEW7pfdOEAKGd7fuE10lO9kcVed8uuSWXiOAOEAKGd7LwTEfHxKeyykw4yeunueq8QPxr4vaHaWOXPIfogbvdfbeVGAPBbHHYLUXdpHTm8LS2yKRHx6pnsWHxrV0duMCkZw6IbEkkattsWGNDlUBtbjVREAKGdV0TGWq5shW0Kem4z3I72uqY7lzTb(xdV0FAKGdVIEPhOm5uMT0JWlXapfv34YPte2uA)8G3FkC1tJeCyV0Q1lscmmfxq0(2FiNQiG4LwTE1Td4cf19cFd8cAVWz0r9AhVgPxA2loKdatXOXx4QqRXYjGf3kjlJ9ckV0Q1lscmmv34YPte2uA)8G3FkCfbeV0Q1loKdatXOXx4QqRXYjGf3kjlJ9cFEfLLUfegkx63OsRMKW2(LS2a3xdV0FAKGdVIEPhOm5uMT0jjWWuCbr7B)HCQI(UXsUx76vu8sZEfhG9sZErsGHP4cI23(d5ufxSW2LUfegkx6HwJLtalUvswgVK1grU1Wl9Ngj4WROx6bktoLzlDscmmfWWZMCcA8veq8QPxCihaMIrJVWvHwJLtalUvswg71UEnsVA6f0EfHxIbEkkUGO95bV)umG6PrcoSxA16fxq0(8G3FkgqbJgNEbLxn9cgjkmG1)K3IcBvclSLLXlDlimuU0bgE2KKGYLLS2a3En8s)Prco8k6LEGYKtz2sNd5aWumA8fUk0ASCcyXTsYYyV21Rr6vtVIWlscmmLXdpHTmCfbKLUfegkx6SWXiOASK1gB(A4L(tJeC4v0l9aLjNYSLohYbGPy04lCvO1y5eWIBLKLXETRxJ0RMErsGHPyHJrq1qraXRMEfHxKeyykJhEcBz4kcilDlimuU0XOiUm5TOW2LS2aNrxdV0FAKGdVIEPhOm5uMT0fd8uuh8(tXatsGXf1tJeCyVA6fhYbGPy04lCvO1y5eWIBLKLXETRxJ0RMEbTxr4LyGNIIliAFEW7pfdOEAKGd7LwTEXfeTpp49NIbuWOXPxqT0TGWq5s)G3FkgyscmUSK1g4GZA4L(tJeC4v0l9aLjNYSLUyGNIY4HNWwgU6Prco8s3ccdLlDGHNnjV1xYAdCI0A4LUfegkx6HwJLtalUvswgV0FAKGdVIEjRnWjkRHx6DeESmEPJZs)Prco8k6LEGYKtz2sxmWtrz8Wtyldx90ibhEPBbHHYLoWWZMKeuUSK1g4mY1Wl9ocpwgV0XzP)0ibhEf9spqzYPmBPtpg98wJe8LUfegkx6yaR)jVff2UK1g4G)1Wl9ocpwgV0XzPBbHHYLogfXLjVff2U0FAKGdVIEjlzPdFmJaiRHxBGZA4L(tJeC4f5spqzYPmBPBA6Pm5kldNludmPNJsldx90ibhEPBbHHYLojaHGbeCzjRnI0A4L(tJeC4v0l9aLjNYSL(XfipihEgqDstMGNXsRx74LW63RD9kkJ6LwTEHXOFEW7pfdOiG4LwTEXfeTpp49NIbueqw6wqyOCPdbjmuUK1grzn8s3ccdLl9XSeEYBVrx6pnsWHxrVK1gJCn8s)Prco8k6LEGYKtz2sxmWtrji59z34YPAOEAKGd7vtVijWWu0ZrPLHpfK8UI(UXsUx76vKw6wqyOCPli59z34YPASK1g4Fn8s)Prco8k6LEGYKtz2spcVed8uuCbr7ZdE)Pya1tJeC4LUfegkx6ym6Nh8(tXalzTbUVgEP)0ibhEf9spqzYPmBPlg4PO4cI2Nh8(tXaQNgj4WE10lO9kcVed8uuSWXiOAOEAKGd7LwTEfHxKeyykw4yeunueq8QPxr4vaHaWOXPIfogbvdfbeVGYRMEbTxr4LyGNIY4HNWwgU6PrcoSxA16veEfqiamACQmE4jSLHRiG4fulDlimuU05cI2Nh8(tXalzTrKBn8s)Prco8k6LEGYKtz2spcVed8uuqOSUbMh8(tXamUOEAKGd7LwTEjg4POGqzDdmp49NIbyCr90ibh2RMEbTxym6Nh8(tXaky040RMEfHxIbEkkUGO95bV)umG6PrcoSxA16fxq0(8G3FkgqbJgNE10lXapffxq0(8G3Fkgq90ibh2lOw6wqyOCPFJkTZdE)PyGLS2a3En8s3ccdLlDc(Nm5D(s)Prco8k6LS2yZxdV0TGWq5spGYWtHAYHNyaR)L(tJeC4v0lzTboJUgEPBbHHYLojaHGNiSP0(5Z31yP)0ibhEf9swBGdoRHx6wqyOCPhtyuyMLte2000trs7s)Prco8k6LS2aNiTgEPBbHHYLogkqWp8000tzYNK36l9Ngj4WROxYAdCIYA4LUfegkx6qiOmmnyz8KeyCzP)0ibhEf9swBGZixdV0TGWq5sxA)Kijrej8edrdFP)0ibhEf9swBGd(xdV0TGWq5sV)oIQXeHnbebg8eMERZx6pnsWHxrVK1g4G7RHx6wqyOCPtzqGa(KLtoel8L(tJeC4v0lzTborU1WlDlimuU0hJOay8olN0ZrPLHV0FAKGdVIEjRnWb3En8s)Prco8k6LEGYKtz2spcVed8uugp8e2YWvpnsWH9sRwVijWWugp8e2YWveq8sRwVcieagnovgp8e2YWv03nwY9cFEH)rx6wqyOCPtcqi4jgbvJLS2aNnFn8s)Prco8k6LEGYKtz2spcVed8uugp8e2YWvpnsWH9sRwVijWWugp8e2YWveqw6wqyOCPtEk)0TSmEjRnI0ORHx6pnsWHxrV0duMCkZw6r4LyGNIY4HNWwgU6PrcoSxA16fjbgMY4HNWwgUIaIxA16vaHaWOXPY4HNWwgUI(UXsUx4Zl8p6s3ccdLlDmg9KaecEjRnIeoRHx6pnsWHxrV0duMCkZw6r4LyGNIY4HNWwgU6PrcoSxA16fjbgMY4HNWwgUIaIxA16vaHaWOXPY4HNWwgUI(UXsUx4Zl8p6s3ccdLlDldNludmdgaSK1grksRHx6pnsWHxrV0duMCkZw6Cbr7ZdE)PyafbeVA6fjbgMkyaWeWIBLKLXk67gl5EHVbEHBV0TGWq5s)A8jcBkTFYfeTVK1grkkRHx6wqyOCP3VCeDP)0ibhEf9swBePrUgEP)0ibhEf9s3ccdLlDkroTGWq5eW4YspqzYPmBPBbHH3NpFNDUx4Zl87vtVG2loKdatXOXx4QqRXYjGf3kjlJ9cFEHFV0Q1loKdatXOXx4kGHNnjV19cFEHFVGAPdyCzMw)lDd9LS2is4Fn8s)Prco8k6LUfegkx6uICAbHHYjGXLLoGXLzA9V05Smg8Py04llzjlDi0hqDstwdV2aN1Wl9Ngj4WROxYAJiTgEP)0ibhEf9swBeL1Wl9Ngj4WROxYAJrUgEP)0ibhEf9swBG)1WlDlimuU0fK8(SBC5unw6pnsWHxrVK1g4(A4L(tJeC4v0l9aLjNYSLUyGNIIliAF7pKtvpnsWH9QPxq7f1yWZJ3trzWWCvarKIx76vu8sRwVOgdEE8EkkdgMRyPx4Zl8pQxqT0TGWq5sNliAF7pKtxYAJi3A4L(tJeC4v0l9aLjNYSLEeEjg4PO4cI2Nh8(tXaQNgj4WlDlimuU0Xy0pp49NIbwYAdC71Wl9Ngj4WROx6bktoLzlDXapffxq0(8G3Fkgq90ibhEPBbHHYLoxq0(8G3FkgyjRn281WlDlimuU0HGegkx6pnsWHxrVK1g4m6A4L(tJeC4v0l9aLjNYSLUyGNI6G3FkgyscmUOEAKGdV0TGWq5s)G3FkgyscmUSK1g4GZA4L(tJeC4v0l9aLjNYSLEeEjg4POo49NIbMKaJlQNgj4WlDlimuU0bgE2KKGYLLS2aNiTgEP)0ibhEf9spqzYPmBPlg4POo49NIbMKaJlQNgj4WlDlimuU0p49NIbMKaJllzTborzn8s)Prco8k6LEGYKtz2spcVed8uuCbr7B)HCQ6PrcoSxn9Id5aWumA8fUx4ZlO9ksJ6vJEzA6Pm5kwCEebFcbjpfMbuul36f(8AuVGAPBbHHYLEO1y5eWIBLKLXlzjlzPBeslIU01FGEXlCZrqaFjlzTa]] )

    spec:RegisterOptions( {
        enabled = true,

        aoe = 3,

        nameplates = false,
        nameplateRange = 8,

        damage = true,
        damageExpiration = 6,

        potion = "potion_of_unbridled_fury",

        package = "Elemental",
    } )

    --[[ spec:RegisterSetting( "micromanage_pets", true, {
        name = "Micromanage Primal Elemental Pets",
        desc = "If checked, Meteor, Eye of the Storm, etc. will appear in your recommendations.",
        type = "toggle",
        width = 1.5
    } ) ]]

end
