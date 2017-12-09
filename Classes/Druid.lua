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


local tinsert, tsort = table.insert, table.sort


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
                    return state.buff.ashamanes_energy.applied + floor( state.query_time - state.buff.ashamanes_energy.applied )
                end,

                interval = 1,
                value = function () return state.artifact.ashamanes_energy.rank * 5 end,
            },

            t20_rip_tick = {
                resource = 'energy',

                spec = 'feral',
                set_bonus = 'tier20_2pc',
                
                aura = 'rip',
                debuff = true,

                last = function ()
                    return state.debuff.rip.applied + floor( state.query_time - state.debuff.rip.applied )
                end,

                interval = function () return state.talent.jagged_wounds.enabled and 1.6 or 2 end,
                value = 1
            }
        } )


        setPotion( "prolonged_power" )
        setRole( state.spec.guardian and "tank" or "attack" )


        addHook( 'specializationChanged', function ()
            setPotion( 'prolonged_power' )
            setRole( state.spec.guardian and "tank" or "attack" )
            if state.spec.guardian then addTalent( "incarnation", 102558 ) -- 21706: Guardian
            else addTalent( "incarnation", 102543 ) end -- 21705: Feral
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
        addAura( "jungle_stalker", 252071, "duration", 30 )
        addAura( "lightning_reflexes", 231065 )
        addAura( "mass_entanglement", 102359, "duration", 30 )
        addAura( "moonkin_form", 197625 )
        addAura( "moonfire", 155625, "duration", 16 )
        addAura( "moonfire_cat", 164812, "duration", 16 )
        
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
            class.auras[ 102547 ] = class.auras.prowl

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
                return ( talent.jagged_wounds.enabled and x * 0.8333 or x ) + ( set_bonus.tier20_4pc == 1 and 4 or 0 )
            end )
            modifyAura( "rip", "tick_time", function( x )
                return talent.jagged_wounds.enabled and x * 0.8333 or x
            end )
        
        addAura( "savage_roar", 52610, "duration", 36 )
        addAura( "scent_of_blood", 210663, "duration", 4 )
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

        addGearSet( 'tier21', 152127, 152129, 152125, 152124, 152126, 152128 )
            addAura( 'apex_predator', 252752, "duration", 25 ) -- T21 Feral 4pc Bonus.

        addGearSet( 'tier20', 147136, 147138, 147134, 147133, 147135, 147137 )
        addGearSet( 'tier19', 138330, 138336, 138366, 138324, 138327, 138333 )
        addGearSet( 'class', 139726, 139728, 139723, 139730, 139725, 139729, 139727, 139724 )

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

        local function calculate_multiplier( spellID )

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

        addMetaFunction( 'state', 'persistent_multiplier', function ()
            local mult = 1

            if not this_action then return mult end

            if tf_spells[ this_action ] and buff.tigers_fury.up then mult = mult * 1.15 end
            if bt_spells[ this_action ] and buff.bloodtalons.up then mult = mult * 1.20 end
            if mc_spells[ this_action ] and buff.clearcasting.up then mult = mult * 1.20 end
            if pr_spells[ this_action ] and ( buff.incarnation.up or buff.prowl.up or buff.shadowmeld.up or state.query_time - stealth_dropped < 0.2 ) then mult = mult * 2.00 end

            return mult
        end )

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
                        ns.saveDebuffModifier( spellID, calculate_multiplier( spellID ) )
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
            desc = "If |cFF00FF00true|r, Regrowth will only be usable in Cat Form when it can be cast without shifting out of form.",
            width = "full"
        } )

        addSetting( 'regrowth_instant_desc', nil, {
            name = "When checked, |cFFFFD100Regrowth: Instant Only|r will only allow the addon to recommend Regrowth while in Cat Form " ..
                "when it is instant cast and will not cause you to unshift.\n",
            type = "description",
            width = "full"
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

        addSetting( "brutal_charges_desc", nil, {
            name = "By telling the addon to save a number of Brutal Slash charges for AOE situations, you can prevent scenarios where you've spent all " ..
                "your Brutal Slash charges immediately before a new wave of enemies appears.  The default is to save 2 charges, meaning your 3rd charge " ..
                "can be spent when there is only 1 target.  If set to 0, no charges will be saved.  If set to 3, then Brutal Slash will not be recommended " ..
                "unless there are multiple enemies detected.  You may want to adjust this setting for specific fights.\n",
            type = "description",
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
            ready = function ()
                if active_enemies == 1 and settings.brutal_charges == 3 then return 3600 end
                if active_enemies > 1 or settings.brutal_charges == 0 then return 0 end

                -- We need time to generate 1 charge more than our settings.brutal_charges value.
                return ( 1 + settings.brutal_charges - cooldown.brutal_slash.charges_fractional ) * recharge
            end,
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
            if buff.scent_of_blood.up then x = x + buff.scent_of_blood.v1 end
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
            usable = function () return combo_points.current > 0 or buff.apex_predator.up end,
        } )

        modifyAbility( "ferocious_bite", "spend", function( x )
            if buff.apex_predator.up then return 0 end
            if args.max_energy and args.max_energy == 1 then
                x = x + 25
            end
            return x * ( ( buff.berserk.up or buff.incarnation.up ) and 0.5 or 1 )
        end )

        addHandler( "ferocious_bite", function ()
            if equipped.behemoth_headdress and buff.tigers_fury.up then buff.tigers_fury.expires = buff.tigers_fury.expires + min( 5, combo_points.current ) * 0.5 end
            if buff.apex_predator.down then spend( min( 5, combo_points.current ), "combo_points" ) end
            removeBuff( 'apex_predator' )
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

        class.abilities.incarnation_king_of_the_jungle = class.abilities.incarnation
        class.abilities.incarnation_guardian_of_ursoc = class.abilities.incarnation

        modifyAbility( "incarnation", "id", function( x )
            if spec.guardian then return 102558 end
            return x
        end )

        addHandler( "incarnation", function ()
            if spec.feral then
                applyBuff( "incarnation", 30 )
                applyBuff( 'jungle_stalker', 30 )
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
                    if buff.cat_form.up then return 30, "energy" end
                end
                if buff.bear_form.up then return 0, "rage" end
                return 0, "mana"
            end,
            cast = 0,
            gcdType = "spell",
            cooldown = 0,
            min_range = 0,
            max_range = 40,
            aura = 'moonfire',
            cycle = 'moonfire',
            usable = function () return ( talent.lunar_inspiration.enabled and buff.cat_form.up ) or ( buff.cat_form.down and buff.bear_form.down ) end,
            recheck = function () return dot.moonfire_cat.remains - dot.moonfire_cat.duration * 0.3, dot.moonfire_cat.remains end,
        } )

        class.abilities.moonfire_cat = class.abilities.moonfire

        modifyAbility( 'moonfire', 'aura', function ( x )
            if talent.lunar_inspiration.enabled then return "moonfire_cat" end
            return x
        end )

        modifyAbility( "moonfire", "cycle", function( x )
            if talent.lunar_inspiration.enabled then return "moonfire_cat" end
            return x
        end )

        addHandler( "moonfire", function ()
            if talent.lunar_inspiration.enabled and buff.cat_form.up then
                gain( 1, "combo_points" )
                applyDebuff( "target", "moonfire_cat" )
            else
                applyDebuff( "target", "moonfire" )
            end
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
            usable = function () return ( time == 0 or boss ) and not buff.prowl.up end,
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
            --[[ ready = function ()
                local refresh_time = debuff.rake.up and ( debuff.rake.remains - ( debuff.rake.duration * 0.3 ) ) or 0
                local energy_time = energy.current < action.rake.cost and energy[ "time_to" .. action.rake.cost ] or 0
                return max( 0, energy_time, refresh_time )
            end, ]]
            cast = 0,
            gcdType = "spell",
            cooldown = 0,
            min_range = 0,
            max_range = 0,
            cycle = 'rake',
            aura = 'rake',
            form = 'cat_form',
            usable = function () return buff.cat_form.up end,
            recheck = function () return dot.rake.remains - dot.rake.duration * 0.3, dot.rake.remains end,
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
            recheck = function () return dot.rip.remains - dot.rip.duration * 0.3, dot.rip.remains end,
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
            notalent = 'brutal_slash'
        }, 213771, 106785 )

        class.abilities.swipe_cat  = class.abilities.swipe
        class.abilities.swipe_bear = class.abilities.swipe

        --[[ modifyAbility( "swipe", "id", function( x )
            if buff.bear_form.up then return 213771
            elseif buff.cat_form.up then return 106785 end
            return x
        end ) ]]

        modifyAbility( "swipe", "spend", function( x )
            if buff.cat_form.up then
                x = 40
                if buff.clearcasting.up then return 0 end
                if buff.scent_of_blood.up then x = x - ( buff.scent_of_blood.v1 or 0 ) end
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
                removeBuff( "scent_of_blood" )
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
            recheck = function () return dot.thrash_cat.remains - dot.thrash_cat.duration * 0.3, dot.thrash_cat.remains end,
        }, 77758, 106830 )

        class.abilities.thrash_cat  = class.abilities.thrash
        class.abilities.thrash_bear = class.abilities.thrash

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

                if artifact.scent_of_blood.enabled then applyBuff( "scent_of_blood", 4, 1, -2 * active_enemies ) end

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


    end


    storeDefault( [[SimC Feral: default]], 'actionLists', 20171207.215448, [[dqKMmaqijfTiufQnHQQ(eQIyuKsYPiLOvjuP6vOkOMLqLYTqvi2fjmmjCmsAzsQEMKcttOsUMqfBJucFtfmoufPZHQGSouvX9KuQ9HQkDqjPfkjEOQIjIQO6IOQSrjLCsvLwjQc0lrvaZevH0nfYovyPkQNImvv0wrvAVu)vfAWQ0HfTyu5XkzYs1LbBMu8zjQrRiNMOxtIMTuUTsTBu(nudxv1XrvuwoHNly6qUoPA7cLVlu15LiRNusnFsP2VQSv9PjEoOj1BixX0i3GjsU)8U1cezJFE3oOj1Bit0pSKztQ1jsIzEOwudtZqdYa4r9c1dQQ15Pku1IAexfhmndzV0PCdMqYLsjR87MS(7QvVBHII48U8WVRa2PKfExEK3vRE3UUirsm7DJ7VBHIA8UA57QLVlw8UfMQUqsml4tpu9Pj(yjxd6UIPQCYMevYuqPERDKldtM(Y6YvIWctmmdmfH78MIrUbtMg5gmrk1BT3TsgMmndnidGh1lupOwyAgcyDXcc(0itFMGLYiCmydmK5mfH7JCdMmYJ6(0eFSKRbDxXeTeYFKjGNPl))HUIMUgn5X4f5)VKv(D5)7Q(UAR97wyQkNSjrLmflfYKRbM(Y6YvIWctmmdmfH78MIrUbt6b4iAsKHjtJCdMiewaVlVzthmvvuoyILBO26b4iAsKHP4wSSPd1g4z6Y)FOROPRrtEmEr()lzL5VQ2AxyAgAqgapQxOEqTW0meW6Ife8PrM(mblLr4yWgyiZzKh1WNM4JLCnO7kMOLq(JmLlKmgCSJrkeY)3LFF3I3vBTFxKCdVl)(UQXXuvoztIkzsOZoMlKeZo2KbKPVSUCLiSWedZatr4(i3GjsU)8U1cezJFE3GKvUbVlkfLbKPiCN3umYnyY0NjyPmchd2adzotJCdMM1zVB1fsIzVlpQmGmvvuoyILBO28ysU)8U1cezJFE3GKvUbVlkfLbep20m0GmaEuVq9GAHPziG1fli4tJmrt44JWDPgjicUIjcjKl0NjyP0vmYJ4YNM4JLCnO7kMOLq(JmvZ3fjxkLSYVR2A)UC6A0O4xGJVPq))D1w73LtxJgfHPSJJFdTUc9Ftv5KnjQKjrQem9L1LReHfMyygykc35nfJCdMmnYnyAovcMMHgKbWJ6fQhulmndbSUybbFAKPptWszeogSbgYCMIW9rUbtg5rC8Pj(yjxd6UIjAjK)it18D501OrXkrh1GfBf6)MQYjBsujt9mmz6lRlxjclmXWmWueUZBkg5gmzAKBWeppdtMMHgKbWJ6fQhulmndbSUybbFAKPptWszeogSbgYCMIW9rUbtg5Hw4tt8XsUg0Dft0si)rMqzdyifnDwkokzHFPirsmtbWsUg0Fx()U18DrYLsjRSPQCYMevY0gJzAKcW0xwxUsewyIHzGPiCN3umYnyY0i3GPimMPrkatZqdYa4r9c1dQfMMHawxSGGpnY0NjyPmchd2adzotr4(i3GjJ84GpnXhl5Aq3vmrlH8hzQMVlNUgnkczSSmCuGtHc9Ftv5KnjQKPqglldhf4uy6lRlxjclmXWmWueUZBkg5gmzAKBWeLXYYW7oJtHPzObza8OEH6b1ctZqaRlwqWNgz6ZeSugHJbBGHmNPiCFKBWKrEWt9Pj(yjxd6UIPQCYMevYehicGqPPVSUCLiSWedZatr4oVPyKBWKPrUbtvaraeknndnidGh1lupOwyAgcyDXcc(0itFMGLYiCmydmK5mfH7JCdMmYdEiFAIpwY1GURyQkNSjrLmjzRuWsKeZm9L1LReHfMyygykc35nfJCdMmnYny6lBLcwIKyg)8U8asw53fR5DrtW7YdQZk3atZqdYa4r9c1dQfMMHawxSGGpnY0NjyPmchd2adzotr4(i3GjJ8qTWNM4JLCnO7kMQYjBsujtizzqeoQrxuY0xwxUsewyIHzGPiCN3umYnyY0i3GPtzzqWtcVBT0fLmndnidGh1lupOwyAgcyDXcc(0itFMGLYiCmydmK5mfH7JCdMmYdvvFAIpwY1GURyQkNSjrLmLHPCNmiCuJayADjtFzD5kryHjgMbMIWDEtXi3GjtJCdMQgMYDYaEs4DRLayADjtZqdYa4r9c1dQfMMHawxSGGpnY0NjyPmchd2adzotr4(i3GjJ8qTUpnXhl5Aq3vmrlH8hzsRExu2agsri5abcJrtkawY1G(7QT2VlNUgnk(fqpryrPJH4LAqmieuO))UA57Y)3fLnGHuW1W4okBywqbWsUg0Fx()UC6A0OGRHXDu2WSGIooE27Y)3DH3C4J)yjdfuS0fcGHE3A)UXXuvoztIkzsaLf44rtM(Y6YvIWctmmdmfH78MIrUbtMg5gmndLf44rtMMHgKbWJ6fQhulmndbSUybbFAKPptWszeogSbgYCMIW9rUbtg5HAn8Pj(yjxd6UIjAjK)itl8MdF8hlzOGILUqam07w73noMQYjBsujtc5VPVSUCLiSWedZatr4oVPyKBWKPrUbtZYFtZqdYa4r9c1dQfMMHawxSGGpnY0NjyPmchd2adzotr4(i3GjJ8qnU8Pj(yjxd6UIjAjK)it18DrYLsjR87Y)3nwkKjxduOhGJOjrgMEx(9DlmvLt2KOsMqtImmz6lRlxjclmXWmWueUZBkg5gmzAKBW05KidtMMHgKbWJ6fQhulmndbSUybbFAKPptWszeogSbgYCMIW9rUbtg5HAC8Pj(yjxd6UIPrUbtu8YFW0meW6Ife8PrMQYjBsujtH4L)GPVSUCLiSWedZatZqdYa4r9c1dQfMOLq(JmLlKmgCeyWwcH3LFFxvJ8qvl8Pj(yjxd6UIPQCYMevYuysaDtFzD5kryHjgMbMIWDEtXi3GjtJCdMOjb0nndnidGh1lupOwyAgcyDXcc(0itFMGLYiCmydmK5mfH7JCdMmYit0si)rMmYga]] )

    storeDefault( [[SimC Feral: precombat]], 'actionLists', 20171207.215448, [[diZ0caGELcTlcX2KsXSPYnjLBtv7Ks7fTBI2pHYWivJtkvgQsLgmH0Wjjhuk5yeSqH0sfQfdvlNIhscpv1YGuRtPGjkLstvkMSunDfxes6YGRleBuPKTcrTzLsTDi43IEouMMsrFhI8yL8zLkgnj1HLCsiX3irNwW5vQ6zeQEne6VsPQPaB4TLh4FWRqmr3cmLBdIjQkdSspEn8Tf2UI4ggLpgCqHb0IwxqPGa62jIqBeFtDL8FzcQgE(wRjKsm2qRaB4rvw4oOZO8FzcQg(PCGCeb3LzFkxkXebKfUd68TWdUWSN3a7ysKg18Oi7HvnPHxMsGxl7ixgB5bEEB5b(yyhtI0OMpgCqHb0IwxqPGoFmGLrmlaJnC4vOgwiQLiaEqoeNxl72Yd8COfnB4rvw4oOZO8TWdUWSNxLjrYXJIShw1KgEzkbETSJCzSLh45TLh431Ki54JbhuyaTO1fukOZhdyzeZcWydhEfQHfIAjcGhKdX51YUT8aphAfNn8OklCh0zu(w4bxy2ZVQP9BNgppkYEyvtA4LPe41YoYLXwEGN3wEGxrnIj6wPXZhdoOWaArRlOuqNpgWYiMfGXgo8kudle1seapihIZRLDB5bEo0UjB4rvw4oOZO8TWdUWSNxvoHuYJIShw1KgEzkbETSJCzSLh45TLh43nNqk5JbhuyaTO1fukOZhdyzeZcWydhEfQHfIAjcGhKdX51YUT8apho8xfScLlSXAcPKwbDX5qc]] )

    storeDefault( [[SimC Feral: cooldowns]], 'actionLists', 20171207.215448, [[dme0kaqiQiTirjAtOQ6tOIYOqf5uOa7IedtuDmbTmGYZOIyAIsY1qbTnGQ8nuHXjkvNtucTorPyEce3dOY(eOoikQfIc9qsIjkkPUijPncuvFuGeNevLvkqkVuGuDtfzNimurP0sjPEkXurvUQOeSvQO2R0FPsgmPoSklgrpwOjlYLH2SI6ZuHrlkonLwTaj9AbmBfUnGDR0Vv1WbYYr65u10bDDuA7uP8DQuDEuP1JkQMpkY(P4gwEveqy0EdlNFq7VLim3jvioaSIybuXObFKEJSXOJ)psV7RVswJZh7awgROgh45XsawEihHHGLDLqWZjzvohvuJxIlplawbxK6GRc0cGUGVlNKxH5i0(RV8kry5vr19ihyQmwrIuliyfNA0KSZZkXd6A(PakSGQWmPDyHCRKoFMk8TjB8GpTY(lwz6toFuIdaRuH4aWkz95ZurnoWZJLaS8qocZROg9plnI(YRWkQKbJbME3qaCHLSY0NioaSsHLaSYRIQ7roWuzSIePwqWkKSZZk2nE09G2FvOiWzxVrheJoxHHgn)gnj78SsqLDDmqxE4ncGufwqvyM0oSqUvarF3hv4Bt24bFAL9xSY0NC(OehawPcXbGvYw67(OIACGNhlby5HCeMxrn6FwAe9LxHvujdgdm9UHa4clzLPprCayLclHtkVkQUh5atLXksKAbbRGlsDWvjYsP4cn6GbNr7KCJMFJMtgD8)r6DFvGwhi17AMLYvHIaND9gDWgndnAMyYOjzNNvGwhi17AMLYvHfKrZGkmtAhwi3kKi1J0av4Bt24bFAL9xSY0NC(OehawPcXbGvyePEKgOIACGNhlby5HCeMxrn6FwAe9LxHvujdgdm9UHa4clzLPprCayLclrwvEvuDpYbMkJvKi1ccwbxK6GRscNTrl0OdgCgn4LxHzs7Wc5wbADGuVRzwk3k8TjB8GpTY(lwz6toFuIdaRuH4aWk8SoqkN5nAWNLYTIACGNhlby5HCeMxrn6FwAe9LxHvujdgdm9UHa4clzLPprCayLclbdlVkQUh5atLXkmtAhwi3kKi1J0a21rf(2KnEWNwz)fRm9jNpkXbGvQqCayfgrQhPbSRJkQXbEESeGLhYryEf1O)zPr0xEfwrLmymW07gcGlSKvM(eXbGvkSeGx5vr19ihyQmwrIuliyL4dq(Ua92f6vISukUqJgCgDUrZVrJlsDWvjYsP4cn6GbNrZW8kmtAhwi3k4GDrVlhS20TrScFBYgp4tRS)IvM(KZhL4aWkvioaSIQd2f5mVrhuyTPBJyf14appwcWYd5imVIA0)S0i6lVcROsgmgy6DdbWfwYktFI4aWkfwcokVkQUh5atLXksKAbbRGlsDWvjYsP4cn6GbNr7KCJMFJMtgD8)r6DFvGwhi17AMLYvHIaND9gDWgDidnAMyYOjzNNvGwhi17AMLYvHfKrZGkmtAhwi3k2nE09G2FRW3MSXd(0k7VyLPp58rjoaSsfIdaRW3gp6Eq7VzJrh0TRdJ(NnAyg0OdASRJbwrnoWZJLaS8qocZROg9plnI(YRWkQKbJbME3qaCHLSY0NioaSsHLi7Lxfv3JCGPYyfjsTGGvGh1bcvGwa0f8DLSOrheJg8yOrZetgnNmAOfaDbFxjlA0bXOdZEUrZVrZjJMKDEwHePEKgqHfKrZetgnj78SIDJhDpO9xfwqgndmAguHzs7Wc5wb0dT)wHVnzJh8Pv2FXktFY5JsCayLkehawjBFO93kmtD4RShacUSee9h)6atUa9UJ0SSIACGNhlby5HCeMxrn6FwAe9LxHvujdgdm9UHa4clzLPprCayfq0F8Rdm5c07oslSezXYRIQ7roWuzSIePwqWkXhG8Db6Tl0RezPuCHgDWGZObZO53O5Kr7uJgEdCHkKJ)tWB8Rxb3JCGjJMjMmAs25zfYX)j4n(1RWcYOzqfMjTdlKBLZN5aUf9UMP4Y5CRW3MSXd(0k7VyLPp58rjoaSsfIdaRWSpZbClYzEJg8P4Y5CROgh45XsawEihH5vuJ(NLgrF5vyfvYGXatVBiaUWswz6tehawPWseMxEvuDpYbMkJvKi1ccwj(aKVlqVDHELilLIl0OdIrZqJMFJgxK6GRsKLsXfA0bdoJ(Iq7Vk0laQeFp0O53OtpuHEbqfqaSdOf0WIuJoignykHgn)gnj78Sc06aPExZSuUkSGmA(nAoz0KSZZkKJ)tWB8RxHfKrZetgTtnA4nWfQqo(pbVXVEfCpYbMmAgy08B0CYODQrdVbUqf7gp6Eq7Vk4EKdmz0mXKrh)FKE3xf7gp6Eq7Vkue4SR3Od2OdZUrZaJMFJ2Pgnj78SIDJhDpO9xfwqvyM0oSqUv8zU07oaosv4Bt24bFAL9xSY0NC(OehawPcXbGvKmx6DhahPkQXbEESeGLhYryEf1O)zPr0xEfwrLmymW07gcGlSKvM(eXbGvkSeHHLxfv3JCGPYyfMjTdlKBfwp6YcraFf(2KnEWNwz)fRm9jNpkXbGvQqCayLSGhnA(GiGVIACGNhlby5HCeMxrn6FwAe9LxHvujdgdm9UHa4clzLPprCayLclSIePwqWkf2ca]] )

    storeDefault( [[SimC Feral: single target]], 'actionLists', 20171207.215448, [[diKTkaqivqSisK2KemkskNIKyvIeLxjsKULirSlvAyOshtfTmePNHimnvqDnQeTnse8nQGXrIOZjsuToerZtKW9OsyFuHCqvOfss6HsOjsfQCrrQ2ivsNuKYkjrOzsfk3evStszPKWtPmvuvBvfyVG)IQmyOoSIfJWJL0KvYLj2Se9zQuJMk60O8AeLzlQBRu7gYVLA4Iy5i9CQA6cxNuTDrsFNe14vbPZJOA9uHQMpjv7xvdNaFW0MTaMX2fFSRcDYK8XEgYDwECmu3saMLiv2Kzo(jync0o5scWCCs5ONdqvWuizz8cOrk3thopjvjVNkbsCyUoaMczwKZNTfWcwLmgY9Jh06XQ9yUxUU8XP0htL9Wq(hNsESApEPtNG1OhNYEm3ljESkpwLh30hZfSJ1G1ipWh0ob(GLoAiYYcufmRszjbyhYJj0llV1j4v209vpbSJeSmlihS6e8kB6gS0qlwDIMcgQrcyC61bdvB2cyGPnBbSIt8yxB6gmfswgVaAKY90HtUGPq8ToTkEGpeGv0PujJtNQSfuaeGXPxAZwadcqJuGpyPJgISSavbZQuwsagHEz5nH2kNV6jpwD1FmHEz517CwTYBjVU6jGDKGLzb5GrhYeWsdTy1jAkyOgjGXPxhmuTzlGbM2SfWumKjGPqYY4fqJuUNoCYfmfIV1PvXd8HaSIoLkzC6uLTGcGamo9sB2cyqaAKa4dw6OHillqvWosWYSGCWQtoZBQbRr8YmFawAOfRortbd1ibmo96GHQnBbmW0MTawXjNF8XAWA0JDmMpa7i1Thm0SfxOuJTl(yxf6Kj5JRDNxTYiVsbtHKLXlGgPCpD4KlykeFRtRIh4dbyfDkvY40PkBbfabyC6L2SfWm2U4JDvOtMKpU2DE1kJ8qaAhg4dw6OHillqvWSkLLeGT64szj3GvjJHC)4cpE1XLYsUuzpmK)XP4XK4XfECmu3sCd2w4fnVftESJE8j3hx4XQ94yOUL46uMC48MuJhNIhtQlFS6Q)4yYckU(HqOr3HZRGgISSESkGDKGLzb5Gvk0UYADppcwiGLgAXQt0uWqnsaJtVoyOAZwadmTzlG5Qq7kR19pwvwiGDK62dwmu3sWJv6Ivhxkl5gSkzmK7cRoUuwYLk7HH8PGefIH6wIBW2cVO5TyIJo5wqTyOUL46uMC48MuJuqQlvx9yYckU(HqOr3HZRGgISSubmfswgVaAKY90HtUGPq8ToTkEGpeGv0PujJtNQSfuaeGXPxAZwadcqZLaFWshnezzbQcMvPSKaSAVjAEjndf(BvNsfu8yx8yx(4cpMqVS8MqL1enLCEELzLbs8(REYJl84yYckUe5UxXKBK)kOHilRhx4Xe6LLxIC3RyYnYFxTYOhx4XQ94d5Xe6LLxgQou0eSgD1tES6Q)4vhxkl5sL9Wq(hNIhRKpwfWosWYSGCWOIBARC4eS0qlwDIMcgQrcyC61bdvB2cyGPnBbmfIBARC4emfswgVaAKY90HtUGPq8ToTkEGpeGv0PujJtNQSfuaeGXPxAZwadcqtja8blD0qKLfOkywLYscWQ9MO5L0mu4VvDkvqXJD0JjXJl84yYckUe5UxXKBK)kOHilRhx4Xe6LL3eQSMOPKZZRmRmqI3F1tECHhtOxwENe5q5LqL1en9QN84cpMqVS8Yq1HIMG1O7Qvgb2rcwMfKdgvCtBLdNGLgAXQt0uWqnsaJtVoyOAZwadmTzlGPqCtBLdNpwTtvatHKLXlGgPCpD4KlykeFRtRIh4dbyfDkvY40PkBbfabyC6L2SfWGa0Ca4dw6OHillqvWSkLLeGrOxwENe5q5LqL1en9QNu4XQ9y1ECT3enVKMHc)TQtPckESJE8HFCHhR2Jj0llVmuDOOjyn6QN8y1v)XXKfuC39wqbVUKxnpuwq(vqdrwwpwLhRYJvx9hR2JJjlO4sK7EftUr(RGgISSECHhtOxwEjYDVIj3i)vp5XfECT3enVKMHc)TQtPckESJEmjESkpwLxjc2rcwMfKdwPq7kR198iyHawAOfRortbd1ibmo96GHQnBbmW0MTaMRcTRSw3)yvzH8y1ovbmfswgVaAKY90HtUGPq8ToTkEGpeGv0PujJtNQSfuaeGXPxAZwadcqtjb(GLoAiYYcufmRszjby1Et08sAgk83QoLkO4Xo6XhgSJeSmlihmQoI3udwJ4Lz(aS0qlwDIMcgQrcyC61bdvB2cyGPnBbmf6OhFSgSg9yhJ5dWosD7bdnBXfk1y7Ip2vHozs(yJ)JlziM3Pq9kfmfswgVaAKY90HtUGPq8ToTkEGpeGv0PujJtNQSfuaeGXPxAZwaZy7Ip2vHozs(yJ)JlziM3Pq9qaAPCGpyPJgISSavb7iblZcYbJQJ4n1G1iEzMpaln0IvNOPGHAKagNEDWq1MTagyAZwatHo6XhRbRrp2Xy(4XQDQcyhPU9GHMT4cLASDXh7QqNmjFSX)XUfKqNOPELcMcjlJxans5E6WjxWui(wNwfpWhcWk6uQKXPtv2ckacW40lTzlGzSDXh7QqNmjFSX)XUfKqNOPEiGamRszjbyqaa]] )

    storeDefault( [[SimC Feral: ST finishers]], 'actionLists', 20171207.215448, [[d4J)haGEGu1MiLSlPQTrvk2hq4YqpgrZwjZNOQBQkoSKVHeopvLDIWEf7MK9RuJIi1WaQFR40egkq0Gvvdxv6GukNIO4yu04aswivvlvQSys1Yb9qIsRIOslJc9CQmrGuzQiPjdy6QCrsHNI6zirUoLSrKQSvsP2mvX2PunnKQQVJuv(mrmpKO(lszDuLsJMcgpvjNKu0RrQCnQs19iswjqkhIOIBlLJzOgMFrsrTeG(6eJkeMGPuyMekEVWHjQggMfnz3F6HWA5T7ptD)9iucNbe6c3HlSCyimc2KcttJGQ30BOe9dMIWDyb4JQOHHdBJ8eJYfQHWmudRHQ0xiq8h2MUyjoFHFNzrdIUXcsIH1ubiiRBGHvJcd)maAxqIQHHddYzw0BGeOxx8hMOAyyqoZA)7q3ybjXW2GsCH9mqAk0RtkZWD4clhgcJGnPWeC4o0nwqs0fQ5clRbKKUNXo2q1f9Wpdar1WW5cHXqnSgQsFHaXFyMekEVW6wE807k7LeKgCkypWqFQW20flX5lSRSxsqAWPGH1ubiiRBGHvJcd)maAxqIQHHdtunmmx2lj4(3nfmChUWYHHWiytkmbhUdDJfKeDHAUWYAajP7zSJnuDrp8ZaqunmCUqqPqnSgQsFHaXFyB6IL48f(DMfni6glijgwtfGGSUbgwnkm8ZaODbjQggomiNzrVbsGEDXFyIQHHb5mR9VdDJfKe3FPnLjSnOexypdKMc96KYmChUWYHHWiytkmbhUdDJfKeDHAUWYAajP7zSJnuDrp8ZaqunmCUqq)HAynuL(cbI)Wmju8EHLZ(Fcs6ekj7V8YV)Bqt69hITsOC7pLLA)bSG1jg1(l39hCpL2Fz2FT2FP3)RGsWR3awRZq)l5T)Gy)n699xR9xo7)vluD9UshH3mNHEuv6ley)Lz)Lx(nOj9(dXwjuU9NYsT)awW6eJA)L7(dUhu7Vw7)lcDc3HQJwZADI3LaH7pi2FG56HI3(3M16eVlbc3Fz2FT2)RGsWR)enK2n0ae4(dI9hu7)g0ctFgqvhwa(cxw3ewtfGGSUbgwnkmSnDXsC(cdfVHFgaTlir1WWHL1ass3ZyhBO6IEyIQHH7eVHTbL4cFfucE0eEKsoNGKoHsI8YlneBLq5OSuawW6eJsUG7PKmAj9vqj41BaR1zO)L8aHrVRLCUAHQR3v6i8M5m0JQsFHaYiV8sdXwjuoklfGfSoXOKl4EqP1lcDc3HQJwZADI3LaHGayUEO4T)TzToX7sGqz06kOe86prdPDdnabccqfUdxy5WqyeSjfMGd3HfGpQIggoCh6glij6c1CHFgaIQHHZfcVhQH1qv6lei(dBtxSeNVWVZSObr3ybjXWAQaeK1nWWQrHHFgaTlir1WWHb5ml6nqc0Rl(dtunmmiNzT)DOBSGK4(lTrzcBdkXf2ZaPPqVoPmd3HlSCyimc2KctWH7q3ybjrxOMlSSgqs6Eg7ydvx0d)maevddNleEtOgwdvPVqG4pmtcfVxyDlpE6DL9scsdofShITsOC7pL3FtJHTPlwIZxyxzVKG0GtbdRPcqqw3adRgfg(za0UGevddhMOAyyUSxsW9VBk4(lTPmH7WfwomegbBsHj4WDOBSGKOluZfwwdijDpJDSHQl6HFgaIQHHZfckc1WAOk9fce)HzsO49cRB5XtVhbc9rdIa0ALOHqxV1ByB6IL48fUvIwynvacY6gyy1OWWpdG2fKOAy4Wevdd)uIw4oCHLddHrWMuycoCh6glij6c1CHL1ass3ZyhBO6IE4NbGOAy4CHauHAynuL(cbI)W20flX5lSheoKIXYrtxCyynvacY6gyy1OWWpdG2fKOAy4WevddtpeoKIXYT)(fhg2guIlCR8IgQqOeFszgUdxy5WqyeSjfMGd3HUXcsIUqnxyznGK09m2XgQUOh(zaiQggoxUWGo0tzTU4pxc]] )

    storeDefault( [[SimC Feral: ST generators]], 'actionLists', 20171207.215448, [[di0EuaqiKaUesGAtQQmkivNcszviH6vcLQBjuk7IsnmvLJjKLjv6zOqMgLKUMqj2gLq8nKOXrjuNtOKADucjZdjO7PkP9PkXbvLAHQQ6HuIMiLqQlsvXgrc5Kuv6MQIDcvdLsWsHKNsAQOOTsj1Ev(lk1GjCyrlgPEmetwkxgSzuYNfQgTu1PPYRPQA2cUnu2nQ(TKHJKoUqjz5iEoftxLRtv2ok47cfJhfQZlvSEKaz(usSFIErJ5uLkG4YGJckpxXhE0hJMQieh1B6u8edMQomlLckcizWIskuMsrCGdK8kIzkkiaPbgE3VikJI6AX2rwegz1pkNIcYwhMomy65q874XLIK3Kc0LIp7ViPi2LccGLoUrkInPaDPO5rYZvCPGILIpBgjfOjfOjffrk(M(g5Cf3mMdpAmN6dpPdqB)NQieh1B6LbGF20HQAxgkUXg4jDaAsXpPG2JflBQeOLxr6W2eJJ1XbJX2JQu8tkO9yXYMouv7YqXn2TkgUu8tkqkm6In1YXpJnIhHa8tkE5vPORu8tkqQk0Qy42PPpXsoyyZIaCkOo2ealDCJuqHsrCK2030UG76mLaXjvmx)uF5nhsEfzkV4W0NQzDsWtmy6u8edMIcItQyU(POGaKgy4D)IOm6BkkWuEeeWmM7MAzpG4)PyaWa(n6PpvdpXGP7gE3XCQp8KoaT9FQIqCuVPxga(zthQQDzO4gBGN0bOjf)KcApwSSPsGwEfPdBtmowhhmgBpQsXpPG2JflB6qvTldf3y3Qy4sXpPaPWOl2ulh)m2iEecWpP4vPWQsXpPOvNnj9d2ealDCJuqHsHvN(M2fCxNPeioPI56N6lV5qYRit5fhM(unRtcEIbtNINyWuuqCsfZ1lfOhH2uuqasdm8UFrug9nffykpccygZDtTShq8)umaya)g90NQHNyW0DdNrJ5uF4jDaA7)ufH4OEtHyLNJkvOzNUGhPytT84iaXif)KIlda)SPdv1UmuCJnWt6a0KIFsb6sbThlw2ujqlVI0HTjghRJdgJT5se)sXlsrxPWkwrkqxkO9yXYMkbA5vKoSnX4yDCWySnxI4xkErkIKIFsrRoBs6hSjaw64gPGcLcgjfOjfOjf)KcApwSSPdv1UmuCJDRIHp9nTl4UotjqCsfZ1p1xEZHKxrMYlom9PAwNe8edMofpXGPOG4KkMRxkqVlAtrbbinWW7(frz03uuGP8iiGzm3n1YEaX)tXaGb8B0tFQgEIbt3nCRoMt9HN0bOT)tveIJ6nnrohdaBGdyoWifVifrtFt7cURZuAI3Lb2MqA6N6lV5qYRit5fhM(unRtcEIbtNINyW0)eVldsHgst)uuqasdm8UFrug9nffykpccygZDtTShq8)umaya)g90NQHNyW0DdpwgZP(Wt6a02)PVPDb31zk1QcSjGP8iiWuF5nhsEfzkV4W0NQzDsWtmy6uluvGIkcoW4B)NINyWuluvqkqbMYJGatFtIBMYQiS5aJVxJMIccqAGH39lIYOVPOat5rqaZyUBQL9aI)NIbad43ON(un8edMUB4wKXCQp8KoaT9FQIqCuVPeGfbm9jDaKIFsb6srICoga2ahWCGrkErk6kfOn9nTl4UotVEsA6N6lV5qYRit5fhM(unRtcEIbtNINyWuM9K00pffeG0adV7xeLrFtrbMYJGaMXC3ul7be)pfdagWVrp9PA4jgmD3WPCmN6dpPdqB)N(M2fCxNPuRkWMaMYJGat9L3Ci5vKP8IdtFQM1jbpXGPtTqvbkQi4aJV9FkEIbtTqvbPafykpccifOhH203K4MPSkcBoW471OPOGaKgy4D)IOm6BkkWuEeeWmM7MAzpG4)PyaWa(n6PpvdpXGP7gUfpMt9HN0bOT)tveIJ6nnrohdaBGdyoWifVifmsk(jfqSYZrLk0SdESyLSJHKuP64XnsXpP4YaWpBAI3Lb2MqA6TbEshG2030UG76m96jPPFQV8MdjVImLxCy6t1Soj4jgmDkEIbtz2tstVuGEeAtrbbinWW7(frz03uuGP8iiGzm3n1YEaX)tXaGb8B0tFQgEIbt3n8y9yo1hEshG2(p9nTl4UotPwvGnbmLhbbM6lV5qYRit5fhM(unRtcEIbtNAHQcuurWbgF7)u8edMAHQcsbkWuEeeqkqVlAtFtIBMYQiS5aJVxJMIccqAGH39lIYOVPOat5rqaZyUBQL9aI)NIbad43ON(un8edMUB4rFJ5uF4jDaA7)ufH4OEtPasX5q874XLcRyfPaDPGcifxga(zthQQDzO4gBGN0bOjf)KccGLoUrkOqPO5rYZvCPGILIpBgjfOjf)KIljXHZ(Cya7Ry3CGu8Iuy1PX0dCuq26mn9UAQV8MdjVImLxCy6BAxWDDMss)W0NQzDsWtmy6ul7be)pfdagWVrpfpXGPOs)W03K4MPxsIdhBhRxPaNdXVJh3kwbDkWLbGF20HQAxgkUXg4jDaA)iaw64gkS5rYZvCk(ZMrO97ssC4SphgW(k2nh8IvNIccqAGH39lIYOVPOat5rqaZyUBkkiBDy6WGPNdXVJhxksEtkqxk(S)IKIyxkiaw64gPi2Kc0LIMhjpxXLckwk(SzKuGMuGMuueP4B6t1Wtmy6UHhfnMt9HN0bOT)tFt7cURZuQvfytat5rqGP(YBoK8kYuEXHPpvZ6KGNyW0PwOQafveCGX3(pfpXGPwOQGuGcmLhbbKc0zeAtFtIBMYQiS5aJVxJMIccqAGH39lIYOVPOat5rqaZyUBQL9aI)NIbad43ON(un8edMUB4rDhZP(Wt6a02)PkcXr9MEza4NnDOQ2LHIBSbEshGMu8tkO9yXYMouv7YqXn2EuLIFsb6sb6sbbWsh3ifu4RsbLsbAsXpPGkqmoZb8JnMx4CudoGifVifT6SjPFWMkMx4CudoGifuSu8zBXXIuGMu8tkUKeho7ZHbSVIDZbsXlsHvNgtpWrbzRZ007QP(YBoK8kYuEXHPVPDb31zkj9dtFQM1jbpXGPtTShq8)umaya)g9u8edMIk9dsb6rOn9njUz6LK4WX2X61lda)SPdv1UmuCJnWt6a0(r7XILnDOQ2LHIBS9O(dD0jaw64gk8vkr7hvGyCMd4hBmVW5OgCa5LwD2K0pytfZlCoQbhqO4pBlowq73LK4WzFomG9vSBo4fRoffeG0adV7xeLrFtrbMYJGaMXC3uuq26W0HbtphIFhpUuK8MuGUu8z)fjfXUuqaS0XnsrSjfukfOjffrk(M(un8edMUB4rmAmN6dpPdqB)NQieh1BQuq7XIL95IdedBwEKo2EuN(M2fCxNP0eVldSnH00p1xEZHKxrMYlom9PAwNe8edMofpXGP)jExgKcnKMEPa9i0MIccqAGH39lIYOVPOat5rqaZyUBQL9aI)NIbad43ON(un8edMUB4rwDmN6dpPdqB)NQieh1BkbyratFshGPVPDb31zkwvCwocm1xEZHKxrMYlom9PAwNe8edMofpXGPpvXz5iW03K4MPxsIdhBhRxjalcy6t6amffeG0adV7xeLrFtrbMYJGaMXC3ul7be)pfdagWVrp9PA4jgmD3WJILXCQp8KoaT9F6BAxWDDMsTQaBcykpccm1xEZHKxrMYlom9PAwNe8edMo1cvfOOIGdm(2)P4jgm1cvfKcuGP8iiGuGUvrB6BsCZuwfHnhy89A0uuqasdm8UFrug9nffykpccygZDtTShq8)umaya)g90NQHNyW0DdpYImMt9HN0bOT)tveIJ6nLaSiGPpPdGu8tkqxkyijUKoa2EgG91tstVu8Qu0vkSIvKIe5CmaSboG5aJu8IuejfOn9nTl4UotVEsA6N6lV5qYRit5fhM(unRtcEIbtNINyWuM9K00lfO3fTPOGaKgy4D)IOm6BkkWuEeeWmM7MAzpG4)PyaWa(n6PpvdpXGP7gEeLJ5uF4jDaA7)ufH4OEtjalcy6t6aif)KcgsIlPdGTNbyF9K00lfVkfrsXpPG2JflBKaKeK0CoECBpQtFt7cURZ0RNKM(P(YBoK8kYuEXHPpvZ6KGNyW0P4jgmLzpjn9sb6mcTPOGaKgy4D)IOm6BkkWuEeeWmM7MAzpG4)PyaWa(n6PpvdpXGP7gEKfpMt9HN0bOT)tFt7cURZuQvfytat5rqGP(YBoK8kYuEXHPpvZ6KGNyW0PwOQafveCGX3(pfpXGPwOQGuGcmLhbbKc0Jf0M(Me3mLvryZbgFVgnffeG0adV7xeLrFtrbMYJGaMXC3ul7be)pfdagWVrp9PA4jgmD3WJI1J5uF4jDaA7)ufH4OEttKZXaWg4aMdmsXlsr0030UG76m1eJJkm1xEZHKxrMYlom9PAwNe8edMofpXGPAmoQWuuqasdm8UFrug9nffykpccygZDtTShq8)umaya)g90NQHNyW0DdV73yo1hEshG2(pvrioQ30wD2K0pytaS0XnsXlsb6srICUIBB6jqZgPmNue7srICUIBts)GnszoPi2KcGdK4DSr8ieGFsbAsbfSuaCGeVJnbIdCPWkwrkO9yXYgjajbjnNJh32J6030UG76m10tG2uF5nhsEfzkV4W0NQzDsWtmy6u8edMQ9eOnffeG0adV7xeLrFtrbMYJGaMXC3ul7be)pfdagWVrp9PA4jgmD3UPw0aR0lC7)Una]] )

    storeDefault( [[IV Guardian: Single]], 'actionLists', 20171207.215448, [[dWtReaGEjfBIsvAxGQTrPI9jjy2cMVKu3usYZPYTfPdl1ov0Ej7gP9tHrjjQHrj)wOVrrnukvYGrvdxHoeLQYPKe6yGCoreTqryPIYIr0Yr58kONQAzukRJsvmrreMkvzYOY0v6IkWvfrXLHUocNgyRuQuBwuTDqP(Oik9zjvtdu03fr1ZOuv9yjgnvL)ckCskY8erQRjP09Ke51GsgNisoivvli5PNeyEtewLqF2POUj72GpzjAghOP2Jb)b06bupddy7qnTzbzgcccMWHStT1ALK6FelGoaQPxqKQjKfm19xwqK6KNMqYtFaTjdiNsOp7uupzCObVPftD6VWaJRUUFsqaSd1jCimalM60ZqxKGvqN80QNHbSDOM2SGmdzPBIYbk9gz60if1QPn5PpG2KbKtj0NDkQxvtRhq9xyGXvx3pjia2H6PnTEa1ZqxKGvqN80QNHbSDOM2SGmdzPBIYbk9gz60if1QP9lp9b0MmGCkH(Str9QIrAoGH6VWaJRojrEo86DOllOaJ6enJd0u4eJ6(jbbWoupngP5agQNHUibRGo5Pvpddy7qnTzbzgYs3eLdu6nY0PrkQvtykp9b0MmGCkH(StrDpFS25t)fgyC119tccGDO(6J1oF6zOlsWkOtEA1ZWa2outBwqMHS0nr5aLEJmDAKIA1Sw5PpG2KbKtj0NDkQBxebyJmqnO(lmW4QZHKe55WxFS25dgKyZG72Uald(kzWxRbF1vBWxzdEsI8C4JebyJmqniCgMZqNVMmGg82RbphssKNdF9XANpyqIndUB7cSm4RGbpKbFf19tccGDO(ira2idudQBIYbk9gz60if1ZqxKGvqN80QNHbSDOM2SGmdzPvt7ip9b0MmGCkH(Str9QIrAoGHg8vgQI6VWaJRohssKNdpngP5agcNHPnG6m4t6kzWxVWP7Neea7q90yKMdyOUjkhO0BKPtJuupdDrcwbDYtREggW2HAAZcYmKLwnnlp9b0MmGCkH(Str9QAIG(lmW4QBFg8BtHfGw3GV6Qn4zDDeEHGXq6AWxbdE7yP7Neea7q90MiOBIYbk9gz60if1ZqxKGvqN80QNHbSDOM2SGmdzPvZKsE6dOnza5uc9zNI6p5Gru)fgyC119tccGDOUl5Gru3eLdu6nY0PrkQNHUibRGo5Pvpddy7qnTzbzgYsRw9xyGXvxRea]] )

    storeDefault( [[IV Guardian: 2-3]], 'actionLists', 20171207.215448, [[d0JPeaGEjL2eQQ0UavBduY(KK0LHMTqZxsQBkP4WsDBr65uANkAVKDJ0(PsJssKHrrJtefNxbgQicdMkgUcDiuvLtjjXXa5CIOQfsvzPIQfJWYr50apv1JLyDIizIIiAQuLjJktxPlQGUQis9mjrDDennuvSvruzZIY2bL6JOQQMhQQ4ZGIVljyzOkFJcgnvv)vsLtsHULikDnjvDpjHoOi8Auv63cwqYtpjXSMmUYN(StrDJjNRd)t2moqttkxhEjBL1ZXi2wutEMqgGGG4dCiyvF9MjV(hXcOJGA7feOAczYh9eLfeOw5PjK80hsBIiYjF6VWaJRU(Str9K2IUogxm1QNGaeb7aDslwhyXuRUrkhO0BGPtduuphJyBrn5zczaYuphTbswbTYtRwn5jp9H0MiICYN(lmW4QRp7uu3ZpRT(1tqaIGDG(6N1w)6gPCGsVbMonqr9CmITf1KNjKbit9C0gizf0kpTA1SYYtFiTjIiN8P)cdmU66Zof1RPPWer9eeGiyhON2uyIOUrkhO0BGPtduuphJyBrn5zczaYuphTbswbTYtRwn5J80hsBIiYjF6VWaJRobzwgCy6yxwqPoyiBghOPWjh1NDkQxtiqZamupbbic2b6PHandWqDJuoqP3atNgOOEogX2IAYZeYaKPEoAdKScALNwTAwV80hsBIiYjF6VWaJRohsqMLbF9ZAR)6iWMb3UDHVUov01PExNQR21PsUoeKzzWhjJWgzGAr4mmJHw)nreDD4xxhoKGmld(6N1w)1rGndUD7cFDDQQRdKRtv0NDkQNeKryJmqTOEogX2IAYZeYaKPUrkhO0BGPtduuphTbswbTYtREccqeSd0hjJWgzGArTAcl5PpK2erKt(0FHbgxDoKGmldEAiqZameodtBa1YpveMcN(Str9AcbAgGHUovcQk65yeBlQjptidqM6gPCGsVbMonqr9C0gizf0kpT6jiarWoqpneOzagQvtdYtFiTjIiN8P)cdmU68NRZ2u(cOW46uD1UoSggeEHKXq666uvxhyzQp7uuVMMmQNJrSTOM8mHmazQBKYbk9gy60af1ZrBGKvqR80QNGaeb7a90MmQvZKrE6dPnre5Kp9xyGXvxF2PO(Raye1ZXi2wutEMqgGm1ns5aLEdmDAGI65OnqYkOvEA1tqaIGDGUTcGruRw9xyGXvxRea]] )

    storeDefault( [[IV Guardian: 4+]], 'actionLists', 20171207.215448, [[dOtIdaGEusBcrHDHiBdfL9HOKzly(OiDtuOUni2Ps2lz3uSFrAuOanmQ43s65uAOOagSqgUqDqQkNcrLoMsDouiTqQslvelgulhPdl1tvTmuP1HOQMiIQmvQ0KrvtxXfLqVcfKNHcX1r4BuvTveLAZs02Pk6Jik68sWNrP67OionWJf1ObPRIcQtIk(lkX1OkCpevmnukxg61OOATLRo5HLnryKx9vdb15q2PrKjrt5bTH8tJyJH0tWa2wulUoB)79MnsBM5HhomQ(JXmOdaw7bunATDyt3xEavJvUATLRErtdhqE5v)zkiE01xneuNHTyAeNbHy19bdcGPGoHfzbmieRohdpi3tLQBQgupbdyBrT46S9VD0tqBLGMrRC1OrlUYvVOPHdiV8Q)mfep66RgcQ7cL2wO6(GbbWuqFGsBluDogEqUNkv3unOEcgW2IAX1z7F7ONG2kbnJw5QrJwmIC1lAA4aYlV6ptbXJU(QHG6mUnShqDFWGaykOdPnShqDogEqUNkv3unOEcgW2IAX1z7F7ONG2kbnJw5QrJwSjx9IMgoG8YR(Zuq8OdtuwsI9o05bKzHDIMYdAdjIy9vdb1zCTAkbuu3hmiaMc6qQvtjGI6Cm8GCpvQUPAq9emGTf1IRZ2)2rpbTvcAgTYvJgT8qU6fnnCa5Lx9NPG4rNhHjkljnqPTfklWytjzNoZ80iYjnYJ0iMY00igmncMOSKumrWtKcyfjrXskAH2WbmnImsJ4ryIYssduABHYcm2us2PZmpnISsJ2PrKR(QHG6marWtKcyf1tWa2wulUoB)BhDogEqUNkv3unOEcARe0mALRgDFWGaykOhte8ePawrnAXm5Qx00WbKxE1FMcIhD9vdb1ptaXOEcgW2IAX1z7F7OZXWdY9uP6MQb1tqBLGMrRC1O7dgeatbDltaXOgn6ptbXJUgja]] )

    storeDefault( [[IV Guardian: Default]], 'actionLists', 20171207.215448, [[dyZhdaGEKiTjLKAxkj2Mss2hssZMKBIk1Trv7uv2Ry3i2VunmL43umyPmCsXbvk9CjDmv15qIyHKslvPAXs0YjCyQEk0YqfRdPyIiPAQezYO00v5IOqVcjLldUoPAJiHAROGntu2osPpIu5BkftJOAEiHCEujNwXNvs9xjCsu0TqsCnKOUhsqFhjWZqQ6Xu68JuqQdYCD1fTbFopeKjd9gD6UGDCcn9g1bzUU6cUdkWRqECw(B()V8v(RIYuEHscIAa74QHs9BmK8(lYdU1EJHuJuE)ifKrIxQa2On4Z5HGAbx0BuSrWheTIrZfSuxMSvkbxuiZi4xH1qbKGBlh1CCfSeCrHmJGp4oun6cluJuUG7Gc8kKhNL)M)sqMe2X6NreKyiqU84ePGms8sfWgTbrRy0CbD7n0cfab4hO2BuyV9d(CEiioK1kO3KCXA4cUdvJUWc1iLl42Yrnhxbf6Kc3EJHuOM6fKjHDS(zebjgceChuGxH84S838xcYTH958qqMm0B0P7c2Xj00B4qwRGC5rFKcYiXlvaB0geTIrZf0T3qluaeGFGAVr1E73BRU3C7n0cfab4hO2BuuVjp4Z5HGCOc99MKlwdxn4oun6cluJuUGBlh1CCf06kvHBVXqkut9cYKWow)mIGedbcUdkWRqECw(B(lb52W(CEiitg6n60Db74eA6nouH(C5jpsbzK4LkGnAdIwXO5c62BOfkacWpqT3OAVrFWNZdbLtTEtYfRHRgChQgDHfQrkxWTLJAoUcADLQWT3yifQPEbzsyhRFgrqIHab3bf4vipol)n)LGCByFopeKjd9gD6UGDCcn9MCQLlxq0kgnxWCja]] )

    storeDefault( [[IV Guardian: Defensives]], 'actionLists', 20171207.215448, [[dKdBdaGEbLnjiTlHABGQY(icZwsZhrQBJWojQ9QSBr7hYOqe1WqYVvPNtXHPAWqnCH4GQsofOQ6yuY3uvzHQsTuqAXQWYjCEevpL0YufRdrKjIiXubXKrQPdCrvLoTuptq11vrBuq0wbvXMru2UQQ(iOk9zbMMGW8qK0JL4VGYOPuJNi6KePvbQCnH09qe6YOghIGxRQ4znit)M(rLP3XuzNGNkfEqy490f0TNKectkmzCA6)SzkuUYUHN8dL1pRhk4l2AQgHlTx7WCqFZjBrfIPVkG(MMbzYwdY0VPFuz69EQStWtdPGZWAMgHHYbCYch03Cku2Cpff2midm91rxBa5tjtWzyntdtWbCYch03CQ0KUlo4kMM3KNcLRSB4j)qz9ZIAQweDeWuB2Ra74YPqWjaHjve2M9kWoMWLeHHdHPIjbeoueMKr4ITlcydctIiC4imPjnc3z5s0zamANWdyyrniSeiSn7vGDmHljcdhctf)efHHFeEGj)mit)M(rLP37PYobpvQ4MKDkMcLn3trHndYatFD01gq(0wCtYoftLM0DXbxX08M8uOCLDdp5hkRFwut1IOJaMIWDwUeDgaJ2j8agwudclbcBZEfyhxofcobimCimv8Zato8bz630pQm9Epv2j4P6P4F)3RiS00a6SamtHYM7POWMbzGPVo6AdiFQ5u8V)7vyDAaDwaMPst6U4GRyAEtEkuUYUHN8dL1plQPAr0ratbE(PZaeoueUZYLOZay0oHhWWc3GWsGW2Sxb2XeUKimCimv8t0bMCigKPFt)OY079uzNGN(2fFmDofkBUNIcBgKbM(6ORnG8PhU4J5tNtLM0DXbxX08M8uOCLDdp5hkRFwut1IOJaMc88tNbiCOiCNLlrNbWODcpGHf1GWsGW2Sxb2XeUKimCimv8t0bgyQweDeW0b2a]] )


    storeDefault( [[Feral Primary]], 'displays', 20171207.215448, [[dWJZgaGEf0lrsAxQsITHeWmPQQzlvpgf3ejQJJK6BQssxtbANuzVIDt0(rL(PIAyQIFd5WsgksnyuLHdvhukEoLogfoNQKYcLslfv0Ij0Yj1dPQ8uWYqfwhsqtKQknvv1KrvnDLUOcDvKixwLRJOncfBvvs1Mjy7i4JQs8zO00qc57uLrIK4zuvXOrPXRk1jrOBHeQttY5POxRawlsGUTICmYpatHVkKedsUWA2VaZu67pr3yaMcFvijgKCb1WlodocOlj2Zh7XmqAdqn5rEnDfw50j3ambmNfeS36RWxfsAJ7jW7zbb7T(k8vHK24EcGRvtL2KidscQHxCd(eysjBgJZpbOM8ip((k8vHK20gWCwqWE7V0yV1g3tallYd8uldBZyAd8EwqWE7V0yV1g3tafdsc4fJsInUbdSLg7TnsgwKoq78)ptzoj(cv(bmJJI5WppbEh3tallY7xAS3AtBGbeBKmSiDG)mnNeFHk)akjFftTiDJKHfPdWjXxOYpatHVkKSrYWI0bAN))zkhaWpgv1vdRvHKXz84NawwKh8tBaQjpYZVk9XSkKmaNeFHk)asYjImiPnokkGf)6Dm9YY6d1r68duXzeqmoJayJZiGooJSbSSipFf(QqsBed8EwqWEBdPUI7jqrQRVj(fqKuqiWu9UHCrX9eqSRgo8LoYRP3JyGQJZwalYJMWyCgbQooB5dnjwlnHX4mc43tOi7BAduDVY0stGoTbiOSkrvxTMFt8lGyaMcFviztxHvgW3O7pYza(klEVm)M4xGkGUKyVVj(fOevD1AgOi1fLvYlTbgqedsUGA4fNbhbQooB9ln2BPjqhNra91d4B09h5mGf)6Dm9YYgXavhNT(Lg7T0egJZia1Kh5XNOKVIPwK2M2a(q4MC59rbWC6QZLxZ8ya(Nqr23gA)daQjFC5H50vNc5YJ)juK9nWwAS3Ibjxyn7xGzk99NOBmGasUbO)C5bL0YLNR0AKxGIuxeLcOVj(fqKuqiGLf51qUO0gO64Svt3RmT0eOJZiGIbjPGi0uCgdgaxRMkTjgKCb1WlodocGRpg0KyTn0(haut(4YdZPRofYLhU(yqtI1gWYI8Ai1frPakIbMQ3nJX9eGAYJ84tKbjb1WlUbFcSLg7T0egJyaXUA4Wx6iVigWYI8O6zkQK8vsS20gGbnjwlnHXigyln2BPjqhXaMZcc2Bjk5RyQfPTX9eWCwqWEBdPUI7jW7zbb7TeL8vm1I024EcyzrEeL8vm1I020gysjBixuCpbQUxzAPjmM2awwKhnHX0gWYI8AgtBag0KyT0eOJyGIuxa(17e9BCpb2sJ9wmi5gG(ZLhuslxEUsRrEbgqedsUWA2VaZu67pr3yGjLe(X9eyln2BXGKlOgEXzWrGQJZwnDVY0stymoJamf(Qqsmi5gG(ZLhuslxEUsRrEbQooB5dnjwlnb64mcmklX(XpTbSQj8(1mpghhbOMuXmWRRSWA2VavGbeXGKBa6pxEqjTC55kTg5fWYI8ap1YW2qUO0gOi1vJKHfPd0o))Zu2)rm)aCE9RSxCC8y8Qgggu0RyqbgCWNxlGLf5rtGoTbmNfeS3s1wBCuSrGP6n8JZiq1XzlGf5rtGooJautEKhFmi5cQHxCgCe49SGG9wQ2AJZia1Kh5XNQT20gWvtxamNU6C5rRvtL2mqrQlkjvBa8EzE6Sj]] )

    storeDefault( [[Feral AOE]], 'displays', 20171207.215448, [[dWtZgaGEPuVefQDHcWRvfmtPeZwQEmsUjkKJJQ42kQPrvu7Kk7vSBI2pb(PcnmvPFd5WsgkQmycA4q1bPQonPogHohkqTqfzPufwmsTCkEivPNcwgkQ1HcQjsvKPQQMmQQPR0fvWvrrCzvUoI2iuAROaAZKy7i4Jsj9muK(mu8DPyKOk55uA0O04vfDse6wOk11uf68K03qbP1IcKTHcIJy(bOk8vJKyrYfw1(fyKj)wi6gcqv4RgjXIKlOBFXjYCatjXCEzpQhYuaEipYZVRXiNp5gGkG6OII9wVf(QrsBCVbEoQOyV1BHVAK0g3BaCJEUmQePqsq3(IZZVbM1s)H4yAaEipYJV3cF1iPntbuhvuS3(ldMBTX9gWYIAGg9sX6pe6aphvuS3(ldMBTX9gqtHKaErPLyI7XafPPikvqFv8lanPIsa144nZm9nWZ44TitFmGLf18ldMBTzkWd0(skwKjWFKZdITYRFaTKVMQwKXxsXImb8GyR86hGQWxns6lPyrMatJ))iJc4fHRkq4hfa7zQUaH(JdbSSOg4NPa8qEKNN0MJA1izapi2kV(bKKZePqsBCIbS4xVJTxwwVOoYKFGkoXaM4edGjoXa0XjMnGLf14TWxnsAdDGNJkk2B9jnvCVbkst9vXVa0KkkbMRN(KlkU3a0DD72T2rn(9EOduDC2cyrnCegItmq1XzlVOz6A5imeNyapDkfzFZuGQ3uQwocCzkabTvtR76v9RIFbOdqv4Rgj97AmYaEhC)bpcWxBX7L6xf)cqfWusm3xf)cu06UEvduKMIrA5LPapqJfjxq3(ItK5avhNT(LbZTCe4ItmG56b8o4(dEeWIF9o2EzzdDGQJZw)YG5wocdXjgGhYJ84tuYxtvlYyZuaa)O0vx3UwnsgN4ltd4Q5la2ZuDbc9hhcSLbZTyrYfw1(fyKj)wi6gc8CurXElJNSXjgyUEc)4edyzrn(Klk0bQooB53BkvlhbU4eduDC2cyrnCe4ItmaUrpxgvSi5c62xCImha3CuOz6A95AjaON9kqi2ZuDgwGqCZrHMPRnG6OII9wgpzJJ3IbMRN(dX9gWYIA8jnfrPck0b2YG5wocdHoGLf1WrGltbSSOggFQ0AjFTeJntb846xzV4y(vKHkkk6zgGid5XhFzWbkst5lPyrMatJ))iJAza7pGLf1an6LI1NCrzkWd0yrYna3xGqOKwbcDLXGAcWdPM6bgO2cRA)cqhWYIAik5RPQfzSzkWSw6tUO4Edu9Ms1YryitbSSOg)HqhWYIA4imKPauOz6A5iWf6avhNT8IMPRLJaxCIb2YG5wSi5gG7lqiusRaHUYyqnbQooB53BkvlhHH4edmRLWpU3aBzWClwKCbD7lorMd8anwKCHvTFbgzYVfIUHauf(QrsSi5gG7lqiusRaHUYyqnbkstb4xVt0tX9gyqw09JFMcy1Z49ZFCioMd8CurXElrjFnvTiJnU3aQJkk2B9jnvCVbuhvuS3suYxtvlYyJ7nWwgm3YrGl0bOqZ01Yryi0bO762TBTJAcDaEipYJprkKe0TV488BafKCdW9fiekPvGqxzmOMaAkKKbHqZXj(yaEipYJpwKCbD7lorMdSLbZT(skwKjW04)pYipi2kV(b4H8ip(mEYMPa8pLISV(CTea0ZEfie7zQodlqi)tPi7BGI0umrQ3a49s9mztaa]] )

    storeDefault( [[Guardian Primary]], 'displays', 20171207.215448, [[dWJPgaGEPKxIeAxkuX2OsrZKkvZwQoSKBIe8nfQ0Tb0ZuOk7KI9k2nQ2VuQFQidtr9BipNudffdwHmCeDqP40eDms6CiiAHuvlLGSysSCk9qa8uvpgLwNcv1erImvOmzcmDLUOcUkcQld66q1gPs2kvkSzcTDe6JiP(mqnnQu67uLrIe1YqGrJuJhGojqUfcsxJG68uXRvOSweeoosYrny5Sf5krCxi((1PdZNimM7Gmd5BzbdxgImrj3wCWqaOHSJf)CQWH4WMUemhiKV5S5otIIA4cqrUsexhZCoGtIIA4cqrUsexhZCov4qCOaqSi(LTGXi8CoqjVziMXlNkCiouaaf5krCD8ZDMef1WfRSGHRoM5CnnY7EYLLUzi(5AAKxd(IIFUMg5Dp5Ys3GVO4Nx42cexeH5qcZvWffZDIHqjGaHZDMef1WLI(6yiu1CnnYdRSGHRo(5JP0WzPr2CSjgHarnLXYLCbs2Ar2golnYMleiQPmwoBrUseVHZsJS5(tyytui)Kqwz1LTQvI4XOo72CnnY7yXpNkCioKsslKDLiEUqGOMYy5CCGGyrCDmUnxtc7Dx9stdaQJSblVIrnxjg1CWXOMBJrnBUMg5bqrUsexhLCaNef1WTb3wXmNx42cZHeMRGlkMdSaSbFrXmNR0LTArDh5107rjV6K01PrEmehIrnV6K0faiGk1YqCig1Ckbfl8(g)8Q7voAgImXpNOulvKD56G5qcZvYzlYvI4nDjyEoadgSbHYfi1K9YbZHeMx52IdgI5qcZlfzxUo5fUTOGKdJF(ykUq89YwWyujiV6K0fwzbdxgImXOMBH9CagmydcLRjH9UREPPJsE1jPlSYcgUmehIrnNkCiouaiUajBTiRo(5McimNA8Ykqw82JySsGL1jFlly46cX3VoDy(eHXChKzihWyMZbCsuudxk6RJrnhyb4XIrnV6K0vt3RC0mezIrnhWjrrnCXkly4QJzoN0kbwwhxi(EzlymQeKtAHSiGk12W4EmZ5sweNqGqaJrv4CGfGndXmNlI4Bodw7rV462JmL1I8Y3YcgUmehIsUMg51GBlqCruuYfc2HLggdbZQJRQQQBhhv3uyHNjK5kDzRwu3rErjNfbuPwgIdrj3zsuudxqCbs2ArwDmZ5otIIA42GBRyMZbCsuudxqCbs2ArwDmZ5AAKhiUajBTiRo(5aL8g8ffZCE19khndXH4NRPrEmehIFUMg51me)CweqLAziYeL8TSGHRleFZzWAp6fx3EKPSwKxEHBRtc7DqukM58XuCH47xNomFIWyUdYmKduYpwmZ5Bzbdxxi(EzlymQeKxDs6QP7voAgIdXOMZwKReXDH4Bodw7rV462JmL1I8YRojDbacOsTmezIrnFGxkDOG4NRLaj7WMPHyiiNkCj7yUHu)1PdZR8XuCH4Bodw7rV462JmL1I8YLSi(jlwjhCmcNZwKReXDH47LTGXOsqEHBRgolnYM7pHHnrb3hCHLRPrEmezIFoPvcSSoGyr8lBbJr45CnnYJIqhfjxGKdwh)8QtsxNg5XqKjg1CQWH4qbUq89YwWyujiFlly42WzPr2C)jmSjkieiQPmwov4qCOak6RJFUaOyH33gg3Zb5gThrnEzfil(43EeLGIfEFZlCBryUCZj7Ld0Mnba]] )

    storeDefault( [[Guardian Defensives]], 'displays', 20171207.215448, [[dOdRgaGEPKxIO0UGQsVMsYmPKA2kCtef3gQCyj7KI9k2nk7xQ4NkYWuf)gY6uuKHIQgSuQHJKdkfpdQQ6yKQJtiwiv1sjuTysz5u5HkQEk4Xe8CIMOIstfktgrMUkxuQ6QiQCzLUocBKsSvOQYMrLTRk9rcPLjvAAkk8DQYiru1Pjz0i14HQCsvLBrO01iuCEk1NvvTwff13GQIJEWciuuNcXSGyhC2JnWe5WS(Z0h4k3)E8V8rlGRy)7C6vWQ4hqeILyBgQFgULDbecypXXj3BErDketgZta8M44K7nVOofIjJ5jaLtHRC2FcigOATXmJNa4uSM(yW)aIqSelP5f1Pqmz8dypXXj3dRC)7jJ5jGKg5bEQtGUPp(bK0iVgIdf)a4k8aSy0dCL7FVgManYfWFcdBImI)jk5XcyhJy72vmbWlgXQJ)DXxXeqsJ8Wk3)EY4hWkTgManYfaBIx8prjpwafJKsOoKRHjqJCbe)tuYJfqOOofI1WeOrUa(tyytKjaqTcQAOAvNcXIr)zgbK0ipal(beHyj2zvUv4uiwaX)eL8ybye4(eqmzm6bKu7yyzus65ObYfSavm6b0IrpWFm6bCXONlGKg5nVOofIjJwa8M44K71q4QyEcueUcZMAdOrWXfaxHxdXHI5jG2q1QLOdKxZyeTa1GIUaAKh)BFm6bQbfDnhHtRo(3(y0dm7YveJlAbQHxzl5F5JFGxLuPPgQZgZMAdOfqOOofI1mu)SaZ7ny9IhGKssnkBmBQnaPaUI9Vy2uBGstnuNDGIWvKrX24hWknli2bQwBm6Ddudk6cRC)7X)YhJEa3ocmV3G1lEaj1ogwgLKoAbQbfDHvU)94F7JrpGielXs6JrsjuhYjJFatHBdikr5iPkwN2ZUCltQExzGRC)7zbXo4ShBGjYHz9NPpaofRH4qX8eWknli2bN9ydmromR)m9beHyjwsFcigOATXmJNa1GIUAgELTK)Lpg9a4nXXj3JS(Yy0dq5u4kNTfe7avRng9UbOCRacNwDn8whZtaLaInZieUy0ftaCfEn9X8eGdXUa8yDAdft2PTPCoKxGRC)7X)2hTakbedOkbf7pgXeqsJ84F5JFaTHQvlrhiVOfaVjoo5EFmskH6qozmpbSN44K79XiPeQd5KX8e4k3)EwqSlapwN2qXKDABkNd5faVjoo5EyL7FpzmpbK0iVpgjLqDiNm(bK0iVgcx9X4qrlqn8kBj)BF8diPrE8V9XpGKg510h)aciCA1X)YhTafHRAyc0ixa)jmSjYyDVfSafHRaQDm(MnMNaIqOeSc)us4ShBGkaofdWI5jWvU)9SGyhOATXO3nqr4QpghcZMAdOrWXfqOOofIzbXUa8yDAdft2PTPCoKxGAqrxZr40QJ)Lpg9a9SsBSKIFaPch1yBM6JPBa7joo5EneUkMNawPzbXUa8yDAdft2PTPCoKxGAqrxndVYwY)2hJEaHI6uiMfe7avRng9Ubeq40QJ)TpAbK0ipYU2Akgjf7xg)aIVJTKBGUp64JE3h8bF1diPrEGN6eOBiou8dudk6cOrE8V8XOhqeILyjzbXoq1AJrVBa7joo5EK1xgJy1dicXsSKiRVm(biTCfX4A4ToWh(1PTOeLJKQyZuN2ZUCltQExzGIWvKJPUauJYED5sa]] )



end

