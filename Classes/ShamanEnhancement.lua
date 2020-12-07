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


    spec:RegisterPack( "Enhancement", 20201207, [[d8Z7SaqBqDArBsbQDjvVgfTpvf9BLopPkZgvZhf8juiPFPq(gPqDyIDkb7LYUf2VQ8tfiHHrkACOqLZPaKLrQQblrdxkDifqNcfQ6yQkDCuOSqf0JuGyXGSCKEOcKYtj5XiEoWevGunvj0KvX0P6IOqIxPqDzORJs)vLEgPGnlPTRQY2qHywQQ6ZkY8ifY3jLMMcGrROgVcKKtQau3sbs01uv4EsXkjvgfkK6MkqsT91kAQJ4OvqFn1xZV6RPg3)QP(6paFykxVw0uTcHPmHMkey0umkXSeeegd3uTIE8vowrtbwwkbnLkHh0mfeBY9bCyqM6ioAf0xt918R(AQX9VAQV(dGgmfOfjwb9zenyQ58CWWGm1bbetniVsgLywcccJH)kvZcSepDdYRCqhjimesFLA8)xP(AQVMMINahyfnfiJjoAfTcFTIMsiEUHP0MXb40KjAkmeioESHMBf03kAkmeioESHMIqthPPyQb(kHyR1ElnHx6jf(vR8d7STMsiEUHPAPj8spPWVALFO5wbnyfnfgcehp2qtrOPJ0umfLnW6sNW(zx4R2moGoYySzBlEELd(vcXwR9ZUWxTzCaD2wtjep3WuaFPWaNMmrZTcdGv0uyiqC8ydnfHMostXuu2aRlDc7NDHVAZ4a6iJXMTT45vo4xjeBT2p7cF1MXb0zBnLq8CdtrOcy(YZPzpYyYCRWhwrtHHaXXJn0ueA6inftrzdSU0jSF2f(QnJdOJmgB22INx5GFLqS1A)Sl8vBghqNT1ucXZnmvsWlWPjt0CRaJyfnfgcehp2qtrOPJ0um1aFLEsyMXKPeINByQkxGXlyEjmn3kOXwrtjep3Wu)qqlsV(6iSPWqG44XgAUvGXzfnfgcehp2qtrOPJ0umfeBT2NLKd8Lc3zBnLq8CdtvPlWVG5LW0CRWaYkAkH45gMcfQpJXf0MmrtHHaXXJn0CRWxnTIMsiEUHPQcEDQeGkli3WuyiqC8ydn3k89Rv0uyiqC8ydnfHMostXuqS1Ah4lfMjITiTZ2AkH45gMINtZEKX0fA5U5wHV6Bfnfgcehp2qtrOPJ0umfeBT2HfKdC6cF1Is7gDGleMVYpBELFykH45gMc5imgUWVqCb4MBf(QbROPWqG44XgAkcnDKMIPGyR1oSGCGtx4RwuA3OdCHW8v(zZR8dtjep3WuKzjJ7Sq)Ha3CRW3bWkAkmeioESHMIqthPPyki2ATdlih40f(QfL2n6aximFLnVYVAAkH45gMINtZEKX0fA5U5wHVFyfnfgcehp2qtrOPJ0umfeBT2Nx)olXPZ2(kzGHxjJ(vszdSU0jS3styHF5Yp5keNv8Lc6iJXMTT45vo4xjeBT2BPjSWVC5NCfIZk(sbDGleMVYpFLmYRKXBkH45gMIl)KlxaZMBf(Yiwrtjep3WuaFPWaNMmrtHHaXXJn0CRWxn2kAkmeioESHMIqthPPyki2ATdlih40f(QfL2n6aximFLF28k)WucXZnmfWxkmteBrQ5wHVmoROPeINBykU8tUCbmBkmeioESHMBf(oGSIMsiEUHPiubmF550ShzmzkmeioESHMBf0xtROPWqG44XgAkH45gMQYfy8cMxcttrOPJ0umffRuemlqC0ue9iC86cDcDGv4R5wb9)AfnLq8CdtvPlWVG5LW0uyiqC8ydn3kOV(wrtjep3WujbVaNMmrtHHaXXJn0CRG(AWkAkH45gMcWghKMXKPWqG44XgAUvq)bWkAkmeioESHMIqthPPykH45p8EwVx5cmEbZlHPPeINByQAsXBS)eZTc6)Hv0uyiqC8ydnfHMostXuqS1AhwqoWPl8vlkTB0bUqy(k)S5v(HPeINBykEon7rgtxOL7MBf0NrSIMsiEUHPqH6ZxKJWy4c3uyiqC8ydn3kOVgBfnfgcehp2qtrOPJ0umfeBT21MXPYs176RJWDkclzaELA0RudAAkH45gMsBgNklvVRVocBU5Msw0kAf(Afnfgcehp2qtrOPJ0umfeBT2jubmF550Shzm1zBnLq8CdtPnJdWPjt0CRG(wrtHHaXXJn0ueA6inftbwwougN(eD)H3m(Ltlv8CJxjdm8kbllhkJtVMi)C36fIVaWcdmLq8Cdtvf86ujavwqUH5wbnyfnfgcehp2qtrOPJ0umfeBT2NLKd8Lc3zBnLq8CdtvPlWVG5LW0CRWayfnfgcehp2qtjep3WuvUaJxW8syAkcnDKMIPOyLIGzbIJVYb)kz0Vsx4y49AsXBS)KogcehpVsgy4v6chdVZfWCgt3kxGrqhdbIJNxjdm8kj7pmKW7bsOlFPNxjJ3ue9iC86cDcDGv4R5wHpSIMcdbIJhBOPeINByQwAcV0tk8Rw5hAkcnDKMIPg4ReITw7T0eEPNu4xTYpSZ2AkIEeoEDHoHoWk81CRaJyfnfgcehp2qtrOPJ0umLq88hEpR3RCbgVG5LW8v(zZRudMsiEUHPQjfVX(tm3kOXwrtjep3Wu)qqlsV(6iSPWqG44XgAUvGXzfnfgcehp2qtrOPJ0umfeBT2BPj8spPWVALFyNT9vo4xjJ(vcXwRDGVuyMi2I0oB7RKbgELqS1AhwqoWPl8vlkTB0bUqy(k)S5v(XRKXBkH45gMINtZEKX0fA5U5wHbKv0uyiqC8ydnfHMostXuUWXW7eQaMZy6c8Lc3XqG445vYadVsi2ATtOcy(YZPzpYyQFwTHPeINBykcvaZxEon7rgtMBf(QPv0uyiqC8ydnLq8CdtXLFYLlGztrOPJ0umLlCm8oxaZzmDRCbgbDmeioEmfrpchVUqNqhyf(AUv47xROPWqG44XgAkcnDKMIPGyR1oHkG5lpNM9iJPoBRPeINBykGVuyGttMO5wHV6BfnLq8CdtrOcy(YZPzpYyYuyiqC8ydn3k8vdwrtHHaXXJn0ueA6inftbXwRDGVuyMi2I0oBRPeINBykYSKXLNtZEKXK5wHVdGv0uyiqC8ydnfHMostXuqS1AhwqoWPl8vlkTB0bUqy(k)S5v(HPeINBykYSKXDwO)qGBUv47hwrtHHaXXJn0ueA6inftbXwRDyb5aNUWxTO0Urh4cH5R8ZMx5hMsiEUHPqocJHl8lexaU5wHVmIv0uyiqC8ydnfHMostXuqS1AhwqoWPl8vlkTB0bUqy(k)S5v(HPeINBykGVuyMi2IuZTcF1yROPWqG44XgAkcnDKMIPGyR1oSGCGtx4RwuA3OdCHW8v28k)QPPeINBykYSKXLNtZEKXK5wHVmoROPWqG44XgAkH45gMQYfy8cMxcttrOPJ0umLlCm8EnP4n2FshdbIJhtr0JWXRl0j0bwHVMBf(oGSIMsiEUHPaSXbPzmzkmeioESHMBf0xtROPWqG44XgAkH45gMIl)KlxaZMIqthPPykkBG1LoH9wAcl8lx(jxH4SIVuqhzm2STfpVYb)kHyR1ElnHf(Ll)KRqCwXxkOdCHW8v(5RKrmfrpchVUqNqhyf(AUvq)Vwrtjep3WuAZ4aCAYenfgcehp2qZTc6RVv0ucXZnmfWxkmWPjt0uyiqC8ydn3kOVgSIMsiEUHP4Yp5YfWSPWqG44XgAUvq)bWkAkmeioESHMsiEUHPQCbgVG5LW0ueA6inftrXkfbZcehnfrpchVUqNqhyf(AUvq)pSIMsiEUHPQcEDQeGkli3WuyiqC8ydn3kOpJyfnLq8CdtvPlWVG5LW0uyiqC8ydn3kOVgBfnLq8CdtLe8cCAYenfgcehp2qZTc6Z4SIMcdbIJhBOPi00rAkMcITw7WcYboDHVArPDJoWfcZx5NnVYpmLq8CdtrMLmU8CA2JmMm3kO)aYkAkmeioESHMIqthPPykH45p8EwVx5cmEbZlH5R8Zx5xtjep3Wu1KI3y)jMBf0GMwrtjep3WuOq9zmUG2KjAkmeioESHMBf0WxROPeINBykuO(8f5imgUWnfgcehp2qZTcAqFROPWqG44XgAkcnDKMIPGyR1U2movwQExFDeUtryjdWRuJELAqttjep3WuAZ4uzP6D91ryZn3uhSkSC3kAf(AfnLq8CdtbX39WzbUPWqG44XGm3kOVv0uyiqC8ydnfHMostXu1CA2VuewYa8k1OxjJOPPeINByQ21Znm3kObROPeINBykTzCUGzuOMcdbIJhBO5wHbWkAkH45gMIfG30ryGPWqG44XgAUv4dROPWqG44XgAkcnDKMIPg4R0fogExaemosqWogcehpVsgy4vcXwRDbqW4ibb7STVsgy4vs2LFwTrxaemosqWofHLmaVYpFLFOPPeINByki(UNBLLQN5wbgXkAkmeioESHMIqthPPyQb(kDHJH3fabJJeeSJHaXXZRKbgELqS1AxaemosqWoBRPeINBykiKcqkZmMm3kOXwrtHHaXXJn0ueA6inftnWxPlCm8UaiyCKGGDmeioEELmWWReITw7cGGXrcc2zBFLmWWRKSl)SAJUaiyCKGGDkclzaELF(k)qttjep3Wu1KIq8DpMBfyCwrtHHaXXJn0ueA6inftnWxPlCm8UaiyCKGGDmeioEELmWWReITw7cGGXrcc2zBFLmWWRKSl)SAJUaiyCKGGDkclzaELF(k)qttjep3WusqqGtf(LiCU5wHbKv0uyiqC8ydnfHMostXud8v6chdVlacghjiyhdbIJNxjdm8kh4ReITw7cGGXrcc2zBnLq8Cdtbjt3TEDAsycm3k8vtROPeINByQksf(f0M00nfgcehp2qZTcF)AfnLq8CdtjacghjiOPWqG44XgAUv4R(wrtHHaXXJn0ueA6inftrzdSU0jSF2f(QnJdOJmgB22INx5GFLqS1A)Sl8vBghW9GqS1A)SAdtjep3WuAZ4uzP6D91ryZTcF1Gv0uyiqC8ydnfHMostXucXZF4fdeorWRS5v(1ucXZnmfr48Rq8CJlpbUP4jWVHaJMcKXehn3k8DaSIMcdbIJhBOPi00rAkMsiE(dVyGWjcELF(k)AkH45gMIiC(viEUXLNa3u8e43qGrtjlAUv47hwrtjep3WuKLnCKcCAYeV(6iSPWqG44XgAUv4lJyfnLq8CdtbyQxLLQ31xhHnfgcehp2qZTcF1yROPeINByQwAcl8lWPjt0uyiqC8ydn3Ct1srYcdjUv0k81kAkmeioESHMIqthPPyki2ATRnJtLLQ3vlkTB0PiSKb4vQrVsnOPMMsiEUHP0MXPYs17QfL2nm3kOVv0uyiqC8ydnfHMostXuqS1AVYfy03yIfVArPDJofHLmaVsn6vQbn10ucXZnmvLlWOVXelE1Is7gMBf0Gv0uyiqC8ydnfHMostXuqS1ANNtZEKX0fmNi)0PiSKb4vQrVsnOPMMsiEUHP450ShzmDbZjYpMBfgaROPWqG44XgAkcnDKMIPg4RKYgyDPty)Sl8vBghqhzm2STfpVYb)kHyR1U2movwQExFDeUFwTHPeINBykTzCQSu9U(6iS5wHpSIMcdbIJhBOPi00rAkMYfogEh4lfMjITiTJHaXXJPeINBykGVuyMi2IuZn3Ct9dPGCdRG(AQVMF1xZpmLwHgzmbm1agUDPoEELdWRuiEUXRKNah0F6mvlDRjhn1G8kzuIzjiimg(RunlWs80niVYbDKGWqi9vQX)FL6RP(A(090jep3a0BPizHHeVrBgNklvVRwuA34FwBGyR1U2movwQExTO0UrNIWsgansdAQ5tNq8CdqVLIKfgs8XnJQCbg9nMyXRwuA34FwBGyR1ELlWOVXelE1Is7gDkclza0inOPMpDcXZna9wkswyiXh3mINtZEKX0fmNi)8pRnqS1ANNtZEKX0fmNi)0PiSKbqJ0GMA(0jep3a0BPizHHeFCZiTzCQSu9U(6i8)S2mqkBG1LoH9ZUWxTzCaDKXyZ2w8myi2ATRnJtLLQ31xhH7NvB80jep3a0BPizHHeFCZiGVuyMi2I0)zTXfogEh4lfMjITiTJHaXXZt3t3G8kzuguHewhpVs8hs17v6jm(k9z8vkeFPVYe8kLFsYfio2F6eINBaAG47E4Sa)PBqELd4yqjzHHe)v2UEUXRmbVsiSUu8vswyiXFLyCa9NoH45gGXnJAxp34FwBQ50SFPiSKbqJyenF6gKx5aoCKszB9x5wFLeb4G(tNq8CdW4MrAZ4CbZOqF6eINBag3mIfG30ryWtNq8CdW4Mrq8Dp3klvV)zTzGUWXW7cGGXrcc2XqG44HbgGyR1UaiyCKGGD2wgyGSl)SAJUaiyCKGGDkclza(8dnF6eINBag3mccPaKYmJP)zTzGUWXW7cGGXrcc2XqG44HbgGyR1UaiyCKGGD22NoH45gGXnJQjfH47E(N1Mb6chdVlacghjiyhdbIJhgyaITw7cGGXrcc2zBzGbYU8ZQn6cGGXrcc2PiSKb4Zp08PtiEUbyCZijiiWPc)seo)FwBgOlCm8UaiyCKGGDmeioEyGbi2ATlacghjiyNTLbgi7YpR2OlacghjiyNIWsgGp)qZNoH45gGXnJGKP7wVonjmb)ZAZaDHJH3fabJJeeSJHaXXddmmqi2ATlacghjiyNT9PtiEUbyCZOksf(f0M00F6eINBag3msaemosqWNoH45gGXnJ0MXPYs176RJW)ZAdLnW6sNW(zx4R2moGoYySzBlEgmeBT2p7cF1MXbCpieBT2pR24PBqELd46RCdUEVYnWxjgiSE)FLT0CPPR3RSUC(Qf8k9z8vYOcYyIJmQVsH45gVsEc8(tNq8CdW4MreHZVcXZnU8e4)dbgBazmXX)zTriE(dVyGWjcA((0niVYbfXReML7zlhFLyGWjc()k9z8v2sZLMUEVY6Y5RwWR0NXxjJQSiJ6RuiEUXRKNaV)0jep3amUzer48Rq8CJlpb()qGXgzX)zTriE(dVyGWjc(87tNq8CdW4MrKLnCKcCAYeV(6i8tNq8CdW4MraM6vzP6D91r4NoH45gGXnJAPjSWVaNMmXNUNUb5voOML75R0f6e6VsH45gVYwAU0017vYtG)0jep3a0LfB0MXb40Kj(pRnqS1ANqfW8LNtZEKXuNT9PtiEUbOlloUzuvWRtLauzb5g)ZAdyz5qzC6t09hEZ4xoTuXZnyGbWYYHY40RjYp3TEH4laSWGNoH45gGUS44Mrv6c8lyEjm)N1gi2ATpljh4lfUZ2(0jep3a0Lfh3mQYfy8cMxcZ)e9iC86cDcDqZ3)zTHIvkcMfiooygTlCm8EnP4n2FshdbIJhgyWfogENlG5mMUvUaJGogcehpmWaz)HHeEpqcD5l9W4F6eINBa6YIJBg1st4LEsHF1k)W)e9iC86cDcDqZ3)zTzGqS1AVLMWl9Kc)Qv(HD22NoH45gGUS44Mr1KI3y)j)ZAJq88hEpR3RCbgVG5LW8Zgn80jep3a0Lfh3m6hcAr61xhHF6eINBa6YIJBgXZPzpYy6cTC)FwBGyR1ElnHx6jf(vR8d7STdMrdXwRDGVuyMi2I0oBldmaXwRDyb5aNUWxTO0Urh4cH5NnFW4F6eINBa6YIJBgrOcy(YZPzpYy6FwBCHJH3jubmNX0f4lfUJHaXXddmaXwRDcvaZxEon7rgt9ZQnE6eINBa6YIJBgXLFYLlG5)e9iC86cDcDqZ3)zTXfogENlG5mMUvUaJGogcehppDcXZnaDzXXnJa(sHbonzI)ZAdeBT2jubmF550Shzm1zBF6eINBa6YIJBgrOcy(YZPzpYy6PtiEUbOlloUzezwY4YZPzpYy6FwBGyR1oWxkmteBrANT9PtiEUbOlloUzezwY4ol0FiW)N1gi2ATdlih40f(QfL2n6axim)S5JNoH45gGUS44MrihHXWf(fIla)FwBGyR1oSGCGtx4RwuA3OdCHW8ZMpE6eINBa6YIJBgb8LcZeXwK(pRnqS1AhwqoWPl8vlkTB0bUqy(zZhpDcXZnaDzXXnJiZsgxEon7rgt)ZAdeBT2HfKdC6cF1Is7gDGleMnF18PtiEUbOlloUzuLlW4fmVeM)j6r441f6e6GMV)ZAJlCm8EnP4n2FshdbIJNNoH45gGUS44Mra24G0mME6eINBa6YIJBgXLFYLlG5)e9iC86cDcDqZ3)zTHYgyDPtyVLMWc)YLFYvioR4lf0rgJnBBXZGHyR1ElnHf(Ll)KRqCwXxkOdCHW8tg5PtiEUbOlloUzK2moaNMmXNoH45gGUS44MraFPWaNMmXNoH45gGUS44MrC5NC5cy(PtiEUbOlloUzuLlW4fmVeM)j6r441f6e6GMV)ZAdfRuemlqC8PtiEUbOlloUzuvWRtLauzb5gpDcXZnaDzXXnJQ0f4xW8sy(0jep3a0Lfh3mkj4f40Kj(0jep3a0Lfh3mImlzC550Shzm9pRnqS1AhwqoWPl8vlkTB0bUqy(zZhpDcXZnaDzXXnJQjfVX(t(N1gH45p8EwVx5cmEbZlH5NFF6eINBa6YIJBgHc1NX4cAtM4tNq8CdqxwCCZiuO(8f5imgUWF6eINBa6YIJBgPnJtLLQ31xhH)N1gi2ATRnJtLLQ31xhH7uewYaOrAqZNUNUb5vQYyIJVsxOtO)kfINB8kBP5stxVxjpb(tNq8CdqhKXehB0MXb40Kj(0jep3a0bzmXXXnJAPj8spPWVALF4)S2mqi2AT3st4LEsHF1k)WoB7tNq8CdqhKXehh3mc4lfg40Kj(pRnu2aRlDc7NDHVAZ4a6iJXMTT4zWqS1A)Sl8vBghqNT9PtiEUbOdYyIJJBgrOcy(YZPzpYy6FwBOSbwx6e2p7cF1MXb0rgJnBBXZGHyR1(zx4R2moGoB7tNq8CdqhKXehh3mkj4f40Kj(pRnu2aRlDc7NDHVAZ4a6iJXMTT4zWqS1A)Sl8vBghqNT9PtiEUbOdYyIJJBgv5cmEbZlH5)S2mqpjmZy6PtiEUbOdYyIJJBg9dbTi96RJWpDcXZnaDqgtCCCZOkDb(fmVeM)ZAdeBT2NLKd8Lc3zBF6eINBa6GmM444MrOq9zmUG2Kj(0jep3a0bzmXXXnJQcEDQeGkli34PtiEUbOdYyIJJBgXZPzpYy6cTC)FwBGyR1oWxkmteBrANT9PtiEUbOdYyIJJBgHCegdx4xiUa8)zTbITw7WcYboDHVArPDJoWfcZpB(4PtiEUbOdYyIJJBgrMLmUZc9hc8)zTbITw7WcYboDHVArPDJoWfcZpB(4PtiEUbOdYyIJJBgXZPzpYy6cTC)FwBGyR1oSGCGtx4RwuA3OdCHWS5RMpDcXZnaDqgtCCCZiU8tUCbm)pRnqS1AFE97SeNoBldmWOPSbwx6e2BPjSWVC5NCfIZk(sbDKXyZ2w8myi2AT3styHF5Yp5keNv8Lc6axim)Kry8pDcXZnaDqgtCCCZiGVuyGttM4tNq8CdqhKXehh3mc4lfMjITi9FwBGyR1oSGCGtx4RwuA3OdCHW8ZMpE6eINBa6GmM444MrC5NC5cy(PtiEUbOdYyIJJBgrOcy(YZPzpYy6PtiEUbOdYyIJJBgv5cmEbZlH5FIEeoEDHoHoO57)S2qXkfbZcehF6eINBa6GmM444Mrv6c8lyEjmF6eINBa6GmM444MrjbVaNMmXNoH45gGoiJjooUzeGnoinJPNoH45gGoiJjooUzunP4n2FY)S2iep)H3Z69kxGXlyEjmF6eINBa6GmM444Mr8CA2JmMUql3)N1gi2ATdlih40f(QfL2n6axim)S5JNoH45gGoiJjooUzekuF(ICegdx4pDcXZnaDqgtCCCZiTzCQSu9U(6i8)S2aXwRDTzCQSu9U(6iCNIWsgansdAAkH1NxQPuj8GM5MBg]] )

end
