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


local RegisterEvent = ns.RegisterEvent
local RegisterUnitEvent = ns.RegisterUnitEvent

local storeDefault = ns.storeDefault


local PTR = ns.PTR or false

if (select(2, UnitClass('player')) == 'WARLOCK') then

    ns.initializeClassModule = function ()
    
        setClass( "WARLOCK" )
        --setSpecialization( "affliction" )

        -- Resources
        addResource( "mana", nil, false )
        addResource( "soul_shards", nil, true )   
     
        state.seeds_of_corruption = setmetatable( {}, {
            __index = function( t, k, v )
                if k == 'count' then
                    t[ k ] = max( GetSpellCount( state.action.seed_of_corruption.id ), state.active_dot.seed_of_corruption )
                    return t[ k ]
                end
            end } )
            
        --[[ registerCustomVariable( 'soul_shards', 
            setmetatable( {
                start = { 0, 0, 0, 0, 0},
                regen = 7,
                max = 5
            }, { __index = function( t, k )
                if k == 'count' or k == 'actual' or k == 'current' then
                    local ct = 0
                    ct = UnitPower("player",7) -- just get the UP count
                    return ct

                elseif k == 'time_to_next' then
                    local time = state.query_time
                    local rune = 3600

                    for i = 1, 5 do
                        local tts = t.start[i] + t.regen - state.query_time

                        if ttr > 0 then
                            return tts
                        end
                    end
                    return 0

                end

                local ttr = k:match( "time_to_(%d)" )
                if ttr then
                    ttr = min( t.max, ttr )
                    local val = max( 0, t.start[ ttr ] + t.regen - state.query_time )
                    return val
                end

            end } ) )

        addHook( 'timeToReady', function( wait, action )
            local ability = action and class.abilities[ action ]

            if ability and ability.spend_type == "soul_shards" and ability.spend > 0 then
                wait = max( wait, state.soul_shards[ "time_to_" .. ability.spend ] )
            end

            return wait
        end ) ]]

        
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
        addAura( "agony", 980, "duration", 18 )
        addAura( "banish", 710, "duration", 30 )
        addAura( "corruption", 146739, "duration", 14 )
        addAura( "dark_pact", 108416, "duration", 20 )
        addAura( "deadwind_harvester", 216708, "duration", 60 )
        addAura( "demonic_circle", 48018, "duration", 900 )
        addAura( "enslave_demon", 1098, "duration", 300 )
        addAura( "eye_of_kilrogg", 126, "duration", 45 )
        addAura( "mastery_potent_afflictions", 77215 )
        addAura( "ritual_of_summoning", 698 )
        addAura( "soul_leech", 108370 )
        addAura( "tormented_souls", 216695, "duration", 3600, "max_stack", 12 )
        addAura( "unending_resolve", 104773, "duration", 8 )
        addAura( "seed_of_corruption", 27243, "duration", 18 )
        addAura( "siphon_life", 63106, "duration", 15 )
        addAura( "soul_effigy", 205178, "duration", 600 )
        addAura( "soulstone", 20707, "duration", 900 )
        addAura( "unending_breath", 5697, "duration", 600 )
        addAura( "unstable_affliction", 30108, "duration", 8, "max_stack", 5 )
            modifyAura( "unstable_affliction", "duration", function( x ) return x * haste end )


        -- Options.
        addToggle( 'artifact_ability', true, 'Artifact Ability', 'Set a keybinding to toggle your artifact ability on/off in your priority lists.' )

        addSetting( 'artifact_cooldown', true, {
            name = "Artifact Ability: Cooldown Override",
            type = "toggle",
            desc = "If |cFF00FF00true|r, when your Cooldown toggle is |cFF00FF00ON|r then the toggle for artifact ability will be overriden and your Artifact Ability will be shown regardless of your Artifact Ability toggle.",
            width = "full"
        } )


        ignoreCastOnReset( "drain_soul" ) -- testing for breaking channels.


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
            cast = 6,
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
        } )

        addHandler( "life_tap", function ()
            gain( mana.max * 0.3, "mana" )
            gain( health.max * -0.1, "health" )
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
            usable = function () return buff.tormented_souls.up and equipped.ulthalesh_the_deadwind_harvester and ( toggle.artifact_ability or ( toggle.artifact_cooldown and toggle.cooldowns ) ) end,
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
            applyBuff( "target", "soulstone", 900 )
        end )


        -- Summon Doomguard
        --[[ Summons a Doomguard under the command of the Warlock.    The Doomguard deals strong damage to a single target at a time. ]]

        addAbility( "summon_doomguard", {
            id = 157757,
            spend = 1,
            min_cost = 1,
            spend_type = "soul_shards",
            cast = 2.5,
            gcdType = "spell",
            cooldown = 0,
            min_range = 0,
            max_range = 0,
        } )

        modifyAbility( "summon_doomguard", "cast", function( x ) return x * haste end )

        addHandler( "summon_doomguard", function ()
            summonPet( "doomguard", 3600 )
        end )


        -- Summon Infernal
        --[[ Summons an Infernal under the command of the Warlock.    The Infernal deals strong area of effect damage. ]]

        addAbility( "summon_infernal", {
            id = 157898,
            spend = 1,
            min_cost = 1,
            spend_type = "soul_shards",
            cast = 2.202,
            gcdType = "spell",
            cooldown = 0,
            min_range = 0,
            max_range = 0,
        } )

        addHandler( "summon_infernal", function ()
            summonPet( "doomguard", 3600 )
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
            applyDebuff( "target", "unstable_affliction", 8 * haste, min( 5, debuff.unstable_affliction.stack + 1 ) )
        end )
    end


    storeDefault( [[Affliction Default SimC]], 'actionLists', 20170512.231704, [[deey1aqiLqBcQmkLKtPeTkOK8krfAwqjv0UuQHbvDmiAzqONbLAAKQ6AIkABIk4BKQmoOe5CqjuZdsCpeX(GahesAHKIEiPWeHsixuuvBekPcNuuLzcLGBcP2jrnuOKQwQOspvYurKUkuIARkb7f1FLQbdfDyQwmcpMstwKlRAZe8ze1OffNg0RvsnBsUTu2TIFdmCICCOKYYr65umDHRtOTtQ8DiOZlkTEOKknFsP9dfMrYKYv(JtOEIj4s2BNlufeuqBabdgyIfDbxufyGzbBAWvUxD3Cwgr8i1dForICJKRYsHsbxCHQnGGXWKYYizs5k)XjupXAYvzPqPGRWvFInzkSbG03bcDJOe9n3MD)XjupHZPbuWTXwbOPoqOlO82nBQpRraEUqLaQGrwUmITgy6Wr40XvCPrMBxJgO7TpbtWfAqAbNk7TZfxYE7CvITgyWaZ8gHthxXvUxD3Cwgr8i1djEUYBsqRhakxdyoxObjzVDU4GLrKjLR8hNq9eRjxLLcLcUcx9j2KPWgasFhi0nIs03CB29hNq9eo3gqDV)5n4niajxOsavWilxgXwdmD4iC64kU0iZTRrd092NGj4cniTGtL925IlzVDUkXwdmyGzEJWPJRWaZvixYvUxD3Cwgr8i1djEUYBsqRhakxdyoxObjzVDU4GLXMjLR8hNq9eRjxLLcLcUcx9j2KPWgasFhi0nIs03CB29hNq9eo3gqDV)5n4nKGeNtdOGBJTcqtDGqxq5TB2uFwtcEUqLaQGrwUmITgy6jaOrw0PjU0iZTRrd092NGj4cniTGtL925IlzVDUkXwdmyGjwea0il60ex5E1DZzzeXJupK45kVjbTEaOCnG5CHgKK925IdwwFMuUYFCc1tSMCvwkuk4kC1Ny)MeaHN(uxbfEpCP9hNq9eUfjefe2Vjbq4Pp1vqH3dxAlkXfQeqfmYYLck8E4sCPrMBxJgO7TpbtWfAqAbNk7TZfxYE7CHfGchdmj1L4k3RUBolJiEK6Hepx5njO1daLRbmNl0GKS3oxCWY5KjLR8hNq9eRjxOsavWilxsGacgUYBsqRhakxdyoxObPfCQS3oxjQ)bA7WjUsDBWLS3oxy9GacgUqLs2W14TtsI6FG2oCIRu3gCL7v3nNLreps9qINlnYC7A0aDV9jycUqdsYE7CLO(hOTdN4k1TbhSCoWKYv(JtOEI1KRYsHsbxlsikiSt3tieoPEgNQ7M40TOeUveIccBdqu1Z4uD3eB6BoCmiiN54XAIqjPN2i1xFSZb9XkK7CIBXWvFIDZvxaA7KPUrA)XjupHJquqy72aQ7Dr3SnHBxJaKA1sikiSdaT9jEQBaIkZME3giGeSKwTHtj)yhW27bONGhfsiefe2bG2(ep1narLztVBdSkN54XAIqjPN2i1xFSZb9XkK7CQv7IHR(e7MRUa02jtDJ0(JtOEc3QGcN1p2suGD7t2TOKwTbfoRFSnHBxdhYDjkWU9j7wuA5sUqLaQGrwUO3L6gGOYWLgzUDnAGU3(embxObPfCQS3oxCj7TZvU3LWaZciQmCL7v3nNLreps9qINR8Me06bGY1aMZfAqs2BNloyz9ys5k)XjupXAYvzPqPGl6BoCmOqsaTR7bS9CKSnXfQeqfmYYLtgmz5kVjbTEaOCnG5CHgKwWPYE7CXLS3oxOsgmz5sJSw1j1PKFyyn5k3RUBolJiEK6HepxOsjB4YM1QEpCk5hgsqYLgzUDnAGU3(embxObjzVDU4GLXsmPCL)4eQNyn5QSuOuW1IHR(eBYuydaPVde6grj6BUn7(JtOEcNBdOU3)8g8MTrS1athocNoUcfsqe3QWPKFSdy79a0tWJaKyj8A1goL8JDM7QiZwYgOqcI41QnCk5h7a2Epa9e8OGn(LCHkbubJSCzeBnW0taqJSOttCPrMBxJgO7TpbtWfAqAbNk7TZfxYE7CvITgyWatSiaOrw0PjmWCfYLCL7v3nNLreps9qINR8Me06bGY1aMZfAqs2BNloyzSyMuUYFCc1tSMCvwkuk4AXWvFInzkSbG03bcDJOe9n3MD)XjupHZTbu37FEdEZ2i2AGPdhHthxHae5cvcOcgz5Yi2AGPdhHthxXLgzUDnAGU3(embxObPfCQS3oxCj7TZvj2AGbdmZBeoDCfgyUcXLCL7v3nNLreps9qINR8Me06bGY1aMZfAqs2BNloyzK4zs5k)XjupXAYvzPqPGRWvFInzkSbG03bcDJOe9n3MD)XjupHZTbu37FEdEZ2i2AGPdhHthxrcsChRjcLKEABGtcqpSBKGXXTOfaujacNTboja9WUrcgVdTPn9nhogeGNlujGkyKLlJyRbMEcaAKfDAIlnYC7A0aDV9jycUqdsl4uzVDU4s2BNRsS1adgyIfbanYIonHbMRqCjx5E1DZzzeXJupK45kVjbTEaOCnG5CHgKK925IdwgjsMuUYFCc1tSMCvwkuk4kC1NytMcBai9DGq3ikrFZTz3FCc1t4CBa19(N3G3SnITgy6Wr40XviajUJ1eHsspTnWjbOh2nsW44w0caQeaHZ2aNeGEy3ibJ3H20M(MdhdcWZfQeqfmYYLrS1athocNoUIlnYC7A0aDV9jycUqdsl4uzVDU4s2BNRsS1adgyM3iC64kmWCf2l5k3RUBolJiEK6Hepx5njO1daLRbmNl0GKS3oxCWYirKjLR8hNq9eRjxLLcLcUKOxxNSnTrUfht4eQ3Dbbf0gqWOvlHOGW2aev9mov3nXM(MdhdcibjEUqLaQGrwUio1C6A4qMlnYC7A0aDV9jycUqdsl4uzVDU4s2BNlnp1C6A4qMRCV6U5SmI4rQhs8CL3KGwpauUgWCUqdsYE7CXblJeBMuUYFCc1tSMCHgKwWPYE7CXLS3oxAQaGegyI1HinlxOsavWilxekai1fePz5k3RUBolJiEK6HepxAK521Ob6E7tWeCL3KGwpauUgWCUqdsYE7CXblJuFMuUYFCc1tSMCHgKwWPYE7CXLS3oxOsT(CmWKuaL(j4cvcOcgz5YPwFEpau6NGRCV6U5SmI4rQhs8CPrMBxJgO7TpbtWvEtcA9aq5AaZ5cnij7TZfhSmYCYKYv(JtOEI1KRYsHsbxlgU6tSnarvpJt1DtS)4eQNWTkOWz9JTefy3(KDlkPvBqHZ6hBt421DjkWU9j7wusR2WPKFSdy79a0tWJcj6HxR2fTaGkbq4SZ4ItSPV5WXGa8A1sikiSDBa19UOB2MWTRraIl5cvcOcgz5sceqWWvEtcA9aq5AaZ5cniTGtL925sIcuGH8tDjacpLlzVDUW6bbemyG5kKl5cvkzdxJ3ojsuGcmKFQlbq4PCL7v3nNLreps9qINlnYC7A0aDV9jycUqdsYE7CjrbkWq(PUeaHNYblJmhys5k)XjupXAYvzPqPGRWvFITbiQ6zCQUBI9hNq9eocrbHTbiQ6zCQUBITOeUvbfoRFSLOa72NSBrjTAdkCw)yBc3UUlrb2Tpz3IsA1goL8JDaBVhGEcEuirp8A1UOfaujacNDgxCIn9nhogeGxRwcrbHTBdOU3fDZ2eUDncqCjxOsavWilxsGacgUYBsqRhakxdyoxObPfCQS3oxsuGcmKFQlbq4PCj7TZfwpiGGbdmxH4sUqLs2W14TtIefOad5N6saeEkx5E1DZzzeXJupK45sJm3Ugnq3BFcMGl0GKS3oxsuGcmKFQlbq4PCWYi1JjLR8hNq9eRjxLLcLcUOV5WXGcjb0UUhW2ZrY2eUvRCBa19(N3G3Gc24m)jthi0TakvukGGzBbItGc2lXfU6tSnae2JmVB(tM9hNq9KwTRCBa19(N3G3GI(4m)jthi0TakvukGGzBbItGI(lxIBfHOGW2Tbu37IUzBc3UgfeXzaIQUjJttMTvKs)eKGxR2fdx9j2nxDbOTtM6gP9hNq90sUqLaQGrwUSakvukGGHlnYC7A0aDV9jycUqdsl4uzVDU4s2BNlnauQOuabdx5E1DZzzeXJupK45kVjbTEaOCnG5CHgKK925IdwgjwIjLR8hNq9eRjxLLcLcUwfU6tSDcdqjgVBbuQOuabZ(JtOEsR2fdx9j2nxDbOTtM6gP9hNq9KwTlgU6tSnarv)ccqYz3FCc1tlX52aQ79pVbVbbiXrFZHJbfscODDpGTNJKTjCRw52aQ79pVbVbfSXz(tMoqOBbuQOuabZ2ceNafSxIlC1NyBaiShzE38Nm7poH6jTAx52aQ79pVbVbf9Xz(tMoqOBbuQOuabZ2ceNaf9xUKlujGkyKLllGsfLciy4kVjbTEaOCnG5CHgKwWPYE7CXLS3oxAaOurPacgmWCfYLCPrwR6K6uYpmSMCL7v3nNLreps9qINluPKnCzZAvVhoL8ddji5sJm3Ugnq3BFcMGl0GKS3oxCWYiXIzs5k)XjupXAYvzPqPGl6BoCmOqsaTR7bS9CKSnHBfHOGW2Tbu37IUzBc3UgfeXzaIQUjJttMTvKs)eKGxR2fdx9j2nxDbOTtM6gP9hNq90sUqLaQGrwUmqPmGPRGcNlnYC7A0aDV9jycUqdsl4uzVDU4s2BNRckLbmyGjwakCUY9Q7MZYiIhPEiXZvEtcA9aq5AaZ5cnij7TZfhSmI4zs5k)XjupXAYvzPqPGRvlgU6tSBU6cqBNm1ns7poH6jTAxmC1NyBaIQ(feGKZU)4eQNwIZTbu37FEdEdcqIJ(MdhdkKeq76EaBphjBtCHkbubJSCzGszatxbfox5njO1daLRbmNl0G0cov2BNlUK925QGszadgyIfGchdmxHCjxAK1QoPoL8ddRjx5E1DZzzeXJupK45cvkzdx2Sw17Htj)WqcsU0iZTRrd092NGj4cnij7TZfhSmIizs5k)XjupXAYvzPqPGRWvFI9BsaeE6tDfu49WL2FCc1t4iefe2Vjbq4Pp1vqH3dxAtFZHJbfsiBtCHkbubJSCPGcVhUexAK521Ob6E7tWeCHgKwWPYE7CXLS3oxybOWXatsDjmWCfYLCL7v3nNLreps9qINR8Me06bGY1aMZfAqs2BNloyzerKjLR8hNq9eRjxLLcLcUwmC1Ny3C1fG2ozQBK2FCc1t4OV5WXGcjiXsyf(n24cNs(XoGT3dqpbpciH(MdhdxOsavWilxozWKLR8Me06bGY1aMZfAqAbNk7TZfxYE7CHkzWKfdmxHCjxAK1QoPoL8ddRjx5E1DZzzeXJupK45cvkzdx2Sw17Htj)WqcsU0iZTRrd092NGj4cnij7TZfhSmIyZKYv(JtOEI1KRYsHsbx03C4yqHeKyjSc)gBCHtj)yhW27bONGhbKqFZHJbhHOGW2Tbu37IUzBc3UMe8CHkbubJSC5KbtwUYBsqRhakxdyoxObPfCQS3oxCj7TZfQKbtwmWCfIl5sJSw1j1PKFyyn5k3RUBolJiEK6HepxOsjB4YM1QEpCk5hgsqYLgzUDnAGU3(embxObjzVDU4GLruFMuUYFCc1tSMCvwkuk4kC1Ny)MeaHN(uxbfEpCP9hNq9eocrbH9BsaeE6tDfu49WL203C4yqjjs9acgSc)gBTAdx9j2nxDbOTtM6gP9hNq9eUWPKFSdy79a0tWJaK5exZhFlzduqINlujGkyKLlfu49WL4sJm3Ugnq3BFcMGl0G0cov2BNlUK925clafogysQlHbMRqCjx5E1DZzzeXJupK45kVjbTEaOCnG5CHgKK925IdwgXCYKYv(JtOEI1KRYsHsbxHR(eBdaH9iZ7M)Kz)XjupHBLBdOU3)8g8geqc24m)jthi0TakvukGGzBbItGasWEPwTRCBa19(N3G3Gas0hN5pz6aHUfqPIsbemBlqCceqI(l1QDLBdOU3)8g8gsWgN5pz6aHUfqPIsbemBlqCcsWEjUei2waLkkfqWSPV5WXGcjw3e9a2Eogux3v9a2oxOsavWilxM)uhi0TakvukGGHlnYC7A0aDV9jycUqdsl4uzVDU4s2BNR6pHbMabmWudaLkkfqWWvUxD3Cwgr8i1djEUYBsqRhakxdyoxObjzVDU4GLrmhys5k)XjupXAYvzPqPGRfdx9j2nxDbOTtM6gP9hNq9eo6BoCmOqcs9Xk8BSXfoL8JDaBVhGEcEeqc9nhogUqLaQGrwUSakvukGGHlnYC7A0aDV9jycUqdsl4uzVDU4s2BNlnauQOuabdgyUcXLCL7v3nNLreps9qINR8Me06bGY1aMZfAqs2BNloyze1JjLR8hNq9eRjxLLcLcUOV5WXGcji1hRWVXgx4uYp2bS9Ea6j4raj03C4yWrikiSDBa19UOB2MWTRjbpxOsavWilxwaLkkfqWWLgzUDnAGU3(embxObPfCQS3oxCj7TZLgakvukGGbdmxH9sUY9Q7MZYiIhPEiXZvEtcA9aq5AaZ5cnij7TZfhSmIyjMuUYFCc1tSMCvwkuk4Av4QpX2jmaLy8UfqPIsbem7poH6jTAxmC1Ny3C1fG2ozQBK2FCc1tA1Uy4QpX2aev9liajND)XjupTeh9nhoguibP(yf(n24cNs(XoGT3dqpbpciH(MdhdxOsavWilxwaLkkfqWWvEtcA9aq5AaZ5cniTGtL925IlzVDU0aqPIsbemyG5k9xYLgzTQtQtj)WWAYvUxD3Cwgr8i1djEUqLs2WLnRv9E4uYpmKGKlnYC7A0aDV9jycUqdsYE7CXblJiwmtkx5poH6jwtUklfkfCTy4QpXU5QlaTDYu3iT)4eQNWrFZHJbfsqMtSc)gBCHtj)yhW27bONGhbKqFZHJHlujGkyKLldukdy6kOW5sJm3Ugnq3BFcMGl0G0cov2BNlUK925QGszadgyIfGchdmxH4sUY9Q7MZYiIhPEiXZvEtcA9aq5AaZ5cnij7TZfhSm24zs5k)XjupXAYvzPqPGl6BoCmOqcYCIv43yJlCk5h7a2Epa9e8iGe6BoCm4iefe2UnG6Ex0nBt421KGNlujGkyKLldukdy6kOW5sJm3Ugnq3BFcMGl0G0cov2BNlUK925QGszadgyIfGchdmxH9sUY9Q7MZYiIhPEiXZvEtcA9aq5AaZ5cnij7TZfhSm2izs5k)XjupXAYvzPqPGRvlgU6tSBU6cqBNm1ns7poH6jTAxmC1NyBaIQ(feGKZU)4eQNwIJ(MdhdkKGmNyf(n24cNs(XoGT3dqpbpciH(MdhdxOsavWilxgOugW0vqHZvEtcA9aq5AaZ5cniTGtL925IlzVDUkOugWGbMybOWXaZv6VKlnYAvNuNs(HH1KRCV6U5SmI4rQhs8CHkLSHlBwR69WPKFyibjxAK521Ob6E7tWeCHgKK925IdwgBezs5k)XjupXAYvzPqPGRvlgU6tSnae2JmVB(tM9hNq9KwTRCBa19(N3G3Gc24m)jthi0TakvukGGzBbItGc2lxIlC1NyNXfNy)XjupHBLbiQ6Mmonz2wrk9tGas0xR20jefe2zCXj203C4yqqoSZPwTHtj)yhW27bONGhfSXVKlujGkyKLlXXeoH6DxqqbTbemCPrMBxJgO7TpbtWfAqAbNk7TZfxYE7CHLht4eQJbMOkiOG2acgUY9Q7MZYiIhPEiXZvEtcA9aq5AaZ5cnij7TZfhSm2yZKYv(JtOEI1KRYsHsbxRwmC1NyBaiShzE38Nm7poH6jTAx52aQ79pVbVbfSXz(tMoqOBbuQOuabZ2ceNafSxUe3k3gqDV)5n4nOOpoZFY0bcDlGsfLciy2wG4eOO)sCHR(eBesHrM3Ht3jdMS7poH6jCHR(eBlycNmem7poH6jCjqSfht4eQ3Dbbf0gqW0rUPV5WXGI1nrpGTJlbIT4ycNq9UliOG2acMoIB6BoCmOyDt0dy74sGyloMWjuV7cckOnGGPJ9M(Mdhdkw3e9a2oUei2IJjCc17UGGcAdiy66VPV5WXGI1nrpGTJlbIT4ycNq9UliOG2acMEo303C4yqX6MOhW25cvcOcgz5sCmHtOE3feuqBabdxAK521Ob6E7tWeCHgKwWPYE7CXLS3oxy5XeoH6yGjQcckOnGGbdmxHCjx5E1DZzzeXJupK45kVjbTEaOCnG5CHgKK925IdwgB9zs5k)XjupXAYvzPqPGRvlgU6tSnae2JmVB(tM9hNq9KwTRCBa19(N3G3Gc24m)jthi0TakvukGGzBbItGc2lxIBLBdOU3)8g8gu0hN5pz6aHUfqPIsbemBlqCcu0FjUWvFIncPWiZ7WP7Kbt29hNq9eUvgGOQBY40KzBfP0pbcirFTAdkCw)ylrb2nCIRu3gBrjTAdkCw)yBc3UgoK7suGD3CtCA2TOKwTbfoRFSLOa7U5M40SBrjTAdkCw)ylrb2TLcJTOKwTbfoRFSLOa7w3PgpGkyKDlkPvlHOGW2aev9mov3nXwusRwcrbHD6EcHWj1Z4uD3eNUfL0QLquqyBbnjG4KGd5EgaLcOB6DBqso1QnCk5h7a2Epa9e8OqcI4xYfQeqfmYYL4ycNq9UliOG2acgU0iZTRrd092NGj4cniTGtL925IlzVDUWYJjCc1XatufeuqBabdgyUcXLCL7v3nNLreps9qINR8Me06bGY1aMZfAqs2BNloyzSZjtkx5poH6jwtUklfkfCTAXWvFITbGWEK5DZFYS)4eQN0QDLBdOU3)8g8guWgN5pz6aHUfqPIsbemBlqCcuWE5sCRCBa19(N3G3GI(4m)jthi0TakvukGGzBbItGI(lXfU6tSBU6cqBNm1ns7poH6jCRcNs(XoGT3dqpbpkyJxRwj611jBtBKBXXeoH6DxqqbTbem4marv3KXPjZ2ceNabKO)sUqLaQGrwUeht4eQ3Dbbf0gqWWLgzUDnAGU3(embxObPfCQS3oxCj7TZfwEmHtOogyIQGGcAdiyWaZvyVKRCV6U5SmI4rQhs8CL3KGwpauUgWCUqdsYE7CXblJDoWKYv(JtOEI1KRYsHsbxRwmC1NyBaiShzE38Nm7poH6jTAx52aQ79pVbVbfSXz(tMoqOBbuQOuabZ2ceNafSxUe3k3gqDV)5n4nOOpoZFY0bcDlGsfLciy2wG4eOO)sCHR(e7MRUa02jtDJ0(JtOEc3kdqu1nzCAYSTIu6NGKCQvB4QpX2cMWjdbZ(JtOEcNbiQ6MmonHas0FjxOsavWilxIJjCc17UGGcAdiy4sJm3Ugnq3BFcMGl0G0cov2BNlUK925clpMWjuhdmrvqqbTbemyG5k9xYvUxD3Cwgr8i1djEUYBsqRhakxdyoxObjzVDU4GLXwpMuUYFCc1tSMCvwkuk4A1IHR(eBdaH9iZ7M)Kz)XjupPv7k3gqDV)5n4nOGnoZFY0bcDlGsfLciy2wG4eOG9YL4w52aQ79pVbVbf9Xz(tMoqOBbuQOuabZ2ceNaf9xIlC1Ny3C1fG2ozQBK2FCc1t4wfU6tSnarv)ccqYz3FCc1tA1ESMius6PTeaHN2TaAQde6QhzIpjk0Se3Is0RRt2M2yVfht4eQ3Dbbf0gqWGtIEDDY20g5wCmHtOE3feuqBabdxOsavWilxIJjCc17UGGcAdiy4sJm3Ugnq3BFcMGl0G0cov2BNlUK925clpMWjuhdmrvqqbTbemyG5QCUKRCV6U5SmI4rQhs8CL3KGwpauUgWCUqdsYE7CXblJnwIjLR8hNq9eRjxLLcLcUwTy4QpX2aqypY8U5pz2FCc1tA1UYTbu37FEdEdkyJZ8NmDGq3cOurPacglqCcuWE5sCRCBa19(N3G3GI(4m)jthi0TakvukGGzBbItGI(lXfU6tSBU6cqBNm1ns7poH6jChRjcLKEAlbq4PDlGM6aHU6rM4tIcn4iefe2UnG6Ex0nBt421KGNlujGkyKLlXXeoH6DxqqbTbemCPrMBxJgO7TpbtWfAqAbNk7TZfxYE7CHLht4eQJbMOkiOG2acgmWCvoSKRCV6U5SmI4rQhs8CL3KGwpauUgWCUqdsYE7CXblJnwmtkx5poH6jwtUklfkfCTAXWvFITbGWEK5DZFYS)4eQN0QDLBdOU3)8g8guWgN5pz6aHUfqPIsbemBlqCcuWE5sCRCBa19(N3G3GI(4m)jthi0TakvukGGzBbItGI(lXfU6tSBU6cqBNm1ns7poH6jCHR(eBdqu1VGaKC29hNq9eUfpwtekj90wcGWt7wan1bcD1JmXNefAWrikiSDBa19UOB2MWTRjbpUei2ozWKDtFZHJbbw3e9a2owHDoMd7CIB1IHR(eBdqu1VGaKC29hNq9KwTsp2gGOQFbbi5S7ei2ozWKDtFZHJbbw3e9a2owHDoMd7CUKlujGkyKLlXXeoH6DxqqbTbemCPrMBxJgO7TpbtWfAqAbNk7TZfxYE7CHLht4eQJbMOkiOG2acgmWCLEl5k3RUBolJiEK6Hepx5njO1daLRbmNl0GKS3oxCWY6JNjLR8hNq9eRjxLLcLcUwTy4QpX2aqypY8U5pz2FCc1tA1UYTbu37FEdEdkyJZ8NmDGq3cOurPacMTfiobkyVCjUvUnG6E)ZBWBqrFCM)KPde6waLkkfqWSTaXjqr)L4cx9j2nxDbOTtM6gP9hNq9eUfdx9j2gGOQFbbi5S7poH6jClESMius6PTeaHN2TaAQde6QhzIpjk0GBrj611jBtBS3IJjCc17UGGcAdiyWLaX2jdMSB6BoCmiW6MOhW2XkSZXCyNtCRsGyBbuQOuabZM(MdhdcSUj6bS9Cmh25uR2WvFITtyakX4DlGsfLciy2FCc1tl5cvcOcgz5sCmHtOE3feuqBabdxAK521Ob6E7tWeCHgKwWPYE7CXLS3oxy5XeoH6yGjQcckOnGGbdmxHLwYvUxD3Cwgr8i1djEUYBsqRhakxdyoxObjzVDU4GL1hjtkx5poH6jwtUklfkfCTiHOGWoDpHq4K6zCQUBIt3Is4iefe2UnG6Ex0nBt421iajUvRwmOWz9JDg30nHBxdhYDt4X2NS4wmOWz9JDg30nHhBFYUuR2WvFIDZvxaA7KPUrA)XjupTKlujGkyKLl6DPUbiQmCPrMBxJgO7TpbtWfAqAbNk7TZfxYE7CL7DjmWSaIkdgyUc5sUY9Q7MZYiIhPEiXZvEtcA9aq5AaZ5cnij7TZfhSS(iYKYv(JtOEI1KRYsHsbxlsikiSt3tieoPEgNQ7M40TOeoj611jBtBKBXXeoH6DxqqbTbem4wTAXGcN1p2zCt3eUDnCi3nHhBFYIBXGcN1p2zCt3eES9j7sTAdx9j2nxDbOTtM6gP9hNq90sCeIcc7aqBFIN6gGOYSP3TbcqYfQeqfmYYf9Uu3aevgU0iZTRrd092NGj4cniTGtL925IlzVDUY9UegywarLbdmxH4sUY9Q7MZYiIhPEiXZvEtcA9aq5AaZ5cnij7TZfhSS(yZKYv(JtOEI1KRYsHsbxnF8TKnqHeK45cvcOcgz5sbfEpCjU0iZTRrd092NGj4cniTGtL925IlzVDUWcqHJbMK6syG5kSxYvUxD3Cwgr8i1djEUYBsqRhakxdyoxObjzVDU4GL1xFMuUYFCc1tSMCHkbubJSCLOoC6gGOIR8Me06bGY1aMZfAqAbNk7TZfxYE7CHfrD4GbMfquXfQuYgUSzC4qcsSoHtCkvukibjx5E1DZzzeXJupK45QYaqiAqckap1WAYLgzUDnAGU3(embxObjzVDU4GL1pNmPCL)4eQNyn5cniTGtL925IlzVDUWcqHJbMK6syG5k9xYfQeqfmYYLck8E4sCL7v3nNLreps9qINlnYC7A0aDV9jycUYBsqRhakxdyoxObjzVDU4GdUkPBHUcI11diyyzeZHCYbZ]] )


    storeDefault( [[Affliction Primary]], 'displays', 20170512.231704, [[dOt2gaGEPQEjPGDPQu8APkMjvvnBPCtOQ62kQhJODsP9k2nH9tu(PImmvv)wLdlzOOYGjQgosDqsmnsHoMu54erlublLu0IjPLtLhsv5PGLPQ45umrvLmvOmzI00v6Ik0vjcUmKRJWgjL2QQsPnRkBhj(OuLEMQsvFgQ8DQYijcDAugnQA8qvojs6wqvPRrvLZtQ(guv0AvvQSnOQWPlybil6LDcTNyHvVHcmjbm)PAhdqw0l7eApXcS(Oy7(eWvcCiF8iYEYqajjqeiLgdNygj2aKb0NEpdA9v0l7eMy)dG307zqRVIEzNWe7FajjqeiPujpbW6JIvJ)bMzcLXy)(assGiqs9v0l7eMmeqF69mOfRC4qRj2)ag(Zd8yljVYygcy4ppfI9Yqad)5bESLKxHyVmeylho0Qii5pxGHjmSj8Rj1ELiwa9yX3p(5xa9P3ZGwnmyIfF7cy4ppSYHdTMmeOhvfbj)5cGnXPj1ELiwaMqkJS2ZPii5pxanP2ReXcqw0l7ekcs(ZfyycdBc)b8D06YKJDbuEVgJCzNqMCLPXag(ZdWYqajjqeOVyoe5YoranP2ReXciiMPsEctSAmGHg1AABLH331oxWcuX2fWfBxaCX2fqn2USbm8NNVIEzNWe1a4n9Eg0Qq4Qy)dueUctNgfqL49cmx4PqSxS)buBS(97TDEkTwudunA(c4ppokJX2fOA08LVBwTwokJX2f4l0RiABudunVs3WrHldbOWmmvwJT6y60OaQbil6LDcLgdNiGVrl2OMbKYm0TshtNgfqAaxjWHW0PrbkvwJT6bkcxHFMaLHa9OQ9elW6JIT7tGQrZxyLdhA5OWfBxahQfW3OfBuZagAuRPTvg(OgOA08fw5WHwokJX2fqscebskvHugzTNZKHaanIKvnw)AzNi2p4d)cif9kI2QW5FaL3RXix2jKj)l0RiARm5aB2xGTC4qR2tSWQ3qbMKaM)uTJbMzcfI9I9paEX(haVP3ZGwnmyITlq1O5lLMxPB4OWfBxGQrZxa)5XrHl2Ua0o2C501EIfy9rX29jaTdrEZQ1QW5FaL3RXix2jKj)l0RiARm5aB2xG5cpal2UaZfEkJX(hqtudvguGp)D4ZF)6(8nDb2YHdTCugJAad)5PbKUktiLjWzYqad)5XrHldb2YHdTCu4IAaYBwTwokJrnq1O5lLMxPB4OmgBxGEu1EInahMm5qjmYKBlN78cOp9Eg0Qq4Qy)dy4ppQcPmYApNjdbm8NNcHROkExudunVs3Wrzmdbm8NNYygcy4ppokJzia5nRwlhfUOgOA08LVBwTwokCX2fOiCLIGK)CbgMWWMWV)JAXcueUIQ4Dy60OaQeVxGzMaWI9pWwoCOv7jwG1hfB3NassWi75Bzgy1BOavaYIEzNq7j2aCyYKdLWitUTCUZlqr4kGg1Au)k2)aJIsTHKMHag2mDdPmng7Na4n9Eg0IvoCO1e7FGTC4qR2tSb4WKjhkHrMCB5CNxa9P3ZGwQcPmYApNj2)a4n9Eg0sviLrw75mX(hqTX63V325f1a0o2C50PsEcG1hfRg)dWipbqxKmbUy9lW7eBaomzYHsyKj3wo35fGrEIV7U5y78lGKeicKuTNybwFuSDFc0JQ2tSWQ3qbMKaM)uTJbKKarGKQHbtgcyRzuaL3RXix2jKjNZXMlNEGIWvsqW2a0Tsh5YMa]] )

    storeDefault( [[Affliction AOE]], 'displays', 20170512.231704, [[dOt1gaGEf4Leb7cPI61ssMPcYSL4MKuCBf1HLANuAVIDty)ePFQqdtv1Vv5Xq1qjQbtsgosoijEgsL4yuXXjIwOISusQwmkwov9qjXtbltvXZPyIkOMkuMmPy6kDrj1vrQQld56iAJKsBfPISzvz7iLpkj12qQGPrsPVtLgjsvonQgnknEvLojcDlKk11icDEs1NrWArQqFdPs64eSa4n1YpH2tSWQxqbgPp2qeT1b22taTY0KdtaFliGQWIWRktbKKerIukCcIzKydGhqF89mOTstT8tyI9pW3X3ZG2kn1YpHj2)assIirAiIFcGpafRA)dmZfk1XsxcijjIePPstT8tyYua9X3ZGwS2taTMy)dyypxWLV4Sk1HjGH9Cvi3lmbmSNl4YxCwfY9YuGT9eqRIaN98bMgXWgvJ6eRMEyb(o(Eg0kHjtSob(g7Fad75I1EcO1KPavXOiWzpFaSrz1jwn9WcWfA449EEfbo75dOoXQPhwa8MA5NqrGZE(atJyyJQjqLJsxQkSlGY7v44l)esvPmwhWWEUawMcijjIenm3JWx(jcOoXQPhwab5mr8tyIvTbmuOsrBPnSvUY5dwGowNamX6eGqSob8X6KnGH9CR0ul)eMWe4747zqRcPVJ9pqt6BmDkuagY3lWC)vHCVy)dWu4dguD5CvkLWeOluSnWEUY0QJ1jqxOy7k3mtVY0QJ1jWWOxtw2WeOlUTUrMMCMcqJB4m8cF1X0PqbycG3ul)ekfobrGk1wSA1dOHBOkToMofkaEaFliGW0PqbAgEHV6bAsFRgUaLPavXO9elWhGI15tGUqX2yTNaALPjhRtapQeOsTfRw9agkuPOT0g2WeOluSnw7jGwzA1X6eqssejsdrHgoEVN3KPaafcN3f(GE5Ni2p0bjgW2ZOakVxHJV8tivLYyDGT9eqR2tSWQxqbgPp2qeT1bM5cfY9I9pqvmApXcREbfyK(ydr0whqpw6(JZFGUqX2kf3w3ittowNaC8tqhVBowhjgGYZNBVU2tSaFakwNpbO8i8BMPxf5HcO8Efo(YpHuvdJEnzzLQc4Zvc8oXgqgtQkOfgPQST3FUbM7Vk1X(hGJFcGQX5ccXkXaB7jGwzA1HjaLNp3EDI4Na4dqXQ2)aQJkO2Gc853HU(lrNp0zNamf(Gbvxo3We4747zqlrHgoEVN3e7Fa9X3ZGwIcnC8EpVj2)aB7jGwTNydiJjvf0cJuv227p3aFhFpdAXApb0AI9pGH9Cjk0WX798MmfWWEUkK(MO4DHjqxCBDJmT6mfWWEUY0QZuad75QuhMa43mtVY0KdtGM03afQuioCS)bAsFRiWzpFGPrmSr1muTwSassYXRIoXnWQxqbycmZfawS)b22taTApXc8bOyD(eOj9nrX7W0PqbyiFVa4n1YpH2tSbKXKQcAHrQkB79NBGUqX2vUzMELPjhRtGArZuqAYuadFMQGugRJ9ta9X3ZGwfsFh7FGQy0EInGmMuvqlmsvzBV)Cd0fk2wP426gzA1X6eaVPw(j0EIf4dqX68ja(nZ0RmT6WeWWEUY0KZuad75kbKodxOHliyYuG5(lGfRtGUqX2a75kttowNassIirA0EIf4dqX68jG(47zqReMmXs3obKKerI0iHjtMcOb9AYYQipuaL3RWXx(jKQAy0RjlRuvaFUsGM030xW3auLwh5ZMa]] )


end
