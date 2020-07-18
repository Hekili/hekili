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
if select( 2, UnitClass( 'player' ) ) == 'SHAMAN' then
    local spec = Hekili:NewSpecialization( 263 )

    spec:RegisterResource( Enum.PowerType.Mana )   

    -- Talents
    spec:RegisterTalents( {
        lashing_flames = 22354, -- 334046
        forceful_winds = 22355, -- 262647
        elemental_blast = 22353, -- 117014

        stormfury = 22636, -- 334175
        hot_hand = 23462, -- 201900
        totem_mastery = 23109, -- 333925

        spirit_wolf = 23165, -- 260878
        earth_shield = 19260, -- 974
        static_charge = 23166, -- 265046

        cycle_of_the_elements = 23089, -- 210853
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
        relentless = 3553, -- 196029
        gladiators_medallion = 3551, -- 208683
        adaptation = 3552, -- 214027

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

        ember_totem = {
            id = 262399,
            duration = 120,
            max_stack =1 ,
        },

        -- Used to proc Maelstrom Weapon stacks.
        feral_spirit = {
            id = 333957,
            duration = 15,
            max_stack = 1,
        },
        
        --[[ BfA
        feral_spirit = {            
            name = "Feral Spirit",
            duration = 15,
            generate = function ()
                local cast = rawget( class.abilities.feral_spirit, "lastCast" ) or 0
                local up = cast + 15 > query_time

                local fs = buff.feral_spirit
                fs.name = "Feral Spirit"

                if up then
                    fs.count = 1
                    fs.expires = cast + 15
                    fs.applied = cast
                    fs.caster = "player"
                    return
                end
                fs.count = 0
                fs.expires = 0
                fs.applied = 0
                fs.caster = "nobody"
            end,
        }, ]]

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

        --[[ BfA - need to revise weapon enchant parsing?
        flametongue = {
            id = 194084,
            duration = 16,
        }, ]]

        forceful_winds = {
            id = 262652,
            duration = 15,
            max_stack = 5,
        },        

        --[[ BfA
        frostbrand = {
            id = 196834,
            duration = 16,
        }, ]]

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

        --[[ totem_mastery = {
            duration = 120,
            generate = function ()
                local expires, remains = 0, 0

                for i = 1, 5 do
                    local _, name, cast, duration = GetTotemInfo(i)

                    if name == class.abilities.totem_mastery.name then
                        if cast + duration > expires then
                            expires = cast + duration
                            remains = expires - now
                        end
                    end
                end

                local up = PlayerBuffUp( "resonance_totem" ) and remains > 0

                local tm = buff.totem_mastery
                tm.name = class.abilities.totem_mastery.name

                if up then
                    tm.count = 4
                    tm.expires = expires
                    tm.applied = expires - 120
                    tm.caster = "player"

                    applyBuff( "resonance_totem", remains )
                    applyBuff( "tailwind_totem", remains )
                    applyBuff( "storm_totem", remains )
                    applyBuff( "ember_totem", remains )
                    return
                end

                tm.count = 0
                tm.expires = 0
                tm.applied = 0
                tm.caster = "nobody"

                removeBuff( "resonance_totem" )
                removeBuff( "tailwind_totem" )
                removeBuff( "storm_totem" )
                removeBuff( "ember_totem" )
            end,
        }, ]]

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


        --[[ Azerite Powers
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
        }, ]]
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
        -- class.auras.totem_mastery.generate()
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


    spec:RegisterStateFunction( "consume_maelstrom", function( cap )
        local stacks = min( buff.maelstrom_weapon.stack, cap or 5 )

        if talent.hailstorm.enabled and buff.maelstrom_weapon.stack > buff.hailstorm.stack then
            applyBuff( "hailstorm", stacks )
        end

        removeStack( "maelstrom_weapon", stacks ) 

        if legendary.legacy_oF_the_frost_witch.enabled and stacks == 5 then
            setCooldown( "stormstrike", 0 )
            setCooldown( "windstrike", 0 )
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
            cast = function () return maelstrom_mod( 2.5 ) * haste end,
            cooldown = 0,
            gcd = "spell",
            
            spend = function () return maelstrom_mod( 0.3 ) end,
            spendType = "mana",
            
            startsCombat = true,
            texture = 136042,
            
            handler = function ()
                consume_maelstrom( 5 )
            end,
        },

        chain_lightning = {
            id = 188443,
            cast = function ()
                if buff.stormkeeper.up then return 0 end
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


        lava_lash = {
            id = 60103,
            cast = 0,
            cooldown = 18,
            gcd = "spell",

            startsCombat = true,
            texture = 236289,

            handler = function ()
                removeBuff( 'hot_hand' )
                removeDebuff( "target", "primal_primer" )

                if talent.lashing_flames.enabled then applyDebuff( "target", "lashing_flames" ) end

                if level < 116 and equipped.eye_of_the_twisting_nether then
                    applyBuff( 'fire_of_the_twisting_nether' )
                    if buff.crash_lightning.up then applyBuff( 'shock_of_the_twisting_nether' ) end
                end

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

                if talent.cycle_of_the_elements.enabled then
                    setCooldown( "flame_shock", 0 )
                    setCooldown( "frost_shock", 0 )
                end

                removeBuff( "legacy_of_the_frost_witch" )

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

        totem_mastery = {
            id = 333925,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            startsCombat = false,
            talent = "totem_mastery",

            handler = function ()
                summonPet( "searing_totem", 15 )
                summonPet( "healing_stream_totem", 15 )
                summonPet( "earthbind_totem", 20 )
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

                if talent.cycle_of_the_elements.enabled then
                    setCooldown( "flame_shock", 0 )
                    setCooldown( "frost_shock", 0 )
                end

                removeBuff( "legacy_of_the_frost_witch" )

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


    spec:RegisterPack( "Enhancement", 20200717, [[d4Z3naqBLAteH2fqBdKI9PI8Bv9xaZwH5Jq15bj)sj6Bss6FiuyNuL2lPDl1(LyuebddHmoIKCArdfKQAWGA4kYfbPIofrIJHGZHqPwOsyPGuLfJOLJ0tjSkek6Xq9CiteKk1uPkMSknDHhbsL8kLuxg11jQdtzAeP2mv2UsYZaP0Sur9zvyEssnsqQW3vuJMQAzerNeHsUfrs5AssCpj1kLeVgehLiPALG6rfxly1RKejjrevvcvfusIKuQisAveqnXQyYWqSdwfTTzvaD2(wJ5n3HkMmOgVDvpQa9YumRcPUCIHuGT(wGHUtAaLkiLZrqSALufxly1RKejjrevvcvfusIKuQicAvbAIXQxjHgOvf(59YTsQIlJWQa69Yh(fyOpnFAgqvGDpTal8T7ppS(IuXirbs9OIl7m5rOEuVeupQWWr(TkMZ(cG8zJQcUnYbF1fAOELu9Ocdh53Qyo7lkOjewfCBKd(Ql0q9cTQhvWTro4RUqfyAgmnnvqk7CGBJhOG(BGz2M(gefggsbU6cmbIuHHJ8Bv4yQnaqtjndnuVsREub3g5GV6cvGPzW00ub()X9NBquqtimiL3w2ivy4i)wfgcZ91AmRH6TkQhvWTro4RUqfyAgmnnvqk7CGBJhOG(BGz2M(gefggsb(ubwAvy4i)wfO4PBimpXunuVqJ6rfCBKd(QlubMMbtttfKYoh424bkO)gyMTPVbrHHHuGpvGLwfgoYVvbp4n3Hnaihgk0q9wv1Jk42ih8vxOcmndMMMkmCKRyaU5DYOc8PcmHcSelWKYohiMAiFGrE4hD2hG3FUvHHJ8BvGPgYhyKh(rN9HgQxPs9OcUnYbF1fQatZGPPPcszNd03YbkE6gefggsbUUaxLcSelWgoYvma38ozub(ubMGkmCKFRch9rbaY)Xq0q9sSvpQGBJCWxDHkmCKFRc3W2maY)XqubMMbtttfu2rzKVroyvGHcpyGWOhCGuVe0q9sGi1Jk42ih8vxOcmndMMMkmCKRyaU5DYOc8Pcmbvy4i)wfi5(Y0Sp0q9sGG6rfCBKd(QlubMMbtttfKYohO)ha(wFbLNuHHJ8BvmSvgWWq(AOEjiP6rfCBKd(QlubMMbtttfgoYvmW9dq3W2maY)XqkWeZcSekWsOaB4ixXaCZ7KrfyPwbMqbwkf4QjgfyOPalLc8PcCvuHHJ8Bv4skd0)ktd1lbOv9OcUnYbF1fQatZGPPPcszNdCB8af0FdmZ203GOWWqkWvxGjqKkmCKFRcu80nkOjewd1lbPvpQGBJCWxDHkW0myAAQWWrUIb4M3jJkWNkWekWsSalHcmPSZbUnEGc6VbMzB6Bquyyif4tfyPlWeN4fyszNdefpDdH5jMckpvGLIkmCKFRcSVLnWip8Jo7dnuVeQI6rfCBKd(QlubMMbtttfgoYvma38ozubUUatOalXcSekWKYoh424bkO)gyMTPVbrHHHuGpvGLUatCIxGjLDoqu80neMNykO8ubwkQWWr(Tkg5HF0zFaq(Jqd1lbOr9Ocdh53Qi(G3aBdfmfkvWTro4RUqd1lHQQEub3g5GV6cvGPzW00uX9dq3W2maY)XqaP82YgvGpvGnCKFdG)FC)5wfgoYVvHJ(Oaa5)yiAOEjivQhvy4i)wfi5(Y0Spub3g5GV6cnuVei2Qhvy4i)wfdBLbmmKVk42ih8vxOHgQyIY4FtAH6r9sq9OcUnYbF1fQatZGPPPcszNdCKh(rN9baYp5XfKYBlBubU6c8b(Qcdh53QyKh(rN9baYp5Xvd1RKQhvWTro4RUqfyAgmnnvqk7CGZzFDYuOaMzB6BqkVTSrf4QlWh4RkmCKFRI5SVozkuaZSn9TgQxOv9OcUnYbF1fQatZGPPPcszNdCo7RtMcfWmBtFds5TLnQaxDb(aFvHHJ8Bv4g2MJVpKzGz2M(wd1R0QhvWTro4RUqfyAgmnnvqk7CGZzFDYuOaIp4n49NBvy4i)wfZzFDYuOaIp4TgAOHkwXuu(T6vsIKKiIiiP0Qy2OD2hivqS2tpn4BbwYcSHJ87c8irbcSurft03LdwfqxfyO3lF4xGH(08Pzavb290cSW3U)8W6lQuPuXWr(ncCIY4FtAr9ip8Jo7daKFYJ750vtk7CGJ8Wp6Spaq(jpUGuEBzJQ(aFlvmCKFJaNOm(3KwSUE5C2xNmfkGz2M((C6QjLDoW5SVozkuaZSn9niL3w2OQpW3sfdh53iWjkJ)nPfRRx6g2MJVpKzGz2M((C6QjLDoW5SVozkuaZSn9niL3w2OQpW3sfdh53iWjkJ)nPfRRxoN91jtHci(G3NtxnPSZboN91jtHci(G3G3FUlvkvmCKFJQNZ(cG8zJwQy4i)gTUE5C2xuqtiCPIHJ8B066LoMAda0usZ4C6QjLDoWTXduq)nWmBtFdIcddPAcevQy4i)gTUEPHWCFTgZNtxn()X9NBquqtimiL3w2Osfdh53O11lrXt3qyEIPNtxnPSZbUnEGc6VbMzB6BquyyiNKUuXWr(nAD9sEWBUdBaqomuCoD1KYoh424bkO)gyMTPVbrHHHCs6sfdh53O11lXud5dmYd)OZ(4C6QnCKRyaU5DYOteKiPSZbIPgYhyKh(rN9b49N7sfdh53O11lD0hfai)hd5C6QjLDoqFlhO4PBquyyi1vrIgoYvma38oz0jcLkgoYVrRRx6g2Mbq(pgYzmu4bdeg9GdunHZPRMYokJ8nYbxQy4i)gTUEjsUVmn7JZPR2WrUIb4M3jJorOuXWr(nAD9YHTYaggY)C6QjLDoq)pa8T(ckpvQy4i)gTUEPlPmq)RSZPR2WrUIbUFa6g2Mbq(pgcXucsWWrUIb4M3jJKAeKs1edOrkNQsPIHJ8B066LO4PBuqti850vtk7CGBJhOG(BGz2M(gefggs1eiQuXWr(nAD9sSVLnWip8Jo7JZPR2WrUIb4M3jJorqIsGu25a3gpqb93aZSn9nikmmKtstCItk7CGO4PBimpXuq5jPuQy4i)gTUE5ip8Jo7daYFeNtxTHJCfdWnVtgvtqIsGu25a3gpqb93aZSn9nikmmKtstCItk7CGO4PBimpXuq5jPuQy4i)gTUEz8bVb2gkykuLkgoYVrRRx6Opkaq(pgY50vF)a0nSndG8FmeqkVTSrNmCKFdG)FC)5UuXWr(nAD9sKCFzA2hLkgoYVrRRxoSvgWWq(QWKd)NQcOdgsosn0qva]] )

end
