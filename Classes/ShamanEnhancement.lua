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
    spec:RegisterTotem( "skyfury_totem", 135829 )
    spec:RegisterTotem( "counterstrike_totem", 511726 )


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

        counterstrike_totem = {
            id = 204331,
            cast = 0,
            cooldown = 45,
            gcd = "spell",
            
            spend = 0.03,
            spendType = "mana",

            pvptalent = "counterstrike_totem",            
            
            startsCombat = false,
            texture = 511726,
            
            handler = function ()
                summonPet( "counterstrike_totem" )
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

        primal_strike = {
            id = 73899,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.09,
            spendType = "mana",
            
            startsCombat = true,
            texture = 460956,

            usable = function () return level < 20, "replaced by stormstrike" end,
            
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

            toggle = "interrupts",
            interrupt = true,

            buff = "dispellable_magic",

            handler = function ()
                removeBuff( "dispellable_magic" )
            end,
        },

        skyfury_totem = {
            id = 204330,
            cast = 0,
            cooldown = 40,
            gcd = "spell",
            
            spend = 0.03,
            spendType = "mana",
            
            startsCombat = false,
            texture = 135829,

            pvptalent = "skyfury_totem",
            
            handler = function ()
                summonPet( "skyfury_totem" )
                applyBuff( "skyfury_totem" )
            end,

            auras = {
                skyfury_totem = {
                    id = 208963,
                    duration = 3600,
                    max_stack = 1,
                },
            },
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

            usable = function () return level > 19 end,

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

            copy = { "strike" }, -- copies this ability to this key or keys (if a table value)
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


    spec:RegisterPack( "Enhancement", 20201031, [[diKhQaqissEKuLAtqs5tQcrJsQsQtPkK8kPIzbPClssLSlf9lPsddsCmPQwgjXZufmnijDnbQTrskFdsIghKeohKuzEQc19e0(KQ4GsvISqH4HQcHlcjvDsPkHvIuMPuLKBssQu7KK6NKKQgkjPclvQsupLutva7LYFvQbtIdJAXQQhd1KH4YGnRWNvLgTs60sEns1Sj62iz3I(TkdxjwoHNJy6uDDHA7QI(UqA8KKk68cK1RkKA(qQ2Vu26Bbmnc7GPwfuubL(O8q)zFvqbvvbvnTh0cy6fgtNFbtNmfyAuFUYjgOG0n9chK8yelGPjxSadMwxupct)JlP3ls7BAe2btTkOOck9r5H(Z(QGcQQYdMMSaytTkQ2dMETqqG0(Mgbiyt37McQpx5eduq6nf9ktXzJwVBkQESFFq0uEOpAnfvqrfuA0A06DtPxcbbqAkpI7jKC6nf(xYYlGmB06DtPxgi(jGMcQNqGedKzJwVBkQoefflBkAxu0HztPP0Ru99QPPLfXjwattQ8vcwatDFlGPHK)saXIyASOCquSPvvt5hpgZfrrDcKIL7O8tygV0uqTMsVUPOQMIZsi9jXpbfDawaXes(lbKMc6O3u(XJXK4NGIoalGygV0uEuMMXEDPPxef1jqkwUJYpbZn1QybmnK8xciwetJfLdIInTQAkEHPx5RPzSxxA6HKPGnz9W0n3u)GfW0m2Rln9tGSaITFoqzAi5VeqSiMBQrvlGPHK)saXIyASOCquSP)XJXCLljXpb1mEX0m2Rln9qCeFtwpmDZn1bBbmnJ96stdSWxHCtwk6GPHK)saXIyUPw1SaMMXEDPPhmSDbNKrmPU00qYFjGyrm3uJkTaMgs(lbelIPXIYbrXM(hpgtIFck6aSaIz8stb1Ak)4XysXGK4IJAhf4LlNeNX0Bk9e2uc20m2RlnTSEx9SY39)KU5MAuHfW0qYFjGyrmnwuoik20)4XysXGK4IJAhf4LlNeNX0Bk9e2uc20m2RlnnibkiDwU)sM4MBQrDwatdj)LaIfX0yr5GOyt)JhJjfdsIloQDuGxUCsCgtVP0tytjytZyVU004vUY9klEce3CtDFuSaMgs(lbelIPXIYbrXM(hpgtkgKexCu7OaVC5K4mMEtjSP0hftZyVU00Y6D1ZkF3)t6MBQ733cyAi5VeqSiMglkhefB6F8ymxpFVYjYmEX0m2RlnTKFYBjtwn3u3xflGPzSxxAAIFckIlk6GPHK)saXIyUPU)dwatdj)LaIfX0yr5GOyt)JhJjfdsIloQDuGxUCsCgtVP0tytjytZyVU00e)eu0bybeMBQ7JQwatZyVU00s(jVLmz10qYFjGyrm3u3pylGPzSxxAASGjRBz9U6zLVMgs(lbelI5M6(QMfW0qYFjGyrmnJ96stpKmfSjRhMUPXIYbrXMwadbqw5VemnoiSe2olEbNyQ7BUPUpQ0cyAg71LMEioIVjRhMUPHK)saXIyUPUpQWcyAg71LMUWWM4IIoyAi5VeqSiMBQ7J6SaMMXEDPPjXjciQ810qYFjGyrm3uRckwatdj)LaIfX0yr5GOytZyVEcBKZNdjtbBY6HPBAg71LMEucyN3t2CtTk9TaMgs(lbelIPXIYbrXM(hpgtkgKexCu7OaVC5K4mMEtPNWMsWMMXEDPPL17QNv(U)N0n3uRIkwatZyVU00al81nibkiDwAAi5VeqSiMBQv5blGPHK)saXIyASOCquSP)XJXmALiJyrqB)CGAkakUsst5XnLhqX0m2RlnD0krgXIG2(5aL5MBA(alGPUVfW0qYFjGyrmnwuoik20)4XyUYLK4NGAgVyAg71LMEioIVjRhMU5MAvSaMgs(lbelIPXIYbrXMMXE9e2iNphsMc2K1dtVP0tyt5btZyVU00Jsa78EYMBQFWcyAi5VeqSiMMXEDPPhsMc2K1dt30yr5GOyt7SesFokbSZ7jpHK)saPPGo6nf89eso9zcyXjpbIPXbHLW2zXl4etDFZn1OQfW0qYFjGyrmnJ96stVikQtGuSChLFcMglkhefBAv1u(XJXCruuNaPy5ok)eMXlnfuRP0RBkQQP4SesFs8tqrhGfqmHK)saPPGo6nLF8ymj(jOOdWciMXlnLhLPXbHLW2zXl4etDFZn1bBbmnJ96st)eilGy7NduMgs(lbelI5MAvZcyAi5VeqSiMglkhefB6F8ymxef1jqkwUJYpHz8stb1Ak)4XysXGK4IJAhf4LlNeNX0Bk9e2uc20m2RlnTSEx9SY39)KU5MAuPfW0m2RlnnwWK1TSEx9SYxtdj)LaIfXCtnQWcyAi5VeqSiMglkhefB6F8ymj(jOOdWciMXlnfuRP8JhJjfdsIloQDuGxUCsCgtVP0tytjytZyVU004vUYTSEx9SYxZn1OolGPHK)saXIyASOCquSP)XJXKIbjXfh1okWlxojoJP3u6jSPeSPzSxxAA8kx5ELfpbIBUPUpkwatdj)LaIfX0yr5GOyt)JhJjfdsIloQDuGxUCsCgtVP0tytj4McQ1uySxpHnKavbKMIQcBkpyAg71LMgKafKol3FjtCZn197BbmnK8xciwetJfLdIIn9pEmMumijU4O2rbE5YjXzm9MspHnLGnnJ96stt8tqrhGfqyUPUVkwatdj)LaIfX0yr5GOyt)JhJjfdsIloQDuGxUCsCgtVPe2u6JIPzSxxAA8kx5wwVREw5R5M6(pybmnK8xciwetZyVU00djtbBY6HPBASOCquSPDwcPphLa259KNqYFjGyACqyjSDw8coXu33CtDFu1cyAg71LMMeNiGOYxtdj)LaIfXCtD)GTaMMXEDPPj(jOiUOOdMgs(lbelI5M6(QMfW0m2RlnTKFYBjtwnnK8xciweZn19rLwatdj)LaIfX0m2Rln9qYuWMSEy6MglkhefBAbmeazL)sW04GWsy7S4fCIPUV5M6(OclGPHK)saXIyASOCquSP)XJXKIbjXfh1okWlxojoJP3u6jSPeCtb1Akm2RNWgsGQastjSP8GPzSxxAAqcuq6SC)LmXn3u3h1zbmnJ96stpyy7cojJysDPPHK)saXIyUPwfuSaMMXEDPPhIJ4BY6HPBAi5VeqSiMBQvPVfW0m2RlnDHHnXffDW0qYFjGyrm3uRIkwatdj)LaIfX0yr5GOyt)JhJjfdsIloQDuGxUCsCgtVP0tytjytZyVU004vUYTSEx9SYxZn1Q8GfW0qYFjGyrmnwuoik20m2RNWg585qYuWMSEy6nLEAk9nnJ96stpkbSZ7jBUPwfu1cyAg71LMgyHVc5MSu0btdj)LaIfXCtTkbBbmnJ96stdSWx3GeOG0zPPHK)saXIyUPwfvZcyAi5VeqSiMglkhefB6F8ymJwjYiwe02phOMcGIRK0uECt5bumnJ96sthTsKrSiOTFoqzU5MgbgCS0TaM6(watZyVU00F5DiYyIBAi5VeqSV5MAvSaMgs(lbelIPXIYbrXMEuVR(wauCLKMYJBkQgkMMXEDPPxoVU0Ct9dwatZyVU00rReztwbwyAi5VeqSiMBQrvlGPzSxxA6OvIqCrrhmnK8xciweZn1bBbmnJ96stJVedPlyhq2djtbMgs(lbelI5MAvZcyAg71LM(lVdzFJTVcBibQGmnK8xciweZn1OslGPzSxxA63ywGuCUVXMF0G48vtdj)LaIfXCtnQWcyAg71LMEC4ycGS5hnikh2FGPmnK8xciweZn1OolGPzSxxA6LyrncQY39xYe30qYFjGyrm3u3hflGPzSxxAAFf2X5)ItK94eyW0qYFjGyrm3u3VVfW0m2RlnnfqDIG23ylJXfYgramfX0qYFjGyrm3u3xflGPzSxxAArTSiHDLBYcJbtdj)LaIfXCtD)hSaMMXEDPPJEcjYtOYTaixYjgmnK8xciweZn19rvlGPHK)saXIyASOCquSPDw8c(CfyPVUxWEtPNMcQaLMc6O3uCw8c(CfyPVUxWEt5XnfvqPPGo6nLr9U6BbqXvsAkpUP8akMMXEDPPfaVu57EizkGyUPUFWwatZyVU00Ral8nqiqIbtdj)LaIfXCtDFvZcyAg71LMoMa7YbkIPHK)saXIyUPUpQ0cyAi5VeqSiMglkhefBAv1uCwcPpzcgseoXWes(lbKMc6O3u(XJXKjyir4edZ4LMc6O3uW3jrUO5Kjyir4edtbqXvsAk90ucgftZyVU00F5Di7rSiiZn19rfwatdj)LaIfX0yr5GOytRQMIZsi9jtWqIWjgMqYFjG0uqh9MYpEmMmbdjcNyygVyAg71LM(dcciOx5R5M6(OolGPHK)saXIyASOCquSPvvtXzjK(Kjyir4edti5VeqAkOJEt5hpgtMGHeHtmmJxAkOJEtbFNe5IMtMGHeHtmmfafxjPP0ttjyumnJ96stpkb8L3HyUPwfuSaMgs(lbelIPXIYbrXMwvnfNLq6tMGHeHtmmHK)saPPGo6nLF8ymzcgseoXWmEPPGo6nf8DsKlAozcgseoXWuauCLKMspnLGrX0m2RlnnNyG4cwUXSuAUPwL(watdj)LaIfX0yr5GOytRQMIZsi9jtWqIWjgMqYFjG0uqh9MIQAk)4XyYemKiCIHz8IPzSxxA6p)UVX2ffMoXCtTkQybmnJ96stpabl3KLsuUPHK)saXIyUPwLhSaMMXEDPPzcgseoXGPHK)saXIyUPwfu1cyAi5VeqSiMglkhefBAg71tydjqvaPPe2u6BAg71LMgZs5MXED5wwe30YI47KPattQ8vcMBQvjylGPHK)saXIyASOCquSPzSxpHnKavbKMspnL(MMXEDPPXSuUzSxxULfXnTSi(ozkW08bMBQvr1SaMMXEDPPxeffl3exu0btdj)LaIfXCZn9IaWh1NDlGPUVfW0qYFjGyrmnwuoik20)4XygTsKrSiODuGxUCkakUsst5XnLhqbftZyVU00rRezelcAhf4Lln3uRIfW0qYFjGyrmnwuoik20)4XyoKmf4x(gd7OaVC5uauCLKMYJBkpGckMMXEDPPhsMc8lFJHDuGxU0Ct9dwatdj)LaIfX0yr5GOyt)JhJPSEx9SY3nzTajYuauCLKMYJBkpGckMMXEDPPL17QNv(UjRfirm3uJQwatdj)LaIfX0yr5GOyt)JhJz0krgXIG2(5a1e5IMMMXEDPPJwjYiwe02phOm3uhSfW0qYFjGyrmnwuoik20olH0Ne)eu0bybeti5VeqmnJ96stt8tqrhGfqyU5MB6NGGuxAQvbfvqPpkQGQZ(MoklYkFjMUxqTCchqAkOAtHXEDztrweNmB0mnh7RNW06I6ry6fXnkjy6E3uq95kNyGcsVPOxzkoB06Dtr1J97dIMYd9rRPOckQGsJwJwVBk9siiast5rCpHKtVPW)swEbKzJwVBk9YaXpb0uq9ecKyGmB06Dtr1HOOyztr7IIomBknLELQVxnB0A0ySxxsMlcaFuF2dJwjYiwe0okWlxIwnc)XJXmALiJyrq7OaVC5uauCLKh)akO0OXyVUKmxea(O(S3jS7qYuGF5BmSJc8YLOvJWF8ymhsMc8lFJHDuGxUCkakUsYJFafuA0ySxxsMlcaFuF27e2vwVREw57MSwGebTAe(JhJPSEx9SY3nzTajYuauCLKh)akO0OXyVUKmxea(O(S3jSB0krgXIG2(5afA1i8hpgZOvImIfbT9ZbQjYfnB0ySxxsMlcaFuF27e2L4NGIoalGaTAe6SesFs8tqrhGfqmHK)saPrRrR3nfuVQtah7astbEcIGAkErbnfFfAkm2prtPinf(jxs(lHzJgJ96ss4xEhImM4nA9UP0lsvx4J6ZEtz586YMsrAkFyCcOPGpQp7nfiriZgng71LKoHDxoVUeTAeoQ3vFlakUsYJvnuA06DtPxKoieXlEt5gnfmtCYSrJXEDjPty3OvISjRalA0ySxxs6e2nALiexu0Hgng71LKoHDXxIH0fSdi7HKPGgng71LKoHD)Y7q23y7RWgsGkOgng71LKoHDFJzbsX5(gB(rdIZxB0ySxxs6e2DC4ycGS5hnikh2FGPA0ySxxs6e2DjwuJGQ8D)LmXB0ySxxs6e21xHDC(V4ezpobgA0ySxxs6e2LcOorq7BSLX4czJiaMI0OXyVUK0jSROwwKWUYnzHXqJgJ96ssNWUrpHe5ju5waKl5ednAm2RljDc7kaEPY39qYuabTAe6S4f85kWsFDVG9EqfOGo6olEbFUcS0x3ly)XQGc6OpQ3vFlakUsYJFaLgng71LKoHDxbw4BGqGednAm2RljDc7gtGD5afPrJXEDjPty3V8oK9iweeA1iuvolH0NmbdjcNyycj)Lac6O)JhJjtWqIWjgMXlOJo(ojYfnNmbdjcNyykakUsspbJsJgJ96ssNWUFqqab9kFrRgHQYzjK(Kjyir4edti5Veqqh9F8ymzcgseoXWmEPrJXEDjPty3rjGV8oe0QrOQCwcPpzcgseoXWes(lbe0r)hpgtMGHeHtmmJxqhD8DsKlAozcgseoXWuauCLKEcgLgng71LKoHD5edexWYnMLs0QrOQCwcPpzcgseoXWes(lbe0r)hpgtMGHeHtmmJxqhD8DsKlAozcgseoXWuauCLKEcgLgng71LKoHD)87(gBxuy6e0QrOQCwcPpzcgseoXWes(lbe0rxv)4XyYemKiCIHz8sJgJ96ssNWUdqWYnzPeL3OXyVUK0jSltWqIWjgA06DtPxmAkxkdQPCj0uGeOccTMYIOor5b1ugNuErjnfFfAkpssLVs4r2uySxx2uKfXNnAm2RljDc7IzPCZyVUCllIJwYuqiPYxjGwnczSxpHnKavbKW(nA9UPO6ZMcvS0Rfj0uGeOkGGwtXxHMYIOor5b1ugNuErjnfFfAkps(GhztHXEDztrweF2OXyVUK0jSlMLYnJ96YTSioAjtbH8bOvJqg71tydjqvaPN(nAm2RljDc7UikkwUjUOOdnAnA9UPO6ow6vtXzXl4nfg71LnLfrDIYdQPilI3OXyVUKm5dchIJ4BY6HPJwnc)XJXCLljXpb1mEPrJXEDjzYh0jS7OeWoVNmA1iKXE9e2iNphsMc2K1dtVNWhA0ySxxsM8bDc7oKmfSjRhMoA4GWsy7S4fCsyF0QrOZsi95OeWoVN8es(lbe0rhFpHKtFMawCYtG0OXyVUKm5d6e2DruuNaPy5ok)eqdhewcBNfVGtc7Jwncv1pEmMlII6eifl3r5NWmEb161QYzjK(K4NGIoalGycj)Lac6O)JhJjXpbfDawaXmE5r1OXyVUKm5d6e29jqwaX2phOA0ySxxsM8bDc7kR3vpR8D)pPJwnc)XJXCruuNaPy5ok)eMXlO2pEmMumijU4O2rbE5YjXzm9EcdUrJXEDjzYh0jSlwWK1TSEx9SY3gng71LKjFqNWU4vUYTSEx9SYx0Qr4pEmMe)eu0bybeZ4fu7hpgtkgKexCu7OaVC5K4mMEpHb3OXyVUKm5d6e2fVYvUxzXtG4OvJWF8ymPyqsCXrTJc8YLtIZy69egCJgJ96sYKpOtyxqcuq6SC)LmXrRgH)4XysXGK4IJAhf4LlNeNX07jmyuJXE9e2qcufquv4dnAm2Rljt(GoHDj(jOOdWciqRgH)4XysXGK4IJAhf4LlNeNX07jm4gng71LKjFqNWU4vUYTSEx9SYx0Qr4pEmMumijU4O2rbE5YjXzm9W(O0OXyVUKm5d6e2DizkytwpmD0WbHLW2zXl4KW(OvJqNLq6ZrjGDEp5jK8xcinAm2Rljt(GoHDjXjciQ8TrJXEDjzYh0jSlXpbfXffDOrJXEDjzYh0jSRKFYBjtwB0ySxxsM8bDc7oKmfSjRhMoA4GWsy7S4fCsyF0QrOagcGSYFj0OXyVUKm5d6e2fKafKol3FjtC0Qr4pEmMumijU4O2rbE5YjXzm9Ecdg1ySxpHnKavbKWhA0ySxxsM8bDc7oyy7cojJysDzJgJ96sYKpOty3H4i(MSEy6nAm2Rljt(GoHDlmSjUOOdnAm2Rljt(GoHDXRCLBz9U6zLVOvJWF8ymPyqsCXrTJc8YLtIZy69egCJgJ96sYKpOty3rjGDEpz0QriJ96jSroFoKmfSjRhMEp9B0ySxxsM8bDc7cSWxHCtwk6qJgJ96sYKpOtyxGf(6gKafKolB0ySxxsM8bDc7gTsKrSiOTFoqHwnc)XJXmALiJyrqB)CGAkakUsYJFaLgTgTE3u0v(kHMIZIxWBkm2RlBklI6eLhutrweVrJXEDjzsQ8vcHlII6eifl3r5NaA1iuv)4XyUikQtGuSChLFcZ4fuRxRkNLq6tIFck6aSaIjK8xciOJ(pEmMe)eu0bybeZ4LhvJgJ96sYKu5Re6e2DizkytwpmD0QrOQ8ctVY3gng71LKjPYxj0jS7tGSaITFoq1OXyVUKmjv(kHoHDhIJ4BY6HPJwnc)XJXCLljXpb1mEPrJXEDjzsQ8vcDc7cSWxHCtwk6qJgJ96sYKu5Re6e2DWW2fCsgXK6Ygng71LKjPYxj0jSRSEx9SY39)KoA1i8hpgtIFck6aSaIz8cQ9JhJjfdsIloQDuGxUCsCgtVNWGB0ySxxsMKkFLqNWUGeOG0z5(lzIJwnc)XJXKIbjXfh1okWlxojoJP3tyWnAm2RljtsLVsOtyx8kx5ELfpbIJwnc)XJXKIbjXfh1okWlxojoJP3tyWnAm2RljtsLVsOtyxz9U6zLV7)jD0Qr4pEmMumijU4O2rbE5YjXzm9W(O0OXyVUKmjv(kHoHDL8tElzYkA1i8hpgZ1Z3RCImJxA0ySxxsMKkFLqNWUe)euexu0Hgng71LKjPYxj0jSlXpbfDawabA1i8hpgtkgKexCu7OaVC5K4mMEpHb3OXyVUKmjv(kHoHDL8tElzYAJgJ96sYKu5Re6e2flyY6wwVREw5BJgJ96sYKu5Re6e2DizkytwpmD0WbHLW2zXl4KW(OvJqbmeazL)sOrJXEDjzsQ8vcDc7oehX3K1dtVrJXEDjzsQ8vcDc7wyytCrrhA0ySxxsMKkFLqNWUK4ebev(2OXyVUKmjv(kHoHDhLa259KrRgHm2RNWg585qYuWMSEy6nAm2RljtsLVsOtyxz9U6zLV7)jD0Qr4pEmMumijU4O2rbE5YjXzm9EcdUrJXEDjzsQ8vcDc7cSWx3GeOG0zzJgJ96sYKu5Re6e2nALiJyrqB)CGcTAe(JhJz0krgXIG2(5a1uauCLKh)akMBUz]] )

end
