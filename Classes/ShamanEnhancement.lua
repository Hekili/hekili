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


    spec:RegisterPack( "Enhancement", 20220302, [[duKmmbqiaQEeajBIa9jcWOubCkHOEfqAwav3sic2fj)cOmmHuhdL0Yub9maX0aOCnucBdqQVHseJdqsNdGuRdLOmpaI7PI2Nq4GasWcbupuiIUOkq6JQaHtIsKwPq1mrjQUjGeANQq)eqIwQqe6Pkmva8vvGOXQcu7vP)QObRshMYIrXJjAYcUm0MLYNLkJwQ60u9AHYSr1TrQDl53QA4e64eqlh0ZrmDrxhjBhL67e04fI05fsMpqSFs9Y6cWocwI7XdJ(WdJgirFOIvanlaQazhzuI4oenzmRd3rz04ooOvVvsKgRChIwu83cla7G8uqjUJHthj3bdLZtwATm7iyjUhpm6dpmAGe9Hkwb0SaOEiqDheruUhpeObYo69qaRLzhbKi3XbT6TsI0yL67O3OTshhOObL967HGRVhg9HhUdUtsYcWoiE1XXfG9iRla7WKP)1oe6vGKqpgUdSmgogwG3CpE4cWoWYy4yybEhsONi0TDWq1AQ(pN9wfuuI6liGOVhqFHuf2EyhQeHoTXNCJTnnzsz5djkuGuUOig0xb1xgQwtjcDAJp5gBBAYKYYhsuK0KX03i0xGwFJ8omz6FTdUX2MCJ0V5Eeila7alJHJHf4DiHEIq32bGRVmuTMsOxHgfmQz(jsROe3Hjt)RDi0RqJcg1m)eP3Cpcyla7alJHJHf4DiHEIq32bKQW2d7qv4F6PqVcefkqkxued6RG6ldvRPc)tpf6vGOOe3Hjt)RDqYhstsOhd3CpYIfGDGLXWXWc8oKqprOB7asvy7HDOk8p9uOxbIcfiLlkIb9vq9LHQ1uH)PNc9kquuI7WKP)1oKqJ0p5ExFwE1T5EeOxa2bwgdhdlW7qc9eHUTdivHTh2HQW)0tHEfikuGuUOig0xb1xgQwtf(NEk0RarrjUdtM(x7WL4KKqpgU5EKLSaSdSmgogwG3He6jcDBhqQcBpSdvH)PNc9kquOaPCrrmOVcQVmuTMk8p9uOxbIIsChMm9V2bHQci0RUn3Ja1fGDGLXWXWc8oKqprOB7GHQ1uIqN(Hb34tHgBufEHL(kO(Ea9fAEyISXkvwiquEPVrOVa2H6liGOVqZdtKnwPYcbIYl9fq0xGwFJ8omz6FTdrOt)WGB8PqJnU5EeqVaSdSmgogwG3He6jcDBhaU(MUmMxD7WKP)1oACJgNK(xgBZ9iRrVaSdSmgogwG3He6jcDBhmuTMI2qojHp9uiAIFPiPjJPVrCQVSqFfuFzOAnLi0PFyWn(uOXgvuI6RG6l08WezJvQSqGO8sFJqFzOAnLi0PFyWn(uOXgvqK28ISdtM(x7G7D9z5v3K555M7rwzDbyhyzmCmSaVdj0te62oGMhMiBSsLfceLx6Be6lGf9omz6FTd2ireHZ8tKEZ9iRhUaSdSmgogwG3He6jcDBhmuTMQ3CojFiTIsChMm9V2rd(KCs6FzSn3JScKfGDyY0)AhObZESMerpgUdSmgogwG3CpYkGTaSdSmgogwG3He6jcDBhHpvnUrJts)lJPGydIKEJHJ7WKP)1o4gBBYns)M7rwzXcWoWYy4yybEhsONi0TDa46lKQW2d7qfbXaz(Tj0OfTkNDWxy2Rqbs5IIyqFbbe9v(pp8clvdHgFseDONkisBEr03i0xGe9omz6FTJMHZeAfPrr8V2CpYkqVaSdSmgogwG3He6jcDBhPXXkvK8H0nofegLclJHJb9vq9LHQ1uK8H0mqV6qOIsChMm9V2bjFinjHEmCZ9iRSKfGDGLXWXWc8oKqprOB7GHQ1uK8H0XqueHkkXDyY0)AhYEZRj376ZYRUn3JScuxa2bwgdhdlW7qc9eHUTdgQwtrBiNKWNEkenXVuK0KX03io1xwSdtM(x7a5inwPXNmCJKBUhzfqVaSdSmgogwG3He6jcDBhqQcBpSdvqRZRUjBKiIWj7hMyKQqbs5IIyqFfuFtJJvQqdM9tsVJ8GclJHJb9vq99a6lBKiIWz(jsp7rJpL9gSdj6Be6lR6liGOVhqFzJereoZpr6zpA8PS3GDirFJqFJwFfuFHMhMiBSsLfceLx6Be67b0xgQwtXgjIiCMFI0kisBEr03ib9fi6BK13iRVrEhMm9V2rpACV6MKeIg9m)eP3CpEy0la7alJHJHf4DiHEIq32bKQW2d7qf068QBYgjIiCY(HjgPkuGuUOig0xb1304yLk0Gz)K07ipOWYy4yqFfuFpG(YgjIiCMFI0ZE04tzVb7qI(gH(YQ(cci67b0x2ireHZ8tKE2JgFk7nyhs03i03O1xb1xO5HjYgRuzHar5L(gH(Ea9LHQ1uSrIicN5NiTcI0Mxe9nsqFbI(gz9nY6BK3Hjt)RDGgm7NKEh5Hn3JhY6cWoWYy4yybEhsONi0TDWq1AkAd5Ke(0tHOj(LIKMmM(gXP(Yc9vq9fAEyISXkvwiquEPVrCQVa6O3Hjt)RDi7nVM9gKnsYn3JhE4cWoWYy4yybEhsONi0TDWq1AkAd5Ke(0tHOj(LIKMmM(EQVSgT(kO(Yq1AkrOt)WGB8PqJnQcVWAhMm9V2b376ZYRUjZZZn3JhcKfGDyY0)AhK8H0Ke6XWDGLXWXWc8M7XdbSfGDGLXWXWc8oKqprOB7GHQ1u0gYjj8PNcrt8lfjnzm9nIt9Lf7WKP)1oi5dPJHOic3CpEilwa2bwgdhdlW7qc9eHUTdYtXz8kOy)ClDoojpNnwPclJHJHDyY0)Ahnos6LqRL7WReHqkXChSU5E8qGEbyhyzmCmSaVdj0te62oyOAnLqVcnkyuZ8tKwbrAZlI(ci6lRrVdtM(x7qOxHgfmQz(jsV5E8qwYcWomz6FTdUX2MCJ0VdSmgogwG3CpEiqDbyhyzmCmSaVdj0te62oyOAnfTHCscF6Pq0e)srstgtFJ4uFzH(kO(Yq1AkrOt)WGB8PqJnQcVWAhMm9V2b376ZYRUjZZZn3JhcOxa2bwgdhdlW7qc9eHUTdO5HjYgRuzHar5L(gXP(cyrVdtM(x7Gqvbe6v3M7rGe9cWomz6FTJg8j5K0)Yy7alJHJHf4n3JaH1fGDyY0)AhsOr6NCVRplV62bwgdhdlWBUhbYHla7WKP)1oCjojj0JH7alJHJHf4n3Jabila7alJHJHf4DiHEIq32HjtNnodFQACJgNK(xgBhMm9V2rZH4SE22M7rGayla7alJHJHf4DiHEIq32b5P4mEfuIuKKIJtesjM(xkSmgog2Hjt)RD04iPxcTwU5EeiSybyhMm9V2bAWSFICKgR047alJHJHf4n3JabOxa2bwgdhdlW7qc9eHUTdcMPxDevZ5Ceoj9Vm2omz6FTJg3OXjP)LX2CpcewYcWoWYy4yybEhsONi0TDWq1AkHEfAuWOM5NiTcI0Mxe9fq0xGe9omz6FTdHEfAuWOM5Ni9MBUd7XfG9iRla7alJHJHf4DiHEIq32bdvRPOnKts4tpfIM4xksAYy6BeN6ll2Hjt)RDi7nVM9gKnsYn3JhUaSdSmgogwG3He6jcDBhqQcBpSdvH)PNc9kquOaPCrrmOVcQVmuTMk8p9uOxbIIsChMm9V2HeAK(j376ZYRUn3JazbyhyzmCmSaVdj0te62oGuf2EyhQc)tpf6vGOqbs5IIyqFfuFzOAnv4F6PqVcefL4omz6FTdcvfqOxDBUhbSfGDGLXWXWc8oKqprOB7asvy7HDOcADE1nzJereoz)WeJufkqkxued6RG6BACSsfAWSFs6DKhuyzmCmOVcQVSrIicN5Ni9Shn(u2BWoKOVrOVrVdtM(x7OhnUxDtscrJEMFI0BUhzXcWoWYy4yybEhsONi0TDaPkS9WoubToV6MSrIicNSFyIrQcfiLlkIb9vq9nnowPcny2pj9oYdkSmgog0xb1x2ireHZ8tKE2JgFk7nyhs03i03O3Hjt)RDGgm7NKEh5Hn3Ja9cWoWYy4yybEhsONi0TDyY0zJZWNQg3OXjP)LX03io1xGwFbbe99a6RjtNnodFQACJgNK(xgtFJ4uFbm9vq91KPZgNHpvnUrJts)lJPVrCQVYOKCCIfs7irFJ8omz6FTJMdXz9STn3JSKfGDGLXWXWc8omz6FTdrOt)WGB8PqJnUdj0te62oaC9LHQ1uIqN(Hb34tHgBurjUdzusootd2HjzpY6M7rG6cWoWYy4yybEhsONi0TDaPkS9WoufquKh1e(FIHjYrASsIcfiLlkIb9vq9LHQ1usOr6NCVRplV6uuI7WKP)1oe6vGKqpgU5EeqVaSdSmgogwG3He6jcDBhqQcBpSdvbef5rnH)NyyICKgRKOqbs5IIyqFfuFzOAnLeAK(j376ZYRofL4omz6FTds(qAsc9y4M7rwJEbyhyzmCmSaVdtM(x7GBSTj3i97qc9eHUTJWNQg3OXjP)LXuPlJ5vN(kO(Ea91KPZgNHpvnUrJts)lJPVaI(kJsYXjwiTJe9vq91KPZgNHpvnUrJts)lJPVaI(c06BK3HmkjhNPb7WKShzDZ9iRSUaSdSmgogwG3He6jcDBhaU(MUmMxD7WKP)1oACJgNK(xgBZ9iRhUaSdSmgogwG3Hjt)RD04gnoj9Vm2oKqprOB7aW1304yLQEZ5K8H0kSmgog0xb1xtMoBCg(u14gnoj9VmM(ci6RmkjhNyH0os0xb1xtMoBCg(u14gnoj9VmM(ci6lqVdzusootd2HjzpY6M7rwbYcWoWYy4yybEhsONi0TDCa91KPZgNHpvnUrJts)lJPVrCQVYOKCCIfs7irFbbe91KPZgNHpvnUrJts)lJPVrCQVaM(gz9vq9LHQ1uIqN(Hb34tHgBurjQVcQVmuTMI2qojHp9uiAIFPiPjJPVrCQVSyhMm9V2b376ZYRUjZZZn3JScyla7alJHJHf4DiHEIq32bdvRP6nNtYhsROe3Hjt)RD0GpjNK(xgBZ9iRSybyhyzmCmSaVdj0te62oipfNXRGQd(SXPxS9UhAP)LclJHJb9feq0xYtXz8kOAoYdZVnz4pH80efwgdhd6liGOVqQcBpSdveedK53MqJw0QC2bFHzVcfiLlkIHDyY0)AhndNj0ksJI4FT5EKvGEbyhyzmCmSaVdj0te62oyOAnLeAK(j376ZYRov4fw6RG6ldvRPeHo9ddUXNcn2OIsuFfuFzOAnfTHCscF6Pq0e)srstgtFbe9Lf7WKP)1oKqJ0p5ExFwE1T5EKvwYcWoWYy4yybEhsONi0TDWq1AkrOt)WGB8PqJnQOe1xb1xgQwtrBiNKWNEkenXVuK0KX0xarFzXomz6FTdcvfqOxDBUhzfOUaSdSmgogwG3He6jcDBhmuTMse60pm4gFk0yJkkr9vq9LHQ1u0gYjj8PNcrt8lfjnzm9fq0xwSdtM(x7GKpKMKqpgU5EKva9cWomz6FTdcvfqOxD7alJHJHf4n3Jhg9cWoWYy4yybEhsONi0TDyY0zJZWNQg3OXjP)LX03io1xaBhMm9V2rZH4SE22M7XdzDbyhyzmCmSaVdj0te62osJJvQKqJ07v3KKpKwHLXWXG(cci6ldvRPKqJ0p5ExFwE1PcVWAhMm9V2HeAK(j376ZYRUn3JhE4cWoWYy4yybEhMm9V2b3yBtUr63He6jcDBhPXXkvCJ07v3SXnAKOWYy4yyhYOKCCMgSdtYEK1n3JhcKfGDGLXWXWc8oKqprOB7WKPZgNHpvnUrJts)lJPVrCQVazhMm9V2rZH4SE22M7XdbSfGDyY0)AhSrIicN5Ni9oWYy4yybEZ94HSybyhyzmCmSaVdj0te62oyOAnfjFiDmefrOIsChMm9V2HS38AY9U(S8QBZ94Ha9cWoWYy4yybEhsONi0TDWq1Akj0i9tU31NLxDkkXDyY0)AhCJTn5gPFZ94HSKfGDGLXWXWc8oKqprOB7GHQ1usOr6NCVRplV6uuI7WKP)1oi5dPjj0JHBUhpeOUaSdSmgogwG3He6jcDBhMmD24m8PQXnACs6Fzm9nIt99WDyY0)AhnhIZ6zBBUhpeqVaSdSmgogwG3He6jcDBhmuTMI2qojHp9uiAIFPiPjJPVrCQVSyhMm9V2bYrASsJpz4gj3CpcKOxa2bwgdhdlW7qc9eHUTdgQwtrBiNKWNEkenXVuK0KX03io1xwSdtM(x7GKpKogIIiCZ9iqyDbyhMm9V2HeAK(j376ZYRUDGLXWXWc8M7rGC4cWoWYy4yybEhsONi0TDWq1AkAd5Ke(0tHOj(LIKMmM(EQVSg9omz6FTdzV51K7D9z5v3M7rGaKfGDyY0)Ahc9kqsOhd3bwgdhdlWBUhbcGTaSdtM(x7GKpKMKqpgUdSmgogwG3CpcewSaSdSmgogwG3He6jcDBhKNIZ4vqX(5w6CCsEoBSsfwgdhd7WKP)1oACK0lHwl3HxjcHuI5oyDZ9iqa6fGDGLXWXWc8omz6FTJg3OXjP)LX2He6jcDBhqSbrsVXWXDiJsYXzAWomj7rw3CpcewYcWomz6FTJMHZeAfPrr8V2bwgdhdlWBUhbcqDbyhMm9V2rd(KCs6FzSDGLXWXWc8M7rGaOxa2bwgdhdlW7qc9eHUTdgQwtrBiNKWNEkenXVuK0KX03io1xwSdtM(x7q2BEn5ExFwE1T5EeWIEbyhMm9V2bAWShRjr0JH7alJHJHf4n3JagRla7WKP)1oqdM9tKJ0yLgFhyzmCmSaV5EeWoCbyhyzmCmSaVdj0te62oyOAnLqVcnkyuZ8tKwbrAZlI(ci6lqIEhMm9V2HqVcnkyuZ8tKEZn3raBgfpxa2JSUaSdtM(x7GH)FGtrYDGLXWXWYS5E8WfGDGLXWXWc8oKqprOB7G5je9vq9T5D95eI0Mxe9fq0xGo6DeqIe6IP)1oyPvKG8PzSuFf)0)sFDI(YGThI6R8PzSuFXkqu7WKP)1oe)0)AZ9iqwa2bwgdhdlW7iGej0ft)RDWsReHqkXChMm9V2HqVctspAWn3Ja2cWomz6FTdkco9ePj7alJHJHf4n3JSybyhyzmCmSaVdj0te62oaC9nnowPYisScwjrfwgdhd6liGOVmuTMYisScwjrfLO(cci6R8FE4fwkJiXkyLevqK28IOVrOVSi6DyY0)Ahm8)dZgfmQn3Ja9cWoWYy4yybEhsONi0TDa46BACSsLrKyfSsIkSmgog0xqarFzOAnLrKyfSsIkkXDyY0)AhmiKGWyE1T5EKLSaSdSmgogwG3He6jcDBhaU(MghRuzejwbRKOclJHJb9feq0xgQwtzejwbRKOIsuFbbe9v(pp8clLrKyfSsIkisBEr03i0xwe9omz6FTJMdrg()Hn3Ja1fGDGLXWXWc8oKqprOB7aW1304yLkJiXkyLevyzmCmOVGaI(Yq1AkJiXkyLevuI6liGOVY)5HxyPmIeRGvsubrAZlI(gH(YIO3Hjt)RDyLejj04tPX5BUhb0la7alJHJHf4DiHEIq32bGRVPXXkvgrIvWkjQWYy4yqFbbe9fW1xgQwtzejwbRKOIsChMm9V2bJ1n)2mHUmgzZ9iRrVaSdtM(x7OHqJpjIo0ZDGLXWXWc8M7rwzDbyhyzmCmSaVdj0te62ooG(MghRuzejwbRKOclJHJb9feq0xivHTh2HQW)0tHEfikuGuUOig03iRVcQVhqFjpfNXRGQd(SXPxS9UhAP)LclJHJb9feq0xYtXz8kOAoYdZVnz4pH80efwgdhd6liGOVMmD24elK2rI(EQVSQVrEhMm9V2rZWzcTI0Oi(xBUhz9WfGDGLXWXWc8oKqprOB7aAEyISXkvwiquEPVrCQVa6O1xqarFnz6SXjwiTJe9nc9L1DyY0)AhgrIvWkjU5EKvGSaSdSmgogwG3Hjt)RDi0RqJcg1m)eP3He6jcDBhqQcBpSdvH)PNc9kquOaPCrrmOVcQVmuTMk8p9uOxbYmGmuTMk8cl9vq99a6l08WezJvQSqGO8sFJ4uFb6O1xqarFnz6SXjwiTJe9nc9Lv9nY6liGOVmuTMsOxHgfmQz(jsRcVWsFfuFpG(c46lKQW2d7qv4F6PqVcefkqkxued6liGOVmuTMk8p9uOxbYmGmuTMIsuFJ8o4EHtzyhSYIn3JScyla7alJHJHf4DeqIe6IP)1oyPn99lEu67xO(Ifshf46Ri0FONrPVTNZFHe9n7r9vaeV64Oa0xtM(x6l3jPAhMm9V2H048Pjt)Rj3j5oij0L5EK1DiHEIq32HjtNnoXcPDKOVN6lR7G7KCwgnUdIxDCCZ9iRSybyhyzmCmSaVJasKqxm9V2bqzPV0u80f5O(Ifs7ibC9n7r9ve6p0ZO032Z5VqI(M9O(ka7rbOVMm9V0xUts1omz6FTdPX5ttM(xtUtYDqsOlZ9iR7qc9eHUTdtMoBCIfs7irFJqFzDhCNKZYOXDypU5EKvGEbyhMm9V2H8PQeHKe6XWz(jsVdSmgogwG3CpYklzbyhMm9V2bjwunkyuZ8tKEhyzmCmSaV5EKvG6cWomz6FTdrOtB8jjHEmChyzmCmSaV5M7qeIYNMXYfG9iRla7alJHJHf4DiHEIq32bdvRPe6vOrbJAkenXVuqK28IOVaI(cKOJEhMm9V2HqVcnkyutHOj(1M7Xdxa2bwgdhdlW7qc9eHUTdgQwt14gnMF1rHtHOj(LcI0Mxe9fq0xGeD07WKP)1oACJgZV6OWPq0e)AZ9iqwa2Hjt)RDW8zYXWSXTOWGqV6M5hPETdSmgogwG3Cpcyla7alJHJHf4DiHEIq32bdvRP4ExFwE1nj9oYdkisBEr0xarFbs0rVdtM(x7G7D9z5v3K07ipS5EKfla7alJHJHf4DiHEIq32rACSsfjFiDmefrOclJHJHDyY0)AhK8H0XqueHBUhb6fGDGLXWXWc8oKqprOB7aW1xivHTh2HQW)0tHEfikuGuUOig0xb1xgQwtj0RqJcg1m)ePvHxyTdtM(x7qOxHgfmQz(jsV5EKLSaSdSmgogwG3He6jcDBhKNIZ4vqjsrskooriLy6FPWYy4yqFbbe9L8uCgVck2p3sNJtYZzJvQWYy4yyhMm9V2rJJKEj0A5M7rG6cWoWYy4yybEhsONi0TDW8eYomz6FTdXp9V2CZn3bBes8V2Jhg9HhgnqI(WDi0GLxDKDCqcuis8il94bbltF1xa6r91PfFyQVThQVcWEua6lefiLdXG(sEAuFnQ8PTed6RS3QoKO0Xz5EH6lRSGLPVrYVyJWed6RaipfNXRG6GfG(MV(kaYtXz8kOoyfwgdhdcqFpWHrAKv64SCVq9fiSGLPVrYVyJWed6RaipfNXRG6GfG(MV(kaYtXz8kOoyfwgdhdcqFTuFpOaLSC99aSgPrwPJRJFqcuis8il94bbltF1xa6r91PfFyQVThQVcG4vhhfG(crbs5qmOVKNg1xJkFAlXG(k7TQdjkDCwUxO(Eilyz6BK8l2imXG(kaYtXz8kOoybOV5RVcG8uCgVcQdwHLXWXGa0xl13dkqjlxFpaRrAKv64SCVq9fiagltFJKFXgHjg0xbqEkoJxb1bla9nF9vaKNIZ4vqDWkSmgogeG(AP(Eqbkz567bynsJSshxh)GeOqK4rw6XdcwM(QVa0J6Rtl(WuFBpuFfqaBgfpfG(crbs5qmOVKNg1xJkFAlXG(k7TQdjkDCwUxO(YkRSm9ns(fBeMyqFfa5P4mEfuhSa0381xbqEkoJxb1bRWYy4yqa67bomsJSshxh)GeOqK4rw6XdcwM(QVa0J6Rtl(WuFBpuFfGieLpnJLcqFHOaPCig0xYtJ6RrLpTLyqFL9w1HeLool3luFzjSm9ns(fBeMyqFfa5P4mEfuhSa0381xbqEkoJxb1bRWYy4yqa67bynsJSshNL7fQVSewM(gj)InctmOVcG8uCgVcQdwa6B(6RaipfNXRG6GvyzmCmia91s99GcuYY13dWAKgzLoUoolLw8Hjg0xatFnz6FPVCNKeLo(oeHFZ54oauak99Gw9wjrASs9D0B0wPJdOau6lqrdk713dbxFpm6dpuhxh3KP)frjcr5tZy5PqVcnkyutHOj(f4E7KHQ1uc9k0OGrnfIM4xkisBEraeGeD064Mm9VikrikFAglb9eSg3OX8RokCkenXVa3BNmuTMQXnAm)QJcNcrt8lfePnViacqIoADCtM(xeLieLpnJLGEcgZNjhdZg3Icdc9QBMFK6LoUjt)lIseIYNMXsqpbJ7D9z5v3K07ipaU3ozOAnf376ZYRUjP3rEqbrAZlcGaKOJwh3KP)frjcr5tZyjONGrYhshdrrecU3otJJvQi5dPJHOicvyzmCmOJBY0)IOeHO8PzSe0tWe6vOrbJAMFI0G7Ttahsvy7HDOk8p9uOxbIcfiLlkIbbzOAnLqVcnkyuZ8tKwfEHLoUjt)lIseIYNMXsqpbRXrsVeATeCVDsEkoJxbLifjP44eHuIP)fiGqEkoJxbf7NBPZXj55SXk1Xnz6FruIqu(0mwc6jyIF6FbU3ozEcrhxhhqbO03dAKIsQed6lYgHrPVPtJ6B2J6RjZhQVorFn2MZngoQ0Xnz6Froz4)h4uKuhhqPVS0ksq(0mwQVIF6FPVorFzW2dr9v(0mwQVyfikDCtM(xeqpbt8t)lW92jZtic28U(CcrAZlcGa0rRJdO0xwALiesjM64Mm9ViGEcMqVctspAqDCtM(xeqpbJIGtprAIoUjt)lcONGXW)pmBuWOa3BNaEACSsLrKyfSsIkSmgogabegQwtzejwbRKOIseeqK)ZdVWszejwbRKOcI0MxKiyr064Mm9ViGEcgdcjimMxDG7TtapnowPYisScwjrfwgdhdGacdvRPmIeRGvsurjQJBY0)Ia6jynhIm8)dG7TtapnowPYisScwjrfwgdhdGacdvRPmIeRGvsurjcciY)5HxyPmIeRGvsubrAZlseSiADCtM(xeqpbZkjssOXNsJZb3BNaEACSsLrKyfSsIkSmgogabegQwtzejwbRKOIseeqK)ZdVWszejwbRKOcI0MxKiyr064Mm9ViGEcgJ1n)2mHUmgbCVDc4PXXkvgrIvWkjQWYy4yaeqaCgQwtzejwbRKOIsuh3KP)fb0tWAi04tIOd9uh3KP)fb0tWAgotOvKgfX)cCVDEG04yLkJiXkyLevyzmCmaciqQcBpSdvH)PNc9kquOaPCrrmezbpa5P4mEfuDWNno9IT39ql9VabeYtXz8kOAoYdZVnz4pH80eqaXKPZgNyH0osoznY64Mm9ViGEcMrKyfSsIG7TtO5HjYgRuzHar5veNa6ObbetMoBCIfs7ijcw1Xnz6Fra9emHEfAuWOM5Nin4CVWPmCYkla3BNqQcBpSdvH)PNc9kquOaPCrrmiidvRPc)tpf6vGmdidvRPcVWsWdanpmr2yLkleikVI4eOJgeqmz6SXjwiTJKiynYGacdvRPe6vOrbJAMFI0QWlSe8aaoKQW2d7qv4F6PqVcefkqkxuedGacdvRPc)tpf6vGmdidvRPOeJSooGsFzPn99lEu67xO(Ifshf46Ri0FONrPVTNZFHe9n7r9vaeV64Oa0xtM(x6l3jPsh3KP)fb0tWKgNpnz6Fn5ojbVmA8K4vhhbNKqxMNScU3onz6SXjwiTJKtw1Xbu6lqzPV0u80f5O(Ifs7ibC9n7r9ve6p0ZO032Z5VqI(M9O(ka7rbOVMm9V0xUtsLoUjt)lcONGjnoFAY0)AYDscEz04P9i4Ke6Y8KvW92PjtNnoXcPDKebR64Mm9ViGEcM8PQeHKe6XWz(jsRJBY0)Ia6jyKyr1OGrnZprADCtM(xeqpbte60gFssOhd1X1Xbuak9fOifpD9nnyhM6Rjt)l9ve6p0ZO0xUtsDCtM(xeL94PS38A2Bq2ijb3BNmuTMI2qojHp9uiAIFPiPjJfXjl0Xnz6Fru2JGEcMeAK(j376ZYRoW92jKQW2d7qv4F6PqVcefkqkxuedcYq1AQW)0tHEfikkrDCtM(xeL9iONGrOQac9QdCVDcPkS9Wouf(NEk0RarHcKYffXGGmuTMk8p9uOxbIIsuh3KP)frzpc6jy9OX9QBssiA0Z8tKgCVDcPkS9WoubToV6MSrIicNSFyIrQcfiLlkIbbtJJvQqdM9tsVJ8GclJHJbbzJereoZpr6zpA8PS3GDijIO1Xnz6Fru2JGEcgAWSFs6DKha3BNqQcBpSdvqRZRUjBKiIWj7hMyKQqbs5IIyqW04yLk0Gz)K07ipOWYy4yqq2ireHZ8tKE2JgFk7nyhsIiADCtM(xeL9iONG1CioRNTbU3onz6SXz4tvJB04K0)YyrCc0GaYbmz6SXz4tvJB04K0)YyrCcycAY0zJZWNQg3OXjP)LXI4ugLKJtSqAhjrwh3KP)frzpc6jyIqN(Hb34tHgBeCzusootd2Hj5KvW92jGZq1AkrOt)WGB8PqJnQOe1Xnz6Fru2JGEcMqVcKe6XqW92jKQW2d7qvarrEut4)jgMihPXkjkuGuUOigeKHQ1usOr6NCVRplV6uuI64Mm9Vik7rqpbJKpKMKqpgcU3oHuf2EyhQcikYJAc)pXWe5inwjrHcKYffXGGmuTMscns)K7D9z5vNIsuh3KP)frzpc6jyCJTn5gPhCzusootd2Hj5KvW92z4tvJB04K0)YyQ0LX8QtWdyY0zJZWNQg3OXjP)LXaezusooXcPDKiOjtNnodFQACJgNK(xgdqa6iRJBY0)IOShb9eSg3OXjP)LXa3BNaE6YyE1PJBY0)IOShb9eSg3OXjP)LXaxgLKJZ0GDysozfCVDc4PXXkv9MZj5dPvyzmCmiOjtNnodFQACJgNK(xgdqKrj54elK2rIGMmD24m8PQXnACs6FzmabO1Xnz6Fru2JGEcg376ZYRUjZZtW925bmz6SXz4tvJB04K0)YyrCkJsYXjwiTJeqaXKPZgNHpvnUrJts)lJfXjGfzbzOAnLi0PFyWn(uOXgvuIcYq1AkAd5Ke(0tHOj(LIKMmweNSqh3KP)frzpc6jyn4tYjP)LXa3BNmuTMQ3CojFiTIsuh3KP)frzpc6jyndNj0ksJI4FbU3ojpfNXRGQd(SXPxS9UhAP)fiGqEkoJxbvZrEy(Tjd)jKNMaciqQcBpSdveedK53MqJw0QC2bFHzVcfiLlkIbDCtM(xeL9iONGjHgPFY9U(S8QdCVDYq1Akj0i9tU31NLxDQWlSeKHQ1uIqN(Hb34tHgBurjkidvRPOnKts4tpfIM4xksAYyacl0Xnz6Fru2JGEcgHQci0RoW92jdvRPeHo9ddUXNcn2OIsuqgQwtrBiNKWNEkenXVuK0KXaewOJBY0)IOShb9ems(qAsc9yi4E7KHQ1uIqN(Hb34tHgBurjkidvRPOnKts4tpfIM4xksAYyacl0Xnz6Fru2JGEcgHQci0RoDCtM(xeL9iONG1CioRNTbU3onz6SXz4tvJB04K0)YyrCcy64Mm9Vik7rqpbtcns)K7D9z5vh4E7mnowPscnsVxDts(qAfwgdhdGacdvRPKqJ0p5ExFwE1PcVWsh3KP)frzpc6jyCJTn5gPhCzusootd2Hj5KvW92zACSsf3i9E1nBCJgjkSmgog0Xnz6Fru2JGEcwZH4SE2g4E70KPZgNHpvnUrJts)lJfXjq0Xnz6Fru2JGEcgBKiIWz(jsRJBY0)IOShb9emzV51K7D9z5vh4E7KHQ1uK8H0XqueHkkrDCtM(xeL9iONGXn22KBKEW92jdvRPKqJ0p5ExFwE1POe1Xnz6Fru2JGEcgjFinjHEmeCVDYq1Akj0i9tU31NLxDkkrDCtM(xeL9iONG1CioRNTbU3onz6SXz4tvJB04K0)YyrCEOoUjt)lIYEe0tWqosJvA8jd3ij4E7KHQ1u0gYjj8PNcrt8lfjnzSiozHoUjt)lIYEe0tWi5dPJHOicb3BNmuTMI2qojHp9uiAIFPiPjJfXjl0Xnz6Fru2JGEcMeAK(j376ZYRoDCtM(xeL9iONGj7nVMCVRplV6a3BNmuTMI2qojHp9uiAIFPiPjJDYA064Mm9Vik7rqpbtOxbsc9yOoUjt)lIYEe0tWi5dPjj0JH64Mm9Vik7rqpbRXrsVeATeCVsecPeZtwb3BNKNIZ4vqX(5w6CCsEoBSsDCtM(xeL9iONG14gnoj9Vmg4YOKCCMgSdtYjRG7Tti2GiP3y4OoUjt)lIYEe0tWAgotOvKgfX)sh3KP)frzpc6jyn4tYjP)LX0Xnz6Fru2JGEcMS38AY9U(S8QdCVDYq1AkAd5Ke(0tHOj(LIKMmweNSqh3KP)frzpc6jyObZESMerpgQJBY0)IOShb9em0Gz)e5inwPX1Xnz6Fru2JGEcMqVcnkyuZ8tKgCVDYq1AkHEfAuWOM5NiTcI0MxeabirRJRJdOau67WRooQVPb7WuFnz6FPVIq)HEgL(YDsQJBY0)IOiE1XXtHEfij0JH64Mm9VikIxDCe0tW4gBBYnsp4E7KHQ1u9Fo7TkOOebbKdaPkS9WoujcDAJp5gBBAYKYYhsuOaPCrrmiidvRPeHoTXNCJTnnzsz5djksAYyra0rwh3KP)frr8QJJGEcMqVcnkyuZ8tKgCVDc4muTMsOxHgfmQz(jsROe1Xnz6FrueV64iONGrYhstsOhdb3BNqQcBpSdvH)PNc9kquOaPCrrmiidvRPc)tpf6vGOOe1Xnz6FrueV64iONGjHgPFY9U(S8QdCVDcPkS9Wouf(NEk0RarHcKYffXGGmuTMk8p9uOxbIIsuh3KP)frr8QJJGEcMlXjjHEmeCVDcPkS9Wouf(NEk0RarHcKYffXGGmuTMk8p9uOxbIIsuh3KP)frr8QJJGEcgHQci0RoW92jKQW2d7qv4F6PqVcefkqkxuedcYq1AQW)0tHEfikkrDCtM(xefXRooc6jyIqN(Hb34tHgBeCVDYq1AkrOt)WGB8PqJnQcVWsWdanpmr2yLkleikVIaWoeeqGMhMiBSsLfceLxacqhzDCtM(xefXRooc6jynUrJts)lJbU3ob80LX8Qth3KP)frr8QJJGEcg376ZYRUjZZtW92jdvRPOnKts4tpfIM4xksAYyrCYcbzOAnLi0PFyWn(uOXgvuIccnpmr2yLkleikVIGHQ1uIqN(Hb34tHgBubrAZlIoUjt)lII4vhhb9em2ireHZ8tKgCVDcnpmr2yLkleikVIaWIwh3KP)frr8QJJGEcwd(KCs6FzmW92jdvRP6nNtYhsROe1Xnz6FrueV64iONGHgm7XAse9yOoUjt)lII4vhhb9emUX2MCJ0dU3odFQACJgNK(xgtbXgej9gdh1Xnz6FrueV64iONG1mCMqRinkI)f4E7eWHuf2EyhQiigiZVnHgTOv5Sd(cZEfkqkxuedGaI8FE4fwQgcn(Ki6qpvqK28IebqIwh3KP)frr8QJJGEcgjFinjHEmeCVDMghRurYhs34uqyukSmgogeKHQ1uK8H0mqV6qOIsuh3KP)frr8QJJGEcMS38AY9U(S8QdCVDYq1Aks(q6yikIqfLOoUjt)lII4vhhb9emKJ0yLgFYWnscU3ozOAnfTHCscF6Pq0e)srstglItwOJBY0)IOiE1XrqpbRhnUxDtscrJEMFI0G7TtivHTh2HkO15v3Knser4K9dtmsvOaPCrrmiyACSsfAWSFs6DKhuyzmCmi4byJereoZpr6zpA8PS3GDijcwbbKdWgjIiCMFI0ZE04tzVb7qserli08WezJvQSqGO8kIdWq1Ak2ireHZ8tKwbrAZlsKaqICKJSoUjt)lII4vhhb9em0Gz)K07ipaU3oHuf2EyhQGwNxDt2ireHt2pmXivHcKYffXGGPXXkvObZ(jP3rEqHLXWXGGhGnser4m)ePN9OXNYEd2HKiyfeqoaBKiIWz(jsp7rJpL9gSdjreTGqZdtKnwPYcbIYRioadvRPyJereoZprAfePnVircajYroY64Mm9VikIxDCe0tWK9MxZEdYgjj4E7KHQ1u0gYjj8PNcrt8lfjnzSiozHGqZdtKnwPYcbIYRiob0rRJBY0)IOiE1XrqpbJ7D9z5v3K55j4E7KHQ1u0gYjj8PNcrt8lfjnzStwJwqgQwtjcD6hgCJpfASrv4fw64Mm9VikIxDCe0tWi5dPjj0JH64Mm9VikIxDCe0tWi5dPJHOicb3BNmuTMI2qojHp9uiAIFPiPjJfXjl0Xnz6FrueV64iONG14iPxcTwcUxjcHuI5jRG7TtYtXz8kOy)ClDoojpNnwPoUjt)lII4vhhb9emHEfAuWOM5Nin4E7KHQ1uc9k0OGrnZprAfePnViacRrRJBY0)IOiE1XrqpbJBSTj3i964Mm9VikIxDCe0tW4ExFwE1nzEEcU3ozOAnfTHCscF6Pq0e)srstglItwiidvRPeHo9ddUXNcn2Ok8clDCtM(xefXRooc6jyeQkGqV6a3BNqZdtKnwPYcbIYRiobSO1Xnz6FrueV64iONG1GpjNK(xgth3KP)frr8QJJGEcMeAK(j376ZYRoDCtM(xefXRooc6jyUeNKe6XqDCtM(xefXRooc6jynhIZ6zBG7TttMoBCg(u14gnoj9VmMoUjt)lII4vhhb9eSghj9sO1sW92j5P4mEfuIuKKIJtesjM(x64Mm9VikIxDCe0tWqdM9tKJ0yLgxh3KP)frr8QJJGEcwJB04K0)YyG7TtcMPxDevZ5Ceoj9VmMoUjt)lII4vhhb9emHEfAuWOM5Nin4E7KHQ1uc9k0OGrnZprAfePnViacqIEhgv2)WDmC6i5MBUl]] )


end
