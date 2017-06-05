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
            
        registerCustomVariable( 'soul_shards', 
            setmetatable( {
                actual = nil,
                max = 5
            }, { __index = function( t, k )
                if k == 'count' or k == 'current' then
                    return t.actual

                elseif k == 'actual' then
                    t.actual = UnitPower( "player", SPELL_POWER_SOUL_SHARDS )
                    return t.actual
                end
            end } ) )

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
        addAura( "agony", 980, "duration", 18 )
        addAura( "banish", 710, "duration", 30 )
        addAura( "corruption", 146739, "duration", 14 )
        addAura( "dark_pact", 108416, "duration", 20 )
        addAura( "deadwind_harvester", 216708, "duration", 60 )
        addAura( "demonic_circle", 48018, "duration", 900 )
        addAura( "empowered_life_tap", 235156, "duration", 20 )
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
        addAura( "unstable_affliction", 233490, "duration", 8 )
            modifyAura( "unstable_affliction", "duration", function( x ) return x * haste end )
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


        -- Options.
        addToggle( 'artifact_ability', true, 'Artifact Ability', 'Set a keybinding to toggle your artifact ability on/off in your priority lists.' )

        addSetting( 'artifact_cooldown', true, {
            name = "Artifact Ability: Cooldown Override",
            type = "toggle",
            desc = "If |cFF00FF00true|r, when your Cooldown toggle is |cFF00FF00ON|r then the toggle for artifact ability will be overriden and your Artifact Ability will be shown regardless of your Artifact Ability toggle.",
            width = "full"
        } )


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
            applyBuff( "soulstone", 900 )
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
            applyUnstableAffliction( 6 * haste )
            -- applyDebuff( "target", "unstable_affliction", 8 * haste, min( 5, debuff.unstable_affliction.stack + 1 ) )
        end )
    end


    storeDefault( [[Affliction Default SimC]], 'actionLists', 20170518.231039, [[de0P1aqiLqBcQAukjNsjAvqH8krjAwqHkAxk1WGkhdIwge8mOKPrr6AIsABIs4BueJdkiNdkGMhK4EiI9bHCqiPfss6HKetekaxuuPncfQWjfvmtOaDti1ojXqHcvTurPEQKPIiDvOGARkb7f1FLQbdL6WuTyeEmLMSixw1MjYNruJMI60GETsQzt42sz3k(nWWjQJdfklhPNtQPlCDkSDrvFhc15ffRhkuP5tsTFOOzKmPCL74eINycUWaUKBicwvUklfkhCXv2xCxFwbbCinbxwrIWgbSqAcot5QKVf6cigxpGGHvqilYkxOAdiy0mPScsMuUYDCcXtSQCvwkuo4kCXNytMcBai9DGuxBitFZTz2FCcXt4DAaLCBSfaAQdK6scVD9M6ZAeHJlujGcyKHlTrRbMoCKoDCbxQy(21Ob5F7tWeCHgKwWPkE7CXLI3oxLrRbgmXoNr60XfCL9f31NvqahstqIJRCMe06bGY1aMZfAqsXBNloyfeys5k3XjepXQYvzPq5GRWfFInzkSbG03bsDTHm9n3Mz)XjepH3Tbm)7FEdEnIqYfQeqbmYWL2O1athosNoUGlvmF7A0G8V9jycUqdsl4ufVDU4sXBNRYO1adMyNZiD64cmXEfYLCL9f31NvqahstqIJRCMe06bGY1aMZfAqsXBNloyfSys5k3XjepXQYvzPq5GRWfFInzkSbG03bsDTHm9n3Mz)XjepH3Tbm)7FEdEnjiX70ak52yla0uhi1LeE76n1N1KGJlujGcyKHlTrRbMEcaAKnCAIlvmF7A0G8V9jycUqdsl4ufVDU4sXBNRYO1adMyJbaanYgonXv2xCxFwbbCinbjoUYzsqRhakxdyoxObjfVDU4GvmLjLRChNq8eRkxLLcLdUcx8j2Vjdq8Pp1fqP3dxE)XjepHFrcdjP9BYaeF6tDbu69WL3gYCHkbuaJmCjGsVhUmxQy(21Ob5F7tWeCHgKwWPkE7CXLI3oxyqO0XeBsDzUY(I76ZkiGdPjiXXvotcA9aq5AaZ5cniP4TZfhSswzs5k3XjepXQYfQeqbmYWLmiGGHRCMe06bGY1aMZfAqAbNQ4TZvI6FG2oCIle3gCP4TZfgpiGGHluPK1CnE7KKO(hOTdN4cXTbxzFXD9zfeWH0eK44sfZ3Ugni)BFcMGl0GKI3oxjQ)bA7WjUqCBWbRKfmPCL74eINyv5QSuOCW1Iegss709eIHtQB2P5VooDBiJFfHHK0wdmeDZon)1XM(MdhnIYAwEmMbuw(PnstnfRSWumc5oR4xmCXNy3CXLG2ozQRL3FCcXt4ngD4eI3Djjb0gqWO36WTRres1QjmKK2bG2(ep11adHEtVBdercgsT6WPKFSdy79a0tWJcjegss7aqBFIN6AGHqVP3TbgL1S8ymdOS8tBKMAkwzHPyeYDwvREXWfFIDZfxcA7KPUwE)XjepHFvqHZ6hBzkWU9jZ2qwT6GcN1p26WTRHd5Umfy3(KzBiVCjxOsafWidx07YDnWqO5sfZ3Ugni)BFcMGl0G0covXBNlUu825k77YyIDbmeAUY(I76ZkiGdPjiXXvotcA9aq5AaZ5cniP4TZfhSIjmPCL74eINyv5QSuOCWf9nhoAuijG219a2Ews2M4cvcOagz4YjdMmCLZKGwpauUgWCUqdsl4ufVDU4sXBNlujdMmCPsgR4K6uYp0SQCL9f31NvqahstqIJluPK1CzZyfVhoL8dnji5sfZ3Ugni)BFcMGl0GKI3oxCWkyiMuUYDCcXtSQCvwkuo4AXWfFInzkSbG03bsDTHm9n3Mz)XjepH3Tbm)7FEdE9wB0AGPdhPthxGcjiGFv4uYp2bS9Ea6j4resmeo1QdNs(X28DryElBduibbCQvhoL8JDaBVhGEcEuWc3sUqLakGrgU0gTgy6jaOr2WPjUuX8TRrdY)2NGj4cniTGtv825IlfVDUkJwdmyIngaa0iB40eMyVc5sUY(I76ZkiGdPjiXXvotcA9aq5AaZ5cniP4TZfhScgitkx5ooH4jwvUklfkhCTy4IpXMmf2aq67aPU2qM(MBZS)4eINW72aM)9pVbVERnAnW0HJ0PJlqecCHkbuaJmCPnAnW0HJ0PJl4sfZ3Ugni)BFcMGl0G0covXBNlUu825QmAnWGj25msNoUatSxHWsUY(I76ZkiGdPjiXXvotcA9aq5AaZ5cniP4TZfhScsCmPCL74eINyv5QSuOCWv4IpXMmf2aq67aPU2qM(MBZS)4eINW72aM)9pVbVERnAnW0HJ0PJlibj(JXmGYYpT1WjbOh21YW44x0caIeaXZwdNeGEyxldJ3H20M(MdhnIWXfQeqbmYWL2O1atpbanYgonXLkMVDnAq(3(embxObPfCQI3oxCP4TZvz0AGbtSXaaGgzdNMWe7viSKRSV4U(Scc4qAcsCCLZKGwpauUgWCUqdskE7CXbRGejtkx5ooH4jwvUklfkhCfU4tSjtHnaK(oqQRnKPV52m7poH4j8UnG5F)ZBWR3AJwdmD4iD64ceHe)Xygqz5N2A4Ka0d7AzyC8lAbarcG4zRHtcqpSRLHX7qBAtFZHJgr44cvcOagz4sB0AGPdhPthxWLkMVDnAq(3(embxObPfCQI3oxCP4TZvz0AGbtSZzKoDCbMyVcRLCL9f31NvqahstqIJRCMe06bGY1aMZfAqsXBNloyfKiWKYvUJtiEIvLRYsHYbxY0NVt2M2i3gJoCcX7UKKaAdiyuRMWqsARbgIUzNM)6ytFZHJgrKGehxOsafWidxeNQpDnCiZLkMVDnAq(3(embxObPfCQI3oxCP4TZLQNQpDnCiZv2xCxFwbbCinbjoUYzsqRhakxdyoxObjfVDU4GvqIftkx5ooH4jwvUqdsl4ufVDU4sXBNlvfaqctSX4WGMHlujGcyKHlcbaK6sg0mCL9f31NvqahstqIJlvmF7A0G8V9jycUYzsqRhakxdyoxObjfVDU4GvqAktkx5ooH4jwvUqdsl4ufVDU4sXBNluPwFoMytkGs)eCHkbuaJmC5uRpVhak9tWv2xCxFwbbCinbjoUuX8TRrdY)2NGj4kNjbTEaOCnG5CHgKu825Idwbzwzs5k3XjepXQYvzPq5GRfdx8j2AGHOB2P5Vo2FCcXt4xfu4S(XwMcSBFYSnKvRoOWz9JToC76Umfy3(KzBiRwD4uYp2bS9Ea6j4rHetWPw9IwaqKaiE2MDJj203C4Oreo1QngD4eI3Djjb0gqWO36WTRrecl5cvcOagz4sgeqWWvotcA9aq5AaZ5cniTGtv825sMceGH8tDzaIpLlfVDUW4bbemyI9kKl5cvkznxJ3ojYuGamKFQldq8PCL9f31NvqahstqIJlvmF7A0G8V9jycUqdskE7CjtbcWq(PUmaXNYbRGmlys5k3XjepXQYvzPq5GRWfFITgyi6MDA(RJ9hNq8eEcdjPTgyi6MDA(RJTHm(vbfoRFSLPa72NmBdz1QdkCw)yRd3UUltb2Tpz2gYQvhoL8JDaBVhGEcEuiXeCQvVOfaejaINTz3yIn9nhoAeHtTAJrhoH4DxssaTbem6ToC7AeHWsUqLakGrgUKbbemCLZKGwpauUgWCUqdsl4ufVDUKPabyi)uxgG4t5sXBNlmEqabdMyVcHLCHkLSMRXBNezkqagYp1Lbi(uUY(I76ZkiGdPjiXXLkMVDnAq(3(embxObjfVDUKPabyi)uxgG4t5GvqActkx5ooH4jwvUklfkhCrFZHJgfscODDpGTNLKTj8Rw52aM)9pVbVgfSWR)t6oqQBbuQHCabZ2cmMafSwIpCXNyRbiUhMFx)N07poH4j1Qx52aM)9pVbVgftXR)t6oqQBbuQHCabZ2cmMaftxUe)kJrhoH4DxssaTbem6ToC7AuqaVgyi6AZonP3wdk9tqco1QxmCXNy3CXLG2ozQRL3FCcXtl5cvcOagz4YcOud5acgUuX8TRrdY)2NGj4cniTGtv825IlfVDUubqPgYbemCL9f31NvqahstqIJRCMe06bGY1aMZfAqsXBNloyfKyiMuUYDCcXtSQCvwkuo4Av4IpX2j0aHr8UfqPgYbem7poH4j1QxmCXNy3CXLG2ozQRL3FCcXtQvVy4IpXwdme9ljbjNz)XjepTeVBdy(3)8g8AeHep9nhoAuijG219a2Ews2MWVALBdy(3)8g8AuWcV(pP7aPUfqPgYbemBlWycuWAj(WfFITgG4Ey(D9FsV)4eINuRELBdy(3)8g8AumfV(pP7aPUfqPgYbemBlWycumD5sUqLakGrgUSak1qoGGHRCMe06bGY1aMZfAqAbNQ4TZfxkE7CPcGsnKdiyWe7vixYLkzSItQtj)qZQYv2xCxFwbbCinbjoUqLswZLnJv8E4uYp0KGKlvmF7A0G8V9jycUqdskE7CXbRGedKjLRChNq8eRkxLLcLdUOV5WrJcjb0UUhW2ZsY2e(vgJoCcX7UKKaAdiy0BD421OGaEnWq01MDAsVTgu6NGeCQvVy4IpXU5IlbTDYuxlV)4eINwYfQeqbmYWLgkBgmDbu6CPI5BxJgK)TpbtWfAqAbNQ4TZfxkE7CvqzZGbtSXGqPZv2xCxFwbbCinbjoUYzsqRhakxdyoxObjfVDU4Gvqahtkx5ooH4jwvUklfkhCTAXWfFIDZfxcA7KPUwE)XjepPw9IHl(eBnWq0VKeKCM9hNq80s8UnG5F)ZBWRres803C4OrHKaAx3dy7zjzBIlujGcyKHlnu2my6cO05kNjbTEaOCnG5CHgKwWPkE7CXLI3oxfu2myWeBmiu6yI9kKl5sLmwXj1PKFOzv5k7lURpRGaoKMGehxOsjR5YMXkEpCk5hAsqYLkMVDnAq(3(embxObjfVDU4Gvqajtkx5ooH4jwvUklfkhCfU4tSFtgG4tFQlGsVhU8(JtiEcpHHK0(nzaIp9PUak9E4YB6BoC0OqczBIlujGcyKHlbu69WL5sfZ3Ugni)BFcMGl0G0covXBNlUu825cdcLoMytQlJj2RqUKRSV4U(Scc4qAcsCCLZKGwpauUgWCUqdskE7CXbRGacmPCL74eINyv5QSuOCW1IHl(e7MlUe02jtDT8(JtiEcp9nhoAuibjgcJWTXcF4uYp2bS9Ea6j4rej03C4O5cvcOagz4YjdMmCLZKGwpauUgWCUqdsl4ufVDU4sXBNlujdMmyI9kKl5sLmwXj1PKFOzv5k7lURpRGaoKMGehxOsjR5YMXkEpCk5hAsqYLkMVDnAq(3(embxObjfVDU4GvqalMuUYDCcXtSQCvwkuo4I(MdhnkKGedHr42yHpCk5h7a2Epa9e8iIe6BoC04ngD4eI3Djjb0gqWO36WTRjbhxOsafWidxozWKHRCMe06bGY1aMZfAqAbNQ4TZfxkE7CHkzWKbtSxHWsUujJvCsDk5hAwvUY(I76ZkiGdPjiXXfQuYAUSzSI3dNs(HMeKCPI5BxJgK)TpbtWfAqsXBNloyfemLjLRChNq8eRkxLLcLdUcx8j2Vjdq8Pp1fqP3dxE)XjepHNWqsA)MmaXN(uxaLEpC5n9nhoAusgupGGbJWTXsT6WfFIDZfxcA7KPUwE)XjepHpCk5h7a2Epa9e8iczwX38X3Y2afK44cvcOagz4saLEpCzUuX8TRrdY)2NGj4cniTGtv825IlfVDUWGqPJj2K6YyI9kewYv2xCxFwbbCinbjoUYzsqRhakxdyoxObjfVDU4GvqiRmPCL74eINyv5QSuOCWv4IpXwdqCpm)U(pP3FCcXt4x52aM)9pVbVgrKGfE9Fs3bsDlGsnKdiy2wGXeiIeSwQw9k3gW8V)5n41iIetXR)t6oqQBbuQHCabZ2cmMarKy6s1Qx52aM)9pVbVMeSWR)t6oqQBbuQHCabZ2cmMGeSwIpbITfqPgYbemB6BoC0OqI11rpGTNLb1ZFrpGTZfQeqbmYWL(p1bsDlGsnKdiy4sfZ3Ugni)BFcMGl0G0covXBNlUu825Q(tyInqctSvbqPgYbemCL9f31NvqahstqIJRCMe06bGY1aMZfAqsXBNloyfeYcMuUYDCcXtSQCvwkuo4AXWfFIDZfxcA7KPUwE)XjepHN(MdhnkKG0umc3gl8Htj)yhW27bONGhrKqFZHJMlujGcyKHllGsnKdiy4sfZ3Ugni)BFcMGl0G0covXBNlUu825sfaLAihqWGj2RqyjxzFXD9zfeWH0eK44kNjbTEaOCnG5CHgKu825Idwbbtys5k3XjepXQYvzPq5Gl6BoC0OqcstXiCBSWhoL8JDaBVhGEcEerc9nhoA8gJoCcX7UKKaAdiy0BD421KGJlujGcyKHllGsnKdiy4sfZ3Ugni)BFcMGl0G0covXBNlUu825sfaLAihqWGj2RWAjxzFXD9zfeWH0eK44kNjbTEaOCnG5CHgKu825Idwbbmetkx5ooH4jwvUklfkhCTkCXNy7eAGWiE3cOud5acM9hNq8KA1lgU4tSBU4sqBNm11Y7poH4j1QxmCXNyRbgI(LKGKZS)4eINwIN(MdhnkKG0umc3gl8Htj)yhW27bONGhrKqFZHJMlujGcyKHllGsnKdiy4kNjbTEaOCnG5CHgKwWPkE7CXLI3oxQaOud5acgmXELPl5sLmwXj1PKFOzv5k7lURpRGaoKMGehxOsjR5YMXkEpCk5hAsqYLkMVDnAq(3(embxObjfVDU4GvqadKjLRChNq8eRkxLLcLdUwmCXNy3CXLG2ozQRL3FCcXt4PV5WrJcjiZkgHBJf(WPKFSdy79a0tWJisOV5WrZfQeqbmYWLgkBgmDbu6CPI5BxJgK)TpbtWfAqAbNQ4TZfxkE7CvqzZGbtSXGqPJj2RqyjxzFXD9zfeWH0eK44kNjbTEaOCnG5CHgKu825IdwblCmPCL74eINyv5QSuOCWf9nhoAuibzwXiCBSWhoL8JDaBVhGEcEerc9nhoA8gJoCcX7UKKaAdiy0BD421KGJlujGcyKHlnu2my6cO05sfZ3Ugni)BFcMGl0G0covXBNlUu825QGYMbdMyJbHshtSxH1sUY(I76ZkiGdPjiXXvotcA9aq5AaZ5cniP4TZfhScwizs5k3XjepXQYvzPq5GRvlgU4tSBU4sqBNm11Y7poH4j1QxmCXNyRbgI(LKGKZS)4eINwIN(MdhnkKGmRyeUnw4dNs(XoGT3dqpbpIiH(MdhnxOsafWidxAOSzW0fqPZvotcA9aq5AaZ5cniTGtv825IlfVDUkOSzWGj2yqO0Xe7vMUKlvYyfNuNs(HMvLRSV4U(Scc4qAcsCCHkLSMlBgR49WPKFOjbjxQy(21Ob5F7tWeCHgKu825Idwbleys5k3XjepXQYvzPq5GRvlgU4tS1ae3dZVR)t69hNq8KA1RCBaZ)(N3GxJcw41)jDhi1Tak1qoGGzBbgtGcwlxIpCXNyB2nMy)XjepHFLgyi6AZonP3wdk9tGismvT60jmKK2MDJj203C4OruwSZQA1Htj)yhW27bONGhfSWTKlujGcyKHlJrhoH4DxssaTbemCPI5BxJgK)TpbtWfAqAbNQ4TZfxkE7CHHhD4eIJj2OkjjG2acgUY(I76ZkiGdPjiXXvotcA9aq5AaZ5cniP4TZfhScwyXKYvUJtiEIvLRYsHYbxRwmCXNyRbiUhMFx)N07poH4j1Qx52aM)9pVbVgfSWR)t6oqQBbuQHCabZ2cmMafSwUe)k3gW8V)5n41OykE9Fs3bsDlGsnKdiy2wGXeOy6s8Hl(eBetHH53Ht3jdMm7poH4j8Hl(eBlycNmem7poH4j8jqSngD4eI3Djjb0gqW0rUPV5WrJI11rpGTJpbITXOdNq8UljjG2acMocB6BoC0OyDD0dy74tGyBm6WjeV7sscOnGGPJ1M(Mdhnkwxh9a2o(ei2gJoCcX7UKKaAdiy6MUPV5WrJI11rpGTJpbITXOdNq8UljjG2acMEw303C4OrX66OhW25cvcOagz4Yy0HtiE3LKeqBabdxQy(21Ob5F7tWeCHgKwWPkE7CXLI3oxy4rhoH4yInQsscOnGGbtSxHCjxzFXD9zfeWH0eK44kNjbTEaOCnG5CHgKu825Idwbltzs5k3XjepXQYvzPq5GRvlgU4tS1ae3dZVR)t69hNq8KA1RCBaZ)(N3GxJcw41)jDhi1Tak1qoGGzBbgtGcwlxIFLBdy(3)8g8AumfV(pP7aPUfqPgYbemBlWycumDj(WfFInIPWW87WP7KbtM9hNq8e(vAGHORn70KEBnO0pbIiXu1QdkCw)yltb2nCIle3gBdz1QdkCw)yRd3UgoK7YuGD3CDCAMTHSA1bfoRFSLPa7U5640mBdz1QdkCw)yltb2TLcJTHSA1bfoRFSLPa7o)PApGcyKzBiRwnHHK0wdmeDZon)1X2qwTAcdjPD6EcXWj1n708xhNUnKvRMWqsABbnzGXKGd5UzaLcOB6DBqswvRoCk5h7a2Epa9e8Oqcc4wYfQeqbmYWLXOdNq8UljjG2acgUuX8TRrdY)2NGj4cniTGtv825IlfVDUWWJoCcXXeBuLKeqBabdMyVcHLCL9f31NvqahstqIJRCMe06bGY1aMZfAqsXBNloyfSYktkx5ooH4jwvUklfkhCTAXWfFITgG4Ey(D9FsV)4eINuRELBdy(3)8g8AuWcV(pP7aPUfqPgYbemBlWycuWA5s8RCBaZ)(N3GxJIP41)jDhi1Tak1qoGGzBbgtGIPlXhU4tSBU4sqBNm11Y7poH4j8RcNs(XoGT3dqpbpkyHtTAz6Z3jBtBKBJrhoH4DxssaTbem41adrxB2Pj92cmMarKy6sUqLakGrgUmgD4eI3Djjb0gqWWLkMVDnAq(3(embxObPfCQI3oxCP4TZfgE0HtioMyJQKKaAdiyWe7vyTKRSV4U(Scc4qAcsCCLZKGwpauUgWCUqdskE7CXbRGvwWKYvUJtiEIvLRYsHYbxRwmCXNyRbiUhMFx)N07poH4j1Qx52aM)9pVbVgfSWR)t6oqQBbuQHCabZ2cmMafSwUe)k3gW8V)5n41OykE9Fs3bsDlGsnKdiy2wGXeOy6s8Hl(e7MlUe02jtDT8(JtiEc)knWq01MDAsVTgu6NGKSQwD4IpX2cMWjdbZ(JtiEcVgyi6AZonHismDjxOsafWidxgJoCcX7UKKaAdiy4sfZ3Ugni)BFcMGl0G0covXBNlUu825cdp6WjehtSrvssaTbemyI9ktxYv2xCxFwbbCinbjoUYzsqRhakxdyoxObjfVDU4GvWYeMuUYDCcXtSQCvwkuo4A1IHl(eBnaX9W876)KE)XjepPw9k3gW8V)5n41OGfE9Fs3bsDlGsnKdiy2wGXeOG1YL4x52aM)9pVbVgftXR)t6oqQBbuQHCabZ2cmMaftxIpCXNy3CXLG2ozQRL3FCcXt4xfU4tS1adr)ssqYz2FCcXtQvFmMbuw(PTmaXN2TaAQdK6IhMJpjkuVe)IY0NVt2M2yTngD4eI3Djjb0gqWGxM(8DY20g52y0HtiE3LKeqBabdxOsafWidxgJoCcX7UKKaAdiy4sfZ3Ugni)BFcMGl0G0covXBNlUu825cdp6WjehtSrvssaTbemyI9QSUKRSV4U(Scc4qAcsCCLZKGwpauUgWCUqdskE7CXbRGfgIjLRChNq8eRkxLLcLdUwTy4IpXwdqCpm)U(pP3FCcXtQvVYTbm)7FEdEnkyHx)N0DGu3cOud5acglWycuWA5s8RCBaZ)(N3GxJIP41)jDhi1Tak1qoGGzBbgtGIPlXhU4tSBU4sqBNm11Y7poH4j8hJzaLLFAldq8PDlGM6aPU4H54tIc14ngD4eI3Djjb0gqWO36WTRjbhxOsafWidxgJoCcX7UKKaAdiy4sfZ3Ugni)BFcMGl0G0covXBNlUu825cdp6WjehtSrvssaTbemyI9QSyjxzFXD9zfeWH0eK44kNjbTEaOCnG5CHgKu825IdwblmqMuUYDCcXtSQCvwkuo4A1IHl(eBnaX9W876)KE)XjepPw9k3gW8V)5n41OGfE9Fs3bsDlGsnKdiy2wGXeOG1YL4x52aM)9pVbVgftXR)t6oqQBbuQHCabZ2cmMaftxIpCXNy3CXLG2ozQRL3FCcXt4dx8j2AGHOFjji5m7poH4j8lEmMbuw(PTmaXN2TaAQdK6IhMJpjkuJ3y0HtiE3LKeqBabJERd3UMeC4tGy7KbtMn9nhoAezDD0dy7yewzzwSZk(vlgU4tS1adr)ssqYz2FCcXtQvl)yRbgI(LKGKZStGy7KbtMn9nhoAezDD0dy7yewzzwSZ6sUqLakGrgUmgD4eI3Djjb0gqWWLkMVDnAq(3(embxObPfCQI3oxCP4TZfgE0HtioMyJQKKaAdiyWe7vMSKRSV4U(Scc4qAcsCCLZKGwpauUgWCUqdskE7CXbRykoMuUYDCcXtSQCvwkuo4A1IHl(eBnaX9W876)KE)XjepPw9k3gW8V)5n41OGfE9Fs3bsDlGsnKdiy2wGXeOG1YL4x52aM)9pVbVgftXR)t6oqQBbuQHCabZ2cmMaftxIpCXNy3CXLG2ozQRL3FCcXt4xmCXNyRbgI(LKGKZS)4eINWV4Xygqz5N2YaeFA3cOPoqQlEyo(KOqn(fLPpFNSnTXABm6WjeV7sscOnGGbFceBNmyYSPV5WrJiRRJEaBhJWklZIDwXVkbITfqPgYbemB6BoC0iY66OhW2ZYSyNv1Qdx8j2oHgimI3Tak1qoGGz)XjepTKlujGcyKHlJrhoH4DxssaTbemCPI5BxJgK)TpbtWfAqAbNQ4TZfxkE7CHHhD4eIJj2OkjjG2acgmXEfgAjxzFXD9zfeWH0eK44kNjbTEaOCnG5CHgKu825IdwXuKmPCL74eINyv5QSuOCW1Iegss709eIHtQB2P5VooDBiJ3y0HtiE3LKeqBabJERd3UgriXVA1IbfoRFSn76UoC7A4qURdp2(Kb)IbfoRFSn76Uo8y7tMLQvhU4tSBU4sqBNm11Y7poH4PLCHkbuaJmCrVl31adHMlvmF7A0G8V9jycUqdsl4ufVDU4sXBNRSVlJj2fWqOXe7vixYv2xCxFwbbCinbjoUYzsqRhakxdyoxObjfVDU4GvmfbMuUYDCcXtSQCvwkuo4ArcdjPD6EcXWj1n708xhNUnKXltF(ozBAJCBm6WjeV7sscOnGGb)Qvlgu4S(X2SR76WTRHd5Uo8y7tg8lgu4S(X2SR76WJTpzwQwD4IpXU5IlbTDYuxlV)4eINwINWqsAhaA7t8uxdme6n9UnqesUqLakGrgUO3L7AGHqZLkMVDnAq(3(embxObPfCQI3oxCP4TZv23LXe7cyi0yI9kewYv2xCxFwbbCinbjoUYzsqRhakxdyoxObjfVDU4GvmflMuUYDCcXtSQCvwkuo4Q5JVLTbkKGehxOsafWidxcO07HlZLkMVDnAq(3(embxObPfCQI3oxCP4TZfgekDmXMuxgtSxH1sUY(I76ZkiGdPjiXXvotcA9aq5AaZ5cniP4TZfhSIPMYKYvUJtiEIvLlujGcyKHRe1HtxdmeCLZKGwpauUgWCUqdsl4ufVDU4sXBNlmaQdhmXUagcUqLswZL1SdhsqIXjCItPgYbji5k7lURpRGaoKMGehxLzaIrdsqj4PAwvUuX8TRrdY)2NGj4cniP4TZfhSIPzLjLRChNq8eRkxObPfCQI3oxCP4TZfgekDmXMuxgtSxz6sUqLakGrgUeqP3dxMRSV4U(Scc4qAcsCCPI5BxJgK)TpbtWvotcA9aq5AaZ5cniP4TZfhCWLI3oxOkjjG2acgmXgd4sUHiWe7c2uHdMb]] )


    storeDefault( [[Affliction Primary]], 'displays', 20170518.231039, [[dOJ3gaGEf0ljc2fuvyBqvrZubA2s6MeHUTkCyP2jL2Ry3e2pr5NkQHPI(TQEnvvnuuzWevdhPoij9mOQ0XKOJtKSqjSuIulMuwovEivLNcEmIEoftur0uHYKjHPR0fvORsvfxgY1ryJKOTsvLAZQ02rsFubSmfPPre57uLrse1Prz0OQXdv5KiXTGQQUMIW5jvFgQSwQQKVbvvoLblaztVSxO8flS6vuGz)Gnif7yGTD4qlhvUOfW1cCiF8is)traPiqei1kdN4aj2aKb0NVxdA910l7fMypdG389AqRVMEzVWe7zaAh7OD6uiFbWgIIvsNboyc1XyX3asrGiqk810l7fMueqF(EnOfRD4qRj2Zag(3d8yljV6ykcy4FpvI9trad)7bESLKxLy)ueyBho0Qki5FxGIzmSzjknLbKmwa9yX)Ptmra8I9mGH)9WAho0Asra)1ufK8Vla2mN0ugqYybycfmYEFNQGK)DbKMYasglaztVSxOki5FxGIzmSzjgW3tRlto2hq9ERmYL9czYvNhdy4FpalfbKIarGMK5qKl7fbKMYasglGG4Gc5lmXkPagAuTQS2gEFF9DblqhBzaxSLbWfBzaTylZgWW)E(A6L9ct0cG389AqRkHRJ9mqt4AmDAuanI7nWrJNkX(XEgqRYgoCG67PwRrlqxP5BG)94OogBzGUsZ3((dTE5OogBzGjr3MOUPiqx9ADdhvUueGkZW0yv2QJPtJcOfGSPx2luRmCIa(gTyJshqbZqxBDmDAuafbCTahctNgfO1yv2QhOjCTezcukc4VMYxSaBik2YPb6knFJ1oCOLJkxSLbCOAaFJwSrPdyOr1QYAB4JwGUsZ3yTdhA5OogBzaPiqeifuekyK9(otkca0iswxzd7L9IyNIpNiGc0TjQRk3GbuV3kJCzVqM8jr3MOUYKdSdFb22HdTkFXcREffy2pydsXog4Gjuj2p2Za6Z3RbTsOWel(xgaV571GwjuyITmqxP5B1QxRB4OYfBzGUsZ3a)7XrLl2Ya0o2r70v(IfydrXwonaTdr(hA9QYnya17TYix2lKjFs0TjQRm5a7WxGJgpal2YahnEQJXEgWW)ECu5srGTD4qlh1XOfqAuf1guStplXVZjkNIpMIVL43PKcy4FpjG01ycfmbotkcq(hA9YrDmAbiB6L9cLVyb2quSLtd0vA(wT616goQJXwgWFnLVydWHjto0cJm5225EVa6Z3RbTQeUo2Zag(3JIqbJS33zsrad)7Ps4AkI7hTaD1R1nCuhtrad)7PoMIag(3JJ6ykcq(hA9YrLlAb6knF77p06LJkxSLbAcxRki5FxGIzmSzjo4OsSanHRPiUpMonkGgX9g4GjaSypdSTdhAv(IfydrXwonGuems)9BMbw9kkqhGSPx2lu(InahMm5qlmYKBBN79c0eUgOr1kLjJ9mWOO1QifPiGHDqxrQZJXonaEZ3RbTyTdhAnXEgyBho0Q8fBaomzYHwyKj32o37fqF(EnOLIqbJS33zI9maEZ3RbTuekyK9(otSNb0QSHdhO(ErlGueicKckKVaydrXkPZa3xSb4WKjhAHrMCB7CVxag5la6MKjWf7ebyKVWV()i2YjcifbIaPq5lwGnefB50a(RP8flS6vuGz)Gnif7yaPiqeifsOWKIa2(afq9ERmYL9czY5CSJ2PhOjCTFeSnaDT1rUSja]] )

    storeDefault( [[Affliction AOE]], 'displays', 20170518.231039, [[dOJ2gaGEjvVeHQDjjPETKuZusXSPQBse62QOhdv7Ks7vSBc7Ne9tfAyQWVv1HLAOe1GjHHJuhKKMgrWXOIJtKSqfzPePwmQA5s8qjXtbltr55umrfvMkuMmPy6kDrfCvIixgY1r0gjL2QIQyZQ02rsFusPNHqXNrW3PsJusItJYOrLXJqojsClekDnIOopPABkQsRvss(MIQ64eSa4n9YEH2xSWQ7rbgLewnuSdbWB6L9cTVybwDuSoZcuAbbufoeE1zkGuKisKQNrqCIeBa8a6J3RbTvA6L9ctShbiA8EnOTstVSxyI9iaDHD2fDk4Vay1rXkHJaNmH6qSetaPirKinvA6L9ctMcOpEVg0I1fcO1e7rad37cUSfNtDi8bmCVRk5(HpGH7Dbx2IZPsUFMcSDHaAvf4CFjW0ig2OeLMsTvblarJ3RbTeFYeRta9X71GwIpzILyDcy4ExSUqaTMmfOAEvbo3xcGnklnLARcwaMqddV3VOkW5(saPPuBvWcG30l7fQcCUVeyAedBuIbQ806kvG9buVxpdFzVqPc1XHagU3fWYuaPirKO5yfe(YEraPPuBvWciipPG)ctSsiGHg59A9THRY7)sWc0X6eGpwNaeI1jqjwNSbmCVBLMEzVWe(aenEVg0Qsw6ypc0KLgtNgfGN8EdC2ePsUFShb49S61R1)UQEF4d0EAUg4ExzQdX6eO90CDL)KVxzQdX6eyo0Tj9BMc0E3w3itvotbOYmmEMNT6y60Oa8bWB6L9cvpJGiqLbl2G0b0Wm0(whtNgfapqPfeqy60OanpZZw9anzPLitGYuGQ51(Ify1rX6mlq7P5ASUqaTYuLJ1jqb5duzWIniDadnY716Bdx4d0EAUgRleqRm1HyDcifjIePHIqddV3VyYuaGgHZApREVSxe7S5vYbS9jkG696z4l7fkvOooey7cb0Q9flS6EuGrjHvdf7qGtMqLC)ypcunV2xSWQ7rbgLewnuSdb0JLyN5CeO90CTQ3T1nYuLJ1jad)fv1)NX6i5a0f2zx01(Ify1rX6mlaDbH)N89Qkxta171ZWx2luQyo0Tj9Rsfa7Ssag(la6gNjieRKdC2ePoe7rG7l2aYykvaTWOuHTlL3nW2fcOvM6q4difjIePHc(lawDuSs4iGH7DLPkNPa8Ew9616F3WhGOX71Gwkcnm8E)Ij2Ja6J3RbTueAy49(ftShb2UqaTAFXgqgtPcOfgLkSDP8UbiA8EnOfRleqRj2JagU3LIqddV3VyYuad37QswAkI7h(aT3T1nYuhYuad37ktDitbmCVR6q4dG)N89ktvo8bAYsd0iVNYCXEeOjlTQaN7lbMgXWgLyndAXcifjdV65HzGv3JcWh4KjaSypcSDHaA1(Ify1rX6mlqtwAkI7JPtJcWtEVbWB6L9cTVydiJPub0cJsf2UuE3aTNMRR8N89ktvowNadIM3J0KPag2jThPooe7Sa6J3RbTQKLo2JavZR9fBazmLkGwyuQW2LY7gO90CTQ3T1nYuhI1jW2fcOvMQC4dG)N89ktDi8bmCVlXr68mHgMGGjtbKg5rTbf7SdN5FizNzv9mIXz(hsiWzteGfRtG2tZ1a37ktvowNasrIirA0(Ify1rX6mlarXEeqksejsdXNmzkGg0Tj9RQCnbuVxpdFzVqPI5q3M0VkvaSZkbAYsljbBdq7BDujBca]] )


end
