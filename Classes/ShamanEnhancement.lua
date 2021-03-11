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


    spec:RegisterPack( "Enhancement", 20210310.1, [[du0GZaqiaIhHQO2eQcFsQcJcqLtbO0RaWSaKBbOOAxc9lvPggQshtvYYuk1ZeiMgQICnaQTbq6Bakmoav15ei16KQOAEsvK7Pe7tQsheqrAHkv9qLssxuPK4JakkNuPKALcyMaQIBcOkTtb1pLQOyPsvu6PKAQsv9vafXyfiXEL8xv1Gb6WelgIhJYKv0Lr2ScFwjnAvXPP8Abz2KCBuz3u9BvgUu54kLy5q9Cqtx01H02vk(oQQXlqsNxGA(kv2VuUEv9l9usQcVnVB)I3G8I34RGgW8eGbgLodUJkDNWcjRuPDHJk9wXFeNrCKNLUtcwDYS6xA4HIzuP1g3wT0iOMk3AVqk9usQcVnVB)I3G8I34RGgW8eGbCPHDeRcVnGgKs)yZj5fsPNeKv6TI)ioJ4ipBG6hHt8waGxbZEAGV4fOg428U9RsRmycR(LgA(QIQ(v4xv)slS0oV08nFctSfIkn5cIIM1(kRWBx9ln5cIIM1(sZWwsytknc6yeFU8)i(mI21a3TRbcCnqmQtJdVsXoSXjQVs2iFHLOsEyyK2cQ11rZgipAGiOJrSdBCI6RKnYxyjQKhggHPWc1a7TbcOnqGT0clTZlTs2iFLaFQSchKQFPjxqu0S2xAg2scBsPbKgic6ye7Wg3HNMO(8LnueTR0clTZlDh24o80e1NVSHQScZtv)stUGOOzTV0mSLe2KsJrDAC4vkoVJ7Z38jmsBb166OzdKhnqe0XioVJ7Z38jmI2vAHL25LgMhMdMylevzfgWv)stUGOOzTV0mSLe2KsJrDAC4vkoVJ7Z38jmsBb166OzdKhnqe0XioVJ7Z38jmI2vAHL25LMHf4ZxzRpPB(ALvyaT6xAYfefnR9LMHTKWMuAmQtJdVsX5DCF(MpHrAlOwxhnBG8ObIGogX5DCF(MpHr0UslS0oV0gJ(WeBHOkRWaJQFPjxqu0S2xAg2scBsPbKgyASqMVwAHL25LEOeo6dFowOkRWa)QFPfwANx6neSJW)8sIR0KlikAw7RSch0v)stUGOOzTV0mSLe2KsJGogXhXuW8WCr0UslS0oV0d8bZp85yHQSc)I3QFPfwANxAsW5d5FyNfIkn5cIIM1(kRWVEv9lTWs78spe6NyXHduODEPjxqu0S2xzf(12v)stUGOOzTV0mSLe2KsJGogryEyUqe1r4iAxPfwANxA2Jy(xzRpPB(ALv4xbP6xAYfefnR9LMHTKWMuAe0XiYjKcM4J7ZNKUZJWuyHAG9U0abCPfwANxAsrCKNI6JOeywzf(fpv9ln5cIIM1(sZWwsytknc6ye5esbt8X95ts35rykSqnWExAGaUbYJgiwS5N2qEgL5egnVb27sdmO5T0clTZln7rm))i4nemRSc)cWv)stUGOOzTV0mSLe2KsJGogroHuWeFCF(K0DEeMcludCPb(I3slS0oV0kB9jDZx)iNkRSc)cqR(LwyPDEPH5H5Gj2crLMCbrrZAFLv4xaJQFPjxqu0S2xAg2scBsPrqhJiNqkyIpUpFs6opctHfQb27sdeWLwyPDEPH5H5cruhHRSc)c4x9lTWs78sRKnYxjWNstUGOOzTVYk8RGU6xAHL25LMHf4ZxzRpPB(APjxqu0S2xzfEBER(LMCbrrZAFPfwANx6Hs4Op85yHkndBjHnP0yAGj4JGOOsZcMPOFk4vkHv4xvwH3(v1V0clTZl9aFW8dFowOstUGOOzTVYk82Bx9lTWs78sBm6dtSfIkn5cIIM1(kRWBhKQFPjxqu0S2xAg2scBsPXIn)0gYZOmNWO5nWExAG8eVLwyPDEPHO(KWMVwzfEBEQ6xAYfefnR9LMHTKWMuAHL2g6pVmouch9HphluPfwANx6HHPVFBKkRWBd4QFPjxqu0S2xAg2scBsPrqhJiNqkyIpUpFs6opctHfQb27sdeWLwyPDEPv26t6MV(rovwzfEBaT6xAHL25LMeC(8jfXrEkQstUGOOzTVYk82aJQFPjxqu0S2xAg2scBsPrqhJiFZNduCW)8sIlIjoXCydSNAGbH3slS0oV08nFoqXb)ZljUkRS0Yrv)k8RQFPjxqu0S2xAg2scBsPrqhJidlWNVYwFs381iAxPfwANxA(MpHj2crvwH3U6xAYfefnR9LMHTKWMuA4HQqmFgxX3g6B(gB9WsANhjxqu0SbUBxdeEOkeZNXHrQ5)gFe1bHhhmsUGOOzPfwANx6Hq)eloCGcTZRSchKQFPjxqu0S2xAg2scBsPXOono8kfN3X95B(egPTGADD0SbYJgic6yeN3X95B(egr7kTWs78sZWc85RS1N0nFTYkmpv9ln5cIIM1(sZWwsytknc6yeFetbZdZfr7kTWs78spWhm)WNJfQYkmGR(LwyPDEPHO(KWMVwAYfefnR9vwHb0QFPjxqu0S2xAHL25LEOeo6dFowOsZWwsytknMgyc(iikQbYJgiW1atrrEghgM((TrIKlikA2a3TRbMII8mQe4J5R)Hs4iyKCbrrZg4UDnq2THCXZOtm8Po8SbUBxdeJ604WRuSdBCI6RKnYxyjQKhggPTGADD0SbcSLMfmtr)uWRucRWVQScdmQ(LMCbrrZAFPfwANx6oSXD4PjQpFzdvAg2scBsPbKgic6ye7Wg3HNMO(8LnueTR0SGzk6NcELsyf(vLvyGF1V0KlikAw7lndBjHnP0clTn0FEzCOeo6dFowOgyVlnWGuAHL25LEyy673gPYkCqx9lTWs78sVHGDe(NxsCLMCbrrZAFLv4x8w9ln5cIIM1(sZWwsytknc6ye7Wg3HNMO(8LnueTRbYJgic6ye5esbt8X95ts35rykSqnWExAGaU0clTZlTYwFs381pYPYkRWVEv9ln5cIIM1(sZWwsytknc6yeH5H5cruhHJODLwyPDEPzpI5FLT(KU5RvwHFTD1V0KlikAw7lndBjHnP0POipJmSaFmF9dZdZfjxqu0SbUBxdebDmImSaF(kB9jDZxJZJVxAHL25LMHf4ZxzRpPB(ALv4xbP6xAYfefnR9LwyPDEPvYg5Re4tPzyljSjLoff5zujWhZx)dLWrWi5cIIMLMfmtr)uWRucRWVQSc)INQ(LMCbrrZAFPzyljSjLgbDmImSaF(kB9jDZxJODnqE0abUgic6yeFU8)i(mI21a3TRbcCnqmQtJdVsXoSXjQVs2iFHLOsEyyK2cQ11rZgipAGiOJrSdBCI6RKnYxyjQKhggHPWc1a7TbcOnqGTbcSLwyPDEPvYg5Re4tLv4xaU6xAYfefnR9LMHTKWMuAe0XiYWc85RS1N0nFnI2vAHL25LgMhMdMylevzf(fGw9lTWs78sZWc85RS1N0nFT0KlikAw7RSc)cyu9ln5cIIM1(sZWwsytknc6ye5esbt8X95ts35rykSqnWExAGaU0clTZln7rm))i4nemRSc)c4x9ln5cIIM1(sZWwsytknc6ye5esbt8X95ts35rykSqnWExAGaU0clTZlnPioYtr9rucmRSc)kOR(LMCbrrZAFPzyljSjLgbDmICcPGj(4(8jP78imfwOgyVlnqaxAHL25LgMhMlerDeUYk828w9ln5cIIM1(sZWwsytknc6ye5esbt8X95ts35rykSqnWLg4lElTWs78sZEeZ)kB9jDZxRScV9RQFPfwANxA(MpHj2crLMCbrrZAFLv4T3U6xAHL25LgMhMdMylevAYfefnR9vwH3oiv)slS0oV0kzJ8vc8P0KlikAw7RScVnpv9ln5cIIM1(slS0oV0dLWrF4ZXcvAg2scBsPX0atWhbrrLMfmtr)uWRucRWVQScVnGR(LwyPDEPhc9tS4Wbk0oV0KlikAw7RScVnGw9lTWs78spWhm)WNJfQ0KlikAw7RScVnWO6xAHL25L2y0hMylevAYfefnR9vwH3g4x9ln5cIIM1(sZWwsytknc6ye5esbt8X95ts35rykSqnWExAGaU0clTZln7rm)RS1N0nFTYk82bD1V0KlikAw7lndBjHnP0clTn0FEzCOeo6dFowOgyVnWxLwyPDEPhgM((TrQScheER(LwyPDEPjbNpK)HDwiQ0KlikAw7RSchKxv)slS0oV0KGZNpPioYtrvAYfefnR9vwHdY2v)stUGOOzTV0mSLe2KsJGogr(MphO4G)5LexetCI5Wgyp1adcVLwyPDEP5B(CGId(NxsCvwzPN0qqvz1Vc)Q6xAHL25LgrD3uHcZstUGOOzHuzfE7QFPjxqu0S2xAg2scBsProiSbYJg4WwFYpM4eZHnWEQbcO8w6jbzyRlTZl9w7aZzhhIKnWUlTZBGgSbIqJdtnq2XHizdK8jmwAHL25LU7s78kRWbP6xAYfefnR9LEsqg26s78sV1EsymAx2aVrdKjWeglTWs78sZ385h(qcUYkmpv9lTWs78sJcPVLehS0KlikAw7RScd4QFPjxqu0S2xAg2scBsPbKgykkYZOazKpfNrrYfefnBG721arqhJOazKpfNrr0Ug4UDnq2DQ5X3JcKr(uCgfXeNyoSb2BdeW8wAHL25LgrD38pqXbxzfgqR(LMCbrrZAFPzyljSjLgqAGPOipJcKr(uCgfjxqu0SbUBxdebDmIcKr(uCgfr7kTWs78sJqyiHdz(ALvyGr1V0KlikAw7lndBjHnP0asdmff5zuGmYNIZOi5cIIMnWD7AGiOJruGmYNIZOiAxdC3Ugi7o1847rbYiFkoJIyItmh2a7TbcyElTWs78spmmHOUBwzfg4x9ln5cIIM1(sZWwsytknG0atrrEgfiJ8P4mksUGOOzdC3Ugic6yefiJ8P4mkI21a3TRbYUtnp(EuGmYNIZOiM4eZHnWEBGaM3slS0oV0IZiyIf1NjkvLv4GU6xAYfefnR9LMHTKWMuAaPbMII8mkqg5tXzuKCbrrZg4UDnqaPbIGogrbYiFkoJIODLwyPDEPrK1)n(j2yHGvwHFXB1V0clTZl9GWI6d7mSLLMCbrrZAFLv4xVQ(LMCbrrZAFPzyljSjLg4AGPOipJcKr(uCgfjxqu0SbUBxdeJ604WRuCEh3NV5tyK2cQ11rZgiW2a5rde4AGWdvHy(mUIVn038n26HL0opsUGOOzdC3Ugi8qviMpJdJuZ)n(iQdcpoyKCbrrZg4UDnqHL2g6toXzeSbU0aF1ab2slS0oV0dH(jwC4afANxzf(12v)stUGOOzTV0mSLe2KsJfB(PnKNrzoHrZBG9U0adAEBG721afwABOp5eNrWgyVnWxLwyPDEPfiJ8P4mQYk8RGu9ln5cIIM1(sZWwsytkng1PXHxP48oUpFZNWiTfuRRJMnqE0arqhJ48oUpFZNW)KqqhJ4847nqE0abUgiwS5N2qEgL5egnVb27sdeq5TbUBxduyPTH(KtCgbBG92aF1ab2g4UDnqe0XiY385afh8pVK4IZJVxAHL25LMV5Zbko4FEjXvzf(fpv9ln5cIIM1(spjidBDPDEP36rd8CvWnWZPgi5exWa1a7W2HTm4g44uQJpSbMpudShqZxvupAGclTZBGkdMXslS0oV0mrP(clTZ)kdMLMHTKWMuAHL2g6toXzeSbU0aFvALbZVlCuPHMVQOkRWVaC1V0KlikAw7l9KGmS1L25LUNXBGCOQ06uudKCIZiiqnW8HAGDy7WwgCdCCk1Xh2aZhQb2d5OE0afwAN3avgmJLwyPDEPzIs9fwAN)vgmlndBjHnP0clTn0NCIZiydS3g4RsRmy(DHJkTCuLv4xaA1V0clTZln7q9KWWeBHOFEjXvAYfefnR9vwHFbmQ(LwyPDEPHHcEGId(NxsCLMCbrrZAFLv4xa)QFPfwANx6oSXjQpmXwiQ0KlikAw7RSYs3Hj2XHiz1Vc)Q6xAYfefnR9LMHTKWMuAe0XiY385afh8NpjDNhXeNyoSb2tnWGWlVLwyPDEP5B(CGId(ZNKUZRScVD1V0KlikAw7lndBjHnP0iOJrCOeokpFfL(8jP78iM4eZHnWEQbgeE5T0clTZl9qjCuE(kk95ts35vwHds1V0clTZlnYLPIM)HscMM8nF9Nxq18stUGOOzTVYkmpv9ln5cIIM1(sZWwsytknc6yev26t6MV(HpgPMrmXjMdBG9udmi8YBPfwANxALT(KU5RF4JrQzLvyax9ln5cIIM1(sZWwsytknG0aXOono8kfN3X95B(egPTGADD0SbYJgic6ye5B(CGId(NxsCX5X3lTWs78sZ385afh8pVK4QScdOv)stUGOOzTV0mSLe2KsNII8mcZdZfIOochjxqu0S0clTZlnmpmxiI6iCLvwzP3qyODEfEBE3(fVb5fVLMVGDZxHLgycW0E2WBDyGz98gydS)d1anUUdNnWXHBG9qoQhnqmTfudtZgi84OgOGMhNK0SbYEeFLGXwaGhZPg4298g4w98neoPzdShWdvHy(mgu6rdmVgypGhQcX8zmOejxqu0ShnqG7vqfyJTaapMtnWT75nWT65BiCsZgypGhQcX8zmO0JgyEnWEapufI5ZyqjsUGOOzpAGs2a3k9mapnqG7vqfyJTaTaataM2ZgERddmRN3aBG9FOgOX1D4SbooCdShtAiOQShnqmTfudtZgi84OgOGMhNK0SbYEeFLGXwaGhZPg4Rx98g4w98neoPzdShWdvHy(mgu6rdmVgypGhQcX8zmOejxqu0ShnqGB7GkWgBbAb2AUUdN0SbYtnqHL25nqLbtySfO0cA(C4sRnUTAP7W3WuuP5zEUbUv8hXzeh5zdu)iCI3cWZ8Cde4vWSNg4lEbQbUnVB)QfOfqyPDom2Hj2XHi5cFZNduCWF(K0Doq2ybbDmI8nFoqXb)5ts35rmXjMd7PGWlVTaclTZHXomXooejby59qjCuE(kk95ts35azJfe0XiouchLNVIsF(K0DEetCI5WEki8YBlGWs7CySdtSJdrsawEJCzQO5FOKGPjFZx)5funVfqyPDom2Hj2XHijalVv26t6MV(HpgPMazJfe0XiQS1N0nF9dFmsnJyItmh2tbHxEBbewANdJDyIDCiscWYB(MphO4G)5Lehq2ybqWOono8kfN3X95B(egPTGADD0KhiOJrKV5Zbko4FEjXfNhFVfqyPDom2Hj2XHijalVH5H5cruhHbYglPOipJW8WCHiQJWrYfefnBbAb4zEUbUvcQednPzdK2q4GBGPXrnW8HAGclpCd0GnqzJykbrrXwaHL25Wfe1DtfkmBb45g4w7aZzhhIKnWUlTZBGgSbIqJdtnq2XHizdK8jm2ciS0ohcWY7UlTZbYgliheYJHT(KFmXjMd7jaL3waEUbU1EsymAx2aVrdKjWegBbewANdby5nFZNF4dj4waHL25qawEJcPVLehSfqyPDoeGL3iQ7M)bkoyGSXcGKII8mkqg5tXzuKCbrrZD7qqhJOazKpfNrr0UD7y3PMhFpkqg5tXzuetCI5WEbmVTaclTZHaS8gHWqchY8vGSXcGKII8mkqg5tXzuKCbrrZD7qqhJOazKpfNrr0UwaHL25qawEpmmHOUBcKnwaKuuKNrbYiFkoJIKlikAUBhc6yefiJ8P4mkI2TBh7o1847rbYiFkoJIyItmh2lG5TfqyPDoeGL3IZiyIf1Njkfq2ybqsrrEgfiJ8P4mksUGOO5UDiOJruGmYNIZOiA3UDS7uZJVhfiJ8P4mkIjoXCyVaM3waHL25qawEJiR)B8tSXcbbYglaskkYZOazKpfNrrYfefn3TdqqqhJOazKpfNrr0UwaHL25qawEpiSO(WodBzlGWs7CialVhc9tS4Wbk0ohiBSaCPOipJcKr(uCgfjxqu0C3omQtJdVsX5DCF(MpHrAlOwxhnbwEaCWdvHy(mUIVn038n26HL0oF3o4HQqmFghgPM)B8ruheECWD7ewABOp5eNrWLxaBlGWs7CialVfiJ8P4mciBSGfB(PnKNrzoHrZ7DjO5D3oHL2g6toXzeS3xTaclTZHaS8MV5Zbko4FEjXbKnwWOono8kfN3X95B(egPTGADD0KhiOJrCEh3NV5t4FsiOJrCE8DEaCyXMFAd5zuMty08ExauE3TtyPTH(KtCgb79fWUBhc6ye5B(CGId(NxsCX5X3Bb45g4wpAGNRcUbEo1ajN4cgOgyh2oSLb3ahNsD8HnW8HAG9aA(QI6rduyPDEduzWm2ciS0ohcWYBMOuFHL25FLbtGCHJwGMVQiGSXIWsBd9jN4mcU8QfGNBG9mEdKdvLwNIAGKtCgbbQbMpudSdBh2YGBGJtPo(Wgy(qnWEih1JgOWs78gOYGzSfqyPDoeGL3mrP(clTZ)kdMa5chTihbKnwewABOp5eNrWEF1ciS0ohcWYB2H6jHHj2cr)8sIRfqyPDoeGL3WqbpqXb)ZljUwaHL25qawE3Hnor9Hj2crTaTa8mp3abErvP1atbVszduyPDEdSdBh2YGBGkdMTaclTZHr5Of(MpHj2crazJfe0XiYWc85RS1N0nFnI21ciS0ohgLJay59qOFIfhoqH25azJf4HQqmFgxX3g6B(gB9WsANVBh8qviMpJdJuZ)n(iQdcpoylGWs7CyuocGL3mSaF(kB9jDZxbYglyuNghELIZ74(8nFcJ0wqTUoAYde0XioVJ7Z38jmI21ciS0ohgLJay59aFW8dFowiGSXcc6yeFetbZdZfr7AbewANdJYraS8gI6tcB(AlGWs7CyuocGL3dLWrF4ZXcbelyMI(PGxPeU8ciBSGPbMGpcII4bWLII8momm99BJejxqu0C3UuuKNrLaFmF9puchbJKlikAUBh72qU4z0jg(uhEUBhg1PXHxPyh24e1xjBKVWsujpmmsBb166OjW2ciS0ohgLJay5Dh24o80e1NVSHaIfmtr)uWRucxEbKnwaee0Xi2HnUdpnr95lBOiAxlGWs7CyuocGL3ddtF)2iazJfHL2g6pVmouch9HphluVlbPfqyPDomkhbWY7neSJW)8sIRfqyPDomkhbWYBLT(KU5RFKtLazJfe0Xi2HnUdpnr95lBOiAhpqqhJiNqkyIpUpFs6opctHfQ3fa3ciS0ohgLJay5n7rm)RS1N0nFfiBSGGogryEyUqe1r4iAxlGWs7CyuocGL3mSaF(kB9jDZxbYglPOipJmSaFmF9dZdZfjxqu0C3oe0XiYWc85RS1N0nFnop(ElGWs7CyuocGL3kzJ8vc8biwWmf9tbVsjC5fq2yjff5zujWhZx)dLWrWi5cIIMTaclTZHr5iawERKnYxjWhGSXcc6yezyb(8v26t6MVgr74bWHGogXNl)pIpJOD72bCyuNghELIDyJtuFLSr(clrL8WWiTfuRRJM8abDmIDyJtuFLSr(clrL8WWimfwOEbuGfyBbewANdJYraS8gMhMdMylebKnwqqhJidlWNVYwFs381iAxlGWs7CyuocGL3mSaF(kB9jDZxBbewANdJYraS8M9iM)Fe8gcMazJfe0XiYjKcM4J7ZNKUZJWuyH6DbWTaclTZHr5iawEtkIJ8uuFeLatGSXcc6ye5esbt8X95ts35rykSq9Ua4waHL25WOCealVH5H5cruhHbYgliOJrKtifmXh3NpjDNhHPWc17cGBbewANdJYraS8M9iM)v26t6MVcKnwqqhJiNqkyIpUpFs6opctHfA5fVTaclTZHr5iawEZ38jmXwiQfqyPDomkhbWYByEyoyITqulGWs7CyuocGL3kzJ8vc8PfqyPDomkhbWY7Hs4Op85yHaIfmtr)uWRucxEbKnwW0atWhbrrTaclTZHr5iawEpe6NyXHduODElGWs7CyuocGL3d8bZp85yHAbewANdJYraS82y0hMyle1ciS0ohgLJay5n7rm)RS1N0nFfiBSGGogroHuWeFCF(K0DEeMcluVlaUfqyPDomkhbWY7HHPVFBeGSXIWsBd9NxghkHJ(WNJfQ3xTaclTZHr5iawEtcoFi)d7SqulGWs7CyuocGL3KGZNpPioYtr1ciS0ohgLJay5nFZNduCW)8sIdiBSGGogr(MphO4G)5LexetCI5WEki82c0cWZ8CduB(QIAGPGxPSbkS0oVb2HTdBzWnqLbZwaHL25Wi08vfTW38jmXwiQfqyPDomcnFvraS8wjBKVsGpazJfe0Xi(C5)r8zeTB3oGdJ604WRuSdBCI6RKnYxyjQKhggPTGADD0KhiOJrSdBCI6RKnYxyjQKhggHPWc1lGcSTaclTZHrO5RkcGL3DyJ7WttuF(YgciBSaiiOJrSdBChEAI6Zx2qr0UwaHL25Wi08vfbWYByEyoyITqeq2ybJ604WRuCEh3NV5tyK2cQ11rtEGGogX5DCF(MpHr0UwaHL25Wi08vfbWYBgwGpFLT(KU5RazJfmQtJdVsX5DCF(MpHrAlOwxhn5bc6yeN3X95B(egr7AbewANdJqZxvealVng9Hj2crazJfmQtJdVsX5DCF(MpHrAlOwxhn5bc6yeN3X95B(egr7AbewANdJqZxvealVhkHJ(WNJfciBSaiPXcz(AlGWs7CyeA(QIay59gc2r4FEjX1ciS0ohgHMVQiawEpWhm)WNJfciBSGGogXhXuW8WCr0UwaHL25Wi08vfbWYBsW5d5FyNfIAbewANdJqZxvealVhc9tS4Wbk0oVfqyPDomcnFvraS8M9iM)v26t6MVcKnwqqhJimpmxiI6iCeTRfqyPDomcnFvraS8Mueh5PO(ikbMazJfe0XiYjKcM4J7ZNKUZJWuyH6DbWTaclTZHrO5RkcGL3ShX8)JG3qWeiBSGGogroHuWeFCF(K0DEeMcluVlaMhyXMFAd5zuMty08ExcAEBbewANdJqZxvealVv26t6MV(rovcKnwqqhJiNqkyIpUpFs6opctHfA5fVTaclTZHrO5RkcGL3W8WCWeBHOwaHL25Wi08vfbWYByEyUqe1ryGSXcc6ye5esbt8X95ts35rykSq9Ua4waHL25Wi08vfbWYBLSr(kb(0ciS0ohgHMVQiawEZWc85RS1N0nFTfqyPDomcnFvraS8EOeo6dFowiGybZu0pf8kLWLxazJfmnWe8rquulGWs7CyeA(QIay59aFW8dFowOwaHL25Wi08vfbWYBJrFyITqulGWs7CyeA(QIay5ne1Ne28vGSXcwS5N2qEgL5egnV3fEI3waHL25Wi08vfbWY7HHPVFBeGSXIWsBd9NxghkHJ(WNJfQfqyPDomcnFvraS8wzRpPB(6h5ujq2ybbDmICcPGj(4(8jP78imfwOExaClGWs7CyeA(QIay5nj485tkIJ8uuTaclTZHrO5RkcGL38nFoqXb)ZljoGSXcc6ye5B(CGId(NxsCrmXjMd7PGWBLvwfa]] )

end
