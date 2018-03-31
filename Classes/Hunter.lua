-- Hunter.lua
-- January 2017

local addon, ns = ...
local Hekili = _G[ addon ]

local class = ns.class
local state = ns.state

local addAbility = ns.addAbility
local addAura = ns.addAura
local addCastExclusion = ns.addCastExclusion
local addGearSet = ns.addGearSet
local addGlyph = ns.addGlyph
local addHandler = ns.addHandler
local addHook = ns.addHook
local addCooldownMetaFunction = ns.addCooldownMetaFunction
local addMetaFunction = ns.addMetaFunction
local addResource = ns.addResource
local addSetting = ns.addSetting
local addStance = ns.addStance
local addTalent =  ns.addTalent
local addToggle = ns.addToggle
local addTrait = ns.addTrait
local modifyAbility = ns.modifyAbility
local modifyAura = ns.modifyAura

local registerCustomVariable = ns.registerCustomVariable
local registerInterrupt = ns.registerInterrupt

local removeResource = ns.removeResource

local setArtifact = ns.setArtifact 
local setClass = ns.setClass
local setPotion = ns.setPotion
local setRegenModel = ns.setRegenModel
local setRole = ns.setRole
local setTalentLegendary = ns.setTalentLegendary

local RegisterEvent = ns.RegisterEvent
local RegisterUnitEvent = ns.RegisterUnitEvent

local retireDefaults = ns.retireDefaults
local storeDefault = ns.storeDefault


local PTR = ns.PTR


