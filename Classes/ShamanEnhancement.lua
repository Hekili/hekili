-- ShamanEnhancement.lua
-- May 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local PTR = ns.PTR

-- Globals
local GetWeaponEnchantInfo = GetWeaponEnchantInfo

-- Conduits
-- [-] Chilled to the Core
-- [-] Focused Lightning
-- [-] Magma Fist
-- [-] Unruly Winds

-- Generate the Enhancement spec database only if you're actually a Shaman.
if UnitClassBase( "player" ) == "SHAMAN" then
    local spec = Hekili:NewSpecialization( 263 )

    spec:RegisterResource( Enum.PowerType.Mana )

    -- Talents
    spec:RegisterTalents( {
        lashing_flames = 22354, -- 334046
        forceful_winds = 22355, -- 262647
        elemental_blast = 22353, -- 117014

        stormflurry = 22636, -- 344357
        hot_hand = 23462, -- 201900
        ice_strike = 23109, -- 342240

        spirit_wolf = 23165, -- 260878
        earth_shield = 19260, -- 974
        static_charge = 23166, -- 265046

        elemental_assault = 23089, -- 210853
        hailstorm = 23090, -- 334195
        fire_nova = 22171, -- 333974

        natures_guardian = 22144, -- 30884
        feral_lunge = 22149, -- 196884
        wind_rush_totem = 21966, -- 192077

        crashing_storm = 21973, -- 192246
        stormkeeper = 22352, -- 320137
        sundering = 22351, -- 197214

        elemental_spirits = 21970, -- 262624
        earthen_spike = 22977, -- 188089
        ascendance = 21972, -- 114051
    } )


    -- PvP Talents
    spec:RegisterPvpTalents( {
        counterstrike_totem = 3489, -- 204331
        ethereal_form = 1944, -- 210918
        grounding_totem = 3622, -- 204336
        purifying_waters = 3492, -- 204247
        ride_the_lightning = 721, -- 289874
        shamanism = 722, -- 193876
        skyfury_totem = 3487, -- 204330
        spectral_recovery = 3519, -- 204261
        swelling_waves = 3623, -- 204264
        thundercharge = 725, -- 204366
    } )

    -- Auras
    spec:RegisterAuras( {
        ascendance = {
            id = 114051,
            duration = 15,
            max_stack = 1,
        },

        astral_shift = {
            id = 108271,
            duration = function () return level > 53 and 12 or 8 end,
            max_stack = 1,
        },

        chains_of_devastation_cl = {
            id = 336736,
            duration = 20,
            max_stack = 1,
        },

        chains_of_devastation_ch = {
            id = 336737,
            duration = 20,
            max_stack = 1
        },

        chill_of_the_twisting_nether = {
            id = 207998,
            duration = 8,
        },

        crackling_surge = {
            id = 224127,
            duration = 3600,
            max_stack = 1,
        },

        crash_lightning = {
            id = 187878,
            duration = 10,
            max_stack = 1,
        },

        crash_lightning_cl = {
            id = 333964,
            duration = 15,
            max_stack = 3
        },

        crashing_lightning = {
            id = 242286,
            duration = 16,
            max_stack = 15,
        },

        doom_winds = {
            id = 335903,
            duration = 8,
            max_stack = 1
        },

        doom_winds_cd = {
            id = 335904,
            duration = 60,
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

        earthen_spike = {
            id = 188089,
            duration = 10,
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

        -- Used to proc Maelstrom Weapon stacks.
        feral_spirit = {
            id = 333957,
            duration = 15,
            max_stack = 1,
        },

        fire_of_the_twisting_nether = {
            id = 207995,
            duration = 8,
        },

        flame_shock = {
            id = 188389,
            duration = 18,
            type = "Magic",
            max_stack = 1,
        },

        forceful_winds = {
            id = 262652,
            duration = 15,
            max_stack = 5,
        },

        frost_shock = {
            id = 196840,
            duration = 6,
            type = "Magic",
            max_stack = 1,
        },

        gathering_storms = {
            id = 198300,
            duration = 12,
            max_stack = 1,
        },

        ghost_wolf = {
            id = 2645,
            duration = 3600,
            type = "Magic",
            max_stack = 1,
        },

        hailstorm = {
            id = 334196,
            duration = 20,
            max_stack = 5,
        },

        hot_hand = {
            id = 215785,
            duration = 8,
            max_stack = 1,
        },

        ice_strike = {
            id = 342240,
            duration = 6,
            max_stack = 1,
        },

        icy_edge = {
            id = 224126,
            duration = 3600,
            max_stack = 1,
        },

        lashing_flames = {
            id = 334168,
            duration = 12,
            max_stack = 1,
        },

        legacy_of_the_frost_witch = {
            id = 335901,
            duration = 10,
            max_stack = 1,
        },

        lightning_crash = {
            id = 242284,
            duration = 16
        },

        lightning_shield = {
            id = 192106,
            duration = 1800,
            type = "Magic",
            max_stack = 1,
        },

        lightning_shield_overcharge = {
            id = 273323,
            duration = 10,
            max_stack = 1,
        },

        maelstrom_weapon = {
            id = 344179,
            duration = 30,
            max_stack = 10,
        },

        molten_weapon = {
            id = 271924,
            duration = 4,
        },

        primal_lava_actuators = {
            id = 335896,
            duration = 15,
            max_stack = 20,
        },

        reincarnation = {
            id = 20608,
        },

        resonance_totem = {
            id = 262417,
            duration = 120,
            max_stack =1 ,
        },

        shock_of_the_twisting_nether = {
            id = 207999,
            duration = 8,
        },

        spirit_walk = {
            id = 58875,
            duration = 8,
            max_stack = 1,
        },

        spirit_wolf = {
            id = 260881,
            duration = 3600,
            max_stack = 1,
        },

        storm_totem = {
            id = 262397,
            duration = 120,
            max_stack =1 ,
        },

        static_charge = {
            id = 118905,
            duration = 3,
            type = "Magic",
            max_stack = 1,
        },

        stormbringer = {
            id = 201845,
            duration = 12,
            max_stack = 1,
        },

        stormkeeper = {
            id = 320137,
            duration = 15,
            max_stack = 2,
        },

        sundering = {
            id = 197214,
            duration = 2,
            max_stack = 1,
        },

        tailwind_totem = {
            id = 262400,
            duration = 120,
            max_stack =1 ,
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

        windfury_totem = {
            id = 327942,
            duration = 120,
            max_stack = 1,
        },


        -- Azerite Powers
        ancestral_resonance = {
            id = 277943,
            duration = 15,
            max_stack = 1,
        },

        lightning_conduit = {
            id = 275391,
            duration = 60,
            max_stack = 1
        },

        primal_primer = {
            id = 273006,
            duration = 30,
            max_stack = 10,
        },

        roiling_storm = {
            id = 278719,
            duration = 3600,
            max_stack = 1,
        },

        strength_of_earth = {
            id = 273465,
            duration = 10,
            max_stack = 1,
        },

        thunderaans_fury = {
            id = 287802,
            duration = 6,
            max_stack = 1,
        },


        -- Legendaries
        legacy_oF_the_frost_witch = {
            id = 335901,
            duration = 10,
            max_stack = 1,
        },


        -- PvP Talents
        thundercharge = {
            id = 204366,
            duration = 10,
            max_stack = 1,
        },

        windfury_weapon = {
            duration = 3600,
            max_stack = 1,
        },

        flametongue_weapon = {
            duration = 1800,
            max_stack = 1,
        }
    } )


    spec:RegisterStateTable( "feral_spirit", setmetatable( {}, {
        __index = function( t, k )
            return buff.feral_spirit[ k ]
        end
    } ) )

    spec:RegisterStateTable( "twisting_nether", setmetatable( { onReset = function( self ) end }, {
        __index = function( t, k )
            if k == "count" then
                return ( buff.fire_of_the_twisting_nether.up and 1 or 0 ) + ( buff.chill_of_the_twisting_nether.up and 1 or 0 ) + ( buff.shock_of_the_twisting_nether.up and 1 or 0 )
            end

            return 0
        end
    } ) )


    spec:RegisterHook( "reset_precast", function ()
        local mh, _, _, mh_enchant, oh, _, _, oh_enchant = GetWeaponEnchantInfo()

        if mh and mh_enchant == 5401 then applyBuff( "windfury_weapon" ) end
        if oh and oh_enchant == 5400 then applyBuff( "flametongue_weapon" ) end

        if buff.windfury_totem.down and ( now - action.windfury_totem.lastCast < 1 ) then applyBuff( "windfury_totem" ) end
        if buff.windfury_weapon.down and ( now - action.windfury_weapon.lastCast < 1 ) then applyBuff( "windfury_weapon" ) end
        if buff.flametongue_weapon.down and ( now - action.flametongue_weapon.lastCast < 1 ) then applyBuff( "flametongue_weapon" ) end

        if settings.pad_windstrike and cooldown.windstrike.remains > 0 then
            reduceCooldown( "windstrike", latency * 2 )
        end
    end )


    spec:RegisterGear( "waycrest_legacy", 158362, 159631 )
    spec:RegisterGear( "electric_mail", 161031, 161034, 161032, 161033, 161035 )

    spec:RegisterGear( "tier21", 152169, 152171, 152167, 152166, 152168, 152170 )
        spec:RegisterAura( "force_of_the_mountain", {
            id = 254308,
            duration = 10
        } )
        spec:RegisterAura( "exposed_elements", {
            id = 252151,
            duration = 4.5
        } )

    spec:RegisterGear( "tier20", 147175, 147176, 147177, 147178, 147179, 147180 )
        spec:RegisterAura( "lightning_crash", {
            id = 242284,
            duration = 16
        } )
        spec:RegisterAura( "crashing_lightning", {
            id = 242286,
            duration = 16,
            max_stack = 15
        } )

    spec:RegisterGear( "tier19", 138341, 138343, 138345, 138346, 138348, 138372 )
    spec:RegisterGear( "class", 139698, 139699, 139700, 139701, 139702, 139703, 139704, 139705 )



    spec:RegisterGear( "akainus_absolute_justice", 137084 )
    spec:RegisterGear( "emalons_charged_core", 137616 )
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

    spec:RegisterGear( "smoldering_heart", 151819 )
    spec:RegisterGear( "soul_of_the_farseer", 151647 )
    spec:RegisterGear( "spiritual_journey", 138117 )
    spec:RegisterGear( "storm_tempests", 137103 )
    spec:RegisterGear( "uncertain_reminder", 143732 )


    spec:RegisterStateFunction( "consume_maelstrom", function( cap )
        local stacks = min( buff.maelstrom_weapon.stack, cap or 5 )

        if talent.hailstorm.enabled and stacks > buff.hailstorm.stack then
            applyBuff( "hailstorm", nil, stacks )
        end

        removeStack( "maelstrom_weapon", stacks )

        if legendary.legacy_oF_the_frost_witch.enabled and stacks == 5 then
            setCooldown( "stormstrike", 0 )
            setCooldown( "windstrike", 0 )
            setCooldown( "strike", 0 )
            applyBuff( "legacy_of_the_frost_witch" )
        end
    end )

    spec:RegisterStateFunction( "maelstrom_mod", function( amount )
        local mod = max( 0, 1 - ( 0.2 * buff.maelstrom_weapon.stack ) )
        return mod * amount
    end )

    spec:RegisterTotem( "windfury_totem", 136114 )


    spec:RegisterAbilities( {
        ascendance = {
            id = 114051,
            cast = 0,
            cooldown = 180,
            gcd = "off",

            readyTime = function() return buff.ascendance.remains end,

            toggle = "cooldowns",

            startsCombat = false,

            talent = "ascendance",
            nobuff = "ascendance",

            handler = function ()
                applyBuff( "ascendance" )
                setCooldown( "stormstrike", 0 )
                setCooldown( "windstrike", 0 )
            end,
        },

        astral_shift = {
            id = 108271,
            cast = 0,
            cooldown = 90,
            gcd = "off",

            startsCombat = false,

            handler = function ()
                applyBuff( "astral_shift" )
            end,
        },

        bloodlust = {
            id = function () return pvptalent.shamanism.enabled and 204361 or 2825 end,
            known = 2825,
            cast = 0,
            cooldown = 300,
            gcd = "off", -- Ugh.

            spend = 0.215,
            spendType = "mana",

            startsCombat = false,

            handler = function ()
                applyBuff( "bloodlust", 40 )
                if conduit.spiritual_resonance.enabled then
                    applyBuff( "spirit_walk", conduit.spiritual_resonance.mod * 0.001 )
                end
            end,

            copy = { 204361, 2825 }
        },

        capacitor_totem = {
            id = 192058,
            cast = 0,
            cooldown = function () return 60 + ( conduit.totemic_surge.mod * 0.001 ) end,
            gcd = "spell",

            spend = 0.1,
            spendType = "mana",

            startsCombat = true,
            texture = 136013,

            handler = function ()
            end,
        },

        chain_heal = {
            id = 1064,
            cast = function ()
                if buff.chains_of_devastation_cl.up then return 0 end
                return maelstrom_mod( 2.5 ) * haste
            end,
            cooldown = 0,
            gcd = "spell",

            spend = function () return maelstrom_mod( 0.3 ) end,
            spendType = "mana",

            startsCombat = true,
            texture = 136042,

            handler = function ()
                consume_maelstrom( 5 )

                removeBuff( "chains_of_devastation_ch" )
                if legendary.chains_of_devastation.enabled then
                    applyBuff( "chains_of_devastation_cl" )
                end
            end,
        },

        chain_lightning = {
            id = 188443,
            cast = function ()
                if buff.stormkeeper.up or buff.chains_of_devastation_cl.up then return 0 end
                return maelstrom_mod( 2 ) * haste
            end,
            cooldown = 0,
            gcd = "spell",

            spend = function () return maelstrom_mod( 0.01 ) end,
            spendType = "mana",

            startsCombat = true,
            texture = 136015,

            handler = function ()
                if level > 51 and active_enemies > 1 then
                    applyBuff( "crash_lightning_cl", nil, min( 3, active_enemies ) )
                end

                if buff.stormkeeper.up then
                    removeBuff( "stormkeeper" )
                    return
                end

                consume_maelstrom( 5 )                

                removeBuff( "chains_of_devastation_cl" )
                if legendary.chains_of_devastation.enabled then
                    applyBuff( "chains_of_devastation_ch" )
                end
            end,
        },

        cleanse_spirit = {
            id = 51886,
            cast = 0,
            cooldown = 8,
            gcd = "spell",

            spend = 0.06,
            spendType = "mana",

            startsCombat = true,
            texture = 236288,

            buff = "dispellable_curse",

            handler = function ()
                removeBuff( "dispellable_curse" )
            end,
        },

        crash_lightning = {
            id = 187874,
            cast = 0,
            cooldown = function () return 9 * haste end,
            gcd = "spell",

            startsCombat = true,

            handler = function ()
                if active_enemies >= 2 then
                    applyBuff( "crash_lightning", 10 )
                    applyBuff( "gathering_storms" )
                end

                removeBuff( "crashing_lightning" )
                removeBuff( "crash_lightning_cl" )
            end,
        },

        earth_elemental = {
            id = 198103,
            cast = 0,
            cooldown = 300,
            gcd = "spell",

            startsCombat = false,
            texture = 136024,

            toggle = "defensives",

            handler = function ()
                summonPet( "greater_earth_elemental", 60 )
                if conduit.vital_accretion.enabled then
                    applyBuff( "vital_accretion" )
                    health.max = health.max * ( 1 + ( conduit.vital_accretion.mod * 0.01 ) )
                end
            end,
        },

        earth_shield = {
            id = 204288,
            cast = 0,
            cooldown = 6,
            gcd = "spell",

            spend = 0.1,
            spendType = "mana",

            startsCombat = false,

            talent = "earth_shield",

            handler = function ()
                applyBuff( "earth_shield" )
                removeBuff( "lightning_shield" )
            end,
        },

        earthen_spike = {
            id = 188089,
            cast = 0,
            cooldown = function () return 20 * haste end,
            gcd = "spell",

            startsCombat = true,
            texture = 1016245,

            handler = function ()
                applyDebuff( "target", "earthen_spike" )

                if azerite.natural_harmony.enabled and buff.frostbrand.up then applyBuff( "natural_harmony_frost" ) end
                if azerite.natural_harmony.enabled and buff.flametongue.up then applyBuff( "natural_harmony_fire" ) end
                if azerite.natural_harmony.enabled then applyBuff( "natural_harmony_nature" ) end
            end,
        },

        earthbind_totem = {
            id = 2484,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            spend = 0.02,
            spendType = "mana",

            startsCombat = true,
            texture = 136102,

            handler = function ()
                applyDebuff( "target", "earthbind" )
            end,
        },

        elemental_blast = {
            id = 117014,
            cast = function () return maelstrom_mod( 2 ) * haste end,
            cooldown = 12,
            gcd = "spell",

            startsCombat = true,
            texture = 651244,

            handler = function ()
                consume_maelstrom( 5 )

                -- applies hailstorm (334196)
                -- applies elemental_blast_haste (173183)
                -- applies elemental_blast_mastery (173184)
                -- applies maelstrom_weapon (187881)
                -- removes lashing_flames (334168)
            end,
        },

        feral_spirit = {
            id = 51533,
            cast = 0,
            cooldown = function () return ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * ( 120 - ( talent.elemental_spirits.enabled and 30 or 0 ) ) end,
            gcd = "spell",

            startsCombat = false,
            toggle = "cooldowns",

            handler = function ()
                -- instant MW stack?
                applyBuff( "feral_spirit" )
            end
        },

        fire_nova = {
            id = 333974,
            cast = 0,
            cooldown = 15,
            gcd = "spell",

            startsCombat = true,
            texture = 459027,

            talent = "fire_nova",

            handler = function ()
            end,
        },

        flame_shock = {
            id = 188389,
            cast = 0,
            cooldown = 6,
            gcd = "spell",

            spend = 0.15,
            spendType = "mana",

            startsCombat = true,
            texture = 135813,

            handler = function ()
                applyDebuff( "target", "flame_shock" )

                setCooldown( "frost_shock", 6 * haste )
            end,
        },

        flametongue_weapon = {
            id = 318038,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            essential = true,

            startsCombat = false,
            texture = 135814,

            handler = function ()
                applyBuff( "flametongue_weapon" )
            end,
        },

        frost_shock = {
            id = 196840,
            cast = 0,
            cooldown = 6,
            gcd = "spell",

            startsCombat = true,
            texture = 135849,

            handler = function ()
                applyDebuff( "target", "frost_shock" )
                removeBuff( "hailstorm" )

                setCooldown( "flame_shock", 6 * haste )
            end,
        },

        ghost_wolf = {
            id = 2645,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = true,
            texture = 136095,

            handler = function ()
                applyBuff( "ghost_wolf" )
                if conduit.thunderous_paws.enabled then applyBuff( "thunderous_paws" ) end
            end,

            auras = {
                -- Conduit
                thunderous_paws = {
                    id = 338036,
                    duration = 3,
                    max_stack = 1
                }
            }
        },

        healing_stream_totem = {
            id = 5394,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            spend = 0.09,
            spendType = "mana",

            startsCombat = true,
            texture = 135127,

            handler = function ()
            end,
        },

        healing_surge = {
            id = 8004,
            cast = function () return maelstrom_mod( 1.5 ) * haste end,
            cooldown = 0,
            gcd = "spell",

            spend = function () return maelstrom_mod( 0.23 ) end,
            spendType = "mana",

            startsCombat = false,

            handler = function ()
                consume_maelstrom( 5 )
            end
        },


        heroism = {
            id = function () return pvptalent.shamanism.enabled and 204362 or 32182 end,
            cast = 0,
            cooldown = 300,
            gcd = "spell", -- Ugh.

            spend = 0.215,
            spendType = "mana",

            startsCombat = false,
            toggle = "cooldowns",

            handler = function ()
                applyBuff( "heroism" )
                applyDebuff( "player", "exhaustion", 600 )
            end,

            copy = { 204362, 32182 }
        },

        ice_strike = {
            id = 342240,
            cast = 0,
            cooldown = 15,
            gcd = "spell",
            
            startsCombat = true,
            texture = 135845,

            talent = "ice_strike",
            
            handler = function ()
                setCooldown( "frost_shock", 0 )
                setCooldown( "flame_shock", 0 )

                applyDebuff( "ice_strike" )
            end,
        },

        lava_lash = {
            id = 60103,
            cast = 0,
            cooldown = function () return ( buff.hot_hand.up and 4.5 or 18 ) * haste end,
            gcd = "spell",

            startsCombat = true,
            texture = 236289,

            handler = function ()
                removeDebuff( "target", "primal_primer" )

                if talent.lashing_flames.enabled then applyDebuff( "target", "lashing_flames" ) end

                removeBuff( "primal_lava_actuators" )

                if azerite.natural_harmony.enabled and buff.frostbrand.up then applyBuff( "natural_harmony_frost" ) end
                if azerite.natural_harmony.enabled then applyBuff( "natural_harmony_fire" ) end
                if azerite.natural_harmony.enabled and buff.crash_lightning.up then applyBuff( "natural_harmony_nature" ) end
            end,
        },

        lightning_bolt = {
            id = 188196,
            cast = function () return maelstrom_mod( 2 ) * haste end,
            cooldown = 0,
            gcd = "spell",

            startsCombat = true,

            handler = function ()
                if buff.stormkeeper.up then
                    removeBuff( "stormkeeper" )
                    return
                end

                consume_maelstrom( 5 )

                removeBuff( "primordial_wave" )

                if azerite.natural_harmony.enabled then applyBuff( "natural_harmony_nature" ) end
            end,
        },

        lightning_shield = {
            id = 192106,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = false,
            essential = true,

            timeToReady = function () return buff.lightning_shield.remains - 120 end,
            handler = function ()
                removeBuff( "earth_shield" )
                applyBuff( "lightning_shield" )
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

            toggle = "interrupts",
            interrupt = true,

            buff = "dispellable_magic",

            handler = function ()
                removeBuff( "dispellable_magic" )
            end,
        },

        spirit_walk = {
            id = 58875,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            startsCombat = false,
            texture = 132328,

            handler = function ()
                applyBuff( "spirit_walk" )
            end,
        },

        stormkeeper = {
            id = 320137,
            cast = function () return maelstrom_mod( 1.5 ) * haste end,
            cooldown = 60,
            gcd = "spell",

            startsCombat = false,
            texture = 839977,

            talent = "stormkeeper",

            handler = function ()
                applyBuff( "stormkeeper", nil, 2 )
                consume_maelstrom( 5 )
            end,
        },

        stormstrike = {
            id = 17364,
            cast = 0,
            cooldown = function() return gcd.execute * 6 end,
            gcd = "spell",

            rangeSpell = 73899,

            startsCombat = true,
            texture = 132314,

            bind = "windstrike",

            cycle = function () return azerite.lightning_conduit.enabled and "lightning_conduit" or nil end,

            nobuff = "ascendance",

            handler = function ()
                setCooldown( "windstrike", action.stormstrike.cooldown )
                setCooldown( "strike", action.stormstrike.cooldown )

                if buff.stormbringer.up then
                    removeBuff( "stormbringer" )
                end

                removeBuff( "gathering_storms" )

                if azerite.lightning_conduit.enabled then
                    applyDebuff( "target", "lightning_conduit" )
                end

                removeBuff( "strength_of_earth" )
                removeBuff( "legacy_of_the_frost_witch" )

                if talent.elemental_assault.enabled then
                    addStack( "maelstrom_weapon", nil, 1 )
                end

                if azerite.natural_harmony.enabled and buff.frostbrand.up then applyBuff( "natural_harmony_frost" ) end
                if azerite.natural_harmony.enabled and buff.flametongue.up then applyBuff( "natural_harmony_fire" ) end
                if azerite.natural_harmony.enabled and buff.crash_lightning.up then applyBuff( "natural_harmony_nature" ) end
            end,

            copy = "strike", -- copies this ability to this key or keys (if a table value)
        },

        sundering = {
            id = 197214,
            cast = 0,
            cooldown = 40,
            gcd = "spell",

            handler = function ()
                applyDebuff( "target", "sundering" )

                if azerite.natural_harmony.enabled and buff.flametongue.up then applyBuff( "natural_harmony_fire" ) end
            end,
        },

        thundercharge = {
            id = 204366,
            cast = 0,
            cooldown = 45,
            gcd = "spell",

            startsCombat = true,
            texture = 1385916,

            pvptalent = function () return not essence.conflict_and_strife.major and "thundercharge" or nil end,

            handler = function ()
                applyBuff( "thundercharge" )
            end,
        },

        tremor_totem = {
            id = 8143,
            cast = 0,
            cooldown = function () return 60 + ( conduit.totemic_surge.mod * 0.001 ) end,
            gcd = "spell",

            spend = 0.02,
            spendType = "mana",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 136108,

            handler = function ()
            end,
        },

        water_walking = {
            id = 546,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = true,
            texture = 135863,

            handler = function ()
                applyBuff( "water_walking" )
            end,
        },

        wind_rush_totem = {
            id = 192077,
            cast = 0,
            cooldown = 120,
            gcd = "spell",

            startsCombat = true,
            texture = 538576,

            handler = function ()
            end,
        },

        wind_shear = {
            id = 57994,
            cast = 0,
            cooldown = 12,
            gcd = "off",

            startsCombat = true,
            toggle = "interrupts",

            usable = function () return debuff.casting.up end,

            debuff = "casting",
            readyTime = state.timeToInterrupt,

            handler = function () interrupt() end,
        },

        windfury_totem = {
            id = 8512,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            essential = true,

            spend = 0.12,
            spendType = "mana",

            startsCombat = false,
            texture = 136114,

            handler = function ()
                applyBuff( "windfury_totem" )
                summonTotem( "windfury_totem", nil, 120 )

                if legendary.doom_winds.enabled and debuff.doom_winds_cd.down then
                    applyBuff( "doom_winds" )
                    applyDebuff( "player", "doom_winds_cd" )
                end
            end,
        },

        windfury_weapon = {
            id = 33757,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            essential = true,

            startsCombat = false,
            texture = 462329,

            handler = function ()
                applyBuff( "windfury_weapon" )
            end,
        },

        windstrike = {
            id = 115356,
            cast = 0,
            cooldown = function() return gcd.execute * 2 end,
            gcd = "spell",

            texture = 1029585,
            known = 17364,

            buff = "ascendance",

            bind = "stormstrike",

            handler = function ()
                setCooldown( "stormstrike", action.stormstrike.cooldown )
                setCooldown( "strike", action.stormstrike.cooldown )

                if buff.stormbringer.up then
                    removeBuff( "stormbringer" )
                end

                removeBuff( "gathering_storms" )
                removeBuff( "strength_of_earth" )
                removeBuff( "legacy_of_the_frost_witch" )

                if talent.elemental_assault.enabled then
                    addStack( "maelstrom_weapon", nil, 1 )
                end

                if azerite.natural_harmony.enabled and buff.frostbrand.up then applyBuff( "natural_harmony_frost" ) end
                if azerite.natural_harmony.enabled and buff.flametongue.up then applyBuff( "natural_harmony_fire" ) end
                if azerite.natural_harmony.enabled and buff.crash_lightning.up then applyBuff( "natural_harmony_nature" ) end
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

        potion = "superior_battle_potion_of_agility",

        package = "Enhancement",
    } )


    spec:RegisterSetting( "pad_windstrike", true, {
        name = "Pad |T1029585:0|t Windstrike Cooldown",
        desc = "If checked, the addon will treat |T1029585:0|t Windstrike's cooldown as slightly shorter, to help ensure that it is recommended as frequently as possible during Ascendance.",
        type = "toggle",
        width = 1.5
    } )


    spec:RegisterPack( "Enhancement", 20201020, [[deeeMaqiKcpsruBsPiFsregLsrXPuerVsrzwkvDlfHs7sQ(LI0WuQCmfvltO0ZukmnfbDnskBtriFdPOACkc4CkI08qkY9eyFcfhurOQfku9qfHkxePOCsLIQvIuDtfbIDss(PsrPLQiu8usnvb1wveO8vfbQ2lL)QQgmjomQfRkpgYKr4YGnRWNrKrRKoTKxJOMnHBJKDl63QmCLy5e9COMovxxiBxP03fKXRiq68KunFKs7xkBZTWMMGDWuf7Uy3nFxS76ZN0nMVBsnTR(cy6fgrMjbMozkW00SCLteqbPB6fwDXXewytJVijcm9MJuFIDcguj20VOs4BEApttWoyQIDxS7MVl2D95t6gZ3PMPXlaYuf7eTHPxlcciTNPjamY0tUPqZYvorafKEtrVYuC2Op5MYMf53dKnLy3TVPe7Uy31O3Op5MYepbbq0uM4UTqYP3u4xjkVaCVrFYnLjga7NeAk0mmgseG7MwuyhBHnnUsscWcBQMBHnnK8taewCtJKLdYInnnAkVOXOVilQtsuS4hI3c9OLMYMAkBMMcnAkolG07y)KuKbybKDi5NaiAk0sBt5fngDSFskYaSaYE0stzsAAg51LMErwuNKOyXpeVfm3ufRf20qYpbqyXnnswoil200OP4fICLKmnJ86stpemf8XRhIS5MQnSWMMrEDPP3c4fq(9Zbktdj)eaHf3Ct1eAHnnK8taewCtJKLdYIn9lAm6RCjW(jP6rlMMrEDPPhYd7F86HiBUPsnlSPzKxxAAGL(kKF8srgmnK8taewCZnvtKf20mYRln9GHVl5epIW1LMgs(jaclU5MkAUf20qYpbqyXnnswoil20VOXOJ9tsrgGfq2JwAkBQP8IgJofdcSlpQFiGxUSJDgrUPetqtrntZiVU00II0QNvs6)oHBUPAcyHnnK8taewCtJKLdYIn9lAm6umiWU8O(HaE5Yo2ze5Msmbnf1mnJ86stdcGcsNf)NGXU5MQj1cBAi5NaiS4MgjlhKfB6x0y0PyqGD5r9db8YLDSZiYnLycAkQzAg51LMgTYv(xz5wa7MBQMVZcBAi5NaiS4MgjlhKfB6x0y0PyqGD5r9db8YLDSZiYnLGMY8DMMrEDPPffPvpRK0)Dc3Ct185wytdj)eaHf30iz5GSyt)IgJ(65)voj6rlMMrEDPPf8w(ly8Q5MQ5XAHnnJ86stJ9tsHDzrgmnK8taewCZnvZ3WcBAi5NaiS4MgjlhKfB6x0y0PyqGD5r9db8YLDSZiYnLycAkQzAg51LMg7NKImalG0Ct18j0cBAg51LMwWB5VGXRMgs(jaclU5MQ5QzHnnJ86stJKmE9lksREwjjtdj)eaHf3Ct18jYcBAi5NaiS4MMrEDPPhcMc(41dr20iz5GSytlHHeWR8taMgPosaFNLKahBQMBUPAon3cBAg51LMEipS)XRhISPHKFcGWIBUPA(eWcBAg51LMUqWh7YImyAi5NaiS4MBQMpPwytZiVU004OKaKvsY0qYpbqyXn3uf7olSPHKFcGWIBAKSCqwSPzKxBHpX59HGPGpE9qKnnJ86stpkj8ZBlBUPk25wytdj)eaHf30iz5GSyt)IgJofdcSlpQFiGxUSJDgrUPetqtrntZiVU00II0QNvs6)oHBUPk2yTWMMrEDPPbw6RFqauq6SW0qYpbqyXn3uf7gwytdj)eaHf30iz5GSyt)IgJEOkjgrs1)(5avxcuCL4Mcn1u2yNPzKxxA6qvsmIKQ)9ZbkZn308bwyt1ClSPHKFcGWIBAKSCqwSPFrJrFLlb2pjvpAX0mYRln9qEy)JxpezZnvXAHnnK8taewCtJKLdYInnJ8Al8joVpemf8XRhICtjMGMYgMMrEDPPhLe(5TLn3uTHf20qYpbqyXnnJ86stpemf8XRhISPrYYbzXM2zbKEFus4N3wUdj)eartHwABkOBlKC69eqYtCsctJuhjGVZssGJnvZn3unHwytdj)eaHf30mYRln9ISOojrXIFiElyAKSCqwSPPrt5fng9fzrDsIIf)q8wOhT0u2utzZ0uOrtXzbKEh7NKImalGSdj)eartHwABkVOXOJ9tsrgGfq2JwAktstJuhjGVZssGJnvZn3uPMf20mYRln9waVaYVFoqzAi5NaiS4MBQMilSPHKFcGWIBAKSCqwSPFrJrFrwuNKOyXpeVf6rlnLn1uErJrNIbb2Lh1peWlx2XoJi3uIjOPOMPzKxxAArrA1Zkj9FNWn3urZTWMMrEDPPrsgV(ffPvpRKKPHKFcGWIBUPAcyHnnK8taewCtJKLdYIn9lAm6y)KuKbybK9OLMYMAkVOXOtXGa7YJ6hc4Ll7yNrKBkXe0uuZ0mYRlnnALR8lksREwjjZnvtQf20qYpbqyXnnswoil20VOXOtXGa7YJ6hc4Ll7yNrKBkXe0uuZ0mYRlnnALR8VYYTa2n3unFNf20qYpbqyXnnswoil20VOXOtXGa7YJ6hc4Ll7yNrKBkXe0uuRPSPMcJ8Al8HeOka3uOrqtzdtZiVU00GaOG0zX)jySBUPA(ClSPHKFcGWIBAKSCqwSPFrJrNIbb2Lh1peWlx2XoJi3uIjOPOMPzKxxAASFskYaSasZnvZJ1cBAi5NaiS4MgjlhKfB6x0y0PyqGD5r9db8YLDSZiYnLGMY8DMMrEDPPrRCLFrrA1ZkjzUPA(gwytdj)eaHf30mYRln9qWuWhVEiYMgjlhKfBANfq69rjHFEB5oK8taeMgPosaFNLKahBQMBUPA(eAHnnJ86stJJscqwjjtdj)eaHf3Ct1C1SWMMrEDPPX(jPWUSidMgs(jaclU5MQ5tKf20mYRlnTG3YFbJxnnK8taewCZnvZP5wytdj)eaHf30mYRln9qWuWhVEiYMgjlhKfBAjmKaELFcW0i1rc47SKe4yt1CZnvZNawytdj)eaHf30iz5GSyt)IgJofdcSlpQFiGxUSJDgrUPetqtrTMYMAkmYRTWhsGQaCtjOPSHPzKxxAAqauq6S4)em2n3unFsTWMMrEDPPhm8DjN4reUU00qYpbqyXn3uf7olSPzKxxA6H8W(hVEiYMgs(jaclU5MQyNBHnnJ86stxi4JDzrgmnK8taewCZnvXgRf20qYpbqyXnnswoil20VOXOtXGa7YJ6hc4Ll7yNrKBkXe0uuZ0mYRlnnALR8lksREwjjZnvXUHf20qYpbqyXnnswoil20mYRTWN48(qWuWhVEiYnLyAkZnnJ86stpkj8ZBlBUPk2j0cBAg51LMgyPVc5hVuKbtdj)eaHf3CtvSQzHnnJ86stdS0x)GaOG0zHPHKFcGWIBUPk2jYcBAi5NaiS4MgjlhKfB6x0y0dvjXisQ(3phO6sGIRe3uOPMYg7mnJ86sthQsIrKu9VFoqzU5MMagCKWTWMQ5wytZiVU00pXDeIiSBAi5NaiSN5MQyTWMgs(jaclUPrYYbzXMEuKw9VeO4kXnfAQPmr7mnJ86stVCEDP5MQnSWMMrEDPPdvjXhVcS00qYpbqyXn3unHwytZiVU00HQKa7YImyAi5NaiS4MBQuZcBAg51LMEfyP)bmgseyAi5NaiS4MBQMilSPzKxxA6im8lhOWMgs(jaclU5MkAUf20qYpbqyXnnswoil200OP4SasVZyeKeCIGoK8taenfAPTP8IgJoJrqsWjc6rlnfAPTPGUtqCHYoJrqsWjc6sGIRe3uIPPO2otZiVU00pXDe)rKuDZnvtalSPHKFcGWIBAKSCqwSPPrtXzbKENXiij4ebDi5NaiAk0sBt5fngDgJGKGte0JwmnJ86st)ajgKKRKK5MQj1cBAi5NaiS4MgjlhKfBAA0uCwaP3zmcscorqhs(jaIMcT02uErJrNXiij4eb9OLMcT02uq3jiUqzNXiij4ebDjqXvIBkX0uuBNPzKxxA6rjHN4ocZnvZ3zHnnK8taewCtJKLdYInnnAkolG07mgbjbNiOdj)eartHwABkVOXOZyeKeCIGE0stHwABkO7eexOSZyeKeCIGUeO4kXnLyAkQTZ0mYRlnnNia7sw8rSqyUPA(ClSPHKFcGWIBAKSCqwSPPrtXzbKENXiij4ebDi5NaiAk0sBtHgnLx0y0zmcscorqpAX0mYRln9Jj9VX3LfIm2Ct18yTWMMrEDPPhGKfF8sjl30qYpbqyXn3unFdlSPzKxxAAgJGKGteyAi5NaiS4MBQMpHwytdj)eaHf30iz5GSytZiV2cFibQcWnLGMYCtZiVU00iwi(mYRl)Ic7Mwuy)NmfyACLKeG5MQ5QzHnnK8taewCtJKLdYInnJ8Al8HeOka3uIPPm30mYRlnnIfIpJ86YVOWUPff2)jtbMMpWCZn9Ieqh1JDlSPAUf20qYpbqyXnnswoil20VOXOhQsIrKu9FiGxUSlbkUsCtHMAkBSBNPzKxxA6qvsmIKQ)db8YLMBQI1cBAi5NaiS4MgjlhKfB6x0y0hcMc8ljfb)qaVCzxcuCL4Mcn1u2y3otZiVU00dbtb(LKIGFiGxU0Ct1gwytdj)eaHf30iz5GSyt)IgJUOiT6zLK(41ceeDjqXvIBk0utzJD7mnJ86stlksREwjPpETabH5MQj0cBAi5NaiS4MgjlhKfB6x0y0dvjXisQ(3phO6exO00mYRlnDOkjgrs1)(5aL5Mk1SWMgs(jaclUPrYYbzXM2zbKEh7NKImalGSdj)eaHPzKxxAASFskYaSasZn3CtVfK46stvS7ID38DXUZ0HyzwjjSP3CQLt6artzcBkmYRlBkIc74EJUP5iF9KMEc(jjIwm9I8gLam9KBk0SCLteqbP3u0RmfNn6tUPSzr(9aztj2D7BkXUl2Dn6n6tUPmXtqaenLjUBlKC6nf(vIYla3B0NCtzIbW(jHMcndJHeb4EJEJoJ86sCFrcOJ6XEqOkjgrs1)HaE5Y91i4fng9qvsmIKQ)db8YLDjqXvIPPn2TRrNrEDjUVib0r9yFwW0HGPa)ssrWpeWlxUVgbVOXOpemf4xskc(HaE5YUeO4kX00g721OZiVUe3xKa6OESplyQOiT6zLK(41cee7RrWlAm6II0QNvs6Jxlqq0LafxjMM2y3UgDg51L4(Ieqh1J9zbtdvjXisQ(3phO2xJGx0y0dvjXisQ(3phO6exOSrNrEDjUVib0r9yFwWuSFskYaSaY91iWzbKEh7NKImalGSdj)earJEJ(KBk0SjOakYbIMcSfKQ3u8IcAk(k0uyKFYMsHBk8wUe8ta9gDg51L4GN4ocre2B0NCtzZZjw0r9yVPSCEDztPWnLhmoj0uqh1J9McKe4EJoJ86s8SGPlNxxUVgbJI0Q)LafxjMMMODn6tUPS5Pdsz0I3uUrtbXyh3B0zKxxINfmnuLeF8kWYgDg51L4zbtdvjb2LfzOrNrEDjEwW0vGL(hWyirqJoJ86s8SGPry4xoqHB0zKxxINfm9jUJ4pIKQVVgb0WzbKENXiij4ebDi5NaiOL2x0y0zmcscorqpAHwAr3jiUqzNXiij4ebDjqXvIJrTDn6mYRlXZcM(ajgKKRK0(AeqdNfq6DgJGKGte0HKFcGGwAFrJrNXiij4eb9OLgDg51L4zbthLeEI7i2xJaA4SasVZyeKeCIGoK8tae0s7lAm6mgbjbNiOhTqlTO7eexOSZyeKeCIGUeO4kXXO2UgDg51L4zbt5ebyxYIpIfI91iGgolG07mgbjbNiOdj)eabT0(IgJoJrqsWjc6rl0sl6obXfk7mgbjbNiOlbkUsCmQTRrNrEDjEwW0ht6FJVllez8(AeqdNfq6DgJGKGte0HKFcGGwAPXlAm6mgbjbNiOhT0OZiVUeply6aKS4Jxkz5n6mYRlXZcMYyeKeCIGg9j3u28rt5sH6nLlHMcKaL67BklY6KLREtzCcXfc3u8vOPmjWvssatIMcJ86YMIOWEVrNrEDjEwWueleFg51LFrH99jtbb4kjjG91iGrETf(qcufGdM3Op5MYMnBkurcVweqtbsGQa8(MIVcnLfzDYYvVPmoH4cHBk(k0uMe8btIMcJ86YMIOWEVrNrEDjEwWueleFg51LFrH99jtbb8b7RraJ8Al8HeOkahZ8g9g9j3uMGej8QP4SKe4nfg51LnLfzDYYvVPikS3OZiVUe35dcgYd7F86HiVVgbVOXOVYLa7NKQhT0OZiVUe35dMfmDus4N3wEFncyKxBHpX59HGPGpE9qKJjyJgDg51L4oFWSGPdbtbF86HiVhPosaFNLKahhmFFncCwaP3hLe(5TL7qYpbqqlTOBlKC69eqYtCsIgDg51L4oFWSGPlYI6Kefl(H4TWEK6ib8DwscCCW891iGgVOXOVilQtsuS4hI3c9OLnTzOHZci9o2pjfzawazhs(jacAP9fngDSFskYaSaYE0YKSrNrEDjUZhmly6waVaYVFoq1OZiVUe35dMfmvuKw9Sss)3j891i4fng9fzrDsIIf)q8wOhTSPx0y0PyqGD5r9db8YLDSZiYXeOwJoJ86sCNpywWuKKXRFrrA1Zkj1OZiVUe35dMfmfTYv(ffPvpRK0(Ae8IgJo2pjfzawazpAztVOXOtXGa7YJ6hc4Ll7yNrKJjqTgDg51L4oFWSGPOvUY)kl3cyFFncErJrNIbb2Lh1peWlx2XoJihtGAn6mYRlXD(GzbtbbqbPZI)tWyFFncErJrNIbb2Lh1peWlx2XoJihtGABIrETf(qcufGPrWgn6mYRlXD(GzbtX(jPidWci3xJGx0y0PyqGD5r9db8YLDSZiYXeOwJoJ86sCNpywWu0kx5xuKw9Sss7RrWlAm6umiWU8O(HaE5Yo2ze5G57A0zKxxI78bZcMoemf8XRhI8EK6ib8DwscCCW891iWzbKEFus4N3wUdj)earJoJ86sCNpywWuCusaYkj1OZiVUe35dMfmf7NKc7YIm0OZiVUe35dMfmvWB5VGXRn6mYRlXD(GzbthcMc(41drEpsDKa(oljbooy((AeiHHeWR8tan6mYRlXD(GzbtbbqbPZI)tWyFFncErJrNIbb2Lh1peWlx2XoJihtGABIrETf(qcufGd2OrNrEDjUZhmly6GHVl5epIW1Ln6mYRlXD(GzbthYd7F86Hi3OZiVUe35dMfmTqWh7YIm0OZiVUe35dMfmfTYv(ffPvpRK0(Ae8IgJofdcSlpQFiGxUSJDgroMa1A0zKxxI78bZcMokj8ZBlVVgbmYRTWN48(qWuWhVEiYXmVrNrEDjUZhmlykWsFfYpEPidn6mYRlXD(Gzbtbw6RFqauq6SOrNrEDjUZhmlyAOkjgrs1)(5a1(Ae8IgJEOkjgrs1)(5avxcuCLyAAJDn6n6tUPORKKaAkoljbEtHrEDztzrwNSC1BkIc7n6mYRlXDCLKeqWISOojrXIFiElSVgb04fng9fzrDsIIf)q8wOhTSPndnCwaP3X(jPidWci7qYpbqqlTVOXOJ9tsrgGfq2JwMKn6mYRlXDCLKeWSGPdbtbF86HiVVgb0Wle5kj1OZiVUe3XvssaZcMUfWlG87Ndun6mYRlXDCLKeWSGPd5H9pE9qK3xJGx0y0x5sG9ts1JwA0zKxxI74kjjGzbtbw6Rq(XlfzOrNrEDjUJRKKaMfmDWW3LCIhr46YgDg51L4oUsscywWurrA1Zkj9FNW3xJGx0y0X(jPidWci7rlB6fngDkgeyxEu)qaVCzh7mICmbQ1OZiVUe3XvssaZcMccGcsNf)NGX((Ae8IgJofdcSlpQFiGxUSJDgroMa1A0zKxxI74kjjGzbtrRCL)vwUfW((Ae8IgJofdcSlpQFiGxUSJDgroMa1A0zKxxI74kjjGzbtffPvpRK0)DcFFncErJrNIbb2Lh1peWlx2XoJihmFxJoJ86sChxjjbmlyQG3YFbJx3xJGx0y0xp)VYjrpAPrNrEDjUJRKKaMfmf7NKc7YIm0OZiVUe3XvssaZcMI9tsrgGfqUVgbVOXOtXGa7YJ6hc4Ll7yNrKJjqTgDg51L4oUsscywWubVL)cgV2OZiVUe3XvssaZcMIKmE9lksREwjPgDg51L4oUsscywW0HGPGpE9qK3JuhjGVZssGJdMVVgbsyib8k)eqJoJ86sChxjjbmly6qEy)Jxpe5gDg51L4oUsscywW0cbFSllYqJoJ86sChxjjbmlykokjazLKA0zKxxI74kjjGzbthLe(5TL3xJag51w4tCEFiyk4Jxpe5gDg51L4oUsscywWurrA1Zkj9FNW3xJGx0y0PyqGD5r9db8YLDSZiYXeOwJoJ86sChxjjbmlykWsF9dcGcsNfn6mYRlXDCLKeWSGPHQKyejv)7Ndu7RrWlAm6HQKyejv)7NduDjqXvIPPn2zU5Mb]] )

end
