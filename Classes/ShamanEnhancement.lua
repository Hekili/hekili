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


    spec:RegisterPack( "Enhancement", 20210117, [[dueIZaqiLQYJuQI2eQcFsPQAuaQCkav9kvWSaKBPIkr7Is)sfAyKkoMsQLjL0Zqv00auCnvu2MkQ6BKkLXrQeohPsADkvHMhPs19KI9jL4GQOs1cvQ8qvuHlQIk6JakrNeqPwjPyMakPBQIkHDsQ6NakHLQIkLNsXuLs9vvujnwsLO9k5VQ0Gr4WelgOhJYKv0LH2Su9zLYOb40cVMuA2KCBuz3u9BvnCL44kvPLJ0ZbnDrxhrBxj57OQgVsvW5rvA(Qi7xHR1v7YmLel9TQtRR1z9ADZQJUEgWCMUwMK3fSmlctRSHLXfoSmNthG4mKd9SmlcVQxMv7YaFskdlJj4ohLbKmujW2lWYmLel9TQtRR1z9ADZQJUEgWCgWug4cYk9TEEEwgaXCIEbwMjczLzpheNthG4mKd9CqyaiCIp0SNdcnItkuEheR1nGgeTQtRRlJkGjSAxgy4BkSAx6xxTlJWY49YWp8jmPHwSmOlGkCw7QS03A1UmOlGkCw7kdJgjsdPm7Bqas272fAW90ziQlFzfAjxkJWY49YSqdUNodrD5lRWkl98SAxg0fqfoRDLHrJePHugkPJ9NUH25)Cx(HpHwCVKXYcohe8yqas2725)Cx(HpHwYLYiSmEVmW8PCWKgAXkl9at1UmOlGkCw7kdJgjsdPmush7pDdTZ)5U8dFcT4EjJLfCoi4XGaKS3TZ)5U8dFcTKlLryz8Ezyubc4QInaPh(wLL(ZQ2LbDbuHZAxzy0irAiLHs6y)PBOD(p3LF4tOf3lzSSGZbbpgeGK9UD(p3LF4tOLCPmclJ3ltWWlmPHwSYs)5R2LbDbuHZAxzy0irAiLzFdImyAdFRmclJ3ltxjC4fc4zARS0RBv7YiSmEVmRq4csV5Nixzqxav4S2vzPxxuTld6cOcN1UYWOrI0qkdizVBbiHcMpLZsUugHLX7LPtFyEHaEM2kl96A1UmclJ3ldk0ea6x4sOfld6cOcN1Ukl9R1PAxgHLX7LPl4nPId7KW49YGUaQWzTRYs)61v7YGUaQWzTRmmAKinKYas27wy(uoTiUGul5szewgVxgvSbi9W3UGVkRS0VU1QDzqxav4S2vggnsKgszaj7DlNGkysFUlFuwE3ctHPDq0sZG4SYiSmEVmOc5qpf1fujWSYs)AEwTld6cOcN1UYWOrI0qkdizVB5eubt6ZD5JYY7wykmTdIwAgeNni4XGGkX8IRqpTYCcTHpiAPzqOR6ugHLX7LHbqc)cqORqywzPFnWuTld6cOcN1UYWOrI0qkdizVB5eubt6ZD5JYY7wykmTdIMbXADkJWY49YOInaPh(2f8vzLL(1NvTld6cOcN1UYWOrI0qkdizVBb85fG4tl5YG40PbbWniOKo2F6gAxObNOUkzLCfwsk5tHwCVKXYcohe8yqas272fAWjQRswjxHLKs(uOfMct7GOLbX5heaFzewgVxgLSsUkbcOYs)6ZxTlJWY49YaZNYbtAOfld6cOcN1Ukl9R1TQDzqxav4S2vggnsKgszaj7DlNGkysFUlFuwE3ctHPDq0sZG4SYiSmEVmW8PCArCbPvw6xRlQ2Lryz8EzuYk5QeiGYGUaQWzTRYs)ADTAxgHLX7LHrfiGRk2aKE4BLbDbuHZAxLL(w1PAxg0fqfoRDLryz8Ez6kHdVqaptBzy0irAiLHIDkcbiGkSmmEzk8McDdtyPFDLL(wxxTlJWY49Y0PpmVqaptBzqxav4S2vzPV1wR2Lryz8EzcgEHjn0ILbDbuHZAxLL(w5z1UmOlGkCw7kdJgjsdPmujMxCf6PvMtOn8brlndcGrNYiSmEVmqsFI0W3QS03kWuTld6cOcN1UYWOrI0qkJWYyfENFA7kHdVqaptBzewgVxMEqXR)RKkl9TEw1UmOlGkCw7kdJgjsdPmGK9ULtqfmPp3LpklVBHPW0oiAPzqCwzewgVxgvSbi9W3UGVkRS0365R2Lryz8EzqHMaUOc5qpfvzqxav4S2vzPVvDRAxg0fqfoRDLHrJePHugqYE3Yp8zNKY7n)e5SuKtchoi09bbp1PmclJ3ld)WNDskV38tKRYklJ8y1U0VUAxg0fqfoRDLHrJePHugqYE3YOceWvfBasp8nl5szewgVxg(HpHjn0Ivw6BTAxg0fqfoRDLHrJePHug4tQadFA3O)k8g(Qy7PsgVBrxav4CqC60Ga(KkWWN2EGQ597xq1dHph0IUaQWzzewgVxMUG3KkoStcJ3RS0ZZQDzqxav4S2vggnsKgszOKo2F6gAN)ZD5h(eAX9sgll4CqWJbbizVBN)ZD5h(eAjxkJWY49YWOceWvfBasp8Tkl9at1UmOlGkCw7kdJgjsdPmGK9UfGeky(uol5szewgVxMo9H5fc4zARS0Fw1UmclJ3ldK0Nin8TYGUaQWzTRYs)5R2LbDbuHZAxzewgVxMUs4WleWZ0wggnsKgszOyNIqacOche8yqaCdIuuON2EqXR)Rel6cOcNdItNgePOqpTkbci8TBxjCi0IUaQW5G40Pbb7xHU4P1rg9vpDoia(YW4LPWBk0nmHL(1vw61TQDzqxav4S2vgHLX7LzHgCpDgI6YxwHLHrJePHuM9niaj7D7cn4E6me1LVScTKlLHXltH3uOBycl9RRS0RlQ2LbDbuHZAxzy0irAiLryzScVZpTDLWHxiGNPDq0sZGGNLryz8Ez6bfV(VsQS0RRv7YiSmEVmRq4csV5Nixzqxav4S2vzPFTov7YGUaQWzTRmmAKinKYas272fAW90ziQlFzfAjxge8yqaCdcqYE3cZNYPfXfKAjxgeNoniaj7DlNGkysFUlFuwE3ctHPDq0sZG4SbbWxgHLX7LrfBasp8Tl4RYkl9RxxTld6cOcN1UYWOrI0qktkk0tlJkqaHVDH5t5SOlGkCoioDAqas27wgvGaUQydq6HVzNpFVmclJ3ldJkqaxvSbi9W3QS0VU1QDzqxav4S2vgHLX7LrjRKRsGakdJgjsdPmPOqpTkbci8TBxjCi0IUaQWzzy8Yu4nf6gMWs)6kl9R5z1UmOlGkCw7kdJgjsdPmGK9ULrfiGRk2aKE4BwYLYiSmEVmW8PCWKgAXkl9RbMQDzewgVxggvGaUQydq6HVvg0fqfoRDvw6xFw1UmOlGkCw7kdJgjsdPmGK9UfMpLtlIli1sUugHLX7LHbqc)QInaPh(wLL(1NVAxg0fqfoRDLHrJePHugqYE3YjOcM0N7YhLL3TWuyAheT0mioRmclJ3lddGe(fGqxHWSYs)ADRAxg0fqfoRDLHrJePHugqYE3YjOcM0N7YhLL3TWuyAheT0mioRmclJ3ldQqo0trDbvcmRS0VwxuTld6cOcN1UYWOrI0qkdizVB5eubt6ZD5JYY7wykmTdIwAgeNvgHLX7LbMpLtlIliTYs)ADTAxg0fqfoRDLHrJePHugqYE3YjOcM0N7YhLL3TWuyAhendI16ugHLX7LHbqc)QInaPh(wLL(w1PAxg0fqfoRDLryz8Ez6kHdVqaptBzy0irAiLjff6PThu86)kXIUaQW5GGhdck2PieGaQWYW4LPWBk0nmHL(1vw6BDD1UmOlGkCw7kJWY49YOKvYvjqaLHrJePHugkPJ9NUH2fAWjQRswjxHLKs(uOf3lzSSGZbbpgeGK9UDHgCI6QKvYvyjPKpfAHPW0oiAzqC(YW4LPWBk0nmHL(1vw6BT1QDzqxav4S2vggnsKgszaj7DlNGkysFUlFuwE3ctHPDq0sZG4SbbpgeclJv4fDKlq4GOLMbbplJWY49YWaiHFvXgG0dFRYsFR8SAxgHLX7LHF4tysdTyzqxav4S2vzPVvGPAxgHLX7LbMpLdM0qlwg0fqfoRDvw6B9SQDzewgVxgLSsUkbcOmOlGkCw7QS0365R2LbDbuHZAxzewgVxMUs4WleWZ0wggnsKgszOyNIqacOcldJxMcVPq3Wew6xxzPVvDRAxgHLX7LPl4nPId7KW49YGUaQWzTRYsFR6IQDzewgVxMo9H5fc4zAld6cOcN1Ukl9TQRv7YiSmEVmbdVWKgAXYGUaQWzTRYspp1PAxg0fqfoRDLHrJePHugqYE3YjOcM0N7YhLL3TWuyAheT0mioRmclJ3lddGe(vfBasp8Tkl98CD1UmOlGkCw7kdJgjsdPmclJv4D(PTReo8cb8mTdIwgeRlJWY49Y0dkE9FLuzPNNTwTlJWY49YGcnbG(fUeAXYGUaQWzTRYspp5z1UmclJ3ldk0eWfvih6POkd6cOcN1Ukl98eyQ2LbDbuHZAxzy0irAiLbKS3T8dF2jP8EZprolf5KWHdcDFqWtDkJWY49YWp8zNKY7n)e5QSYYmXUqQYQDPFD1UmclJ3ldO6)PIeMLbDbuHZcSYsFRv7YGUaQWzTRmmAKinKY0Jna5LICs4WbHUpioVoLryz8Ezw(mEVYsppR2Lryz8Ez4h(8cbGcTmOlGkCw7QS0dmv7YiSmEVmKq8gjYbld6cOcN1Ukl9NvTld6cOcN1UYWOrI0qkZ(gePOqpTcKH(uCgArxav4CqC60GaKS3TcKH(uCgAjxgeNoniy)RMpF3kqg6tXzOLICs4WbrldIZ0PmclJ3ldO6)5Tts5TYs)5R2LbDbuHZAxzy0irAiLzFdIuuONwbYqFkodTOlGkCoioDAqas27wbYqFkodTKlLryz8EzarkePAdFRYsVUvTld6cOcN1UYWOrI0qkZ(gePOqpTcKH(uCgArxav4CqC60GaKS3TcKH(uCgAjxgeNoniy)RMpF3kqg6tXzOLICs4WbrldIZ0PmclJ3ltpOiO6)zLLEDr1UmOlGkCw7kdJgjsdPm7BqKIc90kqg6tXzOfDbuHZbXPtdcqYE3kqg6tXzOLCzqC60GG9VA(8DRazOpfNHwkYjHdheTmiotNYiSmEVmIZqysf1LjkvLLEDTAxg0fqfoRDLHrJePHuM9nisrHEAfid9P4m0IUaQW5G40PbX(geGK9UvGm0NIZql5szewgVxgqz7(9BsdMwyLL(16uTlJWY49Y0rQOUWLGgzzqxav4S2vzPF96QDzqxav4S2vggnsKgszaUbrkk0tRazOpfNHw0fqfoheNoniOKo2F6gAN)ZD5h(eAX9sgll4Cqa8dcEmiaUbb8jvGHpTB0FfEdFvS9ujJ3TOlGkCoioDAqaFsfy4tBpq18(9lO6HWNdArxav4CqC60GqyzScVOJCbchendI1dcGVmclJ3ltxWBsfh2jHX7vw6x3A1UmOlGkCw7kdJgjsdPmujMxCf6PvMtOn8brlndcDvNbXPtdcHLXk8IoYfiCq0YGyDzewgVxgbYqFkodRS0VMNv7YGUaQWzTRmmAKinKYqjDS)0n0o)N7Yp8j0I7LmwwW5GGhdcqYE3o)N7Yp8j8orqYE3oF((GGhdcGBqqLyEXvONwzoH2WheT0mioVodItNgeclJv4fDKlq4GOLbX6bbWpioDAqas27w(Hp7KuEV5NiND(89YiSmEVm8dF2jP8EZprUkl9RbMQDzqxav4S2vggnsKgszewgRWl6ixGWbrZGyDzewgVxgMOuxHLX7xvaZYOcyEDHdldm8nfwzPF9zv7YGUaQWzTRmmAKinKYiSmwHx0rUaHdIwgeRlJWY49YWeL6kSmE)QcywgvaZRlCyzKhRS0V(8v7YiSmEVmSN0tKctAOfV5Nixzqxav4S2vzPFTUvTlJWY49Ya1YBNKY7n)e5kd6cOcN1Ukl9R1fv7YiSmEVml0GtuxysdTyzqxav4S2vzLLzHISNduYQDPFD1UmOlGkCw7kdJgjsdPmGK9ULF4ZojL3lFuwE3srojC4Gq3he8uhDkJWY49YWp8zNKY7LpklVxzPV1QDzqxav4S2vggnsKgszaj7DBxjCy((gjE5JYY7wkYjHdhe6(GGN6OtzewgVxMUs4W89ns8YhLL3RS0ZZQDzewgVxgWptfoVDLWlo5h(2n)9q4LbDbuHZAxLLEGPAxg0fqfoRDLHrJePHugqYE3QInaPh(2fciq10srojC4Gq3he8uhDkJWY49YOInaPh(2fciq1SYs)zv7YGUaQWzTRmmAKinKYSVbbL0X(t3q78FUl)WNqlUxYyzbNdcEmiaj7Dl)WNDskV38tKZoF(EzewgVxg(Hp7KuEV5NixLL(ZxTld6cOcN1UYWOrI0qktkk0tlmFkNwexqQfDbuHZYiSmEVmW8PCArCbPvwzLLzfsHX7L(w1PvDw3ARRldFH6HVblZ565(5MEGTEGL7XbXGOnaCqeClpnhe9Noi2V84(heuCVKbfNdc4ZHdcHmFojX5GGbq8neAhAawdhheTUhheNJ3xH0eNdI9dFsfy4tRUC)dI8he7h(KkWWNwDPfDbuHZ9piaU17bG3o0aSgooiADpoiohVVcPjohe7h(KkWWNwD5(he5pi2p8jvGHpT6sl6cOcN7Fqi5G4CcSayDqaCR3daVDOzO5C9C)CtpWwpWY94Gyq0gaoicULNMdI(the7FIDHuL7FqqX9sguCoiGphoieY85KeNdcgaX3qODObynCCqSE9ECqCoEFfstCoi2p8jvGHpT6Y9piYFqSF4tQadFA1Lw0fqfo3)Ga4ADpa82HMHgGn3YttCoiaMbHWY49bHkGj0o0uMf63dfwM9CqCoDaIZqo0ZbHbGWj(qZEoi0ioPq5DqSw3aAq0QoTUEOzOryz8o0Uqr2Zbkzd)WNDskVx(OS8oqrVbKS3T8dF2jP8E5JYY7wkYjHd1DEQJodnclJ3H2fkYEoqjp0CSReomFFJeV8rz5DGIEdizVB7kHdZ33iXlFuwE3srojCOUZtD0zOryz8o0Uqr2Zbk5HMJGFMkCE7kHxCYp8TB(7HWhAewgVdTluK9CGsEO5Ok2aKE4BxiGavtGIEdizVBvXgG0dF7cbeOAAPiNeou35Po6m0iSmEhAxOi75aL8qZr(Hp7KuEV5NihqrVzFush7pDdTZ)5U8dFcT4EjJLfCYdqYE3Yp8zNKY7n)e5SZNVp0iSmEhAxOi75aL8qZry(uoTiUGuGIEtkk0tlmFkNwexqQfDbuHZHMHM9CqCo3diJmX5GaxHuEhezWHdIeaoiew(0braheYkjucOcTdnclJ3HnGQ)Nksyo0SNdcGTFUK9CGsoiw(mEFqeWbbi2FkoiyphOKdc0Nq7qJWY4D4HMJlFgVdu0B6XgG8srojCOUFEDgA2ZbbW2tKsjxYbX3hembMq7qJWY4D4HMJ8dFEHaqHo0iSmEhEO5ijeVrICWHgHLX7Wdnhbv)pVDskVaf9M9LIc90kqg6tXzOfDbuHZtNaj7DRazOpfNHwYLtNy)RMpF3kqg6tXzOLICs4WwotNHgHLX7WdnhbrkePAdFdOO3SVuuONwbYqFkodTOlGkCE6eizVBfid9P4m0sUm0iSmEhEO5ypOiO6)jqrVzFPOqpTcKH(uCgArxav480jqYE3kqg6tXzOLC50j2)Q5Z3TcKH(uCgAPiNeoSLZ0zOryz8o8qZrXzimPI6YeLcOO3SVuuONwbYqFkodTOlGkCE6eizVBfid9P4m0sUC6e7F1857wbYqFkodTuKtch2Yz6m0iSmEhEO5iOSD)(nPbtleOO3SVuuONwbYqFkodTOlGkCE60(aj7DRazOpfNHwYLHgHLX7Wdnh7ivux4sqJCOryz8o8qZXUG3KkoStcJ3bk6naxkk0tRazOpfNHw0fqfopDIs6y)PBOD(p3LF4tOf3lzSSGtGNhah8jvGHpTB0FfEdFvS9ujJ3pDc(KkWWN2EGQ597xq1dHph80jHLXk8IoYfiSznWp0iSmEhEO5OazOpfNHaf9gQeZlUc90kZj0gEln6QoNojSmwHx0rUaHTSEOryz8o8qZr(Hp7KuEV5NihqrVHs6y)PBOD(p3LF4tOf3lzSSGtEas2725)Cx(HpH3jcs2725Z35bWrLyEXvONwzoH2WBP586C6KWYyfErh5ce2YAG)0jqYE3Yp8zNKY7n)e5SZNVp0SNdcGDFq8UI3bX74GaDKJxGgel04PrY7GO)k1Zhoisa4Gy)WW3u4(heclJ3heQaM2HgHLX7WdnhzIsDfwgVFvbmbYfoSbg(Mcbk6nclJv4fDKlqyZ6HM9CqaSWheCKQmwu4GaDKlqiqdIeaoiwOXtJK3br)vQNpCqKaWbX(Lh3)Gqyz8(GqfW0o0iSmEhEO5ituQRWY49RkGjqUWHnYJaf9gHLXk8IoYfiSL1dnclJ3HhAoYEsprkmPHw8MFICdnclJ3HhAoc1YBNKY7n)e5gAewgVdp0CCHgCI6ctAOfhAgA2ZbX5csvgdIuOByoiewgVpiwOXtJK3bHkG5qJWY4DOvESHF4tysdTiqrVbKS3TmQabCvXgG0dFZsUm0iSmEhALhp0CSl4nPId7KW4DGIEd8jvGHpTB0FfEdFvS9ujJ3pDc(KkWWN2EGQ597xq1dHphCOryz8o0kpEO5iJkqaxvSbi9W3ak6nush7pDdTZ)5U8dFcT4EjJLfCYdqYE3o)N7Yp8j0sUm0iSmEhALhp0CStFyEHaEMwGIEdizVBbiHcMpLZsUm0iSmEhALhp0Ces6tKg(2qJWY4DOvE8qZXUs4WleWZ0ceJxMcVPq3We2SgOO3qXofHaeqfYdGlff6PThu86)kXIUaQW5PtPOqpTkbci8TBxjCi0IUaQW5PtSFf6INwhz0x90jWp0iSmEhALhp0CCHgCpDgI6YxwHaX4LPWBk0nmHnRbk6n7dKS3Tl0G7PZqux(Yk0sUm0iSmEhALhp0CShu86)kbOO3iSmwH35N2Us4WleWZ02sdphAewgVdTYJhAoUcHli9MFICdnclJ3Hw5XdnhvXgG0dF7c(QeOO3as272fAW90ziQlFzfAjx4bWbs27wy(uoTiUGul5YPtGK9ULtqfmPp3LpklVBHPW02sZza)qJWY4DOvE8qZrgvGaUQydq6HVbu0BsrHEAzubci8TlmFkNfDbuHZtNaj7DlJkqaxvSbi9W3SZNVp0iSmEhALhp0CujRKRsGaaIXltH3uOBycBwdu0BsrHEAvceq4B3Us4qOfDbuHZHgHLX7qR84HMJW8PCWKgArGIEdizVBzubc4QInaPh(MLCzOryz8o0kpEO5iJkqaxvSbi9W3gAewgVdTYJhAoYaiHFvXgG0dFdOO3as27wy(uoTiUGul5YqJWY4DOvE8qZrgaj8laHUcHjqrVbKS3TCcQGj95U8rz5DlmfM2wAoBOryz8o0kpEO5iQqo0trDbvcmbk6nGK9ULtqfmPp3LpklVBHPW02sZzdnclJ3Hw5XdnhH5t50I4csbk6nGK9ULtqfmPp3LpklVBHPW02sZzdnclJ3Hw5XdnhzaKWVQydq6HVbu0Baj7DlNGkysFUlFuwE3ctHPTzTodnclJ3Hw5Xdnh7kHdVqaptlqmEzk8McDdtyZAGIEtkk0tBpO41)vIfDbuHtEqXofHaeqfo0iSmEhALhp0CujRKRsGaaIXltH3uOBycBwdu0BOKo2F6gAxObNOUkzLCfwsk5tHwCVKXYco5bizVBxObNOUkzLCfwsk5tHwykmTTC(HgHLX7qR84HMJmas4xvSbi9W3ak6nGK9ULtqfmPp3LpklVBHPW02sZz8qyzScVOJCbcBPHNdnclJ3Hw5Xdnh5h(eM0qlo0iSmEhALhp0CeMpLdM0qlo0iSmEhALhp0CujRKRsGagAewgVdTYJhAo2vchEHaEMwGy8Yu4nf6gMWM1af9gk2PieGaQWHgHLX7qR84HMJDbVjvCyNegVp0iSmEhALhp0CStFyEHaEM2HgHLX7qR84HMJbdVWKgAXHgHLX7qR84HMJmas4xvSbi9W3ak6nGK9ULtqfmPp3LpklVBHPW02sZzdnclJ3Hw5Xdnh7bfV(Vsak6nclJv4D(PTReo8cb8mTTSEOryz8o0kpEO5ik0ea6x4sOfhAewgVdTYJhAoIcnbCrfYHEkQHgHLX7qR84HMJ8dF2jP8EZproGIEdizVB5h(Sts59MFICwkYjHd1DEQZqZqZEoimHVPWbrk0nmheclJ3hel04PrY7GqfWCOryz8o0cdFtHn8dFctAOfhAewgVdTWW3u4HMJl0G7PZqux(YkeOO3SpqYE3UqdUNodrD5lRql5YqJWY4DOfg(Mcp0CeMpLdM0qlcu0BOKo2F6gAN)ZD5h(eAX9sgll4KhGK9UD(p3LF4tOLCzOryz8o0cdFtHhAoYOceWvfBasp8nGIEdL0X(t3q78FUl)WNqlUxYyzbN8aKS3TZ)5U8dFcTKldnclJ3Hwy4Bk8qZXGHxysdTiqrVHs6y)PBOD(p3LF4tOf3lzSSGtEas2725)Cx(HpHwYLHgHLX7qlm8nfEO5yxjC4fc4zAbk6n7ldM2W3gAewgVdTWW3u4HMJRq4csV5Ni3qJWY4DOfg(Mcp0CStFyEHaEMwGIEdizVBbiHcMpLZsUm0iSmEhAHHVPWdnhrHMaq)cxcT4qJWY4DOfg(Mcp0CSl4nPId7KW49HgHLX7qlm8nfEO5Ok2aKE4BxWxLaf9gqYE3cZNYPfXfKAjxgAewgVdTWW3u4HMJOc5qpf1fujWeOO3as27wobvWK(Cx(OS8UfMctBlnNn0iSmEhAHHVPWdnhzaKWVae6keMaf9gqYE3YjOcM0N7YhLL3TWuyABP5mEqLyEXvONwzoH2WBPrx1zOryz8o0cdFtHhAoQInaPh(2f8vjqrVbKS3TCcQGj95U8rz5DlmfM2M16m0iSmEhAHHVPWdnhvYk5QeiaGIEdizVBb85fG4tl5YPtahL0X(t3q7cn4e1vjRKRWssjFk0I7LmwwWjpaj7D7cn4e1vjRKRWssjFk0ctHPTLZd8dnclJ3Hwy4Bk8qZry(uoysdT4qJWY4DOfg(Mcp0CeMpLtlIlifOO3as27wobvWK(Cx(OS8UfMctBlnNn0iSmEhAHHVPWdnhvYk5QeiGHgHLX7qlm8nfEO5iJkqaxvSbi9W3gAewgVdTWW3u4HMJDLWHxiGNPfigVmfEtHUHjSznqrVHIDkcbiGkCOryz8o0cdFtHhAo2PpmVqapt7qJWY4DOfg(Mcp0Cmy4fM0qlo0iSmEhAHHVPWdnhHK(ePHVbu0BOsmV4k0tRmNqB4T0am6m0iSmEhAHHVPWdnh7bfV(Vsak6nclJv4D(PTReo8cb8mTdnclJ3Hwy4Bk8qZrvSbi9W3UGVkbk6nGK9ULtqfmPp3LpklVBHPW02sZzdnclJ3Hwy4Bk8qZruOjGlQqo0trn0iSmEhAHHVPWdnh5h(Sts59MFICaf9gqYE3Yp8zNKY7n)e5SuKtchQ78uNYiKjGNwgtWDoQSYQaa]] )

end
