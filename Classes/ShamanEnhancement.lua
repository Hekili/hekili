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


    spec:RegisterPack( "Enhancement", 20201123, [[deeLTaqiPO8ivu1MKIWNKIQAuGkPtbQu9kHQzbkDlPOszxk8lPWWavDmfLLHu1ZavmnPi6AkQABQO4BQOuJtksDoqLyEQOY9eY(uu5GsrvAHcLhQIsCrqLYjLIkwjs5MsrL0ojf)ukQuTuPOkEkjtLuAVu(RsnybomQfdYJbMSkDzOnlvFwfgTICAjVwqMnr3gj7w0Vv1WLshxkswoHNJy6uDDs12vr(UGA8srL48ivwVkkP5dk2Vs2MzAn1LD00qp80d)Sz0dNXSZap8ZmLtxlAQwgeIpqtLmfAk4woXjaPW0nvltN85RP1uKxxaqtPkQZIPG0lP3CsdYux2rtd9Wtp8ZMrpCgZod8Wd)8MI0Iatd9NboMAQUxmnitDrcWuNFfa3YjobifM(kqnXuCUOD(vGM)esbHIva9Wb2va9Wtp8lAlANFf08EV4DfCw(tyYPVcyOswEHKXI25xbnpiXFbUcGBecMaKmmLSioX0AksLhs00AAMzAnfMmKeVwmtbeLJIInvZwbq69(OvuuV4wSChMpHd9wtXaV(0uTII6f3IL7W8j0Ctd9MwtHjdjXRfZuar5OOytj0tS)IdCC)NAhUYlzGnLE12I3vqtScG079X9FQD4kVK9fH079X9dNMIbE9PPcx5TRlOB7VJuMBAGJP1uyYqs8AXmfquokk2unBf4fiuLhMIbE9PP6sMc3KPheYCtttAAnfd86ttDcjTOy7VJuMctgsIxlM5MM5nTMctgsIxlMPaIYrrXMcsV3htCjj(lOg6TMIbE9PP6IN4BY0dczUP5mMwtXaV(0uil8jm3K2keAkmzijETyMBAoBtRPyGxFAQoJBxWjPRtQpnfMmKeVwmZnnnTP1uyYqs8AXmfquokk2uq69(G4VGkeITOyO3Akg41NMswhtEw5Xg6LU5Mg4IP1uyYqs8AXmfquokk2uq69(GIrjXfp1omYTFoiodcTcMlAfmVPyGxFAkuIuy6SCdjzIBUPzg8MwtHjdjXRfZuar5OOytbP37dkgLex8u7Wi3(5G4mi0kyUOvW8MIbE9PPatCL7jwCcjU5MMzZmTMctgsIxlMPaIYrrXMcsV3humkjU4P2HrU9ZbXzqOvq0kyg8MIbE9PPK1XKNvESHEPBUPzg9MwtHjdjXRfZuar5OOytbP37JP33tCEh6TRayGzfaxxbc9e7V4ahTIIILBjFI3mW1z)fKb2u6vBlExbnXkasV3hTIIILBjFI3mW1z)fKbXzqOvWCRGZScG7MIbE9PPK8jElzYK5MMzWX0Akg41NMI4VGI4IkeAkmzijETyMBAM1KMwtHjdjXRfZuar5OOytbP37dkgLex8u7Wi3(5G4mi0kyUOvW8MIbE9PPi(lOcHylkm30mBEtRPyGxFAkjFI3sMmzkmzijETyMBAMDgtRPyGxFAkGGjtBzDm5zLhMctgsIxlM5MMzNTP1uyYqs8AXmfd86tt1LmfUjtpiKPaIYrrXMsGDbsMyijAkaDajUDwCGoX0mZCtZSM20Akg41NMQlEIVjtpiKPWKHK41IzUPzgCX0Akg41NMQa4M4IkeAkmzijETyMBAOhEtRPyGxFAkIEErrLhMctgsIxlM5Mg6NzAnfMmKeVwmtbeLJIInfd86eUVVp6sMc3KPheYumWRpnvVe4o)tS5Mg6P30AkmzijETyMcikhffBki9EFqXOK4INAhg52pheNbHwbZfTcM3umWRpnLSoM8SYJn0lDZnn0dhtRPyGxFAkKf(0gLifMolnfMmKeVwmZnn03KMwtHjdjXRfZuar5OOytbP37JWvE76c62(7i1qGuCLKvW5wbWbEtXaV(0uHR821f0T93rkZn3u8JMwtZmtRPWKHK41IzkGOCuuSPG079XexsI)cQHERPyGxFAQU4j(Mm9GqMBAO30AkmzijETyMcikhffBkHEI9xCGJ7)u7WvEjdSP0R2w8UcAIvaKEVpU)tTdx5LSViKEVpUF40umWRpnv4kVDDbDB)DKYCtdCmTMctgsIxlMPyGxFAQUKPWnz6bHmfquokk2ucSlqYedjXvqtScGRRaNLy6JEjWD(N4bMmKeVRayGzf4SetFizYuLh7UKPqYatgsI3vamWSca)jm50hjceV8f3vaC3ua6asC7S4aDIPzM5MMM00AkmzijETyMIbE9PPAff1lUfl3H5tOPaIYrrXMQzRai9EF0kkQxClwUdZNWHERPa0bK42zXb6etZmZnnZBAnfMmKeVwmtbeLJIInfd86eUVVp6sMc3KPheAfmx0kaoMIbE9PP6La35FIn30CgtRPyGxFAQtiPffB)DKYuyYqs8AXm30C2MwtHjdjXRfZuar5OOytbP37Jwrr9IBXYDy(eo0BxbnXkaUUcG079bXFbvieBrXqVDfadmRai9EFqXOK4INAhg52pheNbHwbZfTcMFfa3nfd86ttjRJjpR8yd9s3CtttBAnfMmKeVwmtbeLJIInLZsm9bqWKPkp2e)fudmzijExbWaZkasV3habtM2Y6yYZkpg3pCAkg41NMciyY0wwhtEw5H5Mg4IP1uyYqs8AXmfd86ttj5t8wYKjtbeLJIInLZsm9HKjtvES7sMcjdmzijEnfGoGe3oloqNyAMzUPzg8MwtXaV(0uabtM2Y6yYZkpmfMmKeVwmZnnZMzAnfMmKeVwmtbeLJIInfKEVpi(lOcHylkg6TMIbE9PPatCLBzDm5zLhMBAMrVP1uyYqs8AXmfquokk2uq69(GIrjXfp1omYTFoiodcTcMlAfmVPyGxFAkWex5EIfNqIBUPzgCmTMctgsIxlMPaIYrrXMcsV3humkjU4P2HrU9ZbXzqOvWCrRG5nfd86ttHsKctNLBijtCZnnZAstRPWKHK41IzkGOCuuSPG079bfJsIlEQDyKB)CqCgeAfmx0kyEtXaV(0ue)fuHqSffMBAMnVP1uyYqs8AXmfquokk2uq69(GIrjXfp1omYTFoiodcTcIwbZG3umWRpnfyIRClRJjpR8WCtZSZyAnfMmKeVwmtXaV(0uDjtHBY0dczkGOCuuSPCwIPp6La35FIhyYqs8AkaDajUDwCGoX0mZCtZSZ20Akg41NMIONxuu5HPWKHK41IzUPzwtBAnfMmKeVwmtXaV(0us(eVLmzYuar5OOytj0tS)IdC0kkkwUL8jEZaxN9xqgytPxTT4Df0eRai9EF0kkkwUL8jEZaxN9xqgeNbHwbZTcoJPa0bK42zXb6etZmZnnZGlMwtXaV(0ue)fuexuHqtHjdjXRfZCtd9WBAnfd86ttj5t8wYKjtHjdjXRfZCtd9ZmTMctgsIxlMPyGxFAQUKPWnz6bHmfquokk2ucSlqYedjrtbOdiXTZId0jMMzMBAONEtRPyGxFAQoJBxWjPRtQpnfMmKeVwmZnn0dhtRPyGxFAQU4j(Mm9GqMctgsIxlM5Mg6BstRPyGxFAQcGBIlQqOPWKHK41IzUPH(5nTMctgsIxlMPaIYrrXMcsV3humkjU4P2HrU9ZbXzqOvWCrRG5nfd86ttbM4k3Y6yYZkpm30q)zmTMctgsIxlMPaIYrrXMIbEDc333hDjtHBY0dcTcMBfmZumWRpnvVe4o)tS5Mg6pBtRPyGxFAkKf(eMBsBfcnfMmKeVwmZnn030MwtXaV(0uil8PnkrkmDwAkmzijETyMBAOhUyAnfMmKeVwmtbeLJIInfKEVpcx5TRlOB7VJudbsXvswbNBfah4nfd86ttfUYBxxq32FhPm3CtDXoRlDtRPzMP1umWRpnfK8)RuN4MctgsIxdYCtd9MwtHjdjXRfZuar5OOyt1RJjFlqkUsYk4CRGZaVPyGxFAQ23Rpn30ahtRPyGxFAQWvE3KjKfMctgsIxlM5MMM00Akg41NMkCLxIlQqOPWKHK41IzUPzEtRPyGxFAkWNamDb74D3LmfAkmzijETyMBAoJP1umWRpnfK8)7(7BFc3yIu0zkmzijETyMBAoBtRPyGxFAQdDwClo3FFZNvu8(KPWKHK41IzUPPPnTMIbE9PP6pqNG3nFwrr54gczktHjdjXRfZCtdCX0Akg41NMQvxuD6Q8ydjzIBkmzijETyMBAMbVP1umWRpnLpHB9e61Z7U)caAkmzijETyMBAMnZ0Akg41NMIcPEbD7VVL6G6UVcKPiMctgsIxlM5MMz0BAnfd86ttjQ2wjURCtAzaAkmzijETyMBAMbhtRPyGxFAQWVqEpHvUfi5tobOPWKHK41IzUPzwtAAnfMmKeVwmtbeLJIInLZId0htil9PDlWxbZTcAA4xbWaZkWzXb6JjKL(0Uf4RGZTcOh(vamWSc61XKVfifxjzfCUvaCG3umWRpnLa52kp2DjtHeZnnZM30Akg41NMAczHVrcbtaAkmzijETyMBAMDgtRPyGxFAkDcUlhPiMctgsIxlM5MMzNTP1uyYqs8AXmfquokk2unBf4SetFWeaMxob4atgsI3vamWScG079btayE5eGd92vamWSca)lVF4CWeaMxob4qGuCLKvWCRG5H3umWRpnfK8)7URlOZCtZSM20AkmzijETyMcikhffBQMTcCwIPpycaZlNaCGjdjX7kagywbq69(GjamVCcWHERPyGxFAkiuqqrOkpm30mdUyAnfMmKeVwmtbeLJIInvZwbolX0hmbG5LtaoWKHK4DfadmRai9EFWeaMxob4qVDfadmRaW)Y7hohmbG5Ltaoeifxjzfm3kyE4nfd86tt1lbcj))AUPHE4nTMctgsIxlMPaIYrrXMQzRaNLy6dMaW8YjahyYqs8UcGbMvaKEVpycaZlNaCO3UcGbMva4F59dNdMaW8YjahcKIRKScMBfmp8MIbE9PP4eGexWYnGLsZnn0pZ0AkmzijETyMcikhffBQMTcCwIPpycaZlNaCGjdjX7kagywbnBfaP37dMaW8Yjah6TMIbE9PPG4J933UOaHiMBAONEtRPyGxFAQoky5M0wIYnfMmKeVwmZnn0dhtRPyGxFAkMaW8YjanfMmKeVwmZnn03KMwtHjdjXRfZuar5OOytXaVoHBmrQcjRGOvWmtXaV(0uawk3mWRp3YI4MsweFNmfAksLhs0Ctd9ZBAnfMmKeVwmtbeLJIInfd86eUXePkKScMBfmZumWRpnfGLYnd86ZTSiUPKfX3jtHMIF0Ctd9NX0Akg41NMc86PJcIlQq42FhPmfMmKeVwmZnn0F2MwtXaV(0uKq011f0T93rktHjdjXRfZCtd9nTP1umWRpnvROOy5M4IkeAkmzijETyMBUPAfi4PGy30AAMzAnfMmKeVwmtbeLJIInfKEVpcx5TRlOBhg52phcKIRKSco3kaoWdVPyGxFAQWvE76c62HrU9tZnn0BAnfMmKeVwmtbeLJIInfKEVp6sMc9pp0XDyKB)CiqkUsYk4CRa4ap8MIbE9PP6sMc9pp0XDyKB)0CtdCmTMctgsIxlMPaIYrrXMcsV3hY6yYZkp2KPcL3HaP4kjRGZTcGd8WBkg41NMswhtEw5XMmvO8AUPPjnTMctgsIxlMPaIYrrXMQzRaHEI9xCGJ7)u7WvEjdSP0R2w8Akg41NMkCL3UUGUT)oszUPzEtRPWKHK41IzkGOCuuSPCwIPpi(lOcHylkgyYqs8Akg41NMI4VGkeITOWCZn3uNqbP(00qp80d)SzZGJPcZISYdIPAouTVWX7kOjxbmWRpxbYI4KXIMPAfFVKOPo)kaULtCcqkm9vGAIP4Cr78Ran)jKccfRa6HdSRa6HNE4x0w0o)kO59EX7k4S8NWKtFfWqLS8cjJfTZVcAEqI)cCfa3iembizSOTOXaV(KmAfi4PGypkCL3UUGUDyKB)e2QhbP37JWvE76c62HrU9ZHaP4kjNdoWd)Igd86tYOvGGNcI94rn6sMc9pp0XDyKB)e2QhbP37JUKPq)ZdDChg52phcKIRKCo4ap8lAmWRpjJwbcEki2Jh1qwhtEw5XMmvO8cB1JG079HSoM8SYJnzQq5DiqkUsY5Gd8WVOXaV(KmAfi4PGypEuJWvE76c62(7ifSvpQzc9e7V4ah3)P2HR8sgytPxTT4DrJbE9jz0kqWtbXE8Oge)fuHqSffWw9iNLy6dI)cQqi2IIbMmKeVlAlANFfa3AUGaDhVRa8ekOBf4ffUc8jCfWa)fRGISc4tCjzijow0yGxFsIGK)FL6eFr78RGMt2Cd8uqSVcAFV(CfuKvae2FbUcapfe7RamVKXIgd86ts8OgTVxFcB1J61XKVfifxj5CNb(fTZVcAoPJcHERVc((kaWeNmw0yGxFsIh1iCL3nzczXIgd86ts8OgHR8sCrfcx0yGxFsIh1a8jatxWoE3DjtHlAmWRpjXJAaj))U)(2NWnMifDlAmWRpjXJACOZIBX5(7B(SII3Nw0yGxFsIh1O)aDcE38zffLJBiKPw0yGxFsIh1OvxuD6Q8ydjzIVOXaV(KepQHpHB9e61Z7U)caUOXaV(KepQbfs9c62FFl1b1DFfitrw0yGxFsIh1quTTsCx5M0YaCrJbE9jjEuJWVqEpHvUfi5tob4Igd86ts8OgcKBR8y3LmfsGT6roloqFmHS0N2TaFUMgEyGXzXb6JjKL(0Uf4NJE4HbMEDm5BbsXvsohCGFrJbE9jjEuJjKf(gjemb4Igd86ts8Og6eCxosrw0yGxFsIh1as()D31f0bB1JAMZsm9btayE5eGdmzijEHbgi9EFWeaMxob4qVfgya)lVF4CWeaMxob4qGuCLK5Mh(fng41NK4rnGqbbfHQ8a2Qh1mNLy6dMaW8YjahyYqs8cdmq69(GjamVCcWHE7Igd86ts8Og9sGqY)VWw9OM5SetFWeaMxob4atgsIxyGbsV3hmbG5Ltao0BHbgW)Y7hohmbG5LtaoeifxjzU5HFrJbE9jjEudobiXfSCdyPe2Qh1mNLy6dMaW8YjahyYqs8cdmq69(GjamVCcWHElmWa(xE)W5GjamVCcWHaP4kjZnp8lAmWRpjXJAaXh7VVDrbcrGT6rnZzjM(GjamVCcWbMmKeVWatZG079btayE5eGd92fng41NK4rn6OGLBsBjkFrJbE9jjEudMaW8Yjax0o)kO50xbFkPBf8jUcWePOd2vqROEr50Tc6Vu(HjRaFcxbnFsLhsS5VcyGxFUcKfXhlAmWRpjXJAayPCZaV(CllIdBYuyePYdjcB1JyGxNWnMivHKOzlANFf0Cpxbu6sVAL4katKQqcSRaFcxbTI6fLt3kO)s5hMSc8jCf085hB(Rag41NRazr8XIgd86ts8Ogawk3mWRp3YI4WMmfgXpcB1JyGxNWnMivHK5MTOXaV(KepQb41thfexuHWT)osTOXaV(KepQbjeDDDbDB)DKArJbE9jjEuJwrrXYnXfviCrBr78RGMR6sVwboloqFfWaV(Cf0kQxuoDRazr8fng41NKb)yux8eFtMEqiyREeKEVpM4ss8xqn0Bx0yGxFsg8JXJAeUYBxxq32FhPGT6rc9e7V4ah3)P2HR8sgytPxTT4TjG079X9FQD4kVK9fH079X9dNlAmWRpjd(X4rn6sMc3KPhecwaDajUDwCGojAgSvpsGDbsMyij2eWvNLy6JEjWD(N4bMmKeVWaJZsm9HKjtvES7sMcjdmzijEHbgWFcto9rIaXlFXfUVOXaV(Km4hJh1OvuuV4wSChMpHWcOdiXTZId0jrZGT6rndsV3hTII6f3IL7W8jCO3UOXaV(Km4hJh1OxcCN)jg2QhXaVoH777JUKPWnz6bHMlcolAmWRpjd(X4rnoHKwuS93rQfng41NKb)y8OgY6yYZkp2qV0HT6rq69(OvuuV4wSChMpHd92MaUcP37dI)cQqi2IIHElmWaP37dkgLex8u7Wi3(5G4mi0CrZd3x0yGxFsg8JXJAaemzAlRJjpR8a2Qh5SetFaemzQYJnXFb1atgsIxyGbsV3habtM2Y6yYZkpg3pCUOXaV(Km4hJh1qYN4TKjtWcOdiXTZId0jrZGT6rolX0hsMmv5XUlzkKmWKHK4DrJbE9jzWpgpQbqWKPTSoM8SYJfng41NKb)y8OgGjUYTSoM8SYdyREeKEVpi(lOcHylkg6TlAmWRpjd(X4rnatCL7jwCcjoSvpcsV3humkjU4P2HrU9ZbXzqO5IMFrJbE9jzWpgpQbkrkmDwUHKmXHT6rq69(GIrjXfp1omYTFoiodcnx08lAmWRpjd(X4rni(lOcHylkGT6rq69(GIrjXfp1omYTFoiodcnx08lAmWRpjd(X4rnatCLBzDm5zLhWw9ii9EFqXOK4INAhg52pheNbHIMb)Igd86tYGFmEuJUKPWnz6bHGfqhqIBNfhOtIMbB1JCwIPp6La35FIhyYqs8UOXaV(Km4hJh1GONxuu5XIgd86tYGFmEudjFI3sMmblGoGe3oloqNend2Qhj0tS)IdC0kkkwUL8jEZaxN9xqgytPxTT4TjG079rROOy5wYN4ndCD2FbzqCgeAUZSOXaV(Km4hJh1G4VGI4IkeUOXaV(Km4hJh1qYN4TKjtlAmWRpjd(X4rn6sMc3KPhecwaDajUDwCGojAgSvpsGDbsMyijUOXaV(Km4hJh1OZ42fCs66K6Zfng41NKb)y8OgDXt8nz6bHw0yGxFsg8JXJAuaCtCrfcx0yGxFsg8JXJAaM4k3Y6yYZkpGT6rq69(GIrjXfp1omYTFoiodcnx08lAmWRpjd(X4rn6La35FIHT6rmWRt4(((OlzkCtMEqO5MTOXaV(Km4hJh1azHpH5M0wHWfng41NKb)y8Ogil8PnkrkmDwUOXaV(Km4hJh1iCL3UUGUT)osbB1JG079r4kVDDbDB)DKAiqkUsY5Gd8lAlANFfOQ8qIRaNfhOVcyGxFUcAf1lkNUvGSi(Igd86tYGu5HeJAff1lUfl3H5tiSvpQzq69(OvuuV4wSChMpHd92fng41NKbPYdjgpQr4kVDDbDB)DKc2Qhj0tS)IdCC)NAhUYlzGnLE12I3MasV3h3)P2HR8s2xesV3h3pCUOXaV(KmivEiX4rn6sMc3KPhec2Qh1mVaHQ8yrJbE9jzqQ8qIXJACcjTOy7VJulAmWRpjdsLhsmEuJU4j(Mm9GqWw9ii9EFmXLK4VGAO3UOXaV(KmivEiX4rnqw4tyUjTviCrJbE9jzqQ8qIXJA0zC7cojDDs95Igd86tYGu5HeJh1qwhtEw5Xg6LoSvpcsV3he)fuHqSffd92fng41NKbPYdjgpQbkrkmDwUHKmXHT6rq69(GIrjXfp1omYTFoiodcnx08lAmWRpjdsLhsmEudWex5EIfNqIdB1JG079bfJsIlEQDyKB)CqCgeAUO5x0yGxFsgKkpKy8OgY6yYZkp2qV0HT6rq69(GIrjXfp1omYTFoiodcfnd(fng41NKbPYdjgpQHKpXBjtMGT6rq69(y699eN3HElmWaxf6j2FXboAfffl3s(eVzGRZ(lidSP0R2w82eq69(OvuuSCl5t8MbUo7VGmiodcn3zG7lAmWRpjdsLhsmEudI)ckIlQq4Igd86tYGu5HeJh1G4VGkeITOa2QhbP37dkgLex8u7Wi3(5G4mi0CrZVOXaV(KmivEiX4rnK8jElzY0Igd86tYGu5HeJh1aiyY0wwhtEw5XIgd86tYGu5HeJh1OlzkCtMEqiyb0bK42zXb6KOzWw9ib2fizIHK4Igd86tYGu5HeJh1OlEIVjtpi0Igd86tYGu5HeJh1Oa4M4IkeUOXaV(KmivEiX4rni65ffvESOXaV(KmivEiX4rn6La35FIHT6rmWRt4(((OlzkCtMEqOfng41NKbPYdjgpQHSoM8SYJn0lDyREeKEVpOyusCXtTdJC7NdIZGqZfn)Igd86tYGu5HeJh1azHpTrjsHPZYfng41NKbPYdjgpQr4kVDDbDB)DKc2QhbP37JWvE76c62(7i1qGuCLKZbh4nfR7tVWuQI6SyU5Mb]] )

end
