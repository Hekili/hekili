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

    spec:RegisterEvent( "COMBAT_LOG_EVENT_UNFILTERED", function()
        local _, subtype, _,  sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName = CombatLogGetCurrentEventInfo()

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


    spec:RegisterPack( "Enhancement", 20220323, [[dueUxbqifu9iKqSjuuFcfYOqr6uOiEfsQzHeDlbsYUi8luWWuGogGAzcuptbzAibDnuO2gQK8nKanobsCofuSoKqzEce3tPAFOsDqKqIfIK8qujvxejG(isaCsujLvcGzIeQUjsiPDcq)ejKAPcKupvrtfq(ksaASkO0Ev5VsmyLCyklgLEmrtwOldTzj9zLYOvOtt1RfWSj52i1UL63QA4c64OsSCqphX0fDDG2oQ47OkJxGuNxbmFuv7NuFaFaDZOL4byWdgCWdouWdjcEOHOGdn0nZbcXBgAYa2gEZ2OXBsb2JwlrASZBgAdOElEaDtYdcL4nNonx)MSGUk5A9XEZOL4byWdgCWdouWdjcEOHOGdf8njHO8amyUAOBo6Xi2h7nJirEtkWE0AjsJDQxZrJ2AnauunOCuVcEik1RGhm4GVPYjj5a6MeV3u4b0biWhq30KP)9n55DKKqpaEtSnwfgpQU8am4dOBITXQW4r1nLqprOB3KfSwfJFwgTokad1l(81lMQxqWgRpCdfHqN2ufLXXkMmbT8HebYfqpmeJ6fZ6flyTkcHoTPkkJJvmzcA5djcsAYa6f36fxPxm5MMm9VVPY4yfLrgV8aCOdOBITXQW4r1nLqprOB3C46flyTk45DScchOKFI0cWWBAY0)(M88owbHduYpr6lpaPWdOBITXQW4r1nLqprOB3ec2y9HBOi(pDHN3rIa5cOhgIr9Iz9IfSwfX)Pl88oseGH30KP)9nj5dPjj0dGxEaY4dOBITXQW4r1nLqprOB3ec2y9HBOi(pDHN3rIa5cOhgIr9Iz9IfSwfX)Pl88oseGH30KP)9nLqJmwu(2y2EVD5bixDaDtSnwfgpQUPe6jcD7MqWgRpCdfX)Pl88oseixa9WqmQxmRxSG1Qi(pDHN3rIam8MMm9VVPlXcjHEa8Ydqk4b0nX2yvy8O6MsONi0TBcbBS(Wnue)NUWZ7irGCb0ddXOEXSEXcwRI4)0fEEhjcWWBAY0)(MeWoIqV3U8amOCaDtSnwfgpQUPe6jcD7MSG1Qie60pm6MQWZ4GI4ZR1lM1lMQxqZJfKd2PWIrIWB9IB9IcdwV4ZxVGMhlihStHfJeH36vq0lUsVyYnnz6FFZqOt)WOBQcpJdE5b4WCaDtSnwfgpQUPe6jcD7MdxVsxgW7TBAY0)(MvLrJfY4ldC5biWdEaDtSnwfgpQUPe6jcD7MSG1QG2qfjHpDHhAHFliPjdOxCVRxmwVywVybRvri0PFy0nvHNXbfGH6fZ6f08yb5GDkSyKi8wV4wVybRvri0PFy0nvHNXbfqK28MCttM(33u5BJz79wH9v5LhGad8b0nX2yvy8O6MsONi0TBcnpwqoyNclgjcV1lU1lkCWBAY0)(MCqsicl5Ni9LhGah8b0nX2yvy8O6MsONi0TBYcwRIrZvK8H0cWWBAY0)(Mv4tYcz8LbU8ae4HoGUPjt)7BIgmhXUqc9a4nX2yvy8O6YdqGPWdOBITXQW4r1nLqprOB3m(POQmASqgFzabeRqKmASk8MMm9VVPY4yfLrgV8aeygFaDtSnwfgpQUPe6jcD7MdxVGGnwF4gkiigjLVwGgDO1zzd(8YrbYfqpmeJ6fF(6L8Fv851IkcnvHe6qpfqK28MOxCRxdn4nnz6FFZQHLeAnPcs8VV8aeyU6a6MyBSkmEuDtj0te62nttHDki5dPRkqiCab2gRcJ6fZ6flyTki5dPzHEVHqby4nnz6FFts(qAsc9a4LhGatbpGUj2gRcJhv3uc9eHUDtwWAvqYhshaXqekadVPjt)7BkhnVlkFBmBV3U8ae4GYb0nX2yvy8O6MsONi0TBYcwRcAdvKe(0fEOf(TGKMmGEX9UEX4BAY0)(MOcPXonvHvzK8YdqGhMdOBITXQW4r1nLqprOB3ec2y9HBOaABEVv4GKqew48WedAbYfqpmeJ6fZ6vAkStbAWCSqgDuffyBSkmQxmRxmvV4GKqewYpr6YiAQIC0GBirV4wVawV4ZxVyQEXbjHiSKFI0Lr0uf5Ob3qIEXTEnOEXSEbnpwqoyNclgjcV1lU1lMQxSG1QGdscryj)ePfqK28MOxbv61q6ft0lMOxm5MMm9VV5iAkV3kKeIgDj)ePV8am4bpGUj2gRcJhv3uc9eHUDtiyJ1hUHcOT59wHdscryHZdtmOfixa9WqmQxmRxPPWofObZXcz0rvuGTXQWOEXSEXu9Idscryj)ePlJOPkYrdUHe9IB9cy9IpF9IP6fhKeIWs(jsxgrtvKJgCdj6f361G6fZ6f08yb5GDkSyKi8wV4wVyQEXcwRcoijeHL8tKwarAZBIEfuPxdPxmrVyIEXKBAY0)(MObZXcz0rv8YdWGb(a6MyBSkmEuDtj0te62nzbRvbTHkscF6cp0c)wqstgqV4ExVySEXSEbnpwqoyNclgjcV1lU31RHzWBAY0)(MYrZ7YOb5GK8YdWGd(a6MyBSkmEuDtj0te62nzbRvbTHkscF6cp0c)wqstgqV21lGhuVywVybRvri0PFy0nvHNXbfXNxFttM(33u5BJz79wH9v5LhGbp0b0nnz6FFts(qAsc9a4nX2yvy8O6YdWGPWdOBITXQW4r1nLqprOB3KfSwf0gQij8Pl8ql8Bbjnza9I7D9IX30KP)9nj5dPdGyicV8amygFaDtSnwfgpQUPe6jcD7MKhuX6DuW5vw6kSqEfhStb2gRcJ30KP)9nRkKmkHwnVP3jcHGH5nb(YdWG5QdOBITXQW4r1nLqprOB3KfSwf88owbHduYprAbePnVj6vq0lGh8MMm9VVjpVJvq4aL8tK(YdWGPGhq30KP)9nvghROmY4nX2yvy8O6YdWGdkhq3eBJvHXJQBkHEIq3UjlyTkOnurs4tx4Hw43csAYa6f376fJ1lM1lwWAvecD6hgDtv4zCqr85130KP)9nv(2y2EVvyFvE5byWdZb0nX2yvy8O6MsONi0TBcnpwqoyNclgjcV1lU31lkCWBAY0)(MeWoIqV3U8aCObpGUPjt)7BwHpjlKXxg4MyBSkmEuD5b4qaFaDttM(33ucnYyr5BJz792nX2yvy8O6YdWHc(a6MMm9VVPlXcjHEa8MyBSkmEuD5b4qdDaDtSnwfgpQUPe6jcD7MMmDoyj(POQmASqgFzGBAY0)(MvhIL(5yxEaoefEaDtSnwfgpQUPe6jcD7MKhuX6Duecssqfwqiyy6FlW2yvy8MMm9VVzvHKrj0Q5LhGdX4dOBAY0)(MObZXcQqASttDtSnwfgpQU8aCiU6a6MyBSkmEuDtj0te62njyMEVrevxPqyHm(Ya30KP)9nRkJglKXxg4YdWHOGhq3eBJvHXJQBkHEIq3UjlyTk45DScchOKFI0cisBEt0RGOxdn4nnz6FFtEEhRGWbk5Ni9LxEt7XdOdqGpGUj2gRcJhv3uc9eHUDtwWAvqBOIKWNUWdTWVfK0Kb0lU31lgFttM(33uoAExgnihKKxEag8b0nX2yvy8O6MsONi0TBcbBS(Wnue)NUWZ7irGCb0ddXOEXSEXcwRI4)0fEEhjcWWBAY0)(MsOrglkFBmBV3U8aCOdOBITXQW4r1nLqprOB3ec2y9HBOi(pDHN3rIa5cOhgIr9Iz9IfSwfX)Pl88oseGH30KP)9njGDeHEVD5bifEaDtSnwfgpQUPe6jcD7MqWgRpCdfqBZ7TchKeIWcNhMyqlqUa6HHyuVywVstHDkqdMJfYOJQOaBJvHr9Iz9Idscryj)ePlJOPkYrdUHe9IB9AWBAY0)(MJOP8ERqsiA0L8tK(YdqgFaDtSnwfgpQUPe6jcD7MqWgRpCdfqBZ7TchKeIWcNhMyqlqUa6HHyuVywVstHDkqdMJfYOJQOaBJvHr9Iz9Idscryj)ePlJOPkYrdUHe9IB9AWBAY0)(MObZXcz0rv8YdqU6a6MyBSkmEuDtj0te62nnz6CWs8trvz0yHm(Ya6f376fxPx85RxmvVmz6CWs8trvz0yHm(Ya6f376ffQxmRxMmDoyj(POQmASqgFza9I7D9soGuHfSrAhj6ftUPjt)7BwDiw6NJD5bif8a6MyBSkmEuDttM(33me60pm6MQWZ4G3uc9eHUDZHRxSG1Qie60pm6MQWZ4GcWWBkhqQWsAWnmjhGaF5byq5a6MyBSkmEuDtj0te62nHGnwF4gkIigQgOa)pXybvin2jrGCb0ddXOEXSEXcwRcj0iJfLVnMT3BcWWBAY0)(M88ossOhaV8aCyoGUj2gRcJhv3uc9eHUDtiyJ1hUHIiIHQbkW)tmwqfsJDseixa9WqmQxmRxSG1QqcnYyr5BJz79Mam8MMm9VVjjFinjHEa8YdqGh8a6MyBSkmEuDttM(33uzCSIYiJ3uc9eHUDZ4NIQYOXcz8LbePld49MEXSEXu9YKPZblXpfvLrJfY4ldOxbrVKdivybBK2rIEXSEzY05GL4NIQYOXcz8Lb0RGOxCLEXKBkhqQWsAWnmjhGaF5biWaFaDtSnwfgpQUPe6jcD7MdxVsxgW7TBAY0)(MvLrJfY4ldC5biWbFaDtSnwfgpQUPjt)7BwvgnwiJVmWnLqprOB3C46vAkStXO5ks(qAb2gRcJ6fZ6LjtNdwIFkQkJglKXxgqVcIEjhqQWc2iTJe9Iz9YKPZblXpfvLrJfY4ldOxbrV4QBkhqQWsAWnmjhGaF5biWdDaDtSnwfgpQUPe6jcD7MmvVmz6CWs8trvz0yHm(Ya6f376LCaPclyJ0os0l(81ltMohSe)uuvgnwiJVmGEX9UErH6ft0lM1lwWAvecD6hgDtv4zCqbyOEXSEXcwRcAdvKe(0fEOf(TGKMmGEX9UEX4BAY0)(MkFBmBV3kSVkV8aeyk8a6MyBSkmEuDtj0te62nzbRvXO5ks(qAby4nnz6FFZk8jzHm(YaxEacmJpGUj2gRcJhv3uc9eHUDtYdQy9ok2GphS4nhF7Hw6FlW2yvyuV4ZxVipOI17OO6Okw(AHv9eYtteyBSkmQx85RxqWgRpCdfeeJKYxlqJo06SSbFE5Oa5cOhgIXBAY0)(Mvdlj0AsfK4FF5biWC1b0nX2yvy8O6MsONi0TBYcwRcj0iJfLVnMT3BI4ZR1lM1lwWAvecD6hgDtv4zCqbyOEXSEXcwRcAdvKe(0fEOf(TGKMmGEfe9IX30KP)9nLqJmwu(2y2EVD5biWuWdOBITXQW4r1nLqprOB3KfSwfHqN(Hr3ufEghuagQxmRxSG1QG2qfjHpDHhAHFliPjdOxbrVy8nnz6FFtcyhrO3BxEacCq5a6MyBSkmEuDtj0te62nzbRvri0PFy0nvHNXbfGH6fZ6flyTkOnurs4tx4Hw43csAYa6vq0lgFttM(33KKpKMKqpaE5biWdZb0nnz6FFtcyhrO3B3eBJvHXJQlpadEWdOBITXQW4r1nLqprOB30KPZblXpfvLrJfY4ldOxCVRxu4nnz6FFZQdXs)CSlpadg4dOBITXQW4r1nLqprOB3mnf2PqcnYO3Bfs(qAb2gRcJ6fF(6flyTkKqJmwu(2y2EVjIpV(MMm9VVPeAKXIY3gZ27Tlpado4dOBITXQW4r1nnz6FFtLXXkkJmEtj0te62nttHDkugz07Tsvz0irGTXQW4nLdivyjn4gMKdqGV8am4HoGUj2gRcJhv3uc9eHUDttMohSe)uuvgnwiJVmGEX9UEn0nnz6FFZQdXs)CSlpadMcpGUPjt)7BYbjHiSKFI03eBJvHXJQlpadMXhq3eBJvHXJQBkHEIq3UjlyTki5dPdGyicfGH30KP)9nLJM3fLVnMT3BxEagmxDaDtSnwfgpQUPe6jcD7MSG1QqcnYyr5BJz79Mam8MMm9VVPY4yfLrgV8amyk4b0nX2yvy8O6MsONi0TBYcwRcAdvKe(0fEOf(TGKMmGEX9UEX4BAY0)(MOcPXonvHvzK8YdWGdkhq3eBJvHXJQBkHEIq3UjlyTkOnurs4tx4Hw43csAYa6f376fJVPjt)7BsYhshaXqeE5byWdZb0nX2yvy8O6MsONi0TBYcwRcAdvKe(0fEOf(TGKMmGETRxap4nnz6FFt5O5Dr5BJz792LhGdn4b0nX2yvy8O6MsONi0TBYcwRcj0iJfLVnMT3BcWWBAY0)(MK8H0Ke6bWlpahc4dOBITXQW4r1nLqprOB30KPZblXpfvLrJfY4ldOxCVRxbFttM(33S6qS0ph7YdWHc(a6MMm9VVPeAKXIY3gZ27TBITXQW4r1LhGdn0b0nnz6FFtEEhjj0dG3eBJvHXJQlpahIcpGUPjt)7BsYhstsOhaVj2gRcJhvxEaoeJpGUj2gRcJhv3uc9eHUDtYdQy9ok48klDfwiVId2PaBJvHXBAY0)(MvfsgLqRM307eHqWW8MaF5b4qC1b0nX2yvy8O6MMm9VVzvz0yHm(Ya3uc9eHUDtiwHiz0yv4nLdivyjn4gMKdqGV8aCik4b0nnz6FFZQHLeAnPcs8VVj2gRcJhvxEaouq5a6MMm9VVzf(KSqgFzGBITXQW4r1LhGdnmhq3eBJvHXJQBkHEIq3UjlyTkOnurs4tx4Hw43csAYa6f376fJVPjt)7BkhnVlkFBmBV3U8aKch8a6MMm9VVjAWCe7cj0dG3eBJvHXJQlpaPqGpGUPjt)7BIgmhlOcPXon1nX2yvy8O6Ydqkm4dOBITXQW4r1nLqprOB3KfSwf88owbHduYprAbePnVj6vq0RHg8MMm9VVjpVJvq4aL8tK(YlVzeRgOkpGoab(a6MMm9VVjR6)OcKK3eBJvHXJ9YdWGpGUj2gRcJhv3uc9eHUDtMQxPPWofgrID0AjkW2yvyuVywVGMhlihStHfJeH36f3761WmOEXSEj)xfFETWisSJwlrbePnVj6vq0lGhuVyIEXNVEXu9knf2Py8ZYO1rb2gRcJ6fZ6flyTkOFvIDHhAHFlad1lMOx85RxSG1QWLduW4gkad1l(81lMQxPPWofK8H0vfieoGaBJvHr9Iz9IfSwfsOjdO8ERqaHBOamuVyIEXNVEfrwWAvGgmhXUqc9aOamuV4ZxVmz6CWc2iTJe9IB9cy9IpF9I9je9Iz9Q6BJzbI0M3e9ki61qdEZisKqpm9VVjxRdQKpnRL6v4N(36Lt0lwS(quVKpnRL6f2rI4MMm9VVz4N(3xEao0b0nX2yvy8O6MrKiHEy6FFtUwNiecgM30KP)9n55DSqgrdE5bifEaDtSnwfgpQUPjt)7BMJyP6qswi(MRUPe6jcD7MmvVstHDkmIe7O1suGTXQWOEXSEbnpwqoyNclgjcV1lU31RHzq9Iz9s(Vk(8AHrKyhTwIcisBEt0RGOxapOEXe9IpF9IP6vAkStX4NLrRJcSnwfg1lM1lwWAvq)Qe7cp0c)wagQxmrV4ZxVybRvHlhOGXnuagQx85RxmvVstHDki5dPRkqiCab2gRcJ6fZ6flyTkKqtgq59wHac3qbyOEXe9IpF9kISG1QanyoIDHe6bqbyOEXNVEzY05GfSrAhj6f36fW6fF(6v13gZcePnVj6vq0RHg8MTrJ3mhXs1HKSq8nxD5biJpGUj2gRcJhv30KP)9nLMCelFTysUa6qmwsiAeqisUPe6jcD7MSG1QWKCb0HySq49WOamuV4ZxVQ(2ywGiT5nrVcIEfmJVzB04nLMCelFTysUa6qmwsiAeqisU8aKRoGUj2gRcJhv30KP)9njsdskFTuHwIW2ufsc9kEtj0te62nhUEXcwRcI0GKYxlvOLiSnvHKqVIfkuagQx85RxvFBmlqK28MOxbrVgcy9IpF9cAESGCWofwmseERxbrVaMR0l(81ltMohSGns7irV4wVa(MTrJ3KiniP81sfAjcBtvij0R4LhGuWdOBITXQW4r1nnz6FFZe6Damb(MsONi0TBoC9IJbDJvHIe6DambU4Kcp0HXBsuFsUzc9oaMaF5byq5a6MyBSkmEuDttM(33mHEhaZGVPe6jcD7MdxV4yq3yvOiHEhaZGloPWdDy8Me1NKBMqVdGzWxEaomhq3eBJvHXJQBkHEIq3U5W1R0uyNcJiXoATefyBSkmQx85RxSG1QWisSJwlrbyOEXNVEj)xfFETWisSJwlrbePnVj6f36fJh8MMm9VVjR6)yPcch4YdqGh8a6MyBSkmEuDtj0te62nhUELMc7uyej2rRLOaBJvHr9IpF9IfSwfgrID0AjkadVPjt)7BYIqccd492LhGad8b0nX2yvy8O6MsONi0TBoC9knf2PWisSJwlrb2gRcJ6fF(6flyTkmIe7O1suagQx85RxY)vXNxlmIe7O1suarAZBIEXTEX4bVPjt)7BwDiYQ(pE5biWbFaDtSnwfgpQUPe6jcD7MdxVstHDkmIe7O1suGTXQWOEXNVEXcwRcJiXoATefGH6fF(6L8Fv851cJiXoATefqK28MOxCRxmEWBAY0)(MwlrscnvrAk1LhGap0b0nX2yvy8O6MsONi0TBoC9knf2PWisSJwlrb2gRcJ6fF(61W1lwWAvyej2rRLOam8MMm9VVjRTv(AjHUma5YdqGPWdOBAY0)(MveAQcj0HEEtSnwfgpQU8aeygFaDtSnwfgpQUPe6jcD7MmvVstHDkmIe7O1suGTXQWOEXNVEbbBS(Wnue)NUWZ7irGCb0ddXOEXe9Iz9IP6f5bvSEhfBWNdw8MJV9ql9VfyBSkmQx85RxKhuX6DuuDuflFTWQEc5PjcSnwfg1l(81ltMohSGns7irV21lG1lMCttM(33SAyjHwtQGe)7lpabMRoGUj2gRcJhv3uc9eHUDtO5XcYb7uyXir4TEX9UEnmdQx85RxMmDoybBK2rIEXTEb8nnz6FFtJiXoATeV8aeyk4b0nX2yvy8O6MMm9VVjpVJvq4aL8tK(MsONi0TBcbBS(Wnue)NUWZ7irGCb0ddXOEXSEXcwRI4)0fEEhjLiYcwRI4ZR1lM1lMQxqZJfKd2PWIrIWB9I7D9IRguV4ZxVmz6CWc2iTJe9IB9cy9Ij6fF(6flyTk45DScchOKFI0I4ZR1lM1lMQxdxVGGnwF4gkI)tx45DKiqUa6HHyuV4ZxVybRvr8F6cpVJKsezbRvbyOEXKBQ8glY4nbMXxEacCq5a6MyBSkmEuDZisKqpm9VVjxRQxFRgqV(g1lSr6bOuVcH(d9Ca9Q(k1ZJOx5iQxmI49MczKEzY0)wVuojf30KP)9nLMsvmz6FxuojVjjHUmpab(MsONi0TBAY05GfSrAhj61UEb8nvojlTrJ3K49McV8ae4H5a6MyBSkmEuDZisKqpm9VVjfDRx0GQ0dvOEHns7iHs9khr9ke6p0Zb0R6RuppIELJOEXi7rgPxMm9V1lLtsXnnz6FFtPPuftM(3fLtYBssOlZdqGVPe6jcD7MMmDoybBK2rIEXTEb8nvojlTrJ30E8YdWGh8a6MMm9VVP8b7eHKe6bWs(jsFtSnwfgpQU8amyGpGUPjt)7Bscmqfeoqj)ePVj2gRcJhvxEagCWhq30KP)9ndHoTPkKe6bWBITXQW4r1LxEZqikFAwlpGoab(a6MyBSkmEuDtj0te62nzbRvbpVJvq4afEOf(TaI0M3e9ki61qdo4nnz6FFtEEhRGWbk8ql87lpad(a6MyBSkmEuDtj0te62nzbRvrvz0y(9giw4Hw43cisBEt0RGOxdn4G30KP)9nRkJgZV3aXcp0c)(YdWHoGUPjt)7BY(zQWyPQSbWipV3k5h0EFtSnwfgpQU8aKcpGUj2gRcJhv3uc9eHUDtwWAvO8TXS9ERqgDuffqK28MOxbrVgAWbVPjt)7BQ8TXS9ERqgDufV8aKXhq3eBJvHXJQBkHEIq3UzAkStbjFiDaedrOaBJvHXBAY0)(MK8H0bqmeHxEaYvhq3eBJvHXJQBkHEIq3U5W1liyJ1hUHI4)0fEEhjcKlGEyig1lM1lwWAvWZ7yfeoqj)ePfXNxFttM(33KN3XkiCGs(jsF5bif8a6MyBSkmEuDtj0te62njpOI17OieKKGkSGqWW0)wGTXQWOEXNVErEqfR3rbNxzPRWc5vCWofyBSkmEttM(33SQqYOeA18YdWGYb0nX2yvy8O6MF4njyEttM(33KJbDJvH3KJPaXBMqVdGPibw4eroILQdjzH4BUsV4ZxVsO3bWuKalCIGiniP81sfAjcBtvij0ROEXNVELqVdGPibw4eH0KJy5RftYfqhIXscrJacrYn5yWsB04ntO3bWe4Itk8qhgV8aCyoGUj2gRcJhv38dVjbZBAY0)(MCmOBSk8MCmfiEZe6DamfzWcNiYrSuDijleFZv6fF(6vc9oaMImyHteePbjLVwQqlryBQcjHEf1l(81Re6DamfzWcNiKMCelFTysUa6qmwsiAeqisUjhdwAJgVzc9oaMbxCsHh6W4LxE5n5GqI)9byWdgCWdoeWm(M8my79g5MuaPOeudixdqkaum9sVaAe1lNo8HPEvFOEXi7rgPxqKlGoeJ6f5Pr9YaZN2smQxYrR3qIqdaf3BuVaMXum9IR)nheMyuVye5bvSEhfdlJ0R81lgrEqfR3rXWkW2yvyKr6ftdoOzIqdaf3BuVgIXum9IR)nheMyuVye5bvSEhfdlJ0R81lgrEqfR3rXWkW2yvyKr6LL6ffifnfxVykWbnteAa0aqbKIsqnGCnaPaqX0l9cOruVC6WhM6v9H6fJiEVPqgPxqKlGoeJ6f5Pr9YaZN2smQxYrR3qIqdaf3BuVcMXum9IR)nheMyuVye5bvSEhfdlJ0R81lgrEqfR3rXWkW2yvyKr6LL6ffifnfxVykWbnteAaO4EJ61quiftV46FZbHjg1lgrEqfR3rXWYi9kF9IrKhuX6DumScSnwfgzKEzPErbsrtX1lMcCqZeHganauaPOeudixdqkaum9sVaAe1lNo8HPEvFOEXOiwnqvYi9cICb0HyuVipnQxgy(0wIr9soA9gseAaO4EJ6fWmMIPxC9V5GWeJ6fJipOI17OyyzKELVEXiYdQy9okgwb2gRcJmsVyAWbnteAa0aqbKIsqnGCnaPaqX0l9cOruVC6WhM6v9H6fJcHO8PzTKr6fe5cOdXOErEAuVmW8PTeJ6LC06nKi0aqX9g1lkiftV46FZbHjg1lgrEqfR3rXWYi9kF9IrKhuX6DumScSnwfgzKEXuGdAMi0aqX9g1lkiftV46FZbHjg1lgrEqfR3rXWYi9kF9IrKhuX6DumScSnwfgzKEzPErbsrtX1lMcCqZeHgakU3OEfuOy6fx)BoimXOEXOe6DamfalgwgPx5RxmkHEhatrcSyyzKEX0HcAMi0aqX9g1RHHIPxC9V5GWeJ6fJsO3bWueSyyzKELVEXOe6DamfzWIHLr6fthkOzIqdGgaUgD4dtmQxuOEzY0)wVuojjcna30aZXhEZPtZ1Vzi8RUcVjfHIOxuG9O1sKg7uVMJgT1AaOiue9IIQbLJ6vWdrPEf8GbhSganaMm9VjIqikFAwl355DScchOWdTWVP0R7SG1QGN3XkiCGcp0c)warAZBsqgAWb1ayY0)MicHO8PzTK6DgQkJgZV3aXcp0c)MsVUZcwRIQYOX87nqSWdTWVfqK28MeKHgCqnaMm9VjIqikFAwlPENb2ptfglvLnag559wj)G2BnaMm9VjIqikFAwlPENbLVnMT3BfYOJQiLEDNfSwfkFBmBV3kKrhvrbePnVjbzObhudGjt)BIieIYNM1sQ3zGKpKoaIHiKsVUNMc7uqYhshaXqekW2yvyudGjt)BIieIYNM1sQ3zGN3XkiCGs(jstPx3hoeSX6d3qr8F6cpVJebYfqpmeJmZcwRcEEhRGWbk5NiTi(8AnaMm9VjIqikFAwlPENHQcjJsOvtk96o5bvSEhfHGKeuHfecgM(385tEqfR3rbNxzPRWc5vCWo1ayY0)MicHO8PzTK6Dg4yq3yviLTrJ7j07aycCXjfEOdJuYXuG4Ec9oaMcGforKJyP6qswi(MR4ZpHEhatbWcNiisdskFTuHwIW2ufsc9kYNFc9oaMcGforin5iw(AXKCb0HySKq0iGqKObWKP)nrecr5tZAj17mWXGUXQqkBJg3tO3bWm4Itk8qhgPKJPaX9e6DamfblCIihXs1HKSq8nxXNFc9oaMIGforqKgKu(APcTeHTPkKe6vKp)e6DamfblCIqAYrS81Ij5cOdXyjHOraHirdGgakcfrVOadAucMyuVqoiCa9kDAuVYruVmz(q9Yj6LXXCLXQqHgatM(3KDw1)rfij1aqr0lUwhujFAwl1RWp9V1lNOxSy9HOEjFAwl1lSJeHgatM(3eQ3zi8t)Bk96otttHDkmIe7O1suGTXQWiZqZJfKd2PWIrIWBU3hMbzw(Vk(8AHrKyhTwIcisBEtccWdYe(8zAAkStX4NLrRJcSnwfgzMfSwf0VkXUWdTWVfGHmHpFwWAv4YbkyCdfGH85Z00uyNcs(q6QcechqGTXQWiZSG1QqcnzaL3BfciCdfGHmHp)iYcwRc0G5i2fsOhafGH85BY05GfSrAhjCdmF(SpHWC13gZcePnVjbzOb1aqr0lUwNiecgMAamz6FtOENbEEhlKr0GAamz6FtOENbqcw8ePPSnACphXs1HKSq8nxrPx3zAAkStHrKyhTwIcSnwfgzgAESGCWofwmseEZ9(WmiZY)vXNxlmIe7O1suarAZBsqaEqMWNptttHDkg)SmADuGTXQWiZSG1QG(vj2fEOf(TamKj85ZcwRcxoqbJBOamKpFMMMc7uqYhsxvGq4acSnwfgzMfSwfsOjdO8ERqaHBOamKj85hrwWAvGgmhXUqc9aOamKpFtMohSGns7iHBG5ZV6BJzbI0M3KGm0GAamz6FtOENbqcw8ePPSnACxAYrS81Ij5cOdXyjHOraHiHsVUZcwRctYfqhIXcH3dJcWq(8R(2ywGiT5njibZynaMm9VjuVZaiblEI0u2gnUtKgKu(APcTeHTPkKe6vKsVUpCwWAvqKgKu(APcTeHTPkKe6vSqHcWq(8R(2ywGiT5njidbmF(qZJfKd2PWIrIW7GamxXNVjtNdwWgPDKWnWAamz6FtOENbqcw8ePjusuFs2tO3bWeyk96(W5yq3yvOiHEhatGloPWdDyudGjt)Bc17masWINinHsI6tYEc9oaMbtPx3hohd6gRcfj07aygCXjfEOdJAamz6FtOENbw1)XsfeoaLEDF4PPWofgrID0AjkW2yvyKpFwWAvyej2rRLOamKpF5)Q4ZRfgrID0AjkGiT5nHBgpOgatM(3eQ3zGfHeegW7nk96(WttHDkmIe7O1suGTXQWiF(SG1QWisSJwlrbyOgatM(3eQ3zO6qKv9FKsVUp80uyNcJiXoATefyBSkmYNplyTkmIe7O1suagYNV8Fv851cJiXoATefqK28MWnJhudGjt)Bc17myTejj0ufPPuu619HNMc7uyej2rRLOaBJvHr(8zbRvHrKyhTwIcWq(8L)RIpVwyej2rRLOaI0M3eUz8GAamz6FtOENbwBR81scDzacLEDF4PPWofgrID0AjkW2yvyKp)HZcwRcJiXoATefGHAamz6FtOENHkcnvHe6qp1ayY0)Mq9odvdlj0AsfK4FtPx3zAAkStHrKyhTwIcSnwfg5Zhc2y9HBOi(pDHN3rIa5cOhgIrMWmtjpOI17Oyd(CWI3C8ThAP)nF(KhuX6DuuDuflFTWQEc5Pj85BY05GfSrAhj7aZenaMm9VjuVZGrKyhTwIu61DO5XcYb7uyXir4n37dZG85BY05GfSrAhjCdSgatM(3eQ3zGN3XkiCGs(jstPYBSiJ7aZyk96oeSX6d3qr8F6cpVJebYfqpmeJmZcwRI4)0fEEhjLiYcwRI4ZRzMPqZJfKd2PWIrIWBU35Qb5Z3KPZblyJ0os4gyMWNplyTk45DScchOKFI0I4ZRzMPdhc2y9HBOi(pDHN3rIa5cOhgIr(8zbRvr8F6cpVJKsezbRvbyit0aqr0lUwvV(wnGE9nQxyJ0dqPEfc9h65a6v9vQNhrVYruVyeX7nfYi9YKP)TEPCsk0ayY0)Mq9odstPkMm9VlkNKu2gnUt8EtHussOlZDGP0R7MmDoybBK2rYoWAaOi6ffDRx0GQ0dvOEHns7iHs9khr9ke6p0Zb0R6RuppIELJOEXi7rgPxMm9V1lLtsHgatM(3eQ3zqAkvXKP)Dr5KKY2OXD7rkjj0L5oWu61DtMohSGns7iHBG1ayY0)Mq9odYhStessOhal5NiTgatM(3eQ3zGeyGkiCGs(jsRbWKP)nH6DgcHoTPkKe6bqnaAaOiue9IIkOkD9kn4gM6Ljt)B9ke6p0Zb0lLtsnaMm9Vjc7XD5O5Dz0GCqssPx3zbRvbTHkscF6cp0c)wqstgG7DgRbWKP)nryps9odsOrglkFBmBV3O0R7qWgRpCdfX)Pl88oseixa9WqmYmlyTkI)tx45DKiad1ayY0)MiShPENbcyhrO3Bu61DiyJ1hUHI4)0fEEhjcKlGEyigzMfSwfX)Pl88oseGHAamz6Fte2JuVZWiAkV3kKeIgDj)ePP0R7qWgRpCdfqBZ7TchKeIWcNhMyqlqUa6HHyK50uyNc0G5yHm6OkkW2yvyKzoijeHL8tKUmIMQihn4gs4EqnaMm9Vjc7rQ3zanyowiJoQIu61DiyJ1hUHcOT59wHdscryHZdtmOfixa9WqmYCAkStbAWCSqgDuffyBSkmYmhKeIWs(jsxgrtvKJgCdjCpOgatM(3eH9i17muDiw6NJrPx3nz6CWs8trvz0yHm(YaCVZv85ZutMohSe)uuvgnwiJVma37uiZMmDoyj(POQmASqgFzaU3LdivybBK2rct0ayY0)MiShPENHqOt)WOBQcpJdsPCaPclPb3WKSdmLEDF4SG1Qie60pm6MQWZ4GcWqnaMm9Vjc7rQ3zGN3rsc9aiLEDhc2y9HBOiIyOAGc8)eJfuH0yNebYfqpmeJmZcwRcj0iJfLVnMT3BcWqnaMm9Vjc7rQ3zGKpKMKqpasPx3HGnwF4gkIigQgOa)pXybvin2jrGCb0ddXiZSG1QqcnYyr5BJz79MamudGjt)BIWEK6DgughROmYiLYbKkSKgCdtYoWu6194NIQYOXcz8LbePld49gZm1KPZblXpfvLrJfY4ldee5asfwWgPDKWSjtNdwIFkQkJglKXxgiiCft0ayY0)MiShPENHQYOXcz8LbO0R7dpDzaV30ayY0)MiShPENHQYOXcz8LbOuoGuHL0GBys2bMsVUp80uyNIrZvK8H0cSnwfgz2KPZblXpfvLrJfY4ldee5asfwWgPDKWSjtNdwIFkQkJglKXxgiiCLgatM(3eH9i17mO8TXS9ERW(QKsVUZutMohSe)uuvgnwiJVma37YbKkSGns7iHpFtMohSe)uuvgnwiJVma37uityMfSwfHqN(Hr3ufEghuagYmlyTkOnurs4tx4Hw43csAYaCVZynaMm9Vjc7rQ3zOcFswiJVmaLEDNfSwfJMRi5dPfGHAamz6Fte2JuVZq1WscTMubj(3u61DYdQy9ok2GphS4nhF7Hw6FZNp5bvSEhfvhvXYxlSQNqEAcF(qWgRpCdfeeJKYxlqJo06SSbFE5Oa5cOhgIrnaMm9Vjc7rQ3zqcnYyr5BJz79gLEDNfSwfsOrglkFBmBV3eXNxZmlyTkcHo9dJUPk8moOamKzwWAvqBOIKWNUWdTWVfK0KbccJ1ayY0)MiShPENbcyhrO3Bu61DwWAvecD6hgDtv4zCqbyiZSG1QG2qfjHpDHhAHFliPjdeegRbWKP)nryps9odK8H0Ke6bqk96olyTkcHo9dJUPk8moOamKzwWAvqBOIKWNUWdTWVfK0KbccJ1ayY0)MiShPENbcyhrO3BAamz6Fte2JuVZq1HyPFogLED3KPZblXpfvLrJfY4ldW9ofQbWKP)nryps9odsOrglkFBmBV3O0R7PPWofsOrg9ERqYhslW2yvyKpFwWAviHgzSO8TXS9EteFETgatM(3eH9i17mOmowrzKrkLdivyjn4gMKDGP0R7PPWofkJm69wPQmAKiW2yvyudGjt)BIWEK6DgQoel9ZXO0R7MmDoyj(POQmASqgFzaU3hsdGjt)BIWEK6Dg4GKqewYprAnaMm9Vjc7rQ3zqoAExu(2y2EVrPx3zbRvbjFiDaedrOamudGjt)BIWEK6DgughROmYiLEDNfSwfsOrglkFBmBV3eGHAamz6Fte2JuVZaQqASttvyvgjP0R7SG1QG2qfjHpDHhAHFliPjdW9oJ1ayY0)MiShPENbs(q6aigIqk96olyTkOnurs4tx4Hw43csAYaCVZynaMm9Vjc7rQ3zqoAExu(2y2EVrPx3zbRvbTHkscF6cp0c)wqstgyh4b1ayY0)MiShPENbs(qAsc9aiLEDNfSwfsOrglkFBmBV3eGHAamz6Fte2JuVZq1HyPFogLED3KPZblXpfvLrJfY4ldW9EWAamz6Fte2JuVZGeAKXIY3gZ27nnaMm9Vjc7rQ3zGN3rsc9aOgatM(3eH9i17mqYhstsOha1ayY0)MiShPENHQcjJsOvtk9oriemm3bMsVUtEqfR3rbNxzPRWc5vCWo1ayY0)MiShPENHQYOXcz8LbOuoGuHL0GBys2bMsVUdXkejJgRc1ayY0)MiShPENHQHLeAnPcs8V1ayY0)MiShPENHk8jzHm(YaAamz6Fte2JuVZGC08UO8TXS9EJsVUZcwRcAdvKe(0fEOf(TGKMma37mwdGjt)BIWEK6DgqdMJyxiHEaudGjt)BIWEK6DgqdMJfuH0yNMsdGjt)BIWEK6Dg45DScchOKFI0u61DwWAvWZ7yfeoqj)ePfqK28MeKHgudGgakcfrVMEVPq9kn4gM6Ljt)B9ke6p0Zb0lLtsnaMm9VjcI3BkCNN3rsc9aOgatM(3ebX7nfs9odkJJvugzKsVUZcwRIXplJwhfGH85ZuiyJ1hUHIqOtBQIY4yftMGw(qIa5cOhgIrMzbRvri0PnvrzCSIjtqlFirqstgGBUIjAamz6FteeV3ui17mWZ7yfeoqj)ePP0R7dNfSwf88owbHduYprAbyOgatM(3ebX7nfs9odK8H0Ke6bqk96oeSX6d3qr8F6cpVJebYfqpmeJmZcwRI4)0fEEhjcWqnaMm9VjcI3BkK6DgKqJmwu(2y2EVrPx3HGnwF4gkI)tx45DKiqUa6HHyKzwWAve)NUWZ7iragQbWKP)nrq8EtHuVZGlXcjHEaKsVUdbBS(Wnue)NUWZ7irGCb0ddXiZSG1Qi(pDHN3rIamudGjt)BIG49McPENbcyhrO3Bu61DiyJ1hUHI4)0fEEhjcKlGEyigzMfSwfX)Pl88oseGHAamz6FteeV3ui17mecD6hgDtv4zCqk96olyTkcHo9dJUPk8moOi(8AMzk08yb5GDkSyKi8MBkmy(8HMhlihStHfJeH3bHRyIgatM(3ebX7nfs9odvLrJfY4ldqPx3hE6YaEVPbWKP)nrq8EtHuVZGY3gZ27Tc7Rsk96olyTkOnurs4tx4Hw43csAYaCVZyMzbRvri0PFy0nvHNXbfGHmdnpwqoyNclgjcV5MfSwfHqN(Hr3ufEghuarAZBIgatM(3ebX7nfs9odCqsicl5NinLEDhAESGCWofwmseEZnfoOgatM(3ebX7nfs9odv4tYcz8LbO0R7SG1Qy0CfjFiTamudGjt)BIG49McPENb0G5i2fsOha1ayY0)MiiEVPqQ3zqzCSIYiJu6194NIQYOXcz8LbeqScrYOXQqnaMm9VjcI3BkK6DgQgwsO1KkiX)MsVUpCiyJ1hUHccIrs5RfOrhADw2GpVCuGCb0ddXiF(Y)vXNxlQi0ufsOd9uarAZBc3dnOgatM(3ebX7nfs9odK8H0Ke6bqk96EAkStbjFiDvbcHdiW2yvyKzwWAvqYhsZc9EdHcWqnaMm9VjcI3BkK6DgKJM3fLVnMT3Bu61DwWAvqYhshaXqekad1ayY0)MiiEVPqQ3zavin2PPkSkJKu61DwWAvqBOIKWNUWdTWVfK0Kb4ENXAamz6FteeV3ui17mmIMY7TcjHOrxYprAk96oeSX6d3qb028ERWbjHiSW5Hjg0cKlGEyigzonf2PanyowiJoQIcSnwfgzMPCqsicl5NiDzenvroAWnKWnW85ZuoijeHL8tKUmIMQihn4gs4EqMHMhlihStHfJeH3CZuwWAvWbjHiSKFI0cisBEtcQgIjmHjAamz6FteeV3ui17mGgmhlKrhvrk96oeSX6d3qb028ERWbjHiSW5Hjg0cKlGEyigzonf2PanyowiJoQIcSnwfgzMPCqsicl5NiDzenvroAWnKWnW85ZuoijeHL8tKUmIMQihn4gs4EqMHMhlihStHfJeH3CZuwWAvWbjHiSKFI0cisBEtcQgIjmHjAamz6FteeV3ui17mihnVlJgKdssk96olyTkOnurs4tx4Hw43csAYaCVZyMHMhlihStHfJeH3CVpmdQbWKP)nrq8EtHuVZGY3gZ27Tc7Rsk96olyTkOnurs4tx4Hw43csAYa7apiZSG1Qie60pm6MQWZ4GI4ZR1ayY0)MiiEVPqQ3zGKpKMKqpaQbWKP)nrq8EtHuVZajFiDaedriLEDNfSwf0gQij8Pl8ql8BbjnzaU3zSgatM(3ebX7nfs9odvfsgLqRMu6DIqiyyUdmLEDN8GkwVJcoVYsxHfYR4GDQbWKP)nrq8EtHuVZapVJvq4aL8tKMsVUZcwRcEEhRGWbk5NiTaI0M3KGa8GAamz6FteeV3ui17mOmowrzKrnaMm9VjcI3BkK6Dgu(2y2EVvyFvsPx3zbRvbTHkscF6cp0c)wqstgG7DgZmlyTkcHo9dJUPk8moOi(8AnaMm9VjcI3BkK6DgiGDeHEVrPx3HMhlihStHfJeH3CVtHdQbWKP)nrq8EtHuVZqf(KSqgFzanaMm9VjcI3BkK6DgKqJmwu(2y2EVPbWKP)nrq8EtHuVZGlXcjHEaudGjt)BIG49McPENHQdXs)Cmk96UjtNdwIFkQkJglKXxgqdGjt)BIG49McPENHQcjJsOvtk96o5bvSEhfHGKeuHfecgM(3Aamz6FteeV3ui17mGgmhlOcPXonLgatM(3ebX7nfs9odvLrJfY4ldqPx3jyMEVrevxPqyHm(YaAamz6FteeV3ui17mWZ7yfeoqj)ePP0R7SG1QGN3XkiCGs(jslGiT5njidn4LxEha]] )


end
