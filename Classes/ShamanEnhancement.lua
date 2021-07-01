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


    spec:RegisterPack( "Enhancement", 20210701, [[du0b6aqiafpIcP2ekKpPu0Ouk0PukXRuLAwOGBrHKYUO0VaKHrH6yQIwMsONrHyAkOY1qHABaQ8nfuACki5CkOyDkfyEkOQ7PK2NsPoifsyHQsEiGsUiGs9rLssNuPGwjkAMki1nPqs1ovGFQusSukKKNkXuvO(kfs0ybu1EL6Vanyv1HjTyq9yctwsxgAZk6ZkvJgGtl8ALOzJQBJs7MQFRYWPOJRGy5i9Cetx01bz7kKVtbJxPK68kbZxvy)eD)Sh3LQMypyrJx8PXdRXpTgpugzrJF2LCbtSlMQyPUJDXvwSlaBhG6cKf9SlM6c8tR94UqoiQa7sjybwDbgk45g6nCxQAI9GfnEXNgpSg)0A8qzKNmEO6cXef9GfboJ0farTIEd3LkseDby7auxGSONYFbGYQUKjtihLFJymdY)IgV4ZUWdss6XDHe(oh7X9GN94UOImoVlgcVssASe7c6kmhR9Ro7bl2J7c6kmhR9RUiOrI0q7cm0CAbCjia1Rwit5)Xd5FJYpfYX5r3rRjnyvoixhPGQiH08OeloeOW0eRYpJKFyO50AsdwLdY1rkOksinpkXssvSu(3w(bo5FlDrfzCEx46ifKReaD2dmspUlORWCS2V6IGgjsdTlaJ8ddnNwtAWE0AOCqd6i0cz2fvKX5DXKgShTgkh0Goc7ShmC94UGUcZXA)QlcAKin0UqHCCE0D0wVJf0q4vIfhcuyAIv5NrYpm0CAR3XcAi8kXcz2fvKX5DHKhLLK0yj2zpGX94UGUcZXA)QlcAKin0UqHCCE0D0wVJf0q4vIfhcuyAIv5NrYpm0CAR3XcAi8kXcz2fvKX5DrqvcaqESdi9W37ShaC94UGUcZXA)QlcAKin0UqHCCE0D0wVJf0q4vIfhcuyAIv5NrYpm0CAR3XcAi8kXcz2fvKX5DjeiijPXsSZEWW2J7c6kmhR9RUiOrI0q7cfYX5r3rB9owqdHxjwCiqHPjwLFgj)WqZPTEhlOHWRelKzxurgN3fcKxrA47D2dgQECxqxH5yTF1fbnsKgAxag5pdXYW37IkY48Um5klcsaCILD2dgMECxurgN3LriXePG5LiBxqxH5yTF1zp4PX94UGUcZXA)QlcAKin0UadnNwaAWj5rzTqMDrfzCExM0JKGeaNyzN9GNp7XDrfzCExqLMaqhKyglXUGUcZXA)QZEWZf7XDrfzCExMkcMu1jtisCExqxH5yTF1zp4Pr6XDbDfMJ1(vxe0irAODbgAoTK8OSlr0ePwiZUOImoVlcaA4G8yhq6HV3zp45W1J7c6kmhR9RUiOrI0q7cm0CAzvKts6XcAavZZTKuflL)TxLFg3fvKX5Db5il6PYbH5kj7Sh8KX94UGUcZXA)QlcAKin0UadnNwwf5KKESGgq18CljvXs5F7v5NXYpJKFQgvqCe6PvRvInC5F7v5FymUlQiJZ7IaGgoiaLocjzN9GNaxpUlORWCS2V6IGgjsdTlWqZPLvrojPhlObunp3ssvSu(xL)Ng3fvKX5DHh7asp8Dq4JND2dEoS94UOImoVlK8OSKKglXUGUcZXA)QZEWZHQh3f0vyow7xDrqJePH2fyO50YQiNK0Jf0aQMNBjPkwk)BVk)mUlQiJZ7cjpk7senrAN9GNdtpUlORWCS2V6IGgjsdTlKdIdhE1o64AgCeKC8rONw0vyow7IkY48Um5ibGGQZSlHNiLczMD5zN9GfnUh3fvKX5DHRJuqUsa0f0vyow7xD2dw8zpUlQiJZ7IGQeaG8yhq6HV3f0vyow7xD2dwCXECxqxH5yTF1fvKX5DzYvweKa4el7IGgjsdTluCsrcafMJDrSGGJGPs3XK0dE2zpyrJ0J7IkY48UmPhjbjaoXYUGUcZXA)QZEWIdxpUlQiJZ7siqqssJLyxqxH5yTF1zpyrg3J7c6kmhR9RUiOrI0q7cvJkioc90Q1kXgU8V9Q8pCg3fvKX5DHa5vKg(EN9GfbUECxqxH5yTF1fbnsKgAxurgJqW6L2jxzrqcGtSSlQiJZ7YmOiOFJ0o7bloS94UGUcZXA)QlcAKin0UadnNwwf5KKESGgq18CljvXs5F7v5NXDrfzCEx4XoG0dFhe(4zN9GfhQECxqxH5yTF1fbnsKgAxiheho8Q1eIKqCeePqMzCUfDfMJ1UOImoVltosaiO6m7ShS4W0J7IkY48UGknbaICKf9u5DbDfMJ1(vN9aJyCpUlORWCS2V6IGgjsdTlWqZP1q41jeDbW8sK1srwnCI8p8YVrmUlQiJZ7IHWRti6cG5LiBND2f9WECp4zpUlORWCS2V6IGgjsdTlWqZPvqvcaqESdi9W3TqMDrfzCExmeELK0yj2zpyXECxqxH5yTF1fbnsKgAxiheho8QDNEJqWWhf7hvZ4Cl6kmhRY)JhYp5G4WHxTZa5vWBccZpc5yjw0vyow7IkY48UmvemPQtMqK48o7bgPh3f0vyow7xDrqJePH2fkKJZJUJ26DSGgcVsS4qGcttSk)ms(HHMtB9owqdHxjwiZUOImoVlcQsaaYJDaPh(EN9GHRh3f0vyow7xDrqJePH2fyO50cqdojpkRfYSlQiJZ7YKEKeKa4el7ShW4ECxurgN3fcKxrA47DbDfMJ1(vN9aGRh3f0vyow7xDrfzCExMCLfbjaoXYUiOrI0q7cfNuKaqH5O8Zi5FJYFQC0t7mOiOFJul6kmhRY)JhYFQC0tlxjacFhCYvwKyrxH5yv(F8q(f3i0vpTokOh)Ov5)Xd5Nc548O7O1KgSkhKRJuqvKqAEuIfhcuyAIv5FlDrSGGJGPs3XK0dE2zpyy7XDbDfMJ1(vxurgN3ftAWE0AOCqd6iSlcAKin0UamYpm0CAnPb7rRHYbnOJqlKzxeli4iyQ0Dmj9GND2dgQECxqxH5yTF1fbnsKgAxurgJqW6L2jxzrqcGtSu(3Ev(nsxurgN3Lzqrq)gPD2dgMECxurgN3LriXePG5LiBxqxH5yTF1zp4PX94UGUcZXA)QlcAKin0UadnNwtAWE0AOCqd6i0czk)ms(HHMtlRICsspwqdOAEULKQyP8V9Q8Z4UOImoVl8yhq6HVdcF8SZEWZN94UGUcZXA)QlcAKin0UadnNwsEu2LiAIulKzxurgN3fbanCqESdi9W37Sh8CXECxqxH5yTF1fbnsKgAxsLJEAfuLai8DqsEuwl6kmhRY)JhYpm0CAfuLaaKh7asp8DB9m4DrfzCExeuLaaKh7asp89o7bpnspUlORWCS2V6IkY48UW1rkixja6IGgjsdTlPYrpTCLai8DWjxzrIfDfMJ1UiwqWrWuP7ys6bp7Sh8C46XDbDfMJ1(vxe0irAODbgAoTcQsaaYJDaPh(UfYu(zK8Vr5hgAoTaUeeG6vlKP8)4H8Vr5Nc548O7O1KgSkhKRJuqvKqAEuIfhcuyAIv5NrYpm0CAnPbRYb56ifufjKMhLyjPkwk)Bl)aN8Vf5FlDrfzCEx46ifKReaD2dEY4ECxqxH5yTF1fbnsKgAxGHMtRGQeaG8yhq6HVBHm7IkY48UqYJYssASe7Sh8e46XDrfzCExeuLaaKh7asp89UGUcZXA)QZEWZHTh3f0vyow7xDrqJePH2fyO50YQiNK0Jf0aQMNBjPkwk)BVk)mUlQiJZ7IaGgoiaLocjzN9GNdvpUlORWCS2V6IGgjsdTlWqZPLvrojPhlObunp3ssvSu(3Ev(zCxurgN3fKJSONkheMRKSZEWZHPh3f0vyow7xDrqJePH2fyO50YQiNK0Jf0aQMNBjPkwk)BVk)mUlQiJZ7cjpk7senrAN9GfnUh3f0vyow7xDrqJePH2fyO50YQiNK0Jf0aQMNBjPkwk)RY)tJ7IkY48UiaOHdYJDaPh(EN9GfF2J7IkY48Uyi8kjPXsSlORWCS2V6ShS4I94UOImoVlK8OSKKglXUGUcZXA)QZEWIgPh3fvKX5DHRJuqUsa0f0vyow7xD2dwC46XDbDfMJ1(vxe0irAODHCqC4WR2rhxZGJGKJpc90IUcZXAxurgN3LjhjaeuDMDj8ePuiZSlp7ShSiJ7XDbDfMJ1(vxurgN3LjxzrqcGtSSlcAKin0UqXjfjauyo2fXccocMkDhtsp4zN9GfbUECxurgN3LPIGjvDYeIeN3f0vyow7xD2dwCy7XDrfzCExM0JKGeaNyzxqxH5yTF1zpyXHQh3fvKX5DjeiijPXsSlORWCS2V6ShS4W0J7c6kmhR9RUiOrI0q7cm0CAzvKts6XcAavZZTKuflL)TxLFg3fvKX5DraqdhKh7asp89o7bgX4ECxqxH5yTF1fbnsKgAxurgJqW6L2jxzrqcGtSu(3w(F2fvKX5Dzgue0VrAN9aJ8Sh3fvKX5DbvAcaDqIzSe7c6kmhR9Ro7bgzXECxurgN3fuPjaqKJSONkVlORWCS2V6ShyeJ0J7c6kmhR9RUiOrI0q7cm0CAneEDcrxamVezTuKvdNi)dV8BeJ7IkY48Uyi86eIUayEjY2zNDPItfIN94EWZECxurgN3fy(Dvoej7c6kmhRnCN9Gf7XDbDfMJ1(vxe0irAODb(ie5NrY)m2bKGuKvdNi)dV8dCg3Lkse0WmJZ7Yg6g1ehlSMYV5LX5YFqKFyCEuu(fhlSMYp6vITlQiJZ7I5LX5D2dmspUlORWCS2V6sfjcAyMX5Dzd9ePuiZSlQiJZ7IHWRGeaOs7ShmC94UOImoVlaqLMGiHGUa7c6kmhR9Ro7bmUh3fvKX5DbIGGrISKUGUcZXA)QZEaW1J7c6kmhR9RUiOrI0q7cWi)PYrpTkrGEvDbArxH5yv(F8q(HHMtRseOxvxGwit5)Xd5xChVEgCRseOxvxGwkYQHtK)TLFgBCxurgN3fy(DvWjeDHo7bdBpUlORWCS2V6IGgjsdTlaJ8Nkh90Qeb6v1fOfDfMJv5)Xd5hgAoTkrGEvDbAHm7IkY48UaJucsxg(EN9GHQh3f0vyow7xDrqJePH2fGr(tLJEAvIa9Q6c0IUcZXQ8)4H8ddnNwLiqVQUaTqMY)JhYV4oE9m4wLiqVQUaTuKvdNi)Bl)m24UOImoVlZGIW87QD2dgMECxqxH5yTF1fbnsKgAxag5pvo6Pvjc0RQlql6kmhRY)JhYpm0CAvIa9Q6c0czk)pEi)I741ZGBvIa9Q6c0srwnCI8VT8ZyJ7IkY48UOUajjv5GcLZ7Sh804ECxqxH5yTF1fbnsKgAxag5pvo6Pvjc0RQlql6kmhRY)JhYpWi)WqZPvjc0RQlqlKzxurgN3fyDh8MGjneljD2dE(Sh3fvKX5DzIuLdsmdAKDbDfMJ1(vN9GNl2J7c6kmhR9RUiOrI0q7YgL)u5ONwLiqVQUaTORWCSk)pEi)uihNhDhT17ybneELyXHafMMyv(3I8Zi5FJYp5G4WHxT70Becg(Oy)OAgNBrxH5yv(F8q(jheho8QDgiVcEtqy(rihlXIUcZXQ8)4H8RImgHGOJSbsK)v5)P8VLUOImoVltfbtQ6KjejoVZEWtJ0J7c6kmhR9RUiOrI0q7cvJkioc90Q1kXgU8V9Q8pmgl)pEi)QiJrii6iBGe5FB5)zxurgN3fLiqVQUa7Sh8C46XDbDfMJ1(vxe0irAODHc548O7OTEhlOHWReloeOW0eRYpJKFyO50wVJf0q4vcyfHHMtB9m4YpJK)nk)unQG4i0tRwReB4Y)2RYpWzS8)4H8RImgHGOJSbsK)TL)NY)wK)hpKFyO50Ai86eIUayEjYARNbx(zK8Vr5hyKFkKJZJUJ26DSGgcVsS4qGcttSk)pEi)WqZPTEhlOHWReWkcdnNwit5FlDrfzCExmeEDcrxamVez7Sh8KX94UGUcZXA)QlvKiOHzgN3LnCk)NZxq(phLF0r2fyq(nPXrJCb5FEC(zGi)jau(3Ke(oh3u(vrgNl)8GK2UOImoVlcLZbvrgNdYds2fbnsKgAxurgJqq0r2ajY)Q8)Sl8GKGUYIDHe(oh7Sh8e46XDbDfMJ1(vxQirqdZmoVlBfx(zH4zyYr5hDKnqcdYFcaLFtAC0ixq(NhNFgiYFcaL)n1d3u(vrgNl)8GK2UOImoVlcLZbvrgNdYds2fbnsKgAxurgJqq0r2ajY)2Y)ZUWdsc6kl2f9Wo7bph2ECxurgN3fXb5jsjjnwIG5LiBxqxH5yTF1zp45q1J7IkY48UqwUWeIUayEjY2f0vyow7xD2dEom94UOImoVlM0Gv5GKKglXUGUcZXA)QZo7IjffhlSM94EWZECxqxH5yTF1fbnsKgAxGHMtRHWRti6cGgq18Clfz1WjY)Wl)gXyJ7IkY48Uyi86eIUaObunpVZEWI94UGUcZXA)QlcAKin0UadnN2jxzX88Die0aQMNBPiRgor(hE53igBCxurgN3LjxzX88Die0aQMN3zpWi94UOImoVlWxMCSco56cy1q47G5T1H3f0vyow7xD2dgUECxqxH5yTF1fbnsKgAxGHMtlp2bKE47GeabYRwkYQHtK)Hx(nIXg3fvKX5DHh7asp8DqcGa51o7bmUh3f0vyow7xDrqJePH2Lu5ONwsEu2LiAIul6kmhRDrfzCExi5rzxIOjs7ShaC94UGUcZXA)QlcAKin0UamYpfYX5r3rB9owqdHxjwCiqHPjwLFgj)WqZP1q41jeDbW8sK1wpdExurgN3fdHxNq0faZlr2o7bdBpUlORWCS2V6IGgjsdTlKdIdhE1AcrsiocIuiZmo3IUcZXQ8)4H8toioC4v7OJRzWrqYXhHEArxH5yTlQiJZ7YKJeacQoZo7bdvpUlORWCS2V6IGgjsdTlWhH0fvKX5DX8Y48o7SZUmcPK48EWIgV4tJbUfhQUyqPE47KUyuAuyunydhSv3a5x(hdaL)G18OP8ppQ8VPE4MYpfhcuqXQ8towu(vO8y1eRYVaG67iXkzo0HJY)IBG8dSoFestSk)BsoioC4vlWVP8NN8Vj5G4WHxTaVfDfMJ1nL)n(CR3IvYCOdhL)f3a5hyD(iKMyv(3KCqC4WRwGFt5pp5FtYbXHdVAbEl6kmhRBk)Ak)a7TYql)B85wVfRK5qhok)loCBG8dSoFestSk)BsoioC4vlWVP8NN8Vj5G4WHxTaVfDfMJ1nLFnLFG9wzOL)n(CR3IvYuY0O0OWOAWgoyRUbYV8pgak)bR5rt5FEu5Fts47CCt5NIdbkOyv(jhlk)kuESAIv5xaq9DKyLmh6Wr5)5WSbYpW68rinXQ8Vj5G4WHxTa)MYFEY)MKdIdhE1c8w0vyow3u(1u(b2BLHw(34ZTElwjZHoCu(xCO2a5hyD(iKMyv(3KCqC4WRwGFt5pp5FtYbXHdVAbEl6kmhRBk)Ak)a7TYql)B85wVfRKPKPrPrHr1GnCWwDdKF5Fmau(dwZJMY)8OY)MvCQq8Ct5NIdbkOyv(jhlk)kuESAIv5xaq9DKyLmh6Wr5)5IBG8dSoFestSk)BsoioC4vlWVP8NN8Vj5G4WHxTaVfDfMJ1nL)nU4wVfRKPKPrPrHr1GnCWwDdKF5Fmau(dwZJMY)8OY)MMuuCSWAUP8tXHafuSk)KJfLFfkpwnXQ8laO(osSsMdD4O8pSBG8dSoFestSk)BsoioC4vlWVP8NN8Vj5G4WHxTaVfDfMJ1nL)n(CR3IvYCOdhL)HDdKFG15JqAIv5FtYbXHdVAb(nL)8K)njheho8Qf4TORWCSUP8RP8dS3kdT8VXNB9wSsMsMBiR5rtSk)dN8RImox(5bjjwjZUOqjGJ2LsWcS6Ij9Mbh7IrB0YpW2bOUazrpL)caLvDjtJ2OLFMqok)gXygK)fnEXNsMsMQiJZjwtkkowynxneEDcrxa0aQMNZqmxHHMtRHWRti6cGgq18Clfz1WjdVrm2yjtvKX5eRjffhlSMVxbAYvwmpFhcbnGQ55meZvyO50o5klMNVdHGgq18Clfz1WjdVrm2yjtvKX5eRjffhlSMVxbc(YKJvWjxxaRgcFhmVToCjtvKX5eRjffhlSMVxbIh7asp8DqcGa5vgI5km0CA5XoG0dFhKaiqE1srwnCYWBeJnwYufzCoXAsrXXcR57vGi5rzxIOjsziMRPYrpTK8OSlr0ePw0vyowLmvrgNtSMuuCSWA(EfidHxNq0faZlrwgI5kWqHCCE0D0wVJf0q4vIfhcuyAIvgbdnNwdHxNq0faZlrwB9m4sMQiJZjwtkkowynFVc0KJeacQotgI5k5G4WHxTMqKeIJGifYmJZF8GCqC4WR2rhxZGJGKJpc9uYufzCoXAsrXXcR57vGmVmoNHyUcFeIKPKPrB0YpWERrbuIv5hhH0fK)myr5pbGYVkYJk)br(1rAWvyoALmvrgNtwH53v5qKuY0OL)n0nQjowynLFZlJZL)Gi)W48OO8lowynLF0ReRKPkY4CY7vGmVmoNHyUcFecJMXoGeKISA4KHh4mwY0OL)n0tKsHmtjtvKX5K3Razi8kibaQujtvKX5K3RabavAcIec6cuYufzCo59kqqeemsKLizQImoN8Efiy(DvWjeDbgI5kWKkh90Qeb6v1fOfDfMJ1hpGHMtRseOxvxGwiZhpe3XRNb3Qeb6v1fOLISA4KTzSXsMQiJZjVxbcgPeKUm8DgI5kWKkh90Qeb6v1fOfDfMJ1hpGHMtRseOxvxGwitjtvKX5K3RandkcZVRYqmxbMu5ONwLiqVQUaTORWCS(4bm0CAvIa9Q6c0cz(4H4oE9m4wLiqVQUaTuKvdNSnJnwYufzCo59kqQlqssvoOq5CgI5kWKkh90Qeb6v1fOfDfMJ1hpGHMtRseOxvxGwiZhpe3XRNb3Qeb6v1fOLISA4KTzSXsMQiJZjVxbcw3bVjysdXscdXCfysLJEAvIa9Q6c0IUcZX6Jhadm0CAvIa9Q6c0czkzQImoN8EfOjsvoiXmOrkzQImoN8EfOPIGjvDYeIeNZqmx3yQC0tRseOxvxGw0vyowF8Gc548O7OTEhlOHWReloeOW0eRBHrBKCqC4WR2D6ncbdFuSFunJZF8GCqC4WR2zG8k4nbH5hHCSKhpurgJqq0r2ajRp3IKPkY4CY7vGuIa9Q6cKHyUs1OcIJqpTATsSHV96Wy8JhQiJrii6iBGKTFkzQImoN8EfidHxNq0faZlrwgI5kfYX5r3rB9owqdHxjwCiqHPjwzem0CAR3XcAi8kbSIWqZPTEgCgTrQgvqCe6PvRvIn8TxboJF8qfzmcbrhzdKS9ZT84bm0CAneEDcrxamVezT1ZGZOncmuihNhDhT17ybneELyXHafMMy9XdyO50wVJf0q4vcyfHHMtlK5wKmnA5FdNY)58fK)Zr5hDKDbgKFtAC0ixq(NhNFgiYFcaL)njHVZXnLFvKX5YppiPvYufzCo59kqcLZbvrgNdYdsYGRS4kj8DoYqmxvrgJqq0r2ajRpLmnA5FR4Yplepdtok)OJSbsyq(taO8BsJJg5cY)848Zar(taO8VPE4MYVkY4C5NhK0kzQImoN8EfiHY5GQiJZb5bjzWvwCvpKHyUQImgHGOJSbs2(PKPkY4CY7vGehKNiLK0yjcMxISsMQiJZjVxbISCHjeDbW8sKvYufzCo59kqM0Gv5GKKglrjtjtJ2OLFJ6q8mK)uP7yk)QiJZLFtAC0ixq(5bjLmvrgNtS6HRgcVssASeziMRWqZPvqvcaqESdi9W3TqMsMQiJZjw9W3RanvemPQtMqK4CgI5k5G4WHxT70Becg(Oy)OAgN)4b5G4WHxTZa5vWBccZpc5yjsMQiJZjw9W3RajOkbaip2bKE47meZvkKJZJUJ26DSGgcVsS4qGcttSYiyO50wVJf0q4vIfYuYufzCoXQh(EfOj9ijibWjwYqmxHHMtlan4K8OSwitjtvKX5eRE47vGiqEfPHVlzQImoNy1dFVc0KRSiibWjwYGybbhbtLUJjz9jdXCLItksaOWCKrBmvo6PDgue0VrQfDfMJ1hpsLJEA5kbq47GtUYIel6kmhRpEiUrOREADuqp(rRpEqHCCE0D0AsdwLdY1rkOksinpkXIdbkmnX6wKmvrgNtS6HVxbYKgShTgkh0GoczqSGGJGPs3XKS(KHyUcmWqZP1KgShTgkh0GocTqMsMQiJZjw9W3Randkc63iLHyUQImgHG1lTtUYIGeaNy52RgrYufzCoXQh(EfOriXePG5LiRKPkY4CIvp89kq8yhq6HVdcF8KHyUcdnNwtAWE0AOCqd6i0czYiyO50YQiNK0Jf0aQMNBjPkwU9kJLmvrgNtS6HVxbsaqdhKh7asp8DgI5km0CAj5rzxIOjsTqMsMQiJZjw9W3RajOkbaip2bKE47meZ1u5ONwbvjacFhKKhL1IUcZX6JhWqZPvqvcaqESdi9W3T1ZGlzQImoNy1dFVcexhPGCLaGbXccocMkDhtY6tgI5AQC0tlxjacFhCYvwKyrxH5yvYufzCoXQh(EfiUosb5kbadXCfgAoTcQsaaYJDaPh(UfYKrBegAoTaUeeG6vlK5JhBKc548O7O1KgSkhKRJuqvKqAEuIfhcuyAIvgbdnNwtAWQCqUosbvrcP5rjwsQILBdCBzlsMQiJZjw9W3RarYJYssASeziMRWqZPvqvcaqESdi9W3TqMsMQiJZjw9W3RajOkbaip2bKE47sMQiJZjw9W3RajaOHdcqPJqsYqmxHHMtlRICsspwqdOAEULKQy52RmwYufzCoXQh(EfiKJSONkheMRKKHyUcdnNwwf5KKESGgq18CljvXYTxzSKPkY4CIvp89kqK8OSlr0ePmeZvyO50YQiNK0Jf0aQMNBjPkwU9kJLmvrgNtS6HVxbsaqdhKh7asp8DgI5km0CAzvKts6XcAavZZTKuflxFASKPkY4CIvp89kqgcVssASeLmvrgNtS6HVxbIKhLLK0yjkzQImoNy1dFVcexhPGCLaqYufzCoXQh(EfOjhjaeuDMmeEIukKzU(KHyUsoioC4v7OJRzWrqYXhHEkzQImoNy1dFVc0KRSiibWjwYGybbhbtLUJjz9jdXCLItksaOWCuYufzCoXQh(EfOPIGjvDYeIeNlzQImoNy1dFVc0KEKeKa4elLmvrgNtS6HVxbkeiijPXsuYufzCoXQh(EfibanCqESdi9W3ziMRWqZPLvrojPhlObunp3ssvSC7vglzQImoNy1dFVc0mOiOFJugI5QkYyecwV0o5klcsaCILB)uYufzCoXQh(EfiuPja0bjMXsuYufzCoXQh(EfiuPjaqKJSONkxYufzCoXQh(EfidHxNq0faZlrwgI5km0CAneEDcrxamVezTuKvdNm8gXyjtjtJ2OL)s47Cu(tLUJP8RImox(nPXrJCb5NhKuYufzCoXscFNJRgcVssASeLmvrgNtSKW3547vG46ifKReameZvyO50c4sqaQxTqMpESrkKJZJUJwtAWQCqUosbvrcP5rjwCiqHPjwzem0CAnPbRYb56ifufjKMhLyjPkwUnWTfjtvKX5elj8Do(EfitAWE0AOCqd6iKHyUcmWqZP1KgShTgkh0GocTqMsMQiJZjws47C89kqK8OSKKglrgI5kfYX5r3rB9owqdHxjwCiqHPjwzem0CAR3XcAi8kXczkzQImoNyjHVZX3RajOkbaip2bKE47meZvkKJZJUJ26DSGgcVsS4qGcttSYiyO50wVJf0q4vIfYuYufzCoXscFNJVxbkeiijPXsKHyUsHCCE0D0wVJf0q4vIfhcuyAIvgbdnN26DSGgcVsSqMsMQiJZjws47C89kqeiVI0W3ziMRuihNhDhT17ybneELyXHafMMyLrWqZPTEhlOHWRelKPKPkY4CILe(ohFVc0KRSiibWjwYqmxbMmeldFxYufzCoXscFNJVxbAesmrkyEjYkzQImoNyjHVZX3RanPhjbjaoXsgI5km0CAbObNKhL1czkzQImoNyjHVZX3RaHknbGoiXmwIsMQiJZjws47C89kqtfbtQ6KjejoxYufzCoXscFNJVxbsaqdhKh7asp8DgI5km0CAj5rzxIOjsTqMsMQiJZjws47C89kqihzrpvoimxjjdXCfgAoTSkYjj9ybnGQ55wsQILBVYyjtvKX5elj8Do(EfibanCqakDessgI5km0CAzvKts6XcAavZZTKufl3ELXmIQrfehHEA1ALydF71HXyjtvKX5elj8Do(EfiESdi9W3bHpEYqmxHHMtlRICsspwqdOAEULKQy56tJLmvrgNtSKW3547vGi5rzjjnwIsMQiJZjws47C89kqK8OSlr0ePmeZvyO50YQiNK0Jf0aQMNBjPkwU9kJLmvrgNtSKW3547vGMCKaqq1zYq4jsPqM56tgI5k5G4WHxTJoUMbhbjhFe6PKPkY4CILe(ohFVcexhPGCLaqYufzCoXscFNJVxbsqvcaqESdi9W3LmvrgNtSKW3547vGMCLfbjaoXsgeli4iyQ0DmjRpziMRuCsrcafMJsMQiJZjws47C89kqt6rsqcGtSuYufzCoXscFNJVxbkeiijPXsuYufzCoXscFNJVxbIa5vKg(odXCLQrfehHEA1ALydF71HZyjtvKX5elj8Do(EfOzqrq)gPmeZvvKXieSEPDYvweKa4elLmvrgNtSKW3547vG4XoG0dFhe(4jdXCfgAoTSkYjj9ybnGQ55wsQILBVYyjtvKX5elj8Do(EfOjhjaeuDMmeZvYbXHdVAnHijehbrkKzgNlzQImoNyjHVZX3RaHknbaICKf9u5sMQiJZjws47C89kqgcVoHOlaMxISmeZvyO50Ai86eIUayEjYAPiRgoz4nIXD2z3a]] )


end
