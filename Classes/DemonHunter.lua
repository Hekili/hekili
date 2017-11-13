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

local addGearSet = ns.addGearSet
local addGlyph = ns.addGlyph
local addMetaFunction = ns.addMetaFunction
local addSetting = ns.addSetting
local addTalent = ns.addTalent
local addToggle = ns.addToggle
local addTrait = ns.addTrait
local addPerk = ns.addPerk
local addResource = ns.addResource
local addStance = ns.addStance

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
        addTalent( 'blade_turning', 247254 )
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
        addAura( 'blade_turning', 247254, 'duration', 5 )
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
        addAura( 'fiery_brand', 204022, 'duration', 8 )
        addAura( 'frailty', 224509, 'duration', 20 )
        addAura( 'sigil_of_flame', 204598, 'duration', 6 )
        addAura( 'soul_carver', 207407, 'duration', 3 )
        addAura( 'vengeful_retreat', 198813, 'duration', 3 )


        -- Fake Buffs.
        RegisterUnitEvent( "UNIT_SPELLCAST_SUCCEEDED", function( _, unit, spell, _, spellID )

            if unit ~= 'player' then return end

            if spell == class.abilities[ 'darkness' ].name then
                state.last_darkness = GetTime()
            
            elseif spell == class.abilities[ 'metamorphosis' ].name then
                state.last_metamorphosis = GetTime()

            elseif spell == class.abilities[ 'eye_beam' ].name then
                state.last_eye_beam = GetTime()

            end

        end )
        registerCustomVariable( 'last_darkness', 0 )
        registerCustomVariable( 'last_metamorphosis', 0 )
        registerCustomVariable( 'last_eye_beam', 0 )


        addAura( 'demonic_extended_metamorphosis', -20, 'name', 'Demonic: Extended Metamorphosis', 'feign', function()
            if buff.metamorphosis.up and last_eye_beam > last_metamorphosis then
                buff.demonic_extended_metamorphosis.count = 1
                buff.demonic_extended_metamorphosis.expires = buff.metamorphosis.expires
                buff.demonic_extended_metamorphosis.applied = last_eye_beam
                buff.demonic_extended_metamorphosis.caster = 'player'
                return
            end

            buff.demonic_extended_metamorphosis.count = 0
            buff.demonic_extended_metamorphosis.expires = 0
            buff.demonic_extended_metamorphosis.applied = 0
            buff.demonic_extended_metamorphosis.caster = 'unknown'
        end )


        addHook( 'spend', function( amt, resource )
            if state.equipped.delusions_of_grandeur and resource == 'fury' then
                state.setCooldown( 'metamorphosis', max( 0, state.cooldown.metamorphosis.remains - ( 30 / amt ) ) )
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
        addGearSet( 'class', 139715, 139716, 139717, 139718, 139719, 139720, 139721, 139722 )
        
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

        addSetting( 'nemesis_cooldown', true, {
            name = "Havoc: Treat Nemesis as Cooldown",
            type = "toggle",
            desc = "If |cFF00FF00true|r, Nemesis can only be recommended by the addon when you've Show Cooldowns is enabled.",
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
            texture = 1303275
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
        } )


        addAbility( 'eye_beam', {
            id = 198013,
            spend = 50,
            spend_type = 'fury',
            cast = 2,
            channeled = true,
            gcdType = 'melee',
            cooldown = 45,
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
                    buff.metamorphosis.remains = buff.metamorphosis.remains + 8
                else
                    applyBuff( 'metamorphosis', action.eye_beam.cast + 8 ) -- Cheating here, since channels fire handlers at start of cast.
                end
            end
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

        modifyAbility( "nemesis", "toggle", function( x )
            if settings.nemesis_cooldown then return x end
            return nil
        end )

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
            usable = function () return not settings.range_mgmt or target.within15 end
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
            gcdType = 'melee',
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


    storeDefault( [[SimC Havoc: default]], 'actionLists', 20171112.231427, [[deKNpaqiQQArkKAtOugfI4uOGvbPI8krkYSui5wIuODbyya5yIWYGepdfPPjsvxdsL2gkIVHs14GurDorkO1jsP5Hc19qrTprshurzHIepesAIIuuxefYifPYjHu1mHuHBsvStfSufQNk1uvuTvQQSxI)IWGfCyklgIhtLjtYLvTzQsFwenAuYPb9AfIzJ0Tf1Uv63sgoKYYj1Zr10H66iQTduFNQY5rKwVify(kY(fAjHmx6gT7GgfMgyyyTYa6Yo7sNMVxJmflPi94tVXVmGcOeSNircuaqHPGyhL0l9GLV0nmJAmKodC5sBmOUxJmfl9mhgwlxMldjK5sZO1qOxjPiD70q0Ws7Fmqsm4FmGn6xmW(85qoWxdHEvmmnfdUQOQY3cSpFoKdOVPingMMIbxvuv5Bb2NphYb0pBWLhdPgdytN8yammFcCrOGpgMMIbxvuv5Bb2NphYb0pBWLhdPgdmbumWG0ZqGuiMuPbBAOHqV0OFvqNHlT0BTxApLYptpy5lTpdIHBscVLMyF(Cix6blFPBCPFm4NrjFPNPtYLET8z2NbXWnjH3stSpFoKpkWgL8z2Fs8hB0VyG95ZHCGVgc9QPjxvuv5Bb2NphYb03uKon5QIQkFlW(85qoG(zdU8uXMo5Xayy(e4Iqb)0KRkQQ8Ta7ZNd5a6Nn4YtLjGyq6XNEJFzafqjypbiPhFErw7oxMlyPrL1DJ4Pa)8xSGiTNsny5lTGLbuK5sZO1qOxjPiD70q0Ws7Fmqsm4FmGn6xmGJLvCceQPoh4RHqVkgMMIbxvuv5BbCSSItGqn15a6BksJHPPyWvfvv(wahlR4eiutDoG(zdU8yi1yaB6KhdGH5tGlcf8XW0um4QIQkFlGJLvCceQPohq)SbxEmKAmWeqXadspdbsHysLgSPHgc9sJ(vbDgU0sV1EP9uk)m9GLV0(migUjj8wAchlR4eiutDU0dw(s34s)yWpJs(Xajjyq6z6KCPxlFM9zqmCts4T0eowwXjqOM68rb2OKpZ(tI)yJ(fd4yzfNaHAQZb(Ai0RMMCvrvLVfWXYkobc1uNdOVPiDAYvfvv(wahlR4eiutDoG(zdU8uXMo5Xayy(e4Iqb)0KRkQQ8TaowwXjqOM6Ca9ZgC5PYeqmi94tVXVmGcOeSNaK0JpViRDNlZfS0OY6Ur8uGF(lwqK2tPgS8LwWYatL5sZO1qOxjPiD70q0Ws7FmGn6xmG65AHoGVgc9QyGTyWvfvv(wG8XwU0OXQ4qoG(zdU8yGXXatIb2IbVK1KcOUxOdIJHuJbMckgylgijg8pgaBAOHqpGpdIHBscVLMyF(CipgMMIbxvuv5Bb2NphYb0pBWLhdmogsakgyigylgijg8pgaBAOHqpGpdIHBscVLMWXYkobc1uNhdttXGRkQQ8TaowwXjqOM6Ca9ZgC5XaJJbMedmi9meifIjvAWMgAi0ln6xf0z4sl9w7L2tP8Z0dw(sJwvu4MKWBPjYhBspy5lDJl9Jb)mk5hdKGcdsptNKl9A5ZmAvrHBscVLMiFSnkWgL8z2FSr)Ibupxl0b81qOxXMRkQQ8Ta5JTCPrJvXHCa9ZgC5mMjS5LSMua19cDqCQmfeBK4pytdne6b8zqmCts4T0e7ZNd5ttUQOQY3cSpFoKdOF2GlNXjaXaBK4pytdne6b8zqmCts4T0eowwXjqOM68Pjxvuv5BbCSSItGqn15a6Nn4Yzmtyq6XNEJFzafqjypbiPhFErw7oxMlyPrL1DJ4Pa)8xSGiTNsny5lTGLH0lZLMrRHqVssr62PHOHLgB0VyaVqnhtGqRsb81qOxfdttXa)ycKAjZbWWRrber6rZfdPgdGIHPPyWCyi4t89z45XqQmhdmngstXajXa2OFXaowwXjC0BGpWxdHEvmWwmW0yyAkgafdmi9meifIjvAWMgAi0ln6xf0z4sl9w7L2tP8Z0dw(sJqn1ju26U0dw(s34s)yWpJs(XajmLbPNPtYLET8zgHAQtOS19rb2OKpZyJ(fd4fQ5yceAvkGVgc9QPj(Xei1sMdGHxJciI0JMBAYCyi4t89z45PYmtttKGn6xmGJLvCch9g4d81qOxXgtNMaXG0Jp9g)YakGsWEcqsp(8IS2DUmxWsJkR7gXtb(5VybrApLAWYxAbldORmxAgTgc9kjfPBNgIgwAWMgAi0dGqn1ju26EmWwmqsm4LSMuahzT(logyCmWo6gdPXyGKyaB0VyaVqnhtGqRsb81qOxfdSfdOakgMMIbqXadXadspdbsHysLgSPHgc9sJ(vbDgU0sV1EP9uk)m9GLV0OvffUjj8wAceQPoHYw3LEWYx6gx6hd(zuYpgij9mi9mDsU0RLpZOvffUjj8wAceQPoHYw3hfyJs(md20qdHEaeQPoHYw3zJeVK1KYy2r30ijyJ(fd4fQ5yceAvkGVgc9k2qb00eigyq6XNEJFzafqjypbiPhFErw7oxMlyPrL1DJ4Pa)8xSGiTNsny5lTGLbMiZLMrRHqVssr62PHOHLgB0VyahlR4eo6nWh4RHqVkgylg8swtkG6EHoiogsngspiPNHaPqmPsd20qdHEPr)QGodxAP3AV0EkLFMEWYxA0QIc3KeElnHJLvCcowdh5spy5lDJl9Jb)mk5hdKGUmi9mDsU0RLpZOvffUjj8wAchlR4eCSgoYhfyJs(mJn6xmGJLvCch9g4d81qOxXMxYAsbu3l0bXPMEqS5V2GkId(lgWukoaz0ytBqfXb)fdykfhaUmgf0PKoL0Jp9g)YakGsWEcqsp(8IS2DUmxWsJkR7gXtb(5VybrApLAWYxAbldSlZLMrRHqVssr6ziqketQ0UA5KZNiBjHoPr)QGodxAP3AV0EkLFMEWYxAPhS8Lg1A5KZpg8yjHoPhF6n(LbuaLG9eGKE85fzT7CzUGLgvw3nINc8ZFXcI0Ek1GLV0cwgqNL5sZO1qOxjPiD70q0Ws7QIQkFlqsAHyucxvuv5Bb0pBWLhdmhdGKEgcKcXKkTZOucZHH1sqHCS0OFvqNHlT0BTxApLYptpy5lT0dw(sJQrPXWmhgwBmGoGCS0Z0j5sVw(mp6gMrngsNbUCPngCvrvLVD0sp(0B8ldOakb7jaj94ZlYA35YCblnQSUBepf4N)IfeP9uQblFPByg1yiDg4YL2yWvfvv(wbldPHYCPz0Ai0RKuKUDAiAyPXg9lgq9CTqhWxdHEL0ZqGuiMuP1KxcZHH1sqHCS0OFvqNHlT0BTxApLAWYx6gMrngsNbUCPngupxl0jTNs5NPhS8LwAuzD3iEkWp)flispy5l9yYBmmZHH1gdOdihl9mDsU0RLpZJUHzuJH0zGlxAJb1Z1cDJw6XNEJFzafqjypbiPBwLppLc6fEnxsr6XNxK1UZL5cw6gRHomQSUBejfbldjajZLMrRHqVssr6ziqketQ0AYlH5WWAjOqowA0VkOZWLw6T2lTNsny5lDdZOgdPZaxU0gdBPZgvApLYptpy5lT0OY6Ur8uGF(lwqKEWYx6XK3yyMddRngqhqoogijbdsptNKl9A5Z8OByg1yiDg4YL2yylD2OJw6XNEJFzafqjypbiPBwLppLc6fEnxsr6XNxK1UZL5cw6gRHomQSUBejfblyPBNgIgwAblca]] )

    storeDefault( [[SimC Havoc: precombat]], 'actionLists', 20171112.231427, [[duJgcaGEIsTjbYUKsVwGA2cDtPY3GIDQI9sTBi7hfJsqmmvv)M0qjkAWq1Wj0bvL6ucWXqPfkfTuO0Ijy5k6HQcpfzzsvpxHjse1uvvMSknDjxKOQNrK01vLCAuTvbPntKY2vfDzWJf10ic9DIcJKivRJiYOLcFwqDsIk3wKRreCEb0Hv6qeL8xIeBw)zIeHmFJCzVfxr(ibmymjzqA7Ry5MMWcryhGp9)Syyzz7B7L6pMEjA6SjWeXtpyWL((uZsIbxCcznjSLP35IROH)8H1FMKhTcr46MMO8KlwMknC4i0kQfxrdtVf4rEfOjrT4kYKCOlpVLonHueyQtVHUZZMatMoBcmjtT4kYewic7a8P)Nfd7VjSWqFnZWWFUm9ObKdUtFcjavwWuNEpBcm5YNE)zsE0keHRBAIYtUyzQ0WHJqBw14vLbAWGhedEim4YIbpeg8AJaQAVqsrszcc6e1cOvicxg8GyWRncOQ9cjfXZTaAfIWLbpag8am9wGh5vGMsqTjDk2qh8Hj5qxEElDAcPiWuNEdDNNnbMmD2eyQdQnPtXg6GpmHfIWoaF6)zXW(Bclm0xZmm8NltpAa5G70NqcqLfm1P3ZMatUCzIYtUyzYLn]] )

    storeDefault( [[SimC Havoc: normal]], 'actionLists', 20171112.231427, [[daeHzaqijuBIa(KeHQrjPCkjQvbvs8kjczxOYWiOJjjltcEgHktJqvDnjI2gujPVrGghujCoOsuRtIqzEeQY9KizFqL6GKuTqcLhskmrOsQlskzJsK6JsemsOsKoPeYnHu7evTusYtPmvsyRKI2l4Vqvdwvhw0IH4XqzYcUSYMHKpdvmAe50c9AskZMOBtLDJ0Vrz4eYYPQNJW0L66KQTtI(oPuNxs16HkrmFe1(vzOcuagUEOsDzdIbMjAyXugXLKDKrb(skOGGPAYLed4liSsWQQQcCfeNqbli(Gzy(OOgmWuhRJmkbOa4RafGPfnrKlaIbMH5JIAWQDFNYrBor(jk9lWnAIix4EYKVVt5OnNJ5gT1DCJMiYfUV89cCpIokuCI8tu6xGlW0MEVa3JOJcfNJ5gT1DCbM2uWuhjkJDDWuokodLUeVFTFzdwr0qelBMhmkJoWqZcAME(0nWaJpDdmnhfNHsxEVQ1(LnyQMCjXa(ccReSsiyQgbt3Jncqb0GPbPHPgAMY5gTbeWqZc8PBGbnWxauaMw0erUaigygMpkQbR29DkhT5Cm3OTUJB0erUW9KjFFNYrBoutI3Le9815gnrKlCF57f4(A3x89DkhT5Cm3OTUJB0erUW9KjFFT7XiLECgX9L6(c3tM89ymMmW0MYPCuCgkDjE)A)YMZpxgPe3J77f)7lFVa3JOJcfNJ5gT1DCbM207lFVa3x7(IVVt5OnhQjX7sIE(6CJMiYfUNm57rP7RZfgQiwSVh3L6(cL8(Y3lW91UhJu6Xze3xQ7lCFzWuhjkJDDWqnjEVobjWkIgIyzZ8Grz0bgAwqZ0ZNUbgy8PBGv6jVxLobjWun5sIb8fewjyLqWuncMUhBeGcObtdsdtn0mLZnAdiGHMf4t3adAGxCGcW0IMiYfaXaZW8rrny1UhrhfkohZnAR740fDpzY3x89DkhT5Cm3OTUJB0erUW9LVxG7RDFI1rLd)OZfhX94((Q7ldM6irzSRdgQjXJKEFIZaRiAiILnZdgLrhyOzbntpF6gyGXNUbwPN8EXsVpXzGPAYLed4liSsWkHGPAemDp2iafqdMgKgMAOzkNB0gqadnlWNUbg0aV4dkatlAIixaedmdZhf1G1PC0MdrYyb5AUrte5c3lW91UV477uoAZ5yUrBDh3OjICH7jt(EeDuO4Cm3OTUJtx09LVxG7XiLECgX9L6(cGPosug76G1K8mTXJJmJkhyfrdrSSzEWOm6adnlOz65t3adm(0nWuqYZ0((sqMrLdmvtUKyaFbHvcwjemvJGP7XgbOaAW0G0Wudnt5CJ2acyOzb(0nWGg4ljOamTOjICbqmWmmFuudgkDFDomDVF0(EX7(QsEVa3x7EmgtgyAt5clBs4j0EteNFUmsjUx8UVW94k3Jdw4EYKVhJXKbM2uoezgg(qsXgNFUmsjUx8UVW94k3Jdw4(YGPosug76GHAsezggyfrdrSSzEWOm6adnlOz65t3adm(0nWk9KiYmmWun5sIb8fewjyLqWuncMUhBeGcObtdsdtn0mLZnAdiGHMf4t3adAGhxfuaMw0erUaigygMpkQbtz6JjICCiYmm8HKInWuhjkJDDWclBs4j0EteyfrdrSSzEWOm6adnlOz65t3adm(0nWW1lBs3BAVjcmvtUKyaFbHvcwjemvJGP7XgbOaAW0G0Wudnt5CJ2acyOzb(0nWGg4feuaMw0erUaigygMpkQbdJu6Xze3xQ7lCVa3x89DkhT5Cm3OTUJB0erUW9cCFX33PC0Md1K4DjrpFDUrte5c3lW9fFpIokuCU1PJ5frIrej40fbM6irzSRdgQjX71jibwr0qelBMhmkJoWqZcAME(0nWaJpDdSsp59Q0jiDFTQYGPAYLed4liSsWkHGPAemDp2iafqdMgKgMAOzkNB0gqadnlWNUbg0apUauaMw0erUaigyQJeLXUoyOMe)86I6iJcwr0qelBMhmkJoWqZcAME(0nWaJpDdSsp59A51f1rgfmvtUKyaFbHvcwjemvJGP7XgbOaAW0G0Wudnt5CJ2acyOzb(0nWGg4XLbfGPfnrKlaIbMH5JIAWAgo4ihx67iQeRVxG7RDFT7tSoQC4hDU4iUh33xDF57jt((A3x7(IVVt5OnNJ5gT1DCJMiYfUNm57r0rHIZXCJ26ooDr3x(EbUV29fFFNYrBomsjJapImdJGB0erUW9KjFpIokuCyKsgbEezggbNUO7jt(EmgtgyAt5WiLmc8iYmmco)CzKsCpUVxCcVNm5770JZAUo6g(MHpe39I39ymMmW0MYHrkze4rKzyeC(5YiL4(Y3x((YGPosug76GHs3xhpdf(M0WhLYyi9rWkIgIyzZ8Grz0bgAwqZ0ZNUbgy8PBGvADF97zOUVjT7lskJH0hbt1KljgWxqyLGvcbt1iy6ESrakGgmninm1qZuo3OnGagAwGpDdmOb(kHGcW0IMiYfaXaZW8rrnyktFmrKJdrMHHpKuSbM6irzSRdgImddFiPydSIOHiw2mpyugDGHMf0m98PBGbgF6gyIjZWUhxNuSbMQjxsmGVGWkbRecMQrW09yJauanyAqAyQHMPCUrBabm0SaF6gyqd8vvGcW0IMiYfaXaZW8rrnyDkhT5qKmwqUMB0erUW9cCFI1rLd)OZfhX94Uu3x4EbUV29fFFNYrBoxs0ZJNHcFtA4XrMrLJB0erUW9KjFFX33PC0MZXCJ26oUrte5c3tM89i6OqX5yUrBDhNUO7lFVa3x7(eRJkh(rNloI7XDPUxC3xgm1rIYyxhSMKNPnECKzu5aRiAiILnZdgLrhyOzbntpF6gyGXNUbMcsEM23xcYmQC3xRQmyQMCjXa(ccReSsiyQgbt3Jncqb0GPbPHPgAMY5gTbeWqZc8PBGbnWxvauaMw0erUaigygMpkQbdLUVoxyOIyX(ECxQ7fNW7lr3x7EeDuO4e5NO0VaNUO7f4ECX9KjFVW7ldM6irzSRdgQjrKzyGveneXYM5bJYOdm0SGMPNpDdmW4t3aR0tIiZWUVwvzWun5sIb8fewjyLqWuncMUhBeGcObtdsdtn0mLZnAdiGHMf4t3adAGVsCGcW0IMiYfaXaZW8rrnyjwhvo8JoxCe3J77RUNm57RDFI1rLd)OZfhX94Uu3lU7lFpzY3x7(oLJ2CiYinGhLUVo3OjICH7f4Eu6(6CHHkIf77XDPUxCL8(Y3tM89eRXJWO6eCDC(cv4lic7ECFVqWuhjkJDDWw9HhzPdSIOHiw2mpyugDGHMf0m98PBGbgF6gyAvF3l2shyQMCjXa(ccReSsiyQgbt3Jncqb0GPbPHPgAMY5gTbeWqZc8PBGbnWxj(GcW0IMiYfaXaZW8rrny1UVt5OnxyogfpImdJGB0erUW9KjFFX33PC0MZXCJ26oUrte5c3tM89i6OqX5yUrBDhNUO7jt(Eu6(6CHHkIf77fV7fNW7lr3x7EeDuO4e5NO0VaNUO7f4ECX9KjFVW7lFpzY3JOJcfNBD6yErKyerco)CzKsCV4DFjVV89cCFX3Rm9XeroormMmsXbpkMhpImddFiPydm1rIYyxhSKsJKIYSJmkyfrdrSSzEWOm6adnlOz65t3adm(0nWuNsJKIYSJmkyQMCjXa(ccReSsiyQgbt3Jncqb0GPbPHPgAMY5gTbeWqZc8PBGbnWxvsqbyArte5cGyGzy(OOgSoLJ2CisglixZnAIix4EbUV29fFFNYrBoxs0ZJNHcFtA4XrMrLJB0erUW9KjFFX33PC0MZXCJ26oUrte5c3tM89i6OqX5yUrBDhNUO7ldM6irzSRdwtYZ0gpoYmQCGveneXYM5bJYOdm0SGMPNpDdmW4t3atbjpt77lbzgvU7RvOmyQMCjXa(ccReSsiyQgbt3Jncqb0GPbPHPgAMY5gTbeWqZc8PBGbnWxHRckatlAIixaedmdZhf1Gv89DkhT5qKmwqUMB0erUW9cCpIokuCU1PJ5frIrej4cmTP3lW9jwhvo8JoxCe3J7sDV4atDKOm21bRj5zAJhhzgvoWkIgIyzZ8Grz0bgAwqZ0ZNUbgy8PBGPGKNP99LGmJk391exzWun5sIb8fewjyLqWuncMUhBeGcObtdsdtn0mLZnAdiGHMf4t3adAGVsqqbyArte5cGyGzy(OOgSA33PC0MlmhJIhrMHrWnAIix4EYKVV477uoAZ5yUrBDh3OjICH7jt(EeDuO4Cm3OTUJtx09KjFpkDFDUWqfXI99I39It49LO7RDpIokuCI8tu6xGtx09cCpU4EYKVx49LVV89cCFX3Rm9XeroormMmsXbpkMhpgPKrGNO9r129cCFX3Rm9XeroormMmsXbpkMhVBDEVa3x89ktFmrKJteJjJuCWJI5XJiZWWhsk2atDKOm21bdJuYiWt0(OAdSIOHiw2mpyugDGHMf0m98PBGbgF6gyAqkze3BTpQ2at1KljgWxqyLGvcbt1iy6ESrakGgmninm1qZuo3OnGagAwGpDdmOb(kCbOamTOjICbqmWmmFuudwX33PC0MZXCJ26oUrte5c3lW91UVt5OnxyogfpImdJGB0erUW9KjFpIokuCU1PJ5frIrej4cmTP3xgm1rIYyxhmutI3RtqcSIOHiw2mpyugDGHMf0m98PBGbgF6gyLEY7vPtq6(AfkdMQjxsmGVGWkbRecMQrW09yJauanyAqAyQHMPCUrBabm0SaF6gyqd8v4YGcW0IMiYfaXatDKOm21blmhJsGhj2dSIOHiw2mpyugDGHMf0m98PBGbgF6gy465y0sCI7fl2dmvtUKyaFbHvcwjemvJGP7XgbOaAW0G0Wudnt5CJ2acyOzb(0nWGg4lieuaMw0erUaigygMpkQbRtpoR5Iu8(KIZatDKOm21bRj5zAJhhzgvoWkIgIyzZ8Grz0bgAwqZ0ZNUbgy8PBGPGKNP99LGmJk391e)YGPAYLed4liSsWkHGPAemDp2iafqdMgKgMAOzkNB0gqadnlWNUbg0aFHkqbyArte5cGyGzy(OOgSo94SMlej6KIT7X99vL8EYKVVtpoR5Iu8(KIZatDKOm21bd1KiYmmWkIgIyzZ8Grz0bgAwqZ0ZNUbgy8PBGv6jrKzy3xRqzWun5sIb8fewjyLqWuncMUhBeGcObtdsdtn0mLZnAdiGHMf4t3adAGVqbqbyArte5cGyGzy(OOgSo94SMlej6KIT7X99vL8EYKVV29D6XznxKI3NuC29cCFX33PC0MZXCJ26oUrte5c3xgm1rIYyxhmutI3RtqcSIOHiw2mpyugDGHMf0m98PBGbgF6gyLEY7vPtq6(AIRmyQMCjXa(ccReSsiyQgbt3Jncqb0GPbPHPgAMY5gTbeWqZc8PBGbnWxqCGcW0IMiYfaXaZW8rrnyD6Xznxis0jfB3J77RkjyQJeLXUoykhfNHsxI3V2VSbRiAiILnZdgLrhyOzbntpF6gyGXNUbMMJIZqPlVx1A)Y((AvLbt1KljgWxqyLGvcbt1iy6ESrakGgmninm1qZuo3OnGagAwGpDdmOb(cIpOamTOjICbqmWmmFuudwX33PC0MdrYyb5AUrte5cGPosug76G1K8mTXJJmJkhyfrdrSSzEWOm6adnlOz65t3adm(0nWuqYZ0((sqMrL7(ALSmyQMCjXa(ccReSsiyQgbt3Jncqb0GPbPHPgAMY5gTbeWqZc8PBGbn0GXNUbMfDACpU0ujdRe7EkZ7sj0aa]] )

    storeDefault( [[SimC Havoc: cooldown]], 'actionLists', 20171112.231427, [[dWdRhaGAQawpqsTjcQDruVwkv7diXSvY8rIBcu3MKhdyNi1EvTBsTFunkQqdtP63chwXqbsXGrz4I0bjiNIkQJPu(MuPfsiTur0IjYYPQhsf5PuwMi8CeteijtLk1Kf10LCrPexfivDzORlvDEQeBvQWMjuBhionONjLKptG5jv0ibsL)kfJgjDiGu6Kuj9DcX1Oc6Esj10KsP1rfOTjLI)2DFJEu4ndQCIZaDdibGdYzarSYHi6BGku80VQl6TK4chcE6e7BD322siNOv7Dt02BgGhMw3Ujeqbdn5Up92DFRf9iTW8f9Mb4HP1TkeiyHYarSYHiAcNjmN5iNbA5mh5SAwOUKZOk0qazupslmZzuOWzGmE4iTq50iwqTGgXHVrH1WzuOWzGmE4iTqzrgyb1cAeh(gnQqcKWzuOWzGmE4iTqzrgyb1cAeh(gaQtqAKwtgjCMZCgfkCwnEbyjxqf2urtgICwNCwchYzoFtij4cwUCtH1OcFk1Gaj3CvNHatf(B6qJ3ah5ogp9OWB3OhfEdmwJk8PudcKCljUWHGNoX(w3T9Bjrs07bqYD)6MturG2bhGGkuxx6g4itpk82RtN4UV1IEKwy(IEZa8W06wfceSqzGiw5qenHZeMZCKZQzH6soJQqdbKr9iTWmNjmNj1lwSScRrf(uQbbsK7t5mH5mX9ExKb69EuxCwNCwB35mNVjKeCblxUPWAuHpLAqGKBUQZqGPc)nDOXBGJChJNEu4TB0JcVbgRrf(uQbbs4mh3C(wsCHdbpDI9TUB73sIKO3dGK7(1nNOIaTdoabvOUU0nWrMEu4TxNUv39Tw0J0cZx0BgGhMw3YOuVyXYAuHeirohIO5mH5SbOGGGnOgvqKWzGcNTXzcZz14fGLCbvytfnziEtij4cwUCtJkKaj3CvNHatf(B6qJ3ah5ogp9OWB3OhfEJgvibsUjKxa5wnEby1af3Afu7G14fGLCbvytfnziEljUWHGNoX(w3T9Bjrs07bqYD)6MturG2bhGGkuxx6g4itpk82Rt327(wl6rAH5l6ndWdtRBs9IfldqDcsJ0AYirUpLZOqHZK6flwwH1OcFk1GajY9PCgfkCgqeRCiIwwH1OcFk1GajYt2b6jfMB8OAGAcN1jNLyNZOqHZCKZKccHZeMZQXlal5cQWMkAYqKZ6S1CwB25mNVjKeCblxUPrfsGKBUQZqGPc)nDOXBGJChJNEu4TB0JcVrJkKajCMJBoFljUWHGNoX(w3T9Bjrs07bqYD)6MturG2bhGGkuxx6g4itpk82Rt7W7(wl6rAH5l6ndWdtRBviqWcLbIyLdr0eotyoZrotQxSyzfwJk8PudcKi3NYzuOWzarSYHiAzfwJk8PudcKipzhONuyUXJQbQjCgOWzTzNZOqHZQXlal5cQWMkAYqKZ6S1CwU3pfm0CMZ3escUGLl3aOobPrAnzKCZvDgcmv4VPdnEdCK7y80JcVDJEu4nNOobHZeDnzKCljUWHGNoX(w3T9Bjrs07bqYD)6MturG2bhGGkuxx6g4itpk82Rt3M7(wl6rAH5l6ndWdtRBviqWcLtJcgAcNjmN5iNj1lwSScRrf(uQbbsK9OAGAcNbkCwchYzuOWz14fGLCbvytfnziYzDYzTANZC(MqsWfSC5wAuWqFZvDgcmv4VPdnEdCK7y80JcVDJEu4nqtuWqFljUWHGNoX(w3T9Bjrs07bqYD)6MturG2bhGGkuxx6g4itpk82Rt39UV1IEKwy(IEJEu4nqpzKwiN5AHkYnx1ziWuH)Mo04nHKGly5YTEc2alurULejrVhaj39RBjXfoe80j236UTFZa8W062Rx3SueaoliOEkyOpTd7291pa]] )

    storeDefault( [[SimC Havoc: demonic]], 'actionLists', 20171112.231427, [[da0ctaqijWMqv8jQufnkiPtbjEfvQQ2fbdJqoMeTmj0ZKeAAuPsxtsKTrLQY3GsnoQuX5qvszDuPk18qvsUNKO2hQsDqIklKq5HujMOKGUivsBevj(OKaJKkvHtsLYnHu7evwkr6PuMkrSvIQ2RQ)Iedg4WIwmepgQMSqxwzZsQpdLmAO40cEnHQztQBtYUr8BugosA5u1ZrQPl11PITtu(Ue04rvs15LKwpvQsMpQQ9d6xEj3QWvNo6(IDZOo8qQdUxzhyKZvjSX(M0PxsVZvuuj2LLLffkwrryx0DVz4(a1(2n5W7aJqFjNR8sU5kjr0lEXUz4(a1(gQqqN6rAbQ(rn9lkmsIOxec4Zhc6upslOyQrAhLWijIEriafiGhiaXPUwGQFut)IcrwHeiGhiaXPUwqXuJ0okHiRqYn5qc6qx9MSrWA1oAk(1(L9n3iXaE2m)ncJSBOzr5tpxQ2TBCPA3KFeSwTJgcKU2VSVjD6L07CffvIDPOBshnZXJp6l59nxWmCXrZKn1i9rUHMf5s1U9(CfVKBUsse9IxSBgUpqTVHke0PEKwqXuJ0okHrse9IqaF(qqN6rAH6PPOs6E(QcJKi6fHauGaEGauHGcGGo1J0ckMAK2rjmsIOxec4ZhcqfcWXKESgneuziOieWNpeGZy6iRqIGSrWA1oAk(1(LTGFQmqOHaEdbUleGceWdeG4uxlOyQrAhLqKvibcqbc4bcqfcWXKESgneuziOieGYn5qc6qx9w90u8o0yU5gjgWZM5VryKDdnlkF65s1UDJlv7gVmnei1HgZnPtVKENROOsSlfDt6OzoE8rFjVV5cMHloAMSPgPpYn0SixQ2T3NRIxYnxjjIEXl2nd3hO236upslGOzSOETWijIEriGhiaviOaiOt9iTGIPgPDucJKi6fHa(8HaeN6Abftns7OeCOcbOab8ab4yspwJgcQmeu8MCibDORERX4zfsblDgKTBUrIb8Sz(Begz3qZIYNEUuTB34s1UjbJNvieub6miB3Ko9s6DUIIkXUu0nPJM54Xh9L8(MlygU4OzYMAK(i3qZICPA3EFo39sU5kjr0lEXUz4(a1(MS0hse9eq0zCuIjbF3KdjOdD1BXLngk0fUr9MBKyapBM)gHr2n0SO8PNlv72nUuTBv4YgdeyfUr9M0PxsVZvuuj2LIUjD0mhp(OVK33CbZWfhnt2uJ0h5gAwKlv727ZvPl5MRKerV4f7MCibDOREREAkZ7qTdmYn3iXaE2m)ncJSBOzr5tpxQ2TBCPA34LPHax9ou7aJCt60lP35kkQe7sr3KoAMJhF0xY7BUGz4IJMjBQr6JCdnlYLQD795CFxYnxjjIEXl2nd3hO23AgwyPNq67qDI3qapqaQqaQqqI3bzJYitfgneWBiOecqbc4Zhcqfcqfckac6upslOyQrAhLWijIEriGpFiaXPUwqXuJ0okbhQqakqakqak3KdjOdD1B1o(Quy1uAmJsqRdX0hU5gjgWZM5VryKDdnlkF65s1UDJlv7gV44RcbSAiOXmiWnToetF4M0PxsVZvuuj2LIUjD0mhp(OVK33CbZWfhnt2uJ0h5gAwKlv727ZH9LCZvsIOx8IDZW9bQ9nzPpKi6jGOZ4Oetc(GaEGaCgthzfsew1rbzPsWpvgi0qaVHGkbb8abfab4mMoYkKiOwNkMNkggDGwWVmw9MCibDOREdrNXrjMe8DZnsmGNnZFJWi7gAwu(0ZLQD7gxQ2nX0zCqqfMe8Dt60lP35kkQe7sr3KoAMJhF0xY7BUGz4IJMjBQr6JCdnlYLQD795CNl5MRKerV4f7MH7du7BDQhPfq0mwuVwyKerVieWdeK4Dq2OmYuHrdb8UYqqriGhiaviOaiOt9iTGkP75PWQP0ygfS0zq2egjr0lcb85dbfabDQhPfum1iTJsyKerVieWNpeG4uxlOyQrAhLGdviafiGhiaviiX7GSrzKPcJgc4DLHGkcbOCtoKGo0vV1y8ScPGLodY2n3iXaE2m)ncJSBOzr5tpxQ2TBCPA3KGXZkecQaDgKnia1suUjD6L07CffvIDPOBshnZXJp6l59nxWmCXrZKn1i9rUHMf5s1U9(C8AxYnxjjIEXl2nd3hO23QD8vfIRoGhAiG3vgcQOOBYHe0HU6T6Pr0zC3CJed4zZ83imYUHMfLp9CPA3UXLQDJxMgrNXDt60lP35kkQe7sr3KoAMJhF0xY7BUGz4IJMjBQr6JCdnlYLQD795kfDj3CLKi6fVy3mCFGAFlX7GSrzKPcJgc4neucb85dbfabio11cXPyKaoLXR3JexKIADQyEQyy0bAbhQqaF(qaQqa9AkimIdTqhMVyjf3LkoeWBiqeeWdeG4uxlOwNkMNkggDGwWpvgi0qaVHa3bcq5MCibDOREBvhfKLQBUrIb8Sz(Begz3qZIYNEUuTB34s1U5A1bbITuDt60lP35kkQe7sr3KoAMJhF0xY7BUGz4IJMjBQr6JCdnlYLQD795klVKBUsse9IxSBgUpqTVHkeuae0PEKwqXuJ0okHrse9IqaF(qaItDTGIPgPDucouHa(8HGAhFvH4Qd4Hgc4vqqffbbUFiaviaXPUwGQFut)IcouHaEGa3bc4ZhcebbOab85dbio11cQ1PI5PIHrhOf8tLbcneWRGGkbbOab8abfabYsFir0tGkJPdeSOuZ8uq0zCuIjbF3KdjOdD1BjHeWe0zhyKBUrIb8Sz(Begz3qZIYNEUuTB34s1UjhHeWe0zhyKBsNEj9oxrrLyxk6M0rZC84J(sEFZfmdxC0mztnsFKBOzrUuTBVpxzXl5MRKerV4f7MH7du7BDQhPfq0mwuVwyKerVieWdeGkeuae0PEKwqL098uy1uAmJcw6miBcJKi6fHa(8HGcGGo1J0ckMAK2rjmsIOxec4ZhcqCQRfum1iTJsWHkeGYn5qc6qx9wJXZkKcw6miB3CJed4zZ83imYUHMfLp9CPA3UXLQDtcgpRqiOc0zq2GaulIYnPtVKENROOsSlfDt6OzoE8rFjVV5cMHloAMSPgPpYn0SixQ2T3NRSIxYnxjjIEXl2nd3hO23qfckac6upslOyQrAhLWijIEriGpFiaXPUwqXuJ0okbhQqaF(qqTJVQqC1b8qdb8kiOIIGa3peGkeG4uxlq1pQPFrbhQqapqG7ab85dbIGauGauGaEGGcGazPpKi6jqLX0bcwuQzEk4ysgnf62heFqapqqbqGS0hse9eOYy6ablk1mpf16ec4bckacKL(qIONavgthiyrPM5PGOZ4Oetc(Ujhsqh6Q3WXKmAk0Tpi(U5gjgWZM5VryKDdnlkF65s1UDJlv7MlysgneyTpi(UjD6L07CffvIDPOBshnZXJp6l59nxWmCXrZKn1i9rUHMf5s1U9(CLU7LCZvsIOx8IDZW9bQ9TcGGo1J0ckMAK2rjmsIOxec4bcqfcqCQRfuRtfZtfdJoqlezfsGa(8HGo1J0cXPyeki6moAHrse9IqakqapqaQqaoM0J1OHGkdbfHauUjhsqh6Q3QNMI3HgZn3iXaE2m)ncJSBOzr5tpxQ2TBCPA34LPHaPo0yGaulr5M0PxsVZvuuj2LIUjD0mhp(OVK33CbZWfhnt2uJ0h5gAwKlv727ZvwPl5MRKerV4f7MCibDORElofJqtbj07MBKyapBM)gHr2n0SO8PNlv72nUuTBv4umI7jneiwO3nPtVKENROOsSlfDt6OzoE8rFjVV5cMHloAMSPgPpYn0SixQ2T3NR09Dj3CLKi6fVy3mCFGAFRtpwRfcek(KG1Ga(8HGcGGo1J0ciAglQxlmsIOx8MCibDORERX4zfsblDgKTBUrIb8Sz(Begz3qZIYNEUuTB34s1UjbJNvieub6miBqaQveLBsNEj9oxrrLyxk6M0rZC84J(sEFZfmdxC0mztnsFKBOzrUuTBVpxj2xYnxjjIEXl2nd3hO2360J1AHyGUtc(GaEdbLvcc4Zhcqfc60J1AHaHIpjyniGhiOaiOt9iTGIPgPDucJKi6fHauUjhsqh6Q3QNMI3HgZn3iXaE2m)ncJSBOzr5tpxQ2TBCPA34LPHaPo0yGaulIYnPtVKENROOsSlfDt6OzoE8rFjVV5cMHloAMSPgPpYn0SixQ2T3NR0DUKBUsse9IxSBgUpqTV1PhR1cXaDNe8bb8gckR0n5qc6qx9MSrWA1oAk(1(L9n3iXaE2m)ncJSBOzr5tpxQ2TBCPA3KFeSwTJgcKU2VSHaulr5M0PxsVZvuuj2LIUjD0mhp(OVK33CbZWfhnt2uJ0h5gAwKlv727334s1UzbLlqG7rkJH7EdbXPyKa(7Fa]] )

    storeDefault( [[Red Vengeance: precombat]], 'actionLists', 20171112.231427, [[dmJ2baGEufTlkY2uQSpLQmBi3wi7uj7LSBO2VuzyuQXHkPblvnCLYbPOogkpNswifSuqAXcSCQ6WIEQQhRO1HkLjQuvtvbtwqth4IcvlJkUmY1rLQnIQWwrLyZk02rv5JOICEHYNbLVJQQtlzAOcnAQuFduDsk0ZaX1qf19qf8AuL(lvYVLYIPb9vgr6qPWUEUqyyuINe366380SffKa99PXK7iGmOdLquArA5yZGZymhtoqSH7Wr9VrZkrfptq1WAXzUY0npbvdBPbTyAqpoodquOmOVYis)fSc113g765bkJiDOeIslslhB2ogCt2qy6gXH1mbnVoUHjDZbfQaX0TkyfYvB01ikJi9p91gqxaTC0GECCgGOqzqFLrKUr8i5XjQR)aFXlPdLquArA5yZ2XGBYgct3ioSMjO51XnmPBoOqfiMEHhjporUSa(Ixs)tFTb0NUtpmYApoWeqliAqpoodquOmOVYisFWTVXFxpNqzXhPdLquArA5yZ2XGBYgct3ioSMjO51XnmPBoOqfiMoWTVXVlyOS4J0)0xBaDbeq)tFTb0fqca]] )

    storeDefault( [[Red Vengeance: default]], 'actionLists', 20171112.231427, [[diuamaqisfSjvLgfPkNIuvRsvIYUKyyI4yqSmsPNjsnnuk11qf2gKY3uvmosf6CQsuToHumpur3tvQ9rQ0)qPOoOQkles8qukYerPqxes1gjv0jHKwPQePBIsj7ev9tvjIHkKsTuvHNs1uvv1vrPG2QQe(QqkzVi)fkdMuCyklgfpwutwsxgSzf9zHy0cjNM41cPA2sDBOA3Q8BsgUqTCbpxHPR01rjBxK8DvjDEvrRhLcmFuQ2pQ0ec9NCEdhi)bu5Q5fWfbSldrdxnvyAS6LC2imnw9sOq(dObBaeV2eKpiiiAlAtN8rlBtUhdzXAHnWwrDeph6ic5)YROUb9N4rO)KZwQ6lSaVHdKZAaydjI0yQj2SnCGCphK4LC9wRHBlZ2WbSCWgrvGZyAO(TcmSMZYqIinMAInBdhkba3KBW5Be9zND90H1A42YSnCalhSruf4mMgQ6toVHdKZgoaUACjI0C1OMC1OZ2Wb2m5)yKw2NKNYcIX0a5OEvjBRkq(PoG8hqd2aiETjiOH8PKKgHC0pJPHkHcTeVw6p5SLQ(clWB4a5VAYInvbS4GOcY(eZyKwwbgK75GeVKRxwP6Q61Ri44Q2wrDygRGvcaUj3GZKchFJn5kvykzz19nch6Zo76Twd3wMqZ0wfkWzmnu)MvQUQE9ktOzARcLaGBYn4mPWX3ytUsfMswwDFhBYHvHPKLfRfCz1ND21BTgUTmHgdcSIxrDf4mMgQFZkvxvVELj0yqGv8kQReaCtUbNjfo0ND21lLfeJPHcRbGnKisJPMyZ2WHVwELuagCaUadDFR9BwP6Q61RmKisJPMyZ2WHsaWn5gCMu4qF2zxVOaR3OkXqid3Y57QDrGa2gvagrP663Ss1v1RxzcnwfszJ1wrDLaGBYn4mPWX3ytUsMvia3Q770j6t(dObBaeV2ee0q(ussJq(pgPL9j5PSGymnqoQxvY2QcKFQdiN3WbYJwMSC1mvbUAI2brfK9jxn)yKwwbgSzYr)mMgQek0s8PP)KJ(zmnujui3ZbjEjFvrI0qH1aWQWeUHKcgK)JrAzFsE26gZYROoSwgl5pGgSbq8Atqqd5tjjnc5OEvjBRkq(PoGCEdhiNnct4gskyqoBPQ8goq(dOYvZlGlcyxgIgUAQWeUHKcg0s8Sn9NC0pJPHkHc58goqURy1C1WMAWsbK)aAWgaXRnbbnKpLK0iKJ6vLSTQa5N6aY)XiTSpjFOy1y5gSua5EoiXl5XMCLmRqaUv33OL8LH1Cwgkwn2myrWHBhLXA5O)Y4GZ3rbwVrvQWuYYIfNxAjEoO)KJ(zmnujui3ZbjEjFTgUTmILGSymkCMcCgtd1VvGH1CwMbt69zja4MCdo54ldR5SmuSASzWIGd3okJ1Yrx33iK)aAWgaXRnbbnKpLK0iKJ6vLSTQa5N6aY5nCGCpwcYYvdkkCgY)XiTSpjFelbzXyu4m0s8Or)jh9ZyAOsOqUNds8sESjxPctjlRUVr4G8hqd2aiETjiOH8PKKgHCuVQKTvfi)uhqoVHdKJkoUQTvuhxn)yfmY)XiTSpjxWXvTTI6WmwbJwI)d9NC0pJPHkHc5EoiXl5wELuagCaUadDFR9BfyynNLHerAm1eB2goucaUj3GZ3iK)aAWgaXRnbbnKpLK0iKJ6vLSTQa5N6aY5nCGCxIinxnQjxn6SnCG8Fmsl7tYhsePXutSzB4aTeVos)jh9ZyAOsOqUNds8s(AnCBzcntBvOaNX0q9BSjxPctjlRUVJn5WQWuYYI1cUSK)aAWgaXRnbbnKpLK0iKJ6vLSTQa5N6aY5nCGCDcntBvG8Fmsl7tYNqZ0wfOL4F50FYr)mMgQekKZB4a5VK5eUHKcgK75GeVKVQirAOKvQUQE9gK)aAWgaXRnbbnKpLK0iKJ6vLSTQa5N6aY)XiTSpjpBDJz5vuhwlJLC2sv5nCG8hqLRMxaxeWUmenC1OMt4gskyqlXJKq)jh9ZyAOsOqUNds8sULxjfGbhGlW4nY31A42Ymy5LvakWzmnu)gBYvQWuYYYzSjhwfMswwSwWLL8hqd2aiETjiOH8PKKgHCuVQKTvfi)uhqoVHdKRZGLxwbG8Fmsl7tYNblVScaTepcc9NC0pJPHkHc5EoiXl5vGH1CwgsePXutSzB4qja4MCdoFJq(dObBaeV2ee0q(ussJqoQxvY2QcKFQdiN3WbYDjI0C1OMC1OZ2WbUA0drFY)XiTSpjFirKgtnXMTHd0s8iAP)KJ(zmnujui3ZbjEjxpDyTgUTmdwEzfGcCgtdv2z3YRKcWGdWfyO7BT6)n2KRuHPKLLZytoSkmLSSyTGll5pGgSbq8Atqqd5tjjnc5OEvjBRkq(PoGCEdhi3vSAUAytnyPaUA0drFY)XiTSpjFOy1y5gSuaTepsA6p5OFgtdvcfY9CqIxYxRHBltOXGaR4vuxboJPHk5pGgSbq8Atqqd5tjjnc5OEvjBRkq(PoGCEdhixNqZvd6bwXROoY)XiTSpjFcngeyfVI6OL4ryB6p5OFgtdvcfY9CqIxYtzbXyAOWAaydjI0yQj2SnC4REzLQRQxVICtiCwJn2GeDOKJYcrGb2my5vuN16(gPOJCWo7wELuagCaUadDFRvFUVuYFanydG41MGGgYNssAeYr9Qs2wvG8tDa58goqoQ3ecN1C14BqIoq(pgPL9j5YnHWzn2yds0bAjEeoO)KJ(zmnujuiN3WbY9OalWvJEi6t(dObBaeV2ee0q(ussJqoQxvY2QcKFQdi)hJ0Y(K8ruGfi3ZbjEjxhszbXyAO8QjRCrWMQawCqubzFIzmslRadAPLCphK4LCAjca]] )

    storeDefault( [[Red Vengeance: defensives]], 'actionLists', 20171112.231427, [[dSt5iaGEkkQnPQAxuABQsTpvLmBunFkQ0nvvQ62KY6uvQStkSxKDlz)OeJIIsnms1Vj8nrYJLQbJsz4O4GQkoffvCmO6CuuKfkfwQQKfdXYv6HuuYtPAzuKNlQjksvtvv0Kjz6kUikvNNO6YGRlL2ifvTvkkyZez7IuoTkptv4ZOKMNu0HfgNivgnKMMQs5KqrFhkCnII7bL(RiEnrPJtrHMWPNKBeAa5VaflSzgGIviQo8DSWMcKGkFPbzYtpifT8HAq(lGdrgidt64PWXXnzn9qpLPVrUZa9l4NzoMtuKHmPdN8p95evMEsg40tYzVceoOOgKBeAa5UOLZcBMvSPbl5VaoezGmmPJ)gpLv)bo5ywQRhJyjVefq(hKJFJCYZIwEsp20GLCVVhZqoygBpggqzdUAJo6LGrSi8qb5Fui4dQLb2outtSPK5hPvsYMfT8ePnyvdQjBZt0LfR(VcqALKSshSYtq2Ou2f0IRYy1PHmmrpjN9kq4GIAqUrObKNEqtuSWMZCYczYFbCiYazysh)nEkR(dCYXSuxpgXsEjkG8pih)g5KRanrLKzozHm5EFpMH8oASSc5ePn6ZjQG)fwCBkz(rALKSkqtujzMtwiBxqlUkJv)xbiTsswPdw5jiBuk7cAXvzS6)mXv2E7UqnFH1K(pke8b1YaBhQPj20jdnKXd6j5SxbchuudYncnGCZFWkNf2ASrPi)fWHidKHjD834PS6pWjhZsD9yel5LOaY)GC8BKtU0bR8eKnkf5EFpMHCui4dQLb2outtSPtMFKwjjRc0evsM5KfYwLaJ6hPvsYQbtOjwgur(YwLaJ6hPvsYMfT8eKy3dwRsGr93fcUsGrzvGMOsYmNSq22rJLvi3eNgY4B0tYzVceoOOgK799ygYrHGpOwgy7qnnXkJm)tWHASsaprbPf5jMtuwOceoO(zIRS92DHA(c7dDYFbCiYazysh)nEkR(dCYXSuxpgXsEjkGCJqdi38aNf2spKwKNyorr(hKJFJCYLaEIcslYtmNOOHmKHEso7vGWbf1GCJqdi)7Hj0eldQiFzYFbCiYazysh)nEkR(dCYXSuxpgXsEjkG8pih)g5KRbtOjwgur(YK799ygYrHGpOwgy7qnnX23BUEWtg0fYOcUYCnxZgfc(GAzGTd10e730)zIRS92DHAAI1K(Fxi4kbgLv6GvEcYgLYUGwCv(l9FfG0kjzLoyLNGSrPSkbg1psRKKvbAIkjZCYczRsGr93fcUsGrzvGMOsYmNSq22rJLviNiTrForf8M6wzmhAiJ30tYzVceoOOgK799ygYrHGpOwgy7qnnXQIIvytg0fYOcUI8xahImqgM0XFJNYQ)aNCml11JrSKxIci3i0aYDrlNf2Ae7EWs(hKJFJCYZIwEcsS7blnKrk6j5SxbchuudY9(Emd5OqWhuldSDOMMyvrXkSjd6czubx9Zexz7T7c18f236K)c4qKbYWKo(B8uw9h4KJzPUEmIL8sua5gHgqUlA5SWMzXHinG8pih)g5KNfT8KohI0aAiJ0rpjN9kq4GIAqU33Jzihfc(GAzGTd10eRkkwHnzqxiJk4QFKwjjRc0evsM5KfYwLaJ6hPvsYQbtOjwgur(YwLaJ6hPvsYMfT8eKy3dwRsGrr(lGdrgidt64VXtz1FGtoML66XiwYlrbKBeAa5M)GvolS1yJsXcBMnU5q(hKJFJCYLoyLNGSrPOHmmt0tYzVceoOOgKBeAa5yQPj4XCIIf2(0Ub5VaoezGmmPJ)gpLv)bo5ywQRhJyjVefq(hKJFJCYpnnbpMtujr7gK799ygYrHGpOwgy7qnnXQIIvytg0fYOcU6NjUYQaPRFZxyXLHgYaxNEso7vGWbf1GCJqdi38ahHhkG8xahImqgM0XFJNYQ)aNCml11JrSKxIci)dYXVro5sahHhkGCVVhZqoke8b1YaBhQPjwvuScBYGUqgvWv)tWHASsahHhkWcvGWb1ptCLvbsx)MVWYexLOaPRFtc)0UHgYahNEso7vGWbf1GCJqdi3rHyj)fWHidKHjD834PS6pWjhZsD9yel5LOaY)GC8BKtEgfILCVVhZqoke8b1YaBhQPjwvuScBYGUqgvWv0qd5EFpMHCAic]] )

    storeDefault( [[Red Vengeance: offensives]], 'actionLists', 20171112.231427, [[dKd9daGEuLQnHI2LeBJuyFuHztY8jLUjQcUnkTtjzVi7wX(LunkiLHrL(TuwhvunyLWWHKdIcDkuWXa1JbAHsklvjzXqSCOEiQs5PIwgiEovnrQOmvLutwQMUWfPICyIlR66KkBevL2kQIAZa2Us15bPtt5ZOQQVJQINrQ6BkrJgvHEnKQtskAAOQY1qvK7Pu(lQCiuLyCOkPjyAnLvc7PC171xWZF4)Lb8oV(IgaWhVTFpLo7aIovq1OC1vx8NQG4cVegggsbIE3Lq4hLjQdAIY4DjS2qv8eVctjJGH1gpTMQGP1u60iiQ3PAuwjSNs(AhdT(IAyz6uU6Ql(tvqCH1aEzXvpmLAoDduIgMYPnNsgrmLfqPeWogkhcwMoLji2qfuIMGddqaJcGDmuU(zn)lyzq3XgmZquFIcWvC9Vl(qcRnLpcI6DMGTMQ34ZuaUIR)DXhsyTPGpRyJFZLjkXMcOom(t4ytVldA1IgVeI6tuaUIR)DXhsyTP8rquVRvRGddqaJcGDmuU(zn)lyzqFZLbkOki0AkDAee17unkRe2tjFVQ(cN9DXhsyTHYvxDXFQcIlSgWllU6HPuZPBGs0WuoT5uYiIPSakLaxX1)U4djS2qzcInubLHO(efGR46Fx8HewBkFee17mrj2ua1HXFchB6DzIgAcomabmka2Xq56N18VGLbDhBWmfWW2p3NZA3VbZSFeDaafa7yOCiyz6f8zfB8o2GWGwTOj4WaeWOayhdLRFwZ)cwg03C1QvadB)CFoRDVJnimWafuLEAnLoncI6DQgLji2qfugI6tu8OmSfCinwKYhbr9otbmS9Z95S29o2GWerhaqX30P4aWc)z)e(Ipeq0DSbtzLWEktug2I6lQ1yrOC1vx8NQG4cRb8YIREyktESXhEO1na7ypHqjJiMYcOu6rzyl4qASiuQ50nqjAykN2CkOk(rRP0PrquVt1OmbXgQGskxD1f)PkiUWAaVS4QhMsnNUbkrdt50MtzLWEkZMov9f8MG3pMsgrmLfqP030P4af8(XuqbLji2qfusbra]] )

    storeDefault( [[SimC Vengeance: default]], 'actionLists', 20171112.231427, [[d8tbpaWBiRxHkztek7IeVMKSpru9Cu60QA2umFfkDtHCEsQVjcpwr7uu7vA3QSFLsJsqQHjuJtHIld(RcgSsQHJIoOsLtjI4yeCocvYcvilffAXq1Yj6HIuRIqvltqTocvQjQqftvPQjtPPJQlcL6vkuPEMi56eYgfrzROGnReBxahMQVdL0NfO5jiAAku12ukgnumEcvCsLKBjI01eeUhuINICibj3MuxHUVu21qj61P3UMb4cc(nbX921wyXfz4LiMW8DZpUC(JUMdXyekXiyaNfAoCSqcbbHWkHtfNi84lrt5ZKxQ0Uj)rhB33Sq3xc7ZXnGTJkfHSm4YSRHsLYUgkLgDSI0W21rEWFwkngyQkcfa0WXlEjgbd4SqZHJf2iKqjoLqPvN9NohjlDOdkTd)npxDPj6yfPHbTh8NLIq2SRHsL3C4UVe2NJBaBhvIMYNjVeUOLfflOr3alZxfWQyry9edx0YIIg4UgjzIbX(SkwewVs7WFZZvxA5bP6bCPF2sPXatvrOaGgoEXlfHSm4YSRHsLYUgkLShKQ3UEK0pBjgbd4SqZHJf2iKqjoLqPvN9NohjlDOdkfHSzxdLkV5uDFjSph3a2oQenLptEPjgxgeyXs4XowCrllkwqJUbwMVkGvXIW6jwOSiUYYds1d4s)Sk8FQ6VGIHlAzrrdCxJKmXGyFwflcRxPD4V55Qlzbn6gyz(Qa2sPXatvrOaGgoEXlfHSm4YSRHsLYUgknoGgDBxtmFvaBjgbd4SqZHJf2iKqjoLqPvN9NohjlDOdkfHSzxdLkV5X39LW(CCdy7Os0u(m5Lcf7h8ndmn(eSIfQ)gwmFqmCXKG2)JnPCPhamd8xdj1cgxDiJvsjERiPZF0jMl5)Ip5klpivpyb9ZckW54gWkMfXvwEqQEax6NvH)tv)fS0o838C1L(BbKNBgy5YxfukngyQkcfa0WXlEPiKLbxMDnuQu21qPv3cip3SDnXLVkOeJGbCwO5WXcBesOeNsO0QZ(tNJKLo0bLIq2SRHsL3Ci6(syFoUbSDujAkFM8sHI9d(MbMgFcwXc1FdlMpigUysq7)XMuU0daMb(RHKAbJRoKXkPeVvK05p6el0HYL8FXNCLLhKQhSG(zbf4CCdyh7ydT2fNHjgxgeyt6eJldcSdlsFYF05MKiEjmX4YGWa)1qiNiKXIW6PS8Gu9aU0pRIe0(FSJ7qKeXc9eHmwewpf2p4Bgqldlgxdksq7)XM8eJDStmUmiWILWjP0o838C1L(BbKNBgy5YxfukngyQkcfa0WXlEPiKLbxMDnuQu21qPv3cip3SDnXLVky76qlKKsmcgWzHMdhlSriHsCkHsRo7pDosw6qhukczZUgkvEZB6(syFoUbSDujAkFM8swax0YIYI0FdxTIfH1R0o838C1Lyz(YNpGJ04LsJbMQIqbanC8IxkczzWLzxdLkLDnuIy(YNVD9iKgVeJGbCwO5WXcBesOeNsO0QZ(tNJKLo0bLIq2SRHsL3CIUVe2NJBaBhvIMYNjVKfXvwEqQEax6NvH)tv)fS0o838C1LyrImdtxgaKLsJbMQIqbanC8IxkczzWLzxdLkLDnuIqImBxN2Lbazjgbd4SqZHJf2iKqjoLqPvN9NohjlDOdkfHSzxdLkV5X09LW(CCdy7Os0u(m5Ly6)PmfjLWXdjwgtCPD4V55Ql9AnY48hDdUiPxkngyQkcfa0WXlEPiKLbxMDnuQu21qPvAnY48hDBxVtK0lXiyaNfAoCSWgHekXPekT6S)05izPdDqPiKn7AOu5nlU6(syFoUbSDujAkFM8sm9)uMIKs44HeljIlTd)npxDPfWGBClukngyQkcfa0WXlEPiKLbxMDnuQu21qPKbgCJBHsmcgWzHMdhlSriHsCkHsRo7pDosw6qhukczZUgkvEZcXDFjSph3a2oQueYYGlZUgkvk7AOeHez2UEKlLpilLgdmvfHcaA44fVeJGbCwO5WXcBesOeNsO0QZ(tNJKLo0bL2H)MNRUelsKza3LYhKLIq2SRHsL3SGq3xc7ZXnGTJkrt5ZKxIfjYmSi9GA44SyjeL2H)MNRUelsKzyAapaukngyQkcfa0WXlEPiKLbxMDnuQu21qjcjYSDDAd4bGsmcgWzHMdhlSriHsCkHsRo7pDosw6qhukczZUgkvEZcH7(syFoUbSDujAkFM8sCuWGgqzIqglcRhRyHgx0YIIf0OBGL5RcyvSiSEIfklIRS8Gu9aU0pRc)NQ(lOy4Iwwu0a31ijtmi2NvXIW6j2FtK(VGdwx7bHHqWMCmGB4yu0U4i(yLeXjP0o838C1L0a31ijtmi2NTuAmWuvekaOHJx8srildUm7AOuPSRHsra31ijtmi2NTeJGbCwO5WXcBesOeNsO0QZ(tNJKLo0bLIq2SRHsL3SqQUVe2NJBaBhvIMYNjV0FtK(VGdwx7bHHqWMCmGB4yu0U4i(yLeXL2H)MNRU0cygSqaNL78hDLsJbMQIqbanC8IxkczzWLzxdLkLDnukzGz76Xbc4SCN)OReJGbCwO5WXcBesOeNsO0QZ(tNJKLo0bLIq2SRHsL3SW47(syFoUbSDujAkFM8s)nr6)coyDThegcbBYXcgWnCmkAxCeFSsI4s7WFZZvxIfjYmmnGhakLgdmvfHcaA44fVueYYGlZUgkvk7AOeHez2UoTb8aW21HwijLyemGZcnhowyJqcL4ucLwD2F6CKS0HoOueYMDnuQ8Mfcr3xc7ZXnGTJkfHSm4YSRHsLYUgkLmWSDn2srm5p6kLgdmvfHcaA44fVeJGbCwO5WXcBesOeNsO0QZ(tNJKLo0bL2H)MNRU0cygaPiM8hDLIq2SRHsL3SWMUVe2NJBaBhvIMYNjVKe0(FSj1cgxDiXsSskXBfjD(JUs7WFZZvxI9d(Mb0YWIX1qP0yGPQiuaqdhV4LIqwgCz21qPszxdLOp4B2UgTSDDYmUgkXiyaNfAoCSWgHekXPekT6S)05izPdDqPiKn7AOu5nlKO7lH954gW2rLOP8zYlX0)tzkskHJNCSmMyXyrImdlspOgooBihVy)nr6)coyDTheggpBiXcgWnCmkAxCeFSs44s7WFZZvxAr6tUijukngyQkcfa0WXlEPiKLbxMDnuQu21qPKj9jxKekXiyaNfAoCSWgHekXPekT6S)05izPdDqPiKn7AOu5nlmMUVe2NJBaBhvIMYNjVet)pLPiPeoEYXYyIlTd)npxDjwKiZW0aEaOuAmWuvekaOHJx8srildUm7AOuPSRHsesKz760gWdaBxh6WjPeJGbCwO5WXcBesOeNsO0QZ(tNJKLo0bLIq2SRHsL3SG4Q7lH954gW2rLIqwgCz21qPszxdLimGllLgdmvfHcaA44fVeJGbCwO5WXcBesOeNsO0QZ(tNJKLo0bL2H)MNRUelgWLLIq2SRHsLxEPXbwCrgEhvEl]] )

    storeDefault( [[SimC Vengeance: precombat]], 'actionLists', 20171112.231427, [[b4vmErLxt5uyTvMxtnvATnKFGzvzUDwzH52yLPJFGbNCLn2BTjwy051utbxzJLwySLMEHrxAV5MxovdoX41usvgBLf2CL5LtYatm3etmXiJlYmdm3idnEn1uJjxAWrNxt51ubngDP9MBZ5fvE5umErLxtvKBHjgBLrMxc51utnMCPbhDEnfDVD2zSvMlW9gDP9MBZ51ubjwASLgD551uW9gDP9MBEnvsUrwAJfgDVjNxt52BUvMxt10BKzvyY5uyTvMxt51uofwBL51uq9gDP9MBEnvqYD2CEnLBH1wz9isDUjwzUrwAUD2xW9gDP9MBI41usvgBLf2CL5LtYatm2eZnUaZmX41udHwzJTwtVzxzTvMB05LyEnvtVrMtH1wzEnvDUjwzUrwAUD2xW9gDP9MBErNx051uevMzHvhB05LqErNxEb]] )

    storeDefault( [[Wowhead: Simple]], 'actionLists', 20171112.231427, [[d0d7kaGEiGAtiQ2fK2gLQ9rPONtOzl18Pu4tukv(gbDBI6qqb2jc7vz3a7hjgLOQ(lvACqG6EqGCAqdgPmCO0bPcNsuLJjX5Ga0crQwkLyXsA5I8qiG8uuldjTokLQMieutLatMQMUWfjspgQUSQRdH2iuiBLsP0MPK2ov0hPuYxHayAqb9DeLxdfQpdfnAi6zeXjfvgMOCniiNhrwjLsXHj9BkELjymHk)XiagYqE1B7PqJHYy7pgHVvfXog9XwEFv8JGAwryPuOIsvsMqQy4ygpbXgJh7apGgG4emIYemwkqR99J(ycv(JXO3uOzbrrKJT8(Q4hb1SI9Iq0mjLX5aEiUgM0yGb8XmEcIngJJutyEreevYX4FSUwF7MquePB64i1eMqaMJDuHnmin26B3eIIixmcQtWyPaT23p6Jz8eeBmo0(GaT2gJVFGEGw77THncTpiqLnYheikJEGw77hB59vXpcQzf7fHOzskJZb8qCnmPXad4JDuHnmin25byERi2UPhPRXycv(JTThG5TIytHMLhPRXIrizcglfO1((rFmJNGyJXH2heOwF7w1usX8OhO1(EYXrQjmViccHgB59vXpcQzf7fHOzskJZb8qCnmPXad4JDuHnmin26B3QMskMFmHk)Xy0Bk0ORPKI5xmcmCcglfO1((rFmJNGyJXH2heO12y89d0d0AFp5H2heOYQy8KRXQBG8Uy2k05rpqR99JT8(Q4hb1SI9Iq0mjLX5aEiUgM0yGb8XoQWggKghitgYCXSvOZpMqL)ybitgYOqZwTcD(fJaHMGXsbATVF0hZ4ji2yCO9bbQ13UpHi2aAaOhO1((XwEFv8JGAwXEriAMKY4CapexdtAmWa(yhvyddsJT(29jeXgqdymHk)Xy0Bk0KMqeBanGfJW(emwkqR99J(ygpbXgJhB59vXpcQzf7fHOzskJZb8qCnmPXad4JDuHnmin2kIjsUgRUbY7c7g61eCmHk)XyeIjsuOzSsHwG8uOLRBOxtWfJq4emwkqR99J(ygpbXgJdTpiq9x2aG4OhO1((XwEFv8JGAwXEriAMKY4CapexdtAmWa(yhvyddsJpP7wVkpMqL)yPKofA0VkVyei4jySuGw77h9XmEcInghAFqGAfMed3ABmE0d0AFVnSr(kEaDE3dUm8I2uc5H2heO4ivJOlEF15rpqR995n2Y7RIFeuZk2lcrZKugNd4H4AysJbgWh7OcByqACTv)D9ka)Jju5pMER(tHgcRa8VyeiGtWyPaT23p6Jz8eeBmo0(Ga1kmjgU12y8OhO1(EByJ8v8a68UhCz4fTPeYdTpiqXrQgrx8(QZJEGw77ZBSL3xf)iOMvSxeIMjPmohWdX1WKgdmGp2rf2WG0y)1aPRiz)yhtOYFmcFnqsHgt2p2fJOKnbJLc0AF)OpMXtqSX4q7dc0ABm((b6bATVNCfpGoV7bxgErBwgB59vXpcQzf7fHOzskJZb8qCnmPXad4JDuHnminoqMmK5IzRqNFmHk)XcqMmKrHMTAf68uOLFjVfJOuMGXsbATVF0hZ4ji2yCO9bbATHaVRvetKqpqR99JT8(Q4hb1SI9Iq0mjLX5aEiUgM0yGb8XoQWggKgFs3TEvEmHk)XsjDk0OFvMcT8l5TyefQtWyPaT23p6Jz8eeBmESL3xf)iOMvSxeIMjPmohWdX1WKgdmGp2rf2WG0yfaGiHTgqdymHk)XoaaisyRb0awmIIKjySuGw77h9XmEcInghAFqGwBJX3pqpqR99JT8(Q4hb1SI9Iq0mjLX5aEiUgM0yGb8XoQWggKghitgYCXSvOZpMqL)ybitgYOqZwTcDEk0YNAElgrbdNGXsbATVF0hZ4ji2yCfrRwrLFOYMewKgrOiQ3qgGCfpGoV7bxgErBwipFmi0(GaT2qG31kIjsOhO1(EYXGq7dcuCKQr0fVV68OhO1(EYXGq7dcu)Lnaio6bATVpVXwEFv8JGAwXEriAMKY4CapexdtAmWa(yhvyddsJpP7wVkpMqL)yPKofA0VktHw(uZBXiki0emwkqR99J(ygpbXgJRiA1kQ8dv2KWI0icfr9gYaKR4b05Dp4YWlAZcfBZylVVk(rqnRyVientszCoGhIRHjngyaFSJkSHbPXbYKHmxmBf68Jju5pwaYKHmk0SvRqNNcT8LK3IruSpbJLc0AF)OpMXtqSX4XwEFv8JGAwXEriAMKY4CapexdtAmWa(yhvyddsJXrQgrxXibX4pMqL)yeiKQrKcnosqm(lgrr4emwkqR99J(ygpbXgJhB59vXpcQzf7fHOzskJZb8qCnmPXad4JDuHnmin2Fzdq0TcJpMqL)ye(YgGTtKcn6W4lgrbbpbJLc0AF)OpMXtqSX4q7dcu)Lna3AR(lIEGw77jhdcTpiqRTX47hOhO1((XwEFv8JGAwXEriAMKY4CapexdtAmWa(yhvyddsJdKjdzUy2k05htOYFSaKjdzuOzRwHopfA5JH5TyXyg7XHAdrG1aAaJaHekCXg]] )

    storeDefault( [[Wowhead: Complex]], 'actionLists', 20171112.231427, [[daKMqaqikQ2esQpbsHgfkLtHK8kIGQDrPHjuhtPwgs8mI00aPQRbsLTPK8nIQXreQohifSoIqyEeHY9iIAFuuoOuQfsuEirKMirexukSrqk9rIaNuj1njcPDIQwQuYtjnvkYwjcsFLiOSxO)cIbJchMQflvpgutwIlRAZc5ZsrJgLCAeVgKIMnWTfSBf)MWWvILlPNJutx01PW2bjFhLQXteeNhvSEIq08rL2pkACJMqL3dhvjmb7SUxKiyYqsfHfWLqqvsEKBasugQTo4o9rEkXB579MILI0y5uGEuv4kzjrf12Wjrm0OjKFJMqTX4DWlOmuv4kzjrf12DcGKCqfwm0gHdj4njWOUEkeypfvuhXCuBDWD6J8uI3R2YTXs3OY7HJQKkgAJWzYqI6njWyI8uqtO2y8o4fugQkCLSKOMIMnb3cleGIG9Hg1whCN(ipL49QTCBS0nQRNcb2trf1rmhvEpCuLOp9GOUWsqtOrTDNaijhudp9GOUWsqtOXe5LIMqTX4DWlOmu59Wrvsz5cAMmKb8YPrT1b3PpYtjEVAl3glDJ66PqG9uurDeZrTDNaijhuHz5cAiDGxonQkCLSKOMIMnb3cleGIG9HMA26grr2WtpiQlSe0eAB9bNm0Mj5nfUCHfcqrW(ydp9GOUWsqtOT1hCYqBMdNeXyHz5cAiDGxoTfwiafb7Je(McvyI8qpAc1gJ3bVGYqvHRKLe1u0Sj4wyHaueSp0O2UtaKKdQZdNMqJ66PqG9uurDeZrL3dhv(honHg1whCN(ipL49QTCBS0nMip0HMqTX4DWlOmu59WrfApGjJwg0SqT1b3PpYtjEVAl3glDJ66PqG9uurDeZrTDNaijhuJoas1GMfQkCLSKOs)mjttAl08Fbs0bqQg0SGupmlV2KmnzYGAMmyJjdywET5PHevD4KighWKHzsMjJTvo0XKb1mzWgtgMZKr6GpPn6aibNoFLJ9J3bVWKbxUmzezu5ylpIatsMmmtYmzinMjdQyYGkmr(vOjuBmEh8ckdvfUswsuth8jTl1V41xSF8o4fUCzlDWN0geHpPrW(X7GxO28UruKnicFsJG1yHkuBDWD6J8uI3R2YTXs3OUEkeypfvuhXCu59Wrvc9tZhzayYO1Z69e12DcGKCqfQpnFKbas9z9EIjYlhnHAJX7GxqzOQWvYsIkBMNo4tAdIWN0iy)4DWlC52nIISbr4tAeSglurnmlV280sg6qT1b3PpYtjEVAl3glDJ66PqG9uurDeZrL3dhvO9aMmK51Q38O2UtaKKdQrhaP71Q38yI8sC0eQngVdEbLHQcxjljQWS8AZtBMK3w5qh1SLo4tA7aHOaEA)4DWluNo4tAdoD(kereKK1H0e4eOU9J3bVqf1SzE6GpPnicFsJG9J3bVWLB3ikYgeHpPrWASqfQTo4o9rEkX7vB52yPBuxpfcSNIkQJyoQ8E4OAIvvWotgsaWjqDuB3jasYb1KvvWoKMaNa1Xe5HgqtO2y8o4fugQkCLSKOMo4tAJoaYRgljrm2pEh8cQTo4o9rEkX7vB52yPBuxpfcSNIkQJyoQ8E4OcThWKrJQXssedQT7eaj5GA0bqE1yjjIbtKFhJMqTX4DWlOmuv4kzjrLnZth8jTbr4tAeSF8o4fUC7grr2Gi8jncwJfQqT1b3PpYtjEVAl3glDJ66PqG9uurDeZrL3dhvO1OYHjdretgjRZKXAaGu8kb12DcGKCqnYOYbIicsY6qiaaP4vcMi)EJMqTX4DWlOmuv4kzjrnDWN0wEqmey7hVdEHlxhojqDiFEGCAZOGARdUtFKNs8E1wUnw6g11tHa7POI6iMJkVhoQn4CMmKDpGA7obqsoOEohs)EatKFtbnHAJX7GxqzOQWvYsIA6GpPnIuPtiDGquSF8o4fUCD4Ka1H85bYPnJcxUS5WjbQd5ZdKtBMuQth8jTWSCbneyWDOU9J3bVqfQTo4o9rEkX7vB52yPBuxpfcSNIkQJyoQ8E4Okd4LZKHK4d8rTDNaijhu7aVCifFGpMi)wkAc1gJ3bVGYqvHRKLe10bFsBePsNq6aHOy)4DWlC56WjbQd5ZdKtBgfUCzZHtcuhYNhiN2mPuNo4tAHz5cAiWG7qD7hVdEHkuBDWD6J8uI3R2YTXs3OUEkeypfvuhXCu59WrvsUNSyYqz)Fb12DcGKCqTCpzbHM9)fmr(n0JMqTX4DWlOmuv4kzjrnDWN02bcrb80(X7GxO2HtcuhYNhiN2Sn1SzE6GpPnicFsJG9J3bVWLB3ikYgeHpPrWASqfQTo4o9rEkX7vB52yPBuxpfcSNIkQJyoQ8E4OAIvvWotgsaWjqDMmyBtfQT7eaj5GAYQkyhstGtG6yI8BOdnHAJX7GxqzOQWvYsIAKrLJT8icmjntYsJrT1b3PpYtjEVAl3glDJ66PqG9uurDeZrL3dhvO9GoWlh12DcGKCqn6GoWlhtKFVcnHAJX7GxqzOQWvYsIA6GpPTditbsKrLJ9J3bVGARdUtFKNs8E1wUnw6g11tHa7POI6iMJkVhoQn4CMmKDpWKbBBQqTDNaijhupNdPFpGjYVLJMqTX4DWlOmuv4kzjrTBefzdp9GOUWsqtOTgluZM5Pd(K2Gi8jnc2pEh8cxUDJOiBqe(KgbRXcxUrgvo2YJiWKuIrjMkuBDWD6J8uI3R2YTXs3OUEkeypfvuhXCu59WrT9meweGNeXGA7obqsoO6ZqyraEsedMi)wIJMqTX4DWlOmuv4kzjrnDWN02bcrb80(X7GxOMnZth8jTbr4tAeSF8o4fUC7grr2Gi8jncwJfQqT1b3PpYtjEVAl3glDJ66PqG9uurDeZrL3dhvtSQc2zYqcaobQZKbBuOc12DcGKCqnzvfSdPjWjqDmr(n0aAc1gJ3bVGYqvHRKLe1UruKn80dI6clbnH2weSpuZM5Pd(K2oGmfirgvo2pEh8c1MNo4tAHz5cAiWG7qD7hVdEHAZth8jTLhedb2(X7GxOIAhojqDiFEGCAZ2u71Ke5WP1NMgeAwqerqswhs5WNa1R2pEh8cQTo4o9rEkX7vB52yPBuxpfcSNIkQJyoQ8E4O2GZzYq29atgSrHkuB3jasYb1Z5q63dyI8uIrtO2y8o4fugQkCLSKO2nIISHNEquxyjOj02IG9HAhojqDiFEGCAZ2O26G70h5PeVxTLBJLUrD9uiWEkQOoI5OY7HJQjwvb7mzibaNa1zYGnPuHA7obqsoOMSQc2H0e4eOoMipLnAc1gJ3bVGYqvHRKLev26grr2Gi8jncwJfUCnpDWN0geHpPrW(X7GxOIl3iJkhB5reyskXOeJARdUtFKNs8E1wUnw6g11tHa7POI6iMJkVhoQsklxqZKHMvc08O2UtaKKdQWSCbne6SsGMhtKNcf0eQngVdEbLHQcxjljQWS8AZtBMKHEQzZ80bFsBqe(Kgb7hVdEHl3UruKnicFsJG1yHkuBDWD6J8uI3R2YTXs3OUEkeypfvuhXCu59WrfApGjdzET6nptgSTPc12DcGKCqn6aiDVw9MhtKNIu0eQngVdEbLHQcxjljQrgvo2YJiWK0mjtjg1whCN(ipL49QTCBS0nQRNcb2trf1rmhvEpCuLKhed0intgYi5rTDNaijhulpigAiDsEmrEkqpAc1gJ3bVGYqL3dhvtSQc2zYqcaobQJARdUtFKNs8E1wUnw6g11tHa7POI6iMJA7obqsoOMSQc2H0e4eOoQkCLSKOMo4tAlpigiDGxoT9J3bVqT5Pd(K2oqikGN2pEh8cMyIQUCyIdisKEsedYdDYLJjIa]] )

    storeDefault( [[Icy Veins: Single Target]], 'actionLists', 20171112.231427, [[dWdKjaGEPIsBsQQAxqLxtOK9jvunBqZxQeUPurYNLQCBrCzv7ek7LA3q2VGgfHcdtOgNurQhlQZtGblKHRKoOaDkPQ0XqLZjvuSqOQLkslwPwojpuQe9uKLrqRtQimrcvnvs1KLY0LCrsPtd8mPs56kXgjuzRekvBMuSDPs1hLkjhwX0KQkFxQW3iKNt0Orv2Muj1jfWFrvDnPQ4EekLdrOOpjve9Bu2Cw3e2KCtbYccJe7hGKDIWicG6bFyK(O69YeLvG1YKP0d)iVXegZjIJJtioHDlwKW(zIwFgmqqNDkadzS(isKPG5cWqsRBmoRBslA2W3mEtytYnH9KlbstuwbwltfRxp4XLzmyJ1bsAk4gabLatONCjqAk9s2IkFP1Dzk9WpYBmHXCI4Infa1a5Pyktig6UmMqRBslA2W3mEtytYnjUddJsxK8mrzfyTmjgHrYxfa1tItS(x5R5q(Qfjp(QN5nQEauVWOUOlcJQbEuHtZH8tgzDLaChnB4BHr9nmQ)HrzEJQ3L81OMCbyObgg15ITWioCI6JPGBaeucmP5q(QfjptPxYwu5lTUltPh(rEJjmMtexSPaOgipftzcXq3LX6M1nPfnB4BgVjSj5Me3HHr4hLA6DtuwbwltMcUbqqjWKMd5VhLA6DtPxYwu5lTUltPh(rEJjmMtexSPaOgipftzcXq3LX6N1nPfnB4BgVjSj5Me3IsqyettyuX7HrbGqqBuatuwbwltMcUbqqjWKMfLa(mn8lENpacbTrbmLEjBrLV06UmLE4h5nMWyorCXMcGAG8umLjedDxgRpw3Kw0SHVz8MWMKBsRGhgH)tsyKyi(NWqGCFnrzfyTmvd8Ocx7jmeiJ7OzdFlmQ)HrIzy0ErJgCjVMeMALhtcK4wwnfCdGGsGPl483FsmLEjBrLV06UmLE4h5nMWyorCXMcGAG8umLjedDxgRRTUjTOzdFZ4nHnj3K4ommsRAzTamKjkRaRLjtb3aiOeysZH8VAzTamKP0lzlQ8Lw3LP0d)iVXegZjIl2uaudKNIPmHyO7YyISUjTOzdFZ4nHnj3KopfRJWOUcoGU)WiXapKXAWx91eLvG1YunWJkCBiJ1GVWD0SHVzk4gabLatfpfRd(9GdO73u6LSfv(sR7Yu6HFK3ycJ5eXfBkaQbYtXuMqm0DzSoT1nPfnB4BgVjSj5M6uVMeMALhtcKMOScSwMkwVEWJlZyWgRdKmmQ)HrIzy0ErJgCjVMeMALhtcK4wwnfCdGGsGPKxtctTYJjbstPxYwu5lTUltPh(rEJjmMtexSPaOgipftzcXq3LX6mw3Kw0SHVz8MWMKBQl5nmzyeE40U0eLvG1YuX61dECzgd2yDGKMcUbqqjWuM3WK83WPDPP0lzlQ8Lw3LP0d)iVXegZjIl2uaudKNIPmHyO7YyCXw3Kw0SHVz8MWMKBcpCApms8dkFtuwbwlt1apQWPbOKf)nKXA4oA2W3mfCdGGsGPnCANFBq5Bk9s2IkFP1Dzk9WpYBmHXCI4Infa1a5Pyktig6UmghN1nPfnB4BgVjSj5Me)NIxye1X)QjkRaRLPAGhv40auYI)gYynChnB4BMcUbqqjWu7tXJVSJ)vtPxYwu5lTUltPh(rEJjmMtexSPaOgipftzcXq3LX4eADtArZg(MXBcBsUjXD4goTBIYkWAzsZIsaU21aYGkmQZdJ6wSPGBaeucmP5WnCA3u6LSfv(sR7Yu6HFK3ycJ5eXfBkaQbYtXuMqm0DzmUUzDtArZg(MXBcBsUPUK3WKHruPaI1nrzfyTmzk4gabLatzEdtYxwkGyDtPxYwu5lTUltPh(rEJjmMtexSPaOgipftzcXq3LX46N1nPfnB4BgVjSj5McIqaEa4uagYeLvG1YKPGBaeucmnieGhaofGHmLEjBrLV06UmLE4h5nMWyorCXMcGAG8umLjedDxgJRpw3Kw0SHVz8MWMKBs8pHH6KYWi8G6MOScSwMeZWOAGhv4ApHH4VHt7sChnB4BMcUbqqjWu7jmKK)gu3u6LSfv(sR7Yu6HFK3ycJ5eXfBkaQbYtXuMqm0DzmUU26M0IMn8nJ3e2KCt68uSocJ6k4a6(nrzfyTmvd8Ocx7jme)nCAxI7OzdFZuWnackbMkEkwh87bhq3VP0lzlQ8Lw3LP0d)iVXegZjIl2uaudKNIPmHyO7YLjXFnZcSmEx2a]] )

    storeDefault( [[Icy Veins: Opener]], 'actionLists', 20171112.231427, [[dOdcgaGEGkAtavAxKsBtKu2hqvnBeZhOk3efHBlL2jG9sTBK2VG(jqrggP63GEoQgkqjnyHmCP4Gc0PakXXi05akLfsKwQqTyIA5K8qGk8uOLHsToGs1errYufXKLQPl5IIuFdfEMijxhiBefLTcuOntkUSQZtGtR00qrQVls8yr9zIy0OKdR4Kc4Ve01qr19qr0OejvVgOGXbuuBrNyeyAVXazbHrGXVuoypmcm1C6vgXSABkJgJp5d)gGTUidrrr2AzNkDgSzAJyZZ7qwW5ulKAaMZGHXG5AHuUtmGOtmMMoYK3TuJat7ncwH1cPgXSABkJfuIeY12aRfs5HrGByuTTpmIjdJ0ngFYh(naBDrgI6gdkVKTeySbwlKAm(Ciiv(CN4YyaAFZtbvgPq6nYeWoW0EJqsxykJYLby7eJPPJm5Dl1iW0EJmXRPfQAyb5l3iMvBtzSGsKqU2mes6WuOCJbLxYwcm2(AAHQgwq(YngFoeKkFUtCzm(Kp8Ba26Ime1ngG238uqLrkKExgivoXyA6itE3sncmT3iWBpF5gXSABkJfuIeY1MHqshMcLBmO8s2sGr6BpF5gJphcsLp3jUmgFYh(naBDrgI6gdq7BEkOYifsVldW0oXyA6itE3sncmT3iZorMm9BeZQTPmQbKsG2(1S5TcJa)WOuPBmO8s2sGrnNitM(ngFoeKkFUtCzm(Kp8Ba26Ime1ngG238uqLrkKExgG5oXyA6itE3sncmT3i4G1a5Hrsjt)CJywTnLXckrc5AZqiPdtHYnguEjBjWyM1a5cLjt)CJXNdbPYN7exgJp5d)gGTUidrDJbO9npfuzKcP3LbsnNymnDKjVBPgbM2BKP(uScJWu(BmIz12ugRHCAPvZQ4Lqzce21E6itE3yq5LSLaJ9pflH8u(BmgFoeKkFUtCzm(Kp8Ba26Ime1ngG238uqLrkKExgGHtmMMoYK3TuJat7nYStcJIbXzzeZQTPmM6Hr8x1sLW1cg(BeQ5eHkqCwcvpZAuswQKWiWd8cJQHCAPvZjcBhEDLaTNoYK3dJalHrGByuM1OKCUqnQjxlKoKWiWNjdJe1YG5gdkVKTeyuZjcvG4SmgFoeKkFUtCzm(Kp8Ba26Ime1ngG238uqLrkKExgam7eJPPJm5Dl1iW0EJm7KWiPJsnsUrmR2MYOXGYlzlbg1CIq5rPgj3y85qqQ85oXLX4t(WVbyRlYqu3yaAFZtbvgPq6DzaWMtmMMoYK3TuJat7nYmqkbHrqnHrfRhgfGq2(OwJywTnLrJbLxYwcmQbKsGqOgHfRlCjKTpQ1y85qqQ85oXLX4t(WVbyRlYqu3yaAFZtbvgPq6DzarDNymnDKjVBPgbM2BmiLUSwYulKAeZQTPmAmO8s2sGXHsxwlzQfsngFoeKkFUtCzm(Kp8Ba26Ime1ngG238uqLrkKExUmYuxZaIuwQlB]] )

    storeDefault( [[Icy Veins: AOE]], 'actionLists', 20171112.231427, [[d0JimaGEKGQnrOAxiABiHY(Oq9CbZgvZNc(efc9yjDBeoSk7Ks2l0UbTFGFIeedtI(nrNNICAsnyvnCuQdHK0PKQCmk15qcslKIAPOKftWYj5HiH0tPAzcX6qcktKcPPIunzPmDrxej13ekxw56OyJib2ksi2Se2oHYhrcvZdjrFwQQVJe9mHe)vQmAczucvNeP00Oq01qs4EcPghfcETqshePy0gPJU1rm0PTAc8uKPHbkmWtdfc1O7vLMDIo6SgFxyOvKs7y222riJeLYyrms0D2RQpUMc)sTeIwurSyOttn1syaPJw2iD0PgEc81qZOBDedDkyCWZIjicDVQ0St0Jd(84dMKfJ3rCHCktKdEc81aV4GVGrzISTcDvNG34ObFukbFpWBWa4Jd(QOt1FHUc1vtTeECWBC0G3MmgvaEXbFyzQH9dKrDJDxX4DkMGOo1QIovFnSp47bEdgaFCWNhFWKKqsmyYqqo4jWxd8IdEQcEbMIcscjXGjdbjdBW3dDAe0CDAc9IX7umbrOZAbjJQUasht0zn(UWqRiL2XSlrNwytxVuQqhkHdt0kcshDQHNaFn0m6whXqNImy)vWWbpRLQDj6EvPzNOhh85XhmjzRg7tTg5GNaFnWlo4lyuMiRmk1Gj4PYObVrGkaFpWBWa4Jd(84dMKesIbtgcYbpb(AGxCWtvWlWuuqsijgmziizyd(EOtJGMRttOl2G9xbdVtTuTlrN1csgvDbKoMOZA8DHHwrkTJzxIoTWMUEPuHouchMOvuq6Otn8e4RHMr36ig6uW4G38Pux)HUxvA2j6XbpvbFE8btscjXGjdb5GNaFnWBWa4fykkijKedMmeKmSbVbdGpo4RsjVjPesk2G9xbdVtTuTljvJ40Wa4ng8LGxCWxLsEtsjKSy8oftqezv0P6Va4PsWBd(EGVh60iO560e6fJ3jCk11FOZAbjJQUasht0zn(UWqRiL2XSlrNwytxVuQqhkHdt0Yir6Otn8e4RHMr36ig6uaJYe4LfGpfnWtlNRBNsJUxvA2j6XbpvbFE8btscjXGjdb5GNaFnWBWa4fykkijKedMmeKmSbVbdGpo4RsjVjPesk2G9xbdVtTuTljvJ40Wa4ng8LGxCWxLsEtsjKSy8oftqezv0P6Va4PsWBd(EGVh60iO560e6fmktDYIUu060CUUDkn6SwqYOQlG0XeDwJVlm0ksPDm7s0Pf201lLk0Hs4WeTOcKo6udpb(AOz0ToIHo1Mg4nVJaDVQ0St0JdEQc(84dMKTriH6k5GNaFnWBWa4fykkijwEesfBrYGoq2KucbFpWlo4JdEQc(84dMKesIbtgcYbpb(AG3GbWlWuuqsijgmziizydEdgaFCWxLsEtsjKuSb7VcgENAPAxsQgXPHbWBm4lbV4GVkL8MKsizX4DkMGiYQOt1FbWhn4lbFpW3dDAe0CDAc9zADc7iqN1csgvDbKoMOZA8DHHwrkTJzxIoTWMUEPuHouchMOffdPJo1WtGVgAgDRJyOBMFTbEJEW6q3Rkn7e9RMAXw3GJqVa4noAWhf0PrqZ1Pj0f4xBDTdwh6SwqYOQlG0XeDwJVlm0ksPDm7s0Pf201lLk0Hs4WeTIH0rNA4jWxdnJU1rm0n6Uue4Dk3yJUxvA2j6xn1ITUbhHEbWBC0GpkOtJGMRttO32LI6cuUXgDwlizu1fq6yIoRX3fgAfP0oMDj60cB66Lsf6qjCyIwgbKo6udpb(AOz0ToIHoDrkjLGNIZpTyd8XnZLYgFzp09QsZorpp(GjPaxkB8LKdEc81aV4Gpo4Pk4ZJpyssijgmziih8e4RbEdgaVatrbjHKyWKHGKHn4nya8XbFvk5njLqsXgS)ky4DQLQDjPAeNggaVXGVe8Id(QuYBskHKfJ3PycIiRIov)fapvcEBW3d89qNgbnxNMqpfPKu21NFAXg6SwqYOQlG0XeDwJVlm0ksPDm7s0Pf201lLk0Hs4WeTOqr6Otn8e4RHMr36ig6M5xBG3OhSoWhNc0QqcEZCPS1dDVQ0St0ZJpyswOvHStGlLnYbpb(AOtJGMRttOlWV26AhSo0zTGKrvxaPJj6SgFxyOvKs7y2LOtlSPRxkvOdLWHjAzxI0rNA4jWxdnJU1rm0n6Uue4Dk3yd(4uGwfsWBMlLTEO7vLMDIEE8btYcTkKDcCPSro4jWxdDAe0CDAc92UuuxGYn2OZAbjJQUasht0zn(UWqRiL2XSlrNwytxVuQqhkHdt0Y2gPJo1WtGVgAgDRJyOtrfDYa49uPJ6q3Rkn7e9RMAXw3GJqVa4noAWhb8Id(84dMKvrNm0v57eBKdEc81qNgbnxNMqVk6KHUqQ0rDOZAbjJQUasht0zn(UWqRiL2XSlrNwytxVuQqhkHdt0YocshDQHNaFn0m6whXqNUiLKsWtX5NwSHUxvA2j6xn1ITUbhHEbWBC0Gpc60iO560e6PiLKYU(8tl2qN1csgvDbKoMOZA8DHHwrkTJzxIoTWMUEPuHouchMOLDuq6Otn8e4RHMr36ig6uurNmaEpv6OoWh3Uh6EvPzNOxWOmrwzuQbtWBC0Gpwj4nya8XbFE8btY2iKWob(1wGCWtGVg4fh8fmktKvgLAWe8ghn4PyLGVh60iO560e6vrNm0fsLoQdDwlizu1fq6yIoRX3fgAfP0oMDj60cB66Lsf6qjCyIw2gjshDQHNaFn0m6whXq3OJqcnIbWBwNdDVQ0St0Pk4ZJpys2gHe2jWV2cKdEc81qNgbnxNMqVncjm0jOZHoRfKmQ6ciDmrN147cdTIuAhZUeDAHnD9sPcDOeomXeDJUIJHNOzmre]] )

    storeDefault( [[Icy Veins: Default]], 'actionLists', 20171112.231427, [[deZ(caGEijTjIO2fuQ9bjy2eUju0TjQDQu7LA3QA)Q0pHcdtk(njdgIHlvDqI0Xq0cfslvQSyP0YvXdHe1tbltjwhKQjsezQcAYcmDrxuiEgKuxxO2kuYMjcBhsINtQPbPyEqICzupgPVbvDAjNeHoSIRbP05HkFwj9xe8DiH2Ko0WEKzdeP4UiyX1Rr)IijwIjwKga6P6tdg6ybpA27Lgs8KKKlyVG6g8lOXa0Z0AefQozPEVrlE8gKsZs9Ah6nPdne5Nwbh4Og2JmBaLvVowMViyoRf1aqpvFAiGBJLqcSPJoRFf74EdsBlrL4mqvVowMjipRf1qhRvXhkRDOtdDSGhn79sdjEYgde)GIoP6y4vp707fhAiYpTcoWrnShz2ag98Zhda9u9PHuTUkySPkLiqHIV(Ii5lswY8fbLUiKO1qhl4rZEV0qINSXG02sujod0riim0SupbrPtdDSwfFOS2Honq8dk6KQJHx9Sbmvb7rMnqKI7IGfxVg9lcg98ZhNEJAhAiYpTcoWrnShz2GumIyaONQpnm0SqfMa)SCX6lckCrin0XcE0S3lnK4jBmiTTevIZaDeccdnl1tqu60qhRvXhkRDOtde)GIoP6y4vpBatvWEKzdeP4UiyX1Rr)IifJio9gno0qKFAfCGJAypYSbO(vbFrcNZkNga6P6tdg6ybpA27Lgs8KngK2wIkXzGocbHHML6jikDAOJ1Q4dL1o0PbIFqrNuDm8QNnGPkypYSbIuCxeS461OFrG6xf8fjCoRC60PbjXsmXI0rDAd]] )


    storeDefault( [[Havoc Primary]], 'displays', 20171112.231427, [[dWJYgaGEPkVePIDbvL8APeZukLzROhJWnPaghuvQBRqttkPDsP9k2nH9tv8tLYWus)wvpNudfLgmvPHJKdQGtt0XiPZbvvwOuSukOftILtLhkv6PGLjv16GQQMifOPcLjJQmDvUOsCvKk9mkuUoI2iQQTcvf2mQSDLQpkv03Kk8zOY3PQgjfYLHmAumEOkNePClkuDnPuDEk6Wswluv0XrQ6OgSaef1jFb)xCWzorb2OlwB0SlbikQt(c(V4azpuSQ9d4kbouxgerlPjGYu2RxNZ3pkbm3440ORBrDYxOJDnaEBCCA01TOo5l0XUgGEsejIhnIxaYEOyBDnWOumSeRXcqpjIeXRBrDYxOttaZnoon6Wkho0PJDnGM59bF5rWmSKMaAM3FG8(0eqs8cGQiKcCX2EGRC4q3GGG5DbA2WW2mGH060iSa4TXXPrhDA0XQgaVyxdOzEFSYHdD60eOfLbbbZ7cGTXAiTonclGuWtsu37geemVlGH060iSaef1jFXGGG5DbA2WW2mqaGcriRPSxDYxeB7D0ranZ7dyPja9KisKbLoeXjFradP1PrybeKJ0iEHo2wdOPqZj)zPz6(Z3fSavSQbuIvnaUyvd4IvnxanZ73TOo5l0rjaEBCCA0nq6QyxduKUcZKcfqHKJlWyH3a59XUgqzk71RZ57pmNrjqnPykG59z3xIvnqnPyQU)OsDS7lXQgWGiUICEPjqn9ltn7oBAcSl1sf5uEMyMuOakbikQt(IHPeNiq3fl2IHb4j1uZYeZKcfOc4kboeMjfkqPiNYZmqr6kdifO0eOff(V4azpuSQ9dutkMcRC4qh7oBSQbCOzGUlwSfddOPqZj)zPzIsGAsXuyLdh6y3xIvna9KisepAcEsI6ENonbS1ikGr1(t4XlRtowoZax5WHo(V4GZCIcSrxS2OzxcmkfdK3h7AGwu4)IdoZjkWgDXAJMDja3lUaSyE8cLq7XRTCU3pqnPyQHPFzQz3zJvnGz4BC8n(1r)v12Bvf)AVVXw7ynCgV12dq5KJLZK)loq2dfRA)auoeXpQu3aBBba5yxpEnQ2Fc83JxkhI4hvQlGK4f4Z)hJvT9aJfEdlXUgySWdWIvnWvoCOJDFjkbOCYXYzsJ4fGShk2wxdOzEF2D20eGEsejAykXjgrIlara82440OJMGNKOU3PJDnG5ghNgD0e8Ke19oDSRbUYHdD8FXfGfZJxOeApETLZ9(bWBJJtJoSYHdD6yxdOzEFAcEsI6ENonb0mV)aPROj4(OeOM(LPMDFjnb0mVp7(sAcOzE)HL0eG4hvQJDNnkbksxniiyExGMnmSnd02cFSafPRak0CsZGXUgGEsjrl4dPgoZjkqfyukaSyxdCLdh64)IdK9qXQ2pqr6kAcUhZKcfqHKJlarrDYxW)fxawmpEHsO941wo37hOMumv3FuPo2D2yvdSikLjIxAcOLJut0W2sS9dyUXXPr3aPRIDnqlk8FXfGfZJxOeApETLZ9(bQjftnm9ltn7(sSQbUYHdDS7SrjaXpQuh7(sucOzEF6GmvKcEsboDAcyiAIknk2(RQDOQQ2hF13yRD0V1aAM3h8LhbZa59PjqnPykG59z3zJvna9Kisep(V4azpuSQ9dyUXXPrhDA0XAC1a0tIir8OtJonb4H4kY5nW2waqo21JxJQ9Na)94LhIRiNxGI0v0viVauZYe5YLa]] )

    storeDefault( [[Vengeance Primary]], 'displays', 20171112.231427, [[dWJWgaGEPIxsa2LQq12ufIzsvvZwHhdv3ePQETQGBRknnKQStkTxXUrz)ev)urgMQQFd55KAOOQbtvz4i5GsPttYXOWXjilukwQQslMilNkpuv0tbltQ06qQWejOAQqzYiLPRYfLQUkbLNHuPUoI2irzReO2mH2oc(ivvgNQq5ZkQVtvgjbYLvA0OY4vvCse6wiv01iGopfDyjRvvi9nKk5yeSa4f1Pqmzi2bN5ydmjmm)jA7dGxuNcXKHyhO6SXA0nGRyZ7tUf)H0eqAO60XVbYlsbmNef179SOofIPJ9pWNjrr9EplQtHy6y)die5sU0iIJyGQZgl9(d8QyT9Xs3beICjxAplQtHy60eWCsuuVhw5M3th7FanhYd8uhoxBFAcO5qETKhknbu4igqv4k2CScmWvU59Az4CixGMjmSj6)LOFcclWNjrr9EcOrhRrGpX(hqZH8Wk38E60e4bPwgohYfaBI)lr)eewafJMcVoKRLHZHCb(s0pbHfaVOofI1YW5qUantyyt0paqT4QAO6uNcXIvGpMranhYdWstaHixYv4k3IFkelWxI(jiSamYxI4iMow6fqtTJHSrP5EIgixWcuXAeqkwJaZXAeWfRrUaAoK3ZI6uiMosb(mjkQ3RL0vX(hOiDfMj1gqIuumWB9PL8qX(hqAO60XVbYRDmIuGAqXvahYJNqFSgbQbfx9e9kvhpH(ynci8vSihxAcudVYuZtGpnbiO0kj1qDMyMuBaPa4f1PqS2HAMf4zVfR)BaAkn1OmXmP2avaxXMxmtQnqjPgQZmqr6k6RyBAc8GKme7avNnwJUbQbfxHvU594jWhRra3oc8S3I1)nGMAhdzJsZfPa1GIRWk38E8e6J1iGqKl5sJiJMcVoKtNMa26Ddi4LnVfdFL7J3PElNzGRCZ7jdXo4mhBGjHH5prBFGxfRL8qX(h4bjzi2bN5ydmjmm)jA7diIyxaEm5(GIPL7ZwohYlqnO4Q2HxzQ5jWhRraZyPZUc8rcq5uVLZugIDGQZgRr3auUfh9kvxlV)b(U0K7tWlBElg(shY9r5wC0RuDbu4i2JIqVXAiWaV1N2(y)d8wFaSyncCLBEpEc9rkaLt9wotI4igO6SXsV)aAoKhpb(0eqiYLCBhQz27YUa4b(mjkQ3JiJMcVoKth7FaZjrr9Eez0u41HC6y)dCLBEpzi2fGhtUpOyA5(SLZH8c8zsuuVhw5M3th7FanhYJiJMcVoKtNMaAoKxlPRiYerrkqn8ktnpH(0eqZH84j0NMaAoKxBFAcGJELQJNaFKcuKUQLHZHCbAMWWMOV)9YWcuKUcO2XGOWJ9pGqKk8heSsdN5ydubEvmal2)ax5M3tgIDGQZgRr3afPRiYeryMuBajsrXa4f1Pqmzi2fGhtUpOyA5(SLZH8cudkU6j6vQoEc8XAeONvsJLwAcOvVuJTDQp2UbmNef171s6Qy)d8GKme7cWJj3humTCF2Y5qEbQbfx1o8ktnpH(yncCLBEpEc8rkao6vQoEc9rkGMd5jG1usXOPyZ60e47o2sVX293GUmmm6(4DP7F6Ql9cO5qEGN6W5AjpuAcudkUc4qE8e4J1iGqKl5stgIDGQZgRr3aMtII69eqJow60iGqKl5stan60eG2kwKJRL3)aFxAY9j4LnVfdFPd5(OTIf54cuKUsym1fGAuMRlxc]] )

    storeDefault( [[Havoc AOE]], 'displays', 20171112.231427, [[dOJYgaGEPuVef0UueLxlL0mveMTc3ef42QshwYoP0Ef7MO9JQ8tPQHPQ8BLwhvigkQmyuvdhHdsLEgIKogfookYcvulLkyXi1YPQhsf9uWJHQNtQjQiYuHYKjKPRYfLkxffYLHCDKSrc1wPcPntW2vfFukXYuKMgkuFxkgjkQttYOrPXJiojI6wisCnQqDEk6ZQQwRIO6BisDmcwa8I4uRu8kp4mhOa9mcBcY2Uax5)rh3dxOd4l5pYjlcV1mhGjkefYDO(LVi5fapGzVGGgDolItTsDSFbiPxqqJoNfXPwPo2VaeE1B5njJVsq1gflJ)c8QKUDXsQbyIcrHe5Sio1k1zoGzVGGgDyL)hD6y)cOz3gOrD4SUDHoGMDBCPUn0bElsaSyncCL)hDUsC21hyUhdRNboqUfMXcyglPm14lGWkVaCy84dLuZJVT8(TjGMDBWk)p60zoqR0UsC21haRNZbYTWmwaLuKcVU17kXzxFahi3cZybWlItTsxjo76dm3JH1ZGaoxctE8X2amxplop(U9Db0SBdGL5amrHOqts5r4NALbCGClmJfqs9sgFL6yzCanbAmepknRZDS(GfOI1iGpwJa)XAeGowJCb0SBJZI4uRuh6aK0liOrNlLVI9lqr5lmtcuaAkbHaVfjUu3g7xa6HQD7wgBJ7ye6a1GGTa2TH7PlwJa1GGTCUV01X90fRrGjHekQXL5a1OPm1CpCzoWJsROvd1zIzsGcqhaVio1kDhQFzaNDwSohcisPjgLjMjbkaEaFj)ryMeOafTAOoZafLVyGsIYCGwPfVYduTrXAmnqniylSY)JoUhUync4rJao7SyDoeqtGgdXJsZg6a1GGTWk)p64E6I1iatuikKiYsrk86wVoZbaceUQgQ21PwzSoM0KoGTErbyUEwCE8D77cCL)hDIx5bN5afONrytq22fqesOOgNl3eba1RtE8zUEwChHhFriHIACbALw8kp4mhOa9mcBcY2UaK0liOrhdN1XAeOgeSL7OPm1CpCXAeOgeSfWUnCpCXAeGWRElVP4vEGQnkwJPbi8i89LUoxUjcaQxN84ZC9S4ocp(eEe((sxxan72anQdN1L62mh4TiXTl2VaKe7xGR8)OJ7Pl0b0SBd3dxMd4aAGknk2PFgK2WWy6KnLu)i9ughqZUnmezsRKIuYFDMdGVV01X90f6a4fXPwP4vEGQnkwJPbQbbB5oAktn3txSgbALw8kVaCy84dLuZJVT8(TjGMDBilfPWRB96mhWSxqqJoxkFf7xGA0uMAUNUmhqZUnUDHoGMDB4E6YCa89LUoUhUqhOgeSLZ9LUoUhUyncuu(YvIZU(aZ9yy9myIoXybyIsH3QJQ0WzoqbOd8QKawSFbUY)JoXR8avBuSgtduu(ISuyXmjqbOPeecGxeNALIx5fGdJhFOKAE8TL3VnbkkFbeOXG8KI9lqNSOhirzoGw9smqU9DXonGMDBCP8fzPWg6aK0liOrhw5)rNo2Vax5)rN4vEb4W4XhkPMhFB59BtaZEbbn6ilfPWRB96y)cqsVGGgDKLIu41TEDSFbOhQ2TBzSnHoatuikKiY4ReuTrXY4Vak8vcefUs(hRJdOWx5KV7BSgooatuikKiXR8avBuSgtdy2liOrhdN1XskgbyIcrHeXWzDMd8QKUu3g7xGIYxmsQUaeJYe5ZLa]] )


end

