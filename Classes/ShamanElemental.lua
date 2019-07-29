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


    spec:RegisterSetting( "funnel_targets", 0, {
        name = "Funnel |T237582:0|t Lava Burst Targets",
        desc = function ()
            local s = "If set above 0, the addon will recommend spreading |T135813:0|t Flame Shock on up to 5 targets, and funnel |T237582:0|t Lava Bursts into your current target."

            if not Hekili.DB.profile.specs[ spec.id ].cycle then
                s = s .. "\n\n|cFFFF0000Requires 'Recommend Target Swaps' on Targeting tab.|r"
            end

            return s
        end, 
        type = "range",
        min = 0,
        max = 10,
        step = 1,
        width = 1.5
    } )


    spec:RegisterStateExpr( "funneling", function ()
        return active_enemies > 1 and settings.cycle and settings.funnel_targets > 0 and active_enemies <= settings.funnel_targets
    end )


    spec:RegisterPack( "Elemental", 20190729, [[defX3bqiHIhjuPljucBsk5tcLOrbsDkOIvrc8kfPMLuk3sPODrQFPizykQCmqYYGk1ZeQyAGaxtOuBJeuFtOQ04ibjNtOKwhujX7ibPW8aHUNIyFqv6FGGO6GGG0cLs1dHkbtuOQQlkuLncvs6JqLqnsqquoPqvLvcIEjjivZeeu3eQKANkQ6NGGWqjbXsHkH8usAQkfUQqvXxbbrgljiLoljifTxL8xfgSOdtzXi1JfmzOCzvBguFwiJwkonkVwrz2a3wQ2TKFdz4kvhhQeTCephvtN46iz7qv9DLsJhQcNNeA9qv08jr7NQxqT2yPIzYxZJ75GkwNl(I7yvdvScvSIBOwQII7FPUBHzw0xQL1)snEG3FjgyPUBkcqg2AJLkhrrcFP2iYohxzQPIysdfToG6tXzDkGjmufigSmfN1dtTuPPyaj(vl6LkMjFnpUNdQyDU4lUJvnuXkukCCI9sLV)WAECRW4EP2WWWETOxQyNhwQX1Z4bE)LyapvBSUvoKX1Zgr254ktnvetAOO1buFkoRtbmHHQaXGLP4SEykhY46jKuaf9e3XABEI75Gkw9CtpHkwXvMBohshY46jUqJvrNJR4qgxp30Z4d)EQq74G3FjgqtT7jXKMt8uASYZqZdZyvKNbecGH2wCpfKN8FpzWEEW7VedW90i3tlim8V2HmUEUPNXFg3ObhZZ4zePXZ4bE)LyapFje25AhY465MEIl6De(3tiuE4fMvH7PW6FQ2HWEgAEyM2HmUEUPNqOyyEgpfVNiypLM7PQGiDpNYtC9LJi6L6obbZaFPgxpJh49xIb8uTX6w5qgxpBezNJRm1urmPHIwhq9P4SofWegQcedwMIZ6HPCiJRNqsbu0tChRT5jUNdQy1Zn9eQyfxzU5CiDiJRN4cnwfDoUIdzC9CtpJp87PcTJdE)Lyan1UNetAoXtPXkpdnpmJvrEgqiagABX9uqEY)9Kb75bV)sma3tJCpTGWW)AhY465MEg)zCJgCmpJNrKgpJh49xIb88LqyNRDiJRNB6jUO3r4FpHq5HxywfUNcR)PAhc7zO5HzAhY465MEcHIH5z8u8EIG9uAUNQcI09CkpX1xoIODiDiJRNXdpEGsoMN0hgrUNbuN2epPFeR4ApHqdHVlCpluTzJr6WuapTGWqf3tubuu7qgxpTGWqfxVtEa1PnzcmW4ZCiJRNwqyOIR3jpG60Mm9KPGrimhY46PfegQ46DYdOoTjtpzkJkQ)smHHkhY46PAz78gK4jXyyEstbdFmp5IjCpPpmICpdOoTjEs)iwX90kmp3jFZDKiSkYtg3tmuDTdzC90ccdvC9o5buN2KPNmfVSDEdsgCXeUdPfegQ46DYdOoTjtpzkbjVp6gxorrhY46PfegQ46DYdOoTjtpzQBePzCW7Ved0gdEsmIbEj6DcRBGXbV)smaJl6xgn4yoKoKX1Z4d)EQkisF2)(jEUtEa1PnXtQcCo3toQFpnmmUNBzaGN8DBB5jhHkTdPfegQ46DYdOoTjtpzkUGi9z)7N0gdEIyGxIMlisF2)(j6xgn4yTGMymSXX)LOnmmUoGOkbIXrPsIXWgh)xI2WW4AwH3yphooKoKwqyOIR3jpG60Mm9KPGzKpo49xIbAJbpjgXaVenxqK(4G3Fjgq)YObhZH0ccdvC9o5buN2KPNmfxqK(4G3FjgOng8eXaVenxqK(4G3Fjgq)YObhZH0ccdvC9o5buN2KPNm1osyOYH0ccdvC9o5buN2KPNm1bV)smWGgyCPng8eXaVe9bV)smWGgyCr)YObhZH0ccdvC9o5buN2KPNmfWW3g0ueU0gdEsmIbEj6dE)LyGbnW4I(Lrdowl((bGHyKOlCDOXy1aWIAKIvrqmooKwqyOIR3jpG60Mm9KPcngRgawuJuSkQng8e((bGHyKOlCDOXy1aWIAKIvr4f3oKoKX1Z4HhpqjhZZJ)jk6PW63tP5EAbbr8KX90W3yaJgCTdzC9exW4INTdqimafx8SBfLbak6jd2tP5EcHINNWK75geJjEcHwHZfIb8ex05OYQW9KX9CNC(lr7qAbHHk(eAacHbO4sBm4jgEEctU2QW5cXadY5OYQW1VmAWXCiJRNXVAZaQtBIN7iHHkpzCp3jh(KxcZaaf9eWQzhZtb5PIikINXd8(lXaT5jvboN7za1PnXZTmaWZxyEYBqebOOdPfegQ4tpzQDKWqvBm4jhp2Fqo2iG60MmaVIKMnfw)qmoZPujmJ8XbV)smGMAxPsUGi9XbV)smGMA3HmUEg)k5ec1U4jc2ZGXfU2H0ccdv8PNm1wwHn4n3ioKwqyOIp9KPeK8(OBC5efBJbprmWlrli59r34YjkQFz0GJ1IMcgwtohvwf(qqY7AY7gR4qe3oKwqyOIp9KPO4FWK35oKwqyOIp9KPGzKpo49xIbAJbpjgXaVenxqK(4G3Fjgq)YObhZH0ccdv8PNmfxqK(4G3FjgOng8eXaVenxqK(4G3Fjgq)YObhRf0Xig4LOzHdtruu)YObhtPYyOPGH1SWHPikQP2BftaHayOTLMfomfrrn1ooTGogXaVeTXdVWSkC9lJgCmLkJjGqam02sB8WlmRcxtTJJdzC90ccdv8PNm1nI0mo49xIbAJbpjgXaVe9oH1nW4G3FjgGXf9lJgCmLkfd8s07ew3aJdE)Lyagx0VmAWXAbnmJ8XbV)smGgdTTAfJyGxIMlisFCW7VedOFz0GJPujxqK(4G3FjgqJH2wTed8s0Cbr6JdE)Lya9lJgCmCCiTGWqfF6jtfqv4Lqm5ydyG1VdPfegQ4tpzkAacHnqWdP5JxVROdPfegQ4tpzQikJGXSAGGhgEEcsACiTGWqfF6jtbJcu8Jnm88eM8b9TUdPfegQ4tpzQDkcdwrwfnObgxCiTGWqfF6jtjnFqv0iQcBaJiH7qAbHHk(0tMQ)oIO4abpaubg2aJCRZDiTGWqfF6jtry77Gpy1GVBH7qAbHHk(0tMAlIaWW)SAqohvwfUdPfegQ4tpzkAacHnGPik2gdEsmIbEjAJhEHzv46xgn4ykvstbdRnE4fMvHRP2vQmGqam02sB8WlmRcxtE3yfhVXEohslimuXNEYu0NWpzgRIAJbpjgXaVeTXdVWSkC9lJgCmLkPPGH1gp8cZQW1u7oKwqyOIp9KPGzKtdqiS2yWtIrmWlrB8WlmRcx)YObhtPsAkyyTXdVWSkCn1UsLbecGH2wAJhEHzv4AY7gR44n2Z5qAbHHk(0tMYQW5cXaJGbaTXGNeJyGxI24HxywfU(LrdoMsL0uWWAJhEHzv4AQDLkdieadTT0gp8cZQW1K3nwXXBSNZH0ccdv8PNm1v8de8qA(GlisVng8eUGi9XbV)smGMAVfnfmSoyaWaWIAKIvrAY7gR44DIcLdPfegQ4tpzQ(LJioKwqyOIp9KPiu1WccdvdaJlTvw)tm0BJbpXccd)pE9o7C8I7wXatv1bSkYH0ccdv8PNmfHQgwqyOAayCPTY6FcNvrGpeJeDXH0HmUEIRPacZtXirx80ccdvEUtyictu0taJloKwqyOIRn0NWfePp7F)K2yWted8s0Cbr6Z(3pr)YObhZHmUEQUtUH5jUkW63t1guyMNSYtioXtiWtXirx8eMf1i828KMs8SqINyuewf5PA88KAxy93gvboN7PIiQyj5EcZIAewf5zC8ums0fUNwH5zJH)9eCo3tPXkpHcc8ecjwH5jUykU4jxSWmU2H0ccdvCTH(0tMcgy9p4nOWS2ckgaFigj6cFcuTXGNqom58gJg8wqZ3pameJeDHRdngRgawuJuSkcIqh7nJrmWlrli59r34YjkQFz0GJHJsLXig4LO5cI0hh8(lXa6xgn4yTGgMr(4G3FjgqtE3yfhVqdfeOa((bGrJXLJJsLbecGH2wAyg5JdE)Lyan5DJvCicnUHGnHccuaF)aWOX4YXbhCAbDmIbEjAUGi9XbV)smG(LrdoMsLCbr6JdE)LyangABPujF)aWqms0fUo0ySAayrnsXQOjXPfnfmSElRWgruCrZflmdIqbb44qAbHHkU2qF6jtz8WlmRcVng8eXaVeTXdVWSkC9lJgCSwqlg4LO5cI0hh8(lXa6xgn4yT4cI0hh8(lXaAm02QvaHayOTLMlisFCW7VedOjVBSIJxOITsLXig4LO5cI0hh8(lXa6xgn4y40c6yed8s0SWHPikQFz0GJPuzm0uWWAw4Wuef1u7TIjGqam02sZchMIOOMAhhhslimuX1g6tpzkadxsXWgDlQBdbjV3gdEIyGxIgWWLumSr3I62qqY76xgn4yoKoKX1Znik6PG8mY63Z4zePbxszZUNBzsJN4AJlN4jc2tP5EgpW7VeUN0uWWEUT5LNWSOgHvrEghpfJeDHR9m(JQyP4jc)tc2UN4A7aUqq9yCiTGWqfxBOp9KPUrKgCjLn7TXGNeJyGxIUBC5KbcEinFCW7VeU(LrdoMNkv6jnfmSMlisF2)(jAQDpvQ0ZUDaxiOoENanuZn3MqGc47hagIrIUW1HgJvdalQrkwfHJNkv6jnfmSUBC5KbcEinFCW7VeUMA3tLk9KVFayigj6cxhAmwnaSOgPyveEJJdPfegQ4Ad9PNm1nI0GlPSzVng8eOJrmWlr3nUCYabpKMpo49xcx)YObhtPsAkyyD34Yjde8qA(4G3FjCn1UsL0uWWAGHVn4uKORXqBlLk57hagIrIUW13isdUKYMD8obcWPf00uWWAUGi9z)7NOP2vQSBhWfcQJ3jqd1CZTjeOa((bGHyKOlCDOXy1aWIAKIvr4OujnfmSUBC5KbcEinFCW7VeUMAxPs((bGHyKOlCDOXy1aWIAKIvr4no44qgxpX12S7jNICpver5jgQILINae)EAEQkisF2)(jAhslimuX1g6tpzQqJXQbGf1ifRIAJbpHMcgwZfePp7F)en5DJvCighfefWuanfmSMlisF2)(jAUyHzoKoKX1tiefqrpdgx8ecB4BE2ofHlEIkpLgYVNIrIUW9Kb7jt8KX90kpzfxSs80kmpvfeP7z8aV)smGNmUNZdHydpTGWW)AhslimuX1g6tpzkGHVnOPiCPng8eAkyynWW3gCks01u7T47hagIrIUW1HgJvdalQrkwfbriOf0Xig4LO5cI0hh8(lXa6xgn4ykvYfePpo49xIb0yOTfoTWqIggy9p4nOWmTWcZyvKdPfegQ4Ad9PNmflCykIITXGNW3pameJeDHRdngRgawuJuSkcIqqRyOPGH1gp8cZQW1u7oKwqyOIRn0NEYuWeexg8guywBm4j89dadXirx46qJXQbGf1ifRIGie0IMcgwZchMIOOMAVvm0uWWAJhEHzv4AQDhshY46z8HFpJh49xIb8SDGXfpTiJvCXtQDpfKNXXtXirx4EACpbOkYtJ7PQGiDpJh49xIb8KX9SqINwqy4FTdPfegQ4Ad9PNm1bV)smWGgyCPng8eXaVe9bV)smWGgyCr)YObhRfF)aWqms0fUo0ySAayrnsXQiicbTGogXaVenxqK(4G3Fjgq)YObhtPsUGi9XbV)smGgdTTWXH0ccdvCTH(0tMcy4Bd6B92yWted8s0gp8cZQW1VmAWXCiTGWqfxBOp9KPcngRgawuJuSkYH0ccdvCTH(0tMcy4BdAkcxARJWNvrtGQng8eXaVeTXdVWSkC9lJgCmhslimuX1g6tpzkyG1)G3GcZARJWNvrtGQTGIbWhIrIUWNavBm4jKdtoVXOb3H0ccdvCTH(0tMcMG4YG3GcZARJWNvrtGYH0HmUEQYQiW9CdJeDXti0GWqLNkecdryIIEcHzCXHmUEgVItrUN4QQEY4EAbHH)9KQaNZ9ureLNng(3tOGaprep7iY9Klwyg3teSNqiXkmpXftXfpHjOUNQcI09mEG3Fjgq7j0Xdl6Egm(Xv8KApG6SkYtiuEWtAkXtlim8VNQXtHgEIHQyP4jooKwqyOIR5Skc8HyKOltGbw)dEdkmRTGIbWhIrIUWNavBm4jqhJWcZyvKsLIbEjAUGi9XbV)smG(LrdowRacbWqBlnxqK(4G3FjgqtE3yfhI4wbrbmLkXqIggy9p4nOWmn5DJvCiojkGPuPyGxI24HxywfU(LrdowlmKOHbw)dEdkmttE3yfhIqhqiagABPnE4fMvHRjVBSIpnnfmS24HxywfUgJIycdv40kGqam02sB8WlmRcxtE3yfhIqqlOJrmWlrZfePpo49xIb0VmAWXuQumWlrZfePpo49xIb0VmAWXAXfePpo49xIb0yOTfo40cAAkyy9wwHnIO4IMlwygeHccuQ0WZtyY1SO6ik(yhjVeMb0eRMH3j4wPsAkyynWW3gCks01u7kvgdnfmSMgGqyakUOP2XPvm0uWWAofj6de8yhT9en1UdPdzC9m(WVNqO8WlmRc3tdwoXtfruXs8VN89xINga4je2W38SDkcx8m0yKOZ90kmprfqrpzWEwNjnN4PQGiDpJh49xIb8SqepJFHdtru0tJCpdueYlbOONwqy4FTdPfegQ4AoRIaFigj6Y0tMY4HxywfEBm4jIbEjAJhEHzv46xgn4yTcieadTT0adFBqtr4IM8UXkoENRf0Cbr6JdE)LyangABPuzmIbEjAUGi9XbV)smG(LrdogoTGogXaVenlCykII6xgn4ykvgdnfmSMfomfrrn1ERycieadTT0SWHPikQP2XXH0HmUEg)rvSu8KIFpJh49xIb8SDGXfpzWEQiIYZaIcG5zW4INMN4AJlN4jc2tP5EgpW7VeUNVVJ2EYX8mEgrA8uTbfM5jR4YnmTNXFuflfpdgx8mEG3FjgWZ2bgx8eJIWQipvfeP7z8aV)smGNuf4CUNkIO8SXW)Egh8WZ5nHIyapHqMr6OsrTNTtjEYkpLgg3ZGXVNCbT7jfNvrEgpW7Ved4z7aJlEIQW9ureLNKBHgpHcc8Klwyg3teSNqiXkmpXftXfTdPfegQ4AoRIaFigj6Y0tM6G3FjgyqdmU0gdEIyGxI(G3FjgyqdmUOFz0GJ1cAXaVeD34Yjde8qA(4G3FjC9lJgCSw0uWW6UXLtgi4H08XbV)s4AQ9wD7aUqqDiQWZPuzmIbEj6UXLtgi4H08XbV)s46xgn4y40c6yGMlisFCW7VedOP2Bjg4LO5cI0hh8(lXa6xgn4y4OuPHNNWKRltOigy0yKoQuutSA2K40IMcgwVLvyJikUO5IfMbrOGaCCiDiJRNk0)39uvHUNWiINaJeDprep5iu5PHH55wd)Z1EgFkW5Cpver5zJH)9uLIeDprWEQqqBpPnpzLNBByHgpdg)EQiIYZTwjEkipXqu0G7jnfmSNqywuJuSkYZ2raXtAf9ChHaSkYtCTDaxiOUN0hgrEJvyApJhEy9DW9KFCj1RWXv8eQ5MdxR2MNXtTnpvvO3MNq42BZtim(T3MNXtTnpHWT7qAbHHkUMZQiWhIrIUm9KP4cI0N9VFsBm4jIbEjAUGi9z)7NOFz0GJ1cAIXWgh)xI2WW46aIQeighLkjgdBC8FjAddJRzfEJ9C40c6yed8s0Cks0hi4XoA7j6xgn4ykvstbdR5uKOpqWJD02t0u7kv2Td4cb1X7eiacWXH0H0ccdvCnNvrGpeJeDz6jtby4skg2OBrDBii592yWted8s0agUKIHn6wu3gcsEx)YObhRf0eJHno(VeTHHX1bevjqmokvsmg244)s0gggxZk8g75WXH0HmUEIlG60S6EQkisF2)(jEULjnEIRnUCINiypLM7z8aV)s4EIiEQsrIUNiypviOTN4jvboN7PIikpBm8VNsZ9ecB4BEQ2GcZ8uigt80kmp7uaHTdUNCXcZ4AhslimuX1Cwfb(qms0LPNmfGf1ifRIg0iG0gdEcnfmSMlisF2)(jAQ9w89dadXirx46qJXQbGf1ifRIGiUBbTHNNWKRbg(2G3GcZ0eRMPaAkyynWW3g8guyMMlwygoqe3kClOPPGH1DJlNmqWdP5JdE)LW1u7TIrmWlrZPirFGGh7OTNOFz0GJPujnfmSMtrI(abp2rBprtTJJdPdzC9m(WVNXZisdUKYMDpX)eof3tC7PyKOl828KQaNZ9ureLNng(3tiSHV5PAdkmt7z8HFpJNrKgCjLn7EI)jCkUNq5PyKOlEYG9ureLNng(3ZnEqqfl45gnuf2jEghpfw)CpTcZZ5Hq4Pkfj6EIG9uHG2EINVmAWX80kmpNhcHNqydFZt1guyM2H0ccdvCnNvrGpeJeDz6jtDJin4skB2BJbpjgyQQoGvrTGMVFayigj6cxhAmwnaSOgPyveEHsPsdppHjxlpiOIfgsdvHDIMy1m8ojoTIrmWlrZPirFGGh7OTNOFz0GJ1YWZtyY1adFBWBqHzAIvZGiu40YWZtyY1adFBWBqHzAIvZuanfmSgy4BdEdkmtZflmdIqhhfE64OadppHjxlpiOIfgsdvHDIMy1mfW3pameJeDHRdngRgawuJuSkcNwqhJyGxIMtrI(abp2rBpr)YObhtPYyWqIggy9p4nOWmn5WKZBmAWvQKlisFCW7VedOP2XPf0Xig4LO7gxozGGhsZhh8(lHRFz0GJPujnfmSUBC5KbcEinFCW7VeUMAxPYacbWqBlnWW3g0ueUOjVBSIJ35A1Td4cb1X7Kyf3thN5uGyGxIoyaWqA(qAOkSt0VmAWXWXH0HmUEIlyCXZ4zePXt1guyMNBzsJN4AJlN4jc2tP5EgpW7VeUNIbEjEstjEwipTGWW)EQsrIUNiypviOTN4jnfmCBEAfMNwqy4FpvfePp7F)epPPGH90kmpHWg(MNTtr4INbuNvrEIGH9exi(75wM0WkpLM7zD8q8exmUq8VnpTcZZZKMt80ccd)7jU24YjEIG9uAUNXd8(lH7jnfmCBEIiEwipn8ngWOb3tiSHV5z7ueU452gg4Ew3iEIRv9my7T5jI4jNvrG7PyKOlEAfMNDkGW2b3tiSHV5PAdkmZtHymH7PvyE2Tsrp5IfMX1oKwqyOIR5Skc8HyKOltpzQBePzWBqHzTXGNednfmSMtrI(abp2rBprtT3smWlr3nUCYabpKMpo49xcx)YObhRf00uWW6UXLtgi4H08XbV)s4AQDLkdieadTT0adFBqtr4IM8UXkoENRv3oGleuhVtIvCpDCMtbIbEj6GbadP5dPHQWor)YObhtPs((bGHyKOlCDOXy1aWIAKIvrqe3TG2WZtyY1adFBWBqHzAIvZuanfmSgy4BdEdkmtZflmdI4wHXPfnfmSMlisF2)(jAQ9wbecGH2wAGHVnOPiCrtE3yfhItIcy44q6qgxpvOjIYZzfARNBBmbc5Eg)8SXW8KJ63tEdIiEE8yhyLjmu5zZj3tufU2Z2PepLMxEkn3ZaQWycdvEgr(2280kmpJFE2yyEkip57aM4P0Cpr19mEgrA8uTbfM5jGv3twjipHrueTwZrEQiIYZgd)7PG8e7gWZTmPXtPHX90OrDwzcdvEwOT4kEIlyCXZ4zePXt1guyMNBzsdIs8exBC5eprWEkn3Z4bE)LW9umWlPnpTcZZTmPbrjE2y4ZQipfcBhCpJFr1ruCpvii5LWmGNwH5Pfeg(3tiuE4fMvH3MNwH5Pfeg(3tvbr6Z(3pXtAkyyprepRBepX1QEgS928er8uvqKUNXd8(lXaEY4EYklim8FBEAfMNBVNbRILINhp2Fq8uqEgDXtR80WWycdvgWtk(9eb7PQGiDpJh49xIb8KvEkn3tY7gRyvKNWSOgXtycQ7Pkfj6EIG9uHG2EI2H0ccdvCnNvrGpeJeDz6jtDJindEdkmRng8Kyed8s0DJlNmqWdP5JdE)LW1VmAWXAfd0gEEctUMfvhrXh7i5LWmGMy1m8I7w0uWWAJhEHzv4AQDCAbnnfmSMlisF2)(jAQDLk72bCHG64DsSo30Xzofig4LOdgamKMpKgQc7e9lJgCmLkJbAUGi9XbV)smGMAVLyGxIMlisFCW7VedOFz0GJHtRJh7pihBeqDAtgGxrsZMcR)ndieadTT0Cbr6JdE)Lyan5DJv8nHk2ZPayacrGg6Jh7pihBeqDAtgGxrsZMcR)ndieadTT0Cbr6JdE)Lyan5DJvCCIfqf75WbVtIZCkaAOMgAdppHjx)qdAGGhsZhh8(lXaCnXQz4DcUXbhCCiDiJRNXh(9mEgrA8uTbfM5jd2tvks09eb7PcbT9epzCpfd8sowBEstjEwNjnN4jt8SqepnpJ)kevpJh49xIb8KX90ccd)7PjEkn3ZoQ)sAZtRW8ecB4BE2ofHlEY4EsUHPONiINBzaGN03tYnmf9CltAyLNsZ9SoEiEIlgxi(RDiTGWqfxZzve4dXirxMEYu3isZG3GcZAJbprmWlrZPirFGGh7OTNOFz0GJ1kgAkyynNIe9bcESJ2EIMAVvaHayOTLgy4BdAkcx0K3nwXH4KOawlOJrmWlrZfePpo49xIb0VmAWXAfd0WmYhh8(lXaAQDCuQumWlrZfePpo49xIb0VmAWXAfd0Cbr6JdE)Lyan1oo44q6qAbHHkUMZQiWhIrIUm9KPaSOgPyv0ayCoQng8emKOHbw)dEdkmtlSWmwfPuzaHayOTLggy9p4nOWmn5DJvChshY46P6U19ecZIAKIvrE2ociCpXOiSkYtvbr6EgpW7Ved4jgfXegQAZtgSNkIO8edvXsXZgd)7z8lQoII7PcbjVeMb8er8SXW)EYeprfqrprv4T5PvyEIHQyP4jf)EcHzrnsXQipBhbepXOiSkYZ2biegGIlEYG9ureLNng(3tZtiSHV5Pkfj6EQqiOG2H0ccdvCnNvrGpeJeDz6jtbyrnsXQObnciTXGNWfePpo49xIb0u7Ted8s0Cbr6JdE)Lya9lJgCSwqB45jm5AwuDefFSJKxcZaAIvZGiUvQmgAkyynWW3gCks01u7TOPGH10aecdqXfn1oooKoKX1tCbJlEcHzrnsXQipBhbepjpYiyGZ5EIG9uAUN7KJpdrX9mGkmMWqLNmypverflX8eG43tZtvbr6Z(3pXtUyHzEIiE2y4FpvfePp7F)epTcZtCTXLt8eb7P0CpJh49xc3tlim8V2H0ccdvCnNvrGpeJeDz6jtbyrnsXQObnciTXGNannfmSMlisF2)(jAY7gR4qeknukikGPaAkyynxqK(S)9t0CXcZuQKMcgwZfePp7F)en1ElAkyyD34Yjde8qA(4G3FjCn1oooKoKX1Z4d)EIRsqCXt1guyMNBzsJNXVWHPik6PvyEIRnUCINiypLM7z8aV)s4AhslimuX1Cwfb(qms0LPNmfmbXLbVbfM1gdEIyGxIMfomfrr9lJgCSwIbEj6UXLtgi4H08XbV)s46xgn4yTOPGH1SWHPikQP2BrtbdR7gxozGGhsZhh8(lHRP2DiDiTGWqfxZzve4dXirxMEYuadFBqtr4sBm4j0uWWAJhEHzv4AQDhshY46z8ryagEEpvPir3teSNke02t8uqEY3j3W8exfy97PAdkmZtgSNDkGW2b3ZxVZo3tJCp3jN)s0oKwqyOIR5Skc8HyKOltpzkyG1)G3GcZAlOya8HyKOl8jq1gdEc5WKZBmAWBzbHH)hVENDoEHQfnfmSMtrI(abp2rBprtT7q6qgxpJp87je2W38SDkcx8CltA8uLIeDprWEQqqBpXtgSNsZ9eyCXZDK8sygWtkUfDprWEQkis3Z4bE)LyapBmEflfpnpHPaapXOiMWqLNqiWf5jd2tfruEgquampJU4PviP5epP4w09eb7P0CpJ)kevpJh49xIb8Kb7P0CpjVBSIvrEcZIAep3ACpHsHJfEcqv0jAhslimuX1Cwfb(qms0LPNmfWW3g0ueU0gdEIyGxIMlisFCW7VedOFz0GJ1kGqam02AqUfKw0uWWAofj6de8yhT9en1ElOpES)GCSra1PnzaEfjnBkS(3mGqam02sZfePpo49xIb0K3nwX3eQypNcGbiebAOpES)GCSra1PnzaEfjnBkS(3mGqam02sZfePpo49xIb0K3nwXXjwavSNdhigN5ua0qnn0gEEctU(Hg0abpKMpo49xIb4AIvZW7eCJdokvcnuAOuyfa9XJ9hKJncOoTjdWRiPztH1poBgqiagABP5cI0hh8(lXaAY7gR4BcvSNtbWaeIan0qPHsHva0hp2Fqo2iG60MmaVIKMnfw)4SzaHayOTLMlisFCW7VedOjVBSIJtSaQypho4arOpES)GCSra1PnzaEfjnBkS(3mGqam02sZfePpo49xIb0K3nwX3eQypNcGbiebAOpES)GCSra1PnzaEfjnBkS(3mGqam02sZfePpo49xIb0K3nwXXjwavSNdhCWXH0HmUEgF43tiSHV5z7ueU45wM04Pkfj6EIG9uHG2EINmypLM7jW4IN7i5LWmGNuCl6EIG9exLrUNXd8(lXaE2y8kwkEAEctbaEIrrmHHkpHqGlYtgSNkIO8mGOayEgDXtRqsZjEsXTO7jc2tP5Eg)viQEgpW7Ved4jd2tP5EsE3yfRI8eMf1iEU14EcLchl8eGQOt0oKwqyOIR5Skc8HyKOltpzkGHVnOPiCPng8Kyed8s0Cbr6JdE)Lya9lJgCSwbecGH2wdYTG0IMcgwZPirFGGh7OTNOP2Bb9XJ9hKJncOoTjdWRiPztH1)MbecGH2wAyg5JdE)Lyan5DJv8nHk2ZPayacrGg6Jh7pihBeqDAtgGxrsZMcR)ndieadTT0WmYhh8(lXaAY7gR44elGk2ZHdeJZCkaAOMgAdppHjx)qdAGGhsZhh8(lXaCnXQz4DcUXbhLkHgknukScG(4X(dYXgbuN2Kb4vK0SPW6hNndieadTT0WmYhh8(lXaAY7gR4BcvSNtbWaeIan0qPHsHva0hp2Fqo2iG60MmaVIKMnfw)4SzaHayOTLgMr(4G3FjgqtE3yfhNybuXEoCWbIqF8y)b5yJaQtBYa8ksA2uy9VzaHayOTLgMr(4G3FjgqtE3yfFtOI9CkagGqeOH(4X(dYXgbuN2Kb4vK0SPW6FZacbWqBlnmJ8XbV)smGM8UXkooXcOI9C4GdooKoKwqyOIR5Skc8HyKOltpzkalQrkwfnOraPng8eAkyynNIe9bcESJ2EIMA3H0ccdvCnNvrGpeJeDz6jtbm8TbnfHlTXGNeqiagABni3csRyed8s0DJlNmqWdP5JdE)LW1VmAWXCiDiJRNQawuJau0ZiRFpJFHdtru0tAkyypfKNnO9dtbak6jnfmSNCu)E((oA7jhZtCvcIlEQ2GcZ4EULjnEIRnUCINiypLM7z8aV)s4AhslimuX1Cwfb(qms0LPNmflCykIITXGNig4LOzHdtruu)YObhRvmq3Td4cb1XB8n2TcieadTT0adFBqtr4IM8UXkoeNmhoTGogXaVenxqK(4G3Fjgq)YObhtPsUGi9XbV)smGgdTTWXH0H0ccdvCnNvrGpeJeDz6jtbm8TbnfHlTXGNeqiagABni3csRqJrIohVIbEj6hAqde8qA(4G3FjC9lJgCmhshY46PkGf1iaf9e7atrpP4SkYZ4x4Wuef989D02toMN4Qeex8uTbfMX9uqE((oA7jEknV75wM04jU24YjEIG9uAUNXd8(lH7PGqAhslimuX1Cwfb(qms0LPNmfmbXLbVbfM1gdEIyGxIMfomfrr9lJgCSw0uWWAw4Wuef1u7TOPGH1SWHPikQjVBSIdrO0qPGOaMcOPGH1SWHPikQ5IfM5q6qAbHHkUMZQiWhIrIUm9KPag(2GMIWL2yWtcieadTTgKBbXH0HmUEg)rvSu80cbg2lXaaf9KIFpvPir3teSNke02t8CltA8exfy97PAdkmZtmkcRI8KZQiW9ums0fTdPfegQ4AoRIaFigj6Y0tMcgy9p4nOWS2ckgaFigj6cFcuTXGNqom58gJg8wXqtbdR5uKOpqWJD02t0u7oKwqyOIR5Skc8HyKOltpzkbjVp6gxorX2yWted8s0csEF0nUCII6xgn4yTGMMcgwtohvwf(qqY7AY7gR4quHvQeAAkyyn5Cuzv4dbjVRjVBSIdrOPPGH1gp8cZQW1yuetyOA6acbWqBlTXdVWSkCn5DJvCCAfqiagABPnE4fMvHRjVBSIdrOIno44q6qAbHHkUMZQiWhIrIUm9KPGjiUm4nOWS2yWted8s0SWHPikQFz0GJ1IMcgwZchMIOOMAVf00uWWAw4Wuef1K3nwXHyuatbqGcOPGH1SWHPikQ5IfMPujnfmSMlisF2)(jAQDLkJrmWlr3nUCYabpKMpo49xcx)YObhdhhslimuX1Cwfb(qms0LPNmvOXy1aWIAKIvrTXGNqtbdRLheuXcdPHQWortT3kgAkyynxqK(S)9t0u7T47hagIrIUW1HgJvdalQrkwfHxOCiTGWqfxZzve4dXirxMEYuawuJuSkAqJaIdPfegQ4AoRIaFigj6Y0tMcgy9p4nOWS26i8zv0eOAlOya8HyKOl8jq1gdEc5WKZBmAWDiTGWqfxZzve4dXirxMEYuWaR)bVbfM1whHpRIMavBm4jDe(V)s0ymUyv44vHDiJRN4Qeex8uTbfM5jJ7jII4zhH)7VepHzaWjAhslimuX1Cwfb(qms0LPNmfmbXLbVbfM1whHpRIMa1sf)t4muTMh3ZbvSox8f3X6sDRrkwfXxQXV(oIihZtiWtlimu5jGXfU2HCPAusdISuvzDkGjmuHlqmyzPcyCHV2yPYzve4dXirxwBSMhQ1gl1xgn4yR2xQwqyOAPcdS(h8guy2snqyYjmBPcTNX4PWcZyvKNkv6PyGxIMlisFCW7VedOFz0GJ5zlpdieadTT0Cbr6JdE)Lyan5DJvCpHON42tf4zuaZtLk9edjAyG1)G3GcZ0K3nwX9eIt8mkG5PsLEkg4LOnE4fMvHRFz0GJ5zlpXqIggy9p4nOWmn5DJvCpHONq7zaHayOTL24HxywfUM8UXkUNt7jnfmS24HxywfUgJIycdvEIJNT8mGqam02sB8WlmRcxtE3yf3ti6je4zlpH2Zy8umWlrZfePpo49xIb0VmAWX8uPspfd8s0Cbr6JdE)Lya9lJgCmpB5jxqK(4G3FjgqJH2wEIJN44zlpH2tAkyy9wwHnIO4IMlwyMNq0tOGapvQ0tdppHjxZIQJO4JDK8sygqtSAMN4DIN42tLk9KMcgwdm8TbNIeDn1UNkv6zmEstbdRPbiegGIlAQDpXXZwEgJN0uWWAofj6de8yhT9en1(snOya8HyKOl818qTK184ETXs9Lrdo2Q9LAGWKty2svmWlrB8WlmRcx)YObhZZwEgqiagABPbg(2GMIWfn5DJvCpXRNZ5zlpH2tUGi9XbV)smGgdTT8uPspJXtXaVenxqK(4G3Fjgq)YObhZtC8SLNq7zmEkg4LOzHdtruu)YObhZtLk9mgpPPGH1SWHPikQP29SLNX4zaHayOTLMfomfrrn1UN4SuTGWq1s14Hxywf(swZhN1gl1xgn4yR2xQbctoHzlvXaVe9bV)smWGgyCr)YObhZZwEcTNIbEj6UXLtgi4H08XbV)s46xgn4yE2YtAkyyD34Yjde8qA(4G3FjCn1UNT8SBhWfcQ7je9uHNZtLk9mgpfd8s0DJlNmqWdP5JdE)LW1VmAWX8ehpB5j0EgJNq7jxqK(4G3FjgqtT7zlpfd8s0Cbr6JdE)Lya9lJgCmpXXtLk90WZtyY1LjuedmAmshvkQjwnZZjEghpB5jnfmSElRWgruCrZflmZti6juqGN4SuTGWq1s9G3FjgyqdmUSK18qWAJL6lJgCSv7l1aHjNWSLQyGxIMlisF2)(j6xgn4yE2YtO9KymSXX)LOnmmUoGOkXti6zC8uPspjgdBC8FjAddJRzLN41ZypNN44zlpH2Zy8umWlrZPirFGGh7OTNOFz0GJ5PsLEstbdR5uKOpqWJD02t0u7EQuPND7aUqqDpX7epHaiWtCwQwqyOAPYfePp7F)KLSMp2RnwQVmAWXwTVudeMCcZwQIbEjAadxsXWgDlQBdbjVRFz0GJ5zlpH2tIXWgh)xI2WW46aIQepHONXXtLk9KymSXX)LOnmmUMvEIxpJ9CEIZs1ccdvlvadxsXWgDlQBdbjVVK18k8AJL6lJgCSv7l1aHjNWSLknfmSMlisF2)(jAQDpB5jF)aWqms0fUo0ySAayrnsXQipHON42ZwEcTNgEEctUgy4BdEdkmttSAMNkWtAkyynWW3g8guyMMlwyMN44je9e3kSNT8eApPPGH1DJlNmqWdP5JdE)LW1u7E2YZy8umWlrZPirFGGh7OTNOFz0GJ5PsLEstbdR5uKOpqWJD02t0u7EIZs1ccdvlvalQrkwfnOrazjR5JVRnwQVmAWXwTVudeMCcZwQX4jmvvhWQipB5j0EY3pameJeDHRdngRgawuJuSkYt86juEQuPNgEEctUwEqqflmKgQc7enXQzEI3jEghpB5zmEkg4LO5uKOpqWJD02t0VmAWX8SLNgEEctUgy4BdEdkmttSAMNq0tO8ehpB5PHNNWKRbg(2G3GcZ0eRM5Pc8KMcgwdm8TbVbfMP5IfM5je9eApJJc750EghpvGNgEEctUwEqqflmKgQc7enXQzEQap57hagIrIUW1HgJvdalQrkwf5joE2YtO9mgpfd8s0Cks0hi4XoA7j6xgn4yEQuPNX4jgs0WaR)bVbfMPjhMCEJrdUNkv6jxqK(4G3FjgqtT7joE2YtO9mgpfd8s0DJlNmqWdP5JdE)LW1VmAWX8uPspPPGH1DJlNmqWdP5JdE)LW1u7EQuPNbecGH2wAGHVnOPiCrtE3yf3t865CE2YZUDaxiOUN4DINXkU9CApJZCEQapfd8s0bdagsZhsdvHDI(LrdoMN4SuTGWq1s9grAWLu2SVK18kuRnwQVmAWXwTVudeMCcZwQX4jnfmSMtrI(abp2rBprtT7zlpfd8s0DJlNmqWdP5JdE)LW1VmAWX8SLNq7jnfmSUBC5KbcEinFCW7VeUMA3tLk9mGqam02sdm8TbnfHlAY7gR4EIxpNZZwE2Td4cb19eVt8mwXTNt7zCMZtf4PyGxIoyaWqA(qAOkSt0VmAWX8uPsp57hagIrIUW1HgJvdalQrkwf5je9e3E2YtO90WZtyY1adFBWBqHzAIvZ8ubEstbdRbg(2G3GcZ0CXcZ8eIEIBf2tC8SLN0uWWAUGi9z)7NOP29SLNbecGH2wAGHVnOPiCrtE3yf3tioXZOaMN4SuTGWq1s9grAg8guy2swZhRRnwQVmAWXwTVudeMCcZwQX4PyGxIUBC5KbcEinFCW7VeU(LrdoMNT8mgpH2tdppHjxZIQJO4JDK8sygqtSAMN41tC7zlpPPGH1gp8cZQW1u7EIJNT8eApPPGH1Cbr6Z(3prtT7PsLE2Td4cb19eVt8mwNZZP9moZ5Pc8umWlrhmayinFinuf2j6xgn4yEQuPNX4j0EYfePpo49xIb0u7E2YtXaVenxqK(4G3Fjgq)YObhZtC8SLNhp2Fqo2iG60MmaVIKgp30tH1VNB6zaHayOTLMlisFCW7VedOjVBSI75MEcvSNZtf4jmaHiEcTNq75XJ9hKJncOoTjdWRiPXZn9uy975MEgqiagABP5cI0hh8(lXaAY7gR4EIJNXcpHk2Z5joEI3jEgN58ubEcTNq550EcTNgEEctU(Hg0abpKMpo49xIb4AIvZ8eVt8e3EIJN44jolvlimuTuVrKMbVbfMTK18qn3AJL6lJgCSv7l1aHjNWSLQyGxIMtrI(abp2rBpr)YObhZZwEgJN0uWWAofj6de8yhT9en1UNT8mGqam02sdm8TbnfHlAY7gR4EcXjEgfW8SLNq7zmEkg4LO5cI0hh8(lXa6xgn4yE2YZy8eApHzKpo49xIb0u7EIJNkv6PyGxIMlisFCW7VedOFz0GJ5zlpJXtO9KlisFCW7VedOP29ehpXzPAbHHQL6nI0m4nOWSLSMhkOwBSuFz0GJTAFPgim5eMTuXqIggy9p4nOWmTWcZyvKNkv6zaHayOTLggy9p4nOWmn5DJv8LQfegQwQawuJuSkAamohTK18qH71gl1xgn4yR2xQbctoHzlvUGi9XbV)smGMA3ZwEkg4LO5cI0hh8(lXa6xgn4yE2YtO90WZtyY1SO6ik(yhjVeMb0eRM5je9e3EQuPNX4jnfmSgy4Bdofj6AQDpB5jnfmSMgGqyakUOP29eNLQfegQwQawuJuSkAqJaYswZdvCwBSuFz0GJTAFPgim5eMTuH2tAkyynxqK(S)9t0K3nwX9eIEcLgkpvGNrbmpvGN0uWWAUGi9z)7NO5IfM5PsLEstbdR5cI0N9VFIMA3ZwEstbdR7gxozGGhsZhh8(lHRP29eNLQfegQwQawuJuSkAqJaYswZdfeS2yP(YObhB1(snqyYjmBPkg4LOzHdtruu)YObhZZwEkg4LO7gxozGGhsZhh8(lHRFz0GJ5zlpPPGH1SWHPikQP29SLN0uWW6UXLtgi4H08XbV)s4AQ9LQfegQwQWeexg8guy2swZdvSxBSuFz0GJTAFPgim5eMTuPPGH1gp8cZQW1u7lvlimuTubg(2GMIWLLSMhkfETXs9Lrdo2Q9LQfegQwQWaR)bVbfMTudeMCcZwQKdtoVXOb3ZwEAbHH)hVENDUN41tO8SLN0uWWAofj6de8yhT9en1(snOya8HyKOl818qTK18qfFxBSuFz0GJTAFPgim5eMTufd8s0Cbr6JdE)Lya9lJgCmpB5zaHayOT1GCliE2YtAkyynNIe9bcESJ2EIMA3ZwEcTNhp2Fqo2iG60MmaVIKgp30tH1VNB6zaHayOTLMlisFCW7VedOjVBSI75MEcvSNZtf4jmaHiEcTNq75XJ9hKJncOoTjdWRiPXZn9uy975MEgqiagABP5cI0hh8(lXaAY7gR4EIJNXcpHk2Z5joEcrpJZCEQapH2tO8CApH2tdppHjx)qdAGGhsZhh8(lXaCnXQzEI3jEIBpXXtC8uPspH2tO0qPWEQapH2ZJh7pihBeqDAtgGxrsJNB6PW63tC8CtpdieadTT0Cbr6JdE)Lyan5DJvCp30tOI9CEQapHbieXtO9eApHsdLc7Pc8eAppES)GCSra1PnzaEfjnEUPNcRFpXXZn9mGqam02sZfePpo49xIb0K3nwX9ehpJfEcvSNZtC8ehpHONq75XJ9hKJncOoTjdWRiPXZn9uy975MEgqiagABP5cI0hh8(lXaAY7gR4EUPNqf758ubEcdqiINq7j0EE8y)b5yJaQtBYa8ksA8Ctpfw)EUPNbecGH2wAUGi9XbV)smGM8UXkUN44zSWtOI9CEIJN44jolvlimuTubg(2GMIWLLSMhkfQ1gl1xgn4yR2xQbctoHzl1y8umWlrZfePpo49xIb0VmAWX8SLNbecGH2wdYTG4zlpPPGH1Cks0hi4XoA7jAQDpB5j0EE8y)b5yJaQtBYa8ksA8Ctpfw)EUPNbecGH2wAyg5JdE)Lyan5DJvCp30tOI9CEQapHbieXtO9eAppES)GCSra1PnzaEfjnEUPNcRFp30ZacbWqBlnmJ8XbV)smGM8UXkUN44zSWtOI9CEIJNq0Z4mNNkWtO9ekpN2tO90WZtyY1p0Ggi4H08XbV)smaxtSAMN4DIN42tC8ehpvQ0tO9eknukSNkWtO984X(dYXgbuN2Kb4vK045MEkS(9ehp30ZacbWqBlnmJ8XbV)smGM8UXkUNB6juXEopvGNWaeI4j0EcTNqPHsH9ubEcTNhp2Fqo2iG60MmaVIKgp30tH1VN445MEgqiagABPHzKpo49xIb0K3nwX9ehpJfEcvSNZtC8ehpHONq75XJ9hKJncOoTjdWRiPXZn9uy975MEgqiagABPHzKpo49xIb0K3nwX9CtpHk2Z5Pc8egGqepH2tO984X(dYXgbuN2Kb4vK045MEkS(9CtpdieadTT0WmYhh8(lXaAY7gR4EIJNXcpHk2Z5joEIJN4SuTGWq1sfy4BdAkcxwYAEOI11gl1xgn4yR2xQbctoHzlvAkyynNIe9bcESJ2EIMAFPAbHHQLkGf1ifRIg0iGSK184EU1gl1xgn4yR2xQbctoHzl1acbWqBRb5wq8SLNX4PyGxIUBC5KbcEinFCW7VeU(Lrdo2s1ccdvlvGHVnOPiCzjR5XnuRnwQVmAWXwTVudeMCcZwQIbEjAw4Wuef1VmAWX8SLNX4j0E2Td4cb19eVEgFJTNT8mGqam02sdm8TbnfHlAY7gR4EcXjEoNN44zlpH2Zy8umWlrZfePpo49xIb0VmAWX8uPsp5cI0hh8(lXaAm02YtCwQwqyOAPYchMIO4swZJBCV2yP(YObhB1(snqyYjmBPgqiagABni3cINT8m0yKOZ9eVEkg4LOFObnqWdP5JdE)LW1VmAWXwQwqyOAPcm8TbnfHllznpUJZAJL6lJgCSv7l1aHjNWSLQyGxIMfomfrr9lJgCmpB5jnfmSMfomfrrn1UNT8KMcgwZchMIOOM8UXkUNq0tO0q5Pc8mkG5Pc8KMcgwZchMIOOMlwy2s1ccdvlvycIldEdkmBjR5XneS2yP(YObhB1(snqyYjmBPgqiagABni3cYs1ccdvlvGHVnOPiCzjR5XDSxBSuFz0GJTAFPAbHHQLkmW6FWBqHzl1aHjNWSLk5WKZBmAW9SLNX4jnfmSMtrI(abp2rBprtTVudkgaFigj6cFnpulznpUv41gl1xgn4yR2xQbctoHzlvXaVeTGK3hDJlNOO(LrdoMNT8eApPPGH1KZrLvHpeK8UM8UXkUNq0tf2tLk9eApPPGH1KZrLvHpeK8UM8UXkUNq0tO9KMcgwB8WlmRcxJrrmHHkpN2ZacbWqBlTXdVWSkCn5DJvCpXXZwEgqiagABPnE4fMvHRjVBSI7je9eQy7joEIZs1ccdvlvbjVp6gxorXLSMh3X31gl1xgn4yR2xQbctoHzlvXaVenlCykII6xgn4yE2YtAkyynlCykIIAQDpB5j0EstbdRzHdtruutE3yf3ti6zuaZtf4je4Pc8KMcgwZchMIOOMlwyMNkv6jnfmSMlisF2)(jAQDpvQ0Zy8umWlr3nUCYabpKMpo49xcx)YObhZtCwQwqyOAPctqCzWBqHzlznpUvOwBSuFz0GJTAFPgim5eMTuPPGH1YdcQyHH0qvyNOP29SLNX4jnfmSMlisF2)(jAQDpB5jF)aWqms0fUo0ySAayrnsXQipXRNqTuTGWq1sn0ySAayrnsXQOLSMh3X6AJLQfegQwQawuJuSkAqJaYs9Lrdo2Q9LSMpoZT2yP(YObhB1(s1ccdvlvyG1)G3GcZwQbfdGpeJeDHVMhQLAGWKty2sLCyY5ngn4l1ocFwfTuHAjR5JduRnwQVmAWXwTVudeMCcZwQDe(V)s0ymUyv4EIxpv4LQfegQwQWaR)bVbfMTu7i8zv0sfQLSMpo4ETXsTJWNvrlvOwQwqyOAPctqCzWBqHzl1xgn4yR2xYswQg6RnwZd1AJL6lJgCSv7l1aHjNWSLQyGxIMlisF2)(j6xgn4ylvlimuTu5cI0N9VFYswZJ71gl1xgn4yR2xQwqyOAPcdS(h8guy2snqyYjmBPsom58gJgCpB5j0EY3pameJeDHRdngRgawuJuSkYti6j0EgBp30Zy8umWlrli59r34YjkQFz0GJ5joEQuPNX4PyGxIMlisFCW7VedOFz0GJ5zlpH2tyg5JdE)Lyan5DJvCpXRNq7juqGNkWt((bGrJXL7joEQuPNbecGH2wAyg5JdE)Lyan5DJvCpHONq7jUHap30tOGapvGN89daJgJl3tC8ehpXXZwEcTNX4PyGxIMlisFCW7VedOFz0GJ5PsLEYfePpo49xIb0yOTLNkv6jF)aWqms0fUo0ySAayrnsXQipN4zC8SLN0uWW6TScBerXfnxSWmpHONqbbEIZsnOya8HyKOl818qTK18XzTXs9Lrdo2Q9LAGWKty2svmWlrB8WlmRcx)YObhZZwEcTNIbEjAUGi9XbV)smG(LrdoMNT8KlisFCW7VedOXqBlpB5zaHayOTLMlisFCW7VedOjVBSI7jE9eQy7PsLEgJNIbEjAUGi9XbV)smG(LrdoMN44zlpH2Zy8umWlrZchMIOO(LrdoMNkv6zmEstbdRzHdtruutT7zlpJXZacbWqBlnlCykIIAQDpXzPAbHHQLQXdVWSk8LSMhcwBSuFz0GJTAFPgim5eMTufd8s0agUKIHn6wu3gcsEx)YObhBPAbHHQLkGHlPyyJUf1THGK3xYA(yV2yP(YObhB1(snqyYjmBPgJNIbEj6UXLtgi4H08XbV)s46xgn4yEQuPN0uWWAUGi9z)7NOP29uPsp72bCHG6EI3jEcTNqn3CEUPNqGNkWt((bGHyKOlCDOXy1aWIAKIvrEIJNkv6jnfmSUBC5KbcEinFCW7VeUMA3tLk9KVFayigj6cxhAmwnaSOgPyvKN41Z4SuTGWq1s9grAWLu2SVK18k8AJL6lJgCSv7l1aHjNWSLk0EgJNIbEj6UXLtgi4H08XbV)s46xgn4yEQuPN0uWW6UXLtgi4H08XbV)s4AQDpvQ0tAkyynWW3gCks01yOTLNkv6jF)aWqms0fU(grAWLu2S7jEN4je4joE2YtO9KMcgwZfePp7F)en1UNkv6z3oGleu3t8oXtO9eQ5MZZn9ec8ubEY3pameJeDHRdngRgawuJuSkYtC8uPspPPGH1DJlNmqWdP5JdE)LW1u7EQuPN89dadXirx46qJXQbGf1ifRI8eVEghpXzPAbHHQL6nI0GlPSzFjR5JVRnwQVmAWXwTVudeMCcZwQ0uWWAUGi9z)7NOjVBSI7je9moEQapJcyEQapPPGH1Cbr6Z(3prZflmBPAbHHQLAOXy1aWIAKIvrlznVc1AJL6lJgCSv7l1aHjNWSLknfmSgy4Bdofj6AQDpB5jF)aWqms0fUo0ySAayrnsXQipHONqGNT8eApJXtXaVenxqK(4G3Fjgq)YObhZtLk9KlisFCW7VedOXqBlpXXZwEIHenmW6FWBqHzAHfMXQOLQfegQwQadFBqtr4YswZhRRnwQVmAWXwTVudeMCcZwQ89dadXirx46qJXQbGf1ifRI8eIEcbE2YZy8KMcgwB8WlmRcxtTVuTGWq1sLfomfrXLSMhQ5wBSuFz0GJTAFPgim5eMTu57hagIrIUW1HgJvdalQrkwf5je9ec8SLN0uWWAw4Wuef1u7E2YZy8KMcgwB8WlmRcxtTVuTGWq1sfMG4YG3GcZwYAEOGATXs9Lrdo2Q9LAGWKty2svmWlrFW7VedmObgx0VmAWX8SLN89dadXirx46qJXQbGf1ifRI8eIEcbE2YtO9mgpfd8s0Cbr6JdE)Lya9lJgCmpvQ0tUGi9XbV)smGgdTT8eNLQfegQwQh8(lXadAGXLLSMhkCV2yP(YObhB1(snqyYjmBPkg4LOnE4fMvHRFz0GJTuTGWq1sfy4Bd6B9LSMhQ4S2yPAbHHQLAOXy1aWIAKIvrl1xgn4yR2xYAEOGG1gl1xgn4yR2xQbctoHzlvXaVeTXdVWSkC9lJgCSLQfegQwQadFBqtr4YsTJWNvrlvOwYAEOI9AJL6lJgCSv7lvlimuTuHbw)dEdkmBPguma(qms0f(AEOwQbctoHzlvYHjN3y0GVu7i8zv0sfQLSMhkfETXsTJWNvrlvOwQwqyOAPctqCzWBqHzl1xgn4yR2xYswQyh2OaYAJ18qT2yP(YObhBrVudeMCcZwQgEEctU2QW5cXadY5OYQW1VmAWXwQwqyOAPsdqimafxwYAECV2yP(YObhB1(snqyYjmBPE8y)b5yJaQtBYa8ksA8Ctpfw)EcrpJZCEQuPNWmYhh8(lXaAQDpvQ0tUGi9XbV)smGMAFPAbHHQL6osyOAjR5JZAJLQfegQwQBzf2G3CJSuFz0GJTAFjR5HG1gl1xgn4yR2xQbctoHzlvXaVeTGK3hDJlNOO(LrdoMNT8KMcgwtohvwf(qqY7AY7gR4EcrpX9s1ccdvlvbjVp6gxorXLSMp2RnwQwqyOAPsX)GjVZxQVmAWXwTVK18k8AJL6lJgCSv7l1aHjNWSLAmEkg4LO5cI0hh8(lXa6xgn4ylvlimuTuHzKpo49xIbwYA(47AJL6lJgCSv7l1aHjNWSLQyGxIMlisFCW7VedOFz0GJ5zlpH2Zy8umWlrZchMIOO(LrdoMNkv6zmEstbdRzHdtruutT7zlpJXZacbWqBlnlCykIIAQDpXXZwEcTNX4PyGxI24HxywfU(LrdoMNkv6zmEgqiagABPnE4fMvHRP29eNLQfegQwQCbr6JdE)LyGLSMxHATXs1ccdvl1aQcVeIjhBadS(xQVmAWXwTVK18X6AJLQfegQwQ0aecBGGhsZhVExXL6lJgCSv7lznpuZT2yPAbHHQLAeLrWywnqWddppbjnl1xgn4yR2xYAEOGATXs1ccdvlvyuGIFSHHNNWKpOV1xQVmAWXwTVK18qH71glvlimuTu3Pimyfzv0GgyCzP(YObhB1(swZdvCwBSuTGWq1svA(GQOruf2agrcFP(YObhB1(swZdfeS2yPAbHHQLA)DerXbcEaOcmSbg5wNVuFz0GJTAFjR5Hk2RnwQwqyOAPsy77Gpy1GVBHVuFz0GJTAFjR5HsHxBSuTGWq1sDlIaWW)SAqohvwf(s9Lrdo2Q9LSMhQ47AJL6lJgCSv7l1aHjNWSLAmEkg4LOnE4fMvHRFz0GJ5PsLEstbdRnE4fMvHRP29uPspdieadTT0gp8cZQW1K3nwX9eVEg75wQwqyOAPsdqiSbmfrXLSMhkfQ1gl1xgn4yR2xQbctoHzl1y8umWlrB8WlmRcx)YObhZtLk9KMcgwB8WlmRcxtTVuTGWq1sL(e(jZyv0swZdvSU2yP(YObhB1(snqyYjmBPgJNIbEjAJhEHzv46xgn4yEQuPN0uWWAJhEHzv4AQDpvQ0ZacbWqBlTXdVWSkCn5DJvCpXRNXEULQfegQwQWmYPbie2swZJ75wBSuFz0GJTAFPgim5eMTuJXtXaVeTXdVWSkC9lJgCmpvQ0tAkyyTXdVWSkCn1UNkv6zaHayOTL24HxywfUM8UXkUN41Zyp3s1ccdvlvRcNledmcgaSK184gQ1gl1xgn4yR2xQbctoHzlvUGi9XbV)smGMA3ZwEstbdRdgamaSOgPyvKM8UXkUN4DINkulvlimuTuVIFGGhsZhCbr6lznpUX9AJLQfegQwQ9lhrwQVmAWXwTVK184ooRnwQVmAWXwTVudeMCcZwQwqy4)XR3zN7jE9e3E2YZy8eMQQdyv0s1ccdvlvcvnSGWq1aW4YsfW4YOS(xQg6lznpUHG1gl1xgn4yR2xQwqyOAPsOQHfegQgagxwQagxgL1)sLZQiWhIrIUSKLSu3jpG60MS2ynpuRnwQwqyOAPki59r34YjkUuFz0GJTAFjR5X9AJL6lJgCSv7l1aHjNWSLQyGxIMlisF2)(j6xgn4yE2YtO9KymSXX)LOnmmUoGOkXti6zC8uPspjgdBC8FjAddJRzLN41ZypNN4SuTGWq1sLlisF2)(jlznFCwBSuFz0GJTAFPgim5eMTuJXtXaVenxqK(4G3Fjgq)YObhBPAbHHQLkmJ8XbV)smWswZdbRnwQVmAWXwTVudeMCcZwQIbEjAUGi9XbV)smG(Lrdo2s1ccdvlvUGi9XbV)smWswZh71glvlimuTu3rcdvl1xgn4yR2xYAEfETXs9Lrdo2Q9LAGWKty2svmWlrFW7VedmObgx0VmAWXwQwqyOAPEW7VedmObgxwYA(47AJL6lJgCSv7l1aHjNWSLAmEkg4LOp49xIbg0aJl6xgn4yE2Yt((bGHyKOlCDOXy1aWIAKIvrEcrpJZs1ccdvlvGHVnOPiCzjR5vOwBSuFz0GJTAFPgim5eMTu57hagIrIUW1HgJvdalQrkwf5jE9e3lvlimuTudngRgawuJuSkAjlzjlzjRf]] )


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
