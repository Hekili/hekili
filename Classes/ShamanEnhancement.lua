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
            copy = "doom_winds_debuff",
            generate = function( t )
                local name, _, count, debuffType, duration, expirationTime = GetPlayerAuraBySpellID( 335904 )
    
                if name then
                    t.count = count > 0 and count or 1
                    t.expires = expirationTime > 0 and expirationTime or query_time + 5
                    t.applied = expirationTime > 0 and ( expirationTime - duration ) or query_time
                    t.caster = "player"
                    return
                end
    
                t.count = 0
                t.expires = 0
                t.applied = 0
                t.caster = "nobody"
            end,
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
            id = 974,
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


    spec:RegisterPack( "Enhancement", 20201205, [[da0JQaqiPe9iGu2eqsFsvsQrbKQofqQ8kf0SuL6wQsIyxs1VuGHrICmfXYir9mGQMMucDnPK2gqIVPkPACav05aQW8aQ09KI9PkXbvLK0cLs9qvjftuvsIlQkP0jvLewjjCtvjrzNcYpvLevpLutvqTxk)vPgSahg1Ib8yetwvDzOnl0NvuJwvCAjVMKA2eUnr2TOFRYWvOJlLGLJ0ZbnDQUorTDfPVtsgVQKiDEGY8bI9RKTjwyt)zhTqkRKYknrzLATprzLuU1jM2bBen9ituZZOPtwcn9RnF4KGsy6MEKbtC83cBA4jtjOP1L0RX0aYLWFfPby6p7OfszLuwPjkRuR9jkRKYkdkMgoIelKYGc4n9t9)yAaM(JqIPbTvWRnF4KGsy6Ra9dlX5sbOTcEvqckbG0vqRVxbkRKYkTuSuaARGx1)h)RGxZnfto9vaduIYle2nTOGo0cBAyLZc0cBHMyHnnMmGa)wBttOLJ0InDlxbaYXyFKwsh9xSyRINID5rtZeVU00J0s6O)IfBv8u0ClKYwytJjdiWV120eA5iTyttLtmE0zS)VtARQYpSJTGCnoI)vaOUcaKJX()oPTQk)W9hbKJX()uLMMjEDPPvv5pktbB7NJsMBHaVf20yYac8BTnnHwosl20TCf4frDLZMMjEDPPJcwc3WNJO2ClulAHnnt86stpfHJiD7NJsMgtgqGFRT5wOwTWMgtgqGFRTPj0YrAXMgqog7pCjG(rL6YJMMjEDPPJ0d6B4ZruBUfcuSWMMjEDPPrM6pyUHJLA00yYac8BTn3c96wytZeVU00rg3oLtyugwxAAmzab(T2MBHaNwytJjdiWV120eA5iTytdihJDOFuj1ioI0U8OPzIxxAArn)4zLZBGt4MBHahwytJjdiWV120eA5iTytdihJDjgfqNEsBvipEzh6mr9k4LMvqRMMjEDPPrbkHPZInGGHU5wOjkzHnnMmGa)wBttOLJ0InnGCm2LyuaD6jTvH84LDOZe1RGxAwbTAAM41LMM8WvUFy6ue6MBHMmXcBAmzab(T2MMqlhPfBAa5ySlXOa60tARc5Xl7qNjQxbnRGjkzAM41LMwuZpEw58g4eU5wOjkBHnnMmGa)wBttOLJ0InnGCm2FoF)W5VlpUcabKvaOFfqLtmE0zSpsljwSf8uEZexM9Jc7ylixJJ4FfaQRaa5ySpsljwSf8uEZexM9Jc7qNjQxbVScaLvaOZ0mXRlnTGNYBbdFm3cnb8wytZeVU00q)OsqNwQrtJjdiWV12Cl0Kw0cBAmzab(T2MMqlhPfBAa5ySlXOa60tARc5Xl7qNjQxbV0ScA10mXRlnn0pQKAehrQ5wOjTAHnnt86stl4P8wWWhtJjdiWV12Cl0eqXcBAM41LMMqz4ZwuZpEw5SPXKbe43ABUfAYRBHnnMmGa)wBtZeVU00rblHB4ZruBAcTCKwSPPyKIWhgqGMMagrGBNPZOdTqtm3cnbCAHnnt86sthPh03WNJO20yYac8BTn3cnbCyHnnt86stxeCdDAPgnnMmGa)wBZTqkRKf20mXRlnnuo)iTYztJjdiWV12ClKYtSWMgtgqGFRTPj0YrAXMMjEnf3)Z7rblHB4ZruBAM41LMowuCN3u2ClKYkBHnnMmGa)wBttOLJ0InnGCm2LyuaD6jTvH84LDOZe1RGxAwbTAAM41LMwuZpEw58g4eU5wiLbVf20mXRlnnYu)zJcuctNfMgtgqGFRT5wiLBrlSPXKbe43ABAcTCKwSPbKJXUQk)rzkyB)CuQtrjUs4kaCxbGxjtZeVU00QQ8hLPGT9ZrjZn308Hwyl0elSPXKbe43ABAcTCKwSPHNSaOYFFMEtXDLtR5JYED5kaeqwbWtwau5Vhlu83xCdioi8KGMMjEDPPJmUDkNWOmSU0ClKYwytJjdiWV120eA5iTytdihJ9hUeq)OsD5rtZeVU00r6b9n85iQn3cbElSPXKbe43ABAcTCKwSPPYjgp6m2)3jTvv5h2XwqUghX)kauxbaYXy)FN0wvLF4(JaYXy)FQstZeVU00QQ8hLPGT9ZrjZTqTOf20yYac8BTnnt86sthfSeUHphrTPj0YrAXMMIrkcFyabUca1vaOFf4SatVhlkUZBk3XKbe4FfaciRaNfy6DbdFQCEhfSec7yYac8VcabKva5MIjNEprc9eh9VcaDMMagrGBNPZOdTqtm3c1Qf20yYac8BTnnt86stpslPJ(lwSvXtrttOLJ0InDlxbaYXyFKwsh9xSyRINID5rttaJiWTZ0z0HwOjMBHaflSPXKbe43ABAcTCKwSPzIxtX9)8EuWs4g(Ce1RGxAwbG30mXRlnDSO4oVPS5wOx3cBAM41LMEkchr62phLmnMmGa)wBZTqGtlSPXKbe43ABAcTCKwSPbKJX(iTKo6VyXwfpf7YJRaqDfa6xbaYXyh6hvsnIJiTlpUcabKvaGCm2LyuaD6jTvH84LDOZe1RGxAwbTUcaDMMjEDPPf18JNvoVboHBUfcCyHnnMmGa)wBttOLJ0InTZcm9oHYWNkN3q)OsDmzab(xbGaYkaqog7ekdF2IA(XZkN7)tvAAM41LMMqz4ZwuZpEw5S5wOjkzHnnMmGa)wBtZeVU00cEkVfm8X0eA5iTyt7SatVly4tLZ7OGLqyhtgqGFttaJiWTZ0z0HwOjMBHMmXcBAM41LMMqz4ZwuZpEw5SPXKbe43ABUfAIYwytJjdiWV120eA5iTytdihJDOFuj1ioI0U8OPzIxxAAYdx5wuZpEw5S5wOjG3cBAmzab(T2MMqlhPfBAa5ySlXOa60tARc5Xl7qNjQxbV0ScA10mXRlnn5HRC)W0Pi0n3cnPfTWMgtgqGFRTPj0YrAXMgqog7smkGo9K2QqE8Yo0zI6vWlnRGwnnt86stJcuctNfBabdDZTqtA1cBAmzab(T2MMqlhPfBAa5ySlXOa60tARc5Xl7qNjQxbV0ScA10mXRlnn0pQKAehrQ5wOjGIf20yYac8BTnnHwosl20aYXyxIrb0PN0wfYJx2HotuVcAwbtuY0mXRlnn5HRClQ5hpRC2Cl0Kx3cBAmzab(T2MMjEDPPJcwc3WNJO20eA5iTyt7SatVhlkUZBk3XKbe430eWicC7mDgDOfAI5wOjGtlSPzIxxAAOC(rALZMgtgqGFRT5wOjGdlSPXKbe43ABAM41LMwWt5TGHpMMqlhPfBAQCIXJoJ9rAjXITGNYBM4YSFuyhBb5ACe)RaqDfaihJ9rAjXITGNYBM4YSFuyh6mr9k4LvaOyAcyebUDMoJo0cnXClKYkzHnnt86std9JkbDAPgnnMmGa)wBZTqkpXcBAM41LMwWt5TGHpMgtgqGFRT5wiLv2cBAmzab(T2MMjEDPPJcwc3WNJO20eA5iTyttXifHpmGannbmIa3otNrhAHMyUfszWBHnnt86sthzC7uoHrzyDPPXKbe43ABUfs5w0cBAM41LMospOVHphrTPXKbe43ABUfs5wTWMMjEDPPlcUHoTuJMgtgqGFRT5wiLbflSPXKbe43ABAcTCKwSPbKJXUeJcOtpPTkKhVSdDMOEf8sZkOvtZeVU00KhUYTOMF8SYzZTqk)6wytJjdiWV120eA5iTytZeVMI7)59OGLWn85iQxbVScMyAM41LMowuCN3u2ClKYGtlSPzIxxAAKP(dMB4yPgnnMmGa)wBZTqkdoSWMMjEDPPrM6pBuGsy6SW0yYac8BTn3cbELSWMgtgqGFRTPj0YrAXMgqog7QQ8hLPGT9ZrPofL4kHRaWDfaELmnt86stRQYFuMc22phLm3Ct)XillClSfAIf20mXRlnnG4UVqg6MgtgqGFdWClKYwytJjdiWV120eA5iTythR5hFtrjUs4kaCxbGIsMMjEDPPhpVU0Cle4TWMMjEDPPvv5FdFqMAAmzab(T2MBHArlSPzIxxAAvv(HoTuJMgtgqGFRT5wOwTWMMjEDPPLH4UCucAAmzab(T2MBHaflSPXKbe43ABAcTCKwSPB5kWzbMENHem)CsWoMmGa)RaqazfaihJDgsW8Zjb7YJRaqazfqUt8pvzNHem)CsWofL4kHRGxwbTQKPzIxxAAaXD)DuMcM5wOx3cBAmzab(T2MMqlhPfB6wUcCwGP3zibZpNeSJjdiW)kaeqwbaYXyNHem)CsWU8OPzIxxAAaKcrQ6kNn3cboTWMgtgqGFRTPj0YrAXMULRaNfy6DgsW8Zjb7yYac8VcabKvaGCm2zibZpNeSlpUcabKva5oX)uLDgsW8Zjb7uuIReUcEzf0QsMMjEDPPJffbe39n3cboSWMgtgqGFRTPj0YrAXMULRaNfy6DgsW8Zjb7yYac8VcabKvaGCm2zibZpNeSlpUcabKva5oX)uLDgsW8Zjb7uuIReUcEzf0QsMMjEDPP5KGqNYInHfcZTqtuYcBAmzab(T2MMqlhPfB6wUcCwGP3zibZpNeSJjdiW)kaeqwbTCfaihJDgsW8Zjb7YJMMjEDPPb459f3oTiQHMBHMmXcBAM41LMoIuwSHJfTCtJjdiWV12Cl0eLTWMMjEDPPzibZpNe00yYac8BTn3cnb8wytJjdiWV120eA5iTytZeVMIBmrPcHRGMvWetZeVU00ewi2mXRl3Ic6MwuqFNSeAAyLZc0Cl0Kw0cBAmzab(T2MMqlhPfBAM41uCJjkviCf8YkyIPzIxxAAcleBM41LBrbDtlkOVtwcnnFO5wOjTAHnnt86stto50rk0PLAC7NJsMgtgqGFRT5wOjGIf20mXRlnnunyrzkyB)CuY0yYac8BTn3cn51TWMMjEDPPhPLel2qNwQrtJjdiWV12CZn9ifjNea7wyl0elSPXKbe43ABAcTCKwSPbKJXUQk)rzkyBvipEzNIsCLWva4UcaVskzAM41LMwvL)OmfSTkKhV0ClKYwytJjdiWV120eA5iTytdihJ9OGLq)YzzCRc5Xl7uuIReUca3va4vsjtZeVU00rblH(LZY4wfYJxAUfc8wytJjdiWV120eA5iTytdihJDrn)4zLZB4tHIFNIsCLWva4UcaVskzAM41LMwuZpEw58g(uO4BUfQfTWMgtgqGFRTPj0YrAXMULRaQCIXJoJ9)DsBvv(HDSfKRXr8Vca1vaGCm2vv5pktbB7NJs9)Pknnt86stRQYFuMc22phLm3c1Qf20yYac8BTnnHwosl20olW07q)OsQrCePDmzab(nnt86std9JkPgXrKAU5MB6PifwxAHuwjLvAYeLbFFIPvX0SYzOPFfsJh1X)kOfxbmXRlxbIc6W(sHPhPxSeOPbTvWRnF4KGsy6Ra9dlX5sbOTcEvqckbG0vqRVxbkRKYkTuSuaARGx1)h)RGxZnfto9vaduIYle2xkwkyIxxc7JuKCsaS3OQYFuMc2wfYJx(UInaYXyxvL)OmfSTkKhVStrjUsi4cELuAPGjEDjSpsrYjbW(WMbrblH(LZY4wfYJx(UInaYXypkyj0VCwg3QqE8YofL4kHGl4vsPLcM41LW(ifjNea7dBgiQ5hpRCEdFku8FxXga5ySlQ5hpRCEdFku87uuIRecUGxjLwkyIxxc7JuKCsaSpSzGQk)rzkyB)Cu6DfBAjvoX4rNX()oPTQk)Wo2cY14i(bva5ySRQYFuMc22phL6)tvUuWeVUe2hPi5KayFyZaOFuj1ioI03vSXzbMEh6hvsnIJiTJjdiW)sXsbOTcETVsrISJ)vaofPGTc8scxb(dUcyIF0vqbxb8uUemGa7lfmXRlHnaI7(czOVuaARGxr(kHCsaSVcgpVUCfuWvaagpkUciNea7Ram)W(sbt86s4WMbJNxx(UInXA(X3uuIRecUGIslfG2k4vKosPYJ(k4IRacdDyFPGjEDjCyZavv(3WhKPlfmXRlHdBgOQYp0PLACPGjEDjCyZaziUlhLGlfmXRlHdBgaiU7VJYuWExXMw6SatVZqcMFojyhtgqGFqabqog7mKG5Ntc2LhbbeYDI)Pk7mKG5Ntc2POexj8LwvAPGjEDjCyZaaKcrQ6kNFxXMw6SatVZqcMFojyhtgqGFqabqog7mKG5Ntc2LhxkyIxxch2miwueqC3)DfBAPZcm9odjy(5KGDmzab(bbea5ySZqcMFojyxEeeqi3j(NQSZqcMFojyNIsCLWxAvPLcM41LWHnd4KGqNYInHfI3vSPLolW07mKG5Ntc2XKbe4heqaKJXodjy(5KGD5rqaHCN4FQYodjy(5KGDkkXvcFPvLwkyIxxch2maGN3xC70IOg(UInT0zbMENHem)CsWoMmGa)GaslbKJXodjy(5KGD5XLcM41LWHndIiLfB4yrlFPGjEDjCyZagsW8ZjbxkaTvWRiUcUua2k4sCfGjkb27vWiToA5GTcINqCQGRa)bxbVAyLZc8vVcyIxxUcef07lfmXRlHdBgqyHyZeVUClkO)ozjSbw5SaFxXgM41uCJjkviSzYsbOTcELNRajzHxJcCfGjkvi89kWFWvWiToA5GTcINqCQGRa)bxbVA(Wx9kGjED5kquqVVuWeVUeoSzaHfInt86YTOG(7KLWg(W3vSHjEnf3yIsfcFzYsbt86s4WMbKtoDKcDAPg3(5O0sbt86s4WMbq1GfLPGT9ZrPLcM41LWHndgPLel2qNwQXLILcqBf8ktw41kWz6m6RaM41LRGrAD0YbBfikOVuWeVUe25dBImUDkNWOmSU8DfBGNSaOYFFMEtXDLtR5JYEDjiGapzbqL)ESqXFFXnG4GWtcUuWeVUe25dh2mispOVHphr97k2aihJ9hUeq)OsD5XLcM41LWoF4WMbQQ8hLPGT9ZrP3vSHkNy8OZy)FN0wvLFyhBb5ACe)GkGCm2)3jTvv5hU)iGCm2)NQCPGjEDjSZhoSzquWs4g(Ce1VjGre42z6m6WMjVRydfJue(Waceub9olW07XII78MYDmzab(bbeNfy6DbdFQCEhfSec7yYac8dciKBkMC69ej0tC0pOBPGjEDjSZhoSzWiTKo6VyXwfpfFtaJiWTZ0z0HntExXMwcihJ9rAjD0FXITkEk2LhxkyIxxc78HdBgelkUZBk)UInmXRP4(FEpkyjCdFoI6xAa)sbt86syNpCyZGPiCePB)CuAPGjEDjSZhoSzGOMF8SY5nWj83vSbqog7J0s6O)IfBv8uSlpcQGEa5ySd9JkPgXrK2Lhbbea5ySlXOa60tARc5Xl7qNjQFPPvq3sbt86syNpCyZacLHpBrn)4zLZVRyJZcm9oHYWNkN3q)OsDmzab(bbea5yStOm8zlQ5hpRCU)pv5sbt86syNpCyZabpL3cg(8MagrGBNPZOdBM8UInolW07cg(u58okyje2XKbe4FPGjEDjSZhoSzaHYWNTOMF8SY5LcM41LWoF4WMbKhUYTOMF8SY53vSbqog7q)OsQrCePD5XLcM41LWoF4WMbKhUY9dtNIq)DfBaKJXUeJcOtpPTkKhVSdDMO(LMwxkyIxxc78HdBgGcuctNfBabd93vSbqog7smkGo9K2QqE8Yo0zI6xAADPGjEDjSZhoSza0pQKAehr67k2aihJDjgfqNEsBvipEzh6mr9lnTUuWeVUe25dh2mG8WvUf18JNvo)UInaYXyxIrb0PN0wfYJx2Hotu3mrPLcM41LWoF4WMbrblHB4Zru)MagrGBNPZOdBM8UInolW07XII78MYDmzab(xkyIxxc78HdBgaLZpsRCEPGjEDjSZhoSzGGNYBbdFEtaJiWTZ0z0HntExXgQCIXJoJ9rAjXITGNYBM4YSFuyhBb5ACe)GkGCm2hPLel2cEkVzIlZ(rHDOZe1VaklfmXRlHD(WHndG(rLGoTuJlfmXRlHD(WHnde8uEly4Zsbt86syNpCyZGOGLWn85iQFtaJiWTZ0z0HntExXgkgPi8Hbe4sbt86syNpCyZGiJBNYjmkdRlxkyIxxc78HdBgePh03WNJOEPGjEDjSZhoSzqrWn0PLACPGjEDjSZhoSza5HRClQ5hpRC(DfBaKJXUeJcOtpPTkKhVSdDMO(LMwxkyIxxc78HdBgelkUZBk)UInmXRP4(FEpkyjCdFoI6xMSuWeVUe25dh2mazQ)G5gowQXLcM41LWoF4WMbit9NnkqjmDwSuWeVUe25dh2mqvL)OmfSTFok9UInaYXyxvL)OmfSTFok1POexjeCbVslflfG2kqx5SaxbotNrFfWeVUCfmsRJwoyRarb9LcM41LWoSYzb2mslPJ(lwSvXtX3vSPLaYXyFKwsh9xSyRINID5XLcM41LWoSYzboSzGQk)rzkyB)Cu6DfBOYjgp6m2)3jTvv5h2XwqUghXpOcihJ9)DsBvv(H7pcihJ9)PkxkyIxxc7WkNf4WMbrblHB4Zru)UInT0lI6kNxkyIxxc7WkNf4WMbtr4is3(5O0sbt86syhw5Sah2mispOVHphr97k2aihJ9hUeq)OsD5XLcM41LWoSYzboSzaYu)bZnCSuJlfmXRlHDyLZcCyZGiJBNYjmkdRlxkyIxxc7WkNf4WMbIA(XZkN3aNWFxXga5ySd9JkPgXrK2LhxkyIxxc7WkNf4WMbOaLW0zXgqWq)DfBaKJXUeJcOtpPTkKhVSdDMO(LMwxkyIxxc7WkNf4WMbKhUY9dtNIq)DfBaKJXUeJcOtpPTkKhVSdDMO(LMwxkyIxxc7WkNf4WMbIA(XZkN3aNWFxXga5ySlXOa60tARc5Xl7qNjQBMO0sbt86syhw5Sah2mqWt5TGHpVRydGCm2FoF)W5VlpcciGEQCIXJoJ9rAjXITGNYBM4YSFuyhBb5ACe)GkGCm2hPLel2cEkVzIlZ(rHDOZe1VakGULcM41LWoSYzboSza0pQe0PLACPGjEDjSdRCwGdBga9JkPgXrK(UInaYXyxIrb0PN0wfYJx2Hotu)stRlfmXRlHDyLZcCyZabpL3cg(SuWeVUe2HvolWHndiug(Sf18JNvoVuWeVUe2HvolWHndIcwc3WNJO(nbmIa3otNrh2m5DfBOyKIWhgqGlfmXRlHDyLZcCyZGi9G(g(Ce1lfmXRlHDyLZcCyZGIGBOtl14sbt86syhw5Sah2makNFKw58sbt86syhw5Sah2miwuCN3u(DfByIxtX9)8EuWs4g(Ce1lfmXRlHDyLZcCyZarn)4zLZBGt4VRydGCm2LyuaD6jTvH84LDOZe1V006sbt86syhw5Sah2mazQ)SrbkHPZILcM41LWoSYzboSzGQk)rzkyB)Cu6DfBaKJXUQk)rzkyB)CuQtrjUsi4cELmnl7ph106s61yU5Mba]] )

end
