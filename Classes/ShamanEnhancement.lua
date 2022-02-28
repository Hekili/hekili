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


    spec:RegisterPack( "Enhancement", 20220227, [[dy0ombqiaQEeafBIa9jcWOubCkHKEfqAwav3cqkTls(fqzycPogkPLPc6zaIPbq6AOe2gGKVPcuJtibNdqQwhkrzEae3tfTpHWbbKcleq9qHe6IQaPncif5JQaHtIseRuOAMOePBcif1ovH(jkrLLIsu1tvyQa4RQarJfGs7vP)QObRshMYIrXJjAYcUm0MLYNLkJwQ60u9AHYSr1TrQDl53QA4e64eqlh0ZrmDrxhjBhL67e04fs05fIMpqSFs9Y6cWocwI7XdJ(WdJ(Wdpyv0rhnqacGUJmsrChIMmM1H7OmAChh0Q3kjsJvUdrls(BHfGDqEkOe3XWPJI7GHY5jlPwMDeSe3Jhg9Hhg9HhEWQOJoAGaeGSdIik3Jhcuazh9EiG1YSJasK74Gw9wjrASs9D0B0wPJd0eYaPmyK67HSaC99WOp8WDWDsswa2bXRooUaShzDbyhMm9V2HqVcKe6XWDGLXWXWc8M7Xdxa2bwgdhdlW7qc9eHUTdgQwt1)5S3QGIsuFbbe99a6lKQW2d7qLi0Pn(KBSTPjtklFirHcKYffXG(kO(Yq1AkrOtB8j3yBttMuw(qIIKMmM(gH(cu6Bu3Hjt)RDWn22KBK(n3JazbyhyzmCmSaVdj0te62oaC9LHQ1uc9k0OGroZprAfL4omz6FTdHEfAuWiN5Ni9M7raDbyhyzmCmSaVdj0te62oGuf2EyhQc)tpf6vGOqbs5IIyqFfuFzOAnv4F6PqVcefL4omz6FTds(qAsc9y4M7rwSaSdSmgogwG3He6jcDBhqQcBpSdvH)PNc9kquOaPCrrmOVcQVmuTMk8p9uOxbIIsChMm9V2HeAK(j376ZYRUn3Ja1cWoWYy4yybEhsONi0TDaPkS9Wouf(NEk0RarHcKYffXG(kO(Yq1AQW)0tHEfikkXDyY0)AhUeNKe6XWn3Jh8cWoWYy4yybEhsONi0TDaPkS9Wouf(NEk0RarHcKYffXG(kO(Yq1AQW)0tHEfikkXDyY0)AheQkGqV62Cpgfwa2bwgdhdlW7qc9eHUTdaxFtxgZRUDyY0)AhnUrJts)lJT5EeOVaSdSmgogwG3He6jcDBhmuTMI2qojHp9uiAIFPiPjJPVrCQVSqFfuFzOAnLi0PFyWn(uOXgvuI6RG6l08WezJvQSqGO8sFJqFzOAnLi0PFyWn(uOXgvqK28ISdtM(x7G7D9z5v3K555M7rwJEbyhyzmCmSaVdj0te62oyOAnLi0PFyWn(uOXgvHxyPVcQVhqFHMhMiBSsLfceLx6Be6lGEO(cci6l08WezJvQSqGO8sFbe9fO03OUdtM(x7qe60pm4gFk0yJBUhzL1fGDGLXWXWc8oKqprOB7aAEyISXkvwiquEPVrOVaA07WKP)1oyJereoZpr6n3JSE4cWoWYy4yybEhsONi0TDWq1AQEZ5K8H0kkXDyY0)Ahn4tYjP)LX2CpYkqwa2Hjt)RDGgm7XAse9y4oWYy4yybEZ9iRa6cWoWYy4yybEhsONi0TDe(u14gnoj9VmMcInis6ngoUdtM(x7GBSTj3i9BUhzLfla7alJHJHf4DiHEIq32bGRVqQcBpSdveedK53MqJw0QC2bFHzVcfiLlkIb9feq0x5)8WlSuneA8jr0HEQGiT5frFJqFbs07WKP)1oAgotOvKgfX)AZ9iRa1cWoWYy4yybEhsONi0TDKghRurYhs34uqyKkSmgog0xb1xgQwtrYhsZa9QdHkkXDyY0)AhK8H0Ke6XWn3JSEWla7alJHJHf4DiHEIq32bdvRPi5dPJHOicvuI7WKP)1oK9MxtU31NLxDBUhznkSaSdSmgogwG3He6jcDBhmuTMI2qojHp9uiAIFPiPjJPVrCQVSyhMm9V2bYrASsJpz4gj3CpYkqFbyhyzmCmSaVdj0te62oGuf2EyhQGwNxDt2ireHt2pmXOuHcKYffXG(kO(MghRuHgm7NKEh5bfwgdhd6RG67b0x2ireHZ8tKE2JgFk7nyhs03i0xw1xqarFpG(YgjIiCMFI0ZE04tzVb7qI(gH(gT(kO(cnpmr2yLkleikV03i03dOVmuTMInser4m)ePvqK28IOVaT6lq03OQVrvFJ6omz6FTJE04E1njjen6z(jsV5E8WOxa2bwgdhdlW7qc9eHUTdivHTh2HkO15v3Knser4K9dtmkvOaPCrrmOVcQVPXXkvObZ(jP3rEqHLXWXG(kO(Ea9Lnser4m)ePN9OXNYEd2He9nc9Lv9feq03dOVSrIicN5Ni9Shn(u2BWoKOVrOVrRVcQVqZdtKnwPYcbIYl9nc99a6ldvRPyJereoZprAfePnVi6lqR(ce9nQ6Bu13OUdtM(x7any2pj9oYdBUhpK1fGDGLXWXWc8oKqprOB7GHQ1u0gYjj8PNcrt8lfjnzm9nIt9Lf6RG6l08WezJvQSqGO8sFJ4uFb6rVdtM(x7q2BEn7niBKKBUhp8WfGDGLXWXWc8oKqprOB7GHQ1u0gYjj8PNcrt8lfjnzm99uFznA9vq9LHQ1uIqN(Hb34tHgBufEH1omz6FTdU31NLxDtMNNBUhpeila7WKP)1oi5dPjj0JH7alJHJHf4n3JhcOla7alJHJHf4DiHEIq32bdvRPOnKts4tpfIM4xksAYy6BeN6ll2Hjt)RDqYhshdrreU5E8qwSaSdSmgogwG3He6jcDBhKNIZ4vqX(5w6CCsEoBSsfwgdhd7WKP)1oACK0lHwl3HxjcHuI5oyDZ94Ha1cWoWYy4yybEhsONi0TDWq1AkHEfAuWiN5NiTcI0Mxe9fq0xwJEhMm9V2HqVcnkyKZ8tKEZ94Hh8cWomz6FTdUX2MCJ0VdSmgogwG3CpEyuybyhyzmCmSaVdj0te62oyOAnfTHCscF6Pq0e)srstgtFJ4uFzH(kO(Yq1AkrOt)WGB8PqJnQcVWAhMm9V2b376ZYRUjZZZn3Jhc0xa2bwgdhdlW7qc9eHUTdO5HjYgRuzHar5L(gXP(cOrVdtM(x7Gqvbe6v3M7rGe9cWomz6FTJg8j5K0)Yy7alJHJHf4n3JaH1fGDyY0)AhsOr6NCVRplV62bwgdhdlWBUhbYHla7WKP)1oCjojj0JH7alJHJHf4n3Jabila7alJHJHf4DiHEIq32HjtNnodFQACJgNK(xgBhMm9V2rZH4SE22M7rGaOla7alJHJHf4DiHEIq32b5P4mEfuIuKKIJtesjM(xkSmgog2Hjt)RD04iPxcTwU5EeiSybyhMm9V2bAWSFICKgR047alJHJHf4n3JabOwa2bwgdhdlW7qc9eHUTdcMPxDevZ5Ceoj9Vm2omz6FTJg3OXjP)LX2CpcKdEbyhyzmCmSaVdj0te62oyOAnLqVcnkyKZ8tKwbrAZlI(ci6lqIEhMm9V2HqVcnkyKZ8tKEZn3H94cWEK1fGDGLXWXWc8oKqprOB7GHQ1u0gYjj8PNcrt8lfjnzm9nIt9Lf7WKP)1oK9MxZEdYgj5M7Xdxa2bwgdhdlW7qc9eHUTdivHTh2HQW)0tHEfikuGuUOig0xb1xgQwtf(NEk0RarrjUdtM(x7qcns)K7D9z5v3M7rGSaSdSmgogwG3He6jcDBhqQcBpSdvH)PNc9kquOaPCrrmOVcQVmuTMk8p9uOxbIIsChMm9V2bHQci0RUn3Ja6cWoWYy4yybEhsONi0TDaPkS9WoubToV6MSrIicNSFyIrPcfiLlkIb9vq9nnowPcny2pj9oYdkSmgog0xb1x2ireHZ8tKE2JgFk7nyhs03i03O3Hjt)RD0Jg3RUjjHOrpZpr6n3JSybyhyzmCmSaVdj0te62oGuf2EyhQGwNxDt2ireHt2pmXOuHcKYffXG(kO(MghRuHgm7NKEh5bfwgdhd6RG6lBKiIWz(jsp7rJpL9gSdj6Be6B07WKP)1oqdM9tsVJ8WM7rGAbyhyzmCmSaVdj0te62omz6SXz4tvJB04K0)Yy6BeN6lqPVGaI(Ea91KPZgNHpvnUrJts)lJPVrCQVaQ(kO(AY0zJZWNQg3OXjP)LX03io1xzKsooXcPDKOVrDhMm9V2rZH4SE22M7XdEbyhyzmCmSaVdtM(x7qe60pm4gFk0yJ7qc9eHUTdaxFzOAnLi0PFyWn(uOXgvuI7qgPKJZ0GDys2JSU5EmkSaSdSmgogwG3He6jcDBhqQcBpSdvbef5roH)NyyICKgRKOqbs5IIyqFfuFzOAnLeAK(j376ZYRofL4omz6FTdHEfij0JHBUhb6la7alJHJHf4DiHEIq32bKQW2d7qvarrEKt4)jgMihPXkjkuGuUOig0xb1xgQwtjHgPFY9U(S8QtrjUdtM(x7GKpKMKqpgU5EK1Oxa2bwgdhdlW7WKP)1o4gBBYns)oKqprOB7i8PQXnACs6Fzmv6YyE1PVcQVhqFnz6SXz4tvJB04K0)Yy6lGOVYiLCCIfs7irFfuFnz6SXz4tvJB04K0)Yy6lGOVaL(g1DiJuYXzAWomj7rw3CpYkRla7alJHJHf4DiHEIq32bGRVPlJ5v3omz6FTJg3OXjP)LX2CpY6Hla7alJHJHf4DyY0)AhnUrJts)lJTdj0te62oaC9nnowPQ3CojFiTclJHJb9vq91KPZgNHpvnUrJts)lJPVaI(kJuYXjwiTJe9vq91KPZgNHpvnUrJts)lJPVaI(cu7qgPKJZ0GDys2JSU5EKvGSaSdSmgogwG3He6jcDBhhqFnz6SXz4tvJB04K0)Yy6BeN6RmsjhNyH0os0xqarFnz6SXz4tvJB04K0)Yy6BeN6lGQVrvFfuFzOAnLi0PFyWn(uOXgvuI6RG6ldvRPOnKts4tpfIM4xksAYy6BeN6ll2Hjt)RDW9U(S8QBY88CZ9iRa6cWoWYy4yybEhsONi0TDWq1AQEZ5K8H0kkXDyY0)Ahn4tYjP)LX2CpYklwa2bwgdhdlW7qc9eHUTdYtXz8kO6GpBC6fBV7Hw6FPWYy4yqFbbe9L8uCgVcQMJ8W8Btg(tipnrHLXWXG(cci6lKQW2d7qfbXaz(Tj0OfTkNDWxy2Rqbs5IIyyhMm9V2rZWzcTI0Oi(xBUhzfOwa2bwgdhdlW7qc9eHUTdgQwtjHgPFY9U(S8QtfEHL(kO(Yq1AkrOt)WGB8PqJnQOe1xb1xgQwtrBiNKWNEkenXVuK0KX0xarFzXomz6FTdj0i9tU31NLxDBUhz9Gxa2bwgdhdlW7qc9eHUTdgQwtjcD6hgCJpfASrfLO(kO(Yq1AkAd5Ke(0tHOj(LIKMmM(ci6ll2Hjt)RDqOQac9QBZ9iRrHfGDGLXWXWc8oKqprOB7GHQ1uIqN(Hb34tHgBurjQVcQVmuTMI2qojHp9uiAIFPiPjJPVaI(YIDyY0)AhK8H0Ke6XWn3JSc0xa2Hjt)RDqOQac9QBhyzmCmSaV5E8WOxa2bwgdhdlW7qc9eHUTdtMoBCg(u14gnoj9VmM(gXP(cO7WKP)1oAoeN1Z22CpEiRla7alJHJHf4DiHEIq32rACSsLeAKEV6MK8H0kSmgog0xqarFzOAnLeAK(j376ZYRov4fw7WKP)1oKqJ0p5ExFwE1T5E8Wdxa2bwgdhdlW7WKP)1o4gBBYns)oKqprOB7inowPIBKEV6MnUrJefwgdhd7qgPKJZ0GDys2JSU5E8qGSaSdSmgogwG3He6jcDBhMmD24m8PQXnACs6Fzm9nIt9fi7WKP)1oAoeN1Z22CpEiGUaSdtM(x7Gnser4m)eP3bwgdhdlWBUhpKfla7alJHJHf4DiHEIq32bdvRPi5dPJHOicvuI7WKP)1oK9MxtU31NLxDBUhpeOwa2bwgdhdlW7qc9eHUTdgQwtjHgPFY9U(S8QtrjUdtM(x7GBSTj3i9BUhp8Gxa2bwgdhdlW7qc9eHUTdgQwtjHgPFY9U(S8QtrjUdtM(x7GKpKMKqpgU5E8WOWcWoWYy4yybEhsONi0TDyY0zJZWNQg3OXjP)LX03io13d3Hjt)RD0CioRNTT5E8qG(cWoWYy4yybEhsONi0TDWq1AkAd5Ke(0tHOj(LIKMmM(gXP(YIDyY0)AhihPXkn(KHBKCZ9iqIEbyhyzmCmSaVdj0te62oyOAnfTHCscF6Pq0e)srstgtFJ4uFzXomz6FTds(q6yikIWn3JaH1fGDyY0)AhsOr6NCVRplV62bwgdhdlWBUhbYHla7alJHJHf4DiHEIq32bdvRPOnKts4tpfIM4xksAYy67P(YA07WKP)1oK9MxtU31NLxDBUhbcqwa2Hjt)RDi0RajHEmChyzmCmSaV5Eeia6cWomz6FTds(qAsc9y4oWYy4yybEZ9iqyXcWoWYy4yybEhsONi0TDqEkoJxbf7NBPZXj55SXkvyzmCmSdtM(x7OXrsVeATChELiesjM7G1n3JabOwa2bwgdhdlW7WKP)1oACJgNK(xgBhsONi0TDaXgej9gdh3HmsjhNPb7WKShzDZ9iqo4fGDyY0)AhndNj0ksJI4FTdSmgogwG3CpcKOWcWomz6FTJg8j5K0)Yy7alJHJHf4n3JabOVaSdSmgogwG3He6jcDBhmuTMI2qojHp9uiAIFPiPjJPVrCQVSyhMm9V2HS38AY9U(S8QBZ9iGg9cWomz6FTd0GzpwtIOhd3bwgdhdlWBUhbuwxa2Hjt)RDGgm7NihPXkn(oWYy4yybEZ9iGE4cWoWYy4yybEhsONi0TDWq1AkHEfAuWiN5NiTcI0Mxe9fq0xGe9omz6FTdHEfAuWiN5Ni9MBUJa2mkEUaShzDbyhMm9V2bd))aNIK7alJHJHLzZ94Hla7alJHJHf4DiHEIq32bZti6RG6BZ76ZjePnVi6lGOVav07iGej0ft)RDWskGw5tZyP(k(P)L(6e9LbBpe1x5tZyP(IvGO2Hjt)RDi(P)1M7rGSaSdSmgogwG3rajsOlM(x7GLujcHuI5omz6FTdHEfMKE0GBUhb0fGDyY0)AhueC6jst2bwgdhdlWBUhzXcWoWYy4yybEhsONi0TDa46BACSsLrKyfSsIkSmgog0xqarFzOAnLrKyfSsIkkr9feq0x5)8WlSugrIvWkjQGiT5frFJqFzr07WKP)1oy4)hMnkyKBUhbQfGDGLXWXWc8oKqprOB7aW1304yLkJiXkyLevyzmCmOVGaI(Yq1AkJiXkyLevuI7WKP)1oyqibHX8QBZ94bVaSdSmgogwG3He6jcDBhaU(MghRuzejwbRKOclJHJb9feq0xgQwtzejwbRKOIsuFbbe9v(pp8clLrKyfSsIkisBEr03i0xwe9omz6FTJMdrg()Hn3JrHfGDGLXWXWc8oKqprOB7aW1304yLkJiXkyLevyzmCmOVGaI(Yq1AkJiXkyLevuI6liGOVY)5HxyPmIeRGvsubrAZlI(gH(YIO3Hjt)RDyLejj04tPX5BUhb6la7alJHJHf4DiHEIq32bGRVPXXkvgrIvWkjQWYy4yqFbbe9fW1xgQwtzejwbRKOIsChMm9V2bJ1n)2mHUmgzZ9iRrVaSdtM(x7OHqJpjIo0ZDGLXWXWc8M7rwzDbyhyzmCmSaVdj0te62ooG(MghRuzejwbRKOclJHJb9feq0xivHTh2HQW)0tHEfikuGuUOig03OQVcQVhqFjpfNXRGQd(SXPxS9UhAP)LclJHJb9feq0xYtXz8kOAoYdZVnz4pH80efwgdhd6liGOVMmD24elK2rI(EQVSQVrDhMm9V2rZWzcTI0Oi(xBUhz9WfGDGLXWXWc8oKqprOB7aAEyISXkvwiquEPVrCQVa9O1xqarFnz6SXjwiTJe9nc9L1DyY0)AhgrIvWkjU5EKvGSaSdSmgogwG3Hjt)RDi0RqJcg5m)eP3He6jcDBhqQcBpSdvH)PNc9kquOaPCrrmOVcQVmuTMk8p9uOxbYmGmuTMk8cl9vq99a6l08WezJvQSqGO8sFJ4uFbQO1xqarFnz6SXjwiTJe9nc9Lv9nQ6liGOVmuTMsOxHgfmYz(jsRcVWsFfuFpG(c46lKQW2d7qv4F6PqVcefkqkxued6liGOVmuTMk8p9uOxbYmGmuTMIsuFJ6o4EHtzyhSYIn3JScOla7alJHJHf4DeqIe6IP)1oyjn99lEK67xO(Ifshj46Ri0FONrQVTNZFHe9n7r9vaeV64Oa0xtM(x6l3jPAhMm9V2H048Pjt)Rj3j5oij0L5EK1DiHEIq32HjtNnoXcPDKOVN6lR7G7KCwgnUdIxDCCZ9iRSybyhyzmCmSaVJasKqxm9V2blxPV0u80f5O(Ifs7ibC9n7r9ve6p0Zi132Z5VqI(M9O(ka7rbOVMm9V0xUts1omz6FTdPX5ttM(xtUtYDqsOlZ9iR7qc9eHUTdtMoBCIfs7irFJqFzDhCNKZYOXDypU5EKvGAbyhMm9V2H8PQeHKe6XWz(jsVdSmgogwG3CpY6bVaSdtM(x7GelYgfmYz(jsVdSmgogwG3CpYAuybyhMm9V2Hi0Pn(KKqpgUdSmgogwG3CZDicr5tZy5cWEK1fGDGLXWXWc8oKqprOB7GHQ1uc9k0OGrofIM4xkisBEr0xarFbs0rVdtM(x7qOxHgfmYPq0e)AZ94Hla7alJHJHf4DiHEIq32bdvRPACJgZV6OWPq0e)sbrAZlI(ci6lqIo6DyY0)AhnUrJ5xDu4uiAIFT5Eeila7WKP)1oy(m5yy24wKyqOxDZ8JsV2bwgdhdlWBUhb0fGDGLXWXWc8oKqprOB7GHQ1uCVRplV6MKEh5bfePnVi6lGOVaj6O3Hjt)RDW9U(S8QBs6DKh2CpYIfGDGLXWXWc8oKqprOB7inowPIKpKogIIiuHLXWXWomz6FTds(q6yikIWn3Ja1cWoWYy4yybEhsONi0TDa46lKQW2d7qv4F6PqVcefkqkxued6RG6ldvRPe6vOrbJCMFI0QWlS2Hjt)RDi0RqJcg5m)eP3CpEWla7alJHJHf4DiHEIq32b5P4mEfuIuKKIJtesjM(xkSmgog0xqarFjpfNXRGI9ZT054K8C2yLkSmgog2Hjt)RD04iPxcTwU5EmkSaSdSmgogwG3He6jcDBhmpHSdtM(x7q8t)Rn3CZDWgHe)R94HrF4HrF4HSUdHgS8QJSJdsGgS8hzjhpiyz6R(cqpQVoT4dt9T9q9va2JcqFHOaPCig0xYtJ6RrLpTLyqFL9w1HeLool1luFzLfSm9nk(fBeMyqFfa5P4mEfuawbOV5RVcG8uCgVckaRclJHJbbOVh4WOmQkDCwQxO(cewWY03O4xSryIb9vaKNIZ4vqbyfG(MV(kaYtXz8kOaSkSmgogeG(AP(Eqz5yP67bynkJQshxh)GeObl)rwYXdcwM(QVa0J6Rtl(WuFBpuFfaXRooka9fIcKYHyqFjpnQVgv(0wIb9v2Bvhsu64SuVq99qwWY03O4xSryIb9vaKNIZ4vqbyfG(MV(kaYtXz8kOaSkSmgogeG(AP(Eqz5yP67bynkJQshNL6fQVabqzz6Bu8l2imXG(kaYtXz8kOaScqFZxFfa5P4mEfuawfwgdhdcqFTuFpOSCSu99aSgLrvPJRJFqc0GL)il54bbltF1xa6r91PfFyQVThQVciGnJINcqFHOaPCig0xYtJ6RrLpTLyqFL9w1HeLool1luFzLvwM(gf)InctmOVcG8uCgVckaRa0381xbqEkoJxbfGvHLXWXGa03dCyugvLoUo(bjqdw(JSKJheSm9vFbOh1xNw8HP(2EO(karikFAglfG(crbs5qmOVKNg1xJkFAlXG(k7TQdjkDCwQxO(EWSm9nk(fBeMyqFfa5P4mEfuawbOV5RVcG8uCgVckaRclJHJbbOVhG1OmQkDCwQxO(EWSm9nk(fBeMyqFfa5P4mEfuawbOV5RVcG8uCgVckaRclJHJbbOVwQVhuwowQ(EawJYOQ0X1Xzj0IpmXG(cO6Rjt)l9L7KKO0X3HrL9pChdNokUdr43CoUdadGrFpOvVvsKgRuFh9gTv64agaJ(c0eYaPmyK67HSaC99WOp8qDCDCtM(xeLieLpnJLNc9k0OGrofIM4xG7TtgQwtj0RqJcg5uiAIFPGiT5fbqas0rRJBY0)IOeHO8PzSe0tWACJgZV6OWPq0e)cCVDYq1AQg3OX8RokCkenXVuqK28Iaiaj6O1Xnz6FruIqu(0mwc6jymFMCmmBClsmi0RUz(rPx64Mm9VikrikFAglb9emU31NLxDtsVJ8a4E7KHQ1uCVRplV6MKEh5bfePnViacqIoADCtM(xeLieLpnJLGEcgjFiDmefri4E7mnowPIKpKogIIiuHLXWXGoUjt)lIseIYNMXsqpbtOxHgfmYz(jsdU3obCivHTh2HQW)0tHEfikuGuUOigeKHQ1uc9k0OGroZprAv4fw64Mm9VikrikFAglb9eSghj9sO1sW92j5P4mEfuIuKKIJtesjM(xGac5P4mEfuSFULohNKNZgRuh3KP)frjcr5tZyjONGj(P)f4E7K5jeDCDCadGrFpOrjkPsmOViBegP(MonQVzpQVMmFO(6e91yBo3y4Osh3KP)f5KH)FGtrsDCaJ(YskGw5tZyP(k(P)L(6e9LbBpe1x5tZyP(IvGO0Xnz6Fra9emXp9Va3BNmpHiyZ76ZjePnViacqfTooGrFzjvIqiLyQJBY0)Ia6jyc9kmj9Ob1Xnz6Fra9emkco9ePj64Mm9ViGEcgd))WSrbJeCVDc4PXXkvgrIvWkjQWYy4yaeqyOAnLrKyfSsIkkrqar(pp8clLrKyfSsIkisBErIGfrRJBY0)Ia6jymiKGWyE1bU3ob804yLkJiXkyLevyzmCmacimuTMYisScwjrfLOoUjt)lcONG1CiYW)paU3ob804yLkJiXkyLevyzmCmacimuTMYisScwjrfLiiGi)NhEHLYisScwjrfePnVirWIO1Xnz6Fra9emRKijHgFknohCVDc4PXXkvgrIvWkjQWYy4yaeqyOAnLrKyfSsIkkrqar(pp8clLrKyfSsIkisBErIGfrRJBY0)Ia6jymw38BZe6YyeW92jGNghRuzejwbRKOclJHJbqabWzOAnLrKyfSsIkkrDCtM(xeqpbRHqJpjIo0tDCtM(xeqpbRz4mHwrAue)lW925bsJJvQmIeRGvsuHLXWXaiGaPkS9Wouf(NEk0RarHcKYffXquf8aKNIZ4vq1bF240l2E3dT0)ceqipfNXRGQ5ipm)2KH)eYttabetMoBCIfs7i5K1OQJBY0)Ia6jygrIvWkjcU3oHMhMiBSsLfceLxrCc0Jgeqmz6SXjwiTJKiyvh3KP)fb0tWe6vOrbJCMFI0GZ9cNYWjRSaCVDcPkS9Wouf(NEk0RarHcKYffXGGmuTMk8p9uOxbYmGmuTMk8clbpa08WezJvQSqGO8kItGkAqaXKPZgNyH0osIG1OccimuTMsOxHgfmYz(jsRcVWsWda4qQcBpSdvH)PNc9kquOaPCrrmacimuTMk8p9uOxbYmGmuTMIsmQ64ag9LL003V4rQVFH6lwiDKGRVIq)HEgP(2Eo)fs03Sh1xbq8QJJcqFnz6FPVCNKkDCtM(xeqpbtAC(0KP)1K7Ke8YOXtIxDCeCscDzEYk4E70KPZgNyH0osozvhhWOVSCL(stXtxKJ6lwiTJeW13Sh1xrO)qpJuFBpN)cj6B2J6RaShfG(AY0)sF5ojv64Mm9ViGEcM048Pjt)Rj3jj4LrJN2JGtsOlZtwb3BNMmD24elK2rseSQJBY0)Ia6jyYNQsessOhdN5NiToUjt)lcONGrIfzJcg5m)eP1Xnz6Fra9emrOtB8jjHEmuhxhhWay0xGMP4PRVPb7WuFnz6FPVIq)HEgP(YDsQJBY0)IOShpL9MxZEdYgjj4E7KHQ1u0gYjj8PNcrt8lfjnzSiozHoUjt)lIYEe0tWKqJ0p5ExFwE1bU3oHuf2EyhQc)tpf6vGOqbs5IIyqqgQwtf(NEk0RarrjQJBY0)IOShb9emcvfqOxDG7TtivHTh2HQW)0tHEfikuGuUOigeKHQ1uH)PNc9kquuI64Mm9Vik7rqpbRhnUxDtscrJEMFI0G7TtivHTh2HkO15v3Knser4K9dtmkvOaPCrrmiyACSsfAWSFs6DKhuyzmCmiiBKiIWz(jsp7rJpL9gSdjreToUjt)lIYEe0tWqdM9tsVJ8a4E7esvy7HDOcADE1nzJereoz)WeJsfkqkxuedcMghRuHgm7NKEh5bfwgdhdcYgjIiCMFI0ZE04tzVb7qserRJBY0)IOShb9eSMdXz9SnW92PjtNnodFQACJgNK(xglItGceqoGjtNnodFQACJgNK(xglItavqtMoBCg(u14gnoj9VmweNYiLCCIfs7ijQ64Mm9Vik7rqpbte60pm4gFk0yJGlJuYXzAWomjNScU3obCgQwtjcD6hgCJpfASrfLOoUjt)lIYEe0tWe6vGKqpgcU3oHuf2EyhQcikYJCc)pXWe5inwjrHcKYffXGGmuTMscns)K7D9z5vNIsuh3KP)frzpc6jyK8H0Ke6XqW92jKQW2d7qvarrEKt4)jgMihPXkjkuGuUOigeKHQ1usOr6NCVRplV6uuI64Mm9Vik7rqpbJBSTj3i9GlJuYXzAWomjNScU3odFQACJgNK(xgtLUmMxDcEatMoBCg(u14gnoj9VmgGiJuYXjwiTJebnz6SXz4tvJB04K0)YyacqfvDCtM(xeL9iONG14gnoj9Vmg4E7eWtxgZRoDCtM(xeL9iONG14gnoj9Vmg4YiLCCMgSdtYjRG7TtapnowPQ3CojFiTclJHJbbnz6SXz4tvJB04K0)YyaImsjhNyH0ose0KPZgNHpvnUrJts)lJbiaLoUjt)lIYEe0tW4ExFwE1nzEEcU3opGjtNnodFQACJgNK(xglItzKsooXcPDKaciMmD24m8PQXnACs6FzSiob0OkidvRPeHo9ddUXNcn2OIsuqgQwtrBiNKWNEkenXVuK0KXI4Kf64Mm9Vik7rqpbRbFsoj9Vmg4E7KHQ1u9MZj5dPvuI64Mm9Vik7rqpbRz4mHwrAue)lW92j5P4mEfuDWNno9IT39ql9VabeYtXz8kOAoYdZVnz4pH80eqabsvy7HDOIGyGm)2eA0IwLZo4lm7vOaPCrrmOJBY0)IOShb9emj0i9tU31NLxDG7TtgQwtjHgPFY9U(S8QtfEHLGmuTMse60pm4gFk0yJkkrbzOAnfTHCscF6Pq0e)srstgdqyHoUjt)lIYEe0tWiuvaHE1bU3ozOAnLi0PFyWn(uOXgvuIcYq1AkAd5Ke(0tHOj(LIKMmgGWcDCtM(xeL9iONGrYhstsOhdb3BNmuTMse60pm4gFk0yJkkrbzOAnfTHCscF6Pq0e)srstgdqyHoUjt)lIYEe0tWiuvaHE1PJBY0)IOShb9eSMdXz9SnW92PjtNnodFQACJgNK(xglItavh3KP)frzpc6jysOr6NCVRplV6a3BNPXXkvsOr69QBsYhsRWYy4yaeqyOAnLeAK(j376ZYRov4fw64Mm9Vik7rqpbJBSTj3i9GlJuYXzAWomjNScU3otJJvQ4gP3RUzJB0irHLXWXGoUjt)lIYEe0tWAoeN1Z2a3BNMmD24m8PQXnACs6FzSiobIoUjt)lIYEe0tWyJereoZprADCtM(xeL9iONGj7nVMCVRplV6a3BNmuTMIKpKogIIiurjQJBY0)IOShb9emUX2MCJ0dU3ozOAnLeAK(j376ZYRofLOoUjt)lIYEe0tWi5dPjj0JHG7TtgQwtjHgPFY9U(S8QtrjQJBY0)IOShb9eSMdXz9SnW92PjtNnodFQACJgNK(xglIZd1Xnz6Fru2JGEcgYrASsJpz4gjb3BNmuTMI2qojHp9uiAIFPiPjJfXjl0Xnz6Fru2JGEcgjFiDmefri4E7KHQ1u0gYjj8PNcrt8lfjnzSiozHoUjt)lIYEe0tWKqJ0p5ExFwE1PJBY0)IOShb9emzV51K7D9z5vh4E7KHQ1u0gYjj8PNcrt8lfjnzStwJwh3KP)frzpc6jyc9kqsOhd1Xnz6Fru2JGEcgjFinjHEmuh3KP)frzpc6jynos6LqRLG7vIqiLyEYk4E7K8uCgVck2p3sNJtYZzJvQJBY0)IOShb9eSg3OXjP)LXaxgPKJZ0GDysozfCVDcXgej9gdh1Xnz6Fru2JGEcwZWzcTI0Oi(x64Mm9Vik7rqpbRbFsoj9VmMoUjt)lIYEe0tWK9MxtU31NLxDG7TtgQwtrBiNKWNEkenXVuK0KXI4Kf64Mm9Vik7rqpbdny2J1Ki6XqDCtM(xeL9iONGHgm7NihPXknUoUjt)lIYEe0tWe6vOrbJCMFI0G7TtgQwtj0RqJcg5m)ePvqK28IaiajADCDCadGrFhE1Xr9nnyhM6Rjt)l9ve6p0Zi1xUtsDCtM(xefXRooEk0RajHEmuh3KP)frr8QJJGEcg3yBtUr6b3BNmuTMQ)ZzVvbfLiiGCaivHTh2HkrOtB8j3yBttMuw(qIcfiLlkIbbzOAnLi0Pn(KBSTPjtklFirrstglcGkQ64Mm9VikIxDCe0tWe6vOrbJCMFI0G7TtaNHQ1uc9k0OGroZprAfLOoUjt)lII4vhhb9ems(qAsc9yi4E7esvy7HDOk8p9uOxbIcfiLlkIbbzOAnv4F6PqVcefLOoUjt)lII4vhhb9emj0i9tU31NLxDG7TtivHTh2HQW)0tHEfikuGuUOigeKHQ1uH)PNc9kquuI64Mm9VikIxDCe0tWCjojj0JHG7TtivHTh2HQW)0tHEfikuGuUOigeKHQ1uH)PNc9kquuI64Mm9VikIxDCe0tWiuvaHE1bU3oHuf2EyhQc)tpf6vGOqbs5IIyqqgQwtf(NEk0RarrjQJBY0)IOiE1XrqpbRXnACs6FzmW92jGNUmMxD64Mm9VikIxDCe0tW4ExFwE1nzEEcU3ozOAnfTHCscF6Pq0e)srstglItwiidvRPeHo9ddUXNcn2OIsuqO5HjYgRuzHar5vemuTMse60pm4gFk0yJkisBEr0Xnz6FrueV64iONGjcD6hgCJpfASrW92jdvRPeHo9ddUXNcn2Ok8clbpa08WezJvQSqGO8kca9qqabAEyISXkvwiquEbiavu1Xnz6FrueV64iONGXgjIiCMFI0G7TtO5HjYgRuzHar5veaA064Mm9VikIxDCe0tWAWNKts)lJbU3ozOAnvV5Cs(qAfLOoUjt)lII4vhhb9em0GzpwtIOhd1Xnz6FrueV64iONGXn22KBKEW92z4tvJB04K0)Yyki2GiP3y4OoUjt)lII4vhhb9eSMHZeAfPrr8Va3BNaoKQW2d7qfbXaz(Tj0OfTkNDWxy2Rqbs5IIyaeqK)ZdVWs1qOXNerh6PcI0MxKias064Mm9VikIxDCe0tWi5dPjj0JHG7TZ04yLks(q6gNccJuHLXWXGGmuTMIKpKMb6vhcvuI64Mm9VikIxDCe0tWK9MxtU31NLxDG7TtgQwtrYhshdrreQOe1Xnz6FrueV64iONGHCKgR04tgUrsW92jdvRPOnKts4tpfIM4xksAYyrCYcDCtM(xefXRooc6jy9OX9QBssiA0Z8tKgCVDcPkS9WoubToV6MSrIicNSFyIrPcfiLlkIbbtJJvQqdM9tsVJ8GclJHJbbpaBKiIWz(jsp7rJpL9gSdjrWkiGCa2ireHZ8tKE2JgFk7nyhsIiAbHMhMiBSsLfceLxrCagQwtXgjIiCMFI0kisBEraAbsuJAu1Xnz6FrueV64iONGHgm7NKEh5bW92jKQW2d7qf068QBYgjIiCY(HjgLkuGuUOigemnowPcny2pj9oYdkSmgoge8aSrIicN5Ni9Shn(u2BWoKebRGaYbyJereoZpr6zpA8PS3GDijIOfeAEyISXkvwiquEfXbyOAnfBKiIWz(jsRGiT5fbOfirnQrvh3KP)frr8QJJGEcMS38A2Bq2ijb3BNmuTMI2qojHp9uiAIFPiPjJfXjleeAEyISXkvwiquEfXjqpADCtM(xefXRooc6jyCVRplV6Mmppb3BNmuTMI2qojHp9uiAIFPiPjJDYA0cYq1AkrOt)WGB8PqJnQcVWsh3KP)frr8QJJGEcgjFinjHEmuh3KP)frr8QJJGEcgjFiDmefri4E7KHQ1u0gYjj8PNcrt8lfjnzSiozHoUjt)lII4vhhb9eSghj9sO1sW9kriKsmpzfCVDsEkoJxbf7NBPZXj55SXk1Xnz6FrueV64iONGj0RqJcg5m)ePb3BNmuTMsOxHgfmYz(jsRGiT5fbqynADCtM(xefXRooc6jyCJTn5gPxh3KP)frr8QJJGEcg376ZYRUjZZtW92jdvRPOnKts4tpfIM4xksAYyrCYcbzOAnLi0PFyWn(uOXgvHxyPJBY0)IOiE1XrqpbJqvbe6vh4E7eAEyISXkvwiquEfXjGgToUjt)lII4vhhb9eSg8j5K0)Yy64Mm9VikIxDCe0tWKqJ0p5ExFwE1PJBY0)IOiE1XrqpbZL4KKqpgQJBY0)IOiE1XrqpbR5qCwpBdCVDAY0zJZWNQg3OXjP)LX0Xnz6FrueV64iONG14iPxcTwcU3ojpfNXRGsKIKuCCIqkX0)sh3KP)frr8QJJGEcgAWSFICKgR0464Mm9VikIxDCe0tWACJgNK(xgdCVDsWm9QJOAoNJWjP)LX0Xnz6FrueV64iONGj0RqJcg5m)ePb3BNmuTMsOxHgfmYz(jsRGiT5fbqas0BU5Ua]] )


end
