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
            cooldown = 150,
            recharge = 150,
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
            cooldown = 150,
            recharge = 150,
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


    spec:RegisterPack( "Elemental", 20190402.1014, [[defxYbqiHWJes1LifKnjL8jHizuGuNcQyvqv6vkfnlPuULcQDrYVukzykihtPQLbvQNjK00es5AcrTnHi(gPqyCqLOohPawhuj07ukiL5PuP7Pa7dQI)rkeHdskKwOuQEOsb1evkGlkKyJqLiFeQe0ivkivNuPaTsqYljfIAMkfYnvku7uPu)uPGyOKc0sHkbEkPAQkvCvHi1xvkizSKcr6SKcr0EvYFv0GfDyklgPESGjdLlRAZG6Zc1OLItJYRviZg42s1UL8BidhehNuqTCephvtN46iz7qv9DfQXdvsNNu06jfQ5tkTFQETFTZshZKV2g3dTxdmu0gc3Q9dTpArfxEPlAc5lDiwyKf)LEz9V0Jc49xIbw6qmnbidBTZsNJOiHV0BebchxCRTIzsdfTkG6BXzDkGjmufigSSfN1dBT0PPyazdwl6LoMjFTnUhAVgyOOneUv7hAF0I6sNd5H124osW9sVHHH9ArV0XopS0JUNrb8(lXaEQ3yDRCOIUNnIaHJlU1wXmPHIwfq9T4SofWegQcedw2IZ6HTCOIUNAuiegWtC3MN4EO9Aaph2Z9dHlUpAEQr3yhkhQO75gUXQ4ZXfDOIUNd7zKMFp1iDEW7VedOOG4jXKMt8uASYZqZdJyvSNbecGHgxCpfKN8FpzWEEW7VedW90i3tlim8VYHk6EoSNBag3ObhZZOyePXZOaE)LyapFje25khQO75WEIl4De(3tnkp8cZQW9uy9Vv7BKNHMhgPCOIUNd7PgfdZZOO59eb7P0Cp1feP75wEUXxoIOw6qiiyg4l9O7zuaV)smGN6nw3khQO7zJiq44IBTvmtAOOvbuFloRtbmHHQaXGLT4SEylhQO7PgfcHb8e3T5jUhAVgWZH9C)q4I7JMNA0n2HYHk6EUHBSk(CCrhQO75WEgP53tnsNh8(lXakkiEsmP5epLgR8m08Wiwf7zaHayOXf3tb5j)3tgSNh8(lXaCpnY90ccd)RCOIUNd75gGXnAWX8mkgrA8mkG3FjgWZxcHDUYHk6EoSN4cEhH)9uJYdVWSkCpfw)B1(g5zO5HrkhQO75WEQrXW8mkAEprWEkn3tDbr6EULNB8LJikhkhQO7zuW1hOKJ5j9HrK7za1PnXt6hZkUYtnAiCic3Zcvd3yKomfWtlimuX9evanvouwqyOIRGqEa1PnzamW4JCOSGWqfxbH8aQtBYMd2cgHWCOSGWqfxbH8aQtBYMd2YOI7VetyOYHYHk6EQxgeEds8KymmpPPGHpMNCXeUN0hgrUNbuN2epPFmR4EAfMNqiFyiiryvSNmUNyO6khklimuXvqipG60MS5GT4LbH3GKjxmH7qzbHHkUcc5buN2KnhSLGK3NDJlNOPdv090ccdvCfeYdOoTjBoyRBePzEW7Ved0gdEqeIbEjkiew3aZdE)LyagxuVmAWXCOCOIUNrA(9uxqK(OFiN4jeYdOoTjEsvGZ5EYr97PHHX9Cmda8KdXgxEYrOs5qzbHHkUcc5buN2KnhSfxqK(OFiN0gdEGyGxIIlisF0pKtuVmAWXAbnXyyZJ)lrzyyCvarvYUrvRwIXWMh)xIYWW4kwHNipeoououwqyOIRGqEa1PnzZbBbZiFEW7Ved0gdEqeIbEjkUGi95bV)smG6LrdoMdLfegQ4kiKhqDAt2CWwCbr6ZdE)LyG2yWded8suCbr6ZdE)Lya1lJgCmhklimuXvqipG60MS5GTGGegQCOSGWqfxbH8aQtBYMd26G3FjgysdmU0gdEGyGxI6G3FjgysdmUOEz0GJ5qzbHHkUcc5buN2KnhSfWW3M0ueU0gdEqeIbEjQdE)LyGjnW4I6LrdowloKdatXiXx4QqJXQjGf3ifRI3nQouwqyOIRGqEa1PnzZbBfAmwnbS4gPyvCBm4bCihaMIrIVWvHgJvtalUrkwfJhC7q5qfDpJcU(aLCmpp(NOPNcRFpLM7PfeeXtg3tdFJbmAWvour3ZnSXfpBhGqyakU4z3kkda00tgSNsZ9uJQXNWK75oeJjEQrRW5cXaEIl4Cuzv4EY4EcHC(lr5qzbHHk(aAacHbO4sBm4bMgFctUYQW5cXatY5OYQWvVmAWXCOCOIUNBWA4aQtBINqqcdvEY4EcHC4tEjmda00taRgDmpfKNAIOiEgfW7Ved0MNuf4CUNbuN2ephZaapFH5jVbreGMouwqyOIV5GTGGegQAJbp44kKhKJndOoTjtWRyPzyH1)UrDiTAHzKpp49xIbuuq0QLlisFEW7VedOOG4q5qfDp3GLCcHcI4jc2ZGXfUYHYccdv8nhS1ywHn5n3iououwqyOIV5GTeK8(SBC5enBJbpqmWlrji59z34YjAQEz0GJ1IMcgwrohvwf(uqY7kY7gR47IBhklimuX3CWwWmYNh8(lXaTXGheHyGxIIlisFEW7VedOEz0GJ5qzbHHk(Md2IlisFEW7Ved0gdEGyGxIIlisFEW7VedOEz0GJ1c6ied8suSWHPiAQEz0GJPvBe0uWWkw4WuenvuqAfraHayOXLIfomfrtffeCAbDeIbEjkJhEHzv4Qxgn4yA1graHayOXLY4HxywfUIccoour3tlimuX3CWw3isZ8G3FjgOng8Gied8suqiSUbMh8(lXamUOEz0GJPvRyGxIccH1nW8G3FjgGXf1lJgCSwqdZiFEW7VedOWqJRwrig4LO4cI0Nh8(lXaQxgn4yA1YfePpp49xIbuyOXvlXaVefxqK(8G3Fjgq9YObhdhhklimuX3CWwu8pzY7ChklimuX3CWw0aecBctr0Sng8Gied8sugp8cZQWvVmAWX0QLMcgwz8WlmRcxrbrR2acbWqJlLXdVWSkCf5DJvC8e5HCOSGWqfFZbBrFc)KrSkUng8Gied8sugp8cZQWvVmAWX0QLMcgwz8WlmRcxrbXHYccdv8nhSfmJCAacH1gdEqeIbEjkJhEHzv4Qxgn4yA1stbdRmE4fMvHROGOvBaHayOXLY4HxywfUI8UXkoEI8qouwqyOIV5GTSkCUqmWmyaqBm4brig4LOmE4fMvHREz0GJPvlnfmSY4HxywfUIcIwTbecGHgxkJhEHzv4kY7gR44jYd5qzbHHk(Md26A(jcEknFYfeP3gdEaxqK(8G3FjgqrbPfnfmSkyaWeWIBKIvXkY7gR44zaUSdLfegQ4BoyR(LJiouwqyOIV5GTiu10ccdvtaJlTvw)dm0BJbpWccd)pF9o7C8G7wqZHCaykgj(cxfAmwnbS4gPyvmEWTwTCihaMIrIVWvadFBsFRJhCJJdLfegQ4BoylcvnTGWq1eW4sBL1)aoRIbFkgj(IdLdv09CJPacZtXiXx80ccdvEcHWqeMOPNagxCOSGWqfxzOpGlisF0pKtAJbpqmWlrXfePp6hYjQxgn4youour3tDiKByEIlbS(9uVbfg5jR8C3bEgnpfJeFXtywCJWBZtAkXZcjEIrryvSN6rXtkicR)2OkW5Cp1erfPi3tywCJWQypJQNIrIVW90kmpBm8VNGZ5Eknw55(O55gkwH5jUqkU4jxSWiUYHYccdvCLH(Md2cgy9p5nOWO2cAgaFkgj(cFW(2yWdihMCEJrdElO5qoamfJeFHRcngRMawCJuSkExOJ8Wrig4LOeK8(SBC5envVmAWXWrR2ied8suCbr6ZdE)Lya1lJgCSwqdZiFEW7VedOiVBSIJhO3hn8YHCay2yC54OvBaHayOXLcMr(8G3FjgqrE3yfFxOXD0gEF0WlhYbGzJXLJdo40c6ied8suCbr6ZdE)Lya1lJgCmTA5cI0Nh8(lXakm04sRwoKdatXiXx4QqJXQjGf3ifRIhe1w0uWWQXScBgtXffxSWOD3hnCCOSGWqfxzOV5GTmE4fMvH3gdEGyGxIY4HxywfU6LrdowlOfd8suCbr6ZdE)Lya1lJgCSwCbr6ZdE)LyafgAC1kGqam04sXfePpp49xIbuK3nwXXZ(iRvBeIbEjkUGi95bV)smG6LrdogoTGocXaVeflCykIMQxgn4yA1gbnfmSIfomfrtffKwreqiagACPyHdtr0urbbhhklimuXvg6BoylatdtXWMDlUBtbjV3gdEGyGxIcW0WumSz3I72uqY7Qxgn4youour3ZDiA6PG8m263ZOyePrdtzJUNJzsJNBSXLt8eb7P0CpJc49xc3tAkyyph38YtywCJWQypJQNIrIVWvEUbqvKs8eH)jbdINBSDaxiOEeouwqyOIRm03CWw3isJgMYg92yWdIqmWlr1nUCYebpLMpp49xcx9YObhtRwAkyyfxqK(OFiNOOGOvB3oGleuhpdGE)qdnC0WlhYbGPyK4lCvOXy1eWIBKIvX4OvlnfmSQBC5KjcEknFEW7VeUIcIwTCihaMIrIVWvHgJvtalUrkwfJNO6q5qfDp3yB09KtrUNAIO8edvrkXtaIFpnp1fePp6hYjkhklimuXvg6BoyRqJXQjGf3ifRIBJbpGMcgwXfePp6hYjkY7gR47gv8ghWWlnfmSIlisF0pKtuCXcJCOCOIUNBifqtpdgx8CJm8npBNIWfprLNsd53tXiXx4EYG9KjEY4EALNSIlwjEAfMN6cI09mkG3FjgWtg3ZT3q2Xtlim8VYHYccdvCLH(Md2cy4BtAkcxAJbpGMcgwbm8TjNIeFffKwCihaMIrIVWvHgJvtalUrkwfVB0AbDeIbEjkUGi95bV)smG6LrdoMwTCbr6ZdE)LyafgACHtlmKOGbw)tEdkmsjSWiwf7qzbHHkUYqFZbBXchMIOzBm4bCihaMIrIVWvHgJvtalUrkwfVB0AfbnfmSY4HxywfUIcIdLfegQ4kd9nhSfmbXLjVbfg1gdEahYbGPyK4lCvOXy1eWIBKIvX7gTw0uWWkw4WuenvuqAfbnfmSY4HxywfUIcIdLdv09msZVNrb8(lXaE2oW4INwSXkU4jfepfKNr1tXiXx4EACpbOk2tJ7PUGiDpJc49xIb8KX9SqINwqy4FLdLfegQ4kd9nhS1bV)smWKgyCPng8aXaVe1bV)smWKgyCr9YObhRfhYbGPyK4lCvOXy1eWIBKIvX7gTwqhHyGxIIlisFEW7VedOEz0GJPvlxqK(8G3FjgqHHgx44qzbHHkUYqFZbBbm8Tj9TEBm4bIbEjkJhEHzv4Qxgn4youwqyOIRm03CWwHgJvtalUrkwf7qzbHHkUYqFZbBbm8TjnfHlT1r4ZQ4b7BJbpqmWlrz8WlmRcx9YObhZHYccdvCLH(Md2cgy9p5nOWO26i8zv8G9Tf0ma(ums8f(G9TXGhqom58gJgChklimuXvg6BoylycIltEdkmQTocFwfpyVdLdv09uNvXG75ogj(INA0GWqLNAqcdryIMEUrmU4qfDpJsXPi3tCjDpzCpTGWW)EsvGZ5EQjIYZgd)75(O5jI4zhrUNCXcJ4EIG9CdfRW8exifx8eMG6EQlis3ZOaE)LyaLNqhfS47zW4hx0tkibuNvXEQr5bpPPepTGWW)EQhLn08edvrkXtCCOSGWqfxXzvm4tXiXxgadS(N8guyuBbndGpfJeFHpyFBm4bqhHWcJyvSwTIbEjkUGi95bV)smG6LrdowRacbWqJlfxqK(8G3FjgqrE3yfFxCJ34aMwTyirbdS(N8guyKI8UXk(UdIdyA1kg4LOmE4fMvHREz0GJ1cdjkyG1)K3GcJuK3nwX3f6acbWqJlLXdVWSkCf5DJv8nPPGHvgp8cZQWvyuetyOcNwbecGHgxkJhEHzv4kY7gR47gTwqhHyGxIIlisFEW7VedOEz0GJPvRyGxIIlisFEW7VedOEz0GJ1kGqam04sXfePpp49xIbuK3nwX3DpUhchCAbnnfmSAmRWMXuCrXflmA39rtRwtJpHjxXIRJO4tii5LWmGIy1i8ma3A1stbdRag(2KtrIVIcIwTrqtbdRObiegGIlkki40kcAkyyfNIe)jcEcbn(effehkhQO7zKMFp1O8WlmRc3tdwoXtnrurk8VNCiVepnaWZnYW38SDkcx8m0yK4Z90kmprfqtpzWEwNjnN4PUGiDpJc49xIb8Sqep3GHdtr00tJCpdueYlbOPNwqy4FLdLfegQ4koRIbFkgj(YMd2Y4HxywfEBm4bIbEjkJhEHzv4Qxgn4yTcieadnUuadFBstr4II8UXkoEgQf0Cbr6ZdE)LyafgACPvBeIbEjkUGi95bV)smG6LrdogoTGocXaVeflCykIMQxgn4yA1gbnfmSIfomfrtffKwreqiagACPyHdtr0urbbhhkhQO75gavrkXtk(9mkG3FjgWZ2bgx8Kb7PMikpdikaMNbJlEAEUXgxoXteSNsZ9mkG3FjCpFhcA8jhZZOyePXt9guyKNSIl3WuEUbqvKs8myCXZOaE)LyapBhyCXtmkcRI9uxqKUNrb8(lXaEsvGZ5EQjIYZgd)7zuXvp32ekIb8CdDJ0rLMkpBNs8KvEknmUNbJFp5ccINuCwf7zuaV)smGNTdmU4jQc3tnruEsUfA8CF08Klwye3teSNBOyfMN4cP4IYHYccdvCfNvXGpfJeFzZbBDW7VedmPbgxAJbpqmWlrDW7VedmPbgxuVmAWXAbTyGxIQBC5KjcEknFEW7VeU6LrdowlAkyyv34Yjte8uA(8G3FjCffKwD7aUqq9DJKH0QncXaVev34Yjte8uA(8G3FjC1lJgCmCAbDeqZfePpp49xIbuuqAjg4LO4cI0Nh8(lXaQxgn4y4OvRPXNWKRktOigy2yKoQ0urSA0GO2IMcgwnMvyZykUO4IfgT7(OHJdLdv09uJ8pep11i7jmI4jWiX3teXtocvEAyyEo2W)CLNr6cCo3tnruE2y4Fp1PiX3teSNAq04tAZtw554gwOXZGXVNAIO8CSvINcYtmefn4Estbd75gXIBKIvXE2ociEsRPNqqiaRI9CJTd4cb19K(WiYBSct5zuWvRdbCp5xdt9kCCrp3p0qBSEBEgf928uxJCBEUrT3MNBe(T3MNrrVnp3O2DOSGWqfxXzvm4tXiXx2CWwCbr6J(HCsBm4bIbEjkUGi9r)qor9YObhRf0eJHnp(VeLHHXvbevj7gvTAjgdBE8FjkddJRyfEI8q40c6ied8suCks8Ni4je04tuVmAWX0QLMcgwXPiXFIGNqqJprrbrR2UDaxiOoEgeTOHJdLdLfegQ4koRIbFkgj(YMd2cW0WumSz3I72uqY7TXGhig4LOamnmfdB2T4UnfK8U6LrdowlOjgdBE8FjkddJRciQs2nQA1smg284)sugggxXk8e5HWXHYHk6EUHrDAwDp1fePp6hYjEoMjnEUXgxoXteSNsZ9mkG3FjCprep1PiX3teSNAq04t8KQaNZ9uteLNng(3tP5EUrg(MN6nOWipfIXepTcZZofqyqa3tUyHrCLdLfegQ4koRIbFkgj(YMd2cWIBKIvXtAeqAJbpGMcgwXfePp6hYjkkiT4qoamfJeFHRcngRMawCJuSkExC3cAtJpHjxbm8TjVbfgPiwncV0uWWkGHVn5nOWifxSWiC2f3rslOPPGHvDJlNmrWtP5ZdE)LWvuqAfHyGxIItrI)ebpHGgFI6LrdoMwT0uWWkofj(te8ecA8jkki44q5qfDpJ087zumI0OHPSr3t8pHtX9e3Ekgj(cVnpPkW5Cp1er5zJH)9CJm8np1BqHrkpJ087zumI0OHPSr3t8pHtX9CVNIrIV4jd2tnruE2y4Fp35bbvSGN70qvyN4zu9uy9Z90kmp3EdXtDks89eb7Pgen(epFz0GJ5PvyEU9gINBKHV5PEdkms5qzbHHkUIZQyWNIrIVS5GTUrKgnmLn6TXGhanhYbGPyK4lCvOXy1eWIBKIvX4zVwTMgFctUsEqqflmLgQc7efXQr4zquBfHyGxIItrI)ebpHGgFI6LrdowltJpHjxbm8TjVbfgPiwnA3940Y04tyYvadFBYBqHrkIvJWlnfmScy4BtEdkmsXflmAxOJAKSzuXRPXNWKRKheuXctPHQWorrSAeE5qoamfJeFHRcngRMawCJuSkgNwqhHyGxIItrI)ebpHGgFI6LrdoMwTrGHefmW6FYBqHrkYHjN3y0GRvlxqK(8G3FjgqrbbNwqhHyGxIQBC5KjcEknFEW7VeU6LrdoMwT0uWWQUXLtMi4P085bV)s4kkiA1gqiagACPag(2KMIWff5DJvC8muRUDaxiOoEgObW9MrDi8kg4LOcgamLMpLgQc7e1lJgCmCCOCOIUNByJlEgfJinEQ3GcJ8CmtA8CJnUCINiypLM7zuaV)s4Ekg4L4jnL4zH80ccd)7Pofj(EIG9udIgFIN0uWWT5PvyEAbHH)9uxqK(OFiN4jnfmSNwH55gz4BE2ofHlEgqDwf7jcg2Zn8gWZXmPHvEkn3Z64Q4jUWn8gOnpTcZZZKMt80ccd)75gBC5eprWEkn3ZOaE)LW9KMcgUnpreplKNg(gdy0G75gz4BE2ofHlEoUHbUN1nINBSUNbdsBEIiEYzvm4Ekgj(INwH5zNcimiG75gz4BEQ3GcJ8uigt4EAfMNDR00tUyHrCLdLfegQ4koRIbFkgj(YMd26grAM8guyuBm4brqtbdR4uK4prWtiOXNOOG0smWlr1nUCYebpLMpp49xcx9YObhRf00uWWQUXLtMi4P085bV)s4kkiA1gqiagACPag(2KMIWff5DJvC8muRUDaxiOoEgObW9MrDi8kg4LOcgamLMpLgQc7e1lJgCmTA5qoamfJeFHRcngRMawCJuSkExC3cAtJpHjxbm8TjVbfgPiwncV0uWWkGHVn5nOWifxSWODXDKGtlAkyyfxqK(OFiNOOG0kGqam04sbm8TjnfHlkY7gR47oioGHJdLdv09uJKikphvOXEoUXens45g0ZgdZtoQFp5niI45XviaRmHHkpBo5EIQWvE2oL4P08YtP5EgqfgtyOYZyYh3MNwH55g0ZgdZtb5jhcGjEkn3tuDpJIrKgp1BqHrEcy19KvcYtyefrPuCKNAIO8SXW)EkipXUb8CmtA8uAyCpnAuNvMWqLNfAmUONByJlEgfJinEQ3GcJ8CmtAquINBSXLt8eb7P0CpJc49xc3tXaVK280kmphZKgeL4zJHpRI9uimiG75gmUoII7PgejVeMb80kmpTGWW)EQr5HxywfEBEAfMNwqy4Fp1fePp6hYjEstbd7jI4zDJ45gR7zWG0MNiIN6cI09mkG3FjgWtg3twzbHH)BZtRW8C89myvKs884kKhepfKNXx80kpnmmMWqLb8KIFprWEQlis3ZOaE)LyapzLNsZ9K8UXkwf7jmlUr8eMG6EQtrIVNiyp1GOXNOCOSGWqfxXzvm4tXiXx2CWw3isZK3GcJAJbpicXaVev34Yjte8uA(8G3FjC1lJgCSwraTPXNWKRyX1ru8jeK8sygqrSAeEWDlAkyyLXdVWSkCffeCAbnnfmSIlisF0pKtuuq0QTBhWfcQJNbAGH2mQdHxXaVevWaGP08P0qvyNOEz0GJPvBeqZfePpp49xIbuuqAjg4LO4cI0Nh8(lXaQxgn4y4064kKhKJndOoTjtWRyPzyH1)WbecGHgxkUGi95bV)smGI8UXk(W7J8q4fgGqeOH(4kKhKJndOoTjtWRyPzyH1)WbecGHgxkUGi95bV)smGI8UXkooAO9rEiCWZGOoeEHE)MqBA8jm5QhAqte8uA(8G3FjgGRiwncpdWno4GJdLdv09msZVNrXisJN6nOWipzWEQtrIVNiyp1GOXN4jJ7PyGxYXAZtAkXZ6mP5epzINfI4P55gqdQ7zuaV)smGNmUNwqy4FpnXtP5E2r9xsBEAfMNBKHV5z7ueU4jJ7j5gMMEIiEoMbaEsFpj3W00ZXmPHvEkn3Z64Q4jUWn8gq5qzbHHkUIZQyWNIrIVS5GTUrKMjVbfg1gdEGyGxIItrI)ebpHGgFI6LrdowRiOPGHvCks8Ni4je04tuuqAfqiagACPag(2KMIWff5DJv8DhehWAbDeIbEjkUGi95bV)smG6LrdowRiGzKpp49xIbuuq0QvmWlrXfePpp49xIbuVmAWXAfbxqK(8G3FjgqrbbhhkhQO7PoeR75gXIBKIvXE2ociCpXOiSk2tDbr6EgfW7Ved4jgfXegQAZtgSNAIO8edvrkXZgd)75gmUoII7PgejVeMb8er8SXW)EYeprfqtprv4T5PvyEIHQiL4jf)EUrS4gPyvSNTJaINyuewf7z7aecdqXfpzWEQjIYZgd)7P55gz4BEQtrIVNAqckOCOSGWqfxXzvm4tXiXx2CWwawCJuSkEsJasBm4bCbr6ZdE)LyaffKwIbEjkUGi95bV)smG6LrdowlOnn(eMCflUoIIpHGKxcZakIvJ2f3A1gbnfmScy4Btofj(kkiTOPGHv0aecdqXfffeCCOCOIUNByJlEUrS4gPyvSNTJaINKhBemW5CprWEkn3tiKJpdrX9mGkmMWqLNmyp1erfPW8eG43tZtDbr6J(HCINCXcJ8er8SXW)EQlisF0pKt80kmp3yJlN4jc2tP5EgfW7VeUNwqy4FLdLfegQ4koRIbFkgj(YMdaS4gPyv8KgbK2yWdGMMcgwXfePp6hYjkY7gR47UxThVXbm8stbdR4cI0h9d5efxSWiTAPPGHvCbr6J(HCIIcslAkyyv34Yjte8uA(8G3FjCffeCCOCOIUNrA(9exIG4IN6nOWiphZKgp3GHdtr00tRW8CJnUCINiypLM7zuaV)s4khklimuXvCwfd(ums8LnhSfmbXLjVbfg1gdEGyGxIIfomfrt1lJgCSwIbEjQUXLtMi4P085bV)s4Qxgn4yTOPGHvSWHPiAQOG0IMcgw1nUCYebpLMpp49xcxrbXHYHYccdvCfNvXGpfJeFzZbBbm8TjnfHlTXGhqtbdRmE4fMvHROG4q5qfDpJ0cdW047Pofj(EIG9udIgFINcYtoeYnmpXLaw)EQ3GcJ8Kb7zNcimiG75R3zN7PrUNqiN)suouwqyOIR4Skg8PyK4lBoylyG1)K3GcJAlOza8PyK4l8b7BJbpGCyY5ngn4TSGWW)ZxVZohp7BrtbdR4uK4prWtiOXNOOG4q5qfDpJ0875gz4BE2ofHlEoMjnEQtrIVNiyp1GOXN4jd2tP5EcmU4jeK8sygWtkUfFprWEAEQlis3ZOaE)LyapBmEfPepnpHPaapXOiMWqLNBi4c8Kb7PMikpdikaMNXx80kK0CINuCl(EIG9uAUNBanOUNrb8(lXaEYG9uAUNK3nwXQypHzXnINJnUN7JenKNaufFIYHYccdvCfNvXGpfJeFzZbBbm8TjnfHlTXGhig4LO4cI0Nh8(lXaQxgn4yTcieadnUMKBbPfnfmSItrI)ebpHGgFIIcslOpUc5b5yZaQtBYe8kwAgwy9pCaHayOXLIlisFEW7VedOiVBSIp8(ipeEHbiebAOpUc5b5yZaQtBYe8kwAgwy9pCaHayOXLIlisFEW7VedOiVBSIJJgAFKhcNDJ6q4f69BcTPXNWKREObnrWtP5ZdE)LyaUIy1i8ma34GJwTqVxTpsWl0hxH8GCSza1PnzcEflndlS(Xz4acbWqJlfxqK(8G3FjgqrE3yfF49rEi8cdqic0qVxTpsWl0hxH8GCSza1PnzcEflndlS(Xz4acbWqJlfxqK(8G3FjgqrE3yfhhn0(ipeo4Sl0hxH8GCSza1PnzcEflndlS(hoGqam04sXfePpp49xIbuK3nwXhEFKhcVWaeIan0hxH8GCSza1PnzcEflndlS(hoGqam04sXfePpp49xIbuK3nwXXrdTpYdHdo44q5qfDpJ0875gz4BE2ofHlEoMjnEQtrIVNiyp1GOXN4jd2tP5EcmU4jeK8sygWtkUfFprWEAEIlXi3ZOaE)LyapBmEfPepnpHPaapXOiMWqLNBi4c8Kb7PMikpdikaMNXx80kK0CINuCl(EIG9uAUNBanOUNrb8(lXaEYG9uAUNK3nwXQypHzXnINJnUN7JenKNaufFIYHYccdvCfNvXGpfJeFzZbBbm8TjnfHlTXGheHyGxIIlisFEW7VedOEz0GJ1kGqam04AsUfKw0uWWkofj(te8ecA8jkkiTG(4kKhKJndOoTjtWRyPzyH1)WbecGHgxkyg5ZdE)Lyaf5DJv8H3h5HWlmaHiqd9XvipihBgqDAtMGxXsZWcR)HdieadnUuWmYNh8(lXakY7gR44OH2h5HWz3OoeEHE)MqBA8jm5QhAqte8uA(8G3FjgGRiwncpdWno4Ovl07v7Je8c9XvipihBgqDAtMGxXsZWcRFCgoGqam04sbZiFEW7VedOiVBSIp8(ipeEHbiebAO3R2hj4f6JRqEqo2mG60MmbVILMHfw)4mCaHayOXLcMr(8G3FjgqrE3yfhhn0(ipeo4Sl0hxH8GCSza1PnzcEflndlS(hoGqam04sbZiFEW7VedOiVBSIp8(ipeEHbiebAOpUc5b5yZaQtBYe8kwAgwy9pCaHayOXLcMr(8G3FjgqrE3yfhhn0(ipeo4GJdLdLfegQ4koRIbFkgj(YMd2cWIBKIvXtAeqAJbpGMcgwXPiXFIGNqqJprrbXHYccdvCfNvXGpfJeFzZbBbm8TjnfHlTXGheqiagACnj3csRied8suDJlNmrWtP5ZdE)LWvVmAWXCO80thQO7PoGf3ian9m263Zny4Wuen9KMcg2tb5zdcYHPaan9KMcg2toQFpFhcA8jhZtCjcIlEQ3GcJ4EoMjnEUXgxoXteSNsZ9mkG3FjCLdLfegQ4koRIbFkgj(YMd2IfomfrZ2yWded8suSWHPiAQEz0GJ1kcO72bCHG64rJiYTcieadnUuadFBstr4II8UXk(UdgcNwqhHyGxIIlisFEW7VedOEz0GJPvlxqK(8G3FjgqHHgx44q5qzbHHkUIZQyWNIrIVS5GTag(2KMIWL2yWdcieadnUMKBbPvOXiXNJhXaVe1dnOjcEknFEW7VeU6LrdoMdLdv09uhWIBeGMEIDGPPNuCwf75gmCykIME(oe04toMN4seex8uVbfgX9uqE(oe04t8uAE3ZXmPXZn24YjEIG9uAUNrb8(lH7PGqkhklimuXvCwfd(ums8LnhSfmbXLjVbfg1gdEGyGxIIfomfrt1lJgCSw0uWWkw4WuenvuqArtbdRyHdtr0urE3yfF39Q94noGHxAkyyflCykIMkUyHrououwqyOIR4Skg8PyK4lBoylGHVnPPiCPng8GacbWqJRj5wqCOCOIUNBaufPepTqGH9smaqtpP43tDks89eb7Pgen(ephZKgpXLaw)EQ3GcJ8eJIWQyp5SkgCpfJeFr5qzbHHkUIZQyWNIrIVS5GTGbw)tEdkmQTGMbWNIrIVWhSVng8aYHjN3y0G3kcAkyyfNIe)jcEcbn(effehklimuXvCwfd(ums8LnhSLGK3NDJlNOzBm4bIbEjkbjVp7gxort1lJgCSwqttbdRiNJkRcFki5Df5DJv8DJeTAHMMcgwrohvwf(uqY7kY7gR47cnnfmSY4HxywfUcJIycdvBgqiagACPmE4fMvHRiVBSIJtRacbWqJlLXdVWSkCf5DJv8D3hzCWXHYHYccdvCfNvXGpfJeFzZbBbtqCzYBqHrTXGhig4LOyHdtr0u9YObhRfnfmSIfomfrtffKwqttbdRyHdtr0urE3yfF34agEJgEPPGHvSWHPiAQ4IfgPvlnfmSIlisF0pKtuuq0QncXaVev34Yjte8uA(8G3FjC1lJgCmCCOSGWqfxXzvm4tXiXx2CWwHgJvtalUrkwf3gdEanfmSsEqqflmLgQc7effKwrqtbdR4cI0h9d5effKwCihaMIrIVWvHgJvtalUrkwfJN9ouwqyOIR4Skg8PyK4lBoylalUrkwfpPraXHYccdvCfNvXGpfJeFzZbBbdS(N8guyuBDe(SkEW(2cAgaFkgj(cFW(2yWdihMCEJrdUdLfegQ4koRIbFkgj(YMd2cgy9p5nOWO26i8zv8G9TXGh0r4)(lrHX4IvHJNiXHYHk6EIlrqCXt9guyKNmUNikINDe(V)s8eMbaNOCOSGWqfxXzvm4tXiXx2CWwWeexM8guyuBDe(SkEW(Lo(NWzOATnUhAVgyOOn0E1(OfTL(yJuSkMV03GDiiICmpJMNwqyOYtaJlCLd1s3OKgezPRZ6uatyOAdtmyzPdyCHV2zPZzvm4tXiXxw7S2E)ANL(lJgCSv7lDlimuT0Hbw)tEdkmAPhim5eMT0H2Zi8uyHrSk2tTA9umWlrXfePpp49xIbuVmAWX8SLNbecGHgxkUGi95bV)smGI8UXkUN76jU9eVEghW8uRwpXqIcgy9p5nOWif5DJvCp3DGNXbmp1Q1tXaVeLXdVWSkC1lJgCmpB5jgsuWaR)jVbfgPiVBSI75UEcTNbecGHgxkJhEHzv4kY7gR4EUPN0uWWkJhEHzv4kmkIjmu5joE2YZacbWqJlLXdVWSkCf5DJvCp31ZO5zlpH2Zi8umWlrXfePpp49xIbuVmAWX8uRwpfd8suCbr6ZdE)Lya1lJgCmpB5zaHayOXLIlisFEW7VedOiVBSI75UEUh3d5joEIJNT8eApPPGHvJzf2mMIlkUyHrEURN7JMNA16PPXNWKRyX1ru8jeK8sygqrSAKN4zGN42tTA9KMcgwbm8TjNIeFffep1Q1Zi8KMcgwrdqimafxuuq8ehpB5zeEstbdR4uK4prWtiOXNOOGS0dAgaFkgj(cFT9(LS2g3RDw6VmAWXwTV0deMCcZw6IbEjkJhEHzv4Qxgn4yE2YZacbWqJlfWW3M0ueUOiVBSI7jE8CipB5j0EYfePpp49xIbuyOXLNA16zeEkg4LO4cI0Nh8(lXaQxgn4yEIJNT8eApJWtXaVeflCykIMQxgn4yEQvRNr4jnfmSIfomfrtffepB5zeEgqiagACPyHdtr0urbXtCw6wqyOAPB8WlmRcFjRTJ6ANL(lJgCSv7l9aHjNWSLUyGxI6G3FjgysdmUOEz0GJ5zlpH2tXaVev34Yjte8uA(8G3FjC1lJgCmpB5jnfmSQBC5KjcEknFEW7VeUIcINT8SBhWfcQ75UEgjd5PwTEgHNIbEjQUXLtMi4P085bV)s4Qxgn4yEIJNT8eApJWtO9KlisFEW7VedOOG4zlpfd8suCbr6ZdE)Lya1lJgCmpXXtTA9004tyYvLjuedmBmshvAQiwnYZbEgvpB5jnfmSAmRWMXuCrXflmYZD9CF08eNLUfegQw6h8(lXatAGXLLS2oARDw6VmAWXwTV0deMCcZw6IbEjkUGi9r)qor9YObhZZwEcTNeJHnp(VeLHHXvbevjEURNr1tTA9KymS5X)LOmmmUIvEIhpJ8qEIJNT8eApJWtXaVefNIe)jcEcbn(e1lJgCmp1Q1tAkyyfNIe)jcEcbn(effep1Q1ZUDaxiOUN4zGNrlAEIZs3ccdvlDUGi9r)qozjRTJ8ANL(lJgCSv7l9aHjNWSLUyGxIcW0WumSz3I72uqY7Qxgn4yE2YtO9KymS5X)LOmmmUkGOkXZD9mQEQvRNeJHnp(VeLHHXvSYt84zKhYtCw6wqyOAPdyAykg2SBXDBki59LS2osw7S0Fz0GJTAFPhim5eMT0PPGHvCbr6J(HCIIcINT8Kd5aWums8fUk0ySAcyXnsXQyp31tC7zlpH2ttJpHjxbm8TjVbfgPiwnYt86jnfmScy4BtEdkmsXflmYtC8CxpXDK4zlpH2tAkyyv34Yjte8uA(8G3FjCffepB5zeEkg4LO4uK4prWtiOXNOEz0GJ5PwTEstbdR4uK4prWtiOXNOOG4jolDlimuT0bS4gPyv8KgbKLS2wJyTZs)Lrdo2Q9LEGWKty2shAp5qoamfJeFHRcngRMawCJuSk2t845Ep1Q1ttJpHjxjpiOIfMsdvHDIIy1ipXZapJQNT8mcpfd8suCks8Ni4je04tuVmAWX8SLNMgFctUcy4BtEdkmsrSAKN765EpXXZwEAA8jm5kGHVn5nOWifXQrEIxpPPGHvadFBYBqHrkUyHrEURNq7zuJep30ZO6jE9004tyYvYdcQyHP0qvyNOiwnYt86jhYbGPyK4lCvOXy1eWIBKIvXEIJNT8eApJWtXaVefNIe)jcEcbn(e1lJgCmp1Q1Zi8edjkyG1)K3GcJuKdtoVXOb3tTA9KlisFEW7VedOOG4joE2YtO9mcpfd8suDJlNmrWtP5ZdE)LWvVmAWX8uRwpPPGHvDJlNmrWtP5ZdE)LWvuq8uRwpdieadnUuadFBstr4II8UXkUN4XZH8SLND7aUqqDpXZap1a42Zn9mQd5jE9umWlrfmayknFknuf2jQxgn4yEIZs3ccdvl9BePrdtzJ(swBJlV2zP)YObhB1(spqyYjmBPhHN0uWWkofj(te8ecA8jkkiE2YtXaVev34Yjte8uA(8G3FjC1lJgCmpB5j0EstbdR6gxozIGNsZNh8(lHROG4PwTEgqiagACPag(2KMIWff5DJvCpXJNd5zlp72bCHG6EINbEQbWTNB6zuhYt86PyGxIkyaWuA(uAOkStuVmAWX8uRwp5qoamfJeFHRcngRMawCJuSk2ZD9e3E2YtO9004tyYvadFBYBqHrkIvJ8eVEstbdRag(2K3GcJuCXcJ8CxpXDK4joE2YtAkyyfxqK(OFiNOOG4zlpdieadnUuadFBstr4II8UXkUN7oWZ4aMN4S0TGWq1s)grAM8guy0swBRbw7S0Fz0GJTAFPhim5eMT0JWtXaVev34Yjte8uA(8G3FjC1lJgCmpB5zeEcTNMgFctUIfxhrXNqqYlHzafXQrEIhpXTNT8KMcgwz8WlmRcxrbXtC8SLNq7jnfmSIlisF0pKtuuq8uRwp72bCHG6EINbEQbgYZn9mQd5jE9umWlrfmayknFknuf2jQxgn4yEQvRNr4j0EYfePpp49xIbuuq8SLNIbEjkUGi95bV)smG6LrdoMN44zlppUc5b5yZaQtBYe8kwA8Cypfw)EoSNbecGHgxkUGi95bV)smGI8UXkUNd75(ipKN41tyacr8eApH2ZJRqEqo2mG60MmbVILgph2tH1VNd7zaHayOXLIlisFEW7VedOiVBSI7joEQH8CFKhYtC8epd8mQd5jE9eAp375MEcTNMgFctU6Hg0ebpLMpp49xIb4kIvJ8epd8e3EIJN44jolDlimuT0VrKMjVbfgTK127hATZs)Lrdo2Q9LEGWKty2sxmWlrXPiXFIGNqqJpr9YObhZZwEgHN0uWWkofj(te8ecA8jkkiE2YZacbWqJlfWW3M0ueUOiVBSI75Ud8moG5zlpH2Zi8umWlrXfePpp49xIbuVmAWX8SLNr4jmJ85bV)smGIcINA16PyGxIIlisFEW7VedOEz0GJ5zlpJWtUGi95bV)smGIcIN4S0TGWq1s)grAM8guy0swBVF)ANL(lJgCSv7l9aHjNWSLoxqK(8G3FjgqrbXZwEkg4LO4cI0Nh8(lXaQxgn4yE2YtO9004tyYvS46ik(ecsEjmdOiwnYZD9e3EQvRNr4jnfmScy4Btofj(kkiE2YtAkyyfnaHWauCrrbXtCw6wqyOAPdyXnsXQ4jncilzT9ECV2zP)YObhB1(spqyYjmBPdTN0uWWkUGi9r)qorrE3yf3ZD9CVAVN41Z4aMN41tAkyyfxqK(OFiNO4Ifg5PwTEstbdR4cI0h9d5effepB5jnfmSQBC5KjcEknFEW7VeUIcIN4S0TGWq1shWIBKIvXtAeqwYA79rDTZs)Lrdo2Q9LEGWKty2sxmWlrXchMIOP6LrdoMNT8umWlr1nUCYebpLMpp49xcx9YObhZZwEstbdRyHdtr0urbXZwEstbdR6gxozIGNsZNh8(lHROGS0TGWq1shMG4YK3GcJwYA79rBTZs)Lrdo2Q9LEGWKty2sNMcgwz8WlmRcxrbzPBbHHQLoWW3M0ueUSK127J8ANL(lJgCSv7lDlimuT0Hbw)tEdkmAPhim5eMT0jhMCEJrdUNT80ccd)pF9o7CpXJN79SLN0uWWkofj(te8ecA8jkkil9GMbWNIrIVWxBVFjRT3hjRDw6VmAWXwTV0deMCcZw6IbEjkUGi95bV)smG6LrdoMNT8mGqam04AsUfepB5jnfmSItrI)ebpHGgFIIcINT8eAppUc5b5yZaQtBYe8kwA8Cypfw)EoSNbecGHgxkUGi95bV)smGI8UXkUNd75(ipKN41tyacr8eApH2ZJRqEqo2mG60MmbVILgph2tH1VNd7zaHayOXLIlisFEW7VedOiVBSI7joEQH8CFKhYtC8CxpJ6qEIxpH2Z9EUPNq7PPXNWKREObnrWtP5ZdE)LyaUIy1ipXZapXTN44joEQvRNq75E1(iXt86j0EECfYdYXMbuN2Kj4vS045WEkS(9ehph2ZacbWqJlfxqK(8G3FjgqrE3yf3ZH9CFKhYt86jmaHiEcTNq75E1(iXt86j0EECfYdYXMbuN2Kj4vS045WEkS(9ehph2ZacbWqJlfxqK(8G3FjgqrE3yf3tC8ud55(ipKN44joEURNq75XvipihBgqDAtMGxXsJNd7PW63ZH9mGqam04sXfePpp49xIbuK3nwX9Cyp3h5H8eVEcdqiINq7j0EECfYdYXMbuN2Kj4vS045WEkS(9CypdieadnUuCbr6ZdE)Lyaf5DJvCpXXtnKN7J8qEIJN44jolDlimuT0bg(2KMIWLLS2EVgXANL(lJgCSv7l9aHjNWSLEeEkg4LO4cI0Nh8(lXaQxgn4yE2YZacbWqJRj5wq8SLN0uWWkofj(te8ecA8jkkiE2YtO984kKhKJndOoTjtWRyPXZH9uy975WEgqiagACPGzKpp49xIbuK3nwX9Cyp3h5H8eVEcdqiINq7j0EECfYdYXMbuN2Kj4vS045WEkS(9CypdieadnUuWmYNh8(lXakY7gR4EIJNAip3h5H8ehp31ZOoKN41tO9CVNB6j0EAA8jm5QhAqte8uA(8G3FjgGRiwnYt8mWtC7joEIJNA16j0EUxTps8eVEcTNhxH8GCSza1PnzcEflnEoSNcRFpXXZH9mGqam04sbZiFEW7VedOiVBSI75WEUpYd5jE9egGqepH2tO9CVAFK4jE9eAppUc5b5yZaQtBYe8kwA8Cypfw)EIJNd7zaHayOXLcMr(8G3FjgqrE3yf3tC8ud55(ipKN44joEURNq75XvipihBgqDAtMGxXsJNd7PW63ZH9mGqam04sbZiFEW7VedOiVBSI75WEUpYd5jE9egGqepH2tO984kKhKJndOoTjtWRyPXZH9uy975WEgqiagACPGzKpp49xIbuK3nwX9ehp1qEUpYd5joEIJN4S0TGWq1shy4BtAkcxwYA794YRDw6VmAWXwTV0deMCcZw60uWWkofj(te8ecA8jkkilDlimuT0bS4gPyv8KgbKLS2EVgyTZs)Lrdo2Q9LEGWKty2spGqam04AsUfepB5zeEkg4LO6gxozIGNsZNh8(lHREz0GJT0TGWq1shy4BtAkcxwYABCp0ANL(lJgCSv7l9aHjNWSLUyGxIIfomfrt1lJgCmpB5zeEcTND7aUqqDpXJNAer2ZwEgqiagACPag(2KMIWff5DJvCp3DGNd5joE2YtO9mcpfd8suCbr6ZdE)Lya1lJgCmp1Q1tUGi95bV)smGcdnU8eNLUfegQw6SWHPiAUK124E)ANL(lJgCSv7l9aHjNWSLEaHayOX1KCliE2YZqJrIp3t84PyGxI6Hg0ebpLMpp49xcx9YObhBPBbHHQLoWW3M0ueUSK124g3RDw6VmAWXwTV0deMCcZw6IbEjkw4WuenvVmAWX8SLN0uWWkw4Wuenvuq8SLN0uWWkw4WuenvK3nwX9Cxp3R27jE9moG5jE9KMcgwXchMIOPIlwy0s3ccdvlDycIltEdkmAjRTXDux7S0Fz0GJTAFPhim5eMT0dieadnUMKBbzPBbHHQLoWW3M0ueUSK124oARDw6VmAWXwTV0TGWq1shgy9p5nOWOLEGWKty2sNCyY5ngn4E2YZi8KMcgwXPiXFIGNqqJprrbzPh0ma(ums8f(A79lzTnUJ8ANL(lJgCSv7l9aHjNWSLUyGxIsqY7ZUXLt0u9YObhZZwEcTN0uWWkY5OYQWNcsExrE3yf3ZD9ms8uRwpH2tAkyyf5Cuzv4tbjVRiVBSI75UEcTN0uWWkJhEHzv4kmkIjmu55MEgqiagACPmE4fMvHRiVBSI7joE2YZacbWqJlLXdVWSkCf5DJvCp31Z9r2tC8eNLUfegQw6csEF2nUCIMlzTnUJK1ol9xgn4yR2x6bctoHzlDXaVeflCykIMQxgn4yE2YtAkyyflCykIMkkiE2YtO9KMcgwXchMIOPI8UXkUN76zCaZt86z08eVEstbdRyHdtr0uXflmYtTA9KMcgwXfePp6hYjkkiEQvRNr4PyGxIQBC5KjcEknFEW7VeU6LrdoMN4S0TGWq1shMG4YK3GcJwYABCRrS2zP)YObhB1(spqyYjmBPttbdRKheuXctPHQWorrbXZwEgHN0uWWkUGi9r)qorrbXZwEYHCaykgj(cxfAmwnbS4gPyvSN4XZ9lDlimuT0dngRMawCJuSkEjRTXnU8ANLUfegQw6awCJuSkEsJaYs)Lrdo2Q9LS2g3AG1ol9xgn4yR2x6wqyOAPddS(N8guy0spOza8PyK4l8127x6bctoHzlDYHjN3y0GV07i8zv8sF)swBh1Hw7S0Fz0GJTAFPhim5eMT07i8F)LOWyCXQW9epEgjlDlimuT0Hbw)tEdkmAP3r4ZQ4L((LS2oQ7x7S07i8zv8sF)s3ccdvlDycIltEdkmAP)YObhB1(swYs3qFTZA79RDw6VmAWXwTV0deMCcZw6IbEjkUGi9r)qor9YObhBPBbHHQLoxqK(OFiNSK124ETZs)Lrdo2Q9LUfegQw6WaR)jVbfgT0deMCcZw6KdtoVXOb3ZwEcTNCihaMIrIVWvHgJvtalUrkwf75UEcTNr2ZH9mcpfd8sucsEF2nUCIMQxgn4yEIJNA16zeEkg4LO4cI0Nh8(lXaQxgn4yE2YtO9eMr(8G3FjgqrE3yf3t84j0EUpAEIxp5qoamBmUCpXXtTA9mGqam04sbZiFEW7VedOiVBSI75UEcTN4oAEoSN7JMN41toKdaZgJl3tC8ehpXXZwEcTNr4PyGxIIlisFEW7VedOEz0GJ5PwTEYfePpp49xIbuyOXLNA16jhYbGPyK4lCvOXy1eWIBKIvXEoWZO6zlpPPGHvJzf2mMIlkUyHrEURN7JMN4S0dAgaFkgj(cFT9(LS2oQRDw6VmAWXwTV0deMCcZw6IbEjkJhEHzv4Qxgn4yE2YtO9umWlrXfePpp49xIbuVmAWX8SLNCbr6ZdE)LyafgAC5zlpdieadnUuCbr6ZdE)Lyaf5DJvCpXJN7JSNA16zeEkg4LO4cI0Nh8(lXaQxgn4yEIJNT8eApJWtXaVeflCykIMQxgn4yEQvRNr4jnfmSIfomfrtffepB5zeEgqiagACPyHdtr0urbXtCw6wqyOAPB8WlmRcFjRTJ2ANL(lJgCSv7l9aHjNWSLUyGxIcW0WumSz3I72uqY7Qxgn4ylDlimuT0bmnmfdB2T4UnfK8(swBh51ol9xgn4yR2x6bctoHzl9i8umWlr1nUCYebpLMpp49xcx9YObhZtTA9KMcgwXfePp6hYjkkiEQvRND7aUqqDpXZapH2Z9dnKNd7z08eVEYHCaykgj(cxfAmwnbS4gPyvSN44PwTEstbdR6gxozIGNsZNh8(lHROG4PwTEYHCaykgj(cxfAmwnbS4gPyvSN4XZOU0TGWq1s)grA0Wu2OVK12rYANL(lJgCSv7l9aHjNWSLonfmSIlisF0pKtuK3nwX9CxpJQN41Z4aMN41tAkyyfxqK(OFiNO4IfgT0TGWq1sp0ySAcyXnsXQ4LS2wJyTZs)Lrdo2Q9LEGWKty2sNMcgwbm8TjNIeFffepB5jhYbGPyK4lCvOXy1eWIBKIvXEURNrZZwEcTNr4PyGxIIlisFEW7VedOEz0GJ5PwTEYfePpp49xIbuyOXLN44zlpXqIcgy9p5nOWiLWcJyv8s3ccdvlDGHVnPPiCzjRTXLx7S0Fz0GJTAFPhim5eMT05qoamfJeFHRcngRMawCJuSk2ZD9mAE2YZi8KMcgwz8WlmRcxrbzPBbHHQLolCykIMlzTTgyTZs)Lrdo2Q9LEGWKty2sNd5aWums8fUk0ySAcyXnsXQyp31ZO5zlpPPGHvSWHPiAQOG4zlpJWtAkyyLXdVWSkCffKLUfegQw6WeexM8guy0swBVFO1ol9xgn4yR2x6bctoHzlDXaVe1bV)smWKgyCr9YObhZZwEYHCaykgj(cxfAmwnbS4gPyvSN76z08SLNq7zeEkg4LO4cI0Nh8(lXaQxgn4yEQvRNCbr6ZdE)LyafgAC5jolDlimuT0p49xIbM0aJllzT9(9RDw6VmAWXwTV0deMCcZw6IbEjkJhEHzv4Qxgn4ylDlimuT0bg(2K(wFjRT3J71olDlimuT0dngRMawCJuSkEP)YObhB1(swBVpQRDw6VmAWXwTV0deMCcZw6IbEjkJhEHzv4Qxgn4ylDlimuT0bg(2KMIWLLEhHpRIx67xYA79rBTZs)Lrdo2Q9LUfegQw6WaR)jVbfgT0dAgaFkgj(cFT9(LEGWKty2sNCyY5ngn4l9ocFwfV03VK127J8ANLEhHpRIx67x6wqyOAPdtqCzYBqHrl9xgn4yR2xYsw6yh2OaYAN127x7S0Fz0GJTOx6bctoHzlDtJpHjxzv4CHyGj5Cuzv4Qxgn4ylDlimuT0PbiegGIllzTnUx7S0Fz0GJTAFPhim5eMT0pUc5b5yZaQtBYe8kwA8Cypfw)EURNrDip1Q1tyg5ZdE)Lyaffep1Q1tUGi95bV)smGIcYs3ccdvlDiiHHQLS2oQRDw6wqyOAPpMvytEZnYs)Lrdo2Q9LS2oARDw6VmAWXwTV0deMCcZw6IbEjkbjVp7gxort1lJgCmpB5jnfmSICoQSk8PGK3vK3nwX9CxpX9s3ccdvlDbjVp7gxorZLS2oYRDw6VmAWXwTV0deMCcZw6r4PyGxIIlisFEW7VedOEz0GJT0TGWq1shMr(8G3FjgyjRTJK1ol9xgn4yR2x6bctoHzlDXaVefxqK(8G3Fjgq9YObhZZwEcTNr4PyGxIIfomfrt1lJgCmp1Q1Zi8KMcgwXchMIOPIcINT8mcpdieadnUuSWHPiAQOG4joE2YtO9mcpfd8sugp8cZQWvVmAWX8uRwpJWZacbWqJlLXdVWSkCffepXzPBbHHQLoxqK(8G3FjgyjRT1iw7S0TGWq1sNI)jtENV0Fz0GJTAFjRTXLx7S0Fz0GJTAFPhim5eMT0JWtXaVeLXdVWSkC1lJgCmp1Q1tAkyyLXdVWSkCffep1Q1ZacbWqJlLXdVWSkCf5DJvCpXJNrEOLUfegQw60aecBctr0CjRT1aRDw6VmAWXwTV0deMCcZw6r4PyGxIY4HxywfU6LrdoMNA16jnfmSY4HxywfUIcYs3ccdvlD6t4NmIvXlzT9(Hw7S0Fz0GJTAFPhim5eMT0JWtXaVeLXdVWSkC1lJgCmp1Q1tAkyyLXdVWSkCffep1Q1ZacbWqJlLXdVWSkCf5DJvCpXJNrEOLUfegQw6WmYPbie2swBVF)ANL(lJgCSv7l9aHjNWSLEeEkg4LOmE4fMvHREz0GJ5PwTEstbdRmE4fMvHROG4PwTEgqiagACPmE4fMvHRiVBSI7jE8mYdT0TGWq1s3QW5cXaZGbalzT9ECV2zP)YObhB1(spqyYjmBPZfePpp49xIbuuq8SLN0uWWQGbatalUrkwfRiVBSI7jEg4jU8s3ccdvl9R5Ni4P08jxqK(swBVpQRDw6wqyOAP3VCezP)YObhB1(swBVpARDw6VmAWXwTV0deMCcZw6wqy4)5R3zN7jE8e3E2YtO9Kd5aWums8fUk0ySAcyXnsXQypXJN42tTA9Kd5aWums8fUcy4Bt6BDpXJN42tCw6wqyOAPtOQPfegQMagxw6agxML1)s3qFjRT3h51ol9xgn4yR2x6wqyOAPtOQPfegQMagxw6agxML1)sNZQyWNIrIVSKLS0HqEa1PnzTZA79RDw6VmAWXwTVK124ETZs)Lrdo2Q9LS2oQRDw6VmAWXwTVK12rBTZs)Lrdo2Q9LS2oYRDw6wqyOAPli59z34YjAU0Fz0GJTAFjRTJK1ol9xgn4yR2x6bctoHzlDXaVefxqK(OFiNOEz0GJ5zlpH2tIXWMh)xIYWW4QaIQep31ZO6PwTEsmg284)sugggxXkpXJNrEipXzPBbHHQLoxqK(OFiNSK12AeRDw6VmAWXwTV0deMCcZw6r4PyGxIIlisFEW7VedOEz0GJT0TGWq1shMr(8G3FjgyjRTXLx7S0Fz0GJTAFPhim5eMT0fd8suCbr6ZdE)Lya1lJgCSLUfegQw6Cbr6ZdE)LyGLS2wdS2zPBbHHQLoeKWq1s)Lrdo2Q9LS2E)qRDw6VmAWXwTV0deMCcZw6IbEjQdE)LyGjnW4I6Lrdo2s3ccdvl9dE)LyGjnW4YswBVF)ANL(lJgCSv7l9aHjNWSLEeEkg4LOo49xIbM0aJlQxgn4yE2YtoKdatXiXx4QqJXQjGf3ifRI9CxpJ6s3ccdvlDGHVnPPiCzjRT3J71ol9xgn4yR2x6bctoHzlDoKdatXiXx4QqJXQjGf3ifRI9epEI7LUfegQw6HgJvtalUrkwfVKLSKLSK1ca]] )


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
