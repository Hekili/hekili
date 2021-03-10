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


    spec:RegisterPack( "Enhancement", 20210310, [[duui0aqiLc9iuf1MaK(KKkgfQcofavVsvQzbOUfaPQDrv)svYWqv6yayzkf9mQatdvrUgGyBau(gQczCaeDoQGSojvQMNKk5EkY(Ku1bbiLwOsvpeGqxeGGpcqQCsaswjv0mrvOCtufQ2PK0pLuPyPsQu6PKAQskFfGumwQGYEL6VQQbd0HjwmepgLjRKlJSzf(SIA0QItt51sIztYTrLDl8Bvgov64kfSCOEoOPl66qA7kL(oQQXtfuDEQqZxPY(L4gGUwRxssD1n5Dta41baWRNxhINCiE5PwNo6sT2vyvKzQ1HWrTgqiEKGrCuKT2vCuDYQR1A4HIzuR1ghGyRrqnvcOIgP1ljPU6M8Uja86aa41ZRdXtasG4qTg6sSU6MaMdA9JTwu0iTErqwRbeIhjyehfzbu)iCsuCYJly2tbeaEbUaUjVBcqRvgmHDTwdTywrDTUkaDTwlS0UO18TybtSvHAnfcIIw9(o7QB21AnfcIIw9(wZWwsytAnc6y4FU8)iXYJ6wa3TRaYdfqmAqJdptExSXjQVs2kFHLOsEyON2aQ56sRciqlGiOJH3fBCI6RKTYxyjQKhg6HPWQuaRVacyfqaV1clTlATs2kFLaF6SR6GUwRPqqu0Q33Ag2scBsR3ybebDm8UyJ7WltuF(YwYJ62AHL2fT2fBChEzI6Zx2sD2v5PUwRPqqu0Q33Ag2scBsRXObno8m5x3X95BXc6PnGAUU0Qac0cic6y4x3X95BXc6rDBTWs7IwdZdZbtSvH6SRcKUwRPqqu0Q33Ag2scBsRXObno8m5x3X95BXc6PnGAUU0Qac0cic6y4x3X95BXc6rDBTWs7IwZWc85RS5NmSyUZUkG11AnfcIIw9(wZWwsytAngnOXHNj)6oUpFlwqpTbuZ1LwfqGwarqhd)6oUpFlwqpQBRfwAx0AJrFyITkuNDvEuxR1uiikA17BndBjHnP1BSaMgRIfZTwyPDrRhkHJ(WNJvPZUkGSR1AHL2fTElbDj8pVK4AnfcIIw9(o7QouxR1uiikA17BndBjHnP1iOJH)rmfmpmNh1T1clTlA9aFW8dFowLo7QaWBxR1clTlAnj48HIp01QqTMcbrrREFNDvaaOR1AHL2fTEi0pXsahOq7IwtHGOOvVVZUkaB21AnfcIIw9(wZWwsytA9glGUjUac0cic6y4H5H5QqKlH9OUTwyPDrRv28tgwm)rov2zxfah01AnfcIIw9(wZWwsytATBIlGaTaIGogEyEyUke5sypQBRfwAx0A2JyXxzZpzyXCNDva4PUwRPqqu0Q33Ag2scBsRrqhdpNqkyIpUpFsCVWdtHvPaw)ubeiTwyPDrRjfXrrkQpIsGzNDvaasxR1uiikA17BndBjHnP1iOJHNtifmXh3NpjUx4HPWQuaRFQacKciqlGyXwFAlfPxwlO3Icy9tfqhI3wlS0UO1ShXI)JG3sWSZUkaawxR1uiikA17BndBjHnP1iOJHNtifmXh3NpjUx4HPWQuaNkGaWBRfwAx0ALn)KHfZFKtLD2vbGh11ATWs7IwdZdZbtSvHAnfcIIw9(o7Qaai7ATMcbrrREFRzyljSjTgbDm8CcPGj(4(8jX9cpmfwLcy9tfqG0AHL2fTgMhMRcrUeUZUkaouxR1clTlATs2kFLaFAnfcIIw9(o7QBYBxR1clTlAndlWNVYMFYWI5wtHGOOvVVZU6Ma01AnfcIIw9(wlS0UO1dLWrF4ZXQ0Ag2scBsRX0atWhbrrTM5itr)uWZuc7Qa0zxDZn7ATwyPDrRh4dMF4ZXQ0AkeefT69D2v30bDTwlS0UO1gJ(WeBvOwtHGOOvVVZU6M8uxR1uiikA17BndBjHnP1yXwFAlfPxwlO3Icy9tfqEI3wlS0UO1q0yrylM7SRUjq6ATMcbrrREFRzyljSjTwyPTL(Rl9dLWrF4ZXQ0AHL2fTEyy6h3wPZU6MawxR1uiikA17BndBjHnP1iOJHNtifmXh3NpjUx4HPWQuaRFQacKwlS0UO1kB(jdlM)iNk7SRUjpQR1AHL2fTMeC(8jfXrrkQwtHGOOvVVZU6MaYUwRPqqu0Q33Ag2scBsRrqhdpFlwduSJ)8sIZJjoXcybSUkGoG3wlS0UO18TynqXo(ZljUo7S1YrDTUkaDTwtHGOOvVV1mSLe2KwJGogEgwGpFLn)KHfZEu3wlS0UO18TybtSvH6SRUzxR1uiikA17BndBjHnP1WdvHyXYpJVT03IT28HL0UWtHGOOvbC3Uci8qviwS8dJuR)n(iQdcpoONcbrrRwlS0UO1dH(jwc4afAx0zx1bDTwtHGOOvVV1mSLe2KwJrdAC4zYVUJ7Z3If0tBa1CDPvbeOfqe0XWVUJ7Z3If0J62AHL2fTMHf4ZxzZpzyXCNDvEQR1AkeefT69TMHTKWM0Ae0XW)iMcMhMZJ62AHL2fTEGpy(HphRsNDvG01ATWs7IwdrJfHTyU1uiikA177SRcyDTwtHGOOvVV1clTlA9qjC0h(CSkTMHTKWM0AmnWe8rquubeOfqEOaMIII0pmm9JBR4Pqqu0QaUBxbmfffPxjWhlM)dLWrqpfcIIwfWD7kGSBlfsK(Gy4tD4vbC3UcignOXHNjVl24e1xjBLVWsujpm0tBa1CDPvbeWBnZrMI(PGNPe2vbOZUkpQR1AkeefT69TwyPDrRDXg3HxMO(8LTuRzyljSjTEJfqe0XW7InUdVmr95lBjpQBRzoYu0pf8mLWUkaD2vbKDTwtHGOOvVV1mSLe2KwlS02s)1L(Hs4Op85yvkG1pvaDqRfwAx06HHPFCBLo7QouxR1clTlA9wc6s4FEjX1AkeefT69D2vbG3UwRPqqu0Q33Ag2scBsRrqhdVl24o8Ye1NVSL8OUfqGwarqhdpNqkyIpUpFsCVWdtHvPaw)ubeiTwyPDrRv28tgwm)rov2zxfaa6ATMcbrrREFRzyljSjTgbDm8W8WCviYLWEu3wlS0UO1ShXIVYMFYWI5o7QaSzxR1uiikA17BndBjHnP1POOi9mSaFSy(dZdZ5Pqqu0QaUBxbebDm8mSaF(kB(jdlM9RJF0AHL2fTMHf4ZxzZpzyXCNDvaCqxR1uiikA17BTWs7IwRKTYxjWNwZWwsytADkkksVsGpwm)hkHJGEkeefTAnZrMI(PGNPe2vbOZUka8uxR1uiikA17BndBjHnP1iOJHNHf4ZxzZpzyXSh1Tac0cipuarqhd)ZL)hjwEu3c4UDfqEOaIrdAC4zY7Inor9vYw5lSevYdd90gqnxxAvabAbebDm8UyJtuFLSv(clrL8WqpmfwLcy9fqaRac4fqaV1clTlATs2kFLaF6SRcaq6ATMcbrrREFRzyljSjTgbDm8mSaF(kB(jdlM9OUTwyPDrRH5H5Gj2QqD2vbaW6ATwyPDrRzyb(8v28tgwm3AkeefT69D2vbGh11AnfcIIw9(wZWwsytAnc6y45esbt8X95tI7fEykSkfW6NkGaP1clTlAn7rS4)i4Tem7SRcaGSR1AkeefT69TMHTKWM0Ae0XWZjKcM4J7ZNe3l8WuyvkG1pvabsRfwAx0AsrCuKI6JOey2zxfahQR1AkeefT69TMHTKWM0Ae0XWZjKcM4J7ZNe3l8WuyvkG1pvabsRfwAx0AyEyUke5s4o7QBYBxR1uiikA17BndBjHnP1iOJHNtifmXh3NpjUx4HPWQuaNkGaWBRfwAx0A2JyXxzZpzyXCND1nbOR1AHL2fTMVflyITkuRPqqu0Q33zxDZn7ATwyPDrRH5H5Gj2QqTMcbrrREFND1nDqxR1clTlATs2kFLaFAnfcIIw9(o7QBYtDTwtHGOOvVV1clTlA9qjC0h(CSkTMHTKWM0AmnWe8rquuRzoYu0pf8mLWUkaD2v3eiDTwlS0UO1dH(jwc4afAx0AkeefT69D2v3eW6ATwyPDrRh4dMF4ZXQ0AkeefT69D2v3Kh11ATWs7IwBm6dtSvHAnfcIIw9(o7QBci7ATMcbrrREFRzyljSjTgbDm8CcPGj(4(8jX9cpmfwLcy9tfqG0AHL2fTM9iw8v28tgwm3zxDthQR1AkeefT69TMHTKWM0AHL2w6VU0puch9HphRsbS(ciaTwyPDrRhgM(XTv6SR6aE7ATwyPDrRjbNpu8HUwfQ1uiikA177SR6aa6ATwyPDrRjbNpFsrCuKIQ1uiikA177SR6Gn7ATMcbrrREFRzyljSjTgbDm88TynqXo(ZljopM4elGfW6Qa6aEBTWs7IwZ3I1af74pVK46SZwVOHGQYUwxfGUwRfwAx0Ae1DlfkmBnfcIIwnsND1n7ATMcbrrREFRzyljSjTg5GWciqlGdB(j)yItSawaRRciGXBRxeKHn30UO1aQaqp74qKSa6EPDrb0GfqeACyQaYooejlGuSG(wlS0UO1UxAx0zx1bDTwtHGOOvVV1lcYWMBAx0AavKegJ6MfWBuazcmH(wlS0UO18Ty9HpKG7SRYtDTwlS0UO1Oq6BjXbBnfcIIw9(o7QaPR1AkeefT69TMHTKWM06nwatrrr6fiJILemYtHGOOvbC3Ucic6y4fiJILemYJ6wa3TRaYUtTo(HxGmkwsWipM4elGfW6lGaH3wlS0UO1iQ7w)bk2Xo7QawxR1uiikA17BndBjHnP1BSaMIII0lqgfljyKNcbrrRc4UDfqe0XWlqgfljyKh1T1clTlAncHHeUIfZD2v5rDTwtHGOOvVV1mSLe2KwVXcykkksVazuSKGrEkeefTkG72varqhdVazuSKGrEu3c4UDfq2DQ1Xp8cKrXscg5XeNybSawFbei82AHL2fTEyycrD3QZUkGSR1AkeefT69TMHTKWM06nwatrrr6fiJILemYtHGOOvbC3Ucic6y4fiJILemYJ6wa3TRaYUtTo(HxGmkwsWipM4elGfW6lGaH3wlS0UO1sWiyIf1NjkvNDvhQR1AkeefT69TMHTKWM06nwatrrr6fiJILemYtHGOOvbC3Uc4glGiOJHxGmkwsWipQBRfwAx0Aez(FJFInwfyNDva4TR1AHL2fTEqyr9HUg2YwtHGOOvVVZUkaa01AnfcIIw9(wZWwsytAnpuatrrr6fiJILemYtHGOOvbC3UcignOXHNj)6oUpFlwqpTbuZ1LwfqaVac0cipuaHhQcXILFgFBPVfBT5dlPDHNcbrrRc4UDfq4HQqSy5hgPw)B8ruheECqpfcIIwfWD7kGclTT0NcIZiybCQacqbeWBTWs7Iwpe6NyjGduODrNDva2SR1AkeefT69TMHTKWM0ASyRpTLI0lRf0BrbS(PcOdXBbC3UcOWsBl9PG4mcwaRVacqRfwAx0AbYOyjbJ6SRcGd6ATMcbrrREFRzyljSjTgJg04WZKFDh3NVflON2aQ56sRciqlGiOJHFDh3NVfl4FriOJHFD8JciqlG8qbel26tBPi9YAb9wuaRFQacy8wa3TRakS02sFkioJGfW6lGauab8c4UDfqe0XWZ3I1af74pVK48RJF0AHL2fTMVfRbk2XFEjX1zxfaEQR1AkeefT69TErqg2Ct7IwdOgfWluowaVGkGuqCocCb0fBh2shlGJtPo(Wcy(qfW6aTywr1PakS0UOaQmy6BTWs7IwZeL6lS0U4Rmy2Ag2scBsRfwABPpfeNrWc4ubeGwRmy(dHJAn0Izf1zxfaG01AnfcIIw9(wViidBUPDrRRBIcihQknxfvaPG4mccCbmFOcOl2oSLowahNsD8HfW8HkG1roQofqHL2ffqLbtFRfwAx0AMOuFHL2fFLbZwZWwsytATWsBl9PG4mcwaRVacqRvgm)HWrTwoQZUkaawxR1clTlAn7qJKWWeBvOFEjX1AkeefT69D2vbGh11ATWs7IwdR44af74pVK4AnfcIIw9(o7Qaai7ATwyPDrRDXgNO(WeBvOwtHGOOvVVZoBTlMyhhIKDTUkaDTwtHGOOvVV1mSLe2KwJGogE(wSgOyh)8jX9cpM4elGfW6Qa6aE5T1clTlAnFlwduSJF(K4ErND1n7ATMcbrrREFRzyljSjTgbDm8dLWr5fZO0NpjUx4XeNybSawxfqhWlVTwyPDrRhkHJYlMrPpFsCVOZUQd6ATwyPDrRrUmv06puIJ0IVfZ)8C4w0AkeefT69D2v5PUwRPqqu0Q33Ag2scBsRrqhdVYMFYWI5p8Xi1YJjoXcybSUkGoGxEBTWs7IwRS5NmSy(dFmsT6SRcKUwRPqqu0Q33Ag2scBsR3ybeJg04WZKFDh3NVflON2aQ56sRciqlGiOJHNVfRbk2XFEjX5xh)O1clTlAnFlwduSJ)8sIRZUkG11AnfcIIw9(wZWwsytADkkkspmpmxfICjSNcbrrRwlS0UO1W8WCviYLWD2zNTElHH2fD1n5Dta41b8ciBnFbhwmdBnGgaT1Tvbuvb0v3lGfWApub04CpCwahhUawh5O6uaX0gqnmTkGWJJkGcAECssRci7rIzc6lo5XSGkGBw3lGaIxSLWjTkG1bEOkelwEhwDkG5vaRd8qviwS8ompfcIIw1PaYda4WbCFXjpMfubCZ6Ebeq8ITeoPvbSoWdvHyXY7WQtbmVcyDGhQcXIL3H5Pqqu0QofqjlGac1n8yfqEaahoG7lolob0aOTUTkGQkGU6EbSaw7HkGgN7HZc44WfW6SOHGQY6uaX0gqnmTkGWJJkGcAECssRci7rIzc6lo5XSGkGaaqDVaciEXwcN0Qawh4HQqSy5Dy1PaMxbSoWdvHyXY7W8uiikAvNcipSPdhW9fNfNako3dN0QaYtfqHL2ffqLbtOV4S1cA(C4wRnoaXw7IVHPOwZZ8CbeqiEKGrCuKfq9JWjrXjpZZfqECbZEkGaWlWfWn5DtakolofwAxa9UyIDCisoX3I1af74NpjUxaSnMqqhdpFlwduSJF(K4EHhtCIfW6Yb8YBXPWs7cO3ftSJdrY3tVgkHJYlMrPpFsCVayBmHGog(Hs4O8Izu6ZNe3l8yItSawxoGxElofwAxa9UyIDCis(E6fYLPIw)HsCKw8Ty(NNd3IItHL2fqVlMyhhIKVNEPS5NmSy(dFmsTa2gtiOJHxzZpzyX8h(yKA5XeNybSUCaV8wCkS0Ua6DXe74qK890l(wSgOyh)5LehW2yAJy0GghEM8R74(8Tyb90gqnxxAbue0XWZ3I1af74pVK48RJFuCkS0Ua6DXe74qK890lyEyUke5syGTXukkkspmpmxfICjSNcbrrRIZItEMNlGacoCIHM0QasBjSJfW04Ocy(qfqHLhUaAWcOSvmLGOiFXPWs7c4eI6ULcfMfN8Cbeqfa6zhhIKfq3lTlkGgSaIqJdtfq2XHizbKIf0xCkS0Ua(E6L7L2faBJjKdcb6WMFYpM4elG1fGXBXjpxabursymQBwaVrbKjWe6lofwAxaFp9IVfRp8HeCXPWs7c47PxOq6BjXblofwAxaFp9crD36pqXocSnM2ykkksVazuSKGrEkeefT2TdbDm8cKrXscg5rD3TJDNAD8dVazuSKGrEmXjwaRhi8wCkS0Ua(E6fcHHeUIfZaBJPnMIII0lqgfljyKNcbrrRD7qqhdVazuSKGrEu3ItHL2fW3tVggMqu3Ta2gtBmfffPxGmkwsWipfcIIw72HGogEbYOyjbJ8OU72XUtTo(HxGmkwsWipM4elG1deElofwAxaFp9scgbtSO(mrPa2gtBmfffPxGmkwsWipfcIIw72HGogEbYOyjbJ8OU72XUtTo(HxGmkwsWipM4elG1deElofwAxaFp9crM)34NyJvbcSnM2ykkksVazuSKGrEkeefT2TBJiOJHxGmkwsWipQBXPWs7c47PxdclQp01WwwCkS0Ua(E61qOFILaoqH2faBJjEifffPxGmkwsWipfcIIw72HrdAC4zYVUJ7Z3If0tBa1CDPfGduEaEOkelw(z8TL(wS1MpSK2f72bpufIfl)Wi16FJpI6GWJdUBNWsBl9PG4mcobaGxCkS0Ua(E6LazuSKGraBJjSyRpTLI0lRf0Br9toeV72jS02sFkioJG1dqXPWs7c47Px8TynqXo(ZljoGTXegnOXHNj)6oUpFlwqpTbuZ1LwafbDm8R74(8Tyb)lcbDm8RJFauEal26tBPi9YAb9wu)eGX7UDclTT0NcIZiy9aa472HGogE(wSgOyh)5LeNFD8JItEUacOgfWluowaVGkGuqCocCb0fBh2shlGJtPo(Wcy(qfW6aTywr1PakS0UOaQmy6lofwAxaFp9Ijk1xyPDXxzWe4q4OjOfZkcyBmjS02sFkioJGtauCYZfW6MOaYHQsZvrfqkioJGaxaZhQa6ITdBPJfWXPuhFybmFOcyDKJQtbuyPDrbuzW0xCkS0Ua(E6ftuQVWs7IVYGjWHWrtYraBJjHL2w6tbXzeSEakofwAxaFp9IDOrsyyITk0pVK4kofwAxaFp9cwXXbk2XFEjXvCkS0Ua(E6Ll24e1hMyRcvCwCYZ8CbKhhvLwbmf8mLfqHL2ffqxSDylDSaQmywCkS0Ua6LJM4BXcMyRcbSnMqqhdpdlWNVYMFYWIzpQBXPWs7cOxo690RHq)elbCGcTla2gtWdvHyXYpJVT03IT28HL0Uy3o4HQqSy5hgPw)B8ruheECWItHL2fqVC07PxmSaF(kB(jdlMb2gty0GghEM8R74(8Tyb90gqnxxAbue0XWVUJ7Z3If0J6wCkS0Ua6LJEp9AGpy(HphRcW2ycbDm8pIPG5H58OUfNclTlGE5O3tVGOXIWwmxCkS0Ua6LJEp9AOeo6dFowfGzoYu0pf8mLWjaa2gtyAGj4JGOiGYdPOOi9ddt)42kEkeefT2TlfffPxjWhlM)dLWrqpfcIIw72XUTuir6dIHp1Hx72HrdAC4zY7Inor9vYw5lSevYdd90gqnxxAb4fNclTlGE5O3tVCXg3HxMO(8LTeWmhzk6NcEMs4eaaBJPnIGogExSXD4LjQpFzl5rDlofwAxa9YrVNEnmm9JBRaSnMewABP)6s)qjC0h(CSk1p5GItHL2fqVC07PxBjOlH)5LexXPWs7cOxo690lLn)KHfZFKtLaBJje0XW7InUdVmr95lBjpQlqrqhdpNqkyIpUpFsCVWdtHvP(jGuCkS0Ua6LJEp9I9iw8v28tgwmdSnMqqhdpmpmxfICjSh1T4uyPDb0lh9E6fdlWNVYMFYWIzGTXukkkspdlWhlM)W8WCEkeefT2TdbDm8mSaF(kB(jdlM9RJFuCkS0Ua6LJEp9sjBLVsGpaZCKPOFk4zkHtaaSnMsrrr6vc8XI5)qjCe0tHGOOvXPWs7cOxo690lLSv(kb(aSnMqqhdpdlWNVYMFYWIzpQlq5be0XW)C5)rILh1D3oEaJg04WZK3fBCI6RKTYxyjQKhg6PnGAUU0cOiOJH3fBCI6RKTYxyjQKhg6HPWQupGb4aEXPWs7cOxo690lyEyoyITkeW2ycbDm8mSaF(kB(jdlM9OUfNclTlGE5O3tVyyb(8v28tgwmxCkS0Ua6LJEp9I9iw8Fe8wcMaBJje0XWZjKcM4J7ZNe3l8WuyvQFcifNclTlGE5O3tVifXrrkQpIsGjW2ycbDm8CcPGj(4(8jX9cpmfwL6NasXPWs7cOxo690lyEyUke5syGTXec6y45esbt8X95tI7fEykSk1pbKItHL2fqVC07PxShXIVYMFYWIzGTXec6y45esbt8X95tI7fEykSktaWBXPWs7cOxo690l(wSGj2QqfNclTlGE5O3tVG5H5Gj2QqfNclTlGE5O3tVuYw5Re4tXPWs7cOxo690RHs4Op85yvaM5itr)uWZucNaayBmHPbMGpcIIkofwAxa9YrVNEne6NyjGduODrXPWs7cOxo690Rb(G5h(CSkfNclTlGE5O3tVmg9Hj2QqfNclTlGE5O3tVypIfFLn)KHfZaBJje0XWZjKcM4J7ZNe3l8WuyvQFcifNclTlGE5O3tVggM(XTva2gtclTT0FDPFOeo6dFowL6bO4uyPDb0lh9E6fj48HIp01QqfNclTlGE5O3tVibNpFsrCuKIQ4uyPDb0lh9E6fFlwduSJ)8sIdyBmHGogE(wSgOyh)5LeNhtCIfW6Yb8wCwCYZ8CbuBXSIkGPGNPSakS0UOa6ITdBPJfqLbZItHL2fqp0IzfnX3IfmXwfQ4uyPDb0dTywrVNEPKTYxjWhGTXec6y4FU8)iXYJ6UBhpGrdAC4zY7Inor9vYw5lSevYdd90gqnxxAbue0XW7Inor9vYw5lSevYdd9WuyvQhWa8ItHL2fqp0Izf9E6Ll24o8Ye1NVSLa2gtBebDm8UyJ7WltuF(YwYJ6wCkS0Ua6HwmRO3tVG5H5Gj2QqaBJjmAqJdpt(1DCF(wSGEAdOMRlTakc6y4x3X95BXc6rDlofwAxa9qlMv07PxmSaF(kB(jdlMb2gty0GghEM8R74(8Tyb90gqnxxAbue0XWVUJ7Z3If0J6wCkS0Ua6HwmRO3tVmg9Hj2QqaBJjmAqJdpt(1DCF(wSGEAdOMRlTakc6y4x3X95BXc6rDlofwAxa9qlMv07PxdLWrF4ZXQaSnM2yASkwmxCkS0Ua6HwmRO3tV2sqxc)ZljUItHL2fqp0Izf9E61aFW8dFowfGTXec6y4FetbZdZ5rDlofwAxa9qlMv07PxKGZhk(qxRcvCkS0Ua6HwmRO3tVgc9tSeWbk0UO4uyPDb0dTywrVNEPS5NmSy(JCQeyBmTr3edue0XWdZdZvHixc7rDlofwAxa9qlMv07PxShXIVYMFYWIzGTXKBIbkc6y4H5H5QqKlH9OUfNclTlGEOfZk690lsrCuKI6JOeycSnMqqhdpNqkyIpUpFsCVWdtHvP(jGuCkS0Ua6HwmRO3tVypIf)hbVLGjW2ycbDm8CcPGj(4(8jX9cpmfwL6NacqXIT(0wksVSwqVf1p5q8wCkS0Ua6HwmRO3tVu28tgwm)rovcSnMqqhdpNqkyIpUpFsCVWdtHvzcaElofwAxa9qlMv07PxW8WCWeBvOItHL2fqp0Izf9E6fmpmxfICjmW2ycbDm8CcPGj(4(8jX9cpmfwL6NasXPWs7cOhAXSIEp9sjBLVsGpfNclTlGEOfZk690lgwGpFLn)KHfZfNclTlGEOfZk690RHs4Op85yvaM5itr)uWZucNaayBmHPbMGpcIIkofwAxa9qlMv07Pxd8bZp85yvkofwAxa9qlMv07PxgJ(WeBvOItHL2fqp0Izf9E6fenwe2IzGTXewS1N2sr6L1c6TO(jEI3ItHL2fqp0Izf9E61WW0pUTcW2ysyPTL(Rl9dLWrF4ZXQuCkS0Ua6HwmRO3tVu28tgwm)rovcSnMqqhdpNqkyIpUpFsCVWdtHvP(jGuCkS0Ua6HwmRO3tVibNpFsrCuKIQ4uyPDb0dTywrVNEX3I1af74pVK4a2gtiOJHNVfRbk2XFEjX5XeNybSUCaVD2z3a]] )

end
