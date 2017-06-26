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

        addTalent( 'chaos_blades', 211048 )
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
        addAura( 'chaos_blades', 211048, 'duration', 12 )
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

        addSetting( 'keep_fel_rush_recharging', false, {
            name = "Havoc: Keep Fel Rush Recharging",
            type = "toggle",
            desc = "If |cFF00FF00true|r, the addon will enable use of Fel Rush when solely for the purpose of keeping the ability recharging.  This is optimal by a small margin but may introduce movement and positioning issues in your gameplay.",
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
            usable = function () return cooldown.global_cooldown.remains == 0 end,
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
            id = 211048,
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



    storeDefault( [[SimC Havoc: default]], 'actionLists', 20170625.202920, [[deKrpaqiQIweaXMePAuOIofQKvbq6vIOKzPq0Terr7srddroMizzOcpdvrtdvHRjsX2av8nQcJtef6CkeSorknpeLUhQu7te5GkuleG6HiQMOik1frumsruDsqLMPcHUjvPDQGLcGNk1ubKTIQ0Ej(lqdwWHPSyqEmvMmjxw1MPQ6ZuvgnQQtd51kKMns3wu7wPFlz4aQLtQNJY0H66i02bLVlcNhu16frbZhb7xOLucqs3aFhYOOKbdJQvgsJhEiDY((nIuSayPb40BSldCqkLhKGdhPzMAesdp4Xii9GLV0nktEmKCdw5sBmOUFJifl9yhgvltasgsjajnzwdIELayPBNgbmwApJboJbpJbSr)IN7ZNHyZVge9QyGaHyWvfvvj25(8zi2uFtbFmqGqm4QIQQe7CF(meBQF2qllgskgWM23XtmkFqCbQqpgiqigCvrvvIDUpFgIn1pBOLfdjfdWHumWL0JHquegEPHzAKbrV0KZ)Ur9wWE(lwGK2BP410dw(sNWqy06d0FPb3NpdXKEWYx6gx6hd8AuIx6XAFmPxlFUtyimA9b6V0G7ZNHyJeMrjEU9KtpXg9lEUpFgIn)Aq0RiqWvfvvj25(8zi2uFtbpbcUQOQkXo3NpdXM6Nn0YscBAFhpXO8bXfOcDceCvrvvIDUpFgIn1pBOLLeCiXL0aC6n2LboiLYJuKKgGZkIA3zcqcwA4UkKZWLw6T2lT3sny5lTGLboeGKMmRbrVsaS0TtJaglTNXaNXGNXa2OFXthFRyGqutD28RbrVkgiqigCvrvvID64BfdeIAQZM6Bk4JbceIbxvuvLyNo(wXaHOM6SP(zdTSyiPyaBAFhpXO8bXfOc9yGaHyWvfvvj2PJVvmqiQPoBQF2qllgskgGdPyGlPhdHOim8sdZ0idIEPjN)DJ6TG98xSajT3sXRPhS8LoHHWO1hO)sd64BfdeIAQZKEWYx6gx6hd8AuIpg4mfxspw7Jj9A5ZDcdHrRpq)Lg0X3kgie1uNnsygL452to9eB0V4PJVvmqiQPoB(1GOxrGGRkQQsSthFRyGqutD2uFtbpbcUQOQkXoD8TIbcrn1zt9ZgAzjHnTVJNyu(G4cuHobcUQOQkXoD8TIbcrn1zt9ZgAzjbhsCjnaNEJDzGdsP8ifjPb4SIO2DMaKGLgURc5mCPLER9s7Tudw(slyzGNcqstM1GOxjaw62PraJL2ZyaB0V4P65ArU5xdIEvmKEm4QIQQe7mFSLlnW8lgIn1pBOLfdKngGtmKEm4NOg(P6(roeogskg4jPyi9yGZyWZyaMPrge9ZegcJwFG(ln4(8ziwmqGqm4QIQQe7CF(meBQF2qllgiBmKIumWvmKEmWzm4zmaZ0idI(zcdHrRpq)Lg0X3kgie1uNfdeiedUQOQkXoD8TIbcrn1zt9ZgAzXazJb4edCj9yiefHHxAyMgzq0ln58VBuVfSN)IfiP9wkEn9GLV0axffT(a9xAW8XM0dw(s34s)yGxJs8XaNCWL0J1(ysVw(CdCvu06d0FPbZhBJeMrjEU9eB0V4P65ArU5xdIEv6UQOQkXoZhB5sdm)IHyt9ZgAzKfoP7NOg(P6(roeojEskDo9eMPrge9ZegcJwFG(ln4(8zigbcUQOQkXo3NpdXM6Nn0YiBksCLoNEcZ0idI(zcdHrRpq)Lg0X3kgie1uNrGGRkQQsSthFRyGqutD2u)SHwgzHdxsdWP3yxg4GukpsrsAaoRiQDNjajyPH7QqodxAP3AV0El1GLV0cwg4HaK0Kzni6vcGLUDAeWyPXg9lE6hPzyqiAvQ5xdIEvmqGqmWogeQwISjgDnhKa5bWUyiPyGumqGqmyomc2b)(m6SyijUJbEgdjRyGZyaB0V4PJVvmqh9gSprGFni6vXaGgd8mg4s6XqikcdV0WmnYGOxAY5F3OElyp)flqs7Tu8A6blFPHOM6GkBDx6blFPBCPFmWRrj(yGtEYL0J1(ysVw(Cdrn1bv26(iHzuINBSr)IN(rAggeIwLA(1GOxrGa7yqOAjYMy01CqcKha7iqWCyeSd(9z0zjXnptwCIn6x80X3kgOJEd2NFni6vakp5sAao9g7YahKs5rkssdWzfrT7mbiblnCxfYz4sl9w7L2BPgS8LwWYqAeGKMmRbrVsaS0TtJaglnmtJmi6NqutDqLTUhdPhdCgd(jQHF6iQ1FXXazJbpstmKmJbSr)IN(rAggeIwLAIa)Aq0RIbang4GumWL0JHquegEPHzAKbrV0KZ)Ur9wWE(lwGK2BP410dw(sdCvu06d0FPbHOM6GkBDx6blFPBCPFmWRrj(yGtEWL0J1(ysVw(CdCvu06d0FPbHOM6GkBDFKWmkXZnmtJmi6NqutDqLTUNoN(jQHNSEKMKj2OFXt)inddcrRsn)Aq0RauoiXL0aC6n2LboiLYJuKKgGZkIA3zcqcwA4UkKZWLw6T2lT3sny5lTGLb4iajnzwdIELayPBNgbmwASr)INo(wXaD0BW(8RbrVkgspg8tud)uD)ihchdjfd8GK0JHquegEPHzAKbrV0KZ)Ur9wWE(lwGK2BP410dw(sdCvu06d0FPbD8TIbYWA0Ox6blFPBCPFmWRrj(yGZ0WL0J1(ysVw(CdCvu06d0FPbD8TIbYWA0OFKWmkXZn2OFXthFRyGo6nyF(1GOxLUFIA4NQ7h5q4K4bP09uBif4H9fpnLInjcC6AdPapSV4PPuSjAjlhaQpNsAao9g7YahKs5rkssdWzfrT7mbiblnCxfYz4sl9w7L2BPgS8LwWYGhcqstM1GOxjaw6XqikcdV0UAzeZhmB(qoPH7QqodxAP3AV0ElfVMEWYxAPhS8LM8AzeZpg8A(qoPb40BSldCqkLhPijnaNve1UZeGeS0KZ)Ur9wWE(lwGK2BPgS8LwWYqYOaK0Kzni6vcGLUDAeWyPDvrvvID6Jwqgf0vfvvj2P(zdTSyG7yGK0JHquegEPDgLcAomQwqkIHLMC(3nQ3c2ZFXcK0ElfVMEWYxAPhS8LMCJsJHXomQ2yyermS0J1(ysVw(CdinktEmKCdw5sBm4QIQQelGinaNEJDzGdsP8ifjPb4SIO2DMaKGLgURc5mCPLER9s7Tudw(s3Om5XqYnyLlTXGRkQQsScwggbbiPjZAq0RealD70iGXsJn6x8u9CTi38RbrVs6XqikcdV0AIlO5WOAbPigwAY5F3OElyp)flqs7Tu8A6blFPLEWYxAaiUXWyhgvBmmIigw6XAFmPxlFUbKgLjpgsUbRCPngupxlYbisdWP3yxg4GukpsrsAaoRiQDNjajyPH7QqodxAP3AV0El1GLV0nktEmKCdw5sBmOEUwKtWYqkscqstM1GOxjaw6XqikcdV0AIlO5WOAbPigwA4UkKZWLw6T2lT3sXRPhS8Lw6blFPbG4gdJDyuTXWiIy4yGZuCj9yTpM0RLp3asJYKhdj3GvU0gdBPZgfqKgGtVXUmWbPuEKIK0aCwru7otasWsto)7g1Bb75VybsAVLAWYx6gLjpgsUbRCPng2sNnQGfS0TtJaglTGfba]] )

    storeDefault( [[SimC Havoc: precombat]], 'actionLists', 20170625.202920, [[dyJgcaGEIuTjbPDjv2gkuZwOBkv9nu0ovP9sTBi7hQgfrvdtv53KgkrkdgkdNqhuvYPeOoMOCob0cfvTuuYIjy5k6HQs9uKLHs9CfMirWuvvnzvmDjxKOYLbxhfCAuTvbyZer2UQWJLYHvAAeL(orsJKi0NfuJwu52ICsII1Hc5AQIoVa51cIdrK4VerTZ8VjseA8nYL(wCf57tMmnjbqsldXY5nXcIWoaFz)LX8JXSF2Lf4tzLnqt3nbMiE6noMe3hAJr4yItOPjHTm9QvCfn8VVz(3KCOvichN3e1MCXYuPHdhHorT4kAy6LapYRGmjQfxrMKbD4TT0PjKIat96jGDE3eyY0DtGjPPfxrMybryhGVS)YyM9zIfmugMny4FxMENdAH0RpGeGklyQxp3nbMC5lB)Bso0keHJZBIAtUyzQ0WHJqxt14rLkAGJfkoM84ysbhtECSAJaQ6oqsrsEcc6e1bOvichCSqXXQncOQ7ajfXBDaAfIWbhlyCSGn9sGh5vqMsqTjDkMth8HjzqhEBlDAcPiWuVEcyN3nbMmD3eyQhQnPtXC6GpmXcIWoaFz)LXm7ZelyOmmBWW)Um9oh0cPxFajavwWuVEUBcm5YLjQn5ILjx2]] )

    storeDefault( [[SimC Havoc: normal]], 'actionLists', 20170625.202920, [[daeuzaqijKnrs5tajvgfsPtHuSkju6veIYUqLHrOogaltI8msQmnGuDnsQABeIQVraJdijNdifRdiP08ie5EsOAFechKuyHeOhskAIaP0fLaBeiXhLqXibsQ6Ksq3eO2jQAPKKNszQKWwjLSxv)fknyihw0IL0JHQjl4YkBgqFgignuCAHEnH0Sj62uz3i(nkdhPA5u1ZrY0L66KQTtI(oPuNxIA9ajfZNG2pOpGR4gODatDzFbVz0hEmLrqnzhzKZREbe4MQjxsTZxsmabelYlPEoaGg1d6GoO5MH7J07B30aVJmc1vCEaxXTcizvUWf8MH7J07B0crDkhP5O7h90Va3izvUaejuie1PCKMZXCJ06oUrYQCbiIgisniQQdeihD)ON(f4cmTjqKAquvhiqohZnsR74cmTj30OgLXU8nLJaYaQlX6x7x23kKeI4zZ83imYUbMf0k98PB3UXNUDtRraza1LqKQ1(L9nvtUKANVKyacaq8nvJIP7Xh1v8(MMygUOGzkNBK(1BGzb(0TBVpFPR4wbKSkx4cEZW9r69nAHOoLJ0CoMBKw3XnswLlarcfcrDkhP5aojwxs1ZxMBKSkxaIObIudIOfIkcI6uosZ5yUrADh3izvUaejuierleHJj9GmkiQ4qujisOqicNXKbM2eoLJaYaQlX6x7x2C(5YiHcIebeb6qenqKAquvhiqohZnsR74cmTjqenqKAqeTqurquNYrAoGtI1Lu98L5gjRYfGiHcHiG6(YCHbmIhBisefhIkPEiIgisniIwicht6bzuquXHOsqen30OgLXU8nGtI1RtH5wHKqepBM)gHr2nWSGwPNpD72n(0TBGYKqKkDkm3un5sQD(sIbiaaX3unkMUhFuxX7BAIz4IcMPCUr6xVbMf4t3U9(8Q7kUvajRYfUG3mCFKEFJwiQQdeiNJ5gP1DC60HiHcHOIGOoLJ0CoMBKw3XnswLlar0arQbr0crjEhvoSJmxCuqKiGiaqen30OgLXU8nGtITMEFcYUvijeXZM5VryKDdmlOv65t3UDJpD7gOmjejy69ji7MQjxsTZxsmabai(MQrX094J6kEFttmdxuWmLZns)6nWSaF62T3Nh0VIBfqYQCHl4nd3hP336uosZvLmwqUMBKSkxaIudIOfIkcI6uosZ5yUrADh3izvUaejuiev1bcKZXCJ06ooD6qenqKAqeoM0dYOGOIdrLUPrnkJD5BngptBSGiZOYDRqsiINnZFJWi7gywqR0ZNUD7gF62nfy8mTHOIrMrL7MQjxsTZxsmabai(MQrX094J6kEFttmdxuWmLZns)6nWSaF62T3Nx9xXTcizvUWf8MH7J07Ba19L5W19(rAisKGiaQhIudIOfIWzmzGPnHlSSXGLs7n6C(5YiHcIejiQeevSqei4bisOqicNXKbM2eUQmddBij4JZpxgjuqKibrLGOIfIabpar0CtJAug7Y3aozvMHDRqsiINnZFJWi7gywqR0ZNUD7gF62nqzYQmd7MQjxsTZxsmabai(MQrX094J6kEFttmdxuWmLZns)6nWSaF62T3NxKFf3kGKv5cxWBgUpsVVPm9XSkhxvMHHnKe8DtJAug7Y3clBmyP0EJ(TcjHiE2m)ncJSBGzbTspF62TB8PB3aTlBmqKP9g9BQMCj1oFjXaeaG4BQgft3JpQR49nnXmCrbZuo3i9R3aZc8PB3EFEbUIBfqYQCHl4nd3hP33WXKEqgfevCiQeePgerTUJeqO4eDJowGtI1RtHbRF4yspirciqKAqurquNYrAohZnsR74gjRYfGi1GOIGOoLJ0CaNeRlP65lZnswLlCtJAug7Y3aojwVofMBfscr8Sz(Begz3aZcALE(0TB34t3UbktcrQ0PWar0cGMBQMCj1oFjXaeaG4BQgft3JpQR49nnXmCrbZuo3i9R3aZc8PB3EFEq1vCRaswLlCbVPrnkJD5BaNe78607iJCRqsiINnZFJWi7gywqR0ZNUD7gF62nqzsiQaVo9oYi3un5sQD(sIbiaaX3unkMUhFuxX7BAIz4IcMPCUr6xVbMf4t3U9(8GMR4wbKSkx4cEZW9r69nAHOeVJkh2rMlokiseqeaiIgisOqiIwiIwiQiiQt5inNJ5gP1DCJKv5cqKqHquvhiqohZnsR740Pdr0arQbr0crfbrDkhP5WXKmkSvzggf3izvUaejuiev1bcKdhtYOWwLzyuC60HiHcHiCgtgyAt4WXKmkSvzggfNFUmsOGirarQtmejuie1PhK1CD0nSndBioisKGiCgtgyAt4WXKmkSvzggfNFUmsOGiAGiAUPrnkJD5Ba19LXYaITXmSrPmgsF8wHKqepBM)gHr2nWSGwPNpD72n(0TBGIUVmeXacrnMbrfkLXq6J3un5sQD(sIbiaaX3unkMUhFuxX7BAIz4IcMPCUr6xVbMf4t3U9(8aeFf3kGKv5cxWBgUpsVVPm9XSkhxvMHHnKe8brQbrfbr4mMmW0MW5wNoMNoggvKIZVmu(Mg1Om2LVvLzyydjbF3kKeI4zZ83imYUbMf0k98PB3UXNUDtqzggebAtc(UPAYLu78LedqaaIVPAumDp(OUI330eZWffmt5CJ0VEdmlWNUD795ba4kUvajRYfUG3mCFKEFRt5inxvYyb5AUrYQCbisnikX7OYHDK5IJcIerXHOsqKAqeTqurquNYrAoxs1ZJLbeBJzybrMrLJBKSkxaIekeIkcI6uosZ5yUrADh3izvUaejuiev1bcKZXCJ06ooD6qenqKAqeTquI3rLd7iZfhfejIIdrQdIO5Mg1Om2LV1y8mTXcImJk3TcjHiE2m)ncJSBGzbTspF62TB8PB3uGXZ0gIkgzgvoiIwa0Ct1KlP25ljgGaaeFt1Oy6E8rDfVVPjMHlkyMY5gPF9gywGpD727ZdO0vCRaswLlCbVz4(i9(gqDFzUWagXJnejIIdrQtmejYGOQoqGC09JE6xGtNoevSqeO6Mg1Om2LVbCYQmd7wHKqepBM)gHr2nWSGwPNpD72n(0TBGYKvzggerlaAUPAYLu78LedqaaIVPAumDp(OUI330eZWffmt5CJ0VEdmlWNUD795bOUR4wbKSkx4cEZW9r69TeVJkh2rMlokiseqeaisOqiIwikX7OYHDK5IJcIerXHi1br0arcfcr0crDkhP5QYijGfOUVm3izvUaePgebu3xMlmGr8ydrIO4qK6uperZnnQrzSlFBLh26s3TcjHiE2m)ncJSBGzbTspF62TB8PB3kO8Gibx6UPAYLu78LedqaaIVPAumDp(OUI330eZWffmt5CJ0VEdmlWNUD795ba6xXTcizvUWf8MH7J07B0crDkhP5cZXiyRYmmkUrYQCbisOqiQiiQt5inNJ5gP1DCJKv5cqKqHquvhiqohZnsR740Pdrcfcra19L5cdyep2qKibrQtmejYGOQoqGC09JE6xGtNoevSqeOcIekeIQ6abY5wNoMNoggvKIZpxgjuqKibrQhIObIudIkcIuM(ywLJJoJjJeqWcK5XwLzyydjbF30OgLXU8TKqIyIYSJmYTcjHiE2m)ncJSBGzbTspF62TB8PB30GqIyIYSJmYnvtUKANVKyacaq8nvJIP7Xh1v8(MMygUOGzkNBK(1BGzb(0TBVppa1Ff3kGKv5cxWBgUpsVV1PCKMRkzSGCn3izvUaePgerlevee1PCKMZLu98yzaX2ygwqKzu54gjRYfGiHcHOIGOoLJ0CoMBKw3XnswLlarcfcrvDGa5Cm3iTUJtNoerZnnQrzSlFRX4zAJfezgvUBfscr8Sz(Begz3aZcALE(0TB34t3UPaJNPnevmYmQCqeTLO5MQjxsTZxsmabai(MQrX094J6kEFttmdxuWmLZns)6nWSaF62T3NhGi)kUvajRYfUG3mCFKEFRiiQt5inxvYyb5AUrYQCbisniQQdeiNBD6yE6yyurkUatBcePgeL4Du5WoYCXrbrIO4qK6UPrnkJD5BngptBSGiZOYDRqsiINnZFJWi7gywqR0ZNUD7gF62nfy8mTHOIrMrLdIOvD0Ct1KlP25ljgGaaeFt1Oy6E8rDfVVPjMHlkyMY5gPF9gywGpD727ZdqGR4wbKSkx4cEZW9r69nAHOoLJ0CH5yeSvzggf3izvUaejuievee1PCKMZXCJ06oUrYQCbisOqiQQdeiNJ5gP1DC60HiHcHiG6(YCHbmIhBisKGi1jgIezquvhiqo6(rp9lWPthIkwicubr0arQbrfbrktFmRYXrNXKrciybY8yXXKmkSuTpk6Gi1GOIGiLPpMv54OZyYibeSazESU1jePgeveePm9XSkhhDgtgjGGfiZJTkZWWgsc(UPrnkJD5B4ysgfwQ2hfD3kKeI4zZ83imYUbMf0k98PB3UXNUDttmjJcIS2hfD3un5sQD(sIbiaaX3unkMUhFuxX7BAIz4IcMPCUr6xVbMf4t3U9(8aavxXTcizvUWf8MH7J07BfbrDkhP5Cm3iTUJBKSkxaIudIOfI6uosZfMJrWwLzyuCJKv5cqKqHquvhiqo360X80XWOIuCbM2eiIMBAuJYyx(gWjX61PWCRqsiINnZFJWi7gywqR0ZNUD7gF62nqzsisLofgiI2s0Ct1KlP25ljgGaaeFt1Oy6E8rDfVVPjMHlkyMY5gPF9gywGpD727Zda0Cf3kGKv5cxWBAuJYyx(wyogHcBn27wHKqepBM)gHr2nWSGwPNpD72n(0TBG25yeqDuqKGXE3un5sQD(sIbiaaX3unkMUhFuxX7BAIz4IcMPCUr6xVbMf4t3U9(8LeFf3kGKv5cxWBgUpsVV1PhK1CrcwFsaz30OgLXU8TgJNPnwqKzu5UvijeXZM5VryKDdmlOv65t3UDJpD7McmEM2quXiZOYbr0c60Ct1KlP25ljgGaaeFt1Oy6E8rDfVVPjMHlkyMY5gPF9gywGpD727ZxcWvCRaswLlCbVz4(i9(wNEqwZfIuDsWhejcicG6HiHcHOo9GSMlsW6tci7Mg1Om2LVbCYQmd7wHKqepBM)gHr2nWSGwPNpD72n(0TBGYKvzggerBjAUPAYLu78LedqaaIVPAumDp(OUI330eZWffmt5CJ0VEdmlWNUD795lv6kUvajRYfUG3mCFKEFRtpiR5crQoj4dIebebq9qKqHqeTquNEqwZfjy9jbKbrQbrfbrDkhP5Cm3iTUJBKSkxaIO5Mg1Om2LVbCsSEDkm3kKeI4zZ83imYUbMf0k98PB3UXNUDduMeIuPtHbIOvD0Ct1KlP25ljgGaaeFt1Oy6E8rDfVVPjMHlkyMY5gPF9gywGpD727ZxsDxXTcizvUWf8MH7J07BD6bznxis1jbFqKiGiaQ)Mg1Om2LVPCeqgqDjw)A)Y(wHKqepBM)gHr2nWSGwPNpD72n(0TBAncidOUeIuT2VSHiAbqZnvtUKANVKyacaq8nvJIP7Xh1v8(MMygUOGzkNBK(1BGzb(0TBVpFjq)kUvajRYfUG3mCFKEFRiiQt5inxvYyb5AUrYQCHBAuJYyx(wJXZ0gliYmQC3kKeI4zZ83imYUbMf0k98PB3UXNUDtbgptBiQyKzu5GiAvpn3un5sQD(sIbiaaX3unkMUhFuxX7BAIz4IcMPCUr6xVbMf4t3U9(9n(0TBw0PjebQpvYWb1creM3LY3)a]] )

    storeDefault( [[SimC Havoc: cooldown]], 'actionLists', 20170625.202920, [[dWJBhaGAIISEjbTjOk7cvTnIsTpjHMTcZhkDti1Tj5XqStISxWUj1(vzuIOHHk(TWHvAOsQQgSQgUeoirvNsKCmOY5ikQfsrSuryXuy5u6HevEkvltK65eMOKQYuPOMSOMUuxusX3GQ6zef66qY5PiTvjP2mQ02vuonktJOKpRiZts0ijkWFLOrdfhIOGoPKsFxr11Ku5EsQY6Ke4YiVwsYaoWm4sRIa3zk5UxgSZcKk4EKig5yUg86J4UOgnyc4jObTccKsZbh(CKD664XjZ1jlzjZG7iwwrdo4YJ0SqlaZGeoWm41OxJbLbta3rSSIg8oMMgepseJCmxlUhV7tEVm8(K337G0nFMuHMHWt61yq57XI9(zRLTgdIViIbtpvYnSLkQ37XI9(zRLTgdIF(YAMEQKByl1KIemX9yXE)S1YwJbXpFzntpvYnSLiy2quAm2mjUp19yXEFV2jQ5BMIk7OmZO7R8(01DFkWL3GnyTPGROEvHTatiycWRvNziBhwW1HMahDKRETsRIahCPvrGJM6vf2cmHGjapbnOvqGuAo4WhhhWtqIaLfHeGzObxomesvOJzKI0nyao6ilTkcCObP0GzWRrVgdkdMaUJyzfn4DmnniEKig5yUwCpE3N8(EhKU5ZKk0meEsVgdkFpE3BGIlxEf1RkSfycbtWJQ4E8UNlkRP8iOSws33x59YIZ9PaxEd2G1McUI6vf2cmHGjaVwDMHSDybxhAcC0rU61kTkcCWLwfboAQxvylWecM4(K4sbEcAqRGaP0CWHpooGNGebklcjaZqdUCyiKQqhZifPBWaC0rwAve4qdsYiyg8A0RXGYGjG7iwwrdEhttdIhjIroMRf3J39jVp59zYafxU8AsrcMGphZ13J39jVFrA2mQK0KIrI7R494Up19PUhV7tE)ANOMVzkQSJYmJUp19PaxEd2G1McUMuKGjaxomesvOJzKI0nyao6ix9ALwfbo4sRIaxIuKGjaxE7Ka8ETtuxY4wpftxb9ANOMVzkQSJYmJapbnOvqGuAo4WhhhWtqIaLfHeGzObVwDMHSDybxhAcC0rwAve4qdsYcmdEn61yqzWeWDelRObVJPPbXJeXihZ1I7X7(K3N8EduC5YJGzdrPXyZKGhvX9yXEVbkUC5vuVQWwGjembpQI7XI9EKig5yUMxr9QcBbMqWe8BwMqjAkxAj1Y0I7R8(0CUhl2771ornFZuuzhLzgDFL17EzZ5(u3NcC5nydwBk4AsrcMa8A1zgY2HfCDOjWrh5QxR0QiWbxAve4sKIemX9jXLc8e0GwbbsP5GdFCCapbjcuwesaMHgC5WqivHoMrks3Gb4OJS0QiWHgKQdmdEn61yqzWeWDelRObVJPPbXJeXihZ1I7X7(K3BGIlxEf1RkSfycbtWJQ4ESyVhjIroMR5vuVQWwGjemb)MLjuIMYLwsTmT4(kEVS5CpwS33RDIA(MPOYokZm6(kR394sFFkWL3GnyTPGJGzdrPXyZKa8A1zgY2HfCDOjWrh5QxR0QiWbxAve4YHzdX9Mm2mjapbnOvqGuAo4WhhhWtqIaLfHeGzObxomesvOJzKI0nyao6ilTkcCObjzdMbVg9AmOmyc4oILv0G3X00G4lIMfAX94DFY7nqXLlVI6vf2cmHGj4TKAzAX9v8(01DpwS33RDIA(MPOYokZm6(kVxg5CFkWL3GnyTPGxenl0GxRoZq2oSGRdnbo6ix9ALwfbo4sRIaV(JMfAWtqdAfeiLMdo8XXb8eKiqzribygAWLddHuf6ygPiDdgGJoYsRIahAOb3lie2oyv42Sqds1Hp(qda]] )

    storeDefault( [[SimC Havoc: demonic]], 'actionLists', 20170625.202920, [[deeJsaqifWMiQ8jiPkJcLQtHszvkOKxrLk1UqvdJioMISmfYZuq10OsfxJkvTnij13iGXPaLZbjvwhvQKMhKKCpij2NcKdsu1cjqpKOyIkq1fjsTriP8rfumsiPQojvk3ei7evwkb9uktLq2krP9Q6VqQbd1HfTyapgIjl0LL2SI6ZqIrduNMQEnrYSj52KA3G(nsdhLSCbphftxPRtfBNq9DfKXtLkX5vOwVck18Ps2pI)0fDBW7C6O2l4nJvr8PYpSZ1tHNZ9ciWnHv1KPNBKKjbKGQh5E(juN7Dh3b1DZqcEw7TBYJSEkK5Io30fDtAycOA8cEZqcEw7n2j4nvfU8ScLvgAKVWeq1ib7YfbVPQWLxt1fUoA(ctavJemBeSCemGZ8mpRqzLHg5J0HGeSCemGZ8mVMQlCD08r6qWBYd4v(D8nXfIsNDuOdDdn3BUbJEKCPHBqkS3arJYMbUu3B34sDVjBHO0zhfblSBO5Etyvnz65gjzsGjj3ewgQtaPmx03BYaUisbIkU6c3dCdenYL6E775gDr3KgMaQgVG3mKGN1EJDcEtvHlVMQlCD08fMaQgjyxUi4nvfU8ZvHwNmBdJ5lmbunsWSrWYrWStWdqWBQkC51uDHRJMVWeq1ib7YfbZobJaodOugcgvi4reSlxemcLQI0HG8IleLo7Oqh6gAU8HQtpKHGheb7oemBeSCemGZ8mVMQlCD08r6qqcMncwocMDcgbCgqPmemQqWJiy2UjpGx53X3MRcDWHb8n3GrpsU0Wnif2BGOrzZaxQ7TBCPU3qTQiyHomGVjSQMm9CJKmjWKKBcld1jGuMl67nzaxeParfxDH7bUbIg5sDV99Cd)IUjnmbunEbVzibpR92MQcxEafLgvD5lmbunsWYrWStWdqWBQkC51uDHRJMVWeq1ib7Yfbd4mpZRP6cxhnVdlcMncwocgbCgqPmemQqWJUjpGx53X3wWb6qOrrLEX9MBWOhjxA4gKc7nq0OSzGl192nUu3BIahOdrWdJk9I7nHv1KPNBKKjbMKCtyzOobKYCrFVjd4IifiQ4QlCpWnq0ixQ7TVNZDUOBsdtavJxWBgsWZAVjod(eqvEavgl6ycr6n5b8k)o(wS5cgnZqTSU5gm6rYLgUbPWEdenkBg4sDVDJl192G3CbtW2qTSUjSQMm9CJKmjWKKBcld1jGuMl67nzaxeParfxDH7bUbIg5sDV99CU)IUjnmbunEbVjpGx53X3MRcDdoSwpfEZny0JKlnCdsH9giAu2mWL6E7gxQ7nuRkcw6GdR1tH3ewvtMEUrsMeysYnHLH6eqkZf99MmGlIuGOIRUW9a3arJCPU3(Eou9fDtAycOA8cEZqcEw7n2j4ez9Il6cR2xgcEqe8ebZgb7YfbZobZobpabVPQWLxt1fUoA(ctavJeSlxemGZ8mVMQlCD08oSiy2iy2UjpGx53X3MDcJrtNrVGlAVs5JzWFZny0JKlnCdsH9giAu2mWL6E7gxQ7nuZjmMGPZe8cUeSBkLpMb)nHv1KPNBKKjbMKCtyzOobKYCrFVjd4IifiQ4QlCpWnq0ixQ7TVNtGl6M0Weq14f8MHe8S2BIZGpbuLhqLXIoMqKsWYrWiuQkshcY3XfnqtnFO60dzi4brWUNGLJGhGGrOuvKoeKx3n10alWugpdFOzC8n5b8k)o(gGkJfDmHi9MBWOhjxA4gKc7nq0OSzGl192nUu3BcQYyj4bpHi9MWQAY0ZnsYKatsUjSmuNaszUOV3KbCrKcevC1fUh4giAKl1923Znyx0nPHjGQXl4ndj4zT32uv4YdOO0OQlFHjGQrcwocorwV4IUWQ9LHGheQqWJiy5iy2j4bi4nvfU86KzBanDg9cUOrrLEXLVWeq1ib7YfbpabVPQWLxt1fUoA(ctavJeSlxemGZ8mVMQlCD08oSiy2iy5iy2j4ez9Il6cR2xgcEqOcbpCcMTBYd4v(D8TfCGoeAuuPxCV5gm6rYLgUbPWEdenkBg4sDVDJl19MiWb6qe8WOsV4sWSpX2nHv1KPNBKKjbMKCtyzOobKYCrFVjd4IifiQ4QlCpWnq0ixQ7TVNd1Dr3KgMaQgVG3mKGN1EB2jmMp2zpIFj4bHke8WLCtEaVYVJVnxfGkJ9MBWOhjxA4gKc7nq0OSzGl192nUu3BOwvaQm2BcRQjtp3ijtcmj5MWYqDciL5I(EtgWfrkquXvx4EGBGOrUu3BFp3KKl6M0Weq14f8MHe8S2BjY6fx0fwTVme8Gi4jc2LlcEacgWzEMpwnf6rqx3LTWyJO1DtnnWcmLXZW7W6M8aELFhFRJlAGM6BUbJEKCPHBqkS3arJYMbUu3B34sDVj94sWc2uFtyvnz65gjzsGjj3ewgQtaPmx03BYaUisbIkU6c3dCdenYL6E775MMUOBsdtavJxWBgsWZAVXobpabVPQWLxt1fUoA(ctavJeSlxemGZ8mVMQlCD08oSiyxUi4zNWy(yN9i(LGrve8WLqWUBcgWzEMNvOSYqJ8oSi4HfbpyeSlxemGZ8mVUBQPbwGPmEg(q1PhYqWOkc29emBeSCe8aeS4m4tav5zrPkpef0Z0aAavgl6ycr6n5b8k)o(wcHEWEvUEk8MBWOhjxA4gKc7nq0OSzGl192nUu3BYdHEWEvUEk8MWQAY0ZnsYKatsUjSmuNaszUOV3KbCrKcevC1fUh4giAKl1923Znn6IUjnmbunEbVzibpR92MQcxEafLgvD5lmbunsWYrWStWdqWBQkC51jZ2aA6m6fCrJIk9IlFHjGQrc2LlcEacEtvHlVMQlCD08fMaQgjyxUiyaN5zEnvx46O5DyrWSDtEaVYVJVTGd0HqJIk9I7n3GrpsU0Wnif2BGOrzZaxQ7TBCPU3eboqhIGhgv6fxcM9rSDtyvnz65gjzsGjj3ewgQtaPmx03BYaUisbIkU6c3dCdenYL6E775Mg(fDtAycOA8cEZqcEw7n2j4bi4nvfU8AQUW1rZxycOAKGD5IGbCMN51uDHRJM3Hfb7Yfbp7egZh7ShXVemQIGhUec2DtWaoZZ8ScLvgAK3HfbpSi4bJGzJGLJGhGGfNbFcOkplkv5HOGEMgqJaoPmOz2GxQsWYrWdqWIZGpbuLNfLQ8quqptdO1DtcwocEacwCg8jGQ8SOuLhIc6zAanGkJfDmHi9M8aELFhFdbCszqZSbVu9MBWOhjxA4gKc7nq0OSzGl192nUu3BYaoPmeSTbVu9MWQAY0ZnsYKatsUjSmuNaszUOV3KbCrKcevC1fUh4giAKl1923Zn5ox0nPHjGQXl4ndj4zT3gGG3uv4YRP6cxhnFHjGQrcwocMDcgWzEMx3n10alWugpdFKoeKGD5IG3uv4YhRMcrdOYyz4lmbunsWSrWYrWStWiGZakLHGrfcEebZ2n5b8k)o(2CvOdomGV5gm6rYLgUbPWEdenkBg4sDVDJl19gQvfbl0HbmbZ(eB3ewvtMEUrsMeysYnHLH6eqkZf99MmGlIuGOIRUW9a3arJCPU3(EUj3Fr3KgMaQgVG3KhWR874BXQPqg0a(T3Cdg9i5sd3GuyVbIgLndCPU3UXL6EBWRMcr9yiyb9BVjSQMm9CJKmjWKKBcld1jGuMl67nzaxeParfxDH7bUbIg5sDV99CtO6l6M0Weq14f8MHe8S2BBgqPlVhIoKqukb7YfbpabVPQWLhqrPrvx(ctavJ3KhWR874Bl4aDi0OOsV4EZny0JKlnCdsH9giAu2mWL6E7gxQ7nrGd0Hi4HrLEXLGzF4SDtyvnz65gjzsGjj3ewgQtaPmx03BYaUisbIkU6c3dCdenYL6E775Me4IUjnmbunEbVzibpR92Mbu6Yh9mBcrkbpicEY9eSlxem7e8Mbu6Y7HOdjeLsWYrWdqWBQkC51uDHRJMVWeq1ibZ2n5b8k)o(2CvOdomGV5gm6rYLgUbPWEdenkBg4sDVDJl19gQvfbl0HbmbZ(i2UjSQMm9CJKmjWKKBcld1jGuMl67nzaxeParfxDH7bUbIg5sDV99Ctd2fDtAycOA8cEZqcEw7TndO0Lp6z2eIucEqe8K7VjpGx53X3exikD2rHo0n0CV5gm6rYLgUbPWEdenkBg4sDVDJl19MSfIsNDueSWUHMlbZ(eB3ewvtMEUrsMeysYnHLH6eqkZf99MmGlIuGOIRUW9a3arJCPU3((9gxQ7nZRLHGr9tXue3vcownf6r((d]] )

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

