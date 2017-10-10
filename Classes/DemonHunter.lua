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

        addToggle( 'artifact_ability', true, 'Artifact Ability', 'Set a keybinding to toggle your artifact ability on/off in your priority lists.' )

        addSetting( 'artifact_cooldown', true, {
            name = "Artifact Ability: Cooldown Override",
            type = "toggle",
            desc = "If |cFF00FF00true|r, when your Cooldown toggle is |cFF00FF00ON|r then the toggle for artifact ability will be overriden and Doom Winds will be shown regardless of your Artifact Ability toggle.",
            width = "full"
        } )

        addSetting( 'use_fel_rush', false, {
            name = "Havoc: Use Fel Rush",
            type = "toggle",
            desc = "If |cFF00FF00true|r, the addon will recommend the use of Fel Rush.  Using Fel Rush can be very valuable for some talent combinations, but bears movement-related risks.",
            width = "full"
        } )

        addSetting( 'fury_range_aoe', true, {
            name = "Havoc: Fury of the Illidari, Require Target(s)",
            type = "toggle",
            desc = "If |cFF00FF00true|r, the addon will require either (1) your target is within range or (2) you have multiple other nearby targets before recommending Fury of the Illidari.",
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
            known = function() return equipped.twinblades_of_the_deceiver and ( toggle.artifact_ability or ( toggle.cooldowns and settings.artifact_cooldown ) ) end,
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
            setDistance( abs( target.distance - 15 ) )
            setCooldown( 'global_cooldown', 0.25 )
        end )


        addAbility( 'vengeful_retreat', {
            id = 198793,
            spend = 0,
            spend_type = 'fury',
            cast = 0,
            gcdType = 'spell',
            cooldown = 25,
            usable = function () return target.within8 end
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
            setDistance( 8 )
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
            -- usable = function () return target.within15 end
        } )

        addHandler( 'felblade', function ()
            setDistance( 5 )
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


    storeDefault( [[SimC Havoc: default]], 'actionLists', 20171006.172018, [[deKrpaqiQIwKcHnjszuOIofQKvbq6vOkOzPq0Tqvi7srddrDmr0YqepdvrtdG4AIKABOc9nQcJtKQ6COkuRtKkZdvW9qLAFIehuHAHauperAIOkqxeuXifj5KGkntrQYnPkTtfSua8uPMkGSvuL2lXFbAWcomLfdYJPYKj5YQ2mvvFMQYOrvDAiVwH0Sr62IA3k9BjdhqTCs9CuMouxhH2oO8Dr48GQwpQcy(iy)cTKuas6g47qgfXdyyuTYqQ9WdPBNgbmwAPb40BSldKqoPhKtFs4XZKPFYuNAsKEWYx6gLjngsLbRCPlgu3VrKILESdJQLjajdjfGKgoRbrVsaS0TtJaglTNXaNXGNXa2OFXZ95ZqS5xdIEvmqGqm4QIQQe7CF(meBQVPGpgiqigCvrvvIDUpFgIn1pBOLfdPedyt774jgLpiUavOhdeiedUQOQkXo3NpdXM6Nn0YIHuIbosog4s6XqikcdV0WmnYGOxA4UkKZWLw6T2lT3sXRPhS8LoHHWO1hO)sdUpFgIj9GLV0nU0pg41OeV0J1(ysVw(CNWqy06d0FPb3NpdXgjmJs8C7jNEIn6x8CF(meB(1GOxrGGRkQQsSZ95ZqSP(McEceCvrvvIDUpFgIn1pBOLLc20(oEIr5dIlqf6ei4QIQQe7CF(meBQF2qllfosMlPb40BSldKqoPhjjlnaNve1UZeGeS0KY)Ur9wWE(lwGK2BPgS8LwWYajcqsdN1GOxjaw62PraJL2ZyGZyWZyaB0V4PJVvmqiQPoB(1GOxfdeiedUQOQkXoD8TIbcrn1zt9nf8XabcXGRkQQsSthFRyGqutD2u)SHwwmKsmGnTVJNyu(G4cuHEmqGqm4QIQQe70X3kgie1uNn1pBOLfdPedCKCmWL0JHquegEPHzAKbrV0WDviNHlT0BTxAVLIxtpy5lDcdHrRpq)Lg0X3kgie1uNj9GLV0nU0pg41OeFmWzsUKES2ht61YN7egcJwFG(lnOJVvmqiQPoBKWmkXZTNC6j2OFXthFRyGqutD28RbrVIabxvuvLyNo(wXaHOM6SP(McEceCvrvvID64BfdeIAQZM6Nn0YsbBAFhpXO8bXfOcDceCvrvvID64BfdeIAQZM6Nn0YsHJK5sAao9g7YajKt6rsYsdWzfrT7mbiblnP8VBuVfSN)IfiP9wQblFPfSmWtbiPHZAq0RealD70iGXs7zmGn6x8u9CTi38RbrVkgslgCvrvvIDMp2YLgy(fdXM6Nn0YIboedCmgslg8tud)uD)ihchdPed8KCmKwmWzm4zmaZ0idI(zcdHrRpq)LgCF(melgiqigCvrvvIDUpFgIn1pBOLfdCigssog4kgslg4mg8mgGzAKbr)mHHWO1hO)sd64BfdeIAQZIbceIbxvuvLyNo(wXaHOM6SP(zdTSyGdXahJbUKEmeIIWWlnmtJmi6LgURc5mCPLER9s7Tu8A6blFPbUkkA9b6V0G5JnPhS8LUXL(XaVgL4JbojHlPhR9XKET85g4QOO1hO)sdMp2gjmJs8C7j2OFXt1Z1ICZVge9Q0CvrvvIDMp2YLgy(fdXM6Nn0Y4ahtZprn8t19JCiCk8KCAC6jmtJmi6NjmegT(a9xAW95ZqmceCvrvvIDUpFgIn1pBOLXHKK5kno9eMPrge9ZegcJwFG(lnOJVvmqiQPoJabxvuvLyNo(wXaHOM6SP(zdTmoWrUKgGtVXUmqc5KEKKS0aCwru7otasWstk)7g1Bb75VybsAVLAWYxAbldaIaK0Wzni6vcGLUDAeWyPXg9lE6hPzyqiAvQ5xdIEvmqGqmWogeQwISjgDnjKbbeGDXqkXa5yGaHyWCyeSd(9z0zXqkChd8mg4HXaNXa2OFXthFRyGo6nyFIa)Aq0RIbang4zmWL0JHquegEPHzAKbrV0WDviNHlT0BTxAVLIxtpy5lne1uhuzR7spy5lDJl9JbEnkXhdCYtUKES2ht61YNBiQPoOYw3hjmJs8CJn6x80psZWGq0QuZVge9kceyhdcvlr2eJUMeYGacWocemhgb7GFFgDwkCZtEiNyJ(fpD8TIb6O3G95xdIEfGYtUKgGtVXUmqc5KEKKS0aCwru7otasWstk)7g1Bb75VybsAVLAWYxAbldPwasA4Sge9kbWs3oncyS0WmnYGOFcrn1bv26EmKwmWzm4NOg(PJOw)fhdCig8i1XapkgWg9lE6hPzyqiAvQjc8RbrVkga0yGeYXaxspgcrry4LgMPrge9sd3vHCgU0sV1EP9wkEn9GLV0axffT(a9xAqiQPoOYw3LEWYx6gx6hd8AuIpg4eq4s6XAFmPxlFUbUkkA9b6V0GqutDqLTUpsygL45gMPrge9tiQPoOYw3tJt)e1WZbpsnpcB0V4PFKMHbHOvPMFni6vakjK5sAao9g7YajKt6rsYsdWzfrT7mbiblnP8VBuVfSN)IfiP9wQblFPfSmWrbiPHZAq0RealD70iGXsJn6x80X3kgOJEd2NFni6vXqAXGFIA4NQ7h5q4yiLyaqil9yiefHHxAyMgzq0lnCxfYz4sl9w7L2BP410dw(sdCvu06d0FPbD8TIbYWA0Ox6blFPBCPFmWRrj(yGZuZL0J1(ysVw(CdCvu06d0FPbD8TIbYWA0OFKWmkXZn2OFXthFRyGo6nyF(1GOxLMFIA4NQ7h5q4uaeYP5P2qkWd7lEAkfBse400gsbEyFXttPyt0YbsauFoL0aC6n2LbsiN0JKKLgGZkIA3zcqcwAs5F3OElyp)flqs7Tudw(slyzWdbiPHZAq0Real9yiefHHxAxTmI5dMnFiN0WDviNHlT0BTxAVLIxtpy5lT0dw(stATmI5hdEnFiN0aC6n2LbsiN0JKKLgGZkIA3zcqcwAs5F3OElyp)flqs7Tudw(slyzi9fGKgoRbrVsaS0TtJaglTRkQQsStF0cYOGUQOQkXo1pBOLfdChdKLEmeIIWWlTZOuqZHr1csrmS0WDviNHlT0BTxAVLIxtpy5lT0dw(stQrPXWyhgvBmKEigw6XAFmPxlFUhrJYKgdPYGvU0fdUQOQkXocPb40BSldKqoPhjjlnaNve1UZeGeS0KY)Ur9wWE(lwGK2BPgS8LUrzsJHuzWkx6IbxvuvLyfSmWJfGKgoRbrVsaS0TtJagln2OFXt1Z1ICZVge9kPhdHOim8sRjUGMdJQfKIyyPH7QqodxAP3AV0ElfVMEWYxAPhS8LgaIBmm2Hr1gdPhIHLES2ht61YN7r0OmPXqQmyLlDXG65ArUrinaNEJDzGeYj9ijzPb4SIO2DMaKGLMu(3nQ3c2ZFXcK0El1GLV0nktAmKkdw5sxmOEUwKtWYqsYcqsdN1GOxjaw6XqikcdV0AIlO5WOAbPigwA4UkKZWLw6T2lT3sXRPhS8Lw6blFPbG4gdJDyuTXq6Hy4yGZKCj9yTpM0RLp3JOrzsJHuzWkx6IHT0zJocPb40BSldKqoPhjjlnaNve1UZeGeS0KY)Ur9wWE(lwGK2BPgS8LUrzsJHuzWkx6IHT0zJkyblnp49BePybWcwea]] )

    storeDefault( [[SimC Havoc: precombat]], 'actionLists', 20171006.172018, [[duJgcaGEIkTjbLDjQETaz2cDtf5BqPDQs7LA3q2pkgLaAyqX4eGHsqAWq1WjYbvuoLG4ye6CeLSqvHLsGfJslxQEOQupfzzQkpxHjsuXuvvnzvmDjxuG6YGRRkARcQ2mbvBxvYTf53K(SO03jk1ijionQgTO4Xs5KcshwPRPO68evToIIoebL)suyl6FtKe04BKl3T4kY35yXAIADUuzYKaic7a89dJiwmb8jRCXaeNp)Z0DtGjINEZGlK9L2KjdUuhAAIDltZAfxrd)7RO)nfmAzJWXpmrToxQmvA2SrixslUIgMMXYJ8sEtsAXvKPqrhEBlTBcPiW0KEcF73nbMmD3eysOAXvKjbqe2b47hgrSIymjag6ZEdg(3LP3zGwqt6libOYSMM0ZDtGjx((5FtbJw2iC8dtuRZLktLMnBeYBQgpQSrdg8WyWdKbxym4bYGxBeqv(bsksgDGv7OCaTSr4WGhgdETrav5hiPiElhqlBeom4HWGhIPzS8iVK3ucQnPDPm6Gpmfk6WBBPDtifbMM0t4B)UjWKP7MattqTjTlLrh8Hjbqe2b47hgrSIymjag6ZEdg(3LP3zGwqt6libOYSMM0ZDtGjxUmjhq47Zy5hUSb]] )

    storeDefault( [[SimC Havoc: normal]], 'actionLists', 20171006.172018, [[da0qzaqijInrs5tsKsnkOQofuLvbuKxjrk2fQmmc5yaSmj0ZiPQPjrQUgjv2gqr13iiJJKqNJKGwNePK5rsK7jrY(akDqsHfsq9qsrtKKaxKuQncu4JKe1ibkkDsjOBcKDIQwkj6PuMkHARKs2RQ)cvgmKdlAXs6XqzYcUSYMb0NbQgns50c9AssZMOBtLDJ43OmCcSCQ65iz6sDDs12jHVlboVe16bkkMps1(b9bCX3ubdyQl7l8n(0TBw0PjebMnvWWkTGicZ7s5nLtUKANVOiacjsflQc5aOIauN6kEZW8rb9TBAG1rgH6IppGl(M2KSkx4cFZW8rb9n8HOoLJ0Cc8tq6xGBKSkxaIOthI6uosZ5yUrADh3izvUaeHhePgev1bcKtGFcs)cCbwbeisniQQdeiNJ5gP1DCbwbKBAuJYyx(MIraFa1L48R9l7BfscrSSz(Begz3aXcALE(0TB34t3UP1iGpG6sis5A)Y(MYjxsTZxueaHai6MYrX09yJ6IFFttAdtvqmfZns)6nqSaF62T3NV4fFtBswLlCHVzy(OG(g(quNYrAohZnsR74gjRYfGi60HOoLJ0CaNeNlP65lZnswLlar4brQbr4drLarDkhP5Cm3iTUJBKSkxaIOthIWhIWOLEWhfevkiQierNoeHXyYaRacNIraFa1L48R9lBo)CzKqbrGfIkDicpisniQQdeiNJ5gP1DCbwbeicpisnicFiQeiQt5inhWjX5sQE(YCJKv5cqeD6qeqDFzUWagXIneb2sbrfvheHhePgeHpeHrl9GpkiQuquricVBAuJYyx(gWjX51PODRqsiILnZFJWi7giwqR0ZNUD7gF62nWysisPofTBkNCj1oFrraecGOBkhft3JnQl(9nnPnmvbXum3i9R3aXc8PB3EFE1FX30MKv5cx4BgMpkOVHpev1bcKZXCJ06ooDbqeD6qujquNYrAohZnsR74gjRYfGi8Gi1Gi8HOeRJkgUrMlokicSqeaicVBAuJYyx(gWjXvtVpbF3kKeIyzZ83imYUbIf0k98PB3UXNUDdmMeIeo9(e8Dt5KlP25lkcGqaeDt5Oy6ESrDXVVPjTHPkiMI5gPF9giwGpD727Zx6x8nTjzvUWf(MH5Jc6BDkhP5QsglixZnswLlarQbr4drLarDkhP5Cm3iTUJBKSkxaIOthIQ6abY5yUrADhNUaicpisnicJw6bFuquPGOI30OgLXU8TMMNvaoWLzuXUvijeXYM5VryKDdelOv65t3UDJpD7MyAEwbqKklZOIDt5KlP25lkcGqaeDt5Oy6ESrDXVVPjTHPkiMI5gPF9giwGpD727ZRUl(M2KSkx4cFZW8rb9nG6(YCy6E)inePsqea1brQbr4drymMmWkGWfw20WrvWMao)CzKqbrQeeveIatqe4ybiIoDicJXKbwbeUQmddxijyJZpxgjuqKkbrfHiWeebowaIW7Mg1Om2LVbCYQmd7wHKqelBM)gHr2nqSGwPNpD72n(0TBGXKvzg2nLtUKANVOiacbq0nLJIP7Xg1f)(MM0gMQGykMBK(1BGyb(0TBVppy(fFtBswLlCHVzy(OG(MI0hZQCCvzggUqsW2nnQrzSlFlSSPHJQGnb3kKeIyzZ83imYUbIf0k98PB3UXNUDtfSSPbrwbBcUPCYLu78ffbqiaIUPCumDp2OU4330K2WufetXCJ0VEdelWNUD795f6IVPnjRYfUW3mmFuqFdJw6bFuquPGOIqKAqujquNYrAohZnsR74gjRYfGi1GOsGOoLJ0CaNeNlP65lZnswLlarQbrLarvDGa5CRthZlGgJksXPl4Mg1Om2LVbCsCEDkA3kKeIyzZ83imYUbIf0k98PB3UXNUDdmMeIuQtrdIWhaE3uo5sQD(IIaiear3uokMUhBux87BAsByQcIPyUr6xVbIf4t3U9(8Q4fFtBswLlCHVPrnkJD5BaNe386c6iJCRqsiILnZFJWi7giwqR0ZNUD7gF62nWysisBVUGoYi3uo5sQD(IIaiear3uokMUhBux87BAsByQcIPyUr6xVbIf4t3U9(8QWl(M2KSkx4cFZW8rb9n8HOeRJkgUrMlokicSqeaicpiIoDicFicFiQeiQt5inNJ5gP1DCJKv5cqeD6quvhiqohZnsR740far4brQbr4drLarDkhP5WOLmkCvzggf3izvUaerNoev1bcKdJwYOWvLzyuC6cGi60Himgtgyfq4WOLmkCvzggfNFUmsOGiWcrQxeerNoe1Ph81CD0nCndxioisLGimgtgyfq4WOLmkCvzggfNFUmsOGi8Gi8UPrnkJD5Ba19LXXaIRPnCrPmgsF8wHKqelBM)gHr2nqSGwPNpD72n(0TBGHUVmeXacrnTbrfkLXq6J3uo5sQD(IIaiear3uokMUhBux87BAsByQcIPyUr6xVbIf4t3U9(8aeDX30MKv5cx4BgMpkOVPi9XSkhxvMHHlKeSDtJAug7Y3QYmmCHKGTBfscrSSz(Begz3aXcALE(0TB34t3UjSmddIubjbB3uo5sQD(IIaiear3uokMUhBux87BAsByQcIPyUr6xVbIf4t3U9(8aaCX30MKv5cx4BgMpkOV1PCKMRkzSGCn3izvUaePgeLyDuXWnYCXrbrGTuqurisnicFiQeiQt5inNlP65XXaIRPnCGlZOIXnswLlar0PdrLarDkhP5Cm3iTUJBKSkxaIOthIQ6abY5yUrADhNUaicpisnicFikX6OIHBK5IJcIaBPGi1dr4DtJAug7Y3AAEwb4axMrf7wHKqelBM)gHr2nqSGwPNpD72n(0TBIP5zfarQSmJkgeHpa8UPCYLu78ffbqiaIUPCumDp2OU4330K2WufetXCJ0VEdelWNUD795bu8IVPnjRYfUW3mmFuqFdOUVmxyaJyXgIaBPGi1lcIknquvhiqob(ji9lWPlaIatqKkEtJAug7Y3aozvMHDRqsiILnZFJWi7giwqR0ZNUD7gF62nWyYQmddIWhaE3uo5sQD(IIaiear3uokMUhBux87BAsByQcIPyUr6xVbIf4t3U9(8au)fFtBswLlCHVzy(OG(wI1rfd3iZfhfebwicaerNoeHpeLyDuXWnYCXrbrGTuqK6Hi8Gi60Hi8HOoLJ0CvzKeWbu3xMBKSkxaIudIaQ7lZfgWiwSHiWwkis9QdIWdIOthIOwJRYi6uCDC(IaWvuagebwis0nnQrzSlFBLhU6s3TcjHiw2m)ncJSBGybTspF62TB8PB30U8GiHx6UPCYLu78ffbqiaIUPCumDp2OU4330K2WufetXCJ0VEdelWNUD795bu6x8nTjzvUWf(MH5Jc6B4drDkhP5cZXi4QYmmkUrYQCbiIoDiQeiQt5inNJ5gP1DCJKv5cqeD6quvhiqohZnsR740far0Pdra19L5cdyel2qKkbrQxeevAGOQoqGCc8tq6xGtxaebMGiveIOthIQ6abY5wNoMxangvKIZpxgjuqKkbrQdIWdIudIkbIuK(ywLJtaJjJeWXbK5XvLzy4cjbB30OgLXU8TKqI0IYSJmYTcjHiw2m)ncJSBGybTspF62TB8PB30GqI0IYSJmYnLtUKANVOiacbq0nLJIP7Xg1f)(MM0gMQGykMBK(1BGyb(0TBVppa1DX30MKv5cx4BgMpkOV1PCKMRkzSGCn3izvUaePgeHpevce1PCKMZLu984yaX10goWLzuX4gjRYfGi60HOsGOoLJ0CoMBKw3XnswLlar0PdrvDGa5Cm3iTUJtxaeH3nnQrzSlFRP5zfGdCzgvSBfscrSSz(Begz3aXcALE(0TB34t3UjMMNvaePYYmQyqe(fX7MYjxsTZxueaHai6MYrX09yJ6IFFttAdtvqmfZns)6nqSaF62T3Nhay(fFtBswLlCHVzy(OG(wjquNYrAUQKXcY1CJKv5cqKAquvhiqo360X8cOXOIuCbwbeisnikX6OIHBK5IJcIaBPGi1FtJAug7Y3AAEwb4axMrf7wHKqelBM)gHr2nqSGwPNpD72n(0TBIP5zfarQSmJkgeHV6X7MYjxsTZxueaHai6MYrX09yJ6IFFttAdtvqmfZns)6nqSaF62T3NhGqx8nTjzvUWf(MH5Jc6B4drDkhP5cZXi4QYmmkUrYQCbiIoDiQeiQt5inNJ5gP1DCJKv5cqeD6quvhiqohZnsR740far0Pdra19L5cdyel2qKkbrQxeevAGOQoqGCc8tq6xGtxaebMGiveIWdIudIkbIuK(ywLJtaJjJeWXbK5XHrlzu4OAFu1brQbrLarksFmRYXjGXKrc44aY84CRtisniQeisr6JzvoobmMmsahhqMhxvMHHlKeSDtJAug7Y3WOLmkCuTpQ6UvijeXYM5VryKDdelOv65t3UDJpD7MM0sgfezTpQ6UPCYLu78ffbqiaIUPCumDp2OU4330K2WufetXCJ0VEdelWNUD795bOIx8nTjzvUWf(MH5Jc6BLarDkhP5Cm3iTUJBKSkxaIudIWhI6uosZfMJrWvLzyuCJKv5cqeD6quvhiqo360X8cOXOIuCbwbeicVBAuJYyx(gWjX51PODRqsiILnZFJWi7giwqR0ZNUD7gF62nWysisPofnic)I4Dt5KlP25lkcGqaeDt5Oy6ESrDXVVPjTHPkiMI5gPF9giwGpD727ZdqfEX30MKv5cx4BAuJYyx(wyogHcxn27wHKqelBM)gHr2nqSGwPNpD72n(0TBQG5yKsBkis4yVBkNCj1oFrraecGOBkhft3JnQl(9nnPnmvbXum3i9R3aXc8PB3EF(IIU4BAtYQCHl8ndZhf0360d(AUibNpjGVBAuJYyx(wtZZkah4YmQy3kKeIyzZ83imYUbIf0k98PB3UXNUDtmnpRaisLLzuXGi8lD8UPCYLu78ffbqiaIUPCumDp2OU4330K2WufetXCJ0VEdelWNUD795lc4IVPnjRYfUW3mmFuqFRtp4R5crQojydIalebqDqeD6quNEWxZfj48jb8DtJAug7Y3aozvMHDRqsiILnZFJWi7giwqR0ZNUD7gF62nWyYQmddIWViE3uo5sQD(IIaiear3uokMUhBux87BAsByQcIPyUr6xVbIf4t3U9(8flEX30MKv5cx4BgMpkOV1Ph81CHivNeSbrGfIaOoiIoDicFiQtp4R5IeC(Ka(Gi1GOsGOoLJ0CoMBKw3XnswLlar4DtJAug7Y3aojoVofTBfscrSSz(Begz3aXcALE(0TB34t3Ubgtcrk1PObr4RE8UPCYLu78ffbqiaIUPCumDp2OU4330K2WufetXCJ0VEdelWNUD795lQ(l(M2KSkx4cFZW8rb9To9GVMleP6KGnicSqea1DtJAug7Y3umc4dOUeNFTFzFRqsiILnZFJWi7giwqR0ZNUD7gF62nTgb8buxcrkx7x2qe(aW7MYjxsTZxueaHai6MYrX09yJ6IFFttAdtvqmfZns)6nqSaF62T3NVyPFX30MKv5cx4BgMpkOVvce1PCKMRkzSGCn3izvUWnnQrzSlFRP5zfGdCzgvSBfscrSSz(Begz3aXcALE(0TB34t3UjMMNvaePYYmQyqe(QdVBkNCj1oFrraecGOBkhft3JnQl(9nnPnmvbXum3i9R3aXc8PB3E)(MjyyXugbZKDKroV6esO3)]] )

    storeDefault( [[SimC Havoc: cooldown]], 'actionLists', 20171006.172018, [[d0JBhaGAkcwVsvXMav2fQABscTpjbZwjZhuUji9CcFdu1TjzNezVq7Mu7xvJsKAyOIFlCAugQsvvdwLHlrhKO0PejhdiNJOalKOYsfrlMclNspKOQNs1YOOwhrHMOsvPPkctwutxQlQuLZtr6zef11bQhdyRskTzuPTRu5Wk(UKQPrrO5jPyKkvvoerbnAq8xjCsjrFwPCnjj3JIOXruKlJ8AjPgbHjqxAue6otj)F73SlaKX)aIyLJ6A09scGnl2(mnl0OuvWdp6jPfnccLmZbe8CKjZYaEqYeOQQYm6oGLv2OJUSanl0cmbkbctG(E6Xyrzuo0DalRSrVJTTfXdeXkh11I)G7V0)jd)l9F9SiDZNjvOza8KEmwu(pyW(B3yzJXI4lJyX0BfCdBHI65pyW(B3yzJXI4RpSMP3k4g2cnPibt8hmy)TBSSXyr81hwZ0BfCdBbaKjefgRjtI)s9hmy)1JDJA(MPOIokYm6VA(ZCv)LcDznylwBk6kQhvylHecMa9k1zgW0HfDDOj0Hg5AhR0Oi0rxAue6qPEuHTesiyc0tslAeekzMdi4bXb9KKiaBbibMaB0Lhcbun0yhPiDJgOdnYsJIqhBuYmMa990JXIYOCO7awwzJEhBBlIhiIvoQRf)b3FP)RNfPB(mPcndGN0JXIY)b3FgG5YLxr9OcBjKqWe8Gl)dU)4c2AkpayRL09F18NjY5VuOlRbBXAtrxr9OcBjKqWeOxPoZaMoSORdnHo0ix7yLgfHo6sJIqhk1JkSLqcbt8xAqPqpjTOrqOKzoGGheh0tsIaSfGeycSrxEieq1qJDKI0nAGo0ilnkcDSrjzgtG(E6Xyrzuo0DalRSrVJTTfXdeXkh11I)G7V0)L(VmzaMlxEnPibtWNJ66)G7V0)nanBhvqAsXiXFv4pq)L6Vu)b3FP)BSBuZ3mfv0rrMr)L6VuOlRbBXAtrxtksWeOxPoZaMoSORdnHo0ix7yLgfHo6sJIqxIuKGjqxw7Ma9ESBuxW4AsftlJ9y3OMVzkQOJImJqpjTOrqOKzoGGheh0tsIaSfGeycSrxEieq1qJDKI0nAGo0ilnkcDSrjtetG(E6Xyrzuo0DalRSrVJTTfXdeXkh11I)G7V0)L(pdWC5YdazcrHXAYKGhC5FWG9NbyUC5vupQWwcjembp4Y)Gb7pGiw5OUMxr9OcBjKqWe8t2ealAkxyj1W0I)Q5pZC(dgS)6XUrnFZuurhfzg9xnM8VkY5Vu)LcDznylwBk6AsrcMa9k1zgW0HfDDOj0Hg5AhR0Oi0rxAue6sKIemXFPbLc9K0IgbHsM5acEqCqpjjcWwasGjWgD5Hqavdn2rks3Ob6qJS0Oi0XgLQctG(E6Xyrzuo0DalRSrVJTTfXdeXkh11I)G7V0)zaMlxEf1JkSLqcbtWdU8pyW(diIvoQR5vupQWwcjemb)KnbWIMYfwsnmT4Vk8xf58hmy)1JDJA(MPOIokYm6VAm5FGm)xk0L1GTyTPOdazcrHXAYKa9k1zgW0HfDDOj0Hg5AhR0Oi0rxAue6YdzcXFYTMmjqpjTOrqOKzoGGheh0tsIaSfGeycSrxEieq1qJDKI0nAGo0ilnkcDSrPkIjqFp9ySOmkh6oGLv2O3X22I4lJMfAXFW9x6)maZLlVI6rf2siHGj4TKAyAXFv4pZv9hmy)1JDJA(MPOIokYm6VA(tM58xk0L1GTyTPOxgnl0OxPoZaMoSORdnHo0ix7yLgfHo6sJIqF)JMfA0tslAeekzMdi4bXb9KKiaBbibMaB0Lhcbun0yhPiDJgOdnYsJIqhBSrFFjUd4vJYHnI]] )

    storeDefault( [[SimC Havoc: demonic]], 'actionLists', 20171006.172018, [[deeJsaqifWMiQ8jevvnkuQofkLvPGqVsbr2fQAyeXXuKLPqEMcQMgIQY1OsLTHOc(gbmoev6CkiQ1PGGMhIk6EkOSpQu1bjQAHeOhsumrfK6IeP2iIQ8rfKmsevOtsLYnbYorLLsqpLYujKTsuAVQ(lImyihw0Ib8yeMSqxwAZkQpJOmAG60u1RjsMnj3Mu7g0VrA4OKLl45Oy6kDDQy7eQVRanEfe48kuRhrvL5tLSFO(tx0THUZPJAVG34sDVzETmye5ykMsmeIrXQPqpXnHv1KPNBKKjbKqUJgY8tK7K7C3OBgrWZAVDtEI1tHmx05MUOBsdtavJxWBgrWZAVXogTPQWLNvOSYqJ8fMaQgXixUWOnvfU8AQUW1rZxycOAeJydJKdJaCMN5zfkRm0iFKoieJKdJaCMN51uDHRJMpsheEtEaVYVJVjUqY6SJIuOBO5EZny0tKlnCdsH9giAu2mWL6E7gxQ7nzlKSo7OWiHDdn3BcRQjtp3ijtcmj5MWYqDceL5I(EtgWLqkquXvx4EGBGOrUu3BFp3Ol6M0Weq14f8Mre8S2BSJrBQkC51uDHRJMVWeq1ig5YfgTPQWLFUks6KzBymFHjGQrmInmsomIDmAamAtvHlVMQlCD08fMaQgXixUWi2XicWzGSYGrddJgHrUCHreuQksheYlUqY6SJIuOBO5YhQo9qgmY9ye5dJydJKdJaCMN51uDHRJMpsheIrSHrYHrSJreGZazLbJgggncJy7M8aELFhFBUksbhgW3Cdg9e5sd3GuyVbIgLndCPU3UXL6EJ8QcJe6Wa(MWQAY0ZnsYKatsUjSmuNarzUOV3KbCjKcevC1fUh4giAKl1923Zn8l6M0Weq14f8Mre8S2BBQkC5buuAu1LVWeq1igjhgXognagTPQWLxt1fUoA(ctavJyKlxyeGZ8mVMQlCD08oSWi2Wi5WicWzGSYGrddJgDtEaVYVJVTGd0bjrMk9I7n3GrprU0Wnif2BGOrzZaxQ7TBCPU3eboqheJgkv6f3BcRQjtp3ijtcmj5MWYqDceL5I(EtgWLqkquXvx4EGBGOrUu3BFph57IUjnmbunEbVzebpR9M4m4tav5buzSKIjKO3KhWR874BXMlysmd2Y6MBWONixA4gKc7nq0OSzGl192nUu3BdDZfmgzd2Y6MWQAY0ZnsYKatsUjSmuNarzUOV3KbCjKcevC1fUh4giAKl1923Z5Ul6M0Weq14f8M8aELFhFBUksn4WA9u4n3GrprU0Wnif2BGOrzZaxQ7TBCPU3iVQWiPdoSwpfEtyvnz65gjzsGjj3ewgQtGOmx03BYaUesbIkU6c3dCdenYL6E775ihUOBsdtavJxWBgrWZAVXogLeRxCjvy1(YGrUhJMWi2WixUWi2Xi2XObWOnvfU8AQUW1rZxycOAeJC5cJaCMN51uDHRJM3HfgXggX2n5b8k)o(2Stymj6mPfCj5vkFmd(BUbJEICPHBqkS3arJYMbUu3B34sDVrEoHXyeDgJwWfJCtP8Xm4VjSQMm9CJKmjWKKBcld1jquMl67nzaxcParfxDH7bUbIg5sDV99CcCr3KgMaQgVG3mIGN1EtCg8jGQ8aQmwsXesumsomIGsvr6Gq(oUKaAQ5dvNEidg5EmYDyKCy0ayebLQI0bH86UPMgybMY4z4dnJJVjpGx53X3auzSKIjKO3Cdg9e5sd3GuyVbIgLndCPU3UXL6Etqvglgn0jKO3ewvtMEUrsMeysYnHLH6eikZf99MmGlHuGOIRUW9a3arJCPU3(EoY9IUjnmbunEbVzebpR92MQcxEafLgvD5lmbunIrYHrjX6fxsfwTVmyK7hggncJKdJyhJgaJ2uv4YRtMTbs0zsl4sImv6fx(ctavJyKlxy0ay0MQcxEnvx46O5lmbunIrUCHraoZZ8AQUW1rZ7WcJydJKdJyhJsI1lUKkSAFzWi3pmmA4yeB3KhWR874Bl4aDqsKPsV4EZny0tKlnCdsH9giAu2mWL6E7gxQ7nrGd0bXOHsLEXfJyFITBcRQjtp3ijtcmj5MWYqDceL5I(EtgWLqkquXvx4EGBGOrUu3BFp3q(IUjnmbunEbVzebpR92StymFSZEc)IrUFyy0WLCtEaVYVJVnxfGkJ9MBWONixA4gKc7nq0OSzGl192nUu3BKxvaQm2BcRQjtp3ijtcmj5MWYqDceL5I(EtgWLqkquXvx4EGBGOrUu3BFp3KKl6M0Weq14f8Mre8S2BjX6fxsfwTVmyK7XOjmYLlmAamcWzEMpwnf6ji1HGTWyJK0DtnnWcmLXZW7W6M8aELFhFRJljGM6BUbJEICPHBqkS3arJYMbUu3B34sDVj94Irc2uFtyvnz65gjzsGjj3ewgQtGOmx03BYaUesbIkU6c3dCdenYL6E775MMUOBsdtavJxWBgrWZAVXognagTPQWLxt1fUoA(ctavJyKlxyeGZ8mVMQlCD08oSWixUWOzNWy(yN9e(fJiNy0WLGrdjmcWzEMNvOSYqJ8oSWOHigrUyKlxyeGZ8mVUBQPbwGPmEg(q1PhYGrKtmYDyeByKCy0ayK4m4tav5zrPkpKmsZ0ajavglPycj6n5b8k)o(wcHEWEvUEk8MBWONixA4gKc7nq0OSzGl192nUu3BYdHEWEvUEk8MWQAY0ZnsYKatsUjSmuNarzUOV3KbCjKcevC1fUh4giAKl1923Znn6IUjnmbunEbVzebpR92MQcxEafLgvD5lmbunIrYHrSJrdGrBQkC51jZ2aj6mPfCjrMk9IlFHjGQrmYLlmAamAtvHlVMQlCD08fMaQgXixUWiaN5zEnvx46O5DyHrSDtEaVYVJVTGd0bjrMk9I7n3GrprU0Wnif2BGOrzZaxQ7TBCPU3eboqheJgkv6fxmI9rSDtyvnz65gjzsGjj3ewgQtGOmx03BYaUesbIkU6c3dCdenYL6E775Mg(fDtAycOA8cEZicEw7n2XObWOnvfU8AQUW1rZxycOAeJC5cJaCMN51uDHRJM3Hfg5Yfgn7egZh7SNWVye5eJgUemAiHraoZZ8ScLvgAK3HfgneXiYfJydJKdJgaJeNbFcOkplkv5HKrAMgiraoPmKy2GxQIrYHrdGrIZGpbuLNfLQ8qYintdK0DtmsomAamsCg8jGQ8SOuLhsgPzAGeGkJLumHe9M8aELFhFJaCsziXSbVu9MBWONixA4gKc7nq0OSzGl192nUu3BYaoPmyKTbVu9MWQAY0ZnsYKatsUjSmuNarzUOV3KbCjKcevC1fUh4giAKl1923Znr(UOBsdtavJxWBgrWZAVnagTPQWLxt1fUoA(ctavJyKCye7yeGZ8mVUBQPbwGPmEg(iDqig5YfgTPQWLpwnfscqLXYWxycOAeJydJKdJyhJiaNbYkdgnmmAegX2n5b8k)o(2CvKcomGV5gm6jYLgUbPWEdenkBg4sDVDJl19g5vfgj0HbmgX(eB3ewvtMEUrsMeysYnHLH6eikZf99MmGlHuGOIRUW9a3arJCPU3(EUj3Dr3KgMaQgVG3KhWR874BXQPqgsa(T3Cdg9e5sd3GuyVbIgLndCPU3UXL6EBORMcj)zWib9BVjSQMm9CJKmjWKKBcld1jquMl67nzaxcParfxDH7bUbIg5sDV99CtKdx0nPHjGQXl4nJi4zT32mqwxEpKuiHKvmYLlmAamAtvHlpGIsJQU8fMaQgVjpGx53X3wWb6GKitLEX9MBWONixA4gKc7nq0OSzGl192nUu3BIahOdIrdLk9IlgX(Wz7MWQAY0ZnsYKatsUjSmuNarzUOV3KbCjKcevC1fUh4giAKl1923ZnjWfDtAycOA8cEZicEw7TndK1Lp6z2esumY9y0K7WixUWi2XOndK1L3djfsizfJKdJgaJ2uv4YRP6cxhnFHjGQrmITBYd4v(D8T5QifCyaFZny0tKlnCdsH9giAu2mWL6E7gxQ7nYRkmsOddymI9rSDtyvnz65gjzsGjj3ewgQtGOmx03BYaUesbIkU6c3dCdenYL6E775Mi3l6M0Weq14f8Mre8S2BBgiRlF0ZSjKOyK7XOj3DtEaVYVJVjUqY6SJIuOBO5EZny0tKlnCdsH9giAu2mWL6E7gxQ7nzlKSo7OWiHDdnxmI9j2UjSQMm9CJKmjWKKBcld1jquMl67nzaxcParfxDH7bUbIg5sDV997nJvj8PYt(LRNcpN7eqGV)]] )
    
    storeDefault( [[Wowhead: Simple]], 'actionLists', 20170625.202920, [[d0d7kaGEiO0Mii7csBJu1(ek8CcnBPMpIQ(eee9nI0TjQdtzNiSxLDdSFKyuqGHjKXbfk3dcQonObJKgou6GurNsO0XK05quPfIuwkPYILy5cEieu8uuldPADqqYeHcmvcmzQA6IUiP4Xq1LvDDi0gHcARqqyZKsBNk8rHI(keKAAeu9DeLdbfYZiIrdrFgk6Kcv)LkDnckNhrwjuO63K8Aev8QtWyct(JrOvKH8MhHIcvgkJT)ym4Ane7C0gR79nXpc6rvPr6Plm0k5kmHlCYDmJhGyZXJDINqfqCcgrDcgRbyL((rBmHj)Xy4Bku1HOiYX6EFt8JGEuvFvkAKK644ape3svymqb(ygpaXMJXrAbmVicNUqKZpwxTVDdikI0nCCKwatiaZXolWgMKgR9TBarrKlhb9jySgGv67hTXmEaInhNwFqIwALY3prpWk99KN8P1hKOYk5dseLrpWk99J19(M4hb9OQ(Qu0ij1XXbEiULQWyGc8XolWgMKg74amVweB3WZWTCmHj)XiehG51IytHQUNHB5YrizcgRbyL((rBmJhGyZXP1hKOAF7wSqWW8OhyL(EHWrAbmVicxyJ19(M4hb9OQ(Qu0ij1XXbEiULQWyGc8XolWgMKgR9TBXcbdZpMWK)ym8nfQ0SqWW8lhHWNGXAawPVF0gZ4bi2CCA9bjAPvkF)e9aR03luA9bjQSjMp4Q06MiVlMTbDC0dSsF)yDVVj(rqpQQVkfnssDCCGhIBPkmgOaFSZcSHjPXjYGImxmBd64Jjm5pwaYGImkuJzBqhF5ie2emwdWk99J2ygpaXMJtRpir1(29beXMqfa9aR03pw37BIFe0JQ6RsrJKuhhh4H4wQcJbkWh7SaBysAS23UpGi2eQaJjm5pgdFtHQMaIytOcSCe6NGXAawPVF0gZ4bi2C8yDVVj(rqpQQVkfnssDCCGhIBPkmgOaFSZcSHjPXArmqYvP1nrExy3qVfGJjm5pgdrmqIcvLwkutKNc14Dd9waUCesNGXAawPVF0gZ4bi2CCA9bjQ)Ykaeh9aR03pw37BIFe0JQ6RsrJKuhhh4H4wQcJbkWh7SaBysA8jD3Yn5XeM8hRH0PqL2n5LJaJnbJ1aSsF)OnMXdqS5406dsuTWGy6wALYJEGv67jp5rGHNqh39GldVymKiuA9bjkostj6I33CC0dSsFFSJ19(M4hb9OQ(Qu0ij1XXbEiULQWyGc8XolWgMKgxAZFxVbW)yct(JP1M)uOIbga)lhb5obJ1aSsF)OnMXdqS5406dsuTWGy6wALYJEGv67jp5rGHNqh39GldVymKiuA9bjkostj6I33CC0dSsFFSJ19(M4hb9OQ(Qu0ij1XXbEiULQWyGc8XolWgMKg7VLiDfj7h7yct(JXGBjskuzY(XUCe1OjySgGv67hTXmEaInhNwFqIwALY3prpWk99cz4j0XDp4YWlgJ6yDVVj(rqpQQVkfnssDCCGhIBPkmgOaFSZcSHjPXjYGImxmBd64Jjm5pwaYGImkuJzBqhNcveuJD5iQ1jySgGv67hTXmEaInhNwFqIwAiW7QfXaj0dSsF)yDVVj(rqpQQVkfnssDCCGhIBPkmgOaFSZcSHjPXN0Dl3KhtyYFSgsNcvA3KPqfb1yxoIk9jySgGv67hTXmEaInhpw37BIFe0JQ6RsrJKuhhh4H4wQcJbkWh7SaBysASbaqKW2sOcmMWK)yNaaejSTeQalhrvYemwdWk99J2ygpaXMJtRpirlTs57NOhyL((X6EFt8JGEuvFvkAKK644ape3svymqb(yNfydtsJtKbfzUy2g0XhtyYFSaKbfzuOgZ2GoofQiGESlhrv4tWynaR03pAJz8aeBoUGOwTOYpnzvalsLiue1RidiKHNqh39GldVymQcHamkT(GeT0qG3vlIbsOhyL(EHWO06dsuCKMs0fVV54OhyL(EHWO06dsu)Lvaio6bwPVp2X6EFt8JGEuvFvkAKK644ape3svymqb(yNfydtsJpP7wUjpMWK)ynKofQ0UjtHkcOh7Yruf2emwdWk99J2ygpaXMJliQvlQ8ttwfWIujcfr9kYacz4j0XDp4YWlgJkfm(yDVVj(rqpQQVkfnssDCCGhIBPkmgOaFSZcSHjPXjYGImxmBd64Jjm5pwaYGImkuJzBqhNcveij2LJOQFcgRbyL((rBmJhGyZXJ19(M4hb9OQ(Qu0ij1XXbEiULQWyGc8XolWgMKgJJ0uIUIzasoFmHj)XiminLifQCgGKZxoIQ0jySgGv67hTXmEaInhpw37BIFe0JQ6RsrJKuhhh4H4wQcJbkWh7SaBysAS)YkGOBbMFmHj)XyWLvaesrkuPbZVCevm2emwdWk99J2ygpaXMJtRpir9xwbClT5Vi6bwPVximkT(GeT0kLVFIEGv67hR79nXpc6rv9vPOrsQJJd8qClvHXaf4JDwGnmjnorguK5IzBqhFmHj)XcqguKrHAmBd64uOIaHh7YLJzShhAneH1sOcmcHjv6Yna]] )

    storeDefault( [[Wowhead: Complex]], 'actionLists', 20170625.202920, [[daKMqaqiLGnHu6tevvnkukNcP4veHODrPHjuhdKLHcpJOmnLqDnIQSnPKVrHghrvLZreP1recZJiuDpIO2hrLdQeTqI0djQktKiIlkf2OsiFKiOtQu5MeHYorvlvk1tjnvkyReHKVseO2l0FvkdgP6WuTyP6XGAYsCzvBwiFwkA0OKtJ41ebmBGBly3k(nHHRKwUKEosMUORtrBxPQVJs14jcKZJkwpri18rL2pkAecnGkVhoQsWc2zDVirWKU8jcRGlbHQK8i3eKOuuBFWDQJ8mIHmg3IH8SqsQ8w8ILuuv4kznrf1LWjrmuObKhcnGAJX7GxqPOQWvYAIkQl7eaj5GkSyOmdFl4njWOUBkeypfvuhXCuBFWDQJ8mIHAbz0gldcvEpCuLpXqzgot6smVjbgtKNbAa1gJ3bVGsrvHRK1e1u0Sj4wyHaueSpuO2(G7uh5zed1cYOnwgeQ7Mcb2trf1rmhvEpCuLyp9GOUYsqrOqDzNaijhudp9GOUYsqrOWe5LHgqTX4DWlOuu59Wrv(y5ckM0Lc8YPqT9b3PoYZigQfKrBSmiu3nfcSNIkQJyoQl7eaj5GkmlxqT1bE5uOQWvYAIAkA2eClSqakc2hkAzRBgfzdp9GOUYsqrOS1hCYqjNKHyWLlSqakc2hB4Phe1vwckcLT(Gtgk5C4KiglmlxqT1bE5uwyHaueSpsKqmObtKFXObuBmEh8ckfvfUswtutrZMGBHfcqrW(qH6YobqsoOopCkcfQ7Mcb2trf1rmhvEpCu5F4uekuBFWDQJ8mIHAbz0gldctKxEObuBmEh8ckfvEpCux0bmP32KIfQTp4o1rEgXqTGmAJLbH6UPqG9uurDeZrDzNaijhuJoyRAsXcvfUswtuPEMKPjLvc8VUfDWw1KI1w9WS8AtY0KjDAzsNnM0Hz51MNAlQ6WjrmoGjD5Kmt6qwJYJjDAzsNnM0xGj90bFsB0bBbNkFLJ9J3bVWKoxUmPhzw5ylpIatsM0LtYmPllMjDAysNgmr(wObuBmEh8ckfvfUswtuth8jTR1V61xSF8o4fUCzlDWN0geHpPzW(X7GxODHUzuKnicFsZG1CLguBFWDQJ8mIHAbz0gldc1DtHa7POI6iMJkVhoQsuFA(itat6TFwVNOUStaKKdQ7)08rMGT6Z69etK3iAa1gJ3bVGsrvHRK1ev2wiDWN0geHpPzW(X7Gx4YTBgfzdIWN0mynxPHwywET5PKS8qT9b3PoYZigQfKrBSmiu3nfcSNIkQJyoQ8E4OUOdysxQxREZJ6YobqsoOgDWw3RvV5Xe5LFObuBmEh8ckfvfUswtuHz51MNsojdznkpAzlDWN02bcrb80(X7GxOnDWN0gCQ81nr0wY6Bnboz)TF8o4fAOLTfsh8jTbr4tAgSF8o4fUC7Mrr2Gi8jndwZvAqT9b3PoYZigQfKrBSmiu3nfcSNIkQJyoQ8E4OAGvvWot6siWj7pQl7eaj5GAYQkyFRjWj7pMiVKIgqTX4DWlOuuv4kznrnDWN0gDW2RMRjrm2pEh8cQTp4o1rEgXqTGmAJLbH6UPqG9uurDeZrL3dh1fDat6nQMRjrmOUStaKKdQrhS9Q5AsedMipumAa1gJ3bVGsrvHRK1ev2wiDWN0geHpPzW(X7Gx4YTBgfzdIWN0mynxPb12hCN6ipJyOwqgTXYGqD3uiWEkQOoI5OY7HJ6ImRCysxeXKEY6mPVdaifVsqDzNaijhuJmRC2erBjRVraasXRemrEii0aQngVdEbLIQcxjRjQPd(K2YdIHaB)4DWlC56Wjz)3(8a5uYXa12hCN6ipJyOwqgTXYGqD3uiWEkQOoI5OY7HJAdoNjDP3dOUStaKKdQNZ363dyI8qmqdO2y8o4fukQkCLSMOMo4tAJivQCRdeII9J3bVWLRdNK9F7ZdKtjhdUCzZHtY(V95bYPKtgTPd(KwywUGAdgCF)TF8o4fAqT9b3PoYZigQfKrBSmiu3nfcSNIkQJyoQ8E4Okf4LZKUK4d8rDzNaijhu7aV8TIpWhtKhsgAa1gJ3bVGsrvHRK1e10bFsBePsLBDGquSF8o4fUCD4KS)BFEGCk5yWLlBoCs2)TppqoLCYOnDWN0cZYfuBWG77V9J3bVqdQTp4o1rEgXqTGmAJLbH6UPqG9uurDeZrL3dhvj5EYIjDL9)vux2jasYb1Y9K1gf7)RyI8qlgnGAJX7GxqPOQWvYAIA6GpPTdeIc4P9J3bVqRdNK9F7ZdKtjheTSTq6GpPnicFsZG9J3bVWLB3mkYgeHpPzWAUsdQTp4o1rEgXqTGmAJLbH6UPqG9uurDeZrL3dhvdSQc2zsxcboz)zsNniAqDzNaijhutwvb7Bnboz)Xe5HKhAa1gJ3bVGsrvHRK1e1iZkhB5reyskNKLfJA7dUtDKNrmuliJ2yzqOUBkeypfvuhXCu59WrDrh0bE5OUStaKKdQrh0bE5yI8qTqdO2y8o4fukQkCLSMOMo4tA7aYu2ImRCSF8o4fuBFWDQJ8mIHAbz0gldc1DtHa7POI6iMJkVhoQn4CM0LEpWKoBq0G6YobqsoOEoFRFpGjYdzenGAJX7GxqPOQWvYAIA3mkYgE6brDLLGIqznxPLTfsh8jTbr4tAgSF8o4fUC7Mrr2Gi8jndwZvUCJmRCSLhrGjPeNrmnO2(G7uh5zed1cYOnwgeQ7Mcb2trf1rmhvEpCuxodHfb4jrmOUStaKKdQ(meweGNeXGjYdj)qdO2y8o4fukQkCLSMOMo4tA7aHOaEA)4DWl0Y2cPd(K2Gi8jnd2pEh8cxUDZOiBqe(KMbR5knO2(G7uh5zed1cYOnwgeQ7Mcb2trf1rmhvEpCunWQkyNjDje4K9NjD2yqdQl7eaj5GAYQkyFRjWj7pMipKKIgqTX4DWlOuuv4kznrTBgfzdp9GOUYsqrOSfb7dTSTq6GpPTditzlYSYX(X7GxODH0bFslmlxqTbdUV)2pEh8cTlKo4tAlpigcS9J3bVqdToCs2)TppqoLCq061Ke5WP1NMMekwBIOTK13kh(K9VA)4DWlO2(G7uh5zed1cYOnwgeQ7Mcb2trf1rmhvEpCuBW5mPl9EGjD2yqdQl7eaj5G658T(9aMipJy0aQngVdEbLIQcxjRjQDZOiB4Phe1vwckcLTiyFO1HtY(V95bYPKdc12hCN6ipJyOwqgTXYGqD3uiWEkQOoI5OY7HJQbwvb7mPlHaNS)mPZMmAqDzNaijhutwvb7Bnboz)Xe5zaHgqTX4DWlOuuv4kznrLTUzuKnicFsZG1CLl3fsh8jTbr4tAgSF8o4fA4YnYSYXwEebMKsCgXO2(G7uh5zed1cYOnwgeQ7Mcb2trf1rmhvEpCuLpwUGIjDnRejWrDzNaijhuHz5cQnQSsKahtKNbd0aQngVdEbLIQcxjRjQWS8AZtjNKxmTSTq6GpPnicFsZG9J3bVWLB3mkYgeHpPzWAUsdQTp4o1rEgXqTGmAJLbH6UPqG9uurDeZrL3dh1fDat6s9A1BEM0zdIgux2jasYb1Od26ET6npMipdzObuBmEh8ckfvfUswtuJmRCSLhrGjPCsMrmQTp4o1rEgXqTGmAJLbH6UPqG9uurDeZrL3dhvj5bXi)PysxkjpQl7eaj5GA5bXqT1j5Xe5zSy0aQngVdEbLIkVhoQgyvfSZKUecCY(JA7dUtDKNrmuliJ2yzqOUBkeypfvuhXCux2jasYb1KvvW(wtGt2Fuv4kznrnDWN0wEqmBDGxoL9J3bVq7cPd(K2oqikGN2pEh8cMyIQUEyIdis0EsedYlpJgXera]] )

    storeDefault( [[Icy Veins: Single Target]], 'actionLists', 20170625.202920, [[dWdKjaGErkPnbvL2fuzBsPQ9jsPMnO5lsf3uKcUTi(gr5Zsj7ek7LA3q2VqnkOkAyc63O8yrDEuPblKHRehuaNcQsogrohufwiQYsLIfRulNKhksLEkYYiQwNifAIKcMkPAYs10LCrb60apdQkUUsAJKcTvPuQntkTDPu8rPuYHvmnrQ67KIETuQCzvJgv8CcNuK8xuvxdQQUNif1HGQuJtKs8jrkYwY6MWMKBkvMBCuBFasKgJJiaQf8Xr6JQ1ltuwbwktMAo8J4gtEOKSW2lh)4KWd8N(0JhMOLNbdeKwNcWqgd)YKzkqUamKW6gtY6McIMn8DZZe2KCtyp5cGWeLvGLYuXA1cECzgd2zAIeMcSbqqX1e6jxaeMAUGTQYxyDxMAo8J4gtEOKmPqtPqDqEkMYeIHUlJj36McIMn8DZZe2KCtA8W4OMvbhtuwbwkt4zCK4vbqTe4A3)cFThYxTk4Wx9mNr1cGAfhLoPtCunWJkCApKFYiQR4I7OzdFpocVIJW34OmNr16c(AvtUam0aJJs70CCKeoz43uGnackUM0EiF1QGJPMlyRQ8fw3LPMd)iUXKhkjtk0ukuhKNIPmHyO7Yy4J1nfenB47MNjSj5M04HXr8gLAADtuwbwktMcSbqqX1K2d5VhLAADtnxWwv5lSUltnh(rCJjpusMuOPuOoipftzcXq3LXsV1nfenB47MNjSj5M04QIBCetBCuX5XrPGqqFuatuwbwktMcSbqqX1K2vfx(mT8loNpacb9rbm1CbBvLVW6Um1C4hXnM8qjzsHMsH6G8umLjedDxgd)w3uq0SHVBEMWMKBki3hhX7tsCeEQHNWqGmEzIYkWszQg4rfU(tyiqg3rZg(ECe(ghH3Xr7vTAXL8AsyQfombqGBDXuGnackUMo3ZF)jXuZfSvv(cR7YuZHFe3yYdLKjfAkfQdYtXuMqm0DzS2BDtbrZg(U5zcBsUjnEyCuq16sbyituwbwktMcSbqqX1K2d5F16sbyitnxWwv5lSUltnh(rCJjpusMuOPuOoipftzcXq3LXKzDtbrZg(U5zcBsUjDokMMXrTfCaT5Xr4jpiJ1HVWltuwbwkt1apQWTHmwh(c3rZg(UPaBaeuCnvCumn53coG2CtnxWwv5lSUltnh(rCJjpusMuOPuOoipftzcXq3LXslw3uq0SHVBEMWMKBkn8AsyQfombqyIYkWszQyTAbpUmJb7mnrI4i8nocVJJ2RA1Il51KWulCycGa36IPaBaeuCnL8AsyQfombqyQ5c2QkFH1DzQ5WpIBm5HsYKcnLc1b5Pyktig6UmgEyDtbrZg(U5zcBsUP0LZWeXr8Gt)ctuwbwktfRvl4XLzmyNPjsykWgabfxtzodtWFdN(fMAUGTQYxyDxMAo8J4gtEOKmPqtPqDqEkMYeIHUlJjfADtbrZg(U5zcBsUjEWP)4inmO8nrzfyPmvd8OcNwGsu83qgRJ7OzdF3uGnackUM2WPF(9bLVPMlyRQ8fw3LPMd)iUXKhkjtk0ukuhKNIPmHyO7Yyssw3uq0SHVBEMWMKBsdFkoXrKM)lMOScSuMQbEuHtlqjk(BiJ1XD0SHVBkWgabfxt9pfh(cn)xm1CbBvLVW6Um1C4hXnM8qjzsHMsH6G8umLjedDxgtsU1nfenB47MNjSj5M04HB40VjkRalLjTRkU46xlidQ4O0oocFcnfydGGIRjThUHt)MAUGTQYxyDxMAo8J4gtEOKmPqtPqDqEkMYeIHUlJjHpw3uq0SHVBEMWMKBkD5mmrCevkq7UjkRalLjtb2aiO4AkZzyc(IsbA3n1CbBvLVW6Um1C4hXnM8qjzsHMsH6G8umLjedDxgtk9w3uq0SHVBEMWMKBkacb4aGtbyituwbwktMcSbqqX10Gqaoa4uagYuZfSvv(cR7YuZHFe3yYdLKjfAkfQdYtXuMqm0Dzmj8BDtbrZg(U5zcBsUjn8egknjIJ4bQBIYkWszcVJJQbEuHR)egI)go9lWD0SHVBkWgabfxt9NWqc(BqDtnxWwv5lSUltnh(rCJjpusMuOPuOoipftzcXq3LXKAV1nfenB47MNjSj5M05OyAgh1wWb0MBIYkWszQg4rfU(tyi(B40Va3rZg(UPaBaeuCnvCumn53coG2CtnxWwv5lSUltnh(rCJjpusMuOPuOoipftzcXq3LltA4ANvyzEUSba]] )

    storeDefault( [[Icy Veins: Opener]], 'actionLists', 20170625.202920, [[dOdcgaGEvOQnHcYUeW2qbAFOqA2iMpkuDtuiUTuANQ0EP2ns7xi)uOsnms1Vv13qrdvfkgSGgUuCqb6uQqPJrkNJi0cjklvKwmHwojpufIEk0YiQEoQMikOMQiMSunDjxufSovi5YGRRI2irWwvHuBMi9yrDEuQtR0NjOVteDyfpdfkJgLmnHkoPq5Ve4AcvDpuaJsfQ8AvimoHkzR5eJ3PfmglZok8OHLYpQOW4UbOGYiMvBtz0ykqGHd(kxxJPodkp(aAsm(4ehjAeBG8oK94NAFQVXZKPXG5AFk3j(Q5eJhOJib6wMX70cgpMV2NAeZQTPmwVqHeiqZx7t5rHmuuyTTquidefQBmfiWWbFLRRXut3yqXLSfBJnFTp1ykW)tvg4oXLXy0(MN6vgPpfmYiF)oTGXN0fi5OC5RCNy8aDejq3YmENwWiJa10(QgwpF5gXSABkJ1luibcK)N0FjPCJbfxYwSn2c10(QgwpF5gtb(FQYa3jUmMcey4GVY11yQPBmgTV5PELr6tbx(YyoX4b6isGULz8oTGXl0c8LBeZQTPmwVqHeiq(Fs)LKYnguCjBX2ifAb(YnMc8)uLbUtCzmfiWWbFLRRXut3ymAFZt9kJ0NcU8nooX4b6isGULz8oTGrjaerY0bJywTnLrPNk2b6G0nVvuiJgfYy6gdkUKTyBukqejthmMc8)uLbUtCzmfiWWbFLRRXut3ymAFZt9kJ0NcU8nENy8aDejq3YmENwW4rYAEEuOmY0bUrmR2MYy9cfsGa5)j9xsk3yqXLSfBJzwZZfisMoWnMc8)uLbUtCzmfiWWbFLRRXut3ymAFZt9kJ0NcU8LbDIXd0rKaDlZ4DAbJmmmfROqusaAmIz12ugRHa0kG0vXlbIK)7ba6isGUXGIlzl2g7WuSeWLeGgJPa)pvzG7exgtbcmCWx56Am10ngJ238uVYi9PGlFz6eJhOJib6wMX70cgLaqIctp5SmIz12ugpUOqou1sfYdCea0iqkqeOo5SeOGmRrjCPcJczCgpkSgcqRasbIG2HxGIDaGoIeOhfESrHmuuyM1OecCbsvtU2NoKOqgLbIc1cWmEJbfxYwSnkficuNCwgtb(FQYa3jUmMcey4GVY11yQPBmgTV5PELr6tbx(gxoX4b6isGULz8oTGrjaKOqzJsncbJywTnLrJbfxYwSnkficehLAecgtb(FQYa3jUmMcey4GVY11yQPBmgTV5PELr6tbx(krNy8aDejq3YmENwWOeovSJcFPrHflikmgHS9rTgXSABkJgdkUKTyBu6PITGxQGIfiyjKTpQ1ykW)tvg4oXLXuGadh8vUUgtnDJXO9np1RmsFk4YxnDNy8aDejq3YmENwWyqkDzTKP2NAeZQTPmAmO4s2ITXHsxwlzQ9Pgtb(FQYa3jUmMcey4GVY11yQPBmgTV5PELr6tbxUmYWG05KuwMlBa]] )

    storeDefault( [[Icy Veins: AOE]], 'actionLists', 20170625.202920, [[d0JimaGEjuvBIczxizBekzFcHhlPzJQ5tbFscvCyvUncFtc2jLSxODdA)a)ucvzys04quW5PiNMudwvdhL6GiLoLu0XOuNJqPwif1srjlMGLtYdruKNs1YespxWePq1urQMSunDrxer16KqLUSY1rXgfIARikQnluBNq1hruO5HOKpJi(oI0ZKqzusHrti)vkDsKIPHOuxJcL7jHCicfVwiYVjA0gPJU1rm0PPAc8K5PHHIl4PT4ro6EvPzNOJoRX3fgAfT0UqPyf1yu2ITXiBYwSr3zVQ(46I)LAjeTmwHcOtBn1syaPJw2iD0jhEc81rZOBDed9ipo4zXeeHUxvA2j6naFE8btQ4XBjUqoLjQbpb(6G3iWhZOmr1xSUQtWhrrGVyLGVj4nya8naFv0PizH2y1vtTeECWhrrG3MQGXaVrGpSm1qscurAJDB84TkMGOw1QIofjAijGVj4nya8naFE8btkcjXGjdb1GNaFDWBe4fd4fyIJPiKedMmeumSbFt0PvqZ1Pj0JhVvXeeHoRfKmQ6ciDmrN147cdTIwAxWUeDAGDD9sPcDOeomrROiD0jhEc81rZOBDedDY8GKSygo4zTuTlr3Rkn7e9gGpp(GjfB1yFQ1Pg8e4RdEJaFmJYevLrPgmbpzve4jdgd8nbVbdGVb4ZJpysrijgmziOg8e4RdEJaVyaVatCmfHKyWKHGIHn4BIoTcAUonHU4dsYIz4TQLQDj6SwqYOQlG0XeDwJVlm0kAPDb7s0Pb211lLk0Hs4WeTkgshDYHNaFD0m6whXqpYJdEZNsDKm09QsZorVb4fd4ZJpysrijgmziOg8e4RdEdgaVatCmfHKyWKHGIHn4nya8naFvk5DjPqkXhKKfZWBvlv7sk1ionma(iaFj4nc8vPK3LKcPIhVvXeervfDkswa8Kf4TbFtW3eDAf0CDAc94XBfoL6izOZAbjJQUasht0zn(UWqROL2fSlrNgyxxVuQqhkHdt0ISr6Oto8e4RJMr36ig6rMrzc8YyWNIg4PHZ19tPr3Rkn7e9gGxmGpp(GjfHKyWKHGAWtGVo4nya8cmXXuesIbtgckg2G3GbW3a8vPK3LKcPeFqswmdVvTuTlPuJ40Wa4Ja8LG3iWxLsExskKkE8wftqevv0PizbWtwG3g8nbFt0PvqZ1Pj0JzuMALXTPO1Q5CD)uA0zTGKrvxaPJj6SgFxyOv0s7c2LOtdSRRxkvOdLWHjAzmKo6Kdpb(6Oz0ToIHo5Mg4nVJaDVQ0St0BaEXa(84dMu9riH6k1GNaFDWBWa4fyIJPiwEesfBrYGoq1LKcbFtWBe4BaEXa(84dMuesIbtgcQbpb(6G3GbWlWehtrijgmziOyydEdgaFdWxLsExskKs8bjzXm8w1s1UKsnItddGpcWxcEJaFvk5DjPqQ4XBvmbruvrNIKfaFrGVe8nbFt0PvqZ1Pj0NP1kSJaDwlizu1fq6yIoRX3fgAfT0UGDj60a766Lsf6qjCyIwIfshDYHNaFD0m6whXq3m)6d8g)G1HUxvA2j6xn1IV2bhHEbWhrrGVyOtRGMRttOlWV(A7hSo0zTGKrvxaPJj6SgFxyOv0s7c2LOtdSRRxkvOdLWHjAvaPJo5WtGVoAgDRJyOB8DPiW7KUXgDVQ0St0VAQfFTdoc9cGpIIaFXqNwbnxNMqVVlf1giDJn6SwqYOQlG0XeDwJVlm0kAPDb7s0Pb211lLk0Hs4WeTidiD0jhEc81rZOBDedD6IussbpzKFAXh4ByMlLD(YMO7vLMDIEE8btkbUu25lPg8e4RdEJaFdWlgWNhFWKIqsmyYqqn4jWxh8gmaEbM4ykcjXGjdbfdBWBWa4Ba(QuY7ssHuIpijlMH3QwQ2LuQrCAya8ra(sWBe4RsjVljfsfpERIjiIQk6uKSa4jlWBd(MGVj60kO560e6PiLK0ws4Nw8HoRfKmQ6ciDmrN147cdTIwAxWUeDAGDD9sPcDOeomrlXgPJo5WtGVoAgDRJyOBMF9bEJFW6aFJiRvHe8M5szVj6EvPzNONhFWKkwRczRaxk7udEc81rNwbnxNMqxGF912pyDOZAbjJQUasht0zn(UWqROL2fSlrNgyxxVuQqhkHdt0YUePJo5WtGVoAgDRJyOB8DPiW7KUXg8nISwfsWBMlL9MO7vLMDIEE8btQyTkKTcCPStn4jWxhDAf0CDAc9(UuuBG0n2OZAbjJQUasht0zn(UWqROL2fSlrNgyxxVuQqhkHdt0Y2gPJo5WtGVoAgDRJyOtMeDYa49uPJ0q3Rkn7e9RMAXx7GJqVa4JOiWhf8gb(84dMuvrNm0w57eFudEc81rNwbnxNMqVk6KH2qQ0rAOZAbjJQUasht0zn(UWqROL2fSlrNgyxxVuQqhkHdt0YokshDYHNaFD0m6whXqNUiLKuWtg5Nw8HUxvA2j6xn1IV2bhHEbWhrrGpk60kO560e6PiLK0ws4Nw8HoRfKmQ6ciDmrN147cdTIwAxWUeDAGDD9sPcDOeomrl7IH0rNC4jWxhnJU1rm0jtIoza8EQ0rAGVHDt09QsZorpMrzIQYOudMGpIIaFHsWBWa4Ba(84dMu9riHTc8RVa1GNaFDWBe4JzuMOQmk1Gj4JOiWlwLGVj60kO560e6vrNm0gsLosdDwlizu1fq6yIoRX3fgAfT0UGDj60a766Lsf6qjCyIw2KnshDYHNaFD0m6whXq34JqclobWBwNdDVQ0St0fd4ZJpys1hHe2kWV(cudEc81rNwbnxNMqVpcjm0kOZHoRfKmQ6ciDmrN147cdTIwAxWUeDAGDD9sPcDOeomXeDJV4JHNOzmrea]] )

    storeDefault( [[Icy Veins: Default]], 'actionLists', 20170625.202920, [[dmZ(caGEijTjHsTlivBdvQ2NqjZMWnrLCBsStLAVu7wv7hIFcfgMu8BbdwLgUu1brvogrohKuluOAPkPflvwUkEiKipfSmuvpNutevktvitMKMUOlsuDzKRlL2kuQndLSDibpgLPju8DijoSIVru(SsCAjNevSoiLRbfDEOQ)cvMhKqpdsuBjhzypkKbom8ixSP61OHC5gH10ksda7u9PbdRKGgn5n)gjznCNpMOlHAmJjguBa6jwnIcvNScV3yktMbESScV2rEl5idY)PtqQoUH9OqgqPWRBviKlxZsXmaSt1NguPUwSWcD2OZ6xqVT3aVUsujEdSWRBviCkZsXmSs6q7HrAh50WkjOrtEZVrsMuJboVAXMmCm8HNC6nFhzq(pDcs1XnShfYag90thda7u9PHmSSii0zHGqnGkVg5gBKBwkeYffrUsyAyLe0OjV53ijtQXaVUsujEdSriWnSScporPtdRKo0EyK2ronW5vl2KHJHp8KbUcQ7rHmWHHh5InvVgnKlg90thNEJYoYG8F6eKQJBypkKbEyi3aWovFAyyzHceo6jLI0i3yHCLmSscA0K38BKKj1yGxxjQeVb2ie4gwwHhNO0PHvshApms7iNg48QfBYWXWhEYaxb19Oqg4WWJCXMQxJgYLhgYD6DmoYG8F6eKQJBypkKbO(fbHCJMZcLga2P6tdgwjbnAYB(nsYKAmWRRevI3aBecCdlRWJtu60WkPdThgPDKtdCE1Inz4y4dpzGRG6EuidCy4rUyt1Rrd5c1ViiKB0CwO0PtdCJWAAfPJ70ga]] )

    storeDefault( [[Red Vengeance: precombat]], 'actionLists', 20170625.235018, [[dmt2baGEuH2ff12Oq7tO0SbDBQYovQ9s2nK9ROggu9BPmyPQHRihev1XeCouIwiQYsHslwilNkpNs9uvpwjRdLkteLWuvWKPQMoWfLkoSOlJCDubBeLsBfLuBwH2oQKpIsXYqXNHIVJk68sLUgQuJwO6BuKtsbpJs60sUhkv9xkX4qj51cfRGg03PhPJL8N7znHWqjArSBUFYrRMxuc0zbnMCacepDSeKsBsBg8GjCJmCBMbNHLm6FIwvcloMGQH0MBwf05VavdzRbTdAqVdkJGKV4PVtps)fMco33gN7zlm9iDSeKsBsBg8GXGjZ4wd6gq(1kbnNoQHiD(rfSaD1Tlmf0sB0Yim9i9VC1eqxaTz0GEhugbjFXtFNEKUb0i5qjCU)axfdPJLGuAtAZGhmgmzg3Aq3aYVwjO50rnePZpQGfOREHgjhkHwSbUkgs)lxnb0xXthgYow2heqBRAqVdkJGKV4PVtpsFiURX5CpBGzXfPJLGuAtAZGhmgmzg3Aq3aYVwjO50rnePZpQGfORoiURXPfmWS4I0)YvtaDbeq)lxnb0fqc]] )

    storeDefault( [[Red Vengeance: default]], 'actionLists', 20170625.235018, [[dieamaqisfSjvLgfPkNIuvRsiLAxsAyc1XG0YifptvQPHsPCnuQ2MQkFdcgNqkohkfADKk08qfDpvj7JuP)HsrDqvfluvvpeLImruk4IquBKurNecTsvrQUjkLStu1pvfjgQqkzPIupLQPcrUQQiPTQkIVIsPAVi)fkdMu6WuwmkESOMSexgSzf9zHy0cjNM41cPA2sDBOA3Q8BsgUiwUGNRW0v66OKTls(UQOoVQW6vfPmFuH9JknHsiroVHdKNgkC1(e4Ia2LbDKR2cmnw9soBaMgREP)KNgAWgaXRjgfH4FAyVQjwdBud5EcKfRLNMTI6iE2JguY)KxrDdcjIhLqIC2svEIf4nCGCwdaBirKgtnXMTHdK75GKSKR3AnCBD2goGLd2iQkCgtdLVfGH1CwhsePXutSzB4qna4MCdoFHQphCONoSwd3wNTHdy5GnIQcNX0qrFY5nCG8N6a4Q1LisZvRAYvRoBdhyZK)HrAzFqEkligtdKJ4vKSTQa5N6aYtdnydG41eJ(dfHA8BuYr(mMgk0FAjEnesKZwQYtSaVHdK)Sjl2ufWscIki7dmJrAzfyqUNdsYsUEzLQlQNVQGJRABf1HzScwna4MCdoJRS)nXKRwGPKLv3xOSRphCO3AnCBDcntBfOcNX0q5BwP6I65RoHMPTcudaUj3GZ4k7Ftm5Qfykzz19vIjhwbMswwSwWLvFo4qV1A426eAmiWkzf1vHZyAO8nRuDr98vNqJbbwjROUAaWn5gCgxzxFo4qVuwqmMgQSga2qIinMAInBdh(A5vsbyWb4cm09LMVzLQlQNV6qIinMAInBdhQba3KBWzCLD95Gd9IcSEJQMaHmClNVk2fbcyBubyeLQlFZkvxupF1j0yfiLnwBf1vdaUj3GZ4k7Ftm5QzwHaCRUVEhRp5FyKw2hKNYcIX0a5PHgSbq8AIr)HIqn(nk5iEfjBRkq(PoGCEdhiNTBYYv7uf4QnAfevq2hC1(HrAzfyWMjh5ZyAOq)PL4FtiroYNX0qH(tUNdsYs(QIePHkRbGvGjCdjfmi)dJ0Y(G8S1nMLxrDyTmwYtdnydG41eJ(dfHA8BuYr8ks2wvG8tDa58goqoBaMWnKuWGC2sv4nCG80qHR2NaxeWUmOJC1wGjCdjfmOL4zBesKJ8zmnuO)KZB4a5UIvZvlBQblfqEAObBaeVMy0FOiuJFJsoIxrY2QcKFQdi)dJ0Y(G8HIvJLBWsbK75GKSKNyYvZScb4wDF9l(ldR5SouSASzWIGd3oQJ1YrpAZoNVIcSEJQwGPKLfljV0s8StiroYNX0qH(tUNdsYs(AnCBDKibzXyu4mv4mMgkFladR5SodM07JAaWn5gCY(xgwZzDOy1yZGfbhUDuhRLJUUVqjpn0GnaIxtm6pueQXVrjhXRizBvbYp1bKZB4a5EIeKLR2)kCgY)WiTSpiFKibzXyu4m0s8)iKih5ZyAOq)j3ZbjzjpXKRwGPKLv3xOStEAObBaeVMy0FOiuJFJsoIxrY2QcKFQdiN3WbYrehx12kQJR2pScg5FyKw2hKl44Q2wrDygRGrlXJaHe5iFgtdf6p5Eoijl5wELuagCaUadDFP5BbyynN1HerAm1eB2goudaUj3GZxOKNgAWgaXRjg9hkc143OKJ4vKSTQa5N6aY5nCGCxIinxTQjxT6SnCG8pmsl7dYhsePXutSzB4aTeF0qiroYNX0qH(tUNdsYs(AnCBDcntBfOcNX0q5BIjxTatjlRUVsm5WkWuYYI1cUSKNgAWgaXRjg9hkc143OKJ4vKSTQa5N6aY5nCGCDcntBfG8pmsl7dYNqZ0wbOL4zJesKJ8zmnuO)KZB4a5pL5eUHKcgK75GKSKVQirAOMvQUOE(gKNgAWgaXRjg9hkc143OKJ4vKSTQa5N6aY)WiTSpipBDJz5vuhwlJLC2sv4nCG80qHR2NaxeWUmOJC1QMt4gskyqlXJgtiroYNX0qH(tUNdsYsULxjfGbhGlW4f631A426my5LvaQWzmnu(MyYvlWuYYYzIjhwbMswwSwWLL80qd2aiEnXO)qrOg)gLCeVIKTvfi)uhqoVHdKRZGLxwbG8pmsl7dYNblVScaTepkkHe5iFgtdf6p5Eoijl5fGH1CwhsePXutSzB4qna4MCdoFHsEAObBaeVMy0FOiuJFJsoIxrY2QcKFQdiN3WbYDjI0C1QMC1QZ2WbUA1dvFY)WiTSpiFirKgtnXMTHd0s8OAiKih5ZyAOq)j3ZbjzjxpDyTgUTodwEzfGkCgtdfo4WYRKcWGdWfyO7ln6)nXKRwGPKLLZetoScmLSSyTGll5PHgSbq8AIr)HIqn(nk5iEfjBRkq(PoGCEdhi3vSAUAztnyPaUA1dvFY)WiTSpiFOy1y5gSuaTep6BcjYr(mMgk0FY9CqswYxRHBRtOXGaRKvuxfoJPHc5PHgSbq8AIr)HIqn(nk5iEfjBRkq(PoGCEdhixNqZvlYbwjROoY)WiTSpiFcngeyLSI6OL4rzBesKJ8zmnuO)K75GKSKNYcIX0qL1aWgsePXutSzB4Wx9YkvxupFv5Mq4SgBSbj6qnhLfIadSzWYROoR19fAnAyNdoS8kPam4aCbg6(sJ(CF6KNgAWgaXRjg9hkc143OKJ4vKSTQa5N6aY5nCGCeVjeoR5Q13GeDG8pmsl7dYLBcHZASXgKOd0s8OStiroYNX0qH(toVHdK7rbwGRw9q1N80qd2aiEnXO)qrOg)gLCeVIKTvfi)uhq(hgPL9b5JOalqUNdsYsUoKYcIX0q9ztw5IGnvbSKGOcY(aZyKwwbg0sl5Eoijl50se]] )

    storeDefault( [[Red Vengeance: defensives]], 'actionLists', 20170625.235018, [[dSd5iaGEkk0MuvTlkTnvH9PQKzJY8POOBQQu1TjLVjfTtkSxKDlz)Osnkkk1Wiv)MWPv5Xs1GrfgouDqvrNIIkogQ6CuuPfkfwQQIfdXYv6HuuYtPAzevRJIcMOQszQQsnzsMUIlIk68uKldUUuAJIkzRQkv2mr2UOIpJk55ImnrLY8ev9xr5zQsgnKoSWjHI(ou4Aef3dknokQ64IkvVMO0ep9MCJqdi)dO4MJVdkUGO6GzGBouGeuPlhir(3aPOLnudY)amisazixNVP(d5YyLRl3CLtUJd9lyNzmMtuKHmMNN8N95evIEtg80BY5ScegOOgKBeAa5UOLXnhMvS5al5FagejGmKRZ)GVPv)fp5ywQRhJyjVefq(tKJDJjYtIwwwp2CGLCVVh(qoK7ThooOSbtTrh9YWiwewOG0pkeSb1IdBhQjp2MY8J0kjztIwwM0gCPb1KSPj6YIv)xbiTsswPdwtziBuk7cAXvjS60qgYP3KZzfimqrni3i0aY)gOjkU5WXpzHe5FagejGmKRZ)GVPv)fp5ywQRhJyjVefq(tKJDJjYvGMOYs4NSqICVVh(qEhnwUGuM0g95evW(clVTPm)iTsswfOjQSe(jlKSlOfxLWQ)RaKwjjR0bRPmKnkLDbT4Qew9F84kBVDxOMVWkx)hfc2GAXHTd1KhR5LHgY4f9MCoRaHbkQb5gHgqEUoynXnhn2OuK)byqKaYqUo)d(Mw9x8KJzPUEmIL8sua5pro2nMix6G1ugYgLICVVh(qokeSb1IdBhQjpwZlZpsRKKvbAIklHFYcjRsGr9J0kjz1Gj0eloQiDjRsGr9J0kjztIwwgsS7bRvjWO(7cbtjWOSkqtuzj8twiz7OXYfKYZtdzKB0BY5ScegOOgK799WhYrHGnOwCy7qn5XkJm)tWGASsaltb5ePjMtuwOcegO(XJRS92DHA(c7lDY)amisazixN)bFtR(lEYXSuxpgXsEjkGCJqdipxaJBo(gKtKMyorr(tKJDJjYLawMcYjstmNOOHmKHEtoNvGWaf1GCJqdi)7Hj0eloQiDjY)amisazixN)bFtR(lEYXSuxpgXsEjkG8Nih7gtKRbtOjwCur6sK799WhYrHGnOwCy7qn5X23BUEWYg0fsOcMYmntZgfc2GAXHTd1KhBUP)Jhxz7T7c1KhRC9)UqWucmkR0bRPmKnkLDbT4Q0x6)kaPvsYkDWAkdzJszvcmQFKwjjRc0evwc)KfswLaJ6VlemLaJYQanrLLWpzHKTJglxqktAJ(CIky51TYyo0qgpO3KZzfimqrni377HpKJcbBqT4W2HAYJvffxWMnOlKqfmf5FagejGmKRZ)GVPv)fp5ywQRhJyjVefqUrObK7Iwg3C0i29GL8Nih7gtKNeTSmKy3dwAiJM0BY5ScegOOgK799WhYrHGnOwCy7qn5XQIIlyZg0fsOcM6hpUY2B3fQ5lSp0j)dWGibKHCD(h8nT6V4jhZsD9yel5LOaYncnGCx0Y4MdZIbroa5pro2nMipjAzzDge5a0qgMNEtoNvGWaf1GCVVh(qokeSb1IdBhQjpwvuCbB2GUqcvWu)iTsswfOjQSe(jlKSkbg1psRKKvdMqtS4OI0LSkbg1psRKKnjAzziXUhSwLaJI8padIeqgY15FW30Q)INCml11JrSKxIci3i0aYZ1bRjU5OXgLIBomBEZH8Nih7gtKlDWAkdzJsrdzyU0BY5ScegOOgKBeAa5yQPjyXCIIBoE2Ub5FagejGmKRZ)GVPv)fp5ywQRhJyjVefq(tKJDJjYpnnblMtuzr7gK799WhYrHGnOwCy7qn5XQIIlyZg0fsOcM6hpUYQaPRFZxy5LHgYGxNEtoNvGWaf1GCJqdipxadHfkG8padIeqgY15FW30Q)INCml11JrSKxIci)jYXUXe5sadHfkGCVVh(qokeSb1IdBhQjpwvuCbB2GUqcvWu)tWGASsadHfkWcvGWa1pECLvbsx)MVWIhxLPaPRFtg70UHgYGNNEtoNvGWaf1GCJqdi3rHyj)dWGibKHCD(h8nT6V4jhZsD9yel5LOaYFICSBmrEcfILCVVh(qokeSb1IdBhQjpwvuCbB2GUqcvWu0qd5EFp8HCAic]] )

    storeDefault( [[Red Vengeance: offensives]], 'actionLists', 20170625.235018, [[dOZ8daGEuvPnHQSlj2giAFKkZMK5trUjkQ62OYoLK9ISBf7xjzuqPggf(TuonvpgWGLunCq6GqjNcf6yq15qvPwOKYsvsTyqTCipevf9urltjwhQkzIKImvqyYs10fUiPuhM4zuuxNu1gjf1wrvHnd02vQopu8zsHMgkQ8Duv1ZP04qrPrJIIVHICssj)fLUgPG7PuEnk4YQoeQQycNGGYkH7uU(9v15JpA8YaC(Av9gi4hRVFlLA6GIEvq1OC9vxSNQwmWzYaYfnuwmw47fktOhWfLZVs4THQ0aZItjwaH3glbbvHtqqP2JaRENQrzLWDk1SFeMv1RHKPt56RUypvTyGdjotfdZ4uQ10DajAikN2CkXc2vEGHsq)imSWiz6uMaihAqj2ckCqbikG(ryy7NZTVGKHbDB48cr9jkGxX2)Uydj82u(iWQ35b0AQEJ)tb8k2(3fBiH3Mc6CIp2ndEqfFka6rOpHUnZgmAYe28tiQprb8k2(3fBiH3MYhbw9UjtckCqbikG(ryy7NZTVGKHHndgPGQwiiOu7rGvVt1OSs4oLA(Qv1103fBiH3gkxF1f7PQfdCiXzQyygNsTMUdirdr50MtjwWUYdmucEfB)7InKWBdLjaYHgugI6tuaVIT)DXgs4TP8rGvVZdQ4tbqpc9j0Tz2Gh2ylOWbfGOa6hHHTFo3(csgg0THZtacF)SFoNF7goV(H1dcwa9JWWcJKPxqNt8XQBBHrtMWwqHdkarb0pcdB)CU9fKmmSzyYKae((z)Co)wDBlmYifuLzcck1Eey17unktaKdnOme1NOyH6ipyHBCWLpcS6DEcq47N9Z58B1TTWdwpiyX20RybrIg5(e2Ineag0THtzLWDktOoYJv1R14GPC9vxSNQwmWHeNPIHzCk1A6oGeneLtBoLyb7kpWqPfQJ8GfUXbtzYmn(Z8TUd6hzjykOkMJGGsThbw9ovJYea5qdkPC9vxSNQwmWHeNPIHzCk1A6oGeneLtBoLvc3PmB6vRQZNcA)ikXc2vEGHsBtVIfqq7hrbfuMaihAqjfeb]] )

    storeDefault( [[SimC Vengeance: default]], 'actionLists', 20170625.202920, [[d8tbpaWBiRxejTjcPDrITPKAFIO8Cu60QA2umFrQ6Mc68KKVjKESI2PO2R0Uvz)kvgLqudtOgNif)vHomvdwP0WrrhuPQtje5yeCocrTqf0srHwmuTCIEOizvcbltewNisyIIi1uvkMmLMoQUiuQxjIeDzW1juBuKsBffSzLy7c4Zc03jeMMiQMNqOxts9mfy0qX4je5Kkj3sKkxdkX9Gs6PihseXTj1vOBkLDnuIEDQDBzaUGGFtiPy3wlS4In8sety(U5tQo)rxZyjncLyemGZcnNiwiA86eyrrqKXsYtUixIMYNjVuP9t(Jo2UPzHUPe2NJBaBhwkezzWLzxdLkLDnukf6yfRHDBd9G)SukmWuDikaOHJx8smcgWzHMtelSwiQs8aHsRo7pDosw6qhuAp(BEUQst0XkwdJAp4plfISzxdLkV5eDtjSph3a2oSenLptEjCXllkwqJUrwMVAGvXIeXjkU4LffnWDnsYedI9zvSirCL2J)MNRQ0YdsvJ4s)SLsHbMQdrbanC8IxkezzWLzxdLkLDnukTpivTB7qPF2smcgWzHMtelSwiQs8aHsRo7pDosw6qhukezZUgkvEZd6MsyFoUbSDyjAkFM8stmUmiWI1ePp94IxwuSGgDJSmF1aRIfjIt0KyrCLLhKQgXL(zv4)u9Fbffx8YIIg4UgjzIbX(SkwKiUs7XFZZvvYcA0nYY8vdSLsHbMQdrbanC8IxkezzWLzxdLkLDnukPbn62TLy(Qb2smcgWzHMtelSwiQs8aHsRo7pDosw6qhukezZUgkvEZjVBkH954gW2HLOP8zYlLe2p4BgzA8jyfnj)nUy(Gy4IkbT)hB64spayg5VgsNfmUQigRmicwXsN)OtuxY)fFYvwEqQA0c6NfuGZXnGvulIRS8Gu1iU0pRc)NQ)lyP94V55Qk93cip3mYYLVAOukmWuDikaOHJx8sHildUm7AOuPSRHsRUfqEUz3wIlF1qjgbd4SqZjIfwlevjEGqPvN9NohjlDOdkfISzxdLkVzS0nLW(CCdy7Ws0u(m5Lsc7h8nJmn(eSIMK)gxmFqmCrLG2)JnDCPhamJ8xdPZcgxveJvgebRyPZF0jAKtIl5)Ip5klpivnAb9ZckW54gWM(0hzTlsJtmUmiWMUjgxgeyhxK(K)OZnrkcsyIXLbHr(RHioriJfjItz5bPQrCPFwfjO9)ytkXsKenYteYyrI4uy)GVzeTmUyCnOibT)hBYIM(0pX4YGalwtePs7XFZZvv6VfqEUzKLlF1qPuyGP6quaqdhV4LcrwgCz21qPszxdLwDlG8CZUTex(QHDBJSqKkXiyaNfAorSWAHOkXdekT6S)05izPdDqPqKn7AOu5nVUBkH954gW2HLOP8zYlzbCXllkls)nCvkwKiUs7XFZZvvIL5lF(iosJxkfgyQoefa0WXlEPqKLbxMDnuQu21qjI5lF(UTdrA8smcgWzHMtelSwiQs8aHsRo7pDosw6qhukezZUgkvEZr7MsyFoUbSDyjAkFM8swexz5bPQrCPFwf(pv)xWs7XFZZvvIfj2moDzaqwkfgyQoefa0WXlEPqKLbxMDnuQu21qjcj2SBBkxgaKLyemGZcnNiwyTquL4bcLwD2F6CKS0HoOuiYMDnuQ8Mtt3uc7ZXnGTdlrt5ZKxIP)NYuSuchpIynnXL2J)MNRQ0R1iJZF0n6ILEPuyGP6quaqdhV4LcrwgCz21qPszxdLwP1iJZF0TB7EXsVeJGbCwO5eXcRfIQepqO0QZ(tNJKLo0bLcr2SRHsL3Si3nLW(CCdy7Ws0u(m5Ly6)PmflLWXJiwJgxAp(BEUQslGb34wOukmWuDikaOHJx8sHildUm7AOuPSRHsPfm4g3cLyemGZcnNiwyTquL4bcLwD2F6CKS0HoOuiYMDnuQ8MfI7MsyFoUbSDyPqKLbxMDnuQu21qjcj2SB7qxkFqwkfgyQoefa0WXlEjgbd4SqZjIfwlevjEGqPvN9NohjlDOdkTh)npxvjwKyZiUlLpilfISzxdLkVzbHUPe2NJBaBhwIMYNjVelsSzCr6b1WXzXkwkTh)npxvjwKyZ40aEaOukmWuDikaOHJx8sHildUm7AOuPSRHsesSz32ugWdaLyemGZcnNiwyTquL4bcLwD2F6CKS0HoOuiYMDnuQ8Mfs0nLW(CCdy7Ws0u(m5L4OGbnGYeHmwKiowrJmU4LfflOr3ilZxnWQyrI4enjwexz5bPQrCPFwf(pv)xqrXfVSOObURrsMyqSpRIfjIt0)Mi9FbhTU2dcJyHnzya3WXOODrkcXkrJJuP94V55QkPbURrsMyqSpBPuyGP6quaqdhV4LcrwgCz21qPszxdLcbURrsMyqSpBjgbd4SqZjIfwlevjEGqPvN9NohjlDOdkfISzxdLkVzHbDtjSph3a2oSenLptEP)Mi9FbhTU2dcJyHnzya3WXOODrkcXkrJlTh)npxvPfWmAHaol35p6kLcdmvhIcaA44fVuiYYGlZUgkvk7AOuAbZUTjneWz5o)rxjgbd4SqZjIfwlevjEGqPvN9NohjlDOdkfISzxdLkVzHK3nLW(CCdy7Ws0u(m5L(BI0)fC06ApimIf2KHvmGB4yu0UifHyLOXL2J)MNRQelsSzCAapaukfgyQoefa0WXlEPqKLbxMDnuQu21qjcj2SBBkd4bGDBJSqKkXiyaNfAorSWAHOkXdekT6S)05izPdDqPqKn7AOu5nlGLUPe2NJBaBhwkezzWLzxdLkLDnukTGz3wSLIzYF0vkfgyQoefa0WXlEjgbd4SqZjIfwlevjEGqPvN9NohjlDOdkTh)npxvPfWmcsXm5p6kfISzxdLkVzH1DtjSph3a2oSenLptEjjO9)ytNfmUQiI1yLbrWkw68hDL2J)MNRQe7h8nJOLXfJRHsPWat1HOaGgoEXlfISm4YSRHsLYUgkrFW3SBlAz320ACnuIrWaol0CIyH1crvIhiuA1z)PZrYsh6GsHiB21qPYBwiA3uc7ZXnGTdlrt5ZKxIP)NYuSuchpzynnXIYIeBgxKEqnCC2iMCr)BI0)fC06ApimMC2iIvmGB4yu0UifHyLeXL2J)MNRQ0I0NCXsOukmWuDikaOHJx8sHildUm7AOuPSRHsPv6tUyjuIrWaol0CIyH1crvIhiuA1z)PZrYsh6GsHiB21qPYBwinDtjSph3a2oSenLptEjM(FktXsjC8KH10exAp(BEUQsSiXMXPb8aqPuyGP6quaqdhV4LcrwgCz21qPszxdLiKyZUTPmGha2TnYjIujgbd4SqZjIfwlevjEGqPvN9NohjlDOdkfISzxdLkVzbrUBkH954gW2HLcrwgCz21qPszxdLimGllLcdmvhIcaA44fVeJGbCwO5eXcRfIQepqO0QZ(tNJKLo0bL2J)MNRQelgWLLcr2SRHsLxEPKgwCXgEhwEla]] )

    storeDefault( [[SimC Vengeance: precombat]], 'actionLists', 20170625.202920, [[b4vmErLxt5uyTvMxtnvATnKFGzvzUDwzH52yLPJFGbNCLn2BTjwy051utbxzJLwySLMEHrxAV5MxovdoX41usvgBLf2CL5LtYatm3aJnYuJlXKtn0qtoEn1uJjxAWrNxt51ubngDP9MBZ5fvE5umErLxtvKBHjgBLrMxc51utnMCPbhDEnfDVD2zSvMlW9gDP9MBZ51ubjwASLgD551uW9gDP9MBEnvsUrwAJfgDVjNxt52BUvMxt10BKzvyY5uyTvMxt51uofwBL51uq9gDP9MBEnvqYD2CEnLBH1wz9isDUjwzUrwAUD2xW9gDP9MBI41usvgBLf2CL5LtYatm2eZnUaZmX41udHwzJTwtVzxzTvMB05LyEnvtVrMtH1wzEnvDUjwzUrwAUD2xW9gDP9MBErNx051uevMzHvhB05LqErNxEb]] )



    storeDefault( [[Havoc Primary]], 'displays', 20170625.202920, [[d0JXgaGEPkVerLDHOqBdrrMPuvEmsMTc3wL6MOkAAOQ6Bsv14quWoP0Ef7MW(Lc)ufgMI63qonjdffdMIA4i1bLkpNuhJkohQclukTukIftHLtvpuf1tbltLyDik1evrAQq1KjstxPlQixfrvxwvxhHnseBLIuBgv2ou6JsrDyjFgr(ovAKQiEgIsgnknEvsNekUffjxdvLZtuhhvP1IOOETuKJtWdqv0RcjKGelSYJpWb5X7dJDkavrVkKqcsSGQ3hRZLa(sq6pZ(unL2agdvVEnpqUXiG8bhN(3Zf9QqcDSZbUEWXP)9CrVkKqh7CaEjEIxkgkKau9(y5FoWTs0nflzfGxIN4LEUOxfsOtBa5doo9V4LN0V6yNdOzrUGRAPy7MsBanlYTJyrPnGMf5cUQLITJyrPnWwEs)2jOyr(aTh44h80emnFcEGRhCC6FjxRowNaYhCC6FjxRowt5eqZICXlpPF1PnqtgDckwKpa(bJjyA(e8akHufvTiFNGIf5dycMMpbpavrVkKOtqXI8bApWXp4zaG(Pu1q1RwfselF93FanlYfWtBaEjEI)uL)PwfseWemnFcEabXngkKqhl)b00)yizuA2ZObYh8avSobmI1jaPyDc4J1jBanlY9CrVkKqhJaxp440)2r4RyNdue(cxM(dyqWXf4UU2rSOyNdymu9618a52ngXiqnOzlGf5YGDkwNa1GMToJUnQLb7uSobo95kIXM2a1WTK1myzsBaSkTYqnuRmUm9hWiavrVkKOBOijcCEYIpzsaPkn9OKXLP)avaFji94Y0FGYqnuRCGIWx8uj(0gOjdjiXcQEFSoxcudA2cV8K(LbltSob8)iW5jl(Kjb00)yizuA2yeOg0SfE5j9ld2PyDcWlXt8sXiKQOQf51PnGTU)aNuyrunmZ4v3LxoWwEs)kbjwyLhFGdYJ3hg7uGBLOJyrXohOjdjiXcR84dCqE8(WyNcihjMImWJ(Vm7Wh)o8GVlK1C)ZHZu8ZxGAqZwDd3swZGLjwNaxJDoaTxDxEzjiXcQEFSoxcq7Fk0TrTDm9fadLCdZM(vcnz3W8Ppxrm2akkKGmJq3X6WxG76A3uSZbuuibqxukbPy5lWwEs)YGDkgbO9Q7YlJHcjavVpw(NdOzrUmyzsBaEjEIVBOijUFXgGkW1doo9Vyesvu1I86yNdiFWXP)fJqQIQwKxh7CGT8K(vcsSbyWBygkHUHzB59i3axp440)IxEs)QJDoGMf5IrivrvlYRtBanlYTJWxyeCOyeOgULSMb7uAdOzrUmyNsBanlYTBkTbOq3g1YGLjgbkcF1jOyr(aTh44h8SVjj4bkcFb0)yG50yNdWlHIQjtR0Wkp(avGBLaWJDoWwEs)kbjwq17J15sGIWxyeCiCz6pGbbhxaQIEviHeKydWG3WmucDdZ2Y7rUbQbnBDgDBuldwMyDcmjkJXlnTb0QB6X3Dmf7LaYhCC6F7i8vSZbAYqcsSbyWBygkHUHzB59i3a1GMT6gULSMb7uSob2Yt6xgSmXiaf62OwgStXiGMf5sUx2qjKQeK0PnGj)4l9h7LzN(Njtx4Jm6Wd(4NFEe4UUc4X6eOg0SfWICzWYeRtaEjEIxQeKybvVpwNlb4qInadEdZqj0nmBlVh5gGxIN4LsUwDAdi95kIX2X0xamuYnmB6xj0KDdZN(CfXydue(I8c1gGEuYVpBca]] )

    storeDefault( [[Vengeance Primary]], 'displays', 20170625.202920, [[d0JWgaGEPuVKa1UufuVwsQzkL4Xq1Sv44eKBsqzAQc9nvbzCiiANuSxXUrz)ev)urnmvv)gYPjzOOYGLedhPoOu55K6ysQZHG0cLILQQ0IjYYL4HQIEkyziW6iOYevfyQqzYiY0v5IsvxLa5YkDDKSrIYwjaBMqBhr9rPKomvFwr(oLAKeqpdbHrJQgVQItIq3cbLRjj58uYTvLwlbvTneuDQdwaCN(uiMme7GZASbMfewlen9bWD6tHyYqSduT3yQjiqXzt7t(fV60eqAOA3U1bYosbSMff1790PpfIPJ5pWNzrr9EpD6tHy6y(die1sTKiIJyGQ9gZJ)bEvSU(yiebeIAPwspD6tHy60eWAwuuVhMxM2thZFanpYgSvhoFxFAcO5r2Duhknb08iBWwD48DuhknboVmTxhdNhvc0mJHnlSVeBvGyb(mlkQ3tWn6yQdynlkQ3tWn6yiS6aAEKnMxM2tNMavl1XW5rLayZCFj2QaXcOyKu4(HkDmCEujWxITkqSa4o9PqSogopQeOzgdBwyba6fx5dvB)uiwmvriRdO5r2awAcie1sTpqvw8tHyb(sSvbIfGr9sehX0X8yan9ogYgUM)jAGkblGhtDaPyQdmftDGsm15cO5r2pD6tHy6if4ZSOOEVoQIhZFaNQ4yw0BajkrXaV(NoQdfZFaPHQD7whi7UXisb8bnVd8iBoY9XuhWh08(t0RKFCK7JPoWdwrNACPjGpSDlnhzU0eGSsRKud1zHzrVbKcG70NcX6gQjwGN9gS(VbiP00d3cZIEd4bkoBAXSO3aUKAOoRaovXfMITPjq1sYqSduT3yQjiGpO5DmVmThhzUyQdu2rGN9gS(Vb007yiB4A(ifWh08oMxM2JJCFm1beIAPwsezKu4(Hk60eW4VBabSSP1z4R8kCf1RxScCEzApzi2bN1ydmliSwiA6d8QyDuhkM)avljdXo4SgBGzbH1crtFaRyimcQIWd4dAEVBy7wAoYCXuh4tm)bOlQxVyjdXoq1EJPMGa0Lfh9k5xhxlb(UKKxralBADg(kCYRqxwC0RKFbu4iMWJqVXuxvGx)txFm)bu4igq74k2umvf48Y0ECK7Jua6I61lweXrmq1EJ5X)aAEKnhzU0eqiQLA7gQj27YUa4b(mlkQ3JiJKc3purhZFaRzrr9EezKu4(Hk6y(dCEzApzi2fGdtEfWzA5vmEPGSd8zwuuVhMxM2thZFanpYMiJKc3purNMaAEKDhvXjYerrkGpSDlnh5(0eqZJS5i3NMaAEKDxFAcGJEL8JJmxKc4ufVJHZJkbAMXWMfwl9YWc4ufhO3XG4dI5pGquk8QfGsdN1yd4bEvmalM)aNxM2tgIDGQ9gtnbbCQItKjIWSO3asuIIbWD6tHyYqSlahM8kGZ0YRy8sbzhWh08(t0RKFCK5IPoqpZLglP0eqREPhB3CFmeeWAwuuVxhvXJ5pq1sYqSlahM8kGZ0YRy8sbzhWh08E3W2T0CK7JPoW5LP94iZfPa4Oxj)4i3hPaAEKTGxljfJKInPttGV7yD9gdb)1p0pHtqvpCnHw1JpsObE9pawm1b8bnVd8iBoYCXuhqiQLAjjdXoq1EJPMGaIi2fGdtEfWzA5vmEPGSdie1sTKeCJonbiTIo1464AjW3LK8kcyztRZWxHtEfsROtnUaovXfetDbOhU1wYLa]] )

    storeDefault( [[Havoc AOE]], 'displays', 20170625.202920, [[dWJXgaGEPuVePs7srLABkQKzkLy2kCyj3ePIJJu1THkpdPe2jL2Ry3e2pr6Nsvdds9BvEoPgkQmyIy4i5GuXPj5ysX5qkPfQilLcAXO0YPQhQO8uWJryDiLYeHatfktMcnDLUOu5QuaxwvxhrBKISvfvSzu12HOpkL0NHQMMIQ(ovAKuuwgeA0Oy8ifNesUfsP6AqqNNO(gfO1IuIEnfvNMGfGOOw1jmDIfw5XhO3ayTGY2fylp(F5qYf2a(sG)NX8eMNPa0t(KVZqHxG7fBaIaY9886FNvuR6e6yrhGMEEE9VZkQvDcDSOdq5v4kVmkItaQ2FSZJoaoLWPlwAra6jFY34SIAvNqNPaY9886FXkp(F1XIoGM5Cbx1sW40f2aAMZ1HCVWgaxrdGfBtGT84)1rqWC(at9yy90XquTAgwa5yPDeBqhG)eBaomPsGsOLkXwE)5gqZCUyLh)V6mfWCwhbbZ5dG1ZziQwndlGsyuru75DeemNpGHOA1mSaef1QoHJGG58bM6XW6PtGzhLSujyxaZkKhHujo9Db0mNlGLPa0t(Kpcu(NyvNiGHOA1mSacsCOioHo25dOP(XW0O0mZUX5dwGk2Ma(yBcGp2MaSX2KnGM5CNvuR6e6WgGMEEE9VoK(kw0bksFHjt9byj55dGROXHCVyrhGDOA3U1X56mgHnqnOykG5C5q2fBtGAqXuZoCS1YHSl2Mai45lYXMPa1WTK1Ci5YuaKkTIvnuRmMm1hGnarrTQt4mu4fbM1zX6mmGrLMAuYyYuFaIa(sG)XKP(afRAOw5afPVOJs8zkG5SMoXcQ2FSnigOgumfw5X)lhsUyBc4)rGzDwSoddOP(XW0O0mHnqnOykSYJ)xoKDX2eGEYN8nIsyuru751zkaq9eQAOAxR6eXIqdAWa2c3hWSc5rivItFxGT84)10jwyLhFGEdG1ckBxaJpFrowhUwcGIqwQK58kHM2KkbbpFro2aMZA6elSYJpqVbWAbLTlan9886FP7Ko2Ma1GIPCgULSMdjxSnbQbftbmNlhsUyBcq5v4kVSPtSGQ9hBdIbO8pXHJTwhUwcGIqwQK58kHM2KkbbpFro2aAMZfCvlbJd5EzkaUIgNUyrhGMyrhylp(F5q2f2aAMZLdjxMcy4p(s)XIi6gdIEUqeHZDdTIW5NNwdOzox6(YSkHrLaVotbioCS1YHSlSbikQvDctNybv7p2gedudkMYz4wYAoKDX2eWCwtNydWHjvcucTuj2Y7p3aAMZfLWOIO2ZRZua5EEE9VoK(kw0bQHBjR5q2LPaAMZ1PlSb0mNlhYUmfG4WXwlhsUWgOgum1SdhBTCi5ITjqr6lhbbZ5dm1JH1tNw6mHfGEsfH5ZrPHvE8bydGtjaSyrhylp(FnDIfuT)yBqmqr6luc(dtM6dWsYZhGOOw1jmDInahMujqj0sLylV)CduK(cO(XafcIfDGorXoEJzkGwHJA8o9DXIyanZ56q6luc(lSbOPNNx)lw5X)Row0b2YJ)xtNydWHjvcucTuj2Y7p3aY9886FrjmQiQ986yrhGMEEE9VOegve1EEDSOdWouTB364CdBa6jFY3ikItaQ2FSZJoGI4eavrOe4JfHbueNGwEhUyBqya6jFY3OPtSGQ9hBdIbK7551)s3jDS0Eta6jFY3iDN0zkaoLWHCVyrhOi9LbeQna1OKFF2ea]] )



end

