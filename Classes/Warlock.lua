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
        addAura( "empowered_life_tap", 235156, "duration", 20 )
        addAura( "enslave_demon", 1098, "duration", 300 )
        addAura( "eye_of_kilrogg", 126, "duration", 45 )
        addAura( "mastery_potent_afflictions", 77215 )
        addAura( "phantom_singularity", 205179, "duration", 16 )
            modifyAura( "phantom_singularity", "duration", function( x )
                return x * haste
            end )

        addAura( "ritual_of_summoning", 698 )
        addAura( "seed_of_corruption", 27243, "duration", 18 )
        addAura( "siphon_life", 63106, "duration", 15 )
        addAura( "soul_effigy", 205178, "duration", 600 )
        addAura( "soul_leech", 108370 )
        addAura( "soulstone", 20707, "duration", 900 )
        addAura( "tormented_souls", 216695, "duration", 3600, "max_stack", 12 )
        addAura( "unending_resolve", 104773, "duration", 8 )
        addAura( "unending_breath", 5697, "duration", 600 )
        addAura( "unstable_affliction", 233490, "duration", 8, "tick_time", 2 )        
            modifyAura( "unstable_affliction", "duration", function( x ) return x * haste end )
            modifyAura( "unstable_affliction", "tick_time", function( x ) return x * haste end )
            class.auras[ 233496 ] = class.auras.unstable_affliction
            class.auras[ 233497 ] = class.auras.unstable_affliction
            class.auras[ 233498 ] = class.auras.unstable_affliction
            class.auras[ 233499 ] = class.auras.unstable_affliction
            -- May need to use similar logic to Bloodlust.

        local afflictions = {
            [233490] = true,
            [233496] = true,
            [233497] = true,
            [233498] = true,
            [233499] = true
        }

        registerCustomVariable( 'unstable_afflictions', 
            setmetatable( {
                apps = { {}, {}, {}, {}, {} }
            }, { __index = function( t, k )
                if k == 'count' or k == 'actual' or k == 'current' or k == 'stack' then
                    local ct = 0
                    for i = 1, 5 do
                        if t.apps[i].start <= state.query_time and t.apps[i].expires >= state.query_time then
                            ct = ct + 1
                        end
                    end
                    return ct
                end
            end
        } ) )

        local function s( a, b )
            return a.start > 0 and ( a.expires > b.expires )
        end

        addHook( 'reset_precast', function ()

            local apps = state.unstable_afflictions.apps

            for i, app in ipairs( apps ) do
                app.start = 0
                app.expires = 0
            end

            if state.spec.affliction then 
                local i = 1
                local n = 0

                while( true ) do
                    local name, _, _, _, _, duration, expires, caster, _, _, spellID = UnitDebuff( "target", i, "PLAYER" )

                    if not name then break end

                    if afflictions[ spellID ] then
                        n = n + 1
                        apps[ n ].start = expires - duration
                        apps[ n ].expires = expires
                    end
                    i = i + 1
                end

                table.sort( apps, s )
            end

            state.soul_shards.actual = nil

        end )

        function state.applyUnstableAffliction( duration )
            local uas = state.unstable_afflictions

            if state.debuff.unstable_affliction.down then
                state.applyDebuff( 'target', 'unstable_affliction', 6 * state.haste )
                uas.apps[1].start = state.query_time
                uas.apps[1].expires = state.query_time + ( 6 * state.haste )

            else
                local index = min( 5, uas.stack + 1 )
                local app = uas.apps[ index ]

                app.start = state.query_time
                app.expires = state.query_time + ( 6 * state.haste )

                table.sort( uas.apps, s )
            end
        end


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
            cast = 1.5,
            channeled = true,
            gcdType = "spell",
            cooldown = 0,
            min_range = 0,
            max_range = 40,
        } )

        modifyAbility( "drain_soul", "cast", function( x ) return x * haste end )        

        addHandler( "drain_soul", function ()
            applyDebuff( "target", "drain_soul", 6 * haste )
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
            aura = 'empowered_life_tap'
        } )

        addHandler( "life_tap", function ()
            gain( mana.max * 0.3, "mana" )
            gain( health.max * -0.1, "health" )
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
            toggle = 'artifact'
        } )

        addHandler( "reap_souls", function ()
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
        } )

        modifyAbility( "unstable_affliction", "cast", function( x ) return x * haste end )

        addHandler( "unstable_affliction", function ()
            applyUnstableAffliction( 6 * haste )
            -- applyDebuff( "target", "unstable_affliction", 8 * haste, min( 5, debuff.unstable_affliction.stack + 1 ) )
        end )
    end


    storeDefault( [[SimC Affliction: default]], 'actionLists', 20171010.201310, [[dmZIdaGEvu1UiL2MkkntHuZg4MGYTfzNiAVk7wQ9RkJcvOHHGFJYGvPHRcDqK6uOcoMqTqvGLsQSybTCqEOO8uOLrQ65QQPskMmsMovxevQltCDH4XKSvvqBgvTDrvDyjFdvYNfOVlQ05rfDAkJgu9ArfNuizDc4AQO4EIQ8xeArQiptfvEXtZqU7keiulCizLKHOLYExAEEGPCJ1bExkHVIa8H6eGuFzK6jeZvmHycAJhIhfLva78LBSEK6p7zgsRCJ1)PzKXtZqU7keiu7GHOcYo6d9ciTRnvaH3uedcv)JALUcbc1q6qdyoNdvfaqSuUXAIa77dZGlQCGXYxss7lCimg1HfezLKHdjRKmmRaG3Lw5gRF3OTVpKgk4FyxjjVtOLYExAEEGPCJ1bE3uWtd1jaP(Yi1tiMRycd1jFweiL8NM5dJQPmv5mOHnRLHWyuKvsgIwk7DP55bMYnwh4DtbNps9tZqU7keiu7GHOcYo6d9ciTRnxiZHleTMyfK1CQv6keiudPdnG5CouvaaXs5gRjcSVpmdUOYbglFjjTVWHWyuhwqKvsgoKSsYWScaExALBS(DJ2((7YXyomKgk4FyxjjVtOLYExAEEGPCJ1bE3CHmhUCAOobi1xgPEcXCftyOo5ZIaPK)0mFyunLPkNbnSzTmegJISsYq0szVlnppWuUX6aVBUqMdxMpYZnnd5URqGqTdgIki7Op0lG0Uw4vK21kDfceQH0HgWCohQkaGyPCJ1eb23hMbxu5aJLVKK2x4qymQdliYkjdhswjzywbaVlTYnw)UrBF)D5OEomKgk4FyxjjVtOLYExAEEGPCJ1bEx4vK2pnuNaK6lJupHyUIjmuN8zrGuYFAMpmQMYuLZGg2SwgcJrrwjziAPS3LMNhyk3yDG3fEfP95ZhIki7OpC(g]] )

    storeDefault( [[SimC Affliction: precombat]], 'actionLists', 20171010.201310, [[dGd6eaGEjQ0MiPSlj12KiX(ukyMsK0SP0nvs3gv7es7vSBvTFOAusKQHPe)wXqLOWGrXWPWbvQ6usuXXOOfkrSusYIjXYj6HOKEkYYKephIjkrktfknzPmDvUikLhlvxgCDjCyQ2kjvBMu2ou06ukQZljnnjk13vk0Pj8AOWOrP6BOeNuP0FjvxtIQUNsr(SsLNjrjhsIIoMbBi2ExXcTOec15qisWzfNzVMMv0pX8BgNXqc9HR4xivGfCeiOvwmzXCXCP2mezaDHBfLRFI5dALsP8H23pX8ibBqnd2qS9UIfAPKquxkmUqNBH)Q3jf8rib9rthPWqcCVxTgExXcnCg1WzC5j08(vBhztF001SohqQL(JboZgWzwcTxryfx1qifC(86IxdKVBdT9BIUFJm0ppeADAQ7suNdHcH6CievW5ZJZS91a572qQal4iqqRSyYI5sivaYui7asWMleRSdDmwhmbo8xucTonuNdHYf0kbBi2ExXcTusiQlfgxOZTWF17Kc(iKG(OPJuyibU3RwdVRyHgoJA4mE)eyc6WdCbGGZSbCgZq7vewXvnesbNpVU41a572qB)MO73id9ZdHwNM6Ue15qOqOohcrfC(84mBFnq(UfNP0nlNqQal4iqqRSyYI5sivaYui7asWMleRSdDmwhmbo8xucTonuNdHYf0YkydX27kwOLscrDPW4cDUf(RENuWhHe0hnDKcdjW9E1A4Dfl0WzudNX7NatqhEGlaeCMnHZyIZOgoJlpHM3VA7iB6JMUM15asT0FmWz2eoZsO9kcR4QgcPGZNxVndFxHlBH2(nr3Vrg6NhcTon1DjQZHqHqDoeIk485XzkTz47kCzlKkWcoce0klMSyUesfGmfYoGeS5cXk7qhJ1btGd)fLqRtd15qOCbTSd2qS9UIfAPKquxkmUqNBH)QbUXSrqcnDRqd0p3OgExXcnCg1WzktCgLcnTAGBmBeKqt3k0a9ZnQlmcTxryfx1qwHgOFUrOTFt09BKH(5HqRttDxI6CiuiuNdHkvHgGZG1ncPcSGJabTYIjlMlHubitHSdibBUqSYo0XyDWe4WFrj060qDoekxqlFWgIT3vSqlLeI6sHXf6MD7SqTXCI5rcTxryfx1qgZjMp02Vj6(nYq)8qO1PPUlrDoekeQZHqLXCI5dPcSGJabTYIjlMlHubitHSdibBUqSYo0XyDWe4WFrj060qDoekxUquxkmUq5saa]] )

    storeDefault( [[SimC Affliction: haunt]], 'actionLists', 20171010.201310, [[dqutVaqiurCjHks2KQIrrqofHyvKGELqfMfQiPBHks1UiLHrOoMKSmvLEgLQMgjGRPQsBJeiFJsLXrcuNtOIyDOIeAEes3tvv7tsXbrfwiQupKGAIOIuUOKsBevKGtku1mfQKBsGDssdfvKOLkuEkvtLs5QcvuBvvf7f5VOQbRYHLAXKQhlyYk6YGnRk(mjA0cXPH8AujZwIBRWUH63OmCvPJluPwofpNOPl66uY2fsFhvuNxs16fQi18jH2VstvKnYRf36fys6KR2dGChneEpoEEkOqIyyof3lsBHtYJbfOLaP(vCLDvIReRvrU)cbuxqXP7eXWK6xf0VKZrirmSKSrQvKnYRf36fysCtUhmO3KCozpDRNhTj0toJWt(iTjkitWOz9U3N9s0a2RM9(DVp7j0E6wppAjZmaCctEjZQi1mqhY9Q5)E)UNIkUx2gLqQLObWNm(jc2t0)7PB98OLmZaWjm5LmRIuZaDi3tH7j0E)UxCSxL2V7PW9G42c9(ctnd0V8nEYlzCEpr2lo2tO90TEE0Mqp5mcp5J0MOGmbJMbgncl3tH7j0E)UxCSxL2V7PW9G42c9(ctnd0V8nEYlzCEpr2lo1EvF3tH7j0E)UxCSxL2V7PW9G42c9(ctnd0V8nEYlzCEpr2tK9eHCo0rfuwNCd0V8sMvrsE84jk0jZqoMHbYfWM)0g1EaKtUApaYJb97EoZQijpguGwcK6xXv2vjM8yGKzzcGKSrj5chbcCjGffgaojDYfWMQ9aiNss9lzJ8AXTEbMe3K7bd6njFc6wppArAlCQz9U3N94K90TEE0Mqp5mcp5J0MOGmbJM1l5COJkOSo5gOF5LmRIK84XtuOtMHCmddKlGn)PnQ9aiNC1EaKhd639CMvrUNqvIqEmOaTei1VIRSRsm5XajZYeajzJsYfoce4salkmaCs6KlGnv7bqoLKQ9KnYRf36fysCtUhmO3K8oKOOapGHbcK7vZEv79zpozpDRNhTj0toJWt(iTjkitWOz9U3N9s0a2RM9(DVp7jzwfEzK2m3RM9eV3N9eApH2l7cGtnjJZ8zeGxcWuQb4wVaZ9(SxhsuuGhWWabY9Q5)E2VNi7POI71Heff4bmmqGCVA(V3V7jc5COJkOSo5gOF5LmRIK84XtuOtMHCmddKlGn)PnQ9aiNC1EaKhd639CMvrUNqFfH8yqbAjqQFfxzxLyYJbsMLjasYgLKlCeiWLawuya4K0jxaBQ2dGCkjvfGSrET4wVatIBY9Gb9MKBGrJWY9e9)EjkWfFIgWEXXEkdtY5qhvqzDYBLmCDYfoce4salkmaCs6KlGn)PnQ9aiN84XtuOtMHCmddKR2dGCouYW1jNdJsj5H6HcWNTrjKY)vKhdkqlbs9R4k7QetEmqYSmbqs2OKCHRhkGT2OesjXn5cyt1EaKtjP(lzJ8AXTEbMe3K7bd6njpBJsi1s0a4tg)eb7j6)9ugM7PW9(U3N9KmRcVmsBM7j6E)soh6OckRt(00imVKzvix4iqGlbSOWaWjPtUa28N2O2dGCYJhprHozgYXmmqUApaY50mncVNZSkKZHrPK8q9qb4Z2Oes5)kYJbfOLaP(vCLDvIjpgizwMaijBusUW1dfWwBucPK4MCbSPApaYPKuvqKnYRf36fysCtUhmO3KCozVSlao1uAqdgYa8ShEP1RbgDOUgGB9cm37ZEDirrbEaddei3t0)79DVp7j0EzBucPwIgaFY4NiyVA2RsblEpfvCVSnkHulc0LmI2Bi3t0)79v8EkQ4EzBucPwIgaFY4Niypr3ZEX7jc5COJkOSo5sRXGH5Nm2qPvBMKhpEIcDYmKJzyGCbS5pTrTha5KR2dGC3Amy4940ySHsR2mjpguGwcK6xXv2vjM8yGKzzcGKSrj5chbcCjGffgaojDYfWMQ9aiNss1oYg51IB9cmjUj3dg0BsoNSx2faNAknObdzaE2dV061aJouxdWTEbM79zVoKOOapGHbcK7vZEFjNdDubL1jxAngmmpc)agCxipE8ef6KzihZWa5cyZFAJApaYjxTha5U1yWW7fp(bm4UqEmOaTei1VIRSRsm5XajZYeajzJsYfoce4salkmaCs6KlGnv7bqoLKQcMSrET4wVatIBY9Gb9MKNDbWPMsdAWqgGN9WlTEnWOd11aCRxG5EF2RdjkkWdyyGa5E)3RAVp7bXTf69fMAseEYmaIx(IsyVp7Xj7fySYKXzSMeHNmdG4LVOe4rHPMbgncl3RM9etoh6OckRtU0Amyy(jJnuA1Mj5XJNOqNmd5yggixaB(tBu7bqo5Q9ai3TgdgEpongBO0QnZ9eQseYJbfOLaP(vCLDvIjpgizwMaijBusUWrGaxcyrHbGtsNCbSPApaYPKuJtiBKxlU1lWK4MCpyqVj5zxaCQP0GgmKb4zp8sRxdm6qDna36fyU3N96qIIc8aggiqUxn7vT3N9G42c9(ctnjcpzgaXlFrjS3N94K9cmwzY4mwtIWtMbq8Yxuc8OWuZaJgHL7vZEIjNdDubL1jxAngmmpc)agCxipE8ef6KzihZWa5cyZFAJApaYjxTha5U1yWW7fp(bm4USNqvIqEmOaTei1VIRSRsm5XajZYeajzJsYfoce4salkmaCs6KlGnv7bqoLKALyYg51IB9cmjUj3dg0BsEYuQSaAbgRmzCgl37ZEcT3RbIYRmm1Q0SWYS1laF)8uqHeXW7POI7PB98Ojzwf(iTjkitndmAewUxn)3Rs8EIqoh6OckRtUoyKGHlewj5XJNOqNmd5yggixaB(tBu7bqo5Q9aiNBWibdxiSsYJbfOLaP(vCLDvIjpgizwMaijBusUWrGaxcyrHbGtsNCbSPApaYPKuRQiBKxlU1lWK4MCpyqVj5jtPYcOfySYKXzSKCo0rfuwNC9cJn5FSm1jpE8ef6KzihZWa5cyZFAJApaYjxTha5CxyS5ECkyzQtEmOaTei1VIRSRsm5XajZYeajzJsYfoce4salkmaCs6KlGnv7bqoLKA1xYg51IB9cmjUj3dg0BsEYuQSaAVSeXWY9(SNq7Xj7LDbWPMKzv4J0MOGm1aCRxG5EF2tO9sdcZfKAVgwqRX11SE3trf3lnimxqQjZoWf)RHf0ACDnR39uuX9Y2OesTena(KXprWEI(Fp7eVNIkUNfwMTEb47NNckKigwQjZoW1E1S339ezpriNdDubL1j)LLigM84XtuOtMHCmddKlGn)PnQ9aiNC1EaKZPKLigM8yqbAjqQFfxzxLyYJbsMLjasYgLKlCeiWLawuya4K0jxaBQ2dGCkj1k7jBKxlU1lWK4MCpyqVj5jtPYcO9Ysedl37ZEcTx2faNAsMvHpsBIcYudWTEbM79zpDRNhnjZQWhPnrbzQz9U3N9eAV0GWCbP2RHf0ACDnR39uuX9sdcZfKAYSdCX)AybTgxxZ6DpfvCVSnkHulrdGpz8teSNO)3ZoX7POI7Xj7fySYKXzSwK2cNAgy0iSCVA2t8EkQ4Ewyz26fGVFEkOqIyyPMm7ax7vZEF3tK9eHCo0rfuwN8xwIyyYJhprHozgYXmmqUa28N2O2dGCYv7bqoNswIy49eQseYJbfOLaP(vCLDvIjpgizwMaijBusUWrGaxcyrHbGtsNCbSPApaYPKuRuaYg51IB9cmjUj3dg0BsUbgncl3t0)7LOax8jAa7fh7PmmjNdDubL1jxIEJWW8f0dqUWrGaxcyrHbGtsNCbS5pTrTha5KhpEIcDYmKJzyGC1EaK7O3im8EXf6biNdJsj5H6HcWNTrjKY)vKhdkqlbs9R4k7QetEmqYSmbqs2OKCHRhkGT2OesjXn5cyt1EaKtjPw9lzJ8AXTEbMe3K7bd6nj3aJgHL7j6)9suGl(enG9IJ9ugM79zpH2RdjkkWdyyGa5EIUN979zVSlao1KmoZNraEjatPgGB9cm3trf3RdjkkWdyyGa5EIU3V7jc5COJkOSo5bMXy9MigMCHJabUeWIcdaNKo5cyZFAJApaYjpE8ef6KzihZWa5Q9aixyMXy9MigMComkLKhQhkaF2gLqk)xrEmOaTei1VIRSRsm5XajZYeajzJsYfUEOa2AJsiLe3KlGnv7bqoLKALcISrET4wVatIBY9Gb9MKl0E6wppAtONCgHN8rAtuqMGrZaJgHL7fh7PB98OLmZaWjm5LmRIuZaDi3tH7j0E)UxCShe3wO3xyQzG(LVXtEjJZ7jYEISxn)3tO9Q(UNc3tO9(DV4yVkTF3tH7bXTf69fMAgOF5B8KxY48EISNiKZHoQGY6KBG(LxYSksYJhprHozgYXmmqUa28N2O2dGCYv7bqEmOF3Zzwf5EczViKhdkqlbs9R4k7QetEmqYSmbqs2OKCHJabUeWIcdaNKo5cyt1EaKtjPwzhzJ8AXTEbMe3K7bd6njp7cGtny8Y4myGjFb9a8z)Qb4wVaZ9(SNU1ZJgmEzCgmWKVGEa(SF1mWOry5EI(FpLHj5COJkOSo5f0dWN9l5XJNOqNmd5yggixaB(tBu7bqo5Q9aipUqpWE26xYJbfOLaP(vCLDvIjpgizwMaijBusUWrGaxcyrHbGtsNCbSPApaYPKuRuWKnYRf36fysCtUhmO3KCdmAewUNO)3BAz6eXW7PW9eRz)EF2lBJsi1s0a4tg)eb7vZ)9mWOryj5COJkOSo5TsgUo5chbcCjGffgaojDYfWM)0g1EaKtE84jk0jZqoMHbYv7bqohkz467juLiKZHrPK8q9qb4Z2Oes5)kYJbfOLaP(vCLDvIjpgizwMaijBusUW1dfWwBucPK4MCbSPApaYPKuRItiBKxlU1lWK4MCpyqVj5zxaCQbJxgNbdm5lOhGp7xna36fyU3N90TEE0GXlJZGbM8f0dWN9RMbgncl3t09MwMorm8EkCpXA2VNIkUx2faNAJUapOaVstlF1aCRxG5EF2lBJsi1s0a4tg)eb7vZEv)U3N9gnU1Ed5EIUxLyY5qhvqzDYlOhGp7xYJhprHozgYXmmqUa28N2O2dGCYv7bqECHEG9S1V7juLiKhdkqlbs9R4k7QetEmqYSmbqs2OKCHJabUeWIcdaNKo5cyt1EaKtjP(vmzJ8AXTEbMe3K7bd6nj3aJgHL7j6)9MwMorm8EkCpXA2V3N9Y2OesTena(KXprWE18FpdmAewsoh6OckRtUe9gHH5lOhG84XtuOtMHCmddKlGn)PnQ9aiNC1EaK7O3im8EXf6b2tOkripguGwcK6xXv2vjM8yGKzzcGKSrj5chbcCjGffgaojDYfWMQ9aiNss9BfzJ8AXTEbMe3K7bd6nj3aJgHL7j6)9MwMorm8EkCpXA2V3N9Y2OesTena(KXprWE18FpdmAewU3N9MGU1ZJwK2cNAgy0iSCVA(VxhsedRzHLzRxa((5PGcjIH5R0suGl(enG9u4EkO9(S3e0TEE0I0w4uZaJgHL7vZ)96qIyynlSmB9cW3ppfuirmmFLwIcCXNObSNc3tbiNdDubL1jxIEJWW8f0dqUWrGaxcyrHbGtsNCbS5pTrTha5KhpEIcDYmKJzyGC1EaK7O3im8EXf6b2tOVIqohgLsYd1dfGpBJsiL)RipguGwcK6xXv2vjM8yGKzzcGKSrj5cxpuaBTrjKsIBYfWMQ9aiNss97xYg51IB9cmjUj3dg0BsE2faNAsgN5ZiaVeGPudWTEbM79zVoKOOapGHbcK7vZ)9SFpfvCVoKOOapGHbcK7vZ)9(DpfvCVoKOOapGHbcK7vZ)9SFVp7nzPwGzmwVjIH1mWOry5EI(FVqlt(enG9IJ9sthfk8jAaKZHoQGY6KlbyYZE4dmJX6nrmm5XJNOqNmd5yggixaB(tBu7bqo5Q9ai3byUh7zpHzgJ1BIyyYJbfOLaP(vCLDvIjpgizwMaijBusUWrGaxcyrHbGtsNCbSPApaYPKu)ApzJ8AXTEbMe3K7bd6nj3aJgHL7j6)9MwMorm8EkCpXA2V3N9Y2OesTena(KXprWE18FpdmAewsoh6OckRtEGzmwVjIHjpE8ef6KzihZWa5cyZFAJApaYjxTha5cZmgR3eXW7juLiKhdkqlbs9R4k7QetEmqYSmbqs2OKCHJabUeWIcdaNKo5cyt1EaKtjP(vbiBKxlU1lWK4MCpyqVj5gy0iSCpr)V30Y0jIH3tH7jwZ(9(Sx2gLqQLObWNm(jc2RM)7zGrJWY9(S3e0TEE0I0w4uZaJgHL7vZ)96qIyynlSmB9cW3ppfuirmmFLwIcCXNObSNc3tbT3N9MGU1ZJwK2cNAgy0iSCVA(VxhsedRzHLzRxa((5PGcjIH5R0suGl(enG9u4Eka5COJkOSo5bMXy9MigMCHJabUeWIcdaNKo5cyZFAJApaYjpE8ef6KzihZWa5Q9aixyMXy9MigEpH(kc5Cyukjpupua(SnkHu(VI8yqbAjqQFfxzxLyYJbsMLjasYgLKlC9qbS1gLqkjUjxaBQ2dGCkj1V)s2iVwCRxGjXn5EWGEtYfApozVSlao1KmoZNraEjatPgGB9cm3trf3RdjkkWdyyGa5EIUN97jYEF2RdjkkWdyyGa5EIU3V79zpH2tO9KmRcVmsBM7vZ)9uG9(ShNSx2faNAbgoBLigwdWTEbM7jYEkQ4EsMvHxgPnZ9Q5)E)UNIkUx2gLqQLObWNm(jc2t09Sx8EIqoh6OckRtUfwMTEb47NNckKigM84XtuOtMHCmddKlGn)PnQ9aiNC1EaKhNXYS1lWEC88uqHeXWKhdkqlbs9R4k7QetEmqYSmbqs2OKCHJabUeWIcdaNKo5cyt1EaKtjP(vbr2iVwCRxGjXn5EWGEtY7qIIc8aggiqUxn7vT3N9eApozVSlao1KmoZNraEjatPgGB9cm3trf3RdjkkWdyyGa5EIUN97jYEF2tYSk8YiTzUxn)3tb27ZEzxaCQfy4SvIyyna36fyU3N9cmwzY4mwlsBHtndmAewUNO7v97EF2BYsnlSmB9cW3ppfuirmmFLMbgncl3t09cTm5t0a27ZEtwQzHLzRxa((5PGcjIH5)QzGrJWY9eDVqlt(enG9(S3KLAwyz26fGVFEkOqIyyE71mWOry5EIUxOLjFIgWEF2BYsnlSmB9cW3ppfuirmmVcOzGrJWY9eDVqlt(enG9(S3KLAwyz26fGVFEkOqIyy(F1mWOry5EIUxOLjFIga5COJkOSo5wyz26fGVFEkOqIyyYfoce4salkmaCs6KlGn)PnQ9aiN84XtuOtMHCmddKR2dG84mwMTEb2JJNNckKigEpHQeHComkLKhQhkaF2gLqk)xrEmOaTei1VIRSRsm5XajZYeajzJsYfUEOa2AJsiLe3KlGnv7bqoLK6x7iBKxlU1lWK4MCpyqVj5DirrbEaddei3RM9Q27ZEcThNSx2faNAsgN5ZiaVeGPudWTEbM7POI71Heff4bmmqGCpr3Z(9ezVp7j0EqCBHEFHPMmnqcyjVSaWBbKsEzKoWvbK7POI7bXTf69fMAVmodg(aZm5zp8fiJKaEAqY9ezVp7fySYKXzSwK2cNAgy0iSCpr3R639(S3KLAwyz26fGVFEkOqIyy(kndmAewUNO7fAzYNObS3N9MSuZclZwVa89ZtbfsedZ)vZaJgHL7j6EHwM8jAa79zVjl1SWYS1laF)8uqHeXW82RzGrJWY9eDVqlt(enG9(S3KLAwyz26fGVFEkOqIyyEfqZaJgHL7j6EHwM8jAa79zVjl1SWYS1laF)8uqHeXW8)QzGrJWY9eDVqlt(enaY5qhvqzDYTWYS1laF)8uqHeXWKlCeiWLawuya4K0jxaB(tBu7bqo5XJNOqNmd5yggixTha5XzSmB9cShhppfuirm8Ec9veY5WOusEOEOa8zBucP8Ff5XGc0sGu)kUYUkXKhdKmltaKKnkjx46HcyRnkHusCtUa2uTha5usQFvWKnYRf36fysCtUhmO3KCH2Jt2l7cGtnjJZ8zeGxcWuQb4wVaZ9uuX96qIIc8aggiqUNO7z)EIS3N96qIIc8aggiqUNO797EF2l7cGtTadNTsedRb4wVaZ9(SNKzv4LrAZCVA(VNcS3N9MSuZclZwVa89ZtbfsedZxPzGrJWY9eDVqlt(enG9(S3KLAwyz26fGVFEkOqIyy(VAgy0iSCpr3l0YKprdyVp7nzPMfwMTEb47NNckKigM3EndmAewUNO7fAzYNObS3N9MSuZclZwVa89ZtbfsedZRaAgy0iSCpr3l0YKprdyVp7nzPMfwMTEb47NNckKigM)xndmAewUNO7fAzYNObqoh6OckRtUfwMTEb47NNckKigM84XtuOtMHCmddKlGn)PnQ9aiNC1EaKhNXYS1lWEC88uqHeXW7jK9IqEmOaTei1VIRSRsm5XajZYeajzJsYfoce4salkmaCs6KlGnv7bqoLK634eYg51IB9cmjUj3dg0BsUq7Xj7LDbWPMKXz(mcWlbyk1aCRxG5EkQ4EDirrbEaddei3t09SFpr27ZEDirrbEaddei3t09(DVp7nbDRNhTiTfo1mWOry5E18FVoKigwZclZwVa89ZtbfsedZxPLOax8jAa7PW9(soh6OckRtUfwMTEb47NNckKigM84XtuOtMHCmddKlGn)PnQ9aiNC1EaKhNXYS1lWEC88uqHeXW7jKcic5XGc0sGu)kUYUkXKhdKmltaKKnkjx4iqGlbSOWaWjPtUa2uTha5usQ2lMSrET4wVatIBY9Gb9MKZj7PB98OnHEYzeEYhPnrbzcgnR39(SNq7zHLzRxa((5PGcjIHLAYSdCTxn7vTNIkUNq79AGO8kdtTknlSmB9cW3ppfuirm8EF2t365rlzMbGtyYlzwfPMb6qUxn7vTNi7jc5COJkOSo5gOF5LmRIK84XtuOtMHCmddKlGn)PnQ9aiNC1EaKhd639CMvrUNqkGiKhdkqlbs9R4k7QetEmqYSmbqs2OKCHJabUeWIcdaNKo5cyt1EaKtjPAFfzJ8AXTEbMe3K7bd6njF04w7nK7j6)9Qetoh6OckRtEb9a8z)sE84jk0jZqoMHbYfWM)0g1EaKtUApaYJl0dSNT(DpH(kc5XGc0sGu)kUYUkXKhdKmltaKKnkjx4iqGlbSOWaWjPtUa2uTha5usQ2)LSrET4wVatIBY9Gb9MK)AGO8kdtTkTc6b4Z(DVp7zHLzRxa((5PGcjIHLAYSdCT3)9eV3N9gnU1Ed5EIU3VIjNdDubL1jVGEa(SFjpE8ef6KzihZWa5cyZFAJApaYjxTha5Xf6b2Zw)UNq2lc5XGc0sGu)kUYUkXKhdKmltaKKnkjx4iqGlbSOWaWjPtUa2uTha5usQ2BpzJ8AXTEbMe3KZHoQGY6KpnncZlzwfYJhprHozgYXmmqUa28N2O2dGCYv7bqoNMPr49CMvzpHQeHComkLKhI0i8)koveobJX6n)xrEmOaTei1VIRSRsm5XajZYeajzJsYfoce4salkmaCs6KlGnv7bqoLKQ9kazJ8AXTEbMe3K7bd6njF04w7nK7j6EkyXKZHoQGY6KxqpaF2VKlCeiWLawuya4K4MCbS5pTrTha5KhpEIcDYmKJzyGC1EaKhxOhypB97EcPaIqohgLsYhSOiSY)vKhdkqlbs9R4k7QetEmqYSmbqs2OKCbSOiSssTICbSPApaYPKuT)xYg51IB9cmjUj3dg0BsUbgncl3t0)7nTmDIy49403tO9SFpfUxIcCXNObSNiKZHoQGY6K3kz46KlCeiWLawuya4K4M84XtuOtMHCmddKlGn)PnQ9aiNCHRhkGT2OesjXn5Q9aiNdLmC99e6RiKZHrPK8blkcR8FfNAOEOa8zBucP8Ff5XGc0sGu)kUYUkXKhdKmltaKKnkjxalkcRKuRixaBQ2dGCkjv7vqKnYRf36fysCtUhmO3KCdmAewUNO)3BAz6eXW7XPVNq7z)EkCVef4IprdypriNdDubL1jxIEJWW8f0dqUWrGaxcyrHbGtIBYJhprHozgYXmmqUa28N2O2dGCYfUEOa2AJsiLe3KR2dGCh9gHH3lUqpWEczViKZHrPK8blkcR8FfNAOEOa8zBucP8Ff5XGc0sGu)kUYUkXKhdKmltaKKnkjxalkcRKuRixaBQ2dGCkjv7TJSrET4wVatIBY9Gb9MKBGrJWY9e9)EtltNigEpo99eAp73tH7LOax8jAa7jc5COJkOSo5bMXy9MigMCHJabUeWIcdaNe3KhpEIcDYmKJzyGCbS5pTrTha5KlC9qbS1gLqkjUjxTha5cZmgR3eXW7jK9IqohgLsYhSOiSY)vCQH6HcWNTrjKY)vKhdkqlbs9R4k7QetEmqYSmbqs2OKCbSOiSssTICbSPApaYPKuTxbt2iVwCRxGjXn5COJkOSo5f0dWN9l5chbcCjGffgaojUjxaB(tBu7bqo5XJNOqNmd5yggixTha5Xf6b2Zw)UNq)kc5CyukjFWIIWk)lM8yqbAjqQFfxzxLyYJbsMLjasYgLKlGffHvsQIjxaBQ2dGCkPKCpyqVj5usea]] )

    storeDefault( [[SimC Affliction: mg]], 'actionLists', 20171010.201310, [[du0KNaqiQOYLiIIAteOrraNcPYQiI8kIOAwkrQBref2LGggbDmbwMs4zIknnQO4AeH2MsK8nQiJJkk5CkrW6OIsP5rvY9ukTpLOoOsXcrk9qKQMOse5IuvAJerrojvfZKkQ6MiXojQHsfLQLsv1tPmvI0vvIqBvuXEb)LqdwvhwXIPspwOjlXLH2Ss1NrsJwu1Pr8AKIzlPBlYUr1Vrz4kPJteLwojpNutxQRlkBNk8DIGXRerDEQI1tfLI5tvQ9RYqaifmF5JBflGlyYtcbZij6VFZ(ELeBcJ7S9(evW8JvC0iiVqyGtbcdeggaMTIrYujoBMMW4G8ILsIGTj2egxdsb5aqky(Yh3kwaAbZIkYAdMZDVB2(EybNIei8Iy(r5a1nQcZwVxW7BscVF57L49cEVa3lW9Uz77HntLqEJfrnlRQdv4e77xE79oZ9s(9tSjoqrKJjcQV3BVV3nBFpSzQeYBSiQzzvDOcNyF)YBVFjCpD37T333JIk2HnjHIntSqW79A79Uz77HntLqEJfrnlRQdv4e77L09cCVeVxYVpiuI3lP7rjBgzDflHkCwfhEruZKW90DVKFVa37MTVhwWPibcViMFuoqDJQqfMgcxFVKUxG7L49s(9bHs8EjDpkzZiRRyjuHZQ4WlIAMeUNU7LmFFWI7L09cCVeVxYVpiuI3lP7rjBgzDflHkCwfhEruZKW90DpD3thyBCjvs7bmfoRIAwwvdMp8cjontbgNXrWOWk5mk5jHGbM8KqW8JZ69glRQbZpwXrJG8cHbofiem)OMLPIOgKcny0NhJ0qH5atiVbxWOWkYtcbdAqEbifmF5JBflaTGrzwYKuws6OOITgmjcMfvK1gSEQiVd1SSQy(r5a1DiYh3kwUxW7JmwTWKapuZYQI5hLdu3HkmneU(EVUpo6wSjj8EjD)sDVG3RW0q4679A79Lm10eg)EjDVWWCVxW77rrf7WMKqXMjwi49lV9EfMgcxFVG33Kek2mXcbVF57BsKgXMKW7L095c2gxsL0EaBOY4EaJ(8yKgkmhyc5n4cgfwjNrjpjemW8HxiXPzkW4mocM8KqW2qLX9a2gfvnyrpXkk2JIk26TblDAwYIrpXkk2JIk26TsCP7rrfBrY(2EQiVd1SSQy(r5a1DiYh3kwemYy1ctc8qnlRkMFuoqDhQW0q4AVIJUfBscL0sjOctdHR9ABjtnnHXLKWWCfShfvSdBscfBMyHGlVvHPHW1c2Kek2mXcbxUjrAeBscLuUG5hR4OrqEHWaNcecMFuZYurudsHgm69eRO0rrfBnqlyuyf5jHGbniNlifmF5JBflaTGrzwYKuws6OOITgmNbmlQiRnykmneU(EV2EVa33KinInjH3l53tnwUNoW24sQK2dydvg3dy0NhJ0qH5atiVbxWOWk5mk5jHGbMp8cjontbgNXrWKNec2gQmUN7fiGoW2OOQbl6jwrXEuuXwVnyPtZswm6jwrXEuuXwV1zaZpwXrJG8cHbofiem)OMLPIOgKcny07jwrPJIk2AGwWOWkYtcbdAq2zaPG5lFCRybOfmlQiRny9urEhQzsqSZJIAel6qKpUvSCVG3pXM4afroMiO((L3EFU3l49AwwvuNFuL73EVebBJlPsApGPrSiY2fJmLkBTjmoy(WlK40mfyCghbJcRKZOKNecgyYtcbZqSCpB)E6zkv2AtyCW8JvC0iiVqyGtbcbZpQzzQiQbPqdg95XinuyoWeYBWfmkSI8KqWGgKLiifmF5JBflaTGzrfzTbtZYQI68JQC)27LiyBCjvs7bSmUUh3kko77vsSjmoy(WlK40mfyCghbJcRKZOKNecgyYtcbBjY194wX73SVxjXMW4G5hR4OrqEHWaNcecMFuZYurudsHgm6ZJrAOWCGjK3Glyuyf5jHGbniVuGuW8LpUvSa0cMfvK1gSEuuXoSjjuSzIfcEVx3tnwUxs3V4EbVxZYQI68JQCVx3lrW24sQK2dyf1q4IAwwfm6ZJrAOWCGjK3GlyuyLCgL8KqWaZhEHeNMPaJZ4iyYtcbBjPgc)EJLvbBJIQgSONyff7rrfB92aW8JvC0iiVqyGtbcbZpQzzQiQbPqdg9EIvu6OOITgOfmkSI8KqWGgKDcKcMV8XTIfGwWSOIS2G1tf5DiMwzsavyrSs2rXEwdr(4wXY9cEVB2(EiMwzsavyrSs2rXEwdvyAiC99ET9EQXcyBCjvs7bSkzhf7zfmF4fsCAMcmoJJGrHvYzuYtcbdm5jHG58KD8EPZky(XkoAeKximWPaHG5h1Smve1GuObJ(8yKgkmhyc5n4cgfwrEsiyqdYolqky(Yh3kwaAbZIkYAdMZDFpvK3HuvKeJOqr2UOoBvHPj6je5JBfl3l49tSjoqrKJjcQV3RT3V4EbVxG77rrf7WMKqXMjwi49lFFGZs49E7999OOIDyECQD(W1yFVxBVFHW792777rrf7WMKqXMjwi49EDFUcVNoW24sQK2dy6SuIXflmwIA2OkG5dVqItZuGXzCemkSsoJsEsiyGjpjemllLy87xsmwIA2OkG5hR4OrqEHWaNcecMFuZYurudsHgm6ZJrAOWCGjK3Glyuyf5jHGbniVeaPG5lFCRybOfmlQiRnyo399urEhsvrsmIcfz7I6SvfMMONqKpUvSCVG3pXM4afroMiO((LVFbyBCjvs7bmDwkX4Ie(oQ4tfmF4fsCAMcmoJJGrHvYzuYtcbdm5jHGzzPeJFVp8DuXNky(XkoAeKximWPaHG5h1Smve1GuObJ(8yKgkmhyc5n4cgfwrEsiyqdYbcbPG5lFCRybOfmlQiRny9urEhsvrsmIcfz7I6SvfMMONqKpUvSCVG3pXM4afroMiO((T3hCVG3Js2mY6kwc1eEHPqIOEL049cEVZDFKXQfMe4HAcVWuiruVsAuKelHkmneU((LVxiyBCjvs7bmDwkX4IfglrnBufW8HxiXPzkW4mocgfwjNrjpjemWKNecMLLsm(9ljglrnBuL7fiGoW8JvC0iiVqyGtbcbZpQzzQiQbPqdg95XinuyoWeYBWfmkSI8KqWGgKdcaPG5lFCRybOfmlQiRny9urEhsvrsmIcfz7I6SvfMMONqKpUvSCVG3pXM4afroMiO((LVp4EbVhLSzK1vSeQj8ctHer9kPX7f8EN7(iJvlmjWd1eEHPqIOEL0OijwcvyAiC99lFVqW24sQK2dy6SuIXfj8DuXNky(WlK40mfyCghbJcRKZOKNecgyYtcbZYsjg)EF47OIp17fiGoW8JvC0iiVqyGtbcbZpQzzQiQbPqdg95XinuyoWeYBWfmkSI8KqWGgKdwasbZx(4wXcqlywurwBWAgvQvmmYy1ctcC99cEVa3VQqhIuJLWGWmUUh3kko77vsSjm(9E799Uz77HAwwvm)OCG6ouHPHW13V827deEpDGTXLujThWCrLgv0q4ubZhEHeNMPaJZ4iyuyLCgL8KqWatEsiy0IknQOHWPcMFSIJgb5fcdCkqiy(rnltfrnifAWOppgPHcZbMqEdUGrHvKNecg0GCqUGuW8LpUvSa0cMfvK1gSMrLAfdJmwTWKaxd2gxsL0EaZTYyfX9mLhW8HxiXPzkW4mocgfwjNrjpjemWKNecgTvgRCVKPmLhW8JvC0iiVqyGtbcbZpQzzQiQbPqdg95XinuyoWeYBWfmkSI8KqWGgKdCgqky(Yh3kwaAbZIkYAdMctdHRV3RT3lW9njsJyts49s(9uJL7P7EbVVhfvSdBscfBMyHG3V89njsJyts49s6(CbBJlPsApGPjR5zCXkzhbJ(8yKgkmhyc5n4cgfwjNrjpjemW8HxiXPzkW4mocM8KqWmYAEg)ENNSJGTrrvdw0tSII9OOITEBay(XkoAeKximWPaHG5h1Smve1GuObJEpXkkDuuXwd0cgfwrEsiyqdYbseKcMV8XTIfGwWSOIS2GjW9o399urEhQzsqSZJIAel6qKpUvSCV3EF)eBIdue5yIG6796(CVNU7f8(j2ehOiYXeb13719s8EbVxHPHW137127f4(MePrSjj8Ej)EQXY90DVG33JIk2HnjHIntSqW7x((MePrSjj8EjDFUGTXLujThWImLkBTjmoy0NhJ0qH5atiVbxWOWk5mk5jHGbMp8cjontbgNXrWKNecg9mLkBTjmoyBuu1Gf9eROypkQyR3gaMFSIJgb5fcdCkqiy(rnltfrnifAWO3tSIshfvS1aTGrHvKNecg0GCWsbsbZx(4wXcqlywurwBWAgvQvmCL1egxFVG3lW99OOIDytsOyZele8EV2EVtcVNoW24sQK2dyRSMW4G5dVqItZuGXzCemkSsoJsEsiyGjpjemNDwtyCW8JvC0iiVqyGtbcbZpQzzQiQbPqdg95XinuyoWeYBWfmkSI8KqWGgKdCcKcMV8XTIfGwWSOIS2G1mQuRy4kRjmU(EbVxG7f4EN7(EQiVd1SSQy(r5a1DiYh3kwU3BVV3nBFpuZYQI5hLdu3HkmneU((LVpyX90DVG3NX194wrXzFVsInHX1H6EI0C)YBVFX90b2gxsL0EaBL1eghmF4fsCAMcmoJJGrHvYzuYtcbdm5jHG5SZAcJFVab0bMFSIJgb5fcdCkqiy(rnltfrnifAWOppgPHcZbMqEdUGrHvKNecg0GCGZcKcMV8XTIfGwWSOIS2GPW0q4679A79cCFjtnnHXVxs3lmm37P7EbVVhfvSdBscfBMyHG3V827vyAiC99cEVa3NX194wrXzFVsInHX1H6EI0C)27fEV3EF)QcDisnwcdchQmUN7PdSnUKkP9a2qLX9ag95XinuyoWeYBWfmkSsoJsEsiyG5dVqItZuGXzCem5jHGTHkJ75EbwqhyBuu1Gf9eROypkQyR3gaMFSIJgb5fcdCkqiy(rnltfrnifAWO3tSIshfvS1aTGrHvKNecg0GCWsaKcMV8XTIfGwWSOIS2GPW0q4679A79cCFjtnnHXVxs3lmm37P7EbVVhfvSdBscfBMyHG3V827vyAiC99cEVa3NX194wrXzFVsInHX1H6EI0C)27fEV3EF)QcDisnwcdc1K18mUyLSJ3thyBCjvs7bmnznpJlwj7iy0NhJ0qH5atiVbxWOWk5mk5jHGbMp8cjontbgNXrWKNecMrwZZ4378KD8EbcOdSnkQAWIEIvuShfvS1BdaZpwXrJG8cHbofiem)OMLPIOgKcny07jwrPJIk2AGwWOWkYtcbdAqEHqqky(Yh3kwaAbZIkYAdMa37C33tf5DOMjbXopkQrSOdr(4wXY9E799tSjoqrKJjcQV3R7Z9E6UxW7NytCGIihteuFVx3lX7f8EfMgcxFVxBVxG7lzQPjm(9s6EHH5EpD3l499OOIDytsOyZele8(L3EVctdHRVxW7f4(mUUh3kko77vsSjmUou3tKM73EVW79277xvOdrQXsyqyKPuzRnHXVNoW24sQK2dyrMsLT2eghm6ZJrAOWCGjK3GlyuyLCgL8KqWaZhEHeNMPaJZ4iyYtcbJEMsLT2eg)EbcOdSnkQAWIEIvuShfvS1BdaZpwXrJG8cHbofiem)OMLPIOgKcny07jwrPJIk2AGwWOWkYtcbdAqEraifmF5JBflaTGzrfzTbRNkY7qmTYKaQWIyLSJI9SgI8XTIL7f8E3S99qmTYKaQWIyLSJI9SgQW0q46796(sMAAcJFVKUxyyU37T333tf5DyAQ4ojksvn61qKpUvSCVG33JIk2HnjHIntSqW7x((ajEVG3Ng(eUg7796(aHGTXLujThWQKDuSNvW8HxiXPzkW4mocgfwjNrjpjemWKNecMZt2X7LoR3lqaDG5hR4OrqEHWaNcecMFuZYurudsHgm6ZJrAOWCGjK3Glyuyf5jHGbniVybifmF5JBflaTGzrfzTbtG77PI8ouZKGyNhf1iw0HiFCRy5EbVFInXbkICmrq99lV9(CVNU79277f4(j2ehOiYXeb13V827L49cEFH1HrMsLT2egpuHPHW137127JJUfBscVxYVVvJdSk2KeEpDGTXLujThW0iwez7IrMsLT2eghmF4fsCAMcmoJJGrHvYzuYtcbdm5jHGziwUNTFp9mLkBTjm(9ceqhy(XkoAeKximWPaHG5h1Smve1GuObJ(8yKgkmhyc5n4cgfwrEsiyqdYlYfKcMV8XTIfGwWSOIS2G1JIk2HnjHIntSqW796(Cfc2gxsL0EalJR7XTIIZ(ELeBcJdMp8cjontbgNXrWOWk5mk5jHGbM8KqWwICDpUv8(n77vsSjm(9ceqhy(XkoAeKximWPaHG5h1Smve1GuObJ(8yKgkmhyc5n4cgfwrEsiyqdYlCgqky(Yh3kwaAbZIkYAd2eBIdue5yIG67x((G7f8EnlRkQZpQY9lV9ENbSnUKkP9awgx3JBffN99kj2eghmF4fsCAMcmoJJGrHvYzuYtcbdm5jHGTe56ECR49B23RKyty87fybDG5hR4OrqEHWaNcecMFuZYurudsHgm6ZJrAOWCGjK3Glyuyf5jHGbniVqIGuW8LpUvSa0cMfvK1gmbUpJR7XTIIZ(ELeBcJRd19eP5(T3l8EV9(EbU35UFvHoePglH5gMX194wrXzFVsInHXVxW7xvOdrQXsyqygx3JBffN99kj2eg)E6UNU7f8(cRdhQmUNqfMgcxF)Y3hhDl2KeEVKFVa3VuHs8EjDVEfRvX8JUX7PdSnUKkP9awgx3JBffN99kj2eghmF4fsCAMcmoJJGrHvYzuYtcbdm5jHGTe56ECR49B23RKyty87fix6aZpwXrJG8cHbofiem)OMLPIOgKcny0NhJ0qH5atiVbxWOWkYtcbdAqEXsbsbZx(4wXcqlywurwBWCZ23dl4uKaHxeZpkhOUrvOctdHRV3R7lSomJR7XTIIZ(ELeBcJlgeQW0q4679277DZ23dl4uKaHxeZpkhOUrvOctdHRV3R7lSomJR7XTIIZ(ELeBcJlUiuHPHW137T337MTVhwWPibcViMFuoqDJQqfMgcxFVx3xyDygx3JBffN99kj2egxm3qfMgcxFV3EFVB2(EybNIei8Iy(r5a1nQcvyAiC99EDFH1HzCDpUvuC23RKytyCrNjuHPHW137T337MTVhwWPibcViMFuoqDJQqfMgcxFVx3xyDygx3JBffN99kj2egxuIHkmneU(EbVpJR7XTIIZ(ELeBcJRd19eP5(LVpaSnUKkP9aMcNvrnlRQbZhEHeNMPaJZ4iyuyLCgL8KqWatEsiy(Xz9EJLv13lqaDG5hR4OrqEHWaNcecMFuZYurudsHgm6ZJrAOWCGjK3Glyuyf5jHGbniVWjqky(Yh3kwaAbZIkYAdwA4t4ASV3RT3hieSnUKkP9awLSJI9ScMp8cjontbgNXrWOWk5mk5jHGbM8KqWCEYoEV0z9Ebwqhy(XkoAeKximWPaHG5h1Smve1GuObJ(8yKgkmhyc5n4cgfwrEsiyqdYlCwGuW8LpUvSa0cMfvK1gSvf6qKASegewj7OypR3l49zCDpUvuC23RKytyCDOUNin3V9EH3l49PHpHRX(EVUxIcbBJlPsApGvj7OypRG5dVqItZuGXzCemkSsoJsEsiyGjpjemNNSJ3lDwVxGCPdm)yfhncYleg4uGqW8JAwMkIAqk0GrFEmsdfMdmH8gCbJcRipjemOb5flbqky(Yh3kwaAbBJlPsApGvudHlQzzvW8HxiXPzkW4mocgfwjNrjpjemWKNec2ssne(9glREVab0b2gfvnyX8dHVnyPj8gvQS1EBay(XkoAeKximWPaHG5h1Smve1GuObJ(8yKgkmhyc5n4cgfwrEsiyqdY5keKcMV8XTIfGwWSOIS2GLg(eUg7796ENLqW24sQK2dyvYok2Zky0NhJ0qH5atiVbAbJcRKZOKNecgy(WlK40mfyCghbtEsiyopzhVx6SEVaodDGTrrvdwI5GWPUnam)yfhncYleg4uGqW8JAwMkIAqk0GrH5GWPcYbGrHvKNecg0GCUbGuW8LpUvSa0cMfvK1gmfMgcxFVx3xYutty87LmUxG7Z9EjDFtI0i2KeEpDGTXLujThWgQmUhWOppgPHcZbMqEd0cMp8cjontbgNXrWOWk5mk5jHGbg9EIvu6OOITgOfm5jHGTHkJ75EbYLoW2OOQblXCq4u3gS0rpXkk2JIk26TbG5hR4OrqEHWaNcecMFuZYurudsHgmkmheovqoamkSI8KqWGgKZDbifmF5JBflaTGzrfzTbtHPHW13719Lm10eg)EjJ7f4(CVxs33KinInjH3thyBCjvs7bmnznpJlwj7iy0NhJ0qH5atiVbAbZhEHeNMPaJZ4iyuyLCgL8KqWaJEpXkkDuuXwd0cM8KqWmYAEg)ENNSJ3lWc6aBJIQgSeZbHtDBWsh9eROypkQyR3gaMFSIJgb5fcdCkqiy(rnltfrnifAWOWCq4ub5aWOWkYtcbdAqo3CbPG5lFCRybOfmlQiRnykmneU(EVUVKPMMW43lzCVa3N79s6(MePrSjj8E6aBJlPsApGfzkv2AtyCWOppgPHcZbMqEd0cMp8cjontbgNXrWOWk5mk5jHGbg9EIvu6OOITgOfm5jHGrptPYwBcJFValOdSnkQAWsmheo1TblD0tSII9OOITEBay(XkoAeKximWPaHG5h1Smve1GuObJcZbHtfKdaJcRipjemOb5CDgqky(Yh3kwaAbBJlPsApGvj7OypRGrFEmsdfMdmH8gOfmkSsoJsEsiyG5dVqItZuGXzCem5jHG58KD8EPZ69cir6aBJIQgSeZbHtDRqW8JvC0iiVqyGtbcbZpQzzQiQbPqdgfMdcNkilemkSI8KqWGgAWSOIS2Gbnaa]] )

    storeDefault( [[SimC Affliction: writhe]], 'actionLists', 20171010.201310, [[duKC0aqivf1LiaiBsQQrriofH0Quv4vQkYSOuk3Iaa7IKggfCmLYYuQ6zukMgLsCncOTrPK8nbQXrPK6CeG06iaKMNe4EeO9jbDqvLwib5HeutKaixuQsBKaqCsPkMjLs1nvvTtsmuca1sLOEkvtLcDvcqSvLk2lYFvLbdCyflMIESqtwsxgAZc6ZeQrlGtRYRPunBLCBPSBu9BugUu54eGA5e9CsnDrxNs2Ue57kvA8ea15LqRNaGA(cK9dAAJmsEV8XCHvYKCLPHK7xtyi4By46I5X4cGcb7kVmasEzCHJgjL9g2cEZWMb1nY9omEZ6eaEYJXjL92kbs(3yEmUMmskBKrY7LpMlSscrUhLxxs(NHatRWq1ko1DpE9fyKLqDIsvRoiOpeKxdHGcHabcb9HarGatRWq1KjBipX6tZSwAvjoXeckuqiqGqqqbbb5ifJPAEn8LSx9qiOabHatRWq1KjBipX6tZSwAvjoXec(acebceie8jiytvGqWhqakGTUUoSQkXP7n86tZ2fcefc(eeiceyAfgQwXPU7XRVaJSeQtuQkX2CCne8beiceiqi4tqWMQaHGpGauaBDDDyvvIt3B41NMTleikeiaeeSThc(acebceie8jiytvGqWhqakGTUUoSQkXP7n86tZ2fcefcefceL8VM36YIKlXP7Pzwln59WRxCsMKCoJJK)ZQ7msLPHKtUY0qYlJthe4mRLM8Y4chnsk7nSf8MbYlJAMLmIAYiLKlCamA)NvcBipjtY)zvLPHKtjPSNmsEV8XCHvsiY9O86sY)meyAfgQwXPU7XRVaJSeQtuQA1bb9HG8AieuieiqiOpeiceyAfgQQzwRxGrwc1PQeBZX1qqHccbIabcec(eeSPkqi4diafWwxxhwvL409gE9Pz7cbIcb9HalUohZf(MWW1fZJX1Q6CI2HGcHGniiOGGatRWq1iJhzY6WJ4Jf(Ya4BHIpgpCwlvRoiiOGGGuEC7yQ2jzr1JN4AHXu1QdcckiiiLh3oMQ6CI2pU4xNKfvpEIRfgtvRoiiOGGGuEC7yQ2jzr12Otuwu1QdcckiiiLh3oMQ6CI2pU4xNKfvBJorzrvRoiiOGGGuEC7yQ2jzr1O8svRoiiOGGGuEC7yQQZjA)4IFDswunkVu1QdcckiiiLh3oMQDswuTek1tERllQA1bbbfeeKYJBhtvDor7hx8RtYIQLqPEYBDzrvRoiiOGGGuEC7yQ2jzrvDhUwVo2UOu1QdcckiiiLh3oMQ6CI2pU4xNKfv1D4A96y7IsvRoiquY)AERllsUeNUNMzT0K3dVEXjzsY5mos(pRUZivMgso5ktdjVmoDqGZSwAiqKnrjVmUWrJKYEdBbVzG8YOMzjJOMmsj5chaJ2)zLWgYtYK8FwvzAi5usk2qgjVx(yUWkje5EuEDj5sSnhxdbfiieKx0(lVgcbFccehRK)18wxwK8rmJxK8E41lojtsoNXrY)z1DgPY0qYjxzAi5FfZ4fjVmUWrJKYEdBbVzG8YOMzjJOMmsj5chaJ2)zLWgYtYK8FwvzAi5usk2czK8E5J5cRKqK)pcWxZQzCKIXutUaj3JYRljpNfYtvnZA9cmYsOovr(yUWke0hcIm2QY2LRQzwRxGrwc1PQeBZX1qqbqqC05lVgcbFab2kiOpeiX2CCneuGGqq1so5X4qWhqGbvBGG(qqosXyQMxdFj7vpeckuqiqIT54AiOpeKxdFj7vpeckecYlA)LxdHGpGaBi)R5TUSi5JygVi5chaJ2)zLWgYtYK8FwDNrQmnKCY7HxV4Kmj5CghjxzAi5FfZ4fHar2eL8VsXAYJfJl8LJumMAb3ST2ia)IfJl8LJumMAbfOTLJumMVluWCwipv1mR1lWilH6uf5J5cR9Jm2QY2LRQzwRxGrwc1PQeBZX1fehD(YRHFyR6lX2CCDbcwTKtEm(hguTPFosXyQMxdFj7vpSqbLyBoUUFEn8LSx9WcZlA)Lxd)WgYlJlC0iPS3WwWBgiVmQzwYiQjJusUWfJl04ifJPMeI8FwvzAi5uskcKmsEV8XCHvsiY)hb4Rz1mosXyQj3gY9O86sYLyBoUgckqqiiVO9xEnec(eeiowHG(qqEn8LSx9qiOqiiVO9xEnec(acSH8VM36YIKpIz8IKlCamA)NvcBipjtY)z1DgPY0qYjVhE9ItYKKZzCKCLPHK)vmJxecezVOK)vkwtESyCHVCKIXul4MT1gb4xSyCHVCKIXulOn2wosXy(UqbLyBoUUabZlA)Lxd)K4yTFEn8LSx9WcZlA)Lxd)WgYlJlC0iPS3WwWBgiVmQzwYiQjJusUWfJl04ifJPMeI8FwvzAi5usk2kYi59YhZfwjHi3JYRljpNfYtvnB3xgaFAeRAvKpMlScb9HGjMxj8HCSDOgckuqiWgiOpeOzwRNoWiRqGGqGaj)R5TUSi5AeRpw4lYKsRU8yCY7HxV4Kmj5Cghj)Nv3zKktdjNCLPHK7iwHawieimtkT6YJXjVmUWrJKYEdBbVzG8YOMzjJOMmsj5chaJ2)zLWgYtYK8FwvzAi5uskbtgjVx(yUWkje5EuEDj5AM16PdmYkeiieiqiiOGGarGG8A4lzV6HqqbccbIabIabvl5KhJdbFccIJoF51qiqui4diqZSwpDGrwHarHarj)R5TUSi5wCDoMl8nHHRlMhJtEp86fNKjjNZ4i5)S6oJuzAi5KRmnKCbeUohZfcbFddxxmpgN8Y4chnsk7nSf8MbYlJAMLmIAYiLKlCamA)NvcBipjtY)zvLPHKtjPyRjJK3lFmxyLeICpkVUK8CKIXunVg(s2REieuGGqG4yfc(ac2db9HanZA90bgzfckacei5FnV1LfjVkNJ)0mRf5chaJ2)zLWgYtYK8FwDNrQmnKCY7HxV4Kmj5CghjxzAi5cqY54qGZSwK)vkwtESyCHVCKIXul4g5LXfoAKu2Byl4ndKxg1mlze1Krkjx4IXfACKIXutcr(pRQmnKCkjfbuYi59YhZfwjHi3JYRljpNfYtvS1X2fLy9TUq8LtNkYhZfwHG(qGPvyOk26y7IsS(wxi(YPtvIT54AiOabHaXXk5FnV1LfjFDH4lNoY7HxV4Kmj5Cghj)Nv3zKktdjNCLPHKB7xicbgNoYlJlC0iPS3WwWBgiVmQzwYiQjJusUWbWO9FwjSH8Kmj)NvvMgsoLKYMbYi59YhZfwjHi3JYRlj)ZqqolKNQILxJDs8XcFARoj2MyrvKpMlScb9HGjMxj8HCSDOgckqqiype0hcebcYrkgt18A4lzV6HqqHqWMT2aeeuqqqosXyQgaNvgqTlMqqbccb7nabbfeeKJumMQ51WxYE1dHGcGaBmabIs(xZBDzrY1wTgJ)QmwtS1iRK3dVEXjzsY5mos(pRUZivMgso5ktdj3TAnghceGySMyRrwjVmUWrJKYEdBbVzG8YOMzjJOMmsj5chaJ2)zLWgYtYK8FwvzAi5uskBBKrY7LpMlSscrUhLxxs(NHGCwipvflVg7K4Jf(0wDsSnXIQiFmxyfc6dbtmVs4d5y7qneuieSN8VM36YIKRTAng)D8quYNf59WRxCsMKCoJJK)ZQ7msLPHKtUY0qYDRwJXHGE4HOKplYlJlC0iPS3WwWBgiVmQzwYiQjJusUWbWO9FwjSH8Kmj)NvvMgsoLKY2EYi59YhZfwjHi3JYRljpNfYtvXYRXoj(yHpTvNeBtSOkYhZfwHG(qWeZRe(qo2oudbccbBqqFiafWwxxhwv1hVYK490DxIqqFi4ZqqKXwv2UCv9XRmjEpD3L47Ivvj2MJRHGcHadK)18wxwKCTvRX4VkJ1eBnYk59WRxCsMKCoJJK)ZQ7msLPHKtUY0qYDRwJXHabigRj2AKviqKnrjVmUWrJKYEdBbVzG8YOMzjJOMmsj5chaJ2)zLWgYtYK8FwvzAi5uskB2qgjVx(yUWkje5EuEDj55SqEQkwEn2jXhl8PT6KyBIfvr(yUWke0hcMyELWhYX2HAiOqiydc6dbOa2666WQQ(4vMeVNU7sec6dbFgcIm2QY2LRQpELjX7P7UeFxSQkX2CCneuieyG8VM36YIKRTAng)D8quYNf59WRxCsMKCoJJK)ZQ7msLPHKtUY0qYDRwJXHGE4HOKpliqKnrjVmUWrJKYEdBbVzG8YOMzjJOMmsj5chaJ2)zLWgYtYK8FwvzAi5uskB2czK8E5J5cRKqK7r51LKNmXIxOAKXwv2UCne0hcebc6KyPN4yvDt1IRZXCHVjmCDX8yCiiOGGatRWqvnZA9cmYsOovLyBoUgckuqiyZaeik5FnV1Lfj3eLAuA)4IjVhE9ItYKKZzCK8FwDNrQmnKCYvMgsUqOuJs7hxm5LXfoAKu2Byl4ndKxg1mlze1Krkjx4ay0(pRe2qEsMK)ZQktdjNssztGKrY7LpMlSscrUhLxxsEYelEHQrgBvz7Y1K)18wxwKCZfJvFHwYIK3dVEXjzsY5mos(pRUZivMgso5ktdjxOfJvHabqSKfjVmUWrJKYEdBbVzG8YOMzjJOMmsj5chaJ2)zLWgYtYK8FwvzAi5uskB2kYi59YhZfwjHi3JYRljpzIfVq1owEmUgc6dbIab5ifJPAEn8LSx9qiOabHGGnabIs(xZBDzrY7y5X4K3dVEXjzsY5mos(pRUZivMgso5ktdjxamlpgN8Y4chnsk7nSf8MbYlJAMLmIAYiLKlCamA)NvcBipjtY)zvLPHKtjPSfmzK8E5J5cRKqK7r51LKNmXIxOAhlpgxdb9HarGarGGpdb5SqEQQzwRxGrwc1PkYhZfwHGGcccmTcdv1mR1lWilH6uvIT54AiOqiyBpeike0hcebcs5XTJPANKfvhErvRoiiOGGGuEC7yQQZjA)1jzr1Hxu1QdcckiiWIRZXCHVjmCDX8yCTQoNODiOqbHG9qGOqGOK)18wxwK8owEmo59WRxCsMKCoJJK)ZQ7msLPHKtUY0qYfaZYJXHar2eL8Y4chnsk7nSf8MbYlJAMLmIAYiLKlCamA)NvcBipjtY)zvLPHKtjPSzRjJK3lFmxyLeICpkVUKCj2MJRHGceecYlA)LxdHGpbbIJviOpeKxdFj7vpeckecYlA)LxdHGpGG9K)18wxwKC91fGXFRlejx4ay0(pRe2qEsMK)ZQ7msLPHKtEp86fNKjjNZ4i5ktdj3VUamoey7xis(xPyn5XIXf(YrkgtTGBKxgx4OrszVHTG3mqEzuZSKrutgPKCHlgxOXrkgtnje5)SQY0qYPKu2eqjJK3lFmxyLeICpkVUKCj2MJRHGceecYlA)LxdHGpbbIJviOpeiceicemX8kHpKJTd1qqbqGnqqFiiNfYtvnB3xgaFAeRAvKpMlScbIcbbfeemX8kHpKJTd1qqbqGaHarHG(qqEn8LSx9qiOqiiVO9xEnec(ac2t(xZBDzrYJmP0QlpgNCHdGr7)Ssyd5jzs(pRUZivMgso59WRxCsMKCoJJKRmnKCHzsPvxEmo5FLI1Khlgx4lhPym1cUrEzCHJgjL9g2cEZa5LrnZsgrnzKsYfUyCHghPym1KqK)ZQktdjNsszVbYi59YhZfwjHi3JYRljVn8rTlMqqbqGTyac6dbIabwCDoMl8nHHRlMhJRv15eTdbfabBqqqbbbFgcmTcdvR4u3941xGrwc1jkvT6Garj)R5TUSi5RleF50rEp86fNKjjNZ4i5)S6oJuzAi5KRmnKCB)criW40bbISjk5LXfoAKu2Byl4ndKxg1mlze1Krkjx4ay0(pRe2qEsMK)ZQktdjNssz)gzK8E5J5cRKqK7r51LKlceyAfgQwXPU7XRVaJSeQtuQkX2CCne8jiW0kmunzYgYtS(0mRLwvItmHGpGarGabcbFccqbS111HvvjoDVHxFA2UqGOqGOqqHccbIabB7HGpGarGabcbFcc2ufie8beGcyRRRdRQsC6EdV(0SDHarHarj)R5TUSi5sC6EAM1stEp86fNKjjNZ4i5)S6oJuzAi5KRmnK8Y40bboZAPHar2lk5LXfoAKu2Byl4ndKxg1mlze1Krkjx4ay0(pRe2qEsMK)ZQktdjNssz)EYi59YhZfwjHi3JYRljxeiiNfYtvnB3xgaFAeRAvKpMlScb9HGjMxj8HCSDOgckuqiWgiquiiOGGarGGjMxj8HCSDOgckecSbc6dbvwQgzsPvxEmUQedLOoWyUqiquY)AERllsUgX6Jf(ImP0QlpgN8E41lojtsoNXrY)z1DgPY0qYjxzAi5oIviGfcbcZKsRU8yCiqKnrjVmUWrJKYEdBbVzG8YOMzjJOMmsj5chaJ2)zLWgYtYK8FwvzAi5usk7THmsEV8XCHvsiY9O86sYZzH8unY45i(yCvKpMlScb9HGklvT46Cmx4Bcdxxmpg)TPkX2CCneuaeehD(YRHqqFiOYsvlUohZf(MWW1fZJXF7vLyBoUgckacIJoF51qiOpeuzPQfxNJ5cFty46I5X4pBuLyBoUgckacIJoF51qiOpeuzPQfxNJ5cFty46I5X4pBrvIT54AiOaiio68LxdHG(qqLLQwCDoMl8nHHRlMhJ)eOQeBZX1qqbqqC05lVgs(xZBDzrYT46Cmx4BcdxxmpgN8E41lojtsoNXrY)z1DgPY0qYjxzAi5ciCDoMlec(ggUUyEmoeiYMOKxgx4OrszVHTG3mqEzuZSKrutgPKCHdGr7)Ssyd5jzs(pRQmnKCkjL92czK8E5J5cRKqK7r51LKBAfgQwXPU7XRVaJSeQtuQkX2CCneuOGqq1so5X4qWNGG4OZxEnec6dbvwQAX15yUW3egUUyEm(BtvIT54AiOaiio68LxdHG(qqLLQwCDoMl8nHHRlMhJ)2RkX2CCneuaeehD(YRHqqFiOYsvlUohZf(MWW1fZJXF2OkX2CCneuaeehD(YRHqqFiOYsvlUohZf(MWW1fZJXF2IQeBZX1qqbqqC05lVgcb9HGklvT46Cmx4Bcdxxmpg)jqvj2MJRHGcGG4OZxEnK8VM36YIKBX15yUW3egUUyEmo5chaJ2)zLWgYtYK8FwDNrQmnKCY7HxV4Kmj5CghjxzAi5ciCDoMlec(ggUUyEmoeiYErj)RuSM8yX4cF5ifJPwWnBlhPymFxOGMwHHQvCQ7E86lWilH6eLQsSnhxxOGvl5KhJ)P4OZxEnSFLLQwCDoMl8nHHRlMhJ)2uLyBoUUG4OZxEnSFLLQwCDoMl8nHHRlMhJ)2RkX2CCDbXrNV8Ay)klvT46Cmx4Bcdxxmpg)zJQeBZX1fehD(YRH9RSu1IRZXCHVjmCDX8y8NTOkX2CCDbXrNV8Ay)klvT46Cmx4Bcdxxmpg)jqvj2MJRlio68LxdjVmUWrJKYEdBbVzG8YOMzjJOMmsj5cxmUqJJumMAsiY)zvLPHKtjPSxGKrY7LpMlSscrUhLxxsUPvyOAfN6UhV(cmYsOorPQeBZX1qqHqqEr7V8Aie8beShc6dbIabFgcYzH8unY45i(yCvKpMlScbbfeeOzwRNoWiRqqHqWgeeuqqGPvyOQMzTEbgzjuNQwDqGOqqFiqeiOYsvlUohZf(MWW1fZJXFBQ5fTFCXqWNGGklvT46Cmx4Bcdxxmpg)TxnVO9Jlgc(eeuzPQfxNJ5cFty46I5X4pBuZlA)4IHGpbbvwQAX15yUW3egUUyEm(ZwuZlA)4IHGpbbvwQAX15yUW3egUUyEm(tGQ5fTFCXqqbqGaHarj)R5TUSi5wCDoMl8nHHRlMhJtEp86fNKjjNZ4i5)S6oJuzAi5KRmnKCbeUohZfcbFddxxmpghceXgrjVmUWrJKYEdBbVzG8YOMzjJOMmsj5chaJ2)zLWgYtYK8FwvzAi5usk7TvKrY7LpMlSscrUhLxxs(NHatRWq1ko1DpE9fyKLqDIsvRoiOpeyX15yUW3egUUyEmUwvNt0oeuieSr(xZBDzrYL4090mRLM8E41lojtsoNXrY)z1DgPY0qYjxzAi5LXPdcCM1sdbIyJOKxgx4OrszVHTG3mqEzuZSKrutgPKCHdGr7)Ssyd5jzs(pRQmnKCkjL9btgjVx(yUWkje5EuEDj5FgcmTcdvR4u3941xGrwc1jkvT6GG(qqNel9ehRQBQwCDoMl8nHHRlMhJdb9HatRWq1KjBipX6tZSwAvjoXeckec2i)R5TUSi5sC6EAM1stEp86fNKjjNZ4i5)S6oJuzAi5KRmnK8Y40bboZAPHarSfrjVmUWrJKYEdBbVzG8YOMzjJOMmsj5chaJ2)zLWgYtYK8FwvzAi5usk7T1KrY7LpMlSscrUhLxxsEolKNQyRJTlkX6BDH4lNovKpMlScb9HatRWqvS1X2fLy9TUq8LtNQeBZX1qqbqq1so5X4qWhqGbvBGG(qGiqWNHatRWq1ko1DpE9fyKLqDIsvRoiiOGGalUohZf(MWW1fZJX1Q6CI2HGcGGniquY)AERlls(6cXxoDK3dVEXjzsY5mos(pRUZivMgso5ktdj32VqecmoDqGi7fL8Y4chnsk7nSf8MbYlJAMLmIAYiLKlCamA)NvcBipjtY)zvLPHKtjPSxaLmsEV8XCHvsiY9O86sYLyOe1bgZfcb9HG8A4lzV6HqqHccbsSnhxt(xZBDzrYhXmErY7HxV4Kmj5Cghj)Nv3zKktdjNCLPHK)vmJxeceXgrjVmUWrJKYEdBbVzG8YOMzjJOMmsj5chaJ2)zLWgYtYK8FwvzAi5usk2yGmsEV8XCHvsiY9O86sYLyOe1bgZfcb9HG8A4lzV6HqqHccbsSnhxt(xZBDzrY1xxag)TUqK8E41lojtsoNXrY)z1DgPY0qYjxzAi5(1fGXHaB)criqKnrjVmUWrJKYEdBbVzG8YOMzjJOMmsj5chaJ2)zLWgYtYK8FwvzAi5usk2SrgjVx(yUWkje5EuEDj5smuI6aJ5cHG(qqEn8LSx9qiOqbHaj2MJRj)R5TUSi5rMuA1LhJtEp86fNKjjNZ4i5)S6oJuzAi5KRmnKCHzsPvxEmoeiYMOKxgx4OrszVHTG3mqEzuZSKrutgPKCHdGr7)Ssyd5jzs(pRQmnKCkjfB2tgjVx(yUWkje5EuEDj551WxYE1dHGcHG8I2F51qi4diWgiOpe8ziW0kmuTItD3JxFbgzjuNOu1Qdc6dbsmuI6aJ5cHG(qqEn8LSx9qiOqiiVO9xEnec(acSH8VM36YIKpIz8IKlCamA)NvcBipjtY)z1DgPY0qYjVhE9ItYKKZzCKCLPHK)vmJxeceXweL8VsXAYJfJl8LJumMAb3STCKIX8DHcMxdFj7vpSW8I2F51WpSP)NnTcdvR4u3941xGrwc1jkvLyBoUUVedLOoWyUW(51WxYE1dlmVO9xEn8dBiVmUWrJKYEdBbVzG8YOMzjJOMmsj5cxmUqJJumMAsiY)zvLPHKtjPyJnKrY7LpMlSscrUhLxxsEEn8LSx9qiOqiiVO9xEnec(acSbc6dbFgcmTcdvR4u3941xGrwc1jkvT6GG(qGedLOoWyUqiOpeKxdFj7vpeckecYlA)LxdHGpGaBi)R5TUSi56RlaJ)wxisUWbWO9FwjSH8Kmj)Nv3zKktdjN8E41lojtsoNXrYvMgsUFDbyCiW2VqecezVOK)vkwtESyCHVCKIXul4MTLJumMVluW8A4lzV6HfMx0(lVg(Hn9)SPvyOAfN6UhV(cmYsOorPQeBZX19LyOe1bgZf2pVg(s2REyH5fT)YRHFyd5LXfoAKu2Byl4ndKxg1mlze1Krkjx4IXfACKIXutcr(pRQmnKCkjfBSfYi59YhZfwjHi3JYRljpVg(s2REieuieKx0(lVgcbFab2ab9HGpdbMwHHQvCQ7E86lWilH6eLQwDqqFiqIHsuhymxie0hcYRHVK9Qhcbfcb5fT)YRHqWhqGnK)18wxwK8itkT6YJXjx4ay0(pRe2qEsMK)ZQ7msLPHKtEp86fNKjjNZ4i5ktdjxyMuA1LhJdbISxuY)kfRjpwmUWxosXyQfCZ2YrkgZ3fkyEn8LSx9WcZlA)Lxd)WM(F20kmuTItD3JxFbgzjuNOuvIT546(smuI6aJ5c7NxdFj7vpSW8I2F51WpSH8Y4chnsk7nSf8MbYlJAMLmIAYiLKlCX4cnosXyQjHi)NvvMgsoLKIncKmsEV8XCHvsiY9O86sYBdFu7IjeuGGqWMbY)AERlls(6cXxoDK3dVEXjzsY5mos(pRUZivMgso5ktdj32VqecmoDqGi2ik5LXfoAKu2Byl4ndKxg1mlze1Krkjx4ay0(pRe2qEsMK)ZQktdjNssXgBfzK8E5J5cRKqK7r51LK3jXspXXQ6M66cXxoDqqFiWIRZXCHVjmCDX8yCTQoNODiqqiWae0hcAdFu7IjeuaeiqdK)18wxwK81fIVC6iVhE9ItYKKZzCK8FwDNrQmnKCYvMgsUTFHieyC6GarSfrjVmUWrJKYEdBbVzG8YOMzjJOMmsj5chaJ2)zLWgYtYK8FwvzAi5usk2emzK8E5J5cRKqK)18wxwK8QCo(tZSwK3dVEXjzsY5mos(pRUZivMgso5ktdjxasohhcCM1cceztuY)kfRjpgyoUGB22XtukT6sb3iVmUWrJKYEdBbVzG8YOMzjJOMmsj5chaJ2)zLWgYtYK8FwvzAi5usk2yRjJK3lFmxyLeICpkVUK82Wh1Uycbfab2AdK)18wxwK81fIVC6ix4ay0(pRe2qEscr(pRUZivMgso59WRxCsMKCoJJKRmnKCB)criW40bbIiqrj)RuSM8gR0Xfl4g5LXfoAKu2Byl4ndKxg1mlze1Krkj)Nv64IjLnY)zvLPHKtjPyJakzK8E5J5cRKqK7r51LKlX2CCneuGGqq1so5X4qGaaiqeiWgi4diiVO9xEneceL8VM36YIKpIz8IKlCamA)NvcBipjHiVhE9ItYKKZzCK8FwDNrQmnKCYfUyCHghPym1KqKRmnK8VIz8IqGicuuY)kfRjVXkDCXcUzBXIXf(YrkgtTGBKxgx4OrszVHTG3mqEzuZSKrutgPK8FwPJlMu2i)NvvMgsoLKITyGmsEV8XCHvsiY9O86sYLyBoUgckqqiOAjN8yCiqaaeiceyde8beKx0(lVgcbIs(xZBDzrY1xxag)TUqKCHdGr7)Ssyd5jje59WRxCsMKCoJJK)ZQ7msLPHKtUWfJl04ifJPMeICLPHK7xxaghcS9leHarSruY)kfRjVXkDCXcUzBXIXf(YrkgtTGBKxgx4OrszVHTG3mqEzuZSKrutgPK8FwPJlMu2i)NvvMgsoLKITSrgjVx(yUWkje5EuEDj5sSnhxdbfiieuTKtEmoeiaacebcSbc(acYlA)LxdHarj)R5TUSi5rMuA1LhJtUWbWO9FwjSH8KeI8E41lojtsoNXrY)z1DgPY0qYjx4IXfACKIXutcrUY0qYfMjLwD5X4qGi2ik5FLI1K3yLoUyb3STyX4cF5ifJPwWnYlJlC0iPS3WwWBgiVmQzwYiQjJus(pR0XftkBK)ZQktdjNssXw2tgjVx(yUWkje5FnV1LfjFDH4lNoYfoagT)ZkHnKNKqK)ZQ7msLPHKtEp86fNKjjNZ4i5ktdj32VqecmoDqGi2krj)RuSM8gR0XflObYlJlC0iPS3WwWBgiVmQzwYiQjJus(pR0Xftkgi)NvvMgsoLusUhLxxsoLeb]] )


    storeDefault( [[Affliction Primary]], 'displays', 20171209.095746, [[dOJ4gaGEf0lrfSlvPKxlf1mLImBP6MOcDBf1JHQDsP9k2nH9tu(PQyykYVv5yuXqjYGjQgoIoijDnfOdl54OIwOuAPKQSysSCQ6HsHNcwMQKNtXevLIPcLjJknDLUOcDveQUmKRJuBKuzRQsL2SQA7iXhvaBtvQ4Zi47uPrIq5zKQQrJQgpc5KiPBPkvDAuopPSosvXAjvL(MQuQJtWcGxKl7e6oXcRwhf4H4ynr1ogaVix2j0DIfydrX68kGVeeqn4r4nN2aCsJOrQDgbXmsSbWdO98)g02Oix2jmXofGON)3G2gf5YoHj2PaCsJOrCPIFcGnef7GtbMzc1Xy1FaoPr0iUnkYLDctAdO98)g0IvEcO1e7uad)5cUSfNxDmTbm8NRk9EPnGH)Cbx2IZRsVxAdSLNaAvf48Npq7dg2dh1J6aedlGwSV)1Gdgq75)nOLdTMyFVtad)5IvEcO1K2anROkW5pFaShj9OoaXWcWeCz41EEvbo)5dOh1bigwa8ICzNqvGZF(aTpyypCmqJJutMCSlG6)3z4l7eYKR(mgWWFUawAdWjnIg9gMhHVSteqpQdqmSac6zQ4NWeR(dyir9UUEz4BC9ZhSavSobuI1jaHyDc4J1jBad)52Oix2jmrjarp)VbTQ0(k2PafTVW0irbuO))aZfrQ07f7uaLoB4Wb6NRAVhLavNKVa(ZvIYySobQojF14MvQvIYySobEd6x09nTbQUBPzKOiL2auygMcRZwnmnsuaLa4f5YoHANrqeOXOfBuVaCzgYEPHPrIcWnGVeeqyAKOaLcRZwTafTV4itGsBGMv0DIfydrX68kq1j5lSYtaTsuKI1jGh1d0y0InQxadjQ311ldFucuDs(cR8eqReLXyDcWjnIgXLQGldV2ZBsBaGeHZQoByTSte7R3zWa2Agfq9)7m8LDczYL8S5YRfylpb0Q7elSADuGhIJ1ev7yGzMqLEVyNc0SIUtSWQ1rbEiowtuTJbi65)nOLdTMyDcuDs(sT7wAgjksX6eGHFc99U5yDMMcq6zZLxt3jwGnefRZRaKEe(nRuRQutba2CdzYv))odFzNqFKjN0JWVzLAd8pXgqctMCOegzYTL3FUbMlIuhJDkad)eazHZeeIDWaB5jGwjkJrjaPNnxEnQ4NaydrXo4uad)5YbKMctWLjiysBaLoB4Wb6NBucq0Z)BqlvbxgETN3e7uaTN)3GwQcUm8ApVj2PaB5jGwDNydiHjtoucJm52Y7p3ae98)g0IvEcO1e7uad)5svWLHx75nPnGH)CvP9fvX)IsGQ7wAgjkJPnGH)CLOmM2ag(ZvDmTbWVzLALOifLafTVasuVt9nXofOO9LQaN)8bAFWWE4ytJ6WcWjndV53LzGvRJcubMzcal2PaB5jGwDNyb2quSoVcu0(IQ4FyAKOak0)Fa8ICzNq3j2asyYKdLWitUT8(Znq1j5Rg3SsTsuKI1jWOOu6iUPnGHnt2rQpJX(kG2Z)BqRkTVIDkqZk6oXgqctMCOegzYTL3FUbQojFP2DlnJeLXyDcSLNaALOifLa43SsTsugJsa9qDuzqX(AY5TDMCMERxto63jGH)CLOiL2aZfrawSobQojFb8NRefPyDcWjnIgXv3jwGnefRZRaef7uaoPr0iUCO1K2aCr)IUVQsnfayZnKjx9)7m8LDc9rMCUOFr33afTViUGTbi7LgYNnba]] )

    storeDefault( [[Affliction AOE]], 'displays', 20171209.095746, [[dSt3gaGEjQxseAxKQsVwI0mLqnBjDtIGdl13qQGhdv7Ks7vSBc7Ne9tfAyQIFRYZqQKHsudMegoIoij9zeCms54erlurwkPklgflNQEOe8uWYuLSosvXeLqmvOmzI00v6Ik4Qiv5YqUos2iPYwrQiBwvTDe6JseNgvtJuv9DQ0irQQTHurnAuA8QsDsKYTqQuxtcPZtfpNI1IuHUTI6OfSa4n5YpHUtSW6urbgPhwX0Sdb22taTYeLdtaFliGkWIWlntbKKcrHuRCcIzKydGhWz8)nOTqtU8tyI9jW7X)3G2cn5YpHj2NassHOqsPHFcGxgfR(FcmZfQdXsxbKKcrHKwOjx(jmzkGZ4)Bqlw7jGwtSpbmSNl4YxCw1HWeWWEUQu7fMag2ZfC5loRk1EzkW2EcOvvGZE(atJyyJsqpALqFSaVh)FdAL4KjwTaVJ9jGH9CXApb0AYuGszuf4SNpa2OSE0kH(yb4cPC8EpVQaN98b0Jwj0hlaEtU8tOkWzpFGPrmSrjeOWr6Oub2fq9)RC8LFcLkuhhcyypxaltbKKcrHkc3JWx(jcOhTsOpwab1mn8tyIv)bmKOAvxTnSfU65dwGowTa(y1cqiwTamXQLnGH9Cl0Kl)eMWe494)BqRkLVJ9jqt5BmhsuagQ)pWC)wLAVyFcWu5Llxs9CvR1WeORKSnWEUYehIvlqxjz7c3mtVYehIvlqrq)MQUzkqxDBhJmr5mfGi3Wz4v(6G5qIcWeaVjx(juRCcIafgSyd6fqk3qwBhmhsua8a(wqaH5qIc0m8kFDc0u(wcCbktbkLr3jwGxgfR2RaDLKTXApb0ktuowTaEunqHbl2GEbmKOAvxTnSHjqxjzBS2taTYehIvlGKuikKuAcPC8EpVjtbaseoVR8Y9YprSVOZfnGu0VPQRQCXba(CbLku))khF5NqFuQqk63u1nW2EcOv3jwyDQOaJ0dRyA2HaZCHk1EX(eWz8)nOvItMyPBTaoXs3V0Ec0vs2wT62ogzIYXQfORKSnWEUYeLJvlaPNp3EhDNybEzuSAVcq6r43mtVQYfha4ZfuQq9)RC8LFc9rPcspc)Mz6nWC)gWIvlWC)wDi2Nag2ZvMOCMcSTNaALjoeMa6HQO2GI91JgDq7r7rFF9OrxAbmSNReromCHuUGGjtbWVzMELjoeMa4n5YpHUtSaVmkwTxb6kjBRwDBhJmXHy1cukJUtSbKXuQaAHrPcB79NBaNX)3GwvkFh7tad75stiLJ375nzkGH9CvP8nnX)ctGU62ogzIdzkGH9Cvhctad75ktCitbWVzMELjkhMaDLKTlCZm9ktuowTanLVvf4SNpW0ig2OekEqhwGMY30e)dZHefGH6)dmZfawSpb22taT6oXc8YOy1EfqskoEP0jUbwNkkata8MC5Nq3j2aYykvaTWOuHT9(Znqt5BGevR0ksSpbgentfjntbm8zYksDCi2xbEp()g0I1EcO1e7tGT9eqRUtSbKXuQaAHrPcB79NBaNX)3GwAcPC8EpVj2NaVh)FdAPjKYX798MyFcWu5Llxs9CdtaspFU9o0WpbWlJIv)pb44NaiBCUGqSfnW)eBazmLkGwyuQW2E)5gGJFc64DZXQv0assHOqs1DIf4LrXQ9kqPm6oXcRtffyKEyftZoeqskefsQeNmzkGTNrbu))khF5NqPc1XHanLVPNGVbiRTdYNnba]] )


end
