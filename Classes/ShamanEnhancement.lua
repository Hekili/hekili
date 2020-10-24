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
            shared = "player",
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


    spec:RegisterPack( "Enhancement", 20201024, [[dae5PaqiOk9ivbTjOk6tkHuJsjeDkOkWRKcZcQ0Tucb2LI(Lu0WufDmLOLrs8mvHMMsOUMa12ijLVrscJJKuDossY8uf4EcAFkbheQcXcfIhQesUijj6KKKuRePCtLqq7KK6NqvOwQsi0tj1ufWEP8xLAWK4WOwSQ6XqMmuUmyZk8zvPrRKoTKxJunBIUns2TOFRYWLslNWZrmDQUUqTDOIVlKgpufsNxGSEOkO5dv1(LQTLwatJXoyQv5Pkpx(uLfpFQ6bV4fRIP9GAbt3Yi68ly6KPatRkZvorafKUPB5GKhJzbmn5IfiW06IArz6FCjDvDAFtJXoyQv5Pkpx(uLfpFQ6bV4hxSPjTaYuRIQ9OPxlmmiTVPXacY0pSROkZvorafKExrVYuC2P9WUcEmYVpi6kQ8e3UIkpv5zNwN2d7k4rWWaSUYI6Wbso9Uc)lz5fqMDApSRSice)eqxrvsiqIaY00YI4elGPjv(kblGPEPfW0qYFjGzrmnsuoik204TR8JhJzROOobwXYDughyg32vWZUYISRG3UIZsi9jXpbfDaAbXes(lbSUc(43v(XJXK4NGIoaTGyg32vWdmnJ86st3kkQtGvSChLXbm3uRIfW0qYFjGzrmnsuoik204TR4fIELVMMrEDPPhsMc2K1dr3Ct9JwatZiVU004aKwqS9Zbktdj)LaMfXCt9ITaMgs(lbmlIPrIYbrXM(hpgZvUKe)euZ4wtZiVU00dXr8nz9q0n3uhSfW0mYRlnnWcFfYnPTOdMgs(lbmlI5MAvZcyAg51LMEWW2fCsgXK6stdj)LaMfXCtTQWcyAi5VeWSiMgjkhefB6F8ymj(jOOdqliMXTDf8SR8JhJjfdsIloQDuGBVCsCgrVRSqyxjytZiVU00Y6D1ZkF3)t6MBQvDlGPHK)saZIyAKOCquSP)XJXKIbjXfh1okWTxojoJO3vwiSReSPzKxxAAqcuq6SC)LmXn3uRQSaMgs(lbmlIPrIYbrXM(hpgtkgKexCu7Oa3E5K4mIExzHWUsWMMrEDPPrRCL7vwGdqCZn1lFAbmnK8xcywetJeLdIIn9pEmMumijU4O2rbU9YjXze9Usyxz5ttZiVU00Y6D1ZkF3)t6MBQxU0cyAi5VeWSiMgjkhefB6F8ymxpFVYj2mU10mYRlnTKXH3sMSAUPEPkwatZiVU00e)euexu0btdj)LaMfXCt9YhTaMgs(lbmlIPrIYbrXM(hpgtkgKexCu7Oa3E5K4mIExzHWUsWMMrEDPPj(jOOdqlim3uVCXwatZiVU00sghElzYQPHK)saZIyUPEzWwatZiVU00ibtw3Y6D1ZkFnnK8xcyweZn1lvnlGPHK)saZIyAg51LMEizkytwpeDtJeLdIInTagcGSYFjyAuqijSDw8coXuV0Ct9svHfW0mYRln9qCeFtwpeDtdj)LaMfXCt9sv3cyAg51LMUqWM4IIoyAi5VeWSiMBQxQQSaMMrEDPPjXjgiQ810qYFjGzrm3uRYtlGPHK)saZIyAKOCquSPzKx4aBSZNdjtbBY6HOBAg51LMEucyNhoS5MAvwAbmnK8xcywetJeLdIIn9pEmMumijU4O2rbU9YjXze9UYcHDLGnnJ86stlR3vpR8D)pPBUPwfvSaMMrEDPPbw4RBqcuq6S00qYFjGzrm3uRYJwatdj)LaMfX0ir5GOyt)JhJz0kXgXIG2(5a1uauCLKUYd6kp(00mYRlnD0kXgXIG2(5aL5MBA(alGPEPfW0qYFjGzrmnsuoik20)4XyUYLK4NGAg3AAg51LMEioIVjRhIU5MAvSaMgs(lbmlIPrIYbrXMMrEHdSXoFoKmfSjRhIExzHWUYJMMrEDPPhLa25HdBUP(rlGPHK)saZIyAg51LMEizkytwpeDtJeLdIInTZsi95OeWopC4jK8xcyDf8XVRGoCGKtFMasCYtGzAuqijSDw8coXuV0Ct9ITaMgs(lbmlIPzKxxA6wrrDcSIL7OmoGPrIYbrXMgVDLF8ymBff1jWkwUJY4aZ42UcE2vwKDf82vCwcPpj(jOOdqliMqYFjG1vWh)UYpEmMe)eu0bOfeZ42UcEGPrbHKW2zXl4et9sZn1bBbmnJ86stJdqAbX2phOmnK8xcyweZn1QMfW0qYFjGzrmnsuoik20)4Xy2kkQtGvSChLXbMXTDf8SR8JhJjfdsIloQDuGBVCsCgrVRSqyxjytZiVU00Y6D1ZkF3)t6MBQvfwatZiVU00ibtw3Y6D1ZkFnnK8xcyweZn1QUfW0qYFjGzrmnsuoik20)4Xys8tqrhGwqmJB7k4zx5hpgtkgKexCu7Oa3E5K4mIExzHWUsWMMrEDPPrRCLBz9U6zLVMBQvvwatdj)LaMfX0ir5GOyt)JhJjfdsIloQDuGBVCsCgrVRSqyxjytZiVU00OvUY9klWbiU5M6LpTaMgs(lbmlIPrIYbrXM(hpgtkgKexCu7Oa3E5K4mIExzHWUsWDf8SRWiVWb2qcufq6k4nSR8OPzKxxAAqcuq6SC)LmXn3uVCPfW0qYFjGzrmnsuoik20)4XysXGK4IJAhf42lNeNr07kle2vc20mYRlnnXpbfDaAbH5M6LQybmnK8xcywetJeLdIIn9pEmMumijU4O2rbU9YjXze9Usyxz5ttZiVU00OvUYTSEx9SYxZn1lF0cyAi5VeWSiMMrEDPPhsMc2K1dr30ir5GOyt7SesFokbSZdhEcj)LaMPrbHKW2zXl4et9sZn1lxSfW0mYRlnnjoXarLVMgs(lbmlI5M6LbBbmnJ86stt8tqrCrrhmnK8xcyweZn1lvnlGPzKxxAAjJdVLmz10qYFjGzrm3uVuvybmnK8xcywetZiVU00djtbBY6HOBAKOCquSPfWqaKv(lbtJccjHTZIxWjM6LMBQxQ6watdj)LaMfX0ir5GOyt)JhJjfdsIloQDuGBVCsCgrVRSqyxj4UcE2vyKx4aBibQciDLWUYJMMrEDPPbjqbPZY9xYe3Ct9svLfW0mYRln9GHTl4KmIj1LMgs(lbmlI5MAvEAbmnJ86stpehX3K1dr30qYFjGzrm3uRYslGPzKxxA6cbBIlk6GPHK)saZIyUPwfvSaMgs(lbmlIPrIYbrXM(hpgtkgKexCu7Oa3E5K4mIExzHWUsWMMrEDPPrRCLBz9U6zLVMBQv5rlGPHK)saZIyAKOCquSPzKx4aBSZNdjtbBY6HO3vwORS00mYRln9OeWopCyZn1QSylGPzKxxAAGf(kKBsBrhmnK8xcyweZn1QeSfW0mYRlnnWcFDdsGcsNLMgs(lbmlI5MAvunlGPHK)saZIyAKOCquSP)XJXmALyJyrqB)CGAkakUssx5bDLhFAAg51LMoALyJyrqB)CGYCZnngm4yPBbm1lTaMMrEDPP)Y7WKXe30qYFjGzFZn1QybmnK8xcywetJeLdIIn9OEx9TaO4kjDLh0vuTNMMrEDPPBpVU0Ct9JwatZiVU00rReBtwbwyAi5VeWSiMBQxSfW0mYRlnD0kXiUOOdMgs(lbmlI5M6GTaMMrEDPPxbw4BGqGebMgs(lbmlI5MAvZcyAg51LMoMa7YbkIPHK)saZIyUPwvybmnK8xcywetJeLdIInnE7kolH0NmbbjgNiycj)LawxbF87k)4XyYeeKyCIGzCBxbF87kO7Kyx0CYeeKyCIGPaO4kjDLf6kb)00mYRln9xEh2EelcYCtTQBbmnK8xcywetJeLdIInnE7kolH0NmbbjgNiycj)LawxbF87k)4XyYeeKyCIGzCRPzKxxA6piiGGELVMBQvvwatdj)LaMfX0ir5GOytJ3UIZsi9jtqqIXjcMqYFjG1vWh)UYpEmMmbbjgNiyg32vWh)Uc6oj2fnNmbbjgNiykakUssxzHUsWpnnJ86stpkb8L3HzUPE5tlGPHK)saZIyAKOCquSPXBxXzjK(KjiiX4ebti5VeW6k4JFx5hpgtMGGeJtemJB7k4JFxbDNe7IMtMGGeJtemfafxjPRSqxj4NMMrEDPP5ebexWYnILsZn1lxAbmnJ86stJUebPlyhW2djtbMgs(lbmlI5M6LQybmnJ86st)L3HTVX2xHnKavqMgs(lbmlI5M6LpAbmnJ86st)gZcSIZ9n2mEiioF10qYFjGzrm3uVCXwatZiVU00JdftaSnJhcIYH9hyktdj)LaMfXCt9YGTaMMrEDPPBJf1iOkF3FjtCtdj)LaMfXCt9svZcyAg51LM2xHDC(V4eBpobcmnK8xcyweZn1lvfwatZiVU00ua1jcAFJTmgvyBmbWuetdj)LaMfXCt9sv3cyAg51LMwuTTsyx5M0YiW0qYFjGzrm3uVuvzbmnJ86sth9esmCGk3cGCjNiW0qYFjGzrm3uRYtlGPHK)saZIyAKOCquSPDw8c(CfyPVUBrExzHUIQ)SRGp(DfNfVGpxbw6R7wK3vEqxrLNDf8XVRmQ3vFlakUssx5bDLhFAAg51LMwaCBLV7HKPaI5MAvwAbmnJ86stVcSW3aHajcmnK8xcyweZn1QOIfW0qYFjGzrmnsuoik204TR4SesFYeeKyCIGjK8xcyDf8XVRG3UYpEmMmbbjgNiyg3AAg51LM(ZV7BSDrHOtm3uRYJwatZiVU00dqWYnPTeLBAi5VeWSiMBQvzXwatZiVU00mbbjgNiW0qYFjGzrm3uRsWwatdj)LaMfX0ir5GOytZiVWb2qcufq6kHDLLMMrEDPPrSuUzKxxULfXnTSi(ozkW0KkFLG5MAvunlGPHK)saZIyAKOCquSPzKx4aBibQciDLf6klnnJ86stJyPCZiVUCllIBAzr8DYuGP5dm3Ct3ka0r9z3cyQxAbmnK8xcywetJeLdIIn9pEmMrReBelcAhf42lNcGIRK0vEqx5XNpnnJ86sthTsSrSiODuGBV0CtTkwatdj)LaMfX0ir5GOyt)JhJ5qYuGF5BmSJcC7LtbqXvs6kpOR84ZNMMrEDPPhsMc8lFJHDuGBV0Ct9Jwatdj)LaMfX0ir5GOyt)JhJPSEx9SY3nzTaj2uauCLKUYd6kp(8PPzKxxAAz9U6zLVBYAbsmZn1l2cyAi5VeWSiMgjkhefB6F8ymJwj2iwe02phOMyx000mYRlnD0kXgXIG2(5aL5M6GTaMgs(lbmlIPrIYbrXM2zjK(K4NGIoaTGycj)LaMPzKxxAAIFck6a0ccZn3CtJdii1LMAvEQYZLpv5PPJYISYxIPv1uTNWbSUYI7kmYRl7kYI4KzNMPBf3OKGPFyxrvMRCIaki9UIELP4St7HDf8yKFFq0vu5jUDfvEQYZoToTh2vWJGHbyDLf1HdKC6Df(xYYlGm70Eyxzrei(jGUIQKqGebKzNwNgJ86sYSvaOJ6ZEy0kXgXIG2rbU9sCRr4pEmMrReBelcAhf42lNcGIRK8GhF(StJrEDjz2ka0r9zVryZHKPa)Y3yyhf42lXTgH)4XyoKmf4x(gd7Oa3E5uauCLKh84ZNDAmYRljZwbGoQp7ncBkR3vpR8DtwlqIHBnc)XJXuwVREw57MSwGeBkakUsYdE85Zong51LKzRaqh1N9gHnJwj2iwe02phOWTgH)4XygTsSrSiOTFoqnXUOzNgJ86sYSvaOJ6ZEJWMe)eu0bOfe4wJqNLq6tIFck6a0cIjK8xcyDADApSROkXJcOyhW6kaoGiOUIxuqxXxHUcJ8t0vksxHXHlj)LWStJrEDjj8lVdtgt8oTh2vu15Ia0r9zVR0EEDzxPiDLpmob0vqh1N9UcKyKzNgJ86ssJWMTNxxIBnch17QVfafxj5bQ2ZoTh2vu1PdcrCR3vUrxbXeNm70yKxxsAe2mALyBYkWIong51LKgHnJwjgXffDOtJrEDjPryZvGf(gieirqNgJ86ssJWMXeyxoqr60yKxxsAe28lVdBpIfbHBncXRZsi9jtqqIXjcMqYFjGHp()4XyYeeKyCIGzCl(4JUtIDrZjtqqIXjcMcGIRKSqWp70yKxxsAe28dcciOx5lU1ieVolH0NmbbjgNiycj)Lag(4)JhJjtqqIXjcMXTDAmYRljncBokb8L3HHBncXRZsi9jtqqIXjcMqYFjGHp()4XyYeeKyCIGzCl(4JUtIDrZjtqqIXjcMcGIRKSqWp70yKxxsAe2KteqCbl3iwkXTgH41zjK(KjiiX4ebti5VeWWh)F8ymzccsmorWmUfF8r3jXUO5KjiiX4ebtbqXvswi4NDAmYRljncBIUebPlyhW2djtbDAmYRljncB(L3HTVX2xHnKavqDAmYRljncB(gZcSIZ9n2mEiioFTtJrEDjPryZXHIja2MXdbr5W(dmvNgJ86ssJWMTXIAeuLV7VKjENgJ86ssJWM(kSJZ)fNy7XjqqNgJ86ssJWMua1jcAFJTmgvyBmbWuKong51LKgHnfvBRe2vUjTmc60yKxxsAe2m6jKy4avUfa5sorqNgJ86ssJWMcGBR8DpKmfqWTgHolEbFUcS0x3TiFbv)j(47S4f85kWsFD3I8hOYt8XFuVR(wauCLKh84Zong51LKgHnxbw4BGqGebDAmYRljncB(539n2UOq0j4wJq86SesFYeeKyCIGjK8xcy4JpE)XJXKjiiX4ebZ42ong51LKgHnhGGLBsBjkVtJrEDjPrytMGGeJte0P9WUIQE0vUugux5sORajqfeUDLwrDIYdQRmoP8Is6k(k0vw0KkFLWIURWiVUSRilIp70yKxxsAe2eXs5MrED5wweh3KPGqsLVsa3AeYiVWb2qcufqcx2P9WUcEC2vOILE1kHUcKavbeC7k(k0vAf1jkpOUY4KYlkPR4RqxzrZhSO7kmYRl7kYI4Zong51LKgHnrSuUzKxxULfXXnzkiKpa3AeYiVWb2qcufqwyzNwN2d7klcJLE1vCw8cExHrEDzxPvuNO8G6kYI4DAmYRljt(GWH4i(MSEi64wJWF8ymx5ss8tqnJB70yKxxsM8bncBokbSZdhg3AeYiVWb2yNphsMc2K1drFHWh70yKxxsM8bncBoKmfSjRhIoUOGqsy7S4fCs4sCRrOZsi95OeWopC4jK8xcy4Jp6Wbso9zciXjpbwNgJ86sYKpOryZwrrDcSIL7OmoaUOGqsy7S4fCs4sCRriE)XJXSvuuNaRy5okJdmJBXZfjEDwcPpj(jOOdqliMqYFjGHp()4Xys8tqrhGwqmJBXd60yKxxsM8bncBIdqAbX2phO60yKxxsM8bncBkR3vpR8D)pPJBnc)XJXSvuuNaRy5okJdmJBXZF8ymPyqsCXrTJcC7LtIZi6legCNgJ86sYKpOrytKGjRBz9U6zLVDAmYRljt(GgHnrRCLBz9U6zLV4wJWF8ymj(jOOdqliMXT45pEmMumijU4O2rbU9YjXze9fcdUtJrEDjzYh0iSjALRCVYcCaIJBnc)XJXKIbjXfh1okWTxojoJOVqyWDAmYRljt(GgHnbjqbPZY9xYeh3Ae(JhJjfdsIloQDuGBVCsCgrFHWGXtg5foWgsGQacEdFStJrEDjzYh0iSjXpbfDaAbbU1i8hpgtkgKexCu7Oa3E5K4mI(cHb3PXiVUKm5dAe2eTYvUL17QNv(IBnc)XJXKIbjXfh1okWTxojoJOhU8zNgJ86sYKpOryZHKPGnz9q0XffescBNfVGtcxIBncDwcPphLa25HdpHK)saRtJrEDjzYh0iSjjoXarLVDAmYRljt(GgHnj(jOiUOOdDAmYRljt(GgHnLmo8wYK1ong51LKjFqJWMdjtbBY6HOJlkiKe2olEbNeUe3AekGHaiR8xcDAmYRljt(GgHnbjqbPZY9xYeh3Ae(JhJjfdsIloQDuGBVCsCgrFHWGXtg5foWgsGQas4JDAmYRljt(GgHnhmSDbNKrmPUStJrEDjzYh0iS5qCeFtwpe9ong51LKjFqJWMfc2exu0Hong51LKjFqJWMOvUYTSEx9SYxCRr4pEmMumijU4O2rbU9YjXze9fcdUtJrEDjzYh0iS5OeWopCyCRriJ8chyJD(Cizkytwpe9fw2PXiVUKm5dAe2eyHVc5M0w0Hong51LKjFqJWMal81nibkiDw2PXiVUKm5dAe2mALyJyrqB)CGc3Ae(JhJz0kXgXIG2(5a1uauCLKh84ZoToTh2v0v(kHUIZIxW7kmYRl7kTI6eLhuxrweVtJrEDjzsQ8vcHTII6eyfl3rzCaCRriE)XJXSvuuNaRy5okJdmJBXZfjEDwcPpj(jOOdqliMqYFjGHp()4Xys8tqrhGwqmJBXd60yKxxsMKkFLqJWMdjtbBY6HOJBncXRxi6v(2PXiVUKmjv(kHgHnXbiTGy7NduDAmYRljtsLVsOryZH4i(MSEi64wJWF8ymx5ss8tqnJB70yKxxsMKkFLqJWMal8vi3K2Io0PXiVUKmjv(kHgHnhmSDbNKrmPUStJrEDjzsQ8vcncBkR3vpR8D)pPJBnc)XJXK4NGIoaTGyg3IN)4XysXGK4IJAhf42lNeNr0xim4ong51LKjPYxj0iSjibkiDwU)sM44wJWF8ymPyqsCXrTJcC7LtIZi6legCNgJ86sYKu5ReAe2eTYvUxzboaXXTgH)4XysXGK4IJAhf42lNeNr0xim4ong51LKjPYxj0iSPSEx9SY39)KoU1i8hpgtkgKexCu7Oa3E5K4mIE4YNDAmYRljtsLVsOrytjJdVLmzf3Ae(JhJ5657voXMXTDAmYRljtsLVsOrytIFckIlk6qNgJ86sYKu5ReAe2K4NGIoaTGa3Ae(JhJjfdsIloQDuGBVCsCgrFHWG70yKxxsMKkFLqJWMsghElzYANgJ86sYKu5ReAe2ejyY6wwVREw5BNgJ86sYKu5ReAe2CizkytwpeDCrbHKW2zXl4KWL4wJqbmeazL)sOtJrEDjzsQ8vcncBoehX3K1drVtJrEDjzsQ8vcncBwiytCrrh60yKxxsMKkFLqJWMK4edev(2PXiVUKmjv(kHgHnhLa25HdJBnczKx4aBSZNdjtbBY6HO3PXiVUKmjv(kHgHnL17QNv(U)N0XTgH)4XysXGK4IJAhf42lNeNr0xim4ong51LKjPYxj0iSjWcFDdsGcsNLDAmYRljtsLVsOryZOvInIfbT9ZbkCRr4pEmMrReBelcA7NdutbqXvsEWJpnnh7RNW06IArzU5Mb]] )

end
