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
            usable = function () return target.debuff.casting.up end,
        } )

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
            gcdType = 'spell'
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
            gcdType = "spell",
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
            gcdType = 'off',
            velocity = 30,
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
            known = function() return spec.vengeance and buff.metamorphosis.down end,
            gcdType = 'melee',
            bind = 'sever',
            texture = 1344648
        } )


        addAbility( 'sever', {
            id = 235964,
            spend = -10,
            spend_type = 'pain',
            cast = 0,
            cooldown = 0,
            known = function() return spec.vengeance and buff.metamorphosis.up end,
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


    storeDefault( [[SimC Havoc: default]], 'actionLists', 20180113.132154, [[dme2paqivGfPcXMKIAueItriTkbuELaQmlOIClOIQDPkdtuDmPWYGQ8mcvnnPiUMkK2gHkFtqACQGQZjGQwNkiZta5Eek7tqCqvuleQWdjiteQO0fHkzKsr6KqLAMQGYnfODkLwQkYtvmvvfBvaElbv3LGYEj9xvAWICyQwmuEmktMsxgSzk8zkQrtronKxRc1Sr62s1Uv63sgUQslNONJQPJ46ey7QQ(UG68qvTEOII5lk7xO1g6hDMVad5ueoJtq1QThn0q1bNfmCbuIIdDobuW5G2IxEJdpVr(H)WdVMCu80P17GodQlum1u)VyhkMSGHlGs05mJGQLRF02g6hDW16yuWQ4qNHjrFj6CqmjsmDqmrCkSK3cDGJ4pyDmkyJPSSyIvf1wH33cDGJ4pj4w8JPSSyIvf1wH33cDGJ4pj0D0YJPqIjIlndKhb1HlPUweetzzXeRkQTcVVf6ahXFsO7OLhtHetIlpMevNZyikIGVo)Ue5yuqhHmbSJdw)qhwIIPtWYgGlB9oOtyhrqR5RrjVl0boIRtR3bDYygg55mMHHWhsjHykaNkaewMuNZsZCDwVdIf2re0A(AuY7cDGJ440VtfaIDGihqCkSK3cDGJ4pyDmkyZYyvrTv49Tqh4i(tcUf)SmwvuBfEFl0boI)Kq3rlpeIlndKhb1HlPUweKLXQIARW7BHoWr8Ne6oA5HiUCr15eqbNdAlE5ncTrUoNaEjqYaU(rj6G71IyoPK6S1c6eSSTEh0rjAlE6hDW16yuWQ4qNHjrFj6CqmjsmDqmrCkSKhZKx8lg1Ta)bRJrbBmLLftSQO2k8(yM8IFXOUf4pj4w8JPSSyIvf1wH3hZKx8lg1Ta)jHUJwEmfsmrCPzG8iOoCj11IGykllMyvrTv49Xm5f)IrDlWFsO7OLhtHetIlpMevNZyikIGVo)Ue5yuqhHmbSJdw)qhwIIPtWYgGlB9oOtyhrqR5RrjVmtEXVyu3cCDA9oOtgZWipNXmme(qkjetb4ubGWYKXKinevNZsZCDwVdIf2re0A(AuYlZKx8lg1TahN(DQaqSde5aItHL8yM8IFXOUf4pyDmkyZYyvrTv49Xm5f)IrDlWFsWT4NLXQIARW7JzYl(fJ6wG)Kq3rlpeIlndKhb1HlPUweKLXQIARW7JzYl(fJ6wG)Kq3rlpeXLlQoNak4CqBXlVrOnY15eWlbsgW1pkrhCVweZjLuNTwqNGLT17GokrBfV(rhCTogfSko0zys0xIoheteNcl5zHETi2dwhJc2yQ5yIvf1wH3xhiEVKFnvCe)jHUJwEmfOysCXuZXKHaj(plyGyismfsmj(8yQ5ysKy6Gy63LihJcVWoIGwZxJsExOdCepMYYIjwvuBfEFl0boI)Kq3rlpMcum1ipMenMAoMejMoiM(DjYXOWlSJiO181OKxMjV4xmQBbEmLLftSQO2k8(yM8IFXOUf4pj0D0YJPaftIlMevNZyikIGVo)Ue5yuqhHmbSJdw)qhwIIPtWYgGlB9oOZ3QOO181OK3oqCDA9oOtgZWipNXmme(qkjetb4ubGWYKXKi4jQoNLM56SEhe7Bvu0A(AuYBhioo97ubGyhqCkSKNf61IypyDmkyBMvf1wH3xhiEVKFnvCe)jHUJwEGexZgcK4)SGbIHiHi(8Mf5GFxICmk8c7icAnFnk5DHoWr8SmwvuBfEFl0boI)Kq3rlpqnYfTzro43LihJcVWoIGwZxJsEzM8IFXOUf4zzSQO2k8(yM8IFXOUf4pj0D0YdK4evNtafCoOT4L3i0g56Cc4Lajd46hLOdUxlI5KsQZwlOtWY26DqhLOTnr)OdUwhJcwfh6mmj6lrhItHL8mqso5IrRY(G1XOGnMYYIjoqUy1kG)iiqIx(TjFzXuiXuEmLLftoJG(HlSqhb8ykeXIjXhtbUysKyI4uyjpMjV4xgf8F4HUW6yuWgtbwmj(ysuDoJHOic(687sKJrbDeYeWooy9dDyjkMoblBaUS17Goyu3cxRVmqNwVd6KXmmYZzmddHpKscXuaovaiSmzmjI4fvNZsZCDwVdIHrDlCT(YaC63PcaXiofwYZaj5KlgTk7dwhJc2SmoqUy1kG)iiqIx(TjFzzzoJG(HlSqhb8qet8boriofwYJzYl(Lrb)hEW6yuWgyIxuDobuW5G2IxEJqBKRZjGxcKmGRFuIo4ETiMtkPoBTGoblBR3bDuI2Eu9Jo4ADmkyvCOZWKOVeD(DjYXOWdJ6w4A9LbXuZXKiXKHaj(pMaPewsmfOyk0Jgt48yI4uyjpdKKtUy0QSp0fwhJc2ykWIj8YJjr15mgIIi4RZVlrogf0rita74G1p0HLOy6eSSb4YwVd68TkkAnFnk5fJ6w4A9Lb606DqNmMHrEoJzyi8HusiMcWPcaHLjJjrAIO6CwAMRZ6DqSVvrrR5RrjVyu3cxRVmaN(DQaqSFxICmk8WOUfUwFzqZIyiqIFGc9O4CItHL8mqso5IrRY(G1XOGnWWlxuDobuW5G2IxEJqBKRZjGxcKmGRFuIo4ETiMtkPoBTGoblBR3bDuI2ko9Jo4ADmkyvCOZWKOVeDiofwYJzYl(Lrb)hEW6yuWgtnhtgcK4)SGbIHiXuiXutYJPMJjoqiO1m)9Tk61OKxMjV4xgf8FqNZyikIGVo)Ue5yuqhHmbSJdw)qhwIIPtWYgGlB9oOZ3QOO181OKxMjV4xorIog0P17GozmdJ8CgZWq4dPKqmfGtfacltgtICur15S0mxN17GyFRIIwZxJsEzM8IF5ej6yaN(DQaqmItHL8yM8IFzuW)HhSogfSnBiqI)ZcgigIestYBMdecAnZFFRIEnk5LzYl(Lrb)h05eqbNdAlE5ncTrUoNaEjqYaU(rj6G71IyoPK6S1c6eSSTEh0rjABO6hDW16yuWQ4qNZyikIGVoSA5c6WT7MrmDW9ArmNusD2AbDcw2aCzR3bD0P17GocvlxqhIPGUzetNtafCoOT4L3i0g56Cc4Lajd46hLOJqMa2XbRFOdlrX0jyzB9oOJs02dx)OdUwhJcwfh6mmj6lrhwvuBfEFMPfMtVSQO2k8(Kq3rlpMelMY15mgIIi4RdZP0RZiOAVueNOJqMa2XbRFOdlrX0jyzdWLTEh0rNwVd6KXmmYZzmddHlKtPX0zgbvBmDyioryzsDolnZ1z9oi2rguxOyQP(FXoumXQIARW7r05eqbNdAlE5ncTrUoNaEjqYaU(rj6G71IyoPK6S1c6eSSTEh0zqDHIPM6)f7qXeRkQTcVkrBd86hDW16yuWQ4qNHjrFj6qCkSKNf61IypyDmky15mgIIi4RJuWEDgbv7LI4eDeYeWooy9dDyjkMoblBaUS17Go606DqNmMHrEoJzyi8tc2y6mJGQnMomeNiSmPoNLM56SEhe7idQlum1u)VyhkMSqVwe7i6CcOGZbTfV8gH2ixNtaVeizax)OeDW9ArmNusD2AbDcw2wVd6mOUqXut9)IDOyYc9ArmLOTnY1p6GR1XOGvXHoNXquebFDKc2RZiOAVueNOdUxlI5KsQZwlOtWYgGlB9oOJoTEh0jJzyKNZyggc)KGnMoZiOAJPddXjcltgtI0quDolnZ1z9oi2rguxOyQP(FXoumTLS70JOZjGcoh0w8YBeAJCDob8sGKbC9Js0rita74G1p0HLOy6eSSTEh0zqDHIPM6)f7qX0wYUtvIs0zys0xIokrva]] )

    storeDefault( [[SimC Havoc: precombat]], 'actionLists', 20180113.132154, [[dCJgcaGEsrTjKi7cOEnPK9rKy2QY8fKBkQUlPiFtiTtvAVu7gX(vXOeGHHuJtanuIKgSQA4c1bbWPiL6ye1cbKLselgulxIhcqpf1YeLNlPjIe1ubYKbz6sDrbYLHUUqSvbQnJK2os43konHPrQQhtYijf8wsHgTG6WkDssf3wKRrQY5jvADeP6qeP8xa1w2GmZXOsSpHM3wmeF1lAuZugPUrETbYSe8HBf9nJwoqAz6abNLPVEzMVBcnZIeGNVgwkgL0p)4cQMe82Mbq1IHuniFLniZbrw4hczGmdaS4jADnhpTyiM1HajuBpfZKHGMZhOG3YDtOzZ3nHMdPOsLMwPOsvJsDAXq0uOIzj4d3k6BgTCuzAZsW6ePOWQb52mGHrLw5dfycjTHnNpq3nHMD7BMbzoiYc)qidKzwveXTzPD(bC(9(qsdgctdb4ccpfcyKSWpe68P05hW537djnyimneHcmsw4hcD(HcD(vSbgEirQGBbwYKbw)y15lLZN(81(812maWINO11Cc7nnL4WtvunRdbsO2EkMjdbnNpqbVL7MqZMVBcnNJ9MMsC4PkQMLGpCROVz0YrLPnlbRtKIcRgKBZaggvALpuGjK0g2C(aD3eA2TBZSQiIBZUTba]] )

    storeDefault( [[SimC Havoc: normal]], 'actionLists', 20180113.132154, [[dauwxaqikkBsvLpbIqgfiCkvvTkjI6vGOQDHOHHsDmvPLjHEMejtJOqxdePTbIO(grPXruW5arK1bIGMhik3tIW(ik6GuqlKOYdPiMiiQCrksBuIuFuIiJeebojfv3eK2jrwkf6Punvs0wLa7f6VQkdwLdlAXs6XGAYu6YkBwv8zkWOrHtl41evnBc3Mu7gPFJQHJswUqphHPdCDsA7KW3LGoVe16brOMpkA)sn(IkrhYTNuvaq5q3zn4qkcqItqGtrjivwzr34eljgkvK9RmW(LTmqwSOmcPfr3HJbwa0r3qyqGtjqLO0lQeDtPzvmlkh6oCmWcGoe9bsXOaswXXkJZsoAwfZ2htM9bsXOasnxpkqvtoAwfZ23)((1xv95HKvCSY4SKwEH0((1xv95HuZ1Jcu1KwEHu0nSgebqz0vmQb7rv8fhiUeGU5uBaob8i6uoDOdLBliJsPEOJUuQh6fmQb7rv0NXbIlbOBCILedLkY(v2x2OBCeC1i8iqLiaDtymy5HYvm9OaSIouUvk1dDeGsfrLOBknRIzr5q3HJbwa0HOpqkgfqQ56rbQAYrZQy2(yYSpqkgfq(mXNojalwMC0SkMTV)99Rpi6ZS(aPyuaPMRhfOQjhnRIz7JjZ(GOpygz0Gr0xj6RyFmz2hmNlS8cPKkg1G9Ok(IdexciJtNbkrFYSpzSV)99RVQ6ZdPMRhfOQjT8cP99VVF9brFM1hifJciFM4tNeGfltoAwfZ2htM99OgltA3taoa6tMLOVIqAF)77xFq0hmJmAWi6Re9vSV)OBynicGYO)mXxuLGb6MtTb4eWJOt50HouUTGmkL6Ho6sPEOx6j6ZOkbd0noXsIHsfz)k7lB0nocUAeEeOseGUjmgS8q5kMEuawrhk3kL6HocqPsHkr3uAwfZIYHUdhdSaOdrFv1NhsnxpkqvtQYQpMm7ZS(aPyuaPMRhfOQjhnRIz77FF)6dI(syqqX(gD6Wi6tM9923F0nSgebqz0FM4RMXyAWq3CQnaNaEeDkNo0HYTfKrPup0rxk1d9sprFYLXyAWq34eljgkvK9RSVSr34i4Qr4rGkra6MWyWYdLRy6rbyfDOCRuQh6iaLKruj6MsZQywuo0D4yGfaDqkgfqwfCUvma5OzvmBF)6dI(mRpqkgfqQ56rbQAYrZQy2(yYSVQ6ZdPMRhfOQjvz13)((1hmJmAWi6Re9veDdRbraugDaJiVWpdezqXq3CQnaNaEeDkNo0HYTfKrPup0rxk1dDLmI8c7RKezqXq34eljgkvK9RSVSr34i4Qr4rGkra6MWyWYdLRy6rbyfDOCRuQh6iaLGuuj6MsZQywuo0D4yGfa9h1yzsy1yCuqFqwFVqAF)6dI(G5CHLxiL0UeW4JOWnwKXPZaLOpiRVI9vY9zaSTpMm7dMZfwEHuYQiT7ZMu4rgNoduI(GS(k2xj3NbW2((JUH1GiakJ(ZevrAh6MtTb4eWJOt50HouUTGmkL6Ho6sPEOx6jQI0o0noXsIHsfz)k7lB0nocUAeEeOseGUjmgS8q5kMEuawrhk3kL6Hocqjizuj6MsZQywuo0D4yGfaDfzmKvXiRI0UpBsHh6gwdIaOm62LagFefUXcDZP2aCc4r0PC6qhk3wqgLs9qhDPup0HClbm6ZlCJf6gNyjXqPISFL9Ln6ghbxncpcujcq3egdwEOCftpkaROdLBLs9qhbOKSOs0nLMvXSOCO7WXala6WmYObJOVs0xX((1Nz9bsXOasnxpkqvtoAwfZ23V(mRpqkgfq(mXNojalwMC0SkMTVF9zwFv1Nhs9aPMhzXGteiivz13V(aPyuaPDAo9Rks7iihnRIzr3WAqeaLr)zIVOkbd0nNAdWjGhrNYPdDOCBbzuk1dD0Ls9qV0t0Nrvcg9bX7F0noXsIHsfz)k7lB0nocUAeEeOseGUjmgS8q5kMEuawrhk3kL6HocqjzavIUP0SkMfLdDdRbraug9Nj(wuLfiWPOBo1gGtapIoLth6q52cYOuQh6OlL6HEPNOptJQSabofDJtSKyOur2VY(YgDJJGRgHhbQebOBcJblpuUIPhfGv0HYTsPEOJaucscvIUP0SkMfLdDhogybqhI(syqqX(gD6Wi6tM9923)((1he9brFM1hifJci1C9Oavn5OzvmBFmz2xv95HuZ1Jcu1KQS67FF)6dI(mRpqkgfqcZi5eFvrAhb5OzvmBFmz2xv95HeMrYj(QI0ocsvw9XKzFWCUWYlKscZi5eFvrAhbzC6mqj6tM9vk29XKzFGmAWaKGGEFa(NnS(GS(G5CHLxiLeMrYj(QI0ocY40zGs03)((JUH1GiakJ(JAS8h)5dWyFbHiyZyaDZP2aCc4r0PC6qhk3wqgLs9qhDPup0lTASCF8N(amwFMlebBgdOBCILedLkY(v2x2OBCeC1i8iqLiaDtymy5HYvm9OaSIouUvk1dDeGsVSrLOBknRIzr5q3HJbwa0vKXqwfJSks7(SjfEOBynicGYOxfPDF2Kcp0nNAdWjGhrNYPdDOCBbzuk1dD0Ls9qxorAxFqUKcp0noXsIHsfz)k7lB0nocUAeEeOseGUjmgS8q5kMEuawrhk3kL6HocqP3xuj6MsZQywuo0D4yGfaDqkgfqwfCUvma5OzvmBF)6lHbbf7B0PdJOpzwI(k23V(GOpZ6dKIrbK6KaS4h)5dWyFgiYGIroAwfZ2htM9zwFGumkGuZ1Jcu1KJMvXS9XKzFv1NhsnxpkqvtQYQV)99Rpi6lHbbf7B0PdJOpzwI(kvF)r3WAqeaLrhWiYl8Zargum0nNAdWjGhrNYPdDOCBbzuk1dD0Ls9qxjJiVW(kjrguS(G49p6gNyjXqPISFL9Ln6ghbxncpcujcq3egdwEOCftpkaROdLBLs9qhbO0Bruj6MsZQywuo0D4yGfa9h1yzs7EcWbqFYSe9vk29b57dI(QQppKSIJvgNLuLvF)67TpMm7JDF)7RK7tgq3WAqeaLr)zIQiTdDZP2aCc4r0PC6qhk3wqgLs9qhDPup0l9evrAxFq8(hDJtSKyOur2VY(YgDJJGRgHhbQebOBcJblpuUIPhfGv0HYTsPEOJau6TuOs0nLMvXSOCO7WXala6jmiOyFJoDye9jZ(E7JjZ(QQppKmsfC4pqX3pzKfmzC6mqj6dY6RyF)6dI(mRpqkgfqwfbQ97rnwMC0SkMTpMm77rnwM0UNaCa0NmlrFYYUV)99Rpi6dI(syqqX(gD6Wi6tMLOVs13)(yYSpqkgfqwfbQ97rnwMC0SkMTpMm7JyGVkNQsqcclw89Ril4(KzFS77p6gwdIaOm6R8(Ql1OBo1gGtapIoLth6q52cYOuQh6OlL6HUPLxFYTuJUXjwsmuQi7xzFzJUXrWvJWJavIa0nHXGLhkxX0JcWk6q5wPup0rak9kJOs0nLMvXSOCO7WXala6q0hifJciTtZPFvrAhb5OzvmBFmz2Nz9bsXOasnxpkqvtoAwfZ2htM9vvFEi1C9OavnPkR(yYSVh1yzs7EcWbqFqwFLIDFq((GOVQ6ZdjR4yLXzjvz13V(E7JjZ(y33)(k5(KH(yYSVQ6ZdPEGuZJSyWjceKXPZaLOpiRpiTV)99RpZ6trgdzvmswCUiqn47Hh)QI0UpBsHh6gwdIaOm6jLgyeejiWPOBo1gGtapIoLth6q52cYOuQh6OlL6HUHuAGrqKGaNIUXjwsmuQi7xzFzJUXrWvJWJavIa0nHXGLhkxX0JcWk6q5wPup0rak9cPOs0nLMvXSOCO7WXala6GumkGSk4CRyaYrZQy2((1he9zwFGumkGuNeGf)4pFag7ZargumYrZQy2(yYSpZ6dKIrbKAUEuGQMC0SkMTpMm7RQ(8qQ56rbQAsvw99hDdRbraugDaJiVWpdezqXq3CQnaNaEeDkNo0HYTfKrPup0rxk1dDLmI8c7RKezqX6dII)r34eljgkvK9RSVSr34i4Qr4rGkra6MWyWYdLRy6rbyfDOCRuQh6iaLEHKrLOBknRIzr5q3HJbwa0nRpqkgfqwfCUvma5OzvmBF)6RQ(8qQhi18ilgCIabPLxiTVF9LWGGI9n60Hr0NmlrFLcDdRbraugDaJiVWpdezqXq3CQnaNaEeDkNo0HYTfKrPup0rxk1dDLmI8c7RKezqX6dIs9hDJtSKyOur2VY(YgDJJGRgHhbQebOBcJblpuUIPhfGv0HYTsPEOJau6vwuj6MsZQywuo0D4yGfaDi6dKIrbK2P50VQiTJGC0SkMTpMm7ZS(aPyuaPMRhfOQjhnRIz7JjZ(QQppKAUEuGQMuLvFmz23JASmPDpb4aOpiRVsXUpiFFq0xv95HKvCSY4SKQS67xFV9XKzFS77FFLCFYqF)77xFM1NImgYQyKS4CrGAW3dp(bZi5eFeGyq(13V(mRpfzmKvXizX5Ia1GVhE8tpq23V(mRpfzmKvXizX5Ia1GVhE8Rks7(SjfEOBynicGYOdZi5eFeGyq(HU5uBaob8i6uoDOdLBliJsPEOJUuQh6MWi5e95Gyq(HUXjwsmuQi7xzFzJUXrWvJWJavIa0nHXGLhkxX0JcWk6q5wPup0rak9kdOs0nLMvXSOCO7WXala6M1hifJci1C9Oavn5OzvmBF)6dKIrbK2P50VQiTJGC0SkMfDdRbraug9Nj(IQemq3CQnaNaEeDkNo0HYTfKrPup0rxk1d9sprFgvjy0hef)JUXjwsmuQi7xzFzJUXrWvJWJavIa0nHXGLhkxX0JcWk6q5wPup0rak9cjHkr3uAwfZIYHUH1GiakJUDAoL4RgadDZP2aCc4r0PC6qhk3wqgLs9qhDPup0HCtZPqIi6tUayOBCILedLkY(v2x2OBCeC1i8iqLiaDtymy5HYvm9OaSIouUvk1dDeGsfzJkr3uAwfZIYHUdhdSaOdYObdqYvbeb7EHu0nSgebqz0FMOks7q3CQnaNaEeDkNo0HYTfKrPup0rxk1d9sprvK21hef)JUXjwsmuQi7xzFzJUXrWvJWJavIa0nHXGLhkxX0JcWk6q5wPup0rakv8fvIUP0SkMfLdDhogybq3S(aPyuazvW5wXaKJMvXS99RpqkgfqANMt)QI0ocYrZQyw0nSgebqz0bmI8c)mqKbfdDZP2aCc4r0PC6qhk3wqgLs9qhDPup0vYiYlSVssKbfRpiKX)OBCILedLkY(v2x2OBCeC1i8iqLiaDtymy5HYvm9OaSIouUvk1dDeGa0Ls9q3dAt6dsqQGddjSpkpQtbcqe]] )

    storeDefault( [[SimC Havoc: cooldown]], 'actionLists', 20180113.132154, [[d4JQfaGAeeRxkkTjPOYBbizBiO2hcWJvQzd08f4Ma6UsrXTr1HfTteTxv7MO9tvJcbYWKk)wY4qqAOaumyQmCk5GukofcuhdHoVGyHirlLs1IrQLtXdrcpL0YiK1bq0ebO0ujutwOPR4IukDAqptkQ66kPldTvbvBwj2oaEokFgjzAaunpbPrcq4VsvJwk9DPiNuk4qaK6AsHUhcOVHK61ck7IGpXl(kzYXRkKtH3bisaQnG072vbgRMKxbS4sUcoNYR2rqmz4jf1rKq7i2rOcIeb4nk6QUnqR56vB2dSKSl(KeV4R2ktAqmEkVQBd0AUcO9ocY7MeeLJqe5LeUfqzsdIrVliW7ainWKgefSQcekPQFPm9CCsVliW7ainWKgefAkHdusv)sz6LihzqM3fe4DaKgysdIcnLWbkPQFPm972Sy90GzezEhb7DbbE3KgQWryGCSFQ(ie9Uq9ornE1gAiiCc5khNKxgR2IbzxBqgH7CkZvzjXRaRy4PHm541RKjhVceNKxgR2IbzxTJGyYWtkQJi1e7UAhz1QzJSl(ZvkAXDyalaqokNtFfyfjtoE9ZjfDXxTvM0Gy8uEv3gO1CDsquocrKxs4waLjnig9UMZ7Oxxwe44K8Yy1wmity16Qn0qq4eYvoojVmwTfdYU2Gmc35uMRYsIxbwXWtdzYXRxjtoEfiojVmwTfdY8ocIibF1ocIjdpPOoIutS7QDKvRMnYU4pxPOf3HbSaa5OCo9vGvKm541pNS5V4R2ktAqmEkVQBd0AUsVUSiSBZI1tdMrKjSA5DbbEh96YIahNKxgR2IbzcRwExqG3TRcmwnjf44K8Yy1wmitiJeYkBWyVb5juY8Uq9orDExqG3nPHkCegih7NQpcrVluc07iC3vBOHGWjKRsKJmi7AdYiCNtzUkljEfyfdpnKjhVELm54vsKJmi7QDeetgEsrDePMy3v7iRwnBKDXFUsrlUddybaYr5C6RaRizYXRFojGFXxTvM0Gy8uEv3gO1CLEDzrGJtYlJvBXGmHvlVliW72vbgRMKcCCsEzSAlgKjKrczLnyS3G8ekzEhb4DeUZ7cc8UjnuHJWa5y)u9ri6DHsGExC1KdSKxTHgccNqUUBZI1tdMrKDTbzeUZPmxLLeVcSIHNgYKJxVsMC8kfTzX8okbZiYUAhbXKHNuuhrQj2D1oYQvZgzx8NRu0I7WawaGCuoN(kWksMC86Nt24fF1wzsdIXt5vDBGwZv61LfboojVmwTfdYemipHsM3raENOg9UGaVBsdv4imqo2pvFeIExOEhH7UAdneeoHC1QgyjV2Gmc35uMRYsIxbwXWtdzYXRxjtoEnyVS01T3llakatnWs2mbMR2rqmz4jf1rKAIDxTJSA1Sr2f)5kfT4omGfaihLZPVcSIKjhV(5Zv1c3Wee2S5al5jBKAQ)8d]] )

    storeDefault( [[SimC Havoc: demonic]], 'actionLists', 20180113.132154, [[deebsaqiIsBss5tecYOajNcK6vsOk7cvggQQJbKLjr9mjuMMKkDnjvSncb(gH04ie15KaH1jbsnpcHUNeW(Ku1bPiTqIIhsHAIsG6IueBKqKpkHkJucKCsjKBIK2jblLI6PunvkyRsq7f6Va1GL6WIwmGhdQjl0Lv2SK8zkKrdIttPvtiOEnrvZMu3MKDJYVrmCKy5cEosnDvDDISDc13jQmEjq05LiRxcv18rv2VkJGqdOxWRkL0pkd6oLbBtTT4NVLWqH6iQOOBE6L0dfkZhKiZheFrMRC56wNYO7WblLhD0nf(TegnAafaHgq3ewcOxeLbDhoyP8Od11FQh75OegLmSi3yjGEXR5X76p1J9CkIASxsXnwcOx8AOVU21asvvCucJsgwKlsKJDDTRbKQQ4ue1yVKIlsKJHUPawT9lHU4XmAvsAWH9HLp6fXIw48jb0ze2qNkjwyges1qhDHun0lCmJwLK(AZ7dlF0np9s6HcL5dsuq8r38Ojsb4rJgWhDJHmy5Psep1ypcGovsuivdD8rHYOb0nHLa6frzq3Hdwkp6qD9N6XEofrn2lP4glb0lEnpEx)PESNRAAWQK(xOe3yjGEXRH(6Axd11YE9N6XEofrn2lP4glb0lEnpExd11WqYGrJ(6cCD5R5X7AycrhjYX4epMrRssdoSpS85ctLwg911FDDVg6RRDnGuvfNIOg7LuCrICSRH(6Axd11WqYGrJ(6cCD5RHgDtbSA7xc9QPbhKOHGErSOfoFsaDgHn0PsIfMbHun0rxivdDrA6RnlrdbDZtVKEOqz(GefeF0npAIuaE0Ob8r3yidwEQeXtn2JaOtLefs1qhFuOyOb0nHLa6frzq3Hdwkp6FQh75a0esuVNBSeqV411UgQRL96p1J9CkIASxsXnwcOx8AE8UgqQQItruJ9skojkxd911UggsgmA0xxGRlJUPawT9lH(djqKdSr60kEOxelAHZNeqNrydDQKyHzqivdD0fs1q3aKarURloDAfp0np9s6HcL5dsuq8r38Ojsb4rJgWhDJHmy5Psep1ypcGovsuivdD8rH6Igq3ewcOxeLbDhoyP8Olod2eqpoaDgh4yYGh6Mcy12Ve6XLpeW0YTrb9IyrlC(Ka6mcBOtLelmdcPAOJUqQg6f8YhY1UCBuq380lPhkuMpirbXhDZJMifGhnAaF0ngYGLNkr8uJ9ia6ujrHun0XhfQdAaDtyjGErug0nfWQTFj0RMg8csuElHHErSOfoFsaDgHn0PsIfMbHun0rxivdDrA6Rnjir5Teg6MNEj9qHY8bjki(OBE0ePa8Ord4JUXqgS8ujINAShbqNkjkKQHo(OGianGUjSeqVikd6oCWs5rhQRt43kEGhBk7OVU(RbDn0xx7AOUw2R)up2ZPiQXEjf3yjGEXR5X7AaPQkofrn2lP4KOCnpExdti6irogNAFQibkqi0wAUmkclr)lcomvAz0xlIxZ)AOr3uaR2(LqVskucmPc8dzGTATnMbl6fXIw48jb0ze2qNkjwyges1qhDHun0fjPqPRjvx)q21fP12ygSOBE6L0dfkZhKOG4JU5rtKcWJgnGp6gdzWYtLiEQXEeaDQKOqQg64JcIIgq3ewcOxeLbDhoyP8Olod2eqpoaDgh4yYG311UgMq0rICmUvAGbwQ4ctLwg911FDDUU21YEnmHOJe5yCQ9PIeOaHqBP5clJLq3uaR2(LqhqNXboMm4HErSOfoFsaDgHn0PsIfMbHun0rxivdDz0zCxxWjdEOBE6L0dfkZhKOG4JU5rtKcWJgnGp6gdzWYtLiEQXEeaDQKOqQg64JcImAaDtyjGErug0D4GLYJ(N6XEoanHe175glb0lEDTRt43kEGhBk7OVU(cCD5RRDnuxl71FQh75uj9Vaysf4hYaBKoTIh3yjGEXR5X7AzV(t9ypNIOg7LuCJLa6fVMhVRbKQQ4ue1yVKItIY1qFDTRH66e(TIh4XMYo6RRVaxxSRHgDtbSA7xc9hsGihyJ0Pv8qViw0cNpjGoJWg6ujXcZGqQg6OlKQHUbibICxxC60kExdfiOr380lPhkuMpirbXhDZJMifGhnAaF0ngYGLNkr8uJ9ia6ujrHun0XhfkiqdOBclb0lIYGUdhSuE0RKcL4IRYcB)RRVaxxm(xx7AOUUskuIdwkeg7VweVUU8VMhVRbKQQ4u7tfjqbcH2sZfjYXUgA0nfWQTFj0RMgqNXHErSOfoFsaDgHn0PsIfMbHun0rxivdDrAAaDgh6MNEj9qHY8bjki(OBE0ePa8Ord4JUXqgS8ujINAShbqNkjkKQHo(Oai(Ob0nHLa6frzq3Hdwkp6j8BfpWJnLD0xx)1GUMhVRH6AzV(t9yphG2YIGRKcL4glb0lEnpExxjfkXfxLf2(xxFbUwu(xd911UgQRL9AaPQkU4ueMfg8ki)XIlcwTpvKafieAlnNeLR5X7AOUMEpyactIM7Tluge46sb(66VM)11UgqQQItTpvKafieAlnxyQ0YOVU(RbjcUg6RHgDtbSA7xc9vAGbwQqViw0cNpjGoJWg6ujXcZGqQg6OlKQHUjL21YSuHU5PxspuOmFqIcIp6MhnrkapA0a(OBmKblpvI4Pg7ra0PsIcPAOJpkaceAaDtyjGErug0D4GLYJouxl71FQh75ue1yVKIBSeqV4184DnGuvfNIOg7LuCsuUMhVRRKcL4IRYcB)RfXRlg)RlExd11asvvCucJsgwKtIY11UwKVMhVR5Fn0xZJ31asvvCQ9PIeOaHqBP5ctLwg91I4115AOVU21YET4myta94OqiAlZiWvKayaDgh4yYGh6Mcy12Ve6jJzHy15Bjm0lIfTW5tcOZiSHovsSWmiKQHo6cPAOBkJzHy15Bjm0np9s6HcL5dsuq8r38Ojsb4rJgWhDJHmy5Psep1ypcGovsuivdD8rbqLrdOBclb0lIYGUdhSuE0)up2ZbOjKOEp3yjGEXRRDnuxl71FQh75uj9Vaysf4hYaBKoTIh3yjGEXR5X7AzV(t9ypNIOg7LuCJLa6fVMhVRbKQQ4ue1yVKItIY1qFDTRt43kEGhBk7OVU(cCDXq3uaR2(Lq)HeiYb2iDAfp0lIfTW5tcOZiSHovsSWmiKQHo6cPAOBasGi31fNoTI31qvgA0np9s6HcL5dsuq8r38Ojsb4rJgWhDJHmy5Psep1ypcGovsuivdD8rbqfdnGUjSeqVikd6oCWs5rhQRL96p1J9CkIASxsXnwcOx8AE8UgqQQItruJ9skojkxZJ31vsHsCXvzHT)1I41fJ)1fVRH6AaPQkokHrjdlYjr56AxlYxZJ318Vg6RH(6Axl71IZGnb0JJcHOTmJaxrcGHHKeAW0FWk)UU21YET4myta94OqiAlZiWvKay1(86Axl71IZGnb0JJcHOTmJaxrcGb0zCGJjdEOBkGvB)sOddjj0GP)Gv(HErSOfoFsaDgHn0PsIfMbHun0rxivdDJHKe6R9pyLFOBE6L0dfkZhKOG4JU5rtKcWJgnGp6gdzWYtLiEQXEeaDQKOqQg64JcGQlAaDtyjGErug0D4GLYJUSx)PESNtruJ9skUXsa9Ixx76p1J9CXPimWa6moAUXsa9Ixx7AzVgMq0rICmUvAGbwQ4clJLUU21qDnmKmy0OVUaxx(AOr3uaR2(LqVAAWbjAiOxelAHZNeqNrydDQKyHzqivdD0fs1qxKM(AZs0qUgkqqJU5PxspuOmFqIcIp6MhnrkapA0a(OBmKblpvI4Pg7ra0PsIcPAOJpkaQoOb0nHLa6frzq3uaR2(LqpofHrdgW(d9IyrlC(Ka6mcBOtLelmdcPAOJUqQg6f8ueMie91Yy)HU5PxspuOmFqIcIp6MhnrkapA0a(OBmKblpvI4Pg7ra0PsIcPAOJpkaseGgq3ewcOxeLbDhoyP8O)zWO9Crl9Nm4DD9xdI)184DTSx)PESNdqtir9EUXsa9IOBkGvB)sO)qce5aBKoTIh6fXIw48jb0ze2qNkjwyges1qhDHun0najqK76ItNwX7AOkg0OBE6L0dfkZhKOG4JU5rtKcWJgnGp6gdzWYtLiEQXEeaDQKOqQg64Jp6cPAO7wLXxxqLIjWf0xhNIWSW4Ji]] )

    storeDefault( [[Red Vengeance: precombat]], 'actionLists', 20171128.104625, [[dqJ2baGEuLAxuOTjfTpubZgQBlODQO9s2nK9lvnmQ43cnyfmCLYbPiFdehdLZrbwif1svQwmvA5u1NbPNQ6Xk55uQjIk0uLktwGPdCrPKdl6YixhvHnIQOTIQKnRqBNc6JOs58sHPHkX3rv1PLSournAPulduDskPNbkxdvs3dvKxJQY4qLQ)sjwm1PpZqsFNc6h4fHGsjArCUFyZtRyOBc0)YxBaD9DctPnPjChgegJzGrhUWmage9VrRkXfVtqfrAYvUZ0nTavezRonzQtVfkDXuGmRpZqs)f0c3peh7h4jodj9DctPnPjChwtgeJoWy6wrb1kbrVokIi9V81gqx3KBHlqdD7cAHTehTmIZqsanHRo9wO0ftbYS(mdjDROrYJsC)Wb(IpsFNWuAtAc3H1KbXOdmMUvuqTsq0RJIis)lFTb0xTtpuYMdCIPBYTWfOHEHgjpkXwSb(IpsanHPo9wO0ftbYS(mdj9U2(i)9dCdNLHK(oHP0M0eUdRjdIrhymDROGALGOxhfrK(x(AdORBYTWfOHoOTpYVfO4SmKeqaDosJjpWazwaja]] )

    storeDefault( [[Red Vengeance: default]], 'actionLists', 20171128.104625, [[diuamaqisjAtQknksfNIuPvHsHSljgMiogelti9mvHPrkHRHkSniLVPQyCKsY5eczDKsQ5Hk6EQsTpsP(hkLYbvvzHqIhIsrnrukYfHuTrHGtcjTsHq1nrPKDIQ(jkLQHkeklvv0tPAQQQ6QOuO2QiL(kkfyVi)fkdMuCyklgfpwutwsxgSzf9zsvJwi60eVwKIzl1THQDRYVjz4c1Yf8CfMUsxhLSDrY3fP68Qswpkf08rPA)Osti0FY5nCG8NqLRM0cNEWUmO1C1uHPXQxY9CqIxYj)j0GnaIpAcYheeKiQKOfir0JpK7XqwSwydTvuhXZHwHq(V8kQBq)jEe6p5OFgtdvcfY5nCGC24bWvJl6LMRg1KRMi0goW2iNTu10AbEdhiN1aWgIEPXutSzB4a5)yKw2xKNYcIX0a5OEvjBRkq(PoG8Nqd2ai(OjiOH8PK8aHCphK4LCDwRHBlZ2WbSCWgrwGZyAO(TcmSMZYq0lnMAInBdhkba3KBW5BeDzNDD0Y1A42YSnCalhSrKf4mMgQ6slXhL(to6NX0qLqHCphK4LCDYkvxvPFfbhx12kQdZyfSsaWn5gCMu44BSjxPctjlR2Vr4qx2zxN1A42YeAM2QqboJPH63Ss1vv6xzcntBvOeaCtUbNjfo(gBYvQWuYYQ97ytoSkmLSSyTGlRUSZUoR1WTLj0yqGv8kQRaNX0q9BwP6Qk9RmHgdcSIxrDLaGBYn4mPWHUSZUoPSGymnuynaSHOxAm1eB2go81YRKcWGdWfyO97OFZkvxvPFLHOxAm1eB2goucaUj3GZKch6Yo76ejy9gzjgcz4woFxTtpeW2idWisvx)MvQUQs)ktOXQqkBS2kQReaCtUbNjfo(gBYvYScb4wTF)irxYzlvnTwG3WbYt3KfBQcyXbrfK9fMXiTScmi)j0GnaIpAccAiFkjpqih1RkzBvbYp1bKZB4a5SbMSC1mvbUAIybrfK9fxn)yKwwbgSnY)XiTSVipLfeJPbAj(h0FYr)mMgQekK75GeVKVk96BOWAayvyc3qsbdYFcnydG4JMGGgYNsYdeY)XiTSVipBDJz5vuhwlJLCuVQKTvfi)uhqoVHdKZMGjCdjfmiNTuvEdhi)ju5QjTWPhSldAnxnvyc3qsbdAjETG(to6NX0qLqHCEdhi3vSAUAyZnyPaYFcnydG4JMGGgYNsYdeYr9Qs2wvG8tDa5EoiXl5XMCLmRqaUv73OL8LH1Cwgkwn2my6XHBhLXA50WgXbNVJeSEJSuHPKLfloVK)JrAzFr(qXQXYnyPaAjEoO)KJ(zmnujui3ZbjEjFTgUTmILGSymkCMcCgtd1VvGH1CwMbt69vja4MCdo54ldR5SmuSASzW0Jd3okJ1YPr73iK)eAWgaXhnbbnKpLKhiKJ6vLSTQa5N6aY)XiTSViFelbzXyu4mKZB4a5ESeKLRguu4m0s8Or)jh9ZyAOsOqUNds8sESjxPctjlR2Vr4G8Nqd2ai(OjiOH8PK8aHCuVQKTvfi)uhq(pgPL9f5coUQTvuhMXkyKZB4a5OIJRABf1XvZpwbJwI)d9NC0pJPHkHc5EoiXl5wELuagCaUadTFh9BfyynNLHOxAm1eB2goucaUj3GZ3iK)eAWgaXhnbbnKpLKhiKJ6vLSTQa5N6aY)XiTSViFi6LgtnXMTHdKZB4a5UOxAUAutUAIqB4aTeVwr)jh9ZyAOsOqUNds8s(AnCBzcntBvOaNX0q9BSjxPctjlR2VJn5WQWuYYI1cUSK)eAWgaXhnbbnKpLKhiKJ6vLSTQa5N6aY)XiTSViFcntBvGCEdhipcqZ0wfOL4Ji6p5OFgtdvcfY5nCGC2(Cc3qsbdY9CqIxYxLE9nuYkvxvPFdYFcnydG4JMGGgYNsYdeYr9Qs2wvG8tDa5)yKw2xKNTUXS8kQdRLXsoBPQ8goq(tOYvtAHtpyxg0AUAuZjCdjfmOL4rsO)KJ(zmnujui3ZbjEj3YRKcWGdWfy8g57AnCBzgS8Ykaf4mMgQFJn5kvykzz5m2KdRctjllwl4Ys(tObBaeF0ee0q(usEGqoQxvY2QcKFQdi)hJ0Y(I8zWYlRaqoVHdKhHGLxwbGwIhbH(to6NX0qLqHCphK4L8kWWAoldrV0yQj2SnCOeaCtUbNVri)j0GnaIpAccAiFkjpqih1RkzBvbYp1bK)JrAzFr(q0lnMAInBdhiN3WbYDrV0C1OMC1eH2WbUA0brxAjEKO0FYr)mMgQekK75GeVKRJwUwd3wMblVScqboJPHk7SB5vsbyWb4cm0(DuD)gBYvQWuYYYzSjhwfMswwSwWLL8Nqd2ai(OjiOH8PK8aHCuVQKTvfi)uhq(pgPL9f5dfRgl3GLciN3WbYDfRMRg2CdwkGRgDq0LwIh5b9NC0pJPHkHc5EoiXl5R1WTLj0yqGv8kQRaNX0qL8Nqd2ai(OjiOH8PK8aHCuVQKTvfi)uhq(pgPL9f5tOXGaR4vuh58goqEeGMRg0dSIxrD0s8iAb9NC0pJPHkHc5EoiXl5PSGymnuynaSHOxAm1eB2go8vNSs1vv6xrUjeoRXgBqsduYrAb9WaBgS8kQZATFJu0koyNDlVskadoaxGH2VJQl3io5pHgSbq8rtqqd5tj5bc5OEvjBRkq(PoG8Fmsl7lYLBcHZASXgK0aKZB4a5OEtiCwZvJVbjnaTepch0FYr)mMgQekKZB4a5EKGf4QrheDj)j0GnaIpAccAiFkjpqih1RkzBvbYp1bK75GeVKRLPSGymnus3Kvo9ytvaloiQGSVWmgPLvGb5)yKw2xKpIeSaT0soBcMgREjuOLi]] )

    storeDefault( [[Red Vengeance: defensives]], 'actionLists', 20171128.104625, [[dSt5iaGEIsPnPQAxuABQk2NQiZgvZxuKUjrj5BIsRtuPANuyVi7wY(rPAuIIyyKQFt42KYJLQbJsA4O4GQsofrP6yq5CQIYcLclvvPfdXYv6HIkLNs1YKIEUitKOetvvQjtY0vCruk3dQ6YGRlL2OOs2krPyZez7IkoTkttvu9zuI5jQ64eLu)LIgnKEMQWjHk(ouPRruCEIQXjkQdl8ArHjm6n5gHgq(xqXoRYgOybIQd5o7SQajOsxoqICVVhZqo5FboejGmAQJLfdd7zw9NJ9Shzj3zG(f8t2gZjkYqMmJr(R(CIkrVjdm6n5SvbchuudYncnGCx0YzN1Cl2CGL8VahIeqgn1X(GL1Q)aJCCk11JrSKxIci377XmKdY62JHbu2GR2OJEM4glcpuq6hfc(GAzGTd1KhFwz(rALKSjrl3uAdw0GAs20e9mWR)RaKwjjR0bRCtKnkLDbT4QeEDYFHC8BKtEs0Yn7XMdS0qgnP3KZwfiCqrni3i0aYLfqtuSZQZCzajY)cCisaz0uh7dwwR(dmYXPuxpgXsEjkGCVVhZqEhnwwGKP0g95evWFcpMnRm)iTsswfOjkZeZLbKSlOfxLWR)RaKwjjR0bRCtKnkLDbT4QeE9FM4kBVDxOMNW3u)hfc(GAzGTd1KhFMLH8xih)g5KRanrzMyUmGenKXd6n5SvbchuudYncnG8CDWkNDwBSrPi)lWHibKrtDSpyzT6pWihNsD9yel5LOaY9(Emd5OqWhuldSDOM84ZSm)iTsswfOjkZeZLbKSkbU1psRKKvdMqtSmOI0LSkbU1psRKKnjA5MiXUhSwLa36VleCLa3YQanrzMyUmGKTJgllqkpg5Vqo(nYjx6GvUjYgLIgY450BYzRceoOOgK799ygYrHGpOwgy7qn5XlJm)tWHASsa3ub5ePjMtuwOceoO(zIRS92DHAEc)dDY)cCisaz0uh7dwwR(dmYXPuxpgXsEjkG8xih)g5KlbCtfKtKMyorrUrObKNlGZoRYcKtKMyorrdzid9MC2QaHdkQb5gHgqUScMqtSmOI0Li)lWHibKrtDSpyzT6pWihNsD9yel5LOaY9(Emd5OqWhuldSDOM8477nxp4Md6cjubxLPzAMGcbFqTmW2HAYJ)56)mXv2E7Uqn5X3u)VleCLa3YkDWk3ezJszxqlUk9K(VcqALKSshSYnr2OuwLa36hPvsYQanrzMyUmGKvjWT(7cbxjWTSkqtuMjMldiz7OXYcKmL2OpNOcEEDRmYo5Vqo(nYjxdMqtSmOI0LOHm(qVjNTkq4GIAqU33Jzihfc(GAzGTd1KhVkkwG1CqxiHk4kY)cCisaz0uh7dwwR(dmYXPuxpgXsEjkG8xih)g5KNeTCtKy3dwYncnGCx0YzN1gXUhS0qgzP3KZwfiCqrni377XmKJcbFqTmW2HAYJxfflWAoOlKqfC1ptCLT3UluZt4)Ot(xGdrciJM6yFWYA1FGrooL66XiwYlrbK)c543iN8KOLB25qKdqUrObK7Iwo7SMBCiYbOHmYm9MC2QaHdkQb5EFpMHCui4dQLb2outE8QOybwZbDHeQGR(rALKSkqtuMjMldizvcCRFKwjjRgmHMyzqfPlzvcCRFKwjjBs0YnrIDpyTkbUf5FboejGmAQJ9blRv)bg54uQRhJyjVefq(lKJFJCYLoyLBISrPi3i0aYZ1bRC2zTXgLIDwZemzNgY4z0BYzRceoOOgKBeAa54OPj4XCIIDwF1Ub5FboejGmAQJ9blRv)bg54uQRhJyjVefqU33Jzihfc(GAzGTd1KhVkkwG1CqxiHk4QFM4kRcKU(npHhtgYFHC8BKt(PPj4XCIYmA3GgYatNEtoBvGWbf1GCJqdipxahHhkG8VahIeqgn1X(GL1Q)aJCCk11JrSKxIci377XmKJcbFqTmW2HAYJxfflWAoOlKqfC1)eCOgReWr4HcSqfiCq9ZexzvG01V5j8mXvMkq663yYpTBi)fYXVro5sahHhkGgYadJEtoBvGWbf1GCJqdi3rHyj)lWHibKrtDSpyzT6pWihNsD9yel5LOaY9(Emd5OqWhuldSDOM84vrXcSMd6cjubxr(lKJFJCYtOqS0qd5YcifT8HAqdra]] )

    storeDefault( [[Red Vengeance: offensives]], 'actionLists', 20171128.104625, [[dOd9daGEuv0Mqv2LeBJuY(OqZMK5tb3esKBJs7us2lYUvSFLWOGunmkACOq16Ge6Bkjdws1WbLdIcofK0XaCoibluszPkPwmelhQhIQcpv0YqrpNstevLMQs0KLQPlCrsPEmqxw11jvTruvzROqAZGSDLQZdQonvFMuOVtkyAOQQdtmAir9AiLtsk6zKkxdfI7Pu(lQCiuO8BPmbqlPSsypLRFFrDg9JgVmGhfxuVbb9X673szcIDybLuU(Ql2tvmnbwbaaGcft(dGc6wrzc7GUOC(ucVnufJW4auYay4TXslPkaAjLApcI6DQgLvc7PKF(XWxuVgwMoLRV6I9ufttaTawvm1bqPMt3bLOHPCAZPmbXoSGs0fC4qcyuG8JHZ1pRBFbldAg3a4fI6tuGUIR)DXgs4TP8rquVZdS1u9MgMc0vC9Vl2qcVnf8zfFSBM8Gj(ua1JXFcJB6mr1Gb0zSquFIc0vC9Vl2qcVnLpcI6DdgeC4qcyuG8JHZ1pRBFbldABMOsjdiUYd4uc5hdNdbltNcQIjTKsThbr9ovJYkH9uYVRwuNVFxSHeEBOC9vxSNQyAcOfWQIPoak1C6oOenmLtBoLji2HfugI6tuGUIR)DXgs4TP8rquVZdM4tbupg)jmUPZKh6Ol4WHeWOa5hdNRFw3(cwg0mUbWtadF)CFoRF7gaV(r0dbvG8JHZHGLPxWNv8XACJjQgmGUGdhsaJcKFmCU(zD7lyzqBZ0Gbbm89Z95S(Tg3yIkQuYaIR8aoLqxX1)Uydj82qbvPJwsP2JGOENQrzLWEktyo2Jf1R1yrOuZP7Gs0WuoT5uU(Ql2tvmnb0cyvXuhaLjk30ak16oKFSLqOKbex5bCkTWCShCinwektqSdlOme1NOyH5yp4qASiLpcI6DEcy47N7Zz9BnUXKhIEiOITPxXbHfnY(jSfBiGOzCdGcQI)0sk1Eee17unktqSdlOKY1xDXEQIPjGwaRkM6aOuZP7Gs0WuoT5uYaIR8aoL2MEfhOG3pMYkH9uMn9Qf15dbVFmfuqjFpKOxfunkica]] )

    storeDefault( [[SimC Vengeance: default]], 'actionLists', 20171128.104625, [[d8tbpaWCcwVisyteQ2fj2MsP9jIYJv0HPA2uA(keUPGopj1Tj1Pv1of1EL2Tk7xPyuIigMqnoru9uKNjsnyLQgok1bvsDkHOoguDocfTqfQLIsSyuSCIEOizvcHwMiSorKOjkIutvPYKPy6O6IOKELis6YGRtiBuHKTcLAZkX2fWNfOVdLyAkKAEcb)vbVMKmAOy8ekCsLKBPq01iu6EqjDiHiFti9Bix8URu21qj61P2ShB4cc(nHKYn7nWIlYYlL0WIlYY74sSawWfGMteJhfhhxmvIhnUyMoAjAkF28sLwp5p6e6UMX7UsSEoJfmDCPqKbBxMDnuQu21qPuOtqKg2Sp0d(ZsRzE7ZvxAIobrAyq7b)zjwal4cqZjIX3IhvjonEPuyGPQquaqdhVmLwDMF6CKS0HoOuiYKDnuQ8Mt0DLy9Cgly64s0u(S5LyeTSOyan6gey)QabfdclN4mIwwu0a31ijBmiHxqXGWYvAnZBFU6slpivpWi9ZukfgyQkefa0WXltPqKbBxMDnuQu21qPr9Gu9M9JL(zkXcybxaAorm(w8OkXPXlT6m)05izPdDqPqKj7AOu5nNU7kX65mwW0XLOP8zZlnX4YGGawtmIrWiAzrXaA0niW(vbckgewoXJKbXvwEqQEGr6NrH)tv)fuCgrllkAG7AKKngKWlOyqy5kTM5TpxDjdOr3Ga7xfiukfgyQkefa0WXltPqKbBxMDnuQu21qPKg0OBZEI9RcekXcybxaAorm(w8OkXPXlT6m)05izPdDqPqKj7AOu5np6UReRNZybthxIMYNnVuKe(GVDGT1NGr8i93WI9dIHlUe0(FcJKl9aGDG)AyKgW6QJqSs6iAejD(JoXDj)x8jxz5bP6bdOFbqboNXcgXniUYYds1dms)mk8FQ6VGLwZ82NRU0FlG8C7Gax(QGsPWatvHOaGgoEzkfImy7YSRHsLYUgkT6wa552n7jU8vbLybSGlanNigFlEuL404LwDMF6CKS0HoOuiYKDnuQ8MfB3vI1ZzSGPJlrt5ZMxkscFW3oW26tWiEK(ByX(bXWfxcA)pHrYLEaWoWFnmsdyD1riwjDenIKo)rN4jjsUK)l(KRS8Gu9Gb0VaOaNZybZigrs0UymmX4YGGWiNyCzqqyyr6t(Jo3g5ikHjgxgeg4VgIWeHSgewoLLhKQhyK(zuKG2)tiPk2ilEsMiK1GWYPi8bF7aAzyX6AqrcA)pHKfDeJyIXLbbbSMiYLwZ82NRU0FlG8C7Gax(QGsPWatvHOaGgoEzkfImy7YSRHsLYUgkT6wa552n7jU8vbB2Ne8ixIfWcUa0CIy8T4rvItJxA1z(PZrYsh6GsHit21qPYBEB3vI1ZzSGPJlrt5ZMxYamIwwuwK(B5QvmiSCLwZ82NRUKa7x(8bgKMPukmWuvikaOHJxMsHid2Um7AOuPSRHse7x(8n7hJ0mLybSGlanNigFlEuL404LwDMF6CKS0HoOuiYKDnuQ8MJ2DLy9Cgly64s0u(S5LmiUYYds1dms)mk8FQ6VGLwZ82NRUKasKDy6YaGSukmWuvikaOHJxMsHid2Um7AOuPSRHsesKDZ(uUmailXcybxaAorm(w8OkXPXlT6m)05izPdDqPqKj7AOu5nN8UReRNZybthxIMYNnVeB)pLPiPeoEeWAYJlTM5TpxDPxRrwN)OBWfj9sPWatvHOaGgoEzkfImy7YSRHsLYUgkTsRrwN)OBZ(1IKEjwal4cqZjIX3IhvjonEPvN5NohjlDOdkfImzxdLkVzXS7kX65mwW0XLOP8zZlX2)tzkskHJhbSgnU0AM3(C1LwalJ1nqPuyGPQquaqdhVmLcrgSDz21qPszxdLgfyzSUbkXcybxaAorm(w8OkXPXlT6m)05izPdDqPqKj7AOu5nJh3DLy9Cgly64sHid2Um7AOuPSRHsesKDZ(XUu(GS0AM3(C1LeqISdmUu(GSelGfCbO5eX4BXJQeNgVukmWuvikaOHJxMsRoZpDosw6qhukezYUgkvEZ44DxjwpNXcMoUenLpBEjbKi7WI0dQHJlGvXwAnZBFU6scir2HPf8aqPuyGPQquaqdhVmLcrgSDz21qPszxdLiKi7M9PSGhakXcybxaAorm(w8OkXPXlT6m)05izPdDqPqKj7AOu5nJNO7kX65mwW0XLOP8zZlXrbdAbLjczniSCcINegrllkgqJUbb2VkqqXGWYjEKmiUYYds1dms)mk8FQ6VGIZiAzrrdCxJKSXGeEbfdclN4)nr6)coyCThegeRqYWaULJrr7IreJvIgh5sRzE7ZvxsdCxJKSXGeEHsPWatvHOaGgoEzkfImy7YSRHsLYUgkfcCxJKSXGeEHsSawWfGMteJVfpQsCA8sRoZpDosw6qhukezYUgkvEZ4P7UsSEoJfmDCjAkF28s)nr6)coyCThegeRqYWaULJrr7IreJvIgxAnZBFU6slGDWabCbUZF0vkfgyQkefa0WXltPqKbBxMDnuQu21qPrb2n7tAiGlWD(JUsSawWfGMteJVfpQsCA8sRoZpDosw6qhukezYUgkvEZ4JU7kX65mwW0XLOP8zZl93eP)l4GX1EqyqScjdRya3YXOODXiIXkrJlTM5TpxDjbKi7W0cEaOukmWuvikaOHJxMsHid2Um7AOuPSRHsesKDZ(uwWdaB2Ne8ixIfWcUa0CIy8T4rvItJxA1z(PZrYsh6GsHit21qPYBgxSDxjwpNXcMoUuiYGTlZUgkvk7AO0Oa7M9SkfXM)OR0AM3(C1Lwa7aifXM)ORelGfCbO5eX4BXJQeNgVukmWuvikaOHJxMsRoZpDosw6qhukezYUgkvEZ4B7UsSEoJfmDCjAkF28ssq7)jmsdyD1raRXkPJOrK05p6kTM5TpxDjHp4BhqldlwxdLsHbMQcrbanC8YukezW2LzxdLkLDnuI(GVDZE0YM9JY6AOelGfCbO5eX4BXJQeNgV0QZ8tNJKLo0bLcrMSRHsL3mE0UReRNZybthxIMYNnVeB)pLPiPeoEYWAYJfxajYoSi9GA44cry0I)3eP)l4GX1Eqyy0craRya3YXOODXiIXkjIlTM5TpxDPfPp5IKqPuyGPQquaqdhVmLcrgSDz21qPszxdLgL0NCrsOelGfCbO5eX4BXJQeNgV0QZ8tNJKLo0bLcrMSRHsL3mEY7UsSEoJfmDCjAkF28sS9)uMIKs44jdRjpU0AM3(C1LeqISdtl4bGsPWatvHOaGgoEzkfImy7YSRHsLYUgkrir2n7tzbpaSzFsse5sSawWfGMteJVfpQsCA8sRoZpDosw6qhukezYUgkvEZ4Iz3vI1ZzSGPJlfImy7YSRHsLYUgkryaxwAnZBFU6scyaxwIfWcUa0CIy8T4rvItJxkfgyQkefa0WXltPvN5NohjlDOdkfImzxdLkV8seBy(U9tkC(JUMfBYXlVf]] )

    storeDefault( [[SimC Vengeance: precombat]], 'actionLists', 20171128.104625, [[b4vmErLxt5uyTvMxtnvATnKFGzvzUDwzH52yLPJFGbNCLn2BTjwy051uevMzHvhB05LqEnLuLXwzHnxzE5KmWeZnXetm54cm0etoZCJxtn1yYLgC051uEnvqJrxAV52CErLxofJxu51uf5wyIXwzK5LqEn1uJjxAWrNxtr3BNDgBL5cCVrxAV52CEnvqILgBPrxEEnfCVrxAV5MxtLKBKL2yHr3BY51uU9MBL51un9gzwfMCofwBL51uEnLtH1wzEnfuVrxAV5MxtfKCNnNxt5wyTvwpIuNBIvMBKLMBN9fCVrxAV5MiEnLuLXwzHnxzE5KmWeJnXCJlWmtmEn1qOv2yR10B2vwBL5gDEjMxt10BK5uyTvMxtvNBIvMBKLMBN9fCVrxAV5Mx05fDEn1uWv2yPfgBPPxy0L2BU5Lt1GtmErNxEb]] )


    storeDefault( [[Havoc Primary]], 'displays', 20171128.104625, [[dWJYgaGELWlrQyxkrXRLkmtPIMTchwYnrQ0Vv1TvKNrkv7Kk7vSBc7NQ4NkLHPKgNsKSmOWqrXGPknCKCqPQttYXiY5qQYcLILskzXe1YP0dLk9uWJryDkr1evIyQq1KrvnDvUOI6Qiv1LHCDeTrsXwvIuBgv2Us1hLs5ZqPPjLQVtvnsuL(MuIrJsJhk6KiLBrkLRjL05jvpNI1QeLooQIJuWdquuN6fAEXbN(afyJ(4DsZnh4klw0XSZe5a2sGf1Lfr0rAcWdjIe1puyftiXfGiG(ghNbDDlQt9ctCRbWCJJZGUUf1PEHjU1auw1uz1Pr8cqTafx7RbMuI(540EaEirKi(DlQt9ctAcOVXXzqhEzXIotCRbmSVp4Roc2(50eWW((9K3NMakIxaufHsGnUwdCLfl66feSVnqZgo(gD1IwB8IhaZnood6OtJjoPayg3Aad77JxwSOZKMaDi3liyFBa8ngTO1gV4buc(kI6EBVGG9Tb0IwB8IhGOOo1l6feSVnqZgo(gDdauicvnulQt9I4ATLwcyyFFapnb4HerIwIYIio1lcOfT24fpGGCIgXlmX1EadfAm0mkdB3F82GhOItkGCCsbWgNuaBCs5cyyF)Uf1PEHjYbWCJJZGUEsBf3AGI0w46uOaYKCCbMkm7jVpU1aYd1IfTnE)(XiYbQbfBbSVpZ(CCsbQbfB19NKRJzFooPalbXvKJlnbQHFPBy2zstGDLrjRgQthxNcfqoarrDQx0puyfb6o7WN1kaFLHAu646uOavaBjWIW1Pqbkz1qD6bksBrxLaLMaDiR5fhOwGItcJa1GITWllw0XSZeNualAeO7SdFwRagk0yOzug2ihOguSfEzXIoM954KcWdjIeXNMGVIOU3AstaxnHcWBT)eE8YyvtLvpWvwSOtZlo40hOaB0hVtAU5a8rCf546z6maOM66XlV1(tSCpE5J4kYXfOdznV4GtFGcSrF8oP5MdOVXXzqhDAmXPnPa1GIT6h(LUHzNjoPa6rJ2wk61cgRsT2Ue9AfdTV2YA40w7TgGYQMkRUMxCGAbkojmcqzre)KCD9mDgautD94L3A)jwUhVuweXpjxxGAqXwa77ZSZeNuGPcZ(54wdyyFFWxDeS9K3NMaxzXIoM95ihql0avguCySk1IKKe9wM12LON2BjGH99z2zstad77thKUSsWxjWAstaIFsUoM95ihGOOo1l08IdulqXjHrGAqXw9d)s3WSphNuGoK18IladUhVqjmE86kR99dyyFFAc(kI6ERjnb0344mORN0wXTgOg(LUHzFonbmSVF)CAcyyFFM950eG4NKRJzNjYbksB1liyFBGMnC8n625Sg8a1GIT6(tY1XSZeNuaEiveDS0kdC6duGkWKsa4XTg4klw0P5fhOwGItcJafPTOj4ECDkuazsoUaef1PEHMxCbyW94fkHXJxxzTVFGI0wafAmOTK4wdmlk5bIFAcyutudu)2CCyeWW((9K2IMG7JCam344mOdVSyrNjU1axzXIonV4cWG7XlucJhVUYAF)a6BCCg0rtWxru3BnXTgaZnood6Oj4RiQ7TM4wdipulw0249JCaEirKi(0iEbOwGIR91atfMaECsbueVyz)FkoPwdWdjIeXxZloqTafNegb4EXfGb3JxOegpEDL1((b4HerI4tNgtAcmPe9K3h3AGI0w0xOUauJshzZLa]] )

    storeDefault( [[Havoc AOE]], 'displays', 20171128.104625, [[dSJXgaGEQQEjsHDPOs9AQiZKQIzRWnrk6Ws(gsPUnKANuAVIDty)ePFkvnmi63Q6ziumuu1GjIHJKdsL(mcogfDoekTqfzPuqlgflxkpur5PGhdvRdHkturvtfktMcnDLUOu5QuaxwLRJOnsf2kfOnJkBhcFKQsNMutdPKVtvgjvuldPQrJsJhHCsi5wiu11uuX5jQNtYAvujhhPYXmybWlQv)chVyHvECb6naMpOSDb2Qr4wEe8HjqReeUzShUtzkaZq73VVJ3lmbK754u3oROw9luXImar9CCQBNvuR(fQyrgGoYJ8mIc)fG2)flTqgaTw42flXeGoYJ8moROw9luzkGCphN6wSQr4wvSidOyFpWtV4SUDHjGI99Cj3pmbqxebyXAgyRgHBDf4SFlWupgwpnneLVoJfqowINEtKbK754u3sJjvSeVzaf77Hvnc3QYuaNyCf4SFlawpVHO81zSaAHrnETFZvGZ(TagIYxNXcGxuR(fUcC2VfyQhdRNMbM9uYsLG9bCUq84sL423fqX(EawMcqh5rEZRBh(QFradr5RZybeKOrH)cvS0kGI6gdhJsXo7hFlybQynd0I1maHyndWeRz2ak23BwrT6xOctaI654u36s2QyrgOiBfMm1fGHKJla6IixY9JfzaMH2VFFhVN7yeMa1GITa23JhrxSMbQbfBn7rZulpIUyndm)XvKJntbQHxjR4rWNPai0knJEOxzmzQlata8IA1VWDOjicmRZI1zyaJAf1OKXKPUa4bALGWHjtDbkg9qVYbkYwrtT4YuaNyC8If0(VynPpqnOylSQr4wEe8XAgODJaZ6SyDggqrDJHJrPydtGAqXwyvJWT8i6I1maDKh5zeLWOgV2VPYuaG6W11q7Vw9lIDo0M2bqRfUK7hlYaB1iCRJxSWkpUa9gaZhu2UagpUICSU8(eafUSujg80cfXjvY8hxro2aCVydWJjvcucLuj2Q1EVae1ZXPULgtQyndudk2YD4vYkEe8XAgqJ)I56F0XAoNaunn6Qj74flO9FXAsFaQ2H)OzQ1L3NaOWLLkXGNwOioPsM)4kYXgqJ)cGQW1ccXoNaOlIC7IfzaQMgD1KrH)cq7)ILwidSvJWT8i6cta6ipYZDOjiqFInaEaf77XJGptbiQNJtDlkHrnETFtflYaY9CCQBrjmQXR9BQyrgyRgHBD8InapMujqjusLyRw79cquphN6wSQr4wvSidOyFpxYwHsW9HjGI99qjmQXR9BQmfqUNJtDRlzRIfzGA4vYkEeDzkGI994r0LPak23ZTlmbWF0m1YJGpmbkYwbu3yGA(yrgOiBLRaN9BbM6XW6PPpDoWcuKTcLG7XKPUamKCCbqRfawSidSvJWToEXcA)xSM0hGosnUtguRGvECbycGxuR(foEXgGhtQeOekPsSvR9EbQbfBn7rZulpc(ynd0jkMXzmtbuA0uJZTVlw6d4eJJxSb4XKkbkHsQeB1AVxGAqXwUdVswXJOlwZa4f1QFHJxSG2)fRj9bWF0m1YJOlmbuSVhnozgTWOwqqLPagEJRuxS0J0K2MMMe7CJKwMelXq7ak23d80loRl5(zkarXImqnOylG994rWhRza6ipYZOJxSG2)fRj9bCIXXlwyLhxGEdG5dkBxa6ipYZinMuzkGTqFbCUq84sL423fOiBLbe6na1OKVw2ea]] )

    storeDefault( [[Vengeance Primary]], 'displays', 20171128.104625, [[d0JWgaGEPIxIuPDjvQABsLkZKQQoSKzRWXrL6Miv5zqP03GsvpNu7Ks7vSBu2pvLFQOggu8BiNMKHIQgmfA4i6GsPLHk5ye15qQOfkflvvQftKLtLhQk5PGhdvRdkvMOuPmvv1KrW0v5IsvxfvKlR01rYgPGTIk0Mj02rkFuQKpRitdPQ(ovzKOIACqPOrtW4HsojcDlKkCnubNNIEnvvwlukCBvXro)a4f5Pqmdi2bN5ydmZPV)eT9bUYnThpn(ifWvSP9LWI7xAcWn1sTTd1e7zzxa8aMZII69EvKNcX0XIjawZII69EvKNcX0XIjaPt9uotI4igO6SXsFmbEuS2(yX2aCtTulHxf5PqmDAcyolkQ37xUP90XIjGwa5bEQdxOTpnb0ciVwQdLMakCedilCfBkwoe4k30ETmCbKlqZ8)ptV3e7IZ)aynlkQ3JUn6yLdGvSycOfqE)YnTNonb8tQLHlGCb(Z8Vj2fN)bumck86qUwgUaYf4nXU48paErEkeRLHlGCbAM))z6faixCvnuDQtHyXYbSPCaTaYd(Pja3ul12nLBXpfIf4nXU48paJ6HioIPJL(b0K7yyyuAHxObYLFGkw5asXkhykw5aUyLZfqlG8EvKNcX0rkawZII69APCvSycuuU6BsUbKOefd8uy1sDOyXeqAO60PRbYRDmIuGAqkuGaYJNwFSYbQbPq9c9ivhpT(yLd0TvSOgxAcudVYuZtJpnbOP0kj1qDMFtYnGua8I8uiw7qnXc8Q3(7FhGGstokZVj5gOc4k20(nj3aLKAOoZafLRONITPjGFsgqSduD2yL5kqnifQF5M2JNgFSYbC7iWRE7V)Dan5ogggLwisbQbPq9l30E806Jvoa3ul1sGiJGcVoKtNMa26zdWXLnTfdF9zK3PEkNzGRCt7zaXo4mhBGzo99NOTpaHvSOgxlV)bEVe8zKJlBAlg(ID(msyflQXfWpjdi2bN5ydmZPV)eT9bmNff17r3gDS0HCGAqkuTdVYuZtJpw5aMXshCXHUlaPt9uotdi2bQoBSYCfG0T4OhP6A59pW7LGpJCCztBXWxSZNrs3IJEKQlqnifkqa5XtJpw5apfwT9XIjGwa5bEQdxOL6qPjWvUP94P1hPaV3Xw6nwUWiJ9YYY0z3JH(Y0j2I9b0cipEA8PjGwa5r31usXiOyt60eah9ivhpT(ifaVipfIzaXoq1zJvMRa1GuOAhELPMNwFSYb8tYaIDb4)(mcft7ZOTCoKxaTaYJiJGcVoKtNMaMZII69APCvSycudVYuZtRpnb0ciV2(0eqlG84P1NMa4OhP64PXhPafLRAz4cixGM5)FME(3B4hOgKc1l0JuD804Jvoa3ukC)4OsdN5ydubEum4hlMax5M2ZaIDGQZgRmxbkkxrKjI(MKBajkrXa4f5Pqmdi2fG)7ZiumTpJ2Y5qEbkkxbK7yqSBXIjqpRKglH0eqREihB7CFSCfqlG8APCfrMiksbWAwuuV3VCt7PJftGRCt7zaXUa8FFgHIP9z0wohYlG5SOOEpImck86qoDSycG1SOOEpImck86qoDSycinuD601a5fPaCtTulbI4igO6SXsFmbEkSGFSYbu4ig2aHEIvMdb4MAPwcgqSduD2yL5kGiIDb4)(mcft7ZOTCoKxaUPwQLaDB0PjWJI1sDOyXeOOCfNyQla5OmxxUea]] )




end
