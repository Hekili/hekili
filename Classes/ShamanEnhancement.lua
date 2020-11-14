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
            max_stack = 1,
            copy = "doom_winds_buff"
        },

        doom_winds_cd = {
            id = 335904,
            duration = 60,
            max_stack = 1,
            copy = "doom_winds_debuff"
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

            cycle = function () return talent.lashing_flames.enabled and "lashing_flames" or nil  end,

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
                    applyBuff( "doom_winds_cd" ) -- SimC weirdness.
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


    spec:RegisterPack( "Enhancement", 20201113, [[de0HTaqiPs1JurvBsQK8jvuOrbuOtjvc9kHQzbe3sQKQSlf(LuXWiuoMIyzeQEgqPPbu01uKABQOY3KkfJtQeDoPsP5PIs3ti7trYbvrbTqHYdvrrUOuj4KsLuwjHCtPsQ0ojf)uQKQAPQOapLKPskTxk)vjdwGdJAXaEmOjRsxgAZs5ZQWOvuNwYRfuZMOBtWUf9BvnCPQJduWYr65iMovxNuTDvKVliJxQKkopq16vrrnFG0(vQTjMwtDzhnnIlM4InzYeWCiw3oPlN0nMYbVhnvpddZhOPswanvxiN5eIcy6MQNbx(810AkYRtHOPuLWzYua6L07APbyQl7OPrCXexSjtMaMdX62jD5eW0uKEeAAe)CG1uZ19IPbyQlsGM687GUqoZjefW03bQzwGZTOZVd08NqbaKUdMawq2bIlM4ITfTfD(DWz49I3DWz6pHjN(oGbkz5fsgBrNFhCgGe)P4oOlqiycrYWuYI4etRPivEirtRPzIP1uyYas8AXmfKwosl2uDFhaO3AJEAj80BXYvi(eo07nfd96tt1tlHNElwUcXNqZnnIBAnfMmGeVwmtbPLJ0InfvpX2tpWX9FHvOkVKbcg0R(E8Ud6QDaGERnU)lScv5LSUiGERnUFO0um0RpnvOkVnDk4l)DuWCtdynTMctgqIxlMPG0YrAXMQ77aVGHR8Wum0RpnvtYc4Im)WWMBAattRPyOxFAQtiPhPl)DuWuyYas8AXm30mTP1uyYas8AXmfKwosl2ua6T2yMljXFQWqV3um0RpnvJ(eFrMFyyZnnNZ0Akg61NMczQpJ5I0xHrtHjdiXRfZCtt3yAnfd96tt1yC5uojnDs9PPWKbK41IzUPPlnTMctgqIxlMPG0YrAXMcqV1ge)PcHrShPd9EtXqV(0uY6y2ZkpwaV0n300TMwtHjdiXRfZuqA5iTytbO3AdbgLeN(cRqi3)5G4mm8oyQODW0MIHE9PPqjkGPZYfGKjU5MMjIzAnfMmGeVwmtbPLJ0InfGERneyusC6lScHC)NdIZWW7GPI2btBkg61NMcoZvUMz6jK4MBAMmX0AkmzajETyMcslhPfBka9wBiWOK40xyfc5(pheNHH3br7GjIzkg61NMswhZEw5Xc4LU5MMjIBAnfMmGeVwmtbPLJ0InfGERnMFFnZ5DO3Vdaf0DayChq1tS90dC0tlbwUK8jEXqxN9NsgiyqV67X7oOR2ba6T2ONwcSCj5t8IHUo7pLmioddVdMAhCUDqx0um0RpnLKpXljtMn30mbSMwtXqV(0ue)PceNwHrtHjdiXRfZCtZeW00AkmzajETyMcslhPfBka9wBiWOK40xyfc5(pheNHH3btfTdM2um0RpnfXFQqye7rQ5MMjtBAnfd96ttj5t8sYKztHjdiXRfZCtZKZzAnfd96ttbPmzEjRJzpR8WuyYas8AXm30mPBmTMctgqIxlMPyOxFAQMKfWfz(HHnfKwosl2uuSrrYmdirtbbhkXLZ0d0jMMjMBAM0LMwtXqV(0un6t8fz(HHnfMmGeVwmZnnt6wtRPyOxFAQcIlItRWOPWKbK41IzUPrCXmTMIHE9PPi65fPvEykmzajETyMBAeFIP1uyYas8AXmfKwosl2um0Rt46((OjzbCrMFyytXqV(0uTIIR8pXMBAexCtRPWKbK41IzkiTCKwSPa0BTHaJsItFHviK7)CqCggEhmv0oyAtXqV(0uY6y2ZkpwaV0n30ioynTMIHE9PPqM6ZluIcy6S0uyYas8AXm30ioyAAnfMmGeVwmtbPLJ0InfGERncv5TPtbF5VJcdkkWvs2bNDhawXmfd96ttfQYBtNc(YFhfm3CtXpAAnntmTMctgqIxlMPG0YrAXMcqV1gZCjj(tfg69MIHE9PPA0N4lY8ddBUPrCtRPWKbK41IzkiTCKwSPO6j2E6boU)lScv5LmqWGE13J3DqxTda0BTX9FHvOkVK1fb0BTX9dLMIHE9PPcv5TPtbF5VJcMBAaRP1uyYas8AXmfd96tt1KSaUiZpmSPG0YrAXMIInksMzajUd6QDayCh4SetF0kkUY)epWKbK4DhakO7aNLy6djtMR8y1KSasgyYas8Udaf0Da8pHjN(iri9Lp9Ud6IMccouIlNPhOtmntm30aMMwtHjdiXRfZum0RpnvpTeE6Ty5keFcnfKwosl2uDFhaO3AJEAj80BXYvi(eo07nfeCOexotpqNyAMyUPzAtRPWKbK41IzkiTCKwSPyOxNW199rtYc4Im)WW7GPI2bG1um0RpnvRO4k)tS5MMZzAnfd96ttDcj9iD5VJcMctgqIxlM5MMUX0AkmzajETyMcslhPfBka9wB0tlHNElwUcXNWHE)oOR2bGXDaGERni(tfcJypsh697aqbDhaO3AdbgLeN(cRqi3)5G4mm8oyQODW07GUOPyOxFAkzDm7zLhlGx6MBA6stRPWKbK41IzkiTCKwSPCwIPpGuMmx5XI4pvyGjdiX7oauq3ba6T2aszY8swhZEw5X4(HstXqV(0uqktMxY6y2Zkpm300TMwtHjdiXRfZum0RpnLKpXljtMnfKwosl2uolX0hsMmx5XQjzbKmWKbK41uqWHsC5m9aDIPzI5MMjIzAnfd96ttbPmzEjRJzpR8WuyYas8AXm30mzIP1uyYas8AXmfKwosl2ua6T2G4pvimI9iDO3Bkg61NMcoZvUK1XSNvEyUPzI4MwtHjdiXRfZuqA5iTytbO3AdbgLeN(cRqi3)5G4mm8oyQODW0MIHE9PPGZCLRzMEcjU5MMjG10AkmzajETyMcslhPfBka9wBiWOK40xyfc5(pheNHH3btfTdM2um0RpnfkrbmDwUaKmXn30mbmnTMctgqIxlMPG0YrAXMcqV1gcmkjo9fwHqU)ZbXzy4DWur7GPnfd96ttr8NkegXEKAUPzY0MwtHjdiXRfZuqA5iTytbO3AdbgLeN(cRqi3)5G4mm8oiAhmrmtXqV(0uWzUYLSoM9SYdZnntoNP1uyYas8AXmfd96tt1KSaUiZpmSPG0YrAXMYzjM(OvuCL)jEGjdiXRPGGdL4Yz6b6etZeZnnt6gtRPyOxFAkIEErALhMctgqIxlM5MMjDPP1uyYas8AXmfd96ttj5t8sYKztbPLJ0InfvpX2tpWrpTey5sYN4fdDD2FkzGGb9QVhV7GUAhaO3AJEAjWYLKpXlg66S)uYG4mm8oyQDW5mfeCOexotpqNyAMyUPzs3AAnfd96ttr8NkqCAfgnfMmGeVwmZnnIlMP1um0RpnLKpXljtMnfMmGeVwmZnnIpX0AkmzajETyMIHE9PPAswaxK5hg2uqA5iTytrXgfjZmGenfeCOexotpqNyAMyUPrCXnTMIHE9PPAmUCkNKMoP(0uyYas8AXm30ioynTMIHE9PPA0N4lY8ddBkmzajETyMBAehmnTMIHE9PPkiUioTcJMctgqIxlM5MgXN20AkmzajETyMcslhPfBka9wBiWOK40xyfc5(pheNHH3btfTdM2um0RpnfCMRCjRJzpR8WCtJ4NZ0AkmzajETyMcslhPfBkg61jCDFF0KSaUiZpm8oyQDWetXqV(0uTIIR8pXMBAeVBmTMIHE9PPqM6ZyUi9vy0uyYas8AXm30iExAAnfd96ttHm1NxOefW0zPPWKbK41IzUPr8U10AkmzajETyMcslhPfBka9wBeQYBtNc(YFhfguuGRKSdo7oaSIzkg61NMkuL3Mof8L)okyU5M6Inwx6MwtZetRPyOxFAka5)xPoXnfMmGeVgG5MgXnTMctgqIxlMPG0YrAXMQvhZ(IIcCLKDWz3bNtmtXqV(0u9VxFAUPbSMwtXqV(0uHQ8UiZitnfMmGeVwmZnnGPP1um0RpnvOkVeNwHrtHjdiXRfZCtZ0MwtXqV(0uWpHy6u2X7Qjzb0uyYas8AXm30CotRPyOxFAka5)313w(mUWefa3uyYas8AXm300nMwtXqV(0uh6m9wCU(2IpZi99ztHjdiXRfZCttxAAnfd96tt1EOobVl(mJ0YXfaYcMctgqIxlM5MMU10Akg61NMQxNwnWR8ybizIBkmzajETyMBAMiMP1um0RpnLpJl9e41Z7Q9uiAkmzajETyMBAMmX0Akg61NMsafEk4RVTK6W6UUuKfiMctgqIxlM5MMjIBAnfd96ttrR(EjUQCr6ziAkmzajETyMBAMawtRPyOxFAQqpvEpHvUOi5toHOPWKbK41IzUPzcyAAnfMmGeVwmtbPLJ0InLZ0d0hZil95vp03btTd6sX2bGc6oWz6b6JzKL(8Qh67GZUdexSDaOGUdA1XSVOOaxjzhC2DayfZum0Rpnff5(kpwnjlGeZnntM20Akg61NMAgzQVqcbtiAkmzajETyMBAMCotRPyOxFAkDcUkhfiMctgqIxlM5MMjDJP1uyYas8AXmfKwosl2uDFh4SetFWeiMxoH4atgqI3DaOGUda0BTbtGyE5eId9(DaOGUdG)lVFOCWeiMxoH4GIcCLKDWu7GPfZum0RpnfG8)7QPtb3CtZKU00AkmzajETyMcslhPfBQUVdCwIPpyceZlNqCGjdiX7oauq3ba6T2GjqmVCcXHEVPyOxFAkaKsqA4kpm30mPBnTMctgqIxlMPG0YrAXMQ77aNLy6dMaX8YjehyYas8Udaf0DaGERnyceZlNqCO3Vdaf0Da8F59dLdMaX8YjehuuGRKSdMAhmTyMIHE9PPAffbK)Fn30iUyMwtHjdiXRfZuqA5iTyt19DGZsm9btGyE5eIdmzajE3bGc6oaqV1gmbI5Ltio073bGc6oa(V8(HYbtGyE5eIdkkWvs2btTdMwmtXqV(0uCcrItz5cYsP5MgXNyAnfMmGeVwmtbPLJ0Inv33bolX0hmbI5LtioWKbK4DhakO7GUVda0BTbtGyE5eId9EtXqV(0ua8X6BlNwWWeZnnIlUP1um0RpnvdPSCr6lA5MctgqIxlM5MgXbRP1um0RpnftGyE5eIMctgqIxlM5MgXbttRPWKbK41IzkiTCKwSPyOxNWfMOqHKDq0oyIPyOxFAkilLlg61NlzrCtjlIVswanfPYdjAUPr8PnTMctgqIxlMPG0YrAXMIHEDcxyIcfs2btTdMykg61NMcYs5IHE95swe3uYI4RKfqtXpAUPr8ZzAnfd96ttbF90rkXPvyC5VJcMctgqIxlM5MgX7gtRPyOxFAksyWB6uWx(7OGPWKbK41IzUPr8U00Akg61NMQNwcSCrCAfgnfMmGeVwmZn3u9ue(caSBAnntmTMctgqIxlMPG0YrAXMcqV1gHQ820PGVcHC)NdkkWvs2bNDhawXeZum0RpnvOkVnDk4Rqi3)P5MgXnTMctgqIxlMPG0YrAXMcqV1gnjlG(Nh64keY9FoOOaxjzhC2DayftmtXqV(0unjlG(Nh64keY9FAUPbSMwtHjdiXRfZuqA5iTytbO3AdzDm7zLhlYCHY7GIcCLKDWz3bGvmXmfd96ttjRJzpR8yrMluEn30aMMwtHjdiXRfZuqA5iTytbO3AJqvEB6uWx(7OW4(HstXqV(0uHQ820PGV83rbZnntBAnfMmGeVwmtbPLJ0InLZsm9bXFQqye7r6atgqIxtXqV(0ue)PcHrShPMBU5M6esj1NMgXftCXMigyNyQqmnR8GyQUMq)tD8UdaZDad96ZDGSiozSfzkw3NFQPuLWzYu90Vvs0uNFh0fYzoHOaM(oqnZcCUfD(DGM)ekaG0DWeWcYoqCXexSTOTOZVdodVx8Udot)jm503bmqjlVqYyl687GZaK4pf3bDbcbtisgBrBrm0RpjJEkcFba2Jcv5TPtbFfc5(pbPAra6T2iuL3Mof8viK7)CqrbUsYzbRyITfXqV(Km6Pi8faypEuNMKfq)ZdDCfc5(pbPAra6T2Ojzb0)8qhxHqU)Zbff4kjNfSIj2wed96tYONIWxaG94rDK1XSNvESiZfkVGuTia9wBiRJzpR8yrMluEhuuGRKCwWkMyBrm0RpjJEkcFba2Jh1juL3Mof8L)okas1Ia0BTrOkVnDk4l)DuyC)q5wed96tYONIWxaG94rDi(tfcJypsbPArolX0he)PcHrShPdmzajE3I2Io)oOl01bH6oE3b4jKc(oWlbCh4Z4oGH(t3bfzhWN4sYasCSfXqV(Kebi))k1j(w053bDTSRh8fayFh0)E95oOi7aaS9uChaFba23byEjJTig61NK4rD6FV(eKQf1QJzFrrbUsYzpNyBrNFh01shPu9EFh8TDaKjozSfXqV(KepQtOkVlYmY0Tig61NK4rDcv5L40kmUfXqV(KepQd8tiMoLD8UAswa3IyOxFsIh1bq()D9TLpJlmrbW3IyOxFsIh15qNP3IZ13w8zgPVpVfXqV(KepQt7H6e8U4ZmslhxailSfXqV(KepQtVoTAGx5XcqYeFlIHE9jjEuhFgx6jWRN3v7PqClIHE9jjEuhbu4PGV(2sQdR76srwGSfXqV(KepQdT67L4QYfPNH4wed96ts8OoHEQ8EcRCrrYNCcXTig61NK4rDOi3x5XQjzbKas1ICMEG(ygzPpV6H(uDPyGcQZ0d0hZil95vp0pR4IbkOT6y2xuuGRKCwWk2wed96ts8OoZit9fsiycXTig61NK4rD0j4QCuGSfXqV(KepQdG8)7QPtbhKQf1DNLy6dMaX8YjehyYas8ckOa6T2GjqmVCcXHEpOGc)xE)q5GjqmVCcXbff4kjtnTyBrm0RpjXJ6aGucsdx5bivlQ7olX0hmbI5LtioWKbK4fuqb0BTbtGyE5eId9(Tig61NK4rDAffbK)FbPArD3zjM(GjqmVCcXbMmGeVGckGERnyceZlNqCO3dkOW)L3puoyceZlNqCqrbUsYutl2wed96ts8OoCcrItz5cYsjivlQ7olX0hmbI5LtioWKbK4fuqb0BTbtGyE5eId9Eqbf(V8(HYbtGyE5eIdkkWvsMAAX2IyOxFsIh1bGpwFB50cgMas1I6UZsm9btGyE5eIdmzajEbf0UdO3AdMaX8Yjeh69Brm0RpjXJ60qklxK(Iw(wed96ts8OombI5LtiUfD(DqxRTd(uc(o4tChGjkaoi7GEA90YbFh0EP8dr2b(mUdoJKkpK4zChWqV(ChilIp2IyOxFsIh1bYs5IHE95swehKKfWisLhseKQfXqVoHlmrHcjrt2Io)oORFUde0LE1lXDaMOqHeq2b(mUd6P1tlh8Dq7LYpezh4Z4o4mYpEg3bm0Rp3bYI4JTig61NK4rDGSuUyOxFUKfXbjzbmIFeKQfXqVoHlmrHcjtnzlIHE9jjEuh4RNosjoTcJl)DuylIHE9jjEuhsyWB6uWx(7OWwed96ts8Oo90sGLlItRW4w0w053bDD1LETdCMEG(oGHE95oONwpTCW3bYI4Brm0Rpjd(XOg9j(Im)WWGuTia9wBmZLK4pvyO3VfXqV(Km4hJh1juL3Mof8L)okas1IO6j2E6boU)lScv5LmqWGE13J3UcqV1g3)fwHQ8swxeqV1g3puUfXqV(Km4hJh1PjzbCrMFyyqGGdL4Yz6b6KOjGuTik2OizMbKyxbgDwIPpAffx5FIhyYas8ckOolX0hsMmx5XQjzbKmWKbK4fuqH)jm50hjcPV8P3U4wed96tYGFmEuNEAj80BXYvi(ecceCOexotpqNenbKQf1Da9wB0tlHNElwUcXNWHE)wed96tYGFmEuNwrXv(NyqQwed96eUUVpAswaxK5hgEQiWUfXqV(Km4hJh15es6r6YFhf2IyOxFsg8JXJ6iRJzpR8yb8shKQfbO3AJEAj80BXYvi(eo077kWiGERni(tfcJypsh69GckGERneyusC6lScHC)NdIZWWtfnDxClIHE9jzWpgpQdKYK5LSoM9SYdqQwKZsm9bKYK5kpwe)PcdmzajEbfua9wBaPmzEjRJzpR8yC)q5wed96tYGFmEuhjFIxsMmdceCOexotpqNenbKQf5SetFizYCLhRMKfqYatgqI3Tig61NKb)y8OoqktMxY6y2Zkp2IyOxFsg8JXJ6aN5kxY6y2ZkpaPAra6T2G4pvimI9iDO3VfXqV(Km4hJh1boZvUMz6jK4GuTia9wBiWOK40xyfc5(pheNHHNkA6Tig61NKb)y8OoOefW0z5cqYehKQfbO3AdbgLeN(cRqi3)5G4mm8urtVfXqV(Km4hJh1H4pvimI9ifKQfbO3AdbgLeN(cRqi3)5G4mm8urtVfXqV(Km4hJh1boZvUK1XSNvEas1Ia0BTHaJsItFHviK7)CqCggoAIyBrm0Rpjd(X4rDAswaxK5hggei4qjUCMEGojAcivlYzjM(OvuCL)jEGjdiX7wed96tYGFmEuhIEErALhBrm0Rpjd(X4rDK8jEjzYmiqWHsC5m9aDs0eqQwevpX2tpWrpTey5sYN4fdDD2FkzGGb9QVhVDfGERn6PLalxs(eVyORZ(tjdIZWWtDUTig61NKb)y8Ooe)PceNwHXTig61NKb)y8Oos(eVKmzElIHE9jzWpgpQttYc4Im)WWGabhkXLZ0d0jrtaPAruSrrYmdiXTig61NKb)y8OongxoLtstNuFUfXqV(Km4hJh1PrFIViZpm8wed96tYGFmEuNcIlItRW4wed96tYGFmEuh4mx5swhZEw5bivlcqV1gcmkjo9fwHqU)ZbXzy4PIMElIHE9jzWpgpQtRO4k)tmivlIHEDcx33hnjlGlY8ddp1KTig61NKb)y8Ooit9zmxK(kmUfXqV(Km4hJh1bzQpVqjkGPZYTig61NKb)y8OoHQ820PGV83rbqQweGERncv5TPtbF5VJcdkkWvsolyfBlAl687avLhsCh4m9a9Dad96ZDqpTEA5GVdKfX3IyOxFsgKkpKyupTeE6Ty5keFcbPArDhqV1g90s4P3ILRq8jCO3VfXqV(KmivEiX4rDcv5TPtbF5VJcGuTiQEITNEGJ7)cRqvEjdemOx994TRa0BTX9FHvOkVK1fb0BTX9dLBrm0RpjdsLhsmEuNMKfWfz(HHbPArD3ly4kp2IyOxFsgKkpKy8OoNqspsx(7OWwed96tYGu5HeJh1PrFIViZpmmivlcqV1gZCjj(tfg69Brm0RpjdsLhsmEuhKP(mMlsFfg3IyOxFsgKkpKy8OongxoLtstNuFUfXqV(KmivEiX4rDK1XSNvESaEPds1Ia0BTbXFQqye7r6qVFlIHE9jzqQ8qIXJ6GsuatNLlajtCqQweGERneyusC6lScHC)NdIZWWtfn9wed96tYGu5HeJh1boZvUMz6jK4GuTia9wBiWOK40xyfc5(pheNHHNkA6Tig61NKbPYdjgpQJSoM9SYJfWlDqQweGERneyusC6lScHC)NdIZWWrteBlIHE9jzqQ8qIXJ6i5t8sYKzqQweGERnMFFnZ5DO3dkOGrQEITNEGJEAjWYLKpXlg66S)uYabd6vFpE7ka9wB0tlbwUK8jEXqxN9NsgeNHHN6CDXTig61NKbPYdjgpQdXFQaXPvyClIHE9jzqQ8qIXJ6q8NkegXEKcs1Ia0BTHaJsItFHviK7)CqCggEQOP3IyOxFsgKkpKy8Oos(eVKmzElIHE9jzqQ8qIXJ6aPmzEjRJzpR8ylIHE9jzqQ8qIXJ60KSaUiZpmmiqWHsC5m9aDs0eqQwefBuKmZasClIHE9jzqQ8qIXJ60OpXxK5hgElIHE9jzqQ8qIXJ6uqCrCAfg3IyOxFsgKkpKy8Ooe98I0kp2IyOxFsgKkpKy8OoTIIR8pXGuTig61jCDFF0KSaUiZpm8wed96tYGu5HeJh1rwhZEw5Xc4LoivlcqV1gcmkjo9fwHqU)ZbXzy4PIMElIHE9jzqQ8qIXJ6Gm1NxOefW0z5wed96tYGu5HeJh1juL3Mof8L)okas1Ia0BTrOkVnDk4l)DuyqrbUsYzbRyMBUz]] )

end
