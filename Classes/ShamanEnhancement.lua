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

        if buff.windfury_totem.up and pet.windfury_totem.up then
            buff.windfury_totem.expires = pet.windfury_totem.expires
        end

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

            usable = function () return swings.oh_speed > 0, "requires an offhand weapon" end,

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
            cooldown = function() return level > 25 and ( gcd.execute * 6 ) or gcd.execute end,
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

            copy = { "strike", "primal_strike", 73899 }, -- copies this ability to this key or keys (if a table value)
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


    spec:RegisterPack( "Enhancement", 20201024.1, [[daeOPaqiOk9ivHSjOk6tsPIgLaP6usPsELu0SGkULaPWUu0VKcddQ0XKswgjXZufmnvH6AcuBtGKVjqW4GQGZjqK5jLQUNG2NukheQcXcfspukv4Ice6Kce1krk3uGu0ojP(jufQLkqk9usnvbSxk)vPgmjomQfRQEmKjdLld2ScFwvA0kPtl51ivZMOBJKDl63QmCLy5eEoIPt11fQTRk67cX4HQq68KKwVuQuZhQQ9lvBTSaMgJDWuRcUQGBlCv5XZwTA16bvmTR6cy6fgrNFbtNmfy6GyUYjcOG0n9cRQ8ymlGPjxSabMwxuTdt)JlPhKt7BAm2btTk4QcUTWvLhpB1QvRhmnzbqMAvcQhm9AHHbP9nngqqM(rDLGyUYjcOG07k6vMIZoTh1vWJr(9brxrLhJtxrfCvb3oToTh1vWJGHbyDL2X9eso9Uc)lz5fqMDApQRe0ce)eqxjisiqIaY00YI4elGPjv(kblGPULfW0qYFjGzrnnsuoik204TR8JhJ5IOOobwXYDe(jmJx6k4zxjO3vWBxXzjK(K4NGIoalGycj)LawxbF87k)4Xys8tqrhGfqmJx6kTltZiVU00lII6eyfl3r4NG5MAvSaMgs(lbmlQPrIYbrXMgVDfVq0R810mYRln9qYuWMSEi6MBQFWcyAg51LM(jqwaX2phOmnK8xcywuZn1p2cyAi5VeWSOMgjkhefB6F8ymx5ss8tqnJxmnJ86stpehX3K1dr3CtDWwatZiVU00al8vi3KLIoyAi5VeWSOMBQdklGPzKxxA6bdBxWjzetQlnnK8xcywuZn1bblGPHK)saZIAAKOCquSP)XJXK4NGIoalGygV0vWZUYpEmMumijU4O2raE5YjXze9UsBHDLGnnJ86stlR3vpR8D)pPBUPgpybmnK8xcywutJeLdIIn9pEmMumijU4O2raE5YjXze9UsBHDLGnnJ86stdsGcsNL7VKjU5M6GKfW0qYFjGzrnnsuoik20)4XysXGK4IJAhb4LlNeNr07kTf2vc20mYRlnnALRCVYINaXn3u3cxlGPHK)saZIAAKOCquSP)XJXKIbjXfh1ocWlxojoJO3vc7kTW10mYRlnTSEx9SY39)KU5M6wTSaMgs(lbmlQPrIYbrXM(hpgZ1Z3RCInJxmnJ86stl5N8wYKvZn1TuXcyAg51LMM4NGI4IIoyAi5VeWSOMBQB9GfW0qYFjGzrnnsuoik20)4XysXGK4IJAhb4LlNeNr07kTf2vc20mYRlnnXpbfDawaH5M6wp2cyAg51LMwYp5TKjRMgs(lbmlQ5M6wbBbmnJ86stJemzDlR3vpR810qYFjGzrn3u3kOSaMgs(lbmlQPzKxxA6HKPGnz9q0nnsuoik20cyiaYk)LGPrQIKW2zXl4etDlZn1TccwatZiVU00dXr8nz9q0nnK8xcywuZn1TWdwatZiVU00fc2exu0btdj)LaMf1CtDRGKfW0mYRlnnjoXarLVMgs(lbmlQ5MAvW1cyAi5VeWSOMgjkhefBAg51tyJD(CizkytwpeDtZiVU00Jsa78EYMBQvPLfW0qYFjGzrnnsuoik20)4XysXGK4IJAhb4LlNeNr07kTf2vc20mYRlnTSEx9SY39)KU5MAvuXcyAg51LMgyHVUbjqbPZstdj)LaMf1CtTkpybmnK8xcywutJeLdIIn9pEmMrQeBeluD7NdutbqXvs6kTVR8aUMMrEDPPJuj2iwO62phOm3CtZhybm1TSaMgs(lbmlQPrIYbrXM(hpgZvUKe)euZ4ftZiVU00dXr8nz9q0n3uRIfW0qYFjGzrnnsuoik20mYRNWg785qYuWMSEi6DL2c7kpyAg51LMEucyN3t2Ct9dwatdj)LaMf10mYRln9qYuWMSEi6MgjkhefBANLq6ZrjGDEp5jK8xcyDf8XVRGUNqYPptajo5jWmnsvKe2olEbNyQBzUP(Xwatdj)LaMf10mYRln9IOOobwXYDe(jyAKOCquSPXBx5hpgZfrrDcSIL7i8tygV0vWZUsqVRG3UIZsi9jXpbfDawaXes(lbSUc(43v(XJXK4NGIoalGygV0vAxMgPkscBNfVGtm1Tm3uhSfW0mYRln9tGSaITFoqzAi5VeWSOMBQdklGPHK)saZIAAKOCquSP)XJXCruuNaRy5oc)eMXlDf8SR8JhJjfdsIloQDeGxUCsCgrVR0wyxjytZiVU00Y6D1ZkF3)t6MBQdcwatZiVU00ibtw3Y6D1ZkFnnK8xcywuZn14blGPHK)saZIAAKOCquSP)XJXK4NGIoalGygV0vWZUYpEmMumijU4O2raE5YjXze9UsBHDLGnnJ86stJw5k3Y6D1ZkFn3uhKSaMgs(lbmlQPrIYbrXM(hpgtkgKexCu7iaVC5K4mIExPTWUsWMMrEDPPrRCL7vw8eiU5M6w4AbmnK8xcywutJeLdIIn9pEmMumijU4O2raE5YjXze9UsBHDLG7k4zxHrE9e2qcufq6k4nSR8GPzKxxAAqcuq6SC)LmXn3u3QLfW0qYFjGzrnnsuoik20)4XysXGK4IJAhb4LlNeNr07kTf2vc20mYRlnnXpbfDawaH5M6wQybmnK8xcywutJeLdIIn9pEmMumijU4O2raE5YjXze9UsyxPfUMMrEDPPrRCLBz9U6zLVMBQB9GfW0qYFjGzrnnJ86stpKmfSjRhIUPrIYbrXM2zjK(CucyN3tEcj)LaMPrQIKW2zXl4etDlZn1TESfW0mYRlnnjoXarLVMgs(lbmlQ5M6wbBbmnJ86stt8tqrCrrhmnK8xcywuZn1TcklGPzKxxAAj)K3sMSAAi5VeWSOMBQBfeSaMgs(lbmlQPzKxxA6HKPGnz9q0nnsuoik20cyiaYk)LGPrQIKW2zXl4etDlZn1TWdwatdj)LaMf10ir5GOyt)JhJjfdsIloQDeGxUCsCgrVR0wyxj4UcE2vyKxpHnKavbKUsyx5btZiVU00GeOG0z5(lzIBUPUvqYcyAg51LMEWW2fCsgXK6stdj)LaMf1CtTk4AbmnJ86stpehX3K1dr30qYFjGzrn3uRsllGPzKxxA6cbBIlk6GPHK)saZIAUPwfvSaMgs(lbmlQPrIYbrXM(hpgtkgKexCu7iaVC5K4mIExPTWUsWMMrEDPPrRCLBz9U6zLVMBQv5blGPHK)saZIAAKOCquSPzKxpHn25ZHKPGnz9q07kT1vAzAg51LMEucyN3t2CtTkp2cyAg51LMgyHVc5MSu0btdj)LaMf1CtTkbBbmnJ86stdSWx3GeOG0zPPHK)saZIAUPwLGYcyAi5VeWSOMgjkhefB6F8ymJuj2iwO62phOMcGIRK0vAFx5bCnnJ86sthPsSrSq1TFoqzU5MgdgCS0TaM6wwatZiVU00F5DyYyIBAi5VeWSV5MAvSaMgs(lbmlQPrIYbrXMEuVR(wauCLKUs77kbfUMMrEDPPxoVU0Ct9dwatZiVU00rQeBtwbwyAi5VeWSOMBQFSfW0mYRlnDKkXiUOOdMgs(lbmlQ5M6GTaMMrEDPPrxIG0fSdy7HKPatdj)LaMf1CtDqzbmnJ86st)L3HTVX2xHnKaLQMgs(lbmlQ5M6GGfW0mYRln9BmlWko33yZTBqC(QPHK)saZIAUPgpybmnJ86stpoumbW2C7geLd7pWuMgs(lbmlQ5M6GKfW0mYRln9sSOgQw57(lzIBAi5VeWSOMBQBHRfW0mYRlnTVc748FXj2ECceyAi5VeWSOMBQB1YcyAg51LMMcOoHQ7BSLXOcBJjaMIyAi5VeWSOMBQBPIfW0mYRlnTOwwKWUYnzHrGPHK)saZIAUPU1dwatZiVU00roHe7ju5waKl5ebMgs(lbmlQ5M6wp2cyAi5VeWSOMgjkhefBANfVGpxbw6R7fK3vARRGhWTRGp(DfNfVGpxbw6R7fK3vAFxrfC7k4JFxzuVR(wauCLKUs77kpGRPzKxxAAbWlv(UhsMciMBQBfSfW0mYRln9kWcFdecKiW0qYFjGzrn3u3kOSaMMrEDPPJjWUCGIyAi5VeWSOMBQBfeSaMgs(lbmlQPrIYbrXMgVDfNLq6tMGGeJtemHK)saRRGp(DLF8ymzccsmorWmEPRGp(Df0DsSlsozccsmorWuauCLKUsBDLGX10mYRln9xEh2Eelu1CtDl8GfW0qYFjGzrnnsuoik204TR4SesFYeeKyCIGjK8xcyDf8XVR8JhJjtqqIXjcMXlMMrEDPP)GGac6v(AUPUvqYcyAi5VeWSOMgjkhefBA82vCwcPpzccsmorWes(lbSUc(43v(XJXKjiiX4ebZ4LUc(43vq3jXUi5KjiiX4ebtbqXvs6kT1vcgxtZiVU00JsaF5DyMBQvbxlGPHK)saZIAAKOCquSPXBxXzjK(KjiiX4ebti5VeW6k4JFx5hpgtMGGeJtemJx6k4JFxbDNe7IKtMGGeJtemfafxjPR0wxjyCnnJ86stZjciUGLBelLMBQvPLfW0qYFjGzrnnsuoik204TR4SesFYeeKyCIGjK8xcyDf8XVRG3UYpEmMmbbjgNiygVyAg51LM(ZV7BSDrHOtm3uRIkwatZiVU00dqWYnzPeLBAi5VeWSOMBQv5blGPzKxxAAMGGeJteyAi5VeWSOMBQv5Xwatdj)LaMf10ir5GOytZiVEcBibQciDLWUsltZiVU00iwk3mYRl3YI4MwweFNmfyAsLVsWCtTkbBbmnK8xcywutJeLdIInnJ86jSHeOkG0vARR0Y0mYRlnnILYnJ86YTSiUPLfX3jtbMMpWCZn9Iaqh1NDlGPULfW0qYFjGzrnnsuoik20)4XygPsSrSq1DeGxUCkakUssxP9DLhWfxtZiVU00rQeBeluDhb4Lln3uRIfW0qYFjGzrnnsuoik20)4XyoKmf4x(gd7iaVC5uauCLKUs77kpGlUMMrEDPPhsMc8lFJHDeGxU0Ct9dwatdj)LaMf10ir5GOyt)JhJPSEx9SY3nzTaj2uauCLKUs77kpGlUMMrEDPPL17QNv(UjRfiXm3u)ylGPHK)saZIAAKOCquSP)XJXmsLyJyHQB)CGAIDrstZiVU00rQeBeluD7NduMBQd2cyAi5VeWSOMgjkhefBANLq6tIFck6aSaIjK8xcyMMrEDPPj(jOOdWcim3CZn9tqqQln1QGRk42cxvESPJWISYxIPdYulNWbSUYJ7kmYRl7kYI4KzNMPxe3OKGPFuxjiMRCIaki9UIELP4St7rDf8yKFFq0vu5X40vubxvWTtRt7rDf8iyyawxPDCpHKtVRW)swEbKzN2J6kbTaXpb0vcIecKiGm7060yKxxsMlcaDuF2dJuj2iwO6ocWlxItnc)XJXmsLyJyHQ7iaVC5uauCLK2)aU42PXiVUKmxea6O(S3mSXqYuGF5BmSJa8YL4uJWF8ymhsMc8lFJHDeGxUCkakUss7FaxC70yKxxsMlcaDuF2Bg2qwVREw57MSwGedNAe(JhJPSEx9SY3nzTaj2uauCLK2)aU42PXiVUKmxea6O(S3mSrKkXgXcv3(5afo1i8hpgZivInIfQU9ZbQj2fj70yKxxsMlcaDuF2Bg2G4NGIoalGaNAe6SesFs8tqrhGfqmHK)saRtRt7rDLGiEuaf7awxbEccv7kErbDfFf6kmYprxPiDf(jxs(lHzNgJ86ss4xEhMmM4DApQReKZGgOJ6ZExz586YUsr6kFyCcORGoQp7DfiXiZong51LKMHnwoVUeNAeoQ3vFlakUss7dkC70EuxjiNoieXlEx5gDfetCYStJrEDjPzyJivITjRal60yKxxsAg2isLyexu0Hong51LKMHnqxIG0fSdy7HKPGong51LKMHn(Y7W23y7RWgsGs1ong51LKMHnEJzbwX5(gBUDdIZx70yKxxsAg2yCOycGT52nikh2FGP60yKxxsAg2yjwudvR8D)LmX70yKxxsAg2WxHDC(V4eBpobc60yKxxsAg2GcOoHQ7BSLXOcBJjaMI0PXiVUK0mSHOwwKWUYnzHrqNgJ86ssZWgroHe7ju5waKl5ebDAmYRljndBiaEPY39qYuabNAe6S4f85kWsFDVG82Wd4Ip(olEbFUcS0x3liV9QGl(4pQ3vFlakUss7Fa3ong51LKMHnwbw4BGqGebDAmYRljndBetGD5afPtJrEDjPzyJV8oS9iwOko1ieVolH0NmbbjgNiycj)Lag(4)JhJjtqqIXjcMXl4Jp6oj2fjNmbbjgNiykakUssBbJBNgJ86ssZWgFqqab9kFXPgH41zjK(KjiiX4ebti5VeWWh)F8ymzccsmorWmEPtJrEDjPzyJrjGV8omCQriEDwcPpzccsmorWes(lbm8X)hpgtMGGeJtemJxWhF0DsSlsozccsmorWuauCLK2cg3ong51LKMHn4ebexWYnILsCQriEDwcPpzccsmorWes(lbm8X)hpgtMGGeJtemJxWhF0DsSlsozccsmorWuauCLK2cg3ong51LKMHn(87(gBxui6eCQriEDwcPpzccsmorWes(lbm8XhV)4XyYeeKyCIGz8sNgJ86ssZWgdqWYnzPeL3PXiVUK0mSbtqqIXjc60Euxjip6kxkvTRCj0vGeOufNUYIOor5Q2vgNuEriDfFf6kTtsLVsOD2vyKxx2vKfXNDAmYRljndBGyPCZiVUCllIJtYuqiPYxjGtnczKxpHnKavbKWwDApQRGhNDfQyPxlsORajqvabNUIVcDLfrDIYvTRmoP8Iq6k(k0vAN8bTZUcJ86YUISi(StJrEDjPzydelLBg51LBzrCCsMcc5dWPgHmYRNWgsGQasBT6060EuxjOzS0RUIZIxW7kmYRl7klI6eLRAxrweVtJrEDjzYheoehX3K1drhNAe(JhJ5kxsIFcQz8sNgJ86sYKpOzyJrjGDEpzCQriJ86jSXoFoKmfSjRhIEBHp0PXiVUKm5dAg2yizkytwpeDCqQIKW2zXl4KWw4uJqNLq6ZrjGDEp5jK8xcy4Jp6EcjN(mbK4KNaRtJrEDjzYh0mSXIOOobwXYDe(jGdsvKe2olEbNe2cNAeI3F8ymxef1jWkwUJWpHz8cEg0XRZsi9jXpbfDawaXes(lbm8X)hpgtIFck6aSaIz8s7QtJrEDjzYh0mSXtGSaITFoq1PXiVUKm5dAg2qwVREw57(FshNAe(JhJ5IOOobwXYDe(jmJxWZF8ymPyqsCXrTJa8YLtIZi6TfgCNgJ86sYKpOzydKGjRBz9U6zLVDAmYRljt(GMHnqRCLBz9U6zLV4uJWF8ymj(jOOdWciMXl45pEmMumijU4O2raE5YjXze92cdUtJrEDjzYh0mSbALRCVYINaXXPgH)4XysXGK4IJAhb4LlNeNr0Blm4ong51LKjFqZWgGeOG0z5(lzIJtnc)XJXKIbjXfh1ocWlxojoJO3wyW4jJ86jSHeOkGG3Wh60yKxxsM8bndBq8tqrhGfqGtnc)XJXKIbjXfh1ocWlxojoJO3wyWDAmYRljt(GMHnqRCLBz9U6zLV4uJWF8ymPyqsCXrTJa8YLtIZi6HTWTtJrEDjzYh0mSXqYuWMSEi64GufjHTZIxWjHTWPgHolH0NJsa78EYti5VeW60yKxxsM8bndBqItmqu5BNgJ86sYKpOzydIFckIlk6qNgJ86sYKpOzydj)K3sMS2PXiVUKm5dAg2yizkytwpeDCqQIKW2zXl4KWw4uJqbmeazL)sOtJrEDjzYh0mSbibkiDwU)sM44uJWF8ymPyqsCXrTJa8YLtIZi6TfgmEYiVEcBibQciHp0PXiVUKm5dAg2yWW2fCsgXK6Yong51LKjFqZWgdXr8nz9q070yKxxsM8bndBuiytCrrh60yKxxsM8bndBGw5k3Y6D1ZkFXPgH)4XysXGK4IJAhb4LlNeNr0Blm4ong51LKjFqZWgJsa78EY4uJqg51tyJD(Cizkytwpe92A1PXiVUKm5dAg2ayHVc5MSu0Hong51LKjFqZWgal81nibkiDw2PXiVUKm5dAg2isLyJyHQB)CGcNAe(JhJzKkXgXcv3(5a1uauCLK2)aUDADApQROR8vcDfNfVG3vyKxx2vwe1jkx1UISiENgJ86sYKu5Recxef1jWkwUJWpbCQriE)XJXCruuNaRy5oc)eMXl4zqhVolH0Ne)eu0bybeti5VeWWh)F8ymj(jOOdWciMXlTRong51LKjPYxj0mSXqYuWMSEi64uJq86fIELVDAmYRljtsLVsOzyJNazbeB)CGQtJrEDjzsQ8vcndBmehX3K1drhNAe(JhJ5kxsIFcQz8sNgJ86sYKu5ReAg2ayHVc5MSu0Hong51LKjPYxj0mSXGHTl4KmIj1LDAmYRljtsLVsOzydz9U6zLV7)jDCQr4pEmMe)eu0bybeZ4f88hpgtkgKexCu7iaVC5K4mIEBHb3PXiVUKmjv(kHMHnajqbPZY9xYehNAe(JhJjfdsIloQDeGxUCsCgrVTWG70yKxxsMKkFLqZWgOvUY9klEcehNAe(JhJjfdsIloQDeGxUCsCgrVTWG70yKxxsMKkFLqZWgY6D1ZkF3)t64uJWF8ymPyqsCXrTJa8YLtIZi6HTWTtJrEDjzsQ8vcndBi5N8wYKvCQr4pEmMRNVx5eBgV0PXiVUKmjv(kHMHni(jOiUOOdDAmYRljtsLVsOzydIFck6aSacCQr4pEmMumijU4O2raE5YjXze92cdUtJrEDjzsQ8vcndBi5N8wYK1ong51LKjPYxj0mSbsWK1TSEx9SY3ong51LKjPYxj0mSXqYuWMSEi64GufjHTZIxWjHTWPgHcyiaYk)LqNgJ86sYKu5ReAg2yioIVjRhIENgJ86sYKu5ReAg2OqWM4IIo0PXiVUKmjv(kHMHniXjgiQ8TtJrEDjzsQ8vcndBmkbSZ7jJtnczKxpHn25ZHKPGnz9q070yKxxsMKkFLqZWgY6D1ZkF3)t64uJWF8ymPyqsCXrTJa8YLtIZi6TfgCNgJ86sYKu5ReAg2ayHVUbjqbPZYong51LKjPYxj0mSrKkXgXcv3(5afo1i8hpgZivInIfQU9ZbQPaO4kjT)bCnnh7RNW06IQDyU5Mb]] )

end
