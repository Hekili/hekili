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


    spec:RegisterPack( "Enhancement", 20201210, [[d8ZjTaWzf5Xi2Kck7skBdus7trLBJIZtsz2OA(GIpbkH(Lc5BkOYPLStryVu2TW(vv)ubvrdJe53QmoqPYLHgSinCPQdPG0PaLQoMIY5aLOfQaVMewmilhPhQGQQNsQLrs1ZbMOcQktvenzLmDQUiOe8kfQNrIY1rPJdkLhPGOnlQTRu5WeZsPQPrIkZJev9Dq1FvLrRugVcQsoPccDlfufUMIQUNuzLKKrPGGBQGQuBZSKMEjoAjuxj1vAM6ZuQndwot5usDt7Q1JMUxikKj00HWGMgwi2KGGmy4MUxuJFYYsAAWXsjOP1fZWVPHylUpeddY0lXrlH6kPUsZuFMsTzWYzkNPb9iXsOoSQmtVvRfggKPxiGy6H8NcleBsqqgm8FQEtyK4RAi)PdFibzGq6pDMs7)PQRK6kzAEbCGL00GkM4OL0smZsAAH41fMgEflGtlfOPXqG44YgyULqDlPPXqG44YgyAcTCKwIPh6pfInNB90I5ORs4p4YoSX2BAH41fMUNwmhDvc)bx2HMBjuML00yiqCCzdmnHwoslX0u2aZhDcBR7yEWRybAiSXw9946NoSFkeBo3w3X8GxXc0y7nTq86ctd8JYaCAPan3sOCwstJHaXXLnW0eA5iTettzdmF0jSTUJ5bVIfOHWgB13JRF6W(PqS5CBDhZdEflqJT30cXRlmnHkGThVM28OIjZTeZBjnngcehx2attOLJ0smnLnW8rNW26oMh8kwGgcBSvFpU(Pd7NcXMZT1Dmp4vSan2EtleVUW0fbFaNwkqZTeWQL00yiqCCzdmnHwoslX0d9N6frrftMwiEDHPZCHbFGTJOWClXWzjnTq86ctVdb9i95NJmMgdbIJlBG5wcyNL00yiqCCzdmnHwoslX0qS5CBtkoWpktJT30cXRlmDMEa)b2oIcZTeWslPPfIxxyAuO(ggpqFPanngcehx2aZTeZuYsAAH41fMol4ZPsaYSG6ctJHaXXLnWClXSzwstJHaXXLnW0eA5iTetdXMZnGFugfi2J0gBVPfIxxyAEnT5rftpOJ7MBjMPUL00yiqCCzdmnHwoslX0qS5CJrqoWPhZdok9x0aUqu8tNR7NoVPfIxxyAKJmy4c)bXfGBULyMYSKMgdbIJlBGPj0YrAjMgInNBmcYbo9yEWrP)IgWfIIF6CD)05nTq86ctt2KkEBcDhcCZTeZuolPPXqG44YgyAcTCKwIPHyZ5gJGCGtpMhCu6VObCHO4N29tNPKPfIxxyAEnT5rftpOJ7MBjMnVL00yiqCCzdmnHwoslX0qS5CB783MeRgB)pfgy(PdHFkLnW8rNWwpTye(Jl7KNqCwXpkOHWgB13JRF6W(PqS5CRNwmc)XLDYtioR4hf0aUqu8tN7NcR)uyVPfIxxyAUStECbSzULygSAjnTq86ctd8JYaCAPanngcehx2aZTeZgolPPXqG44YgyAcTCKwIPHyZ5gJGCGtpMhCu6VObCHO4Nox3pDEtleVUW0a)OmkqShPMBjMb7SKMwiEDHP5Yo5XfWMPXqG44YgyULygS0sAAH41fMMqfW2JxtBEuXKPXqG44YgyULqDLSKMgdbIJlBGPfIxxy6mxyWhy7ikmnHwoslX0umtrWMaXrttuJWXNl0j0bwIzMBjuFML00cXRlmDMEa)b2oIctJHaXXLnWClH6QBjnTq86ctxe8bCAPanngcehx2aZTeQRmlPPfIxxyAaBSqAftMgdbIJlBG5wc1volPPXqG44YgyAcTCKwIPfIx7W368wMlm4dSDefMwiEDHPZffFXTtm3sO(8wstJHaXXLnW0eA5iTetdXMZngb5aNEmp4O0Frd4crXpDUUF68MwiEDHP510Mhvm9GoUBULqDy1sAAH41fMgfQV9qoYGHlCtJHaXXLnWClH6dNL00yiqCCzdmnHwoslX0qS5CdEfRmlvTNFoY0OiJub4NQ8)uLPKPfIxxyA4vSYSu1E(5iJ5MBA5qlPLyML00yiqCCzdmnHwoslX0qS5CJqfW2JxtBEuXuJT30cXRlmn8kwaNwkqZTeQBjnngcehx2attOLJ0smn4y5qvSAt0Bh(QyxnDuXRl(PWaZpfCSCOkwTCH817Ypi(bahdW0cXRlmDwWNtLaKzb1fMBjuML00yiqCCzdmnHwoslX0qS5CBtkoWpktJT30cXRlmDMEa)b2oIcZTekNL00yiqCCzdmTq86ctN5cd(aBhrHPj0YrAjMMIzkc2eio(th2pDi8tDHJH3YffFXTtAyiqCC9tHbMFQlCm8gxaBvm9YCHbbnmeioU(PWaZpLC7WqcVfiHE8JU(PWEttuJWXNl0j0bwIzMBjM3sAAmeioUSbMwiEDHP7PfZrxLWFWLDOPj0YrAjMEO)ui2CU1tlMJUkH)Gl7WgBVPjQr44Zf6e6alXmZTeWQL00yiqCCzdmnHwoslX0cXRD4BDElZfg8b2oIIF6CD)uLzAH41fMoxu8f3oXClXWzjnTq86ctVdb9i95NJmMgdbIJlBG5wcyNL00yiqCCzdmnHwoslX0qS5CRNwmhDvc)bx2Hn2(F6W(PdHFkeBo3a(rzuGypsBS9)uyG5NcXMZngb5aNEmp4O0Frd4crXpDUUF68)uyVPfIxxyAEnT5rftpOJ7MBjGLwstJHaXXLnW0eA5iTet7chdVrOcyRIPhWpktddbIJRFkmW8tHyZ5gHkGThVM28OIP26GhMwiEDHPjubS9410MhvmzULyMswstJHaXXLnW0cXRlmnx2jpUa2mnHwoslX0UWXWBCbSvX0lZfge0WqG44Y0e1iC85cDcDGLyM5wIzZSKMgdbIJlBGPj0YrAjMgInNBeQa2E8AAZJkMAS9MwiEDHPb(rzaoTuGMBjMPUL00cXRlmnHkGThVM28OIjtJHaXXLnWClXmLzjnngcehx2attOLJ0smneBo3a(rzuGypsBS9MwiEDHPjBsfpEnT5rftMBjMPCwstJHaXXLnW0eA5iTetdXMZngb5aNEmp4O0Frd4crXpDUUF68MwiEDHPjBsfVnHUdbU5wIzZBjnngcehx2attOLJ0smneBo3yeKdC6X8GJs)fnGlef)056(PZBAH41fMg5idgUWFqCb4MBjMbRwstJHaXXLnW0eA5iTetdXMZngb5aNEmp4O0Frd4crXpDUUF68MwiEDHPb(rzuGypsn3smB4SKMgdbIJlBGPj0YrAjMgInNBmcYbo9yEWrP)IgWfIIFA3pDMsMwiEDHPjBsfpEnT5rftMBjMb7SKMgdbIJlBGPfIxxy6mxyWhy7ikmnHwoslX0UWXWB5IIV42jnmeioUmnrnchFUqNqhyjMzULygS0sAAH41fMgWglKwXKPXqG44YgyULqDLSKMgdbIJlBGPfIxxyAUStECbSzAcTCKwIPPSbMp6e26PfJWFCzN8eIZk(rbne2yR(EC9th2pfInNB90Ir4pUStEcXzf)OGgWfIIF6C)uy10e1iC85cDcDGLyM5wc1NzjnTq86ctdVIfWPLc00yiqCCzdm3sOU6wstleVUW0a)OmaNwkqtJHaXXLnWClH6kZsAAH41fMMl7KhxaBMgdbIJlBG5wc1volPPXqG44YgyAH41fMoZfg8b2oIcttOLJ0smnfZueSjqC00e1iC85cDcDGLyM5wc1N3sAAH41fMol4ZPsaYSG6ctJHaXXLnWClH6WQL00cXRlmDMEa)b2oIctJHaXXLnWClH6dNL00cXRlmDrWhWPLc00yiqCCzdm3sOoSZsAAmeioUSbMMqlhPLyAi2CUXiih40J5bhL(lAaxik(PZ19tN30cXRlmnztQ4XRPnpQyYClH6WslPPXqG44YgyAcTCKwIPfIx7W368wMlm4dSDef)05(PZmTq86ctNlk(IBNyULqzkzjnTq86ctJc13W4b6lfOPXqG44YgyULqzZSKMwiEDHPrH6BpKJmy4c30yiqCCzdm3sOm1TKMgdbIJlBGPj0YrAjMgInNBWRyLzPQ98ZrMgfzKka)uL)NQmLmTq86ctdVIvMLQ2Zphzm3CtVWSWYDlPLyML00cXRlmne)UfNf4MgdbIJldYClH6wstJHaXXLnW0eA5iTetNRPn)rrgPcWpv5)PWQsMwiEDHP7pVUWClHYSKMwiEDHPHxX6b2qHAAmeioUSbMBjuolPPfIxxyAwa(khzaMgdbIJlBG5wI5TKMgdbIJlBGPj0YrAjMEO)ux4y4nbqWyjbbByiqCC9tHbMFkeBo3eabJLeeSX2)tHbMFk5o(6GhnbqWyjbbBuKrQa8tN7NoVsMwiEDHPH43TEzwQAMBjGvlPPXqG44YgyAcTCKwIPh6p1fogEtaemwsqWggcehx)uyG5NcXMZnbqWyjbbBS9MwiEDHPHqkaPkQyYClXWzjnngcehx2attOLJ0sm9q)PUWXWBcGGXscc2WqG446Ncdm)ui2CUjacgljiyJT)Ncdm)uYD81bpAcGGXscc2OiJub4No3pDELmTq86ctNlkcXVBzULa2zjnngcehx2attOLJ0sm9q)PUWXWBcGGXscc2WqG446Ncdm)ui2CUjacgljiyJT)Ncdm)uYD81bpAcGGXscc2OiJub4No3pDELmTq86ctlbbbov4pIW5MBjGLwstJHaXXLnW0eA5iTetp0FQlCm8MaiySKGGnmeioU(PWaZpDO)ui2CUjacgljiyJT30cXRlmnKm9U8ZPfrbWClXmLSKMwiEDHPZiv4pqFrl30yiqCCzdm3smBML00cXRlmTaiySKGGMgdbIJlBG5wIzQBjnngcehx2attOLJ0smnLnW8rNW26oMh8kwGgcBSvFpU(Pd7NcXMZT1Dmp4vSaVfcXMZT1bp(PWaZpfInNBWRyLzPQ98ZrM26GhMwiEDHPHxXkZsv75NJmMBjMPmlPPXqG44YgyAcTCKwIPfIx7WhgitHGFA3pDMPfIxxyAIW5pH41fpEbCtZlG)cHbnnOIjoAULyMYzjnngcehx2attOLJ0smTq8Ah(Wazke8tN7NoZ0cXRlmnr48Nq86IhVaUP5fWFHWGMwo0ClXS5TKMwiEDHPjhB4if40sb(8ZrgtJHaXXLnWClXmy1sAAH41fMgOqTmlvTNFoYyAmeioUSbMBjMnCwstleVUW090Ir4pGtlfOPXqG44YgyU5MUNIKJbsClPLyML00yiqCCzdmnHwoslX0qS5CdEfRmlvThCu6VOrrgPcWpv5)PktjLmTq86ctdVIvMLQ2dok9xyULqDlPPXqG44YgyAcTCKwIPHyZ5wMlmOFXel(GJs)fnkYiva(Pk)pvzkPKPfIxxy6mxyq)Ijw8bhL(lm3sOmlPPXqG44YgyAcTCKwIPHyZ5gVM28OIPhyRq(QrrgPcWpv5)PktjLmTq86ctZRPnpQy6b2kKVm3sOCwstJHaXXLnW0eA5iTetp0FkLnW8rNW26oMh8kwGgcBSvFpU(Pd7NcXMZn4vSYSu1E(5itBDWdtleVUW0WRyLzPQ98ZrgZTeZBjnngcehx2attOLJ0smTlCm8gWpkJce7rAddbIJltleVUW0a)OmkqShPMBU5MEhsb1fwc1vsDLMPUsdNPHl0OIjGPhIm9h1X1pv5(PcXRl(P8c4G2xLPfwF7OMwxmd)MUNE5IJMEi)PWcXMeeKbd)NQ3egj(QgYF6WhsqgiK(tNP0(FQ6kPUsFvFvcXRlaTEksogiX7GxXkZsv7bhL(l2x5oi2CUbVIvMLQ2dok9x0OiJubq5vMsk9vjeVUa06Pi5yGeFC3Omxyq)Ijw8bhL(l2x5oi2CUL5cd6xmXIp4O0FrJImsfaLxzkP0xLq86cqRNIKJbs8XDJ410Mhvm9aBfYx7RCheBo3410Mhvm9aBfYxnkYivauELPKsFvcXRlaTEksogiXh3ncEfRmlvTNFoYSVYDdLYgy(OtyBDhZdEflqdHn2QVhxddInNBWRyLzPQ98ZrM26GhFvcXRlaTEksogiXh3nc4hLrbI9iDFL7CHJH3a(rzuGypsByiqCC9v9vnK)uyHHxiH1X1pf3Hu1(PEXG)uFd)PcXp6pTa)uzNuCbIJTVkH41fGoi(DlolW)QgYF6qmgEqogiX)P9Nxx8tlWpfcZhf)PKJbs8Fkglq7RsiEDbyC3O(ZRl2x5UCnT5pkYivauEyvPVQH8NoedhPu2E)NE5FkraoO9vjeVUamUBe8kwpWgk0VkH41fGXDJyb4RCKb8vjeVUamUBee)U1lZsvBFL7gQlCm8MaiySKGGnmeioUGbgi2CUjacgljiyJThgyi3Xxh8OjacgljiyJImsfG5MxPVkH41fGXDJGqkaPkQyAFL7gQlCm8MaiySKGGnmeioUGbgi2CUjacgljiyJT)RsiEDbyC3OCrri(DR9vUBOUWXWBcGGXscc2WqG44cgyGyZ5MaiySKGGn2EyGHChFDWJMaiySKGGnkYivaMBEL(QeIxxag3nscccCQWFeHZ3x5UH6chdVjacgljiyddbIJlyGbInNBcGGXscc2y7HbgYD81bpAcGGXscc2OiJubyU5v6RsiEDbyC3iiz6D5NtlIcW(k3nux4y4nbqWyjbbByiqCCbdmdfInNBcGGXscc2y7)QeIxxag3nkJuH)a9fT8VkH41fGXDJeabJLee8RsiEDbyC3i4vSYSu1E(5iZ(k3rzdmF0jSTUJ5bVIfOHWgB13JRHbXMZT1Dmp4vSaVfcXMZT1bpGbgi2CUbVIvMLQ2ZphzARdE8vnK)0Hy(NEbxTF6f4pfdKrT9)0EAD0Yv7NMpo)Gd(P(g(tHfbvmXryXFQq86IFkVaE7RsiEDbyC3iIW5pH41fpEb89HWGDGkM44(k3jeV2HpmqMcbDZ(QgYF6WZ4NYWY9QNJ)umqMcb7)P(g(t7P1rlxTFA(48do4N6B4pfwuoew8NkeVU4NYlG3(QeIxxag3nIiC(tiEDXJxaFFimyNC4(k3jeV2HpmqMcbZn7RsiEDbyC3iYXgosboTuGp)CK5RsiEDbyC3iGc1YSu1E(5iZxLq86cW4Ur90Ir4pGtlf4x1x1q(thEZY96N6cDc9FQq86IFApToA5Q9t5fW)QeIxxaAYHDWRybCAPa3x5oi2CUrOcy7XRPnpQyQX2)vjeVUa0Kdh3nkl4ZPsaYSG6I9vUdCSCOkwTj6TdFvSRMoQ41fWad4y5qvSA5c5R3LFq8daogWxLq86cqtoCC3Om9a(dSDef7RCheBo32KId8JY0y7)QeIxxaAYHJ7gL5cd(aBhrXEIAeo(CHoHoOB2(k3rXmfbBcehh2qWfogElxu8f3oPHHaXXfmW4chdVXfWwftVmxyqqddbIJlyGHC7WqcVfiHE8JUG9FvcXRlan5WXDJ6PfZrxLWFWLD4EIAeo(CHoHoOB2(k3nui2CU1tlMJUkH)Gl7WgB)xLq86cqtoCC3OCrXxC7K9vUtiETdFRZBzUWGpW2rumxNY(QeIxxaAYHJ7gTdb9i95NJmFvcXRlan5WXDJ410Mhvm9GoUVVYDqS5CRNwmhDvc)bx2Hn2(HneGyZ5gWpkJce7rAJThgyGyZ5gJGCGtpMhCu6VObCHOyUU5H9FvcXRlan5WXDJiubS9410MhvmTVYDUWXWBeQa2Qy6b8JY0WqG44cgyGyZ5gHkGThVM28OIP26GhFvcXRlan5WXDJ4Yo5XfW2EIAeo(CHoHoOB2(k35chdVXfWwftVmxyqqddbIJRVkH41fGMC44Ura)OmaNwkW9vUdInNBeQa2E8AAZJkMAS9FvcXRlan5WXDJiubS9410Mhvm9vjeVUa0Kdh3nISjv8410MhvmTVYDqS5Cd4hLrbI9iTX2)vjeVUa0Kdh3nISjv82e6oe47RCheBo3yeKdC6X8GJs)fnGlefZ1n)xLq86cqtoCC3iKJmy4c)bXfGVVYDqS5CJrqoWPhZdok9x0aUqumx38FvcXRlan5WXDJa(rzuGyps3x5oi2CUXiih40J5bhL(lAaxikMRB(VkH41fGMC44UrKnPIhVM28OIP9vUdInNBmcYbo9yEWrP)IgWfIIUzk9vjeVUa0Kdh3nkZfg8b2oII9e1iC85cDcDq3S9vUZfogElxu8f3oPHHaXX1xLq86cqtoCC3iaBSqAftFvcXRlan5WXDJ4Yo5XfW2EIAeo(CHoHoOB2(k3rzdmF0jS1tlgH)4Yo5jeNv8JcAiSXw994AyqS5CRNwmc)XLDYtioR4hf0aUqumhS(vjeVUa0Kdh3ncEflGtlf4xLq86cqtoCC3iGFugGtlf4xLq86cqtoCC3iUStECbS9vjeVUa0Kdh3nkZfg8b2oII9e1iC85cDcDq3S9vUJIzkc2eio(vjeVUa0Kdh3nkl4ZPsaYSG6IVkH41fGMC44Urz6b8hy7ik(QeIxxaAYHJ7gve8bCAPa)QeIxxaAYHJ7gr2KkE8AAZJkM2x5oi2CUXiih40J5bhL(lAaxikMRB(VkH41fGMC44Ur5IIV42j7RCNq8Ah(wN3YCHbFGTJOyUzFvcXRlan5WXDJqH6By8a9Lc8RsiEDbOjhoUBekuF7HCKbdx4FvcXRlan5WXDJGxXkZsv75NJm7RCheBo3GxXkZsv75NJmnkYivauELP0x1x1q(t1vmXXFQl0j0)PcXRl(P906OLR2pLxa)RsiEDbObQyIJDWRybCAPa)QeIxxaAGkM444Ur90I5ORs4p4YoCFL7gkeBo36PfZrxLWFWLDyJT)RsiEDbObQyIJJ7gb8JYaCAPa3x5okBG5JoHT1Dmp4vSane2yR(ECnmi2CUTUJ5bVIfOX2)vjeVUa0avmXXXDJiubS9410MhvmTVYDu2aZhDcBR7yEWRybAiSXw994AyqS5CBDhZdEflqJT)RsiEDbObQyIJJ7gve8bCAPa3x5okBG5JoHT1Dmp4vSane2yR(ECnmi2CUTUJ5bVIfOX2)vjeVUa0avmXXXDJYCHbFGTJOyFL7gQxefvm9vjeVUa0avmXXXDJ2HGEK(8ZrMVkH41fGgOIjooUBuMEa)b2oII9vUdInNBBsXb(rzAS9FvcXRlanqftCCC3iuO(ggpqFPa)QeIxxaAGkM444UrzbFovcqMfux8vjeVUa0avmXXXDJ410Mhvm9GoUVVYDqS5Cd4hLrbI9iTX2)vjeVUa0avmXXXDJqoYGHl8hexa((k3bXMZngb5aNEmp4O0Frd4crXCDZ)vjeVUa0avmXXXDJiBsfVnHUdb((k3bXMZngb5aNEmp4O0Frd4crXCDZ)vjeVUa0avmXXXDJ410Mhvm9GoUVVYDqS5CJrqoWPhZdok9x0aUqu0ntPVkH41fGgOIjooUBex2jpUa22x5oi2CUTD(BtIvJThgygcu2aZhDcB90Ir4pUStEcXzf)OGgcBSvFpUggeBo36PfJWFCzN8eIZk(rbnGlefZbRW(VkH41fGgOIjooUBeWpkdWPLc8RsiEDbObQyIJJ7gb8JYOaXEKUVYDqS5CJrqoWPhZdok9x0aUqumx38FvcXRlanqftCCC3iUStECbS9vjeVUa0avmXXXDJiubS9410Mhvm9vjeVUa0avmXXXDJYCHbFGTJOyprnchFUqNqh0nBFL7OyMIGnbIJFvcXRlanqftCCC3Om9a(dSDefFvcXRlanqftCCC3OIGpGtlf4xLq86cqduXehh3ncWglKwX0xLq86cqduXehh3nkxu8f3ozFL7eIx7W368wMlm4dSDefFvcXRlanqftCCC3iEnT5rftpOJ77RCheBo3yeKdC6X8GJs)fnGlefZ1n)xLq86cqduXehh3ncfQV9qoYGHl8VkH41fGgOIjooUBe8kwzwQAp)CKzFL7GyZ5g8kwzwQAp)CKPrrgPcGYRmLm3CZa]] )

end
