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


    storeDefault( [[SimC Havoc: default]], 'actionLists', 20171119.041937, [[dee6paqiuPwKevTjjKrHk5uOIwLefEfku1SaqUfkuzxk1Wqrhtaldv4zOQ00qvLRHcLTHQIVjqghaQCojkY6KO08qvv3dLY(KqDqaAHqsEikvteavDruiJuIkNesQzcGYnfKDQelfqEQutfsSvbQ9s6VqmyQ6WelgOhtXKP0LvTzb1NLGrJQCAqVgaMnIBlPDR43IgoGA5c9CKMouxhLSDi13LiNhfSEjkQ5RK2pvwdOOODd8nqHalZcgMJUWybfK2TjcbgRT2aDYf61foygiOabcuM2m5xa(XbhAVi1RDdRS78LtqNMY682hwyrWAdObdZHQOOlbuu0MrJasUvrL2TjcbgRn3opxop3opwiFW751tH09hbKCRZVU68Mmj2S0SNxpfs3XlwgC(1vNNBNxmyyo751tH09hbKCRZVU68Mmj2S0SNxpfs3Xxf4qD(IDESelC8gdRhbNiw4D(1vN3KjXMLM986Pq6o(QahQZxSZZhMopNAdiiKaXmOnAjcfqY1MDE3aGqj6x)GvqTdL2GL4IuV2LeigofqcNrK51tHuTxK61UXz8oFWcH11gWybQ2JupBLeigofqcNrK51tHuacTqyD24MlUXc5dEpVEkKU)iGKBxxnzsSzPzpVEkKUJxSmSUYTyWWC2ZRNcP7pci521vtMeBwA2ZRNcP74RcCOfJLyHJ3yy9i4eXc)6QjtInln751tH0D8vbo0I5dto1gOtUqVUWbZabfGP2aDAYkAovrrXAJ6XcncoJAp5CTdL2fPETvSUWHII2mAeqYTkQ0UnriWyT5255Y5525Xc5dEB4jjfbKi2t3FeqYTo)6QZBYKyZsZ2WtskcirSNUJxSm48RRop3oVyWWC2gEssrajI909hbKCRZVU68Mmj2S0Sn8KKIase7P74RcCOoFXopwIfoEJH1JGtel8o)6QZBYKyZsZ2WtskcirSNUJVkWH68f788HPZZP2accjqmdAJwIqbKCTzN3naiuI(1pyfu7qPnyjUi1RDjbIHtbKWzeXWtskcirSNQ9IuV2noJ35dwiSUZZvao1gWybQ2JupBLeigofqcNredpjPiGeXEkaHwiSoBCZf3yH8bVn8KKIase7P7pci521vtMeBwA2gEssrajI90D8ILH1vUfdgMZ2WtskcirSNU)iGKBxxnzsSzPzB4jjfbKi2t3Xxf4qlglXchVXW6rWjIf(1vtMeBwA2gEssrajI90D8vbo0I5dto1gOtUqVUWbZabfGP2aDAYkAovrrXAJ6XcncoJAp5CTdL2fPETvSUWxffTz0iGKBvuPDBIqGXAZTZJfYh82(AoqZ(JasU15lY5nzsSzPzxpwQzeyEjfs3Xxf4qDE(788X5lY5fdgMZUESuZiW8skKU)iGKBD(IC(WSImSTpm0aXoFXopFz68f58C58C78OLiuajFxsGy4uajCgrMxpfsD(1vN3KjXMLM986Pq6o(QahQZZFNpatNNtNViNNlNNBNhTeHci57scedNciHZiIHNKueqIyp15xxDEtMeBwA2gEssrajI90D8vbouNN)opFCEo1gqqibIzqB0sekGKRn78UbaHs0V(bRGAhkTblXfPETbotcCkGeoJi1JfTxK61UXz8oFWcH1DEU4GtTbmwGQ9i1ZgWzsGtbKWzePESaqOfcRZg3yH8bVTVMd0S)iGKBlYKjXMLMD9yPMrG5LuiDhFvGdL)8POWSImSTpm0aXfZxMfXf3OLiuajFxsGy4uajCgrMxpfsxxnzsSzPzpVEkKUJVkWHY)am5SiU4gTeHci57scedNciHZiIHNKueqIypDD1KjXMLMTHNKueqIypDhFvGdL)8HtTb6Kl0RlCWmqqbyQnqNMSIMtvuuS2OESqJGZO2tox7qPDrQxBfRl8trrBgnci5wfvA3MieyS2yH8bVddJumcijt7(JasU15xxDE6XiG5WIUXWh5Gjc)a248f78mD(1vNxmyi6J85v4PoFXS58815z8opxopwiFWBdpjPigYf0Fdr(iGKBD(YW55RZZP2accjqmdAJwIqbKCTzN3naiuI(1pyfu7qPnyjUi1RnirShXkJ5AVi1RDJZ4D(GfcR78CXxo1gWybQ2JupBGeXEeRmMdqOfcRZgwiFW7WWifJasY0U)iGKBxxPhJaMdl6gdFKdMi8dyZ6QyWq0h5ZRWtlMn(Y45clKp4THNKued5c6V)iGKBld(YP2aDYf61foygiOam1gOttwrZPkkkwBupwOrWzu7jNRDO0Ui1RTI1fgtrrBgnci5wfvA3MieyS2OLiuajFdse7rSYyUZxKZZLZhMvKHTHvm(b78835dIXCEgNZJfYh8ommsXiGKmTBiYhbKCRZxgophmDEo1gqqibIzqB0sekGKRn78UbaHs0V(bRGAhkTblXfPETbotcCkGeoJiGeXEeRmMR9IuV2noJ35dwiSUZZf)4uBaJfOAps9SbCMe4uajCgrajI9iwzmhGqlewNn0sekGKVbjI9iwzmViUcZkYa)dIXyCyH8bVddJumcijt7(JasUTm4GjNAd0jxOxx4GzGGcWuBGonzfnNQOOyTr9yHgbNrTNCU2Hs7IuV2kwx4JII2mAeqYTkQ0UnriWyTXc5dEB4jjfXqUG(7pci5wNViNpmRidB7ddnqSZxSZZpMoFrop9ymCkq3aNjbjCgrm8KKIyixqFTbeesGyg0gTeHci5AZoVBaqOe9RFWkO2HsBWsCrQxBGZKaNciHZiIHNKuekocbW1ErQx7gNX78blew355IX4uBaJfOAps9SbCMe4uajCgrm8KKIqXriaoaHwiSoByH8bVn8KKIyixq)9hbKCBrHzfzyBFyObIlMFmlsmyi6J85v4PSfqBGo5c96chmdeuaMAd0PjRO5ufffRnQhl0i4mQ9KZ1ouAxK61wX6sqkkAZOraj3QOsBabHeiMbTn5qzvpsvkanAJ6XcncoJAp5CTdL2GL4IuV2AVi1Rn75qzvVZhskanAd0jxOxx4GzGGcWuBGonzfnNQOOyTzN3naiuI(1pyfu7qPDrQxBfRlaCkkAZOraj3QOs72eHaJ12KjXMLMDbsckeetMeBwA2Xxf4qDE2CEMAdiiKaXmOTrieeXGH5GqGuS2SZ7gaekr)6hScQDO0gSexK61w7fPETzxieNhqdgMJZdWGuS2aglq1EK6zR8nSYUZxobDAkRZBYKyZst51gOtUqVUWbZabfGP2aDAYkAovrrXAJ6XcncoJAp5CTdL2fPETByLDNVCc60uwN3KjXMLgfRlLjffTz0iGKBvuPDBIqGXAJfYh82(AoqZ(JasUvBabHeiMbTJSgeXGH5GqGuS2SZ7gaekr)6hScQDO0gSexK61w7fPETbI148aAWWCCEagKI1gWybQ2JupBLVHv2D(YjOttzDE7R5anLxBGo5c96chmdeuaMAd0PjRO5ufffRnQhl0i4mQ9KZ1ouAxK61UHv2D(YjOttzDE7R5ankwxcWurrBgnci5wfvAdiiKaXmODK1GigmmhecKI1g1JfAeCg1EY5AhkTblXfPET1ErQxBGynopGgmmhNhGbPyNNRaCQnGXcuThPE2kFdRS78LtqNMY68tgRcP8Ad0jxOxx4GzGGcWuBGonzfnNQOOyTzN3naiuI(1pyfu7qPDrQx7gwz35lNGonL15NmwfIIvS2a8pSWIGvuPyvba]] )

    storeDefault( [[SimC Havoc: precombat]], 'actionLists', 20171119.041937, [[duJgcaGEIsTjbyxkYRfqZwOBkL(gHStvSxQDdz)q1OKImmvv)M0qjkmyumCICqfLtjioguohrrlur1srPwmblxHhQk8uKLPk9CPAIeQmvvLjRstxYffOUm46OeBvqAZek2UQOBlYPr10iQ8DIsgPuupwuJwqDyLoPazDeQ6AOKCEIQ(Su4qOK6VekTX8NjscY8nYL9wCf5dRejYeLhCPYKj2qe2o4Z7pMimmmzo9lhMCVVMoBcmr80dCMM3NAw84msdiRjHTmnlxCf19Npy(ZuWOvicxp3eLhCPYuPnAeHjjT4kQBAMapYl5njPfxrMccD55T0HjKIatT6n0DC2eyY0ztGjzOfxrMydry7GpV)yIW(nXg6klJm09Nltpcd5aB1NqcqLfm1Q3ZMatU851FMcgTcr465MO8GlvMkTrJimLvnEvzH64mbGZ0eodRXzAcNP2iGQPlKuKyhGGoqtaAfIWfNjaCMAJaQMUqsr88eGwHiCXzcbNjetZe4rEjVPeuBshsH1oVBki0LN3shMqkcm1Q3q3XztGjtNnbMAHAt6qkS25DtSHiSDWN3Fmry)MydDLLrg6(ZLPhHHCGT6tibOYcMA17ztGjxUmjoqmllXYZDzd]] )

    storeDefault( [[SimC Havoc: normal]], 'actionLists', 20171119.041937, [[dae1xaqijOnHO6tsKKgfK4uqsRcrbEfHQyxOYWqvDmiAzsONjryAsK4AikABikOVrinoeLCocvP1jrs18quQ7jr0(iu5GKkwiHYdjvAIik0fjvzJsK6JeQQrkrsCsjWnHu7KGLss9uktLeTvsvTxWFHkdwLdlAXs6XqzYu1Lv2me(mHy0qvNwWRjjMnr3Mk7gLFJ0WrvwUqphHPRQRtkBNe(ojPZlrTEjskZhr2VudibLGrghIut(GyGjKUbMfC62xPsQGIvQ3hJgDPem1tUKyGqr(iffjsKIxo(LcYsPyrWmSyG3dgy6G9bkJauccibLGPhlRY5bXaZWIbEpyO03NYXEoEXXlJZZnwwLZ3hjs99PCSNZrDJ9AoUXYQC((qTpY7RQHabhV44LX558uvz9rEFvnei4Cu3yVMJZtvLbMo1Gm8LbtXyImeAsCX9XLpyfW8bS8PrWyu2adn1RFgfs3admH0nW0FmrgcnzFQ3hx(GPEYLedekYhPOi5dM6rq1IyJaucpy6IFyQGMQyUXEOcgAQxiDdm4bHIGsW0JLv58GyGzyXaVhmu67t5ypNJ6g71CCJLv589rIuFFkh75qmjoxs8lwMBSSkNVpu7J8(qPVc77t5ypNJ6g71CCJLv589rIuFO0hg(mkYi6RK9vSpsK6dJsLEQQmofJjYqOjXf3hx(CX5YaJOpX1xP0hQ9rEFvnei4Cu3yVMJZtvL1hQ9rEFO0xH99PCSNdXK4CjXVyzUXYQC((irQpeAXYC(HiGf((exj7Riz2hQ9rEFO0hg(mkYi6RK9vSpubtNAqg(YGHysCrnc8GvaZhWYNgbJrzdm0uV(zuiDdmWes3aR0t2NAnc8GPEYLedekYhPOi5dM6rq1IyJaucpy6IFyQGMQyUXEOcgAQxiDdm4bHsakbtpwwLZdIbMHfd8EWqPVQgceCoQBSxZXPXRpsK6RW((uo2Z5OUXEnh3yzvoFFO2h59HsFj2humCJnxye9jU(q2hQGPtnidFzWqmjUAgJPidScy(aw(0iymkBGHM61pJcPBGbMq6gyLEY(elJXuKbM6jxsmqOiFKIIKpyQhbvlIncqj8GPl(HPcAQI5g7HkyOPEH0nWGhekfqjy6XYQCEqmWmSyG3d2NYXEUQKs9Y9CJLv589rEFO0xH99PCSNZrDJ9AoUXYQC((irQVQgceCoQBSxZXPXRpu7J8(WWNrrgrFLSVIGPtnidFzWE8rQQ4erMbfdScy(aw(0iymkBGHM61pJcPBGbMq6gykXhPQ2N4lZGIbM6jxsmqOiFKIIKpyQhbvlIncqj8GPl(HPcAQI5g7HkyOPEH0nWGheitqjy6XYQCEqmWmSyG3dgcTyzomTyCSVpYUpKKzFK3hk9HrPspvvgNF5JhhHQB84IZLbgrFKDFf7JmOprW89rIuFyuQ0tvLXvLPF48jdBCX5YaJOpYUVI9rg0Niy((qfmDQbz4ldgIjRY0pWkG5dy5tJGXOSbgAQx)mkKUbgycPBGv6jRY0pWup5sIbcf5JuuK8bt9iOArSrakHhmDXpmvqtvm3ypubdn1lKUbg8GaziOem9yzvopigygwmW7btrgdzvoUQm9dNpzydmDQbz4ldMF5JhhHQB8aRaMpGLpncgJYgyOPE9ZOq6gyGjKUbgzC5JVpt1nEGPEYLedekYhPOi5dM6rq1IyJaucpy6IFyQGMQyUXEOcgAQxiDdm4bbrbLGPhlRY5bXaZWIbEpyy4ZOiJOVs2xX(iVVc77t5ypNJ6g71CCJLv589rEFf23NYXEoetIZLe)IL5glRY57J8(kSVQgceCU9PJg5HNsei404bMo1Gm8LbdXK4IAe4bRaMpGLpncgJYgyOPE9ZOq6gyGjKUbwPNSp1Ae47dfKOcM6jxsmqOiFKIIKpyQhbvlIncqj8GPl(HPcAQI5g7HkyOPEH0nWGheilqjy6XYQCEqmW0PgKHVmyiMe3IA8(aLbwbmFalFAemgLnWqt96NrH0nWatiDdSspzF6f149bkdm1tUKyGqr(iffjFWupcQweBeGs4btx8dtf0ufZn2dvWqt9cPBGbpiiEbLGPhlRY5bXaZWIbEpypverKJlJFarI99rEFO0hk9LyFqXWn2CHr0N46dzFO2hjs9HsFO0xH99PCSNZrDJ9AoUXYQC((irQVQgceCoQBSxZXPXRpu7J8(qPVc77t5yphg(KsGRkt)i4glRY57JeP(QAiqWHHpPe4QY0pconE9rIuFyuQ0tvLXHHpPe4QY0pcU4CzGr0N46Re87JeP(kSVe7dughg(KsGRkt)i4glRY57JeP((mkYEUp4gUNIZhwFKDFyuQ0tvLXHHpPe4QY0pcU4CzGr0hQ9HAFOcMo1Gm8LbdHwSmokcCp(HliLbFgdGvaZhWYNgbJrzdm0uV(zuiDdmWes3aR0AXY9rr03JF9vGug8zmaM6jxsmqOiFKIIKpyQhbvlIncqj8GPl(HPcAQI5g7HkyOPEH0nWGheqYhucMESSkNhedmdlg49GPiJHSkhxvM(HZNmSbMo1Gm8LbRkt)W5tg2aRaMpGLpncgJYgyOPE9ZOq6gyGjKUbMyY0V(iJjdBGPEYLedekYhPOi5dM6rq1IyJaucpy6IFyQGMQyUXEOcgAQxiDdm4bbKibLGPhlRY5bXaZWIbEpyFkh75Qsk1l3ZnwwLZ3h59LyFqXWn2CHr0N4kzFf7J8(qPVc77t5ypNlj(fXrrG7XpCIiZGIXnwwLZ3hjs9vyFFkh75Cu3yVMJBSSkNVpsK6RQHabNJ6g71CCA86d1(iVpu6lX(GIHBS5cJOpXvY(krFOcMo1Gm8Lb7XhPQItezgumWkG5dy5tJGXOSbgAQx)mkKUbgycPBGPeFKQAFIVmdkwFOGevWup5sIbcf5JuuK8bt9iOArSrakHhmDXpmvqtvm3ypubdn1lKUbg8GaYIGsW0JLv58GyGzyXaVhmeAXYC(HiGf((exj7Re87t80hk9v1qGGJxC8Y48CA86J8(iR(irQp(9Hky6udYWxgmetwLPFGvaZhWYNgbJrzdm0uV(zuiDdmWes3aR0twLPF9Hcsubt9KljgiuKpsrrYhm1JGQfXgbOeEW0f)WubnvXCJ9qfm0uVq6gyWdcilbOem9yzvopigygwmW7blX(GIHBS5cJOpX1hY(irQpu6lX(GIHBS5cJOpXvY(krFO2hjs9HsFFkh75QYaZJdHwSm3yzvoFFK3hcTyzo)qeWcFFIRK9vcYSpu7JeP(i2JRszAeCFyXIiXvKhwFIRp(GPtnidFzWw5HRU0bwbmFalFAemgLnWqt96NrH0nWatiDdm9kV(eBPdm1tUKyGqr(iffjFWupcQweBeGs4btx8dtf0ufZn2dvWqt9cPBGbpiGSuaLGPhlRY5bXaZWIbEpyO03NYXEo)CugUQm9JGBSSkNVpsK6RW((uo2Z5OUXEnh3yzvoFFKi1xvdbcoh1n2R54041hjs9HqlwMZpebSW3hz3xj43N4Ppu6RQHabhV44LX55041h59rw9rIuF87d1(irQVQgceCU9PJg5HNsei4IZLbgrFKDFKzFO2h59vyFkYyiRYXXJsLbMi4qqJ4QY0pC(KHnW0PgKHVmyjJfWhK5hOmWkG5dy5tJGXOSbgAQx)mkKUbgycPBGPdJfWhK5hOmWup5sIbcf5JuuK8bt9iOArSrakHhmDXpmvqtvm3ypubdn1lKUbg8GasYeucMESSkNhedmdlg49G9PCSNRkPuVCp3yzvoFFK3hk9vyFFkh75CjXViokcCp(HtezgumUXYQC((irQVc77t5ypNJ6g71CCJLv589rIuFvnei4Cu3yVMJtJxFOcMo1Gm8Lb7XhPQItezgumWkG5dy5tJGXOSbgAQx)mkKUbgycPBGPeFKQAFIVmdkwFOuevWup5sIbcf5JuuK8bt9iOArSrakHhmDXpmvqtvm3ypubdn1lKUbg8GasYqqjy6XYQCEqmWmSyG3dwH99PCSNRkPuVCp3yzvoFFK3xvdbco3(0rJ8WtjceCEQQS(iVVe7dkgUXMlmI(exj7ReGPtnidFzWE8rQQ4erMbfdScy(aw(0iymkBGHM61pJcPBGbMq6gykXhPQ2N4lZGI1hkLavWup5sIbcf5JuuK8bt9iOArSrakHhmDXpmvqtvm3ypubdn1lKUbg8GasrbLGPhlRY5bXaZWIbEpyO03NYXEo)CugUQm9JGBSSkNVpsK6RW((uo2Z5OUXEnh3yzvoFFKi1xvdbcoh1n2R54041hjs9HqlwMZpebSW3hz3xj43N4Ppu6RQHabhV44LX55041h59rw9rIuF87d1(qTpY7RW(uKXqwLJJhLkdmrWHGgXHHpPe4i(yqL1h59vyFkYyiRYXXJsLbMi4qqJ4C7Z(iVVc7trgdzvooEuQmWebhcAexvM(HZNmSbMo1Gm8LbddFsjWr8XGkdScy(aw(0iymkBGHM61pJcPBGbMq6gy6IpPe9zFmOYat9KljgiuKpsrrYhm1JGQfXgbOeEW0f)WubnvXCJ9qfm0uVq6gyWdcijlqjy6XYQCEqmWmSyG3dwH99PCSNZrDJ9AoUXYQC((iVpu67t5ypNFokdxvM(rWnwwLZ3hjs9v1qGGZTpD0ip8uIabNNQkRpubtNAqg(YGHysCrnc8GvaZhWYNgbJrzdm0uV(zuiDdmWes3aR0t2NAnc89Hsrubt9KljgiuKpsrrYhm1JGQfXgbOeEW0f)WubnvXCJ9qfm0uVq6gyWdcifVGsW0JLv58GyGPtnidFzW8Zrze4QHFGvaZhWYNgbJrzdm0uV(zuiDdmWes3aJmohLvQs0NyHFGPEYLedekYhPOi5dM6rq1IyJaucpy6IFyQGMQyUXEOcgAQxiDdm4bHI8bLGPhlRY5bXaZWIbEpyFgfzphv7jc(rwGPtnidFzWE8rQQ4erMbfdScy(aw(0iymkBGHM61pJcPBGbMq6gykXhPQ2N4lZGI1hkLcQGPEYLedekYhPOi5dM6rq1IyJaucpy6IFyQGMQyUXEOcgAQxiDdm4bHIibLGPhlRY5bXaZWIbEpyFgfzphv7jc(rwGPtnidFzWqmzvM(bwbmFalFAemgLnWqt96NrH0nWatiDdSspzvM(1hkfrfm1tUKyGqr(iffjFWupcQweBeGs4btx8dtf0ufZn2dvWqt9cPBGbpiuSiOem9yzvopigygwmW7bRW((uo2ZvLuQxUNBSSkNhmDQbz4ld2JpsvfNiYmOyGvaZhWYNgbJrzdm0uV(zuiDdmWes3atj(iv1(eFzguS(qHmrfm1tUKyGqr(iffjFWupcQweBeGs4btx8dtf0ufZn2dvWqt9cPBGbp8Gz8gwiLHsT8dugiqMIkk8aaa]] )

    storeDefault( [[SimC Havoc: cooldown]], 'actionLists', 20171119.041937, [[d0Z0gaGAckwVsi2evu7IiBJks7JGuZwsZxjDtaDBs(gi1PrzNGAVQ2nP2pIrriggi(TWJbAOkHYGrA4s4GufofH0XukNJGilKqzPuLwmrTCrEiHQNszzuvwhbrnrccMkvQjlQPR4Iuv1vvcPNrqY1LOZtL0wvc2mvy7krtJGQNJQptG5rvLrsqO)QunAaoKsO6Kuj(oi5AurCpckDyPUm0RPk6VD33GBfEZykXjuHyVmafYekye1CaL(MvGGSUYwKEyH(WobAOV5fRyZXd7dYg0BBBcjjicFt4(8DZatSI52npahwO539H3U7B(RB5kMVy3mWeRyUnHabvucmIAoGsZjuNjuri0fNqfHqNUI6rkJQqZaLqDlxXmHUUsOl7eRLROurevMwWUJiTRWPj01vcDzNyTCfLGQzdtly3rK21Oc5moHUUsOl7eRLROeunByAb7oI0oiGo47Y1oJCcvucDDLqNojahPHPW9j2ZmKq9Jq95ecv0BEiZQSX1BkCAvKkaeCg)Ml6mdSNiDthA8gWiVqNGBfE7gCRWBaXPvrQaqWz8BEXk2C8W(GSb9gKBErEuMar(D)5M4aqqpbglrfQNlFdyKHBfE7ZH9D338x3YvmFXUzGjwXCBcbcQOeye1CaLMtOotOIqOtxr9iLrvOzGsOULRyMqDMqLlD4qsHtRIubGGZ4sLfeQZeQJYKRsGLPeQhc1pcv4qiurV5HmRYgxVPWPvrQaqWz8BUOZmWEI0nDOXBaJ8cDcUv4TBWTcVbeNwfPcabNXjur2e9MxSInhpSpiBqVb5MxKhLjqKF3FUjoae0tGXsuH65Y3agz4wH3(CyH6UV5VULRy(IDZatSI52eceurjWiQ5aknNqDMqfHqfHqLlD4qceqh8D5ANrUuzbHUUsOYLoCiPWPvrQaqWzCPYccDDLqbJOMdO0skCAvKkaeCgxQZctjFW8EcvntZju)iuFqi01vcD6KaCKgMc3NypZqc1pHLqDkecvucv0BEiZQSX1BAuHCg)Ml6mdSNiDthA8gWiVqNGBfE7gCRWBWOc5m(nVyfBoEyFq2GEdYnVipktGi)U)CtCaiONaJLOc1ZLVbmYWTcV95Wc)UV5VULRy(IDZatSI52eceurjWiQ5aknNqDMqfHqLlD4qsHtRIubGGZ4sLfe66kHcgrnhqPLu40Qivai4mUuNfMs(G59eQAMMtOcnH6uie66kHoDsaosdtH7tSNziH6NWsO5YupSqtOIEZdzwLnUEdeqh8D5ANr(nx0zgypr6Mo04nGrEHob3k82n4wH3ehqhCcvSANr(nVyfBoEyFq2GEdYnVipktGi)U)CtCaiONaJLOc1ZLVbmYWTcV95Wo5UV5VULRy(IDZdzwLnUERKJ7Sbv8BUOZmWEI0nDOXBaJ8cDcUv4TBWTcVTOCKqDzqf)MxSInhpSpiBqVb5MxKhLjqKF3FUjoae0tGXsuH65Y3agz4wH3(CyNE338x3YvmFXUzGjwXCBcbcQOurmSqZjuNjuriu5shoKu40Qivai4mUucvntZjuHMq95ecDDLqNojahPHPW9j2ZmKq9JqfkieQO38qMvzJR3kIHf6BUOZmWEI0nDOXBaJ8cDcUv4TBWTcVTyXWc9nVyfBoEyFq2GEdYnVipktGi)U)CtCaiONaJLOc1ZLVbmYWTcV95ZnHa6OlRZf7Zp]] )

    storeDefault( [[SimC Havoc: demonic]], 'actionLists', 20171119.041937, [[daulraqijOnHu6tujfnkKkNcP4vujvTluzyOQoMKAzsINjH00qQIRHuv2gvsLVrinoKQQZjHkwhvsPMNeQ6EsOSpQKCqQGfsiEivOjkHWfPsSrKQ0hLq0iLqLojvQUjKANeSuQONszQePTkb2l4VqXGv5WIwmepgQMSqxwzZs0NjugnKCAQ61eQMnPUnj7gLFJy4qPLl45iz6sDDIA7eX3Psz8ujfoVK06Pskz(Ok7xvd1GuWkIvMY6gebmHunWmVYX)kUPecUR9FXPimpoyoNEj1aHk8RfTUUU4WXNEQPNkvaZWdESnyG5aE7jmkqkiudsbZfwIOxeebmdp4X2Gr3FDQhR5Wgg2mSi3yjIEX)4X7Vo1J1CkIASwwXnwIOx8pA(J2)qKll5Wgg2mSixK4g7pA)drUSKtruJ1YkUiXngyoG41(UkysgtSvkRXewhw2G5ol6XZMeaJrydm0KybzqivdmWes1aRGXeBLY6)CUoSSbZ50lPgiuHFTO18bZ5OiYb8rbsHgmhrnCXrtKm1ynGagAsuivdmObHkGuWCHLi6fbraZWdESny09xN6XAofrnwlR4glr0l(hpE)1PESMRCAmQKQxOk3yjIEX)O5pA)JU)k8Vo1J1CkIASwwXnwIOx8pE8(JU)WrLbXg1Ff7Vk)XJ3F4eIosCJXjzmXwPSgtyDyzZfMk9mQ)C1F0ZF08hT)HixwYPiQXAzfxK4g7pA(J2)O7pCuzqSr9xX(RYF0aMdiETVRcw50ycYuOaZDw0JNnjagJWgyOjXcYGqQgyGjKQbg9o9FoLPqbMZPxsnqOc)ArR5dMZrrKd4JcKcnyoIA4IJMizQXAabm0KOqQgyqdcffKcMlSerViicygEWJTbRt9ynhIMqI61CJLi6f)J2)O7Vc)Rt9ynNIOgRLvCJLi6f)JhV)qKll5ue1yTSItg7F08hT)HJkdInQ)k2FvaZbeV23vbRrfiUHrmD6LmWCNf94ztcGXiSbgAsSGmiKQbgycPAGjfvG42FfPo9sgyoNEj1aHk8RfTMpyohfroGpkqk0G5iQHloAIKPgRbeWqtIcPAGbniqpGuWCHLi6fbraZWdESnysYGpr0JdrNXHjMm8bMdiETVRcwCzJcdLBBybZDw0JNnjagJWgyOjXcYGqQgyGjKQbwrSSr9N52gwWCo9sQbcv4xlAnFWCokICaFuGuObZrudxC0ejtnwdiGHMefs1adAqG(aPG5clr0lcIaMdiETVRcw50ywqgB7jmWCNf94ztcGXiSbgAsSGmiKQbgycPAGrVt)NlbzSTNWaZ50lPgiuHFTO18bZ5OiYb8rbsHgmhrnCXrtKm1ynGagAsuivdmObbxhifmxyjIErqeWm8GhBdwtetm94Yq7lt8(pA)JU)O7VeV9sgMXMYpQ)C1F1)rZF849hD)v4FDQhR5ue1yTSIBSerV4F849hICzjNIOgRLvCYy)JM)Obmhq8AFxfSs5qvmKsmnQHXR1(yg8G5ol6XZMeaJrydm0KybzqivdmWes1aJELdv)Ju(xJA)5Uw7JzWdMZPxsnqOc)ArR5dMZrrKd4JcKcnyoIA4IJMizQXAabm0KOqQgyqdcIcsbZfwIOxeebmdp4X2Gjjd(erpoeDghMyYW3F0(hoHOJe3yCR6WGSuXfMk9mQ)C1F03F0(xH)Hti6iXngNADQibSOiuEkUWYyvWCaXR9DvWq0zCyIjdFG5ol6XZMeaJrydm0KybzqivdmWes1ateDg3FfrYWhyoNEj1aHk8RfTMpyohfroGpkqk0G5iQHloAIKPgRbeWqtIcPAGbniq)GuWCHLi6fbraZWdESnyDQhR5q0esuVMBSerV4F0(xI3EjdZyt5h1FUQy)v5pA)JU)k8Vo1J1CQKQxadPetJAyetNEjJBSerV4F849xH)1PESMtruJ1YkUXse9I)XJ3FiYLLCkIASwwXjJ9pA(J2)O7VeV9sgMXMYpQ)CvX(RO)rdyoG41(UkynQaXnmIPtVKbM7SOhpBsamgHnWqtIfKbHunWativdmPOce3(Ri1PxY(JUAAaZ50lPgiuHFTO18bZ5OiYb8rbsHgmhrnCXrtKm1ynGagAsuivdmObHIdifmxyjIErqeWm8GhBdwPCOkxCLECF)NRk2FfLpyoG41(UkyLtJOZ4aZDw0JNnjagJWgyOjXcYGqQgyGjKQbg9onIoJdmNtVKAGqf(1IwZhmNJIihWhfifAWCe1WfhnrYuJ1acyOjrHunWGgeQ5dsbZfwIOxeebmdp4X2GL4TxYWm2u(r9NR(R(pE8(RW)qKll5ItryECmZ1OhlUig16urcyrrO8uCYy)JhV)O7pQ1yqimzkU2VqLAm0dw8)C1F8)J2)qKll5uRtfjGffHYtXfMk9mQ)C1F0)F0aMdiETVRc2QomilvG5ol6XZMeaJrydm0KybzqivdmWes1aZLQ7prwQaZ50lPgiuHFTO18bZ5OiYb8rbsHgmhrnCXrtKm1ynGagAsuivdmObH6AqkyUWse9IGiGz4bp2gm6(RW)6upwZPiQXAzf3yjIEX)4X7pe5YsofrnwlR4KX(hpE)vkhQYfxPh33)v8)vu()56)JU)qKll5Wgg2mSiNm2)O9p6)pE8(J)F08hpE)HixwYPwNksalkcLNIlmv6zu)v8)rF)rZF0(xH)jjd(erpoSeI2ZedtjjGbrNXHjMm8bMdiETVRcwYyEuED2Ecdm3zrpE2KaymcBGHMelidcPAGbMqQgyoWyEuED2EcdmNtVKAGqf(1IwZhmNJIihWhfifAWCe1WfhnrYuJ1acyOjrHunWGgeQRasbZfwIOxeebmdp4X2G1PESMdrtir9AUXse9I)r7F09xH)1PESMtLu9cyiLyAudJy60lzCJLi6f)JhV)k8Vo1J1CkIASwwXnwIOx8pE8(drUSKtruJ1YkozS)rdyoG41(UkynQaXnmIPtVKbM7SOhpBsamgHnWqtIfKbHunWativdmPOce3(Ri1PxY(JUk0aMZPxsnqOc)ArR5dMZrrKd4JcKcnyoIA4IJMizQXAabm0KOqQgyqdc1ffKcMlSerViicygEWJTbJU)k8Vo1J1CkIASwwXnwIOx8pE8(drUSKtruJ1YkozS)XJ3FLYHQCXv6X99Ff)FfL)FU()O7pe5YsoSHHndlYjJ9pA)J()JhV)4)hn)rZF0(xH)jjd(erpoSeI2ZedtjjGbhvsOWq1bV47pA)RW)KKbFIOhhwcr7zIHPKeWOwN)r7Ff(NKm4te94WsiAptmmLKageDghMyYWhyoG41(Uky4OscfgQo4fFG5ol6XZMeaJrydm0KybzqivdmWes1aZrujH6pRdEXhyoNEj1aHk8RfTMpyohfroGpkqk0G5iQHloAIKPgRbeWqtIcPAGbniutpGuWCHLi6fbraZWdESnyf(xN6XAofrnwlR4glr0l(hT)r3FiYLLCQ1PIeWIIq5P4Ie3y)XJ3FDQhR5Itryyq0zCuCJLi6f)JM)O9p6(dhvgeBu)vS)Q8hnG5aIx77QGvonMGmfkWCNf94ztcGXiSbgAsSGmiKQbgycPAGrVt)Ntzku)rxnnG5C6LudeQWVw0A(G5Cue5a(OaPqdMJOgU4OjsMASgqadnjkKQbg0Gqn9bsbZfwIOxeebmhq8AFxfS4uegfgeFpWCNf94ztcGXiSbgAsSGmiKQbgycPAGvetryUMu)jIVhyoNEj1aHk8RfTMpyohfroGpkqk0G5iQHloAIKPgRbeWqtIcPAGbniu76aPG5clr0lcIaMHh8yBW6mi2AoICt5JJ(bZbeV23vbRrfiUHrmD6LmWCNf94ztcGXiSbgAsSGmiKQbgycPAGjfvG42FfPo9s2F0vuAaZ50lPgiuHFTO18bZ5OiYb8rbsHgmhrnCXrtKm1ynGagAsuivdmOHgmd7W9P27ALTNWab6turHgaa]] )

    storeDefault( [[Red Vengeance: precombat]], 'actionLists', 20171119.041937, [[dqJ2baGEurTlkPTjvSpOcZg0TPs7uP2lz3q2VImmk1VLYGLQgUcDqk4BuuhdLZbvYcPqlfkTyHSCQ6ZqXtv9yL8CQyIqfnvfmzbMoWfLkDyrpJICDubBevOTIkYMvuBhvXhHQY5fQMgQuFhvPtlzzcA0cLXbvQtsjwhufxdQs3dQQEnQKlJ8xuvlMg03PlPJLcM65eHWqjAr4zQF0tRMBuc0)YxJaDDSeKshs7qBMzgJHlR2CZ4omu)J0QsyX5eunK24f3mDdlq1qoAqBMg07IYiifiJ670L0FHPGt9T5PEoctxshlbP0H0o0M1Hz2QTjMUfuqTsqZRJAis)lFnc01nevWcex3PWuq(Tz(ZW0Leq7qnO3fLrqkqg13PlPBbntEucN6pWxCr6yjiLoK2H2SomZwTnX0TGcQvcAEDudr6F5RrG(kw6Xqo4a)mDdrfSaX1l0m5rjKVdWxCrcOTjnO3fLrqkqg13PlPpeZ34DQhFWS4H0XsqkDiTdTzDyMTABIPBbfuRe086OgI0)YxJaDDdrfSaX1bX8nE5JbMfpKacOJtAo5aeiJciba]] )

    storeDefault( [[Red Vengeance: default]], 'actionLists', 20171119.041937, [[diuamaqisj1MGqJIuXPivAvQIK2LKgMioMQAzKQEMQutdsvUgQOTbr(gKyCKsY5GujRJuIMhQW9uLSpsP(hPeCqiyHqupesLAIqQOlIszJcjojK0kHuHUjKQANOQFQkszOQIelvK6PunviLRQks1wvfXxjLq7f5VqzWKIdtzXO4XIAYsCzWMv0NfIrlK60eVwiPzl1THQDRYVjz4c1Yf8CfMUsxhLSDrY3vf15vfwpKky(OuTFuPPpHg58goqEAOWvZtGlcyxg0sUAkW0y1l5EoiXl5KNgAWgaXRp5JY))rx1e07JE61tUhdzXAbDWwrDepNA1NCeYROUbHgX)j0ih9vLNybEdhiN1aWgsePXutSzB4a5EoiXl56Swd3wNTHdy5GnIUcNX0qbXcWWAoRdjI0yQj2SnCOgaCtUbhV(6Yo76O1R1WT1zB4awoyJORWzmnu0LC2oJPHcHm5iWiTSpipLfeJPbYr9ks2wvG8tDa5PHgSbq86t(i9rPM8(toVHdK)0haxnUerAUAutUAIsB4GwGwIxpHg5OVQ8elWB4a5pBYInvbS4GOcY(aZyKwwbgK75GeVKRtwP6I65Rk44Q2wrDygRGvdaUj3GJKkNigBYvlWuYYQ9RpN6Yo76Swd3wNqZ0wbQWzmnuqmRuDr98vNqZ0wbQba3KBWrsLteJn5Qfykzz1(vSjhwbMswwSwWLvx2zxN1A426eAmiWkEf1vHZyAOGywP6I65RoHgdcSIxrD1aGBYn4iPYPUSZUoPSGymnuznaSHerAm1eB2goGOLxjfGbhGlWq7x6rmRuDr98vhsePXutSzB4qna4MCdosQCQl7SRt0G1B01yiKHB54vXUiqaBJoaJOvDbXSs1f1ZxDcnwbszJ1wrD1aGBYn4iPYjIXMC1mRqaUv7xVt0LC2oJPHcHm5iWiTSpipLfeJPbYr9ks2wvG8tDa58goqUw0KLRMPkWvZtjiQGSp4QbbgPLvGHwG80qd2aiE9jFK(OutE)PL4FtOroBNX0qHqMCphK4L8vfjsdvwdaRat4gskyqEAObBaeV(KpsFuQjV)KJaJ0Y(G8S1nMLxrDyTmwYr9ks2wvG8tDa58goqo6eMWnKuWGC0xv4nCG80qHRMNaxeWUmOLC1uGjCdjfmOL4rpcnYz7mMgkeYKZB4a5UIvZvd6UblfqEAObBaeV(KpsFuQjV)KJ6vKSTQa5N6aY9CqIxYJn5QzwHaCR2VqkbrgwZzDOy1yZGfbhUDuhRLJ6tLtoEfny9gDTatjllwCEjhbgPL9b5dfRgl3GLcOL45KqJC2oJPHcHm5EoiXl5R1WT1rSeKfJrHZuHZyAOGybyynN1zWKEFudaUj3GdorKH1Cwhkwn2myrWHBh1XA5OQ9Rp5PHgSbq86t(i9rPM8(toQxrY2QcKFQdihbgPL9b5JyjilgJcNHCEdhi3JLGSC1GScNHwIhjcnYz7mMgkeYK75GeVKhBYvlWuYYQ9RpNKNgAWgaXRp5J0hLAY7p5OEfjBRkq(PoGCeyKw2hKl44Q2wrDygRGroVHdKJkoUQTvuhxniWky0s8OqOroBNX0qHqMCphK4LClVskadoaxGH2V0JybyynN1HerAm1eB2goudaUj3GJxFYtdnydG41N8r6Jsn59NCuVIKTvfi)uhqocmsl7dYhsePXutSzB4a58goqUlrKMRg1KRMO0goqlXRveAKZ2zmnuiKj3ZbjEjFTgUToHMPTcuHZyAOGySjxTatjlR2VIn5WkWuYYI1cUSKNgAWgaXRp5J0hLAY7p5OEfjBRkq(PoGCeyKw2hKpHMPTcqoVHdKhfOzARa0s8OlcnYz7mMgkeYKZB4a5pT5eUHKcgK75GeVKVQirAOMvQUOE(gKNgAWgaXRp5J0hLAY7p5OEfjBRkq(PoGCeyKw2hKNTUXS8kQdRLXso6Rk8goqEAOWvZtGlcyxg0sUAuZjCdjfmOL4)jeAKZ2zmnuiKj3ZbjEj3YRKcWGdWfy86J4AnCBDgS8Ykav4mMgkigBYvlWuYYYrSjhwbMswwSwWLL80qd2aiE9jFK(OutE)jh1RizBvbYp1bKJaJ0Y(G8zWYlRaqoVHdKhLGLxwbGwI))j0iNTZyAOqitUNds8sEbyynN1HerAm1eB2goudaUj3GJxFYtdnydG41N8r6Jsn59NCuVIKTvfi)uhqocmsl7dYhsePXutSzB4a58goqUlrKMRg1KRMO0goWvJoFDPL4)6j0iNTZyAOqitUNds8sUoA9AnCBDgS8Ykav4mMgkSZULxjfGbhGlWq7x61fXytUAbMswwoIn5WkWuYYI1cUSKNgAWgaXRp5J0hLAY7p5OEfjBRkq(PoGCeyKw2hKpuSASCdwkGCEdhi3vSAUAq3nyPaUA05RlTe))nHg5SDgtdfczY9CqIxYxRHBRtOXGaR4vuxfoJPHc5PHgSbq86t(i9rPM8(toQxrY2QcKFQdihbgPL9b5tOXGaR4vuh58goqEuGMRg2cSIxrD0s8F0JqJC2oJPHcHm5EoiXl5PSGymnuznaSHerAm1eB2goGOozLQlQNVQCtiCwJn2GevOMJ2crGb2my5vuN1A)6x1kozNDlVskadoaxGH2V0Rlx0rYtdnydG41N8r6Jsn59NCuVIKTvfi)uhqocmsl7dYLBcHZASXgKOcKZB4a5OEtiCwZvJVbjQaTe)NtcnYz7mMgkeYKZB4a5E0Gf4QrNVUKNgAWgaXRp5J0hLAY7p5OEfjBRkq(PoGCphK4LCToLfeJPH6ZMSYfbBQcyXbrfK9bMXiTScmihbgPL9b5JOblqlTKJoHPXQxczAjc]] )

    storeDefault( [[Red Vengeance: defensives]], 'actionLists', 20171119.041937, [[dSt5iaGErjQnPQAxuABQsTpvbZgvZxusUPOe8nrvRtviTtkSxKDlz)Ounkrj1Wiv)MWTjLhlvdgLy4O4GQIoLOuCmOCorP0cLIwQQslgILR0dvfINs1YefpxKjQkutvvYKjz6kUikL7bvDzW1LsBuuQ2QOezZez7IkDAvMMOcFgL08KchxucnorfnAi9xk6KqL(ouX1ikopr1ZuvCyHxtuAcJErUrObK)fuSZswckwHO6WJYolkqcQ0LlKi377XmKt(xGdrciJm6y5XWWYwREoWYrMmK7mq)c(LLJ5efzitoXi)zForLOxKbg9IC2QaHdkQj5gHgqUlA5SZYJeBUWs(xGdrciJm6yVXYB1)GroUL66XiwYlrbK799ygYHSy7XWakBWvB0rptCIfHhki9JcbFqTmW2HAAGpVm)iTss2KOLBkTbRAqnjBAIUS41)vasRKKv6GvUjYgLYUGwCvcVo5pro(nYjpjA5M9yZfwAiJm0lYzRceoOOMKBeAa5pg0ef7S4mNSqI8VahIeqgz0XEJL3Q)bJCCl11JrSKxIci377XmK3rJLvizkTrForf8hWJzZlZpsRKKvbAIYmXCYcj7cAXvj86)kaPvsYkDWk3ezJszxqlUkHx)NjUY2B3fQ5b8z0)rHGpOwgy7qnnWNtzi)jYXVro5kqtuMjMtwirdz8HEroBvGWbf1KCJqdip7hSYzNLMBukY)cCisazKrh7nwER(hmYXTuxpgXsEjkGCVVhZqoke8b1YaBhQPb(CkZpsRKKvbAIYmXCYcjRsGt9J0kjz1Gj0eldQiDjRsGt9J0kjztIwUjsS7bRvjWP(7cbxjWPSkqtuMjMtwiz7OXYkKAGr(tKJFJCYLoyLBISrPOHmYb9IC2QaHdkQj5EFpMHCui4dQLb2outd8YiZ)eCOgReWnvqUrAI5eLfQaHdQFM4kBVDxOMhW)rN8VahIeqgz0XEJL3Q)bJCCl11JrSKxIci)jYXVro5sa3ub5gPjMtuKBeAa5zh4SZYJHCJ0eZjkAidzOxKZwfiCqrnj3i0aYZcWeAILbvKUe5FboejGmYOJ9glVv)dg54wQRhJyjVefqU33Jzihfc(GAzGTd10aFFV56b3CqxiHk4QSkRYAui4dQLb2outd85q)NjUY2B3fQPb(m6)DHGRe4uwPdw5MiBuk7cAXvPh0)vasRKKv6GvUjYgLYQe4u)iTsswfOjkZeZjlKSkbo1Fxi4kboLvbAIYmXCYcjBhnwwHKP0g95evWBOBLjBi)jYXVro5AWeAILbvKUenKXB6f5SvbchuutY9(Emd5OqWhuldSDOMg4vrXkSMd6cjubxr(xGdrciJm6yVXYB1)GroUL66XiwYlrbK)e543iN8KOLBIe7EWsUrObK7Iwo7S0m29GLgYip9IC2QaHdkQj5EFpMHCui4dQLb2outd8QOyfwZbDHeQGR(zIRS92DHAEa)BDY)cCisazKrh7nwER(hmYXTuxpgXsEjkG8Nih)g5KNeTCZohICbYncnGCx0YzNLhHdrUanKroPxKZwfiCqrnj377XmKJcbFqTmW2HAAGxffRWAoOlKqfC1psRKKvbAIYmXCYcjRsGt9J0kjz1Gj0eldQiDjRsGt9J0kjztIwUjsS7bRvjWPi)lWHibKrgDS3y5T6FWih3sD9yel5LOaYFIC8BKtU0bRCtKnkf5gHgqE2pyLZoln3OuSZswJLn0qgzl9IC2QaHdkQj5gHgqoUAAcEmNOyNLNTBq(xGdrciJm6yVXYB1)GroUL66XiwYlrbK799ygYrHGpOwgy7qnnWRIIvynh0fsOcU6NjUYQaPRFZd4XKH8Nih)g5KFAAcEmNOmJ2nOHmW0PxKZwfiCqrnj3i0aYZoWr4Hci)lWHibKrgDS3y5T6FWih3sD9yel5LOaY9(Emd5OqWhuldSDOMg4vrXkSMd6cjubx9pbhQXkbCeEOalubchu)mXvwfiD9BEaptCLPcKU(nM8t7gYFIC8BKtUeWr4HcOHmWWOxKZwfiCqrnj3i0aYDuiwY)cCisazKrh7nwER(hmYXTuxpgXsEjkGCVVhZqoke8b1YaBhQPbEvuScR5GUqcvWvK)e543iN8ekeln0q(JbPOLputAic]] )

    storeDefault( [[Red Vengeance: offensives]], 'actionLists', 20171119.041937, [[dOd9daGEuvQnHQSlj2gPu7JkmBsMpPQBcsLBJs7us2lYUvSFqYOGuggv63szDGu13qbdwjA4GYbrHofkYHjohQkSqjLLQewmelhQhIQIEQOLbQEovnruv1uLunzPA6cxKu0Jb6YQUoPYgrvLTIQs2SsTDqCEi50u(mPGVtk00aP8mQOrJIsJdfvojPKxdP6AOOQ7PK(lQCmahcfftauDkRe2t5I3HAjF9rdxgWd9qTST3F8gK7PmbXgSGskxC1f)Pk4UamaaaWhfxOban4WPmHDqtugFlH1gQI5zoakzemS24P6ufavNsnhbr9ovJYkH9uYp7yuqTSgwMoLlU6I)ufCxaTbyO46eGsTMUbkrdt50MtzcInybLOj4W2cyu22XO46N18VGLbDhRa8cr9jk7R46hI4djS2u(iiQ35b2AQEtJtzFfx)qeFiH1Mc(SIn(vxEWeBkG6W4pHJvNUmPxpAmtiQprzFfx)qeFiH1MYhbr9UE9coSTagLTDmkU(zn)lyzqF1LjkzeXuwGIYTDmkoeSmDkOk4uDk1Cee17unkRe2tj)UcQL8)qeFiH1gkxC1f)Pk4UaAdWqX1jaLAnDduIgMYPnNYeeBWckdr9jk7R46hI4djS2u(iiQ35btSPaQdJ)eowD6Ydn0eCyBbmkB7yuC9ZA(xWYGUJvaEcyyqo3NZA3VcWRFeD7DzBhJIdbltVGpRyJ3XkCM0Rhnbh2waJY2ogfx)SM)fSmOV6QxVaggKZ95S29owHZetuYiIPSafL7R46hI4djS2qbv5KQtPMJGOENQrzcInybLHO(efpmdBbhsJfP8rquVZtaddY5(Cw7EhRW5HOBVl(Mof3glAG9t4l(qar3XkaLjZ20i01622o2tiuU4Ql(tvWDb0gGHIRtak1A6gOenmLtBoLmIyklqrPhMHTGdPXIqzLWEktyg2cOwwRXIqbvbnQoLAocI6DQgLji2Gfus5IRU4pvb3fqBagkUobOuRPBGs0WuoT5uYiIPSafL(MofhOGHCmLvc7PmB6uqTKpfmKJPGck5)3Iovq1OGia]] )

    storeDefault( [[SimC Vengeance: default]], 'actionLists', 20171119.041937, [[d8tbpaWCcwpHkXMiu2fj2MsP9jIYJv0HPA2uA(Iu6Mc68KKBtQtRQDkQ9kTBv2VsXOermmHACIu8uKxtsnyLQgok1bvsDkHOoguDorKSqf0srjwmkworpuKSkHGLjKwhHkPjkIutvPYKPy6O6IOKEfHk1LbxNq2OivTvOuBwj2Ua(Sa9DOKMMiQMNqONPa)vHgnumEcvCsLKBjsLRrOQ7bL4qcr(Mi8Bix8URu21qj61P2ShB4cc(nbX1n7nWIlYYlL0WIlYY7WsSawWfGMJgJNahhpPuItoEYJgTenLpBEPsRN8hDcDxZ4DxjwpNXcMoSuiYGTlZUgkvk7AOuk0jisdB2h6b)zjwal4cqZrJX3INqjEaEP1mV95QknrNGinmQ9G)S0QZ8tNJKLo0bLsHbMQdrbanC8YukezYUgkvEZr7UsSEoJfmDyjAkF28smIwwumGgDJcSF1GGIbH1tmgrllkAG7AKKngKWlOyqy9kTM5TpxvPLhKQgzK(zkLcdmvhIcaA44LPuiYGTlZUgkvk7AOu6FqQAZ(Hs)mLybSGlanhngFlEcL4b4LwDMF6CKS0HoOuiYKDnuQ8Mh0DLy9Cgly6Ws0u(S5LMyCzqqalrtBAzeTSOyan6gfy)QbbfdcRNyrYG4klpivnYi9ZOW)P6)ckgJOLffnWDnsYgds4fumiSELwZ82NRQKb0OBuG9RgekLcdmvhIcaA44LPuiYGTlZUgkvk7AOusdA0TzpX(vdcLybSGlanhngFlEcL4b4LwDMF6CKS0HoOuiYKDnuQ8MtE3vI1ZzSGPdlrt5ZMxkscFW3oY26tWiwK(BCX(bXWftcA)pH0XLEaWoYFnKodyDvrmwzqemIKo)rNyUK)l(KRS8Gu1Ob0VaOaNZybJygexz5bPQrgPFgf(pv)xWsRzE7Zvv6VfqEUDuGlF1qPuyGP6quaqdhVmLcrgSDz21qPszxdLwDlG8C7M9ex(QHsSawWfGMJgJVfpHs8a8sRoZpDosw6qhukezYUgkvEZIV7kX65mwW0HLOP8zZlfjHp4BhzB9jyels)nUy)Gy4IjbT)Nq64spayh5VgsNbSUQigRmicgrsN)OtSKejxY)fFYvwEqQA0a6xauGZzSGjTPnjAxCgNyCzqqiDtmUmiimUi9j)rNBJCeKWeJldcJ8xdrCIqwdcRNYYdsvJms)mksq7)jiUfFKfljteYAqy9ue(GVDeTmUyDnOibT)NqYsK20oX4YGGawIg5sRzE7Zvv6VfqEUDuGlF1qPuyGP6quaqdhVmLcrgSDz21qPszxdLwDlG8C7M9ex(QHn7tcEKlXcybxaAoAm(w8ekXdWlT6m)05izPdDqPqKj7AOu5nVT7kX65mwW0HLOP8zZlzagrllkls)TCvkgewVsRzE7ZvvsG9lF(idsZukfgyQoefa0WXltPqKbBxMDnuQu21qjI9lF(M9drAMsSawWfGMJgJVfpHs8a8sRoZpDosw6qhukezYUgkvEZj6UsSEoJfmDyjAkF28sgexz5bPQrgPFgf(pv)xWsRzE7ZvvsajYooDzaqwkfgyQoefa0WXltPqKbBxMDnuQu21qjcjYUzFkxgaKLybSGlanhngFlEcL4b4LwDMF6CKS0HoOuiYKDnuQ8Mtt3vI1ZzSGPdlrt5ZMxIT)NYuKuchpIyjnXLwZ82NRQ0R1iRZF0n6IKEPuyGP6quaqdhVmLcrgSDz21qPszxdLwP1iRZF0Tz)ArsVelGfCbO5OX4BXtOepaV0QZ8tNJKLo0bLcrMSRHsL3Cs1DLy9Cgly6Ws0u(S5Ly7)PmfjLWXJiwsexAnZBFUQslGLX6gOukmWuDikaOHJxMsHid2Um7AOuPSRHsPhSmw3aLybSGlanhngFlEcL4b4LwDMF6CKS0HoOuiYKDnuQ8MXJ7UsSEoJfmDyPqKbBxMDnuQu21qjcjYUz)qxkFqwIfWcUa0C0y8T4juIhGxAnZBFUQscir2rgxkFqwA1z(PZrYsh6GsPWat1HOaGgoEzkfImzxdLkVzC8UReRNZybthwIMYNnVKasKDCr6b1WXfWI4lTM5TpxvjbKi740cEaOukmWuDikaOHJxMsHid2Um7AOuPSRHsesKDZ(uwWdaLybSGlanhngFlEcL4b4LwDMF6CKS0HoOuiYKDnuQ8MXJ2DLy9Cgly6Ws0u(S5L4OGbTGYeHSgewpbXscJOLffdOr3Oa7xniOyqy9elsgexz5bPQrgPFgf(pv)xqXyeTSOObURrs2yqcVGIbH1tS)Mi9FbhnU2dcJIxizya3YXOODXjcXkjIJCP1mV95QkPbURrs2yqcVqPuyGP6quaqdhVmLcrgSDz21qPszxdLcbURrs2yqcVqjwal4cqZrJX3INqjEaEPvN5NohjlDOdkfImzxdLkVz8bDxjwpNXcMoSenLpBEP)Mi9FbhnU2dcJIxizya3YXOODXjcXkjIlTM5TpxvPfWoAGaUa35p6kLcdmvhIcaA44LPuiYGTlZUgkvk7AOu6b7M9jneWf4o)rxjwal4cqZrJX3INqjEaEPvN5NohjlDOdkfImzxdLkVz8K3DLy9Cgly6Ws0u(S5L(BI0)fC04ApimkEHKHfmGB5yu0U4eHyLeXLwZ82NRQKasKDCAbpaukfgyQoefa0WXltPqKbBxMDnuQu21qjcjYUzFkl4bGn7tcEKlXcybxaAoAm(w8ekXdWlT6m)05izPdDqPqKj7AOu5nJl(UReRNZybthwkezW2LzxdLkLDnuk9GDZEwLIyZF0vIfWcUa0C0y8T4juIhGxAnZBFUQslGDeKIyZF0vA1z(PZrYsh6GsPWat1HOaGgoEzkfImzxdLkVz8TDxjwpNXcMoSenLpBEjjO9)esNbSUQiILyLbrWis68hDLwZ82NRQKWh8TJOLXfRRHsPWat1HOaGgoEzkfImy7YSRHsLYUgkrFW3UzpAzZ(0BDnuIfWcUa0C0y8T4juIhGxA1z(PZrYsh6GsHit21qPYBgpr3vI1ZzSGPdlrt5ZMxIT)NYuKuchpzyjnXIjGezhxKEqnCCHiMCX(BI0)fC04ApimMCHiIfmGB5yu0U4eHyLOXLwZ82NRQ0I0NCrsOukmWuDikaOHJxMsHid2Um7AOuPSRHsPx6tUijuIfWcUa0C0y8T4juIhGxA1z(PZrYsh6GsHit21qPYBgpnDxjwpNXcMoSenLpBEj2(FktrsjC8KHL0exAnZBFUQscir2XPf8aqPuyGP6quaqdhVmLcrgSDz21qPszxdLiKi7M9PSGha2SpjrJCjwal4cqZrJX3INqjEaEPvN5NohjlDOdkfImzxdLkVz8KQ7kX65mwW0HLcrgSDz21qPszxdLimGllXcybxaAoAm(w8ekXdWlTM5TpxvjbmGllT6m)05izPdDqPuyGP6quaqdhVmLcrMSRHsLxEjInmF3(Ilo)rxZIpn4L3ca]] )

    storeDefault( [[SimC Vengeance: precombat]], 'actionLists', 20171119.041937, [[b4vmErLxt5uyTvMxtnvATnKFGzvzUDwzH52yLPJFGbNCLn2BTjwy051uevMzHvhB05LqEnLuLXwzHnxzE5KmWeZnXetm54cm0ednYiJxtn1yYLgC051uEnvqJrxAV52CErLxofJxu51uf5wyIXwzK5LqEn1uJjxAWrNxtr3BNDgBL5cCVrxAV52CEnvqILgBPrxEEnfCVrxAV5MxtLKBKL2yHr3BY51uU9MBL51un9gzwfMCofwBL51uEnLtH1wzEnfuVrxAV5MxtfKCNnNxt5wyTvwpIuNBIvMBKLMBN9fCVrxAV5MiEnLuLXwzHnxzE5KmWeJnXCJlWmtmEn1qOv2yR10B2vwBL5gDEjMxt10BK5uyTvMxtvNBIvMBKLMBN9fCVrxAV5Mx05fDEn1uWv2yPfgBPPxy0L2BU5Lt1GtmErNxEb]] )


    storeDefault( [[Havoc Primary]], 'displays', 20171119.041937, [[dWJYgaGEPsVKuWUGQIETIWmLs1Sv4XiCtKkoosvFtr00iLANuAVIDty)uf)uPmmL04GQsoSKHIsdMQ0WrYbLQonjhJOohPqlukwkPKftKLtLhkv8uWYuKwhuv1eLsyQqzYOktxLlQexfPsxgY1r0grvTvOQuBgv2Us1hLs55u8zOY3PQgjPONbvvgnkgpuLtIuULuIUMusNNu9BvTwOQWTvuh5GfGOOo1l4)Ido9bkWgDXANMDjarrDQxW)fhO6IIvEAaxjWH6WGiMinbKgQUDBB8(rkG(ghNbDDkQt9ctSRbWBJJZGUof1PEHj21a0tIir8Or8cq1ffR2RbMvI(LyXVa0tIir86uuN6fM0eqFJJZGoSYHdDMyxdyyEFWxDem9lPjGH597jVpnbmmVp4RocMEY7ttGRC4qxVGG5DbA2WW2OJw0AttSa4TXXzqNgAmXkhqFJJZGon0yITLYbmmVpw5WHotAcmHuVGG5DbW2y1IwBAIfqj4PiQ7D9ccM3fqlATPjwaII6uVOxqW8UanByyB0jaqHiu1q1To1lIT1jNmGH59bS0eGEsejQfkhI4uViGw0AttSacYzAeVWeR2bmuOXG)OmmD(X7cwGkw5aUyLdGlw5asXkNlGH597uuN6fMifaVnood66jDvSRbksxHPtHcirYXfyUWRN8(yxdinuD722497hJifOgumfW8(S7lXkhOgumvNFwQo29LyLd0cexroU0eOg(LUHDNnnb2vgLKAOoDmDkuaPaef1PEr)qHteOZIfBrRa8ugQrPJPtHcubCLahctNcfOKud1PhOiDfDucuAcmHe)xCGQlkw5PbQbftHvoCOJDNnw5ao0iqNfl2IwbmuOXG)OmmrkqnOykSYHdDS7lXkhGEsejIhnbpfrDVZKMa2AgfqZA)j84L1PMlNEGRC4qh)xCWPpqb2Olw70Slb4H4kYX1Z2Eaqn3XJxnR9Na)94LhIRihxGjK4)Ido9bkWgDXANMDja3lUaSyE8cLW4XRTCU3pqnOyQ(HFPBy3zJvoGE43s8LgNC6QCRAlRXwNIFRtUgUwQDRbOCQ5YPZ)fhO6IIvEAakhI4NLQRNT9aGAUJhVAw7pb(7XlLdr8Zs1fOgumfW8(S7SXkhyUWRFj21aZfEawSYbUYHdDS7lrkGH59z3zttaTqduzqXoDvEszzznIpx1ww7PtdyyEFnG0LucEkbotAcq8Zs1XUVePax5WHo2D2ifOgumv)WV0nS7lXkhycj(V4cWI5XlucJhV2Y5E)agM3NMGNIOU3zsta9nood66jDvSRbQHFPBy3xstadZ73VKMagM3NDFjnbi(zP6y3zJuGI0v9ccM3fOzddBJoTVWhlqnOyQo)SuDS7SXkhGEsfXe4BLbo9bkqfywjaSyxdCLdh64)IduDrXkpnqr6kAcUhtNcfqIKJlarrDQxW)fxawmpEHsy841wo37hOiDfqHgdATi21alIsAG4LMag1m1a1VTe70agM3VN0v0eCFKcG3ghNbDyLdh6mXUg4kho0X)fxawmpEHsy841wo37hqFJJZGoAcEkI6ENj21a4TXXzqhnbpfrDVZe7Aa6jrKO(HcNygjUaebOCQ5YPtJ4fGQlkwTxdOiEbqvekbUyBnGI4f4J)NJvU1a0tIir84)IduDrXkpnaEXUgGEsejINgAmPjWSs0tEFSRbksxrxH6cqnkDKlxc]] )

    storeDefault( [[Vengeance Primary]], 'displays', 20171119.041937, [[d0JWgaGEPIxsaTlckTnKkQzsvvpgQMTchNGCtcKPjvQVHuroSKDsP9k2nk7Nc9tf1Wuv9BiNMKHIkdMQYWrYbLspNuhJOohsfAHsXsvvSyISCQ8qvHNcwMQO1rqXejOAQqzYi00v5IsvxLaCzLUoI2ifSvcuBMqBhP8rPsEnvv(SI8DQYirQQNHujgnQA8QkDseClKk11qQY5POXHujTwKk42Qsh5GfaVOofIzaXo4mhBGzbG5pbBFa8I6uiMbe7avNnw5NbCfBAFWV4(LMasdvNoDnqErkG5SOOEVhf1PqmDS)b(olkQ37rrDketh7FaHixYLibCeduD2y7(pWRI12hlDjGqKl5s8rrDketNMaMZII69Wk30E6y)dO5rEGN6W5B7ttanpYRL8qPjGMh5bEQdNVL8qPjWvUP9Az48ixGMzmSzb9Hqx0hlW3zrr9EcSrhRCaZzrr9EcSrhlDlhqZJ8Wk30E60eWpPwgopYfaBM7dHUOpwafJOcVoKRLHZJCb(qOl6JfaVOofI1YW5rUanZyyZckaqT4QAO6uNcXILE0v5aAEKhGLMacrUKRWvUf)uiwGpe6I(ybyKVeWrmDSDhqtTJHHrP5FGgixWcuXkhWfRCGPyLdifRCUaAEK3JI6uiMosb(olkQ3RL0vX(hOiDfMj1gqIuumWB9TL8qX(hqAO60PRbYRDmIuGAqXxapYJJwFSYbQbfF9a9kvhhT(yLdi8vSihxAcudVYuZrJlnbOP0kj1qDMyMuBaPa4f1PqS2HAIf4rVfR)taIkn1OmXmP2avaxXMwmtQnqjPgQZmqr6kbPyBAc4NKbe7avNnw5NbQbfFHvUP94OXfRCa3oc8O3I1)jGMAhddJsZhPa1GIVWk30EC06JvoGqKl5sKaJOcVoKtNMa26Ddi4LnTfdFn6JZPElNzGRCt7zaXo4mhBGzbG5pbBFaIRyroUwo)d8zjA0NGx20wm8vym6J4kwKJlGFsgqSdoZXgyway(tW2hqeXUaCyg9bftB0NTCoKxGAqXxTdVYuZrJlw5aMXs3pPhDoaLt9wotdi2bQoBSYpdq5wC0RuDTC(h4Zs0OpbVSPTy4RWy0hLBXrVs1fOgu8fWJ84OXfRCG36BBFS)bERVawSYbUYnThhT(ifqZJ84OXLMaF2Xw6n2N)Y0jzzz6OW(3TC3pFgqZJ8e4AkPyevSjDAcGJELQJJwFKcCLBApoACrkqnO4R2HxzQ5O1hRCa)KmGyxaomJ(GIPn6ZwohYlGMh5rGruHxhYPttaZzrr9ETKUk2)a1WRm1C06ttanpYRTpnb08ipoA9Pjao6vQooACrkqr6QwgopYfOzgdBwq(3BalqnO4RhOxP64OXfRCaHiv4(jyLgoZXgOc8QyawS)bUYnTNbe7avNnw5NbksxrGjIWmP2asKIIbWlQtHygqSlahMrFqX0g9zlNd5fOiDfqTJbbHh7FGEwjnwIPjGw9sn225(yFgqZJ8AjDfbMiksb(olkQ3dRCt7PJ9pWvUP9mGyxaomJ(GIPn6ZwohYlG5SOOEpcmIk86qoDS)b(olkQ3JaJOcVoKth7FaHixYTDOMyVl7cGhGYPElNjbCeduD2y7(pGchXaQcxXMILEbu4igDaHEJvMEbeICjxIgqSduD2yLFg4BS)beICjxIcSrNMaVkwl5HI9pqr6kbWuxaQrzUUCj]] )

    storeDefault( [[Havoc AOE]], 'displays', 20171119.041937, [[dSJXgaGEPuVeLk7cLGETusZukYSv4MOK6Ws(MuOUnuzNuAVIDty)ePFkvnmi53Q6zOeQHIQgmrmCKCqQ4ZqvhJIohkHSqfzPsblgPwov9qfLNcEmcRdLOMOIQMkuMmfmDLUOu5QOKCzvUoI2ifAROu1MrLTdrFukXPj10uu57uPrkf1YGGrJIXdHojK6wOe5AsHCEI65KSwucCCukhZGfGOOw9lm(Ifw5XfONvynH22fylp(B5rYh6a(sG)MXCeTMPaSrEKNZqJxG7eBaIaY9CCQBNvuR(fQyrfaXEoo1TZkQv)cvSOcq514kVmAIxa62xSZHkaoTWPlwwCa2ipYZWSIA1VqLPaY9CCQBXkp(BvXIkGI5Dbx9sW40f6akM31HC)qhaxHiGfRzGT84V1rqW8(at9yy9SUb0T0mwa5yzjemrfG7fBaEmPsGsOKkXwE)7gqX8UyLh)TQmfOvAhbbZ7dG1Z3a6wAglGwyqtu77DeemVpqdOBPzSaef1QFHJGG59bM6XW6zDGzpLSujyFGMlKpHujo9DbumVlGLPaSrEK38A)rS6xeOb0T0mwabjo0eVqf7Cbuu3yyCukMz)49blqfRza6yndGpwZa(ynZgqX8UZkQv)cvOdGyphN6whsFflQafPVWKPUa0KCCbWvi6qUFSOcqp0TB3Y4DDgJqhOgumfW8U8i7I1mqnOyQzpo6A5r2fRzG5pUICSzkqnClzfps(mfaPwPP1d9kJjtDbOdquuR(fodnErGzDwSUgcyqROgLmMm1fGiGVe4pmzQlqrRh6voqr6lwRfxMc0kTXxSGU9fRjcbQbftHvE83YJKpwZa(BeywNfRRHakQBmmokftOdudkMcR84VLhzxSMbyJ8ipdOfg0e1(EvMcauhHUg621QFrSnQXnoaoTWHC)yrfylp(Bn(Ifw5XfONvynH22fWWXvKJ1HVPaOjKLkH9NwOyzPsM)4kYXgqUNJtDl7MuXYsMbqSNJtDl7MuXAgOgumLZWTKv8i5J1mGM4fSG)XfRzJcq514kVSXxSGU9fRjcbO8hXJJUwh(McGMqwQe2FAHILLkz(JRihBanXlaQIqlWhBJcGRq0PlwubyJ8ipdOjEbOBFXohQaB5XFlpYUqhGEOB3ULX7g6anCJRuxSiGYSXMMMSiwiQ5mNdbecGyphN6w0cdAIAFVkwubK754u3Iwyqtu77vXIkWwE83A8fBaEmPsGsOKkXwE)7gaXEoo1TyLh)TQyrfqX8UoK(cTG7dDafZ7Iwyqtu77vzkGCphN6whsFflQa1WTKv8i7YuafZ7YJSltbumVRtxOdq84ORLhjFOduK(cOUXa98XIkqr6lhbbZ7dm1JH1Z6M6mIfOi9fAb3JjtDbOj54cGtlaSyrfylp(Bn(If0TVynriaBKAIwzVwbR84cqhGOOw9lm(InapMujqjusLylV)DdudkMA2JJUwEK8XAgOtu0JZqMcO04OgNtFxSieOvAJVydWJjvcucLuj2Y7F3a1GIPCgULSIhzxSMbikQv)cJVybD7lwtecq84ORLhzxOdOyEx2DY0AHbTaVktbumVlps(mfaXyrfqX8UGREjyCi3ptbQbftbmVlps(yndWg5rEgm(If0TVynriqR0gFXcR84c0ZkSMqB7cWg5rEgy3KktbSfUlqZfYNqQeN(UafPVyLqVbOgL85ZMaa]] )



end

