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


    spec:RegisterPack( "Enhancement", 20201221, [[dyevZaqivGEKuqTjuf9jvqgfQcDkuf8kLkZcqULuav7Is)sPQHHQ0XaWYiL8mavtdqPRbqTnaIVbOOXPcOZbOW6ubW8KcY9Ks7tk0bbivTqLspeGeteGuCrva6JaKsNukaRKumtPaYnLcOStsv)eGKAPaKKNsXuLI(kaPYyLcK9k5VQ0Gr4WelgOhJYKvYLH2Su9zf1OvrNw41KkZMKBJODt1Vv1WvKJRcQLJ0ZbnDrxhv2UsX3rvnEPa15jLA(Qq7xHlaQMLzjjw61IxT4faT0calVhiWcCToWYKApHLzsy6KzSmUqIL5a6NIZqs0ZYmjAREzvnld85OmSmMGeqPmGCHkBaEbwMLKyPxlE1Ixa0slaS8EGalW1cyldCczLETaeGxMZyTqValZcHSY0WdIdOFkodjrpheMtHu8HMgEqaObzijisheAXlqdcT4vlElJkGjSAwgy4ZkSAw6bOAwgHLX7LHF4lysdDyzqxav4Q2wzPxRQzzqxav4Q2wggnsKgszo4GaKR3Tt0G8PRqux(Yg0YnvgHLX7LzIgKpDfI6Yx2Gvw6bE1SmOlGkCvBldJgjsdPmuoh7pDgTR)jV8dFbT4H5IPjCni45GaKR3TR)jV8dFbTCtLryz8EzG5tjHjn0Hvw6b2Qzzqxav4Q2wggnsKgszOCo2F6mAx)tE5h(cAXdZftt4AqWZbbixVBx)tE5h(cA5MkJWY49YWOc88QI5Z0dFUYspGRMLbDbuHRABzy0irAiLHY5y)PZOD9p5LF4lOfpmxmnHRbbpheGC9UD9p5LF4lOLBQmclJ3ltWWlmPHoSYspGunld6cOcx12YWOrI0qkZbhezW0f(CzewgVxMUsiXl88z6QS0dmRMLryz8Ez2GWjKEZprYYGUaQWvTTYs)bwnld6cOcx12YWOrI0qkdixVBpLqbZNsA5MkJWY49Y0PpmVWZNPRYspWOAwgHLX7LbfAEI(fof6WYGUaQWvTTYspa8wnlJWY49Y0f8MuXHDoy8Ezqxav4Q2wzPhaaQMLbDbuHRABzy0irAiLbKR3TW8PK6qCcPwUPYiSmEVmQy(m9WNVGVkRS0dGwvZYGUaQWvTTmmAKinKYaY17wsbvWK(Kx(Om9UfMct3GOX2bbGlJWY49YGkKe9uuxqLaZkl9aa8Qzzqxav4Q2wggnsKgsza56DlPGkysFYlFuME3ctHPBq0y7GaWLryz8EzyNs43tHUbHzLLEaa2Qzzqxav4Q2wggnsKgsza56DlPGkysFYlFuME3ctHPBq0oiaG3YiSmEVmQy(m9WNVGVkRS0daGRMLbDbuHRABzy0irAiLbKR3TNFEpfFz5Mgehpoi4XbbLZX(tNr7enif1vjBKRWsojFk0IhMlMMW1GGNdcqUE3ordsrDvYg5kSKtYNcTWuy6genoiaKbbpugHLX7LrjBKRsGNvw6baqQMLryz8EzG5tjHjn0HLbDbuHRABLLEaaMvZYGUaQWvTTmmAKinKYaY17wsbvWK(Kx(Om9UfMct3GOX2bbGlJWY49YaZNsQdXjKwzPhGdSAwgHLX7LrjBKRsGNLbDbuHRABLLEaagvZYiSmEVmmQapVQy(m9WNld6cOcx12kl9AXB1SmOlGkCvBlJWY49Y0vcjEHNptxzy0irAiLHIDkcpfqfwgM2mfEtHoJjS0dqLLETaOAwgHLX7LPtFyEHNptxzqxav4Q2wzPxlTQMLryz8EzcgEHjn0HLbDbuHRABLLETaE1SmOlGkCvBldJgjsdPmujwxCd6PvwlOn8brJTdcGL3YiSmEVmqoFH0WNRS0RfWwnld6cOcx12YWOrI0qkJWYydExFA7kHeVWZNPRmclJ3ltpO41)nsLLETaC1SmOlGkCvBldJgjsdPmGC9ULuqfmPp5LpktVBHPW0niASDqa4YiSmEVmQy(m9WNVGVkRS0RfGunlJWY49YGcnpVOcjrpfvzqxav4Q2wzPxlGz1SmOlGkCvBldJgjsdPmGC9ULF4Rohv7B(jsAPiPeoCq0qdcGZBzewgVxg(HV6CuTV5NizLvwg5XQzPhGQzzqxav4Q2wggnsKgsza56DlJkWZRkMptp8zl3uzewgVxg(HVGjn0Hvw61QAwg0fqfUQTLHrJePHug4ZPadFzNP)g8g(My(PsgVBrxav4AqC84Ga(CkWWx2EGQ197xq1dHpj0IUaQWvzewgVxMUG3KkoSZbJ3RS0d8Qzzqxav4Q2wggnsKgszOCo2F6mAx)tE5h(cAXdZftt4AqWZbbixVBx)tE5h(cA5MkJWY49YWOc88QI5Z0dFUYspWwnld6cOcx12YWOrI0qkdixVBpLqbZNsA5MkJWY49Y0PpmVWZNPRYspGRMLryz8EzGC(cPHpxg0fqfUQTvw6bKQzzqxav4Q2wgHLX7LPRes8cpFMUYWOrI0qkdf7ueEkGkCqWZbbpoisrHEA7bfV(VrSOlGkCnioECqKIc90Qe4z4Z3UsirOfDbuHRbXXJdc2VbDXtRJm6RE6AqWdLHPntH3uOZycl9auzPhywnld6cOcx12YiSmEVmt0G8PRqux(YgSmmAKinKYCWbbixVBNOb5txHOU8LnOLBQmmTzk8McDgtyPhGkl9hy1SmOlGkCvBldJgjsdPmclJn4D9PTRes8cpFMUbrJTdcGxgHLX7LPhu86)gPYspWOAwgHLX7LzdcNq6n)ejld6cOcx12kl9aWB1SmOlGkCvBldJgjsdPmGC9UDIgKpDfI6Yx2GwUPbbphe84GaKR3TW8PK6qCcPwUPbXXJdcqUE3skOcM0N8YhLP3TWuy6gen2oia8GGhkJWY49YOI5Z0dF(c(QSYspaaunld6cOcx12YWOrI0qktkk0tlJkWZWNVW8PKw0fqfUgehpoia56DlJkWZRkMptp8z7657Lryz8EzyubEEvX8z6HpxzPhaTQMLbDbuHRABzewgVxgLSrUkbEwggnsKgszsrHEAvc8m85BxjKi0IUaQWvzyAZu4nf6mMWspavw6ba4vZYGUaQWvTTmmAKinKYaY17wgvGNxvmFME4ZwUPYiSmEVmW8PKWKg6Wkl9aaSvZYiSmEVmmQapVQy(m9WNld6cOcx12kl9aa4Qzzqxav4Q2wggnsKgsza56DlmFkPoeNqQLBQmclJ3ld7uc)QI5Z0dFUYspaas1SmOlGkCvBldJgjsdPmGC9ULuqfmPp5LpktVBHPW0niASDqa4YiSmEVmStj87Pq3GWSYspaaZQzzqxav4Q2wggnsKgsza56DlPGkysFYlFuME3ctHPBq0y7GaWLryz8EzqfsIEkQlOsGzLLEaoWQzzqxav4Q2wggnsKgsza56DlPGkysFYlFuME3ctHPBq0y7GaWLryz8EzG5tj1H4esRS0daWOAwg0fqfUQTLHrJePHugqUE3skOcM0N8YhLP3TWuy6geTdca4TmclJ3ld7uc)QI5Z0dFUYsVw8wnld6cOcx12YiSmEVmDLqIx45Z0vggnsKgszsrHEA7bfV(VrSOlGkCni45GGIDkcpfqfwgM2mfEtHoJjS0dqLLETaOAwg0fqfUQTLryz8EzuYg5Qe4zzy0irAiLHY5y)PZODIgKI6QKnYvyjNKpfAXdZftt4AqWZbbixVBNObPOUkzJCfwYj5tHwykmDdIgheaszyAZu4nf6mMWspavw61sRQzzqxav4Q2wggnsKgsza56DlPGkysFYlFuME3ctHPBq0y7GaWdcEoiewgBWl6izGWbrJTdcGxgHLX7LHDkHFvX8z6HpxzPxlGxnlJWY49YWp8fmPHoSmOlGkCvBRS0RfWwnlJWY49YaZNsctAOdld6cOcx12kl9Ab4QzzewgVxgLSrUkbEwg0fqfUQTvw61cqQMLbDbuHRABzewgVxMUsiXl88z6kdJgjsdPmuStr4PaQWYW0MPWBk0zmHLEaQS0RfWSAwgHLX7LPl4nPId7CW49YGUaQWvTTYsVwhy1SmclJ3ltN(W8cpFMUYGUaQWvTTYsVwaJQzzewgVxMGHxysdDyzqxav4Q2wzPh48wnld6cOcx12YWOrI0qkdixVBjfubt6tE5JY07wykmDdIgBheaUmclJ3ld7uc)QI5Z0dFUYspWbOAwg0fqfUQTLHrJePHugHLXg8U(02vcjEHNpt3GOXbbaLryz8Ez6bfV(VrQS0dCTQMLryz8EzqHMNOFHtHoSmOlGkCvBRS0dCGxnlJWY49YGcnpVOcjrpfvzqxav4Q2wzPh4aB1SmOlGkCvBldJgjsdPmGC9ULF4Rohv7B(jsAPiPeoCq0qdcGZBzewgVxg(HV6CuTV5NizLvwMf2fovwnl9aunlJWY49YaQ(FP4Gzzqxav4QaRS0Rv1SmOlGkCvBldJgjsdPm9y(mVuKuchoiAObbGWBzewgVxMPpJ3RS0d8QzzewgVxg(HVUWtuOLbDbuHRABLLEGTAwgHLX7LHdI3irsyzqxav4Q2wzPhWvZYGUaQWvTTmmAKinKYCWbrkk0tRazOVeNHw0fqfUgehpoia56DRazOVeNHwUPbXXJdc2)Q1Z3TcKH(sCgAPiPeoCq04GaW8wgHLX7Lbu9)625OAxzPhqQMLbDbuHRABzy0irAiL5GdIuuONwbYqFjodTOlGkCnioECqaY17wbYqFjodTCtLryz8EzarkeP6cFUYspWSAwg0fqfUQTLHrJePHuMdoisrHEAfid9L4m0IUaQW1G44XbbixVBfid9L4m0YnnioECqW(xTE(UvGm0xIZqlfjLWHdIgheaM3YiSmEVm9GIGQ)xvw6pWQzzqxav4Q2wggnsKgszo4Giff6PvGm0xIZql6cOcxdIJhheGC9UvGm0xIZql30G44Xbb7F1657wbYqFjodTuKuchoiACqayElJWY49YiodHjvuxMOuvw6bgvZYGUaQWvTTmmAKinKYCWbrkk0tRazOVeNHw0fqfUgehpoio4GaKR3TcKH(sCgA5MkJWY49YakZ3VFtAW0bRS0daVvZYiSmEVmDKkQlCkOrwg0fqfUQTvw6baGQzzqxav4Q2wggnsKgsz4Xbrkk0tRazOVeNHw0fqfUgehpoiOCo2F6mAx)tE5h(cAXdZftt4AqWddcEoi4Xbb85uGHVSZ0FdEdFtm)ujJ3TOlGkCnioECqaFofy4lBpq16(9lO6HWNeArxav4AqC84GqyzSbVOJKbcheTdcage8qzewgVxMUG3KkoSZbJ3RS0dGwvZYGUaQWvTTmmAKinKYqLyDXnONwzTG2When2oiag8oioECqiSm2Gx0rYaHdIgheaugHLX7LrGm0xIZWkl9aa8Qzzqxav4Q2wggnsKgszOCo2F6mAx)tE5h(cAXdZftt4AqWZbbixVBx)tE5h(cExiixVBxpFFqWZbbpoiOsSU4g0tRSwqB4dIgBheacVdIJhheclJn4fDKmq4GOXbbadcEyqC84GaKR3T8dF15OAFZprs7657Lryz8Ez4h(QZr1(MFIKvw6bayRMLbDbuHRABzy0irAiLryzSbVOJKbcheTdcakJWY49YWeL6kSmE)QcywgvaZRlKyzGHpRWkl9aa4Qzzqxav4Q2wggnsKgszewgBWl6izGWbrJdcakJWY49YWeL6kSmE)QcywgvaZRlKyzKhRS0daGunlJWY49YWEoprkmPHo8MFIKLbDbuHRABLLEaaMvZYiSmEVmqDA35OAFZprYYGUaQWvTTYspahy1SmclJ3lZenif1fM0qhwg0fqfUQTvwzzMOi7jbLSAw6bOAwg0fqfUQTLHrJePHugqUE3Yp8vNJQ9LpktVBPiPeoCq0qdcGZlVLryz8Ez4h(QZr1(YhLP3RS0Rv1SmOlGkCvBldJgjsdPmGC9UTResmFFMdV8rz6DlfjLWHdIgAqaCE5TmclJ3ltxjKy((mhE5JY07vw6bE1SmclJ3ld4NPcx3Us0gx8dF(MFdo8YGUaQWvTTYspWwnld6cOcx12YWOrI0qkdixVBvX8z6HpFHNbQwwkskHdhen0Ga48YBzewgVxgvmFME4Zx4zGQvLLEaxnld6cOcx12YWOrI0qkZbheuoh7pDgTR)jV8dFbT4H5IPjCni45GaKR3T8dF15OAFZprs7657Lryz8Ez4h(QZr1(MFIKvw6bKQzzqxav4Q2wggnsKgszsrHEAH5tj1H4esTOlGkCvgHLX7LbMpLuhItiTYkRSmBqkmEV0RfVAXlaAPfVLHVq9WNHLbqhGEav6Ba6b0EagedIMN4GiiNEAoi6pDqCi5XdniO4H5ckUgeWNehecx(KsIRbb7u8zeAhAAGchheADageakVVbPjUgehc(CkWWx2g0Hge5pioe85uGHVSnil6cOcxhAqWJa0G5b7qtdu44GqRdWGaq59ninX1G4qWNtbg(Y2Go0Gi)bXHGpNcm8LTbzrxav46qdcjhehqa1nqdcEeGgmpyhAgAa0bOhqL(gGEaThGbXGO5joicYPNMdI(thehAHDHtLhAqqXdZfuCniGpjoieU8jLexdc2P4Zi0o00afooiaaGdWGaq59ninX1G4qWNtbg(Y2Go0Gi)bXHGpNcm8LTbzrxav46qdcEuRgmpyhAgAAaKtpnX1GayheclJ3heQaMq7qtzMOFpuyzA4bXb0pfNHKONdcZPqk(qtdpia0GmKeePdcT4fObHw8QfVdndnclJ3H2jkYEsqjB5h(QZr1(YhLP3bk6TGC9ULF4Rohv7lFuME3srsjCydbCE5DOryz8o0orr2tck5U29DLqI57ZC4LpktVdu0Bb56DBxjKy((mhE5JY07wkskHdBiGZlVdnclJ3H2jkYEsqj31Uh8ZuHRBxjAJl(HpFZVbh(qJWY4DODIISNeuYDT7vX8z6HpFHNbQwaf9wqUE3QI5Z0dF(cpduTSuKuch2qaNxEhAewgVdTtuK9KGsURDp)WxDoQ238tKeOO3EqkNJ9NoJ21)Kx(HVGw8WCX0eU4jixVB5h(QZr1(MFIK21Z3hAewgVdTtuK9KGsURDpmFkPoeNqkqrVnff6PfMpLuhIti1IUaQW1qZqtdpioGnyKXL4AqGBqQ2dImiXbrEIdcHLpDqeWbHSrcLaQq7qJWY4DylO6)LIdMdnn8GOb4nWzpjOKdIPpJ3hebCqaI9NIdc2tck5Ga9f0o0iSmEhURD)0NX7af92EmFMxkskHdBiaH3HMgEq0a8ePuUPCq89bbtGj0o0iSmEhURDp)Wxx4jk0HgHLX7WDT75G4nsKeo0iSmEhURDpO6)1TZr1gOO3EWuuONwbYqFjodTOlGkCD8iixVBfid9L4m0YnD8i7F1657wbYqFjodTuKuch2iG5DOryz8oCx7EqKcrQUWNbk6Thmff6PvGm0xIZql6cOcxhpcY17wbYqFjodTCtdnclJ3H7A33dkcQ(Fbu0Bpykk0tRazOVeNHw0fqfUoEeKR3TcKH(sCgA5MoEK9VA98DRazOVeNHwkskHdBeW8o0iSmEhURDV4meMurDzIsbu0Bpykk0tRazOVeNHw0fqfUoEeKR3TcKH(sCgA5MoEK9VA98DRazOVeNHwkskHdBeW8o0iSmEhURDpOmF)(nPbtheOO3EWuuONwbYqFjodTOlGkCD84bb56DRazOVeNHwUPHgHLX7WDT77ivux4uqJCOryz8oCx7(UG3KkoSZbJ3bk6T8ykk0tRazOVeNHw0fqfUoEKY5y)PZOD9p5LF4lOfpmxmnHlEGN8i85uGHVSZ0FdEdFtm)ujJ3pEe(CkWWx2EGQ197xq1dHpj84rHLXg8IosgiSfaEyOryz8oCx7EbYqFjodbk6TujwxCd6PvwlOn8gBbg8E8OWYydErhjde2iadnclJ3H7A3Zp8vNJQ9n)ejbk6Tuoh7pDgTR)jV8dFbT4H5IPjCXtqUE3U(N8Yp8f8UqqUE3UE(op5rQeRlUb90kRf0gEJTacVhpkSm2Gx0rYaHncapC8iixVB5h(QZr1(MFIK21Z3hAA4brdOpiExP9G4DCqGosQnqdIjA80i1Eq0FL65dhe5joioem8zfEObHWY49bHkGPDOryz8oCx7EMOuxHLX7xvatGCHeBHHpRqGIERWYydErhjde2cWqtdpiau7dcsovgtkCqGosgieObrEIdIjA80i1Eq0FL65dhe5joioK84HgeclJ3heQaM2HgHLX7WDT7zIsDfwgVFvbmbYfsSvEeOO3kSm2Gx0rYaHncWqJWY4D4U29SNZtKctAOdV5Ni5qJWY4D4U29qDA35OAFZprYHgHLX7WDT7NObPOUWKg6WHMHMgEq0aJtLXGif6mMdcHLX7dIjA80i1EqOcyo0iSmEhALhB5h(cM0qhcu0Bb56DlJkWZRkMptp8zl30qJWY4DOvECx7(UG3KkoSZbJ3bk6TWNtbg(Yot)n4n8nX8tLmE)4r4ZPadFz7bQw3VFbvpe(KWHgHLX7qR84U29mQapVQy(m9WNbk6Tuoh7pDgTR)jV8dFbT4H5IPjCXtqUE3U(N8Yp8f0Ynn0iSmEhALh31UVtFyEHNpthqrVfKR3TNsOG5tjTCtdnclJ3Hw5XDT7HC(cPHpp0iSmEhALh31UVRes8cpFMoGyAZu4nf6mMWwaak6TuStr4PaQqEYJPOqpT9GIx)3iw0fqfUoEmff6PvjWZWNVDLqIql6cOcxhpY(nOlEADKrF1tx8WqJWY4DOvECx7(jAq(0viQlFzdcetBMcVPqNXe2caqrV9GGC9UDIgKpDfI6Yx2GwUPHgHLX7qR84U299GIx)3iaf9wHLXg8U(02vcjEHNptxJTaFOryz8o0kpURD)geoH0B(jso0iSmEhALh31UxfZNPh(8f8vjqrVfKR3Tt0G8PRqux(Yg0YnXtEeKR3TW8PK6qCcPwUPJhb56DlPGkysFYlFuME3ctHPRXwaZddnclJ3Hw5XDT7zubEEvX8z6Hpdu0BtrHEAzubEg(8fMpL0IUaQW1XJGC9ULrf45vfZNPh(SD989HgHLX7qR84U29kzJCvc8eiM2mfEtHoJjSfaGIEBkk0tRsGNHpF7kHeHw0fqfUgAewgVdTYJ7A3dZNsctAOdbk6TGC9ULrf45vfZNPh(SLBAOryz8o0kpURDpJkWZRkMptp85HgHLX7qR84U29Stj8RkMptp8zGIElixVBH5tj1H4esTCtdnclJ3Hw5XDT7zNs43tHUbHjqrVfKR3TKcQGj9jV8rz6DlmfMUgBb8qJWY4DOvECx7EuHKONI6cQeycu0Bb56DlPGkysFYlFuME3ctHPRXwap0iSmEhALh31UhMpLuhItifOO3cY17wsbvWK(Kx(Om9UfMctxJTaEOryz8o0kpURDp7uc)QI5Z0dFgOO3cY17wsbvWK(Kx(Om9UfMctxla8o0iSmEhALh31UVRes8cpFMoGyAZu4nf6mMWwaak6TPOqpT9GIx)3iw0fqfU4jf7ueEkGkCOryz8o0kpURDVs2ixLapbIPntH3uOZycBbaOO3s5CS)0z0ordsrDvYg5kSKtYNcT4H5IPjCXtqUE3ordsrDvYg5kSKtYNcTWuy6AeqgAewgVdTYJ7A3ZoLWVQy(m9WNbk6TGC9ULuqfmPp5LpktVBHPW01ylG5PWYydErhjde2ylWhAewgVdTYJ7A3Zp8fmPHoCOryz8o0kpURDpmFkjmPHoCOryz8o0kpURDVs2ixLaphAewgVdTYJ7A33vcjEHNpthqmTzk8McDgtylaaf9wk2Pi8uav4qJWY4DOvECx7(UG3KkoSZbJ3hAewgVdTYJ7A33PpmVWZNPBOryz8o0kpURDFWWlmPHoCOryz8o0kpURDp7uc)QI5Z0dFgOO3cY17wsbvWK(Kx(Om9UfMctxJTaEOryz8o0kpURDFpO41)ncqrVvyzSbVRpTDLqIx45Z01iadnclJ3Hw5XDT7rHMNOFHtHoCOryz8o0kpURDpk088IkKe9uudnclJ3Hw5XDT75h(QZr1(MFIKaf9wqUE3Yp8vNJQ9n)ejTuKuch2qaN3HMHMgEqycFwHdIuOZyoiewgVpiMOXtJu7bHkG5qJWY4DOfg(ScB5h(cM0qho0iSmEhAHHpRWDT7NOb5txHOU8LniqrV9GGC9UDIgKpDfI6Yx2GwUPHgHLX7qlm8zfURDpmFkjmPHoeOO3s5CS)0z0U(N8Yp8f0IhMlMMWfpb56D76FYl)Wxql30qJWY4DOfg(Sc31UNrf45vfZNPh(mqrVLY5y)PZOD9p5LF4lOfpmxmnHlEcY1721)Kx(HVGwUPHgHLX7qlm8zfURDFWWlmPHoeOO3s5CS)0z0U(N8Yp8f0IhMlMMWfpb56D76FYl)Wxql30qJWY4DOfg(Sc31UVRes8cpFMoGIE7bZGPl85HgHLX7qlm8zfURD)geoH0B(jso0iSmEhAHHpRWDT770hMx45Z0bu0Bb56D7Peky(usl30qJWY4DOfg(Sc31UhfAEI(fof6WHgHLX7qlm8zfURDFxWBsfh25GX7dnclJ3Hwy4ZkCx7EvmFME4ZxWxLaf9wqUE3cZNsQdXjKA5MgAewgVdTWWNv4U29Ocjrpf1fujWeOO3cY17wsbvWK(Kx(Om9UfMctxJTaEOryz8o0cdFwH7A3ZoLWVNcDdctGIElixVBjfubt6tE5JY07wykmDn2c4HgHLX7qlm8zfURDVkMptp85l4RsGIElixVBjfubt6tE5JY07wykmDTaW7qJWY4DOfg(Sc31UxjBKRsGNaf9wqUE3E(59u8LLB64rEKY5y)PZODIgKI6QKnYvyjNKpfAXdZftt4INGC9UDIgKI6QKnYvyjNKpfAHPW01iGWddnclJ3Hwy4ZkCx7Ey(usysdD4qJWY4DOfg(Sc31UhMpLuhItifOO3cY17wsbvWK(Kx(Om9UfMctxJTaEOryz8o0cdFwH7A3RKnYvjWZHgHLX7qlm8zfURDpJkWZRkMptp85HgHLX7qlm8zfURDFxjK4fE(mDaX0MPWBk0zmHTaau0BPyNIWtbuHdnclJ3Hwy4ZkCx7(o9H5fE(mDdnclJ3Hwy4ZkCx7(GHxysdD4qJWY4DOfg(Sc31UhY5lKg(mqrVLkX6IBqpTYAbTH3ylWY7qJWY4DOfg(Sc31UVhu86)gbOO3kSm2G31N2UsiXl88z6gAewgVdTWWNv4U29Qy(m9WNVGVkbk6TGC9ULuqfmPp5LpktVBHPW01ylGhAewgVdTWWNv4U29OqZZlQqs0trn0iSmEhAHHpRWDT75h(QZr1(MFIKaf9wqUE3Yp8vNJQ9n)ejTuKuch2qaN3YiC55tlJjibuQSYQa]] )

end
