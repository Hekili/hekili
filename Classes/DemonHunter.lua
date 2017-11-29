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
        addGearSet( 'tier21', 152121, 152123, 152119, 152118, 152120, 152122 )
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


    storeDefault( [[SimC Havoc: default]], 'actionLists', 20171128.104625, [[de0wpaqijklsHWMKinkurNcvyvsG8kjqzwkeDlKOQDbyyiPJrjwgQkpdPkttIkxdjkBdPQ(gQuJdjQ05KOQwNeH5jbCpuj7tc6GkulurLhIuzIsGQlQOQrkr0jrImtjQYnPuTtfSufXtLAQksBfvv7L4VanybhM0Ib5XumzQ6YQ2mL0NPugnQYPH8AfsZgXTL0Uv63IgUIYYPYZrz6qDDKY2bLVlHopsy9irfZhuTFHwSitLUNDdsjikhfJYvgOmU5w624qZWsl9KtUYUmWhvlCBXILYhGA5Su(0JBPh06LUrv6IHsQWstjIb)TQ0iyPhBWOCzYuzWImv65xfICVmN0TXHMHLUSyGZyOSyaRKVyG91ZqmGVke5(yao8yWKjXNfxG91Zqma3vpfXaC4XGjtIplUa7RNHyaUxv0YIHcJbS6SDmagvpiob9OhdWHhdMmj(S4cSVEgIb4EvrllgkmgOp1yGdPhdHiimfsdtDifICPP06rgfNoP3CV02tp)QBqRx6IkcJwBGwth4(6ziM0dA9s3409yGFLq7sp2zJj9Q1ZvrfHrRnqRPdCF9meBKWucTZvzCwgwjFXa7RNHyaFviY9WHBYK4ZIlW(6zigG7QNc4Wnzs8zXfyF9medW9QIwwHy1z7yamQEqCc6rhoCtMeFwCb2xpdXaCVQOLvi9PYH0to5k7YaFuTWTfQsp5SKMZCMmvWsthVBg1Ec71VybsA7PFqRxAbld8jtLE(vHi3lZjDBCOzyPllg4mgklgWk5lgWWttgier9Nb8vHi3hdWHhdMmj(S4cy4PjdeIO(ZaCx9uedWHhdMmj(S4cy4PjdeIO(ZaCVQOLfdfgdy1z7yamQEqCc6rpgGdpgmzs8zXfWWttgier9Nb4EvrllgkmgOp1yGdPhdHiimfsdtDifICPP06rgfNoP3CV02tp)QBqRx6IkcJwBGwthOHNMmqiI6pt6bTEPBC6EmWVsO9yGtlCi9yNnM0RwpxfvegT2aTMoqdpnzGqe1F2iHPeANRY4SmSs(Ibm80Kbcru)zaFviY9WHBYK4ZIlGHNMmqiI6pdWD1tbC4Mmj(S4cy4PjdeIO(ZaCVQOLviwD2ogaJQheNGE0Hd3KjXNfxadpnzGqe1FgG7vfTScPpvoKEYjxzxg4JQfUTqv6jNL0CMZKPcwA64DZO2tyV(flqsBp9dA9slyzGEYuPNFviY9YCs3ghAgw6YIbSs(Ib8VMlYa8vHi3hdLgdMmj(S4cupwRPBgVKHyaUxv0YIHced0pgkngSsZrbG)wrgeogkmgOh1yO0yGZyOSyaM6qke5afvegT2aTMoW91ZqSyao8yWKjXNfxG91Zqma3RkAzXqbIbluJboIHsJboJHYIbyQdPqKduury0Ad0A6an80Kbcru)zXaC4XGjtIplUagEAYaHiQ)ma3RkAzXqbIb6hdCi9yiebHPqAyQdPqKlnLwpYO40j9M7L2E65xDdA9spltcATbAnDG1JvPh06LUXP7Xa)kH2Jbo5JdPh7SXKE165AwMe0Ad0A6aRhRJeMsODUkdRKVya)R5ImaFviY9LAYK4ZIlq9yTMUz8sgIb4EvrlRa0VuR0Cua4VvKbHlKEulLZYGPoKcroqrfHrRnqRPdCF9medoCtMeFwCb2xpdXaCVQOLvalu5OuoldM6qke5afvegT2aTMoqdpnzGqe1FgC4Mmj(S4cy4PjdeIO(ZaCVQOLva6ZH0to5k7YaFuTWTfQsp5SKMZCMmvWsthVBg1Ec71VybsA7PFqRxAbldLtMk98RcrUxMt624qZWsJvYxmGvKJHbHiz6b(QqK7Jb4WJb2XGq5sJbGr3XhvWYnZedfgduJb4WJb1GrWo43xrNfdfYvmqVyOGfdCgdyL8fdy4Pjd0qUc7aiWVke5(yOGIb6fdCi9yiebHPqAyQdPqKlnLwpYO40j9M7L2E65xDdA9sdru)b96AU0dA9s3409yGFLq7XaN0JdPh7SXKE165cIO(d6118rctj0oxyL8fdyf5yyqisMEGVke5E4WzhdcLlngagDhFubl3mdC4QbJGDWVVIoRqUOxbJtSs(Ibm80KbAixHDGVke5(cIECi9KtUYUmWhvlCBHQ0tolP5mNjtfS00X7MrTNWE9lwGK2E6h06LwWYaLjtLE(vHi3lZjDBCOzyPHPoKcroaer9h0RR5XqPXaNXGvAokam0CUV4yOaXa3uwmq5JbSs(IbSICmmiejtpac8RcrUpgkOyGpQXahspgcrqykKgM6qke5stP1JmkoDsV5EPTNE(v3GwV0ZYKGwBGwthier9h0RR5spO1lDJt3Jb(vcThdCwooKESZgt6vRNRzzsqRnqRPdeIO(d6118rctj0oxWuhsHihaIO(d6118s50knhffGBkJYJvYxmGvKJHbHiz6b(QqK7li(OYH0to5k7YaFuTWTfQsp5SKMZCMmvWsthVBg1Ec71VybsA7PFqRxAbld0xMk98RcrUxMt624qZWsJvYxmGHNMmqd5kSd8vHi3hdLgdwP5OaWFRidchdfgdLJAmuAmWogJwBmGzzsaTMoqdpnzGgYvyx6XqicctH0WuhsHixAkTEKrXPt6n3lT90ZV6g06LEwMe0Ad0A6an80KbYWo0Ox6bTEPBC6EmWVsO9yGtkJdPh7SXKE165AwMe0Ad0A6an80KbYWo0OFKWucTZfwjFXagEAYanKRWoWxfICFPwP5OaWFRidcxy5Owk7ymATXaMLjb0A6an80KbAixHDPNCYv2Lb(OAHBluLEYzjnN5mzQGLMoE3mQ9e2RFXcK02t)GwV0cwg4wMk98RcrUxMt6XqicctH0MCz0QhSQ2qgPP06rgfNoP3CV02tp)QBqRxAPh06LMUCz0QpgSR2qgPNCYv2Lb(OAHBluLEYzjnN5mzQGLMoE3mQ9e2RFXcK02t)GwV0cwgOCLPsp)QqK7L5KUno0mS0Mmj(S4cyJKqkb0KjXNfxa3RkAzXaxXavPhdHiimfsBucbunyuUGeedlnLwpYO40j9M7L2E65xDdA9sl9GwV00Pesmm2Gr5gdLhIHLESZgt6vRNRr0OkDXqjvyPPeXGjtIplUJq6jNCLDzGpQw42cvPNCwsZzotMkyPPJ3nJApH96xSajT90pO1lDJQ0fdLuHLMsedMmj(S4kyzO8LPsp)QqK7L5KUno0mS0yL8fd4FnxKb4RcrUx6XqicctH0oAlOAWOCbjigwAkTEKrXPt6n3lT90ZV6g06Lw6bTEPNqBJHXgmk3yO8qmS0JD2ysVA9CnIgvPlgkPclnLig8VMlYmcPNCYv2Lb(OAHBluLEYzjnN5mzQGLMoE3mQ9e2RFXcK02t)GwV0nQsxmusfwAkrm4FnxKrWYGfQYuPNFviY9YCspgcrqykK2rBbvdgLlibXWstP1JmkoDsV5EPTNE(v3GwV0spO1l9eABmm2Gr5gdLhIHJboTWH0JD2ysVA9CnIgvPlgkPclnLig20vvYiKEYjxzxg4JQfUTqv6jNL0CMZKPcwA64DZO2tyV(flqsBp9dA9s3OkDXqjvyPPeXWMUQseSGLUGFRkncwMtWIa]] )

    storeDefault( [[SimC Havoc: precombat]], 'actionLists', 20171128.104625, [[dqZ5baGEuLAtQszxiXRPaZwIBsL(MszNszVKDJy)uLrHk0WuQ(TWqrLQbtfdNQ6GkHtHQWXuvNdvvluj1srslgPwUKEOsYtHwgf55Q0ervYuvftwftxXfPqEgQuUUQKTsbTzuj2Us0TP00qf50OmsufDzWOPOESuDsuvoSORPkvNNc16qfCiur9xujT(6ri6dDwwy8ohwqu79TnHyVY8hHcPcfiVGAM2)B))NFk7C6Zp32e2sliez2vEo8mxgDo454xHEyPZr4I(WcYvpQ91JqJijDboATWf0ScBmwOFmSGiKpYH1ZjQcjbbe6ghdZAlTGqHT0cc5EmSGiKkuG8cQzA)V93fsfUXRAhU6rJWvMHUbUXsWcKr0cDJtlTGqnQzspcnIK0f4O1cXEL5pc5SNdh9CMSaKHYbSbHRvGoQekajPlWXZ5npNjlazOCaBqyDkajPlWXZHhcxqZkSXyHwysBu9nhx2viFKdRNtufscci0nogM1wAbHcBPfe6ctAJQV54YUcPcfiVGAM2)B)DHuHB8Q2HRE0iCLzOBGBSeSazeTq340sliuJgH8c4s(QmATgja]] )

    storeDefault( [[SimC Havoc: normal]], 'actionLists', 20171128.104625, [[daKnzaqijInrq9jeHWOakNcOAvsKWRiur7cvggboMKSmj0ZqennjiUgIGTHiK(gbzCsK05qeQ1jrImpcv6EsqTpcvDqsQwiHYdjvmrcv4IKQSrjs9rjinseHOtkbUjq2jQAPKKNszQKWwjvAVQ(lcnyihw0Ib8yOAYu1Lv2SK6ZisJgbNwOxtsz2eDBQSBK(nkdNqwUGNdLPl11jLTtI(oPQoVe16LirnFe1(b9RUIBIJvNAY(IDJpD7MfD6arKitLm8sjiIYcUuEt1KlX25lkOsOQQksmNGcPIetsHUz4HOO(2n1X7iJIDfNV6kUPhnbKZFXUz4HOO(gyquNYrBorHjkdZZnAciNhIitgI6uoAZ5yUrBnh3OjGCEicCisyicqRUMtuyIYW8CEM(uisyicqRUMZXCJ2AooptF6n1bIYyx(MYrjD1AsIH1HL9TcO(iE2SWnkJUBGyEDZaF62TB8PB30DusxTMeIuToSSVPAYLy78ffujuLGBQggtlGpSR49nDimC1aXuo3O9bUbI55t3U9(8fVIB6rta58xSBgEikQVbge1PC0MZXCJ2AoUrta58qezYquNYrBU6jj6sSEHYCJMaY5HiWHiHHiWGOsGOoLJ2CoMB0wZXnAciNhIitgIadIWjKbshgevyiQierMmeHZysptFkNYrjD1AsIH1HLnxyUmsXGiXdrfceboejmebOvxZ5yUrBnhNNPpfIahIegIadIkbI6uoAZvpjrxI1luMB0eqoperMmevRfkZ5xDep2qK4lmevKeGiWHiHHiCczG0HbrfgIkEtDGOm2LVvpjXGggHBfq9r8SzHBugD3aX86Mb(0TB34t3Uv6jHivAyeUPAYLy78ffujuLGBQggtlGpSR49nDimC1aXuo3O9bUbI55t3U9(8K8kUPhnbKZFXUz4HOO(gyqeGwDnNJ5gT1CCAIGiYKHOsGOoLJ2CoMB0wZXnAciNhIahIegIs8oQCehDU4WGiXdrv3uhikJD5B1tseidHK0DRaQpINnlCJYO7giMx3mWNUD7gF62TspjejwgcjP7MQjxITZxuqLqvcUPAymTa(WUI330HWWvdet5CJ2h4giMNpD727ZxixXn9OjGC(l2ndpef136uoAZbizmVCn3OjGCEisyicmiQeiQt5OnNJ5gT1CCJMaY5HiYKHiaT6AohZnAR540ebrGdrcdr4eYaPddIkmev8M6arzSlFRjey6tKuzgvUBfq9r8SzHBugD3aX86Mb(0TB34t3UPGqGPpevOYmQC3un5sSD(IcQeQsWnvdJPfWh2v8(MoegUAGykNB0(a3aX88PB3EFEs4kUPhnbKZFXUz4HOO(wTwOmhUwimAdrIlevrcqKWqeyqeoJj9m9PC(LnbIy6VjIlmxgPyqK4crfHOsberkUhIitgIWzmPNPpLdqM(r0Nu8XfMlJumisCHOIquPaIif3drGFtDGOm2LVvpjGm97wbuFepBw4gLr3nqmVUzGpD72n(0TBLEsaz63nvtUeBNVOGkHQeCt1WyAb8HDfVVPdHHRgiMY5gTpWnqmpF62T3NNe9kUPhnbKZFXUz4HOO(MYmeta54aKPFe9jfF3uhikJD5B(LnbIy6Vj6wbuFepBw4gLr3nqmVUzGpD72n(0TBIJLnbiY0Ft0nvtUeBNVOGkHQeCt1WyAb8HDfVVPdHHRgiMY5gTpWnqmpF62T3NxOR4ME0eqo)f7MHhII6B4eYaPddIkmeveIegIkbI6uoAZ5yUrBnh3OjGCEisyiQeiQt5Onx9KeDjwVqzUrta58qKWqujqeGwDnNBD6ybreyyrmonr3uhikJD5B1tsmOHr4wbuFepBw4gLr3nqmVUzGpD72n(0TBLEsisLggbicSkWVPAYLy78ffujuLGBQggtlGpSR49nDimC1aXuo3O9bUbI55t3U9(8L6vCtpAciN)IDtDGOm2LVvpjXf0e1rg9wbuFepBw4gLr3nqmVUzGpD72n(0TBLEsisVGMOoYO3un5sSD(IcQeQsWnvdJPfWh2v8(MoegUAGykNB0(a3aX88PB3EFEs8vCtpAciN)IDZWdrr9nWGOeVJkhXrNlomis8qufeboerMmebgevce1PC0MZXCJ2AoUrta58qezYqeGwDnNJ5gT1CCAIGiWHiHHiWGOsGOoLJ2C4esggraz6hg3OjGCEiImzicqRUMdNqYWicit)W40ebrKjdr4mM0Z0NYHtizyebKPFyCH5YifdIepersbqezYquNbsxZ1r3i2mI(4GiXfIWzmPNPpLdNqYWicit)W4cZLrkgeb(n1bIYyx(wTwOmrwnXMWigLYOpdXBfq9r8SzHBugD3aX86Mb(0TB34t3UvATqziIvdrnHbrfiLrFgI3un5sSD(IcQeQsWnvdJPfWh2v8(MoegUAGykNB0(a3aX88PB3EF(kbxXn9OjGC(l2ndpef13uMHycihhGm9JOpP47M6arzSlFdqM(r0Nu8DRaQpINnlCJYO7giMx3mWNUD7gF62nXKPFqK4iP47MQjxITZxuqLqvcUPAymTa(WUI330HWWvdet5CJ2h4giMNpD727ZxvDf30JMaY5Vy3m8quuFRt5OnhGKX8Y1CJMaY5HiHHOeVJkhXrNlomis8fgIkcrcdrGbrLarDkhT5CjwVarwnXMWisQmJkh3OjGCEiImziQeiQt5OnNJ5gT1CCJMaY5HiYKHiaT6AohZnAR540ebrGdrcdrGbrjEhvoIJoxCyqK4lmersic8BQdeLXU8TMqGPprsLzu5Uva1hXZMfUrz0DdeZRBg4t3UDJpD7MccbM(quHkZOYbrGvb(nvtUeBNVOGkHQeCt1WyAb8HDfVVPdHHRgiMY5gTpWnqmpF62T3NVQ4vCtpAciN)IDZWdrr9TATqzo)QJ4XgIeFHHiskaIeNqeyqeGwDnNOWeLH550ebrcdrLkerMmevbrGFtDGOm2LVvpjGm97wbuFepBw4gLr3nqmVUzGpD72n(0TBLEsaz6hebwf43un5sSD(IcQeQsWnvdJPfWh2v8(MoegUAGykNB0(a3aX88PB3EF(ksEf30JMaY5Vy3m8quuFlX7OYrC05IddIepevbrKjdrGbrjEhvoIJoxCyqK4lmersicCiImzicmiQt5OnhGms9eR1cL5gnbKZdrcdr1AHYC(vhXJnej(cdrKKeGiWHiYKHiS1ebyunmUoUqXkIffHdrIhIeCtDGOm2LVTYJiWs3TcO(iE2SWnkJUBGyEDZaF62TB8PB30R8GiXw6UPAYLy78ffujuLGBQggtlGpSR49nDimC1aXuo3O9bUbI55t3U9(8vfYvCtpAciN)IDZWdrr9nWGOoLJ2C(5yuIaY0pmUrta58qezYqujquNYrBohZnAR54gnbKZdrKjdraA11CoMB0wZXPjcIitgIQ1cL58RoIhBisCHiskaIeNqeyqeGwDnNOWeLH550ebrcdrLkerMmejaIahIitgIa0QR5CRthliIadlIXfMlJumisCHisaIahIegIkbIuMHycihNigtgPKsSMficit)i6tk(UPoqug7Y3sknsikZoYO3kG6J4zZc3Om6UbI51nd8PB3UXNUDtDknsikZoYO3un5sSD(IcQeQsWnvdJPfWh2v8(MoegUAGykNB0(a3aX88PB3EF(ks4kUPhnbKZFXUz4HOO(wNYrBoajJ5LR5gnbKZdrcdrGbrLarDkhT5CjwVarwnXMWisQmJkh3OjGCEiImziQeiQt5OnNJ5gT1CCJMaY5HiYKHiaT6AohZnAR540ebrGdrLcikX7OYrC05IddIeFHHisEtDGOm2LV1ecm9jsQmJk3TcO(iE2SWnkJUBGyEDZaF62TB8PB3uqiW0hIkuzgvoicSIGFt1KlX25lkOsOkb3unmMwaFyxX7B6qy4QbIPCUr7dCdeZZNUD795RirVIB6rta58xSBgEikQVvce1PC0MdqYyE5AUrta58qKWqeGwDnNBD6ybreyyrmoptFkejmeL4Du5io6CXHbrIVWqejVPoqug7Y3AcbM(ejvMrL7wbuFepBw4gLr3nqmVUzGpD72n(0TBkiey6drfQmJkhebgjb)MQjxITZxuqLqvcUPAymTa(WUI330HWWvdet5CJ2h4giMNpD727Zxj0vCtpAciN)IDZWdrr9nWGOoLJ2C(5yuIaY0pmUrta58qezYqujquNYrBohZnAR54gnbKZdrKjdraA11CoMB0wZXPjcIitgIQ1cL58RoIhBisCHiskaIeNqeyqeGwDnNOWeLH550ebrcdrLkerMmejaIahIahIegIkbIuMHycihNigtgPKsSMfiItizyeX6quTbrcdrLarkZqmbKJteJjJusjwZceDRtisyiQeiszgIjGCCIymzKskXAwGiGm9JOpP47M6arzSlFdNqYWiI1HOA7wbuFepBw4gLr3nqmVUzGpD72n(0TB6qizyqK1HOA7MQjxITZxuqLqvcUPAymTa(WUI330HWWvdet5CJ2h4giMNpD727ZxvQxXn9OjGC(l2ndpef13kbI6uoAZ5yUrBnh3OjGCEisyicmiQt5OnNFogLiGm9dJB0eqoperMmebOvxZ5wNowqebgweJZZ0NcrGFtDGOm2LVvpjXGggHBfq9r8SzHBugD3aX86Mb(0TB34t3Uv6jHivAyeGiWkc(nvtUeBNVOGkHQeCt1WyAb8HDfVVPdHHRgiMY5gTpWnqmpF62T3NVIeFf30JMaY5Vy3uhikJD5B(5yumIaXE3kG6J4zZc3Om6UbI51nd8PB3UXNUDtCmhJsIadIel27MQjxITZxuqLqvcUPAymTa(WUI330HWWvdet5CJ2h4giMNpD727ZxuWvCtpAciN)IDZWdrr9TodKUMlsjgskP7M6arzSlFRjey6tKuzgvUBfq9r8SzHBugD3aX86Mb(0TB34t3UPGqGPpevOYmQCqeyfc43un5sSD(IcQeQsWnvdJPfWh2v8(MoegUAGykNB0(a3aX88PB3EF(IvxXn9OjGC(l2ndpef136mq6AoMwJf9RsWn1bIYyx(w9KaY0VBfq9r8SzHBugD3aX86Mb(0TB34t3Uv6jbKPFqeyfb)MQjxITZxuqLqvcUPAymTa(WUI330HWWvdet5CJ2h4giMNpD727ZxS4vCtpAciN)IDZWdrr9nWGOodKUMJP1yr)QearcdrLarDkhT5Cm3OTMJB0eqopeb(n1bIYyx(w9KedAyeUva1hXZMfUrz0DdeZRBg4t3UDJpD7wPNeIuPHraIaJKGFt1KlX25lkOsOkb3unmMwaFyxX7B6qy4QbIPCUr7dCdeZZNUD795lsYR4ME0eqo)f7MHhII6BDgiDnhtRXI(vrc3uhikJD5BkhL0vRjjgwhw23kG6J4zZc3Om6UbI51nd8PB3UXNUDt3rjD1Asis16WYgIaRc8BQMCj2oFrbvcvj4MQHX0c4d7kEFthcdxnqmLZnAFGBGyE(0TBVpFXc5kUPhnbKZFXUz4HOO(wjquNYrBoajJ5LR5gnbKZFtDGOm2LV1ecm9jsQmJk3TcO(iE2SWnkJUBGyEDZaF62TB8PB3uqiW0hIkuzgvoicmsa8BQMCj2oFrbvcvj4MQHX0c4d7kEFthcdxnqmLZnAFGBGyE(0TBVFFZen8ykJLYzhz0Ztccj07F]] )

    storeDefault( [[SimC Havoc: cooldown]], 'actionLists', 20171128.104625, [[dWZUfaGAeeRxcuBcbYUi41sq7dbQzdy(sYnvkFtjCBuTteTxv7Mu7NOrjbmmLQFl60GgkcqdMKHtvDqcLtHe6ykPZHGYcrswkvPfJulNkpej6PuwMe16qa1eLazQuftwktxXfLqEmqxg66sQZtiTvjuBgH2Us00ie9Cu(msQ5rOAKiG8xPYOLQoecGtkr67sexdj4EiO6zechwyBii9xVNBKbhVzqoLsfbkwMGeyPcmtGwwI(M5JGWaawWXat9jPWIf38IayWWtwEFDX66kHjSlYvctelUzGoO)C7MyGdm1S75KR3ZTI0bna2ov3mqh0FUraKQcivtaG6rOH8udbfqDqdGnPQQsQwgoyqdGc(zca1u3rmDDCCcPQQsQwgoyqdGcLeWbQPUJy660ihzqMuvvjvldhmObqHsc4a1u3rmDDG9rY6ObIgYKkkkvvvs1eoQXryGCSBYUgeLkXLQYu4My0qa4i6noobpD(9jdYUvQUbbJjD30PgVTLTIdhzWXB3idoEBdNGNo)(Kbz38IayWWtwEFDX6(nVilRDGi7E(CJYEeSWTCjYr9C6BBzJm44TpNS89CRiDqdGTt1nd0b9NBtaG6rOH8udbfqDqdGnPIGKk6AIef44e8053NmitO2xQiiPIyTtubWANd1JujUujY9BIrdbGJO344e8053Nmi7wP6gemM0DtNA82w2koCKbhVDJm44TnCcE687tgKjvfyLI38IayWWtwEFDX6(nVilRDGi7E(CJYEeSWTCjYr9C6BBzJm44TpNue3ZTI0bna2ov3mqh0FUvaPIUMirbW(izD0ardzc1(svvLurxtKOahNGNo)(Kbzc1(svvLubMjqllrlWXj4PZVpzqMq0iKA2GTohYdOMjvIlvL3LQQkPAch14imqo2nzxdIsL4eUurO7sffVjgneaoIEtJCKbz3kv3GGXKUB6uJ32YwXHJm44TBKbhVrICKbz38IayWWtwEFDX6(nVilRDGi7E(CJYEeSWTCjYr9C6BBzJm44TpNuK3ZTI0bna2ov3mqh0FUrxtKOahNGNo)(Kbzc1(svvLubMjqllrlWXj4PZVpzqMq0iKA2GTohYdOMjveSurO7svvLunHJACegih7MSRbrPsCcxQA1UyGP(My0qa4i6nW(izD0ardz3kv3GGXKUB6uJ32YwXHJm44TBKbhVrzFKmPIkGOHSBEramy4jlVVUyD)MxKL1oqKDpFUrzpcw4wUe5OEo9TTSrgC82NtsH75wr6GgaBNQBgOd6p3ORjsuGJtWtNFFYGmbhYdOMjveSuvMcsvvLunHJACegih7MSRbrPsCPse73eJgcahrV5Ndm13kv3GGXKUB6uJ32YwXHJm44TBKbhVraZbM6BEramy4jlVVUyD)MxKL1oqKDpFUrzpcw4wUe5OEo9TTSrgC82Np3kiKyudmNQp)a]] )

    storeDefault( [[SimC Havoc: demonic]], 'actionLists', 20171128.104625, [[daKetaqisv2eIYNquv1OiGtrGELeQYUqLHrqhtsTmjQNjHyAiQ01quX2KGuFdLY4KG4CiQkRtcsAEsi5EsOSpjOoiPslKq5HKsnrju5IKk2iIQ8rjKAKsOQoPe4MazNOQLsu9uktLOSvsj7v1FrKbd6WIwmGhJIjl0Lv2SK8zuQgnqDAbVMq1SPYTjz3i9BOgokz5u1Zry6sDDISDsX3jv14ruv58sK1lbjMpHSFi)6l7wXTQuY1xSB8PA3SGsBeS4NAWmfQiyCkmnWCt(Clj25llSMT66AYhNqYTM8ve2Uzm(aR(2nDz6aMsCzNV(YUPdnbClEXUzm(aR(MaiyNUrBow(Xk9lYnAc4webfjcb70nAZPWQrBjf3OjGBreuqeKmeeqQQIJLFSs)ICrS(ueKmeeqQQItHvJ2skUiwF6nDbcUqx6MMrzFvsos(1(L9TcOXat2y)nkMUBGWrTspFQ2TB8PA30Au2xLKdbLV2VSVjFULe78LfwZwTWBYhbwYZmIl79nTbpgXbH1m1O9bUbch5t1U9(8LVSB6qta3IxSBgJpWQVjac2PB0MtHvJ2skUrta3IiOiriyNUrBUQ5iPsIE(sCJMaUfrqbrqYqqbqq9qWoDJ2CkSA0wsXnAc4webfjcbfabzaNE2hbcwmeSmcksecYGXUiwFkNMrzFvsos(1(LnNFQmqjqWcJGKlckicsgccivvXPWQrBjfxeRpfbfebjdbfabzaNE2hbcwmeSmck4nDbcUqx6w1CK8seGVvangyYg7VrX0DdeoQv65t1UDJpv7g5nhckxIa8n5ZTKyNVSWA2QfEt(iWsEMrCzVVPn4XioiSMPgTpWnq4iFQ2T3NVix2nDOjGBXl2nJXhy1360nAZb4W4OBn3OjGBreKmeuaeupeSt3OnNcRgTLuCJMaUfrqrIqqaPQkofwnAlP4KyHGcIGKHGmGtp7Jablgcw(MUabxOlDRb7X6tIDxg0SBfqJbMSX(BumD3aHJALE(uTB34t1UjdShRpcw0UmOz3Kp3sID(YcRzRw4n5Jal5zgXL9(M2GhJ4GWAMA0(a3aHJ8PA3EFEY9YUPdnbClEXUzm(aR(MM0hsa34aCzCKIjLz30fi4cDPBXLnyse6VX6wb0yGjBS)gft3nq4OwPNpv72n(uTBf3YgmcA6VX6M85wsSZxwynB1cVjFeyjpZiUS330g8yehewZuJ2h4giCKpv727Ztox2nDOjGBXl2nDbcUqx6w1CKMxIvhW0BfqJbMSX(BumD3aHJALE(uTB34t1UrEZHG64Ly1bm9M85wsSZxwynB1cVjFeyjpZiUS330g8yehewZuJ2h4giCKpv727ZxOVSB6qta3IxSBgJpWQVPhc2PB0MtHvJ2skUrta3IiOiriiGuvfNcRgTLuCsSUPlqWf6s3QK8LiHRi1GhPGZfIPpCRaAmWKn2FJIP7giCuR0ZNQD7gFQ2nYtYxcbXviydEiyboxiM(Wn5ZTKyNVSWA2QfEt(iWsEMrCzVVPn4XioiSMPgTpWnq4iFQ2T3NNTl7Mo0eWT4f7MX4dS6BAsFibCJdWLXrkMuMHGKHGmySlI1NYTsJeWsfNFQmqjqWcJGKdcsgcQhcYGXUiwFkNADQWEwGXebco)YyPB6ceCHU0naxghPysz2TcOXat2y)nkMUBGWrTspFQ2TB8PA3eZLXHGfxsz2n5ZTKyNVSWA2QfEt(iWsEMrCzVVPn4XioiSMPgTpWnq4iFQ2T3NVqUSB6qta3IxSBgJpWQV1PB0MdWHXr3AUrta3IiiziyY0bnJ0Otfgbcw4IHGLrqYqqbqq9qWoDJ2CQKONNeUIudEKy3LbnJB0eWTicksecQhc2PB0MtHvJ2skUrta3IiOiriiGuvfNcRgTLuCsSqqbrqYqqbqWKPdAgPrNkmceSWfdblcck4nDbcUqx6wd2J1Ne7UmOz3kGgdmzJ93Oy6Ubch1k98PA3UXNQDtgypwFeSODzqZqqbQf8M85wsSZxwynB1cVjFeyjpZiUS330g8yehewZuJ2h4giCKpv727Zt(USB6qta3IxSBgJpWQVvj5lXfxvGj0iyHlgcweHiiziOaiyLKVehJK3pAJGffcsUcrqrIqqaPQko16uH9SaJjceCrS(ueuWB6ceCHU0TQ5aCzC3kGgdmzJ93Oy6Ubch1k98PA3UXNQDJ8MdWLXDt(Clj25llSMTAH3KpcSKNzex27BAdEmIdcRzQr7dCdeoYNQD795RfEz30HMaUfVy3mgFGvFlz6GMrA0PcJablmcwJGIeHG6HGasvvCXPW0adPr(1JgxKKADQWEwGXebcojwiOiriOaiiXAsayQebxhMVCnjYLfdcwyeuicsgccivvXPwNkSNfymrGGZpvgOeiyHrWcbbf8MUabxOlDBLgjGLQBfqJbMSX(BumD3aHJALE(uTB34t1UPtPHGITuDt(Clj25llSMTAH3KpcSKNzex27BAdEmIdcRzQr7dCdeoYNQD795RRVSB6qta3IxSBgJpWQVjacQhc2PB0MtHvJ2skUrta3IiOiriiGuvfNcRgTLuCsSqqrIqWkjFjU4QcmHgblkeSicrWIhckaccivvXXYpwPFrojwiiziyHGGIeHGcrqbrqrIqqaPQko16uH9SaJjceC(PYaLablkeKCqqbrqYqq9qqnPpKaUXXcJDbk7KQWEsaUmosXKYSB6ceCHU0TKsdGdUSdy6TcOXat2y)nkMUBGWrTspFQ2TB8PA30LsdGdUSdy6n5ZTKyNVSWA2QfEt(iWsEMrCzVVPn4XioiSMPgTpWnq4iFQ2T3NVU8LDthAc4w8IDZy8bw9ToDJ2Caomo6wZnAc4webjdbfab1db70nAZPsIEEs4ksn4rIDxg0mUrta3IiOiriOEiyNUrBofwnAlP4gnbClIGIeHGasvvCkSA0wsXjXcbfebjdbtMoOzKgDQWiqWcxmeSi30fi4cDPBnypwFsS7YGMDRaAmWKn2FJIP7giCuR0ZNQD7gFQ2nzG9y9rWI2LbndbfOSG3Kp3sID(YcRzRw4n5Jal5zgXL9(M2GhJ4GWAMA0(a3aHJ8PA3EF(6ICz30HMaUfVy3mgFGvFtaeupeSt3OnNcRgTLuCJMaUfrqrIqqaPQkofwnAlP4KyHGIeHGvs(sCXvfycncwuiyreIGfpeuaeeqQQIJLFSs)ICsSqqYqWcbbfjcbfIGcIGcIGKHG6HGAsFibCJJfg7cu2jvH9KyaNycseTpi(qqYqq9qqnPpKaUXXcJDbk7KQWEsQ1jcsgcQhcQj9HeWnowySlqzNuf2tcWLXrkMuMDtxGGl0LUXaoXeKiAFq8DRaAmWKn2FJIP7giCuR0ZNQD7gFQ2nTbNyce0AFq8Dt(Clj25llSMTAH3KpcSKNzex27BAdEmIdcRzQr7dCdeoYNQD795Rj3l7Mo0eWT4f7MX4dS6B6HGD6gT5uy1OTKIB0eWTicsgcQhcYGXUiwFk3knsalvC(LXsiiziOaiiGuvfNADQWEwGXebcUiwFkcksec2PB0MlofMscWLXrWnAc4webfebjdbzaNE2hbcwmeS8nDbcUqx6w1CK8seGVvangyYg7VrX0DdeoQv65t1UDJpv7g5nhckxIamckqTG3Kp3sID(YcRzRw4n5Jal5zgXL9(M2GhJ4GWAMA0(a3aHJ8PA3EF(AY5YUPdnbClEXUPlqWf6s3ItHPeKac9UvangyYg7VrX0DdeoQv65t1UDJpv7wXnfMs(tGGIf6Dt(Clj25llSMTAH3KpcSKNzex27BAdEmIdcRzQr7dCdeoYNQD795Rl0x2nDOjGBXl2nJXhy1360Z(AUaLKpPSpeuKieupeSt3OnhGdJJU1CJMaUfVPlqWf6s3AWES(Ky3Lbn7wb0yGjBS)gft3nq4OwPNpv72n(uTBYa7X6JGfTldAgckqre8M85wsSZxwynB1cVjFeyjpZiUS330g8yehewZuJ2h4giCKpv727ZxZ2LDthAc4w8IDZy8bw9nbqq9qWoDJ2CkSA0wsXnAc4webjdb70Z(AoSuteIRMCqqbVPlqWf6s3QMJKxIa8TcOXat2y)nkMUBGWrTspFQ2TB8PA3iV5qq5seGrqbkl4n5ZTKyNVSWA2QfEt(iWsEMrCzVVPn4XioiSMPgTpWnq4iFQ2T3NVUqUSB6qta3IxSBgJpWQV1PN91CyPMiexn5CtxGGl0LUPzu2xLKJKFTFzFRaAmWKn2FJIP7giCuR0ZNQD7gFQ2nTgL9vj5qq5R9lBeuGAbVjFULe78LfwZwTWBYhbwYZmIl79nTbpgXbH1m1O9bUbch5t1U9(9nJ1ycPluOKDatpp5WgBV)b]] )

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

