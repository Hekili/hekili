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

        -- Conduit
        swirling_currents = {
            id = 338340,
            duration = 15,
            max_stack = 1
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


    local death_events = {
        UNIT_DIED               = true,
        UNIT_DESTROYED          = true,
        UNIT_DISSIPATES         = true,
        PARTY_KILL              = true,
        SPELL_INSTAKILL         = true,
    }

    local vesper_heal = 0
    local vesper_damage = 0
    local vesper_used = 0

    local vesper_expires = 0
    local vesper_guid
    local vesper_last_proc = 0

    spec:RegisterCombatLogEvent( function( _, subtype, _,  sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )
        -- Deaths/despawns.
        if death_events[ subtype ] and destGUID == vesper_guid then
            vesper_guid = nil
            return
        end

        if sourceGUID == state.GUID then
            -- Summons.
            if subtype == "SPELL_SUMMON" and spellID == 324386 then
                vesper_guid = destGUID
                vesper_expires = GetTime() + 30

                vesper_heal = 3
                vesper_damage = 3
                vesper_used = 0

            -- Vesper Totem heal
            elseif spellID == 324522 then
                local now = GetTime()

                if vesper_last_proc + 0.75 < now then
                    vesper_last_proc = now
                    vesper_used = vesper_used + 1
                    vesper_heal = vesper_heal - 1
                end

            -- Vesper Totem damage; only fires on SPELL_DAMAGE...
            elseif spellID == 324520 then
                local now = GetTime()

                if vesper_last_proc + 0.75 < now then
                    vesper_last_proc = now
                    vesper_used = vesper_used + 1
                    vesper_damage = vesper_damage - 1
                end

            end

            if subtype == "SPELL_CAST_SUCCESS" then
                -- Reset in case we need to deal with an instant after a hardcast.
                vesper_last_proc = 0
            end
        end
    end )

    spec:RegisterStateExpr( "vesper_totem_heal_charges", function()
        return vesper_heal
    end )

    spec:RegisterStateExpr( "vesper_totem_dmg_charges", function ()
        return vesper_damage
    end )

    spec:RegisterStateExpr( "vesper_totem_used_charges", function ()
        return vesper_used
    end )

    spec:RegisterStateFunction( "trigger_vesper_heal", function ()
        if vesper_totem_heal_charges > 0 then
            vesper_totem_heal_charges = vesper_totem_heal_charges - 1
            vesper_totem_used_charges = vesper_totem_used_charges + 1
        end
    end )

    spec:RegisterStateFunction( "trigger_vesper_damage", function ()
        if vesper_totem_dmg_charges > 0 then
            vesper_totem_dmg_charges = vesper_totem_dmg_charges - 1
            vesper_totem_used_charges = vesper_totem_used_charges + 1
        end
    end )


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

        if settings.pad_lava_lash and cooldown.lava_lash.remains > 0 and buff.hot_hand.up then
            reduceCooldown( "lava_lash", latency * 2 )
        end

        if vesper_expires > 0 and now > vesper_expires then
            vesper_expires = 0
            vesper_heal = 0
            vesper_damage = 0
            vesper_used = 0
        end

        vesper_totem_heal_charges = nil
        vesper_totem_dmg_charges = nil
        vesper_totem_used_charges = nil

        if totem.vesper_totem.up then
            applyBuff( "vesper_totem", totem.vesper_totem.remains )
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

                if buff.vesper_totem.up and vesper_totem_heal_charges > 0 then trigger_vesper_heal() end
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

                if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
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

                if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
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

                if buff.vesper_totem.up and vesper_totem_heal_charges > 0 then trigger_vesper_heal() end
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

                if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
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

                if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
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
                if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
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

                if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
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
                removeBuff( "hailstorm" )

                setCooldown( "flame_shock", 6 * haste )

                if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
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
                if buff.vesper_totem.up and vesper_totem_heal_charges > 0 then trigger_vesper_heal() end
                if conduit.swirling_currents.enabled then applyBuff( "swirling_currents" ) end
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

                if buff.vesper_totem.up and vesper_totem_heal_charges > 0 then trigger_vesper_heal() end
                if buff.swirling_currents.up then removeStack( "swirling_currents" ) end
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

                if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
            end,
        },

        lava_lash = {
            id = 60103,
            cast = 0,
            cooldown = function () return ( buff.hot_hand.up and 4.5 or 18 ) * haste end,
            gcd = "spell",

            startsCombat = true,
            texture = 236289,

            cycle = function()
                return talent.lashing_flames.enabled and "lashing_flames" or nil
            end,

            indicator = function()
                return debuff.flame_shock.down and active_dot.flame_shock > 0 and "cycle" or nil
            end,

            handler = function ()
                removeDebuff( "target", "primal_primer" )

                if talent.lashing_flames.enabled then applyDebuff( "target", "lashing_flames" ) end

                removeBuff( "primal_lava_actuators" )

                if azerite.natural_harmony.enabled and buff.frostbrand.up then applyBuff( "natural_harmony_frost" ) end
                if azerite.natural_harmony.enabled then applyBuff( "natural_harmony_fire" ) end
                if azerite.natural_harmony.enabled and buff.crash_lightning.up then applyBuff( "natural_harmony_nature" ) end

                -- This is dumb, but technically you don't know if FS will go to a new target or refresh an old one.  Even your current target.
                if debuff.flame_shock.up and active_dot.flame_shock < 3 then active_dot.flame_shock = 3 end
                if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
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

                if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
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

                if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
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

                if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
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

                if azerite.natural_harmony.enabled then
                    if buff.frostbrand.up then applyBuff( "natural_harmony_frost" ) end
                    if buff.flametongue.up then applyBuff( "natural_harmony_fire" ) end
                    if buff.crash_lightning.up then applyBuff( "natural_harmony_nature" ) end
                end

                if buff.vesper_totem.up and vesper_totem_dmg_charges > 0 then trigger_vesper_damage() end
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

    spec:RegisterSetting( "pad_lava_lash", true, {
        name = "Pad |T236289:0|t Lava Lash Cooldown",
        desc = "If checked, the addon will treat |T236289:0|t Lava Lash's cooldown as slightly shorter, to help ensure that it is recommended as frequently as possible during Hot Hand.",
        type = "toggle",
        width = 1.5
    } )

    spec:RegisterSetting( "filler_shock", true, {
        name = "Filler |T135813:0|t Shock",
        desc = "If checked, the addon's default priority will recommend a filler |T135813:0|t Flame Shock when there's nothing else to push, even if something better will be off cooldown very soon.  " ..
            "This matches sim behavior and is a small DPS increase, but has been confusing to some users.",
        type = "toggle",
        width = 1.5
    })


    spec:RegisterPack( "Enhancement", 20220326, [[du05ybqiaWJqc0MqH(ekQgfsOtHK4vOGzHeDlQGKDr4xOidtH0XaKLrf6zaOPHe01qrzBij5BOksJJkiohaK1HQiMhvG7PK2hQshejPWcrs9qufvxejG(isaCsufLvQqntKKQBIKu0obOFIKuAPubPEQsnva1xrcqJfaQ9QYFL0Gv0HPSyu6XKAYu1LH2SeFwjgTcoTWRPIMnj3gP2Tu)wvdNkDCufwoONJy6IUoqBhv8DuvJNkOoVcX8rL2prFaDaFBVL4bOJJ6OJJcqhPkbqJ6iabYXBNJ4I3210oTf82TrJ3McShSwJ0yN321gr9M)a(2KheQXBVdAE(TzbdvYZ6J92ElXdqhh1rhhfGosvcGg1rac0TjUO(a0rQcG3Ei8ESp2B7rI(2uG9G1AKg7uo3dgT1YXunnOEqoDKzukNooQJoEBvqsYb8TjrVOWd4dqGoGVTPZ47BZpApjHHt82yBSk0FuF5bOJhW3gBJvH(J6BRHrIWWUnlyPig(SoyTxa6kNC5kNuuoHGnwE4ckCHbTPQkJJvnDcA5djcKhGHRl6LtgLtwWsr4cdAtvvghRA6e0YhseK00oLtELtQsoPYTnDgFFBLXXQkJmC5biapGVn2gRc9h13wdJeHHDBaqozblfb)O9fq4i18tKwa6EBtNX33MF0(ciCKA(jsF5bifEaFBSnwf6pQVTggjcd72qWglpCbf()PR8J2teipadxx0lNmkNSGLIW)pDLF0EIa092MoJVVnjFinjHHt8YdqMDaFBSnwf6pQVTggjcd72qWglpCbf()PR8J2teipadxx0lNmkNSGLIW)pDLF0EIa092MoJVVTgAKHQkwgYo6LlpaPQd4BJTXQq)r9T1Wiryy3gc2y5HlOW)pDLF0EIa5by46IE5Kr5KfSue()PR8J2teGU320z89TdnwjjmCIxEaYtpGVn2gRc9h13wdJeHHDBiyJLhUGc))0v(r7jcKhGHRl6LtgLtwWsr4)NUYpApra6EBtNX33Ma2Eeg9YLhGoKd4BJTXQq)r9T1Wiryy3MfSueUWG(H(Wuv(ghu4F(TCYOCsr5eAHVICWofM3terlN8kNuOJYjxUYj0cFf5GDkmVNiIwoDGCsvYjvUTPZ47B7cd6h6dtv5BCWlpabqhW3gBJvH(J6BRHrIWWUnaiNzODg9YTnDgFF7IYOXkz41oV8aeOrpGVn2gRc9h13wdJeHHDBwWsrqBOIKWNUYhn3VfK00oLtExLtMjNmkNSGLIWfg0p0hMQY34Gcqx5Kr5eAHVICWofM3terlN8kNSGLIWfg0p0hMQY34GcisBrtKtgLtkkNaGCYcwkcIRk6eHOVIkKg7KiaDLtUCLZsSmKvisBrtKthSkNa5OCsLBB6m((2Qyzi7OxQSVkV8aeiGoGVn2gRc9h13wdJeHHDBOf(kYb7uyEpreTCYRCsHJEBtNX33MdsCryn)ePV8aeihpGVn2gRc9h13wdJeHHDBwWsrmyHIKpKwa6EBtNX33UaFswjdV25LhGabWd4BB6m((2ObZbSRe3WjEBSnwf6pQV8aeik8a(2yBSk0FuFBnmseg2T9FkkkJgRKHx7uaXcejdgRcVTPZ47BRmowvzKHlpabIzhW3gBJvH(J6BRHrIWWUnaiNqWglpCbfee9K6xQqJ216SUaF(5Ga5by46IE5Klx5u)VY)8BrbHMQsCdyKcisBrtKtELtao6TnDgFF7IH1eAnPasIVV8aeiQ6a(2yBSk0FuFBnmseg2TttHDki5dPlkqiCeb2gRc9YjJYjlyPii5dPzHrVGqbO7TnDgFFBs(qAscdN4LhGaXtpGVn2gRc9h13wdJeHHDBwWsrqYhs7erxekaDVTPZ47BRhSORQyzi7OxU8aeihYb8TX2yvO)O(2AyKimSBZcwkcAdvKe(0v(O5(TGKM2PCY7QCYSBB6m((2OcPXonvLvzK8YdqGaqhW3gBJvH(J6BRHrIWWUneSXYdxqb0wIEPYbjUiSY5Hj6WcKhGHRl6LtgLZ0uyNc0G5qLmeOYlW2yvOxozuoPOCYbjUiSMFI01b0uv9GbxqICYRCcKCYLRCsr5KdsCryn)ePRdOPQ6bdUGe5Kx5Cu5Kr5eAHVICWofM3terlN8kNuuozblfbhK4IWA(jslGiTfnroDOKtakNuroPICsLBB6m((2dOPIEPssiA018tK(Ydqhh9a(2yBSk0FuFBnmseg2THGnwE4ckG2s0lvoiXfHvopmrhwG8amCDrVCYOCMMc7uGgmhQKHavEb2gRc9YjJYjfLtoiXfH18tKUoGMQQhm4csKtELtGKtUCLtkkNCqIlcR5NiDDanvvpyWfKiN8kNJkNmkNql8vKd2PW8EIiA5Kx5KIYjlyPi4GexewZprAbePTOjYPdLCcq5KkYjvKtQCBtNX33gnyoujdbQ8xEa6iqhW3gBJvH(J6BRHrIWWUnlyPiOnurs4tx5JM73csAANYjVRYjZKtgLtOf(kYb7uyEpreTCY7QCcGg92MoJVVTEWIUoyqoijV8a0rhpGVn2gRc9h13wdJeHHDBwWsrqBOIKWNUYhn3VfK00oLZv5eOrLtgLtwWsr4cd6h6dtv5BCqH)53320z89TvXYq2rVuzFvE5bOJa8a(2MoJVVnjFinjHHt82yBSk0FuF5bOJu4b8TX2yvO)O(2AyKimSBZcwkcAdvKe(0v(O5(TGKM2PCY7QCYSBB6m((2K8H0or0fHxEa6iZoGVn2gRc9h13wdJeHHDBYdQyJ2l48kldfwjVId2PaBJvH(BB6m((2ffsg0qRK3o6eHqq382aD5bOJu1b8TX2yvO)O(2AyKimSBZcwkc(r7lGWrQ5NiTaI0w0e50bYjqJEBtNX33MF0(ciCKA(jsF5bOJ80d4BB6m((2kJJvvgz42yBSk0FuF5bOJoKd4BJTXQq)r9T1Wiryy3MfSue0gQij8PR8rZ9BbjnTt5K3v5KzYjJYjlyPiCHb9d9HPQ8noOW)87BB6m((2Qyzi7OxQSVkV8a0ra0b8TX2yvO)O(2AyKimSBdTWxroyNcZ7jIOLtExLtkC0BB6m((2eW2JWOxU8aeGJEaFBtNX33UaFswjdV25TX2yvO)O(Ydqac0b8TnDgFFBn0idvvSmKD0l3gBJvH(J6lpabOJhW320z89TdnwjjmCI3gBJvH(J6lpabiapGVn2gRc9h13wdJeHHDBtNbhS6)uuugnwjdV25TnDgFF7saXA)CSlpabifEaFBSnwf6pQVTggjcd72KhuXgTx4cssqfwriOBgFlW2yvO)2MoJVVDrHKbn0k5LhGaKzhW320z89TrdMdvuH0yNM62yBSk0FuF5biaPQd4BJTXQq)r9T1Wiryy3MGzg9crucLcHvYWRDEBtNX33UOmASsgETZlpabip9a(2yBSk0FuFBnmseg2Tzblfb)O9fq4i18tKwarAlAIC6a5eGJEBtNX33MF0(ciCKA(jsF5L32E8a(aeOd4BJTXQq)r9T1Wiryy3MfSue0gQij8PR8rZ9BbjnTt5K3v5Kz320z89T1dw01bdYbj5LhGoEaFBSnwf6pQVTggjcd72qWglpCbf()PR8J2teipadxx0lNmkNSGLIW)pDLF0EIa092MoJVVTgAKHQkwgYo6Llpab4b8TX2yvO)O(2AyKimSBdbBS8Wfu4)NUYpAprG8amCDrVCYOCYcwkc))0v(r7jcq3BB6m((2eW2JWOxU8aKcpGVn2gRc9h13wdJeHHDBiyJLhUGcOTe9sLdsCryLZdt0Hfipadxx0lNmkNPPWofObZHkziqLxGTXQqVCYOCYbjUiSMFI01b0uv9GbxqICYRCo6TnDgFF7b0urVujjen6A(jsF5biZoGVn2gRc9h13wdJeHHDBiyJLhUGcOTe9sLdsCryLZdt0Hfipadxx0lNmkNPPWofObZHkziqLxGTXQqVCYOCYbjUiSMFI01b0uv9GbxqICYRCo6TnDgFFB0G5qLmeOYF5bivDaFBSnwf6pQVTggjcd72Modoy1)POOmASsgETt5K3v5KQKtUCLtkkNModoy1)POOmASsgETt5K3v5KcLtgLttNbhS6)uuugnwjdV2PCY7QCQhrRWk2iDGe5Kk320z89TlbeR9ZXU8aKNEaFBSnwf6pQVTPZ47B7cd6h6dtv5BCWBRHrIWWUnaiNSGLIWfg0p0hMQY34Gcq3BRhrRWAAWfmjhGaD5bOd5a(2yBSk0FuFBnmseg2THGnwE4ck8i6QgPc)prFfvin2jrG8amCDrVCYOCYcwkcn0idvvSmKD0lcq3BB6m((28J2tsy4eV8aeaDaFBSnwf6pQVTggjcd72qWglpCbfEeDvJuH)NOVIkKg7KiqEagUUOxozuozblfHgAKHQkwgYo6fbO7TnDgFFBs(qAscdN4LhGan6b8TX2yvO)O(2MoJVVTY4yvLrgUTggjcd72(pffLrJvYWRDkYq7m6f5Kr5KIYPPZGdw9FkkkJgRKHx7uoDGCQhrRWk2iDGe5Kr500zWbR(pffLrJvYWRDkNoqoPk5Kk3wpIwH10Glysoab6YdqGa6a(2yBSk0FuFBnmseg2Tba5mdTZOxUTPZ47BxugnwjdV25LhGa54b8TX2yvO)O(2MoJVVDrz0yLm8AN3wdJeHHDBaqottHDkgSqrYhslW2yvOxozuonDgCWQ)trrz0yLm8ANYPdKt9iAfwXgPdKiNmkNModoy1)POOmASsgETt50bYjvDB9iAfwtdUGj5aeOlpabcGhW3gBJvH(J6BRHrIWWUnfLttNbhS6)uuugnwjdV2PCY7QCQhrRWk2iDGe5Klx500zWbR(pffLrJvYWRDkN8UkNuOCsf5Kr5KfSueUWG(H(Wuv(ghua6kNmkNSGLIG2qfjHpDLpAUFliPPDkN8UkNmtozuoPOCcaYjlyPiiUQOteI(kQqAStIa0vo5YvolXYqwHiTfnroDWQCcKJYjxUYj0cFf5GDkmVNiGiTfnroDWQCUO9YjvUTPZ47BRILHSJEPY(Q8YdqGOWd4BJTXQq)r9T1Wiryy3MfSuedwOi5dPfGU320z89TlWNKvYWRDE5biqm7a(2yBSk0FuFBnmseg2TjpOInAVyb(CWA0CILhAz8TaBJvHE5Klx5K8Gk2O9IsGkF9lvw1tipnrGTXQqVCYLRCcbBS8Wfuqq0tQFPcnAxRZ6c85NdcKhGHRl6VTPZ47BxmSMqRjfqs89LhGarvhW3gBJvH(J6BRHrIWWUnlyPi0qJmuvXYq2rVi8p)wozuozblfHlmOFOpmvLVXbfGUYjJYjlyPiOnurs4tx5JM73csAANYPdKtMDBtNX33wdnYqvfldzh9YLhGaXtpGVn2gRc9h13wdJeHHDBwWsr4cd6h6dtv5BCqbORCYOCYcwkcAdvKe(0v(O5(TGKM2PC6a5Kz320z89TjGThHrVC5biqoKd4BJTXQq)r9T1Wiryy3MfSueUWG(H(Wuv(ghua6kNmkNSGLIG2qfjHpDLpAUFliPPDkNoqoz2TnDgFFBs(qAscdN4LhGabGoGVTPZ47BtaBpcJE52yBSk0FuF5bOJJEaFBSnwf6pQVTggjcd72Modoy1)POOmASsgETt5K3v5KcVTPZ47Bxciw7NJD5bOJaDaFBSnwf6pQVTggjcd72PPWofAOrgIEPsYhslW2yvOxo5YvozblfHgAKHQkwgYo6fH)53320z89T1qJmuvXYq2rVC5bOJoEaFBSnwf6pQVTPZ47BRmowvzKHBRHrIWWUDAkStHYidrVulkJgjcSnwf6VTEeTcRPbxWKCac0LhGocWd4BJTXQq)r9T1Wiryy320zWbR(pffLrJvYWRDkN8UkNa82MoJVVDjGyTFo2LhGosHhW320z89T5GexewZpr6BJTXQq)r9LhGoYSd4BJTXQq)r9T1Wiryy3MfSueK8H0or0fHcq3BB6m((26bl6QkwgYo6LlpaDKQoGVn2gRc9h13wdJeHHDBwWsrOHgzOQILHSJEra6EBtNX33wzCSQYidxEa6ip9a(2yBSk0FuFBnmseg2TzblfbTHkscF6kF0C)wqst7uo5Dvoz2TnDgFFBuH0yNMQYQmsE5bOJoKd4BJTXQq)r9T1Wiryy3MfSue0gQij8PR8rZ9BbjnTt5K3v5Kz320z89Tj5dPDIOlcV8a0ra0b8TX2yvO)O(2AyKimSBZcwkcAdvKe(0v(O5(TGKM2PCUkNan6TnDgFFB9GfDvfldzh9YLhGaC0d4BJTXQq)r9T1Wiryy3MfSueAOrgQQyzi7OxeGU320z89Tj5dPjjmCIxEacqGoGVn2gRc9h13wdJeHHDBtNbhS6)uuugnwjdV2PCY7QC64TnDgFF7saXA)CSlpabOJhW320z89T1qJmuvXYq2rVCBSnwf6pQV8aeGa8a(2MoJVVn)O9KegoXBJTXQq)r9LhGaKcpGVTPZ47BtYhstsy4eVn2gRc9h1xEacqMDaFBSnwf6pQVTggjcd72KhuXgTxW5vwgkSsEfhStb2gRc9320z89TlkKmOHwjVD0jcHGU5Tb6YdqasvhW3gBJvH(J6BB6m((2fLrJvYWRDEBnmseg2THybIKbJvH3wpIwH10Glysoab6YdqaYtpGVTPZ47BxmSMqRjfqs89TX2yvO)O(Ydqa6qoGVTPZ47BxGpjRKHx782yBSk0FuF5biabqhW3gBJvH(J6BRHrIWWUnlyPiOnurs4tx5JM73csAANYjVRYjZUTPZ47BRhSORQyzi7OxU8aKch9a(2MoJVVnAWCa7kXnCI3gBJvH(J6lpaPqGoGVTPZ47BJgmhQOcPXon1TX2yvO)O(Ydqk0Xd4BJTXQq)r9T1Wiryy3MfSue8J2xaHJuZprAbePTOjYPdKtao6TnDgFFB(r7lGWrQ5Ni9LxEBpwmqvEaFac0b8TnDgFFBw1)EfijVn2gRc9h7LhGoEaFBSnwf6pQVTggjcd72uuottHDkmIgBV1AuGTXQqVCYOCcTWxroyNcZ7jIOLtExLta0OYjJYP(FL)53cJOX2BTgfqK2IMiNoqobAu5KkYjxUYjfLZ0uyNIHpRdw7fyBSk0lNmkNSGLIG(vj2v(O5(Ta0voPICYLRCYcwkIqpsf9lOa0vo5YvoPOCMMc7uqYhsxuGq4icSnwf6LtgLtwWsrOHM2Pk6LkbeUGcqx5KkYjxUYPhzblfbAWCa7kXnCIcqx5Klx500zWbRyJ0bsKtELtGKtUCLt2NqKtgLZsSmKvisBrtKthiNaC0B7rIggUz89T5zTdL(PzTuoD)m(wodICYILhIYP(PzTuoX2te320z89TD)m((YdqaEaFBSnwf6pQVThjAy4MX33MN1jcHGU5TnDgFFB(r7RKb0GxEasHhW3gBJvH(J6BB6m((25awlbKKvsSeQBRHrIWWUnfLZ0uyNcJOX2BTgfyBSk0lNmkNql8vKd2PW8EIiA5K3v5eanQCYOCQ)x5F(TWiAS9wRrbePTOjYPdKtGgvoPICYLRCsr5mnf2Py4Z6G1Eb2gRc9YjJYjlyPiOFvIDLpAUFlaDLtQiNC5kNSGLIi0Jur)ckaDLtUCLtkkNPPWofK8H0ffieoIaBJvHE5Kr5KfSueAOPDQIEPsaHlOa0voPICYLRC6rwWsrGgmhWUsCdNOa0vo5YvonDgCWk2iDGe5Kx5ei5Klx5SeldzfI0w0e50bYjah92TrJ3ohWAjGKSsILqD5biZoGVn2gRc9h1320z89T1MEaRFPAAEagq0xtiAeqisUTggjcd72SGLIW08amGOVs4)qVa0vo5YvolXYqwHiTfnroDGC6iZUDB04T1MEaRFPAAEagq0xtiAeqisU8aKQoGVn2gRc9h1320z89TjAdsQFPwGwIW2uvscJcEBnmseg2Tba5KfSueeTbj1VulqlryBQkjHrbRuOa0vo5YvolXYqwHiTfnroDGCcqGKtUCLtOf(kYb7uyEpreTC6a5eiQso5YvonDgCWk2iDGe5Kx5eOB3gnEBI2GK6xQfOLiSnvLKWOGxEaYtpGVn2gRc9h1320z89Tty0oXeOBRHrIWWUnaiNCmyySkuKWODIjq1Gu5Jb0FBI6tYTty0oXeOlpaDihW3gBJvH(J6BB6m((2jmANy64T1Wiryy3gaKtogmmwfksy0oX0XAqQ8Xa6Vnr9j52jmANy64LhGaOd4BJTXQq)r9T1Wiryy3gaKZ0uyNcJOX2BTgfyBSk0lNC5kNSGLIWiAS9wRrbORCYLRCQ)x5F(TWiAS9wRrbePTOjYjVYjZg92MoJVVnR6FFTach5YdqGg9a(2yBSk0FuFBnmseg2Tba5mnf2PWiAS9wRrb2gRc9YjxUYjlyPimIgBV1Aua6EBtNX33MfHee6m6LlpabcOd4BJTXQq)r9T1Wiryy3gaKZ0uyNcJOX2BTgfyBSk0lNC5kNSGLIWiAS9wRrbORCYLRCQ)x5F(TWiAS9wRrbePTOjYjVYjZg92MoJVVDjGiR6F)LhGa54b8TX2yvO)O(2AyKimSBdaYzAkStHr0y7TwJcSnwf6LtUCLtwWsryen2ER1Oa0vo5Yvo1)R8p)wyen2ER1OaI0w0e5Kx5KzJEBtNX332AnssOPQAtPU8aeiaEaFBSnwf6pQVTggjcd72aGCMMc7uyen2ER1OaBJvHE5Klx5eaKtwWsryen2ER1Oa092MoJVVnRTu)snHH2j5YdqGOWd4BB6m((2feAQkXnGrEBSnwf6pQV8aeiMDaFBSnwf6pQVTggjcd72uuottHDkmIgBV1AuGTXQqVCYLRCcbBS8Wfu4)NUYpAprG8amCDrVCsf5Kr5KIYj5bvSr7flWNdwJMtS8qlJVfyBSk0lNC5kNKhuXgTxucu5RFPYQEc5PjcSnwf6LtUCLttNbhSInshiroxLtGKtQCBtNX33UyynHwtkGK47lpabIQoGVn2gRc9h13wdJeHHDBOf(kYb7uyEpreTCY7QCcGgvo5YvonDgCWk2iDGe5Kx5eOBB6m((2grJT3AnE5biq80d4BJTXQq)r9TnDgFFB(r7lGWrQ5Ni9T1Wiryy3gc2y5HlOW)pDLF0EIa5by46IE5Kr5KfSue()PR8J2tQEKfSue(NFlNmkNuuoHw4RihStH59er0YjVRYjvnQCYLRCA6m4GvSr6ajYjVYjqYjvKtUCLtwWsrWpAFbeosn)ePf(NFlNmkNuuoba5ec2y5HlOW)pDLF0EIa5by46IE5Klx5KfSue()PR8J2tQEKfSueGUYjvUTkASQ93giMD5biqoKd4BJTXQq)r9T9irdd3m((28SIC(TAe58BuoXgPhHs50fgpmYrKZYRupFICMdOCYCs0lkK5YPPZ4B5ufKuCBtNX33wBkv10z8DvfK82Keg68aeOBRHrIWWUTPZGdwXgPdKiNRYjq3wfKS2gnEBs0lk8YdqGaqhW3gBJvH(J6B7rIggUz89TPAB5KguLHRcLtSr6ajukN5akNUW4HroICwEL65tKZCaLtMBpYC500z8TCQcskUTPZ47BRnLQA6m(UQcsEBscdDEac0T1Wiryy320zWbRyJ0bsKtELtGUTkizTnA822JxEa64OhW320z89T1pyNiKKWWjwZpr6BJTXQq)r9LhGoc0b8TnDgFFBIZrkGWrQ5Ni9TX2yvO)O(YdqhD8a(2MoJVVTlmOnvLKWWjEBSnwf6pQV8YB7cr9tZA5b8biqhW3gBJvH(J6BRHrIWWUnlyPi4hTVachPYhn3VfqK2IMiNoqob4OJEBtNX33MF0(ciCKkF0C)(YdqhpGVn2gRc9h13wdJeHHDBwWsruugnMFVaIv(O5(TaI0w0e50bYjahD0BB6m((2fLrJ53lGyLpAUFF5biapGVTPZ47BZ(zQqFTOSrqp)OxQ57WrFBSnwf6pQV8aKcpGVn2gRc9h13wdJeHHDBwWsrOILHSJEPsgcu5fqK2IMiNoqob4OJEBtNX33wfldzh9sLmeOYF5biZoGVn2gRc9h13wdJeHHD70uyNcs(qANi6Iqb2gRc9320z89Tj5dPDIOlcV8aKQoGVn2gRc9h13wdJeHHDBaqoHGnwE4ck8)tx5hTNiqEagUUOxozuozblfb)O9fq4i18tKw4F(9TnDgFFB(r7lGWrQ5Ni9LhG80d4BJTXQq)r9T1Wiryy3M8Gk2O9cxqscQWkcbDZ4Bb2gRc9YjxUYj5bvSr7fCELLHcRKxXb7uGTXQq)TnDgFF7IcjdAOvYlpaDihW3gBJvH(J6B)U3MG5TnDgFFBogmmwfEBoMceVDcJ2jMIeirqe5awlbKKvsSek5Klx5mHr7etrcKiicI2GK6xQfOLiSnvLKWOGYjxUYzcJ2jMIeirqeAtpG1Vunnpadi6Rjenciej3MJbRTrJ3oHr7etGQbPYhdO)Ydqa0b8TX2yvO)O(2V7TjyEBtNX33MJbdJvH3MJPaXBNWODIPiDueeroG1sajzLelHso5Yvoty0oXuKokcIGOniP(LAbAjcBtvjjmkOCYLRCMWODIPiDueeH20dy9lvtZdWaI(AcrJacrYT5yWAB04Tty0oX0XAqQ8Xa6V8YlVnhesIVpaDCuhDCua6iaVnFd2rVqUnfqQgo0aYZaKcaproLtGhq5mODFykNLhkNm3EK5Yje5byarVCsEAuonW8PTe9YPEW6fKiKJP6rJYjqmJNiN88V5GWe9YjZjpOInAVaaZC5mF5K5KhuXgTxaGfyBSk0ZC5KIo6Wuriht1JgLtaYmEICYZ)Mdct0lNmN8Gk2O9camZLZ8LtMtEqfB0EbawGTXQqpZLtlLtkqQwQUCsrGCyQiKJLJPas1WHgqEgGua4jYPCc8akNbT7dt5S8q5K5KOxuiZLtiYdWaIE5K80OCAG5tBj6Lt9G1liriht1JgLthzgpro55FZbHj6LtMtEqfB0EbaM5Yz(YjZjpOInAVaalW2yvON5YPLYjfivlvxoPiqomveYXu9Or5eGuipro55FZbHj6LtMtEqfB0EbaM5Yz(YjZjpOInAVaalW2yvON5YPLYjfivlvxoPiqomveYXYXuaPA4qdipdqka8e5uobEaLZG29HPCwEOCYCpwmqvYC5eI8amGOxojpnkNgy(0wIE5upy9cseYXu9Or5eiMXtKtE(3CqyIE5K5KhuXgTxaGzUCMVCYCYdQyJ2laWcSnwf6zUCsrhDyQiKJLJPas1WHgqEgGua4jYPCc8akNbT7dt5S8q5K5Uqu)0SwYC5eI8amGOxojpnkNgy(0wIE5upy9cseYXu9Or5KNYtKtE(3CqyIE5K5KhuXgTxaGzUCMVCYCYdQyJ2laWcSnwf6zUCsrGCyQiKJP6rJYjpLNiN88V5GWe9YjZjpOInAVaaZC5mF5K5KhuXgTxaGfyBSk0ZC50s5KcKQLQlNueihMkc5yQE0OC6q4jYjp)BoimrVCY8egTtmfajaWmxoZxozEcJ2jMIeibaM5YjfbOdtfHCmvpAuobq8e5KN)nheMOxozEcJ2jMchfayMlN5lNmpHr7etr6OaaZC5KIa0HPIqowoMNr7(We9YjfkNMoJVLtvqsIqo(2gyo8WBVdAE(TDHFju4TPGuq5KcShSwJ0yNY5EWOTwoMcsbLtQMgupiNoYmkLthh1rhLJLJnDgFteUqu)0SwUYpAFbeosLpAUFtzuwzblfb)O9fq4iv(O5(TaI0w0ehaWrhvo20z8nr4cr9tZAjdRmvugnMFVaIv(O5(nLrzLfSuefLrJ53lGyLpAUFlGiTfnXbaC0rLJnDgFteUqu)0SwYWktSFMk0xlkBe0Zp6LA(oC0YXMoJVjcxiQFAwlzyLjvSmKD0lvYqGkpLrzLfSueQyzi7OxQKHavEbePTOjoaGJoQCSPZ4BIWfI6NM1sgwzIKpK2jIUiKYOSMMc7uqYhs7erxekW2yvOxo20z8nr4cr9tZAjdRmXpAFbeosn)ePPmkRaaeSXYdxqH)F6k)O9ebYdWW1f9mYcwkc(r7lGWrQ5NiTW)8B5ytNX3eHle1pnRLmSYurHKbn0kjLrzL8Gk2O9cxqscQWkcbDZ4BUCjpOInAVGZRSmuyL8koyNYXMoJVjcxiQFAwlzyLjogmmwfszB04AcJ2jMavdsLpgqpLCmfiUMWODIPairqe5awlbKKvsSekUCty0oXuaKiicI2GK6xQfOLiSnvLKWOGC5MWODIPairqeAtpG1Vunnpadi6RjenciejYXMoJVjcxiQFAwlzyLjogmmwfszB04AcJ2jMowdsLpgqpLCmfiUMWODIPWrrqe5awlbKKvsSekUCty0oXu4OiicI2GK6xQfOLiSnvLKWOGC5MWODIPWrrqeAtpG1Vunnpadi6RjenciejYXYXuqkOCsb6WOgmrVCICq4iYzg0OCMdOCA68HYzqKtJJfkJvHc5ytNX3Kvw1)EfijLJPGYjpRDO0pnRLYP7NX3YzqKtwS8quo1pnRLYj2EIqo20z8nHHvMC)m(MYOSsX0uyNcJOX2BTgfyBSk0Zi0cFf5GDkmVNiIM3va0OmQ)x5F(TWiAS9wRrbePTOjoaOrPcxUumnf2Py4Z6G1Eb2gRc9mYcwkc6xLyx5JM73cqxQWLllyPic9iv0VGcqxUCPyAkStbjFiDrbcHJiW2yvONrwWsrOHM2Pk6LkbeUGcqxQWLRhzblfbAWCa7kXnCIcqxUCnDgCWk2iDGeEbIlx2NqySeldzfI0w0ehaWrLJPGYjpRtecbDt5ytNX3egwzIF0(kzanOCSPZ4BcdRmbsWAKinLTrJR5awlbKKvsSekkJYkfttHDkmIgBV1AuGTXQqpJql8vKd2PW8EIiAExbqJYO(FL)53cJOX2BTgfqK2IM4aGgLkC5sX0uyNIHpRdw7fyBSk0ZilyPiOFvIDLpAUFlaDPcxUSGLIi0Jur)ckaD5YLIPPWofK8H0ffieoIaBJvHEgzblfHgAANQOxQeq4ckaDPcxUEKfSueObZbSRe3WjkaD5Y10zWbRyJ0bs4fiUClXYqwHiTfnXbaCu5ytNX3egwzcKG1irAkBJgx1MEaRFPAAEagq0xtiAeqisOmkRSGLIW08amGOVs4)qVa0Ll3sSmKvisBrtCGJmto20z8nHHvMajynsKMY2OXvI2GK6xQfOLiSnvLKWOGugLvaGfSueeTbj1VulqlryBQkjHrbRuOa0Ll3sSmKvisBrtCaabIlxOf(kYb7uyEpreTdaIQ4Y10zWbRyJ0bs4fi5ytNX3egwzcKG1irAcLe1NK1egTtmbIYOScaCmyySkuKWODIjq1Gu5Jb0lhB6m(MWWktGeSgjstOKO(KSMWODIPJugLvaGJbdJvHIegTtmDSgKkFmGE5ytNX3egwzIv9VVwaHJqzuwbG0uyNcJOX2BTgfyBSk0ZLllyPimIgBV1Aua6YLR(FL)53cJOX2BTgfqK2IMWlZgvo20z8nHHvMyribHoJEHYOScaPPWofgrJT3AnkW2yvONlxwWsryen2ER1Oa0vo20z8nHHvMkbezv)7PmkRaqAkStHr0y7TwJcSnwf65YLfSuegrJT3AnkaD5Yv)VY)8BHr0y7TwJcisBrt4LzJkhB6m(MWWktwRrscnvvBkfLrzfastHDkmIgBV1AuGTXQqpxUSGLIWiAS9wRrbOlxU6)v(NFlmIgBV1AuarAlAcVmBu5ytNX3egwzI1wQFPMWq7KqzuwbG0uyNcJOX2BTgfyBSk0ZLlaWcwkcJOX2BTgfGUYXMoJVjmSYubHMQsCdyKYXMoJVjmSYuXWAcTMuajX3ugLvkMMc7uyen2ER1OaBJvHEUCHGnwE4ck8)tx5hTNiqEagUUONkmsrYdQyJ2lwGphSgnNy5HwgFZLl5bvSr7fLav(6xQSQNqEAcxUModoyfBKoqYkquro20z8nHHvMmIgBV1AKYOScTWxroyNcZ7jIO5DfankxUModoyfBKoqcVajhB6m(MWWkt8J2xaHJuZprAkvrJvTFfiMrzuwHGnwE4ck8)tx5hTNiqEagUUONrwWsr4)NUYpApP6rwWsr4F(nJueAHVICWofM3terZ7kvnkxUModoyfBKoqcVarfUCzblfb)O9fq4i18tKw4F(nJueaGGnwE4ck8)tx5hTNiqEagUUONlxwWsr4)NUYpApP6rwWsra6sf5ykOCYZkY53QrKZVr5eBKEekLtxy8WihrolVs98jYzoGYjZjrVOqMlNMoJVLtvqsHCSPZ4BcdRmPnLQA6m(UQcsszB04kj6ffsjjHHoxbIYOSA6m4GvSr6ajRajhtbLtQ2woPbvz4Qq5eBKoqcLYzoGYPlmEyKJiNLxPE(e5mhq5K52JmxonDgFlNQGKc5ytNX3egwzsBkv10z8DvfKKY2OXv7rkjjm05kqugLvtNbhSInshiHxGKJnDgFtyyLj9d2jcjjmCI18tKwo20z8nHHvMiohPachPMFI0YXMoJVjmSYKlmOnvLKWWjkhlhtbPGYjvtqvgYzAWfmLttNX3YPlmEyKJiNQGKYXMoJVjc7Xv9GfDDWGCqsszuwzblfbTHkscF6kF0C)wqst7K3vMjhB6m(MiShzyLjn0idvvSmKD0lugLviyJLhUGc))0v(r7jcKhGHRl6zKfSue()PR8J2teGUYXMoJVjc7rgwzIa2Eeg9cLrzfc2y5HlOW)pDLF0EIa5by46IEgzblfH)F6k)O9ebORCSPZ4BIWEKHvMgqtf9sLKq0OR5NinLrzfc2y5HlOaAlrVu5Gexew58WeDybYdWW1f9mMMc7uGgmhQKHavEb2gRc9mYbjUiSMFI01b0uv9GbxqcVJkhB6m(MiShzyLj0G5qLmeOYtzuwHGnwE4ckG2s0lvoiXfHvopmrhwG8amCDrpJPPWofObZHkziqLxGTXQqpJCqIlcR5NiDDanvvpyWfKW7OYXMoJVjc7rgwzQeqS2phJYOSA6m4Gv)NIIYOXkz41o5DLQ4YLIModoy1)POOmASsgETtExPqgnDgCWQ)trrz0yLm8AN8UQhrRWk2iDGeQihB6m(MiShzyLjxyq)qFyQkFJdsPEeTcRPbxWKSceLrzfayblfHlmOFOpmvLVXbfGUYXMoJVjc7rgwzIF0EscdNiLrzfc2y5HlOWJORAKk8)e9vuH0yNebYdWW1f9mYcwkcn0idvvSmKD0lcqx5ytNX3eH9idRmrYhstsy4ePmkRqWglpCbfEeDvJuH)NOVIkKg7KiqEagUUONrwWsrOHgzOQILHSJEra6khB6m(MiShzyLjLXXQkJmqPEeTcRPbxWKSceLrz1)POOmASsgETtrgANrVWifnDgCWQ)trrz0yLm8ANoqpIwHvSr6ajmA6m4Gv)NIIYOXkz41oDavrf5ytNX3eH9idRmvugnwjdV2jLrzfaYq7m6f5ytNX3eH9idRmvugnwjdV2jL6r0kSMgCbtYkqugLvainf2PyWcfjFiTaBJvHEgnDgCWQ)trrz0yLm8ANoqpIwHvSr6ajmA6m4Gv)NIIYOXkz41oDavjhB6m(MiShzyLjvSmKD0lv2xLugLvkA6m4Gv)NIIYOXkz41o5DvpIwHvSr6ajC5A6m4Gv)NIIYOXkz41o5DLcPcJSGLIWfg0p0hMQY34GcqxgzblfbTHkscF6kF0C)wqst7K3vMXifbawWsrqCvrNie9vuH0yNebOlxULyziRqK2IM4GvGCKlxOf(kYb7uyEprarAlAIdwx0EQihB6m(MiShzyLPc8jzLm8ANugLvwWsrmyHIKpKwa6khB6m(MiShzyLPIH1eAnPasIVPmkRKhuXgTxSaFoynAoXYdTm(MlxYdQyJ2lkbQ81VuzvpH80eUCHGnwE4ckii6j1VuHgTR1zDb(8ZbbYdWW1f9YXMoJVjc7rgwzsdnYqvfldzh9cLrzLfSueAOrgQQyzi7Oxe(NFZilyPiCHb9d9HPQ8noOa0LrwWsrqBOIKWNUYhn3VfK00oDaZKJnDgFte2JmSYebS9im6fkJYklyPiCHb9d9HPQ8noOa0LrwWsrqBOIKWNUYhn3VfK00oDaZKJnDgFte2JmSYejFinjHHtKYOSYcwkcxyq)qFyQkFJdkaDzKfSue0gQij8PR8rZ9BbjnTthWm5ytNX3eH9idRmraBpcJEro20z8nrypYWktLaI1(5yugLvtNbhS6)uuugnwjdV2jVRuOCSPZ4BIWEKHvM0qJmuvXYq2rVqzuwttHDk0qJme9sLKpKwGTXQqpxUSGLIqdnYqvfldzh9IW)8B5ytNX3eH9idRmPmowvzKbk1JOvynn4cMKvGOmkRPPWofkJme9sTOmAKiW2yvOxo20z8nrypYWktLaI1(5yugLvtNbhS6)uuugnwjdV2jVRauo20z8nrypYWktCqIlcR5NiTCSPZ4BIWEKHvM0dw0vvSmKD0lugLvwWsrqYhs7erxekaDLJnDgFte2JmSYKY4yvLrgOmkRSGLIqdnYqvfldzh9Ia0vo20z8nrypYWktOcPXonvLvzKKYOSYcwkcAdvKe(0v(O5(TGKM2jVRmto20z8nrypYWktK8H0or0fHugLvwWsrqBOIKWNUYhn3VfK00o5DLzYXMoJVjc7rgwzspyrxvXYq2rVqzuwzblfbTHkscF6kF0C)wqst7CfOrLJnDgFte2JmSYejFinjHHtKYOSYcwkcn0idvvSmKD0lcqx5ytNX3eH9idRmvciw7NJrzuwnDgCWQ)trrz0yLm8AN8U6OCSPZ4BIWEKHvM0qJmuvXYq2rVihB6m(MiShzyLj(r7jjmCIYXMoJVjc7rgwzIKpKMKWWjkhB6m(MiShzyLPIcjdAOvskJorie0nxbIYOSsEqfB0EbNxzzOWk5vCWoLJnDgFte2JmSYurz0yLm8ANuQhrRWAAWfmjRarzuwHybIKbJvHYXMoJVjc7rgwzQyynHwtkGK4B5ytNX3eH9idRmvGpjRKHx7uo20z8nrypYWkt6bl6QkwgYo6fkJYklyPiOnurs4tx5JM73csAAN8UYm5ytNX3eH9idRmHgmhWUsCdNOCSPZ4BIWEKHvMqdMdvuH0yNMso20z8nrypYWkt8J2xaHJuZprAkJYklyPi4hTVachPMFI0cisBrtCaahvowoMcsbLZD0lkuotdUGPCA6m(woDHXdJCe5ufKuo20z8nrqIErHR8J2tsy4eLJnDgFteKOxuidRmPmowvzKbkJYklyPig(SoyTxa6YLlfHGnwE4ckCHbTPQkJJvnDcA5djcKhGHRl6zKfSueUWG2uvLXXQMobT8HebjnTtEPkQihB6m(MiirVOqgwzIF0(ciCKA(jstzuwbawWsrWpAFbeosn)ePfGUYXMoJVjcs0lkKHvMi5dPjjmCIugLviyJLhUGc))0v(r7jcKhGHRl6zKfSue()PR8J2teGUYXMoJVjcs0lkKHvM0qJmuvXYq2rVqzuwHGnwE4ck8)tx5hTNiqEagUUONrwWsr4)NUYpApra6khB6m(MiirVOqgwzk0yLKWWjszuwHGnwE4ck8)tx5hTNiqEagUUONrwWsr4)NUYpApra6khB6m(MiirVOqgwzIa2Eeg9cLrzfc2y5HlOW)pDLF0EIa5by46IEgzblfH)F6k)O9ebORCSPZ4BIGe9IczyLjxyq)qFyQkFJdszuwzblfHlmOFOpmvLVXbf(NFZifHw4RihStH59er08sHoYLl0cFf5GDkmVNiI2bufvKJnDgFteKOxuidRmvugnwjdV2jLrzfaYq7m6f5ytNX3ebj6ffYWktQyzi7OxQSVkPmkRSGLIG2qfjHpDLpAUFliPPDY7kZyKfSueUWG(H(Wuv(ghua6Yi0cFf5GDkmVNiIMxwWsr4cd6h6dtv5BCqbePTOjmsraGfSueexv0jcrFfvin2jra6YLBjwgYkePTOjoyfihPICSPZ4BIGe9IczyLjoiXfH18tKMYOScTWxroyNcZ7jIO5Lchvo20z8nrqIErHmSYub(KSsgETtkJYklyPigSqrYhslaDLJnDgFteKOxuidRmHgmhWUsCdNOCSPZ4BIGe9IczyLjLXXQkJmqzuw9FkkkJgRKHx7uaXcejdgRcLJnDgFteKOxuidRmvmSMqRjfqs8nLrzfaGGnwE4ckii6j1VuHgTR1zDb(8ZbbYdWW1f9C5Q)x5F(TOGqtvjUbmsbePTOj8cWrLJnDgFteKOxuidRmrYhstsy4ePmkRPPWofK8H0ffieoIaBJvHEgzblfbjFinlm6fekaDLJnDgFteKOxuidRmPhSORQyzi7OxOmkRSGLIGKpK2jIUiua6khB6m(MiirVOqgwzcvin2PPQSkJKugLvwWsrqBOIKWNUYhn3VfK00o5DLzYXMoJVjcs0lkKHvMgqtf9sLKq0OR5NinLrzfc2y5HlOaAlrVu5Gexew58WeDybYdWW1f9mMMc7uGgmhQKHavEb2gRc9msroiXfH18tKUoGMQQhm4cs4fiUCPihK4IWA(jsxhqtv1dgCbj8okJql8vKd2PW8EIiAEPilyPi4GexewZprAbePTOjouaKkuHkYXMoJVjcs0lkKHvMqdMdvYqGkpLrzfc2y5HlOaAlrVu5Gexew58WeDybYdWW1f9mMMc7uGgmhQKHavEb2gRc9msroiXfH18tKUoGMQQhm4cs4fiUCPihK4IWA(jsxhqtv1dgCbj8okJql8vKd2PW8EIiAEPilyPi4GexewZprAbePTOjouaKkuHkYXMoJVjcs0lkKHvM0dw01bdYbjjLrzLfSue0gQij8PR8rZ9BbjnTtExzgJql8vKd2PW8EIiAExbqJkhB6m(MiirVOqgwzsfldzh9sL9vjLrzLfSue0gQij8PR8rZ9BbjnTZvGgLrwWsr4cd6h6dtv5BCqH)53YXMoJVjcs0lkKHvMi5dPjjmCIYXMoJVjcs0lkKHvMi5dPDIOlcPmkRSGLIG2qfjHpDLpAUFliPPDY7kZKJnDgFteKOxuidRmvuizqdTssz0jcHGU5kqugLvYdQyJ2l48kldfwjVId2PCSPZ4BIGe9IczyLj(r7lGWrQ5NinLrzLfSue8J2xaHJuZprAbePTOjoaOrLJnDgFteKOxuidRmPmowvzKb5ytNX3ebj6ffYWktQyzi7OxQSVkPmkRSGLIG2qfjHpDLpAUFliPPDY7kZyKfSueUWG(H(Wuv(ghu4F(TCSPZ4BIGe9IczyLjcy7ry0lugLvOf(kYb7uyEprenVRu4OYXMoJVjcs0lkKHvMkWNKvYWRDkhB6m(MiirVOqgwzsdnYqvfldzh9ICSPZ4BIGe9IczyLPqJvscdNOCSPZ4BIGe9IczyLPsaXA)CmkJYQPZGdw9FkkkJgRKHx7uo20z8nrqIErHmSYurHKbn0kjLrzL8Gk2O9cxqscQWkcbDZ4B5ytNX3ebj6ffYWktObZHkQqASttjhB6m(MiirVOqgwzQOmASsgETtkJYkbZm6fIOekfcRKHx7uo20z8nrqIErHmSYe)O9fq4i18tKMYOSYcwkc(r7lGWrQ5NiTaI0w0ehaWrV8Y7a]] )


end
