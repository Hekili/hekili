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


    storeDefault( [[SimC Havoc: default]], 'actionLists', 20180108.224520, [[dmu2paqivGfPcQnjk1OieNIqAvck5vckLzPcPBrqj7svgMuCmbzzeKNrOQPjkX1uHyBqL6BuughbL6CckvRtfK5jO4Eek7tq1bvrTqOcpeQQjsqrDrOIgPOKojujZKGc3uG2PuAPQipvXuvvSvkQElbv3LqL9s6VQ0Gf5WuTyO8yuMmLUmyZu4Zcy0uKtd51QqnBKUTuTBL(TKHRQ0Yj65OA6iUob2UQQVlkopuL1tqrMVOA)cTgs)OZ8fyiNIeMCcQwT9iMzMocZGHlGsuCOZjGcoh0wHAczwOqcjSFHAYcUf6i606DqNb1XpMYQ)xSdftwWWfqj6CMrq1Y1pABi9Jo4CDmkyvCOZWKOVeDoiMejMoiMiofwYBHoWr8hSogfSXuEEmXQIARm7BHoWr8NeClEXuEEmXQIARm7BHoWr8Ne6oA5Xu4XeXLbaYJG6WLuxlcIP88yIvf1wz23cDGJ4pj0D0YJPWJjC3etIQZzmefrWtNFxICmkOd(Ma2XbRFOdlrX0jyzn3LTEh0jJJiOnW1OK3f6ahX1P17Go5mdJMggZWq4dPKqmzUtfaIlxQZzzaUoR3bXY4icAdCnk5DHoWr8J(7ubGyhiYbeNcl5Tqh4i(dwhJc28CwvuBLzFl0boI)KGBXlpNvf1wz23cDGJ4pj0D0YdN4Yaa5rqD4sQRfb55SQO2kZ(wOdCe)jHUJwE44UruDobuW5G2kutiZc1OZjGxcKmGRFuIo4ATiMtkPoBTGoblBR3bDuI2kK(rhCUogfSko0zys0xIohetIetheteNcl5Xm5f)IrDlWFW6yuWgt55XeRkQTYSpMjV4xmQBb(tcUfVykppMyvrTvM9Xm5f)IrDlWFsO7OLhtHhtexgaipcQdxsDTiiMYZJjwvuBLzFmtEXVyu3c8Ne6oA5Xu4XeUBIjr15mgIIi4PZVlrogf0bFta74G1p0HLOy6eSSM7YwVd6KXre0g4AuYlZKx8lg1TaxNwVd6KZmmAAymddHpKscXK5ovaiUCzmjsir15SmaxN17GyzCebTbUgL8Ym5f)IrDlWp6VtfaIDGihqCkSKhZKx8lg1Ta)bRJrbBEoRkQTYSpMjV4xmQBb(tcUfV8CwvuBLzFmtEXVyu3c8Ne6oA5HtCzaG8iOoCj11IG8CwvuBLzFmtEXVyu3c8Ne6oA5HJ7gr15eqbNdARqnHmluJoNaEjqYaU(rj6GR1IyoPK6S1c6eSSTEh0rjAR41p6GZ1XOGvXHodtI(s05GyI4uyjpl0RfXEW6yuWgtzhtSQO2kZ(6aX7L8RPIJ4pj0D0YJPWet4oMYoMmeiX7zbdedrIPWJjX3etzhtIethet)Ue5yu4LXre0g4AuY7cDGJ4XuEEmXQIARm7BHoWr8Ne6oA5XuyIPqnXKOXu2XKiX0bX0VlrogfEzCebTbUgL8Ym5f)IrDlWJP88yIvf1wz2hZKx8lg1Ta)jHUJwEmfMyc3XKO6Cgdrre8053LihJc6GVjGDCW6h6WsumDcwwZDzR3bD(wffTbUgL82bIRtR3bDYzggnnmMHHWhsjHyYCNkaexUmMerir15SmaxN17GyFRII2axJsE7aXp6VtfaIDaXPWsEwOxlI9G1XOGnBwvuBLzFDG49s(1uXr8Ne6oA5Hb3zBiqI3ZcgigIeU4BYwKd(DjYXOWlJJiOnW1OK3f6ahXZZzvrTvM9Tqh4i(tcDhT8WeQr0Sf5GFxICmk8Y4icAdCnk5LzYl(fJ6wGNNZQIARm7JzYl(fJ6wG)Kq3rlpm4wuDobuW5G2kutiZc1OZjGxcKmGRFuIo4ATiMtkPoBTGoblBR3bDuI2Mf9Jo4CDmkyvCOZWKOVeDiofwYZaj5KlgTk7dwhJc2ykppM4a5IvRa(JGaPqn3S8LftHhtnXuEEm5mc6hUWcDeWJPWflMeFmf2IjrIjItHL8yM8IFzuW)Hh6cRJrbBmfwXK4Jjr15mgIIi4PZVlrogf0bFta74G1p0HLOy6eSSM7YwVd6GrDlCT(YaDA9oOtoZWOPHXmme(qkjetM7ubG4YLXKiIxuDoldW1z9oigg1TW16ldo6VtfaIrCkSKNbsYjxmAv2hSogfS55CGCXQva)rqGuOMBw(YYZDgb9dxyHoc4HlM4dBIqCkSKhZKx8lJc(p8G1XOGnSeVO6CcOGZbTvOMqMfQrNtaVeizax)OeDW1ArmNusD2AbDcw2wVd6OeT9i6hDW56yuWQ4qNHjrFj687sKJrHhg1TW16ldIPSJjrIjdbs8EmbsjSKykmXKzhjMewXeXPWsEgijNCXOvzFOlSogfSXuyftc1etIQZzmefrWtNFxICmkOd(Ma2XbRFOdlrX0jyzn3LTEh05Bvu0g4AuYlg1TW16ld0P17Go5mdJMggZWq4dPKqmzUtfaIlxgtIKfr15SmaxN17GyFRII2axJsEXOUfUwFzWr)DQaqSFxICmk8WOUfUwFzq2IyiqIxym7iclItHL8mqso5IrRY(G1XOGnSeQruDobuW5G2kutiZc1OZjGxcKmGRFuIo4ATiMtkPoBTGoblBR3bDuI2IB9Jo4CDmkyvCOZWKOVeDiofwYJzYl(Lrb)hEW6yuWgtzhtgcK49SGbIHiXu4XuwAIPSJjoqiOna)9Tk61OKxMjV4xgf8FqNZyikIGNo)Ue5yuqh8nbSJdw)qhwIIPtWYAUlB9oOZ3QOOnW1OKxMjV4xorIog0P17Go5mdJMggZWq4dPKqmzUtfaIlxgtICer15SmaxN17GyFRII2axJsEzM8IF5ej6y4O)ovaigXPWsEmtEXVmk4)WdwhJc2SneiX7zbdedrcplnzZbcbTb4VVvrVgL8Ym5f)YOG)d6CcOGZbTvOMqMfQrNtaVeizax)OeDW1ArmNusD2AbDcw2wVd6OeT1m9Jo4CDmkyvCOZzmefrWthwTCbD429aiMo4ATiMtkPoBTGoblR5US17Go606Dqh8RLlOdXuqpaIPZjGcoh0wHAczwOgDob8sGKbC9Js0bFta74G1p0HLOy6eSSTEh0rjARWw)OdoxhJcwfh6mmj6lrhwvuBLzFbOfMtVSQO2kZ(Kq3rlpMelMA05mgIIi4PdZP0RZiOAVueNOd(Ma2XbRFOdlrX0jyzn3LTEh0rNwVd6KZmmAAymddHJVtPX0zgbvBmjmqCI4YL6CwgGRZ6DqSdpOo(Xuw9)IDOyIvf1wz2dRZjGcoh0wHAczwOgDob8sGKbC9Js0bxRfXCsj1zRf0jyzB9oOZG64htz1)l2HIjwvuBLzvI2g21p6GZ1XOGvXHodtI(s0H4uyjpl0RfXEW6yuWQZzmefrWthPG96mcQ2lfXj6GVjGDCW6h6WsumDcwwZDzR3bD0P17Go5mdJMggZWq4NeSX0zgbvBmjmqCI4YL6CwgGRZ6DqSdpOo(Xuw9)IDOyYc9ArSdRZjGcoh0wHAczwOgDob8sGKbC9Js0bxRfXCsj1zRf0jyzB9oOZG64htz1)l2HIjl0RfXuI2gQr)OdoxhJcwfh6Cgdrre80rkyVoJGQ9srCIo4ATiMtkPoBTGoblR5US17Go606DqNCMHrtdJzyi8tc2y6mJGQnMegiorC5YysKqIQZzzaUoR3bXo8G64htz1)l2HIPTKDNEyDobuW5G2kutiZc1OZjGxcKmGRFuIo4BcyhhS(HoSeftNGLT17GodQJFmLv)VyhkM2s2DQsuIodtI(s0rjQca]] )

    storeDefault( [[SimC Havoc: precombat]], 'actionLists', 20180108.224520, [[dGZgcaGEsfTjKs2fq2gPG9HuQzRI5lOUPeDxsr(gb2PkTxQDJy)QYOivAyeACKs1qjfAWQQHluheGoLG0Xa1cbKLIuTyKSCr9qKINIAzs45sAIKIAQa1Kbz6sDrbQldDDH0VvSvb0MjOTdOonrpMKPrQY6iLyKKs5TKkmAH42ICsbYHv6AcIZlaVMuvhIus)faByd2mhJk5EK6CB5q8nebcmRzu4g90giZ0XdUv03crybWWfAheSOEAOieZ3nHMzzIM3xBlWJslVFCgvtIABZaQA5qQgSVWgS5Gjl1bHmqMbKsEKDaMJNwoeZbrGKQTNSzYqqZLduGB(Uj0S57MqZHvcfkkQucfQdnoTCiAkC2mD8GBf9TqewaSOz6yDIMvy1GDBMMiOs)YbymHK2uMlhO7MqZU9TWGnhmzPoiKbYmRYY42SwFFDF)EpiPbbHPHaqgPMmbeswQdc9(06919979GKgeeMgIubcjl1bHE)WHF)k2aqnKOvqTeZfWaOxS69P97l((H((HAgqk5r2byoH9MMCCKPkRMdIajvBpzZKHGMlhOa38DtOzZ3nHMlXEttooYuLvZ0XdUv03crybWIMPJ1jAwHvd2TzAIGk9lhGXesAtzUCGUBcn72TzwLLXTz32a]] )

    storeDefault( [[SimC Havoc: normal]], 'actionLists', 20180108.224520, [[dauixaqikkBcr6tsePgfQOtHkSkjs5vseXUqyyeLJbOLjHEMejtJeuxdrKTHiQ(grY4ib5CsKQwNerY8qe6Ese2hjWbPGwirQhsrmrer5IuK2iIGpkruJuIuXjPO6Ma1orvlLc9uQMkjARsG9c9xGmyvDyrlwspgKjtPlRSza(mfy0iQtl41KqZMWTj1Ur63OmCuPLl0Zb10L66K02jQ(Ue05LOwVePsZNi2VkJarLOtYgGuv0O0O7ChuifHs3SdmkYtssjf6gNyj8q(IYakfqGfvicGYuysErscDhkg42OJUHqDGrHrLipquj6MsZQywuA0DOyGBJoN33Py0MGBCCZ4SeJMvXS3lrY9DkgTj0m9OTQMy0SkM9EoUN07RQaaqWnoUzCwclRq69KEFvfaacntpARQjSScPOBynicDz0LpQbdGQauCDCzJU5uBakBweDkJo0bZSfKr(up0rNp1d9cg1GbqvCVX1XLn6gNyj8q(IYakfqzOBCWm1i0GrLyJUjKhKIGzYNE0gROdMz5t9qhBKViQeDtPzvmlkn6oumWTrNZ77umAtOz6rBvnXOzvm79sKCFNIrBcatasNW9ILjgnRIzVNJ7j9EoV3S77umAtOz6rBvnXOzvm79sKCpN3droJgm47lX9fVxIK7HymHLviLq(OgmaQcqX1XLnrC6mqHVxb3RW3ZX9KEFvfaacntpARQjSScP3ZX9KEpN3B29DkgTjambiDc3lwMy0SkM9EjsUhGASmHDacqH(EfuI7lss3ZX9KEpN3droJgm47lX9fVNd0nSgeHUm6aMauufMm6MtTbOSzr0Pm6qhmZwqg5t9qhD(up0jHjU3Okmz0noXs4H8fLbukGYq34GzQrObJkXgDtipifbZKp9OnwrhmZYN6Ho2iFPqLOBknRIzrPr3HIbUn6CEFvfaacntpARQju5EVej3B29DkgTj0m9OTQMy0SkM9EoUN0758(eQdYhOrNom47vW9aVNd0nSgeHUm6aMaunJX0GHU5uBakBweDkJo0bZSfKr(up0rNp1dDsyI7LoJX0GHUXjwcpKVOmGsbug6ghmtncnyuj2OBc5bPiyM8PhTXk6Gzw(up0Xg5vyuj6MsZQywuA0DOyGBJENIrBIQGXSI1eJMvXS3t69CEVz33Py0MqZ0J2QAIrZQy27Li5(QkaaeAME0wvtOY9EoUN07HiNrdg89L4(IOBynicDz0BYrwHGmqKb5dDZP2au2Si6ugDOdMzliJ8PEOJoFQh6kjhzfEFjlYG8HUXjwcpKVOmGsbug6ghmtncnyuj2OBc5bPiyM8PhTXk6Gzw(up0Xg5jjuj6MsZQywuA0DOyGBJoa1yzci1yC0(Es8EGK09KEpN3dXyclRqkHDztgeCHBCjItNbk89K49fVV0U3ai79sKCpeJjSScPevrAhiBsHgrC6mqHVNeVV49L29gazVNd0nSgeHUm6aMOks7q3CQnaLnlIoLrh6Gz2cYiFQh6OZN6HojmrvK2HUXjwcpKVOmGsbug6ghmtncnyuj2OBc5bPiyM8PhTXk6Gzw(up0Xg5j5Os0nLMvXSO0O7qXa3gD5zmKvXiQI0oq2Kcn0nSgeHUm62LnzqWfUXfDZP2au2Si6ugDOdMzliJ8PEOJoFQh6KSLn579c34IUXjwcpKVOmGsbug6ghmtncnyuj2OBc5bPiyM8PhTXk6Gzw(up0Xg5LcvIUP0SkMfLgDhkg42OdroJgm47lX9fVN07n7(ofJ2eAME0wvtmAwfZEpP3B29DkgTjambiDc3lwMy0SkM9EsV3S7RQaaqOxNAwKlzgCaMqL79KEFNIrBc70mkOQiTdMy0SkMfDdRbrOlJoGjafvHjJU5uBakBweDkJo0bZSfKr(up0rNp1dDsyI7nQct(EobYb6gNyj8q(IYakfqzOBCWm1i0GrLyJUjKhKIGzYNE0gROdMz5t9qhBKxHqLOBknRIzrPr3WAqe6YOdycqlQYTdmk6MtTbOSzr0Pm6qhmZwqg5t9qhD(up0jHjU30Ok3oWOOBCILWd5lkdOuaLHUXbZuJqdgvIn6MqEqkcMjF6rBSIoyMLp1dDSr(spQeDtPzvmlkn6oumWTrNZ7tOoiFGgD6WGVxb3d8EoUN0758EoV3S77umAtOz6rBvnXOzvm79sKCFvfaacntpARQju5Eph3t69CEVz33Py0MaICYGbvfPDWeJMvXS3lrY9vvaaiGiNmyqvrAhmHk37Li5EigtyzfsjGiNmyqvrAhmrC6mqHVxb3xkz3lrY9Dgnynrh0duZazd7Es8EigtyzfsjGiNmyqvrAhmrC6mqHVNJ75aDdRbrOlJoa1yzqmaGAYduqic2mgq3CQnaLnlIoLrh6Gz2cYiFQh6OZN6HojOglFpdW9n5DV5crWMXa6gNyj8q(IYakfqzOBCWm1i0GrLyJUjKhKIGzYNE0gROdMz5t9qhBKhOmuj6MsZQywuA0DOyGBJU8mgYQyevrAhiBsHg6gwdIqxg9QiTdKnPqdDZP2au2Si6ugDOdMzliJ8PEOJoFQh6sls7UNKLuOHUXjwcpKVOmGsbug6ghmtncnyuj2OBc5bPiyM8PhTXk6Gzw(up0Xg5bcevIUP0SkMfLgDhkg42O3Py0MOkymRynXOzvm79KEFc1b5d0Othg89kOe3x8EsVNZ7n7(ofJ2e6eUxeedaOM8azGidYhXOzvm79sKCVz33Py0MqZ0J2QAIrZQy27Li5(QkaaeAME0wvtOY9EoUN0758(eQdYhOrNom47vqjUVu3Zb6gwdIqxg9MCKviidezq(q3CQnaLnlIoLrh6Gz2cYiFQh6OZN6HUsYrwH3xYImiF3Zjqoq34elHhYxugqPakdDJdMPgHgmQeB0nH8Guemt(0J2yfDWmlFQh6yJ8alIkr3uAwfZIsJUdfdCB0bOgltyhGauOVxbL4(sj7(sY9vvaai4gh3molHk37lT7vi0nSgeHUm6aMOks7q3CQnaLnlIoLrh6Gz2cYiFQh6OZN6HojmrvK2DpNa5aDJtSeEiFrzaLcOm0noyMAeAWOsSr3eYdsrWm5tpAJv0bZS8PEOJnYdSuOs0nLMvXSO0O7qXa3g9eQdYhOrNom47vW9aVxIK7RQaaqqoLZGa1fbcsH5creNodu47jX7lEpP3Z59MDFNIrBIQiqTGaOgltmAwfZEVej3dqnwMWoabOqFVckX9sj7EoUN0758EoVpH6G8bA0Pdd(EfuI7l19CCVej33Py0MOkculiaQXYeJMvXS3lrY9WRbvzuvyIoSyrGGkYf6EfCVS75aDdRbrOlJ(kpq1LA0nNAdqzZIOtz0HoyMTGmYN6Ho68PEOBA5DV0l1OBCILWd5lkdOuaLHUXbZuJqdgvIn6MqEqkcMjF6rBSIoyMLp1dDSrEGkmQeDtPzvmlkn6oumWTrNZ77umAtyNMrbvfPDWeJMvXS3lrY9MDFNIrBcntpARQjgnRIzVxIK7RQaaqOz6rBvnHk37Li5EaQXYe2biaf67jX7lLS7lj3xvbaGGBCCZ4SeQCVV0UxHUxIK7RQaaqOxNAwKlzgCaMioDgOW3tI3ts3ZX9KEVz3lpJHSkgbxgteOgacalcQks7aztk0q3WAqe6YONuAGCqKDGrr3CQnaLnlIoLrh6Gz2cYiFQh6OZN6HUHuAGCqKDGrr34elHhYxugqPakdDJdMPgHgmQeB0nH8Guemt(0J2yfDWmlFQh6yJ8ajjuj6MsZQywuA0DOyGBJENIrBIQGXSI1eJMvXS3t69CEVz33Py0MqNW9IGyaa1Khidezq(ignRIzVxIK7n7(ofJ2eAME0wvtmAwfZEVej3xvbaGqZ0J2QAcvU3Zb6gwdIqxg9MCKviidezq(q3CQnaLnlIoLrh6Gz2cYiFQh6OZN6HUsYrwH3xYImiF3Zzroq34elHhYxugqPakdDJdMPgHgmQeB0nH8Guemt(0J2yfDWmlFQh6yJ8aj5Os0nLMvXSO0O7qXa3gDZUVtXOnrvWywXAIrZQy27j9(Qkaae61PMf5sMbhGjSScP3t69juhKpqJoDyW3RGsCFPq3WAqe6YO3KJScbzGidYh6MtTbOSzr0Pm6qhmZwqg5t9qhD(up0vsoYk8(swKb57EolfhOBCILWd5lkdOuaLHUXbZuJqdgvIn6MqEqkcMjF6rBSIoyMLp1dDSrEGsHkr3uAwfZIsJUdfdCB058(ofJ2e2PzuqvrAhmXOzvm79sKCVz33Py0MqZ0J2QAIrZQy27Li5(QkaaeAME0wvtOY9EjsUhGASmHDacqH(Es8(sj7(sY9vvaai4gh3molHk37lT7vO754EsV3S7LNXqwfJGlJjcudabGfbbrozWGG7yqXDpP3B29YZyiRIrWLXebQbGaWIG0RZ7j9EZUxEgdzvmcUmMiqnaeaweuvK2bYMuOHUH1Gi0LrhICYGbb3XGIdDZP2au2Si6ugDOdMzliJ8PEOJoFQh6MqozW37DmO4q34elHhYxugqPakdDJdMPgHgmQeB0nH8Guemt(0J2yfDWmlFQh6yJ8aviuj6MsZQywuA0DOyGBJUz33Py0MqZ0J2QAIrZQy27j9(ofJ2e2PzuqvrAhmXOzvml6gwdIqxgDatakQctgDZP2au2Si6ugDOdMzliJ8PEOJoFQh6KWe3BufM89CwKd0noXs4H8fLbukGYq34GzQrObJkXgDtipifbZKp9OnwrhmZYN6Ho2ipWspQeDtPzvmlkn6gwdIqxgD70mkmOAOh6MtTbOSzr0Pm6qhmZwqg5t9qhD(up0jztZOL0W3lDOh6gNyj8q(IYakfqzOBCWm1i0GrLyJUjKhKIGzYNE0gROdMz5t9qhBKVOmuj6MsZQywuA0DOyGBJENrdwtWuB4GDajj0nSgeHUm6aMOks7q3CQnaLnlIoLrh6Gz2cYiFQh6OZN6HojmrvK2DpNf5aDJtSeEiFrzaLcOm0noyMAeAWOsSr3eYdsrWm5tpAJv0bZS8PEOJnYxeiQeDtPzvmlkn6oumWTr3S77umAtufmMvSMy0SkM9EsVVtXOnHDAgfuvK2btmAwfZIUH1Gi0LrVjhzfcYargKp0nNAdqzZIOtz0HoyMTGmYN6Ho68PEORKCKv49LSidY39CQWCGUXjwcpKVOmGsbug6ghmtncnyuj2OBc5bPiyM8PhTXk6Gzw(up0XgB05t9q3dAtUV0jLZGkPUNYI6uGnIa]] )

    storeDefault( [[SimC Havoc: cooldown]], 'actionLists', 20180108.224520, [[d4ZQfaGAGIwVuuAtsrXUiyBib7dGQNJYSry(cCtaDxKqDBu9yLANiAVQ2nr7NkJcOudtj(TKdlAOaKmyQA4uYbPuCkGchdiNxqSqKKLsPAXi1YP4HiPEkPLriRdGWeLIktLqnzHMUIlkiDAqpdGIRRKghaL2QGQnlvTDamnKqoearFgjAEuknsPOQ)kLgTu57sHoPuKldDnPG7buY3aQElaPETGYh0fFLm54vfYP25B(eGAdiC(DveXQr51Md7ZvI5uD1osGjdpPOfqGdcKiaRaOfkIcIA4QUnqR56vB2dSKSl(KGU4RHktAcmEQUQBd0AUciDEW25NKaLJqe5LeUfqzstGrNpiW5binWKMafSQIakPSTVmTCCsNpiW5binWKMafAmHduszBFzALihzqMZhe48aKgystGcnMWbkPSTVmT7USyT0ezezopy48bbo)KgkXryGCSDQ2ieDEBDErnC1gAibCc5khNKxgRUIbzxBsgH7CkZvzjXRaRy4PHm541RKjhVceNKxgRUIbzxTJeyYWtkAbe4GwUAhz1QzJSl(ZvQ7WDyalaqokNtFfyfjtoE9ZjfDXxdvM0ey8uDv3gO1CDscuocrKxs4waLjnbgD(MX5Px77f44K8Yy1vmity16Qn0qc4eYvoojVmwDfdYU2Kmc35uMRYsIxbwXWtdzYXRxjtoEfiojVmwDfdYCEWgeyC1osGjdpPOfqGdA5QDKvRMnYU4pxPUd3HbSaa5OCo9vGvKm541pNeWCXxdvM0ey8uDv3gO1CLETVxy3LfRLMiJity1Y5dcCE61(EboojVmwDfdYewTC(GaNFxfrSAukWXj5LXQRyqMqgbZv2GXwdYtOK58268IwC(GaNFsdL4imqo2ovBeIoVTGLZtHLR2qdjGtixLihzq21MKr4oNYCvws8kWkgEAitoE9kzYXRKihzq2v7ibMm8KIwaboOLR2rwTA2i7I)CL6oChgWcaKJY50xbwrYKJx)Csk6IVgQmPjW4P6QUnqR5k9AFVahNKxgRUIbzcRwoFqGZVRIiwnkf44K8Yy1vmitiJG5kBWyRb5juYCEa35PWIZhe48tAOehHbYX2PAJq05TfSC(4QjhyjVAdnKaoHCD3LfRLMiJi7AtYiCNtzUkljEfyfdpnKjhVELm54vQ7YI58urKrKD1osGjdpPOfqGdA5QDKvRMnYU4pxPUd3HbSaa5OCo9vGvKm541pNSHl(AOYKMaJNQR62aTMR0R99cCCsEzS6kgKjyqEcLmNhWDErn48bbo)KgkXryGCSDQ2ieDEBDEkSC1gAibCc5QvnWsETjzeUZPmxLLeVcSIHNgYKJxVsMC8AWUVFzzV77b0aQAGLKIdmxTJeyYWtkAbe4GwUAhz1QzJSl(ZvQ7WDyalaqokNtFfyfjtoE9ZNRQfUHjbSzZbwYt2a4G)5ha]] )

    storeDefault( [[SimC Havoc: demonic]], 'actionLists', 20180108.224520, [[deeUraqiIsBcO8jGkQrHk5uOsTkje5vsiQDHIHHQCmj1YKOEMeQMgQQ4AavABsi5BOQmoju6CavK1jHGMNesDpuv1(aQ6GuelKO4HuKMiqfUifYgrvL(OekgPec5KsGBcIDsWsPOEkvtLOARsq7f6VazWQCyrlgWJb1Kf6YkBws(mfQrdsNMsVMcmBsDBs2ns)gXWrflxWZrPPRQRtKTtO(of04LqGZlrwVec18jK9l1ynkhDWXQsj9JYGUZzW2uBlIZ3sOOa4YhFOBE6LSdfkZRMV66Yfltnp(POkdUO7WblNhD0nb(TeklkhfQr5OBenb0lIYGUdhSCE05QVp1J(mCcJtgwKz0eqVyFIe13N6rFgfrn6lPygnb0l2h39bwFasvvmCcJtgwKjsmK2hy9bivvXOiQrFjftKyifDtaSA7xcDXJA8QK0Gc7dlF0lGgTW5tcOtj0HoesSWmiKQHo6cPAOx4OgVkjDFM3hw(OBE6LSdfkZRMVAEOBESePa8yr54JUPqhSbqiINA0hbqhcjkKQHo(Oqzuo6grta9IOmO7WblNhDU67t9OpJIOg9LumJMa6f7tKO((up6ZunnivY(luIz0eqVyFC3hy9XvFY23N6rFgfrn6lPygnb0l2Nir9XvFWqZGXJTp(3x5(ejQpycrhjgszepQXRssdkSpS8zctLwkBFGVp(PpU7dS(aKQQyue1OVKIjsmK2h39bwFC1hm0my8y7J)9vUpUr3eaR2(LqVAAqbjwOOxanAHZNeqNsOdDiKyHzqivdD0fs1qNFNUpZsSqr380lzhkuMxnF18q38yjsb4XIYXhDtHoydGqep1OpcGoesuivdD8rHIJYr3iAcOxeLbDhoy58O)PE0Nbqtir9EMrta9I9bwFC1NS99PE0NrruJ(skMrta9I9jsuFasvvmkIA0xsXiXPpU7dS(GHMbJhBF8VVYOBcGvB)sO)qdedbzSoTIh6fqJw48jb0Pe6qhcjwyges1qhDHun0LdnqmSVIrNwXdDZtVKDOqzE18vZdDZJLifGhlkhF0nf6Gnacr8uJ(ia6qirHun0Xhf4huo6grta9IOmO7WblNhDXzWMa6XaOZ4aftk8q3eaR2(LqpU8HcI1WnoOxanAHZNeqNsOdDiKyHzqivdD0fs1qhCS8H2NB4gh0np9s2HcL5vZxnp0npwIuaESOC8r3uOd2aieXtn6JaOdHefs1qhFuaCr5OBenb0lIYGUjawT9lHE10GwqIZBju0lGgTW5tcOtj0HoesSWmiKQHo6cPAOZVt3NrbjoVLqr380lzhkuMxnF18q38yjsb4XIYXhDtHoydGqep1OpcGoesuivdD8rHIcLJUr0eqVikd6oCWY5rNR(s43kEGgDk7y7d89v3h39bwFC1NS99PE0NrruJ(skMrta9I9jsuFasvvmkIA0xsXiXPpUr3eaR2(LqVskucePc0dDGSATnMbl6fqJw48jb0Pe6qhcjwyges1qhDHun05xPqP(iv99qxFfO12ygSOBE6LSdfkZRMVAEOBESePa8yr54JUPqhSbqiINA0hbqhcjkKQHo(OaFOC0nIMa6frzq3Hdwop6IZGnb0JbqNXbkMu41hy9bti6iXqkZknqalvmHPslLTpW3h42hy9jBFWeIosmKYO2NksGducRLLjSmwcDtaSA7xcDaDghOysHh6fqJw48jb0Pe6qhcjwyges1qhDHun0LrNX1h4iPWdDZtVKDOqzE18vZdDZJLifGhlkhF0nf6Gnacr8uJ(ia6qirHun0Xhfkwuo6grta9IOmO7WblNh9p1J(maAcjQ3ZmAcOxSpW6lHFR4bA0PSJTpWZ)(k3hy9XvFY23N6rFgvY(laIub6HoqgRtR4XmAcOxSprI6t2((up6ZOiQrFjfZOjGEX(ejQpaPQkgfrn6lPyK40h39bwFC1xc)wXd0OtzhBFGN)9v8(4gDtaSA7xc9hAGyiiJ1Pv8qVaA0cNpjGoLqh6qiXcZGqQg6OlKQHUCObIH9vm60kE9Xvn3OBE6LSdfkZRMVAEOBESePa8yr54JUPqhSbqiINA0hbqhcjkKQHo(Oa4ekhDJOjGErug0D4GLZJELuOetCvwy73h45FFfNxFG1hx9vjfkXalfcJ(9v09Xp86tKO(aKQQyu7tfjWbkH1YYejgs7JB0nbWQTFj0RMgqNXHEb0OfoFsaDkHo0HqIfMbHun0rxivdD(DAaDgh6MNEj7qHY8Q5RMh6Mhlrkapwuo(OBk0bBaeI4Pg9ra0HqIcPAOJpkuZdLJUr0eqVikd6oCWY5rpHFR4bA0PSJTpW3xDFIe1hx9jBFFQh9za0wAeuLuOeZOjGEX(ejQVkPqjM4QSW2VpWZ)(4JxFC3hy9XvFY2hGuvftCkc1cdAfb)OXfbP2NksGducRLLrItFIe1hx9XUheaHkXY82fkxdIF4a3h47JxFG1hGuvfJAFQiboqjSwwMWuPLY2h47RUO6J7(4gDtaSA7xc9vAGawQqVaA0cNpjGoLqh6qiXcZGqQg6OlKQHUrLwFYSuHU5PxYouOmVA(Q5HU5XsKcWJfLJp6McDWgaHiEQrFeaDiKOqQg64Jc11OC0nIMa6frzq3Hdwop6C1NS99PE0NrruJ(skMrta9I9jsuFasvvmkIA0xsXiXPprI6RskuIjUklS97RO7R486Ri3hGuvfdNW4KHfzK40xrQVITprI6dqQQIrTpvKahOewlltyQ0sz7RO7dC7J7(aRpz7tCgSjGEmCieTLAmOksaeGoJdumPWdDtaSA7xc9KsTqT68Tek6fqJw48jb0Pe6qhcjwyges1qhDHun0nHsTqT68Tek6MNEj7qHY8Q5RMh6Mhlrkapwuo(OBk0bBaeI4Pg9ra0HqIcPAOJpkuxgLJUr0eqVikd6oCWY5r)t9OpdGMqI69mJMa6f7dS(4Qpz77t9OpJkz)farQa9qhiJ1Pv8ygnb0l2Nir9jBFFQh9zue1OVKIz0eqVyFIe1hGuvfJIOg9LumsC6J7(aRVe(TIhOrNYo2(ap)7R4OBcGvB)sO)qdedbzSoTIh6fqJw48jb0Pe6qhcjwyges1qhDHun0LdnqmSVIrNwXRpUkZn6MNEj7qHY8Q5RMh6Mhlrkapwuo(OBk0bBaeI4Pg9ra0HqIcPAOJpkuxCuo6grta9IOmO7WblNhDU6t2((up6ZOiQrFjfZOjGEX(ejQpaPQkgfrn6lPyK40Nir9vjfkXexLf2(9v09vCE9vK7dqQQIHtyCYWImsC6Ri1xX2h39bwFY2N4myta9y4qiAl1yqvKaiyOjHfe7hSgS(aRpz7tCgSjGEmCieTLAmOksaKAF2hy9jBFIZGnb0JHdHOTuJbvrcGa0zCGIjfEOBcGvB)sOddnjSGy)G1GHEb0OfoFsaDkHo0HqIfMbHun0rxivdDtHMe2(8pynyOBE6LSdfkZRMVAEOBESePa8yr54JUPqhSbqiINA0hbqhcjkKQHo(Oqn)GYr3iAcOxeLbDhoy58OlBFFQh9zue1OVKIz0eqVyFG13N6rFM4uekiaDghlZOjGEX(aRpz7dMq0rIHuMvAGawQyclJL6dS(4QpyOzW4X2h)7RCFCJUjawT9lHE10GcsSqrVaA0cNpjGoLqh6qiXcZGqQg6OlKQHo)oDFMLyH2hx1CJU5PxYouOmVA(Q5HU5XsKcWJfLJp6McDWgaHiEQrFeaDiKOqQg64Jc1GlkhDJOjGErug0nbWQTFj0JtrOSGaS)qVaA0cNpjGoLqh6qiXcZGqQg6OlKQHo4ykcfCMTpzS)q380lzhkuMxnF18q38yjsb4XIYXhDtHoydGqep1OpcGoesuivdD8rH6IcLJUr0eqVikd6oCWY5r)ZGX7zIw2pPWRpW3xnV(ejQpz77t9OpdGMqI69mJMa6fr3eaR2(Lq)HgigcYyDAfp0lGgTW5tcOtj0HoesSWmiKQHo6cPAOlhAGyyFfJoTIxFCvCUr380lzhkuMxnF18q38yjsb4XIYXhDtHoydGqep1OpcGoesuivdD8XhDHun0DRY0(kIsXe4IW(ItrOwy8re]] )

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

