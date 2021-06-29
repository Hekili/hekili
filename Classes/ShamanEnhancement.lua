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
        ride_the_lightning = 721, -- 289874
        seasoned_winds = 5414, -- 355630
        shamanism = 722, -- 193876
        skyfury_totem = 3487, -- 204330
        spectral_recovery = 3519, -- 204261
        static_field_totem = 5438, -- 355580
        swelling_waves = 3623, -- 204264
        thundercharge = 725, -- 204366
        unleash_shield = 3492, -- 356736
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
        },
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
                if buff.chains_of_devastation_ch.up then return 0 end
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

                if buff.primordial_wave.up and state.spec.enhancement and legendary.splintered_elements.enabled then
                    applyBuff( "splintered_elements", nil, active_dot.flame_shock )
                end
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


    spec:RegisterPack( "Enhancement", 20210628, [[duup1aqiLI6rOuQnbi9jPs1OaeofaQxPkAwaQBHsjXUe6xQcdtGCmaAzsL8muQmnaKRHsX2aG(gGOgNuP05uksRdqeZtPiUNsSpLcheqKAHkv9qaaxeaOpIsj4KaGwPaMjkLOBIsjPDkv8tukPwkkLqpLutvQQVcisgRuPO9k5VQQbd0HjwmipgvtwHlJSzf9zL0OvLonvVwQYSj52Oy3u(TkdxqhhLQwouphY0fDDqTDLkFhLmEPsHZlqnFLs7xkxaw9l9qsQ60vqDbyqayxDBSl2bqaeabqLodoKkDOW7jRuPnHHknaO9kgNyillDOeS6Kr1V0OdgZPsRDgaGsdb7QeaAfuPhssvNUcQladca7QBJDXoacGaOsJcjE1PlaKDL(1hdYkOspieV0aG2RyCIHSSbQFfgXAbcaBudSRUf4gyxb1fGLw5Oev9lnYTvfv9Roaw9lTWt)SsZYTbkXEpQ0KjqkAu7RS60v1V0KjqkAu7lnh7jHDP0qWZz89Y)RyJiCydC72giq0aXWgnp8kfdXoJO(kzN8fEcl5HrrI9WEyinAGaTbcbpNXqSZiQVs2jFHNWsEyueLcVxdCJgia2ab4sl80pR0kzN8vc6TYQd7Q(LMmbsrJAFP5ypjSlLEZnqi45mgIDMdpCr9zj7OiCyPfE6Nv6qSZC4HlQplzhvz1bGQ(LMmbsrJAFP5ypjSlLgdB08WRuCChZNLBduKypShgsJgiqBGqWZzCChZNLBdueoS0cp9ZknkpmdkXEpQYQdBQ(LMmbsrJAFP5ypjSlLgdB08WRuCChZNLBduKypShgsJgiqBGqWZzCChZNLBdueoS0cp9ZknhlO3VYxFtZT1kRoay1V0KjqkAu7lnh7jHDP0yyJMhELIJ7y(SCBGIe7H9WqA0abAdecEoJJ7y(SCBGIWHLw4PFwPDo9rj27rvwDaYv)stMaPOrTV0CSNe2LsJHnAE4vkoUJ5ZYTbksSh2ddPrdeOnqi45moUJ5ZYTbkchwAHN(zLgbBdc72ALvNUT6xAYeifnQ9LMJ9KWUu6n3atN3ZT1sl80pR0tLWqF07X7vz1ztR(Lw4PFwP3rOqc)ZljMstMaPOrTVYQdGbv9lnzcKIg1(sZXEsyxkne8CgFfxHYdZeHdlTWt)SspXhk)O3J3RYQdGaw9lTWt)SstcoFj7Jc9EuPjtGu0O2xz1bWUQ(Lw4PFwPNc9tSyOjmYpR0KjqkAu7RS6ai7Q(LMmbsrJAFP5ypjSlLgcEoJO8Wm9ikKWr4Wsl80pR08xXTVYxFtZT1kRoacqv)stMaPOrTV0CSNe2LsdbpNrgHuOeFmFwKeEweLcVxdCJLgiBkTWt)SstkIHSuuFiLGYkRoaYMQFPjtGu0O2xAo2tc7sPHGNZiJqkuIpMplscplIsH3RbUXsdKnnqG2aXIp(0oYYOmgOOBnWnwAGBAqLw4PFwP5VIB)xbVJqzLvhabWQFPjtGu0O2xAo2tc7sPHGNZiJqkuIpMplscplIsH3RbU0abmOsl80pR0kF9nn3w)qNkRS6aiqU6xAHN(zLgLhMbLyVhvAYeifnQ9vwDaSBR(LMmbsrJAFP5ypjSlLgcEoJmcPqj(y(Sij8SikfEVg4glnq2uAHN(zLgLhMPhrHeUYQdGBA1V0cp9ZkTs2jFLGElnzcKIg1(kRoDfu1V0cp9ZknhlO3VYxFtZT1stMaPOrTVYQtxaw9lnzcKIg1(sl80pR0tLWqF07X7vAo2tc7sPX0etOxbsrLMhmxr)uWRuIQoawz1PRUQ(Lw4PFwPN4dLF07X7vAYeifnQ9vwD6IDv)sl80pR0oN(Oe79OstMaPOrTVYQtxau1V0KjqkAu7lnh7jHDP0yXhFAhzzugdu0Tg4glnqakOsl80pR0iyBqy3wRS60fBQ(LMmbsrJAFP5ypjSlLw4PVJ(JlJtLWqF07X7vAHN(zLE6y6B3oPYQtxay1V0KjqkAu7lnh7jHDP0qWZzKrifkXhZNfjHNfrPW71a3yPbYMsl80pR0kF9nn3w)qNkRS60fqU6xAHN(zLMeC((jfXqwkQstMaPOrTVYQtxDB1V0KjqkAu7lnh7jHDP0qWZzKLBJjmo4FEjXeXeJ4gQbUjnq2fuPfE6NvAwUnMW4G)5LetLvwA5OQF1bWQFPjtGu0O2xAo2tc7sPHGNZihlO3VYxFtZT1iCyPfE6NvAwUnqj27rvwD6Q6xAYeifnQ9LMJ9KWUuA0bRGCBexX3o672oF9Ws6NfjtGu0ObUDBdeDWki3gXPtQX)MFi1HqhdksMaPOrPfE6Nv6Pq)elgAcJ8ZQS6WUQFPjtGu0O2xAo2tc7sPXWgnp8kfh3X8z52afj2d7HH0Obc0gie8Cgh3X8z52afHdlTWt)SsZXc69R8130CBTYQdav9lnzcKIg1(sZXEsyxkne8CgFfxHYdZeHdlTWt)SspXhk)O3J3RYQdBQ(Lw4PFwPrW2GWUTwAYeifnQ9vwDaWQFPjtGu0O2xAHN(zLEQeg6JEpEVsZXEsyxknMMyc9kqkQbc0giq0atrrwgNoM(2TtIKjqkA0a3UTbMIISmQe0RBR)PsyiuKmbsrJg42Tnq(TJmXYOrC8Po8ObUDBdedB08WRume7mI6RKDYx4jSKhgfj2d7HH0ObcWLMhmxr)uWRuIQoawz1bix9lnzcKIg1(sl80pR0HyN5WdxuFwYoQ0CSNe2LsV5gie8CgdXoZHhUO(SKDueoS08G5k6NcELsu1bWkRoDB1V0KjqkAu7lnh7jHDP0cp9D0FCzCQeg6JEpEVg4glnq2vAHN(zLE6y6B3oPYQZMw9lTWt)SsVJqHe(NxsmLMmbsrJAFLvhadQ6xAYeifnQ9LMJ9KWUuAi45mgIDMdpCr9zj7OiCydeOnqi45mYiKcL4J5ZIKWZIOu49AGBS0aztPfE6NvALV(MMBRFOtLvwDaeWQFPjtGu0O2xAo2tc7sPHGNZikpmtpIcjCeoS0cp9Zkn)vC7R8130CBTYQdGDv9lnzcKIg1(sZXEsyxkDkkYYihlOx3w)O8WmrYeifnAGB32aHGNZihlO3VYxFtZT144yzLw4PFwP5yb9(v(6BAUTwz1bq2v9lnzcKIg1(sl80pR0kzN8vc6T0CSNe2LsNIISmQe0RBR)PsyiuKmbsrJsZdMROFk4vkrvhaRS6aiav9lnzcKIg1(sZXEsyxkne8Cg5yb9(v(6BAUTgHdBGaTbcenqi45m(E5)vSreoSbUDBdeiAGyyJMhELIHyNruFLSt(cpHL8WOiXEypmKgnqG2aHGNZyi2ze1xj7KVWtyjpmkIsH3RbUrdeaBGaCdeGlTWt)SsRKDYxjO3kRoaYMQFPjtGu0O2xAo2tc7sPHGNZihlO3VYxFtZT1iCyPfE6NvAuEyguI9EuLvhabWQFPfE6NvAowqVFLV(MMBRLMmbsrJAFLvhabYv)stMaPOrTV0CSNe2LsdbpNrgHuOeFmFwKeEweLcVxdCJLgiBkTWt)SsZFf3(VcEhHYkRoa2Tv)stMaPOrTV0CSNe2LsdbpNrgHuOeFmFwKeEweLcVxdCJLgiBkTWt)SstkIHSuuFiLGYkRoaUPv)stMaPOrTV0CSNe2LsdbpNrgHuOeFmFwKeEweLcVxdCJLgiBkTWt)SsJYdZ0JOqcxz1PRGQ(LMmbsrJAFP5ypjSlLgcEoJmcPqj(y(Sij8SikfEVg4sdeWGkTWt)SsZFf3(kF9nn3wRS60fGv)sl80pR0SCBGsS3JknzcKIg1(kRoD1v1V0cp9ZknkpmdkXEpQ0KjqkAu7RS60f7Q(Lw4PFwPvYo5Re0BPjtGu0O2xz1PlaQ6xAYeifnQ9Lw4PFwPNkHH(O3J3R0CSNe2LsJPjMqVcKIknpyUI(PGxPevDaSYQtxSP6xAHN(zLEk0pXIHMWi)SstMaPOrTVYQtxay1V0cp9Zk9eFO8JEpEVstMaPOrTVYQtxa5QFPfE6NvANtFuI9EuPjtGu0O2xz1PRUT6xAYeifnQ9LMJ9KWUuAi45mYiKcL4J5ZIKWZIOu49AGBS0aztPfE6NvA(R42x5RVP52ALvNU20QFPjtGu0O2xAo2tc7sPfE67O)4Y4ujm0h9E8EnWnAGawAHN(zLE6y6B3oPYQd7cQ6xAHN(zLMeC(s2hf69OstMaPOrTVYQd7aS6xAHN(zLMeC((jfXqwkQstMaPOrTVYQd76Q6xAYeifnQ9LMJ9KWUuAi45mYYTXegh8pVKyIyIrCd1a3Kgi7cQ0cp9Zknl3gtyCW)8sIPYkl9GMcSkR(vhaR(Lw4PFwPHu3nuWOS0KjqkAuqvwD6Q6xAYeifnQ9LMJ9KWUuAOdHAGaTbo9138JjgXnudCtAGayqLEqio2dt)Ssdan2k8JbsYgy4L(znqh1aHO5HPgi)yGKSbs2aflTWt)SshEPFwLvh2v9lnzcKIg1(spieh7HPFwPbGwsymCywAHN(zLMLBJp6LeCLvhaQ6xAHN(zL(LeC(jeImovAYeifnQ9vwDyt1V0cp9ZknmI(EsmOstMaPOrTVYQdaw9lnzcKIg1(sZXEsyxk9MBGPOilJcIt2qmofjtGu0ObUDBdecEoJcIt2qmofHdBGB32a53PghllkiozdX4uetmIBOg4gnq2euPfE6NvAi1DJ)eghCLvhGC1V0KjqkAu7lnh7jHDP0BUbMIISmkiozdX4uKmbsrJg42Tnqi45mkiozdX4ueoS0cp9ZkneHreUNBRvwD62QFPjtGu0O2xAo2tc7sP3CdmffzzuqCYgIXPizcKIgnWTBBGqWZzuqCYgIXPiCydC72gi)o14yzrbXjBigNIyIrCd1a3ObYMGkTWt)SspDmbPUBuz1ztR(LMmbsrJAFP5ypjSlLEZnWuuKLrbXjBigNIKjqkA0a3UTbcbpNrbXjBigNIWHnWTBBG87uJJLffeNSHyCkIjgXnudCJgiBcQ0cp9ZkTyCcLyr95Isvz1bWGQ(LMmbsrJAFP5ypjSlLEZnWuuKLrbXjBigNIKjqkA0a3UTbU5gie8CgfeNSHyCkchwAHN(zLgsw)38NyN3dvz1bqaR(Lw4PFwPNewuFuOJ9S0KjqkAu7RS6ayxv)stMaPOrTV0CSNe2LsdenWuuKLrbXjBigNIKjqkA0a3UTbIHnAE4vkoUJ5ZYTbksSh2ddPrdeGBGaTbcenq0bRGCBexX3o672oF9Ws6NfjtGu0ObUDBdeDWki3gXPtQX)MFi1HqhdksMaPOrdC72gOWtFh9jJyCc1axAGa2ab4sl80pR0tH(jwm0eg5Nvz1bq2v9lnzcKIg1(sZXEsyxknw8XN2rwgLXafDRbUXsdCtdQbUDBdu4PVJ(KrmoHAGB0abS0cp9ZkTG4KneJtvwDaeGQ(LMmbsrJAFP5ypjSlLgdB08WRuCChZNLBduKypShgsJgiqBGqWZzCChZNLBd0FqqWZzCCSSgiqBGardel(4t7ilJYyGIU1a3yPbcGb1a3UTbk803rFYigNqnWnAGa2ab4g42Tnqi45mYYTXegh8pVKyIJJL1abAdeiAGBUbIHnAE4vkoUJ5ZYTbksSh2ddPrdC72gie8Cgh3X8z52a9hee8CgHdBGaCPfE6NvAwUnMW4G)5LetLvhazt1V0KjqkAu7l9GqCShM(zLgaoBGNPcUbEg1ajJycg4gyi2pSNb3aNNsDSqnW8LAGDh52QI6Edu4PFwdu5OmwAHN(zLMlk1x4PF2x5OS0CSNe2Lsl803rFYigNqnWLgiGLw5O8BcdvAKBRkQYQdGay1V0KjqkAu7l9GqCShM(zLMT2AGmWQ0dvudKmIXjeWnW8LAGHy)WEgCdCEk1Xc1aZxQb2D5OU3afE6N1avokJLw4PFwP5Is9fE6N9voklnh7jHDP0cp9D0NmIXjudCJgiGLw5O8BcdvA5OkRoacKR(Lw4PFwP5hSLegLyVh9ZljMstMaPOrTVYQdGDB1V0cp9ZknQxWtyCW)8sIP0KjqkAu7RS6a4Mw9lTWt)SshIDgr9rj27rLMmbsrJAFLvw6qmXpgijR(vhaR(LMmbsrJAFP5ypjSlLgcEoJSCBmHXb)zrs4zrmXiUHAGBsdKDbfuPfE6NvAwUnMW4G)Sij8SkRoDv9lnzcKIg1(sZXEsyxkne8CgNkHHYZwHPplscplIjgXnudCtAGSlOGkTWt)SspvcdLNTctFwKeEwLvh2v9lTWt)SsdDzQOXFQKGPbl3w)51nCR0KjqkAu7RS6aqv)stMaPOrTV0CSNe2LsdbpNrLV(MMBRF0RtQretmIBOg4M0azxqbvAHN(zLw5RVP526h96KAuz1Hnv)stMaPOrTV0CSNe2LsNIISmIYdZ0JOqchjtGu0O0cp9ZknkpmtpIcjCLvhaS6xAYeifnQ9LMJ9KWUu6n3aXWgnp8kfh3X8z52afj2d7HH0Obc0gie8Cgz52ycJd(NxsmXXXYkTWt)SsZYTXegh8pVKyQS6aKR(LMmbsrJAFP5ypjSlLg6qOsl80pR0Hx6NvzLvw6Deg5NvD6kOUamiaki2vAwc2CBfvAGuaPzl2ba2HTaqsdSb2)LAGot4HZg48WnWUlh19giMypSJPrdeDmuduGZJrsA0a5VITsOylaBPBudSlGKgiaWz7iCsJgy3rhScYTrSB29gyEnWUJoyfKBJy3msMaPOr3BGabGDdao2cWw6g1a7ciPbcaC2ocN0Ob2D0bRGCBe7MDVbMxdS7Odwb52i2nJKjqkA09gOKnqaq2A2Ygiqay3aGJTaTaaPasZwSdaSdBbGKgydS)l1aDMWdNnW5HBGDFqtbwLDVbIj2d7yA0arhd1af48yKKgnq(RyRek2cWw6g1abSlGKgiaWz7iCsJgy3rhScYTrSB29gyEnWUJoyfKBJy3msMaPOr3BGarxDdao2c0caazcpCsJgia1afE6N1avokrXwGslW57HlT2zaakDi(MUIknBZ2nqaq7vmoXqw2a1VcJyTaSnB3adaBudSRUf4gyxb1fGTaTacp9ZqXqmXpgijxy52ycJd(ZIKWZa2NlqWZzKLBJjmo4plscplIjgXn0MWUGcQfq4PFgkgIj(Xaj5ZLhtLWq5zRW0NfjHNbSpxGGNZ4ujmuE2km9zrs4zrmXiUH2e2fuqTacp9ZqXqmXpgijFU8a6YurJ)ujbtdwUT(ZRB4wlGWt)mumet8JbsYNlpu(6BAUT(rVoPga7Zfi45mQ8130CB9JEDsnIyIrCdTjSlOGAbeE6NHIHyIFmqs(C5bkpmtpIcjmW(CjffzzeLhMPhrHeosMaPOrlGWt)mumet8JbsYNlpy52ycJd(Nxsma7ZLnJHnAE4vkoUJ5ZYTbksSh2ddPbqHGNZil3gtyCW)8sIjoowwlGWt)mumet8JbsYNlpcV0pdyFUaDiulqlaBZ2nqaWUbXHtA0aPDeo4gy6mudmFPgOWZd3aDudu2jUsGuuSfq4PFgAbsD3qbJYwa2Ubcan2k8JbsYgy4L(znqh1aHO5HPgi)yGKSbs2afBbeE6NHEU8i8s)mG95c0HqaD6RV5htmIBOnbadQfGTBGaqljmgomBbeE6NHEU8GLBJp6LeClGWt)m0ZLhVKGZpHqKXPwaHN(zONlpGr03tIb1ci80pd9C5bK6UXFcJdgyFUS5uuKLrbXjBigNIKjqkASDle8CgfeNSHyCkchUDl)o14yzrbXjBigNIyIrCdTbBcQfq4PFg65YdicJiCp3wb2NlBoffzzuqCYgIXPizcKIgB3cbpNrbXjBigNIWHTacp9ZqpxEmDmbPUBaSpx2CkkYYOG4KneJtrYeifn2UfcEoJcIt2qmofHd3ULFNACSSOG4KneJtrmXiUH2Gnb1ci80pd9C5HyCcLyr95IsbSpx2CkkYYOG4KneJtrYeifn2UfcEoJcIt2qmofHd3ULFNACSSOG4KneJtrmXiUH2Gnb1ci80pd9C5bKS(V5pXoVhcyFUS5uuKLrbXjBigNIKjqkASD7MHGNZOG4KneJtr4WwaHN(zONlpMewuFuOJ9Sfq4PFg65YJPq)elgAcJ8Za2NlarkkYYOG4KneJtrYeifn2UfdB08WRuCChZNLBduKypShgsdagOab6GvqUnIR4Bh9DBNVEyj9Z2UfDWki3gXPtQX)MFi1HqhdA7wHN(o6tgX4eAbqaUfq4PFg65YdbXjBigNa2NlyXhFAhzzugdu0Tnw20G2Uv4PVJ(KrmoH2aWwaHN(zONlpy52ycJd(Nxsma7ZfmSrZdVsXXDmFwUnqrI9WEyinake8Cgh3X8z52a9hee8CghhldOabw8XN2rwgLXafDBJfamOTBfE67OpzeJtOnaeG3UfcEoJSCBmHXb)ZljM44yzafi2mg2O5HxP44oMpl3gOiXEypmKgB3cbpNXXDmFwUnq)bbbpNr4qaUfGTBGaWzd8mvWnWZOgizetWa3adX(H9m4g48uQJfQbMVudS7i3wvu3BGcp9ZAGkhLXwaHN(zONlp4Is9fE6N9vokb2egAb52QIa2Nlcp9D0NmIXj0cGTaSDdKT2AGmWQ0dvudKmIXjeWnW8LAGHy)WEgCdCEk1Xc1aZxQb2D5OU3afE6N1avokJTacp9ZqpxEWfL6l80p7RCucSjm0ICeW(Cr4PVJ(KrmoH2aWwaHN(zONlp4hSLegLyVh9ZljMwaHN(zONlpq9cEcJd(NxsmTacp9ZqpxEeIDgr9rj27rTaTaSnB3azRcRsVbMcELYgOWt)Sgyi2pSNb3avokBbeE6NHIYrlSCBGsS3Ja2NlqWZzKJf07x5RVP52AeoSfq4PFgkkh9C5XuOFIfdnHr(za7Zf0bRGCBexX3o672oF9Ws6NTDl6GvqUnItNuJ)n)qQdHogulGWt)muuo65YdowqVFLV(MMBRa7ZfmSrZdVsXXDmFwUnqrI9WEyinake8Cgh3X8z52afHdBbeE6NHIYrpxEmXhk)O3J3dyFUabpNXxXvO8Wmr4WwaHN(zOOC0ZLhiyBqy3wBbeE6NHIYrpxEmvcd9rVhVhW8G5k6NcELs0cGa7ZfmnXe6vGueqbIuuKLXPJPVD7KizcKIgB3MIISmQe0RBR)PsyiuKmbsrJTB53oYelJgXXN6WJTBXWgnp8kfdXoJO(kzN8fEcl5HrrI9WEyina4waHN(zOOC0ZLhHyN5WdxuFwYocyEWCf9tbVsjAbqG95YMHGNZyi2zo8Wf1NLSJIWHTacp9Zqr5ONlpMoM(2Tta2Nlcp9D0FCzCQeg6JEpEVnwyxlGWt)muuo65YJDekKW)8sIPfq4PFgkkh9C5HYxFtZT1p0PsG95ce8CgdXoZHhUO(SKDueoeOqWZzKrifkXhZNfjHNfrPW7TXcBAbeE6NHIYrpxEWFf3(kF9nn3wb2NlqWZzeLhMPhrHeoch2ci80pdfLJEU8GJf07x5RVP52kW(CjffzzKJf0RBRFuEyMizcKIgB3cbpNrowqVFLV(MMBRXXXYAbeE6NHIYrpxEOKDYxjOxG5bZv0pf8kLOfab2NlPOilJkb9626FQegcfjtGu0Ofq4PFgkkh9C5Hs2jFLGEb2NlqWZzKJf07x5RVP52AeoeOabe8CgFV8)k2ichUDlqGHnAE4vkgIDgr9vYo5l8ewYdJIe7H9WqAaui45mgIDgr9vYo5l8ewYdJIOu492aabyaUfq4PFgkkh9C5bkpmdkXEpcyFUabpNrowqVFLV(MMBRr4WwaHN(zOOC0ZLhCSGE)kF9nn3wBbeE6NHIYrpxEWFf3(VcEhHsG95ce8CgzesHs8X8zrs4zruk8EBSWMwaHN(zOOC0ZLhKIyilf1hsjOeyFUabpNrgHuOeFmFwKeEweLcV3glSPfq4PFgkkh9C5bkpmtpIcjmW(CbcEoJmcPqj(y(Sij8SikfEVnwytlGWt)muuo65Yd(R42x5RVP52kW(CbcEoJmcPqj(y(Sij8SikfEVfadQfq4PFgkkh9C5bl3gOe79OwaHN(zOOC0ZLhO8WmOe79OwaHN(zOOC0ZLhkzN8vc6Tfq4PFgkkh9C5Xujm0h9E8EaZdMROFk4vkrlacSpxW0etOxbsrTacp9Zqr5ONlpMc9tSyOjmYpRfq4PFgkkh9C5XeFO8JEpEVwaHN(zOOC0ZLhoN(Oe79OwaHN(zOOC0ZLh8xXTVYxFtZTvG95ce8CgzesHs8X8zrs4zruk8EBSWMwaHN(zOOC0ZLhthtF72ja7ZfHN(o6pUmovcd9rVhV3ga2ci80pdfLJEU8GeC(s2hf69OwaHN(zOOC0ZLhKGZ3pPigYsr1ci80pdfLJEU8GLBJjmo4FEjXaSpxGGNZil3gtyCW)8sIjIjgXn0MWUGAbAbyB2UbQDBvrnWuWRu2afE6N1adX(H9m4gOYrzlGWt)mue52QIwy52aLyVh1ci80pdfrUTQONlpuYo5Re0lW(CbcEoJVx(FfBeHd3UfiWWgnp8kfdXoJO(kzN8fEcl5HrrI9WEyinake8CgdXoJO(kzN8fEcl5Hrruk8EBaGaClGWt)mue52QIEU8ie7mhE4I6Zs2ra7ZLndbpNXqSZC4HlQplzhfHdBbeE6NHIi3wv0ZLhO8WmOe79iG95cg2O5HxP44oMpl3gOiXEypmKgafcEoJJ7y(SCBGIWHTacp9ZqrKBRk65YdowqVFLV(MMBRa7ZfmSrZdVsXXDmFwUnqrI9WEyinake8Cgh3X8z52afHdBbeE6NHIi3wv0ZLhoN(Oe79iG95cg2O5HxP44oMpl3gOiXEypmKgafcEoJJ7y(SCBGIWHTacp9ZqrKBRk65YdeSniSBRa7ZfmSrZdVsXXDmFwUnqrI9WEyinake8Cgh3X8z52afHdBbeE6NHIi3wv0ZLhtLWqF07X7bSpx2C68EUT2ci80pdfrUTQONlp2rOqc)ZljMwaHN(zOiYTvf9C5XeFO8JEpEpG95ce8CgFfxHYdZeHdBbeE6NHIi3wv0ZLhKGZxY(OqVh1ci80pdfrUTQONlpMc9tSyOjmYpRfq4PFgkICBvrpxEWFf3(kF9nn3wb2NlqWZzeLhMPhrHeoch2ci80pdfrUTQONlpifXqwkQpKsqjW(CbcEoJmcPqj(y(Sij8SikfEVnwytlGWt)mue52QIEU8G)kU9Ff8ocLa7Zfi45mYiKcL4J5ZIKWZIOu492yHnafl(4t7ilJYyGIUTXYMgulGWt)mue52QIEU8q5RVP526h6ujW(CbcEoJmcPqj(y(Sij8SikfEVfadQfq4PFgkICBvrpxEGYdZGsS3JAbeE6NHIi3wv0ZLhO8Wm9ikKWa7Zfi45mYiKcL4J5ZIKWZIOu492yHnTacp9ZqrKBRk65YdLSt(kb92ci80pdfrUTQONlp4yb9(v(6BAUT2ci80pdfrUTQONlpMkHH(O3J3dyEWCf9tbVsjAbqG95cMMyc9kqkQfq4PFgkICBvrpxEmXhk)O3J3Rfq4PFgkICBvrpxE4C6JsS3JAbeE6NHIi3wv0ZLhiyBqy3wb2NlyXhFAhzzugdu0TnwaOGAbeE6NHIi3wv0ZLhthtF72ja7ZfHN(o6pUmovcd9rVhVxlGWt)mue52QIEU8q5RVP526h6ujW(CbcEoJmcPqj(y(Sij8SikfEVnwytlGWt)mue52QIEU8GeC((jfXqwkQwaHN(zOiYTvf9C5bl3gtyCW)8sIbyFUabpNrwUnMW4G)5LetetmIBOnHDbvzLvb]] )


end
