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

            nobuff = "earth_shield",

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

        potion = "potion_of_spectral_agility",

        package = "Enhancement",
    } )


    spec:RegisterSetting( "pad_windstrike", true, {
        name = "Pad |T1029585:0|t Windstrike Cooldown",
        desc = "If checked, the addon will treat |T1029585:0|t Windstrike's cooldown as slightly shorter, to help ensure that it is recommended as frequently as possible during Ascendance.",
        type = "toggle",
        width = 1.5
    } )


    spec:RegisterPack( "Enhancement", 20201220, [[dyuLYaqiLk6rkvOnHQsFsPsgfGsNcvfELsvZcqUfQkQAxu6xQGHHQQJPISmsLEgGQPjfORPIY2urLVjfuJdqrNtkiRtPsL5Pub3tkTpPqheqbwOIQhQuP0ebuixuPsXhvQuLtIQISssXmrvr5MOQOYojv9tLkv1sbuOEkftvk6RakOXkfG9k5VQ0Gr4WelgOhJYKvYLH2Su9zLYOb40IEnP0Sj52iA3c)wvdxroUkQA5i9CqtNQRJkBxr57OkJxkGopPI5RcTFfUovnlZsCS0Rl)6Y)jD1LFl)n0znSUaZY46mHLzsyALnSmHqILz3eaKGHKy4Lzs0r9YQAwg4Zrzyzmj5UTmGCPY5trbwML4yPxx(1L)t6Ql)w(BOZAyDB4YaNqwPx3Zb8YaixlmkWYSqiRm74Gy3eaKGHKy4dcdaHuIHMDCqamczijisheNAiGge6YVU8xgvcDy1SmWm2uy1S0FQAwgH55hLHxglOttTyzWqav4QMxEPx3QzzWqav4QMxggnDKMsz25GaKR3Tt0K8PRuuxEYm0YnvgH55hLzIMKpDLI6YtMHLx6bE1SmyiGkCvZldJMostPmuUa7pDdTR)jV8YybT455YPjCni47GaKR3TR)jV8YybTCtLryE(rzG(tjHon1ILx6BWQzzWqav4QMxggnDKMszOCb2F6gAx)tE5LXcAXZZLtt4AqW3bbixVBx)tE5LXcA5MkJW88JYWOceWvLBa8iJTYl9NvnldgcOcx18YWOPJ0ukdLlW(t3q76FYlVmwqlEEUCAcxdc(oia56D76FYlVmwql3uzeMNFuMKHxOttTy5L(ZvnldgcOcx18YWOPJ0ukZoheEY0MXwzeMNFuMUsiXleWZ0wEPVHRMLryE(rzMHWjKE93rYYGHaQWvnV8spWSAwgmeqfUQ5LHrthPPugqUE3cqsf0FkPLBQmcZZpktN(q)cb8mTLx6BOQzzeMNFuguOoamUWPulwgmeqfUQ5Lx6pXF1SmcZZpktxWRtLa25G5hLbdbuHRAE5L(tNQMLbdbuHRAEzy00rAkLbKR3Tq)PKArCcPwUPYimp)OmQCdGhzSDbFLxEP)KUvZYGHaQWvnVmmA6inLYaY17wsbvqN(KxEOm9Hf6ct7GOX2bXzLryE(rzqfsIHlQlOsGE5L(taVAwgmeqfUQ5LHrthPPugqUE3skOc60N8YdLPpSqxyAhen2oioRmcZZpkddGKXfGqNHqV8s)PgSAwgmeqfUQ5LHrthPPugqUE3skOc60N8YdLPpSqxyAheTdIt8xgH55hLrLBa8iJTl4R8Yl9NoRAwgmeqfUQ5LHrthPPugqUE3c49lajwwUPbXXJdcGDqq5cS)0n0ortsrDvYm5kmNt8NcT455YPjCni47GaKR3Tt0KuuxLmtUcZ5e)Pql0fM2brJdIZni4JYimp)OmkzMCvceq5L(tNRAwgH55hLb6pLe60ulwgmeqfUQ5Lx6p1WvZYGHaQWvnVmmA6inLYaY17wsbvqN(KxEOm9Hf6ct7GOX2bXzLryE(rzG(tj1I4eslV0FcywnlJW88JYOKzYvjqaLbdbuHRAE5L(tnu1SmcZZpkdJkqaxvUbWJm2kdgcOcx18Yl96YF1SmyiGkCvZlJW88JY0vcjEHaEM2YWOPJ0ukdf7uecqavyzy6Wu41f6g6Ws)PYl96EQAwgH55hLPtFOFHaEM2YGHaQWvnV8sVU6wnlJW88JYKm8cDAQfldgcOcx18Yl96c8QzzWqav4QMxggnDKMszOsUU4mmCRSwqBgdIgBheni)LryE(rzGCXcPzSvEPx3gSAwgmeqfUQ5LHrthPPugH55m8UE32vcjEHaEM2Yimp)Om9KI34NjLx619SQzzWqav4QMxggnDKMsza56DlPGkOtFYlpuM(WcDHPDq0y7G4SYimp)OmQCdGhzSDbFLxEPx3ZvnlJW88JYGc1bCrfsIHlQYGHaQWvnV8sVUnC1SmyiGkCvZldJMostPmGC9ULxgRohvNR)osAPiPKbCqSddcGZFzeMNFugEzS6CuDU(7iz5Lxg5XQzP)u1SmyiGkCvZldJMostPmGC9ULrfiGRk3a4rgBwUPYimp)Om8YybDAQflV0RB1SmyiGkCvZldJMostPmWNtbMXYUr)z4nJz52tfp)WIHaQW1G44Xbb85uGzSS9evR73VGQhcFsOfdbuHRYimp)OmDbVovcyNdMFuEPh4vZYGHaQWvnVmmA6inLYaY17wasQG(tjTCtLryE(rz60h6xiGNPT8sFdwnlJW88JYa5IfsZyRmyiGkCvZlV0Fw1SmyiGkCvZlJW88JY0vcjEHaEM2YWOPJ0ukdf7uecqav4GGVdcGDq4Icd32tkEJFMyXqav4AqC84GWffgUvjqazSD7kHeHwmeqfUgehpoiy)mmKWTbYOV6PRbbFugMomfEDHUHoS0FQ8s)5QMLbdbuHRAEzeMNFuMjAs(0vkQlpzgwggnDKMsz25GaKR3Tt0K8PRuuxEYm0YnvgMomfEDHUHoS0FQ8sFdxnldgcOcx18YWOPJ0ukJW8CgExVB7kHeVqapt7GOX2bbWlJW88JY0tkEJFMuEPhywnlJW88JYmdHti96VJKLbdbuHRAE5L(gQAwgmeqfUQ5LHrthPPugqUE3ortYNUsrD5jZql30GGVdcGDqaY17wO)usTioHul30G44XbbixVBjfubD6tE5HY0hwOlmTdIgBheNni4JYimp)OmQCdGhzSDbFLxEP)e)vZYGHaQWvnVmmA6inLY4Icd3YOceqgBxO)uslgcOcxdIJhheGC9ULrfiGRk3a4rgB21ZlkJW88JYWOceWvLBa8iJTYl9NovnldgcOcx18Yimp)OmkzMCvceqzy00rAkLXffgUvjqazSD7kHeHwmeqfUkdthMcVUq3qhw6pvEP)KUvZYGHaQWvnVmmA6inLYaY17wgvGaUQCdGhzSz5MkJW88JYa9NscDAQflV0Fc4vZYimp)OmmQabCv5gapYyRmyiGkCvZlV0FQbRMLbdbuHRAEzy00rAkLbKR3Tq)PKArCcPwUPYimp)OmmasgxvUbWJm2kV0F6SQzzWqav4QMxggnDKMsza56DlPGkOtFYlpuM(WcDHPDq0y7G4SYimp)OmmasgxacDgc9Yl9Nox1SmyiGkCvZldJMostPmGC9ULuqf0Pp5LhktFyHUW0oiASDqCwzeMNFuguHKy4I6cQeOxEP)udxnldgcOcx18YWOPJ0ukdixVBjfubD6tE5HY0hwOlmTdIgBheNvgH55hLb6pLulItiT8s)jGz1SmyiGkCvZldJMostPmGC9ULuqf0Pp5LhktFyHUW0oiAheN4VmcZZpkddGKXvLBa8iJTYl9NAOQzzWqav4QMxgH55hLPRes8cb8mTLHrthPPugxuy42EsXB8ZelgcOcxdc(oiOyNIqacOcldthMcVUq3qhw6pvEPxx(RMLbdbuHRAEzeMNFugLmtUkbcOmmA6inLYq5cS)0n0ortsrDvYm5kmNt8NcT455YPjCni47GaKR3Tt0KuuxLmtUcZ5e)Pql0fM2brJdIZvgMomfEDHUHoS0FQ8sVUNQMLbdbuHRAEzy00rAkLbKR3TKcQGo9jV8qz6dl0fM2brJTdIZge8DqimpNHxmqYeHdIgBheaVmcZZpkddGKXvLBa8iJTYl96QB1SmcZZpkdVmwqNMAXYGHaQWvnV8sVUaVAwgH55hLb6pLe60ulwgmeqfUQ5Lx61TbRMLryE(rzuYm5QeiGYGHaQWvnV8sVUNvnldgcOcx18Yimp)OmDLqIxiGNPTmmA6inLYqXofHaeqfwgMomfEDHUHoS0FQ8sVUNRAwgH55hLPl41Psa7CW8JYGHaQWvnV8sVUnC1SmcZZpktN(q)cb8mTLbdbuHRAE5LEDbMvZYimp)OmjdVqNMAXYGHaQWvnV8sVUnu1SmyiGkCvZldJMostPmGC9ULuqf0Pp5LhktFyHUW0oiASDqCwzeMNFuggajJRk3a4rgBLx6bo)vZYGHaQWvnVmmA6inLYimpNH3172UsiXleWZ0oiACqCQmcZZpktpP4n(zs5LEGFQAwgH55hLbfQdaJlCk1ILbdbuHRAE5LEGRB1SmcZZpkdkuhWfvijgUOkdgcOcx18Yl9ah4vZYGHaQWvnVmmA6inLYaY17wEzS6CuDU(7iPLIKsgWbXomiao)LryE(rz4LXQZr156VJKLxEzwyx4uE1S0FQAwgH55hLbu9)sXb9YGHaQWvbwEPx3QzzWqav4QMxggnDKMsz65ga)srsjd4GyhgeNJ)Yimp)OmtVNFuEPh4vZYimp)Om8YyDHaqHwgmeqfUQ5Lx6BWQzzeMNFugoiEthjHLbdbuHRAE5L(ZQMLbdbuHRAEzy00rAkLzNdcxuy4wbYWyjbdTyiGkCnioECqaY17wbYWyjbdTCtdIJhheS)vRNxyfidJLem0srsjd4GOXbXz8xgH55hLbu9)625O6uEP)CvZYGHaQWvnVmmA6inLYSZbHlkmCRazySKGHwmeqfUgehpoia56DRazySKGHwUPYimp)OmGifIuTzSvEPVHRMLbdbuHRAEzy00rAkLzNdcxuy4wbYWyjbdTyiGkCnioECqaY17wbYWyjbdTCtdIJhheS)vRNxyfidJLem0srsjd4GOXbXz8xgH55hLPNueu9)Q8spWSAwgmeqfUQ5LHrthPPuMDoiCrHHBfidJLem0IHaQW1G44XbbixVBfidJLem0YnnioECqW(xTEEHvGmmwsWqlfjLmGdIgheNXFzeMNFugjyi0PI6YeLQ8sFdvnldgcOcx18YWOPJ0ukZoheUOWWTcKHXscgAXqav4AqC84GyNdcqUE3kqggljyOLBQmcZZpkdOSD)(1PjtlS8s)j(RMLryE(rz6ivux4ustVmyiGkCvZlV0F6u1SmyiGkCvZldJMostPma7GWffgUvGmmwsWqlgcOcxdIJhheuUa7pDdTR)jV8YybT455YPjCni4JbbFhea7Ga(CkWmw2n6pdVzml3EQ45hwmeqfUgehpoiGpNcmJLTNOAD)(fu9q4tcTyiGkCnioECqimpNHxmqYeHdI2bXPbbFugH55hLPl41Psa7CW8JYl9N0TAwgmeqfUQ5LHrthPPugQKRlodd3kRf0MXGOX2brdX)G44XbHW8CgEXajteoiACqCQmcZZpkJazySKGHLx6pb8QzzWqav4QMxggnDKMszOCb2F6gAx)tE5LXcAXZZLtt4AqW3bbixVBx)tE5LXcExiixVBxpVyqW3bbWoiOsUU4mmCRSwqBgdIgBheNJ)bXXJdcH55m8IbsMiCq04G40GGpgehpoia56DlVmwDoQox)DK0UEErzeMNFugEzS6CuDU(7iz5L(tny1SmyiGkCvZldJMostPmcZZz4fdKmr4GODqCQmcZZpkdtuQRW88JRkHEzuj0VHqILbMXMclV0F6SQzzWqav4QMxggnDKMszeMNZWlgizIWbrJdItLryE(rzyIsDfMNFCvj0lJkH(nesSmYJLx6pDUQzzeMNFug2ZfosHon1Ix)DKSmyiGkCvZlV0FQHRMLryE(rzGA1PZr156VJKLbdbuHRAE5L(taZQzzeMNFuMjAskQl0PPwSmyiGkCvZlV8Ymrr2tckE1S0FQAwgmeqfUQ5LHrthPPugqUE3YlJvNJQZLhktFyPiPKbCqSddcGZp)LryE(rz4LXQZr15YdLPpkV0RB1SmyiGkCvZldJMostPmGC9UTRes0)yJdV8qz6dlfjLmGdIDyqaC(5VmcZZpktxjKO)XghE5HY0hLx6bE1SmcZZpkd47Ucx3Us0bx8Yy76FdmJYGHaQWvnV8sFdwnldgcOcx18YWOPJ0ukdixVBv5gapYy7cbKOAzPiPKbCqSddcGZp)LryE(rzu5gapYy7cbKOAvEP)SQzzWqav4QMxggnDKMsz25GGYfy)PBOD9p5LxglOfppxonHRbbFheGC9ULxgRohvNR)osAxpVOmcZZpkdVmwDoQox)DKS8s)5QMLbdbuHRAEzy00rAkLXffgUf6pLulIti1IHaQWvzeMNFugO)usTioH0YlV8YmdPW8JsVU8Rl)N09udxgEcnYydwgGHadagRNpPF3B3nigenbGdIKC6P(GO)0bXUKh31GGINNlP4AqaFsCqiC(tkoUgemasSHq7qdFwg4Gq3D3Gy3(XmK64AqSl4ZPaZyzBa7Aq4)GyxWNtbMXY2aSyiGkCTRbbWEQbYh2Hg(SmWbHU7UbXU9Jzi1X1GyxWNtbMXY2a21GW)bXUGpNcmJLTbyXqav4AxdcXhe7MDF(SbbWEQbYh2HMHgGHadagRNpPF3B3nigenbGdIKC6P(GO)0bXUwyx4u(Ugeu88Cjfxdc4tIdcHZFsXX1GGbqIneAhA4ZYaheNoT7ge72pMHuhxdIDbFofyglBdyxdc)he7c(CkWmw2gGfdbuHRDniawDBG8HDOzOHpro9uhxdIgCqimp)yqOsOdTdnLzI(9uHLzhhe7MaGemKedFqyaiKsm0SJdcGridjbr6G4udb0Gqx(1L)HMHgH55hq7efzpjO4T8Yy15O6C5HY0haL9wqUE3YlJvNJQZLhktFyPiPKbChao)8p0imp)aANOi7jbfFF7HUsir)Jno8YdLPpak7TGC9UTRes0)yJdV8qz6dlfjLmG7aW5N)HgH55hq7efzpjO47Bpa(URW1TReDWfVm2U(3aZyOryE(b0orr2tck((2dQCdGhzSDHasuTak7TGC9UvLBa8iJTleqIQLLIKsgWDa48Z)qJW88dODIISNeu89Th4LXQZr156VJKaL92Ds5cS)0n0U(N8YlJf0INNlNMWfFb56DlVmwDoQox)DK0UEEXqJW88dODIISNeu89ThG(tj1I4esbk7TUOWWTq)PKArCcPwmeqfUgAgA2XbXUPbImohxdcCgs1zq4jjoiCa4Gqy(thejCqiZKujGk0o0imp)a2cQ(FP4G(qZooi4tbFE2tck(Gy698JbrcheGy)P4GG9KGIpiWybTdncZZpG7Bpm9E(bqzVTNBa8lfjLmG7W54FOzhhe8PWrkLBYheFFqWeOdTdncZZpG7BpWlJ1fcaf6qJW88d4(2dCq8MoschAeMNFa33Eau9)625O6au2B3PlkmCRazySKGHwmeqfUoEeKR3TcKHXscgA5MoEK9VA98cRazySKGHwkskzaB8m(hAeMNFa33EaePqKQnJnGYE7oDrHHBfidJLem0IHaQW1XJGC9UvGmmwsWql30qJW88d4(2d9KIGQ)xaL92D6Icd3kqggljyOfdbuHRJhb56DRazySKGHwUPJhz)RwpVWkqggljyOLIKsgWgpJ)HgH55hW9ThKGHqNkQltukGYE7oDrHHBfidJLem0IHaQW1XJGC9UvGmmwsWql30XJS)vRNxyfidJLem0srsjdyJNX)qJW88d4(2dGY297xNMmTqGYE7oDrHHBfidJLem0IHaQW1XJ7eKR3TcKHXscgA5MgAeMNFa33EOJurDHtjn9HgH55hW9Th6cEDQeWohm)aOS3cSUOWWTcKHXscgAXqav464rkxG9NUH21)KxEzSGw88C50eU4d(cSWNtbMXYUr)z4nJz52tfp)44r4ZPaZyz7jQw3VFbvpe(KWJhfMNZWlgizIW2t8XqJW88d4(2dcKHXscgcu2BPsUU4mmCRSwqBgn22q8F8OW8CgEXajte24PHgH55hW9Th4LXQZr156VJKaL9wkxG9NUH21)KxEzSGw88C50eU4lixVBx)tE5LXcExiixVBxpVGValvY1fNHHBL1cAZOX2ZX)XJcZZz4fdKmryJN4JJhb56DlVmwDoQox)DK0UEEXqZooi4t9bXhkDgeFGdcmqsDaAqmrZNMUodI(Rupp4GWbGdIDbZytH7Aqimp)yqOsOBhAeMNFa33EGjk1vyE(XvLqhOqiXwygBkeOS3kmpNHxmqYeHTNgA2XbXUFmii5uEoPWbbgizIqGgeoaCqmrZNMUodI(Rupp4GWbGdIDjpURbHW88JbHkHUDOryE(bCF7bMOuxH55hxvcDGcHeBLhbk7TcZZz4fdKmryJNgAeMNFa33EG9CHJuOttT41FhjhAeMNFa33EaQvNohvNR)oso0imp)aUV9Wenjf1f60ulo0m0SJdc(CCkpheUq3qFqimp)yqmrZNMUodcvc9HgH55hqR8ylVmwqNMArGYElixVBzubc4QYnaEKXMLBAOryE(b0kpUV9qxWRtLa25G5haL9w4ZPaZyz3O)m8MXSC7PINFC8i85uGzSS9evR73VGQhcFs4qJW88dOvECF7Ho9H(fc4zAbk7TGC9UfGKkO)usl30qJW88dOvECF7bixSqAgBdncZZpGw5X9Th6kHeVqaptlqmDyk86cDdDy7jGYElf7uecqaviFbwxuy42EsXB8ZelgcOcxhp6Icd3QeiGm2UDLqIqlgcOcxhpY(zyiHBdKrF1tx8XqJW88dOvECF7HjAs(0vkQlpzgcethMcVUq3qh2EcOS3UtqUE3ortYNUsrD5jZql30qJW88dOvECF7HEsXB8ZeGYERW8CgExVB7kHeVqaptBJTaFOryE(b0kpUV9WmeoH0R)oso0imp)aALh33EqLBa8iJTl4RCGYElixVBNOj5txPOU8KzOLBIValixVBH(tj1I4esTCthpcY17wsbvqN(KxEOm9Hf6ctBJTNXhdncZZpGw5X9Thyubc4QYnaEKXgqzV1ffgULrfiGm2Uq)PKwmeqfUoEeKR3TmQabCv5gapYyZUEEXqJW88dOvECF7bLmtUkbcaiMomfEDHUHoS9eqzV1ffgUvjqazSD7kHeHwmeqfUgAeMNFaTYJ7Bpa9NscDAQfbk7TGC9ULrfiGRk3a4rgBwUPHgH55hqR84(2dmQabCv5gapYyBOryE(b0kpUV9adGKXvLBa8iJnGYElixVBH(tj1I4esTCtdncZZpGw5X9ThyaKmUae6me6aL9wqUE3skOc60N8YdLPpSqxyABS9SHgH55hqR84(2dOcjXWf1fujqhOS3cY17wsbvqN(KxEOm9Hf6ctBJTNn0imp)aALh33Ea6pLulItifOS3cY17wsbvqN(KxEOm9Hf6ctBJTNn0imp)aALh33EGbqY4QYnaEKXgqzVfKR3TKcQGo9jV8qz6dl0fM22t8p0imp)aALh33EORes8cb8mTaX0HPWRl0n0HTNak7TUOWWT9KI34NjwmeqfU4lf7uecqav4qJW88dOvECF7bLmtUkbcaiMomfEDHUHoS9eqzVLYfy)PBODIMKI6QKzYvyoN4pfAXZZLtt4IVGC9UDIMKI6QKzYvyoN4pfAHUW0245gAeMNFaTYJ7BpWaizCv5gapYydOS3cY17wsbvqN(KxEOm9Hf6ctBJTNXxH55m8IbsMiSXwGp0imp)aALh33EGxglOttT4qJW88dOvECF7bO)usOttT4qJW88dOvECF7bLmtUkbcyOryE(b0kpUV9qxjK4fc4zAbIPdtHxxOBOdBpbu2BPyNIqacOchAeMNFaTYJ7Bp0f86ujGDoy(XqJW88dOvECF7Ho9H(fc4zAhAeMNFaTYJ7BpKm8cDAQfhAeMNFaTYJ7BpWaizCv5gapYydOS3cY17wsbvqN(KxEOm9Hf6ctBJTNn0imp)aALh33EONu8g)mbOS3kmpNH3172UsiXleWZ024PHgH55hqR84(2dOqDayCHtPwCOryE(b0kpUV9akuhWfvijgUOgAeMNFaTYJ7BpWlJvNJQZ1Fhjbk7TGC9ULxgRohvNR)osAPiPKbChao)dndn74GWKXMcheUq3qFqimp)yqmrZNMUodcvc9HgH55hqlmJnf2YlJf0PPwCOryE(b0cZytH7BpmrtYNUsrD5jZqGYE7ob56D7enjF6kf1LNmdTCtdncZZpGwygBkCF7bO)usOttTiqzVLYfy)PBOD9p5LxglOfppxonHl(cY1721)KxEzSGwUPHgH55hqlmJnfUV9aJkqaxvUbWJm2ak7TuUa7pDdTR)jV8YybT455YPjCXxqUE3U(N8YlJf0Ynn0imp)aAHzSPW9ThsgEHon1IaL9wkxG9NUH21)KxEzSGw88C50eU4lixVBx)tE5LXcA5MgAeMNFaTWm2u4(2dDLqIxiGNPfOS3UtpzAZyBOryE(b0cZytH7BpmdHti96VJKdncZZpGwygBkCF7Ho9H(fc4zAbk7TGC9UfGKkO)usl30qJW88dOfMXMc33EafQdaJlCk1IdncZZpGwygBkCF7HUGxNkbSZbZpgAeMNFaTWm2u4(2dQCdGhzSDbFLdu2Bb56Dl0FkPweNqQLBAOryE(b0cZytH7BpGkKedxuxqLaDGYElixVBjfubD6tE5HY0hwOlmTn2E2qJW88dOfMXMc33EGbqY4cqOZqOdu2Bb56DlPGkOtFYlpuM(WcDHPTX2ZgAeMNFaTWm2u4(2dQCdGhzSDbFLdu2Bb56DlPGkOtFYlpuM(WcDHPT9e)dncZZpGwygBkCF7bLmtUkbcaOS3cY17waVFbiXYYnD8iWs5cS)0n0ortsrDvYm5kmNt8NcT455YPjCXxqUE3ortsrDvYm5kmNt8NcTqxyAB8C8XqJW88dOfMXMc33Ea6pLe60ulo0imp)aAHzSPW9ThG(tj1I4esbk7TGC9ULuqf0Pp5LhktFyHUW02y7zdncZZpGwygBkCF7bLmtUkbcyOryE(b0cZytH7BpWOceWvLBa8iJTHgH55hqlmJnfUV9qxjK4fc4zAbIPdtHxxOBOdBpbu2BPyNIqacOchAeMNFaTWm2u4(2dD6d9leWZ0o0imp)aAHzSPW9ThsgEHon1IdncZZpGwygBkCF7bixSqAgBaL9wQKRlodd3kRf0MrJTni)dncZZpGwygBkCF7HEsXB8ZeGYERW8CgExVB7kHeVqapt7qJW88dOfMXMc33EqLBa8iJTl4RCGYElixVBjfubD6tE5HY0hwOlmTn2E2qJW88dOfMXMc33EafQd4IkKedxudncZZpGwygBkCF7bEzS6CuDU(7ijqzVfKR3T8Yy15O6C93rslfjLmG7aW5VmcNd4PLXKK72YlVka]] )

end
