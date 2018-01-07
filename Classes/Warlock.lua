local addon, ns = ...
local Hekili = _G[ addon ]

local class = ns.class
local state = ns.state

local addHook = ns.addHook

local addAbility = ns.addAbility
local modifyAbility = ns.modifyAbility
local addHandler = ns.addHandler

local addAura = ns.addAura
local modifyAura = ns.modifyAura

local addGearSet = ns.addGearSet
local addGlyph = ns.addGlyph
local addMetaFunction = ns.addMetaFunction
local addTalent = ns.addTalent
local addTrait = ns.addTrait
local addResource = ns.addResource
local addStance = ns.addStance

local addSetting = ns.addSetting
local addToggle = ns.addToggle


local ignoreCastOnReset = ns.ignoreCastOnReset

local registerCustomVariable = ns.registerCustomVariable
local registerInterrupt = ns.registerInterrupt

local removeResource = ns.removeResource

local setArtifact = ns.setArtifact
local setClass = ns.setClass
local setPotion = ns.setPotion
local setRegenModel = ns.setRegenModel
local setRole = ns.setRole
local setTalentLegendary = ns.setTalentLegendary


local RegisterEvent = ns.RegisterEvent
local RegisterUnitEvent = ns.RegisterUnitEvent

local storeDefault = ns.storeDefault


local PTR = ns.PTR or false

