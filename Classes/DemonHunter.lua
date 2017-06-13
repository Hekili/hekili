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

local RegisterEvent = ns.RegisterEvent
local RegisterUnitEvent = ns.RegisterUnitEvent
local storeDefault = ns.storeDefault


local PTR = ns.PTR or false


-- This table gets loaded only if there's a supported class/specialization.
if (select(2, UnitClass('player')) == 'DEMONHUNTER') then

    ns.initializeClassModule = function ()

        local current_spec = GetSpecialization()

        setClass( 'DEMONHUNTER' )
        Hekili.LowImpact = true

        addResource( 'fury', current_spec == 1, true )
        addResource( 'pain', current_spec == 2, true )

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
        addTalent( 'blade_turning', 203753 )
        addTalent( 'spirit_bomb', 218679 )

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
            if PTR and state.spec.vengeance and state.talent.blade_turning.enabled and state.buff.blade_turning.up and resource == 'pain' then
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

                    local step = PTR and 0.1 or 0.125

                    return app + ( floor( ( t - app ) / step ) * step )
                end,

                interval = PTR and 0.1 or 0.125,

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

        if PTR then
            addGearSet( "soul_of_the_slayer", 151639 )
            addGearSet( "chaos_theory", 151798 )
            addGearSet( "oblivions_embrace", 151799 )
        end


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
            cast = PTR and 2 or 1,
            channeled = true,
            charges = PTR and 1 or 5,
            recharge = PTR and 60 or 30,
            gcdType = 'spell',
            cooldown = PTR and 60 or 30,
            talent = 'fel_barrage',
        } )

        addHandler( 'fel_barrage', function ()
            applyBuff( 'fel_barrage', PTR and 2 or 1 )
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
            applyBuff( 'chaos_blades', PTR and 18 or 12 )
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
            if PTR and equipped.oblivions_embrace then return x + 1 end
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
            charges = PTR and 1 or nil,
            recharge = PTR and 20 or nil,
            min_range = 0,
            max_range = 0,
        } )

        modifyAbility( 'empower_wards', 'charges', function( x )
            if PTR and equipped.oblivions_embrace then return x + 1 end
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
            spend = PTR and 30 or 20,
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
            id = 218679,
            spend = 0,
            spend_type = 'pain',
            cast = 0,
            cooldown = 0,
            gcdType = 'spell',
        } )

        addHandler( 'spirit_bomb', function ()
            gainChargeTime( 'demon_spikes', buff.soul_fragments.stack )
            removeBuff( 'soul_fragments' )
            applyDebuff( 'target', 'frailty', 20 )
            active_dot.frailty = max( 1, active_enemies )
        end )

    end


    storeDefault( [[Wowhead: Simple]], 'actionLists', 20170612.233537, [[d0d7kaGEiq1MqI2fK2gP0(if52e1SLA(Kc(eeOCAqFJiwgsANiSxLDdSFe1OeQmmQ0Vj58iYRrczWiLHdLoiv4ucvDmjDoiqSqcAPKQwSelxWdHaQNI6Xq16GaYercAQivtMQMUOlsKEoHUSQRdH2isGTcbWMjv2ov0hjf6RqG00qc13HI(RqEgbgneDykNuO8zOW1if19GG0kHa04GG4qqq9QJ(yct(JrqvyI8MhbImngkJT)yg7XHwdrWTeQaJqZsKmw)7BIFeuDRsC1wPIsvGRebAEmJhGyZXJDGNqfqC0hrD0hlfyL((jCmHj)XuWBY00JOiYX6FFt8JGQBvBvcQRG64yape3svymqb(yhfydtsJ19okGOiYXmEaInhJJ0cyCrekvkPOFSr6Ehfquezu44iTagqaglhb1rFSuGv67NWXmEaInhNwFqIwALY3prpWk99AqdP1hKOYk5dseLrpWk99J1)(M4hbv3Q2Qeuxb1XXaEiULQWyGc8XeM8hJaCagxhInzA6FgULJDuGnmjn25byCDi2rHNHB5Yriy0hlfyL((jCmJhGyZXP1hKO6EhvSqWW4OhyL(EkXrAbmUicvZJ1)(M4hbv3Q2Qeuxb1XXaEiULQWyGc8XeM8htbVjttOfcggFSJcSHjPX6EhvSqWW4lhbfp6JLcSsF)eoMXdqS5406ds0sRu((j6bwPVNY06dsuztmFisPlkr(imAd68OhyL((X6FFt8JGQBvBvcQRG64yape3svymqb(yct(JPJmOWKmnn2g05h7OaBysACImOWmcJ2Go)YrO5rFSuGv67NWXmEaInhNwFqIQ7D0diInHka6bwPVFS(33e)iO6w1wLG6kOoogWdXTufgduGpMWK)yk4nzAsdiInHkWyhfydtsJ19o6beXMqfy5i0o6JLcSsF)eoMXdqS54X6FFt8JGQBvBvcQRG64yape3svymqb(yct(JPaedKittPJmTe5jtlw3qVfGJDuGnmjnwhIbsrkDrjYhb7g6TaC5iKm6JLcSsF)eoMXdqS5406dsu)Lvaio6bwPVFS(33e)iO6w1wLG6kOoogWdXTufgduGpMWK)yPKozAcVjp2rb2WK04t6rLBYlhbcz0hlfyL((jCmJhGyZXP1hKO6GbXmQ0kLh9aR03RbneNHNqNp6GldVOMeqzA9bjkostjgH33CE0dSsFF8J1)(M4hbv3Q2Qeuxb1XXaEiULQWyGc8XeM8hlSn)jtJcna(h7OaBysACPn)J8ga)lhbcYOpwkWk99t4ygpaXMJtRpir1bdIzuPvkp6bwPVxdAiodpHoF0bxgErnjGY06dsuCKMsmcVV58OhyL((4hR)9nXpcQUvTvjOUcQJJb8qClvHXaf4Jjm5pMcVLijtJX8h7yhfydtsJ93sKrIy(JD5iQUJ(yPaR03pHJz8aeBooT(GeT0kLVFIEGv67P0WtOZhDWLHxut1X6FFt8JGQBvBvcQRG64yape3svymqb(yct(JPJmOWKmnn2g05jtlUA8JDuGnmjnorguygHrBqNF5iQ1rFSuGv67NWXmEaInhNwFqIwAiWhPdXaj0dSsF)y9VVj(rq1TQTkb1vqDCmGhIBPkmgOaFmHj)XsjDY0eEtMmT4QXp2rb2WK04t6rLBYlhrL6OpwkWk99t4ygpaXMJhR)9nXpcQUvTvjOUcQJJb8qClvHXaf4Jjm5p2baarcBlHkWyhfydtsJnaaIe2wcvGLJOky0hlfyL((jCmJhGyZXP1hKOLwP89t0dSsF)y9VVj(rq1TQTkb1vqDCmGhIBPkmgOaFmHj)X0rguysMMgBd68KPfh14h7OaBysACImOWmcJ2Go)YruP4rFSuGv67NWXmEaInhxquNou5NMSkGfPsekI6vycO0WtOZhDWLHxutvkJdHtRpirlne4J0HyGe6bwPVNseoT(GefhPPeJW7Bop6bwPVNseoT(Ge1FzfaIJEGv67JFS(33e)iO6w1wLG6kOoogWdXTufgduGpMWK)yPKozAcVjtMwCuJFSJcSHjPXN0Jk3KxoIQMh9XsbwPVFchZ4bi2CCbrD6qLFAYQawKkrOiQxHjGsdpHoF0bxgErnvjJaow)7BIFeuDRARsqDfuhhd4H4wQcJbkWhtyYFmDKbfMKPPX2GopzAXji(XokWgMKgNidkmJWOnOZVCevTJ(yPaR03pHJz8aeBoES(33e)iO6w1wLG6kOoogWdXTufgduGpMWK)yeyKMsKmnodqk6JDuGnmjnghPPeJeZaKI(YruLm6JLcSsF)eoMXdqS54X6FFt8JGQBvBvcQRG64yape3svymqb(yct(JPWlRaiyIKPjeMFSJcSHjPX(lRaIrfy(LJOIqg9XsbwPVFchZ4bi2CCA9bjQ)YkquPn)frpWk99uIWP1hKOLwP89t0dSsF)y9VVj(rq1TQTkb1vqDCmGhIBPkmgOaFmHj)X0rguysMMgBd68KPfhfh)yhfydtsJtKbfMry0g05xUCmfEDgIDUYYna]] )

    storeDefault( [[Wowhead: Complex]], 'actionLists', 20170612.233537, [[daKMqaqikQ2esQprKaJcLYPqsEfrIyxuAyc5yGSmK4zeX0isX1uQW2Ks(grzCejPZPurSoIeP5rKe3Jiv7JIYbvswir1djsQjsKsxukSrLk5JkvQtQK6MejQDIQwQuQNsAQuKTsKG(QsfP9c9xLYGrHdt1ILQhdQjlXLvTzH6ZsrJgLCAeVwPIA2a3wWUv8BcdxjwUKEosnDrxNcBxPQVJs14jsiNhvSEIeQ5JkTFu0ieAcvEpCu3Pc2zDViLYKHulclGlfHQUCyIdisXEsedYVdzYqT9b3PpYtjcswulikwksIKjzhOQWvYsIkQRGtIyOrtipeAc1gJ3bVGYrvHRKLevux1jasYbvyXqBe(wWBsGrD9uiWEkQOoI5OY7HJQulgAJWzYqk7njWO2(G70h5Peb1csMnsceMipf0eQngVdEbLJQcxjljQPOztWTWcbOiyFOrT9b3PpYtjcQfKmBKeiuxpfcSNIkQJyoQR6eaj5GA4Phe1fwcAcnQ8E4OkLF6brDHLGMqJjYlbnHAJX7Gxq5OY7HJQuZYf0mzih4LtJA7dUtFKNseuliz2ijqOUEkeypfvuhXCuv4kzjrnfnBcUfwiafb7dn1S1nIJTHNEquxyjOj026dozOnt6qu4Yfwiafb7Jn80dI6clbnH2wFWjdTzoCseJfMLlO36aVCAlSqakc2hPeikuH6QobqsoOcZYf0BDGxonMiV0GMqTX4DWlOCuv4kzjrnfnBcUfwiafb7dnQR6eaj5G68WPj0OUEkeypfvuhXCuBFWD6J8uIGAbjZgjbcvEpCu5F40eAmr(DGMqTX4DWlOCu59WrDxhWKrBdAwO2(G70h5Peb1csMnsceQRNcb2trf1rmhvfUswsuPFMKPjTDN)x2IpyRAqZAREywETjzAYKb1mzWgtgWS8AZtVfxD4KighWKHzsNjdiRSDWKb1mzWgtgMZKr6GpPn(GTGtNVYX(X7GxyYGlxMmInQCSLhtGjjtgMjDMmKeXKbvmzqfQR6eaj5GA8bBvdAwyI8TqtO2y8o4fuoQkCLSKOMo4tAxQFXRVy)4DWlC5Yw6GpPnicFsJG9J3bVqT5DJ4yBqe(KgbRXcvO2(G70h5Peb1csMnsceQRNcb2trf1rmh1vDcGKCqD)NMp2aSvFwVNOY7HJQu4NMp2aWKr7N17jMiVm0eQngVdEbLJQcxjljQSzE6GpPnicFsJG9J3bVWLB3io2geHpPrWASqf1WS8AZtl9DGA7dUtFKNseuliz2ijqOUEkeypfvuhXCux1jasYb14d26ET6npQ8E4OURdyYqUxREZJjYlvrtO2y8o4fuoQkCLSKOcZYRnpTzshYkBhuZw6GpPTdeIc4P9J3bVqD6GpPn405RBI4TK13AcCY(B)4DWlurnBMNo4tAdIWN0iy)4DWlC52nIJTbr4tAeSgluHA7dUtFKNseuliz2ijqOUEkeypfvuhXCux1jasYb1KvvW(wtGt2Fu59Wr1eRQGDMm2nWj7pMi)obnHAJX7Gxq5OQWvYsIA6GpPn(GTxnwsIySF8o4fuBFWD6J8uIGAbjZgjbc11tHa7POI6iMJ6QobqsoOgFW2RgljrmOY7HJ6UoGjJgvJLKigmrEOi0eQngVdEbLJQcxjljQSzE6GpPnicFsJG9J3bVWLB3io2geHpPrWASqfQTp4o9rEkrqTGKzJKaH66PqG9uurDeZrDvNaijhuJnQC2eXBjRVraasXReu59WrDxgvomziIzYizDMmwdaKIxjyI8qqOjuBmEh8ckhvfUswsuth8jTLhedb2(X7Gx4Y1HtY(V95bYPnJcQTp4o9rEkrqTGKzJKaH66PqG9uurDeZrDvNaijhupNV1VhqL3dh1gCotgYVhWe5HOGMqTX4DWlOCuv4kzjrnDWN0gtQ05whief7hVdEHlxhoj7)2NhiN2mkC5YMdNK9F7ZdKtBMeQth8jTWSCb9gm4((B)4DWluHA7dUtFKNseuliz2ijqOUEkeypfvuhXCux1jasYb1oWlFR4d8rL3dhv5aVCMmKwFGpMipKe0eQngVdEbLJQcxjljQPd(K2ysLo36aHOy)4DWlC56Wjz)3(8a50MrHlx2C4KS)BFEGCAZKqD6GpPfMLlO3Gb33F7hVdEHkuBFWD6J8uIGAbjZgjbc11tHa7POI6iMJ6QobqsoOwUNS2Oz)FbvEpCuL27jlMmu2)xWe5HKg0eQngVdEbLJQcxjljQPd(K2oqikGN2pEh8c1oCs2)TppqoTzquZM5Pd(K2Gi8jnc2pEh8cxUDJ4yBqe(KgbRXcvO2(G70h5Peb1csMnsceQRNcb2trf1rmh1vDcGKCqnzvfSV1e4K9hvEpCunXQkyNjJDdCY(ZKbBquHjYdTd0eQngVdEbLJQcxjljQXgvo2YJjWK0mPljc12hCN(ipLiOwqYSrsGqD9uiWEkQOoI5OUQtaKKdQXh0bE5OY7HJ6UoOd8YXe5HAHMqTX4DWlOCuv4kzjrnDWN02bKPSfBu5y)4DWlO2(G70h5Peb1csMnsceQRNcb2trf1rmh1vDcGKCq9C(w)EavEpCuBW5mzi)EGjd2GOctKhsgAc1gJ3bVGYrvHRKLe1UrCSn80dI6clbnH2ASqnBMNo4tAdIWN0iy)4DWlC52nIJTbr4tAeSglC5gBu5ylpMatsPcLiQqT9b3PpYtjcQfKmBKeiuxpfcSNIkQJyoQR6eaj5GQpdHfb4jrmOY7HJ6QziSiapjIbtKhsQIMqTX4DWlOCuv4kzjrnDWN02bcrb80(X7GxOMnZth8jTbr4tAeSF8o4fUC7gXX2Gi8jncwJfQqT9b3PpYtjcQfKmBKeiuxpfcSNIkQJyoQR6eaj5GAYQkyFRjWj7pQ8E4OAIvvWotg7g4K9Njd2OqfMip0obnHAJX7Gxq5OQWvYsIA3io2gE6brDHLGMqBlc2hQzZ80bFsBhqMYwSrLJ9J3bVqT5Pd(KwywUGEdgCF)TF8o4fQnpDWN0wEqmey7hVdEHkQD4KS)BFEGCAZGO2Rjj2HtRpnni0S2eXBjRVvo8j7F1(X7GxqT9b3PpYtjcQfKmBKeiuxpfcSNIkQJyoQR6eaj5G658T(9aQ8E4O2GZzYq(9atgSrHkmrEkrOjuBmEh8ckhvfUswsu7gXX2WtpiQlSe0eABrW(qTdNK9F7ZdKtBgeQTp4o9rEkrqTGKzJKaH66PqG9uurDeZrDvNaijhutwvb7Bnboz)rL3dhvtSQc2zYy3aNS)mzWMeQWe5PaHMqTX4DWlOCuv4kzjrLTUrCSnicFsJG1yHlxZth8jTbr4tAeSF8o4fQ4Yn2OYXwEmbMKsfkrO2(G70h5Peb1csMnsceQRNcb2trf1rmh1vDcGKCqfMLlO3OZkzNpQ8E4Ok1SCbntgAwj78Xe5PqbnHAJX7Gxq5OQWvYsIkmlV280MjDPHA2mpDWN0geHpPrW(X7Gx4YTBehBdIWN0iynwOc12hCN(ipLiOwqYSrsGqD9uiWEkQOoI5OUQtaKKdQXhS19A1BEu59WrDxhWKHCVw9MNjd2GOctKNIe0eQngVdEbLJQcxjljQXgvo2YJjWK0mPtjc12hCN(ipLiOwqYSrsGqD9uiWEkQOoI5OUQtaKKdQLhed9wNKhvEpCuL2heJuantgYj5Xe5PinOjuBmEh8ckhvEpCunXQkyNjJDdCY(JA7dUtFKNseuliz2ijqOUEkeypfvuhXCuv4kzjrnDWN0wEqmBDGxoT9J3bVqT5Pd(K2oqikGN2pEh8cQR6eaj5GAYQkyFRjWj7pMyIQ0(y3aKyhteba]] )

    storeDefault( [[Red Vengeance: precombat]], 'actionLists', 20170612.233537, [[dqJ2baGEuQAxOkBJISpHsZgYTf0ovYEj7g0(vOHrjJdLIbROgUcoiQQNtPogvohkPwifSuO0IfYYPQdl6PQESsTouknrOkMQImzbMoWfLkTmuCzKRJsLnIsYwrjSzPQTJk6JOeDEPIpdfFxO40sMguvnAHQVHkDsk0ZGkxdQk3dQsVgv4Vuu)wklNM0xziPJLcgNzbbXqjCtSDCEWt7wyuc0Xd1NSdbKbDSeIsBslglhxltogEm4yynd(1)aTRevSpbvdQf(yJtN)gunOTM0YPj9UWmcrbYG(kdj9xyk04CRFCMvOmK0XsikTjTySCMCC5zHZPBegu7e086WgK05hvOc0r3UWuiZTEZ9OmK0)2xdaDb0Irt6DHzeIcKb9vgs6gH9KhMOX5d8fhKowcrPnPfJLZKJlplCoDJWGANGMxh2GKo)OcvGo6fSN8Wez2g4loi9V91aqFhp9yi7yXRtaTWPj9UWmcrbYG(kdj9P4(wmJZSeLfNKowcrPnPfJLZKJlplCoDJWGANGMxh2GKo)OcvGo6G4(wmMXGYIts)BFna0fqa9V91aqxaja]] )

    storeDefault( [[Red Vengeance: default]], 'actionLists', 20170612.233537, [[diu)laqisfAtQQmksvDksvwfkfyxsmmrCmiwgP4zIutJubxdv02uv6BqkJJurohkfzDKkQ5HkCpvP2hPs)dLs5GQkwOQQEikf1erPqxes1gfsCsiPvQkr6MOuYorv)eLs1qvLiwQQWtPAQqIRIsbTvHK(QQeL9I8xOmysPdtzXO4XIAYs6YGnROpleJwi1PjETQeMTu3gQ2Tk)MKHlulxWZvy6kDDuY2fjFxvsNxv06vLOA(OuTFuPjecfY5nCG8hqLR2OcxeWUmOZC1wHPXQxYzJW0y1l9N8hqd2aiEnjiOL8frtrtAnSjn6a5EmKfRLxUTI6iEo1jeY)KxrDdcfIhHqHC0pJPHk9NCEdhiNnCaC16seP5Qvn5QnkTHdSnY9CqIxY1FTgUTmBdhWYbBeDboJPH6VkWWAoldjI0yQj2SnCOeaCtUbhVr0JD21xhxRHBlZ2WbSCWgrxGZyAOQh5FyKw2NKNYcIX0a5OEvjBRkq(PoG8hqd2aiEnjiFrqRKKgHC2svJQf4nCGCwdaBirKgtnXMTHd0s8Aiuih9ZyAOs)j3ZbjEjx)Ss1v1RxrWXvTTI6WmwbReaCtUbhjfo)fBYvQWuYYQ7Beo1JD21FTgUTmHMPTkuGZyAO(lRuDv96vMqZ0wfkba3KBWrsHZFXMCLkmLSS6(o2KdRctjllwl4YQh7SR)AnCBzcngeyfVI6kWzmnu)LvQUQE9ktOXGaR4vuxja4MCdoskCQh7SRFkligtdfwdaBirKgtnXMTHd)S8kPam4aCbg6(wZVSs1v1RxzirKgtnXMTHdLaGBYn4iPWPESZU(rdwVrxIHqgULJ3v7IabSn6amIw11FzLQRQxVYeASkKYgRTI6kba3KBWrsHZFXMCLmRqaUv33Pt0J8pmsl7tYtzbXyAG8hqd2aiEnjiFrqRKKgHCuVQKTvfi)uhqoVHdK)Ymz5QDQcC1(scIki7tUA)WiTScmyBKZwQAuTaVHdK)Qjl2ufWIdIki7tmJrAzfyqlXNMqHC0pJPHk9NCphK4L8vfjsdLkmHBiPGb5FyKw2NKNTUXS8kQdRLXs(dObBaeVMeKViOvssJqoQxvY2QcKFQdiN3WbYzJWeUHKcgKZwQkVHdK)aQC1gv4Ia2LbDMR2kmHBiPGbTeVoqOqo6NX0qL(toVHdK7kwnxTS5gSua5pGgSbq8Asq(IGwjjnc5OEvjBRkq(PoG8pmsl7tYhkwnwUblfqUNds8sESjxjZkeGB1993KFmSMZYqXQXMblcoC7Omwl)c2ao54D0G1B0LkmLSSyX5LwINtcfYr)mMgQ0FY9CqIxYxRHBlJyjilgJcNPaNX0q9xfyynNLzWKEFwcaUj3Gdo)XWAoldfRgBgSi4WTJYyT8l09nc5pGgSbq8Asq(IGwjjnc5OEvjBRkq(PoGCEdhi3JLGSC1(xHZq(hgPL9j5JyjilgJcNHwI)lHc5OFgtdv6p5EoiXl5XMCLkmLSS6(gHtYFanydG41KG8fbTssAeYr9Qs2wvG8tDa58goqoQ44Q2wrDC1(HvWi)dJ0Y(KCbhx12kQdZyfmAjE0iuih9ZyAOs)j3ZbjEj3YRKcWGdWfyO7Bn)QadR5SmKisJPMyZ2WHsaWn5gC8gH8hqd2aiEnjiFrqRKKgHCuVQKTvfi)uhqoVHdK7seP5Qvn5QnkTHdK)HrAzFs(qIinMAInBdhOL41jcfYr)mMgQ0FY9CqIxYxRHBltOzARcf4mMgQ)In5kvykzz19DSjhwfMswwSwWLL8hqd2aiEnjiFrqRKKgHCuVQKTvfi)uhqoVHdKhfOzARcK)HrAzFs(eAM2QaTepBIqHC0pJPHk9NCEdhiNTpNWnKuWGCphK4L8vfjsdLSs1v1R3G8hqd2aiEnjiFrqRKKgHCuVQKTvfi)uhq(hgPL9j5zRBmlVI6WAzSKZwQkVHdK)aQC1gv4Ia2LbDMRw1Cc3qsbdAjEKecfYr)mMgQ0FY9CqIxYT8kPam4aCbgVr(Twd3wMblVScqboJPH6VytUsfMswwoIn5WQWuYYI1cUSK)aAWgaXRjb5lcALK0iKJ6vLSTQa5N6aY5nCG8OeS8YkaK)HrAzFs(my5LvaOL4rqiuih9ZyAOs)j3ZbjEjVcmSMZYqIinMAInBdhkba3KBWXBeYFanydG41KG8fbTssAeYr9Qs2wvG8tDa58goqUlrKMRw1KR2O0goWvR(i6r(hgPL9j5djI0yQj2SnCGwIhrdHc5OFgtdv6p5EoiXl56RJR1WTLzWYlRauGZyAOYo7wELuagCaUadDFRrVFXMCLkmLSSCeBYHvHPKLfRfCzj)b0GnaIxtcYxe0kjPrih1RkzBvbYp1bKZB4a5UIvZvlBUblfWvR(i6r(hgPL9j5dfRgl3GLcOL4rstOqo6NX0qL(tUNds8s(AnCBzcngeyfVI6kWzmnuj)b0GnaIxtcYxe0kjPrih1RkzBvbYp1bKZB4a5rbAUArpWkEf1r(hgPL9j5tOXGaR4vuhTepIoqOqo6NX0qL(tUNds8sEkligtdfwdaBirKgtnXMTHd)0pRuDv96vKBcHZASXgKxaLC0wicmWMblVI6Sw33ifDIt2z3YRKcWGdWfyO7Bn6X9Ls(dObBaeVMeKViOvssJqoQxvY2QcKFQdiN3WbYr9Mq4SMRwFdYlaY)WiTSpjxUjeoRXgBqEbqlXJWjHc5OFgtdv6p58goqUhnybUA1hrpYFanydG41KG8fbTssAeYr9Qs2wvG8tDa5FyKw2NKpIgSa5EoiXl56ykligtdLxnzLlc2ufWIdIki7tmJrAzfyqlTK75GeVKtlra]] )

    storeDefault( [[Red Vengeance: defensives]], 'actionLists', 20170612.233537, [[dSt5iaGEkkQnPsTlkTnvW(urmBuMpfLCtkk42KY3Kc7Kc7fz3s2pQkJIIkggP63eESuDyHbJQQHdvhuf1PevkhdvohfvAHIQwQkPfdXYv6HuuQNs1YiQwhffAIQizQQetMKPR4IOkDEkYLbxxkTrkQARuuKntKTlQ40Q6zQqFgvX8KIEUihxuPA0qAAQi1jHcFhk6Aef3dknorL8xr51eLM4OlKBeAa5xbfF8BMGIhiQoyg5JFfibv6ZbsKFkqkAzdLN8RadIeqgY15AOFGtUv(r5MR8ttUJd9pyVzoMxuKHm5IJ8Z95fvIUqgC0fY5TcegOO8KBeAa5UOLXh)MDS5al5xbgejGmKRZDGRHv)ih5yuQVhJyjVefq(zKN9JjYtIwwwp2CGLCVVp(qoK7TpooOSbtTrh9ZWmwewOG0nkeSb1IdBhQPj2gYCJ0kjztIwwM0g8Ob1KSPj6YIv)wbiTsswPhwtziBuk7cAXxjS60qgYPlKZBfimqr5j3i0aYpfOjk(43XFzHe5xbgejGmKRZDGRHv)ih5yuQVhJyjVefq(zKN9JjYvGMOYs4VSqICVVp(qEhnwEGuM0g95fvWoblNTHm3iTsswfOjQSe(llKSlOfFLWQFRaKwjjR0dRPmKnkLDbT4Rew9B84lBVDxOMtWkx)gfc2GAXHTd10eBUKHgY4iDHCERaHbkkp5gHgqU5FynXh)53OuKFfyqKaYqUo3bUgw9JCKJrP(EmIL8sua5NrE2pMix6H1ugYgLICVVp(qokeSb1IdBhQPj2CjZnsRKKvbAIklH)YcjRsGzDJ0kjz1Gj0eloQi9jRsGzDJ0kjztIwwgsS7dRvjWSU7cbtjWSSkqtuzj8xwiz7OXYdKAYrdzCA6c58wbcduuEY9((4d5OqWguloSDOMMyLrM7jyqnwjGLPGCI0eZlklubcdu34Xx2E7UqnNG9Oo5xbgejGmKRZDGRHv)ih5yuQVhJyjVefqUrObKBEGXh)NcYjstmVOi)mYZ(Xe5saltb5ePjMxu0qgYqxiN3kqyGIYtUrObKBgGj0eloQi9jYVcmisazixN7axdR(roYXOuFpgXsEjkG8Zip7htKRbtOjwCur6tK799XhYrHGnOwCy7qnnX23F(EWYg0fsOcMYSmlZbfc2GAXHTd10e7P1VXJVS92DHAAIvU(DxiykbMLv6H1ugYgLYUGw8v6e9BfG0kjzLEynLHSrPSkbM1nsRKKvbAIklH)YcjRsGzD3fcMsGzzvGMOYs4VSqY2rJLhiLjTrFErfSM6wzYnAiJd0fY5TcegOO8K799XhYrHGnOwCy7qnnXQIIhyZg0fsOcMI8RadIeqgY15oW1WQFKJCmk13JrSKxIci3i0aYDrlJp(Zh7(Ws(zKN9JjYtIwwgsS7dlnKrd6c58wbcduuEY9((4d5OqWguloSDOMMyvrXdSzd6cjubtDJhFz7T7c1Cc2d6KFfyqKaYqUo3bUgw9JCKJrP(EmIL8sua5gHgqUlAz8XVzZGihG8Zip7htKNeTSSodICaAiJCrxiN3kqyGIYtU33hFihfc2GAXHTd10eRkkEGnBqxiHkyQBKwjjRc0evwc)LfswLaZ6gPvsYQbtOjwCur6twLaZ6gPvsYMeTSmKy3hwRsGzr(vGbrcid56Ch4Ay1pYrogL67XiwYlrbKBeAa5M)H1eF8NFJsXh)MdxUr(zKN9JjYLEynLHSrPOHmmx6c58wbcduuEYncnGCm00eSyErXh)NB3G8RadIeqgY15oW1WQFKJCmk13JrSKxIci)mYZ(Xe5VMMGfZlQSODdY9((4d5OqWguloSDOMMyvrXdSzd6cjubtDJhFzvG03)5eSCYqdzWPtxiN3kqyGIYtUrObKBEGHWcfq(vGbrcid56Ch4Ay1pYrogL67XiwYlrbKFg5z)yICjGHWcfqU33hFihfc2GAXHTd10eRkkEGnBqxiHkyQ7jyqnwjGHWcfyHkqyG6gp(YQaPV)ZjyXJVYuG03)jJ9A)qdzWXrxiN3kqyGIYtUrObK7OqSKFfyqKaYqUo3bUgw9JCKJrP(EmIL8sua5NrE2pMipHcXsU33hFihfc2GAXHTd10eRkkEGnBqxiHkykAOHCVVp(qoneb]] )

    storeDefault( [[Red Vengeance: offensives]], 'actionLists', 20170612.233537, [[dOd9daGEuvPnHQSlj2gezFKQMnjZNu5MOOYTrPDsr7fz3k2VsQrbrnmjzCOQKhd0HjgSKQHdshef6uOGJbPZHQIwOKYsvswmOwoupevL6PIwMsSouuAIKImvqyYsz6cxKuQVbIUSQRtH2iQQAROOyZa2Us15HWPP6ZKI67Kc9mk45uA0OQIxJICssjtJuW1qrv3tP8xu5qOQWVLQjuccknf2t5Q3wxNz(O5ld4z2117aaFS((TuQPdigvbvJYvxDXEYCPcfYkKqxklgw4Zfnqzc9GUOC(vcVpKjZZxOuYiy49XsqqMOeeuQ9iWQ3OAuAkSNs(7hJyD9AyzAuU6Ql2tMlvOiHczPYakLAnnhuIoMYPpNsgHDLhiOeWpgbhmwMgLji2HguISGdhqaJcGFmcU2zD7lyzys)gkVquFIcWvCTVl2qcVpLpcS6nEG9UQ114uaUIR9DXgs49PGpR4JDRIhuXNcOrm(tOFZqfd60HmFeI6tuaUIR9DXgs49P8rGvVPtNGdhqaJcGFmcU2zD7lyzyARIbkiZfcck1Eey1Bunknf2tj)VADDn9DXgs49HYvxDXEYCPcfjuilvgqPuRP5Gs0Xuo95uYiSR8abLaxX1(Uydj8(qzcIDObLHO(efGR4AFxSHeEFkFey1B8Gk(uanIXFc9BgQ4HmYcoCabmka(Xi4AN1TVGLHj9BO8eWW3p3NZ63UHYRDyJaafa)yeCWyzAf8zfFS63wyqNoKfC4acyua8JrW1oRBFbldtBv60jGHVFUpN1Vv)2cdmqbzAGGGsThbw9gvJstH9uMqDShRRxRZctzcIDObLHO(efluh7bhCNfU8rGvVXtadF)CFoRFR(TfEWgbak2Urfhaw0m7NWwSHaYK(nukxD1f7jZLkuKqHSuzaLsTMMdkrht50NtjJWUYdeuAH6yp4G7SWuM8txJmxV5a(XwcMcYudeeuQ9iWQ3OAuMGyhAqjLRU6I9K5sfksOqwQmGsPwtZbLOJPC6ZP0uypLz3OADD(wW7htjJWUYdeuA7gvCGcE)ykOGYee7qdkPGia]] )

    storeDefault( [[Icy Veins: Single Target]], 'actionLists', 20170612.233537, [[dWZMjaGErkPnruWUGkBtQkTprQy2aZxKsDtrkYPb9nI0Jf1oHYEP2nK9lKrjvvnmbgNif1HvCEuPbludxjoiPQtjvvogQ6CIuIfselvQSyLA5K8qrQ0trwgr16ePqtKOutvqtwktxYfjLEoHlR66kPnsuYwjkkBMuz7svXhfPQEgPGPjsv(oPOxtuOBlIrJk(lu1jfjFwQY1if6EefvhIOiFsKc(nkBEhAslA2G382eLvWLYKjzFDZkO82u3bFe3yYd4Lg0xE54KRHaPAqJMOLNHdaMwNcYqgtJsLAsFUGmKWHgJ3HM0IMn4nlXeLvWLYuX61dCCzgd0yAIeM6UGTQYx4qxM0VHayX1e6jxafMsHAW8umLjedDtDh8rCJjpGxkFGjSj5MWEYfqHlJj3HM0IMn4nlXeLvWLYu)JIfVkiQNaNm(VGx3b4vRco4vpZzu9GOErXPDAhfxd4OcNUdWNmI6kU4oA2G3II7xuSmefN5mQExGxNAYfKHgquC6iZJI5XjvJM6UGTQYx4qxM0VHayX1KUdWRwfCmLc1G5Pyktig6M6o4J4gtEaVu(atytYnjRdII7wfCCzmn4qtArZg8MLyIYk4szYu3fSvv(ch6YK(nealUM0Da(9OutVBkfQbZtXuMqm0n1DWhXnM8aEP8bMWMKBswheflzuQP3DzS0ZHM0IMn4nlXeLvWLYKPUlyRQ8fo0Lj9BiawCnPBvXfpth(IZXdbayBuqtPqnyEkMYeIHUPUd(iUXKhWlLpWe2KCtYAvXnkMPlkU48O4uaaSnkOlJPrhAslA2G3Setuwbxkt1aoQW1EcdbZ4oA2G3IILHOyzkkEVQthUKxtctTWHjGcCRlM6UGTQYx4qxM0VHayX105E87pjMsHAW8umLjedDtDh8rCJjpGxkFGjSj5M0Y9rXs(Kef3Fz)egcM7NlJ1xhAslA2G3SetuwbxktM6UGTQYx4qxM0VHayX1KUdWF16sbzitPqnyEkMYeIHUPUd(iUXKhWlLpWe2KCtY6GOyTQ1LcYqUmMuhAslA2G3Setuwbxkt1aoQWTbmwd8c3rZg8MPUlyRQ8fo0Lj9BiawCnvCumnX3dmW(CtPqnyEkMYeIHUPUd(iUXKhWlLpWe2KCtHCumnJItFWa7ZJI7VeaJ1aV6NlJLMDOjTOzdEZsmrzfCPmvSE9ahxMXanMMiruSmefltrX7vD6WL8AsyQfombuGBDXu3fSvv(ch6YK(nealUMsEnjm1chMakmLc1G5Pyktig6M6o4J4gtEaVu(atytYnLMEnjm1chMakCzS0IdnPfnBWBwIjkRGlLPI1Rh44YmgOX0ejm1DbBvLVWHUmPFdbWIRPmNHjWVbt7ctPqnyEkMYeIHUPUd(iUXKhWlLpWe2KCtPlNHjIILaM2fUmgFGdnPfnBWBwIjkRGlLPAahv40bvIc)gWynChnBWBM6UGTQYx4qxM0VHayX10gmTJVnO8nLc1G5Pyktig6M6o4J4gtEaVu(atytYnjbmThfl7bLVlJXZ7qtArZg8MLyIYk4szQgWrfoDqLOWVbmwd3rZg8MPUlyRQ8fo0Lj9BiawCn1(uCWl08FXukudMNIPmHyOBQ7GpIBm5b8s5dmHnj3KS)uCIIjn)xCzmE5o0Kw0SbVzjMOScUuM0TQ4IRDDWmSIItNOyneyQ7c2QkFHdDzs)gcGfxt6oydM2nLc1G5Pyktig6M6o4J4gtEaVu(atytYnjRd2GPDxgJxdo0Kw0SbVzjMOScUuMm1DbBvLVWHUmPFdbWIRPmNHjWlkfugVPuOgmpftzcXq3u3bFe3yYd4LYhycBsUP0LZWerXuPGY4Dzm(0ZHM0IMn4nlXeLvWLYKPUlyRQ8fo0Lj9BiawCnnieKdemfKHmLc1G5Pyktig6M6o4J4gtEaVu(atytYnPhHGCGGPGmKlJXRrhAslA2G3SetuwbxktYuuCnGJkCTNWq43GPDbUJMn4ntDxWwv5lCOlt63qaS4AQ9egsGFdRBkfQbZtXuMqm0n1DWhXnM8aEP8bMWMKBs2pHHsdIOyjW6UmgFFDOjTOzdEZsmrzfCPmvd4Ocx7jme(nyAxG7OzdEZu3fSvv(ch6YK(nealUMkokMM47bgyFUPuOgmpftzcXq3u3bFe3yYd4LYhycBsUPqokMMrXPpyG95UCzcBsUPuzUrXYSdrI0yumbr9apkoCu9E5Yg]] )

    storeDefault( [[Icy Veins: Opener]], 'actionLists', 20170612.233537, [[dOZegaGEGkAtOaTlbSnGQAFOaMnO5duLBcuPVHI2jG9sTBK2VqgfqPAye1VrCALgkqrgSqnCP4GKQofqrDms5CaLYcfKLkIfJklNKhcuONcTmuvpNWerbzQI0KLQPl5IcQhlQlR66azJOqTvsf1MjshwX9qb1NjIPrQiFNuPBlL(lQYOrPEnqbNuGEgPcxdfY5rjJdOKwhqf(jqj2Ao1yy6WbF3CgXSABkJgzOlDablZzm5WpIBa(YAmLbFn(b4RdzM6GrgXMN3bUGZPwc1amIjtJ6Z1sOcNAanNAmmD4GV7qgXSABkJfrIe4d0qQLqfrXmyuCTTpkMHJILncmT3iyIulHAm5cciv(cN6YOEUfUflJnKAjuJbP9npfrzKsO3yYHFe3a8L1yQjBeCjDGP9gjWopDhLldW3Pgdtho47oKrmR2MYyrKib(azcb2j6sfgtUGasLVWPUmQNBHBXYy7RPLOAyteRWyqAFZtrugPe6nMC4hXnaFznMAYgbM2BeCFnTevdBIyfUmGoCQXW0Hd(UdzeZQTPmwejsGpqMqGDIUuHXKliGu5lCQlJ65w4wSmsF7fRWyqAFZtrugPe6nMC4hXnaFznMAYgbM2Be4TxScxgqNCQXW0Hd(UdzeZQTPmkfKIvG(LU5TIIzGOyDiBm5cciv(cN6YOEUfUflJspKdo9BmiTV5PikJuc9gto8J4gGVSgtnzJat7nY4d5Gt)UmaJCQXW0Hd(UdzeZQTPmwejsGpqMqGDIUuHXKliGu5lCQlJ65w4wSmMzpebpo40VWyqAFZtrugPe6nMC4hXnaFznMAYgbM2BemYEiIO4qWPFHlda(o1yy6WbF3HmIz12ugRbEAfq6QefpoiH0dC6WbF3yYfeqQ8fo1Lr9ClClwg7Fk28e6(3ymiTV5PikJuc9gto8J4gGVSgtnzJat7nYqFk2rXOU)nUmatNAmmD4GV7qgXSABkJG9OyXRAPsebad)n8KEipfibBEQNzpkjlvsum4bErX1apTci9qETJOUIvGtho47rXG5OygmkoZEusUGNu1KRLqhyumdWWrXAbyYiJjxqaPYx4uxg1ZTWTyzu6H8uGeSngK238ueLrkHEJjh(rCdWxwJPMSrGP9gz8HrXjGeSDzaWQtngMoCW3DiJywTnLrJjxqaPYx4uxg1ZTWTyzu6H84gLAKCJbP9npfrzKsO3yYHFe3a8L1yQjBeyAVrgFyuCOrPgj3LbaBo1yy6WbF3HmIz12ugnMCbbKkFHtDzup3c3ILrPGuS4rKYRyFEleU9rTgds7BEkIYiLqVXKd)iUb4lRXut2iW0EJmgKIvumrAuCX(rXbHWTpQ1Lb0KDQXW0Hd(UdzeZQTPmAm5cciv(cN6YOEUfUflJdLUSx4ulHAmiTV5PikJuc9gto8J4gGVSgtnzJat7nQNsx2lCQLqD5YiW0EJbZSII15Vub4ikgS0C6vUSb]] )

    storeDefault( [[Icy Veins: AOE]], 'actionLists', 20170612.233537, [[d0tlmaGEPQsTjkKDHKTrOQ2hfQttQzJQ5tbFsQQKhlPVjuoSk7Ks2l0UbTFGFkvvyys0Vj68uKBJWGv1WjOdHOQtjv5yuQZrOkTqkQLsGfJILtYdjufpLQLjKwNuvrtuiyQivtwktx0frK(Ru5YkxhL2OquBvQQQnlHTtO8rev08quPPjvv57ikpJqLXHOcJMqETqOtIu6ZiIRje5Esv55cgLq1brkgTr6Otk8y4RHmO7vLwyIo6ryfhlprg0fm(UWqROL2XkfF7OurfxzmXfj0DHRQpUUFFPwcrRiflg60utTegq6OLnshDsHhdFn0m6EvPfMOhh85XhmPkgVJ4c5uMOg8y4RbEJaFbRYevBf6QobVX9bEXvc(EG3GbWhh8vrNIKf6kuxn1s4XbVX9bEBQyrc8gb(WYudjjqfXnHDfJ3PydI6uRk6uKOHKa(EG3GbWhh85XhmPiKedMSeudEm81aVrGN8GNHTOGIqsmyYsqXke89qxWcswvDbKoMOtdJMRttOxmENInicDAHnD9sPcDOeo0fm(UWqROL2XSlr36ig6rECWlGnict0kkshDsHhdFn0m6EvPfMOhh85XhmPeQMWtTg1GhdFnWBe4lyvMOQSk1Gj4j3(ap5isGVh4nya8XbFE8btkcjXGjlb1GhdFnWBe4jp4zylkOiKedMSeuScbFp0fSGKvvxaPJj60WO560e6InijRGL3PwQ2LOtlSPRxkvOdLWHUGX3fgAfT0oMDj6whXqV)hKKvWYbVGLQDjMOL4q6Otk8y4RHMr3RkTWe94GN8Gpp(GjfHKyWKLGAWJHVg4nya8mSffuesIbtwckwHG3GbWhh8vPK3KKbPeBqswblVtTuTlPuJ40Wa4ng8LG3iWxLsEtsgKQy8ofBqevv0PizbWtUG3g89aFp0fSGKvvxaPJj60WO560e6fJ3XCk1rYqNwytxVuQqhkHdDbJVlm0kAPDm7s0ToIHEKhh8MpL6izyIw9hshDsHhdFn0m6EvPfMOhh8Kh85XhmPiKedMSeudEm81aVbdGNHTOGIqsmyYsqXke8gma(4GVkL8MKmiLydsYky5DQLQDjLAeNggaVXGVe8gb(QuYBsYGufJ3PydIOQIofjlaEYf82GVh47HUGfKSQ6ciDmrNggnxNMqVGvzQtw0LIwNMZ1TtPrNwytxVuQqhkHdDbJVlm0kAPDm7s0ToIHEKzvMaVSa8PObEA5CD7uAmrRiH0rNu4XWxdnJUxvAHj6Xbp5bFE8btQ2iKqDLAWJHVg4nya8mSffuelpcPsOizqhOAsYGGVh4nc8Xbp5bFE8btkcjXGjlb1GhdFnWBWa4zylkOiKedMSeuScbVbdGpo4RsjVjjdsj2GKScwENAPAxsPgXPHbWBm4lbVrGVkL8MKmivX4Dk2GiQQOtrYcGVpWxc(EGVh6cwqYQQlG0XeDAy0CDAc9zADm7iqNwytxVuQqhkHdDbJVlm0kAPDm7s0ToIHoPMg4nVJat0s8r6Otk8y4RHMr3RkTWe9RMAXw3GJqVa4nUpWlo0fSGKvvxaPJj60WO560e6m8RTU2bRdDAHnD9sPcDOeo0fm(UWqROL2XSlr36ig6M5xBGpchSomrRyiD0jfEm81qZO7vLwyI(vtTyRBWrOxa8g3h4fh6cwqYQQlG0XeDAy0CDAc92UuuxGSnHOtlSPRxkvOdLWHUGX3fgAfT0oMDj6whXqpc7srG3jBtiMOf5aPJoPWJHVgAgDVQ0ct0ZJpysXWLYgFj1GhdFnWBe4JdEYd(84dMuesIbtwcQbpg(AG3GbWZWwuqrijgmzjOyfcEdgaFCWxLsEtsgKsSbjzfS8o1s1UKsnItddG3yWxcEJaFvk5njzqQIX7uSbruvrNIKfap5cEBW3d89qxWcswvDbKoMOtdJMRttONIusY6iHFAXg60cB66Lsf6qjCOly8DHHwrlTJzxIU1rm0Plsjjd8Kt(PfBGpUzUu24l7HjAjEr6Otk8y4RHMr3RkTWe984dMufAvi7y4szJAWJHVg6cwqYQQlG0XeDAy0CDAcDg(1wx7G1HoTWMUEPuHouch6cgFxyOv0s7y2LOBDedDZ8RnWhHdwh4JhzTkKG3mxkB9WeTSlr6Otk8y4RHMr3RkTWe984dMufAvi7y4szJAWJHVg6cwqYQQlG0XeDAy0CDAc92UuuxGSnHOtlSPRxkvOdLWHUGX3fgAfT0oMDj6whXqpc7srG3jBti4JhzTkKG3mxkB9WeTSTr6Otk8y4RHMr3RkTWe9RMAXw3GJqVa4nUpWhf8gb(84dMuvrNm0v57eBudEm81qxWcswvDbKoMOtdJMRttOxfDYqxiv6io0Pf201lLk0Hs4qxW47cdTIwAhZUeDRJyOlEeDYa49uPJ4WeTSJI0rNu4XWxdnJUxvAHj6xn1ITUbhHEbWBCFGpk6cwqYQQlG0XeDAy0CDAc9uKsswhj8tl2qNwytxVuQqhkHdDbJVlm0kAPDm7s0ToIHoDrkjzGNCYpTydt0YwCiD0jfEm81qZO7vLwyIEbRYevLvPgmbVX9b(yLG3GbWhh85XhmPAJqc7y4xBbQbpg(AG3iWxWQmrvzvQbtWBCFGx8lbFp0fSGKvvxaPJj60WO560e6vrNm0fsLoIdDAHnD9sPcDOeo0fm(UWqROL2XSlr36ig6IhrNmaEpv6ioWh3UhMOLD)H0rNu4XWxdnJUxvAHj6Kh85XhmPAJqc7y4xBbQbpg(AOlybjRQUasht0PHrZ1Pj0BJqcdDm6COtlSPRxkvOdLWHUGX3fgAfT0oMDj6whXqpcJqc7xbWBwNdtmr36ig60wnb((FAyOFcEA6hKIjI]] )

    storeDefault( [[Icy Veins: Default]], 'actionLists', 20170612.233537, [[diJbdaGELQQnPuHDbPABOk1(uQuZMWnHu(guANkzVu7wL9RQ(jKyyI43cgmedxuoijCmIAHqrlvuTyHA5QYdvQONcwgu55KAIOkzQczYez6sUiQQlJCDrARqHnJQy7kvXPLAAkvPVRuvEmkhwXTjP)IkDsOQNrICnsuNhvmpLkzDqsFwPSLDKb(3elijhBayVoRmyGxeptQOCSHCsqJM8cxIm2eElJdDCkLGvjLnazeRhrV)P6W5LYyXAqbR6WPDKxYoYa)BIfKKX0aWEDwzqIIt5Hh0zJU6Bd90md5KoK(yK2rUmOiUfDXXalC6uvIR6S1md4pPMnv4z4chziNe0OjVWLiJvoXWAujd7mC6uv6JG2S1mxEHZrg4FtSGKmMga2RZkdvyBtqOZcbHuyFN(JSJps1Q0hzxFezLnSgvYakz0rpd5KoK(yK2rUmOiUfDXXaBecUdR6WXv06Ya(tQztfEgUWrgYjbnAYlCjYyLtmGwqAnQKb8moFemO(0O(rqjJo65YlLCKb(3elijJPbG96SYWWQEpex6i1M0FKD)rKnSgvYGcu4BiN0H0hJ0oYLbfXTOlogyJqWDyvhoUIwxgWFsnBQWZWfoYqojOrtEHlrgRCIb0csRrLmGNX5JGb1Ng1pIcu47YR96id8Vjwqsgtda71zLbdRrLma9TjOps082OYqoPdPpgPDKldkIBrxCmWgHG7WQoCCfTUmG)KA2uHNHlCKHCsqJM8cxImw5edOfKwJkzapJZhbdQpnQFeOVnb9rIM3gvUCzynQKb8moFemO(0O(r4fXZKkkx2a]] )


    storeDefault( [[Havoc Primary]], 'displays', 20170612.233537, [[d0d3gaGEf4Liu2LsPyBkfYmLQ4WsMTI(TQUjcvpJIQUniEms2jL2Ry3e2pr6NkXWusJtPu60KmuuzWeXWrQdkL(MsjhJkDouLAHsLLsrzXuy5u1dvqpfAzsH1PuQMOsrtfutMImDvUOcDvuLCzGRJOnIQARuuzZO02vQ(OuL(mcMMuv(ovmsPQ65KA0Oy8iKtcs3sPGRjf58e1RLIATkfQJJQ44g4Guf9PEb)xC4jpbbx4fCpqTJbVYtaCC7CXiOVeeadzaunNUG8qcibTtfbbeG4csfuEHLvdUHf9PEHo21GeTWYQb3WI(uVqh7AqAVcs5LHs9cunaeBFRbHOeTJXA(G8qcibMgw0N6f60fuEHLvdo4YtaC6yxdQzEh0rDumTJPlOM5DAjVpDbHueHWX6g8kpbW1kOyEFWUfy4fIBg0E7hoirlSSAWrSoDSUbzFXfKdwQeSeAPsSL3)ob1mVdC5jaoD6c2SrRGI59bHx4mdAV9dhujmPOQ79TckM3h0mO92pCqQI(uVOvqX8(GDlWWlep4WNwwQe4py)1(tjvs7YyqnZ7GWPlipKasWMkpG6uViOzq7TF4GcsiqPEHo2(cQPbZj)zPzg(Z3h4GvSUb9X6gKqSUbnI1nxqnZ7mSOp1l0XiirlSSAW1s6RyxdwK(cwMge0GKLniKIOwY7JDnOXunyqVZ3PDoJrWAsZuiZ7WTpgRBWAsZudFig1XTpgRBWnbSf58sxWA6uYAUDU0fCxPvgQP6KHLPbbncsv0N6fTtfbrWHJw4rZcAsPPNLmSmniyf0xccayzAqWYqnvNCWI0xexjaPlyZg8FXHQbGyDBeSM0mfC5jaoUDUyDd6bZGdhTWJMfutdMt(ZsZeJG1KMPGlpbWXTpgRBqEibKatqfMuu19ED6cI0akvnvdQt9IyBARTcAliGG9x7pLujCEfKYlh8kpbWX)fhEYtqWfEb3du7yqta2ICETC9eekLSujMdOe6TlvYMa2ICEbB2G)lo8KNGGl8cUhO2XGYH)g2wEVvJv3M6ZL3n1W8RBTg2n0xtbRjnt1oDkzn3oxSUbRjntHmVd3oxSUbP9kiLxM)lounaeRBJG0Ea1dXOUwUEccLswQeZbuc92LkztaBroVGef7AqifrTJXUguZ8oOJ6OyAjVpDbVYtaCC7JXiOzGjO0GyBS6U16g52yBAy(g8UrFb1mVd3ox6cQzEhIbKnuctkbbD6cs9qmQJBFmgbPk6t9c(V4q1aqSUncwtAMQD6uYAU9XyDd2Sb)xCb5GLkblHwQeB59VtqnZ7avysrv371PlO8clRgCTK(k21G10PK1C7JPlOM5DAhtxqnZ7WTpMUGupeJ6425IrWAsZudFig1XTZfRBWI0xTckM3hSBbgEH49mYhoipKkQMnNsJN8eeSccrjq4yxdELNa44)IdvdaX62iyr6lOc2hwMge0GKLnivrFQxW)fxqoyPsWsOLkXwE)7eSi9fsdMtOBg7AWrrzmbMsxqTcc9e0UmgBJGAM3PL0xqfSFmcs0clRgCWLNa40XUg8kpbWX)fxqoyPsWsOLkXwE)7euEHLvdoOctkQ6EVo21GeTWYQbhuHjfvDVxh7AqJPAWGENVtmcYdjGeyck1lq1aqS9Tgur9cKUOuccX2uqf1l24)HeRBtb5HeqcmX)fhQgaI1Trq5fwwn4iwNo2n4gKhsajWeX60PlieLOL8(yxdwK(Ixc1fKEwYaFUea]] )

    storeDefault( [[Havoc AOE]], 'displays', 20170612.233537, [[dWJXgaGEPuVePu7ccuBdcKzkLy2kCyj3ePKxtLY3OsYZqkYoP0Ef7MW(js)urggK63Q8CsnuuzWeXWrYbPOttYXKIZHuGfQOwkvIfJslNQEOuvpf8yewhsHMie0uHYKPGPR0fLkxfPIlRQRJOnsH2keWMrvBhI(ivQ(mu10qQ03PIrkL0YKQmAumEi0jHKBHuuxJkPoprDBOYArkOJJu1PjybikQvDcJNyHvE8bMOdwlOSDb2YJ)xoKCHnGVe4)(mpHBzoa7q1UT7JZjSbKN451)2VOw1j0XIoaIt886F7xuR6e6yrhGEYN8nGI4eGQ9hlDrhaNsy2flnfGEYN8n0VOw1j0zoG8epV(xSYJ)xDSOdOzohWrTemMDHnGM5Cmj3lSbWvicyX2eylp(FnfemNpW8eg2eTCbL7TIfqowAUxd6aYt886FP9SowAUjGM5CWkp(F1zoGBSMccMZhaBIZfuU3kwaLWGIO2ZBkiyoFaxq5ERybikQvDctbbZ5dmpHHnrRa9pkzPsWUaTwipcPsmN6cOzohalZbON8jFeQ8pXQoraxq5ERybeK4qrCcDS0nGM6hdJJsZ0)gNpybQyBcWgBta8X2eWhBt2aAMZPFrTQtOdBaeN451)As6RyrhOi9fMm1hGLKNpaUcrtY9IfDa2HQDB3hNJ5ye2a1GIPaMZHdzxSnbQbft1)WXwlhYUyBcGWNVihBMdudNswZHKlZbqQ0kw1qTYyYuFa2aef1QoH5qHxeOFNfRZLaguAQrjJjt9bic4lb(htM6duSQHALduK(IwkXN5aUXA8elOA)X20lqnOykSYJ)xoKCX2eW)Ja97SyDUeqt9JHXrPzcBGAqXuyLh)VCi7ITja9Kp5BaLWGIO2ZRZCaG6ju1q1Uw1jI11UYvbWPeMK7fl6aB5X)RXtSWkp(at0bRfu2UagE(ICSMCTeafHSujiWReAAuQee(8f5ydWFInahMujqj0sLylV)CcG4epV(xApRJTjqnOykZHtjR5qYfBtafXjOH3Hl2gxhGYRWvEzJNybv7p2MEbO8pXHJTwtUwcGIqwQee4vcnnkvccF(ICSbueNaOkcLaFSUoaUcrZUyrhGYRWvEzueNauT)yPl6aB5X)lhYUWgGEYN8nhk8cCVydqeWLF8L(JTh6gxHgb10db3JM6rd6r3aioXZR)fLWGIO2ZRJfDa5jEE9VOegue1EEDSOdSLh)VgpXgGdtQeOeAPsSL3FobqCINx)lw5X)Row0b0mNJjPVqj4VWgqZCoOegue1EEDMdipXZR)1K0xXIoqnCkznhYUmhqZCoCi7YCanZ5y2f2aeho2A5qYf2afPVaQFmqHWyrhOi9LPGG58bMNWWMOvlDgXcuK(cLG)WKP(aSK88bWPeawSOdSLh)VgpXcQ2FSn9cqpPIWneqPHvE8bydquuR6egpXgGdtQeOeAPsSL3FobQbft1)WXwlhsUyBc0jk2XBiZb0kCuJ3CQl2EbCJ14j2aCysLaLqlvIT8(ZjqnOykZHtjR5q2fBtaIIAvNW4jwq1(JTPxaIdhBTCi7cBanZ5q7xMvjmOe41zoGM5C4qYL5aAMZbCulbJj5EzoaIXIoqnOykG5C4qYfBta6jFY3GXtSGQ9hBtVaUXA8elSYJpWeDWAbLTla9Kp5BG2Z6mhWw4(aTwipcPsmN6cuK(Ioc1gGAuYVpBca]] )

    -- storeDefault( [[Vengeance Primary]], 'displays', 20170423.214519, [[dStJgaGEQsVeQs7sbkBdkcZKQOzlv3eQIdl52kQxtvyNuSxXUr1(Hc)uHgMI8BiptbQgkkgSQudhrhuk(SQ4yuYXrPSqQQLIs1IjYYPYdvqpf8yK8CsnrfitvvnzcmDLUOu6Qqv5YQCDe2ibTvOOAZeA7qPpQaonjtdQQ(oLAKOewgkPrJuJxvYjHk3ckkxdLOZtuJdksTwOi5Bqr0Xk)auf5QqCHi(cRC)cmIVVN4mTb2Y9CldwMifWv8NBi9r5r8dWgXrCnD1dF(4BaQaYJII6BhwKRcX1Xmf41OOO(2Hf5QqCDmtbiDQ5YjJJcXbL3lg8pfywXBAJzWdWgXrCcgwKRcX1XpG8OOO(2F5EUvhZuannYgSvlfDtB8dOPr2nelk(bMRxWpgRaB5EUTHtrJCb8h))r8WoUbyXpGCmygRSete4vmtb00i7F5EUvh)aEi1WPOrUa)rg2Xnal(buCbkQArUgofnYfGDCdWIFaQICviEdNIg5c4p()J4jaqEuQQR8wRcXJHLyARaAAKn8JFa2ioIBqk3rTkepa74gGf)aCIzCuiUog8hqtE9UWEPPhI6ix(bQyScifJvGNySc4IXkBannYEyrUkexhPaVgff132q4QyMcueU6ltEbKiefdmxVAiwumtbK6kVEhOJSB69ifO6K0fqJSzW2gJvGQtsxdrZs1YGTngRad6elI(gPav3UK1myzIFaSkTss1vR8xM8cifGQixfI30vp8adBn)w2diqPj7L8xM8ciiGR4p3xM8cusQUALdueUcpk(f)aEijeXxq59IXI1avNKU(L75wgSmXyfWD9adBn)w2dOjVExyV00rkq1jPRF5EULbBBmwbyJ4iob44cuu1IC64hWuZxam)4pxXPomEZ4uZLtoWwUNBfI4lSY9lWi((EIZ0gywXBiwumtb8qsiIVWk3VaJ477jotBa2ioItaokehuEVyW)uGQtsxnD7swZGLjgRaVgff13IxFDmwbiDQ5YjleXxq59IXI1aKUJcnlvBdJNXmfqrH4ykeAoglwgyUE10gZuareFdW8X4nuCngVnLZHSdSL75wgSTrkGIcXbYIsXFIHLby)6xPVaSozHjNWV10GzfqQR86DGoYosbEnkkQVfhxGIQwKthZua5rrr9T44cuu1IC6yMcSL75wHi(gG5JXBO4AmEBkNdzh41OOO(2F5EUvhZuannYghxGIQwKth)aAAKDdHRWXfrrkq1Tlznd224hqtJSzW2g)aAAKDtB8dqHMLQLbltKcueUQHtrJCb8h))r84zRWFGIWva5174gumtbyJqr5bMR0Wk3VavGzfh(Xmfyl3ZTcr8fuEVySynqr4kCCr0xM8cirikgGQixfIleX3amFmEdfxJXBt5Ci7avNKUgIMLQLbltmwbA5Lu)ee)aA1mz)AgBJH1aYJII6BBiCvmtb8qsiIVby(y8gkUgJ3MY5q2bQojD10Tlznd22yScqvKRcXfI4lO8EXyXAak0SuTmyBJuannYgVNSKIlqXF0XpGMgzZGLj(b00iBWwTu0nelk(bQojDb0iBgSmXyfGnIJ4eieXxq59IXI1aYJII6BXRVogmZkaBehXjaV(64hqWjwe9THXZyMcueUcFC1gGSxYNlBca]] )


end

