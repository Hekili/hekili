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


    -- f681cdeb24ca362198d9d31e1636583e97c07727
    spec:RegisterPack( "Elemental", 20190709.1630, [[deLm1bqiHWJuGCjHeSjPKpjKqJcK6uqfRIe4vkGzjLYTukAxK6xsPAykfogizzqL6zcrMMsfUMquBdQI(MqIACKGIZPavRdQe5DKGsyEkv6EkO9bvP)PuruDqLkslui1dHkbtubkDrHK2iujQpcvc1ivQikNubkwPsvVKeuQzQurDtOkyNke)uPIWqHQqlfQeYtjPPQq6QcjYxvQiYyjbL0zjbLO9QK)QObl6Wuwms9ybtgkxw1Mb1NfQrlfNgLxRqnBGBlv7wYVHmCqCCsq1Yr8CunDIRJKTdv13vknEOs68KqRNeK5tI2pvVGAn6sfZKVgb3Ba1GVruEJbxdfEUJDePLQOiKVuHyHXw8xQL1)snQG3FjgyPcXueGmS1OlvoIIe(sTreiCCP2BpMjnu06aQ3oN1PaMWqvGyWs7Cwp0(sLMIbKbtTOxQyM81i4EdOg8nIYBm4AOWZiTu5qEyncUXtCVuByyyVw0lvSZdl1b5zubV)smGNQnw3kF)G8SreiCCP2BpMjnu06aQ3oN1PaMWqvGyWs7Cwp0UVFqEUNcOONdEBEI7nGAW9CtpHcpXLI0g(EF)G8exOXQ4ZXL89dYZn9mkXVNkSop49xIb0uq8KysZjEknw5zO5HXSk2ZacbWqBlUNcYt(VNmypp49xIb4EAK7Pfeg(x77hKNB65GLXnAWX8mQgrA8mQG3FjgWZxcHDU23pip30tCrVJW)EUt5HxywfUNcR)2JEN9m08WyTVFqEUPN7ummpJQI3teSNsZ9uvqKUNT7jE4Yre9sfcbbZaFPoipJk49xIb8uTX6w57hKNnIaHJl1E7XmPHIwhq925SofWegQcedwANZ6H299dYZ9uaf9CWBZtCVbudUNB6ju4jUuK2W377hKN4cnwfFoUKVFqEUPNrj(9uH15bV)smGMcINetAoXtPXkpdnpmMvXEgqiagABX9uqEY)9Kb75bV)sma3tJCpTGWW)AF)G8CtphSmUrdoMNr1isJNrf8(lXaE(siSZ1((b55MEIl6De(3ZDkp8cZQW9uy93E07SNHMhgR99dYZn9CNIH5zuv8EIG9uAUNQcI09SDpXdxoIO99((b5zuX1hOKJ5j9HrK7za1PnXt6hZkU2ZDAiCic3ZcvB2yKomfWtlimuX9evaf1(ElimuX1qipG60Mmegy8X(ElimuX1qipG60MmWW2HrimFVfegQ4AiKhqDAtgyy7gvC)Lycdv((b5PAzq4niXtIXW8KMcg(yEYft4EsFye5EgqDAt8K(XSI7PvyEcH8nHGeHvXEY4EIHQR99wqyOIRHqEa1PnzGHTZldcVbjtUyc33BbHHkUgc5buN2Kbg2UGK3NDJlNOOVFqEAbHHkUgc5buN2Kbg2(nI0mp49xIbAJbpmcXaVenecRBG5bV)smaJl6xgn4y(EF)G8mkXVNQcI0h)d5epHqEa1PnXtQcCo3toQFpnmmUNBzaGNCi22YtocvAFVfegQ4AiKhqDAtgyy7Cbr6J)HCsBm4HIbEjAUGi9X)qor)YObhRf0eJHnp(VeTHHX1bevj7gjLkjgdBE8FjAddJRzfEJ8g44799wqyOIRHqEa1PnzGHTdZiFEW7Ved0gdEyeIbEjAUGi95bV)smG(LrdoMV3ccdvCneYdOoTjdmSDUGi95bV)smqBm4HIbEjAUGi95bV)smG(LrdoMV3ccdvCneYdOoTjdmSDiiHHkFVfegQ4AiKhqDAtgyy7h8(lXatAGXL2yWdfd8s0h8(lXatAGXf9lJgCmFVfegQ4AiKhqDAtgyy7adFBstr4sBm4Hrig4LOp49xIbM0aJl6xgn4yT4qoamfJeFHRdngRMawCJuSkE3i57TGWqfxdH8aQtBYadBp0ySAcyXnsXQ42yWd5qoamfJeFHRdngRMawCJuSkgV42377hKNrfxFGsoMNh)tu0tH1VNsZ90ccI4jJ7PHVXagn4AF)G8exW4INrdqimafx8SBfLbak6jd2tP5EUtvOtyY9CuIXep3Pv4CHyapXfDoQSkCpzCpHqo)LO99wqyOIpKgGqyakU0gdEOPqNWKRTkCUqmWKCoQSkC9lJgCmF)G8CWuBgqDAt8ecsyOYtg3tiKdFYlHzaGIEcy14J5PG8urefXZOcE)LyG28KQaNZ9mG60M45wga45lmp5niIau03BbHHk(adBhcsyOQng8WJRqEqo2mG60MmbVILMnfw)7gPnuQeMr(8G3FjgqtbrPsUGi95bV)smGMcIVFqEoyk5ecfeXteSNbJlCTV3ccdv8bg2(wwHn5n3i(ElimuXhyy7csEF2nUCIITXGhkg4LOfK8(SBC5ef1VmAWXArtbdRjNJkRcFki5Dn5DJv8DXTV3ccdv8bg2omJ85bV)smqBm4Hrig4LO5cI0Nh8(lXa6xgn4y(ElimuXhyy7Cbr6ZdE)LyG2yWdfd8s0Cbr6ZdE)Lya9lJgCSwqhHyGxIMfomfrr9lJgCmLkJGMcgwZchMIOOMcsRicieadTT0SWHPikQPGGtlOJqmWlrB8WlmRcx)YObhtPYicieadTT0gp8cZQW1uqWX3pipTGWqfFGHTFJinZdE)LyG2yWdJqmWlrdHW6gyEW7VedW4I(LrdoMsLIbEjAiew3aZdE)Lyagx0VmAWXAbnmJ85bV)smGgdTTAfHyGxIMlisFEW7VedOFz0GJPujxqK(8G3FjgqJH2wTed8s0Cbr6ZdE)Lya9lJgCmC89wqyOIpWW2P4FYK35(ElimuXhyy7bufEjeto2egy977TGWqfFGHTtdqiSjcEknF(6Df99wqyOIpWW2JPmcgZQjcEAk0jiPX3BbHHk(adBhgfO4hBAk0jm5t6BDFVfegQ4dmSDiuegSISkEsdmU47TGWqfFGHTlnFsv0iQcBcJiH77TGWqfFGHT3FhruCIGNaQadBIrU15(ElimuXhyy7egeiGpz1KdXc33BbHHk(adBFlIaWW)SAsohvwfUV3ccdv8bg2onaHWMWuefBJbpmcXaVeTXdVWSkC9lJgCmLkPPGH1gp8cZQW1uquQmGqam02sB8WlmRcxtE3yfhVrEdFVfegQ4dmSD6t4NmMvXTXGhgHyGxI24HxywfU(LrdoMsL0uWWAJhEHzv4Aki(ElimuXhyy7WmYPbiewBm4Hrig4LOnE4fMvHRFz0GJPujnfmS24HxywfUMcIsLbecGH2wAJhEHzv4AY7gR44nYB47TGWqfFGHTBv4CHyGzWaG2yWdJqmWlrB8WlmRcx)YObhtPsAkyyTXdVWSkCnfeLkdieadTT0gp8cZQW1K3nwXXBK3W3BbHHk(adB)k(jcEknFYfeP3gdEixqK(8G3FjgqtbPfnfmSoyaWeWIBKIvXAY7gR44DOcJV3ccdv8bg2E)YreFVfegQ4dmSDcvnTGWq1eW4sBL1)qd92yWdTGWW)ZxVZohV4Uf0CihaMIrIVW1HgJvtalUrkwfJxCRujhYbGPyK4lCnWW3M0364f3447TGWqfFGHTtOQPfegQMagxARS(hYzvm4tXiXx89((b5jEGcimpfJeFXtlimu5jecdryIIEcyCX3BbHHkU2qFixqK(4FiN0gdEOyGxIMlisF8pKt0VmAWX89dYtviKByEIldS(9uTbfg7jR8C3HEUdpfJeFXtywCJWBZtAkXZcjEIrryvSNQr1tkicR)2OkW5Cpverffj3tywCJWQypJKNIrIVW90kmpBm8VNGZ5Eknw5ju7WZDsScZtCXuCXtUyHXCTV3ccdvCTH(adBhgy9p5nOW42ckgaFkgj(cFiuTXGhsom58gJg8wqZHCaykgj(cxhAmwnbS4gPyv8Uqh5nJqmWlrli59z34YjkQFz0GJHJsLrig4LO5cI0Nh8(lXa6xgn4yTGgMr(8G3FjgqtE3yfhVqd1ouahYbGzJXLJJsLbecGH2wAyg5ZdE)Lyan5DJv8DHg37ytO2Hc4qoamBmUCCWbNwqhHyGxIMlisFEW7VedOFz0GJPujxqK(8G3FjgqJH2wkvYHCaykgj(cxhAmwnbS4gPyv8Wi1IMcgwVLvyZykUO5IfgVlu7ahFVfegQ4Ad9bg2UXdVWSk82yWdfd8s0gp8cZQW1VmAWXAbTyGxIMlisFEW7VedOFz0GJ1IlisFEW7VedOXqBRwbecGH2wAUGi95bV)smGM8UXkoEHkYkvgHyGxIMlisFEW7VedOFz0GJHtlOJqmWlrZchMIOO(LrdoMsLrqtbdRzHdtruutbPvebecGH2wAw4Wuef1uqWX3BbHHkU2qFGHTdykCkg2SBXDBki592yWdfd8s0aMcNIHn7wC3McsEx)YObhZ377hKNJsu0tb5zS1VNr1isJcNYgFp3YKgpXdgxoXteSNsZ9mQG3FjCpPPGH9CBZlpHzXncRI9msEkgj(cx75GfvrrXte(NemiEIhSd4cb1JW3BbHHkU2qFGHTFJinkCkB8BJbpmcXaVeD34Yjte8uA(8G3FjC9lJgCmLkPPGH1Cbr6J)HCIMcIsLD7aUqqD8oeAO2yJn3Hc4qoamfJeFHRdngRMawCJuSkghLkPPGH1DJlNmrWtP5ZdE)LW1uquQKd5aWums8fUo0ySAcyXnsXQy8gjFVVFqEIhSX3tof5EQiIYtmufffpbi(908uvqK(4FiNO99wqyOIRn0hyy7HgJvtalUrkwf3gdEinfmSMlisF8pKt0K3nwX3nskioGPaAkyynxqK(4FiNO5Ifg7799dYZDIcOONbJlEUZg(MNrtr4INOYtPH87PyK4lCpzWEYepzCpTYtwXfRepTcZtvbr6EgvW7Ved4jJ75i7eJ6Pfeg(x77TGWqfxBOpWW2bg(2KMIWL2yWdPPGH1adFBYPiXxtbPfhYbGPyK4lCDOXy1eWIBKIvX7UJwqhHyGxIMlisFEW7VedOFz0GJPujxqK(8G3FjgqJH2w40cdjAyG1)K3GcJ1clmMvX(ElimuX1g6dmSDw4WuefBJbpKd5aWums8fUo0ySAcyXnsXQ4D3rRiOPGH1gp8cZQW1uq89wqyOIRn0hyy7WeexM8guyCBm4HCihaMIrIVW1HgJvtalUrkwfV7oArtbdRzHdtruutbPve0uWWAJhEHzv4Aki(EF)G8mkXVNrf8(lXaEgnW4INwSXkU4jfepfKNrYtXiXx4EACpbOk2tJ7PQGiDpJk49xIb8KX9SqINwqy4FTV3ccdvCTH(adB)G3FjgysdmU0gdEOyGxI(G3FjgysdmUOFz0GJ1Id5aWums8fUo0ySAcyXnsXQ4D3rlOJqmWlrZfePpp49xIb0VmAWXuQKlisFEW7VedOXqBlC89wqyOIRn0hyy7adFBsFR3gdEOyGxI24HxywfU(LrdoMV3ccdvCTH(adBp0ySAcyXnsXQyFVfegQ4Ad9bg2oWW3M0ueU0whHpRIhcvBm4HIbEjAJhEHzv46xgn4y(ElimuX1g6dmSDyG1)K3GcJBRJWNvXdHQTGIbWNIrIVWhcvBm4HKdtoVXOb33BbHHkU2qFGHTdtqCzYBqHXT1r4ZQ4Hq5799dYtvwfdUNJAK4lEUtdcdvEIhjmeHjk65oZ4IVFqEg1ItrUN4YQEY4EAbHH)9KQaNZ9ureLNng(3tO2HNiINDe5EYflmM7jc2ZDsScZtCXuCXtycQ7PQGiDpJk49xIb0EcDuXIVNbJFCjpPGeqDwf75oLh8KMs80ccd)7PAuvyHNyOkkkEIJV3ccdvCnNvXGpfJeFzimW6FYBqHXTfuma(ums8f(qOAJbpe6iewymRIvQumWlrZfePpp49xIb0VmAWXAfqiagABP5cI0Nh8(lXaAY7gR47IBfehWuQedjAyG1)K3GcJ1K3nwX3DyCatPsXaVeTXdVWSkC9lJgCSwyirddS(N8guySM8UXk(UqhqiagABPnE4fMvHRjVBSIpanfmS24HxywfUgJIycdv40kGqam02sB8WlmRcxtE3yfF3D0c6ied8s0Cbr6ZdE)Lya9lJgCmLkfd8s0Cbr6ZdE)Lya9lJgCSwCbr6ZdE)LyangABHdoTGMMcgwVLvyZykUO5IfgVlu7qPstHoHjxZIRJO4tii5LWmGMy1y8oe3kvstbdRbg(2KtrIVMcIsLrqtbdRPbiegGIlAki40kcAkyynNIe)jcEcbT9enfeFVVFqEgL43ZDkp8cZQW90GLt8urevue)7jhYlXtda8CNn8npJMIWfpdngj(CpTcZtubu0tgSN1zsZjEQkis3ZOcE)LyapleXZbt4Wuef90i3ZafH8sak6Pfeg(x77TGWqfxZzvm4tXiXxgyy7gp8cZQWBJbpumWlrB8WlmRcx)YObhRvaHayOTLgy4BtAkcx0K3nwXX7gTGMlisFEW7VedOXqBlLkJqmWlrZfePpp49xIb0VmAWXWPf0rig4LOzHdtruu)YObhtPYiOPGH1SWHPikQPG0kIacbWqBlnlCykIIAki44799dYZblQIIINu87zubV)smGNrdmU4jd2tfruEgquampdgx808epyC5eprWEkn3ZOcE)LW98DiOTNCmpJQrKgpvBqHXEYkUCdt75GfvrrXZGXfpJk49xIb8mAGXfpXOiSk2tvbr6EgvW7Ved4jvboN7PIikpBm8VNrcx9CetOigWZDYmshvkQ9mAkXtw5P0W4Egm(9KliiEsXzvSNrf8(lXaEgnW4INOkCpver5j5wOXtO2HNCXcJ5EIG9CNeRW8exmfx0(ElimuX1Cwfd(ums8Lbg2(bV)smWKgyCPng8qXaVe9bV)smWKgyCr)YObhRf0IbEj6UXLtMi4P085bV)s46xgn4yTOPGH1DJlNmrWtP5ZdE)LW1uqA1Td4cb13fp3qPYied8s0DJlNmrWtP5ZdE)LW1VmAWXWPf0ranxqK(8G3FjgqtbPLyGxIMlisFEW7VedOFz0GJHJsLMcDctUUmHIyGzJr6OsrnXQXdJulAkyy9wwHnJP4IMlwy8UqTdC89((b5Pc7FiEQQW2tyeXtGrIVNiINCeQ80WW8CRH)5ApJsf4CUNkIO8SXW)EQsrIVNiypXJOTN0MNSYZTnSqJNbJFpver55wRepfKNyikAW9KMcg2ZDMf3ifRI9mAeq8KwrpHGqawf7jEWoGleu3t6dJiVXkmTNrfxToeW9KFfo1RWXL8eQn2apO2MNrvTnpvvy3MN7C0T55oJF0T5zuvBZZDoAFVfegQ4AoRIbFkgj(YadBNlisF8pKtAJbpumWlrZfePp(hYj6xgn4yTGMymS5X)LOnmmUoGOkz3iPujXyyZJ)lrByyCnRWBK3aNwqhHyGxIMtrI)ebpHG2EI(LrdoMsL0uWWAofj(te8ecA7jAkikv2Td4cb1X7WDSdC89(ElimuX1Cwfd(ums8Lbg2oGPWPyyZUf3TPGK3BJbpumWlrdykCkg2SBXDBki5D9lJgCSwqtmg284)s0gggxhquLSBKuQKymS5X)LOnmmUMv4nYBGJV33pipXfqDAwDpvfePp(hYjEULjnEIhmUCINiypLM7zubV)s4EIiEQsrIVNiypXJOTN4jvboN7PIikpBm8VNsZ9CNn8npvBqHXEkeJjEAfMNDkGWGaUNCXcJ5AFVfegQ4AoRIbFkgj(YadBhWIBKIvXtAeqAJbpKMcgwZfePp(hYjAkiT4qoamfJeFHRdngRMawCJuSkExC3cAtHoHjxdm8TjVbfgRjwnwb0uWWAGHVn5nOWynxSWyC2f34zlOPPGH1DJlNmrWtP5ZdE)LW1uqAfHyGxIMtrI)ebpHG2EI(LrdoMsL0uWWAofj(te8ecA7jAki44799dYZOe)EgvJinkCkB89e)t4uCpXTNIrIVWBZtQcCo3tfruE2y4Fp3zdFZt1guyS2ZOe)EgvJinkCkB89e)t4uCpHYtXiXx8Kb7PIikpBm8VNJ(GGkwWZrBOkSt8msEkS(5EAfMNJSt4Pkfj(EIG9epI2EINVmAWX80kmphzNWZD2W38uTbfgR99wqyOIR5Skg8PyK4ldmS9BePrHtzJFBm4HqZHCaykgj(cxhAmwnbS4gPyvmEHsPstHoHjxlpiOIfMsdvHDIMy1y8omsTIqmWlrZPiXFIGNqqBpr)YObhRLPqNWKRbg(2K3GcJ1eRgVlu40YuOtyY1adFBYBqHXAIvJvanfmSgy4BtEdkmwZflmExOJeEoqKuGPqNWKRLheuXctPHQWortSASc4qoamfJeFHRdngRMawCJuSkgNwqhHyGxIMtrI)ebpHG2EI(LrdoMsLrGHenmW6FYBqHXAYHjN3y0GRujxqK(8G3FjgqtbbNwqhHyGxIUBC5KjcEknFEW7VeU(LrdoMsL0uWW6UXLtMi4P085bV)s4AkikvgqiagABPbg(2KMIWfn5DJvC8UrRUDaxiOoEho44EGiTHced8s0bdaMsZNsdvHDI(Lrdogo(EF)G8exW4INr1isJNQnOWyp3YKgpXdgxoXteSNsZ9mQG3FjCpfd8s8KMs8SqEAbHH)9uLIeFprWEIhrBpXtAky4280kmpTGWW)EQkisF8pKt8KMcg2tRW8CNn8npJMIWfpdOoRI9ebd7jUWG1ZTmPHvEkn3Z64Q4jUyCHbBBEAfMNNjnN4Pfeg(3t8GXLt8eb7P0CpJk49xc3tAky428er8SqEA4BmGrdUN7SHV5z0ueU452gg4Ew3iEIhu9myqAZteXtoRIb3tXiXx80kmp7uaHbbCp3zdFZt1guySNcXyc3tRW8SBLIEYflmMR99wqyOIR5Skg8PyK4ldmS9BePzYBqHXTXGhgbnfmSMtrI)ebpHG2EIMcslXaVeD34Yjte8uA(8G3FjC9lJgCSwqttbdR7gxozIGNsZNh8(lHRPGOuzaHayOTLgy4BtAkcx0K3nwXX7gT62bCHG64D4GJ7bI0gkqmWlrhmayknFknuf2j6xgn4ykvYHCaykgj(cxhAmwnbS4gPyv8U4Uf0McDctUgy4BtEdkmwtSAScOPGH1adFBYBqHXAUyHX7IB8eNw0uWWAUGi9X)qortbPvaHayOTLgy4BtAkcx0K3nwX3DyCadhFVVFqEQWseLNJl0wp32yYo5Eoy8SXW8KJ63tEdIiEECfcWktyOYZMtUNOkCTNrtjEknV8uAUNbuHXegQ8mM8TT5PvyEoy8SXW8uqEYHayINsZ9ev3ZOAePXt1guySNawDpzLG8egrr0Anh5PIikpBm8VNcYtSBap3YKgpLgg3tJg1zLjmu5zH2Il5jUGXfpJQrKgpvBqHXEULjnikXt8GXLt8eb7P0CpJk49xc3tXaVK280kmp3YKgeL4zJHpRI9uimiG75GjUoII7jEejVeMb80kmpTGWW)EUt5HxywfEBEAfMNwqy4FpvfePp(hYjEstbd7jI4zDJ4jEq1ZGbPnprepvfeP7zubV)smGNmUNSYccd)3MNwH5527zWQOO45XvipiEkipJV4PvEAyymHHkd4jf)EIG9uvqKUNrf8(lXaEYkpLM7j5DJvSk2tywCJ4jmb19uLIeFprWEIhrBpr77TGWqfxZzvm4tXiXxgyy73isZK3GcJBJbpmcXaVeD34Yjte8uA(8G3FjC9lJgCSwraTPqNWKRzX1ru8jeK8sygqtSAmEXDlAkyyTXdVWSkCnfeCAbnnfmSMlisF8pKt0uquQSBhWfcQJ3Hd(gdePnuGyGxIoyaWuA(uAOkSt0VmAWXuQmcO5cI0Nh8(lXaAkiTed8s0Cbr6ZdE)Lya9lJgCmCADCfYdYXMbuN2Kj4vS0SPW6FZacbWqBlnxqK(8G3FjgqtE3yfFtOI8gkagGqeOH(4kKhKJndOoTjtWRyPztH1)MbecGH2wAUGi95bV)smGM8UXkoorbOI8g4G3HrAdfanudaTPqNWKRFObnrWtP5ZdE)LyaUMy1y8oe34Gdo(EF)G8mkXVNr1isJNQnOWypzWEQsrIVNiypXJOTN4jJ7PyGxYXAZtAkXZ6mP5epzINfI4P55GfpQ6zubV)smGNmUNwqy4FpnXtP5E2r9xsBEAfMN7SHV5z0ueU4jJ7j5gMIEIiEULbaEsFpj3Wu0ZTmPHvEkn3Z64Q4jUyCHbR23BbHHkUMZQyWNIrIVmWW2VrKMjVbfg3gdEOyGxIMtrI)ebpHG2EI(LrdowRiOPGH1Cks8Ni4je02t0uqAfqiagABPbg(2KMIWfn5DJv8DhghWAbDeIbEjAUGi95bV)smG(LrdowRiGgMr(8G3FjgqtbbhLkfd8s0Cbr6ZdE)Lya9lJgCSwranxqK(8G3FjgqtbbhC89wqyOIR5Skg8PyK4ldmSDalUrkwfpbgNJ89((b5PkeR75oZIBKIvXEgnciCpXOiSk2tvbr6EgvW7Ved4jgfXegQAZtgSNkIO8edvrrXZgd)75GjUoII7jEejVeMb8er8SXW)EYeprfqrprv4T5PvyEIHQOO4jf)EUZS4gPyvSNrJaINyuewf7z0aecdqXfpzWEQiIYZgd)7P55oB4BEQsrIVN4rckO99wqyOIR5Skg8PyK4ldmSDalUrkwfpPraPng8qUGi95bV)smGMcslXaVenxqK(8G3Fjgq)YObhRf0McDctUMfxhrXNqqYlHzanXQX7IBLkJGMcgwdm8TjNIeFnfKw0uWWAAacHbO4IMcco(EF)G8exW4IN7mlUrkwf7z0iG4j5XgbdCo3teSNsZ9ec54ZquCpdOcJjmu5jd2tfrurrmpbi(908uvqK(4FiN4jxSWyprepBm8VNQcI0h)d5epTcZt8GXLt8eb7P0CpJk49xc3tlim8V23BbHHkUMZQyWNIrIVmWW2bS4gPyv8KgbK2yWdHMMcgwZfePp(hYjAY7gR47cLgkfehWuanfmSMlisF8pKt0CXcJvQKMcgwZfePp(hYjAkiTOPGH1DJlNmrWtP5ZdE)LW1uqWX377hKNrj(9exMG4INQnOWyp3YKgphmHdtru0tRW8epyC5eprWEkn3ZOcE)LW1(ElimuX1Cwfd(ums8Lbg2ombXLjVbfg3gdEOyGxIMfomfrr9lJgCSwIbEj6UXLtMi4P085bV)s46xgn4yTOPGH1SWHPikQPG0IMcgw3nUCYebpLMpp49xcxtbX377TGWqfxZzvm4tXiXxgyy7adFBstr4sBm4H0uWWAJhEHzv4Aki(EF)G8mkjmatHUNQuK47jc2t8iA7jEkip5qi3W8exgy97PAdkm2tgSNDkGWGaUNVENDUNg5EcHC(lr77TGWqfxZzvm4tXiXxgyy7WaR)jVbfg3wqXa4tXiXx4dHQng8qYHjN3y0G3Yccd)pF9o7C8cvlAkyynNIe)jcEcbT9enfeFVVFqEgL43ZD2W38mAkcx8CltA8uLIeFprWEIhrBpXtgSNsZ9eyCXtii5LWmGNuCl(EIG9uvqKUNrf8(lXaE2y8kkkEAEctbaEIrrmHHkp3jWf5jd2tfruEgquampJV4PviP5epP4w89eb7P0CphS4rvpJk49xIb8Kb7P0CpjVBSIvXEcZIBep3ACpHcpJcEcqv8jAFVfegQ4AoRIbFkgj(YadBhy4BtAkcxAJbpumWlrZfePpp49xIb0VmAWXAfqiagABnj3cslAkyynNIe)jcEcbT9enfKwqFCfYdYXMbuN2Kj4vS0SPW6FZacbWqBlnxqK(8G3FjgqtE3yfFtOI8gkagGqeOH(4kKhKJndOoTjtWRyPztH1)MbecGH2wAUGi95bV)smGM8UXkoorbOI8g4SBK2qbqd1aqBk0jm56hAqte8uA(8G3FjgGRjwngVdXno4Ouj0qPHcpva0hxH8GCSza1PnzcEflnBkS(XzZacbWqBlnxqK(8G3FjgqtE3yfFtOI8gkagGqeOHgknu4PcG(4kKhKJndOoTjtWRyPztH1poBgqiagABP5cI0Nh8(lXaAY7gR44efGkYBGdo7c9XvipihBgqDAtMGxXsZMcR)ndieadTT0Cbr6ZdE)Lyan5DJv8nHkYBOayacrGg6JRqEqo2mG60MmbVILMnfw)BgqiagABP5cI0Nh8(lXaAY7gR44efGkYBGdo44799dYZOe)EUZg(MNrtr4INBzsJNQuK47jc2t8iA7jEYG9uAUNaJlEcbjVeMb8KIBX3teSN4YmY9mQG3FjgWZgJxrrXtZtykaWtmkIjmu55obUipzWEQiIYZaIcG5z8fpTcjnN4jf3IVNiypLM75GfpQ6zubV)smGNmypLM7j5DJvSk2tywCJ45wJ7ju4zuWtaQIpr77TGWqfxZzvm4tXiXxgyy7adFBstr4sBm4Hrig4LO5cI0Nh8(lXa6xgn4yTcieadTTMKBbPfnfmSMtrI)ebpHG2EIMcslOpUc5b5yZaQtBYe8kwA2uy9VzaHayOTLgMr(8G3FjgqtE3yfFtOI8gkagGqeOH(4kKhKJndOoTjtWRyPztH1)MbecGH2wAyg5ZdE)Lyan5DJvCCIcqf5nWz3iTHcGgQbG2uOtyY1p0GMi4P085bV)smaxtSAmEhIBCWrPsOHsdfEQaOpUc5b5yZaQtBYe8kwA2uy9JZMbecGH2wAyg5ZdE)Lyan5DJv8nHkYBOayacrGgAO0qHNka6JRqEqo2mG60MmbVILMnfw)4SzaHayOTLgMr(8G3FjgqtE3yfhNOaurEdCWzxOpUc5b5yZaQtBYe8kwA2uy9VzaHayOTLgMr(8G3FjgqtE3yfFtOI8gkagGqeOH(4kKhKJndOoTjtWRyPztH1)MbecGH2wAyg5ZdE)Lyan5DJvCCIcqf5nWbhC89(ElimuX1Cwfd(ums8Lbg2oGf3ifRIN0iG0gdEinfmSMtrI)ebpHG2EIMcIV3ccdvCnNvXGpfJeFzGHTdm8TjnfHlTXGhgqiagABnj3csRied8s0DJlNmrWtP5ZdE)LW1VmAWX89((b5PkGf3iaf9m263Zbt4Wuef9KMcg2tb5zdcYHPaaf9KMcg2toQFpFhcA7jhZtCzcIlEQ2GcJ5EULjnEIhmUCINiypLM7zubV)s4AFVfegQ4AoRIbFkgj(YadBNfomfrX2yWdfd8s0SWHPikQFz0GJ1kcO72bCHG64nkh5wbecGH2wAGHVnPPiCrtE3yfF3HBGtlOJqmWlrZfePpp49xIb0VmAWXuQKlisFEW7VedOXqBlC89(ElimuX1Cwfd(ums8Lbg2oWW3M0ueU0gdEyaHayOT1KCliTcngj(C8kg4LOFObnrWtP5ZdE)LW1VmAWX89((b5PkGf3iaf9e7atrpP4Sk2Zbt4Wuef98DiOTNCmpXLjiU4PAdkmM7PG88DiOTN4P08UNBzsJN4bJlN4jc2tP5EgvW7VeUNccP99wqyOIR5Skg8PyK4ldmSDycIltEdkmUng8qXaVenlCykII6xgn4yTOPGH1SWHPikQPG0IMcgwZchMIOOM8UXk(UqPHsbXbmfqtbdRzHdtruuZflm2377TGWqfxZzvm4tXiXxgyy7adFBstr4sBm4HbecGH2wtYTG4799dYZblQIIINwiWWEjgaOONu87Pkfj(EIG9epI2EINBzsJN4YaRFpvBqHXEIrryvSNCwfdUNIrIVO99wqyOIR5Skg8PyK4ldmSDyG1)K3GcJBlOya8PyK4l8Hq1gdEi5WKZBmAWBfbnfmSMtrI)ebpHG2EIMcIV3ccdvCnNvXGpfJeFzGHTli59z34Yjk2gdEOyGxIwqY7ZUXLtuu)YObhRf00uWWAY5OYQWNcsExtE3yfFx8uPsOPPGH1KZrLvHpfK8UM8UXk(UqttbdRnE4fMvHRXOiMWq1abecGH2wAJhEHzv4AY7gR440kGqam02sB8WlmRcxtE3yfFxOImo44799wqyOIR5Skg8PyK4ldmSDycIltEdkmUng8qXaVenlCykII6xgn4yTOPGH1SWHPikQPG0cAAkyynlCykIIAY7gR47ghWuWouanfmSMfomfrrnxSWyLkPPGH1Cbr6J)HCIMcIsLrig4LO7gxozIGNsZNh8(lHRFz0GJHJV3ccdvCnNvXGpfJeFzGHThAmwnbS4gPyvCBm4H0uWWA5bbvSWuAOkSt0uqAfbnfmSMlisF8pKt0uqAXHCaykgj(cxhAmwnbS4gPyvmEHY3BbHHkUMZQyWNIrIVmWW2bS4gPyv8KgbeFVfegQ4AoRIbFkgj(YadBhgy9p5nOW426i8zv8qOAlOya8PyK4l8Hq1gdEi5WKZBmAW99wqyOIR5Skg8PyK4ldmSDyG1)K3GcJBRJWNvXdHQng8Woc)3FjAmgxSkC8IN((b5jUmbXfpvBqHXEY4EIOiE2r4)(lXtygaCI23BbHHkUMZQyWNIrIVmWW2HjiUm5nOW426i8zv8qOwQ4FcNHQ1i4EdOg8nIYBm4AOWZiTu3AKIvX8L6GPdbrKJ55o80ccdvEcyCHR99lvaJl81OlvoRIbFkgj(YA01iqTgDP(YObhBf9s1ccdvlvyG1)K3GcJxQbctoHzlvO9mcpfwymRI9uPspfd8s0Cbr6ZdE)Lya9lJgCmpB5zaHayOTLMlisFEW7VedOjVBSI75UEIBpvGNXbmpvQ0tmKOHbw)tEdkmwtE3yf3ZDh6zCaZtLk9umWlrB8WlmRcx)YObhZZwEIHenmW6FYBqHXAY7gR4EURNq7zaHayOTL24HxywfUM8UXkUNd4jnfmS24HxywfUgJIycdvEIJNT8mGqam02sB8WlmRcxtE3yf3ZD9ChE2YtO9mcpfd8s0Cbr6ZdE)Lya9lJgCmpvQ0tXaVenxqK(8G3Fjgq)YObhZZwEYfePpp49xIb0yOTLN44joE2YtO9KMcgwVLvyZykUO5Ifg75UEc1o8uPspnf6eMCnlUoIIpHGKxcZaAIvJ9eVd9e3EQuPN0uWWAGHVn5uK4RPG4PsLEgHN0uWWAAacHbO4IMcIN44zlpJWtAkyynNIe)jcEcbT9enfKLAqXa4tXiXx4RrGAjRrW9A0L6lJgCSv0l1aHjNWSLQyGxI24HxywfU(LrdoMNT8mGqam02sdm8TjnfHlAY7gR4EIxp3WZwEcTNCbr6ZdE)LyangAB5PsLEgHNIbEjAUGi95bV)smG(LrdoMN44zlpH2Zi8umWlrZchMIOO(LrdoMNkv6zeEstbdRzHdtruutbXZwEgHNbecGH2wAw4Wuef1uq8eNLQfegQwQgp8cZQWxYAKiTgDP(YObhBf9snqyYjmBPkg4LOp49xIbM0aJl6xgn4yE2YtO9umWlr3nUCYebpLMpp49xcx)YObhZZwEstbdR7gxozIGNsZNh8(lHRPG4zlp72bCHG6EURN45gEQuPNr4PyGxIUBC5KjcEknFEW7VeU(LrdoMN44zlpH2Zi8eAp5cI0Nh8(lXaAkiE2YtXaVenxqK(8G3Fjgq)YObhZtC8uPspnf6eMCDzcfXaZgJ0rLIAIvJ9CONrYZwEstbdR3YkSzmfx0CXcJ9CxpHAhEIZs1ccdvl1dE)LyGjnW4YswJSJ1Ol1xgn4yROxQbctoHzlvXaVenxqK(4FiNOFz0GJ5zlpH2tIXWMh)xI2WW46aIQep31Zi5PsLEsmg284)s0gggxZkpXRNrEdpXXZwEcTNr4PyGxIMtrI)ebpHG2EI(LrdoMNkv6jnfmSMtrI)ebpHG2EIMcINkv6z3oGleu3t8o0ZDSdpXzPAbHHQLkxqK(4FiNSK1irEn6s9Lrdo2k6LAGWKty2svmWlrdykCkg2SBXDBki5D9lJgCmpB5j0Esmg284)s0gggxhquL45UEgjpvQ0tIXWMh)xI2WW4Aw5jE9mYB4jolvlimuTubmfofdB2T4UnfK8(swJGNRrxQVmAWXwrVudeMCcZwQ0uWWAUGi9X)qortbXZwEYHCaykgj(cxhAmwnbS4gPyvSN76jU9SLNq7PPqNWKRbg(2K3GcJ1eRg7Pc8KMcgwdm8TjVbfgR5Ifg7joEURN4gp9SLNq7jnfmSUBC5KjcEknFEW7VeUMcINT8mcpfd8s0Cks8Ni4je02t0VmAWX8uPspPPGH1Cks8Ni4je02t0uq8eNLQfegQwQawCJuSkEsJaYswJeLxJUuFz0GJTIEPgim5eMTuH2toKdatXiXx46qJXQjGf3ifRI9eVEcLNkv6PPqNWKRLheuXctPHQWortSASN4DONrYZwEgHNIbEjAofj(te8ecA7j6xgn4yE2YttHoHjxdm8TjVbfgRjwn2ZD9ekpXXZwEAk0jm5AGHVn5nOWynXQXEQapPPGH1adFBYBqHXAUyHXEURNq7zKWtphWZi5Pc80uOtyY1YdcQyHP0qvyNOjwn2tf4jhYbGPyK4lCDOXy1eWIBKIvXEIJNT8eApJWtXaVenNIe)jcEcbT9e9lJgCmpvQ0Zi8edjAyG1)K3GcJ1KdtoVXOb3tLk9KlisFEW7VedOPG4joE2YtO9mcpfd8s0DJlNmrWtP5ZdE)LW1VmAWX8uPspPPGH1DJlNmrWtP5ZdE)LW1uq8uPspdieadTT0adFBstr4IM8UXkUN41Zn8SLND7aUqqDpX7qphCC75aEgPn8ubEkg4LOdgamLMpLgQc7e9lJgCmpXzPAbHHQL6nI0OWPSXFjRruywJUuFz0GJTIEPgim5eMTuJWtAkyynNIe)jcEcbT9enfepB5PyGxIUBC5KjcEknFEW7VeU(LrdoMNT8eApPPGH1DJlNmrWtP5ZdE)LW1uq8uPspdieadTT0adFBstr4IM8UXkUN41Zn8SLND7aUqqDpX7qphCC75aEgPn8ubEkg4LOdgamLMpLgQc7e9lJgCmpvQ0toKdatXiXx46qJXQjGf3ifRI9CxpXTNT8eApnf6eMCnWW3M8guySMy1ypvGN0uWWAGHVn5nOWynxSWyp31tCJNEIJNT8KMcgwZfePp(hYjAkiE2YZacbWqBlnWW3M0ueUOjVBSI75Ud9moG5jolvlimuTuVrKMjVbfgVK1id(A0L6lJgCSv0l1aHjNWSLAeEkg4LO7gxozIGNsZNh8(lHRFz0GJ5zlpJWtO90uOtyY1S46ik(ecsEjmdOjwn2t86jU9SLN0uWWAJhEHzv4AkiEIJNT8eApPPGH1Cbr6J)HCIMcINkv6z3oGleu3t8o0ZbFdphWZiTHNkWtXaVeDWaGP08P0qvyNOFz0GJ5PsLEgHNq7jxqK(8G3FjgqtbXZwEkg4LO5cI0Nh8(lXa6xgn4yEIJNT884kKhKJndOoTjtWRyPXZn9uy975MEgqiagABP5cI0Nh8(lXaAY7gR4EUPNqf5n8ubEcdqiINq7j0EECfYdYXMbuN2Kj4vS045MEkS(9CtpdieadTT0Cbr6ZdE)Lyan5DJvCpXXZOGNqf5n8ehpX7qpJ0gEQapH2tO8CapH2ttHoHjx)qdAIGNsZNh8(lXaCnXQXEI3HEIBpXXtC8eNLQfegQwQ3isZK3GcJxYAeO2yn6s9Lrdo2k6LAGWKty2svmWlrZPiXFIGNqqBpr)YObhZZwEgHN0uWWAofj(te8ecA7jAkiE2YZacbWqBlnWW3M0ueUOjVBSI75Ud9moG5zlpH2Zi8umWlrZfePpp49xIb0VmAWX8SLNr4j0EcZiFEW7VedOPG4joEQuPNIbEjAUGi95bV)smG(LrdoMNT8mcpH2tUGi95bV)smGMcIN44jolvlimuTuVrKMjVbfgVK1iqb1A0LQfegQwQawCJuSkEcmohTuFz0GJTIEjRrGc3RrxQVmAWXwrVudeMCcZwQCbr6ZdE)LyanfepB5PyGxIMlisFEW7VedOFz0GJ5zlpH2ttHoHjxZIRJO4tii5LWmGMy1yp31tC7PsLEgHN0uWWAGHVn5uK4RPG4zlpPPGH10aecdqXfnfepXzPAbHHQLkGf3ifRIN0iGSK1iqfP1Ol1xgn4yROxQbctoHzlvO9KMcgwZfePp(hYjAY7gR4EURNqPHYtf4zCaZtf4jnfmSMlisF8pKt0CXcJ9uPspPPGH1Cbr6J)HCIMcINT8KMcgw3nUCYebpLMpp49xcxtbXtCwQwqyOAPcyXnsXQ4jncilzncu7yn6s9Lrdo2k6LAGWKty2svmWlrZchMIOO(LrdoMNT8umWlr3nUCYebpLMpp49xcx)YObhZZwEstbdRzHdtruutbXZwEstbdR7gxozIGNsZNh8(lHRPGSuTGWq1sfMG4YK3GcJxYAeOI8A0L6lJgCSv0l1aHjNWSLknfmS24HxywfUMcYs1ccdvlvGHVnPPiCzjRrGcpxJUuFz0GJTIEPAbHHQLkmW6FYBqHXl1aHjNWSLk5WKZBmAW9SLNwqy4)5R3zN7jE9ekpB5jnfmSMtrI)ebpHG2EIMcYsnOya8PyK4l81iqTK1iqfLxJUuFz0GJTIEPgim5eMTufd8s0Cbr6ZdE)Lya9lJgCmpB5zaHayOT1KCliE2YtAkyynNIe)jcEcbT9enfepB5j0EECfYdYXMbuN2Kj4vS045MEkS(9CtpdieadTT0Cbr6ZdE)Lyan5DJvCp30tOI8gEQapHbieXtO9eAppUc5b5yZaQtBYe8kwA8Ctpfw)EUPNbecGH2wAUGi95bV)smGM8UXkUN44zuWtOI8gEIJN76zK2Wtf4j0EcLNd4j0EAk0jm56hAqte8uA(8G3FjgGRjwn2t8o0tC7joEIJNkv6j0EcLgk80tf4j0EECfYdYXMbuN2Kj4vS045MEkS(9ehp30ZacbWqBlnxqK(8G3FjgqtE3yf3Zn9eQiVHNkWtyacr8eApH2tO0qHNEQapH2ZJRqEqo2mG60MmbVILgp30tH1VN445MEgqiagABP5cI0Nh8(lXaAY7gR4EIJNrbpHkYB4joEIJN76j0EECfYdYXMbuN2Kj4vS045MEkS(9CtpdieadTT0Cbr6ZdE)Lyan5DJvCp30tOI8gEQapHbieXtO9eAppUc5b5yZaQtBYe8kwA8Ctpfw)EUPNbecGH2wAUGi95bV)smGM8UXkUN44zuWtOI8gEIJN44jolvlimuTubg(2KMIWLLSgbkfM1Ol1xgn4yROxQbctoHzl1i8umWlrZfePpp49xIb0VmAWX8SLNbecGH2wtYTG4zlpPPGH1Cks8Ni4je02t0uq8SLNq75XvipihBgqDAtMGxXsJNB6PW63Zn9mGqam02sdZiFEW7VedOjVBSI75MEcvK3Wtf4jmaHiEcTNq75XvipihBgqDAtMGxXsJNB6PW63Zn9mGqam02sdZiFEW7VedOjVBSI7joEgf8eQiVHN445UEgPn8ubEcTNq55aEcTNMcDctU(Hg0ebpLMpp49xIb4AIvJ9eVd9e3EIJN44PsLEcTNqPHcp9ubEcTNhxH8GCSza1PnzcEflnEUPNcRFpXXZn9mGqam02sdZiFEW7VedOjVBSI75MEcvK3Wtf4jmaHiEcTNq7juAOWtpvGNq75XvipihBgqDAtMGxXsJNB6PW63tC8CtpdieadTT0WmYNh8(lXaAY7gR4EIJNrbpHkYB4joEIJN76j0EECfYdYXMbuN2Kj4vS045MEkS(9CtpdieadTT0WmYNh8(lXaAY7gR4EUPNqf5n8ubEcdqiINq7j0EECfYdYXMbuN2Kj4vS045MEkS(9CtpdieadTT0WmYNh8(lXaAY7gR4EIJNrbpHkYB4joEIJN4SuTGWq1sfy4BtAkcxwYAeOg81Ol1xgn4yROxQbctoHzlvAkyynNIe)jcEcbT9enfKLQfegQwQawCJuSkEsJaYswJG7nwJUuFz0GJTIEPgim5eMTudieadTTMKBbXZwEgHNIbEj6UXLtMi4P085bV)s46xgn4ylvlimuTubg(2KMIWLLSgb3qTgDP(YObhBf9snqyYjmBPkg4LOzHdtruu)YObhZZwEgHNq7z3oGleu3t86zuoYE2YZacbWqBlnWW3M0ueUOjVBSI75Ud9CdpXXZwEcTNr4PyGxIMlisFEW7VedOFz0GJ5PsLEYfePpp49xIb0yOTLN4SuTGWq1sLfomfrXLSgb34En6s9Lrdo2k6LAGWKty2snGqam02AsUfepB5zOXiXN7jE9umWlr)qdAIGNsZNh8(lHRFz0GJTuTGWq1sfy4BtAkcxwYAeChP1Ol1xgn4yROxQbctoHzlvXaVenlCykII6xgn4yE2YtAkyynlCykIIAkiE2YtAkyynlCykIIAY7gR4EURNqPHYtf4zCaZtf4jnfmSMfomfrrnxSW4LQfegQwQWeexM8guy8swJG7DSgDP(YObhBf9snqyYjmBPgqiagABnj3cYs1ccdvlvGHVnPPiCzjRrWDKxJUuFz0GJTIEPAbHHQLkmW6FYBqHXl1aHjNWSLk5WKZBmAW9SLNr4jnfmSMtrI)ebpHG2EIMcYsnOya8PyK4l81iqTK1i4gpxJUuFz0GJTIEPgim5eMTufd8s0csEF2nUCII6xgn4yE2YtO9KMcgwtohvwf(uqY7AY7gR4EURN4PNkv6j0EstbdRjNJkRcFki5Dn5DJvCp31tO9KMcgwB8WlmRcxJrrmHHkphWZacbWqBlTXdVWSkCn5DJvCpXXZwEgqiagABPnE4fMvHRjVBSI75UEcvK9ehpXzPAbHHQLQGK3NDJlNO4swJG7O8A0L6lJgCSv0l1aHjNWSLQyGxIMfomfrr9lJgCmpB5jnfmSMfomfrrnfepB5j0EstbdRzHdtruutE3yf3ZD9moG5Pc8ChEQapPPGH1SWHPikQ5Ifg7PsLEstbdR5cI0h)d5enfepvQ0Zi8umWlr3nUCYebpLMpp49xcx)YObhZtCwQwqyOAPctqCzYBqHXlzncUvywJUuFz0GJTIEPgim5eMTuPPGH1YdcQyHP0qvyNOPG4zlpJWtAkyynxqK(4FiNOPG4zlp5qoamfJeFHRdngRMawCJuSk2t86julvlimuTudngRMawCJuSkEjRrW9GVgDPAbHHQLkGf3ifRIN0iGSuFz0GJTIEjRrI0gRrxQDe(SkEPc1s1ccdvlvyG1)K3GcJxQbfdGpfJeFHVgbQLAGWKty2sLCyY5ngn4l1xgn4yROxYAKib1A0LAhHpRIxQqTuTGWq1sfgy9p5nOW4LAGWKty2sTJW)9xIgJXfRc3t86jEUuFz0GJTIEjRrIeUxJUu7i8zv8sfQLQfegQwQWeexM8guy8s9Lrdo2k6LSKLQH(A01iqTgDP(YObhBf9snqyYjmBPkg4LO5cI0h)d5e9lJgCSLQfegQwQCbr6J)HCYswJG71Ol1xgn4yROxQwqyOAPcdS(N8guy8snqyYjmBPsom58gJgCpB5j0EYHCaykgj(cxhAmwnbS4gPyvSN76j0Egzp30Zi8umWlrli59z34YjkQFz0GJ5joEQuPNr4PyGxIMlisFEW7VedOFz0GJ5zlpH2tyg5ZdE)Lyan5DJvCpXRNq7ju7Wtf4jhYbGzJXL7joEQuPNbecGH2wAyg5ZdE)Lyan5DJvCp31tO9e37WZn9eQD4Pc8Kd5aWSX4Y9ehpXXtC8SLNq7zeEkg4LO5cI0Nh8(lXa6xgn4yEQuPNCbr6ZdE)LyangAB5PsLEYHCaykgj(cxhAmwnbS4gPyvSNd9msE2YtAkyy9wwHnJP4IMlwySN76ju7WtCwQbfdGpfJeFHVgbQLSgjsRrxQVmAWXwrVudeMCcZwQIbEjAJhEHzv46xgn4yE2YtO9umWlrZfePpp49xIb0VmAWX8SLNCbr6ZdE)LyangAB5zlpdieadTT0Cbr6ZdE)Lyan5DJvCpXRNqfzpvQ0Zi8umWlrZfePpp49xIb0VmAWX8ehpB5j0EgHNIbEjAw4Wuef1VmAWX8uPspJWtAkyynlCykIIAkiE2YZi8mGqam02sZchMIOOMcIN4SuTGWq1s14Hxywf(swJSJ1Ol1xgn4yROxQbctoHzlvXaVenGPWPyyZUf3TPGK31VmAWXwQwqyOAPcykCkg2SBXDBki59LSgjYRrxQVmAWXwrVudeMCcZwQr4PyGxIUBC5KjcEknFEW7VeU(LrdoMNkv6jnfmSMlisF8pKt0uq8uPsp72bCHG6EI3HEcTNqTXgEUPN7Wtf4jhYbGPyK4lCDOXy1eWIBKIvXEIJNkv6jnfmSUBC5KjcEknFEW7VeUMcINkv6jhYbGPyK4lCDOXy1eWIBKIvXEIxpJ0s1ccdvl1BePrHtzJ)swJGNRrxQVmAWXwrVudeMCcZwQ0uWWAUGi9X)qortE3yf3ZD9msEQapJdyEQapPPGH1Cbr6J)HCIMlwy8s1ccdvl1qJXQjGf3ifRIxYAKO8A0L6lJgCSv0l1aHjNWSLknfmSgy4Btofj(AkiE2YtoKdatXiXx46qJXQjGf3ifRI9Cxp3HNT8eApJWtXaVenxqK(8G3Fjgq)YObhZtLk9KlisFEW7VedOXqBlpXXZwEIHenmW6FYBqHXAHfgZQ4LQfegQwQadFBstr4YswJOWSgDP(YObhBf9snqyYjmBPYHCaykgj(cxhAmwnbS4gPyvSN765o8SLNr4jnfmS24HxywfUMcYs1ccdvlvw4WuefxYAKbFn6s9Lrdo2k6LAGWKty2sLd5aWums8fUo0ySAcyXnsXQyp31ZD4zlpPPGH1SWHPikQPG4zlpJWtAkyyTXdVWSkCnfKLQfegQwQWeexM8guy8swJa1gRrxQVmAWXwrVudeMCcZwQIbEj6dE)LyGjnW4I(LrdoMNT8Kd5aWums8fUo0ySAcyXnsXQyp31ZD4zlpH2Zi8umWlrZfePpp49xIb0VmAWX8uPsp5cI0Nh8(lXaAm02YtCwQwqyOAPEW7VedmPbgxwYAeOGAn6s9Lrdo2k6LAGWKty2svmWlrB8WlmRcx)YObhBPAbHHQLkWW3M036lzncu4En6s1ccdvl1qJXQjGf3ifRIxQVmAWXwrVK1iqfP1Ol1ocFwfVuHAPAbHHQLkWW3M0ueUSudeMCcZwQIbEjAJhEHzv46xgn4yl1xgn4yROxYAeO2XA0LAhHpRIxQqTuTGWq1sfgy9p5nOW4LAqXa4tXiXx4RrGAPgim5eMTujhMCEJrd(s9Lrdo2k6LSgbQiVgDP2r4ZQ4LkulvlimuTuHjiUm5nOW4L6lJgCSv0lzjlvSdBuazn6AeOwJUuFz0GJTOxQbctoHzlvtHoHjxBv4CHyGj5Cuzv46xgn4ylvlimuTuPbiegGIllzncUxJUuFz0GJTIEPgim5eMTupUc5b5yZaQtBYe8kwA8Ctpfw)EURNrAdpvQ0tyg5ZdE)LyanfepvQ0tUGi95bV)smGMcYs1ccdvlviiHHQLSgjsRrxQwqyOAPULvytEZnYs9Lrdo2k6LSgzhRrxQVmAWXwrVudeMCcZwQIbEjAbjVp7gxorr9lJgCmpB5jnfmSMCoQSk8PGK31K3nwX9CxpX9s1ccdvlvbjVp7gxorXLSgjYRrxQVmAWXwrVudeMCcZwQr4PyGxIMlisFEW7VedOFz0GJTuTGWq1sfMr(8G3FjgyjRrWZ1Ol1xgn4yROxQbctoHzlvXaVenxqK(8G3Fjgq)YObhZZwEcTNr4PyGxIMfomfrr9lJgCmpvQ0Zi8KMcgwZchMIOOMcINT8mcpdieadTT0SWHPikQPG4joE2YtO9mcpfd8s0gp8cZQW1VmAWX8uPspJWZacbWqBlTXdVWSkCnfepXzPAbHHQLkxqK(8G3FjgyjRrIYRrxQwqyOAPsX)KjVZxQVmAWXwrVK1ikmRrxQwqyOAPgqv4Lqm5ytyG1)s9Lrdo2k6LSgzWxJUuTGWq1sLgGqyte8uA(817kUuFz0GJTIEjRrGAJ1OlvlimuTuJPmcgZQjcEAk0jiPzP(YObhBf9swJafuRrxQwqyOAPcJcu8Jnnf6eM8j9T(s9Lrdo2k6LSgbkCVgDPAbHHQLkekcdwrwfpPbgxwQVmAWXwrVK1iqfP1OlvlimuTuLMpPkAevHnHrKWxQVmAWXwrVK1iqTJ1OlvlimuTu7VJikorWtavGHnXi368L6lJgCSv0lzncurEn6s1ccdvlvcdceWNSAYHyHVuFz0GJTIEjRrGcpxJUuTGWq1sDlIaWW)SAsohvwf(s9Lrdo2k6LSgbQO8A0L6lJgCSv0l1aHjNWSLAeEkg4LOnE4fMvHRFz0GJ5PsLEstbdRnE4fMvHRPG4PsLEgqiagABPnE4fMvHRjVBSI7jE9mYBSuTGWq1sLgGqytykIIlzncukmRrxQVmAWXwrVudeMCcZwQr4PyGxI24HxywfU(LrdoMNkv6jnfmS24HxywfUMcYs1ccdvlv6t4NmMvXlzncud(A0L6lJgCSv0l1aHjNWSLAeEkg4LOnE4fMvHRFz0GJ5PsLEstbdRnE4fMvHRPG4PsLEgqiagABPnE4fMvHRjVBSI7jE9mYBSuTGWq1sfMronaHWwYAeCVXA0L6lJgCSv0l1aHjNWSLAeEkg4LOnE4fMvHRFz0GJ5PsLEstbdRnE4fMvHRPG4PsLEgqiagABPnE4fMvHRjVBSI7jE9mYBSuTGWq1s1QW5cXaZGbalzncUHAn6s9Lrdo2k6LAGWKty2sLlisFEW7VedOPG4zlpPPGH1bdaMawCJuSkwtE3yf3t8o0tfMLQfegQwQxXprWtP5tUGi9LSgb34En6s1ccdvl1(LJil1xgn4yROxYAeChP1Ol1xgn4yROxQbctoHzlvlim8)817SZ9eVEIBpB5j0EYHCaykgj(cxhAmwnbS4gPyvSN41tC7PsLEYHCaykgj(cxdm8Tj9TUN41tC7jolvlimuTuju10ccdvtaJllvaJlZY6FPAOVK1i4EhRrxQVmAWXwrVuTGWq1sLqvtlimunbmUSubmUmlR)LkNvXGpfJeFzjlzPcH8aQtBYA01iqTgDP(YObhBf9swJG71Ol1xgn4yROxYAKiTgDP(YObhBf9swJSJ1Ol1xgn4yROxYAKiVgDPAbHHQLQGK3NDJlNO4s9Lrdo2k6LSgbpxJUuFz0GJTIEPgim5eMTufd8s0Cbr6J)HCI(LrdoMNT8eApjgdBE8FjAddJRdiQs8CxpJKNkv6jXyyZJ)lrByyCnR8eVEg5n8eNLQfegQwQCbr6J)HCYswJeLxJUuFz0GJTIEPgim5eMTuJWtXaVenxqK(8G3Fjgq)YObhBPAbHHQLkmJ85bV)smWswJOWSgDP(YObhBf9snqyYjmBPkg4LO5cI0Nh8(lXa6xgn4ylvlimuTu5cI0Nh8(lXalznYGVgDPAbHHQLkeKWq1s9Lrdo2k6LSgbQnwJUuFz0GJTIEPgim5eMTufd8s0h8(lXatAGXf9lJgCSLQfegQwQh8(lXatAGXLLSgbkOwJUuFz0GJTIEPgim5eMTuJWtXaVe9bV)smWKgyCr)YObhZZwEYHCaykgj(cxhAmwnbS4gPyvSN76zKwQwqyOAPcm8TjnfHllzncu4En6s9Lrdo2k6LAGWKty2sLd5aWums8fUo0ySAcyXnsXQypXRN4EPAbHHQLAOXy1eWIBKIvXlzjlzPAusdISuvzDkGjmuHlqmyzjlzTa]] )
    spec:RegisterPack( "Elemental Funnel", 20190709.1630, [[deveXbqiHWJukYLifHnjf9jHO0OaPofizvKI6vsHMLuWTuQyxK8lfKHPq6yqfltiYZesmnfIUguvTnOs13eIkJdQuQZPuuToHOW7eII08uQ09uG9bvL)PqivheQuYcfs9qOsstuHqDrHK2Ocb(iujHrQqiLtkevTsLQEPquuZuPOCtOsQDQu4NkeIHcvkwkujrpLunvfuxvHG(QcHKXkefHZkefr7vj)vrdwYHPSye9ybtguxw1MHYNfQrlLonkVwP0SbUTuTBr)gYWbXXjfrlhPNJQPtCDe2ouLVRqnEOsCEsH1tksZNuA)u9cN1WlDyt(AJinkoB(OrUr3Cfo4(ihjorULUObKV0HyHTw8x6P1)spQG3FkgWRrarMhS0HyAaqg8A4LohrqdFPV0jjyajYNlYLoSjFTrKgfNnF0i3OBUchCpklDoKhwBejCpsl9wgm8Zf5sh(8WsFtEfvW7pfd4LER1T0lOhbezEalJHY3VjVAfbcpYyOHIzslbPkG6dXzDcGjmugOgMmeN1dd573Kx7jaA41M3GxrAuC2CV2XlCW9iJOm6shcfHXaFPVjVIk49NIb8sV16w6f0JaImpGLXq573KxTIaHhzm0qXmPLGufq9H4SobWegkdudtgIZ6HH89BYR9ean8AZBWRinkoBUx74fo4EKrug13773Kx4QTwgFEKHVFtETJxJq(9kYeZdE)PyafbeVOM0EQxsRLEfAFyllJ9kGqay04K7LG8I)7fdZRdE)PyaUxg9EzbHH3v((n51oEnIzCJeCyVIQrLwVIk49NIb86PqzNR89BYRD8cx57i8Ux4w8Wtyld3lH1)qrVzEfAFyRY3VjV2XlClyyVIQg3leMxs79sxq0Uxd5fU(YruLV33VjVIkU8aHCyVipgIEVcOoPjEr(ywYvEHBfchIW9kr5oTgTJra8YccdLCVqjqdLV3ccdLCfe6dOoPjdWagFRV3ccdLCfe6dOoPjnoyimec23BbHHsUcc9buN0KghmKre3FkMWqPVFtEPNgeEls8IAmyVijWWoSxCXeUxKhdrVxbuN0eViFml5EzjSxqOFhiiryzSxmUxWO8kFVfegk5ki0hqDstACWq80GWBrYKlMW99wqyOKRGqFa1jnPXbdji59z34YPA473KxwqyOKRGqFa1jnPXbdDJkTZdE)PyGgyydIqmWtrbHY6gyEW7pfdW4I6PrcoSV33VjVgH87LUGO9T)qo1li0hqDst8IibNZ9IJ63ldgM71yga4fhIno9IJqPY3BbHHsUcc9buN0Kghmexq0(2FiN2adBGyGNIIliAF7pKtvpnsWHBcn1yWZJ3trzWWCvarKYUrrRwQXGNhVNIYGH5kwIp8pku(EFVfegk5ki0hqDstACWqym6Nh8(tXanWWgeHyGNIIliAFEW7pfdOEAKGd77TGWqjxbH(aQtAsJdgIliAFEW7pfd0adBGyGNIIliAFEW7pfdOEAKGd77TGWqjxbH(aQtAsJdgccsyO03BbHHsUcc9buN0Kghm0bV)umWKeyCPbg2aXapf1bV)umWKeyCr90ibh23BbHHsUcc9buN0KghmeWWZMKeuU0adBqeIbEkQdE)PyGjjW4I6PrcoCtoKdatXOXx4QqRXYjGf3kjlJ3nk(ElimuYvqOpG6KM04GHcTglNawCRKSmUbg2aoKdatXOXx4QqRXYjGf3kjlJXxK89((n5vuXLhiKd71X7un8sy97L0EVSGGOEX4Ez4zmGrcUY3VjVWvnU4v0aecgqWfV6wsyaGgEXW8sAVx4wA6Pm5Enm1yIx4wz4CHAaVWvEokTmCVyCVGqp)PO89wqyOKpGeGqWacU0adBGPPNYKRSmCUqnWKEokTmC1tJeCyF)M8kYN7eqDst8ccsyO0lg3li0JD6tHzaGgEby52d7LG8sdeb1ROcE)PyGg8IibNZ9kG6KM41yga41tyV4TiQa0W3BbHHsEJdgccsyOSbg2GJlqEqo8mG6KMmbpJL2Dew)7gLr1QfJr)8G3FkgqrarRwUGO95bV)umGIaIVFtEf5t5ukbeXleMxbJlCLV3ccdL8ghm0ywcp5T3O(ElimuYBCWqcsEF2nUCQgnWWgig4POeK8(SBC5unupnsWHBssGHPONJsldFki5Df9DJL8DJKV3ccdL8ghmegJ(5bV)umqdmSbrig4PO4cI2Nh8(tXaQNgj4W(ElimuYBCWqCbr7ZdE)PyGgyyded8uuCbr7ZdE)Pya1tJeC4MqhHyGNIIfogbvd1tJeCyTAJGKadtXchJGQHIasZicieagnovSWXiOAOiGavtOJqmWtrz8Wtyldx90ibhwR2icieagnovgp8e2YWveqGY3VjVSGWqjVXbdDJkTZdE)PyGgyydIqmWtrbHY6gyEW7pfdW4I6PrcoSwTIbEkkiuw3aZdE)PyagxupnsWHBcngJ(5bV)umGcgnoBgHyGNIIliAFEW7pfdOEAKGdRvlxq0(8G3FkgqbJgNnfd8uuCbr7ZdE)Pya1tJeCyO89wqyOK34GHi4FYK35(ElimuYBCWqbugEkuto8edy977TGWqjVXbdrcqi4jcBkTF(8Dn89wqyOK34GHIjmkmZYjcBAA6PiP13BbHHsEJdgcdfi4hEAA6Pm5tYBDFVfegk5noyiieugMgSmEscmU47TGWqjVXbdjTFsKKiIeEIHOH77TGWqjVXbd1Fhr1yIWMaIadEctV15(ElimuYBCWqugeiGpz5KdXc33BbHHsEJdgAmIcGX7SCsphLwgUV3ccdL8ghmejaHGNyeunAGHnicXapfLXdpHTmC1tJeCyTAjjWWugp8e2YWveq0QnGqay04uz8WtyldxrF3yjhF4FuFVfegk5noyiYt5NULLXnWWgeHyGNIY4HNWwgU6PrcoSwTKeyykJhEcBz4kci(ElimuYBCWqym6jbieCdmSbrig4POmE4jSLHREAKGdRvljbgMY4HNWwgUIaIwTbecaJgNkJhEcBz4k67gl54d)J67TGWqjVXbdzz4CHAGzWaGgyydIqmWtrz8Wtyldx90ibhwRwscmmLXdpHTmCfbeTAdieagnovgp8e2YWv03nwYXh(h13BbHHsEJdg6A8jcBkTFYfeT3adBaxq0(8G3FkgqraPjjbgMkyaWeWIBLKLXk67gl54BaUTV3ccdL8ghmu)YruFVfegk5noyikroTGWq5eW4sdP1)ad9gyydSGWW7ZNVZohF4Vj0CihaMIrJVWvHwJLtalUvswgJp8RvlhYbGPy04lCfWWZMK364d)q57TGWqjVXbdrjYPfegkNagxAiT(hWzzm4tXOXx89((n5fUMaimVeJgFXllimu6fekdrzIgEbyCX3BbHHsUYqFaxq0(2FiN2adBGyGNIIliAF7pKtvpnsWH99BYlDi0BWEncaw)EP3IcB9ILET7aVgPxIrJV4fglUv4n4fjH4vIeVGjOSm2l9O6fbeH1Fdej4CUxAGiIS07fglUvyzSxrXlXOXx4EzjSxTgE3lW5CVKwl9cNr61ikwc7fUccU4fxSWwUY3BbHHsUYqVXbdHbS(N8wuyBdbncGpfJgFHpaNgyydOhJEERrcEtO5qoamfJgFHRcTglNawCRKSmExOX)orig4POeK8(SBC5unupnsWHHsR2ied8uuCbr7ZdE)Pya1tJeC4MqJXOFEW7pfdOOVBSKJpOXzKAMd5aWS14YHsR2acbGrJtfgJ(5bV)umGI(UXs(UqhPrUdoJuZCihaMTgxouqbvtOJqmWtrXfeTpp49NIbupnsWH1QLliAFEW7pfdOGrJtTA5qoamfJgFHRcTglNawCRKSmEquAssGHPgZs4zmbxuCXcB3fNrcLV3ccdLCLHEJdgY4HNWwgEdmSbIbEkkJhEcBz4QNgj4WnHwmWtrXfeTpp49NIbupnsWHBYfeTpp49NIbuWOXzZacbGrJtfxq0(8G3FkgqrF3yjhF4GFTAJqmWtrXfeTpp49NIbupnsWHHQj0rig4POyHJrq1q90ibhwR2iijWWuSWXiOAOiG0mIacbGrJtflCmcQgkciq57TGWqjxzO34GHamnjbdE2T4UnfK8EdmSbIbEkkattsWGNDlUBtbjVREAKGd7799BYRHPA4LG8k263ROAuPvtsyBVxJzsRx4AJlN6fcZlP9EfvW7pfUxKeyyEnU9PxyS4wHLXEffVeJgFHR8AeJYiR4fcVtdgeVW12bCHI6r47TGWqjxzO34GHUrLwnjHT9nWWgeHyGNIQBC50jcBkTFEW7pfU6PrcoSwTKeyykUGO9T)qovrarR2UDaxOOo(ganoJo6oJuZCihaMIrJVWvHwJLtalUvswgdLwTKeyyQUXLtNiSP0(5bV)u4kciA1YHCaykgn(cxfAnwobS4wjzzm(IIV33VjVW1227fNGEV0ar4fmkJSIxae)EzEPliAF7pKtv(ElimuYvg6noyOqRXYjGf3kjlJBGHnGKadtXfeTV9hYPk67gl57gfnhhG1mjbgMIliAF7pKtvCXcB99((n51isc0WRGXfV2mdpZROjOCXlu6L0s)9smA8fUxmmVyIxmUxw6fl5ILIxwc7LUGODVIk49NIb8IX9AJrKH9YccdVR89wqyOKRm0BCWqadpBssq5sdmSbKeyykGHNn5e04RiG0Kd5aWumA8fUk0ASCcyXTsYY4DhztOJqmWtrXfeTpp49NIbupnsWH1QLliAFEW7pfdOGrJtOAcJefgW6FYBrHTkHf2YYyFVfegk5kd9ghmelCmcQgnWWgWHCaykgn(cxfAnwobS4wjzz8UJSzeKeyykJhEcBz4kci(ElimuYvg6noyimkIltElkSTbg2aoKdatXOXx4QqRXYjGf3kjlJ3DKnjjWWuSWXiOAOiG0mcscmmLXdpHTmCfbeFVVFtEnc53ROcE)PyaVIgyCXll2yjx8IaIxcYRO4Ly04lCVmUxaug7LX9sxq0Uxrf8(tXaEX4ELiXllim8UY3BbHHsUYqVXbdDW7pfdmjbgxAGHnqmWtrDW7pfdmjbgxupnsWHBYHCaykgn(cxfAnwobS4wjzz8UJSj0rig4PO4cI2Nh8(tXaQNgj4WA1YfeTpp49NIbuWOXju(ElimuYvg6noyiGHNnjV1BGHnqmWtrz8Wtyldx90ibh23BbHHsUYqVXbdfAnwobS4wjzzSV3ccdLCLHEJdgcy4ztsckxAOJWJLXdWPbg2aXapfLXdpHTmC1tJeCyFVfegk5kd9ghmegW6FYBrHTn0r4XY4b40qqJa4tXOXx4dWPbg2a6XON3AKG77TGWqjxzO34GHWOiUm5TOW2g6i8yz8aC89((n5LolJb3RHnA8fVWTccdLEHBOmeLjA41MX4IVFtEf1KtqVxJaDVyCVSGWW7ErKGZ5EPbIWRwdV7foJ0le1RoIEV4If2Y9cH51ikwc7fUccU4fgf19sxq0Uxrf8(tXakVGoQWX3RGXFKHxeqcOolJ9c3Ih8IKq8YccdV7LEuJm1lyugzfVGY3BbHHsUIZYyWNIrJVmady9p5TOW2gcAeaFkgn(cFaonWWgaDeclSLLXA1kg4PO4cI2Nh8(tXaQNgj4WndieagnovCbr7ZdE)Pyaf9DJL8DJKMJdWA1cJefgW6FYBrHTk67gl57oioaRvRyGNIY4HNWwgU6PrcoCtyKOWaw)tElkSvrF3yjFxOdieagnovgp8e2YWv03nwYBKKadtz8WtyldxbtqnHHsOAgqiamACQmE4jSLHROVBSKV7iBcDeIbEkkUGO95bV)umG6PrcoSwTIbEkkUGO95bV)umG6PrcoCtUGO95bV)umGcgnoHcQMqtsGHPgZs4zmbxuCXcB3fNrQvRPPNYKRyX5re8jeK8uygqrTCl(gejTAjjWWuadpBYjOXxrarR2iijWWuKaecgqWffbeOAgbjbgMItqJ)eHnHGgFQIaIV33VjVgH87fUfp8e2YW9YWKt9sderKfV7fhYtXlda8AZm8mVIMGYfVcTgn(CVSe2luc0WlgMx5zs7PEPliA3ROcE)PyaVse1RiF4yeun8YO3RabL(uaA4LfegEx57TGWqjxXzzm4tXOXxACWqgp8e2YWBGHnqmWtrz8Wtyldx90ibhUzaHaWOXPcy4ztsckxu03nwYX3OnHMliAFEW7pfdOGrJtTAJqmWtrXfeTpp49NIbupnsWHHQj0rig4POyHJrq1q90ibhwR2iijWWuSWXiOAOiG0mIacbGrJtflCmcQgkciq5799BYRrmkJSIxe87vubV)umGxrdmU4fdZlnqeEfqeayVcgx8Y8cxBC5uVqyEjT3ROcE)PW96DiOXNEyVIQrLwV0BrHTEXsUCdw51igLrwXRGXfVIk49NIb8kAGXfVGjOSm2lDbr7EfvW7pfd4frcoN7LgicVAn8Uxrbx8AdtiOgWRr0mAhLAO8kAcXlw6L0Y4Efm(9IliiErWzzSxrf8(tXaEfnW4IxOmCV0ar4f9wO1lCgPxCXcB5EHW8AeflH9cxbbxu(ElimuYvCwgd(umA8Lghm0bV)umWKeyCPbg2aXapf1bV)umWKeyCr90ibhUj0IbEkQUXLtNiSP0(5bV)u4QNgj4WnjjWWuDJlNorytP9ZdE)PWveqA2Td4cf13f3hvR2ied8uuDJlNorytP9ZdE)PWvpnsWHHQj0ranxq0(8G3FkgqraPPyGNIIliAFEW7pfdOEAKGddLwTMMEktUknHGAGzRr7Oudf1YTdIstscmm1ywcpJj4IIlwy7U4msO89((n5vK5FiEPhz2lme1lGrJVxiQxCek9YGH9ASH35kVgHj4CUxAGi8Q1W7EPtqJVximVWnOXN2GxS0RXTSqRxbJFV0ar41ylfVeKxWicsW9IKadZRnJf3kjlJ9kAeq8IudVGGqawg7fU2oGluu3lYJHOV1syLxrfxSoeW9IFnjXZWJm8cNrhfxR3GxrvVbV0Jm3GxBw0n41MHx0n4vu1BWRnlAFVfegk5kolJbFkgn(sJdgIliAF7pKtBGHnqmWtrXfeTV9hYPQNgj4WnHMAm45X7POmyyUkGisz3OOvl1yWZJ3trzWWCflXh(hfQMqhHyGNIItqJ)eHnHGgFQ6PrcoSwTKeyykobn(te2ecA8PkciA12Td4cf1X3GrosO89(ElimuYvCwgd(umA8LghmeGPjjyWZUf3TPGK3BGHnqmWtrbyAscg8SBXDBki5D1tJeC4Mqtng8849uugmmxfqePSBu0QLAm45X7POmyyUIL4d)JcLV33VjVWvrDswEV0feTV9hYPEnMjTEHRnUCQximVK27vubV)u4EHOEPtqJVximVWnOXN6frcoN7LgicVAn8Uxs79AZm8mV0BrHTEjuJjEzjSxDcGWGaUxCXcB5kFVfegk5kolJbFkgn(sJdgcWIBLKLXtseqAGHnGKadtXfeTV9hYPkcin5qoamfJgFHRcTglNawCRKSmE3i1eAttpLjxbm8SjVff2QOwUvZKeyykGHNn5TOWwfxSWwO2ns4EtOjjWWuDJlNorytP9ZdE)PWveqAgHyGNIItqJ)eHnHGgFQ6PrcoSwTKeyykobn(te2ecA8Pkciq5799BYRri)EfvJkTAscB79cVt5eCVIKxIrJVWBWlIeCo3lnqeE1A4DV2mdpZl9wuyRYRri)EfvJkTAscB79cVt5eCVWXlXOXx8IH5LgicVAn8Uxd)GGswWRHBjs4t9kkEjS(5EzjSxBmI4Lobn(EHW8c3GgFQxpnsWH9YsyV2yeXRnZWZ8sVff2Q89wqyOKR4Smg8Py04lnoyOBuPvtsyBFdmSbqZHCaykgn(cxfAnwobS4wjzzm(WrRwttpLjxjpiOKfMslrcFQIA5w8niknJqmWtrXjOXFIWMqqJpv90ibhUPPPNYKRagE2K3IcBvul3Uloq1000tzYvadpBYBrHTkQLB1mjbgMcy4ztElkSvXflSDxOJcU3yu0SPPNYKRKheuYctPLiHpvrTCRM5qoamfJgFHRcTglNawCRKSmgQMqhHyGNIItqJ)eHnHGgFQ6PrcoSwTraJefgW6FYBrHTk6XON3AKGRvlxq0(8G3FkgqrabQMqhHyGNIQBC50jcBkTFEW7pfU6PrcoSwTKeyyQUXLtNiSP0(5bV)u4kciA1gqiamACQagE2KKGYff9DJLC8nAZUDaxOOo(gS5rQXOmQMfd8uubdaMs7NslrcFQ6Prcomu(EF)M8cx14Ixr1OsRx6TOWwVgZKwVW1gxo1leMxs79kQG3FkCVed8u8IKq8krEzbHH39sNGgFVqyEHBqJp1lscmSg8YsyVSGWW7EPliAF7pKt9IKadZllH9AZm8mVIMGYfVcOolJ9cHH5fU6i2RXmPLLEjT3R84I4fUcC1rCdEzjSxNjTN6LfegE3lCTXLt9cH5L0EVIk49Nc3lscmSg8cr9krEz4zmGrcUxBMHN5v0euU414wg4EL3OEHR19kyqAWle1lolJb3lXOXx8YsyV6eaHbbCV2mdpZl9wuyRxc1yc3llH9QBPgEXflSLR89wqyOKR4Smg8Py04lnoyOBuPDYBrHTnWWgebjbgMItqJ)eHnHGgFQIastXapfv34YPte2uA)8G3FkC1tJeC4MqtsGHP6gxoDIWMs7Nh8(tHRiGOvBaHaWOXPcy4ztsckxu03nwYX3On72bCHI64BWMhPgJYOAwmWtrfmaykTFkTej8PQNgj4WA1YHCaykgn(cxfAnwobS4wjzz8UrQj0MMEktUcy4ztElkSvrTCRMjjWWuadpBYBrHTkUyHT7gjChQMKeyykUGO9T)qovraPzaHaWOXPcy4ztsckxu03nwY3DqCagkFVVFtEfzseHxBt0yVg3AYi6Ef59Q1G9IJ63lElIkEDCbcWstyO0R2tVxOmCLxrtiEjTp9sAVxbucZegk9kM(Xn4LLWEf59Q1G9sqEXHayIxs79cL3ROAuP1l9wuyRxawEVyPG8cdrqvkfh5LgicVAn8UxcYl4BaVgZKwVKwg3lJe1zPjmu6vIghz4fUQXfVIQrLwV0BrHTEnMjTicXlCTXLt9cH5L0EVIk49Nc3lXapLg8YsyVgZKweH4vRHhlJ9sOmiG7vKpopIG7fUbjpfMb8YsyVSGWW7EHBXdpHTm8g8YsyVSGWW7EPliAF7pKt9IKadZle1R8g1lCTUxbdsdEHOEPliA3ROcE)PyaVyCVyPfegEVbVSe2RX3RGLrwXRJlqEq8sqEfFXll9YGHzcdLgWlc(9cH5LUGODVIk49NIb8ILEjT3l67glzzSxyS4wXlmkQ7Lobn(EHW8c3GgFQY3BbHHsUIZYyWNIrJV04GHUrL2jVff22adBqeIbEkQUXLtNiSP0(5bV)u4QNgj4WnJaAttpLjxXIZJi4tii5PWmGIA5w8fPMKeyykJhEcBz4kciq1eAscmmfxq0(2FiNQiGOvB3oGluuhFd28rBmkJQzXapfvWaGP0(P0sKWNQEAKGdRvBeqZfeTpp49NIbueqAkg4PO4cI2Nh8(tXaQNgj4Wq184cKhKdpdOoPjtWZyPDhH1)obecaJgNkUGO95bV)umGI(UXs(o4G)r1mgaHOqd9XfipihEgqDstMGNXs7ocR)DcieagnovCbr7ZdE)Pyaf9DJLCO0e4G)rHcFdIYOAgACAeAttpLjx9qlAIWMs7Nh8(tXaCf1YT4BqKGckO89((n51iKFVIQrLwV0BrHTEXW8sNGgFVqyEHBqJp1lg3lXapLd3GxKeIx5zs7PEXeVse1lZRrmUr3ROcE)PyaVyCVSGWW7EzIxs79QJ6pLg8YsyV2mdpZROjOCXlg3l6nyn8cr9Amda8I8ErVbRHxJzsll9sAVx5XfXlCf4QJyLV3ccdLCfNLXGpfJgFPXbdDJkTtElkSTbg2aXapffNGg)jcBcbn(u1tJeC4MrqsGHP4e04prytiOXNQiG0mGqay04ubm8SjjbLlk67gl57oioa3e6ied8uuCbr7ZdE)Pya1tJeC4MrangJ(5bV)umGIacuA1kg4PO4cI2Nh8(tXaQNgj4WnJaAUGO95bV)umGIacuq57TGWqjxXzzm4tXOXxACWqawCRKSmEcmoh5799BYlDiw3RnJf3kjlJ9kAeq4EbtqzzSx6cI29kQG3FkgWlycQjmu2GxmmV0ar4fmkJSIxTgE3RiFCEeb3lCdsEkmd4fI6vRH39IjEHsGgEHYWBWllH9cgLrwXlc(9AZyXTsYYyVIgbeVGjOSm2RObiemGGlEXW8sdeHxTgE3lZRnZWZ8sNGgFVWnuuq57TGWqjxXzzm4tXOXxACWqawCRKSmEsIasdmSbCbr7ZdE)PyafbKMIbEkkUGO95bV)umG6PrcoCtOnn9uMCflopIGpHGKNcZakQLB3nsA1gbjbgMcy4ztobn(kcinjjWWuKaecgqWffbeO89((n5fUQXfV2mwCRKSm2ROraXl6Jnkm4CUximVK27fe6XJHi4EfqjmtyO0lgMxAGiISWEbq87L5LUGO9T)qo1lUyHTEHOE1A4DV0feTV9hYPEzjSx4AJlN6fcZlP9EfvW7pfUxwqy4DLV3ccdLCfNLXGpfJgFPXbdbyXTsYY4jjcinWWganjbgMIliAF7pKtv03nwY3fhfoAooaRzscmmfxq0(2FiNQ4If2QvljbgMIliAF7pKtveqAssGHP6gxoDIWMs7Nh8(tHRiGaLV33VjVgH871iGI4Ix6TOWwVgZKwVI8HJrq1WllH9cxBC5uVqyEjT3ROcE)PWv(ElimuYvCwgd(umA8LghmegfXLjVff22adBGyGNIIfogbvd1tJeC4MIbEkQUXLtNiSP0(5bV)u4QNgj4WnjjWWuSWXiOAOiG0KKadt1nUC6eHnL2pp49NcxraX377TGWqjxXzzm4tXOXxACWqadpBssq5sdmSbKeyykJhEcBz4kci(EF)M8AekmattVx6e047fcZlCdA8PEjiV4qO3G9AeaS(9sVff26fdZRobqyqa3RNVZo3lJEVGqp)PO89wqyOKR4Smg8Py04lnoyimG1)K3IcBBiOra8Py04l8b40adBa9y0ZBnsWBAbHH3NpFNDo(WPjjbgMItqJ)eHnHGgFQIaIV33VjVgH871Mz4zEfnbLlEnMjTEPtqJVximVWnOXN6fdZlP9EbmU4feK8uygWlcUfFVqyEPliA3ROcE)PyaVAnEgzfVmVWiaaVGjOMWqPxJi4k9IH5LgicVcicaSxXx8YsK0EQxeCl(EHW8sAVxJyCJUxrf8(tXaEXW8sAVx03nwYYyVWyXTIxJnUx4G7AcVaOm(uLV3ccdLCfNLXGpfJgFPXbdbm8SjjbLlnWWgig4PO4cI2Nh8(tXaQNgj4WndieagnoN0BbPjjbgMItqJ)eHnHGgFQIastOpUa5b5WZaQtAYe8mwA3ry9VtaHaWOXPIliAFEW7pfdOOVBSKVdo4FunJbqik0qFCbYdYHNbuN0Kj4zS0UJW6FNacbGrJtfxq0(8G3FkgqrF3yjhknbo4FuO2nkJQzOXPrOnn9uMC1dTOjcBkTFEW7pfdWvul3IVbrckO0QfACu4G7Ag6JlqEqo8mG6KMmbpJL2Dew)qTtaHaWOXPIliAFEW7pfdOOVBSKVdo4FunJbqik0qJJchCxZqFCbYdYHNbuN0Kj4zS0UJW6hQDcieagnovCbr7ZdE)Pyaf9DJLCO0e4G)rHcQDH(4cKhKdpdOoPjtWZyPDhH1)obecaJgNkUGO95bV)umGI(UXs(o4G)r1mgaHOqd9XfipihEgqDstMGNXs7ocR)DcieagnovCbr7ZdE)Pyaf9DJLCO0e4G)rHckO89((n51iKFV2mdpZROjOCXRXmP1lDcA89cH5fUbn(uVyyEjT3lGXfVGGKNcZaErWT47fcZRraJEVIk49NIb8Q14zKv8Y8cJaa8cMGAcdLEnIGR0lgMxAGi8kGiaWEfFXllrs7PErWT47fcZlP9EnIXn6EfvW7pfd4fdZlP9ErF3yjlJ9cJf3kEn24EHdURj8cGY4tv(ElimuYvCwgd(umA8LghmeWWZMKeuU0adBqeIbEkkUGO95bV)umG6PrcoCZacbGrJZj9wqAssGHP4e04prytiOXNQiG0e6JlqEqo8mG6KMmbpJL2Dew)7eqiamACQWy0pp49NIbu03nwY3bh8pQMXaiefAOpUa5b5WZaQtAYe8mwA3ry9VtaHaWOXPcJr)8G3FkgqrF3yjhknbo4FuO2nkJQzOXPrOnn9uMC1dTOjcBkTFEW7pfdWvul3IVbrckO0QfACu4G7Ag6JlqEqo8mG6KMmbpJL2Dew)qTtaHaWOXPcJr)8G3FkgqrF3yjFhCW)OAgdGquOHghfo4UMH(4cKhKdpdOoPjtWZyPDhH1pu7eqiamACQWy0pp49NIbu03nwYHstGd(hfkO2f6JlqEqo8mG6KMmbpJL2Dew)7eqiamACQWy0pp49NIbu03nwY3bh8pQMXaiefAOpUa5b5WZaQtAYe8mwA3ry9VtaHaWOXPcJr)8G3FkgqrF3yjhknbo4FuOGckFVV3ccdLCfNLXGpfJgFPXbdbyXTsYY4jjcinWWgqsGHP4e04prytiOXNQiG47TGWqjxXzzm4tXOXxACWqadpBssq5sdmSbbecaJgNt6TG0mcXapfv34YPte2uA)8G3FkC1tJeCyFVVFtEPdyXTcqdVIT(9kYhogbvdVijWW8sqE1IGCmcaqdVijWW8IJ63R3HGgF6H9AeqrCXl9wuyl3RXmP1lCTXLt9cH5L0EVIk49Ncx57TGWqjxXzzm4tXOXxACWqSWXiOA0adBGyGNIIfogbvd1tJeC4MraD3oGluuhFro83mGqay04ubm8SjjbLlk67gl57oyuOAcDeIbEkkUGO95bV)umG6PrcoSwTCbr7ZdE)PyafmACcLV33BbHHsUIZYyWNIrJV04GHagE2KKGYLgyydcieagnoN0BbPzO1OXNJpXapf1dTOjcBkTFEW7pfU6PrcoSV33VjV0bS4wbOHxWhyA4fbNLXEf5dhJGQHxVdbn(0d71iGI4Ix6TOWwUxcYR3HGgFQxs77EnMjTEHRnUCQximVK27vubV)u4EjiKY3BbHHsUIZYyWNIrJV04GHWOiUm5TOW2gyyded8uuSWXiOAOEAKGd3KKadtXchJGQHIastscmmflCmcQgk67gl57IJchnhhG1mjbgMIfogbvdfxSWwFVV3ccdLCfNLXGpfJgFPXbdbm8SjjbLlnWWgeqiamACoP3cIV33VjVgXOmYkEzHad(PyaGgErWVx6e047fcZlCdA8PEnMjTEncaw)EP3IcB9cMGYYyV4SmgCVeJgFr57TGWqjxXzzm4tXOXxACWqyaR)jVff22qqJa4tXOXx4dWPbg2a6XON3AKG3mcscmmfNGg)jcBcbn(ufbeFVfegk5kolJbFkgn(sJdgsqY7ZUXLt1Obg2aXapfLGK3NDJlNQH6PrcoCtOjjWWu0ZrPLHpfK8UI(UXs(U4UwTqtsGHPONJsldFki5Df9DJL8DHMKadtz8WtyldxbtqnHHYgdieagnovgp8e2YWv03nwYHQzaHaWOXPY4HNWwgUI(UXs(U4GFOGY377TGWqjxXzzm4tXOXxACWqyuexM8wuyBdmSbIbEkkw4yeunupnsWHBssGHPyHJrq1qraPj0Keyykw4yeunu03nwY3noaR5rQzscmmflCmcQgkUyHTA1ssGHP4cI23(d5ufbeTAJqmWtr1nUC6eHnL2pp49Ncx90ibhgkFVfegk5kolJbFkgn(sJdgk0ASCcyXTsYY4gyydijWWuYdckzHP0sKWNQiG0mcscmmfxq0(2FiNQiG0Kd5aWumA8fUk0ASCcyXTsYYy8HJV3ccdLCfNLXGpfJgFPXbdbyXTsYY4jjci(ElimuYvCwgd(umA8LghmegW6FYBrHTn0r4XY4b40qqJa4tXOXx4dWPbg2a6XON3AKG77TGWqjxXzzm4tXOXxACWqyaR)jVff22qhHhlJhGtdmSbDeEV)uuWmUyz44d399BYRrafXfV0BrHTEX4EHiOE1r49(tXlmgaCQY3BbHHsUIZYyWNIrJV04GHWOiUm5TOW2g6i8yz8aCw64DkNHY1grAuC28rJCJU5kCW9OS0hB0KLX8LEKVdbrLd71i9YccdLEbyCHR89lDaJl81WlDolJbFkgn(YA41g4SgEP)0ibhEf9spqzYPmBPdTxr4LWcBzzSxA16LyGNIIliAFEW7pfdOEAKGd7vtVcieagnovCbr7ZdE)Pyaf9DJLCV21Ri5LM9koa7LwTEbJefgW6FYBrHTk67gl5ET7aVIdWEPvRxIbEkkJhEcBz4QNgj4WE10lyKOWaw)tElkSvrF3yj3RD9cAVcieagnovgp8e2YWv03nwY9QrVijWWugp8e2YWvWeutyO0lO8QPxbecaJgNkJhEcBz4k67gl5ETRxJ0RMEbTxr4LyGNIIliAFEW7pfdOEAKGd7LwTEjg4PO4cI2Nh8(tXaQNgj4WE10lUGO95bV)umGcgno9ckVGYRMEbTxKeyyQXSeEgtWffxSWwV21lCgPxA16LPPNYKRyX5re8jeK8uygqrTCRx4BGxrYlTA9IKadtbm8SjNGgFfbeV0Q1Ri8IKadtrcqiyabxueq8ckVA6veErsGHP4e04prytiOXNQiGS0TGWq5shdy9p5TOW2LS2isRHx6pnsWHxrV0duMCkZw6IbEkkJhEcBz4QNgj4WE10RacbGrJtfWWZMKeuUOOVBSK7f(8AuVA6f0EXfeTpp49NIbuWOXPxA16veEjg4PO4cI2Nh8(tXaQNgj4WEbLxn9cAVIWlXapfflCmcQgQNgj4WEPvRxr4fjbgMIfogbvdfbeVA6veEfqiamACQyHJrq1qraXlOw6wqyOCPB8WtyldFjRnIYA4L(tJeC4v0l9aLjNYSLUyGNI6G3FkgyscmUOEAKGd7vtVG2lXapfv34YPte2uA)8G3FkC1tJeCyVA6fjbgMQBC50jcBkTFEW7pfUIaIxn9QBhWfkQ71UEH7J6LwTEfHxIbEkQUXLtNiSP0(5bV)u4QNgj4WEbLxn9cAVIWlO9IliAFEW7pfdOiG4vtVed8uuCbr7ZdE)Pya1tJeCyVGYlTA9Y00tzYvPjeudmBnAhLAOOwU1RbEffVA6fjbgMAmlHNXeCrXflS1RD9cNr6fulDlimuU0p49NIbMKaJllzTXixdV0FAKGdVIEPhOm5uMT0fd8uuCbr7B)HCQ6PrcoSxn9cAVOgdEE8EkkdgMRciIu8AxVIIxA16f1yWZJ3trzWWCfl9cFEH)r9ckVA6f0EfHxIbEkkobn(te2ecA8PQNgj4WEPvRxKeyykobn(te2ecA8PkciEPvRxD7aUqrDVW3aVg5i9cQLUfegkx6Cbr7B)HC6swBG)1Wl9Ngj4WROx6bktoLzlDXapffGPjjyWZUf3TPGK3vpnsWH9QPxq7f1yWZJ3trzWWCvarKIx76vu8sRwVOgdEE8EkkdgMRyPx4Zl8pQxqT0TGWq5shW0Kem4z3I72uqY7lzTbUVgEP)0ibhEf9spqzYPmBPtsGHP4cI23(d5ufbeVA6fhYbGPy04lCvO1y5eWIBLKLXETRx4Uxn9cAVmn9uMCfWWZM8wuyRIA5wV0SxKeyykGHNn5TOWwfxSWwVGYRD9kk4Uxn9cAVijWWuDJlNorytP9ZdE)PWveq8QPxr4LyGNIItqJ)eHnHGgFQ6PrcoSxA16fjbgMItqJ)eHnHGgFQIaIxqT0TGWq5shWIBLKLXtseqwYAJi3A4L(tJeC4v0l9aLjNYSLEeErsGHP4e04prytiOXNQiG4vtVed8uuDJlNorytP9ZdE)PWvpnsWH9QPxq7fjbgMQBC50jcBkTFEW7pfUIaIxA16vaHaWOXPcy4ztsckxu03nwY9cFEnQxn9QBhWfkQ7f(g41MhjVA0ROmQxA2lXapfvWaGP0(P0sKWNQEAKGd7LwTEbTxMMEktUcy4ztElkSvrTCRxA2lscmmfWWZM8wuyRIlwyRx76vuWDVGYRMErsGHP4cI23(d5ufbeVA6vaHaWOXPcy4ztsckxu03nwY9A3bEfhG9ckV0Q1Ri8smWtr1nUC6eHnL2pp49Ncx90ibh2RMEfHxq7LPPNYKRyX5re8jeK8uygqrTCRx4ZRi5vtVijWWugp8e2YWveq8ckVA6f0ErsGHP4cI23(d5ufbeV0Q1RUDaxOOUx4BGxB(OE1OxrzuV0SxIbEkQGbatP9tPLiHpv90ibh2lTA9kcVG2lUGO95bV)umGIaIxn9smWtrXfeTpp49NIbupnsWH9ckVA61XfipihEgqDstMGNXsRx74LW63RD8kGqay04uXfeTpp49NIbu03nwY9AhVWb)J6LM9cdGquVG2lO964cKhKdpdOoPjtWZyP1RD8sy971oEfqiamACQ4cI2Nh8(tXak67gl5EbLxAcVWb)J6fuEHVbEfLr9sZEbTx44vJEbTxMMEktU6Hw0eHnL2pp49NIb4kQLB9cFd8ksEbLxq5fulDlimuU0VrL2jVff2UK1g42RHx6pnsWHxrV0duMCkZw6IbEkkobn(te2ecA8PQNgj4WE10Ri8IKadtXjOXFIWMqqJpvraXRMEfqiamACQagE2KKGYff9DJLCV2DGxXbyVA6f0EfHxIbEkkUGO95bV)umG6PrcoSxn9kcVG2lmg9ZdE)PyafbeVGYlTA9smWtrXfeTpp49NIbupnsWH9QPxr4f0EXfeTpp49NIbueq8ckVGAPBbHHYL(nQ0o5TOW2LS2yZxdV0FAKGdVIEPhOm5uMT05cI2Nh8(tXakciE10lXapffxq0(8G3Fkgq90ibh2RMEbTxMMEktUIfNhrWNqqYtHzaf1YTETRxrYlTA9kcVijWWuadpBYjOXxraXRMErsGHPibiemGGlkciEb1s3ccdLlDalUvswgpjrazjRnWz01Wl9Ngj4WROx6bktoLzlDXapfflCmcQgQNgj4WE10lXapfv34YPte2uA)8G3FkC1tJeCyVA6fjbgMIfogbvdfbeVA6fjbgMQBC50jcBkTFEW7pfUIaYs3ccdLlDmkIltElkSDjRnWbN1Wl9Ngj4WROx6bktoLzlDscmmLXdpHTmCfbKLUfegkx6adpBssq5YswBGtKwdV0FAKGdVIEPhOm5uMT0PhJEERrcUxn9YccdVpF(o7CVWNx44vtVijWWuCcA8NiSje04tveqw6wqyOCPJbS(N8wuy7swBGtuwdV0FAKGdVIEPhOm5uMT0fd8uuCbr7ZdE)Pya1tJeCyVA6vaHaWOX5KEliE10lscmmfNGg)jcBcbn(ufbeVA6f0EDCbYdYHNbuN0Kj4zS061oEjS(9AhVcieagnovCbr7ZdE)Pyaf9DJLCV2XlCW)OEPzVWaie1lO9cAVoUa5b5WZaQtAYe8mwA9AhVew)ETJxbecaJgNkUGO95bV)umGI(UXsUxq5LMWlCW)OEbLx76vug1ln7f0EHJxn6f0EzA6Pm5QhArte2uA)8G3FkgGROwU1l8nWRi5fuEbLxA16f0EHJchC3ln7f0EDCbYdYHNbuN0Kj4zS061oEjS(9ckV2XRacbGrJtfxq0(8G3FkgqrF3yj3RD8ch8pQxA2lmacr9cAVG2lCu4G7EPzVG2RJlqEqo8mG6KMmbpJLwV2XlH1Vxq51oEfqiamACQ4cI2Nh8(tXak67gl5EbLxAcVWb)J6fuEbLx76f0EDCbYdYHNbuN0Kj4zS061oEjS(9AhVcieagnovCbr7ZdE)Pyaf9DJLCV2XlCW)OEPzVWaie1lO9cAVoUa5b5WZaQtAYe8mwA9AhVew)ETJxbecaJgNkUGO95bV)umGI(UXsUxq5LMWlCW)OEbLxq5fulDlimuU0bgE2KKGYLLS2aNrUgEP)0ibhEf9spqzYPmBPhHxIbEkkUGO95bV)umG6PrcoSxn9kGqay04CsVfeVA6fjbgMItqJ)eHnHGgFQIaIxn9cAVoUa5b5WZaQtAYe8mwA9AhVew)ETJxbecaJgNkmg9ZdE)Pyaf9DJLCV2XlCW)OEPzVWaie1lO9cAVoUa5b5WZaQtAYe8mwA9AhVew)ETJxbecaJgNkmg9ZdE)Pyaf9DJLCVGYlnHx4G)r9ckV21ROmQxA2lO9chVA0lO9Y00tzYvp0IMiSP0(5bV)umaxrTCRx4BGxrYlO8ckV0Q1lO9chfo4UxA2lO964cKhKdpdOoPjtWZyP1RD8sy97fuETJxbecaJgNkmg9ZdE)Pyaf9DJLCV2XlCW)OEPzVWaie1lO9cAVWrHdU7LM9cAVoUa5b5WZaQtAYe8mwA9AhVew)EbLx74vaHaWOXPcJr)8G3FkgqrF3yj3lO8st4fo4FuVGYlO8AxVG2RJlqEqo8mG6KMmbpJLwV2XlH1Vx74vaHaWOXPcJr)8G3FkgqrF3yj3RD8ch8pQxA2lmacr9cAVG2RJlqEqo8mG6KMmbpJLwV2XlH1Vx74vaHaWOXPcJr)8G3FkgqrF3yj3lO8st4fo4FuVGYlO8cQLUfegkx6adpBssq5YswBGd(xdV0FAKGdVIEPhOm5uMT0jjWWuCcA8NiSje04tveqw6wqyOCPdyXTsYY4jjcilzTbo4(A4L(tJeC4v0l9aLjNYSLEaHaWOX5KEliE10Ri8smWtr1nUC6eHnL2pp49Ncx90ibhEPBbHHYLoWWZMKeuUSK1g4e5wdV0FAKGdVIEPhOm5uMT0fd8uuSWXiOAOEAKGd7vtVIWlO9QBhWfkQ7f(8kYHFVA6vaHaWOXPcy4ztsckxu03nwY9A3bEnQxq5vtVG2Ri8smWtrXfeTpp49NIbupnsWH9sRwV4cI2Nh8(tXaky040lOw6wqyOCPZchJGQXswBGdU9A4L(tJeC4v0l9aLjNYSLEaHaWOX5KEliE10RqRrJp3l85LyGNI6Hw0eHnL2pp49Ncx90ibhEPBbHHYLoWWZMKeuUSK1g4S5RHx6pnsWHxrV0duMCkZw6IbEkkw4yeunupnsWH9QPxKeyykw4yeunueq8QPxKeyykw4yeunu03nwY9AxVWrHJxA2R4aSxA2lscmmflCmcQgkUyHTlDlimuU0XOiUm5TOW2LS2isJUgEP)0ibhEf9spqzYPmBPhqiamACoP3cYs3ccdLlDGHNnjjOCzjRnIeoRHx6pnsWHxrV0duMCkZw60JrpV1ib3RMEfHxKeyykobn(te2ecA8PkcilDlimuU0Xaw)tElkSDjRnIuKwdV0FAKGdVIEPhOm5uMT0fd8uucsEF2nUCQgQNgj4WE10lO9IKadtrphLwg(uqY7k67gl5ETRx4UxA16f0ErsGHPONJsldFki5Df9DJLCV21lO9IKadtz8WtyldxbtqnHHsVA0RacbGrJtLXdpHTmCf9DJLCVGYRMEfqiamACQmE4jSLHROVBSK71UEHd(9ckVGAPBbHHYLUGK3NDJlNQXswBePOSgEP)0ibhEf9spqzYPmBPlg4POyHJrq1q90ibh2RMErsGHPyHJrq1qraXRMEbTxKeyykw4yeunu03nwY9AxVIdWEPzVgPxA2lscmmflCmcQgkUyHTEPvRxKeyykUGO9T)qovraXlTA9kcVed8uuDJlNorytP9ZdE)PWvpnsWH9cQLUfegkx6yuexM8wuy7swBePrUgEPBbHHYLoGf3kjlJNKiGS0FAKGdVIEjRnIe(xdV07i8yz8shNL(tJeC4v0l9aLjNYSLo9y0ZBnsWx6wqyOCPJbS(N8wuy7swBejCFn8sVJWJLXlDCw6pnsWHxrV0duMCkZw6DeEV)uuWmUyz4EHpVW9LUfegkx6yaR)jVff2UK1grkYTgEP3r4XY4LoolDlimuU0XOiUm5TOW2L(tJeC4v0lzjlDd91WRnWzn8s)Prco8k6LEGYKtz2sxmWtrXfeTV9hYPQNgj4WlDlimuU05cI23(d50LS2isRHx6pnsWHxrV0duMCkZw60JrpV1ib3RMEbTxCihaMIrJVWvHwJLtalUvswg71UEbTx43RD8kcVed8uucsEF2nUCQgQNgj4WEbLxA16veEjg4PO4cI2Nh8(tXaQNgj4WE10lO9kGqay04uHXOFEW7pfdOOVBSK7f(8cAVWjsJ6vJEHZi9sZEXHCay2AC5EbLxA16vaHaWOXPcJr)8G3FkgqrF3yj3RD9cAVI0i9AhVWzKEPzV4qoamBnUCVGYlO8ckVA6f0EfHxIbEkkUGO95bV)umG6PrcoSxA16fxq0(8G3FkgqbJgNEPvRxCihaMIrJVWvHwJLtalUvswg71aVIIxn9IKadtnMLWZycUO4If261UEHZi9cQLUfegkx6yaR)jVff2U0dAeaFkgn(cFTbolzTruwdV0FAKGdVIEPhOm5uMT0fd8uugp8e2YWvpnsWH9QPxq7LyGNIIliAFEW7pfdOEAKGd7vtV4cI2Nh8(tXaky040RMEfqiamACQ4cI2Nh8(tXak67gl5EHpVWb)EPvRxr4LyGNIIliAFEW7pfdOEAKGd7fuE10lO9kcVed8uuSWXiOAOEAKGd7LwTEfHxKeyykw4yeunueq8QPxr4vaHaWOXPIfogbvdfbeVGAPBbHHYLUXdpHTm8LS2yKRHx6pnsWHxrV0duMCkZw6IbEkkattsWGNDlUBtbjVREAKGdV0TGWq5shW0Kem4z3I72uqY7lzTb(xdV0FAKGdVIEPhOm5uMT0JWlXapfv34YPte2uA)8G3FkC1tJeCyV0Q1lscmmfxq0(2FiNQiG4LwTE1Td4cf19cFd8cAVWz0r9AhVgPxA2loKdatXOXx4QqRXYjGf3kjlJ9ckV0Q1lscmmv34YPte2uA)8G3FkCfbeV0Q1loKdatXOXx4QqRXYjGf3kjlJ9cFEfLLUfegkx63OsRMKW2(LS2a3xdV0FAKGdVIEPhOm5uMT0jjWWuCbr7B)HCQI(UXsUx76vu8sZEfhG9sZErsGHP4cI23(d5ufxSW2LUfegkx6HwJLtalUvswgVK1grU1Wl9Ngj4WROx6bktoLzlDscmmfWWZMCcA8veq8QPxCihaMIrJVWvHwJLtalUvswg71UEnsVA6f0EfHxIbEkkUGO95bV)umG6PrcoSxA16fxq0(8G3FkgqbJgNEbLxn9cgjkmG1)K3IcBvclSLLXlDlimuU0bgE2KKGYLLS2a3En8s)Prco8k6LEGYKtz2sNd5aWumA8fUk0ASCcyXTsYYyV21Rr6vtVIWlscmmLXdpHTmCfbKLUfegkx6SWXiOASK1gB(A4L(tJeC4v0l9aLjNYSLohYbGPy04lCvO1y5eWIBLKLXETRxJ0RMErsGHPyHJrq1qraXRMEfHxKeyykJhEcBz4kcilDlimuU0XOiUm5TOW2LS2aNrxdV0FAKGdVIEPhOm5uMT0fd8uuh8(tXatsGXf1tJeCyVA6fhYbGPy04lCvO1y5eWIBLKLXETRxJ0RMEbTxr4LyGNIIliAFEW7pfdOEAKGd7LwTEXfeTpp49NIbuWOXPxqT0TGWq5s)G3FkgyscmUSK1g4GZA4L(tJeC4v0l9aLjNYSLUyGNIY4HNWwgU6Prco8s3ccdLlDGHNnjV1xYAdCI0A4LUfegkx6HwJLtalUvswgV0FAKGdVIEjRnWjkRHx6DeESmEPJZs)Prco8k6LEGYKtz2sxmWtrz8Wtyldx90ibhEPBbHHYLoWWZMKeuUSK1g4mY1Wl9ocpwgV0XzP)0ibhEf9spqzYPmBPtpg98wJe8LUfegkx6yaR)jVff2UK1g4G)1Wl9ocpwgV0XzPBbHHYLogfXLjVff2U0FAKGdVIEjlzPdFmJaiRHxBGZA4L(tJeC4f5spqzYPmBPBA6Pm5kldNludmPNJsldx90ibhEPBbHHYLojaHGbeCzjRnI0A4L(tJeC4v0l9aLjNYSL(XfipihEgqDstMGNXsRx74LW63RD9kkJ6LwTEHXOFEW7pfdOiG4LwTEXfeTpp49NIbueqw6wqyOCPdbjmuUK1grzn8s3ccdLl9XSeEYBVrx6pnsWHxrVK1gJCn8s)Prco8k6LEGYKtz2sxmWtrji59z34YPAOEAKGd7vtVijWWu0ZrPLHpfK8UI(UXsUx76vKw6wqyOCPli59z34YPASK1g4Fn8s)Prco8k6LEGYKtz2spcVed8uuCbr7ZdE)Pya1tJeC4LUfegkx6ym6Nh8(tXalzTbUVgEP)0ibhEf9spqzYPmBPlg4PO4cI2Nh8(tXaQNgj4WE10lO9kcVed8uuSWXiOAOEAKGd7LwTEfHxKeyykw4yeunueq8QPxr4vaHaWOXPIfogbvdfbeVGYRMEbTxr4LyGNIY4HNWwgU6PrcoSxA16veEfqiamACQmE4jSLHRiG4fulDlimuU05cI2Nh8(tXalzTrKBn8s)Prco8k6LEGYKtz2spcVed8uuqOSUbMh8(tXamUOEAKGd7LwTEjg4POGqzDdmp49NIbyCr90ibh2RMEbTxym6Nh8(tXaky040RMEfHxIbEkkUGO95bV)umG6PrcoSxA16fxq0(8G3FkgqbJgNE10lXapffxq0(8G3Fkgq90ibh2lOw6wqyOCPFJkTZdE)PyGLS2a3En8s3ccdLlDc(Nm5D(s)Prco8k6LS2yZxdV0TGWq5spGYWtHAYHNyaR)L(tJeC4v0lzTboJUgEPBbHHYLojaHGNiSP0(5Z31yP)0ibhEf9swBGdoRHx6wqyOCPhtyuyMLte2000trs7s)Prco8k6LS2aNiTgEPBbHHYLogkqWp8000tzYNK36l9Ngj4WROxYAdCIYA4LUfegkx6qiOmmnyz8KeyCzP)0ibhEf9swBGZixdV0TGWq5sxA)Kijrej8edrdFP)0ibhEf9swBGd(xdV0TGWq5sV)oIQXeHnbebg8eMERZx6pnsWHxrVK1g4G7RHx6wqyOCPtzqGa(KLtoel8L(tJeC4v0lzTborU1WlDlimuU0hJOay8olN0ZrPLHV0FAKGdVIEjRnWb3En8s)Prco8k6LEGYKtz2spcVed8uugp8e2YWvpnsWH9sRwVijWWugp8e2YWveq8sRwVcieagnovgp8e2YWv03nwY9cFEH)rx6wqyOCPtcqi4jgbvJLS2aNnFn8s)Prco8k6LEGYKtz2spcVed8uugp8e2YWvpnsWH9sRwVijWWugp8e2YWveqw6wqyOCPtEk)0TSmEjRnI0ORHx6pnsWHxrV0duMCkZw6r4LyGNIY4HNWwgU6PrcoSxA16fjbgMY4HNWwgUIaIxA16vaHaWOXPY4HNWwgUI(UXsUx4Zl8p6s3ccdLlDmg9KaecEjRnIeoRHx6pnsWHxrV0duMCkZw6r4LyGNIY4HNWwgU6PrcoSxA16fjbgMY4HNWwgUIaIxA16vaHaWOXPY4HNWwgUI(UXsUx4Zl8p6s3ccdLlDldNludmdgaSK1grksRHx6pnsWHxrV0duMCkZw6Cbr7ZdE)PyafbeVA6fjbgMkyaWeWIBLKLXk67gl5EHVbEHBV0TGWq5s)A8jcBkTFYfeTVK1grkkRHx6wqyOCP3VCeDP)0ibhEf9swBePrUgEP)0ibhEf9s3ccdLlDkroTGWq5eW4YspqzYPmBPBbHH3NpFNDUx4Zl87vtVG2loKdatXOXx4QqRXYjGf3kjlJ9cFEHFV0Q1loKdatXOXx4kGHNnjV19cFEHFVGAPdyCzMw)lDd9LS2is4Fn8s)Prco8k6LUfegkx6uICAbHHYjGXLLoGXLzA9V05Smg8Py04llzjlDi0hqDstwdV2aN1Wl9Ngj4WROxYAJiTgEP)0ibhEf9swBeL1Wl9Ngj4WROxYAJrUgEP)0ibhEf9swBG)1WlDlimuU0fK8(SBC5unw6pnsWHxrVK1g4(A4L(tJeC4v0l9aLjNYSLUyGNIIliAF7pKtvpnsWH9QPxq7f1yWZJ3trzWWCvarKIx76vu8sRwVOgdEE8EkkdgMRyPx4Zl8pQxqT0TGWq5sNliAF7pKtxYAJi3A4L(tJeC4v0l9aLjNYSLEeEjg4PO4cI2Nh8(tXaQNgj4WlDlimuU0Xy0pp49NIbwYAdC71Wl9Ngj4WROx6bktoLzlDXapffxq0(8G3Fkgq90ibhEPBbHHYLoxq0(8G3FkgyjRn281WlDlimuU0HGegkx6pnsWHxrVK1g4m6A4L(tJeC4v0l9aLjNYSLUyGNI6G3FkgyscmUOEAKGdV0TGWq5s)G3FkgyscmUSK1g4GZA4L(tJeC4v0l9aLjNYSLEeEjg4POo49NIbMKaJlQNgj4WlDlimuU0bgE2KKGYLLS2aNiTgEP)0ibhEf9spqzYPmBPlg4POo49NIbMKaJlQNgj4WlDlimuU0p49NIbMKaJllzTborzn8s)Prco8k6LEGYKtz2spcVed8uuCbr7B)HCQ6PrcoSxn9Id5aWumA8fUx4ZlO9ksJ6vJEzA6Pm5kwCEebFcbjpfMbuul36f(8AuVGAPBbHHYLEO1y5eWIBLKLXlzjlzPBeslIU01FGEXlCZrqaFjlzTa]] )

    spec:RegisterOptions( {
        enabled = true,

        aoe = 3,

        nameplates = false,
        nameplateRange = 8,

        damage = true,
        damageExpiration = 6,

        potion = "battle_potion_of_intellect",

        package = "Elemental",
    } )
end
