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


    spec:RegisterPack( "Enhancement", 20220315, [[duKvxbqiaOhHeuBcf1NqHAueeNcfPxHKAwir3sqHSlu9luWWuiogGAzkKEgaAAibUgsOTrqQVHcHXHcPohaW6iiX8eu6Ekv7JG6GOqelej5Hck4IibPpIeeojbjTsfQzIcj3efI0obOFIcrTubfQNQOPciFfjiASaG2Rk)vsdwjhMYIrPhtYKf6YqBwIpRugTconvVMqnBIUnsTBP(TQgUahhfXYb9Cetx01bA7e47eY4fu05funFbz)K6d4dOBgTepahDKrhDeacmf5aZOPaGPagXnZWdWBgykX2gEZ2OXBsH2dwRqASZBgyHlFlEaDtYdcv4nNoDy4MSGUmfQ9XEZOL4b4OJm6OJaqGPihygnabaaC0Bscq1b4OcnaV5GhJyFS3mIe1nPq7bRvin2PEnhmAR1JzKAq1GEbmaPuVgDKrh9MsNKKdOBs8EtIhqhGaFaDttL(33uK3rscDX4nX2yLy8O6YdWrpGUj2gReJhv3ub9eHUDtwWsHp8zDW6ihmqVcfsVeIEbbBS8WnKhaDAtwLMaRAQe0Yhs4ita9GamQxmRxSGLcpa60MSknbw1ujOLpKWjPPeRxcRxcTEX0BAQ0)(MstGvLgz4YdqaEaDtSnwjgpQUPc6jcD7MaOEXcwkCrEhlGWWR5Ninhm4MMk9VVPiVJfqy418tK(Ydqk4a6MyBSsmEuDtf0te62nHGnwE4gYJ)txf5DKWrMa6bbyuVywVyblfE8F6QiVJeoyWnnv6FFts(qAscDX4LhGu8a6MyBSsmEuDtf0te62nHGnwE4gYJ)txf5DKWrMa6bbyuVywVyblfE8F6QiVJeoyWnnv6FFtf0idvPVnKT3BxEak0hq3eBJvIXJQBQGEIq3UjeSXYd3qE8F6QiVJeoYeqpiaJ6fZ6flyPWJ)txf5DKWbdUPPs)7B6kSssOlgV8aKrCaDtSnwjgpQUPc6jcD7MqWglpCd5X)PRI8os4ita9GamQxmRxSGLcp(pDvK3rchm4MMk9VVjbSJi07Tlpaz0hq3eBJvIXJQBQGEIq3UjlyPWdGo9dJUjRImbip(IA9Iz9si6f08yffGDYTyKW9wVewVOGr1RqH0lO5Xkka7KBXiH7TEfw9sO1lMEttL(33ma60pm6MSkYeGxEacaoGUj2gReJhv3ub9eHUDtauVsxj27TBAQ0)(MfPrJvYWReF5biWJCaDtSnwjgpQUPc6jcD7MSGLcN2qjjHpDveAbFZjPPeRxcVRxuuVywVyblfEa0PFy0nzvKja5Gb6fZ6f08yffGDYTyKW9wVewVyblfEa0PFy0nzvKja5qK28MCttL(33u6Bdz79wL9L5LhGad8b0nX2yLy8O6MkONi0TBcnpwrbyNClgjCV1lH1lkyKBAQ0)(McqsacR5Ni9LhGap6b0nX2yLy8O6MkONi0TBYcwk8bZLK8H0CWGBAQ0)(Mf4tYkz4vIV8aeyaEaDttL(33enyoGDLe4IXBITXkX4r1LhGatbhq3eBJvIXJQBQGEIq3Uz8tErA0yLm8kXCiwGizWyL4nnv6FFtPjWQsJmC5biWu8a6MyBSsmEuDtf0te62nbq9cc2y5HBiNGyKu)sfA0bwN1n4lkh4ita9GamQxHcPxQ)LXxuZli0KvsGd9KdrAZBIEjSEbWrUPPs)7BwmSMqRjfqI)9LhGal0hq3eBJvIXJQBQGEIq3UzAsStojFiDrccHHZX2yLyuVywVyblfojFinl07neYbdUPPs)7BsYhstsOlgV8aeygXb0nX2yLy8O6MkONi0TBYcwkCs(qAXigGqoyWnnv6FFt1G5Dv6Bdz792LhGaZOpGUj2gReJhv3ub9eHUDtwWsHtBOKKWNUkcTGV5K0uI1lH31lkEttL(33eLin2PjRSsJKxEacma4a6MyBSsmEuDtf0te62nHGnwE4gYH2M3BvbijaHvbpmXWKJmb0dcWOEXSELMe7KJgmhQKbhLro2gReJ6fZ6Lq0lbijaH18tKUoGMSQgm4gs0lH1lG1RqH0lHOxcqsacR5NiDDanzvnyWnKOxcRxJOxmRxqZJvua2j3Irc3B9sy9si6flyPWfGKaewZprAoePnVj6vyKEbq9IP6ft1lMEttL(33CanP3BvscrJUMFI0xEao6ihq3eBJvIXJQBQGEIq3UjeSXYd3qo028ERkajbiSk4HjgMCKjGEqag1lM1R0KyNC0G5qLm4OmYX2yLyuVywVeIEjajbiSMFI01b0Kv1Gb3qIEjSEbSEfkKEje9sascqyn)ePRdOjRQbdUHe9sy9Ae9Iz9cAESIcWo5wms4ERxcRxcrVyblfUaKeGWA(jsZHiT5nrVcJ0laQxmvVyQEX0BAQ0)(MObZHkzWrz8YdWrb(a6MyBSsmEuDtf0te62nzblfoTHsscF6Qi0c(MtstjwVeExVOOEXSEbnpwrbyNClgjCV1lH31laWi30uP)9nvdM31bdkaj5LhGJo6b0nX2yLy8O6MkONi0TBYcwkCAdLKe(0vrOf8nNKMsSETRxapIEXSEXcwk8aOt)WOBYQitaYJVO(MMk9VVP03gY27Tk7lZlpahfGhq30uP)9nj5dPjj0fJ3eBJvIXJQlpahLcoGUj2gReJhv3ub9eHUDtwWsHtBOKKWNUkcTGV5K0uI1lH31lkEttL(33KKpKwmIbi8YdWrP4b0n9oriemiVjW3eBJvIXJQBQGEIq3Uj5bLSEh5cEPLUeRKxka7KJTXkX4nnv6FFZIejdkOvYlpahvOpGUj2gReJhv3ub9eHUDtwWsHlY7ybegEn)eP5qK28MOxHvVaEKBAQ0)(MI8owaHHxZpr6lpahLrCaDttL(33uAcSQ0id3eBJvIXJQlpahLrFaDtSnwjgpQUPc6jcD7MSGLcN2qjjHpDveAbFZjPPeRxcVRxuuVywVyblfEa0PFy0nzvKja5XxuFttL(33u6Bdz79wL9L5LhGJcaoGUj2gReJhv3ub9eHUDtO5Xkka7KBXiH7TEj8UErbJCttL(33Ka2re692LhGaCKdOBAQ0)(Mf4tYkz4vIVj2gReJhvxEacqGpGUPPs)7BQGgzOk9THS9E7MyBSsmEuD5biah9a6MMk9VVPRWkjHUy8MyBSsmEuD5biab4b0nX2yLy8O6MkONi0TBAQ0fG14N8I0OXkz4vIVPPs)7BwCiw7xGD5biaPGdOBITXkX4r1nvqprOB3K8GswVJ8aqsckXkcbds)Bo2gReJ30uP)9nlsKmOGwjV8aeGu8a6MMk9VVjAWCOIsKg70K3eBJvIXJQlpabOqFaDtSnwjgpQUPc6jcD7MemtV3i8IlLiSsgEL4BAQ0)(MfPrJvYWReF5biazehq3eBJvIXJQBQGEIq3UjlyPWf5DSacdVMFI0CisBEt0RWQxaCKBAQ0)(MI8owaHHxZpr6lV8M2JhqhGaFaDtSnwjgpQUPc6jcD7MSGLcN2qjjHpDveAbFZjPPeRxcVRxu8MMk9VVPAW8UoyqbijV8aC0dOBITXkX4r1nvqprOB3ec2y5HBip(pDvK3rchzcOheGr9Iz9IfSu4X)PRI8os4Gb30uP)9nvqJmuL(2q2EVD5biapGUj2gReJhv3ub9eHUDtiyJLhUH84)0vrEhjCKjGEqag1lM1lwWsHh)NUkY7iHdgCttL(33Ka2re692LhGuWb0nX2yLy8O6MkONi0TBcbBS8WnKdTnV3QcqsacRcEyIHjhzcOheGr9Iz9knj2jhnyoujdokJCSnwjg1lM1lbijaH18tKUoGMSQgm4gs0lH1RrUPPs)7BoGM07TkjHOrxZpr6lpaP4b0nX2yLy8O6MkONi0TBcbBS8WnKdTnV3QcqsacRcEyIHjhzcOheGr9Iz9knj2jhnyoujdokJCSnwjg1lM1lbijaH18tKUoGMSQgm4gs0lH1RrUPPs)7BIgmhQKbhLXlpaf6dOBITXkX4r1nvqprOB30uPlaRXp5fPrJvYWReRxcVRxcTEfkKEje9YuPlaRXp5fPrJvYWReRxcVRxuGEXSEzQ0fG14N8I0OXkz4vI1lH31lv4kjwXgPDKOxm9MMk9VVzXHyTFb2LhGmIdOBITXkX4r1nvqprOB3ea1lwWsHhaD6hgDtwfzcqoyWnnv6FFZaOt)WOBYQitaEtv4kjwtdUHj5ae4lpaz0hq3eBJvIXJQBQGEIq3UjeSXYd3qEeXaz4v4)jgROePXojCKjGEqag1lM1lwWsHRGgzOk9THS9EJdgCttL(33uK3rscDX4LhGaGdOBITXkX4r1nvqprOB3ec2y5HBipIyGm8k8)eJvuI0yNeoYeqpiaJ6fZ6flyPWvqJmuL(2q2EVXbdUPPs)7BsYhstsOlgV8ae4roGUj2gReJhv3ub9eHUDZ4N8I0OXkz4vI5PRe79MEXSEje9YuPlaRXp5fPrJvYWReRxHvVuHRKyfBK2rIEXSEzQ0fG14N8I0OXkz4vI1RWQxcTEX0BAQ0)(MstGvLgz4MQWvsSMgCdtYbiWxEacmWhq3eBJvIXJQBQGEIq3UjaQxPRe792nnv6FFZI0OXkz4vIV8ae4rpGUj2gReJhv3ub9eHUDtauVstIDYhmxsYhsZX2yLyuVywVmv6cWA8tErA0yLm8kX6vy1lv4kjwXgPDKOxmRxMkDbyn(jVinASsgELy9kS6LqFttL(33SinASsgEL4BQcxjXAAWnmjhGaF5biWa8a6MyBSsmEuDtf0te62nfIEzQ0fG14N8I0OXkz4vI1lH31lv4kjwXgPDKOxHcPxMkDbyn(jVinASsgELy9s4D9Ic0lMQxmRxSGLcpa60pm6MSkYeGCWa9Iz9IfSu40gkjj8PRIql4BojnLy9s4D9II30uP)9nL(2q2EVvzFzE5biWuWb0nX2yLy8O6MkONi0TBYcwk8bZLK8H0CWGBAQ0)(Mf4tYkz4vIV8aeykEaDtSnwjgpQUPc6jcD7MKhuY6DKVbFby1Bb(2dT0)MJTXkXOEfkKErEqjR3rEXrzS(LkR8jKNMWX2yLyuVcfsVGGnwE4gYjigj1VuHgDG1zDd(IYboYeqpiaJ30uP)9nlgwtO1KciX)(YdqGf6dOBITXkX4r1nvqprOB3KfSu4kOrgQsFBiBV34XxuRxmRxSGLcpa60pm6MSkYeGCWa9Iz9IfSu40gkjj8PRIql4BojnLy9kS6ffVPPs)7BQGgzOk9THS9E7YdqGzehq3eBJvIXJQBQGEIq3UjlyPWdGo9dJUjRImbihmqVywVyblfoTHsscF6Qi0c(MtstjwVcRErXBAQ0)(MeWoIqV3U8aeyg9b0nX2yLy8O6MkONi0TBYcwk8aOt)WOBYQitaYbd0lM1lwWsHtBOKKWNUkcTGV5K0uI1RWQxu8MMk9VVjjFinjHUy8YdqGbahq30uP)9njGDeHEVDtSnwjgpQU8aC0roGUj2gReJhv3ub9eHUDttLUaSg)KxKgnwjdVsSEj8UErb30uP)9nloeR9lWU8aCuGpGUj2gReJhv3ub9eHUDZ0KyNCf0idEVvj5dP5yBSsmQxHcPxSGLcxbnYqv6Bdz79gp(I6BAQ0)(MkOrgQsFBiBV3U8aC0rpGUj2gReJhv3ub9eHUDZ0KyNCPrg8ERwKgns4yBSsmEttL(33uAcSQ0id3ufUsI10GBysoab(YdWrb4b0nX2yLy8O6MkONi0TBAQ0fG14N8I0OXkz4vI1lH31laEttL(33S4qS2Va7YdWrPGdOBAQ0)(McqsacR5Ni9nX2yLy8O6YdWrP4b0nX2yLy8O6MkONi0TBYcwkCs(qAXigGqoyWnnv6FFt1G5Dv6Bdz792LhGJk0hq3eBJvIXJQBQGEIq3UjlyPWvqJmuL(2q2EVXbdUPPs)7BknbwvAKHlpahLrCaDtSnwjgpQUPc6jcD7MSGLcN2qjjHpDveAbFZjPPeRxcVRxu8MMk9VVjkrASttwzLgjV8aCug9b0nX2yLy8O6MkONi0TBYcwkCAdLKe(0vrOf8nNKMsSEj8UErXBAQ0)(MK8H0IrmaHxEaoka4a6MyBSsmEuDtf0te62nzblfoTHsscF6Qi0c(MtstjwV21lGh5MMk9VVPAW8Uk9THS9E7YdqaoYb0nX2yLy8O6MkONi0TBYcwkCf0idvPVnKT3BCWGBAQ0)(MK8H0Ke6IXlpabiWhq3eBJvIXJQBQGEIq3UPPsxawJFYlsJgRKHxjwVeExVg9MMk9VVzXHyTFb2LhGaC0dOBAQ0)(MkOrgQsFBiBV3Uj2gReJhvxEacqaEaDttL(33uK3rscDX4nX2yLy8O6Ydqasbhq30uP)9nj5dPjj0fJ3eBJvIXJQlpabifpGUP3jcHGb5nb(MyBSsmEuDtf0te62njpOK17ixWlT0LyL8sbyNCSnwjgVPPs)7BwKizqbTsE5biaf6dOBITXkX4r1nvqprOB3eIfisgmwjEttL(33SinASsgEL4BQcxjXAAWnmjhGaF5biazehq30uP)9nlgwtO1KciX)(MyBSsmEuD5biaz0hq30uP)9nlWNKvYWReFtSnwjgpQU8aeGaGdOBITXkX4r1nvqprOB3KfSu40gkjj8PRIql4BojnLy9s4D9II30uP)9nvdM3vPVnKT3BxEasbJCaDttL(33enyoGDLe4IXBITXkX4r1LhGuaWhq30uP)9nrdMdvuI0yNM8MyBSsmEuD5bifm6b0nX2yLy8O6MkONi0TBYcwkCrEhlGWWR5NinhI0M3e9kS6fah5MMk9VVPiVJfqy418tK(YlVzelgOmpGoab(a6MMk9VVjR8)OeKK3eBJvIXJ9YdWrpGUj2gReJhv30uP)9nd(0)(MkONi0TBke9knj2j3ikSJwRqo2gReJ6fZ6f08yffGDYTyKW9wVeExVaaJOxmRxQ)LXxuZnIc7O1kKdrAZBIEfw9c4r0lMQxHcPxcrVstIDYh(SoyDKJTXkXOEXSEXcwkC6xMyxfHwW3CWa9IP6vOq6flyPWDv4vmUHCWa9kui9si6vAsStojFiDrccHHZX2yLyuVywVyblfUcAkXsV3Qeq4gYbd0lMQxHcPxrKfSu4ObZbSRKaxmYbd0RqH0ltLUaSIns7irVewVawVcfsVyFcrVywVk(2qwHiT5nrVcREbWrUzejkOhK(33uO2HrQNM1s9k4t)B9Yj6flwEiQxQNM1s9c7iHF5biapGUj2gReJhv3mIef0ds)7Bku7eHqWG8MMk9VVPiVJvYaAWlpaPGdOBITXkX4r1nBJgVzoG1IdjzL4BU8MMk9VVzoG1IdjzL4BU8MkONi0TBke9knj2j3ikSJwRqo2gReJ6fZ6f08yffGDYTyKW9wVeExVaaJOxmRxQ)LXxuZnIc7O1kKdrAZBIEfw9c4r0lMQxHcPxcrVstIDYh(SoyDKJTXkXOEXSEXcwkC6xMyxfHwW3CWa9IP6vOq6flyPWDv4vmUHCWa9kui9si6vAsStojFiDrccHHZX2yLyuVywVyblfUcAkXsV3Qeq4gYbd0lMQxHcPxrKfSu4ObZbSRKaxmYbd0RqH0ltLUaSIns7irVewVawVcfsVk(2qwHiT5nrVcREbWrU8aKIhq3eBJvIXJQB2gnEtLPgW6xQMIjGoeJ1eIgbeIKBAQ0)(MktnG1VunftaDigRjenciej3ub9eHUDtwWsHBkMa6qmwjIEyKdgOxHcPxfFBiRqK28MOxHvVgLIxEak0hq3eBJvIXJQB2gnEtIYGK6xQfOLiSnzLKqVG30uP)9njkdsQFPwGwIW2Kvsc9cEtf0te62nbq9IfSu4eLbj1VulqlryBYkjHEbRuahmqVcfsVk(2qwHiT5nrVcREbWrU8aKrCaDtSnwjgpQUjr(j5Mj0BXyc8nnv6FFZe6Tymb(MkONi0TBcG6Lad6gRe5j0BXycC1jvrOdJxEaYOpGUj2gReJhv3Ki)KCZe6Tymh9MMk9VVzc9wmMJEtf0te62nbq9sGbDJvI8e6TymhT6KQi0HXlpabahq3eBJvIXJQBQGEIq3UjaQxPjXo5grHD0AfYX2yLyuVcfsVyblfUruyhTwHCWa9kui9s9Vm(IAUruyhTwHCisBEt0lH1lkoYnnv6FFtw5)XAbeg(LhGapYb0nX2yLy8O6MkONi0TBcG6vAsStUruyhTwHCSnwjg1RqH0lwWsHBef2rRvihm4MMk9VVjlcjiuS3BxEacmWhq3eBJvIXJQBQGEIq3UjaQxPjXo5grHD0AfYX2yLyuVcfsVyblfUruyhTwHCWa9kui9s9Vm(IAUruyhTwHCisBEt0lH1lkoYnnv6FFZIdrw5)XlpabE0dOBITXkX4r1nvqprOB3ea1R0KyNCJOWoATc5yBSsmQxHcPxSGLc3ikSJwRqoyGEfkKEP(xgFrn3ikSJwRqoePnVj6LW6ffh5MMk9VVP1kKKqtwvMuE5biWa8a6MyBSsmEuDtf0te62nbq9knj2j3ikSJwRqo2gReJ6vOq6faQxSGLc3ikSJwRqoyWnnv6FFtwBR(LAcDLyYLhGatbhq30uP)9nli0KvsGd98MyBSsmEuD5biWu8a6MyBSsmEuDtf0te62nfIELMe7KBef2rRvihBJvIr9kui9cc2y5HBip(pDvK3rchzcOheGr9IP6fZ6Lq0lYdkz9oY3GVaS6TaF7Hw6FZX2yLyuVcfsVipOK17iV4Omw)sLv(eYtt4yBSsmQxHcPxMkDbyfBK2rIETRxaRxm9MMk9VVzXWAcTMuaj(3xEacSqFaDtSnwjgpQUPc6jcD7MqZJvua2j3Irc3B9s4D9camIEfkKEzQ0fGvSrAhj6LW6fW30uP)9nnIc7O1k8YdqGzehq3eBJvIXJQBQGEIq3UjeSXYd3qE8F6QiVJeoYeqpiaJ6fZ6flyPWJ)txf5DKuJilyPWJVOwVywVeIEbnpwrbyNClgjCV1lH31lHEe9kui9YuPlaRyJ0os0lH1lG1lMQxHcPxSGLcxK3Xcim8A(jsZJVOwVywVeIEbG6feSXYd3qE8F6QiVJeoYeqpiaJ6vOq6flyPWJ)txf5DKuJilyPWbd0lMEttL(33uK3Xcim8A(jsFtP3yvfVjWu8YdqGz0hq3eBJvIXJQBgrIc6bP)9nfQf96Bz4613OEHnshoL6va0FONHRxLxkFre9khq9IXeV3KiJ1ltL(36L0jj)MMk9VVPYKYQPs)7Q0j5njj0v5biW3ub9eHUDttLUaSIns7irV21lGVP0jzTnA8MeV3K4LhGadaoGUj2gReJhv3mIef0ds)7BYi36fnOm9ajQxyJ0osOuVYbuVcG(d9mC9Q8s5lIOx5aQxm2EKX6LPs)B9s6KKFttL(33uzsz1uP)Dv6K8MKe6Q8ae4BQGEIq3UPPsxawXgPDKOxcRxaFtPtYAB04nThV8aC0roGUPPs)7BQEWorijHUySMFI03eBJvIXJQlpahf4dOBAQ0)(MeXHxaHHxZpr6BITXkX4r1LhGJo6b0nnv6FFZaOtBYkjHUy8MyBSsmEuD5L3maIQNM1YdOdqGpGUj2gReJhv3ub9eHUDtwWsHlY7ybegEveAbFZHiT5nrVcREbWrg5MMk9VVPiVJfqy4vrOf89LhGJEaDtSnwjgpQUPc6jcD7MSGLcVinAm)EdeRIql4BoePnVj6vy1laoYi30uP)9nlsJgZV3aXQi0c((YdqaEaDttL(33K9ZuIXArAHJrrEVvZpm9(MyBSsmEuD5bifCaDtSnwjgpQUPc6jcD7MSGLcx6Bdz79wLm4OmYHiT5nrVcREbWrg5MMk9VVP03gY27TkzWrz8YdqkEaDtSnwjgpQUPc6jcD7MPjXo5K8H0IrmaHCSnwjgVPPs)7BsYhslgXaeE5bOqFaDtSnwjgpQUPc6jcD7MaOEbbBS8WnKh)NUkY7iHJmb0dcWOEXSEXcwkCrEhlGWWR5Ninp(I6BAQ0)(MI8owaHHxZpr6lpazehq3eBJvIXJQBQGEIq3Uj5bLSEh5bGKeuIvecgK(3CSnwjg1RqH0lYdkz9oYf8slDjwjVua2jhBJvIXBAQ0)(MfjsguqRKxEaYOpGUj2gReJhv38dUjbZBAQ0)(McmOBSs8McmjiEZe6Tym5jWCNWZbSwCijReFZL6vOq6vc9wmM8eyUt4eLbj1VulqlryBYkjHEb1RqH0Re6Tym5jWCNWvMAaRFPAkMa6qmwtiAeqisUPadwBJgVzc9wmMaxDsve6W4LhGaGdOBITXkX4r1n)GBsW8MMk9VVPad6gReVPatcI3mHElgtEok3j8CaRfhsYkX3CPEfkKELqVfJjphL7eorzqs9l1c0se2MSssOxq9kui9kHElgtEok3jCLPgW6xQMIjGoeJ1eIgbeIKBkWG12OXBMqVfJ5OvNufHomE5LxEtbiK4FFao6iJo6iaCekEtrgS9EJCtkKmscJbuOcifcHIEPxanG6Lth8WuVkpuVyS9iJ1liYeqhIr9I80OEzG5tBjg1l1G1BiHRhZO8g1lGPOqrVcdFlaHjg1lgtEqjR3roaKX6v(6fJjpOK17ihaYX2yLyKX6LqgnmzkxpMr5nQxaKIcf9km8TaeMyuVym5bLSEh5aqgRx5RxmM8GswVJCaihBJvIrgRxwQxuOmYmk9siahMmLRhRhtHKrsymGcvaPqiu0l9cObuVC6GhM6v5H6fJjEVjrgRxqKjGoeJ6f5Pr9YaZN2smQxQbR3qcxpMr5nQxJsrHIEfg(wactmQxmM8GswVJCaiJ1R81lgtEqjR3roaKJTXkXiJ1ll1lkugzgLEjeGdtMY1JzuEJ6faPaHIEfg(wactmQxmM8GswVJCaiJ1R81lgtEqjR3roaKJTXkXiJ1ll1lkugzgLEjeGdtMY1J1JPqYijmgqHkGuiek6LEb0aQxoDWdt9Q8q9IXrSyGYKX6fezcOdXOErEAuVmW8PTeJ6LAW6nKW1JzuEJ6fWuuOOxHHVfGWeJ6fJjpOK17ihaYy9kF9IXKhuY6DKda5yBSsmYy9siJgMmLRhRhtHKrsymGcvaPqiu0l9cObuVC6GhM6v5H6fJdGO6PzTKX6fezcOdXOErEAuVmW8PTeJ6LAW6nKW1JzuEJ6fJqOOxHHVfGWeJ6fJjpOK17ihaYy9kF9IXKhuY6DKda5yBSsmYy9siahMmLRhZO8g1lgHqrVcdFlaHjg1lgtEqjR3roaKX6v(6fJjpOK17ihaYX2yLyKX6LL6ffkJmJsVecWHjt56XmkVr9Irlu0RWW3cqyIr9IXj0BXyYbMdazSELVEX4e6Tym5jWCaiJ1lHaWWKPC9ygL3OEbaek6vy4BbimXOEX4e6Tym5JYbGmwVYxVyCc9wmM8CuoaKX6LqayyYuUESESqLo4Hjg1lkqVmv6FRxsNKeUE8ndGFXL4nPWuy9IcThSwH0yN61CWOTwpMctH1lgPgunOxadqk1Rrhz0r1J1Jnv6Ft4bqu90SwUlY7ybegEveAbFtPx2zblfUiVJfqy4vrOf8nhI0M3KWcWrgrp2uP)nHhar1tZAj17muKgnMFVbIvrOf8nLEzNfSu4fPrJ53BGyveAbFZHiT5njSaCKr0Jnv6Ft4bqu90Sws9odSFMsmwlslCmkY7TA(HP36XMk9Vj8aiQEAwlPENbPVnKT3BvYGJYiLEzNfSu4sFBiBV3QKbhLroePnVjHfGJmIESPs)BcpaIQNM1sQ3zGKpKwmIbiKsVSNMe7KtYhslgXaeYX2yLyup2uP)nHhar1tZAj17miY7ybegEn)ePP0l7aieSXYd3qE8F6QiVJeoYeqpiaJmZcwkCrEhlGWWR5Ninp(IA9ytL(3eEaevpnRLuVZqrIKbf0kjLEzN8GswVJ8aqsckXkcbds)7qHipOK17ixWlT0LyL8sbyN6XMk9Vj8aiQEAwlPENbbg0nwjszB04Ec9wmMaxDsve6WiLcmjiUNqVfJjhyUt45awloKKvIV5YqHsO3IXKdm3jCIYGK6xQfOLiSnzLKqVGHcLqVfJjhyUt4ktnG1VunftaDigRjenciej6XMk9Vj8aiQEAwlPENbbg0nwjszB04Ec9wmMJwDsve6WiLcmjiUNqVfJjFuUt45awloKKvIV5YqHsO3IXKpk3jCIYGK6xQfOLiSnzLKqVGHcLqVfJjFuUt4ktnG1VunftaDigRjenciej6X6XuykSErHgMOcmXOEHcqy46v60OELdOEzQ8H6Lt0ltG5sJvIC9ytL(3KDw5)rjij1JPW6LqTdJupnRL6vWN(36Lt0lwS8quVupnRL6f2rcxp2uP)nH6Dgc(0)MsVSlK0KyNCJOWoATc5yBSsmYm08yffGDYTyKW9w4DaWimR(xgFrn3ikSJwRqoePnVjHf4ryAOqcjnj2jF4Z6G1ro2gReJmZcwkC6xMyxfHwW3CWaMgkelyPWDv4vmUHCWGqHesAsStojFiDrccHHZX2yLyKzwWsHRGMsS07TkbeUHCWaMgkuezblfoAWCa7kjWfJCWGqHmv6cWk2iTJeHboui2NqyU4BdzfI0M3KWcWr0JPW6LqTtecbds9ytL(3eQ3zqK3XkzanOESPs)Bc17masWQNinLTrJ75awloKKvIV5sk9YUqstIDYnIc7O1kKJTXkXiZqZJvua2j3Irc3BH3baJWS6Fz8f1CJOWoATc5qK28MewGhHPHcjK0KyN8HpRdwh5yBSsmYmlyPWPFzIDveAbFZbdyAOqSGLc3vHxX4gYbdcfsiPjXo5K8H0fjiegohBJvIrMzblfUcAkXsV3Qeq4gYbdyAOqrKfSu4ObZbSRKaxmYbdcfYuPlaRyJ0oseg4qHk(2qwHiT5njSaCe9ytL(3eQ3zaKGvprAkBJg3vMAaRFPAkMa6qmwtiAeqisO0l7SGLc3umb0HySse9WihmiuOIVnKvisBEtc7Ouup2uP)nH6Dgajy1tKMY2OXDIYGK6xQfOLiSnzLKqVGu6LDaKfSu4eLbj1VulqlryBYkjHEbRuahmiuOIVnKvisBEtclahrp2uP)nH6Dgajy1tKMqjr(jzpHElgtGP0l7aOad6gRe5j0BXycC1jvrOdJ6XMk9VjuVZaibREI0ekjYpj7j0BXyokLEzhafyq3yLipHElgZrRoPkcDyup2uP)nH6DgyL)hRfqy4u6LDamnj2j3ikSJwRqo2gReJHcXcwkCJOWoATc5GbHcP(xgFrn3ikSJwRqoePnVjctXr0Jnv6FtOENbwesqOyV3O0l7ayAsStUruyhTwHCSnwjgdfIfSu4grHD0AfYbd0Jnv6FtOENHIdrw5)rk9YoaMMe7KBef2rRvihBJvIXqHyblfUruyhTwHCWGqHu)lJVOMBef2rRvihI0M3eHP4i6XMk9VjuVZG1kKKqtwvMusPx2bW0KyNCJOWoATc5yBSsmgkelyPWnIc7O1kKdgekK6Fz8f1CJOWoATc5qK28Mimfhrp2uP)nH6DgyTT6xQj0vIju6LDamnj2j3ikSJwRqo2gReJHcbGSGLc3ikSJwRqoyGESPs)Bc17muqOjRKah6PESPs)Bc17mumSMqRjfqI)nLEzxiPjXo5grHD0AfYX2yLymuiiyJLhUH84)0vrEhjCKjGEqagzkZcH8GswVJ8n4laRElW3EOL(3HcrEqjR3rEXrzS(LkR8jKNMekKPsxawXgPDKSdmt1Jnv6FtOENbJOWoATcP0l7qZJvua2j3Irc3BH3baJekKPsxawXgPDKimW6XMk9VjuVZGiVJfqy418tKMsP3yvf3bMIu6LDiyJLhUH84)0vrEhjCKjGEqagzMfSu4X)PRI8osQrKfSu4XxuZSqGMhROaStUfJeU3cVl0JekKPsxawXgPDKimWmnuiwWsHlY7ybegEn)eP5XxuZSqaqiyJLhUH84)0vrEhjCKjGEqagdfIfSu4X)PRI8osQrKfSu4GbmvpMcRxc1IE9TmC96BuVWgPdNs9ka6p0ZW1RYlLViIELdOEXyI3BsKX6LPs)B9s6KKRhBQ0)Mq9odktkRMk9VRsNKu2gnUt8EtIussORYDGP0l7MkDbyfBK2rYoW6Xuy9IrU1lAqz6bsuVWgPDKqPELdOEfa9h6z46v5LYxerVYbuVyS9iJ1ltL(36L0jjxp2uP)nH6DguMuwnv6FxLojPSnAC3EKsscDvUdmLEz3uPlaRyJ0osegy9ytL(3eQ3zq9GDIqscDXyn)eP1Jnv6FtOENbI4WlGWWR5NiTESPs)Bc17meaDAtwjj0fJ6X6XuykSEXifuMUELgCdt9YuP)TEfa9h6z46L0jPESPs)Bc3ECxnyExhmOaKKu6LDwWsHtBOKKWNUkcTGV5K0uIfENI6XMk9VjC7rQ3zqbnYqv6Bdz79gLEzhc2y5HBip(pDvK3rchzcOheGrMzblfE8F6QiVJeoyGESPs)Bc3EK6DgiGDeHEVrPx2HGnwE4gYJ)txf5DKWrMa6bbyKzwWsHh)NUkY7iHdgOhBQ0)MWThPENHb0KEVvjjen6A(jstPx2HGnwE4gYH2M3BvbijaHvbpmXWKJmb0dcWiZPjXo5ObZHkzWrzKJTXkXiZcqsacR5NiDDanzvnyWnKi8i6XMk9VjC7rQ3zanyoujdokJu6LDiyJLhUHCOT59wvascqyvWdtmm5ita9GamYCAsStoAWCOsgCug5yBSsmYSaKeGWA(jsxhqtwvdgCdjcpIESPs)Bc3EK6DgkoeR9lWO0l7MkDbyn(jVinASsgELyH3f6qHeIPsxawJFYlsJgRKHxjw4DkGztLUaSg)KxKgnwjdVsSW7QWvsSIns7iHP6XMk9VjC7rQ3zia60pm6MSkYeGuQcxjXAAWnmj7atPx2bqwWsHhaD6hgDtwfzcqoyGESPs)Bc3EK6Dge5DKKqxmsPx2HGnwE4gYJigidVc)pXyfLin2jHJmb0dcWiZSGLcxbnYqv6Bdz79ghmqp2uP)nHBps9odK8H0Ke6Irk9YoeSXYd3qEeXaz4v4)jgROePXojCKjGEqagzMfSu4kOrgQsFBiBV34Gb6XMk9VjC7rQ3zqAcSQ0iduQcxjXAAWnmj7atPx2JFYlsJgRKHxjMNUsS3BmletLUaSg)KxKgnwjdVsCyvHRKyfBK2rcZMkDbyn(jVinASsgEL4Wk0mvp2uP)nHBps9odfPrJvYWRetPx2bW0vI9Etp2uP)nHBps9odfPrJvYWRetPkCLeRPb3WKSdmLEzhattIDYhmxsYhsZX2yLyKztLUaSg)KxKgnwjdVsCyvHRKyfBK2rcZMkDbyn(jVinASsgEL4Wk06XMk9VjC7rQ3zq6Bdz79wL9LjLEzxiMkDbyn(jVinASsgELyH3vHRKyfBK2rsOqMkDbyn(jVinASsgELyH3PaMYmlyPWdGo9dJUjRImbihmGzwWsHtBOKKWNUkcTGV5K0uIfENI6XMk9VjC7rQ3zOaFswjdVsmLEzNfSu4dMlj5dP5Gb6XMk9VjC7rQ3zOyynHwtkGe)Bk9Yo5bLSEh5BWxaw9wGV9ql9VdfI8GswVJ8IJYy9lvw5tipnjuiiyJLhUHCcIrs9lvOrhyDw3GVOCGJmb0dcWOESPs)Bc3EK6DguqJmuL(2q2EVrPx2zblfUcAKHQ03gY27nE8f1mZcwk8aOt)WOBYQitaYbdyMfSu40gkjj8PRIql4BojnL4Wsr9ytL(3eU9i17mqa7ic9EJsVSZcwk8aOt)WOBYQitaYbdyMfSu40gkjj8PRIql4BojnL4Wsr9ytL(3eU9i17mqYhstsOlgP0l7SGLcpa60pm6MSkYeGCWaMzblfoTHsscF6Qi0c(MtstjoSuup2uP)nHBps9odeWoIqV30Jnv6Ft42JuVZqXHyTFbgLEz3uPlaRXp5fPrJvYWRel8ofOhBQ0)MWThPENbf0idvPVnKT3Bu6L90KyNCf0idEVvj5dP5yBSsmgkelyPWvqJmuL(2q2EVXJVOwp2uP)nHBps9odstGvLgzGsv4kjwtdUHjzhyk9YEAsStU0idEVvlsJgjCSnwjg1Jnv6Ft42JuVZqXHyTFbgLEz3uPlaRXp5fPrJvYWRel8oa1Jnv6Ft42JuVZGaKeGWA(jsRhBQ0)MWThPENb1G5Dv6Bdz79gLEzNfSu4K8H0IrmaHCWa9ytL(3eU9i17minbwvAKbk9YolyPWvqJmuL(2q2EVXbd0Jnv6Ft42JuVZakrASttwzLgjP0l7SGLcN2qjjHpDveAbFZjPPel8of1Jnv6Ft42JuVZajFiTyedqiLEzNfSu40gkjj8PRIql4BojnLyH3POESPs)Bc3EK6DgudM3vPVnKT3Bu6LDwWsHtBOKKWNUkcTGV5K0uI3bEe9ytL(3eU9i17mqYhstsOlgP0l7SGLcxbnYqv6Bdz79ghmqp2uP)nHBps9odfhI1(fyu6LDtLUaSg)KxKgnwjdVsSW7JQhBQ0)MWThPENbf0idvPVnKT3B6XMk9VjC7rQ3zqK3rscDXOESPs)Bc3EK6Dgi5dPjj0fJ6XMk9VjC7rQ3zOirYGcALKsVtecbdYDGP0l7KhuY6DKl4Lw6sSsEPaSt9ytL(3eU9i17muKgnwjdVsmLQWvsSMgCdtYoWu6LDiwGizWyLOESPs)Bc3EK6DgkgwtO1KciX)wp2uP)nHBps9odf4tYkz4vI1Jnv6Ft42JuVZGAW8Uk9THS9EJsVSZcwkCAdLKe(0vrOf8nNKMsSW7uup2uP)nHBps9odObZbSRKaxmQhBQ0)MWThPENb0G5qfLin2Pj1Jnv6Ft42JuVZGiVJfqy418tKMsVSZcwkCrEhlGWWR5NinhI0M3KWcWr0J1JPWuy9A69Me1R0GByQxMk9V1RaO)qpdxVKoj1Jnv6Ft4eV3K4UiVJKe6Ir9ytL(3eoX7njs9odstGvLgzGsVSZcwk8HpRdwh5GbHcjeiyJLhUH8aOtBYQ0eyvtLGw(qchzcOheGrMzblfEa0PnzvAcSQPsqlFiHtstjwyHMP6XMk9VjCI3BsK6Dge5DSacdVMFI0u6LDaKfSu4I8owaHHxZprAoyGESPs)BcN49MePENbs(qAscDXiLEzhc2y5HBip(pDvK3rchzcOheGrMzblfE8F6QiVJeoyGESPs)BcN49MePENbf0idvPVnKT3Bu6LDiyJLhUH84)0vrEhjCKjGEqagzMfSu4X)PRI8os4Gb6XMk9VjCI3BsK6DgCfwjj0fJu6LDiyJLhUH84)0vrEhjCKjGEqagzMfSu4X)PRI8os4Gb6XMk9VjCI3BsK6DgiGDeHEVrPx2HGnwE4gYJ)txf5DKWrMa6bbyKzwWsHh)NUkY7iHdgOhBQ0)MWjEVjrQ3zia60pm6MSkYeGu6LDwWsHhaD6hgDtwfzcqE8f1mleO5Xkka7KBXiH7TWuWOHcbnpwrbyNClgjCVdRqZu9ytL(3eoX7njs9odfPrJvYWRetPx2bW0vI9Etp2uP)nHt8EtIuVZG03gY27Tk7ltk9YolyPWPnuss4txfHwW3CsAkXcVtrMzblfEa0PFy0nzvKja5GbmdnpwrbyNClgjCVfMfSu4bqN(Hr3KvrMaKdrAZBIESPs)BcN49MePENbbijaH18tKMsVSdnpwrbyNClgjCVfMcgrp2uP)nHt8EtIuVZqb(KSsgELyk9YolyPWhmxsYhsZbd0Jnv6Ft4eV3Ki17mGgmhWUscCXOESPs)BcN49MePENbPjWQsJmqPx2JFYlsJgRKHxjMdXcejdgRe1Jnv6Ft4eV3Ki17mumSMqRjfqI)nLEzhaHGnwE4gYjigj1VuHgDG1zDd(IYboYeqpiaJHcP(xgFrnVGqtwjbo0toePnVjcdWr0Jnv6Ft4eV3Ki17mqYhstsOlgP0l7PjXo5K8H0fjiegohBJvIrMzblfojFinl07neYbd0Jnv6Ft4eV3Ki17mOgmVRsFBiBV3O0l7SGLcNKpKwmIbiKdgOhBQ0)MWjEVjrQ3zaLin2PjRSsJKu6LDwWsHtBOKKWNUkcTGV5K0uIfENI6XMk9VjCI3BsK6Dggqt69wLKq0OR5NinLEzhc2y5HBihABEVvfGKaewf8WedtoYeqpiaJmNMe7KJgmhQKbhLro2gReJmlebijaH18tKUoGMSQgm4gseg4qHeIaKeGWA(jsxhqtwvdgCdjcpcZqZJvua2j3Irc3BHfclyPWfGKaewZprAoePnVjHraKPmLP6XMk9VjCI3BsK6DgqdMdvYGJYiLEzhc2y5HBihABEVvfGKaewf8WedtoYeqpiaJmNMe7KJgmhQKbhLro2gReJmlebijaH18tKUoGMSQgm4gseg4qHeIaKeGWA(jsxhqtwvdgCdjcpcZqZJvua2j3Irc3BHfclyPWfGKaewZprAoePnVjHraKPmLP6XMk9VjCI3BsK6DgudM31bdkajjLEzNfSu40gkjj8PRIql4BojnLyH3PiZqZJvua2j3Irc3BH3baJOhBQ0)MWjEVjrQ3zq6Bdz79wL9LjLEzNfSu40gkjj8PRIql4BojnL4DGhHzwWsHhaD6hgDtwfzcqE8f16XMk9VjCI3BsK6Dgi5dPjj0fJ6XMk9VjCI3BsK6Dgi5dPfJyacP0l7SGLcN2qjjHpDveAbFZjPPel8of1Jnv6Ft4eV3Ki17muKizqbTssP3jcHGb5oWu6LDYdkz9oYf8slDjwjVua2PESPs)BcN49MePENbrEhlGWWR5NinLEzNfSu4I8owaHHxZprAoePnVjHf4r0Jnv6Ft4eV3Ki17minbwvAKb9ytL(3eoX7njs9odsFBiBV3QSVmP0l7SGLcN2qjjHpDveAbFZjPPel8ofzMfSu4bqN(Hr3KvrMaKhFrTESPs)BcN49MePENbcyhrO3Bu6LDO5Xkka7KBXiH7TW7uWi6XMk9VjCI3BsK6DgkWNKvYWReRhBQ0)MWjEVjrQ3zqbnYqv6Bdz79MESPs)BcN49MePENbxHvscDXOESPs)BcN49MePENHIdXA)cmk9YUPsxawJFYlsJgRKHxjwp2uP)nHt8EtIuVZqrIKbf0kjLEzN8GswVJ8aqsckXkcbds)B9ytL(3eoX7njs9odObZHkkrASttQhBQ0)MWjEVjrQ3zOinASsgELyk9YobZ07ncV4sjcRKHxjwp2uP)nHt8EtIuVZGiVJfqy418tKMsVSZcwkCrEhlGWWR5NinhI0M3KWcWrUPbMdp8MtNomC5L3b]] )


end
