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
    spec:RegisterPack( "Elemental", 20190625.0950, [[de1c1bqiHOhjLkxIuiTjPKpjesJcK6uqfRIuWRuaZskLBPq1Ui5xkqdtH4yGKLbvYZesAAsPQRjeSnsH6BKcHXbvv05uQqRdQu07ifIW8uQ09uq7dQk)tPcQ6Gkvelui1dvQinrHq1ffsSrOQcFeQuOrQubvoPsfyLkv9ssHOMPsf1nHkL2PcPFQubzOqvLwkuPGNsQMQcLRkekFvPckJLuisNLuiI2Rs(RIgSOdtzXi1JfmzOCzvBguFwOgTuCAuETsXSbUTuTBj)gYWbXXfcXYr8CunDIRJKTdv57kLgpuP68KIwpuv18jL2pvVGAn2shZKVgfxJa1ooIgJRiOgzhJauJSJlDrtiFPdXcBS4V0lR)LEuaV)smWshIPjazyRXw6Cefj8LEJiq44MdoymtAOOvbuFqoRtbmHHQaXGLb5SEyWLonfdi7GArV0Xm5RrX1iqTJJOX4kcQr2Xia1sNd5H1O4sJX1sVHHH9ArV0XopS0BNNrb8(lXaEQ3yDR89TZZgrGWXnhCWyM0qrRcO(GCwNcycdvbIbldYz9WG((255EQ6EIRi0MN4AeO2rph3Zr2rCZ2hbFVVVDEUtBSk(CCtFF78CCpJy87PgPZdE)LyaffepjM0CINsJvEgAEydRI9mGqam02I7PG8K)7jd2ZdE)LyaUNg5EAbHH3v((2554EgXzCJgCmpJIrKgpJc49xIb88LqyNR89TZZX9e3W7i8UN7eE4fMvH7PW6FWO3zpdnpSr57BNNJ75obdZZOO59eb7P0Cp1feP75GEIBVCerT0HqqWmWx6TZZOaE)Lyap1BSUv((25zJiq44MdoymtAOOvbuFqoRtbmHHQaXGLb5SEyqFF78CpvDpXveAZtCncu7ONJ75i7iUz7JGV333op3PnwfFoUPVVDEoUNrm(9uJ05bV)smGIcINetAoXtPXkpdnpSHvXEgqiagABX9uqEY)9Kb75bV)sma3tJCpTGWW7kFF78CCpJ4mUrdoMNrXisJNrb8(lXaE(siSZv((2554EIB4DeE3ZDcp8cZQW9uy9py07SNHMh2O89TZZX9CNGH5zu08EIG9uAUN6cI09CqpXTxoIO89((25zuW9hOKJ5j9HrK7za1PnXt6hZkUYZDsiCic3ZcvJ3yKomfWtlimuX9evanv(ElimuXvqipG60Mmegy8n(ElimuXvqipG60MmWWbHrimFVfegQ4kiKhqDAtgy4GgvC)Lycdv(EFF78uVmi8gK4jXyyEstbdFmp5IjCpPpmICpdOoTjEs)ywX90kmpHq(4qqIWQypzCpXq1v(ElimuXvqipG60MmWWb5LbH3GKjxmH77TGWqfxbH8aQtBYadhuqY7ZUXLt0033opTGWqfxbH8aQtBYadh8grAMh8(lXaTXGhgPyGxIccH1nW8G3FjgGXf1lJgCmFVVVDEgX43tDbr6B(HCINqipG60M4jvboN7jh1VNggg3ZTmaWtoeBB5jhHkLV3ccdvCfeYdOoTjdmCqUGi9n)qoPng8qXaVefxqK(MFiNOEz0GJ1cAIXWMhVxIYWW4QaIQKDJQwTeJHnpEVeLHHXvScFryeC89(ElimuXvqipG60MmWWbHzKpp49xIbAJbpmsXaVefxqK(8G3Fjgq9YObhZ3BbHHkUcc5buN2KbgoixqK(8G3FjgOng8qXaVefxqK(8G3Fjgq9YObhZ3BbHHkUcc5buN2KbgoieKWqLV3ccdvCfeYdOoTjdmCWdE)LyGjnW4sBm4HIbEjQdE)LyGjnW4I6LrdoMV3ccdvCfeYdOoTjdmCqGHNnPPiCPng8Wifd8suh8(lXatAGXf1lJgCSwCihaMIrIVWvHgJvtalUrkwfVBu99wqyOIRGqEa1PnzGHdgAmwnbS4gPyvCBm4HCihaMIrIVWvHgJvtalUrkwfJpC5799TZZOG7pqjhZZJ3jA6PW63tP5EAbbr8KX90WZyaJgCLVVDEUtnU4z0aecdqXfp7wrzaGMEYG9uAUN7e8)eMCphJymXZDsfoxigWtCdNJkRc3tg3tiKZFjkFVfegQ4dPbiegGIlTXGhA4)jm5kRcNledmjNJkRcx9YObhZ377BNN7GA8aQtBINqqcdvEY4EcHC4tEjmda00taR2CmpfKNAIOiEgfW7Ved0MNuf4CUNbuN2ep3YaapFH5jVbreGM(ElimuXhy4GqqcdvTXGhEChYdYXMbuN2Kj4vS0mUW6F3OoIwTWmYNh8(lXakkiA1YfePpp49xIbuuq89((255oOKtiuqeprWEgmUWv(ElimuXhy4GBzf2K3CJ4799wqyOIpWWbfK8(SBC5enBJbpumWlrji59z34YjAQEz0GJ1IMcgwrohvwf(uqY7kY7gR47IlFVfegQ4dmCqyg5ZdE)LyG2yWdJumWlrXfePpp49xIbuVmAWX89wqyOIpWWb5cI0Nh8(lXaTXGhkg4LO4cI0Nh8(lXaQxgn4yTGosXaVeflCykIMQxgn4yA1gjnfmSIfomfrtffKwrgqiagABPyHdtr0urbbNwqhPyGxIY4HxywfU6LrdoMwTrgqiagABPmE4fMvHROGGJVVDEAbHHk(adh8grAMh8(lXaTXGhgPyGxIccH1nW8G3FjgGXf1lJgCmTAfd8suqiSUbMh8(lXamUOEz0GJ1cAyg5ZdE)LyafgAB1ksXaVefxqK(8G3Fjgq9YObhtRwUGi95bV)smGcdTTAjg4LO4cI0Nh8(lXaQxgn4y447TGWqfFGHdsX)KjVZ99wqyOIpWWbdOk8siMCSjmW633BbHHk(adhKgGqyte8uA(817A67TGWqfFGHdgtzemMvte80W)tqsJV3ccdv8bgoimkqXp20W)tyYN036(ElimuXhy4GqOimynzv8KgyCX3BbHHk(adhuA(KQOruf2egrc33BbHHk(adhS)oIO5ebpbubg2eJCRZ99wqyOIpWWbjmiqaFYQjhIfUV3ccdv8bgo4webGH3z1KCoQSkCFVfegQ4dmCqAacHnHPiA2gdEyKIbEjkJhEHzv4Qxgn4yA1stbdRmE4fMvHROGOvBaHayOTLY4HxywfUI8UXko(IWi(ElimuXhy4G0NWpzdRIBJbpmsXaVeLXdVWSkC1lJgCmTAPPGHvgp8cZQWvuq89wqyOIpWWbHzKtdqiS2yWdJumWlrz8WlmRcx9YObhtRwAkyyLXdVWSkCffeTAdieadTTugp8cZQWvK3nwXXxegX3BbHHk(adh0QW5cXaZGbaTXGhgPyGxIY4HxywfU6LrdoMwT0uWWkJhEHzv4kkiA1gqiagABPmE4fMvHRiVBSIJVimIV3ccdv8bgo418te8uA(KlisVng8qUGi95bV)smGIcslAkyyvWaGjGf3ifRIvK3nwXX3q8tFVfegQ4dmCW(LJi(ElimuXhy4GeQAAbHHQjGXL2kR)Hg6TXGhAbHH3NVENDo(WvlO5qoamfJeFHRcngRMawCJuSkgF4sRwoKdatXiXx4kGHNnPV1XhUWX3BbHHk(adhKqvtlimunbmU0wz9pKZQyWNIrIV4799TZtClfqyEkgj(INwqyOYtiegIWen9eW4IV3ccdvCLH(qUGi9n)qoPng8qXaVefxqK(MFiNOEz0GJ5799TZtDiKByEIFaS(9uVbf24jR8C3HE2EpfJeFXtywCJWBZtAkXZcjEIrryvSN6rXtkicR)2OkW5Cp1erfrj3tywCJWQypJQNIrIVW90kmpBm8UNGZ5Eknw5juT3ZDyScZtCJuCXtUyHnCLV3ccdvCLH(adhegy9p5nOWM2cAgaFkgj(cFiuTXGhsom58gJg8wqZHCaykgj(cxfAmwnbS4gPyv8UqhHXJumWlrji59z34YjAQEz0GJHJwTrkg4LO4cI0Nh8(lXaQxgn4yTGgMr(8G3FjgqrE3yfhFqdv71ahYbGzJXLJJwTbecGH2wkyg5ZdE)Lyaf5DJv8DHgxTFCOAVg4qoamBmUCCWbNwqhPyGxIIlisFEW7VedOEz0GJPvlxqK(8G3FjgqHH2wA1YHCaykgj(cxfAmwnbS4gPyv8WO2IMcgwTLvyZykUO4If2SluThhFVfegQ4kd9bgoOXdVWSk82yWdfd8sugp8cZQWvVmAWXAbTyGxIIlisFEW7VedOEz0GJ1IlisFEW7VedOWqBRwbecGH2wkUGi95bV)smGI8UXko(GkcA1gPyGxIIlisFEW7VedOEz0GJHtlOJumWlrXchMIOP6LrdoMwTrstbdRyHdtr0urbPvKbecGH2wkw4WuenvuqWX3BbHHkUYqFGHdcyrekg2SBXDBki592yWdfd8suaweHIHn7wC3McsEx9YObhZ377BNNJr00tb5zS1VNrXisteHY2Cp3YKgpXTgxoXteSNsZ9mkG3FjCpPPGH9CBZlpHzXncRI9mQEkgj(cx5zehvruXteENemiEIBTd4cb1J03BbHHkUYqFGHdEJinrekBZBJbpmsXaVev34Yjte8uA(8G3FjC1lJgCmTAPPGHvCbr6B(HCIIcIwTD7aUqqD8neAOgzKXBVg4qoamfJeFHRcngRMawCJuSkghTAPPGHvDJlNmrWtP5ZdE)LWvuq0QLd5aWums8fUk0ySAcyXnsXQy8fvFVVVDEIBTn3tof5EQjIYtmufrfpbi(908uxqK(MFiNO89wqyOIRm0hy4GHgJvtalUrkwf3gdEinfmSIlisFZpKtuK3nwX3nQAioGPbAkyyfxqK(MFiNO4If24799TZZDOcOPNbJlEUZgEMNrtr4INOYtPH87PyK4lCpzWEYepzCpTYtwXfRepTcZtDbr6EgfW7Ved4jJ75O7qJ5PfegEx57TGWqfxzOpWWbbgE2KMIWL2yWdPPGHvadpBYPiXxrbPfhYbGPyK4lCvOXy1eWIBKIvX72(wqhPyGxIIlisFEW7VedOEz0GJPvlxqK(8G3FjgqHH2w40cdjkyG1)K3GcBuclSHvX(ElimuXvg6dmCqw4WuenBJbpKd5aWums8fUk0ySAcyXnsXQ4DBFRiPPGHvgp8cZQWvuq89wqyOIRm0hy4GWeexM8guytBm4HCihaMIrIVWvHgJvtalUrkwfVB7BrtbdRyHdtr0urbPvK0uWWkJhEHzv4kki(EFF78mIXVNrb8(lXaEgnW4INwSXkU4jfepfKNr1tXiXx4EACpbOk2tJ7PUGiDpJc49xIb8KX9SqINwqy4DLV3ccdvCLH(adh8G3FjgysdmU0gdEOyGxI6G3FjgysdmUOEz0GJ1Id5aWums8fUk0ySAcyXnsXQ4DBFlOJumWlrXfePpp49xIbuVmAWX0QLlisFEW7VedOWqBlC89wqyOIRm0hy4GadpBsFR3gdEOyGxIY4HxywfU6LrdoMV3ccdvCLH(adhm0ySAcyXnsXQyFVfegQ4kd9bgoiWWZM0ueU0whHhRIhcvBm4HIbEjkJhEHzv4Qxgn4y(ElimuXvg6dmCqyG1)K3GcBARJWJvXdHQTGMbWNIrIVWhcvBm4HKdtoVXOb33BbHHkUYqFGHdctqCzYBqHnT1r4XQ4Hq5799TZtDwfdUNJzK4lEUtccdvEIFjmeHjA65oZ4IVVDEgLItrUN4h6EY4EAbHH39KQaNZ9uteLNngE3tOAVNiINDe5EYflSH7jc2ZDyScZtCJuCXtycQ7PUGiDpJc49xIbuEcDuWIVNbJFCtpPGeqDwf75oHh8KMs80ccdV7PEu0iHNyOkIkEIJV3ccdvCfNvXGpfJeFzimW6FYBqHnTf0ma(ums8f(qOAJbpe6ifwydRI1QvmWlrXfePpp49xIbuVmAWXAfqiagABP4cI0Nh8(lXakY7gR47IlnehW0QfdjkyG1)K3GcBuK3nwX3DyCatRwXaVeLXdVWSkC1lJgCSwyirbdS(N8guyJI8UXk(UqhqiagABPmE4fMvHRiVBSIpanfmSY4HxywfUcJIycdv40kGqam02sz8WlmRcxrE3yfF323c6ifd8suCbr6ZdE)Lya1lJgCmTAfd8suCbr6ZdE)Lya1lJgCSwbecGH2wkUGi95bV)smGI8UXk(UqHRrWbNwqttbdR2YkSzmfxuCXcB2fQ2RvRH)NWKRyX1ru8jeK8sygqrSAd(gIlTAPPGHvadpBYPiXxrbrR2iPPGHv0aecdqXfffeCAfjnfmSItrI)ebpHG2EIIcIV333opJy875oHhEHzv4EAWYjEQjIkII39Kd5L4PbaEUZgEMNrtr4INHgJeFUNwH5jQaA6jd2Z6mP5ep1feP7zuaV)smGNfI45oiCykIMEAK7zGIqEjan90ccdVR89wqyOIR4Skg8PyK4ldmCqJhEHzv4TXGhkg4LOmE4fMvHREz0GJ1kGqam02sbm8SjnfHlkY7gR44BKwqZfePpp49xIbuyOTLwTrkg4LO4cI0Nh8(lXaQxgn4y40c6ifd8suSWHPiAQEz0GJPvBK0uWWkw4WuenvuqAfzaHayOTLIfomfrtffeC89((25zehvruXtk(9mkG3FjgWZObgx8Kb7PMikpdikaMNbJlEAEIBnUCINiypLM7zuaV)s4E(oe02toMNrXisJN6nOWgpzfxUHP8mIJQiQ4zW4INrb8(lXaEgnW4INyuewf7PUGiDpJc49xIb8KQaNZ9uteLNngE3ZOI7EoQjued45oCgPJknvEgnL4jR8uAyCpdg)EYfeepP4Sk2ZOaE)LyapJgyCXtufUNAIO8KCl04juT3tUyHnCprWEUdJvyEIBKIlkFVfegQ4koRIbFkgj(Yadh8G3FjgysdmU0gdEOyGxI6G3FjgysdmUOEz0GJ1cAXaVev34Yjte8uA(8G3FjC1lJgCSw0uWWQUXLtMi4P085bV)s4kkiT62bCHG67QXJOvBKIbEjQUXLtMi4P085bV)s4Qxgn4y40c6iHMlisFEW7VedOOG0smWlrXfePpp49xIbuVmAWXWrRwd)pHjxvMqrmWSXiDuPPIy1MHrTfnfmSAlRWMXuCrXflSzxOApo(EFF78uJ8pep11i7jmI4jWiX3teXtocvEAyyEU1W7CLNrScCo3tnruE2y4Dp1PiX3teSN4x02tAZtw552gwOXZGXVNAIO8CRvINcYtmefn4Estbd75oZIBKIvXEgnciEsRPNqqiaRI9e3AhWfcQ7j9HrK3yfMYZOG7whc4EYFeH6v44MEc1iJGB1BZZOO3MN6AKBZZDo628CNXl628mk6T55ohTV3ccdvCfNvXGpfJeFzGHdYfePV5hYjTXGhkg4LO4cI038d5e1lJgCSwqtmg2849sugggxfquLSBu1QLymS5X7LOmmmUIv4lcJGtlOJumWlrXPiXFIGNqqBpr9YObhtRwAkyyfNIe)jcEcbT9effeTA72bCHG64By7Bpo(EFVfegQ4koRIbFkgj(YadheWIiumSz3I72uqY7TXGhkg4LOaSicfdB2T4UnfK8U6LrdowlOjgdBE8EjkddJRciQs2nQA1smg2849sugggxXk8fHrWX377BNN7uuNMv3tDbr6B(HCINBzsJN4wJlN4jc2tP5EgfW7VeUNiIN6uK47jc2t8lA7jEsvGZ5EQjIYZgdV7P0Cp3zdpZt9guyJNcXyINwH5zNcimiG7jxSWgUY3BbHHkUIZQyWNIrIVmWWbbS4gPyv8KgbK2yWdPPGHvCbr6B(HCIIcsloKdatXiXx4QqJXQjGf3ifRI3fxTG2W)tyYvadpBYBqHnkIvB0anfmScy4ztEdkSrXflSbNDXLg3cAAkyyv34Yjte8uA(8G3FjCffKwrkg4LO4uK4prWtiOTNOEz0GJPvlnfmSItrI)ebpHG2EIIcco(EFF78mIXVNrXisteHY2CpX7eof3tC5PyK4l828KQaNZ9uteLNngE3ZD2WZ8uVbf2O8mIXVNrXisteHY2CpX7eof3tO8ums8fpzWEQjIYZgdV75ypiOIf8CSgQc7epJQNcRFUNwH55O7qEQtrIVNiypXVOTN45lJgCmpTcZZr3H8CNn8mp1BqHnkFVfegQ4koRIbFkgj(Yadh8grAIiu2M3gdEi0CihaMIrIVWvHgJvtalUrkwfJpO0Q1W)tyYvYdcQyHP0qvyNOiwTbFdJARifd8suCks8Ni4je02tuVmAWXAz4)jm5kGHNn5nOWgfXQn7cfoTm8)eMCfWWZM8guyJIy1gnqtbdRagE2K3GcBuCXcB2f6OQXdevny4)jm5k5bbvSWuAOkStueR2OboKdatXiXx4QqJXQjGf3ifRIXPf0rkg4LO4uK4prWtiOTNOEz0GJPvBKyirbdS(N8guyJICyY5ngn4A1YfePpp49xIbuuqWPf0rkg4LO6gxozIGNsZNh8(lHREz0GJPvlnfmSQBC5KjcEknFEW7VeUIcIwTbecGH2wkGHNnPPiCrrE3yfhFJ0QBhWfcQJVH7iUgiQJObXaVevWaGP08P0qvyNOEz0GJHJV333op3Pgx8mkgrA8uVbf245wM04jU14YjEIG9uAUNrb8(lH7PyGxIN0uINfYtlim8UN6uK47jc2t8lA7jEstbd3MNwH5PfegE3tDbr6B(HCIN0uWWEAfMN7SHN5z0ueU4za1zvSNiyyp3PrCp3YKgw5P0CpRJ7IN4g3Pr8280kmpptAoXtlim8UN4wJlN4jc2tP5EgfW7VeUN0uWWT5jI4zH80WZyaJgCp3zdpZZOPiCXZTnmW9SUr8e3Q7zWG0MNiINCwfdUNIrIV4PvyE2Pacdc4EUZgEMN6nOWgpfIXeUNwH5z3kn9Klwydx57TGWqfxXzvm4tXiXxgy4G3isZK3GcBAJbpmsAkyyfNIe)jcEcbT9effKwIbEjQUXLtMi4P085bV)s4Qxgn4yTGMMcgw1nUCYebpLMpp49xcxrbrR2acbWqBlfWWZM0ueUOiVBSIJVrA1Td4cb1X3WDexde1r0GyGxIkyaWuA(uAOkStuVmAWX0QLd5aWums8fUk0ySAcyXnsXQ4DXvlOn8)eMCfWWZM8guyJIy1gnqtbdRagE2K3GcBuCXcB2fxAmoTOPGHvCbr6B(HCIIcsRacbWqBlfWWZM0ueUOiVBSIV7W4ago(EFF78uJKikp3uOTEUTXKD49Ch4zJH5jh1VN8ger884oeGvMWqLNnNCprv4kpJMs8uAE5P0CpdOcJjmu5zm5BBZtRW8Ch4zJH5PG8KdbWepLM7jQUNrXisJN6nOWgpbS6EYkb5jmIIOukoYtnruE2y4DpfKNy3aEULjnEknmUNgnQZktyOYZcTf30ZDQXfpJIrKgp1BqHnEULjnikXtCRXLt8eb7P0CpJc49xc3tXaVK280kmp3YKgeL4zJHhRI9uimiG75oiUoII7j(fjVeMb80kmpTGWW7EUt4HxywfEBEAfMNwqy4Dp1fePV5hYjEstbd7jI4zDJ4jUv3ZGbPnprep1feP7zuaV)smGNmUNSYccdV3MNwH5527zWQiQ45XDipiEkipJV4PvEAyymHHkd4jf)EIG9uxqKUNrb8(lXaEYkpLM7j5DJvSk2tywCJ4jmb19uNIeFprWEIFrBpr57TGWqfxXzvm4tXiXxgy4G3isZK3GcBAJbpmsXaVev34Yjte8uA(8G3FjC1lJgCSwrcTH)NWKRyX1ru8jeK8sygqrSAd(WvlAkyyLXdVWSkCffeCAbnnfmSIlisFZpKtuuq0QTBhWfcQJVH74ide1r0GyGxIkyaWuA(uAOkStuVmAWX0QnsO5cI0Nh8(lXakkiTed8suCbr6ZdE)Lya1lJgCmCADChYdYXMbuN2Kj4vS0mUW6F8acbWqBlfxqK(8G3FjgqrE3yfFCOIWiAagGqeOH(4oKhKJndOoTjtWRyPzCH1)4becGH2wkUGi95bV)smGI8UXkooAuOIWi4GVHrDenanudaTH)NWKREObnrWtP5ZdE)LyaUIy1g8nex4Gdo(EFF78mIXVNrXisJN6nOWgpzWEQtrIVNiypXVOTN4jJ7PyGxYXAZtAkXZ6mP5epzINfI4P5zeh)Q7zuaV)smGNmUNwqy4DpnXtP5E2r9xsBEAfMN7SHN5z0ueU4jJ7j5gMMEIiEULbaEsFpj3W00ZTmPHvEkn3Z64U4jUXDAex57TGWqfxXzvm4tXiXxgy4G3isZK3GcBAJbpumWlrXPiXFIGNqqBpr9YObhRvK0uWWkofj(te8ecA7jkkiTcieadTTuadpBstr4II8UXk(UdJdyTGosXaVefxqK(8G3Fjgq9YObhRvKWmYNh8(lXakkiA1kg4LO4cI0Nh8(lXaQxgn4yTIKlisFEW7VedOOGGJV333op1HyDp3zwCJuSk2ZOraH7jgfHvXEQlis3ZOaE)LyapXOiMWqvBEYG9uteLNyOkIkE2y4Dp3bX1ruCpXVi5LWmGNiINngE3tM4jQaA6jQcVnpTcZtmufrfpP43ZDMf3ifRI9mAeq8eJIWQypJgGqyakU4jd2tnruE2y4Dpnp3zdpZtDks89e)sqbLV3ccdvCfNvXGpfJeFzGHdcyXnsXQ4jnciTXGhYfePpp49xIbuuqAjg4LO4cI0Nh8(lXaQxgn4yTG2W)tyYvS46ik(ecsEjmdOiwTzxCPvBK0uWWkGHNn5uK4ROG0IMcgwrdqimafxuuqWX377BNN7uJlEUZS4gPyvSNrJaINKhBemW5CprWEkn3tiKJhdrX9mGkmMWqLNmyp1erfrX8eG43tZtDbr6B(HCINCXcB8er8SXW7EQlisFZpKt80kmpXTgxoXteSNsZ9mkG3FjCpTGWW7kFVfegQ4koRIbFkgj(YadbS4gPyv8KgbK2yWdHMMcgwXfePV5hYjkY7gR47cLcknehW0anfmSIlisFZpKtuCXcB0QLMcgwXfePV5hYjkkiTOPGHvDJlNmrWtP5ZdE)LWvuqWX377BNNrm(9e)GG4IN6nOWgp3YKgp3bHdtr00tRW8e3AC5eprWEkn3ZOaE)LWv(ElimuXvCwfd(ums8LbgoimbXLjVbf20gdEOyGxIIfomfrt1lJgCSwIbEjQUXLtMi4P085bV)s4Qxgn4yTOPGHvSWHPiAQOG0IMcgw1nUCYebpLMpp49xcxrbX377TGWqfxXzvm4tXiXxgy4GadpBstr4sBm4H0uWWkJhEHzv4kki(EFF78mIjmad)VN6uK47jc2t8lA7jEkip5qi3W8e)ay97PEdkSXtgSNDkGWGaUNVENDUNg5EcHC(lr57TGWqfxXzvm4tXiXxgy4GWaR)jVbf20wqZa4tXiXx4dHQng8qYHjN3y0G3YccdVpF9o7C8bvlAkyyfNIe)jcEcbT9effeFVVVDEgX43ZD2WZ8mAkcx8CltA8uNIeFprWEIFrBpXtgSNsZ9eyCXtii5LWmGNuCl(EIG908uxqKUNrb8(lXaE2y8kIkEAEctbaEIrrmHHkp3HWn4jd2tnruEgquampJV4PviP5epP4w89eb7P0CpJ44xDpJc49xIb8Kb7P0CpjVBSIvXEcZIBep3ACpHsJ1OEcqv8jkFVfegQ4koRIbFkgj(Yadhey4ztAkcxAJbpumWlrXfePpp49xIbuVmAWXAfqiagABnj3cslAkyyfNIe)jcEcbT9effKwqFChYdYXMbuN2Kj4vS0mUW6F8acbWqBlfxqK(8G3FjgqrE3yfFCOIWiAagGqeOH(4oKhKJndOoTjtWRyPzCH1)4becGH2wkUGi95bV)smGI8UXkooAuOIWi4SBuhrdqd1aqB4)jm5QhAqte8uA(8G3FjgGRiwTbFdXfo4Ovl0qPGsJ1a0h3H8GCSza1PnzcEflnJlS(Xz8acbWqBlfxqK(8G3FjgqrE3yfFCOIWiAagGqeOHgkfuASgG(4oKhKJndOoTjtWRyPzCH1poJhqiagABP4cI0Nh8(lXakY7gR44OrHkcJGdo7c9XDipihBgqDAtMGxXsZ4cR)XdieadTTuCbr6ZdE)Lyaf5DJv8XHkcJObyacrGg6J7qEqo2mG60MmbVILMXfw)JhqiagABP4cI0Nh8(lXakY7gR44OrHkcJGdo44799TZZig)EUZgEMNrtr4INBzsJN6uK47jc2t8lA7jEYG9uAUNaJlEcbjVeMb8KIBX3teSNMN4hmY9mkG3FjgWZgJxruXtZtykaWtmkIjmu55oeUbpzWEQjIYZaIcG5z8fpTcjnN4jf3IVNiypLM7zeh)Q7zuaV)smGNmypLM7j5DJvSk2tywCJ45wJ7juASg1taQIpr57TGWqfxXzvm4tXiXxgy4GadpBstr4sBm4Hrkg4LO4cI0Nh8(lXaQxgn4yTcieadTTMKBbPfnfmSItrI)ebpHG2EIIcslOpUd5b5yZaQtBYe8kwAgxy9pEaHayOTLcMr(8G3FjgqrE3yfFCOIWiAagGqeOH(4oKhKJndOoTjtWRyPzCH1)4becGH2wkyg5ZdE)Lyaf5DJvCC0OqfHrWz3OoIgGgQbG2W)tyYvp0GMi4P085bV)smaxrSAd(gIlCWrRwOHsbLgRbOpUd5b5yZaQtBYe8kwAgxy9JZ4becGH2wkyg5ZdE)Lyaf5DJv8XHkcJObyacrGgAOuqPXAa6J7qEqo2mG60MmbVILMXfw)4mEaHayOTLcMr(8G3FjgqrE3yfhhnkuryeCWzxOpUd5b5yZaQtBYe8kwAgxy9pEaHayOTLcMr(8G3FjgqrE3yfFCOIWiAagGqeOH(4oKhKJndOoTjtWRyPzCH1)4becGH2wkyg5ZdE)Lyaf5DJvCC0OqfHrWbhC89(ElimuXvCwfd(ums8LbgoiGf3ifRIN0iG0gdEinfmSItrI)ebpHG2EIIcIV3ccdvCfNvXGpfJeFzGHdcm8SjnfHlTXGhgqiagABnj3csRifd8suDJlNmrWtP5ZdE)LWvVmAWX89E6PVVDEQdyXncqtpJT(9CheomfrtpPPGH9uqE2GGCykaqtpPPGH9KJ63Z3HG2EYX8e)GG4IN6nOWgUNBzsJN4wJlN4jc2tP5EgfW7VeUY3BbHHkUIZQyWNIrIVmWWbzHdtr0Sng8qXaVeflCykIMQxgn4yTIe6UDaxiOo(0iIqRacbWqBlfWWZM0ueUOiVBSIV7WrWPf0rkg4LO4cI0Nh8(lXaQxgn4yA1YfePpp49xIbuyOTfo(EFVfegQ4koRIbFkgj(Yadhey4ztAkcxAJbpmGqam02AsUfKwHgJeFo(ed8sup0GMi4P085bV)s4Qxgn4y(EFF78uhWIBeGMEIDGPPNuCwf75oiCykIME(oe02toMN4heex8uVbf2W9uqE(oe02t8uAE3ZTmPXtCRXLt8eb7P0CpJc49xc3tbHu(ElimuXvCwfd(ums8LbgoimbXLjVbf20gdEOyGxIIfomfrt1lJgCSw0uWWkw4WuenvuqArtbdRyHdtr0urE3yfFxOuqPH4aMgOPGHvSWHPiAQ4If24799wqyOIR4Skg8PyK4ldmCqGHNnPPiCPng8WacbWqBRj5wq89((25zehvruXtleyyVeda00tk(9uNIeFprWEIFrBpXZTmPXt8dG1VN6nOWgpXOiSk2toRIb3tXiXxu(ElimuXvCwfd(ums8LbgoimW6FYBqHnTf0ma(ums8f(qOAJbpKCyY5ngn4TIKMcgwXPiXFIGNqqBprrbX3BbHHkUIZQyWNIrIVmWWbfK8(SBC5enBJbpumWlrji59z34YjAQEz0GJ1cAAkyyf5Cuzv4tbjVRiVBSIVRgRvl00uWWkY5OYQWNcsExrE3yfFxOPPGHvgp8cZQWvyuetyOAGacbWqBlLXdVWSkCf5DJvCCAfqiagABPmE4fMvHRiVBSIVlurahC89(ElimuXvCwfd(ums8LbgoimbXLjVbf20gdEOyGxIIfomfrt1lJgCSw0uWWkw4WuenvuqAbnnfmSIfomfrtf5DJv8DJdyAO9AGMcgwXchMIOPIlwyJwT0uWWkUGi9n)qorrbrR2ifd8suDJlNmrWtP5ZdE)LWvVmAWXWX3BbHHkUIZQyWNIrIVmWWbdngRMawCJuSkUng8qAkyyL8GGkwyknuf2jkkiTIKMcgwXfePV5hYjkkiT4qoamfJeFHRcngRMawCJuSkgFq57TGWqfxXzvm4tXiXxgy4GawCJuSkEsJaIV3ccdvCfNvXGpfJeFzGHdcdS(N8guytBDeESkEiuTf0ma(ums8f(qOAJbpKCyY5ngn4(ElimuXvCwfd(ums8LbgoimW6FYBqHnT1r4XQ4Hq1gdEyhH37VefgJlwfo(0yFVVVDEIFqqCXt9guyJNmUNikINDeEV)s8eMbaNO89wqyOIR4Skg8PyK4ldmCqycIltEdkSPTocpwfpeQLoENWzOAnkUgbQDCK2pcUuqncuTFPV1ifRI5l9DqhcIihZZ27PfegQ8eW4cx57x6gL0GilDDwNcycdv7uIbllDaJl81ylDoRIbFkgj(YAS1OqTgBP)YObhBf9s3ccdvlDyG1)K3GcBw6bctoHzlDO9mspfwydRI9uRwpfd8suCbr6ZdE)Lya1lJgCmpB5zaHayOTLIlisFEW7VedOiVBSI75UEIlp1GNXbmp1Q1tmKOGbw)tEdkSrrE3yf3ZDh6zCaZtTA9umWlrz8WlmRcx9YObhZZwEIHefmW6FYBqHnkY7gR4EURNq7zaHayOTLY4HxywfUI8UXkUNd4jnfmSY4HxywfUcJIycdvEIJNT8mGqam02sz8WlmRcxrE3yf3ZD9S9E2YtO9mspfd8suCbr6ZdE)Lya1lJgCmp1Q1tXaVefxqK(8G3Fjgq9YObhZZwEgqiagABP4cI0Nh8(lXakY7gR4EURNqHRr8ehpXXZwEcTN0uWWQTScBgtXffxSWgp31tOAVNA16PH)NWKRyX1ru8jeK8sygqrSAJN4BON4YtTA9KMcgwbm8SjNIeFffep1Q1Zi9KMcgwrdqimafxuuq8ehpB5zKEstbdR4uK4prWtiOTNOOGS0dAgaFkgj(cFnkulznkUwJT0Fz0GJTIEPhim5eMT0fd8sugp8cZQWvVmAWX8SLNbecGH2wkGHNnPPiCrrE3yf3t855iE2YtO9KlisFEW7VedOWqBlp1Q1Zi9umWlrXfePpp49xIbuVmAWX8ehpB5j0EgPNIbEjkw4WuenvVmAWX8uRwpJ0tAkyyflCykIMkkiE2YZi9mGqam02sXchMIOPIcIN4S0TGWq1s34Hxywf(swJg11yl9xgn4yROx6bctoHzlDXaVe1bV)smWKgyCr9YObhZZwEcTNIbEjQUXLtMi4P085bV)s4Qxgn4yE2YtAkyyv34Yjte8uA(8G3FjCffepB5z3oGleu3ZD9uJhXtTA9mspfd8suDJlNmrWtP5ZdE)LWvVmAWX8ehpB5j0EgPNq7jxqK(8G3FjgqrbXZwEkg4LO4cI0Nh8(lXaQxgn4yEIJNA16PH)NWKRktOigy2yKoQ0urSAJNd9mQE2YtAkyy1wwHnJP4IIlwyJN76juT3tCw6wqyOAPFW7VedmPbgxwYA02VgBP)YObhBf9spqyYjmBPlg4LO4cI038d5e1lJgCmpB5j0Esmg2849sugggxfquL45UEgvp1Q1tIXWMhVxIYWW4kw5j(8mcJ4joE2YtO9mspfd8suCks8Ni4je02tuVmAWX8uRwpPPGHvCks8Ni4je02tuuq8uRwp72bCHG6EIVHE2(27jolDlimuT05cI038d5KLSgncRXw6VmAWXwrV0deMCcZw6IbEjkalIqXWMDlUBtbjVREz0GJ5zlpH2tIXWMhVxIYWW4QaIQep31ZO6PwTEsmg2849sugggxXkpXNNryepXzPBbHHQLoGfrOyyZUf3TPGK3xYAunEn2s)Lrdo2k6LEGWKty2sNMcgwXfePV5hYjkkiE2YtoKdatXiXx4QqJXQjGf3ifRI9CxpXLNT8eApn8)eMCfWWZM8guyJIy1gp1GN0uWWkGHNn5nOWgfxSWgpXXZD9exASNT8eApPPGHvDJlNmrWtP5ZdE)LWvuq8SLNr6PyGxIItrI)ebpHG2EI6LrdoMNA16jnfmSItrI)ebpHG2EIIcIN4S0TGWq1shWIBKIvXtAeqwYAunI1yl9xgn4yROx6bctoHzlDO9Kd5aWums8fUk0ySAcyXnsXQypXNNq5PwTEA4)jm5k5bbvSWuAOkStueR24j(g6zu9SLNr6PyGxIItrI)ebpHG2EI6LrdoMNT80W)tyYvadpBYBqHnkIvB8CxpHYtC8SLNg(FctUcy4ztEdkSrrSAJNAWtAkyyfWWZM8guyJIlwyJN76j0Egvn2Zb8mQEQbpn8)eMCL8GGkwyknuf2jkIvB8udEYHCaykgj(cxfAmwnbS4gPyvSN44zlpH2Zi9umWlrXPiXFIGNqqBpr9YObhZtTA9mspXqIcgy9p5nOWgf5WKZBmAW9uRwp5cI0Nh8(lXakkiEIJNT8eApJ0tXaVev34Yjte8uA(8G3FjC1lJgCmp1Q1tAkyyv34Yjte8uA(8G3FjCffep1Q1ZacbWqBlfWWZM0ueUOiVBSI7j(8CepB5z3oGleu3t8n0ZDexEoGNrDep1GNIbEjQGbatP5tPHQWor9YObhZtCw6wqyOAPFJinrekBZxYAu8Z1yl9xgn4yROx6bctoHzl9i9KMcgwXPiXFIGNqqBprrbXZwEkg4LO6gxozIGNsZNh8(lHREz0GJ5zlpH2tAkyyv34Yjte8uA(8G3FjCffep1Q1ZacbWqBlfWWZM0ueUOiVBSI7j(8CepB5z3oGleu3t8n0ZDexEoGNrDep1GNIbEjQGbatP5tPHQWor9YObhZtTA9Kd5aWums8fUk0ySAcyXnsXQyp31tC5zlpH2td)pHjxbm8SjVbf2OiwTXtn4jnfmScy4ztEdkSrXflSXZD9exASN44zlpPPGHvCbr6B(HCIIcINT8mGqam02sbm8SjnfHlkY7gR4EU7qpJdyEIZs3ccdvl9BePzYBqHnlzn6oUgBP)YObhBf9spqyYjmBPhPNIbEjQUXLtMi4P085bV)s4Qxgn4yE2YZi9eApn8)eMCflUoIIpHGKxcZakIvB8eFEIlpB5jnfmSY4HxywfUIcIN44zlpH2tAkyyfxqK(MFiNOOG4PwTE2Td4cb19eFd9ChhXZb8mQJ4Pg8umWlrfmayknFknuf2jQxgn4yEQvRNr6j0EYfePpp49xIbuuq8SLNIbEjkUGi95bV)smG6LrdoMN44zlppUd5b5yZaQtBYe8kwA8CCpfw)EoUNbecGH2wkUGi95bV)smGI8UXkUNJ7juryep1GNWaeI4j0EcTNh3H8GCSza1PnzcEflnEoUNcRFph3ZacbWqBlfxqK(8G3FjgqrE3yf3tC8uJ6juryepXXt8n0ZOoINAWtO9ekphWtO90W)tyYvp0GMi4P085bV)smaxrSAJN4BON4YtC8ehpXzPBbHHQL(nI0m5nOWMLSgfQrwJT0Fz0GJTIEPhim5eMT0fd8suCks8Ni4je02tuVmAWX8SLNr6jnfmSItrI)ebpHG2EIIcINT8mGqam02sbm8SjnfHlkY7gR4EU7qpJdyE2YtO9mspfd8suCbr6ZdE)Lya1lJgCmpB5zKEcZiFEW7VedOOG4PwTEkg4LO4cI0Nh8(lXaQxgn4yE2YZi9KlisFEW7VedOOG4jolDlimuT0VrKMjVbf2SK1Oqb1ASL(lJgCSv0l9aHjNWSLoxqK(8G3FjgqrbXZwEkg4LO4cI0Nh8(lXaQxgn4yE2YtO90W)tyYvS46ik(ecsEjmdOiwTXZD9exEQvRNr6jnfmScy4ztofj(kkiE2YtAkyyfnaHWauCrrbXtCw6wqyOAPdyXnsXQ4jncilznku4An2s)Lrdo2k6LEGWKty2shApPPGHvCbr6B(HCII8UXkUN76jukO8udEghW8udEstbdR4cI038d5efxSWgp1Q1tAkyyfxqK(MFiNOOG4zlpPPGHvDJlNmrWtP5ZdE)LWvuq8eNLUfegQw6awCJuSkEsJaYswJcvuxJT0Fz0GJTIEPhim5eMT0fd8suSWHPiAQEz0GJ5zlpfd8suDJlNmrWtP5ZdE)LWvVmAWX8SLN0uWWkw4Wuenvuq8SLN0uWWQUXLtMi4P085bV)s4kkilDlimuT0HjiUm5nOWMLSgfQ2VgBP)YObhBf9spqyYjmBPttbdRmE4fMvHROGS0TGWq1shy4ztAkcxwYAuOIWASL(lJgCSv0lDlimuT0Hbw)tEdkSzPhim5eMT0jhMCEJrdUNT80ccdVpF9o7CpXNNq5zlpPPGHvCks8Ni4je02tuuqw6bndGpfJeFHVgfQLSgfknEn2s)Lrdo2k6LEGWKty2sxmWlrXfePpp49xIbuVmAWX8SLNbecGH2wtYTG4zlpPPGHvCks8Ni4je02tuuq8SLNq75XDipihBgqDAtMGxXsJNJ7PW63ZX9mGqam02sXfePpp49xIbuK3nwX9CCpHkcJ4Pg8egGqepH2tO984oKhKJndOoTjtWRyPXZX9uy9754EgqiagABP4cI0Nh8(lXakY7gR4EIJNAupHkcJ4joEURNrDep1GNq7juEoGNq7PH)NWKREObnrWtP5ZdE)LyaUIy1gpX3qpXLN44joEQvRNq7jukO0yp1GNq75XDipihBgqDAtMGxXsJNJ7PW63tC8CCpdieadTTuCbr6ZdE)Lyaf5DJvCph3tOIWiEQbpHbieXtO9eApHsbLg7Pg8eAppUd5b5yZaQtBYe8kwA8CCpfw)EIJNJ7zaHayOTLIlisFEW7VedOiVBSI7joEQr9eQimIN44joEURNq75XDipihBgqDAtMGxXsJNJ7PW63ZX9mGqam02sXfePpp49xIbuK3nwX9CCpHkcJ4Pg8egGqepH2tO984oKhKJndOoTjtWRyPXZX9uy9754EgqiagABP4cI0Nh8(lXakY7gR4EIJNAupHkcJ4joEIJN4S0TGWq1shy4ztAkcxwYAuO0iwJT0Fz0GJTIEPhim5eMT0J0tXaVefxqK(8G3Fjgq9YObhZZwEgqiagABnj3cINT8KMcgwXPiXFIGNqqBprrbXZwEcTNh3H8GCSza1PnzcEflnEoUNcRFph3ZacbWqBlfmJ85bV)smGI8UXkUNJ7juryep1GNWaeI4j0EcTNh3H8GCSza1PnzcEflnEoUNcRFph3ZacbWqBlfmJ85bV)smGI8UXkUN44Pg1tOIWiEIJN76zuhXtn4j0EcLNd4j0EA4)jm5QhAqte8uA(8G3FjgGRiwTXt8n0tC5joEIJNA16j0EcLckn2tn4j0EEChYdYXMbuN2Kj4vS0454EkS(9ehph3ZacbWqBlfmJ85bV)smGI8UXkUNJ7juryep1GNWaeI4j0EcTNqPGsJ9udEcTNh3H8GCSza1PnzcEflnEoUNcRFpXXZX9mGqam02sbZiFEW7VedOiVBSI7joEQr9eQimIN44joEURNq75XDipihBgqDAtMGxXsJNJ7PW63ZX9mGqam02sbZiFEW7VedOiVBSI754EcvegXtn4jmaHiEcTNq75XDipihBgqDAtMGxXsJNJ7PW63ZX9mGqam02sbZiFEW7VedOiVBSI7joEQr9eQimIN44joEIZs3ccdvlDGHNnPPiCzjRrHc)Cn2s)Lrdo2k6LEGWKty2sNMcgwXPiXFIGNqqBprrbzPBbHHQLoGf3ifRIN0iGSK1OqTJRXw6VmAWXwrV0deMCcZw6becGH2wtYTG4zlpJ0tXaVev34Yjte8uA(8G3FjC1lJgCSLUfegQw6adpBstr4YswJIRrwJT0Fz0GJTIEPhim5eMT0fd8suSWHPiAQEz0GJ5zlpJ0tO9SBhWfcQ7j(8uJicE2YZacbWqBlfWWZM0ueUOiVBSI75Ud9CepXXZwEcTNr6PyGxIIlisFEW7VedOEz0GJ5PwTEYfePpp49xIbuyOTLN4S0TGWq1sNfomfrZLSgfxqTgBP)YObhBf9spqyYjmBPhqiagABnj3cINT8m0yK4Z9eFEkg4LOEObnrWtP5ZdE)LWvVmAWXw6wqyOAPdm8SjnfHllznkUW1ASL(lJgCSv0l9aHjNWSLUyGxIIfomfrt1lJgCmpB5jnfmSIfomfrtffepB5jnfmSIfomfrtf5DJvCp31tOuq5Pg8moG5Pg8KMcgwXchMIOPIlwyZs3ccdvlDycIltEdkSzjRrXvuxJT0Fz0GJTIEPhim5eMT0dieadTTMKBbzPBbHHQLoWWZM0ueUSK1O4Q9RXw6VmAWXwrV0TGWq1shgy9p5nOWMLEGWKty2sNCyY5ngn4E2YZi9KMcgwXPiXFIGNqqBprrbzPh0ma(ums8f(AuOwYAuCfH1yl9xgn4yROx6bctoHzlDXaVeLGK3NDJlNOP6LrdoMNT8eApPPGHvKZrLvHpfK8UI8UXkUN76Pg7PwTEcTN0uWWkY5OYQWNcsExrE3yf3ZD9eApPPGHvgp8cZQWvyuetyOYZb8mGqam02sz8WlmRcxrE3yf3tC8SLNbecGH2wkJhEHzv4kY7gR4EURNqfbpXXtCw6wqyOAPli59z34YjAUK1O4sJxJT0Fz0GJTIEPhim5eMT0fd8suSWHPiAQEz0GJ5zlpPPGHvSWHPiAQOG4zlpH2tAkyyflCykIMkY7gR4EURNXbmp1GNT3tn4jnfmSIfomfrtfxSWgp1Q1tAkyyfxqK(MFiNOOG4PwTEgPNIbEjQUXLtMi4P085bV)s4Qxgn4yEIZs3ccdvlDycIltEdkSzjRrXLgXASL(lJgCSv0l9aHjNWSLonfmSsEqqflmLgQc7effepB5zKEstbdR4cI038d5effepB5jhYbGPyK4lCvOXy1eWIBKIvXEIppHAPBbHHQLEOXy1eWIBKIvXlznkUWpxJT0TGWq1shWIBKIvXtAeqw6VmAWXwrVK1O4AhxJT0Fz0GJTIEPBbHHQLomW6FYBqHnl9GMbWNIrIVWxJc1spqyYjmBPtom58gJg8LEhHhRIx6qTK1OrDK1yl9xgn4yROx6bctoHzl9ocV3FjkmgxSkCpXNNA8s3ccdvlDyG1)K3GcBw6DeESkEPd1swJgvOwJT07i8yv8shQLUfegQw6WeexM8guyZs)Lrdo2k6LSKLUH(AS1OqTgBP)YObhBf9spqyYjmBPlg4LO4cI038d5e1lJgCSLUfegQw6Cbr6B(HCYswJIR1yl9xgn4yROx6wqyOAPddS(N8guyZspqyYjmBPtom58gJgCpB5j0EYHCaykgj(cxfAmwnbS4gPyvSN76j0Egbph3Zi9umWlrji59z34YjAQEz0GJ5joEQvRNr6PyGxIIlisFEW7VedOEz0GJ5zlpH2tyg5ZdE)Lyaf5DJvCpXNNq7juT3tn4jhYbGzJXL7joEQvRNbecGH2wkyg5ZdE)Lyaf5DJvCp31tO9exT3ZX9eQ27Pg8Kd5aWSX4Y9ehpXXtC8SLNq7zKEkg4LO4cI0Nh8(lXaQxgn4yEQvRNCbr6ZdE)LyafgAB5PwTEYHCaykgj(cxfAmwnbS4gPyvSNd9mQE2YtAkyy1wwHnJP4IIlwyJN76juT3tCw6bndGpfJeFHVgfQLSgnQRXw6VmAWXwrV0deMCcZw6IbEjkJhEHzv4Qxgn4yE2YtO9umWlrXfePpp49xIbuVmAWX8SLNCbr6ZdE)LyafgAB5zlpdieadTTuCbr6ZdE)Lyaf5DJvCpXNNqfbp1Q1Zi9umWlrXfePpp49xIbuVmAWX8ehpB5j0EgPNIbEjkw4WuenvVmAWX8uRwpJ0tAkyyflCykIMkkiE2YZi9mGqam02sXchMIOPIcIN4S0TGWq1s34Hxywf(swJ2(1yl9xgn4yROx6bctoHzlDXaVefGfrOyyZUf3TPGK3vVmAWXw6wqyOAPdyrekg2SBXDBki59LSgncRXw6VmAWXwrV0deMCcZw6r6PyGxIQBC5KjcEknFEW7VeU6LrdoMNA16jnfmSIlisFZpKtuuq8uRwp72bCHG6EIVHEcTNqnYiEoUNT3tn4jhYbGPyK4lCvOXy1eWIBKIvXEIJNA16jnfmSQBC5KjcEknFEW7VeUIcINA16jhYbGPyK4lCvOXy1eWIBKIvXEIppJ6s3ccdvl9BePjIqzB(swJQXRXw6VmAWXwrV0deMCcZw60uWWkUGi9n)qorrE3yf3ZD9mQEQbpJdyEQbpPPGHvCbr6B(HCIIlwyZs3ccdvl9qJXQjGf3ifRIxYAunI1yl9xgn4yROx6bctoHzlDAkyyfWWZMCks8vuq8SLNCihaMIrIVWvHgJvtalUrkwf75UE2EpB5j0EgPNIbEjkUGi95bV)smG6LrdoMNA16jxqK(8G3FjgqHH2wEIJNT8edjkyG1)K3GcBuclSHvXlDlimuT0bgE2KMIWLLSgf)Cn2s)Lrdo2k6LEGWKty2sNd5aWums8fUk0ySAcyXnsXQyp31Z27zlpJ0tAkyyLXdVWSkCffKLUfegQw6SWHPiAUK1O74ASL(lJgCSv0l9aHjNWSLohYbGPyK4lCvOXy1eWIBKIvXEURNT3ZwEstbdRyHdtr0urbXZwEgPN0uWWkJhEHzv4kkilDlimuT0HjiUm5nOWMLSgfQrwJT0Fz0GJTIEPhim5eMT0fd8suh8(lXatAGXf1lJgCmpB5jhYbGPyK4lCvOXy1eWIBKIvXEURNT3ZwEcTNr6PyGxIIlisFEW7VedOEz0GJ5PwTEYfePpp49xIbuyOTLN4S0TGWq1s)G3FjgysdmUSK1Oqb1ASL(lJgCSv0l9aHjNWSLUyGxIY4HxywfU6Lrdo2s3ccdvlDGHNnPV1xYAuOW1ASLUfegQw6HgJvtalUrkwfV0Fz0GJTIEjRrHkQRXw6VmAWXwrV0deMCcZw6IbEjkJhEHzv4Qxgn4ylDlimuT0bgE2KMIWLLEhHhRIx6qTK1Oq1(1yl9xgn4yROx6wqyOAPddS(N8guyZspOza8PyK4l81OqT0deMCcZw6KdtoVXObFP3r4XQ4Loulznkuryn2sVJWJvXlDOw6wqyOAPdtqCzYBqHnl9xgn4yROxYsw6yh2OaYAS1OqTgBP)YObhBrV0deMCcZw6g(FctUYQW5cXatY5OYQWvVmAWXw6wqyOAPtdqimafxwYAuCTgBP)YObhBf9spqyYjmBPFChYdYXMbuN2Kj4vS0454EkS(9CxpJ6iEQvRNWmYNh8(lXakkiEQvRNCbr6ZdE)LyaffKLUfegQw6qqcdvlznAuxJT0TGWq1sFlRWM8MBKL(lJgCSv0lznA7xJT0Fz0GJTIEPhim5eMT0fd8sucsEF2nUCIMQxgn4yE2YtAkyyf5Cuzv4tbjVRiVBSI75UEIRLUfegQw6csEF2nUCIMlznAewJT0Fz0GJTIEPhim5eMT0J0tXaVefxqK(8G3Fjgq9YObhBPBbHHQLomJ85bV)smWswJQXRXw6VmAWXwrV0deMCcZw6IbEjkUGi95bV)smG6LrdoMNT8eApJ0tXaVeflCykIMQxgn4yEQvRNr6jnfmSIfomfrtffepB5zKEgqiagABPyHdtr0urbXtC8SLNq7zKEkg4LOmE4fMvHREz0GJ5PwTEgPNbecGH2wkJhEHzv4kkiEIZs3ccdvlDUGi95bV)smWswJQrSgBPBbHHQLof)tM8oFP)YObhBf9swJIFUgBPBbHHQLEavHxcXKJnHbw)l9xgn4yROxYA0DCn2s3ccdvlDAacHnrWtP5ZxVR5s)Lrdo2k6LSgfQrwJT0TGWq1spMYiymRMi4PH)NGKML(lJgCSv0lznkuqTgBPBbHHQLomkqXp20W)tyYN036l9xgn4yROxYAuOW1ASLUfegQw6qOimynzv8KgyCzP)YObhBf9swJcvuxJT0TGWq1sxA(KQOruf2egrcFP)YObhBf9swJcv7xJT0TGWq1sV)oIO5ebpbubg2eJCRZx6VmAWXwrVK1OqfH1ylDlimuT0jmiqaFYQjhIf(s)Lrdo2k6LSgfknEn2s3ccdvl9TicadVZQj5Cuzv4l9xgn4yROxYAuO0iwJT0Fz0GJTIEPhim5eMT0J0tXaVeLXdVWSkC1lJgCmp1Q1tAkyyLXdVWSkCffep1Q1ZacbWqBlLXdVWSkCf5DJvCpXNNryKLUfegQw60aecBctr0CjRrHc)Cn2s)Lrdo2k6LEGWKty2spspfd8sugp8cZQWvVmAWX8uRwpPPGHvgp8cZQWvuqw6wqyOAPtFc)KnSkEjRrHAhxJT0Fz0GJTIEPhim5eMT0J0tXaVeLXdVWSkC1lJgCmp1Q1tAkyyLXdVWSkCffep1Q1ZacbWqBlLXdVWSkCf5DJvCpXNNryKLUfegQw6WmYPbie2swJIRrwJT0Fz0GJTIEPhim5eMT0J0tXaVeLXdVWSkC1lJgCmp1Q1tAkyyLXdVWSkCffep1Q1ZacbWqBlLXdVWSkCf5DJvCpXNNryKLUfegQw6wfoxigygmayjRrXfuRXw6VmAWXwrV0deMCcZw6Cbr6ZdE)LyaffepB5jnfmSkyaWeWIBKIvXkY7gR4EIVHEIFU0TGWq1s)A(jcEknFYfePVK1O4cxRXw6wqyOAP3VCezP)YObhBf9swJIROUgBP)YObhBf9spqyYjmBPBbHH3NVENDUN4ZtC5zlpH2toKdatXiXx4QqJXQjGf3ifRI9eFEIlp1Q1toKdatXiXx4kGHNnPV19eFEIlpXzPBbHHQLoHQMwqyOAcyCzPdyCzww)lDd9LSgfxTFn2s)Lrdo2k6LUfegQw6eQAAbHHQjGXLLoGXLzz9V05Skg8PyK4llzjlDiKhqDAtwJTgfQ1yl9xgn4yROxYAuCTgBP)YObhBf9swJg11yl9xgn4yROxYA02VgBP)YObhBf9swJgH1ylDlimuT0fK8(SBC5enx6VmAWXwrVK1OA8ASL(lJgCSv0l9aHjNWSLUyGxIIlisFZpKtuVmAWX8SLNq7jXyyZJ3lrzyyCvarvIN76zu9uRwpjgdBE8EjkddJRyLN4ZZimIN4S0TGWq1sNlisFZpKtwYAunI1yl9xgn4yROx6bctoHzl9i9umWlrXfePpp49xIbuVmAWXw6wqyOAPdZiFEW7VedSK1O4NRXw6VmAWXwrV0deMCcZw6IbEjkUGi95bV)smG6Lrdo2s3ccdvlDUGi95bV)smWswJUJRXw6wqyOAPdbjmuT0Fz0GJTIEjRrHAK1yl9xgn4yROx6bctoHzlDXaVe1bV)smWKgyCr9YObhBPBbHHQL(bV)smWKgyCzjRrHcQ1yl9xgn4yROx6bctoHzl9i9umWlrDW7VedmPbgxuVmAWX8SLNCihaMIrIVWvHgJvtalUrkwf75UEg1LUfegQw6adpBstr4YswJcfUwJT0Fz0GJTIEPhim5eMT05qoamfJeFHRcngRMawCJuSk2t85jUw6wqyOAPhAmwnbS4gPyv8swYswYswl]] )
    spec:RegisterPack( "Elemental Funnel", 20190625.0952, [[d4KnPbqisjpciQlbvkTjQkFIQiAuaPtbcRcQQEfvjZcaDlGWUi5xsrnmQQCmOILbvPNjfX0OkQRbvY2GkvFdisnoquQZbII1rvKY7aIizEGi3tkSpOkoivrQwivPEiuPiteisUOuK2iuPWhHkf1ibIi1jPkcTsqYlbIiMjqeUjuvyNaWpPkcmuOQOLsve0tjvtLQQUkik5Raru7vs)vQgSIdtzXi8yQmzqDzvBgkFwknAaDAuEni1Sv62sSBr)gYWbQJtvKSCKEoQMoX1r02Pk8DaA8GO68KsTEOQ08jf7x4kov)R6WM8kaWRF4az8d3XlUu(bzWvt8ZZvDrBWVQd2CqBTVQNw5v9MUV8uSngCdYm)w1bBAVidU6FvNJiPUx1R6eKSv8eZkrvh2KxbaE9dhiJF4oEXLYpidUWlU8Cv3ifGiAvhFsMgWVVQdKbd)Ssu1Hp3v1b5yA6(YtX2y0bAflJbuCdYm)YYwicOa5yakcyUNwZn3YeGKekhQ0mNvixtyO0rnmPzoR4AoGcKJbkY8XGxCbWyWRF4azIbeX4hKXtdx4TQVmUWR(x15SSDFxmA7LQ)vaGt1)Q(tJypC17QUJYKtzwvh0y0kgH5GMLTXOrtmITpffxq0s)7lpfBvpnI9WX4lghcTWiatfxq0s)7lpfBv0xmwYJbsXG3yWFmTo4y0OjgyKOWwR8ohiYbTI(IXsEmqQrmTo4y0OjgX2NIY4UNWw6U6PrShogFXaJef2AL35aroOv0xmwYJbsXaAmoeAHraMkJ7EcBP7k6lgl5X4vmeKyykJ7EcBP7kysQjmugdeX4lghcTWiatLXDpHT0Df9fJL8yGumEogFXaAmAfJy7trXfeT0)(YtXw1tJypCmA0eJy7trXfeT0)(YtXw1tJypCm(IHliAP)9LNITkyeGzmqedeX4lgqJHGedtbilH7TKCrXfZbDmqkgC8CmA0eJHVNYKRyT5rK8oyK8uy2QOwcDm4Prm4ngnAIHGedtTMhwNtsBVIeCmA0eJwXqqIHPiwecEj5IIeCmqeJVy0kgcsmmfNK2(ocRdgb4PksWvDZjmuw1XwR8ohiYbDvQaaVv)R6pnI9WvVR6oktoLzvDX2NIY4UNWw6U6PrShogFX4qOfgbyQwZdRtqs5II(IXsEm4jg)IXxmGgdxq0s)7lpfBvWiaZy0OjgTIrS9PO4cIw6FF5PyR6PrShogiIXxmGgJwXi2(uum3XiPAREAe7HJrJMy0kgcsmmfZDmsQ2ksWX4lgTIXHqlmcWuXChJKQTIeCmqu1nNWqzv34UNWw6EvQaOjv)R6pnI9WvVR6oktoLzvDX2NI67lpfB7eRXf1tJypCm(Ib0yeBFkQIXLt7iSUa89VV8u4QNgXE4y8fdbjgMQyC50ocRlaF)7lpfUIeCm(IPyF5cfvIbsXG7(fJgnXOvmITpfvX4YPDewxa((3xEkC1tJypCmqeJVyangTIb0y4cIw6FF5PyRIeCm(IrS9PO4cIw6FF5PyR6PrShogiIrJMym89uMCvAcj12oqJwqP2kQLqhtJyAsm(IHGedtbilH7TKCrXfZbDmqkgC8Cmqu1nNWqzv)7lpfB7eRXLQubGNR(x1FAe7HREx1DuMCkZQ6ITpffxq0c0)Gpv90i2dhJVyangQXG73JNIYGH5khImLyGumnjgnAIHAm4(94POmyyUILXGNyWLFXarm(Ib0y0kgX2NIItsBFhH1bJa8u1tJypCmA0edbjgMItsBFhH1bJa8ufj4y0OjMI9Lluujg80igp75yGOQBoHHYQoxq0c0)GpTkvaGRQ)v9NgXE4Q3vDhLjNYSQUy7trTmpfjdUxS2I1fK8I6PrShogFXaAmuJb3VhpfLbdZvoezkXaPyAsmA0ed1yW97XtrzWWCflJbpXGl)IbIQU5egkR6lZtrYG7fRTyDbjVuLkaW9Q)v9NgXE4Q3vDhLjNYSQobjgMIliAb6FWNQibhJVy4G)UDXOTx4khqJL9L1cusw2gdKIb3JXxmGgJHVNYKRwZdRZbICqROwcDm4pgcsmm1AEyDoqKdAfxmh0XarmqkMMG7X4lgqJHGedtvmUCAhH1fGV)9LNcxrcogFXOvmITpffNK2(ocRdgb4PQNgXE4y0OjgcsmmfNK2(ocRdgb4PksWXarv3CcdLv9L1cusw22jqRuLkaaPR(x1FAe7HREx1DuMCkZQ6AfdbjgMItsBFhH1bJa8ufj4y8fJy7trvmUCAhH1fGV)9LNcx90i2dhJVyangcsmmvX4YPDewxa((3xEkCfj4y0OjghcTWiat1AEyDcskxu0xmwYJbpX4xm(IPyF5cfvIbpnIbYG3y8kMM4xm4pgX2NIYz72fGVlajt4tvpnI9WXOrtmGgJHVNYKRwZdRZbICqROwcDm4pgcsmm1AEyDoqKdAfxmh0XaPyAcUhdeX4lgcsmmfxq0c0)GpvrcogFX4qOfgbyQwZdRtqs5II(IXsEmqQrmTo4yGignAIrRyeBFkQIXLt7iSUa89VV8u4QNgXE4y8fJwXaAmg(EktUI1MhrY7GrYtHzRIAj0XGNyWBm(IHGedtzC3tylDxrcogiIXxmGgdbjgMIliAb6FWNQibhJgnXuSVCHIkXGNgXaz8lgVIPj(fd(JrS9POC2UDb47cqYe(u1tJypCmA0eJwXaAmCbrl9VV8uSvrcogFXi2(uuCbrl9VV8uSv90i2dhdeX4lMd5GVtoC3HkeM03NTcWyarmcR8yarmoeAHraMkUGOL(3xEk2QOVySKhdiIbhC5xm4pgSfHOXaAmGgZHCW3jhU7qfct67ZwbymGigHvEmGighcTWiatfxq0s)7lpfBv0xmwYJbIyWTXGdU8lgiIbpnIPj(fd(Jb0yWjgVIb0ym89uMC1DarDewxa((3xEk2YvulHog80ig8gdeXarmqu1nNWqzv)gva25aroORsfaq2v)R6pnI9WvVR6oktoLzvDX2NIItsBFhH1bJa8u1tJypCm(IrRyiiXWuCsA77iSoyeGNQibhJVyCi0cJamvR5H1jiPCrrFXyjpgi1iMwhCm(Ib0y0kgX2NIIliAP)9LNITQNgXE4y8fJwXaAmym67FF5PyRIeCmqeJgnXi2(uuCbrl9VV8uSv90i2dhJVy0kgqJHliAP)9LNITksWXarmqu1nNWqzv)gva25aroORsfaqMQ)v9NgXE4Q3vDhLjNYSQoxq0s)7lpfBvKGJXxmITpffxq0s)7lpfBvpnI9WX4lgqJXW3tzYvS28isEhmsEkmBvulHogifdEJrJMy0kgcsmm1AEyDojT9ksWX4lgcsmmfXIqWljxuKGJbIQU5egkR6lRfOKSSTtGwPkvaGJFv)R6pnI9WvVR6oktoLzvDX2NII5ogjvB1tJypCm(IrS9POkgxoTJW6cW3)(YtHREAe7HJXxmeKyykM7yKuTvKGJXxmeKyyQIXLt7iSUa89VV8u4ksWvDZjmuw1XOiU05aroORsfa4Gt1)Q(tJypC17QUJYKtzwvNGedtzC3tylDxrcUQBoHHYQ(AEyDcskxQsfa4G3Q)v9NgXE4Q3vDhLjNYSQo9y0ZbAe7JXxmMtyE8(ZxyNhdEIbNy8fdbjgMItsBFhH1bJa8ufj4QU5egkR6yRvENde5GUkvaGttQ(x1FAe7HREx1DuMCkZQ6ITpffxq0s)7lpfBvpnI9WX4lghcTWiaZo9MtIXxmeKyykojT9DewhmcWtvKGJXxmGgZHCW3jhU7qfct67ZwbymGigHvEmGighcTWiatfxq0s)7lpfBv0xmwYJbeXGdU8lg8hd2Iq0yangqJ5qo47Kd3DOcHj99zRamgqeJWkpgqeJdHwyeGPIliAP)9LNITk6lgl5Xarm42yWbx(fdeXaPyAIFXG)yangCIXRyangdFpLjxDhquhH1fGV)9LNITCf1sOJbpnIbVXarmqeJgnXaAm4OWb3Jb)XaAmhYbFNC4UdvimPVpBfGXaIyew5XarmGighcTWiatfxq0s)7lpfBv0xmwYJbeXGdU8lg8hd2Iq0yangqJbhfo4Em4pgqJ5qo47Kd3DOcHj99zRamgqeJWkpgiIbeX4qOfgbyQ4cIw6FF5PyRI(IXsEmqedUngCWLFXarmqedKIb0yoKd(o5WDhQqysFF2kaJbeXiSYJbeX4qOfgbyQ4cIw6FF5PyRI(IXsEmGigCWLFXG)yWweIgdOXaAmhYbFNC4UdvimPVpBfGXaIyew5XaIyCi0cJamvCbrl9VV8uSvrFXyjpgiIb3gdo4YVyGigiIbIQU5egkR6R5H1jiPCPkvaGJNR(x1FAe7HREx1DuMCkZQ6AfJy7trXfeT0)(YtXw1tJypCm(IXHqlmcWStV5Ky8fdbjgMItsBFhH1bJa8ufj4y8fdOXCih8DYH7ouHWK((SvagdiIryLhdiIXHqlmcWuHXOV)9LNITk6lgl5XaIyWbx(fd(JbBriAmGgdOXCih8DYH7ouHWK((SvagdiIryLhdiIXHqlmcWuHXOV)9LNITk6lgl5Xarm42yWbx(fdeXaPyAIFXG)yangCIXRyangdFpLjxDhquhH1fGV)9LNITCf1sOJbpnIbVXarmqeJgnXaAm4OWb3Jb)XaAmhYbFNC4UdvimPVpBfGXaIyew5XarmGighcTWiatfgJ((3xEk2QOVySKhdiIbhC5xm4pgSfHOXaAmGgdokCW9yWFmGgZHCW3jhU7qfct67ZwbymGigHvEmqediIXHqlmcWuHXOV)9LNITk6lgl5Xarm42yWbx(fdeXarmqkgqJ5qo47Kd3DOcHj99zRamgqeJWkpgqeJdHwyeGPcJrF)7lpfBv0xmwYJbeXGdU8lg8hd2Iq0yangqJ5qo47Kd3DOcHj99zRamgqeJWkpgqeJdHwyeGPcJrF)7lpfBv0xmwYJbIyWTXGdU8lgiIbIyGOQBoHHYQ(AEyDcskxQsfa4GRQ)v9NgXE4Q3vDhLjNYSQobjgMItsBFhH1bJa8ufj4QU5egkR6lRfOKSSTtGwPkvaGdUx9VQ)0i2dx9UQ7Om5uMv1Di0cJam70BojgFXOvmITpfvX4YPDewxa((3xEkC1tJypCv3CcdLv918W6eKuUuLkaWbKU6Fv)PrShU6Dv3rzYPmRQl2(uum3XiPAREAe7HJXxmAfdOXuSVCHIkXGNyaPXvm(IXHqlmcWuTMhwNGKYff9fJL8yGuJy8lgiIXxmGgJwXi2(uuCbrl9VV8uSv90i2dhJgnXWfeT0)(YtXwfmcWmgiQ6MtyOSQZChJKQDvQaahi7Q)v9NgXE4Q3vDhLjNYSQUdHwyeGzNEZjX4lghqJ2EEm4jgX2NI6oGOocRlaF)7lpfU6PrShUQBoHHYQ(AEyDcskxQsfa4azQ(x1FAe7HREx1DuMCkZQ6ITpffZDmsQ2QNgXE4y8fdbjgMI5ogjvBfj4y8fdbjgMI5ogjvBf9fJL8yGum4OWjg8htRdog8hdbjgMI5ogjvBfxmh0vDZjmuw1XOiU05aroORsfa41VQ)v9NgXE4Q3vDhLjNYSQUdHwyeGzNEZjvDZjmuw1xZdRtqs5svQaaV4u9VQ)0i2dx9UQ7Om5uMv1PhJEoqJyFm(IrRyiiXWuCsA77iSoyeGNQibx1nNWqzvhBTY7CGih0vPca8I3Q)v9NgXE4Q3vDhLjNYSQUy7trji5LEX4YPAREAe7HJXxmGgdbjgMIEokT09UGKxu0xmwYJbsXG7XOrtmGgdbjgMIEokT09UGKxu0xmwYJbsXaAmeKyykJ7EcBP7kysQjmugJxX4qOfgbyQmU7jSLUROVySKhdeX4lghcTWiatLXDpHT0Df9fJL8yGum4GRyGigiQ6MtyOSQli5LEX4YPAxLkaWBtQ(x1FAe7HREx1DuMCkZQ6ITpffZDmsQ2QNgXE4y8fdbjgMI5ogjvBfj4y8fdOXqqIHPyUJrs1wrFXyjpgiftRdog8hJNJb)XqqIHPyUJrs1wXfZbDmA0edbjgMIliAb6FWNQibhJgnXOvmITpfvX4YPDewxa((3xEkC1tJypCmqu1nNWqzvhJI4sNde5GUkvaGxpx9VQBoHHYQ(YAbkjlB7eOvQ6pnI9WvVRsfa4fxv)R6pnI9WvVR6oktoLzvD6XONd0i2x1nNWqzvhBTY7CGih0v9cYdw2w1XPkvaGxCV6Fv)PrShU6Dv3rzYPmRQxqE8YtrbZ4ILUhdEIb3R6MtyOSQJTw5DoqKd6QEb5blBR64uLkaWliD1)QEb5blBR64u1nNWqzvhJI4sNde5GUQ)0i2dx9UkvPQBOx9VcaCQ(x1FAe7HREx1DuMCkZQ6ITpffxq0c0)Gpv90i2dx1nNWqzvNliAb6FWNwLkaWB1)Q(tJypC17QU5egkR6yRvENde5GUQ7Om5uMv1PhJEoqJyFm(Ib0y4G)UDXOTx4khqJL9L1cusw2gdKIb0yWvmGigTIrS9POeK8sVyC5uTvpnI9WXarmA0eJwXi2(uuCbrl9VV8uSv90i2dhJVyanghcTWiatfgJ((3xEk2QOVySKhdEIb0yWbV(fJxXGJNJb)XWb)D7anU8yGignAIXHqlmcWuHXOV)9LNITk6lgl5XaPyang865yarm445yWFmCWF3oqJlpgiIbIyGigFXaAmAfJy7trXfeT0)(YtXw1tJypCmA0edxq0s)7lpfBvWiaZy0Ojgo4VBxmA7fUYb0yzFzTaLKLTX0iMMeJVyiiXWuaYs4EljxuCXCqhdKIbhphdevDN2U9DXOTx4vaGtvQaOjv)R6pnI9WvVR6oktoLzvDX2NIY4UNWw6U6PrShogFXaAmITpffxq0s)7lpfBvpnI9WX4lgUGOL(3xEk2QGraMX4lghcTWiatfxq0s)7lpfBv0xmwYJbpXGdUIrJMy0kgX2NIIliAP)9LNITQNgXE4yGigFXaAmAfJy7trXChJKQT6PrShognAIrRyiiXWum3XiPARibhJVy0kghcTWiatfZDmsQ2ksWXarv3CcdLvDJ7EcBP7vPcapx9VQ)0i2dx9UQ7Om5uMv1fBFkQL5PizW9I1wSUGKxupnI9WvDZjmuw1xMNIKb3lwBX6csEPkvaGRQ)v9NgXE4Q3vDhLjNYSQUwXi2(uufJlN2ryDb47FF5PWvpnI9WXOrtmeKyykUGOfO)bFQIeCmA0etX(YfkQedEAedOXGJF(fdiIXZXG)y4G)UDXOTx4khqJL9L1cusw2gdeXOrtmeKyyQIXLt7iSUa89VV8u4ksWXOrtmCWF3Uy02lCLdOXY(YAbkjlBJbpX0KQU5egkR63OcqpfPb9Rsfa4E1)Q(tJypC17QUJYKtzwvNGedtXfeTa9p4tv0xmwYJbsX0KyWFmTo4yWFmeKyykUGOfO)bFQIlMd6QU5egkR6oGgl7lRfOKSSTkvaasx9VQ)0i2dx9UQ7Om5uMv1jiXWuR5H15K02RibhJVy4G)UDXOTx4khqJL9L1cusw2gdKIXZX4lgqJrRyeBFkkUGOL(3xEk2QEAe7HJrJMy4cIw6FF5PyRcgbygdeX4lgyKOWwR8ohiYbTsyoOzzBv3CcdLv918W6eKuUuLkaGSR(x1FAe7HREx1DuMCkZQ6CWF3Uy02lCLdOXY(YAbkjlBJbsX45y8fJwXqqIHPmU7jSLURibx1nNWqzvN5ogjv7QubaKP6Fv)PrShU6Dv3rzYPmRQZb)D7IrBVWvoGgl7lRfOKSSngifJNJXxmeKyykM7yKuTvKGJXxmAfdbjgMY4UNWw6UIeCv3CcdLvDmkIlDoqKd6Qubao(v9VQ)0i2dx9UQ7Om5uMv1fBFkQVV8uSTtSgxupnI9WX4lgo4VBxmA7fUYb0yzFzTaLKLTXaPy8Cm(Ib0y0kgX2NIIliAP)9LNITQNgXE4y0OjgUGOL(3xEk2QGraMXarv3CcdLv9VV8uSTtSgxQsfa4Gt1)Q(tJypC17QUJYKtzwvxS9POmU7jSLUREAe7HR6MtyOSQVMhwN4wPkvaGdER(x1nNWqzv3b0yzFzTaLKLTv9NgXE4Q3vPcaCAs1)Q(tJypC17QUJYKtzwvxS9POmU7jSLUREAe7HR6MtyOSQVMhwNGKYLQEb5blBR64uLkaWXZv)R6pnI9WvVR6oktoLzvD6XONd0i2x1nNWqzvhBTY7CGih0v9cYdw2w1XPkvaGdUQ(x1lipyzBvhNQU5egkR6yuex6CGih0v9NgXE4Q3vPkvD4JzKRu9VcaCQ(x1FAe7HRevDhLjNYSQUHVNYKRS0DUqTTtphLw6U6PrShUQBoHHYQoXIqWljxQsfa4T6Fv)PrShU6Dv3rzYPmRQFih8DYH7ouHWK((SvagdiIryLhdKIPj(fJgnXGXOV)9LNITksWXOrtmCbrl9VV8uSvrcUQBoHHYQoyKWqzvQaOjv)R6MtyOSQdilH7CG3Ov9NgXE4Q3vPcapx9VQ)0i2dx9UQ7Om5uMv1fBFkkbjV0lgxovB1tJypCm(IHGedtrphLw6ExqYlk6lgl5XaPyWBv3CcdLvDbjV0lgxov7QubaUQ(x1FAe7HREx1DuMCkZQ6AfJy7trXfeT0)(YtXw1tJypCv3CcdLvDmg99VV8uSTkvaG7v)R6pnI9WvVR6oktoLzvDX2NIIliAP)9LNITQNgXE4y8fdOXOvmITpffZDmsQ2QNgXE4y0OjgTIHGedtXChJKQTIeCm(IrRyCi0cJamvm3XiPARibhdeX4lgqJrRyeBFkkJ7EcBP7QNgXE4y0OjgTIXHqlmcWuzC3tylDxrcogiQ6MtyOSQZfeT0)(YtX2QubaiD1)Q(tJypC17QUJYKtzwvxRyeBFkkWuwX2(3xEk2Y4I6PrShognAIrS9POatzfB7FF5PylJlQNgXE4y8fdOXGXOV)9LNITkyeGzm(IrRyeBFkkUGOL(3xEk2QEAe7HJrJMy4cIw6FF5PyRcgbygJVyeBFkkUGOL(3xEk2QEAe7HJbIQU5egkR63OcW(3xEk2wLkaGSR(x1nNWqzvNK)otEHx1FAe7HRExLkaGmv)R6MtyOSQ7qP7Pqn5WDS1kVQ)0i2dx9UkvaGJFv)R6MtyOSQtSieChH1fGV)8fTR6pnI9WvVRsfa4Gt1)QU5egkR6TKgfMzzhH1n89uKaSQ)0i2dx9UkvaGdER(x1nNWqzvhd5i5hUB47Pm5DIBLQ(tJypC17QubaonP6Fv3CcdLvDWKugM2SSTtSgxQ6pnI9WvVRsfa445Q)vDZjmuw1fGVtMeiYeUJHOUx1FAe7HRExLkaWbxv)R6MtyOSQxEbr1UJW6lPJb3HP3k8Q(tJypC17Qubao4E1)QU5egkR6ugyW77SSZbBUx1FAe7HRExLkaWbKU6Fv3CcdLvDar0f2JZYo9CuAP7v9NgXE4Q3vPcaCGSR(x1FAe7HREx1DuMCkZQ6AfJy7trzC3tylDx90i2dhJgnXqqIHPmU7jSLURibhJgnX4qOfgbyQmU7jSLUROVySKhdEIbx(v1nNWqzvNyri4ogjv7QubaoqMQ)v9NgXE4Q3vDhLjNYSQUwXi2(uug39e2s3vpnI9WXOrtmeKyykJ7EcBP7ksWvDZjmuw1joLFk0SSTkvaGx)Q(x1FAe7HREx1DuMCkZQ6AfJy7trzC3tylDx90i2dhJgnXqqIHPmU7jSLURibhJgnX4qOfgbyQmU7jSLUROVySKhdEIbx(v1nNWqzvhJrpXIqWvPca8It1)Q(tJypC17QUJYKtzwvxRyeBFkkJ7EcBP7QNgXE4y0OjgcsmmLXDpHT0Dfj4y0OjghcTWiatLXDpHT0Df9fJL8yWtm4YVQU5egkR6w6oxO22D2UvPca8I3Q)v9NgXE4Q3vDhLjNYSQoxq0s)7lpfBvKGJXxmeKyykNTBFzTaLKLTk6lgl5XGNgXazx1nNWqzv)A)ocRlaFNliAPkvaG3Mu9VQBoHHYQE5Yr0Q(tJypC17QubaE9C1)Q(tJypC17QUJYKtzwv3CcZJ3F(c78yWtm4kgFXaAmCWF3Uy02lCLdOXY(YAbkjlBJbpXGRy0Ojgo4VBxmA7fUAnpSoXTsm4jgCfdevDZjmuw1PKz3CcdL9LXLQ(Y4spTYR6g6vPca8IRQ)v9NgXE4Q3vDZjmuw1PKz3CcdL9LXLQ(Y4spTYR6Cw2UVlgT9svQsvhm9ouHWKQ)vaGt1)Q(tJypC17QubaER(x1FAe7HRExLkaAs1)Q(tJypC17QubGNR(x1FAe7HRExLkaWv1)QU5egkR6csEPxmUCQ2v9NgXE4Q3vPcaCV6Fv)PrShU6Dv3rzYPmRQl2(uuCbrlq)d(u1tJypCm(Ib0yOgdUFpEkkdgMRCiYuIbsX0Ky0OjgQXG73JNIYGH5kwgdEIbx(fdevDZjmuw15cIwG(h8PvPcaq6Q)v9NgXE4Q3vDhLjNYSQUwXi2(uuCbrl9VV8uSv90i2dx1nNWqzvhJrF)7lpfBRsfaq2v)R6pnI9WvVR6oktoLzvDX2NIIliAP)9LNITQNgXE4QU5egkR6Cbrl9VV8uSTkvaazQ(x1nNWqzvhmsyOSQ)0i2dx9UkvaGJFv)R6pnI9WvVR6oktoLzvDX2NI67lpfB7eRXf1tJypCv3CcdLv9VV8uSTtSgxQsfa4Gt1)Q(tJypC17QUJYKtzwvxRyeBFkQVV8uSTtSgxupnI9WvDZjmuw1xZdRtqs5svQaah8w9VQ)0i2dx9UQ7Om5uMv1fBFkQVV8uSTtSgxupnI9WvDZjmuw1)(YtX2oXACPkvaGttQ(x1FAe7HREx1DuMCkZQ6AfJy7trXfeTa9p4tvpnI9WX4lgo4VBxmA7fEm4jgqJbV(fJxXy47Pm5kwBEejVdgjpfMTkQLqhdEIXVyGOQBoHHYQUdOXY(YAbkjlBRsvQsvhqJMSSLx19elGru5WX45ymNWqzmlJlCvavvNd(UkaWlUJ3QoykcJTVQdYX009LNITXOd0kwgdO4gKz(LLTqeqbYXaueWCpTMBULjajjuouPzoRqUMWqPJAysZCwX1CafihduK5JbV4cGXGx)WbYediIXpiJNgUWBavafihttH87iLdhdXXq0hJdvimjgI3YsUkgpDN7GfEmjkbbqJwWi3ymNWqjpguUARcOmNWqjxbMEhQqysdS14qhqzoHHsUcm9ouHWeVA0mgcbhqzoHHsUcm9ouHWeVA0Sr2wEkMWqzafihJEAG5arsmuJbhdbjg2HJHlMWJH4yi6JXHkeMedXBzjpglHJbm9Gamsew2gdJhdmkVkGYCcdLCfy6DOcHjE1OzEAG5arsNlMWdOmNWqjxbMEhQqyIxnAwqYl9IXLt1oGcKJXCcdLCfy6DOcHjE1O5Buby)7lpfBbidRHwITpffykRyB)7lpfBzCr90i2dhqbYXazXFm6cIwG(h8PXaMEhQqysmK5EopgoQ8ymyyEmaY2ngoydWmgocLQakZjmuYvGP3HkeM4vJM5cIwG(h8PaKH1qS9PO4cIwG(h8PQNgXEyFGsngC)E8uugmmx5qKPaPMOrd1yW97XtrzWWCflXdU8dIakZjmuYvGP3HkeM4vJMXy03)(YtXwaYWAOLy7trXfeT0)(YtXw1tJypCaL5egk5kW07qfct8QrZCbrl9VV8uSfGmSgITpffxq0s)7lpfBvpnI9WbuMtyOKRatVdvimXRgndgjmugqzoHHsUcm9ouHWeVA083xEk22jwJlaKH1qS9PO((YtX2oXACr90i2dhqzoHHsUcm9ouHWeVA08AEyDcskxaidRHwITpf13xEk22jwJlQNgXE4akZjmuYvGP3HkeM4vJM)(YtX2oXACbGmSgITpf13xEk22jwJlQNgXE4akZjmuYvGP3HkeM4vJMDanw2xwlqjzzlazyn0sS9PO4cIwG(h8PQNgXEyFCWF3Uy02lC8akE9ZldFpLjxXAZJi5DWi5PWSvrTeA84hebuXeqbYX0ui)os5WXCpov7yew5XiaFmMtq0yy8ympm2Ae7vbuGCm4MmUeJ3lcbVKCjMILK2UAhddlgb4JXthFpLjpg)PgtIXtpDNluBJXt45O0s3JHXJbm98NIkGYCcdL8gelcbVKCbGmSgg(EktUYs35c12o9CuAP7QNgXE4aQakqogpXeeouHWKyaJegkJHXJbm9yN(uy2UAhZYsOpCmckgTrK0yA6(YtXwagdzUNZJXHkeMedGSDJ5jCmCGiQSAhqzoHHsUxnAgmsyOeGmSghYbFNC4UdvimPVpBfGGqyLdPM4Ngnym67FF5PyRIeSgnCbrl9VV8uSvrcoGkGcKJXtmLtPKGLyqyX4mUWvbuMtyOK7vJMbKLWDoWB0akZjmuY9QrZcsEPxmUCQ2aKH1qS9POeK8sVyC5uTvpnI9W(iiXWu0ZrPLU3fK8II(IXsoKWBaL5egk5E1Ozmg99VV8uSfGmSgAj2(uuCbrl9VV8uSv90i2dhqzoHHsUxnAMliAP)9LNITaKH1qS9PO4cIw6FF5PyR6PrSh2hOAj2(uum3XiPAREAe7H1OrlcsmmfZDmsQ2ksW(0YHqlmcWuXChJKQTIeme(avlX2NIY4UNWw6U6PrShwJgTCi0cJamvg39e2s3vKGHiGYCcdLCVA08nQaS)9LNITaKH1qlX2NIcmLvST)9LNITmUOEAe7H1OrS9POatzfB7FF5PylJlQNgXEyFGIXOV)9LNITkyeGPpTeBFkkUGOL(3xEk2QEAe7H1OHliAP)9LNITkyeGPpX2NIIliAP)9LNITQNgXEyicOmNWqj3RgntYFNjVWdOmNWqj3Rgn7qP7Pqn5WDS1kpGYCcdLCVA0mXIqWDewxa((Zx0oGYCcdLCVA0ClPrHzw2ryDdFpfjadOmNWqj3RgnJHCK8d3n89uM8oXTsaL5egk5E1OzWKugM2SSTtSgxcOmNWqj3RgnlaFNmjqKjChdrDpGYCcdLCVA0C5fev7ocRVKogChMERWdOmNWqj3RgntzGbVVZYohS5EaL5egk5E1Ozar0f2JZYo9CuAP7buMtyOK7vJMjwecUJrs1gGmSgAj2(uug39e2s3vpnI9WA0qqIHPmU7jSLURibRrJdHwyeGPY4UNWw6UI(IXsoEWLFbuMtyOK7vJMjoLFk0SSfGmSgAj2(uug39e2s3vpnI9WA0qqIHPmU7jSLURibhqzoHHsUxnAgJrpXIqWaKH1qlX2NIY4UNWw6U6PrShwJgcsmmLXDpHT0DfjynACi0cJamvg39e2s3v0xmwYXdU8lGYCcdLCVA0SLUZfQTDNTlazyn0sS9POmU7jSLUREAe7H1OHGedtzC3tylDxrcwJghcTWiatLXDpHT0Df9fJLC8Gl)cOmNWqj3RgnFTFhH1fGVZfeTaqgwdUGOL(3xEk2Qib7JGedt5SD7lRfOKSSvrFXyjhpnGSdOmNWqj3RgnxUCenGYCcdLCVA0mLm7MtyOSVmUaW0kVHHoazynmNW849NVWohp4YhOCWF3Uy02lCLdOXY(YAbkjlBXdU0OHd(72fJ2EHRwZdRtCRGhCbraL5egk5E1Ozkz2nNWqzFzCbGPvEdolB33fJ2EjGkMakqog8b5kSyeJ2EjgZjmugdykdrzI2XSmUeqzoHHsUYqVbxq0c0)GpfGmSgITpffxq0c0)Gpv90i2dhqfqbYXOdMEdogCJ1kpgDGih0XWYyGuJy8CmIrBVedgRfOWbymeKsmjsIbMKYY2y0BAmKGfw5aKm3Z5XOnI0tsFmySwGclBJPjXigT9cpglHJbO5XJzpNhJa0YyWXZXasMLWXGBMKlXWfZbnxfqzoHHsUYq3RgnJTw5DoqKdAa602TVlgT9cVboaKH1GEm65anI9(aLd(72fJ2EHRCanw2xwlqjzzlKafxGqlX2NIsqYl9IXLt1w90i2ddHgnAj2(uuCbrl9VV8uSv90i2d7duhcTWiatfgJ((3xEk2QOVySKJhqXbV(5foEg)CWF3oqJlhcnACi0cJamvym67FF5PyRI(IXsoKafVEge44z8Zb)D7anUCiGacFGQLy7trXfeT0)(YtXw1tJypSgnCbrl9VV8uSvbJam1OHd(72fJ2EHRCanw2xwlqjzzBJM4JGedtbilH7TKCrXfZbnKWXZqeqzoHHsUYq3RgnBC3tylDhGmSgITpfLXDpHT0D1tJypSpqfBFkkUGOL(3xEk2QEAe7H9XfeT0)(YtXwfmcW0NdHwyeGPIliAP)9LNITk6lgl54bhCPrJwITpffxq0s)7lpfBvpnI9Wq4duTeBFkkM7yKuTvpnI9WA0OfbjgMI5ogjvBfjyFA5qOfgbyQyUJrs1wrcgIakZjmuYvg6E1O5L5PizW9I1wSUGKxaidRHy7trTmpfjdUxS2I1fK8I6PrShoGkGcKJXFQ2XiOyATYJPPgva6PinOFmaYeGXGpmUCAmiSyeGpMMUV8u4XqqIHfdGaFgdgRfOWY2yAsmIrBVWvXasHspPedYJtDg4yWh2xUqrfTcOmNWqjxzO7vJMVrfGEksd6dqgwdTeBFkQIXLt7iSUa89VV8u4QNgXEynAiiXWuCbrlq)d(ufjynAk2xUqrf80auC8Zpq4z8Zb)D7IrBVWvoGgl7lRfOKSSfcnAiiXWufJlN2ryDb47FF5PWvKG1OHd(72fJ2EHRCanw2xwlqjzzlEAsavafihd(WG(XWjPpgTrKXaJspPeZI4pglgDbrlq)d(uvaL5egk5kdDVA0SdOXY(YAbkjlBbidRbbjgMIliAb6FWNQOVySKdPMG)whm(jiXWuCbrlq)d(ufxmh0bubuGCmEcYv7yCgxIbKW8WIXBskxIbLXiaP)XigT9cpggwmmjggpglJHLCXsjglHJrxq0smnDF5PyBmmEmaWtG)XyoH5XvbuMtyOKRm09QrZR5H1jiPCbGmSgeKyyQ18W6CsA7vKG9Xb)D7IrBVWvoGgl7lRfOKSSfsE2hOAj2(uuCbrl9VV8uSv90i2dRrdxq0s)7lpfBvWiati8bJef2AL35aroOvcZbnlBdOmNWqjxzO7vJMzUJrs1gGmSgCWF3Uy02lCLdOXY(YAbkjlBHKN9PfbjgMY4UNWw6UIeCaL5egk5kdDVA0mgfXLohiYbnazyn4G)UDXOTx4khqJL9L1cusw2cjp7JGedtXChJKQTIeSpTiiXWug39e2s3vKGdOcOa5yGS4pMMUV8uSngVxJlXyTgl5smKGJrqX0KyeJ2EHhJXJzrzBmgpgDbrlX009LNITXW4XKijgZjmpUkGYCcdLCLHUxnA(7lpfB7eRXfaYWAi2(uuFF5PyBNynUOEAe7H9Xb)D7IrBVWvoGgl7lRfOKSSfsE2hOAj2(uuCbrl9VV8uSv90i2dRrdxq0s)7lpfBvWiaticOmNWqjxzO7vJMxZdRtCRaqgwdX2NIY4UNWw6U6PrShoGYCcdLCLHUxnA2b0yzFzTaLKLTbuMtyOKRm09QrZR5H1jiPCbGfKhSSTboaKH1qS9POmU7jSLUREAe7HdOmNWqjxzO7vJMXwR8ohiYbnalipyzBdCaOy02lDgwd6XONd0i2hqzoHHsUYq3RgnJrrCPZbICqdWcYdw22aNaQycOa5y0zz7(y83OTxIXt3jmugd(KYquMODmGemUeqbYX00KtsFm4g6XW4XyoH5XJHm3Z5XOnImgGMhpgC8CmiAmfe9XWfZbnpgewmGKzjCm4Mj5smyuujgDbrlX009LNITQyaTPWTpgNXVNwmKGDOclBJXtN7IHGuIXCcZJhJEtbjvmWO0tkXaraL5egk5kolB33fJ2EPb2AL35aroObOy02lDgwdq1syoOzzRgnITpffxq0s)7lpfBvpnI9W(Ci0cJamvCbrl9VV8uSvrFXyjhs4f)ToynAGrIcBTY7CGih0k6lgl5qQrRdwJgX2NIY4UNWw6U6PrSh2hmsuyRvENde5GwrFXyjhsG6qOfgbyQmU7jSLUROVySK7fbjgMY4UNWw6UcMKAcdLq4ZHqlmcWuzC3tylDxrFXyjhsE2hOAj2(uuCbrl9VV8uSv90i2dRrJy7trXfeT0)(YtXw1tJypSpUGOL(3xEk2QGraMqaHpqjiXWuaYs4EljxuCXCqdjC8Sgng(EktUI1MhrY7GrYtHzRIAj04PbE1OHGedtTMhwNtsBVIeSgnArqIHPiwecEj5IIeme(0IGedtXjPTVJW6GraEQIeCavafihdKf)X4PZDpHT09ymm50y0gr6j94XWb)uIX2ngqcZdlgVjPCjghqJ2EEmwchdkxTJHHftEMa80y0feTett3xEk2gtIOX4j6ogjv7ym6JXrsPpLv7ymNW84QakZjmuYvCw2UVlgT9IxnA24UNWw6oazyneBFkkJ7EcBP7QNgXEyFoeAHraMQ18W6eKuUOOVySKJh)8bkxq0s)7lpfBvWiatnA0sS9PO4cIw6FF5PyR6PrShgcFGQLy7trXChJKQT6PrShwJgTiiXWum3XiPARib7tlhcTWiatfZDmsQ2ksWqeqfqbYXasHspPedj)X009LNITX49ACjggwmAJiJXHix4yCgxIXIbFyC50yqyXiaFmnDF5PWJ5fWiap9WX0uJkaJrhiYbDmSKl3GvXasHspPeJZ4smnDF5PyBmEVgxIbMKYY2y0feTett3xEk2gdzUNZJrBezmanpEmnbYJbaMqsTngqsB0ck1ogwgdGazoGX4m(JrBezmCbbogsolBJPP7lpfBJX714smO09y0grgd9Mdym445y4I5GMhdclgqYSeogCZKCrfqzoHHsUIZY29DXOTx8QrZFF5PyBNynUaqgwdX2NI67lpfB7eRXf1tJypSpqfBFkQIXLt7iSUa89VV8u4QNgXEyFeKyyQIXLt7iSUa89VV8u4ksW(k2xUqrfiH7(PrJwITpfvX4YPDewxa((3xEkC1tJypme(avlq5cIw6FF5PyRIeSpX2NIIliAP)9LNITQNgXEyi0OXW3tzYvPjKuB7anAbLAROwcDJM4JGedtbilH7TKCrXfZbnKWXZqeqfqbYXasYp4y0bjjgmenM1OTpgengocLXyWWXaO5X5QyGSY9CEmAJiJbO5XJrNK2(yqyXGpraEkaJHLXaiqMdymoJ)y0grgdGwkXiOyGrKe7JHGedlgqcwlqjzzBmEJwjgcTJbmcTSSng8H9LluujgIJHOhOLWQyAkKBfW7JHFpf5t390Ibh)8dFOdWyAQoaJrhKeagdiH3amgqcp8gGX0uDagdiH3buMtyOKR4SSDFxmA7fVA0mxq0c0)GpfGmSgITpffxq0c0)Gpv90i2d7duQXG73JNIYGH5khImfi1enAOgdUFpEkkdgMRyjEWLFq4duTeBFkkojT9DewhmcWtvpnI9WA0qqIHP4K023ryDWiapvrcwJMI9Lluubpn8SNHiGYCcdLCfNLT77IrBV4vJMxMNIKb3lwBX6csEbGmSgITpf1Y8uKm4EXAlwxqYlQNgXEyFGsngC)E8uugmmx5qKPaPMOrd1yW97XtrzWWCflXdU8dIaQakqogCtOcblFm6cIwG(h8PXaitagd(W4YPXGWIra(yA6(YtHhdIgJojT9XGWIbFIa8uvaL5egk5kolB33fJ2EXRgnVSwGsYY2obAfaYWAqqIHP4cIwG(h8PksW(4G)UDXOTx4khqJL9L1cusw2cjC3hOg(EktUAnpSohiYbTIAj04NGedtTMhwNde5GwXfZbneqQj4UpqjiXWufJlN2ryDb47FF5PWvKG9PLy7trXjPTVJW6GraEQ6PrShwJgcsmmfNK2(ocRdgb4PksWqeqfqbYX4pWtFmfwlqjghQ8ySmgsWWM8yWq0yeGmEmllFmaYeGXWrLhJocFgZIAzovafihJ5egk5kolB33fJ2EXRgnFJka9uKg0hGmSgGYb)D7IrBVWvoGgl7lRfOKSSfp44ZW3tzYvR5H15aroOvulHg)eKyyQ18W6CGih0kUyoOHutWDi8bQwITpffNK2(ocRdgb4PQNgXEynA0cgjkS1kVZbICqROhJEoqJyVgnCbrl9VV8uSvrcgcFGQLy7trvmUCAhH1fGV)9LNcx90i2dRrdbjgMQyC50ocRlaF)7lpfUIeSgnf7lxOOcEAazWlebuGCmEJ0wPuac0KySyCOeMjmuQIbKmtagd(W4YPXGWIra(yA6(YtHhdyeAJbFyF5cfvIHeCmckgi7yWh2xUqrLyi(Iamgb4JXzGJrqX8KtsFmmXtYJHKF4yaKjaJPPgvagJoqKdAvmGKzcqePed(W4YPXGWIra(yA6(YtHdWyi5pMMAubym6aroOJ5mb4PXWWIrxq0c0)GpnggpgsWamg8H9LluujggpgC8lg8H9LluujgIViaJra(yCg4yq0y2Z5amgenMZeGNgJUGOLyA6(YtX2yy80tkXi2(uoCmiAmmXtYJjrsmMtyE8ySeogTrK0ywJlXOliAjMMUV8uSngewmcWhdgRfOedGSDJbO5XJbLR2XyXa2OcZ2yGjPMWqPkGYCcdLCfNLT77IrBV4vJMVrfGDoqKdAaYWAOfbjgMItsBFhH1bJa8ufjyFITpfvX4YPDewxa((3xEkC1tJypSpqjiXWufJlN2ryDb47FF5PWvKG1OXHqlmcWuTMhwNGKYff9fJLC84NVI9LluubpnGm41RM4h(fBFkkNTBxa(UaKmHpv90i2dRrdOg(EktUAnpSohiYbTIAj04NGedtTMhwNde5GwXfZbnKAcUdHpcsmmfxq0c0)Gpvrc2NdHwyeGPAnpSobjLlk6lgl5qQrRdgcnA0sS9POkgxoTJW6cW3)(YtHREAe7H9PfOg(EktUI1MhrY7GrYtHzRIAj04bV(iiXWug39e2s3vKGHWhOeKyykUGOfO)bFQIeSgnf7lxOOcEAaz8ZRM4h(fBFkkNTBxa(UaKmHpv90i2dRrJwGYfeT0)(YtXwfjyFITpffxq0s)7lpfBvpnI9Wq47qo47Kd3DOcHj99zRaeecRCq4qOfgbyQ4cIw6FF5PyRI(IXsoiWbx(HFSfHOGc6HCW3jhU7qfct67Zwbiiew5GWHqlmcWuXfeT0)(YtXwf9fJLCiWT4Gl)GapnAIF4huC8cudFpLjxDhquhH1fGV)9LNITCf1sOXtd8cbeqeqfqbYXazXFmn1OcWy0bICqhddlgDsA7JbHfd(eb4PXW4Xi2(uomaJHGuIjptaEAmmjMerJXIbKcFQhtt3xEk2gdJhJ5eMhpgtIra(ykOYtbGXyjCmGeMhwmEts5smmEm0BWAhdIgdGSDJH4XaitaYYyeGpM8qUedUzCtGuQakZjmuYvCw2UVlgT9IxnA(gva25aroObidRHy7trXjPTVJW6GraEQ6PrSh2NweKyykojT9DewhmcWtvKG95qOfgbyQwZdRtqs5II(IXsoKA06G9bQwITpffxq0s)7lpfBvpnI9W(0cumg99VV8uSvrcgcnAeBFkkUGOL(3xEk2QEAe7H9PfOCbrl9VV8uSvrcgcicOcOa5yWnzCjgqcwlqjzzBmEJwHhdmjLLTXOliAjMMUV8uSngysQjmuQcOmNWqjxXzz7(Uy02lE1O5L1cusw22jqRaqgwdUGOL(3xEk2Qib7tS9PO4cIw6FF5PyR6PrSh2hOg(EktUI1MhrY7GrYtHzRIAj0qcVA0OfbjgMAnpSoNK2EfjyFeKyykIfHGxsUOibdravafihdKf)XGBqrCjgDGih0XaitagJNO7yKuTJXs4yWhgxongewmcWhtt3xEkCvaL5egk5kolB33fJ2EXRgnJrrCPZbICqdqgwdX2NII5ogjvB1tJypSpX2NIQyC50ocRlaF)7lpfU6PrSh2hbjgMI5ogjvBfjyFeKyyQIXLt7iSUa89VV8u4ksWbuMtyOKR4SSDFxmA7fVA08AEyDcskxaidRbbjgMY4UNWw6UIeCavafihdKLWwg((y0jPTpgewm4teGNgJGIHdMEdogCJ1kpgDGih0XWWIPqUcd8(yE(c78ym6Jbm98NIkGYCcdLCfNLT77IrBV4vJMXwR8ohiYbnafJ2EPZWAqpg9CGgXEFMtyE8(ZxyNJhC8rqIHP4K023ryDWiapvrcoGkGcKJbYI)yajmpSy8MKYLyaKjaJrNK2(yqyXGpraEAmmSyeGpM14smGrYtHzBmKCR9XGWIXIbKcFQhtt3xEk2gdqJNEsjglgmYDJbMKAcdLX4jWtymmSy0grgJdrUWX0EjglrcWtJHKBTpgewmcWhdif(upMMUV8uSnggwmcWhd9fJLSSngmwlqjganEm4G742ywu2EQkGYCcdLCfNLT77IrBV4vJMxZdRtqs5cazyneBFkkUGOL(3xEk2QEAe7H95qOfgby2P3CIpcsmmfNK2(ocRdgb4PksW(a9qo47Kd3DOcHj99zRaeecRCq4qOfgbyQ4cIw6FF5PyRI(IXsoiWbx(HFSfHOGc6HCW3jhU7qfct67Zwbiiew5GWHqlmcWuXfeT0)(YtXwf9fJLCiWT4Gl)GasnXp8dkoEbQHVNYKRUdiQJW6cW3)(YtXwUIAj04PbEHacnAafhfo4o(b9qo47Kd3DOcHj99zRaeecRCiaHdHwyeGPIliAP)9LNITk6lgl5GahC5h(XweIckO4OWb3XpOhYbFNC4UdvimPVpBfGGqyLdbiCi0cJamvCbrl9VV8uSvrFXyjhcClo4YpiGasGEih8DYH7ouHWK((SvaccHvoiCi0cJamvCbrl9VV8uSvrFXyjhe4Gl)Wp2Iquqb9qo47Kd3DOcHj99zRaeecRCq4qOfgbyQ4cIw6FF5PyRI(IXsoe4wCWLFqabebubuGCmqw8hdiH5HfJ3KuUedGmbym6K02hdclg8jcWtJHHfJa8XSgxIbmsEkmBJHKBTpgewmwmGu4t9yA6(YtX2yaA80tkXyXGrUBmWKutyOmgpbEcJHHfJ2iYyCiYfoM2lXyjsaEAmKCR9XGWIra(yaPWN6X009LNITXWWIra(yOVySKLTXGXAbkXaOXJbhCh3gZIY2tvbuMtyOKR4SSDFxmA7fVA08AEyDcskxaidRHwITpffxq0s)7lpfBvpnI9W(Ci0cJam70BoXhbjgMItsBFhH1bJa8ufjyFGEih8DYH7ouHWK((SvaccHvoiCi0cJamvym67FF5PyRI(IXsoiWbx(HFSfHOGc6HCW3jhU7qfct67Zwbiiew5GWHqlmcWuHXOV)9LNITk6lgl5qGBXbx(bbKAIF4huC8cudFpLjxDhquhH1fGV)9LNITCf1sOXtd8cbeA0akokCWD8d6HCW3jhU7qfct67Zwbiiew5qachcTWiatfgJ((3xEk2QOVySKdcCWLF4hBrikOGIJchCh)GEih8DYH7ouHWK((SvaccHvoeGWHqlmcWuHXOV)9LNITk6lgl5qGBXbx(bbeqc0d5GVtoC3HkeM03NTcqqiSYbHdHwyeGPcJrF)7lpfBv0xmwYbbo4Yp8JTiefuqpKd(o5WDhQqysFF2kabHWkheoeAHraMkmg99VV8uSvrFXyjhcClo4YpiGaIakZjmuYvCw2UVlgT9IxnAEzTaLKLTDc0kaKH1GGedtXjPTVJW6GraEQIeCaL5egk5kolB33fJ2EXRgnVMhwNGKYfaYWA4qOfgby2P3CIpTeBFkQIXLt7iSUa89VV8u4QNgXE4akZjmuYvCw2UVlgT9IxnAM5ogjvBaYWAi2(uum3XiPAREAe7H9PfOf7lxOOcEaPXLphcTWiat1AEyDcskxu0xmwYHud)GWhOAj2(uuCbrl9VV8uSv90i2dRrdxq0s)7lpfBvWiaticOmNWqjxXzz7(Uy02lE1O518W6eKuUaqgwdhcTWiaZo9Mt85aA02ZXJy7trDhquhH1fGV)9LNcx90i2dhqzoHHsUIZY29DXOTx8QrZyuex6CGih0aKH1qS9POyUJrs1w90i2d7JGedtXChJKQTIeSpcsmmfZDmsQ2k6lgl5qchfo4V1bJFcsmmfZDmsQ2kUyoOdOmNWqjxXzz7(Uy02lE1O518W6eKuUaqgwdhcTWiaZo9MtcOcOa5yaPqPNuIXCog8tX2v7yi5pgDsA7JbHfd(eb4PXaitagdUXALhJoqKd6yGjPSSngolB3hJy02lQakZjmuYvCw2UVlgT9IxnAgBTY7CGih0aumA7LodRb9y0ZbAe79PfbjgMItsBFhH1bJa8ufj4akZjmuYvCw2UVlgT9IxnAwqYl9IXLt1gGmSgITpfLGKx6fJlNQT6PrSh2hOeKyyk65O0s37csErrFXyjhs4UgnGsqIHPONJslDVli5ff9fJLCibkbjgMY4UNWw6UcMKAcdLE5qOfgbyQmU7jSLUROVySKdHphcTWiatLXDpHT0Df9fJLCiHdUGaIaQakqog9L1cuwTJP1kpgpr3XiPAhdbjgwmckgGiWhJCxTJHGedlgoQ8yaKjaJbFyC50yqyXiaFmnDF5PWvbuMtyOKR4SSDFxmA7fVA0mgfXLohiYbnazyneBFkkM7yKuTvpnI9W(iiXWum3XiPARib7ducsmmfZDmsQ2k6lgl5qQ1bJFpJFcsmmfZDmsQ2kUyoO1OHGedtXfeTa9p4tvKG1OrlX2NIQyC50ocRlaF)7lpfU6PrShgIakZjmuYvCw2UVlgT9IxnAEzTaLKLTDc0kbuMtyOKR4SSDFxmA7fVA0m2AL35aroObyb5blBBGdafJ2EPZWAqpg9CGgX(akZjmuYvCw2UVlgT9IxnAgBTY7CGih0aSG8GLTnWbGmSgfKhV8uuWmUyP74b3dOcOa5yWnOiUeJoqKd6yy8yqK0ykipE5PedgB3tvbuMtyOKR4SSDFxmA7fVA0mgfXLohiYbnalipyzBdCQsvQva]] )

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
