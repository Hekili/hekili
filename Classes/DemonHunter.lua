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
        addAura( 'blur', 198589, 'duration', 10 )
        addAura( 'chaos_nova', 179067, 'duration', 5 )
        addAura( 'chaos_blades', 211048, 'duration', 12 )
        addAura( 'darkness', 209426, 'duration', 8 )
        addAura( 'death_sweep', 210152, 'duration', 1 )
        addAura( 'fel_barrage', 211053, 'duration', 1 )
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


        -- Pick an instant cast ability for checking the GCD.
        addHook( 'spend', function( amt, resource )
            if state.equipped.delusions_of_grandeur and resource == 'fury' then
                state.setCooldown( 'metamorphosis', max( 0, state.cooldown.metamorphosis.remains - ( 30 / amt ) ) )
            end
        end )

        -- Gear Sets       
        addGearSet( 'tier19', 138375, 138376, 138377, 138378, 138379, 138380 )
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


        addHook( 'specializationChanged', function ()
            setPotion( 'prolonged_power' )
            setRole( 'attack' )
        end )

        addHook( 'advance', function( t )
            if state.spec.havoc then

                if state.buff.prepared.up then
                    state.gain( floor( state.buff.prepared.remains / 0.125 ), 'fury' )
                end

                return t
            end

            if state.buff.metamorphosis.up then
                local ticks_remain = ceil( state.buff.metamorphosis.remains )
                local ticks_after = floor( ticks_remain - t )
                local ticks = ticks_remain - ticks_after

                state.gain( 7 * ticks, 'pain' )
            end

            if state.buff.immolation_aura.up then
                local ticks_remain = ceil( state.buff.immolation_aura.remains )
                local ticks_after = floor( ticks_remain - t )
                local ticks = ticks_remain - ticks_after

                state.gain( floor( 3.334 * ticks ), 'pain' )
            end

            return t

        end )

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
        end )


        addAbility( 'fury_of_the_illidari', {
            id = 201467,
            spend = 0,
            spend_type = 'fury',
            cast = 0,
            gcdType = 'melee',
            cooldown = 60,
            known = function() return equipped.twinblades_of_the_deceiver and ( toggle.artifact_ability or ( toggle.cooldowns and settings.artifact_cooldown ) ) end,
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
            cast = 1,
            channeled = true,
            charges = 5,
            recharge = 30,
            gcdType = 'spell',
            cooldown = 30,
            known = function () return talent.fel_barrage.enabled end
        } )

        addHandler( 'fel_barrage', function ()
            applyBuff( 'fel_barrage', 1 )
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
            target.distance = abs( target.distance - 15 )
        end )


        addAbility( 'vengeful_retreat', {
            id = 198793,
            spend = 0,
            spend_type = 'fury',
            cast = 0,
            gcdType = 'spell',
            cooldown = 25,
            -- usable = function () return target.within5 end
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
            applyBuff( 'chaos_blades', 12 )
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
        } )


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

        addHandler( 'demon_spikes', function ()
            applyBuff( 'demon_spikes', 6 )
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
            spend = 20,
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
            spend = 0,
            spend_type = 'pain',
            cast = 0,
            cooldown = 15,
            gcdType = 'spell',
        } )

        addHandler( 'immolation_aura', function ()
            applyBuff( 'immolation_aura', 6 )
        end )


        addAbility( 'infernal_strike', {
            id = 189110,
            spend = 0,
            spend_type = 'pain',
            cast = 0,
            cooldown = 20,
            charges = 2,
            recharge = 20,
            gcdType = 'spell',
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


        addAbility( 'soul_barrier', {
            id = 227225,
            spend = 10,
            spend_type = 'pain',
            cast = 0,
            cooldown = 30,
            gcdType = 'spell'
        } )

        addHandler( 'soul_barrier', function ()
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
            applyDebuff( 'target', 'frailty', 20 )
        end )

    end


    storeDefault( [[Kib: Simple]], 'actionLists', 20170522.210710, [[d0t8kaGEii1lPek7csBJkAFIeDBIA2snFkbFccIonOVrehcIIDIWEv2nW(ruJccmmrmoiO68iYZiObJugou6GuHtjs6ys6CqqzHivlLsAXsSCQ6Hucvpf1YqsRdccteIktLatwutx4IePdt6YQUoezJquARqqYMPu2oLQpsjQPrjYNHqFhj8Cc9yOA0qXFPsNuK61uc5AIeUhevzLquvBcj63u8QtWycv(JTyWccbzAmugB)Xm2Jd1gIqRb0agrkKizS13xf)iOMuLKyjQcrPwTukQiSXmUhIngp2bEanaXjye1jySuGw6Nh9XeQ8hJSVjtZksIygB99vXpcQjvNvjOjcRJtdYqCnm(Xad4JDuGnmin22BxpsIygZ4Ei2ymog1J4frEuPu8rabikIAr)yDT921JKigx)XXOEeHaexmcQtWyPaT0pp6JzCpeBmo0(GaT0gtUFGEGw6NTGfcTpiqLnYheijJEGw6NhB99vXpcQjvNvjOjcRJtdYqCnm(Xad4Jju5pgH6aeVnKAY0S(WFng7OaByqAS9dq82qQD9p8xJfJq4emwkql9ZJ(yg3dXgJdTpiqT92TOEVI4rpql9ZuIJr9iErKxkgB99vXpcQjvNvjOjcRJtdYqCnm(Xad4Jju5pgzFtMgD17ve)yhfyddsJT92TOEVI4xmclnbJLc0s)8OpMX9qSX4q7dc0sBm5(b6bAPFMYq7dcuzvmU31yZnWCxeBfA)OhOL(5XwFFv8JGAs1zvcAIW640GmexdJFmWa(ycv(JfGXBOGmnl3k0(h7OaByqACGXBOWfXwH2)IrKIjySuGw6Nh9XmUhInghAFqGA7T79iHnGga6bAPFES13xf)iOMuDwLGMiSoonidX1W4hdmGpMqL)yK9nzAs9iHnGgWyhfyddsJT929EKWgqdyXiCobJLc0s)8OpMX9qSX4XwFFv8JGAs1zvcAIW640GmexdJFmWa(ycv(JrwK8KitZyJmTaZjtlD3WS6HJDuGnmin2gsEsUgBUbM7c7gMvpCXiKmbJLc0s)8OpMX9qSX4q7dc08Lnaio6bAPFES13xf)iOMuDwLGMiSoonidX1W4hdmGpMqL)yPKozA0Vkp2rb2WG04t6ULRYlgbcFcglfOL(5rFmJ7HyJXH2heO2GEXWT0gtg9aT0pBblGafpG2V7bxgEXukKYq7dcuCmQr0fVVA)OhOL(5uhB99vXpcQjvNvjOjcRJtdYqCnm(Xad4Jju5pMER5tMgYPa8p2rb2WG04sR57Mva(xmce2emwkql9ZJ(yg3dXgJdTpiqTb9IHBPnMm6bAPF2cwabkEaTF3dUm8IPuiLH2heO4yuJOlEF1(rpql9ZPo267RIFeutQoRsqtewhNgKH4Ay8JbgWhtOYFmYDnWqMgtXp2XokWggKgNVgyCfP4h7IrutMGXsbAPFE0hZ4Ei2yCO9bbAPnMC)a9aT0ptPIhq739GldVykRJT((Q4hb1KQZQe0eH1XPbziUgg)yGb8XeQ8hlaJ3qbzAwUvO9tMgcQPo2rb2WG04aJ3qHlITcT)fJOwNGXsbAPFE0hZ4Ei2yCO9bbAPHGSRnK8Kqpql9ZJT((Q4hb1KQZQe0eH1XPbziUgg)yGb8XeQ8hlL0jtJ(vzY0qqn1XokWggKgFs3TCvEXiQuNGXsbAPFE0hZ4Ei2y8yRVVk(rqnP6SkbnryDCAqgIRHXpgyaFmHk)XoaaigyRb0ag7OaByqAScaqmWwdObSyevHtWyPaT0pp6JzCpeBmo0(GaT0gtUFGEGw6NhB99vXpcQjvNvjOjcRJtdYqCnm(Xad4Jju5pwagVHcY0SCRq7Nmneqn1XokWggKghy8gkCrSvO9VyevlnbJLc0s)8OpMX9qSX4cs2SHk)qLnESymIqr0SHcaLkEaTF3dUm8IPSsjcqMq7dc0sdbzxBi5jHEGw6NPezcTpiqXXOgrx8(Q9JEGw6NPezcTpiqZx2aG4OhOL(5uhB99vXpcQjvNvjOjcRJtdYqCnm(Xad4Jju5pwkPtMg9RYKPHaQPo2rb2WG04t6ULRYlgrnftWyPaT0pp6JzCpeBmUGKnBOYpuzJhlgJiuenBOaqPIhq739GldVykRKr(JT((Q4hb1KQZQe0eH1XPbziUgg)yGb8XeQ8hlaJ3qbzAwUvO9tMgceM6yhfyddsJdmEdfUi2k0(xmIQZjySuGw6Nh9XmUhIngp267RIFeutQoRsqtewhNgKH4Ay8JbgWhtOYFSfhJAejtJdp0I(yhfyddsJXXOgrxXWdTOVyevjtWyPaT0pp6JzCpeBmES13xf)iOMuDwLGMiSoonidX1W4hdmGpMqL)yK7YgacPizA0HXh7OaByqAC(YgGOBbgFXiQi8jySuGw6Nh9XmUhInghAFqGMVSb4wAnFr0d0s)mLitO9bbAPnMC)a9aT0pp267RIFeutQoRsqtewhNgKH4Ay8JbgWhtOYFSamEdfKPz5wH2pzAiWsPo2rb2WG04aJ3qHlITcT)flgJC3MIuhJ(Ina]] )

    storeDefault( [[Kib: Complex]], 'actionLists', 20170522.210710, [[daeEqaqiruBcj1NusjnkuKtHK8ksIODrLHjQogildjEgPyAkPY1usX2us(gP04usjohjbwhjrY8ijk3JKu7te5GsvTqsQhssstKKexuQyJkPQpssOtQu5LKeu3KKOANKyPsvEkXufHTssKAVq)vPmyrYHPSyP8yqnzjUSQnlkFwQ0OrHtJ41kPuZg42u1Uv8BunCLy5s65i10fUoPA7kv9DuuJNKGCEuY6jjcZhLA)IuJqycuum)rrfM0uPsNsv5(fWvHqrwomXaevcli8bvwJwTO07GB0hvOKdPnFDu04OaTU1aPcqrGRKLafu6dhe(qJjqfimbkDgRbEbvJIaxjlbkO0VraKGfkW8Hw3)nV1LaJYUPqGTGxrz4ZrrX8hfvLp06(NoLk36sGrP3b3OpQqjhAfKwxUgimqfkycu6mwd8cQgfbUswcucE3UG7G5CqHZ8qJsVdUrFuHso0kiTUCnqOSBkeyl4vug(Cu63iasWcf)dZZRlm40eAuum)rrL)W886cdonHgdurdMaLoJ1aVGQrrX8hfvLHXPtNsnWkNgLEhCJ(OcLCOvqAD5AGqz3uiWwWROm85OiWvYsGsW72fChmNdkCMhAQzQPNL58pmpVUWGttOD17nYqNKQHOWMnmNdkCMhN)H551fgCAcTREVrg6Km4GWhhmdJtV1aw50oyohu4mpQKquOcL(ncGeSqbMHXP3AaRCAmqL1HjqPZynWlOAue4kzjqj4D7cUdMZbfoZdnk9BeajyHYC)Pj0OSBkeyl4vug(Cu6DWn6JkuYHwbP1LRbcffZFuuU)0eAmqL1GjqPZynWlOAuum)rz9hKovpDAgO07GB0hvOKdTcsRlxdek7Mcb2cEfLHphfbUswcuOFeKPlTBT)x2YoyRQtZyREygwTlz6sntWmSA3tVLvn4GWhdKKQHCAxd1mLCyGpHl7GnVrhVYY9XAGxyZotVYYvEgbMejPAn5urfk9BeajyHs2bBvDAgyGkRWeO0zSg4funkcCLSeOeg4t4wQFXQV4(ynWlSzZuyGpHZZ9FcDV7J1aVqDYn9SmNN7)e6EN(cvO07GB0hvOKdTcsRlxdek7Mcb2cEfLHphL(ncGeSqz)NUpthSvFuVfOOy(JIk9NUpthKovVh1BbgOIwmbkDgRbEbvJIaxjlbkmLCyGpHZZ9FcDV7J1aVWMDtplZ55(pHU3PVqf1WmSA3tR61GsVdUrFuHso0kiTUCnqOSBkeyl4vug(Cu63iasWcLSd2AwTADpkkM)OS(dsNsTvRw3JbQSwWeO0zSg4funkcCLSeOaZWQDpDsQgYPDnuZuyGpHRb48c4H7J1aVqDyGpHZB0XRB8STGX36cmY(7(ynWlurntjhg4t48C)Nq37(ynWlSz30ZYCEU)tO7D6luHsVdUrFuHso0kiTUCnqOSBkeyl4vug(Cu63iasWcLGrLZ8wxGr2Fuum)rjbJkN50PurGr2FmqfvaMaLoJ1aVGQrrGRKLaLWaFcx2bBVQVee(4(ynWlO07GB0hvOKdTcsRlxdek7Mcb2cEfLHphL(ncGeSqj7GTx1xccFqrX8hL1Fq6uDQ6lbHpyGkq5ycu6mwd8cQgfbUswcuyk5WaFcNN7)e6E3hRbEHn7MEwMZZ9FcDVtFHku6DWn6JkuYHwbP1LRbcLDtHaBbVIYWNJs)gbqcwOKPxzTXZ2cgFJaaKIvjOOy(JY61RSsNINLovW4PtTdaifRsWavGGWeO0zSg4funkcCLSeOeg4t4k3ZhcS7J1aVWMTbhK9F7Z9KtNefu6DWn6JkuYHwbP1LRbcLDtHaBbVIYWNJs)gbqcwOCwFRDZJII5pkDy90PuFZJbQarbtGsNXAGxq1OiWvYsGsyGpHlJuPJTgGZlUpwd8cB2gCq2)Tp3toDsuyZMjdoi7)2N7jNojnuhg4t4GzyC6nyWT939XAGxOcLEhCJ(OcLCOvqAD5AGqz3uiWwWROm85O0VraKGfknGv(wXg4JII5pkQbw5PtPk2aFmqfinycu6mwd8cQgfbUswcucd8jCzKkDS1aCEX9XAGxyZ2GdY(V95EYPtIcB2mzWbz)3(Cp50jPH6WaFchmdJtVbdUT)Upwd8cvO07GB0hvOKdTcsRlxdek7Mcb2cEfLHphL(ncGeSqPClySrZ8)ckkM)OOk3cgPtjm)VGbQaTombkDgRbEbvJIaxjlbkHb(eUgGZlGhUpwd8c1gCq2)Tp3toDsquZuYHb(eop3)j09Upwd8cB2n9SmNN7)e6EN(cvO07GB0hvOKdTcsRlxdek7Mcb2cEfLHphL(ncGeSqjyu5mV1fyK9hffZFusWOYzoDkveyK9pDkMGOcdubAnycu6mwd8cQgfbUswcuY0RSCLNrGjrsQwtok9o4g9rfk5qRG06Y1aHYUPqGTGxrz4ZrPFJaibluYoObSYrrX8hL1FqdyLJbQaTctGsNXAGxq1OiWvYsGsyGpHRbitzltVYY9XAGxqP3b3OpQqjhAfKwxUgiu2nfcSf8kkdFok9BeajyHYz9T2npkkM)O0H1tNs9nF6umbrfgOcKwmbkDgRbEbvJIaxjlbkn9SmN)H551fgCAcTtFHAMsomWNW55(pHU39XAGxyZUPNL58C)Nq370xyZotVYYvEgbMeQmk5uHsVdUrFuHso0kiTUCnqOSBkeyl4vug(Cu63iasWcfBgcdcWccFqrX8hL(Zqyqawq4dgOc0AbtGsNXAGxq1OiWvYsGsyGpHRb48c4H7J1aVqntjhg4t48C)Nq37(ynWlSz30ZYCEU)tO7D6luHsVdUrFuHso0kiTUCnqOSBkeyl4vug(Cu63iasWcLGrLZ8wxGr2Fuum)rjbJkN50PurGr2)0PyIcvyGkqQambkDgRbEbvJIaxjlbkn9SmN)H551fgCAcTRWzEOMPKdd8jCnazkBz6vwUpwd8c1jhg4t4GzyC6nyWT939XAGxOo5WaFcx5E(qGDFSg4fQO2GdY(V95EYPtcIARgKmdoC20vNqZyJNTfm(w5WNS)v3hRbEbLEhCJ(OcLCOvqAD5AGqz3uiWwWROm85O0VraKGfkN13A38OOy(JshwpDk138PtXefQWavOKJjqPZynWlOAue4kzjqPPNL58pmpVUWGttODfoZd1gCq2)Tp3toDsqO07GB0hvOKdTcsRlxdek7Mcb2cEfLHphL(ncGeSqjyu5mV1fyK9hffZFusWOYzoDkveyK9pDkM0qfgOcfimbkDgRbEbvJIaxjlbkm10ZYCEU)tO7D6lSzNCyGpHZZ9FcDV7J1aVqfB2z6vwUYZiWKqLrjhLEhCJ(OcLCOvqAD5AGqz3uiWwWROm85O0VraKGfkWmmo9gDujR9rrX8hfvLHXPtNsIkzTpgOcfkycu6mwd8cQgfbUswcuGzy1UNojvVoQzk5WaFcNN7)e6E3hRbEHn7MEwMZZ9FcDVtFHku6DWn6JkuYHwbP1LRbcLDtHaBbVIYWNJs)gbqcwOKDWwZQvR7rrX8hL1Fq6uQTA16(0PycIkmqfkAWeO0zSg4funkcCLSeOKPxz5kpJatIKunLCu6DWn6JkuYHwbP1LRbcLDtHaBbVIYWNJs)gbqcwOuUNp0BnsCuum)rrvUNpRv60PutIJbQqzDycu6mwd8cQgffZFusWOYzoDkveyK9hLEhCJ(OcLCOvqAD5AGqz3uiWwWROm85OiWvYsGsyGpHRCpF2AaRCA3hRbEH6Kdd8jCnaNxapCFSg4fu63iasWcLGrLZ8wxGr2FmWafv5zMoiq1yGia]] )

    storeDefault( [[SimC Havoc: normal]], 'actionLists', 20170522.211452, [[diuYAaqisvTjOWNeHOgLe5usuRcejVseQClriKDbQHruoMuSmr0ZePQPjsrxtKsBtek9nuQghisDorOyDIqqZtes3tKk7de1bjvSquspKuLjkcvDrIkBeeXhfPWifHaNueCtqANOyPOepLYuHI2krv7f5VsyWQ6WclwQEmunzQ6YkBws9zrYOLsNMkVgLYSjCBs2nKFJQHdLwUOEoPmDGRljBNi(oPsJxeICEqy9IqOMprA)Qm1qysMCOOlMN6KXeQrM5u6DFIGqch)(KjcVhXZQqqgltSqBetsznSllTjtc3qMHNDybKrMo4ahhPrysmneMKjhk6I5jwjZWZoSaYkDpiedbGXMh2ipp8qrxm)9sLEpiedbGvC1qGkf8qrxm)9LVhJ77v11WyZdBKNh2Z1fDpg33RQRHvC1qGkfSNRlImD6oHdabzsgk1QRef5bYlaKPx7WzdkxYudbOozq5E5JmtOgzKXeQrM8dLA1vI7zzG8cazSmXcTrmjL1WEJmYsa5D4bGNjdXrJmOCptOgzeGyssysMCOOlMNyLmdp7WciR09GqmeawXvdbQuWdfDX83lv69GqmeaUEIcvObwgc4HIUy(7lFpg3x6E9VheIHaWkUAiqLcEOOlM)EPsVV09LUhVnYPM29P7(K3JX9AdaCOuAWSTHTOEIICLwBrE4TroLdL6(Y3lv694CUWZ1fblzOuRUsuKhiVaaNNkCiT7H89P59LVhJ77v11WkUAiqLc2Z1fDF57X4(s3R)9GqmeaUEIcvObwgc4HIUy(7Lk9(6QmeW(v7WDG7HC6UpzAVV89yCFP7XBJCQPDF6Up59yCV2aahkLgmBBylQNOixP1wKhEBKt5qPUVmz60DchacYQNOixP1sMETdNnOCjtneG6KbL7LpYmHAKrgtOgzqYe3ZsLwlzSmXcTrmjL1WEJmYsa5D4bGNjdXrJmOCptOgzeGyspHjzYHIUyEIvYm8SdlGSs3J3g5ut7(0DVksKkWBJCQPDF57X4(s33RQRHvC1qGkfCf27Lk9E9VheIHaWkUAiqLcEOOlM)(Y3JX9LUpWbojRyOPCt7EiFFZ9LjtNUt4aqqw9ef9iNJuJm9AhoBq5sMAia1jdk3lFKzc1iJmMqnYGKjUN1iNJuJmwMyH2iMKYAyVrgzjG8o8aWZKH4OrguUNjuJmcqmPjHjzYHIUyEIvYm8SdlGmqigca3fCUxma8qrxm)9yCFP71)EqigcaR4QHavk4HIUy(7Lk9(EvDnSIRgcuPGRWEF57X4E82iNAA3NU7tsMoDNWbGGmqBMRBrkr4KmY0RD4SbLlzQHauNmOCV8rMjuJmYyc1idZ2mx37tdr4KmYyzIfAJyskRH9gzKLaY7WdaptgIJgzq5EMqnYiaXKwctYKdfDX8eRKz4zhwaz1vziGXRY5Ha3NO33K27X4(s3JZ5cpxxeSFbOTqt3nSW5Pchs7(e9(KqQu4(7Lk9ECox456IG7IWVcFGWhCEQWH0UprVpjKkfU)(YKPt3jCaiiREIUi8Jm9AhoBq5sMAia1jdk3lFKzc1iJmMqnYGKj6IWpYyzIfAJyskRH9gzKLaY7WdaptgIJgzq5EMqnYiaXKyjmjtou0fZtSsMHNDybKjjYUOlgCxe(v4de(itNUt4aqqMFbOTqt3nSKPx7WzdkxYudbOozq5E5JmtOgzKXeQrwIFbO9Et3nSKXYel0gXKuwd7nYilbK3HhaEMmehnYGY9mHAKraIHDctYKdfDX8eRKz4zhwazAdaCOuAWSTHTOEIICLwBrE4TroLdL6EmUhVnYPM29P7(K3JX96FpiedbGvC1qGkf8qrxm)9yCV(3dcXqa46jkuHgyziGhk6I5jtNUt4aqqw9ef5kTwY0RD4SbLlzQHauNmOCV8rMjuJmYyc1idsM4EwQ0AVVutzYyzIfAJyskRH9gzKLaY7WdaptgIJgzq5EMqnYiaXaPjmjtou0fZtSsguUx(iZeQrgzmHAKbjtCVC5kSahhrwciVdpa8mzioAKPt3jCaiiREIILRWcCCez61oC2GYLm1qaQtgltSqBetsznS3iJmOCptOgzeGysmeMKjhk6I5jwjZWZoSaYkDFGdCswXqt5M29q((M7lFVuP3x6(s3R)9GqmeawXvdbQuWdfDX83lv699Q6AyfxneOsbxH9(Y3JX9LUx)7bHyiamEBW1k6IWpn4HIUy(7Lk9(EvDnmEBW1k6IWpn4kS3lv694CUWZ1fbJ3gCTIUi8tdopv4qA3d57tVS7Lk9EqKtnamWPwbGx4D7(e9ECox456IGXBdUwrxe(PbNNkCiT7lFFzY0P7eoaeKvxLHOGxxaAxHtiC(i7itV2HZguUKPgcqDYGY9YhzMqnYiJjuJmiPkdX9867bT7(eecNpYoYyzIfAJyskRH9gzKLaY7WdaptgIJgzq5EMqnYiaX0iJWKm5qrxmpXkzgE2HfqMKi7IUyWDr4xHpq47EmUV096FpoNl8CDrWQbcfpJTLR50GZl8qCFzY0P7eoaeK1fHFf(aHpY0RD4SbLlzQHauNmOCV8rMjuJmYyc1iJvr439j(aHpYyzIfAJyskRH9gzKLaY7WdaptgIJgzq5EMqnYiaX00qysMCOOlMNyLmdp7WcideIHaWDbN7fdapu0fZFpg3h4aNKvm0uUPDpKt39jVhJ7lDV(3dcXqayvObwUGxxaAxrkr4Km4HIUy(7Lk9E9VheIHaWkUAiqLcEOOlM)EPsVVxvxdR4QHavk4kS3x(EmUV09boWjzfdnLBA3d50DF6VVmz60DchacYaTzUUfPeHtYitV2HZguUKPgcqDYGY9YhzMqnYiJjuJmmBZCDVpneHtYUVutzYyzIfAJyskRH9gzKLaY7WdaptgIJgzq5EMqnYiaX0KKWKm5qrxmpXkzgE2HfqwDvgcy)QD4oW9qoD3NEzjUEvDnm28Wg55HRWcPG0KPt3jCaiiREIUi8Jm9AhoBq5sMAia1jdk3lFKzc1iJmMqnYGKj6IWV7l1uMmwMyH2iMKYAyVrgzjG8o8aWZKH4OrguUNjuJmcqmnPNWKm5qrxmpXkzgE2HfqgiedbG7chYxuxLHaEOOlM)EmUV09boWjzfdnLBA3d57BUxQ07RRYqa7xTd3bUhYP7(0N27ltMoDNWbGGSbXk6luKPx7WzdkxYudbOozq5E5JmtOgzKXeQrMCqS7zDHImwMyH2iMKYAyVrgzjG8o8aWZKH4OrguUNjuJmcqmnPjHjzYHIUyEIvYm8SdlGSs3dcXqay)uCurxe(Pbpu0fZFVuP3R)9GqmeawXvdbQuWdfDX83lv699Q6AyfxneOsbxH9EPsVVUkdbSF1oCh4(e9(0llX1RQRHXMh2ippCfwifK(EPsVVxvxdRgiu8m2wUMtdopv4qA3NO3N27lFpg3R)9sISl6IbJLZfouQIAEUOlc)k8bcFKPt3jCaiilqixRteahhrMETdNnOCjtneG6KbL7LpYmHAKrgtOgz6GqUwNiaooImwMyH2iMKYAyVrgzjG8o8aWZKH4OrguUNjuJmcqmnPLWKm5qrxmpXkzgE2HfqgiedbG7co3lgaEOOlM)EmUV096FpiedbGvHgy5cEDbODfPeHtYGhk6I5VxQ071)EqigcaR4QHavk4HIUy(7Lk9(EvDnSIRgcuPGRWEFzY0P7eoaeKbAZCDlsjcNKrMETdNnOCjtneG6KbL7LpYmHAKrgtOgzy2M56EFAicNKDFPKLjJLjwOnIjPSg2BKrwciVdpa8mzioAKbL7zc1iJaettILWKm5qrxmpXkzgE2HfqM(3dcXqa4UWH8f1vziGhk6I5VhJ7lDFGdCswXqt5M29q((M7Lk9(s3R)9Adu05OknyGB5MetrAIf)EiFVS7X4E9VxsKDrxmySCUWHsvuZZfQbI7X4(EvDnSAGqXZyB5Aonypxx09yCFP7JmWvh4a4aLQYP1wWRlaTRWp85KSm8qrxm)9sLEFGdCswXqt5M29q((M7lFpg3R)9GqmeagVn4Af4Ifsg8qrxm)9LVVmz60DchacYgeROVqrMETdNnOCjtneG6KbL7LpYmHAKrgtOgzYbXUN1fQ7l1uMmwMyH2iMKYAyVrgzjG8o8aWZKH4OrguUNjuJmcqmnStysMCOOlMNyLmdp7WciRxvxdRgiu8m2wUMtd2Z1fDpg3h4aNKvm0uUPDpKt39jjtNUt4aqqgOnZ1TiLiCsgz61oC2GYLm1qaQtguUx(iZeQrgzmHAKHzBMR79PHiCs29LsFzYyzIfAJyskRH9gzKLaY7WdaptgIJgzq5EMqnYiaX0aPjmjtou0fZtSsMHNDybKv6Eqigca7NIJk6IWpn4HIUy(7Lk9E9VheIHaWkUAiqLcEOOlM)EPsVVxvxdR4QHavk4kS3lv691vziG9R2H7a3NO3NEzjUEvDnm28Wg55HRWcPG03x(EmUx)7Lezx0fdglNlCOuf18CbEBW1k0azhB7EmUx)7Lezx0fdglNlCOuf18CHAG4EmUx)7Lezx0fdglNlCOuf18Crxe(v4de(itNUt4aqqgEBW1k0azhBJm9AhoBq5sMAia1jdk3lFKzc1iJmMqnY0Rn4A3BGSJTrgltSqBetsznS3iJSeqEhEa4zYqC0idk3ZeQrgbiMMedHjzYHIUyEIvYm8SdlGSs3J3g5ut7(0DVksKkWBJCQPLiQ5(Y3JX99Q6Ay1aHINX2Y1CAWEUUO7X4(s33RQRHvC1qGkfCf27Lk9E9VheIHaWkUAiqLcEOOlM)(Y3JX9LUpWbojRyOPCt7EiFFZ9LjtNUt4aqqw9ef9iNJuJm9AhoBq5sMAia1jdk3lFKzc1iJmMqnYGKjUN1iNJu7(snLjJLjwOnIjPSg2BKrwciVdpa8mzioAKbL7zc1iJaetszeMKjhk6I5jwjZWZoSaY0)EqigcaR4QHavk4HIUy(7X4(s3dcXqay)uCurxe(Pbpu0fZFVuP33RQRHvdekEgBlxZPb756IUVmz60DchacYQNOixP1sMETdNnOCjtneG6KbL7LpYmHAKrgtOgzqYe3ZsLw79LswMmwMyH2iMKYAyVrgzjG8o8aWZKH4OrguUNjuJmcqmjBimjtou0fZtSsguUx(iZeQrgzmHAKL4NIJsK1UNvhyKLaY7WdaptgIJgz60DchacY8tXrAfDhyKPx7WzdkxYudbOozSmXcTrmjL1WEJmYGY9mHAKraIjzsctYKdfDX8eRKz4zhwazGiNAayhQihOuJmD6oHdabzG2mx3IuIWjzKPx7WzdkxYudbOozq5E5JmtOgzKXeQrgMTzUU3NgIWjz3xknltgltSqBetsznS3iJSeqEhEa4zYqC0idk3ZeQrgbiMKPNWKm5qrxmpXkzgE2HfqgiYPga270abcF3lv69GiNAayhQihOuJmD6oHdabz1t0fHFKPx7WzdkxYudbOozq5E5JmtOgzKXeQrgKmrxe(DFPKLjJLjwOnIjPSg2BKrwciVdpa8mzioAKbL7zc1iJaetY0KWKm5qrxmpXkzgE2HfqgiYPga270abcF3d57Bs79sLEFP7bro1aWouroqP29yCV(3dcXqayfxneOsbpu0fZFFzY0P7eoaeKvprrUsRLm9AhoBq5sMAia1jdk3lFKzc1iJmMqnYGKjUNLkT27lL(YKXYel0gXKuwd7nYilbK3HhaEMmehnYGY9mHAKraIjzAjmjtou0fZtSsMHNDybKbICQbG9onqGW39q((M0sMoDNWbGGmjdLA1vII8a5faY0RD4SbLlzQHauNmOCV8rMjuJmYyc1it(HsT6kX9SmqEb4(snLjJLjwOnIjPSg2BKrwciVdpa8mzioAKbL7zc1iJaetYelHjzYHIUyEIvYm8SdlGm9VheIHaWDbN7fdapu0fZtMoDNWbGGmqBMRBrkr4KmY0RD4SbLlzQHauNmOCV8rMjuJmYyc1idZ2mx37tdr4KS7lL2YKXYel0gXKuwd7nYilbK3HhaEMmehnYGY9mHAKracqMHD4Uq4sehahhrmPLD2jara]] )

    storeDefault( [[SimC Havoc: default]], 'actionLists', 20170522.211452, [[daKBpaqirWIuOYMicJsvvNcjzvIq9kIOmlfkDlIOAxkAyiXXejlte9mrQMMcvDnfk2gsL(MiLXPqKoNcryDkeMhrK7HKAFefhufAHiv8qKQUOQsgPiKtQQuZuHOUjr1ovWsvi9uLMQkWwjkTxQ(RknysDyulwvEmLMmHld2Sa9zbmAI0PH8AvqZgQBlQDl1VLmCvflxONtX0rCDb12vrFxqoVQkRxHiA(iL9tYEk)aF)Q5hge(Z3bod(UOm9kDI4ZYQ0jhHslGGCymX3rbmWgWhssjvAugtYKZu(U2i6dXxFpAjOQn(b(qk)aF)Q5hgeoD8DTr0hIVjO0)v6euAcJHMmBidgKzcn)WGqPPrtPTvHfvOE2qgmiZmcS4NstJMsBRclQq9SHmyqMzeYmQnkTmknHJbaYKGYWLuxbcuAA0uABvyrfQNnKbdYmJqMrTrPLrPPlfLMkFp(qye5NVNCeXpm473Tazzsf9TRg8vEjKLJdCg8neJiOoWnyfVnKbdY47aNbFxsfbLwwghg89ymGX3MZa1Hyeb1bUbR4THmyqMXEY4Wa1j8pbcJHMmBidgKzcn)WGGgnBvyrfQNnKbdYmJal(rJMTkSOc1ZgYGbzMriZO2idHJbaYKGYWLuxbcOrZwfwuH6zdzWGmZiKzuBKHUuOY3rbmWgWhssjvAPO4l9sb7HYRtidnXF(kVedCg81j(qs)aF)Q5hgeoD8DTr0hIVjO0)v6euAcJHMmTs5YCFywaMj08ddcLMgnL2wfwuH6PvkxM7dZcWmJal(P00OP02QWIkupTs5YCFywaMzeYmQnkTmknHJbaYKGYWLuxbcuAA0uABvyrfQNwPCzUpmlaZmczg1gLwgLMUuuAQ894dHrKF(EYre)WGVF3cKLjv03UAWx5LqwooWzW3qmIG6a3Gv8ALYL5(WSam(oWzW3LurqPLLXHbL(FkQ89ymGX3MZa1Hyeb1bUbR41kLlZ9Hzbyg7jJdduNW)eimgAY0kLlZ9HzbyMqZpmiOrZwfwuH6PvkxM7dZcWmJal(rJMTkSOc1tRuUm3hMfGzgHmJAJmeogaitckdxsDfiGgnBvyrfQNwPCzUpmlaZmczg1gzOlfQ8DuadSb8HKusLwkk(sVuWEO86eYqt8NVYlXaNbFDIpKUFGVF18ddcNo(U2i6dX3euAcJHMmfqUAKDcn)WGqPLqPTvHfvOEMbcNR4hPLbzMriZO2O0ssPPRslHshmC83uabrwerPLrPtNIslHs)xPtqPp5iIFyygIreuh4gSI3gYGbzuAA0uABvyrfQNnKbdYmJqMrTrPLKsNIIstLslHs)xPtqPp5iIFyygIreuh4gSIxRuUm3hMfGrPPrtPTvHfvOEALYL5(WSamZiKzuBuAjP00vPPY3Jpegr(57jhr8dd((DlqwMurF7QbFLxcz54aNbF)ufg1bUbR4nde23bod(UKkckTSmomO0)tsLVhJbm(2CgO(tvyuh4gSI3mq4XEY4Wa1jqym0KPaYvJStO5hgesyRclQq9mdeoxXpsldYmJqMrTrs0vIGHJ)MciiYIiYKofj(NWjhr8ddZqmIG6a3Gv82qgmidnA2QWIkupBidgKzgHmJAJKsrHkj(NWjhr8ddZqmIG6a3Gv8ALYL5(WSam0OzRclQq90kLlZ9HzbyMriZO2ij6sLVJcyGnGpKKsQ0srXx6Lc2dLxNqgAI)8vEjg4m4Rt8HX7h47xn)WGWPJVRnI(q8LWyOjZGOOHCF4QetO5hgeknnAkTbi3x1HntccIjPCt(XQ0YO0uuAA0uA2sqNWfAiJaJsld1kD6sMs)xPjmgAY0kLlZ1Ib(eMOl08ddIeNUstLVhFimI8Z3toI4hg897wGSmPI(2vd(kVeYYXbod((WSaUcUTGVdCg8DjveuAzzCyqP)Nov(EmgW4BZzG6hMfWvWTfg7jJddutym0Kzqu0qUpCvIj08ddcA0ma5(QoSzsqqmjLBYpwA0ylbDcxOHmcmYqD6s2FcJHMmTs5YCTyGpHj08ddIeNov(okGb2a(qskPslffFPxkypuEDczOj(Zx5LyGZGVoXhgJFGVF18ddcNo(U2i6dX3toI4hgMpmlGRGBlO0sO0bdh)nTHJrOjs(4PO0ssPtFmsoHXqtMbrrd5(WvjMOl08ddIeNKIslHs)xPzlbDcxOHmcmkTmuR0Plzk9FLMWyOjtRuUmxlg4tyIUqZpmisC6knvknv(E8HWiYpFp5iIFyW3VBbYYKk6Bxn4R8silhh4m47NQWOoWnyfVpmlGRGBl47aNbFxsfbLwwghgu6)JNkFpgdy8T5mq9NQWOoWnyfVpmlGRGBlm2tghgO(KJi(HH5dZc4k42csemC8NKpEksk9Xi5egdnzgefnK7dxLycn)WGiXjPiXF2sqNWfAiJaJmuNUK9NWyOjtRuUmxlg4tycn)WGiXPtfv(okGb2a(qskPslffFPxkypuEDczOj(Zx5LyGZGVoXhORFGVF18ddcNo(U2i6dXxcJHMmTs5YCTyGpHj08ddcLwcLoy44VPacISiIslJspEk(E8HWiYpFp5iIFyW3VBbYYKk6Bxn4R8silhh4m47NQWOoWnyfVwPCzUgseDi47aNbFxsfbLwwghgu6)JHkFpgdy8T5mq9NQWOoWnyfVwPCzUgseDim2tghgOMWyOjtRuUmxlg4tycn)WGqIGHJ)MciiYIiYmEksKqKrIlCcnzYcHzg(JergjUWj0KjleMjQLuYehWk8DuadSb8HKusLwkk(sVuWEO86eYqt8NVYlXaNbFDIpKMFGVF18ddcNo(kVeYYXbod(67aNbFPVAt4mO0Y5aiRVF3cKLjv03UAW3Jpegr(5RTAt4mCZCaK1x6Lc2dLxNqgAI)8DuadSb8HKusLwkk(kVedCg81j(Wi1pW3VA(HbHthFxBe9H4RTkSOc1Za46X4RTkSOc1ZiKzuBuAQvAk(E8HWiYpFTmgFzlbv9fJmeF)UfiltQOVD1GVYlHSCCGZGV(oWzWx6zmwPpAjOQv6rgzi(EmgW4BZzG6XTOm9kDI4ZYQ0jhHsBRclQq948DuadSb8HKusLwkk(sVuWEO86eYqt8NVYlXaNbFxuMELor8zzv6KJqPTvHfvO2j(WiHFGVF18ddcNo(U2i6dXxcJHMmfqUAKDcn)WGqPLqPjmgAYua5Qr2l)5dqqeycn)WGqPLqPjmgAY8HrT4gmC83eA(HbHVhFimI8Z3y4(YwcQ6lgzi((DlqwMurF7QbFLxcz54aNbF9DGZGVJgUv6JwcQALEKrgIVhJbm(2CgOEClktVsNi(SSkDYrO0cixnYooFhfWaBaFijLuPLIIV0lfShkVoHm0e)5R8smWzW3fLPxPteFwwLo5iuAbKRgzDIpKIIFGVF18ddcNo(E8HWiYpFJH7lBjOQVyKH473Tazzsf9TRg8vEjKLJdCg813bod(oA4wPpAjOQv6rgzik9)uu57XyaJVnNbQh3IY0R0jIplRsNCekDxXmJhNVJcyGnGpKKsQ0srXx6Lc2dLxNqgAI)8vEjg4m47IY0R0jIplRsNCekDxXmJDIt8D)aweJrJKmbvTpmM0sZjUd]] )

    storeDefault( [[SimC Havoc: precombat]], 'actionLists', 20170522.211452, [[daJ8baGEuuTjuL2fv51OcZMu3KQ62KStjTxXUv1(jYOqvmme8BkdffXGj0WrPdQuCkujhJOwiQOLIqwSkwUk9qLspfSmQ06qOAQe0KLy6kUOsLldTvuP2UsvphrFMk8DuugjksNgPrtGhRKtIQQVHcxJkY5rv5WsDiek)LkQJCegy33hnwYjqTvyaGQ2kjY0EVTKeDjUKi7fxM60taIqn2KyQUeKzqWjxxp5aW6szNab2SgQ9KryQYryGDFF0yjCgawxk7eymho0OhRnu7jdS5q10HVaS2qTpWwb4IdFBpQWFYjGVv4UV1wHbcuBfgGj2qTparOgBsmvxcYmKjeG)Vqx9y3aV9yaFRuBfgitQUryGDFF0yjCgawxk7eymho0O3YmDXy2tYlpetsKhjXP14pEfuzVZx8y33d)(OXIKiVsItRXF8kOYE6Yd)(OXIKixCfyZHQPdFbu40k7YkWiPKb2kaxC4B7rf(tob8Tc39T2kmqGARWa(40k7YkWiPKbic1ytIP6sqMHmHa8)f6Qh7g4Thd4BLARWazYeayXfT1uM3d1(uDIbJmj]] )

    storeDefault( [[SimC Havoc: cooldown]], 'actionLists', 20170522.211452, [[dOJ4gaGAKs16rkHnPuAxi61IkTprfMTKMVk6Mkv3MWorYEH2nQ2prJsenmvQFlmuKs0Gjz4I0brjDkr4yQW3qkwifQLsrSyuSCjEikXtPAzuW6qPItRQPIszYuA6kUifPhJWZqPsxNI68uiBvjXMrQ2UsXHL65KAAiLY3vsnsKsQ5jQQrRs(ROCsrv(SsCnLKUhkvDiKsYLbBturJhiBOBkVzQGfzqNQfa6(lyrQO19MGqQmWosfrevBSMJUjqfAnGugUpO5Evdgipq3jkF6Go6SsmFW1iBi1bYg6MYBMkyrJr3jkF6G(ellvGKiIQnwZ1BtsRKQKs10vGpKwqe8NGe4ntfSs15PuTPlFZubY0iQpFjJEuYeW0s15PuTPlFZubY19ppFjJEuY4Ga0VwQopLQnD5BMkqUU)55lz0JsgXvh6mMABbTuLqQopLQPllWqoVaYMiZ(GuLVuzy1eOZkZx)Xi0fW0IOKEf6xJolxarU7Xgqa8bzqFpSR0fQwaOJovla03HPfrj9k0VgDtGk0AaPmCFqZXn65XTprprbDEWb03dlvla0XbPmGSHUP8MPcw0y0DIYNoOpXYsfijIOAJ1C92Ktxb(qAbrWFcsG3mvWkvBLkgZ0PtkGPfrj9k0VM0CQuTvQOBUyejH5sb4JuLVurB3jqNvMV(JrOlGPfrj9k0VgDwUaIC3JnGa4dYG(EyxPluTaqhDQwaOVdtlIs6vOFTuL8ib6MavO1asz4(GMJB0ZJBFIEIc68GdOVhwQwaOJdsXUiBOBkVzQGfngDNO8Pd6tSSubsIiQ2ynxVnzsPYcmMPtNKdcq)AsBSMlvBLQKsvtm)gid4G4bTuLdP6qQsivjKQTsvsPQllWqoVaYMiZ(GuLib6SY81FmcDoia9RrppU9j6jkOZdoG(EyxPluTaqhDQwaOtbcq)A0zTSOrF6YcmzpD2lEo7mDzbgY5fq2ez2hq3eOcTgqkd3h0CCJolxarU7Xgqa8bzqFpSuTaqhhKI2q2q3uEZublAm6or5th0NyzPcKeruTXAUEBYKsfJz60jjU6qNXuBlOjnNkvNNsfJz60jfW0IOKEf6xtAovQopLkIiQ2ynNuatlIs6vOFnzBPDZ6bSzfq0pxlv5lvgULQZtPA6YcmKZlGSjYSpiv5ZEPkN3svIeOZkZx)Xi05Ga0VgDwUaIC3JnGa4dYG(EyxPluTaqhDQwaOtbcq)APk5rc0nbQqRbKYW9bnh3ONh3(e9ef05bhqFpSuTaqhhKAvKn0nL3mvWIgJUtu(0b9jwwQajrevBSMR3MKXmD6KcyArusVc9RjnNkvNNsfrevBSMtkGPfrj9k0VMST0Uz9a2Sci6NRLQCiv58wQopLQPllWqoVaYMiZ(GuLp7LQddjqNvMV(JrOtC1HoJP2wqJolxarU7Xgqa8bzqFpSR0fQwaOJovla0z5QdTuzCTTGgDtGk0AaPmCFqZXn65XTprprbDEWb03dlvla0XbPYjYg6MYBMkyrJr3jkF6G(ellvGmnMp46TjzmtNoPaMweL0Rq)AYci6NRLQCivgwvQopLQPllWqoVaYMiZ(GuLVuXU3jqNvMV(JrONgZhC0z5ciYDp2acGpid67HDLUq1caD0PAbGoTmMp4OBcuHwdiLH7dAoUrppU9j6jkOZdoG(EyPAbGoo4GUNceFxFArpFWrQvPHgCqea]] )

    storeDefault( [[SimC Havoc: demonic]], 'actionLists', 20170522.211452, [[deu)qaqiQO2eq5teIWOaQofaTkcr1ROsfTluzye0XKultI8mjQAAsuPRrLQ2gvQW3qknojQ4CeIO1risnpjk5Eec2NefhKqAHeOhsOmrjk1fjGnsi0hPsLgjHO4KurUPuANizPaXtPmvG0wjuTxO)kHbd6WIwSu9yu1Kf6YkBwk(mvYOLKttQxJumBsUnr7wv)gLHdOLl45uLPRY1PQ2os13Psz8eIKZdG1tiknFQW(rmwJGIMaF2vlID0Os5qZ0sXiqrMKoJNaljstGXjzVMhnqMAP3qQscRPvO7lvIRgnJpObEOHMO8NM9EiOivnckAc8zxTikiAgFqd8qdCc8s1(JdyyaZWIC7ZUArc0Hdc8s1(JtYK7pFj3(SRwKabKabJa7(nnCaddygwKlYC7jqWiWUFtdNKj3F(sUiZThnr7AL(aan67DTgFvryxy5HMyvJNMwg9j3FyhTwwu8mqLYHgAuPCOj(ExRXxrGGSlS8qdKPw6nKQKWAARfIMtFuZNhlG2Z(HwllsLYHgEivjeu0e4ZUAruq0m(Gg4Hg4e4LQ9hNKj3F(sU9zxTib6WbbEPA)X1mvHm9UfaGBF2vlsGasGGrGGtGotGxQ2FCsMC)5l52ND1IeOdhei4ei4eO3Ut)U84OzdyrZufbFVQIW4RYGl97IabJa5RYGR5rGIabwIabKaD4Ga5zmvK52ZrFVR14Rkc7clpUWKP(9iWYqGLlbcibcgb29BA4Km5(ZxYfzU9eiGeiyei4eO3Ut)U84OzdyrZufbFVQIW4RYGl97IabJa5RYGR5rGIabwIabenr7AL(aaTMPkc(EvOjw14PPLrFY9h2rRLffpduPCOHgvkhAI4ueii(EvObYul9gsvsynT1crZPpQ5ZJfq7z)qRLfPs5qdpKQ8iOOjWND1IOGOz8bnWdTlv7pUUIXIQDC7ZUArcemceCc0zc8s1(JtYK7pFj3(SRwKaD4Ga7(nnCsMC)5l58bsGasGGrG8vzW18iqrGalHMODTsFaG2vfyUv4sLA6dnXQgpnTm6tU)WoATSO4zGkLdn0Os5qd0QaZnc0DvPM(qdKPw6nKQKWAARfIMtFuZNhlG2Z(HwllsLYHgEiv5IGIMaF2vlIcIMXh0ap0ONbD2vJRRY4kI5Zp0eTRv6da0IlVQcp32aIMyvJNMwg9j3FyhTwwu8mqLYHgAuPCOv2lVkc0CBdiAGm1sVHuLewtBTq0C6JA(8yb0E2p0AzrQuo0WdPCpckAc8zxTikiATSO4zGkLdn0Os5qteNIafi4d80ShnN(OMppwaTN9dnr7AL(aaTMPkwWh4PzpAIvnEAAz0NC)HD0azQLEdPkjSM2AHO1YIuPCOHhs5oqqrtGp7QfrbrZ4dAGhAGtGj)PPVI9tQNhbwgcSMabKaD4GabNabNaDMaVuT)4Km5(ZxYTp7QfjqhoiWUFtdNKj3F(soFGeiGeiGOjAxR0haO14haOG1uCvRqRu6yg0Ojw14PPLrFY9h2rRLffpduPCOHgvkhAIOFaacK1qGx1iqNukDmdA0azQLEdPkjSM2AHO50h185XcO9SFO1YIuPCOHhsrlckAc8zxTikiAgFqd8qJEg0zxnUUkJRiMp)iqWiqEgtfzU9CdGv0xk5ctM63Jaldb6Ecemc0zcKNXurMBpNCxkzbGvmpThxyzea0eTRv6da06QmUIy(8dnXQgpnTm6tU)WoATSO4zGkLdn0Os5qtqvghbw25Zp0azQLEdPkjSM2AHO50h185XcO9SFO1YIuPCOHhsvoiOOjWND1IOGOz8bnWdTlv7pUUIXIQDC7ZUArcemcm5pn9vSFs98iWYiceyjcemceCc0zc8s1(JtME3cfSMIRAfUuPM(42ND1IeOdheOZe4LQ9hNKj3F(sU9zxTib6Wbb29BA4Km5(ZxY5dKabKabJabNat(ttFf7NuppcSmIabwEceq0eTRv6da0UQaZTcxQutFOjw14PPLrFY9h2rRLffpduPCOHgvkhAGwfyUrGURk10hbcEnGObYul9gsvsynT1crZPpQ5ZJfq7z)qRLfPs5qdpKsKebfnb(SRwefenJpObEOL8NM(k2pPEEeyziWAc0Hdc0zcS730WfNK9A(IjsD7Jlwi3LswayfZt7X5denr7AL(aaTbWk6lLOjw14PPLrFY9h2rRLffpduPCOHgvkhAcaWiqbxkrdKPw6nKQKWAARfIMtFuZNhlG2Z(HwllsLYHgEivTqeu0e4ZUAruq0m(Gg4Hg4eOZe4LQ9hNKj3F(sU9zxTib6Wbb29BA4Km5(ZxY5dKaD4GaB8daWfxJMxFeyzrGLxO7S730WbmmGzyroFGI8YHaD4Ga7(nnCYDPKfawX80ECHjt97rGLfb6Eceqcemc0zcKEg0zxnoGmMs)UkAyHIUkJRiMp)qt0UwPpaql)xxPv5PzpAIvnEAAz0NC)HD0AzrXZavkhAOrLYHMO)RR0Q80ShnqMAP3qQscRPTwiAo9rnFESaAp7hATSivkhA4Hu11iOOjWND1IOGOz8bnWdTlv7pUUIXIQDC7ZUArcemceCc0zc8s1(JtME3cfSMIRAfUuPM(42ND1IeOdheOZe4LQ9hNKj3F(sU9zxTib6Wbb29BA4Km5(ZxY5dKabenr7AL(aaTRkWCRWLk10hAIvnEAAz0NC)HD0AzrXZavkhAOrLYHgOvbMBeO7Qsn9rGGxcq0azQLEdPkjSM2AHO50h185XcO9SFO1YIuPCOHhsvxcbfnb(SRwefenJpObEObob6mbEPA)XjzY9NVKBF2vlsGoCqGD)MgojtU)8LC(ajqhoiWg)aaCX1O51hbwwey5f6o7(nnCaddygwKZhOiVCiqajqWiqNjq6zqND14aYyk97QOHfk4RsMxH3f00mcemc0zcKEg0zxnoGmMs)UkAyHc5UKabJaDMaPNbD2vJdiJP0VRIgwOORY4kI5Zp0eTRv6da04RsMxH3f00m0eRA800YOp5(d7O1YIINbQuo0qJkLdnXQsMhbAxqtZqdKPw6nKQKWAARfIMtFuZNhlG2Z(HwllsLYHgEivD5rqrtGp7QfrbrZ4dAGhAotGxQ2FCsMC)5l52ND1Ieiyey3VPHtUlLSaWkMN2JlYC7jqWiqWjqVDN(D5XrZgWIMPkc(EvfHXxLbx63fbcgbYxLbxZJafbcSebciAI21k9baAntve89QqtSQXttlJ(K7pSJwllkEgOs5qdnQuo0eXPiqq89QiqWRbenqMAP3qQscRPTwiAo9rnFESaAp7hATSivkhA4Hu1LlckAc8zxTikiATSO4zGkLdn0Os5qRSNK9IeEeOG6BO50h185XcO9SFOjAxR0haOfNK9EfD9n0eRA800YOp5(d7ObYul9gsvsynT1crRLfPs5qdpKQ29iOOjWND1IOGOz8bnWdTldU2XP)Iq(UgAI21k9baAxvG5wHlvQPp0eRA800YOp5(d7O1YIINbQuo0qJkLdnqRcm3iq3vLA6JabV8aIgitT0BivjH10wlenN(OMppwaTN9dTwwKkLdn8qQA3bckAc8zxTikiAgFqd8q7YGRDCrT3Lp)iWYqG1UNaD4GabNaVm4AhN(lc57AeiyeOZe4LQ9hNKj3F(sU9zxTibciAI21k9baAntve89QqtSQXttlJ(K7pSJwllkEgOs5qdnQuo0eXPiqq89QiqWlbiAGm1sVHuLewtBTq0C6JA(8yb0E2p0AzrQuo0WdPQPfbfnb(SRwefenJpObEODzW1oUO27YNFeyziWA3JMODTsFaGg99UwJVQiSlS8qtSQXttlJ(K7pSJwllkEgOs5qdnQuo0eFVR14Riqq2fwEei41aIgitT0BivjH10wlenN(OMppwaTN9dTwwKkLdn8Wdnd441PslYMNM9iL7PLw8qe]] )

    storeDefault( [[Red Vengeance: precombat]], 'actionLists', 20170522.210710, [[dqJ2baGEuuTlkyBsL2NqPzd1Tf0ovQ9s2nK9RqdJk(TugSImCf1brv(gQQJrPZbIAHOILcklwilNQoTKNQ6Xk55u0ebrMQu1Kfy6axee(mO6YixhfLnIc1wrbTzfSDuQ(ikKZlvmnusFxO4WIwhkWOfQwgv6KuONbsxdLY9qr8AuIXHI0FrLww1RVZqshgfmoXqcbNs0IyW40SNwTWOeO)LVMb66WimLMK2Uow(oS6c1GRLv2Sqw)Z0QsCX8eunK2SXuRoVfOAit1RTv96qGYimfio67mK0FbVWJtTHXjgJZqshgHP0K021X21Y3GduRUruqTsqZRJAis)lFnd015fv4c0r3SGxyUTbUd4mKeqBx1RdbkJWuG4OVZqs3iAG8OepoDGVyH0HryknjTDDSDT8n4a1QBefuRe086OgI0)YxZa9v80dNmJLjwDErfUaD0l0a5rjMRjWxSqcOnu1RdbkJWuG4OVZqsVpUVfZ4eJWzXoPdJWuAsA76y7A5BWbQv3ikOwjO51rneP)LVMb668IkCb6OdI7BXWfool2jbeqhs0qYmmqCeqc]] )

    storeDefault( [[Red Vengeance: default]], 'actionLists', 20170522.210710, [[diu)laqisjAtQkgfPItrQ0QGub7sIHjIJbXYiv9mrQPbPkxdLQTbP8nvvghPKCoivY6iLuZdv09uLAFKs9psj4GQkTqvv9qivQjcPIUikLnkK4KqsRuvI0nHuv7ev9tsj0qvLiwQQWtPAQqIRcPcTvvj8vvjk7f5VqzWKIdtzXO4XIAYs6YGnROpleJwi1PjETqsZwQBdv7wLFtYWfQLl45kmDLUokz7IKVRkPZRkA9QsunFuH9JknHqOqoVHdK)aQC18c4Ia2LbTMRMkmnw9sUNds8so5pGgSbq86tq(LGE6tx0JGESJGUi3JHSyT8YTvuhXZUwHq(38kQBqOq8iekKJ(Q6lSaVHdKZAaydjI0yQj2SnCGCphK4LCDwRHBlZ2WbSCWgrxGZyAO(PcmSMZYqIinMAInBdhkba3KBW5BeD5GdD0Y1A42YSnCalhSr0f4mMgQ6soBNX0qL(t(xgPL9j5PSGymnqoQxvY2QcKFQdi)b0GnaIxFccAi)kjPriN3WbYrhhaxnUerAUAutUAIsB4GwGwIxpHc5OVQ(clWB4a5VAYInvbS4GOcY(eZyKwwbgK75GeVKRtwP6Q61Ri44Q2wrDygRGvcaUj3GZKc7FIn5kvykzz1(nc76Ybh6Swd3wMqZ0wfkWzmnu)KvQUQE9ktOzARcLaGBYn4mPW(NytUsfMswwTFhBYHvHPKLfRfCz1Ldo0zTgUTmHgdcSIxrDf4mMgQFYkvxvVELj0yqGv8kQReaCtUbNjf21Ldo0jLfeJPHcRbGnKisJPMyZ2WHpwELuagCaUadTFR)twP6Q61RmKisJPMyZ2WHsaWn5gCMuyxxo4qNObR3OlXqid3Y57QDrGa2gDagrR66NSs1v1RxzcnwfszJ1wrDLaGBYn4mPW(NytUsMvia3Q970j6soBNX0qL(t(dObBaeV(ee0q(vssJqoQxvY2QcKFQdiN3WbYFzMSC1mvbUAEjbrfK9jxnFzKwwbgAbY)YiTSpjpLfeJPbAj(0ekKZ2zmnuP)K75GeVKVQirAOuHjCdjfmi)b0GnaIxFccAi)kjPri)lJ0Y(K8S1nMLxrDyTmwYr9Qs2wvG8tDa58goqo6eMWnKuWGC0xv5nCG8hqLRMxaxeWUmO1C1uHjCdjfmOL4rpcfYz7mMgQ0FY5nCGCxXQ5QbD3GLci)b0GnaIxFccAi)kjPrih1RkzBvbYp1bK75GeVKhBYvYScb4wTFJwYhgwZzzOy1yZGfbhUDugRLJk6a7C(oAW6n6sfMswwS48s(xgPL9j5dfRgl3GLcOL4zNqHC2oJPHk9NCphK4L81A42YiwcYIXOWzkWzmnu)ubgwZzzgmP3NLaGBYn4K9pmSMZYqXQXMblcoC7OmwlhvTFJq(dObBaeV(ee0q(vssJqoQxvY2QcKFQdi)lJ0Y(K8rSeKfJrHZqoVHdK7XsqwUA(RWzOL4rJqHC2oJPHk9NCphK4L8ytUsfMswwTFJWo5pGgSbq86tqqd5xjjnc5OEvjBRkq(PoG8Vmsl7tYfCCvBROomJvWiN3WbYrfhx12kQJRMVScgTe)pcfYz7mMgQ0FY9CqIxYT8kPam4aCbgA)w)NkWWAoldjI0yQj2SnCOeaCtUbNVri)b0GnaIxFccAi)kjPrih1RkzBvbYp1bK)LrAzFs(qIinMAInBdhiN3WbYDjI0C1OMC1eL2WbAjETIqHC2oJPHk9NCphK4L81A42YeAM2QqboJPH6NytUsfMswwTFhBYHvHPKLfRfCzj)b0GnaIxFccAi)kjPrih1RkzBvbYp1bK)LrAzFs(eAM2Qa58goqEuGMPTkqlXJUiuiNTZyAOs)jN3WbY1IZjCdjfmi3ZbjEjFvrI0qjRuDv96ni)b0GnaIxFccAi)kjPrih1RkzBvbYp1bK)LrAzFsE26gZYROoSwgl5OVQYB4a5pGkxnVaUiGDzqR5QrnNWnKuWGwIhjHqHC2oJPHk9NCphK4LClVskadoaxGXBKpR1WTLzWYlRauGZyAO(j2KRuHPKLLZytoSkmLSSyTGll5pGgSbq86tqqd5xjjnc5OEvjBRkq(PoG8Vmsl7tYNblVSca58goqEucwEzfaAjEeecfYz7mMgQ0FY9CqIxYRadR5SmKisJPMyZ2WHsaWn5gC(gH8hqd2aiE9jiOH8RKKgHCuVQKTvfi)uhq(xgPL9j5djI0yQj2SnCGCEdhi3LisZvJAYvtuAdh4QrheDPL4r0tOqoBNX0qL(tUNds8sUoA5AnCBzgS8Ykaf4mMgQCWHLxjfGbhGlWq73619tSjxPctjllNXMCyvykzzXAbxwYFanydG41NGGgYVssAeYr9Qs2wvG8tDa5FzKw2NKpuSASCdwkGCEdhi3vSAUAq3nyPaUA0brxAjEK0ekKZ2zmnuP)K75GeVKVwd3wMqJbbwXROUcCgtdvYFanydG41NGGgYVssAeYr9Qs2wvG8tDa5FzKw2NKpHgdcSIxrDKZB4a5rbAUAylWkEf1rlXJGEekKZ2zmnuP)K75GeVKNYcIX0qH1aWgsePXutSzB4WhDYkvxvVEf5Mq4SgBSbjQqjhTfIadSzWYROoR1(nsrRyNdoS8kPam4aCbgA)wVUCFPK)aAWgaXRpbbnKFLK0iKJ6vLSTQa5N6aY)YiTSpjxUjeoRXgBqIkqoVHdKJ6nHWznxn(gKOc0s8iStOqoBNX0qL(toVHdK7rdwGRgDq0L8hqd2aiE9jiOH8RKKgHCuVQKTvfi)uhqUNds8sUwMYcIX0q5vtw5IGnvbS4GOcY(eZyKwwbgK)LrAzFs(iAWc0sl5OtyAS6L(tlra]] )

    storeDefault( [[Red Vengeance: defensives]], 'actionLists', 20170522.210710, [[dSt5iaGErjQnPQAxuABQs2NQiZgvZxusUPOe8nrvRtvuANuyVi7wY(rjgLOuAyKQFt42KYPvzWefdhfhuvPtjkfhdQoNOKAHsrlvvQfdXYv6HQIINs1YefpxKjQkQMQQIjtY0vCruQUhu6YGRlL2OOuTvrjYMjY2fvAAIk6Xs1NrjnpPWXfLqptvy0q6WcNek8DOORHs58ev)LIgNOcVMO0eo9HCJqdi)nOyrMSeuScr1HNLfzuGeuPlxirU33JziN83ahIeqgz0XZRNZmpSzWZjB4zn5od0VGFz5yorrgSLdCY)2Ntuj6dzGtFiN9kq4GIAsUrObK7IwolY8mXMlSK)g4qKaYiJo(l88w9h4KJrPUEmIL8sua5EFpMHCil2EmmGYgC1gD0ZeZyr4Hcs)OqWhuldSDOMgyZZ2psRKKnjA5MsBWQgutYMMOllw9FfG0kjzLoyLBISrPSlOfxLWQt(xKJFJCYtIwUzp2CHLgYid9HC2RaHdkQj5gHgq(ZbnrXImoZjlKi)nWHibKrgD8x45T6pWjhJsD9yel5LOaY9(Emd5D0yzfsMsB0Ntub)jS428S9J0kjzvGMOmtmNSqYUGwCvcR(VcqALKSshSYnr2Ou2f0IRsy1)zIRS92DHAEcBg9Fui4dQLb2outdS5GnY)IC8BKtUc0eLzI5Kfs0qgpOpKZEfiCqrnj3i0aYZ(bRCwKP5gLI83ahIeqgz0XFHN3Q)aNCmk11JrSKxIci377XmKJcbFqTmW2HAAGnhS9J0kjzvGMOmtmNSqYQeyw)iTsswnycnXYGksxYQeyw)iTss2KOLBIe7EWAvcmR)UqWvcmlRc0eLzI5Kfs2oASScPg4K)f543iNCPdw5MiBukAiJCsFiN9kq4GIAsU33Jzihfc(GAzGTd10alBS9pbhQXkbCtfKBKMyorzHkq4G6NjUY2B3fQ5jSp0j)nWHibKrgD8x45T6pWjhJsD9yel5LOaY)IC8BKtUeWnvqUrAI5ef5gHgqE2bolY8Ci3inXCIIgYGn6d5SxbchuutYncnG8SamHMyzqfPlr(BGdrciJm64VWZB1FGtogL66XiwYlrbK799ygYrHGpOwgy7qnnW23BUEWnh0fsOcUkRYQSffc(GAzGTd10aBo1)zIRS92DHAAGnJ(Fxi4kbMLv6GvUjYgLYUGwCv6j9FfG0kjzLoyLBISrPSkbM1psRKKvbAIYmXCYcjRsGz93fcUsGzzvGMOmtmNSqY2rJLvizkTrForf8g6w2YgY)IC8BKtUgmHMyzqfPlrdz8I(qo7vGWbf1KCVVhZqoke8b1YaBhQPbwvuScR5GUqcvWvK)g4qKaYiJo(l88w9h4KJrPUEmIL8sua5Fro(nYjpjA5MiXUhSKBeAa5UOLZImnJDpyPHmYtFiN9kq4GIAsU33Jzihfc(GAzGTd10aRkkwH1CqxiHk4QFM4kBVDxOMNW(sN83ahIeqgz0XFHN3Q)aNCmk11JrSKxIci)lYXVro5jrl3SZHixGCJqdi3fTCwK5z4qKlqdzKd6d5SxbchuutY9(Emd5OqWhuldSDOMgyvrXkSMd6cjubx9J0kjzvGMOmtmNSqYQeyw)iTsswnycnXYGksxYQeyw)iTss2KOLBIe7EWAvcmlYFdCisazKrh)fEER(dCYXOuxpgXsEjkG8Vih)g5KlDWk3ezJsrUrObKN9dw5SitZnkflYKT4zdnKrwtFiN9kq4GIAsUrObKJHMMGhZjkwK5B7gK)g4qKaYiJo(l88w9h4KJrPUEmIL8sua5EFpMHCui4dQLb2outdSQOyfwZbDHeQGR(zIRSkq6638ewC2i)lYXVro5NMMGhZjkZODdAidCD6d5SxbchuutYncnG8SdCeEOaYFdCisazKrh)fEER(dCYXOuxpgXsEjkGCVVhZqoke8b1YaBhQPbwvuScR5GUqcvWv)tWHASsahHhkWcvGWb1ptCLvbsx)MNWYexzQaPRFJj)0UH8Vih)g5KlbCeEOaAidCC6d5SxbchuutYncnGChfIL83ahIeqgz0XFHN3Q)aNCmk11JrSKxIci377XmKJcbFqTmW2HAAGvffRWAoOlKqfCf5Fro(nYjpHcXsdnK)CqkA5d1KgIa]] )

    storeDefault( [[Red Vengeance: offensives]], 'actionLists', 20170522.210710, [[dOd9daGEuvQnHQSlj2gPu7JcnBsMpPQBIIIBJs7us2lYUvSFLOrbPAyu04qvrRtsL(gKYGvsgoiDquWPqrogOohQkzHsklvj1IHy5q9quu1tfTmq8Cknruv1uvctwQMUWfjL8yaxw11PGnIQkBffL2mqBxP68qYPP6ZsQ47KcnnjvDyIrJIkVgf6KKIEgPY1ifCpLYFrLdHQc)wktW0ckRe2t563xUIz)uNldWR7YvnqWpwF)wktaSdnOKY1xDXEQcIjmAM1drxbcC9AaMVOmHEaxuoFlH3gQsd8jmLmaeEBS0cQcMwqPwJGOENQrzLWEk5NFmQLRQHLPt56RUypvbXewBy0kM6GPuZP7as0WuoT5uMayhAqj6coCqbikG(XO46N1TVGLHrJBW8cr9jkGxX1)Uydj82u(iiQ35b0AQEtJtb8kU(3fBiH3Mc(SIp2ntEqfFkagW4pHXnDMmPxp68riQprb8kU(3fBiH3MYhbr9UE9coCqbikG(XO46N1TVGLHXntMOKbex5bkkb9JrXHGLPtbvbHwqPwJGOENQrzLWEk53vlxX)Vl2qcVnuU(Ql2tvqmH1ggTIPoyk1C6oGenmLtBoLja2HgugI6tuaVIR)DXgs4TP8rquVZdQ4tbWag)jmUPZKh6Ol4WbfGOa6hJIRFw3(cwggnUbZtacF)CFoRF7gmV(rmacwa9JrXHGLPxWNv8XACdct61JUGdhuaIcOFmkU(zD7lyzyCZuVEbi89Z95S(Tg3GWetuYaIR8afLGxX1)Uydj82qbvPJwqPwJGOENQrzcGDObLHO(efluh7bhsJfP8rquVZtacF)CFoRFRXni8qmacwSndkoqSuh2pHTydbGrJBWuQ50DajAykN2CkxF1f7PkiMWAdJwXuhmLjZ10iZ06oOFSLqOKbex5bkkTqDShCinwekRe2tzc1XESCvTglcfuv90ck1Aee17unktaSdnOKY1xDXEQcIjS2WOvm1btPMt3bKOHPCAZPKbex5bkkTndkoabVFmLvc7PmBgulxX8cE)ykOGs(FqXGkOAuqe]] )


    storeDefault( [[Havoc Primary]], 'displays', 20170522.210710, [[dWd4gaGEPQEjsL2fur8APkntfIzROdl5MOk54Ok(guHNPqYoPYEf7MO9tq)ujgMs14uivpNIHIsdMadhrhuQCAsogLCouLAHsPLsOAXKYYPQhsP6PGhJW6GkQjsPutfktgv10v1fvWvrQ4YqUos2iHSvfszZOY2vkFuQIpdvnncLVlfJePQLPqnAumEOsNePClkLCnkfNNu9Bvwlur62kPJvWcquKV6KIo5dV(efyHoyJqZne4lpE0ZUXgTa(sIhzNbr0BAdOnv973Z8AIwa9food6TxKV6KM42dG7chNb92lYxDstC7b4HcrH4tJ4KGQpkoX2dSQKDdXnQa8qHOq8TxKV6KM0gqFHJZGESYJh9M42dyyUgOr9emDdPnGH5A6O(lTbwlCbS4Sc8Lhp67KemNpq7cg2cVeNwp0Jfa3food6PBRjoRa6lCCg0t3wtC2YkGH5AWkpE0BsBGE16KemNpa2cR406HESakjFfr9NVtsWC(aItRh6XcquKV6KDscMZhODbdBHxbSFK6cfGDbOV2ocHc6wgcyyUgalTb4HcrHSTYJiE1jdioTEOhlGKALgXjnXjwadjAofnldJ9BE(GfOIZkGwCwbWhNvaFCw5dyyUg7f5RoPjAbWDHJZG(okFf3EGIYxy6KOaAuCCbwlC7O(lU9aAtv)(9mVMU5mAbQjjtbmxd72qCwbQjjtz)w1QNDBioRa2gXvuZpTbQztPBy3ytBGnLrPPMQxhtNefqlarr(Qt2nv4LbSp4WgepaFLHCw6y6KOavaFjXJW0jrbkn1u96bkkFXlLeL2a9Qj6KpO6JIZACGAsYuyLhp6z3yJZkGhndyFWHniEadjAofnldt0cutsMcR84rp72qCwb4HcrH4ttYxru)5nPnaqIiu1u1VE1jJZgCGJaRkzh1FXTh4lpE0l6Kp86tuGf6Gncn3qa(iUIA(DSJeauR2fkG(A7iWzHc4J4kQ5hqpIS1OZBCmE3YgXS4TnJh1oo2dNTeZMaCN8dWIjuausJqbUY7VMa1KKP6MnLUHDJnoRakItItVBnolBcq6vRLxx0jFq1hfN14aKEeXTQvFh7iba1QDHcOV2ocCwOaspI4w1QpGI4KazrOK4JZMaRfUDdXThG0RwlVonItcQ(O4eBpWxE8ONDBiAb4HcrH6Mk8YvK8dqeqC0evguCJ3TWXUyJhfozSLy2yX7a4UWXzqpnjFfr9N3e3Ea9food6Pj5RiQ)8M42d8Lhp6fDYpalMqbqjncf4kV)AcG7chNb9yLhp6nXThWWCnDu(IMK7IwadZ1qtYxru)5nPnG(chNb9Du(kU9a1SP0nSBdPnGH5Ay3gsBadZ10nK2ae3Qw9SBSrlqr5lGenN0SDC7bkkF1jjyoFG2fmSfEnYGiSafLVOj5omDsuankoUaRkjGf3EGV84rVOt(GQpkoRXb4Hsr07OPmWRprbQaef5RoPOt(byXekakPrOax59xtGAsYu2VvT6z3yJZkWGS0Mi(PnGrTsorDldXnoqVAIo5hGftOaOKgHcCL3FnbQjjt1nBkDd72qCwbikYxDsrN8bvFuCwJdqCRA1ZUneTagMRHUiDnLKVsI3K2agMRHDJnTbWnU9agMRbAupbth1FPnqnjzkG5Ay3yJZkapuikeFrN8bvFuCwJd0RMOt(WRprbwOd2i0Cdb4HcrH4t3wtAd4Qvua6RTJqOawVAT86bkkFrhP6dqolDKpFc]] )

    storeDefault( [[Havoc AOE]], 'displays', 20170522.210710, [[dSJYgaGEPuVKqXUuvj9AfHzkLy2kCtuihwY3iu64OO2jL2Ry3eTFuv)uQAyQk)wLNHcyOOYGrvgoIoiv8zeCmQ05uevluvAPeQwmsTCQ6HuONcEmuTouGMOIitfktMqMUsxuQCvuqxgY1rYgPGTQQsSzc2UQ4JsjDAsMMQk(UumsuKLPinAuA8QQ6Ki0TuvPUgkuNNIEoPwRIOCBf1XnybWlYvDsdNCH1CGc0ZqSwiA7cSLNaA5E4cDaFjjGmYIWNiVbyMcrHCgkcYzKCdGhWSxqqJwJf5QoPo2Va)7fe0O1yrUQtQJ9laPxnxEtI4NeuTrX(ZxGzL0PlwgiaZuikKiJf5QoPoVbm7fe0OfR8eqRo2VaA2RbAuloRtxOdOzVghQ9cDG56pGfRBGT8eqRJeN98bE7XW6zK4eBLjSaMX(7PUFbeo5gGdJppOKA(8SL3Fnb0Sxdw5jGwDEdmbTJeN98bW65eNyRmHfqjfPWR98osC2ZhqCITYewa8ICvN0rIZE(aV9yy9mkGXJ0KppSlat1ZHZNNtFxan71ay5naZuik0KuEe(QozaXj2ktybKuZeXpPo2FcOjrJHHrPznEJZhSavSUb8X6gGqSUbOJ1nBan71ySix1j1HoW)EbbnADO8vSFbkkFHzsIcqtjieyU(7qTxSFbOhQ2TBDCnoJrOduds2cyVgUNUyDduds2Y4ntxl3txSUbMesOOgBOduJMYuZ9WL3apkTIwnuRjMjjkaDa8ICvN0zOiidySZI1jEarkn5OmXmjrbWd4ljbeMjjkqrRgQ1mqr5lgPKO8gycAdNCbvBuSUtduds2cR8eql3dxSUb8OraJDwSoXdOjrJHHrPzdDGAqYwyLNaA5E6I1naZuikKiIsrk8ApVoVbaseUQgQ21QozSmwSInGTMrbyQEoC(8C67cSLNaAnCYfwZbkqpdXAHOTlGiKqrnwhUwcaQzJ85Xu9C4miFEIqcf1ydmbTHtUWAoqb6ziwleTDb(3liOrRyE1X6gOgKSLZOPm1CpCX6gOgKSfWEnCpCX6gG0RMlVPHtUGQnkw3Pbi9i8BMUwhUwcaQzJ85Xu9C4miFEKEe(ntxBan71anQfN1HAV8gyU(70f7xG)X(fylpb0Y90f6aA2RH7HlVbehnqLgf70pxX(9Zug4xN6(dJDN8aA2RrmitALuKssqN3a43mDTCpDHoaErUQtA4KlOAJI1DAGAqYwoJMYuZ90fRBGjOnCYnahgFEqj185zlV)AcOzVgIsrk8ApVoVbm7fe0O1HYxX(fOgnLPM7PlVb0SxJtxOdOzVgUNU8ga)MPRL7Hl0bQbjBz8MPRL7Hlw3afLVCK4SNpWBpgwpJAPZawaMPu4t8lknSMdua6aZkjGf7xGT8eqRHtUGQnkw3PbkkFrukCyMKOa0uccbWlYvDsdNCdWHXNhusnFE2Y7VMafLVas0yqCsX(fOtw0dKO8gqRMjhiN(UyNgqZEnou(IOu4cDG)9ccA0IvEcOvh7xGT8eqRHtUb4W4ZdkPMppB59xtaZEbbnAjkfPWR986y)c8VxqqJwIsrk8ApVo2Va0dv72ToUMqhGzkefser8tcQ2Oy)5lGc)KazHRKeILXbu4NCYUBowxghGzkefsKHtUGQnkw3Pbm7fe0OvmV6y)TBaMPquirI5vN3aZkPd1EX(fOO8fdLQna5Omr(Sj]] )

--    storeDefault( [[Vengeance Primary]], 'displays', 20170423.214519, [[dStJgaGEQsVeQs7sbkBdkcZKQOzlv3eQIdl52kQxtvyNuSxXUr1(Hc)uHgMI8BiptbQgkkgSQudhrhuk(SQ4yuYXrPSqQQLIs1IjYYPYdvqpf8yK8CsnrfitvvnzcmDLUOu6Qqv5YQCDe2ibTvOOAZeA7qPpQaonjtdQQ(oLAKOewgkPrJuJxvYjHk3ckkxdLOZtuJdksTwOi5Bqr0Xk)auf5QqCHi(cRC)cmIVVN4mTb2Y9CldwMifWv8NBi9r5r8dWgXrCnD1dF(4BaQaYJII6BhwKRcX1Xmf41OOO(2Hf5QqCDmtbiDQ5YjJJcXbL3lg8pfywXBAJzWdWgXrCcgwKRcX1XpG8OOO(2F5EUvhZuannYgSvlfDtB8dOPr2nelk(bMRxWpgRaB5EUTHtrJCb8h))r8WoUbyXpGCmygRSete4vmtb00i7F5EUvh)aEi1WPOrUa)rg2Xnal(buCbkQArUgofnYfGDCdWIFaQICviEdNIg5c4p()J4jaqEuQQR8wRcXJHLyARaAAKn8JFa2ioIBqk3rTkepa74gGf)aCIzCuiUog8hqtE9UWEPPhI6ix(bQyScifJvGNySc4IXkBannYEyrUkexhPaVgff132q4QyMcueU6ltEbKiefdmxVAiwumtbK6kVEhOJSB69ifO6K0fqJSzW2gJvGQtsxdrZs1YGTngRad6elI(gPav3UK1myzIFaSkTss1vR8xM8cifGQixfI30vp8adBn)w2diqPj7L8xM8ciiGR4p3xM8cusQUALdueUcpk(f)aEijeXxq59IXI1avNKU(L75wgSmXyfWD9adBn)w2dOjVExyV00rkq1jPRF5EULbBBmwbyJ4iob44cuu1IC64hWuZxam)4pxXPomEZ4uZLtoWwUNBfI4lSY9lWi((EIZ0gywXBiwumtb8qsiIVWk3VaJ477jotBa2ioItaokehuEVyW)uGQtsxnD7swZGLjgRaVgff13IxFDmwbiDQ5YjleXxq59IXI1aKUJcnlvBdJNXmfqrH4ykeAoglwgyUE10gZuareFdW8X4nuCngVnLZHSdSL75wgSTrkGIcXbYIsXFIHLby)6xPVaSozHjNWV10GzfqQR86DGoYosbEnkkQVfhxGIQwKthZua5rrr9T44cuu1IC6yMcSL75wHi(gG5JXBO4AmEBkNdzh41OOO(2F5EUvhZuannYghxGIQwKth)aAAKDdHRWXfrrkq1Tlznd224hqtJSzW2g)aAAKDtB8dqHMLQLbltKcueUQHtrJCb8h))r84zRWFGIWva5174gumtbyJqr5bMR0Wk3VavGzfh(Xmfyl3ZTcr8fuEVySynqr4kCCr0xM8cirikgGQixfIleX3amFmEdfxJXBt5Ci7avNKUgIMLQLbltmwbA5Lu)ee)aA1mz)AgBJH1aYJII6BBiCvmtb8qsiIVby(y8gkUgJ3MY5q2bQojD10Tlznd22yScqvKRcXfI4lO8EXyXAak0SuTmyBJuannYgVNSKIlqXF0XpGMgzZGLj(b00iBWwTu0nelk(bQojDb0iBgSmXyfGnIJ4eieXxq59IXI1aYJII6BXRVogmZkaBehXjaV(64hqWjwe9THXZyMcueUcFC1gGSxYNlBca]] )


end

