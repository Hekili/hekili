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


    spec:RegisterPack( "Enhancement", 20201123.1, [[de0YTaqiPs5rQOQnbuYNKkv1OakvNsQe6vcvZciDlPsLYUu4xsfddP0XuQSmKINbumnPs01urzBkvLVPuv14KkPohqPmpvu5EczFkv5GsLQ0cfkpuPQIlkvcoPuPIvIuDtPsL0ojv(PuPs1sLkvXtjzQKQ2lL)QKblWHrTyapg0KvPldTzP8zvy0kLtl51cQzt0TrYUf9BvnCPQJlvswoHNJy6uDDsz7QiFxqgVuPsCEGQ1RuvP5de7xrB7m9M6YoA6OHwAOD3oAaZy3(ODhnDPPCW7rt1ZWW8bAQKPqt1fYnoHifMUP6zWLpFn9MI8AciAkvrTFmfGwj9UtAaM6YoA6OHwAOD3oAaZy3(ODhn0ykspcnD0SpWyQT6EX0am1fjqtD(zqxi34eIuy6Za1gtX5K(5Nb6(tifakMb0agqNb0qln0oPpPF(zq379I3zW(5pHjN(mGbkz5fsgt6NFg09Ge)f4mOlqiycrYWuYI4etVPivEirtVPBNP3uyYas8AXmfuuokk2uDBgaO1AJErr9IBXYvi(eo06nfd96tt1lkQxClwUcXNqZnD0y6nfMmGeVwmtbfLJIInLqlX2loWX9FQvOkVKb2vAvFpENbG1maqR1g3)PwHQ8swxeqR1g3puAkg61NMkuL3MMa8L)oszUPdmMEtHjdiXRfZuqr5OOyt1TzGxWWvEykg61NMQjzkCr2EyyZnDDPP3um0Rpn1jK0JIL)oszkmzajETyMB6oZ0BkmzajETyMckkhffBkaTwBSXLK4VGAO1Bkg61NMQjEIViBpmS5MU9z6nfd96ttHSW3WCr6RWOPWKbK41IzUPB)n9MIHE9PPAmUCbNKMgP(0uyYas8AXm3011MEtHjdiXRfZuqr5OOytbO1AdI)cQWi2JIHwVPyOxFAkzDS5zLhlGx6MB6aBMEtHjdiXRfZuqr5OOytbO1AdkgLex8uRqi3)5G4mm8myVOzWzMIHE9PPqjsHPZYfGKjU5MUD0A6nfMmGeVwmtbfLJIInfGwRnOyusCXtTcHC)NdIZWWZG9IMbNzkg61NMcUXvU2yXjK4MB62TZ0BkmzajETyMckkhffBkaTwBqXOK4INAfc5(pheNHHNbrZGD0Akg61NMswhBEw5Xc4LU5MUD0y6nfMmGeVwmtbfLJIInfGwRn2EFTX5DO1pdabKzayFgi0sS9IdC0lkkwUK8jEXqxJ9xqgyxPv994DgawZaaTwB0lkkwUK8jEXqxJ9xqgeNHHNb7nd23mOlAkg61NMsYN4LKjBMB62bgtVPyOxFAkI)ckIlQWOPWKbK41IzUPBxxA6nfMmGeVwmtbfLJIInfGwRnOyusCXtTcHC)NdIZWWZG9IMbNzkg61NMI4VGkmI9OWCt3UZm9MIHE9PPK8jEjzYMPWKbK41IzUPB3(m9MIHE9PPGcMSTK1XMNvEykmzajETyMB62T)MEtHjdiXRfZum0RpnvtYu4IS9WWMckkhffBkb2eizJbKOPGGdL4YzXb6et3oZnD76AtVPyOxFAQM4j(IS9WWMctgqIxlM5MUDGntVPyOxFAQcIlIlQWOPWKbK41IzUPJgAn9MIHE9PPiA5ffvEykmzajETyMB6OzNP3uyYas8AXmfuuokk2um0Rt46((OjzkCr2EyytXqV(0uTsGR8pXMB6OHgtVPWKbK41IzkOOCuuSPa0ATbfJsIlEQviK7)CqCggEgSx0m4mtXqV(0uY6yZZkpwaV0n30rdym9MIHE9PPqw4BluIuy6S0uyYas8AXm30rtxA6nfMmGeVwmtbfLJIInfGwRncv5TPjaF5VJudbsXvsMbNBgagAnfd96ttfQYBtta(YFhPm3CtXpA6nD7m9MctgqIxlMPGIYrrXMcqR1gBCjj(lOgA9MIHE9PPAIN4lY2ddBUPJgtVPWKbK41IzkOOCuuSPeAj2EXboU)tTcv5LmWUsR67X7maSMbaAT24(p1kuLxY6IaAT24(HstXqV(0uHQ820eGV83rkZnDGX0BkmzajETyMIHE9PPAsMcxKThg2uqr5OOytjWMajBmGeNbG1maSpdCwIPpALax5FIhyYas8odabKzGZsm9HKjBvESAsMcjdmzajENbGaYma(NWKtFKiu8YxCNbDrtbbhkXLZId0jMUDMB66stVPWKbK41Izkg61NMQxuuV4wSCfIpHMckkhffBQUnda0ATrVOOEXTy5keFchA9MccouIlNfhOtmD7m30DMP3uyYas8AXmfuuokk2um0Rt46((OjzkCr2Ey4zWErZaWykg61NMQvcCL)j2Ct3(m9MIHE9PPoHKEuS83rktHjdiXRfZCt3(B6nfMmGeVwmtbfLJIInfGwRn6ff1lUflxH4t4qRFgawZaW(maqR1ge)fuHrShfdT(zaiGmda0ATbfJsIlEQviK7)CqCggEgSx0m4Szqx0um0RpnLSo28SYJfWlDZnDDTP3uyYas8AXmfuuokk2uolX0hqbt2Q8yr8xqnWKbK4DgaciZaaTwBafmzBjRJnpR8yC)qPPyOxFAkOGjBlzDS5zLhMB6aBMEtHjdiXRfZum0RpnLKpXljt2mfuuokk2uolX0hsMSv5XQjzkKmWKbK41uqWHsC5S4aDIPBN5MUD0A6nfd96ttbfmzBjRJnpR8WuyYas8AXm30TBNP3uyYas8AXmfuuokk2uaAT2G4VGkmI9OyO1Bkg61NMcUXvUK1XMNvEyUPBhnMEtHjdiXRfZuqr5OOytbO1AdkgLex8uRqi3)5G4mm8myVOzWzMIHE9PPGBCLRnwCcjU5MUDGX0BkmzajETyMckkhffBkaTwBqXOK4INAfc5(pheNHHNb7fndoZum0RpnfkrkmDwUaKmXn30TRln9MctgqIxlMPGIYrrXMcqR1gumkjU4PwHqU)ZbXzy4zWErZGZmfd96ttr8xqfgXEuyUPB3zMEtHjdiXRfZuqr5OOytbO1AdkgLex8uRqi3)5G4mm8miAgSJwtXqV(0uWnUYLSo28SYdZnD72NP3uyYas8AXmfd96tt1KmfUiBpmSPGIYrrXMYzjM(OvcCL)jEGjdiXRPGGdL4YzXb6et3oZnD72FtVPyOxFAkIwErrLhMctgqIxlM5MUDDTP3uyYas8AXmfd96ttj5t8sYKntbfLJIInLqlX2loWrVOOy5sYN4fdDn2FbzGDLw13J3zaynda0ATrVOOy5sYN4fdDn2FbzqCggEgS3myFMccouIlNfhOtmD7m30TdSz6nfd96ttr8xqrCrfgnfMmGeVwmZnD0qRP3um0RpnLKpXljt2mfMmGeVwmZnD0SZ0BkmzajETyMIHE9PPAsMcxKThg2uqr5OOytjWMajBmGenfeCOexoloqNy62zUPJgAm9MIHE9PPAmUCbNKMgP(0uyYas8AXm30rdym9MIHE9PPAIN4lY2ddBkmzajETyMB6OPln9MIHE9PPkiUiUOcJMctgqIxlM5MoAoZ0BkmzajETyMckkhffBkaTwBqXOK4INAfc5(pheNHHNb7fndoZum0RpnfCJRCjRJnpR8WCthn7Z0BkmzajETyMckkhffBkg61jCDFF0KmfUiBpm8myVzWotXqV(0uTsGR8pXMB6Oz)n9MIHE9PPqw4ByUi9vy0uyYas8AXm30rtxB6nfd96ttHSW3wOePW0zPPWKbK41IzUPJgWMP3uyYas8AXmfuuokk2uaAT2iuL3MMa8L)osneifxjzgCUzayO1um0RpnvOkVnnb4l)DKYCZn1fBSM0n9MUDMEtXqV(0uaY)VsnIBkmzajEnaZnD0y6nfMmGeVwmtbfLJIInvRo28LaP4kjZGZnd2hTMIHE9PP6FV(0Cthym9MIHE9PPcv5Dr2qwykmzajETyMB66stVPyOxFAQqvEjUOcJMctgqIxlM5MUZm9MIHE9PPGFcX0fSJ3vtYuOPWKbK41IzUPBFMEtXqV(0uaY)VRVT8nCHjsbUPWKbK41IzUPB)n9MIHE9PPo0yXT4C9TfVFrX7BMctgqIxlM5MUU20Bkg61NMQ9qncEx8(ffLJlaKPmfMmGeVwmZnDGntVPyOxFAQEnr1aVYJfGKjUPWKbK41IzUPBhTMEtXqV(0u(gU0sGxlVR2lGOPWKbK41IzUPB3otVPyOxFAkkK6fGV(2sQbR76kqMIykmzajETyMB62rJP3um0RpnLO67L4QYfPNHOPWKbK41IzUPBhym9MIHE9PPc9c59ew5sGKp5eIMctgqIxlM5MUDDPP3uyYas8AXmfuuokk2uoloqFSHS03w9qFgS3mORPDgaciZaNfhOp2qw6BREOpdo3mGgANbGaYmOvhB(sGuCLKzW5MbGHwtXqV(0ucK7R8y1Kmfsm30T7mtVPyOxFAQnKf(cjemHOPWKbK41IzUPB3(m9MIHE9PP0i4QCKIykmzajETyMB62T)MEtHjdiXRfZuqr5OOyt1TzGZsm9btGyE5eIdmzajENbGaYmaqR1gmbI5Ltio06NbGaYma(V8(HYbtGyE5eIdbsXvsMb7ndoJwtXqV(0uaY)VRMMaCZnD76AtVPWKbK41IzkOOCuuSP62mWzjM(GjqmVCcXbMmGeVZaqazgaO1AdMaX8YjehA9MIHE9PPaqbbfHR8WCt3oWMP3uyYas8AXmfuuokk2uDBg4SetFWeiMxoH4atgqI3zaiGmda0ATbtGyE5eIdT(zaiGmdG)lVFOCWeiMxoH4qGuCLKzWEZGZO1um0RpnvReiG8)R5MoAO10BkmzajETyMckkhffBQUndCwIPpyceZlNqCGjdiX7maeqMbaAT2GjqmVCcXHw)maeqMbW)L3puoyceZlNqCiqkUsYmyVzWz0Akg61NMItisCblxqwkn30rZotVPWKbK41IzkOOCuuSP62mWzjM(GjqmVCcXbMmGeVZaqazg0TzaGwRnyceZlNqCO1Bkg61NMcGpwFB5IcgMyUPJgAm9MIHE9PPAOGLlsFjk3uyYas8AXm30rdym9MIHE9PPyceZlNq0uyYas8AXm30rtxA6nfMmGeVwmtbfLJIInfd96eUWePkKmdIMb7mfd96ttbzPCXqV(CjlIBkzr8vYuOPivEirZnD0CMP3uyYas8AXmfuuokk2um0Rt4ctKQqYmyVzWotXqV(0uqwkxm0RpxYI4MsweFLmfAk(rZnD0SptVPyOxFAk4RLokiUOcJl)DKYuyYas8AXm30rZ(B6nfd96ttrcdEtta(YFhPmfMmGeVwmZnD001MEtXqV(0u9IIILlIlQWOPWKbK41IzU5MQxGWNcGDtVPBNP3uyYas8AXmfuuokk2uaAT2iuL3MMa8viK7)CiqkUsYm4CZaWqlTMIHE9PPcv5TPjaFfc5(pn30rJP3uyYas8AXmfuuokk2uaAT2Ojzk0)8qdxHqU)ZHaP4kjZGZndadT0Akg61NMQjzk0)8qdxHqU)tZnDGX0BkmzajETyMckkhffBkaTwBiRJnpR8yr2kuEhcKIRKmdo3mam0sRPyOxFAkzDS5zLhlYwHYR5MUU00BkmzajETyMckkhffBQUndeAj2EXboU)tTcv5LmWUsR67X7maSMbaAT2iuL3MMa8L)osnUFO0um0RpnvOkVnnb4l)DKYCt3zMEtHjdiXRfZuqr5OOyt5SetFq8xqfgXEumWKbK41um0RpnfXFbvye7rH5MBUPoHcs9PPJgAPH2D7ObmMkelYkpiMQ7q1)chVZGUCgWqV(CgilItgt6MQx8TsIM68ZGUqUXjePW0NbQnMIZj9Zpd09NqkaumdObmGodOHwAODsFs)8ZGU37fVZG9ZFcto9zaduYYlKmM0p)mO7bj(lWzqxGqWeIKXK(Kod96tYOxGWNcG9OqvEBAcWxHqU)tqRweGwRncv5TPjaFfc5(phcKIRKCoWqlTt6m0RpjJEbcFka2Jh1Pjzk0)8qdxHqU)tqRweGwRnAsMc9pp0WviK7)CiqkUsY5adT0oPZqV(Km6fi8PaypEuhzDS5zLhlYwHYlOvlcqR1gY6yZZkpwKTcL3HaP4kjNdm0s7Kod96tYOxGWNcG94rDcv5TPjaF5VJuGwTOUj0sS9IdCC)NAfQYlzGDLw13JxWcqR1gHQ820eGV83rQX9dLt6m0RpjJEbcFka2Jh1H4VGkmI9Oa0Qf5SetFq8xqfgXEumWKbK4DsFs)8ZGUq3feQ54DgGNqb4ZaVOWzGVHZag6VyguKzaFIljdiXXKod96tseG8)RuJ4t6NFg0DYUBWNcG9zq)71NZGImdaW2lWza8PayFgG5LmM0zOxFsIh1P)96tqRwuRo28LaP4kjNBF0oPF(zq3jDui069zW3MbqM4KXKod96ts8OoHQ8UiBilM0zOxFsIh1juLxIlQW4Kod96ts8OoWpHy6c2X7QjzkCsNHE9jjEuha5)313w(gUWePaFsNHE9jjEuNdnwCloxFBX7xu8(2Kod96ts8OoThQrW7I3VOOCCbGm1Kod96ts8Oo9AIQbELhlajt8jDg61NK4rD8nCPLaVwExTxaXjDg61NK4rDOqQxa(6BlPgSURRazkYKod96ts8OoIQVxIRkxKEgIt6m0RpjXJ6e6fY7jSYLajFYjeN0zOxFsIh1rGCFLhRMKPqcOvlYzXb6JnKL(2Qh67110ccioloqFSHS03w9q)C0qliG0QJnFjqkUsY5adTt6m0RpjXJ6SHSWxiHGjeN0zOxFsIh1rJGRYrkYKod96ts8OoaY)VRMMaCqRwu3CwIPpyceZlNqCGjdiXliGaO1AdMaX8YjehA9Gac8F59dLdMaX8YjehcKIRKS3z0oPZqV(KepQdakiOiCLhGwTOU5SetFWeiMxoH4atgqIxqabqR1gmbI5Ltio06N0zOxFsIh1Pvceq()f0Qf1nNLy6dMaX8YjehyYas8cciaAT2GjqmVCcXHwpiGa)xE)q5GjqmVCcXHaP4kj7DgTt6m0RpjXJ6WjejUGLlilLGwTOU5SetFWeiMxoH4atgqIxqabqR1gmbI5Ltio06bbe4)Y7hkhmbI5LtioeifxjzVZODsNHE9jjEuha(y9TLlkyycOvlQBolX0hmbI5LtioWKbK4feq6gGwRnyceZlNqCO1pPZqV(KepQtdfSCr6lr5t6m0RpjXJ6WeiMxoH4K(5NbDN2m4tj4ZGpXzaMif4God6f1lkh8zq7LYpezg4B4mO7tQ8qID)zad96ZzGSi(ysNHE9jjEuhilLlg61NlzrCqtMcJivEirqRwed96eUWePkKeTBs)8ZGU75mGst6vVeNbyIufsaDg4B4mOxuVOCWNbTxk)qKzGVHZGUp)y3FgWqV(CgilIpM0zOxFsIh1bYs5IHE95sweh0KPWi(rqRwed96eUWePkKS3UjDg61NK4rDGVw6OG4IkmU83rQjDg61NK4rDiHbVPjaF5VJut6m0RpjXJ60lkkwUiUOcJt6t6NFg0Dvt61mWzXb6Zag61NZGEr9IYbFgilIpPZqV(Km4hJAIN4lY2dddA1Ia0ATXgxsI)cQHw)Kod96tYGFmEuNqvEBAcWx(7ifOvlsOLy7fh44(p1kuLxYa7kTQVhVGfGwRnU)tTcv5LSUiGwRnUFOCsNHE9jzWpgpQttYu4IS9WWGcbhkXLZId0jr7aTArcSjqYgdirWcS7SetF0kbUY)epWKbK4feqCwIPpKmzRYJvtYuizGjdiXliGa)tyYPpsekE5lUDXjDg61NKb)y8Oo9II6f3ILRq8jeui4qjUCwCGojAhOvlQBaAT2OxuuV4wSCfIpHdT(jDg61NKb)y8OoTsGR8pXGwTig61jCDFF0KmfUiBpm8ErGzsNHE9jzWpgpQZjK0JIL)osnPZqV(Km4hJh1rwhBEw5Xc4LoOvlcqR1g9II6f3ILRq8jCO1dwGDaTwBq8xqfgXEum06bbeaTwBqXOK4INAfc5(pheNHH3l6SU4Kod96tYGFmEuhOGjBlzDS5zLhGwTiNLy6dOGjBvESi(lOgyYas8cciaAT2akyY2swhBEw5X4(HYjDg61NKb)y8Oos(eVKmzdui4qjUCwCGojAhOvlYzjM(qYKTkpwnjtHKbMmGeVt6m0Rpjd(X4rDGcMSTK1XMNvEmPZqV(Km4hJh1bUXvUK1XMNvEaA1Ia0ATbXFbvye7rXqRFsNHE9jzWpgpQdCJRCTXItiXbTAraAT2GIrjXfp1keY9FoioddVx0zt6m0Rpjd(X4rDqjsHPZYfGKjoOvlcqR1gumkjU4PwHqU)ZbXzy49IoBsNHE9jzWpgpQdXFbvye7rbOvlcqR1gumkjU4PwHqU)ZbXzy49IoBsNHE9jzWpgpQdCJRCjRJnpR8a0QfbO1AdkgLex8uRqi3)5G4mmC0oAN0zOxFsg8JXJ60KmfUiBpmmOqWHsC5S4aDs0oqRwKZsm9rRe4k)t8atgqI3jDg61NKb)y8OoeT8IIkpM0zOxFsg8JXJ6i5t8sYKnqHGdL4YzXb6KODGwTiHwITxCGJErrXYLKpXlg6AS)cYa7kTQVhVGfGwRn6ffflxs(eVyORX(lidIZWW7TVjDg61NKb)y8Ooe)fuexuHXjDg61NKb)y8Oos(eVKmzBsNHE9jzWpgpQttYu4IS9WWGcbhkXLZId0jr7aTArcSjqYgdiXjDg61NKb)y8OongxUGtstJuFoPZqV(Km4hJh1PjEIViBpm8Kod96tYGFmEuNcIlIlQW4Kod96tYGFmEuh4gx5swhBEw5bOvlcqR1gumkjU4PwHqU)ZbXzy49IoBsNHE9jzWpgpQtRe4k)tmOvlIHEDcx33hnjtHlY2ddV3UjDg61NKb)y8Ooil8nmxK(kmoPZqV(Km4hJh1bzHVTqjsHPZYjDg61NKb)y8OoHQ820eGV83rkqRweGwRncv5TPjaF5VJudbsXvsohyODsFs)8ZavLhsCg4S4a9zad96ZzqVOEr5GpdKfXN0zOxFsgKkpKyuVOOEXTy5keFcbTArDdqR1g9II6f3ILRq8jCO1pPZqV(KmivEiX4rDcv5TPjaF5VJuGwTiHwITxCGJ7)uRqvEjdSR0Q(E8cwaAT24(p1kuLxY6IaAT24(HYjDg61NKbPYdjgpQttYu4IS9WWGwTOU5fmCLht6m0RpjdsLhsmEuNtiPhfl)DKAsNHE9jzqQ8qIXJ60epXxKThgg0QfbO1AJnUKe)fudT(jDg61NKbPYdjgpQdYcFdZfPVcJt6m0RpjdsLhsmEuNgJlxWjPPrQpN0zOxFsgKkpKy8OoY6yZZkpwaV0bTAraAT2G4VGkmI9OyO1pPZqV(KmivEiX4rDqjsHPZYfGKjoOvlcqR1gumkjU4PwHqU)ZbXzy49IoBsNHE9jzqQ8qIXJ6a34kxBS4esCqRweGwRnOyusCXtTcHC)NdIZWW7fD2Kod96tYGu5HeJh1rwhBEw5Xc4LoOvlcqR1gumkjU4PwHqU)ZbXzy4OD0oPZqV(KmivEiX4rDK8jEjzYgOvlcqR1gBVV248o06bbeWUqlX2loWrVOOy5sYN4fdDn2FbzGDLw13JxWcqR1g9IIILljFIxm01y)fKbXzy492xxCsNHE9jzqQ8qIXJ6q8xqrCrfgN0zOxFsgKkpKy8Ooe)fuHrShfGwTiaTwBqXOK4INAfc5(pheNHH3l6SjDg61NKbPYdjgpQJKpXljt2M0zOxFsgKkpKy8Ooqbt2wY6yZZkpM0zOxFsgKkpKy8OonjtHlY2dddkeCOexoloqNeTd0QfjWMajBmGeN0zOxFsgKkpKy8OonXt8fz7HHN0zOxFsgKkpKy8OofexexuHXjDg61NKbPYdjgpQdrlVOOYJjDg61NKbPYdjgpQtRe4k)tmOvlIHEDcx33hnjtHlY2ddpPZqV(KmivEiX4rDK1XMNvESaEPdA1Ia0ATbfJsIlEQviK7)CqCggEVOZM0zOxFsgKkpKy8Ooil8TfkrkmDwoPZqV(KmivEiX4rDcv5TPjaF5VJuGwTiaTwBeQYBtta(YFhPgcKIRKCoWqRPynF7fMsvu7hZn3m]] )

end
