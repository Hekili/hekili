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
                talent = 'elunes_guidance',
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
            },

            ashamanes_energy = {
                resource = 'energy',

                spec = 'feral',
                aura = 'ashamanes_energy',

                last = function ()
                    return state.buff.ashamanes_energy.applied + floor( state.query_time - state.buff.elunes_guidance.applied )
                end,

                interval = 1,
                value = function () return state.artifact.ashamanes_energy.rank * 5 end,
            },
        } )

        setPotion( "prolonged_power" )
        setRole( state.spec.guardian and "tank" or "attack" )

        addHook( 'specializationChanged', function ()
            setPotion( 'prolonged_power' )
            setRole( state.spec.guardian and "tank" or "attack" )
            if state.spec.guardian then addTalent( "incarnation", 102558 ) -- 21706: Guardian
            else addTalent( "incarnation", 102543 ) -- 21705: Feral
            end
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
        addTalent( "incarnation", 102543 ) -- 21705: Feral

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
        addTalent( "incarnation", 102558 ) -- 21706

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
        addAura( "ashamanes_energy", 210583, "duration", 3 )
        addAura( "ashamanes_frenzy", 210722, "duration", 6 )
        addAura( "astral_influence", 197524 )
        addAura( "barkskin", 22812 )
        addAura( "bear_form", 5487, 'duration', 3600 )
        addAura( "berserk", 106951 )
        addAura( "bloodtalons", 145152, "max_stack", 2, "duration", 30 )
        addAura( "bristling_fur", 155835 )
        addAura( "cat_form", 768, "duration", 3600 )
        addAura( "clearcasting", 135700, "duration", 15, "max_stack", 1 )
            modifyAura( "clearcasting", "max_stack", function( x )
                return talent.moment_of_clarity.enabled and 2 or x
            end )
        addAura( "dash", 1850 )
        addAura( "displacer_beast", 102280, "duration", 2 )
        addAura( "elunes_guidance", 202060, 'duration', 5 )
        addAura( "fiery_red_maimers", 212875)
        addAura( "feline_swiftness", 131768 )
        addAura( "feral_instinct", 16949 )
        addAura( "frenzied_regeneration", 22842 )
        addAura( "gore", 210706 )
        -- addAura( "incarnation_guardian_of_ursoc", 102558, "duration", 30 )
        
        addAura( "incarnation", 102543, "duration", 30 )
            class.auras[ 102558 ] = class.auras.incarnation
            modifyAura( "incarnation", "id", function( x )
                if spec.guardian then return 102558 end
                return x
            end )
        
        addAura( "infected_wounds", 48484 )
        addAura( "ironfur", 192081 )
        addAura( "lightning_reflexes", 231065 )
        addAura( "mass_entanglement", 102359, "duration", 30 )
        addAura( "moonkin_form", 197625 )
        addAura( "moonfire", 155625, "duration", 16 )
        
        addAura( "omen_of_clarity", 16864, "duration", 15, 'max_stack', 1 )
            modifyAura( "omen_of_clarity", "max_stack", function( x )
                if talent.moment_of_clarity.enabled then return 2 end
                return x
            end )
        
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
        
        addAura( "rake_stun", 163505, "duration", 4 )
        addAura( "regrowth", 8936, "duration", 12 )
        
        addAura( "rip", 1079, "duration", 24, "tick_time", 2 )
            modifyAura( "rip", "duration", function( x )
                return talent.jagged_wounds.enabled and x * 0.8333 or x
            end )
            modifyAura( "rip", "tick_time", function( x )
                return talent.jagged_wounds.enabled and x * 0.8333 or x
            end )
        
        addAura( "savage_roar", 52610, "duration", 36 )
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
        addAura( "typhoon", 61391, "duration", 6 )
        addAura( "wild_charge", 102401 )
        -- addAura( "wild_charge_movement", )
        addAura( "yseras_gift", 145108 )


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



        local tf_spells = { rake = true, rip = true, thrash = true, moonfire = true }
        local bt_spells = { rake = true, rip = true, thrash = true }
        local mc_spells = { thrash = true }
        local pr_spells = { rake = true }

        addMetaFunction( 'state', 'persistent_multiplier', function ()
            local mult = 1

            if not this_action then return mult end

            if tf_spells[ this_action ] and buff.tigers_fury.up then mult = mult * 1.15 end
            if bt_spells[ this_action ] and buff.bloodtalons.up then mult = mult * 1.20 end
            if mc_spells[ this_action ] and buff.clearcasting.up then mult = mult * 1.20 end
            if pr_spells[ this_action ] and ( buff.prowl.up or buff.shadowmeld.up or buff.incarnation.up ) then mult = mult * 2.00 end

            return mult
        end )


        local modifiers = {
            [1822]   = 155722,
            [1079]   = 1079,
            [106830] = 106830,
            [8921]   = 155625
        }

        local stealth_dropped = 0

        local function persistent_multiplier( spellID )

            local tigers_fury = UnitBuff( "player", class.auras.tigers_fury.name, nil, "PLAYER" )
            local bloodtalons = UnitBuff( "player", class.auras.bloodtalons.name, nil, "PLAYER" )
            local clearcasting = UnitBuff( "player", class.auras.clearcasting.name, nil, "PLAYER" )
            local prowling = GetTime() - stealth_dropped < 0.2 or
                             UnitBuff( "player", class.auras.incarnation.name, nil, "PLAYER" )

            if spellID == 155722 then
                return 1 * ( prowling and 2 or 1 ) * ( bloodtalons and 1.2 or 1 ) * ( tigers_fury and 1.15 or 1 )

            elseif spellID == 1079 then
                return 1 * ( bloodtalons and 1.2 or 1 ) * ( tigers_fury and 1.15 or 1 )

            elseif spellID == 106830 then
                return 1 * ( clearcasting and 1.2 or 1 ) * ( bloodtalons and 1.2 or 1 ) * ( tigers_fury and 1.15 or 1 )

            elseif spellID == 155625 then
                return 1 * ( tigers_fury and 1.15 or 1 )

            end

            return 1
        end

        local snapshots = {
            [155722] = true,
            [1079]   = true,
            [106830] = true,
            [155625] = true
        }

        RegisterEvent( "COMBAT_LOG_EVENT_UNFILTERED", function( event, _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName, _, amount, interrupt, a, b, c, d, offhand, multistrike, ... )
            if sourceGUID == state.GUID then
                if subtype == "SPELL_AURA_REMOVED" then
                    -- Track Prowl and Shadowmeld dropping, give a 0.2s window for the Rake snapshot.
                    if spellID == 58984 or spellID == 5215 then
                        stealth_dropped = GetTime()
                    end
                elseif subtype == "SPELL_AURA_APPLIED" then
                    if snapshots[ spellID ] and ( subtype == 'SPELL_AURA_APPLIED'  or subtype == 'SPELL_AURA_REFRESH' or subtype == 'SPELL_AURA_APPLIED_DOSE' ) then
                        ns.saveDebuffModifier( spellID, persistent_multiplier( spellID ) )
                        ns.trackDebuff( spellID, destGUID, GetTime(), true )
                    end
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

        addMetaFunction( 'state', 'unshift', function()
            removeBuff( "cat_form" )
            removeBuff( "bear_form" )
            removeBuff( "travel_form" )
            removeBuff( "moonkin_form" )
        end )

        state.shift = setfenv( function( form )
            removeBuff( "cat_form" )
            removeBuff( "bear_form" )
            removeBuff( "travel_form" )
            removeBuff( "moonkin_form" )
            applyBuff( form )
        end, state )

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
            if resource == 'combo_points' and amount > 0 and state.talent.soul_of_the_forest.enabled then
                state.gain( amount * 5, 'energy' )
            end
        end

        addHook( 'spend', comboSpender )
        addHook( 'spendResources', comboSpender )
        

        addSetting( 'regrowth_instant', true, {
            name = "Regrowth: Instant Only",
            type = "toggle",
            desc = "If |cFF00FF00true|r, Regrowth will only be usable in Cat Form when it can be cast without shifting out of form."
        } )

        addSetting( 'aoe_rip_threshold', 4, {
            name = "Rip: Priority on Fewer Than...",
            type = "range",
            desc = "Set a |cFFFF0000maximum|r number of targets you want to engage before you prioritize your AOE attacks over keeping Rip up on your current target.\r\n" ..
                "You can incorporate this into your custom APLs using the |cFFFFD100settings.aoe_rip_threshold|r syntax.",
            min = 0,
            max = 10,
            step = 1,
            width = 'full'
        } )


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
            form = 'cat_form',
            known = function() return equipped.fangs_of_ashamane end,
        } )

        addHandler( "ashamanes_frenzy", function ()
            removeStack( "bloodtalons" )
            applyDebuff( "target", "ashamanes_frenzy", 6 )
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
            shift( "bear_form" )
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
            notalent = 'incarnation'
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
            form = "bear_form",
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
            form = "cat_form",
        } )

        modifyAbility( "brutal_slash", "spend", function( x )
            if buff.clearcasting.up then return 0 end
            if buff.berserk.up then return x / 2 end
            return x
        end )

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
            shift( "cat_form" )
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
            shift( "cat_form" )
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
            applyBuff( "elunes_guidance", 5 )
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
            form = "cat_form",
            usable = function () return combo_points.current > 0 end,
        } )

        addHandler( "ferocious_bite", function ()
            spend( min( 5, combo_points.current ), "combo_points" )
            spend( min( 25, energy.current ), "energy" )
            removeStack( "bloodtalons" )
            if ( target.health_pct < 25 or talent.sabertooth.enabled ) and debuff.rip.up then debuff.rip.expires = query_time + debuff.rip.duration end
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
            form = "bear_form",
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
            form = "bear_form",
        } )

        addHandler( "growl", function ()
            applyDebuff( "target", "growl" )
        end )


        -- Incarnation: King of the Jungle
        --[[ An improved Cat Form that allows the use of Prowl while in combat, causes Shred and Rake to deal damage as if stealth were active, reduces the cost of all Cat Form abilities by 60%, and increases maximum Energy by 50.  Lasts 30 sec. You may shapeshift in and out of this improved Cat Form for its duration. ]]

        addAbility( "incarnation", {
            id = 102543,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            talent = "incarnation",
            toggle = 'cooldowns',
            cooldown = 180,            
            min_range = 0,
            max_range = 0,
        }, 102558 )

        modifyAbility( "incarnation", "id", function( x )
            if spec.guardian then return 102558 end
            return x
        end )

        addHandler( "incarnation", function ()
            if spec.feral then
                applyBuff( "incarnation", 30 )
                energy.max = energy.max + 50

                shift( "cat_form" )
            end

            if spec.guardian then
                applyBuff( "incarnation", 30 )
                shift( "bear_form" )
            end
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
            form = "bear_form",
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
            form = "bear_form",
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
            form = "cat_form",
            usable = function () return combo_points.current > 0 end,
        } )

        modifyAbility( "maim", "spend", function( x )
            if buff.incarnation_king_of_the_jungle.up then return x / 2 end
            return x
        end )

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
            form = 'bear_form',
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
            talent = "mass_entanglement",
        } )

        addHandler( "mass_entanglement", function ()
            applyDebuff( "target", "mass_entanglement", 30 )
            active_dot.mass_entanglement = max( active_dot.mass_entanglement, true_active_enemies )
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
            form = 'bear_form',
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
            talent = "mighty_bash",
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
            if talent.lunar_inspiration.enabled then gain( 1, "combo_points" ) end
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
            usable = function () return buff.moonkin_form.down and talent.balance_affinity.enabled end,
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
            form = 'bear_form',
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
            form = 'bear_form',
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
            aura = 'rake',
            form = 'cat_form',
            usable = function () return buff.cat_form.up end,
        } )

        modifyAbility( "rake", "spend", function( x )
            return buff.berserk.up and x * 0.5 or x 
        end )

        addHandler( "rake", function ()
            applyDebuff( "target", "rake" )
            debuff.rake.pmultiplier = persistent_multiplier

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
            -- proto.
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
            aura = 'rip',
            form = 'cat_form',
            usable = function () return combo_points.current > 0 end,
        } )

        addHandler( "rip", function ()
            spend( combo_points.current, "combo_points" )
            applyDebuff( "target", "rip", min( 1.3 * class.auras.rip.duration, debuff.rip.remains + class.auras.rip.duration ) )
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
            form = 'cat_form',
            usable = function () return combo_points.current > 0 end,
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
            form = 'cat_form'
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
            toggle = 'interrupts',
            form = 'cat_form'
        } )

        modifyAbility( "skull_bash", "form", function( x )
            if buff.bear_form.up then return "bear_form" end
            return x
        end )

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
            usable = function () return buff.survival_instincts.down end,
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
            talent = "restoration_affinity",
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
            form = "cat_form",
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

        modifyAbility( "swipe", "form", function( x )
            if buff.bear_form.up then return "bear_form" end
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
            form = 'cat_form',
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

        modifyAbility( "thrash", "cooldown", function( x )
            if buff.bear_form.up then return 6 * haste end
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

        modifyAbility( "thrash", "form", function( x )
            if buff.bear_form.up then return "bear_form" end
            return x
        end )

        addHandler( "thrash", function ()
            if buff.cat_form.up then
                applyDebuff( "target", "thrash_cat" )
                active_dot.thrash_cat = max( active_dot.thrash_cat, true_active_enemies )
                debuff.thrash_cat.pmultiplier = persistent_multiplier

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
            applyBuff( "tigers_fury", 8 + ( talent.predator.enabled and 4 or 0 ) )
            if artifact.ashamanes_energy.enabled then applyBuff( "ashamanes_energy", 3 ) end
            shift( "cat_form" )
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
            shift( "travel_form" )
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
            applyDebuff( "target", "typhoon", 6 )
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
            form = "cat_form",
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


    storeDefault( [[SimC Feral: default]], 'actionLists', 20171112.010004, [[dmeWlaqivu1IuGYMqe6tQOOrrqXPurLvPav3sff2fjAysPJrsltf5zIOAAQOuxtbyBeuY3uOgNceDofizDicUhbvTpcQCqfYcvqperzIQOKlsq2OcOtIOALIOuVubcZueLCtPyNk1sfvpfAQQWwrK2l1FLGbRshwyXe6XkAYs6YGnls9zry0s0PjA1kqQxlsMTuDBLSBu(nsdNahNGsTCu9CsnDvDDrz7sOVlICEsy9IOy(iI2pcBvFyuiwi2HQfnItUuWB04owGruUiJ4oqGhDsG4wH0rw)nIcGPm6YKjEjL5TABYnMdDi0G3NAvhRQQ2QuD8agFsyzmhIQId5cmYHvizAJJMVKY0(WBvFyuiwi2HQhACKOSlFfglgCzi2bJ7ybgXNYbIlPrpdmsoRkNXt5gzugymh6qObVp1QowT1yoOPz8jO9HFJn0kPbFhlWyMgk8L8qxAeNCPG3yRFVp5dJcXcXou9qJJeLD5RWyXGldXoyChlWi(uoqCjn6zaXvyupNrYzv5mEk3iJYaJ5qhcn49Pw1XQTgZbnnJpbTp8BSHwjn47ybgZ0qHVKh6sJ4Klf8gbHDMuGaOQSNLoDuijEiqGKLqtCdwL4QsCPCIBRFVtUpmkele7q1dnItUuWBmMVSiuayWscAIRWrC1W)swcTYGcf4sbf(soOlP9kXLKKK4wPVsUuGYxotjzjiUKKKe3xUaIRWrCvhGXrIYU8vyKNXkeZxszf6s9BKCwvoJNYnYOmWydTUJfyeLlYiUde4rNeiUAjlrhiUFWtaVXgAL0GVJfy0izLWmvdTiSa2BrJ7ybgZZye3rZxsze3KLu)ghXtOnYIfi8dgkxKrChiWJojqC1swIoqC)GNa(bZyo0HqdEFQvDSARXCqtZ4tq7d)gXsAsn0QmTe4Ap0i(C58jReMP8q)EF2(WOqSqSdvp0io5sbVXZtCF5mLKLG4ssssCfZsNwPaonPUYmbghjk7YxHrEKcmsoRkNXt5gzugySHwjn47ybgnMujWYHOQWOEYLcEJ7ybgZJuGrYkHzQgArybS3IgZHoeAW7tTQJvBnMdAAgFcAF43yoevfhYfyKdRqY0e3ZG4kme3AgpEjLrChCIBRYKtCpNXgADhlWOFVhGpmkele7q1dnItUuWB88exXS0PvoJVqAkFPmtGXrIYU8vySg6sJKZQYz8uUrgLbgBOvsd(owGrJ7ybgpRqxAmh6qObVp1QowT1yoOPz8jO9HFJKvcZun0IWcyVfn2qR7ybg97TWYhgfIfIDO6HgXjxk4nEEIRyw60k1rXibuGtdUYmbghjk7YxHrDumsaf40GBKCwvoJNYnYOmWydTsAW3XcmAChlWigfJeaXnNgCJ5qhcn49Pw1XQTgZbnnJpbTp8BKSsyMQHwewa7TOXgADhlWOFVh7dJcXcXou9qJ4Klf8gFAIeDq5Ks7vAsmTXrIYU8vyue4AGNYi5SQCgpLBKrzGXgAL0GVJfy04owGXHaxd8ugZHoeAW7tTQJvBnMdAAgFcAF43izLWmvdTiSa2BrJn06owGr)Epi9HrHyHyhQEOXrIYU8vyuYMbNfVKYkKsYsuGMUWxcfg0zSeDWi5SQCgpLBKrzGXgAL0GVJfy04owGrYzZGZIxszKaXDqizjiU00e3VeiUj7mwIoymh6qObVp1QowT1yoOPz8jO9HFJKvcZun0IWcyVfn2qR7ybg979GYhgfIfIDO6Hghjk7YxHXxMa46cPZ4kmsoRkNXt5gzugySHwjn47ybgnUJfy8qMa4NPM4oWmUcJ5qhcn49Pw1XQTgZbnnJpbTp8BKSsyMQHwewa7TOXgADhlWOFVvB9HrHyHyhQEOXrIYU8vym0LXkyGUqAoWsgfgjNvLZ4PCJmkdm2qRKg8DSaJg3XcmosxgRGbNPM4oqoWsgfgZHoeAW7tTQJvBnMdAAgFcAF43izLWmvdTiSa2BrJn06owGr)ERQ6dJcXcXou9qJ4Klf8gfgI7hDG9k1HiWFk9lvcSqSdvIljjjXvmlDALc4qnEkxrbDsY0pd0ALzciUNJ4sIe3p6a7vk2P06hDktReyHyhQexsK4kMLoTsXoLw)OtzALvAsmIljsCN0LiTGaQK9ALZmohypXv4jUdW4irzx(kmYHeCAsFPrYzv5mEk3iJYaJn0kPbFhlWOXDSaJ5qconPV0yo0HqdEFQvDSARXCqtZ4tq7d)gjReMPAOfHfWElASHw3Xcm63B1t(WOqSqSdvp0io5sbVXjDjsliGkzVw5mJZb2tCfEI7amosu2LVcJCPaJKZQYz8uUrgLbgBOvsd(owGrJjvcSCiQkmQNCPG34owGXCPaJKvcZun0IWcyVfnMdDi0G3NAvhR2Amh00m(e0(WVXCiQkoKlWihwHKPjUNbXvyiU1mE8skJ4o4e3wLjN4EoJn06owGr)ERMCFyuiwi2HQhAeNCPG345jUVCMsYsqCjrIBXGldXoOmtdf(sEOljUchXT14irzx(km(L8qxAKCwvoJNYnYOmWydTsAW3XcmAmPsGLdrvHr9Klf8g3XcmEuYdDPrYkHzQgArybS3IgZHoeAW7tTQJvBnMdAAgFcAF43yoevfhYfyKdRqY0gBO1DSaJ(9w9S9HrHyHyhQEOXrIYU8vyuxYHQrYzv5mEk3iJYaJn0kPbFhlWOXDSaJyjhQgZHoeAW7tTQJvBnMdAAgFcAF43izLWmvdTiSa2BrJn06owGr)(nEwq6iR)EOFB]] )

    storeDefault( [[SimC Feral: precombat]], 'actionLists', 20171112.010004, [[dCtSeaGEreTlevBteLztPBkW3Oi7uI9s2nQ2pfmkPs1We0VvCAHgQuPmyuYWbQdsrDkku5yO44uO0cbjlfilgHLJ0dLKEQQLjcpxutKcvnvqmzatxPlkv5WuDzORlsBusOTkvSzjrBhL6zIinljbtJcfFNc58ikVgrmAj1Jb1jbPUTuUMiQUNuj)fr6ZsvTorewmcIEpUtyrarOB8yLEQDfu6hmchDBmj9noCvyctQoi0IEgvjriJjggMqYzmLCtjsM(HPrWRUUz4no8SGOcJGO3J7eweqqPFyAe8QVUf5l5e2zaw3o8m5i3jSiGUzIOnUKPtX(0XOTwhAoqe23HQZhoQhmaDCAXBOUEXBOoiSpDmAR1bHw0ZOkjczmXeQdcZtkfgZcIw9Q1imjbdBSH8ve6bdqXBOUwvsii694oHfbeu6hMgbV6H6MjI24sMoBNgDclQdnhic77q15dh1dgGooT4nupnJKU1upxRx8gQ)DOObwDCBkQBM2pRZ9g2vAgjDRPEUUcSDBk2vOoi0IEgvjriJjMqDqyEsPWywq0QxTgHjjyyJnKVIqpyakEd11Qssfe9ECNWIack9dtJGxD0ytJGbJaKBtRSsNuJOoyWrE)SbwohWalgdSgQbwH6MjI24sMoBNgDclQdnhic77q15dh1dgGooT4nupnJKU1upxRx8gQ)DOObwDCBkAGv3zmoDZ0(zDU3WUsZiPBn1Z1vGTBtXUy0bHw0ZOkjczmXeQdcZtkfgZcIw9Q1imjbdBSH8ve6bdqXBOUwvmgbrVh3jSiGGs3mr0gxY0bthJS6qZbIW(ouD(Wr9GbOJtlEd11lEd17gDmYQdcTONrvseYyIjuheMNukmMfeT6vRryscg2yd5Ri0dgGI3qDTQKCbrVh3jSiGGs3mr0gxY0H9L0khAthAoqe23HQZhoQhmaDCAXBOUEXBOEvFnWQIdTPdcTONrvseYyIjuheMNukmMfeT6vRryscg2yd5Ri0dgGI3qDTQKmbrVh3jSiGGs)W0i4vFN(9Ti5GNno8SUzIOnUKPdE24W1HMdeH9DO68HJ6bdqhNw8gQRx8gQ3TzJdxheArpJQKiKXetOoimpPuymliA1RwJWKemSXgYxrOhmafVH6A1Qx8gQ)yRQbwvePUnjmWcmfHNgHVALa]] )

    storeDefault( [[SimC Feral: cooldowns]], 'actionLists', 20171112.010004, [[daeDjaqikkTiHKSjiYNOOWOOs6uuPAxezyq4ysPLjv8mHuMgff11aLSnHs(ge14aLY5esK1rrrMNqQUNqX(Os5GeflKc6HuunrHK6IeL2OqP(OqcDskWnbv7KqdviblLk8ustLcDvHe1wPsSxL)sfnyOoSQwmKESGjlYLr2Su1NPiJwO60u61GIzlQBdYUv53sgUuSCu9CQA6axNGTle9DHW5jQwpOunFPs7hLx7mov27rZuAOtJAQ)fYGz4uTHc2pBH9hyRBITiI2uhuMEpnXoiArUTTfHulYWc5oXAQg42gW0PYea268Z4eBNXPYEpAMsZWPAGBBatnldJk03lfEGZ(Idjj0mvguB2cKpn9(4tn4s2Wdk(0RoAk8k5YZfFiA6uXhIMg1Vp(uhuMEpnXoiArUfXuhKVe4bYpJdm184uag4vKeeDGHofELeFiA6atSZmov27rZuAgovdCBdykOmzktsHQYPkIZZWiXWUYW0rCtYLccCoDag2Tyy4OHGHrIHDLHdvLtveNeWAI4EN9cC5sCc6TNNHDJHHfd3TldJk03lbSMiU3zVaxUKqdd7od7(uzqTzlq(uuI7jomtn4s2Wdk(0RoAk8k5YZfFiA6uXhIMAiX9ehMPoOm9EAIDq0IClIPoiFjWdKFghyQ5XPamWRiji6adDk8kj(q00bMy0MXPYEpAMsZWPAGBBatPJ4MKlLOEBWcyy3IHHJfIPYGAZwG8PaRjI7D2lWLp1GlzdpO4tV6OPWRKlpx8HOPtfFiAQrRjIBgEgo2cC5tDqz690e7GOf5wetDq(sGhi)moWuZJtbyGxrsq0bg6u4vs8HOPdmrZ8mov27rZuAgovdCBdyAOGqlNnL9aEPGaNthGHJHHrWWiXW0rCtYLccCoDag2TyyyyHyQmO2SfiFkLfoY70KGn9xGMAWLSHhu8PxD0u4vYLNl(q00PIpenv2SWrMHNHJIc20FbAQdktVNMyheTi3IyQdYxc8a5NXbMAECkad8kscIoWqNcVsIpenDGjcRzCQS3JMP0mCQg42gWu6iUj5sbboNoad7wmmC0qWWiXWUYWHQYPkItcynrCVZEbUCjob92ZZWUXWTWIH72LHrf67Lawte37SxGlxsOHHDFQmO2SfiFQ9cp)EGTUPgCjB4bfF6vhnfELC55IpenDQ4drtn4cp)EGTUPoOm9EAIDq0IClIPoiFjWdKFghyQ5XPamWRiji6adDk8kj(q00bMySMXPYEpAMsZWPAGBBatbLjtzsQPa268mmsmSRmm45MiGeWcrobLZKLy4OZWXcwmC3UmSRmmWcrobLZKLy4OZWTWgcggjg2vggvOVxcL4EIdJKqdd3TldJk03lzVWZVhyRtsOHHDNHDNHDFQmO2SfiFAtbS1n1GlzdpO4tV6OPWRKlpx8HOPtfFiAAuOa26Mkd3KF69qumrvdVY1zIsoBQiiEun1bLP3ttSdIwKBrm1b5lbEG8Z4atnpofGbEfjbrhyOtHxjXhIM2WRCDMOKZMkcIpWerEgNk79OzkndNQbUTbmnuqOLZMYEaVuqGZPdWWUfdd3HHrIHDLHnldd(mDaj0CvjWNRZlr3JMPed3TldJk03lHMRkb(CDEjHgg29PYGAZwG8PVp(d9h5D2ZPd2Lp1GlzdpO4tV6OPWRKlpx8HOPtfFiAQm(4p0FKz4z4yZPd2Lp1bLP3ttSdIwKBrm1b5lbEG8Z4atnpofGbEfjbrhyOtHxjXhIMoWeHTzCQS3JMP0mCQg42gW0qbHwoBk7b8sbboNoadhDggwmmsmmDe3KCPGaNthGHDlgg(daBDs8hgskuEadJedNkGe)HHKAGeYaBt2sCgo6mChPwggjggvOVxcynrCVZEbUCjHgggjg2vggvOVxcnxvc8568scnmC3UmSzzyWNPdiHMRkb(CDEj6E0mLyy3zyKyyxzyZYWGpthqYEHNFpWwNeDpAMsmC3UmCOQCQI4KSx453dS1jXjO3EEg2ngUf2yy3zyKyyZYWOc99s2l887b26KeAMkdQnBbYN6J)PkcikNMAWLSHhu8PxD0u4vYLNl(q00PIpenvJ)PkcikNM6GY07Pj2brlYTiM6G8Lapq(zCGPMhNcWaVIKGOdm0PWRK4drthyIrPzCQS3JMP0mCQmO2SfiFQGNCAbeKFQbxYgEqXNE1rtHxjxEU4drtNk(q00OSNyydaeKFQdktVNMyheTi3IyQdYxc8a5NXbMAECkad8kscIoWqNcVsIpenDGbMk(q0u1czodhBI)zZedhQkNQio)aBa]] )

    storeDefault( [[SimC Feral: single target]], 'actionLists', 20171112.010004, [[dWJjgaGEvjPnPkHDjvTnGe7tvsmtKunBQmFkLUPQ4BQkDAuTte2Ry3G2pPgfIGHrcJtvI6WkEMQKAWumCsYbjPofqshtIopLKfcelfOwmsTCuEiI6PqltvX6irnrvjYuvvnzatxLlsI8APsxM46syJisBLsvBgj2oLIdbKQVJKmnGuMhIq3ws)vQy0uIhlLtsj1NvL6AiIUhsklIsLNtv)wPtz(dQeCODcqOd(scLPWDbKGOkPXhh)vNJVWquQ41bbloz8si(OO8BzzPI(YVK87hqji2yCvxWGQBhFH(8hIY8huj4q7eGasqSX4QUGGU2qxqHsFBUouwwTVqvq10Ch)SkyBUouwwnO1qaEBULfeUqj4Zcy)WiMQemiXuLGKNtBiDz1GGfNmEjeFuu(TurqWIFlynXN)CbjBrADFwBKQaVqh8zbiMQemxi(K)GkbhANaeqcIngx1fKUGcLEvSLkxFHkTXwB1g6cku69wgGLQQ4a6lufunn3XpRcYMUsqRHa82ClliCHsWNfW(HrmvjyqIPkbbpDLGGfNmEjeFuu(TurqWIFlynXN)CbjBrADFwBKQaVqh8zbiMQemxiED(dQeCODcqajOAAUJFwfSnoxNPD8f2XX9xqRHa82ClliCHsWNfW(HrmvjyqIPkbjpoN2OUD8fQnuN7VGQzV9bHtvOMDiVswBivyJtzTPTRdyPc6TliyXjJxcXhfLFlveeS43cwt85pxqYwKw3N1gPkWl0bFwaIPkbrELS2qQWgNYAtBxhWsf0NleGw(dQeCODcqaji2yCvxW2wP3oQwo889TcgtGN2qnTHKAZl0MBCc86PD7cCJBH(Ebo0obqBEH2qxqHspTBxGBCl03dSub1MxOnKG2a6AdDbfk9CyByW54lSVqL2yRTAdWE9mUQEMuho0RnKO28YAJT2Qna71ZMUsptQdh61gsuBiP2aQbvtZD8ZQGm5nBP6Se0AiaVn3YccxOe8zbSFyetvcgKyQsqWYB2s1zjiyXjJxcXhfLFlveeS43cwt85pxqYwKw3N1gPkWl0bFwaIPkbZfcsM)GkbhANaeqcIngx1fSTv6TJQLdpFFRGXe4PnVI2aAbvtZD8ZQGScyNPD8f2XX9xqRHa82ClliCHsq8y82r2I06gqc(Sa2pmIPkbdIwwQEwaofUW8bKGetvccUaQnQBhFHAd15(lOA2BFq4ufQzhYRK1gsf24uwBWFTHchY9weM3UGGfNmEjeFuu(TurqWIFlynXN)CbjBrADFwBKQaVqh8zbiMQee5vYAdPcBCkRn4V2qHd5ElcZNleGs(dQeCODcqajOAAUJFwfKva7mTJVWooU)cAneG3MBzbHluc(Sa2pmIPkbdsmvji4cO2OUD8fQnuN7pTHekb1GQzV9bHtvOMDiVswBivyJtzTb)1M3cuyZTmVDbbloz8si(OO8BPIGGf)wWAIp)5cs2I06(S2ivbEHo4ZcqmvjiYRK1gsf24uwBWFT5Taf2ClZNlxqIPkbrELS2qQWgNYAJNdF7eT5g2B5YLaa]] )

    storeDefault( [[SimC Feral: ST finishers]], 'actionLists', 20171112.010004, [[d0Z4gaGEqj1Maf7cv2gPQY(qv65cnBvz(Qq3ev1HfDBbltLyNuXEH2nj7xXOqrdde)MOZdsDALgSudNGdHsPtHchtLACQiwiHQLcQwmv1YbEOkWtP8yszDGsYebLWujvMSQA6sUOkONrvQlJCDQ0gbLYwbj2SkPTRI6ZeY3bLQPbkrZdK03qPAvekJMQy8KQQoPks3IuvUgkf3JQK)IsEnPkhevX4nQdTdvP)J(OpAWc6A6(kuC0mnWkuOHMtgi0SnCW0WgbYhSAAt30xx1g9qGiAWPhLrcDUa5M977BiC3SZg2VOFObNYp062aHgZPfiqCJfPkwb3xTcVLatZ70FzXbwboHG7RwH3sGPzmnmtZCAafYvfNwFtZC6VliRvQMwSPHWDY0mMMX0hponZPbuixvCA9nnZP)UGSwPAAXMgcN3tZyAgOXJwTsve1Ho3Oo0ouL(p6JIJMPbwHcnF3Rx5I55ueXcita3xc7k04XFFBbnAX8CkIybKjaTtv)vlljanLurOXx(HscCYaHgAozGqZYZPiAA4YeGgC6rzKqNlqUz)gcAWPO0fOrruhwODGhstp(YZuGuf6JgF53jdeAyHoxqDODOk9F0hfhntdScfASD6A10BvIM(4XPzonGc5QItdvVM(7cYALQPfBAiCEpnJPHzAMtxjqevCEO8vE4e0QP5D6lSzAyMMTtx5Jufxm9jqjLLhosL(p6pnJPpECAMtdOqUQ40q1RP)UGSwPAAXMgc3jtdZ0ceiUXIufRG7RwH3sGP5D6VS4aRaNqW9vRWBjW0mMgMPReiIkUAdeRsY6V008o9jOb7EifCk)qJwudScfANQ(RwwsaAkPIqJh)9Tf0Obwb04l)qjbozGqdn4u(Hw3gi0yoTabIBSivXk4(Qv4TeyAEN(lloWkWjeCF1k8wcmnJPHzAMtdOqUQ406BAMt)DbzTs10InneUtMMX0mM(4XPzonGc5QItRVPzo93fK1kvtl20q48EAgtZanNmqObFfqJhGOiAvcerfR9QxSTwn9wLOJhzcOqUQiu967cYALkXGW5ndyywjqevCEO8vE4e0kEVWgyyBLpsvCX0NaLuwE4iv6)OpJJhzcOqUQiu967cYALkXGWDcmceiUXIufRG7RwH3saE)YIdScCcb3xTcVLamGPsGiQ4QnqSkjR)s8EcAWPhLrcDUa5M9BiObNIsxGgfrDyH2bEin94lptbsvOpA8LFNmqOHf64nQdTdvP)J(O4OzAGvOqZ396vUyEofrSaYeWbOqUQ40qD67lOXJ)(2cA0I55ueXcitaANQ(RwwsaAkPIqJV8dLe4Kbcn0CYaHMLNtr00WLjyAM3mqdo9OmsOZfi3SFdbn4uu6c0OiQdl0oWdPPhF5zkqQc9rJV87KbcnSqhyjQdTdvP)J(O4OzAGvOqZ396vURlbGMfG(Sc5giqKZvanE833wqJwi3aANQ(RwwsaAkPIqJV8dLe4Kbcn0CYaHg)CdObNEugj05cKB2VHGgCkkDbAue1HfAh4H00JV8mfivH(OXx(DYaHgwOdBqDODOk9F0hfhnE833wqJ2vci1wPBKL)weANQ(RwwsaAkPIqJV8dLe4Kbcn0CYaHgSraP2kDJtl(weA8aefrlK6plsrarq71nAWPhLrcDUa5M9BiObNIsxGgfrDyH2bEin94lptbsvOpA8LFNmqOHfwOzcK2MVfwN1kvOZneVXcra]] )

    storeDefault( [[SimC Feral: ST generators]], 'actionLists', 20171112.010004, [[dae6oaqiQsSjQIrjKoLqSkHkVIikClIQAxKyyQQoMkAzQcptfyAuL01iIQTreL(gryCQqPZPcvADQqvnpIi3JOk7tcCqQKwivIhkbnrIOOlku1gvHQCsvq3KiTtQyPQkpLYujkBvfYEb)LKAWkoSOfdvpgktwWLr2mj5ZsOrlrNMWRfkZws3wL2nQ(nKHRkDCvOOLJYZj10L66uvBNOY3vfnEvOIZtLA9QqH5tvQ9R0WjidS45jELcaoysMKQ0V2GlGzymXBdgyo5LaZe3c354rSSE83XKTtrItSSrmnyFuLsnbop(pL4888x5ucjxIhswW(Om4wM4sGXOBk46DK)or3j4ZYwG47e3o)khSteWCfRfiUgKboNGmWINN4vkaUaMHXeVnyDwjERGxrOqNvexRq8eVsHD8SdUVkvkVmkKnI5wT(PqvZjTwX)Dhp7G7RsLcEfHcDwrCTsa9KVJNDWqxCK6xKG3AfmFgJ49ofiVDESJNDWqOAa9KRK6Y8MCsRwfJ4hd3km6McUEhjTtrSayUIlQI2nymQid9Slb7qEqGLnIbghXjWKIchLmN8sGbMtEjW(OIm0ZUeSpQsPMaNh)NsC(d2hPr(mmsdYGgScljSysrYrxI3aoysrbN8sGbn48aKbw88eVsbWfWmmM4TbRZkXBf8kcf6SI4AfIN4vkSJNDW9vPs5LrHSrm3Q1pfQAoP1k(V74zhCFvQuWRiuOZkIRvcON8D8Sdg6IJu)Ie8wRG5ZyeV3rE741D8Sta1kSmgPWOBk46DK0oEfmxXfvr7gmgvKHE2LGDipiWYgXaJJ4eysrHJsMtEjWaZjVeyFurg6zxUt0ZiG9rvk1e484)uIZFW(inYNHrAqg0GvyjHftkso6s8gWbtkk4KxcmObNdazGfppXRuaCbmdJjEBWOJPV49LckPO6ZqQFr(CmIP3XZoDwjERGxrOqNvexRq8eVsHD8St0DW9vPs5LrHSrm3Q1pfQAoP1k6oXITtb78yhV9ENO7G7RsLYlJczJyUvRFku1CsRv0DIfBNc25Chp7eqTclJrkm6McUEhjTZb7ezNi74zhCFvQuWRiuOZkIRvcONCWCfxufTBWyurg6zxc2H8GalBedmoItGjffokzo5LadmN8sG9rfzOND5orFebSpQsPMaNh)NsC(d2hPr(mmsdYGgScljSysrYrxI3aoysrbN8sGbn44vqgyXZt8kfaxaZWyI3gSeRfYrQjoDfKENc25emxXfvr7gmCMFNv16AQlb7qEqGLnIbghXjWKIchLmN8sGbMtEjWCH53zDhRM6sW(OkLAcCE8FkX5pyFKg5ZWinidAWkSKWIjfjhDjEd4GjffCYlbg0GJKdYalEEIxPa4cyggt82GfDhVStlWIj4f3XBV3Hr3uW17iPDc(SSfi(oXTZVYb7ezhp7eDNeRfYrQjoDfKENc25XoraZvCrv0UbRlzPUeSd5bbw2igyCeNatkkCuYCYlbgyplj(hLb3GPXyI3gmN8sGjRKL6sWkSKWIjfjhDjEd4G9rvk1e484)uIZFW(inYNHrAqg0G9rzWTmXLaJr3uW17i)DIUtWNLTaX3jUD(voyNiGjffCYlbg0GJKfKbw88eVsbWfWmmM4TbZl70cSycEXD827DIUJx2PZkXBf8kcf6SI4AfIN4vkSJNDy0nfC9osANGplBbIVtC78RCWor2XZoDYksTslUK6gPoiODkyhVc2ZsI)rzWnyAmM4Tb7qEqGLnIbghXjWCfxufTBWyzmcmPOWrjZjVeyG9rzWTmXLaJr3uW17i)DIUtWNLTaX3jUD(voyNiG5KxcSVmgbMRSIAW6KvKA1cvYZlTalMGx0BVJ6LoReVvWRiuOZkIRviEIxPGhgDtbxlPGplBbIh3VYbr80jRi1kT4sQBK6GGkWRG9rvk1e484)uIZFW(inYNHrAqg0GvyjHftkso6s8gWbtkk4KxcmObhjazGfppXRuaCbmdJjEBW6Ss8wbVIqHoRiUwH4jELc74zhCFvQuWRiuOZkIRv8F3XZor3j6om6McUEhjjVDKyNi74zNxIPf6M4T6RFTfVvbX2PGDcOwHLXiL3RFTfVvbX2jUD(vowjFNi74zNozfPwPfxsDJuhe0ofSJxb7zjX)Om4gmngt82GDipiWYgXaJJ4eyUIlQI2nySmgbMuu4OK5KxcmW(Om4wM4sGXOBk46DK)osaMtEjW(Yy0orpJaMRSIAW6KvKA1cvYRZkXBf8kcf6SI4AfIN4vk4b3xLkf8kcf6SI4Af)xprJYOBk4AjjpjI45LyAHUjER(6xBXBvqSccOwHLXiL3RFTfVvbXI7x5yL8iE6KvKALwCj1nsDqqf4vW(OkLAcCE8FkX5pyFKg5ZWinidAWkSKWIjfjhDjEd4GjffCYlbg0GZXcYalEEIxPa4cyggt82GfDhCFvQuArrIPvRYN5wX)Dhp7eDNO7CUJKXo384OgRmzfj9oYFhSYKvK0QvXsSwG4zDNi7e3omcRmzfj1T4s7ezNiG5kUOkA3GHZ87SQwxtDjyhYdcSSrmW4iobMuu4OK5KxcmWCYlbMlm)oR7y1uxUt0ZiG9rvk1e484)uIZFW(inYNHrAqg0GvyjHftkso6s8gWbtkk4KxcmObNJlidS45jELcGlGzymXBdw0D8YoTalMGxChV9EhgDtbxVJK2j4ZYwG47e3o)khStKD8St0DKlzIeVsk(AsDxYsD5oYBNh74T37KyTqosnXPRG07uWoN7ebSNLe)JYGBW0ymXBd2H8GalBedmoItGjffokzo5LadmxXfvr7gSUKL6sWCYlbMSswQl3j6zeW(Om4wM4sGXOBk46DK)or3j4ZYwG47e3o)khSteW(OkLAcCE8FkX5pyFKg5ZWinidAWkSKWIjfjhDjEd4GjffCYlbg0GZ5pidS45jELcGlGzymXBdw0D8YoTalMGxChV9EhgDtbxVJK2j4ZYwG47e3o)khStKD8SJCjtK4vsXxtQ7swQl3rE7CUJNDW9vPsbRsjdl1TGxuX)fSNLe)JYGBW0ymXBd2H8GalBedmoItGjffokzo5LadmxXfvr7gSUKL6sWCYlbMSswQl3j6JiG9rzWTmXLaJr3uW17i)DIUtWNLTaX3jUD(voyNiG9rvk1e484)uIZFW(inYNHrAqg0GvyjHftkso6s8gWbtkk4KxcmObNZtqgyXZt8kfaxaZWyI3gSeRfYrQjoDfKENc25emxXfvr7gm9tXlb2H8GalBedmoItGjffokzo5LadmN8sGzpfVeyFuLsnbop(pL48hSpsJ8zyKgKbnyfwsyXKIKJUeVbCWKIco5LadAW58bidS45jELcGlG5kUOkA3GPlzuaSd5bbw2igyCeNatkkCuYCYlbgyo5LaZkzuaSpQsPMaNh)NsC(d2hPr(mmsdYGgScljSysrYrxI3aoysrbN8sGbn0GzVeMiRIJr2cehCo)paAaa]] )

    storeDefault( [[IV Guardian: Single]], 'actionLists', 20171112.010004, [[dGZveaGErvTlHY2aG9je1SP4McPUTG2Ps2lz3G2pGmkQQQggQ8Bk9CQmuHadgGgUOCqQItrvL6yk1HvSqQslvGfJWYrzziXtLESiRJQkAIIQ0urvtgrtxLlsv5QcH6YqxhPoVq1wPQk2mq2UqKpsvLCAv9zrLVlQI5jeYFbqJgqnnHKojs6Ba11esCpQQkVMQk8mHGghvvP1w8Q(GdHbjfH6AcrvQ(dqa6x0dJ8hOFceG9H5mOAtSp7uvdqdooulkCBW79Ml2gCuatbaQndt)y(8N7TqT2Crv1t6El0jET2Ix1hCimiP8QUMqunIDiqas9WqNkvi5NMZYuHwiQ6H4n)fxL2Ha8pm0PgGolnlHoXRtnan44qTOWTbV5uBI9zNQoTOiEvFWHWGKYR6AcrvEGzJdyvQqYpnNLPcTqu1dXB(lU6bmBCaRgGolnlHoXRtnan44qTOWTbV5uBI9zNQoTIqXR6doegKuEvxtiQg9aZzqvQqYpnNLPcTqu1dXB(lUA4aZzq1a0zPzj0jEDQbObhhQffUn4nNAtSp7u1PvufVQp4qyqs5vDnHOA0wle0ZqvQqYpnNLPcTqu1dXB(lUAO1cb9munaDwAwcDIxNAaAWXHArHBdEZP2e7ZovcAqGILBmt6(eaZrpmYFGXOZ0PvueVQp4qyqs5vDnHOAeqBIeY(8r1a0GJd1Ic3g8Mt1dXB(lUAgTjsi7ZhvPcj)0CwMk0cr1a0zPzj0jEDQnX(StLejObbk2bmBCadqcCyXC3K8dGamYab4wNwaq8Q(GdHbjLx11eIQrBTqqpdbcq)F73QbObhhQffUn4nNQhI38xC1qRfc6zOkvi5NMZYuHwiQgGolnlHoXRtTj2NDQKibniqXcTwiONHXyy48qxe5F5sK60cS4v9bhcdskVQRjevJEOnQbObhhQffUn4nNQhI38xC1WH2Osfs(P5SmvOfIQbOZsZsOt86uBI9zNkBYHXs0mgcVidaoDA5VIx1hCimiP8QUMquT55Zq1a0GJd1Ic3g8Mt1dXB(lUQlpFgQsfs(P5SmvOfIQbOZsZsOt86uBI9zNQoDQ5fbn0MtE1jb]] )

    storeDefault( [[IV Guardian: 2-3]], 'actionLists', 20171112.010004, [[dKdueaGErvTlHQTjQY(eImBQ6MIkUTaxgANszVKDdA)cPgfvk1WqPFtPdlzOOsvdwiz4IYbPsofQuCmPAzazHuHLkOfJWYr68cLNQ8yrwhvkmrQu0urvtgrtxLlsfDvQuXZOsvxhfNwvBfvkTzaTDHO(OOsnpuj1NbW3fvYFrL4Ba1ObONtXjrf3cvsUMqO7rLknnHGxtLsghQuz1fVMtyr4rsrO1QauJd3gDu5MPOKFbDJOJcex5ETLOF2PPfIESmOAGy7G79oB8o4icguEAldtF5)8R7Tq16SrqZv6El0iE16IxZjSi8iPCOTe9ZonTq0yzOj0iEDAUiE)FX0ymix(ddmACGKFQolvdAHOwi6XYGQbITdUZQ1QauZDmy0rX5WaJo1ajEnNWIWJKYH2s0p700crJLHMqJ41P5I49)ft7aKwga14aj)uDwQg0crTq0JLbvdeBhCNvRvbOgpG0YaOo1CV41CclcpskhAlr)SttlenwgAcnIxNMlI3)xmTGccGh14aj)uDwQg0crTq0JLbvdeBhCNvRvbOwofeapQtTiiEnNWIWJKYH2s0p70iyacmoaLVs3N4camfL8lyCMmTq0yzOj0iEDAUiE)FX0cSwiWNIACGKFQolvdAHOwi6XYGQbITdUZQ1QaulhRfc8POo1IO41CclcpskhAlr)StJejyacm(biTmaYfcSOXnxLCRi11Cr8()IPLX4Jms)8rTq0JLbvdeBhCNvJdK8t1zPAqle1crJLHMqJ41P1QauJ7z8rgPF(Oo1Yt8AoHfHhjLdTLOF2PrIemabgpWAHaFkgNIb1dnCT7cqIuZfX7)lMwG1cb(uule9yzq1aX2b3z14aj)uDwQg0crTq0yzOj0iEDATka1YXAHaFkgDuUDNB0PgyXR5eweEKuo0wI(zNgTaaJNyOueErkpwnxeV)VyAbfJxle9yzq1aX2b3z14aj)uDwQg0crTq0yzOj0iEDATka1YPy86uJ7eVMtyr4rs5qBj6NDAAUiE)FX0m56ZqTq0JLbvdeBhCNvJdK8t1zPAqle1crJLHMqJ41P1QauB56ZqD60CteyX4p5qNea]] )

    storeDefault( [[IV Guardian: 4+]], 'actionLists', 20171112.010004, [[dqZrdaGEQkTlvkBJGyFQuPztLBsq52QKDkQ9I2nu7NQIHrs)wKHsamyIudxqhKsCmvSqkLLsvwmKwofhwYtvESqRtLQAIeinvsmzcnDPUiLQxra6zQuLRtupNuBLaXMPK2obvFKaQLbHptK8Dcs)LQQoTQgTaUQkvCsI4Bq01iqDEbAAuv51eqUmyEOcNDCH6arIYLRlGtIG4J0cSCze)cFFFK2pbKBrZh2CCEGdknWmc1dYZ5OE7GuWirieUfcXVCVVv)jmZhv)4Se7pH1uH5dv4SJluhisBClA(WMJZd0jzte0uHnNf039Dqozn4)3WLMtcw8JvNmC4eg48ahuAGzeQhKhvUCDbC3rd(iTKgU0Szgbv4SJluhisBClA(WMJZd0jzte0uHnNf039DqUoGP0b4KGf)y1jdhoHbopWbLgygH6b5rLlxxaNsatPdWM57rfo74c1bI0g3IMpS548aDs2ebnvyZzb9DFhK7QWs5aojyXpwDYWHtyGZdCqPbMrOEqEu5Y1fWjSclLdyZSFuHZoUqDGiTXTO5dBouzRwVjv5Qy)r)LsUmIFHVjhY5b6KSjcAQWMZc67(oi3vkHT(gGtcw8JvNmC4eg48ahuAGzeQhKhvUCDbCclLWwFdWMzbtfo74c1bI0g3IMpS5ebuzRwV1bmLoG)OqzUP7kkq39Wzb9DFhKlu2jCW8(cCEGdknWmc1dYJkNeS4hRoz4WjmW5b6KSjcAQWMlxxaNai7eoyEFb2mleQWzhxOoqK24w08HnhNf039DqoTq)qGZdCqPbMrOEqEu5KGf)y1jdhoHbopqNKnrqtf2C56c4Mq)qGnBobfSwYUM2ytc]] )

    storeDefault( [[IV Guardian: Default]], 'actionLists', 20171112.010004, [[dudldaGEqQAtGe2fjX2ajAFOaZMOBss62OQDcyVIDRQ9lLHPc)MQgSunCjXbLKogqhMYcjPwkiwmvA5eEUepf6XKADOitefQPsIjdQPR0fvj9kuqxg56uXgbP0wrjTzvuBhLYhrPAzQuttLyEGu58OOoTI)kP(gQ0jrf3cfY1aj5EGu8zvKVdsQNHsCaJsWRV5kj44geW4PGCyT1z3XeWJ9m16mMoBoYniQftLnyqiKKScfG7dqUGGGhQaYfQ4EdLbXkKEm5a92o(paGhxcwvVJ)lrjaGrj413CLeCuheW4PGQjt06qRxWhKZdpAB9IGV)PGvDh5SmhCETjEBh)hecv8ocnvIs2Gqijzfka3hGCbpcIAXuzd66C(SkUKjQp7f8Qa7H6pBaUJsWRV5kj4OoiGXtbX5pjPwxXeNOniQftLnOP3HnQMEIFOsRdnToyqiKKScfG7dqUGhbR6oYzzoOW5Rn9o(VwoLnieQ4DeAQeLSb58WJ2wVi47FkOQEyaJNcYH1wNDhtap2ZuRJZFsszdalrj413CLeCuheW4PG3mILwxXeNOTee1IPYg007WgvtpXpuP1zqRd26qrRB6DyJQPN4hQ06qxRFjiesswHcW9bixWJGvDh5SmhuBszTP3X)1YPSbHqfVJqtLOKniNhE026fbF)tbv1ddy8uqoS26S7yc4XEMA9BgXs2aCjkbV(MRKGJ6Gagpf8cdBDftCI2squlMkBqtVdBun9e)qLwNbTolbHqsYkuaUpa5cEeSQ7iNL5GAtkRn9o(VwoLnieQ4DeAQeLSb58WJ2wVi47FkOQEyaJNcYH1wNDhtap2ZuRFHHzZgKX0zZrUrD2ea]] )


    storeDefault( [[Feral Primary]], 'displays', 20171112.010004, [[dSJZgaGEf0lrsSlvjPxRaMPc0SLQBIG6XO42kQTPkPANuzVIDty)Os)urgMQ43qMgvvzOi1GrfdhQoOu65u6yu0XrsTqPyPePwmrTCs9qQkpfSmeyDiinrQQyQQQjtetxPlQqxLiXLv56iAJqXwvLu2mQA7iXhvL40K8zO03PkJejPNrK0OrPXRk1jrOBHG4AuvPZtHdlzTQsIVrvvDmZpatHVkKadsSWA0Vats5pir3yaMcFvibgKyb1WlotccOlb2Zh7XmqAcqn5rETDfwX8j2ambmM45T36RWxfsyJ7jW7jEE7T(k8vHe24EcGRvZL2GidsaQHxC(7jWSs0ogNudqn5rEs8v4RcjSPjGXepV92FPXERnUNawwKh4Pwg22X0e49epV92FPXERnUNakgKaWlgLaBC(nWwAS32kyyr6ant))eHLM4lu9hWiocHaP(e4DCpbSSiVFPXERnnbgqUvWWI0b(t0st8fQ(dOesum1I0TcgwKoG0eFHQ)amf(QqIwbdlshOz6)NiCaa)yuvxnSwfseN5JudyzrEWpnbOM8ip)O0hZQqIast8fQ(diiNjYGe248xal(17y6LL1hQJ05hOIZmGCCMbWgNzaDCMzdyzrE(k8vHe2ih49epV92wsDf3tGIuxFd8lGmjpFG56Dl5II7jGCxnC4lDKxBVh5avhNTawKhnLX4mduDC2YhAwUwAkJXzgWphFr230eO6ELHLMcDAcqrzvYQUAn(g4xa5amf(QqI2UcRiGVr3Fu6asuw8Ez8nWVavaDjWEFd8lqjR6Q1iqrQlcRexAcmGmgKyb1WlotccuDC26xAS3stHooZa6RhW3O7pkDal(17y6LLnYbQooB9ln2BPPmgNzaQjpYtcrHeftTiTnnb8HWn4Y5JcG50vNlN2PXaUA(cG50vNlhATAU0gb2sJ9wmiXcRr)cmjL)GeDJb4rIna9NlhOewUCCLwJ8c8EIN3ElvASXzgWYI8AjxuAcuDC2QT7vgwAk0XzgO64SfWI8OPqhNzaCTAU0gyqIfudV4mjiaU(yqZY12spyaqn7JlhmNU6ekxo46JbnlxBG56n8JZmWC9UDmUNagt882BPsJnocXmWwAS3stzmYbSSipAk0PjGLf5rLZqwjKOeyTPjG0x)k7fhbpM(30085vn9VF9pbVEGIuxTcgwKoqZ0)pr4bhX8dyzrEGNAzyBjxuAcmGmgKydq)5YbkHLlhxP1iVautQyg41uwyn6xGkGLf5ruirXulsBttGzLOLCrX9eO6ELHLMYyAcyzrETJPjGLf5rtzmnbyqZY1stHoYbQooB5dnlxlnf64mdSLg7TyqIna9NlhOewUCCLwJ8cuDC2QT7vgwAkJXzgywjGFCpb2sJ9wmiXcQHxCMeeyazmiXcRr)cmjL)GeDJbyk8vHeyqIna9NlhOewUCCLwJ8cuK6cWVENOFI7jWOOK7NK0eWQMX7x70yCee49epV9wIcjkMArABCpbmM45T32sQR4EcymXZBVLOqIIPwK2g3tGT0yVLMcDKdWGMLRLMYyKdi3vdh(sh5f5autEKNeImibOgEX5VNawwKxlPUik4rroGIbjEfeAoot)gGAYJ8KGbjwqn8IZKGafPUik4rFd8lGmjpFaQjpYtcvASPjGKJVi7Bl9Gba1SpUCWC6QtOC5i54lY(gOi1LueQnaEVmoD2e]] )

    storeDefault( [[Guardian Primary]], 'displays', 20171112.010004, [[dOtOgaGEjPxIq1UGQIETKOzkLy2s1nrcDBqCyQ2jf7vSBuTFfYpvKHPO(nK1bvfgkkgSuQHJOdkfpdQQ6yK0XrsTqj1sLewmjwoLEOc1tv9yu65KAIibtfutMatxPlQGRIq6YaxhkBKG2kcrBMqBhbFejAzijttkPVlrJeHYPjA0i14HQCsOYTGQkxdHW5LWNbP1cvL8nOQuh1aNZ6KReXfI473IoiFIOWTGZmKVUfkyziWeLCRZHcgtdyRm15uJbWanDjuoeaFZzZlMef1GDStUsexhZCoEtIIAWo2jxjIRJzoNAmagqaowe)YQGyADohIK3med(NtngadiyStUsexN68IjrrnyHDluWQJzoxtJkFPCzPBgsDoEtIIAWc7wOGvhZCUMgv(s5Ys3GTOuNVUfkyB4S0iBE9em8efRahLedohVjrrnyjETog18IjrrnyjETog8tnxtJkHDluWQtDELknCwAKnhEIPcCusm4CjxGK1xKTHZsJS5vGJsIbNZ6KReXB4S0iBE9em8efZpjGv6DzvFLiEmQZTMRPrLho15uJbWauqAbSReXZRahLedoNJbbhlIRJP1CnjO3f2Dn9yuhzdCUhJAUsmQ5qJrn3gJA2CnnQCStUsexhLC8Mef1GTbZ6XmN7ywhUGeKRGjkMdXXRbBrXmNR0LvRszhv207rj37K0(PrLmegIrn37K0(yeefFzimeJAofaIowFJsU3l9cndbMuNtqQLkYUClGlib5k5So5kr8MUekpF8GbEOICbsnz3lGlib5EU15qbWfKGCxr2LBrUJzDkk5GuNxPIqeFVSkigvQY9ojTd7wOGLHatmQ5wqpF8GbEOICnjO3f2DnDuY9ojTd7wOGLHWqmQ5uJbWacWXfiz9fz1Po34qa5uI5wbsNpQnJvcXTf5RBHcwHi((TOdYNikCl4md5kDz1Qu2rLrjhVyMZ10OYgmRJJlIIsU3jP9MEPxOziWeJAoehVdhJAoPvcXTfcr89YQGyuPkN0cyrqu8THPLyMZLSio(cHGeJkrKdXXRziM5ChZ644Ii4csqUcMOy(6wOGLHWquYlIb)Oc)NZ10OsIdkuKCbsouDQZfr8nNbEu77C9O2g3ArL5Siik(Yqyik5ftIIAWIJlqY6lYQJzoVysuud2gmRhZCoEtIIAWIJlqY6lYQJzoxtJkXXfiz9fz1PohIK3GTOyMZ9EPxOzimK6CnnQKHWqQZ10OYMHuNZIGO4ldbMOKVUfkyfI4Bod8O2356rTnU1IkZDmRFsqVJJcXmNxPIqeF)w0b5tefUfCMHCis(HJzoFDluWkeX3lRcIrLQCVts7n9sVqZqyig1CwNCLiUqeFZzGh1(oxpQTXTwuzU3jP9Xiik(YqGjg18bUR0bcsDUwcHSdAMgIHQCQXKSvsKs93Ioi3ZRuriIV5mWJAFNRh124wlQmxYI4N0zLCOXqe5So5krCHi(EzvqmQuL7ywVHZsJS51tWWtuSLbHW5AAujdbMuNxbOdCnigQMvX3QQZTIpvZjTsiUTahlIFzvqmToN7DsA)0OsgcmXOMtngadiqiIVxwfeJkv5AAuzd2IsDo1yamGaIxRtDUaGOJ13gMwYXrKJAtjMBfiDo(yuBkaeDS(M7ywNOC5Mt29cGnBc]] )

    storeDefault( [[Feral AOE]], 'displays', 20171112.010004, [[d0JYgaGEPuVefYUGGyBqqzMsjEmsnBP64OkUjkOPrvu3wrEneyNuzVIDt0(rv9tfAyq0Vv1PjzOOYGjOHdvhKQ6YQCms5COaSqf1sPkSyKSCk9qQspfSmuuRdfOjsvKPcPjtGPR0fvWvrvYZqH66iAJqXwrb0Mj02rWhLsACOkvFgk9DPyKOi9CkgnknEi0jrOBHQuUgkIZtQoSK1cbPVbbvhTGgGUWx1lX8Yfw9(fyKxOTq0neGUWx1lX8YfuTV40yoGTKypVShncYCaEipYZVRWkNo5gGoG(OOO5wVf(QEPjoKbqCuu0CR3cFvV0ehYa4w1uz1js)sq1(IZZidmPK(dXX4a8qEKNaVf(QEPjZb0hffn3IwwS3AIdzad73anQLM1FiubmSFJp5(HkGI(LaErRKyJJjbksBruk(O64xaksrXa6XXBA8otcGyCidyy)g0YI9wtMdGakFjn7BdGoY5bXwzkAaLuGIU236lPzFBapi2ktrdqx4R6L(sA23gyEefDKHb8(468fI(bWC2QZxO)4qad73aOzoapKh55jL9Ox1ld4bXwzkAaj5er6xAIZZbm4xVJPxgwVF)TbnqfNwaBCAbWgNwaQ40YgWW(nEl8v9stOcG4OOO5wFsBfhYafPTq1XVauKIIbMke9j3poKbO6Q2TBT)n(9EOcuDC2cy)gocdXPfO64SL3FIQwocdXPfWtNyr23qfO6nLUHJaxMdqqzuuQUA1r1XVaubOl8v9s)UcRmG3bh6GhbeOm49shvh)cqhWwsShQo(fOOuD1QhOiTfdvYlZbqafMxUGQ9fNgZbQooBHwwS3YrGloTa2RhW7GdDWJag8R3X0ldBOcuDC2cTSyVLJWqCAb4H8ipbeLcu01(wtMda4hTQ6Q21QEzCAizCaxnDbWC2QZxO)4qGTSyVfZlxy17xGrEH2cr3qaehffn3YOztCAbqCuu0ClAzXERjoKbmSFJpPTikf)qfO64SLFVP0nCe4Itlq1XzlG9B4iWfNwaCRAQS6yE5cQ2xCAmha3E0)evT(CTeautE5leZzRodYxiU9O)jQAdOpkkAULrZM44nTatfI(dXHmWuHiGgNwGTSyVLJWqOcyy)ggD6ukPaLeRjZbmSFdhbUmhWJRFL5IJzKAiCnnKmbHWmJ1qymMbeOiTLVKM9TbMhrrhzyldyqdyy)gOrT0S(K7N5aiGcZl3aCO8fcL0WxORS2VjapKkAeWavgy17xaQag2VHOuGIU23AYCGjL0NC)4qgO6nLUHJWqMdyy)g)HqfWW(nCegYCa6FIQwocCHkq1XzlV)evTCe4ItlWwwS3I5LBaou(cHsA4l0vw73eO64SLFVP0nCegItlWKscOXHmWwwS3I5LlOAFXPXCaeqH5LlS69lWiVqBHOBiaDHVQxI5LBaou(cHsA4l0vw73eOiTfGF9orpfhYadYIQFcYCaJAcVF(JdXXCaehffn3sukqrx7BnXHmG(OOO5wFsBfhYa6JIIMBjkfOOR9TM4qgyll2B5iWfQa0)evTCegcvaQUQD7w7FtOcWd5rEcis)sq1(IZZidi(YnahkFHqjn8f6kR9BcOOFjc9)P40ysaEipYtaMxUGQ9fNgZb2YI9wFjn7BdmpIIoYqpi2ktrdWd5rEcy0SjZbeCIfzF95AjaOM8YxiMZwDgKVqbNyr23afPT4LuTbW7L(zZMaa]] )


end

