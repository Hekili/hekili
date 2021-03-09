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


    spec:RegisterPack( "Enhancement", 20210308, [[duKQZaqiLeEeQISjuf(KKcJcqYPaO6vQIMfG6waePDrv)svyyOkDmaSmLKEgvetdvrDnaX2aO8nacJtsroNKIADae18OIu3tj2NKsheqkAHkv9qasCras6JasjNeGuRKkmtaPYnbiIDsL6Nasvlfqk8usnvjvFfqk1yPIe7vQ)QQgmqhMyXq8yuMSIUmYMv4ZkLrRkDAkVMkz2KCBuz3c)wLHljhxjrlhQNdA6IUoK2UsLVJQA8ursNNkQ5RKA)sCdqxV1tjP29Q8Uka86eERj)QaaeabpZZToDUIADLWCjBuRdHJAnGA8kbJ4OiBDL4S6KzxV1WdfZOwRnoaLwJGAQeqhnsRNssT7v5Dva41j8wt(vbaiacNuZTgwrS29QaMtA9RnNu0iTEsqwRbuJxjyehfzbu)kCsuCairWS3cynbCbCvExfGwRmyc76TgAXMI66TBa66TwyPDrR5BXeMyZf1Akeefn79D2UxTR3Akeefn79TMHTKWM0Ae0XW)E5)vIPhTQaUEDbeOkGy0GghEJ8vyJtuFLSt(clrL8WqpTsuRQIMfqEuarqhdFf24e1xj7KVWsujpm0dtH5QawBbeWkGaERfwAx0ALSt(kb(2z72jD9wtHGOOzVV1mSLe2KwVIcic6y4RWg3HNMO(8LDKhTQ1clTlADf24o80e1NVSJ6SDZZD9wtHGOOzVV1mSLe2KwJrdAC4nYpVJ7Z3Ij0tRe1QQOzbKhfqe0XWpVJ7Z3Ij0Jw1AHL2fTgMhMdMyZf1z7giD9wtHGOOzVV1mSLe2KwJrdAC4nYpVJ7Z3Ij0tRe1QQOzbKhfqe0XWpVJ7Z3Ij0Jw1AHL2fTMHf47xzBVzyXwNTBaRR3Akeefn79TMHTKWM0AmAqJdVr(5DCF(wmHEALOwvfnlG8OaIGog(5DCF(wmHE0QwlS0UO1gJ(WeBUOoB3aIUERPqqu0S33Ag2scBsRxrbmnMll2ATWs7Iwpuch9HVhZvNT7AQR3AHL2fTEhbRi8pVK4AnfcIIM9(oB31CxV1uiikA27BndBjHnP1iOJH)vmfmpmNhTQ1clTlA9aFW8dFpMRoB3aWBxV1clTlAnj48LIpSYCrTMcbrrZEFNTBaaOR3AHL2fTEi0pXsahOq7IwtHGOOzVVZ2naR21BnfcIIM9(wZWwsytA9kkGvjUaYJcic6y4H5H5CrufH9OvTwyPDrRv22BgwS9rov2z7gaN01BnfcIIM9(wZWwsytADvIlG8OaIGogEyEyoxevrypAvRfwAx0A2RyXxzBVzyXwNTBa45UERPqqu0S33Ag2scBsRrqhdpNqkyIpUpFsQUWdtH5Qaw7sbeiTwyPDrRjfXrrkQpIsGzNTBaasxV1uiikA27BndBjHnP1iOJHNtifmXh3Npjvx4HPWCvaRDPacKcipkGyXMFAhfPxMtO3IcyTlfWAM3wlS0UO1SxXI)RG3rWSZ2naawxV1uiikA27BndBjHnP1iOJHNtifmXh3Npjvx4HPWCvaxkGaWBRfwAx0ALT9MHfBFKtLD2Ubaq01BTWs7IwdZdZbtS5IAnfcIIM9(oB3autD9wtHGOOzVV1mSLe2KwJGogEoHuWeFCF(KuDHhMcZvbS2LciqATWs7IwdZdZ5IOkc3z7gGAUR3AHL2fTwj7KVsGVTMcbrrZEFNT7v5TR3AHL2fTMHf47xzBVzyXwRPqqu0S33z7Eva66TMcbrrZEFRfwAx06Hs4Op89yUAndBjHnP1yAGj4RGOOwZCMPOFk4nkHTBa6SDV6QD9wlS0UO1d8bZp89yUAnfcIIM9(oB3R6KUERfwAx0AJrFyInxuRPqqu0S33z7EvEUR3Akeefn79TMHTKWM0ASyZpTJI0lZj0BrbS2LcipZBRfwAx0AiAmjSfBD2UxfiD9wtHGOOzVV1mSLe2KwlS02r)5L(Hs4Op89yUATWs7Iwpmm9JBN0z7EvaRR3Akeefn79TMHTKWM0Ae0XWZjKcM4J7ZNKQl8WuyUkG1UuabsRfwAx0ALT9MHfBFKtLD2Uxfq01BTWs7IwtcoF)KI4OifvRPqqu0S33z7E1AQR3Akeefn79TMHTKWM0Ae0XWZ3I5af78pVK48yItSawaD6cOt4T1clTlAnFlMduSZ)8sIRZoBTCuxVDdqxV1uiikA27BndBjHnP1iOJHNHf47xzBVzyXMhTQ1clTlAnFlMWeBUOoB3R21BnfcIIM9(wZWwsytAn8qviwm9B4Bh9TyNTDyjTl8uiikAwaxVUacpufIft)Wi18FJpI6GWJd6Pqqu0S1clTlA9qOFILaoqH2fD2UDsxV1uiikA27BndBjHnP1y0GghEJ8Z74(8Tyc90krTQkAwa5rbebDm8Z74(8Tyc9OvTwyPDrRzyb((v22BgwS1z7MN76TMcbrrZEFRzyljSjTgbDm8VIPG5H58OvTwyPDrRh4dMF47XC1z7giD9wlS0UO1q0ysyl2AnfcIIM9(oB3awxV1uiikA27BTWs7Iwpuch9HVhZvRzyljSjTgtdmbFfefva5rbeOkGPOOi9ddt)42jEkeefnlGRxxatrrr6vc81IT)qjCe0tHGOOzbC96ci72rHePpig(uhEwaxVUaIrdAC4nYxHnor9vYo5lSevYdd90krTQkAwab8wZCMPOFk4nkHTBa6SDdi66TMcbrrZEFRfwAx06kSXD4PjQpFzh1Ag2scBsRxrbebDm8vyJ7WttuF(YoYJw1AMZmf9tbVrjSDdqNT7AQR3Akeefn79TMHTKWM0AHL2o6pV0puch9HVhZvbS2LcOtATWs7Iwpmm9JBN0z7UM76TwyPDrR3rWkc)ZljUwtHGOOzVVZ2na821BnfcIIM9(wZWwsytAnc6y4RWg3HNMO(8LDKhTQaYJciqvarqhdpmpmNlIQiShTQaUEDbebDm8CcPGj(4(8jP6cpmfMRcyTlfqGuab8wlS0UO1kB7ndl2(iNk7SDdaaD9wtHGOOzVV1mSLe2KwJGogEyEyoxevrypAvRfwAx0A2RyXxzBVzyXwNTBawTR3Akeefn79TMHTKWM06uuuKEgwGVwS9H5H58uiikAwaxVUaIGogEgwGVFLT9MHfB(5XpATWs7IwZWc89RST3mSyRZ2naoPR3Akeefn79TwyPDrRvYo5Re4BRzyljSjTofffPxjWxl2(dLWrqpfcIIMfW1RlGavbeJg04WBKVcBCI6RKDYxyjQKhg6PvIAvv0SaYJcic6y4RWgNO(kzN8fwIk5HHEykmxfWAlGawbeWBnZzMI(PG3Oe2UbOZ2na8CxV1uiikA27BndBjHnP1iOJHNHf47xzBVzyXMhTQ1clTlAnmpmhmXMlQZ2naaPR3AHL2fTMHf47xzBVzyXwRPqqu0S33z7gaaRR3Akeefn79TMHTKWM0Ae0XWZjKcM4J7ZNKQl8WuyUkG1UuabsRfwAx0A2RyX)vW7iy2z7gaarxV1uiikA27BndBjHnP1iOJHNtifmXh3Npjvx4HPWCvaRDPacKwlS0UO1KI4Oif1hrjWSZ2na1uxV1uiikA27BndBjHnP1iOJHNtifmXh3Npjvx4HPWCvaRDPacKwlS0UO1W8WCUiQIWD2UbOM76TMcbrrZEFRzyljSjTgbDm8CcPGj(4(8jP6cpmfMRc4sbeaEBTWs7IwZEfl(kB7ndl26SDVkVD9wlS0UO18TyctS5IAnfcIIM9(oB3RcqxV1clTlAnmpmhmXMlQ1uiikA277SDV6QD9wlS0UO1kzN8vc8T1uiikA277SDVQt66TMcbrrZEFRfwAx06Hs4Op89yUAndBjHnP1yAGj4RGOOwZCMPOFk4nkHTBa6SDVkp31BTWs7Iwpe6NyjGduODrRPqqu0S33z7EvG01BTWs7IwpWhm)W3J5Q1uiikA277SDVkG11BTWs7IwBm6dtS5IAnfcIIM9(oB3Rci66TMcbrrZEFRzyljSjTgbDm8CcPGj(4(8jP6cpmfMRcyTlfqG0AHL2fTM9kw8v22BgwS1z7E1AQR3Akeefn79TMHTKWM0AHL2o6pV0puch9HVhZvbS2ciaTwyPDrRhgM(XTt6SDVAn31BTWs7IwtcoFP4dRmxuRPqqu0S33z72j821BTWs7IwtcoF)KI4OifvRPqqu0S33z72ja01BnfcIIM9(wZWwsytAnc6y45BXCGID(NxsCEmXjwalGoDb0j82AHL2fTMVfZbk25FEjX1zNTEsdbvLD92naD9wlS0UO1iQ7Mkuy2AkeefnBKoB3R21BnfcIIM9(wZWwsytAnYbHfqEuah22B(XeNybSa60fqaJ3wpjidBvPDrRb0bGu2XHizbS6s7IcOblGi04WubKDCiswaPyc9TwyPDrRRU0UOZ2Tt66TMcbrrZEFRNeKHTQ0UO1a6ijmgTklG3OaYeyc9TwyPDrR5BX8dFjb3z7MN76TwyPDrRrH03sId2Akeefn79D2UbsxV1uiikA27BndBjHnP1ROaMIII0lqgftjyKNcbrrZc461fqe0XWlqgftjyKhTQaUEDbKDNAE8dVazumLGrEmXjwalG1wabcVTwyPDrRru3n)duSZD2UbSUERPqqu0S33Ag2scBsRxrbmfffPxGmkMsWipfcIIMfW1RlGiOJHxGmkMsWipAvRfwAx0AecdjSll26SDdi66TMcbrrZEFRzyljSjTEffWuuuKEbYOykbJ8uiikAwaxVUaIGogEbYOykbJ8OvfW1RlGS7uZJF4fiJIPemYJjoXcybS2ciq4T1clTlA9WWeI6UzNT7AQR3Akeefn79TMHTKWM06vuatrrr6fiJIPemYtHGOOzbC96cic6y4fiJIPemYJwvaxVUaYUtnp(HxGmkMsWipM4elGfWAlGaH3wlS0UO1sWiyIf1NjkvNT7AUR3Akeefn79TMHTKWM06vuatrrr6fiJIPemYtHGOOzbC96c4kkGiOJHxGmkMsWipAvRfwAx0Aez7FJFInMlyNTBa4TR3AHL2fTEqyr9Hvg2YwtHGOOzVVZ2naa01BnfcIIM9(wZWwsytAnqvatrrr6fiJIPemYtHGOOzbC96cignOXH3i)8oUpFlMqpTsuRQIMfqaVaYJciqvaHhQcXIPFdF7OVf7STdlPDHNcbrrZc461fq4HQqSy6hgPM)B8ruheECqpfcIIMfW1RlGclTD0NcIZiybCPacqbeWBTWs7Iwpe6NyjGduODrNTBawTR3Akeefn79TMHTKWM0ASyZpTJI0lZj0BrbS2LcynZBbC96cOWsBh9PG4mcwaRTacqRfwAx0AbYOykbJ6SDdGt66TMcbrrZEFRzyljSjTgJg04WBKFEh3NVftONwjQvvrZcipkGiOJHFEh3NVft4FsiOJHFE8JcipkGavbel28t7Oi9YCc9wuaRDPacy8waxVUakS02rFkioJGfWAlGauab8c461fqe0XWZ3I5af78pVK48ZJF0AHL2fTMVfZbk25FEjX1z7gaEUR3Akeefn79TEsqg2Qs7IwdOhfWluoxaVGkGuqCodCbScBh2sNlGJtPo(Wcy(sfWAaTytr1OakS0UOaQmy6BTWs7IwZeL6lS0U4Rmy2Ag2scBsRfwA7OpfeNrWc4sbeGwRmy(dHJAn0Inf1z7gaG01BnfcIIM9(wpjidBvPDrRb6JcihQkTkfvaPG4mccCbmFPcyf2oSLoxahNsD8HfW8LkG1qoQgfqHL2ffqLbtFRfwAx0AMOuFHL2fFLbZwZWwsytATWsBh9PG4mcwaRTacqRvgm)HWrTwoQZ2naawxV1clTlAn7qJKWWeBUOFEjX1Akeefn79D2Ubaq01BTWs7IwdD58af78pVK4AnfcIIM9(oB3autD9wlS0UO1vyJtuFyInxuRPqqu0S33zNTUctSJdrYUE7gGUERPqqu0S33Ag2scBsRrqhdpFlMduSZF(KuDHhtCIfWcOtxaDcV82AHL2fTMVfZbk25pFsQUOZ29QD9wtHGOOzVV1mSLe2KwJGog(Hs4O8Inu6ZNKQl8yItSawaD6cOt4L3wlS0UO1dLWr5fBO0Npjvx0z72jD9wlS0UO1ixMkA(hkXzAY3ITFEovlAnfcIIM9(oB38CxV1uiikA27BndBjHnP1iOJHxzBVzyX2h(AKA6XeNybSa60fqNWlVTwyPDrRv22BgwS9HVgPMD2UbsxV1uiikA27BndBjHnP1ROaIrdAC4nYpVJ7Z3Ij0tRe1QQOzbKhfqe0XWZ3I5af78pVK48ZJF0AHL2fTMVfZbk25FEjX1z7gW66TMcbrrZEFRzyljSjTofffPhMhMZfrve2tHGOOzRfwAx0AyEyoxevr4o7SZwVJWq7I29Q8Uka86eEbeTMVGdl2GTgOnqtGgUb0UbAbixalG1FPcOXvD4SaooCbSgYr1OaIPvIAyAwaHhhvaf084KKMfq2ReBe0xCa0zbvaxfqUacOCXocN0Sawd4HQqSy6Dk1OaMxbSgWdvHyX07u8uiikAwJciqbGtfW9fhaDwqfWvbKlGakxSJWjnlG1aEOkelMENsnkG5vaRb8qviwm9ofpfcIIM1OakzbeqfOhORacua4ubCFXrXbqBGManCdODd0cqUawaR)sfqJR6WzbCC4cynM0qqvznkGyALOgMMfq4XrfqbnpojPzbK9kXgb9fhaDwqfqaaaqUacOCXocN0Sawd4HQqSy6Dk1OaMxbSgWdvHyX07u8uiikAwJciqTQtfW9fhfhaAUQdN0SaYZfqHL2ffqLbtOV4O1cA(E4wRnoaLwxHVHPOwZt8ubeqnELGrCuKfq9RWjrXbpXtfqajcM9waRjGlGRY7QauCuCiS0Ua6RWe74qKCHVfZbk25pFsQUayBSGGogE(wmhOyN)8jP6cpM4elGoTt4L3IdHL2fqFfMyhhIKpxEmuchLxSHsF(KuDbW2ybbDm8dLWr5fBO0Npjvx4XeNyb0PDcV8wCiS0Ua6RWe74qK85YdKltfn)dL4mn5BX2ppNQffhclTlG(kmXooejFU8qzBVzyX2h(AKAcSnwqqhdVY2EZWITp81i10JjoXcOt7eE5T4qyPDb0xHj2XHi5ZLh8TyoqXo)ZljoGTXYkWObno8g5N3X95BXe6PvIAvv0KhiOJHNVfZbk25FEjX5Nh)O4qyPDb0xHj2XHi5ZLhW8WCUiQIWaBJLuuuKEyEyoxevrypfcIIMfhfh8epvabuDQednPzbK2ryNlGPXrfW8LkGclpCb0GfqzNykbrr(IdHL2fWfe1Dtfkmlo4PciGoaKYooejlGvxAxuanybeHghMkGSJdrYciftOV4qyPDb85YJQlTla2gliheYJHT9MFmXjwaDAaJ3IdEQacOJKWy0QSaEJcitGj0xCiS0Ua(C5bFlMF4lj4IdHL2fWNlpqH03sIdwCiS0Ua(C5bI6U5FGIDgyBSSIuuuKEbYOykbJ8uiikAUEnc6y4fiJIPemYJwTEn7o184hEbYOykbJ8yItSawlq4T4qyPDb85YdecdjSll2a2glRifffPxGmkMsWipfcIIMRxJGogEbYOykbJ8OvfhclTlGpxEmmmHOUBcSnwwrkkksVazumLGrEkeefnxVgbDm8cKrXucg5rRwVMDNAE8dVazumLGrEmXjwaRfi8wCiS0Ua(C5HemcMyr9zIsbSnwwrkkksVazumLGrEkeefnxVgbDm8cKrXucg5rRwVMDNAE8dVazumLGrEmXjwaRfi8wCiS0Ua(C5bIS9VXpXgZfeyBSSIuuuKEbYOykbJ8uiikAUE9kqqhdVazumLGrE0QIdHL2fWNlpgewuFyLHTS4qyPDb85YJHq)elbCGcTla2glavkkksVazumLGrEkeefnxVgJg04WBKFEh3NVftONwjQvvrtaNhaf8qviwm9B4Bh9TyNTDyjTlwVgEOkelM(HrQ5)gFe1bHhhC9AHL2o6tbXzeCbaaV4qyPDb85YdbYOykbJa2glyXMFAhfPxMtO3IAxQzExVwyPTJ(uqCgbRfGIdHL2fWNlp4BXCGID(NxsCaBJfmAqJdVr(5DCF(wmHEALOwvfn5bc6y4N3X95BXe(Nec6y4Nh)GhafwS5N2rr6L5e6TO2faJ31RfwA7OpfeNrWAbaWxVgbDm88TyoqXo)Zljo)84hfh8ubeqpkGxOCUaEbvaPG4Cg4cyf2oSLoxahNsD8HfW8LkG1aAXMIQrbuyPDrbuzW0xCiS0Ua(C5btuQVWs7IVYGjWHWrlql2ueW2yryPTJ(uqCgbxaO4GNkGa9rbKdvLwLIkGuqCgbbUaMVubScBh2sNlGJtPo(Wcy(sfWAihvJcOWs7IcOYGPV4qyPDb85YdMOuFHL2fFLbtGdHJwKJa2glclTD0NcIZiyTauCiS0Ua(C5b7qJKWWeBUOFEjXvCiS0Ua(C5b0LZduSZ)8sIR4qyPDb85YJkSXjQpmXMlQ4O4GN4PciGeuvAfWuWBuwafwAxuaRW2HT05cOYGzXHWs7cOxoAHVftyInxeW2ybbDm8mSaF)kB7ndl28OvfhclTlGE5ONlpgc9tSeWbk0UayBSapufIft)g(2rFl2zBhws7I1RHhQcXIPFyKA(VXhrDq4XbloewAxa9YrpxEWWc89RST3mSydyBSGrdAC4nYpVJ7Z3Ij0tRe1QQOjpqqhd)8oUpFlMqpAvXHWs7cOxo65YJb(G5h(EmxaBJfe0XW)kMcMhMZJwvCiS0Ua6LJEU8aIgtcBXwXHWs7cOxo65YJHs4Op89yUaM5mtr)uWBucxaayBSGPbMGVcII4bqLIII0pmm9JBN4Pqqu0C96uuuKELaFTy7puchb9uiikAUEn72rHePpig(uhEUEngnOXH3iFf24e1xj7KVWsujpm0tRe1QQOjGxCiS0Ua6LJEU8OcBChEAI6Zx2raZCMPOFk4nkHlaaSnwwbc6y4RWg3HNMO(8LDKhTQ4qyPDb0lh9C5XWW0pUDcW2yryPTJ(Zl9dLWrF47XCv7ItkoewAxa9YrpxESJGve(NxsCfhclTlGE5ONlpu22BgwS9rovcSnwqqhdFf24o80e1NVSJ8Ov8aOqqhdpmpmNlIQiShTA9Ae0XWZjKcM4J7ZNKQl8WuyUQDbiaEXHWs7cOxo65Yd2RyXxzBVzyXgW2ybbDm8W8WCUiQIWE0QIdHL2fqVC0ZLhmSaF)kB7ndl2a2glPOOi9mSaFTy7dZdZ5Pqqu0C9Ae0XWZWc89RST3mSyZpp(rXHWs7cOxo65YdLSt(kb(cmZzMI(PG3OeUaaW2yjfffPxjWxl2(dLWrqpfcIIMRxduy0GghEJ8vyJtuFLSt(clrL8WqpTsuRQIM8abDm8vyJtuFLSt(clrL8WqpmfMRAbmaV4qyPDb0lh9C5bmpmhmXMlcyBSGGogEgwGVFLT9MHfBE0QIdHL2fqVC0ZLhmSaF)kB7ndl2koewAxa9YrpxEWEfl(VcEhbtGTXcc6y45esbt8X95ts1fEykmx1UaKIdHL2fqVC0ZLhKI4Oif1hrjWeyBSGGogEoHuWeFCF(KuDHhMcZvTlaP4qyPDb0lh9C5bmpmNlIQimW2ybbDm8CcPGj(4(8jP6cpmfMRAxasXHWs7cOxo65Yd2RyXxzBVzyXgW2ybbDm8CcPGj(4(8jP6cpmfMRfa4T4qyPDb0lh9C5bFlMWeBUOIdHL2fqVC0ZLhW8WCWeBUOIdHL2fqVC0ZLhkzN8vc8T4qyPDb0lh9C5XqjC0h(EmxaZCMPOFk4nkHlaaSnwW0atWxbrrfhclTlGE5ONlpgc9tSeWbk0UO4qyPDb0lh9C5XaFW8dFpMRIdHL2fqVC0ZLhgJ(WeBUOIdHL2fqVC0ZLhSxXIVY2EZWInGTXcc6y45esbt8X95ts1fEykmx1UaKIdHL2fqVC0ZLhddt)42jaBJfHL2o6pV0puch9HVhZvTauCiS0Ua6LJEU8GeC(sXhwzUOIdHL2fqVC0ZLhKGZ3pPioksrvCiS0Ua6LJEU8GVfZbk25FEjXbSnwqqhdpFlMduSZ)8sIZJjoXcOt7eEloko4jEQaQTytrfWuWBuwafwAxuaRW2HT05cOYGzXHWs7cOhAXMIw4BXeMyZfvCiS0Ua6HwSPONlpuYo5Re4lW2ybbDm8Vx(FLy6rRwVgOWObno8g5RWgNO(kzN8fwIk5HHEALOwvfn5bc6y4RWgNO(kzN8fwIk5HHEykmx1cyaEXHWs7cOhAXMIEU8OcBChEAI6Zx2raBJLvGGog(kSXD4PjQpFzh5rRkoewAxa9ql2u0ZLhW8WCWeBUiGTXcgnOXH3i)8oUpFlMqpTsuRQIM8abDm8Z74(8Tyc9OvfhclTlGEOfBk65YdgwGVFLT9MHfBaBJfmAqJdVr(5DCF(wmHEALOwvfn5bc6y4N3X95BXe6rRkoewAxa9ql2u0ZLhgJ(WeBUiGTXcgnOXH3i)8oUpFlMqpTsuRQIM8abDm8Z74(8Tyc9OvfhclTlGEOfBk65YJHs4Op89yUa2glRinMll2koewAxa9ql2u0ZLh7iyfH)5LexXHWs7cOhAXMIEU8yGpy(HVhZfW2ybbDm8VIPG5H58OvfhclTlGEOfBk65YdsW5lfFyL5IkoewAxa9ql2u0ZLhdH(jwc4afAxuCiS0Ua6HwSPONlpu22BgwS9rovcSnwwrvI5bc6y4H5H5CrufH9OvfhclTlGEOfBk65Yd2RyXxzBVzyXgW2yPkX8abDm8W8WCUiQIWE0QIdHL2fqp0Inf9C5bPioksr9rucmb2gliOJHNtifmXh3Npjvx4HPWCv7cqkoewAxa9ql2u0ZLhSxXI)RG3rWeyBSGGogEoHuWeFCF(KuDHhMcZvTlaHhyXMFAhfPxMtO3IAxQzEloewAxa9ql2u0ZLhkB7ndl2(iNkb2gliOJHNtifmXh3Npjvx4HPWCTaaVfhclTlGEOfBk65YdyEyoyInxuXHWs7cOhAXMIEU8aMhMZfrvegyBSGGogEoHuWeFCF(KuDHhMcZvTlaP4qyPDb0dTytrpxEOKDYxjW3IdHL2fqp0Inf9C5bdlW3VY2EZWITIdHL2fqp0Inf9C5XqjC0h(EmxaZCMPOFk4nkHlaaSnwW0atWxbrrfhclTlGEOfBk65YJb(G5h(EmxfhclTlGEOfBk65YdJrFyInxuXHWs7cOhAXMIEU8aIgtcBXgW2ybl28t7Oi9YCc9wu7cpZBXHWs7cOhAXMIEU8yyy6h3obyBSiS02r)5L(Hs4Op89yUkoewAxa9ql2u0ZLhkB7ndl2(iNkb2gliOJHNtifmXh3Npjvx4HPWCv7cqkoewAxa9ql2u0ZLhKGZ3pPioksrvCiS0Ua6HwSPONlp4BXCGID(NxsCaBJfe0XWZ3I5af78pVK48yItSa60oH3o7SBa]] )

end
