-- Druid.lua
-- May 2017

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


-- This table gets loaded only if there's a supported class/specialization.
if (select(2, UnitClass('player')) == 'DRUID') then

    ns.initializeClassModule = function ()

        setClass( "DRUID" )
        -- setSpecialization( "feral" )

        -- Resources
        addResource( "mana", SPELL_POWER_MANA )
        addResource( "energy", SPELL_POWER_ENERGY )
        addResource( "rage", SPELL_POWER_RAGE, true )
        addResource( "combo_points", SPELL_POWER_COMBO_POINTS, true )

        setRegenModel( {
            elunes_guidance = {
                resource = 'combo_points',

                spec = 'feral',
                aura = 'elunes_guidance',
                setting = nil,

                last = function ()
                    return state.buff.elunes_guidance.applied + floor( state.query_time - state.buff.elunes_guidance.applied )
                end,

                interval = 1,
                value = 1
            },

            energy = {
                resource = "energy",

                spec = "feral",
                aura = "cat_form",

                last = function () 
                    local app = state.energy.last_tick > 0 and state.energy.last_tick or state.now
                    local t = state.query_time

                    return app + ( floor( ( t - app ) / 0.1 ) * 0.1 )
                end,

                interval = 0.1,
                value = 0,
            }
        } )


        setPotion( "prolonged_power" )
        setRole( state.spec.guardian and "tank" or "attack" )

        addHook( 'specializationChanged', function ()
            setPotion( 'prolonged_power' )
            setRole( state.spec.guardian and "tank" or "attack" )
        end )

        -- Talents: Feral
        --[[ Balance Affinity: You gain:   Astral Influence  Increases the range of all of your abilities by 5 yards.  You also learn:   Moonkin Form   Starsurge   Lunar Strike   Solar Wrath   Sunfire ]]
        addTalent( "balance_affinity", 197488 ) -- 22163

        --[[ Blood Scent: Your melee abilities in Cat Form have a 10% increased critical strike chance on targets with a Bleed effect. ]]
        addTalent( "blood_scent", 202022 ) -- 22364

        --[[ Bloodtalons: Casting Regrowth causes your next two melee abilities to deal 50% increased damage for their full duration. ]]
        addTalent( "bloodtalons", 155672 ) -- 21649

        --[[ Brutal Slash: Strikes all nearby enemies with a massive slash, inflicting 95880.1 to 105663.3 Physical damage. Awards 1 combo point. Maximum 3 charges. ]]
        addTalent( "brutal_slash", 202028 ) -- 21653

        --[[ Displacer Beast: Teleports you up to 20 yards forward, activating Cat Form and increasing your movement speed by 50% for 2 sec. ]]
        addTalent( "displacer_beast", 102280 ) -- 18570

        --[[ Elune's Guidance: Immediately gain 5 combo points and an additional 1 combo point every 1 sec for 8 sec. ]]
        addTalent( "elunes_guidance", 202060 ) -- 22370

        --[[ Guardian Affinity: You gain:   Thick Hide  Reduces all damage taken by 6%.  You also learn:   Mangle   Ironfur   Frenzied Regeneration ]]
        addTalent( "guardian_affinity", 217615 ) -- 22158

        --[[ Incarnation: King of the Jungle: An improved Cat Form that allows the use of Prowl while in combat, causes Shred and Rake to deal damage as if stealth were active, reduces the cost of all Cat Form abilities by 60%, and increases maximum Energy by 50.  Lasts 30 sec. You may shapeshift in and out of this improved Cat Form for its duration. ]]
        addTalent( "incarnation_king_of_the_jungle", 102543 ) -- 21705

        --[[ Jagged Wounds: Your Rip, Rake, and Thrash abilities deal the same damage as normal, but in 33% less time. ]]
        addTalent( "jagged_wounds", 202032 ) -- 21711

        --[[ Lunar Inspiration: Moonfire is now usable while in Cat Form, generates 1 combo point, deals damage based on attack power, and costs 30 energy. ]]
        addTalent( "lunar_inspiration", 155580 ) -- 22365

        --[[ Mass Entanglement: Roots the target in place for 30 sec and spreads to additional nearby enemies. Damage may interrupt the effect. Usable in all shapeshift forms. ]]
        addTalent( "mass_entanglement", 102359 ) -- 18576

        --[[ Mighty Bash: Invokes the spirit of Ursoc to stun the target for 5 sec. Usable in all shapeshift forms. ]]
        addTalent( "mighty_bash", 5211 ) -- 21778

        --[[ Moment of Clarity: Omen of Clarity now affects the next 3 Shreds, Thrashes, or Swipes and increases their damage by 15%.  Your maximum Energy is increased by 30. ]]
        addTalent( "moment_of_clarity", 236068 ) -- 21646

        --[[ Predator: The cooldown on Tiger's Fury resets when a target dies with one of your Bleed effects active, and Tiger's Fury last 4 additional seconds. ]]
        addTalent( "predator", 202021 ) -- 22363

        --[[ Renewal: Instantly heals you for 30% of maximum health. Usable in all shapeshift forms. ]]
        addTalent( "renewal", 108238 ) -- 19283

        --[[ Restoration Affinity: You gain:   Ysera's Gift  Heals you for 3% of your maximum health every 5 sec. If you are at full health, a injured party or raid member will be healed instead.  You also learn:   Rejuvenation   Healing Touch   Swiftmend ]]
        addTalent( "restoration_affinity", 197492 ) -- 22159

        --[[ Sabertooth: Ferocious Bite deals 15% increased damage and always refreshes the duration of Rip. ]]
        addTalent( "sabertooth", 202031 ) -- 21714

        --[[ Savage Roar: Finishing move that grants 25% increased damage to your Cat Form attacks for their full duration. Lasts longer per combo point:     1 point  : 8 seconds   2 points: 12 seconds   3 points: 16 seconds   4 points: 20 seconds   5 points: 24 seconds ]]
        addTalent( "savage_roar", 52610 ) -- 21702

        --[[ Soul of the Forest: Your finishing moves grant 5 Energy per combo point. ]]
        addTalent( "soul_of_the_forest", 158476 ) -- 21708

        --[[ Typhoon: Strikes targets within 15 yards in front of you with a violent Typhoon, knocking them back and dazing them for 6 sec. Usable in all shapeshift forms. ]]
        addTalent( "typhoon", 132469 ) -- 18577

        --[[ Wild Charge: Fly to a nearby ally's position. ]]
        addTalent( "wild_charge", 102401 ) -- 18571


        -- Talents: Guardian
        --[[ Balance Affinity: You gain:     Astral Influence  Increases the range of all of your abilities by 5 yards.    You also learn:     Moonkin Form   Starsurge   Lunar Strike   Solar Wrath   Sunfire ]]
        addTalent( "balance_affinity", 197488 ) -- 22163

        --[[ Blood Frenzy: Thrash also generates 2 Rage each time it deals damage. ]]
        addTalent( "blood_frenzy", 203962 ) -- 22420

        --[[ Brambles: Sharp brambles protect you, absorbing and reflecting up to 2,002 damage from each attack.    While Barkskin is active, the brambles also deal 1,802 Nature damage to all nearby enemies every 1 sec. ]]
        addTalent( "brambles", 203953 ) -- 22419

        --[[ Bristling Fur: Bristle your fur, causing you to generate Rage based on damage taken for 8 sec. ]]
        addTalent( "bristling_fur", 155835 ) -- 22418

        --[[ Earthwarden: When you deal direct damage with Thrash, you gain a charge of Earthwarden, reducing the damage of the next auto attack you take by 30%. Earthwarden may have up to 3 charges. ]]
        addTalent( "earthwarden", 203974 ) -- 22423

        --[[ Feral Affinity: You gain:     Feline Swiftness  Increases your movement speed by 15%.    You also learn:     Shred   Rake   Rip   Ferocious Bite    Your energy regeneration is increased by 35%. ]]
        addTalent( "feral_affinity", 202155 ) -- 22156

        --[[ Galactic Guardian: Your damage has a 7% chance to trigger a free automatic Moonfire on that target.     When this occurs, the next Moonfire you cast generates 8 Rage, and deals 300% increased direct damage. ]]
        addTalent( "galactic_guardian", 203964 ) -- 22421

        --[[ Guardian of Elune: Mangle increases the duration of your next Ironfur by 2 sec, or the healing of your next Frenzied Regeneration by 20%. ]]
        addTalent( "guardian_of_elune", 155578 ) -- 21712

        --[[ Guttural Roars: Increases the radius of Stampeding Roar by 200%, the radius of Incapacitating Roar by 100%, and reduces the cooldown of Stampeding Roar by 50%. ]]
        addTalent( "guttural_roars", 204012 ) -- 22424

        --[[ Incarnation: Guardian of Ursoc: An improved Bear Form that reduces the cooldown on all melee damage abilities and Growl to 1.5 sec, causes Mangle to hit up to 3 targets, and increases armor by 15%.    Lasts 30 sec. You may freely shapeshift in and out of this improved Bear Form for its duration. ]]
        addTalent( "incarnation_guardian_of_ursoc", 102558 ) -- 21706

        --[[ Intimidating Roar: Unleash a terrifying roar, causing all enemies within 20 yards to cower in fear, disorienting them for 3 sec. Usable in all shapeshift forms. ]]
        addTalent( "intimidating_roar", 236748 ) -- 22916

        --[[ Lunar Beam: Summons a beam of lunar light at your location, dealing 60,072 Arcane damage and healing you for 200,232 over 8 sec. ]]
        addTalent( "lunar_beam", 204066 ) -- 22427

        --[[ Mass Entanglement: Roots the target and all enemies with 15 yards in place for 30 sec. Damage may interrupt the effect. Usable in all shapeshift forms. ]]
        addTalent( "mass_entanglement", 102359 ) -- 18576

        --[[ Mighty Bash: Invokes the spirit of Ursoc to stun the target for 5 sec. Usable in all shapeshift forms. ]]
        addTalent( "mighty_bash", 5211 ) -- 21778

        --[[ Pulverize: A devastating blow that consumes 2 stacks of your Thrash on the target to deal 45,350 Physical damage, and reduces all damage you take by 9% for 20 sec. ]]
        addTalent( "pulverize", 80313 ) -- 22425

        --[[ Rend and Tear: While in Bear Form, Thrash also increases your damage dealt to the target, and reduces your damage taken from the target by 2% per application of Thrash. ]]
        addTalent( "rend_and_tear", 204053 ) -- 22426

        --[[ Restoration Affinity: You gain:     Ysera's Gift  Heals you for 1.5% of your maximum health every 5 sec. If you are at full health, a injured party or raid member will be healed instead.    You also learn:     Rejuvenation   Healing Touch   Swiftmend ]]
        addTalent( "restoration_affinity", 197492 ) -- 22159

        --[[ Soul of the Forest: Mangle generates 5 more Rage and deals 25% more damage. ]]
        addTalent( "soul_of_the_forest", 158477 ) -- 21709

        --[[ Survival of the Fittest: Reduces the cooldowns of Barkskin and Survival Instincts by 33%. ]]
        addTalent( "survival_of_the_fittest", 203965 ) -- 22422

        --[[ Typhoon: Strikes targets within 15 yards in front of you with a violent Typhoon, knocking them back and dazing them for 6 sec. Usable in all shapeshift forms. ]]
        addTalent( "typhoon", 132469 ) -- 18577

        --[[ Wild Charge: Fly to a nearby ally's position. ]]
        addTalent( "wild_charge", 102401 ) -- 18571



        -- Traits
        addTrait( "adaptive_fur", 200850 )
        addTrait( "ashamanes_bite", 210702 )
        addTrait( "ashamanes_energy", 210579 )
        addTrait( "ashamanes_frenzy", 210722 )
        addTrait( "attuned_to_nature", 210590 )
        addTrait( "bear_hug", 215799 )
        addTrait( "bestial_fortitude", 200414 )
        addTrait( "bloodletters_frailty", 238120 )
        addTrait( "bloody_paws", 200515 )
        addTrait( "concordance_of_the_legionfall", 239042 )
        addTrait( "embrace_of_the_nightmare", 200855 )
        addTrait( "fangs_of_the_first", 214911 )
        addTrait( "feral_instinct", 210631 )
        addTrait( "feral_power", 210571 )
        addTrait( "ferocity_of_the_cenarion_circle", 241100 )
        addTrait( "fleshknitting", 238085 )
        addTrait( "fortitude_of_the_cenarion_circle", 241101 )
        addTrait( "fury_of_ashamane", 238084 )
        addTrait( "gory_fur", 200854 )
        addTrait( "hardened_roots", 210638 )
        addTrait( "honed_instincts", 210557 )
        addTrait( "iron_claws", 215061 )
        addTrait( "jagged_claws", 200409 )
        addTrait( "mauler", 208762 )
        addTrait( "open_wounds", 210666 )
        addTrait( "pawsitive_outlook", 238121 )
        addTrait( "perpetual_spring", 200402 )
        addTrait( "powerful_bite", 210575 )
        addTrait( "protection_of_ashamane", 210650 )
        addTrait( "rage_of_the_sleeper", 200851 )
        addTrait( "razor_fangs", 210570 )
        addTrait( "reinforced_fur", 200395 )
        addTrait( "roar_of_the_crowd", 214996 )
        addTrait( "scent_of_blood", 210663 )
        addTrait( "scintillating_moonlight", 238049 )
        addTrait( "shadow_thrash", 210676 )
        addTrait( "sharpened_claws", 210637 )
        addTrait( "sharpened_instincts", 200415 )
        addTrait( "shredder_fangs", 214736 )
        addTrait( "tear_the_flesh", 210593 )
        addTrait( "thrashing_claws", 238048 )
        addTrait( "ursocs_bond", 214912 )
        addTrait( "ursocs_endurance", 200399 )
        addTrait( "vicious_bites", 200440 )
        addTrait( "wildflesh", 200400 )

        -- Auras
        addAura( "astral_influence", 197524 )
        addAura( "barkskin", 22812 )
        addAura( "bear_form", 5487, 'duration', 3600 )
        addAura( "berserk", 106951 )
        addAura( "bloodtalons", 145152, "max_stack", 2, "duration", 30 )
        addAura( "bristling_fur", 155835 )
        addAura( "cat_form", 768, "duration", 3600 )
        addAura( "clearcasting", 135700, "duration", 15, "max_stack", 1 )
            modifyAura( "clearcasting", "max_stack", function( x )
                return talent.moment_of_clarity.enabled and 3 or x
            end )
        addAura( "dash", 1850 )
        addAura( "displacer_beast", 102280, "duration", 2 )
        addAura( "elunes_guidance", 202060, 'duration', 5 )
        addAura( "fiery_red_maimers", 212875)
        addAura( "feline_swiftness", 131768 )
        addAura( "feral_instinct", 16949 )
        addAura( "frenzied_regeneration", 22842 )
        addAura( "gore", 210706 )
        addAura( "incarnation_guardian_of_ursoc", 102558, "duration", 30 )
        addAura( "incarnation_king_of_the_jungle", 117679, "duration", 30 )
        addAura( "infected_wounds", 48484 )
        addAura( "ironfur", 192081 )
        addAura( "lightning_reflexes", 231065 )
        addAura( "moonkin_form", 197625 )
        addAura( "omen_of_clarity", 16864 )
        addAura( "predatory_swiftness", 69369, "duration", 12 )
        addAura( "primal_fury", 159286 )
        addAura( "prowl", 5215, "duration", 3600 )
        addAura( "pulverize", 138792, "duration", 20 )
        addAura( "rage_of_the_sleeper", 200851, "duration", 10 )
        addAura( "rake", 155722, "duration", 15, "tick_time", 3 )
            modifyAura( "rake", "duration", function( x )
                return talent.jagged_wounds.enabled and x * 0.8333 or x
            end )
            modifyAura( "rake", "tick_time", function( x )
                return talent.jagged_wounds.enabled and x * 0.8333 or x
            end )
        addAura( "regrowth", 8936, "duration", 12 )
        addAura( "rip", 1079, "duration", 24, "tick_time", 2 )
            modifyAura( "rip", "duration", function( x )
                return talent.jagged_wounds.enabled and x * 0.8333 or x
            end )
            modifyAura( "rip", "tick_time", function( x )
                return talent.jagged_wounds.enabled and x * 0.8333 or x
            end )
        addAura( "savage_roar", 52610, "duration", 24 )
        addAura( "shadowmeld", 58984, "duration", 3600 )
        addAura( "survival_instincts", 61336 )
        addAura( "thick_hide", 16931 )
        addAura( "thrash_bear", 192090, "duration", 15, "max_stack", 3 )
        addAura( "thrash_cat", 106830, "duration", 15, "tick_time", 3 )
            modifyAura( "thrash_cat", "duration", function( x )
                return talent.jagged_wounds.enabled and x * 0.8333 or x
            end )
            modifyAura( "thrash_cat", "tick_time", function( x )
                return talent.jagged_wounds.enabled and x * 0.8333 or x
            end )
        addAura( "tigers_fury", 5217, "duration", 8 )
            modifyAura( "tigers_fury", "duration", function( x )
                if talent.predator.enabled then return x + 4 end
                return x
            end )
        addAura( "travel_form", 783 )
        addAura( "wild_charge", 102401 )
        -- addAura( "wild_charge_movement", )
        addAura( "yseras_gift", 145108 )


        --[[ addToggle( 'artifact_ability', true, 'Artifact Ability',
            'Set a keybinding to toggle your artifact ability on/off in your priority lists.' )

        addSetting( 'artifact_cooldown', true, {
            name = "Artifact Ability: Cooldown Override",
            type = "toggle",
            desc = "If |cFF00FF00true|r, when your Cooldown toggle is |cFF00FF00ON|r then the toggle for your artifact ability will be overridden and your artifact ability will be shown regardless of its toggle above.",
            width = "full"
        } ) ]]

        addSetting( 'regrowth_instant', true, {
            name = "Regrowth: Instant Only",
            type = "toggle",
            desc = "If |cFF00FF00true|r, Regrowth will only be usable in Cat Form when "
            })


        addGearSet( 'fangs_of_ashamane', 128860 )
        setArtifact( 'fangs_of_ashamane' )

        addGearSet( 'claws_of_ursoc', 128821 )
        setArtifact( 'claws_of_ursoc' )


        addGearSet( 'soul_of_the_archdruid', 151636 )
        setTalentLegendary( 'soul_of_the_archdruid', 'feral',       'soul_of_the_forest' )
        setTalentLegendary( 'soul_of_the_archdruid', 'guardian',    'soul_of_the_forest' )


        addMetaFunction( 'state', 'gcd', function()
            return 1.0
        end )



        local moc_spells = { shred = true, thrash_cat = true, swipe_cat = true }

        addMetaFunction( 'state', 'persistent_multiplier', function ()
            local mult = 1

            mult = mult * ( buff.bloodtalons.up and 1.5 or 1 )
            mult = mult * ( buff.tigers_fury.up and 1.15 or 1 )

            if this_action and moc_spells[ this_action ] then
                mult = mult * ( buff.clearcasting.up and 1.15 or 1 )
            end

            return mult
        end )

        local clearcasting_spells = { [5221] = true, [106830] = true, [106785] = true }

        local function persistent_modifier( spellID )
            local bloodtalons = UnitBuff( "player", class.auras.bloodtalons.name, nil, "PLAYER" )
            local tigers_fury = UnitBuff( "player", class.auras.tigers_fury.name, nil, "PLAYER" )
            local clearcasting = UnitBuff( "player", class.auras.clearcasting.name, nil, "PLAYER" )

            return 1 * ( bloodtalons and 1.2 or 1 ) * ( tigers_fury and 1.15 or 1 ) * ( ( clearcasting_spells[ spellID ] and clearcasting ) and 1.2 or 1 )
        end

        RegisterUnitEvent( "UNIT_SPELLCAST_SUCCEEDED", function( event, unit, spell, _, _, spellID )

            if unit == 'player' then
                if class.abilities[ spell ] then
                    ns.saveDebuffModifier( spell, persistent_modifier( spellID ) )
                end
            end

        end )  

        addMetaFunction( 'state', 'break_stealth', function ()
            removeBuff( "shadowmeld" )
            if buff.prowl.up then
                setCooldown( "prowl", 6 )
                removeBuff( "prowl" )
            end
        end )

        addMetaFunction( 'state', 'shift', function( form )
            removeBuff( "cat_form" )
            removeBuff( "bear_form" )
            removeBuff( "travel_form" )
            removeBuff( "moonkin_form" )
            applyBuff( form )
        end )

        addHook( "runHandler", function( ability )
            if not class.abilities[ ability ] or not class.abilities[ ability ].passive then
                if state.buff.prowl.up then
                    state.removeBuff( "prowl" )
                    state.setCooldown( "prowl", 10 )
                end
                state.removeBuff( "shadowmeld" )
            end
        end )

        addHook( "reset_precast", function ()
            if state.buff.cat_form.down then
                state.energy.regen = 10 + ( state.stat.haste * 10 )
            end
            state.debuff.rip.pmultiplier = nil
            state.debuff.rake.pmultiplier = nil
            state.debuff.thrash.pmultiplier = nil
        end )

        local function comboSpender( amount, resource )
            if resource == 'combo_points' and state.talent.soul_of_the_forest.enabled then
                state.gain( amount * 5, 'energy' )
            end
        end

        addHook( 'spend', comboSpender )
        addHook( 'spendResources', comboSpender )
        

        -- Abilities

        -- Ashamane's Frenzy
        --[[ Unleash Ashamane's Frenzy, clawing your target 15 times over 3 sec for 19,365 Physical damage and an additional 58,095 Bleed damage over 6 sec.    Awards 3 combo points. ]]

        addAbility( "ashamanes_frenzy", {
            id = 210722,
            spend = -3,
            spend_type = 'combo_points',
            cast = 0,
            gcdType = "spell",
            cooldown = 75,
            min_range = 0,
            max_range = 0,
            toggle = 'artifact',
            known = function() return equipped.fangs_of_ashamane end,
        } )

        addHandler( "ashamanes_frenzy", function ()
            removeStack( "bloodtalons" )
        end )


        -- Barkskin
        --[[ Your skin becomes as tough as bark, reducing all damage you take by 20% and preventing damage from delaying your spellcasts. Lasts 12 sec.    Usable while stunned, frozen, incapacitated, feared, or asleep, and in all shapeshift forms. ]]

        addAbility( "barkskin", {
            id = 22812,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            cooldown = 60,
            min_range = 0,
            max_range = 0,
        } )

        addHandler( "barkskin", function ()
            applyBuff( 'barkskin', 12 )
        end )


        -- Bear Form
        --[[ Shapeshift into Bear Form, increasing armor by 200% and Stamina by 55%, granting protection from Polymorph effects, and increasing threat generation.  The act of shapeshifting frees you from movement impairing effects. ]]

        addAbility( "bear_form", {
            id = 5487,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            cooldown = 0,
            min_range = 0,
            max_range = 0,
            usable = function() return buff.bear_form.down end,
        } )

        addHandler( "bear_form", function ()
            applyBuff( "bear_form" )
            removeBuff( "cat_form" )
            removeBuff( "travel_form" )
            removeBuff( "moonkin_form" )
        end )


        -- Berserk
        --[[ Reduces the cost of all Cat Form abilities by 50% and increases maximum Energy by 50 for 15 sec. Requires Cat Form. ]]

        addAbility( "berserk", {
            id = 106951,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            cooldown = 180,
            min_range = 0,
            max_range = 0,
            usable = function () return buff.cat_form.up end,
            toggle = "cooldowns",
            notalent = 'incarnation_king_of_the_jungle'
        } )

        addHandler( "berserk", function ()
            applyBuff( "berserk", 15 )
        end )


        -- Bristling Fur
        --[[ Bristle your fur, causing you to generate Rage based on damage taken for 8 sec. ]]

        addAbility( "bristling_fur", {
            id = 155835,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            talent = "bristling_fur",
            cooldown = 40,
            min_range = 0,
            max_range = 0,
        } )

        addHandler( "bristling_fur", function ()
            applyBuff( 'bristling_fur', 8 )
        end )


        -- Brutal Slash
        --[[ Strikes all nearby enemies with a massive slash, inflicting 95880.1 to 105663.3 Physical damage. Awards 1 combo point. Maximum 3 charges. ]]

        addAbility( "brutal_slash", {
            id = 202028,
            spend = 20,
            spend_type = "energy",
            cast = 0,
            gcdType = "spell",
            talent = "brutal_slash",
            cooldown = 12,
            charges = 3,
            recharge = 12,
            min_range = 0,
            max_range = 8,
        } )

        modifyAbility( "brutal_slash", "cooldown", function( x )
            return x * haste
        end )
        
        modifyAbility( "brutal_slash", "recharge", function( x )
            return x * haste
        end )

        addHandler( "brutal_slash", function ()
            gain( 1, "combo_points" )
            removeStack( "bloodtalons" )
        end )


        -- Cat Form
        --[[ Shapeshift into Cat Form, increasing movement speed by 30%, granting protection from Polymorph effects, and reducing falling damage.  The act of shapeshifting frees you from movement impairing effects. ]]

        addAbility( "cat_form", {
            id = 768,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            cooldown = 0,
            min_range = 0,
            max_range = 0,
            passive = true,
            usable = function () return buff.cat_form.down end,
        } )

        addHandler( "cat_form", function ()
            applyBuff( "cat_form" )
            removeBuff( "bear_form" )
            removeBuff( "moonkin_form" )
            removeBuff( "travel_form" )
        end )


        -- Dash
        --[[ Activates Cat Form and increases movement speed by 70% while in Cat Form for 15 sec. ]]

        addAbility( "dash", {
            id = 1850,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            cooldown = 180,
            min_range = 0,
            max_range = 0,
        } )

        addHandler( "dash", function ()
            applyBuff( "cat_form" )
            removeBuff( "bear_form" )
            removeBuff( "moonkin_form" )
            removeBuff( "travel_form" )
            applyBuff( "dash" )
        end )


        -- Displacer Beast
        --[[ Teleports you up to 20 yards forward, activating Cat Form and increasing your movement speed by 50% for 2 sec. ]]

        addAbility( "displacer_beast", {
            id = 102280,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            talent = "displacer_beast",
            cooldown = 30,
            min_range = 0,
            max_range = 0,
        } )

        addHandler( "displacer_beast", function ()
            applyBuff( "cat_form" )
            removeBuff( "bear_form" )
            removeBuff( "moonkin_form" )
            removeBuff( "travel_form" )
            applyBuff( "displacer_beast", 2 )
        end )


        -- Elune's Guidance
        --[[ Immediately gain 5 combo points and an additional 1 combo point every 1 sec for 8 sec. ]]

        addAbility( "elunes_guidance", {
            id = 202060,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            talent = "elunes_guidance",
            cooldown = 30,
            min_range = 0,
            max_range = 0,
        } )

        addHandler( "elunes_guidance", function ()
            gain( 5, "combo_points" )
            applyBuff( "elunes_guidance" )
        end )


        -- Entangling Roots
        --[[ Roots the target in place for 30 sec.  Damage may cancel the effect. ]]

        addAbility( "entangling_roots", {
            id = 339,
            spend = 10,
            spend_type = "mana",
            cast = 1.7,
            gcdType = "spell",
            cooldown = 0,
            min_range = 0,
            max_range = 35,
        } )

        modifyAbility( "entangling_roots", "cast", function( x )
            if buff.predatory_swiftness.up then return 0 end
            return x * haste
        end )

        modifyAbility( "entangling_roots", "cooldown", function( x )
            return x * haste
        end )
        
        addHandler( "entangling_roots", function ()
            removeBuff( "predatory_swiftness" )
            if talent.bloodtalons.enabled then applyBuff( "bloodtalons", 30, 2 ) end
        end )


        -- Ferocious Bite
        --[[ Finishing move that causes Physical damage per combo point and consumes up to 25 additional Energy to increase damage by up to 100%.  When used on targets below 25% health, Ferocious Bite will also refresh the duration of your Rip on your target.     1 point  : 3,294 damage   2 points: 6,588 damage   3 points: 9,883 damage   4 points: 13,177 damage   5 points: 16,472 damage ]]

        addAbility( "ferocious_bite", {
            id = 22568,
            spend = 25,
            spend_type = "energy",
            cast = 0,
            gcdType = "spell",
            cooldown = 0,
            min_range = 0,
            max_range = 0,
            usable = function () return buff.cat_form.up and combo_points.current > 0 end,
        } )

        addHandler( "ferocious_bite", function ()
            spend( min( 5, combo_points.current ), "combo_points" )
            spend( min( 25, energy.current ), "energy" )
            removeStack( "bloodtalons" )
        end )


        -- Frenzied Regeneration
        --[[ Heals you for 50% of all damage taken in the last 5 sec over 3 sec, minimum 5% of maximum health. ]]

        addAbility( "frenzied_regeneration", {
            id = 22842,
            spend = 10,
            spend_type = "rage",
            cast = 0,
            gcdType = "spell",
            cooldown = 24,
            charges = 2,
            recharge = 24,
            min_range = 0,
            max_range = 0,
            usable = function () return buff.bear_form.up end,
        } )

        addHandler( "frenzied_regeneration", function ()
            applyBuff( "frenzied_regeneration", 3 )
            gain( health.max * 0.05, "health" )
        end )


        -- Growl
        --[[ Taunts the target to attack you, and increases threat that you generate against the target for 3 sec. ]]

        addAbility( "growl", {
            id = 6795,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            cooldown = 8,
            min_range = 0,
            max_range = 30,
            usable = function () return buff.bear_form.up end,
        } )

        addHandler( "growl", function ()
            applyDebuff( "target", "growl" )
        end )


        -- Incarnation: King of the Jungle
        --[[ An improved Cat Form that allows the use of Prowl while in combat, causes Shred and Rake to deal damage as if stealth were active, reduces the cost of all Cat Form abilities by 60%, and increases maximum Energy by 50.  Lasts 30 sec. You may shapeshift in and out of this improved Cat Form for its duration. ]]

        addAbility( "incarnation_king_of_the_jungle", {
            id = 102543,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            talent = "incarnation_king_of_the_jungle",
            toggle = 'cooldowns',
            cooldown = 180,
            min_range = 0,
            max_range = 0,
        } )

        addHandler( "incarnation", function ()
            applyBuff( "incarnation", 30 )
            energy.max = energy.max + 50

            applyBuff( "cat_form" )
            removeBuff( "bear_form" )
            removeBuff( "travel_form" )
            removeBuff( "moonkin_form" )
        end )


        -- Ironfur
        --[[ Increases armor by 80% for 6 sec. Multiple uses of this ability may overlap. ]]

        addAbility( "ironfur", {
            id = 192081,
            spend = 45,
            spend_type = "rage",
            cast = 0,
            gcdType = "spell",
            cooldown = 0.5,
            min_range = 0,
            max_range = 0,
            usable = function () return buff.bear_form.up end,
        } )

        addHandler( "ironfur", function ()
            applyBuff( "ironfur", buff.ironfur.up and buff.ironfur.remains + 6 or 6 )
        end )


        -- Healing Touch
        --[[ Heals a friendly target for 23,360. ]]

        addAbility( "healing_touch", {
            id = 5185,
            spend = 9,
            spend_type = "mana",
            cast = 2.5,
            gcdType = "spell",
            cooldown = 0,
            min_range = 0,
            max_range = 40,
        } )

        modifyAbility( "healing_touch", "cast", function( x )
            if buff.predatory_swiftness.up then return 0 end
            return x * haste
        end )

        addHandler( "healing_touch", function ()
            if buff.predatory_swiftness.down then
                removeBuff( "cat_form" )
                removeBuff( "bear_form" )
                removeBuff( "travel_form" )
            end
            removeStack( "predatory_swiftness" )
        end )


        -- Incapacitating Roar
        --[[ Invokes the spirit of Ursol to let loose a deafening roar, incapacitating all enemies within 20 yards for 3 sec. Damage will cancel the effect. Usable in all shapeshift forms. ]]

        addAbility( "incapacitating_roar", {
            id = 99,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            cooldown = 30,
            min_range = 0,
            max_range = 0,
        } )

        addHandler( "incapacitating_roar", function ()
            applyDebuff( "target", "incapacitating_roar", 3 )
        end )


        -- Incarnation: Guardian of Ursoc
        --[[ An improved Bear Form that reduces the cooldown on all melee damage abilities and Growl to 1.5 sec, causes Mangle to hit up to 3 targets, and increases armor by 15%.    Lasts 30 sec. You may freely shapeshift in and out of this improved Bear Form for its duration. ]]

        addAbility( "incarnation_guardian_of_ursoc", {
            id = 102558,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            talent = "incarnation_guardian_of_ursoc",
            cooldown = 180,
            min_range = 0,
            max_range = 0,
        } )

        addHandler( "incarnation_guardian_of_ursoc", function ()
            applyBuff( "incarnation_guardian_of_ursoc", 30 )
        end )


        -- Ironfur
        --[[ Increases armor by 65% for 6 sec. Multiple uses of this ability may overlap. ]]

        addAbility( "ironfur", {
            id = 192081,
            spend = 45,
            min_cost = 45,
            spend_type = "rage",
            cast = 0,
            gcdType = "spell",
            cooldown = 0.5,
            min_range = 0,
            max_range = 0,
        } )

        addHandler( "ironfur", function ()
            addStack( "ironfur", 6, 1 )
        end )


        -- Maim
        --[[ Finishing move that causes Physical damage and stuns the target. Damage and duration increased per combo point:     1 point  : 5445.0 to 6000.6 damage, 1 sec   2 points: 10890.1 to 12001.3 damage, 2 sec   3 points: 16335.1 to 18001.9 damage, 3 sec   4 points: 21780.2 to 24002.5 damage, 4 sec   5 points: 27225.2 to 30003.2 damage, 5 sec ]]

        addAbility( "maim", {
            id = 22570,
            spend = 35,
            spend_type = "energy",
            cast = 0,
            gcdType = "spell",
            cooldown = 10,
            min_range = 0,
            max_range = 0,
            usable = function () return buff.cat_form.up and combo_points.current > 0 end,
        } )

        addHandler( "maim", function ()
            applyDebuff( "target", "maim", combo_points.current )
            spend( combo_points.current, "combo_points" )
            removeStack( "bloodtalons" )
        end )


        -- Mangle
        --[[ Mangle the target for 15019.5 to 16552.0 Physical damage.  Generates 5 Rage. ]]

        addAbility( "mangle", {
            id = 33917,
            spend = -5,
            spend_type = "rage",
            cast = 0,
            gcdType = "spell",
            cooldown = 6,
            min_range = 0,
            max_range = 0,
            usable = function () return buff.bear_form.up end,
        } )

        addHandler( "mangle", function ()
            removeStack( "bloodtalons" )
        end )


        -- Mass Entanglement
        --[[ Roots the target in place for 30 sec and spreads to additional nearby enemies. Damage may interrupt the effect. Usable in all shapeshift forms. ]]

        addAbility( "mass_entanglement", {
            id = 102359,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            talent = "mass_entanglement",
            cooldown = 30,
            min_range = 0,
            max_range = 30,
            known = function () return talent.mass_entanglement.enabled end,
        } )

        addHandler( "mass_entanglement", function ()
            applyDebuff( "target", "mass_entanglement" )
        end )


        -- Maul
        --[[ Maul the target for 41,615 Physical damage. ]]

        addAbility( "maul", {
            id = 6807,
            spend = 45,
            min_cost = 45,
            spend_type = "rage",
            cast = 0,
            gcdType = "spell",
            cooldown = 0,
            min_range = 0,
            max_range = 0,
        } )

        addHandler( "maul", function ()
            -- proto
        end )


        -- Mighty Bash
        --[[ Invokes the spirit of Ursoc to stun the target for 5 sec. Usable in all shapeshift forms. ]]

        addAbility( "mighty_bash", {
            id = 5211,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            talent = "mighty_bash",
            cooldown = 50,
            min_range = 0,
            max_range = 0,
            known = function () return talent.mighty_bash.enabled end,
        } )

        addHandler( "mighty_bash", function ()
            applyDebuff( "target", "mighty_bash" )
        end )


        -- Moonfire
        --[[ A quick beam of lunar light burns the enemy for 581 Arcane damage and then an additional 2,525 Arcane damage over 16 sec. Usable while in Bear Form. ]]

        addAbility( "moonfire", {
            id = 8921,
            spend = function ()
                if talent.lunar_inspiration.enabled then
                    if buff.cat_form.enabled then return 30, "energy"
                    elseif buff.bear_form.enabled then return 0, "rage" end
                end
                return 0, "mana"
            end,
            cast = 0,
            gcdType = "spell",
            cooldown = 0,
            min_range = 0,
            max_range = 40,
            usable = function () return talent.lunar_inspiration.enabled or ( buff.cat_form.down and buff.bear_form.down ) end,
        } )

        addHandler( "moonfire", function ()
            applyDebuff( "target", "moonfire", 16 )
        end )


        -- Moonkin Form
        --[[ Shapeshift into Moonkin Form, increasing your armor by 200%, and granting protection from Polymorph effects.  The act of shapeshifting frees you from  movement impairing effects. ]]

        addAbility( "moonkin_form", {
            id = 197625,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            cooldown = 0,
            min_range = 0,
            max_range = 0,
            usable = function () return talent.balance_affinity.enabled end,
        } )

        addHandler( "moonkin_form", function ()
            applyBuff( "moonkin_form" )
            removeBuff( "cat_form" )
            removeBuff( "bear_form" )
            removeBuff( "travel_form" )
        end )


        -- Prowl
        --[[ Activates Cat Form and places you into stealth until cancelled. ]]

        addAbility( "prowl", {
            id = 5215,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            cooldown = 10,
            min_range = 0,
            max_range = 0,
            passive = true,
            usable = function () return not buff.prowl.up end,
        } )

        modifyAbility( 'prowl', 'cooldown', function( x )
            if buff.prowl.up then return 0 end
            return x
        end )

        addHandler( "prowl", function ()
            applyBuff( "cat_form" )
            applyBuff( "prowl" )
            removeBuff( "moonkin_form" )
            removeBuff( "bear_form" )
            removeBuff( "travel_form" )
        end )


        -- Pulverize
        --[[ A devastating blow that consumes 2 stacks of your Thrash on the target to deal 79,072 Physical damage, and reduces all damage you take by 9% for 20 sec. ]]

        addAbility( "pulverize", {
            id = 80313,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            talent = "pulverize",
            cooldown = 0,
            min_range = 0,
            max_range = 0,
            usable = function () return debuff.thrash_bear.stack >= 2 end,
        } )

        addHandler( "pulverize", function ()
            if debuff.thrash_bear.stack > 2 then
                applyDebuff( "target", "thrash_bear", debuff.thrash_bear.remains, debuff.thrash_bear.stack - 2 )
            else
                removeDebuff( "target", "thrash_bear" )
            end
            applyBuff( "pulverize", 20 )
        end )


        -- Rage of the Sleeper
        --[[ Unleashes the rage of Ursoc for 10 sec, preventing 25% of all damage you take and reflecting 21,062 Nature damage back at your attackers. ]]

        addAbility( "rage_of_the_sleeper", {
            id = 200851,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            cooldown = 90,
            min_range = 0,
            max_range = 0,
            toggle = 'artifact',
            known = function () return equipped.claws_of_ursoc end,
        } )

        addHandler( "rage_of_the_sleeper", function ()
            applyBuff( "rage_of_the_sleeper", 10 )
        end )


        -- Rake
        --[[ Rake the target for 5,406 Bleed damage and an additional 27,030 Bleed damage over 10.1 sec. Reduces the target's movement speed by 50% for 12 sec.   While stealthed, Rake will also stun the target for 4 sec, and deal 100% increased damage.  Awards 1 combo point. ]]

        addAbility( "rake", {
            id = 1822,
            spend = 35,
            spend_type = "energy",
            cast = 0,
            gcdType = "spell",
            cooldown = 0,
            min_range = 0,
            max_range = 0,
            cycle = 'rake',
            usable = function () return buff.cat_form.up end,
        } )

        modifyAbility( "rake", "spend", function( x )
            return buff.berserk.up and x * 0.5 or x 
        end )

        addHandler( "rake", function ()
            applyDebuff( "target", "rake" )
            debuff.rip.pmultiplier = persistent_multiplier

            gain( 1, "combo_points" )
            removeStack( "bloodtalons" )
        end )


        -- Rebirth
        --[[ Returns the spirit to the body, restoring a dead target to life with 60% health and 20% mana. Castable in combat. ]]

        addAbility( "rebirth", {
            id = 20484,
            spend = 0,
            spend_type = "mana",
            cast = 0,
            gcdType = "spell",
            cooldown = 600,
            min_range = 0,
            max_range = 40,
        } )



        addHandler( "rebirth", function ()
            -- proto
        end )


        -- Regrowth
        --[[ Heals a friendly target for 18,169 and another 3,390 over 12 sec. ]]

        addAbility( "regrowth", {
            id = 8936,
            spend = 0.19,
            spend_type = "mana",
            cast = 1.5,
            gcdType = "spell",
            cooldown = 0,
            min_range = 0,
            max_range = 40,
            passive = true, 
            usable = function ()
                if not talent.bloodtalons.enabled then return false end
                if buff.bloodtalons.up then return false end

                if buff.cat_form.up then
                    return not settings.regrowth_instant or buff.predatory_swiftness.up
                end

                return true
            end,
        } )

        modifyAbility( "regrowth", "cast", function( x )
            if buff.predatory_swiftness.up then return 0 end
            return x * haste
        end )

        addHandler( "regrowth", function ()
            if buff.predatory_swiftness.down then
                removeBuff( "cat_form" )
                removeBuff( "bear_form" )
                removeBuff( "travel_form" )
            end
            removeBuff( "predatory_swiftness" )
            if talent.bloodtalons.enabled then
                applyBuff( "bloodtalons", 30, 2 )
            end
            applyBuff( "regrowth", 12 )
        end )


        -- Rejuvenation
        --[[ Heals the target for 20,068 over 15 sec. ]]

        addAbility( "rejuvenation", {
            id = 774,
            spend = 0.10,
            spend_type = "mana",
            cast = 0,
            gcdType = "spell",
            cooldown = 0,
            min_range = 0,
            max_range = 40,
        } )

        addHandler( "rejuvenation", function ()
            removeBuff( "cat_form" )
            removeBuff( "bear_form" )
            removeBuff( "travel_form" )
        end )


        -- Remove Corruption
        --[[ Nullifies corrupting effects on the friendly target, removing all Curse and Poison effects. ]]

        addAbility( "remove_corruption", {
            id = 2782,
            spend = 0.13,
            spend_type = "mana",
            cast = 0,
            gcdType = "spell",
            cooldown = 8,
            min_range = 0,
            max_range = 40,
        } )

        addHandler( "remove_corruption", function ()
            -- proto
        end )


        -- Renewal
        --[[ Instantly heals you for 30% of maximum health. Usable in all shapeshift forms. ]]

        addAbility( "renewal", {
            id = 108238,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            talent = "renewal",
            cooldown = 90,
            min_range = 0,
            max_range = 0,
        } )

        addHandler( "renewal", function ()
            health.actual = min( health.max, health.actual + ( health.max * 0.3 ) )
        end )


        -- Revive
        --[[ Returns the spirit to the body, restoring a dead target to life with 35% of maximum health and mana. Not castable in combat. ]]

        addAbility( "revive", {
            id = 50769,
            spend = 0.04,
            spend_type = "mana",
            cast = 10,
            gcdType = "spell",
            cooldown = 0,
            min_range = 0,
            max_range = 40,
        } )

        modifyAbility( "revive", "cast", function( x ) return x * haste end )

        addHandler( "revive", function ()
            -- Waggle your fingers until your friend's not dead.
        end )


        -- Rip
        --[[ Finishing move that causes Bleed damage over 16.1 sec. Damage increases per combo point:     1 point : 11,376 damage   2 points: 22,752 damage   3 points: 34,128 damage   4 points: 45,504 damage   5 points: 56,880 damage ]]

        addAbility( "rip", {
            id = 1079,
            spend = 30,
            spend_type = "energy",
            cast = 0,
            gcdType = "spell",
            cooldown = 0,
            min_range = 0,
            max_range = 0,
            cycle = 'rip',
            usable = function () return buff.cat_form.up and combo_points.current > 0 end,
        } )

        addHandler( "rip", function ()
            spend( combo_points.current, "combo_points" )
            applyDebuff( "target", "rip" )
            debuff.rip.pmultiplier = persistent_multiplier
            removeStack( "bloodtalons" )
        end )


        -- Savage Roar
        --[[ Finishing move that grants 25% increased damage to your Cat Form attacks for their full duration. Lasts longer per combo point:     1 point  : 8 seconds   2 points: 12 seconds   3 points: 16 seconds   4 points: 20 seconds   5 points: 24 seconds ]]

        addAbility( "savage_roar", {
            id = 52610,
            spend = 40,
            spend_type = "energy",
            cast = 0,
            gcdType = "spell",
            talent = "savage_roar",
            cooldown = 0,
            min_range = 0,
            max_range = 100,
            talent = 'savage_roar',
            usable = function () return buff.cat_form.up and combo_points.current > 0 end,
        } )

        addHandler( "savage_roar", function ()
            local cost = min( 5, combo_points.current )
            spend( cost, "combo_points" )
            applyBuff( "savage_roar", 6 + ( 6 * cost ) )
        end )


        -- Shred
        --[[ Shred the target, causing 32,907 to 36,264 Physical damage to the target. Deals 20% increased damage against bleeding targets.  While stealthed, Shred deals 50% increased damage, and has double the chance to critically strike.  Awards 1 combo point. ]]

        addAbility( "shred", {
            id = 5221,
            spend = 40,
            spend_type = "energy",
            cast = 0,
            gcdType = "spell",
            cooldown = 0,
            min_range = 0,
            max_range = 0,
        } )

        modifyAbility( "shred", "spend", function( x )
            if buff.clearcasting.up then return 0
            elseif buff.berserk.up then return x * 0.5 end
            return x
        end )

        addHandler( "shred", function ()
            gain( 1, "combo_points" )
            removeStack( "bloodtalons" )
            removeStack( "clearcasting" )
        end )


        -- Skull Bash
        --[[ You charge and bash the target's skull, interrupting spellcasting and preventing any spell in that school from being cast for 4 sec. ]]

        addAbility( "skull_bash", {
            id = 106839,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            cooldown = 15,
            min_range = 0,
            max_range = 13,
            usable = function() return target.casting end,
            toggle = 'interrupts'
        } )

        addHandler( "skull_bash", function ()
            interrupt()
        end )


        -- Solar Wrath
        --[[ Causes 9,517 Nature damage to the target. ]]

        addAbility( "solar_wrath", {
            id = 197629,
            spend = 0.02,
            spend_type = "mana",
            cast = 1.5,
            gcdType = "spell",
            cooldown = 0,
            min_range = 0,
            max_range = 45,
        } )

        addHandler( "solar_wrath", function ()
            removeBuff( "cat_form" )
            removeBuff( "travel_form" )
            removeBuff( "bear_form" )
        end )


        -- Stampeding Roar
        --[[ Lets loose a wild roar, increasing the movement speed of all friendly players within 10 yards by 60% for 8 sec.  Using this ability outside of Bear Form or Cat Form activates Bear Form. ]]

        addAbility( "stampeding_roar", {
            id = 106898,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            cooldown = 120,
            min_range = 0,
            max_range = 10,
        } )

        modifyAbility( "stampeding_roar", "cooldown", function( x )
            if talent.guttural_roars.enabled then return x / 2 end
            return x
        end )

        addHandler( "stampeding_roar", function ()
            applyBuff( "stampeding_roar", 8 )
            if buff.bear_form.down and buff.cat_form.down then
                applyBuff( "bear_form" )
                removeBuff( "moonkin_form" )
                removeBuff( "travel_form" )
            end
        end )


        -- Starsurge
        --[[ Instantly causes 21,631 Astral damage to the target.  Also increase the damage of your next Lunar Strike, and your next Solar Wrath, by 20%. ]]

        addAbility( "starsurge", {
            id = 197626,
            spend = 0.03,
            spend_type = "mana",
            cast = 2,
            gcdType = "spell",
            cooldown = 10,
            min_range = 0,
            max_range = 45,
        } )

        addHandler( "starsurge", function ()
            applyBuff( "starsurge" )
        end )


        -- Sunfire
        --[[ Burns the enemy for 4,760 Nature damage and then an additional 15,547 Nature damage over 12 sec to the primary target and all enemies within 5 yards. ]]

        addAbility( "sunfire", {
            id = 197630,
            spend = 12,
            spend_type = "mana",
            cast = 0,
            gcdType = "spell",
            cooldown = 0,
            min_range = 0,
            max_range = 45,
            known = function () return talent.balance_affinity.enabled end,
        } )

        addHandler( "sunfire", function ()
            applyDebuff( "sunfire", 12 )
        end )


        -- Survival Instincts
        --[[ Reduces all damage you take by 50% for 6 sec.  Max 2 charges. ]]

        addAbility( "survival_instincts", {
            id = 61336,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            cooldown = 120,
            charges = 2,
            recharge = 120,
            min_range = 0,
            max_range = 0,
        } )

        addHandler( "survival_instincts", function ()
            applyBuff( "survival_instincts", 6 )
        end )


        -- Swiftmend
        --[[ Instantly heals a friendly target for 39,972. ]]

        addAbility( "swiftmend", {
            id = 18562,
            spend = 14,
            spend_type = "mana",
            cast = 0,
            gcdType = "spell",
            cooldown = 30,
            charges = 1,
            recharge = 30,
            min_range = 0,
            max_range = 40,
            known = function () return talent.balance_affinity.enabled end,
        } )

        addHandler( "swiftmend", function ()
            -- proto
        end )


        -- Swipe
        --[[ Swipe nearby enemies, inflicting Physical damage. Damage varies by shapeshift form. ]]

        addAbility( "swipe", {
            id = 213764,
            spend = 0,
            spend_type = "rage",
            cast = 0,
            gcdType = "melee",
            cooldown = 0,
            min_range = 0,
            max_range = 8,
            known = function() return buff.bear_form.up end,
        }, 213771, 106785 )

        modifyAbility( "swipe", "id", function( x )
            if buff.bear_form.up then return 213771
            elseif buff.cat_form.up then return 106785 end
            return x
        end )

        modifyAbility( "swipe", "spend", function( x )
            if buff.cat_form.up then
                if buff.clearcasting.up then return 0 end
                if buff.berserk.up then return 20 end
                return 40
            end
            return x
        end )

        modifyAbility( "swipe", "spend_type", function( x )
            if buff.cat_form.up then return "energy" end
            return x
        end )

        addHandler( "swipe", function ()
            if buff.cat_form.up then
                gain( 1, "combo_points" ) 
                removeStack( "bloodtalons" )
                removeStack( "clearcasting" )
            end
        end )


        -- Teleport: Moonglade
        --[[ Teleport to the Moonglade.  Casting Teleport: Moonglade while in Moonglade will return you back to near your departure point. ]]

        addAbility( "teleport_moonglade", {
            id = 18960,
            spend = 0.32,
            spend_type = "mana",
            cast = 10,
            gcdType = "spell",
            cooldown = 0,
            min_range = 0,
            max_range = 0,
        } )

        modifyAbility( "teleport_moonglade", "cast", function( x ) return x * haste end )

        addHandler( "teleport_moonglade", function ()
            -- bye
        end )


        -- Thrash
        --[[ Thrash all nearby enemies, dealing immediate physical damage and periodic bleed damage. Damage varies by shapeshift form. ]]

        addAbility( "thrash", {
            id = 106832,
            spend = 45,
            spend_type = "energy",
            cast = 0,
            gcdType = "spell",
            cooldown = 0,
            min_range = 0,
            max_range = 0,
            aura = 'thrash_cat',
            cycle = 'thrash_cat',
            known = function () return buff.bear_form.up or buff.cat_form.up end,
        }, 77758, 106830 )

        modifyAbility( "thrash", "id", function( x )
            if buff.cat_form.up then return 106830
            elseif buff.bear_form.up then return 77758 end
            return x
        end )

        modifyAbility( "thrash", "spend", function( x )
            if buff.cat_form.up then
                if buff.clearcasting.up then return 0
                elseif buff.berserk.up then return x * 0.5 end
            elseif buff.bear_form.up then
                return -4
            end
        end )

        modifyAbility( "thrash", "spend_type", function( x )
            if buff.bear_form.up then return "rage" end
            return x
        end )

        modifyAbility( "thrash", "aura", function( x )
            if buff.bear_form.up then return "thrash_bear" end
            return x
        end )
        
        modifyAbility( "thrash", "cycle", function( x )
            if buff.bear_form.up then return "thrash_bear" end
            return x
        end )

        modifyAbility( "thrash", "cooldown", function( x )
            if buff.bear_form.up then return 6 * haste end
            return x
        end )

        addHandler( "thrash", function ()
            if buff.cat_form.up then
                applyDebuff( "target", "thrash_cat" )
                active_dot.thrash_cat = max( active_dot.thrash_cat, true_active_enemies )
                removeStack( "bloodtalons" )
                removeStack( "clearcasting" )
                if target.within8 then gain( 1, "combo_points" ) end
            elseif buff.bear_form.up then
                applyDebuff( "target", "thrash_bear", 15, min( 5, debuff.thrash_bear.stack + 1 ) )
                active_dot.thrash_bear = active_enemies
            end
        end )


        -- Tiger's Fury
        --[[ Instantly restores 60 Energy, and increases the damage of all your attacks by 15% for their full duration. Lasts 8 sec. ]]

        addAbility( "tigers_fury", {
            id = 5217,
            spend = -60,
            spend_type = "energy",
            cast = 0,
            gcdType = "spell",
            cooldown = 30,
            min_range = 0,
            max_range = 0,
        } )

        addHandler( "tigers_fury", function ()
            applyBuff( "tigers_fury" )
        end )


        -- Travel Form
        --[[ Shapeshift into a travel form appropriate to your current location, increasing movement speed on land, in water, or in the air, and granting protection from Polymorph effects.  The act of shapeshifting frees you from movement impairing effects.  Land speed increased when used out of combat.  This effect is disabled in battlegrounds and arenas.   ]]

        addAbility( "travel_form", {
            id = 783,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            cooldown = 0,
            min_range = 0,
            max_range = 0,
            known = function () return buff.travel_form.down end,
        } )

        addHandler( "travel_form", function ()
            applyBuff( "travel_form" )
            removeBuff( "cat_form" )
            removeBuff( "bear_form" )
            removeBuff( "moonkin_form" )
        end )


        -- Typhoon
        --[[ Strikes targets within 15 yards in front of you with a violent Typhoon, knocking them back and dazing them for 6 sec. Usable in all shapeshift forms. ]]

        addAbility( "typhoon", {
            id = 132469,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            talent = "typhoon",
            cooldown = 30,
            min_range = 0,
            max_range = 15,
        } )

        addHandler( "typhoon", function ()
            applyDebuff( "target", "dazed", 6 )
        end )


        -- Wild Charge
        --[[ Fly to a nearby ally's position. ]]

        addAbility( "wild_charge", {
            id = 102401,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            talent = "wild_charge",
            cooldown = 15,
            min_range = 5,
            max_range = 25,
            usable = function () if buff.cat_form.up and target.outside8 and target.within25 then return target.exists end
                return false
            end,
        } )

        addHandler( "wild_charge", function ()
            setDistance( 5 )
            applyDebuff( "target", "dazed", 3 )
        end )


        -- Wild Charge
        --[[ Leap behind an enemy, dazing them for 3 sec.

        addAbility( "wild_charge", {
            id = 49376,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            talent = "wild_charge",
            cooldown = 15,
            min_range = 8,
            max_range = 25,
        } )

        addHandler( "wild_charge", function ()
            -- proto
        end ) ]]


    end


    storeDefault( [[SimC Feral: opener]], 'actionLists', 20171105.231639, [[dOZzgaGEeQ0MKQAxKY2qu0SvXnLkxg6BuQESQStv1Ef7MI9dyuiuYWqWVLCyfNxjmyGgobhKi6uiu0XusNJuPSqeYsvklwLwoOhseEkQLPe9CsMicfMkImzQA6iDrevNMkpdrPUUu2icvTvIkBMs2oLYRjv9DsftdrjZdHsDBc9zI0Ojk)vP6KevDiPkUgPsUhIchxQsFcHkwhPs1znKctUzUh0NBywaFU54iUd1vM8xjq2HjgO10o0qu4n8GJcZFjHv7ReiqMAR2jl7l1TW8d6eOHdl5J6kJkKYFnKctUzUh0hIcZpOtGg(2SS0eGLohTMqyjVUJJUimC0JHL34DVHwWWMYGH7kVCd8pIy4W)redVn6XWB4bhfM)scR2xjeEdvvd(qvifAyjKHp9DLnuen0Cd3v()iIHdn)LHuyYnZ9G(quy(bDc0W3MLLMASnsXDynqnFPJjSKx3Xrxewn2gP4oSgyy5nE3BOfmSPmy4UYl3a)Jigo8FeXW8yBKIaGB1adVHhCuy(ljSAFLq4nuvn4dvHuOHLqg(03v2qr0qZnCx5)Jigo08j7qkm5M5EqFikm)GobAyAjv6b1EvD8LogfayFaqIfa4TzzPPgBJuChwduRjaa2haShaqS3Mtqa9AE40KkJUxw7QQDuaGeZWsEDhhDr4lcviuFy5nE3BOfmSPmy4UYl3a)Jigo8FeXWeHqfc1hEdp4OW8xsy1(kHWBOQAWhQcPqdlHm8PVRSHIOHMB4UY)hrmCO5twHuyYnZ9G(quy(bDc0W3MLL2fHkeQxRjaa2haShaqS3Mtqa9AE40KkJUxw7QQDuHL86oo6IWuNueQ2TAWfHL34DVHwWWMYGH7kVCd8pIy4W)redtYjfHehfaiX3GlcVHhCuy(ljSAFLq4nuvn4dvHuOHLqg(03v2qr0qZnCx5)Jigo081vifMCZCpOpefMFqNan8ReV1Uq5muL2RbHOHcasgaG6caSpa4TzzPDpv5PZPmknFPJbaSpa4TzzPjar)ql4IDLoolQbvkTMaayFaWEaaXEBobb0R5HttQm6EzTRQ2rfwYR74OlcdrPWshQSWYB8U3qlyytzWWDLxUb(hrmC4)iIH3qPWshQSWB4bhfM)scR2xjeEdvvd(qvifAyjKHp9DLnuen0Cd3v()iIHdnFYmKctUzUh0hIcZpOtGg(vI3AxOCgQs71Gq0qbajdaqDba2ha82SS0UNQ805ugLwtaaSpaypaGyVnNGa618WPjvgDVS2vv7Ocl51DC0fHHoHWYB8U3qlyytzWWDLxUb(hrmC4)iIH3CcH3Wdokm)LewTVsi8gQQg8HQqk0WsidF67kBOiAO5gUR8)redhA(2dPWKBM7b9HOW8d6eOHFL4T2fkNHQ0EnienuaqInaOUaa7daEBwwAQX2if3H1a1AcaG9ba7bae7T5eeqVMhonPYO7L1UQAhvyjVUJJUiSsge9HL34DVHwWWMYGH7kVCd8pIy4W)redZYGOp8gEWrH5VKWQ9vcH3qv1GpufsHgwcz4tFxzdfrdn3WDL)pIy4qdn8FeXWStucaqIhHZr3balb0GWqta]] )

    storeDefault( [[SimC Feral: default]], 'actionLists', 20171105.231639, [[da0AjaqiPiTirPytIs1NeLuJIKeDkssXUiudtkDms1YevEMOeMMOKCnPi2MOu6BIQghjP05ijvRtkk3dfH9jfvoOeSqLupujzIIs0frbBKKOtIcTsss4LsrvZKKKCtszNsAPkXtHMQQ0wrrTxQ)kHgmbhwyXQQhROjRWLbBMK6ZeYOvfNMOvtss9As0SLQBRu7gPFJy4KWYr1Zfz6QCDjA7sHVJI05ffRhfrZNKW(rPTUFnYan(Dy4VrubmLrxYKXjjux1BZcJzjOok7NxBCb6qKaxZ1QNxVTnBfRNpRYNt1nItUuXz0yH5jj0KFDv3VgzGg)om8AJ4KlvCghKtmxQq8jNkLurScQqfScNCdScnhRGEtmw4l7YlJrEjTympjHwSltNrgPd5moc3iLqbJAKbZbVgBWOXASbJlLuwHcZtsOScQkz6mwGlkzKgBGjYguUxXkOsGh9MXkKKurDGv4cUi4YgJlqhIe4AUw986TgxGePKpHKF9zC1dmvQrAaBGE(BuJmQXgmIY9kwbvc8O3mwHKKkQdScxWfbNpxZ5xJmqJFhgETrCYLkoJnLv4KtLsQiwbvOcwHFPA1IvWjmTlUuHXcFzxEzmYdLGrgPd5moc3iLqbJAKbZbVgBWOXASbJlHsW4c0HibUMRvpVERXfirk5ti5xFgx9atLAKgWgON)g1iJASbJ(Cnl8RrgOXVddV2io5sfNXMYk8lvRw8mUIQj8T4sfgl8LD5LX4ispgzKoKZ4iCJucfmQrgmh8ASbJgRXgmMLr6X4c0HibUMRvpVERXfirk5ti5xFgx9atLAKgWgON)g1iJASbJ(CnR8RrgOXVddV2io5sfNXMYk8lvRwCkAeIGICsWfxQWyHVSlVmgtrJqeuKtcUrgPd5moc3iLqbJAKbZbVgBWOXASbJy0iebSclKGBCb6qKaxZ1QNxV14cKiL8jK8RpJREGPsnsdyd0ZFJAKrn2GrFU2e)AKbA87WWRnItUuXz8iIe1bXtcPpimLMmw4l7YlJXpWtaxPrgPd5moc3iLqbJAKbZbVgBWOXASbJRbEc4knUaDisGR5A1ZR3ACbsKs(es(1NXvpWuPgPbSb65VrnYOgBWOpxZw)AKbA87WWRnw4l7YlJrjDgCACscTOsjvurI6I3duuvxsf1bJmshYzCeUrkHcg1idMdEn2GrJ1ydgzKodonojH2mwHMxsfXkquZkCpaRGQOKkQdgxGoejW1CT651BnUajsjFcj)6Z4QhyQuJ0a2a983OgzuJny0NR59RrgOXVddV2yHVSlVmgpPiGNkQUKNXiJ0HCghHBKsOGrnYG5GxJny0yn2GXxPiGN1jwbvwYZyCb6qKaxZ1QNxV14cKiL8jK8RpJREGPsnsdyd0ZFJAKrn2GrFUQA9RrgOXVddV2yHVSlVmgJ0tSdkKkQMduMmJrgPd5moc3iLqbJAKbZbVgBWOXASbJfspXoOqwNyfujhOmzgJlqhIe4AUw986TgxGePKpHKF9zC1dmvQrAaBGE(BuJmQXgm6Zvv3VgzGg)om8AJ4KlvCgvLScx0b6jofFGFeY9igOXVddwbvOcwHFPA1IvWHrCeEMIjMkvFuiLexQGvq1WkKDwHl6a9e)7eY4IoHMed043HbRq2zf(LQvl(3jKXfDcnjEqykLvi7SctY(tkQGiPxs8SKZb6XkWeScnXyHVSlVmg5GioHP3JrgPd5moc3iLqbJAKbZbVgBWOXASbJlGioHP3JXfOdrcCnxREE9wJlqIuYNqYV(mU6bMk1inGnqp)nQrg1ydg95QERFnYan(Dy41gXjxQ4moj7pPOcIKEjXZsohOhRatWk0eJf(YU8YyKlvyKr6qoJJWnsjuWOgzWCWRXgmASgBW4IuHXfOdrcCnxREE9wJlqIuYNqYV(mU6bMk1inGnqp)nQrg1ydg95QUUFnYan(Dy41gXjxQ4m2uwHtovkPIyfYoRqJGlJFhexMGI3dpspScnhRqRXcFzxEzmEp8i9uCgNrgPd5moc3iLqbJAKbZbVgBWOXASbJVp8i9yCb6qKaxZ1QNxV14cKiL8jK8RpJREGPsnsdyd0ZFJAKrn2GrFUQNZVgzGg)om8AJf(YU8Yym9WHHrgPd5moc3iLqbJAKbZbVgBWOXASbJ4dhggxGoejW1CT651BnUajsjFcj)6Z4QhyQuJ0a2a983OgzuJny0NpJ1ydgr5EfRGkbE0BgRWauhL9ZNna]] )

    storeDefault( [[SimC Feral: precombat]], 'actionLists', 20171105.231639, [[dGJOeaGEbLAxiQ2MirZMIBsP(gL0Lb7uI9s2nk7hrmkbfnmb(TspgkdvKWGrugoeoiL4uck5yOYXrvLwOuXsHOfJWYr6HsINQAzcYZf1ervftvQAYqA6kUOuPdt1Zeu56IyJcQARssBwKQTJQCEOsZsKKPjsQVJQYPf6ZqfJwsDBPCsOkVgQQRHQQ6EIu(lI06qvvoNGclo1R3L5egave6hbGfDtmS9jUmv4ccNo)aP7jMrD0rcgWZGkHc4SYfeKsY5SMARHcd9JrJigDDlytCzz1RcN617YCcdGQo6hJgrm6JBa2qoHzx0XnlltoWCcdGQBHiAIdU6uah6Y3uRJhdnI5Zs1zld0Tx0QoT4nqxV4nqhjGdD5BQ1rcgWZGkHc4SYfOJeYBcfdYQxJELAadF7Lh0a2icD7fT4nqxJkHuVExMtyau1r)y0iIrpq3cr0ehC1550OtyaD8yOrmFwQoBzGU9Iw1PfVb6jzG0PM65A9I3a9plfiHSQUjb0TqXjRZ8gKwsgiDQPEUov8CtcKwGosWaEgujuaNvUaDKqEtOyqw9A0Rudy4BV8GgWgrOBVOfVb6AujCQxVlZjmaQ6OFmAeXOd8BsebcaLCts6P7KYh1rGiYWjRBHiAIdU68CA0jmGoEm0iMplvNTmq3ErR60I3a9Kmq6ut9CTEXBG(NLcKqwv3KaKqwyYfw6wO4K1zEdsljdKo1upxNkEUjbsJthjyapdQekGZkxGosiVjumiREn6vQbm8TxEqdyJi0Tx0I3aDnQKA1R3L5egavD0TqenXbxDe0LpJoEm0iMplvNTmq3ErR60I3aD9I3a9uqx(m6ibd4zqLqbCw5c0rc5nHIbz1RrVsnGHV9YdAaBeHU9Iw8gORrf(x96DzoHbqvhDlertCWvhZhstFPnD8yOrmFwQoBzGU9Iw1PfVb66fVb6v8HeYc)sB6ibd4zqLqbCw5c0rc5nHIbz1RrVsnGHV9YdAaBeHU9Iw8gORrLuQE9UmNWaOQJ(XOreJ(S4GJbihXoXLL1TqenXbxDe7exMoEm0iMplvNTmq3ErR60I3aD9I3a9uStCz6ibd4zqLqbCw5c0rc5nHIbz1RrVsnGHV9YdAaBeHU9Iw8gORrJEXBG(JTkKqw4bQB4psidbfW2gHpAKa]] )

    storeDefault( [[SimC Feral: generator]], 'actionLists', 20171105.231639, [[dieKpaqiIQAtKQ(erPYOuuoLIQvruIxrukDlIsv7cvnmI4ykPLPu6zksmnIQ01afTnqH(gPuJtrsDoqbRJOK08Ou19OuAFukoirLfsu8qsjtKOKQlsPYgjkfFKOK4KksDtI0oPKLQiEQWujv2Qsr7f6VkXGfDyPwSQ6XuzYQYLr2mP4ZkKrdQonjVguA2u1Tbz3a)gLHRGJtuflNWZPy6QCDuz7kv9DLcJNOKY5vQSEfjz(ku7xY4kQdd7a93tp8Jrmqov7vtvFkgaTwLmfmK1jnnN)qzWyc5P2qO1wjRAVkrcmYVQT8Q9wyaJWjudhgyiN7umGb1HwROomSd0Fp9qzWiCc1WHr7o1EAHaeKImvAtLRvQVshd6ZwgykWz4DCcbbUkTVsyIHCFLxD7W4l4U2Vy8TbogtdEkxFmbgagGWqk7TzlSAicdmSAicdzeCx7Rm8Tbogtip1gcT2kzv7vjymHmmoHJmOo8Wql4KdwPS9eebo8JHu2ZQHimWdT2I6WWoq)90dLbJWjudhgog0NTmWuGZW74eccCvAVTvUTs9v(50OHN8CaYSmIt9AGJ4FSnavQVYzv(50OH)7zS31EgWWZnu54Xvk)kV2tGJ)7zS31EgWWtG(7PxLZRuFLZQ8ZPrdVP33JOfbRf8CdvoECLYVYR9e44n9(EeTiyTGNa93tVkNJHCFLxD7WOnWBOgqMfnccmv7WyAWt56JjWaWaegszVnBHvdryGHvdryiNbEd1as2zQu2iiWuTdJjKNAdHwBLSQ9QemMqggNWrguhEyOfCYbRu2EcIah(Xqk7z1qeg4Hwtb1HHDG(7PhkdgHtOgomU2tGJN8CaYSmIt9AGJ4jq)90Rs9v6yqF2YatbodVJtiiWvPTvkPs9vsasmAhVJtiiWvPn2wz7ofdWRHemNIXzw(QJ4DmZvPSTYTWed5(kV62Hb55aKzzeN61ahHX0GNY1htGbGbimKYEB2cRgIWadRgIWWophGKDMkLv4uVg4imMqEQneATvYQ2RsWyczyCchzqD4HHwWjhSsz7jicC4hdPSNvdryGhAjVOomSd0Fp9qzWiCc1WHX1EcC8Fb31(fJVnW5jq)90Rs9v2UtTNwiabPitL2yBLWagY9vE1TdJdUOnWxC9HX0GNY1htGbGbimKYEB2cRgIWadRgIWqhCrBGJXeYtTHqRTsw1EvcgtidJt4idQdpm0co5GvkBpbrGd)yiL9SAicd8qlyI6WWoq)90dLbJWjudhgT7u7PfcqqkYuPn2wjmIHCFLxD7WWSHAGWyAWt56JjWaWaegszVnBHvdryGHvdryeBOgimMqEQneATvYQ2RsWyczyCchzqD4HHwWjhSsz7jicC4hdPSNvdryGhAbJOomSd0Fp9qzWiCc1WHHJb9zldmf4m8ooHGaxL2xjmRuFLeGeJ2X74eccCvAJTv2UtXa8IgwI3XmxL6R8XoErdlXpaX5p1GxrIkTVYT8RvQVYpNgn8NAejmlA4e745gQuFLZQ8ZPrd)3ZyVR9mGHNBOYXJRu(vETNah)3ZyVR9mGHNa93tVkNxP(kNvP8R8ApboEfW1cqFkgGNa93tVkhpUshJ5FSna8kGRfG(umaVGGAfWuPnvUo1voVs9vk)k)CA0WRaUwa6tXa8Cdyi3x5v3ommW7hBdiY)WyAWt56JjWaWaegszVnBHvdryGHvdryeW7hBdiY)Wyc5P2qO1wjRAVkbJjKHXjCKb1HhgAbNCWkLTNGiWHFmKYEwneHbEOL2OomSd0Fp9qzWiCc1WHHJb9zldmf4m8ooHGaxL2xjmRuFLZQu(vEkhSkWOkhpUYzvk)kV2tGJ)7zS31EgWWtG(7PxL6RuqqTcyQ0(kFCI(umqLYsLs4NsLZRC84kNv51EcC8FpJ9U2ZagEc0Fp9QuFLFonA4)Eg7DTNbm8CdvQVYzvkiOwbmvAVTvUVfQ(7jErdlTiincYaVY5vQVYbsyuMJa3ceN)udEfjQ0MkFSJx0Ws8dqC(tn4vKOszPsj8tTKkNx58k1x51Ir0XFkiA5ylpfvPSVsbb1kGPsBQ8uoyxofeHHCFLxD7Wq0WsyOfCYbRu2EcIah(Xqk7TzlSAicdmMg8uU(ycmamaHHvdrymPHLWqoXidgUDopTCTyeDgBxXyc5P2qO1wjRAVkbJjKHXjCKb1HhgATZ5jDTyeDgugmKYEwneHbEO1uJ6WWoq)90dLbJWjudhgg6w(maNH)uKyfgwK3bxL2uPKk1xPGGAfWuP92w5Jt0NIbQuwQuc)uQuFLog0NTmWuGZW74eccCvAFLWSs9voRY2DQ90cbiifzQ0gBRCBLJhx5SkNvjjpCQHb6X750OPx2q0ddkWitLJhx5NtJgENNAHRnNcmINBOY5vQVYzvsYdNAyGE8TYZjyldmoGJeMkhpUYpNgn8FpJ9U2Zag(hBdqLZRCELZXqUVYRUDyCWfTb(IRpm0co5GvkBpbrGd)yiL92SfwneHbgtdEkxFmbgagGWWQHim0bx0g4voBDogYjgzWWTZ5PLRfJOZy7kgtip1gcT2kzv7vjymHmmoHJmOo8WqRDopPRfJOZGYGHu2ZQHimWdTGbuhg2b6VNEOmyeoHA4Wq(vAOB5ZaCg(trIvyyrEhCvAtLsQuFLccQvatL2BBLporFkgOszPsj8tPs9voRY2DQ90cbiifzQ0gBRCBLJhx5Sk)CA0W78ulCT5uGr8CdvQVssE4udd0J3ZPrtVSHOhguGrMk1x5Skj5Htnmqp(w55eSLbghWrctLJhx5NtJg(VNXEx7zad)JTbOY5voVY5yi3x5v3omo4I2aFX1hgAbNCWkLTNGiWHFmKYEB2cRgIWaJPbpLRpMadadqyy1qeg6GlAd8kNTDogYjgzWWTZ5PLRfJOZy7kgtip1gcT2kzv7vjymHmmoHJmOo8WqRDopPRfJOZGYGHu2ZQHimWdTwLG6WWoq)90dLbJWjudhgog0NTmWuGZW74eccCvAFLWSs9voRYzvoRY1kLTvc1YAlo4TyezQu2xPdElgrMfnI2DkgO9voVszPYvyw58khpUYzvoRsh8wmImlAeT7umq7R0Mk3YdJWyL6R8uquL2u5QKkNx58kNJHCFLxD7W4l4U2Vy8TbogtdEkxFmbgagGWqk7TzlSAicdmSAicdzeCx7Rm8TbELZwNJXeYtTHqRTsw1EvcgtidJt4idQdpm0co5GvkBpbrGd)yiL9SAicd8qR1vuhg2b6VNEOmyeoHA4WWXG(SLbMcCgEhNqqGRs7ReMvQVY2DQ90cbiifzQ0gBRCkyi3x5v3ommBOgimMg8uU(ycmamaHHu2BZwy1qegyy1qegXgQbQYzRZXyc5P2qO1wjRAVkbJjKHXjCKb1HhgAbNCWkLTNGiWHFmKYEwneHbEO16wuhg2b6VNEOmyeoHA4WWXG(SLbMcCgEhNqqGRs7ReMvQVYzv2UtTNwiabPitL2x5uQC84kV2tGJ)l4U2Vy8Tbopb6VNEvohd5(kV62HHbUGEymn4PC9XeyayacdPS3MTWQHimWWQHimc4c6HXeYtTHqRTsw1EvcgtidJt4idQdpm0co5GvkBpbrGd)yiL9SAicd8WddRgIWiuqAvPSHeTxwTYreGe9Xe4Hi]] )

    storeDefault( [[SimC Feral: sbt opener]], 'actionLists', 20171105.231639, [[dytxcaGEPcTjfyxKyBKKmBPCti6BuHDcyVIDJy)ummf53kDzIbtPHtQoiq8yQ6yKY5ij1cbslfOwSkwoupKK4POwgj1ZvPjkvWuvvMSQmDjxur1Hb9mQiDDQ0gLQYwLQ0MvO2UuvDpPkonstJkQ(UuP(RQQETcz0kOdPQYjLk5Zq4AsfDEfLprfL1rfXTH0rlFHNtGNM8YjmRlEkSr7iSOljaAtonChKXq3wfqddwAc8kbq9KMdTPjvPO5W5ouR6WSht1RWHbXx0LCZxa0Yx45e4PjVaAy2JP6v4c2esPCA7(kyBjxfHapn5zSdmw)IE2)6lLuxfVlglKYy7Xy70yhyS)m2J74XkN2UVc2wYvXv3yhyS)m23wkyQUsr9JOeeHb5qB0AwySGaVDxdd3f5r9WAXHjlrcJCF9cXaqujCyaiQegSGaVDxdddwAc8kbq9KMdTPWGL76I9YnFPcRYqXpc52VGkKkNWi3haevcNkaQZx45e4PjVaAy2JP6v4Fg7BlfmvxPO(ruccJDGX6x0Z(xFPK6Q4DXyHugBpgBNHb5qB0Aw4IIqW3)JDXZc3f5r9WAXHjlrcJCF9cXaqujCyaiQe(JIqWo7AS95INfgS0e4vcG6jnhAtHbl31f7LB(sfwLHIFeYTFbvivoHrUpaiQeovQWaqujmtrvXy7tWWMtm27Pm2vxicovc]] )

    storeDefault( [[SimC Feral: finisher]], 'actionLists', 20171105.231639, [[da0Ioaqifs2KcAukvofeSkIOYSuivDlIOODjYWKehJGwMOspdI00ev01is2MOcFtuvJtb4CervRtHumpc4EeO9rK6GkeluuLhQanrIOWfjc2iru6KeHUPK0ovklfc9uGPQqTvIi7v4VeAWKoSulwv9yjMmrDzKntL(SKA0kvDAuwTcP0RHOMTsUTQSBO(nQgovSCqpNQMUkxxrBxu67qeJxb05ffRxHuz(qA)uoegJdGeW9FrYXpaahQW6fB01hJJJnHvqAaKmi3EUUiVaGiTO2tXwUveMVWkvYrsy(5m)CL8bauGmNlabyKYX4yFmo2egJdGeW9FrYrEbauGmNlaJY0)01n57SDnjc5nmnDmDOP7mTWFFUOdNHpFQmHqcFMkOPszkkQP7m96fHV0hoVEj6xTFFIW9FrYMo00UCSSKiHPhJ8MkTPcnDOPD5yCC6dNxVe9R2Vpv23WAYBQ0MwXuemfHamYNTyxMa47SDnjc5nmaselZk9XHbaZXuaQYLLud36hfGaS1pkaGoBxtMIiVHbarArTNITCRimFHvcaIKNpHfYhJJladUNkixLNLEe(IFaQYL36hfG4ITCJXbqc4(Vi5iVaakqMZfai9Ag2BQacAQ8e2hJJnvYzALesnDOPD5yzjrctpg5nvAbnvQamYNTyxMaC7HTFVyPVam4EQGCvEw6r4l(bOkxwsnCRFuacGeXYSsFCyaWCmfGT(rby8Ey73hGrG1(auYuwK41WA68ckmaislQ9uSLBfH5lSsaqK88jSq(yCCbyWmLfnUH105J8cqvU8w)OaexSH0yCaKaU)lsoYlaGcK5CbOlhlljsy6XiVPslOPdiaJ8zl2LjaEKWCOairSmR0hhgamhtbOkxwsnCRFuacWw)OaaqcZHcaI0IApfB5wry(cReaejpFclKpghxagCpvqUkpl9i8f)auLlV1pkaXfB5mghajG7)IKJ8caOazoxa2z6Om9yfKz4AtrrnDNPq61mS3ubmDaMo00RH10L2t962NCkNPsBAUsz6qthLPxVi8L89NGhNF7teU)ls2uemff1uhc6z(JWN4BUoMZIrqtL2uz(LGmNKZBUoMZIrqtrW0HMEnSMU0XEK4XfLzKPsMMcPxZWEtL20Jvqw8ypYujNP500HMw4Vpx0HZWNpvMqiHptf0uPmDOP7mLWeSot6yps84IVEGMkGPzBiR)lk5W5lgU2uuut)tx30NGEcICA6ykkQP)PRBIHlne3hJJtthtrrn9pDDt0AIjVy9Kj34cLMoMIIAAHZxYCKGthRMGEr3jmtcsVMH9MkGPi1uuut90j(54PpDmckCaI50PyQ0MwXuuut3z6F66MklQHL2FmCDA6y6qtjmbRZKktiKWNPsBAoKYuemff10Rxe(sE(CjYDfV9KOlhs(lr4(ViztrrnDuMkZVeK5KowbzgU2uuut3zQm)sWgzkbPxZWEtfWuHjPmDOPD5yzjrctpg5nvatZHPiykcbyKpBXUmbaYCcWG7PcYv5zPhHV4hGQCzj1WT(rbiaselZk9XHbaZXua26hfaezobyeyTpaLmLfjEnSMoVGcdaI0IApfB5wry(cReaejpFclKpghxagmtzrJBynD(iVauLlV1pkaXfBsfJdGeW9FrYrEbauGmNla7mDNP)PRBY3z7AseYBycsVMH9MkGGMkSsskthA61lcFPrBxxtYIiHpXY(eH7)IKnfbtrrnDNP)PRBY3z7AseYBycsVMH9MkGGMMFkxtrWuemDOPf(7ZfD4m85tLjes4ZubnvkthA6otjmbRZKo2JepU4RhOPcyA2gY6)IsoC(IHRnff10)01n9jONGiNMoMIIA6F66My4sdX9X4400Xuuut)tx3eTMyYlwpzYnUqPPJPOOMw48Lmhj40XQjOx0DcZKG0RzyVPcyksnff1upDIFoE6thJGchGyoDkMkTPvmff10DM(NUUPYIAyP9hdxNMoMo0uctW6mPYecj8zQ0MMdPmfbtrrn96fHVKNpxICxXBpj6YHK)seU)ls2uuuthLPY8lbzoPJvqMHRnff10DMkZVeSrMsq61mS3ubmvyskthAAxowwsKW0JrEtfW0CykcMIqag5ZwSlta8D2UMeH8ggajILzL(4WaG5ykav5YsQHB9Jcqa26hfaqNTRjtrK3qt3jeHaGiTO2tXwUveMVWkbarYZNWc5JXXfGb3tfKRYZspcFXpav5YB9JcqCXwoIXbqc4(Vi5iVaakqMZfGc)95IoCg(8PYecj8zQGMkLPdnDNPD5yzjrctpg5nvAbnnhMIIA6ot7YXYsIeMEmYBQ0cAksnDOPJY0Rxe(s)fNlF9IJ9jc3)fjBkcMIGPdnTWFFUOdNHpFQmHqcFMkOPsz6qt3zkHjyDM0XEK4XfF9anvatZ2qw)xuYHZxmCTPOOM(NUUPpb9ee500Xuuut)tx3edxAiUpghNMoMIIA6F66MO1etEX6jtUXfknDmff10cNVK5ibNownb9IUtyMeKEnd7nvatrQPOOM6Pt8ZXtF6yeu4aeZPtXuPnTIPOOMUZ0Rxe(sp(JWNi3vSSAi7YKiC)xKSPdn9pDDtLf1Ws7pgUonDmfbtriaJ8zl2LjaEKWCOairSmR0hhgamhtbOkxwsnCRFuacWw)OaaqcZHmDNqecaI0IApfB5wry(cReaejpFclKpghxagCpvqUkpl9i8f)auLlV1pkaXfB5hJdGeW9FrYrEbauGmNlaf(7ZfD4m85tLjes4ZubnvkthA6F66MCzemJiKKfFn7rqFA6y6qt3zkHjyDM0XEK4XfF9anvatZ2qw)xuYHZxmCTPOOM(NUUPpb9ee500Xuuut)tx3edxAiUpghNMoMIIA6F66MO1etEX6jtUXfknDmff10cNVK5ibNownb9IUtyMeKEnd7nvatrQPieGr(Sf7YeGxZEbqIyzwPpomayoMcqvUSKA4w)OaeGT(rbOAZEbarArTNITCRimFHvcaIKNpHfYhJJladUNkixLNLEe(IFaQYL36hfG4ITbeJdGeW9FrYrEbauGmNlaf(7ZfD4m85tLjes4ZubnvkthA6otjmbRZKo2JepU4RhOPcyA2gY6)IsoC(IHRnff10)01n9jONGiNMoMIIA6F66My4sdX9X4400Xuuut)tx3eTMyYlwpzYnUqPPJPOOMw48Lmhj40XQjOx0DcZKG0RzyVPcyksnfHamYNTyxMa4sqEHXNEXp7Oam4EQGCvEw6r4l(bOkxwsnCRFuacGeXYSsFCyaWCmfGT(rbqYsqEHXNEtZJDuagbw7dWRhOiHjyDgbfo6lzkls8AynDEbfgaePf1Ek2YTIW8fwjaisE(ewiFmoUamyMYIg3WA68rEbOkxERFuaIlUaS1pkaa2BqtLSeSxJgtDzyMFpbJlca]] )

    storeDefault( [[SimC Feral: cooldowns]], 'actionLists', 20171105.231639, [[dm0NjaqiQewevP0MGiFsLunkQuofvj7IOggiDmqSmvQEgvvAAuLkxdvL2gvv13GOgNkPCoQsvRJQkAEuvL7PsY(Os6GOQAHKKEijvtKQkCrskBevf9rQeXjjjwjvIYlPsuDtiStImuQsrlLk6PuMkv4QuLcBLQWEv(ljAWOCyvTyi9yHMSOUmYMvHpJQmAQkNMuRMkr61QeZwKBdQDl1VLmCv0Yj8Cbth46OY2Pk67uP68KW6rvH5Rsz)q9GmhZuRF0eLh6m7KI6pP5JhOREsqG63z(bD8CjWuDMtkrFGM0DOqqgcuO(xgcYEhY39(zwuOpbZMXFeORomhtcYCmtT(rtuEQoZIc9jyMlWmuUJd54duEucyzUZz8JQtAGIz5p4BMkDwhFqjM1vtZquzpEH0dtZMj9W0m)4d(M5Ks0hOjDhkeKHaDMtkuCIifMJbMPUpkEbr5jbtnyOZquzPhMMnWKUphZuRF0eLNQZSOqFcMbkE8sKCSQuUCVdygsyMByg1KGNc5iNqqnaZC9kmZVqXmKWm3WSyvPC5Eld08irq5bNqHSGGFDhWmxXm(Iz3UHzOChhYanpseuEWjuiZDIzEHzEnJFuDsdumdLebsCzMkDwhFqjM1vtZquzpEH0dtZMj9W0mvjrGexM5Ks0hOjDhkeKHaDMtkuCIifMJbMPUpkEbr5jbtnyOZquzPhMMnWK87CmtT(rtuEQoZIc9jyg1KGNc5mDOJAaM56vyM)HoJFuDsdumdO5rIGYdoHIzQ0zD8bLywxnndrL94fspmnBM0dtZCO5rIRhWm(KtOyMtkrFGM0DOqqgc0zoPqXjIuyogyM6(O4feLNem1GHodrLLEyA2atY7MJzQ1pAIYt1zwuOpbZIfmAP8S0niih5ecQby2vygumdjmJAsWtHCKtiOgGzUEfMXxOZ4hvN0afZOextbL8405VJ0mv6So(GsmRRMMHOYE8cPhMMnt6HPzQL4A66bmZLWPZFhPzoPe9bAs3HcbziqN5KcfNisH5yGzQ7JIxquEsWudg6mevw6HPzdmj(ohZuRF0eLNQZSOqFcMrnj4PqoYjeudWmxVcZ8lumdjmZnmlwvkxU3YanpseuEWjuili4x3bmZvmdcFXSB3WmuUJdzGMhjckp4ekK5oXmVMXpQoPbkMP74l6hORw5fDZtzDOe4Ju6s5AEjAMkDwhFqjM1vtZquzpEH0dtZMj9W0mv64l6hOR2pXmxUU5Hz1bMb8ryMlJR5LOzoPe9bAs3HcbziqN5KcfNisH5yGzQ7JIxquEsWudg6mevw6HPzdmj)phZuRF0eLNQZSOqFcMbkE8sK8zb0vhWmKWm3WmWl4razGgMuckLznHz(dZ8pFXSB3Wm3WmGgMuckLznHz(dZGCnOygsyMBygk3XHmkjcK4Im3jMD7gMHYDCiR74l6hORwM7eZ8cZ8cZ8Ag)O6KgOy2zb0vptLoRJpOeZ6QPziQShVq6HPzZKEyAM3Sa6QNXVGxyw)W0vE7POsvZJYkpl3jH3oZjLOpqt6ouiidb6mNuO4erkmhdmtDFu8cIYtcMAWqNHOYspmn7uuPQ5rzLNL7KyGjH8CmtT(rtuEQoZIc9jywSGrlLNLUbb5iNqqnaZC9km7oMHeM5gM5cmd8jQbYOPQYGpvDqM6hnrzm72nmdL74qgnvvg8PQdYCNyMxZ4hvN0afZ(GVh(BkO8qqnFOyMkDwhFqjM1vtZquzpEH0dtZMj9W0m(d(E4VPRhWm(uqnFOyMtkrFGM0DOqqgc0zoPqXjIuyogyM6(O4feLNem1GHodrLLEyA2at6AZXm16hnr5P6mlk0NGzXcgTuEw6geKJCcb1amZFygFXmKWmQjbpfYroHGAaM56vy2hb6QLf)fsowbaMHeMLlGS4VqYNWCjG(mPjbM5pm7UmemdjmdL74qgO5rIGYdoHczUtmdjmZnmdL74qgnvvg8PQdYCNy2TByMlWmWNOgiJMQkd(u1bzQF0eLXmVWmKWm3WmxGzGprnqw3Xx0pqxTm1pAIYy2TBywSQuUCVL1D8f9d0vlli4x3bmZvmdY1WmVWmKWmxGzOChhY6o(I(b6QL5oNXpQoPbkMf895YDykLNPsN1XhuIzD10mev2Jxi9W0SzspmnZ895YDykLN5Ks0hOjDhkeKHaDMtkuCIifMJbMPUpkEbr5jbtnyOZquzPhMMnWK8(5yMA9JMO8uDg)O6KgOygxGuQbeCyMkDwhFqjM1vtZquzpEH0dtZMj9W0mVrGWmvaeCyMtkrFGM0DOqqgc0zoPqXjIuyogyM6(O4feLNem1GHodrLLEyA2admt6HPzMgwDmJpjXN8tmlwvkxU3Hb2a]] )

    storeDefault( [[SimC Feral: single target]], 'actionLists', 20171105.231639, [[d0JbgaGEGcTjssTlf12akzFuQkZKsOztL5tj6MQuxM4BQqpwHDcXEL2nO9tXOaQyyqY4ak4WIopLKbtQHtIoij1PaQ0XuKZrsslKKyPazXq1Yr5HqXtrwMkY6ibtKsv1uvjtgW0v1fHuDAu9mssCDb2iKYwPuAZqPTtj1FfuFNe6ZQG5bu0Hak1TfA0cYRvrDskftJsW1OuL7bu1IOu55u1Vv6o1RsOdtCNau8sKszWthhmMpFHfzcLQuY(fSzG7RkLajoj9sroHA64ekuG180rlC8KQwIgmUYVuj1JNVqFVkYuVkHomXDcqvPenyCLFjW2OXdWIDEKFySllohOSKACUJ)wvAKFySllwYgiaFK)YkbxOu6EbSnzizukvcjJsjm5B0OTSyjqItsVuKtOMooHQeiXVbSH47v)sycjJZ3R1suGFXlDVaizuk1ViN6vj0HjUtaQkLObJR8lHhGf7Ss2QOBoqPrBPLgnEawSZ(qjWQyuCaZbklPgN74VvLy5zPKnqa(i)LvcUqP09cyBYqYOuQesgLsGYZsjqItsVuKtOMooHQeiXVbSH47v)sycjJZ3R1suGFXlDVaizuk1ViQsVkHomXDcqvPKACUJ)wvAKox4C88fg2X9FjBGa8r(lReCHsP7fW2KHKrPujKmkLWKoNrRE88fA0wK7)sQzh8LGzuaVDepIXOrtyPtbJESRdyve6TReiXjPxkYjuthNqvcK43a2q89QFjmHKX571AjkWV4LUxaKmkLiEeJrJMWsNcg9yxhWQi03ViwOxLqhM4obOQuIgmUYV0yJ4ByLlh((5raJjW3ObVrBpJw1g9Nob(Z4UDb(0Tq)SatCNay0Q2OXdWIDg3TlWNUf6NbwfHgTQnAWXObBJgpal2zoCKmy(8fohO0OT0sJgy)zgx5mtIjh6nAW0ObdgTLwA0a7pZYZYmtIjh6nAW0OTNrdULuJZD83Qsm5aBv8dvYgiaFK)YkbxOu6EbSnzizukvcjJsjqYb2Q4hQeiXjPxkYjuthNqvcK43a2q89QFjmHKX571AjkWV4LUxaKmkL6xe71RsOdtCNauvkrdgx5xASr8nSYLdF)8iGXe4B02NrBHsQX5o(BvjwamCoE(cd74(VKnqa(i)LvcUqP09cyBYqYOuQesgLsGcGgT6XZxOrBrU)lPMDWxcMrb82r8igJgnHLofmA6YOXYHCFiH5TReiXjPxkYjuthNqvcK43a2q89QFjmHKX571AjkWV4LUxaKmkLiEeJrJMWsNcgnDz0y5qUpKW89lcy1RsOdtCNauvkPgN74VvLybWW545lmSJ7)s2ab4J8xwj4cLs3lGTjdjJsPsizukbkaA0QhpFHgTf5(3ObNjWTKA2bFjygfWBhXJymA0ew6uWOPlJ(Gafw(lZBxjqItsVuKtOMooHQeiXVbSH47v)sycjJZ3R1suGFXlDVaizukr8igJgnHLofmA6YOpiqHL)Y897xcjJsjIhXy0OjS0PGr75WdoXO)KDq((T]] )

    storeDefault( [[SimC Feral: ST finishers]], 'actionLists', 20171105.231639, [[d0JMfaGEPkPnHa7IeBJKq7JK0LHMTkMpi6MGQhJuFdK6WuTtKSxLDtQ9tPrHigMu53OCEe0Pv1GfmCH6GGKtHO6ys05KQelerzPOIfJQwoWdjP6PelJISoPk0eLQOMkQ0KvPPl6Iui)fHEMuvUUe2ijbBvi1MPO2UqmnPk13LQiFguMNqYRrKUTugnfmEPk4KuOoei01ij6EKuwfi45sACsv1RCCNyK25p4D8tKyK(9Z3RE(m9Ok76BspJM9ItoYMWbpOxXrzQRe6YUovuPe6EdTPEzIqd(4CYeOOZNPRJ7Okh3jgPD(dEhzteAWhNt4lmBwP6rCyiraZbkxwpPNaf)F(KWjvpIddjcyoyIX67t7jdmrZ04e4SB0oGYB4KjuEdNiEehgAdCyoych8GEfhLPUsOl7MWbRScanwh3Ltu3astkCweSH6C8tGZUuEdNSCuMg3jgPD(dEhzteAWhNtGOnKpnPVgMnajK2aj2aaB(RR2quQzd3cGNptBdqWg6u6Zgi3giWgiXgshadtfdOFsdkX0PnOQnysL2ab2aeTH0pOovQopcsglnOGAN)GxBGCBasiTbsSba28xxTHOuZgUfapFM2gGGn0P0VnqGneJG6xtuNeBfN8JppcSbvTHllvaFSsCR4KF85rGnqUnqGnKoagMk53qIjJ49rBqvBO)jqX)NpjCc4JNyS((0EYat0mnobo7gTdO8gozcL3WjC(4jqbGvNKoagMeFZQbX8Pj91WGessayZFDnk1UfapFMgcDk9robKKoagMkgq)KguIPtvnPscGy6huNkvNhbjJLguqTZFWl5qcjjaS5VUgLA3cGNptdHoL(jigb1VMOoj2ko5hFEeO6LLkGpwjUvCYp(8iGCcshadtL8BiXKr8(OQ9pHdEqVIJYuxj0LDt4GvwbGgRJ7YjQBaPjfolc2qDo(jWzxkVHtwoQ(g3jgPD(dEhzteAWhNt4lmBwP6rCyiraZbkaS5VUAdrzdLMMaf)F(KWjvpIddjcyoyIX67t7jdmrZ04e4SB0oGYB4KjuEdNiEehgAdCyoWgiPK8jCWd6vCuM6kHUSBchSYka0yDCxorDdinPWzrWgQZXpbo7s5nCYYr17XDIrAN)G3r2eHg8X5e(cZMvm)iGqIa8sS5FdbvLI4jqX)NpjCsZ)2eJ13N2tgyIMPXjWz3ODaL3WjtO8gobU)TjCWd6vCuM6kHUSBchSYka0yDCxorDdinPWzrWgQZXpbo7s5nCYYrPYXDIrAN)G3r2eO4)ZNeoXmcy0pROsK)tCIX67t7jdmrZ04e4SB0oGYB4KjuEdNOciGr)SIQnq2N4eOaWQtAEpqe1iagHQvoHdEqVIJYuxj0LDt4GvwbGgRJ7YjQBaPjfolc2qDo(jWzxkVHtwUCcL3WjY3u3gube4NE0geU2G5x)vdiOUCda]] )

    storeDefault( [[SimC Feral: ST generators]], 'actionLists', 20171105.231639, [[daeKnaqicvTjsvJsO6usLwfHkVIGa3IGq2frnmOQJjvTmPINrqzAeuDnfcTncI6BGQgNcroNcbwhbHAEkKUhbP9rvXbjfwiPOhsv0eviQUivL2ibbDsHIBcv2jrwkPYtPmvsPTkuAVQ(lbgSshw0IHYJv0KLYLr2mH8zQQgTconjVMQ0SfCBq2nQ(nKHdkhxHOSCuEovMUKRlKTdQ8DcLXRqqNxHA9eez(uf2pWV)AV5lpXcu7y3my0uLbLqklfIFPE8c72iNeLrH6AEthfO0rxQd(E47XJxil3dVWHVZi4Mnzky1TBAmlfI7U2l1FT38LNybQDnVztMcwDRYaXlzSac1QmG4ozINybQbw9GflsKizymQLfInwGtmLOItoNCemWQhSyrIejJfqOwLbe3j3qIXbREWorqyibWqkE5KNrmgXlW6JqbBhWQhStek0qIXLt3qcLCYjqeJ4cPXYmckvChyhfS(NTBAGPcQA8ng5NHeRgUfdVPMzHy34ioDdhQfBYKsi62nPeIUPJ8ZqIvd30rbkD0L6GVh(E830roueBsUR91nphOPxCi4iiIxh7goutkHOBVUuNR9MV8elqTR5nBYuWQBvgiEjJfqOwLbe3jt8elqnWQhSyrIejdJrTSqSXcCIPevCY5KJGbw9GflsKizSac1QmG4o5gsmoy1d2jccdjagsXlN8mIXiEbwHcwHdw9GTHkzw6LKzeuQ4oWokyf(nnWubvn(gJ8ZqIvd3IH3uZSqSBCeNUHd1InzsjeD7Mucr30r(ziXQbWgVV7nDuGshDPo47HVh)nDKdfXMK7AFDZZbA6fhcocI41XUHd1Ksi62RljSR9MV8elqTR5nBYuWQB0ilsbdg1KtviIHeadfXNeZbw9GTYaXlzSac1QmG4ozINybQbw9GnoyXIejsggJAzHyJf4etjQ4KZj7QC6fS(a2oG1dpaBCWIfjsKmmg1YcXglWjMsuXjNt2v50ly9bS9GvpyBOsMLEjzgbLkUdSJcwHb2UGTly1dwSirIKXciuRYaI7KBiX430atfu14BmYpdjwnClgEtnZcXUXrC6goul2KjLq0TBsjeDth5NHeRgaB8oDVPJcu6Ol1bFp894VPJCOi2KCx7RBEoqtV4qWrqeVo2nCOMucr3EDjHFT38LNybQDnVztMcwDlNLcosaXjif5aRpGT)MgyQGQgFdJfvzqGlKUHBXWBQzwi2noIt3WHAXMmPeIUDtkHOBAYIQmawlKUHB6OaLo6sDW3dFp(B6ihkInj31(6MNd00loeCeeXRJDdhQjLq0TxxAeV2B(YtSa1UM3SjtbRUfhSIhSLA6vX9dwp8aSmckvChyhfSTiwwkehSIdS4Lfgy7cw9GnoyZzPGJeqCcsroW6dy7a2U30atfu14B1alDdcMzDlgEtnZcXUXrC6goul2KjLq0TBsjeDt7alDd30rbkD0L6GVh(E830roueBsUR91nphOPxCi4iiIxh7goutkHOBVUKq(AV5lpXcu7AEZMmfS6M4bBPMEvC)G1dpaBCWkEWwzG4LmwaHAvgqCNmXtSa1aREWYiOuXDGDuW2IyzPqCWkoWIxwyGTly1d2kz(PsUuqKGcjOPiW6dyf(nnWubvn(gl9s3IH3uZSqSBCeNUHd1InzsjeD7Mucr30LEPBAW87UvjZpvcuIeQ4l10RI73dpIl(kdeVKXciuRYaI7KjEIfOMEgbLkUB0wellfIlo8YcRR(kz(PsUuqKGcjOPiFe(nDuGshDPo47HVh)nDKdfXMK7AFDZZbA6fhcocI41XUHd1Ksi62Rlb)1EZxEIfO218Mnzky1TkdeVKXciuRYaI7KjEIfOgy1dwSirIKXciuRYaI7KJGbw9GnoyJdwgbLkUdSJkuWcpy7cw9GfgXCkxr8sauuOuWckIbwFaBdvYS0ljddkkukybfXaR4alE5rAebBxWQhSvY8tLCPGibfsqtrG1hWk8BAGPcQA8nw6LUfdVPMzHy34ioDdhQfBYKsi62nPeIUPl9sGnEF3BAW87UvjZpvcuIeALbIxYybeQvzaXDYepXcutpwKirYybeQvzaXDYrW0hpoJGsf3nQqHVREyeZPCfXlbqrHsblOiMpnujZsVKmmOOqPGfuetC4LhPrSR(kz(PsUuqKGcjOPiFe(nDuGshDPo47HVh)nDKdfXMK7AFDZZbA6fhcocI41XUHd1Ksi62Rlnsx7nF5jwGAxZB2KPGv3IdwSirIKlLFI5eikInwocgy1d24Gnoy7bRqayHYrOG5qY8toWkeb25qY8tobIy5SuiEgaBxWkoWYO5qY8tckfeb2UGT7nnWubvn(gglQYGaxiDd3IH3uZSqSBCeNUHd1InzsjeD7Mucr30KfvzaSwiDdGnEF3B6OaLo6sDW3dFp(B6ihkInj31(6MNd00loeCeeXRJDdhQjLq0TxxAeCT38LNybQDnVztMcwDloyfpyl10RI7hSE4byzeuQ4oWokyBrSSuioyfhyXllmW2fS6bBCWcxYujwGKJCKGAGLUbWkuW2bSE4byZzPGJeqCcsroW6dy7bB3BAGPcQA8TAGLUbbZSUfdVPMzHy34ioDdhQfBYKsi62nPeIUPDGLUbWgVV7nDuGshDPo47HVh)nDKdfXMK7AFDZZbA6fhcocI41XUHd1Ksi62Rl1J)AV5lpXcu7AEZMmfS6wCWkEWwQPxf3py9WdWYiOuXDGDuW2IyzPqCWkoWIxwyGTly1dw4sMkXcKCKJeudS0nawHc2EWQhSyrIejpduYMPRuC)YrWUPbMkOQX3Qbw6gemZ6wm8MAMfIDJJ40nCOwSjtkHOB3Ksi6M2bw6gaB8oDVPJcu6Ol1bFp894VPJCOi2KCx7RBEoqtV4qWrqeVo2nCOMucr3EDP((R9MV8elqTR5nBYuWQB5SuWrciobPihy9bS930atfu14BoXuWOBXWBQzwi2noIt3WHAXMmPeIUDtkHOBMyky0nDuGshDPo47HVh)nDKdfXMK7AFDZZbA6fhcocI41XUHd1Ksi62Rl135AV5lpXcu7AEtdmvqvJV5gyu7wm8MAMfIDJJ40nCOwSjtkHOB3Ksi6MnWO2nDuGshDPo47HVh)nDKdfXMK7AFDZZbA6fhcocI41XUHd1Ksi62Rx3Ksi6MPG8eScHeldcXG10cw)eNyzHyUx)a]] )

    storeDefault( [[IV Guardian: Single]], 'actionLists', 20171105.231639, [[dCZreaGErvTlrYRHsL9jO0SPQBks52cStLSxYUHSFOOrjiPHHs)MIHkiQbdLmCr5GuHtjsvhtPEoLwOiAPuPfJWYr6Xc9uPLHOwNGqhwXurvtgQMUkxKk6QcsCzW1rLZlcBvqHnJiBxqvFekvDAv9zrLVlsLPjQYFHsz0qHVHcNef9mbfDnbP6EccMNGiBtqLXjiL1w8QordHhWfH6AcavMHbMyH9Cdf)huiIjw9r58GQl4HXcArMDZyVzZl1wTr6NDQQoI3BqwXR1w8QordHhWvs1gPF2PQUMaqnuSaMyX8GaRQdI3)xcvolGT)GaRkte(hNZqvrgeO6cEySGwKz3m2SQUG1WrJGv860PfzXR6eneEaxjvBK(zNQ6AcavEmOJfdvheV)VeQhg0XIHkte(hNZqvrgeO6cEySGwKz3m2SQUG1WrJGv860PvykEvNOHWd4kPAJ0p7uvxtaOM2GY5bvheV)VeQbdkNhuzIW)4CgQkYGavxWdJf0Im7MXMv1fSgoAeSIxNoTYt8QordHhWvs1gPF2PsWrIuQCJFI3hXwoUHI)dkfxM6Aca10mgePNcQoiE)FjudmgePNcQmr4FCodvfzqGQl4HXcArMDZyZQ6cwdhncwXRtNwHU4vDIgcpGRKQns)Stfhi4irk1HbDSyGncyOPS3eXomXkSyI1wDnbGAiZ5dpq)8bvxWdJf0Im7MXMvLjc)JZzOQidcuDbRHJgbR41P6G49)LqnJZhEG(5d60kCIx1jAi8aUsQ2i9ZovCGGJePubgdI0tHuuiyEKnKcHCrC11eaQPzmispfWeRqDNEvxWdJf0Im7MXMvLjc)JZzOQidcuDbRHJgbR41P6G49)LqnWyqKEkOtlgIx1jAi8aUsQ2i9Zov6Kdsf5OuaDHnCSQRjautB48QUGhglOfz2nJnRkte(hNZqvrgeO6cwdhncwXRt1bX7)lHAWW51PvOjEvNOHWd4kPAJ0p7uvxtaO209zGQl4HXcArMDZyZQYeH)X5muvKbbQUG1WrJGv86uDq8()sOAt3Nb60P2mi(J)ZFU3G0AZMNoja]] )

    storeDefault( [[IV Guardian: 2-3]], 'actionLists', 20171105.231639, [[dGdqeaGEvK2Lq1RPIO9ji1SPQBkeUnvANIAVKDdz)cQgfvu1WqPFtXLbdLksgSq0WvHdIkDkbbhtLESiluiTubwmuTCKoSINkTmO06OIIZluMkQAYimDLUiv4Qur4zcsUokoTQ2QGqBgr2UGsFKkQmpve9zOW3vr4BiQNtPrdf9xvuojQ4wurPRjiQ7jiY0ur12eumoQi16kEvhOb3decxnpUGkNqm8iDoMHs8dYzcpsSoBOudapmwqzSSxY3l75XVQnr)JvvLBAFdYkELVIx1bAW9aHIQMhxq1jSq4rYzbxRAt0)yvv5I)(FJPYyHZ(fCTQbG1WqtGv8AvdapmwqzSSxYxwvoiIpnRHQImiqRYyfVQd0G7bcfvnpUGkpM0XIPAt0)yvv5I)(FJPUyshlMQbG1WqtGv8AvdapmwqzSSxYxwvoiIpnRHQImiqRYHs8QoqdUhiuu184cQrmim8GAt0)yvv5I)(FJP6oim8GAaynm0eyfVw1aWdJfugl7L8LvLdI4tZAOQidc0Q85Ix1bAW9aHIQMhxqncJbr6PGAt0)yvXzirkogJFs7NoddMHs8dkoZHkx83)BmvxJbr6PGAaynm0eyfVw1aWdJfugl7L8LvLdI4tZAOQidc0QCilEvhOb3dekQAECbvNIXhwG(NcQnr)JvLaWzirk(IjDSyEgom042DsozOVQCXF)VXupy8HfO)PGkheXNM1qvrgeOgawddnbwXRvna8WybLXYEjFz1QCyeVQd0G7bcfvnpUGAegdI0tHWJ05VHGAt0)yvjaCgsKI7AmispfItb35r2tgsyKiu5I)(FJP6Amispfu5Gi(0SgQkYGa1aWAyOjWkETQbGhglOmw2l5lRwLjlEvhOb3dekQAECb1iggVAt0)yvPdgq8edLcOn0HHvLl(7)nMQ7W4v5Gi(0SgQkYGa1aWAyOjWkETQbGhglOmw2l5lRwLDAXR6an4EGqrvZJlO2t8hGAt0)yvv5I)(FJPApXFaQCqeFAwdvfzqGAaynm0eyfVw1aWdJfugl7L8LvRw1EaPF8)PZ(gKYx2Z1kba]] )

    storeDefault( [[IV Guardian: 4+]], 'actionLists', 20171105.231639, [[dmZndaGEQI2LkYRPK0(ePQztLBcj1TvHDkQ9I2nu7NQWWiQFl0qHemyrkdxehKcDmvAHIKLsPwmelNupv5XcwhKOEojtLitMqtxQlsbVcsOldUofDyjBvfv2mvLTdj5JqI8nkXNHu(oLe)LsQtRQrtv1vfPYjjWYiORPIIZtv6zQO00GuTnvu18sjod4cXbIeHlxhaNGZ5rAOKzPf)cJYEKg6OiNn4Gsbmlu(A5ELr)0LBb9N0CCgd9hXkkX8LsCgWfIdezkUCDaCPtbEKMGgouClO)KMJZiY7(2lNPcS(B4qXzdQOPoakkXMZgCqPaMfkFTCL5eGf)q1rnhoIb2mlKsCgWfIdezkUCDaCs(1LYp3c6pP54mI8UV9Y1(1LYpNnOIM6aOOeBoBWbLcywO81YvMtaw8dvh1C4igyZ8zPeNbCH4arMIlxhahQlmAoGBb9N0CCgrE33E5okmAoGZgurtDauuInNn4Gsbmlu(A5kZjal(HQJAoCedSzgDkXzaxioqKP4Y1bWH6ye771a3c6pP5qm957eALRc9hSgnZsl(f(KzcNrK39TxUJye771aNnOIM6aOOeBoBWbLcywO81YvMtaw8dvh1C4igyZ8zOeNbCH4arMIlxhahky6qfOFpbUf0FsZjciM(8DQ9RlLFRrGsFs1vWQP)Yze5DF7LlX0Hkq)EcCcWIFO6OMdhXaNnOIM6aOOeBoBWbLcywO81YvMnZNNsCgWfIdezkUCDaCZkFcWTG(tAooJiV7BVCkR8jaNaS4hQoQ5WrmWzdQOPoakkXMZgCqPaMfkFTCLzZMBjq4l37z1FeZ8vgD2Ka]] )

    storeDefault( [[IV Guardian: Default]], 'actionLists', 20171105.231639, [[dmJgdaGEqrTjII2frP9ruy2KCtrvUnQStvzVu7gy)s1WKu)wKblLHtuDqLIJPQwOsyPkvlMilNWZL4PildLSouWefvLPIQMmitxLlQK6vGsDzORljBuuvTvqLnRKSDuuFef5WcttuzEGI8nLOZdQ6ZkLEmPojk1TaLCAf3duWZqH(oOq)vu2FZBAniKuiKLm9co0eB46nMQcb0eag6T8HRIk1zAhvyuq)yv)x()15K9BI0Ir(zY0g9njqX8(9nVP1GqsHqEHjslg5NjPQvRKvcdr2QKGtwOemcm9co00cme9w(tcotBKg1CWBscdr2QKGZeBa0OJljmbsa00oQWOG(XQ(V8xBAhlPkHglM3Np)yzEtRbHKcH8ctKwmYptH(gMXmeGCdw6nyO3(MEbhAIgWwf2B8HylEMydGgDCjHjqcGM2rfgf0pw1)L)At7yjvj0yX8(mTrAuZbVjrfil03KazQPCMYlb9co0eB46nMQcb0eag6nAaBvOp)y08Mwdcjfc5fMiTyKFMc9nmJzia5gS0BYO3(9Mm7TqFdZygcqUbl9gm1B5m9co0elyXyVXhIT4vmXgan64sctGeanTJkmkOFSQ)l)1M2XsQsOXI59zAJ0OMdEt6qPYc9njqMAkNP8sqVGdnXgUEJPQqanbGHEJfSy0NF5mVP1GqsHqEHjslg5NPqFdZygcqUbl9Mm6ngn9co0uoy3B8HylEftSbqJoUKWeibqt7OcJc6hR6)YFTPDSKQeASyEFM2inQ5G3KouQSqFtcKPMYzkVe0l4qtSHR3yQkeqtayO3YbBF(mrYr9eQbMJBsa)(158zd]] )


    storeDefault( [[Feral Primary]], 'displays', 20171105.231639, [[dWdUgaGEPuVejv7svsABQskZuvIzlvpgPUjssVwkY3Kc10qsStkTxXUjSFQWpvfdtr9BihwYqrPbtfnCeoOconrhJQCovjXcPQwkQulMelNupuk5PGLPk1ZPyIsbnvv1KrftxPlQixfjLlRY1r0grITkfOnJQ2ou1hLIADqP0NHIVtLgjuQEMuiJgfJhk5KqLBjfW1GsX5jPBRqRvvs1XrLC8YpaDrSsKGcsSWQ2Vapu7)co7ua6IyLibfKybz7lwV3b0LaZ1I5OBk(bu6Y2TBUJCJsa1hEEZTTkIvIeMyNdG1dpV52wfXkrctSZb4I8ipo4Orcq2(ILkZbgLIHPyBuaUipYJtRIyLiHj(buF45n3(lnMBnXohWWGCbx5sZmmf)aggK7a5IIFaddYfCLlnZa5IIFGT0yUDqqZG0b8F()hQYnUMX(pGASnW7gnhGhj2aSFhoHsyC40wAnYnGHb5(lnMBnXpqtkdcAgKoW)HLBCnJ9FaPGJKUwKEqqZG0b4gxZy)hGUiwjsmiOzq6a(p))dvdaehTS6Y21krIy9MBuaddYf(XpaxKh51qP(OxjseGBCnJ9Fab5ioAKWelvcyiUENsVmmTqDKo)avSEbuI1laMy9cOJ1lBaddYTvrSsKWeLay9WZBUDGuxXohOi11xL4cOqYZhySWAGCrXohqPlB3U5oYDO3JsGQtWuadYLf)uSEbQobt1cnQull(Py9c0WJVi7B8duD3s1WINn(bWlnsfzxUQFvIlGsa6IyLiXqxIreO1K9pXDaosdrVu)Qexaob0LaZ9vjUaLISlx1afPUOQuCXpqtkuqIfKTVy9EhO6em1V0yULfpBSEb0xpqRj7FI7agIR3P0ldtucuDcM6xAm3YIFkwVaCrEKhhCcos6ArAt8dyRXlaLtxDhoz1YXsRgylnMBPGelSQ9lWd1(VGZofyukgixuSZbAsHcsSWQ2Vapu7)co7uaSE45n3sDFtSEbQobtn0DlvdlE2y9cGvSZbi0YXsRsbjwq2(I17Dac9rJgvQDG9LaGCSLdNuoD1Xwhoj0hnAuP2asAK41rOXy9WMaJfwdtXohqsJearrlfyIfBcSLgZTS4NIsacTCS0Q4Orcq2(ILkZbmmixw8SXpaxKh5n0LyeJNydqhaRhEEZT4eCK01I0MyNdO(WZBUfNGJKUwK2e7CGT0yULcsSby)oCcLW4WPT0AKBaSE45n3(lnMBnXohWWGCXj4iPRfPnXpGHb5oqQlCcEuucuD3s1WIFk(bmmixw8tXpGHb5omf)a0OrLAzXZgLafPUge0miDa)N))HQVmr5hOi1fqC9oUgg7CaUiL0n1GsdSQ9lqfyukGFSZb2sJ5wkiXcY2xSEVduK6cNGh9vjUakK88bOlIvIeuqIna73HtOeghoTLwJCduDcMQfAuPww8SX6fysuk9Jt8dyKJe9B4zk23buF45n3oqQRyNd0KcfKydW(D4ekHXHtBP1i3avNGPg6ULQHf)uSEb2sJ5ww8SrjanAuPww8trjGHb5s9tvrk4ifymXpa3x)kZf77zVg7np)AVQxJPsJF)kbglSGFSEbQobtbmixw8SX6fGlYJ84qbjwq2(I17Da1hEEZTu33eBd4fGlYJ84qDFt8dW54lY(oW(saqo2YHtkNU6yRdNCo(ISVbksDrnHCdq0l1tNnb]] )

    storeDefault( [[Guardian Primary]], 'displays', 20171105.231639, [[dOtOgaGEjPxIK0UGQIETuIzkjA2s1nrsCBqCyQ2jL2Ry3OA)kKFQidtr9BiRdQk1qrXGLsnCeDqP4zibDms64eOfkPwQKWIjXYP4Hkupv1JrPNtQjIe1ub1KrW0v6Ik4QirUmW1HYgjOTcvvTzcTDe6JiPwgbmnPK(UensKqNMOrJuJhQYjHk3cjW1GQkNxcFgKwluv4Bqvjh1aNZ6KReXfI473IoiFIsWvIZoKVUbkyziYeLCJZHcgtdyBj15cIbWanDjuoeaFZzZlMef1GDStUsexh7CoEtIIAWo2jxjIRJDoN0iH4McCSi(LvbX26CoejVziwkmxqmagGWyNCLiUo15ftIIAWc7gOGvh7CUMgv(s5Ys3mK6CnnQSbBrPohIJ3HJvnFDduW2WzPrM86jy4jQuboQPiCErSuGau4CoEXoNRPrLWUbky1PoVfLgolnYKdpXuboQPiCUKtqY6lY0WzPrM8kWrnfHZzDYvI4nCwAKjVEcgEIk5NeWk9USQVsepw15wZ10OYdN6CbXayaklna2vI45vGJAkcNZXGGJfX1X2AUMe07c7UMEmQJmbo3Jvnxjw1COXQMBIvnBUMgvo2jxjIRJsoEtIIAW2Gz8yNZDmJdxqcYvWefZH441GTOyNZv6YQvPUJkB69OK7DsA)0OsgIdXQM7DsAFmcIIVmehIvnNYarhRVrj37LEHMHitQZjk1sfzxUfWfKGCLCwNCLiEtxcLNpEWcpurobPMS7fWfKGCc5gNdfaxqcYDfzxUf5oMXPIKdsDElkcr89YQGyvfi37K0oSBGcwgImXQMBa98Xdw4HkY1KGExy310rj37K0oSBGcwgIdXQMligadqahNGK1xKrN6CRdbKtnMBiiD(O2mgje3uKVUbkyfI473IoiFIsWvIZoKdrYBWwuSZ5TOieX3VfDq(eLGReNDixqmagGaowe)YQGyBDo37K0EtV0l0mezIvnhVjrrnyPATow1CsJeIBkeI47LvbXQkqoPbWIGO4BdtLXoNlzrC8bcbjwv8lhIJxZqSZ5Ii(MZapQ9DUEuBRBmOY81nqbldXHOKlzr8t6Sso0yXV8kaDGRb5cmRIVuvNBfFQMR0LvRsDhvgLC8Mef1GfhNGK1xKrh7CEXKOOgS44eKS(Im6yNZx3afScr8nNbEu77C9O2w3yqL54njkQblSBGcwDSZ5AAujoobjRViJo15AAuzdMXXXfrrj37LEHMH4qQZ10OsgIdPoxtJkBgsDolcIIVmezIsUJz8golnYKxpbdprLkhecN7yg)KGEhhLJDoxqmjBl4Vu)TOdY9Cis(HJDoFDduWkeX3lRcIvvGChZ444Ii4csqUcMOyoRtUsexiIV5mWJAFNRh126gdQm37K0(yeefFziYeRA(a3v6acPoxlHq2bntdXkqEXKOOgSnygp258wueI4Bod8O2356rTTUXGkZ9ojT30l9cndXHyvZzDYvI4cr89YQGyvfiNfbrXxgIdrjxtJkPkOqrYji5q1PoxtJkziYK6CnnQ8LYLLUbBrPo37K0(PrLmezIvnxqmagGGqeFVSkiwvbYlMef1GLQ16yPa1CbXayacuTwN6CcarhRVnmvMJd)h1MAm3qq6C89O2ugi6y9n3XmoL4YnNS7fat2ea]] )


end

