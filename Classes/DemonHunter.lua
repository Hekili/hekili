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
            gcdType = 'spell',
            cooldown = 10,
        } )

        addHandler( 'fel_rush', function ()
            if talent.fel_mastery.enabled then gain( 30, 'fury' ) end
            if talent.momentum.enabled then applyBuff( 'momentum', 4 ) end
            setDistance( abs( target.distance - 15 ) )
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
            usable = function () return target.within15 end
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


    storeDefault( [[Kib: Simple]], 'actionLists', 20170525.095620, [[d0Z5kaGEiq1lHayxqABuQ2hLiRdcqZwQ5tj4tqa50GUnrDys7eH9QSBG9JeJsKYWeX4GG4Eqq6GurdgPmCO0HGG6uIuDmjDoiqAHivlLsAXsSCQ6HqGYtrTme1Zj0eHIyQeyYIA6cxKi9nc6YQUoeAJqrARqGyZukBNk8rkH(muyAqr57ijpJiEmunAiAtiPoPi5VuPRrjQZJiRecO(nfVgkQE1jymHk)XiaWccifAmugB)XyYTPi2XOp267RIFeKtQctSmzYOKRjcRJzCpeBmESt8aAaItWiQtWyPaT0pp6Jju5pgtFtHMvefro267RIFeKtQ2RcrtKuhNcKH4Ay8JbgWhZ4Ei2ymos1JXfrOKPgZ)X6A7TRhrrKU(JJu9yabym2zb2WG0yBVD9ikICXiipbJLc0s)8OpMX9qSX4q7dc0sBm5(b6bAPF2cwi0(Gav2iFqGOm6bAPFES13xf)iiNuTxfIMiPoofidX1W4hdmGp2zb2WG0yhhGXTHy76F4VgJju5pgb5amUneBk0S(WFnwmcjtWyPaT0pp6JzCpeBmo0(Ga12B3I69kgh9aT0ptnos1JXfrOwES13xf)iiNuTxfIMiPoofidX1W4hdmGp2zb2WG0yBVDlQ3Ry8XeQ8hJPVPqJU69kgFXiWSjySuGw6Nh9XmUhInghAFqGwAJj3pqpql9ZuhAFqGkRIX9UgBUbY7IrRqhh9aT0pp267RIFeKtQ2RcrtKuhNcKH4Ay8JbgWh7SaByqACG0BOYfJwHo(ycv(JfG0BOIcnl2k0XxmclpbJLc0s)8OpMX9qSX4q7dcuBVDVhrSb0aqpql9ZJT((Q4hb5KQ9Qq0ej1XPaziUgg)yGb8XolWggKgB7T79iInGgWycv(JX03uOj1Ji2aAalgH9jySuGw6Nh9XmUhIngp267RIFeKtQ2RcrtKuhNcKH4Ay8JbgWh7SaByqASne9KCn2CdK3f2nmRE4ycv(JXue9KOqZyJcTa5Pqlv3WS6HlgHWjySuGw6Nh9XmUhInghAFqGMVSbaXrpql9ZJT((Q4hb5KQ9Qq0ej1XPaziUgg)yGb8XolWggKgFs3TCvEmHk)XsjDk0OFvEXiqitWyPaT0pp6JzCpeBmo0(Ga1g0lgUL2yYOhOL(zlyH0u8a64UhCz4fTKeQdTpiqXrQgrx8(QJJEGw6NtFS13xf)iiNuTxfIMiPoofidX1W4hdmGp2zb2WG04sR57Mva(htOYFm9wZNcnmrb4FXiqqNGXsbAPFE0hZ4Ei2yCO9bbQnOxmClTXKrpql9ZwWcPP4b0XDp4YWlAjjuhAFqGIJunIU49vhh9aT0pN(yRVVk(rqoPAVkenrsDCkqgIRHXpgyaFSZcSHbPX5RbsxrQ(XoMqL)ym5AGKcnMQFSlgrnzcglfOL(5rFmJ7HyJXH2heOL2yY9d0d0s)m1kEaDC3dUm8IwQo267RIFeKtQ2RcrtKuhNcKH4Ay8JbgWh7SaByqACG0BOYfJwHo(ycv(JfG0BOIcnl2k0XPqlTA6lgrTobJLc0s)8OpMX9qSX4q7dc0sdbzxBi6jHEGw6NhB99vXpcYjv7vHOjsQJtbYqCnm(Xad4JDwGnmin(KUB5Q8ycv(JLs6uOr)QmfAPvtFXiQKNGXsbAPFE0hZ4Ei2y8yRVVk(rqoPAVkenrsDCkqgIRHXpgyaFSZcSHbPXkaarcBnGgWycv(JDcaqKWwdObSyevjtWyPaT0pp6JzCpeBmo0(GaT0gtUFGEGw6NhB99vXpcYjv7vHOjsQJtbYqCnm(Xad4JDwGnminoq6nu5IrRqhFmHk)Xcq6nurHMfBf64uOLg50xmIkMnbJLc0s)8OpMX9qSX4cI2SHk)qLnESinIqr0SHka1kEaDC3dUm8IwQsDAiCO9bbAPHGSRne9Kqpql9ZuJWH2heO4ivJOlEF1Xrpql9ZuJWH2heO5lBaqC0d0s)C6JT((Q4hb5KQ9Qq0ej1XPaziUgg)yGb8XolWggKgFs3TCvEmHk)XsjDk0OFvMcT0iN(IruT8emwkql9ZJ(yg3dXgJliAZgQ8dv24XI0icfrZgQauR4b0XDp4YWlAPkfe4XwFFv8JGCs1EviAIK64uGmexdJFmWa(yNfyddsJdKEdvUy0k0XhtOYFSaKEdvuOzXwHoofAPjj9fJOAFcglfOL(5rFmJ7HyJXJT((Q4hb5KQ9Qq0ej1XPaziUgg)yGb8XolWggKgJJunIUIHhI5FmHk)XiyivJifAC4Hy(xmIQWjySuGw6Nh9XmUhIngp267RIFeKtQ2RcrtKuhNcKH4Ay8JbgWh7SaByqAC(YgGOBbgFmHk)XyYLnaeirk0OdJVyeveYemwkql9ZJ(yg3dXgJdTpiqZx2aClTMVi6bAPFMAeo0(GaT0gtUFGEGw6NhB99vXpcYjv7vHOjsQJtbYqCnm(Xad4JDwGnminoq6nu5IrRqhFmHk)Xcq6nurHMfBf64uOLgML(IfJzShhQnebxdObmcllu4Ina]] )

    storeDefault( [[Kib: Complex]], 'actionLists', 20170525.095620, [[da0DqaqibQnHK6tKuGrHICkKKxrsrSlQmmHCmqwgs8msPPrsfxtPcBtj5BKIXrsjDoLkI1rsbnpskQ7rsv7tGCqPQwij5HKuQjssLUOuXgvQKpQuPoPsQxQur6MKuIDsILkv5PetvaBLKI0EH(RszWcYHPSyP8yqnzjUSQnluFwQ0OrHtJ41kvuZg42u1Uv8BunCLy5s65i10fDDs12vQ67OOgpjfY5rjRNKc18rP2VGAecdGII5pk7ustnmCi1M7xaxncf19XMoirvO07GB0hvOebPjAhuO4OafPbcfbUswsuqPpCs4dngavGWaO0zSg4fufkcCLSKOGs)gbqswOaZhAD)38wxcmkRNcb2sEfLHphLEhCJ(OcLiOvqACrAHqrX8hf1Mp06(hoKAX6sGXevOGbqPZynWlOkue4kzjrj5D7cUdMZbfoZdnk9o4g9rfkrqRG04I0cHY6PqGTKxrz4ZrrX8hf1YtZZRlm40eAu63iasYcf)tZZRlm40eAmrfTyau6mwd8cQcffZFuuBggNoCivaRCAu6DWn6JkuIGwbPXfPfcL1tHaBjVIYWNJs)gbqswOaZW40BnGvonkcCLSKOK8UDb3bZ5GcN5HMAMA6XXo)tZZRlm40eAx9EJm0bPEikSzdZ5GcN5X5FAEEDHbNMq7Q3BKHoidoj8XbZW40BnGvoTdMZbfoZJAcefQWevuhmakDgRbEbvHIaxjljkjVBxWDWCoOWzEOrPFJaijluM7pnHgL1tHaBjVIYWNJII5pkk3FAcnk9o4g9rfkrqRG04I0cHjQSdmakDgRbEbvHII5pk76GWH6PtZaLEhCJ(OcLiOvqACrAHqz9uiWwYROm85O0VraKKfkXhSv1PzGIaxjljk0ptY0L2TZ)lBXhSv1PzSvpmdR2LmDPMjygwT7P3IRgCs4Jbcs9qon7GAMconWN0fFWM3OZxz5(ynWlSzhRxz5kpMatYGuV2iQOctuzfgaLoJ1aVGQqrGRKLeL0aFs3s9lw9f3hRbEHnBMsd8jDEU)tQ7DFSg4fQdUPhh78C)Nu370xOcLEhCJ(OcLiOvqACrAHqz9uiWwYROm85OOy(JIA6NUpwheouVN1Bjk9BeajzHY(pDFSoyR(SElXev0GbqPZynWlOkue4kzjrHPGtd8jDEU)tQ7DFSg4f2SB6XXop3)j19o9fQOgMHv7EA1Vdu6DWn6JkuIGwbPXfPfcL1tHaBjVIYWNJII5pk76GWHuz1Q19O0VraKKfkXhS1SA16Emrf1kgaLoJ1aVGQqrGRKLefygwT7Pds9qon7GAMsd8jDnaNxapDFSg4fQtd8jDEJoFDJhVLm(wxGr2F3hRbEHkQzk40aFsNN7)K6E3hRbEHn7MECSZZ9FsDVtFHku6DWn6JkuIGwbPXfPfcL1tHaBjVIYWNJII5pkbyu5mho0Ubgz)rPFJaijlusgvoZBDbgz)Xev2jyau6mwd8cQcfbUswsusd8jDXhS9Q(ss4J7J1aVGsVdUrFuHse0kinUiTqOSEkeyl5vug(Cuum)rzxheouNQ(ss4dk9BeajzHs8bBVQVKe(GjQafHbqPZynWlOkue4kzjrHPGtd8jDEU)tQ7DFSg4f2SB6XXop3)j19o9fQqP3b3OpQqjcAfKgxKwiuwpfcSL8kkdFokkM)OSl9kRWH4XHdLmE4qRbasXQeu63iasYcLy9kRnE8wY4BeaGuSkbtubccdGsNXAGxqvOiWvYsIsAGpPRCpFiWUpwd8cB2gCs2)Tp3toDquqP3b3OpQqjcAfKgxKwiuwpfcSL8kkdFokkM)O0H1dhs1npk9BeajzHYz9T2npMOcefmakDgRbEbvHIaxjljkPb(KUysLo3AaoV4(ynWlSzBWjz)3(Cp50brHnBMm4KS)BFUNC6G0sDAGpPdMHXP3Gb32F3hRbEHku6DWn6JkuIGwbPXfPfcL1tHaBjVIYWNJII5pkQaw5HdPU2aFu63iasYcLgWkFRyd8XevG0IbqPZynWlOkue4kzjrjnWN0ftQ05wdW5f3hRbEHnBdoj7)2N7jNoikSzZKbNK9F7Z9KthKwQtd8jDWmmo9gm42(7(ynWluHsVdUrFuHse0kinUiTqOSEkeyl5vug(Cuum)rrDVLmchsy(FbL(ncGKSqPClzSrZ8)cMOcK6GbqPZynWlOkue4kzjrjnWN01aCEb809XAGxO2GtY(V95EYPdcIAMconWN055(pPU39XAGxyZUPhh78C)Nu370xOcLEhCJ(OcLiOvqACrAHqz9uiWwYROm85OOy(JsagvoZHdTBGr2)WHycIku63iasYcLKrLZ8wxGr2FmrfODGbqPZynWlOkue4kzjrjwVYYvEmbMKbPETrO07GB0hvOebTcsJlslekRNcb2sEfLHphffZFu21bnGvok9BeajzHs8bnGvoMOc0kmakDgRbEbvHIaxjljkPb(KUgGmLTy9kl3hRbEbLEhCJ(OcLiOvqACrAHqz9uiWwYROm85OOy(JshwpCiv38HdXeevO0VraKKfkN13A38yIkqAWaO0zSg4fufkcCLSKO00JJD(NMNxxyWPj0o9fQzk40aFsNN7)K6E3hRbEHn7MECSZZ9FsDVtFHn7y9klx5XeysQMPerfk9o4g9rfkrqRG04I0cHY6PqGTKxrz4ZrrX8hL(Zqyqaws4dk9BeajzHIndHbbyjHpyIkqQvmakDgRbEbvHIaxjljkPb(KUgGZlGNUpwd8c1mfCAGpPZZ9FsDV7J1aVWMDtpo255(pPU3PVqfk9o4g9rfkrqRG04I0cHY6PqGTKxrz4ZrrX8hLamQCMdhA3aJS)HdXefQqPFJaijlusgvoZBDbgz)XevG2jyau6mwd8cQcfbUswsuA6XXo)tZZRlm40eAxHZ8qntbNg4t6AaYu2I1RSCFSg4fQdonWN0bZW40BWGB7V7J1aVqDWPb(KUY98Ha7(ynWlurTbNK9F7Z9Kthee1wnjXgC6SPRoHMXgpElz8TYHpz)RUpwd8ck9o4g9rfkrqRG04I0cHY6PqGTKxrz4ZrrX8hLoSE4qQU5dhIjkuHs)gbqswOCwFRDZJjQqjcdGsNXAGxqvOiWvYsIstpo25FAEEDHbNMq7kCMhQn4KS)BFUNC6GGqP3b3OpQqjcAfKgxKwiuwpfcSL8kkdFokkM)OeGrLZC4q7gyK9pCiM0sfk9BeajzHsYOYzERlWi7pMOcfimakDgRbEbvHIaxjljkm10JJDEU)tQ7D6lSzhCAGpPZZ9FsDV7J1aVqfB2X6vwUYJjWKuntjcLEhCJ(OcLiOvqACrAHqz9uiWwYROm85OOy(JIAZW40HdjzLSZhL(ncGKSqbMHXP3OZkzNpMOcfkyau6mwd8cQcfbUswsuGzy1UNoi1RouZuWPb(Kop3)j19Upwd8cB2n94yNN7)K6EN(cvO07GB0hvOebTcsJlslekRNcb2sEfLHphffZFu21bHdPYQvR7dhIjiQqPFJaijluIpyRz1Q19yIku0IbqPZynWlOkue4kzjrjwVYYvEmbMKbPEkrO07GB0hvOebTcsJlslekRNcb2sEfLHphffZFuu375JAaD4qQi5rPFJaijluk3Zh6TgjpMOcf1bdGsNXAGxqvOOy(JsagvoZHdTBGr2Fu6DWn6JkuIGwbPXfPfcL1tHaBjVIYWNJs)gbqswOKmQCM36cmY(JIaxjljkPb(KUY98zRbSYPDFSg4fQdonWN01aCEb809XAGxWetuKLdtmarn2scFqLDOrdMic]] )

    storeDefault( [[Red Vengeance: precombat]], 'actionLists', 20170525.095620, [[dit2baGEusTlkyBcv7tPkZgYTfyNkAVKDdA)kyyO43szWsvdxQCquvhJslKkzPqPflOLtvpNIEQQhRK1bvvteQstvHMSqMoWfPsDyjxg56qvzJOKSvuI2Ssz7Ou9ruclJk(mu57OuoVsLRHkA0cLVbfNev6zOkNw09GQ4VuOXPuvVgvyz1O(SciDSu0qpljioQGlc)d9DEA1cclGoEPTcFiGCPJLquzsA6WyXWWPJJbhldgR(7OvwOK1fiBqn5CFRo)fiBqtnQPvJ6UHviIIKl9zfq6pXLOH(22qpRqvaPJLquzsA6WyJBXyGHNvNlmkxfO51HniPZpmrjyNUzIlrgBBg3qvaP)Lp7a6cOPJg1DdRqefjx6ZkG05c3ipSqd9h4toiDSeIktsthgBClgdm8S6CHr5QanVoSbjD(Hjkb70t4g5HfYOjWNCq6F5ZoG(kw5XrM7HhRaAYtJ6UHviIIKl9zfq6JX8n2g6zbQs2jDSeIktsthgBClgdm8S6CHr5QanVoSbjD(Hjkb70bX8n2mIdvj7K(x(SdOlGa6F5ZoGUasa]] )

    storeDefault( [[Red Vengeance: default]], 'actionLists', 20170525.095620, [[die)laqiuk1MuvmksvofPQwLQkf7ssdtOogelJu6zQsMgkf6AOuTniX3uvACKk05uvPQ1rQG5Hk6EQI2hPs)dLI6GQsTqvv9qukYerPGlcPAJKk6KqsRuvLu3eLs2jQ6NQQegQQkjlvK6PunviLRQQsPTkKQVQQs0Er(lugmP4WuwmkESOMSexgSzf9zHy0cjNM41cPmBPUnuTBv(njdxelxWZvy6kDDuY2fjFxvfNxvy9QQuz(Oc7hvAcHqJCEdhipnu4Qj6WfbSld6axnfyAS6LC2amnw9s)jpn0GnaIxBmY3y21QTQfj(lc5EcKfRLFNTI6iE21reYFNxrDdcnIhHqJC2svIUf4nCGCwdaBirKgtnXMTHdK75GKSKR3AnCBD2goGLd2iQkCgtdLpfGH1CwhsePXutSzB4qna4MCdoFIOphCOhBVwd3wNTHdy5GnIQcNX0qrFY5nCG8F7a4QXLisZvJAYvJoBdhyZK)MrAzFqEkligtdKJ6vKSTQa5N6aYtdnydG41gJGcY3A8leYr)mMgk0FAjETeAKZwQs0TaVHdK)Jjl2ufWscIki7dmJrAzfyqUNdsYsUEzLQlQFUQGJRABf1HzScwna4MCdoJRS)jXKRwGPKLv3NiSRphCO3AnCBDcntBfOcNX0q5twP6I6NRoHMPTcudaUj3GZ4k7Fsm5Qfykzz19zIjhwbMswwSwWLvFo4qV1A426eAmiWkzf1vHZyAO8jRuDr9ZvNqJbbwjROUAaWn5gCgxzxFo4qVuwqmMgQSga2qIinMAInBdh(y5vsbyWb4cm09P2pzLQlQFU6qIinMAInBdhQba3KBWzCLD95Gd9IcSEJQMaHmClNpl2fbcyBubyeLQlFYkvxu)C1j0yfiLnwBf1vdaUj3GZ4k7Fsm5QzwHaCRUpFfRp5VzKw2hKNYcIX0a5PHgSbq8AJrqb5Bn(fc5OEfjBRkq(PoGCEdhi)xAYYvZuf4Q5xfevq2hC18MrAzfyWMjh9ZyAOq)PL4FrOro6NX0qH(tUNdsYs(QIePHAbMWnKuWG83msl7dYZw3ywEf1H1Yyjpn0GnaIxBmckiFRXVqih1RizBvbYp1bKZB4a5Sbyc3qsbdYzlvH3WbYtdfUAIoCra7YGoWvtbMWnKuWGwINnsOro6NX0qH(toVHdK7kwnxnSPgSua5PHgSbq8AJrqb5Bn(fc5OEfjBRkq(PoG83msl7dYhkwnwUblfqUNdsYsEIjxnZkeGB19jkXFyynN1HIvJndweC42rDSwoA)g258zuG1Bu1cmLSSyj5LwINDcnYr)mMgk0FY9CqswYxRHBRJejilgJcNPcNX0q5tbyynN1zWKEFudaUj3Gt2)WWAoRdfRgBgSi4WTJ6yTC009jc5PHgSbq8AJrqb5Bn(fc5OEfjBRkq(PoGCEdhi3tKGSC18xHZq(BgPL9b5JejilgJcNHwIhfcnYr)mMgk0FY9CqswYtm5Qfykzz19jc7KNgAWgaXRngbfKV14xiKJ6vKSTQa5N6aY5nCGCuXXvTTI64Q5nRGr(BgPL9b5coUQTvuhMXky0s8Fj0ih9ZyAOq)j3Zbjzj3YRKcWGdWfyO7tTFkadR5SoKisJPMyZ2WHAaWn5gC(eH80qd2aiETXiOG8Tg)cHCuVIKTvfi)uhqoVHdK7seP5Qrn5QrNTHdK)MrAzFq(qIinMAInBdhOL41rcnYr)mMgk0FY9CqswYxRHBRtOzARav4mMgkFsm5Qfykzz19zIjhwbMswwSwWLL80qd2aiETXiOG8Tg)cHCuVIKTvfi)uhqoVHdKRtOzARaK)MrAzFq(eAM2kaTe)VNqJC0pJPHc9NCEdhi)xmNWnKuWGCphKKL8vfjsd1Ss1f1p3G80qd2aiETXiOG8Tg)cHCuVIKTvfi)uhq(BgPL9b5zRBmlVI6WAzSKZwQcVHdKNgkC1eD4Ia2LbDGRg1Cc3qsbdAjEKycnYr)mMgk0FY9CqswYT8kPam4aCbgpr(Swd3wNblVScqfoJPHYNetUAbMswwotm5WkWuYYI1cUSKNgAWgaXRngbfKV14xiKJ6vKSTQa5N6aY5nCGCDgS8YkaK)MrAzFq(my5LvaOL4rqi0ih9ZyAOq)j3ZbjzjVamSMZ6qIinMAInBdhQba3KBW5teYtdnydG41gJGcY3A8leYr9ks2wvG8tDa58goqUlrKMRg1KRgD2goWvJEi6t(BgPL9b5djI0yQj2SnCGwIhrlHg5OFgtdf6p5Eoijl56X2R1WT1zWYlRauHZyAOWbhwELuagCaUadDFQv)pjMC1cmLSSCMyYHvGPKLfRfCzjpn0GnaIxBmckiFRXVqih1RizBvbYp1bKZB4a5UIvZvdBQblfWvJEi6t(BgPL9b5dfRgl3GLcOL4rErOro6NX0qH(tUNdsYs(AnCBDcngeyLSI6QWzmnuipn0GnaIxBmckiFRXVqih1RizBvbYp1bKZB4a56eAUAqpWkzf1r(BgPL9b5tOXGaRKvuhTepcBKqJC0pJPHc9NCphKKL8uwqmMgQSga2qIinMAInBdh(OxwP6I6NRk3ecN1yJnirdQ5OSqeyGndwEf1zTUprQ6i7CWHLxjfGbhGlWq3NA1N7VM80qd2aiETXiOG8Tg)cHCuVIKTvfi)uhqoVHdKJ6nHWznxn(gKObK)MrAzFqUCtiCwJn2GenGwIhHDcnYr)mMgk0FY5nCGCpkWcC1OhI(KNgAWgaXRngbfKV14xiKJ6vKSTQa5N6aYFZiTSpiFefybY9CqswYz7uwqmMgQ)yYkxeSPkGLeevq2hygJ0YkWGwAj3ZbjzjNwIa]] )

    storeDefault( [[Red Vengeance: defensives]], 'actionLists', 20170525.095620, [[dSd5iaGEkk0MuvTlkTnvP2huKzJQ5trLUjuu62KQ1bff7Kc7fz3s2pkXOOOKHrk)MW3ejNwLbJsA4O4GQsoffL6yq15OOGfkfTuvHfdXYv6Huu0tPAzuKNlQjksvtvvXKjz6kUikLZtuDzW1LsBKIQ2kuuzZez7Iu(mkvhwyAuuX8Kc)veptv0OH0JLQtcf(UQsxJO4EqPXjsLxtu64qrvt40hYncDG8hGIfwXCqXoevhWmSWQcKGkFPbzYtpifT8HAs(dGdrgidtA4P0KXKjRjCTu4K7mq)c(zgJ5efzit6Wj)vForLPpKbo9HC2QaHdkQj5gHoqUlA5SWQzgBAWs(dGdrgidtA4VXtz1EItogL66XiwYlrbK)c543iN8SOLN0Jnnyj377XmKdy(2JHbu2GR2OJEjFJfHhki)JcbFqTmW2HAAGnLm)iTss2SOLNiTb76qnzBEIUSy1(vasRKKv6GvEcYgLYUGECvgRgnKHj6d5SvbchuutYncDG80d6IIfwDMtwit(dGdrgidtA4VXtz1EItogL66XiwYlrbK)c543iNCfOlQKmZjlKj377XmK3rJLDiNiTrForfCmHf3MsMFKwjjRc0fvsM5KfY2f0JRYy1(vasRKKv6GvEcYgLYUGECvgR2ptCLT3UludMWAs7hfc(GAzGTd10aB6KHgY4j9HC2QaHdkQj5gHoqU5pyLZcRn3OuK)a4qKbYWKg(B8uwTN4KJrPUEmIL8sua5Vqo(nYjx6GvEcYgLICVVhZqoke8b1YaBhQPb20jZpsRKKvb6IkjZCYczRs8T(rALKS6We6ILbvKVSvj(w)iTss2SOLNGe7EWAvIV1Fxi4kX3YQaDrLKzozHSTJgl7qUbonKH5qFiNTkq4GIAsU33Jzihfc(GAzGTd10aRmY8pbhQXkb8efKwKNyorzHkq4G6NjUY2B3fQbtyFQr(dGdrgidtA4VXtz1EItogL66XiwYlrbKBe6a5Mh4SWA6H0I8eZjkYFHC8BKtUeWtuqArEI5efnKHm0hYzRceoOOMKBe6a5ywycDXYGkYxM8hahImqgM0WFJNYQ9eNCmk11JrSKxIci)fYXVro56We6ILbvKVm5EFpMHCui4dQLb2outdS99MRh8KbDHmQGRmxZ1SqHGpOwgy7qnnWAoA)mXv2E7UqnnWAs7VleCL4BzLoyLNGSrPSlOhxLXK2VcqALKSshSYtq2OuwL4B9J0kjzvGUOsYmNSq2QeFR)UqWvIVLvb6IkjZCYczBhnw2HCI0g95evWBOzLXSPHmEtFiNTkq4GIAsU33Jzihfc(GAzGTd10aRkk2HnzqxiJk4kYFaCiYazysd)nEkR2tCYXOuxpgXsEjkGCJqhi3fTCwyTzS7bl5Vqo(nYjplA5jiXUhS0qgPOpKZwfiCqrnj377XmKJcbFqTmW2HAAGvff7WMmOlKrfC1ptCLT3UludMW(wJ8hahImqgM0WFJNYQ9eNCmk11JrSKxIci3i0bYDrlNfwntoePbK)c543iN8SOLN05qKgqdzKo6d5SvbchuutY9(Emd5OqWhuldSDOMgyvrXoSjd6czubx9J0kjzvGUOsYmNSq2QeFRFKwjjRomHUyzqf5lBvIV1psRKKnlA5jiXUhSwL4Br(dGdrgidtA4VXtz1EItogL66XiwYlrbKBe6a5M)GvolS2CJsXcRMfUzt(lKJFJCYLoyLNGSrPOHmmd0hYzRceoOOMKBe6a5yORl4XCIIfwF1Ub5paoezGmmPH)gpLv7jo5yuQRhJyjVefq(lKJFJCYpDDbpMtujr7gK799ygYrHGpOwgy7qnnWQIIDytg0fYOcU6NjUYQaPRFdMWIldnKbUg9HC2QaHdkQj5gHoqU5bocpua5paoezGmmPH)gpLv7jo5yuQRhJyjVefq(lKJFJCYLaocpua5EFpMHCui4dQLb2outdSQOyh2KbDHmQGR(NGd1yLaocpuGfQaHdQFM4kRcKU(nycltCvIcKU(nj8t)gAidCC6d5SvbchuutYncDGChfIL8hahImqgM0WFJNYQ9eNCmk11JrSKxIci)fYXVro5zuiwY9(Emd5OqWhuldSDOMgyvrXoSjd6czubxrdnK799ygYPHi]] )

    storeDefault( [[Red Vengeance: offensives]], 'actionLists', 20170525.095620, [[dKZ8daGEuLQnHI2LeBtQW(iLMnjZNu1nrvWTrPDsr7fz3k2VsyuOGHrHFlP1jvudwQQHdjhes1PqHogOonvluQ0svswmelhQhIQKEQOLPuEoLMiQQmvLutwktx4IKcpgONjv56KkBevfBfvrTzaBheNhK(mQQAAOkX3LkY3uIghQcnAuf5WeNKu0FrLRHQs3tP61qkxw1HqvktW0Aknf2t5Q3w0NN)W)ld478I(vaGpwhYTuYVdi6ub1LYvxDXEYCZaEPbF32kBWglHPmrDqxuoVlHxhYKV8imLOdgEDS0AYeMwtPgJGOEJ6sPPWEk5JFm0f97ILPr5QRUypzUza3b8YIrpyk1CAoOevmLtDoLOJ4kpGsjGFmuoeSmnktqSJkOKbbhoGagfa)yOCTZ62xWYGM2DyMHO(efGR4AhIydj86u(iiQ3ycwRQwTttb4kU2Hi2qcVof8zfFS7gmrj(ua1HXFcT79myuVEg4TquFIcWvCTdrSHeEDkFee1B61l4WbeWOa4hdLRDw3(cwg02nyKcYCJwtPgJGOEJ6sPPWEk5Zvl6ZVdrSHeEDOC1vxSNm3mG7aEzXOhmLAonhuIkMYPoNs0rCLhqPe4kU2Hi2qcVouMGyhvqziQprb4kU2Hi2qcVoLpcI6nMOeFkG6W4pH29EgmzGbbhoGagfa)yOCTZ62xWYGM2DyMcy4qo3NZ63UdZSDeDaafa)yOCiyzAf8zfFSA33yuVEgeC4acyua8JHY1oRBFbldA7g61lGHd5CFoRFR29ngzKcYShTMsngbr9g1LYee7Ockdr9jkwuo2doKkls5JGOEJPagoKZ95S(TA33yIOdaOyR6uCayH)SFcBXgciAA3HP0uypLjkh7XI(DRSiuU6Ql2tMBgWDaVSy0dMsnNMdkrft5uNtj6iUYdOuAr5yp4qQSiuM8uTt8qT5a(XwcHcYKxO1uQXiiQ3OUuMGyhvqjLRU6I9K5MbChWllg9GPuZP5GsuXuo15uAkSNYSQtTOpVkyihtj6iUYdOuAR6uCGcgYXuqbLji2rfusbra]] )

    storeDefault( [[SimC Havoc: normal]], 'actionLists', 20170525.095620, [[di06AaqisfBcu8jIQknkj4usOvbIKxjsjDlIQq2fuggr5ykXYiv9mrQAAevLRjsX2iQQ6BOunoqK6CIuI1rufyEevP7jsL9bI6GKcleL4HKIMirv0fjQSrqeFuKsnsIQGojPs3eK2jkwkkPNszQGsBLuYEr(RenyfhwyXk1JHQjtvxw1MLuFwKmAL0PPYRrPmBc3MKDd53OA4GQLlQNlIPdCDjz7eX3jLA8evvCEqy9evHA(eP9l10cblzYHIT4EAtMHNDWbKrM881rLaqSqgRx8i5eJEzlSlln61JPFzr(sJEYm4h3fcN84a44iIjnSZozAGdCCucblXSqWsMCOylUNyHmdp7GdiRqpGqCeadE(WJ89yhfBX99ivApGqCeatXvhbQuyhfBX99uShy6zxvxJbpF4r(EmpxBupW0ZUQUgtXvhbQuyEU2iY0y7eoaeKj5OuVUsuMpi)aqMMRhNnOCjxDeG2KbL71kYmH6KrgtOozADuQxxj6H1dYpaKX6fpsoXOx2c7lYitxK3HhaEMmehDYGY9mH6KraIrpblzYHIT4EIfYm8SdoGSc9acXramfxDeOsHDuSf33JuP9acXraS6lkvrc4ziWok2I77PypW0tHE0PhqiocGP4QJavkSJIT4(EKkTNc9uOh81iN6j9KUE03dm9W2p8Y6lkZvjRL5JVg5uouQEk2JuP9GZ5cpxBeMKJs96krz(G8daw(QWHs6bY9iF9uShy6zxvxJP4QJavkmpxBupf7bMEk0Jo9acXraS6lkvrc4ziWok2I77rQ0EQRYqG5FTd3b6bYPRh9PPNI9atpf6Pqp4Rro1t6jD9OVhy6HTF4L1xuMRswlZhFnYPCOu9uSNIKPX2jCaiiR(IYCvYkzAUEC2GYLC1raAtguUxRiZeQtgzmH6Kbjx0dRvjRKX6fpsoXOx2c7lYitxK3HhaEMmehDYGY9mH6KraIj9eSKjhk2I7jwiZWZo4aYk0d(AKt9KEsxpQq(PeFnYPEspf7bMEk0ZUQUgtXvhbQuyvW7rQ0E0PhqiocGP4QJavkSJIT4(Ek2dm9uONah4K8YJUY9KEGCpl9uKmn2oHdabz1xuUJCosDY0C94SbLl5QJa0MmOCVwrMjuNmYyc1jdsUOhwICosDYy9IhjNy0lBH9fzKPlY7WdaptgIJozq5EMqDYiaXiFeSKjhk2I7jwiZWZo4aYaH4ia2wW5EXbyhfBX99atpf6rNEaH4iaMIRocuPWok2I77rQ0E2v11ykU6iqLcRcEpf7bMEWxJCQN0t66rpzASDchacYaRzU2LPeHtYjtZ1JZguUKRocqBYGY9AfzMqDYiJjuNmyxZCT7jTfHtYjJ1lEKCIrVSf2xKrMUiVdpa8mzio6KbL7zc1jJaetAiyjtouSf3tSqMHNDWbKvxLHadVkNpc0J82ZsA6bMEk0doNl8CTry(hG1YeT)HJLVkCOKEK3E03dKQNu4(EKkThCox45AJW2IW)sFGWpw(QWHs6rE7rFpqQEsH77PizASDchacYQVylc)jtZ1JZguUKRocqBYGY9AfzMqDYiJjuNmi5ITi8NmwV4rYjg9YwyFrgz6I8o8aWZKH4OtguUNjuNmcqmYFcwYKdfBX9elKz4zhCazsISl2IJTfH)L(aHFY0y7eoaeK5Fawlt0(hozAUEC2GYLC1raAtguUxRiZeQtgzmH6KjpFaw7X0(hozSEXJKtm6LTW(ImY0f5D4bGNjdXrNmOCptOozeGyyNGLm5qXwCpXczgE2bhqwHEWxJCQN0t66rFpW0dB)WlRVOmxLSwMp(AKt5qP6PypW0Jo9acXramfxDeOsHDuSf33dm9OtpGqCeaR(IsvKaEgcSJIT4EY0y7eoaeKvFrzUkzLmnxpoBq5sU6iaTjdk3RvKzc1jJmMqDYGKl6H1QK1EkSuKmwV4rYjg9YwyFrgz6I8o8aWZKH4OtguUNjuNmcqmqAcwYKdfBX9elKbL71kYmH6KrgtOozqYf9ixUcoWXrKP56XzdkxYvhbOnzSEXJKtm6LTW(ImY0f5D4bGNjdXrNmn2oHdabz1xu(CfCGJJidk3ZeQtgbiM0cblzYHIT4EIfYm8SdoGSc9e4aNKxE0vUN0dK7zPNI9ivApf6Pqp60diehbWuC1rGkf2rXwCFpsL2ZUQUgtXvhbQuyvW7PypW0tHE0PhqiocGHVg8KYTi8pb7OylUVhPs7zxvxJHVg8KYTi8pbRcEpsL2doNl8CTry4RbpPClc)tWYxfouspqUN0lRhPs7be5uhGbCQxc4LE37rE7bNZfEU2im81GNuUfH)jy5RchkPNI9uKmn2oHdabz1vzik51LG1x6ecNpYoY0C94SbLl5QJa0MmOCVwrMjuNmYyc1jdsQYq0dVUhW67rxHW5JSJmwV4rYjg9YwyFrgz6I8o8aWZKH4OtguUNjuNmcqmlYiyjtouSf3tSqMHNDWbKjjYUylo2we(x6de(7bMEk0Jo9GZ5cpxBeM6GqXZWx5jUeS8dpe9uKmn2oHdabzBr4FPpq4NmnxpoBq5sU6iaTjdk3RvKzc1jJmMqDYyre(3J8mq4NmwV4rYjg9YwyFrgz6I8o8aWZKH4OtguUNjuNmcqmlleSKjhk2I7jwiZWZo4aYaH4ia2wW5EXbyhfBX99atpboWj5LhDL7j9a501J(EGPNc9OtpGqCeatfjGNl51LG1xMseojh7OylUVhPs7rNEaH4iaMIRocuPWok2I77rQ0E2v11ykU6iqLcRcEpf7bMEk0tGdCsE5rx5EspqoD9K(EksMgBNWbGGmWAMRDzkr4KCY0C94SbLl5QJa0MmOCVwrMjuNmYyc1jd21mx7EsBr4K8EkSuKmwV4rYjg9YwyFrgz6I8o8aWZKH4OtguUNjuNmcqml6jyjtouSf3tSqMHNDWbKvxLHaZ)AhUd0dKtxpPxwpP1E2v11yWZhEKVhRcEpqQEG0KPX2jCaiiR(ITi8NmnxpoBq5sU6iaTjdk3RvKzc1jJmMqDYGKl2IW)EkSuKmwV4rYjg9YwyFrgz6I8o8aWZKH4OtguUNjuNmcqmlPNGLm5qXwCpXczgE2bhqgiehbW2chYxwxLHa7OylUVhy6PqpboWj5LhDL7j9a5Ew6rQ0EQRYqG5FTd3b6bYPRN0NMEksMgBNWbGGSdXl3puKP56XzdkxYvhbOnzq5ETImtOozKXeQtMCq8Ey5HImwV4rYjg9YwyFrgz6I8o8aWZKH4OtguUNjuNmcqmlYhblzYHIT4EIfYm8SdoGSc9acXram)vCu5we(NGDuSf33JuP9OtpGqCeatXvhbQuyhfBX99ivAp7Q6AmfxDeOsHvbVhPs7PUkdbM)1oChOh5TN0lRN0Ap7Q6Am45dpY3JvbVhivpq6EKkTNDvDnM6GqXZWx5jUeS8vHdL0J82tA6PypW0Jo9ijYUylogCox4qPkR55YTi8V0hi8tMgBNWbGGSaHCRoraCCezAUEC2GYLC1raAtguUxRiZeQtgzmH6KPbc5wDIa44iYy9IhjNy0lBH9fzKPlY7WdaptgIJozq5EMqDYiaXSKgcwYKdfBX9elKz4zhCazGqCeaBl4CV4aSJIT4(EGPNc9OtpGqCeatfjGNl51LG1xMseojh7OylUVhPs7rNEaH4iaMIRocuPWok2I77rQ0E2v11ykU6iqLcRcEpfjtJTt4aqqgynZ1UmLiCsozAUEC2GYLC1raAtguUxRiZeQtgzmH6Kb7AMRDpPTiCsEpf0xKmwV4rYjg9YwyFrgz6I8o8aWZKH4OtguUNjuNmcqmlYFcwYKdfBX9elKz4zhCaz60diehbW2chYxwxLHa7OylUVhy6PqpboWj5LhDL7j9a5Ew6rQ0Ek0Jo9KCq5MJQsWaUNxslLYhC8EGCpY6bME0Phjr2fBXXGZ5chkvznpxQoi6bME2v11yQdcfpdFLN4sW8CTr9atpf6jYaxDGdWcuQkxYAjVUeS(s)XVtYZyhfBX99ivApboWj5LhDL7j9a5Ew6PypW0Jo9acXram81GNuIlEi5yhfBX99uSNIKPX2jCaii7q8Y9dfzAUEC2GYLC1raAtguUxRiZeQtgzmH6KjheVhwEO6PWsrYy9IhjNy0lBH9fzKPlY7WdaptgIJozq5EMqDYiaXSWoblzYHIT4EIfYm8SdoGSDvDnM6GqXZWx5jUempxBupW0tGdCsE5rx5EspqoD9ONmn2oHdabzG1mx7YuIWj5KP56XzdkxYvhbOnzq5ETImtOozKXeQtgSRzU29K2IWj59ui9fjJ1lEKCIrVSf2xKrMUiVdpa8mzio6KbL7zc1jJaeZcKMGLm5qXwCpXczgE2bhqwHEaH4iaM)koQClc)tWok2I77rQ0E0PhqiocGP4QJavkSJIT4(EKkTNDvDnMIRocuPWQG3JuP9uxLHaZ)AhUd0J82t6L1tATNDvDng88Hh57XQG3dKQhiDpf7bME0Phjr2fBXXGZ5chkvznpxIVg8KYeq2X27bME0Phjr2fBXXGZ5chkvznpxQoi6bME0Phjr2fBXXGZ5chkvznpxUfH)L(aHFY0y7eoaeKHVg8KYeq2X2jtZ1JZguUKRocqBYGY9AfzMqDYiJjuNmnxdEspgi7y7KX6fpsoXOx2c7lYitxK3HhaEMmehDYGY9mH6KraIzjTqWsMCOylUNyHmdp7GdiRqp4Rro1t6jD9Oc5Ns81iN6j9ipQNLEk2dm9SRQRXuhekEg(kpXLG55AJ6bMEk0ZUQUgtXvhbQuyvW7rQ0E0PhqiocGP4QJavkSJIT4(Ek2dm9uONah4K8YJUY9KEGCpl9uKmn2oHdabz1xuUJCosDY0C94SbLl5QJa0MmOCVwrMjuNmYyc1jdsUOhwICos9EkSuKmwV4rYjg9YwyFrgz6I8o8aWZKH4OtguUNjuNmcqm6LrWsMCOylUNyHmdp7GditNEaH4iaMIRocuPWok2I77bMEk0diehbW8xXrLBr4Fc2rXwCFpsL2ZUQUgtDqO4z4R8excMNRnQNIKPX2jCaiiR(IYCvYkzAUEC2GYLC1raAtguUxRiZeQtgzmH6Kbjx0dRvjR9uqFrYy9IhjNy0lBH9fzKPlY7WdaptgIJozq5EMqDYiaXOFHGLm5qXwCpXczq5ETImtOozKXeQtM88kos(nPhwCGtMMRhNnOCjxDeG2KX6fpsoXOx2c7lYitxK3HhaEMmehDY0y7eoaeK5VIJsk3oWjdk3ZeQtgbig96jyjtouSf3tSqMHNDWbKbICQdWCOYCGsDY0y7eoaeKbwZCTltjcNKtMMRhNnOCjxDeG2KbL71kYmH6KrgtOozWUM5A3tAlcNK3tb5RizSEXJKtm6LTW(ImY0f5D4bGNjdXrNmOCptOozeGy0NEcwYKdfBX9elKz4zhCazGiN6amVlbei83JuP9aICQdWCOYCGsDY0y7eoaeKvFXwe(tMMRhNnOCjxDeG2KbL71kYmH6KrgtOozqYfBr4Fpf0xKmwV4rYjg9YwyFrgz6I8o8aWZKH4OtguUNjuNmcqm6LpcwYKdfBX9elKz4zhCazGiN6amVlbei83dK7zjn9ivApf6be5uhG5qL5aL69atp60diehbWuC1rGkf2rXwCFpfjtJTt4aqqw9fL5QKvY0C94SbLl5QJa0MmOCVwrMjuNmYyc1jdsUOhwRsw7Pq6lsgRx8i5eJEzlSViJmDrEhEa4zYqC0jdk3ZeQtgbig9PHGLm5qXwCpXczgE2bhqgiYPoaZ7sabc)9a5EwsdzASDchacYKCuQxxjkZhKFaitZ1JZguUKRocqBYGY9AfzMqDYiJjuNmTok1RRe9W6b5hGEkSuKmwV4rYjg9YwyFrgz6I8o8aWZKH4OtguUNjuNmcqm6L)eSKjhk2I7jwiZWZo4aY0PhqiocGTfCUxCa2rXwCpzASDchacYaRzU2LPeHtYjtZ1JZguUKRocqBYGY9AfzMqDYiJjuNmyxZCT7jTfHtY7PqAksgRx8i5eJEzlSViJmDrEhEa4zYqC0jdk3ZeQtgbiazmH6KzoLM9ipmKWXLh0dINvHGaeb]] )

    storeDefault( [[SimC Havoc: default]], 'actionLists', 20170525.095620, [[deuGpaqirKfPqQnrkmkKKtHKAvIe9ksr1Sui5wIOyxkAyiXXOuTmvWZePAAIeUMiQ2gsL(MiLXrkkCosrrRtKK5rkY9uv1(ivCqvOfQQupePQjskk5IQkzKIK6Kivmtru6MKQ2PcwQcXtvAQkuTvsL2lv)vLgmrhg1IvLhlyYeUmyZuIptjnAsPtd51kuMnu3wu7wQFlz4QkwUqpNIPJ46ukBxf9Dr48QQSEsrPMpsz)KSB3h33VA(HbH)8Ddr0hIV(QzbwyByI)TVJayGnGpCGI90OK8dhMhSBpfj)GV7hiGymsZMjOQ9HKNwA(EmqqvB8X9b7(4((vZpmi8V9Ddr0hIVjPKuPKjPKegdnz2qgmiZeA(HbHssJMsgQclQe9SHmyqMzeyXpLKgnLmufwuj6zdzWGmZiKzuBusDuschTcKjbLHlPUceOK0OPKHQWIkrpBidgKzgHmJAJsQJssxkkj1(E8HWiYpFp5iIFyWx60cuGjv03UAWx9LqxooWzW3emIGARxlv82qgmiJVdCg8DjveusDzSnW3JrRgFBod)tWicQTETuXBdzWGmJ6KX2G)jrvsegdnz2qgmiZeA(HbbnAHQWIkrpBidgKzgbw8JgTqvyrLONnKbdYmJqMrTrhchTcKjbLHlPUceqJwOkSOs0ZgYGbzMriZO2OdDPqTVJayGnGpCGI90StXx61cHX0xNqgAI)8vFjg4m4Rt8Hd(4((vZpmi8V9Ddr0hIVjPKuPKjPKegdnzg0YL5(WSamtO5hgekjnAkzOkSOs0ZGwUm3hMfGzgbw8tjPrtjdvHfvIEg0YL5(WSamZiKzuBusDuschTcKjbLHlPUceOK0OPKHQWIkrpdA5YCFywaMzeYmQnkPokjDPOKu77XhcJi)89KJi(HbFPtlqbMurF7QbF1xcD54aNbFtWicQTETuXBqlxM7dZcW47aNbFxsfbLuxgBdusQStTVhJwn(2Cg(NGreuB9API3GwUm3hMfGzuNm2g8pjQsIWyOjZGwUm3hMfGzcn)WGGgTqvyrLONbTCzUpmlaZmcS4hnAHQWIkrpdA5YCFywaMzeYmQn6q4OvGmjOmCj1vGaA0cvHfvIEg0YL5(WSamZiKzuB0HUuO23ramWgWhoqXEA2P4l9AHWy6RtidnXF(QVedCg81j(q6(4((vZpmi8V9Ddr0hIVjPKegdnzkGC1OWeA(HbHsQHsgQclQe9mdeoxXpAldYmJqMrTrj1KssxLudL0IT4VPaSGciIsQJsMofLudLKkLmjL8KJi(HHzcgrqT1RLkEBidgKrjPrtjdvHfvIE2qgmiZmczg1gLutkPDkkj1kPgkjvkzsk5jhr8ddZemIGARxlv8g0YL5(WSamkjnAkzOkSOs0ZGwUm3hMfGzgHmJAJsQjLKUkj1(E8HWiYpFp5iIFyWx60cuGjv03UAWx9LqxooWzW3pvHrT1RLkEZaH9DGZGVlPIGsQlJTbkjvhO23JrRgFBod))ufg1wVwQ4ndeEuNm2g8pjcJHMmfqUAuycn)WGqJqvyrLONzGW5k(rBzqMzeYmQnAIUAyXw83uawqberN0PObvjDYre)WWmbJiO261sfVnKbdYqJwOkSOs0ZgYGbzMriZO2Oj7uOwdQs6KJi(HHzcgrqT1RLkEdA5YCFywagA0cvHfvIEg0YL5(WSamZiKzuB0eDP23ramWgWhoqXEA2P4l9AHWy6RtidnXF(QVedCg81j(qk8X99RMFyq4F77gIOpeFjmgAY0ckAi3hUkXeA(HbHssJMsAaY9vTnZKGG4bk3dFckPokjfLKgnLKde0jCHgYiWOK68xjtxj1CLKkLKWyOjZGwUm3ag4tyIUqZpmiuYuQKPRKu77XhcJi)89KJi(HbFPtlqbMurF7QbF1xcD54aNbFFywaxb3bW3bod(UKkckPUm2gOKuLo1(EmA14BZz4)dZc4k4oaJ6KX2G)egdnzAbfnK7dxLycn)WGGgndqUVQTzMeeepq5E4tGgnoqqNWfAiJaJo)txZPIWyOjZGwUm3ag4tycn)WGiLPtTVJayGnGpCGI90StXx61cHX0xNqgAI)8vFjg4m4Rt8HK7J77xn)WGW)23nerFi(EYre)WW8HzbCfChaLudL0IT4VzWwmcnrjtgLmfuusnPKPNCLmzuscJHMmTGIgY9HRsmrxO5hgekzkvYduusnusQusoqqNWfAiJaJsQZFLmDLuZvsQuscJHMmdA5YCdyGpHj6cn)WGqjtPsMUssTssTVhFimI8Z3toI4hg8LoTafysf9TRg8vFj0LJdCg89tvyuB9API3hMfWvWDa8DGZGVlPIGsQlJTbkjvPGAFpgTA8T5m8)tvyuB9API3hMfWvWDag1jJTb)p5iIFyy(WSaUcUdGgwSf)LmPGIMsp5jdHXqtMwqrd5(WvjMqZpmis5bkAqfhiOt4cnKrGrN)PR5urym0KzqlxMBad8jmHMFyqKY0PMAFhbWaBaF4af7PzNIV0RfcJPVoHm0e)5R(smWzWxN4d01h33VA(HbH)TVBiI(q8LWyOjZGwUm3ag4tycn)WGqj1qjTyl(BkalOaIOK6OKPGIVhFimI8Z3toI4hg8LoTafysf9TRg8vFj0LJdCg89tvyuB9API3GwUmxdjIgd8DGZGVlPIGsQlJTbkjvjNAFpgTA8T5m8)tvyuB9API3GwUmxdjIgdg1jJTb)jmgAYmOLlZnGb(eMqZpmi0WIT4VPaSGciIoPGIgjfzK4cNqtMSqyM2(OrKrIlCcnzYcHzIAnDiLwdcFhbWaBaF4af7PzNIV0RfcJPVoHm0e)5R(smWzWxN4dP5J77xn)WGW)2x9LqxooWzWxFh4m4l9vBSLbLupBff8LETqym91jKHM4pFhbWaBaF4af7PzNIV0PfOatQOVD1GVhFimI8Z3q1gBz4MzROGV6lXaNbFDIpOz4J77xn)WGW)23nerFi(gQclQe90kUEm(gQclQe9mczg1gL8VssX3Jpegr(5BGX4lhiOQVyKH4lDAbkWKk6Bxn4R(sOlhh4m4RVdCg8LEgJvYJbcQALmzrgIVhJwn(2Cg(p6fLPxjtnFwHuPKHQWIkrpAFhbWaBaF4af7PzNIV0RfcJPVoHm0e)5R(smWzW3fLPxjtnFwHuPKHQWIkr7eFqZ0h33VA(HbH)TVBiI(q8LWyOjtbKRgfMqZpmiusnuscJHMmfqUAu4YF(aeebMqZpmiusnuscJHMmFyulUwSf)nHMFyq47XhcJi)8nARVCGGQ(IrgIV0PfOatQOVD1GV6lHUCCGZGV(oWzW3rS1k5XabvTsMSidX3JrRgFBod)h9IY0RKPMpRqQusbKRgfgTVJayGnGpCGI90StXx61cHX0xNqgAI)8vFjg4m47IY0RKPMpRqQusbKRgfCIpyNIpUVF18ddc)BFp(qye5NVrB9Ldeu1xmYq8LoTafysf9TRg8vFj0LJdCg813bod(oITwjpgiOQvYKfzikjv2P23JrRgFBod)h9IY0RKPMpRqQuYUIzgpAFhbWaBaF4af7PzNIV0RfcJPVoHm0e)5R(smWzW3fLPxjtnFwHuPKDfZm2joX3bod(UOm9kzQ5ZkKkLuawyByItCha]] )

    storeDefault( [[SimC Havoc: precombat]], 'actionLists', 20170525.095620, [[dqZbcaGEsO2ejXUuKxtImBIUjv13qv2Ps2Ry3QA)GmkQsggq(nLHIQQgmOgobhur1PiPCmcTqvKLQcTyvA5aEOkQNcTms1ZrLjcu1uPkMSctxQlQcUmY1jb2kjPnJQsBhOCAuESsnnsiFNe0iPk1HLmAsPBtLtsI6ZKIRPOCEsQoeqL)IQkRdvfhX4j4HVUsAKBqCdWe6GbbpX3sbYoNcEKKuXrzPdsKhOz66t6IIkAMEquG2SsYuC1m7ZAgpEbNVBM9CXtwIXtWdFDL0iNcIBaMqhSnnAK0KG1m75co)YKSw9GcwZSp4zT0wjFdmYrFNBqFBOAbSkhfm4QCuq(BnZ(GhjjvCuw6Ge5jckOY)GTR2ac(2tb9TXQCuW0zPhpbp81vsJCkiUbycDW20OrstBZKdtHpheSkqWEbbdoiyVGG7ssFpniN98dGUgWprFDL0acwfi4UK03tdYzpBprFDL0acwniy1co)YKSw9GoQlNbiO14yCbpRL2k5BGro67Cd6BdvlGv5OGbxLJc6tD5mabTghJl4rssfhLLoirEIGcQ8py7QnGGV9uqFBSkhfmD6GRYrbrM7meS3fy2MpqWca02C3QtNa]] )

    storeDefault( [[SimC Havoc: cooldown]], 'actionLists', 20170525.095620, [[dSZhhaGAkcwVsPytaLDHsVwjyFIkmBjnFaUjG(gq1orv7fA3KSFvnkr0WqHFlCAqdvPuAWQmCr5GeItjchtP6XOYcjuwkfvlMGLlXdjKEkvlJcEoPMOsPYujunzknDfxKI0HL6YixNcDEkkBvuLnJI2Us0Tj6que1NvsFxPyKkLQMNsOrdK)ksNuuvttujxtPK7jQupJIqRJIiBturJ7O4OBQQfQKffq35kWSbD03oIzBSoOyOBovPwtiVbg7GZyldgynSVNRTmGUNrCWUc3MEGHc53cCWrxeUbgknkoYVJIJUPQwOswum0DUcmBqFI11kXYfr1gBu6)a7VK)zY)L8VPRKAyTKmuqows1cvY(haa)TSlWwOsSzruHQ1uMrjvst)haa)TSlWwOsSBA4avRPmJsQIKKgQ)daG)w2fyluj2nnCGQ1uMrjLduh6uHABj9Fj(daG)MUSsd7aLu6ePwi93I)zyR)sGUicWkCmdDjnTmkzGcnuJUOGiUfagljjPguaDGHnVUW3scD05BjHoqAAzuYafAOgDZPk1Ac5nWyh8DgONVYc56jkORcfHoWWY3scDCqEdO4OBQQfQKffdDNRaZg0NyDTsSCruTXgL(pW(l5Ftxj1WAjzOGCSKQfQK9pW(tWitMSsAAzuYafAOM1y2FG9htJfZy5mwkKA(BX)YfJ)sGUicWkCmdDjnTmkzGcnuJUOGiUfagljjPguaDGHnVUW3scD05BjHoqAAzuYafAO(VK7jq3CQsTMqEdm2bFNb65RSqUEIc6QqrOdmS8TKqhhK3erXr3uvlujlkg6oxbMnOpX6ALy5IOAJnk9FG9xY)s(NLemYKjRIKKgQzTXg1FG9xY)AUbUKsjfjHK(VC83(Fj(lXFG9xY)6YknSdusPtKAH0Fj(lb6IiaRWXm0vKK0qn65RSqUEIc6QqrOdmS51f(wsOJoFlj05jjPHA0fPSQrF6YknPqM5wcvM00LvAyhOKsNi1cj0nNQuRjK3aJDW3zGUOGiUfagljjPguaDGHLVLe64G85cfhDtvTqLSOyO7Cfy2G(eRRvILlIQn2O0)b2Fj)l5FcgzYKLduh6uHABjnRXS)aa4pbJmzYkPPLrjduOHAwJz)baWFCruTXgfRKMwgLmqHgQzBRjyupKnTqYgQ0)T4Fgy8haa)nDzLg2bkP0jsTq6VfZ9F5KXFj(lb6IiaRWXm0vKK0qn6IcI4waySKKKAqb0bg286cFlj0rNVLe68KK0q9Fj3tGU5uLAnH8gySd(od0ZxzHC9ef0vHIqhyy5BjHooi)wO4OBQQfQKffdDNRaZg0NyDTsSCruTXgL(pW(l5FcgzYKvstlJsgOqd1SgZ(daG)4IOAJnkwjnTmkzGcnuZ2wtWOEiBAHKnuP)lh)Ltg)baWFtxwPHDGskDIulK(BXC)3UH)sGUicWkCmdDoqDOtfQTL0OlkiIBbGXsssQbfqhyyZRl8TKqhD(wsOlkOo0)jwTTKgDZPk1Ac5nWyh8DgONVYc56jkORcfHoWWY3scDCq(CIIJUPQwOswum0DUcmBqFI11kXMfdmu6)a7VK)jyKjtwjnTmkzGcnuZwizdv6)YXFg26paa(B6YknSdusPtKAH0Fl(NjY4VeOlIaSchZqplgyOqxuqe3caJLKKudkGoWWMxx4BjHo68TKqFBJbgk0nNQuRjK3aJDW3zGE(klKRNOGUkue6adlFlj0Xbh05BjHUdLI(323ldot6pUiQ2yJcheb]] )

    storeDefault( [[SimC Havoc: demonic]], 'actionLists', 20170525.095620, [[de0craqiQO2eOQprLemkqXPKsTkQKIxrLKAxOYWiKJjPwgvQNjHQPjHORHuvBJkP03qknojuCoQKqRJkjX8KqP7Huf7tcPdsqTqKkpKqzIsiCrcYgrQsFKkPAKujrDsQi3ee7ejlfu6PuMkOYwjuTxO)krdwvhwyXs1JrvtwKlRSzP4ZsWOLKttQxJumBsUnr7gXVrz4G0YPQNlQMoW1fLTtGVtLy8ujroVuY6PssA(uH9RYynchAcrIUAjSJMX71qbOHwrSMitbq6qd2PwKpKYTOAAfrF3U5CxxxK03nAg0XRdL2vnaAgbPOpT0IMW8anJKJWHu1iCOjej6QLq6qZ49AOa0G5EqOgbWb1pOHFjUrIUAP7D44EqOgbWjzYrazsUrIUAP7BFp833ZAA4G6h0WVexI5c5E4VVN10WjzYrazsUeZfcAc31knOfAcgPWAYuL(b8laOjw14PbctWKJaWoAqyjXdpvihAOrfYHM4JuynzQ7HDa)caAWo1I8HuUfvtBTi0CIK08bG5rJWidniSevihAiaPCJWHMqKORwcPdnJ3RHcqdM7bHAeaNKjhbKj5gj6QLU3HJ7bHAeaxZuLYihmFlUrIUAP7BFp83dZ9oFpiuJa4Km5iGmj3irxT09oCCpm3dZ98vHVWYVNEU399WFpnBqlBMQ0NLxv6hFv4lOjfUV99oCCppJPsmxiCcgPWAYuL(b8laC(jdnj)(IEFrEF77H)(EwtdNKjhbKj5smxi33(E4VhM7H5E(QWxy53tp37(E4VNMnOLntv6ZYRk9JVk8f0Kc33((2OjCxR0GwO1mvPplVcnXQgpnqycMCea2rdcljE4Pc5qdnQqo0O3PUh2S8k0GDQf5dPClQM2ArO5ejP5daZJgHrgAqyjQqo0qasvCeo0eIeD1siDOz8EnuaAGqncGRRySKAaUrIUAP7H)EyU357bHAeaNKjhbKj5gj6QLU3HJ77znnCsMCeqMKld69TVh(75RcFHLFp9CVB0eURvAql0avEMlLfuHwWqtSQXtdeMGjhbGD0GWsIhEQqo0qJkKdn4Q8mxU31vHwWqd2PwKpKYTOAARfHMtKKMpampAegzObHLOc5qdbivrIWHMqKORwcPdnJ3RHcqtq41rxnUUksRmfe(HMWDTsdAHwAbOQm3LnOOjw14PbctWKJaWoAqyjXdpvihAOrfYHwrSauDV5Ygu0GDQf5dPClQM2ArO5ejP5daZJgHrgAqyjQqo0qasrFeo0eIeD1siDObHLep8uHCOHgvihA07u3lKpdkqZiOjw14PbctWKJaWoAWo1I8HuUfvtBTi0CIK08bG5rJWidnH7ALg0cTMPkNpdkqZiObHLOc5qdbiLRfHdnHirxTeshAgVxdfGgm3h8aTGvoYK6LFFrVV((237WX9WCpm3789GqncGtYKJaYKCJeD1s37WX99SMgojtocitYLb9(233gnH7ALg0cTMmFRswtjOALALsNcVgnXQgpnqycMCea2rdcljE4Pc5qdnQqo0O3mFR7zn3dQ29oPu6u41Ob7ulYhs5wunT1IqZjssZhaMhncJm0GWsuHCOHaKIweo0eIeD1siDOz8EnuaAccVo6QX1vrALPGWV7H)EEgtLyUq4wRv2xi58tgAs(9f9E6Fp837898mMkXCHWjhiKmp0kwUoNZVi1cnH7ALg0cTUksRmfe(HMyvJNgimbtoca7ObHLep8uHCOHgvihA0PI0UVicc)qd2PwKpKYTOAARfHMtKKMpampAegzObHLOc5qdbivXGWHMqKORwcPdnJ3RHcqdeQraCDfJLudWns0vlDp83h8aTGvoYK6LFFrPN7DFp83dZ9oFpiuJa4Kroy(swtjOALfuHwW4gj6QLU3HJ7D(EqOgbWjzYrazsUrIUAP7D44(EwtdNKjhbKj5YGEF77H)EyUp4bAbRCKj1l)(Isp3x87BJMWDTsdAHgOYZCPSGk0cgAIvnEAGWem5iaSJgews8WtfYHgAuHCObxLN5Y9UUk0c29Wu3gnyNAr(qk3IQPTweAorsA(aW8OryKHgewIkKdneGuUIiCOjej6QLq6qZ49AOa0cEGwWkhzs9YVVO3xFVdh37899SMgU0KmIMVCUsGrslvkhiKmp0kwUoNldkAc31knOfAR1k7lKOjw14PbctWKJaWoAqyjXdpvihAOrfYHMqT290TqIgStTiFiLBr10wlcnNijnFayE0imYqdclrfYHgcqQAriCOjej6QLq6qZ49AOa0G5ENVheQraCsMCeqMKBKORw6EhoUVN10WjzYrazsUmO37WX9nz(wCP1O51G7l27lUO7D133ZAA4G6h0WVexg07Dn3xm37WX99SMgo5aHK5HwXY15C(jdnj)(I9E6FF77H)ENVxq41rxnoOmMstku2W8LDvKwzki8dnH7ALg0cTGq0vAva0mcAIvnEAGWem5iaSJgews8WtfYHgAuHCOjmHOR0QaOze0GDQf5dPClQM2ArO5ejP5daZJgHrgAqyjQqo0qasvxJWHMqKORwcPdnJ3RHcqdeQraCDfJLudWns0vlDp83dZ9oFpiuJa4Kroy(swtjOALfuHwW4gj6QLU3HJ7D(EqOgbWjzYrazsUrIUAP7D44(EwtdNKjhbKj5YGEFB0eURvAql0avEMlLfuHwWqtSQXtdeMGjhbGD0GWsIhEQqo0qJkKdn4Q8mxU31vHwWUhg3Trd2PwKpKYTOAARfHMtKKMpampAegzObHLOc5qdbivTBeo0eIeD1siDOz8EnuaAWCVZ3dc1iaojtocitYns0vlDVdh33ZAA4Km5iGmjxg07D44(MmFlU0A08AW9f79fx09U677znnCq9dA4xIld69UM7lM7BFp83789ccVo6QXbLXuAsHYgMVKVky5L5aVMMDp83789ccVo6QXbLXuAsHYgMVuoqCp83789ccVo6QXbLXuAsHYgMVSRI0ktbHFOjCxR0GwOXxfS8YCGxtZqtSQXtdeMGjhbGD0GWsIhEQqo0qJkKdnXQcw(9gWRPzOb7ulYhs5wunT1IqZjssZhaMhncJm0GWsuHCOHaKQU4iCOjej6QLq6qZ49AOa0C(EqOgbWjzYrazsUrIUAP7H)(EwtdNCGqY8qRy56CUeZfY9WFpm3dZ98vHVWYVNEU399WFpnBqlBMQ0NLxv6hFv4lOjfUV99Trt4UwPbTqRzQsFwEfAIvnEAGWem5iaSJgews8WtfYHgAuHCOrVtDpSz5v3dtDB0GDQf5dPClQM2ArO5ejP5daZJgHrgAqyjQqo0qasvxKiCOjej6QLq6qdcljE4Pc5qdnQqo0kIjzexH87PtdgAIvnEAGWem5iaSJgStTiFiLBr10wlcnNijnFayE0imYqt4UwPbTqlnjJKx21GHgewIkKdneGu10hHdnHirxTeshAgVxdfGgi8fgGttk9bPWqt4UwPbTqdu5zUuwqfAbdnXQgpnqycMCea2rdcljE4Pc5qdnQqo0GRYZC5ExxfAb7EykEB0GDQf5dPClQM2ArO5ejP5daZJgHrgAqyjQqo0qasv7Ar4qtis0vlH0HMX71qbObcFHb4s6Cqq439f9(A6FVdh3dZ9GWxyaonP0hKc7E4V357bHAeaNKjhbKj5gj6QLUVnAc31knOfAntv6ZYRqtSQXtdeMGjhbGD0GWsIhEQqo0qJkKdn6DQ7HnlV6EyC3gnyNAr(qk3IQPTweAorsA(aW8OryKHgewIkKdneGu10IWHMqKORwcPdnJ3RHcqde(cdWL05GGWV7l6910hnH7ALg0cnbJuynzQs)a(fa0eRA80aHjyYrayhniSK4HNkKdn0Oc5qt8rkSMm19WoGFb4EyQBJgStTiFiLBr10wlcnNijnFayE0imYqdclrfYHgcqaAuHCOzAPy37khcy8Uk3NMKr08iara]] )



    storeDefault( [[Havoc Primary]], 'displays', 20170525.095620, [[dWZ3gaGEPQEjQs2LcL61srMPuLMTIoSKBIuPJJQ4Bsv8meQANuzVIDt0(jOFQedtjnofk55umuuAWey4i6GsLttYXOKZHqLfkLwkHYIjLLtvpuk8uWJHQ1HqPjIQutfktgv10v1fvWvrQ4YqUos2iHSvekSzuz7kvFukQpJGPPq13PuJePQLPqgnkgpc5KiLBPqX1iuDEs1VvzTiu0TvkhRGfaViF1jfDYhE9jkWcDW6LMBiWxEcONDNnAb8LKaQbdcVP0gqBQ63V55zhTa6lCCg03OiF1jnXTgGOfood6BuKV6KM4wdWdfIcXNg(jbvFuCJVgytj7gIJ4dWdfIcXVrr(QtAsBa9food6Xkpb0BIBnGH5SbB1JZ0nK2agMZUJ6V0gyRicWIZkWxEcOVtIZC(aTlyyl0vmAntpwaIw44mONxTM4ScOVWXzqpVAnXngRagMZgR8eqVjTbAsRtIZC(aylSIrRz6XcOK8v41F(ojoZ5digTMPhlaEr(Qt2jXzoFG2fmSf6gOXrQlua2fG(A)WfkOBziGH5SbS0gGhkefI3kpc)vNmGy0AMESasQnA4N0e34bmKO5u0SmmnU55dwGkoRa(4ScqioRaAXzLpGH5SBuKV6KMOfGOfood67O8vCRbkkFHPtIcOrXXfyRiQJ6V4wdOnv97388S7MZOfOMKmfWC2S7dXzfOMKmvJBtRE29H4ScWBexrn)0gOM2LUHDNnTb2vgLMAQEDmDsuaTa4f5Roz3urqgOXGdBqSa8vgYzPJPtIcub8LKactNefO0ut1RhOO8fDvsuAd0KMOt(GQpkoRrbQjjtHvEcONDNnoRaE0mqJbh2GybmKO5u0SmmrlqnjzkSYta9S7dXzfGhkefIpnjFfE9N3K2aajcxvtv)6vNmoX7PNaUAdfG(A)WfkG1R2kVEGV8eqVOt(WRprbwOdwV0Cdb4J4kQ53X2BaqT1qOa6R9dNyfkGpIROMFGM0eDYhE9jkWcDW6LMBiGEenMXI46z0QL4JBrCIpI4x7znCJzCXdutsMQBAx6g2D24ScutsMcyoB2D24Scq6vBLxx0jFq1hfN1OaKEe(TPvFhBVba1wdHcOV2pCIvOaspc)20QpGH5SbB1JZ0r9xAdSve1ne3AaIIBnWxEcONDFiAbednrLbf3OvREwfF0OXEK1ApwbmmNn7oBAdyyoBEH01us(kjbtAdGFBA1ZUpeTa4f5RoPOt(GQpkoRrbQjjt1nTlDd7(qCwbAst0j)aSycfaL0iuGR8(ZoGH5SPj5RWR)8M0gqFHJZG(okFf3AGAAx6g29H0gWWC2DdPnGH5Sz3hsBa8BtRE2D2OfOMKmvJBtRE2D24Scuu(QtIZC(aTlyyl0T3bryb4HsH3eXqzGxFIcub2usalU1aF5jGErN8bvFuCwJcuu(IMK7W0jrb0O44cGxKV6KIo5hGftOaOKgHcCL3F2bkkFbKO5KgVJBnWGS0Mi(PnGrTrorDldXnkGH5S7O8fnj3fTaeTWXzqpw5jGEtCRb(Yta9Io5hGftOaOKgHcCL3F2b0x44mONMKVcV(ZBIBnarlCCg0ttYxHx)5nXTgGhkefQBQii3qYpaEasVAR860WpjO6JIB81ak8tcKfUssioXdOWpjX8UT4SepapuikeFrN8bvFuCwJcWDYpalMqbqjncf4kV)SdWdfIcXNxTM0gytj7O(lU1afLVOJu9biNLoYNpb]] )

    storeDefault( [[Havoc AOE]], 'displays', 20170525.095620, [[dOtYgaGEPuVef0UuuLETusZurLzRWnrHCBL4Ws2jf7vSBI2pQQFkvnmLYVv16qKyOOYGrvgochukEMIQQJrfhhfzHkYsPuSyKA5u1dPu9uWJHQNtQjsPutfktMqMUkxuQCvuGld56izJeQTQOQSzc2Us6JsjwMIY0OuY3PsJef1Pjz0O04reNerDlejDnuOopL8zLQ1QOk(gIuhNGfaVio1lf)YdoRbkqpdWMJSPlWv(D0XTYf6a(sUJSZIWBntbyIcrHAgQD5csEbWdy1liOrN9I4uVuhZwas6fe0OZErCQxQJzlaHxTuElY4VeuTrXyRTalkztxmZFaMOquir2lIt9sDMcy1liOrhw53rNoMTaA23fCvhoBtxOdOzF3gQ7dDGLIealgNax53rxJeN99bM6XW6zKnKBHzSawXqQZC2ci8YlahgFEqj185zkV)DdOzFxSYVJoDMc0kDJeN99bW65SHClmJfqjfPWR79nsC23hWgYTWmwa8I4uVSrIZ((at9yy9mkG9NWIppSpaZ16JZNxtFxan77cyzkatuikKTvEe(PEzaBi3cZybKulKXFPogBfqtGgdXJsZA)hVpybQyCcqhJtG9yCc4JXjxan77AVio1l1Hoaj9ccA01q5Ry2cuu(cZIafGMsqiWsrsd19XSfGEOA3ULX72mgHoqniylG9D5w7IXjqniyl7)cDDCRDX4eW2iHIACzkqnClln3kxMcSQ0kA1qDwyweOa0bWlIt9YMHAxgWENbRZMaIuAIrzHzrGcGhWxYDeMfbkqrRgQZkqr5lgPKOmfOvAXV8avBumoZcudc2cR87OJBLlgNaE0iG9odwNnb0eOXq8O0SHoqniylSYVJoU1UyCcWefIcjISuKcVU3RZuaGaHRQHQDDQxgdJjnPdSOKnu3hZwGR87Ot8lp4SgOa9maBoYMUaIqcf14A4MlaOwSZNhZ16Jtk85jcjuuJlGvVGGgDmCshdP6eGKEbbn6y4KogNa1GGTAgULLMBLlgNak8xop)VeJdJdq4vlL3s8lpq1gfJZSaeEe(Vqxxd3Cba1ID(8yUwFCsHppcpc)xORlGc)LarHRK7XW4alfjnDXSfGjkefsez8xcQ2OyS1wGR87OJBTl0bOhQ2TBz8UHoGnObQ0OyMT5q6ngpB28oZzJ0obiPxqqJoYsrk86EVoMTaw9ccA0rwksHx371XSf4k)o6e)YlahgFEqj185zkV)DdqsVGGgDyLFhD6y2cOzF3gkFrwk8HoGM9DjlfPWR796mfWQxqqJUgkFfZwGA4wwAU1UmfqZ(UCRDzkGM9DB6cDa8FHUoUvUqhOO8fqGgdY2oMTafLVAK4SVpWupgwpJMRtmwGIYxKLcpMfbkanLGqGfLeWIzlWv(D0j(LhOAJIXzwaMOu4ToFknCwdua6a4fXPEP4xEb4W4ZdkPMppt59VBGAqWw2)f664w5IXjqNSOhirzkGwTqmqn9DXmlqR0IF5fGdJppOKA(8mL3)UbQbbB1mClln3AxmobWlIt9sXV8avBumoZcG)l01XT2f6aA23LHilALuKsURZuan77YTYLPaKeZwan77cUQdNTH6(mfOgeSfW(UCRCX4eGjkefsK4xEGQnkgNzbALw8lp4SgOa9maBoYMUamrHOqIy4Kotbm1ckaZ16JZNxtFxGIYxmqQUaeJYc5ZLa]] )

--    storeDefault( [[Vengeance Primary]], 'displays', 20170423.214519, [[dStJgaGEQsVeQs7sbkBdkcZKQOzlv3eQIdl52kQxtvyNuSxXUr1(Hc)uHgMI8BiptbQgkkgSQudhrhuk(SQ4yuYXrPSqQQLIs1IjYYPYdvqpf8yK8CsnrfitvvnzcmDLUOu6Qqv5YQCDe2ibTvOOAZeA7qPpQaonjtdQQ(oLAKOewgkPrJuJxvYjHk3ckkxdLOZtuJdksTwOi5Bqr0Xk)auf5QqCHi(cRC)cmIVVN4mTb2Y9CldwMifWv8NBi9r5r8dWgXrCnD1dF(4BaQaYJII6BhwKRcX1Xmf41OOO(2Hf5QqCDmtbiDQ5YjJJcXbL3lg8pfywXBAJzWdWgXrCcgwKRcX1XpG8OOO(2F5EUvhZuannYgSvlfDtB8dOPr2nelk(bMRxWpgRaB5EUTHtrJCb8h))r8WoUbyXpGCmygRSete4vmtb00i7F5EUvh)aEi1WPOrUa)rg2Xnal(buCbkQArUgofnYfGDCdWIFaQICviEdNIg5c4p()J4jaqEuQQR8wRcXJHLyARaAAKn8JFa2ioIBqk3rTkepa74gGf)aCIzCuiUog8hqtE9UWEPPhI6ix(bQyScifJvGNySc4IXkBannYEyrUkexhPaVgff132q4QyMcueU6ltEbKiefdmxVAiwumtbK6kVEhOJSB69ifO6K0fqJSzW2gJvGQtsxdrZs1YGTngRad6elI(gPav3UK1myzIFaSkTss1vR8xM8cifGQixfI30vp8adBn)w2diqPj7L8xM8ciiGR4p3xM8cusQUALdueUcpk(f)aEijeXxq59IXI1avNKU(L75wgSmXyfWD9adBn)w2dOjVExyV00rkq1jPRF5EULbBBmwbyJ4iob44cuu1IC64hWuZxam)4pxXPomEZ4uZLtoWwUNBfI4lSY9lWi((EIZ0gywXBiwumtb8qsiIVWk3VaJ477jotBa2ioItaokehuEVyW)uGQtsxnD7swZGLjgRaVgff13IxFDmwbiDQ5YjleXxq59IXI1aKUJcnlvBdJNXmfqrH4ykeAoglwgyUE10gZuareFdW8X4nuCngVnLZHSdSL75wgSTrkGIcXbYIsXFIHLby)6xPVaSozHjNWV10GzfqQR86DGoYosbEnkkQVfhxGIQwKthZua5rrr9T44cuu1IC6yMcSL75wHi(gG5JXBO4AmEBkNdzh41OOO(2F5EUvhZuannYghxGIQwKth)aAAKDdHRWXfrrkq1Tlznd224hqtJSzW2g)aAAKDtB8dqHMLQLbltKcueUQHtrJCb8h))r84zRWFGIWva5174gumtbyJqr5bMR0Wk3VavGzfh(Xmfyl3ZTcr8fuEVySynqr4kCCr0xM8cirikgGQixfIleX3amFmEdfxJXBt5Ci7avNKUgIMLQLbltmwbA5Lu)ee)aA1mz)AgBJH1aYJII6BBiCvmtb8qsiIVby(y8gkUgJ3MY5q2bQojD10Tlznd22yScqvKRcXfI4lO8EXyXAak0SuTmyBJuannYgVNSKIlqXF0XpGMgzZGLj(b00iBWwTu0nelk(bQojDb0iBgSmXyfGnIJ4eieXxq59IXI1aYJII6BXRVogmZkaBehXjaV(64hqWjwe9THXZyMcueUcFC1gGSxYNlBca]] )


end

