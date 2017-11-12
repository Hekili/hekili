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

        state.unshift = setfenv( function()
            removeBuff( "cat_form" )
            removeBuff( "bear_form" )
            removeBuff( "travel_form" )
            removeBuff( "moonkin_form" )
        end, state )

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
            gcdType = "off",
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
            gcdType = "off",
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
            passive = true,
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
                    return not settings.regrowth_instant or buff.predatory_swiftness.up or time == 0
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
                unshift()
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
            gcdType = "off",
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


    storeDefault( [[SimC Feral: default]], 'actionLists', 20171112.121935, [[dm0YlaqieQArieztiu6tie1OqO4uiKAvie6wiKyxKOHjjhJKwMuvpte00ebCneQSnPKIVHinoes6CeuQ1rqX8KsQCpcQAFeu5GsvwOuPhIOmrck5IiQ2OusojbzLie0lriWmLsQ6MsQDQslvKEk0urWwre7L6VsfdwrhwyXe6XkzYsCzWMfv9zr0OLItt0RfvMTkUTc7gv)gPHtGJlLuA5O8CsnDvDDrz7sP(Ui05jH1lc08LsSFLARAcgjNhIhOyrJ4Ijf8gnEJbyeLdY2ZwbS4im7zbYhzN3ikawY4itW4LuUVQvj0ykCGqd(2VsLuvv1(kRuRQQsaJPquuqqoaJmyesU2yV1lPCTj4RQjyKCEiEGI7AexmPG3yLXBmaJ4tzWEssCYaJ10cjb7gdWyMg68nSq3ySNO8iFfgBhmziEaJcXlYv8uMroLdgtbnnJTaTj43ykCGqd(2VsLu1k)(23emsopepqXDnIlMuWBeATzsbcGIYtw(8rNezHabsEs9Eg8YEQUNu2Ewz8gdWi(ugSNKeNmypjgvI2ynTqsWUXamMPHoFdl0ng7jkpYxHX2btgIhWOq8ICfpLzKt5GXuqtZylqBc(nMchi0GV9RujvTYVVj0emsopepqXDnIlMuWBmwVSn0b4Wqc69u42tn8VKNuRmOqhMuqNVHb6g6PSNT0YEwOVsMuGYxUYj5j3ZwAzpF5a2tHBpvjU9SLw2ZpyjHx5lhqNN2PiH9S1TNevJ9eLh5RWilJ3jwVKY7CK63Oq8ICfpLzKt5Gr8zY1twdSY5UgRPfsc2ngGrJydnXAArMxcmT7A8gdWyAgFp7TEjLVNTEP(n2JLuBKhdq4jsOCq2E2kGfhHzp1sEYdSNFWscprYykCGqd(2VsLu1kJPGMMXwG2e8BKSgyLRM2gga)TOXAA5gdWikhKTNTcyXry2tTKN8a75hSKW733eWemsopepqXDnIlMuWBK43ZxUYj5j3ZwAzpfZYNxPagnXJYmbg7jkpYxHrwKdmkeVixXtzg5uoySMwijy3yagnMydWtHOOWOEXKcEJ3yagtJCGXuikkiihGrgmcjxVNeL9Ky2ZsglEjLVNeX9Sszc3tI2ykCGqd(2VsLu1kJPGMMXwG2e8BKSgyLRM2gga)TOXAA5gdWOFFjotWi58q8af31iUysbVrIFpfZYNx5k(o5PSHYmbg7jkpYxHXsOBmkeVixXtzg5uoySMwijy3yagnEJbyuyf6gJPWbcn4B)kvsvRmMcAAgBbAtWVrYAGvUAABya83IgRPLBmaJ(9T1ycgjNhIhO4UgXftk4ns87Pyw(8k1r7ij0HrdMYmbg7jkpYxHrD0oscDy0GzuiErUINYmYPCWynTqsWUXamA8gdWigTJKWEMsdMXu4aHg8TFLkPQvgtbnnJTaTj43iznWkxnTnma(BrJ10YngGr)(sQjyKCEiEGI7AexmPG34ttM8akxu6PqtKRn2tuEKVcJIatdSCgfIxKR4PmJCkhmwtlKeSBmaJgVXam2fyAGLZykCGqd(2VsLu1kJPGMMXwG2e8BKSgyLRM2gga)TOXAA5gdWOFFjQMGrY5H4bkURXEIYJ8vyuYxbJhVKYnkeVixXtzg5uoySMwijy3yagnEJbyui(ky84LuUWSNebsEY9KMFp)gypjcZ4jpGXu4aHg8TFLkPQvgtbnnJTaTj43iznWkxnTnma(BrJ10YngGr)(kSnbJKZdXduCxJ9eLh5RW4ltcmDN8zmfgfIxKR4PmJCkhmwtlKeSBmaJgVXamsqMeyez9E2QmMcJPWbcn4B)kvsvRmMcAAgBbAtWVrYAGvUAABya83IgRPLBmaJ(9vTYemsopepqXDn2tuEKVcJHUjgbh0DYZaEcQWOq8ICfpLzKt5GXAAHKGDJby04ngGXE6MyeCGiR3ZwXaEcQWykCGqd(2VsLu1kJPGMMXwG2e8BKSgyLRM2gga)TOXAA5gdWOFFvvnbJKZdXduCxJ4Ijf8gjM98JdWFL6qeypL(nkbEiEGYE2sl7Pyw(8kfWGs8uMIo6eL5FoO1kZeSNe9EsS75hhG)kfpuA5JdLRvc8q8aL9Ky3tXS85vkEO0YhhkxRSqtKVNe7EUOdrAhbuj)1kxzmgW)9u43tIZypr5r(kmYGKmAIFJrH4f5kEkZiNYbJ10cjb7gdWOXBmaJPqsgnXVXykCGqd(2VsLu1kJPGMMXwG2e8BKSgyLRM2gga)TOXAA5gdWOFFv7BcgjNhIhO4UgXftk4nUOdrAhbuj)1kxzmgW)9u43tIZypr5r(kmYKcmkeVixXtzg5uoySMwijy3yagnMydWtHOOWOEXKcEJ3yagtLcmMcrrbb5amYGri569KOSNeZEwYyXlP89KiUNvkt4Es0gtHdeAW3(vQKQwzmf00m2c0MGFJK1aRC102Wa4Vfnwtl3yag97RAcnbJKZdXduCxJ4Ijf8gj(98LRCsEY9Ky3Z2btgIhqzMg68nSq3SNc3EwzSNO8iFfg)gwOBmkeVixXtzg5uoySMwijy3yagnMydWtHOOWOEXKcEJ3yagj0WcDJXuikkiihGrgmcjxBmfoqObF7xPsQALXuqtZylqBc(nswdSYvtBddG)w0ynTCJby0VVQjGjyKCEiEGI7ASNO8iFfg1nmOyuiErUINYmYPCWynTqsWUXamA8gdWi2WGIXu4aHg8TFLkPQvgtbnnJTaTj43iznWkxnTnma(BrJ10YngGr)(nkSG8r25Dx)2a]] )

    storeDefault( [[SimC Feral: precombat]], 'actionLists', 20171112.121935, [[dCtSeaGErcTlkkBJIQA2u6Mc62szNIAVKDJQ9tHgfOsnmK63komvdvKsdMcgoOCqb6uIeCmKCCqLSqaSuGSyewokpus6PQEmiRJIQmrkQyQa1KLQPR0fbupxIldDDrSrrI2QKyZGk2ofzzcywIumnrs9DevNhu1PfA0sQVbqNer8za5AuuP7js1FrKEMijVgrzrjW6aZDcl2fHU5GWXtSRaqp7nu)XwvJgsjYCR5z0amgcnncF1bHw0lOYbOPaKIIkGz0u000Pw)qSiSvxpi0ghErGvMsG1bM7ewSla0pelcB1x3I81mc7m91TdVygYDcl21dseTXfEDgceBiFR1jH3Jq(omD(Wr9WPxXzzVH66zVH6GqGyd5BToi0IEbvoanfGu06GWYKWGWIaRvVAncrw4ycBiFfHE40ZEd11QCabwhyUtyXUaq)qSiSvNwpir0gx41n5SOtyrDs49iKVdtNpCupC6vCw2BOEsbjDRzEPwp7nu)7WqJgQ42eupidOIo3By6jfK0TM5L60yYTjy606Gql6fu5a0uasrRdcltcdclcSw9Q1iezHJjSH8ve6Htp7nuxRYPsG1bM7ewSla0pelcB1r4kjcdg2nZMah44KsoZHblYbQy0GZ7gnqz0WWmAGwpir0gx41n5SOtyrDs49iKVdtNpCupC6vCw2BOEsbjDRzEPwp7nu)7WqJgQ42e0Ob4Mkf0dYaQOZ9gMEsbjDRzEPonMCBcMoLoi0IEbvoanfGu06GWYKWGWIaRvVAncrw4ycBiFfHE40ZEd11QCQfyDG5oHf7ca9GerBCHxhgBi3QtcVhH8Dy68HJ6HtVIZYEd11ZEd1tlBi3QdcTOxqLdqtbifToiSmjmiSiWA1RwJqKfoMWgYxrOho9S3qDTkBUcSoWCNWIDbGEqIOnUWRd5lPWzynDs49iKVdtNpCupC6vCw2BOUE2BOEvFnAiLdRPdcTOxqLdqtbifToiSmjmiSiWA1RwJqKfoMWgYxrOho9S3qDTkB(cSoWCNWIDbG(HyryR(oabKfnd2SXHx0dseTXfEDyZghUoj8EeY3HPZhoQho9kol7nuxp7nupTZghUoi0IEbvoanfGu06GWYKWGWIaRvVAncrw4ycBiFfHE40ZEd11Qv)WqOOBJPOVXHRmfDQ0kb]] )

    storeDefault( [[SimC Feral: cooldowns]], 'actionLists', 20171112.121935, [[da0WjaqiQKSibkTje0NikYOOs5ucKDHIHjOJbILHapJOKPjqX1ik12evvFJKY4ikQZrLuSorvP5jq19evzFcWbjQSqQipKkQjkQkUirvBKOqFKkPYjjP6Mi0orPHsLuAPuHNszQKORsLu1wfq7v5VKKbJQddSye9yHMSixgAZGQptcJwu50K61GuZwk3wQ2Tk)wYWfLLJ0ZPQPRQRtKTtLQVtL48GY6jky(GK9t4bzkNj)biByAKZSivN9ZMXc64mt3DwWLrKcA5RGhRQLkxo)S8bHdKA)CAMdSHapowccHOgeiqiGjesyyyWmZbcsWuQ74m8qQcymVUJQ(sLScNjx8115NYXczkNj)biByAonZIuD2pZvcoPeC4mrWRcEr7mszZKJu30pSzjGp3m1VKoc(Io7QdNrSsbcOSGooBglOJZYhGp3mhydbECSeecrniHZCG(sIgr)uUFMZ5Wi0el3XoE)iNrSsSGooB)yjykNj)biByAonZIuD2p7lfkAitSQwQC58coHcUBcoEivbmMOeLI3l4bKNGlRqbNqb3nbpwvlvUCmVwbs9QGlrHXqXoqFEbpabx2couqj4KsWHZ8Afi1RcUefgJuMGhKGh0m5i1n9dBgjs9if6zQFjDe8fD2vhoJyLceqzbDC2mwqhN5es9if6zoWgc84yjieIAqcN5a9LenI(PC)mNZHrOjwUJD8(roJyLybDC2(XkRPCM8hGSHP50mls1z)m8qQcymjeUoQFbpG8e88hotosDt)WM9Afi1RcUef2m1VKoc(Io7QdNrSsbcOSGooBglOJZuQvGuzYl4YOef2mhydbECSeecrniHZCG(sIgr)uUFMZ5Wi0el3XoE)iNrSsSGooB)ydMPCM8hGSHP50mls1z)Sy1jlvzL(EptuIsX7f88e8qbNqbhpKQagtuIsX7f8aYtWLD4m5i1n9dBg2Ko0RsHKobUiot9lPJGVOZU6WzeRuGaklOJZMXc64m5BshktEb31jPtGlIZCGne4XXsqie1GeoZb6ljAe9t5(zoNdJqtSCh749JCgXkXc64S9Jv2t5m5pazdtZPzwKQZ(z4HufWyIsukEVGhqEcUScfCcfC3e8yvTu5YX8Afi1RcUefgdf7a95f8aeCiYwWHckbNucoCMxRaPEvWLOWyKYe8GM5so8CGGeSz(ivN9Zu)s6i4l6SRoCgXkfiGYc64SzYrQB6h2m9fb0d866MXc64m1ViGEGxx3mNZHrOjwUJD8(roZb2qGhhlbHquds4mhOVKOr0pL7N5abjyk1DCgEivbmMx3rvFPswHZiwjwqhNTFS5FkNj)biByAonZIuD2p7lfkAitw9668coHcUBc(dOkWN51Du1xQsAuWdUGNFzl4qbLG7MG)6oQ6lvjnk4bxWHiZHcoHcUBcoPeC4mKi1JuOzKYeCOGsWjLGdNrFra9aVUogPmbpibpibpOzYrQB6h2SS611nt9lPJGVOZU6WzeRuGaklOJZMXc64mxB966MjhvHF2b6yEbBgTA1PatQYkxqAWoZb2qGhhlbHquds4mhOVKOr0pL7N5ComcnXYDSJ3pYzeRelOJZYOvRofysvw5cs3pw1MYzYFaYgMMtZSivN9ZIvNSuLv679mrjkfVxWdipbNabNqb3nb3vc(dA49mKTQspOvNNbpazdtcouqj4KsWHZq2Qk9GwDEgPmbpOzYrQB6h2mGphOdo0Rcofpza2m1VKoc(Io7QdNrSsbcOSGooBglOJZKZNd0bhktEbxgP4jdWM5aBiWJJLGqiQbjCMd0xs0i6NY9ZCohgHMy5o2X7h5mIvIf0Xz7hRmpLZK)aKnmnNMzrQo7NfRozPkR037zIsukEVGhCbx2coHcoEivbmMOeLI3l4bKNGdIVUogkaAKjw(xWjuWt1ZqbqJmzDP2RZAAKk4bxWjGbIGtOGtkbhoZRvGuVk4suymszcoHcUBcoPeC4mKTQspOvNNrktWHckb3vc(dA49mKTQspOvNNbpazdtcEqcoHcUBcURe8h0W7z0xeqpWRRJbpazdtcouqj4XQAPYLJrFra9aVUogk2b6Zl4bi4qKzbpibNqb3vcoPeC4m6lcOh411XiLntosDt)WM5ZbsLlDSLMP(L0rWx0zxD4mIvkqaLf0XzZybDCMLdKkx6ylnZb2qGhhlbHquds4mhOVKOr0pL7N5ComcnXYDSJ3pYzeRelOJZ2pwxZuot(dq2W0CAMCK6M(HntYJQ0p29Zu)s6i4l6SRoCgXkfiGYc64SzSGooZ17rbx9h7(zoWgc84yjieIAqcN5a9LenI(PC)mNZHrOjwUJD8(roJyLybDC2(9ZSmmQbnTmaEDDJfsOS2Vb]] )

    storeDefault( [[SimC Feral: single target]], 'actionLists', 20171112.121935, [[dWJjgaGEPIQnrjPDPcBtQOSpPI0mjj1SPY8Pu6MQOBlL1rc2jc7vSBq7NIrHKkdtLACsfXHv8nsIbtQHtIoij1PqeCmj68sfwOkPLculgPwokper9uOLjv1ZPQjIKQMkqMmGPRQlscDAuDzIRlHnIKSvkP2msSDkvESK(oI0NvjMhIO(RuLdHiYOPetJKKtsPQNHi01OK4EiPSikf)wPxlv6ugqbveo0obi0bPEHYu4(CniX0KGiVr2OPsyJtbJ2ZHxCIr)d7I8bbloz8si6FxQszzz)J7Y77BvfeRmUYpyq11NVqFafIYakOIWH2ja5AqSY4k)GKKrtxqHYrD(Euww7Oqzq10Ch)7iyD(EuwwlO9qaED(LfeUqj45cy9WiMMemiX0KGKN3OPAzTGGfNmEje9VlvP8oiyXVfSQ4dO8bjBrQDpx7KMa)qh8CbiMMemFi6hqbveo0obixdIvgx5hKUGcLdLSLu3rHsJ2wBnA6ckuo8wgGL0M4aokugunn3X)ocYMUsq7Ha868lliCHsWZfW6HrmnjyqIPjbbpDLGGfNmEje9VlvP8oiyXVfSQ4dO8bjBrQDpx7KMa)qh8CbiMMemFiiXakOIWH2ja5Aq10Ch)7iyDCUEt95lSNJ7)G2db415xwq4cLGNlG1dJyAsWGettcsECoJwD95l0Ovn3)bvZU4dcNMqnBqEJSrtLWgNcgDDxhWsk0BtqWItgVeI(3LQuEheS43cwv8bu(GKTi1UNRDstGFOdEUaettcI8gzJMkHnofm66UoGLuOpFiuvafur4q7eGCniwzCLFW62O3Ekxo89h1cgtGVrtnJ2kgTvn6FCc8pOD7c8JBH(dbo0obWOTQrtxqHYbTBxGFCl0FaSKcnARA0uNrtsgnDbfkhCyDyW55l8OqPrBRTgnW(hmUYdM0go0B0KSr3jgTT2A0a7FWMUYbtAdh6nAs2OTIrtcbvtZD8VJGm5cBj9Te0EiaVo)YccxOe8CbSEyettcgKyAsqWYf2s6BjiyXjJxcr)7svkVdcw8BbRk(akFqYwKA3Z1oPjWp0bpxaIPjbZhcReqbveo0obixdIvgx5hSUn6TNYLdF)rTGXe4B0DQrRQGQP5o(3rqwbS3uF(c754(pO9qaED(LfeUqj45cqmnjiYBKnAQe24uWOrqgnfoK7TimFWZfW6HrmnjyqYwKA3Z1oPjWp0bjMMeeCb0OvxF(cnAvZ9Fq1Sl(GWPjuZgK3iB0ujSXPGrJGmAkCi3BryEBccwCY4Lq0)UuLY7GOLL0ZfGtHlmFUgeS43cwv8bu(G4Z41NSfP2nxZhIolGcQiCODcqUgunn3X)ocYkG9M6Zxyph3)bThcWRZVSGWfkbpxaRhgX0KGbjMMeeCb0OvxF(cnAvZ9VrtDLKqq1Sl(GWPjuZgK3iB0ujSXPGrJGm6lcuyZVmVnbbloz8si6FxQs5DqWIFlyvXhq5ds2Iu7EU2jnb(Ho45cqmnjiYBKnAQe24uWOrqg9fbkS5xMpF(GOsPYhhVZNNVWquEtI5ta]] )

    storeDefault( [[SimC Feral: ST finishers]], 'actionLists', 20171112.121935, [[dWZ4gaGEqjAtGu7cvEnvI9HQ0SvL5lKUjQQNlLVrvXHfTtQyVq7MK9RyuOOHju)MOLjv58GIbR0Wj4GOuDkuYXaXPvzHujTuq1IPklh4Huv6PuEmPSoPQKjckHPsOMSQA6sUOq0ZOQQlJCDs1gbLQTcsAZsL2UuX0aL03bLYNjK5bsmoHWQqvmAQuJxQk1jLQQBHsX1KQI7rvL)IchcLs3wWieumArQsVh9rp0Gfu3u)vOROzAGtOqdnNmqOzxW3zHDcKV(Awt8SDp11CtGgAWPhLncD6fdXhiqG0JlgsCCmSIgCk)Wi(ceAmNvGaTRvKQye0F1j8ocmlVZ(Lfh4e4ec6V6eEhbML1SqplZzbuipvBw2mlZz)6GSoPAwEMnMlIzznlRzJgDwMZcOqEQ2SSzwMZ(1bzDs1S8mBmN)ZYAwwOXUwDsvdfJoqqXOfPk9E0hDfntdCcfAE6D7Y1YoPiIbqMaUVe2uOXU39Ucg0AzNueXaitaA9R(NwwsaAkPIqJV8d1e4Kbcn0CYaHMLDsr0SWLjan40JYgHo9IH4dKy0GtnPoqJAOySqZx3KMl8LDOaPk0dn(YVtgi0WcD6HIrlsv69Op6kAMg4ek0y7S1P5YPenB0OZYCwafYt1Mfk(n7xhK1jvZYZSXC(plRzHEwMZwjqevCUP8vU5e0Qz5D2E9zwONLTZw5Jufxl9iqjLLBosLEp6plRzJgDwMZcOqEQ2SqXVz)6GSoPAwEMnMlIzHEwbc0UwrQIrq)vNW7iWS8o7xwCGtGtiO)Qt4DeywwZc9SvcerfxDbIrjz8pAwENnc0Gn3KcoLFyqRPboHcT(v)tlljanLurOXU39Ucg0aNaA8LFOMaNmqOHMVUjnx4l7qbsvOhAozGqd(jGg7arn0QeiIkgxx)yBDAUCkrrJYeqH8unO43xhK1jv8eZ5plOzwjqevCUP8vU5e0kE71hOzBLpsvCT0JaLuwU5iv69OpROrzcOqEQgu87RdY6KkEI5IaAbc0UwrQIrq)vNW7iaVFzXboboHG(RoH3rawqxjqevC1figLKX)iEJan40JYgHo9IH4dKy0Gt5hgXxGqJ5SceODTIufJG(RoH3rGz5D2VS4aNaNqq)vNW7iWSSMf6zzolGc5PAZYMzzo7xhK1jvZYZSXCrmlRzznB0OZYCwafYt1MLnZYC2VoiRtQMLNzJ58FwwZYcn4utQd0Ogkgl04l)ozGqdl0XFumArQsVh9rxrZ0aNqHMNE3UCTStkIyaKjGdqH8uTzHYSq6Hg7E37kyqRLDsredGmbO1V6FAzjbOPKkcn(YputGtgi0qZjdeAw2jfrZcxMGzzcHfAWPhLncD6fdXhiXObNAsDGg1qXyHMVUjnx4l7qbsvOhA8LFNmqOHf6aROy0IuLEp6JUIMPboHcnp9UD56Eeagga6ZiKxGanoDb0y37ExbdAH8cO1V6FAzjbOPKkcn(YputGtgi0qZjdeA8ZlGgC6rzJqNEXq8bsmAWPMuhOrnumwO5RBsZf(YouGuf6HgF53jdeAyHo9bfJwKQ07rF0v0y37ExbdADjGu7K6ngExrO1V6FAzjbOPKkcn(YputGtgi0qZjdeAWobKANuVnRRxrOXoqudTq23mifbebJFqqdo9OSrOtVyi(ajgn4utQd0Ogkgl081nP5cFzhkqQc9qJV87KbcnSWcntG0U8DWYSoPcDGe7pwica]] )

    storeDefault( [[SimC Feral: ST generators]], 'actionLists', 20171112.121935, [[dae6oaqiQsAtufJsiDkHyvcvEfjQWTOkXUiQHPQCmv0YufEMkW0iH6AKqyBKqsFJezCKOQZrcPSosiY8uH6EKOSpjWbPsAHujEOe0ejrfDrHQ2ijKQtQc6MeXoPILQQ6PuMkrARQq2l4VKudwXHfTyO6XqzYcUmYMjjFwcnAj60eETqz2s62Q0Ur1VHmCvPJtcrTCuEoPMUuxNQA7KGVRkA8KqIZtLA9KOsZNQu7xPHtqkyXZt8kfaCWuojvPFTbxaZWyI3gmWCYlbMjUfUJIoXYQI0oM0DksCILnIPb7NQuQjW5X3PsNNNpK)o)((umy)ugClvCjWy0nfC9oEzNO7e8zzlq8DIBNp5d2jcyUI1cexdsbNtqkyXZt8kfaxaZWyI3gSoReVLXRiuOZkIRLjEIxPWoE2b3xLk5xgfYgXCRw)uOQ5Kwl7)UJNDW9vPsgVIqHoRiUwoGEY3XZoyOlos9lsWBTmMpJr8ENcu2op2XZoyiunGEYLtDzEtoPvRIrCLRBzgDtbxVZX7uelaMR4IQODdgJkYqp7sWoKheyzJyGXrCcmjOWrjZjVeyG5KxcSFQid9Slb7NQuQjW5X3PsNFG9tAKpdJ0GuObRWsclMeKc0L4nGdMeuWjVeyqdopaPGfppXRuaCbmdJjEBW6Ss8wgVIqHoRiUwM4jELc74zhCFvQKFzuiBeZTA9tHQMtATS)7oE2b3xLkz8kcf6SI4A5a6jFhp7GHU4i1VibV1Yy(mgX7Du2okEhp7eqTmlJrYm6McUENJ3rXG5kUOkA3GXOIm0ZUeSd5bbw2igyCeNatckCuYCYlbgyo5La7NkYqp7YDIEgbSFQsPMaNhFNkD(b2pPr(mmsdsHgScljSysqkqxI3aoysqbN8sGbn4CaifS45jELcGlGzymXBdgPi7lEFPGCkQ(mK6xKphJy6D8StNvI3Y4vek0zfX1YepXRuyhp7eDhCFvQKFzuiBeZTA9tHQMtATSUtSy7uWop2XBV3j6o4(Quj)YOq2iMB16NcvnN0AzDNyX2PGDo3XZobulZYyKmJUPGR354DoyNi7ezhp7G7RsLmEfHcDwrCTCa9KdMR4IQODdgJkYqp7sWoKheyzJyGXrCcmjOWrjZjVeyG5KxcSFQid9Sl3j6JiG9tvk1e4847uPZpW(jnYNHrAqk0GvyjHftcsb6s8gWbtck4KxcmObhfdsblEEIxPa4cyggt82GLyTqbsnXPRG07uWoNG5kUOkA3GHZ87SQwxtDjyhYdcSSrmW4iobMeu4OK5KxcmWCYlbMlm)oR7y1uxc2pvPutGZJVtLo)a7N0iFggPbPqdwHLewmjifOlXBahmjOGtEjWGgCueGuWINN4vkaUaMHXeVnyr3XR70cSycEXD827Dy0nfC9ohVtWNLTaX3jUD(KpyNi74zNO7KyTqbsnXPRG07uWop2jcyUIlQI2nyDjl1LGDipiWYgXaJJ4eysqHJsMtEjWa7zjX)Pm4gmngt82G5KxcmPLSuxc2pLb3sfxcmgDtbxVJx2j6obFw2ceFN425t(GDIa2pvPutGZJVtLo)a7N0iFggPbPqdwHLewmjifOlXBahmjOGtEjWGgCuubPGfppXRuaCbmdJjEBW86oTalMGxChV9ENO741D6Ss8wgVIqHoRiUwM4jELc74zhgDtbxVZX7e8zzlq8DIBNp5d2jYoE2PtwrQLBXLu3i1bbTtb7OyWEws8FkdUbtJXeVnyhYdcSSrmW4iobMR4IQODdglJrGjbfokzo5LadScljSysqkqxI3aoyo5La7pJrG5kROgSozfPwTqLY8AlWIj4f927OETZkXBz8kcf6SI4AzIN4vk4Hr3uW1hh8zzlq84(KpiINozfPwUfxsDJuheubkgSFQsPMaNhFNkD(b2pLb3sfxcmgDtbxVJx2j6obFw2ceFN425t(GDIa2pPr(mmsdsHgmjOGtEjWGgCucKcw88eVsbWfWmmM4TbRZkXBz8kcf6SI4AzIN4vkSJNDW9vPsgVIqHoRiUw2)Dhp7eDNO7WOBk46Dowz7O0or2XZoVetl0nXB1x)AlERcITtb7eqTmlJrYVx)AlERcITtC78jR8kIDISJND6KvKA5wCj1nsDqq7uWokgSNLe)NYGBW0ymXBd2H8GalBedmoItG5kUOkA3GXYyeysqHJsMtEjWaRWsclMeKc0L4nGdMtEjW(Zy0orpJaMRSIAW6KvKA1cvkRZkXBz8kcf6SI4AzIN4vk4b3xLkz8kcf6SI4Az)xprJYOBk46JvMsr88smTq3eVvF9RT4TkiwbbulZYyK871V2I3QGyX9jR8kIiE6KvKA5wCj1nsDqqfOyW(PkLAcCE8DQ05hy)ugClvCjWy0nfC9oEzhLa7N0iFggPbPqdMeuWjVeyqdokpifS45jELcGlGzymXBdw0DW9vPsUffjMwTkFMBz)3D8St0DIUZ5okh7Ctff1yLjRiP3Xl7GvMSIKwTkwI1cepR7ezN42HryLjRiPUfxANi7ebmxXfvr7gmCMFNv16AQlb7qEqGLnIbghXjWKGchLmN8sGbMtEjWCH53zDhRM6YDIEgbSFQsPMaNhFNkD(b2pPr(mmsdsHgScljSysqkqxI3aoysqbN8sGbn4OObsblEEIxPa4cyggt82GfDhVUtlWIj4f3XBV3Hr3uW17C8obFw2ceFN425t(GDISJNDIUJcjtK4vs2xtQ7swQl3rz78yhV9ENeRfkqQjoDfKENc25CNiG9SK4)ugCdMgJjEBWoKheyzJyGXrCcmjOWrjZjVeyG5kUOkA3G1LSuxcMtEjWKwYsD5orpJawHLewmjifOlXBahSFQsPMaNhFNkD(b2pLb3sfxcmgDtbxVJx2j6obFw2ceFN425t(GDIa2pPr(mmsdsHgmjOGtEjWGgCo)aPGfppXRuaCbmdJjEBWIUJx3PfyXe8I74T37WOBk46DoENGplBbIVtC78jFWor2XZokKmrIxjzFnPUlzPUChLTZ5oE2b3xLkzSkLmSu3cErz)xWEws8FkdUbtJXeVnyhYdcSSrmW4iobMeu4OK5KxcmWCfxufTBW6swQlbZjVeyslzPUCNOpIawHLewmjifOlXBahSFQsPMaNhFNkD(b2pLb3sfxcmgDtbxVJx2j6obFw2ceFN425t(GDIa2pPr(mmsdsHgmjOGtEjWGgCopbPGfppXRuaCbmdJjEBWsSwOaPM40vq6DkyNtWCfxufTBW0pfVeyhYdcSSrmW4iobMeu4OK5KxcmWCYlbM9u8sG9tvk1e4847uPZpW(jnYNHrAqk0GvyjHftcsb6s8gWbtck4KxcmObNZhGuWINN4vkaUaMR4IQODdMUKrbWoKheyzJyGXrCcmjOWrjZjVeyG5KxcmRKrbW(PkLAcCE8DQ05hy)Kg5ZWinifAWkSKWIjbPaDjEd4GjbfCYlbg0qdM9syISkuUzlqCW587aOba]] )

    storeDefault( [[IV Guardian: Single]], 'actionLists', 20171112.121935, [[dGZveaGErvTlHQxtvf2NqKztPBkK62cANkzVKDd1(HqJIQQYWG0VPYHvmuQQQgmcmCr5GuLofckhtPEoflKQyPcSyKSCu(gQ0tLwgcToeunrQQKPIQMmIMUkxKQYvfcCzW1rQZlu2kvvXMHOTlK4JuvPoTQ(SOY3fs6XI8xeKrdbttuLtIkEgvvPRrvfDpHqMNqqBtiQXjeQ1w8Q(WdLfifL6Acbvo(dIe430dJ8hmHJib9X5SGQFbihA7jpQbGfgdOfr0n39Etmo6gffnp1MbPFSF(Z9oSwB08u9MU3HnIxRT4v9HhklqkpQRjeuJadGibCoi0O2e7ZovvVuV9VyQ0gGq)bHgvoyYpnNJPIDyqnaSWyaTiIU5UrvdaJJMLaJ41PtlIIx1hEOSaP8OUMqqLhb2yqqTj2NDQQEPE7FXupeyJbbvoyYpnNJPIDyqnaSWyaTiIU5UrvdaJJMLaJ41Ptl)v8Q(WdLfiLh11ecQrp4CwqTj2NDQQEPE7FXudhColOYbt(P5CmvSddQbGfgdOfr0n3nQAayC0SeyeVoDALN4v9HhklqkpQRjeuJ25WiFgO2e7ZovkAKiJNBSt6(eHYrpmYFWXPZu9s92)IPg6CyKpdu5Gj)0CoMk2Hb1aWcJb0Ii6M7gvnamoAwcmIxNoT8tXR6dpuwGuEuxtiO6)02OaSpFqTj2NDQKafnsKXpeyJbbcrbdlU5MKFGibrcrc2QbGfgdOfr0n3nQkhm5NMZXuXomOgaghnlbgXRt1l1B)lMAgTnka7Zh0PvKfVQp8qzbs5rDnHGA0ohg5ZaejW)2eMAtSp7ujbkAKiJh6CyKpdIZGW5XMimIYLivdalmgqlIOBUBuvoyYpnNJPIDyqnamoAwcmIxNQxQ3(xm1qNdJ8zGoT4kEvF4HYcKYJ6Acb1OhARAtSp7uztoiEIMXa8fPiJQgawymGwer3C3OQCWKFAohtf7WGAayC0SeyeVovVuV9VyQHdTvNwrS4v9HhklqkpQRjeuBu)mqTj2NDQQbGfgdOfr0n3nQkhm5NMZXuXomOgaghnlbgXRt1l1B)lMQjQFgOtNAtSp7u1jb]] )

    storeDefault( [[IV Guardian: 2-3]], 'actionLists', 20171112.121935, [[dKdueaGErL2Lq51cc2NqKztv3ui1TPsxgStPSxYUHA)IkgLGOggKgNGsDyjdvqfdwiz4IYbPIoLGuoMu9CkTqQWsfyXiz5OCEHQNQSmeSobvAIckAQOQjJOPRYfrLUQGKEMqORJuNwvBvqHndrBxi4JckzEcc9zi47cQ6BOIhlYOHq)vuvNeHULGixtqI7jivttuLTje1VPy1fVgxCr5bsrP1kxqJyyKtuHfDXi)chU5efHqkIAHjGSO9NCOfaEOSGAeq7C69oHyODuu080wgK(Y)5w3BWQ1rZtZz6Ed2kE16IxJlUO8aPCOTe7ZonTw5cAHQfYjkIh4A1Cs9()IRrBH8)dCTAbG1qZsGv860capuwqncODoDunIyYpvNHPHnyqNAeeVgxCr5bs5qBj2NDAATYf04rKvwe1Cs9()IRDiYklIAbG1qZsGv860capuwqncODoDunIyYpvNHPHnyqNAru8ACXfLhiLdTLyF2PP1kxql6cJGh0Cs9()IR5wye8Gwayn0SeyfVoTaWdLfuJaANthvJiM8t1zyAydg0PwEIxJlUO8aPCOTe7ZonkAKiJHq5R09P8rGUyKFHJrNP1kxqlAJbJ8zGMtQ3)xCnxJbJ8zGwayn0SeyfVoTaWdLfuJaANthvJiM8t1zyAydg0PwOiEnU4IYdKYH2sSp70ibkAKiJDiYklI5tbflM9QuiePUwRCbTWH2hbG95cAoPE)FX1YO9rayFUGgrm5NQZW0WgmOfawdnlbwXRtla8qzb1iG250r1PwKfVgxCr5bs5qBj2NDAKafnsKXCngmYNbXyGB9yBig6iKi1ALlOfTXGr(miNOc5EOP5K69)fxZ1yWiFgOret(P6mmnSbdAbG1qZsGv860capuwqncODoDuDQXr8ACXfLhiLdTLyF2PXkeGyjAgdWxKImQwRCbTOlAVMtQ3)xCn3I2Rret(P6mmnSbdAbG1qZsGv860capuwqncODoDuDQf2IxJlUO8aPCOTe7ZonTw5cAl8FgO5K69)fxZg(pd0iIj)uDgMg2GbTaWAOzjWkEDAbGhklOgb0oNoQoDAlX(SttNea]] )

    storeDefault( [[IV Guardian: 4+]], 'actionLists', 20171112.121935, [[dqZrdaGEQkTlvkVwLk2NkvA2u5MqfDBvYof1Er7MW(PQyyq8BbdfsrdMK0WfXbPehtflKszPuLfdLLtXHL8uLLbjRtLQmrivAQKyYez6sDrkvVsLQ6YGRtupNuBfsjBMsA7qQ6JqQ4BKuFgQ03Hk8xrkNwvJMQQRksvNeQ6XcDniL68IKNjsLPrsSnifMhQWzxuyoqIyC56c4WJw(Ok6ixgPVe3Zhvv5(COlyTKDnTX5boO0aZOqoQpNdQBiheeev4wce)Y9(w9hemFquHZsS)GqtfMpuHZUOWCGeTXTO5tAoUCDbCPxd(Ok(gU0CwWE33P4K1qAFdxAopqhKnrqtf2CEGdknWmkKJ6dchEH0hRoy4ebbWMzuuHZUOWCGeTXTO5tAoUCDbCk(nL2pNfS39DkU2VP0(58aDq2ebnvyZ5boO0aZOqoQpiC4fsFS6GHteeaBMthv4SlkmhirBClA(KMJlxxaholbUoGZc27(of3vjW1bCEGoiBIGMkS58ahuAGzuih1heo8cPpwDWWjccGnZQqfo7IcZbs0g3IMpP5WKTA9gULRI9htdx5Yi9L4MCcxUUaoCgccRVb4SG9UVtXDfccRVb48aDq2ebnvyZ5boO0aZOqoQpiC4fsFS6GHteeaBMrBQWzxuyoqI24w08jnNeGjB16T2VP0(tddkZnDxX7C3dxUUao0u2HEW8(cCwWE33P4sKDOhmVVahEH0hRoy4ebbW5b6GSjcAQWMZdCqPbMrHCuFqyZmAqfo7IcZbs0g3IMpP54Y1fWnC8jaNfS39Dkono(eGdVq6JvhmCIGa48aDq2ebnvyZ5boO0aZOqoQpiSzZTO5tAo2Ka]] )

    storeDefault( [[IV Guardian: Default]], 'actionLists', 20171112.121935, [[dmdldaGEqsTjvq2fbAFGuMnj3uf42OQDcyVIDRQ9lLHHk)MQgSunCQWbvHogqlKGwQk1IPslNONlPNcTmqSouuteKQPsOjdQPR0fvrEfkWLrUUe2iiHTIsSzvsBhf5JOqhMY0OIMhirFtL48OK(SkQhtQtIsDluqNwX9ub1ZiGVdsYFLOdyedE6nxfbh3GagpfKnlToJfMeESN5wh60vRqTbHoD1kuBeg8MuKvPaaHd8ciiieb5a544CgeDq6XuduB74)aaY5m4r9o(VgXaagXGNEZvrWryqaJNckKmzRdfEjFqulhhBq3IRxf0Lmz5vVKxqypu9bp6oQzzn48At(2o(pi7hE026LbF)tbVjfzvkaq4aVaYf8MQ(cPMQrmB2aajIbp9MRIGJWGOwoo2GMEhMOs6j(HQT(HBDWGagpfeN)SIADrtEM2GSF4rBRxg89pf8MuKvPaaHd8cixWBQ6lKAQgXSbp6oQzznOS4ln9o(Vun1n4bEyaJNcYMLwNXctcp2ZCRJZFwrzdGarm4P3CveCege1YXXg007WevspXpuT1HwRd26hQ1n9omrL0t8dvBDOS1DgeW4PGqyOaTUOjptBni7hE026LbF)tbVjfzvkaq4aVaYf8MQ(cPMQrmBWJUJAwwdQnLQ0074)s1u3Gh4HbmEkiBwADglmj8ypZToegkq2a4mIbp9MRIGJWGOwoo2GMEhMOs6j(HQTo0ADbccy8uqNmO1fn5zARbz)WJ2wVm47Fk4nPiRsbach4fqUG3u1xi1unIzdE0DuZYAqTPuLMEh)xQM6g8apmGXtbzZsRZyHjHh7zU1DYGSzdIA54ydMnb]] )

    storeDefault( [[IV Feral: Single]], 'actionLists', 20171112.121935, [[dautjaqibL6scsytKK(KGIgfvuNsqSkbv9kbLClbf2fjgMcDmbwgQ0Zqf10uQIRPa2MGK6BkOXjifNtqkTobPQ5HkY9euP9PaDqOKfQu5IOcBKKOtcLAMcsLBkOIDsLwQI6PuMQsARcsYEv9xOyWqoSKfdvpwOjtWLr2SI8zsQrRuonWRvQsZMQUTsSBu(nrdNqhxqIwUONtQPl11rvBNKW3vQkNNkSELQQ5tfz)G(bF9ghSc3tch)MftGyF7Mjsrq5b7VAGKD3GroFBM8uPP7YDmyyqqaxLGBZuj4yfSq3CgI4QmCaikmGO4wLQjnMPSInqYkpefcefEikP4wLQPByfBGKP)6Dd(6noyfUNe(UBU1cDZkvuQjiAww5nSzcGy1Y8gtYOByHd8G2XnDPIsnHjLvEBM0s(ms6V((2m5Pst3L7yWWGXBwmbI9TKMssVv4E69D5(1BCWkCpj8D3CRf62CTx6g2mbqSAzEJjz0nSWbEq74ww7LUntAjFgj9xFFBM8uPP7YDmyyW4nlMaX(wstjP3kCpbro5eejiBLS2lPiUW7BGOhqjeXjisKsnq3eRXSW7BGOhq577Y5VEJdwH7jHV7MBTq3MbI3WMjaIvlZBmjJUHfoWdAh3sG4Tzsl5ZiP)67BZKNknDxUJbddgVzXei23IYfCjgrjG1ALiFMeRHObHO9arQcrodrHne1LNyTIUWPSLYEtHyfUNeGiNCcI6kvtTYgv(EdJySHObdxiI7aquiqKQquxPAQvAWcHPLyeaeeniejq48ttkjqurGpRgizquOaI4mePke5meL0us6Tc3tqKtobrcYwjbIkIl8(gi6bucrCcIePud0nXAml8(gi6bucrH8(U75R34Gv4Es47U5wl0nvsPmcK8AiAhOPByZeaXQL5nMKr3Wch4bTJBtukJajVgdoOPBZKwYNrs)133MjpvA6UChdggmEZIjqSVfLl4smIsaR1kr(mjwdrdcr7bIufICgI6YtSwrx4u2szVPqSc3tcqKtobrDLQPwzJkFVHrm2qeNGiUdarH8(Ud81BCWkCpj8D3CRf6w4iLSjqs3WMjaIvlZBmjJUHfoWdAh3wKs2eiPBZKwYNrs)133MjpvA6UChdggmEZIjqSV1LNyTINNvjgatlcYQbsMcXkCpjarQcrjnLKERW9077gQ)6noyfUNe(UBU1cDBDll9ge5COJFAQc5g2mbqSAzEJjz0nSWbEq74wVLLE72mPL8zK0F99TzYtLMUl3XGHbJ3Syce7B48ttkrpvzS0nGPwHxeIufIOqjpquKeu88ttfM9LLOiGPwdrQcrjnLKERW9077o8R34Gv4Es47U5wl0TvGAkdtnePs(0XnSzcGy1Y8gtYOByHd8G2XTgOMsnMj(0XTzsl5ZiP)67BZKNknDxUJbddgVzXei23igLQDOe5ZKyneXPWfI4o((UHMVEJdwH7jHV72mPL8zK0F99nlMaX(go)0KsdutPgZeF6qHx8g2mbqSAzEJjz0TzYtLMUl3XGHbJ3Sn5(chPaycqP(43Wch4bTJBLERwkgPXmLeB)oU5wl0nS0B1sXOWudrQmj2(D8(UH2VEJdwH7jHV7MftGyFlUvPAsJzkRydKSYdrdcrCvgoaePkefLl4smIsaR1kr(mjwdrCcIg4gw4apODCdp57YJr7l92nSzcGy1Y8gtYOBU1cDBxY3LhImFP3UntEQ00D5ogmmy82mPL8zK0F99TzQeCScwOBodrCvgoaefgquCRs1KgZuwXgizLhIcbIcpeLuCRs10T9TrSzQeCCthtGy)(UbJF9ghSc3tcF3n3AHUzBjjCdBMaiwTmVXKm6gw4apODCtVLKWTzsl5ZiP)67BZKNknDxUJbddgVzXei23IYfCjgrjG1ALiFMeRHiobrd8(UbbF9ghSc3tcF3n3AHUPskLrGKxdr7anbroZnKByZeaXQL5nMKr3Wch4bTJBtukJajVgdoOPBZKwYNrs)133MjpvA6UChdggmEZIjqSVfLl4smIsaR1kr(mjwdrdcr7bIufICgIeKTscevsAPamneniejiBLeiQiWNvdKmik8q0OcNHOWcIcgHOqGivHiNHOWgI6YtSwrxQOutyszLkeRW9Kae5Ktqeo)0KIUurPMWKYkvsAPamnenieHZpnPOlvuQjmPSsfb(SAGKbrHhIgv4mefwquWiefY733CRf6g2HkisLuw(qpezaMAp9(h]] )

    storeDefault( [[IV Feral: Opener]], 'actionLists', 20171112.121935, [[d4ZDhaGEjfTjsQAxOOTrIu2hjkonKBljZwK5tIQUjjcUmY3iHZRkTtOAVu7wL9RQ(PKQYWev)MWZjAOKiPbdLHtQoOO4usk1XqPZrIuTqHQLsklgvwUIhsIOEkyzOW6KuvnosezQczYOQPR0fLihwQNjPKRlHnssPTsIqBwOSDjv5Xc(UQitJevMhjv(ljzvKuy0suFwv4KIs3IKIUMKk3Jej(ejknkjfETQO2SoYqPR5seV5maHbPVgma6ua1jun7fjoJZMxldAuIAjzCg5SkyzzzWK1Gg18VrOkYqn(ymyQOUpMA(XcL75bjvfB6WIexN(y1(JPgFSHcL75bzityrIt6iJZ6idLUMlr8oUbimi91Gb8UImOuhXtjdz4qj0(AqFepLmOrsrXeiPJ8AqJsuljJZiNvbBUHShpk0RymCIJ8ACgoYqPR5seVJBacdsFnyaVRidk5E)yQvmvgYWHsO91qOxvXetLbnskkMajDKxdAuIAjzCg5SkyZnK94rHEfJHtCKxJxlhzO01CjI3XnG3vKbT(zYq2Jhf6vmgoXrgYWHsO91W0ptg0iPOycK0rEnOrjQLKXzKZQGn3aegK(AGxSmN(zIjV4PZRXvohzO01CjI3XnG3vKbORx)G(yAIEmK94rHEfJHtCKHmCOeAFni761pivJOhdAKuumbs6iVg0Oe1sY4mYzvWMBacdsFnWvelgtzxV(bPAe9WKx8051415idLUMlr8oUb8UImeNgjnpBi7XJc9kgdN4idz4qj0(AGJgjnpBqJKIIjqsh51GgLOwsgNroRc2Cdqyq6RbVgxP5idLUMlr8oUb8UImK9c9C9IeNHShpk0RymCIJmKHdLq7Rb0f656fjodAKuumbs6iVg0Oe1sY4mYzvWMBacdsFn414kCKHsxZLiEh3aExrgIqpOrzLFm1wmVgYE8OqVIXWjoYqgoucTVgw0dAKQIvmVg0iPOycK0rEnOrjQLKXzKZQGn3aegK(AWRXvsoYqPR5seVJBaVRidzKL7Q(iLv(Xu7qxnFnK94rHEfJHtCKHmCOeAFn0YYDvFKuvSHUA(AqJKIIjqsh51GgLOwsgNroRc2Cdqyq6RbUIyXyUOh0ivfRyEzwO)Xu)hliQ4eQ0fOBLmdfZq3(Xu3hRwEnUs3rgkDnxI4DCd4Dfzqjiexm0qgYE8OqVIXWjoYqgoucTVgQeIlgAidAKuumbs6iVg0Oe1sY4mYzvWMBacdsFnSDIULzQ46rf6K6OPxK4ysxZLi(pM6)ybrfNqLUaDRKzOyg62pM6(y1514S5oYqPR5seVJBacdsFnek3ZdsQk20HfjUo9XugLYhJbtf1zidhkH2xdCtX2jvYullBi7XJc9kgdN4id4Dfzi(uSD6JbPww2GgLOwsgNroRc2CdAuZ)gHQid14JXGPI6(yQ5hluUNhKuvSPdlsCD6Jv7pMA8XgkuUNhKHNktNg18VgKHbPVg0iPOycK0rE9ACwwhzO01CjI3XnG3vKbO8q8gYE8OqVIXWjoYqgoucTVgKLhI3GgjfftGKoYRbnkrTKmoJCwfS5gGWG0xdbrfNqLUaDRKzOyg62pM6(y1514SmCKHsxZLiEh3aExrg0q6gYE8OqVIXWjoYqgoucTVggKUbnskkMajDKxdAuIAjzCg5SkyZnaHbPVgcIkoHkDb6wjZqXm0TFmL5JPCFm1)XQXhBOydjl3Cj6JP8k)hJxSmhKot9QI0I0tiA(yQ7JPtJejx6wvvfPfPNq08XQTxVgW7kYqwL4htT00P6)JvF60rJxBa]] )

    storeDefault( [[IV Feral: AOE]], 'actionLists', 20171112.121935, [[da0QiaqiIQYLuvOnPQYOOIofvYQiQsVsjPBPQi7sfnmI4yQWYuPEgkyAQkQRruzBejvFtj14iQcNtvjToIQO5PQQUNQsTpIuhefAHeLhQQexevyJevvNevQBQQk7uO(jrsSuvXtjnvLyRejP9c(RkzWkoSulgv9ybtgLUm0MrrFMk1OPWPr8AIeZwPUnfTBk9BQA4QslhPNty6IUUq2oQKVRKy8Qk48uH1tKuMpQO9lz4awaLdBZVrwGhunqjVjOGQVyG0BIuRtI3cXhsya0hCJTaH4BjhRpooUppa9bBwhleteukgmAQBSg5TgN1CFUwUA(unbJM6gfxmPDijEBVRXfOmgsI3kGfi(awaLdBZVrwqgO)1FGygzU0u3ykaLbq1aL8MGMn1nMNjXeVs)flbRr6VRHf5JyY8KsEpzJODs82A(ynmuZVAcEtE)1RNytXziIsrBwZ31ixn)QXznYxnzVrBEkAEKMEFACI2MFJS1WjN1Kn1nMNgyVtJR3qwJ0FxZTC14QMF1qrMuuy08Beug5jBs6auk5fuUTSKqNEkOwVfbnUnrqFiV148RR6c0V4iSXLM6gtbid0hCJTaH4BjhRpKaQA4x5pplHjbPcqgOpOWhrdOawGesi(gwaLdBZVrwqgOXTjcQ8JuFG4Je1iJKyno)6QUaLBllj0PNcQ1BrqzKNSjPdqzIuFG4Jex8Keb9bf(iAafWcKG(GBSfieFl5y9Heq1aL8MGg8M8(RxpXMIZqeLI2SMVRrUA(vJZAYM6gZZKyIxP)ILG18FnSiFetMNuY7jBeTtI3wZhRHHA4KZACwdlYhXK5jL8Eg9wZVACwt2B0MNIMhPP3NgNOT53iBnCYznztDJ5Pb27046nK18Fn3YvJRACvdNCwJ8vdlYhXK5jL8EsrMuuy08BSgxqcXmalGYHT53ilid0)6pqmJmxAQBmfGYaOAGsEtq7qs4cVqlAsqrnsxZrn)QPdjHl8cTOjbf18FnFUMF1qrMuuy08Beug5jBs6auAlfeuUTSKqNEkOwVfbnUnrqFAPG148(tm4c0V4iSXLM6gtbid0hCJTaH4BjhRpKaQA4x5pplHjbPcqgOpOWhrdOawGe0vmq7d2SoaTJspKq8NHfq5W28BKfKbACBIGUyqBHrnoVx1fOCBzjHo9uqTElckJ8KnjDaAAqBHbOpOWhrdOawGe0hCJTaH4BjhRpKaQgOK3e0oKeUWl0IMeuuJ01CuZVACwthscx4fRpptdAlmQ5)A6qs4cVqlAsqrnCYznuKjffgn)gRXfKqSCWcOCyB(nYcYavduYBcAhscx4fArtckQ57AUR5xnbJM6gfxmPDijEBVRr6AUpxlhOmYt2K0bO80OS3xIDlmaLBllj0PNcQ1BrqJBteuz0OS31O7wyuJZ7vDb6dUXwGq8TKJ1hsa9bf(iAafWcKG(GnRJfIjckfdgn1nwJ8wJZAUpxlxnFQMGrtDJIlM0oKeVT314c0vmq7d2SoaveOK3esiwQdlGYHT53ilid042ebvnOiBnoVDbk3wwsOtpfuR3IGYipztshGkmOilOpOWhrdOawGe0hCJTaH4BjhRpKaQgOK3e0oKeUWl0IMeuuZ31CxZVAcEtE)1RNytXziIsrBwZ)1ihKq8AybuoSn)gzbzG(x)bIzK5stDJPaugavduYBcAhscx4fArtckQr6AyOMF1Kn1nMNjXeVs)flbRr6Ayr(iMmpPTuWt2iANeVTMpwZDn)QHImPOWO53iOmYt2K0bO0wkiOCBzjHo9uqTElcACBIG(0sbRX5Nx1fOFXryJln1nMcqgOp4gBbcX3sowFibu1WVYFEwctcsfGmqFqHpIgqbSajKqS8awaLdBZVrwqgOXTjcQmAu27A0DlmQXjdR6cuUTSKqNEkOwVfbLrEYMKoaLNgL9(sSBHbOpOWhrdOawGe0hCJTaH4BjhRpKaQgOK3e0oKeUWl0IMeuuJ01Cdje)vybuoSn)gzbzGg3MiO6kKxSgNmSQlq52YscD6PGA9weug5jBs6auXkKxe0hu4JObualqc6dUXwGq8TKJ1hsavduYBcAhscx4fArtckQr6AUHesqJBteuULQ1i)iT3YZAyuQWbKaa]] )

    storeDefault( [[IV Feral: Cooldowns]], 'actionLists', 20171112.121935, [[duJIdaGEuvQDjuVMuO9bkYSf18fiFcuu3wLSta7LA3QA)OYWeYVrzOOQWGHYWvPoOeCmqwOizPs0IHQLR0drvjpfzzKspNKhlPPkIjd00L6IsORckXLjUUk2iQQAROQOntQomKVjs9mqHPbkPVtk60kMhPG)cQwhOuDsbCluv5AcuoVG(mQY2eO6MGszd5etfFeEwanUja0LykaFYHXFzrzyNdJVySmitZxzQuYcsjgqBeuAiiiTXqMOBPoO8W3OEyVbGIGHPc1EyVYjgaYjMk(i8Sa6uMaqxIPaFfTpQh2BkWdovuZwtp7ftfWN80HMMVI2h1d7nvkk2zRIYjUnvkzbPedOncknuKjQUZDBQYyzqMMFCp8Kvbx)SHXRCHMxXHPbomyeXHXpom8JUECp8Kvbx)SHXGNf1d75Wckiom8JUECp8Kvbx)SHXNB3gqRtmv8r4zb0PmbGUetPKvjRgnf4bNkQzRPN9IPc4tE6qt4YQKvJMkff7Svr5e3MkLSGuIb0gbLgkYev35UnvzSmitZpUhEYQGRF2W4vUqZR4W0ahguW4W4hhg(rxpUhEYQGRF2WyWZI6H9Cybfehg(rxpUhEYQGRF2W4ZTBdadNyQ4JWZcOtzcaDjMsgEYcZkom(F2qtbEWPIA2A6zVyQa(KNo0up8Kvbx)SHMkff7Svr5e3MkLSGuIb0gbLgkYev35UnjVS8cJbf9PonhgmXHf8i3gawDIPIpcplGoLjQUZDBYea6smXhSEyVPap4urnBn9SxmvkzbPedOncknuKPsrXoBvuoXTPc4tE6qt3SEyVjyJbcGUetSmiCnrRBdemNyQ4JWZcOtzcaDjMGffcplCybA5szkWdovuZwtp7ftfWN80HMokb(0YLYuPOyNTkkN42uPKfKsmG2iO0qrMO6o3Tj3Unr1DUBtUTb]] )

    storeDefault( [[IV Feral: Precombat]], 'actionLists', 20171112.121935, [[d4cbcaGEkI2eOu7cu9AqjZgYnPq62a1ov0Ej7gQ9dOHrv(TudfadgidxKoiL4yIAHa0sPslwHLJQNQ6Xs65smvQyYGmDHlsPCzKRtvzJuv1wPqSzkkFMQkFNcoSsFJs1OPOADuOCskPNrr60OCEqXYeX8Oq1FPiSYYr3gEhicsd95cM0TAeGG8N4lYyabbaNQn4Xg6UeI2cPzIx2EoNtGN1FkvzlIzYnynwZSNP6wQbRXf5Ozwo62W7arqcq95cM0Dj)4THWCDRyiwDJMRJBmPBzWqSagDo5hVneMR7sL2hVsf5Oq3Lq0wint8Y2ZE6VYzPHESichWhOUHIf14cCcVdebbeeSbcA4ZmZGpqDdflQXf4LyRWciiJdeuIcntKJUn8oqeKau)voln01NlyshGoynw3kgIv3O564gt6UeI2cPzIx2E2t3LkTpELkYrHULbdXcy0t7G1yDJ2qZfmP3iityy5k00u5OBdVdebja1NlyshaEBaPBfdXQB0CDCJjDldgIfWONYBdiDxQ0(4vQihf6UeI2cPzIx2E2t)voln0vOq)voln0vib]] )

    storeDefault( [[IV Feral: Default]], 'actionLists', 20171112.121935, [[dWJUeaGEjKAtQs1UuK2MKs2NKQMnrZxsPUjuvhwLBljFtvYoHYEf7MW(P4NsQmmf63qwhjv3trKbtQHJchucofjrDmu60kTqQKLQkwSeTCu9qfHvrsKLrfEovnrjeMQcMSQA6sDrQuptcvxg56KOncvzRKu2muX2vLYNrrFscrttsHVdv6Xu6VkQrtsAEsOCss4wkI6AKeopv0tbVwsrJscjh2meWT4kL0pLbWUkkGc1mA8i(jv3OlccNtPSd8qs68uWCmY(ILL1Xu2aadYUNCl6RxKiySJfpqbBViHpdbJndbClUsj9JRaGLVm6a9wrgDXmAwvy0VB0FupLVmM(r4km63n6(4mPEAVv0CJM)lz01pjJMvfg9Kn6EROafkx52odWvkMpBViXSC9DafI)AVgXdiqcka2vrbQJbjiEa8rFSRIcOqnJgpIFs1n66yqcIh4HK05PG5yK9f7yGhYJuYTKpdPdaQIWfF0FXzjUpUcanFT9eQs2AMY0bZrgc4wCLs6hxbalFz0bAetMsAQfHKFeUcFaSRIcmbcj)iCf(ake)1EnIhqGeuGhssNNcMJr2xSJbEipsj3s(mKoqHYvUTZa2tkNpBViXSC9Da8rFSRIcOqnJgpIFs1n6jqi5hHRWNoyfpdbClUsj9JRayxffyyzs8I0B04PK7mGcXFTxJ4beibfOq5k32zGEzsC)mok5od8qEKsUL8ziDGhssNNcMJr2xSJbalFz0bibXz6C6NWzTBB01pjJUwJPdwnYqa3IRus)4ka2vrbG7TJjz0pOJhqH4V2Rr8acKGcuOCLB7mG)E7ysZC0Xd8qEKsUL8ziDGhssNNcMJr2xSJbalFz0b4u1TcVrxmJ2HrRsgnt73ORDTn6IYO5eoCYR6vkjJ(DJ2IQkrZmqRO9tTk5Cs0gD9gDnmAvoDWurgc4wCLs6hxbalFz0boBVVrZKGQwYB01B0SbkuUYTDgWEs58z7fjMLRVdOq8x71iEabsqbWUkkqH6ChaF0h7QOakuZOXJ4NuDJUqDUd8qs68uWCmY(IDmWd5rk5wYNH0bavr4Ip6V4Se3hxbGMV2EcvjBnJR0bRwziGBXvkPFCfaS8Lrhia2vrbGvWusg9WXzsDafI)AVgXdiqckWdjPZtbZXi7l2XapKhPKBjFgshOq5k32za7jLZNTxKywU(oa(Op2vrbuOMrJhXpP6gnScMskD6aGLVm6aPta]] )


    storeDefault( [[Feral Primary]], 'displays', 20171112.121935, [[dOJYgaGEf4Lij2Luc9APKMPukZwQUjuvDBvXJrXoPYEf7MW(jIFQOgMI8BihJunuKAWOsdhHdsvnnKKoSKJJkSqPyPOIwmrTCsEOc6PGLbv55uAIiPAQQQjtKMUsxuHUkuvUSkxhrBekTvOaBgvTDK4JsP6zsj6ZqLVtvgjskNMIrJsJhk6KQs3ckKRjLGZtkRdkuRfkiFdkOo65hGPiwdsGfjwy16xGz89B71ngGPiwdsGfjwWm4IthVaQsG7gYEmTMMaCqEKNF3Gt8CInataTzEE7TdlI1Ge24McG5mpV92HfXAqcBCtbiuMNsP9YGeGzWfhvNc8ye(JX1YaCqEKN0HfXAqcBAcOnZZBV9xkC3AJBkGLf5bEMLH1FmnbWCMN3E7Vu4U1g3uaddsaefJrGlUwiWwkC36lyyrQanZ))m(58TDQ9dOfhgHxlNcGzCtbSSiVFPWDRnnbAv2xWWIub(Z0C(2o1(bmcPgMArkFbdlsfGZ32P2patrSgKWxWWIubAM))z8haiogt1ndQ1GeXPp1YawwKh8ttaoipYJ6g1XSgKiaNVTtTFab5ZldsyJJQbSexVJTxw2HOosLFGko9aYXPhaxC6buXPNnGLf5nSiwdsyJCamN55T36tQQ4McuKQ6RrCbKj55d8uy6tUO4Mci3ndg0Eh5537roq1jylGf5rtzmo9avNGTgIEKRLMYyC6bO(XxK9nnbQUxPzPPqNMaumwJSPBwTVgXfqoatrSgKWVBWjcmC09h5mGuJLOxAFnIlqfqvcC3xJ4cuYMUz1cuKQc)gXLMaTkJfjwWm4IthVavNGT(Lc3T0uOJtpG66bgo6(JCgWsC9o2EzzJCGQtWw)sH7wAkJXPhGdYJ8K(kKAyQfPSPjWqeHMeUFuaSNQ6s46ppgq6XxK91NUTaVyGeUypv1XyjCP(XxK9nWwkC3Ifjwy16xGz89B71ngGhj2a0FjCHsyLW1vkfYlqrQQxbp6RrCbKj55dyzrE(KlknbQobB539knlnf640dyyqcmec9eNEleGqzEkLgwKybZGloD8cqOog0JCT(0Tf4fdKWf7PQoglHlT6yqpY1gWYI88jv1RGhf5apfM(JXnfGdYJ8K(YGeGzWfhvNcSLc3T0ugJCa5UzWG27iVihWYI8OPqNMamOh5APPmg5aBPWDlnf6ihqBMN3E7RqQHPwKYg3uaTzEE7T(KQkUPayoZZBV9vi1WulszJBkGLf59kKAyQfPSPjWJr4tUO4McuDVsZstzmnbSSipAkJPjGLf55pMMamOh5APPqh5afPQaIR3FPECtb2sH7wSiXgG(lHlucReUUsPqEbAvglsSWQ1VaZ4732RBmWJra)4McSLc3TyrIfmdU40Xlq1jyl)UxPzPPmgNEaMIynibwKydq)LWfkHvcxxPuiVavNGTgIEKRLMcDC6bgfLC)KMMawZdr)8NhJdVaCqAyAfdmwy16xGkqRYyrIna9xcxOewjCDLsH8cyzrEGNzzy9jxuAcuKQYxWWIubAM))z832i2FaoV(v2lo8M0XW66641It6tttunGLf5rLtt2iKAe4SPjG2mpV9wQ0yJdJ0d8uyc)40duDc2cyrE0uOJtpahKh5jflsSGzWfNoEbWCMN3ElvASXPhGdYJ8KsLgBAc4QNla2tvDjCPvMNsPfOivf(eMnarV0ov2ea]] )

    storeDefault( [[Guardian Primary]], 'displays', 20171112.121935, [[dOtOgaGEjPxIq1UGQIETKOzkLy2s1nrcDBqCyQ2jf7vSBuTFfYpvKHPO(nK1bvfgkkgSuQHJOdkfpdQQ6yK0XrsTqj1sLewmjwoLEOc1tv9yu65KAIibtfutMatxPlQGRIq6YaxhkBKG2kcrBMqBhbFejAzijttkPVlrJeHYPjA0i14HQCsOYTGQkxdHW5LWNbP1cvL8nOQuh1aNZ6KReXfI473IoiFIOWTGZmKVUfkyziWeLCRZHcgtdyRm15uJbWanDjuoeaFZzZlMef1GDStUsexhZCoEtIIAWo2jxjIRJzoNAmagqaowe)YQGyADohIK3med(NtngadiyStUsexN68IjrrnyHDluWQJzoxtJkFPCzPBgsDoEtIIAWc7wOGvhZCUMgv(s5Ys3GTOuNVUfkyB4S0iBE9em8efRahLedohVjrrnyjETog18IjrrnyjETog8tnxtJkHDluWQtDELknCwAKnhEIPcCusm4CjxGK1xKTHZsJS5vGJsIbNZ6KReXB4S0iBE9em8efZpjGv6DzvFLiEmQZTMRPrLho15uJbWauqAbSReXZRahLedoNJbbhlIRJP1CnjO3f2Dn9yuhzdCUhJAUsmQ5qJrn3gJA2CnnQCStUsexhLC8Mef1GTbZ6XmN7ywhUGeKRGjkMdXXRbBrXmNR0LvRszhv207rj37K0(PrLmegIrn37K0(yeefFzimeJAofaIowFJsU3l9cndbMuNtqQLkYUClGlib5k5So5kr8MUekpF8GbEOICbsnz3lGlib5EU15qbWfKGCxr2LBrUJzDkk5GuNxPIqeFVSkigvQY9ojTd7wOGLHatmQ5wqpF8GbEOICnjO3f2DnDuY9ojTd7wOGLHWqmQ5uJbWacWXfiz9fz1Po34qa5uI5wbsNpQnJvcXTf5RBHcwHi((TOdYNikCl4md5kDz1Qu2rLrjhVyMZ10OYgmRJJlIIsU3jP9MEPxOziWeJAoehVdhJAoPvcXTfcr89YQGyuPkN0cyrqu8THPLyMZLSio(cHGeJkrKdXXRziM5ChZ644Ii4csqUcMOy(6wOGLHWquYlIb)Oc)NZ10OsIdkuKCbsouDQZfr8nNbEu77C9O2g3ArL5Siik(Yqyik5ftIIAWIJlqY6lYQJzoVysuud2gmRhZCoEtIIAWIJlqY6lYQJzoxtJkXXfiz9fz1PohIK3GTOyMZ9EPxOzimK6CnnQKHWqQZ10OYMHuNZIGO4ldbMOKVUfkyfI4Bod8O2356rTnU1IkZDmRFsqVJJcXmNxPIqeF)w0b5tefUfCMHCis(HJzoFDluWkeX3lRcIrLQCVts7n9sVqZqyig1CwNCLiUqeFZzGh1(oxpQTXTwuzU3jP9Xiik(YqGjg18bUR0bcsDUwcHSdAMgIHQCQXKSvsKs93Ioi3ZRuriIV5mWJAFNRh124wlQmxYI4N0zLCOXqe5So5krCHi(EzvqmQuL7ywVHZsJS51tWWtuSLbHW5AAujdbMuNxbOdCnigQMvX3QQZTIpvZjTsiUTahlIFzvqmToN7DsA)0OsgcmXOMtngadiqiIVxwfeJkv5AAuzd2IsDo1yamGaIxRtDUaGOJ13gMwYXrKJAtjMBfiDo(yuBkaeDS(M7ywNOC5Mt29cGnBc]] )

    storeDefault( [[Feral AOE]], 'displays', 20171112.121935, [[d0JYgaGEPuVefYUGGyBqqzMsjEmsnBP64OkUjkOPrvu3wrEneyNuzVIDt0(rv9tfAyq0Vv1PjzOOYGjOHdvhKQ6YQCms5COaSqf1sPkSyKSCk9qQspfSmuuRdfOjsvKPcPjtGPR0fvWvrvYZqH66iAJqXwrb0Mj02rWhLsACOkvFgk9DPyKOi9CkgnknEi0jrOBHQuUgkIZtQoSK1cbPVbbvhTGgGUWx1lX8Yfw9(fyKxOTq0neGUWx1lX8YfuTV40yoGTKypVShncYCaEipYZVRWkNo5gGoG(OOO5wVf(QEPjoKbqCuu0CR3cFvV0ehYa4w1uz1js)sq1(IZZidmPK(dXX4a8qEKNaVf(QEPjZb0hffn3IwwS3AIdzad73anQLM1FiubmSFJp5(HkGI(LaErRKyJJjbksBruk(O64xaksrXa6XXBA8otcGyCidyy)g0YI9wtMdGakFjn7BdGoY5bXwzkAaLuGIU236lPzFBapi2ktrdqx4R6L(sA23gyEefDKHb8(468fI(bWC2QZxO)4qad73aOzoapKh55jL9Ox1ld4bXwzkAaj5er6xAIZZbm4xVJPxgwVF)TbnqfNwaBCAbWgNwaQ40YgWW(nEl8v9stOcG4OOO5wFsBfhYafPTq1XVauKIIbMke9j3poKbO6Q2TBT)n(9EOcuDC2cy)gocdXPfO64SL3FIQwocdXPfWtNyr23qfO6nLUHJaxMdqqzuuQUA1r1XVaubOl8v9s)UcRmG3bh6GhbeOm49shvh)cqhWwsShQo(fOOuD1QhOiTfdvYlZbqafMxUGQ9fNgZbQooBHwwS3YrGloTa2RhW7GdDWJag8R3X0ldBOcuDC2cTSyVLJWqCAb4H8ipbeLcu01(wtMda4hTQ6Q21QEzCAizCaxnDbWC2QZxO)4qGTSyVfZlxy17xGrEH2cr3qaehffn3YOztCAbqCuu0ClAzXERjoKbmSFJpPTikf)qfO64SLFVP0nCe4Itlq1XzlG9B4iWfNwaCRAQS6yE5cQ2xCAmha3E0)evT(CTeautE5leZzRodYxiU9O)jQAdOpkkAULrZM44nTatfI(dXHmWuHiGgNwGTSyVLJWqOcyy)ggD6ukPaLeRjZbmSFdhbUmhWJRFL5IJzKAiCnnKmbHWmJ1qymMbeOiTLVKM9TbMhrrhzyldyqdyy)gOrT0S(K7N5aiGcZl3aCO8fcL0WxORS2VjapKkAeWavgy17xaQag2VHOuGIU23AYCGjL0NC)4qgO6nLUHJWqMdyy)g)HqfWW(nCegYCa6FIQwocCHkq1XzlV)evTCe4ItlWwwS3I5LBaou(cHsA4l0vw73eO64SLFVP0nCegItlWKscOXHmWwwS3I5LlOAFXPXCaeqH5LlS69lWiVqBHOBiaDHVQxI5LBaou(cHsA4l0vw73eOiTfGF9orpfhYadYIQFcYCaJAcVF(JdXXCaehffn3sukqrx7BnXHmG(OOO5wFsBfhYa6JIIMBjkfOOR9TM4qgyll2B5iWfQa0)evTCegcvaQUQD7w7FtOcWd5rEcis)sq1(IZZidi(YnahkFHqjn8f6kR9BcOOFjc9)P40ysaEipYtaMxUGQ9fNgZb2YI9wFjn7BdmpIIoYqpi2ktrdWd5rEcy0SjZbeCIfzF95AjaOM8YxiMZwDgKVqbNyr23afPT4LuTbW7L(zZMaa]] )


end

