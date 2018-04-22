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
        addResource( "mana", Enum.PowerType.Mana )
        addResource( "energy", Enum.PowerType.Energy )
        addResource( "rage", Enum.PowerType.Rage, true )
        addResource( "combo_points", Enum.PowerType.ComboPoints, true )

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

            --[[ energy = {
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
            }, ]]

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

        addAura( "moonfire_cat", 155625, "duration", 16 )

        addAura( "moonfire", 164812, "duration", 16 )
            modifyAura( "moonfire", "id", function( x )
                if talent.lunar_inspiration.enabled and buff.cat_form.up then
                    return 155625
                end
                return x
            end )
        
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
            return buff.cat_form.up and 1.0 or max( 0.75, 1.5 * haste )
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
                    if spellID == 58984 or spellID == 5215 or spellID == 1102547 then
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

        addSetting( 'tf_restrictions', 1, {
            name = "Tiger's Fury: Restriction",
            type = "select",
            desc = "This setting allows you to set some restrictions on Tiger's Fury when using it would overwrite an existing Tiger's " ..
                "Fury buff.  This only applies when the Predator talent is taken.",
            width = "full",
            values = {
                "No Restrictions",
                "Restrict Overlap Time",
                "Restrict Energy Amount",
                "Restrict Time and Energy"
            }
        }) 

        addSetting( 'tf_overlap', 2, {
            name = "Tiger's Fury: Restrict Overlap",
            type = "range",
            desc = "Specify how much overlap the addon should allow before refreshing Tiger's Fury.  For example, if set to 4, " ..
                "the addon will not recommend using Tiger's Fury unless the remaining time on Tiger's Fury is at or below 4 seconds.",
            min = 0,
            max = 15,
            step = 0.1,
            width = "full",
            hidden = function()
                return not ( state.settings.tf_restrictions == 2 or state.settings.tf_restrictions == 4 )
            end,
        } )

        addSetting( 'tf_energy', 60, {
            name = "Tiger's Fury: Restrict Energy",
            type = "range",
            desc = "Specify how much Energy you must be missing before Tiger's Fury would be recommended, if the Tiger's Fury buff is " ..
                "active.  For instance, if this value is set to 30, and your maximum energy is 130, then the addon would not recommend " ..
                "overwriting an existing Tiger's Fury buff unless your energy was at or below 100.",
            min = 0,
            max = 250,
            step = 1,
            width = "full",
            hidden = function ()
                return not (state.settings.tf_restrictions == 3 or state.settings.tf_restrictions == 4 )
            end,
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
            gcdType = "off",
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
            usable = function () return combo_points.current > 0 end,
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
            if ( target.health_pct < 25 or talent.sabertooth.enabled ) and debuff.rip.up then debuff.rip.expires = query_time + min( debuff.rip.remains + debuff.rip.duration, debuff.rip.duration * 1.3 ) end
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
            usable = function () return ( talent.lunar_inspiration.enabled and buff.cat_form.up ) or ( talent.galactic_guardian.enabled and buff.bear_form.up ) or ( buff.cat_form.down and buff.bear_form.down ) end,
            recheck = function () return dot.moonfire.remains - dot.moonfire.duration * 0.3, dot.moonfire.remains end,
        }, 155625 )

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
            elseif talent.galactic_guardian.enabled and buff.bear_form.up then
                if buff.galactic_guardian.up then
                    gain( 8, "rage" )
                    removeBuff( "galactic_guardian" )
                end
            end
            applyDebuff( "target", "moonfire" )
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
            recheck = function () return buff.incarnation.remains - 0.1 end,
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
            if buff.bear_form.up then
                if buff.incarnation.up then return 0 end
                return 6 * haste
            end
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
            ready = function ()
                -- This uses the settings created for managing overlapping Tiger's Fury, with the assumption that maximizing
                -- TF uptime is a good plan.  This is generally applicable when Predator is talented, but also applies in extreme
                -- edge cases where the helm + tier 21 procs keep TF long enough to overlap itself.
                if not buff.tigers_fury.up then return 0 end

                local overlap = 0
                local threshold = 0

                if ( settings.tf_restrictions == 2 or settings.tf_restrictions == 4 ) then
                    overlap = buff.tigers_fury.remains - settings.tf_overlap
                end

                if ( settings.tf_restrictions == 3 or settings.tf_restrictions == 4 ) then
                    threshold = energy[ "time_to_" .. ( energy.max - settings.tf_energy ) ]
                end
                    
                return max( 0, overlap, threshold )
            end,
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


        class.abilities.shadowmeld.recheck = setfenv( function () return buff.incarnation.remains - 0.1 end, state )


    end


    storeDefault( [[SimC Feral: default]], 'actionLists', 20180205.201654, [[dqKMmaqiHkTiufXMir8jufyucv4ucv0Quve9kvfLMLQIWTuvuzxKWWKWXiLLjP8muvX0qvLUgjsBdvb9njvJdvH6CQkswhQI6EQkyFOQkhuIAHsIhQcMiQI0frvAJQk0jvvALQks9svfvntvff3ui7uHLQOEkYuvrBfvL9s9xvObRshw0IrLhRKjlvxgSzsQpljnAf50e9AsYSLYTvQDJYVHA4QQooQcz5eEUGPd56KQTlu(UqvNxISEuvvZNe1(vLTMpnnYnyIK7dV7hbr2453TdQt9gYeTeYFKjt0pSKztY)jsIzEOvWpMMHgKbWJAfA11QvuxrnnLYV8lp20mK9sNYnycjxQKSQVBY6VBC8Ufkku67(zFxbStjl8UFU3noE3UUirsm7D)KVBHc(5DJZ3noFxS4DlmvEHKywWNEO5tt8YsUg0DftL5KnjQKPGk9w7ixgMm9L1LReHfMyygykc35lfJCdMmnYnyIuP3AVBLmmzAgAqgapQvOvxRW0meW6Ife8PrMomblvr4yWgyiZzkc3h5gmzKh18PjEzjxd6UIjAjK)itapsx()dDfnD1QZJXlY)FjR67QK3v7Dvw53TWuzoztIkzkwkKjxdm9L1LReHfMyygykc35lfJCdM0dWr0KidtMg5gmriSaEx(YMoyQSOAWel3Wh0dWr0KidtFIyzth(aWJ0L))qxrtxT68y8I8)xYQQenLvUW0m0GmaEuRqRUwHPziG1fli4tJmDycwQIWXGnWqMZip4hFAIxwY1GURyIwc5pYuUqYyWXogPqi)Fx(7DlExLv(DrYn8U837QPutL5KnjQKjHo7yUqsm7ytgqM(Y6YvIWctmmdmfH7JCdMi5(W7(rqKnE(Ddsw1g8UOuufqMIWD(sXi3GjthMGLQiCmydmK5mnYnyAwN9ULxijM9UFgzazQSOAWel3Wh4jKCF4D)iiYgp)UbjRAdExukQciEIPzObza8OwHwDTct0eo(iCxQwcIGRyAgcyDXcc(0itesixOdtWsLRyKh8RpnXll5Aq3vmrlH8hzkUVlsUujzvFxLv(D50vRwXVahFtH()7QSYVlNUA1kctzhh)gADf6)MkZjBsujtIufy6lRlxjclmXWmWueUZxkg5gmzAKBW0CQcmndnidGh1k0QRvyAgcyDXcc(0ithMGLQiCmydmK5mfH7JCdMmYdL6tt8YsUg0Dft0si)rMI77YPRwTIvIoQgl2k0)nvMt2KOsM6zyY0xwxUsewyIHzGPiCNVumYnyY0i3GjEAgMmndnidGh1k0QRvyAgcyDXcc(0ithMGLQiCmydmK5mfH7JCdMmYdEOpnXll5Aq3vmrlH8hzcLnGHu00zP4OKf(LIejXmfal5Aq)DvY7g33fjxQKSQMkZjBsujtBmMPwkatFzD5kryHjgMbMIWD(sXi3GjtJCdMIWyMAPamndnidGh1k0QRvyAgcyDXcc(0ithMGLQiCmydmK5mfH7JCdMmYJ6(0eVSKRbDxXeTeYFKP4(UC6QvRiKXYQWrbofk0)nvMt2KOsMczSSkCuGtHPVSUCLiSWedZatr4oFPyKBWKPrUbtuglRcV7mofMMHgKbWJAfA11kmndbSUybbFAKPdtWsveogSbgYCMIW9rUbtg5bp2NM4LLCnO7kMkZjBsujtCGiacvM(Y6YvIWctmmdmfH78LIrUbtMg5gmvbebqOY0m0GmaEuRqRUwHPziG1fli4tJmDycwQIWXGnWqMZueUpYnyYip(u(0eVSKRbDxXuzoztIkzsYwPGLijMz6lRlxjclmXWmWueUZxkg5gmzAKBW0x2kfSejXmE(D)8sw13fR(DrtW7(P1zvBGPzObza8OwHwDTctZqaRlwqWNgz6WeSufHJbBGHmNPiCFKBWKrEOv4tt8YsUg0DftL5KnjQKjKSkichvRlkz6lRlxjclmXWmWueUZxkg5gmzAKBW0PSki4bH39J6IsMMHgKbWJAfA11kmndbSUybbFAKPdtWsveogSbgYCMIW9rUbtg5HMMpnXll5Aq3vmvMt2KOsMYWuUtgeoQwam(VKPVSUCLiSWedZatr4oFPyKBWKPrUbtLdt5ozapi8UFuam(VKPzObza8OwHwDTctZqaRlwqWNgz6WeSufHJbBGHmNPiCFKBWKrEOvZNM4LLCnO7kMOLq(JmfhVlkBadPiKCGaHXOjfal5Aq)Dvw53LtxTAf)cONiSO0Xq8s1igeck0)F348DvY7IYgWqk4AyChLnmlOayjxd6VRsExoD1QvW1W4okBywqrhhp7DvY7UWBo8XFSKHckw6cbWqV7hExLAQmNSjrLmjGQcC8OjtFzD5kryHjgMbMIWD(sXi3GjtJCdMMHQcC8OjtZqdYa4rTcT6AfMMHawxSGGpnY0HjyPkchd2adzotr4(i3GjJ8qJF8PjEzjxd6UIjAjK)itl8MdF8hlzOGILUqam07(H3vPMkZjBsujtc5VPVSUCLiSWedZatr4oFPyKBWKPrUbtZYFtZqdYa4rTcT6AfMMHawxSGGpnY0HjyPkchd2adzotr4(i3GjJ8qJF9PjEzjxd6UIjAjK)itX9DrYLkjR67QK3nwkKjxduOhGJOjrgMEx(7DlmvMt2KOsMqtImmz6lRlxjclmXWmWueUZxkg5gmzAKBW05KidtMMHgKbWJAfA11kmndbSUybbFAKPdtWsveogSbgYCMIW9rUbtg5HMs9PjEzjxd6UIjAjK)it5cjJbhbgSLq4D5V3vZ0xwxUsewyIHzGPYCYMevYuiE5pyAgcyDXcc(0itZqdYa4rTcT6AfMg5gmrXl)bJ8qJh6tt8YsUg0DftL5KnjQKPWKa6M(Y6YvIWctmmdmfH78LIrUbtMg5gmrtcOBAgAqgapQvOvxRW0meW6Ife8PrMomblvr4yWgyiZzkc3h5gmzKrM4PG6uVHCfJSb]] )

    storeDefault( [[SimC Feral: precombat]], 'actionLists', 20180205.201654, [[diZ0caGELcTlIQEneA2u5MKYTfStkTx0UjSFIsdJu9BrdvPIbtuz4KKdkKogrwOqSuPyXqz5u8qs0tvTmi1ZHQjkLIPkutwjtxXfHixgCDPKnQu0wHO2SsP2oK0PPQhlvtJO47kvDyjFwPsJMK6BKWjHeRtkvDnPu58qW4uk4zkL8xPuAkXyEBfa(7dkLvUnbt5AVSYPYa9mGvdFBGTRwUHr4Bahu4aTO1LuiHwxH8OLANmYSb(3nEvdpF0(4tboJPvIX8ijkmhSye(3nEvd)uoqmYJ5YCnLlf4YdIcZbl(OyENFqG3a7AY9JAEuelFVM0WlsbWRLlKlJTcapVTcaFdSRj3pQ5Bahu4aTO1LuiPZ3a4zlthWzmhELQHoIAjQqaedX41YLTcaphArZyEKefMdwmcFumVZpiWRYK7D8Oiw(EnPHxKcGxlxixgBfaEEBfa(Dm5EhFd4GchOfTUKcjD(gapBz6aoJ5WRun0rulrfcGyigVwUSva45q7wmMhjrH5GfJWhfZ78dc89AA72PjWJIy571KgErkaETCHCzSva45Tva4vwJSYTzAc8nGdkCGw06skK05Ba8SLPd4mMdVs1qhrTeviaIHy8A5YwbGNdTYWyEKefMdwmcFumVZpiWRkhFk4rrS89AsdVifaVwUqUm2ka882ka87KJpf8nGdkCGw06skK05Ba8SLPd4mMdVs1qhrTeviaIHy8A5YwbGNdh(Rc6(Y53yn(uqRK(wCiba]] )

    storeDefault( [[SimC Feral: cooldowns]], 'actionLists', 20180205.201654, [[dmu5kaqiQiwKkfztKK(ejsgfkWPqbTlu1WePJjILjOEMayAKiCnvQSnse9nuuJtLsDoQiL1PsrnpbO7Psv7taDquHfIc9qsIjQsjDrsuBKeP(OkfQtIkALQuGxsfP6MkQDIKHQsjwkv4PetLeUQkf0wPsAVs)Lk1GP4WalgPESqtwuxgAZQKptsnAb50uA1QuiVwGMTc3wf7wPFRQHRilhXZPQPd66O02PI67ujopQ06PIK5JISFsDtQIkuGdwrShv0gLgjGXnRnX)h53L1xrIe7eSsLBfVaSdyzSIdCGapwQWPjmNeoLz(Wj3PekXTR4abzUkShScUirnxEO9GUHV7aKwHJi0(RVkkvsvur5fqpWCzSIej2jyfNOn0Sxx8ra091to8Stv4G2oSqUvYaFOkCUzBeaFsL9xSY8NDfqOahSsfkWbRCRaFOkoWbc8yPcNMWCsAfhO)zjr0xffwrLqym487mEWfw6kZFMcCWkfwQWvrfLxa9aZLXksKyNGvOzVU4TBeqwa0(lpbpa761MaQnP83PnQQn0Sxx83i2v9aD7HGrqKWZovHdA7Wc5wzI8UmQW5MTra8jv2FXkZF2vaHcCWkvOahSYTqExgvCGde4XsfonH5K0koq)ZsIOVkkSIkHWyW53z8GlS0vM)mf4GvkSubOkQO8cOhyUmwrIe7eScUirnx(ilHGluBc8ETjaPAJQAdd0M4)J87YYdTQrI39flHlpbpa761Ma1M70gMysBOzVU4Hw1iX7(ILWLNDsByyfoOTdlKBfAK4rsWkCUzBeaFsL9xSY8NDfqOahSsfkWbRWis8ijyfh4abESuHttyojTId0)SKi6RIcROsimgC(Dgp4clDL5ptboyLclLsufvuEb0dmxgRirIDcwbxKOMlFgVSrluBc8ETrjtRWbTDyHCRaTQrI39flHBfo3SncGpPY(lwz(ZUciuGdwPcf4GvuyvJeLYRnknlHBfh4abESuHttyojTId0)SKi6RIcROsimgC(Dgp4clDL5ptboyLcl1DvrfLxa9aZLXkCqBhwi3k0iXJKG2vDfo3SncGpPY(lwz(ZUciuGdwPcf4GvyejEKe0UQR4ahiWJLkCAcZjPvCG(NLerFvuyfvcHXGZVZ4bxyPRm)zkWbRuyPuYQOIYlGEG5YyfjsStWkX)q)UNE7c98rwcbxO2CV2KQnQQn4Ie1C5JSecUqTjW71M7sRWbTDyHCRGd2f9UvZAZGnIv4CZ2ia(Kk7VyL5p7kGqboyLkuGdwr5b7IkLxBUXS2myJyfh4abESuHttyojTId0)SKi6RIcROsimgC(Dgp4clDL5ptboyLclfZvrfLxa9aZLXksKyNGvWfjQ5YhzjeCHAtG3RnbivBuvByG2e)FKFxwEOvns8UVyjC5j4byxV2eO2KCN2WetAdn71fp0QgjE3xSeU8StAddRWbTDyHCRy3iGSaO93kCUzBeaFsL9xSY8NDfqOahSsfkWbRW5gbKfaT)EZAJt3UQ1M)sBGHqT5gWUQhyfh4abESuHttyojTId0)SKi6RIcROsimgC(Dgp4clDL5ptboyLcl1TRIkkVa6bMlJvKiXobRabe1iKhApOB47oBrTjGAJsEN2WetAdd0gO9GUHV7Sf1MaQnj3ovBuvByG2qZEDXtJepscYZoPnmXK2qZEDXB3iGSaO9xE2jTHHAddRWbTDyHCRm9q7Vv4CZ2ia(Kk7VyL5p7kGqboyLkuGdw5wEO93kCqu7RSGdE)nnr(XVQXS7P3fKCtvCGde4XsfonH5K0koq)ZsIOVkkSIkHWyW53z8GlS0vM)mf4GvMi)4x1y2907cskSuoTQOIYlGEG5YyfjsStWkX)q)UNE7c98rwcbxO2e49AtyTrvTHbAJt0giyGlKNE8Fgcg)65XfqpWS2WetAdn71fp94)mem(1ZZoPnmSch02HfYTcWhcCal6DFrW1P4wHZnBJa4tQS)IvM)SRacf4GvQqboyfo8HahWIkLxBuAcUof3koWbc8yPcNMWCsAfhO)zjr0xffwrLqym487mEWfw6kZFMcCWkfwQK0QOIYlGEG5YyfjsStWkX)q)UNE7c98rwcbxO2eqT5oTrvTbxKOMlFKLqWfQnbEV2aIq7V8eqqKp(EO2OQ2KFipbee5NoSdODAyrI2eqTjmFI2OQ2qZEDXdTQrI39flHlp7K2OQ2WaTHM96INE8Fgcg)65zN0gMysBCI2abdCH80J)ZqW4xppUa6bM1ggQnQQnmqBCI2abdCH82ncilaA)Lhxa9aZAdtmPnX)h53LL3Urazbq7V8e8aSRxBcuBsUT2WqTrvTXjAdn71fVDJaYcG2F5zNQWbTDyHCR4dbYVlhCKRW5MTra8jv2FXkZF2vaHcCWkvOahSIecKFxo4ixXboqGhlv40eMtsR4a9pljI(QOWkQecJbNFNXdUWsxz(ZuGdwPWsLKufvuEb0dmxgRirIDcwXjAZe5Dzyx1v4G2oSqUvy9OBlep(kCUzBeaFsL9xSY8NDfqOahSsfkWbRCd9O2Wjep(koWbc8yPcNMWCsAfhO)zjr0xffwrLqym487mEWfw6kZFMcCWkfwyfzcJwWW6uaO93sLKgGcBba]] )

    storeDefault( [[SimC Feral: single target]], 'actionLists', 20180205.201654, [[diKTkaqivqzrKiTjjyuKuDkssRsfK8kvq0TubHDPsddv6yiYYurEMkktJkrxJevBtKO8nsLghjcNtfKADQOAEIeUhvc7JeLdQcTqskpucnrrI4IIuTrQKoPiLvksKMjjIUjQyNKYsjHNszQOQ2QkWEb)fvzWqDyflgHhlPjRKltSzj6ZuPgnPQtJYRruMTOUTsTBi)wQHlILJ0ZPQPlCDQy7IK(ojX4vbvNhr16fjQMpPI9RQbsaFWSePYMmlLpbRrGgjUNbMvPSKamWsjs54KdqnWuizz8cODIljDjDIRU3tKuUlDPsaMczwKZNTfWcwLmgY9Jh06XQ)yUxUk)XhYhtL9Wq(hFiES6pE5qNG1OhFOEm37zpw1hR6JB6J5c2XAWAKh4dAKa(GLoAiYYcudmRszjbyh2JjCklV1j4v2091jbSJeSmlihS6e8kB6gS0qlwDIMcgQrcyC61bdvB2cyGPnBbSIt8yxB6gmfswgVaAN4ssxsCbtH4BhAv8aFiaROEPsgNovzlOaiaJtV0MTageG2jGpyPJgISSa1aZQuwsagHtz5nH2QKVojpwhDEmHtz51RFwTkBjVUojGDKGLzb5GrhYeWsdTy1jAkyOgjGXPxhmuTzlGbM2SfWumKjGPqYY4fq7exs6sIlykeF7qRIh4dbyf1lvY40PkBbfabyC6L2SfWGa0od4dw6OHillqnWosWYSGCWQtoZBQbRr8YmFawAOfRortbd1ibmo96GHQnBbmW0MTawXjNF8XAWA0JvsMpa7i1Thm0SfxOuJTl(yxf6Kp)X1UZRwfKxPGPqYY4fq7exs6sIlykeF7qRIh4dbyf1lvY40PkBbfabyC6L2SfWm2U4JDvOt(8hx7oVAvqEianxc8blD0qKLfOgywLYscWwDCPSKBWQKXqUFCHhV64szjxQShgY)4u84ZECHhhd1Te3GTfErZBXKhRShtI7Jl8y1FCmu3sC1lto0FtQXJtXJpP8hRJopoMSGIRFieA0DO)kOHilRhRkyhjyzwqoyLcTRS2XZJGfcyPHwS6enfmuJeW40RdgQ2SfWatB2cyUk0UYAh)JvJfcyhPU9Gfd1Te8yLUy1XLYsUbRsgd5UWQJlLLCPYEyiFkoRqmu3sCd2w4fnVftugjUfupgQBjU6Ljh6Vj1ifNuUo6etwqX1pecn6o0Ff0qKLLQGPqYY4fq7exs6sIlykeF7qRIh4dbyf1lvY40PkBbfabyC6L2SfWGa0uoWhS0rdrwwGAGzvkljaR2BIMxsZqH)wDOubfp2fpw5pUWJjCklVjuznrtjNNxfwzGeV)6K84cpoMSGIlrU7vm5g5VcAiYY6XfEmHtz5Li39kMCJ83vRc6XfES6p(WEmHtz5LHQdfnbRrxNKhRJopE1XLYsUuzpmK)XP4XkXJvfSJeSmlihmQ4M2Qe6bln0IvNOPGHAKagNEDWq1MTagyAZwatH4M2Qe6btHKLXlG2jUK0LexWui(2HwfpWhcWkQxQKXPtv2ckacW40lTzlGbbOLYa(GLoAiYYcudmRszjby1Et08sAgk83QdLkO4Xk7XN94cpoMSGIlrU7vm5g5VcAiYY6XfEmHtz5nHkRjAk588QWkdK49xNKhx4XeoLL3jroCEjuznrtVojpUWJjCklVmuDOOjyn6UAvqGDKGLzb5Grf30wLqpyPHwS6enfmuJeW40RdgQ2SfWatB2cyke30wLq)JvNKQGPqYY4fq7exs6sIlykeF7qRIh4dbyf1lvY40PkBbfabyC6L2SfWGa00f4dw6OHillqnWSkLLeGr4uwENe5W5LqL1en96Ku4XQ)y1FCT3enVKMHc)T6qPckESYESlFCHhR(JjCklVmuDOOjyn66K8yD05XXKfuC39wqbVUKxnpuwq(vqdrwwpw1hR6J1rNhR(JJjlO4sK7EftUr(RGgISSECHht4uwEjYDVIj3i)1j5XfECT3enVKMHc)T6qPckESYE8zpw1hR6Nsb7iblZcYbRuODL1oEEeSqaln0IvNOPGHAKagNEDWq1MTagyAZwaZvH2vw74FSASqES6KufmfswgVaAN4ssxsCbtH4BhAv8aFiaROEPsgNovzlOaiaJtV0MTageGMsa8blD0qKLfOgywLYscWQ9MO5L0mu4VvhkvqXJv2JDjyhjyzwqoyuheVPgSgXlZ8byPHwS6enfmuJeW40RdgQ2SfWatB2cykCqp(ynyn6XkjZhGDK62dgA2IluQX2fFSRcDYN)yJ)JlziMxVq9kfmfswgVaAN4ssxsCbtH4BhAv8aFiaROEPsgNovzlOaiaJtV0MTaMX2fFSRcDYN)yJ)JlziMxVq9qaAhAGpyPJgISSa1a7iblZcYbJ6G4n1G1iEzMpaln0IvNOPGHAKagNEDWq1MTagyAZwatHd6XhRbRrpwjz(4XQtsvWosD7bdnBXfk1y7Ip2vHo5ZFSX)XUfKqNOPELcMcjlJxaTtCjPljUGPq8TdTkEGpeGvuVujJtNQSfuaeGXPxAZwaZy7Ip2vHo5ZFSX)XUfKqNOPEiGamTzlGzSDXh7QqN85p2ZqUZYJJH6wciaa]] )

    storeDefault( [[SimC Feral: ST finishers]], 'actionLists', 20180205.201654, [[d4J)haGEIs0MiQAxQITbKk7di8yeDyjZwPMpPWnLQEnsLVHeopvLDIWEf7MK9RKrrKAya14asonHHcenyv1WvLoerLofrYXOKFRyHuvTuPYIPWYb9qKQwfrPwgPQNtLjsuctfPmzatxLlsk1tr9mIkUofTrKO2kPKntvSDkvtdiLVtusFMiMhsK)IKwhqQA0KkJNsPtsk6YqxJsH7ruSskfDBPCqQshRqlmtcfVx4WYc0tzUV4pmr1WWSOr)6tzewBq)6Z0wFpcLWPdHUWD4glhgc9GTOWspykE0Bzdqd0av4oSa8rt0WWH9sEIr5cTqyfAH1wvgBei(d71qSfNVWVZSPcr3ycjXWAQaeK1nWWQrHH7haTkir1WWHb5mBkpqc02l(dtunmmiNzV(DOBmHKyyVqjUWEgivfA7jJv4oCJLddHEWwuyboCh6gtij6cTCHPxhssx)yhBO6Ir4(bGOAy4CHqFOfwBvzSrG4pmtcfVxydtpEECL9scsfof8byKvvyVgIT48f2v2ljiv4uWWAQaeK1nWWQrHH7haTkir1WWHjQggMl7LeC97McgUd3y5WqOhSffwGd3HUXesIUqlxy61HK01p2XgQUyeUFaiQggoxiKtOfwBvzSrG4pSxdXwC(c)oZMkeDJjKedRPcqqw3adRgfgUFa0QGevddhgKZSP8ajqBV4pmr1WWGCM963HUXesIRV0wsf2luIlSNbsvH2EYyfUd3y5WqOhSffwGd3HUXesIUqlxy61HK01p2XgQUyeUFaiQggoxiaTqlS2QYyJaXFyMekEVWYD9pbjDcLK1xdnw)LnLE9HyRek36tjzwFatyDIrT(YE9b)iN1xQ1x(1x61)kOe8E0H1(098sERpiwF92y9LF9L76F1gv3JRmq4nZP7bvLXgbwFPwFn0yztPxFi2kHYT(usM1hWewNyuRVSxFWpGA9LF9FrOt4ouDuBM7t8UfiC9bX6dm3du8(82m3N4Dlq46l16l)6FfucEpNOHuVHkGaxFqS(GA9x2mSSQdvDyb4lCzEtynvacY6gyy1OWWEneBX5lmu8gUFa0QGevddhMEDijD9JDSHQlgHjQggUt8g2luIl8vqj4rv4rg5Ecs6ekjAOH0qSvcLJsYaycRtmkzd(rosjV0xbLG3JoS2NUNxYde6TH8Y9QnQUhxzGWBMt3dQkJnciLgAineBLq5OKmaMW6eJs2GFaL8Vi0jChQoQnZ9jE3ceccG5EGI3N3M5(eVBbcLs(RGsW75enK6nubeiiav4oCJLddHEWwuyboCh6gtij6cTCH7WcWhnrddhUFaiQggoxiSrOfwBvzSrG4pSxdXwC(c)oZMkeDJjKedRPcqqw3adRgfgUFa0QGevddhgKZSP8ajqBV4pmr1WWGCM963HUXesIRV06LkSxOexypdKQcT9KXkChUXYHHqpylkSahUdDJjKeDHwUW0RdjPRFSJnuDXiC)aqunmCUqa6cTWARkJnce)HzsO49cBy6XZJRSxsqQWPGpqSvcLB9P06BPpSxdXwC(c7k7LeKkCkyynvacY6gyy1OWW9dGwfKOAy4WevddZL9scU(DtbxFPTKkChUXYHHqpylkSahUdDJjKeDHwUW0RdjPRFSJnuDXiC)aqunmCUqqrOfwBvzSrG4pmtcfVxydtpEE8iqOpQqeGARene6EmFd71qSfNVWTs0cRPcqqw3adRgfgUFa0QGevddhMOAy4(s0c3HBSCyi0d2IclWH7q3ycjrxOLlm96qs66h7ydvxmc3paevddNleGk0cRTQm2iq8h2RHyloFH9GWHumMoQgIddRPcqqw3adRgfgUFa0QGevddhMOAyykJWHumMU13V4WWEHsCHBLTurfcL4tgRWD4glhgc9GTOWcC4o0nMqs0fA5ctVoKKU(Xo2q1fJW9dar1WW5YfMFrsrTfYY6eJkewGLtUea]] )

    storeDefault( [[SimC Feral: ST generators]], 'actionLists', 20180205.201654, [[di0EuaqiKaUesGAtQQmkivNcszvuc8kHQQBjuv2fLAyQkhtiltQ0ZOezAucDnKqTnHQOVHcghLGoNqvQ1jufmpKGUNQe7tvshuvQfQQQhsjzIcvHUivL2isiNKQIBQk2junuuilfsEkPPII2kLu7v5VOudMWHfTyK6XqmzPCzWMrjFwOmAPQttLxtv1SfCBOSBu9BjdhjDCHQKLJ45umDvUovz7irFxOY4rH68sfRhjqMpLO2prVOXCQIqCuVPtJhbwPx42)P4jgmvDywjfueqYq8GuOmLIyahi5veZuuqasdm8UFrme19Jb7UruSfTOfoffKTomDyW0ZH43XJjfjVjfOlfF2Frsr8lfealDCJueFsb6srZJKNR4sHfifF2wskqtkqtkkIu8n9nY5kUzmhE0yo1xEshG2(pvrioQ30lda)SPdv1UmuCJnWt6a0KIFsbThlw2ujqlVI0HTjohRJdgJThvP4Nuq7XILnDOQ2LHIBSBvCCP4NuGuy0fBQLJFgBepcb4Nu86lsrxP4NuGuvOvXXTttFILCWWMfb4uqDSjaw64gPGcLIyiTPVPDb31zkbIrQ4U(P(WBoK8kYuEXHPpvZ6KGNyW0P4jgmffeJuXD9trbbinWW7(fXq03uuGP8iiGzm3n1QEaX)trjGb8B0tFQgEIbt3n8UJ5uF5jDaA7)ufH4OEtVma8ZMouv7YqXn2apPdqtk(jf0ESyztLaT8ksh2M4CSooym2EuLIFsbThlw20HQAxgkUXUvXXLIFsbsHrxSPwo(zSr8ieGFsXlsHfLIFsrRoBs6hSjaw64gPGcLclo9nTl4Uotjqmsf31p1hEZHKxrMYlom9PAwNe8edMofpXGPOGyKkURxkqpcTPOGaKgy4D)Iyi6BkkWuEeeWmM7MAvpG4)POeWa(n6PpvdpXGP7gULgZP(Yt6a02)PkcXr9McXlphvQqZoDbpsXMA5XraIrk(jfxga(zthQQDzO4gBGN0bOjf)Kc0LcApwSSPsGwEfPdBtCowhhmgBZLi(LIxLIUsHLTSuGUuq7XILnvc0YRiDyBIZX64GXyBUeXVu8Quejf)KIwD2K0pytaS0Xnsbfkfwskqtkqtk(jf0ESyzthQQDzO4g7wfhF6BAxWDDMsGyKkURFQp8MdjVImLxCy6t1Soj4jgmDkEIbtrbXivCxVuGEx0MIccqAGH39lIHOVPOat5rqaZyUBQv9aI)NIsad43ON(un8edMUB4wCmN6lpPdqB)NQieh1BAICokb2ahWCGrkEvkIM(M2fCxNP0eVldSnH00p1hEZHKxrMYlom9PAwNe8edMofpXGP)jExgKcnKM(POGaKgy4D)Iyi6BkkWuEeeWmM7MAvpG4)POeWa(n6PpvdpXGP7gofpMt9LN0bOT)tFt7cURZuQvfytat5rqGP(WBoK8kYuEXHPpvZ6KGNyW0PmQQafveCGX3(pfpXGPmQQGuGcmLhbbM(MeZmLvryZbgFVenffeG0adV7xedrFtrbMYJGaMXC3uR6be)pfLagWVrp9PA4jgmD3WJNJ5uF5jDaA7)ufH4OEtjalcy6t6aif)Kc0LIe5CucSboG5aJu8Qu0vkqB6BAxWDDME9K00p1hEZHKxrMYlom9PAwNe8edMofpXGPm7jPPFkkiaPbgE3VigI(MIcmLhbbmJ5UPw1di(FkkbmGFJE6t1Wtmy6UHZWyo1xEshG2(p9nTl4UotPwvGnbmLhbbM6dV5qYRit5fhM(unRtcEIbtNYOQcuurWbgF7)u8edMYOQcsbkWuEeeqkqpcTPVjXmtzve2CGX3lrtrbbinWW7(fXq03uuGP8iiGzm3n1QEaX)trjGb8B0tFQgEIbt3nClCmN6lpPdqB)NQieh1BAICokb2ahWCGrkEvkSKu8tkG4LNJkvOzh8yXkzhhjPs1XJzKIFsXLbGF20eVldSnH00Bd8KoaTPVPDb31z61tst)uF4nhsEfzkV4W0NQzDsWtmy6u8edMYSNKMEPa9i0MIccqAGH39lIHOVPOat5rqaZyUBQv9aI)NIsad43ON(un8edMUB4X7XCQV8KoaT9F6BAxWDDMsTQaBcykpccm1hEZHKxrMYlom9PAwNe8edMoLrvfOOIGdm(2)P4jgmLrvfKcuGP8iiGuGEx0M(MeZmLvryZbgFVenffeG0adV7xedrFtrbMYJGaMXC3uR6be)pfLagWVrp9PA4jgmD3WJ(gZP(Yt6a02)PkcXr9MsbKIZH43XJjfw2Ysb6sbfqkUma8ZMouv7YqXn2apPdqtk(jfealDCJuqHsrZJKNR4sHfifF2wskqtk(jfxsIbN95Wa2xXU5aP4vPWItJRh4OGS1zA6D1uF4nhsEfzkV4W030UG76mLK(HPpvZ6KGNyW0Pw1di(FkkbmGFJEkEIbtrL(HPVjXmtVKedo2owVqbohIFhpMLTm6uGlda)SPdv1UmuCJnWt6a0(raS0XnuyZJKNR4wWNTLq73LKyWzFomG9vSBo4vloffeG0adV7xedrFtrbzRdthgm9Ci(D8ysrYBsb6sXN9xKue)sbbWsh3ifXNuGUu08i55kUuybsXNTLKc0Kc0KIIifFtrbMYJGaMXC30NQHNyW0DdpkAmN6lpPdqB)N(M2fCxNPuRkWMaMYJGat9H3Ci5vKP8IdtFQM1jbpXGPtzuvbkQi4aJV9FkEIbtzuvbPafykpccifOBj0M(MeZmLvryZbgFVenffeG0adV7xedrFtrbMYJGaMXC3uR6be)pfLagWVrp9PA4jgmD3WJ6oMt9LN0bOT)tveIJ6n9YaWpB6qvTldf3yd8KoanP4Nuq7XILnDOQ2LHIBS9Okf)Kc0Lc0LccGLoUrkOWxKcgKc0KIFsbvGyCMd4hBmVW5OgCarkEvkA1zts)GnvmVW5OgCarkSaP4Z2cPyPanP4NuCjjgC2NddyFf7MdKIxLclonUEGJcYwNPP3vt9H3Ci5vKP8IdtFt7cURZus6hM(unRtcEIbtNAvpG4)POeWa(n6P4jgmfv6hKc0JqB6BsmZ0ljXGJTJ1lxga(zthQQDzO4gBGN0bO9J2JflB6qvTldf3y7r9h6OtaS0Xnu4lmG2pQaX4mhWp2yEHZrn4aYRT6SjPFWMkMx4CudoGybF2wifJ2VljXGZ(Cya7Ry3CWRwCkkiaPbgE3VigI(MIcYwhMomy65q874XKIK3Kc0LIp7ViPi(LccGLoUrkIpPGbPanPOisX3uuGP8iiGzm3n9PA4jgmD3WJS0yo1xEshG2(pvrioQ3uPG2Jfl7Zfdig2S8iDS9Oo9nTl4UotPjExgyBcPPFQp8MdjVImLxCy6t1Soj4jgmDkEIbt)t8UmifAin9sb6rOnffeG0adV7xedrFtrbMYJGaMXC3uR6be)pfLagWVrp9PA4jgmD3WJS4yo1xEshG2(pvrioQ3ucWIaM(KoatFt7cURZuSQ4SCeyQp8MdjVImLxCy6t1Soj4jgmDkEIbtFQIZYrGPVjXmtVKedo2owVqaweW0N0bykkiaPbgE3VigI(MIcmLhbbmJ5UPw1di(FkkbmGFJE6t1Wtmy6UHhrXJ5uF5jDaA7)030UG76mLAvb2eWuEeeyQp8MdjVImLxCy6t1Soj4jgmDkJQkqrfbhy8T)tXtmykJQkifOat5rqaPaDlI203KyMPSkcBoW47LOPOGaKgy4D)Iyi6BkkWuEeeWmM7MAvpG4)POeWa(n6PpvdpXGP7gEu8CmN6lpPdqB)NQieh1BkbyratFshaP4NuGUuqzsCjDaS9ma7RNKMEP4fPORuyzllfjY5OeydCaZbgP4vPiskqB6BAxWDDME9K00p1hEZHKxrMYlom9PAwNe8edMofpXGPm7jPPxkqVlAtrbbinWW7(fXq03uuGP8iiGzm3n1QEaX)trjGb8B0tFQgEIbt3n8iggZP(Yt6a02)PkcXr9MsaweW0N0bqk(jfuMexshaBpdW(6jPPxkErkIKIFsbThlw2ibijiP5C8y2EuN(M2fCxNPxpjn9t9H3Ci5vKP8IdtFQM1jbpXGPtXtmykZEsA6Lc0TeAtrbbinWW7(fXq03uuGP8iiGzm3n1QEaX)trjGb8B0tFQgEIbt3n8ilCmN6lpPdqB)N(M2fCxNPuRkWMaMYJGat9H3Ci5vKP8IdtFQM1jbpXGPtzuvbkQi4aJV9FkEIbtzuvbPafykpccifOtXOn9njMzkRIWMdm(EjAkkiaPbgE3VigI(MIcmLhbbmJ5UPw1di(FkkbmGFJE6t1Wtmy6UHhfVhZP(Yt6a02)PkcXr9MMiNJsGnWbmhyKIxLIOPVPDb31zQjohvyQp8MdjVImLxCy6t1Soj4jgmDkEIbt14CuHPOGaKgy4D)Iyi6BkkWuEeeWmM7MAvpG4)POeWa(n6PpvdpXGP7gE3VXCQV8KoaT9FQIqCuVPT6SjPFWMayPJBKIxLc0LIe5Cf320tGMnszoPi(LIe5Cf3MK(bBKYCsr8jfahiX6yJ4ria)Kc0KckyPa4ajwhBced4sHLTSuq7XILnsascsAohpMTh1PVPDb31zQPNaTP(WBoK8kYuEXHPpvZ6KGNyW0P4jgmv7jqBkkiaPbgE3VigI(MIcmLhbbmJ5UPw1di(FkkbmGFJE6t1Wtmy6UDtvQaIldokO8CfF4rFwA3g]] )

    storeDefault( [[IV Guardian: Single]], 'actionLists', 20180205.201654, [[dStReaGEjfBsub7cvSnjH2NOknBbZxsQBkj52IYZPYov0Ej7gP9tHrjjQHrjJtsKdl1qfvObtrdxHoivvNssWXq03qLwiLQLkIfdQLJY5Lu9uvldKwNOImrrLyQuLjJQMUsxubDvrv0ZevkxhHtdSvrL0MfPTdI6JIkvtde8zf47IQQ)kP0JLy0uv(TqNKszEIQW1aHUNOQCzOdjQOEniYIuE65cM2eHv21NDgQBlxnmZDIMXdAAozyEaDqa1tWa2outOwKCjHAXLdusicbiuj9pIfqha10lis1K0cc6(llisDYtts5PpK2WbKx21FHbgxD9zNH65PdnmTTyMt3pmia266eoSwWIzoDBuEqP3itNgPOEcgW2HAc1IKlPLEc6IeSc6KNwTAcvE6dPnCa5LD9xyGXvxF2zOEvnDqa19ddcGTUEwtheqDBuEqP3itNgPOEcgW2HAc1IKlPLEc6IeSc6KNwTAMBYtFiTHdiVSR)cdmU6WePPCg0HUSGsTdiAgpOPCig1NDgQxvmstbmu3pmia266zXinfWqDBuEqP3itNgPOEcgW2HAc1IKlPLEc6IeSc6KNwTAcb5PpK2WbKx21FHbgxD9zNH6E(yTZNUFyqaS11xFS25t3gLhu6nY0PrkQNGbSDOMqTi5sAPNGUibRGo5PvRMquE6dPnCa5LD9xyGXvNhHjst5S(yTZxTWyZ442UajdZ8zycrdZQR2WSYgMWePPCgjcqgzGAqommLHoFnCanmZbdtEeMinLZ6J1oF1cJnJJB7cKmmZRHjPHzf0NDgQNJebiJmqnOEcgW2HAc1IKlPLUnkpO0BKPtJuupbDrcwbDYtRUFyqaS11hjcqgzGAqTAwr5PpK2WbKx21FHbgxDEeMinLtwmstbmKddZAa1zyMh5ZWCqHxF2zOEvXinfWqdZktwb9emGTd1eQfjxslDBuEqP3itNgPOEc6IeSc6KNwD)WGayRRNfJ0uad1Qjx5PpK2WbKx21FHbgx9C2WCBkKa0bgMvxTHjRhGCkemgsxdZ8Aywrl9zNH6v1eb9emGTd1eQfjxslDBuEqP3itNgPOEc6IeSc6KNwD)WGayRRN1ebTAwj5PpK2WbKx21FHbgxD9zNH6p)Grupbdy7qnHArYL0s3gLhu6nY0PrkQNGUibRGo5Pv3pmia266U8dgrTA1FHbgxDTs]] )

    storeDefault( [[IV Guardian: 2-3]], 'actionLists', 20180205.201654, [[dWJPeaGEjv2efvSluX2KeAFscMTG5lj1nLuCzOBlshwQDQO9s2nk7NknkjjnmkmojjEoLgkfLmyQy4k0bPQCkruDmeoVcSqryPIYIb1Yr60apv1YaP1rrvnrrKmvQYKrvtxPlQGUQicptsuxhrttsvBLIkTzr12PO4JIiAEuuLpdcFxeLhlXVfA0uv9nuPtsrUffL6AGi3tsKdjIuVge1FLuArip9KcZBYWQe6Zof1nzUUojjzt5bnZ8DDGA2vwpddyBrnHAqWLaQbxoqjGu91xf9pIfqha11liY0KWOEDFLfezw5PjH80hYA4aYRe6Zof1tcl66yAXuR(luW4QR7dgea7aDslwlyXuREgAJK0cALNw9mmGTf1eQbbxcdDtmEqP3ivNfzOwnHkp9HSgoG8kH(StrDp)026x)fkyC119bdcGDG(6N2w)6zOnsslOvEA1ZWa2wutOgeCjm0nX4bLEJuDwKHA1SYYtFiRHdiVsOp7uuVMMbra1FHcgxDDFWGayhON2micOEgAJK0cALNw9mmGTf1eQbbxcdDtmEqP3ivNfzOwnRxE6dznCa5vc9zNI61eJSCaf1FHcgxDyY8Coq0HUSGsTqq2uEqZ4qoQ7dgea7a90yKLdOOEgAJK0cALNw9mmGTf1eQbbxcdDtmEqP3ivNfzOwnHK80hYA4aYRe6Zof1nlYGzqkOou)fkyC15ryY8CoRFAB9xlm2uo2Tlq21PsUoqY1P6QDDQQRdmzEoNrYGzqkOoKdfZPO1FdhqxhZX1HhHjZZ5S(PT1FTWyt5y3UazxNk46q46KCDFWGayhOpsgmdsb1H6My8GsVrQolYq9m0gjPf0kpT6zyaBlQjudcUegA1SIYtFiRHdiVsOp7uuVMyKLdOORtvjsU(luW4QZJWK55CsJrwoGICOyAdywZRsqu419bdcGDGEAmYYbuu3eJhu6ns1zrgQNH2ijTGw5PvpddyBrnHAqWLWqRMCLN(qwdhqELqF2POEnnzq)fkyC1tAxNTzqgWGW1P6QDDOneiNcjLIS11PcUov0q3hmia2b6Pnzq3eJhu6ns1zrgQNH2ijTGw5PvpddyBrnHAqWLWqRMvrE6dznCa5vc9zNI6pzGru)fkyC119bdcGDGUnzGru3eJhu6ns1zrgQNH2ijTGw5PvpddyBrnHAqWLWqRw9xOGXvxRe]] )

    storeDefault( [[IV Guardian: 4+]], 'actionLists', 20180205.201654, [[dOtIdaGEukBsa1UqHTHsO9HGYSPQ5JsYnrj62kXovQ9s2nf7xiJcfLggvACOO45uAOOiAWc1WfXbfKtHIQogOoSuluGwQiTyqwosFdv8uvltjToeunruKAQuXKrvtxXfLqxffjxg66i68sWwrrLnlrBxq5JiiDAGpJs13fqESOMgcmAe63s6KOs)vaUMGQ7HIWZqq8kucEnkPwWYrNPXYM0pkO(UxqDUmxumHs2uEqBi8Oycyb9u0JTf1E1fMd8QlhgRWHtabmJ(tWmO9a26bunAd7sGEO8aQgRC0gwo6fnnKh5vq9DVG6mLfJI5o4Iv)zkiz01dbb8GPGoPfdam4IvpfTvsAgTYrJEk6X2IAV6cZb2vNRHhK7Ps1nvdQr7v5Ox00qEKxb139cQ7qK2wI6ptbjJUEiiGhmf0hI02supfTvsAgTYrJEk6X2IAV6cZb2vNRHhK7Ps1nvdQrBcro6fnnKh5vq9DVG6SSnS7r9NPGKrxpeeWdMc6lTHDpQNI2kjnJw5Orpf9yBrTxDH5a7QZ1WdY9uP6MQb1OnbYrVOPH8iVcQV7fuNL1QPeqr9NPGKrhISSKb7TVZdiha7KnLh0ggKj6HGaEWuqFPwnLakQNI2kjnJw5Orpf9yBrTxDH5a7QZ1WdY9uP6MQb1OD4YrVOPH8iVcQV7fuNjj9HHuaBO(ZuqYOZJqKLLmgI02smaiSPmStNzDumtefhEumRyvumZgfdrwwYiH0hgsbSHmOyjfTeBipgfh4OyEeISSKXqK2wIbaHnLHD6mRJIjSOy4OyMxpeeWdMc6jK(WqkGnuNRHhK7Ps1nvdQNI2kjnJw5Orpf9yBrTxDH5a7QrBwuo6fnnKh5vq9DVG6pqGeu)zkiz01dbb8GPGUnqGeuNRHhK7Ps1nvdQNI2kjnJw5Orpf9yBrTxDH5a7QrJ(ZuqYORrc]] )

    storeDefault( [[IV Guardian: Default]], 'actionLists', 20180205.201654, [[duZhdaGEvvQnPOIDruSpvvz2KCtIs3gvTtvzVIDJy)s1WKIXPQIgScdNuCqfLNlPJHIdt1cLilvvzXsPLt4BKspfAzkY6qsMisWujYKrPPRYfrk9kKqpdj66syJQQWwrQSzIQTJK6JivDEKIplrnpfv60k9Dfv5VKQFtXjrf3svvDnfv19uvjtdv6YGhtPdtKcsbqUxOUuk4Z5HGCORpOVWfSRtOQpOai3luxWpqbEfYBQHrlZuJwzMyMpxU)miQbSRR2F73Ai5X0Wn4m7Tgsns5XePG0s8wfWMsbrRy1CbBlKlxMwWf6YncEzynZJe858qWsGl6JFye8bN1UQ9Ojyl4cD5gbFqoe216NreKyiqWpqbEfYBQHrlttWpOAkewOgPC5YBksbPL4TkGnLcIwXQ5c62BPg0bcWVqTp(vFWe858qqCjLvqFi5IYWfKdHDT(zebjgce8duGxH8MAy0Y0e8dQMcHfQrkxWzTRApAckki6U9wdrxT1lOSg2NZdb5qxFqFHlyxNqvFGlPScYLhLrkiTeVvbSPuq0kwnxq3El1Goqa(fQ9XF9btFmN(WT3snOdeGFHAFm3(GBWNZdbN(NY(qYfLHRgKdHDT(zebjgce8duGxH8MAy0Y0e8dQMcHfQrkxWzTRApAcADLs3T3Ai6QTEbL1W(CEiih66d6lCb76eQ6JP)PmxECJuqAjERcytPGOvSAUGU9wQbDGa8lu7J)6dkd(CEiixk2hsUOmC1GCiSR1pJiiXqGGFGc8kK3udJwMMGFq1uiSqns5coRDv7rtqRRu6U9wdrxT1lOSg2NZdb5qxFqFHlyxNqvFWLI5YfeTIvZfmxca]] )

    storeDefault( [[IV Guardian: Defensives]], 'actionLists', 20180205.201654, [[dGtFdaGEHOnje2LeETq1(qcZwsZhH03KQStIAVk7w0(HAuiOAye53QYPvzWqgUq5GQQCkeKogfDyQwOqAPG0IvvwoHhlLNsAzs0ZP0erOAQGQjJuth4IGW9KQQUmQRlv2OuvzRiOSzey7GOpIq0ZKQY0qsnpee3grFwGrlOXJKCskyCiuUgf68irRsvvRdHWFbLN5GpfI0)Qm9(MsCMaVRcw0PAmUDE9I0b3lNSPe1tHYv2T8KlLm7zwk1RO00i1utSPAtCXatN(RbUxAh8jBo4tHi9VktVOt1M4IbMgYEfew06ecobyeHGrHSxbHfKovy0FmsQGyyueyeHJrTqxeWwmQ)yuFyerjkgDz7rEzamAN0dyygTyefyui7vqybPtfg9hJKkknIrekgn1qsFnh8etZxYt)9D1dq5uceCg5X0WeCaNSWb3lNcLTVorJTd(atHYv2T8KlLm7zknv2j5P9tWzKhtJrq5aozHdUxoWKlh8PqK(xLPx0PAtCXatXOlBpYldGr7KEadZOfJOaJczVcclADcbNam6pgjvuo1qsFnh8etZxYt)9D1dq50t8sc6etHY2xNOX2bFGPq5k7wEYLsM9mLMk7K8udIxsqNyGj33GpfI0)Qm9IovBIlgykWZ4xgGrrGrx2EKxgaJ2j9agwFwmIcmkK9kiSG0PcJ(JrsfLgNAiPVMdEIP5l5P)(U6bOCQTta5bPxHDPfCzdyNcLTVorJTd(atHYv2T8KlLm7zknv2j5PANaYdsVIrgsl4YgWoWKPEWNcr6FvMErNQnXfdmf4z8ldWOiWOlBpYldGr7KEadZOfJOaJczVccliDQWO)yKurPXPgs6R5GNyA(sE6VVREakN(5I424xofkBFDIgBh8bMcLRSB5jxkz2ZuAQStYtJ6I424xoWatLDsEQbcdJiYoxqFEseyeXzc40EqY2b2a]] )

    storeDefault( [[SimC Guardian: cooldowns]], 'actionLists', 20180205.201654, [[d8JIgaqyjRhIOEjer2fj8AIQ9brILbv2eQaZwuZxvQBkO7cvP(ge12GQe7uk7LA3OSFImkuHmmHACqvPttQHcrsdgvnCIYbvfofuv5yc8mOQyHKOLcLwmKwoHhcfEkYJvXZfzIqvOPcHjRsth0fHIUkufCzLRlvTrOkQTIkAZK02Lk9ris13rf00Gimpis5VczDOc1OrL(SuXjvL8wOQQRbvjDEvrReQICBv1Vb2bgHjmzfAExJAQv)zI0FmK4r69L4QlghlXFaG8fWHSKj6i0YGMmHD5vP5gU4a8noahof4WHpbirGjs2o6kRrYfudyUfeJeMECGAalzeUfyeMWKvO5DTst0rOLbnH2RQQquDweqncYDrP8MSju0lZ0duDwdFAsgaQbmtVyx9PGaHjgGntHGlNLOv)zYuR(Z07JQAC85OQI)ivaudy49BHjSlVkn3WfhGCqSjSlb6fNLmcdnHb3DKhc6U)yqJAkeCB1FMm0nCgHjmzfAExR00duDwdFAcnda3i1EXttVyx9PGaHjgGntHGlNLOv)zYuR(ZKYmaCL4XZ9INMWU8Q0CdxCaYbXMWUeOxCwYim0egC3rEiO7(JbnQPqWTv)zYq3WhJWeMScnVRvA6bQoRHpnHorAc5AwhtVyx9PGaHjgGntHGlNLOv)zYuR(ZKYjstixZ6yc7YRsZnCXbiheBc7sGEXzjJWqtyWDh5HGU7pg0OMcb3w9NjdDdjmctyYk08UwPPhO6Sg(0ujofBrqGqmg00l2vFkiqyIbyZui4YzjA1FMm1Q)m9qCk2K4raeIXGMWU8Q0CdxCaYbXMWUeOxCwYim0egC3rEiO7(JbnQPqWTv)zYq3WRgHjmzfAExR00duDwdFAsuDweqncYDrP8MSjm9ID1NcceMya2mfcUCwIw9NjtT6ptyRotIhOkXd5ojEkVjBctyxEvAUHloa5Gytyxc0lolzegAcdU7ipe0D)XGg1ui42Q)mzOB4fJWeMScnVRvA6bQoRHpnPzNsWkOgWm9ID1NcceMya2mfcUCwIw9NjtT6ptVyNsWkOgW4yjEKKM1rIhOkXd5ojE8upRtEMWU8Q0CdxCaYbXMWUeOxCwYim0egC3rEiO7(JbnQPqWTv)zYq3q2imHjRqZ7ALMOJqldAcw5XGkqf1hnVKIXk08Us8CGephjXJ2RQQquDweqncYDrP8MSju0ltI)9BjEyLhdQi1l6Q7w5iGAeK7Iu1q4sqfJvO5DL4Xptpq1zn8Pj0sipjxZm9ID1NcceMya2mfcUCwIw9NjtT6ptklH8KCnZe2LxLMB4Idqoi2e2La9IZsgHHMWG7oYdbD3FmOrnfcUT6ptg6g(AeMWKvO5DTst0rOLbnDaG8fWHmfIQZIaQrqUlkL3KnHcX(LMLK4rks8b4K4F)wIhTxvvHO6SiGAeK7Is5nztOOxMe)73s8CKepkiLK45ajEyj6mOcO(Viii6QNepstIhhojE8Z0duDwdFAQpTinC)KPxSR(uqGWedWMPqWLZs0Q)mzQv)z69rvno(CuvXF8qAs8VG7NW73ctyxEvAUHloa5Gytyxc0lolzegAcdU7ipe0D)XGg1ui42Q)mzOHMWJtT6ZqR0qBa]] )

    storeDefault( [[SimC Guardian: default]], 'actionLists', 20180205.201654, [[dm0gpaqisOwePkQnrv1OKcNskAxKYWirhtvSmvONPc00Ku4AsQQTrcX3OkzCsQsNJufyDskQ5rQ09ivP9Pc4GKGfsQQhsQyIKqIlsvQpkPkoPKsZKes5MQs7KKgkjKQLsv5PctLk1wvb9wsiP7sQcAVq)LidMWHPSyI6XIAYs1Lv2mv8zQIrlLonOvtQc9AvLMTi3wL2nQ(nIHRIoUQIwospxIPdCDjz7QQ(UQcJNuf58sQSEjfz(uj7hLXh0ngEZn506OmgQ2DyeWRomr9uz0o041mt0NJvLayezk8eGbg(wAwzO6rLp1RYNJh1oE8Gp14bJ4CzOLG1KbGeoQ(OSgyOqgaj8c6gvFq3y4n3KtRJ6JHQDhgX3QuIj03kTyulVdZgGqXGt4ddfKHjiOomkFRsjjzR0IHVviv08kOBeGHVLMvgQEu5JxpkXiYu4jadeGQhr3y4n3KtRJ6JHcYWeeuhgzlLKSmas4sjybGrT8omBacfdoHpmEj9dnQQDhgyOA3HHRSJJsL5SJJIQowkXekKbqcNju0GfGEOlkgkq9uWGB3Px9CaV6We1tLr7qJxZmrMqsDYh8IEgdFlnRmu9OYhVEuIHVviv08kOBeGHoTl)9L8V74augJxsx1UdJaE1HjQNkJ2HgVMzImHK6Kp4feGQheDJH3CtoToQpgrMcpbyKjKuN8bxd0sTsRK8mQgDxdYlmXbycp5ot4NjSma(pPX3fUctCaM4Hj8Zewga)N047cxHj0LjueMWLlMWYa4)KgFx4kmHEzIhMWptqnptRphygcycDzI6fdfKHjiOomUwvcJA5Dy2aekgCcFy8s6hAuv7omWq1UdJxRkHHVLMvgQEu5JxpkXW3kKkAEf0ncWqN2L)(s(3DCakJXlPRA3Hbcq1AGUXWBUjNwh1hJitHNamYesQt(GRbAPwPvsEgvJURb5fMqxM4it4Nj6eGgOLALwj5zuTcWYFzc9YeDcqd0sTsRK8mQ210tsfGL)wWqbzyccQdJZQ0)OWAAyulVdZgGqXGt4dJxs)qJQA3HbgQ2DyOOxL(hfwtddFlnRmu9OYhVEuIHVviv08kOBeGHoTl)9L8V74augJxsx1UddeGQ1hDJH3CtoToQpgrMcpbyOyMayPXbAESKLbWSKNkJ2HgxBCtoTot4NjAWekMj6eG2Lq4oq60aW8xi3dt4Yft0GjKRCC0G8Sr5gas4AvNmHFMOtaAxcH7aPtJoh6kTMCAmrtMOjt4NjSma(pPX3fUctOxM4bdfKHjiOomUec3bshg1Y7WSbium4e(W4L0p0OQ2DyGHQDhgVec3bshg(wAwzO6rLpE9OedFRqQO5vq3iadDAx(7l5F3XbOmgVKUQDhgiavve0ngEZn506O(yezk8eGrdMObtix54Ob5zJYnaKW1Qozc)mrdMOtaAGwQvALKNr1OZHUsRjNgt4Yft0Gj2NvWZZ11svooM0hu78eY9uycxUycJcGowgOPhnpEwxkNSpkAuJ)LjoatudMOjt0KjAYeUCXeDcqd0sTsRK8mQwby5VmHUmrNa0aTuR0kjpJQDn9Kuby5VfMWLlMObtSpRGNNRRLQCCmPpO25jK7PWe(zcJcGowgOPhnpEwxkNSpkAuJ)LjoatuFMOjt0Kj8ZekMjawACGwHuLKiosG2j5qORa0g3KtRZeUCXewga)N047cxHjoat8GHcYWeeuhgGwQvAXOwEhMnaHIbNWhgVK(Hgv1UddmuT7WWDl1kTy4BPzLHQhv(41Jsm8TcPIMxbDJam0PD5VVK)DhhGYy8s6Q2DyGau1l0ngEZn506O(yezk8eGHLbW)jn(UWvycDzIAGHcYWeeuhgxJ7jnmQL3HzdqOyWj8HXlPFOrvT7Wadv7omEnUN0WW3sZkdvpQ8XRhLy4BfsfnVc6gbyOt7YFFj)7ooaLX4L0vT7WabOA9IUXWBUjNwh1hdfKHjiOomaTuR0IrT8omBacfdoHpmEj9dnQQDhgyOA3HH7wQvAzIgpnXW3sZkdvpQ8XRhLy4BfsfnVc6gbyOt7YFFj)7ooaLX4L0vT7WabOQEa6gdV5MCADuFmImfEcWqUYXrZJLSmaML8uz0o04AvNmHFMObt0GjAWekMj(nk0KttlzGSeHk5q4s7Zk4556mHFMWYa4)KgFx4kmHUmrnyIMmHlxmrdM43OqtonTKbYseQKdHlTpRGNNRZe(zcldG)tA8DHRWe6Ye1NjAYenzcxUyIobODjeUdKon6COR0AYPXe(zIgmHIzIFJcn500sgilrOsoeU0(ScEEUot4NjSma(pPX3fUctOltuFMOjt4Yft0Gj(nk0KttlzGSeHk5q4s7Zk4556mHFMWYa4)KgFx4kmHUmHIWenzIMyOGmmbb1HXLq4oq6WqN2L)(s(3DCakJXlPFOrvT7Wadv7omEjeUdKoMOXttmuG6PGbWOEgqc6Ox5khhnpwYYaywYtLr7qJRvD6VrJgk(3OqtonTKbYseQKdHlTpRGNNR73Ya4)KgFx4k6wJMUC143OqtonTKbYseQKdHlTpRGNNR73Ya4)KgFx4k6w)MnD5QtaAxcH7aPtJoh6kTMCA(BO4FJcn500sgilrOsoeU0(ScEEUUFldG)tA8DHROB9B6YvJFJcn500sgilrOsoeU0(ScEEUUFldG)tA8DHRORI0Sjg(wAwzO6rLpE9OedFRqQO5vq3iaJA5Dy2aekgCcFy8s6Q2DyGau9rj6gdV5MCADuFmImfEcWOtaAxcH7aPtJoh6kTMCAmHFMqXmbWsJd08yjldGzjpvgTdnU24MCADmuqgMGG6W4siChiDyOt7YFFj)7ooaLX4L0p0OQ2DyGHQDhgVec3bsht04ytmuG6PGbWOEgqc6O3obODjeUdKon6COR0AYP5xXalnoqZJLSmaML8uz0o04AJBYP1XW3sZkdvpQ8XRhLy4BfsfnVc6gbyulVdZgGqXGt4dJxsx1UddeGQppOBm8MBYP1r9XiYu4jadldG)tA8DHRWe6Yekct4NjAWezcj1jFW1OMNjrCKaTtQK2ohvJURb5fM4amXJsMWLlMqUYXrJAEMeXrc0oPsA7CuTQtMOjgkidtqqDyCTQeg1Y7WSbium4e(W4L0p0OQ2DyGHQDhgVwvIjA80edFlnRmu9OYhVEuIHVviv08kOBeGHoTl)9L8V74augJxsx1UddeGQphr3y4n3KtRJ6JrKPWtagDcq7siChiDA05qxP1KtJj8Zewga)N047cxHj0LjoigkidtqqDyCjeUdKom0PD5VVK)DhhGYy8s6hAuv7omWq1UdJxcH7aPJjACWMyOa1tbdGr9mGe0rVDcq7siChiDA05qxP1KtZVLbW)jn(UWv09Gy4BPzLHQhv(41Jsm8TcPIMxbDJamQL3HzdqOyWj8HXlPRA3Hbcq1NdIUXWBUjNwh1hdfKHjiOomkFaphg1Y7WSbium4e(W4L0p0OQ2DyGHQDhgXhWZHHVLMvgQEu5JxpkXW3kKkAEf0ncWqN2L)(s(3DCakJXlPRA3HbcqagkkZXQsauFeGi]] )

    storeDefault( [[SimC Guardian: precombat]], 'actionLists', 20180205.201654, [[dCZbdaGEiO2LuXRPenBPmFi1nvWDHiDBfTtLSxXUjSFkvdJu(nOHkvvgmLYWvQdkv6Xu5yKQJtvzHuvTuuPfJQworpes6PiltHEovzIucnvuYKPy6qDriQdl5YQUoGncbzRqInJITlv5JqaZsQkMgeX4KQsNhL6TucgnQ4zqOojLK)c0Pj5EqiFgc06KQQ(gLuh9WkeYIIVDt4dTQ5drQjQ2THaaL0Okr)TBBlVdo5lCiYjvBCOqCF7L3ZAutVVA6JJDghrSos0dr77uvtHWfwbfzPRHKqDDyfu4fwzPhwHqwu8TBI)qKtQ24q3hGAVVPtRmSblHbeZ5GooQMXUn0OTB7(au79nDyaKSbHmGIcdiFOU8QMcZouVsQk(2dHkN7SCa27ZlWHp0a0Gsjx18HAf2bcLGmqb49bO27BcTQ5dH2XWOP5CmmwGWq5TBdLQbCKIwgQReb9cjQ5ruRWoqOeKbkaVpa1EFtF6vnGJO7dqT330Pvg2GLWaI5CqhhvZGg99bO27B6Waizdczaffgq(qCF7L3ZAut3ADTqCVheq6UxyfCiRegLRWqzibu8qdqZQMpuWzngwHqwu8TBI)qD5vnfMDi(xsqgOCgYkHr5kmugsafp0a0Gsjx18HcTQ5d5)L0UneckNH4(2lVN1OMU16AH4EpiG0DVWk4qOY5olhG9(8cC4dnanRA(qbNfIdRqilk(2nXFOU8QMcZo0gIvqriRegLRWqzibu8qdqdkLCvZhk0QMpeAhdJMMZXWyH(bXkOaPOLH4(2lVN1OMU16AH4EpiG0DVWk4qOY5olhG9(8cC4dnanRA(qbhCilEMcOHJ)Gta]] )


    storeDefault( [[Feral Primary]], 'displays', 20171207.215448, [[dWJZgaGEf0lrsAxQsITHeWmPQQzlvpgf3ejQJJK6BQssxtbANuzVIDt0(rL(PIAyQIFd5WsgksnyuLHdvhukEoLogfoNQKYcLslfv0Ij0Yj1dPQ8uWYqfwhsqtKQknvv1KrvnDLUOcDvKixwLRJOncfBvvs1Mjy7i4JQs8zO00qc57uLrIK4zuvXOrPXRk1jrOBHeQttY5POxRawlsGUTICmYpatHVkKedsUWA2VaZu67pr3yaMcFvijgKCb1WlodocOlj2Zh7XmqAdqn5rEnDfw50j3ambmNfeS36RWxfsAJ7jW7zbb7T(k8vHK24EcGRvtL2KidscQHxCd(eysjBgJZpbOM8ip((k8vHK20gWCwqWE7V0yV1g3tallYd8uldBZyAd8EwqWE7V0yV1g3tafdsc4fJsInUbdSLg7TnsgwKoq78)ptzoj(cv(bmJJI5WppbEh3tallY7xAS3AtBGbeBKmSiDG)mnNeFHk)akjFftTiDJKHfPdWjXxOYpatHVkKSrYWI0bAN))zkhaWpgv1vdRvHKXz84NawwKh8tBaQjpYZVk9XSkKmaNeFHk)asYjImiPnokkGf)6Dm9YY6d1r68duXzeqmoJayJZiGooJSbSSipFf(QqsBed8EwqWEBdPUI7jqrQRVj(fqKuqiWu9UHCrX9eqSRgo8LoYRP3JyGQJZwalYJMWyCgbQooB5dnjwlnHX4mc43tOi7BAduDVY0stGoTbiOSkrvxTMFt8lGyaMcFviztxHvgW3O7pYza(klEVm)M4xGkGUKyVVj(fOevD1AgOi1fLvYlTbgqedsUGA4fNbhbQooB9ln2BPjqhNra91d4B09h5mGf)6Dm9YYgXavhNT(Lg7T0egJZia1Kh5XNOKVIPwK2M2a(q4MC59rbWC6QZLxZ8ya(Nqr23gA)daQjFC5H50vNc5YJ)juK9nWwAS3Ibjxyn7xGzk99NOBmGasUbO)C5bL0YLNR0AKxGIuxeLcOVj(fqKuqiGLf51qUO0gO64Svt3RmT0eOJZiGIbjPGi0uCgdgaxRMkTjgKCb1WlodocGRpg0KyTn0(haut(4YdZPRofYLhU(yqtI1gWYI8Ai1frPakIbMQ3nJX9eGAYJ84tKbjb1WlUbFcSLg7T0egJyaXUA4Wx6iVigWYI8O6zkQK8vsS20gGbnjwlnHXigyln2BPjqhXaMZcc2Bjk5RyQfPTX9eWCwqWEBdPUI7jW7zbb7TeL8vm1I024EcyzrEeL8vm1I020gysjBixuCpbQUxzAPjmM2awwKhnHX0gWYI8AgtBag0KyT0eOJyGIuxa(17e9BCpb2sJ9wmi5gG(ZLhuslxEUsRrEbgqedsUWA2VaZu67pr3yGjLe(X9eyln2BXGKlOgEXzWrGQJZwnDVY0stymoJamf(Qqsmi5gG(ZLhuslxEUsRrEbQooB5dnjwlnb64mcmklX(XpTbSQj8(1mpghhbOMuXmWRRSWA2VavGbeXGKBa6pxEqjTC55kTg5fWYI8ap1YW2qUO0gOi1vJKHfPd0o))Zu2)rm)aCE9RSxCC8y8Qgggu0RyqbgCWNxlGLf5rtGoTbmNfeS3s1wBCuSrGP6n8JZiq1XzlGf5rtGooJautEKhFmi5cQHxCgCe49SGG9wQ2AJZia1Kh5XNQT20gWvtxamNU6C5rRvtL2mqrQlkjvBa8EzE6Sj]] )

    storeDefault( [[Feral AOE]], 'displays', 20171207.215448, [[dWtZgaGEPuVefQDHcWRvfmtPeZwQEmsUjkKJJQ42kQPrvu7Kk7vSBI2pb(PcnmvPFd5WsgkQmycA4q1bPQonPogHohkqTqfzPufwmsTCkEivPNcwgkQ1HcQjsvKPQQMmQQPR0fvWvrrCzvUoI2iuAROaAZKy7i4Jsj9muK(mu8DPyKOk55uA0O04vfDse6wOk11uf68K03qbP1IcKTHcIJy(bOk8vJKyrYfw1(fyKj)wi6gcqv4RgjXIKlOBFXjYCatjXCEzpQhYuaEipYZVRXiNp5gGkG6OII9wVf(QrsBCVbEoQOyV1BHVAK0g3BaCJEUmQePqsq3(IZZVbM1s)H4yAaEipYJV3cF1iPntbuhvuS3(ldMBTX9gWYIAGg9sX6pe6aphvuS3(ldMBTX9gqtHKaErPLyI7XafPPikvqFv8lanPIsa144nZm9nWZ44TitFmGLf18ldMBTzkWd0(skwKjWFKZdITYRFaTKVMQwKXxsXImb8GyR86hGQWxns6lPyrMatJ))iJc4fHRkq4hfa7zQUaH(JdbSSOg4NPa8qEKNN0MJA1izapi2kV(bKKZePqsBCIbS4xVJTxwwVOoYKFGkoXaM4edGjoXa0XjMnGLf14TWxnsAdDGNJkk2B9jnvCVbkst9vXVa0KkkbMRN(KlkU3a0DD72T2rn(9EOduDC2cyrnCegItmq1XzlVOz6A5imeNyapDkfzFZuGQ3uQwocCzkabTvtR76v9RIFbOdqv4Rgj97AmYaEhC)bpcWxBX7L6xf)cqfWusm3xf)cu06UEvduKMIrA5LPapqJfjxq3(ItK5avhNT(LbZTCe4ItmG56b8o4(dEeWIF9o2EzzdDGQJZw)YG5wocdXjgGhYJ84tuYxtvlYyZuaa)O0vx3UwnsgN4ltd4Q5la2ZuDbc9hhcSLbZTyrYfw1(fyKj)wi6gc8CurXElJNSXjgyUEc)4edyzrn(Klk0bQooB53BkvlhbU4eduDC2cyrnCe4ItmaUrpxgvSi5c62xCImha3CuOz6A95AjaON9kqi2ZuDgwGqCZrHMPRnG6OII9wgpzJJ3IbMRN(dX9gWYIA8jnfrPck0b2YG5wocdHoGLf1WrGltbSSOggFQ0AjFTeJntb846xzV4y(vKHkkk6zgGid5XhFzWbkst5lPyrMatJ))iJAza7pGLf1an6LI1NCrzkWd0yrYna3xGqOKwbcDLXGAcWdPM6bgO2cRA)cqhWYIAik5RPQfzSzkWSw6tUO4Edu9Ms1YryitbSSOg)HqhWYIA4imKPauOz6A5iWf6avhNT8IMPRLJaxCIb2YG5wSi5gG7lqiusRaHUYyqnbQooB53BkvlhHH4edmRLWpU3aBzWClwKCbD7lorMd8anwKCHvTFbgzYVfIUHauf(QrsSi5gG7lqiusRaHUYyqnbkstb4xVt0tX9gyqw09JFMcy1Z49ZFCioMd8CurXElrjFnvTiJnU3aQJkk2B9jnvCVbuhvuS3suYxtvlYyJ7nWwgm3YrGl0bOqZ01Yryi0bO762TBTJAcDaEipYJprkKe0TV488BafKCdW9fiekPvGqxzmOMaAkKKbHqZXj(yaEipYJpwKCbD7lorMdSLbZT(skwKjW04)pYipi2kV(b4H8ip(mEYMPa8pLISV(CTea0ZEfie7zQodlqi)tPi7BGI0umrQ3a49s9mztaa]] )

    storeDefault( [[Guardian Primary]], 'displays', 20180121.231355, [[d4dZhaGEvHxIiAxicTnPkoSKzsj6CisMTQACksDtsr9yK6BKICAI2jvTxXUjSFf4NiyysLFd65uzOKQblv1WrPdkLUSshJIoUcAHsXsruTyk1Yj5HuspfAzQG1rkWeLQutfvMSkA6axeHUkPqpdrW1vPnskTvPkPnJQ2os8rvrFvQs8zK03vOrsjmnvOrJIXJOCsvPBHi11ueNNcVwrYAjf0TvuhZWfKUybsOqluaqGXFdsqJCw(6jgeukQlqNIESdQkb11kZspvAcA)LpE88dhJDqdc88UfyTybsOWfFxWH39UNV0qHfRKkdi(jDbhE37E(sdfO8Xg)KUGog4y7vvVcEySdo8U390AXcKqHlnbjZWkuqzvG9mnbniWZ7waxPOUax8DbDmWrCucOzAjMMGKrGN3TaUsrDbU47coxKHCXBgeukQlOvqZavbBiWXrqZK)(0cUGgrlPN(4XJhoQPEivNM66HutmdpPpojipuacQZnOpwc3G((sPGJbDmWrUsrDbU0eCk7wbndufKJGo5VpTGl4W7E3ZxAOOxKNaM4N0fKvjNlLXlnuyXkPYaIFsxqP4usxaOQvqZavbj)9PfCbPlwGekAf0mqvWgcCCe0CqKDPL1x(OasOiEZUJbDmWrKlnbhE372BPAPbsOii5VpTGlO4o)sdfU4pg0XU)V2F5ySc)qv4cwXBgufVzqQXBg0oEZac6yGJwlwGekCXoize45DlO9QQ47cEU819dA1TmikNToO)ZBPoLLqdg0)C5R7heC4vspvVkDiW4VbRGZfzTxam(UG2F5Jhp)WX2)p2bRpltHmWrDkeJ3my9zzkRWz7cOtHy8Mb79Yx3pinbNLI2lagFxW6pwgoDk6PjifPtAl)sGbNb7g0oiDXcKqr7xsve0krphrYdEkDS)YGZGDdwbhE37EsYgxAcQkb1LZGDdw2YVeyeSUQsZsXMMGdV7DBf0mqvqYFFAbxWPS1cfau(yJ38qqdc88UfqYgx8K2my9zzkUsrDb6u0J3mize45DlGKnU4ndQ2FqRe9CejpOJD)FT)YXe7G1NLP4kf1fOtHy8MbL0qHgcHZXtcDbhE37E(koL0faQCPjij3LT1XU0aYlGeMMGog4y7fattqqPOUaTqbabg)nibnYz5RNyWzPOLy8KqWH39UiW4Vbj)9PfCbhE372(LufZRaeKoy9zzQ2)yz40POhVzqA4SDb0Pqm2bzvY5szOfkaO8XgV5HGSQLgoBxGwDldIYzRd6)8wQtzj0Gb9zvlnC2UabniWZ7wWR4usxaOYfFxW5ISwIX3f0GapVBbTxvfFxqqPOUaDkeJDqY3)wUn(dDMAY8qNMiXdMtoEC6Gog4ijxdBP4ukO6stqYiWZ7wWR4usxaOYfFxW6QQwbndufSHahhbnBjrTCbRRQq29)F7D8DbPlwGek0cfau(yJ38qqjnuGSfTuqn(jbDmWXxXPKUaqLlnbRplt1(hldNofIXBgS(JLHtNcX0e0XahBjMMGog4OofIPjinC2Ua6u0JDWPS1cfGG6Cd6JLWnOVVuk4yWPS1cfaey83Ge0iNLVEIbbLI6c0cfGG6Cd6JLWnOVVuk4yWzPa5IVliOuuxGwOaGYhB8Mhco8U3TvqZave45Dli(jbPlwGek0cfGG6Cd6JLWnOVVuk4yW6ZYuwHZ2fqNIE8Mbjkk7)EMMGo5m7FBjqm(dbTSCaRqbLv5Kqr8h6mNUZ08ijscbDmWrDk6PjiRsoxkJxAOaLp24N0f0xZBWN3sDklXG(6k5CPmcsgbEE3cSwSaju4IVlOJboIJsant7fattW6QQxbpKZGDdAF55dQHq4SvOGYQa7zAcwFwMczGJ6u0J3m4W7E3tTqbaLp24npeKSOL0t6HuKA6EMEAZjh6XShsDm8K(ypbzvY5sz8sdf9I8eWe)KUG1vvCgSBq7lpFW6QknkKGGS)YyvbKa]] )

    storeDefault( [[Guardian Defensives]], 'displays', 20180121.231355, [[dWtPhaGELuVebzxeO8AayMsKMTkDyPUjPqJJGY3KiwMsYoP0Ef7gv7hG(jGgMe(nOlRyOKQbJadhLoOKCAIogv64kHfsvTueXIPklNIhkr9uOhJK1bG0ejqMkkMSs10v1fbYvjO6ziOUUk2iP0wbqSzcTDG6JeWxbqnnLOVlPgjPOpJOgnsnEePtQuUfPGRrqopv8CswlbQUncDCdtqQM9LqUwi)X35obbkCMs3SGc(TH886G1JxqtZjpLPhkae)GEx561cCH1XlOdqrr18LB2xc5QylcU4mNzFJcY1CKKP)yxweCXzoZ(gfKJY1tSllcQOH1vhtVXfHXl4IZCM9Yn7lHCv8dsQtzih8y(zp(bDakkQMNPnKNxfBrqfnSgRLpfDfO4hurdRRopm(bj2KImX6g8Bd55R4u0qtqFGmma1ijBcOjtqsbkkQMNq(QyDdsASAy1kHcQOH1mTH88Q4heaEvCkAOjidqDs2eqtMGloZz23OGCawU)0XUSiiRrsSnoBuqUMJKm9h7YIGs(UKQFOPItrdnbjztanzcs1SVeYR4u0qtqFGmma1yqKDOK9vUUFjKhRBXYGkAynYe)GloZzeK0muVeYdsYMaAYeKFiUrb5QyDdQyN7v7Tv0LHxOjmb7yDdAI1ni5yDd6fRB(GkAyD5M9LqUkEbjfOOOA(QJPJTiyFmnJd7e07ikguqJyFUF8dsSjT68Wylc6DLRxlWfwxDVXlyFzPBKgwRdguSUb7llDxgs0RFDWGI1nirjV68Wylc6auuunF1X0XweSV1TJshSE8dcwQKEYR8DyCyNGEbPA2xc5vxjzEWYGSmGij4UuXEBhgh2j4EWfN5m7eYxf)GMMtEyCyNGTN8kFNG9X0AuYN4hCXzotfNIgAcsYMaAYeeaEAH8hLRNyDxf02eNGcCAZUS5asGGgXHRKGhvW(Ys3mTH886G1J1niHMHTsXoupj9lHXpOzUbldYYaIKGk25E1EBfD8c2xw6MPnKNxhmOyDd2xw6gPH16G1J1n4IZCM9n(UKQFOrf)GorRgwkeHfwjLuIqcvsrHWiCjcfrnSuOGIq(huNbqcWMRaKaBBmW6GFBipVwi)X35obbkCMs3SGcsbj61VoyqXl4IZCg8DUtqs2eqtMGun7lHCTq(JY1tSURc2xw6U6w3okDW6X6gSVS0D1TUDu6GbfRBqwJKyBC0c5pkxpX6UkiRzOGe96VsV0ylcU4mNP6kjZjo8pivqInPvGITiOIgwRdwp(b)2qEEDWGIxqsM70Qj2vfUL4UQOebBLRqlxkSGkAynHghpjFxYjRIFqa4PfY)G6masa2CfGeyBJbwhKuGIIQ5347sQ(HgvSfb7llDxgs0RFDW6X6g0bOOOA(n(UKQFOrfBrWVnKNxlK)b1zaKaS5kajW2gdSoOIgwVX3Lu9dnQ4hSpMEJlczCyNGEhrXG9TUDu6Gbf)GkAyToyqXpOIgwxbk(bPGe96xhSE8cskqrr18mTH88QylcU4iPaaarQW35ob7G9X0vCkAOjOpqggGASuqAzcsuYrMylc(TH88AH8hLRNyDxfCXzotfNIgAakkQMpwHcs1SVeY1c5FqDgajaBUcqcSTXaRd2htJSZ9UjOylccI3E3zp(bvsIS3PciOyxfS0w9LHCWJrjH8yxv4kScx3LcgHdYAKeBJZgfKJY1tSllckPGCKTPKCYXkuqfnSgRLpfD15HXpiPaffvZxUzFjKRITiOdqrr18eYxfRgCdsuYRaflHdk4qiXYqo4X8ZE8dkPGCbhcjglHlcU4mNzxlK)OC9eR7QGaWtlK)47CNGafotPBwqbznsITXzJcYby5(th7YIG7JyFUFLEPb3aiasGaN2SlBoafqce0ioCLe8Oc2htlCU8dYEBNXKpba]] )


end

