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


    spec:RegisterPack( "Enhancement", 20201213, [[d8ZITaWBvEnjAtkszxszBkQY(uu5tksvDEsWSr18bs3urQK(LI4BkQQoTODssTxk7wy)QYpvKkXWKGgNIQY5iHsltcmyjA4svhsrsNIekoMIYXjHyHkWHjwmGLJ0djHeEkPEmINdAIksLAQsOjRKPt1fvKQ8kf0ZuvvxhL(Rs9ifjSzjTDvvUm0SaIPPirZJeQ(oq9zfA0QkJNes6Kksf3Ies01uvL7jvwjj52OyuKqQTzwrtVehn1fuybfoRGz)3M9)S5RG5zAxHE009crPmIMoeg00tV4tccYGHB6Erb(jlROPHhlLGMwNmkkmnaBY9PtyaMEjoAQlOWckCwbZ(Vn7)zZxbfyAypsm1fmV)n9xUwyyaMEHqIPNIx50l(KGGmy4Vs9NWiXt1u8kNUrcYaG0x5S)b5vwqHfuOP5j0HwrtdZyKJwrt9mROPfINxyAWzSGonvIMgdbGJlBG5M6cSIMgdbGJlBGPj00rAkMEQVsa2AT1ttMJUsHVbl)WgBVPfINxy6EAYC0vk8ny5hAUP(FROPXqa44YgyAcnDKMIPPSbwp6i2w3XSbNXc2qfHn77X1RCAVsa2ATTUJzdoJfSX2BAH45fMg6hLb60ujAUPEkTIMgdbGJlBGPj00rAkMMYgy9OJyBDhZgCglydve2SVhxVYP9kbyR126oMn4mwWgBVPfINxyAcvGFBEo(5rgJMBQ)ZkAAmeaoUSbMMqthPPyAkBG1JoIT1DmBWzSGnuryZ(EC9kN2ReGTwBR7y2GZybBS9MwiEEHPtcUHonvIMBQNNv00yiaCCzdmnHMostX0t9v6jrzgJMwiEEHPRCHb3WVJO0Ct98BfnTq88ct)dH9iD7NJmMgdbGJlBG5M65ZkAAmeaoUSbMMqthPPyAa2AT9jjh6hLPX2BAH45fMUspOVHFhrP5MAfRv00cXZlmnku)dJnSpvIMgdbGJlBG5M6zfAfnTq88ctxfC7ujGvwyEHPXqa44YgyUPE2mROPXqa44YgyAcnDKMIPbyR1g0pkJse7rAJT30cXZlmnph)8iJXnWXDZn1ZkWkAAmeaoUSbMMqthPPyAa2ATXiih60JzdgL(lAqxikFLZ19k)Z0cXZlmnYrgmCHVb4c0n3up7FROPXqa44YgyAcnDKMIPbyR1gJGCOtpMnyu6VObDHO8vox3R8ptlepVW0KpjJ9Nq)Hq3Ct9SP0kAAmeaoUSbMMqthPPyAa2ATXiih60JzdgL(lAqxikFLDVYzfAAH45fMMNJFEKX4g44U5M6z)zfnngcahx2attOPJ0umnaBT2(oF)jXQX2)kbf0xPI(vszdSE0rS1ttgHV5YpzleNv8JcBOIWM9946voTxjaBT26PjJW3C5NSfIZk(rHnOleLVY5ELZ7vQymTq88ctZLFYMlWpZn1ZMNv00cXZlmn0pkd0PPs00yiaCCzdm3upB(TIMgdbGJlBGPj00rAkMgGTwBmcYHo9y2GrP)Ig0fIYx5CDVY)mTq88ctd9JYOeXEKAUPE28zfnTq88ctZLFYMlWptJHaWXLnWCt9mfRv00cXZlmnHkWVnph)8iJrtJHaWXLnWCtDbfAfnngcahx2atlepVW0vUWGB43ruAAcnDKMIPPyLIWpbGJMMOaHJBxOJOdn1Zm3uxWmROPfINxy6k9G(g(DeLMgdbGJlBG5M6ckWkAAH45fMoj4g60ujAAmeaoUSbMBQl4FROPfINxyAiBSqAgJMgdbGJlBG5M6cMsROPXqa44YgyAcnDKMIPfIN)W968wLlm4g(DeLMwiEEHPRjf3X9tm3uxWFwrtJHaWXLnW0eA6inftdWwRngb5qNEmBWO0Frd6cr5RCUUx5FMwiEEHP554NhzmUboUBUPUG5zfnTq88ctJc1)2ihzWWfUPXqa44YgyUPUG53kAAmeaoUSbMMqthPPyAa2ATboJvLLQW2phzAuKrYa(kv8x5)fAAH45fMgCgRklvHTFoYyU5Mwo0kAQNzfnngcahx2attOPJ0umnaBT2iub(T554Nhzm2y7nTq88ctdoJf0PPs0CtDbwrtJHaWXLnW0eA6inftdpwoqgR2i9(H7m(LJhv88IxjOG(kHhlhiJvRMiFTV6gGFq4XanTq88ctxfC7ujGvwyEH5M6)TIMgdbGJlBGPj00rAkMgGTwBFsYH(rzAS9MwiEEHPR0d6B43ruAUPEkTIMgdbGJlBGPfINxy6kxyWn87iknnHMostX0uSsr4NaWXx50ELk6xPlCm8wnP4oUFsddbGJRxjOG(kDHJH34c8lJXDLlmiSHHaWX1ReuqFLK7hgs4Taj0JF01RuXyAIceoUDHoIo0upZCt9FwrtJHaWXLnW0cXZlmDpnzo6kf(gS8dnnHMostX0t9vcWwRTEAYC0vk8ny5h2y7nnrbch3UqhrhAQNzUPEEwrtJHaWXLnW0eA6inftlep)H715TkxyWn87ikFLZ19k)30cXZlmDnP4oUFI5M653kAAH45fM(hc7r62phzmngcahx2aZn1ZNv00yiaCCzdmnHMostX0aS1ARNMmhDLcFdw(Hn2(x50ELk6xjaBT2G(rzuIypsBS9Vsqb9vcWwRngb5qNEmBWO0Frd6cr5RCUUx5FVsfJPfINxyAEo(5rgJBGJ7MBQvSwrtJHaWXLnW0eA6inft7chdVrOc8lJXn0pktddbGJRxjOG(kbyR1gHkWVnph)8iJX26ahMwiEEHPjub(T554NhzmAUPEwHwrtJHaWXLnW0cXZlmnx(jBUa)mnHMostX0UWXWBCb(LX4UYfge2Wqa44Y0efiCC7cDeDOPEM5M6zZSIMgdbGJlBGPj00rAkMgGTwBeQa)28C8ZJmgBS9MwiEEHPH(rzGonvIMBQNvGv00cXZlmnHkWVnph)8iJrtJHaWXLnWCt9S)TIMgdbGJlBGPj00rAkMgGTwBq)OmkrShPn2EtlepVW0KpjJnph)8iJrZn1ZMsROPXqa44YgyAcnDKMIPbyR1gJGCOtpMnyu6VObDHO8vox3R8ptlepVW0KpjJ9Nq)Hq3Ct9S)SIMgdbGJlBGPj00rAkMgGTwBmcYHo9y2GrP)Ig0fIYx5CDVY)mTq88ctJCKbdx4BaUaDZn1ZMNv00yiaCCzdmnHMostX0aS1AJrqo0PhZgmk9x0GUqu(kNR7v(NPfINxyAOFugLi2JuZn1ZMFROPXqa44YgyAcnDKMIPbyR1gJGCOtpMnyu6VObDHO8v29kNvOPfINxyAYNKXMNJFEKXO5M6zZNv00yiaCCzdmTq88ctx5cdUHFhrPPj00rAkM2fogERMuCh3pPHHaWXLPjkq442f6i6qt9mZn1ZuSwrtlepVW0q2yH0mgnngcahx2aZn1fuOv00yiaCCzdmTq88ctZLFYMlWpttOPJ0umnLnW6rhXwpnze(Ml)KTqCwXpkSHkcB23JRx50ELaS1ARNMmcFZLFYwioR4hf2GUqu(kN7vopttuGWXTl0r0HM6zMBQlyMv00cXZlmn4mwqNMkrtJHaWXLnWCtDbfyfnTq88ctd9JYaDAQenngcahx2aZn1f8Vv00cXZlmnx(jBUa)mngcahx2aZn1fmLwrtJHaWXLnW0cXZlmDLlm4g(DeLMMqthPPyAkwPi8ta4OPjkq442f6i6qt9mZn1f8Nv00cXZlmDvWTtLawzH5fMgdbGJlBG5M6cMNv00cXZlmDLEqFd)oIstJHaWXLnWCtDbZVv00cXZlmDsWn0PPs00yiaCCzdm3uxW8zfnngcahx2attOPJ0umnaBT2yeKdD6XSbJs)fnOleLVY56EL)zAH45fMM8jzS554NhzmAUPUafRv00yiaCCzdmnHMostX0cXZF4EDERYfgCd)oIYx5CVYzMwiEEHPRjf3X9tm3u)FHwrtlepVW0Oq9pm2W(ujAAmeaoUSbMBQ)FMv00cXZlmnku)BJCKbdx4MgdbGJlBG5M6)lWkAAmeaoUSbMMqthPPyAa2ATboJvLLQW2phzAuKrYa(kv8x5)fAAH45fMgCgRklvHTFoYyU5MEHvHL7wrt9mROPfINxyAa(Dlol0nngcahxgG5M6cSIMgdbGJlBGPj00rAkMUMJF(MImsgWxPI)kNxHMwiEEHP7ppVWCt9)wrtlepVW0GZyTHFOqnngcahx2aZn1tPv00cXZlmnle3PJmqtJHaWXLnWCt9FwrtJHaWXLnW0eA6inftp1xPlCm8MajySKGGnmeaoUELGc6ReGTwBcKGXscc2y7FLGc6RKChFDGJMajySKGGnkYizaFLZ9k)RqtlepVW0a87w7klvbZn1ZZkAAmeaoUSbMMqthPPy6P(kDHJH3eibJLeeSHHaWX1ReuqFLaS1AtGemwsqWgBVPfINxyAaKcrQYmgn3up)wrtJHaWXLnW0eA6inftp1xPlCm8MajySKGGnmeaoUELGc6ReGTwBcKGXscc2y7FLGc6RKChFDGJMajySKGGnkYizaFLZ9k)RqtlepVW01KIa87wMBQNpROPXqa44YgyAcnDKMIPN6R0fogEtGemwsqWggcahxVsqb9vcWwRnbsWyjbbBS9Vsqb9vsUJVoWrtGemwsqWgfzKmGVY5EL)vOPfINxyAjii0PcFteo3CtTI1kAAmeaoUSbMMqthPPy6P(kDHJH3eibJLeeSHHaWX1ReuqFLt9vcWwRnbsWyjbbBS9MwiEEHPbKX9v3onjkHMBQNvOv00cXZlmDfPcFd7tA6MgdbGJlBG5M6zZSIMwiEEHPfibJLee00yiaCCzdm3upRaROPXqa44YgyAcnDKMIPPSbwp6i2w3XSbNXc2qfHn77X1RCAVsa2ATTUJzdoJfCVqa2ATToWXReuqFLaS1AdCgRklvHTFoY0wh4W0cXZlmn4mwvwQcB)CKXCt9S)TIMgdbGJlBGPj00rAkMwiE(d3yGmjcFLDVYzMwiEEHPjcNVfINxS5j0nnpH(oeg00Wmg5O5M6ztPv00yiaCCzdmnHMostX0cXZF4gdKjr4RCUx5mtlepVW0eHZ3cXZl28e6MMNqFhcdAA5qZn1Z(ZkAAH45fMMCSHJuOttL42phzmngcahx2aZn1ZMNv00cXZlmnuPcvwQcB)CKX0yiaCCzdm3upB(TIMwiEEHP7PjJW3qNMkrtJHaWXLnWCZnDpfjhdG4wrt9mROPXqa44YgyAcnDKMIPbyR1g4mwvwQcBWO0FrJImsgWxPI)k)VWcnTq88ctdoJvLLQWgmk9xyUPUaROPXqa44YgyAcnDKMIPbyR1wLlmOFXilUbJs)fnkYizaFLk(R8)cl00cXZlmDLlmOFXilUbJs)fMBQ)3kAAH45fMg4CNJRDLlkGlWzmU9trndtJHaWXLnWCt9uAfnngcahx2attOPJ0umnaBT2454NhzmUHFjYxnkYizaFLk(R8)cl00cXZlmnph)8iJXn8lr(YCt9FwrtJHaWXLnW0eA6inftp1xjLnW6rhX26oMn4mwWgQiSzFpUELt7vcWwRnWzSQSuf2(5itBDGdtlepVW0GZyvzPkS9ZrgZn1ZZkAAmeaoUSbMMqthPPyAx4y4nOFugLi2J0ggcahxMwiEEHPH(rzuIypsn3CZn9pKcZlm1fuybfoRGzfAAWcnYyeA6Pdt)rDC9kNYxPq88IxjpHoS9uzAH1)oQP1jJIct3tVAYrtpfVYPx8jbbzWWFL6pHrINQP4voDJeKbaPVYz)dYRSGclOWNQNkH45fWwpfjhdG4DGZyvzPkSbJs)fGK1oa2ATboJvLLQWgmk9x0OiJKbuX)VWcFQeINxaB9uKCmaIpSBsLlmOFXilUbJs)fGK1oa2ATv5cd6xmYIBWO0FrJImsgqf))cl8PsiEEbS1trYXai(WUjaN7CCTRCrbCboJXTFkQz8ujepVa26Pi5yaeFy3eEo(5rgJB4xI8fizTdGTwB8C8ZJmg3WVe5RgfzKmGk()fw4tLq88cyRNIKJbq8HDtaNXQYsvy7NJmGK1UPszdSE0rSTUJzdoJfSHkcB23JRPbWwRnWzSQSuf2(5itBDGJNkH45fWwpfjhdG4d7Ma9JYOeXEKcsw7CHJH3G(rzuIypsByiaCC9u9unfVYPNIksyDC9kXFivHxPNm4R0)WxPq8J(kt4Ru(jjxa4y7PsiEEbSdGF3IZc9NQP4voDcfLKJbq8xz)55fVYe(kbW6rXxj5yae)vIXc2EQeINxah2nP)88cqYAxnh)8nfzKmGk(8k8PAkELtNWrkLT3FLx9vseOdBpvcXZlGd7MaoJ1g(Hc9PsiEEbCy3ewiUthzGpvcXZlGd7MaWVBTRSufajRDt1fogEtGemwsqWggcahxGckaBT2eibJLeeSX2dkOK74RdC0eibJLeeSrrgjd4C)v4tLq88c4WUjaifIuLzmcsw7MQlCm8MajySKGGnmeaoUafua2ATjqcgljiyJT)PsiEEbCy3KAsra(DlqYA3uDHJH3eibJLeeSHHaWXfOGcWwRnbsWyjbbBS9Gck5o(6ahnbsWyjbbBuKrYao3Ff(ujepVaoSBIeee6uHVjcNdsw7MQlCm8MajySKGGnmeaoUafua2ATjqcgljiyJThuqj3Xxh4OjqcgljiyJImsgW5(RWNkH45fWHDtaKX9v3onjkHGK1UP6chdVjqcgljiyddbGJlqbDQaS1AtGemwsqWgB)tLq88c4WUjvKk8nSpPP)ujepVaoSBIajySKGGpvcXZlGd7MaoJvLLQW2phzajRDu2aRhDeBR7y2GZybBOIWM994AAaS1ABDhZgCgl4EHaS1ABDGdqbfGTwBGZyvzPkS9ZrM26ahpvtXRC6uFLxWv4vEb(kXazuaKxzpnpA6k8kRhNFGHVs)dFLtFygJCC6)kfINx8k5j0BpvcXZlGd7MqeoFlepVyZtOdsimyhmJrocsw7eIN)WngitIWUzpvtXRC6s8kzy5E2ZXxjgitIqqEL(h(k7P5rtxHxz948dm8v6F4RC6lho9FLcXZlEL8e6TNkH45fWHDticNVfINxS5j0bjegStoeKS2jep)HBmqMeHZn7PsiEEbCy3eYXgosHonvIB)CK5PsiEEbCy3eOsfQSuf2(5iZtLq88c4WUj90Kr4BOttL4t1t1u8kNUYY98v6cDe9xPq88IxzpnpA6k8k5j0FQeINxaBYHDGZybDAQebjRDaS1AJqf43MNJFEKXyJT)PsiEEbSjhoSBsvWTtLawzH5fGK1o4XYbYy1gP3pCNXVC8OINxakOWJLdKXQvtKV2xDdWpi8yGpvcXZlGn5WHDtQ0d6B43rucsw7ayR12NKCOFuMgB)tLq88cytoCy3KkxyWn87ikbHOaHJBxOJOd7Mbsw7OyLIWpbGJttr7chdVvtkUJ7N0Wqa44cuqDHJH34c8lJXDLlmiSHHaWXfOGsUFyiH3cKqp(rxkMNkH45fWMC4WUj90K5ORu4BWYpeeIceoUDHoIoSBgizTBQaS1ARNMmhDLcFdw(Hn2(NkH45fWMC4WUj1KI74(jGK1oH45pCVoVv5cdUHFhr5CD))ujepVa2Kdh2n5hc7r62phzEQeINxaBYHd7MWZXppYyCdCChKS2bWwRTEAYC0vk8ny5h2y7NMIgGTwBq)OmkrShPn2EqbfGTwBmcYHo9y2GrP)Ig0fIY56(tX8ujepVa2Kdh2nHqf43MNJFEKXiizTZfogEJqf4xgJBOFuMggcahxGckaBT2iub(T554Nhzm2wh44PsiEEbSjhoSBcx(jBUa)aHOaHJBxOJOd7Mbsw7CHJH34c8lJXDLlmiSHHaWX1tLq88cytoCy3eOFugOttLiizTdGTwBeQa)28C8ZJmgBS9pvcXZlGn5WHDtiub(T554Nhzm(ujepVa2Kdh2nH8jzS554Nhzmcsw7ayR1g0pkJse7rAJT)PsiEEbSjhoSBc5tYy)j0Fi0bjRDaS1AJrqo0PhZgmk9x0GUquox3FpvcXZlGn5WHDtqoYGHl8naxGoizTdGTwBmcYHo9y2GrP)Ig0fIY56(7PsiEEbSjhoSBc0pkJse7rkizTdGTwBmcYHo9y2GrP)Ig0fIY56(7PsiEEbSjhoSBc5tYyZZXppYyeKS2bWwRngb5qNEmBWO0Frd6crz3ScFQeINxaBYHd7Mu5cdUHFhrjiefiCC7cDeDy3mqYANlCm8wnP4oUFsddbGJRNkH45fWMC4WUjq2yH0mgFQeINxaBYHd7MWLFYMlWpqikq442f6i6WUzGK1okBG1JoITEAYi8nx(jBH4SIFuydve2SVhxtdGTwB90Kr4BU8t2cXzf)OWg0fIY5M3tLq88cytoCy3eWzSGonvIpvcXZlGn5WHDtG(rzGonvIpvcXZlGn5WHDt4YpzZf43tLq88cytoCy3KkxyWn87ikbHOaHJBxOJOd7Mbsw7OyLIWpbGJpvcXZlGn5WHDtQcUDQeWklmV4PsiEEbSjhoSBsLEqFd)oIYNkH45fWMC4WUjjb3qNMkXNkH45fWMC4WUjKpjJnph)8iJrqYAhaBT2yeKdD6XSbJs)fnOleLZ193tLq88cytoCy3KAsXDC)eqYANq88hUxN3QCHb3WVJOCUzpvcXZlGn5WHDtqH6FySH9Ps8PsiEEbSjhoSBcku)BJCKbdx4pvcXZlGn5WHDtaNXQYsvy7NJmGK1oa2ATboJvLLQW2phzAuKrYaQ4)x4t1t1u8k1zmYXxPl0r0FLcXZlEL908OPRWRKNq)PsiEEbSbZyKJDGZybDAQeFQeINxaBWmg54WUj90K5ORu4BWYpeKS2nva2AT1ttMJUsHVbl)WgB)tLq88cydMXihh2nb6hLb60ujcsw7OSbwp6i2w3XSbNXc2qfHn77X10ayR126oMn4mwWgB)tLq88cydMXihh2nHqf43MNJFEKXiizTJYgy9OJyBDhZgCglydve2SVhxtdGTwBR7y2GZybBS9pvcXZlGnygJCCy3KKGBOttLiizTJYgy9OJyBDhZgCglydve2SVhxtdGTwBR7y2GZybBS9pvcXZlGnygJCCy3KkxyWn87ikbjRDt1tIYmgFQeINxaBWmg54WUj)qyps3(5iZtLq88cydMXihh2nPspOVHFhrjizTdGTwBFsYH(rzAS9pvcXZlGnygJCCy3euO(hgByFQeFQeINxaBWmg54WUjvb3ovcyLfMx8ujepVa2GzmYXHDt454NhzmUboUdsw7ayR1g0pkJse7rAJT)PsiEEbSbZyKJd7MGCKbdx4BaUaDqYAhaBT2yeKdD6XSbJs)fnOleLZ193tLq88cydMXihh2nH8jzS)e6pe6GK1oa2ATXiih60JzdgL(lAqxikNR7VNkH45fWgmJrooSBcph)8iJXnWXDqYAhaBT2yeKdD6XSbJs)fnOleLDZk8PsiEEbSbZyKJd7MWLFYMlWpqYAhaBT2(oF)jXQX2dkOkAkBG1JoITEAYi8nx(jBH4SIFuydve2SVhxtdGTwB90Kr4BU8t2cXzf)OWg0fIY5MNI5PsiEEbSbZyKJd7Ma9JYaDAQeFQeINxaBWmg54WUjq)OmkrShPGK1oa2ATXiih60JzdgL(lAqxikNR7VNkH45fWgmJrooSBcx(jBUa)EQeINxaBWmg54WUjeQa)28C8ZJmgFQeINxaBWmg54WUjvUWGB43ruccrbch3Uqhrh2ndKS2rXkfHFcahFQeINxaBWmg54WUjv6b9n87ikFQeINxaBWmg54WUjjb3qNMkXNkH45fWgmJrooSBcKnwinJXNkH45fWgmJrooSBsnP4oUFcizTtiE(d3RZBvUWGB43ru(ujepVa2GzmYXHDt454NhzmUboUdsw7ayR1gJGCOtpMnyu6VObDHOCUU)EQeINxaBWmg54WUjOq9VnYrgmCH)ujepVa2GzmYXHDtaNXQYsvy7NJmGK1oa2ATboJvLLQW2phzAuKrYaQ4)xO5MBg]] )

end
