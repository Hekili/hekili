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

            nobuff = "doom_winds", -- Don't cast Windfury Totem while Doom Winds is already up, there's some weirdness with Windfury Totem's buff right now.

            handler = function ()
                applyBuff( "windfury_totem" )
                summonTotem( "windfury_totem", nil, 120 )

                if legendary.doom_winds.enabled and debuff.doom_winds_cd.down then
                    applyBuff( "doom_winds" )
                    applyDebuff( "player", "doom_winds_cd" )
                    applyDebuff( "player", "doom_winds_debuff" )
                    applyBuff( "doom_winds_cd" ) -- SimC weirdness.
                    applyBuff( "doom_winds_debuff" ) -- SimC weirdness.
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


    spec:RegisterPack( "Enhancement", 20210709, [[duuU6aqivH8ikuAtOq9jLIgLsHoLsbVcqMfk4wuOOSlk9laAysbhtv0YKs5zuOAAsPIRHczBaQ8nkenoafDoavToPuvZtkv5EkP9Pk4GQcvTqa8qaLCraL6JuOGtQkuwjfmtPuPBsHIQDkf9tvHklLcf6PsmvLWxPqrglfc7vXFbAWQQdtAXG6XeMSKUmYMLQpRunAvPtl8ALOzJQBJs7MQFRYWPOJtH0YH65qMUORdY2Ls(okA8akCEPqZxP0(j655SykvnPPzBn02ZgmYgaEBBn0Mr2WZPKnAstXufl1DAkUYstby7VQliwYZPyQnYpTolMc6GWcAkLGfynfyOGNpMpWtPQjnnBRH2E2Gr2aWBBRH2aogzKtbzsIPzBaNXNYBuRKpWtPsiXua2(R6cIL8u(lVkR6sdgG4nk)apdYFBn02ZPWduIMftbf(oNMftZNZIPOImoFkmdVIsCSKMc5kmNQdatonBBwmfYvyovhaMIahjHdDkWq9U99sWx1Rwit5F7w5FJYpgYP(H3jRjoyvoixBPGQiH08WilzuOW0KQYpJLFyOE3AIdwLdY1wkOksinpmYIsvSu(Fq(bo5FdtrfzC(u4AlfKRO3jNMgFwmfYvyovhaMIahjHdDkps(HH6DRjoypCnuoitTfzHmNIkY48PyId2dxdLdYuBrtonBNzXuixH5uDaykcCKeo0PGHCQF4DYwVJfKz4vKLmkuyAsv5NXYpmuVBR3XcYm8kYczofvKX5tbLhMfL4yjn50KrZIPqUcZP6aWue4ijCOtbd5u)W7KTEhliZWRilzuOW0KQYpJLFyOE3wVJfKz4vKfYCkQiJZNIaROxqES)ME47tonbUzXuixH5uDaykcCKeo0PGHCQF4DYwVJfKz4vKLmkuyAsv5NXYpmuVBR3XcYm8kYczofvKX5tjeeikXXsAYPProlMc5kmNQdatrGJKWHofmKt9dVt26DSGmdVISKrHcttQk)mw(HH6DB9owqMHxrwiZPOImoFkiiVs4W3NCAcmNftHCfMt1bGPiWrs4qNYJK)meldFFkQiJZNsNRSei69elNCAc8ZIPOImoFkTiKjHbZlj2PqUcZP6aWKtZNnmlMc5kmNQdatrGJKWHofyOE3(QbhLhM1czofvKX5tPJpucIEpXYjNMpFolMIkY48PqkoFjhezglPPqUcZP6aWKtZNTnlMc5kmNQdatrGJKWHoLhj)yiN6hENSiIQiWRdIvwt1tWD8XmFTKrHcttQk)B3k)I741JPB7ew5GiZahPftSA4i5)b5)jJMIkY48P0vcmXQJ6qO48jNMpn(SykKRWCQoamfbosch6uGH6Dlkpm7sImjSfYCkQiJZNI4vdhKh7VPh((KtZNTZSykKRWCQoamfbosch6uGH6DlRsCuIpwqMKAEUfLQyP8)WQ8ZOPOImoFkeNyjpvoimxr5KtZNmAwmfYvyovhaMIahjHdDkWq9ULvjokXhlitsnp3IsvSu(Fyv(zK8Zy5hRrfKArEA1Afzdx(Fyv(b(gMIkY48PiE1WbFvClcLtonFcCZIPqUcZP6aWue4ijCOtbgQ3TSkXrj(ybzsQ55wuQILY)Q8)SHPOImoFk8y)n9W3bHpEo508ProlMIkY48PGYdZIsCSKMc5kmNQdatonFcmNftHCfMt1bGPiWrs4qNcmuVBzvIJs8XcYKuZZTOuflL)hwLFgnfvKX5tbLhMDjrMeEYP5tGFwmfYvyovhaMIahjHdDkOdIdhE1264AgCceD8wKNwYvyovNIkY48P05e6vG1EoLWtcJHmZP8CYPzBnmlMIkY48PW1wkixrVtHCfMt1bGjNMT9CwmfvKX5trGv0lip2Ftp89PqUcZP6aWKtZ2ABwmfYvyovhaMIkY48P05klbIEpXYPiWrs4qNcM6yc9QWCAkIgfCcmv8oLOP5ZjNMTz8zXuurgNpLo(qji69elNc5kmNQdatonBRDMftrfzC(ucbbIsCSKMc5kmNQdatonBJrZIPqUcZP6aWue4ijCOtbRrfKArEA1Afzdx(Fyv(BNgMIkY48PGG8kHdFFYPzBa3SykKRWCQoamfbosch6uurgTiW6L2oxzjq07jwofvKX5tPhyc0Vw6KtZ2mYzXuixH5uDaykcCKeo0Pad17wwL4OeFSGmj18ClkvXs5)Hv5NrtrfzC(u4X(B6HVdcF8CYPzBaZzXuixH5uDaykcCKeo0PGoioC4vRjekH4eiHHmZ4Cl5kmNQtrfzC(u6Cc9kWApNCA2gWplMIkY48PqkoFbjoXsEQ8PqUcZP6aWKttJ3WSykKRWCQoamfbosch6uGH6DlZWRDiCJG5LeRftSA4i5V9KFJ3WuurgNpfMHx7q4gbZlj2jNCk6rZIP5ZzXuixH5uDaykcCKeo0Pad17wbwrVG8y)n9W3TqMtrfzC(uygEfL4yjn50STzXuixH5uDaykcCKeo0PGoioC4v7o(ArGH3k2pSMX5wYvyovL)TBLF0bXHdVA7bXRGxheMFi0XISKRWCQofvKX5tPReyIvh1HqX5tonn(SykKRWCQoamfbosch6uWqo1p8ozR3XcYm8kYsgfkmnPQ8Zy5hgQ3T17ybzgEfzHmNIkY48PiWk6fKh7VPh((KtZ2zwmfYvyovhaMIahjHdDkWq9U9vdokpmRfYCkQiJZNshFOee9EILtonz0SykQiJZNccYReo89PqUcZP6aWKttGBwmfYvyovhaMIkY48P05klbIEpXYPiWrs4qNcM6yc9QWCs(zS8Vr5pvo5PThyc0VwQLCfMtv5F7w5pvo5PLRO3W3b7CLLqwYvyovL)TBLFX1IC1tRtc8XpCv(3Uv(Xqo1p8oznXbRYb5AlfufjKMhgzjJcfMMuv(3Wuenk4eyQ4DkrtZNtonnYzXuixH5uDaykQiJZNIjoypCnuoitTfnfbosch6uEK8dd17wtCWE4AOCqMAlYczofrJcobMkENs0085KttG5SykKRWCQoamfbosch6uurgTiW6L2oxzjq07jwk)pSk)gFkQiJZNspWeOFT0jNMa)SykQiJZNslczsyW8sIDkKRWCQoam508zdZIPqUcZP6aWue4ijCOtbgQ3TM4G9W1q5Gm1wKfYu(zS8dd17wwL4OeFSGmj18ClkvXs5)Hv5NrtrfzC(u4X(B6HVdcF8CYP5ZNZIPqUcZP6aWue4ijCOtbgQ3TO8WSljYKWwiZPOImoFkIxnCqES)ME47tonF22SykKRWCQoamfbosch6usLtEAfyf9g(oikpmRLCfMtv5F7w5hgQ3TcSIEb5X(B6HVBRhtFkQiJZNIaROxqES)ME47tonFA8zXuixH5uDaykQiJZNcxBPGCf9ofbosch6usLtEA5k6n8DWoxzjKLCfMt1PiAuWjWuX7uIMMpNCA(SDMftHCfMt1bGPiWrs4qNcmuVBfyf9cYJ930dF3czk)mw(3O8dd1723lbFvVAHmL)TBL)nk)yiN6hENSM4Gv5GCTLcQIesZdJSKrHcttQk)mw(HH6DRjoyvoixBPGQiH08WilkvXs5)b5h4K)ni)BykQiJZNcxBPGCf9o508jJMftHCfMt1bGPiWrs4qNcmuVBfyf9cYJ930dF3czofvKX5tbLhMfL4yjn508jWnlMIkY48PiWk6fKh7VPh((uixH5uDayYP5tJCwmfYvyovhaMIahjHdDkWq9ULvjokXhlitsnp3IsvSu(Fyv(z0uurgNpfXRgo4RIBrOCYP5tG5SykKRWCQoamfbosch6uGH6DlRsCuIpwqMKAEUfLQyP8)WQ8ZOPOImoFkeNyjpvoimxr5KtZNa)SykKRWCQoamfbosch6uGH6DlRsCuIpwqMKAEUfLQyP8)WQ8ZOPOImoFkO8WSljYKWtonBRHzXuixH5uDaykcCKeo0Pad17wwL4OeFSGmj18ClkvXs5Fv(F2WuurgNpfXRgoip2Ftp89jNMT9CwmfvKX5tHz4vuIJL0uixH5uDayYPzBTnlMIkY48PGYdZIsCSKMc5kmNQdatonBZ4ZIPOImoFkCTLcYv07uixH5uDayYPzBTZSykKRWCQoamfbosch6uqheho8QT1X1m4ei64TipTKRWCQofvKX5tPZj0RaR9CkHNegdzMt55KtZ2y0SykKRWCQoamfvKX5tPZvwce9EILtrGJKWHofm1Xe6vH50uenk4eyQ4DkrtZNtonBd4MftrfzC(u6kbMy1rDiuC(uixH5uDayYPzBg5SykQiJZNshFOee9EILtHCfMt1bGjNMTbmNftrfzC(ucbbIsCSKMc5kmNQdatonBd4NftHCfMt1bGPiWrs4qNcmuVBzvIJs8XcYKuZZTOuflL)hwLFgnfvKX5tr8QHdYJ930dFFYPPXBywmfYvyovhaMIahjHdDkQiJwey9sBNRSei69elL)hK)NtrfzC(u6bMa9RLo5004pNftrfzC(uifNVKdImJL0uixH5uDayYPPXBBwmfvKX5tHuC(csCIL8u5tHCfMt1bGjNMg34ZIPqUcZP6aWue4ijCOtbgQ3TmdV2HWncMxsSwmXQHJK)2t(nEdtrfzC(uygETdHBemVKyNCYPuPUcXZzX085SykQiJZNcm)UkhcLtHCfMt1bEYPzBZIPqUcZP6aWue4ijCOtb(qi5NXYFp2FtqmXQHJK)2t(bUgMsLqcCyMX5t5XCJzIJfwt538Y4C5pqYpm1pmj)IJfwt5N8kYofvKX5tX8Y48jNMgFwmfYvyovhaMsLqcCyMX5t5X8KWyiZCkQiJZNcZWRGOxsXtonBNzXuurgNpLxsXjiHqKlOPqUcZP6aWKttgnlMIkY48PaHiWijw0uixH5uDayYPjWnlMc5kmNQdatrGJKWHoLhj)PYjpTksqEvDbzjxH5uv(3Uv(HH6DRIeKxvxqwit5F7w5xChVEmDRIeKxvxqwmXQHJK)hKFg1WuurgNpfy(DvWoeUXjNMg5SykKRWCQoamfbosch6uEK8NkN80Qib5v1fKLCfMtv5F7w5hgQ3TksqEvDbzHmNIkY48PatyeHxg((KttG5SykKRWCQoamfbosch6uEK8NkN80Qib5v1fKLCfMtv5F7w5hgQ3TksqEvDbzHmL)TBLFXD86X0TksqEvDbzXeRgos(Fq(zudtrfzC(u6bMG53vNCAc8ZIPqUcZP6aWue4ijCOt5rYFQCYtRIeKxvxqwYvyovL)TBLFyOE3Qib5v1fKfYu(3Uv(f3XRht3Qib5v1fKftSA4i5)b5NrnmfvKX5trDbHsSYbfkNp508zdZIPqUcZP6aWue4ijCOt5rYFQCYtRIeKxvxqwYvyovL)TBL)hj)Wq9UvrcYRQlilK5uurgNpfyDh86GjoelrtonF(CwmfvKX5tPtyLdImdCKtHCfMt1bGjNMpBBwmfYvyovhaMIahjHdDkBu(tLtEAvKG8Q6cYsUcZPQ8VDR8JHCQF4DYwVJfKz4vKLmkuyAsv5FdYpJL)nk)OdIdhE1UJVwey4TI9dRzCULCfMtv5F7w5hDqC4WR2Eq8k41bH5hcDSil5kmNQY)2TYVkYOfbsoXges(xL)NY)gMIkY48P0vcmXQJ6qO48jNMpn(SykKRWCQoamfbosch6uWAubPwKNwTwr2WL)hwLFGVb5F7w5xfz0IajNydcj)pi)pNIkY48POib5v1f0KtZNTZSykKRWCQoamfbosch6uWqo1p8ozR3XcYm8kYsgfkmnPQ8Zy5hgQ3T17ybzgEfbwjyOE3wpMU8Zy5FJYpwJki1I80Q1kYgU8)WQ8dCni)B3k)QiJwei5eBqi5)b5)P8Vb5F7w5hgQ3TmdV2HWncMxsS26X0LFgl)Bu(FK8JHCQF4DYwVJfKz4vKLmkuyAsv5F7w5hgQ3T17ybzgEfbwjyOE3czk)BykQiJZNcZWRDiCJG5Le7KtZNmAwmfYvyovhaMsLqcCyMX5t5X6Y)58gL)Zj5NCITrgKFtCC4iBu(7hNFmrYF(sY)MOW350MYVkY4C5NhO0ofvKX5trOCoOkY4CqEGYPiWrs4qNIkYOfbsoXges(xL)NtHhOe0vwAkOW350KtZNa3SykKRWCQoamLkHe4WmJZNYJZLFwiEgMCs(jNydcXG8NVK8BIJdhzJYF)48Jjs(Zxs(3upAt5xfzCU8ZduANIkY48PiuohufzCoipq5ue4ijCOtrfz0IajNydcj)pi)pNcpqjORS0u0JMCA(0iNftrfzC(uehKNegL4yjbMxsStHCfMt1bGjNMpbMZIPOImoFkOLn2HWncMxsStHCfMt1bGjNMpb(zXuurgNpftCWQCquIJL0uixH5uDayYjNIjMehlSMZIP5ZzXuixH5uDaykcCKeo0Pad17wMHx7q4gbzsQ55wmXQHJK)2t(nEdnmfvKX5tHz41oeUrqMKAE(KtZ2MftHCfMt1bGPiWrs4qNcmuVB7CLLYZ3HiqMKAEUftSA4i5V9KFJ3qdtrfzC(u6CLLYZ3HiqMKAE(KttJplMIkY48PaFzYPkyNRnsvMHVdMhWi8PqUcZP6aWKtZ2zwmfYvyovhaMIahjHdDkWq9ULh7VPh(oi6niE1IjwnCK83EYVXBOHPOImoFk8y)n9W3brVbXRtonz0SykKRWCQoamfbosch6usLtEAr5HzxsKjHTKRWCQofvKX5tbLhMDjrMeEYPjWnlMc5kmNQdatrGJKWHoLhj)yiN6hENS17ybzgEfzjJcfMMuv(zS8dd17wMHx7q4gbZljwB9y6trfzC(uygETdHBemVKyNCAAKZIPqUcZP6aWue4ijCOtbDqC4WRwtiucXjqcdzMX5wYvyovL)TBLF0bXHdVABDCndobIoElYtl5kmNQtrfzC(u6Cc9kWApNCAcmNftHCfMt1bGPiWrs4qNc8HqtrfzC(umVmoFYjNCkTimkoFA2wdT9SbJSHNtHPI9W3rtXy6XBm28XAAm0(YV8V4LK)G18WP83pS8VPE0MYpMmkuGPQ8Jows(vO8y1KQYV4v9DczLgA3Wj5VT2x(bwN3IWjvL)nrheho8Q1i2u(Zt(3eDqC4WRwJWsUcZP6MY)gFcm2GvAODdNK)2AF5hyDElcNuv(3eDqC4WRwJyt5pp5Ft0bXHdVAncl5kmNQBk)Ak)a7hx7k)B8jWydwPH2nCs(BRDAF5hyDElcNuv(3eDqC4WRwJyt5pp5Ft0bXHdVAncl5kmNQBk)Ak)a7hx7k)B8jWydwPbPbJPhVXyZhRPXq7l)Y)Ixs(dwZdNYF)WY)MOW350MYpMmkuGPQ8Jows(vO8y1KQYV4v9DczLgA3Wj5)jW3(YpW68weoPQ8Vj6G4WHxTgXMYFEY)MOdIdhE1AewYvyov3u(1u(b2pU2v(34tGXgSsdTB4K83gWS9LFG15TiCsv5Ft0bXHdVAnInL)8K)nrheho8Q1iSKRWCQUP8RP8dSFCTR8VXNaJnyLgKgmME8gJnFSMgdTV8l)lEj5pynpCk)9dl)BwPUcXZnLFmzuOatv5hDSK8Rq5XQjvLFXR67eYkn0UHtY)Z2AF5hyDElcNuv(3eDqC4WRwJyt5pp5Ft0bXHdVAncl5kmNQBk)BSnGXgSsdsdgtpEJXMpwtJH2x(L)fVK8hSMhoL)(HL)nnXK4yH1Ct5htgfkWuv(rhlj)kuESAsv5x8Q(oHSsdTB4K8BKTV8dSoVfHtQk)BIoioC4vRrSP8NN8Vj6G4WHxTgHLCfMt1nL)n(eySbR0q7goj)gz7l)aRZBr4KQY)MOdIdhE1AeBk)5j)BIoioC4vRryjxH5uDt5xt5hy)4Ax5FJpbgBWknin8ySMhoPQ83oYVkY4C5NhOezLgMIj(6bNMIXASYpW2FvxqSKNYF5vzvxAWynw53aeVr5h4zq(BRH2EkninOImohznXK4yH1CLz41oeUrqMKAEodrFfgQ3TmdV2HWncYKuZZTyIvdh1EgVHgKgurgNJSMysCSWAc0kGDUYs557qeitsnpNHOVcd172oxzP88DicKjPMNBXeRgoQ9mEdninOImohznXK4yH1eOvaHVm5ufSZ1gPkZW3bZdyeU0GkY4CK1etIJfwtGwbKh7VPh(oi6niELHOVcd17wES)ME47GO3G4vlMy1WrTNXBObPbvKX5iRjMehlSMaTcikpm7sImjmdrFnvo5PfLhMDjrMe2sUcZPQ0GkY4CK1etIJfwtGwbKz41oeUrW8sILHOV(imKt9dVt26DSGmdVISKrHcttQYyyOE3Ym8Ahc3iyEjXARhtxAqfzCoYAIjXXcRjqRa25e6vG1EYq0xrheho8Q1ecLqCcKWqMzC(2TOdIdhE1264AgCceD8wKNsdQiJZrwtmjowynbAfqZlJZzi6RWhcjninySgR8dSbgKakPQ8tTiCJYFgSK8NVK8RI8WYFGKFTLgCfMtwPbvKX5Ovy(DvoekLgmw5)XCJzIJfwt538Y4C5pqYpm1pmj)IJfwt5N8kYknOImohb0kGMxgNZq0xHpeIX9y)nbXeRgoQ9aUgKgmw5)X8KWyiZuAqfzCocOvazgEfe9skwAqfzCocOvaFjfNGecrUGKgurgNJaAfqiebgjXIKgurgNJaAfqy(DvWoeUrgI(6JsLtEAvKG8Q6cYsUcZP62TWq9UvrcYRQlilK52TI741JPBvKG8Q6cYIjwnC0dmQbPbvKX5iGwbeMWicVm8DgI(6JsLtEAvKG8Q6cYsUcZP62TWq9UvrcYRQlilKP0GkY4CeqRa2dmbZVRYq0xFuQCYtRIeKxvxqwYvyov3UfgQ3TksqEvDbzHm3UvChVEmDRIeKxvxqwmXQHJEGrninOImohb0kGQliuIvoOq5CgI(6JsLtEAvKG8Q6cYsUcZP62TWq9UvrcYRQlilK52TI741JPBvKG8Q6cYIjwnC0dmQbPbvKX5iGwbew3bVoyIdXsedrF9rPYjpTksqEvDbzjxH5uD72hbd17wfjiVQUGSqMsdQiJZraTcyNWkhezg4iLgurgNJaAfWUsGjwDuhcfNZq0x3yQCYtRIeKxvxqwYvyov3Ufd5u)W7KTEhliZWRilzuOW0KQBGXBeDqC4WR2D81IadVvSFynJZ3UfDqC4WR2Eq8k41bH5hcDSOTBvrgTiqYj2GqRp3G0GkY4CeqRaQib5v1fedrFfRrfKArEA1Afzd)HvGVHTBvrgTiqYj2Gqp8uAqfzCocOvazgETdHBemVKyzi6RyiN6hENS17ybzgEfzjJcfMMuLXWq9UTEhliZWRiWkbd1726X0z8gXAubPwKNwTwr2WFyf4Ay7wvKrlcKCIni0dp3W2TWq9ULz41oeUrW8sI1wpMoJ34JWqo1p8ozR3XcYm8kYsgfkmnP62TWq9UTEhliZWRiWkbd17wiZninySY)J1L)Z5nk)NtYp5eBJmi)M44Wr2O83po)yIK)8LK)nrHVZPnLFvKX5YppqPvAqfzCocOvafkNdQImohKhOKbxzPvu47CIHOVQImArGKtSbHwFknySY)JZLFwiEgMCs(jNydcXG8NVK8BIJdhzJYF)48Jjs(Zxs(3upAt5xfzCU8ZduALgurgNJaAfqHY5GQiJZb5bkzWvwAvpIHOVQImArGKtSbHE4P0GkY4CeqRakoipjmkXXscmVKyLgurgNJaAfq0Yg7q4gbZljwPbvKX5iGwb0ehSkheL4yjjninySgR8BmhINH8NkENs5xfzCU8BIJdhzJYppqP0GkY4CKvpALz4vuIJLedrFfgQ3TcSIEb5X(B6HVBHmLgurgNJS6raTcyxjWeRoQdHIZzi6ROdIdhE1UJVwey4TI9dRzC(2TOdIdhE12dIxbVoim)qOJfjnOImohz1JaAfqbwrVG8y)n9W3zi6RyiN6hENS17ybzgEfzjJcfMMuLXWq9UTEhliZWRilKP0GkY4CKvpcOva74dLGO3tSKHOVcd172xn4O8WSwitPbvKX5iREeqRaIG8kHdFxAqfzCoYQhb0kGDUYsGO3tSKbrJcobMkENs06tgI(kM6yc9QWCIXBmvo5PThyc0VwQLCfMt1TBtLtEA5k6n8DWoxzjKLCfMt1TBfxlYvpTojWh)W1TBXqo1p8oznXbRYb5AlfufjKMhgzjJcfMMuDdsdQiJZrw9iGwb0ehShUgkhKP2Iyq0OGtGPI3PeT(KHOV(iyOE3AId2dxdLdYuBrwitPbvKX5iREeqRa2dmb6xlLHOVQImArG1lTDUYsGO3tS8HvJlnOImohz1JaAfWweYKWG5LeR0GkY4CKvpcOva5X(B6HVdcF8KHOVcd17wtCWE4AOCqMAlYczYyyOE3YQehL4JfKjPMNBrPkw(WkJKgurgNJS6raTcO4vdhKh7VPh(odrFfgQ3TO8WSljYKWwitPbvKX5iREeqRakWk6fKh7VPh(odrFnvo5PvGv0B47GO8WSwYvyov3UfgQ3TcSIEb5X(B6HVBRhtxAqfzCoYQhb0kGCTLcYv0ldIgfCcmv8oLO1Nme91u5KNwUIEdFhSZvwczjxH5uvAqfzCoYQhb0kGCTLcYv0ldrFfgQ3TcSIEb5X(B6HVBHmz8gHH6D77LGVQxTqMB3UrmKt9dVtwtCWQCqU2sbvrcP5HrwYOqHPjvzmmuVBnXbRYb5AlfufjKMhgzrPkw(aWTHninOImohz1JaAfquEywuIJLedrFfgQ3TcSIEb5X(B6HVBHmLgurgNJS6raTcOaROxqES)ME47sdQiJZrw9iGwbu8QHd(Q4wekzi6RWq9ULvjokXhlitsnp3IsvS8HvgjnOImohz1JaAfqItSKNkheMROKHOVcd17wwL4OeFSGmj18ClkvXYhwzK0GkY4CKvpcOvar5HzxsKjHzi6RWq9ULvjokXhlitsnp3IsvS8HvgjnOImohz1JaAfqXRgoip2Ftp8DgI(kmuVBzvIJs8XcYKuZZTOuflxF2G0GkY4CKvpcOvazgEfL4yjjnOImohz1JaAfquEywuIJLK0GkY4CKvpcOva5AlfKROxPbvKX5iREeqRa25e6vG1EYq4jHXqM56tgI(k6G4WHxTToUMbNarhVf5P0GkY4CKvpcOva7CLLarVNyjdIgfCcmv8oLO1Nme9vm1Xe6vH5K0GkY4CKvpcOva7kbMy1rDiuCU0GkY4CKvpcOva74dLGO3tSuAqfzCoYQhb0kGHGarjowssdQiJZrw9iGwbu8QHdYJ930dFNHOVcd17wwL4OeFSGmj18ClkvXYhwzK0GkY4CKvpcOva7bMa9RLYq0xvrgTiW6L2oxzjq07jw(WtPbvKX5iREeqRaskoFjhezgljPbvKX5iREeqRaskoFbjoXsEQCPbvKX5iREeqRaYm8Ahc3iyEjXYq0xHH6DlZWRDiCJG5LeRftSA4O2Z4nininySgR8xcFNtYFQ4DkLFvKX5YVjooCKnk)8aLsdQiJZrwu47CALz4vuIJLK0GkY4CKff(oNaAfqU2sb5k6LHOVcd1723lbFvVAHm3UDJyiN6hENSM4Gv5GCTLcQIesZdJSKrHcttQYyyOE3AIdwLdY1wkOksinpmYIsvS8bGBdsdQiJZrwu47CcOvanXb7HRHYbzQTigI(6JGH6DRjoypCnuoitTfzHmLgurgNJSOW35eqRaIYdZIsCSKyi6RyiN6hENS17ybzgEfzjJcfMMuLXWq9UTEhliZWRilKP0GkY4CKff(oNaAfqbwrVG8y)n9W3zi6RyiN6hENS17ybzgEfzjJcfMMuLXWq9UTEhliZWRilKP0GkY4CKff(oNaAfWqqGOehljgI(kgYP(H3jB9owqMHxrwYOqHPjvzmmuVBR3XcYm8kYczknOImohzrHVZjGwbeb5vch(odrFfd5u)W7KTEhliZWRilzuOW0KQmggQ3T17ybzgEfzHmLgurgNJSOW35eqRa25klbIEpXsgI(6JYqSm8DPbvKX5ilk8Dob0kGTiKjHbZljwPbvKX5ilk8Dob0kGD8Hsq07jwYq0xHH6D7RgCuEywlKP0GkY4CKff(oNaAfqsX5l5GiZyjjnOImohzrHVZjGwbSReyIvh1HqX5me91hHHCQF4DYIiQIaVoiwznvpb3XhZ81sgfkmnP62TI741JPB7ew5GiZahPftSA4OhEYiPbvKX5ilk8Dob0kGIxnCqES)ME47me9vyOE3IYdZUKitcBHmLgurgNJSOW35eqRasCIL8u5GWCfLme9vyOE3YQehL4JfKjPMNBrPkw(WkJKgurgNJSOW35eqRakE1WbFvClcLme9vyOE3YQehL4JfKjPMNBrPkw(WkJymwJki1I80Q1kYg(dRaFdsdQiJZrwu47CcOva5X(B6HVdcF8KHOVcd17wwL4OeFSGmj18ClkvXY1NninOImohzrHVZjGwbeLhMfL4yjjnOImohzrHVZjGwbeLhMDjrMeMHOVcd17wwL4OeFSGmj18ClkvXYhwzK0GkY4CKff(oNaAfWoNqVcS2tgcpjmgYmxFYq0xrheho8QT1X1m4ei64TipLgurgNJSOW35eqRaY1wkixrVsdQiJZrwu47CcOvafyf9cYJ930dFxAqfzCoYIcFNtaTcyNRSei69elzq0OGtGPI3PeT(KHOVIPoMqVkmNKgurgNJSOW35eqRa2XhkbrVNyP0GkY4CKff(oNaAfWqqGOehljPbvKX5ilk8Dob0kGiiVs4W3zi6RynQGulYtRwRiB4pS2oninOImohzrHVZjGwbShyc0VwkdrFvfz0IaRxA7CLLarVNyP0GkY4CKff(oNaAfqES)ME47GWhpzi6RWq9ULvjokXhlitsnp3IsvS8HvgjnOImohzrHVZjGwbSZj0RaR9KHOVIoioC4vRjekH4eiHHmZ4CPbvKX5ilk8Dob0kGKIZxqItSKNkxAqfzCoYIcFNtaTciZWRDiCJG5LeldrFfgQ3TmdV2HWncMxsSwmXQHJApJ3WuuO89WtPeSaRjNCga]] )


end
