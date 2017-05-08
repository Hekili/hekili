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
            known = function () return not talent.demon_blades.enabled end,
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
            known = function () return equipped.twinblades_of_the_deceiver end,
            usable = function () return toggle.artifact_ability end,
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
            known = function () return talent.chaos_blades.enabled end,
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
            health.current = min( health.max, health.current + ( stat.attack_power * 25 ) ) 
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

    storeDefault( [[SimC Havoc: default]], 'actionLists', 20170423.214519, [[deKmpaqiQKwKKK2esvJcQ4uqLwLqHxrLqZssIBjuAxkzyKKJHuXYespdvAAsIRHk2gs5BcvgNkOZrsToHIMhsLUhsY(qv5GQqlekvpej1fHsSrOugjvIojusZKkbUjvyNqXsfQ6PkMQKuBfvv7LYFvQbtIomXIvPhtvtgLld2mu1NPIgnQYPv1RvbMnKBlXUL63IgUkYYf8CsnDexxi2UK67uPoVkQ1tLGMpsSFsyJow12m(WFIyJnXdiq0GHjQk6eNQkQuVOJnZjW)c6DHc5Z2WWjU4S5ON8zRTQnm0XQ2gS0Yfbmd72m(WFIyJR44krqqtwnua9RxqlxeWOqXNjILU7vdfq)6vae2zku8zIyP7E1qb0VEfGI8TMpIeCcKf5lWMKB2duO4ZeXs39QHcOF9kaf5BnF0uHRnhVp6jNTPwcVCrGnyTzVxizWMoBWghjJFjGrkGnULN8TZn(mSBOa6xBdgPa2mKmakuYVGIa2Cm4uBtlfGk3Yt(25gFg2nua9RRsTGIau5koUsee0Kvdfq)6f0Yfbmku8zIyP7E1qb0VEfaHDMcfFMiw6Uxnua9RxbOiFR5JibNazr(cSj5M9afk(mrS0DVAOa6xVcqr(wZhnv4At8acenyyJM6OXXr1Hv4YHM6OQRqZWhlxo2qnpWFGJSgkqtSRnosggPa2yedtuRABWslxeWmSBZ4d)jInUIJRebbnz55jPEFrcd0lOLlcyuO4ZeXs39YZts9(IegOxbqyNPqXNjILU7LNNK69fjmqVcqr(wZhrcobYI8fytYn7bku8zIyP7E55jPEFrcd0RauKV18rtfU2C8(ONC2MAj8Yfb2G1M9EHKbB6SbBCKm(LagPa24wEY3o34ZW2Zts9(IegOTbJuaBgsgafk5xqrafkXHo4AZXGtTnTuaQClp5BNB8zy75jPEFrcd0vPwqraQCfhxjccAYYZts9(IegOxqlxeWOqXNjILU7LNNK69fjmqVcGWotHIptelD3lppj17lsyGEfGI8TMpIeCcKf5lWMKB2duO4ZeXs39YZts9(IegOxbOiFR5JMkCTjEabIgmSrtD044O6WkC5qtDu1vOz4JLlhBOMh4pWrwdfOj21ghjdJuaBmIHHRvTnyPLlcyg2Tz8H)eXgxjccAYIbLSF)cA5Iag9(mrS0DVkarkz4eVu)6vakY3A6sJE8rcNxma)7FcFCvrpoUwlHxUiy5wEY3o34ZWUHcOFnfk(mrS0DVAOa6xVcqr(wtx6Ocx6XX1Aj8Yfbl3Yt(25gFg2EEsQ3xKWanfk(mrS0DV88KuVViHb6vakY3A6sdxBoEF0toBtTeE5IaBWAZEVqYGnD2Gnosg)saJuaBoLj6BNB8zyxaIydgPa2mKmakuYVGIakuItuCT5yWP2MwkavNYe9TZn(mSlarQsTGIau5krqqtwmOK97xqlxeWO3NjILU7vbisjdN4L6xVcqr(wtxA0Jps48Ib4F)t4JRk6XX1Aj8Yfbl3Yt(25gFg2nua9RPqXNjILU7vdfq)6vakY3A6shv4spoUwlHxUiy5wEY3o34ZW2Zts9(IegOPqXNjILU7LNNK69fjmqVcqr(wtxA4At8acenyyJM6OXXr1Hv4YHM6OQRqZWhlxo2qnpWFGJSgkqtSRnosggPa2yedtfRABWslxeWmSBZ4d)jInebbnzH)dAY(IYKTGwUiGrHIgi7B2r0lYdHOQ2rp55tffkIN81WgAO8GMpQ46I4qee0KLNNK6ThbsnS(n0YfbSyWfxBoEF0toBtTeE5IaBWAZEVqYGnD2Gnosg)saJuaBUiHbBM0EWgmsbSzizauOKFbfbuOehU4AZXGtTnTuaQUiHbBM0EOk1ckcqfrqqtw4)GMSVOmzlOLlcyuOObY(MDe9I8qiQQD0tEkuep5RHn0q5bnFuX1fXHiiOjlppj1BpcKAybTCralgCX1M4beiAWWgn1rJJJQdRWLdn1rvxHMHpwUCSHAEG)ahznuGMyxBCKmmsbSXiggow12GLwUiGzy3MXh(teBQLWlxeSUiHbBM0EGE8rcNx(iHa0KyROIUC5elrqqtw4)GMSVOmzRFdTCralgrvrpoIN81WgAO8GMpQ46I4qee0KLNNK6ThbsnS(n0YfbSyWfxCT549rp5Sn1s4LlcSbRn79cjd20zd24iz8lbmsbS5uMOVDUXNH9fjmyZK2d2GrkGndjdGcL8lOiGcL4ubxBogCQTPLcq1PmrF7CJpd7lsyWMjThQsTGIauvlHxUiyDrcd2mP9a94JeohBfv0LlNyjccAYc)h0K9fLjBbTCralgrvrpoIN81WgAO8GMpQ46I4qee0KLNNK6ThbsnSGwUiGfdU4IRnXdiq0GHnAQJghhvhwHlhAQJQUcndFSC5yd18a)boYAOanXU24izyKcyJrmm0SQTblTCraZWUnJp8Ni2qee0KLNNK6ThbsnSGwUiGrp(iHZlgG)9pHVkQS549rp5Sn1s4LlcSbRn79cjd20zd24iz8lbmsbS5uMOVDUXNHTNNK6TMe(daBWifWMHKbqHs(fueqHsC4GRnhdo120sbO6uMOVDUXNHTNNK6TMe(dGQulOiavebbnz55jPE7rGudlOLlcy0Jps48Ib4F)t4RIk6DnipBd1qtwcJPxrorFqE2gQHMSegtV(MUrJHtpZM4beiAWWgn1rJJJQdRWLdn1rvxHMHpwUCSHAEG)ahznuGMyxBCKmmsbSXigM4SQTblTCraZWUnosg)saJuaBSbJuaBOoBDKcOqPdX57TbRn79cjd20zd2C8(ONC2gF26ifyxeNV3gQ5b(dCK1qbAIDTjEabIgmSrtD044O6WkC5qtDu1vOz4JLlhBCKmmsbSXigMdTQTblTCraZWUnJp8Ni24ZeXs39YjkVcA7ZeXs39kaf5BnvQS549rp5SnEbH2IN8zVrVMydwB27fsgSPZgSXrY4xcyKcyJnyKcyd1ccPq5rp5ZwHsxWRj2Cm4uBtlfGQQoFHAfkDPuN(yQqPptelD3v1M4beiAWWgn1rJJJQdRWLdn1rvxHMHpwUCSHAEG)ahznuGMyxBCKmmsbSz(c1ku6sPo9XuHsFMiw6UnIHrTvTnyPLlcyg2Tz8H)eXgIGGMSyqj73VGwUiGrprqqtwmOK973YPta5jWcA5Iag9ebbnzDrFZ24JeoVGwUiGzZX7JEYzBcr6T4jF2B0Rj2G1M9EHKbB6SbBCKm(LagPa2ydgPa2eFKwHYJEYNTcLUGxtS5yWP2MwkavvD(c1ku6sPo9XuHsguY(9v1M4beiAWWgn1rJJJQdRWLdn1rvxHMHpwUCSHAEG)ahznuGMyxBCKmmsbSz(c1ku6sPo9XuHsguY(9gXWqhvw12GLwUiGzy3MJ3h9KZ2eI0BXt(S3OxtSbRn79cjd20zd24iz8lbmsbSXgmsbSj(iTcLh9KpBfkDbVMOqjo0bxBogCQTPLcqvvNVqTcLUuQtFmvOSZqrqv1M4beiAWWgn1rJJJQdRWLdn1rvxHMHpwUCSHAEG)ahznuGMyxBCKmmsbSz(c1ku6sPo9XuHYodfbzeJydgPa2mFHAfkDPuN(yQqjdWlrqeJyga]] )

    storeDefault( [[SimC Havoc: precombat]], 'actionLists', 20170423.214519, [[dOtfcaGEkrTjkL2Lu12aYSj6Ms0Pr13qjFgf2ji7vSBvTFQqJIkYWqrJJsYJvPHsjyWujnCcDqj4uujogvvNtfwiLklvfzXeSCPSiQIEk0Ya0Zb15PcMkvLjlPPR0fPs51ufUmYdbkBKsQTsPyZuQA7a0HvCBkMgk13bWibQ8xvuJwc9mQsNKkQBrLQRjvUhLqRdOQdrjYVjD8hFbXBJlUbdEIK0atbcit)SyYM5rV)GOiD5JKB5z56hOowScw4UC9HJVa5p(c62pcsQg7cI3gxCdUkdgsQxuxU(WbliWL81HGI6Y1pOZFLFNvBbF9PGLA1MPbngkyqOXqbTGUC9dwOXao4pgYIEQY6zaMMNbprsAGPynOdGS6yAfBVDGoaEWguS3DVDbbRiD9OubKm0VriyPwHgdfuL1ZamTSbcy8f0TFeKun2feVnU4gCvgmKu)vvzvb4HT1jl50os63(kz0)CJe023t)iiPQT7iPF7RKrF(TN(rqsvxCjybbUKVoe0q7y0MyrfMdheSI01JsfqYq)gHGLA1MPbngkyqOXqblPDmAtSOcZHdEIK0atXAqhaz1X0k2E7aDa8GnOyV7E7c68x53z1wWxFkyPwHgdfmB2GqJHcICdyo6k4ga1l4D0vXgDvJWSzta]] )

    storeDefault( [[Kib: Simple]], 'actionLists', 20170423.214519, [[d0tWkaGEib6LujKDbX2OuTpQeDAqZwQ5JIQpHIs9yO62e1VPyNqzVk7gy)OKrjkzyuX4qrjNhsDysdgvmCu4qqICkrPoMeNJkHAHOklLsSyrwUKEiKaEkYYiONtKjsLGPIknzQA6cxKqToQKsxw11HK2iKO2kvsXMffBNs5JujzAOO4ZOQ8DuKNrGVriJgL6VIQtsLAtOQ6AqcDpQKkRKkPQdsj9Aib9kJ7iXan13V0imv(JCrWKRLfhckZO)ilVVk9Hj0PiYHzkoiLreJJd1gIcQb0aggkks0iR4b0aKg3Hvg3rIbAQVF8gHPYFek)MfhlOkXEKL3xL(We6uSxeH4iOmYnWdX1WuhbmGpYAc2Wa9OmVZROkXEeHxHmIrlgMWXDKyGM67hVreEfYigfAFqGKAJX3pqoqt99mN5H2heiYg5dcuLroqt99JS8(Q0hMqNI9IiehbLrUbEiUgM6iGb8ryQ8h5AoGVNb1MfhlpQxJrwtWggOhz7a(Egu786J61yXWemUJed0uF)4nIWRqgXOq7dcKmVZtATQ8DKd0uFp)4S1kFxY1HIJS8(Q0hMqNI9IiehbLrUbEiUgM6iGb8ryQ8hHYVzXHNwRkFFK1eSHb6rzENN0Av57lggZmUJed0uF)4nIWRqgXOq7dcKuBm((bYbAQVN)q7dcezvkEn3Kjpy)C(AfA7ihOP((rwEFv6dtOtXEreIJGYi3apexdtDeWa(imv(J4YUAyIfhx1k02hznbByGEuWUAykNVwH2(IHHIJ7iXan13pEJi8kKrmk0(GajZ78xrLranaKd0uF)ilVVk9Hj0PyVicXrqzKBGhIRHPocyaFeMk)rO8BwCexrLranGrwtWggOhL5D(ROYiGgWIHzFChjgOP((XBeHxHmIrJS8(Q0hMqNI9IiehbLrUbEiUgM6iGb8ryQ8hHYOwrZIJjdlob7ZIJ7UHETchznbByGEuguROZnzYd2ph2n0Rv4IHjAChjgOP((XBeHxHmIrH2hei(lBaqCKd0uF)ilVVk9Hj0PyVicXrqzKBGhIRHPocyaFeMk)rIrFwC4DvEK1eSHb6rh9ZtxLxmmM14osmqt99J3icVczeJcTpiqYaRsrEQngpYbAQVN5mplfpG2E(bxgEjxkG)q7dceC2QrkhVVA7ihOP((Shz59vPpmHof7friockJCd8qCnm1rad4JWu5pIxR(ZIJlOa8pYAc2Wa9OuR(N7va(xmmx84osmqt99J3icVczeJcTpiqYaRsrEQngpYbAQVN5mplfpG2E(bxgEjxkG)q7dceC2QrkhVVA7ihOP((Shz59vPpmHof7friockJCd8qCnm1rad4JWu5pYfUgSzXHy6NXiRjydd0J8xd25sm9ZyXWkoJ7iXan13pEJi8kKrmk0(Gaj1gJVFGCGM675xXdOTNFWLHxYLLrwEFv6dtOtXEreIJGYi3apexdtDeWa(imv(J4YUAyIfhx1k02zXjRs2JSMGnmqpkyxnmLZxRqBFXWkLXDKyGM67hVreEfYigfAFqGKAiWNNb1kAKd0uF)ilVVk9Hj0PyVicXrqzKBGhIRHPocyaFeMk)rIrFwC4DvMfNSkzpYAc2Wa9OJ(5PRYlgwr44osmqt99J3icVczeJgz59vPpmHof7friockJCd8qCnm1rad4JWu5pYkaazdBnGgWiRjydd0JuaaYg2AanGfdRiyChjgOP((XBeHxHmIrH2heiP2y89dKd0uF)ilVVk9Hj0PyVicXrqzKBGhIRHPocyaFeMk)rCzxnmXIJRAfA7S4KLWShznbByGEuWUAykNVwH2(IHvyMXDKyGM67hVreEfYigLqntge5hQSPYGTrckH4nmb4xXdOTNFWLHxYLf(ZcLcTpiqsne4ZZGAfnYbAQVNFuk0(GabNTAKYX7R2oYbAQVNFuk0(GaXFzdaIJCGM67ZEKL3xL(We6uSxeH4iOmYnWdX1WuhbmGpctL)iXOplo8UkZItwcZEK1eSHb6rh9ZtxLxmSckoUJed0uF)4nIWRqgXOeQzYGi)qLnvgSnsqjeVHja)kEaT98dUm8sUSWY1pYY7RsFycDk2lIqCeug5g4H4AyQJagWhHPYFex2vdtS44QwH2olozji7rwtWggOhfSRgMY5RvOTVyyf7J7iXan13pEJi8kKrmAKL3xL(We6uSxeH4iOmYnWdX1WuhbmGpctL)iua2QrIfhkQqu4hznbByGEeoB1iLlfvik8lgwr04osmqt99J3icVczeJgz59vPpmHof7friockJCd8qCnm1rad4JWu5pYfUSbWSLyXHhm(iRjydd0J8x2aKYtW4lgwHznUJed0uF)4nIWRqgXOq7dce)LnG8uR(lHCGM675hLcTpiqsTX47hihOP((rwEFv6dtOtXEreIJGYi3apexdtDeWa(imv(J4YUAyIfhx1k02zXjlMj7rwtWggOhfSRgMY5RvOTVyXicVczeJwSb]] )

    storeDefault( [[Kib: Complex]], 'actionLists', 20170423.214519, [[daehqaqisvTjKQ(ePkvJcPYPqk9ksiXUemmHCmLAzqPNrsnnKI6AifABsv(gP04iHkNJeQADifjZJekDpsvSpsshuQQfskEiPkzIifXfPQAJif8rsioPsYljHuDtsOyNO0sfQEkXujv2ksrQ9c(lumyQkhMYIL4Xq1KL0LvTzPYNjbJgfonIxtQsz2qUnv2TIFJQHRelxkphjtx01PkBxj13jjgpjK05rrRNesz(KO9lug2Goq8pwb9kuaH1ChefDsHMkMp9I7wqxrfK4hDJ6al2OT2iAEhf2GilhNyiIIMLe(aS0OwTG0hpj8Hc0bSBqhi(hRGEf0aIG3iljiG0VqqKKji48HYZDmotbcoiRMkb3sEdKHphewZDq0l(q55EmFkgtbcoiXp6g1bwSr7EBTHi1BibwSGoq8pwb9kObebVrwsqaj(r3OoWInA3BRnePEdYQPsWTK3az4ZbPFHGijtqCpnhVTWGtrOaH1ChefZtZXBlm4uekibw1Goq8pwb9kObewZDq0lggNkMpniREkqIF0nQdSyJ292AdrQ3GSAQeCl5nqg(Cqe8gzjbP411fCpnhVTWGtrOcT7mYqPQE2yvQeNZrvUktW90C82cdofHk0UZidLQgEs4taNHXPWuqw9ubCohv5QmkkBSG0VqqKKji4mmofMcYQNcsGLMbDG4FSc6vqdicEJSKGas)cbrsMGm3DkcfiRMkb3sEdKHphK4hDJ6al2ODVT2qK6niSM7GWE3PiuqcS0iOde)JvqVcAaH1CheA4Oy(I7rXaK4hDJ6al2ODVT2qK6niRMkb3sEdKHphebVrwsqWzynfofMUMHNe(yiv1ZoOLgPNo9td9jdDhHXzu5BmdFSc6vLk78Amd13rWjPQ6rDeTG0VqqKKjiDhHP5rXasGThOde)JvqVcAarWBKLeK0qFYWs7lw71WhRGEvPs6sd9jdoU7t65cFSc6v61V411fCC3N0Zf8wOfK4hDJ6al2ODVT2qK6niRMkb3sEdKHphK(fcIKmbz9hfENhct7z7wccR5oi00Fu4DEOy(I)SDlHey1c6aX)yf0RGgqe8gzjbHo9td9jdoU7t65cFSc6vLklEDDbh39j9CbVfAPhNH1u4u6Hgbj(r3OoWInA3BRnePEdYQPsWTK3az4ZbPFHGijtq6octXAntHdcR5oi0WrX8PXAntHdjWQ4aDG4FSc6vqdicEJSKGGZWAkCkv1ZoOLgPNU0qFYqbX5v0ZWhRGEL(0qFYGZOY3WW7WKmogfqgz9dFSc6vAPNo9td9jdoU7t65cFSc6vLklEDDbh39j9CbVfAbj(r3OoWInA3BRnePEdYQPsWTK3az4ZbPFHGijtqsgnUkyuazK1hewZDq0XOXvjMpfbzK1hsGvXd6aX)yf0RGgqe8gzjbjn0Nm0DeM38wscFcFSc6vqIF0nQdSyJ292AdrQ3GSAQeCl5nqg(Cq6xiisYeKUJW8M3ss4diSM7GqdhfZN)M3ss4dKa7oc0bI)XkOxbnGi4nYsccD6Ng6tgCC3N0Zf(yf0Rkvw866coU7t65cEl0cs8JUrDGfB0U3wBis9gKvtLGBjVbYWNds)cbrsMG051yIH3HjzCmeeIuTgbewZDqObVgZy(4DX8LmEmFRqis1Aeib29g0bI)XkOxbnGi4nYscsAOpzOEhFi4Hpwb9QsLgEswFmFUJCkvXcs8JUrDGfB0U3wBis9gKvtLGBjVbYWNds)cbrsMGCMht5MdewZDq8Z8X8P5MdsGDJf0bI)XkOxbnGi4nYscsAOpzOJ0OsmfeNxdFSc6vLkn8KS(y(Ch5uQIvPs6m8KS(y(Ch5uQQM(0qFYaodJtHbhDB9dFSc6vAbj(r3OoWInA3BRnePEdYQPsWTK3az4ZbPFHGijtqkiREmvBWpiSM7GObz1hZhnXg8djWUvd6aX)yf0RGgqe8gzjbjn0Nm0rAujMcIZRHpwb9QsLgEswFmFUJCkvXQujDgEswFmFUJCkvvtFAOpzaNHXPWGJUT(Hpwb9kTGe)OBuhyXgT7T1gIuVbz1uj4wYBGm85G0VqqKKji1BjdmuQ8VacR5oi0KBjJy(ev(xGey30mOde)JvqVcAarWBKLeK0qFYqbX5v0ZWhRGELEdpjRpMp3roLQB6Pt)0qFYGJ7(KEUWhRGEvPYIxxxWXDFspxWBHwqIF0nQdSyJ292AdrQ3GSAQeCl5nqg(Cq6xiisYeKKrJRcgfqgz9bH1CheDmACvI5trqgz9J5JUnTqcSBAe0bI)XkOxbnGi4nYscsNxJzO(ocojvvpQJaj(r3OoWInA3BRnePEdYQPsWTK3az4ZbPFHGijtq6oQGS6bH1CheA4OcYQhsGD3d0bI)XkOxbnGi4nYscsAOpzOGitftNxJz4JvqVcs8JUrDGfB0U3wBis9gKvtLGBjVbYWNds)cbrsMGCMht5MdewZDq8Z8X8P5MlMp620cjWU1c6aX)yf0RGgqe8gzjbP411fCpnhVTWGtrOcEl0tN(PH(Kbh39j9CHpwb9QsLfVUUGJ7(KEUG3IsLDEnMH67i4KuXInIwqIF0nQdSyJ292AdrQ3GSAQeCl5nqg(Cq6xiisYeeBgcdcYscFaH1ChK(Zqyqqws4dKa7wXb6aX)yf0RGgqe8gzjbjn0NmuqCEf9m8XkOxPNo9td9jdoU7t65cFSc6vLklEDDbh39j9CbVfAbj(r3OoWInA3BRnePEdYQPsWTK3az4ZbPFHGijtqsgnUkyuazK1hewZDq0XOXvjMpfbzK1pMp6WslKa7wXd6aX)yf0RGgqe8gzjbP411fCpnhVTWGtrOcvUkd90PFAOpzOGitftNxJz4JvqVsV(PH(KbCggNcdo626h(yf0R0RFAOpzOEhFi4Hpwb9kT0B4jz9X85oYPuDtV1ssNHNbBuWJqXadVdtY4yQh)K1Vf(yf0RGe)OBuhyXgT7T1gIuVbz1uj4wYBGm85G0VqqKKjiN5XuU5aH1Che)mFmFAU5I5JoS0cjWInc0bI)XkOxbnGi4nYscsXRRl4EAoEBHbNIqfQCvg6n8KS(y(Ch5uQUbj(r3OoWInA3BRnePEdYQPsWTK3az4ZbPFHGijtqsgnUkyuazK1hewZDq0XOXvjMpfbzK1pMp6utlKal2nOde)JvqVcAarWBKLee6kEDDbh39j9CbVfLk1pn0Nm44UpPNl8XkOxPvPYoVgZq9DeCsQyXgbs8JUrDGfB0U3wBis9gKvtLGBjVbYWNds)cbrsMGGZW4uyOYgrVDqyn3brVyyCQy(KSr0BhsGflwqhi(hRGEf0aIG3ilji4mSMcNsv9qZ0tN(PH(Kbh39j9CHpwb9QsLfVUUGJ7(KEUG3cTGe)OBuhyXgT7T1gIuVbz1uj4wYBGm85G0VqqKKjiDhHPyTMPWbH1CheA4Oy(0yTMPWJ5JUnTqcSyvd6aX)yf0RGgqe8gzjbPZRXmuFhbNKQQhSrGe)OBuhyXgT7T1gIuVbz1uj4wYBGm85G0VqqKKji174dfMcjpiSM7GqtUJp6DQy(0qYdjWILMbDG4FSc6vqdiSM7GOJrJRsmFkcYiRpiXp6g1bwSr7EBTHi1BqwnvcUL8gidFoicEJSKGKg6tgQ3XhmfKvpv4JvqVsV(PH(KHcIZRONHpwb9ki9leejzcsYOXvbJciJS(qcjicEJSKGaja]] )

    storeDefault( [[Red Vengeance: precombat]], 'actionLists', 20170423.214519, [[det1baGEukTlc12Kc7dkXSHCBb2PI2l1UbTFPQHHIFl0GLsdxjoiQYXizHcQLQuwmuTCs9uvltjToucFwPAQsLjtuth4IOspwHlJCyrBeLOTIsXMHITJs1hrj15LIMgusFhv40s(gbnAb5ze4KOQ(lHCnOuDpusEnQONtKXbLYw5oFUWehrYg3FMbK)gj33YgcUtjCqSOVDrtJyaEc83ieLsKNRmkHmyvXiw5)HUwa((8gGkcLCNNk35ZfM4is2H9Nza5)AVq9Trm9TSeLbK)gHOuI8CLr1qjumJaLpFOCnsqu7dJqY)dDTa895HxOc00xQ2lKOigryqzazGNRUZNlmXrKSd7pZaYNpedPHjQV9aDXj5VrikLipxzunucfZiq5ZhkxJee1(WiK8)qxla)rOuVtsyHvkFE4fQan9ligsdtKijGU4KmWtbUZNlmXrKSd7pZaYVlKoYrFlRrzXo5VrikLipxzunucfZiq5ZhkxJee1(WiK8)qxlaFFE4fQan9bH0roeTJYIDYad8)cnQevSnbve6j2XMYaB]] )

    storeDefault( [[Red Vengeance: default]], 'actionLists', 20170423.214519, [[die(laqisjAtQknksPofPsRsvK0UK0WeXXGyzcXZuLAAKs4AOcBtvvFdsmouk15qPGwNqkMhQO7PkzFKk(hkL4GQkwiKQhIsHMOQivxuvLnskPtcjTsvrIBIsr7ev9tukPHkKswQi1tPAQqkxvvKYwvfXxfsP2lYFHQbtkomLfdLhlXKf1LbBwrFMu1OfsonXRfs1SL62Oy3Q8BsgUqTCbpxHPR01rjBxK8DvrDEvH1JsbMpkv7hvAcHqJ8FNH1qMWiN3yaYtdzUAEcC6b7kq0WvtgMgREjpn0GnaIpscckjAbssfHCVeK4LCY)uwrDdcnIhHqJ8FNH1qMqNCEJbi)PnaUACrV0C1OMC1O12ya2c5SPk)elWBma5Sga(q0lnUAIpBJbi)dM0Y(G8uwqmSgih1llfBvbYp1bKNgAWgaXhjb5pck1K3iK7LGeVKR9AnCBD2gdGxc2iQkCgwd5VzaJ1CwhIEPXvt8zBmqnamMCdoFHOl7SRTwUwd3wNTXa4LGnIQcNH1qwxAj(ieAK)7mSgYe6K7LGeVKRDrP6S65RkmmQ2wrD4gRGvdaJj3GZKkhFJn5Qzykfz15fch6Yo7AVwd3wNqJ1wgQWzynK)wuQoRE(QtOXAld1aWyYn4mPYX3ytUAgMsrwDEfBYHNHPuKfVfgz1LD21ETgUToHghcSIxrDv4mSgYFlkvNvpF1j04qGv8kQRgagtUbNjvo0LD21oLfedRHkRbGpe9sJRM4Z2yGVwzLuaoCaJadDEf5BrP6S65Roe9sJRM4Z2yGAaym5gCMu5qx2zx7OaR3OQXqOa3Y5RSD6Ha(gvagrP683Is1z1ZxDcnEgszJ1wrD1aWyYn4mPYX3ytUAHvia3QZR3j6soBQYpXc8gdq(ZMS4tvapoiQGSpWnmPLvGb5PHgSbq8rsq(JGsn5nc5OEzPyRkq(PoGCEJbipABYYvZuf4QjAfevq2hC18btAzfyWwi)dM0Y(G8uwqmSgOL4FtOr(VZWAitOtUxcs8s(Q0RVHAgMWnKuWG80qd2ai(iji)rqPM8gH8pysl7dYlw34wzf1H3Yyjh1llfBvbYp1bKZBma5pDyc3qsbdYztvM3yaYtdzUAEcC6b7kq0WvtgMWnKuWGwIxli0i)3zynKj0jN3yaYDfRMRg2ydwkG80qd2ai(iji)rqPM8gHCuVSuSvfi)uhqUxcs8sESjxTWkeGB151)KVySMZ6qXQXNbtpdC7OowRe9NkhC(kkW6nQAgMsrw84Ys(hmPL9b5dfRgV0GLcOL45GqJ8FNH1qMqNCVeK4L81A426iwcYIJPyWQWzynK)MbmwZzDgmP3h1aWyYn4KJVySMZ6qXQXNbtpdC7OowReDDEHqEAObBaeFKeK)iOutEJqoQxwk2QcKFQdi)dM0Y(G8rSeKfhtXGroVXaK7XsqwUAqxXGrlX)NqJ8FNH1qMqNCVeK4L8ytUAgMsrwDEHWb5PHgSbq8rsq(JGsn5nc5OEzPyRkq(PoG8pysl7dYfggvBROoCJvWiN3yaYrLHr12kQJRMpScgTepkeAK)7mSgYe6K7LGeVKBLvsb4Wbmcm05vKVzaJ1CwhIEPXvt8zBmqnamMCdoFHqEAObBaeFKeK)iOutEJqoQxwk2QcKFQdi)dM0Y(G8HOxAC1eF2gdqoVXaK7IEP5Qrn5QrRTXa0s8SnHg5)odRHmHo5EjiXl5R1WT1j0yTLHkCgwd5VXMC1mmLIS68k2KdpdtPilElmYsEAObBaeFKeK)iOutEJqoQxwk2QcKFQdi)dM0Y(G8j0yTLbY5ngGCTcnwBzGwINnKqJ8FNH1qMqNCEJbiNToNWnKuWGCVeK4L8vPxFd1Is1z1Z3G80qd2ai(iji)rqPM8gHCuVSuSvfi)uhq(hmPL9b5fRBCRSI6WBzSKZMQmVXaKNgYC18e40d2vGOHRg1Cc3qsbdAjEKecnY)DgwdzcDY9sqIxYTYkPaC4agbgVq(Uwd3wNbRSScqfodRH83ytUAgMsrwoJn5WZWukYI3cJSKNgAWgaXhjb5pck1K3iKJ6LLITQa5N6aY)GjTSpiFgSYYkaKZBma5AnyLLvaOL4rqi0i)3zynKj0j3lbjEjpdySMZ6q0lnUAIpBJbQbGXKBW5leYtdnydG4JKG8hbLAYBeYr9YsXwvG8tDa5FWKw2hKpe9sJRM4Z2yaY5ngGCx0lnxnQjxnATngGRgTr0LwIhjcHg5)odRHmHo5EjiXl5ARLR1WT1zWklRauHZWAiZo7wzLuaoCaJadDEfr3VXMC1mmLISCgBYHNHPuKfVfgzjpn0GnaIpscYFeuQjVrih1llfBvbYp1bK)btAzFq(qXQXlnyPaY5ngGCxXQ5QHn2GLc4QrBeDPL4rEtOr(VZWAitOtUxcs8s(AnCBDcnoeyfVI6QWzynKjpn0GnaIpscYFeuQjVrih1llfBvbYp1bK)btAzFq(eACiWkEf1roVXaKRvO5Q5xGv8kQJwIhrli0i)3zynKj0j3lbjEjpLfedRHkRbGpe9sJRM4Z2yGVAxuQoRE(QYnHWzn(yds0HAjklOhg4ZGvwrDwRZlKkBZb7SBLvsb4Wbmcm05veD5(uipn0GnaIpscYFeuQjVrih1llfBvbYp1bK)btAzFqUCtiCwJp2GeDGCEJbih1BcHZAUA8nirhOL4r4GqJ8FNH1qMqNCEJbi3JcSaxnAJOl5PHgSbq8rsq(JGsn5nc5OEzPyRkq(PoGCVeK4LCTmLfedRH6ZMSYPhFQc4XbrfK9bUHjTScmi)dM0Y(G8ruGfOLwY9yOiwlSb2kQJ45GTrOLia]] )

    storeDefault( [[Red Vengeance: defensives]], 'actionLists', 20170423.214519, [[dSd4iaGErbAtq0UO02GG9Hsy2OA(Ic6MIc42KYZfzNuyVi7wY(rPmkrHAyKQXjkQVjQ8zuQgmkPHdvhuv0PefXXqX5qjIfkvAPQsTyv1Yv6HIc5Pu9yPSouIQjkkstvvYKjA6kUiu4EqPldUUu1gfLYwrjsBMeBxuYPvzzIQMMOu9DOO5jv8mvHrdP)srNecDyHRrsCEsQxts63eookrzIHErogv85GK(KBeAa5VbjBSYsHIDiQgWYzJvjOav6YcsK)g4qKaYiVoto9SZOBzi3B7HpKt(Z2CIkrVidg6f5yuXNdsQl5gHgqUl65SXAgfBwWs(BGdrciJ86miWKZQ)GHCel51IrSKxIci3B7HpKdSS(dhhK2Gl3OHEMyg7NhsiHefc(GAXHTb10bBovq(7vuSjrp3uzd21GAs20envXQJuc)EffRYbRAZ)gL0UGwCvcRo5p)h)g1KNe9CZwSzblnKrE6f5yuXNdsQl5gHgqEMcAIInwD8tvir(BGdrciJ86miWKZQ)GHCel51IrSKxIci3B7HpK3qJLDizQSrBorfCwGLXMtfK)EffRe0eLzc)ufs2f0IRsy1rkHFVIIv5GvT5FJsAxqlUkHvhjECLT1VludlWMxhjke8b1IdBdQPd2mRc5p)h)g1KlbnrzMWpvHenKXd6f5yuXNdsQl5gHgqE2oyvZgRD3OKK)g4qKaYiVodcm5S6pyihXsETyel5LOaY92E4d5OqWhuloSnOMoyZSki)9kkwjOjkZe(PkKSsbMfYFVIIvdMqtS4OI0LSsbMfYFVIInj65M)y3dwRuGzHSjeCPaZYkbnrzMWpvHKTHgl7qQdd5p)h)g1KRCWQ28VrjPHmYo9ICmQ4Zbj1LCVTh(qoke8b1IdBdQPdwvub5eCOgRcWnLqwrAI5eLfQ4Zbjs84kBRFxOgwG9Ho5VboejGmYRZGatoR(dgYrSKxlgXsEjkG8N)JFJAYvaUPeYkstmNOi3i0aYZgWzJ1mfYkstmNOOHmuHErogv85GK6sUrObKNbGj0eloQiDjYFdCisazKxNbbMCw9hmKJyjVwmIL8sua5EBp8HCui4dQfh2guthST9MRfCZbDHeQGlZWmmJrHGpOwCyBqnDWMDDK4Xv2w)UqnDWMxhzti4sbMLv5GvT5FJsAxqlUkXcDKs43ROyvoyvB(3OKwPaZc5VxrXkbnrzMWpvHKvkWSq2ecUuGzzLGMOmt4NQqY2qJLDizQSrBorf8o6wvYeYF(p(nQjxdMqtS4OI0LOHmqGErogv85GK6sU32dFihfc(GAXHTb10bRmk2H1CqxiHk4sYFdCisazKxNbbMCw9hmKJyjVwmIL8sua5p)h)g1KNe9CZFS7bl5gHgqUl65SXA3y3dwAiJC0lYXOIphKuxY92E4d5OqWhuloSnOMoyLrXoSMd6cjubxIepUY263fQHfyrqN83ahIeqg51zqGjNv)bd5iwYRfJyjVefq(Z)XVrn5jrp3SXHilGCJqdi3f9C2ynJ4qKfqdzKz6f5yuXNdsQl5EBp8HCui4dQfh2guthSYOyhwZbDHeQGlr(7vuSsqtuMj8tvizLcmlK)EffRgmHMyXrfPlzLcmlK)EffBs0Zn)XUhSwPaZI83ahIeqg51zqGjNv)bd5iwYRfJyjVefq(Z)XVrn5khSQn)BusYncnG8SDWQMnw7UrjzJ1mMjtOHmyj0lYXOIphKuxYncnGCe10e8yorXgRp73G83ahIeqg51zqGjNv)bd5iwYRfJyjVefqU32dFihfc(GAXHTb10bRmk2H1CqxiHk4sK4XvwjOCTBybwgvi)5)43OM8tttWJ5eLz0VbnKbJo9ICmQ4Zbj1LCJqdipBa)Zdjq(BGdrciJ86miWKZQ)GHCel51IrSKxIci3B7HpKJcbFqT4W2GA6Gvgf7WAoOlKqfCjYj4qnwfG)5HeSqfFoirIhxzLGY1UHfyXJRmLGY1UXKFA3q(Z)XVrn5ka)ZdjqdzWWqVihJk(CqsDj3i0aYDuiwYFdCisazKxNbbMCw9hmKJyjVwmIL8sua5EBp8HCui4dQfh2guthSYOyhwZbDHeQGlj)5)43OM8ekeln0qUJdTl4xgmMtuKHkzMHgIa]] )

    storeDefault( [[Red Vengeance: offensives]], 'actionLists', 20170423.214519, [[dKZ7daGEuvQnHI2LiBtrY(OcZMK5tkDtuiDBuANuP9ISBP2pqzuavdJu9BfEovnyfLHdQoiK0PGuogeFds1cvuTuLWIbSCOEiQk8ujpwPwhQkzIOQOPQenzrnDHlIcomXLvDDfXgjfARkszZGSDGCEq50uMgQQ8Duv1Yqv(lQmAuiEgv0jjf9AiX1qHQ7PK(mPGdPivJdfkti0sQyOfa1ZeavUc7PAXZGnBAV1WLEF(cSzdiO3Ed09uT4Ql(tU80rqxNFi6jeQQn2GhurfQ7WgTNwsUi0sQyOfa1Z0CQCf2tLgTJHb2S5yPZuT4Ql(tU80rMcb9KUteQ0SZ2wIbMQE0NQAJn4bvGl4WGKDKGSJHXLpR5FclnkowrygI6DKGUIlFqIpKWgD6TaOEM5Emu5b)7e0vC5ds8He2Ot4Zkw7x1zcxSoTNGXVdhRo1rtRwWNEiQ3rc6kU8bj(qcB0P3cG6zTAfCyqYosq2XW4YN18pHLgLvD0OcvatzbmQGSJHXbGLotb5YJwsfdTaOEMMtLRWEQ04vGnJppiXhsyJMQfxDXFYLNoYuiON0DIqLMD22smWu1J(uvBSbpOke17ibDfx(GeFiHn60Bbq9mt4I1P9em(D4y1PotWbxWHbj7ibzhdJlFwZ)ewAuCSIWu2Hb6CVpRD)kcZ8bMabLGSJHXbGLoNWNvS27yLhAA1cUGdds2rcYoggx(SM)jS0OSQRvRSdd05EFw7EhR8qdnQqfWuwaJkOR4YhK4djSrtb56KwsfdTaOEMMtLRWEQk4g2cWMnFWcqLMD22smWu1J(uT4Ql(tU80rMcb9KUteQkgzWFgDKni7ypbqfQaMYcyu5HByl4agSauvBSbpOke17i5HByl4agSaP3cG6zMYomqN79zT7DSYJjWeiOKFmrXbHfnW(o8jFiBuCSIqb5YpAjvm0cG6zAov1gBWdQOAXvx8NC5PJmfc6jDNiuPzNTTedmv9OpvOcyklGrLFmrXTfmOJPYvypv1yIcSz8HGbDmfuqvb)BtugFlHnAYLXzmekic]] )

    storeDefault( [[SimC Havoc (Demonic): normal]], 'actionLists', 20170423.214519, [[diuSzaqisrBcQ4tQQc1OevDkjyvQQIELQQGBrkSlOmmOshdQQLPQ8muyAe01eLTjv(gkY4qrDoP06uvfY8iLI7rkv7tvvDqcXcrKEiHQjQQk1fjGnQQYhjLsJuvvIojPKBQkTtsAPiINszQqv2kH0Eb)vkgSuvhwyXs6XimzQCzLntIplHgTQ40u1RjqZgv3MODd53inCe1Yf55KQPRY1LOTJs(oHY4vvL05fvwVQQeMpk1(LQmGpGhycGIkFoOcMAihyMxkEV()LblkrV(5)7jPiprH)OE9r0Km4GrY4l0hO(Hl(mHRWpgy4dMrEe(G7)lIZtrGAgtmbMieNNI0b8av8b8atauu5ZbKcMrK8KpWYFbFOdJCAKJ0Cydfv(CSzFbFOdtsLdDLsSHIkFUc4ulvuWiNg5inhMJkgcNAPIcMKkh6kLyoQyiWeP65(lhySgQ4uk5nPDPfhyI)mcbFPSMCOdQG9sDIgj1qoWatnKdmrhQ4uk596tYU0IdmsgFH(GFDTFmLHlZczK11(1kSdu0GrgyAHCEI4OjWqu0a7L6ud5adoq9dWdmbqrLphqkygrYt(al)f8Homjvo0vkXgkQ85yZ(c(qhMY4nYq)wkh2qrLpxbCYR5f8Homjvo0vkXgkQ85yZopXtKkoDT)XMnbLYDuXqySgQ4uk5nPDPfhwAYWJ0)xybCQLkkysQCORuI5OIHkGtEnVGp0HPmEJm0VLYHnuu5ZXMTszkhMBkEc)9V2)YkGtEINivC6A)RayIu9C)LdmLXBsL6pGj(Zie8LYAYHoOc2l1jAKud5adm1qoW(nEV(KuQ)agjJVqFWVU2pMYWLzHmY6A)Af2bkAWidmTqoprC0eyikAG9sDQHCGbhOYaWdmbqrLphqkygrYt(alpXtKkoDTlJ)AdXtKko9c4KVwQOGjPYHUsjwjz2S18c(qhMKkh6kLydfv(CfWjFqCEwRzOj9t)F8laMivp3F5atz8MAKsrXbM4pJqWxkRjh6GkyVuNOrsnKdmWud5a73496tAKsrXbgjJVqFWVU2pMYWLzHmY6A)Af2bkAWidmTqoprC0eyikAG9sDQHCGbhOkeWdmbqrLphqkygrYt(a7c(qhwLtPo(oSHIkFoCYR5f8Homjvo0vkXgkQ85yZUwQOGjPYHUsjwj5c4q8ePItx7FGjs1Z9xoWUNevSMI8WZAGj(Zie8LYAYHoOc2l1jAKud5adm1qoWW7jrfRxFTLhEwdmsgFH(GFDTFmLHlZczK11(1kSdu0GrgyAHCEI4OjWqu0a7L6ud5adoqndWdmbqrLphqkygrYt(atPmLdJOmLg60g8ZWjpbLYDuXqyUf3tJUyBKXstgEKU289NfjCSztqPChvmewLhU14ceXWstgEKU289NfjCfatKQN7VCGPmELhUbM4pJqWxkRjh6GkyVuNOrsnKdmWud5a734vE4gyKm(c9b)6A)ykdxMfYiRR9RvyhOObJmW0c58eXrtGHOOb2l1PgYbgCGAhGhycGIkFoGuWmIKN8bgRi5JkFyvE4wJlqedmrQEU)YbMBX90Ol2gzWe)zec(szn5qhub7L6ensQHCGbMAihy)9I7PxFtSnYGrY4l0h8RR9JPmCzwiJSU2VwHDGIgmYatlKZtehnbgIIgyVuNAihyWbQmb4bMaOOYNdifmJi5jFGr8ePItx7F4O5f8Homjvo0vkXgkQ85WrZl4dDykJ3id9BPCydfv(CGjs1Z9xoWugVjvQ)aM4pJqWxkRjh6GkyVuNOrsnKdmWud5a73496tsP(tV(5XVayKm(c9b)6A)ykdxMfYiRR9RvyhOObJmW0c58eXrtGHOOb2l1PgYbgCGkZaEGjakQ85asb7L6ensQHCGbMAihy)gVxFbsLKppfbMwiNNioAcmefnWeP65(lhykJ3Suj5ZtrGj(Zie8LYAYHoOcgjJVqFWVU2pMYWLzHmY6A)Af2bkAWidSxQtnKdm4a1wapWeafv(CaPGzejp5dS8bX5zTMHM0p9)XVaB25ZR5f8Homjvo0vkXgkQ85yZUwQOGjPYHUsjwj5c4KxZl4dDyepbvVPYd30XgkQ85yZUwQOGr8eu9MkpCthRKmB2euk3rfdHr8eu9MkpCthlnz4r6)Zax2SVivCh25LR5Ono)0gckL7OIHWiEcQEtLhUPJLMm8i9cfatKQN7VCGPuMY1qvAUN145CVlsEWe)zec(szn5qhub7L6ensQHCGbMAihy)kt561NQ0R)9SE91IZ9Ui5bJKXxOp4xx7htz4YSqgzDTFTc7afnyKbMwiNNioAcmefnWEPo1qoWGduXhxapWeafv(CaPGzejp5dmwrYhv(WQ8WTgxGigo51KGs5oQyim5UqstKFO6EDS0cxUcGjs1Z9xoWQ8WTgxGigyI)mcbFPSMCOdQG9sDIgj1qoWatnKdms5HB96)3bIyGrY4l0h8RR9JPmCzwiJSU2VwHDGIgmYatlKZtehnbgIIgyVuNAihyWbQ4JpGhycGIkFoGuWmIKN8b2f8HoSkNsD8Dydfv(C4eeNN1AgAs)0)x7F4KxZl4dDyYq)wQHQ0CpRPip8Sg2qrLphB2AEbFOdtsLdDLsSHIkFo2SRLkkysQCORuIvsUao5dIZZAndnPF6)RDgfatKQN7VCGDpjQynf5HN1at8Nri4lL1KdDqfSxQt0iPgYbgyQHCGH3tIkwV(Alp8SwV(5XVayKm(c9b)6A)ykdxMfYiRR9RvyhOObJmW0c58eXrtGHOOb2l1PgYbgCGk(FaEGjakQ85asbZisEYhykLPCyUP4j83)ANbU)HAPIcg50ihP5Wkj)NmdMivp3F5atz8kpCdmXFgHGVuwto0bvWEPorJKAihyGPgYb2VXR8WTE9ZJFbWiz8f6d(11(XugUmlKrwx7xRWoqrdgzGPfY5jIJMadrrdSxQtnKdm4av8za4bMaOOYNdifmJi5jFGDbFOdRY9ixJszkh2qrLpho5dIZZAndnPF6)JpB2kLPCyUP4j83)ANrwbWeP65(lhyl3AQlKGj(Zie8LYAYHoOc2l1jAKud5adm1qoWei361N0fsWiz8f6d(11(XugUmlKrwx7xRWoqrdgzGPfY5jIJMadrrdSxQtnKdm4av8fc4bMaOOYNdifmJi5jFGL)c(qhMBskQPYd30XgkQ85yZwZl4dDysQCORuInuu5ZXMDTurbtsLdDLsSsYSzRuMYH5MINWFAddC)d1sffmYProsZHvs(pzMn7APIcMCxiPjYpuDVowAYWJ01MSc4OjRi5JkFyKPuUhvSrHMAQ8WTgxGigyIu9C)LdSaH8pEECEkcmXFgHGVuwto0bvWEPorJKAihyGPgYbMiiK)XZJZtrGrY4l0h8RR9JPmCzwiJSU2VwHDGIgmYatlKZtehnbgIIgyVuNAihyWbQ4Nb4bMaOOYNdifmJi5jFGDbFOdRYPuhFh2qrLpho518c(qhMm0VLAOkn3ZAkYdpRHnuu5ZXMTMxWh6WKu5qxPeBOOYNJn7APIcMKkh6kLyLKlaMivp3F5a7EsuXAkYdpRbM4pJqWxkRjh6GkyVuNOrsnKdmWud5adVNevSE91wE4zTE9Z)vamsgFH(GFDTFmLHlZczK11(1kSdu0GrgyAHCEI4OjWqu0a7L6ud5adoqf)oapWeafv(CaPGzejp5dmnVGp0Hv5EKRrPmLdBOOYNdN8bX5zTMHM0p9)XNn78AQVRPsrL6yNFj8BBesM4FCXrtwrYhv(WitPCpQyJcn1i3f4ulvuWK7cjnr(HQ71XCuXq4KpsNxjioSavS0R)0qvAUN14gX8SwcBOOYNJn7G48SwZqt6N()4xahnVGp0Hr8eu9gc(cwdBOOYNRqbWeP65(lhyl3AQlKGj(Zie8LYAYHoOc2l1jAKud5adm1qoWei361N0fYE9ZJFbWiz8f6d(11(XugUmlKrwx7xRWoqrdgzGPfY5jIJMadrrdSxQtnKdm4av8zcWdmbqrLphqkygrYt(aRwQOGj3fsAI8dv3RJ5OIHWjiopR1m0K(P)V2)atKQN7VCGDpjQynf5HN1at8Nri4lL1KdDqfSxQt0iPgYbgyQHCGH3tIkwV(Alp8SwV(5zuamsgFH(GFDTFmLHlZczK11(1kSdu0GrgyAHCEI4OjWqu0a7L6ud5adoqfFMb8atauu5ZbKcMrK8KpWYFbFOdZnjf1u5HB6ydfv(CSzR5f8Homjvo0vkXgkQ85yZUwQOGjPYHUsjwjz2Svkt5WCtXt4pTHbU)HAPIcg50ihP5Wkj)NmxahnzfjFu5dJmLY9OInk0udXtq1B0VKxWHJMSIKpQ8HrMs5EuXgfAQrUlWrtwrYhv(WitPCpQyJcn1u5HBnUarmWeP65(lhyepbvVr)sEbhyI)mcbFPSMCOdQG9sDIgj1qoWatnKdmXFcQEV(2L8coWiz8f6d(11(XugUmlKrwx7xRWoqrdgzGPfY5jIJMadrrdSxQtnKdm4av8Bb8atauu5ZbKcMrK8KpWYt8ePItx7Y4V2q8ePItxd8lGtTurbtUlK0e5hQUxhZrfdHt(APIcMKkh6kLyLKzZwZl4dDysQCORuInuu5ZvaN8bX5zTMHM0p9)XVayIu9C)LdmLXBQrkffhyI)mcbFPSMCOdQG9sDIgj1qoWatnKdSFJ3RpPrkffxV(5XVayKm(c9b)6A)ykdxMfYiRR9RvyhOObJmW0c58eXrtGHOOb2l1PgYbgCG6hUaEGjakQ85asbZisEYhyAEbFOdtsLdDLsSHIkFoCYFbFOdZnjf1u5HB6ydfv(CSzxlvuWK7cjnr(HQ71XCuXqfatKQN7VCGPmEtQu)bmXFgHGVuwto0bvWEPorJKAihyGPgYb2VX71NKs9NE9Z)vamsgFH(GFDTFmLHlZczK11(1kSdu0GrgyAHCEI4OjWqu0a7L6ud5adoq9dFapWeafv(CaPG9sDIgj1qoWatnKdS)Esk6pwVxFs93atlKZtehnbgIIgyIu9C)Ldm3KuKEt1FdmXFgHGVuwto0bvWiz8f6d(11(XugUmlKrwx7xRWoqrdgzG9sDQHCGbhO(9b4bMaOOYNdifmJi5jFGDrQ4ompQjfOIdmrQEU)Yb29KOI1uKhEwdmXFgHGVuwto0bvWEPorJKAihyGPgYbgEpjQy96RT8WZA96NxybWiz8f6d(11(XugUmlKrwx7xRWoqrdgzGPfY5jIJMadrrdSxQtnKdm4a1pgaEGjakQ85asbZisEYhyxKkUdZ51Varm2SVivChMh1KcuXbMivp3F5atz8kpCdmXFgHGVuwto0bvWEPorJKAihyGPgYb2VXR8WTE9Z)vamsgFH(GFDTFmLHlZczK11(1kSdu0GrgyAHCEI4OjWqu0a7L6ud5adoq9tiGhycGIkFoGuWmIKN8b2fPI7WCE9lqe7F8ZyZo)fPI7W8OMuGkoC08c(qhMKkh6kLydfv(CfatKQN7VCGPmEtQu)bmXFgHGVuwto0bvWEPorJKAihyGPgYb2VX71NKs9NE9ZZOayKm(c9b)6A)ykdxMfYiRR9RvyhOObJmW0c58eXrtGHOOb2l1PgYbgCG6xgGhycGIkFoGuWmIKN8b2fPI7WCE9lqe7F8ZatKQN7VCGXAOItPK3K2LwCGj(Zie8LYAYHoOc2l1jAKud5adm1qoWeDOItPK3Rpj7slUE9ZJFbWiz8f6d(11(XugUmlKrwx7xRWoqrdgzGPfY5jIJMadrrdSxQtnKdm4a1VoapWeafv(CaPGzejp5dmnVGp0Hv5uQJVdBOOYNdmrQEU)Yb29KOI1uKhEwdmXFgHGVuwto0bvWEPorJKAihyGPgYbgEpjQy96RT8WZA96NpRayKm(c9b)6A)ykdxMfYiRR9RvyhOObJmW0c58eXrtGHOOb2l1PgYbgCWbMrK8KpWGda]] )

    storeDefault( [[SimC Havoc (Demonic): default]], 'actionLists', 20170423.214519, [[diKIpaqisslsuv2ekQrjQCkrPvjs4vKGAwIQQBjszxkzyuIJrcSmkPNHsMMO4AOuBdf(MivJdc15iPwNiPMhsvDpKk7Je6GkLwiKKhIImrrIUieYgHKAKIKCsKQmtsqCtkLDcrlvuLNQyQkfTvsI9s1FvPbJehMyXQ4XKAYO6YGnJu(mLQrtIoTQETsHzd1TfA3s9BjdhcwUGNtX0rCDr02vQ(UiCEiX6jbP5dP2psAxb(M(GOwoyG7hFqkrWN5JmrLsQK9stLsUucXQFD2utLchOjjXeFYdWGyahPvlkiDlzSYAPaFgea9l4xHkKVAhj70t3NTAYxTX30rQaFtFqulhmWDu5ZOdpceFunNQebdnz1qemVzbTCWahnADvyELOxnebZBwbq4OGgTUkmVs0RgIG5nRaeLVnksKGDGSiFeUK6YFanADvyELOxnebZBwbikFBuKHLS(S984NGIp7s4Ldg8HEn)1cPc(0vd(yR4QibKse8jH8KVTFPvHBdrW8gFqkrWNHubGkfveCsWNTb7gFAjc0LqEY32V0QWTHiyEt(3fCsGovZPkrWqtwnebZBwqlhmWrJwxfMxj6vdrW8MvaeokOrRRcZRe9QHiyEZkar5BJIejyhilYhHlPU8hqJwxfMxj6vdrW8MvaIY3gfzyjRp5byqmGJAgQTMoBliodl2muBvDggoT0yX2hMuc6nSv7qeAIF8XwXrkrWhN4iT6B6dIA5GbUJkFgD4rG4JQ5uLiyOjlTsPm3dw4GzbTCWahnADvyELOxALszUhSWbZkachf0O1vH5vIEPvkL5EWchmRaeLVnksKGDGSiFeUK6YFanADvyELOxALszUhSWbZkar5BJImSK1NTNh)eu8zxcVCWGp0R5VwivWNUAWhBfxfjGuIGpjKN8T9lTkC1kLYCpyHdgFqkrWNHubGkfveCsGkLCkiRpBd2n(0seOlH8KVTFPvHRwPuM7blCWK)DbNeOt1CQsem0KLwPuM7blCWSGwoyGJgTUkmVs0lTsPm3dw4GzfaHJcA06QW8krV0kLYCpyHdMvaIY3gfjsWoqwKpcxsD5pGgTUkmVs0lTsPm3dw4GzfGO8TrrgwY6tEaged4OMHARPZ2cIZWInd1wvNHHtlnwS9HjLGEdB1oeHM4hFSvCKse8Xjosw(M(GOwoyG7OYNrhEei(OkrWqtwCiw9RxqlhmWzwxfMxj6veisSciOSmVzfGO8TH(myMwYakloq71prrwwyoNQ7s4LdgwjKN8T9lTkCBicM3GgTUkmVs0RgIG5nRaeLVn0xbwYYCov3LWlhmSsip5B7xAv4QvkL5EWchmOrRRcZRe9sRukZ9GfoywbikFBOpJS(S984NGIp7s4Ldg8HEn)1cPc(0vd(yR4QibKse8bHQWFB)sRc3iqeFqkrWNHubGkfveCsGkLCwZ6Z2GDJpTeb6qOk832V0QWncej)7cojqNQebdnzXHy1VEbTCWaNzDvyELOxrGiXkGGYY8MvaIY3g6ZGzAjdOS4aTx)efzzH5CQUlHxoyyLqEY32V0QWTHiyEdA06QW8krVAicM3Scqu(2qFfyjlZ5uDxcVCWWkH8KVTFPvHRwPuM7blCWGgTUkmVs0lTsPm3dw4GzfGO8TH(mY6tEaged4OMHARPZ2cIZWInd1wvNHHtlnwS9HjLGEdB1oeHM4hFSvCKse8XjoYm(M(GOwoyG7OYNrhEei(qem0KfTpyi3dUk(cA5GboA0gGCpvN0SipeSA5AfbTIwqJw0KFhUqdXhmkshlfohrWqtwALszUAmi7W6VqlhmWtbRS(S984NGIp7s4Ldg8HEn)1cPc(0vd(yR4QibKse85GfoC5sRbFqkrWNHubGkfveCsGkLCSY6Z2GDJpTeb6oyHdxU0Ai)7cojqhrWqtw0(GHCp4Q4lOLdg4OrBaY9uDsZI8qWQLRve0OrlAYVdxOH4dgfPJLcNJiyOjlTsPmxngKDybTCWapfSY6tEaged4OMHARPZ2cIZWInd1wvNHHtlnwS9HjLGEdB1oeHM4hFSvCKse8Xjos2(M(GOwoyG7OYNrhEei(SlHxoyyDWchUCP1aZ0sgqzPtgcqtslJf6ZIDAebdnzr7dgY9GRIV(l0Ybd8uy1cZ5en53Hl0q8bJI0XsHZrem0KLwPuMRgdYoS(l0Ybd8uWkBwF2EE8tqXNDj8Ybd(qVM)AHubF6QbFSvCvKasjc(Gqv4VTFPvH7blC4YLwd(GuIGpdPcavkQi4Kavk5YK1NTb7gFAjc0Hqv4VTFPvH7blC4YLwd5FxWjb62LWlhmSoyHdxU0AGzAjdOKwgl0Nf70icgAYI2hmK7bxfFbTCWapfwTWCort(D4cneFWOiDSu4CebdnzPvkL5QXGSdlOLdg4PGv2S(KhGbXaoQzO2A6STG4mSyZqTv1zy40sJfBFysjO3WwTdrOj(XhBfhPebFCIJKHVPpiQLdg4oQ8z0HhbIpebdnzPvkL5QXGSdlOLdg4mtlzaLfhO96NOygl(S984NGIp7s4Ldg8HEn)1cPc(0vd(yR4QibKse8bHQWFB)sRcxTsPmxdj8Ba(GuIGpdPcavkQi4Kavk5yN1NTb7gFAjc0Hqv4VTFPvHRwPuMRHe(nG8Vl4KaDebdnzPvkL5QXGSdlOLdg4mtlzaLfhO96NOyglmRAqE(f2HMSeo3SsIaZb55xyhAYs4CZ6B6Bnf21CFYdWGyah1muBnD2wqCgwSzO2Q6mmCAPXITpmPe0ByR2Hi0e)4JTIJuIGpoXrMUVPpiQLdg4oQ8XwXvrciLi4JpiLi4dtvBsgbQuSj2FTp0R5VwivWNUAWNTNh)eu8rxTjzeUrX(R9HjLGEdB1oeHM4hFYdWGyah1muBnD2wqCgwSzO2Q6mmCAPXITp2kosjc(4ehjI9n9brTCWa3rLpJo8iq8rxfMxj6LDCDe8vxfMxj6vaIY3g6S4Z2ZJFck(Ofm(kAYx9f)gIp0R5VwivWNUAWhBfxfjGuIGp(GuIGpmjymvkB1KVAQuuiVH4Z2GDJpTeb6Y38rMOsjvYEPPsjxkHy1VoBQPsrxfMxj685tEaged4OMHARPZ2cIZWInd1wvNHHtlnwS9HjLGEdB1oeHM4hFSvCKse8z(ituPKkzV0uPKlLqS6xNn1uPORcZReTtCKQ9n9brTCWa3rLpJo8iq8HiyOjloeR(1lOLdg4mtem0KfhIv)6RGaca5jWcA5GboZebdnzDWFZV0sgqzbTCWa3NTNh)eu8jKSVIM8vFXVH4d9A(Rfsf8PRg8XwXvrciLi4JpiLi4tEjBQu2QjF1uPOqEdXNTb7gFAjc0LV5JmrLsQK9stLsUucXQFD2utLchIv)685tEaged4OMHARPZ2cIZWInd1wvNHHtlnwS9HjLGEdB1oeHM4hFSvCKse8z(ituPKkzV0uPKlLqS6xNn1uPWHy1V2josfyX30he1YbdChv(S984NGIpHK9v0KV6l(neFOxZFTqQGpD1Gp2kUksaPebF8bPebFYlztLYwn5RMkffYBiuPKtbz9zBWUXNwIaD5B(ituPKkzV0uPKlLqS6xNn1uP0vik485tEaged4OMHARPZ2cIZWInd1wvNHHtlnwS9HjLGEdB1oeHM4hFSvCKse8z(ituPKkzV0uPKlLqS6xNn1uP0vikyN4eFgD4rG4JtCha]] )

    storeDefault( [[SimC Havoc (Demonic): precombat]], 'actionLists', 20170423.214519, [[dSZkcaGEIuTjQGDPiBdKMnPoSu3uP8Cu6BeYYKu7ef7vSBvTFamkazysIFt58urnuIedgGgorDqQkNsPQJjjDoqSqQuwkqAXGA5k8qa1tHESswhbYevQ0uPknzjMUkxeO60O6ze04OkSrQI2QsfBMkvBhi(lb8zc10iIVdugjrsxgz0uvTiQqNKkXTOs6AkQ7rKYHiq9AQi3MKt14ni4FdRPsGdY0kkiYvadaGsTbXwaaiq7sk75R9ccaaLh0YuW9feustnlfM6kvfvrsTWPQbrzAXBnx69XTpmZIef03642ZgVHPA8ge8VH1ujUfexdU8f8mXI10KSDC7zd6dMR5NZbLTJBFqx(cF1Nnc(2tb3SYo9GPvuWGmTIckf742h03qmBWVvK0C00fbaRhogeustnlfpHcPw0CfpKiCgkKAisGg3Dv4CqG9tlN2mqif9xGdUzfMwrbnDraW6rUWuhVbb)BynvIBbX1GlFbptSynnTmtxmWEwhasWaDTM(BQqk7fyqW24NOVH1uXHR10FtfszpFnrFdRPY(9b9bZ18Z5Gk6ALnK9BSC2Ga7NwoTzGqk6VahCZk70dMwrbdY0kk4gDTYgY(nwoBqqjn1Su8ekKArZv8qIWzOqQHibAC3vHZbD5l8vF2i4BpfCZkmTIcMlxqCn4YxWCj]] )

    storeDefault( [[SimC Havoc (Demonic): cooldown]], 'actionLists', 20170423.214519, [[da07gaqiLsvlIuvSjvkJIu6uKk3suXUqYWeQogbzziYZiutJeUMsABkvFtLQXjQ05quRJaX8ev19iqTpsv1bjGfsI8qcXevkvUiPkBus0ivkLoPKWnvHDssdvPuSucPNszQeuBvPK9c(RqgSKuhwQfJupgHjl4YqBwj(SKA0QKtRQvtG0RLKmBjUnk7gv)MQHlklxKNt00vCDsX2vk(Uq58KOwpPQ08vr7xuLbHaHbtpEtxWaqdMAZqWSNjsEvVT9gNiVQ1UDiZ5pHobjVQjCVe8yCWeflylrqLuCHUhxbjXucbMLHeFxE9TN35G6697GjaX8oxccdQcbcdME8MUGbqjWmI0NnGnEDDbPiCVe8yC5nTBV2PliFOciZ5pbfYB6cgop30PVPlivM7LNxhT4Pigo955Mo9nDbPI1)886OfpfXrgkF555Mo9nDbPI1)886OfpfrC1UmIU0buQ78C6unouZZWOXJcpMpPvDGja9x(rzWy40mpLD5YxcMixirvh(gKH8bOb7WdB1j1MHGbMAZqWoWPzEk7YLVemrXc2seQCNmP7RXZvH41DYKiRyhwYr8kyvWdprpEcmUZrWo8GAZqWGbujbcdME8MUGbqjWmI0NnGnEDDbPiCVe8yC5nTtxq(qfqMZFckK30fmCJwZYcfdNM5PSlx(sknz3w0KuMIqtkH8jFfX1bMa0F5hLbJHtZ8u2LlFjyICHevD4BqgYhGgSdpSvNuBgcgyQndb7aNM5PSlx(Y8QwRq6atuSGTeHk3jt6(A8CviEDNmjYk2HLCeVcwf8Wt0JNaJ7CeSdpO2memyavXGWGPhVPlyaucmJi9zdyJxxxqkc3lbpgxEtR2asRzzHIJmu(sQGhJFtBtm)gmc5i7rP(fsNUBA7unouZZWOXJcpQthycq)LFugmoYq5lbRcE4j6XtGXDoc2Hh2QtQndbdm1MHGPImu(sWeivlbB6unor)IGzpxqMovJd18mmA8OWJGjkwWwIqL7KjDFnEUkeVUtMezf7WsoIxbtKlKOQdFdYq(a0GD4b1MHGbdOQaegm94nDbdGsGzePpBaB866csr4Ej4X4YBA1sRzzHI4QDzeDPdOKst25jTMLfkgonZtzxU8LuAYopjCVe8yCkgonZtzxU8LuDqq1ihmeLqw)Cz(KIFEoDQghQ5zy04rHhZxW7X1PdmbO)YpkdghzO8LGjYfsu1HVbziFaAWo8WwDsTziyGP2memvKHYxMx1AfshyIIfSLiu5ozs3xJNRcXR7KjrwXoSKJ4vWQGhEIE8eyCNJGD4b1MHGbdOUccdME8MUGbqjWmI0NnGnEDDbPiCVe8yC5nT0AwwOy40mpLD5YxsPj78KW9sWJXPy40mpLD5Yxs1bbvJCWqucz9ZL6Fp(550PACOMNHrJhfEmFblejDGja9x(rzWiUAxgrx6akbtKlKOQdFdYq(a0GD4HT6KAZqWatTziyIC1UmVQvQ0bucMOybBjcvUtM09145Qq86ozsKvSdl5iEfSk4HNOhpbg35iyhEqTziyWaQ7GWGPhVPlyaucmJi9zdyJxxxqQmFENlVPLwZYcfdNM5PSlx(sQeY6Nl1pP1ZZPt14qnpdJgpk8y(IJRdmbO)YpkdwMpVZbRcE4j6XtGXDoc2Hh2QtQndbdm1MHGTn(8ohmbs1sW4ndfS(4LquSoPpGjkwWwIqL7KjDFnEUkeVUtMezf7WsoIxbtKlKOQdFdYq(a0GD4b1MHG5LquSobdmGzePpBadgaaa]] )

    storeDefault( [[SimC Havoc (Demonic): demonic]], 'actionLists', 20170423.214519, [[diKvqaqiQqBcQ0NqrPmkiXPGKwfvuLxHIkDlQGDHKHbL6yivwgu8mKY0iORjkBtI(guY4qbNtswhvuvZdfLCpuuSpQOCqcyHOipKanrQOYfrH2iuXhrrvJefLQtsiDtPYoPWsHipL0uHO2kHyVG)cHblHoSWILYJrPjtvxwzZu0NLunAPQttPxJu1Sj62OA3Q63igoKA5I8Cr10v56uPTdv9DQiJhfv05LuwpkQW8ju7xcgOdqgug)OjNhAGAe8bQA5cwOiZEGNWwOiko34K3YIQZVqr)4K3YckstUiFGbgSPdlSfIHgfDGQOhRnKwMJ4SKhmYWclqfG9SKphqgmOdqgug)OjNhycuLnzrFGIYfY9hf60qhP5P2hn58IfFHC)rXj89NlNAF0KZJkUnxttk0PHosZt5jo942CnnP4e((ZLt5jo9GkqZkTxnqXVV(mDLis7sloqfSFS03rWp((dAG2r8IejJGpqb1i4dur2xFMUYcfrAxAXbkstUiFaoLvyWkdBgeslRSctLWsW0bAzGk67TSXrsG(KFG2r8gbFGchyGbqgug)OjNhycuLnzrFGIYfY9hfNW3FUCQ9rtoVyXxi3FuMtIGh53s1O2hn58OIlkoEHC)rXj89NlNAF0KZlwmkS9rQ(YzgmIfZsispXPNc)(6Z0vIiTlT4OsJh2p3zcrf3MRPjfNW3FUCkpXPhvCrHTps1xoZGbvqfOzL2RgOMtIi5M3dQG9JL(oc(X3Fqd0oIxKize8bkOgbFGIZKfkIKBEpOin5I8b4uwHbRmSzqiTSYkmvclbthOLbQOV3Yghjb6t(bAhXBe8bkCGbnazqz8JMCEGjqv2Kf9b6fY9hvtsiE5oQ9rtopUO44fY9hfNW3FUCQ9rtoVyXnxttkoHV)C5uUOrfx2(ivF5mdgqfOzL2RgOxFI4eI6YWIFGky)yPVJGF89h0aTJ4fjsgbFGcQrWhOi3NiovOiZldl(bkstUiFaoLvyWkdBgeslRSctLWsW0bAzGk67TSXrsG(KFG2r8gbFGchyieqgug)OjNhycuLnzrFGIps2Ojhvtg(HWhp7avGMvAVAG6xC9iYDAdnOc2pw67i4hF)bnq7iErIKrWhOGAe8bQZT46luuDAdnOin5I8b4uwHbRmSzqiTSYkmvclbthOLbQOV3Yghjb6t(bAhXBe8bkCGrgGmOm(rtopWeODeVirYi4duqnc(afNjluKXKl6ZsEqf99w24ijqFYpqfOzL2RgOMtIyjx0NL8Gky)yPVJGF89h0afPjxKpaNYkmyLHndcPLvwHPsyjy6aTmq7iEJGpqHdmkbKbLXpAY5bMavztw0hOOeSNf)qSFC7YDgDOkwmkO44fY9hfNW3FUCQ9rtoVyXnxttkoHV)C5uUOrfvqfOzL2RgOMUPAiiMiU(HWkLwFKSGky)yPVJGF89h0aTJ4fjsgbFGcQrWhO44MQvOiXSqXRFfkkQuA9rYckstUiFaoLvyWkdBgeslRSctLWsW0bAzGk67TSXrsG(KFG2r8gbFGchyGfGmOm(rtopWeOkBYI(afFKSrtoQMm8dHpE2HllHi9eNEQvBiAl4uPXd7N7SmCDKLqKEItpfFxWjj09KCBovAHVgOc0Ss7vd0Mm8dHpE2bQG9JL(oc(X3Fqd0oIxKize8bkOgbFGYKm8RqrNlE2bkstUiFaoLvyWkdBgeslRSctLWsW0bAzGk67TSXrsG(KFG2r8gbFGchyWaGmOm(rtopWeOkBYI(a9c5(JQjjeVCh1(OjNh3G9S4hI9JBxUZygm4IIJxi3Fu8i)wcbXeX1pe1LHf)O2hn58If74fY9hfNW3FUCQ9rtoVyXnxttkoHV)C5uUOrfxuc2ZIFi2pUD5oJzOHkOc0Ss7vd0RprCcrDzyXpqfSFS03rWp((dAG2r8IejJGpqb1i4duK7teNkuK5LHf)kuef6qfuKMCr(aCkRWGvg2miKwwzfMkHLGPd0Yav03BzJJKa9j)aTJ4nc(afoWOcqgug)OjNhycuLnzrFGgSNf)qSFC7YDgDIf7yZ10KYpo5TSigZ5T3ppc(UGtsO7j52Ckx0GkqZkTxnqxTHOTGdQG9JL(oc(X3Fqd0oIxKize8bkOgbFGYyTvOitl4GI0KlYhGtzfgSYWMbH0YkRWujSemDGwgOI(ElBCKeOp5hODeVrWhOWbg0HnGmOm(rtopWeOkBYI(affhVqU)O4e((ZLtTpAY5flU5AAsXj89NlNYfTyXMUPAu(zAzThZIg2m3MRPjf60qhP5PCr78yqS4MRPjfFxWjj09KCBovA8W(5mRmuX1r8rYgn5Oqtis7xhHjjHOjd)q4JNDGkqZkTxnqJ)T9wzCwYdQG9JL(oc(X3Fqd0oIxKize8bkOgbFGkW)2ERmol5bfPjxKpaNYkmyLHndcPLvwHPsyjy6aTmqf99w24ijqFYpq7iEJGpqHdmOJoazqz8JMCEGjqv2Kf9b6fY9hvtsiE5oQ9rtopUO44fY9hfpYVLqqmrC9drDzyXpQ9rtoVyXoEHC)rXj89NlNAF0KZlwCZ10KIt47pxoLlAubvGMvAVAGE9jItiQldl(bQG9JL(oc(X3Fqd0oIxKize8bkOgbFGICFI4uHImVmS4xHIOGbvqrAYf5dWPScdwzyZGqAzLvyQewcMoqldurFVLnosc0N8d0oI3i4du4ad6WaidkJF0KZdmbQYMSOpqrXXlK7pkoHV)C5u7JMCEXIBUMMuCcF)5YPCrlwSPBQgLFMww7XSOHnZT5AAsHon0rAEkx0opgqfxhXhjB0KJcnHiTFDeMKec2(GKJi)sw6hUoIps2OjhfAcrA)6imjje8DbUoIps2OjhfAcrA)6imjjenz4hcF8SdubAwP9QbkBFqYrKFjl9dub7hl9De8JV)GgODeVirYi4duqnc(avW(GKxOOEjl9duKMCr(aCkRWGvg2miKwwzfMkHLGPd0Yav03BzJJKa9j)aTJ4nc(afoWGoAaYGY4hn58atGQSjl6duhVqU)O4e((ZLtTpAY5XT5AAsX3fCscDpj3Mt5jo94IcBFKQVCMbdQGkqZkTxnqnNerYnVhub7hl9De8JV)GgODeVirYi4duqnc(afNjluej38(cfrHoubfPjxKpaNYkmyLHndcPLvwHPsyjy6aTmqf99w24ijqFYpq7iEJGpqHdmOtiGmOm(rtopWeODeVirYi4duqnc(a15gN8mB5fkYK9gOI(ElBCKeOp5hOc0Ss7vdu)4KphrZEdub7hl9De8JV)GgOin5I8b4uwHbRmSzqiTSYkmvclbthOLbAhXBe8bkCGbDzaYGY4hn58atGQSjl6d0ls13rzFeP4RpqfOzL2RgOxFI4eI6YWIFGky)yPVJGF89h0aTJ4fjsgbFGcQrWhOi3NiovOiZldl(vOik0qfuKMCr(aCkRWGvg2miKwwzfMkHLGPd0Yav03BzJJKa9j)aTJ4nc(afoWGUsazqz8JMCEGjqv2Kf9b6fP67O828lE25m6YelgLls13rzFeP4RpCD8c5(JIt47pxo1(OjNhvqfOzL2RgOMtIi5M3dQG9JL(oc(X3Fqd0oIxKize8bkOgbFGIZKfkIKBEFHIOGbvqrAYf5dWPScdwzyZGqAzLvyQewcMoqldurFVLnosc0N8d0oI3i4du4ad6Wcqgug)OjNhycuLnzrFGErQ(okVn)INDoJUmqfOzL2RgO43xFMUsePDPfhOc2pw67i4hF)bnq7iErIKrWhOGAe8bQi7RptxzHIiTlT4kuef6qfuKMCr(aCkRWGvg2miKwwzfMkHLGPd0Yav03BzJJKa9j)aTJ4nc(afo4avztw0hOWbaa]] )

    storeDefault( [[SimC Havoc: normal]], 'actionLists', 20170423.214519, [[diKPzaqisrBsvvFcQeQrjQ6usOvbvIEfuj4wKc7ckddQ4yqvTmvLNHctJGUMOSnPY3qrghkQZjLwhujK5rkf3JuQ2huPoiHyHispKq1eHkPUibSrvv(iPuAKqLeDssj3uvANK0srepLYuHQSvcP9c(RumyvrhwyXs6XimzQCzLntIplbJwQ60u1RjqZgv3MODd53inCe1Yf55KQPRY1LOTJs(oHY4HkjDErL1dvsy(Ou7xvyaFapWeafv(Cqfm1qoWmVu8hpXvgSOe4IE8ertYGdgjJVqFG6ho4Zeoc)yGHpyg5r4dUhxrCEkcuZyIjWeH48uKoGhOIpGhycGIkFoGuWmIKN8bw(l4dDyKtJCKMdBOOYNJn7l4dDysQCORuInuu5Zv8FTurbJCAKJ0CyoQyO)1sffmjvo0vkXCuXqGjs1Z9xoWynuHPuYBs7sloWeVFec(szn5qhub7L6ensQHCGbMAihyIouHPuYF8KKDPfhyKm(c9b)6A)ykdhMfYiRR9RvyhOObJmW0c58eXrtGHOOb2l1PgYbgCG6hGhycGIkFoGuWmIKN8bw(l4dDysQCORuInuu5ZXM9f8HomLXBKH(TuoSHIkFUI)ZR5f8Homjvo0vkXgkQ85yZoprFKkmDT)XMnbLYDuXqySgQWuk5nPDPfhwAYWJ0XTWI)RLkkysQCORuI5OIHk(pVMxWh6WugVrg63s5WgkQ85yZwPmLdZnfpH)WT2)Yk(pprFKkmDT)vemrQEU)YbMY4nPs9EWeVFec(szn5qhub7L6ensQHCGbMAihy)g)Xtsk17bJKXxOp4xx7htz4WSqgzDTFTc7afnyKbMwiNNioAcmefnWEPo1qoWGduza4bMaOOYNdifmJi5jFGLNOpsfMU2LbUAdrFKkm9I)ZxlvuWKu5qxPeRKmB2AEbFOdtsLdDLsSHIkFUI)ZheNN1AgAs)0Xn(fbtKQN7VCGPmEtnsPOWat8(ri4lL1KdDqfSxQt0iPgYbgyQHCG9B8hpjnsPOWaJKXxOp4xx7htz4WSqgzDTFTc7afnyKbMwiNNioAcmefnWEPo1qoWGdufc4bMaOOYNdifmJi5jFGDbFOdRYPuhFh2qrLp3)8AEbFOdtsLdDLsSHIkFo2SRLkkysQCORuIvsU4FI(ivy6A)dmrQEU)Yb21NOI1uGhEwdmX7hHGVuwto0bvWEPorJKAihyGPgYbgE9jQypEQT8WZAGrY4l0h8RR9JPmCywiJSU2VwHDGIgmYatlKZtehnbgIIgyVuNAihyWbQzaEGjakQ85asbZisEYhykLPCyeLP0qN2GF2)8euk3rfdH5wC9n6ITrglnz4r6AZhUSaHJnBckL7OIHWQ8WTgxGigwAYWJ01MpCzbcxrWeP65(lhykJx5HBGjE)ie8LYAYHoOc2l1jAKud5adm1qoW(nELhUbgjJVqFWVU2pMYWHzHmY6A)Af2bkAWidmTqoprC0eyikAG9sDQHCGbhO2b4bMaOOYNdifmJi5jFGXks(OYhwLhU14ceXatKQN7VCG5wC9n6ITrgmX7hHGVuwto0bvWEPorJKAihyGPgYbgUEX1)4Pj2gzWiz8f6d(11(XugomlKrwx7xRWoqrdgzGPfY5jIJMadrrdSxQtnKdm4avMa8atauu5ZbKcMrK8KpWi6JuHPR9V)AEbFOdtsLdDLsSHIkFU)AEbFOdtz8gzOFlLdBOOYNdmrQEU)YbMY4nPs9EWeVFec(szn5qhub7L6ensQHCGbMAihy)g)Xtsk17F8mp(fbJKXxOp4xx7htz4WSqgzDTFTc7afnyKbMwiNNioAcmefnWEPo1qoWGduzgWdmbqrLphqkyVuNOrsnKdmWud5a734pEkqQK85PiW0c58eXrtGHOObMivp3F5atz8MLkjFEkcmX7hHGVuwto0bvWiz8f6d(11(XugomlKrwx7xRWoqrdgzG9sDQHCGbhO2c4bMaOOYNdifmJi5jFGLpiopR1m0K(PJB8lYMD(8AEbFOdtsLdDLsSHIkFo2SRLkkysQCORuIvsU4)8AEbFOdJOpO6nvE4Mo2qrLphB21sffmI(GQ3u5HB6yLKzZMGs5oQyimI(GQ3u5HB6yPjdpsh3mWHn7lsf2HDE5AoAJZpTHGs5oQyimI(GQ3u5HB6yPjdpsVyrWeP65(lhykLPCnuLMRFnEo37IKhmX7hHGVuwto0bvWEPorJKAihyGPgYb2VYuUhpPkpEE97XtT4CVlsEWiz8f6d(11(XugomlKrwx7xRWoqrdgzGPfY5jIJMadrrdSxQtnKdm4av8XbWdmbqrLphqkygrYt(aJvK8rLpSkpCRXfiI9pVMeuk3rfdHj3fsAICpv3RJLw4YvemrQEU)YbwLhU14ceXat8(ri4lL1KdDqfSxQt0iPgYbgyQHCGrkpC7XtCDGigyKm(c9b)6A)ykdhMfYiRR9RvyhOObJmW0c58eXrtGHOOb2l1PgYbgCGk(4d4bMaOOYNdifmJi5jFGDbFOdRYPuhFh2qrLp3)G48SwZqt6NoU1(3)8AEbFOdtg63snuLMRFnf4HN1WgkQ85yZwZl4dDysQCORuInuu5ZXMDTurbtsLdDLsSsYf)NpiopR1m0K(PJBTZOiyIu9C)LdSRprfRPap8SgyI3pcbFPSMCOdQG9sDIgj1qoWatnKdm86tuXE8uB5HN1E8mp(fbJKXxOp4xx7htz4WSqgzDTFTc7afnyKbMwiNNioAcmefnWEPo1qoWGduX)dWdmbqrLphqkygrYt(atPmLdZnfpH)WT2zGdUqTurbJCAKJ0CyLKXLmdMivp3F5atz8kpCdmX7hHGVuwto0bvWEPorJKAihyGPgYb2VXR8WThpZJFrWiz8f6d(11(XugomlKrwx7xRWoqrdgzGPfY5jIJMadrrdSxQtnKdm4av8za4bMaOOYNdifmJi5jFGDbFOdRY9ixJszkh2qrLp3)8bX5zTMHM0pDCJpB2kLPCyUP4j8hU1oJSIGjs1Z9xoWwU1uxibt8(ri4lL1KdDqfSxQt0iPgYbgyQHCGjqU94jPlKGrY4l0h8RR9JPmCywiJSU2VwHDGIgmYatlKZtehnbgIIgyVuNAihyWbQ4leWdmbqrLphqkygrYt(al)f8Hom3KuutLhUPJnuu5ZXMTMxWh6WKu5qxPeBOOYNJn7APIcMKkh6kLyLKzZwPmLdZnfpH)0gg4GlulvuWiNg5inhwjzCjZSzxlvuWK7cjnrUNQ71XstgEKU2Kv8VMSIKpQ8HrMs5EuHgfAQPYd3ACbIyGjs1Z9xoWceY375X5PiWeVFec(szn5qhub7L6ensQHCGbMAihyIGq(EppopfbgjJVqFWVU2pMYWHzHmY6A)Af2bkAWidmTqoprC0eyikAG9sDQHCGbhOIFgGhycGIkFoGuWmIKN8b2f8HoSkNsD8Dydfv(C)ZR5f8HomzOFl1qvAU(1uGhEwdBOOYNJnBnVGp0HjPYHUsj2qrLphB21sffmjvo0vkXkjxemrQEU)Yb21NOI1uGhEwdmX7hHGVuwto0bvWEPorJKAihyGPgYbgE9jQypEQT8WZApEM)RiyKm(c9b)6A)ykdhMfYiRR9RvyhOObJmW0c58eXrtGHOOb2l1PgYbgCGk(DaEGjakQ85asbZisEYhyAEbFOdRY9ixJszkh2qrLp3)8bX5zTMHM0pDCJpB251uFxtLIk1Xo)s432iKmbUX5VMSIKpQ8HrMs5EuHgfAQrUl(xlvuWK7cjnrUNQ71XCuXq)ZhPZReehwGku617BOknx)ACJyEwlHnuu5ZXMDqCEwRzOj9th34x8VMxWh6Wi6dQEdbFbRHnuu5ZvSiyIu9C)LdSLBn1fsWeVFec(szn5qhub7L6ensQHCGbMAihycKBpEs6c5JN5XViyKm(c9b)6A)ykdhMfYiRR9RvyhOObJmW0c58eXrtGHOOb2l1PgYbgCGk(mb4bMaOOYNdifmJi5jFGvlvuWK7cjnrUNQ71XCuXq)dIZZAndnPF64w7FGjs1Z9xoWU(evSMc8WZAGjE)ie8LYAYHoOc2l1jAKud5adm1qoWWRprf7XtTLhEw7XZ8mkcgjJVqFWVU2pMYWHzHmY6A)Af2bkAWidmTqoprC0eyikAG9sDQHCGbhOIpZaEGjakQ85asbZisEYhy5VGp0H5MKIAQ8WnDSHIkFo2S18c(qhMKkh6kLydfv(CSzxlvuWKu5qxPeRKmB2kLPCyUP4j8N2WahCHAPIcg50ihP5WkjJlzU4FnzfjFu5dJmLY9Ocnk0udrFq1B0VKxW9xtwrYhv(WitPCpQqJcn1i3f)1KvK8rLpmYuk3Jk0OqtnvE4wJlqedmrQEU)YbgrFq1B0VKxWbM49JqWxkRjh6GkyVuNOrsnKdmWud5at8(GQ)4PDjVGdmsgFH(GFDTFmLHdZczK11(1kSdu0GrgyAHCEI4OjWqu0a7L6ud5adoqf)wapWeafv(CaPGzejp5dS8e9rQW01UmWvBi6JuHPRb(f)xlvuWK7cjnrUNQ71XCuXq)ZxlvuWKu5qxPeRKmB2AEbFOdtsLdDLsSHIkFUI)ZheNN1AgAs)0Xn(fbtKQN7VCGPmEtnsPOWat8(ri4lL1KdDqfSxQt0iPgYbgyQHCG9B8hpjnsPOWE8mp(fbJKXxOp4xx7htz4WSqgzDTFTc7afnyKbMwiNNioAcmefnWEPo1qoWGdu)WbWdmbqrLphqkygrYt(atZl4dDysQCORuInuu5Z9p)f8Hom3KuutLhUPJnuu5ZXMDTurbtUlK0e5EQUxhZrfdvemrQEU)YbMY4nPs9EWeVFec(szn5qhub7L6ensQHCGbMAihy)g)Xtsk17F8m)xrWiz8f6d(11(XugomlKrwx7xRWoqrdgzGPfY5jIJMadrrdSxQtnKdm4a1p8b8atauu5ZbKc2l1jAKud5adm1qoWW1tsr4I1F8Ku)nW0c58eXrtGHOObMivp3F5aZnjfP3u93at8(ri4lL1KdDqfmsgFH(GFDTFmLHdZczK11(1kSdu0GrgyVuNAihyWbQFFaEGjakQ85asbZisEYhyxKkSdZJAsbQWatKQN7VCGD9jQynf4HN1at8(ri4lL1KdDqfSxQt0iPgYbgyQHCGHxFIk2JNAlp8S2JN5fwemsgFH(GFDTFmLHdZczK11(1kSdu0GrgyAHCEI4OjWqu0a7L6ud5adoq9JbGhycGIkFoGuWmIKN8b2fPc7WCE9lqeJn7lsf2H5rnPavyGjs1Z9xoWugVYd3at8(ri4lL1KdDqfSxQt0iPgYbgyQHCG9B8kpC7XZ8FfbJKXxOp4xx7htz4WSqgzDTFTc7afnyKbMwiNNioAcmefnWEPo1qoWGdu)ec4bMaOOYNdifmJi5jFGDrQWomNx)ceXWn(zSzN)IuHDyEutkqf2FnVGp0HjPYHUsj2qrLpxrWeP65(lhykJ3Kk17bt8(ri4lL1KdDqfSxQt0iPgYbgyQHCG9B8hpjPuV)XZ8mkcgjJVqFWVU2pMYWHzHmY6A)Af2bkAWidmTqoprC0eyikAG9sDQHCGbhO(Lb4bMaOOYNdifmJi5jFGDrQWomNx)ceXWn(zGjs1Z9xoWynuHPuYBs7sloWeVFec(szn5qhub7L6ensQHCGbMAihyIouHPuYF8KKDPf3JN5XViyKm(c9b)6A)ykdhMfYiRR9RvyhOObJmW0c58eXrtGHOOb2l1PgYbgCG6xhGhycGIkFoGuWmIKN8bMMxWh6WQCk1X3Hnuu5ZbMivp3F5a76tuXAkWdpRbM49JqWxkRjh6GkyVuNOrsnKdmWud5adV(evShp1wE4zThpZNvemsgFH(GFDTFmLHdZczK11(1kSdu0GrgyAHCEI4OjWqu0a7L6ud5ado4aZisEYhyWbaa]] )

    storeDefault( [[SimC Havoc: cooldown]], 'actionLists', 20170424.002226, [[d0ZSgaGAeLA9ik0MuuTlfETqv7dPQMTiZxjDtLYYikFtvvNwLDIWEb7gL9ROyucXWuQ(nvhwYqruIbRO0WfLdQQYPekhJsDoef1crkTuIklgjlxWIquPNs6XQY6quXerustfPYKPy6sDrIuNNi5YqxNi2MQITkuzZiY2vK(SO67cPPHOQ5ru1iruWTr1OvI)sjNur4zQkDnfr3dPkhcrrEoHhIumyd0bQ0SIkHgGcuYksQKKAGwq1m8Dv6iJvFodiM8)FqLdtyjqGq2U9)DYl77qMn5N0MmdQ(cxwdkO)E95mbqhqyd0bQ0SIkHgGwq1x4YAqBpppHJN7jJhLjMhHmfPReY6Hb5o7EdKvuj0SUoTcxrLWrM7PJLBrYdwCSR11Pv4kQeoIwxFSClsEWIHCuCI11Pv4kQeoIwxFSClsEW6TuUWIkvgueBDTRqo2J(4Ov7wMdLx2KXa9h1LUwkq5yxCpKT4Itaknl4l(nFkYrwduGU5M4QarXrqbLO4iOByxCpKT4ItaQCyclbceY2T)y)FS)1g0jyM7vThaL5me0n3quCeuObczaDGknROsObOfu9fUSg02ZZt445EY4rzI5r6kHSEyqUZU3azfvcnZPKqI0GJDX9q2IloXqs2CsscsnEscbK1Yt(9yG(J6sxlfOCSlUhYwCXjaLMf8f)Mpf5iRbkq3CtCvGO4iOGsuCe0nSlUhYwCXjMz2i2XavomHLabcz72FS)p2)Ad6emZ9Q2dGYCgc6MBikock0aXxGoqLMvuj0a0cQ(cxwdA755jC8Cpz8OmX8irmiLesKgmKJItmmEu28i1RVPOfYq(Hc6Bhl28iDfYXE0hhTA3YCySyG(J6sxlfOmKJIta6emZ9Q2dGYCgc6MBIRcefhbfuIIJGsGCuCcq)fYfG2vihBRJe94hJC6kKJ9OpoA1UL5qqLdtyjqGq2U9h7)J9V2GsZc(IFZNICK1afOBUHO4iOqdeKhOduPzfvcnaTGQVWL1G2EEEchp3tgpktmpsekjKinElLlSOsLbfdjzRRusirAWXU4EiBXfNyijBD95EY4rzdo2f3dzlU4eJYq2senASciVoMqEz7RRDfYXE0hhTA3YCO807ZESyG(J6sxlfOmKJItaknl4l(nFkYrwduGU5M4QarXrqbLO4iOeihfNyMzJyhdu5WewceiKTB)X()y)RnOtWm3RApakZziOBUHO4iOqdetc0bQ0SIkHgGwq1x4YAqBpppHJN7jJhLjMhHscjsdo2f3dzlU4edjzRRp3tgpkBWXU4EiBXfNyugYwIOrJva51Xe0)Z(6AxHCSh9XrR2Tmhkp9SLfd0Fux6APa9TuUWIkvguaknl4l(nFkYrwduGU5M4QarXrqbLO4iO0SuUyMzPnvguaQCyclbceY2T)y)FS)1g0jyM7vThaL5me0n3quCeuObIpaDGknROsObOfu9fUSg02ZZt4iZ7ZzI5rOKqI0GJDX9q2IloXiG86yc6lBY11Uc5yp6JJwTBzou(V7Xa9h1LUwkqZ8(CgOtWm3RApakZziOBUjUkquCeuqjkockzX7ZzG(lKlaLvCKEKRNmwrRa5cQCyclbceY2T)y)FS)1guAwWx8B(uKJSgOaDZnefhb1tgROvaAObLO4iO6XPzMzjd1u)roZm7Z9KXJYGga]] )

    storeDefault( [[SimC Havoc: demonic]], 'actionLists', 20170423.214519, [[di0sqaqiQI2esLpHIszuqfNckAvuLkEfkQ0TOkSlKmmOWXGkTmi1ZqktJGUMOSnj8nOKXHcoNKSoQsLMhkk5EOOyFuLYbjGfII8qc0ePkvDruOncL6JOOQrIIs1jjKUPuzNuyPqKNsAQquBLqSxWFHWGLuoSWILYJrPjtLlRSzk6ZsQgTu1PP0RrQA2eDBuTBv9BedhswUipxunDvUov12HQ(ovjJhfv05LOwpkQW8ju7xImGlGmOm(rtoh0a1i4du1YfSunM9apH17wQMBCYBzbfPjxKpWang4IfgcrtJcxqvuJ1gslZrCwYdgzyHfOcWEwYNdidg4cidkJF0KZbmbQYMSOoqX5c5(JcvAOI0Cu7JMCoXIVqU)O4e((ZNtTpAY5WKUMVPjfQ0qfP5OCeVE6A(MMuCcF)5ZPCeVEqfOzL2RmO43xFM(sePDPfhOc2pw67i4hF)bnq7iorIKrWhOGAe8bQi7RptFzPAiTlT4afPjxKpa7Ik0yLHbdcPLvuHUsyby6bTmqf9Dw24ijqFYpq7ioJGpqHdmqdidkJF0KZbmbQYMSOoqX5c5(JIt47pFo1(OjNtS4lK7pkZjrWJ8BPYu7JMComPdhpVqU)O4e((ZNtTpAY5elgh2(ivF5mdAXIzjePJ41tHFF9z6lrK2LwCuPXd7N7nHysxZ30KIt47pFoLJ41JjD4W2hP6lNzqJjOc0Ss7vguZjrK8Z7bvW(XsFhb)47pObAhXjsKmc(afuJGpqXEYs1qYpVhuKMCr(aSlQqJvggmiKwwrf6kHfGPh0Yav03zzJJKa9j)aTJ4mc(afoWGgGmOm(rtohWeOkBYI6a9c5(JQjjeNCh1(OjNJoC88c5(JIt47pFo1(OjNtS4MVPjfNW3F(CkFuyshBFKQVCMbnOc0Ss7vg0Rpr8crDzyXpqfSFS03rWp((dAG2rCIejJGpqb1i4duK7teVkvJ5LHf)afPjxKpa7Ik0yLHbdcPLvuHUsyby6bTmqf9Dw24ijqFYpq7ioJGpqHdmecidkJF0KZbmbQYMSOoqXhjB0KJQjd3q4INDGkqZkTxzqDlUEe5ETHcub7hl9De8JV)GgODeNirYi4duqnc(a17xC9LQPETHcuKMCr(aSlQqJvggmiKwwrf6kHfGPh0Yav03zzJJKa9j)aTJ4mc(afoWidqgug)OjNdyc0oItKize8bkOgbFGI9KLQXyYh1zjpOI(olBCKeOp5hOc0Ss7vguZjrSKpQZsEqfSFS03rWp((dAGI0KlYhGDrfASYWGbH0YkQqxjSam9GwgODeNrWhOWbgfaYGY4hn5CatGQSjlQduCc2ZIFi2pUD5EdxmflghC88c5(JIt47pFo1(OjNtS4MVPjfNW3F(CkFuyIjOc0Ss7vgut)uzeetex)qyLsRlswqfSFS03rWp((dAG2rCIejJGpqb1i4duS9tLlvJywQ21Vs1evkTUizbfPjxKpa7Ik0yLHbdcPLvuHUsyby6bTmqf9Dw24ijqFYpq7ioJGpqHdmWcqgug)OjNdycuLnzrDGIps2OjhvtgUHWfp7OJLqKoIxp1kpeTfCQ04H9Z9wgDEYsishXRNIVl4KeQEsUnNkTWvgubAwP9kdAtgUHWfp7avW(XsFhb)47pObAhXjsKmc(afuJGpqzsgUvQM3hp7afPjxKpa7Ik0yLHbdcPLvuHUsyby6bTmqf9Dw24ijqFYpq7ioJGpqHdmyaqgug)OjNdycuLnzrDGEHC)r1KeItUJAF0KZrxWEw8dX(XTl3BmdA6WXZlK7pkEKFlHGyI46hI6YWIFu7JMCoXI98c5(JIt47pFo1(OjNtS4MVPjfNW3F(CkFuyshob7zXpe7h3UCVXm0WeubAwP9kd61NiEHOUmS4hOc2pw67i4hF)bnq7iorIKrWhOGAe8bkY9jIxLQX8YWIFLQHdUyckstUiFa2fvOXkddgeslROcDLWcW0dAzGk67SSXrsG(KFG2rCgbFGchyubidkJF0KZbmbQYMSOoqd2ZIFi2pUD5EdxXI9S5BAs5gN8wweJ5827MdbFxWjju9KCBoLpkqfOzL2RmOR8q0wWbvW(XsFhb)47pObAhXjsKmc(afuJGpqzS8kvJPfCqrAYf5dWUOcnwzyWGqAzfvORewaMEqldurFNLnosc0N8d0oIZi4du4adCXaqgug)OjNdycuLnzrDGIJNxi3FuCcF)5ZP2hn5CIf38nnP4e((ZNt5JsSyt)uzk3mTS2JzrddMBZ30KcvAOI0Cu(O8omiwCZ30KIVl4KeQEsUnNknEy)CMvgM05j(izJMCuOieP9RJWKKq0KHBiCXZoqfOzL2RmOX)2ERmol5bvW(XsFhb)47pObAhXjsKmc(afuJGpqf4FBVvgNL8GI0KlYhGDrfASYWGbH0YkQqxjSam9GwgOI(olBCKeOp5hODeNrWhOWbg4IlGmOm(rtohWeOkBYI6a9c5(JQjjeNCh1(OjNJoC88c5(JIh53siiMiU(HOUmS4h1(OjNtSypVqU)O4e((ZNtTpAY5elU5BAsXj89NpNYhfMGkqZkTxzqV(eXle1LHf)avW(XsFhb)47pObAhXjsKmc(afuJGpqrUpr8QunMxgw8RunCqJjOin5I8byxuHgRmmyqiTSIk0vclatpOLbQOVZYghjb6t(bAhXze8bkCGbUObKbLXpAY5aMavztwuhO445fY9hfNW3F(CQ9rtoNyXnFttkoHV)85u(Oel20pvMYntlR9yw0WG528nnPqLgQinhLpkVddysNN4JKnAYrHIqK2VoctscbBFqYrKFjl9JopXhjB0KJcfHiTFDeMKec(UGopXhjB0KJcfHiTFDeMKeIMmCdHlE2bQanR0ELbLTpi5iYVKL(bQG9JL(oc(X3Fqd0oItKize8bkOgbFGkyFqYlvtVKL(bkstUiFa2fvOXkddgeslROcDLWcW0dAzGk67SSXrsG(KFG2rCgbFGchyGlnazqz8JMCoGjqv2Kf1bQNxi3FuCcF)5ZP2hn5C018nnP47cojHQNKBZPCeVE6WHTps1xoZGgtqfOzL2RmOMtIi5N3dQG9JL(oc(X3Fqd0oItKize8bkOgbFGI9KLQHKFEFPA4GlMGI0KlYhGDrfASYWGbH0YkQqxjSam9GwgOI(olBCKeOp5hODeNrWhOWbg4keqgug)OjNdyc0oItKize8bkOgbFG69JtEMT8s1yYEdurFNLnosc0N8dubAwP9kdQBCYNJOzVbQG9JL(oc(X3FqduKMCr(aSlQqJvggmiKwwrf6kHfGPh0YaTJ4mc(afoWa3mazqz8JMCoGjqv2Kf1b6fP67OSpIu81hOc0Ss7vg0Rpr8crDzyXpqfSFS03rWp((dAG2rCIejJGpqb1i4duK7teVkvJ5LHf)kvdhAyckstUiFa2fvOXkddgeslROcDLWcW0dAzGk67SSXrsG(KFG2rCgbFGchyGBbGmOm(rtohWeOkBYI6a9Iu9DuoB(fp78gUzIfJZfP67OSpIu81hDEEHC)rXj89NpNAF0KZHjOc0Ss7vguZjrK8Z7bvW(XsFhb)47pObAhXjsKmc(afuJGpqXEYs1qYpVVunCqJjOin5I8byxuHgRmmyqiTSIk0vclatpOLbQOVZYghjb6t(bAhXze8bkCGbUybidkJF0KZbmbQYMSOoqVivFhLZMFXZoVHBgOc0Ss7vgu87RptFjI0U0Idub7hl9De8JV)GgODeNirYi4duqnc(avK91NPVSunK2LwCLQHdUyckstUiFa2fvOXkddgeslROcDLWcW0dAzGk67SSXrsG(KFG2rCgbFGchCGQSjlQdu4aa]] )


    storeDefault( [[Havoc Primary]], 'displays', 20170423.214519, [[dWtXgaGEPuVKKWUGQIETuKzkfA2kCyj3ePspgHBRipdQQANu1Ef7MW(Pi)ujnmf1Vv15iPQHIIbtrnCKCqPQtt0XOshhPQfkvwkjLftILtPhkL8uWYukToOQYejPYuHYKrftxLlQexfPIld56iAJOsBfQkSzu12vQ(OsHpdvMMuW3PIrssACqvjJgLgpuLtIuUfjrxtkQZtHNtQ1cvL6BkfDCdwaII6KVG7lo4mgOaR0bRrA(LaxzXHoMDMOeWwcCOwSiIMsxa6jrKO(HeNycjUaebmw551ORvrDYxOJFoaER88A01QOo5l0XphGYkNkRbnIxaY2O4ByoWKu0Vep(hGEsejItRI6KVqNUagR88A0HvwCOth)Can77aoYJGTFjDb0SVtp59PlWuHhGfVBGRS4qxVGG9Tb6wXWwPRA02qvSagHRkXxQFZTZUn3GR6BEl(pV5C4vzdnhaV4NdOzFhSYIdD60fOjLEbb7BdGTYOgTnuflGuWrsu3B7feSVnGA02qvSaef1jFrVGG9Tb6wXWwPBaGcriRHSDDYxeFZBUzan77ayPla9KisK6KweXjFra1OTHQybeKt0iEHo(gcOPqJb3rPzB9J3gSav8UbuI3naU4DdyJ3nxan770QOo5l0rjaER88A01tAR4NduK2cZGcfqHKNpWuHxp59XphqziB3EJX70pgrjqnOylG9Dy2xI3nqnOyRw)KsDm7lX7gqDi(ICCrjqnCkdnZot6cSl1sf5qEgyguOakbikQt(I(HeNiqRfp2IAb4i1uJYaZGcfGtaBjWHWmOqbkf5qEgbksBrxPaLUanPW9fhiBJI3DBGAqXwyLfh6y2zI3nGfnc0AXJTOwanfAm4oknBucudk2cRS4qhZ(s8UbONerI4qtWrsu3B1PlGVMqbuT2FctMzSYPYAe4klo0X9fhCgduGv6G1in)sGjPON8(4Nd0Kc3xCWzmqbwPdwJ08lbONerI4qJ4fGSnk(gMdudk2QF4ugAMDM4DdG3kpVgDQOthVBakRCQSgCFXbY2O4D3gGYIi(jL66zAmaiNAzYSQ1(tGFMmtzre)KsDbKeVaF))u8UnhyQWRFj(5a8V4cWGzYmucTjZ(YAFNaxzXHoM9LOeqs8cGQiKcCX3Ca1qduPrb2o7U5CdZQhF6gqziB3EJX7eLa4TYZRrhnbhjrDVvh)CaJvEEn6Oj4ijQ7T64NdCLfh64(IladMjZqj0Mm7lR9DcG3kpVgDyLfh60XphqZ(o0eCKe19wD6cOzFNEsBrtW)rjqnCkdnZ(s6cOzFhM9L0fqZ(o9lPlaXpPuhZotucuK2QxqW(2aDRyyR0TXfUybksBbuOXGM6IFoa9KsIMWhsnCgduGkWKuayXph4klo0X9fhiBJI3DBGI0w0e8pMbfkGcjpFaII6KVG7lUamyMmdLqBYSVS23jqnOyRw)KsDm7mX7gyrukdeN0fqlNOgO(1L43gWyLNxJUEsBf)CGMu4(IladMjZqj0Mm7lR9Dcudk2QF4ugAM9L4DdquuN8fCFXbY2O4D3gG4NuQJzFjkb0SVJkqgksbhPaNoDb0SVdZot6cOzFhWrEeS9K3NUa1GITa23HzNjE3a0tIirC4(IdKTrX7UnGXkpVgDQOthVkDdqpjIeXrfD60fGdIVihxptJba5ultMvT2Fc8ZKzoi(ICCbksBrhH8cqnkdKnxca]] )

--    storeDefault( [[Vengeance Primary]], 'displays', 20170423.214519, [[dStJgaGEQsVeQs7sbkBdkcZKQOzlv3eQIdl52kQxtvyNuSxXUr1(Hc)uHgMI8BiptbQgkkgSQudhrhuk(SQ4yuYXrPSqQQLIs1IjYYPYdvqpf8yK8CsnrfitvvnzcmDLUOu6Qqv5YQCDe2ibTvOOAZeA7qPpQaonjtdQQ(oLAKOewgkPrJuJxvYjHk3ckkxdLOZtuJdksTwOi5Bqr0Xk)auf5QqCHi(cRC)cmIVVN4mTb2Y9CldwMifWv8NBi9r5r8dWgXrCnD1dF(4BaQaYJII6BhwKRcX1Xmf41OOO(2Hf5QqCDmtbiDQ5YjJJcXbL3lg8pfywXBAJzWdWgXrCcgwKRcX1XpG8OOO(2F5EUvhZuannYgSvlfDtB8dOPr2nelk(bMRxWpgRaB5EUTHtrJCb8h))r8WoUbyXpGCmygRSete4vmtb00i7F5EUvh)aEi1WPOrUa)rg2Xnal(buCbkQArUgofnYfGDCdWIFaQICviEdNIg5c4p()J4jaqEuQQR8wRcXJHLyARaAAKn8JFa2ioIBqk3rTkepa74gGf)aCIzCuiUog8hqtE9UWEPPhI6ix(bQyScifJvGNySc4IXkBannYEyrUkexhPaVgff132q4QyMcueU6ltEbKiefdmxVAiwumtbK6kVEhOJSB69ifO6K0fqJSzW2gJvGQtsxdrZs1YGTngRad6elI(gPav3UK1myzIFaSkTss1vR8xM8cifGQixfI30vp8adBn)w2diqPj7L8xM8ciiGR4p3xM8cusQUALdueUcpk(f)aEijeXxq59IXI1avNKU(L75wgSmXyfWD9adBn)w2dOjVExyV00rkq1jPRF5EULbBBmwbyJ4iob44cuu1IC64hWuZxam)4pxXPomEZ4uZLtoWwUNBfI4lSY9lWi((EIZ0gywXBiwumtb8qsiIVWk3VaJ477jotBa2ioItaokehuEVyW)uGQtsxnD7swZGLjgRaVgff13IxFDmwbiDQ5YjleXxq59IXI1aKUJcnlvBdJNXmfqrH4ykeAoglwgyUE10gZuareFdW8X4nuCngVnLZHSdSL75wgSTrkGIcXbYIsXFIHLby)6xPVaSozHjNWV10GzfqQR86DGoYosbEnkkQVfhxGIQwKthZua5rrr9T44cuu1IC6yMcSL75wHi(gG5JXBO4AmEBkNdzh41OOO(2F5EUvhZuannYghxGIQwKth)aAAKDdHRWXfrrkq1Tlznd224hqtJSzW2g)aAAKDtB8dqHMLQLbltKcueUQHtrJCb8h))r84zRWFGIWva5174gumtbyJqr5bMR0Wk3VavGzfh(Xmfyl3ZTcr8fuEVySynqr4kCCr0xM8cirikgGQixfIleX3amFmEdfxJXBt5Ci7avNKUgIMLQLbltmwbA5Lu)ee)aA1mz)AgBJH1aYJII6BBiCvmtb8qsiIVby(y8gkUgJ3MY5q2bQojD10Tlznd22yScqvKRcXfI4lO8EXyXAak0SuTmyBJuannYgVNSKIlqXF0XpGMgzZGLj(b00iBWwTu0nelk(bQojDb0iBgSmXyfGnIJ4eieXxq59IXI1aYJII6BXRVogmZkaBehXjaV(64hqWjwe9THXZyMcueUcFC1gGSxYNlBca]] )


end

