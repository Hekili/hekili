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


    spec:RegisterPack( "Enhancement", 20210403, [[du0h0aqiaIhjq0Mau9jPkmkafNcqPxbGzbi3cvfv2Lq)sv0Wqv1XufwMsHNHQsttGW1aO2gaPVHQImouvOZPuuToLIuZtGu3tj2NuLoiQkkluPQhQueDrLIKpIQc4KkfLvkGzIQc6MOQOQDkv8tLIGLIQc0tj1uLQ6RkfHgRajTxj)vvnyGomXIb5XOmzfDzKnRWNvsJwv60uETuPztYTrLDt1Vvz4c64sv0YH65qMUORdQTRu67OkJxGeNxGA(kv2VuUEu9l9usQ6Sb)B8G)GGF(gF8aW8T0zWHuPdfwxzLkTlCuP3u(R4mIJ8S0HsWQtMv)sJoymJkT242KLgc2u5M5fuPNssvNn4FJh8he8Z34JhaEdadOLgfsSQZgakFl9RnNKxqLEsiwP3u(R4mIJ8SbQFfoXBb4ZcXMQbUbqnWn4FJhLwzOev9lnY8vfv9RopQ(LwyPDEP5z(eLyRlvAYfifnR9vwD2O6xAYfifnR9LMHTKWMuAi4Xi(E5)v8zeoSbUBxdeyAGyyNghELIHyJtuFLSv(clHL8WOi1tylmKMnqG3aHGhJyi24e1xjBLVWsyjpmkIsH1Tb2BdeqBGaBPfwANxALSv(kb9wz1HVv)stUaPOzTV0mSLe2Ksdinqi4XigInUdpnr95jBPiCyPfwANx6qSXD4PjQppzlvz1jiQ(LMCbsrZAFPzyljSjLgd704WRuCEh3NN5tuK6jSfgsZgiWBGqWJrCEh3NN5tueoS0clTZlnkpmhkXwxQYQdGR(LMCbsrZAFPzyljSjLgd704WRuCEh3NN5tuK6jSfgsZgiWBGqWJrCEh3NN5tueoS0clTZlndlO3VYwFt381kRoaA1V0KlqkAw7lndBjHnP0yyNghELIZ74(8mFIIupHTWqA2abEdecEmIZ74(8mFIIWHLwyPDEPng9rj26svwD4tv)stUaPOzTV0mSLe2KsJHDAC4vkoVJ7ZZ8jks9e2cdPzde4nqi4XioVJ7ZZ8jkchwAHL25Lgb7tcB(ALvh(y1V0KlqkAw7lndBjHnP0asdmnwxZxlTWs78spuch9rVhRBLvNnV6xAHL25LElHcj8pVK4kn5cKIM1(kRop4V6xAYfifnR9LMHTKWMuAi4Xi(kMcLhMlchwAHL25LEGpu(rVhRBLvNhpQ(LwyPDEPjbNVK)rHwxQ0KlqkAw7RS68yJQFPfwANx6Hq)eloAaJSZln5cKIM1(kRop4B1V0KlqkAw7lndBjHnP0qWJreLhMRlrHeochwAHL25LM9kM)v26B6MVwz15rqu9ln5cKIM1(sZWwsytkne8ye5esHs8X95rs45rukSUnWExAGaU0clTZlnPioYtr9HuckRS68aWv)stUaPOzTV0mSLe2KsdbpgroHuOeFCFEKeEEeLcRBdS3LgiGBGaVbIfB(PTKNrzorrZBG9U0a3C(lTWs78sZEfZ)VcElHYkRopa0QFPjxGu0S2xAg2scBsPHGhJiNqkuIpUppscppIsH1TbU0aFWFPfwANxALT(MU5RFOtLvwDEWNQ(LwyPDEPr5H5qj26sLMCbsrZAFLvNh8XQFPjxGu0S2xAg2scBsPHGhJiNqkuIpUppscppIsH1Tb27sdeWLwyPDEPr5H56suiHRS68yZR(LwyPDEPvYw5Re0BPjxGu0S2xz1zd(R(LwyPDEPzyb9(v26B6MVwAYfifnR9vwD24r1V0KlqkAw7lTWs78spuch9rVhRBPzyljSjLgtdmHEfifvAwWmf9tbVsjQ68OYQZgBu9lTWs78spWhk)O3J1T0KlqkAw7RS6SbFR(LwyPDEPng9rj26sLMCbsrZAFLvNncIQFPjxGu0S2xAg2scBsPXIn)0wYZOmNOO5nWExAGbb)LwyPDEPrW(KWMVwz1zdax9ln5cKIM1(sZWwsytkTWsBl9NxghkHJ(O3J1T0clTZl9WW03VTsLvNna0QFPjxGu0S2xAg2scBsPHGhJiNqkuIpUppscppIsH1Tb27sdeWLwyPDEPv26B6MV(Hovwz1zd(u1V0clTZlnj489tkIJ8uuLMCbsrZAFLvNn4Jv)stUaPOzTV0mSLe2KsdbpgrEMphW4G)5LexetCI5Ogyq3a5l)LwyPDEP5z(CaJd(NxsCvwzPLJQ(vNhv)stUaPOzTV0mSLe2KsdbpgrgwqVFLT(MU5Rr4WslS0oV08mFIsS1LQS6Sr1V0KlqkAw7lndBjHnP0Odwbz(mUIVT038T26HL0opsUaPOzdC3Ugi6GvqMpJdJuZ)n(qQdHoouKCbsrZslS0oV0dH(jwC0agzNxz1HVv)stUaPOzTV0mSLe2KsJHDAC4vkoVJ7ZZ8jks9e2cdPzde4nqi4XioVJ7ZZ8jkchwAHL25LMHf07xzRVPB(ALvNGO6xAYfifnR9LMHTKWMuAi4Xi(kMcLhMlchwAHL25LEGpu(rVhRBLvhax9lTWs78sJG9jHnFT0KlqkAw7RS6aOv)stUaPOzTV0clTZl9qjC0h9ESULMHTKWMuAmnWe6vGuude4nqGPbMII8momm99BRejxGu0SbUBxdmff5zujOxZx)dLWrOi5cKIMnWD7AGSBl5INrNy4tD4zdC3Ugig2PXHxPyi24e1xjBLVWsyjpmks9e2cdPzdeylnlyMI(PGxPevDEuz1Hpv9ln5cKIM1(slS0oV0HyJ7WttuFEYwQ0mSLe2Ksdinqi4XigInUdpnr95jBPiCyPzbZu0pf8kLOQZJkRo8XQFPjxGu0S2xAg2scBsPfwABP)8Y4qjC0h9ESUnWExAG8T0clTZl9WW03VTsLvNnV6xAHL25LElHcj8pVK4kn5cKIM1(kRop4V6xAYfifnR9LMHTKWMuAi4XigInUdpnr95jBPiCyde4nqi4XiYjKcL4J7ZJKWZJOuyDBG9U0abCPfwANxALT(MU5RFOtLvwDE8O6xAYfifnR9LMHTKWMuAi4XiIYdZ1LOqchHdlTWs78sZEfZ)kB9nDZxRS68yJQFPjxGu0S2xAg2scBsPtrrEgzyb9A(6hLhMlsUaPOzdC3Ugie8yezyb9(v26B6MVgNhpV0clTZlndlO3VYwFt381kRop4B1V0KlqkAw7lTWs78sRKTYxjO3sZWwsytkDkkYZOsqVMV(hkHJqrYfifnlnlyMI(PGxPevDEuz15rqu9ln5cKIM1(sZWwsytkne8yezyb9(v26B6MVgHdBGaVbcmnqi4Xi(E5)v8zeoSbUBxdeyAGyyNghELIHyJtuFLSv(clHL8WOi1tylmKMnqG3aHGhJyi24e1xjBLVWsyjpmkIsH1Tb2BdeqBGaBdeylTWs78sRKTYxjO3kRopaC1V0KlqkAw7lndBjHnP0qWJrKHf07xzRVPB(AeoS0clTZlnkpmhkXwxQYQZdaT6xAHL25LMHf07xzRVPB(APjxGu0S2xz15bFQ6xAYfifnR9LMHTKWMuAi4XiYjKcL4J7ZJKWZJOuyDBG9U0abCPfwANxA2Ry()vWBjuwz15bFS6xAYfifnR9LMHTKWMuAi4XiYjKcL4J7ZJKWZJOuyDBG9U0abCPfwANxAsrCKNI6dPeuwz15XMx9ln5cKIM1(sZWwsytkne8ye5esHs8X95rs45rukSUnWExAGaU0clTZlnkpmxxIcjCLvNn4V6xAYfifnR9LMHTKWMuAi4XiYjKcL4J7ZJKWZJOuyDBGlnWh8xAHL25LM9kM)v26B6MVwz1zJhv)slS0oV08mFIsS1Lkn5cKIM1(kRoBSr1V0clTZlnkpmhkXwxQ0KlqkAw7RS6SbFR(LwyPDEPvYw5Re0BPjxGu0S2xz1zJGO6xAYfifnR9LwyPDEPhkHJ(O3J1T0mSLe2KsJPbMqVcKIknlyMI(PGxPevDEuz1zdax9lTWs78spe6NyXrdyKDEPjxGu0S2xz1zdaT6xAHL25LEGpu(rVhRBPjxGu0S2xz1zd(u1V0clTZlTXOpkXwxQ0KlqkAw7RS6SbFS6xAYfifnR9LMHTKWMuAi4XiYjKcL4J7ZJKWZJOuyDBG9U0abCPfwANxA2Ry(xzRVPB(ALvNn28QFPjxGu0S2xAg2scBsPfwABP)8Y4qjC0h9ESUnWEBGpkTWs78spmm99BRuz1HV8x9lTWs78stcoFj)JcTUuPjxGu0S2xz1HVpQ(LwyPDEPjbNVFsrCKNIQ0KlqkAw7RS6W3nQ(LMCbsrZAFPzyljSjLgcEmI8mFoGXb)ZljUiM4eZrnWGUbYx(lTWs78sZZ85agh8pVK4QSYspPHaRYQF15r1V0clTZlnK6UPcgLLMCbsrZcQYQZgv)stUaPOzTV0mSLe2KsdDiude4nWHT(MFmXjMJAGbDdeq5V0tcXWwyANx6nZ5ZXooijBGHxAN3anudeIghMAGSJdsYgi5tuS0clTZlD4L25vwD4B1V0KlqkAw7l9KqmSfM25LEZ8KWy4WS0clTZlnpZNF0lj4kRobr1V0clTZlnmI(wsCOstUaPOzTVYQdGR(LMCbsrZAFPzyljSjLgqAGPOipJcIr(uCgfjxGu0SbUBxdecEmIcIr(uCgfHdBG721az3PMhppkig5tXzuetCI5OgyVnqaZFPfwANxAi1DZ)aghCLvhaT6xAYfifnR9LMHTKWMuAaPbMII8mkig5tXzuKCbsrZg4UDnqi4Xikig5tXzueoS0clTZlneHreUR5RvwD4tv)stUaPOzTV0mSLe2KsdinWuuKNrbXiFkoJIKlqkA2a3TRbcbpgrbXiFkoJIWHnWD7AGS7uZJNhfeJ8P4mkIjoXCudS3giG5V0clTZl9WWeK6UzLvh(y1V0KlqkAw7lndBjHnP0asdmff5zuqmYNIZOi5cKIMnWD7AGqWJruqmYNIZOiCydC3Ugi7o1845rbXiFkoJIyItmh1a7Tbcy(lTWs78sloJqjwuFMOuvwD28QFPjxGu0S2xAg2scBsPbKgykkYZOGyKpfNrrYfifnBG721abKgie8yefeJ8P4mkchwAHL25Lgsw)34NyJ1fvz15b)v)slS0oV0dclQpk0WwwAYfifnR9vwDE8O6xAYfifnR9LMHTKWMuAGPbMII8mkig5tXzuKCbsrZg4UDnqmStJdVsX5DCFEMprrQNWwyinBGaBde4nqGPbIoyfK5Z4k(2sFZ3ARhws78i5cKIMnWD7AGOdwbz(momsn)34dPoe64qrYfifnBG721afwABPp5eNrOg4sd8rdeylTWs78spe6NyXrdyKDELvNhBu9ln5cKIM1(sZWwsytknwS5N2sEgL5efnVb27sdCZ5VbUBxduyPTL(KtCgHAG92aFuAHL25LwqmYNIZOkRop4B1V0KlqkAw7lndBjHnP0yyNghELIZ74(8mFIIupHTWqA2abEdecEmIZ74(8mFI(tccEmIZJN3abEdeyAGyXMFAl5zuMtu08gyVlnqaL)g4UDnqHL2w6toXzeQb2Bd8rdeyBG721aHGhJipZNdyCW)8sIlopEEPfwANxAEMphW4G)5LexLvNhbr1V0KlqkAw7l9KqmSfM25LEZgnWZvb3apNAGKtCbdudmeBh2YGBGJtPoEOgy(snWEGmFvr9ObkS0oVbQmuglTWs78sZeL6lS0o)RmuwAg2scBsPfwABPp5eNrOg4sd8rPvgk)UWrLgz(QIQS68aWv)stUaPOzTV0tcXWwyANx6nbVbYbRslurnqYjoJqa1aZxQbgITdBzWnWXPuhpudmFPgypKJ6rduyPDEduzOmwAHL25LMjk1xyPD(xzOS0mSLe2KslS02sFYjoJqnWEBGpkTYq53foQ0YrvwDEaOv)slS0oV0Sd2tcJsS1L(5LexPjxGu0S2xz15bFQ6xAHL25Lg1n4bmo4FEjXvAYfifnR9vwDEWhR(LwyPDEPdXgNO(OeBDPstUaPOzTVYklDiMyhhKKv)QZJQFPjxGu0S2xAg2scBsPHGhJipZNdyCWFEKeEEetCI5Ogyq3a5l)8xAHL25LMN5Zbmo4ppscpVYQZgv)stUaPOzTV0mSLe2KsdbpgXHs4O88vy6ZJKWZJyItmh1ad6giF5N)slS0oV0dLWr55RW0NhjHNxz1HVv)slS0oV0qxMkA(hkjyAYZ81FEbfZln5cKIM1(kRobr1V0KlqkAw7lndBjHnP0qWJruzRVPB(6h9AKAgXeNyoQbg0nq(Yp)LwyPDEPv26B6MV(rVgPMvwDaC1V0KlqkAw7lndBjHnP0asded704WRuCEh3NN5tuK6jSfgsZgiWBGqWJrKN5Zbmo4FEjXfNhpV0clTZlnpZNdyCW)8sIRYQdGw9ln5cKIM1(sZWwsytkDkkYZikpmxxIcjCKCbsrZslS0oV0O8WCDjkKWvwzLLElHr25vNn4FJh8Z3h8hFuAEc2nFfv6nr(m(GD2So8b20nWgy)xQbACHhoBGJd3a7HCupAGyQNWgMMnq0XrnqbopojPzdK9k(kHITa8HMtnWn20nWn55BjCsZgypqhScY8zmO2JgyEnWEGoyfK5ZyqnsUaPOzpAGaZJGcWgBb4dnNAGBSPBGBYZ3s4KMnWEGoyfK5ZyqThnW8AG9aDWkiZNXGAKCbsrZE0aLSbUP2e4dBGaZJGcWgBbAb2e5Z4d2zZ6Whyt3aBG9FPgOXfE4SbooCdShtAiWQShnqm1tydtZgi64OgOaNhNK0SbYEfFLqXwa(qZPg4JhB6g4M88TeoPzdShOdwbz(mgu7rdmVgypqhScY8zmOgjxGu0ShnqGzJGcWgBbAb2mUWdN0SbgenqHL25nqLHsuSfO0H4BykQ0bzq2a3u(R4mIJ8SbQFfoXBbcYGSbYNfInvdCdGAGBW)gpAbAbewANJIHyIDCqsUWZ85agh8NhjHNdKnwGGhJipZNdyCWFEKeEEetCI5OGMV8ZFlGWs7CumetSJdssawEouchLNVctFEKeEoq2ybcEmIdLWr55RW0NhjHNhXeNyokO5l)83ciS0ohfdXe74GKeGLNqxMkA(hkjyAYZ81FEbfZBbewANJIHyIDCqscWYtLT(MU5RF0RrQjq2ybcEmIkB9nDZx)OxJuZiM4eZrbnF5N)waHL25OyiMyhhKKaS8KN5Zbmo4FEjXbKnwaemStJdVsX5DCFEMprrQNWwyinboe8ye5z(CaJd(NxsCX5XZBbewANJIHyIDCqscWYtuEyUUefsyGSXskkYZikpmxxIcjCKCbsrZwGwGGmiBGBQGcXGtA2aPTeo4gyACudmFPgOWYd3anudu2kMsGuuSfqyPDoAbsD3ubJYwGGSbUzoFo2Xbjzdm8s78gOHAGq04WudKDCqs2ajFIITaclTZraS8m8s7CGSXc0HqaFyRV5htCI5OGgq5VfiiBGBMNegdhMTaclTZraS8KN5Zp6LeClGWs7CealpHr03sId1ciS0ohbWYti1DZ)aghmq2ybqsrrEgfeJ8P4mksUaPO5UDqWJruqmYNIZOiC4UDS7uZJNhfeJ8P4mkIjoXCuVaM)waHL25iawEcryeH7A(kq2ybqsrrEgfeJ8P4mksUaPO5UDqWJruqmYNIZOiCylGWs7CealphgMGu3nbYglaskkYZOGyKpfNrrYfifn3TdcEmIcIr(uCgfHd3TJDNAE88OGyKpfNrrmXjMJ6fW83ciS0ohbWYtXzekXI6ZeLciBSaiPOipJcIr(uCgfjxGu0C3oi4Xikig5tXzueoC3o2DQ5XZJcIr(uCgfXeNyoQxaZFlGWs7CealpHK1)n(j2yDrazJfajff5zuqmYNIZOi5cKIM72biqWJruqmYNIZOiCylGWs7CealphewuFuOHTSfqyPDocGLNdH(jwC0agzNdKnwaMuuKNrbXiFkoJIKlqkAUBhg2PXHxP48oUppZNOi1tylmKMalWbg0bRGmFgxX3w6B(wB9WsANVBh6GvqMpJdJuZ)n(qQdHoo0UDclTT0NCIZi0YdGTfqyPDocGLNcIr(uCgbKnwWIn)0wYZOmNOO59US58VBNWsBl9jN4mc17JwaHL25iawEYZ85agh8pVK4aYglyyNghELIZ74(8mFIIupHTWqAcCi4XioVJ7ZZ8j6pji4XiopEoWbgSyZpTL8mkZjkAEVlak)72jS02sFYjoJq9(ay3TdcEmI8mFoGXb)ZljU4845TabzdCZgnWZvb3apNAGKtCbdudmeBh2YGBGJtPoEOgy(snWEGmFvr9ObkS0oVbQmugBbewANJay5jtuQVWs78VYqjqUWrliZxveq2yryPTL(KtCgHwE0ceKnWnbVbYbRslurnqYjoJqa1aZxQbgITdBzWnWXPuhpudmFPgypKJ6rduyPDEduzOm2ciS0ohbWYtMOuFHL25FLHsGCHJwKJaYglclTT0NCIZiuVpAbewANJay5j7G9KWOeBDPFEjX1ciS0ohbWYtu3GhW4G)5LexlGWs7CealpdXgNO(OeBDPwGwGGmiBG85HvP1atbVszduyPDEdmeBh2YGBGkdLTaclTZrr5OfEMprj26sazJfi4XiYWc69RS130nFnch2ciS0ohfLJay55qOFIfhnGr25azJf0bRGmFgxX3w6B(wB9WsANVBh6GvqMpJdJuZ)n(qQdHooulGWs7CuuocGLNmSGE)kB9nDZxbYglyyNghELIZ74(8mFIIupHTWqAcCi4XioVJ7ZZ8jkch2ciS0ohfLJay55aFO8JEpwxGSXce8yeFftHYdZfHdBbewANJIYraS8eb7tcB(AlGWs7CuuocGLNdLWrF07X6celyMI(PGxPeT8aiBSGPbMqVcKIaoWKII8momm99BRejxGu0C3UuuKNrLGEnF9puchHIKlqkAUBh72sU4z0jg(uhEUBhg2PXHxPyi24e1xjBLVWsyjpmks9e2cdPjW2ciS0ohfLJay5zi24o80e1NNSLaIfmtr)uWRuIwEaKnwaei4XigInUdpnr95jBPiCylGWs7CuuocGLNddtF)2kazJfHL2w6pVmouch9rVhRBVl8TfqyPDokkhbWYZTekKW)8sIRfqyPDokkhbWYtLT(MU5RFOtLazJfi4XigInUdpnr95jBPiCiWHGhJiNqkuIpUppscppIsH1T3fa3ciS0ohfLJay5j7vm)RS130nFfiBSabpgruEyUUefs4iCylGWs7CuuocGLNmSGE)kB9nDZxbYglPOipJmSGEnF9JYdZfjxGu0C3oi4XiYWc69RS130nFnopEElGWs7CuuocGLNkzR8vc6fiwWmf9tbVsjA5bq2yjff5zujOxZx)dLWrOi5cKIMTaclTZrr5iawEQKTYxjOxGSXce8yezyb9(v26B6MVgHdboWabpgX3l)VIpJWH72bmyyNghELIHyJtuFLSv(clHL8WOi1tylmKMahcEmIHyJtuFLSv(clHL8WOikfw3EbuGfyBbewANJIYraS8eLhMdLyRlbKnwGGhJidlO3VYwFt381iCylGWs7CuuocGLNmSGE)kB9nDZxBbewANJIYraS8K9kM)Ff8wcLazJfi4XiYjKcL4J7ZJKWZJOuyD7DbWTaclTZrr5iawEskIJ8uuFiLGsGSXce8ye5esHs8X95rs45rukSU9Ua4waHL25OOCealpr5H56suiHbYglqWJrKtifkXh3NhjHNhrPW627cGBbewANJIYraS8K9kM)v26B6MVcKnwGGhJiNqkuIpUppscppIsH1D5b)TaclTZrr5iawEYZ8jkXwxQfqyPDokkhbWYtuEyouITUulGWs7CuuocGLNkzR8vc6TfqyPDokkhbWYZHs4Op69yDbIfmtr)uWRuIwEaKnwW0atOxbsrTaclTZrr5iawEoe6NyXrdyKDElGWs7CuuocGLNd8HYp69yDBbewANJIYraS80y0hLyRl1ciS0ohfLJay5j7vm)RS130nFfiBSabpgroHuOeFCFEKeEEeLcRBVlaUfqyPDokkhbWYZHHPVFBfGSXIWsBl9NxghkHJ(O3J1T3hTaclTZrr5iawEscoFj)JcTUulGWs7CuuocGLNKGZ3pPioYtr1ciS0ohfLJay5jpZNdyCW)8sIdiBSabpgrEMphW4G)5LexetCI5OGMV83c0ceKbzduB(QIAGPGxPSbkS0oVbgITdBzWnqLHYwaHL25OiY8vfTWZ8jkXwxQfqyPDokImFvraS8ujBLVsqVazJfi4Xi(E5)v8zeoC3oGbd704WRumeBCI6RKTYxyjSKhgfPEcBHH0e4qWJrmeBCI6RKTYxyjSKhgfrPW62lGcSTaclTZrrK5RkcGLNHyJ7WttuFEYwciBSaiqWJrmeBChEAI6Zt2sr4WwaHL25OiY8vfbWYtuEyouITUeq2ybd704WRuCEh3NN5tuK6jSfgstGdbpgX5DCFEMprr4WwaHL25OiY8vfbWYtgwqVFLT(MU5RazJfmStJdVsX5DCFEMprrQNWwyinboe8yeN3X95z(efHdBbewANJIiZxvealpng9rj26sazJfmStJdVsX5DCFEMprrQNWwyinboe8yeN3X95z(efHdBbewANJIiZxvealprW(KWMVcKnwWWono8kfN3X95z(efPEcBHH0e4qWJrCEh3NN5tueoSfqyPDokImFvraS8COeo6JEpwxGSXcGKgRR5RTaclTZrrK5RkcGLNBjuiH)5LexlGWs7Cuez(QIay55aFO8JEpwxGSXce8yeFftHYdZfHdBbewANJIiZxvealpjbNVK)rHwxQfqyPDokImFvraS8Ci0pXIJgWi78waHL25OiY8vfbWYt2Ry(xzRVPB(kq2ybcEmIO8WCDjkKWr4WwaHL25OiY8vfbWYtsrCKNI6dPeucKnwGGhJiNqkuIpUppscppIsH1T3fa3ciS0ohfrMVQiawEYEfZ)VcElHsGSXce8ye5esHs8X95rs45rukSU9UayGJfB(PTKNrzorrZ7DzZ5VfqyPDokImFvraS8uzRVPB(6h6ujq2ybcEmICcPqj(4(8ij88ikfw3Lh83ciS0ohfrMVQiawEIYdZHsS1LAbewANJIiZxvealpr5H56suiHbYglqWJrKtifkXh3NhjHNhrPW627cGBbewANJIiZxvealpvYw5Re0BlGWs7Cuez(QIay5jdlO3VYwFt381waHL25OiY8vfbWYZHs4Op69yDbIfmtr)uWRuIwEaKnwW0atOxbsrTaclTZrrK5RkcGLNd8HYp69yDBbewANJIiZxvealpng9rj26sTaclTZrrK5RkcGLNiyFsyZxbYglyXMFAl5zuMtu08Excc(BbewANJIiZxvealphgM((TvaYglclTT0FEzCOeo6JEpw3waHL25OiY8vfbWYtLT(MU5RFOtLazJfi4XiYjKcL4J7ZJKWZJOuyD7DbWTaclTZrrK5RkcGLNKGZ3pPioYtr1ciS0ohfrMVQiawEYZ85agh8pVK4aYglqWJrKN5Zbmo4FEjXfXeNyokO5l)LwGZ3dxATXTjRSYQaa]] )


end
