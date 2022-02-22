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

            cycle = function () return talent.lashing_flames.enabled and "lashing_flames" or nil  end,

            handler = function ()
                removeDebuff( "target", "primal_primer" )

                if talent.lashing_flames.enabled then applyDebuff( "target", "lashing_flames" ) end

                removeBuff( "primal_lava_actuators" )

                if azerite.natural_harmony.enabled and buff.frostbrand.up then applyBuff( "natural_harmony_frost" ) end
                if azerite.natural_harmony.enabled then applyBuff( "natural_harmony_fire" ) end
                if azerite.natural_harmony.enabled and buff.crash_lightning.up then applyBuff( "natural_harmony_nature" ) end
                
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


    spec:RegisterPack( "Enhancement", 20220221, [[dyKmmbqiaQEearBcv0NqfmkrrDkrfEfqAwav3ciq7IKFbugMOshdLyzQGEgq00ev01qjzBaH(gaLgNOiCoGGwhkPY8aiDpv0(efoiqawiG8qrr0fbi0gbciFeGaNeLuSsrvZeLu6Mabu7uf6NOKQSuusv9ufMka(kabnwak2Rs)vrdwLomLfJIht0Kf5YqBwkFwQmAPQtt1RfLMnHBJODl53QA4OQJJk0Yb9CKMUW1ry7OuFhvA8II05vbMpGA)K6LLfGDKSa3JhM7HhM7HhYI6qwYzUhYQDehWJ7G3KzToChLrI7aqS6TsIKyf7G3oq8wAbyh0NakXDmCYm5oyiCrWAQLzhjlW94H5E4H5E4HSOoKLCM7H5ChuEuUhpeeb5o69ucRLzhjKk3bGy1BLejXk03rVrALopiqidKWGhOVhYc467H5E4H7q40GUaSdQxDcCbypYYcWomz4FTdUELOb0ZI7alJrGPfOn2JhUaSdSmgbMwG2He6bcDBhmeTMQ)JzVvjfbV(cmW6BM1xirHTh2HkEOtAIPWyBttgew8qQc5iHZZJj9Lt9LHO1u8qN0etHX2MMmiS4Hufnmzw9nd9fe13CSdtg(x7qySTPWO9BShb5cWoWYyeyAbAhsOhi0TDa46ldrRP46vQrapygFGKkc(DyYW)AhC9k1iGhmJpqYn2J5CbyhyzmcmTaTdj0de62oGef2EyhQs)to56vIQqos488ysF5uFziAnv6FYjxVsufb)omz4FTdA8qsAa9S4g7rwTaSdSmgbMwG2He6bcDBhqIcBpSdvP)jNC9krvihjCEEmPVCQVmeTMk9p5KRxjQIGFhMm8V2HeA0(PW76JYRUn2JG4cWoWYyeyAbAhsOhi0TDajkS9WouL(NCY1RevHCKW55XK(YP(Yq0AQ0)KtUELOkc(DyYW)AhUeN0a6zXn2Ja2fGDGLXiW0c0oKqpqOB7asuy7HDOk9p5KRxjQc5iHZZJj9Lt9LHO1uP)jNC9krve87WKH)1oOevcHE1TXEmtSaSdSmgbMwG2He6bcDBhaU(gUmRxD7WKH)1oAcJeN0(xMDJ9iiCbyhyzmcmTaTdj0de62oyiAnfPHcAaFYjx04)srdtMvFZ4uFzL(YP(Yq0AkEOt(WKBIjxJnQi41xo1xO5PjYgRqzPev5L(MH(Yq0AkEOt(WKBIjxJnQGiP5fDhMm8V2HW76JYRUjZlIn2JSK7cWoWYyeyAbAhsOhi0TDWq0AkEOt(WKBIjxJnQsp3sF5uFZS(cnpnr2yfklLOkV03m03CEO(cmW6l080ezJvOSuIQ8sFbu9fe13CSdtg(x7Gh6Kpm5MyY1yJBShzHLfGDGLXiW0c0oKqpqOB7aAEAISXkuwkrvEPVzOV5m3DyYW)AhSrkpcNXhi5g7rwoCbyhyzmcmTaTdj0de62oyiAnvV5cA8qsfb)omz4FTJg8PXK2)YSBShzbKla7WKH)1oqdg9ynP8EwChyzmcmTaTXEKLCUaSdSmgbMwG2He6bcDBhPpunHrItA)lZQGydI0EJrG7WKH)1oegBBkmA)g7rwy1cWoWYyeyAbAhsOhi0TDa46lKOW2d7qffXeD(Tj0i5TkMDWNB0Rqos488ysFbgy9v(Vi9ClvdHMys5DOhkisAEr13m0xqM7omz4FTJMHZaAfTrq9V2ypYciUaSdSmgbMwG2He6bcDBhHjWku04HKnbbeEGclJrGj9Lt9LHO1u04HKmqV6qOIGFhMm8V2bnEijnGEwCJ9ila2fGDGLXiW0c0oKqpqOB7GHO1u04HKzrKhHkc(DyYW)AhYEZRPW76JYRUn2JSKjwa2bwgJatlq7qc9aHUTdgIwtrAOGgWNCYfn(Vu0WKz13mo1xwTdtg(x7afijwHjMmcJgBShzbeUaSdSmgbMwG2He6bcDBhqIcBpSdvqRZRUjBKYJWj7hgyMQqos488ysF5uFdtGvOqdg9tAVJIKclJrGj9Lt9nZ6lBKYJWz8bso7rtmL9gSdP6Bg6ll6lWaRVzwFzJuEeoJpqYzpAIPS3GDivFZqFZvF5uFHMNMiBScLLsuLx6Bg6BM1xgIwtXgP8iCgFGKkisAEr1xqq9fK6Bo03COV5yhMm8V2rpAcV6M0aIg5m(aj3ypEyUla7alJrGPfODiHEGq32bKOW2d7qf068QBYgP8iCY(HbMPkKJeoppM0xo13Weyfk0Gr)K27OiPWYyeysF5uFZS(YgP8iCgFGKZE0etzVb7qQ(MH(YI(cmW6BM1x2iLhHZ4dKC2JMyk7nyhs13m03C1xo1xO5PjYgRqzPev5L(MH(Mz9LHO1uSrkpcNXhiPcIKMxu9feuFbP(Md9nh6Bo2Hjd)RDGgm6N0EhfPn2JhYYcWoWYyeyAbAhsOhi0TDWq0Aksdf0a(KtUOX)LIgMmR(MXP(Yk9Lt9fAEAISXkuwkrvEPVzCQVGWC3Hjd)RDi7nVM9gKnsJn2JhE4cWoWYyeyAbAhsOhi0TDWq0Aksdf0a(KtUOX)LIgMmR(EQVSKR(YP(Yq0AkEOt(WKBIjxJnQsp3AhMm8V2HW76JYRUjZlIn2JhcYfGDyYW)Ah04HK0a6zXDGLXiW0c0g7XdZ5cWoWYyeyAbAhsOhi0TDWq0Aksdf0a(KtUOX)LIgMmR(MXP(YQDyYW)Ah04HKzrKhHBShpKvla7alJrGPfODiHEGq32b9jemELuSFHfUaN0xWgRqHLXiW0omz4FTJMaP9sO1ID4vGqibFSdw2ypEiiUaSdSmgbMwG2He6bcDBhmeTMIRxPgb8Gz8bsQGiP5fvFbu9LLC3Hjd)RDW1RuJaEWm(aj3ypEiGDbyhMm8V2HWyBtHr73bwgJatlqBShpmtSaSdSmgbMwG2He6bcDBhmeTMI0qbnGp5KlA8FPOHjZQVzCQVSsF5uFziAnfp0jFyYnXKRXgvPNBTdtg(x7q4D9r5v3K5fXg7XdbHla7alJrGPfODiHEGq32b080ezJvOSuIQ8sFZ4uFZzU7WKH)1oOevcHE1TXEeK5UaSdtg(x7ObFAmP9Vm7oWYyeyAbAJ9iizzbyhMm8V2HeA0(PW76JYRUDGLXiW0c0g7rqE4cWomz4FTdxItAa9S4oWYyeyAbAJ9iib5cWoWYyeyAbAhsOhi0TDyYWzJZ0hQMWiXjT)Lz3Hjd)RD0CioRNTTXEeK5CbyhyzmcmTaTdj0de62oOpHGXRKINGgecCIqc(W)sHLXiW0omz4FTJMaP9sO1In2JGKvla7WKH)1oqdg9tuGKyfMyhyzmcmTaTXEeKG4cWomz4FTJMWiXjT)Lz3bwgJatlqBShbjGDbyhyzmcmTaTdj0de62oyiAnfxVsnc4bZ4dKubrsZlQ(cO6liZDhMm8V2bxVsnc4bZ4dKCJn2H94cWEKLfGDGLXiW0c0oKqpqOB7GHO1uKgkOb8jNCrJ)lfnmzw9nJt9Lv7WKH)1oK9MxZEdYgPXg7Xdxa2bwgJatlq7qc9aHUTdirHTh2HQ0)KtUELOkKJeoppM0xo1xgIwtL(NCY1RevrWVdtg(x7qcnA)u4D9r5v3g7rqUaSdSmgbMwG2He6bcDBhqIcBpSdvP)jNC9krvihjCEEmPVCQVmeTMk9p5KRxjQIGFhMm8V2bLOsi0RUn2J5CbyhyzmcmTaTdj0de62oGef2EyhQGwNxDt2iLhHt2pmWmvHCKW55XK(YP(gMaRqHgm6N0EhfjfwgJat6lN6lBKYJWz8bso7rtmL9gSdP6Bg6BU7WKH)1o6rt4v3Kgq0iNXhi5g7rwTaSdSmgbMwG2He6bcDBhqIcBpSdvqRZRUjBKYJWj7hgyMQqos488ysF5uFdtGvOqdg9tAVJIKclJrGj9Lt9Lns5r4m(ajN9OjMYEd2Hu9nd9n3DyYW)AhObJ(jT3rrAJ9iiUaSdSmgbMwG2He6bcDBhMmC24m9HQjmsCs7Fzw9nJt9fe1xGbwFZS(AYWzJZ0hQMWiXjT)Lz13mo13CQVCQVMmC24m9HQjmsCs7Fzw99uFnz4SXjwiPJu9nh7WKH)1oAoeN1Z22ypcyxa2bwgJatlq7WKH)1o4Ho5dtUjMCn24oKqpqOB7aW1xgIwtXdDYhMCtm5ASrfb)oKhif4mmyhg09ilBShZela7alJrGPfODiHEGq32bKOW2d7qvcrEXbt4)bMMOajXkOkKJeoppM0xo1xgIwtjHgTFk8U(O8QtrWVdtg(x7GRxjAa9S4g7rq4cWoWYyeyAbAhsOhi0TDajkS9WouLqKxCWe(FGPjkqsScQc5iHZZJj9Lt9LHO1usOr7NcVRpkV6ue87WKH)1oOXdjPb0ZIBShzj3fGDGLXiW0c0omz4FTdHX2McJ2Vdj0de62osFOAcJeN0(xMvfUmRxD6lN6BM1xtgoBCM(q1egjoP9VmR(cO6RjdNnoXcjDKQVCQVMmC24m9HQjmsCs7Fzw9fq1xquFZXoKhif4mmyhg09ilBShzHLfGDGLXiW0c0oKqpqOB7aW13WLz9QBhMm8V2rtyK4K2)YSBShz5WfGDGLXiW0c0omz4FTJMWiXjT)Lz3He6bcDBhaU(gMaRq1BUGgpKuHLXiWK(YP(AYWzJZ0hQMWiXjT)Lz1xavFnz4SXjwiPJu9Lt91KHZgNPpunHrItA)lZQVaQ(cI7qEGuGZWGDyq3JSSXEKfqUaSdSmgbMwG2He6bcDBhzwFnz4SXz6dvtyK4K2)YS6BgN6RjdNnoXcjDKQVadS(AYWzJZ0hQMWiXjT)Lz13mo13CQV5qF5uFziAnfp0jFyYnXKRXgve86lN6ldrRPinuqd4to5Ig)xkAyYS6BgN6lR2Hjd)RDi8U(O8QBY8IyJ9il5CbyhyzmcmTaTdj0de62oyiAnvV5cA8qsfb)omz4FTJg8PXK2)YSBShzHvla7alJrGPfODiHEGq32b9jemELuDWNno9IT39ql8VuyzmcmPVadS(sFcbJxjvZrrA(TjJ4P0NKQWYyeysFbgy9fsuy7HDOIIyIo)2eAK8wfZo4Zn6vihjCEEmTdtg(x7Oz4mGwrBeu)Rn2JSaIla7alJrGPfODiHEGq32bdrRPKqJ2pfExFuE1Psp3sF5uFziAnfp0jFyYnXKRXgve86lN6ldrRPinuqd4to5Ig)xkAyYS6lGQVSAhMm8V2HeA0(PW76JYRUn2JSayxa2bwgJatlq7qc9aHUTdgIwtXdDYhMCtm5ASrfbV(YP(Yq0Aksdf0a(KtUOX)LIgMmR(cO6lR2Hjd)RDqjQec9QBJ9ilzIfGDGLXiW0c0oKqpqOB7GHO1u8qN8Hj3etUgBurWRVCQVmeTMI0qbnGp5KlA8FPOHjZQVaQ(YQDyYW)Ah04HK0a6zXn2JSacxa2Hjd)RDqjQec9QBhyzmcmTaTXE8WCxa2bwgJatlq7qc9aHUTdtgoBCM(q1egjoP9VmR(MXP(MZDyYW)AhnhIZ6zBBShpKLfGDGLXiW0c0oKqpqOB7imbwHscnAVxDtA8qsfwgJat6lWaRVmeTMscnA)u4D9r5vNk9CRDyYW)AhsOr7NcVRpkV62ypE4Hla7alJrGPfODyYW)AhcJTnfgTFhsOhi0TDeMaRqjmAVxDZMWirQclJrGPDipqkWzyWomO7rw2ypEiixa2bwgJatlq7qc9aHUTdtgoBCM(q1egjoP9VmR(MXP(cYDyYW)AhnhIZ6zBBShpmNla7WKH)1oyJuEeoJpqYDGLXiW0c0g7Xdz1cWoWYyeyAbAhsOhi0TDWq0AkA8qYSiYJqfb)omz4FTdzV51u4D9r5v3g7XdbXfGDGLXiW0c0oKqpqOB7GHO1usOr7NcVRpkV6ue87WKH)1oegBBkmA)g7XdbSla7alJrGPfODiHEGq32bdrRPKqJ2pfExFuE1Pi43Hjd)RDqJhssdONf3ypEyMybyhyzmcmTaTdj0de62omz4SXz6dvtyK4K2)YS6BgN67H7WKH)1oAoeN1Z22ypEiiCbyhyzmcmTaTdj0de62oyiAnfPHcAaFYjx04)srdtMvFZ4uFz1omz4FTduGKyfMyYimASXEeK5UaSdSmgbMwG2He6bcDBhmeTMI0qbnGp5KlA8FPOHjZQVzCQVSAhMm8V2bnEizwe5r4g7rqYYcWomz4FTdj0O9tH31hLxD7alJrGPfOn2JG8WfGDGLXiW0c0oKqpqOB7GHO1uKgkOb8jNCrJ)lfnmzw99uFzj3DyYW)AhYEZRPW76JYRUn2JGeKla7WKH)1o46vIgqplUdSmgbMwG2ypcYCUaSdtg(x7GgpKKgqplUdSmgbMwG2ypcswTaSdSmgbMwG2He6bcDBh0NqW4vsX(fw4cCsFbBScfwgJat7WKH)1oAcK2lHwl2HxbcHe8XoyzJ9iibXfGDGLXiW0c0omz4FTJMWiXjT)Lz3He6bcDBhqSbrAVXiWDipqkWzyWomO7rw2ypcsa7cWomz4FTJMHZaAfTrq9V2bwgJatlqBShbzMybyhMm8V2rd(0ys7Fz2DGLXiW0c0g7rqccxa2bwgJatlq7qc9aHUTdgIwtrAOGgWNCYfn(Vu0WKz13mo1xwTdtg(x7q2BEnfExFuE1TXEmN5UaSdtg(x7any0J1KY7zXDGLXiW0c0g7XCYYcWomz4FTd0Gr)efijwHj2bwgJatlqBShZ5Hla7alJrGPfODiHEGq32bdrRP46vQrapygFGKkisAEr1xavFbzU7WKH)1o46vQrapygFGKBSXosyZieXcWEKLfGDyYW)AhmI)tccASdSmgbMwMn2JhUaSdSmgbMwG2He6bcDBhmpLQVCQVnVRpMqK08IQVaQ(cI5UJesLqNp8V2bRPabLpjJf6l)h(x6Rt1xgS9quFLpjJf6lwjQAhMm8V2b)h(xBShb5cWoWYyeyAbAhjKkHoF4FTdwtfiesWh7WKH)1o46vAs7rdUXEmNla7WKH)1o6rdgtKsXsI7alJrGPfOn2JSAbyhMm8V2bbfNEGK0DGLXiW0c0g7rqCbyhyzmcmTaTdj0de62oaC9nmbwHYOsSswjrfwgJat6lWaRVmeTMYOsSswjrfbV(cmW6R8Fr65wkJkXkzLevqK08IQVzOVSk3DyYW)AhmI)tZgb8Gn2Ja2fGDGLXiW0c0oKqpqOB7aW13WeyfkJkXkzLevyzmcmPVadS(Yq0AkJkXkzLeve87WKH)1oyqifHz9QBJ9yMybyhyzmcmTaTdj0de62oaC9nmbwHYOsSswjrfwgJat6lWaRVmeTMYOsSswjrfbV(cmW6R8Fr65wkJkXkzLevqK08IQVzOVSk3DyYW)AhnhImI)tBShbHla7alJrGPfODiHEGq32bGRVHjWkugvIvYkjQWYyeysFbgy9LHO1ugvIvYkjQi41xGbwFL)lsp3szujwjRKOcIKMxu9nd9Lv5Udtg(x7WkjsdOjMsti2ypYsUla7alJrGPfODiHEGq32bGRVHjWkugvIvYkjQWYyeysFbgy9fW1xgIwtzujwjRKOIGFhMm8V2bJ1n)2mGUmlDJ9ilSSaSdtg(x7OHqtmP8o0JDGLXiW0c0g7rwoCbyhyzmcmTaTdj0de62oYS(gMaRqzujwjRKOclJrGj9fyG1xirHTh2HQ0)KtUELOkKJeoppM03COVCQVzwFPpHGXRKQd(SXPxS9UhAH)LclJrGj9fyG1x6tiy8kPAoksZVnzepL(KufwgJat6lWaRVMmC24elK0rQ(EQVSOV5yhMm8V2rZWzaTI2iO(xBShzbKla7alJrGPfODiHEGq32b080ezJvOSuIQ8sFZ4uFbH5QVadS(AYWzJtSqshP6Bg6ll7WKH)1omQeRKvsCJ9il5CbyhyzmcmTaTdj0de62oGef2EyhQs)to56vIQqos488ysF5uFziAnv6FYjxVs0zcziAnv65w6lN6BM1xO5PjYgRqzPev5L(MXP(cI5QVadS(AYWzJtSqshP6Bg6ll6Bo0xGbwFziAnfxVsnc4bZ4dKuLEUL(YP(Mz9fW1xirHTh2HQ0)KtUELOkKJeoppM0xGbwFziAnv6FYjxVs0zcziAnfbV(MJDyYW)AhC9k1iGhmJpqYn2JSWQfGDGLXiW0c0osivcD(W)AhSMM((L4a99luFXcjpaC9Lh6p0Jd032lepxQ(g9O(YbQxDcKd6Rjd)l9v40qTdtg(x7qAcX0KH)1u40yh0a6YypYYoKqpqOB7WKHZgNyHKos13t9LLDiCAmlJe3b1RobUXEKfqCbyhyzmcmTaTJesLqNp8V2bRxPVKeIW5fO(Ifs6ifC9n6r9Lh6p0Jd032lepxQ(g9O(Yb7roOVMm8V0xHtd1omz4FTdPjettg(xtHtJDqdOlJ9il7qc9aHUTdtgoBCIfs6ivFZqFzzhcNgZYiXDypUXEKfa7cWomz4FTd5tubcPb0ZIZ4dKChyzmcmTaTXEKLmXcWomz4FTdA2dAeWdMXhi5oWYyeyAbAJ9ilGWfGDyYW)Ah8qN0etAa9S4oWYyeyAbAJn2bpeLpjJfla7rwwa2bwgJatlq7qc9aHUTdgIwtX1RuJaEWKlA8FPGiP5fvFbu9fK5M7omz4FTdUELAeWdMCrJ)Rn2JhUaSdSmgbMwG2He6bcDBhmeTMQjmsm(QJaNCrJ)lfejnVO6lGQVGm3C3Hjd)RD0egjgF1rGtUOX)1g7rqUaSdtg(x7G5JqGPztyhGjUE1nJpt9AhyzmcmTaTXEmNla7alJrGPfODiHEGq32bdrRPeExFuE1nP9okskisAEr1xavFbzU5Udtg(x7q4D9r5v3K27OiTXEKvla7alJrGPfODiHEGq32rycScfnEizwe5rOclJrGPDyYW)Ah04HKzrKhHBShbXfGDGLXiW0c0oKqpqOB7aW1xirHTh2HQ0)KtUELOkKJeoppM0xo1xgIwtX1RuJaEWm(ajvPNBTdtg(x7GRxPgb8Gz8bsUXEeWUaSdSmgbMwG2He6bcDBh0NqW4vsXtqdcboribF4FPWYyeysFbgy9L(ecgVsk2VWcxGt6lyJvOWYyeyAhMm8V2rtG0Ej0AXg7XmXcWoWYyeyAbAhsOhi0TDW8u6omz4FTd(p8V2yJn2bBes9V2JhM7HSWYH5cy3bxdwE1r3bGqqaS(hznhbeW60x9fGEuFDs(hg6B7H6lhSh5G(cros4qmPV0Ne1xJiEslWK(k7TQdPkDEwRxO(YcRyD6BM8l2imWK(Yb6tiy8kPamCqFJxF5a9jemELuagfwgJatCqFZ8HzAou68SwVq9fKSI1PVzYVyJWat6lhOpHGXRKcWWb9nE9Ld0NqW4vsbyuyzmcmXb91c9fqK1J1QVzMLmnhkDEDEaHGay9pYAociG1PV6la9O(6K8pm032d1xoq9QtGCqFHihjCiM0x6tI6RrepPfysFL9w1HuLopR1luFpKvSo9nt(fBegysF5a9jemELuagoOVXRVCG(ecgVskaJclJrGjoOVwOVaISESw9nZSKP5qPZZA9c1xqMtwN(Mj)IncdmPVCG(ecgVskadh0341xoqFcbJxjfGrHLXiWeh0xl0xarwpwR(MzwY0CO0515beccG1)iR5iGawN(QVa0J6RtY)WqFBpuF5qcBgHi4G(cros4qmPV0Ne1xJiEslWK(k7TQdPkDEwRxO(YYHSo9nt(fBegysF5a9jemELuagoOVXRVCG(ecgVskaJclJrGjoOVz(WmnhkDEDEaHGay9pYAociG1PV6la9O(6K8pm032d1xoWdr5tYybh0xiYrchIj9L(KO(AeXtAbM0xzVvDivPZZA9c1xalRtFZKFXgHbM0xoqFcbJxjfGHd6B86lhOpHGXRKcWOWYyeyId6BMzjtZHsNN16fQVawwN(Mj)IncdmPVCG(ecgVskadh0341xoqFcbJxjfGrHLXiWeh0xl0xarwpwR(MzwY0CO0515znK8pmWK(Mt91KH)L(kCAqv687Gh(nxG7aqci1xaXQ3kjsIvOVJEJ0kDEajGuFbbczGeg8a99qwaxFpm3dpuNxN3KH)fvXdr5tYyXjxVsnc4btUOX)f4E7KHO1uC9k1iGhm5Ig)xkisAErbuqMBU68Mm8VOkEikFsgla9eSMWiX4RocCYfn(Va3BNmeTMQjmsm(QJaNCrJ)lfejnVOakiZnxDEtg(xufpeLpjJfGEcgZhHatZMWoatC9QBgFM6LoVjd)lQIhIYNKXcqpbt4D9r5v3K27OibU3oziAnLW76JYRUjT3rrsbrsZlkGcYCZvN3KH)fvXdr5tYybONGrJhsMfrEecU3odtGvOOXdjZIipcvyzmcmPZBYW)IQ4HO8jzSa0tW46vQrapygFGKG7Ttahsuy7HDOk9p5KRxjQc5iHZZJjoziAnfxVsnc4bZ4dKuLEULoVjd)lQIhIYNKXcqpbRjqAVeATaCVDsFcbJxjfpbnie4eHe8H)fWatFcbJxjf7xyHlWj9fSXk05nz4Frv8qu(Kmwa6jy8F4FbU3ozEkvNxNhqci1xaXmfLebM0xKncpqFdNe13Oh1xtgpuFDQ(ASnxymcuPZBYW)IEYi(pjiOHopGuFznfiO8jzSqF5)W)sFDQ(YGThI6R8jzSqFXkrv68Mm8VOGEcg)h(xG7TtMNs5S5D9XeIKMxuafeZvNhqQVSMkqiKGp05nz4Frb9emUELM0E0G68Mm8VOGEcwpAWyIukwsuN3KH)ff0tWiO40dKKQZBYW)Ic6jymI)tZgb8aW92jGhMaRqzujwjRKOclJrGjGbMHO1ugvIvYkjQi4bgy5)I0ZTugvIvYkjQGiP5fndwLRoVjd)lkONGXGqkcZ6vh4E7eWdtGvOmQeRKvsuHLXiWeWaZq0AkJkXkzLeve868Mm8VOGEcwZHiJ4)e4E7eWdtGvOmQeRKvsuHLXiWeWaZq0AkJkXkzLeve8adS8Fr65wkJkXkzLevqK08IMbRYvN3KH)ff0tWSsI0aAIP0ecW92jGhMaRqzujwjRKOclJrGjGbMHO1ugvIvYkjQi4bgy5)I0ZTugvIvYkjQGiP5fndwLRoVjd)lkONGXyDZVndOlZsb3BNaEycScLrLyLSsIkSmgbMagyaNHO1ugvIvYkjQi415nz4Frb9eSgcnXKY7qp05nz4Frb9eSMHZaAfTrq9Va3BNzombwHYOsSswjrfwgJatadmKOW2d7qv6FYjxVsufYrcNNht5GZmtFcbJxjvh8zJtVy7Dp0c)lGbM(ecgVsQMJI08BtgXtPpjfyGnz4SXjwiPJ0twYHoVjd)lkONGzujwjRKi4E7eAEAISXkuwkrvELXjimxGb2KHZgNyHKosZGfDEtg(xuqpbJRxPgb8Gz8bscU3oHef2EyhQs)to56vIQqos488yItgIwtL(NCY1ReDMqgIwtLEUfNzgAEAISXkuwkrvELXjiMlWaBYWzJtSqshPzWsoagygIwtX1RuJaEWm(ajvPNBXzMbCirHTh2HQ0)KtUELOkKJeoppMagygIwtL(NCY1ReDMqgIwtrWNdDEaP(YAA67xId03Vq9flK8aW1xEO)qpoqFBVq8CP6B0J6lhOE1jqoOVMm8V0xHtdLoVjd)lkONGjnHyAYW)AkCAaEzK4j1RobconGUmozbCVDAYWzJtSqshPNSOZdi1xwVsFjjeHZlq9flK0rk46B0J6lp0FOhhOVTxiEUu9n6r9Ld2JCqFnz4FPVcNgkDEtg(xuqpbtAcX0KH)1u40a8YiXt7rWPb0LXjlG7TttgoBCIfs6indw05nz4Frb9em5tubcPb0ZIZ4dKuN3KH)ff0tWOzpOrapygFGK68Mm8VOGEcgp0jnXKgqplQZRZdibK6liWeIW13WGDyOVMm8V0xEO)qpoqFfon05nz4Frv2JNYEZRzVbzJ0aCVDYq0Aksdf0a(KtUOX)LIgMmBgNSsN3KH)fvzpc6jysOr7NcVRpkV6a3BNqIcBpSdvP)jNC9krvihjCEEmXjdrRPs)to56vIQi415nz4Frv2JGEcgLOsi0RoW92jKOW2d7qv6FYjxVsufYrcNNhtCYq0AQ0)KtUELOkcEDEtg(xuL9iONG1JMWRUjnGOroJpqsW92jKOW2d7qf068QBYgP8iCY(HbMPkKJeoppM4mmbwHcny0pP9okskSmgbM4Kns5r4m(ajN9OjMYEd2H0mYvN3KH)fvzpc6jyObJ(jT3rrcCVDcjkS9WoubToV6MSrkpcNSFyGzQc5iHZZJjodtGvOqdg9tAVJIKclJrGjozJuEeoJpqYzpAIPS3GDinJC15nz4Frv2JGEcwZH4SE2g4E70KHZgNPpunHrItA)lZMXjicmWz2KHZgNPpunHrItA)lZMXzo50KHZgNPpunHrItA)lZEAYWzJtSqshP5qN3KH)fvzpc6jy8qN8Hj3etUgBeC5bsbodd2Hb9KfW92jGZq0AkEOt(WKBIjxJnQi415nz4Frv2JGEcgxVs0a6zrW92jKOW2d7qvcrEXbt4)bMMOajXkOkKJeoppM4KHO1usOr7NcVRpkV6ue868Mm8VOk7rqpbJgpKKgqplcU3oHef2EyhQsiYloyc)pW0efijwbvHCKW55XeNmeTMscnA)u4D9r5vNIGxN3KH)fvzpc6jycJTnfgThC5bsbodd2Hb9KfW92z6dvtyK4K2)YSQWLz9QJZmBYWzJZ0hQMWiXjT)LzbutgoBCIfs6iLttgoBCM(q1egjoP9VmlGcI5qN3KH)fvzpc6jynHrItA)lZcU3ob8WLz9QtN3KH)fvzpc6jynHrItA)lZcU8aPaNHb7WGEYc4E7eWdtGvO6nxqJhsQWYyeyIttgoBCM(q1egjoP9VmlGAYWzJtSqshPCAYWzJZ0hQMWiXjT)LzbuquN3KH)fvzpc6jycVRpkV6MmVia3BNz2KHZgNPpunHrItA)lZMXPjdNnoXcjDKcmWMmC24m9HQjmsCs7Fz2moZzo4KHO1u8qN8Hj3etUgBurWZjdrRPinuqd4to5Ig)xkAyYSzCYkDEtg(xuL9iONG1GpnM0(xMfCVDYq0AQEZf04HKkcEDEtg(xuL9iONG1mCgqROncQ)f4E7K(ecgVsQo4ZgNEX27EOf(xadm9jemELunhfP53MmINsFskWadjkS9WourrmrNFBcnsERIzh85g9kKJeoppM05nz4Frv2JGEcMeA0(PW76JYRoW92jdrRPKqJ2pfExFuE1Psp3ItgIwtXdDYhMCtm5ASrfbpNmeTMI0qbnGp5KlA8FPOHjZcOSsN3KH)fvzpc6jyuIkHqV6a3BNmeTMIh6Kpm5MyY1yJkcEoziAnfPHcAaFYjx04)srdtMfqzLoVjd)lQYEe0tWOXdjPb0ZIG7TtgIwtXdDYhMCtm5ASrfbpNmeTMI0qbnGp5KlA8FPOHjZcOSsN3KH)fvzpc6jyuIkHqV605nz4Frv2JGEcwZH4SE2g4E70KHZgNPpunHrItA)lZMXzo15nz4Frv2JGEcMeA0(PW76JYRoW92zycScLeA0EV6M04HKkSmgbMagygIwtjHgTFk8U(O8QtLEULoVjd)lQYEe0tWegBBkmAp4YdKcCggSdd6jlG7TZWeyfkHr79QB2egjsvyzmcmPZBYW)IQShb9eSMdXz9SnW92PjdNnotFOAcJeN0(xMnJtqQZBYW)IQShb9em2iLhHZ4dKuN3KH)fvzpc6jyYEZRPW76JYRoW92jdrRPOXdjZIipcve868Mm8VOk7rqpbtySTPWO9G7TtgIwtjHgTFk8U(O8QtrWRZBYW)IQShb9emA8qsAa9Si4E7KHO1usOr7NcVRpkV6ue868Mm8VOk7rqpbR5qCwpBdCVDAYWzJZ0hQMWiXjT)LzZ48qDEtg(xuL9iONGHcKeRWetgHrdW92jdrRPinuqd4to5Ig)xkAyYSzCYkDEtg(xuL9iONGrJhsMfrEecU3oziAnfPHcAaFYjx04)srdtMnJtwPZBYW)IQShb9emj0O9tH31hLxD68Mm8VOk7rqpbt2BEnfExFuE1bU3oziAnfPHcAaFYjx04)srdtM9KLC15nz4Frv2JGEcgxVs0a6zrDEtg(xuL9iONGrJhssdONf15nz4Frv2JGEcwtG0Ej0Ab4EfiesWhNSaU3oPpHGXRKI9lSWf4K(c2yf68Mm8VOk7rqpbRjmsCs7FzwWLhif4mmyhg0twa3BNqSbrAVXiqDEtg(xuL9iONG1mCgqROncQ)LoVjd)lQYEe0tWAWNgtA)lZQZBYW)IQShb9emzV51u4D9r5vh4E7KHO1uKgkOb8jNCrJ)lfnmz2mozLoVjd)lQYEe0tWqdg9ynP8EwuN3KH)fvzpc6jyObJ(jkqsSctOZBYW)IQShb9emUELAeWdMXhij4E7KHO1uC9k1iGhmJpqsfejnVOakiZvNxNhqci13HxDcuFdd2HH(AYW)sF5H(d94a9v40qN3KH)fvr9QtGNC9krdONf15nz4FrvuV6eiONGjm22uy0EW92jdrRP6)y2BvsrWdmWzgsuy7HDOIh6KMykm220KbHfpKQqos488yItgIwtXdDstmfgBBAYGWIhsv0WKzZaeZHoVjd)lQI6vNab9emUELAeWdMXhij4E7eWziAnfxVsnc4bZ4dKurWRZBYW)IQOE1jqqpbJgpKKgqplcU3oHef2EyhQs)to56vIQqos488yItgIwtL(NCY1RevrWRZBYW)IQOE1jqqpbtcnA)u4D9r5vh4E7esuy7HDOk9p5KRxjQc5iHZZJjoziAnv6FYjxVsufbVoVjd)lQI6vNab9emxItAa9Si4E7esuy7HDOk9p5KRxjQc5iHZZJjoziAnv6FYjxVsufbVoVjd)lQI6vNab9emkrLqOxDG7TtirHTh2HQ0)KtUELOkKJeoppM4KHO1uP)jNC9krve868Mm8VOkQxDce0tWAcJeN0(xMfCVDc4HlZ6vNoVjd)lQI6vNab9emH31hLxDtMxeG7TtgIwtrAOGgWNCYfn(Vu0WKzZ4KvCYq0AkEOt(WKBIjxJnQi45eAEAISXkuwkrvELbdrRP4Ho5dtUjMCn2OcIKMxuDEtg(xuf1Robc6jy8qN8Hj3etUgBeCVDYq0AkEOt(WKBIjxJnQsp3IZmdnpnr2yfklLOkVYiNhcmWqZttKnwHYsjQYlafeZHoVjd)lQI6vNab9em2iLhHZ4dKeCVDcnpnr2yfklLOkVYiN5QZBYW)IQOE1jqqpbRbFAmP9Vml4E7KHO1u9MlOXdjve868Mm8VOkQxDce0tWqdg9ynP8EwuN3KH)fvr9QtGGEcMWyBtHr7b3BNPpunHrItA)lZQGydI0EJrG68Mm8VOkQxDce0tWAgodOv0gb1)cCVDc4qIcBpSdvuet053MqJK3Qy2bFUrVc5iHZZJjGbw(Vi9ClvdHMys5DOhkisAErZaK5QZBYW)IQOE1jqqpbJgpKKgqplcU3odtGvOOXdjBcci8afwgJatCYq0AkA8qsgOxDiurWRZBYW)IQOE1jqqpbt2BEnfExFuE1bU3oziAnfnEizwe5rOIGxN3KH)fvr9QtGGEcgkqsSctmzegna3BNmeTMI0qbnGp5KlA8FPOHjZMXjR05nz4FrvuV6eiONG1JMWRUjnGOroJpqsW92jKOW2d7qf068QBYgP8iCY(HbMPkKJeoppM4mmbwHcny0pP9okskSmgbM4mZSrkpcNXhi5ShnXu2BWoKMbladCMzJuEeoJpqYzpAIPS3GDinJC5eAEAISXkuwkrvELrMziAnfBKYJWz8bsQGiP5ffeeK5ih5qN3KH)fvr9QtGGEcgAWOFs7DuKa3BNqIcBpSdvqRZRUjBKYJWj7hgyMQqos488yIZWeyfk0Gr)K27OiPWYyeyIZmZgP8iCgFGKZE0etzVb7qAgSamWzMns5r4m(ajN9OjMYEd2H0mYLtO5PjYgRqzPev5vgzMHO1uSrkpcNXhiPcIKMxuqqqMJCKdDEtg(xuf1Robc6jyYEZRzVbzJ0aCVDYq0Aksdf0a(KtUOX)LIgMmBgNSItO5PjYgRqzPev5vgNGWC15nz4FrvuV6eiONGj8U(O8QBY8IaCVDYq0Aksdf0a(KtUOX)LIgMm7jl5YjdrRP4Ho5dtUjMCn2Ok9ClDEtg(xuf1Robc6jy04HK0a6zrDEtg(xuf1Robc6jy04HKzrKhHG7TtgIwtrAOGgWNCYfn(Vu0WKzZ4Kv68Mm8VOkQxDce0tWAcK2lHwla3RaHqc(4KfW92j9jemELuSFHfUaN0xWgRqN3KH)fvr9QtGGEcgxVsnc4bZ4dKeCVDYq0AkUELAeWdMXhiPcIKMxuaLLC15nz4FrvuV6eiONGjm22uy0EDEtg(xuf1Robc6jycVRpkV6MmVia3BNmeTMI0qbnGp5KlA8FPOHjZMXjR4KHO1u8qN8Hj3etUgBuLEULoVjd)lQI6vNab9emkrLqOxDG7TtO5PjYgRqzPev5vgN5mxDEtg(xuf1Robc6jyn4tJjT)Lz15nz4FrvuV6eiONGjHgTFk8U(O8QtN3KH)fvr9QtGGEcMlXjnGEwuN3KH)fvr9QtGGEcwZH4SE2g4E70KHZgNPpunHrItA)lZQZBYW)IQOE1jqqpbRjqAVeATaCVDsFcbJxjfpbnie4eHe8H)LoVjd)lQI6vNab9em0Gr)efijwHj05nz4FrvuV6eiONG1egjoP9VmRoVjd)lQI6vNab9emUELAeWdMXhij4E7KHO1uC9k1iGhmJpqsfejnVOakiZDhgr0)WDmCYm5gBSla]] )


end
