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


    spec:RegisterPack( "Enhancement", 20220305, [[du0mmbqiaQEeaL2eb6teGrPc4ucr9kGYSaQULqeSls(fqAycPogkPLbiEgazAQG6AOe2gGuFdqsJdLiDovGADOeL5PcY9ur7tiCqajyHaQhkerxufi9rvGWjrjIvkuntuIQBciH2Pk0pbKOLkeHEQctfaFvfiASauSxL(RIgSkDyklgfpMOjl4YqBwkFwQmAPQtt1RfkZgv3gP2TKFRQHtOJtaTCqphX0fDDKSDuQVtqJxisNxiz(aX(j1lRla7iyjUhbs0abirdOOzHIvabOd(Wh8oYOeXDiAYywhUJYOXDCqRERKinw5oeTO4Vfwa2b5PGsChdNosUdgkNNSKAz2rWsCpcKObcqIgqrZcfRacqh8HzP7GiIY9iqaAaTJEpeWAz2rajYDCqRERKinwP(o6nAR0XbkAqzV(YcW1xGenqaYo4ojjla7G4vhhxa2JSUaSdtM(x7qOxbsc9y4oWYy4yybEZ9iqwa2bwgdhdlW7qc9eHUTdgQwt1)5S3QGIsuFbbe99a6lKQW2d7qLi0Pn(KBSTPjtklFirHcKYffXG(kO(Yq1AkrOtB8j3yBttMuw(qIIKMmM(gH(c06BK3Hjt)RDWn22KBK(n3JaAbyhyzmCmSaVdj0te62oaC9LHQ1uc9k0OGrnZprAfL4omz6FTdHEfAuWOM5Ni9M7XdVaSdSmgogwG3He6jcDBhqQcBpSdvH)PNc9kquOaPCrrmOVcQVmuTMk8p9uOxbIIsChMm9V2bjFinjHEmCZ9ilwa2bwgdhdlW7qc9eHUTdivHTh2HQW)0tHEfikuGuUOig0xb1xgQwtf(NEk0RarrjUdtM(x7qcns)K7D9z5v3M7rGEbyhyzmCmSaVdj0te62oGuf2EyhQc)tpf6vGOqbs5IIyqFfuFzOAnv4F6PqVcefL4omz6FTdxItsc9y4M7rG6cWoWYy4yybEhsONi0TDaPkS9Wouf(NEk0RarHcKYffXG(kO(Yq1AQW)0tHEfikkXDyY0)AheQkGqV62CpYsxa2bwgdhdlW7qc9eHUTdgQwtjcD6hgCJpfASrv4fw6RG67b0xO5HjYgRuzHar5L(gH(EyGOVGaI(cnpmr2yLkleikV03dPVaT(g5DyY0)AhIqN(Hb34tHgBCZ94bVaSdSmgogwG3He6jcDBhaU(MUmMxD7WKP)1oACJgNK(xgBZ9iRrVaSdSmgogwG3He6jcDBhmuTMI2qojHp9uiAIFPiPjJPVrCQVSqFfuFzOAnLi0PFyWn(uOXgvuI6RG6l08WezJvQSqGO8sFJqFzOAnLi0PFyWn(uOXgvqK28ISdtM(x7G7D9z5v3K555M7rwzDbyhyzmCmSaVdj0te62oGMhMiBSsLfceLx6Be67HJEhMm9V2bBKiIWz(jsV5EKvGSaSdSmgogwG3He6jcDBhmuTMQ3CojFiTIsChMm9V2rd(KCs6FzSn3JScOfGDyY0)AhObZESMerpgUdSmgogwG3CpY6Hxa2bwgdhdlW7qc9eHUTJWNQg3OXjP)LXuqSbrsVXWXDyY0)AhCJTn5gPFZ9iRSybyhyzmCmSaVdj0te62oaC9fsvy7HDOIGyGm)2eA0IwLZo4lm7vOaPCrrmOVGaI(k)NhEHLQHqJpjIo0tfePnVi6Be6lGIEhMm9V2rZWzcTI0Oi(xBUhzfOxa2bwgdhdlW7qc9eHUTJ04yLks(q6gNccJsHLXWXG(kO(Yq1Aks(qAgOxDiurjUdtM(x7GKpKMKqpgU5EKvG6cWoWYy4yybEhsONi0TDWq1Aks(q6yikIqfL4omz6FTdzV51K7D9z5v3M7rwzPla7alJHJHf4DiHEIq32bdvRPOnKts4tpfIM4xksAYy6BeN6ll2Hjt)RDGCKgR04tgUrYn3JSEWla7alJHJHf4DiHEIq32bKQW2d7qf068QBYgjIiCY(HjgPkuGuUOig0xb1304yLk0Gz)K07ipOWYy4yqFfuFpG(YgjIiCMFI0ZE04tzVb7qI(gH(YQ(cci67b0x2ireHZ8tKE2JgFk7nyhs03i03O1xb1xO5HjYgRuzHar5L(gH(Ea9LHQ1uSrIicN5NiTcI0Mxe9nsqFbK(gz9nY6BK3Hjt)RD0Jg3RUjjHOrpZpr6n3Jaj6fGDGLXWXWc8oKqprOB7asvy7HDOcADE1nzJereoz)WeJufkqkxued6RG6BACSsfAWSFs6DKhuyzmCmOVcQVhqFzJereoZpr6zpA8PS3GDirFJqFzvFbbe99a6lBKiIWz(jsp7rJpL9gSdj6Be6B06RG6l08WezJvQSqGO8sFJqFpG(Yq1Ak2ireHZ8tKwbrAZlI(gjOVasFJS(gz9nY7WKP)1oqdM9tsVJ8WM7rGW6cWoWYy4yybEhsONi0TDWq1AkAd5Ke(0tHOj(LIKMmM(gXP(Yc9vq9fAEyISXkvwiquEPVrCQVhC07WKP)1oK9MxZEdYgj5M7rGaKfGDGLXWXWc8oKqprOB7GHQ1u0gYjj8PNcrt8lfjnzm99uFznA9vq9LHQ1uIqN(Hb34tHgBufEH1omz6FTdU31NLxDtMNNBUhbcGwa2Hjt)RDqYhstsOhd3bwgdhdlWBUhbYHxa2bwgdhdlW7qc9eHUTdgQwtrBiNKWNEkenXVuK0KX03io1xwSdtM(x7GKpKogIIiCZ9iqyXcWoWYy4yybEhsONi0TDqEkoJxbf7NBPZXj55SXkvyzmCmSdtM(x7OXrsVeATChELiesjM7G1n3JabOxa2bwgdhdlW7qc9eHUTdgQwtj0RqJcg1m)ePvqK28IOVhsFzn6DyY0)Ahc9k0OGrnZpr6n3JabOUaSdtM(x7GBSTj3i97alJHJHf4n3JaHLUaSdSmgogwG3He6jcDBhmuTMI2qojHp9uiAIFPiPjJPVrCQVSqFfuFzOAnLi0PFyWn(uOXgvHxyTdtM(x7G7D9z5v3K555M7rGCWla7alJHJHf4DiHEIq32b08WezJvQSqGO8sFJ4uFpC07WKP)1oiuvaHE1T5EeqrVaSdtM(x7ObFsoj9Vm2oWYy4yybEZ9iGyDbyhMm9V2HeAK(j376ZYRUDGLXWXWc8M7rabKfGDyY0)AhUeNKe6XWDGLXWXWc8M7rabOfGDGLXWXWc8oKqprOB7WKPZgNHpvnUrJts)lJTdtM(x7O5qCwpBBZ9iGo8cWoWYy4yybEhsONi0TDqEkoJxbLifjP44eHuIP)LclJHJHDyY0)Ahnos6LqRLBUhbelwa2Hjt)RDGgm7NihPXkn(oWYy4yybEZ9iGa6fGDGLXWXWc8oKqprOB7GGz6vhr1CohHts)lJTdtM(x7OXnACs6FzSn3JacOUaSdSmgogwG3He6jcDBhmuTMsOxHgfmQz(jsRGiT5frFpK(cOO3Hjt)RDi0RqJcg1m)eP3CZDypUaShzDbyhyzmCmSaVdj0te62oyOAnfTHCscF6Pq0e)srstgtFJ4uFzXomz6FTdzV51S3GSrsU5Eeila7alJHJHf4DiHEIq32bKQW2d7qv4F6PqVcefkqkxued6RG6ldvRPc)tpf6vGOOe3Hjt)RDiHgPFY9U(S8QBZ9iGwa2bwgdhdlW7qc9eHUTdivHTh2HQW)0tHEfikuGuUOig0xb1xgQwtf(NEk0RarrjUdtM(x7Gqvbe6v3M7XdVaSdSmgogwG3He6jcDBhqQcBpSdvqRZRUjBKiIWj7hMyKQqbs5IIyqFfuFtJJvQqdM9tsVJ8GclJHJb9vq9Lnser4m)ePN9OXNYEd2He9nc9n6DyY0)Ah9OX9QBssiA0Z8tKEZ9ilwa2bwgdhdlW7qc9eHUTdivHTh2HkO15v3Knser4K9dtmsvOaPCrrmOVcQVPXXkvObZ(jP3rEqHLXWXG(kO(YgjIiCMFI0ZE04tzVb7qI(gH(g9omz6FTd0Gz)K07ipS5EeOxa2bwgdhdlW7qc9eHUTdtMoBCg(u14gnoj9VmM(gXP(c06liGOVhqFnz6SXz4tvJB04K0)Yy6BeN67H1xb1xtMoBCg(u14gnoj9VmM(gXP(kJsYXjwiTJe9nY7WKP)1oAoeN1Z22Cpcuxa2bwgdhdlW7WKP)1oeHo9ddUXNcn24oKqprOB7aW1xgQwtjcD6hgCJpfASrfL4oKrj54mnyhMK9iRBUhzPla7alJHJHf4DiHEIq32bKQW2d7qvarrEut4)jgMihPXkjkuGuUOig0xb1xgQwtjHgPFY9U(S8QtrjUdtM(x7qOxbsc9y4M7XdEbyhyzmCmSaVdj0te62oGuf2EyhQcikYJAc)pXWe5inwjrHcKYffXG(kO(Yq1Akj0i9tU31NLxDkkXDyY0)AhK8H0Ke6XWn3JSg9cWoWYy4yybEhMm9V2b3yBtUr63He6jcDBhHpvnUrJts)lJPsxgZRo9vq99a6RjtNnodFQACJgNK(xgtFpK(kJsYXjwiTJe9vq91KPZgNHpvnUrJts)lJPVhsFbA9nY7qgLKJZ0GDys2JSU5EKvwxa2bwgdhdlW7qc9eHUTdaxFtxgZRUDyY0)AhnUrJts)lJT5EKvGSaSdSmgogwG3Hjt)RD04gnoj9Vm2oKqprOB7aW1304yLQEZ5K8H0kSmgog0xb1xtMoBCg(u14gnoj9VmM(Ei9vgLKJtSqAhj6RG6RjtNnodFQACJgNK(xgtFpK(c07qgLKJZ0GDys2JSU5EKvaTaSdSmgogwG3He6jcDBhhqFnz6SXz4tvJB04K0)Yy6BeN6RmkjhNyH0os0xqarFnz6SXz4tvJB04K0)Yy6BeN67H13iRVcQVmuTMse60pm4gFk0yJkkr9vq9LHQ1u0gYjj8PNcrt8lfjnzm9nIt9Lf7WKP)1o4ExFwE1nzEEU5EK1dVaSdSmgogwG3He6jcDBhmuTMQ3CojFiTIsChMm9V2rd(KCs6FzSn3JSYIfGDGLXWXWc8oKqprOB7G8uCgVcQo4ZgNEX27EOL(xkSmgog0xqarFjpfNXRGQ5ipm)2KH)eYttuyzmCmOVGaI(cPkS9WourqmqMFBcnArRYzh8fM9kuGuUOig2Hjt)RD0mCMqRinkI)1M7rwb6fGDGLXWXWc8oKqprOB7GHQ1usOr6NCVRplV6uHxyPVcQVmuTMse60pm4gFk0yJkkr9vq9LHQ1u0gYjj8PNcrt8lfjnzm99q6ll2Hjt)RDiHgPFY9U(S8QBZ9iRa1fGDGLXWXWc8oKqprOB7GHQ1uIqN(Hb34tHgBurjQVcQVmuTMI2qojHp9uiAIFPiPjJPVhsFzXomz6FTdcvfqOxDBUhzLLUaSdSmgogwG3He6jcDBhmuTMse60pm4gFk0yJkkr9vq9LHQ1u0gYjj8PNcrt8lfjnzm99q6ll2Hjt)RDqYhstsOhd3CpY6bVaSdtM(x7Gqvbe6v3oWYy4yybEZ9iqIEbyhyzmCmSaVdj0te62omz6SXz4tvJB04K0)Yy6BeN67H3Hjt)RD0CioRNTT5EeiSUaSdSmgogwG3He6jcDBhPXXkvsOr69QBsYhsRWYy4yqFbbe9LHQ1usOr6NCVRplV6uHxyTdtM(x7qcns)K7D9z5v3M7rGaKfGDGLXWXWc8omz6FTdUX2MCJ0Vdj0te62osJJvQ4gP3RUzJB0irHLXWXWoKrj54mnyhMK9iRBUhbcGwa2bwgdhdlW7qc9eHUTdtMoBCg(u14gnoj9VmM(gXP(cODyY0)AhnhIZ6zBBUhbYHxa2Hjt)RDWgjIiCMFI07alJHJHf4n3JaHfla7alJHJHf4DiHEIq32bdvRPi5dPJHOicvuI7WKP)1oK9MxtU31NLxDBUhbcqVaSdSmgogwG3He6jcDBhmuTMscns)K7D9z5vNIsChMm9V2b3yBtUr63CpceG6cWoWYy4yybEhsONi0TDWq1AkAd5Ke(0tHOj(LIKMmM(gXP(YIDyY0)AhihPXkn(KHBKCZ9iqyPla7alJHJHf4DiHEIq32bdvRPOnKts4tpfIM4xksAYy6BeN6ll2Hjt)RDqYhshdrreU5Eeih8cWoWYy4yybEhsONi0TDWq1AkAd5Ke(0tHOj(LIKMmM(EQVSg9omz6FTdzV51K7D9z5v3M7raf9cWoWYy4yybEhsONi0TDWq1Akj0i9tU31NLxDkkXDyY0)AhK8H0Ke6XWn3JaI1fGDGLXWXWc8oKqprOB7WKPZgNHpvnUrJts)lJPVrCQVazhMm9V2rZH4SE22M7rabKfGDyY0)AhsOr6NCVRplV62bwgdhdlWBUhbeGwa2Hjt)RDi0RajHEmChyzmCmSaV5EeqhEbyhMm9V2bjFinjHEmChyzmCmSaV5EeqSybyhyzmCmSaVdj0te62oipfNXRGI9ZT054K8C2yLkSmgog2Hjt)RD04iPxcTwUdVsecPeZDW6M7rab0la7alJHJHf4DyY0)AhnUrJts)lJTdj0te62oGydIKEJHJ7qgLKJZ0GDys2JSU5Eeqa1fGDyY0)AhndNj0ksJI4FTdSmgogwG3Cpciw6cWomz6FTJg8j5K0)Yy7alJHJHf4n3Ja6Gxa2bwgdhdlW7qc9eHUTdgQwtrBiNKWNEkenXVuK0KX03io1xwSdtM(x7q2BEn5ExFwE1T5E8WrVaSdtM(x7any2J1Ki6XWDGLXWXWc8M7XdZ6cWomz6FTd0Gz)e5inwPX3bwgdhdlWBUhpmqwa2bwgdhdlW7qc9eHUTdgQwtj0RqJcg1m)ePvqK28IOVhsFbu07WKP)1oe6vOrbJAMFI0BU5ocyZO45cWEK1fGDyY0)Ahm8)dCksUdSmgogwMn3JazbyhyzmCmSaVdj0te62oyEcrFfuFBExFoHiT5frFpK(c0rVJasKqxm9V2blPIeKpnJL6R4N(x6Rt0xgS9quFLpnJL6lwbIAhMm9V2H4N(xBUhb0cWoWYy4yybEhbKiHUy6FTdwsLiesjM7WKP)1oe6vys6rdU5E8Wla7WKP)1oOi40tKMSdSmgogwG3CpYIfGDGLXWXWc8oKqprOB7aW1304yLkJiXkyLevyzmCmOVGaI(Yq1AkJiXkyLevuI6liGOVY)5HxyPmIeRGvsubrAZlI(gH(YIO3Hjt)RDWW)pmBuWO2Cpc0la7alJHJHf4DiHEIq32bGRVPXXkvgrIvWkjQWYy4yqFbbe9LHQ1ugrIvWkjQOe3Hjt)RDWGqccJ5v3M7rG6cWoWYy4yybEhsONi0TDa46BACSsLrKyfSsIkSmgog0xqarFzOAnLrKyfSsIkkr9feq0x5)8WlSugrIvWkjQGiT5frFJqFzr07WKP)1oAoez4)h2CpYsxa2bwgdhdlW7qc9eHUTdaxFtJJvQmIeRGvsuHLXWXG(cci6ldvRPmIeRGvsurjQVGaI(k)NhEHLYisScwjrfePnVi6Be6llIEhMm9V2HvsKKqJpLgNV5E8Gxa2bwgdhdlW7qc9eHUTdaxFtJJvQmIeRGvsuHLXWXG(cci6lGRVmuTMYisScwjrfL4omz6FTdgRB(TzcDzmYM7rwJEbyhMm9V2rdHgFseDON7alJHJHf4n3JSY6cWoWYy4yybEhsONi0TDCa9nnowPYisScwjrfwgdhd6liGOVqQcBpSdvH)PNc9kquOaPCrrmOVrwFfuFpG(sEkoJxbvh8zJtVy7Dp0s)lfwgdhd6liGOVKNIZ4vq1CKhMFBYWFc5PjkSmgog0xqarFnz6SXjwiTJe99uFzvFJ8omz6FTJMHZeAfPrr8V2CpYkqwa2bwgdhdlW7qc9eHUTdO5HjYgRuzHar5L(gXP(EWrRVGaI(AY0zJtSqAhj6Be6lR7WKP)1omIeRGvsCZ9iRaAbyhyzmCmSaVdtM(x7qOxHgfmQz(jsVdj0te62oGuf2EyhQc)tpf6vGOqbs5IIyqFfuFzOAnv4F6PqVcKzazOAnv4fw6RG67b0xO5HjYgRuzHar5L(gXP(c0rRVGaI(AY0zJtSqAhj6Be6lR6BK1xqarFzOAnLqVcnkyuZ8tKwfEHL(kO(Ea9fW1xivHTh2HQW)0tHEfikuGuUOig0xqarFzOAnv4F6PqVcKzazOAnfLO(g5DW9cNYWoyLfBUhz9Wla7alJHJHf4DeqIe6IP)1oyjn99lEu67xO(Ifshf46Ri0FONrPVTNZFHe9n7r9vaeV64Oa0xtM(x6l3jPAhMm9V2H048Pjt)Rj3j5oij0L5EK1DiHEIq32HjtNnoXcPDKOVN6lR7G7KCwgnUdIxDCCZ9iRSybyhyzmCmSaVJasKqxm9V2bqzPV0u80f5O(Ifs7ibC9n7r9ve6p0ZO032Z5VqI(M9O(ka7rbOVMm9V0xUts1omz6FTdPX5ttM(xtUtYDqsOlZ9iR7qc9eHUTdtMoBCIfs7irFJqFzDhCNKZYOXDypU5EKvGEbyhMm9V2H8PQeHKe6XWz(jsVdSmgogwG3CpYkqDbyhMm9V2bjwunkyuZ8tKEhyzmCmSaV5EKvw6cWomz6FTdrOtB8jjHEmChyzmCmSaV5M7qeIYNMXYfG9iRla7alJHJHf4DiHEIq32bdvRPe6vOrbJAkenXVuqK28IOVhsFbu0rVdtM(x7qOxHgfmQPq0e)AZ9iqwa2bwgdhdlW7qc9eHUTdgQwt14gnMF1rHtHOj(LcI0Mxe99q6lGIo6DyY0)AhnUrJ5xDu4uiAIFT5Eeqla7WKP)1oy(m5yy24wuyqOxDZ8JuV2bwgdhdlWBUhp8cWoWYy4yybEhsONi0TDWq1AkU31NLxDtsVJ8GcI0Mxe99q6lGIo6DyY0)AhCVRplV6MKEh5Hn3JSybyhyzmCmSaVdj0te62osJJvQi5dPJHOicvyzmCmSdtM(x7GKpKogIIiCZ9iqVaSdSmgogwG3He6jcDBhaU(cPkS9Wouf(NEk0RarHcKYffXG(kO(Yq1AkHEfAuWOM5NiTk8cRDyY0)Ahc9k0OGrnZpr6n3Ja1fGDGLXWXWc8oKqprOB7G8uCgVckrkssXXjcPet)lfwgdhd6liGOVKNIZ4vqX(5w6CCsEoBSsfwgdhd7WKP)1oACK0lHwl3CpYsxa2bwgdhdlW7qc9eHUTdMNq2Hjt)RDi(P)1MBU5oyJqI)1EeirdeGenGIgi7qOblV6i74GeOqK4rwYXdcwM(QVa0J6Rtl(WuFBpuFfG9Oa0xikqkhIb9L80O(Au5tBjg0xzVvDirPJZY9c1xwzbltFJKFXgHjg0xbqEkoJxbfGra6B(6RaipfNXRGcWOWYy4yqa67basKgzLool3luFbelyz6BK8l2imXG(kaYtXz8kOamcqFZxFfa5P4mEfuagfwgdhdcqFTuFpOaLSC99aSgPrwPJRJFqcuis8il54bbltF1xa6r91PfFyQVThQVcG4vhhfG(crbs5qmOVKNg1xJkFAlXG(k7TQdjkDCwUxO(cewWY03i5xSryIb9vaKNIZ4vqbyeG(MV(kaYtXz8kOamkSmgogeG(AP(Eqbkz567bynsJSshNL7fQVa6WSm9ns(fBeMyqFfa5P4mEfuagbOV5RVcG8uCgVckaJclJHJbbOVwQVhuGswU(EawJ0iR0X1XpibkejEKLC8GGLPV6la9O(60Ipm132d1xbeWMrXtbOVquGuoed6l5Pr91OYN2smOVYER6qIshNL7fQVSYkltFJKFXgHjg0xbqEkoJxbfGra6B(6RaipfNXRGcWOWYy4yqa67basKgzLoUo(bjqHiXJSKJheSm9vFbOh1xNw8HP(2EO(karikFAglfG(crbs5qmOVKNg1xJkFAlXG(k7TQdjkDCwUxO(cuzz6BK8l2imXG(kaYtXz8kOamcqFZxFfa5P4mEfuagfwgdhdcqFpaRrAKv64SCVq9fOYY03i5xSryIb9vaKNIZ4vqbyeG(MV(kaYtXz8kOamkSmgogeG(AP(Eqbkz567bynsJSshxhNLql(Wed67H1xtM(x6l3jjrPJVdr43CoUdalGvFpOvVvsKgRuFh9gTv64awaR(cu0GYE9LfGRVajAGaeDCDCtM(xeLieLpnJLNc9k0OGrnfIM4xG7TtgQwtj0RqJcg1uiAIFPGiT5f5qak6O1Xnz6FruIqu(0mwc2jOnUrJ5xDu4uiAIFbU3ozOAnvJB0y(vhfofIM4xkisBEroeGIoADCtM(xeLieLpnJLGDckZNjhdZg3Icdc9QBMFK6LoUjt)lIseIYNMXsWobL7D9z5v3K07ipaU3ozOAnf376ZYRUjP3rEqbrAZlYHau0rRJBY0)IOeHO8PzSeStqj5dPJHOicb3BNPXXkvK8H0XqueHkSmgog0Xnz6FruIqu(0mwc2jOc9k0OGrnZprAW92jGdPkS9Wouf(NEk0RarHcKYffXGGmuTMsOxHgfmQz(jsRcVWsh3KP)frjcr5tZyjyNG24iPxcTwcU3ojpfNXRGsKIKuCCIqkX0)ceqipfNXRGI9ZT054K8C2yL64Mm9VikrikFAglb7euXp9Va3BNmpHOJRJdybS67bnsrjvIb9fzJWO030Pr9n7r91K5d1xNOVgBZ5gdhv64Mm9ViNm8)dCksQJdy1xwsfjiFAgl1xXp9V0xNOVmy7HO(kFAgl1xSceLoUjt)lcyNGk(P)f4E7K5jebBExFoHiT5f5qaD064aw9LLujcHuIPoUjt)lcyNGk0RWK0Jguh3KP)fbStqPi40tKMOJBY0)Ia2jOm8)dZgfmkW92jGNghRuzejwbRKOclJHJbqaHHQ1ugrIvWkjQOebbe5)8WlSugrIvWkjQGiT5fjcweToUjt)lcyNGYGqccJ5vh4E7eWtJJvQmIeRGvsuHLXWXaiGWq1AkJiXkyLevuI64Mm9ViGDcAZHid))a4E7eWtJJvQmIeRGvsuHLXWXaiGWq1AkJiXkyLevuIGaI8FE4fwkJiXkyLevqK28IeblIwh3KP)fbStqTsIKeA8P04CW92jGNghRuzejwbRKOclJHJbqaHHQ1ugrIvWkjQOebbe5)8WlSugrIvWkjQGiT5fjcweToUjt)lcyNGYyDZVntOlJra3BNaEACSsLrKyfSsIkSmgogabeaNHQ1ugrIvWkjQOe1Xnz6Fra7e0gcn(Ki6qp1Xnz6Fra7e0MHZeAfPrr8Va3BNhinowPYisScwjrfwgdhdGacKQW2d7qv4F6PqVcefkqkxuedrwWdqEkoJxbvh8zJtVy7Dp0s)lqaH8uCgVcQMJ8W8Btg(tipnbeqmz6SXjwiTJKtwJSoUjt)lcyNGAejwbRKi4E7eAEyISXkvwiquEfX5bhniGyY0zJtSqAhjrWQoUjt)lcyNGk0RqJcg1m)ePbN7foLHtwzb4E7esvy7HDOk8p9uOxbIcfiLlkIbbzOAnv4F6PqVcKzazOAnv4fwcEaO5HjYgRuzHar5veNaD0GaIjtNnoXcPDKebRrgeqyOAnLqVcnkyuZ8tKwfEHLGhaWHuf2EyhQc)tpf6vGOqbs5IIyaeqyOAnv4F6PqVcKzazOAnfLyK1XbS6llPPVFXJsF)c1xSq6OaxFfH(d9mk9T9C(lKOVzpQVcG4vhhfG(AY0)sF5ojv64Mm9ViGDcQ048Pjt)Rj3jj4LrJNeV64i4Ke6Y8KvW92PjtNnoXcPDKCYQooGvFbkl9LMINUih1xSqAhjGRVzpQVIq)HEgL(2Eo)fs03Sh1xbypka91KP)L(YDsQ0Xnz6Fra7euPX5ttM(xtUtsWlJgpThbNKqxMNScU3onz6SXjwiTJKiyvh3KP)fbStqLpvLiKKqpgoZprADCtM(xeWobLelQgfmQz(jsRJBY0)Ia2jOIqN24tsc9yOoUooGfWQVafP4PRVPb7WuFnz6FPVIq)HEgL(YDsQJBY0)IOShpL9MxZEdYgjj4E7KHQ1u0gYjj8PNcrt8lfjnzSiozHoUjt)lIYEeStqLqJ0p5ExFwE1bU3oHuf2EyhQc)tpf6vGOqbs5IIyqqgQwtf(NEk0RarrjQJBY0)IOShb7eucvfqOxDG7TtivHTh2HQW)0tHEfikuGuUOigeKHQ1uH)PNc9kquuI64Mm9Vik7rWobThnUxDtscrJEMFI0G7TtivHTh2HkO15v3Knser4K9dtmsvOaPCrrmiyACSsfAWSFs6DKhuyzmCmiiBKiIWz(jsp7rJpL9gSdjreToUjt)lIYEeStqrdM9tsVJ8a4E7esvy7HDOcADE1nzJereoz)WeJufkqkxuedcMghRuHgm7NKEh5bfwgdhdcYgjIiCMFI0ZE04tzVb7qserRJBY0)IOShb7e0MdXz9SnW92PjtNnodFQACJgNK(xglItGgeqoGjtNnodFQACJgNK(xglIZdlOjtNnodFQACJgNK(xglItzusooXcPDKezDCtM(xeL9iyNGkcD6hgCJpfASrWLrj54mnyhMKtwb3BNaodvRPeHo9ddUXNcn2OIsuh3KP)frzpc2jOc9kqsOhdb3BNqQcBpSdvbef5rnH)NyyICKgRKOqbs5IIyqqgQwtjHgPFY9U(S8QtrjQJBY0)IOShb7eus(qAsc9yi4E7esvy7HDOkGOipQj8)edtKJ0yLefkqkxuedcYq1Akj0i9tU31NLxDkkrDCtM(xeL9iyNGYn22KBKEWLrj54mnyhMKtwb3BNHpvnUrJts)lJPsxgZRobpGjtNnodFQACJgNK(xg7qYOKCCIfs7irqtMoBCg(u14gnoj9Vm2Ha6iRJBY0)IOShb7e0g3OXjP)LXa3BNaE6YyE1PJBY0)IOShb7e0g3OXjP)LXaxgLKJZ0GDysozfCVDc4PXXkv9MZj5dPvyzmCmiOjtNnodFQACJgNK(xg7qYOKCCIfs7irqtMoBCg(u14gnoj9Vm2HaADCtM(xeL9iyNGY9U(S8QBY88eCVDEatMoBCg(u14gnoj9VmweNYOKCCIfs7ibeqmz6SXz4tvJB04K0)YyrCE4ilidvRPeHo9ddUXNcn2OIsuqgQwtrBiNKWNEkenXVuK0KXI4Kf64Mm9Vik7rWobTbFsoj9Vmg4E7KHQ1u9MZj5dPvuI64Mm9Vik7rWobTz4mHwrAue)lW92j5P4mEfuDWNno9IT39ql9VabeYtXz8kOAoYdZVnz4pH80eqabsvy7HDOIGyGm)2eA0IwLZo4lm7vOaPCrrmOJBY0)IOShb7euj0i9tU31NLxDG7TtgQwtjHgPFY9U(S8QtfEHLGmuTMse60pm4gFk0yJkkrbzOAnfTHCscF6Pq0e)srstg7qSqh3KP)frzpc2jOeQkGqV6a3BNmuTMse60pm4gFk0yJkkrbzOAnfTHCscF6Pq0e)srstg7qSqh3KP)frzpc2jOK8H0Ke6XqW92jdvRPeHo9ddUXNcn2OIsuqgQwtrBiNKWNEkenXVuK0KXoel0Xnz6Fru2JGDckHQci0RoDCtM(xeL9iyNG2CioRNTbU3onz6SXz4tvJB04K0)YyrCEyDCtM(xeL9iyNGkHgPFY9U(S8QdCVDMghRujHgP3RUjjFiTclJHJbqaHHQ1usOr6NCVRplV6uHxyPJBY0)IOShb7euUX2MCJ0dUmkjhNPb7WKCYk4E7mnowPIBKEV6MnUrJefwgdhd64Mm9Vik7rWobT5qCwpBdCVDAY0zJZWNQg3OXjP)LXI4eq64Mm9Vik7rWobLnser4m)eP1Xnz6Fru2JGDcQS38AY9U(S8QdCVDYq1Aks(q6yikIqfLOoUjt)lIYEeStq5gBBYnsp4E7KHQ1usOr6NCVRplV6uuI64Mm9Vik7rWobf5inwPXNmCJKG7TtgQwtrBiNKWNEkenXVuK0KXI4Kf64Mm9Vik7rWobLKpKogIIieCVDYq1AkAd5Ke(0tHOj(LIKMmweNSqh3KP)frzpc2jOYEZRj376ZYRoW92jdvRPOnKts4tpfIM4xksAYyNSgToUjt)lIYEeStqj5dPjj0JHG7TtgQwtjHgPFY9U(S8QtrjQJBY0)IOShb7e0MdXz9SnW92PjtNnodFQACJgNK(xglItGOJBY0)IOShb7euj0i9tU31NLxD64Mm9Vik7rWobvOxbsc9yOoUjt)lIYEeStqj5dPjj0JH64Mm9Vik7rWobTXrsVeATeCVsecPeZtwb3BNKNIZ4vqX(5w6CCsEoBSsDCtM(xeL9iyNG24gnoj9Vmg4YOKCCMgSdtYjRG7Tti2GiP3y4OoUjt)lIYEeStqBgotOvKgfX)sh3KP)frzpc2jOn4tYjP)LX0Xnz6Fru2JGDcQS38AY9U(S8QdCVDYq1AkAd5Ke(0tHOj(LIKMmweNSqh3KP)frzpc2jOObZESMerpgQJBY0)IOShb7eu0Gz)e5inwPX1Xnz6Fru2JGDcQqVcnkyuZ8tKgCVDYq1AkHEfAuWOM5NiTcI0MxKdbOO1X1XbSaw9D4vhh130GDyQVMm9V0xrO)qpJsF5oj1Xnz6FrueV644PqVcKe6XqDCtM(xefXRooc2jOCJTn5gPhCVDYq1AQ(pN9wfuuIGaYbGuf2EyhQeHoTXNCJTnnzsz5djkuGuUOigeKHQ1uIqN24tUX2MMmPS8HefjnzSia6iRJBY0)IOiE1XrWobvOxHgfmQz(jsdU3obCgQwtj0RqJcg1m)ePvuI64Mm9VikIxDCeStqj5dPjj0JHG7TtivHTh2HQW)0tHEfikuGuUOigeKHQ1uH)PNc9kquuI64Mm9VikIxDCeStqLqJ0p5ExFwE1bU3oHuf2EyhQc)tpf6vGOqbs5IIyqqgQwtf(NEk0RarrjQJBY0)IOiE1XrWob1L4KKqpgcU3oHuf2EyhQc)tpf6vGOqbs5IIyqqgQwtf(NEk0RarrjQJBY0)IOiE1XrWobLqvbe6vh4E7esvy7HDOk8p9uOxbIcfiLlkIbbzOAnv4F6PqVcefLOoUjt)lII4vhhb7eurOt)WGB8PqJncU3ozOAnLi0PFyWn(uOXgvHxyj4bGMhMiBSsLfceLxrCyGaciqZdtKnwPYcbIYRdb0rwh3KP)frr8QJJGDcAJB04K0)YyG7TtapDzmV60Xnz6FrueV64iyNGY9U(S8QBY88eCVDYq1AkAd5Ke(0tHOj(LIKMmweNSqqgQwtjcD6hgCJpfASrfLOGqZdtKnwPYcbIYRiyOAnLi0PFyWn(uOXgvqK28IOJBY0)IOiE1XrWobLnser4m)ePb3BNqZdtKnwPYcbIYRioC064Mm9VikIxDCeStqBWNKts)lJbU3ozOAnvV5Cs(qAfLOoUjt)lII4vhhb7eu0GzpwtIOhd1Xnz6FrueV64iyNGYn22KBKEW92z4tvJB04K0)Yyki2GiP3y4OoUjt)lII4vhhb7e0MHZeAfPrr8Va3BNaoKQW2d7qfbXaz(Tj0OfTkNDWxy2Rqbs5IIyaeqK)ZdVWs1qOXNerh6PcI0MxKiau064Mm9VikIxDCeStqj5dPjj0JHG7TZ04yLks(q6gNccJsHLXWXGGmuTMIKpKMb6vhcvuI64Mm9VikIxDCeStqL9MxtU31NLxDG7TtgQwtrYhshdrreQOe1Xnz6FrueV64iyNGICKgR04tgUrsW92jdvRPOnKts4tpfIM4xksAYyrCYcDCtM(xefXRooc2jO9OX9QBssiA0Z8tKgCVDcPkS9WoubToV6MSrIicNSFyIrQcfiLlkIbbtJJvQqdM9tsVJ8GclJHJbbpaBKiIWz(jsp7rJpL9gSdjrWkiGCa2ireHZ8tKE2JgFk7nyhsIiAbHMhMiBSsLfceLxrCagQwtXgjIiCMFI0kisBErIeauKJCK1Xnz6FrueV64iyNGIgm7NKEh5bW92jKQW2d7qf068QBYgjIiCY(HjgPkuGuUOigemnowPcny2pj9oYdkSmgoge8aSrIicN5Ni9Shn(u2BWoKebRGaYbyJereoZpr6zpA8PS3GDijIOfeAEyISXkvwiquEfXbyOAnfBKiIWz(jsRGiT5fjsaqroYrwh3KP)frr8QJJGDcQS38A2Bq2ijb3BNmuTMI2qojHp9uiAIFPiPjJfXjleeAEyISXkvwiquEfX5bhToUjt)lII4vhhb7euU31NLxDtMNNG7TtgQwtrBiNKWNEkenXVuK0KXoznAbzOAnLi0PFyWn(uOXgvHxyPJBY0)IOiE1XrWobLKpKMKqpgQJBY0)IOiE1XrWobLKpKogIIieCVDYq1AkAd5Ke(0tHOj(LIKMmweNSqh3KP)frr8QJJGDcAJJKEj0Aj4ELiesjMNScU3ojpfNXRGI9ZT054K8C2yL64Mm9VikIxDCeStqf6vOrbJAMFI0G7TtgQwtj0RqJcg1m)ePvqK28ICiwJwh3KP)frr8QJJGDck3yBtUr61Xnz6FrueV64iyNGY9U(S8QBY88eCVDYq1AkAd5Ke(0tHOj(LIKMmweNSqqgQwtjcD6hgCJpfASrv4fw64Mm9VikIxDCeStqjuvaHE1bU3oHMhMiBSsLfceLxrCE4O1Xnz6FrueV64iyNG2GpjNK(xgth3KP)frr8QJJGDcQeAK(j376ZYRoDCtM(xefXRooc2jOUeNKe6XqDCtM(xefXRooc2jOnhIZ6zBG7TttMoBCg(u14gnoj9VmMoUjt)lII4vhhb7e0ghj9sO1sW92j5P4mEfuIuKKIJtesjM(x64Mm9VikIxDCeStqrdM9tKJ0yLgxh3KP)frr8QJJGDcAJB04K0)YyG7TtcMPxDevZ5Ceoj9VmMoUjt)lII4vhhb7euHEfAuWOM5Nin4E7KHQ1uc9k0OGrnZprAfePnVihcqrVdJk7F4ogoDKCZn3fa]] )


end