if (select(2, UnitClass('player')) == 'WARLOCK') then

    ns.initializeClassModule = function ()
    
        setClass( "WARLOCK" )
        --setSpecialization( "affliction" )

        -- Resources
        addResource( "mana", SPELL_POWER_MANA )
        addResource( "soul_shards", SPELL_POWER_SOUL_SHARDS, true )   
     
        state.seeds_of_corruption = setmetatable( {}, {
            __index = function( t, k, v )
                if k == 'count' then
                    t[ k ] = max( GetSpellCount( state.action.seed_of_corruption.id ), state.active_dot.seed_of_corruption )
                    return t[ k ]
                end
            end } )
            
        state.soul_shards = setmetatable( {
                actual = nil,
                max = 5,
                active_regen = 0,
                inactive_regen = 0,
                forecast = {},
                times = {},
                values = {},
                fcount = 0,
                regen = 0,
                regenerates = false,
            }, { __index = function( t, k )
                if k == 'count' or k == 'current' then
                    return t.actual

                elseif k == 'actual' then
                    t.actual = UnitPower( "player", SPELL_POWER_SOUL_SHARDS )
                    return t.actual
                end
            end } )

        addMetaFunction( 'state', 'soul_shard', function () return soul_shards.current end )


        setRegenModel( {
            drain_soul = {
                resource = 'mana',

                spec = 'affliction',

                aura = 'drain_soul',
                debuff = true,

                last = function ()
                    local app = state.debuff.drain_soul.applied
                    local t = state.query_time

                    local tick_time = class.auras.drain_soul.tick_time

                    local since = t - app
                    local ticks = floor( since / class.auras.drain_soul.tick_time )

                    local last = ( app + ( ticks * tick_time ) )
                    local remains = state.debuff.drain_soul.remains

                    while ( remains >= 0 ) do
                        last = last + tick_time
                        remains = remains - tick_time
                    end

                    return app + ( ticks * tick_time )
                end,

                interval = function ( now, val )
                    return class.auras.drain_soul.tick_time end,

                stop = function( x )
                    return x < ( 0.03 * state.mana.max )
                end,

                value = function( x )
                    return - 0.03 * state.mana.max
                end,
            }
        } )


        addHook( 'timeToReady', function( wait, action )
            local ability = action and class.abilities[ action ]

            if ability and ability.spend_type == "soul_shards" and ability.spend > state.soul_shards.current then
                wait = 3600
            end

            return wait
        end )

        
        -- Talents
        --[[ Absolute Corruption: Corruption is now permanent and deals 25% increased damage. Duration reduced to 40 sec against players. ]]
        addTalent( "absolute_corruption", 196103 ) -- 21180

        --[[ Burning Rush: Increases your movement speed by 50%, but also damages you for 4% of your maximum health every 1 sec. Movement impairing effects may not reduce you below 100% of normal movement speed. Lasts until cancelled. ]]
        addTalent( "burning_rush", 111400 ) -- 19291

        --[[ Contagion: You deal 18% increased damage to targets affected by your Unstable Affliction. ]]
        addTalent( "contagion", 196105 ) -- 22044

        --[[ Dark Pact: Sacrifices 20% of your demon's current health to shield you for 400% of the sacrificed health for 20 sec. If you have no demon, your health is sacrificed instead. Usable while suffering from control impairing effects. ]]
        addTalent( "dark_pact", 108416 ) -- 19288

        --[[ Demon Skin: Your Soul Leech absorption now passively recharges at a rate of 1% of maximum health every 1 sec, and may now absorb up to 20% of maximum health. ]]
        addTalent( "demon_skin", 219272 ) -- 22047

        --[[ Demonic Circle: Summons a Demonic Circle for 15 min, allowing you to cast it again to teleport to its location and remove all movement slowing effects. Limit 1. ]]
        addTalent( "demonic_circle", 48018 ) -- 19280

        --[[ Empowered Life Tap: Life Tap increases your damage dealt by 10% for 20 sec. ]]
        addTalent( "empowered_life_tap", 235157 ) -- 22088

        --[[ Grimoire of Sacrifice: Sacrifice your demon to gain Demonic Power, causing your spells to sometimes also deal 9,346 Shadow damage to the target and other enemies within 8 yds. Lasts 1 |4hour:hrs; or until you summon a demon. ]]
        addTalent( "grimoire_of_sacrifice", 108503 ) -- 19295

        --[[ Grimoire of Service: Summons a second demon which fights for you for 25 sec and deals 100% increased damage. 1.5 min cooldown. The demon will immmediately use one of its special abilities when summoned:    Grimoire: Imp: Cleanses 1 harmful Magic effect from you.  Grimoire: Voidwalker Taunts its target.  Grimoire: Succubus Seduces its target.  Grimoire: Felhunter Interrupts its target. ]]
        addTalent( "grimoire_of_service", 108501 ) -- 19294

        --[[ Grimoire of Supremacy: You are able to maintain control over even greater demons indefinitely, allowing you to summon a Doomguard or Infernal as a permanent pet. ]]
        addTalent( "grimoire_of_supremacy", 152107 ) -- 21182

        --[[ Haunt: A ghostly soul haunts the target, dealing 149,717 Shadow damage and increasing your damage dealt to the target by 30% for 15 sec. If the target dies, Haunt's cooldown is reset. ]]
        addTalent( "haunt", 48181 ) -- 19290

        --[[ Howl of Terror: Let loose a terrifying howl, causing 5 enemies within 10 yds to flee in fear, disorienting them for 20 sec. Damage may cancel the effect. ]]
        addTalent( "howl_of_terror", 5484 ) -- 22476

        --[[ Malefic Grasp: While channeling Drain Soul, your damage over time effects deal 70% increased damage to the target. ]]
        addTalent( "malefic_grasp", 235155 ) -- 22040

        --[[ Mortal Coil: Horrifies an enemy target into fleeing, incapacitating for 3 sec and healing you for 20% of maximum health. ]]
        addTalent( "mortal_coil", 6789 ) -- 19285

        --[[ Phantom Singularity: Places a phantom singularity above the target, which consumes the life of all enemies within 25 yards, dealing 258,736 damage over 14.1 sec, healing you for 30% of the damage done. ]]
        addTalent( "phantom_singularity", 205179 ) -- 19281

        --[[ Siphon Life: Siphons the target's life essence, dealing 90,720 damage over 15 sec and healing you for 100% of the damage it deals. ]]
        addTalent( "siphon_life", 63106 ) -- 19279

        --[[ Soul Conduit: Every Soul Shard you spend has a 20% chance to be refunded. ]]
        addTalent( "soul_conduit", 215941 ) -- 19293

        --[[ Soul Effigy: Creates a Soul Effigy bound to the target, which is attackable only by you. 35% of all damage taken by the Effigy is duplicated on the original target. Limit 1. Lasts 10 min. ]]
        addTalent( "soul_effigy", 205178 ) -- 19284

        --[[ Soul Harvest: Increases your damage and your pets' damage by 20%. Lasts 15 sec, increased by 2 sec for each target afflicted by your Agony, up to a maximum of 35 sec. ]]
        addTalent( "soul_harvest", 196098 ) -- 22046

        --[[ Sow the Seeds: Seed of Corruption will now embed a demon seed in 2 additional nearby enemies. ]]
        addTalent( "sow_the_seeds", 196226 ) -- 19292

        --[[ Writhe in Agony: Agony's damage may now ramp up twice as high. ]]
        addTalent( "writhe_in_agony", 196102 ) -- 22090


        -- Traits
        addTrait( "compounding_horror", 199282 )
        addTrait( "concordance_of_the_legionfall", 239042 )
        addTrait( "crystalline_shadows", 221862 )
        addTrait( "degradation_of_the_black_harvest", 241257 )
        addTrait( "drained_to_a_husk", 199120 )
        addTrait( "fatal_echoes", 199257 )
        addTrait( "harvester_of_souls", 201424 )
        addTrait( "hideous_corruption", 199112 )
        addTrait( "inherently_unstable", 199152 )
        addTrait( "inimitable_agony", 199111 )
        addTrait( "long_dark_night_of_the_soul", 199214 )
        addTrait( "perdition", 199158 )
        addTrait( "reap_souls", 216698 )
        addTrait( "rend_soul", 238144 )
        addTrait( "seeds_of_doom", 199153 )
        addTrait( "shadows_of_the_flesh", 199212 )
        addTrait( "shadowy_incantations", 199163 )
        addTrait( "sinister_seeds", 238108 )
        addTrait( "soul_flame", 199471 )
        addTrait( "soulstealer", 214934 )
        addTrait( "sweet_souls", 199220 )
        addTrait( "winnowing", 238072 )
        addTrait( "wrath_of_consumption", 199472 )

        -- Auras
        addAura( "agony", 980, "duration", 18, "tick_time", 2 )
            modifyAura( "agony", "tick_time", function( x )
                return x * haste
            end )
        addAura( "banish", 710, "duration", 30 )
        addAura( "corruption", 146739, "duration", 14, "tick_time", 2 )
            modifyAura( "corruption", "tick_time", function( x )
                return x * haste
            end )

        addAura( "dark_pact", 108416, "duration", 20 )
        addAura( "deadwind_harvester", 216708, "duration", 60 )
        addAura( "demonic_circle", 48018, "duration", 900 )
        addAura( "demonic_power", 196099, "duration", 3600 )
        addAura( "drain_soul", 198590, "duration", 6, "tick_time", 1 )
            modifyAura( "drain_soul", "duration", function( x )
                return x * haste
            end )

            modifyAura( "drain_soul", "tick_time", function( x )
                return x * haste
            end )

        addAura( "empowered_life_tap", 235156, "duration", 20 )
        addAura( "enslave_demon", 1098, "duration", 300 )
        addAura( "eye_of_kilrogg", 126, "duration", 45 )
        addAura( "haunt", 48181, "duration", 10 )
        addAura( "mastery_potent_afflictions", 77215 )
        addAura( "phantom_singularity", 205179, "duration", 16 )
            modifyAura( "phantom_singularity", "duration", function( x )
                return x * haste
            end )

        addAura( "ritual_of_summoning", 698 )
        addAura( "seed_of_corruption", 27243, "duration", 18 )
        addAura( "sindorei_spite", 208868, "duration", 25 )
        addAura( "siphon_life", 63106, "duration", 15, "tick_time", 3 )
            modifyAura( "siphon_life", "tick_time", function( x )
                return x * haste
            end )

        addAura( "soul_effigy", 205178, "duration", 600 )
        addAura( "soul_harvest", 106098, "duration", 36 )
        addAura( "soul_leech", 108370 )
        addAura( "soulstone", 20707, "duration", 900 )
        addAura( "tormented_souls", 216695, "duration", 3600, "max_stack", 12 )
        addAura( "unending_resolve", 104773, "duration", 8 )
        addAura( "unending_breath", 5697, "duration", 600 )
        addAura( "unstable_affliction", 233490, "duration", 8, "tick_time", 2 )        
            modifyAura( "unstable_affliction", "duration", function( x ) return x * haste end )
            modifyAura( "unstable_affliction", "tick_time", function( x ) return x * haste end )
            class.auras.unstable_affliction_1 = class.auras.unstable_affliction

        addAura( "unstable_affliction_2", 233496, "duration", 8, "tick_time", 2 )
            modifyAura( "unstable_affliction_2", "duration", function( x ) return x * haste end )
            modifyAura( "unstable_affliction_2", "tick_time", function( x ) return x * haste end )

        addAura( "unstable_affliction_3", 233497, "duration", 8, "tick_time", 2 )
            modifyAura( "unstable_affliction_3", "duration", function( x ) return x * haste end )
            modifyAura( "unstable_affliction_3", "tick_time", function( x ) return x * haste end )

        addAura( "unstable_affliction_4", 233498, "duration", 8, "tick_time", 2 )
            modifyAura( "unstable_affliction_4", "duration", function( x ) return x * haste end )
            modifyAura( "unstable_affliction_4", "tick_time", function( x ) return x * haste end )

        addAura( "unstable_affliction_6", 233499, "duration", 8, "tick_time", 2 )
            modifyAura( "unstable_affliction_5", "duration", function( x ) return x * haste end )
            modifyAura( "unstable_affliction_5", "tick_time", function( x ) return x * haste end )


        -- Gear Sets
        addGearSet( 'tier21', 152174, 152177, 152172, 152176, 152173, 152175 )

        addGearSet( 'tier20', 147183, 147186, 147181, 147185, 147182, 147184 )

        addGearSet( 'tier19', 138314, 138323, 138373, 138320, 138311, 138317 )

        addGearSet( 'class', 139765, 139768, 139767, 139770, 139764, 139769, 139766, 139763 )
        
        addGearSet( 'ulthalesh_the_deadwind_harvester', 128942 )
        setArtifact( 'ulthalesh_the_deadwind_harvester' )

        addGearSet( 'amanthuls_vision', 154172 )
        addGearSet( 'hood_of_eternal_disdain', 132394 )
        addGearSet( 'norgannons_foresight', 132455 )
        addGearSet( 'pillars_of_the_dark_portal', 132357 )
        addGearSet( 'power_cord_of_lethtendris', 132457 )
        addGearSet( 'reap_and_sow', 144364 )
        addGearSet( 'sacrolashs_dark_strike', 132378 )
        addGearSet( 'sindorei_spite', 132379 )
        addGearSet( 'soul_of_the_netherlord', 151649 )
        addGearSet( 'stretens_sleepless_shackles', 132381 )
        addGearSet( 'the_master_harvester', 151821 )

        setTalentLegendary( 'soul_of_the_netherlord', 'affliction',     'deaths_embrace' )
        setTalentLegendary( 'soul_of_the_netherlord', 'destruction',    'eradication' )
        setTalentLegendary( 'soul_of_the_netherlord', 'demonology',     'grimoire_of_synergy' )


        --[[ local afflictions = {
            [233490] = true,
            [233496] = true,
            [233497] = true,
            [233498] = true,
            [233499] = true
        } ]]

        registerCustomVariable( 'unstable_afflictions', 
            setmetatable( {}, { __index = function( t, k )
                return  ( state.dot.unstable_affliction.up and 1 or 0 ) +
                        ( state.dot.unstable_affliction_2.up and 1 or 0 ) +
                        ( state.dot.unstable_affliction_3.up and 1 or 0 ) +
                        ( state.dot.unstable_affliction_4.up and 1 or 0 ) +
                        ( state.dot.unstable_affliction_5.up and 1 or 0 )
            end
        } ) )

        function state.applyUnstableAffliction( duration )
            if state.debuff.unstable_affliction.down then
                state.applyDebuff( 'target', 'unstable_affliction', duration or ( 8 * state.haste ) )

            else
                for i = 2, 5 do
                    local aura = "unstable_affliction_" .. i

                    if state.debuff[ aura ].down then
                        state.applyDebuff( 'target', aura, duration or ( 8 * state.haste ) )
                    end
                end
            end
        end


        local summons = {
            [18540] = true,
            [157757] = true,
            [1122] = true,
            [157898] = true,
        }

        local last_sindorei_spite = 0

        RegisterUnitEvent( "UNIT_SPELLCAST_SUCCEEDED", function( _, unit, spell, _, spellID )

            if not UnitIsUnit( unit, "player" ) then return end

            local now = GetTime()

            if summons[ spellID ] then
                if state.talent.grimoire_of_supremacy.enabled and now - last_sindorei_spite > 180 then
                    last_sindorei_spite = now
                elseif not state.talent.grimoire_of_supremacy.enabled and now - last_sindorei_spite > 25 then
                    last_sindorei_spite = now
                end
            end

        end )


        addHook( 'reset_precast', function ()

            state.soul_shards.actual = nil

            local now = GetTime()
            local icd = ( state.talent.grimoire_of_supremacy.enabled and 180 or 25 )

            if now - last_sindorei_spite < icd then
                state.cooldown.sindorei_spite_icd.applied = last_sindorei_spite
                state.cooldown.sindorei_spite_icd.expires = last_sindorei_spite + icd
                state.cooldown.sindorei_spite_icd.duration = icd
            end

        end )



        ignoreCastOnReset( "drain_soul" ) -- testing for breaking channels.
        setPotion( "prolonged_power" )

        -- Abilities

        -- Agony
        --[[ Inflicts increasing agony on the target, causing up to 116,867 Shadow damage over 18 sec. Damage starts low and increases over the duration. Refreshing Agony maintains its current damage level.    Agony damage sometimes generates 1 Soul Shard. ]]

        addAbility( "agony", {
            id = 980,
            spend = 0.03,
            min_cost = 24000,
            spend_type = "mana",
            cast = 0,
            gcdType = "spell",
            cooldown = 0,
            min_range = 0,
            max_range = 40,
            recheck = function ()
                return remains, remains - ( tick_time + gcd ), remains - ( duration * 0.3 )
            end
        } )

        addHandler( "agony", function ()
            applyDebuff( 'target', 'agony', 18, debuff.agony.stack or 1 )
        end )


        -- Banish
        --[[ Banishes an enemy Demon, Aberration, or Elemental, preventing any action for 30 sec. Limit 1. Casting Banish again on the target will cancel the effect. ]]

        addAbility( "banish", {
            id = 710,
            spend = 0.02,
            min_cost = 20000,
            spend_type = "mana",
            cast = 1.5,
            gcdType = "spell",
            cooldown = 0,
            min_range = 0,
            max_range = 30,
        } )

        modifyAbility( "banish", "cast", function( x ) return x * haste end )

        addHandler( "banish", function ()
            applyDebuff( 'target', 'banish', 30 )
        end )


        -- Corruption
        --[[ Corrupts the target, causing 79,765 Shadow damage over 14 sec. ]]

        addAbility( "corruption", {
            id = 172,
            spend = 0.03,
            min_cost = 24000,
            spend_type = "mana",
            cast = 0,
            gcdType = "spell",
            cooldown = 0,
            min_range = 0,
            max_range = 40,
            recheck = function ()
                return remains, remains - ( tick_time + gcd ), remains - ( duration * 0.3 )
            end
        } )

        addHandler( "corruption", function ()
            applyDebuff( 'target', 'corruption', 14 )
        end )


        -- Create Healthstone
        --[[ Creates a Healthstone that can be consumed to restore 366,314 health. ]]

        addAbility( "create_healthstone", {
            id = 6201,
            spend = 0.05,
            min_cost = 40000,
            spend_type = "mana",
            cast = 3,
            gcdType = "spell",
            cooldown = 0,
            min_range = 0,
            max_range = 0,
        } )

        modifyAbility( "create_healthstone", "cast", function( x ) return x * haste end )

        addHandler( "create_healthstone", function ()
            -- does nothing we care about, not really needed but /shrug.
        end )


        -- Create Soulwell
        --[[ Creates a Soulwell for 2 min. Party and raid members can use the Soulwell to acquire a Healthstone. ]]

        addAbility( "create_soulwell", {
            id = 29893,
            spend = 0.1,
            min_cost = 80000,
            spend_type = "mana",
            cast = 3,
            gcdType = "spell",
            cooldown = 120,
            min_range = 0,
            max_range = 30,
        } )

        addHandler( "create_soulwell", function ()
            -- proto
        end )


        -- Dark Pact
        --[[ Sacrifices 20% of your demon's current health to shield you for 400% of the sacrificed health for 20 sec. If you have no demon, your health is sacrificed instead. Usable while suffering from control impairing effects. ]]

        addAbility( "dark_pact", {
            id = 108416,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            talent = "dark_pact",
            cooldown = 60,
            min_range = 0,
            max_range = 100,
        } )

        addHandler( "dark_pact", function ()
            applyBuff( "dark_pact", 20 )
        end )


        -- Demonic Circle
        --[[ Summons a Demonic Circle for 15 min, allowing you to cast it again to teleport to its location and remove all movement slowing effects. Limit 1. ]]

        addAbility( "demonic_circle", {
            id = 48018,
            spend = 0.05,
            min_cost = 40000,
            spend_type = "mana",
            cast = 0.5,
            gcdType = "spell",
            talent = "demonic_circle",
            cooldown = 0,
            min_range = 0,
            max_range = 0,
        } )

        modifyAbility( "demonic_circle", "cast", function( x ) return x * haste end )

        addHandler( "demonic_circle", function ()
            applyBuff( "demonic_circle", 900 )
        end )


        -- Demonic Gateway
        --[[ Creates a demonic gateway between two locations. Activating the gateway transports the user to the other gateway. Each player can use a Demonic Gateway only once per 1.5 min. ]]

        addAbility( "demonic_gateway", {
            id = 111771,
            spend = 0.1,
            min_cost = 80000,
            spend_type = "mana",
            cast = 3,
            gcdType = "spell",
            cooldown = 10,
            min_range = 10,
            max_range = 40,
        } )

        modifyAbility( "demonic_gateway", "cast", function( x ) return x * haste end )

        addHandler( "demonic_gateway", function ()
            -- proto
        end )


        -- Drain Soul
        --[[ Drains the target's soul, causing 139,272 Shadow damage over 5.3 sec, and healing you for 200% of the damage done.  Generates 1 Soul Shard if the target dies during this effect. ]]

        addAbility( "drain_soul", {
            id = 198590,
            spend = 0,
            min_cost = 0,
            spend_type = "mana",
            cast = 6,
            gcdType = "spell",
            cooldown = 0,
            min_range = 0,
            max_range = 40,
            aura = 'drain_soul',

            channeled = true,
            prechannel = true, -- run the ability's handler at the start.
            breakable = true,
            breakchannel = function ()
                removeDebuff( "target", "drain_soul" )
            end,
        } )

        modifyAbility( "drain_soul", "cast", function( x ) return x * haste end )        

        addHandler( "drain_soul", function ()
            applyDebuff( "target", "drain_soul", 6 * haste )
            applyBuff( "casting", 6 * haste )
            channelSpell( "drain_soul" )
        end )


        -- Enslave Demon
        --[[ Enslaves the target demon up to level 108, forcing it to do your bidding for 5 min. ]]

        addAbility( "enslave_demon", {
            id = 1098,
            spend = 0.05,
            min_cost = 40000,
            spend_type = "mana",
            cast = 3,
            gcdType = "spell",
            cooldown = 0,
            min_range = 0,
            max_range = 30,
        } )

        modifyAbility( "enslave_demon", "cast", function( x ) return x * haste end )

        addHandler( "enslave_demon", function ()
            applyDebuff( "target", "enslave_demon", 300 )
        end )


        -- Eye of Kilrogg
        --[[ Summons an Eye of Kilrogg and binds your vision to it. The eye is stealthed and moves quickly but is very fragile. ]]

        addAbility( "eye_of_kilrogg", {
            id = 126,
            spend = 0.04,
            min_cost = 32000,
            spend_type = "mana",
            cast = 2,
            gcdType = "spell",
            cooldown = 0,
            min_range = 0,
            max_range = 50000,
        } )

        modifyAbility( "eye_of_kilrogg", "cast", function( x ) return x * haste end )

        addHandler( "eye_of_kilrogg", function ()
            -- Does nothing we're concerned about for DPS.
            applyBuff( "eye_of_kilrogg", 45 )
        end )


        -- Fear
        --[[ Strikes fear in the enemy, disorienting for 20 sec. Damage may cancel the effect. Limit 1. ]]

        addAbility( "fear", {
            id = 5782,
            spend = 0.1,
            min_cost = 80000,
            spend_type = "mana",
            cast = 1.7,
            gcdType = "spell",
            cooldown = 0,
            min_range = 0,
            max_range = 30,
        } )

        modifyAbility( "fear", "cast", function( x ) return x * haste end )

        addHandler( "fear", function ()
            applyDebuff( "target", "fear", 20 )
        end )


        -- Grimoire of Service: Felhunter

        addAbility( "grimoire_felhunter", {
            id = 111897,
            known = 108501,
            spend = 1,
            spend_type = "soul_shards",
            cast = 0,
            gcdType = "spell",
            cooldown = 90,
            talent = 'grimoire_of_service'
        } )

        addHandler( "grimoire_felhunter", function ()
            summonPet( "grimoire_felhunter", 25 )
        end )

        class.abilities.service_pet = class.abilities.grimoire_felhunter


        -- Grimoire of Sacrifice

        addAbility( "grimoire_of_sacrifice", {
            id = 108503,
            spend = 0,
            spend_type = "mana",
            cast = 0,
            gcdType = "spell",
            cooldown = 30,
            talent = 'grimoire_of_sacrifice',
            usable = function () return pet.up end,
        } )

        addHandler( "grimoire_of_sacrifice", function ()
            dismissPet( 'imp' )
            dismissPet( 'voidwalker' )
            dismissPet( 'felhunter' )
            dismissPet( 'succubus' )
            applyBuff( "demonic_power" )
        end )


        addAbility ( "haunt", {
            id = 48181,
            spend = 0.05,
            spend_type = 'mana',
            cast = 1.5,
            gcdType = 'spell',
            cooldown = 25,
            talent = 'haunt',
            velocity = 30,
        } )

        modifyAbility( "haunt", "cast", function( x )
            return x * haste
        end )

        addHandler( "haunt", function ()
            applyDebuff( 'target', 'haunt', 10 )
        end )


        -- Health Funnel
        --[[ Sacrifices 24% of your maximum health to heal your summoned Demon for twice as much over 5.3 sec. ]]

        addAbility( "health_funnel", {
            id = 755,
            spend = 0,
            cast = 6,
            channeled = true,
            gcdType = "spell",
            cooldown = 0,
            min_range = 0,
            max_range = 45,
        } )

        modifyAbility( "health_funnel", "cast", function( x ) return x * haste end )

        addHandler( "health_funnel", function ()
            -- I don't remember if it buffs you and debuffs pet, one or the other, both...  Doesn't matter.
        end )


        -- Life Tap
        --[[ Restores 30% of your maximum mana, at the cost of 10% of your maximum health. ]]

        addAbility( "life_tap", {
            id = 1454,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            cooldown = 0,
            min_range = 0,
            max_range = 0,
            aura = 'empowered_life_tap',
            recheck = function ()
                if talent.empowered_life_tap.enabled then
                    return buff.empowered_life_tap.remains, buff.empowered_life_tap.remains - gcd
                end
            end
        } )

        addHandler( "life_tap", function ()
            gain( mana.max * 0.3, "mana" )
            spend( health.max * 0.1, "health" )
            if talent.empowered_life_tap.enabled then applyBuff( "empowered_life_tap", 20 + buff.empowered_life_tap.remains ) end
        end )


        -- Phantom Singularity

        addAbility( "phantom_singularity", {
            id = 205179,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            cooldown = 40,
        } )

        addHandler( "phantom_singularity", function ()
            applyDebuff( "target", "phantom_singularity" )
        end )


        -- Meteor Strike -- Infernal Pet?
        --[[ The infernal releases a powerful burst of flames, dealing 9,116 Fire damage to nearby targets, and stunning them for 2 sec. ]]

        --[[ addAbility( "meteor_strike", {
            id = 171152,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            cooldown = 1,
            min_range = 0,
            max_range = 50000,
        } )

        addHandler( "meteor_strike", function ()
            -- Probably belongs to the pet?
        end ) ]]


        -- Reap Souls
        --[[ Consume all Tormented Souls collected by Ulthalesh, increasing your damage by 10% and doubling the effect of all of Ulthalesh's other traits for 5 sec per soul consumed.
             Ulthalesh collects Tormented Souls from each target you kill and occasionally escaped souls it previously collected. ]]

        addAbility( "reap_souls", {
            id = 216698,
            spend = 0,
            cast = 0,
            gcdType = "off",
            cooldown = 5,
            min_range = 0,
            max_range = 0,
            buff = 'tormented_souls',
            equipped = 'ulthalesh_the_deadwind_harvester',
            toggle = 'artifact',
            recheck = function ()
                return buff.deadwind_harvester.remains
            end
        } )

        addHandler( "reap_souls", function ()
            removeBuff( 'tormented_souls' )
            applyBuff( "deadwind_harvester", buff.tormented_souls.stack * 5 )
        end )


        -- Ritual of Summoning
        --[[ Begins a ritual to create a summoning portal, requiring the caster and 2 allies to complete. This portal can be used to summon party and raid members. ]]

        --[[ addAbility( "ritual_of_summoning", {
            id = 698,
            spend = 0.04,
            min_cost = 0,
            spend_type = "mana",
            cast = 0,
            gcdType = "spell",
            cooldown = 120,
            min_range = 0,
            max_range = 30,
        } )

        addHandler( "ritual_of_summoning", function ()
            -- proto
        end ) ]]


        -- Seed of Corruption
        --[[ Embeds a demon seed in the enemy target that will explode after 15.9 sec, dealing 41,985 Shadow damage to all enemies within 10 yards and applying Corruption to them.    The seed will detonate early if the target is hit by other detonations, or takes 52,704 damage from your spells. ]]

        addAbility( "seed_of_corruption", {
            id = 27243,
            spend = 1,
            min_cost = 1,
            spend_type = "soul_shards",
            cast = 2.5,
            gcdType = "spell",
            cooldown = 0,
            min_range = 0,
            max_range = 40,
            recheck = function ()
                return dot.corruption.remains - ( cast_time + travel_time )
            end
        } )

        modifyAbility( "seed_of_corruption", "cast", function( x ) return x * haste end )

        addHandler( "seed_of_corruption", function ()
            applyDebuff( "target", "seed_of_corruption", 18 )
            if active_enemies > 1 then
                active_dot.seed_of_corruption = min( active_enemies, active_dot.seed_of_corruption + 2 )
            end
        end )


        -- Siphon Life
        --[[ Siphons the target's life essence, dealing 90,720 damage over 15 sec and healing you for 100% of the damage it deals. ]]

        addAbility( "siphon_life", {
            id = 63106,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            talent = "siphon_life",
            cooldown = 0,
            min_range = 0,
            max_range = 40,
            recheck = function ()
                return remains, remains - ( tick_time + gcd ), remains - ( duration * 0.3 )
            end
        } )

        addHandler( "siphon_life", function ()
            applyDebuff( "target", "siphon_life", 15 )
        end )


        -- Soul Effigy
        --[[ Creates a Soul Effigy bound to the target, which is attackable only by you. 35% of all damage taken by the Effigy is duplicated on the original target. Limit 1. Lasts 10 min. ]]

        addAbility( "soul_effigy", {
            id = 205178,
            spend = 0,
            cast = 1.5,
            gcdType = "spell",
            talent = "soul_effigy",
            cooldown = 0,
            min_range = 0,
            max_range = 40,
        } )

        modifyAbility( "soul_effigy", "cast", function( x ) return x * haste end )

        addHandler( "soul_effigy", function ()
            applyDebuff( "target", "soul_effigy", 600 )
            summonPet( "soul_effigy", 600 )
        end )


        -- Soul Harvest

        addAbility( "soul_harvest", {
            id = 196098,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            talent = "soul_harvest",
            cooldown = 120,
            toggle = "cooldowns",
            recheck = function () return buff.soul_harvest.remains - 8 end,
        } )

        addHandler( "soul_harvest", function ()
            applyBuff( "soul_harvest", min( 36, 12 + ( active_dot.agony * 4 ) ) )
        end )


        -- Soulstone
        --[[ Stores the soul of the target party or raid member, allowing resurrection upon death. Also castable to resurrect a dead target. Targets resurrect with 60% health and 20% mana. ]]

        addAbility( "soulstone", {
            id = 20707,
            spend = 0.05,
            min_cost = 40000,
            spend_type = "mana",
            cast = 3,
            gcdType = "spell",
            cooldown = 600,
            min_range = 0,
            max_range = 40,
        } )

        modifyAbility( "soulstone", "cast", function( x ) return x * haste end )

        addHandler( "soulstone", function ()
            applyBuff( "soulstone", 900 )
        end )


        -- Summon Doomguard
        --[[ Summons a Doomguard under the command of the Warlock.    The Doomguard deals strong damage to a single target at a time. ]]

        addAbility( "summon_doomguard", {
            id = 18540,
            spend = 1,
            min_cost = 1,
            spend_type = "soul_shards",
            cast = 2.5,
            gcdType = "spell",
            cooldown = 180,
            min_range = 0,
            max_range = 0,
            usable = function ()
                if talent.grimoire_of_supremacy.enabled then return not pet.alive end
                return true
            end,
        }, 157757 )

        modifyAbility( "summon_doomguard", "cast", function( x )
            if talent.grimoire_of_supremacy.enabled then return x * haste end
            return 0
        end )

        modifyAbility( "summon_doomguard", "cooldown", function( x )
            if talent.grimoire_of_supremacy.enabled then return 0 end
            return x
        end )

        modifyAbility( "summon_doomguard", "toggle", function( x )
            if not talent.grimoire_of_supremacy.enabled then return 'cooldowns' end
            return x
        end )

        addHandler( "summon_doomguard", function ()
            summonPet( "doomguard", talent.grimoire_of_supremacy.enabled and 3600 or 25 )
            if equipped.sindorei_spite then
                applyBuff( "sindorei_spite", 25 )
                setCooldown( "sindorei_spite_icd", talent.grimoire_of_supremacy.enabled and 180 or 25 )
            end
            removeBuff( "demonic_power" )
        end )


        -- Summon Infernal
        --[[ Summons an Infernal under the command of the Warlock.    The Infernal deals strong area of effect damage. ]]

        addAbility( "summon_infernal", {
            id = 1122,
            spend = 1,
            min_cost = 1,
            spend_type = "soul_shards",
            cast = 2.5,
            gcdType = "spell",
            cooldown = 180,
            min_range = 0,
            max_range = 0,
            usable = function ()
                if talent.grimoire_of_supremacy.enabled then return not pet.alive end
                return true
            end,
        }, 157898 )

        modifyAbility( "summon_infernal", "cast", function( x )
            if talent.grimoire_of_supremacy.enabled then return x * haste end
            return 0
        end )

        modifyAbility( "summon_infernal", "cooldown", function( x )
            if talent.grimoire_of_supremacy.enabled then return 0 end
            return x
        end )

        modifyAbility( "summon_infernal", "toggle", function( x )
            if not talent.grimoire_of_supremacy.enabled then return 'cooldowns' end
            return x
        end )

        addHandler( "summon_infernal", function ()
            summonPet( "infernal", talent.grimoire_of_supremacy.enabled and 3600 or 25 )
            if equipped.sindorei_spite then
                applyBuff( "sindorei_spite", 25 )
                setCooldown( "sindorei_spite_icd", talent.grimoire_of_supremacy.enabled and 180 or 25 )
            end
            removeBuff( "demonic_power" )
        end )


        -- Summon Imp

        addAbility( "summon_imp", {
            id = 688,
            spend = 1,
            spend_type = "soul_shards",
            cast = 2.5,
            gcdType = "spell",
            cooldown = 0,
            usable = function ()
                return not pet.alive and buff.demonic_power.down
            end,
        } )

        modifyAbility( "summon_imp", "cast", function( x ) return x * haste end )

        addHandler( "summon_imp", function ()
            summonPet( "imp" )
        end )


        -- Summon Voidwalker

        addAbility( "summon_voidwalker", {
            id = 697,
            spend = 1,
            spend_type = "soul_shards",
            cast = 2.5,
            gcdType = "spell",
            cooldown = 0,
            usable = function ()
                return not pet.alive and buff.demonic_power.down
            end,
        } )

        modifyAbility( "summon_voidwalker", "cast", function( x ) return x * haste end )

        addHandler( "summon_voidwalker", function ()
            summonPet( "voidwalker" )
        end )


        -- Summon Felhunter

        addAbility( "summon_felhunter", {
            id = 691,
            spend = 1,
            spend_type = "soul_shards",
            cast = 2.5,
            gcdType = "spell",
            cooldown = 0,
            usable = function ()
                return not pet.alive and buff.demonic_power.down
            end,
        } )

        modifyAbility( "summon_felhunter", "cast", function( x ) return x * haste end )

        addHandler( "summon_felhunter", function ()
            summonPet( "felhunter" )
        end )

        class.abilities.summon_pet = class.abilities.summon_felhunter


        -- Summon Succubus

        addAbility( "summon_succubus", {
            id = 712,
            spend = 1,
            spend_type = "soul_shards",
            cast = 2.5,
            gcdType = "spell",
            cooldown = 0,
            usable = function ()
                return not pet.alive and buff.demonic_power.down
            end,
        } )

        modifyAbility( "summon_succubus", "cast", function( x ) return x * haste end )

        addHandler( "summon_succubus", function ()
            summonPet( "succubus" )
        end )


        addAbility( "sindorei_spite_icd", {
            id = -90,
            name = "Sindorei Spite ICD",
            spend = 0,
            spend = "mana",
            cast = 0,
            gcdType = "off",
            cooldown = 25,
            hidden = true,
            usable = function () return false end
        } )

        modifyAbility( "sindorei_spite_icd", "cooldown", function( x )
            if talent.grimoire_of_supremacy.enabled then return 180 end
            return x
        end )


        -- Unending Breath
        --[[ Allows an ally to breathe underwater and increases swim speed by 20% for 10 min. ]]

        addAbility( "unending_breath", {
            id = 5697,
            spend = 0.02,
            min_cost = 16000,
            spend_type = "mana",
            cast = 0,
            gcdType = "spell",
            cooldown = 0,
            min_range = 0,
            max_range = 30,
        } )

        addHandler( "unending_breath", function ()
            applyBuff( "unending_breath", 600  )
        end )


        -- Unending Resolve
        --[[ Hardens your skin, reducing all damage you take by 40% and granting immunity to interrupt and silence effects for 8 sec. ]]

        addAbility( "unending_resolve", {
            id = 104773,
            spend = 0.1,
            min_cost = 80000,
            spend_type = "mana",
            cast = 0,
            gcdType = "spell",
            cooldown = 180,
            min_range = 0,
            max_range = 0,
        } )

        addHandler( "unending_resolve", function ()
            applyBuff( "unending_resolve", 8 )
        end )


        -- Unstable Affliction
        --[[ Afflicts the target with 106,864 Shadow damage over 7.0 sec. You may afflict a target with up to 5 Unstable Afflictions at once.  If dispelled, deals 106,864 damage to the dispeller and silences them for 4 sec.  Refunds 1 Soul Shard if the target dies while afflicted. ]]

        addAbility( "unstable_affliction", {
            id = 30108,
            spend = 1,
            min_cost = 1,
            spend_type = "soul_shards",
            cast = 1.5,
            gcdType = "spell",
            cooldown = 0,
            min_range = 0,
            max_range = 40,
            aura = 'unstable_affliction',
            recheck = function ()
                return dot.unstable_affliction.remains - cast_time, dot.unstable_affliction_2.remains - cast_time, dot.unstable_affliction_3.remains - cast_time, dot.unstable_affliction_4.remains - cast_time, dot.unstable_affliction_5.remains - cast_time
            end
        } )

        modifyAbility( "unstable_affliction", "cast", function( x ) return x * haste end )

        addHandler( "unstable_affliction", function ()
            applyUnstableAffliction( 8 * haste )
            -- applyDebuff( "target", "unstable_affliction", 8 * haste, min( 5, debuff.unstable_affliction.stack + 1 ) )
        end )

        class.abilities.unstable_affliction_1 = class.abilities.unstable_affliction
        -- TODO: Check action.unstable_affliction_1.tick_time


        class.abilities.potion.elem.recheck = function ()
            if talent.haunt.enabled then return cooldown.haunt.remains end
            return 0
        end

    end


    storeDefault( [[SimC Affliction: default]], 'actionLists', 20180107.172146, [[dCdXdaGEIG2fvyBqs1mLQ0SbnFiXnrH7kvX3ik2jkTxLDRQ9d0Oicnmk63egmGHRI6GOQtre1XOklKO0sPswmv1YvPhkvEkYJH65qmrIatLcMmQmDHlsKCArxM01PqhwYwLQQntPTRcAzevNNi1NPI(oKK1rL62sz0OONre5KQaVvQkxdsk3tfYFHuVwfQfPI88MHrs9Lpu5M)i6SIZcMsyfP4hRCuh1gjbQTmcJj7ixkuleDSYn9KXZ0Z0HCtpj5nIW38CmAeposXJmdJ1Bggj1x(qLBYoIW38CmkkO(HJwbvBIr78wiNDOF5dvUr8(jmdPhHlieDHJu8OHjsm6GNlXviUJEXRJyi46VUSvthnITA6iuWwRPjgBT91vqiiaposXdc0BIe9GYDe)1jYOVA6rNOS1bcWBTWehP4Ddc0CEAKlfQfIow5MEY4zoYLIimEXkYmSyuhtfFmdXHAt)y(Jyi4yRMoIYwhiaV1ctCKI3niqZ5IXkFggj1x(qLBYoIW38CmkkO(HduDZGPIoF0LtXlTd9lFOYnI3pHzi9iCbHOlCKIhnmrIrh8CjUcXD0lEDedbx)1LTA6OrSvthHc2AnnXyRTVUccbb4XrkEqGEtKOhuUGas0tYJ4Vorg9vtp6eLToqaERfM4ifVBqauDZGPEAKlfQfIow5MEY4zoYLIimEXkYmSyuhtfFmdXHAt)y(Jyi4yRMoIYwhiaV1ctCKI3niaQUzWuxmwjndJK6lFOYnzhr4BEogffu)WbZY4ho0V8Hk3iE)eMH0JWfeIUWrkE0WejgDWZL4ke3rV41rmeC9xx2QPJgXwnDekyR10eJT2(6kieeGhhP4bb6nrIEq5ccir5sEe)1jYOVA6rNOS1bcWBTWehP4DdcWSm(XPrUuOwi6yLB6jJN5ixkIW4fRiZWIrDmv8XmehQn9J5pIHGJTA6ikBDGa8wlmXrkE3GamlJFSyXi2QPJOS1bcWBTWehP4DdcWP2YimwSb]] )

    storeDefault( [[SimC Affliction: precombat]], 'actionLists', 20180107.172146, [[d0d6gaGEsK0Mef2fv12if0(ifyMui1SP08PqCtL0DffvFdP0PrStq2R0Ub2punksKAykXVvCyHHsIidgjdxuDqLsNIevogvzzIslKuQLsblMKwokpKuYtjEmvwhjIAIKOyQKWKfz6qUiPOZRuCzvxNI2ijc2kfQndQTJu8rse6ZkvMMOO8DsHoKOipJcjJgPYFjvNePQBJQRrIQUhjk9ALQEouEljsC9QIkAccv7tvTIKFhjSeLAGidOqz1qLVIYC4W0IQ2vmC7dSxOSlE06T4T4NDXZO8QiogjhvPYwhImaSQOqEvrfnbHQ9PQDfXXi5OkzcNcf2dq(7ye(qyxFG1XmZzNhUn(heQ2NWPYaNsPXPYeofkShG83Xi8HWU(aRJfogbM4U)bHQ9jCkJyeCkvtyy)05dG40ZhnEMFA0iaNs5QSvLyjOnvWm58bOdFlDMa0zvOhKiUanSkGb8kRtY4Gbf8xPcuWFfXKZhaoLs4w6mbOZQy42hyVqzx8O1BPIHJnMm3XQIIQOfD3TFDO58dqvTY6KGc(RuuHYwfv0eeQ2NQ2vehJKJQGc7bi)DmcFiSRpW6yM5SZd3g)dcv7t4uzGtfmeboCiF7Ws6dSoSn4hZNfG94uAao1sLTQelbTPcMjNpaDca(mqyRqpirCbAyvad4vwNKXbdk4VsfOG)kIjNpaCk6bWNbcBfd3(a7fk7IhTElvmCSXK5owvuufTO7U9RdnNFaQQvwNeuWFLIkKrvfv0eeQ2NQ2vehJKJQGc7bi)DmcFiSRpW6yM5SZd3g)dcv7t4uzGtfoeHMRFW5KJHtPb4uEv2QsSe0MkyMC(a0ja4ZaHTc9GeXfOHvbmGxzDsghmOG)kvGc(RiMC(aWPOhaFgiS4ukTNYvXWTpWEHYU4rR3sfdhBmzUJvffvrl6UB)6qZ5hGQAL1jbf8xPOcLzvrfnbHQ9PQDfXXi5OkOWEaYFhJWhc76dSoMzo78WTX)Gq1(eovg4uHdrO56hCo5y4ukloLhovg4ubdrGdhY3oSK(aRdBd(X8zbypoLYItTuzRkXsqBQGzY5dqpndFNzWsvOhKiUanSkGb8kRtY4Gbf8xPcuWFfXKZhaoLYmdFNzWsvmC7dSxOSlE06TuXWXgtM7yvrrv0IU72Vo0C(bOQwzDsqb)vkQqkFvurtqOAFQAxrCmsoQckShG83Xi8HWU(aRJfogbM4U)bHQ9PkBvjwcAtLDmcFiSRpW6yHJrGjUxHEqI4c0WQagWRSojJdguWFLkqb)vuImcFiSJtnW4us4yeyI7vmC7dSxOSlE06TuXWXgtM7yvrrv0IU72Vo0C(bOQwzDsqb)vkQqAyvurtqOAFQAxrCmsoQckShG8ppF04zpPBjWxhf5(heQ2NWPYaNkt4uQMWW(NNpA8SN0Te4RJICFZ8kBvjwcAtflb(6OiVc9GeXfOHvbmGxzDsghmOG)kvGc(Ry0e4JtPiYRy42hyVqzx8O1BPIHJnMm3XQIIQOfD3TFDO58dqvTY6KGc(RuuHOTkQOjiuTpvTRSvLyjOnvYhezavOhKiUanSkGb8kRtY4Gbf8xPcuWFfJ4GHxwCoyyLIsAqKbK5gHvXWTpWEHYU4rR3sfdhBmzUJvffvrl6UB)6qZ5hGQAL1jbf8xPOIQaf8xriCTWP2cdBjoezakzCQC2Ddxnqf1c]] )

    storeDefault( [[SimC Affliction: haunt]], 'actionLists', 20180107.172146, [[dCusYaqicixsvQi2KQkJIq1PiuwfLQ8kkvLzravUfrrXUOKHrqhtkwMQKNjOAAQsvxJaSnII03OuzCefX5iGsRtvQinpcP7HkAFQs5GQQAHeOhsiMirr1fLsSrvPIAKeqHtkOmtkvv3evANezOefLwQG8uQMkr1vvLkSvPKElbuL7safTxK)IQgSkhwYIPOhl0Kv0LbBwv8zbmAkLtd1RrfMTc3wQ2nKFJYWvvoUQuPLtQNtY0fDDkSDb67efoVuQ1tav18jkTFLMAi5K3cQmhWKmj3)GiUgyb(vIzis6LmvaKlZHNYyKKGKhcgqPas6LWg7Ae2i06LWMWBi3JA8xso5)JjMHuKCsQHKtElOYCatsqY9Og)LKlq7zA88ynHAkdmAYBR0bbvcAlJV9(TxI7WEVTNa273EIVNPXZJvY0DaLWKxXmgklnuXCV34CpbSNSYUxw6aqAL4oWNm(jg2tuo3Z045Xkz6oGsyYRygdLLgQyUN92t89eWE23Enwcyp7TN47bVRb(7dMwAO(4l0KxXKXEfAUxZEm9Ec3tS9eBp7BpX3Z045XAc1ugy0K3wPdcQe0wAOxyKAp7TN47jG9SV9ASeWE2Bp4DnWFFW0sd1hFHM8kMm2tS9ENSxZR9S3EIVNa2Z(2RXsa7zV9eFp4DnWFFW0sd1hFHM8kMm2RqZ9A2JP3t4EITNy7j2EIr(Ft8aNTjxd1hVIzmuKhgAIJvY0KJyiGCUSzRLwQ6a5KlvDG8qq9TNZmgkYdbdOuaj9syJDncjpeOyg6iOi5usUi2GihCzbHoGsYKCUSPu1bYPKKErYjVfuzoGjji5EuJ)sYNGPXZJLTYaLwgF79BpbAptJNhRjutzGrtEBLoiOsqBz8r(Ft8aNTjxd1hVIzmuKhgAIJvY0KJyiGCUSzRLwQ6a5KlvDG8qq9TNZmgQ9eVrmYdbdOuaj9syJDncjpeOyg6iOi5usUi2GihCzbHoGsYKCUSPu1bYPKKcNKtElOYCatsqY9Og)LKxXehe4be0XGAV32RzVF7jq7zA88ynHAkdmAYBR0bbvcAlJV9(TxI7WEVTNa273EkMXGxzR0Z9EBpH79BpX3t89YAaO0sXKbFAd4vamvwaQmhWCVF7vXehe4be0XGAV34CVW3tS9Kv29QyIdc8ac6yqT3BCUNa2tmY)BIh4Sn5AO(4vmJHI8WqtCSsMMCedbKZLnBT0svhiNCPQdKhcQV9CMXqTN4VeJ8qWakfqsVe2yxJqYdbkMHocksoLKlIniYbxwqOdOKmjNlBkvDGCkjP3tYjVfuzoGjji5EuJ)sY1qVWi1EIY5EjoYbFI7WE23EbItY)BIh4Sn5vagQn5IydICWLfe6akjtY5YMTwAPQdKtEyOjowjttoIHaYLQoq()amuBY)RdOip2ooa(S0bGuXzd5HGbukGKEjSXUgHKhcumdDeuKCkjxK2XbiV0bGurcsox2uQ6a5usscGKtElOYCatsqY9Og)LKNLoaKwjUd8jJFIH9eLZ9ceN7zV9ET3V9umJbVYwPN7j6EcG8)M4boBt(uxyeVIzmixeBqKdUSGqhqjzsox2S1slvDGCYddnXXkzAYrmeqUu1bYL56cJ2ZzgdY)RdOip2ooa(S0bGuXzd5HGbukGKEjSXUgHKhcumdDeuKCkjxK2XbiV0bGurcsox2uQ6a5ussYuso5TGkZbmjbj3JA8xs(KLwrMwB8LygYsd9cJu79BVjlTQamuBln0lmsr(Ft8aNTjxz07me)dmSzGsqtEyOjowjttoIHaY5YMTwAPQdKtUu1bYDJENH27Dgg2mqjOjpemGsbK0lHn21iK8qGIzOJGIKtj5IydICWLfe6akjtY5YMsvhiNssYoso5TGkZbmjbj3JA8xsUaTxwdaLwb04odRbE2dVY4td9k22cqL5aM79BVkM4GapGGogu7jkN79AVF7j(EzPdaPvI7aFY4NyyV32RrMiCpzLDVS0bG0YguJ0M1xm3tuo37LW9Kv29YshasRe3b(KXpXWEIUx4c3tmY)BIh4Sn5kJENH4NmwpGrPNKhgAIJvY0KJyiGCUSzRLwQ6a5KlvDGC3O3zO9K5mwpGrPNKhcgqPas6LWg7AesEiqXm0rqrYPKCrSbro4YccDaLKj5CztPQdKtjjjti5K3cQmhWKeKCpQXFj5c0EznauAfqJ7mSg4zp8kJpn0RyBlavMdyU3V9QyIdc8ac6yqT3B79I8)M4boBtUYO3ziEm6b0OAqEyOjowjttoIHaY5YMTwAPQdKtUu1bYDJENH2lm0dOr1G8qWakfqsVe2yxJqYdbkMHocksoLKlIniYbxwqOdOKmjNlBkvDGCkjjbwso5TGkZbmjbj3JA8xsEwdaLwb04odRbE2dVY4td9k22cqL5aM79BVkM4GapGGogu7X5En79Bp4DnWFFW0sHrtMgW8QpCc79BpbAViJnMmzGSuy0KPbmV6dNapooT0qVWi1EVTNqY)BIh4Sn5kJENH4NmwpGrPNKhgAIJvY0KJyiGCUSzRLwQ6a5KlvDGC3O3zO9K5mwpGrPN7jEJyKhcgqPas6LWg7AesEiqXm0rqrYPKCrSbro4YccDaLKj5CztPQdKtjj1iKKtElOYCatsqY9Og)LKN1aqPvanUZWAGN9WRm(0qVITTauzoG5E)2RIjoiWdiOJb1EVTxZE)2dExd83hmTuy0KPbmV6dNWE)2tG2lYyJjtgilfgnzAaZR(WjWJJtln0lmsT3B7jK8)M4boBtUYO3ziEm6b0OAqEyOjowjttoIHaY5YMTwAPQdKtUu1bYDJENH2lm0dOr1ypXBeJ8qWakfqsVe2yxJqYdbkMHocksoLKlIniYbxwqOdOKmjNlBkvDGCkjPMgso5TGkZbmjbj3JA8xs(NgcYhioTASmqQSmhaF98mWXeZq7jRS7zA88yPygdEBLoiOsln0lmsT3BCUxJqY)BIh4Sn5MGwbAoWOaKhgAIJvY0KJyiGCUSzRLwQ6a5KlvDGCbbTc0CGrbipemGsbK0lHn21iK8qGIzOJGIKtj5IydICWLfe6akjtY5YMsvhiNssQ5fjN8wqL5aMKGK)3epWzBYnhm2K)Xq3M8WqtCSsMMCedbKZLnBT0svhiNCPQdKl4GXM79oBOBtEiyaLciPxcBSRri5HafZqhbfjNsYfXge5Glli0busMKZLnLQoqoLKut4KCYBbvMdyscsUh14VKCtJNhlfZyWBR0bbvAPHEHrQ9eLZ9Kj79BpdKklZbWxppdCmXmKYsLvKJ9EJZ9A273EvmXbbEabDmO27T9Ai)VjEGZ2KRygdEBLoiOsYddnXXkzAYrmeqox2S1slvDGCYLQoqUZmg7jWO0bbvsEiyaLciPxcBSRri5HafZqhbfjNsYfXge5Glli0busMKZLnLQoqoLKuZ7j5K3cQmhWKeKCpQXFj5c0EznauAPygdEBLoiOslavMdyU3V9eFVuJrCaP1NMfTkuBlJV9Kv29sngXbKwQSICW)PzrRc12Y4BpzLDVS0bG0kXDGpz8tmSNOCUNDc3twz3ZaPYYCa81ZZahtmdPSuzf5yV3271EIr(Ft8aNTj)JLygI8WqtCSsMMCedbKZLnBT0svhiNCPQdKlB85rOWy85rGNmllXmKatz1KhcgqPas6LWg7AesEiqXm0rqrYPKCrSbro4YccDaLKj5CztPQdKtjj1iaso5TGkZbmjbj3JA8xsEwdaLwkMXG3wPdcQ0cqL5aM79BptJNhlfZyWBR0bbvAz8T3V9eFVuJrCaP1NMfTkuBlJV9Kv29sngXbKwQSICW)PzrRc12Y4BpzLDVS0bG0kXDGpz8tmSNOCUNDc3twz3tG2lYyJjtgilBLbkT0qVWi1EVTNW9Kv29mqQSmhaF98mWXeZqklvwro27T9ETNyK)3epWzBY)yjMHipm0ehRKPjhXqa5CzZwlTu1bYjxQ6a5YgFEekmgFEe4jZYsmdjWuw9EI3ig5HGbukGKEjSXUgHKhcumdDeuKCkjxeBqKdUSGqhqjzsox2uQ6a5ussnYuso5TGkZbmjbj3JA8xsUg6fgP2tuo3lXro4tCh2Z(2lqCs(Ft8aNTjxH)SXq8d8dqUi2GihCzbHoGsYKCUSzRLwQ6a5KhgAIJvY0KJyiGCPQdK74pBm0E2p(bi)VoGI8y74a4ZshasfNnKhcgqPas6LWg7AesEiqXm0rqrYPKCrAhhG8shasfji5CztPQdKtjj1yhjN8wqL5aMKGK7rn(ljxd9cJu7jkN7L4ih8jUd7zF7fio373EIVxftCqGhqqhdQ9eDVW373EznauAPyYGpTb8kaMklavMdyUNSYUxftCqGhqqhdQ9eDpbSNyK)3epWzBYJmT24lXme5IydICWLfe6akjtY5YMTwAPQdKtEyOjowjttoIHaYLQoqUimT24lXme5)1buKhBhhaFw6aqQ4SH8qWakfqsVe2yxJqYdbkMHocksoLKls74aKx6aqQibjNlBkvDGCkjPgzcjN8wqL5aMKGK7rn(ljx89mnEESMqnLbgn5Tv6GGkbTLg6fgP2Z(2Z045Xkz6oGsyYRygdLLgQyUN92t89eWE23EW7AG)(GPLgQp(cn5vmzSNy7j2EVX5EIVxZR9S3EIVNa2Z(2RXsa7zV9G31a)9btlnuF8fAYRyYypX2tmY)BIh4Sn5AO(4vmJHI8WqtCSsMMCedbKZLnBT0svhiNCPQdKhcQV9CMXqTN4Hlg5HGbukGKEjSXUgHKhcumdDeuKCkjxeBqKdUSGqhqjzsox2uQ6a5ussncSKCYBbvMdyscsUh14VK8SgakTG(htgGgM8d8dWN1NfGkZbm373EMgppwq)Jjdqdt(b(b4Z6Zsd9cJu7jkN7fioj)VjEGZ2KpWpaFwFKhgAIJvY0KJyiGCUSzRLwQ6a5KlvDGC7h)a7jV(ipemGsbK0lHn21iK8qGIzOJGIKtj5IydICWLfe6akjtY5YMsvhiNss6Lqso5TGkZbmjbj)VjEGZ2K)zRqjRZRWOagJsJZ2KhgAIJvY0KJyiGCUSzRLwQ6a5KlvDGCzwBfkz99CmkGXO04Sn5HGbukGKEjSXUgHKhcumdDeuKCkjxeBqKdUSGqhqjzsox2uQ6a5ussVAi5K3cQmhWKeK8)M4boBtUTYaLKhgAIJvY0KJyiGCUSzRLwQ6a5KlvDGCbgLbkjpemGsbK0lHn21iK8qGIzOJGIKtj5IydICWLfe6akjtY5YMsvhiNss61lso5TGkZbmjbj3JA8xsUg6fgP2tuo3BAOReZq7zV9eAf(E)2llDaiTsCh4tg)ed79gN7PHEHrkY)BIh4Sn5vagQn5IydICWLfe6akjtY5YMTwAPQdKtEyOjowjttoIHaYLQoq()amu79eVrmY)RdOip2ooa(S0bGuXzd5HGbukGKEjSXUgHKhcumdDeuKCkjxK2XbiV0bGurcsox2uQ6a5ussVcNKtElOYCatsqY9Og)LKN1aqPf0)yYa0WKFGFa(S(SauzoG5E)2Z045Xc6FmzaAyYpWpaFwFwAOxyKApr3BAOReZq7zV9eAf(EYk7EznauA1Rb8GJ8b0L6ZcqL5aM79BVS0bG0kXDGpz8tmS3B71iG9(TxVqL1xm3t09Aes(Ft8aNTjFGFa(S(ipm0ehRKPjhXqa5CzZwlTu1bYjxQ6a52p(b2tE9TN4nIrEiyaLciPxcBSRri5HafZqhbfjNsYfXge5Glli0busMKZLnLQoqoLK0R3tYjVfuzoGjji5EuJ)sY1qVWi1EIY5EtdDLygAp7TNqRW373EzPdaPvI7aFY4NyyV34Cpn0lmsr(Ft8aNTjxH)SXq8d8dqEyOjowjttoIHaY5YMTwAPQdKtUu1bYD8NngAp7h)a7jEJyKhcgqPas6LWg7AesEiqXm0rqrYPKCrSbro4YccDaLKj5CztPQdKtjj9saKCYBbvMdyscsUh14VKCn0lmsTNOCU30qxjMH2ZE7j0k89(Txw6aqAL4oWNm(jg27no3td9cJu79BVjyA88yzRmqPLg6fgP27no3RIjMHSmqQSmhaF98mWXeZq8nwjoYbFI7WE2Bpz6E)2BcMgppw2kduAPHEHrQ9EJZ9QyIzildKklZbWxppdCmXmeFJvIJCWN4oSN9279K)3epWzBYv4pBme)a)aKlIniYbxwqOdOKmjNlB2APLQoqo5HHM4yLmn5igcixQ6a5o(ZgdTN9JFG9e)LyK)xhqrESDCa8zPdaPIZgYdbdOuaj9syJDncjpeOyg6iOi5usUiTJdqEPdaPIeKCUSPu1bYPKKEjtj5K3cQmhWKeKCpQXFj5znauAPyYGpTb8kaMklavMdyU3V9QyIdc8ac6yqT3BCUx47jRS7vXehe4be0XGAV34CpbSNSYUxftCqGhqqhdQ9EJZ9cFVF7nzPvKP1gFjMHS0qVWi1EIY5EXsL8jUd7zF7L6kim4tChi)VjEGZ2KRayYZE4JmT24lXme5HHM4yLmn5igciNlB2APLQoqo5svhi3byUh7zpryATXxIziYdbdOuaj9syJDncjpeOyg6iOi5usUi2GihCzbHoGsYKCUSPu1bYPKKEzhjN8wqL5aMKGK7rn(ljxd9cJu7jkN7nn0vIzO9S3EcTcFVF7LLoaKwjUd8jJFIH9EJZ90qVWif5)nXdC2M8itRn(smdrEyOjowjttoIHaY5YMTwAPQdKtUu1bYfHP1gFjMH2t8gXipemGsbK0lHn21iK8qGIzOJGIKtj5IydICWLfe6akjtY5YMsvhiNss6LmHKtElOYCatsqY9Og)LKRHEHrQ9eLZ9Mg6kXm0E2BpHwHV3V9YshasRe3b(KXpXWEVX5EAOxyKAVF7nbtJNhlBLbkT0qVWi1EVX5EvmXmKLbsLL5a4RNNboMygIVXkXro4tCh2ZE7jt373EtW045XYwzGsln0lmsT3BCUxftmdzzGuzzoa(65zGJjMH4BSsCKd(e3H9S3EVN8)M4boBtEKP1gFjMHixeBqKdUSGqhqjzsox2S1slvDGCYddnXXkzAYrmeqUu1bYfHP1gFjMH2t8xIr(FDaf5X2XbWNLoaKkoBipemGsbK0lHn21iK8qGIzOJGIKtj5I0ooa5LoaKksqY5YMsvhiNss6LaljN8wqL5aMKGK7rn(ljx89eO9YAaO0sXKbFAd4vamvwaQmhWCpzLDVkM4GapGGogu7j6EHVNy79BVkM4GapGGogu7j6EcyVF7j(EIVNIzm4v2k9CV34CV3V3V9eO9YAaO0kYqzfaZqwaQmhWCpX2twz3tXmg8kBLEU3BCUNa2twz3llDaiTsCh4tg)ed7j6EHlCpXi)VjEGZ2KBGuzzoa(65zGJjMHipm0ehRKPjhXqa5CzZwlTu1bYjxQ6a5VdKklZbS3)NNboMygI8qWakfqsVe2yxJqYdbkMHocksoLKlIniYbxwqOdOKmjNlBkvDGCkjPWfsYjVfuzoGjji5EuJ)sYRyIdc8ac6yqT3B71S3V9eFpbAVSgakTumzWN2aEfatLfGkZbm3twz3RIjoiWdiOJb1EIUx47j2E)2tXmg8kBLEU3BCU37373EznauAfzOScGzilavMdyU3V9Im2yYKbYYwzGsln0lmsTNO71iG9(T3KLwgivwMdGVEEg4yIzi(gln0lmsTNO7flvYN4oS3V9MS0YaPYYCa81ZZahtmdX)Ysd9cJu7j6EXsL8jUd79BVjlTmqQSmhaF98mWXeZq8HBPHEHrQ9eDVyPs(e3H9(T3KLwgivwMdGVEEg4yIzi(3BPHEHrQ9eDVyPs(e3H9(T3KLwgivwMdGVEEg4yIziEbyPHEHrQ9eDVyPs(e3bY)BIh4Sn5givwMdGVEEg4yIziYfXge5Glli0busMKZLnBT0svhiN8WqtCSsMMCedbKlvDG83bsLL5a27)ZZahtmdTN4nIr(FDaf5X2XbWNLoaKkoBipemGsbK0lHn21iK8qGIzOJGIKtj5I0ooa5LoaKksqY5YMsvhiNssk8gso5TGkZbmjbj3JA8xsEftCqGhqqhdQ9EBVM9(TN47jq7L1aqPLIjd(0gWRayQSauzoG5EYk7EvmXbbEabDmO2t09cFpX273EIVh8Ug4VpyAPsnKasXRga8naLIxzRICma1EYk7EW7AG)(GP1htgGMpY0tE2d)asBjGMASApX273ErgBmzYazzRmqPLg6fgP2t09AeWE)2BYsldKklZbWxppdCmXmeFJLg6fgP2t09ILk5tCh273EtwAzGuzzoa(65zGJjMH4FzPHEHrQ9eDVyPs(e3H9(T3KLwgivwMdGVEEg4yIzi(WT0qVWi1EIUxSujFI7WE)2BYsldKklZbWxppdCmXme)7T0qVWi1EIUxSujFI7WE)2BYsldKklZbWxppdCmXmeVaS0qVWi1EIUxSujFI7a5)nXdC2MCdKklZbWxppdCmXme5IydICWLfe6akjtY5YMTwAPQdKtEyOjowjttoIHaYLQoq(7aPYYCa79)5zGJjMH2t8xIr(FDaf5X2XbWNLoaKkoBipemGsbK0lHn21iK8qGIzOJGIKtj5I0ooa5LoaKksqY5YMsvhiNssk8xKCYBbvMdyscsUh14VKCX3tG2lRbGslftg8PnGxbWuzbOYCaZ9Kv29QyIdc8ac6yqTNO7f(EIT3V9QyIdc8ac6yqTNO7jG9(TxwdaLwrgkRaygYcqL5aM79BpfZyWRSv65EVX5EVFVF7nzPLbsLL5a4RNNboMygIVXsd9cJu7j6EXsL8jUd79BVjlTmqQSmhaF98mWXeZq8VS0qVWi1EIUxSujFI7WE)2BYsldKklZbWxppdCmXmeF4wAOxyKApr3lwQKpXDyVF7nzPLbsLL5a4RNNboMygI)9wAOxyKApr3lwQKpXDyVF7nzPLbsLL5a4RNNboMygIxawAOxyKApr3lwQKpXDG8)M4boBtUbsLL5a4RNNboMygI8WqtCSsMMCedbKZLnBT0svhiNCPQdK)oqQSmhWE)FEg4yIzO9epCXipemGsbK0lHn21iK8qGIzOJGIKtj5IydICWLfe6akjtY5YMsvhiNssk8Wj5K3cQmhWKeKCpQXFj5IVNaTxwdaLwkMm4tBaVcGPYcqL5aM7jRS7vXehe4be0XGApr3l89eBVF7vXehe4be0XGApr3ta79BVjyA88yzRmqPLg6fgP27no3RIjMHSmqQSmhaF98mWXeZq8nwjoYbFI7WE2BVxK)3epWzBYnqQSmhaF98mWXeZqKhgAIJvY0KJyiGCUSzRLwQ6a5KlvDG83bsLL5a27)ZZahtmdTN4VxmYdbdOuaj9syJDncjpeOyg6iOi5usUi2GihCzbHoGsYKCUSPu1bYPKKc)9KCYBbvMdyscsUh14VKCbAptJNhRjutzGrtEBLoiOsqBz8T3V9eFpdKklZbWxppdCmXmKYsLvKJ9EBVM9Kv29eFVpneKpqCA1yzGuzzoa(65zGJjMH273EMgppwjt3buctEfZyOS0qfZ9EBVM9eBpXi)VjEGZ2KRH6JxXmgkYddnXXkzAYrmeqox2S1slvDGCYLQoqEiO(2Zzgd1EI)EXipemGsbK0lHn21iK8qGIzOJGIKtj5IydICWLfe6akjtY5YMsvhiNsskCbqYjVfuzoGjji5EuJ)sY7fQS(I5EIY5Encj)VjEGZ2KpWpaFwFKhgAIJvY0KJyiGCUSzRLwQ6a5KlvDGC7h)a7jV(2t8xIrEiyaLciPxcBSRri5HafZqhbfjNsYfXge5Glli0busMKZLnLQoqoLKu4Yuso5TGkZbmjbj3JA8xs(NgcYhioTASg4hGpRV9(TNbsLL5a4RNNboMygszPYkYXECUNW9(TxVqL1xm3t09eGqY)BIh4Sn5d8dWN1h5HHM4yLmn5igciNlB2APLQoqo5svhi3(XpWEYRV9epCXipemGsbK0lHn21iK8qGIzOJGIKtj5IydICWLfe6akjtY5YMsvhiNsskC7i5K3cQmhWKeK8)M4boBt(uxyeVIzmipm0ehRKPjhXqa5CzZwlTu1bYjxQ6a5YCDHr75mJXEI3ig5)1buKhTvyeNncCyucATXxYzd5HGbukGKEjSXUgHKhcumdDeuKCkjxeBqKdUSGqhqjzsox2uQ6a5ussHlti5K3cQmhWKeKCpQXFj59cvwFXCpr3tMiK8)M4boBt(a)a8z9rUi2GihCzbHoGssqY5YcIrbiPgY5YMTwAPQdKtUu1bYTF8dSN86BpXFVyK)xhqrENfeJcWzd5HGbukGKEjSXUgHKhcumdDeuKCkjpm0ehRKPjhXqa5CztPQdKtjjfUaljN8wqL5aMKGK7rn(ljxd9cJu7jkN7nn0vIzO9Kz2t89cFp7TxIJCWN4oSNyK)3epWzBYRamuBYfXge5Glli0buscsoxwqmkaj1qox2S1slvDGCYfPDCaYlDaivKGKlvDG8)byO27j(lXi)VoGI8oligfGZgbUy74a4ZshasfNnKhcgqPas6LWg7AesEiqXm0rqrYPK8WqtCSsMMCedbKZLnLQoqoLK07fsYjVfuzoGjji5EuJ)sY1qVWi1EIY5EtdDLygApzM9eFVW3ZE7L4ih8jUd7jg5)nXdC2MCf(ZgdXpWpa5IydICWLfe6akjbjNlligfGKAiNlB2APLQoqo5I0ooa5LoaKksqYLQoqUJ)SXq7z)4hypXdxmY)RdOiVZcIrb4SrGl2ooa(S0bGuXzd5HGbukGKEjSXUgHKhcumdDeuKCkjpm0ehRKPjhXqa5CztPQdKtjj9(gso5TGkZbmjbj3JA8xsUg6fgP2tuo3BAOReZq7jZSN47f(E2BVeh5GpXDypXi)VjEGZ2KhzATXxIziYfXge5Glli0buscsoxwqmkaj1qox2S1slvDGCYfPDCaYlDaivKGKlvDGCryATXxIzO9epCXi)VoGI8oligfGZgbUy74a4ZshasfNnKhcgqPas6LWg7AesEiqXm0rqrYPK8WqtCSsMMCedbKZLnLQoqoLK07FrYjVfuzoGjji5)nXdC2M8b(b4Z6JCrSbro4YccDaLKGKZLfeJcqscjNlB2APLQoqo5svhi3(XpWEYRV9exaIr(FDaf5DwqmkaNcjpemGsbK0lHn21iK8qGIzOJGIKtj5HHM4yLmn5igciNlBkvDGCkPKCPQdK74Ui79)5zGJjMHENUNTYaLusea]] )

    storeDefault( [[SimC Affliction: mg]], 'actionLists', 20180107.172146, [[dGeRPaqiQs4siQQYMiQmkcQtrqwfvj9kQs0SquvUfIQODjsddroMGwMsYZernnQGCnev2Msk13OcnoevPZHOkSoLuenprO7HG2NsQoicSqeQhIOmrQGYffbBujfvJujfHtsvQzQKc3uPANeAOiQQSuQkpLYujkxvjL0wfrERsks3vjfL9Q6VezWahwYIPspwutwkxgAZkXNjWOPQ60i9AeYSLQBl0Ur1Vrz4kLJtfuTCsEoPMUIRlW2PI(ovGXRKsCEQI1JOQQMprv7h0p8YULaVC7y7U3SnmtRoL8Fnug)IRwBYDZHHlvqFoX38HDS04fxrk0XqsHKsxrkm5WBwwr3MB3iipugxFzxm8YULaVC7y7eFZYk62CZlGa3GLL0gwnhq5nj)LYjQhuLgSbbYbbdnIqW6qa5Ga5GaHHaHHa3GLL0HPIiFWMKMf01PkSYdeSoHqGdbbEjeu5H6eLqogPOgcKxEiWnyzjDyQiYhSjPzbDDQcR8abRtieqEabcbbYlpemLsaoPdnIsdtQrriircHa3GLL0HPIiFWMKMf01PkSYde4viqyiGCqGxcbHPKdc8keGo8a62g2svyTjv8MKM5aiqiiWlHaHHa3GLL0gwnhq5nj)LYjQhuLQWyr5AiWRqGWqa5GaVecctjhe4viaD4b0TnSLQWAtQ4njnZbqGqqa5piiCfe4viqyiGCqGxcbHPKdc8keGo8a62g2svyTjv8MKM5aiqiiqiiqOBe4s70XZnfwBsAwqxFZBEJMRHPUXzC82oRLuPeRiE7MyfXB(WAdcmwqxFZh2XsJxCfPqhdjDZhQzbQmQVSp3iZpMjAN5eJiFU7TDwtSI4TpxC1LDlbE52X2j(2ETwOXGOSsjah9nYDZYk62CBQoYNunlOl5Vuor9KI8YTJniqoiiZy9gZb8unlOl5Vuor9KQWyr5Aiiriix6rAOrec8keS2qGCqGcJfLRHGejecAbQAOmoe4viGuAYqGCqWukb4Ko0iknmPgfHG1jecuySOCneihem0iknmPgfHG1HGHMjsAOrec8keK8ncCPD645wjGX9CJm)yMODMtmI85U32zTKkLyfXB38M3O5AyQBCghVjwr8gbcyCp3iqjqFl7j3rPPucWrtyi5lwRfPSNChLMsjahnHK7MpSJLgV4ksHogs6MpuZcuzuFzFUrMNChLvkb4OpX32znXkI3(CXKVSBjWl3o2oX32R1cngeLvkb4OV5q3SSIUn3uySOCneKiHqGWqWqZejn0icbEjeii3GaHUrGlTthp3kbmUNBK5hZeTZCIrKp392oRLuPeRiE7M38gnxdtDJZ44nXkI3iqaJ7bceouOBeOeOVL9K7O0ukb4OjmK8fR1Iu2tUJstPeGJMqh6MpSJLgV4ksHogs6MpuZcuzuFzFUrMNChLvkb4OpX32znXkI3(Crh6YULaVC7y7eFZYk62CBQoYNunZbsJFusJytNI8YTJniqoiOYd1jkHCmsrneSoHqqYqGCqGMf0L0(lvdcieci3ncCPD645MgXMeBrkZuQGTHY438M3O5AyQBCghVTZAjvkXkI3Ujwr8MHydcylqazmLkyBOm(nFyhlnEXvKcDmK0nFOMfOYO(Y(CJm)yMODMtmI85U32znXkI3(CrYDz3sGxUDSDIVzzfDBUPzbDjT)s1GacHaYDJaxANoEUfW1t52rPAzPtZdLXV5nVrZ1Wu34moEBN1sQuIveVDtSI4T1kxpLBhHacww608qz8B(WowA8IRif6yiPB(qnlqLr9L95gz(Xmr7mNye5ZDVTZAIveV95IR9LDlbE52X2j(MLv0T52ukb4Ko0iknmPgfHGeHab5ge4viyfeiheOzbDjT)s1GGeHaYDJaxANoEU1ufLlPzb9BK5hZeTZCIrKp392oRLuPeRiE7M38gnxdtDJZ44nXkI3CyQIYHaJf0VrGsG(w2tUJstPeGJMWWB(WowA8IRif6yiPB(qnlqLr9L95gzEYDuwPeGJ(eFBN1eRiE7ZfD8YULaVC7y7eFZYk62CBQoYNumUXCaQWMuNUGstTLI8YTJniqoiWnyzjfJBmhGkSj1PlO0uBPkmwuUgcsKqiqqUDJaxANoEU1PlO0uB38M3O5AyQBCghVTZAjvkXkI3Ujwr82AqxqiqwTDZh2XsJxCfPqhdjDZhQzbQmQVSp3iZpMjAN5eJiFU7TDwtSI4TpxK8Ez3sGxUDSDIVzzfDBU1ytAMPubBdLXtvySOCneihe0ytAjGX9KQWyr56Be4s70XZnDqmY4sly3FaFq1nV5nAUgM6gNXXB7SwsLsSI4TBIveVzbXiJdbR5y3FaFq1nFyhlnEXvKcDmK0nFOMfOYO(Y(CJm)yMODMtmI85U32znXkI3(CrYJl7wc8YTJTt8nlROBZnVacMQJ8jvGIgzufkXwK0bBkmwzpPiVC7ydcKdcQ8qDIsihJuudbjsieSccKdcegcMsjaN0HgrPHj1OieSoeesEjbbYlpemLsaoP(XQp(t3YdeKiHqWksqG8YdbtPeGt6qJO0WKAuecsecsMeei0ncCPD645MoigzCPgJffeuQ2nV5nAUgM6gNXXB7SwsLsSI4TBIveVzbXiJdbomglkiOuTB(WowA8IRif6yiPB(qnlqLr9L95gz(Xmr7mNye5ZDVTZAIveV95IHKUSBjWl3o2oX3SSIUn38ciyQoYNubkAKrvOeBrshSPWyL9KI8YTJniqoiOYd1jkHCmsrneSoeS6gbU0oD8CtheJmUeLVGkE1V5nVrZ1Wu34moEBN1sQuIveVDtSI4nligzCiWB(cQ4v)MpSJLgV4ksHogs6MpuZcuzuFzFUrMFmt0oZjgr(C3B7SMyfXBFUyy4LDlbE52X2j(MLv0T52uDKpPcu0iJQqj2IKoytHXk7jf5LBhBqGCqqLhQtuc5yKIAiGqiiecKdcqhEaDBdBPAkVXuivsVrhecKdc8ciiZy9gZb8unL3ykKkP3OdkrZTufglkxdbRdbKUrGlTthp30bXiJl1ySOGGs1U5nVrZ1Wu34moEBN1sQuIveVDtSI4nligzCiWHXyrbbLQbbchk0nFyhlnEXvKcDmK0nFOMfOYO(Y(CJm)yMODMtmI85U32znXkI3(CXWvx2Te4LBhBN4Bwwr3MBt1r(KkqrJmQcLyls6GnfgRSNuKxUDSbbYbbvEOorjKJrkQHG1HGqiqoiaD4b0TnSLQP8gtHuj9gDqiqoiWlGGmJ1BmhWt1uEJPqQKEJoOen3svySOCneSoeq6gbU0oD8CtheJmUeLVGkE1V5nVrZ1Wu34moEBN1sQuIveVDtSI4nligzCiWB(cQ4vhceouOB(WowA8IRif6yiPB(qnlqLr9L95gz(Xmr7mNye5ZDVTZAIveV95IHjFz3sGxUDSDIVzzfDBUTPqNscYT0W0aUEk3okvllDAEOmoeiV8qGBWYsQMf0L8xkNOEsvySOCneSoHqqiPBe4s70XZnxuPrfruUGBEZB0Cnm1noJJ32zTKkLyfXB3eRiEJyuPrfruUGB(WowA8IRif6yiPB(qnlqLr9L95gz(Xmr7mNye5ZDVTZAIveV95IHo0LDlbE52X2j(gbU0oD8CZTZynPLaLNBEZB0Cnm1noJJ32zTKkLyfXB3eRiEJ4oJ1GG18aLNB(WowA8IRif6yiPB(qnlqLr9L95gz(Xmr7mNye5ZDVTZAIveV95IHK7YULaVC7y7eFZYk62CtHXIY1qqIecbcdbdntK0qJie4LqGGCdceccKdcMsjaN0HgrPHj1OieSoem0mrsdnIqGxHGKVrGlTthp300n)mUuNUG3iZpMjAN5eJiFU7TDwlPsjwr82nV5nAUgM6gNXXBIveVz0n)moeSg0f8gbkb6Bzp5oknLsaoAcdV5d7yPXlUIuOJHKU5d1Savg1x2NBK5j3rzLsao6t8TDwtSI4TpxmCTVSBjWl3o2oX3SSIUn3egc8ciyQoYNunZbsJFusJytNI8YTJniqE5HGkpuNOeYXif1qqIqqYqGqqGCqqLhQtuc5yKIAiiriGCqGCqGcJfLRHGejecegcgAMiPHgriWlHab5geieeihemLsaoPdnIsdtQrriyDiyOzIKgAeHaVcbjFJaxANoEULzkvW2qz8BK5hZeTZCIrKp392oRLuPeRiE7M38gnxdtDJZ44nXkI3iJPubBdLXVrGsG(w2tUJstPeGJMWWB(WowA8IRif6yiPB(qnlqLr9L95gzEYDuwPeGJ(eFBN1eRiE7ZfdD8YULaVC7y7eFJaxANoEUT5V4dlkPPCbb9srhp38M3O5AyQBCghVTZAjvkXkI3Ujwr8g5N)IpSieyuUGGEPOJNB(WowA8IRif6yiPB(qnlqLr9L95gz(Xmr7mNye5ZDVTZAIveV95IHK3l7wc8YTJTt8nlROBZTaUEk3okvllDAEOmUovpvMiiyDiiecKdcCdwws1SGUK)s5e1tQcJfLRHGejeciVqGCqGWqGxabt1r(K2WA8RLWORQYykYl3o2Ga5LhcMsjaN0HgrPHj1OieSoHqqyYRneiV8qWukb4Ko0iknmPgfHGejecCisqGq3iWL2PJNBAwqxYFPCI65M38gnxdtDJZ44TDwlPsjwr82nXkI3mwqhcwtukNOEU5d7yPXlUIuOJHKU5d1Savg1x2NBK5hZeTZCIrKp392oRjwr82NlgsECz3sGxUDSDIVzzfDBUnLsaoPdnIsdtQrriircHahjDJaxANoEUTXgkJFZBEJMRHPUXzC82oRLuPeRiE7MyfXBYNxwirkNxwwtj)ydLXxZKxDZh2XsJxCfPqhdjDZhQzbQmQVSp3iZpMjAN5eJiFU7TDwtSI4TpxCfPl7wc8YTJTt8nlROBZnHHaVacMQJ8jvZc6s(lLtupPiVC7ydcKxEiWnyzjvZc6s(lLtupPkmwuUgcwhccxbbcbbYbbbC9uUDuQww608qzCDQEQmrqW6ecbRUrGlTthp32ydLXV5nVrZ1Wu34moEBN1sQuIveVDtSI4n5ZllKiLZllRPKFSHY4RzYRGaHdf6MpSJLgV4ksHogs6MpuZcuzuFzFUrMFmt0oZjgr(C3B7SMyfXBFU4QWl7wc8YTJTt8nlROBZnfglkxdbjsieime0cu1qzCiWRqaP0KHaHGa5GGPucWjDOruAysnkcbRtieOWyr5AiqoiqyiiGRNYTJs1YsNMhkJRt1tLjcciecibbYlpeSPqNscYT0W0saJ7bce6gbU0oD8CReW4EUrMFmt0oZjgr(C3B7SwsLsSI4TBEZB0Cnm1noJJ3eRiEJabmUhiq4vcDJaLa9TSNChLMsjahnHH38HDS04fxrk0Xqs38HAwGkJ6l7ZnY8K7OSsjah9j(2oRjwr82NlUA1LDlbE52X2j(MLv0T5McJfLRHGejecegcAbQAOmoe4viGuAYqGqqGCqWukb4Ko0iknmPgfHG1jecuySOCneiheimeeW1t52rPAzPtZdLX1P6PYebbecbKGa5Lhc2uOtjb5wAyQMU5NXL60fece6gbU0oD8Ctt38Z4sD6cEJm)yMODMtmI85U32zTKkLyfXB38M3O5AyQBCghVjwr8Mr38Z4qWAqxqiq4qHUrGsG(w2tUJstPeGJMWWB(WowA8IRif6yiPB(qnlqLr9L95gzEYDuwPeGJ(eFBN1eRiE7ZfxL8LDlbE52X2j(MLv0T5MWqGxabt1r(KQzoqA8JsAeB6uKxUDSbbYlpeu5H6eLqogPOgcsecsgceccKdcQ8qDIsihJuudbjcbKdcKdcuySOCneKiHqGWqqlqvdLXHaVcbKstgceccKdcMsjaN0HgrPHj1OieSoHqGcJfLRHa5GaHHGaUEk3okvllDAEOmUovpvMiiGqiGeeiV8qWMcDkji3sdtZmLkyBOmoei0ncCPD645wMPubBdLXVrMFmt0oZjgr(C3B7SwsLsSI4TBEZB0Cnm1noJJ3eRiEJmMsfSnughceouOBeOeOVL9K7O0ukb4Ojm8MpSJLgV4ksHogs6MpuZcuzuFzFUrMNChLvkb4OpX32znXkI3(CXvo0LDlbE52X2j(MLv0T52uDKpPyCJ5auHnPoDbLMAlf5LBhBqGCqGBWYskg3yoavytQtxqPP2svySOCneKie0cu1qzCiWRqaP0KHa5LhcMQJ8jnwDCHMLeOk9wkYl3o2Ga5GGPucWjDOruAysnkcbRdbHKdcKdcIfVs3YdeKiees6gbU0oD8CRtxqPP2U5nVrZ1Wu34moEBN1sQuIveVDtSI4T1GUGqGSAdceouOB(WowA8IRif6yiPB(qnlqLr9L95gz(Xmr7mNye5ZDVTZAIveV95IRi3LDlbE52X2j(MLv0T5MWqWuDKpPAMdKg)OKgXMof5LBhBqGCqqLhQtuc5yKIAiyDcHGKHaHGa5LhcegcQ8qDIsihJuudbRtieqoiqoiOXM0mtPc2gkJNQWyr5AiircHGCPhPHgriWlHGrvoXU0qJiei0ncCPD645MgXMeBrkZuQGTHY438M3O5AyQBCghVTZAjvkXkI3Ujwr8MHydcylqazmLkyBOmoeiCOq38HDS04fxrk0Xqs38HAwGkJ6l7ZnY8JzI2zoXiYN7EBN1eRiE7ZfxT2x2Te4LBhB39MLv0T5MltRHa5GGPucWjDOruAysnkcbjcbjt6gbU0oD8ClGRNYTJs1YsNMhkJFZBEJMRHPUXzC82oRLuPeRiE7MyfXBRvUEk3ocbeSS0P5HY4qGWHcDZ8ZCWoRrxOOsF3B(WowA8IRif6yiPB(qnlqLr9L95gz(Xmr7mNye5ZDVTZAIveV95IRC8YULaVC7y7eFZYk62CRYd1jkHCmsrneSoeecbYbbAwqxs7VuniyDcHah6gbU0oD8ClGRNYTJs1YsNMhkJFZBEJMRHPUXzC82oRLuPeRiE7MyfXBRvUEk3ocbeSS0P5HY4qGWRe6MpSJLgV4ksHogs6MpuZcuzuFzFUrMFmt0oZjgr(C3B7SMyfXBFU4kY7LDlbE52X2j(MLv0T5MWqqaxpLBhLQLLonpugxNQNkteeqieqccKxEiqyiWlGGnf6usqULMCAaxpLBhLQLLonpughcKdc2uOtjb5wAyAaxpLBhLQLLonpughcecceccKdcASjTeW4EsvySOCneSoeKl9in0icbEjeimeS2PKdc8keO3WExYFPhece6gbU0oD8ClGRNYTJs1YsNMhkJFZBEJMRHPUXzC82oRLuPeRiE7MyfXBRvUEk3ocbeSS0P5HY4qGWjl0nFyhlnEXvKcDmK0nFOMfOYO(Y(CJm)yMODMtmI85U32znXkI3(CXvKhx2Te4LBhBN4Bwwr3MBUbllPnSAoGYBs(lLtupOkvHXIY1qqIqqJnPbC9uUDuQww608qzCPWufglkxdbYlpe4gSSK2WQ5akVj5Vuor9GQufglkxdbjcbn2KgW1t52rPAzPtZdLXLwLQWyr5AiqE5Ha3GLL0gwnhq5nj)LYjQhuLQWyr5AiiriOXM0aUEk3okvllDAEOmUuYPkmwuUgcKxEiWnyzjTHvZbuEtYFPCI6bvPkmwuUgcsecASjnGRNYTJs1YsNMhkJl5qPkmwuUgcKxEiWnyzjTHvZbuEtYFPCI6bvPkmwuUgcsecASjnGRNYTJs1YsNMhkJlrUufglkxdbYbbbC9uUDuQww608qzCDQEQmrqW6qq4ncCPD645McRnjnlORV5nVrZ1Wu34moEBN1sQuIveVDtSI4nFyTbbglORHaHdf6MpSJLgV4ksHogs6MpuZcuzuFzFUrMFmt0oZjgr(C3B7SMyfXBFUyYKUSBjWl3o2oX3SSIUn3IfVs3YdeKiHqqiPBe4s70XZToDbLMA7M38gnxdtDJZ44TDwlPsjwr82nXkI3wd6ccbYQniq4vcDZh2XsJxCfPqhdjDZhQzbQmQVSp3iZpMjAN5eJiFU7TDwtSI4Tpxm5Wl7wc8YTJTt8nlROBZTnf6usqULgM2PlO0uBqGCqqaxpLBhLQLLonpugxNQNkteeqieqccKdcIfVs3YdeKieqos3iWL2PJNBD6ckn12nV5nAUgM6gNXXB7SwsLsSI4TBIveVTg0fecKvBqGWjl0nFyhlnEXvKcDmK0nFOMfOYO(Y(CJm)yMODMtmI85U32znXkI3(CXKxDz3sGxUDSDIVrGlTthp3AQIYL0SG(nV5nAUgM6gNXXB7SwsLsSI4TBIveV5WufLdbglOdbchk0ncuc03Y(lkNWqYhLpOsfSnegEZh2XsJxCfPqhdjDZhQzbQmQVSp3iZpMjAN5eJiFU7TDwtSI4Tpxm5KVSBjWl3o2oX3SSIUn3IfVs3YdeKieqEjDJaxANoEU1PlO0uB3iZpMjAN5eJiFoX32zoPCbxm82oRLuPeRiE7MyfXBRbDbHaz1geiSdj0ncuc03ImNuUacdV5d7yPXlUIuOJHKU5d1Savg1x2NBEZB0Cnm1noJJ32znXkI3(CXKDOl7wc8YTJTt8nlROBZnfglkxdbjcbTavnughcipHaHHGKHaVcbdntK0qJiei0ncCPD645wjGX9CJm)yMODMtmI85eFBN5KYfCXWB7SwsLsSI4TBK5j3rzLsao6t8nXkI3iqaJ7bceozHUrGsG(wK5KYfqyi5l7j3rPPucWrty4nFyhlnEXvKcDmK0nFOMfOYO(Y(CZBEJMRHPUXzC82oRjwr82NlMm5USBjWl3o2oX3SSIUn3uySOCneKie0cu1qzCiG8ecegcsgc8kem0mrsdnIqGq3iWL2PJNBA6MFgxQtxWBK5hZeTZCIrKpN4B7mNuUGlgEBN1sQuIveVDJmp5okRucWrFIVjwr8Mr38Z4qWAqxqiq4vcDJaLa9TiZjLlGWqYx2tUJstPeGJMWWB(WowA8IRif6yiPB(qnlqLr9L95M38gnxdtDJZ44TDwtSI4Tpxm51(YULaVC7y7eFZYk62CtHXIY1qqIqqlqvdLXHaYtiqyiiziWRqWqZejn0icbcDJaxANoEULzkvW2qz8BK5hZeTZCIrKpN4B7mNuUGlgEBN1sQuIveVDJmp5okRucWrFIVjwr8gzmLkyBOmoei8kHUrGsG(wK5KYfqyi5l7j3rPPucWrty4nFyhlnEXvKcDmK0nFOMfOYO(Y(CZBEJMRHPUXzC82oRjwr82NlMSJx2Te4LBhBN4Be4s70XZToDbLMA7gz(Xmr7mNye5Zj(2oZjLl4IKUTZAjvkXkI3Ujwr82AqxqiqwTbbctoHUrGsG(wK5KYfqiPB(WowA8IRif6yiPB(qnlqLr9L95M38gnxdtDJZ44TDwtSI4TpFUjwr8MrJKbbeSS0P5HY4RjHGOGp)a]] )

    storeDefault( [[SimC Affliction: writhe]], 'actionLists', 20180107.172146, [[dG0r2aqiuu6skveztOiJIq1PiuwLqIxHIIzjKKULsfHDrjdJqoMszzsPEMusttPcxdfvBJGu(gPQgNqsCocs06uQOsZtI09ivzFkv6GkvTqc4HeOjQur5IseBKGeAKkvuXjfsntHK6MOWojXqjivTuHYtPAQKkxvPI0wLs8wLkQ6UeKG9c(lknyvoSIftspwWKLQlJSzj8zkLrtP60qETe1SL0TvYUr1VHA4sXXjiPLt0ZPy6IUoPSDHQVtqmEcsLZleRxPIOMpb1(v1WgOd8s4JAL6Gk4EdfqtfTtEseMdkTfAmh8DgvmA1eea8yuLgdbkTfTP)MOnrwTfT16g4EqIAsWbFFiryUb0bkBGoWlHpQvQdcaUhKOMeCM9pvTIcRonDHG4Dw7JmozssAP18ht)LOf93U)X8)y6pX)tvROWkXYfXtQZAWAvJLKMq(3U69hZ)tyH)lhPnkTs0IytmBhr)vQE)PQvuyLy5I4j1znyTQXssti)lk)j(Fm)pM5VnlM)xu(JeQAOMgQBjPPHD4Dwdwi)j2FmZFI)NQwrHvNMUqq8oR9rgNmjjTK0AqCZFr5pX)J5)Xm)TzX8)IYFKqvd10qDljnnSdVZAWc5pX(BN0FBT)lk)j(Fm)pM5VnlM)xu(JeQAOMgQBjPPHD4Dwdwi)j2FI9NyGVxfvrzeWL00WAWAvd4rZ7OWKyj4CmNaNbU3YivMfbo4kZIapgnn)5yTQb8yuLgdbkTfTP)MiWJrgSMmqgqhKGlODkuMbooTiEcQGZa3vMfboKGsBqh4LWh1k1bba3dsutcoZ(NQwrHvNMUqq8oR9rgNmjjT0A(JP)s0I(B3)y(Fm9N4)PQvuyzWAvw7JmozsljTge383U69N4)X8)yM)2Sy(Fr5psOQHAAOULKMg2H3znyH8Ny)X0FACtoQvIDkkQOqIWCJLjNq5)29VT)ew4)u1kkScyEal7dpqS4c20oXwjBimVyQvlTM)ew4)sjIxMsRgjoyH4jvRuiT0A(tyH)lLiEzkTm5ekJ42yBK4GfINuTsH0sR5pHf(VuI4LP0QrIdwRXKKmILwZFcl8FPeXltPLjNqze3gBJehSwJjjzelTM)ew4)sjIxMsRgjoyfKO0sR5pHf(VuI4LP0YKtOmIBJTrIdwbjkT0A(tyH)lLiEzkTAK4GvCsAMevrzelTM)ew4)sjIxMsltoHYiUn2gjoyfNKMjrvugXsR5pHf(VuI4LP0QrIdwMgQwzBWcHKwAn)jSW)LseVmLwMCcLrCBSnsCWY0q1kBdwiK0sR5pXaFVkQIYiGlPPH1G1QgWJM3rHjXsW5yobodCVLrQmlcCWvMfbEmAA(ZXAvZFIVjg4XOkngcuAlAt)nrGhJmynzGmGoibxq7uOmdCCAr8eubNbURmlcCibLwbDGxcFuRuheaCpirnj4sAniU5Vs17VefkZMOf9hZ8NTqh89QOkkJa(ydZJaE08okmjwcohZjWzG7TmsLzrGdUYSiW3BdZJaEmQsJHaL2I20Fte4XidwtgidOdsWf0ofkZahNwepbvWzG7kZIahsqzhGoWlHpQvQdcaoJrOdT0w6gPnknGZCW9Ge1KGNtL4PLbRvzTpY4KjTi(OwP(Fm9xaJRDSq4wgSwL1(iJtM0ssRbXn)v6FHXKSjAr)fL)eA)X0FsAniU5Vs17VUMCseM)xu(tKvR)X0F5iTrPvIweBIz7i6VD17pjTge38ht)LOfXMy2oI(B3)suOmBIw0Fr5VwbFVkQIYiGp2W8iGlODkuMbooTiEcQGZa3BzKkZIah8O5DuysSeCoMtGRmlc892W8i)j(MyGVxAZaEisOsS5iTrPrVTO6Ae6ydrcvInhPnkn6XCWJrvAmeO0w0M(BIapgzWAYazaDqcUGrcvs3iTrPbeaCg4UYSiWHeuyoOd8s4JAL6GaGZye6qlTLUrAJsd4TcUhKOMeCjTge38xP69xIcLzt0I(Jz(ZwO)ht)LOfXMy2oI(B3)suOmBIw0Fr5VwbFVkQIYiGp2W8iGlODkuMbooTiEcQGZa3BzKkZIah8O5DuysSeCoMtGRmlc892W8i)jEBXaFV0Mb8qKqLyZrAJsJEBr11i0XgIeQeBosBuA0RvWJrvAmeO0w0M(BIapgzWAYazaDqcUGrcvs3iTrPbeaCg4UYSiWHeueAGoWlHpQvQdcaUhKOMe8CQepTmyHWM2jwdrDJfXh1k1)JP)MqIItSeNwiY83U69xR)X0FgSwL1yFK9)07pMd(EvufLra3quNfxWgWsPwtIWCWJM3rHjXsW5yobodCVLrQmlcCWvMfbUtu)pCXFcILsTMeH5GhJQ0yiqPTOn93ebEmYG1KbYa6GeCbTtHYmWXPfXtqfCg4UYSiWHeu0h0bEj8rTsDqaW9Ge1KGBWAvwJ9r2)tV)y(Fcl8FI)xIweBIz7i6Vs17pX)t8)6AYjry(FmZFHXKSjAr)j2Fr5pdwRYASpY(FI9NyGVxfvrzeW14MCuRe7uuurHeH5GhnVJctILGZXCcCg4ElJuzwe4GRmlc8Dk3KJAL(BFrrffseMdEmQsJHaL2I20Fte4XidwtgidOdsWf0ofkZahNwepbvWzG7kZIahsqjQa6aVe(OwPoia4EqIAsWZrAJsReTi2eZ2r0FLQ3F2c9)IYFT)JP)myTkRX(i7)v6Fmh89QOkkJaExoioRbRvbxq7uOmdCCAr8eubNbU3YivMfbo4rZ7OWKyj4CmNaxzwe47m5G4)5yTk47L2mGhIeQeBosBuA0Bd8yuLgdbkTfTP)MiWJrgSMmqgqhKGlyKqL0nsBuAabaNbURmlcCibfHsqh4LWh1k1bba3dsutcEovINw0QblessD2kQGyZPXI4JAL6)X0FQAffw0QblessD2kQGyZPXssRbXn)vQE)zl0bFVkQIYiGxrfeBonGhnVJctILGZXCcCg4ElJuzwe4GRmlc8Ogvq)PBAapgvPXqGsBrB6Vjc8yKbRjdKb0bj4cANcLzGJtlINGk4mWDLzrGdjOSjc0bEj8rTsDqaW9Ge1KG3XPvalLAnjcZTK0AqCZFm9xhNwJnmpILKwdIBaFVkQIYiGB0wlmNTGQ214jjbpAEhfMelbNJ5e4mW9wgPYSiWbxzwe4U2AH5)juKQ214jjbpgvPXqGsBrB6Vjc8yKbRjdKb0bj4cANcLzGJtlINGk4mWDLzrGdjOSTb6aVe(OwPoia4EqIAsWz2)YPs80YMeTWijXIlynAnsAnHiweFuRu)pM(BcjkoXsCAHiZFLQ3FT)JP)e)VCK2O0krlInXSDe93U)Tfve9NWc)xosBuAzNMAA3QjK)vQE)1w0Fcl8F5iTrPvIweBIz7i6Vs)Rvr)jg47vrvugbCJ2AH5SDmEztBKDWJM3rHjXsW5yobodCVLrQmlcCWvMfbURTwy(F7mmEztBKDWJrvAmeO0w0M(BIapgzWAYazaDqcUG2Pqzg440I4jOcodCxzwe4qckBTbDGxcFuRuheaCpirnj4m7F5ujEAztIwyKKyXfSgTgjTMqelIpQvQ)ht)nHefNyjoTqK5VD)Rn47vrvugbCJ2AH5SiEbj5tf8O5DuysSeCoMtGZa3BzKkZIahCLzrG7ARfM)x08csYNk4XOkngcuAlAt)nrGhJmynzGmGoibxq7uOmdCCAr8eubNbURmlcCibLTwbDGxcFuRuheaCpirnj45ujEAztIwyKKyXfSgTgjTMqelIpQvQ)ht)nHefNyjoTqK5p9(B7pM(JeQAOMgQBzq8owsiwtdkP)y6pM9Vagx7yHWTmiEhljeRPbLelk0TK0AqCZF7(NiW3RIQOmc4gT1cZz7y8YM2i7GhnVJctILGZXCcCg4ElJuzwe4GRmlcCxBTW8)2zy8YM2i7)j(MyGhJQ0yiqPTOn93ebEmYG1KbYa6GeCbTtHYmWXPfXtqfCg4UYSiWHeu22bOd8s4JAL6GaG7bjQjbpNkXtlBs0cJKelUG1O1iP1eIyr8rTs9)y6VjKO4elXPfIm)T7FB)X0FKqvd10qDldI3XscXAAqj9ht)XS)fW4AhleULbX7yjHynnOKyrHULKwdIB(B3)eb(EvufLra3OTwyolIxqs(ubpAEhfMelbNJ5e4mW9wgPYSiWbxzwe4U2AH5)fnVGK8P(N4BIbEmQsJHaL2I20Fte4XidwtgidOdsWf0ofkZahNwepbvWzG7kZIahsqzJ5GoWlHpQvQdcaUhKOMe8gjfN1wOBTzPXn5Owj2POOIcjcZ)tyH)tvROWYG1QS2hzCYKwsAniU5VD17VnrGVxfvrzeWvjPHKLrCBGhnVJctILGZXCcCg4ElJuzwe4GRmlcCbiPHKLrCBGhJQ0yiqPTOn93ebEmYG1KbYa6GeCbTtHYmWXPfXtqfCg4UYSiWHeu2eAGoWlHpQvQdca(EvufLraxTIXD2cnzeWJM3rHjXsW5yobodCVLrQmlcCWvMfbUavmU)NqrnzeWJrvAmeO0w0M(BIapgzWAYazaDqcUG2Pqzg440I4jOcodCxzwe4qckB6d6aVe(OwPoia4EqIAsWv1kkSmyTkR9rgNmPLKwdIB(Ru9(lQ8ht)nHefNyjoTqK5VD)B7pM(t8)04MCuRe7uuurHeH5gltoHY)TRE)1(pHf(VjKO4elXPfIm)T7FT(Ny)X0FI)hZ(xovINwDAs7gwAPkNazr8rTs9)ew4)s0IytmBhr)T7FBTf9NWc)xIweBIz7i6Vs)Rvr)jg47vrvugbCdwRYAFKXjtcE08okmjwcohZjWzG7TmsLzrGdUYSiWDSw9VDoJmozsWJrvAmeO0w0M(BIapgzWAYazaDqcUG2Pqzg440I4jOcodCxzwe4qckBrfqh4LWh1k1bba3dsutcEosBuALOfXMy2oI(Ru9(tFrGVxfvrzeWBWjcZbpAEhfMelbNJ5e4mW9wgPYSiWbxzwe4chkkejkekk25f6XjcZfkiSe8yuLgdbkTfTP)MiWJrgSMmqgqhKGlODkuMbooTiEcQGZa3vMfboKGYMqjOd8s4JAL6GaG7bjQjbx8)y2)YPs80YG1QS2hzCYKweFuRu)pHf(pvTIcldwRYAFKXjtAjP1G4M)29VT2)j2Fm9N4)LseVmLwnsCWA4rS0A(tyH)lLiEzkTm5ekZ2iXbRHhXsR5pHf(pnUjh1kXoffvuiryUXYKtO8F7Q3FT)tmW3RIQOmc4n4eH5GhnVJctILGZXCcCg4ElJuzwe4GRmlcCHdffIefcff78c94eH5cfew(N4BIbEmQsJHaL2I20Fte4XidwtgidOdsWf0ofkZahNwepbvWzG7kZIahsqPTiqh4LWh1k1bba3dsutcUKwdIB(Ru9(lrHYSjAr)Xm)zl0)JP)s0IytmBhr)T7FjkuMnrl6VO8xBW3RIQOmc4guJDmNTIkiWf0ofkZahNwepbvWzG7TmsLzrGdE08okmjwcohZjWvMfbUJASJ5)f1Occ89sBgWdrcvInhPnkn6TbEmQsJHaL2I20Fte4XidwtgidOdsWfmsOs6gPnknGaGZa3vMfboKGs7nqh4LWh1k1bba3dsutcUKwdIB(Ru9(lrHYSjAr)Xm)zl0)JP)e)pX)BcjkoXsCAHiZFL(xR)X0F5ujEAzWcHnTtSgI6glIpQvQ)Ny)jSW)nHefNyjoTqK5Vs)J5)j2Fm9xIweBIz7i6VD)lrHYSjAr)fL)Ad(EvufLrapGLsTMeH5GlODkuMbooTiEcQGZa3BzKkZIah8O5DuysSeCoMtGRmlcCbXsPwtIWCW3lTzapejuj2CK2O0O3g4XOkngcuAlAt)nrGhJmynzGmGoibxWiHkPBK2O0acaodCxzwe4qckTBd6aVe(OwPoia4EqIAsWxdFSAc5FL(3oe9ht)j(FACtoQvIDkkQOqIWCJLjNq5)k9VT)ew4)y2)u1kkS600fcI3zTpY4KjjPLwZFIb(EvufLraVIki2CAapAEhfMelbNJ5e4mW9wgPYSiWbxzwe4rnQG(t308N4BIbEmQsJHaL2I20Fte4XidwtgidOdsWf0ofkZahNwepbvWzG7kZIahsqPDRGoWlHpQvQdcaUhKOMeCX)tvROWQttxiiEN1(iJtMKKwsAniU5pM5pvTIcRelxepPoRbRvnwsAc5Fr5pX)J5)Xm)rcvnutd1TK00Wo8oRblK)e7pX(Bx9(t8)2A)xu(t8)y(FmZFBwm)VO8hju1qnnu3sstd7W7SgSq(tS)ed89QOkkJaUKMgwdwRAapAEhfMelbNJ5e4mW9wgPYSiWbxzwe4XOP5phRvn)jEBXapgvPXqGsBrB6Vjc8yKbRjdKb0bj4cANcLzGJtlINGk4mWDLzrGdjO0EhGoWlHpQvQdca(EvufLraVX(Wt8I1G420QJeLrapAEhfMelbNJ5e4mW9wgPYSiWbxzwe4c92hEIx)5iUnT6irzeWJrvAmeO0w0M(BIapgzWAYazaDqcUG2Pqzg440I4jOcodCxzwe4qckTzoOd8s4JAL6GaG7bjQjbx8)YPs80YGfcBANyne1nweFuRu)pM(BcjkoXsCAHiZF7Q3FT(Ny)jSW)j(FtirXjwItlez(B3)A9pM(RJtRawk1AseMBjPcjzSpQv6pXaFVkQIYiGBiQZIlydyPuRjryo4rZ7OWKyj4CmNaNbU3YivMfbo4kZIa3jQ)hU4pbXsPwtIW8)eFtmWJrvAmeO0w0M(BIapgzWAYazaDqcUG2Pqzg440I4jOcodCxzwe4qckTfAGoWlHpQvQdcaUhKOMe8CQepTcyEo2qyUfXh1k1)JP)640sJBYrTsStrrffseMZUzjP1G4M)k9VWys2eTO)y6VooT04MCuRe7uuurHeH5STTK0AqCZFL(xymjBIw0Fm9xhNwACtoQvIDkkQOqIWC2wTK0AqCZFL(xymjBIw0Fm9xhNwACtoQvIDkkQOqIWC2DyjP1G4M)k9VWys2eTO)y6VooT04MCuRe7uuurHeH5Sm3ssRbXn)v6FHXKSjArGVxfvrzeW14MCuRe7uuurHeH5GhnVJctILGZXCcCg4ElJuzwe4GRmlc8Dk3KJAL(BFrrffseM)N4BIbEmQsJHaL2I20Fte4XidwtgidOdsWf0ofkZahNwepbvWzG7kZIahsqPT(GoWlHpQvQdcaUhKOMe8CQepTgvdUQLeBalLAnjcZTi(OwP(Fm9NHswvmxZyLis2EJDhnH)29pr)X0FDsvROWkXYfXtQZo2W8iwsAniU5Vs17VWys2eTiW3RIQOmc4ACtoQvIDkkQOqIWCWJM3rHjXsW5yobodCVLrQmlcCWvMfb(oLBYrTs)TVOOIcjcZ)t82IbEmQsJHaL2I20Fte4XidwtgidOdsWf0ofkZahNwepbvWzG7kZIahsqPDub0bEj8rTsDqaW9Ge1KGRQvuy1PPleeVZAFKXjtssljTge383U69xxtojcZ)Jz(lmMKnrl6pM(RJtlnUjh1kXoffvuiryo7MLKwdIB(R0)cJjzt0I(JP)640sJBYrTsStrrffseMZ22ssRbXn)v6FHXKSjAr)X0FDCAPXn5Owj2POOIcjcZzB1ssRbXn)v6FHXKSjAr)X0FDCAPXn5Owj2POOIcjcZz3HLKwdIB(R0)cJjzt0I(JP)640sJBYrTsStrrffseMZYCljTge38xP)fgtYMOfb(EvufLraxJBYrTsStrrffseMdUG2Pqzg440I4jOcodCVLrQmlcCWJM3rHjXsW5yobUYSiW3PCtoQv6V9ffvuiry(FI3QyGVxAZaEisOsS5iTrPrVTOAosBuYIk0tvROWQttxiiEN1(iJtMKKwsAniUzx96AYjryoZegtYMOfXuhNwACtoQvIDkkQOqIWC2nljTge3uAymjBIwetDCAPXn5Owj2POOIcjcZzBBjP1G4MsdJjzt0IyQJtlnUjh1kXoffvuiryoBRwsAniUP0Wys2eTiM640sJBYrTsStrrffseMZUdljTge3uAymjBIwetDCAPXn5Owj2POOIcjcZzzULKwdIBknmMKnrlc8yuLgdbkTfTP)MiWJrgSMmqgqhKGlyKqL0nsBuAabaNbURmlcCibL2cLGoWlHpQvQdcaUhKOMeCvTIcRonDHG4Dw7JmozssAjP1G4M)29VefkZMOf9xu(R9Fm9N4)XS)zOKvfZ1mwjIKT3y3rt4VD)t0Fcl8F5ujEAfW8CSHWClIpQvQ)NWc)NbRvzn2hz)VD)B7pX(JP)e)pM9VCQepTcyEo2qyUfXh1k1)tyH)ZG1QSg7JS)3U)T9NWc)NQwrHLbRvzTpY4KjT0A(tS)y6pX)RJtlnUjh1kXoffvuiryo7MvIcLrCB)Xm)1XPLg3KJALyNIIkkKimNTTvIcLrCB)Xm)1XPLg3KJALyNIIkkKimNTvRefkJ42(Jz(RJtlnUjh1kXoffvuiryo7oSsuOmIB7pM5VooT04MCuRe7uuurHeH5Sm3krHYiUT)k9pM)NyGVxfvrzeW14MCuRe7uuurHeH5GhnVJctILGZXCcCg4ElJuzwe4GRmlc8Dk3KJAL(BFrrffseM)N47qmWJrvAmeO0w0M(BIapgzWAYazaDqcUG2Pqzg440I4jOcodCxzwe4qckTkc0bEj8rTsDqaW9Ge1KGZS)PQvuy1PPleeVZAFKXjtsslTM)y6pnUjh1kXoffvuiryUXYKtO8F7(3g47vrvugbCjnnSgSw1aE08okmjwcohZjWzG7TmsLzrGdUYSiWJrtZFowRA(t8wfd8yuLgdbkTfTP)MiWJrgSMmqgqhKGlODkuMbooTiEcQGZa3vMfboKGsRBGoWlHpQvQdcaUhKOMeCM9pvTIcRonDHG4Dw7JmozssAP18ht)1iP4S2cDRnlnUjh1kXoffvuiry(Fm9NQwrHvILlINuN1G1QgljnH8VD)Bd89QOkkJaUKMgwdwRAapAEhfMelbNJ5e4mW9wgPYSiWbxzwe4XOP5phRvn)j(oed8yuLgdbkTfTP)MiWJrgSMmqgqhKGlODkuMbooTiEcQGZa3vMfboKGsRTbDGxcFuRuheaCpirnj45ujEArRgSqij1zROcInNglIpQvQ)ht)PQvuyrRgSqij1zROcInNgljTge38xP)11KtIW8)IYFISA9pM(t8)y2)u1kkS600fcI3zTpY4KjjPLwZFcl8FACtoQvIDkkQOqIWCJLjNq5)k9VT)ed89QOkkJaEfvqS50aE08okmjwcohZjWzG7TmsLzrGdUYSiWJAub9NUP5pXBlg4XOkngcuAlAt)nrGhJmynzGmGoibxq7uOmdCCAr8eubNbURmlcCibLwBf0bEj8rTsDqaW9Ge1KGlPcjzSpQv6pM(lrlInXSDe93U69NKwdIBaFVkQIYiGp2W8iGhnVJctILGZXCcCg4ElJuzwe4GRmlc892W8i)jERIbEmQsJHaL2I20Fte4XidwtgidOdsWf0ofkZahNwepbvWzG7kZIahsqP1Da6aVe(OwPoia4EqIAsWLuHKm2h1k9ht)LOfXMy2oI(Bx9(tsRbXnGVxfvrzeWnOg7yoBfvqGhnVJctILGZXCcCg4ElJuzwe4GRmlcCh1yhZ)lQrf0FIVjg4XOkngcuAlAt)nrGhJmynzGmGoibxq7uOmdCCAr8eubNbURmlcCibLwzoOd8s4JAL6GaG7bjQjbxsfsYyFuR0Fm9xIweBIz7i6VD17pjTge3a(EvufLrapGLsTMeH5GhnVJctILGZXCcCg4ElJuzwe4GRmlcCbXsPwtIW8)eFtmWJrvAmeO0w0M(BIapgzWAYazaDqcUG2Pqzg440I4jOcodCxzwe4qckTk0aDGxcFuRuheaCpirnj4jArSjMTJO)29VefkZMOf9xu(R1)y6pM9pvTIcRonDHG4Dw7JmozssAP18ht)jPcjzSpQvc89QOkkJa(ydZJaUG2Pqzg440I4jOcodCVLrQmlcCWJM3rHjXsW5yobUYSiW3BdZJ8N47qmW3lTzapejuj2CK2O0O3g4XOkngcuAlAt)nrGhJmynzGmGoibxWiHkPBK2O0acaodCxzwe4qckTQpOd8s4JAL6GaG7bjQjbprlInXSDe93U)LOqz2eTO)IYFT(ht)XS)PQvuy1PPleeVZAFKXjtsslTM)y6pjvijJ9rTsGVxfvrzeWnOg7yoBfvqGlODkuMbooTiEcQGZa3BzKkZIah8O5DuysSeCoMtGRmlcCh1yhZ)lQrf0FI3wmW3lTzapejuj2CK2O0O3g4XOkngcuAlAt)nrGhJmynzGmGoibxWiHkPBK2O0acaodCxzwe4qckTgvaDGxcFuRuheaCpirnj4jArSjMTJO)29VefkZMOf9xu(R1)y6pM9pvTIcRonDHG4Dw7JmozssAP18ht)jPcjzSpQvc89QOkkJaEalLAnjcZbxq7uOmdCCAr8eubNbU3YivMfbo4rZ7OWKyj4CmNaxzwe4cILsTMeH5)jEBXaFV0Mb8qKqLyZrAJsJEBGhJQ0yiqPTOn93ebEmYG1KbYa6GeCbJeQKUrAJsdia4mWDLzrGdjO0QqjOd8s4JAL6GaG7bjQjbFn8XQjK)vQE)Tjc89QOkkJaEfvqS50aE08okmjwcohZjWzG7TmsLzrGdUYSiWJAub9NUP5pXBvmWJrvAmeO0w0M(BIapgzWAYazaDqcUG2Pqzg440I4jOcodCxzwe4qck7qeOd8s4JAL6GaG7bjQjbVrsXzTf6wBwvubXMtZFm9Ng3KJALyNIIkkKim3yzYju(p9(t0Fm93A4Jvti)R0)yUiW3RIQOmc4vubXMtd4rZ7OWKyj4CmNaNbU3YivMfbo4kZIapQrf0F6MM)eFhIbEmQsJHaL2I20Fte4XidwtgidOdsWf0ofkZahNwepbvWzG7kZIahsqzhBGoWlHpQvQdca(EvufLraVlheN1G1QGhnVJctILGZXCcCg4ElJuzwe4GRmlc8DMCq8)CSw9pX3ed89sBgWd2hexVTOkINKuQ1K6TbEmQsJHaL2I20Fte4XidwtgidOdsWf0ofkZahNwepbvWzG7kZIahsqzhTbDGxcFuRuheaCpirnj4RHpwnH8Vs)lQic89QOkkJaEfvqS50aUG2Pqzg440I4jia4mWXrCBGYg4mW9wgPYSiWbxzwe4rnQG(t308N4mxmW3lTzaFHJJ420Bd8yuLgdbkTfTP)MiWJrgSMmqgqhKGhnVJctILGZXCcCg4UYSiWHeu2rRGoWlHpQvQdcaUhKOMeCjTge38xP69xxtojcZ)BN4pX)R1)IYFjkuMnrl6pXaFVkQIYiGp2W8iGlODkuMbooTiEccaodCCe3gOSbodCVLrQmlcCWfmsOs6gPnknGaGRmlc892W8i)joZfd89sBgWx44iUn92IQHiHkXMJ0gLg92apgvPXqGsBrB6Vjc8yKbRjdKb0bj4rZ7OWKyj4CmNaNbURmlcCibLDSdqh4LWh1k1bba3dsutcUKwdIB(Ru9(RRjNeH5)Tt8N4)16Fr5VefkZMOf9NyGVxfvrzeWnOg7yoBfvqGlODkuMbooTiEccaodCCe3gOSbodCVLrQmlcCWfmsOs6gPnknGaGRmlcCh1yhZ)lQrf0FI3QyGVxAZa(chhXTP3wunejuj2CK2O0O3g4XOkngcuAlAt)nrGhJmynzGmGoibpAEhfMelbNJ5e4mWDLzrGdjOSdMd6aVe(OwPoia4EqIAsWL0AqCZFLQ3FDn5Kim)VDI)e)Vw)lk)LOqz2eTO)ed89QOkkJaEalLAnjcZbxq7uOmdCCAr8eeaCg44iUnqzdCg4ElJuzwe4GlyKqL0nsBuAabaxzwe4cILsTMeH5)jERIb(EPnd4lCCe3MEBr1qKqLyZrAJsJEBGhJQ0yiqPTOn93ebEmYG1KbYa6Ge8O5DuysSeCoMtGZa3vMfboKGYoeAGoWlHpQvQdca(EvufLraVIki2CAaxq7uOmdCCAr8eeaCg44iUnqre4mW9wgPYSiWbxzwe4rnQG(t308N4cnXaFV0Mb8fooIBtprGhJQ0yiqPTOn93ebEmYG1KbYa6Ge8O5DuysSeCoMtGZa3vMfboKqcUYSiWD0sW)2xuurHeH57C)tisuANGea]] )


    storeDefault( [[Affliction Primary]], 'displays', 20180107.172146, [[dSJ4gaGEf4LKc2LQKQTPkPmtvjMTuDtuHoSKBROETuKDsP9k2nH9tu9tfzyQIXPkv6zQsvdfvnyIYWr0bjPpJGJrvDCurlukTusrlMelNkpuk8uWJHQ1HqXevLKPcLjJknDLUOcDveQUmKRJuBKuARKc1MvvBhj(OuuNgLPrkKVtvgjQGLPGgnrgpc5KiPBHqPRPkLZtQEofRvvQ43QC8dwa8ICzNq7jwy17Oateh7fQ2XaB5iGwEk8rjGReeqnKq4nL2aCsJOrQDgbXmsSbWdOp9)g02Oix2jmX(eGOP)3G2gf5YoHj2NaKo2C50PIFcGnaf7BpbMzc1XyFFaoPr0iUnkYLDctAdOp9)g0IvocO1e7taJ05bESfxsDmTbmsNNk9EPnGr68ap2IlPsVxAdSLJaAvf4sNlq7eg2eh1KAZCalGESe7q)Naef7taJ05HvocO1K2anPOkWLoxaSjEnP2mhWcWeCz41EovbU05cOj1M5awa8ICzNqvGlDUaTtyytCmqJJuxUmSlG6)3z4l7eYLPongWiDEawAdWjnIg9kMdHVSteqtQnZbSac6zQ4NWeRgfWqI6DT9Yi146NlybQy9d4I1paHy9dOeRF2agPZRrrUStyIsaIM(FdAvPDvSpbkAxHPtIcOq))bMlIuP3l2NakD2Gbn3pp1EpkbQoPubsNhpLXy9duDsPQXnRulpLXy9d8k0VO7BAduDVs3WtHpTbOWmmfwNT6y6KOakbWlYLDc1oJGiqJrl2OMb4YmK9shtNefGBaxjiGW0jrbkfwNT6bkAxXrMaL2anPO9elWgGI1FyGQtkvyLJaA5PWhRFahQhOXOfBuZagsuVRTxgPOeO6Ksfw5iGwEkJX6hGtAenIlvbxgETNZK2aajcNvD2GAzNi2HV2Bb4I(fDFv5FjaWMBixM6)3z4l7eeJCzCr)IUVb2YraTApXcREhfyI4yVq1ogyMjuP3l2Na6t)VbTAO1elX6hGOP)3Gwn0AI1pq1jLk1UxPB4PWhRFGQtkvG05XtHpw)aKo2C501EIfydqX6pmaPdHFZk1QY)saGn3qUm1)VZWx2jig5YiDi8BwP2aZfrawS(bMlIuhJ9jGr684PWN2aB5iGwEkJrjGMOoQmOyh(4)Up(pA0Rp03F47FlGr680asxHj4YeemPna(nRulpLXOeaVix2j0EIfydqX6pmq1jLk1UxPB4PmgRFGMu0EInapMCzqjmYLzlN78cOp9)g0Qs7QyFcyKopQcUm8ApNjTbmsNNkTROk(xucuDVs3WtzmTbmsNN6yAdyKopEkJPna(nRulpf(OeO6KsvJBwPwEk8X6hOODLQax6CbANWWM44lJAXcu0UIQ4Fy6KOak0)FGzMaWI9jWwocOv7jwGnafR)WaCsZWBsJzgy17Oava8ICzNq7j2a8yYLbLWixMTCUZlqr7kGe17uFvSpbgfLshXnTbmSzYosDAm2HbiA6)nOfRCeqRj2NaB5iGwTNydWJjxgucJCz2Y5oVa6t)VbTufCz41EotSpbiA6)nOLQGldV2ZzI9jGsNnyqZ9Zlkb4KgrJ4sf)eaBak23Ec8pXgGhtUmOeg5YSLZDEby4NailCMGqSVfGHFI35U5yh(eGtAenIR2tSaBakw)HbAsr7jwy17Oateh7fQ2XaCsJOrC1qRjTbS1mkG6)3z4l7eYLX7yZLtpqr7kIlyBaYEPJCzta]] )

    storeDefault( [[Affliction AOE]], 'displays', 20180107.172146, [[dWt4gaGEjQxsKYUisvVwrXmLinBj9yO6MeHUTQ4BebnnfLStkTxXUjSFsXpvOHPk9BvEofdLOgmjmCeDqs60O6yKQZreyHkYsPsSyuSCQ6HuPEkyzkQwhcKjsLKPcLjtIMUsxubxLiYLHCDKAJKsBvrPSzv12rIpkrSneO(mc9DjmsIOEgrQmAuA8iOtIKUfvsDneW5PIdl1AvuQoorYrpybWBYLFcTNyH1PIcmkjSsPAhcG3Kl)eApXc8YOy1NhW3cIi3Si8zYuaPOr0i1kNO4bj2a4bCg)FdAD3Kl)eMyFdq44)BqR7MC5NWe7Basp)P9ouXpbWlJIDwVbE4c1HyLUasrJOrkD3Kl)eMmfWz8)nOfR9erRj23ag2Rak4loR6qycyyVcv69ctad7vaf8fNvLEVmfyBpr0QkWzpFGPrmSrj6c1sKmwach)FdAL2Kjw9aoJ)VbTsBYeRR1dyyVcS2teTMmfyggvbo75dGnk7c1sKmwaUqjhV3ZRkWzpFaxOwIKXcG3Kl)eQcC2ZhyAedBuIbCFKoAuGDbu))khF5NqJc1XHag2RaWYuaPOr0ixX9i8LFIaUqTejJfqq)qf)eMy1dyir1Q2AByDF1ZhSaDS6byIvpaXy1d4JvpBad7v4Ujx(jmHjaHJ)VbTQ0(o23anTVXCirbyO))apnHQ07f7BaMkVC5sQxHATgMaDLKTb2RqMYqS6b6kjB7(Ey6vMYqS6bCf6301ntb6Ar7yKPiNPau4godVYxhmhsuaMa4n5YpHALtueW9GfBWLak5gYA7G5qIcGhW3cIimhsuGMHx5RtGM23sKlqzkWmmApXc8YOy1NhORKSnw7jIwzkYXQhWJQbCpyXgCjGHevRARTHnmb6kjBJ1EIOvMYqS6bKIgrJusvOKJ375nzkaqIW5DLxUx(jIDobtGa2(bfq9)RC8LFcnkuhhcSTNiA1EIfwNkkWOKWkLQDiWdxOsVxSVbMHr7jwyDQOaJscRuQ2HaoX6656Vb6kjBRwlAhJmf5y1dWXpXSF3tS6eiaPN)0EhTNybEzuS6Zdq6r43dtVQYLga4pU1Oq9)RC8LFccsJcspc)Ey6nah)eazJZfeJLabEAcvhI9nW)eBazmnkGwy0OW2E)veyBpr0ktzimbKIgrJusf)eaVmk2z9gWWEfYuKZuaMkVC5sQxrycq44)BqlvHsoEVN3e7BaNX)3GwQcLC8EpVj23aB7jIwTNydiJPrb0cJgf227VIaeo()g0I1EIO1e7Bad7vqvOKJ375nzkGH9kuP9nvX)ctGUw0ogzkdzkGH9kKPmKPag2RqDimbWVhMELPihManTVbsuTs1vX(gOP9TQaN98bMgXWgLyPdAXcifnhFMzJBG1PIcWe4HlaSyFdSTNiA1EIf4LrXQppqt7BQI)H5qIcWq))bWBYLFcTNydiJPrb0cJgf227VIaDLKTDFpm9ktrow9adIMPIuMPag(dzfPooe78aoJ)VbTQ0(o23aZWO9eBazmnkGwy0OW2E)veORKSTATODmYugIvpW2EIOvMICycGFpm9ktzimbmSxH0qomCHsUGOjtbCbvrTbf78xDjuF(Rei9VsabKWzrWbEAcbSy1d0vs2gyVczkYXQhqkAensP2tSaVmkw95bimwxRlDeiGu0iAKsPnzYuaLOFtxxv5sda8h3AuO()vo(YpbbPrHs0VPRBGM23ssW3aK12b5ZMa]] )



end
