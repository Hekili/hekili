-- ShamanEnhancement.lua
-- May 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local PTR = ns.PTR

-- Globals
local GetWeaponEnchantInfo = GetWeaponEnchantInfo

-- Generate the Enhancement spec database only if you're actually a Shaman.
if UnitClassBase( 'player' ) == 'SHAMAN' then
    local spec = Hekili:NewSpecialization( 263 )

    spec:RegisterResource( Enum.PowerType.Mana )

    -- Talents
    spec:RegisterTalents( {
        lashing_flames = 22354, -- 334046
        forceful_winds = 22355, -- 262647
        elemental_blast = 22353, -- 117014

        stormfury = 22636, -- 334175
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
            duration = 8,
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
            max_stack = 1
        },

        doom_winds_cd = {
            id = 335904,
            duration = 60,
            max_stack = 1,
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
            id = 187881,
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
            duration = 1800,
            max_stack = 1,
        },

        flametongue_weapon = {
            duration = 1800,
            max_stack = 1,
        }
    } )


    spec:RegisterStateTable( 'feral_spirit', setmetatable( {}, {
        __index = function( t, k )
            return buff.feral_spirit[ k ]
        end
    } ) )

    spec:RegisterStateTable( 'twisting_nether', setmetatable( { onReset = function( self ) end }, {
        __index = function( t, k )
            if k == 'count' then
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
        if buff.windfury_weapon.down and ( now - action.windfury_weapon.lastCast < 1 ) then applyBuff( "windfury_weapon" ) end
        if buff.flametongue_weapon.down and ( now - action.flametongue_weapon.lastCast < 1 ) then applyBuff( "flametongue_weapon" ) end
    end )


    spec:RegisterGear( 'waycrest_legacy', 158362, 159631 )
    spec:RegisterGear( 'electric_mail', 161031, 161034, 161032, 161033, 161035 )

    spec:RegisterGear( 'tier21', 152169, 152171, 152167, 152166, 152168, 152170 )
        spec:RegisterAura( 'force_of_the_mountain', {
            id = 254308,
            duration = 10
        } )
        spec:RegisterAura( 'exposed_elements', {
            id = 252151,
            duration = 4.5
        } )

    spec:RegisterGear( 'tier20', 147175, 147176, 147177, 147178, 147179, 147180 )
        spec:RegisterAura( "lightning_crash", {
            id = 242284,
            duration = 16
        } )
        spec:RegisterAura( "crashing_lightning", {
            id = 242286,
            duration = 16,
            max_stack = 15
        } )

    spec:RegisterGear( 'tier19', 138341, 138343, 138345, 138346, 138348, 138372 )
    spec:RegisterGear( 'class', 139698, 139699, 139700, 139701, 139702, 139703, 139704, 139705 )



    spec:RegisterGear( 'akainus_absolute_justice', 137084 )
    spec:RegisterGear( 'emalons_charged_core', 137616 )
    spec:RegisterGear( 'eye_of_the_twisting_nether', 137050 )
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

    spec:RegisterGear( 'smoldering_heart', 151819 )
    spec:RegisterGear( 'soul_of_the_farseer', 151647 )
    spec:RegisterGear( 'spiritual_journey', 138117 )
    spec:RegisterGear( 'storm_tempests', 137103 )
    spec:RegisterGear( 'uncertain_reminder', 143732 )


    spec:RegisterTotem( "vesper_totem", 3565451 )


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

    spec:RegisterAbilities( {
        ascendance = {
            id = 114051,
            cast = 0,
            cooldown = 180,
            gcd = 'off',

            readyTime = function() return buff.ascendance.remains end,

            toggle = 'cooldowns',

            startsCombat = false,

            talent = 'ascendance',
            nobuff = 'ascendance',

            handler = function ()
                applyBuff( 'ascendance' )
                setCooldown( 'stormstrike', 0 )
                setCooldown( 'windstrike', 0 )
            end,
        },

        astral_shift = {
            id = 108271,
            cast = 0,
            cooldown = 90,
            gcd = 'off',

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
            gcd = 'off', -- Ugh.

            spend = 0.215,
            spendType = 'mana',

            startsCombat = false,

            handler = function ()
                applyBuff( 'bloodlust', 40 )
            end,

            copy = { 204361, 2825 }
        },

        capacitor_totem = {
            id = 192058,
            cast = 0,
            cooldown = 60,
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
                if active_enemies > 1 then
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

        crash_lightning = {
            id = 187874,
            cast = 0,
            cooldown = function () return 9 * haste end,
            gcd = 'spell',

            startsCombat = true,

            handler = function ()
                if active_enemies >= 2 then
                    applyBuff( 'crash_lightning', 10 )
                    applyBuff( "gathering_storms" )
                end

                removeBuff( "crashing_lightning" )
                removeBuff( "crash_lightning_cl" )

                --[[ if level < 116 then
                    if equipped.emalons_charged_core and spell_targets.crash_lightning >= 3 then
                        applyBuff( 'emalons_charged_core', 10 )
                    end

                    if set_bonus.tier20_2pc > 1 then
                        applyBuff( 'lightning_crash' )
                    end

                    if equipped.eye_of_the_twisting_nether then
                        applyBuff( 'shock_of_the_twisting_nether', 8 )
                    end

                    if azerite.natural_harmony.enabled and buff.frostbrand.up then applyBuff( "natural_harmony_frost" ) end
                    if azerite.natural_harmony.enabled and buff.flametongue.up then applyBuff( "natural_harmony_fire" ) end
                    if azerite.natural_harmony.enabled then applyBuff( "natural_harmony_nature" ) end
                end ]]
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
            end,
        },

        earth_shield = {
            id = 204288,
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
            gcd = 'spell',

            startsCombat = true,
            texture = 1016245,

            handler = function ()
                applyDebuff( 'target', 'earthen_spike' )

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
            end,
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
            id = 188070,
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
            spendType = 'mana',

            startsCombat = false,
            toggle = 'cooldowns',

            handler = function ()
                applyBuff( 'heroism' )
                applyDebuff( 'player', 'exhaustion', 600 )
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

                if level < 116 and equipped.eye_of_the_twisting_nether then
                    applyBuff( 'shock_of_the_twisting_nether' )
                end

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

            timeToReady = function () return buff.lightning_shield.remains - 120 end,
            handler = function ()
                removeBuff( "earth_shield" )
                applyBuff( "lightning_shield" )
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

            handler = function ()
                setCooldown( 'windstrike', action.stormstrike.cooldown )
                setCooldown( 'strike', action.stormstrike.cooldown )

                if buff.stormbringer.up then
                    removeBuff( 'stormbringer' )
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

                if level < 116 then
                    if equipped.storm_tempests then
                        applyDebuff( 'target', 'storm_tempests', 15 )
                    end

                    if set_bonus.tier20_4pc > 0 then
                        addStack( 'crashing_lightning', 16, 1 )
                    end

                    if equipped.eye_of_the_twisting_nether and buff.crash_lightning.up then
                        applyBuff( 'shock_of_the_twisting_nether', 8 )
                    end
                end

                if azerite.natural_harmony.enabled and buff.frostbrand.up then applyBuff( "natural_harmony_frost" ) end
                if azerite.natural_harmony.enabled and buff.flametongue.up then applyBuff( "natural_harmony_fire" ) end
                if azerite.natural_harmony.enabled and buff.crash_lightning.up then applyBuff( "natural_harmony_nature" ) end
            end,

            copy = "strike", -- copies this ability to this key or keys (if a table value)
        },

        sundering = {
            id = 197214,
            cast = 0,
            cooldown = 40,
            gcd = "spell",

            handler = function ()
                if level < 116 and equipped.eye_of_the_twisting_nether then
                    applyBuff( 'fire_of_the_twisting_nether' )
                end

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
            cooldown = 60,
            gcd = "spell",

            spend = 0.02,
            spendType = "mana",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 136108,

            handler = function ()
            end,
        },

        vesper_totem = {
            id = 324386,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            spend = 0.1,
            spendType = "mana",

            startsCombat = true,
            texture = 3565451,

            handler = function ()
                applyBuff( "vesper_totem" )
                summonPet( "vesper_totem", 30 )
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

                if legendary.doom_winds.enabled and debuff.doom_winds_cd.down then
                    applyBuff( "doom_winds" )
                    applyDebuff( "player", "doom_winds_cd" )
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
            cooldown = function() return gcd.execute * 2 - 0.01 end,
            gcd = "spell",

            texture = 1029585,
            known = 17364,

            buff = 'ascendance',

            bind = "stormstrike",

            handler = function ()
                setCooldown( 'stormstrike', action.stormstrike.cooldown )
                setCooldown( 'strike', action.stormstrike.cooldown )

                if buff.stormbringer.up then
                    removeBuff( 'stormbringer' )
                end

                removeBuff( "gathering_storms" )
                removeBuff( "strength_of_earth" )
                removeBuff( "legacy_of_the_frost_witch" )

                if talent.elemental_assault.enabled then
                    addStack( "maelstrom_weapon", nil, 1 )
                end

                if level < 116 then
                    if equipped.storm_tempests then
                        applyDebuff( 'target', 'storm_tempests', 15 )
                    end

                    if set_bonus.tier20_4pc > 0 then
                        addStack( 'crashing_lightning', 16, 1 )
                    end

                    if equipped.eye_of_the_twisting_nether and buff.crash_lightning.up then
                        applyBuff( 'shock_of_the_twisting_nether', 8 )
                    end
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

        potion = "superior_battle_potion_of_agility",

        package = "Enhancement",
    } )


    spec:RegisterPack( "Enhancement", 20200813, [[d4ZQwaqBLSjcXUuQxlL2hi53apLOzlvZxkY5jK(LQsFdkf)dKQyNIs7vy3k2pPgLkudtf14KIQtlzOGuvgSQmCr1HKIIJkfLQJrOohuQyHQilfkvAXq1Yr6XiwfuQAzqrphYeLIsmvPWKb10P6rsrj9kvfxg11j4IsrPCykBMKTdf(oiMfuY0uHmpqkJeKQQTbLsJweFwv1jbPk9mvqxdKk3tKwPO4uQa)vLoehncjS5CKfZZyE(CZfF4gZdpJnH0fnNdzUrATFoKJT4q2Snj2q4fpEiZnr7adoAeseqGs4q2SluKw9Zgy9RzPOUOHexO6o07e4He2CoYI5zmpFU5IpCJ5HNXwOR5HeLZKilMy7HHmPGH5jWdjmJiHe7ce(t0pOpAbOLlQ(Pau9tMyWaiDBGrHSxihfncjmRmHUhnISIJgH0iEbMqcPg4lkHnAi5XW7mCCk8ilMrJqAeVatiZtkRFbQlIP8uUOHKhdVZWXPWJShgncjpgENHJtHKqlNPLfsJ4fg8LhEvms)Gs)eRFIOF4ck1MqnuYTx)j(uZ)ggazcPr8cmHKqnuYTx)j(uZF4r2JIgH0iEbMqcPgyKtRwoK8y4DgoofEKf6IgHKhdVZWXPqsOLZ0YcjUGsTxg3rofSUqylhmBKBKw9dA6N4ZH0iEbMqQyQ1VO8IwE4rwSnAesEm8odhNcjHwotllKeaOddGmBKtRwEt5LvdkKgXlWesdr4b2gchEKfBIgH0iEbMqIbJYz61boVcjpgENHJtHhzBE0iK8y4DgoofscTCMwwiXfuQDIvDKdORnYnsR(LQFqN(jI(HlOu7LXDKtbRle2YbZg5gPv)Gs)okKgXlWesffG8lkbqAdpYIDIgHKhdVZWXPqsOLZ0YcjUGsTxg3rofSUqylhmBKBKw9dk97OqAeVatiroGUAzoNPHhzfFoAesEm8odhNcjHwotllKgXlm4lp8QyK(LQFIdPr8cmHKnQNWZfLxTC4rwXIJgHKhdVZWXPqsOLZ0YcPr8cd(YdVkgPFP6Ny9te97y97y9dxqP2lJ7iNcwxiSLdMnYnsR(bL(DK(jI(HlOuBKdORwMZz6wix)er)WfuQnYb0vlZ5mDt5Lvds)GwQ(9tG1pSx)Wu)oq)AQj9dxqP2lJ7iNcwxiSLdMnYnsR(LQFIpRFhesJ4fyczV(t8PM)loO7HhzfJz0iK8y4DgoofscTCMwwinIxyWxE4vXi9dk9tS(jI(DS(DS(HlOu7LXDKtbRle2YbZg5gPv)Gs)os)er)WfuQnYb0vlZ5mDlKRFIOF4ck1g5a6QL5CMUP8YQbPFqlv)(jW6h2RFyQFhOFn1K(HlOu7LXDKtbRle2YbZg5gPv)s1pXN1VdcPr8cmHKKy1C71FIp18hEKv8HrJqYJH3z44uij0YzAzHexqP2lJ7iNcwxiSLdMnYnsR(bL(DuinIxGjKCNx84w)I3nKhEKv8rrJqYJH3z44uij0YzAzHexqP2jw1roGU2i3iT6xQ(bDH0iEbMqQOaKFrjasB4rwXqx0iK8y4DgoofscTCMwwinIxyWxE4vXi9dk9tCinIxGjKeQHsU96pXNA(dpYkgBJgHKhdVZWXPqsOLZ0YcPr8cd(YdVkgPFqPFIdPr8cmHejmWmTM)WJSIXMOri5XW7mCCkKeA5mTSq2m6hmJlOuBv3w8fLaiTBH8qAeVativDBXxucG0gEKvCZJgHKhdVZWXPqsOLZ0YcjUGsTta(nXg4TqEinIxGjKDdd72nus4rwXyNOri5XW7mCCkKeA5mTSqAeVWGV8WRIr6xQ(joKgXlWes2OEcpxuE1YHhzX8C0iK8y4DgoofscTCMwwiXfuQ9Y4oYPG1fcB5GzJCJ0QFqt)eFoKgXlWesKdOlKtRwo8ilMIJgHKhdVZWXPqsOLZ0YczN)5b2OIUHbG1fsnWOnpgENH1pr0pygxqP2WaW6cPgy0LaVHbqMqAeVatiHudSsGk61boVcpYIjMrJqYJH3z44uij0YzAzH0iEHbF5HxfJ0pO0pX6Ni63X6hUGsTxg3rofSUqylhmBKBKw9dk97i9RPM0pCbLAJCaD1YCot3c563b6Ni63X6xZOF4ck1MqnuYTx)j(uZ)L03c56xtnPF4ck1EzCh5uW6cHTCWSrUrA1pO0VMRFhesJ4fycjjXQ52R)eFQ5p8ilMhgncjpgENHJtHKqlNPLfsJ4fg8LhEvms)s1pX6Ni63X6hUGsTxg3rofSUqylhmBKBKw9dk97i9RPM0pCbLAJCaD1YCot3c563bH0iEbMq2R)eFQ5)Id6E4rwmpkAesJ4fycPdCEDxgYzQOHKhdVZWXPWJSycDrJqYJH3z44uij0YzAzH0iEHbFHb(w1TfFrjasR(H963X63X6Nr8cd(YdVkgPFhOFqd6r)Ww97a9dk9dBcPr8cmHuvu(oamSWJSyITrJqYJH3z44uinIxGjKQUT4lkbqAdjHwotllKuwrzuIH35qseL05RB0F2rrwXHhzXeBIgH0iEbMqYg1t45IYRwoK8y4DgoofEKfZMhncPr8cmHejmWmTM)qYJH3z44u4rwmXorJqYJH3z44uij0YzAzHKaaDyaKzROaKFrjas7MYlRgK(bL(9tGdPr8cmHSi8f50QLdpYE45OrinIxGjKDdd72nusi5XW7mCCk8i7HIJgH0iEbMqsOgk52R)eFQ5pK8y4DgoofEK9qmJgHKhdVZWXPqsOLZ0YczZOFU15X3jw1roGU28y4Dgw)er)Gb(w1TfFrjas7MYlRgK(bL(zeVaZLaaDyaKjKgXlWesffG8lkbqAdp8qMtzcyHBE0iYkoAesEm8odhNcjHwotllK4ck1Ux)j(uZ)fLuChEt5Lvds)GM(D45ZH0iEbMq2R)eFQ5)IskUdhEKfZOri5XW7mCCkKeA5mTSqIlOuBi1aReOIEHWwoy2uEz1G0pOPFhE(CinIxGjKqQbwjqf9cHTCWeEK9WOri5XW7mCCkKeA5mTSqIlOuBv3wSdMFb(cHTCWSP8YQbPFqt)o885qAeVativDBXoy(f4le2Ybt4r2JIgHKhdVZWXPqsOLZ0YcjUGsTHudSsGk61boV2WaitinIxGjKqQbwjqf96aNxHhE4HedMIkWezX8mMNpJnIBEiHy0PMFuiHEx5aQZW6hM6Nr8cm6xVqoARZeYCkqvDoKnR6h2fi8NOFqF0cqlxu9tbO6NmXGbq62aJ0z0zmIxGbTZPmbSWnpTx)j(uZ)fLuChgRsLIlOu7E9N4tn)xusXD4nLxwniOD45Z6mgXlWG25uMaw4M)j9lKAGvcurVqylhmyvQuCbLAdPgyLav0le2YbZMYlRge0o88zDgJ4fyq7CktalCZ)K(v1Tf7G5xGVqylhmyvQuCbLAR62IDW8lWxiSLdMnLxwniOD45Z6mgXlWG25uMaw4M)j9lKAGvcurVoW5fwLkfxqP2qQbwjqf96aNxByaKrNrNXiEbgukKAGVOe2O6mgXlWG(K(npPS(fOUiMYt5IQZyeVad6t6xc1qj3E9N4tn)yvQuJ4fg8LhEvmckXIGlOuBc1qj3E9N4tn)ByaKrNXiEbg0N0VqQbg50QL1zmIxGb9j9RIPw)IYlA5yvQuCbLAVmUJCkyDHWwoy2i3iTqt8zDgJ4fyqFs)AicpW2qySkvkba6WaiZg50QL3uEz1G0z0zmIxGb9j9lgmkNPxh48sNXiEbg0N0Vkka5xucG0IvPsXfuQDIvDKdORnYnsBk0jcUGsTxg3rofSUqylhmBKBKwOosNXiEbg0N0VihqxTmNZuSkvkUGsTxg3rofSUqylhmBKBKwOosNXiEbg0N0VSr9eEUO8QLXQuPgXlm4lp8QyuQyDgJ4fyqFs)2R)eFQ5)Id6owLk1iEHbF5HxfJsflYXhJlOu7LXDKtbRle2YbZg5gPfQJebxqP2ihqxTmNZ0TqUi4ck1g5a6QL5CMUP8YQbbT0Fcm2J5bn1eUGsTxg3rofSUqylhmBKBK2uXNpqNXiEbg0N0VKeRMBV(t8PMFSkvQr8cd(YdVkgbLyro(yCbLAVmUJCkyDHWwoy2i3iTqDKi4ck1g5a6QL5CMUfYfbxqP2ihqxTmNZ0nLxwniOL(tGXEmpOPMWfuQ9Y4oYPG1fcB5GzJCJ0Mk(8b6mgXlWG(K(L78Ih36x8UHCSkvkUGsTxg3rofSUqylhmBKBKwOosNXiEbg0N0Vkka5xucG0IvPsXfuQDIvDKdORnYnsBk0PZyeVad6t6xc1qj3E9N4tn)yvQuJ4fg8LhEvmckX6mgXlWG(K(fjmWmTMFSkvQr8cd(YdVkgbLyDgJ4fyqFs)Q62IVOeaPfRsL2mWmUGsTvDBXxucG0UfY1zmIxGb9j9B3WWUDdLGvPsXfuQDcWVj2aVfY1zmIxGb9j9lBupHNlkVAzSkvQr8cd(YdVkgLkwNXiEbg0N0VihqxiNwTmwLkfxqP2lJ7iNcwxiSLdMnYnsl0eFwNrNXiEbg0N0VqQbwjqf96aNxyvQ0o)ZdSrfDddaRlKAGrBEm8odlcmJlOuByayDHudm6sG3WaiJoJoJr8cmOpPFjjwn3E9N4tn)yvQuJ4fg8LhEvmckXICmUGsTxg3rofSUqylhmBKBKwOoQPMWfuQnYb0vlZ5mDlKFGih3m4ck1MqnuYTx)j(uZ)L03c5n1eUGsTxg3rofSUqylhmBKBKwOA(b6mgXlWG(K(Tx)j(uZ)fh0DSkvQr8cd(YdVkgLkwKJXfuQ9Y4oYPG1fcB5GzJCJ0c1rn1eUGsTroGUAzoNPBH8d0zmIxGb9j9RdCEDxgYzQO6mgXlWG(K(vvu(oammSkvQr8cd(cd8TQBl(IsaKwS)4JnIxyWxE4vXOdGg0d2EauyJoJr8cmOpPFvDBXxucG0IfrusNVUr)zhLkgRsLszfLrjgEN1zmIxGb9j9lBupHNlkVAzDgJ4fyqFs)IegyMwZVoJr8cmOpPFlcFroTAzSkvkba6WaiZwrbi)IsaK2nLxwniO(jW6mgXlWG(K(TByy3UHs0zmIxGb9j9lHAOKBV(t8PMFDgJ4fyqFs)QOaKFrjaslwLkTzCRZJVtSQJCaDT5XW7mSiWaFR62IVOeaPDt5LvdckJ4fyUeaOddGmH0e8eanKyxj0F4Hhb]] )

end
