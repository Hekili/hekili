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
            gcd = "spell",

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


    spec:RegisterPack( "Enhancement", 20210307, [[du0o1aqiLI8iQiAtakFsPGrrfHtHQOELQKzbi3sPqPDrv)sPQHrf1XuLAzsf9mufMgGQUga12au5BurY4aiCoLIQ1PuOAEkfY9uK9jv4GOkcTqLkpuPO4IkfL(iQIiNeGOvsfMjQIKBQuOyNuP(jQIulfvrWtj1uLk9vufrnwQiL9k5VQQbd0HjwmcpgLjRKldTzf(SIA0QItt51ujZMKBJODl8BvgUu1XbiTCKEoOPl66OY2vk9DuvJNks15rvA(ay)s56D1T0ljXYDNo35BN5HZoLVZobEabW3zPtE7Xs3lmxYmw6qiXsVzJhjyijgzP7fEvNSQULgECugwATrUzknbNPsazueLEjjwU705oF7mpC2P8D2jWdi4bGlnShzL7oboEu6hBTWOik9cHSsVzJhjyijgzdu)iKs0CSXiu2td0PaQb2PZD(U0kdMWQBPHwmRWQB5(D1T0clTlknFlwWKAUWsJHqOWvTRYYDNv3sJHqOWvTR0mQLi1KstWng(Nl)psS8C9nqaaOb6enqkxGJJoJ(EQrkQVs2kFHLCsEuOhbuoRVhxnqG1aj4gdFp1if1xjBLVWsojpk0dtH5Qb2rde4AG8CPfwAxuALSv(kb(uz5Mhv3sJHqOWvTR0mQLi1KsVPgib3y47Pg5rxMO(8LTONRV0clTlkDp1ip6Ye1NVSfRSCd8v3sJHqOWvTR0mQLi1Kst5cCC0z0VUJ8Z3If0JakN13JRgiWAGeCJHFDh5NVflONRV0clTlknmpkjmPMlSYYnGRULgdHqHRAxPzulrQjLMYf44OZOFDh5NVflOhbuoRVhxnqG1aj4gd)6oYpFlwqpxFPfwAxuAgvGpFLn)KHfZvwUbUQBPXqiu4Q2vAg1sKAsPPCboo6m6x3r(5BXc6raLZ67XvdeynqcUXWVUJ8Z3If0Z1xAHL2fL2y4hMuZfwz52PQULgdHqHRAxPzulrQjLEtnW0yUSyU0clTlk9qjK4h(CmxvwUbev3slS0UO0Bryps)5LizPXqiu4Q2vz5EZRULgdHqHRAxPzulrQjLMGBm8pIPG5rj9C9LwyPDrPh0dMF4ZXCvz5(TZv3slS0UO0OqZhm(WEZfwAmecfUQDvwUF)U6wAHL2fLEi4pPsahCq7IsJHqOWvTRYY97oRULgdHqHRAxPzulrQjLEtnW(K2abwdKGBm8W8OKUqShPEU(slS0UO0kB(jdlM)eNkRSC)Mhv3sJHqOWvTR0mQLi1Ks3N0giWAGeCJHhMhL0fI9i1Z1xAHL2fLM9iw8v28tgwmxz5(nWxDlngcHcx1UsZOwIutknb3y4jfubt6r(5Js)fEykmxnWoMAGaU0clTlknQqsmsr9jucmRSC)gWv3sJHqOWvTR0mQLi1KstWngEsbvWKEKF(O0FHhMcZvdSJPgiGBGaRbsfB9XTyKEzTGElAGDm1a3CNlTWs7IsZEel(pcDlcZkl3VbUQBPXqiu4Q2vAg1sKAsPj4gdpPGkyspYpFu6VWdtH5Qbo1aF7CPfwAxuALn)KHfZFItLvwUF7uv3slS0UO0W8OKWKAUWsJHqOWvTRYY9Bar1T0yiekCv7knJAjsnP0eCJHNuqfmPh5Npk9x4HPWC1a7yQbc4slS0UO0W8OKUqShPvwUFV5v3slS0UO0kzR8vc8P0yiekCv7QSC3PZv3slS0UO0mQaF(kB(jdlMlngcHcx1Ukl3D(U6wAmecfUQDLwyPDrPhkHe)WNJ5Q0mQLi1KstXbfHpcHclnJxMc)PqNXewUFxz5UZoRULwyPDrPh0dMF4ZXCvAmecfUQDvwU7Khv3slS0UO0gd)WKAUWsJHqOWvTRYYDNaF1T0yiekCv7knJAjsnP0uXwFClgPxwlO3IgyhtnqG35slS0UO0qUyHulMRSC3jGRULgdHqHRAxPzulrQjLwyPTf)Rl9dLqIF4ZXCvAHL2fLEyu8h3wPYYDNax1T0yiekCv7knJAjsnP0eCJHNuqfmPh5Npk9x4HPWC1a7yQbc4slS0UO0kB(jdlM)eNkRSC3PtvDlTWs7IsJcnF(OcjXifvPXqiu4Q2vz5Utar1T0yiekCv7knJAjsnP0eCJHNVfRbhL3FEjs6PiPybSbUrnqE4CPfwAxuA(wSgCuE)5LizLvwA5WQB5(D1T0yiekCv7knJAjsnP0eCJHNrf4ZxzZpzyXSNRV0clTlknFlwWKAUWkl3DwDlngcHcx1UsZOwIutkn84uewS8Z0Bl(TyRnFujTl8yiekC1abaGgi84uewS8ddvR)n(eQdcpsOhdHqHRslS0UO0db)jvc4GdAxuz5Mhv3sJHqOWvTR0mQLi1Kst5cCC0z0VUJ8Z3If0JakN13JRgiWAGeCJHFDh5NVflONRV0clTlknJkWNVYMFYWI5kl3aF1T0yiekCv7knJAjsnP0eCJH)rmfmpkPNRV0clTlk9GEW8dFoMRkl3aU6wAHL2fLgYflKAXCPXqiu4Q2vz5g4QULgdHqHRAxPfwAxu6HsiXp85yUknJAjsnP0uCqr4JqOWgiWAGordmffgPFyu8h3wXJHqOWvdeaaAGPOWi9kb(yX8FOese6Xqiu4Qbcaanq2TfdjsFGm6Po6QbYZLMXltH)uOZycl3VRSC7uv3sJHqOWvTR0clTlkDp1ip6Ye1NVSflnJAjsnP0BQbsWng(EQrE0LjQpFzl656lnJxMc)PqNXewUFxz5gquDlngcHcx1UsZOwIutkTWsBl(xx6hkHe)WNJ5Qb2XudKhLwyPDrPhgf)XTvQSCV5v3slS0UO0Bryps)5LizPXqiu4Q2vz5(TZv3sJHqOWvTR0mQLi1KstWng(EQrE0LjQpFzl656BGaRb6enqcUXWdZJs6cXEK656BGaaqdKGBm8KcQGj9i)8rP)cpmfMRgyhtnqa3a55slS0UO0kB(jdlM)eNkRSC)(D1T0yiekCv7knJAjsnP0POWi9mQaFSy(dZJs6Xqiu4QbcaanqcUXWZOc85RS5NmSy2Vo(rPfwAxuAgvGpFLn)KHfZvwUF3z1T0yiekCv7kTWs7IsRKTYxjWNsZOwIutkDkkmsVsGpwm)hkHeHEmecfUknJxMc)PqNXewUFxz5(npQULgdHqHRAxPzulrQjLMGBm8mQaF(kB(jdlM9C9LwyPDrPH5rjHj1CHvwUFd8v3slS0UO0mQaF(kB(jdlMlngcHcx1Ukl3VbC1T0yiekCv7knJAjsnP0eCJHhMhL0fI9i1Z1xAHL2fLM9iw8v28tgwmxz5(nWvDlngcHcx1UsZOwIutknb3y4jfubt6r(5Js)fEykmxnWoMAGaU0clTlkn7rS4)i0TimRSC)2PQULgdHqHRAxPzulrQjLMGBm8KcQGj9i)8rP)cpmfMRgyhtnqaxAHL2fLgvijgPO(ekbMvwUFdiQULgdHqHRAxPzulrQjLMGBm8KcQGj9i)8rP)cpmfMRgyhtnqaxAHL2fLgMhL0fI9iTYY97nV6wAmecfUQDLMrTePMuAcUXWtkOcM0J8ZhL(l8WuyUAGtnW3oxAHL2fLM9iw8v28tgwmxz5UtNRULgdHqHRAxPfwAxu6HsiXp85yUknJAjsnP0POWi9dJI)42kEmecfUAGaRbsXbfHpcHclnJxMc)PqNXewUFxz5UZ3v3sJHqOWvTR0clTlkTs2kFLaFknJAjsnP0uUahhDg99uJuuFLSv(cl5K8OqpcOCwFpUAGaRbsWng(EQrkQVs2kFHLCsEuOhMcZvdSJgiWvAgVmf(tHoJjSC)UYYDNDwDlngcHcx1UsZOwIutknb3y4jfubt6r(5Js)fEykmxnWoMAGaUbcSgOWsBl(Xajne2a7yQbYJslS0UO0ShXIVYMFYWI5kl3DYJQBPfwAxuA(wSGj1CHLgdHqHRAxLL7ob(QBPfwAxuAyEusysnxyPXqiu4Q2vz5UtaxDlTWs7IsRKTYxjWNsJHqOWvTRYYDNax1T0yiekCv7kTWs7Ispucj(HphZvPzulrQjLMIdkcFecfwAgVmf(tHoJjSC)UYYDNov1T0clTlk9qWFsLao4G2fLgdHqHRAxLL7obev3slS0UO0d6bZp85yUkngcHcx1Ukl3DU5v3slS0UO0gd)WKAUWsJHqOWvTRYYnpCU6wAmecfUQDLMrTePMuAcUXWtkOcM0J8ZhL(l8WuyUAGDm1abCPfwAxuA2JyXxzZpzyXCLLBE8U6wAmecfUQDLMrTePMuAHL2w8VU0pucj(HphZvdSJg47slS0UO0dJI)42kvwU5rNv3slS0UO0OqZhm(WEZfwAmecfUQDvwU5bpQULwyPDrPrHMpFuHKyKIQ0yiekCv7QSCZdGV6wAmecfUQDLMrTePMuAcUXWZ3I1GJY7pVej9uKuSa2a3OgipCU0clTlknFlwdokV)8sKSYkl9chcNkRUL73v3slS0UO0eQ7wkoywAmecfUkIkl3DwDlngcHcx1UsZOwIutknXbHnqG1ah28t(PiPybSbUrnqGZ5sVqiJA9PDrPbKXgl7ijKSb2FPDrd0GnqcCCuSbYoscjBGySG(slS0UO09xAxuz5Mhv3sJHqOWvTR0leYOwFAxuAazKiLY1NnWB0azcmH(slS0UO08Ty9HpOqRSCd8v3slS0UO0Cq8BjsclngcHcx1Ukl3aU6wAmecfUQDLMrTePMu6n1atrHr6fidJLem0JHqOWvdeaaAGeCJHxGmmwsWqpxFdeaaAGS7uRJF4fidJLem0trsXcydSJgiGDU0clTlknH6U1FWr5TYYnWvDlngcHcx1UsZOwIutk9MAGPOWi9cKHXscg6Xqiu4QbcaanqcUXWlqggljyONRV0clTlknbsHi1LfZvwUDQQBPXqiu4Q2vAg1sKAsP3udmffgPxGmmwsWqpgcHcxnqaaObsWngEbYWyjbd9C9nqaaObYUtTo(HxGmmwsWqpfjflGnWoAGa25slS0UO0dJIeQ7wvwUbev3sJHqOWvTR0mQLi1KsVPgykkmsVazySKGHEmecfUAGaaqdKGBm8cKHXscg656BGaaqdKDNAD8dVazySKGHEkskwaBGD0abSZLwyPDrPLGHWKkQptuQkl3BE1T0yiekCv7knJAjsnP0BQbMIcJ0lqggljyOhdHqHRgiaa0a3udKGBm8cKHXscg656lTWs7IstiZ)B8tQXCbRSC)25QBPfwAxu6bsf1h2BullngcHcx1Ukl3VFxDlngcHcx1UsZOwIutkTt0atrHr6fidJLem0JHqOWvdeaaAGuUahhDg9R7i)8Tyb9iGYz994QbYZnqG1aDIgi84uewS8Z0Bl(TyRnFujTl8yiekC1abaGgi84uewS8ddvR)n(eQdcpsOhdHqHRgiaa0afwABXpgiPHWg4ud8DdKNlTWs7Ispe8NujGdoODrLL73DwDlngcHcx1UsZOwIutknvS1h3Ir6L1c6TOb2XudCZDUbcaanqHL2w8JbsAiSb2rd8DPfwAxuAbYWyjbdRSC)Mhv3sJHqOWvTR0mQLi1Kst5cCC0z0VUJ8Z3If0JakN13JRgiWAGeCJHFDh5NVfl4FHeCJHFD8JgiWAGordKk26JBXi9YAb9w0a7yQbcCo3abaGgOWsBl(Xajne2a7Ob(UbYZnqaaObsWngE(wSgCuE)5LiPFD8JslS0UO08Tyn4O8(ZlrYkl3Vb(QBPXqiu4Q2v6fczuRpTlknGC0aVqXBd8cSbIbsYlqnWEQDul5TbooL64dBG5d2a3a0IzfUHgOWs7IgOYGPV0clTlkntuQVWs7IVYGzPzulrQjLwyPTf)yGKgcBGtnW3LwzW8hcjwAOfZkSYY9BaxDlngcHcx1UsVqiJA9PDrP5PJgijNkTEf2aXajnecudmFWgyp1oQL82ahNsD8HnW8bBGBqoCdnqHL2fnqLbtFPfwAxuAMOuFHL2fFLbZsZOwIutkTWsBl(Xajne2a7Ob(U0kdM)qiXslhwz5(nWvDlTWs7IsZoUirkmPMl8NxIKLgdHqHRAxLL73ov1T0clTlkn0fVdokV)8sKS0yiekCv7QSC)gquDlTWs7Is3tnsr9Hj1CHLgdHqHRAxLvw6EkYoscjRUL73v3sJHqOWvTR0mQLi1KstWngE(wSgCuE)8rP)cpfjflGnWnQbYdNDU0clTlknFlwdokVF(O0FrLL7oRULgdHqHRAxPzulrQjLMGBm8dLqI5fZC4Npk9x4PiPybSbUrnqE4SZLwyPDrPhkHeZlM5WpFu6VOYYnpQULwyPDrPjUmv46pucV4IVfZ)8C6wuAmecfUQDvwUb(QBPXqiu4Q2vAg1sKAsPj4gdVYMFYWI5p8Xq1YtrsXcydCJAG8WzNlTWs7IsRS5NmSy(dFmuTQSCd4QBPXqiu4Q2vAg1sKAsP3udKYf44OZOFDh5NVflOhbuoRVhxnqG1aj4gdpFlwdokV)8sK0Vo(rPfwAxuA(wSgCuE)5LizLLBGR6wAmecfUQDLMrTePMu6uuyKEyEusxi2JupgcHcxLwyPDrPH5rjDHypsRSYkl9wKcTlk3D6CNVD(9BNQ08fAyXmS08K5jYtWnG0npPnEdSb29bBGgz)rZg44OnWnihUHgifbuoJIRgi8iXgOWLhPK4QbYEKygH(MdEklWgyNB8g4M5ITinXvdCdWJtryXY702qdmVg4gGhNIWIL3P5Xqiu4AdnqN4TtNN9nh8uwGnWo34nWnZfBrAIRg4gGhNIWIL3PTHgyEnWnapofHflVtZJHqOW1gAGs2a3S808unqN4TtNN9nhnh8K5jYtWnG0npPnEdSb29bBGgz)rZg44OnWnSWHWPYn0aPiGYzuC1aHhj2afU8iLexnq2JeZi03CWtzb2aF)EJ3a3mxSfPjUAGBaECkclwEN2gAG51a3a84uewS8onpgcHcxBOb6eD605zFZrZbGKS)OjUAGaFduyPDrduzWe6BokDp9gMclTt6KnWnB8ibdjXiBG6hHuIMdN0jBGBmcL90aDkGAGD6CNVBoAoewAxa99uKDKesoX3I1GJY7Npk9xaKnMi4gdpFlwdokVF(O0FHNIKIfWnIho7CZHWs7cOVNISJKqYxt7hkHeZlM5WpFu6VaiBmrWng(HsiX8Izo8ZhL(l8uKuSaUr8WzNBoewAxa99uKDKes(AApXLPcx)Hs4fx8Ty(NNt3IMdHL2fqFpfzhjHKVM2RS5NmSy(dFmuTaYgteCJHxzZpzyX8h(yOA5PiPybCJ4HZo3CiS0Ua67Pi7ijK810E(wSgCuE)5Lijq2yAtuUahhDg9R7i)8Tyb9iGYz994cyeCJHNVfRbhL3FEjs6xh)O5qyPDb03tr2rsi5RP9W8OKUqShPazJPuuyKEyEusxi2JupgcHcxnhnhoPt2a3SoDKXL4QbIBrkVnW0iXgy(GnqHLhTbAWgOSvmLqOqFZHWs7c4eH6ULIdMnhozdeqgBSSJKqYgy)L2fnqd2ajWXrXgi7ijKSbIXc6BoewAxaFnTV)s7cGSXeXbHaByZp5NIKIfWnc4CU5WjBGaYirkLRpBG3ObYeyc9nhclTlGVM2Z3I1h(GcT5qyPDb810Eoi(TejHnhclTlGVM2tOUB9hCuEbYgtBkffgPxGmmwsWqpgcHcxaaab3y4fidJLem0Z1daaS7uRJF4fidJLem0trsXcyha25MdHL2fWxt7jqkePUSygiBmTPuuyKEbYWyjbd9yiekCbaaeCJHxGmmwsWqpxFZHWs7c4RP9dJIeQ7wazJPnLIcJ0lqggljyOhdHqHlaaGGBm8cKHXscg656baa2DQ1Xp8cKHXscg6PiPybSda7CZHWs7c4RP9sWqysf1Njkfq2yAtPOWi9cKHXscg6Xqiu4caai4gdVazySKGHEUEaaGDNAD8dVazySKGHEkskwa7aWo3CiS0Ua(AApHm)VXpPgZfeiBmTPuuyKEbYWyjbd9yiekCbaaBIGBm8cKHXscg656BoewAxaFnTFGur9H9g1YMdHL2fWxt7hc(tQeWbh0UaiBm5ePOWi9cKHXscg6Xqiu4caaOCboo6m6x3r(5BXc6raLZ67XfpdmNaECkclw(z6Tf)wS1MpQK2faaa84uewS8ddvR)n(eQdcpsiaaiS02IFmqsdHtV55MdHL2fWxt7fidJLemeiBmrfB9XTyKEzTGEl6yAZDgaaewABXpgiPHWoE3CiS0Ua(AApFlwdokV)8sKeiBmr5cCC0z0VUJ8Z3If0JakN13JlGrWng(1DKF(wSG)fsWng(1XpaMtqfB9XTyKEzTGEl6yc4CgaaewABXpgiPHWoEZZaaab3y45BXAWr59NxIK(1XpAoCYgiGC0aVqXBd8cSbIbsYlqnWEQDul5TbooL64dBG5d2a3a0IzfUHgOWs7IgOYGPV5qyPDb810EMOuFHL2fFLbtGcHeNGwmRqGSXKWsBl(Xajneo9U5WjBG80rdKKtLwVcBGyGKgcbQbMpydSNAh1sEBGJtPo(Wgy(GnWnihUHgOWs7IgOYGPV5qyPDb810EMOuFHL2fFLbtGcHeNKdbYgtclTT4hdK0qyhVBoewAxaFnTNDCrIuysnx4pVejBoewAxaFnTh6I3bhL3FEjs2CiS0Ua(AAFp1if1hMuZf2C0C4KozdCJHtLwdmf6mMnqHL2fnWEQDul5TbQmy2CiS0Ua6LdN4BXcMuZfcKnMi4gdpJkWNVYMFYWIzpxFZHWs7cOxo810(HG)KkbCWbTlaYgtWJtryXYptVT43IT28rL0UaaaGhNIWILFyOA9VXNqDq4rcBoewAxa9YHVM2ZOc85RS5NmSygiBmr5cCC0z0VUJ8Z3If0JakN13JlGrWng(1DKF(wSGEU(MdHL2fqVC4RP9d6bZp85yUaYgteCJH)rmfmpkPNRV5qyPDb0lh(AApKlwi1I5MdHL2fqVC4RP9dLqIF4ZXCbeJxMc)PqNXeo9giBmrXbfHpcHcbMtKIcJ0pmk(JBR4Xqiu4caasrHr6vc8XI5)qjKi0JHqOWfaaWUTyir6dKrp1rx8CZHWs7cOxo810(EQrE0LjQpFzlceJxMc)PqNXeo9giBmTjcUXW3tnYJUmr95lBrpxFZHWs7cOxo810(HrXFCBfGSXKWsBl(xx6hkHe)WNJ5QJjE0CiS0Ua6LdFnTFlc7r6pVejBoewAxa9YHVM2RS5NmSy(tCQeiBmrWng(EQrE0LjQpFzl656bMtqWngEyEusxi2JupxpaaqWngEsbvWKEKF(O0FHhMcZvhtaMNBoewAxa9YHVM2ZOc85RS5NmSygiBmLIcJ0ZOc8XI5pmpkPhdHqHlaaGGBm8mQaF(kB(jdlM9RJF0CiS0Ua6LdFnTxjBLVsGpaX4LPWFk0zmHtVbYgtPOWi9kb(yX8FOese6Xqiu4Q5qyPDb0lh(AApmpkjmPMleiBmrWngEgvGpFLn)KHfZEU(MdHL2fqVC4RP9mQaF(kB(jdlMBoewAxa9YHVM2ZEel(kB(jdlMbYgteCJHhMhL0fI9i1Z13CiS0Ua6LdFnTN9iw8Fe6weMazJjcUXWtkOcM0J8ZhL(l8WuyU6ycWnhclTlGE5Wxt7rfsIrkQpHsGjq2yIGBm8KcQGj9i)8rP)cpmfMRoMaCZHWs7cOxo810EyEusxi2JuGSXeb3y4jfubt6r(5Js)fEykmxDmb4MdHL2fqVC4RP9ShXIVYMFYWIzGSXeb3y4jfubt6r(5Js)fEykmxtVDU5qyPDb0lh(AA)qjK4h(CmxaX4LPWFk0zmHtVbYgtPOWi9dJI)42kEmecfUagfhue(iekS5qyPDb0lh(AAVs2kFLaFaIXltH)uOZycNEdKnMOCboo6m67PgPO(kzR8fwYj5rHEeq5S(ECbmcUXW3tnsr9vYw5lSKtYJc9WuyU6a4AoewAxa9YHVM2ZEel(kB(jdlMbYgteCJHNuqfmPh5Npk9x4HPWC1XeGbMWsBl(Xajne2XepAoewAxa9YHVM2Z3IfmPMlS5qyPDb0lh(AApmpkjmPMlS5qyPDb0lh(AAVs2kFLaFAoewAxa9YHVM2pucj(HphZfqmEzk8NcDgt40BGSXefhue(iekS5qyPDb0lh(AA)qWFsLao4G2fnhclTlGE5Wxt7h0dMF4ZXC1CiS0Ua6LdFnT3y4hMuZf2CiS0Ua6LdFnTN9iw8v28tgwmdKnMi4gdpPGkyspYpFu6VWdtH5QJja3CiS0Ua6LdFnTFyu8h3wbiBmjS02I)1L(HsiXp85yU64DZHWs7cOxo810EuO5dgFyV5cBoewAxa9YHVM2JcnF(OcjXifvZHWs7cOxo810E(wSgCuE)5Lijq2yIGBm88Tyn4O8(ZlrspfjflGBepCU5O5WjDYgO2Izf2atHoJzduyPDrdSNAh1sEBGkdMnhclTlGEOfZkCIVflysnxyZHWs7cOhAXScFnTxjBLVsGpazJjcUXW)C5)rILNRhaaCckxGJJoJ(EQrkQVs2kFHLCsEuOhbuoRVhxaJGBm89uJuuFLSv(cl5K8OqpmfMRoaoEU5qyPDb0dTywHVM23tnYJUmr95lBrGSX0Mi4gdFp1ip6Ye1NVSf9C9nhclTlGEOfZk810EyEusysnxiq2yIYf44OZOFDh5NVflOhbuoRVhxaJGBm8R7i)8Tyb9C9nhclTlGEOfZk810EgvGpFLn)KHfZazJjkxGJJoJ(1DKF(wSGEeq5S(ECbmcUXWVUJ8Z3If0Z13CiS0Ua6HwmRWxt7ng(Hj1CHazJjkxGJJoJ(1DKF(wSGEeq5S(ECbmcUXWVUJ8Z3If0Z13CiS0Ua6HwmRWxt7hkHe)WNJ5ciBmTP0yUSyU5qyPDb0dTywHVM2VfH9i9NxIKnhclTlGEOfZk810(b9G5h(CmxazJjcUXW)iMcMhL0Z13CiS0Ua6HwmRWxt7rHMpy8H9MlS5qyPDb0dTywHVM2pe8NujGdoODrZHWs7cOhAXScFnTxzZpzyX8N4ujq2yAt9jfyeCJHhMhL0fI9i1Z13CiS0Ua6HwmRWxt7zpIfFLn)KHfZazJP(KcmcUXWdZJs6cXEK656BoewAxa9qlMv4RP9OcjXif1NqjWeiBmrWngEsbvWKEKF(O0FHhMcZvhtaU5qyPDb0dTywHVM2ZEel(pcDlctGSXeb3y4jfubt6r(5Js)fEykmxDmbyGrfB9XTyKEzTGEl6yAZDU5qyPDb0dTywHVM2RS5NmSy(tCQeiBmrWngEsbvWKEKF(O0FHhMcZ10BNBoewAxa9qlMv4RP9W8OKWKAUWMdHL2fqp0Izf(AApmpkPle7rkq2yIGBm8KcQGj9i)8rP)cpmfMRoMaCZHWs7cOhAXScFnTxjBLVsGpnhclTlGEOfZk810EgvGpFLn)KHfZnhclTlGEOfZk810(HsiXp85yUaIXltH)uOZycNEdKnMO4GIWhHqHnhclTlGEOfZk810(b9G5h(CmxnhclTlGEOfZk810EJHFysnxyZHWs7cOhAXScFnThYflKAXmq2yIk26JBXi9YAb9w0XeW7CZHWs7cOhAXScFnTFyu8h3wbiBmjS02I)1L(HsiXp85yUAoewAxa9qlMv4RP9kB(jdlM)eNkbYgteCJHNuqfmPh5Npk9x4HPWC1XeGBoewAxa9qlMv4RP9OqZNpQqsmsr1CiS0Ua6HwmRWxt75BXAWr59NxIKazJjcUXWZ3I1GJY7pVej9uKuSaUr8W5slC5ZrlT2i3mvwzva]] )

end
