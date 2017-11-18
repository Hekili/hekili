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
        addAura( "berserk", 106951, "duration", 15 )
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
        addAura( "fiery_red_maimers", 236757 )
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
        
        addAura( "predatory_swiftness", 69369, "duration", 12, 'max_stack', 1 )
            modifyAura( 'predatory_swiftness', 'max_stack', function( x )
                if equipped.ailuro_pouncers then return 3 end
                return x
            end )

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

        addGearSet( 'ailuro_pouncers', 137024 )
        addGearSet( 'behemoth_headdress', 151801 )
        addGearSet( 'chatoyant_signet', 137040 )        
        addGearSet( 'ekowraith_creator_of_worlds', 137015 )
        addGearSet( 'fiery_red_maimers', 144354 )
        addGearSet( 'luffa_wrappings', 137056 )
        addGearSet( 'the_wildshapers_clutch', 137094 )


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
        

        addSetting( 'max_bite', true, {
            name = "Ferocious Bite: Cap Energy",
            type = "toggle",
            desc = "If |cFF00FF00true|r, Ferocious Bite will not be recommended until you have a surplus of energy to get its damage bonus.",
            width = "full"
        } )

        addSetting( 'regrowth_instant', true, {
            name = "Regrowth: Instant Only",
            type = "toggle",
            desc = "If |cFF00FF00true|r, Regrowth will only be usable in Cat Form when it can be cast without shifting out of form.",
            width = "full"
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

        addSetting( 'brutal_charges', 2, {
            name = "Brutal Slash: Save Charges for AOE",
            type = "range",
            desc = "Set a number of Brutal Slash stacks to save for AOE situations.  This is used in the default action lists.  If set to |cFF00FF002|r, the default " ..
                "action lists will recommend using 1 of your Brutal Slash charges in single-target but keep the remaining 2 charges on reserve for times when there are more enemies.",
            min = 0,
            max = 3,
            step = 1,
            width = "full"
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
            if equipped.fiery_red_maimers then applyBuff( "fiery_red_maimers", 30 ) end
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
            energy.max = energy.max + 50
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
            return x * ( ( buff.berserk.up or buff.incarnation.up ) and 0.5 or 1 )
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

        modifyAbility( "ferocious_bite", "spend", function( x )
            x = x + ( settings.max_bite and 25 or 0 )
            return x * ( ( buff.berserk.up or buff.incarnation.up ) and 0.5 or 1 )
        end )

        addHandler( "ferocious_bite", function ()
            if equipped.behemoth_headdress and buff.tigers_fury.up then buff.tigers_fury.expires = buff.tigers_fury.expires + min( 5, combo_points.current ) * 0.5 end
            spend( min( 5, combo_points.current ), "combo_points" )
            removeStack( "bloodtalons" )
            if ( target.health_pct < 25 or talent.sabertooth.enabled ) and debuff.rip.up then debuff.rip.expires = min( debuff.rip.duration * 1.3, query_time + debuff.rip.duration ) end
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
            if buff.fiery_red_maimers.up then return 0 end
            return x * ( ( buff.berserk.up or buff.incarnation.up ) and 0.5 or 1 )
        end )

        addHandler( "maim", function ()
            applyDebuff( "target", "maim", combo_points.current )
            if equipped.behemoth_headdress and buff.tigers_fury.up then buff.tigers_fury.expires = buff.tigers_fury.expires + min( 5, combo_points.current ) * 0.5 end
            spend( combo_points.current, "combo_points" )
            removeStack( "bloodtalons" )
            removeBuff( "fiery_red_maimers" )
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
            return x * ( ( buff.berserk.up or buff.incarnation.up ) and 0.5 or 1 )
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

        modifyAbility( "rip", "spend", function( x )
            return x * ( ( buff.berserk.up or buff.incarnation.up ) and 0.5 or 1 )
        end )

        addHandler( "rip", function ()
            applyDebuff( "target", "rip", min( 1.3 * class.auras.rip.duration, debuff.rip.remains + class.auras.rip.duration ) )
            if equipped.behemoth_headdress and buff.tigers_fury.up then buff.tigers_fury.expires = buff.tigers_fury.expires + min( 5, combo_points.current ) * 0.5 end
            spend( combo_points.current, "combo_points" )
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

        modifyAbility( "savage_roar", "spend", function( x )
            return x * ( ( buff.berserk.up or buff.incarnation.up ) and 0.5 or 1 )
        end )

        addHandler( "savage_roar", function ()
            local cost = min( 5, combo_points.current )
            if equipped.behemoth_headdress and buff.tigers_fury.up then buff.tigers_fury.expires = buff.tigers_fury.expires + min( 5, combo_points.current ) * 0.5 end
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
            if buff.clearcasting.up then return 0 end
            return x * ( ( buff.berserk.up or buff.incarnation.up ) and 0.5 or 1 )
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
                return x * ( ( buff.berserk.up or buff.incarnation.up ) and 0.5 or 1 )
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
            if buff.bear_form.up then return 77758
            elseif buff.cat_form.up then return 106830 end
            return x
        end )

        modifyAbility( "thrash", "spend", function( x )
            if buff.bear_form.up then
                return -4
            end
            if buff.clearcasting.up then return 0 end
            return x * ( ( buff.berserk.up or buff.incarnation.up ) and 0.5 or 1 )
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


    storeDefault( [[SimC Feral: default]], 'actionLists', 20171114.165509, [[deeQlaqivPyrQsOnPkv9jvjQrPkvoLQuAvQsIBPkjTls0WufhJKwMKQNjcmnvj4AsuzBsufFdrACQsKZPkPSocQmpjQk3JGQ2hbfhubwOc6HiIjQkP6IeKnkc6KiQMPevPBkj7ujlvKEk0uvOTIOSxQ)kfnyv1HfwmHESIMSOUmyZskFwenAP0Pj61sKzRu3wQ2nQ(nsdNahxIQQLJYZj10v56sy7sHVlcDEsy9euA(su2pcBvpAeNmPGZOXxhQff7ZdnIcGPm2sHnojL7L6tcmMcBi0Gx1FujvvvTUs16QVwckNXuiYkgLDWid6HKRnoyEskx7rVu9OXkAMSGTIoySqdnVwwOBnItMuWz8X4k6Gr8OmG4twSlaJcXdXnK9qJPWgcn4v9hvsvFmMcAAbBcAp6Zi58SCghLzKt5GXbIYT8uySrWKH4g85vDpASIMjlyROdgl0qZRLf6wJ4KjfCgHYFHuGaiRCxuRw0mrwiqGKNut8dEM4Rs8PmI)JXv0bJ4rzaXNSyxae)3P(wJcXdXnK9qJPWgcn4v9hvsvFmMcAAbBcAp6Zi58SCghLzKt5GXbIYT8uySrWKH4g85vc8OrH4H4gYEOrCYKcoJX8KnGMah6sqt8fgIVgUtYtQvguOjtkO51YaDlDNj(LvgXptpLmPaLNCwsYts8lRmI)j7aXxyi(QLJ4xwze)lyjHt5j7qZJ2mlbIF5J4)sghik3YtHrwbVzmpjL3Cl1NrY5z5mokZiNYbJ4XKZJKwywYdnwrZKfSv0bJgtbnTGnbTh9zCfDWyAbN4pyEskN4xEL6Z4awsTrE0bH)frzNeIFcbwSfoIVwYtUbI)fSKW9IgtHneAWR6pQKQ(yeBPjwrZYAsGP9qJK0cZsv0gqh4NfnwrZROdgrzNeIFcbwSfoIVwYtUbI)fSKW5ZRxWJgfIhIBi7HgXjtk4m(gI)jNLK8Ke)YkJ4lwuRMsbmAIBLfcmoquULNcJSOeyKCEwoJJYmYPCWyfntwWwrhmAmXwGNcrwHr9KjfCgxrhmMgLaJPGMwWMG2J(mMcBi0Gx1Fujv9XykezfJYoyKb9qY1e)xL4)oIFUGfNKYj(VcX)rzci(V1ijTWSufTb0b(zrJv08k6GrFEvopAuiEiUHShAeNmPGZ4Bi(If1QPCgxZAuwxzHaJdeLB5PWyo0TgjNNLZ4OmJCkhmwrZKfSv0bJgxrhm(6HU1ykSHqdEv)rLu1hJPGMwWMG2J(msslmlvrBaDGFw0yfnVIoy0NxLhpAuiEiUHShAeNmPGZ4Bi(If1QPuhnIKqtgnykleyCGOClpfg1rJij0KrdMrY5z5mokZiNYbJv0mzbBfDWOXv0bJy0isce)uAWmMcBi0Gx1Fujv9XykOPfSjO9OpJK0cZsv0gqh4NfnwrZROdg95fPE0Oq8qCdzp0iozsbNXJMm5guoP0DMMixBCGOClpfgfbMgyLmsoplNXrzg5uoySIMjlyROdgnUIoyCiW0aRKXuydHg8Q(JkPQpgtbnTGnbTh9zKKwywQI2a6a)SOXkAEfDWOpVEjpAuiEiUHShACGOClpfgL8zW4XjPCJKZZYzCuMroLdgROzYc2k6GrJROdgjNpdgpojLBmf2qObVQ)OsQ6JXuqtlytq7rFgjPfMLQOnGoWplASIMxrhm6ZRxZJgfIhIBi7Hghik3YtHXtMey6M1kykmsoplNXrzg5uoySIMjlyROdgnUIoyCuMeyVSM4NWcMcJPWgcn4v9hvsvFmMcAAbBcAp6ZijTWSufTb0b(zrJv08k6GrFEP(4rJcXdXnK9qJdeLB5PWyOBJEWbDZAmGlSkmsoplNXrzg5uoySIMjlyROdgnUIoyCGUn6bhEznXpHmGlSkmMcBi0Gx1Fujv9XykOPfSjO9OpJK0cZsv0gqh4NfnwrZROdg95LQQhnkepe3q2dnItMuWz8De)l2a)uQdrGDu61Qe4H4gYe)YkJ4lwuRMsbmihhLPOPorzTJdATYcbe)3s8FpX)InWpLIBknFXMY1kbEiUHmX)9eFXIA1ukUP08fBkxRmttKt8FpXFs7I0McOs(PvolymGFeFHN4xoJdeLB5PWidsYOjETgjNNLZ4OmJCkhmwrZKfSv0bJgxrhmMcjz0eVwJPWgcn4v9hvsvFmMcAAbBcAp6ZijTWSufTb0b(zrJv08k6GrFEPw3JgfIhIBi7HgXjtk4moPDrAtbuj)0kNfmgWpIVWt8lNXbIYT8uyKjfyKCEwoJJYmYPCWyfntwWwrhmAmXwGNcrwHr9KjfCgxrhmMkfymf00c2e0E0NXuydHg8Q(JkPQpgtHiRyu2bJmOhsUM4)Qe)3r8ZfS4KuoX)vi(pktaX)TgjPfMLQOnGoWplASIMxrhm6Zl1e4rJcXdXnK9qJ4KjfCgFdX)KZssEsI)7j(ncMme3GYcn08AzHUL4lme)hJdeLB5PW41YcDRrY5z5mokZiNYbJv0mzbBfDWOXeBbEkezfg1tMuWzCfDW4yll0TgtbnTGnbTh9zmf2qObVQ)OsQ6JXuiYkgLDWid6HKRnsslmlvrBaDGFw0yfnVIoy0NxQVGhnkepe3q2dnoquULNcJ6wgKnsoplNXrzg5uoySIMjlyROdgnUIoyeBzq2ykSHqdEv)rLu1hJPGMwWMG2J(msslmlvrBaDGFw0yfnVIoy0NpJROdgrzNeIFcbwSfoIFgQff7ZNn]] )

    storeDefault( [[SimC Feral: precombat]], 'actionLists', 20171114.165509, [[dGdKeaGErrAxOK2gIQA2u6Ms42k8Cr2PK2lz3OA)uWOefQHrv9BLEmqdvrKbJsnCqCqkQtjkKJHW5efyHkklfqlgflhPhkQ6PQwgfADkIAIIIyQamzqnDPUiI0HfUm01PkBuusBvuzZkcBNICEqYSeLyAiQY3rjonvEgIkJwI(MI0jre)fr5AII6EIs9zfvhxuqVgKAria61yG63nYBGDwrAyNSb2qOi4oyIwptWjcpBRz6arlgjuvJ(etjiimYkHrImGCzw)GuhKwx3my7wEsauLqa0jLhmwewZ0pi1bP17WI8Mvg7UWDyxEIvKhmwew3mJZ6AO0P4C6YsxQtch2bg9s15lh1lw4CbTgduxVgduhioNUS0L6arlgjuvJ(etj81bIP1JcIjbqTE(see6I1eoqElg9IfUgduxTQgfaDs5bJfH1m9dsDqADFDZmoRRHs3uqDbJf1jHd7aJEP68LJ6flCUGwJbQ7LqY6sAKk1RXa1FVu0a7CH1d1ntNN05XaZ2lHK1L0ivMftH1dZ2xhiAXiHQA0NykHVoqmTEuqmjaQ1ZxIGqxSMWbYBXOwvYja6KYdglcRz6hK6G06yg65GabHz16nXebzSqdiqC85jdSdoSb2egyVudS91nZ4SUgkDtb1fmwuNeoSdm6LQZxoQxSW5cAngOUxcjRlPrQuVgdu)9srdSZfwp0a7mMiJ0ntNN05XaZ2lHK1L0ivMftH1dZMqhiAXiHQA0NykHVoqmTEuqmjaQ1ZxIGqxSMWbYBXOwvYta0jLhmwewZ0nZ4SUgkDi0LfRojCyhy0lvNVCuVyHZf0AmqD9Amq9jrxwS6arlgjuvJ(etj81bIP1JcIjbqTE(see6I1eoqElg9IfUgduxTQzwa0jLhmwewZ0nZ4SUgkDWOjBILo0jHd7aJEP68LJ6flCUGwJbQRxJbQNpAdSZ6sh6arlgjuvJ(etj81bIP1JcIjbqTE(see6I1eoqElg9IfUgduxTQKVaOtkpySiSMPFqQdsR3785wKviB7wEs3mJZ6AO0HSTB56KWHDGrVuD(Yr9IfoxqRXa11RXa1N02ULRdeTyKqvn6tmLWxhiMwpkiMea165lrqOlwt4a5Ty0lw4AmqD1Q1pee0fwxMgTB5Qs4to1s]] )

    storeDefault( [[SimC Feral: cooldowns]], 'actionLists', 20171114.165509, [[daeUjaqiQKSibkTjc4teOmkQuoLazxiAyG0XevldeEMGQPrLuCneKTHGQVrqnoceNdbfRdbLMNav3tqzFcWbjilKKQhsfzIcuCrQeBKavFKkPYjjPCteANeAOujLwkv4PuMkj6QujvTvb0Ev(ljzWOCyGftupwOjlYLH2mO6ZKWOfKttQxdIMTuUTuTBv(TKHlklhPNtvtxvxNiBNkvFNkQZdkRNaP5Ja7hvV8PCMfP6SF2mldJAqtlOGxx3eZHg(SGbHdKA)uFMdSHaporiGMlCEEoeK5qKtycNqZCGGemL6oodpKQag5R7OQVufo0zcfFDD(PCI5t5mxoGCdtt9zwKQZ(zUIZKLGdNmcEvWlANukBMqY6M(Hnlb8HMP2L0rWx0zxD4mIvkqave0XzZebDCwWa8HM5aBiWJtecO5cNdDMd0xs0i6NY9ZCkegHKy5o2X7N8mIvse0Xz7Niet5mxoGCdtt9zwKQZ(zFPqrdjJv1sLZNNZeGZCJZWdPkGrgLOu8EolGW4SWHYzcWzUXzXQAPY5J81kqQxfCjkmsk2b6ZZzbWzeIZiGaotwcoCYxRaPEvWLOWiLY4SG4SGMjKSUPFyZKrQhPqotTlPJGVOZU6WzeRuGaQiOJZMjc64m1rQhPqoZb2qGhNieqZfoh6mhOVKOr0pL7N5uimcjXYDSJ3p5zeRKiOJZ2pXWNYzUCa5gMM6ZSivN9ZWdPkGrMq46O(5SacJZiCOZesw30pSzVwbs9QGlrHntTlPJGVOZU6WzeRuGaQiOJZMjc64mLAfivW8CMGlrHnZb2qGhNieqZfoh6mhOVKOr0pL7N5uimcjXYDSJ3p5zeRKiOJZ2prxZuoZLdi3W0uFMfP6SFwS6YLQSsFVNmkrP49CwyCguotaodpKQagzuIsX75SacJZie0zcjRB6h2mSjDOxLcjDcCrCMAxshbFrND1HZiwPaburqhNnte0XzU0KouW8CMRtsNaxeN5aBiWJtecO5cNdDMd0xs0i6NY9ZCkegHKy5o2X7N8mIvse0Xz7NiHMYzUCa5gMM6ZSivN9ZWdPkGrgLOu8EolGW4SWHYzcWzUXzXQAPY5J81kqQxfCjkmsk2b6ZZzbWz5eIZiGaotwcoCYxRaPEvWLOWiLY4SGM5Ci8CGGeSz(ivN9Zu7s6i4l6SRoCgXkfiGkc64SzcjRB6h2m9fb0d866Mjc64m1UiGEGxx3mNcHrijwUJD8(jpZb2qGhNieqZfoh6mhiibtPUJZWdPkGr(6oQ6lvHdDMd0xs0i6NY9ZiwjrqhNTFIe(uoZLdi3W0uFMfP6SF2xku0qYS61155mb4m34ShqvGp5R7OQVuL0iNfCoJWjeNrabCMBC2R7OQVuL0iNfColxqGYzcWzUXzYsWHtkJupsHKukJZiGaotwcoCs9fb0d866iLY4SG4SG4SGMjKSUPFyZYQxx3m1UKoc(Io7QdNrSsbcOIGooBMiOJZCT1RRBMquf(zhOJHfSz0QvNcmPkRCgPb7mhydbECIqanx4COZCG(sIgr)uUFMtHWiKel3XoE)KNrSsIGoolJwT6uGjvzLZiD)efEkN5YbKByAQpZIuD2plwD5svwPV3tgLOu8EolGW4mi4mb4m34mxXzpOH3tk3Qk9GwDEs8aYnmXzeqaNjlbhoPCRQ0dA15jLY4SGMjKSUPFyZa(qGo4qVk4u8euyZu7s6i4l6SRoCgXkfiGkc64SzIGootiFiqhCOG55mbNINGcBMdSHaporiGMlCo0zoqFjrJOFk3pZPqyesIL7yhVFYZiwjrqhNTFIcYuoZLdi3W0uFMfP6SFwS6YLQSsFVNmkrP49CwW5mcXzcWz4HufWiJsukEpNfqyCgi(66iPairYy5FotaolvpjfajsM1LAVoRPrkNfCodcYCotaotwcoCYxRaPEvWLOWiLY4mb4m34mzj4WjLBvLEqRopPugNrabCMR4Sh0W7jLBvLEqRopjEa5gM4SG4mb4m34mxXzpOH3tQViGEGxxhjEa5gM4mciGZIv1sLZhP(Ia6bEDDKuSd0NNZcGZYfeoliotaoZvCMSeC4K6lcOh411rkLntizDt)WM5dbsLZDSLMP2L0rWx0zxD4mIvkqave0XzZebDCMfcKkN7ylnZb2qGhNieqZfoh6mhOVKOr0pL7N5uimcjXYDSJ3p5zeRKiOJZ2prcZuoZLdi3W0uFMqY6M(HntYJQ0p29Zu7s6i4l6SRoCgXkfiGkc64SzIGooZ17rotTh7(zoWgc84eHaAUW5qN5a9LenI(PC)mNcHrijwUJD8(jpJyLebDC2(9ZebDCMP7oXzcosbnclNfRQLkNp)(n]] )

    storeDefault( [[SimC Feral: single target]], 'actionLists', 20171114.165509, [[d0ZggaGEGcTjssTlvyBII0(efLzIkPztL5tj5MQOVHk1Tf60OSte2R0UbTFsnkGkggQY4efvxM48uQAWumCuvhKK6uafDmbohqbluLyPazXKy5i9quXtHwMO0ZPQjkkIPQsnzatxvxKsP)kQ6zKKCDbTrePTkkSze12PuzDKeFhrmnGsMhqLoeqPoSIrtjESiNKsXNvjDnujUhqvlIsQFR0RfvUb9UiXeLIilYrBivOJtfTXZGxDI28d9Q8fZeH8e6(EPiiXjJxkrwEbCheeK9iiBayqvCPiMOm(FXIQtpBH(ExIGEx0w4O4eGEPiMOm(FrWwBucjt(inFEYlnEeYVOAfMJ92xmnFEYlnw0gialn)slcxOu8CbYyOetukwKyIsroZRnKU0yrqItgVuIS8c4oGxrqIFdPjX37(f5yrs5ox7KOa)Qu8CbiMOuSFjY27I2chfNa0lfXeLX)lQesM8bF6sI7iKV2yLvAJsizYhEldWssuCahH8lQwH5yV9fPtoPOnqawA(LweUqP45cKXqjMOuSiXeLIGMCsrqItgVuIS8c4oGxrqIFdPjX37(f5yrs5ox7KOa)Qu8CbiMOuSFjuvVlAlCuCcqVuuTcZXE7lMgNl)KE2cZ7y(VOnqawA(LweUqP45cKXqjMOuSiXeLICgNtBuNE2c1gUY8Fr10R(IWjkG3AKf5OnKk0XPI2K21bSKa9wxeK4KXlLilVaUd4veK43qAs89UFrowKuUZ1ojkWVkfpxaIjkfrwKJ2qQqhNkAtAxhWsc03VeGvVlAlCuCcqVuetug)VyAJkBE(ld((JuiLkWxBaV2WfTr1AZpob(hkUDb(XTq)HahfNaOnQwBucjt(qXTlWpUf6pawsGAJQ1gWrBaBTrjKm5dgmnu48SfEeYxBSYkTby)dkJ)bvIdd61gWvBYCTXkR0gG9pOto5GkXHb9Ad4QnCrBaZIQvyo2BFrQCLUK8wkAdeGLMFPfHlukEUazmuIjkflsmrPii5kDj5TueK4KXlLilVaUd4veK43qAs89UFrowKuUZ1ojkWVkfpxaIjkf7xcU07I2chfNa0lfXeLX)lM2OYMN)YGV)ifsPc81MmtBaRIQvyo2BFrAim)KE2cZ7y(VOnqawA(LweUqP45cqmrPiYIC0gsf64urBWBTHmdY8weQV45cKXqjMOuSihlsk35ANef4xLIetukckeQnQtpBHAdxz(VOA6vFr4efWBnYIC0gsf64urBWBTHmdY8weQ36IGeNmEPez5fWDaVIGe)gstIV39lIwwsoxagzMq99sr8PS0ZXIKY1l9lrM27I2chfNa0lfvRWCS3(I0qy(j9SfM3X8FrBGaS08lTiCHsXZfiJHsmrPyrIjkfbfc1g1PNTqTHRm)RnGtaywun9QViCIc4TgzroAdPcDCQOn4T2CvGcD(L6TUiiXjJxkrwEbChWRiiXVH0K47D)ICSiPCNRDsuGFvkEUaetukISihTHuHoov0g8wBUkqHo)s997xe5lj24yGX5zlSeb8uv)wa]] )

    storeDefault( [[SimC Feral: ST finishers]], 'actionLists', 20171114.165509, [[d0d2gaGEqj1Mar7cvEnvs7dvXZfA2QY8vb3ev1LrUTGdlANuXEH2nj7xQrHcddK(nrNhuCALgSIHtWHqP4uOKJPsohvQYcPsSuq1Ivrlh4Huv8uklJQQ1bkHjsLQAQeQjRQMUKlQsvJJQupJkLRtQ2iOu2Qkv2Sk02vP8zc57Gs10aLO5bc(gvL(lkA0ufJhusoji0TOsLRHsP7rvYQqv6XKYbrPA8cfJM7tht9xHUGMjqAB(wyDwRuHoxqDdnNmqOzBWNEGncKpyrpM4EoUQn6Har0GtpkJe64h6LVxxx(5U8F5EUXw0Gt5hgXBGqJrpceiUXIufZG(RwH3sGE4PNVS4aRaNqq)vRWBjqpS6bYEy0dGc5QI94UEy0ZxhK1kv9WBpq58Uhw9WQNdh6HrpakKRk2J76HrpFDqwRu1dV9aLZTEy1dl0yxRwPkIIrNlumA3RYZh9rxqZ0aRqH2P(XJCX8wkIycKjG7lHDfASFUVTGbTyElfrmbYeGgev)vlljanLurOXx(VlbozGqdnNmqOz5Tue1dCzcqdo9OmsOJFOx(Ebfn4uuQd0Oikgl08XdP5kF5nkqQcprJV87KbcnSqh)Oy0UxLNp6JUGMPbwHcn20tTAUUkr9C4qpm6bqHCvXEGGx981bzTsvp82duo36Hvpq2dJEQeiIkopu(kpCcAvp80JF22dK9WMEQ8rQIlMNeOKYYdhPYZh97Hvpho0dJEauixvShi4vpFDqwRu1dV9aLZ7EGShbce3yrQIzq)vRWBjqp80ZxwCGvGtiO)Qv4TeOhw9azpvcerfxTbIzjz(xQhE6XB0GDpKcoLFyqlQbwHcniQ(RwwsaAkPIqJ9Z9TfmObwb04l)3LaNmqOHMpEinx5lVrbsv4jAozGqd(kGg7arr0QeiIkM7rVytTAUUkrhoWaqHCvri41xhK1kv8cLZnwqYOsGiQ48q5R8WjOv84NTqYMkFKQ4I5jbkPS8WrQ88rFwhoWaqHCvri41xhK1kv8cLZBifiqCJfPkMb9xTcVLa88Lfhyf4ec6VAfElbybzLaruXvBGywsM)L4XB0GtpkJe64h6LVxqrdofL6ankIIXcn4u(Hr8gi0y0JabIBSivXmO)Qv4TeOhE65lloWkWje0F1k8wc0dREGShg9aOqUQypURhg981bzTsvp82duoV7HvpS65WHEy0dGc5QI94UEy0ZxhK1kv9WBpq5CRhw9Wcn(YVtgi0WcDCdfJ29Q88rF0f0mnWkuODQF8ixmVLIiMazc4auixvShi0ZLF0y)CFBbdAX8wkIycKjaniQ(RwwsaAkPIqJV8FxcCYaHgAozGqZYBPiQh4Ye0dJlwObNEugj0Xp0lFVGIgCkk1bAuefJfA(4H0CLV8gfivHNOXx(DYaHgwOdSefJ29Q88rF0f0mnWkuODQF8i3XLaWWeqFMHCdeiYPlGg7N7BlyqlKBaniQ(RwwsaAkPIqJV8FxcCYaHgAozGqJFUb0GtpkJe64h6LVxqrdofL6ankIIXcnF8qAUYxEJcKQWt04l)ozGqdl0HTOy0UxLNp6JUGg7N7Blyq7ibKARupY8ClcniQ(RwwsaAkPIqJV8FxcCYaHgAozGqd2iGuBL6XECzlcn2bIIOfsyftsrarW41fAWPhLrcD8d9Y3lOObNIsDGgfrXyHMpEinx5lVrbsv4jA8LFNmqOHfwOzAGvOqdleb]] )

    storeDefault( [[SimC Feral: ST generators]], 'actionLists', 20171114.165509, [[dau3oaqiQsSjQuJsGoLGAvcOxHueDlIQAxKyyQQoMkAzQqptaMgvjDnKIABQcrFJOY4ufsNtviSoKIW8qkCpIQSpjWbPsAHujEOe0evfQCrvqBuvOQtQcCtKQDsflvv5PuMkrzRQc2l4VKKbR4WIwmrEmsMSqxgAZKuFwcnAj60eETGmBjDBvA3O63igUQ0XvfkTCuEoPMUuxNQA7iL(UQOXRkuCEQI1JuKMpvP2VsdNGmWECO60V2GlGzViLiRcAA2cchCo)damN8IGzIBH784rwwPj2XKTtrKJSSjmnyFyftncoh)pL7888OY5XZhra0myFyg9itCrWy4nfC9oYFNG7e9zzli8DcCNFLa2jmyUs1ccxdYaNtqgyhYtPkgbxaZOyI3gSoRiVvKQesSZkHRvqEkvX4oU3rYxTALxggZMW8Os)uOU5OwR4)UJ7DK8vRwrQsiXoReUwjsEY3X9ouKRer1lrWBTcLpJH8ENcK3oh3X9ouesnsEYvsDzEtoQvPMHCAQhfgEtbxVdn2PivemxLevr7bmgwKrE2LGDapkOYMWaJt4iy0jXhsMtErWaZjViyFyrg5zxc2hwXuJGZX)t5o)b7d1eFgfQbzqdwHLivi6eAXlYBqcm6KOtErWGgCocYa7qEkvXi4cygft82G1zf5TIuLqIDwjCTcYtPkg3X9os(QvR8YWy2eMhv6Nc1nh1Af)3DCVJKVA1ksvcj2zLW1krYt(oU3HICLiQEjcERvO8zmK37iVD86oU3jsAfwgcvy4nfC9o0yhVcMRsIQO9agdlYip7sWoGhfuztyGXjCem6K4djZjViyG5KxeSpSiJ8Sl3j4zyW(WkMAeCo(Fk35pyFOM4ZOqnidAWkSePcrNqlErEdsGrNeDYlcg0GtaGmWoKNsvmcUaMrXeVny4J1x8(IrLuu9zevVeFofY074ENoRiVvKQesSZkHRvqEkvX4oU3j4os(QvR8YWy2eMhv6Nc1nh1AfDNuH2PGDoUJ3EVtWDK8vRw5LHXSjmpQ0pfQBoQ1k6oPcTtb7CUJ7DIKwHLHqfgEtbxVdn2jGDcVt4DCVJKVA1ksvcj2zLW1krYtoyUkjQI2dymSiJ8Slb7aEuqLnHbgNWrWOtIpKmN8IGbMtErW(WImYZUCNGhdd2hwXuJGZX)t5o)b7d1eFgfQbzqdwHLivi6eAXlYBqcm6KOtErWGgC8kidSd5PufJGlGzumXBdws1cArvihVcuVtb7CcMRsIQO9aMeZVZQkDn1LGDapkOYMWaJt4iy0jXhsMtErWaZjViyUW87SUJvtDjyFyftncoh)pL78hSput8zuOgKbnyfwIuHOtOfViVbjWOtIo5fbdAWHMbzGDipLQyeCbmJIjEBWcUJx2PfuHe8I74T37WWBk46DOXorFw2ccFNa35xjGDcVJ7DcUts1cArvihVcuVtb7CCNWG5QKOkApG1LSuxc2b8OGkBcdmoHJGrNeFizo5fbdSNLi)dZOhW0umXBdMtErWKvYsDjyFOM4ZOqnidAW(WkMAeCo(Fk35pyFyg9itCrWy4nfC9oYFNG7e9zzli8DcCNFLa2jmyfwIuHOtOfViVbjWOtIo5fbdAW5rcYa7qEkvXi4cygft82G5LDAbvibV4oE79ob3Xl70zf5TIuLqIDwjCTcYtPkg3X9om8McUEhASt0NLTGW3jWD(vcyNW74ENozfXwPfxuvtuff4ofSJxb7zjY)Wm6bmnft82GDapkOYMWaJt4iyUkjQI2dySmecgDs8HK5KxemWkSePcrNqlErEdsG5KxeSVmecMRSIAW6KveBvc1YZlTGkKGx0BVd6LoRiVvKQesSZkHRvqEkvXOBgEtbxtJOplBbHh4VsaHD3jRi2kT4IQAIQOalWRG9Hvm1i4C8)uUZFW(qnXNrHAqg0G9Hz0JmXfbJH3uW17i)DcUt0NLTGW3jWD(vcyNWGrNeDYlcg0GJCGmWoKNsvmcUaMrXeVnyDwrERivjKyNvcxRG8uQIXDCVJKVA1ksvcj2zLW1k(V74ENG7eChgEtbxVdnK3oYTt4DCVZlY0cDJ8w11V2I3Qaz7uWorsRWYqOY71V2I3Qaz7e4o)kpknVt4DCVtNSIyR0IlQQjQIcCNc2XRG9Se5Fyg9aMMIjEBWoGhfuztyGXjCemxLevr7bmwgcbJoj(qYCYlcgyfwIuHOtOfViVbjWCYlc2xgc3j4zyWCLvudwNSIyRsOwEDwrERivjKyNvcxRG8uQIr3s(QvRivjKyNvcxR4)6oyqgEtbxtd5jxy3Vitl0nYBvx)AlERcKvqK0kSmeQ8E9RT4TkqwG)kpknh2DNSIyR0IlQQjQIcSaVc2hwXuJGZX)t5o)b7d1eFgfQbzqd2hMrpYexemgEtbxVJ83roWOtIo5fbdAW5rbzGDipLQyeCbmJIjEBWcUJKVA1kTOiY0Qu7Z8O4)UJ7DcUtWDo3HMCNB(yurvMSIOEh5VdvzYkIAvQzjvli8SUt4DcChgsvMSIOQwCXDcVtyWCvsufThWKy(DwvPRPUeSd4rbv2egyCchbJoj(qYCYlcgyo5fbZfMFN1DSAQl3j4zyW(WkMAeCo(Fk35pyFOM4ZOqnidAWkSePcrNqlErEdsGrNeDYlcg0GZJaKb2H8uQIrWfWmkM4Tbl4oEzNwqfsWlUJ3EVddVPGR3Hg7e9zzli8DcCNFLa2j8oU3j4o0MmrkvrfFnQQlzPUCh5TZXD827DsQwqlQc54vG6DkyNZDcd2ZsK)Hz0dyAkM4Tb7aEuqLnHbgNWrWOtIpKmN8IGbMRsIQO9awxYsDjyo5fbtwjl1L7e8mmyfwIuHOtOfViVbjW(WkMAeCo(Fk35pyFOM4ZOqnidAW(Wm6rM4IGXWBk46DK)ob3j6ZYwq47e4o)kbStyWOtIo5fbdAW58hKb2H8uQIrWfWmkM4Tbl4oEzNwqfsWlUJ3EVddVPGR3Hg7e9zzli8DcCNFLa2j8oU3H2KjsPkQ4RrvDjl1L7iVDo3X9os(QvRqvXKrL6wWlQ4)c2ZsK)Hz0dyAkM4Tb7aEuqLnHbgNWrWOtIpKmN8IGbMRsIQO9awxYsDjyo5fbtwjl1L7e8yyWkSePcrNqlErEdsG9Hvm1i4C8)uUZFW(qnXNrHAqg0G9Hz0JmXfbJH3uW17i)DcUt0NLTGW3jWD(vcyNWGrNeDYlcg0GZ5jidSd5PufJGlGzumXBdws1cArvihVcuVtb7CcMRsIQO9aM(P4fb7aEuqLnHbgNWrWOtIpKmN8IGbMtErWSNIxeSpSIPgbNJ)NYD(d2hQj(mkudYGgSclrQq0j0IxK3Gey0jrN8IGbn4CEeKb2H8uQIrWfWCvsufThW0Lmmc2b8OGkBcdmoHJGrNeFizo5fbdmN8IGzLmmc2hwXuJGZX)t5o)b7d1eFgfQbzqdwHLivi6eAXlYBqcm6KOtErWGgAWmkM4TbdAaa]] )

    storeDefault( [[IV Guardian: Single]], 'actionLists', 20171114.165509, [[dKdteaGEa0UeQETGG9je1SPQBkkCBQ0ZP0oLyVKDdA)a0Oeu0WqvJtqQoSudvqsdgqnCr1bPIoLGsDmjDobrTqQWsfyXO0Yr6BOONQSmGSobLmrbfMkQmzenDvUOq6QcICzORJW5fkBvuuBgO2UqWhfe60QAAcH(UGkZtqINjez0aYJf5KOWFbGRjOQ7jiLplkTnrr(nfRQ40cdeCt4p5qR0UOgJmdiWHirtj)ggwac8EywpQfGESTOkG4RmR1kO4vq1qosHxB5y6B)dW(EduLkFe1CMU3aTItLQ40IcBwpskhAlr)8ttR0UOwizrabMXHUwnNSV)VyAewea)HUwTa0AiOj0koDAbOhBlQci(kZkVgdi5N6Zq1GgiQtfqItlkSz9iPCOTe9ZpnTs7IACarBlqAozF)FX0oGOTfiTa0AiOj0koDAbOhBlQci(kZkVgdi5N6Zq1GgiQtLijoTOWM1JKYH2s0p)00kTlQLrdZ6rnNSV)VyAUnmRh1cqRHGMqR40PfGESTOkG4RmR8AmGKFQpdvdAGOovIO40IcBwpskhAlr)8tJLam44zBFNUpbGSenL8ByCICTs7IAzymqWpf1CY(()IP5AmqWpf1cqRHGMqR40PfGESTOkG4RmR8AmGKFQpdvdAGOovcV40IcBwpskhAlr)8tJezjado(beTTabawSPXTxNcbaboYacCvR0UOwOs4JasFaIAozF)FX0Yj8raPparngqYp1NHQbnqulaTgcAcTItNwa6X2IQaIVYSYRtLmjoTOWM1JKYH2s0p)0irwcWGJ7AmqWpfJtr3(H2qj0YMi1kTlQLHXab)ueqGdZAyR5K99)ftZ1yGGFkQXas(P(munObIAbO1qqtOvC60cqp2wufq8vMvEDQWuCArHnRhjLdTLOF(Pr7Sy8ebLIWlYzIxR0UOwgnHxZj77)lMMBt41yaj)uFgQg0arTa0AiOj0koDAbOhBlQci(kZkVovcDXPff2SEKuo0wI(5NMwPDrTfUph1CY(()IPzd3NJAmGKFQpdvdAGOwaAne0eAfNoTa0JTfvbeFLzLxNoTLOF(PPtca]] )

    storeDefault( [[IV Guardian: 2-3]], 'actionLists', 20171114.165509, [[dOtreaGErP2Lq51KuQ9jeA2u1nfIUm42uPdl1oL0Er7gQ9lKAucsAyKQXrsv9CknubrgSqYWfvhKk6uccoMeNtqIfsfwQalMelNOZlu9uLhlY6eKQjkiLPsktMGPRYfffxLKsEgjfxNqNwvBLKkTziz7ck(OGOMhjv5ZquFxqv)vuY0euA0qKVrsojK6wKuX1ecUNGqBtqLLbHFtXSqnUqdq1I(Jo4QTlWHwDJoQqwSLcFJd9OJcH6OgUaWdTfyfHErvPuqeRGOekQjcClhsF7)S77nywl6HLZz6Ed2snwluJldUv8GaDWvBxGtTSq0rH(axl3sYp)44CQ8()IZjAHS(dCTCOXcFQpJKdBWaxa4H2cSIqVOQOZfawJOmbwQXJhRiOgxgCR4bb6GR2UaNgsY2Ie3sYp)44CQ8()IZDijBlsCOXcFQpJKdBWaxa4H2cSIqVOQOZfawJOmbwQXJhRQHACzWTIheOdUA7cCr2yK9a3sYp)44CQ8()IZ52yK9ahASWN6Zi5WgmWfaEOTaRi0lQk6CbG1iktGLA84XAyPgxgCR4bb6GR2UaxKgdg1lbULKF(XPiIcvmKBFNUpLfYITu4BCmXCoNkV)V4CUgdg1lbo0yHp1NrYHnyGla8qBbwrOxuv05caRruMal14XJ1iqnUm4wXdc0bxTDbUqs0hgq(zdClj)8JtauerHk2HKSTiLLc0Yy2RtQDelCbGhAlWkc9IQIohASWN6Zi5WgmWfawJOmbwQXJZPY7)loxUOpmG8Zg4XA4OgxgCR4bb6GR2UaxKgdg1lHOJkulHa3sYp)4eafruOI5AmyuVeIjb3(Xw1lerojWfaEOTaRi0lQk6COXcFQpJKdBWaxaynIYeyPgpoNkV)V4CUgdg1lbESQIACzWTIheOdUA7cCr2IEULKF(XjBKHyjrPeWxedNoxa4H2cSIqVOQOZHgl8P(msoSbdCbG1iktGLA84CQ8()IZ52IEESQ(uJldUv8GaDWvBxGBH)ZbULKF(XXfaEOTaRi0lQk6COXcFQpJKdBWaxaynIYeyPgpoNkV)V4C2W)5apEClj)8JJhj]] )

    storeDefault( [[IV Guardian: 4+]], 'actionLists', 20171114.165509, [[dudpdaGEQk2Le1RPGAFsKmBQCtir3wc7us7fTBO2pLQggL8BrgkePgmLkdxqhKcDmrDojsTqkLLsvwmHwojpNupvzzqyDqu1eHizQemzIA6QCrbCvicxgCDICyP2keL2mf12HK8rik(gf5ZuGVtb5VseNwvJMQQNbj1jHupwORbjCEbAAuvABqu5vqenZuGdPaZTK7OnUAxaCOrw7TdzKAL83yK3E78fj58ah0AGvewzt5Cgr5mICPrnk4wie)29(03NWSMT8LZy8(ewtbwZuGlaUfDGmTXv7cGdj0G92H(Gcn3IQp844mk(U)cYjPHs(dk0COXYFSVKIdNWaNh4GwdSIWkBkBX5b6KKkcAkWJhRiOaxaCl6azAJR2faNGFvR9ZTO6dpooJIV7VGCNFvR9ZHgl)X(skoCcdCEGdAnWkcRSPSfNhOtsQiOPapESIAkWfa3IoqM24QDbWHYgBGd4wu9HhhNrX39xqUIgBGd4qJL)yFjfhoHbopWbTgyfHv2u2IZd0jjve0uGhpw9LcCbWTOdKPnUAxaCOmLWMFfWTO6dporjZMlBq7649XsmqQvYFJllfYzu8D)fKRiLWMFfWHgl)X(skoCcdCEGdAnWkcRSPSfNhOtsQiOPapESIckWfa3IoqM24QDbWH0soubQ3hGBr1hECYGOKzZLp)Qw7VerOvL1xhnCPYCEGdAnWkcRSPSfhAS8h7lP4WjmW5b6KKkcAkWJZO47(lixOKdvG69b4XkYrbUa4w0bY0gxTlaUzOpe4wu9HhhNh4GwdSIWkBkBXHgl)X(skoCcdCEGojPIGMc84mk(U)cYPn0hc84XTO6dpoEKa]] )

    storeDefault( [[IV Guardian: Default]], 'actionLists', 20171114.165509, [[dGdndaGAqjTEGK2eQuTlcvVgiX(aLA2K6Mek3MGDcYEf7wv7xQgMk53u65sAWsz4sOdQcomvhdW5afAHsWsbQfRIwojFtf6PiltLADOOMiOstLitgLMUsxef8kqfxg66e1gbszROiBwISDujFef68GQMgqmpqjoTINjrnAqr9ykojQ4wOs5AaP6EGc(mH8Dqr(lQ6aePqWfl5Y6nfcb5cyiom1Bmk7k2XFM7n4ILCz9gcmQrVIb6(c4iaaWT4a3aWyzqpevenJRhq13X(bc4cKqhm7y)AKceqKcXW7NAKnfcrg1uCdDkxQK4NOR4lzvcIZAHPpeKlGHkGUQ3anRsi0HZrpl8HM34Q33X(8GY8I4TL4xyg5Hv5xKgdbgRwzLbRrkBiWOg9kgO7lGJaxH48SJXxRk0BFmBGUJuigE)uJSPqiYOMIBi3Sdxip(OWG1Edg6nGqqUagIMxKg7njxjc3qGXQvwzWAKYg6W5ONf(qk5N3n7yFE9u3qCE2X4Rvf6TpgcmQrVIb6(c4iWviXSSqUagIdt9gJYUID8N5EJMxKgZgOYrkedVFQr2uiezutXnKB2HlKhFuyWAVb7EdO34EV5MD4c5XhfgS2BWsVbsiixadDZTY9MKReHBneySALvgSgPSHoCo6zHpKX1AE3SJ951tDdX5zhJVwvO3(yiWOg9kgO7lGJaxHeZYc5cyiom1Bmk7k2XFM7TBUvoBGajsHy49tnYMcHiJAkUHCZoCH84Jcdw7ny3BLdb5cyiqGtVj5kr4wdbgRwzLbRrkBOdNJEw4dzCTM3n7yFE9u3qCE2X4Rvf6TpgcmQrVIb6(c4iWviXSSqUagIdt9gJYUID8N5Ede4KnBiYOMIBOSja]] )

    if hekili_is_dumb then
        storeDefault( [[IV Feral: Single]], 'actionLists', 20171114.165509, [[deKujaqifGUejHSjssFIQQQrrvLtrvPvPa1ROQkDlQQk7IOgMICmQ0YqrpdkvttbY1OQyBuvf9nf04OIQCofqToQOQMhuk3tbW(uu5GqjlurzIuvfUik0gjj6KOGzsfv6MkGStQYsvspLYuvQ2kvuXEv9xOyWqoSulgQESqtMixgzZk0NjPgTs50aVMKGzl42kXUr1VjmCsCCsc1YL8CsnDrxhL2ovu(UIQ68uH1ROkZNkY(b9D)(nlwaL82n)bn2SH8ZU51l0ngCoqKkPQdoFiYaC1b62kfOwt3J5K7qxxxMYUmDhyS7ZTvQLCSdwOB(brmLh6de5FquCRl1KgZy1Xei4DaI8fIgmevuCRl10nSIjqW1F)EUF)gJ8gpqsF2nlwaL8wrJfP3A8aDBL0c2ks6V)8gw4GaiDCt3oRvtykrx3yGlbIDkQBCbNUTsbQ109yo5o0D6MxVq3S2zTAcIwfD98Em)(ng5nEGK(SBwSak5TIglsV14bcICYjissKYvRcKSYcBibkbavqe2GifQ0aDs8eZcBibkbav3wjTGTIK(7pVHfoiash3QwfOBmWLaXof1nUGt3wPa1A6EmNCh6oDZRxOBRTkqpVh2)(ng5nEGK(SBwSak5TOybxGrra4PwoYwfXtiAoiAqqKQqKFq0acrzhiEkRBCQsHi3KjEJhijiYjNGOSl1ukVrDi3WOetiAUbaIy6de5lePkeLDPMs5eSqysbgjabrZbrseo74OCbuKLyRobcoePIGiSdrQcr(brfnwKERXdee5KtqKKiLlGISYcBibkbavqe2GifQ0aDs8eZcBibkbavqKV3wjTGTIK(7pVHfoiash3kGYng4sGyNI6gxWPBRuGAnDpMtUdDNU51l0TvGYZ7nOVFJrEJhiPp7MflGsElkwWfyueaEQLJSvr8eIMdIgeePke5heLDG4PSUXPkfICtM4nEGKGiNCcIYUutP8g1HCdJsmHiSbrm9bI892kPfSvK0F)5nSWbbq642ivIiqWQXGds6gdCjqStrDJl40TvkqTMUhZj3HUt386f6MkPsebcwnendK0Z75Z3VXiVXdK0NDZIfqjVLDG4PCGL3fgaxRaQobcUmXB8ajbrQcrfnwKERXd0TvslyRiP)(ZByHdcG0XTfHGpck6gdCjqStrDJl40TvkqTMUhZj3HUt386f62aje8rqrpVN)873yK34bs6ZUzXcOK3WzhhLJbQRyRtaxTmRcePkerQywGIcjjhyhhBmZVAffaxTgIufIkASi9wJhOBRKwWwrs)9N3WcheaPJB5w16TBmWLaXof1nUGt3wPa1A6EmNCh6oDZRxOB7BvR3Gi)CUSJJTVpV3WVFJrEJhiPp7MflGsEJ4uP2HCKTkINqe2gaiI50TvslyRiP)(ZByHdcG0XTeOMknMr2YXng4sGyNI6gxWPBRuGAnDpMtUdDNU51l0TDGAQ8FnePs2YXZ758((ng5nEGK(SBRKwWwrs)9N3SybuYB4SJJYjqnvAmJSLdzwLB2My(dKqcmcOsF8ByHdcG0XTwV1lnN0yglIpph3yGlbIDkQBCbNUTsbQ109yo5o0D6MxVq3WsV1lnN8FnePYI4ZZXZ7nWF)gJ8gpqsF2nlwaL8wCRl1KgZy1Xei4DaIMdIykp0hisvikkwWfyueaEQLJSvr8eIWge5ZnSWbbq64gEXMDaJo06TBmWLaXof1nUGt386f62SIn7aezHwVDBLcuRP7XCYDO70TvslyRiP)(ZBRul5yhSq38dIykp0hiY)GO4wxQjnMXQJjqW7ae5lenyiQO4wxQPBZFJ4Rul54MowaL859CN((ng5nEGK(SBwSak5TOybxGrra4PwoYwfXticBqKp3wjTGTIK(7pVHfoiash30BfjDJbUei2POUXfC62kfOwt3J5K7q3PBE9cDZ2ks659CD)(ng5nEGK(SBwSak5TOybxGrra4PwoYwfXtiAoiAqqKQqKFqKKiLlGICrlnGRHO5Gijrkxafzj2QtGGdrdgIMKXoe5VqK7ee5lePke5henGqu2bINY62zTActj6sM4nEGKGiNCcIWzhhL1TZA1eMs0LCrlnGRHO5GiC2XrzD7SwnHPeDjlXwDceCiAWq0Km2Hi)fICNGiFVTsAbBfj93FEdlCqaKoUnsLiceSAm4GKUXaxce7uu34coDBLcuRP7XCYDO70nVEHUPsQerGGvdrZajbr(X03NpVzkue0bW86ei43ZDc7p)b]] )

        storeDefault( [[IV Feral: Opener]], 'actionLists', 20171114.165509, [[da0JhaGjjv5teu1OufLtjPQwLOIClIkzxeyys0XqPLbkpJOktJGkxtuPTPkQ6BeLXrqrNJOsTockzEev19iiv7JOchuu1cjLEibjnrcs5IQcBuuHtkHUjbf2jk(jbLAOeKyPKQNcnvrzRQIk7L6VQsdgKdl1IjYJfAYe6YiBMu8zjLrlbNgy1IkQxRkYSf52sYUv53OA4cSCfpNKPR01f02LuPVtqCEq16LuX8jQO9RQ2SoZighqWA0OqJ00HP1AnY0vKXIp3hkh00jH1hsyhqhng1Pe1kYmWkzLXYYctalmw5wE5AuNAr4zGkY4Z(qWeil3pKC9HIf6PgPE1mDCb8RtFO6)HYPp0qXc9uJmMpUa(PCMzyDMXhxlLirR1itxrgfkdxijJyCabRrJ5LajWc3yWWfsYyXtee7Lpgp(rg1Pe1kYmWkzLXwAuNu8WjskN51RzG5mJpUwkrIwRrMUImku79dLd(uzeJdiynAmVeibw4gJ9(QHpvglEIGyV8X4XpYOoLOwrMbwjRm2sJ6KIhors5mVEnJ8CMXhxlLirR1ighqWAuKVcM(jsGixiNrDsXdNiPCMxJ5LajWc340prglEIGyV8X4XpYOoLOwrMbwjRm2sJmDfzuVFI8AgHZzgFCTuIeTwJyCabRrPqnAeO6621O3H3JarUqoJ6KIhors5mVgZlbsGfUrvx3Ug9o8Emw8ebXE5JXJFKrDkrTImdSswzSLgz6kYi21TRrFiDEpEntUoZ4JRLsKO1AeJdiynAuNu8WjskN51yEjqcSWnkrJIMNmw8ebXE5JXJFKrDkrTImdSswzSLgz6kYOwAu08KxZ88oZ4JRLsKO1AeJdiynAuNu8WjskN51yEjqcSWncUypxVa(9(e4Q9Y18UfO3Co8QLiJfprqSx(y84hzuNsuRiZaRKvgBPrMUImw8I9C9c4NxZiZzgFCTuIeTwJyCabRrJ6KIhors5mVgZlbsGfUXfuJg1RMWbUXINii2lFmE8JmQtjQvKzGvYkJT0itxrgZa1Or4vFOCeoW9AgHPZm(4APejATgX4acwJsHA0iyb1Or9QjCGlim4dvVpuKxjXFd4GBvcIHZq3(HK)hsEg1jfpCIKYzEnMxcKalCJTQqx1hPE1m0vh4glEIGyV8X4XpYOoLOwrMbwjRm2sJmDfzmVQqx1hj8Qpuog6QdCVMrUDMXhxlLirR1ighqWAC7eDRGu41Zl4ubGPxa)eqxlLiXpu9(qrELe)nGdUvjigodD7hs(FOCnQtkE4ejLZ8AmVeibw4gR48tdyiJfprqSx(y84hzuNsuRiZaRKvgBPrMUImkm48tdyiVMHT0zgFCTuIeTwJyCabRXyHEQrQxnthxa)60hsoe6FiycKLRX8sGeyHBuAc3o9QsTQGXINii2lFmE8JmY0vKrTt42PpeMAvbJ6uIAfzgyLSYylnQtTi8mqfz8zFiycKL7hsU(qXc9uJuVAMoUa(1Ppu9)q50hAOyHEQrgfsb60PweUrvCabRrDsXdNiPCMxVMHL1zgFCTuIeTwJyCabRXiVsI)gWb3QeedNHU9dj)puUg1jfpCIKYzEnMxcKalCJQcdjAS4jcI9YhJh)iJ6uIAfzgyLSYylnY0vKrSWqIEndlmNz8X1sjs0AnIXbeSgJ8kj(BahCRsqmCg62pKC8HeUpu9(qp7dnKMHufAPe9HKt58djYxbdiqqqvyAbbjanFi5)HcOrbulD7BvyAbbjanFO6BuNu8WjskN51yEjqcSWnoGaJfprqSx(y84hzuNsuRiZaRKvgBPrMUImQdc861igqrqNa1Pxa)mdBP88Ad]] )

        storeDefault( [[IV Feral: AOE]], 'actionLists', 20171114.165509, [[deeSiaqicv1LuvInPQQrrL6uujRIqvELQc3cfj7sLmmuvhtIwMk1ZuvzAQkQRHkzBOivFtfACeQW5ubSocv08qfCpvLAFekhef1cjKhQQitKqLCruP2OkqojQs3efXof0pjuPwQQ4PKMQe2QkqTxWFvrdwXHLAXe8yHMmkDzOnJcFMkA0u0Pr8AuHMTKUnf2nL(nvnCvPLJ0ZjA6IUUaBhvX3vbnEvL05PcRhfPmFur7xPHsOaunsjVjOGkUqgDqnbrGg2giO8EW7CqiTRIZDywCZnOpyfBjcH38lpwwwEFvExEGFCb6d2SokigiOumA2uN4oI3oU35(6ix7Wu7enBQtuEYG2XK4TDDhxGYCmjERekGWsOauUTTqfzbrGYK(ReJaJIM6etjO)avJuYBcA2uNyELed8m9NSeChX(EhwuiGbJlk59InG2jXB35l78BN)7e9gc(ZxpXMYRyaLI2CNV3HRD(VJ7De)DYUI28s2cin9(08cTTqfz3Hto3jBQtmVmXUMMNVXChX(ENBU2X1o)3HImOO0SfQiOmlqQK0bOuYlO8AzjXo9uqTElcAyBGG(qE3X9b(WfOFYrSIfn1jMsqeOpyfBjcH38lpwYhu10Fit8SegeKkbrG(GsFanIsOasiHWBOauUTTqfzbrGQrk5nbn6ne8NVEInLxXakfT5oFVdx78Fh37Kn1jMxjXapt)jlb3Hd7WIcbmyCrjVxSb0ojE7oFzNF7WjN74EhwuiGbJlk59k4DN)74ENSROnVKTastVpnVqBlur2D4KZDYM6eZltSRP55Bm3Hd7CZ1oU2X1oCY5oI)oSOqadgxuY7ffzqrPzluXDCb6dk9b0ikHcibLzbsLKoaLbs9rIpqEkqseuETSKyNEkOwVfb9bRylri8MF5Xs(Gg2giOhes9rIpqUJisI74(aF4csi8huak32wOISGiqzs)vIrGrrtDIPe0FGQrk5nbTJjHh8eTObbL7i2oL78FNoMeEWt0IgeuUdh25Z78FhkYGIsZwOIGYSaPsshGsBoIGYRLLe70tb16TiOHTbc6tZrCh33m1pxG(jhXkw0uNykbrG(GvSLieEZV8yjFqvt)HmXZsyqqQeeb6dk9b0ikHcib9qt0(GnRdq7G0dje(zOauUTTqfzbrGQrk5nbTJjHh8eTObbL7i2oL78Fh370XKWdEY6ZR0K2sZD4WoDmj8GNOfniOCho5ChkYGIsZwOI74c0hu6dOrucfqckZcKkjDaAAsBPjO8AzjXo9uqTElc6dwXwIq4n)YJL8bnSnqqlmPT0Ch33F4csiKlOauUTTqfzbrGQrk5nbTJjHh8eTObbL789o378FNOztDIYtg0oMeVTR7i2o3xh5cuMfivs6aubAq21tzTLMGYRLLe70tb16TiOHTbcQiAq21D0Aln3X99hUa9bRylri8MF5Xs(G(GsFanIsOasqFWM1rbXabLIrZM6e3r82X9o3xh5AhMANOztDIYtg0oMeVTR74c0dnr7d2SoavgPK3esiKPdfGYTTfQilicunsjVjODmj8GNOfniOCNV35EN)7e9gc(ZxpXMYRyaLI2ChoSdxG(GsFanIsOasqzwGujPdqLMuKfuETSKyNEkOwVfb9bRylri8MF5Xs(Gg2giOQjfz3X9TliHWJqbOCBBHkYcIaLj9xjgbgfn1jMsq)bQgPK3e0oMeEWt0IgeuUJy78BN)7Kn1jMxjXapt)jlb3rSDyrHagmUOnhXl2aANeVDNVSZ9o)3HImOO0SfQiOmlqQK0bO0MJiO8AzjXo9uqTElcAyBGG(0Ce3X9N)WfOFYrSIfn1jMsqeOpyfBjcH38lpwYhu10Fit8SegeKkbrG(GsFanIsOasiHqXbuak32wOISGiq1iL8MG2XKWdEIw0GGYDeBNBqFqPpGgrjuajOmlqQK0bOc0GSRNYAlnbLxllj2PNcQ1BrqFWk2secV5xESKpOHTbcQiAq21D0Aln3X9VpCbjeEaOauUTTqfzbrGQrk5nbTJjHh8eTObbL7i2o3G(GsFanIsOasqzwGujPdqLhsErq51YsID6PGA9we0hSITeHWB(Lhl5dAyBGGQhsEXDC)7dxqcjO6lgjDLW06K4Tqyj)Fqcaa]] )

        storeDefault( [[IV Feral: Cooldowns]], 'actionLists', 20171114.165509, [[dKJOdaGAsPQ1dsPDrfVwPK9PukZwI5tQQBcsLBRuTtqTxXUb2psggL63qEojdLucdgPgoioOsXLjoMQ6CKs0cPOwQQ0IPWYv5HKsQNI6XkzDKsPjskftLknzenDPUii5QGu8msLUUK2ivf2kvfTzeomuFJQQtRyAKsY3jvzEKkAzKIrtkv(SQ4KuKBrQW1OQ05PK)sv2MsP6tGu15h3WW4DjSjFsr7d5WfTLIwRrOcjspGkmdrwdUmqlUheiWFBDd)kfbRKaRX(7)))AC(A(APU(gMx3aPdhEZQheqf3a)JByOayJIqgZH51nq6WleQqI0d40ZJCkpI6z5CYoEakkADsrRRnfToOOnQeeo98iNYJOEwoK1d3dcqrRV(u0gvccNEEKt5ruplNkKWVIcvVLOIB6WBmMY0wHhWcFaCpiG3wd4Xdr41AN4P9vWtrcBcqolCJUWaeqc)kfbRKaRX(7)BhggVlHnbw4dG7bbshynXnmuaSrriJ5W86giD4fcvir6bC65roLhr9SCozhpaffToPO)(srRdkAJkbHtppYP8iQNLdz9W9Gau06RpfTrLGWPNh5uEe1ZYPcj8ROq1BjQ4Mo8gJPmTvyd5uYTvytaYzHB0fgGas4xPiyLeyn2F)F7WW4DjSz5uYTv6aRBCddfaBueYyomVUbshwaY9y5qkeZAAk6TrrVD7WVIcvVLOIB6WBmMY0wH75roLhr9ScBcqolCJUWaeqc)kfbRKaRX(7)BhggVlHDNh5GEffTpQNv6aRvXnmuaSrriJ5W86giD4WW4DjSwG6bbc)kku9wIkUPdVXyktBfgcQheiSja5SWn6cdqaj8RueSscSg7V)VDyOdrcJ3LWOcPNE4lDG9nUHHcGnkczmhMx3aPdh(vuO6TevCthEJXuM2kCvjEtl7QWMaKZc3OlmabKWVsrWkjWAS)()2HHX7syOrHnkcfTPw2vPthwBecCT0XC6ea]] )

        storeDefault( [[IV Feral: Precombat]], 'actionLists', 20171114.165509, [[detccaGEkPAtiQSle8AefZgYnru62aANkAVKDd1(bYWOk)wQHcGbdudxbhKkCmrDokbluKSurSyqwofpv1JL06OKYePKyQuPjdQPlCrfQNjsDDezJuISvkrTzfYZL4ZukMhLKUmQdR0OPu6BurNKs1Pr6AucDEa67i0YOQ(lIQwz5QpxGSUDldcSLyZISgiWay4AdeAd9pWv6IOwFdAJ1m7LwpHr8wyn99YoZ5SpHSF2cPTO(Rg6qOR7Og0gxKRMz5QpgVqigwP0F1qhc9yrmoiaH6gowuJley8cHyyqGjhiWqKgnIaeQB4yrnUqOeBLmGaBvqG91t4stYu5ICvO7aIIObG6g2gttmSv3ogMw3On64gZ6jmI3cRPVx2z2tFUaz9e2gttmSvHM(YvFmEHqmSsP)QHoe66ZfiRdqh0gRNWLMKPYf5Qq3befrda1h6G2yD7yyADJ2OJBmRNWiElSM(EzNzpDY2WZfiR3iyYtCnk0mTC1hJxiedRu6VAOdHUEcxAsMkxKRcDhquenauFW0er62XW06gTrh3ywpHr8wyn99YoZE6ZfiRdGPjIuOq3k8OLekukfsa]] )

        storeDefault( [[IV Feral: Default]], 'actionLists', 20171114.165509, [[d0ZVeaGEkLQnbHSlfLxlH0(uqEmvMnjZxbLBcrUmYTLOdRYoH0Ef7MO9tXpLKAykYVH6EsioTsdMudhfoOeCkfuDmu6Ceu1cPKwQQ0IvOLJQhkjAvukXYiK1rPyIsOAQsQjRQMUuxub(MIQNbH66eyJquBLs0MHGTtq5ZOOTjj00Ke8DcYZPQ)QkgnLW8Kq5KeQBrPuUMKKZtP6PGprqLrrPKoSPoa6vsbeBPrJmXpLngDXjeobQoaWGC7PwB)6fldk7eId8sk68uqfnXoNLLv0mwrScpIRka44lJoqGcUEXsFQdkBQdmqEJk6hRbahFz0b6TKm6Iz0Svz0iYO)4EgFzm7JfsA0iYO7JZK6z9wspn(5VKrpurmA2QmABZO7TKcuyCvBBpaxG85C9ILpQ13bel)R7AmpGelPaOxjfOAgKK4bqc)rVskGylnAKj(PSXORMbjjEGxsrNNcQOj25StbEjpwa3r(uNoaybwiKW)fHL4(yna0811vAb5kAgthurPoWa5nQOFSgaC8LrhOXmzQOzomw9Xcj9bqVskqLyS6Jfs6d8sESaUJ8PoDGcJRAB7bCNs9CUEXYh167aIL)1DnMhqILuGxsrNNcQOj25Stbqc)rVskGylnAKj(PSXOReJvFSqsF6GI4uhyG8gv0pwdao(YOdqsIZ0(SpHW622OhQigDfNc8sESaUJ8PoDGcJRAB7b6LjX9piiGBpGy5FDxJ5bKyjf4Lu05PGkAIDo7ua0RKcuVmjUW5nAKfWTNoOvi1bgiVrf9J1aGJVm6aCQ8wP3OlMrlYOTfJMP7B0dBygTTA0Ccbo5T4gvKrJiJ2HlhXpmWRS9ZCc4Cs2g9qgDfm6Hh4L8ybCh5tD6afgx122d4pHDmPho(4bel)R7AmpGelPaVKIopfurtSZzNcGELua4e2XKm6x8Xth0QsDGbYBur)yna44lJoW56vy0djPYL8g9qgnBGcJRAB7bCNs9CUEXYh167aIL)1DnMhqILua0RKcuO6bbqc)rVskGylnAKj(PSXOlu9GaVKIopfurtSZzNc8sESaUJ8PoDaWcSqiH)lclX9XAaO5RRR0cYv0ynDqRyQdmqEJk6hRbahFz0bcGELuayLmvKrxFCMuh4L8ybCh5tD6afgx122d4oL65C9ILpQ13bel)R7AmpGelPaVKIopfurtSZzNcGe(JELuaXwA0it8tzJrdRKPIsNoqXjeobQowtNaa]] )
    end

    storeDefault( [[Feral Primary]], 'displays', 20171114.165509, [[dSJZgaGEf0ljsSliK61uv1mvGMTuDtKKoSKBROoosQDsL9k2nH9Jk9tfzyq0Vv11OQsdfLgmQy4q1bLsRJijhJOoheswOuSuIulMuwofpKQYtbpgPEoLMivvmvinzIy6kDrf6Qiipdb11r0gHITsKuBgvTDe6JkGpdLMgeIVtvgjsILbbJgfJhbojsCliuDAsopP6YQSwiu8niu6ih0a0f(QEbMxSWQ3VatecDqkUXaBzWEllr2OfWucSNpMJ2)0eqRRgoCG(7fTa6t882B9v4R6f24qgGGjEE7T(k8v9cBCidqn5rEsOq)cqn8IdrqgWY8ETKMIIG)JwaQjpYtIVcFvVWMMa6t882Brld2BTXHmGL59ap1sZ0oMMaemXZBVfTmyV1ghYak6xa4fTsGno)gOinffb)JQJFb0i55dqWepV9wP0yJtoabXHmGL59qld2BTPjG)ATcAM3eaDIvAkdqf0akHefDTVPvqZ8MastzaQGgGUWx1lAf0mVjqZek6evda4hTQ6QH1QErCYijCalZ7bOPja1Kh55hL5Ox1lcinLbOcAab5mf6xyJdrcyXVEhtVSm(((BcAGko5aAXjhaBCYbmXjNnGL598v4R6f2OfGGjEE7TTKMkoKbkstHQJFb0i55dmxe0sUFCidO1vdhoq)9A79OfO64mfW8ESehJtoq1XzkF)SwTSehJtoGFo(ISVPjq19kDllr20eGOYQ0uD1QJQJFb0cqx4R6fTDfwraFJo0rPdirzX7LoQo(fOcykb2dvh)cuAQUA1duKMIQkXLMa(RH5flOgEXjJqGQJZuOLb7TSezJtoG56b8n6qhLoGf)6Dm9YYeTavhNPqld2BzjogNCaQjpYtcfHefDTVXMMa(ECDUCq)ayot15YPDAmGKJVi7Bl7Gba1SpUCWCMQlvC5i54lY(gyld2BX8Ifw9(fyIqOdsXngG)fBawuUCGsy5YXvgZ7fyld2BBf0mVjqZek6evLMYaubnGL59Aj3pnbQoot129kDllr24KdOOFbI5)54K9BaCJAUm6yEXcQHxCYiea3C0)SwTTSdgauZ(4YbZzQUuXLdU5O)zTAdmReTJXr4aZfbTJXHmaUrnxgDk0VaudV4qeKb2YG9wwIJrla1Kh512vyfZNydqhWY8Es501ucjkbwBAcq)ZA1YsCmAbOl8v9cmVyb1WlozecOpXZBVLIqIIU23yJdza9jEE7TTKMkoKbiyIN3ElfHefDTVXghYawM3JIqIIU23yttGzLOLC)4qgO6ELULL4yAcyzEpwIJPjGL59Ahtta6FwRwwISrlqrAka)6Dk(joKb2YG9wmVydWIYLduclxoUYyEVa(RH5flS69lWeHqhKIBmWSsaOXHmWwgS3I5flOgEXjJqGQJZuTDVs3YsCmo5a0f(QEbMxSbyr5YbkHLlhxzmVxGQJZu((zTAzjYgNCGrrP1pjPjGvnJ3V2PX4qia1KkA)LALfw9(fOc4VgMxSbyr5YbkHLlhxzmVxalZ7bEQLMPLC)0eOinvRGM5nbAMqrNO6GJyqdi91VYEXHaszeRSSmciAzeKrue2VbSmVhlr20eyUiaqJtoG(epV9wP0yJdXLduDCMcyEpwISXjhGAYJ8KG5flOgEXjJqa94qCeimYautEKNeP0yttaxnFbWCMQZLdRrnxg9afPPiKqTbW7L(zYMaa]] )

    storeDefault( [[Guardian Primary]], 'displays', 20171114.165509, [[dSJPgaGEPKxIeAxaK8AjPMPKKzlv3ej4XO0Tb03ai1oj1Ef7gv7xH8tfzykQFdzAirgksnyPudhrhukomvhJeNdGslusTujHftslNspuH6PQwgawNKinrKOMkuMmbMUsxubxfb5YGUouTrcARsIyZeA7i0hrsonrFgiFxIgjcQNjjQrJIXJaNeOUfavxdG48s45uSwakoosQJsWYzDYvI4cr89BrhMpriSQaRhYzDYvI4cr89YwWOvai36CqWXmq2QtDUAx2QfvDuzuZlMefnWDStUse3e9CobtIIg4o2jxjIBIEoN0kb62cWSi(LTGrtP5CddQSb36G5IOOMtnoehkyStUse3K68IjrrdCXCli4AIEo3WGkFPCzzAgsDUHbv2GVOuNd0j4yrRKVUfeCB4SmiBE9eg2efQamveglViAahGkpNtq0Z5ggujMBbbxtQZRwTHZYGS5yt0vaMkcJLl5cKS(ISnCwgKnVcWurySCwNCLiEdNLbzZRNWWMOq(jHSsVlB5ReXJwzMs5ggu5XsDo14qCiLLwi7kr88katfHXY54abZI4MOPuUHe27c7UHzmQJSbl3JwjxnALCqrRKBJwjBUHbvo2jxjIBIAobtIIg42GB9ONZDCRJvqcZvXffZb6e0GVOONZv7YwTOQJkB69OM7Dsg)mOsAIdrRK7DsgFmcOQV0ehIwjNYqrhVVPo37LEHHMiDQZjknsvzxUfyfKWC1CwNCLiEtxcINpEqJnurUaPHS7fyfKWCp36CqqScsyURk7YTi3XTofKCyQZRwviIVx2cgTca5ENKXXCli4stKoALClSNpEqJnurUHe27c7UHjQ5ENKXXCli4stCiALCQXH4qbG5cKS(ISMuNRDGWCQWDRaPZh1M2kb62I81TGGRqeF)w0H5tecRkW6H8IjrrdCPyTjAaxjNGjrrdCPyTjALCddQ8LYLLPbFrPo37KmEtV0lm0ePJwjNGjrrdCXCli4AIEoN0kb62cHi(Ezly0kaKtAHSiGQ(2qxv0Z5swehWGqaJwbqYb6e0me9CoqjVzi6kNVUfeCPjoe1CreFZPXg1(o3mQT2TwuzEfWo0nWObywbqROOaaGsbafaBLbKCQXH4WMUeehiKV5S5SiGQ(stCiQ5ftIIg4cMlqY6lYAIEoVysu0a3gCRh9CobtIIg4cMlqY6lYAIEo3WGkbZfiz9fznPohOK3GVOONZ9EPxyOjoK6CddQKM4qQZnmOYMHuNZIaQ6lnr6OMVUfeCfI4Bon2O235MrT1U1IkZDCRFsyVdMYrpNxTQqeF)w0H5tecRkW6HCGs(XIEoFDli4keX3lBbJwbGCVtY4n9sVWqtCiALCwNCLiUqeFZPXg1(o3mQT2TwuzU3jz8XiGQ(stKoAL8bUR2HcsDUrcKSdBMgIgGCQXLSvxjsZ3Iom3ZRwviIV50yJAFNBg1w7wlQmxYI4N0zLCqrdi5RBbbxAI0rn3XTEdNLbzZRNWWMOqvdcXYnmOsAI0PoNACiouaywe)YwWOP0CUHbvsryHQKlqYbzsDU3jz8ZGkPjshTso14qCOaHi(Ezly0kaK74whmxeHvqcZvXffZPghIdfqXAtQZfafD8(2qxvo4kzuBQWDRaPZR0rTPmu0X7BUJBDcXLBoz3lG2Sja]] )

    storeDefault( [[Feral AOE]], 'displays', 20171114.165509, [[dWJYgaGEPuVejLDbjKxlLyMsrnBP6WsUjcQJJQ42kQXbjIDsL9k2nr7Na)uHggu63Q6YQmuuzWOQgouDqQYPj1Xi05GeQfQilfvPfJulNIhkfEk4XOyDiinrPiMketMGMUsxubxfjvpdsW1r0gHITcjkBMeBhH(OusFgsnnPi9DQQrIK0YGKgnknEe4KiXTqqCnKeNNKEoLwlKO6BqI0rmibyk8v)smVCHvTFbgPosZuCdb2YG(woICHoGPKOVgShtlzkaDx3UDR93p0buhvuS32OWx9lTXHnabJkk2BBu4R(L24WgGhYJ8esH5LGU9fxtXgWY((EKMIIu5dDaEipYtyJcF1V0MPaQJkk2Brkd6BTXHnGL99bF9YW6ne6aemQOyVfPmOV1gh2aZfbasCIb2YG(wpjd7BcmnIGmsyEP0kvrcOghHiIsOsacIdBal77Jug03AZuGwO9KmSVjaYihVuALQib0sHAMAFJNKH9nb4LsRufjatHV6x6jzyFtGPreKrchOXJRkGpYhaZzQUa(EJdbSSVpGKPa8qEKxt0MJz1VmaVuALQibKKZuyEPnUMgWIF9oMEzzB893eKavCIbmXjgaDCIbOJtmBal773OWx9lTHoabJkk2B9invCyduKMcrf)cqtQOeyUiWJC)4WgGURB3U1(7717Hoq1XzlG995ioeNyGQJZwn(z6A5ioeNyGMCkfzFZuGQ7xQwoICzkarTvtR76vfrf)cqhGPWx9l96A0YangCid8gqO2I3lvev8latatjrFiQ4xGIw31RAGI0uewlVmfOfAmVCbD7loruduDC2cPmOVLJixCIbmxpqJbhYaVbS4xVJPxw2qhO64SfszqFlhXH4edWd5rEcPifQzQ9n2mfaWpgD11TRv)Y4eXIcbC18faZzQUa(EJdb2YG(wmVCHvTFbgPosZuCdbiyurXEl1MSXjgWY((EK7h6aAMxc4fJwIooQeO64SLx3VuTCe5Itmq1XzlG995iYfNyaCJEUmQyE5c62xCIOga3Cm)mDTECnha0ZneWhZzQoHkGpU5y(z6AdOoQOyVLAt24ieXaZfbEdXHnWSw6nehkeyld6B5ioe6aw23NJixMcyzFFQDQ0APqTeTntb496xzV4qfRikvuuevuKiQIOyuGkbkst5jzyFtGPreKrc38agKaw23h81ldRh5(zkql0yE5gGdraFOKwb8DLX8(b4HuZ0cktBHvTFbOdyzFFksHAMAFJntbM1spY9JdBGQ7xQwoIdzkGL999gcDal77ZrCitby(z6A5iYf6avhNTA8Z01YrKloXaBzqFlMxUb4qeWhkPvaFxzmVFGQJZwED)s1YrCioXaZAjGeh2aBzqFlMxUGU9fNiQbAHgZlxyv7xGrQJ0mf3qaMcF1VeZl3aCic4dL0kGVRmM3pqrAka)6DknjoSbgKfD)eMPaw9mE)8ghId1aemQOyVLIuOMP23yJdBa1rff7TEKMkoSbuhvuS3srkuZu7BSXHnatHV6xI5LlOBFXjIAaMFMUwoIdHoapKh5511OLZNCdWea3ONlJkfMxc62xCnfBaLxUb4qeWhkPvaFxzmVFanZlr5)phNivcWd5rEcX8Yf0TV4ernqrAkksLhrf)cqtQOeGhYJ8esTjBMci8ukY(6X1Caqp3qaFmNP6eQa(cpLISVbkstrDPEdG3l1ZKnb]] )


end