if select( 2, UnitClass( 'player' ) ) == 'HUNTER' then

    local function HunterInit()
        setClass( 'HUNTER' )
        addResource( 'focus', SPELL_POWER_FOCUS )

        setRegenModel( {
            volley = {
                resource = 'focus',

                spec = 'marksmanship',
                buff = 'volley',

                last = function ()
                    local swing = state.swings.mainhand
                    local t = state.query_time

                    return swing + ( floor( ( t - swing ) / state.swings.mainhand_speed ) * state.swings.mainhand_speed )
                end,

                interval = 'mainhand_speed',

                value = -3
            }
        } )
        
        addTalent( 'a_murder_of_crows', 206505 ) -- MM, 131894
        addTalent( 'animal_instincts', 204315 )
        addTalent( 'aspect_of_the_beast', 191384 )
        addTalent( "barrage", 120360 ) -- 22002
        addTalent( 'bestial_fury', 194306 )
        addTalent( 'big_game_hunter', 204308 )
        addTalent( "binding_shot", 109248 ) -- 22284
        addTalent( "black_arrow", 194599 ) -- 22497
        addTalent( 'blink_strikes', 130392 )
        addTalent( 'butchery', 212436 )
        addTalent( 'caltrops', 194277 )
        addTalent( 'camouflage', 199483 )
        addTalent( "careful_aim", 53238 ) -- 22289
        addTalent( 'chimera_shot', 53209 )
        addTalent( 'dire_frenzy', 217200 )
        addTalent( 'dire_stable', 193532 )
        addTalent( 'disengage', 781 )
        addTalent( 'dragonsfire_grenade', 2194855 )
        addTalent( 'expert_trapper', 199543 )
        addTalent( "explosive_shot", 212431 ) -- 22267
        addTalent( "farstrider", 199523 ) -- 19348
        addTalent( 'guerrilla_tactics', 236698 )
        addTalent( 'intimidation', 19577 )
        addTalent( 'killer_cobra', 199532 )
        addTalent( "lock_and_load", 194595 ) -- 22495
        addTalent( "lone_wolf", 155228 ) -- 22279
        addTalent( 'mortal_wounds', 201075 )
        addTalent( 'one_with_the_pack', 199528 )
        addTalent( "patient_sniper", 234588 ) -- 21998
        addTalent( "piercing_shot", 198670 ) -- 22308
        addTalent( 'posthaste', 109215 )
        addTalent( 'rangers_net', 200108 )
        addTalent( "sentinel", 206817 ) -- 22286
        addTalent( 'serpent_sting', 87935 )
        addTalent( "sidewinders", 214579 ) -- 22274
        addTalent( 'snake_hunter', 201078 )
        addTalent( 'spitting_cobra', 194407 )
        addTalent( 'stampede', 201430 )
        addTalent( "steady_focus", 193533 ) -- 22501
        addTalent( 'steel_trap', 162488 )
        addTalent( 'sticky_bomb', 191241 )
        addTalent( 'stomp', 199530 )
        addTalent( 'throwing_axes', 200163 )
        addTalent( 'trailblazer', 199921 )
        addTalent( "trick_shot", 199522 ) -- 22288
        addTalent( "true_aim", 199527 ) -- 22498
        addTalent( "volley", 194386 ) -- 22287
        addTalent( 'way_of_the_cobra', 194397 )
        addTalent( 'way_of_the_moknathal', 201082 )
        addTalent( "wyvern_sting", 19386 ) -- 22276

        addTrait( "acuity_of_the_unseen_path", 241114 )
        addTrait( "aspect_of_the_skylord", 203755 )
        addTrait( "bird_of_prey", 224764 )
        addTrait( "bullseye", 204089 )
        addTrait( "call_of_the_hunter", 191048 )
        addTrait( "called_shot", 190467 )
        addTrait( "concordance_of_the_legionfall", 239042 )
        addTrait( "critical_focus", 191328 )
        addTrait( "cyclonic_burst", 238124 )
        addTrait( "deadly_aim", 190449 )
        addTrait( "eagles_bite", 203757 )
        addTrait( "echoes_of_ohnara", 238125 )
        addTrait( "embrace_of_the_aspects", 225092 )
        addTrait( "explosive_force", 203670 )
        addTrait( "feet_of_wind", 238088 )
        addTrait( "ferocity_of_the_unseen_path", 241115 )
        addTrait( "fluffy_go", 203669 )
        addTrait( "fury_of_the_eagle", 203415 )
        addTrait( "gust_of_wind", 190567 )
        addTrait( "healing_shell", 190503 )
        addTrait( "hellcarver", 203673 )
        addTrait( "hunters_bounty", 203749 )
        addTrait( "hunters_guile", 203752 )
        addTrait( "iron_talons", 221773 )
        addTrait( "jaws_of_the_mongoose", 238053 )
        addTrait( "lacerating_talons", 203578 )
        addTrait( "legacy_of_the_windrunners", 190852 )
        addTrait( "mark_of_the_windrunner", 204219 )
        addTrait( "marked_for_death", 190529 )
        addTrait( "my_beloved_monster", 203577 )
        addTrait( "precision", 190520 )
        addTrait( "quick_shot", 190462 )
        addTrait( "rapid_killing", 191339 )
        addTrait( "raptors_cry", 203638 )
        addTrait( "sharpened_fang", 203566 )
        addTrait( "slithering_serpents", 238051 ) -- BM trait
        addTrait( "survival_of_the_fittest", 190514 )
        addTrait( "talon_bond", 238089 )
        addTrait( "talon_strike", 203563 )
        addTrait( "terms_of_engagement", 203754 )
        addTrait( "unerring_arrows", 238052 )
        addTrait( "voice_of_the_wild_gods", 214916 )
        addTrait( "wind_arrows", 214826 )
        addTrait( "windburst", 204147 )
        addTrait( "windflight_arrows", 214915 )
        addTrait( "windrunners_guidance", 190457 )

        -- Buffs/Debuffs
        addAura( 'a_murder_of_crows', 206505, 'duration', 15 )
            modifyAura( 'a_murder_of_crows', 'id', function( x )
                if not spec.survival  then return 131894 end -- Murder of Crows is the same for BM and MM
                return x
            end )
            class.auras[ 131894 ] = class.auras[ 206505 ]

        -- Auras: SV + Generic Hunter
        addAura( 'aspect_of_the_cheetah', 186258, 'duration', 12 )
        addAura( 'aspect_of_the_cheetah_sprint', 186257, 'duration', 3 )
        addAura( 'aspect_of_the_eagle', 186289, 'duration', 10 )
        addAura( 'aspect_of_the_turtle', 186265, 'duration', 8 )
        addAura( 'butchers_bone_apron', 236446, 'duration', 30, 'max_stack', 10 )
        addAura( 'caltrops', 194279, 'duration', 6 )
        addAura( 'camouflage', 199483, 'duration', 60 )
        addAura( 'cyclonic_burst', 242712, 'duration', 5 )
        addAura( 'dragonsfire_grenade', 194858, 'duration', 8 )
        addAura( 'explosive_trap', 13812, 'duration', 10 )
        addAura( "exposed_flank", 252094, "duration", 20 )
            class.auras.t21_exposed_flank = class.auras.exposed_flank
        addAura( 'feign_death', 5384, 'duration', 360 )
        addAura( 'freezing_trap', 3355, 'duration', 60 )
        addAura( 'harpoon', 190927, 'duration', 3 )
        addAura( 'helbrine_rope_of_the_mist_marauder', 213154, 'duration', 10 )
        addAura( "in_for_the_kill", 252095, "duration", 15, "max_stack", 6 )
        addAura( 'lacerate', 185855, 'duration', 12 )
        addAura( 'moknathal_tactics', 201081, 'duration', 10, 'max_stack', 4 )
        addAura( 'mongoose_fury', 190931, 'duration', 14, 'max_stack', 6 )
        addAura( 'mongoose_power', 211362, 'duration', 10 )
        addAura( 'on_the_trail', 204081, 'duration', 12 )
        addAura( 'posthaste', 118922, 'duration', 5 )
        addAura( 'rangers_net', 206755, 'duration', 15 )
        addAura( 'rangers_net_root', 200108, 'duration', 3 )
        addAura( 'serpent_sting', 118253, 'duration', 15 )
        addAura( 'spitting_cobra', 194407, 'duration', 30 )
        addAura( 'survivalist', 164856, 'duration', 10 )
        addAura( 'tar_trap', 135299, 'duration', 60 )
        addAura( 'trailblazer', 231390, 'duration', 3600 )

        -- Auras: MM
        addAura( "bombardment", 35110, "duration", 5 )
        addAura( "binding_shot", 117405, "duration", 10 )
        addAura( "binding_shot_stun", 117526, "duration", 5 )
        addAura( "black_arrow", 194599, "duration", 8 )
        addAura( "bullseye", 204090, "duration", 6, "max_stack", 30 )
        addAura( "bursting_shot", 224729, "duration", 4 )
        addAura( "careful_aim", 63648, "duration", 8 )
        addAura( "concussive_shot", 5116, "duration", 6 )
        -- addAura( "eagle_eye", 6197 )
        addAura( "feet_of_wind", 240777, "duration", 12 )
        addAura( "hunters_mark", 185365, "duration", 12 )
        -- addAura( "hunting_party", 212658 )
        addAura( "lock_and_load", 194594, "duration", 15, "max_stack", 2 )
        addAura( "marking_targets", 223138, "duration", 15 )
        -- addAura( "marksmans_focus", 231554 )
        -- addAura( "mastery_sniper_training", 193468 )
        addAura( "sentinels_sight", 208913, "duration", 20, "max_stack", 20 )
        addAura( "steady_focus", 193534, "duration", 12 )
        -- addAura( "t20_2p_critical_aimed_damage" ) -- need aura ID.
        addAura( "trick_shot", 227272, "duration", 15 )
        addAura( "trueshot", 193526, "duration", 15 )
        addAura( "volley", 194386, "duration", 3600 )
        addAura( "vulnerable", 187131, "duration", 7 )
            class.auras.vulnerability = class.auras.vulnerable
        addAura( "true_aim", 199803, "duration", 10, "max_stack", 10 )
        addAura( "wyvern_sting", 19386, "duration", 30 ) -- Remove when hit.
    
        -- Auras: BM
        addAura( 'bestial_wrath', 19574, 'duration', 15 )
        addAura( 'aspect_of_the_wild', 193530, 'duration', 14 )

        -- Gear Sets
        addGearSet( 'tier19', 138342, 138347, 138368, 138339, 138340, 138344 )
        addGearSet( 'tier20', 147142, 147144, 147140, 147139, 147141, 147143 )
            addAura( "pre_t20_2p_critical_aimed_damage", -102, "duration", 3600, "feign", function ()
                local up = set_bonus.tier20 > 1 and prev_gcd[1].aimed_shot

                buff.pre_t20_2p_critical_aimed_damage.name = "Pre-T20 2p Critical Aimed Damage"
                buff.pre_t20_2p_critical_aimed_damage.count = up and 1 or 0
                buff.pre_t20_2p_critical_aimed_damage.expires = up and ( now + 3600 ) or 0
                buff.pre_t20_2p_critical_aimed_damage.applied = up and ( now ) or 0
                buff.pre_t20_2p_critical_aimed_damage.caster = "player"
            end )                   
            addAura( "t20_2p_critical_aimed_damage", 242243, "duration", 6 )
        addGearSet( 'tier21', 152133, 152135, 152131, 152130, 152132, 152134 )
            
        -- SV artifact
        addGearSet( 'talonclaw', 128808 )
        setArtifact( 'talonclaw' )

        -- MM artifact
        addGearSet( 'thasdorah_legacy_of_the_windrunners', 128826 )
        setArtifact( 'thasdorah_legacy_of_the_windrunners' )

        -- BM artifact
        addGearSet( 'titanstrike', 128861 )
        setArtifact( 'titanstrike' )
    
        addGearSet( 'butchers_bone_apron', 144361 )
        addGearSet( 'call_of_the_wild', 137101 )
        addGearSet( 'celerity_of_the_windrunners', 151803 )
            addAura( "celerity_of_the_windrunners", 248088, "duration", 6 )
        addGearSet( 'frizzos_fingertrap', 137043 )
        addGearSet( 'helbrine_rope_of_the_mist_marauder', 137082 )
        addGearSet( 'kiljaedens_burning_wish', 144259 )
        addGearSet( 'magnetized_blasting_cap_launcher', 141353 )
        addGearSet( "mkii_gyroscopic_stabilizer", 144303 )
            addAura( "gyroscopic_stabilization", 235712, "duration", 3600 )
        addGearSet( 'nesingwarys_trapping_threads', 137034 )
        addGearSet( 'parsels_tongue', 151805 )
            addAura( 'parsels_tongue', 248085, 'duration', 8, 'max_stack', 4 )
        addGearSet( 'prydaz_xavarics_magnum_opus', 132444 )
        addGearSet( 'qapla_eredun_war_order', 137227 )
        addGearSet( 'roots_of_shaladrassil', 132466 )
        addGearSet( 'sephuzs_secret', 132452 )
        addGearSet( 'soul_of_the_huntmaster', 151641 )
        addGearSet( 'the_shadow_hunters_voodoo_mask', 137064 )
        addGearSet( "ullrs_feather_snowshoes", 137033 )
        addGearSet( 'unseen_predators_cloak', 151807 )
        addGearSet( "war_belt_of_the_sentinel_army", 137081 )
            addAura( "sentinels_sight", 208913, "duration", 20, "max_stack", 20 )
        addGearSet( "zevrims_hunger", 137055 )
    
        setTalentLegendary( 'soul_of_the_huntmaster', 'survival', 'serpent_sting' )
        setTalentLegendary( 'soul_of_the_huntmaster', 'marksmanship', 'lock_and_load' )
        setTalentLegendary( 'soul_of_the_huntmaster', 'beast_mastery', 'bestial_wrath' )


        addHook( 'specializationChanged', function ()
            --[[ if spec.marksmanship then setSpecialization( "marksmanship" )
            elseif spec.survival then setSpecialization( "survival" )
            else setSpecialization( "beast_mastery" ) end ]]
            if spec.survival then addTalent( 'a_murder_of_crows', 206505 )
            else addTalent( 'a_murder_of_crows', 131894 ) end
            setPotion( 'old_war' ) -- true for Sv, anyway.
            setRole( 'attack' )
        end )


        addHook( 'reset_precast', function( x )
            for k in pairs( state.active_dot ) do
                state.active_dot[ k ] = nil
            end
        end )


        local floor = math.floor

        addHook( 'advance', function( t )
            if state.spec.survival then
                if not state.talent.spitting_cobra.enabled then return t end

                if state.buff.spitting_cobra.up then
                    local ticks_before = floor( state.buff.spitting_cobra.remains )
                    local ticks_after = floor( max( 0, state.buff.spitting_cobra.remains - t ) )
                    local gain = 3 * ( ticks_before - ticks_after )

                    state.gain( gain, 'focus' )
                end
            end

            return t
        end )


        addHook( 'specializationChanged', function ()
            setPotion( 'prolonged_power' )
            setRole( 'attack' )
            state.ranged = state.spec.marksmanship
        end )


        addHook( 'reset_precast', function()
            rawset( state.pet, 'ferocity', IsSpellKnown( 55709, true ) )
            rawset( state.pet, 'tenacity', IsSpellKnown( 53478, true ) )
            rawset( state.pet, 'cunning', IsSpellKnown( 53490, true ) )
        end )

        -- fake some stuff for Beast Cleave
        registerCustomVariable( 'last_multishot', 0 )
        
        -- register when I cast multishot
        RegisterUnitEvent( "UNIT_SPELLCAST_SUCCEEDED", function( _, unit, spell, _, spellID )

            if unit ~= 'player' then return end

            if spell == class.abilities[ 'multishot' ].name then
                state.last_multishot = GetTime()
            end
        
        end )
                
        -- create a fake aura
        addAura( 'beast_cleave', -100, 'name', 'Beast Cleave', 'duration', 4, 'feign', function ()
                local up = last_multishot
                buff.beast_cleave.name = 'Beast Cleave'
                buff.beast_cleave.count = up and 1 or 0
                buff.beast_cleave.expires = up and last_multishot + 4 or 0
                buff.beast_cleave.applied = up and last_multishot or 0
                buff.beast_cleave.caster = 'player'
            end )
    
        addSetting( 'moknathal_padding', true, {
            name = "Way of the Mok'Nathal Padding",
            type = "toggle",
            desc = "If checked, the addon will save an internal buffer of 25 Focus to spend on Raptor Strike for Mok'Nathal Tactics stacks.",
            width = "full"
        } )

        addSetting( 'refresh_padding', 0.5, {
            name = "Survival: Buff/Debuff Refresh Window",
            type = "range",
            desc = "The default action list has some criteria for refreshing Mok'Nathal Tactics or Serpent Sting when they have less than 1 global cooldown remaining on their durations.  If adhering strictly to this criteria, it is easy " ..
                "for the buff/debuff to fall off.  Adding a small time buffer (the default is |cFFFFD1000.5 seconds|r) will tell the addon to recommend refreshing these a little bit sooner, to prevent losing uptime.",
            min = 0,
            max = 1.5,
            step = 0.01,
            width = "full"
        } )


        addMetaFunction( 'state', 'refresh_window', function()
            return gcd + settings.refresh_padding
        end )

        addMetaFunction( 'state', 'rebuff_window', function ()
            return gcd + settings.refresh_padding
        end )

        addMetaFunction( 'state', 'active_mongoose_fury', function ()
            return buff.mongoose_fury.remains > latency * 2
        end )

        registerCustomVariable( 'last_sentinel', 0 )

        RegisterUnitEvent( "UNIT_SPELLCAST_SUCCEEDED", function( _, unit, spell, _, spellID )
            if unit ~= 'player' then return end

            if spellID == class.abilities.sentinel.id then
                state.last_sentinel = GetTime()
            end

        end )

        addAura( 'sentinel', -100, 'name', 'Sentinel', 'duration', 18, 'feign', function ()
            local t = now + offset
            local up = last_sentinel - t < 18

            buff.sentinel.name = "Sentinel"
            buff.sentinel.count = up and 1 or 0
            buff.sentinel.expires = up and ( last_sentinel + 18 ) or 0
            buff.sentinel.applied = up and last_sentinel or 0
            buff.sentinel.caster = "player"
        end )

        addMetaFunction( "state", "marks_next_gcd", function ()
            if buff.sentinels_sight.up and cooldown.global_cooldown.remains > 0 then
                local r = buff.sentinels_sight.remains
                local t = 1 + floor( r / 6 )
                local n = 1 + floor( ( r - global_cooldown.remains ) / 6 )

                if n < t then return active_enemies end
            end
            return active_dot.hunters_mark
        end )

        -- This is not technically what we want, but we don't track aura duration on non-primary targets.
        state.lowest_vuln_within = setmetatable( {}, {
            __index = function( t, k, v )
                return state.debuff.vulnerable.remains
            end
        } )

        addMetaFunction( "state", "vuln_casts", function ()
            return action.aimed_shot.vuln_casts
        end )

        -- ignoreCastOnReset( "fury_of_the_eagle" )

        local function genericHasteMod( x )
            return x * haste
        end

        setfenv( genericHasteMod, state )

        -- Beast Mastery Stuff (keeping it separate for the moment)
    
        addAbility( 'aspect_of_the_wild', {
                id = 193530,
                spend = 0,
                spend_type = 'focus',
                cast = 0,
                gcdType = 'off',
                cooldown = 120,
            })
        
        addAbility( 'bestial_wrath', {
                id = 19574,
                spend = 0,
                spend_type = 'focus',
                cast = 0,
                gcdType = 'off',
                cooldown = 90,
            })
        
        addHandler( 'bestial_wrath', function ()
                applyBuff( 'bestial_wrath', 15 )
            end )
        
        addAbility( 'cobra_shot', {
                id = 193455,
                spend = 40,
                spend_type = 'focus',
                cast = 0,
                gcd_type = 'spell',
                cooldown = 0,
            })
        
        modifyAbility( 'cobra_shot', 'spend', function( x )
                return x - ( 2 * artifact.slithering_serpents.rank )
            end )
        
        addAbility( 'dire_beast', {
                id = 120679,
                spend = 0,
                spend_type = 'focus',
                cast = 0,
                charges = 2,
                recharge = 12,
                cooldown = 12,
                gcdType = 'spell',
            })
        
        modifyAbility( 'dire_beast', 'recharge', genericHasteMod )
        modifyAbility( 'dire_beast', 'cooldown', genericHasteMod )
        
        addHandler( 'dire_beast', function()
                cooldown.bestial_wrath.expires = max( state.time, cooldown.bestial_wrath.expires - 12 )
                if equipped.qapla_eredun_war_order then
                    cooldown.kill_command.expires = max( state.time, cooldown.kill_command.expires - 3 )
                end
            end )
        
        addAbility( 'kill_command', {
                id = 34026,
                spend = 30,
                spend_type = 'focus',
                cast = 0,
                gcdType = 'spell',
                cooldown = 7.5,
            })
        
        addHandler( 'kill_command', function()
                if set_bonus.tier21_4pc > 0 then
                    cooldown.aspect_of_the_wild.expires = max( state.time, cooldown.aspect_of_the_wild.expires - 3 )
                end
            end )
                
        addAbility( 'counter_shot', {
                id = 147362,
                spend = 0,
                spend_type = 'focus',
                cast = 0,
                gcdType = 'off',
                velocity = 60,
                toggle = 'interrupts'
            })
        
        addAbility( 'multishot', {
                id = 2643,
                spend = 40,
                spend_type = 'focus',
                cast = 0,
                gcdType = 'spell',
                cooldown = 0,
            })
        
        addHandler( 'multishot', function ()
                applyBuff( 'beast_cleave', 4 )
            end )
        
        addAbility( 'titans_thunder', {
                id = 207068,
                spend = 0,
                spend_type = 'focus',
                cast = 0,
                gcdType = 'spell',
                cooldown = 60,
            })
    
        -- Abilities.

        addAbility( "aimed_shot", {
            id = 19434,
            spend = 50,
            min_cost = 50,
            spend_type = "focus",
            cast = 2,
            gcdType = "spell",
            cooldown = 0,
            min_range = 0,
            max_range = 47.171875,
            velocity = 100,
            vuln_casts = function ()
                local rem = debuff.vulnerable.remains
                if talent.sidewinders.enabled then rem = min( cooldown.sidewinders.full_recharge_time, rem ) end

                local casts = 0
                if buff.lock_and_load.up then 
                    casts = min( buff.lock_and_load.stack, floor( rem / gcd ) )
                    local lnl_rem = rem - ( gcd * casts )
                    casts = casts + floor( rem / ( 2 * haste ) )
                else
                    local cast = max( gcd, action.aimed_shot.cast )
                    casts = floor( rem / cast )
                end
                if casts == 0 then return 0 end
                
                local regen = focus.current + ( focus.regen * rem )
                return min( casts, floor( regen / ( action.aimed_shot.cost > 0 and action.aimed_shot.cost or 50 ) ) )
            end,
            in_flight = function () return prev.aimed_shot end,
        } )

        modifyAbility( 'aimed_shot', 'cast', function( x )
            if buff.lock_and_load.up then return 0 end
            return x * haste
        end )

        modifyAbility( 'aimed_shot', 'spend', function( x )
            if buff.lock_and_load.up then return 0 end
            return x
        end )

        addHandler( "aimed_shot", function ()
            removeStack( 'lock_and_load' )
            removeBuff( "trick_shot" )
            if active_dot.vulnerable == 0 or ( active_dot.vulnerable == 1 and debuff.vulnerable.up ) then
                applyBuff( "trick_shot" )
            end
            if talent.true_aim.enabled then
                applyDebuff( "target", "true_aim", 10, debuff.true_aim.stack + 1 )
            end
            if set_bonus.tier20 > 1 then
                if prev_gcd[1].aimed_shot then
                    applyBuff( "t20_2p_critical_aimed_damage" )
                    removeBuff( "pre_t20_2p_critical_aimed_damage" )
                else
                    applyBuff( "pre_t20_2p_critical_aimed_damage" )
                end
            end
            if equipped.mkii_gyroscopic_stabilizer then
                if buff.gyroscopic_stabilization.up then removeBuff( "gyroscopic_stabilization" )
                else applyBuff( "gyroscopic_stabilization" ) end
            end
            removeBuff( "sentinels_sight" )
            if equipped.ullrs_feather_snowshoes and cooldown.trueshot.expires > 0 then cooldown.trueshot.expires = cooldown.trueshot.expires - 0.8 end
        end )


        -- Arcane Shot
        --[[ A quick shot that causes 98,146 Arcane damage.    Generates 8 Focus. ]]

        addAbility( "arcane_shot", {
            id = 185358,
            spend = -8,
            spend_type = "focus",
            cast = 0,
            gcdType = "spell",
            cooldown = 0,
            notalent = "sidewinders",
            velocity = 70,
            min_range = 0,
            max_range = 47.171875,
        } )

        modifyAbility( "arcane_shot", "spend", function( x )
            if set_bonus.tier21 > 1 then return x * 1.25 end
            return x
        end )

        addHandler( "arcane_shot", function ()
            if buff.trueshot.up or buff.marking_targets.up then
                applyDebuff( "target", "hunters_mark" )
                removeBuff( "marking_targets" )
            end
            if talent.steady_focus.enabled and ( prev_gcd[1].arcane_shot or prev_gcd[1].multishot ) then
                applyBuff( "steady_focus" )
            end
            if talent.true_aim.enabled then
                applyDebuff( "target", "true_aim", 10, debuff.true_aim.stack + 1 )
            end
            if equipped.ullrs_feather_snowshoes and cooldown.trueshot.expires > 0 then cooldown.trueshot.expires = cooldown.trueshot.expires - 0.8 end
        end )


        addAbility( "aspect_of_the_chameleon", {
            id = 61648,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            cooldown = 180,
            min_range = 0,
            max_range = 0,
        } )

        addHandler( "aspect_of_the_chameleon", function ()
            applyBuff( "aspect_of_the_chameleon" )
        end )
        

        addAbility( 'aspect_of_the_cheetah', {
            id = 186257,
            spend = 0,
            spend_type = 'focus',
            cast = 0,
            gcdType = 'off',
            cooldown = 180,
        } )

        modifyAbility( 'aspect_of_the_cheetah', 'cooldown', function ()
            if equipped.call_of_the_wild then return x - ( x * 0.35 ) end
            return x
        end )

        addHandler( 'aspect_of_the_cheetah', function( x )
            applyBuff( 'aspect_of_the_cheetah_sprint', 3 )
            applyBuff( 'aspect_of_the_cheetah', 12 )
            if artifact.feet_of_wind.enabled then applyBuff( "feet_of_wind" ) end
        end )


        addAbility( 'aspect_of_the_eagle', {
            id = 186289,
            spend = 0,
            spend_type = 'focus',
            cast = 0,
            gcdType = 'off',
            cooldown = 120,
            toggle = 'cooldowns',
            recheck = function () return buff.mongoose_fury.remains - 11, buff.mongoose_fury.remains end,
        } )

        modifyAbility( 'aspect_of_the_eagle', 'cooldown', function( x )
            if equipped.call_of_the_wild then return x - ( x * 0.35 ) end
            return x
        end )

        addHandler( 'aspect_of_the_eagle', function ()
            applyBuff( 'aspect_of_the_eagle', 10 )
            stat.mod_crit_pct = stat.mod_crit_pct + 20
        end )

        
        addAbility( 'aspect_of_the_turtle', {
            id = 186265,
            spend = 0,
            spend_type = 'focus',
            cast = 0,
            gcdType = 'off',
            cooldown = 180,
        } )

        modifyAbility( 'aspect_of_the_turtle', 'cooldown', function( x )
            if equipped.call_of_the_wild then return x - ( x * 0.35 ) end
            return x
        end )

        addHandler( 'aspect_of_the_turtle', function ()
            applyBuff( 'aspect_of_the_turtle', 8 )
            setCooldown( 'global_cooldown', 8 )
        end )


        -- Barrage
        --[[ Rapidly fires a spray of shots for 2.6 sec, dealing an average of 674,082 Physical damage to all enemies in front of you. Usable while moving. ]]

        addAbility( "barrage", {
            id = 120360,
            spend = 60,
            min_cost = 60,
            spend_type = "focus",
            cast = 3,
            channeled = true,
            gcdType = "spell",
            talent = "barrage",
            cooldown = 20,
            min_range = 0,
            max_range = 47.171875,
        } )

        modifyAbility( "barrage", "spend", function ()
            if set_bonus.tier19 > 3 then return x * 0.85 end
            return x
        end )

        modifyAbility( "barrage", "cast", genericHasteMod )

        addHandler( "barrage", function ()
            if equipped.ullrs_feather_snowshoes and cooldown.trueshot.expires > 0 then cooldown.trueshot.expires = cooldown.trueshot.expires - 0.8 end
        end ) 


        -- Binding Shot
        --[[ Fires a magical projectile, tethering the enemy and any other enemies within 5 yards for 10 sec, stunning them for 5 sec if they move more than 5 yards from the arrow. Player targets are stunned for a shorter duration. ]]

        addAbility( "binding_shot", {
            id = 109248,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            talent = "binding_shot",
            cooldown = 45,
            min_range = 0,
            max_range = 35.37890625,
        } )

        addHandler( "binding_shot", function ()
            -- proto
        end )


        addAbility( "black_arrow", {
            id = 194599,
            spend = 10,
            cast = 0, 
            gcdType = "spell",
            talent = "black_arrow",
            cooldown = 15,
            velocity = 60,
        } )

        modifyAbility( "black_arrow", "cooldown", genericHasteMod )

        addHandler( "black_arrow", function ()
            applyDebuff( "target", "black_arrow" )
            if equipped.ullrs_feather_snowshoes and cooldown.trueshot.expires > 0 then cooldown.trueshot.expires = cooldown.trueshot.expires - 0.8 end
        end )


        -- Bursting Shot
        --[[ Fires an explosion of bolts at all enemies in front of you, knocking them back, disorienting them for 4 sec, and dealing 33,704 Physical damage. ]]

        addAbility( "bursting_shot", {
            id = 186387,
            spend = 10,
            min_cost = 10,
            spend_type = "focus",
            cast = 0,
            gcdType = "spell",
            cooldown = 30,
            min_range = 0,
            max_range = 0,
        } )

        modifyAbility( "bursting_shot", "cooldown", function( x )
            return ( 1 - ( 0.05 * artifact.gust_of_wind.rank ) ) * x
        end )
        
        addHandler( "bursting_shot", function ()
            applyDebuff( "target", "bursting_shot", 4 )
            if equipped.ullrs_feather_snowshoes and cooldown.trueshot.expires > 0 then cooldown.trueshot.expires = cooldown.trueshot.expires - 0.8 end
        end )
                

        addAbility( 'butchery', {
            id = 212436,
            spend = 40,
            spend_type = 'focus',
            ready = 40,
            cast = 0,
            charges = 3,
            recharge = 12,
            cooldown = 12,
            velocity = 20,
            talent = 'butchery',
            recheck = function ()
                local pool_goal = 90 - ( cooldown.flanking_strike.remains * focus.regen )
                local pool_time = focus[ "time_to_" .. pool_goal ]
                return dot.lacerate.remains - ( dot.lacerate.duration * 0.3 ), dot.lacerate.remains, dot.serpent_sting.remains - ( dot.serpent_sting.duration * 0.3 ), dot.serpent_sting.remains, pool_time
            end
        } )

        modifyAbility( 'butchery', 'ready', function( x )
            if not talent.way_of_the_moknathal.enabled or not settings.moknathal_padding then
                return x
            end

            local ticks = floor( ( buff.moknathal_tactics.remains - refresh_window ) / focus.tick_rate )
            return x + max( 0, 25 - floor( focus.regen * ticks * focus.tick_rate ) ), "focus"
        end )

        modifyAbility( 'butchery', 'recharge', genericHasteMod )
        modifyAbility( 'butchery', 'cooldown', genericHasteMod )

        addHandler( 'butchery', function ()
            -- if settings.moknathal_padding and talent.way_of_the_moknathal.enabled then gain( max( 0, 25 - focus.regen * max( 0, buff.moknathal_tactics.remains - gcd ) ), 'focus', true ) end
            removeBuff( 'butchers_bone_apron' )
            if equipped.frizzos_fingertrap and active_dot.lacerate > 0 then
                active_dot.lacerate = active_dot.lacerate + 1
            end
        end )

        
        addAbility( 'summon_pet', {
            id = 883,
            spend = 0,
            spend_type = 'focus',
            cast = 0,
            gcdType = 'spell',
            cooldown = 0,
            passive = true,
            texture = 'Interface\\ICONS\\Ability_Hunter_BeastCall',
            usable = function () return not talent.lone_wolf.enabled and not pet.exists end
        } )

        addHandler( 'summon_pet', function ()
            summonPet( 'made_up_pet', 3600, 'ferocity' )
        end )


        addAbility( 'caltrops', {
            id = 194277,
            spend = 0,
            spend_type = 'focus',
            cast = 0,
            gcdType = 'spell',
            cooldown = 15,
            passive = true,
            talent = 'caltrops',
            aura = 'caltrops',
            recheck = function () return dot.caltrops.remains - ( dot.caltrops.duration * 0.3 ), dot.caltrops.remains end,
        } )

        -- addHandler() -- Maybe for the snare?


        addAbility( 'camouflage', {
            id = 199483,
            spend = 0,
            spend_type = 'focus',
            cast = 0,
            gcdType = 'off',
            passive = true,
            talent = 'camouflage',
        } )

        addHandler( 'camouflage', function ()
            applyBuff( 'camouflage', 60 )
        end )


        addAbility( 'carve', {
            id = 187708,
            spend = 40,
            spend_type = 'focus',
            ready = 40,
            cast = 0,
            gcdType = 'melee',
            cooldown = 0,
            velocity = 60,
            notalent = 'butchery',
            recheck = function ()
                local pool_goal = 90 - ( cooldown.flanking_strike.remains * focus.regen )
                local pool_time = focus[ "time_to_" .. pool_goal ]
                return dot.lacerate.remains - ( dot.lacerate.duration * 0.3 ), dot.lacerate.remains, dot.serpent_sting.remains - ( dot.serpent_sting.duration * 0.3 ), dot.serpent_sting.remains, pool_time
            end
        } )

        modifyAbility( 'carve', 'ready', function( x )
            if not talent.way_of_the_moknathal.enabled or not settings.moknathal_padding then
                return x
            end

            local ticks = floor( ( buff.moknathal_tactics.remains - refresh_window ) / focus.tick_rate )
            return x + max( 0, 25 - floor( focus.regen * ticks * focus.tick_rate ) ), "focus"
        end )

        addHandler( 'carve', function ()
            removeBuff( 'butchers_bone_apron' )

            if talent.serpent_sting.enabled then
                applyDebuff( 'target', 'serpent_sting', 15 )
                active_dot.serpent_sting = active_enemies
            end 

            if equipped.frizzos_fingertrap and active_dot.lacerate > 0 then
                active_dot.lacerate = min( active_enemies, active_dot.lacerate + 1 )
            end
        end )


        -- Concussive Shot
        --[[ Dazes the target, slowing movement speed by 50% for 6 sec. ]]

        addAbility( "concussive_shot", {
            id = 5116,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            cooldown = 5,
            min_range = 0,
            max_range = 47.171875,
        } )

        addHandler( "concussive_shot", function ()
            applyDebuff( "target", "concussive_shot", 6 )
        end )


        -- Counter Shot
        --[[ Interrupts spellcasting, preventing any spell in that school from being cast for 3 sec. ]]

        addAbility( "counter_shot", {
            id = 147362,
            spend = 0,
            cast = 0,
            gcdType = "off",
            cooldown = 24,
            min_range = 0,
            max_range = 47.171875,
            toggle = "interrupts",
            usable = function () return target.casting end,
        } )

        addHandler( "counter_shot", function ()
            interrupt()
        end )


        addAbility( 'disengage', {
            id = 781,
            spend = 0,
            spend_type = 'focus',
            cast = 0,
            gcdType = 'off',
            cooldown = 20
        } )

        addHandler( "disengage", function ()
            if talent.posthaste.enabled then applyBuff( "posthaste" ) end 
        end )


        addAbility( 'dragonsfire_grenade', {
            id = 194855,
            spend = 0,
            spend_type = 'focus',
            cast = 0,
            gcdType = 'spell',
            cooldown = 30,
            velocity = 20,
            passive = true, -- since it could be in the air I guess.
            talent = 'dragonsfire_grenade',
        } )

        addHandler( 'dragonsfire_grenade', function ()
            applyDebuff( 'target', 'dragonsfire_grenade', 8 )
        end )


        addAbility( 'exhilaration', {
            id = 109304,
            spend = 0,
            spend_type = 'focus',
            cast = 0,
            gcdType = 'off',
            cooldown = 120,
            passive = true,
        } )

        addHandler( 'exhilaration', function ()
            health.actual = min( health.max, health.actual + ( health.max * 0.3 ) )
        end )


        -- Explosive Shot
        --[[ Fires a slow-moving munition directly forward. Activating this ability a second time detonates the Shot, dealing up to 683,411 Fire damage to all enemies within 8 yds, damage based on proximity. ]]

        addAbility( "explosive_shot", {
            id = 212431,
            spend = 20,
            min_cost = 20,
            spend_type = "focus",
            cast = 0,
            gcdType = "spell",
            talent = "explosive_shot",
            cooldown = 30,
            min_range = 0,
            max_range = 47.171875,
        } )

        addHandler( "explosive_shot", function ()
            if equipped.ullrs_feather_snowshoes and cooldown.trueshot.expires > 0 then cooldown.trueshot.expires = cooldown.trueshot.expires - 0.8 end
        end )


        addAbility( 'feign_death', {
            id = 5384,
            spend = 0,
            spend_type = 'focus',
            cast = 0,
            gcdType = 'off',
            cooldown = 30,
            passive = true,
        } )

        addHandler( 'feign_death', function ()
            applyBuff( 'feign_death', 360 )
            if equipped.the_shadow_hunters_voodoo_mask then health.actual = min( health.max, health.actual + ( health.max * 0.2 ) ) end
        end )
        

        addAbility( 'flanking_strike', {
            id = 202800,
            spend = 50,
            spend_type = 'focus',
            ready = 50,
            cast = 0,
            gcdType = 'melee',
            cooldown = 6,
            velocity = 60,
            known = function () return pet.exists end,
        } )

        modifyAbility( 'flanking_strike', 'ready', function( x )
            if not talent.way_of_the_moknathal.enabled or not settings.moknathal_padding then
                return x
            end

            local ticks = floor( ( buff.moknathal_tactics.remains - refresh_window ) / focus.tick_rate )
            return x + max( 0, 25 - floor( focus.regen * ticks * focus.tick_rate ) ), "focus"
        end )

        addHandler( 'flanking_strike', function ()
            -- if settings.moknathal_padding and talent.way_of_the_moknathal.enabled then gain( max( 0, 25 - focus.regen * max( 0, buff.moknathal_tactics.remains - gcd ) ), 'focus', true ) end
            if talent.aspect_of_the_beast.enabled then
                if pet.ferocity then

                elseif pet.tenacity then

                elseif pet.cunning then

                end
            end
        end )


        addAbility( 'fury_of_the_eagle', {
            id = 203415,
            spend = 0,
            spend_type = 'focus',
            cast = 4,
            gcdType = 'melee',
            cooldown = 45,
            velocity = 60,
            equipped = 'talonclaw',
            toggle = 'artifact',
            channeled = true,
            recheck = function () return buff.aspect_of_the_eagle.remains end,
        } )

        modifyAbility( 'fury_of_the_eagle', 'cast', genericHasteMod )

        addHandler( 'fury_of_the_eagle', function ()
            if buff.mongoose_fury.up then
                buff.mongoose_fury.expires = buff.mongoose_fury.expires + ( 4 * haste )
            end
        end )
        

        addAbility( 'harpoon', {
            id = 190925,
            spend = 0,
            spend_type = 'focus',
            cast = 0,
            gcdType = 'melee',
            cooldown = 20,
            velocity = 40,
            usable = function () return target.minR >= 8 and target.maxR <= 40 end,       
        } )

        addHandler( 'harpoon', function ()
            setDistance( 0, 5 )
            applyDebuff( 'target', 'on_the_trail', 12 )
            if talent.posthaste.enabled then
                applyBuff( 'posthaste', 5 )
            end

            if equipped.helbrine_rope_of_the_mist_marauder then
                applyDebuff( 'target', 'helbrine_rope_of_the_mist_marauder', 10 )
            end
        end )


        addAbility( 'hatchet_toss', {
            id = 193265,
            spend = 0,
            spend_type = 'focus',
            cast = 0,
            gcdType = 'melee',
            cooldown = 0,
            velocity = 40,
        } )


        addAbility( 'lacerate', {
            id = 185855,
            spend = 35,
            spend_type = 'focus',
            ready = 35,
            cast = 0,
            gcdType = 'melee',
            cooldown = 0,
            velocity = 60,
            recheck = function () 
                local pool_goal = 85 - ( cooldown.flanking_strike.remains * focus.regen )
                local pool_time = focus[ "time_to_" .. pool_goal ]

                return dot.lacerate.remains - 14, dot.lacerate.remains - ( dot.lacerate.duration * 0.3 ), dot.lacerate.remains, pool_time
            end,
        } )

        modifyAbility( 'lacerate', 'ready', function( x )
            if not talent.way_of_the_moknathal.enabled or not settings.moknathal_padding then
                return x
            end

            local ticks = floor( ( buff.moknathal_tactics.remains - refresh_window ) / focus.tick_rate )
            return x + max( 0, 25 - floor( focus.regen * ticks * focus.tick_rate ) ), "focus"
        end )

        addHandler( 'lacerate', function ()
            -- if settings.moknathal_padding and talent.way_of_the_moknathal.enabled then gain( max( 0, 25 - focus.regen * max( 0, buff.moknathal_tactics.remains - gcd ) ), 'focus', true ) end
            applyDebuff( 'target', 'lacerate', 12 + ( set_bonus.tier20_2pc == 1 and 6 or 0 ) )
        end )


        -- Marked Shot
        --[[ Rapidly fires shots at all targets with your Hunter's Mark, dealing 509,789 Physical damage and making them Vulnerable for 7 sec.     Vulnerable  Damage taken from Aimed Shot increased by 30% for 7 sec. ]]

        addAbility( "marked_shot", {
            id = 185901,
            spend = 25,
            min_cost = 25,
            spend_type = "focus",
            cast = 0,
            gcdType = "spell",
            cooldown = 0,
            min_range = 0,
            max_range = 47.171875,            
            usable = function () return active_dot.hunters_mark > 0 end,
            velocity = 60
        } )

        addHandler( "marked_shot", function ()
            if debuff.hunters_mark.up then
                applyDebuff( "target", "vulnerable" )
                removeDebuff( "target", "hunters_mark" )
            end
            active_dot.vulnerable = active_dot.hunters_mark
            active_dot.hunters_mark = 0
            if equipped.ullrs_feather_snowshoes and cooldown.trueshot.expires > 0 then cooldown.trueshot.expires = cooldown.trueshot.expires - 0.8 end
        end )


        addAbility( 'mongoose_bite', {
            id = 190928,
            spend = 0,
            spend_type = 'focus',
            cast = 0,
            gcdType = 'melee',
            charges = 3,
            recharge = 12,
            cooldown = 12,
            velocity = 20,
            recheck = function ()
                local next_charge = ( 1 - ( charges_fractional % 1 ) ) * recharge

                if charges == 0 then
                    return next_charge, next_charge + recharge, next_charge + recharge * 2
                elseif charges == 1 then
                    return next_charge, next_charge + recharge
                elseif charges == 2 then
                    return next_charge
                end
            end,
        } )

        modifyAbility( 'mongoose_bite', 'recharge', genericHasteMod )
        modifyAbility( 'mongoose_bite', 'cooldown', genericHasteMod )

        addHandler( 'mongoose_bite', function ()
            if equipped.butchers_bone_apron then
                addStack( 'butchers_bone_apron', 3600, 1 )
            end

            if buff.mongoose_fury.stack == 5 and set_bonus.tier19_4pc == 1 then
                applyBuff( 'mongoose_power', 10 )
            end

            if set_bonus.tier21_4pc > 0 then
                applyBuff( "in_for_the_kill", 15, buff.in_for_the_kill.stack + 1 )
            end

            applyBuff( 'mongoose_fury', buff.mongoose_fury.remains > 0 and buff.mongoose_fury.remains or 14, min( 6, buff.mongoose_fury.stack + 1 ) )

        end )
        

        -- Multi-Shot
        --[[ Fires several missiles, hitting your current target and all enemies within 8 yards for 55,452 Physical damage.    Generates 3 Focus per target hit. ]]

        addAbility( "multishot", {
            id = 2643,
            spend = -3,
            min_cost = 0,
            spend_type = "focus",
            cast = 0,
            gcdType = "spell",
            cooldown = 0,
            notalent = "sidewinders",
            min_range = 0,
            max_range = 47.171875,
            velocity = 50,
        } )

        modifyAbility( "multishot", "spend", function( x )
            if set_bonus.tier21 > 1 then x = x * 1.25 end
            return x * active_enemies
        end )

        addHandler( "multishot", function ()
            if buff.marking_targets.up or buff.trueshot.up then
                applyDebuff( "target", "hunters_mark" )
                removeBuff( "marking_targets" )
                active_dot.hunters_mark = active_enemies
            end
            if talent.steady_focus.enabled and ( prev_gcd[1].arcane_shot or prev_gcd[1].multishot ) then
                applyBuff( "steady_focus" )
            end
            if equipped.war_belt_of_the_sentinel_army then
                addStack( "sentinels_sight", 20, active_enemies )
            end
            if equipped.ullrs_feather_snowshoes and cooldown.trueshot.expires > 0 then cooldown.trueshot.expires = cooldown.trueshot.expires - 0.8 end
        end )


        addAbility( 'muzzle', {
            id = 187707,
            spend = 0,
            spend_type = 'focus',
            cast = 0,
            gcdType = 'melee',
            cooldown = 15,
            velocity = 60,
            toggle = 'interrupts',
            usable = function () return target.casting end,
        } )

        addHandler( 'muzzle', function ()
            interrupt()
        end )

        registerInterrupt( 'muzzle' )


        -- Piercing Shot
        --[[ A powerful shot which deals up to 1.3 million Physical damage to the target and up to 653,017 Physical damage to all enemies between you and the target. Damage increased against targets with Vulnerable. ]]

        addAbility( "piercing_shot", {
            id = 198670,
            spend = 20,
            spend_type = "focus",
            cast = 0,
            gcdType = "spell",
            talent = "piercing_shot",
            cooldown = 30,
            min_range = 0,
            max_range = 47.171875,
            recheck = function ()
                return focus.time_to_86, focus.time_to_101, focus.time_to_106
            end,
            velocity = 100,
        } )

        addHandler( "piercing_shot", function ()
            spend( min( focus.current, 80 ), "focus" )
            if equipped.ullrs_feather_snowshoes and cooldown.trueshot.expires > 0 then cooldown.trueshot.expires = cooldown.trueshot.expires - 0.8 end
        end )


        addAbility( 'rangers_net', {
            id = 200108,
            spend = 30,
            spend_type = 'focus',
            ready = 30,
            cast = 0,
            gcdType = 'spell',
            cooldown = 1,
            velocity = 40,
        } )

        modifyAbility( 'rangers_net', 'ready', function( x )
            if not talent.way_of_the_moknathal.enabled or not settings.moknathal_padding then
                return x
            end

            local ticks = floor( ( buff.moknathal_tactics.remains - refresh_window ) / focus.tick_rate )
            return x + max( 0, 25 - floor( focus.regen * ticks * focus.tick_rate ) ), "focus"
        end )

        addHandler( 'rangers_net', function ()
            -- if settings.moknathal_padding and talent.way_of_the_moknathal.enabled then gain( max( 0, 25 - focus.regen * max( 0, buff.moknathal_tactics.remains - gcd ) ), 'focus', true ) end
            applyDebuff( 'target', 'rangers_net_root', 3 )
            applyDebuff( 'target', 'rangers_net', 15 )
        end )


        addAbility( 'raptor_strike', {
            id = 186270,
            spend = 25,
            spend_type = 'focus',
            cast = 0,
            gcdType = 'melee',
            cooldown = 0,
            recheck = function ()
                local pool_goal = 75 - ( gcd * focus.regen )
                local pool_time = focus[ "time_to_" .. pool_goal ]

                if talent.way_of_the_moknathal.enabled then
                    return buff.moknathal_tactics.remains - gcd * 4, buff.moknathal_tactics.remains - rebuff_window, buff.moknatha_tactics.remains - gcd, buff.moknathal_tactics.remains, pool_time
                end
                return pool_time
            end
        } )

        addHandler( 'raptor_strike', function ()
            if talent.way_of_the_moknathal.enabled then
                addStack( 'moknathal_tactics', 10, 1 )
            end

            if talent.serpent_sting.enabled then
                applyDebuff( 'target', 'serpent_sting', 15 )
            end

            removeBuff( "exposed_flank" )
            removeBuff( "in_for_the_kill" )
        end )

        -- Sentinel
        --[[ Your Sentinel watches over the target area for 18 sec, applying Hunter's Mark to all enemies every 6 sec. ]]

        addAbility( "sentinel", {
            id = 206817,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            talent = "sentinel",
            cooldown = 60,
            min_range = 0,
            max_range = 47.171875,
        } )

        addHandler( "sentinel", function ()
            applyBuff( "sentinel" )
        end )


        -- Sidewinders
        --[[ Launches Sidewinders that travel toward the target, weaving back and forth and dealing 251,866 Nature damage to each target they hit. Cannot hit the same target twice. Applies Vulnerable to all targets hit.    Generates 35 Focus. ]]

        addAbility( "sidewinders", {
            id = 214579,
            spend = -40,
            spend_type = "focus",
            cast = 0,
            gcdType = "spell",
            talent = "sidewinders",
            cooldown = 12,
            charges = 2,
            recharge = 12,
            min_range = 0,
            max_range = 47.171875,
            -- velocity = 18,
        } )

        modifyAbility( "sidewinders", "spend", function( x )
            if set_bonus.tier21 > 1 then return x * 1.25 end
            return x
        end )

        modifyAbility( "sidewinders", "cooldown", genericHasteMod )
        modifyAbility( "sidewinders", "recharge", genericHasteMod )

        addCooldownMetaFunction( "sidewinders", "full_recharge_time", function( x )
            if not talent.sidewinders.enabled then return 0 end
            return ( cooldown.sidewinders.max_charges - cooldown.sidewinders.charges_fractional ) * cooldown.sidewinders.recharge
        end )

        addHandler( "sidewinders", function ()
            if buff.marking_targets.up or buff.trueshot.up then
                applyDebuff( "target", "hunters_mark" )
                active_dot.hunters_mark = active_enemies
                removeBuff( "marking_targets" )
            end
            if talent.steady_focus.enabled then
                applyBuff( "steady_focus" )
            end
            if equipped.ullrs_feather_snowshoes and cooldown.trueshot.expires > 0 then cooldown.trueshot.expires = cooldown.trueshot.expires - 0.8 end
        end )
        

        addAbility( 'spitting_cobra', {
            id = 194407,
            spend = 0,
            spend_type = 'focus',
            cast = 0,
            gcdType = 'spell',
            cooldown = 60,
            toggle = 'cooldowns',
            talent = 'spitting_cobra'
        } )

        addHandler( 'spitting_cobra', function ()
            summonPet( 'spitting_cobra', 30 )
            applyBuff( 'spitting_cobra', 30 )
            -- focus.regen = focus.regen + 3
        end )


        addAbility( 'snake_hunter', {
            id = 201078,
            spend = 0,
            spend_type = 'focus',
            cast = 0,
            gcdType = 'off',
            cooldown = 120,
            talent = 'snake_hunter',
            toggle = 'cooldowns',
        } )

        addHandler( 'snake_hunter', function ()
            gainCharges( 'mongoose_bite', 3 )
        end )


        addAbility( 'freezing_trap', {
            id = 187650,
            spend = 0,
            spend_type = 'focus',
            cast = 0,
            gcdType = 'spell',
            cooldown = 30,
            passive = true,
            notalent = 'steel_trap',
        } )


        addAbility( 'explosive_trap', {
            id = 191433,
            spend = 0,
            spend_type = 'focus',
            cast = 0,
            gcdType = 'spell',
            cooldown = 30,
            velocity = 10,
            passive = true
        } )

        addHandler( 'explosive_trap', function ()
            gain( 25, 'focus' )
        end )


        addAbility( 'tar_trap', {
            id = 187698,
            spend = 0,
            spend_type = 'focus',
            cast = 0,
            gcdType = 'spell',
            cooldown = 30,
            passive = true,
            notalent = 'caltrops'
        } )


        addAbility( 'steel_trap', {
            id = 162488,
            spend = 0,
            spend_type = 'focus',
            cast = 0,
            gcdType = 'spell',
            cooldown = 60,
            passive = true,
            talent = 'steel_trap'
        } )

        addHandler( 'steel_trap', function ()
            gain( 25, 'focus' )
        end )



        addAbility( 'sticky_bomb', {
            id = 191241,
            spend = 0,
            spend_type = 'focus',
            cast = 0,
            gcdType = 'spell',
            cooldown = 25,
            velocity = 20,
            talent = 'sticky_bomb'
        } )


        addAbility( 'throwing_axes', {
            id = 200163,
            spend = 15,
            spend_type = 'focus',
            cast = 0,
            gcdType = 'melee',
            cooldown = 15,
            charges = 2,
            recharge = 15,
            velocity = 40,
            talent = 'throwing_axes'
        } )

        modifyAbility( 'throwing_axes', 'cooldown', genericHasteMod )
        modifyAbility( 'throwing_axes', 'recharge', genericHasteMod )

        
        -- Trueshot
        --[[ Increases haste by 40% and causes Arcane Shot and Multi-Shot to always apply Hunter's Mark. Lasts 15 sec. ]]

        addAbility( "trueshot", {
            id = 193526,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            cooldown = 180,
            min_range = 0,
            max_range = 0,
            toggle = "cooldowns"
        } )

        local ts_qs_ranks = { 10, 20, 30, 38, 45, 52, 58 }

        modifyAbility( "trueshot", "cooldown", function( x )
            return x - ( ts_qs_ranks[ artifact.quick_shot.rank ] or 0 )
        end )

        addCooldownMetaFunction( 'trueshot', 'duration_guess', function ()
            return cooldown.trueshot.duration * 0.7
        end )

        addCooldownMetaFunction( 'trueshot', 'remains_guess', function ()
            return cooldown.trueshot.remains * 0.7
        end )

        addHandler( "trueshot", function ()
            applyBuff( "trueshot" )
        end )


        -- Volley
        --[[ While active, your auto attacks spend 3 Focus to also launch a volley of shots that hit the target and all other nearby enemies, dealing 76,542 additional Physical damage. ]]

        addAbility( "volley", {
            id = 194386,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            talent = "volley",
            cooldown = 1.5,
            min_range = 0,
            max_range = 0,
        } )

        addHandler( "volley", function ()
            if buff.volley.down then
                applyBuff( "volley" )
            elseif buff.volley.up then
                removeBuff( "volley" )
            end
            -- need 3 focus per second drain.
        end )


        -- Windburst
        --[[ Focuses the power of Wind through Thas'dorah, dealing 674,083 Physical damage to your target, and leaving behind a trail of wind for 5 sec that increases the movement speed of allies by 50%. ]]

        addAbility( "windburst", {
            id = 204147,
            spend = 20,
            min_cost = 20,
            spend_type = "focus",
            cast = 1.5,
            gcdType = "spell",
            cooldown = 20,
            min_range = 0,
            max_range = 47.171875,
            toggle = "artifact",
            in_flight = function () return prev_gcd[1].windburst end,
            velocity = 50,
        } )

        modifyAbility( "windburst", "cast", genericHasteMod )

        addHandler( "windburst", function ()
            if equipped.celerity_of_the_windrunners then applyBuff( "celerity_of_the_windrunners" ) end
            if equipped.ullrs_feather_snowshoes and cooldown.trueshot.expires > 0 then cooldown.trueshot.expires = cooldown.trueshot.expires - 0.8 end
            if artifact.mark_of_the_windrunner.enabled then applyDebuff( "target", "vulnerable" ) end
        end )


        -- Wyvern Sting
        --[[ A stinging shot that puts the target to sleep, incapacitating them for 30 sec. Damage will cancel the effect. Usable while moving. ]]

        addAbility( "wyvern_sting", {
            id = 19386,
            spend = 0,
            cast = 1.5,
            gcdType = "spell",
            talent = "wyvern_sting",
            cooldown = 45,
            min_range = 0,
            max_range = 47.171875,
        } )

        modifyAbility( "wyvern_sting", "cast", genericHasteMod )

        addHandler( "wyvern_sting", function ()
            applyDebuff( "target", "wyvern_sting" )
        end )


        addAbility( 'a_murder_of_crows', {
            id = 206505,
            spend = 30,
            spend_type = 'focus',
            ready = 30,
            cast = 0,
            gcdType = 'spell',
            cooldown = 60,
            velocity = 60,
            talent = 'a_murder_of_crows'
        }, 131894 )

        modifyAbility( 'a_murder_of_crows', 'id', function( x )
            if not spec.survival then return 131894 end
            return x
        end )

        modifyAbility( 'a_murder_of_crows', 'ready', function( x )
            if spec.survival then
                if not talent.way_of_the_moknathal.enabled or not settings.moknathal_padding then
                    return x
                end

                local ticks = floor( ( buff.moknathal_tactics.remains - refresh_window ) / focus.tick_rate )
                return x + max( 0, 25 - floor( focus.regen * ticks * focus.tick_rate ) ), "focus"
            end
        end )

        addHandler( 'a_murder_of_crows', function ()
            -- if settings.moknathal_padding and talent.way_of_the_moknathal.enabled then gain( max( 0, 25 - focus.regen * max( 0, buff.moknathal_tactics.remains - gcd ) ), 'focus', true ) end
            applyDebuff( 'target', 'a_murder_of_crows', 15 )
        end )

    end


    storeDefault( [[SimC Survival: CDs]], 'actionLists', 20171128.180630, [[d0Z8faGEqjAtuPAxuyBKs0(aLQVrqMnqZhuXnb0Pv42GCzv7ek7vA3eTFHgfPKgguzCksL7rkLHQiLgSGHtfhIkLCkQuCmk6WkTqfvlLuSyeTCsEiOQvPifltr8CQAIGsAQeyYiz6qUib16OsPEgOsxhHnckHTsQ0MrQTROmnsj8BrFgGVtkvJurQ6POgnu18aLYjjv8ykDnfjNNu1Fj0RPsoiO4AwbLH1tVeGOoVm2c9Y8ac(yGjuZgZwq3ogGhw9L1CWV(xSj4mfY0CY0zyc3P0ctZYSvnCqLldJfnsPVckMzfuwy5scEQoVmBvdhuz60s4nSek1LOya20wmaxCLHHCaoq6lVk7kVikvQlrL1rsnSlkvLLP8LbMu6UkSf6LlJTqVmmk7kFmiivQlrL1CWV(xSj4mfYexzn3Nek79vqrLHh)TUaMZo0LOswgysHTqVCrfBsfuwy5scEQoVmBvdhuzscAAJ17ClsmPfr4V4xaG3GWPmmKdWbsFzYR8x5Aibuwhj1WUOuvwMYxgysP7QWwOxUm2c9YZVYFLRHeqznh8R)fBcotHmXvwZ9jHYEFfuuz4XFRlG5SdDjQKLbMuyl0lxuXGBfuwy5scEQoVmBvdhuzscAAJ17ClsmPfr4V4xaG3GWPmmKdWbsFzsWmPePju6lRJKAyxuQklt5ldmP0Dvyl0lxgBHE55GzsfdWccL(YAo4x)l2eCMczIRSM7tcL9(kOOYWJ)wxaZzh6sujldmPWwOxUOIPfvqzHLlj4P68YSvnCqLjjOPnwVZTiXKweH)IFbaEdcNyW9yqRXajbnTb5v(RCnKamiCIb4aNyGKGM2GemtkrAcLEdcNyWnLHHCaoq6l7KOrklRJKAyxuQklt5ldmP0Dvyl0lxgBHE5PnrJuwwZb)6FXMGZuitCL1CFsOS3xbfvgE836cyo7qxIkzzGjf2c9YfvSPQGYclxsWt15LzRA4GkBZeKk1U0akLaY0FrYb6gw8RcW9XG2IbCXG7XajbnTbukbKP)I0ek9gQdTdPpgG9yaUXW0edaSuXG7XGwJbBMGuP2LgR35wKyslIWFXVaaVH6q7q6JbypgMkgCpgCRyGKGM2y9o3IetAre(l(fa4niCIb3uggYb4aPVSxUUUiEcj6QY6iPg2fLQYYu(YatkDxf2c9YLXwOxMLRRhdtpHeDvznh8R)fBcotHmXvwZ9jHYEFfuuz4XFRlG5SdDjQKLbMuyl0lxuX0YkOSWYLe8uDEz2QgoOYRfnMDrOucit)fPju6Jb3JbTgd2mbPsTlnGsjGm9xKCGUHf)QaCFmOTyaxmah4edKe00gqPeqM(lstO0BOo0oK(ya2IbtZyWnLHHCaoq6lVENBrIjTic)f)ca8L1rsnSlkvLLP8LbMu6UkSf6LlJTqVmmENBrXqshdi8pgeEba(YAo4x)l2eCMczIRSM7tcL9(kOOYWJ)wxaZzh6sujldmPWwOxUOIkZo3owWbSCrJuwSjtnvrTa]] )

    storeDefault( [[SimC Survival: AOE]], 'actionLists', 20171128.180630, [[dCJpdaGEOeTjjPSlLKxRKAFss1Sf18Hk1nf42k1oLyVu7gv7NO(jucddkghekdMidxqhusCkOsogIwiPYsHOfJslNKhIIEkyzi06Gq1eHqmvLyYqA6kUiPQNl0LvDDu4BqWwHQSzOuTDj1HLAAqP8zjjNMWHGq6zqfgnPy8qjDse0Jf5AiW5jL(ns)fQQrbv0M0lgqKJ9MrESodLEFdGyZuwcyOQf1DgXLLQGf6nG853X7crmKiqsseXwrIdcWgjPbiPeHJbdvsJGYJEXfsVyqpVzZh16muHvKfJwdSmMKMR0AGqoQi1dvzGt53qaffVwv69nyO07BqhJjP5kTgq(874DHigseiXya5JugQ0JEXJbMAEADaT(7ZhZAiGIw69n4XfIEXGEEZMpQ1zaskr4yarLLgrATGxLHkSISy0Ai15rrdJgiKJks9qvg4u(neqrXRvLEFdgk9(gy25rrdJgq(874DHigseiXya5JugQ0JEXJbMAEADaT(7ZhZAiGIw69n4XfC4fd65nB(OwNHkSISy0A4ynmtJI6J)O6qdeYrfPEOkdCk)gcOO41QsVVbdLEFd6XAyMgf1xwAr1Hgq(874DHigseiXya5JugQ0JEXJbMAEADaT(7ZhZAiGIw69n4XfS5fd65nB(OwNbiPeHJbCklnD(8zv8QWZh8JJGx1QZB28rLLQMSekDwfVk88b)4i4vTsDSREutZMVSeUKLWnULLWPSuNgr9X)8VfpklvDzjcKLWLHkSISy0Ai1Q6BGqoQi1dvzGt53qaffVwv69nyO07BGzRQVbKp)oExiIHebsmgq(iLHk9Ox8yGPMNwhqR)(8XSgcOOLEFdE8yacFs0zbw2JGYDHibe4Xg]] )

    storeDefault( [[SimC Survival: default]], 'actionLists', 20180317.095948, [[d4JUjaGEsQwMs0UuQY2erY(ijQMjjHFty2OCAf3uKoVsLVbv8qL0oHYEL2nr7hIFkIuddv14ijYHPAOIiAWQQHtPCqi5uKsDmLY5uQkTqOQwkPyXKQLtXIqv8uWJf16GknrOkmvvPjJktxLlQk6QKeLNbvPRtj)fsTvuL2SQW2jXLrMLsvX0GQOVRuvDBbVwegnLQpReojjLNl01er19ijDireoUikJIuYDRVfWd6HBXUIFbWgLhNnQ73iKfBzYtEbneJ8ivSL83WzBBPkT3MkXpPWBbiBgBxHcOY3iKX(wST(w4P01zexXVaKnJTRGwiFkzwJnBe3EpmJ6QlIOFmYfK5mUnKV2fqPpS52vqXnJRZOcR2PCIuHcfi5v9cPcoEDdMhOcpmJ6QlIptM1yZgXvaZdub4egc5ZRZSOcOmlIfKEGu9HzuxDr8zYSgB2iU9rXzwKQArjZASzJ42BdV4WhpXR2f0qmYJuXwYFdNn(f0qrHLjtX(2RGAsUj7NWuqkKuVITSVfEkDDgXv8lazZy7kOfY)CgjV92VVdT4b6ZoHoisi9ZUZ2JKUoJ4q(AxaL(WMBxbf3mUoJkSANYjsfkuGKx1lKk441nyEGkeejEDgjpIRaMhOcWjmeYNxNzriFT20UakZIybPhivdIeVoJKhXTpkoZIuvRZzK82B)(o0IhOp7e6GiH0p7oBps66mIt7cAig5rQyl5VHZg)cAOOWYKPyF7vqnj3K9tykifsQxXWBFl8u66mIR4xaL(WMBxbRiHEokelOMKBY(jmfKcjvivWXRBW8avOaMhOcQSiH8v7OqSGgIrEKk2s(B4SXVGgkkSmzk23EfwTt5ePcfkqYR6fsfCyEGk0Ry4zFl8u66mIR4xaYMX2vOak9Hn3Ucbl1vNrfutYnz)eMcsHKkKk441nyEGkuaZduHul1vNrf0qmYJuXwYFdNn(f0qrHLjtX(2RWQDkNivOqbsEvVqQGdZduHEfl59TWtPRZiUIFbiBgBxbf3mUoJ2lis86msEexbu6dBUDfYoJH2Z3iKOzt8kSANYjsfkuGKx1lKk441nyEGkuaZduHvNXq(OY3iKiFvmXRakZIybPhiv5bMWkYhSmkJIZWf5hejs9rE(i5PGgIrEKk2s(B4SXVGgkkSmzk23EfutYnz)eMcsHKkKk4W8avaMWkYhSmkJIZWf5hejs9rE(i7vSKQVfEkDDgXv8lGsFyZTRq2zm0E(gHenBIxb1KCt2pHPGuiPcPcoEDdMhOcfW8avy1zmKpQ8ncjYxft8q(ATPDbuMfXcspqQYdmHvKpyzugfNHlYFfpI8uqdXipsfBj)nC24xqdffwMmf7BVcR2PCIuHcfi5v9cPcompqfGjSI8blJYO4mCr(R4rSxXWPVfEkDDgXv8lazZy7k45Bui0KKcdfr(QCvr(4Tak9Hn3UczNXq75Bes0SjEfwTt5ePcfkqYR6fsfC86gmpqfkG5bQWQZyiFu5BesKVkM4H81AP2fqzweli9aPkpWewr(GLrzuCgUiFuj9tEkOHyKhPITK)goB8lOHIcltMI9Txb1KCt2pHPGuiPcPcompqfGjSI8blJYO4mCr(Os6N9kMk13cpLUoJ4k(fGSzSDfscKVNVrHqheYfcrKq)WYSRak9Hn3UczNXq75Bes0SjEfwTt5ePcfkqYR6fsfC86gmpqfka2f7pvWnpgYel(fW8avy1zmKpQ8ncjYxft8q(AHxTlGYSiwq6bsvEGjSI8blJYO4mCr(pggJmrEkOHyKhPITK)goB8lOHIcltMI9Txb1KCt2pHPGuiPcPcompqfGjSI8blJYO4mCr(pggJmXEfBF7BHNsxNrCf)cq2m2UcjbY3Z3OqOdc5cHisOFyz2vaL(WMBxHSZyO98ncjA2eVcR2PCIuHcfi5v9cPcoEDdMhOcfW8avy1zmKpQ8ncjYxft8q(AHNAxaLzrSG0dKQ8atyf5dwgLrXz4I81NJEnZIfKHNcAig5rQyl5VHZg)cAOOWYKPyF7vqnj3K9tykifsQqQGdZdubycRiFWYOmkodxKV(C0RzwSGm9k2g)(w4P01zexXVaKnJTRGNVrHqheYfcrKq)WYSRak9Hn3UczNXq75Bes0SjEfwTt5ePcfkqYR6fsfC86gmpqfkG5bQWQZyiFu5BesKVkM4H81k5AxaLzrSG0dKQ8atyf5dwgLrXz4I81NJss7EK4PGgIrEKk2s(B4SXVGgkkSmzk23EfutYnz)eMcsHKkKk4W8avaMWkYhSmkJIZWf5RphLK29i1RxbmpqfGjSI8blJYO4mCr(C0d3ID9Ab]] )

    storeDefault( [[SimC Survival: precombat]], 'actionLists', 20171128.180630, [[dqdbeaGEIu1UKO02isLzlQBsIBtv7KI9I2nH9lrgMQyCejzOKuAWIKHlLoOe6yq1ZLQfkIwQuSyIA5K6Huspf8yOSoIuAIKumvk1KL00HCrj43Q8msQCDsYYuvTvvL2SevBNi(irsDyHptK40uzKeP4BIuJwegpjvDsvj)Ls01OeoVQuttIIlR8AvftCAtqnR8qvgXKemHFeaN3APuGkTeNKilTLs1Qh25LdeHMLx0hn)p4PXX)LQYIRolkdoobat7Areiued5orN20GtBcfeHCEvMKqrzx2HEtORY7pHLTdr4LO6Wc0PjioXiOC1VH2e(rGGj8JG1iNlLsTdvkfoHMLx0hn)p4PXFi0S(PsJToTjIG1ed7JYjz(jquMGYvnHFeiIMFAtOGiKZRYKekk7Yo0BcThYDccVevhwGonbXjgbLR(n0MWpcemHFeu7HCNGqZYl6JM)h804peAw)uPXwN2erWAIH9r5Km)eiktq5QMWpcerJ6OnHcIqoVktsOOSl7qVjm13MVUtYSePJwcVevhwGonbXjgbLR(n0MWpcemHFekO(281DswPu26OLqZYl6JM)h804peAw)uPXwN2erWAIH9r5Km)eiktq5QMWpcertzOnHcIqoVktsOOSl7qVj0rBzlr6OLWlr1HfOttqCIrq5QFdTj8Jabt4hbaTLlLYwhTeAwErF08)GNg)HqZ6Nkn260MicwtmSpkNK5Narzckx1e(rGiASG2ekic58QmjHIYUSd9Mqvhs5e9YD6zPu0te1r4LO6Wc0PjioXiOC1VH2e(rGGj8JGA0HuorVCNELsj16jI6i0S8I(O5)bpn(dHM1pvAS1PnreSMyyFuojZpbIYeuUQj8Jar0iD0MqbriNxLjjuu2LDO3ese627eeEjQoSaDAcItmckx9BOnHFeiyc)iinHU9obHMLx0hn)p4PXFi0S(PsJToTjIG1ed7JYjz(jquMGYvnHFeiIicq7WCr2j9bYDcA(TWcIib]] )

    storeDefault( [[SimC Survival: fillers]], 'actionLists', 20171128.180630, [[dieOlaqikv1LuffBcjvJsrCkQQwfLkELQO0TOev7cPmmvLJrvwgvLNbLKPrPsxdjLTPkc(MQuJtvKCoOKQ1PkcnpvrL9rjkhKuXcrsEOQWevfvDrvjBekP8rvruNKuPzQkICtj1ovQLIepf1uvvTvkH9k(RI0Gj6WsTys5XuzYk5YGntQ6ZivJMs50u8Ajz2kCBOA3e(nIHROoUQi1YH8CjMUkxhk2oL03PeX4PePZdLA9uQY8HsSFsoE5p8Zd6BmJlufE34qy2G)qjzmiRgR94jQK6nJbGkHPadOlq2((8E7557PO5HvuZUEEHzhYmFHdRJ7merj)z7L)WVeT2awHQWSdzMVWoczSiwIGgorqNqkWunZb0C2AeDOOKpNsIvH1rZmmh2H1pArLrqFA5qMkiSUILX1hbfwqeq4AYYIgTBCiC4DJdHXAJwuze0vs(qMkimfyaDbY23N3BVVWuGcbdYbL8Nl8dBGRQMyfWbXfTW1K1UXHW5Y2x(d)s0AdyfQcRJMzyoSdxMn3ze0N6iAOoSUILX1hbfwqeq4AYYIgTBCiC4DJdH5zZDgbDL8brd1HPadOlq2((8E79fMcuiyqoOK)CHFydCv1eRaoiUOfUMS2noeox2yv(d)s0AdyfQcRJMzyoSdVqnDIOO3GGP0rGOxqyDflJRpckSGiGW1KLfnA34q4W7ghc)8OMoru0BqGs(KrGOxqykWa6cKTVpV3EFHPafcgKdk5px4h2axvnXkGdIlAHRjRDJdHZLTDZF4xIwBaRqvy2HmZxyeOhbfBT2ausSGfL0(k5zCvgb9W6OzgMd7WJ2bO(GW6kwgxFeuybraHRjllA0UXHWH3noe(j1oa1heMcmGUaz77Z7T3xykqHGb5Gs(Zf(HnWvvtSc4G4Iw4AYA34q4CztT8h(LO1gWkufMDiZ8fwdJE90oFEt9npfS0zsbwt1pArfnmZkj1vs7RKwBKP1ganCs1FpaXbRW6OzgMd7WOE(iOPLdzQGW6kwgxFeuybraHRjllA0UXHWH3noeMspFeKsYhYubHPadOlq2((8E79fMcuiyqoOK)CHFydCv1eRaoiUOfUMS2noeox2pH8h(LO1gWkufMDiZ8fEIsE9aehTcGMbXnTCgbDAGO1gWsjPUsAFLCroAfandIBA5mc60oJRYiORK(dRJMzyoSdJ65JGMwoKPccRRyzC9rqHfebeUMSSOr7ghchE34qyk98rqkjFitfOKt88hMcmGUaz77Z7T3xykqHGb5Gs(Zf(HnWvvtSc4G4Iw4AYA34q4Cz)o)HFjATbScvHzhYmFHrGEeuS1AdqjXcwus7RKNXvze0dRJMzyoSdxoagtpuphwxXY46JGcliciCnzzrJ2noeo8UXHW8bWqj)r9CykWa6cKTVpV3EFHPafcgKdk5px4h2axvnXkGdIlAHRjRDJdHZL9tL)WVeT2awHQWSdzMVWiqpck2ATbOKyblkP9vYZ4Qmc6H1rZmmh2HD94qK5syDflJRpckSGiGW1KLfnA34q4W7ghc)OhhImxctbgqxGS995927lmfOqWGCqj)5c)Wg4QQjwbCqCrlCnzTBCiCUSX65p8lrRnGvOkSoAMH5WomyPZdsXyfMEOEoSUILX1hbfwqeq4AYYIgTBCiC4DJdHFzPZdsXyfuYFuphMcmGUaz77Z7T3xykqHGb5Gs(Zf(HnWvvtSc4G4Iw4AYA34q4Cz79L)WVeT2awHQWSdzMVWwBKP1gan9iJ9ShP86PXyMNHLssDLCroAJ2bO(aAiqpck2ATbOKuxjNOK6jomfAomieioL0YuYjk5eLKAFk5ZQK29tj9RKwUsorjNOKoczSiwIGM(rlQmc6tlhYub0qaEBefL8zus6ULs6xjTJsorj1tCyk0qaDqOK2rjP7wkPFL0Vs6xj9hwhnZWCyhwdZ5SbiSdRRyzC9rqHfebeUMSSOr7ghchE34qyQWCoBac7WuGb0fiBFFEV9(ctbkemihuYFUWpSbUQAIvahex0cxtw7ghcNlBpV8h(LO1gWkufMDiZ8f2AJmT2aOPhzSN9iLxpngZ8mSusQRKlYrB0oa1hqdb6rqXwRnaLK6k5eLupXHPqZHbHaXPKwMsorjNOKu7tjFwL0UFkPFL0YvYjk5eL0riJfXse00pArLrqFA5qMkGgcWBJOOKpJss3Tus)kPDuYjkPEIdtHgcOdcL0okjD3sj9RK(vs)kP)W6OzgMd7WUgzfcRRyzC9rqHfebeUMSSOr7ghchE34q4hnYkeMcmGUaz77Z7T3xykqHGb5Gs(Zf(HnWvvtSc4G4Iw4AYA34q4Cz75l)HFjATbScvH1rZmmh2H1pArLrqFA5qMkiSUILX1hbfwqeq4AYYIgTBCiC4DJdHXAJwuze0vs(qMkqjN45pmfyaDbY23N3BVVWuGcbdYbL8Nl8dBGRQMyfWbXfTW1K1UXHW5Y2dRYF4xIwBaRqvy2HmZx4jkP1gzATbqdNu93dqCWsjPUsQHrVEA4KkrF26X0RDNXvOHa82ikk5ZPK0DlL0okPDvs)kjwWIsorj1tCyk0CyqiqCkPLPKtuYjk5BQPKwUsQN4WuOHa6GqjTJss3Tus)kPFL0FyD0mdZHDyupFe00YHmvqyDflJRpckSGiGW1KLfnA34q4W7ghctPNpcsj5dzQaLCIp)HPadOlq2((8E79fMcuiyqoOK)CHFydCv1eRaoiUOfUMS2noeoxUW8m4m9WyV(mer2(Og1YLa]] )

    storeDefault( [[SimC Survival: mokMaintain]], 'actionLists', 20171128.180630, [[dmdJbaGEGs7ss9AOA2aMpi6Mq42Q0oHYEv2nj7hXOiQggvYVjmyKgUu6GGsNIkCmPAHeflfuTyQQLtQhckEkQLbrRtsYebIMkKAYsX0fUiqQll66uLTcKSzISDQOdt5BGutdOyEGKXjj1JLy0uPoTQojq4zGW1KeNNO0FHKVdu9Cv86d9yqMsMhqmzgJz3Cm)xyiu2t78DAavrOxboc7vH9QXWtG0o5Wq6QdDVJS66oevatVpMl6Vngpg2s8c1zOhwFOhdAL5dKntMXCr)TXy5eQVNKu9vGRSWTbGkSs8LtToV2RoekueQCcvN(EssOa)vncWjuhekKqsOYjuFpjP6RaxzHBdavyL4lN6tyfCcfkcfcc1bH6ymS(pWhYowBTHqJ6e6hphdcvZxSqOhReQCmcrdOmnMDZXJXSBogU1gcnHYH(XZXWtG0o5Wq6QdD31y45r4Pl5zOxmgg3zbhHWzEtvm)Xieny2nhVyXyUnlVb8G1IxOggYkvwSb]] )

    storeDefault( [[SimC Survival: bitePhase]], 'actionLists', 20180317.095948, [[dq0hlaqicv5sQkP2eHknkusNcLyvQkvVsvjAwGQu3sHOAxKIHbshJswgPQNbQQPPqexJuQ2MQsY3uvzCQkLZPqcRtHunpqvY9uiSpcv1bvvSqvv9qf0evvcxeuzJkK0hvirNKqzMkKYnPu7uvgQcrzPOupfzQGyRKs2R4VQWGPQdl1Ij4Xsmzv6YqBgf9zqz0KkNMKxtiZws3wr7gv)wPHJclNONtX0bUUkA7kW3jLY4juX5vOwVcrA(GQy)u5yfiH(cKzFwb5FiIbwuDvnsBGA55Px7ApeBSITbZtpuRFww6)MgRVb9RGFiQivmaHc9Paul3ei5zfiHGJ3cv8M)HOIuXaeQSB9UAJRzUCy7AWdbfa1u01syOX5hHZd)qFeuvfyCO5YHTRbpeuamKy8RQ0GvgIVCmK9E1QLVEIHc96jgYE5W21Go)FfadXgRyBW80d16Nf0qSrZEklOjqci0qDyrK9oaNiheHq2791tmua5PpqcbhVfQ4n)drfPIbiKWjtMAMlh2Ug8G5PCSgjoBf348IVZZQZdRCD(V78S68LDR3vBCnZLdBxdEiOaOMIUwcdno)x68woploplH(iOQkW4qmRnxKId7WaKkryiX4xvPbRmeF5yi79QvlF9edf61tm0OwBUifhMZtaPsegInwX2G5PhQ1plOHyJM9uwqtGeqOH6WIi7DaoroicHS37RNyOaYd(bsi44TqfV5FiQivmaH6cqnapMlh2Ug8G5PCCOpcQQcmo0C5W21Ghckagsm(vvAWkdXxogYEVA1YxpXqHE9edzVCy7AqN)VcGopRwSeInwX2G5PhQ1plOHyJM9uwqtGeqOH6WIi7DaoroicHS37RNyOaYBKeiHGJ3cv8M)HOIuXaeIvNx8C(bTu1cvuZCfbPRihGxNhEGhNNvNx4KjtnZveVb666bOlavXOrIZwXnoV478S68WkxN)7opRo)3C(V25HVZZIZZIZZIZZIZlUoV458cNmzQPnmWc4yzEa0HhydRIAoze6JGQQaJdX8uo(yzEa0HhydRIHgQdlIS3b4e5GieYEVA1YxpXqHE9ednQNYXo)Y05b6qNhUgwfd9rcZesXbOuEYaCOMt8QAaocl4TIdqP8Kb4qXCeLDR3vBCnZLdBxdEiOaOMIUwcdnJa(Wd8WkqvezoK4SvC41iSexHtMm1mxr8gORRhGUaufJgjoBf3aVGQ5hlHyJvSnyE6HA9ZcAi2OzpLf0eibesm(vvAWkdXxogYEVVEIHcipThiHGJ3cv8M)HOIuXae6Uan1UGYgGAKitjA01cv05fxNNvNN5wonAkNsjYboV478S68S68AhQZ)Lop81UZZIZpYDEwDEwD(YU17QnUgM1MlsXHDyasLiuJeNTIBC(V25HvUoplo)3DEwDEMB50OrIWqUZ)DNhw568S48S48S48Se6JGQQaJdv7ckBagsm(vvAWkdXxogYEVA1YxpXqHE9ednADbLnadXgRyBW80d16Nf0qSrZEklOjqci0qDyrK9oaNiheHq2791tmua59vbsi44TqfV5FiQivmaHeozYudqV1HEghO4Wyn49GzT5I0CYi0hbvvbghs2maR8WaKkryiX4xvPbRmeF5yi79QvlF9edf61tme7MbyLopbKkryi2yfBdMNEOw)SGgInA2tzbnbsaHgQdlIS3b4e5GieYEVVEIHciVFbsi44TqfV5FOpcQQcmoKHHcauCyhLvq2HeJFvLgSYq8LJHS3RwT81tmuOxpXqedfaO4WC(HRGSdXgRyBW80d16Nf0qSrZEklOjqci0qDyrK9oaNiheHq2791tmua59TajeC8wOI38p0hbvvbgh6kByl3WujXdysK3xmKy8RQ0GvgIVCmK9E1QLVEIHc96jg6lKnSLByQKOZpkLiVVyi2yfBdMNEOw)SGgInA2tzbnbsaHgQdlIS3b4e5GieYEVVEIHciVrrGecoEluXB(h6JGQQaJdzaiwpaYMriX4xvPbRmeF5yi79QvlF9edf61tmebqS68qKnJqSXk2gmp9qT(zbneB0SNYcAcKacnuhwezVdWjYbriK9EF9edfqEwqdKqWXBHkEZ)qFeuvfyCO(yEkVO8yzEuKR2mHeJFvLgSYq8LJHS3RwT81tmuOxpXqFCE7t5fLo)Y05hkxTzcXgRyBW80d16Nf0qSrZEklOjqci0qDyrK9oaNiheHq2791tmua5zzfiHGJ3cv8M)HOIuXaes8CEGQisXHf6JGQQaJdv6kqUmmHeJFvLgSYq8LJHS3RwT81tmuOxpXqd7kqUmmHyJvSnyE6HA9ZcAi2OzpLf0eibeAOoSiYEhGtKdIqi79(6jgkG8S0hiHGJ3cv8M)H(iOQkW4qO4WOUg1a8aiBgHeJFvLgSYq8LJHS3RwT81tmuOxpXqWjomQRrnaDEiYMri2yfBdMNEOw)SGgInA2tzbnbsaHgQdlIS3b4e5GieYEVVEIHcipl4hiHGJ3cv8M)HE9ednSRvN)tbOwUZpAkdievKkgGqHyJM9uwqtGeqOpcQQcmouPR1JUaul)OQmGqIXVQsdwzi(YXqSXk2gmp9qT(zbnK9EF9edrQ5qNNoLdud66O78mv1kknbeqOxpXqKAo05Pt5a1GUo6oVGcGJmDTbdiba]] )

    storeDefault( [[SimC Survival: biteTrigger]], 'actionLists', 20171128.180630, [[dqZicaGEHqBseSlrYRfI2NqvZKaz2qCtP42s1ovXEP2nQ2VGHjjJJqXGj1WjKdQsCmuSqvklLGwmKworpuLQNISmjSocutvsnzuA6Q6IQK(gbCzW1fPEmjBvO0HvA7IOZlKCAO(SuAEcv(TIVtO0OLOMMqQtkuSkcvUMi09iu1ZecEUO(RezZ4Atx5lkcWAutNTdMiC)EqtPLjXjxebh0O4hQL42wqAsiGaBg8POIragMcXKIXejcu4fbhX9Xd3NIet00f1JhE21(W4Atx5lkcW6BMiLel6njH(I55GoUGMj6GoHGodFj0HNoN6XGSOQu0IubD8bDvqNqqRMbHDelpvF4TZKHsO4hsjH(I55GoUGUvXg0IlOJGPlOye8hLjKvbY9btXWzXQ9hPj(WbtndBSR8SDWKPZ2btcAvGCFWKqab2m4trfJamvMec5jTubzx7309YGkYMjj0b(Butnd7z7Gj)(u4Atx5lkcW6BMiLel6nPkVYwih0Xl(GUW0fumc(JYuF4TZKHsO4hmfdNfR2FKM4dhm1mSXUYZ2btMoBhm1m82zYqqFd)GjHacSzWNIkgbyQmjeYtAPcYU2VP7LbvKntsOd83OMAg2Z2bt(9BIusSO3KFB]] )

    storeDefault( [[SimC Marksmanship: patient sniper]], 'actionLists', 20180318.135342, [[dCeUKaqiiklIII0LOibBss1OusDkLKvrrjELsjMLsj5wuuu7sLggboMs1YKuEguvyAqvPRrrsBdQk6Buunoks05OOuToLsQMhuvDpksTpOkhKIyHkfEOsrtKIIOlcbojevRKIeQzQusPBsO2PKmuLskwke5PkMkeARkL6RuueElfLYDPOK2lP)cLbl6WsTyi9yknzjUmYMPWNjKrRQ60GETQIztv3wf7gLFJQHdvworpNkth46QY2vIVRQ04POW5HGwpfjK5tq7xyDxruheWAupvuuDQ6dPZapBgP4w(XDAM7hIBRhjUgajgishdIJK6m4ilS9qtrnaYzAvntfF1bjYtTJ0QAc2nLcWh7MFRTJV4ZDZUoJvcXb0rhtSaiN5ue1QDfrDqaRr9ur3qNXkH4a6y5CFH)LDDWc9fYkK0DnEEpMKS)TueHbGhshtqHEiaH6S0syJ6jDqoRaTnGl1HXzKoI5LTBzvFiDwEEg2xiRW)QtvFiDeAnmeiWAnmmBdGlPi3U9pYSkuQJjsroDy9Hm9YZZW(czf(3TIJZ0ocan2QL2)itB5CFH)LDDWc9fYkK0DnEEpMKS)TueHbGhARwA)JWiVJmDHqFgg3LNNrYg1txjDAiZTvwoRabqoZ0G2tmW1bl0xiRqs3LynQNk1TCUVW)YUoyH(czfs6UgpVhts2)wkIWaWdH)cH(mmUlppJKnQNUs60qMthKip1osRQjy38Db6Ge54pPLCkIkqNn)j7hX8f6qmGIQJyEPQpKokqRQPiQdcynQNk6g6mwjehqN2cGC2THhQG5(5G7YZZWSTd40XeuOhcqOolTe2OEshKZkqBd4sDyCgPJyEz7ww1hsNLNNH1WdMTDaNoZp)RyEbAajPtr1PQpKocTggceyTggMTbWLuKB3(hzwfkJC9(kDmrkYPdRpKPxEEgwdpy22bCBfhNPDeyRwA)JmDBbqo72WdvWC)CWD55zy22bC6Ge5P2rAvnb7MVlqhKih)jTKtrub6S5pz)iMVqhIbuuDeZlv9H0rbAf(qruheWAupv0n0zSsioGolTe2OE6U88mSVqwH)ns8hzBbqo72WdvWC)CW12oagaEOifkmYLwcBupDxEEg2xiRW)gjErU0syJ6P7YZZWA4bZ2oGlsZsKTfa5SBdpubZ9ZbxYmi7dqya4HIClrkYwIClrk4URJjOqpeGqDwAjSr9KoiNvG2gWL6W4mshX8Y2TSQpKo2MHjYw0z(5FfZlqdijD6g6u1hshHwddbcSwddZ2a4skYTB)JmRcLrUU2kDmrkYPdRpKPTndtKTSvlT)rMEPLWg1t3LNNH9fYk8V4VTaiNDB4HkyUFo4ABhadapKqHlTe2OE6U88mSVqwH)fVLwcBupDxEEgwdpy22bCML2cGC2THhQG5(5GlzgK9bima8qBrKTCpTzSfb3DDqI8u7iTQMGDZ3fOdsKJ)KwYPiQaD28NSFeZxOdXakQoI5LQ(q6OaTcFve1bbSg1tfDdDgReIdOdOLIiWfapegGJvGuK4pYLwcBupDxEEg2xiRW)gz9iBlaUqyeJoqYfPPJCxhtqHEiaH6yBVhRTaiNH5HoGoiNvG2gWL6W4mshX8Y2TSQpKo6u1hshHwddbcSwddZ2MT3hPjwaKZICRf6aMvHsDmrkYPdRpKPnth4zZif3YpUtZC)qCB9ibTuebkqYmvhKip1osRQjy38Db6Ge54pPLCkIkqNn)j7hX8f6qmGIQJyEPQpKod8SzKIB5h3PzUFiUTEKGwkIafiPaTYuve1bbSg1tfDdDgReIdOJLZ9f(x2fhKKwiteM7NdUpCrwpY2cGlegXOdKCrA6i3JSEKRJSqOpdJ7YZZizJ6P7dxK1Je9zyCxEEgjBupDL0PHmxK4pY9ixPJjOqpeGqDWbjPfYeH5(5aDqoRaTnGl1HXzKoI5LTBzvFiD0PQpKoBnqsAHmrro)CGoirEQDKwvtWU57c0bjYXFsl5uevGoB(t2pI5l0HyafvhX8svFiDuGwHpve1bbSg1tfDdDgReIdOJLZ9f(x2fhKKwiteM7NdUpCrwpY2cGlegXOdKCrIxK7rwpYcH(mmUlppJKnQNUpCrwpY1rUosKfj6ZW4cKpY9Zb3hUiRhPb3(Cx7tkjgis8I0ukiY6rUoYcH(mmUlppJKnQNUs60qMls8h5EKcfgzHqFgg3)hdqsh2PLFUpCrUkYvrkuyKRJe9zyCbYh5(5G7dxK1J0GBFUR9jLedejErUlWuJSEKfc9zyCxEEgjBupDL0PHmxK4ps8zKRICLoMGc9qac1bhKKwiteM7Nd0b5Sc02aUuhgNr6iMx2ULv9H0rNQ(q6S1ajPfYef58ZbrUEFLoirEQDKwvtWU57c0bjYXFsl5uevGoB(t2pI5l0HyafvhX8svFiDuGwzUIOoiG1OEQOBOZyLqCaDAlaUqyeJoqYfjErUhz9ibTNyGlqcTFWC)CWLynQNkrwpYcH(mmUlppJKnQNUs60qMls8I02oagaEOiRh56irFggxhXaqg5DyoOOFW1bA7NiXZ0r2waCHWigDGKlsZsKMAKcfgj6ZW46igaYiVdZbf9dUoqB)e5wICDKTfaximIrhi5I0uiYArUks8ISMGifkmY1r6iagkN9CxaKK1eGvdNns8IuqK1JezrI(mmUGAcWQHdZkHaOT9yn8qfSsFAr09HlY6rItsl3gEOcM7NdICvKcfgj6ZW4652pynRG55D5(Wfz9iBlaUqyeJoqYfj(JeFe5kDmbf6HaeQtdpubZ9Zb6GCwbABaxQdJZiDeZlB3YQ(q6OtvFiDmbEOsKZphOdsKNAhPv1eSB(UaDqIC8N0sofrfOZM)K9Jy(cDigqr1rmVu1hshfOvMsfrDqaRr9ur3qNXkH4a60waCHWigDGKls8ICxhtqHEiaH6CA5hQG5(5aDqoRaTnGl1HXzKoI5LTBzvFiD0PQpKoIB5hQe58Zb6Ge5P2rAvnb7MVlqhKih)jTKtrub6S5pz)iMVqhIbuuDeZlv9H0rbALzxruheWAupv0n0zSsioGoTfaximIrhi5IeVi3JSEKRJe9zyCpT8dKjcd0sreWDF4IuOWirFggxG8rUFo4(Wf5kDmbf6HaeQZ55bq3phOdYzfOTbCPomoJ0rmVSDlR6dPJov9H0r8ZdGM55Nd0bjYtTJ0QAc2nFxGoiro(tAjNIOc0zZFY(rmFHoedOO6iMxQ6dPJc0QDbkI6GawJ6PIUHoJvcXb0zPLWg1t3LNNH1WdMTDaxK4pY9iRhjYICPLWg1txCCUhYeHzWLy4GK0czI0XeuOhcqOoFHSc6t6a6GCwbABaxQdJZiDeZlB3YQ(q6OtvFiDmtazf0N0b0bjYtTJ0QAc2nFxGoiro(tAjNIOc0zZFY(rmFHoedOO6iMxQ6dPJc0Q9DfrDqaRr9ur3qNXkH4a6S0syJ6PRTzyISLiRh56irwKlTe2OE6IJZ9qMimdUedhKKwituKcfg56ile6ZW4U88ms2OE6kPtdzUiXlsr2sK1J0GBFUR9jLedejErAkn1ixf5QWuSoiro(tAjNIOc0XeuOhcqOoO(2(bRLs(xDqoRaTnGl1HXzKoirEQDKwvtWU57c0PQpKoB4B7Ninrk5FvGwTxtruheWAupv0n0zSsioGoRJezrU0syJ6Ploo3dzIWm4smCqsAHmrrkuyKfc9zyCxEEgjBupDL0PHmxK4fPiBjYvrwpY1rcAPicCbWdHb4yfifjEMoY2cGC2TXopzHKyCdmRK)1DTCUVW)YIClrwEYga5SifkmsqlfrG7p1EW)fNfej(JSMGifkmsqlfrGlaEimahRaPiXFK74Zixfz9ixAjSr90D55zyn8GzBhWfPPJuGoMGc9qac1PXopzHKyCdmRK)1PdYzfOTbCPomoJ0rmVSDlR6dPJov9H0XKif)Kfsgj3iYnL8VoDqI8u7iTQMGDZ3fOdsKJ)KwYPiQaD28NSFeZxOdXakQoI5LQ(q6OaTAhFOiQdcynQNk6g6mwjehqN2cGlegXOdKCrIxK1IuOWixhjOLIiW9NAp4)IZcIe)rwtqK1Je9zyCrFEVJqiDDG2(js8hzntnYv6yck0dbiuh0wkBrKoiNvG2gWL6W4mshX8Y2TSQpKo6u1hsNnAPSfr6Ge5P2rAvnb7MVlqhKih)jTKtrub6S5pz)iMVqhIbuuDeZlv9H0rbA1o(QiQdcynQNk6g6mwjehqNcH(mmUlppJKnQNUpCrwps0NHX1ZTFWAwbZZ7Y9HlY6rUosKf5slHnQNU44CpKjcZGlXWbjPfYefPqHrwi0NHXD55zKSr90vsNgYCrIxKISLixPJjOqpeGqDA4HkyUFoqhKZkqBd4sDyCgPJyEz7ww1hshDQ6dPJjWdvIC(5GixVVshKip1osRQjy38Db6Ge54pPLCkIkqNn)j7hX8f6qmGIQJyEPQpKokqR2nvfrDqaRr9ur3qNXkH4a60waCHWigDGKls8ICpY6rwi0NHXD55zKSr90vsNgYCrIxKKzq2hGWaWdfz9ixhjYICPLWg1txCCUhYeHzWLy4GK0czIIuOWixhPb3(Cx7tkjgis8ICxGGiRhzHqFgg3LNNrYg1txjDAiZfjErUosYmi7dqya4HIClrkYwICvKRICLoMGc9qac1PHhQG5(5aDqoRaTnGl1HXzKoI5LTBzvFiD0PQpKoMapujY5NdICDTv6Ge5P2rAvnb7MVlqhKih)jTKtrub6S5pz)iMVqhIbuuDeZlv9H0rbA1o(uruheWAupv0n0zSsioGoTfaximIrhi5IeVi3JSEKlTe2OE6ABgMiBjY6rAWTp31(KsIbIClrABhatsIiwKBjY2cGC2THhQG5(5GRTDamjjIyrI)in42N7EAZiY6rUosKf5slHnQNU44CpKjcZGlXWbjPfYefPqHrwi0NHXD55zKSr90vsNgYCrIxKISLixPJjOqpeGqDoppa6(5aDqoRaTnGl1HXzKoI5LTBzvFiD0PQpKoIFEa0mp)CqKR3xPdsKNAhPv1eSB(UaDqIC8N0sofrfOZM)K9Jy(cDigqr1rmVu1hshfOv7MRiQdcynQNk6g6mwjehqN2cGlegXOdKCrA6i3JSEKRJezr6iagkN9CxaKK1eGvdNns8IuqKcfgjYISTaiNDB4HkyUFo4czygEOOFqKcfgj6ZW4cQjaRgomRecG22J1WdvWk9PfrxjDAiZfjEr2waKZUn8qfm3phCTTdGbGhkYTePiBjYvrwpY1rU0syJ6P7YZZWA4bZ2oGls8IuqKcfgzBbqo7(fYkOpPdCHmmdpu0piY6rISiDeadLZEUlasYA7y4loBK4fPGixfz9ixAjSr9012mmr2sK1J0GBFUR9jLede5wI02oaMKerSi3sKTfa5SBdpubZ9ZbxB7aysseXIe)rAWTp390MrK1JCDKilYLwcBupDXX5EiteMbxIHdsslKjksHcJSqOpdJ7YZZizJ6PRKonK5IeVifzlrUshtqHEiaH60sBZim3phOdYzfOTbCPomoJ0rmVSDlR6dPJov9H0XePTzuKZphOdsKNAhPv1eSB(UaDqIC8N0sofrfOZM)K9Jy(cDigqr1rmVu1hshfOv7MsfrDqaRr9ur3qNXkH4a6aApXaxhSqFHScjDxI1OEQez9ixhzHqFgg3LNNrYg1txjDAiZfjErABhadapuKcfg56irFggxp3(bRzfmpVl3c)llY6r2waKZUFHSc6t6axidZWdf9dICvKRISEKRJCPLWg1t3LNNH9fYk8VrAMJCDKKzq2hGWaWdfPzjYLwcBupDxEEgwdpy22bCrUks8h5EKcfgPb3(C3czaTqqK430rABhatsIiwKcfgj6ZW4cKpY9Zb3hUixfz9ixhzBbWfcJy0bsUinDK7rkuyKgC7ZDTpPKyGiXlYDbcICLoMGc9qac1PHhQG5(5aDqoRaTnGl1HXzKoI5LTBzvFiD0PQpKoMapujY5NdICn(yLoirEQDKwvtWU57c0bjYXFsl5uevGoB(t2pI5l0HyafvhX8svFiDuGwTB2ve1bbSg1tfDdDgReIdOdYIe0EIbUoyH(czfs6UeRr9ujY6rUoYcH(mmUlppJKnQNUs60qMls8I02oagaEOifkmY1rI(mmUEU9dwZkyEExUf(xwK1JSTaiND)czf0N0bUqgMHhk6hez9ixhjYI0ramuo75UaijRTJHV4SrIxKcIuOWile6ZW4()yas6WoT8ZTW)YICvKRICvK1JCDKilYLwcBupDXX5EiteMbxIHdsslKjksHcJSqOpdJ7YZZizJ6PRKonK5IeVijZGSpaHbGhkYTePiBjYv6yck0dbiuNgEOcM7Nd0b5Sc02aUuhgNr6iMx2ULv9H0rNQ(q6yc8qLiNFoiY147kDqI8u7iTQMGDZ3fOdsKJ)KwYPiQaD28NSFeZxOdXakQoI5LQ(q6OaTQMafrDqaRr9ur3qNXkH4a6GSibTNyGRdwOVqwHKUlXAupvISEKRJCDKOpdJRNB)G1ScMN3L7dxK1JSqOpdJ7YZZizJ6PBH)Lf5QifkmY1rU0syJ6P7YZZW(czf(3iXFKTfa5SBdpubZ9ZbxB7aya4HISEKilYLwcBupDXX5EiteMbxIHdsslKjkY6rUosKfzBbqo7(fYkOpPdCHmmdpu0pisHcJ0ramuo75UaijRTJHV4SrIxKcICvK1JCDKRJ0GBFUR9jLedejErIpn1ifkms0NHXfiFK7NdUpCrkuyKRJCpstHiBaOTFW(BhGICvK4f5(T2U5rkuyKRJCpstHiBaOTFW(BhGICvK4f5(D389iRhPJayOC2ZDbqswtag(IZgjErkiYvrkuyKocGHYzp3fajzTDm8fNns8IuqK1Jezr6iagkN9CxaKK1eGvdNns8IuqKRICvKR0XeuOhcqOoNw(HkyUFoqhKZkqBd4sDyCgPJyEz7ww1hshDQ6dPJ4w(Hkro)CqKR3xPdsKNAhPv1eSB(UaDqIC8N0sofrfOZM)K9Jy(cDigqr1rmVu1hshfOv12ve1bbSg1tfDdDgReIdOdO9edCDWc9fYkK0DjwJ6PsK1JCDKlTe2OE6U88mSgEWSTd4Ie)rUhPqHrI(mmUa5JC)CW9HlsHcJCPLWg1t3LNNH9fYk8VrI)iBlaYz3gEOcM7NdU22bWaWdf5kDmbf6HaeQZPLFOcM7Nd0b5Sc02aUuhgNr6iMx2ULv9H0rNQ(q6iULFOsKZphe56AR0bjYtTJ0QAc2nFxGoiro(tAjNIOc0zZFY(rmFHoedOO6iMxQ6dPJc0QA1ue1bbSg1tfDdDgReIdOJb3(Cx7tkjgiYTePTDamjjIyrIxKgC7ZDpTzez9irFggxp3(bRzfmpVl3c)llY6rISirFggxhXaqg5DyoOOFW9HthtqHEiaH60WdvWC)CGoiNvG2gWL6W4mshX8Y2TSQpKo6u1hshtGhQe58ZbrU2uxPdsKNAhPv1eSB(UaDqIC8N0sofrfOZM)K9Jy(cDigqr1rmVu1hshfOv1WhkI6GawJ6PIUHoJvcXb0zDKilYcH(mmU)pgGKoStl)CF4IuOWixhjYIe9zyCpT8dKjcd0sreWDF4ISEKils0NHXfiFK7NdUpCrUkYvrwpY1rUos0NHX90YpqMimqlfra39HlY6rU0syJ6P7YZZWA4bZ2oGls8h5EKRIuOWirFggxG8rUFo4(WfPqHrA)BPiYHziBlaYzTps8IC)A2JCLoMGc9qac1Xbl0xiRqsNoiNvG2gWL6W4mshX8Y2TSQpKo6u1hsNbwOVqwHKoDqI8u7iTQMGDZ3fOdsKJ)KwYPiQaD28NSFeZxOdXakQoI5LQ(q6OaTQg(QiQdcynQNk6g6mwjehqN2cGlegXOdKCrA6i3JSEKRJezrU0syJ6Ploo3dzIWm4smCqsAHmrrkuyKfc9zyCxEEgjBupDL0PHmxK4fPiBjYv6yck0dbiuNwABgH5(5aDqoRaTnGl1HXzKoI5LTBzvFiD0PQpKoMiTnJIC(5GixVVshKip1osRQjy38Db6Ge54pPLCkIkqNn)j7hX8f6qmGIQJyEPQpKokqRQzQkI6GawJ6PIUHoJvcXb0PTa4cHrm6ajxK4f5EK1JCDKilYLwcBupDXX5EiteMbxIHdsslKjksHcJSqOpdJ7YZZizJ6PRKonK5IeVifzlrUshtqHEiaH6CEEa09Zb6GCwbABaxQdJZiDeZlB3YQ(q6OtvFiDe)8aOzE(5GixxBLoirEQDKwvtWU57c0bjYXFsl5uevGoB(t2pI5l0HyafvhX8svFiDuGc0Xmjz0ppq3qbQc]] )

    storeDefault( [[SimC Marksmanship: default]], 'actionLists', 20180317.214619, [[daK9iaqiQQIfHQWMqvAuceNsGQzbcPDrvgMI6yG0YarpJQQ00OQQCnHOTrfP8nQQmoqiwhiyEuvvDpHW(eOCqryHOQ8qQktKks6IcjNui1mbH6MIYoj0sfrpLYufkxLks1wPI6TurCxufTxO)kQgSKoSslMk9ysMmOUmYMj4ZuHrlsNwvVwrmBsDBf2Tu)gy4OYXPIelNONJY0v56cA7c47cvNhvvRxG08vK2VeJqXyOfvVUAcgDrZ4i1V6pO79GgfHms)dnNkjSH6d5dTKKMwgHIqodfIm7Vq9ZdAKrcjuicAMs(ChAOLqDpOzymuekgdTO61vtWiFOzk5ZDOroLWNJJG9yexAyqz5msjPRu5TuVv6GopyYnuqWtTS7BhEHCLkVLQca0WG4TNBOGGhJ4sddklNrkjDEHCLkVLQ)uQUHccEmIlnmOSCgPK05fYHwc3x)h)OPaH9rYCwk4ql6g(v7bKO1GMqlda78kf3bHgAI7GqZhiSpswQwk4qljPPLrOiKZq9d6mAjjgiuQiggdp08LsQjzGa0G6dDrldalUdcn8qriXyOfvVUAcg5dTeUV(p(rlKr5)rdgAr3WVApGeTg0eAzayNxP4oi0qtCheAtvccZZkLGGtC6mQuJ(ObJNtLOLK00YiueYzO(bDgTKedekvedJHhA(sj1KmqaAq9HUOLbGf3bHgEOO)IXqlQED1emYhAMs(ChAR6(auo104jwPgSsfYsL3s1nuqWlaqRj(9GbXB0s4(6)4hTaaTM4hTOB4xThqIwdAcTmaSZRuCheAOLKyGqPIyym8qtCheAod0AIF0siDWq7aoCOPianAjjnTmcfHCgQFqNrZsbXZaWVWtsgYhA(sj1KmqaAq9HUOLbGf3bHgEOO)HXqlQED1emYhAMs(ChA3QP(84EsQ(2rolfCEuVUAcUu5TuvaGggeV94EsQ(2rolfCEsASFZkv)VuJSu5TuHj3qbbVaH6MKRRM8K0y)MvQbRuvaGggeV94EsQ(2rolfCEsASFZkvEl1GuQUHccENmKyPGZdgeVl1Ptl1vDFakNAA8eRuJOuHwQbhTeUV(p(rlWk)1vtOfDd)Q9as0AqtOLbGDELI7GqJda0F7ixaiZ5EsQ(2bAjjgiuQiggdp0e3bH2uLGW8Ssji4e7asQuDE1HepNkrlH0bdTEhueCaG(Bh5cazo3ts13oGObwDifXTAQppUNKQVDKZsbNh1RRMG5vbaAyq82J7jP6Bh5SuW5jPX(nZ)JKxnioXU8aH6op(FPF7fzWM5vdItSlpqOUZJ)x63ErgmfaOHbXBpUNKQVDKZsbNNKg73mEdIBOGG3jdjwk48GbX7Ptx19bOCQPXtSiGgC0ssAAzekc5mu)GoJMLcINbGFHNKmKp08LsQjzGa0G6dDrldalUdcn8qXiXyOfvVUAcg5dTeUV(p(rtTAD(QUh056NDOfDd)Q9as0AqtOLbGDELI7GqdnXDqOnvjimpRuccoX3Q1LAc19GUuH4ND8CQeTeshm06DqrWd7h(k1SvoHn2ML(CqOuvaGggeVz8aTKKMwgHIqod1pOZOLKyGqPIyym8qZxkPMKbcqdQp0fTmaS4oi0SF4RuZw5e2yBw6ZbHsvbaAyq8MHhk60WyOfvVUAcg5dntjFUdTB1uFEC79uF5S(5iPh1RRMGrlH7R)JF0uRwNVQ7bDU(zhAr3WVApGeTg0eAzayNxP4oi0qtCheAtvccZZkLGGt8TADPMqDpOlvi(zhpNkl1Gan4OLq6GHwVdkcEy)WxPMTYjSX2S0NdcLk3Ep1xPY6NJK8aTKKMwgHIqod1pOZOLKyGqPIyym8qZxkPMKbcqdQp0fTmaS4oi0SF4RuZw5e2yBw6ZbHsLBVN6Ruz9Zrs8qr)WyOfvVUAcg5dntjFUdn)PuVvt95XT3t9LZ6NJKEuVUAcgTeUV(p(rtTAD(QUh056NDOfDd)Q9as0AqtOLbGDELI7GqdnXDqOnvjimpRuccoX3Q1LAc19GUuH4ND8CQSudcKbhTeshm06DqrWd7h(k1SvoHn2ML(CqOuBqxQC79uFLkRFosYd0ssAAzekc5mu)GoJwsIbcLkIHXWdnFPKAsgianO(qx0YaWI7GqZ(HVsnBLtyJTzPphek1g0Lk3Ep1xPY6NJK4HhAI7GqZ(HVsnBLtyJTzPphekvysyd1hEic]] )

    storeDefault( [[SimC Marksmanship: precombat]], 'actionLists', 20180317.214619, [[dqdtcaGEQs1Uqr51cvZwH5tvPBIk3ffvFtiTtQSxYUHA)cyyOQFRQHsvXGfOHJchuqDmiwOGSuP0IvQLROhIsEkyzkPNlQjsvstvkMSunDvUOq5YixxjonfBffzZOuBhs5XI8vQcnnQc(ovjoSKXrvLrle3MsNes8mQQ6AqsNhs1FPkL3svuRJQile1iigU2dQRTaGbLm1W496mpwUvu9GaVsSRLXPqcAPbvzsUvEe)49hjkZqqf1ve)eaPPHXjqq40zECwnYHOgbXW1EqDfsq4Tzyo0fKxS2h7ng0jafC3KQ7NcWpMeW9DMQPRSKabUYscyvJrGG(qxGGicAPbvzsUvEKOi8cAP8Vmtuwn6eWkcLIZ9OrwcFAlG77UYsc0j3QAeedx7b1vibH3MH5qxaJ)mpwak4Ujv3pfGFmjG77mvtxzjbcCLLe4BInBE(uInBp7ZFMhZCFNcAPbvzsUvEKOi8cAP8Vmtuwn6eWkcLIZ9OrwcFAlG77UYsc0jN)QrqmCThuxHeeEBgMdDbEXG77Lz(eGcUBs19tb4htc4(ot10vwsGaxzjbE0G77Lz(e0sdQYKCR8irr4f0s5FzMOSA0jGvekfN7rJSe(0wa33DLLeOtNaxzjbGXYkqqUAgpBlCoIHHNceKXKsVDxNoja]] )

    storeDefault( [[SimC Marksmanship: cooldowns]], 'actionLists', 20180317.214619, [[d8tnfaqAkTEQiztur4TkvW2OIu7tPkESiVwvQzlQ5dk3eG7Quj(gsX9ufANGSxPDtQ9tYOuf1WeQXPuvDyedvPIAWumCGCqa5uQcoMs5zurTqvjlLkSyv1Yj8qKQEkQLjeRtPs1evQKMkqnzbtxXfrQ8kQi6YqxxjBuPISvQK2mrTDQu9xa1HuQuMMsv67uPmpLQYNrknAq1TrYjPs8CQ6AQICEH0kvQq)wLDrK7wbxMon5NXq)LzqyYsYwNIm2txOipT3Y7kktw5PVk7aZiXJfks82(JDEJgPTNEkY2(lZjHf0uUmqPXEAFbxOTcUmDAYpJH(QmNewqtz5lT8sbu2MSJYSNhvgNJvgNqzEwz2nLzizupsEBaDZQdOWlHAYpJbLbgmLjDxoCUPL82a6MvhqHxkbNiOf9kZ(uMikZdLb6BZ2jAzIir0iWZjeOEk7IoytK5eL1Ngld4cUseqekSCzicfwgirIOrLb8jeOEk7aZiXJfks8gnBXLDG(BjsOVG7uME4y6nGZDKc1t)LbCbicfwUtHIuWLPtt(zm0xL5KWcAk)xYYsJyHE43iTavgOVnBNOL)OWJI3wnTLDrhSjYCIY6tJLbCbxjcicfwUmeHcl)cfEu82QPTSdmJepwOiXB0Sfx2b6VLiH(cUtz6HJP3ao3rkup9xgWfGiuy5ofY5cUmDAYpJH(QmNewqt5)swwAel0d)gPfOYa9Tz7eT8pFxay5LiAzx0bBImNOS(0yzaxWvIaIqHLldrOWYVY3fuMDAjIw2bMrIhluK4nA2Il7a93sKqFb3Pm9WX0BaN7ifQN(ld4cqekSCNcT3cUmDAYpJH(QmNewqt5NvM)swwAel0d)gPfiLXjuM)sww6NVlKx(rAbszEqzGbtz(lzzP)kN9yuusGK0OmpQmohR2XYa9Tz7eTmOBSNUSl6GnrMtuwFASmGl4krarOWYLHiuyzyjz544uswEh25BSNExGjk7aZiXJfks8gnBXLDG(BjsOVG7uME4y6nGZDKc1t)LbCbicfwUtHEQGltNM8ZyOVkZjHf0uESuOY8OYeRmWGPm)LSS0pFxiV8J0cKYadMY8SYmebT4inwke45aoyrLzpkZZkt6UC4CtlnIf6HFJuyjiJ90at7c9ELXjvMWsqg7PvMhuMhugyWuM)sww6VYzpgfLeijnkZJkJZXkdmykZqe0IJ0yPqGNd4GfvM9PmBoDzG(2SDIwEel0d)MYUOd2ezorz9PXYaUGRebeHclxgIqHLblwOh(nLDGzK4XcfjEJMT4Yoq)Tej0xWDktpCm9gW5osH6P)YaUaeHcl3PtzicfwMTu0RmaiI3EkI2d3cA3vM0D5W5M23Pf]] )

    storeDefault( [[SimC Marksmanship: non patient sniper]], 'actionLists', 20180318.135342, [[dieJuaqiif2KsvJIQOtrvLxPuKmlQQQ4wkfP2frggKCmfzzcQNPuuMgvvPRrvvSnLIQVrjmoif5CqkQ1rvvLMhvvL7bPK9Pu4GkLwiKQhsj1evkICrkrNKQs3urTtumuLIGLsv6PKMkLYwPQ4RuvvvVvPi0DvkIAVQ(RadMWHLAXq8yrnzrUmyZc5ZcYOfQtJ41evZwHBRKDd1VrA4eLLtXZPY0LCDuA7uQ(oLKXdPuNNQW6PQQkZxPY(r1F62UAjUrgq6ixz6fCvjlR5I52i3TASlMiZ)LlWumxiRlcGlUWHjYaZvvgKj9G4)1fHIpty)XFV6fgq7GZeg1eAc1MnzHu4j)DZNqZx1SHiRUEDBUiuS72oZ0TD1sCJmG0r)QMnez11QhaUKCaUiyyib4gzajUypx4jxGWgfjTAJCcouq1Mqq5KyLXf72XfiSrrsLHfCX0sIvgx4hxSNl6CrOyjhGlcggsR2i3fGb0UccLtx3IqgKYJR2BdPrgWvFXjsUlQ5kMIHRZ0KpTHPxWvRAsrWHcIOMahGlcggx1yQvZ0ejIag3r)ktVGR7YrrOqLZrrBIArnax4tpyHn5DMRBnHCxX9cqlRAsrWHcIOMahGlcgg(p27blGwvpaCj5aCrWWqcWnYas79eHnksA1g5eCOGQnHGYjXkB3oe2OiPYWcUyAjXkZV9DUiuSKdWfbddPvBK7cWaAxbHYPREHb0o4mHrnzXeQREbhL1Kb3T96Q1Xqw(m1oSaCDKRZ0etVGRVot4B7QL4gzaPJ(1TiKbP84kG2YguhXoe4IP1vFXjsUlQ5kMIHRZ0KpTHPxW1Rm9cUAjAlBqDe7axOX06QxyaTdotyutwmH6QxWrznzWDBVUADmKLptTdlaxh56mnX0l46RZSz32vlXnYash9RA2qKvxtacBuKKD2bgmnYaKmWQjyhxSbxGIl2Zfr0mRtkZAmaU4In4IjuOUUfHmiLhxLratMGdf4IP1vFXjsUlQ5kMIHRZ0KpTHPxW1Rm9cUUjqatMGdXfAmTU6fgq7GZeg1KftOU6fCuwtgC32RRwhdz5Zu7WcW1rUottm9cU(6m(7TD1sCJmG0r)QMnez11oxe7qaGHfbCCXgCXexSNlsacBuKKD2bgmnYaKmWQjyhxSbxKBxfuKfWf75cp5IQhaUKkdjlpWftlja3idiXf72XfiSrrsdAwEqJtbdANKyLXf(Xf75ce2OijhGlcggUahjuCj5QolNlqlUimQRBrids5X1MSGuGlMwx9fNi5UOMRykgUott(0gMEbxVY0l46wYcsCHgtRREHb0o4mHrnzXeQREbhL1Kb3T96Q1Xqw(m1oSaCDKRZ0etVGRVoJ)CBxTe3idiD0VQzdrwDTZfXoeayyrahxSbxmXf75IeGWgfjzNDGbtJmajdSAc2XfBWf52vbfzbCXEUO6bGlPYqYYdCX0scWnYasCXEUWbvacfZ6KkcycJkiSSmxSbxGIl2ZfObxGWgfjvHrfewwq2qksUhbnzbPGuV6qGeRmUypx05IqXsnzbPaxmTKi4GObjuCDDlczqkpU2KfKcCX06QV4ej3f1CftXW1zAYN2W0l46vMEbx3swqIl0yAXfEo53vVWaAhCMWOMSyc1vVGJYAYG72ED16yilFMAhwaUoY1zAIPxW1xNzZVTRwIBKbKo6x1SHiRU25IyhcamSiGJl2GlMUUfHmiLhxxTroKcCX06QV4ej3f1CftXW1zAYN2W0l46vMEbxNBJCiXfAmTU6fgq7GZeg1KftOU6fCuwtgC32RRwhdz5Zu7WcW1rUottm9cU(6mwCBxTe3idiD0VQzdrwDTZfXoeayyrahxSbxmXf75cp5ce2OiPvBKtWHcQ2eckNeRmUy3oUaHnksQmSGlMwsSY4c)UUfHmiLhxxSJI4IP1vFXjsUlQ5kMIHRZ0KpTHPxW1Rm9cUoZokYMwJP1vVWaAhCMWOMSyc1vVGJYAYG72ED16yilFMAhwaUoY1zAIPxW1xNbnDBxTe3idiD0VQzdrwDfn4IeGWgfjfZIlW4cwTrUeRSRBrids5XvhGlcggx9fNi5UOMRykgUott(0gMEbxVY0l4Qc4IGHXvVWaAhCMWOMSyc1vVGJYAYG72ED16yilFMAhwaUoY1zAIPxW1xNbnFBxTe3idiD0VQzdrwDT6bGljhjbwrWjW4KaCJmGexSBhx05IyhcamSiGJl8pUyZVY0l4k6JolNl2AmuRUUfHmiLhxrgDwEqBmuRU6lorYDrnxXumC1lmG2bNjmQjlMqD1l4OSMm4UTxVoZeQB7QL4gzaPJ(vnBiYQRvBcbLurwqqrdseGl2aT4IoxekwQdwSMeycOrbzd1kNuMshjQvyUytXfjwtxekMl2TJlQ2eckPyOhvSKSCXf(hxeg11TiKbP84AhSynjWeqJcYgQvUR(ItKCxuZvmfdxNPjFAdtVGRxz6fCDlxmZAsGHlOrCH1gQvUREHb0o4mHrnzXeQREbhL1Kb3T96Q1Xqw(m1oSaCDKRZ0etVGRVoZ00TD1sCJmG0r)6weYGuEC1kcoHWAC1vFXjsUlQ5kMIHRZ0KpTHPxW1Rm9cU6)tWjewJRU6fgq7GZeg1KftOU6fCuwtgC32RRwhdz5Zu7WcW1rUottm9cU(6mtHVTRwIBKbKo6x1SHiRU25IyhcamSiGJl2GlcZf72XfEYfvBcbLum0JkwswU4c)JlcJIl2ZfiSrrsiSJHd8aKCvNLZf(hxe2F4c)UUfHmiLhxrAJPdbx9fNi5UOMRykgUott(0gMEbxVY0l4k6TX0HGREHb0o4mHrnzXeQREbhL1Kb3T96Q1Xqw(m1oSaCDKRZ0etVGRVoZ0MDBxTe3idiD0VQzdrwDfHnksA1g5eCOGQnHGYjXkJl2TJlqyJIKkdl4IPLeRSRBrids5X1vBKdPaxmTU6lorYDrnxXumCDMM8Pnm9cUELPxW152ihsCHgtlUWZj)U6fgq7GZeg1KftOU6fCuwtgC32RRwhdz5Zu7WcW1rUottm9cU(6mt(7TD1sCJmG0r)QMnez1v0GlS3gsJmajRAsrWHcIOMahGlcggCXEUWtUibiSrrsXS4cmUGvBKlLOwH5ID74cp5ce2OiPYWcUyAjLOwH5I9CbcBuK0QnYj4qbvBcbLtkrTcZf(Xf(Xf75cp5cp5ce2OiPvBKtWHcQ2eckNeRmUy3oUaHnksQmSGlMwsSY4c)4ID74ICCBcbUGitNlcf3dUydUyscnXf(Xf75cp5IiAM1jLGisMuCXgCrUDvGbcbyUWVRBrids5XvhjbwrWjW4U6lorYDrnxXumCDMM8Pnm9cUELPxWvLKaRi4eyCx9cdODWzcJAYIjux9cokRjdUB71vRJHS8zQDyb46ixNPjMEbxFDMj)52UAjUrgq6OFvZgIS6A1daxsoscSIGtGXjb4gzajUypxKae2Oij7SdmyAKbizGvtWoUydUi3UkOil46weYGuECTjlif4IP1vFXjsUlQ5kMIHRZ0KpTHPxW1Rm9cUULSGexOX0Il8mSFx9cdODWzcJAYIjux9cokRjdUB71vRJHS8zQDyb46ixNPjMEbxFDMPn)2UAjUrgq6OFvZgIS6kAWfvpaCj5ijWkcobgNeGBKbK4I9CrcqyJIKSZoWGPrgGKbwnb74In4IC7QGISaUypx4jxGgCH92qAKbijJsheCOGiQjqgbmzcoexSBhx4jxGWgfjnOz5bnofmODsIvgxSNlsacBuKKD2bgmnYaKmWQjyhxSbxekN4c)4c)4I9CHNCrNlIDiaWWIaoUW)4c)Hl2TJlQEa4sQmKS8axmTKaCJmGexSBhxGWgfj5aCrWWWf4iHIljx1z5CbAXfHrXf(DDlczqkpU2KfKcCX06QV4ej3f1CftXW1zAYN2W0l46vMEbx3swqIl0yAXfEUz(D1lmG2bNjmQjlMqD1l4OSMm4UTxxTogYYNP2HfGRJCDMMy6fC91zMS42UAjUrgq6OFDlczqkpUUAJCif4IP1vFXjsUlQ5kMIHRZ0KpTHPxW1Rm9cUo3g5qIl0yAXfEg2VREHb0o4mHrnzXeQREbhL1Kb3T96Q1Xqw(m1oSaCDKRZ0etVGRVoZeA62UAjUrgq6OFvZgIS6AenZ6KYSgdGlUytXf52vbgieG5In4IiAM1jTA0Ml2ZfObxGWgfj5aCrWWWf4iHIljwzx3IqgKYJRnzbPaxmTU6lorYDrnxXumCDMM8Pnm9cUELPxW1TKfK4cnMwCHN(RFx9cdODWzcJAYIjux9cokRjdUB71vRJHS8zQDyb46ixNPjMEbxFDMj08TD1sCJmG0r)QMnez11oxe7qaGHfbCCXgCXexSNlqdUWEBinYaKSQjfbhkiIAcCaUiyyCDlczqkpUUyhfXftRR(ItKCxuZvmfdxNPjFAdtVGRxz6fCDMDuKnTgtlUWZj)U6fgq7GZeg1KftOU6fCuwtgC32RRwhdz5Zu7WcW1rUottm9cU(6mHrDBxTe3idiD0VQzdrwDTZfXoeayyrahxGwCXexSNlqdUWEBinYaKSQjfbhkiIAcCaUiyyCDlczqkpU2MCJHaxmTU6lorYDrnxXumCDMM8Pnm9cUELPxW1TMCJbUqJP1vVWaAhCMWOMSyc1vVGJYAYG72ED16yilFMAhwaUoY1zAIPxW1xVUUjbrn7Oo6V(b]] )

    storeDefault( [[SimC Marksmanship: targetdie]], 'actionLists', 20180317.214619, [[dudHeaGEjG2KsjTlOOxtf2NeOzdPBIkFtrANcTxYUrz)qLHPK(nIHIQQmyOQHRioiv0XOsluszPkvlgILtPhQu8uWYqvEUGjkbyQkXKPy6sDrjvNgPlR66kQhRWwHcBgvLTlroSOVIQQAAsq(UsPgNsj(Re1OLKNjb1jHs9zjuxtc58qj3MQ2gQQyDOQslxTiOolrqVricGjFqtuAbMnLWuKxrfsqbC(Yz0w1eSF0NHRiVv3TSwy3Py6wur8C3IayyPtAbcCoAkHf0IIUArqDwIGEJQjagw6KwG5iZ8XhMLMrz3MiOhZ5jcCIqrPnwcMqVDqzfxourAbyZm0r2eRagHDbCedgPnM(lqqm9xa)rVDqzfJdpurAb7h9z4kYB1DQ7QG9hiZ2XdArTGnvF4GJu6(ZAHiGJyIP)cuRipTiOolrqVr1e4eHIsBSeSnLzqMTHwa2mdDKnXkGryxahXGrAJP)ceet)fW)uMbz2gAb7h9z4kYB1DQ7QG9hiZ2XdArTGnvF4GJu6(ZAHiGJyIP)cuRyH1IG6Seb9gvtamS0jTaZrM5JpmlnJYUnrqpM27tklGdFbXHFKHUCt9hh(TIdFN2IFJzt9VCtkBOhh(cId)idD5M6VaNiuuAJLGK6VPCOI0cWMzOJSjwbmc7c4igmsBm9xGGy6VaNu)n4WdvKwW(rFgUI8wDN6Uky)bYSD8Gwulyt1ho4iLU)Swic4iMy6Va1kwiTiOolrqVr1e4eHIsBSe4tRJBkhQiTaSzg6iBIvaJWUaoIbJ0gt)fiiM(lGlToUbhEOI0c2p6ZWvK3Q7u3vb7pqMTJh0IAbBQ(WbhP09N1crahXet)fOwXI0IG6Seb9gvtGtekkTXsqAhj7LdvKwa2mdDKnXkGryxahXGrAJP)ceet)f40os2XHhQiTG9J(mCf5T6o1DvW(dKz74bTOwWMQpCWrkD)zTqeWrmX0FbQvKF0IG6Seb9gvtGtekkTXsqGA(2uM52GaSzg6iBIvaJWUaoIbJ0gt)fiiM(laOMVnLzUniy)OpdxrERUtDxfS)az2oEqlQfSP6dhCKs3FwlebCetm9xGA1cIP)caQFdo8CP1rWNSqfDc)IdFN2IFBOxTea]] )


    storeDefault( [[Survival Primary]], 'displays', 20171128.135411, [[d8t6haWyKA9QiVKcv7cjk2gfGFd1mPinnkOMTcNNkUPIkNgLVrb5ysPDsP9k2nj7hs(jKAyeACuG6YQAOemyiA4iCqPQJIeLoSKZrbYcLklfjSyQQLt0dLIEkyzuupNuturPMkIMmQy6kDrv4QuiEMIsCDvAJsHTQOK2mvz7q4JkkETIQ(ms67kYiPqzDuinAu14vrDsuPBrb01qICpKOQBtLwlsu54ueN2qgGUiwgw1aRwyDgFa0gH0uU2Ja0fXYWQgy1cStFSTMdilf1Vj)tpF6c4pyNonZapf)aoO980)2SiwgwPJvmWz0EE6FBweldR0XkgWK7FFoCPXkGD6J1WIbCzQ(JynhWK7FFonlILHv60fWbTNN(xYss9xDSIbOS3)(6qgBBidCOk)XZjDb6PxgwHcPPm9gRbfWwUFakU6I3OOqsiFASRFTbO4hFP)ynl2AiXwrXaaTKrSbwM7t5fZgR5qg4qv(JNt6c0tVmScfstz6nwdoGTC)auC1fVrrHKZ7v3XgGIF8L(J1SyRHeBffZMnGMhpbtSLMV)iDb084P(7Itxa36mqgBBGTKu)TxrZJLb6qtsIEok4oJXid4eRbA2aedCowXaAE8ezjP(RoDbM3VxrZJLbirlqb3zmgzaASRFTcioIFa6IyzyvVIMhld0HMKe9CbaINMvd2PAzyvSMPeLcO5Xtaz6cyY9V)SzYNEzyvak4oJXidOUUCPXkDSgoGM4hJgJsZ3epWYqgOITnGm22auJTnGFSTzdO5XtnlILHv60f4mApp9V9xzfRyG6klshIpG)1ZlGBDU)U4yfdudc(QFmvoAbehX2gOge8fWJNeqCeBBGAqWxnXU(1kG4i22aZ(9Q7ytxGAmvoAbecPlacMM5ZgS1H0H4d4hGUiwgw1pyuvbAEyjpOiahMMyuoKoeFGkGSuuFshIpq5ZgS1jqDL1Cm1NUaMCz0ZpRmnSoJpqfyE)gy1cStFSTMdyl3paCLiyiQbkKcsMBjDcudc(ISKu)vaHqSTbCq75P)LRIdJUwSuhRya5pc08WsEqranXpgngLMp(bQbbFrwsQ)kG4i22amfhgDTyzVIMhldqb3zmgzatU)95WvXHrxlwQtxaxMQ)U4yfduxz1RO5XYaDOjjrpNPhnidSLK6VnWQfwNXhaTrinLR9iWC1zM71ffssM7h7SigqZJNGj2sZ3FxC6ca0sgXgiqni4R(Xu5OfqieBBG6klUkpmPdXhW)65fGqYClPtdSAb2Pp2wZbiKpn21V2Ebtdam3MOqcxjcgIAyuuijKpn21V2aAE8u)vwCvE44hWTo3FeRyaYA8QffYzK4lrSIb2ss9xbehXpaf)4l9hRzXwdjAaMPeLP1GOKzdBOacsMBjDqHSzrSmSkGwwldhGZ7v3X2lyAaG52efs4krWqudJIcjN3RUJnGdApp9VgVthRb2g4mApp9VKLK6V6yfdmVFdSAH1z8bqBest5Apc4G2Zt)B)vwXkgqZJN4Q4WORfl1Plqni4lGhpjGqi22a1yQC0ciosxG6klG4hdUZowZITIgCBanpEsaXr6cqJD9RvaHq8dmVFdSAdiqIcjuknkK2skXtb084P(J0fqZJNeqiKUaUmfqgRyGTKu)TbwTa70hBR5aNr75P)14D6yfdqxeldRAGvBabsuiHsPrH0wsjEkqni4RMyx)AfqieBBGdv5pEoPlGM5sm(E0hXAoG)GD60md8u)ye)aEy1g44mH816PYjWwsQ)kGqi(bm5(3VFWOQCF1gGoGMhpz83XNP4Wuu1PlGGK5wshuiBweldRqHS)kRaZHvuXy9JczJR0jaHK5wshU0yfWo9XAyXamAScikAMIASukaJgROCySBSZIyatU)950aRwGD6JT1CGTKu)TbwTbeirHekLgfsBjL4PaMC)7ZX4D60f4mApp9VCvCy01IL6yfduxzzefBdqmkNxMnba]] )

    storeDefault( [[Survival AOE]], 'displays', 20171128.135411, [[dee7haqiIe1MubPBPcIDbjfdtkoMcwgQ0ZisY0if5Aqs2gKu5BKcghKu6Cej16is5Eej0bLslurEivvtufuxuH2ivLpQcmssHojr8ssrntsj3ufYoP0pHOHsQokKu1svr9uWurYvjs1wjsWAjsK9kgmK6Wswmr9yKAYOIlRQntfFgHgnQ60O8AvOMTuDBQYUj8BOgoIooPulNINtY0v66Q02HW3vuJhsCEQ06vr2pcodHkaDrUmSWhwSW62)aiLoLwsSJbOlYLHf(WIfyN(yh4gWucIVF(N(4mfqUZoD6GoEoYbCr64O(1FrUmSqfBtauq64O(1FrUmSqfBtaTV)95iHgla2Ppwn1eWJjAhJLBaTV)954VixgwOYuaxKooQFPkdXFvX2ea1F)7RcvSdHkWOOK7pNmfOLEzybb0AXuBSsDaB59boFvfV0iGM080yp5AdC(7FP(y52mOHMHMMaaTHrUbwM3lfBYgl3qfyuuY9NtMc0sVmSGaATyQnwuBaB59boFvfV0iGMZ7u3(g483)s9XYTzqdndnnzZgqXJNHz2sZ3oMPaOG0Xr9lvzi(Rk2MamASailAMGySOkWwgI)2kO5XMatiPOqE0zjhOrQaUXEiChqvauITjGIhptvgI)QYuGJLBf08ytakK6NLCGgPcqJ9KRvhXyKdqxKldlAf08ytGjKuuipkaq(0SQZovldlILlQqvafpEgOYuaTV)9pmZ80ldlcCwYbAKkG46jHgluXQPakYV391lfVFChBcvGk2HaMyhcqm2HaYXoKnGIhp7VixgwOYuauq64O(T9AQyBcuxtr5s(bKVoob8kuAVlo2MavNKVA7ZLRshXySdbQojFb84zDeJXoeO6K8LFSNCT6igJDiWHFN623mfO6ZLRshHEMcGGPyYSoBDPCj)aYbOlYLHfTDgrra)JwQXZb4WuK9YLYL8dqhWucIpLl5hOKzD26gOUM6iM4ZuaTVm6JLcmfSU9pqf4yzFyXcStFSdCdylVpaCniyiQob0TihdOByELXLaA)f5YWccOBVMkWrybrmw9eq77ACd4XeT3fhl3aMVhW)OLA8Caf537(6LIpYbQojFrvgI)QJym2HaUiDCu)krWHrxl2OITjG23)(CKi4WORfBuzkGIhpdZSLMV9U4mfOUMQvqZJnbMqsrH8iTg9rfyldXF9HflSU9pasPtPLe7yGJkuyExpcOPyEFSsvtaVcfGk2MaaTHrUbumbX(FOs56U4avNKVA7ZLRshHESdbQRPKiCWuUKFa5RJtasdZRmU(WIfyN(yh4gG080yp5AB11kaW88tanCniyiQU0iGM080yp5AdO4XZT3fh5aEfkTJX2eGQ6VyjG(ad(sgBtGTme)vhXyKdOByELXLaA)f5YWIaktTmCafpEwZVRmtWHjiQYuaoVtD7BRUwbaMNFcOHRbbdr1Lgb0CEN623aUiDCu)Q5jvShYqGTme)1hwSb0PiGgkHIaABzm45ahl7dlwyD7FaKsNslj2XaUiDCu)2EnvSnbu84zjcom6AXgvMcuDs(c4XZ6i0JDiq1NlxLoIXmfOUMci)ExYHJTjGIhpRJymtbOXEY1QJqpYbow2hwSb0PiGgkHIaABzm45akE8C7yKdO4XZ6i0ZuapMaOILBGTme)1hwSa70h7a3aOG0Xr9RMNuXoeGUixgw4dl2a6ueqdLqraTTmg8CGQtYx(XEY1QJqp2HaJIsU)CYuafZJS)TihJLBa5o70Pd6452EpYb0((3VTZik8EXgGoWwgI)QJqpYbQojFrvgI)QJqp2HaN)(xQpwUndAOb1XfvOMbPgvC1KgcqAyELXvcnwaStFSAQjatWHrxl20kO5XMaNLCGgPcO4XZTxtjr4GJCagnwiLWyVyLQMaAF)7ZXhwSa70h7a3aoyXgyefsZRuZLBaTV)95O5jvMcGcshh1VseCy01InQyBcuxtjDbBdq2l33Knb]] )

    storeDefault( [[Marksmanship Primary]], 'displays', 20180317.224416, [[d4tviaGEqXlrsSlQqSncsCyjZKG62k0Sv01ie3ukYJrX3uPQ8CsTtkTxXUr1(Ps9tvyysLXPsvUSsdLKgSuy4i1bvWNrIJjLoUkLfsvwksQftvTCIEivYtHwMuuRJkuMOkvMkitwfnDvDrvYvjiEgssxhrBKqTvcsAZKy7e4Jur(kvOAAubFxQAKurnwvQQgncJhu6KGQBrfsNMIZJsVMqATeK63aN2afKPOFdGlgWF8zNBWdHajmC7vWVKu2xvGA8dkloL1fXYiA8c6pnWaJttqF8dYEOOO33vr)gaxhBxqypuu077QOFdGRJTl4OHpCflvdEJCj3txf9BaCD8cclRlaxWk)9mEbzpuu07dvsk7RJTlOMa0J9MNHy4kEb1eG(bYheVGAcqp2BEgIbYheVGFjPS)aNHaid6DabD0e1WDYzOGWEOOO3NkE6yBdQa4Fqvi3nWIRD3WwsjOpi7HIIE)72zXgBxqypuu07F3ol2y7cQja9qLKY(64fuu)bodbqge6qLA4o5muWBKl5EcNbWDCZ5teRiDbPLMXsYcNbWDEnui(yfPlOTg3Gnvsr1JfxtyOD3qvAgljBqd)0WupqoWziaYGud3jNHcAyaCpG8CLXlitr)gaFGZqaKb9oGGoAkiT0mwsw4maUJBoFIyfPlisVmMAAGPEdGhBZI4qqnbOhHIxWBKl5ENrUmVbWdsnCNCgkiNCeodGRJ1HGNRsro)bvHdIMrxUB0ujfvpwCnHH2XC34CvkY5huGrB8ntZZcXsVb9dQP35u8S0eUatGmqbRyBd6hBBqkX2gugBB(GAcqVRI(naUo(bPYU0dA6L5PUEdiEblszbXsVb9jvucAyaCHgagJLQDbHn2UGJfSdKpi2UG(tdmW40e0pmNXpynPjkKa0Rk4k22G1KMOCbg9RxvWvSTbhn8bYheBxq2dff9(uXthRJ2gSM9fRwvGA8ckQVya)dQc5UbwCT7g2skb9bzk63a4dtdfEqxxwOlQdEA00ZIfILEdwbhlyrOyBdkloLfILEdw(MP5zdwKYQjdFJxWBKl5oWziaYGud3jNHckQVya)rdmBSToee2dff9(W5NgM6bsDSDbRjnrbvsk7Rkqn22G3ixY9eodG78AOq8Xksxq5od66YcDrDqn9oNINLMi(bRjnrbvsk7Rk4k22G3ixYDyAOWhx(hKj4nYLCpHZpnm1dK64f8gPHruHQrJp7Cdwbp3zXkgWF8zNBWdHajmC7vWVKu2xmG)4Zo3Ghcbsy42RGN7Syh4meazqOdvHVedf8g5sU4Zo3Gud3jNHcEUZIvmG)ObMn2whcwtAIAy2xSAvbQX2gSiLfsVZj87ITliT0mwswXa(Jgy2yBDiiTCzaJ(1pOkCq0m6YDJMkPO6XIRjm0oM7g0YLbm6xFqnbOxvGA8cowWoCfBxqddG7bKNR0fycKbkyfBBq)y7csj2UGYy7Yh8ljL9vfCf)GuVZT0BSn31EVoQ2EFosZTIiuO69cQja9uzz9n8tdNIoEbp3zXkgW)GQqUBGfx7UHTKsqFqnbO)UDwSbHUUFOGFjPSVya)dQc5UbwCT7g2skb9bH9qrrVpujPSVo2UGAcq)aPSGZvaXpOMa0dNFAyQhi1Xli7HIIEF48tdt9aPo2UG1SVy1QcUIxqnbOF4kEb1eGEvbxXlidy0VEvbQXpyrkRbodbqg07ac6OjHVedfe2dff9(dKYk2UGShkk69hiLvSDbhnCek2UGFjPSVya)rdmBSToe8g5sUdCgcG8qrrVFSIeKPOFdGlgW)GQqUBGfx7UHTKsqFWAstuUaJ(1Rkqn22Gx8YFUNXlO2msp3HJRyBoOWL(Db4cwP2a4X2Cx796ABDWrOAqMI(naUya)rdmBSToeuuFXa(Jp7CdEieiHHBVcAyaCKUymCkXksWIuwW5kaiw6nOpPIsqgWOF9QcUIFq2yD0MBwKGcnam6cWfSYFpJxWAstuibOxvGASTbVrUK7Pya)rdmBSToe8UvPiNF8cEJCj3tQ4PJxWAstudZ(IvRk4k22GfPSec38bPNf7kZNa]] )

    storeDefault( [[Marksmanship AOE]], 'displays', 20180317.224416, [[d4tuiaGEqXlvPQDHsP2gkL0HLmtcPBRcZwrxJkLBkvYJrQVjvkEoP2jL2Ry3OA)uL(PcnmP04KkvxwPHsfdwQy4O4GsXNrIJrvDCvkluQAPiPwmrTCsEivXtHwgkfRJkrnrvQmvqMSkz6Q6IQORIK0ZqsCDeTrc1wLkL2mr2ok5JuP6RujY0qP67kyKujnwukXOry8GsNeuDlQe60uCEcEnHyTuj43ah)afKUyEdGlgWF8fMBWrQcjkC7zWVuu23HLtKdQkoL1dXsls6dkpnWaJ7tWqKdkmkjP33tX8gaxhBBqyhLK077PyEdGRJTn4HH3CglvcEJCj3lpfZBaCD6dcRGhaN1Q(9k9bfgLK07dvkk7RJTnOMamGdMNMO5mYb1eGHgYhe5GAcWaoyEAIgYhK(GFPOSFdNMaOc2pcbn2f1WD3vOGWokjP3)(EDS(bLa8pOdK3oyX1E7ylLcmeuyussV)D7SeITniSJss69VBNLqSTb1eGbOsrzFD6dkICdNMaOccn6qnC3Dfk4nYLCVGtd4UK56jI1T2GmkZrPeGtd4UUgkeFSU1g0whBWUkLi6JIRjmmE70mEg0WVm01dunCAcGki1WD3vOGgAaVhOUwv6dsxmVbWB40eavW(riOXUcYOmhLsaonG7sMRNiw3AdImlTPMgyQ3a4XYg3ypOMamGqPp4nYLCVZOw63a4bPgU7UcfKtEaNgW1XYEWRvQiNFJJObrZHhVD6QuIOpkUMWW4YE7CTsf58dYYOnYMP5fGey2GYb1m7CkEwAcpGjqfOGvS(bLJ1piLy9dQI1pFqnbyWtX8gaxh5G3VltJMzPFQR3asFWIuvqcmBqzsjPGgAa3faGJyPsBqyJTn4rbBd5dITnO80admUpbdnZzKdwtgIcjadoSoJ1pynzikpGd56DyDgRFWddVH8bX2guyussV)996yDr)G1COe0oSCsFqrKfd4FqhiVDWIR92XwkfyiiDX8gaVzAOWd650cDsDWlJMzwcqcmBq6GhfSiuS(bvfNYcjWSblzZ08cblsv1LHVPp4nYLCB40eavqQH7URqbfrwmG)ObMnwF2dc7OKKEF48ldD9aLo22G1KHOGkfL9Dy5eRFWBKl5EbNgWDDnui(yDRnOANb9CAHoPoOMzNtXZste5G1KHOGkfL9DyDgRFWBKl52mnu4hl)dsh8g5sUxW5xg66bkD6dEJ0qls3A04lm3GYbV2zjigWF8fMBWrQcjkC7zWVuu2xmG)4lm3GJufsu42ZGx7SeA40eavqOrhrpfdf8g5sU4lm3Gud3DxHcETZsqmG)ObMnwF2dwtgIQzoucAhwoX6hSivfYSZj87ITniJYCukbXa(Jgy2y9zpiJAPbhY134iAq0C4XBNUkLi6JIRjmmUS3omQLgCixFqnbyWHLt6dEuW2CgBBqdnG3duxRYdycubkyfRFq5yBdsj22GQyBZh8lfL9DyDg5GuVZT0BSSP1V7TuXVByB247gBLkDpOMamC)kiB4xgofD6dETZsqmG)bDG82blU2BhBPuGHGAcWWD7SeccDYwGc(LIY(Ib8pOdK3oyX1E7ylLcmee2rjj9(qLIY(6yBdQjadnKQcoxce5GAcWaC(LHUEGsN(GcJss69HZVm01du6yBdwZHsq7W6m9b1eGHMZihutagCyDM(G0Gd56Dy5e5GfPQA40eavW(riOXUe9umuqyhLK073qQQyBdkmkjP3VHuvX2g8WWrOyBd(LIY(Ib8hnWSX6ZEWBKl52WPjaQrjj9(X6wq6I5naUya)d6a5TdwCT3o2sPadbRjdr5bCixVdlNy9dEYl55EL(GAZbZCBgpJLnbfT0VhaN1Q0gapw20639wFF2zBQeKUyEdGlgWF0aZgRp7bfrwmG)4lm3GJufsu42ZGgAahzkAdNsSUfSivfCUeasGzdktkjfKgCixVdRZihuiwx0VBAd6caWHhaN1Q(9k9bRjdrHeGbhwoX6h8g5sUxIb8hnWSX6ZEW7wPIC(Pp4nYLCVUVxN(G1KHOAMdLG2H1zS(blsvrvU5dYmlHvLpba]] )


    ns.initializeClassModule = HunterInit

end
