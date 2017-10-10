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


        setPotion( "old_war" )
        setRole( "attack" )

        -- Talents
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

        --[[ Soul of the Forest: Your finishing moves grant 12 Energy per combo point. ]]
        addTalent( "soul_of_the_forest", 158476 ) -- 21708

        --[[ Typhoon: Strikes targets within 15 yards in front of you with a violent Typhoon, knocking them back and dazing them for 6 sec. Usable in all shapeshift forms. ]]
        addTalent( "typhoon", 132469 ) -- 18577

        --[[ Wild Charge: Fly to a nearby ally's position. ]]
        addTalent( "wild_charge", 102401 ) -- 18571


        -- Traits
        addTrait( "ashamanes_bite", 210702 )
        addTrait( "ashamanes_energy", 210579 )
        addTrait( "ashamanes_frenzy", 210722 )
        addTrait( "attuned_to_nature", 210590 )
        addTrait( "bloodletters_frailty", 238120 )
        addTrait( "concordance_of_the_legionfall", 239042 )
        addTrait( "fangs_of_the_first", 214911 )
        addTrait( "feral_instinct", 210631 )
        addTrait( "feral_power", 210571 )
        addTrait( "ferocity_of_the_cenarion_circle", 241100 )
        addTrait( "fury_of_ashamane", 238084 )
        addTrait( "hardened_roots", 210638 )
        addTrait( "honed_instincts", 210557 )
        addTrait( "open_wounds", 210666 )
        addTrait( "powerful_bite", 210575 )
        addTrait( "protection_of_ashamane", 210650 )
        addTrait( "razor_fangs", 210570 )
        addTrait( "scent_of_blood", 210663 )
        addTrait( "shadow_thrash", 210676 )
        addTrait( "sharpened_claws", 210637 )
        addTrait( "shredder_fangs", 214736 )
        addTrait( "tear_the_flesh", 210593 )
        addTrait( "thrashing_claws", 238048 )

        -- Auras
        addAura( "astral_influence", 197524 )
        addAura( "bear_form", 5487, 'duration', 3600 )
        addAura( "berserk", 106951 )
        addAura( "bloodtalons", 145152, "max_stack", 2, "duration", 30 )
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
        addAura( "incarnation", 117679 )
        addAura( "infected_wounds", 48484 )
        addAura( "ironfur", 192081 )
        addAura( "mastery_razor_claws", 77493 )
        addAura( "moonkin_form", 197625 )
        addAura( "omen_of_clarity", 16864 )
        addAura( "predatory_swiftness", 69369, "duration", 12 )
        addAura( "primal_fury", 159286 )
        addAura( "prowl", 5215, "duration", 3600 )
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
        addAura( "thrash_bear", 77758, "duration", 15, "max_stack", 3 )
        addAura( "thrash_cat", 106830, "duration", 15, "tick_time", 3 )
            modifyAura( "thrash_cat", "duration", function( x )
                return talent.jagged_wounds.enabled and x * 0.8333 or x
            end )
            modifyAura( "thrash_cat", "tick_time", function( x )
                return talent.jagged_wounds.enabled and x * 0.8333 or x
            end )
        addAura( "tigers_fury", 5217 )
        addAura( "travel_form", 783 )
        addAura( "wild_charge", 102401 )
        -- addAura( "wild_charge_movement", )
        addAura( "yseras_gift", 145108 )


        addToggle( 'artifact_ability', true, 'Artifact Ability',
            'Set a keybinding to toggle your artifact ability on/off in your priority lists.' )

        addSetting( 'artifact_cooldown', true, {
            name = "Artifact Ability: Cooldown Override",
            type = "toggle",
            desc = "If |cFF00FF00true|r, when your Cooldown toggle is |cFF00FF00ON|r then the toggle for your artifact ability will be overridden and your artifact ability will be shown regardless of its toggle above.",
            width = "full"
        } )

        addSetting( 'regrowth_instant', true, {
            name = "Regrowth: Instant Only",
            type = "toggle",
            desc = "If |cFF00FF00true|r, Regrowth will only be usable in Cat Form when "
            })


        addGearSet( 'fangs_of_ashamane', 128860 )
        setArtifact( 'fangs_of_ashamane' )


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
            known = function() return equipped.fangs_of_ashamane and ( toggle.artifact_ability or ( toggle.cooldowns and settings.artifact_cooldown ) ) end,
        } )

        addHandler( "ashamanes_frenzy", function ()
            removeStack( "bloodtalons" )
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
        } )

        addHandler( "berserk", function ()
            applyBuff( "berserk", 15 )
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
            cooldown = 22.046,
            charges = 2,
            recharge = 22.046,
            min_range = 0,
            max_range = 0,
            usable = function () return buff.bear_form.up end,
        } )

        addHandler( "frenzied_regeneration", function ()
            applyBuff( "frenzied_regeneration" )
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

        addAbility( "incarnation", {
            id = 102543,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            talent = "incarnation",
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
            usable = function() return toggle.interrupts and target.casting end,
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


        -- Swipe (Cat)
        --[[ Swipe nearby enemies, inflicting X to Y Physical damage.  Deals 20% increased damage against bleeding targets. ]]
        addAbility( "swipe_cat", {
            id = 106785,
            spend = 40,
            spend_type = "energy",
            cast = 0,
            gcdType = "melee",
            cooldown = 0,
            min_range = 0,
            max_range = 8,
            known = function () return buff.cat_form.up end,
            -- usable = function () return buff.cat_form.up end,
        } )

        modifyAbility( "swipe_cat", "spend", function( x )
            if buff.clearcasting.up then return 0
            elseif buff.berserk.up then return x * 0.5 end
            return x
        end )

        addHandler( "swipe_cat", function ()
            gain( 1, "combo_points" ) 
            removeStack( "bloodtalons" )
            removeStack( "clearcasting" )            
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

        addAbility( "thrash_cat", {
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
            known = function () return buff.cat_form.up or buff.bear_form.up end,
        } )

        modifyAbility( "thrash_cat", "spend", function( x )
            if buff.clearcasting.up then return 0
            elseif buff.berserk.up then return x * 0.5 end
            return x
        end )

        addHandler( "thrash_cat", function ()
            applyDebuff( "target", "thrash_cat" )
            active_dot.thrash_cat = max( active_dot.thrash_cat, true_active_enemies )
            removeStack( "bloodtalons" )
            removeStack( "clearcasting" )
            if target.within8 then gain( 1, "combo_points" ) end            
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


    storeDefault( [[SimC Feral: opener]], 'actionLists', 20171006.174729, [[dGZvgaGEcrAtsP2ff2gHGMTQ6MsXTr0ovQ9k2nP2pGrriKHHGFl50u5XQyWanCcoirXPOQOoMsCCQQAHeQwQsAXQ0Yb9qcPNIAzQsEojhwXurOjtPPJ0fjuoVuYLHUUuTrQkyReL2mvz7uuFMiTocbMgvfzEeI4VQIVPk1OjINriQtsu13jQCnQQCpQk0HOQ0NieQxtrolHyyX0Z9J2CdVhsmm7iffa0hq48fbaGLaQry4v8JJcZ(fHL3e8JWIXsywapU57ePd1v6SxiiYHL5qDLwfIzVeIHftp3pAJ4H5d0jqdF7EEgcWsUVrxiSmx33rBfgoMWWYRTUZqlyyDPXWnLv2bUhsmC49qIHxhty4v8JJcZ(fHL3lecVIQQdpOkednSOsWJPMYmsIAAUHBk7EiXWHM9RqmSy65(rBepmFGobA4B3ZZqnMhP4dSgOHTKthwMR77OTcRgZJu8bwdmS8AR7m0cgwxAmCtzLDG7HedhEpKyyEmpsraW1AGHxXpokm7xewEVqi8kQQo8GQqm0WIkbpMAkZijQP5gUPS7HedhA2ICigwm9C)OnIhMpqNanmTKk9JgNQ(2soTcaSnaOica8298muJ5rk(aRbA0faaBda6lai6F3jiGwdlC6sLqFkVhv1)kaqFoSmx33rBf(IqfcnfwET1DgAbdRlngUPSYoW9qIHdVhsmS4iuHqtHxXpokm7xewEVqi8kQQo8GQqm0WIkbpMAkZijQP5gUPS7HedhA2(uigwm9C)OnIhMpqNan8T75zCrOcHMm6caGTba9fae9V7eeqRHfoDPsOpL3JQ6FvyzUUVJ2km1jfHQhVoSvy51w3zOfmSU0y4MYk7a3djgo8EiXWeDsrOiwba6dDyRWR4hhfM9lclVxieEfvvhEqvigAyrLGhtnLzKe10Cd3u29qIHdnB)cXWIPN7hTr8W8b6eOHpf5TEekNMQmoDie1uaqFea0paW2aG3UNNX9xLLo)sRmSLCAaW2aG3UNNHaeTdTGTEuY58OAuPm6caGTba9fae9V7eeqRHfoDPsOpL3JQ6FvyzUUVJ2kmeLcl5OsclV26odTGH1Lgd3uwzh4EiXWH3djgEfLcl5OscVIFCuy2ViS8EHq4vuvD4bvHyOHfvcEm1uMrsutZnCtz3djgo0SfHHyyX0Z9J2iEy(aDc0WNI8wpcLttvgNoeIAkaOpca6hayBaWB3ZZ4(RYsNFPvgDbaW2aG(caI(3DccO1WcNUuj0NY7rv9VkSmx33rBfg6eclV26odTGH1Lgd3uwzh4EiXWH3djgE1jeEf)4OWSFry59cHWROQ6WdQcXqdlQe8yQPmJKOMMB4MYUhsmCOz)oedlMEUF0gXdZhOtGg(uK36rOCAQY40HqutbafjaG(ba2ga8298muJ5rk(aRbA0faaBda6lai6F3jiGwdlC6sLqFkVhv1)QWYCDFhTvyLeiAdlV26odTGH1Lgd3uwzh4EiXWH3djgMLarB4v8JJcZ(fHL3lecVIQQdpOkednSOsWJPMYmsIAAUHBk7EiXWHgAy(aDc0WHMa]] )

    storeDefault( [[SimC Feral: default]], 'actionLists', 20171006.174729, [[d8dsjaqAIwpkQ8suuLDrO2gPO0(ef0mjfvESKMTIMpkk3KK2KOi3wjNNuANsSxQDJ0(jyuKIIHPqJJuK8As03qGbJsdNqoOO0PifHJrQohPiAHiulvQAXiA5O6HsLEkyzsfpxKjsksnvLQjlLPRYfrihsuuxg66kyJKcTvuKnlQSDrvRdbXNjHPHIQ67iOEMOqoSWOvk)ff6KOGfjkW1ifCpeKwjPOQFRQpjkuBDVBGiAqoXMjnuIfAaKRUcSAe5XKqeyByUyyEg6Xjgj0LoJ6emQHrDX6garyvgtjZfN8PUOpMrgYwp5ttE3fDVBGiAqoXMj2au5srNH2FI5srIpzvPKQqGLzmtG9KluGndfy11GHSKYP80AGpqzmQN8PmoLPZad0MSg3ZnqFkAq9Bmf8sSqdgkXcn0pqfyZwp5tfy1CY0zilxrYanwiHMbGC1vGvJipMeIaBssvmrb2l4kWldm0JtmsOlDg1jqF0qpM(bEftE3NHUByvP6Nhxi9mPb1VvIfAaKRUcSAe5XKqeytsQIjkWEbxbE(CPJ3nqeniNyZeBaQCPOZqMfypzvPKQqGLzmtGLCixoXI4pHNIhezilPCkpTg4Hs0ad0MSg3ZnqFkAq9Bmf8sSqdgkXcn0hkrd94eJe6sNrDc0hn0JPFGxXK39zO7gwvQ(5XfsptAq9BLyHg85sg5DderdYj2mXgGkxk6mKzbwYHC5exJJXCpFjEqKHSKYP80AOfPndmqBYACp3a9POb1VXuWlXcnyOel0GMosBg6Xjgj0LoJ6eOpAOht)aVIjV7Zq3nSQu9ZJlKEM0G63kXcn4ZfMV3nqeniNyZeBaQCPOZqMfyjhYLtCkYhkqg5FWfpiYqws5uEAnKI8HcKr(hCdmqBYACp3a9POb1VXuWlXcnyOel0ae5dfOaB)hCd94eJe6sNrDc0hn0JPFGxXK39zO7gwvQ(5XfsptAq9BLyHg85Ig8UbIOb5eBMydqLlfDgUxHIjkU()S9eMMmKLuoLNwdKipHCLgyG2K14EUb6trdQFJPGxIfAWqjwObIrEc5kn0JtmsOlDg1jqF0qpM(bEftE3NHUByvP6Nhxi9mPb1VvIfAWNlAwVBGiAqoXMj2qws5uEAniP1GtJt(udmqBYACp3a9POb1VXuWlXcnyOel0ad0AWPXjFkHiWY8KufcSFob2Bdfy18duft0qpoXiHU0zuNa9rd9y6h4vm5DFg6UHvLQFECH0ZKgu)wjwObFUqG3nqeniNyZeBilPCkpTgoPcKNym3axRbgOnznUNBG(u0G63yk4LyHgmuIfAyxQa5zCsGvJdCTg6Xjgj0LoJ6eOpAOht)aVIjV7Zq3nSQu9ZJlKEM0G63kXcn4ZfnL3nqeniNyZeBilPCkpTgI0wSckMymhhPmNwdmqBYACp3a9POb1VXuWlXcnyOel0q20wSckMXjbwnYrkZP1qpoXiHU0zuNa9rd9y6h4vm5DFg6UHvLQFECH0ZKgu)wjwObFUOj9UbIOb5eBMydqLlfDg0mcSxmr6jofKi)()2eJ0GCInbwMXmbwYHC5elIJT4EUwgtewM7OykjEqKaRMqGntcSxmr6jMC(F7I5ttIrAqoXMaBMeyjhYLtm58)2fZNMe3EctfyZKaB9xKpJIEj9sIRdCospbwcvGvdgYskNYtRboQG)e(2mWaTjRX9Cd0NIgu)gtbVel0GHsSqd9Oc(t4BZqpoXiHU0zuNa9rd9y6h4vm5DFg6UHvLQFECH0ZKgu)wjwObFUOp6DderdYj2mXgGkxk6mu)f5ZOOxsVK46aNJ0tGLqfy1GHSKYP80AGlfzGbAtwJ75gOpfnO(nMcEjwObdLyHg6LIm0JtmsOlDg1jqF0qpM(bEftE3NHUByvP6Nhxi9mPb1VvIfAWNl66E3ar0GCIntSbOYLIodzwG9KvLsQcb2mjWMp4YGCIIhsiJ3gpsBcSzOa7OHSKYP80A424rAJXACgyG2K14EUb6trdQFJPGxIfAWqjwOH9nEK2m0JtmsOlDg1jqF0qpM(bEftE3NHUByvP6Nhxi9mPb1VvIfAWNl6D8UbIOb5eBMydzjLt5P1qAJJndmqBYACp3a9POb1VXuWlXcnyOel0aSXXMHECIrcDPZOob6Jg6X0pWRyY7(m0DdRkv)84cPNjnO(TsSqd(8zaQCPOZGpB]] )

    storeDefault( [[SimC Feral: precombat]], 'actionLists', 20171006.174729, [[dyJKeaGEuvv7cvLTHQknBkDtkCBjTtr2lz3OSFe0OquYWOOFRyOcPAWqQgUu1bfItHQkogQCCPOAHiILcjlgQwospuO8uvltO65I60cMQuzYqmDLUiKYJHYLbxxcBuiLTkf2mIITJQCyQMLuuMgIs9DevNhbEMqsJwIwhQQYjriFtk5AcjUNuK)Iq9zPuVgrAXPoD0yoUfqeUEYRG(d1yeIE0aQB5pcrVNcytf3xDuGf8mOuCtUwMrXKJpo93dyb3g4FFddtjoZOQhbBddlRoL4uNoAmh3ciIe9Jrd9R(6wGT8HBNbzD7WY8bmh3ci6rWd2WsGofAthY3sDIyibmFhQoByGUXG0WPjVc66jVc6OG20H8Tuhfybpdkf3KRfNPokipfumiRoT6XkbmsngEqfyRW1ngKKxbDTkfxD6OXCClGis0pgn0V6M6rWd2WsGopNgCClOtedjG57q1zdd0ngKgon5vqVideVLupxQN8kO)DOaHO3WTfGEeA7SoZRqtfzG4TK65YMXZTfqtM6Oal4zqP4MCT4m1rb5PGIbz1PvpwjGrQXWdQaBfUUXGK8kORvPOQoD0yoUfqej6hJg6xDO5fH(EaHpBbziJtm5uVVpWAN1JGhSHLaDEon44wqNigsaZ3HQZggOBminCAYRGErgiElPEUup5vq)7qbcrVHBlacrNS44h9i02zDMxHMkYaXBj1ZLnJNBlGM40rbwWZGsXn5AXzQJcYtbfdYQtRESsaJuJHhub2kCDJbj5vqxRsKT60rJ54warKOhbpydlb6y(smzgAvNigsaZ3HQZggOBminCAYRGUEYRGEmFje9On0QokWcEgukUjxlotDuqEkOyqwDA1JvcyKAm8GkWwHRBmijVc6AvkkQthnMJBberIEe8GnSeO3thYT6eXqcy(ouD2WaDJbPHttEf01tEf0JoDi3QJcSGNbLIBY1IZuhfKNckgKvNw9yLagPgdpOcSv46gdsYRGUwL4x1PJgZXTaIir)y0q)QVt72wGV(zddlRhbpydlb69ZggMormKaMVdvNnmq3yqA40KxbD9Kxb9OpByy6Oal4zqP4MCT4m1rb5PGIbz1PvpwjGrQXWdQaBfUUXGK8kORvR(XOH(vxRea]] )

    storeDefault( [[SimC Feral: generator]], 'actionLists', 20171006.174729, [[deeIpaqiQi2ev4tevOrPcoLIQvbkYRuHGBrub7cvnmI4yQOLPs5zurAAQqQRbkSnIk5BuPACQqY5iQO1PcHMhvs3JkX(OI6GeLwirXdjQ6IuPSrqr1hbfLoPkr3KiTtkAPkkpvyQuOTQsyVi)vrgSOdl1IvvpMstwvUm0MPGpRqgnO60K8AqPztv3gKDd8BugUcoorLA5eEoPMUsxhv2UkvFxfQXdkkoVkP1RcrZxHA)sMojJu4gO)E8rFkmBiKIqbjFLWCu0(JyLJqak6LjOyg6XwJK5njNUlbgso5pPigqRQ9QJSxfdqMNsCkfYAxfdOjJK5jzKc3a93JpsgkcRqnSu02vDhNqacPqDLox5zLoQ0YG(SPbMcSAElNqGGTsxRegui7x5v7vk(cUT9tAFRHtXLGNY2ltqbGbqkKYEx0cZgcPGcZgcPqgb32(kdFRHtXm0JTgjZBsoD)ucfZqnJtyrnzKwkKhoAHvk7ocHGL(uiL9mBiKcAjZBKrkCd0Fp(izOiSc1WsHLb9ztdmfy18woHabBLU6sL3Q0rLFodg4rpha1tJ4uVgyr(h7yqLoQ8qLFodg4)Eg7TTNb08CdvoECLoPYT9iy5)Eg7TTNb08iO)E8v58kDu5Hk)CgmWR779iCsWAbp3qLJhxPtQCBpcwEDFVhHtcwl4rq)94RY5ui7x5v7vkAn8gQbOEYGabh5vkUe8u2EzckamasHu27Iwy2qifuy2qifYQH3qnaLJ6kH5ceCKxPyg6XwJK5njNUFkHIzOMXjSOMmslfYdhTWkLDhHqWsFkKYEMnesbTKPtjJu4gO)E8rYqryfQHLIT9iy5rpha1tJ4uVgyrEe0Fp(Q0rLwg0NnnWuGvZB5eceSv6sLsQ0rLiafJUYB5eceSv6Slv22vXa8gqbZQyC6PVArEltVvEeQ8gmOq2VYR2RuGEoaQNgXPEnWIuCj4PS9YeuayaKcPS3fTWSHqkOWSHqkCZZbq5OUsywo1RbwKIzOhBnsM3KC6(PekMHAgNWIAYiTuipC0cRu2Decbl9Pqk7z2qif0sMhnzKc3a93JpsgkcRqnSuSThbl)xWTTFs7BnCEe0Fp(Q0rLTDv3XjeGqkuxPZUuPCsHSFLxTxPyHlAn8jBVuCj4PS9YeuayaKcPS3fTWSHqkOWSHqkmcx0A4umd9yRrY8MKt3pLqXmuZ4ewutgPLc5HJwyLYUJqiyPpfszpZgcPGwYegKrkCd0Fp(izOiSc1WsrBx1DCcbiKc1v6Slvkxui7x5v7vk0hRgWjBVuCj4PS9YeuayaKcPS3fTWSHqkOWSHqkIJvdifZqp2AKmVj509tjumd1moHf1KrAPqE4OfwPS7iecw6tHu2ZSHqkOLmLlYifUb6VhFKmuewHAyPWYG(SPbMcSAElNqGGTsxRegv6OseGIrx5TCcbc2kD2LkB7QyaErdlYBz6Tshv(ylVOHf5hG48RAWRqrLUw5n(ZkDu5NZGb(vncf6jdCIR8Cdv6OYdv(5myG)7zS32EgqZZnu54Xv6Kk32JGL)7zS32EgqZJG(7XxLZR0rLhQ0jvUThblVcyBbOxfdWJG(7XxLJhxPLX8p2XaEfW2cqVkgGxGqTcOR05kppQkNxPJkDsLFodg4vaBla9QyaEUbkK9R8Q9kfA49JDme6FuCj4PS9YeuayaKcPS3fTWSHqkOWSHqkc49JDme6Fumd9yRrY8MKt3pLqXmuZ4ewutgPLc5HJwyLYUJqiyPpfszpZgcPGwY0DYifUb6VhFKmuewHAyPWYG(SPbMcSAElNqGGTsxRegv6OYdv6KkxLfwfyuLJhx5HkDsLB7rWY)9m2BBpdO5rq)94RshvkqOwb0v6ALporVkgOsyQsj8oTY5voECLhQCBpcw(VNXEB7zanpc6VhFv6OYpNbd8FpJ922ZaAEUHkDu5HkfiuRa6kD1LkV3cv)9iVOHfNeObbQHx58kDu5ak0k9IGDcIZVQbVcfv6CLp2YlAyr(bio)Qg8kuujmvPe(JssLZRCELoQCBXiC5xfeoTSPNcRuouPaHAfqxPZvUklStRccPq2VYR2RuiAyrkKhoAHvk7ocHGL(uiL9UOfMnesbfxcEkBVmbfagaPWSHqkM1WIuiRyKMc7vRhN2wmcxTlNumd9yRrY8MKt3pLqXmuZ4ewutgPLc5VA9OXwmcxnjdfszpZgcPGwY8OiJu4gO)E8rYqryfQHLcnUtFgGtZVkuCkNth9GTsNRusLoQuGqTcOR0vxQ8Xj6vXavctvkH3Pv6Osld6ZMgykWQ5TCcbc2kDTsyuPJkpuzBx1DCcbiKc1v6SlvERYXJR8qLhQeLBo1Wa(49Cgm0thl6HbfyKUYXJR8ZzWaV1JTW26vbgXZnu58kDu5Hkr5MtnmGp(w55eSPbghWIcDLJhx5NZGb(VNXEB7zan)JDmOY5voVY5ui7x5v7vkw4IwdFY2lfYdhTWkLDhHqWsFkKYEx0cZgcPGIlbpLTxMGcadGuy2qifgHlAn8kpCoNczfJ0uyVA9402Ir4QD5KIzOhBnsM3KC6(PekMHAgNWIAYiTui)vRhn2Ir4QjzOqk7z2qif0sMYjzKc3a93JpsgkcRqnSu4Kk14o9zaon)QqXPCoD0d2kDUsjv6Osbc1kGUsxDPYhNOxfdujmvPeENwPJkpuzBx1DCcbiKc1v6SlvERYXJR8qLFodg4TESf2wVkWiEUHkDujk3CQHb8X75myONow0ddkWiDLoQ8qLOCZPggWhFR8Cc20aJdyrHUYXJR8ZzWa)3ZyVT9mGM)Xogu58kNx5CkK9R8Q9kflCrRHpz7Lc5HJwyLYUJqiyPpfszVlAHzdHuqXLGNY2ltqbGbqkmBiKcJWfTgELhUnNczfJ0uyVA9402Ir4QD5KIzOhBnsM3KC6(PekMHAgNWIAYiTui)vRhn2Ir4QjzOqk7z2qif0sMNsiJu4gO)E8rYqryfQHLcld6ZMgykWQ5TCcbc2kDTsyuPJkpu5Hkpu5zLhHkHAyMjl8wmc1vkhQ0cVfJq9KbrBxfd0(kNxjmv5jmQCELJhx5HkpuPfElgH6jdI2UkgO9v6CL34Ll5QshvUkiSsNR8usLZRCELZPq2VYR2Ru8fCB7N0(wdNIlbpLTxMGcadGuiL9UOfMnesbfMnesHmcUT9vg(wdVYdNZPyg6XwJK5njNUFkHIzOMXjSOMmslfYdhTWkLDhHqWsFkKYEMnesbTK55jzKc3a93JpsgkcRqnSuyzqF20atbwnVLtiqWwPRvcJkDuzBx1DCcbiKc1v6Slv6ukK9R8Q9kf6Jvd4KTxkUe8u2EzckamasHu27Iwy2qifuy2qifXXQbSYdNZPyg6XwJK5njNUFkHIzOMXjSOMmslfYdhTWkLDhHqWsFkKYEMnesbTK55nYifUb6VhFKmuewHAyPWYG(SPbMcSAElNqGGTsxRegv6OYdv22vDhNqacPqDLUwPtRC84k32JGL)l422pP9Tgopc6VhFvoNcz)kVAVsHgUaFuCj4PS9YeuayaKcPS3fTWSHqkOWSHqkc4c8rXm0JTgjZBsoD)ucfZqnJtyrnzKwkKhoAHvk7ocHGL(uiL9mBiKcAPLIWkudlf0sea]] )

    storeDefault( [[SimC Feral: sbt opener]], 'actionLists', 20171006.174729, [[dittcaGEkfTjPODrIxtv1SLQBcu3gj7uvTxXUHSFsnmP0VvmykgoLCqa1XiPfsv0srklwflh0drQ8uultk8CLAQQIjRstxYfbWPH6Yexxj2iLQ2kLsBgq2ovPEmvomIpdKVtvY9Ou5qQsnALK1HuLtsv4VQsUMsQZtv5Ba0ZqQQprPWrnpHbaroD5Mt4pHscZyk60g7fiPtpTzFkTzSeKadtt6czl53OvfW21TQkQHzlXHjDSnjfEq5R2s)Wa7k8G25jF18egae50LB8mm7GyRkCr6cQuo9zUfPpOTIGiNUC1MMAJBOoZlRbJQTIBbcfuPn2PnR1MMAZBT5SaeqkN(m3I0h0wzXsBAQnV1M7ukqSLsHD(XiqHb(G74YxyOacoEvRc7b6IDKAGHrdscdEU2sGFcLeo8NqjHPjGGJx1QW0KUq2s(nAvbuTnmnzplqNSZtQW0TsC(bpElucQYjm45(jus4u53ipHbaroD5gpdZoi2Qc)wBUtPaXwkf25hJaPnn1g3qDMxwdgvBf3cekOsBStBwhg4dUJlFHlmibUFb0c0xypqxSJudmmAqsyWZ1wc8tOKWH)ekj8dgKaTXwBSFb6lmnPlKTKFJwvavBdtt2Zc0j78KkmDReNFWJ3cLGQCcdEUFcLeovQWSdITQWPsa]] )

    storeDefault( [[SimC Feral: finisher]], 'actionLists', 20171006.174729, [[d4ZGoaGAikP1RGkTjfyxISnfu2NOOhlXSvQ5dPBkQ6WsDBv5Aer7uj2RWUHA)KgLsYWev(nQUhbSkik1GPmCQ4qskCkLuhJGUmYcLuzPqOfRQwoOhkPQNcSmfK1PGQmorHMQczYe10v5Iqu9zj5zebxxrBubvSvrbBMkTDrP5rGMLcQQPbrX3vO6Ve6BkugnemEjfDsIq3cIsCAuopr65u1bLu61qKdHXOaGCC)3KC8dWs)OaayV6vB4qWEp8uZLHzEeiyaqK2u7PyzOCchlNK5eMegaGdvy9MnC7JXXXIWCsia1wogh7JrXIWyuaqoU)BsoQlaGcK5CbOgQ9NUUjFNTRiriVHPPJAduBLAf(7ZfD4m85tLjes4tnbuts1qrvBLAxVj8L(W51Br)U9iKiC)3KSAduRlhlljsy6XiVAzQMq1gOwxoghN(W51Br)U9iKki0WkYRwMQLtT1QToa1(zB2jna(oBxrIqEddGeXYSsFCyaWCmfG8C5m0WL(rbial9JcaOZ2vKAiYByaqK2u7PyzOCchtyUaGi55tyH8XO4cq9iqfKYZZspcFXpa55Yl9JcqCXYqXOaGCC)3KCuxaafiZ5caKEnd7vtqbutEc7JXXQHSvlxscQnqTUCSSKiHPhJ8QLPaQjzaQ9Z2StAaoeGThbXsFbOEeOcs55zPhHV4hG8C5m0WL(rbiaselZk9XHbaZXuaw6hfGriaBpcbOwyLpafPLnjEnSIoVacdaI0MApfldLt4ycZfaejpFclKpgfxaQxAztJAyfD(OUaKNlV0pkaXflsigfaKJ7)MKJ6caOazoxa6YXYsIeMEmYRwMcOwgdqTF2MDsdGFCMdjw6laselZk9XHbaZXuaYZLZqdx6hfGaS0pkaGXzouaqK2u7PyzOCchtyUaGi55tyH8XO4cq9iqfKYZZspcFXpa55Yl9JcqCXcYeJcaYX9FtYrDbauGmNlaRuRgQDScsmCLAOOQTsni9Ag2RMGQLr1gO21Wk6siq9(qi5uo1YuTHKuTbQvd1UEt4l57pbpo)qir4(Vjz1wRgkQAoe0Z8hHpX3CFmNnJGQLPAY8lbzojN3CFmNnJGQTwTbQDnSIU0XEK4XfLzKAilQbPxZWE1YuTJvqs8ypsnKTAiJAduRWFFUOdNHpFQmHqcFQjGAsQ2a1wPgHjyL00XEK4XfFDnvtq1Y2qw)3uYHZ3mCLAOOQ9NUUPpb9eeP00rnuu1(tx3edxAiUpghNMoQHIQ2F66MO9etEXQjtUXfknDudfvTcNVL5JJthRIGEr3juAcsVMH9QjOAsqnuu180j(54PpDmckmJIiJtrTmvlNAOOQTsT)01nv2udlT)y4Q00rTbQrycwjnvMqiHp1YuTHjPARvdfvTR3e(sE(ClYDfpeirxoK8xIW9FtYQHIQwnutMFjiZjDScsmCLAOOQTsnz(LGnsucsVMH9QjOActsQ2a16YXYsIeMEmYRMGQnm1wR26au7NTzN0aazobOEeOcs55zPhHV4hG8C5m0WL(rbiaselZk9XHbaZXuaw6hfaezobOwyLpafPLnjEnSIoVacdaI0MApfldLt4ycZfaejpFclKpgfxaQxAztJAyfD(OUaKNlV0pkaXflsgJcaYX9FtYrDbauGmNlaRuBLA)PRBY3z7kseYBycsVMH9QjOaQjmxss1gO21BcFjK1UQIKfhNpXY(eH7)MKvBTAOOQTsT)01n57SDfjc5nmbPxZWE1eua1glnKARvBTAduRWFFUOdNHpFQmHqcFQjGAsQ2a1wPgHjyL00XEK4XfFDnvtq1Y2qw)3uYHZ3mCLAOOQ9NUUPpb9eeP00rnuu1(tx3edxAiUpghNMoQHIQ2F66MO9etEXQjtUXfknDudfvTcNVL5JJthRIGEr3juAcsVMH9QjOAsqnuu180j(54PpDmckmJIiJtrTmvlNAOOQTsT)01nv2udlT)y4Q00rTbQrycwjnvMqiHp1YuTHjPARvdfvTR3e(sE(ClYDfpeirxoK8xIW9FtYQHIQwnutMFjiZjDScsmCLAOOQTsnz(LGnsucsVMH9QjOActsQ2a16YXYsIeMEmYRMGQnm1wR26au7NTzN0a47SDfjc5nmaselZk9XHbaZXuaYZLZqdx6hfGaS0pkaGoBxrQHiVHQTs46aGiTP2tXYq5eoMWCbarYZNWc5JrXfG6rGkiLNNLEe(IFaYZLx6hfG4ILHfJcaYX9FtYrDbauGmNlaf(7ZfD4m85tLjes4tnbuts1gO2k16YXYsIeMEmYRwMcO2WudfvTvQ1LJLLejm9yKxTmfqnjO2a1QHAxVj8L(Box(6nh7teU)BswT1QTwTbQv4Vpx0HZWNpvMqiHp1eqnjvBGARuJWeSsA6yps84IVUMQjOAzBiR)Bk5W5BgUsnuu1(tx30NGEcIuA6OgkQA)PRBIHlne3hJJtth1qrv7pDDt0EIjVy1Kj34cLMoQHIQwHZ3Y8XXPJvrqVO7eknbPxZWE1eunjOgkQAE6e)C80NogbfMrrKXPOwMQLtnuu1wP21BcFPh)r4tK7kw2nKDsteU)BswTbQ9NUUPYMAyP9hdxLMoQTwT1bO2pBZoPbWpoZHel9fajILzL(4WaG5yka55YzOHl9Jcqaw6hfaW4mhsTvcxhaePn1EkwgkNWXeMlaisE(ewiFmkUaupcubP88S0JWx8dqEU8s)OaexSmwmkaih3)njh1faqbYCUau4Vpx0HZWNpvMqiHp1eqnjvBGA)PRBYLrqPIqsw81Shb9PPJAduBLAeMGvsth7rIhx811unbvlBdz9FtjhoFZWvQHIQ2F66M(e0tqKsth1qrv7pDDtmCPH4(yCCA6OgkQA)PRBI2tm5fRMm5gxO00rnuu1kC(wMpooDSkc6fDNqPji9Ag2RMGQjb1whGA)Sn7KgGxZEbqIyzwPpomayoMcqEUCgA4s)OaeGL(rbiFZEbarAtTNILHYjCmH5caIKNpHfYhJIla1Javqkppl9i8f)aKNlV0pkaXflzmgfaKJ7)MKJ6caOazoxak83Nl6Wz4ZNktiKWNAcOMKQnqTvQrycwjnDShjECXxxt1euTSnK1)nLC48ndxPgkQA)PRB6tqpbrknDudfvT)01nXWLgI7JXXPPJAOOQ9NUUjApXKxSAYKBCHsth1qrvRW5Bz(440XQiOx0DcLMG0RzyVAcQMeuBDaQ9Z2StAaCjiVW4tV4NDuaQhbQGuEEw6r4l(bipxodnCPFuacGeXYSsFCyaWCmfGL(rby4qqEHXNE1QJDuaQfw5dWRRPiHjyLubeo8lslBs8AyfDEbegaePn1EkwgkNWXeMlaisE(ewiFmkUauV0YMg1Wk68rDbipxEPFuaIlUaakqMZfG4Ia]] )

    storeDefault( [[SimC Feral: cooldowns]], 'actionLists', 20171006.174729, [[dieFjaqisqlsGInHc(eksnkQKofvk7IiddGJPswgk0ZeeMMarDnsGTjq13irghkIoNaHwNaLMNGO7jiTpQehef1cjP6HKuMOajUij0grr4JcKYjjrTsbs6Lce5MaANemubs1sPIEkLPssUQabBLkv7v5VuHbd5WQAXO0JfAYICzKnRs9zIQrlOonPETkQzlQBd0UL63sgUkSCu9CQA6GUoH2Ua8Db05jkRhfjZxfz)q9UMQzk2pBMsJDMWdsZmnOAyetq8phSyuSQCQcS9ZCsz690eyeWLsxaaeCPRz2bf1FwZupux9eUaeIzmhH6Q9t1eUMQzk2pBMst9zwKRpGZuigXkEFlfFOJ7IdkjEmJzwDwdLnl9(WZuUt64dl(SUAAgWk5(ZfEqA2mHhKMfuEF4zoPm9EAcmc4sPlaZCs(sKhj)un4m1ctXZaRaiqQHJDgWkj8G0SbNaJt1mf7NntPP(mlY1hWzWsU8mjfRkNQaBpgXag5kgrnXLltkkY5udXixcfJcbamIbmYvmkwvovb2sqTCI7DClYLjXjWx3EmYfmsby0PtyeR49TeulN4Eh3ICzsIhyKByKBZyMvN1qzZyjUN4NNPCN0Xhw8zD10mGvY9Nl8G0SzcpintDI7j(5zoPm9EAcmc4sPlaZCs(sKhj)un4m1ctXZaRaiqQHJDgWkj8G0SbNqiMQzk2pBMst9zwKRpGZOM4YLjLOBDudXixcfJcoGzmZQZAOSzqTCI7DClYLnt5oPJpS4Z6QPzaRK7px4bPzZeEqAMkTCIZ0EmIje5YM5KY07PjWiGlLUamZj5lrEK8t1GZulmfpdScGaPgo2zaRKWdsZgCcb5PAMI9ZMP0uFMf56d4SybYwookDd9srroNAigfkgbaJyaJOM4YLjff5CQHyKlHIrkaWmMz1znu2mkl2K3HCrD67int5oPJpS4Z6QPzaRK7px4bPzZeEqAMIzXMyApgf0e1PVJ0mNuMEpnbgbCP0fGzojFjYJKFQgCMAHP4zGvaei1WXodyLeEqA2Gtqbt1mf7NntPP(mlY1hWzutC5YKIICo1qmYLqXOqaaJyaJCfJIvLtvGTeulN4Eh3ICzsCc81ThJCbJUuagD6egXkEFlb1YjU3XTixMK4bg52mMz1znu2mDhFE)qD1ZuUt64dl(SUAAgWk5(ZfEqA2mHhKMPChFE)qD1blgfK0TCmQUXiyycJcQIT8mnZjLP3ttGraxkDbyMtYxI8i5NQbNPwykEgyfabsnCSZawjHhKMn4ec(untX(zZuAQpZIC9bCgSKlptshfuxThJyaJCfJGpxobLGAqYbSCK0egfsmk4kaJoDcJCfJGAqYbSCK0egfsm6IjbGrmGrUIrSI33sSe3t8ZsIhy0PtyeR49TKUJpVFOUAjXdmYnmYnmYTzmZQZAOSzhfux9mL7Ko(WIpRRMMbSsU)CHhKMnt4bPzb9cQREgZC5(z9dsHgmh8kxTCk54OcK4bZmNuMEpnbgbCP0fGzojFjYJKFQgCMAHP4zGvaei1WXodyLeEqA2bVYvlNsooQaj(GtqPPAMI9ZMP0uFMf56d4SybYwookDd9srroNAig5sOyeJyedyKRyKcXi4NPgkXMRkb)C1EjQF2mLWOtNWiwX7Bj2Cvj4NR2ljEGrUnJzwDwdLn79HFWVjVJBo1mLSzk3jD8HfFwxnndyLC)5cpinBMWdsZy2h(b)MyApgXeCQzkzZCsz690eyeWLsxaM5K8Lips(PAWzQfMINbwbqGudh7mGvs4bPzdobMCQMPy)Szkn1NzrU(aolwGSLJJs3qVuuKZPgIrHeJuagXagrnXLltkkY5udXixcfJ(iuxTe)ptsXYdXigWOubL4)zs6aumd1hznXXOqIrmkDHrmGrSI33sqTCI7DClYLjjEGrmGrUIrSI33sS5QsWpxTxs8aJoDcJuigb)m1qj2Cvj4NR2lr9ZMPeg5ggXag5kgPqmc(zQHs6o(8(H6QLO(zZucJoDcJIvLtvGTKUJpVFOUAjob(62JrUGrxmjg5ggXagPqmIv8(ws3XN3puxTK4XmMz1znu2mF4pvbcs50mL7Ko(WIpRRMMbSsU)CHhKMnt4bPzw4pvbcs50mNuMEpnbgbCP0fGzojFjYJKFQgCMAHP4zGvaei1WXodyLeEqA2GtiiovZuSF2mLM6ZyMvN1qzZe9KdnKa9ZuUt64dl(SUAAgWk5(ZfEqA2mHhKMfe8egPmKa9ZCsz690eyeWLsxaM5K8Lips(PAWzQfMINbwbqGudh7mGvs4bPzdo4mlY1hWzdUb]] )

    storeDefault( [[SimC Feral: single target]], 'actionLists', 20171006.174729, [[dSJ9faGEfk1MiPyxkY2qKY(qKQzssPztL5ts1nvj3wWobAVs7g0(Pyuiqnme63k9nuIhl0Gj1WjHdssofcWXuuhw0cPuAPQulgflhPhIOEk0YqepNQopLIPQIMmGPRQlIs1Pr1LjUUc2icARuI2mjA7ucpdb03rjnneiZtHQ(Rc5qkuz0uQwhkLtsj5ZQqxtHI7Hi51QGfrj14uOK7CplYomzCcqzkcMbPiYdKnAcfA6yZO9C4rNy0FspkFXBXjPxkijeNzzMirsBAUiQqI80Xh785lSGZejWIQIpFH(EwW5EwKDyY4eGABrms5k(IJZOzguQCkM)iLlnmnOOOkgUJ)2umM)iLlnu0kiapM)slcxOu8AbSmPGzqkwemdsrY5B0eU0qXBXjPxkijeNzzMyXBXVd0O47z)IKTlXdxRfsqGFzkETaGzqk2VGK0ZISdtgNauBlIrkxXxKzqPYjf0Lv30GcJwD1nAMbLkN82tGL1G4aMguuufd3XFBksZdsrRGa8y(lTiCHsXRfWYKcMbPyrWmifVZdsXBXjPxkijeNzzMyXBXVd0O47z)IKTlXdxRfsqGFzkETaGzqk2VGeyplYomzCcqTTOkgUJ)2umMo3Om(8foYX9FrRGa8y(lTiCHsXRfWYKcMbPyrWmifjNoNrRk(8fA0QL7)IQOh9fHzqiL1ipq2OjuOPJnJoURdyzf6TU4T4K0lfKeIZSmtS4T43bAu89SFrY2L4HR1cjiWVmfVwaWmifrEGSrtOqthBgDCxhWYk03VGeuplYomzCcqTTigPCfFX4gy2rkwo89tXbkvGVrtkJEmgTAm6pDc8NyC7c8PBH(jbMmobWOvJrZmOu5eJBxGpDl0pbSScnA1y0eSrpoJMzqPYjomMuy(8fonOWOvxDJgy)jkxXevcjh6n6XB0JLrRU6gnW(t08GmrLqYHEJE8g9ymAcOOkgUJ)2uKkhPlRV9Iwbb4X8xAr4cLIxlGLjfmdsXIGzqkElhPlRV9I3ItsVuqsioZYmXI3IFhOrX3Z(fjBxIhUwlKGa)Yu8AbaZGuSFbhtplYomzCcqTTigPCfFX4gy2rkwo89tXbkvGVrt6gnbvufd3XFBkshGJY4Zx4ih3)fTccWJ5V0IWfkfVwaltkygKIfbZGu8EaA0QIpFHgTA5(VOk6rFrygesznYdKnAcfA6yZOXtJwjhY92fQ36I3ItsVuqsioZYmXI3IFhOrX3Z(fjBxIhUwlKGa)Yu8AbaZGue5bYgnHcnDSz04PrRKd5E7c13VGKwplYomzCcqTTOkgUJ)2uKoahLXNVWroU)lAfeGhZFPfHlukETawMuWmiflcMbP49a0OvfF(cnA1Y9VrtWZeqrv0J(IWmiKYAKhiB0ek00XMrJNg9rbk08xQ36I3ItsVuqsioZYmXI3IFhOrX3Z(fjBxIhUwlKGa)Yu8AbaZGue5bYgnHcnDSz04PrFuGcn)L673VigPCfFX(Ta]] )

    storeDefault( [[SimC Feral: ST finishers]], 'actionLists', 20171006.174729, [[dSJIfaGEPk0Mav2fj2MqvSpujZwvnFq4MGYTf5Xi1orYEv2nP2pLgfc1WKkJtQshMQVrsAWcgofDqq0PqehtkDEeYcjPAPiQfJQwoWdrL6PeltiToHQ0PvzQOIjRktxYfjP8mPQCzORlfBuQI2QqLnlu2of6ZG03LQGPjuvnpHOxJi9xemAky8cvLtkeoKuvDnqvDpsIvbQYZf1Vr51ootut78F8n(juEcNixIBBONiW)XRniCSHyN(YgqqEcz8JEghv0UwvB76IhL2jIjsF()6rVoMEuTD9nbs66y684mQ2XzIAAN)JVP(eHgCM1e(MyXuYUrhksaWCGYJ1d6jqYF)RiAs2n6qrcaMdMeH(D0EXat0mnobg7fNdO8eozcLNWjIB0HI2azMdMqg)ONXrfTRv12UjKXmRbqJ5Xz1eUnG0KcJzetOUg)eyShLNWjRgv0XzIAAN)JVP(eHgCM1K(TH6Oj90qTbiGWgi2gayYpD2gIufB41a86yABaE2qNsF2aj2aC2aX2q5aOyPya9FzqXKUSbUSHOW3gGZg63gk)J6sj78iOySYGcQD(p(SbsSbiGWgi2gayYpD2gIufB41a86yABaE2qNsV2aC2GjcYxUqDri18RZ8FiWg4YgESsbCMkMPMFDM)db2aj2aC2q5aOyPuxcjumcVdTbUSHENaj)9VIOjGZCse63r7fdmrZ04eySxCoGYt4KjuEcNq(mNajaAEs5aOyr4IPs)1rt6PHcbeedWKF6CKQ8AaEDmn86u6Je4iUCauSumG(VmOysxCff(W1F5FuxkzNhbfJvguqTZ)XhjqabXam5NohPkVgGxhtdVoLEHZeb5lxOUiKA(1z(peW1JvkGZuXm18RZ8FiGe4khaflL6siHIr4Dix9oHm(rpJJkAxRQTDtiJzwdGgZJZQjCBaPjfgZiMqDn(jWypkpHtwnQ(gNjQPD(p(M6teAWzwt4BIftj7gDOibaZbkam5NoBdrAdTrNaj)9VIOjz3Odfjayoyse63r7fdmrZ04eySxCoGYt4KjuEcNiUrhkAdKzoWgiULKjKXp6zCur7AvTTBczmZAa0yECwnHBdinPWygXeQRXpbg7r5jCYQrf)JZe10o)hFt9jcn4mRj8nXIPe7qarea4JqYVecYknMtGK)(xr0KKFPjrOFhTxmWentJtGXEX5akpHtMq5jCcm)stiJF0Z4OI21QAB3eYyM1aOX84SAc3gqAsHXmIjuxJFcm2JYt4KvJc(JZe10o)hFt9jqYF)RiAsmeWOpwtMa)v4Ki0VJ2lgyIMPXjWyV4CaLNWjtO8eoPNiGrFSMSnO(v4eibqZtsE8ra1iakrQ0oHm(rpJJkAxRQTDtiJzwdGgZJZQjCBaPjfgZiMqDn(jWypkpHtwTAIqdoZAYQn]] )

    storeDefault( [[SimC Feral: ST generators]], 'actionLists', 20171006.174729, [[d8dHnaWyfTEIkPnrQSlcTnIkL9rvXHfTofIQzly(KQ6MqvNxH62QYPjzNezVGDJQ9R0OuGHPQACke8ukxgzWQmCvLdrQItjuDmPQZrujAHufwkPyXqz5O8qQkTkIkwMc65u51uLMkP0KLY0LCrQIEfrLQNrGCDHSrfIyRcL2mrz7eW3iihxHinnsv67euZtH0NPQA0sLXRquoPqXTiQeUMcHUhbQ)cvoirv)gYqpOfmp5jwGAagys5JaZupF3BKqSmmY3Z0UNFItSSqmhyAOaLocKg(3lu))VCtShm7JMQmOKRzPqCqQ)xqGj)SuiUd0cs9GwW8KNybQbEaMnzQVcSkdeVeXciuRYaI7ejEIfO2E62dlsMmXpg1YcXgJZjSswXjNtm6BpD7HfjtMiwaHAvgqCNydjmFpD7nrpmeUpKIxoXzeJr8ApFe8Ed3t3Etek0qcZftxx(so5WjJrC56yrg9sf3T3O75F2atEmvqvJbJr(ziHRoWIH3uZSqmW4iobgEul2KjLpcmWKYhbMgYpdjC1bMgkqPJaPH)9c1)dMgYHIytYbAHcmF7OPx8ibOhXladm8OMu(iWGcKgcAbZtEIfOg4by2KP(kWQmq8selGqTkdiUtK4jwGA7PBpSizYe)yulleBmoNWkzfNCoXOV90ThwKmzIybeQvzaXDInKW890T3e9Wq4(qkE5eNrmgXR9e8E6DpD71qLil9sIm6LkUBVr3tVGjpMkOQXGXi)mKWvhyXWBQzwigyCeNadpQfBYKYhbgys5Jatd5NHeU62BqFCW0qbkDein8VxO(FW0qoueBsoqluG5Bhn9Ihja9iEbyGHh1KYhbguGKGaTG5jpXcud8amBYuFfy0ins99rnXufIyiCFOi(KyU90TxLbIxIybeQvzaXDIepXcuBpD7nypSizYe)yulleBmoNWkzfNCorxLtV75ZEd3tF93BWEyrYKj(XOwwi2yCoHvYko5CIUkNE3ZN963t3EnujYsVKiJEPI72B09e0EX3l(E62dlsMmrSac1QmG4oXgsyoyYJPcQAmymYpdjC1bwm8MAMfIbghXjWWJAXMmP8rGbMu(iW0q(ziHRU9gmmoyAOaLocKg(3lu)pyAihkInjhOfkW8TJMEXJeGEeVamWWJAs5JadkqsVGwW8KNybQbEaMnzQVcSCwkbiCeNEkYTNp71dM8yQGQgdgglQYaoxiDDGfdVPMzHyGXrCcm8OwSjtkFeyGjLpcmpyrvg2ZcPRdmnuGshbsd)7fQ)hmnKdfXMKd0cfy(2rtV4rcqpIxagy4rnP8rGbfinIGwW8KNybQbEaMnzQVcSb7PN9k10RI7Fp91Fpg9sf3T3O71IyzPq89KZE)IcAV47PBVb7LZsjaHJ40trU98zVH7fhm5XubvngSQJLUoCZSalgEtnZcXaJJ4ey4rTytMu(iWatkFeyA7yPRdmnuGshbsd)7fQ)hmnKdfXMKd0cfy(2rtV4rcqpIxagy4rnP8rGbfij3aTG5jpXcud8amBYuFfy6zVsn9Q4(3tF93BWE6zVkdeVeXciuRYaI7ejEIfO2E62JrVuXD7n6ETiwwkeFp5S3VOG2l(E62RsMFQel1JWviCnfTNp7PxWKhtfu1yWyPxcSy4n1mledmoItGHh1Inzs5JadmP8rGPj9sGjpZVdSkz(PcNsMG1tPMEvC)6R)a9uzG4LiwaHAvgqCNiXtSa10XOxQ4UrBrSSuiUC(ffuCDvY8tLyPEeUcHRPiF0lyAOaLocKg(3lu)pyAihkInjhOfkW8TJMEXJeGEeVamWWJAs5JadkqsiqlyEYtSa1apaZMm1xbwLbIxIybeQvzaXDIepXcuBpD7HfjtMiwaHAvgqCNy03E62BWEd2JrVuXD7nQG3tO9IVNU9(iMt5kIx4ErHs9fueBpF2RHkrw6Le)ErHs9fueBp5S3V4imI7fFpD7vjZpvIL6r4keUMI2ZN90lyYJPcQAmyS0lbwm8MAMfIbghXjWWJAXMmP8rGbMu(iW0KEP9g0hhm5z(DGvjZpv4uYeCLbIxIybeQvzaXDIepXcuthwKmzIybeQvzaXDIrF6gmGrVuXDJkyHIR7JyoLRiEH7ffk1xqrmFAOsKLEjXVxuOuFbfXKZV4imIX1vjZpvIL6r4keUMI8rVGPHcu6iqA4FVq9)GPHCOi2KCGwOaZ3oA6fpsa6r8cWadpQjLpcmOaPra0cMN8elqnWdWSjt9vGnypSizYelLFI5WjlInwm6BpD7nyVb71VNCFVxoYWn7sMFYTNCXEZUK5NC4KXYzPq8mSx89KZEmA2Lm)eUs9O9IVxCWKhtfu1yWWyrvgW5cPRdSy4n1mledmoItGHh1Inzs5JadmP8rG5blQYWEwiDD7nOpoyAOaLocKg(3lu)pyAihkInjhOfkW8TJMEXJeGEeVamWWJAs5JadkqsUe0cMN8elqnWdWSjt9vGnyp9SxPMEvC)7PV(7XOxQ4U9gDVwellfIVNC27xuq7fFpD7nypbsMkXcKyKJWvDS01TNG3B4E6R)E5Sucq4io9uKBpF2RFV4GjpMkOQXGvDS01HBMfyXWBQzwigyCeNadpQfBYKYhbgys5JatBhlDD7nOpoyAOaLocKg(3lu)pyAihkInjhOfkW8TJMEXJeGEeVamWWJAs5JadkqQ)h0cMN8elqnWdWSjt9vGnyp9SxPMEvC)7PV(7XOxQ4U9gDVwellfIVNC27xuq7fFpD7jqYujwGeJCeUQJLUU9e8E97PBpSizYeNbkzZ0vkUFXOpWKhtfu1yWQow66WnZcSy4n1mledmoItGHh1Inzs5JadmP8rGPTJLUU9gmmoyAOaLocKg(3lu)pyAihkInjhOfkW8TJMEXJeGEeVamWWJAs5JadkqQVh0cMN8elqnWdWSjt9vGLZsjaHJ40trU98zVEWKhtfu1yWCcR(iCZSalgEtnZcXaJJ4ey4rTytMu(iWatkFeyMWQpcmnuGshbsd)7fQ)hmnKdfXMKd0cfy(2rtV4rcqpIxagy4rnP8rGbfi1pe0cMN8elqnWdWKhtfu1yWCDmQbwm8MAMfIbghXjWWJAXMmP8rGbMu(iWSog1atdfO0rG0W)EH6)btd5qrSj5aTqbMVD00lEKa0J4fGbgEutkFeyqbfy2KP(kWGcaa]] )


    storeDefault( [[Feral Primary]], 'displays', 20171006.174729, [[dOZSgaGEjvVejQDPGQETcYmLumBP6Mib3wHEmk2jL2Ry3e2Ve6NQIHPO(nKJjjdfPgSemCeoOumnujDyQoosYcLslfvQfJQwoPEOc8uWYqs9CkMOcktvvnzuX0v6IkYvrcDzvUoI2iuARqr0MjX2HQ(OKspdkQ(SQ03LOrIkXPjA0O04HcNeQClOiDnKiNNKwhuuwlue(McQCQYpaJtSsKalsSWQ2Vapu8xdo7uagNyLibwKybz9l2kQdODX7nG9ygkTb47Y61RTJkdFa1hffZTdCIvIeMyNdGXJII52boXkrctSZbOI8ipo4yqcqw)ILRZbgLIMPyX8aurEKhNboXkrctAdO(OOyU9763BnXohWWIkHs5YW2mL2agwuzd5IsBadlQekLldBd5IsBG11V32iyyr6aTp))df4gxTC5hqnwmLAknhq9rrXClLBnXIPvbmSOYVRFV1K2adX3iyyr6a)hAUXvlx(bKcosgFr6gbdlshGBC1YLFagNyLirJGHfPd0(8)puiaqCmsVlR7RejITAgZdyyrLWpTbOI8iVHj1hZkrIaCJRwU8diihXXGeMy5AadX17y7UHDaQJ05hWJTkGo2QaVXwfGp2QSbmSOYboXkrct4dGXJII52gsTh7CaNu7FvIlapPIsGrhJgYff7Ca(USE9A7OYMEp8b8obRdSOsA8tXwfW7eS(a0iVV04NITkWWofNSVHpG3lDvdnE60gaV0i5LD5Q(vjUa8byCIvIenD5RiWGj7FI7aCKgIUR(vjUaCcODX79vjUaoVSlx1aoP2PGuCPnWq8yrIfK1VyROoG3jy9VRFVLgpDSvb0xpWGj7FI7agIR3X2DdB4d4Dcw)763BPXpfBvaQipYJdobhjJViTjTbS(4fa7P9EXc0A5ORvdSU(9wSiXcRA)c8qXFn4Stb4CkozFBORjaihhuSa2t7DmRyboNIt23adXJfjwyv7xGhk(RbNDkagXohW7eSEtV0vn04PJTkGcsSbO)flaUWuSG11AuzacTC01QyrIfK1VyROoaH(yqJ8(2qxtaqooOybSN27ywXce6JbnY7BaVtW6alQKgpDSvbgDmAMIDoWOJb8JTkW663BPXpf(aCF9ZnxaQNRgUzknxn8vbmSOsA80PnGHfvs5tLxk4ifVM0gyD97T04PdFag0iVV04NcFaVtW6n9sx1qJFk2QadXJfj2a0)IfaxykwW6AnQmGHfvItWrY4lsBsBa1hffZTnKAp25aEV0vn04NsBadlQSzkTbmSOsA8tPnadAK3xA80HpGtQ9gbdlshO95)FOqnty)b8obRpanY7lnE6yRcqfPKzimP0aRA)c4bgLc4h7CG11V3Ifjwqw)ITI6aoP2XjuqFvIlapPIsagNyLibwKydq)lwaCHPybRR1OYaoP2bIR3XnSyNdmjC((XjTbmYrI(18mfl1bmSOYgsTJtOGcFamEuum3(D97TMyNdSU(9wSiXgG(xSa4ctXcwxRrLbuFuum3ItWrY4lsBIDoagpkkMBXj4iz8fPnXohGkYJ8A6YxX4j2ambi0YrxRIJbjaz9lwUohqYGeaHZifVXsPasgKatGqJXwrPaurEKhhSiXcY6xSvuhaJhffZTuU1eBvaQipYJdLBnPnWOu0qUOyNd4KANIc5gGO7QNoBc]] )



end

