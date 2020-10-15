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


    spec:RegisterPack( "Enhancement", 20201015.1, [[d0dZyaGEkbztcu2fGxRi2hiPlJA2cnFbQEmKFji3gOVPiv7KcTxIDlA)QYpvkLAycyCuc15bPUMIKbRqdxrDqLsrhM0XukohLqwiL0sPeuwSQA5i9qLsHNIyzGQEouZcuzQuWKvY0P6IksPxjOEgLORtP(RuTvfPiBwkBxG8Dq8vfPOMgiX8ukzBuc8iLs1OPOpRuDsfPWTOeuDAj3tbReuoKsPKFRYYgXGqwQZIr4daFGnb2mfWMatzrwArcXHEMfYSIMO7SqsfKfY0MMAIyqoDHmRqhpDjgec(SPiwitde0w4ttCLyH8TROpns5lKL6Sye(aWhytGntbSjWuw0MncbpZiXi8wGLcXSwloLVqwmgjKT)gN20utedYP)gjMkOMpyB)nUTr(9z6BCZuW9gHpa8bEWEW2(BCBUw86nUnUG4ut)nQ)kwEXyGhST)gTWySFu(noTymNigdiKyHDSyqilUP2rxmig3igeII86sHaPYvhBYkviCQ)iVeRIlgHxmieo1FKxIvHGOLZ0sfY3U1aumIZLMigWE(ng8G)g)2TgqJPASJNlA5a2ZcrrEDPqMpVUuCXOLIbHOiVUuiOiRjM745IwUq4u)rEjwfxmcfXGq4u)rEjwfcIwotlviF7wdasLRMnf6UFodcSoiPquKxxkeivUA2uO7(5mO4IXPedcHt9h5LyviiA5mTuH8TBnatTIy)OGa2ZcrrEDPqA0d7DS5HMiUy0cedcrrEDPqyL6MC2XZ1ewiCQ)iVeRIlgNUyqiCQ)iVeRcbrlNPLke0DX1bjbWoTMWauguRe)gH6BmGquKxxkefJ4CPjIfxmAXIbHOiVUuiqQCHDAnHfcN6pYlXQ4Irlsmieo1FKxIvHGOLZ0sfsK35CPuObw3b2Hu5cdWP(J86ngS34I)2TgW6oWoKkx4oAbSoiPquKxxkeivUA2uO7(5mO4IXnbedcrrEDPqqxI40PQZRElQGSq4u)rEjwfxmUzJyqikYRlfYpE3QFTUBYDozqOfcN6pYlXQ4IXnWlgeII86sHSBR0vPz)AD1cX0ZnfcN6pYlXQ4IXnwkgeII86sH0oKnMxD1cX0Y5(NvqHWP(J8sSkUyCduedcrrEDPqMTPvd6k37)OIDHWP(J8sSkUyCZuIbHOiVUuiUj3TZ)zNRE7OiwiCQ)iVeRIlg3ybIbHOiVUuiGm4rHUFTE0gvR(IYkiwiCQ)iVeRIlg3mDXGquKxxkeAnph5ELD8SIyHWP(J8sSkUyCJflgeII86sHa5OXvqCLDkJVuteleo1FKxIvXfJBSiXGq4u)rEjwfcIwotlviUs3zhWK1OB2Nr(BeQVrloWBm4b)n6kDNDatwJUzFg5VXTEJWh4ng8G)gB1UP3PmOwj(nU1B0YacrrEDPqOSox5EVfvqglUye(aIbHOiVUuiMSs9oJXCIyHWP(J8sSkUye(nIbHOiVUuibX4zM29ZzqHWP(J8sSkUyeE4fdcHt9h5LyvikYRlfYmTap6Q0yhIgeleeTCMwQqw83U1aArfK7yZdnbyDqsHGGgf5UR0D2XIXnIlgH3sXGquKxxkKMYDNQjUzJRlfcN6pYlXQ4Ir4HIyqikYRlfcYuRSBQ0GySleo1FKxIvXfJWpLyqiCQ)iVeRcbrlNPLkKVDRbaQCe70dSdH15lbWUIM8ghEJt9gd2B8B3Aay)OGFAL7mfWE(ngS3OI8kiUZjdwm(nc134gHOiVUuiitTYES2n9SYDXfJWBbIbHWP(J8sSkeeTCMwQq(2TgaOYrStpWoewNVea7kAYBC4no1BmyVXVDRbG9Jc(PvUZua7zHOiVUuiXA30Zk37)l6IlgHF6IbHWP(J8sSkeeTCMwQq(2TgaOYrStpWoewNVea7kAYBC4noLquKxxkeoYGC6AS)Jk2fxmcVflgecN6pYlXQqq0YzAPc5B3AaGkhXo9a7qyD(saSROjVXH34ucrrEDPqW(rbNW8mtfxmcVfjgecN6pYlXQqq0YzAPc5B3AaGkhXo9a7qyD(saSROjVrO(gN(BmyVrf5vqCNtgSy8BeQVXncrrEDPqqMAL9yTB6zL7IlgTmGyqiCQ)iVeRcbrlNPLkKVDRbaQCe70dSdH15lbWUIM8gH6BC6crrEDPqI1UPNvU3)x0fxmA5gXGq4u)rEjwfcIwotlviF7wdW88UPMla7zHOiVUuirniThvSP4IrlHxmieo1FKxIvHGOLZ0sfIRroDGOInRCV3IkiJb4u)rE9gd2BCXF7wdiQyZk37TOcYyG1bjfII86sHe1G0EuXMIlgT0sXGq4u)rEjwfcIwotlviBR3OxOjvUlef51LcPfvqUJnp0eXfJwcfXGquKxxkeSFuqStRjSq4u)rEjwfxmA5uIbHOiVUuinMQXoEUOLleo1FKxIvXfJwAbIbHOiVUuiy7CX0k3fcN6pYlXQ4IrlNUyqiCQ)iVeRcbrlNPLkKf)TBnGwub5o28qtaOmOwj(nU1BCkHOiVUuiTOcYDS5HMiUy0slwmieo1FKxIvHGOLZ0sfIRroDaevXMvU3X(rbb4u)rEjef51LcbrvSzpw7MEw5U4IrlTiXGquKxxkKg9WEhBEOjcHt9h5LyvCXiucigeII86sHuiUJDAnHfcN6pYlXQ4IrOSrmief51LcjQbP9OInfcN6pYlXQ4IrOaVyqikYRlfcIQyZES2n9SYDHWP(J8sSkUyekwkgecN6pYlXQqq0YzAPcrrEfe3xNd0Iki3XMhAYBeQVXacrrEDPqAfL75fKkUyekqrmieo1FKxIvHGOLZ0sfY3U1aavoID6b2HW68LayxrtEJq9ncfHOiVUuiXA30Zk37)l6IlgHYuIbHWP(J8sSkeeTCMwQqmzn6MaZmfXP)g36nUjqaHOiVUuinL7ovtCZgxx2nznkUyekwGyqiCQ)iVeRcbrlNPLketwJUjWmtrC6VXTEJBceqikYRlfIjRXk37yNYky3pNbfxmcLPlgecN6pYlXQqq0YzAPczMDaivUA2uO7(5miaLb1kXVXTEJwqaHOiVUuiqQC1SPq39ZzqXfxiZugDGF1fdIXnIbHWP(J8sSkeeTCMwQq(2TgqS2n9SY9o2S44cGYGAL434wVrldeqikYRlfsS2n9SY9o2S44sCXi8IbHWP(J8sSkeeTCMwQq(2TgaKkxnBk0DiSoFjaLb1kXVXTEJwgiGquKxxkeivUA2uO7qyD(sXfJwkgecN6pYlXQqq0YzAPc5B3AaTOcY(L72ChcRZxcqzqTs8BCR3OLbcief51LcPfvq2VC3M7qyD(sXfJqrmieo1FKxIvHGOLZ0sfY3U1aGu5QztHU7NZGaRdskef51LcbsLRMnf6UFodkU4IlKGykUUumcFa4dSjWglb2ieiknRChlKPb48rDE9gH)nQiVU8nglSJbEWeIA7MhvitZhDzplKz61QilKT)gN20utedYP)gjMkOMpyB)nUTr(9z6BCZuW9gHpa8bEWEW2(BCBUw86nUnUG4ut)nQ)kwEXyGhST)gTWySFu(noTymNigd8G9GPiVUedmtz0b(vFiw7MEw5EhBwCCbx1g(2TgqS2n9SY9o2S44cGYGAL4TSmqGhmf51LyGzkJoWV6HhcbPYvZMcDhcRZxcx1g(2TgaKkxnBk0DiSoFjaLb1kXBzzGapykYRlXaZugDGF1dpeQfvq2VC3M7qyD(s4Q2W3U1aArfK9l3T5oewNVeGYGAL4TSmqGhmf51LyGzkJoWV6HhcbPYvZMcD3pNbHRAdF7wdasLRMnf6UFodcSoi5d2dMI86s8aKkxDSjR0hmf51L4WdHMpVUeUQn8TBnafJ4CPjIbSNdEW)2TgqJPASJNlA5a2ZpykYRlXHhcHISMyUJNlA5pykYRlXHhcbPYvZMcD3pNbHRAdF7wdasLRMnf6UFodcSoi5dMI86sC4Hqn6H9o28qtGRAdF7wdWuRi2pkiG98dMI86sC4HqSsDto745Ac)GPiVUehEiKIrCU0eXWvTb0DX1bjbWoTMWauguRed1apykYRlXHhcbPYf2P1e(btrEDjo8qiivUA2uO7(5miCvBiY7CUuk0aR7a7qQCHb4u)rEfSf)TBnG1DGDivUWD0cyDqYhmf51L4WdHqxI40PQZRElQG8dMI86sC4Hq)4DR(16Uj35KbH(btrEDjo8qODBLUkn7xRRwiMEU5dMI86sC4HqTdzJ5vxTqmTCU)zf8btrEDjo8qOzBA1GUY9(pQy)btrEDjo8qi3K725)SZvVDue)GPiVUehEieidEuO7xRhTr1QVOScIFWuKxxIdpeIwZZrUxzhpRi(btrEDjo8qiihnUcIRStz8LAI4hmf51L4WdHOSox5EVfvqgdx1gCLUZoGjRr3SpJCOAXbcEWDLUZoGjRr3SpJ8TGpqWdER2n9oLb1kXBzzGhmf51L4WdHmzL6DgJ5eXpykYRlXHhcfeJNzA3pNbFWuKxxIdpeAMwGhDvASdrdIHdbnkYDxP7SJh2ax1gw83U1aArfK7yZdnbyDqYhmf51L4WdHAk3DQM4MnUU8btrEDjo8qiKPwz3uPbXy)btrEDjo8qiKPwzpw7MEw5oCvB4B3AaGkhXo9a7qyD(saSROjdtfSVDRbG9Jc(PvUZua75GPiVcI7CYGfJH6Mhmf51L4WdHI1UPNvU3)x0HRAdF7wdau5i2PhyhcRZxcGDfnzyQG9TBnaSFuWpTYDMcyp)GPiVUehEiehzqoDn2)rf7WvTHVDRbaQCe70dSdH15lbWUIMmm1dMI86sC4Hqy)OGtyEMPWvTHVDRbaQCe70dSdH15lbWUIMmm1dMI86sC4HqitTYES2n9SYD4Q2W3U1aavoID6b2HW68LayxrtG60dMI8kiUZjdwmgQBEWuKxxIdpekw7MEw5E)FrhUQn8TBnaqLJyNEGDiSoFja2v0eOo9hmf51L4WdHIAqApQyt4Q2W3U1ampVBQ5cWE(btrEDjo8qOOgK2Jk2eUQn4AKthiQyZk37TOcYyao1FKxbBXF7wdiQyZk37TOcYyG1bjFWuKxxIdpeQfvqUJnp0e4Q2W2Yl0Kk3FWuKxxIdpec7hfe70Ac)GPiVUehEiuJPASJNlA5pykYRlXHhcHTZftRC)btrEDjo8qOwub5o28qtGRAdl(B3AaTOcYDS5HMaqzqTs8wt9GPiVUehEieIQyZES2n9SYD4Q2GRroDaevXMvU3X(rbb4u)rE9GPiVUehEiuJEyVJnp0Khmf51L4WdHke3XoTMWpykYRlXHhcf1G0EuXMpykYRlXHhcHOk2ShRDtpRC)btrEDjo8qOwr5EEbPWvTbf5vqCFDoqlQGChBEOjqnWdMI86sC4HqXA30Zk37)l6WvTHVDRbaQCe70dSdH15lbWUIMavO8GPiVUehEiut5Ut1e3SX1LDtwJWvTbtwJUjWmtrC6BTjqGhmf51L4WdHmznw5Eh7uwb7(5miCvBWK1OBcmZueN(wBce4btrEDjo8qiivUA2uO7(5miCvByMDaivUA2uO7(5miaLb1kXBzbbexCra]] )

end
