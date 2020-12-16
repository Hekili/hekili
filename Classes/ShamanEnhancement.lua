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


    spec:RegisterPack( "Enhancement", 20201216, [[dyeEUaqifv8iPkXMuuvFcivJcijNcirVsrmlG4wkQKyxc9lfPHrs1XuuwMufpdOY0KQuUMQK2MIQ8nfvQXbuLoNuLQ1bKunpGQ6EsL9PkXbLQKKfkv1dbskteibDrPkP(OIkP6KavXkjjZuQsIBQOsk7uq(jqcSuPkj1tj1ufuFvrLKglqcTxk)vvnybomXIb8yetwPUm0MLYNvOrRkoTKxtIMnQUnk2TOFRYWvWXbsz5i9CqtNQRJsBxvQVtcJxrL48KuMpqz)kzBMf20BXrlupQ3J6Z6z28IQ37Q379mZ0UAdOPheIszenDkmOP715JKeKbt30dIA8t2wytdpwkbnTUya1mnaBXDWtAaMEloAH6r9EuFwpZMxu9Ex9EF2CBA4asSq9mpWz6NAVX0am9gHet3lRGED(ijbzW0xb6hHrYLQEzfakejidasxbZahiRGEuVh1nnVGo0cBAyLJC0cBHMzHnTq86stROYn0PLs00ykaCCB9n3c1Jf20ykaCCB9nnHwoslX0ZzfaW2AXbAXC0Dj8Vc5ngzhmTq86stpqlMJUlH)viVrZTqGZcBAmfaoUT(MMqlhPLyAkBITJoIX9DmFfvUHre0yRHbCVcM)kaGT1I77y(kQCdJSdMwiEDPPH(rzGoTuIMBH6nlSPXua4426BAcTCKwIPPSj2o6ig33X8vu5ggrqJTggW9ky(Raa2wlUVJ5ROYnmYoyAH41LMMqf4ZNxJpEw5O5wOxTWMgtbGJBRVPj0YrAjMMYMy7OJyCFhZxrLByebn2Aya3RG5VcayBT4(oMVIk3Wi7GPfIxxA6IGFOtlLO5wO5zHnnMcah3wFttOLJ0sm9CwbEruw5OPfIxxA6gxyWp85ikn3cn3wytleVU00Vr4as)(5iJPXua4426BUfc8AHnnMcah3wFttOLJ0smnaBRfFKId9JYezhmTq86st3Oh0)WNJO0CluVBHnTq86stJc1FW8dhkLOPXua4426BUfAM6wytleVU00nb)ovsyJfwxAAmfaoUT(MBHMnZcBAmfaoUT(MMqlhPLyAa2wlc9JYOeXbKgzhmTq86stZRXhpRC8dCC3Cl0SESWMgtbGJBRVPj0YrAjMgGT1ImcYHo9y(kqz4Yi0fIYvWlDRGxnTq86stJCKbtx4FaUaDZTqZaNf20ykaCCB9nnHwoslX0aSTwKrqo0PhZxbkdxgHUquUcEPBf8QPfIxxAAYJu5)rOVrOBUfAwVzHnnMcah3wFttOLJ0smnaBRfzeKdD6X8vGYWLrOleLRGUvWm1nTq86stZRXhpRC8dCC3Cl0SxTWMgtbGJBRVPj0YrAjMgGT1IpN)FKChzhwbGb2kauTcOSj2o6ighOfJW)C5T8fIZk(rHre0yRHbCVcM)kaGT1Id0Ir4FU8w(cXzf)OWi0fIYvWlRG5TcaLMwiEDPP5YB5Zf4J5wOzZZcBAH41LMg6hLb60sjAAmfaoUT(MBHMn3wytJPaWXT130eA5iTetdW2Argb5qNEmFfOmCze6cr5k4LUvWRMwiEDPPH(rzuI4asn3cnd8AHnTq86stZL3YNlWhtJPaWXT13Cl0SE3cBAH41LMMqf4ZNxJpEw5OPXua4426BUfQh1TWMgtbGJBRVPfIxxA6gxyWp85iknnHwoslX0uSrr4JaWrttuJWXVl0r0HwOzMBH6zMf20cXRlnDJEq)dFoIstJPaWXT13Clup9yHnTq86stxe8dDAPennMcah3wFZTq9aolSPfIxxAAiBUrALJMgtbGJBRV5wOE6nlSPXua4426BAcTCKwIPfIxVX)(8yJlm4h(CeLMwiEDPPBff)59wm3c1ZRwytJPaWXT130eA5iTetdW2Argb5qNEmFfOmCze6cr5k4LUvWRMwiEDPP514JNvo(boUBUfQN5zHnTq86stJc1F(ihzW0fUPXua4426BUfQN52cBAmfaoUT(MMqlhPLyAa2wlQOYDJLQ23phzIuKrQeUca)va4u30cXRlnTIk3nwQAF)CKXCZnTCOf2cnZcBAmfaoUT(MMqlhPLyAa2wlsOc85ZRXhpRCmYoyAH41LMwrLBOtlLO5wOESWMgtbGJBRVPj0YrAjMgESCGk3Xr69g)v(UgpQ41LrmfaoUxbGb2kaESCGk3XwH89)AFa(bHhdmIPaWXTPfIxxA6MGFNkjSXcRln3cbolSPXua4426BAcTCKwIPbyBT4JuCOFuMi7GPfIxxA6g9G(h(CeLMBH6nlSPXua4426BAH41LMUXfg8dFoIsttOLJ0smnfBue(iaCCfm)vaOAf4chtp2kk(Z7TeXua44EfagyRax4y6rUaFQC834cdcJykaCCVcadSva5EJPKEmrc94hDVcaLMMOgHJFxOJOdTqZm3c9Qf20ykaCCB9nTq86stpqlMJUlH)viVrttOLJ0sm9CwbaSTwCGwmhDxc)RqEJr2bttuJWXVl0r0HwOzMBHMNf20ykaCCB9nnHwoslX0cXR34FFESXfg8dFoIYvWlDRaWzAH41LMUvu8N3BXCl0CBHnTq86st)gHdi97NJmMgtbGJBRV5wiWRf20ykaCCB9nnHwoslX0aSTwCGwmhDxc)RqEJr2HvW8xbGQvaaBRfH(rzuI4asJSdRaWaBfaW2Argb5qNEmFfOmCze6cr5k4LUvWRRaqPPfIxxAAEn(4zLJFGJ7MBH6DlSPXua4426BAcTCKwIPDHJPhjub(u54h6hLjIPaWX9kamWwbaSTwKqf4ZNxJpEw5yCFkstleVU00eQaF(8A8XZkhn3cntDlSPXua4426BAH41LMMlVLpxGpMMqlhPLyAx4y6rUaFQC834cdcJykaCCBAIAeo(DHoIo0cnZCl0SzwytJPaWXT130eA5iTetdW2ArcvGpFEn(4zLJr2btleVU00q)OmqNwkrZTqZ6XcBAH41LMMqf4ZNxJpEw5OPXua4426BUfAg4SWMgtbGJBRVPj0YrAjMgGT1Iq)OmkrCaPr2btleVU00KhPYpVgF8SYrZTqZ6nlSPXua4426BAcTCKwIPbyBTiJGCOtpMVcugUmcDHOCf8s3k4vtleVU00KhPY)JqFJq3Cl0SxTWMgtbGJBRVPj0YrAjMgGT1ImcYHo9y(kqz4Yi0fIYvWlDRGxnTq86stJCKbtx4FaUaDZTqZMNf20ykaCCB9nnHwoslX0aSTwKrqo0PhZxbkdxgHUquUcEPBf8QPfIxxAAOFugLioGuZTqZMBlSPXua4426BAcTCKwIPbyBTiJGCOtpMVcugUmcDHOCf0TcMPUPfIxxAAYJu5NxJpEw5O5wOzGxlSPXua4426BAH41LMUXfg8dFoIsttOLJ0smTlCm9yRO4pV3setbGJBttuJWXVl0r0HwOzMBHM17wytleVU00q2CJ0khnnMcah3wFZTq9OUf20ykaCCB9nTq86stZL3YNlWhttOLJ0smnLnX2rhX4aTye(NlVLVqCwXpkmIGgBnmG7vW8xbaSTwCGwmc)ZL3YxioR4hfgHUquUcEzfmpttuJWXVl0r0HwOzMBH6zMf20cXRlnTIk3qNwkrtJPaWXT13Clup9yHnTq86std9JYaDAPennMcah3wFZTq9aolSPfIxxAAU8w(Cb(yAmfaoUT(MBH6P3SWMgtbGJBRVPfIxxA6gxyWp85iknnHwoslX0uSrr4JaWrttuJWXVl0r0HwOzMBH65vlSPfIxxA6MGFNkjSXcRlnnMcah3wFZTq9mplSPfIxxA6g9G(h(CeLMgtbGJBRV5wOEMBlSPfIxxA6IGFOtlLOPXua4426BUfQhWRf20ykaCCB9nnHwoslX0aSTwKrqo0PhZxbkdxgHUquUcEPBf8QPfIxxAAYJu5NxJpEw5O5wOE6DlSPXua4426BAcTCKwIPfIxVX)(8yJlm4h(CeLRGxwbZmTq86st3kk(Z7TyUfcCQBHnTq86stJc1FW8dhkLOPXua4426BUfcCZSWMwiEDPPrH6pFKJmy6c30ykaCCB9n3cbUESWMgtbGJBRVPj0YrAjMgGT1IkQC3yPQ99ZrMifzKkHRaWFfao1nTq86stROYDJLQ23phzm3CtVXMWYDlSfAMf20cXRlnna)UnNf6MgtbGJBdWClupwytJPaWXT130eA5iTet3QXh)trgPs4ka8xbZtDtleVU00dNxxAUfcCwytleVU00kQC)HpOqnnMcah3wFZTq9Mf20cXRlnnle)LJmqtJPaWXT13Cl0RwytJPaWXT130eA5iTetpNvGlCm9OajyULKGrmfaoUxbGb2kaGT1IcKG5wscgzhwbGb2kGChFFkYOajyULKGrkYivcxbVScEvDtleVU00a872)glvnZTqZZcBAmfaoUT(MMqlhPLy65ScCHJPhfibZTKemIPaWX9kamWwbaSTwuGem3ssWi7GPfIxxAAaKcrQYkhn3cn3wytJPaWXT130eA5iTetpNvGlCm9OajyULKGrmfaoUxbGb2kaGT1IcKG5wscgzhwbGb2kGChFFkYOajyULKGrkYivcxbVScEvDtleVU00TIIa872MBHaVwytJPaWXT130eA5iTetpNvGlCm9OajyULKGrmfaoUxbGb2kaGT1IcKG5wscgzhwbGb2kGChFFkYOajyULKGrkYivcxbVScEvDtleVU00ssqOtf(NiCU5wOE3cBAmfaoUT(MMqlhPLy65ScCHJPhfibZTKemIPaWX9kamWwbZzfaW2ArbsWCljbJSdMwiEDPPbKX)1(oTikHMBHMPUf20cXRlnDdPc)dhkA5MgtbGJBRV5wOzZSWMwiEDPPfibZTKe00ykaCCB9n3cnRhlSPXua4426BAcTCKwIPPSj2o6ig33X8vu5ggrqJTggW9ky(Raa2wlUVJ5ROYn8Vra2wlUpf5kamWwbaSTwurL7glvTVFoYe3NI00cXRlnTIk3nwQAF)CKXCl0mWzHnnMcah3wFttOLJ0smTq86n(XezkeUc6wbZmTq86stteo)leVU8ZlOBAEb9FkmOPHvoYrZTqZ6nlSPXua4426BAcTCKwIPfIxVXpMitHWvWlRGzMwiEDPPjcN)fIxx(5f0nnVG(pfg00YHMBHM9Qf20cXRlnn5ythPqNwkXVFoYyAmfaoUT(MBHMnplSPfIxxAAOs1ASu1((5iJPXua4426BUfA2CBHnTq86stpqlgH)HoTuIMgtbGJBRV5MB6bksogaXTWwOzwytJPaWXT130eA5iTetdW2ArfvUBSu1(kqz4YifzKkHRaWFfao1v30cXRlnTIk3nwQAFfOmCP5wOESWMgtbGJBRVPj0YrAjMgGT1InUWG(LJS4xbkdxgPiJujCfa(RaWPU6MwiEDPPBCHb9lhzXVcugU0Cle4SWMwiEDPPbo354(34IA4wrLJF)MlvAAmfaoUT(MBH6nlSPXua4426BAcTCKwIPbyBTiVgF8SYXp8Pq(osrgPs4ka8xbGtD1nTq86stZRXhpRC8dFkKVn3c9Qf20ykaCCB9nnHwoslX0ZzfqztSD0rmUVJ5ROYnmIGgBnmG7vW8xbaSTwurL7glvTVFoYe3NI00cXRlnTIk3nwQAF)CKXCl08SWMgtbGJBRVPj0YrAjM2foMEe6hLrjIdinIPaWXTPfIxxAAOFugLioGuZn3Ct)gPW6slupQ3J6Z6zg4mTcHMvocn9C1Ev9QdbEcnxhuFfScc)GRGIz4O(kOD0vaOlhc6RakcASff3Ra4XGRaH1pgXX9kG8i5icJlv9kvIRGEa1xbGAx(gPoUxbGo8y5avUJGIG(kWVvaOdpwoqL7iOyetbGJBqFfaQMnxaLXLQELkXvqpG6RaqTlFJuh3RaqhESCGk3rqrqFf43ka0HhlhOYDeumIPaWXnOVceFf0Rbf0RScavZMlGY4s1sf4Hz4OoUxb92kqiED5kGxqhgxQmTW6ph106IbuZ0d0RvC009YkOxNpssqgm9vG(ryKCPQxwbGcrcYaG0vWmWbYkOh17r9LQLkH41LW4afjhdG4DkQC3yPQ9vGYWLGuToa2wlQOYDJLQ2xbkdxgPiJuje8bN6QVujeVUeghOi5yaeFs30gxyq)Yrw8RaLHlbPADaSTwSXfg0VCKf)kqz4YifzKkHGp4ux9LkH41LW4afjhdG4t6McCUZX9VXf1WTIkh)(nxQCPsiEDjmoqrYXai(KUP8A8XZkh)WNc5BqQwhaBRf514JNvo(HpfY3rkYivcbFWPU6lvcXRlHXbksogaXN0nvrL7glvTVFoYas16MdLnX2rhX4(oMVIk3WicAS1WaUNpaBRfvu5UXsv77NJmX9PixQeIxxcJduKCmaIpPBk0pkJsehqkivRZfoMEe6hLrjIdinIPaWX9s1svVSc61ZfKW64EfGVrQARaVyWvG)GRaH4hDfuWvG8wkUaWX4sLq86syha)UnNf6lv9Yka8KZvihdG4RGHZRlxbfCfaGTJIRaYXai(kaZnmUujeVUeoPB6W51LGuTUwn(4FkYivcb)5P(svVScapPJuk7GVcU2kGiqhgxQeIxxcN0nvrL7p8bf6sLq86s4KUPSq8xoYaxQeIxxcN0nfGF3(3yPQbs16MJlCm9OajyULKGrmfaoUbdma2wlkqcMBjjyKDamWi3X3NImkqcMBjjyKImsLWxEv9LkH41LWjDtbqkePkRCeKQ1nhx4y6rbsWCljbJykaCCdgyaSTwuGem3ssWi7WsLq86s4KUPTIIa872GuTU54chtpkqcMBjjyetbGJBWadGT1IcKG5wscgzhadmYD89PiJcKG5wscgPiJuj8LxvFPsiEDjCs3ujji0Pc)teohKQ1nhx4y6rbsWCljbJykaCCdgyaSTwuGem3ssWi7ayGrUJVpfzuGem3ssWifzKkHV8Q6lvcXRlHt6MciJ)R9DArucbPADZXfoMEuGem3ssWiMcah3Gb2CayBTOajyULKGr2HLkH41LWjDtBiv4F4qrlFPsiEDjCs3ubsWCljbxQeIxxcN0nvrL7glvTVFoYas16OSj2o6ig33X8vu5ggrqJTggW98byBT4(oMVIk3W)gbyBT4(uKGbgaBRfvu5UXsv77NJmX9PixQ6Lva4PTcUKR2k4sCfGjYOgiRGbAD0YvBf0oo)uaxb(dUcaDyLJCe0xbcXRlxb8c6XLkH41LWjDtjcN)fIxx(5f0bjfgSdw5ihbPADcXR34htKPqy3SLQEzfakixbmSCVg44katKPqiiRa)bxbd06OLR2kODC(PaUc8hCfa6YHG(kqiED5kGxqpUujeVUeoPBkr48Vq86YpVGoiPWGDYHGuToH41B8JjYui8LzlvcXRlHt6Mso20rk0PLs87NJmlvcXRlHt6McvQwJLQ23phzwQeIxxcN0nDGwmc)dDAPexQwQ6LvWCnwUxRaxOJOVceIxxUcgO1rlxTvaVG(sLq86syuoStrLBOtlLiivRdGT1IeQaF(8A8XZkhJSdlvcXRlHr5WjDtBc(DQKWglSUeKQ1bpwoqL74i9EJ)kFxJhv86sWadESCGk3XwH89)AFa(bHhdCPsiEDjmkhoPBAJEq)dFoIsqQwhaBRfFKId9JYezhwQeIxxcJYHt6M24cd(Hphrjie1iC87cDeDy3mqQwhfBue(iaCC(Gkx4y6XwrXFEVLiMcah3GbMlCm9ixGpvo(BCHbHrmfaoUbdmY9gtj9yIe6Xp6guUujeVUegLdN0nDGwmhDxc)RqEJGquJWXVl0r0HDZaPADZbGT1Id0I5O7s4FfYBmYoSujeVUegLdN0nTvu8N3BbKQ1jeVEJ)95XgxyWp85ikFPdClvcXRlHr5WjDtFJWbK(9ZrMLkH41LWOC4KUP8A8XZkh)ah3bPADaSTwCGwmhDxc)RqEJr2H5dQayBTi0pkJsehqAKDamWayBTiJGCOtpMVcugUmcDHO8LUxbLlvcXRlHr5WjDtjub(8514JNvocs16CHJPhjub(u54h6hLjIPaWXnyGbW2ArcvGpFEn(4zLJX9PixQeIxxcJYHt6MYL3YNlWhqiQr443f6i6WUzGuTox4y6rUaFQC834cdcJykaCCVujeVUegLdN0nf6hLb60sjcs16ayBTiHkWNpVgF8SYXi7WsLq86syuoCs3ucvGpFEn(4zLJlvcXRlHr5WjDtjpsLFEn(4zLJGuToa2wlc9JYOeXbKgzhwQeIxxcJYHt6MsEKk)pc9ncDqQwhaBRfzeKdD6X8vGYWLrOleLV096sLq86syuoCs3uKJmy6c)dWfOds16ayBTiJGCOtpMVcugUmcDHO8LUxxQeIxxcJYHt6Mc9JYOeXbKcs16ayBTiJGCOtpMVcugUmcDHO8LUxxQeIxxcJYHt6MsEKk)8A8XZkhbPADaSTwKrqo0PhZxbkdxgHUqu2nt9LkH41LWOC4KUPnUWGF4Zruccrnch)Uqhrh2ndKQ15chtp2kk(Z7TeXua44EPsiEDjmkhoPBkKn3iTYXLkH41LWOC4KUPC5T85c8beIAeo(DHoIoSBgivRJYMy7OJyCGwmc)ZL3YxioR4hfgrqJTggW98byBT4aTye(NlVLVqCwXpkmcDHO8L5TujeVUegLdN0nvrLBOtlL4sLq86syuoCs3uOFugOtlL4sLq86syuoCs3uU8w(Cb(SujeVUegLdN0nTXfg8dFoIsqiQr443f6i6WUzGuTok2Oi8ra44sLq86syuoCs30MGFNkjSXcRlxQeIxxcJYHt6M2Oh0)WNJOCPsiEDjmkhoPBArWp0PLsCPsiEDjmkhoPBk5rQ8ZRXhpRCeKQ1bW2Argb5qNEmFfOmCze6cr5lDVUujeVUegLdN0nTvu8N3BbKQ1jeVEJ)95XgxyWp85ikFz2sLq86syuoCs3uuO(dMF4qPexQeIxxcJYHt6MIc1F(ihzW0f(sLq86syuoCs3ufvUBSu1((5idivRdGT1IkQC3yPQ99ZrMifzKkHGp4uFPAPQxwb6kh54kWf6i6RaH41LRGbAD0YvBfWlOVujeVUegHvoYXofvUHoTuIlvcXRlHryLJCCs30bAXC0Dj8Vc5ncs16MdaBRfhOfZr3LW)kK3yKDyPsiEDjmcRCKJt6Mc9JYaDAPebPADu2eBhDeJ77y(kQCdJiOXwdd4E(aSTwCFhZxrLByKDyPsiEDjmcRCKJt6MsOc85ZRXhpRCeKQ1rztSD0rmUVJ5ROYnmIGgBnmG75dW2AX9DmFfvUHr2HLkH41LWiSYrooPBArWp0PLseKQ1rztSD0rmUVJ5ROYnmIGgBnmG75dW2AX9DmFfvUHr2HLkH41LWiSYrooPBAJlm4h(CeLGuTU54frzLJlvcXRlHryLJCCs303iCaPF)CKzPsiEDjmcRCKJt6M2Oh0)WNJOeKQ1bW2AXhP4q)Omr2HLkH41LWiSYrooPBkku)bZpCOuIlvcXRlHryLJCCs30MGFNkjSXcRlxQeIxxcJWkh54KUP8A8XZkh)ah3bPADaSTwe6hLrjIdinYoSujeVUegHvoYXjDtroYGPl8paxGoivRdGT1ImcYHo9y(kqz4Yi0fIYx6EDPsiEDjmcRCKJt6MsEKk)pc9ncDqQwhaBRfzeKdD6X8vGYWLrOleLV096sLq86syew5ihN0nLxJpEw54h44oivRdGT1ImcYHo9y(kqz4Yi0fIYUzQVujeVUegHvoYXjDt5YB5Zf4divRdGT1IpN)FKChzhadmqfLnX2rhX4aTye(NlVLVqCwXpkmIGgBnmG75dW2AXbAXi8pxElFH4SIFuye6cr5lZduUujeVUegHvoYXjDtH(rzGoTuIlvcXRlHryLJCCs3uOFugLioGuqQwhaBRfzeKdD6X8vGYWLrOleLV096sLq86syew5ihN0nLlVLpxGplvcXRlHryLJCCs3ucvGpFEn(4zLJlvcXRlHryLJCCs30gxyWp85ikbHOgHJFxOJOd7Mbs16OyJIWhbGJlvcXRlHryLJCCs30g9G(h(CeLlvcXRlHryLJCCs30IGFOtlL4sLq86syew5ihN0nfYMBKw54sLq86syew5ihN0nTvu8N3BbKQ1jeVEJ)95XgxyWp85ikxQeIxxcJWkh54KUP8A8XZkh)ah3bPADaSTwKrqo0PhZxbkdxgHUqu(s3RlvcXRlHryLJCCs3uuO(Zh5idMUWxQeIxxcJWkh54KUPkQC3yPQ99ZrgqQwhaBRfvu5UXsv77NJmrkYivcbFWPU5MBg]] )

end
