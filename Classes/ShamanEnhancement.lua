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

        potion = "potion_of_spectral_agility",

        package = "Enhancement",
    } )


    spec:RegisterSetting( "pad_windstrike", true, {
        name = "Pad |T1029585:0|t Windstrike Cooldown",
        desc = "If checked, the addon will treat |T1029585:0|t Windstrike's cooldown as slightly shorter, to help ensure that it is recommended as frequently as possible during Ascendance.",
        type = "toggle",
        width = 1.5
    } )


    spec:RegisterPack( "Enhancement", 20201217, [[dyeLUaqiffEKav2KII(eqQgfqcNcirVsrAwaXTuukLDj0VuedtQWXuuTmPIEgqLPbuLRPkX2uuY3eOyCavLZbKK1jqvmpbkDpPQ9PkPdQOusluQ0dbskturPIlkqv9rfLs1jbQQwPaMjqs1nvukXofKFQOuPLkqvQNsQPkO(QavjJvrPQ9s5VQQbtshMyXaEmIjRuxgAZs5Zk0OvfNwYRjrZgv3gf7w0Vvz4k44aPSCKEoOPt11rPTRk13jHXROuCEbY8bk7xjBZTWMEloAH6SJo7yENZdM4Cq1lZc8apt7bnGMEqikLr00PWGMo4NpssqgmDtpibXpzBHnn8yPe006IbuZ0aSf3b)Pby6T4OfQZo6SJ5DopyIZbvVmlWdCMgoGeluNZcCM(P2BmnatVriX0b3sn4Npssqgm9LQ(ryKCfi4wQZoibzaq6sDEWaYsTZo6SdtZlOdTWMgw5ihTWwO5wytleVU00kQCdDAPennMcah3wxZTqDAHnnMcah3wxttOLJ0sm9mwQaSTwCGwmhDxc)RqEJr2btleVU00d0I5O7s4FfYB0Cle4SWMgtbGJBRRPj0YrAjMMYMy7OJyCFhZxrLByebn2Aya3l1zUubyBT4(oMVIk3Wi7GPfIxxAAOFugOtlLO5wiWZcBAmfaoUTUMMqlhPLyAkBITJoIX9DmFfvUHre0yRHbCVuN5sfGT1I77y(kQCdJSdMwiEDPPjub(8514JNvoAUf6flSPXua4426AAcTCKwIPPSj2o6ig33X8vu5ggrqJTggW9sDMlva2wlUVJ5ROYnmYoyAH41LMUi4h60sjAUfAwwytJPaWXT110eA5iTetpJLQxeLvoAAH41LMUXfg8dFoIsZTqbJf20cXRln9BeoG0VFoYyAmfaoUTUMBHaFwytJPaWXT110eA5iTetdW2AXhP4q)Omr2btleVU00n6b9p85ikn3cbQSWMwiEDPPrH6py(HdLs00ykaCCBDn3cnVdlSPfIxxA6MGFNkjSXcRlnnMcah3wxZTqZNBHnnMcah3wxttOLJ0smnaBRfH(rzuI4asJSdMwiEDPP514JNvo(boUBUfAENwytJPaWXT110eA5iTetdW2Argb5qNEmFfOmCze6cr5s91(L6lMwiEDPProYGPl8paxGU5wO5GZcBAmfaoUTUMMqlhPLyAa2wlYiih60J5RaLHlJqxikxQV2VuFX0cXRlnn5rQ8)i03i0n3cnh8SWMgtbGJBRRPj0YrAjMgGT1ImcYHo9y(kqz4Yi0fIYLA)sDEhMwiEDPP514JNvo(boUBUfA(lwytJPaWXT110eA5iTetdW2AXNZ)psUJSdlvWaBPckwQu2eBhDeJd0Ir4FU8w(cXzf)OWicAS1WaUxQZCPcW2AXbAXi8pxElFH4SIFuye6cr5s91L6SwQGstleVU00C5T85c8XCl08zzHnTq86std9JYaDAPennMcah3wxZTqZdglSPXua4426AAcTCKwIPbyBTiJGCOtpMVcugUmcDHOCP(A)s9ftleVU00q)OmkrCaPMBHMd(SWMwiEDPP5YB5Zf4JPXua4426AUfAoOYcBAH41LMMqf4ZNxJpEw5OPXua4426AUfQZoSWMgtbGJBRRPfIxxA6gxyWp85iknnHwoslX0uSrr4JaWrttcIWXVl0r0HwO5MBH6CUf20cXRlnDJEq)dFoIstJPaWXT11CluNDAHnTq86stxe8dDAPennMcah3wxZTqDcolSPfIxxAAiBUrALJMgtbGJBRR5wOobplSPXua4426AAcTCKwIPfIxVX)(8yJlm4h(CeLMwiEDPPBff)59wm3c15lwytJPaWXT110eA5iTetdW2Argb5qNEmFfOmCze6cr5s91(L6lMwiEDPP514JNvo(boUBUfQZzzHnTq86stJc1F(ihzW0fUPXua4426AUfQZGXcBAmfaoUTUMMqlhPLyAa2wlQOYDJLg03phzIuKrQeUud2Lk46W0cXRlnTIk3nwAqF)CKXCZnTCOf2cn3cBAmfaoUTUMMqlhPLyAa2wlsOc85ZRXhpRCmYoyAH41LMwrLBOtlLO5wOoTWMgtbGJBRRPj0YrAjMgESCGk3Xr69g)v(UgpQ41LrmfaoUxQGb2sfESCGk3XwH89)AFa(bHhdmIPaWXTPfIxxA6MGFNkjSXcRln3cbolSPXua4426AAcTCKwIPbyBT4JuCOFuMi7GPfIxxA6g9G(h(CeLMBHaplSPXua4426AAH41LMUXfg8dFoIsttOLJ0smnfBue(iaCCPoZLkOyP6chtp2kk(Z7TeXua44EPcgylvx4y6rUaFQC834cdcJykaCCVubdSLk5EJPKEmrc94hDVubLMMeeHJFxOJOdTqZn3c9If20ykaCCBDnTq86stpqlMJUlH)viVrttOLJ0sm9mwQaSTwCGwmhDxc)RqEJr2bttcIWXVl0r0HwO5MBHMLf20ykaCCBDnnHwoslX0cXR34FFESXfg8dFoIYL6R9lvWzAH41LMUvu8N3BXCluWyHnTq86st)gHdi97NJmMgtbGJBRR5wiWNf20ykaCCBDnnHwoslX0aSTwCGwmhDxc)RqEJr2HL6mxQGILkaBRfH(rzuI4asJSdlvWaBPcW2Argb5qNEmFfOmCze6cr5s91(L6llvqPPfIxxAAEn(4zLJFGJ7MBHavwytJPaWXT110eA5iTet7chtpsOc8PYXp0pktetbGJ7LkyGTubyBTiHkWNpVgF8SYX4(uKMwiEDPPjub(8514JNvoAUfAEhwytJPaWXT110cXRlnnxElFUaFmnHwoslX0UWX0JCb(u54VXfgegXua4420KGiC87cDeDOfAU5wO5ZTWMgtbGJBRRPj0YrAjMgGT1IeQaF(8A8XZkhJSdMwiEDPPH(rzGoTuIMBHM3Pf20cXRlnnHkWNpVgF8SYrtJPaWXT11Cl0CWzHnnMcah3wxttOLJ0smnaBRfH(rzuI4asJSdMwiEDPPjpsLFEn(4zLJMBHMdEwytJPaWXT110eA5iTetdW2Argb5qNEmFfOmCze6cr5s91(L6lMwiEDPPjpsL)hH(gHU5wO5VyHnnMcah3wxttOLJ0smnaBRfzeKdD6X8vGYWLrOleLl1x7xQVyAH41LMg5idMUW)aCb6MBHMpllSPXua4426AAcTCKwIPbyBTiJGCOtpMVcugUmcDHOCP(A)s9ftleVU00q)OmkrCaPMBHMhmwytJPaWXT110eA5iTetdW2Argb5qNEmFfOmCze6cr5sTFPoVdtleVU00KhPYpVgF8SYrZTqZbFwytJPaWXT110cXRlnDJlm4h(CeLMMqlhPLyAx4y6XwrXFEVLiMcah3l1zUuPyJIWhbGJMMeeHJFxOJOdTqZn3cnhuzHnTq86stdzZnsRC00ykaCCBDn3c1zhwytJPaWXT110cXRlnnxElFUaFmnHwoslX0u2eBhDeJd0Ir4FU8w(cXzf)OWicAS1WaUxQZCPcW2AXbAXi8pxElFH4SIFuye6cr5s91L6Smnjich)UqhrhAHMBUfQZ5wytleVU00kQCdDAPennMcah3wxZTqD2Pf20cXRlnn0pkd0PLs00ykaCCBDn3c1j4SWMwiEDPP5YB5Zf4JPXua4426AUfQtWZcBAmfaoUTUMwiEDPPBCHb)WNJO00eA5iTettXgfHpcahnnjich)UqhrhAHMBUfQZxSWMwiEDPPBc(DQKWglSU00ykaCCBDn3c15SSWMwiEDPPB0d6F4ZruAAmfaoUTUMBH6mySWMwiEDPPlc(HoTuIMgtbGJBRR5wOobFwytJPaWXT110eA5iTetdW2Argb5qNEmFfOmCze6cr5s91(L6lMwiEDPPjpsLFEn(4zLJMBH6euzHnnMcah3wxttOLJ0smTq86n(3NhBCHb)WNJOCP(6sDUPfIxxA6wrXFEVfZTqGRdlSPfIxxAAuO(dMF4qPennMcah3wxZTqGBUf20cXRlnnku)5JCKbtx4MgtbGJBRR5wiW1Pf20ykaCCBDnnHwoslX0aSTwurL7glnOVFoYePiJujCPgSlvW1HPfIxxAAfvUBS0G((5iJ5MB6n2ewUBHTqZTWMwiEDPPb43T5Sq30ykaCCBaMBH60cBAmfaoUTUMMqlhPLy6wn(4FkYivcxQb7sDwDyAH41LME486sZTqGZcBAH41LMwrL7p8bfQPXua4426AUfc8SWMwiEDPPzH4VCKbAAmfaoUTUMBHEXcBAmfaoUTUMMqlhPLy6zSuDHJPhfibZTKemIPaWX9sfmWwQaSTwuGem3ssWi7WsfmWwQK747trgfibZTKemsrgPs4s91L6lDyAH41LMgGF3(3yPbzUfAwwytJPaWXT110eA5iTetpJLQlCm9OajyULKGrmfaoUxQGb2sfGT1IcKG5wscgzhmTq86stdGuisvw5O5wOGXcBAmfaoUTUMMqlhPLy6zSuDHJPhfibZTKemIPaWX9sfmWwQaSTwuGem3ssWi7WsfmWwQK747trgfibZTKemsrgPs4s91L6lDyAH41LMUvueGF32Cle4ZcBAmfaoUTUMMqlhPLy6zSuDHJPhfibZTKemIPaWX9sfmWwQaSTwuGem3ssWi7WsfmWwQK747trgfibZTKemsrgPs4s91L6lDyAH41LMwsccDQW)eHZn3cbQSWMgtbGJBRRPj0YrAjMEglvx4y6rbsWCljbJykaCCVubdSL6mwQaSTwuGem3ssWi7GPfIxxAAaz8FTVtlIsO5wO5DyHnTq86st3qQW)WHIwUPXua4426AUfA(ClSPfIxxAAbsWCljbnnMcah3wxZTqZ70cBAmfaoUTUMMqlhPLyAkBITJoIX9DmFfvUHre0yRHbCVuN5sfGT1I77y(kQCd)BeGT1I7trUubdSLkaBRfvu5UXsd67NJmX9PinTq86stROYDJLg03phzm3cnhCwytJPaWXT110eA5iTetleVEJFmrMcHl1(L6CtleVU00eHZ)cXRl)8c6MMxq)NcdAAyLJC0Cl0CWZcBAmfaoUTUMMqlhPLyAH41B8JjYuiCP(6sDUPfIxxAAIW5FH41LFEbDtZlO)tHbnTCO5wO5VyHnTq86stto20rk0PLs87NJmMgtbGJBRR5wO5ZYcBAH41LMgQmOglnOVFoYyAmfaoUTUMBHMhmwytleVU00d0Ir4FOtlLOPXua4426AU5MEGIKJbqClSfAUf20ykaCCBDnnHwoslX0aSTwurL7glnOVcugUmsrgPs4snyxQGRJomTq86stROYDJLg0xbkdxAUfQtlSPXua4426AAcTCKwIPbyBTyJlmOF5il(vGYWLrkYivcxQb7sfCD0HPfIxxA6gxyq)Yrw8RaLHln3cbolSPfIxxAAGZDoU)nUeeUvu543VztLMgtbGJBRR5wiWZcBAmfaoUTUMMqlhPLyAa2wlYRXhpRC8dFkKVJuKrQeUud2Lk46OdtleVU008A8XZkh)WNc5BZTqVyHnnMcah3wxttOLJ0sm9mwQu2eBhDeJ77y(kQCdJiOXwdd4EPoZLkaBRfvu5UXsd67NJmX9PinTq86stROYDJLg03phzm3cnllSPXua4426AAcTCKwIPDHJPhH(rzuI4asJykaCCBAH41LMg6hLrjIdi1CZn30VrkSU0c1zhD2X8oNpltRqOzLJqth8A2AW7qG)qZ2dEwQl1Wp4sTygoQVuBhDPc6YHG(sLIGgBrX9sfEm4svy9JrCCVujpsoIW4kaOEL4sTZGNLkO2LVrQJ7LkOdpwoqL74Sh0xQ(TubD4XYbQChN9rmfaoUb9LkOy(Sbugxba1RexQDg8Sub1U8nsDCVubD4XYbQChN9G(s1VLkOdpwoqL74SpIPaWXnOVufFPg8NDb1xQGI5ZgqzCfyfa8ZmCuh3lvWBPkeVUCPYlOdJRaMEGETIJMo4wQb)8rscYGPVu1pcJKRab3sD2bjidasxQZdgqwQD2rNDScScieVUeghOi5yaeVxrL7glnOVcugUeKQ1dW2ArfvUBS0G(kqz4YifzKkHbl46OJvaH41LW4afjhdG4t7N04cd6xoYIFfOmCjivRhGT1InUWG(LJS4xbkdxgPiJujmybxhDScieVUeghOi5yaeFA)eGZDoU)nUeeUvu543VztLRacXRlHXbksogaXN2pHxJpEw54h(uiFds16byBTiVgF8SYXp8Pq(osrgPsyWcUo6yfqiEDjmoqrYXai(0(jkQC3yPb99ZrgqQw)mOSj2o6ig33X8vu5ggrqJTggW9mbyBTOIk3nwAqF)CKjUpf5kGq86syCGIKJbq8P9tG(rzuI4asbPA9UWX0Jq)OmkrCaPrmfaoUxbwbcULAWF2Gewh3lv8nsdAP6fdUu9hCPke)Ol1cUuL3sXfaogxbeIxxc7b43T5SqFfi4wQG)C2g5yaeFPoCED5sTGlvaSDuCPsogaXxQyUHXvaH41LWP9tgoVUeKQ13QXh)trgPsyWoRowbcULk4pDKszh8L61wQeb6W4kGq86s40(jkQC)HpOqxbeIxxcN2pHfI)Yrg4kGq86s40(ja872)glniqQw)mCHJPhfibZTKemIPaWXnyGbW2ArbsWCljbJSdGbg5o((uKrbsWCljbJuKrQe(6lDScieVUeoTFcasHivzLJGuT(z4chtpkqcMBjjyetbGJBWadGT1IcKG5wscgzhwbeIxxcN2pPvueGF3gKQ1pdx4y6rbsWCljbJykaCCdgyaSTwuGem3ssWi7ayGrUJVpfzuGem3ssWifzKkHV(shRacXRlHt7NijbHov4FIW5GuT(z4chtpkqcMBjjyetbGJBWadGT1IcKG5wscgzhadmYD89PiJcKG5wscgPiJuj81x6yfqiEDjCA)eaz8FTVtlIsiivRFgUWX0JcKG5wscgXua44gmWMbaBRffibZTKemYoScieVUeoTFsdPc)dhkA5RacXRlHt7NiqcMBjj4kGq86s40(jkQC3yPb99ZrgqQwpLnX2rhX4(oMVIk3WicAS1WaUNjaBRf33X8vu5g(3iaBRf3NIemWayBTOIk3nwAqF)CKjUpf5kqWTub)TL6L8GwQxIlvmrMGazPoqRJwEql12X5Nc4s1FWLkOdRCKJG(sviED5sLxqpUcieVUeoTFcr48Vq86YpVGoiPWG9Wkh5iivRxiE9g)yImfc7NVceCl1z3CPYWY9AGJlvmrMcHGSu9hCPoqRJwEql12X5Nc4s1FWLkOlhc6lvH41LlvEb94kGq86s40(jeHZ)cXRl)8c6GKcd2lhcs16fIxVXpMitHWxNVcieVUeoTFc5ythPqNwkXVFoYScieVUeoTFcuzqnwAqF)CKzfqiEDjCA)KbAXi8p0PLsCfyfi4wQZwy5ETuDHoI(sviED5sDGwhT8GwQ8c6RacXRlHr5WEfvUHoTuIGuTEa2wlsOc85ZRXhpRCmYoScieVUegLdN2pPj43PscBSW6sqQwp8y5avUJJ07n(R8DnEuXRlbdm4XYbQChBfY3)R9b4heEmWvaH41LWOC40(jn6b9p85ikbPA9aSTw8rko0pktKDyfqiEDjmkhoTFsJlm4h(CeLGqcIWXVl0r0H9ZbPA9uSrr4JaWXzckCHJPhBff)59wIykaCCdgyUWX0JCb(u54VXfgegXua44gmWi3BmL0JjsOh)OBq5kGq86syuoCA)KbAXC0Dj8Vc5nccjich)Uqhrh2phKQ1pda2wloqlMJUlH)viVXi7WkGq86syuoCA)KwrXFEVfqQwVq86n(3NhBCHb)WNJO81EWTcieVUegLdN2p5nchq63phzwbeIxxcJYHt7NWRXhpRC8dCChKQ1dW2AXbAXC0Dj8Vc5ngzhMjOaGT1Iq)OmkrCaPr2bWadGT1ImcYHo9y(kqz4Yi0fIYx7FbuUcieVUegLdN2pHqf4ZNxJpEw5iivR3foMEKqf4tLJFOFuMiMcah3GbgaBRfjub(8514JNvog3NICfqiEDjmkhoTFcxElFUaFaHeeHJFxOJOd7Nds16DHJPh5c8PYXFJlmimIPaWX9kGq86syuoCA)eOFugOtlLiivRhGT1IeQaF(8A8XZkhJSdRacXRlHr5WP9tiub(8514JNvoUcieVUegLdN2pH8iv(514JNvocs16byBTi0pkJsehqAKDyfqiEDjmkhoTFc5rQ8)i03i0bPA9aSTwKrqo0PhZxbkdxgHUqu(A)lRacXRlHr5WP9tqoYGPl8paxGoivRhGT1ImcYHo9y(kqz4Yi0fIYx7FzfqiEDjmkhoTFc0pkJsehqkivRhGT1ImcYHo9y(kqz4Yi0fIYx7FzfqiEDjmkhoTFc5rQ8ZRXhpRCeKQ1dW2Argb5qNEmFfOmCze6crz)8owbeIxxcJYHt7N04cd(HphrjiKGiC87cDeDy)CqQwVlCm9yRO4pV3setbGJ7zsXgfHpcahxbeIxxcJYHt7NazZnsRCCfqiEDjmkhoTFcxElFUaFaHeeHJFxOJOd7Nds16PSj2o6ighOfJW)C5T8fIZk(rHre0yRHbCpta2wloqlgH)5YB5leNv8JcJqxikFDwRacXRlHr5WP9tuu5g60sjUcieVUegLdN2pb6hLb60sjUcieVUegLdN2pHlVLpxGpRacXRlHr5WP9tACHb)WNJOeesqeo(DHoIoSFoivRNInkcFeaoUcieVUegLdN2pPj43PscBSW6YvaH41LWOC40(jn6b9p85ikxbeIxxcJYHt7Nue8dDAPexbeIxxcJYHt7NqEKk)8A8XZkhbPA9aSTwKrqo0PhZxbkdxgHUqu(A)lRacXRlHr5WP9tAff)59waPA9cXR34FFESXfg8dFoIYxNVcieVUegLdN2pbfQ)G5houkXvaH41LWOC40(jOq9NpYrgmDHVcieVUegLdN2prrL7glnOVFoYas16byBTOIk3nwAqF)CKjsrgPsyWcUowbwbcULQUYroUuDHoI(sviED5sDGwhT8GwQ8c6RacXRlHryLJCSxrLBOtlL4kGq86syew5ihN2pzGwmhDxc)RqEJGuT(zaW2AXbAXC0Dj8Vc5ngzhwbeIxxcJWkh540(jq)OmqNwkrqQwpLnX2rhX4(oMVIk3WicAS1WaUNjaBRf33X8vu5ggzhwbeIxxcJWkh540(jeQaF(8A8XZkhbPA9u2eBhDeJ77y(kQCdJiOXwdd4EMaSTwCFhZxrLByKDyfqiEDjmcRCKJt7Nue8dDAPebPA9u2eBhDeJ77y(kQCdJiOXwdd4EMaSTwCFhZxrLByKDyfqiEDjmcRCKJt7N04cd(HphrjivRFgEruw54kGq86syew5ihN2p5nchq63phzwbeIxxcJWkh540(jn6b9p85ikbPA9aSTw8rko0pktKDyfqiEDjmcRCKJt7NGc1FW8dhkL4kGq86syew5ihN2pPj43PscBSW6YvaH41LWiSYrooTFcVgF8SYXpWXDqQwpaBRfH(rzuI4asJSdRacXRlHryLJCCA)eKJmy6c)dWfOds16byBTiJGCOtpMVcugUmcDHO81(xwbeIxxcJWkh540(jKhPY)JqFJqhKQ1dW2Argb5qNEmFfOmCze6cr5R9VScieVUegHvoYXP9t414JNvo(boUds16byBTiJGCOtpMVcugUmcDHOSFEhRacXRlHryLJCCA)eU8w(Cb(as16byBT4Z5)hj3r2bWaduqztSD0rmoqlgH)5YB5leNv8JcJiOXwdd4EMaSTwCGwmc)ZL3YxioR4hfgHUqu(6SaLRacXRlHryLJCCA)eOFugOtlL4kGq86syew5ihN2pb6hLrjIdifKQ1dW2Argb5qNEmFfOmCze6cr5R9VScieVUegHvoYXP9t4YB5Zf4ZkGq86syew5ihN2pHqf4ZNxJpEw54kGq86syew5ihN2pPXfg8dFoIsqibr443f6i6W(5GuTEk2Oi8ra44kGq86syew5ihN2pPrpO)Hphr5kGq86syew5ihN2pPi4h60sjUcieVUegHvoYXP9tGS5gPvoUcieVUegHvoYXP9tAff)59waPA9cXR34FFESXfg8dFoIYvaH41LWiSYrooTFcVgF8SYXpWXDqQwpaBRfzeKdD6X8vGYWLrOleLV2)YkGq86syew5ihN2pbfQ)8roYGPl8vaH41LWiSYrooTFIIk3nwAqF)CKbKQ1dW2ArfvUBS0G((5itKImsLWGfCDyAH1FoQP1fdOM5MBg]] )

end
