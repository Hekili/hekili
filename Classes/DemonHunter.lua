-- DemonHunter.lua
-- April 2017

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

local addBuffMetaFunction = ns.addBuffMetaFunction
local addCooldownMetaFunction = ns.addCooldownMetaFunction
local addGearSet = ns.addGearSet
local addGlyph = ns.addGlyph
local addMetaFunction = ns.addMetaFunction
local addPerk = ns.addPerk
local addResource = ns.addResource
local addSetting = ns.addSetting
local addStance = ns.addStance
local addTalent = ns.addTalent
local addToggle = ns.addToggle
local addTrait = ns.addTrait

local registerCustomVariable = ns.registerCustomVariable
local registerInterrupt = ns.registerInterrupt

local removeResource = ns.removeResource

local setArtifact = ns.setArtifact
local setClass = ns.setClass
local setPotion = ns.setPotion
local setRole = ns.setRole
local setRegenModel = ns.setRegenModel
local setTalentLegendary = ns.setTalentLegendary

local RegisterEvent = ns.RegisterEvent
local RegisterUnitEvent = ns.RegisterUnitEvent
local storeDefault = ns.storeDefault


local PTR = ns.PTR or false


-- This table gets loaded only if there's a supported class/specialization.
if (select(2, UnitClass('player')) == 'DEMONHUNTER') then

    ns.initializeClassModule = function ()

        local current_spec = GetSpecialization()

        setClass( 'DEMONHUNTER' )
        -- Hekili.LowImpact = true

        addResource( 'fury', SPELL_POWER_FURY, true )
        addResource( 'pain', SPELL_POWER_PAIN, true )

        addTalent( 'fel_mastery', 192939 )
        addTalent( 'felblade', 232893 )
        addTalent( 'blind_fury', 203550 )

        addTalent( 'prepared', 203551 )
        addTalent( 'demon_blades', 203555 )
        addTalent( 'demonic_appetite', 206478 )

        addTalent( 'chaos_cleave', 206475 )
        addTalent( 'first_blood', 206416 )
        addTalent( 'bloodlet', 206473 )

        addTalent( 'netherwalk', 196555 )
        addTalent( 'desperate_instincts', 205411 )
        addTalent( 'soul_rending', 204909 )

        addTalent( 'momentum', 206476 )
        addTalent( 'fel_eruption', 211881 )
        addTalent( 'nemesis', 206491 )


        addTalent( 'master_of_the_glaive', 203556 )
        addTalent( 'unleashed_power', 206477 )
        addTalent( 'demon_reborn', 193897 )

        addTalent( 'chaos_blades', 247938 )
        addTalent( 'fel_barrage', 211053 )
        addTalent( 'demonic', 213410 )

        addTalent( 'abyssal_strike', 207550 )
        addTalent( 'agonizing_flames', 207548 )
        addTalent( 'razor_spikes', 209400 )

        addTalent( 'feast_of_souls', 207697 )
        addTalent( 'fallout', 227174 )
        addTalent( 'burning_alive', 207739 )

        -- addTalent( 'felblade', 232893 )
        addTalent( 'flame_crash', 227322 )
        addTalent( 'fel_eruption', 211881 )

        addTalent( 'feed_the_demon', 218612 )
        addTalent( 'fracture', 209795 )
        addTalent( 'soul_rending', 217996 )

        addTalent( 'concentrated_sigils', 207666 )
        addTalent( 'sigil_of_chains', 202138 )
        addTalent( 'quickened_sigils', 209281 )

        addTalent( 'fel_devastation', 212084 )
        addTalent( 'blade_turning', 247253 )
        addTalent( 'spirit_bomb', 247454 )

        addTalent( 'last_resort', 209258 )
        addTalent( 'demonic_infusion', 236189 )
        addTalent( 'soul_barrier', 227225 )


        -- Traits
        -- Havoc
        addTrait( "anguish_of_the_deceiver", 201473 )
        addTrait( "balanced_blades", 201470 )
        addTrait( "bladedancers_grace", 243188 )
        addTrait( "chaos_burn", 214907 )
        addTrait( "chaos_vision", 201456 )
        addTrait( "chaotic_onslaught", 238117 )
        addTrait( "concordance_of_the_legionfall", 239042 )
        addTrait( "contained_fury", 201454 )
        addTrait( "critical_chaos", 201455 )
        addTrait( "deceivers_fury", 201463 )
        addTrait( "demon_rage", 201458 )
        addTrait( "demon_speed", 201469 )
        addTrait( "feast_on_the_souls", 201468 )
        addTrait( "fury_of_the_illidari", 201467 )
        addTrait( "illidari_ferocity", 241090 )
        addTrait( "illidari_knowledge", 201459 )
        addTrait( "inner_demons", 201471 )
        addTrait( "overwhelming_power", 201464 )
        addTrait( "rage_of_the_illidari", 201472 )
        addTrait( "sharpened_glaives", 201457 )
        addTrait( "unleashed_demons", 201460 )
        addTrait( "warglaives_of_chaos", 214795 )
        addTrait( "wide_eyes", 238045 )


        -- Vengeance
        addTrait( "aldrachi_design", 207343 )
        addTrait( "aura_of_pain", 207347 )
        addTrait( "charred_warblades", 213010 )
        addTrait( "concordance_of_the_legionfall", 239042 )
        addTrait( "defensive_spikes", 212829 )
        addTrait( "demonic_flames", 212894 )
        addTrait( "devour_souls", 212821 )
        addTrait( "embrace_the_pain", 212816 )
        addTrait( "erupting_souls", 238082 )
        addTrait( "fiery_demise", 212817 )
        addTrait( "flaming_soul", 238118 )
        addTrait( "fueled_by_pain", 213017 )
        addTrait( "honed_warblades", 207352 )
        addTrait( "illidari_durability", 241091 )
        addTrait( "infernal_force", 207375 )
        addTrait( "lingering_ordeal", 238046 )
        addTrait( "painbringer", 207387 )
        addTrait( "shatter_the_souls", 212827 )
        addTrait( "siphon_power", 218910 )
        addTrait( "soul_carver", 207407 )
        addTrait( "soulgorger", 214909 )
        addTrait( "tormented_souls", 214744 )
        addTrait( "will_of_the_illidari", 212819 )


        -- Auras.
        addAura( 'blade_dance', 188499, 'duration', 1 )
        addAura( 'blade_turning', 247253, 'duration', 5 )
        addAura( 'blur', 198589, 'duration', 10 )
        addAura( 'chaos_nova', 179067, 'duration', 5 )
        addAura( 'chaos_blades', 247938, 'duration', 18 )
        addAura( 'darkness', 209426, 'duration', 8 )
        addAura( 'death_sweep', 210152, 'duration', 1 )
        addAura( 'empower_wards', 218256, 'duration', 6 )
        addAura( 'fel_barrage', 211053, 'duration', 2 )
        addAura( 'imprison', 217832, 'duration', 60 )
        addAura( 'metamorphosis', 162264, 'duration', 30 )

            class.auras[ 187827 ] = class.auras.metamorphosis
            modifyAura( 'metamorphosis', 'id', function( x )
                if spec.vengeance then return 187827 end
                return x
            end )

            modifyAura( 'metamorphosis', 'duration', function( x )
                if spec.vengeance then return 15 end
                return x
            end )

        addAura( 'momentum', 208628, 'duration', 4 )
        addAura( 'netherwalk', 196555, 'duration', 5 )
        addAura( 'spectral_sight', 188501, 'duration', 10 )
        addAura( 'demon_spikes', 203819, 'duration', 6 )
        addAura( 'immolation_aura', 178740, 'duration', 6 )
        addAura( 'prepared', 203650, 'duration', 5 )
        addAura( 'soul_fragments', 203981, 'duration', 3600 )
        addAura( 'soul_barrier', 227225, 'duration', 12 )

        addAura( 'anguish', 202443, 'duration', 2, 'max_stacks', 10 )
        addAura( 'bloodlet', 207690, 'duration', 10 )
        addAura( 'fiery_brand', 212818, 'duration', 8 )
        addAura( 'frailty', 247456, 'duration', 20 )
        addAura( 'sigil_of_flame', 204598, 'duration', 6 )
        addAura( 'soul_carver', 207407, 'duration', 3 )
        addAura( 'vengeful_retreat', 198813, 'duration', 3 )
        addAura( 'betrayers_fury', 252165, 'duration', 8 )


        -- Fake Buffs.
        RegisterUnitEvent( "UNIT_SPELLCAST_SUCCEEDED", function( _, unit, spell, _, spellID )

            if unit ~= 'player' then return end

            if spell == class.abilities[ 'darkness' ].name then
                state.last_darkness_real = GetTime()

            elseif spell == class.abilities[ 'metamorphosis' ].name then
                state.last_metamorphosis_real = GetTime()

            elseif spell == class.abilities[ 'eye_beam' ].name then
                state.last_eye_beam_real = GetTime()

            end

        end )


        registerCustomVariable( 'last_darkness_real', 0 )
        registerCustomVariable( 'last_darkness', 0 )

        registerCustomVariable( 'last_metamorphosis_real', 0 )
        registerCustomVariable( 'last_metamorphosis', 0 )
        
        registerCustomVariable( 'last_eye_beam_real', 0 )
        registerCustomVariable( 'last_eye_beam', 0 )


        addMetaFunction( 'state', 'darkness_applied', function ()
            return max( state.last_darkness_real, state.last_darkness )
        end )

        addMetaFunction( 'state', 'metamorphosis_applied', function ()
            return max( state.last_metamorphosis_real, state.last_metamorphosis )
        end )

        addMetaFunction( 'state', 'eye_beam_applied', function ()
            return max( state.last_eye_beam_real, state.last_eye_beam )
        end )


        addAura( 'demonic_extended_metamorphosis', -20, 'name', 'Demonic: Extended Metamorphosis', 'feign', function()
            if buff.metamorphosis.up and eye_beam_applied > metamorphosis_applied then
                buff.demonic_extended_metamorphosis.count = 1
                buff.demonic_extended_metamorphosis.expires = buff.metamorphosis.expires
                buff.demonic_extended_metamorphosis.applied = eye_beam_applied
                buff.demonic_extended_metamorphosis.caster = 'player'
                return
            end

            buff.demonic_extended_metamorphosis.count = 0
            buff.demonic_extended_metamorphosis.expires = 0
            buff.demonic_extended_metamorphosis.applied = 0
            buff.demonic_extended_metamorphosis.caster = 'nobody'
        end )

        addBuffMetaFunction( 'metamorphosis', 'extended_by_demonic', function ()
            return buff.metamorphosis.up and buff.demonic_extended_metamorphosis.up
        end )


        -- DoG Reduction: -1
        -- DoG Fury PS:   30

        registerCustomVariable( 'meta_cd_multiplier', 1 )

        addHook( 'reset_precast', function ()
            state.last_darkness = 0
            state.last_metamorphosis = 0
            state.last_eye_beam = 0


            local rps = 0

            if state.equipped.convergence_of_fates then
                rps = rps + ( 3 / ( 60 / 4.35 ) )
            end

            if state.equipped.delusions_of_grandeur then
                -- From SimC model, 1/13/2018.
                local fps = 10.2 + ( state.talent.demonic.enabled and 1.2 or 0 ) + ( state.equipped.anger_of_the_halfgiants and 1.8 or 0 )

                if state.set_bonus.tier19_2pc > 0 then fps = fps * 1.1 end

                -- SimC uses base haste, we'll use current since we recalc each time.
                fps = fps / state.haste

                -- Chaos Strike accounts for most Fury expenditure.
                fps = fps + ( ( fps * 0.9 ) * 0.5 * ( state.stat.crit / 100 ) )

                rps = rps + ( fps / 30 ) * ( 1 )
            end

            state.meta_cd_multiplier = 1 / ( 1 + rps )
        end )


        addHook( 'spend', function( amt, resource )
            if state.equipped.delusions_of_grandeur and resource == 'fury' then
                state.cooldown.metamorphosis.expires = state.cooldown.metamorphosis.expires - ( 30 / amt )
            end
        end )

        addHook( 'gain', function( amt, resource, overcap )
            if state.spec.vengeance and state.talent.blade_turning.enabled and state.buff.blade_turning.up and resource == 'pain' then
                state.pain.actual = max( 0, min( state.pain.max, state.pain.actual + ( 0.2 * amount ) ) )
            end
        end )


        setRegenModel( {
            prepared = {
                resource = 'fury',

                spec = 'havoc',
                talent = 'prepared',
                aura = 'prepared',

                last = function ()
                    local app = state.buff.prepared.applied
                    local t = state.query_time

                    local step = 0.1

                    return app + ( floor( ( t - app ) / step ) * step )
                end,

                interval = 0.1,

                value = 1
            },

            metamorphosis = {
                resource = 'pain',

                spec = 'vengeance',
                aura = 'metamorphosis',

                last = function ()
                    local app = state.buff.metamorphosis.applied
                    local t = state.query_time

                    return app + floor( t - app )
                end,

                interval = 1,
                value = 7
            },

            immolation = {
                resource = 'pain',

                spec = 'vengeance',
                aura = 'immolation_aura',

                last = function ()
                    local app = state.buff.immolation_aura.applied
                    local t = state.query_time

                    return app + floor( t - app )
                end,

                interval = 1,
                value = 2
            },

        } )


        -- Gear Sets
        addGearSet( 'tier19', 138375, 138376, 138377, 138378, 138379, 138380 )
        addGearSet( 'tier20', 147130, 147132, 147128, 147127, 147129, 147131 )
        addGearSet( 'tier21', 152121, 152123, 152119, 152118, 152120, 152122 )
            addAura( 'havoc_t21_4pc', 252165, 'duration', 8 )

        addGearSet( 'class', 139715, 139716, 139717, 139718, 139719, 139720, 139721, 139722 )

        addGearSet( 'convergence_of_fates', 140806 )

        addGearSet( 'twinblades_of_the_deceiver', 127829 )
        addGearSet( 'aldrachi_warblades', 128832 )

        setArtifact( 'twinblades_of_the_deceiver' )
        setArtifact( 'aldrachi_warblades' )

        addGearSet( 'achor_the_eternal_hunger', 137014 )
        addGearSet( 'anger_of_the_halfgiants', 137038 )
        addGearSet( 'cinidaria_the_symbiote', 133976 )
        addGearSet( 'delusions_of_grandeur', 144279 )
        addGearSet( 'kiljaedens_burning_wish', 144259 )
        addGearSet( 'loramus_thalipedes_sacrifice', 137022 )
        addGearSet( 'moarg_bionic_stabilizers', 137090 )
        addGearSet( 'prydaz_xavarics_magnum_opus', 132444 )
        addGearSet( 'raddons_cascading_eyes', 137061 )
        addGearSet( 'sephuzs_secret', 132452 )
        addGearSet( 'the_sentinels_eternal_refuge', 146669 )

        addGearSet( "soul_of_the_slayer", 151639 )
        addGearSet( "chaos_theory", 151798 )
        addGearSet( "oblivions_embrace", 151799 )

        setTalentLegendary( 'soul_of_the_slayer', 'havoc',      'first_blood' )
        setTalentLegendary( 'soul_of_the_slayer', 'vengeance',  'fallout' )

        addHook( 'specializationChanged', function ()
            setPotion( 'prolonged_power' )
            setRole( 'attack' )
        end )


        -- TODO:  Sigil of Flame stuff.
        -- in_flight

        --[[ addHook( 'spend', function( amt, resource )
            if resource == 'maelstrom' and state.spec.elemental and state.talent.aftershock.enabled then
                local refund = amt * 0.3
                refund = refund - ( refund % 1 )
                state.gain( refund, 'maelstrom' )
            end
        end ) ]]

        --[[ addToggle( 'artifact_ability', true, 'Artifact Ability', 'Set a keybinding to toggle your artifact ability on/off in your priority lists.' )

        addSetting( 'artifact_cooldown', true, {
            name = "Artifact Ability: Cooldown Override",
            type = "toggle",
            desc = "If |cFF00FF00true|r, when your Cooldown toggle is |cFF00FF00ON|r then the toggle for artifact ability will be overriden and Doom Winds will be shown regardless of your Artifact Ability toggle.",
            width = "full"
        } ) ]]

        addSetting( 'use_fel_rush', false, {
            name = "Havoc: Use Fel Rush",
            type = "toggle",
            desc = "If |cFF00FF00true|r, the addon will recommend the use of Fel Rush.  Using Fel Rush can be very valuable for some talent combinations, but bears movement-related risks.",
            width = "full"
        } )

        addSetting( 'range_mgmt', false, {
            name = "Havoc: Simulate Movement",
            type = "toggle",
            desc = "If |cFF00FF00true|r, the addon will try to estimate your positioning changes when it recommends Fel Rush or Vengeful Retreat.  This can be inaccurate.",
            width = "full"
        } )

        addSetting( 'fury_range_aoe', true, {
            name = "Havoc: Fury of the Illidari, Require Target(s)",
            type = "toggle",
            desc = "If |cFF00FF00true|r, the addon will require either (1) your target is within range or (2) you have multiple other nearby targets before recommending Fury of the Illidari.",
            width = "full"
        } )

        addSetting( 'pool_for_chaos_cleave', false, {
            name = "Havoc: Pool Fury for Chaos Cleave",
            type = "toggle",
            desc = "If |cFF00FF00true|r, when Chaos Cleave is talented, the addon will reserve a large amount of Fury when you are fighting a single-target, so that you will be able to hit Chaos Strike " ..
                "several times if/when a wave of additional enemy arrives.  You may want to adjust this based on your boss-fight.  If a boss is purely-single target, then you would want this to be |cFFFF0000false|r.",
            width = "full"
        } )

        addToggle( 'use_defensives', true, 'Vengeance: Use Defensives', 'Enable defensive abilities in the Vengeance priority lists.' )

        addSetting( 'danger_threshold', 50, {
            name = "Vengeance: Health Danger Threshold",
            type = "range",
            desc = "Below this percentage of maximum health, certain defensive abilities may be prioritized in the Vengeance priority lists.",
            min = 1,
            max = 80,
            step = 1,
            width = "full",
        } )

        addMetaFunction( 'state', 'danger_threshold', function ()
            return settings.danger_threshold
        end )

        addSetting( 'critical_threshold', 30, {
            name = "Vengeance: Health Critical Threshold",
            type = "range",
            desc = "Below this percentage of maximum health, certain defensive abilities may be more highly prioritized in the Vengeance priority lists.",
            min = 1,
            max = 80,
            step = 1,
            width = "full",
        } )

        addMetaFunction( 'state', 'critical_threshold', function ()
            return settings.critical_threshold
        end )

        rawset( state, 'pain_deficit_limit', 25 )




        addAbility( 'consume_magic', {
            id = 183752,
            spend = -50,
            spend_type = 'fury',
            cast = 0,
            gcdType = 'off',
            cooldown = 15,
            usable = function () return target.casting end,
            toggle = 'interrupts'
        } )

        modifyAbility( 'consume_magic', 'spend_type', function( x )
            if spec.vengeance then return 'pain' end
            return x
        end )

        addHandler( 'consume_magic', function ()
            if target.casting then
                gain( 50, spec.vengeance and 'pain' or 'fury' )
            end
            interrupt()
        end )


        addAbility( 'darkness', {
            id = 196718,
            spend = 0,
            spend_type = 'fury',
            gcdType = 'off',
            cooldown = 180,
        } )

        addHandler( 'darkness', function ()
            last_darkness = query_time
            applyBuff( 'darkness', 8 )
        end )


        addAbility( 'demons_bite', {
            id = 162243,
            spend = -20,
            spend_type = 'fury',
            cast = 0,
            gcdType = 'melee',
            cooldown = 0,
            notalent = 'demon_blades',
        } )

        modifyAbility( 'demons_bite', 'spend', function( x )
            if equipped.anger_of_the_halfgiants then
                return x - 1
            end
            return x
        end )


        addAbility( 'chaos_strike', {
            id = 162794,
            spend = 40,
            spend_type = 'fury',
            cast = 0,
            gcdType = 'melee',
            cooldown = 0,
            known = function() return spec.havoc and buff.metamorphosis.down end,
            bind = 'annihilation',
            texture = 1305152,
        } )

        modifyAbility( 'chaos_strike', 'spend', function( x )
            if stat.crit >= 100 then return x - 20 end
            return x
        end )


        addAbility( 'annihilation', {
            id = 201427,
            spend = 40,
            spend_type = 'fury',
            cast = 0,
            gcdType = 'melee',
            cooldown = 0,
            known = function() return spec.havoc and buff.metamorphosis.up end,
            bind = 'chaos_strike',
            texture = 1303275,
            recheck = function () return buff.metamorphosis.remains - 5, buff.metamorphosis.remains end,
        } )

        modifyAbility( 'annihilation', 'spend', function( x )
            if stat.crit >= 100 then return x - 20 end
            return x
        end )


        addAbility( 'blade_dance', {
            id = 188499,
            spend = 35,
            spend_type = 'fury',
            cast = 0,
            gcdType = 'melee',
            cooldown = 10,
            known = function() return spec.havoc and buff.metamorphosis.down end,
            bind = 'death_sweep',
            texture = 1305149
        } )

        modifyAbility( 'blade_dance', 'spend', function( x )
            return talent.first_blood.enabled and ( x - 20 ) or x
        end )

        addHandler( 'blade_dance', function ()
            applyBuff( 'blade_dance', 1 )
            if set_bonus.tier20_2pc == 1 and target.within8 then gain( 20, 'fury' ) end
        end )


        addAbility( 'chaos_nova', {
            id = 179057,
            spend = 30,
            spend_type = 'fury',
            cast = 0,
            gcdType = 'spell',
            cooldown = 60
        } )

        addHandler( 'chaos_nova', function ()
            applyDebuff( 'target', 'chaos_nova', 5 )
        end )


        addAbility( 'death_sweep', {
            id = 210152,
            spend = 35,
            spend_type = 'fury',
            cast = 0,
            gcdType = 'melee',
            cooldown = 8,
            known = function() return spec.havoc and buff.metamorphosis.up end,
            bind = 'blade_dance',
            texture = 1309099
        } )

        modifyAbility( 'death_sweep', 'spend', function( x )
            return talent.first_blood.enabled and ( x - 20 ) or x
        end )

        addHandler( 'death_sweep', function ()
            applyBuff( 'death_sweep', 1 )
            if set_bonus.tier20_2pc == 1 and target.within8 then gain( 20, 'fury' ) end
        end )


        addAbility( 'fury_of_the_illidari', {
            id = 201467,
            spend = 0,
            spend_type = 'fury',
            cast = 0,
            gcdType = 'melee',
            cooldown = 60,
            known = function() return equipped.twinblades_of_the_deceiver end,
            toggle = 'artifact',
            usable = function () return ( not settings.fury_range_aoe ) or target.within8 or active_enemies > 1 end,
            recheck = function () return cooldown.chaos_blades.remains - 30, cooldown.chaos_blades.remains end,
        } )


        addAbility( 'eye_beam', {
            id = 198013,
            spend = 50,
            spend_type = 'fury',
            cast = 2,
            channeled = true,
            gcdType = 'melee',
            cooldown = 45,
            recheck = function () return buff.metamorphosis.remains - 8, buff.metamorphosis.remains end
        } )

        modifyAbility( 'eye_beam', 'cast', function( x )
            if talent.blind_fury.enabled then return x * 1.5 end
            return x
        end )

        modifyAbility ( 'eye_beam', 'cooldown', function( x )
            if equipped.raddons_cascading_eyes then
                if talent.blind_fury.enabled then
                    return x - ( 1.5 * active_enemies )
                else
                    return x - ( active_enemies )
                end
            end
            return x
        end )

        modifyAbility( 'eye_beam', 'spend', function( x )
            return x - ( 5 * artifact.wide_eyes.rank )
        end )

        addHandler( 'eye_beam', function ()
            if talent.blind_fury.enabled then gain( 105, 'fury' ) end

            if artifact.anguish_of_the_deceiver.enabled then
                applyDebuff( 'target', 'anguish', 2 )
                active_dot.anguish = max( active_dot.anguish, active_enemies )
            end

            if talent.demonic.enabled then
                if buff.metamorphosis.up then
                    if buff.demonic_extended_metamorphosis.down then
                        buff.metamorphosis.expires = buff.metamorphosis.expires + 8
                        applyBuff( 'demonic_extended_metamorphosis', buff.metamorphosis.remains )
                    end
                else
                    applyBuff( 'metamorphosis', action.eye_beam.cast + 8 ) -- Cheating here, since channels fire handlers at start of cast.
                    applyBuff( 'demonic_extended_metamorphosis', buff.metamorphosis.remains )                    
                end
            end

            if set_bonus.tier21_4pc == 1 then applyBuff( 'havoc_t21_4pc' ) end

            last_eye_beam = query_time
        end )


        addAbility( 'throw_glaive', {
            id = 185123,
            spend = 0,
            spend_type = 'fury',
            cast = 0,
            charges = 1,
            recharge = 10,
            gcdType = 'melee',
            cooldown = 10,
            velocity = 50,
        }, 204157 )

        modifyAbility( 'throw_glaive', 'id', function( x )
            if spec.vengeance then return 204157 end
            return x
        end )

        addHandler( 'throw_glaive', function ()
            if talent.bloodlet.enabled then
                applyDebuff( 'target', 'bloodlet', 10 )
            end
        end )


        addAbility( 'fel_barrage', {
            id = 211053,
            spend = 0,
            spend_type = 'fury',
            cast = 2,
            channeled = true,
            charges = 1,
            recharge = 60,
            gcdType = 'spell',
            cooldown = 60,
            talent = 'fel_barrage',
        } )

        addHandler( 'fel_barrage', function ()
            applyBuff( 'fel_barrage', 2 )
            spendCharges( 'fel_barrage', cooldown.fel_barrage.charges )
        end )


        addAbility( 'fel_rush', {
            id = 195072,
            spend = 0,
            spend_type = 'fury',
            ready = function () return max( cooldown.global_cooldown.remains, cooldown.fel_rush.remains ) end,
            cast = 0,
            charges = 2,
            recharge = 10,
            gcdType = 'off',
            cooldown = 10,
            usable = function () return settings.use_fel_rush and cooldown.global_cooldown.remains == 0 end,
        } )

        addHandler( 'fel_rush', function ()
            if cooldown.vengeful_retreat.remains < 1 then setCooldown( 'vengeful_retreat', 1 ) end
            if talent.fel_mastery.enabled then gain( 30, 'fury' ) end
            if talent.momentum.enabled then applyBuff( 'momentum', 4 ) end
            if settings.range_mgmt then setDistance( abs( target.distance - 15 ) ) end
            setCooldown( 'global_cooldown', 0.25 )
        end )


        addAbility( 'vengeful_retreat', {
            id = 198793,
            spend = 0,
            spend_type = 'fury',
            cast = 0,
            gcdType = 'spell',
            cooldown = 25,
            usable = function () return not settings.range_mgmt or target.within8 end
        } )

        modifyAbility( 'vengeful_retreat', 'cooldown', function( x )
            return talent.prepared.enabled and ( x - 10 ) or x
        end )

        addHandler( 'vengeful_retreat', function ()
            applyDebuff( 'target', 'vengeful_retreat', 3 )
            active_dot.vengeful_retreat = max( active_dot.vengeful_retreat, active_enemies )
            if cooldown.fel_rush.remains < 1 then setCooldown( 'fel_rush', 1 ) end
            if talent.prepared.enabled then applyBuff( 'prepared', 5 ) end
            if talent.momentum.enabled then applyBuff( 'momentum', 4 ) end
        end )


        addAbility( 'blur', {
            id = 198589,
            spend = 0,
            spend_type = 'fury',
            cast = 0,
            gcdType = 'off',
            cooldown = 60,
        } )

        addHandler( 'blur', function ()
            applyBuff( 'blur', 10 )
            -- Achor, the Eternal Hunger: doesn't really matter.
        end )


        addAbility( 'metamorphosis', {
            id = 191427,
            spend = 0,
            spend_type = 'fury',
            cast = 0,
            gcdType = 'spell',
            cooldown = 300,
            toggle = 'cooldowns',
        }, 187827 )

        modifyAbility( 'metamorphosis', 'id', function( x )
            if spec.vengeance then return 187827 end
            return x
        end )

        modifyAbility( 'metamorphosis', 'cooldown', function( x )
            if spec.havoc then return x - ( 20 * artifact.unleashed_demons.rank ) end
            return x
        end )

        addHandler( 'metamorphosis', function ()
            applyBuff( 'metamorphosis', 30 )
            stat.haste = stat.haste + 25
            if settings.range_mgmt then setDistance( 8 ) end
            -- stat.leech = stat.leech + 30
        end )

        addCooldownMetaFunction( 'metamorphosis', 'adjusted_remains', function ()
            if not ( equipped.delusions_of_grandeur or equipped.convergence_of_fates ) then
                return cooldown.metamorphosis.remains
            end

            return cooldown.metamorphosis.remains * meta_cd_multiplier
        end )


        addAbility( 'darkness', {
            id = 196718,
            spend = 0,
            spend_type = 'fury',
            cast = 0,
            gcdType = 'off',
            cooldown = 180
        } )

        addHandler( 'darkness', function ()
            applyBuff( 'darkness', 8 )
        end )


        addAbility( 'nemesis', {
            id = 206491,
            spend = 0,
            spend_type = 'fury',
            cast = 0,
            gcdType = 'off',
            cooldown = 120,
            toggle = 'cooldowns'
        } )

        addHandler( 'nemesis', function ()
            applyDebuff( 'target', 'nemesis', 60 )
        end )


        addAbility( 'chaos_blades', {
            id = 247938,
            spend = 0,
            spend_type = 'fury',
            cast = 0,
            gcdType = 'off',
            cooldown = 120,
            toggle = 'cooldowns',
            talent = 'chaos_blades',
        } )

        addHandler( 'chaos_blades', function ()
            applyBuff( 'chaos_blades', 18 )
        end )


        addAbility( 'netherwalk', {
            id = 196555,
            spend = 0,
            spend_type = 'fury',
            cast = 0,
            gcdType = 'spell',
            cooldown = 120
        } )

        addHandler( 'netherwalk', function ()
            applyBuff( 'netherwalk', 5 )
        end )


        addAbility( 'fel_eruption', {
            id = 211881,
            spend =10,
            spend_type = 'fury',
            cast = 0,
            gcdType = 'spell',
            cooldown = 30
        } )

        addHandler( 'fel_eruption', function()
            applyDebuff( 'target', 'fel_eruption', 2 )
        end )


        addAbility( 'felblade', {
            id = 232893,
            spend = -30,
            spend_type = 'fury',
            cast = 0,
            gcdType = 'melee',
            cooldown = 15,
            usable = function () return not settings.range_mgmt or target.within15 end,
            recheck = function () return cooldown.death_sweep.remains - 2 * gcd, cooldown.death_sweep.remains, cooldown.blade_dance.remains - 2 * gcd, cooldown.blade_dance.remains end,
            talent = 'felblade'
        } )

        addHandler( 'felblade', function ()
            if settings.range_mgmt then setDistance( 5 ) end
        end )


        addAbility( 'demon_spikes', {
            id = 203720,
            spend = 20,
            spend_type = 'pain',
            cast = 0,
            charges = 2,
            recharge = 15,
            cooldown = 15,
            gcdType = 'off'
        } )

        modifyAbility( 'demon_spikes', 'charges', function( x )
            if equipped.oblivions_embrace then return x + 1 end
            return x
        end )

        addHandler( 'demon_spikes', function ()
            applyBuff( 'demon_spikes', 6 )
        end )


        -- Demonic Infusion
        --[[ Draw from the power of the Twisting Nether to instantly activate and then refill your charges of Demon Spikes.    Generates 60 Pain. ]]

        addAbility( "demonic_infusion", {
            id = 236189,
            spend = -60,
            spend_type = 'pain',
            cast = 0,
            gcdType = "spell",
            talent = "demonic_infusion",
            cooldown = 120,
            min_range = 0,
            max_range = 0,
        } )

        addHandler( "demonic_infusion", function ()
            applyBuff( 'demon_spikes', 6 )
            gainCharges( 'demon_spikes', 2 )
        end )


        -- Empower Wards
        --[[ Reduces magical damage taken by 30% for 6 sec. ]]

        addAbility( "empower_wards", {
            id = 218256,
            spend = 0,
            cast = 0,
            gcdType = "off",
            cooldown = 20,
            charges = 1,
            recharge = 20,
            min_range = 0,
            max_range = 0,
        } )

        modifyAbility( 'empower_wards', 'charges', function( x )
            if equipped.oblivions_embrace then return x + 1 end
            return x
        end )

        addHandler( "empower_wards", function ()
            applyBuff( "empower_wards", 6 )
        end )


        addAbility( 'fel_devastation', {
            id = 212084,
            spend = 30,
            spend_type = 'pain',
            cast = 2,
            channeled = true,
            cooldown = 60,
            gcdType = 'spell',
        } )

        modifyAbility( 'fel_devastation', 'cast', function( x ) return x * haste end )

        addHandler( 'fel_devastation', function ()
            health.actual = min( health.max, health.actual + ( stat.attack_power * 25 ) )
        end )


        addAbility( 'fiery_brand', {
            id = 204021,
            spend = 0,
            spend_type = 'pain',
            cast = 0,
            cooldown = 60,
            gcdType = 'spell'
        } )

        addHandler( 'fiery_brand', function ()
            applyDebuff( 'target', 'fiery_brand', 8 )
        end )


        addAbility( 'fracture', {
            id = 209795,
            spend = 30,
            spend_type = 'pain',
            cast = 0,
            cooldown = 0,
            gcdType = 'spell',
        } )

        addHandler( 'fracture', function ()
            addStack( 'soul_fragments', 2, 3600 )
        end )


        addAbility( 'immolation_aura', {
            id = 178740,
            spend = -8,
            spend_type = 'pain',
            cast = 0,
            cooldown = 15,
            gcdType = 'spell',
        } )

        -- Modeled as 8 pain immediately, + 6 ticks of 2 per sec.
        addHandler( 'immolation_aura', function ()
            applyBuff( 'immolation_aura', 6 )
        end )


        addAbility( 'infernal_strike', {
            id = 189110,
            spend = 0,
            spend_type = 'pain',
            cast = 1,
            cooldown = 20,
            charges = 2,
            recharge = 20,
            gcdType = 'spell',
            velocity = 30,
            usable = function () return not prev_gcd[1].infernal_strike end,
            passive = false,
        } )

        addHandler( 'infernal_strike', function ()
            setDistance( 0, 5 )
        end )


        addAbility( 'shear', {
            id = 203782,
            spend = -10,
            spend_type = 'pain',
            cast = 0,
            cooldown = 0,
            nobuff = 'metamorphosis',
            spec = 'vengeance',
            gcdType = 'melee',
            bind = 'sever',
            texture = 1344648
        } )


        addAbility( 'sever', {
            id = 235964,
            known = 203782,
            spend = -10,
            spend_type = 'pain',
            cast = 0,
            cooldown = 0,
            buff = 'metamorphosis',
            spec = 'vengeance',
            gcdType = 'melee',
            bind = 'shear',
            texture = 1380369
        } )


        addAbility( 'sigil_of_flame', {
            id = 204596,
            spend = 0,
            spend_type = 'pain',
            cast = 0,
            cooldown = 30,
            gcdType = 'spell',
            passive = true,
        } )

        -- NYI: Sigil Placed


        addAbility( 'soul_barrier', {
            id = 227225,
            spend = 10,
            spend_type = 'pain',
            cast = 0,
            cooldown = 30,
            gcdType = 'spell'
        } )

        addHandler( 'soul_barrier', function ()
            gainChargeTime( 'demon_spikes', buff.soul_fragments.stack )
            removeBuff( 'soul_fragments' )
            applyBuff( 'soul_barrier', 12 )
        end )


        addAbility( 'soul_carver', {
            id = 207407,
            spend = 0,
            spend_type = 'pain',
            cast = 0,
            cooldown = 40,
            gcdType = 'melee',
        } )

        addHandler( 'soul_carver', function ()
            addStack( 'soul_fragments', 2, 3600 )
            applyDebuff( 'target', 'soul_carver', 3 )
        end )


        addAbility( 'soul_cleave', {
            id = 228477,
            spend = 30,
            spend_type = 'pain',
            cast = 0,
            cooldown = 0,
            gcdType = 'spell',
        } )

        addHandler( 'soul_cleave', function ()
            spend( max( 0, min( 30, pain.current - 30 ) ), 'pain' )
            gainChargeTime( 'demon_spikes', buff.soul_fragments.stack )
            removeBuff( 'soul_fragments' )
        end )


        addAbility( 'spirit_bomb', {
            id = 247454,
            spend = 0,
            spend_type = 'pain',
            cast = 0,
            cooldown = 0,
            buff = 'soul_fragments',
            gcdType = 'spell',
            talent = 'spirit_bomb'
        } )

        addHandler( 'spirit_bomb', function ()
            gainChargeTime( 'demon_spikes', buff.soul_fragments.stack )
            removeBuff( 'soul_fragments' )
            applyDebuff( 'target', 'frailty', 20 )
            active_dot.frailty = max( 1, active_enemies )
        end )

    end


    storeDefault( [[SimC Havoc: default]], 'actionLists', 20180130.203734, [[dmu2paqirPwKkK2KkWOiKofHYQeOYRiiQzPcQBrqKDPkdtkoMawgH4zqLmnrjDnvi2gbvFtqzCcuLZrqiRtfK5jq5EeQ2NGQdQIAHqfEiuvtKGqDrOIgPOeNeQuZKGGBki7ukTuvKNQyQQk2Qa5TeuUlbP9s6VQ0Gf5WuTyO8yuMmLUmyZu4ZuuJMICAiVwfQzJ0TLQDR0VLmCvLworphvthX1jW2vv9DrX5HQSEbQQ5lQ2VqRb0p6mFbgYPOGVtq1QThjSW0zys0xIo6CcOGZbTvKMabVMabW1laUejWrYQoTEh0zqD8JPS4)f7qXKfmCbuIoNzeuTC9J2gq)OdoxhJcwfh6mmj6lrNSJjrJPSJjItHL8wOdCe)bRJrbBmLNhtSQO2kZ(wOdCe)jb3IxmLNhtSQO2kZ(wOdCe)jHUJwEmfEmrCPzG8iOoCj11IGykppMyvrTvM9Tqh4i(tcDhT8yk8ys4nXKy6Cgdrre8053LihJc6GVjGDCO6h6WsumDcv2GCzR3bDY4icAnFnk5DHoWrCDA9oOtoZWOPHXmme2qkjetb5ubGqZL6CwAMRZ6Dq8moIGwZxJsExOdCe)W)ovaiE2IMnXPWsEl0boI)G1XOGnpNvf1wz23cDGJ4pj4w8YZzvrTvM9Tqh4i(tcDhT8WjU0mqEeuhUK6ArqEoRkQTYSVf6ahXFsO7OLhUWBetNtafCoOTI0eiSan6Cc4Lajd46hLOdUxlI5KsQZwlOtOY26DqhLOTIOF0bNRJrbRIdDgMe9LOt2XKOXu2XeXPWsEmtEXVyu3c8hSogfSXuEEmXQIARm7JzYl(fJ6wG)KGBXlMYZJjwvuBLzFmtEXVyu3c8Ne6oA5Xu4XeXLMbYJG6WLuxlcIP88yIvf1wz2hZKx8lg1Ta)jHUJwEmfEmj8MysmDoJHOicE687sKJrbDW3eWoou9dDyjkMoHkBqUS17GozCebTMVgL8Ym5f)IrDlW1P17Go5mdJMggZWqydPKqmfKtfacnxgtIgqmDolnZ1z9oiEghrqR5RrjVmtEXVyu3c8d)7ubG4zlA2eNcl5Xm5f)IrDlWFW6yuWMNZQIARm7JzYl(fJ6wG)KGBXlpNvf1wz2hZKx8lg1Ta)jHUJwE4exAgipcQdxsDTiipNvf1wz2hZKx8lg1Ta)jHUJwE4cVrmDobuW5G2kstGWc0OZjGxcKmGRFuIo4ETiMtkPoBTGoHkBR3bDuI2Il9Jo4CDmkyvCOZWKOVeDYoMiofwYZc9ArShSogfSX0bXeRkQTYSVoq8Ej)AQ4i(tcDhT8ykyXKWJPdIjdbs8EwWaXqKyk8ycxnX0bXKOXu2X0VlrogfEzCebTMVgL8Uqh4iEmLNhtSQO2kZ(wOdCe)jHUJwEmfSykqtmjwmDqmjAmLDm97sKJrHxghrqR5RrjVmtEXVyu3c8ykppMyvrTvM9Xm5f)IrDlWFsO7OLhtblMeEmjMoNXquebpD(DjYXOGo4BcyhhQ(HoSeftNqLnix26DqNVvrrR5RrjVDG4606DqNCMHrtdJzyiSHusiMcYPcaHMlJjrfrmDolnZ1z9oi(3QOO181OK3oq8d)7ubG4ztCkSKNf61IypyDmkypGvf1wz2xhiEVKFnvCe)jHUJwEWe(bgcK49SGbIHiHJRMden7FxICmk8Y4icAnFnk5DHoWr88CwvuBLzFl0boI)Kq3rlpybAe7arZ(3LihJcVmoIGwZxJsEzM8IFXOUf455SQO2kZ(yM8IFXOUf4pj0D0YdMWftNtafCoOTI0eiSan6Cc4Lajd46hLOdUxlI5KsQZwlOtOY26DqhLOTzv)OdoxhJcwfh6mmj6lrhItHL8mqso5IrRY(G1XOGnMYZJjoqUy1kG)iiqksZnRFzXu4XutmLNhtoJG(HlSqhb8ykCXJjCftc5ys0yI4uyjpMjV4xgf8F4HUW6yuWgtbxmHRysmDoJHOicE687sKJrbDW3eWoou9dDyjkMoHkBqUS17Goyu3cxRVmqNwVd6KZmmAAymddHnKscXuqovai0CzmjkUetNZsZCDwVdIJrDlCT(YGd)7ubG4eNcl5zGKCYfJwL9bRJrbBEohixSAfWFeeifP5M1VS8CNrq)WfwOJaE4IJlHSOeNcl5Xm5f)YOG)dpyDmkydoCjMoNak4CqBfPjqybA05eWlbsgW1pkrhCVweZjLuNTwqNqLT17GokrBpI(rhCUogfSko0zys0xIo)Ue5yu4HrDlCT(YGy6Gys0yYqGeVhtGucljMcwmf2rIjHumrCkSKNbsYjxmAv2h6cRJrbBmfCXKinXKy6Cgdrre8053LihJc6GVjGDCO6h6WsumDcv2GCzR3bD(wffTMVgL8IrDlCT(YaDA9oOtoZWOPHXmme2qkjetb5ubGqZLXKOzvmDolnZ1z9oi(3QOO181OKxmQBHR1xgC4FNkae)3LihJcpmQBHR1xgCGOgcK4fSWoIqI4uyjpdKKtUy0QSpyDmkydorAetNtafCoOTI0eiSan6Cc4Lajd46hLOdUxlI5KsQZwlOtOY26DqhLOTcx)OdoxhJcwfh6mmj6lrhItHL8yM8IFzuW)HhSogfSX0bXKHajEplyGyismfEmL1My6GyIdecAnZFFRIEnk5LzYl(Lrb)h05mgIIi4PZVlrogf0bFta74q1p0HLOy6eQSb5YwVd68TkkAnFnk5LzYl(LtKOJbDA9oOtoZWOPHXmme2qkjetb5ubGqZLXKOhrmDolnZ1z9oi(3QOO181OKxMjV4xorIogo8VtfaItCkSKhZKx8lJc(p8G1XOG9adbs8EwWaXqKWZAZbCGqqRz(7Bv0RrjVmtEXVmk4)GoNak4CqBfPjqybA05eWlbsgW1pkrhCVweZjLuNTwqNqLT17GokrBdt)OdoxhJcwfh6Cgdrre80HvlxqhUD3mIPdUxlI5KsQZwlOtOYgKlB9oOJoTEh0b)A5c6qmfYnJy6CcOGZbTvKMaHfOrNtaVeizax)OeDW3eWoou9dDyjkMoHkBR3bDuI2g80p6GZ1XOGvXHodtI(s0Hvf1wz2NzAH50lRkQTYSpj0D0YJjXJPgDoJHOicE6WCk96mcQ2lfXj6GVjGDCO6h6WsumDcv2GCzR3bD0P17Go5mdJMggZWqy47uAmDMrq1gtcbeNi0CPoNLM56SEhe)OdQJFmLf)VyhkMyvrTvM9O6CcOGZbTvKMaHfOrNtaVeizax)OeDW9ArmNusD2AbDcv2wVd6mOo(Xuw8)IDOyIvf1wzwLOTcr6hDW56yuWQ4qNHjrFj6qCkSKNf61IypyDmky15mgIIi4PJuWEDgbv7LI4eDW3eWoou9dDyjkMoHkBqUS17Go606DqNCMHrtdJzyiStc2y6mJGQnMeciorO5sDolnZ1z9oi(rhuh)ykl(FXoumzHETi2r15eqbNdARinbclqJoNaEjqYaU(rj6G71IyoPK6S1c6eQSTEh0zqD8JPS4)f7qXKf61IykrBd0OF0bNRJrbRIdDoJHOicE6ifSxNrq1EPiorhCVweZjLuNTwqNqLnix26DqhDA9oOtoZWOPHXmme2jbBmDMrq1gtcbeNi0CzmjAaX05S0mxN17G4hDqD8JPS4)f7qX0wYUtpQoNak4CqBfPjqybA05eWlbsgW1pkrh8nbSJdv)qhwIIPtOY26DqNb1XpMYI)xSdftBj7ovjkrhHyWWfqjkouIQa]] )

    storeDefault( [[SimC Havoc: precombat]], 'actionLists', 20180130.203734, [[dGZgcaGEsjTjIe7ciVMuX(uuA2Q08fIBQi3LivFtiTtv1EP2ns7xvgfPsdJOghrkdLuudwfdxOoOIQtPO4yGAHa0sjIfJOLlQhcGNIAza1ZvyIKcMkcMmitxYffiptG66cQFl1wjv1MrOTdi3wKttyAKs9wsHgjPihwPrlipMKtkGwhrsxJuLZlaxg6qKs8xa1g2emZXOsSxHw3s0u)1lAuZSklIlZMLGxChO)GLHLMmmCWGGdgmSEAB(Vj0mlsa8oAAbQvs9DIZOQtKBzEUQenDyc(dBcMdIUKxeYaAEoP4kQamh3LOPMdKcjuB1zZ0MIMNAi938FtOzZ)nHMJOisuwwPisuJAUlrtLEKSzj4f3b6pyz4OWYMLGJoCwHdtWLzacHkDMAGWesltAEQH(Bcn7YFWMG5GOl5fHmGMzvwexM1Y7O77u7fPfiim1uGZizNPGq6sErO3rkVJUVtTxKwGGWutfkqiDjVi07ejY7mWcyYMgEaQeygmmWAhRENzFh53zM3zgZZjfxrfG5ewBQZXH6HyyoqkKqTvNntBkAEQH0FZ)nHMn)3eAEcRn154q9qmmlbV4oq)bldhfw2SeC0HZkCycUmdqiuPZudeMqAzsZtn0FtOzxUmRbK4g(wgqx2a]] )

    storeDefault( [[SimC Havoc: normal]], 'actionLists', 20180130.203734, [[da0oxaqisvTjvv9jqeYOaHtPQYQKiPxbIQ2fcddv1XuLwMe6zKImnseDnqK2giI6BefJJeHZbIiRdebnpquUhPO2hjshKuXcjk9qsLMiiQCrsv2OeP(OejgjicCsjWnbPDsKLsk9uQMkr1wLG2l0FvvgSkhw0IL0Jb1KP0Lv2SQ4ZKcJgvCAHEnjQzt42uSBK(nkdhvz5cEoIMoW1jPTtcFxI48suRheHA(Os7xQXxuo6qU9KQcakl6sPzO7rJU9bjivWGHe2hLfmPaDTtSKCOur(Vkb)3xnr8QPIVqQsIUdhI8aOJUoWGiJsIYrPxuo66rZQywuw0D4qKhaDi6dKIrbe8cJxgMLy0SkMTpUC7dKIrbegMzuGQHy0SkMTVF99VVQ6ZdbVW4LHzjSSsO99VVQ6ZdHHzgfOAiSSsOORtnkIGYORyun2JQ4lmqyja9cO2iCcyb0Pm6qhkZwygKsZqhDP0m0lCun2JQOpTdewcqx7eljhkvK)RmV8rx7izQb4rIYra66YzWkdLPyMrbyfDOmRuAg6iaLkIYrxpAwfZIYIUdhI8aOdrFGumkGWWmJcuneJMvXS9XLBFGumkG4zIptscwOmXOzvmBF)67FFq0N(9bsXOacdZmkq1qmAwfZ2hxU9brFWCYGgJSpn3xX(4YTpygtyzLqjumQg7rv8fgiSeqeMjJuY(uAFkzF)67FFv1NhcdZmkq1qyzLq77xF)7dI(0Vpqkgfq8mXNjjbluMy0SkMTpUC77rnuMWUNiCe0Ns1CFfH0((13)(GOpyozqJr2NM7RyF)qxNAuebLr)zIVGkjh0lGAJWjGfqNYOdDOmBHzqkndD0LsZqV0t0NwvsoORDILKdLkY)vMx(ORDKm1a8ir5iaDD5myLHYumZOaSIouMvkndDeGsAcLJUE0SkMfLfDhoe5bqhI(QQppegMzuGQHqLxFC52N(9bsXOacdZmkq1qmAwfZ23V((3he9LWGOI9n6mXr2Ns77TVFORtnkIGYO)mXxndHuJHEbuBeobSa6ugDOdLzlmdsPzOJUuAg6LEI(KndHuJHU2jwsouQi)xzE5JU2rYudWJeLJa01LZGvgktXmJcWk6qzwP0m0rakPKOC01JMvXSOSO7WHipa6GumkGOkymRyaIrZQy2((3he9PFFGumkGWWmJcuneJMvXS9XLBFv1NhcdZmkq1qOYRVF99VpyozqJr2NM7Ri66uJIiOm6aobwjFAiYOIHEbuBeobSa6ugDOdLzlmdsPzOJUuAg6Y5eyL0xPiYOIHU2jwsouQi)xzE5JU2rYudWJeLJa01LZGvgktXmJcWk6qzwP0m0rakbPOC01JMvXSOSO7WHipa6pQHYeWQHWOG(GS(EH0((3he9bZyclRekHDjGZhzjB8icZKrkzFqwFf7Ru7tdyBFC52hmJjSSsOevrA3NnPWJimtgPK9bz9vSVsTpnGT99dDDQrreug9NjQI0o0lGAJWjGfqNYOdDOmBHzqkndD0LsZqV0tufPDORDILKdLkY)vMx(ORDKm1a8ir5iaDD5myLHYumZOaSIouMvkndDeGsqYOC01JMvXSOSO7WHipa6kYqmRIrufPDF2Kcp01Pgfrqz0TlbC(ilzJh6fqTr4eWcOtz0HouMTWmiLMHo6sPzOd5wc40NxYgp01oXsYHsf5)kZlF01osMAaEKOCeGUUCgSYqzkMzuawrhkZkLMHocqjzq5ORhnRIzrzr3HdrEa0H5KbngzFAUVI99Vp97dKIrbegMzuGQHy0SkMTV)9PFFGumkG4zIptscwOmXOzvmBF)7t)(QQppeMbsdlWJdJmssOYRV)9bsXOac7mm6xvK2rsmAwfZIUo1OickJ(ZeFbvsoOxa1gHtalGoLrh6qz2cZGuAg6OlLMHEPNOpTQKC6dI3FORDILKdLkY)vMx(ORDKm1a8ir5iaDD5myLHYumZOaSIouMvkndDeGskbkhD9Ozvmlkl66uJIiOm6pt8TGkpqKrrVaQncNawaDkJo0HYSfMbP0m0rxknd9sprF6fu5bImk6ANyj5qPI8FL5Lp6AhjtnapsuocqxxodwzOmfZmkaROdLzLsZqhbOeKekhD9Ozvmlkl6oCiYdGoe9brF63hifJcimmZOavdXOzvmBFC52xv95HWWmJcuneQ867xF)7dI(0VpqkgfqaZjzKFvrAhjXOzvmBFC52xv95HaMtYi)QI0oscvE9XLBFWmMWYkHsaZjzKFvrAhjryMmsj7tP9Pj(9XLBFGmOXaeGOzFa2NnU(GS(GzmHLvcLaMtYi)QI0osIWmzKs23V((HUo1OickJ(JAO8h75dWzFrHiAZqe9cO2iCcyb0Pm6qhkZwygKsZqhDP0m0lTAOCFSN(aCwFfierBgIORDILKdLkY)vMx(ORDKm1a8ir5iaDD5myLHYumZOaSIouMvkndDeGsV8r5ORhnRIzrzr3HdrEa0vKHywfJOks7(SjfEORtnkIGYOxfPDF2Kcp0lGAJWjGfqNYOdDOmBHzqkndD0LsZqxwrAxFqUKcp01oXsYHsf5)kZlF01osMAaEKOCeGUUCgSYqzkMzuawrhkZkLMHocqP3xuo66rZQywuw0D4qKhaDqkgfqufmMvmaXOzvmBF)7lHbrf7B0zIJSpLQ5(k23)(GOp97dKIrbeMKeSWh75dWzFAiYOIrmAwfZ2hxU9PFFGumkGWWmJcuneJMvXS9XLBFv1NhcdZmkq1qOYRVF99Vpi6lHbrf7B0zIJSpLQ5(0uF)qxNAuebLrhWjWk5tdrgvm0lGAJWjGfqNYOdDOmBHzqkndD0LsZqxoNaRK(kfrgvS(G49h6ANyj5qPI8FL5Lp6AhjtnapsuocqxxodwzOmfZmkaROdLzLsZqhbO0Bruo66rZQywuw0D4qKha9h1qzc7EIWrqFkvZ9Pj(9b57dI(QQppe8cJxgMLqLxF)77TpUC7JFF)6Ru7tjqxNAuebLr)zIQiTd9cO2iCcyb0Pm6qhkZwygKsZqhDP0m0l9evrAxFq8(dDTtSKCOur(VY8YhDTJKPgGhjkhbORlNbRmuMIzgfGv0HYSsPzOJau6vtOC01JMvXSOSO7WHipa6jmiQyFJotCK9P0(E7Jl3(QQppeCsfm4pqX3pLKhmryMmsj7dY6RyF)7dI(0VpqkgfqufrQ97rnuMy0SkMTpUC77rnuMWUNiCe0Ns1CFYWVVF99Vpi6dI(syquX(gDM4i7tPAUpn13V(4YTpqkgfqufrQ97rnuMy0SkMTpUC7JCGVkJQssaIlu89Rip4(uAF877h66uJIiOm6R8(QlnOxa1gHtalGoLrh6qz2cZGuAg6OlLMHUELxFYU0GU2jwsouQi)xzE5JU2rYudWJeLJa01LZGvgktXmJcWk6qzwP0m0rak9QKOC01JMvXSOSO7WHipa6q0hifJciSZWOFvrAhjXOzvmBFC52N(9bsXOacdZmkq1qmAwfZ2hxU9vvFEimmZOavdHkV(4YTVh1qzc7EIWrqFqwFAIFFq((GOVQ6ZdbVW4LHzju513)(E7Jl3(433V(k1(uI(4YTVQ6ZdHzG0Wc84WiJKeHzYiLSpiRpiTVF99Vp97trgIzvmcEmMis147Hf(QI0UpBsHh66uJIiOm6jLg5efjiYOOxa1gHtalGoLrh6qz2cZGuAg6OlLMHUouAKtuKGiJIU2jwsouQi)xzE5JU2rYudWJeLJa01LZGvgktXmJcWk6qzwP0m0rak9cPOC01JMvXSOSO7WHipa6GumkGOkymRyaIrZQy2((3he9PFFGumkGWKKGf(ypFao7tdrgvmIrZQy2(4YTp97dKIrbegMzuGQHy0SkMTpUC7RQ(8qyyMrbQgcvE99dDDQrreugDaNaRKpnezuXqVaQncNawaDkJo0HYSfMbP0m0rxkndD5CcSs6RuezuX6dII)qx7eljhkvK)RmV8rx7izQb4rIYra66YzWkdLPyMrbyfDOmRuAg6iaLEHKr5ORhnRIzrzr3HdrEa01VpqkgfqufmMvmaXOzvmBF)7RQ(8qyginSapomYijHLvcTV)9LWGOI9n6mXr2Ns1CFAcDDQrreugDaNaRKpnezuXqVaQncNawaDkJo0HYSfMbP0m0rxkndD5CcSs6RuezuX6dcn9dDTtSKCOur(VY8YhDTJKPgGhjkhbORlNbRmuMIzgfGv0HYSsPzOJau6vguo66rZQywuw0D4qKhaDi6dKIrbe2zy0VQiTJKy0SkMTpUC7t)(aPyuaHHzgfOAignRIz7Jl3(QQppegMzuGQHqLxFC523JAOmHDpr4iOpiRpnXVpiFFq0xv95HGxy8YWSeQ867FFV9XLBF877xFLAFkrF)67FF63NImeZQye8ymrKQX3dl8bZjzKFKGqu513)(0VpfziMvXi4XyIivJVhw4Zmq23)(0VpfziMvXi4XyIivJVhw4Rks7(SjfEORtnkIGYOdZjzKFKGqu5HEbuBeobSa6ugDOdLzlmdsPzOJUuAg66YjzK95Gqu5HU2jwsouQi)xzE5JU2rYudWJeLJa01LZGvgktXmJcWk6qzwP0m0rak9QeOC01JMvXSOSO7WHipa663hifJcimmZOavdXOzvmBF)7dKIrbe2zy0VQiTJKy0SkMfDDQrreug9Nj(cQKCqVaQncNawaDkJo0HYSfMbP0m0rxknd9sprFAvj50hef)HU2jwsouQi)xzE5JU2rYudWJeLJa01LZGvgktXmJcWk6qzwP0m0rak9cjHYrxpAwfZIYIUo1OickJUDggL8Rgbd9cO2iCcyb0Pm6qhkZwygKsZqhDP0m0HCZWOqIi7t2iyORDILKdLkY)vMx(ORDKm1a8ir5iaDD5myLHYumZOaSIouMvkndDeGsf5JYrxpAwfZIYIUdhI8aOdYGgdqWubKr7EHu01Pgfrqz0FMOks7qVaQncNawaDkJo0HYSfMbP0m0rxknd9sprvK21hef)HU2jwsouQi)xzE5JU2rYudWJeLJa01LZGvgktXmJcWk6qzwP0m0rakv8fLJUE0SkMfLfDhoe5bqx)(aPyuarvWywXaeJMvXS99VpqkgfqyNHr)QI0osIrZQyw01Pgfrqz0bCcSs(0qKrfd9cO2iCcyb0Pm6qhkZwygKsZqhDP0m0LZjWkPVsrKrfRpiuYFORDILKdLkY)vMx(ORDKm1a8ir5iaDD5myLHYumZOaSIouMvkndDeGa0DEdoMIiK4eezuucsLrgeGi]] )

    storeDefault( [[SimC Havoc: cooldown]], 'actionLists', 20180130.203734, [[d4ZQfaGAekTEcv1MuQI2fbBJqL9Hq45OmBGMVa3eb3Lqv(gsQBJQDIO9QA3eTFQmkesgMszCkvvDAqdvPk1GPQHtjhKq5uieDmL48srTqKWsPuTyKA5u8qKONsAzukRtPQyIkvvMkHmzHMUIlkf5XaUm01vshw0wfuTzPQTRu5VsLNHq10qi18KcgPsvYNrsgTu67csNuqCiLQW1euUhcfVwk0VL8wLQs)Ll6kzYXRkKtPZVx5UcyFCEGQaJvOYRQfcatqO4NdSKNmmQP(QDeetgEsBBl7)2YcXfwiUTLWi6RkGbAnxVkgWalj7Io5YfDTjzsdIXtXvfWaTMR7HZtuo)KGOCeIiVKqabuM0Gy05dcC(DPbM0GOGvvGqjvD9LPJJt68bbo)U0atAqui0eoqjvD9LPtICKbzoFqGZVlnWKgefcnHdusvxFz6aAZI1rdMrK58ePZhe48tAOchHbYXUP6Iq05BW5Tf2vXOHGWP5RCCsEzSAlgKDnezecKtzUkljELqfdpnKjhVELm54vc4K8Yy1wmi7QDeetgEsBBluVSD1oYQvdaYUOpxPSfbAKqTd5OCo9vcvKm541pN02fDTjzsdIXtXvfWaTMRtcIYriI8scbeqzsdIrNFpDE61(EboojVmwTfdYewTUkgneeonFLJtYlJvBXGSRHiJqGCkZvzjXReQy4PHm541RKjhVsaNKxgR2IbzoprTqKxTJGyYWtABBH6LTR2rwTAaq2f95kLTiqJeQDihLZPVsOIKjhV(5Ke)IU2KmPbX4P4QcyGwZv61(EbG2SyD0GzezcRwoFqGZtV23lWXj5LXQTyqMWQLZhe48avbgRqLcCCsEzSAlgKjKrIDLnySZG8ekzoFdoVTnNpiW5N0qfocdKJDt1fHOZ3aX48IB7Qy0qq408vjYrgKDnezecKtzUkljELqfdpnKjhVELm54vsKJmi7QDeetgEsBBluVSD1oYQvdaYUOpxPSfbAKqTd5OCo9vcvKm541pNKOVORnjtAqmEkUQagO1CLETVxGJtYlJvBXGmHvlNpiW5bQcmwHkf44K8Yy1wmitiJe7kBWyNb5juYCEIW5f3MZhe48tAOchHbYXUP6Iq05BGyC(4QjhyjVkgneeonFfOnlwhnygr21qKriqoL5QSK4vcvm80qMC86vYKJxPSnlMZtbygr2v7iiMm8K22wOEz7QDKvRgaKDrFUszlc0iHAhYr5C6ReQizYXRFozyx01MKjnigpfxvad0AUsV23lWXj5LXQTyqMGb5juYCEIW5TfMZhe48tAOchHbYXUP6Iq05BW5f32vXOHGWP5Rw1al51qKriqoL5QSK4vcvm80qMC86vYKJxda6732aa67339UgyjfVaZv7iiMm8K22wOEz7QDKvRgaKDrFUszlc0iHAhYr5C6ReQizYXRF(CD)W(CfCofF(b]] )

    storeDefault( [[SimC Havoc: demonic]], 'actionLists', 20180130.203734, [[deK5raqicvBcO8jcbzuivofsvVscvzxOYWqvDmj1YKOEgHOPbuX1aQ02ie4BesJtcLohfIyDuiQMhHq3JcP9bu1bLalKq5HuetucfxKI0gPq4JsOYiPquoPeYnrk7KGLsr9uQMkfSvjO9c9xGmyPoSOfd4XGAYcDzLnljFMc1ObXPP0QjeuVMOQztQBtYUr53igoiTCbphjtxvxNiBNO8DIkJNcr68sK1lHQA(Ok7xLXA0a6fZQsj9JIHUqQg6UvzY1gzPmcSr(1XPimlm6MNEj1qHY8Rlw(11IKRwKLRbxWbDhoyH(OJEbWVLWOqdOqnAaDtzjGErum0D4Gf6JoDx)PESNdAyqZWICJLa6fVMhVR)up2ZPiQXEjf3yjGEXRP)AWUgqQQIdAyqZWICrICSRb7AaPQkofrn2lP4Ie5yOxaGvB)sOlBmJxLKguyFy5JErSOfoFsaDgHn0PrIfMbHun0rxivd9chZ4vjPV28(WYhDZtVKAOqz(1IwZhDZJIifGhfAaF0nbYGLNgr2uJ9ia60irHun0XhfkJgq3uwcOxefdDhoyH(Ot31FQh75ue1yVKIBSeqV4184D9N6XEUQPbPsQFHsCJLa6fVM(Rb7A6Uw8R)up2ZPiQXEjf3yjGEXR5X7A6UggsgmEuxB0RlFnpExdti6irogNSXmEvsAqH9HLpxyQ0YOUg8xdoxt)1GDnGuvfNIOg7LuCrICSRP)AWUMURHHKbJh11g96Yxtp6fay12Ve6vtdkirbb9IyrlC(Ka6mcBOtJelmdcPAOJUqQg6gX0xBwIcc6MNEj1qHY8RfTMp6Mhfrkapk0a(OBcKblpnISPg7ra0PrIcPAOJpkis0a6MYsa9IOyO7Wbl0h9p1J9CaAcjQ3ZnwcOx8AWUMURf)6p1J9CkIASxsXnwcOx8AE8UgqQQItruJ9skojOxt)1GDnmKmy8OU2Oxxg9caSA7xc9hsGihiJ1Pv2qViw0cNpjGoJWg60iXcZGqQg6OlKQHUbibICxxC60kBOBE6LudfkZVw0A(OBEuePa8Oqd4JUjqgS80iYMAShbqNgjkKQHo(Oa4Ggq3uwcOxefdDhoyH(Olld2eqpoaDghOyYGh6fay12Ve6XLpequYTbf9IyrlC(Ka6mcBOtJelmdcPAOJUqQg6fZYhY1UCBqr380lPgkuMFTO18r38Oisb4rHgWhDtGmy5PrKn1ypcGonsuivdD8rbWfnGUPSeqVikg6fay12Ve6vtdAbjOVLWqViw0cNpjGoJWg60iXcZGqQg6OlKQHUrm91MgKG(wcdDZtVKAOqz(1IwZhDZJIifGhfAaF0nbYGLNgr2uJ9ia60irHun0XhfebOb0nLLa6frXq3HdwOp60DT4x)PESNtruJ9skUXsa9IxZJ31asvvCkIASxsXjb9AE8UgMq0rICmo1(urcqHqOSuCzuewI6xeuyQ0YOUweVM)10JEbawT9lHELuOeisfOhYaz1ABmdw0lIfTW5tcOZiSHonsSWmiKQHo6cPAOBesHsxtQU(HSRlsRTXmyr380lPgkuMFTO18r38Oisb4rHgWhDtGmy5PrKn1ypcGonsuivdD8rbrrdOBklb0lIIHUdhSqF0LLbBcOhhGoJdumzW7AWUgMq0rICmUvAGawQ4ctLwg11G)AW9AWUw8RHjeDKihJtTpvKauieklfxyzSe6fay12Ve6a6moqXKbp0lIfTW5tcOZiSHonsSWmiKQHo6cPAOlMoJ76IjzWdDZtVKAOqz(1IwZhDZJIifGhfAaF0nbYGLNgr2uJ9ia60irHun0Xhfkw0a6MYsa9IOyO7Wbl0h9p1J9CaAcjQ3ZnwcOx8AWUoHFRSbASPSJ6AWB0RlFnyxt31IF9N6XEovs9laIub6HmqgRtRSXnwcOx8AE8Uw8R)up2ZPiQXEjf3yjGEXR5X7AaPQkofrn2lP4KGEn9xd210DDc)wzd0ytzh11G3OxlYRPh9caSA7xc9hsGihiJ1Pv2qViw0cNpjGoJWg60iXcZGqQg6OlKQHUbibICxxC60kBxtxn9OBE6LudfkZVw0A(OBEuePa8Oqd4JUjqgS80iYMAShbqNgjkKQHo(OGrcAaDtzjGErum0D4Gf6JELuOexCvwy7Fn4n61IK)1GDnDxxjfkXblfcJ9xlIxdo8VMhVRbKQQ4u7tfjafcHYsXfjYXUME0laWQTFj0RMgqNXHErSOfoFsaDgHn0PrIfMbHun0rxivdDJyAaDgh6MNEj1qHY8RfTMp6Mhfrkapk0a(OBcKblpnISPg7ra0PrIcPAOJpkuZhnGUPSeqVikg6oCWc9rpHFRSbASPSJ6AWFD9184DnDxl(1FQh75a0wweuLuOe3yjGEXR5X76kPqjU4QSW2)AWB0RfL)10Fnyxt31IFnGuvfxCkcZcdAgP)yXfbP2NksakecLLItc6184DnDxtTheaHjrX92fkxdcCGcFn4VM)1GDnGuvfNAFQibOqiuwkUWuPLrDn4VUweCn9xtp6fay12Ve6R0abSuHErSOfoFsaDgHn0PrIfMbHun0rxivdDtlTRfBPcDZtVKAOqz(1IwZhDZJIifGhfAaF0nbYGLNgr2uJ9ia60irHun0XhfQRrdOBklb0lIIHUdhSqF0P7AXV(t9ypNIOg7LuCJLa6fVMhVRbKQQ4ue1yVKItc6184DDLuOexCvwy7FTiETi5FDX7A6UgqQQIdAyqZWICsqVgSRl2R5X7A(xt)184DnGuvfNAFQibOqiuwkUWuPLrDTiEn4En9xd21IFTSmyta94GsiAlZyqvKaiaDghOyYGh6fay12Ve6jJzHy15Bjm0lIfTW5tcOZiSHonsSWmiKQHo6cPAOxaJzHy15Bjm0np9sQHcL5xlAnF0npkIuaEuOb8r3eidwEAeztn2JaOtJefs1qhFuOUmAaDtzjGErum0D4Gf6J(N6XEoanHe175glb0lEnyxt31IF9N6XEovs9laIub6HmqgRtRSXnwcOx8AE8Uw8R)up2ZPiQXEjf3yjGEXR5X7AaPQkofrn2lP4KGEn9xd21j8BLnqJnLDuxdEJETirVaaR2(Lq)HeiYbYyDALn0lIfTW5tcOZiSHonsSWmiKQHo6cPAOBasGi31fNoTY210vME0np9sQHcL5xlAnF0npkIuaEuOb8r3eidwEAeztn2JaOtJefs1qhFuOwKOb0nLLa6frXq3HdwOp60DT4x)PESNtruJ9skUXsa9IxZJ31asvvCkIASxsXjb9AE8UUskuIlUklS9VweVwK8VU4DnDxdivvXbnmOzyrojOxd21f7184Dn)RP)A6VgSRf)AzzWMa6XbLq0wMXGQibqWqscfiQpyLFxd21IFTSmyta94GsiAlZyqvKai1(8AWUw8RLLbBcOhhucrBzgdQIeabOZ4aftg8qVaaR2(LqhgssOar9bR8d9IyrlC(Ka6mcBOtJelmdcPAOJUqQg6Majjux7FWk)q380lPgkuMFTO18r38Oisb4rHgWhDtGmy5PrKn1ypcGonsuivdD8rHAWbnGUPSeqVikg6oCWc9rx8R)up2ZPiQXEjf3yjGEXRb76p1J9CXPimqa6mokUXsa9Ixd21IFnmHOJe5yCR0abSuXfwglDnyxt31WqYGXJ6AJED5RPh9caSA7xc9QPbfKOGGErSOfoFsaDgHn0PrIfMbHun0rxivdDJy6Rnlrb5A6QPhDZtVKAOqz(1IwZhDZJIifGhfAaF0nbYGLNgr2uJ9ia60irHun0XhfQbx0a6MYsa9IOyOxaGvB)sOhNIWOaby)HErSOfoFsaDgHn0PrIfMbHun0rxivd9IzkcteI6AXS)q380lPgkuMFTO18r38Oisb4rHgWhDtGmy5PrKn1ypcGonsuivdD8rHAraAaDtzjGErum0D4Gf6J(NbJ3ZfTuFYG31G)6A(xZJ31IF9N6XEoanHe175glb0lIEbawT9lH(djqKdKX60kBOxelAHZNeqNrydDAKyHzqivdD0fs1q3aKarURloDALTRPtK0JU5PxsnuOm)ArR5JU5rrKcWJcnGp6MazWYtJiBQXEeaDAKOqQg64Jp6o0bBtTT4NVLWqbWvurXhra]] )

    storeDefault( [[Red Vengeance: precombat]], 'actionLists', 20180301.194236, [[dmJ2baGEuQAxusBJsSpQsnBi3MQANk1Ej7gQ9ROggk(TqdwQmCf5GuOJHQZbIAHuKLcslwqlNkpNs9uvpwjRdLIjcImvfmzbMoWfLIoSKlJCDuQSrusTvuI2ScTDkWhrjzzsvFgu9DkOZlLCArJwk8mq5KuuFtk11qjCpuknoq4VufVMQKfxd67YN0HsbZDSKWWPcVi2m3n5Ov0pSa6qIgl2HaYKoucrLnPDpdhcgymCRCi3BHdH(NOvwOK9fiJyTzbeCDJlqgX2AqBUg0BIRqefit67YN0FcprZDXX5owJkFshkHOYM0UNHBH32kdmUUzCqUkq0PJJys3yyIsqlD7eEI8eh9mIkFs)lxob0fq7EnO3exHikqM03LpPBgpsoCHM7oWLEr6qjev2K29mCl82wzGX1nJdYvbIoDCet6gdtucAPN4rYHlKhBGl9I0)YLta9vJYbNS9MTCb0gMg0BIRqefit67YN0hA4Igo3XkuLgq6qjev2K29mCl82wzGX1nJdYvbIoDCet6gdtucAPdA4Ig6boQsdi9VC5eqxab0)YLtaDbKa]] )

    storeDefault( [[Red Vengeance: default]], 'actionLists', 20180301.194236, [[diKbnaqibGnHsmkbLtjOAvOKc7sPgMsCmewMq8mvftdLu11eeBtvLVHszCOK4COKkRtaQ5jGUhI0(eK(Naihuj1cvv1dfGmrusPlIi2OqfNuvPvIss6MkjANK4NOKugQaOwQq6PuMQe1vrjj2QqL(kkPO9c9xKAWc0HPAXi5XIAYs6YGnRkFMKmAHQonXRvsy2kUnk2Tk)gvdxclNupxKPl11ruBxO8DLKoVez9OKunFuQ2pj1ibwgnfNbqlkuvhmUWPc8ldbS6Gv45KNgnwl8CYtJ)rlkmGNaujYcbRS8zHytW6I8JGvqZkGS4JWQ7TWpujewHaT15w4xclJkeyz0wjVgxxR4maAKtaDsujdn)r)gNbqZYAPOrlS2h469BCgGoR9u8B4CQbQSubkYV3ojQKHM)OFJZaBnW4YLcKuIWzN9WcG2h469BCgGoR9u8B4CQbQHJMIZaOXQKa1bnrLmQdYFQdgNXzGaeARPKr6sOfZ1ItnaAFVQK9MRr74hGwuyapbOsKfIFeSTx(qGgjNtnqf)JnQeblJ2k5146AfNbqBvxA6hxtxOfUw6s0oLmslqcnlRLIgTWYC(u5REBHHHpEl8J2jR9TgyC5sbUSdHLcxUDfEsw6qjLiKWzN9WAFGR3pyOgVcB4CQbQSK58PYx92pyOgVcBnW4YLcCzhclfUC7k8KS0HsAHlhDfEswA6ryKoC2zpS2h469dgAqtUOf(THZPgOYsMZNkF1B)GHg0KlAHFBnW4YLcCzhs4SZEyXCT4udSjNa6KOsgA(J(nodWINBjgqdhWiqkusJWsMZNkF1BNevYqZF0VXzGTgyC5sbUSdjC2zpS4bF643fGodxhiPv)ubA6oEnKINpvwYC(u5RE7hm0viMNAVf(T1aJlxkWLDiSu4YTZK1A46qj9Zs4OTMsgPlHwmxlo1aOffgWtaQezH4hbB7LpeO99Qs2BUgTJFaAkodGgRPlT6GpUwDWaSw4APlPo4AkzKwGuacnsoNAGk(hBu5dwgnsoNAGk(hnlRLIgn0uCgaTaIFjYmG6GR0vjz0wtjJ0LqlZVezgGMXvjz0IcjozDgsyzSrlkmGNauHaTVxvYEZ1OD8dWgvy9yz0i5CQbQ4F0SSwkA0AUkvdSjNa6k8GljXGeARPKr6sOL9zO9Cl8JEKuJwuyapbOsKfIFeSTx(qG23RkzV5A0o(bOP4maASw4bxsIbj0wjVQ4maArHQ6GXfovGFziGvhScp4ssmiHnQecwgnsoNAGk(hnfNbqZ4Kh1bdOb8yaArHb8eGkrwi(rW2E5dbAFVQK9MRr74hG2AkzKUeAjo5HopGhdqZYAPOrRWLBNjR1W1Hs6VfwOi)E7eN8q)0Ukg460o1EEfSgHeiPXd(0XVRWtYstxKBSrLFyz0i5CQbQ4F0SSwkA0AFGR3PcrlnnfNHAdNtnqLLkqr(92pTltxARbgxUuGHWcf53BN4Kh6N2vXaxN2P2ZRiusjqlkmGNaujYcXpc22lFiq77vLS3CnAh)a0uCganRq0sRo4FodfARPKr6sOLkeT00uCgkSrf2WYOrY5uduX)OzzTu0Ov4YTRWtYshkPeHGwuyapbOsKfIFeSTx(qG23RkzV5A0o(bOP4maAFzy4J3c)uhCnzTJ2AkzKUeAcddF8w4hTtw7yJkScwgnsoNAGk(hnlRLIgnp3smGgoGrGuOKgHLkqr(92jrLm08h9BCgyRbgxUuGKsGwuyapbOsKfIFeSTx(qG23RkzV5A0o(bOP4maAMOsg1b5p1bJZ4maARPKr6sOLevYqZF0VXzaSrfwhwgnsoNAGk(hnlRLIgT2h469dgQXRWgoNAGklfUC7k8KS0HsAHlhDfEswA6ryKgTOWaEcqLile)iyBV8HaTVxvYEZ1OD8dqtXza0IdmuJxb0wtjJ0Lq7bd14vaBuHyblJgjNtnqf)JMIZaOXQ9EWLKyqcnlRLIgTMRs1a7mNpv(QxcTOWaEcqLile)iyBV8HaTVxvYEZ1OD8dqBnLmsxcTSpdTNBHF0JKA0wjVQ4maArHQ6GXfovGFziGvhK)EWLKyqcBuHGalJgjNtnqf)JML1srJMNBjgqdhWiqIucwAFGR3pTNBYAydNtnqLLcxUDfEsw6alC5ORWtYstpcJ0OffgWtaQezH4hbB7LpeO99Qs2BUgTJFaAkodGwC0EUjRb0wtjJ0Lq7P9CtwdyJkerWYOrY5uduX)OzzTu0OvbkYV3ojQKHM)OFJZaBnW4YLcKuc0Icd4javISq8JGT9Yhc0(Evj7nxJ2XpanfNbqZevYOoi)PoyCgNbuhmmIWrBnLmsxcTKOsgA(J(nodGnQq8blJgjNtnqf)JML1srJwybq7dC9(P9CtwdB4CQbQSZUNBjgqdhWiqkusJeolfUC7k8KS0bw4YrxHNKLMEegPrlkmGNaujYcXpc22lFiq77vLS3CnAh)a0uCganJtEuhmGgWJbQdggr4OTMsgPlHwItEOZd4XaSrfcwpwgnsoNAGk(hnlRLIgT2h469dgAqtUOf(THZPgOIwuyapbOsKfIFeSTx(qG23RkzV5A0o(bOP4maAXbg1bjrtUOf(H2AkzKUeApyObn5Iw4h2Ocriyz0i5CQbQ4F0SSwkA0I5AXPgytob0jrLm08h9BCgGLWYC(u5REB5EG(8Ho1AzfWohVRvbj6N2ZTWpFcLuInRec7S75wIb0WbmcKcL0iHRMvfTOWaEcqLile)iyBV8HaTVxvYEZ1OD8dqtXza0(EpqF(OoO1AzfaARPKr6sOj3d0Np0PwlRaWgvi(HLrJKZPgOI)rtXza0S4bxRoyyeHJwuyapbOsKfIFeSTx(qG23RkzV5A0o(bOTMsgPlHwkEW1OzzTu0OfaXCT4udSx1Lwov0pUMUqlCT0LODkzKwGe2OcbByz0i5CQbQ4F0uCgandIbA0SSwkA0cGyUwCQb2R6slNk6hxtxOfUw6s0oLmslqcT1uYiDj0sqmqJ23RkzV5A0o(bOffgWtaQqGwuiXjRZqclJn2yJML1srJg2ic]] )

    storeDefault( [[Red Vengeance: defensives]], 'actionLists', 20180301.194236, [[dSt5iaGEIsPnPsTlkTnPs7tfXSr18ffXnjkj3MuTorLQDsH9ISBj7hLQrjksdJugNkspwkhwyWOedhfhuf1PefvhdQoNOOSqrvlvL0IHy5k9qrLYtPAzIspxKjsuIPQsmzsMUIlIs68evxgCDPQnkQKTsuk2mr2UOItRQFtyAeLQ5jv8xk6BQGrdPNPcDsOOVdfUgrX9GsFgLYXjkPETOWeoDHCJqhi)kOyNfzduSbr1GCNDwuGeuPphirUSasrpFO8KFf4qKaYiRg(PAh1WT4zw2U4NsUZaTp4VSnMxuKHmNIt(528IkrxidC6c5SwbchuuEYncDGCx0ZzNLCl2CGL8RahIeqgz1W7IFWQDeNCml13IrSKxIci)mYZ)ro5jrp3SfBoWsU32NzihK19pddOSbxTrd9nXiweEOG0nke8b1YaBdQPd2dYCJ0ljztIEUP0gSPd1KSPjAzGv7wbi9sswPhw5MiBuk7c6XxjSA0qgzPlKZAfiCqr5j3i0bYLfqxuSZIZ8zajYVcCisazKvdVl(bR2rCYXSuFlgXsEjkG8Zip)h5KRaDrzMy(mGe5EBFMH8gASSbjtPnAZlQGFcwC7bzUr6LKSkqxuMjMpdizxqp(kHv7wbi9sswPhw5MiBuk7c6XxjSA3mXx2w)UqnNGnR2nke8b1YaBdQPd2tLHgY4iDHCwRaHdkkp5gHoqEUEyLZol53OuKFf4qKaYiRgEx8dwTJ4KJzP(wmIL8sua5NrE(pYjx6HvUjYgLICVTpZqoke8b1YaBdQPd2tL5gPxsYQaDrzMy(mGKvjWOUr6LKS6We6ILbvK(KvjWOUr6LKSjrp3ej29H1Qeyu3nHGReyuwfOlkZeZNbKSn0yzdsDWPHmKD6c5SwbchuuEY92(md5OqWhuldSnOMoyLrM7j4qnwjGBQGCI0eZlklubchu3mXx2w)UqnNG9Og5xboejGmYQH3f)Gv7io5ywQVfJyjVefqUrOdKNlGZolYcKtKMyErr(zKN)JCYLaUPcYjstmVOOHmKHUqoRvGWbfLNCJqhixwbtOlwgur6tKFf4qKaYiRgEx8dwTJ4KJzP(wmIL8sua5NrE(pYjxhMqxSmOI0Ni3B7ZmKJcbFqTmW2GA6GTT)8TGBoOlKqfCvMKjzkke8b1YaBdQPdwzx7Mj(Y263fQPd2SA3nHGReyuwPhw5MiBuk7c6XxPt0UvasVKKv6HvUjYgLYQeyu3i9sswfOlkZeZNbKSkbg1Dti4kbgLvb6IYmX8zajBdnw2GKP0gT5fvW7OzLjZPHm6sxiN1kq4GIYtU32Nzihfc(GAzGTb10bRkk2G1CqxiHk4kYVcCisazKvdVl(bR2rCYXSuFlgXsEjkGCJqhi3f9C2zjFS7dl5NrE(pYjpj65MiXUpS0qghOlKZAfiCqr5j3B7ZmKJcbFqTmW2GA6GvffBWAoOlKqfC1nt8LT1VluZjy7Qr(vGdrciJSA4DXpy1oItoML6BXiwYlrbKBe6a5UONZol5ghICaYpJ88FKtEs0ZnBCiYbOHmoLUqoRvGWbfLNCVTpZqoke8b1YaBdQPdwvuSbR5GUqcvWv3i9sswfOlkZeZNbKSkbg1nsVKKvhMqxSmOI0NSkbg1nsVKKnj65MiXUpSwLaJI8RahIeqgz1W7IFWQDeNCml13IrSKxIci3i0bYZ1dRC2zj)gLIDwYu8mN8Zip)h5Kl9Wk3ezJsrdzKz0fYzTceoOO8KBe6a5yQRl4X8IIDwo3Vb5xboejGmYQH3f)Gv7io5ywQVfJyjVefq(zKN)JCYFDDbpMxuMr)gK7T9zgYrHGpOwgyBqnDWQIInynh0fsOcU6Mj(YQaPV9ZjyXLHgYaxJUqoRvGWbfLNCJqhipxahHhkG8RahIeqgz1W7IFWQDeNCml13IrSKxIci)mYZ)ro5sahHhkGCVTpZqoke8b1YaBdQPdwvuSbR5GUqcvWv3tWHASsahHhkWcvGWb1nt8LvbsF7NtWYeFzQaPV9Jj)1)HgYahNUqoRvGWbfLNCJqhi3rHyj)kWHibKrwn8U4hSAhXjhZs9Tyel5LOaYpJ88FKtEcfILCVTpZqoke8b1YaBdQPdwvuSbR5GUqcvWv0qd5EBFMHCAica]] )

    storeDefault( [[Red Vengeance: offensives]], 'actionLists', 20180301.194236, [[dOd9daGEuvQnHQSlj2gKyFKQMnjZNcUjkk(gPu7us2lYUvSFLOrbPAyu0VLQ1jPspgObRKmCq6GqkNcf5yG6COQWcLuwQsQfdXYH6HOQONkAzOWZP0ejfAQkHjlLPlCrsjhM4YQUofAJKc2kkQAZa2Us58G40unnjv8Duv5zKkFgvvnAuuzCsQ6KKI(lkDnuu6EkvVgs6qOQKBJktW0ckReUt563wUI5)W)ld4R7YvDaGpwF7wk14beJQGQr56RUypvXWeUEtDMWfy(GbkW1tzc9GUOC(wcVpufZwpmLObgEFS0cQcMwqPwJGOEJQrzLWDk1GFmKLRQHLPr56RUypvXWegfyTlM6GPuZP5Gs0Xuo95uIgIR8acLa(XqyrWY0OmbXo0Gs0fC4acyua8JHW2oNBFbldQ63H5fI6tuaUIT9nXgs49P8rquVXdS3vTo)McWvSTVj2qcVpf85eFS7M8Gk(uanIXFc976mzYGb05RquFIcWvSTVj2qcVpLpcI6ndgeC4acyua8JHW2oNBFbldQ7MmrbvXGwqPwJGOEJQrzLWDk1WvlxPXVj2qcVpuU(Ql2tvmmHrbw7IPoyk1CAoOeDmLtFoLOH4kpGqjWvSTVj2qcVpuMGyhAqziQprb4k223eBiH3NYhbr9gpOIpfqJy8Nq)UotEOJUGdhqaJcGFme225C7lyzqv)ompbm8TZ(5C(T7W8AhXiaqbWpgclcwMwbFoXhR(DgmzWa6coCabmka(XqyBNZTVGLb1DtdgeWW3o7NZ53QFNbtmrbvPJwqPwJGOEJQrzcIDObLHO(efluh7blsNdP8rquVXtadF7SFoNFR(Dg8qmcauSDJkwaSWFUpHTydbev971HYkH7uMqDShlxvRZHq56RUypvXWegfyTlM6GPuZP5Gs0Xuo95uIgIR8acLwOo2dwKohcLjZ15hZ0BoGFSLqOGQQdTGsTgbr9gvJYee7qdkPC9vxSNQyycJcS2ftDWuQ50Cqj6ykN(CkReUtz2nQwUIpf82XuIgIR8acL2UrflOG3oMckOmbXo0Gskic]] )


    storeDefault( [[Havoc Primary]], 'displays', 20171128.104625, [[dWJYgaGELWlrQyxkrXRLkmtPIMTchwYnrQ0Vv1TvKNrkv7Kk7vSBc7NQ4NkLHPKgNsKSmOWqrXGPknCKCqPQttYXiY5qQYcLILskzXe1YP0dLk9uWJryDkr1evIyQq1KrvnDvUOI6Qiv1LHCDeTrsXwvIuBgv2Us1hLs5ZqPPjLQVtvnsuL(MuIrJsJhk6KiLBrkLRjL05jvpNI1QeLooQIJuWdquuN6fAEXbN(afyJ(4DsZnh4klw0XSZe5a2sGf1Lfr0rAcWdjIe1puyftiXfGiG(ghNbDDlQt9ctCRbWCJJZGUUf1PEHjU1auw1uz1Pr8cqTafx7RbMuI(540EaEirKi(DlQt9ctAcOVXXzqhEzXIotCRbmSVp4Roc2(50eWW((9K3NMakIxaufHsGnUwdCLfl66feSVnqZgo(gD1IwB8IhaZnood6OtJjoPayg3Aad77JxwSOZKMaDi3liyFBa8ngTO1gV4buc(kI6EBVGG9Tb0IwB8IhGOOo1l6feSVnqZgo(gDdauicvnulQt9I4ATLwcyyFFapnb4HerIwIYIio1lcOfT24fpGGCIgXlmX1EadfAm0mkdB3F82GhOItkGCCsbWgNuaBCs5cyyF)Uf1PEHjYbWCJJZGUEsBf3AGI0w46uOaYKCCbMkm7jVpU1aYd1IfTnE)(XiYbQbfBbSVpZ(CCsbQbfB19NKRJzFooPalbXvKJlnbQHFPBy2zstGDLrjRgQthxNcfqoarrDQx0puyfb6o7WN1kaFLHAu646uOavaBjWIW1Pqbkz1qD6bksBrxLaLMaDiR5fhOwGItcJa1GITWllw0XSZeNualAeO7SdFwRagk0yOzug2ihOguSfEzXIoM954KcWdjIeXNMGVIOU3AstaxnHcWBT)eE8YyvtLvpWvwSOtZlo40hOaB0hVtAU5a8rCf546z6maOM66XlV1(tSCpE5J4kYXfOdznV4GtFGcSrF8oP5MdOVXXzqhDAmXPnPa1GIT6h(LUHzNjoPa6rJ2wk61cgRsT2Ue9AfdTV2YA40w7TgGYQMkRUMxCGAbkojmcqzre)KCD9mDgautD94L3A)jwUhVuweXpjxxGAqXwa77ZSZeNuGPcZ(54wdyyFFWxDeS9K3NMaxzXIoM95ihql0avguCySk1IKKe9wM12LON2BjGH99z2zstad77thKUSsWxjWAstaIFsUoM95ihGOOo1l08IdulqXjHrGAqXw9d)s3WSphNuGoK18IladUhVqjmE86kR99dyyFFAc(kI6ERjnb0344mORN0wXTgOg(LUHzFonbmSVF)CAcyyFFM950eG4NKRJzNjYbksB1liyFBGMnC8n625Sg8a1GIT6(tY1XSZeNuaEiveDS0kdC6duGkWKsa4XTg4klw0P5fhOwGItcJafPTOj4ECDkuazsoUaef1PEHMxCbyW94fkHXJxxzTVFGI0wafAmOTK4wdmlk5bIFAcyutudu)2CCyeWW((9K2IMG7JCam344mOdVSyrNjU1axzXIonV4cWG7XlucJhVUYAF)a6BCCg0rtWxru3BnXTgaZnood6Oj4RiQ7TM4wdipulw0249JCaEirKi(0iEbOwGIR91atfMaECsbueVyz)FkoPwdWdjIeXxZloqTafNegb4EXfGb3JxOegpEDL1((b4HerI4tNgtAcmPe9K3h3AGI0w0xOUauJshzZLa]] )

    storeDefault( [[Havoc AOE]], 'displays', 20171128.104625, [[dSJXgaGEQQEjsHDPOs9AQiZKQIzRWnrk6Ws(gsPUnKANuAVIDty)ePFkvnmi63Q6ziumuu1GjIHJKdsL(mcogfDoekTqfzPuqlgflxkpur5PGhdvRdHkturvtfktMcnDLUOu5QuaxwLRJOnsf2kfOnJkBhcFKQsNMutdPKVtvgjvuldPQrJsJhHCsi5wiu11uuX5jQNtYAvujhhPYXmybWlQv)chVyHvECb6naMpOSDb2Qr4wEe8HjqReeUzShUtzkaZq73VVJ3lmbK754u3oROw9luXImar9CCQBNvuR(fQyrgGoYJ8mIc)fG2)flTqgaTw42flXeGoYJ8moROw9luzkGCphN6wSQr4wvSidOyFpWtV4SUDHjGI99Cj3pmbqxebyXAgyRgHBDf4SFlWupgwpnneLVoJfqowINEtKbK754u3sJjvSeVzaf77Hvnc3QYuaNyCf4SFlawpVHO81zSaAHrnETFZvGZ(TagIYxNXcGxuR(fUcC2VfyQhdRNMbM9uYsLG9bCUq84sL423fqX(EawMcqh5rEZRBh(QFradr5RZybeKOrH)cvS0kGI6gdhJsXo7hFlybQynd0I1maHyndWeRz2ak23BwrT6xOctaI654u36s2QyrgOiBfMm1fGHKJla6IixY9JfzaMH2VFFhVN7yeMa1GITa23JhrxSMbQbfBn7rZulpIUyndm)XvKJntbQHxjR4rWNPai0knJEOxzmzQlata8IA1VWDOjicmRZI1zyaJAf1OKXKPUa4bALGWHjtDbkg9qVYbkYwrtT4YuaNyC8If0(VynPpqnOylSQr4wEe8XAgODJaZ6SyDggqrDJHJrPydtGAqXwyvJWT8i6I1maDKh5zeLWOgV2VPYuaG6W11q7Vw9lIDo0M2bqRfUK7hlYaB1iCRJxSWkpUa9gaZhu2UagpUICSU8(eafUSujg80cfXjvY8hxro2aCVydWJjvcucLuj2Q1EVae1ZXPULgtQyndudk2YD4vYkEe8XAgqJ)I56F0XAoNaunn6Qj74flO9FXAsFaQ2H)OzQ1L3NaOWLLkXGNwOioPsM)4kYXgqJ)cGQW1ccXoNaOlIC7IfzaQMgD1KrH)cq7)ILwidSvJWT8i6cta6ipYZDOjiqFInaEaf77XJGptbiQNJtDlkHrnETFtflYaY9CCQBrjmQXR9BQyrgyRgHBD8InapMujqjusLyRw79cquphN6wSQr4wvSidOyFpxYwHsW9HjGI99qjmQXR9BQmfqUNJtDRlzRIfzGA4vYkEeDzkGI994r0LPak23ZTlmbWF0m1YJGpmbkYwbu3yGA(yrgOiBLRaN9BbM6XW6PPpDoWcuKTcLG7XKPUamKCCbqRfawSidSvJWToEXcA)xSM0hGosnUtguRGvECbycGxuR(foEXgGhtQeOekPsSvR9EbQbfBn7rZulpc(ynd0jkMXzmtbuA0uJZTVlw6d4eJJxSb4XKkbkHsQeB1AVxGAqXwUdVswXJOlwZa4f1QFHJxSG2)fRj9bWF0m1YJOlmbuSVhnozgTWOwqqLPagEJRuxS0J0K2MMMe7CJKwMelXq7ak23d80loRl5(zkarXImqnOylG994rWhRza6ipYZOJxSG2)fRj9bCIXXlwyLhxGEdG5dkBxa6ipYZinMuzkGTqFbCUq84sL423fOiBLbe6na1OKVw2ea]] )

    storeDefault( [[Vengeance Primary]], 'displays', 20171128.104625, [[d0JWgaGEPIxIuPDjvQABsLkZKQQoSKzRWXrL6Miv5zqP03GsvpNu7Ks7vSBu2pvLFQOggu8BiNMKHIQgmfA4i6GsPLHk5ye15qQOfkflvvQftKLtLhQk5PGhdvRdkvMOuPmvv1KrW0v5IsvxfvKlR01rYgPGTIk0Mj02rkFuQKpRitdPQ(ovzKOIACqPOrtW4HsojcDlKkCnubNNIEnvvwlukCBvXro)a4f5Pqmdi2bN5ydmZPV)eT9bUYnThpn(ifWvSP9LWI7xAcWn1sTTd1e7zzxa8aMZII69EvKNcX0XIjawZII69EvKNcX0XIjaPt9uotI4igO6SXsFmbEuS2(yX2aCtTulHxf5PqmDAcyolkQ37xUP90XIjGwa5bEQdxOTpnb0ciVwQdLMakCedilCfBkwoe4k30ETmCbKlqZ8)ptV3e7IZ)aynlkQ3JUn6yLdGvSycOfqE)YnTNonb8tQLHlGCb(Z8Vj2fN)bumck86qUwgUaYf4nXU48paErEkeRLHlGCbAM))z6faixCvnuDQtHyXYbSPCaTaYd(Pja3ul12nLBXpfIf4nXU48paJ6HioIPJL(b0K7yyyuAHxObYLFGkw5asXkhykw5aUyLZfqlG8EvKNcX0rkawZII69APCvSycuuU6BsUbKOefd8uy1sDOyXeqAO60PRbYRDmIuGAqkuGaYJNwFSYbQbPq9c9ivhpT(yLd0TvSOgxAcudVYuZtJpnbOP0kj1qDMFtYnGua8I8uiw7qnXc8Q3(7FhGGstokZVj5gOc4k20(nj3aLKAOoZafLRONITPjGFsgqSduD2yL5kqnifQF5M2JNgFSYbC7iWRE7V)Dan5ogggLwisbQbPq9l30E806Jvoa3ul1sGiJGcVoKtNMa26zdWXLnTfdF9zK3PEkNzGRCt7zaXo4mhBGzo99NOTpaHvSOgxlV)bEVe8zKJlBAlg(ID(msyflQXfWpjdi2bN5ydmZPV)eT9bmNff17r3gDS0HCGAqkuTdVYuZtJpw5aMXshCXHUlaPt9uotdi2bQoBSYCfG0T4OhP6A59pW7LGpJCCztBXWxSZNrs3IJEKQlqnifkqa5XtJpw5apfwT9XIjGwa5bEQdxOL6qPjWvUP94P1hPaV3Xw6nwUWiJ9YYY0z3JH(Y0j2I9b0cipEA8PjGwa5r31usXiOyt60eah9ivhpT(ifaVipfIzaXoq1zJvMRa1GuOAhELPMNwFSYb8tYaIDb4)(mcft7ZOTCoKxaTaYJiJGcVoKtNMaMZII69APCvSycudVYuZtRpnb0ciV2(0eqlG84P1NMa4OhP64PXhPafLRAz4cixGM5)FME(3B4hOgKc1l0JuD804Jvoa3ukC)4OsdN5ydubEum4hlMax5M2ZaIDGQZgRmxbkkxrKjI(MKBajkrXa4f5Pqmdi2fG)7ZiumTpJ2Y5qEbkkxbK7yqSBXIjqpRKglH0eqREihB7CFSCfqlG8APCfrMiksbWAwuuV3VCt7PJftGRCt7zaXUa8FFgHIP9z0wohYlG5SOOEpImck86qoDSycG1SOOEpImck86qoDSycinuD601a5fPaCtTulbI4igO6SXsFmbEkSGFSYbu4ig2aHEIvMdb4MAPwcgqSduD2yL5kGiIDb4)(mcft7ZOTCoKxaUPwQLaDB0PjWJI1sDOyXeOOCfNyQla5OmxxUea]] )




end
