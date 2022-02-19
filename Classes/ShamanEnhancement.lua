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
            tick_time = function () return 2 * haste end,
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


    local TriggerFeralMaelstrom = setfenv( function()
        addStack( "maelstrom_weapon", nil, 1 )
    end, state )


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

        if buff.feral_spirit.up then
            local next_mw = query_time + 3 - ( ( query_time - buff.feral_spirit.applied ) % 3 )

            while ( next_mw <= buff.feral_spirit.expires ) do
                state:QueueAuraEvent( "feral_maelstrom", TriggerFeralMaelstrom, next_mw, "AURA_PERIODIC" )
                next_mw = next_mw + 3
            end
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


    -- Tier 28
    spec:RegisterSetBonuses( "tier28_2pc", 364473, "tier28_4pc", 363668 )
    -- 2-Set - Stormspirit - Spending Maelstrom Weapon has a 3% chance per stack to summon a Feral Spirit for 9 sec.
    -- 4-Set - Stormspirit - Your Feral Spirits' attacks have a 20% chance to trigger Stormbringer, resetting the cooldown of your Stormstrike.
    -- 2/15/22:  No mechanics require actual modeling; nothing can be predicted.


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

                if azerite.natural_harmony.enabled and buff.frostbrand_weapon.up then applyBuff( "natural_harmony_frost" ) end
                if azerite.natural_harmony.enabled and buff.flametongue_weapon.up then applyBuff( "natural_harmony_fire" ) end
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

                addStack( "maelstrom_weapon", nil, 1 )
                state:QueueAuraEvent( "feral_maelstrom", TriggerFeralMaelstrom, query_time + 3, "AURA_PERIODIC" )
                state:QueueAuraEvent( "feral_maelstrom", TriggerFeralMaelstrom, query_time + 6, "AURA_PERIODIC" )
                state:QueueAuraEvent( "feral_maelstrom", TriggerFeralMaelstrom, query_time + 9, "AURA_PERIODIC" )
                state:QueueAuraEvent( "feral_maelstrom", TriggerFeralMaelstrom, query_time + 12, "AURA_PERIODIC" )
                state:QueueAuraEvent( "feral_maelstrom", TriggerFeralMaelstrom, query_time + 15, "AURA_PERIODIC" )
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
            gcd = "totem",

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


    spec:RegisterPack( "Enhancement", 20211207, [[duu66aqiLk5ruqAtOq9jLkgLsHoLsbVcqMfG6wuqu2fL(fanmPihtPQLjf1ZOaMMuQ01qbTnui(gfunouGCokOSoPuL5PuPCpL0(uk6GkvQAHa4HOa6IOa1hPGGtkLQALuOzkLkUjfev7uk8tLkvwkfe6PsmvLWxPGiJffs7vXFbAWQQdtAXG6XeMSKUmYMLQpRkgTQ0PP61krZgv3gL2TWVvz4u0XPaTCOEoKPl66GSDPKVJIgpkaNxkL5RuA)e9SFwmLQM00O5MAE)(MBYWTnBGMzytgykzBM0umvXs9HMsOS0uyWXRgcILICkMAB8tRZIPGoiSGMsXzzGtbgY5z7hd8uQAstJMBQ597BUjd32SbAMHtbzsIPrZmIbMYRxRumWtPsiXuyWXRgcILIu(lVkRgsJnUwelmHL)9gay5V5MAE)u4okrZIPG84HtZIPX(zXuur6xmfMEurj2xstHcfMt1bGjNgnplMcfkmNQdatrG9KWUofyOE3(Ej4RgvlKP8VDR8Vr5hdfu)WpK1e7SkhKRTuqvKqAEyKLmiKBAsv5NXYpmuVBnXoRYb5AlfufjKMhgzrPkwk)Bk)mI8VHPOI0VykCTLcYv07KtddmlMcfkmNQdatrG9KWUoLDj)Wq9U1e7ShU6khKP2ISqMtrfPFXumXo7HRUYbzQTOjNgT7SykuOWCQoamfb2tc76uWqb1p8dzR3XcY0JkYsgeYnnPQ8Zy5hgQ3T17ybz6rfzHmNIks)IPGYdZIsSVKMCAWWzXuOqH5uDaykcSNe21PGHcQF4hYwVJfKPhvKLmiKBAsv5NXYpmuVBR3XcY0JkYczofvK(ftrGv0li3FEZWJNjNgmYSykuOWCQoamfb2tc76uWqb1p8dzR3XcY0JkYsgeYnnPQ8Zy5hgQ3T17ybz6rfzHmNIks)IP4cceLyFjn50WWNftHcfMt1bGPiWEsyxNcgkO(HFiB9owqMEurwYGqUPjvLFgl)Wq9UTEhlitpQilK5uur6xmfeuujShptonyqZIPqHcZP6aWueypjSRtzxYF6ILE8mfvK(ftPZvwce9EILtonmSzXuur6xmLweYKWG5Le7uOqH5uDayYPX(MMftHcfMt1bGPiWEsyxNcmuVBFvNJYdZAHmNIks)IP0XhkbrVNy5KtJ97NftrfPFXuifNVuaIm9L0uOqH5uDayYPX(MNftHcfMt1bGPiWEsyxNYUKFmuq9d)qwerve41bXkRPgj4d(yMVwYGqUPjvL)TBLFXD86XmSDcRCqKPJ90Ijw1dK8VP8VNHtrfPFXu6kbMynqDiKFXKtJ9gywmfkuyovhaMIa7jHDDkWq9UfLhMDjrMe2czofvK(ftr8QEaY9N3m84zYPX(2DwmfkuyovhaMIa7jHDDkWq9ULvjokXhlitsnVWIsvSu(3Cv(z4uur6xmfItSuKkheMROCYPXEgolMcfkmNQdatrG9KWUofyOE3YQehL4JfKjPMxyrPkwk)BUk)mu(zS8JvVcsTOiTATISEi)BUk)gwttrfPFXueVQhGVkUfHYjNg7zKzXuOqH5uDaykcSNe21Pad17wwL4OeFSGmj18clkvXs5Fv(330uur6xmfU)8MHhpGWhpNCAS3WNftrfPFXuq5Hzrj2xstHcfMt1bGjNg7zqZIPqHcZP6aWueypjSRtbgQ3TSkXrj(ybzsQ5fwuQILY)MRYpdNIks)IPGYdZUKitcp50yVHnlMcfkmNQdatrG9KWUof0bXH9OABDCnDobIoElkslfkmNQtrfPFXu6Cc9kWApNIhjHXqM5u2p50O5MMftrfPFXu4AlfKRO3PqHcZP6aWKtJM3plMIks)IPiWk6fK7pVz4XZuOqH5uDayYPrZnplMcfkmNQdatrfPFXu6CLLarVNy5ueypjSRtbtDmHEvyonfrBcobMk(Hs00y)KtJMnWSykQi9lMshFOee9EILtHcfMt1bGjNgn3UZIPOI0VykUGarj2xstHcfMt1bGjNgnZWzXuOqH5uDaykcSNe21PGvVcsTOiTATISEi)BUk)TBttrfPFXuqqrLWE8m50OzgzwmfkuyovhaMIa7jHDDkQi9wey9sBNRSei69elNIks)IP0DmbgxlDYPrZg(SykuOWCQoamfb2tc76uGH6DlRsCuIpwqMKAEHfLQyP8V5Q8ZWPOI0VykC)5ndpEaHpEo50Ozg0SykuOWCQoamfb2tc76uqheh2JQ1ecLqCcKWqMPFHLcfMt1POI0VykDoHEfyTNtonA2WMftrfPFXuifNVGeNyPiv(uOqH5uDayYPHbAAwmfkuyovhaMIa7jHDDkWq9ULPh1oeUnW8sI1Ijw1dK8VBYVbAAkQi9lMctpQDiCBG5Le7Ktof9OzX0y)SykuOWCQoamfb2tc76uGH6DRaROxqU)8MHhpwiZPOI0Vykm9OIsSVKMCA08SykuOWCQoamfb2tc76uqheh2JQ9bFTiqpA5phwt)clfkmNQY)2TYp6G4WEuTDN4vWRdcZpe6yrwkuyovNIks)IP0vcmXAG6qi)IjNggywmfkuyovhaMIa7jHDDkyOG6h(HS17ybz6rfzjdc5MMuv(zS8dd1726DSGm9OISqMtrfPFXueyf9cY9N3m84zYPr7olMcfkmNQdatrG9KWUofyOE3(QohLhM1czofvK(ftPJpucIEpXYjNgmCwmfvK(ftbbfvc7XZuOqH5uDayYPbJmlMcfkmNQdatrfPFXu6CLLarVNy5ueypjSRtbtDmHEvyoj)mw(3O8NkNI02Dmbgxl1sHcZPQ8VDR8NkNI0Yv0RhpGDUYsilfkmNQY)2TYV4ArHgPnib(4hUk)B3k)yOG6h(HSMyNv5GCTLcQIesZdJSKbHCttQk)BykI2eCcmv8dLOPX(jNgg(SykuOWCQoamfvK(ftXe7ShU6khKP2IMIa7jHDDk7s(HH6DRj2zpC1voitTfzHmNIOnbNatf)qjAASFYPbdAwmfkuyovhaMIa7jHDDkQi9wey9sBNRSei69elL)nxLFdmfvK(ftP7ycmUw6KtddBwmfvK(ftPfHmjmyEjXofkuyovhaMCASVPzXuOqH5uDaykcSNe21Pad17wtSZE4QRCqMAlYczk)mw(HH6DlRsCuIpwqMKAEHfLQyP8V5Q8ZWPOI0VykC)5ndpEaHpEo50y)(zXuOqH5uDaykcSNe21Pad17wuEy2LezsylK5uur6xmfXR6bi3FEZWJNjNg7BEwmfkuyovhaMIa7jHDDkPYPiTcSIE94beLhM1sHcZPQ8VDR8dd17wbwrVGC)5ndpES1JzmfvK(ftrGv0li3FEZWJNjNg7nWSykuOWCQoamfvK(ftHRTuqUIENIa7jHDDkPYPiTCf96XdyNRSeYsHcZP6ueTj4eyQ4hkrtJ9ton23UZIPqHcZP6aWueypjSRtbgQ3TcSIEb5(ZBgE8yHmLFgl)Bu(HH6D77LGVAuTqMY)2TY)gLFmuq9d)qwtSZQCqU2sbvrcP5HrwYGqUPjvLFgl)Wq9U1e7SkhKRTuqvKqAEyKfLQyP8VP8ZiY)gK)nmfvK(ftHRTuqUIENCASNHZIPqHcZP6aWueypjSRtbgQ3TcSIEb5(ZBgE8yHmNIks)IPGYdZIsSVKMCASNrMftrfPFXueyf9cY9N3m84zkuOWCQoam50yVHplMcfkmNQdatrG9KWUofyOE3YQehL4JfKjPMxyrPkwk)BUk)mCkQi9lMI4v9a8vXTiuo50ypdAwmfkuyovhaMIa7jHDDkWq9ULvjokXhlitsnVWIsvSu(3Cv(z4uur6xmfItSuKkheMROCYPXEdBwmfkuyovhaMIa7jHDDkWq9ULvjokXhlitsnVWIsvSu(3Cv(z4uur6xmfuEy2Lezs4jNgn30SykuOWCQoamfb2tc76uGH6DlRsCuIpwqMKAEHfLQyP8Vk)7BAkQi9lMI4v9aK7pVz4XZKtJM3plMIks)IPW0JkkX(sAkuOWCQoam50O5MNftrfPFXuq5Hzrj2xstHcfMt1bGjNgnBGzXuur6xmfU2sb5k6DkuOWCQoam50O52DwmfkuyovhaMIa7jHDDkOdId7r1264A6CceD8wuKwkuyovNIks)IP05e6vG1EofpscJHmZPSFYPrZmCwmfkuyovhaMIks)IP05klbIEpXYPiWEsyxNcM6yc9QWCAkI2eCcmv8dLOPX(jNgnZiZIPOI0VykDLatSgOoeYVykuOWCQoam50OzdFwmfvK(ftPJpucIEpXYPqHcZP6aWKtJMzqZIPOI0VykUGarj2xstHcfMt1bGjNgnByZIPqHcZP6aWueypjSRtbgQ3TSkXrj(ybzsQ5fwuQILY)MRYpdNIks)IPiEvpa5(ZBgE8m50WannlMcfkmNQdatrG9KWUofvKElcSEPTZvwce9EILY)MY)(POI0VykDhtGX1sNCAyG9ZIPOI0VykKIZxkarM(sAkuOWCQoam50WanplMIks)IPqkoFbjoXsrQ8PqHcZP6aWKtddyGzXuOqH5uDaykcSNe21Pad17wMEu7q42aZljwlMyvpqY)Uj)gOPPOI0Vykm9O2HWTbMxsSto5uQuxH45SyASFwmfvK(ftbMFxLdHYPqHcZP6ap50O5zXuOqH5uDaykcSNe21PaFiK8Zy5V7pVjiMyvpqY)Uj)msttPsib2nt)IP0(HHmXXcRP8BEPFH87i5hM6hMKFXXcRP8trfzNIks)IPyEPFXKtddmlMcfkmNQdatPsib2nt)IP0(rsymKzofvK(ftHPhvq0lP4jNgT7SykQi9lMYlP4eKqike0uOqH5uDayYPbdNftrfPFXuGqeONelAkuOWCQoam50GrMftHcfMt1bGPiWEsyxNYUK)u5uKwfjOOQHGSuOWCQk)B3k)Wq9UvrckQAiilKP8VDR8lUJxpMHvrckQAiilMyvpqY)MYpdBAkQi9lMcm)Ukyhc32KtddFwmfkuyovhaMIa7jHDDk7s(tLtrAvKGIQgcYsHcZPQ8VDR8dd17wfjOOQHGSqMtrfPFXuGjmIWl94zYPbdAwmfkuyovhaMIa7jHDDk7s(tLtrAvKGIQgcYsHcZPQ8VDR8dd17wfjOOQHGSqMY)2TYV4oE9ygwfjOOQHGSyIv9aj)Bk)mSPPOI0VykDhtW87QtonmSzXuOqH5uDaykcSNe21PSl5pvofPvrckQAiilfkmNQY)2TYpmuVBvKGIQgcYczk)B3k)I741JzyvKGIQgcYIjw1dK8VP8ZWMMIks)IPOHGqjw5GcLZNCASVPzXuOqH5uDaykcSNe21PSl5pvofPvrckQAiilfkmNQY)2TY)UKFyOE3QibfvneKfYCkQi9lMcS(aEDWe7ILOjNg73plMIks)IP0jSYbrMo2ZPqHcZP6aWKtJ9nplMcfkmNQdatrG9KWUoLnk)PYPiTksqrvdbzPqH5uv(3Uv(Xqb1p8dzR3XcY0JkYsgeYnnPQ8Vb5NXY)gLF0bXH9OAFWxlc0Jw(ZH10VWsHcZPQ8VDR8JoioShvB3jEf86GW8dHowKLcfMtv5F7w5xfP3IaPGyDcj)RY)E5FdtrfPFXu6kbMynqDiKFXKtJ9gywmfkuyovhaMIa7jHDDky1RGulksRwRiRhY)MRYVH1K8VDR8RI0BrGuqSoHK)nL)9trfPFXuuKGIQgcAYPX(2DwmfkuyovhaMIa7jHDDkyOG6h(HS17ybz6rfzjdc5MMuv(zS8dd1726DSGm9OIaRemuVBRhZq(zS8Vr5hREfKArrA1Afz9q(3Cv(zKMK)TBLFvKElcKcI1jK8VP8Vx(3G8VDR8dd17wMEu7q42aZljwB9ygYpJL)nk)7s(Xqb1p8dzR3XcY0JkYsgeYnnPQ8VDR8dd1726DSGm9OIaRemuVBHmL)nmfvK(ftHPh1oeUnW8sIDYPXEgolMcfkmNQdatPsib2nt)IP0(D5)cEBY)fK8tbX2gWYVj2pSNTj)9JZpMi5pFj5FhKhpCAh5xfPFH8ZDuANIks)IPiuohufPFbi3r5uqj2f50y)ueypjSRtrfP3IaPGyDcj)RY)(PWDucgklnfKhpCAYPXEgzwmfkuyovhaMsLqcSBM(ftz3fYplepDtoj)uqSoHaw(Zxs(nX(H9Sn5VFC(Xej)5lj)7OhTJ8RI0Vq(5okTtrfPFXuekNdQI0VaK7OCkOe7ICASFkcSNe21POI0BrGuqSoHK)nL)9tH7OemuwAk6rton2B4ZIPOI0VykIdkscJsSVKaZlj2PqHcZP6aWKtJ9mOzXuur6xmf0Y26q42aZlj2PqHcZP6aWKtJ9g2SykQi9lMIj2zvoikX(sAkuOWCQoam5KtXetIJfwZzX0y)SykuOWCQoamfb2tc76uGH6DltpQDiCBGmj18clMyvpqY)Uj)gOPMMIks)IPW0JAhc3gitsnVyYPrZZIPqHcZP6aWueypjSRtbgQ3TDUYs5fpqeitsnVWIjw1dK8VBYVbAQPPOI0VykDUYs5fpqeitsnVyYPHbMftrfPFXuGVm5ufSZ12OktpEaZJb4XuOqH5uDayYPr7olMcfkmNQdatrG9KWUofyOE3Y9N3m84be96eVAXeR6bs(3n53an10uur6xmfU)8MHhpGOxN41jNgmCwmfkuyovhaMIa7jHDDkPYPiTO8WSljYKWwkuyovNIks)IPGYdZUKitcp50GrMftHcfMt1bGPiWEsyxNYUKFmuq9d)q26DSGm9OISKbHCttQk)mw(HH6DltpQDiCBG5LeRTEmJPOI0Vykm9O2HWTbMxsStonm8zXuOqH5uDaykcSNe21PGoioShvRjekH4eiHHmt)clfkmNQY)2TYp6G4WEuTToUMoNarhVffPLcfMt1POI0VykDoHEfyTNtonyqZIPqHcZP6aWueypjSRtb(qOPOI0VykMx6xm5KtoLweg5xmnAUPM33KH3KHnfMko84bnfdPDVHyJ2VHHq7j)Y)Ixs(DwZdNYF)WY)o6r7i)yYGqoMQYp6yj5xHYJvtQk)IxnEiKvASD8GK)MBp5NbErlcNuv(3bDqCypQwgDh5pp5Fh0bXH9OAzulfkmNQ7i)BCpdydwPX2Xds(BU9KFg4fTiCsv5Fh0bXH9OAz0DK)8K)Dqheh2JQLrTuOWCQUJ8RP8ZG3DTJ8VX9mGnyLgBhpi5V52T9KFg4fTiCsv5Fh0bXH9OAz0DK)8K)Dqheh2JQLrTuOWCQUJ8RP8ZG3DTJ8VX9mGnyLgLgnK29gInA)ggcTN8l)lEj53znpCk)9dl)7G84Ht7i)yYGqoMQYp6yj5xHYJvtQk)IxnEiKvASD8GK)9gw7j)mWlAr4KQY)oOdId7r1YO7i)5j)7GoioShvlJAPqH5uDh5xt5NbV7Ah5FJ7zaBWkn2oEqYFZmO2t(zGx0IWjvL)Dqheh2JQLr3r(Zt(3bDqCypQwg1sHcZP6oYVMYpdE31oY)g3Za2GvAuA0qA3Bi2O9Byi0EYV8V4LKFN18WP83pS8VtL6kep3r(XKbHCmvLF0XsYVcLhRMuv(fVA8qiR0y74bj)7BU9KFg4fTiCsv5Fh0bXH9OAz0DK)8K)Dqheh2JQLrTuOWCQUJ8VXMzaBWknknAiT7neB0(nmeAp5x(x8sYVZAE4u(7hw(3XetIJfwZDKFmzqihtv5hDSK8Rq5XQjvLFXRgpeYkn2oEqYVH3EYpd8IweoPQ8Vd6G4WEuTm6oYFEY)oOdId7r1YOwkuyov3r(34EgWgSsJTJhK8B4TN8ZaVOfHtQk)7GoioShvlJUJ8NN8Vd6G4WEuTmQLcfMt1DKFnLFg8URDK)nUNbSbR0O0y7ZAE4KQYF7k)Qi9lKFUJsKvACkku(E4PuCwg4umXx350umudv(zWXRgcILIu(lVkRgsJgQHk)nUwelmHL)9gay5V5MAEV0O0Oks)cK1etIJfwZvMEu7q42azsQ5fa79vyOE3Y0JAhc3gitsnVWIjw1d0UzGMAsAufPFbYAIjXXcRjqRa25klLx8arGmj18cG9(kmuVB7CLLYlEGiqMKAEHftSQhODZan1K0Oks)cK1etIJfwtGwbe(YKtvWoxBJQm94bmpgGhsJQi9lqwtmjowynbAfqU)8MHhpGOxN4vG9(kmuVB5(ZBgE8aIEDIxTyIv9aTBgOPMKgvr6xGSMysCSWAc0kGO8WSljYKWa791u5uKwuEy2LezsylfkmNQsJQi9lqwtmjowynbAfqMEu7q42aZljwG9(6UWqb1p8dzR3XcY0JkYsgeYnnPkJHH6DltpQDiCBG5LeRTEmdPrvK(fiRjMehlSMaTcyNtOxbw7jWEFfDqCypQwtiucXjqcdzM(fB3IoioShvBRJRPZjq0XBrrknQI0VaznXK4yH1eOvanV0VayVVcFiK0O0OHAOYpdMbqcOKQYp1IWTj)PZsYF(sYVkYdl)os(1wQZvyozLgvr6xGwH53v5qOuA0qL)2pmKjowynLFZl9lKFhj)Wu)WK8lowynLFkQiR0Oks)ceqRaAEPFbWEFf(qig39N3eetSQhODJrAsA0qL)2pscJHmtPrvK(fiGwbKPhvq0lPyPrvK(fiGwb8LuCcsiefcsAufPFbcOvaHqeONelsAufPFbcOvaH53vb7q42a27R7kvofPvrckQAiilfkmNQB3cd17wfjOOQHGSqMB3kUJxpMHvrckQAiilMyvpqBYWMKgvr6xGaAfqycJi8spEa27R7kvofPvrckQAiilfkmNQB3cd17wfjOOQHGSqMsJQi9lqaTcy3Xem)UkWEFDxPYPiTksqrvdbzPqH5uD7wyOE3QibfvneKfYC7wXD86XmSksqrvdbzXeR6bAtg2K0Oks)ceqRaQHGqjw5GcLZb27R7kvofPvrckQAiilfkmNQB3cd17wfjOOQHGSqMB3kUJxpMHvrckQAiilMyvpqBYWMKgvr6xGaAfqy9b86Gj2flra791DLkNI0QibfvneKLcfMt1TB3fmuVBvKGIQgcYczknQI0Vab0kGDcRCqKPJ9uAufPFbcOva7kbMynqDiKFbWEFDJPYPiTksqrvdbzPqH5uD7wmuq9d)q26DSGm9OISKbHCttQUbgVr0bXH9OAFWxlc0Jw(ZH10Vy7w0bXH9OA7oXRGxheMFi0XI2UvfP3IaPGyDcTUFdsJQi9lqaTcOIeuu1qqa79vS6vqQffPvRvK1JnxnSM2UvfP3IaPGyDcT5EPrvK(fiGwbKPh1oeUnW8sIfyVVIHcQF4hYwVJfKPhvKLmiKBAsvgdd1726DSGm9OIaRemuVBRhZGXBeREfKArrA1Afz9yZvgPPTBvr6TiqkiwNqBUFdB3cd17wMEu7q42aZljwB9ygmEJ7cdfu)WpKTEhlitpQilzqi30KQB3cd1726DSGm9OIaRemuVBHm3G0OHk)TFx(VG3M8Fbj)uqSTbS8BI9d7zBYF)48Jjs(Zxs(3b5XdN2r(vr6xi)ChLwPrvK(fiGwbuOCoOks)cqUJsGdLLwrE8WjGrj2f56EG9(QksVfbsbX6eADV0OHk)7Uq(zH4PBYj5NcI1jeWYF(sYVj2pSNTj)9JZpMi5pFj5Fh9ODKFvK(fYp3rPvAufPFbcOvafkNdQI0VaK7Oe4qzPv9iGrj2f56EG9(QksVfbsbX6eAZ9sJQi9lqaTcO4GIKWOe7ljW8sIvAufPFbcOvarlBRdHBdmVKyLgvr6xGaAfqtSZQCquI9LK0O0OHAOYVHCiE6YFQ4hkLFvK(fYVj2pSNTj)ChLsJQi9lqw9OvMEurj2xsa79vyOE3kWk6fK7pVz4XJfYuAufPFbYQhb0kGDLatSgOoeYVayVVIoioShv7d(ArGE0YFoSM(fB3IoioShvB3jEf86GW8dHowK0Oks)cKvpcOvafyf9cY9N3m84byVVIHcQF4hYwVJfKPhvKLmiKBAsvgdd1726DSGm9OISqMsJQi9lqw9iGwbSJpucIEpXsG9(kmuVBFvNJYdZAHmLgvr6xGS6raTcickQe2JhPrvK(fiREeqRa25klbIEpXsGfTj4eyQ4hkrR7b27RyQJj0RcZjgVXu5uK2UJjW4APwkuyov3UnvofPLROxpEa7CLLqwkuyov3UvCTOqJ0gKaF8dx3Ufdfu)WpK1e7SkhKRTuqvKqAEyKLmiKBAs1ninQI0Vaz1JaAfqtSZE4QRCqMAlcyrBcobMk(Hs06EG9(6UGH6DRj2zpC1voitTfzHmLgvr6xGS6raTcy3XeyCTuG9(QksVfbwV025klbIEpXYnxnG0Oks)cKvpcOvaBritcdMxsSsJQi9lqw9iGwbK7pVz4Xdi8XtG9(kmuVBnXo7HRUYbzQTilKjJHH6DlRsCuIpwqMKAEHfLQy5MRmuAufPFbYQhb0kGIx1dqU)8MHhpa79vyOE3IYdZUKitcBHmLgvr6xGS6raTcOaROxqU)8MHhpa791u5uKwbwrVE8aIYdZAPqH5uD7wyOE3kWk6fK7pVz4XJTEmdPrvK(fiREeqRaY1wkixrValAtWjWuXpuIw3dS3xtLtrA5k61JhWoxzjKLcfMtvPrvK(fiREeqRaY1wkixrVa79vyOE3kWk6fK7pVz4XJfYKXBegQ3TVxc(Qr1czUD7gXqb1p8dznXoRYb5AlfufjKMhgzjdc5MMuLXWq9U1e7SkhKRTuqvKqAEyKfLQy5MmYg2G0Oks)cKvpcOvar5Hzrj2xsa79vyOE3kWk6fK7pVz4XJfYuAufPFbYQhb0kGcSIEb5(ZBgE8inQI0Vaz1JaAfqXR6b4RIBrOeyVVcd17wwL4OeFSGmj18clkvXYnxzO0Oks)cKvpcOvajoXsrQCqyUIsG9(kmuVBzvIJs8XcYKuZlSOufl3CLHsJQi9lqw9iGwbeLhMDjrMegyVVcd17wwL4OeFSGmj18clkvXYnxzO0Oks)cKvpcOvafVQhGC)5ndpEa27RWq9ULvjokXhlitsnVWIsvSCDFtsJQi9lqw9iGwbKPhvuI9LK0Oks)cKvpcOvar5Hzrj2xssJQi9lqw9iGwbKRTuqUIELgvr6xGS6raTcyNtOxbw7jWEKegdzMR7b27ROdId7r1264A6CceD8wuKsJQi9lqw9iGwbSZvwce9EILalAtWjWuXpuIw3dS3xXuhtOxfMtsJQi9lqw9iGwbSReyI1a1Hq(fsJQi9lqw9iGwbSJpucIEpXsPrvK(fiREeqRa6cceLyFjjnQI0Vaz1JaAfqXR6bi3FEZWJhG9(kmuVBzvIJs8XcYKuZlSOufl3CLHsJQi9lqw9iGwbS7ycmUwkWEFvfP3IaRxA7CLLarVNy5M7Lgvr6xGS6raTciP48LcqKPVKKgvr6xGS6raTciP48fK4elfPYLgvr6xGS6raTcitpQDiCBG5LelWEFfgQ3Tm9O2HWTbMxsSwmXQEG2nd0K0O0OHAOYFXJhoj)PIFOu(vr6xi)My)WE2M8ZDuknQI0VazrE8WPvMEurj2xssJQi9lqwKhpCcOva5AlfKROxG9(kmuVBFVe8vJQfYC72nIHcQF4hYAIDwLdY1wkOksinpmYsgeYnnPkJHH6DRj2zvoixBPGQiH08WilkvXYnzKninQI0VazrE8WjGwb0e7ShU6khKP2Ia27R7cgQ3TMyN9Wvx5Gm1wKfYuAufPFbYI84HtaTcikpmlkX(scyVVIHcQF4hYwVJfKPhvKLmiKBAsvgdd1726DSGm9OISqMsJQi9lqwKhpCcOvafyf9cY9N3m84byVVIHcQF4hYwVJfKPhvKLmiKBAsvgdd1726DSGm9OISqMsJQi9lqwKhpCcOvaDbbIsSVKa27RyOG6h(HS17ybz6rfzjdc5MMuLXWq9UTEhlitpQilKP0Oks)cKf5XdNaAfqeuujShpa79vmuq9d)q26DSGm9OISKbHCttQYyyOE3wVJfKPhvKfYuAufPFbYI84HtaTcyNRSei69elb27R7kDXspEKgvr6xGSipE4eqRa2IqMegmVKyLgvr6xGSipE4eqRa2XhkbrVNyjWEFfgQ3TVQZr5HzTqMsJQi9lqwKhpCcOvajfNVuaIm9LK0Oks)cKf5XdNaAfWUsGjwduhc5xaS3x3fgkO(HFilIOkc86GyL1uJe8bFmZxlzqi30KQB3kUJxpMHTtyLdImDSNwmXQEG2CpdLgvr6xGSipE4eqRakEvpa5(ZBgE8aS3xHH6Dlkpm7sImjSfYuAufPFbYI84HtaTciXjwksLdcZvucS3xHH6DlRsCuIpwqMKAEHfLQy5MRmuAufPFbYI84HtaTcO4v9a8vXTiucS3xHH6DlRsCuIpwqMKAEHfLQy5MRmKXy1RGulksRwRiRhBUAynjnQI0VazrE8WjGwbK7pVz4Xdi8XtG9(kmuVBzvIJs8XcYKuZlSOuflx33K0Oks)cKf5XdNaAfquEywuI9LK0Oks)cKf5XdNaAfquEy2LezsyG9(kmuVBzvIJs8XcYKuZlSOufl3CLHsJQi9lqwKhpCcOva7Cc9kWApb2JKWyiZCDpWEFfDqCypQ2whxtNtGOJ3IIuAufPFbYI84HtaTcixBPGCf9knQI0VazrE8WjGwbuGv0li3FEZWJhPrvK(filYJhob0kGDUYsGO3tSeyrBcobMk(Hs06EG9(kM6yc9QWCsAufPFbYI84HtaTcyhFOee9EILsJQi9lqwKhpCcOvaDbbIsSVKKgvr6xGSipE4eqRaIGIkH94byVVIvVcsTOiTATISES5A72K0Oks)cKf5XdNaAfWUJjW4APa79vvKElcSEPTZvwce9EILsJQi9lqwKhpCcOva5(ZBgE8acF8eyVVcd17wwL4OeFSGmj18clkvXYnxzO0Oks)cKf5XdNaAfWoNqVcS2tG9(k6G4WEuTMqOeItGegYm9lKgvr6xGSipE4eqRaskoFbjoXsrQCPrvK(filYJhob0kGm9O2HWTbMxsSa79vyOE3Y0JAhc3gyEjXAXeR6bA3mqtto5ma]] )


end
