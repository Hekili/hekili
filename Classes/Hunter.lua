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

local floor = math.floor


if select( 2, UnitClass( 'player' ) ) == 'HUNTER' then

    local function HunterInit()
        setClass( 'HUNTER' )
        addResource( 'focus', SPELL_POWER_FOCUS )

        setRegenModel( {
            volley = {
                resource = 'focus',

                aura = 'volley',

                last = function ()
                    local swing = state.swings.mainhand
                    local t = state.query_time

                    return swing + ( floor( ( t - swing ) / state.swings.mainhand_speed ) * state.swings.mainhand_speed )
                end,

                interval = 'mainhand_speed',

                value = -3
            },

            spitting_cobra = {
                resource = 'focus',

                spec = 'survival',
                talent = 'spitting_cobra',
                aura = 'spitting_cobra',

                last = function ()
                    local app = state.buff.spitting_cobra.applied
                    local t = state.query_time

                    return app + floor( t - app )
                end,

                stop = function( x )
                    return x < 3
                end,

                interval = 1,
                value = 3,
            },


            -- Dire Beast uses the same spell ID for multiple applications.
            -- We're going to need to feign auras on successful Dire Beast casts, but it can wait.

            aspect_of_the_wild = {
                resource = 'focus',

                spec = 'beast_mastery',
                aura = 'spect_of_the_wild',

                last = function ()
                    local app = state.buff.aspect_oF_the_wild.applied
                    local t = state.query_time

                    return app + floor( t - app )
                end,

                interval = 1,
                value = 10,
            },

            dire_beast = {
                resource = 'focus',

                spec = 'beast_mastery',
                aura = 'dire_beast',

                last = function ()
                    local app = state.buff.dire_beast.applied
                    local t = state.query_time

                    return app + floor( t - app )
                end,

                interval = 2,
                value = 3,
            },

            dire_frenzy_1 = {
                resource = 'focus',

                spec = 'beast_mastery',
                talent = 'dire_frenzy',
                aura = 'dire_frenzy_1', 

                last = function ()
                    local app = state.buff.dire_frenzy_1.applied
                    local t = state.query_time

                    return app + floor( t - app )
                end,

                interval = 2,
                value = function () return state.talent.dire_stable.enabled and 9 or 6 end,
            },

            dire_frenzy_2 = {
                resource = 'focus',

                spec = 'beast_mastery',
                talent = 'dire_frenzy',
                aura = 'dire_frenzy_2',

                last = function ()
                    local app = state.buff.dire_frenzy_2.applied
                    local t = state.query_time

                    return app + floor( t - app )
                end,

                interval = 2,
                value = function () return state.talent.dire_stable.enabled and 9 or 6 end,
            },

            dire_frenzy_3 = {
                resource = 'focus',

                spec = 'beast_mastery',
                talent = 'dire_frenzy',
                aura = 'dire_frenzy_3',

                last = function ()
                    local app = state.buff.dire_frenzy_3.applied
                    local t = state.query_time

                    return app + floor( t - app )
                end,

                interval = 2,
                value = function () return state.talent.dire_stable.enabled and 9 or 6 end,
            },
            
            dire_frenzy_4 = {
                resource = 'focus',

                spec = 'beast_mastery',
                talent = 'dire_frenzy',
                aura = 'dire_frenzy_4',

                last = function ()
                    local app = state.buff.dire_frenzy_4.applied
                    local t = state.query_time

                    return app + floor( t - app )
                end,

                interval = 2,
                value = function () return state.talent.dire_stable.enabled and 9 or 6 end,
            },
            
            dire_frenzy_5 = {
                resource = 'focus',

                spec = 'beast_mastery',
                talent = 'dire_frenzy',
                aura = 'dire_frenzy_5',

                last = function ()
                    local app = state.buff.dire_frenzy_5.applied
                    local t = state.query_time

                    return app + floor( t - app )
                end,

                interval = 2,
                value = function () return state.talent.dire_stable.enabled and 9 or 6 end,
            },
            
        } )


        ------------------------------------------------------------------------
        -- Talents
        ------------------------------------------------------------------------

        -- Talents Beast Mastery
        -- 15
        addTalent( 'big_game_hunter', 204308 )
        addTalent( 'way_of_the_cobra', 194397 )
        addTalent( 'dire_stable', 193532 )
        -- 30
        addTalent( 'stomp', 199530 )
        addTalent( 'dire_frenzy', 217200 )
        addTalent( 'chimaera_shot', 53209 )
        -- 45
        addTalent( 'posthaste', 109215 )
        addTalent( "farstrider", 199523 ) -- 19348
        addTalent( 'trailblazer', 199921 )
        -- 60
        addTalent( 'one_with_the_pack', 199528 )
        addTalent( 'bestial_fury', 194306 )
        addTalent( 'blink_strikes', 130392 )
        -- 75
        addTalent( "binding_shot", 109248 ) -- 22284
        addTalent( "wyvern_sting", 19386 ) -- 22276
        addTalent( 'intimidation', 19577 )
        -- 90
        -- addTalent( 'a_murder_of_crows', 206505 ) -- MM,BM 131894
        addTalent( "barrage", 120360 ) -- 22002
        addTalent( "volley", 194386 ) -- 22287
        -- 100
        addTalent( 'stampede', 201430 )
        addTalent( 'killer_cobra', 199532 )
        addTalent( 'aspect_of_the_beast', 191384 )

        -- Talents Marksmanship
        -- 15
        addTalent( "lone_wolf", 155228 ) -- 22279
        addTalent( "steady_focus", 193533 ) -- 22501
        addTalent( "careful_aim", 53238 ) -- 22289
        -- 30
        addTalent( "lock_and_load", 194595 ) -- 22495
        addTalent( "black_arrow", 194599 ) -- 22497
        addTalent( "true_aim", 199527 ) -- 22498
        -- 45
        -- addTalent( 'posthaste', 109215 )
        -- addTalent( "farstrider", 199523 ) -- 19348
        -- addTalent( 'trailblazer', 199921 )
        -- 60
        addTalent( "explosive_shot", 212431 ) -- 22267
        addTalent( "sentinel", 206817 ) -- 22286
        addTalent( "patient_sniper", 234588 ) -- 21998
        -- 75
        -- addTalent( "binding_shot", 109248 ) -- 22284
        -- addTalent( "wyvern_sting", 19386 ) -- 22276
        addTalent( 'camouflage', 199483 )
        -- 90
        -- addTalent( 'a_murder_of_crows', 206505 ) -- MM,BM 131894
        -- addTalent( "barrage", 120360 ) -- 22002
        -- addTalent( "volley", 194386 ) -- 22287
        -- 100
        addTalent( "sidewinders", 214579 ) -- 22274
        addTalent( "piercing_shot", 198670 ) -- 22308
        addTalent( "trick_shot", 199522 ) -- 22288

        -- Talents Survival
        -- 15
        addTalent( 'animal_instincts', 204315 )
        addTalent( 'throwing_axes', 200163 )
        addTalent( 'way_of_the_moknathal', 201082 )
        -- 30
        addTalent( 'a_murder_of_crows', 206505 ) -- MM,BM 131894
        addTalent( 'mortal_wounds', 201075 )
        addTalent( 'snake_hunter', 201078 )
        -- 45
        -- addTalent( 'posthaste', 109215 )
        addTalent( 'disengage', 781 )
        -- addTalent( 'trailblazer', 199921 )
        -- 60
        addTalent( 'caltrops', 194277 )
        addTalent( 'guerrilla_tactics', 236698 )
        addTalent( 'steel_trap', 162488 )
        -- 75
        addTalent( 'sticky_bomb', 191241 )
        addTalent( 'rangers_net', 200108 )
        -- addTalent( 'camouflage', 199483 )
        -- 90
        addTalent( 'butchery', 212436 )
        addTalent( 'dragonsfire_grenade', 2194855 )
        addTalent( 'serpent_sting', 87935 )
        -- 100
        addTalent( 'spitting_cobra', 194407 )
        addTalent( 'expert_trapper', 199543 )
        -- addTalent( 'aspect_of_the_beast', 191384 )

        ------------------------------------------------------------------------
        -- Traits
        ------------------------------------------------------------------------

        -- Traits Generic
        addTrait( "concordance_of_the_legionfall", 239042 )
        addTrait( "artificial_stamina", 211309 )

        -- Traits Beast Mastery
        addTrait( "beast_master", 215779 )
        addTrait( "bond_of_the_unseen_path", 241110 )
        addTrait( "cobra_commander", 238123 )
        addTrait( "focus_of_the_titans", 197139 )
        addTrait( "furious_swipes", 197047 )
        addTrait( "hatis_bond", 197344 )
        addTrait( "hunters_advantage", 197178 )
        addTrait( "jaws_of_thunder", 197162 )
        addTrait( "master_of_beasts", 197248 )
        addTrait( "mimirons_shell", 197160 )
        addTrait( "natural_reflexes", 197138 )
        addTrait( "pack_leader", 197080 )
        addTrait( "pathfinder", 197343 )
        addTrait( "slithering_serpents", 238051 )
        addTrait( "spirit_bond", 197199 )
        addTrait( "spiritbound", 214914 )
        addTrait( "spitting_cobras", 197140 )
        addTrait( "surge_of_the_stormgod", 197354 )
        addTrait( "thunderslash", 238087 )
        addTrait( "titans_thunder", 207068 )
        addTrait( "unleash_the_beast", 206910 )
        addTrait( "wilderness_expert", 197038 )

        -- Traits Marksmanship
        addTrait( "acuity_of_the_unseen_path", 241114 )
        addTrait( "bullseye", 204089 )
        addTrait( "call_of_the_hunter", 191048 )
        addTrait( "called_shot", 190467 )
        addTrait( "critical_focus", 191328 )
        addTrait( "cyclonic_burst", 238124 )
        addTrait( "deadly_aim", 190449 )
        addTrait( "feet_of_wind", 238088 )
        addTrait( "gust_of_wind", 190567 )
        addTrait( "healing_shell", 190503 )
        addTrait( "legacy_of_the_windrunners", 190852 )
        addTrait( "mark_of_the_windrunner", 204219 )
        addTrait( "marked_for_death", 190529 )
        addTrait( "precision", 190520 )
        addTrait( "quick_shot", 190462 )
        addTrait( "rapid_killing", 191339 )
        addTrait( "survival_of_the_fittest", 190514 )
        addTrait( "unerring_arrows", 238052 )
        addTrait( "wind_arrows", 214826 )
        addTrait( "windburst", 204147 )
        addTrait( "windflight_arrows", 214915 )
        addTrait( "windrunners_guidance", 190457 )

        -- Traits Survival
        addTrait( "aspect_of_the_skylord", 203755 )
        addTrait( "bird_of_prey", 224764 )
        addTrait( "eagles_bite", 203757 )
        addTrait( "echoes_of_ohnara", 238125 )
        addTrait( "embrace_of_the_aspects", 225092 )
        addTrait( "explosive_force", 203670 )
        addTrait( "ferocity_of_the_unseen_path", 241115 )
        addTrait( "fluffy_go", 203669 )
        addTrait( "fury_of_the_eagle", 203415 )
        addTrait( "hellcarver", 203673 )
        addTrait( "hunters_bounty", 203749 )
        addTrait( "hunters_guile", 203752 )
        addTrait( "iron_talons", 221773 )
        addTrait( "jaws_of_the_mongoose", 238053 )
        addTrait( "lacerating_talons", 203578 )
        addTrait( "my_beloved_monster", 203577 )
        addTrait( "raptors_cry", 203638 )
        addTrait( "sharpened_fang", 203566 )
        addTrait( "talon_bond", 238089 )
        addTrait( "talon_strike", 203563 )
        addTrait( "terms_of_engagement", 203754 )
        addTrait( "voice_of_the_wild_gods", 214916 )

        ------------------------------------------------------------------------
        -- Buffs/Debuffs
        ------------------------------------------------------------------------
        
        -- Buffs/Debuffs Generic
        addAura( 'a_murder_of_crows', 206505, 'duration', 15 )
            modifyAura( 'a_murder_of_crows', 'id', function( x )
                if not spec.survival then return 131894 end -- Murder of Crows is the same for BM and MM
                return x
            end )
            class.auras[ 131894 ] = class.auras[ 206505 ]
        addAura( 'aspect_of_the_cheetah', 186258, 'duration', 12 )
        addAura( 'aspect_of_the_cheetah_sprint', 186257, 'duration', 3 )
        addAura( 'aspect_of_the_turtle', 186265, 'duration', 8 )
        addAura( 'camouflage', 199483, 'duration', 60 ) -- BM,MM
        addAura( 'feign_death', 5384, 'duration', 360 )
        addAura( 'freezing_trap', 3355, 'duration', 60 )
        addAura( 'posthaste', 118922, 'duration', 5 )
        addAura( 'trailblazer', 231390, 'duration', 3600 )

        -- Buffs/Debuffs Beast Mastery
        addAura( 'aspect_of_the_wild', 193530, 'duration', 14 )
        addAura( 'bestial_ferocity', 191413, 'duration', 6 )
            addMetaFunction( 'state', 'bestial_ferocity', function () return buff.bestial_ferocity end )
        addAura( 'bestial_wrath', 19574, 'duration', 15 )
        addAura( 'intimidation', 24394, 'duration', 5 )
        addAura( 'dire_frenzy_1', 246152, 'duration', 8 )
        addAura( 'dire_frenzy_2', 246851, 'duration', 8 )
        addAura( 'dire_frenzy_3', 246852, 'duration', 8 )
        addAura( 'dire_frenzy_4', 246853, 'duration', 8 )
        addAura( 'dire_frenzy_5', 246854, 'duration', 8 )
        addAura( 'dire_frenzy', 217200, 'duration', 8, 'max_stack', 8, 'feign', function ()
            -- This is a real aura, but it is applied to our pet.
            local up, _, _, count, _, duration, expires, caster, _, _, spellID, _, _, _, _, timeMod, v1, v2, v3 = UnitBuff( "pet", class.abilities.dire_frenzy.name )

            buff.dire_frenzy.name = up or class.abilities.dire_frenzy.name
            buff.dire_frenzy.count = up and count or 0
            buff.dire_frenzy.expires = up and expires or 0
            buff.dire_frenzy.applied = up and ( expires - duration ) or 0
            buff.dire_frenzy.caster = up and caster or "player"
        end )
        addAura( 'titans_thunder', 207094, 'duration', 30, 'feign', function ()
            -- This is a real aura, but it is applied to our pet.
            local i, found = 1, false
            local up, count, duration, expires, caster, spellID, timeMod, v1, v2, v3
            while( true ) do
                up, _, _, count, _, duration, expires, caster, _, _, spellID, _, _, _, _, timeMod, v1, v2, v3 = UnitBuff( "pet", i )

                if not up then break end

                if spellID == 207094 then
                    found = true
                    break
                end
                
                i = i + 1
            end

            buff.titans_thunder.name = class.abilities.titans_thunder.name
            buff.titans_thunder.count = found and count or 0
            buff.titans_thunder.expires = found and expires or 0
            buff.titans_thunder.applied = found and ( expires - duration ) or 0
            buff.titans_thunder.caster = found and caster or "player"
        end )
        addAura( 'titans_frenzy', 218638, 'duration', 10, 'name', "Titan's Frenzy", 'feign', function ()
            -- This is a real aura, but it is applied to our pet.
            local i, found = 1, false
            local up, count, duration, expires, caster, spellID, timeMod, v1, v2, v3
            while( true ) do
                up, _, _, count, _, duration, expires, caster, _, _, spellID, _, _, _, _, timeMod, v1, v2, v3 = UnitBuff( "pet", i )

                if not up then break end

                if spellID == 218638 then
                    found = true
                    break
                end

                i = i + 1
            end

            buff.titans_frenzy.name = "Titan's Frenzy"
            buff.titans_frenzy.count = found and count or 0
            buff.titans_frenzy.expires = found and expires or 0
            buff.titans_frenzy.applied = found and ( expires - duration ) or 0
            buff.titans_frenzy.caster = found and caster or "player"
        end )

        -- Buffs/Debuffs Marksmanship
        addAura( "bombardment", 35110, "duration", 5 )
        addAura( "binding_shot", 117405, "duration", 10 )
        addAura( "binding_shot_stun", 117526, "duration", 5 )
        addAura( "black_arrow", 194599, "duration", 8 )
        addAura( "bullseye", 204090, "duration", 6, "max_stack", 30 )
        addAura( "bursting_shot", 224729, "duration", 4 )
        addAura( "careful_aim", 63648, "duration", 8 )
        addAura( "concussive_shot", 5116, "duration", 6 )
        addAura( 'cyclonic_burst', 242712, 'duration', 5 )
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

        -- Buffs/Debuffs Survival
        addAura( 'aspect_of_the_eagle', 186289, 'duration', 10 )
        addAura( 'butchers_bone_apron', 236446, 'duration', 30, 'max_stack', 10 )
        addAura( 'caltrops', 194279, 'duration', 6 )
        addAura( 'dragonsfire_grenade', 194858, 'duration', 8 )
        addAura( 'explosive_trap', 13812, 'duration', 10 )
        addAura( "exposed_flank", 252094, "duration", 20 )
            class.auras.t21_exposed_flank = class.auras.exposed_flank
        addAura( 'harpoon', 190927, 'duration', 3 )
        addAura( 'helbrine_rope_of_the_mist_marauder', 213154, 'duration', 10 )
        addAura( "in_for_the_kill", 252095, "duration", 15, "max_stack", 6 )
        addAura( 'lacerate', 185855, 'duration', 12 )
        addAura( 'moknathal_tactics', 201081, 'duration', 10, 'max_stack', 4 )
        addAura( 'mongoose_fury', 190931, 'duration', 14, 'max_stack', 6 )
        addAura( 'mongoose_power', 211362, 'duration', 10 )
        addAura( 'on_the_trail', 'duration', 12 )
        addAura( 'rangers_net', 206755, 'duration', 15 )
        addAura( 'rangers_net_root', 200108, 'duration', 3 )
        addAura( 'serpent_sting', 118253, 'duration', 15 )
        addAura( 'spitting_cobra', 194407, 'duration', 30 )
        addAura( 'survivalist', 164856, 'duration', 10 )
        addAura( 'tar_trap', 135299, 'duration', 60 )

        ------------------------------------------------------------------------
        -- Gear Sets, Artifact, Legendaries
        ------------------------------------------------------------------------

        -- Sets
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
    
        -- Generic Legendaries
        addGearSet( 'the_shadow_hunters_voodoo_mask', 137064 )
        addGearSet( 'prydaz_xavarics_magnum_opus', 132444 )
        addGearSet( 'call_of_the_wild', 137101 )
        addGearSet( 'vigilance_perch', 146668 )
        addGearSet( 'kiljaedens_burning_wish', 144259 )
        addGearSet( 'roots_of_shaladrassil', 132466 )
        addGearSet( 'sephuzs_secret', 132452 )
        addGearSet( 'soul_of_the_huntmaster', 151641 )
            setTalentLegendary( 'soul_of_the_huntmaster', 'survival', 'serpent_sting' )
            setTalentLegendary( 'soul_of_the_huntmaster', 'marksmanship', 'lock_and_load' )
            setTalentLegendary( 'soul_of_the_huntmaster', 'beast_mastery', 'bestial_wrath' )
        addGearSet( 'insignia_of_the_grand_army', 152626 )

        -- BM Legendaries
        addGearSet( 'the_mantle_of_command', 144326 )
            addAura( 'the_mantle_of_command', 247993, 'duration', 8 )
        addGearSet( 'parsels_tongue', 151805 )
            addAura( 'parsels_tongue', 248085, 'duration', 8, 'max_stack', 4 )
        addGearSet( 'qapla_eredun_war_order', 137227 )
        addGearSet( 'roar_of_the_seven_lions', 137080 )
        addGearSet( 'the_apex_predators_claw', 137382 )

        -- MM Legendaries
        addGearSet( 'celerity_of_the_windrunners', 151803 )
            addAura( "celerity_of_the_windrunners", 248088, "duration", 6 )
        addGearSet( 'magnetized_blasting_cap_launcher', 141353 )
        addGearSet( "mkii_gyroscopic_stabilizer", 144303 )
            addAura( "gyroscopic_stabilization", 235712, "duration", 3600 )
        addGearSet( "ullrs_feather_snowshoes", 137033 )
        addGearSet( "war_belt_of_the_sentinel_army", 137081 )
            addAura( "sentinels_sight", 208913, "duration", 20, "max_stack", 20 )
        addGearSet( "zevrims_hunger", 137055 )

        -- SV Legendaries
        addGearSet( 'unseen_predators_cloak', 151807 )
        addGearSet( 'butchers_bone_apron', 144361 )
        addGearSet( 'helbrine_rope_of_the_mist_marauder', 137082 )
        addGearSet( 'nesingwarys_trapping_threads', 137034 )
        addGearSet( 'frizzos_fingertrap', 137043 )

        
        ------------------------------------------------------------------------
        -- Hooks
        ------------------------------------------------------------------------

        addHook( 'specializationChanged', function ()
            if state.spec.survival then addTalent( 'a_murder_of_crows', 206505 )
            else addTalent( 'a_murder_of_crows', 131894 ) end
            setPotion( 'old_war' ) -- true for Sv, anyway.
            setRole( 'attack' )
        end )


        addHook( 'reset_precast', function( x )
            rawset( state.pet, 'ferocity', IsSpellKnown( 55709, true ) )
            rawset( state.pet, 'tenacity', IsSpellKnown( 53478, true ) )
            rawset( state.pet, 'cunning', IsSpellKnown( 53490, true ) )
        end )

        ------------------------------------------------------------------------
        -- Settings + Meta + fake auras
        ------------------------------------------------------------------------

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
        addAura( 'beast_cleave', -101, 'name', 'Beast Cleave', 'duration', 4, 'feign', function ()
                local up = query_time < last_multishot + 4
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
            local up = last_sentinel + duration < query_time

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

        local function genericHasteMod( x )
            return x * haste
        end
        setfenv( genericHasteMod, state )

        ------------------------------------------------------------------------
        -- Abilities, modifiers and Handlers
        ------------------------------------------------------------------------
    
        ------------------------------------------------------------------------
        -- Abilities generic


        --[[
            Summons a flock of crows to attack your target over the next 15
            sec. If the target dies while under attack, A Murder of Crows'
            cooldown is reset.
        ]]
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


        --[[
            The Hunter takes on the aspect of a chameleon, becoming untrackable.
        ]]
        addAbility( "aspect_of_the_chameleon", {
            id = 61648,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            cooldown = 180,
            min_range = 0,
            max_range = 0,
        } )

        modifyAbility( 'aspect_of_the_chameleon', 'cooldown', function( x )
            if equipped.call_of_the_wild then return x * 0.65 end
            return x
        end )

        addHandler( "aspect_of_the_chameleon", function ()
            applyBuff( "aspect_of_the_chameleon" )
        end )


        --[[
            Increases your movement speed by 90% for 3 sec, and then by 30% for
                another 9 sec.
        ]]
        addAbility( 'aspect_of_the_cheetah', {
            id = 186257,
            spend = 0,
            spend_type = 'focus',
            cast = 0,
            gcdType = 'off',
            cooldown = 180,
        } )

        modifyAbility( 'aspect_of_the_cheetah', 'cooldown', function ()
            if equipped.call_of_the_wild then return x * 0.65 end
            return x
        end )

        addHandler( 'aspect_of_the_cheetah', function( x )
            applyBuff( 'aspect_of_the_cheetah_sprint', 3 )
            applyBuff( 'aspect_of_the_cheetah', 12 )
            if artifact.feet_of_wind.enabled then applyBuff( "feet_of_wind" ) end
        end )


        --[[
            Deflects all attacks and reduces all damage you take by 30% for 8
            sec, but you cannot attack.
        ]]
        addAbility( 'aspect_of_the_turtle', {
            id = 186265,
            spend = 0,
            spend_type = 'focus',
            cast = 0,
            gcdType = 'off',
            cooldown = 180,
        } )

        modifyAbility( 'aspect_of_the_turtle', 'cooldown', function( x )
            if equipped.call_of_the_wild then return x * 0.65 end
            return x
        end )

        addHandler( 'aspect_of_the_turtle', function ()
            applyBuff( 'aspect_of_the_turtle', 8 )
            setCooldown( 'global_cooldown', 8 )
        end )
        
        
        --[[
            Rapidly fires a spray of shots for 3 sec, dealing an average of 
            80% * 10) Physical damage to all enemies in front of you. Usable
            while moving.
        ]]
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
            if spec.marksmanship and set_bonus.tier19 > 3 then
                return x * 0.85
            end
            return x
        end )

        modifyAbility( "barrage", "cast", genericHasteMod )

        addHandler( "barrage", function ()
            if equipped.ullrs_feather_snowshoes and cooldown.trueshot.expires > 0 then cooldown.trueshot.expires = cooldown.trueshot.expires - 0.8 end
        end )


        --[[
            Fires a magical projectile, tethering the enemy and any other 
            enemies within 5 yards for 10 sec, stunning them for 5 sec if they
            move more than 5 yards from the arrow. Player targets are stunned
            for a shorter duration.
        ]]
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
        
        
        --[[
            You and your pet blend into the surroundings and gain stealth for 1
            min. While camouflaged, you will heal for 2% of maximum health
            every 1 secs.
        ]]
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
        

        --[[
            Dazes the target, slowing movement speed by 50% for 6 sec.
        ]]
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


        --[[
            Interrupts spellcasting, preventing any spell in that school from
            being cast for 3 sec.
        ]]
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


        --[[
            Leap backwards
            Posthaste: clearing movement impairing effects, and increasing your     movement speed by 60% for 5 sec
            Narrow Escape: and activating a web trap which encases all targets      within 8 yards in sticky webs, preventing movement for 8 sec
        ]]
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


        --[[
            Heals you for 30% and your pet for 100% of maximum health.
        ]]
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


        --[[
            Feign death, tricking enemies into ignoring you. Lasts up to 6 min.
        ]]
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


        --[[
            Fires several missiles, hitting your current target and all enemies
            within 8 yards for 100% Physical damage
            BM: and triggering Beast Cleave
            MM: Generates 3 Focus per target hit.
        ]]
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
            recheck = function () return buff.beast_cleave.remains - gcd, buff.beast_cleave.remains end,
            velocity = 50,
        } )

        modifyAbility( "multishot", "spend", function( x )
            if spec.beast_mastery then
                x = 40
                if equipped.roar_of_the_seven_lions and buff.bestial_wrath.up then x = x * 0.85 end
                return x
            end
            if set_bonus.tier21 > 1 then x = x * 1.25 end
            return x * active_enemies
        end )

        addHandler( "multishot", function ()
            if spec.beast_mastery then
                if active_enemies > 1 then applyBuff( "beast_cleave" ) end
                return
            end
            -- Marksmanship.
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


        --[[
            Summons your first pet to you.
        ]]        
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


        --[[
            Hurls a frost trap to the target location that incapacitates the
            first enemy that approaches for 1 min. Damage will break the
            effect. Limit 1. Trap will exist for 1 min.
        ]]
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


        --[[
            Hurls a tar trap to the target location that creates a 8 yd radius
            pool of tar around itself for 30 sec when the first enemy
            approaches. All enemies have 50% reduced movement speed while in
            the area of effect. Trap will exist for 1 min.
        ]]
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


        --[[
            While active, your auto attacks spend 3 Focus to also launch a
            volley of shots that hit the target and all other nearby enemies,
            dealing (100% of Attack power) additional Physical damage.
        ]]
        addAbility( "volley", {
            id = 194386,
            spend = 0,
            cast = 0,
            gcdType = "spell",
            talent = "volley",
            cooldown = 1.5,
            min_range = 0,
            max_range = 0,
            nobuff = "volley"
        } )

        modifyAbility( 'volley', 'cooldown', genericHasteMod )

        addHandler( "volley", function ()
            if buff.volley.down then
                applyBuff( "volley" )
            elseif buff.volley.up then
                removeBuff( "volley" )
            end
        end )


        --[[
            A stinging shot that puts the target to sleep, incapacitating them
            for 30 sec. Damage will cancel the effect. Usable while moving.
        ]]
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


        ------------------------------------------------------------------------
        -- Abilities Beast Mastery

        
        --[[
            Grants you and your pet 10 Focus per 1 sec and 10% increased
            critical strike chance on all attacks for 10 sec.
        ]]
        addAbility( 'aspect_of_the_wild', {
            id = 193530,
            spend = 0,
            spend_type = 'focus',
            cast = 0,
            gcdType = 'off',
            cooldown = 120,
            toggle = 'cooldowns',
        } )

        modifyAbility( 'aspect_of_the_wild', 'cooldown', function( x )
            if equipped.call_of_the_wild then return x * 0.65 end
            return x
        end )

        addHandler( 'aspect_of_the_wild', function ()
            applyBuff( 'aspect_of_the_wild' )
        end )


        --[[
            Sends you and your pet into a rage, increasing all damage you both
            deal by 25% for 15 sec.
            Bestial Wrath's remaining cooldown is reduced by 12 sec each time
            you use Dire Frenzy/Dire Beast
        ]]
        addAbility( 'bestial_wrath', {
            id = 19574,
            spend = 0,
            spend_type = 'focus',
            cast = 0,
            gcdType = 'off',
            cooldown = 90,
            recheck = function () return buff.bestial_wrath.remains end,
            toggle = 'cooldowns',
        } )
        

        addHandler( 'bestial_wrath', function ()
            applyBuff( 'bestial_wrath', 15 )
        end )


        --[[
            A two-headed shot that hits your primary target and another nearby
            target, dealing 720% Nature damage to one and 720% Frost damage to
            the other.
            Generates 10 Focus for each target hit.
        ]]
        addAbility( 'chimaera_shot', {
            id = 53209,
            spend = 0,
            spend_type = 'focus',
            cast = 0,
            cooldown = 15,
            talent = 'chimaera_shot'
         } )

        modifyAbility( 'chimaera_shot', 'cooldown', genericHasteMod )

        addHandler( 'chimaera_shot', function ()
            gain( min( 20, active_enemies * 10 ), 'focus' )
        end )


        --[[
            A quick shot causing 270% Physical damage.
        ]]
        addAbility( 'cobra_shot', {
            id = 193455,
            spend = 40,
            spend_type = 'focus',
            cast = 0,
            gcd_type = 'spell',
            recheck = function () return buff.bestial_wrath.remains - ( gcd * 2 ), buff.parsels_tongue.remains - ( gcd * 2 ) end,
            cooldown = 0,
        } )
        
        modifyAbility( 'cobra_shot', 'spend', function( x )
            if equipped.roar_of_the_seven_lions and buff.bestial_wrath.up then x = x * 0.85 end
            return x - ( 2 * artifact.slithering_serpents.rank )
        end )
        
        addHandler( 'cobra_shot', function()
            if talent.killer_cobra.enabled and buff.bestial_wrath.up then
                setCooldown( 'kill_command', 0 )
            end

            if equipped.parsels_tongue then addStack( 'parsels_tongue', 8, 1 ) end
        end)


        --[[
            Summons a powerful wild beast to attack your target for 8 sec.
            Generates 12 Focus over 8 sec.
        ]]
        addAbility( 'dire_beast', {
            id = 120679,
            spend = 0,
            spend_type = 'focus',
            cast = 0,
            charges = 2,
            recharge = 12,
            cooldown = 12,
            notalent = 'dire_frenzy',
            recheck = function () return full_recharge_time - gcd end,
            gcdType = 'spell',
        })
        
        modifyAbility( 'dire_beast', 'recharge', genericHasteMod )
        modifyAbility( 'dire_beast', 'cooldown', genericHasteMod )

        --[[ addCooldownMetaFunction( "dire_beast", "full_recharge_time", function( x )
            if talent.dire_frenzy.enabled then return 0 end
            return ( cooldown.dire_beast.max_charges - cooldown.dire_beast.charges_fractional ) * cooldown.dire_beast.recharge
        end ) ]]
        
        addHandler( 'dire_beast', function()
            cooldown.bestial_wrath.expires = max( state.time, cooldown.bestial_wrath.expires - 12 )

            if equipped.qapla_eredun_war_order then
                cooldown.kill_command.expires = max( state.time, cooldown.kill_command.expires - 3 )
            end

            if equipped.the_mantle_of_command then applyBuff( 'the_mantle_of_command' ) end
        end )


        --[[
            Causes your pet to enter a frenzy, performing a flurry of 5 attacks
            on the target, and gaining 30% increased attack speed for 8 sec,
            stacking up to 3 times.
            Generates 24 Focus over 8 sec.
        ]]
    	addAbility( 'dire_frenzy', {
            id = 217200,
            spend = 0,
            spend_type = 'focus',
            cast = 0,
            charges = 2,
            recharge = 12,
            cooldown = 12,
            talent = 'dire_frenzy',
            recheck = function () return buff.dire_frenzy.remains - ( gcd * 1.2 ), full_recharge_time - gcd end,
            gcdType = 'spell',
        })
        
        modifyAbility( 'dire_frenzy', 'recharge', genericHasteMod )
        modifyAbility( 'dire_frenzy', 'cooldown', genericHasteMod )

        --[[ addCooldownMetaFunction( "dire_frenzy", "full_recharge_time", function( x )
            if not talent.dire_frenzy.enabled then return 0 end
            return ( cooldown.dire_frenzy.max_charges - cooldown.dire_frenzy.charges_fractional ) * cooldown.dire_frenzy.recharge
        end) ]]
        
        addHandler( 'dire_frenzy', function()
            cooldown.bestial_wrath.expires = max( state.time, cooldown.bestial_wrath.expires - 12 )

            if equipped.qapla_eredun_war_order then
                cooldown.kill_command.expires = max( state.time, cooldown.kill_command.expires - 3 )
            end

            if equipped.the_mantle_of_command then applyBuff( 'the_mantle_of_command' ) end

            addStack( 'dire_frenzy', 8, 1 )

            -- player focus regen auras.
            for i = 1, 5 do
                if buff[ 'dire_frenzy_' .. i ].down then
                    applyBuff( 'dire_frenzy_' .. i )
                    break
                end
            end
        end )


        --[[
            Commands your pet to intimidate the target, stunning it for 5 sec.
        ]]
        addAbility( 'intimidation', {
            id = 19577,
            spend = 0,
            cast = 0,
            gcdType = 'spell',
            cooldown = 60,
            talent = 'intimidation',
        } )

        addHandler( 'intimidation', function ()
            applyDebuff( 'target', 'intimidation', 5 )
        end )


        --[[
            Give the command to kill, causing your pet to savagely deal [1.5 *
            (0 + (Ranged attack power * 3.6)) * 1.18 * (0.5 + min(Level, 20) *
            0.025) * (1 + Versatility)] Physical damage to its target. 40 yd
            range.
        ]]
        addAbility( 'kill_command', {
            id = 34026,
            spend = 30,
            spend_type = 'focus',
            cast = 0,
            gcdType = 'spell',
            recheck = function () return buff.dire_frenzy.remains end,
            cooldown = 7.5,
        } )

        modifyAbility( 'kill_command', 'spend', function( x )
            if equipped.roar_of_the_seven_lions and buff.bestial_wrath.up then x = x * 0.85 end
            return x
        end )
        
        modifyAbility( 'kill_command', 'cooldown', genericHasteMod )
        
        addHandler( 'kill_command', function()
            if set_bonus.tier21_4pc > 0 then
                cooldown.aspect_of_the_wild.expires = max( state.time, cooldown.aspect_of_the_wild.expires - 3 )
            end
            if pet.ferocity then applyDebuff( 'target', 'bestial_ferocity', 6 ) end
        end )


        --[[
            Summon a herd of stampeding animals from the wilds around you that
            deal damage to your enemies for 12 sec.
        ]]
        addAbility( 'stampede', {
            id = 201430,
            spend = 0,
            cast = 0,
            gcdType = 'spell',
            cooldown = 180,
            toggle = 'cooldowns',
            recheck = function ()
                return cooldown.bestial_wrath.remains - 2
            end,
            talent = 'stampede',
        } )       

        -- Will want to check APLs to see if there's a hidden buff or totem to track for uptime.


        --[[
            Discharge a massive jolt of electricity from Titanstrike into all
            your pets and Dire Beasts, causing them to deal up to (Ranged
            attack power * 1.15 * 0.5 * 1) Nature damage to their target every
            1 sec. for 8 sec.

            Dire Frenzy
            Also causes your next Dire Frenzy to deal (200% of Attack power)
            additional Nature damage on each of the 5 Dire Frenzy attacks
        ]]
        addAbility( 'titans_thunder', {
            id = 207068,
            spend = 0,
            spend_type = 'focus',
            cast = 0,
            gcdType = 'spell',
            cooldown = 60,
            toggle = 'artifact',
        } )

        addHandler( 'titans_thunder', function ()
            applyBuff( 'titans_thunder' )
            applyBuff( 'titans_frenzy' )
        end )


        ------------------------------------------------------------------------
        -- Abilities Marksmanship


        --[[
            A powerful aimed shot that deals [425% * ((max(0, min(Level - 10, 
            0)) * 8 + 130) / 210)] Physical damage.  Damage increased by 50%
            against a target you have not yet damaged.
        ]]
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


        --[[
            A quick shot that causes [200% * ((max(0, min(Level - 10, 10)) * 5
            + 80) / 130)] Arcane damage.
            Generates 8 Focus.
        ]]
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


        --[[
            Fires a Black Arrow at the target, dealing (520% of Attack power)
            Shadow damage over 8 sec and summoning a Dark Minion to taunt it
            for the duration.
            When you kill an enemy, the remaining cooldown on Black Arrow will
            reset.
        ]]
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


        --[[
            Fires an explosion of bolts at all enemies in front of you,
            knocking them back, disorienting them for 4 sec, and dealing 40%
            Physical damage.
        ]]
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

        
        --[[
            Fires a slow-moving munition directly forward. Activating this
            ability a second time detonates the Shot, dealing up to (1000% of
            Attack power) Fire damage to all enemies within 8 yds, damage based
            on proximity.
        ]]
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


        --[[
            Rapidly fires shots at all targets with your Hunter's Mark, dealing
            550% Physical damage and making them Vulnerable for 7 sec.

            Vulnerable
            Damage taken from Aimed Shot and Piercing Shot increased by 30% for
            7 sec.
        ]]
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


        --[[
            A powerful shot which deals up to (2 * 775%) Physical damage to the
            target and up to 775% Physical damage to all enemies between you
            and the target. Damage increased against targets with Vulnerable.
        ]]
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


        --[[
            Your Sentinel watches over the target area for 18 sec, applying
            Hunter's Mark to all enemies every 6 sec.
        ]]
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


        --[[
            Launches Sidewinders that travel toward the target, weaving back
            and forth and dealing (500% of Attack power) Nature damage to each
            target they hit. Cannot hit the same target twice. Applies
            Vulnerable to all targets hit.
            Generates 35 Focus.
            Also replaces Multi-Shot.
        ]]
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

        --[[ addCooldownMetaFunction( "sidewinders", "full_recharge_time", function( x )
            if not talent.sidewinders.enabled then return 0 end
            return ( cooldown.sidewinders.max_charges - cooldown.sidewinders.charges_fractional ) * cooldown.sidewinders.recharge
        end ) ]]

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

        
        --[[
            Increases haste by 40% and causes Arcane Shot and Multi-Shot to
            always apply Hunter's Mark. Lasts 15 sec.
        ]]
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


        --[[
            Focuses the power of Wind through Thas'dorah, dealing 800% Physical
            damage to your target, and leaving behind a trail of wind for 5 sec
            that increases the movement speed of allies by 50%.
        ]]
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


        ------------------------------------------------------------------------
        -- Abilities Survival


        --[[
            Grants you and your pet 0% increased Critical Strike chance on all
            abilities, and your pet's attacks have an additional 25% chance to
            grant you a charge of Mongoose Bite. Lasts 10 sec.
        ]]
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
            if equipped.call_of_the_wild then return x * 0.65 end
            return x
        end )

        addHandler( 'aspect_of_the_eagle', function ()
            applyBuff( 'aspect_of_the_eagle', 10 )
            stat.mod_crit_pct = stat.mod_crit_pct + 20
        end )


        --[[
            Strike all nearby enemies in a flurry of strikes, inflicting 694%
            Physical damage to each.
        ]]
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

        
        --[[
            Scatters Caltrops in an area for 15 sec. Enemies who step on
            Caltrops will take (45% of Attack power) Bleed damage every 1 sec,
            and have 70% reduced movement speed for 6 sec.
        ]]
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


        --[[
            A sweeping attack that strikes all enemies in front of you for 324%
            Physical damage.
        ]]
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


        --[[
            Hurls a dragonsfire grenade at the target that explodes into flames,
            inflicting [(1304% of Attack power) + (400% of Attack power)] Fire
            damage over 8 sec and reducing movement speed by 20%. The volatile
            flames on the target also scorch nearby enemies.
        ]]
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


        --[[
            Hurls a fire trap to the target location  that explodes when an
            enemy approaches, causing (420% of Attack power) Fire damage and
            burning all enemies within 8 yards for (420% of Attack power)
            additional Fire damage over 10 sec. Trap will exist for 1 min.
        ]]
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


        --[[
            A coordinated attack on the target, where you deal [390% * ((max(0,
            min(Level - 10, 10)) * 7 + 130) / 200)] Physical damage and your
            pet deals [1.6 * ((Attack power * 4.2)) * (1 + Versatility) *
            (min(Level, 20) * 0.05)] Physical damage.
            If the target is attacking you, your pet's attack will deal 50%
            increased damage and 400% increased threat. Otherwise, your attack
            will deal 50% increased damage.
            Flanking strike has double the normal chance to trigger Hunting
            Companion
        ]]
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


        --[[
            Furiously strikes all enemies in front of you, dealing ((125% of
            Attack power) * 9) Physical damage over 4 sec. Damage increased by
            Mongoose Fury.
        ]]
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

        
        --[[
            Hurls a harpoon at an enemy, rooting them in place for 3 sec and
            pulling you to them.
        ]]
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


        --[[
            Tosses a hatchet at an enemy, dealing (10% of Attack power)
            Physical damage.
        ]]
        addAbility( 'hatchet_toss', {
            id = 193265,
            spend = 0,
            spend_type = 'focus',
            cast = 0,
            gcdType = 'melee',
            cooldown = 0,
            velocity = 40,
        } )


        --[[
            Tears a bleeding wound in the target, dealing [(964.8% of Attack
            power) + (187.2% of Attack power)] Physical damage over 12 sec.
        ]]
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


        --[[
            Attempts to sever the target's limbs with a brutal attack that
            deals 300% Physical damage and grants you Mongoose Fury.
            Mongoose Fury increases Mongoose Bite damage by 50% for 14 sec,
            stacking up to 6 times. Successive attacks do not increase duration.
        ]]
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


        --[[
            Interrupts spellcasting, preventing any spell in that school from
            being cast for 3 sec.
        ]]
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


        --[[
            Hurls a net at the enemy, rooting the target for 3 sec and reducing
            movement speed by 50% for 15 sec. Damage may break the effect.
        ]]
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


        --[[
            A vicious slash dealing 257% Physical damage.
        ]]
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


        --[[
            Summons a Spitting Cobra for 30 sec that attacks your target for
            (100% of Attack power) Nature damage every 2 sec. While the Cobra
            is active you gain an extra 3 Focus every 1 sec.
        ]]
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


        --[[
            Instantly grants you 3 charges of Mongoose Bite.
        ]]
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


        --[[
            Hurls a Steel Trap to the target location that immobilizes the
            first enemy that approaches for 30 sec and deals (1500% of Attack
            power) bleed damage over 30 sec. Other damage may break the
            immobilization effect. Limit 1. Trap will exist for 1 min.
            Waylay: Fully arms after 2 sec, dealing 500% increased damage if
            triggered by an enemy that is not in combat.
        ]]
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


        --[[
            Hurls a concussive grenade at your target which sticks to them and
            explodes after 2 sec, knocking back all nearby enemies.
        ]]
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


        --[[
            Tosses 3 axes at an enemy, each dealing (312.5% of Attack power)
            Physical damage.
        ]]
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


    end


    storeDefault( [[SimC Survival: CDs]], 'actionLists', 20171128.180630, [[d0Z8faGEqjAtuPAxuyBKs0(aLQVrqMnqZhuXnb0Pv42GCzv7ek7vA3eTFHgfPKgguzCksL7rkLHQiLgSGHtfhIkLCkQuCmk6WkTqfvlLuSyeTCsEiOQvPifltr8CQAIGsAQeyYiz6qUib16OsPEgOsxhHnckHTsQ0MrQTROmnsj8BrFgGVtkvJurQ6POgnu18aLYjjv8ykDnfjNNu1Fj0RPsoiO4AwbLH1tVeGOoVm2c9Y8ac(yGjuZgZwq3ogGhw9L1CWV(xSj4mfY0CY0zyc3P0ctZYSvnCqLldJfnsPVckMzfuwy5scEQoVmBvdhuz60s4nSek1LOya20wmaxCLHHCaoq6lVk7kVikvQlrL1rsnSlkvLLP8LbMu6UkSf6LlJTqVmmk7kFmiivQlrL1CWV(xSj4mfYexzn3Nek79vqrLHh)TUaMZo0LOswgysHTqVCrfBsfuwy5scEQoVmBvdhuzscAAJ17ClsmPfr4V4xaG3GWPmmKdWbsFzYR8x5Aibuwhj1WUOuvwMYxgysP7QWwOxUm2c9YZVYFLRHeqznh8R)fBcotHmXvwZ9jHYEFfuuz4XFRlG5SdDjQKLbMuyl0lxuXGBfuwy5scEQoVmBvdhuzscAAJ17ClsmPfr4V4xaG3GWPmmKdWbsFzsWmPePju6lRJKAyxuQklt5ldmP0Dvyl0lxgBHE55GzsfdWccL(YAo4x)l2eCMczIRSM7tcL9(kOOYWJ)wxaZzh6sujldmPWwOxUOIPfvqzHLlj4P68YSvnCqLjjOPnwVZTiXKweH)IFbaEdcNyW9yqRXajbnTb5v(RCnKamiCIb4aNyGKGM2GemtkrAcLEdcNyWnLHHCaoq6l7KOrklRJKAyxuQklt5ldmP0Dvyl0lxgBHE5PnrJuwwZb)6FXMGZuitCL1CFsOS3xbfvgE836cyo7qxIkzzGjf2c9YfvSPQGYclxsWt15LzRA4GkBZeKk1U0akLaY0FrYb6gw8RcW9XG2IbCXG7XajbnTbukbKP)I0ek9gQdTdPpgG9yaUXW0edaSuXG7XGwJbBMGuP2LgR35wKyslIWFXVaaVH6q7q6JbypgMkgCpgCRyGKGM2y9o3IetAre(l(fa4niCIb3uggYb4aPVSxUUUiEcj6QY6iPg2fLQYYu(YatkDxf2c9YLXwOxMLRRhdtpHeDvznh8R)fBcotHmXvwZ9jHYEFfuuz4XFRlG5SdDjQKLbMuyl0lxuX0YkOSWYLe8uDEz2QgoOYRfnMDrOucit)fPju6Jb3JbTgd2mbPsTlnGsjGm9xKCGUHf)QaCFmOTyaxmah4edKe00gqPeqM(lstO0BOo0oK(ya2IbtZyWnLHHCaoq6lVENBrIjTic)f)ca8L1rsnSlkvLLP8LbMu6UkSf6LlJTqVmmENBrXqshdi8pgeEba(YAo4x)l2eCMczIRSM7tcL9(kOOYWJ)wxaZzh6sujldmPWwOxUOIkZo3owWbSCrJuwSjtnvrTa]] )

    storeDefault( [[SimC Survival: AOE]], 'actionLists', 20171128.180630, [[dCJpdaGEOeTjjPSlLKxRKAFss1Sf18Hk1nf42k1oLyVu7gv7NO(jucddkghekdMidxqhusCkOsogIwiPYsHOfJslNKhIIEkyzi06Gq1eHqmvLyYqA6kUiPQNl0LvDDu4BqWwHQSzOuTDj1HLAAqP8zjjNMWHGq6zqfgnPy8qjDse0Jf5AiW5jL(ns)fQQrbv0M0lgqKJ9MrESodLEFdGyZuwcyOQf1DgXLLQGf6nG853X7crmKiqsseXwrIdcWgjPbiPeHJbdvsJGYJEXfsVyqpVzZh16muHvKfJwdSmMKMR0AGqoQi1dvzGt53qaffVwv69nyO07BqhJjP5kTgq(874DHigseiXya5JugQ0JEXJbMAEADaT(7ZhZAiGIw69n4XfIEXGEEZMpQ1zaskr4yarLLgrATGxLHkSISy0Ai15rrdJgiKJks9qvg4u(neqrXRvLEFdgk9(gy25rrdJgq(874DHigseiXya5JugQ0JEXJbMAEADaT(7ZhZAiGIw69n4XfC4fd65nB(OwNHkSISy0A4ynmtJI6J)O6qdeYrfPEOkdCk)gcOO41QsVVbdLEFd6XAyMgf1xwAr1Hgq(874DHigseiXya5JugQ0JEXJbMAEADaT(7ZhZAiGIw69n4XfS5fd65nB(OwNbiPeHJbCklnD(8zv8QWZh8JJGx1QZB28rLLQMSekDwfVk88b)4i4vTsDSREutZMVSeUKLWnULLWPSuNgr9X)8VfpklvDzjcKLWLHkSISy0Ai1Q6BGqoQi1dvzGt53qaffVwv69nyO07BGzRQVbKp)oExiIHebsmgq(iLHk9Ox8yGPMNwhqR)(8XSgcOOLEFdE8yacFs0zbw2JGYDHibe4Xg]] )

    storeDefault( [[SimC Survival: default]], 'actionLists', 20180317.095948, [[d4JUjaGEsQwMs0UuQY2erY(ijQMjjHFty2OCAf3uKoVsLVbv8qL0oHYEL2nr7hIFkIuddv14ijYHPAOIiAWQQHtPCqi5uKsDmLY5uQkTqOQwkPyXKQLtXIqv8uWJf16GknrOkmvvPjJktxLlQk6QKeLNbvPRtj)fsTvuL2SQW2jXLrMLsvX0GQOVRuvDBbVwegnLQpReojjLNl01er19ijDireoUikJIuYDRVfWd6HBXUIFbWgLhNnQ73iKfBzYtEbneJ8ivSL83WzBBPkT3MkXpPWBbiBgBxHcOY3iKX(wST(w4P01zexXVaKnJTRGwiFkzwJnBe3EpmJ6QlIOFmYfK5mUnKV2fqPpS52vqXnJRZOcR2PCIuHcfi5v9cPcoEDdMhOcpmJ6QlIptM1yZgXvaZdub4egc5ZRZSOcOmlIfKEGu9HzuxDr8zYSgB2iU9rXzwKQArjZASzJ42BdV4WhpXR2f0qmYJuXwYFdNn(f0qrHLjtX(2RGAsUj7NWuqkKuVITSVfEkDDgXv8lazZy7kOfY)CgjV92VVdT4b6ZoHoisi9ZUZ2JKUoJ4q(AxaL(WMBxbf3mUoJkSANYjsfkuGKx1lKk441nyEGkeejEDgjpIRaMhOcWjmeYNxNzriFT20UakZIybPhivdIeVoJKhXTpkoZIuvRZzK82B)(o0IhOp7e6GiH0p7oBps66mIt7cAig5rQyl5VHZg)cAOOWYKPyF7vqnj3K9tykifsQxXWBFl8u66mIR4xaL(WMBxbRiHEokelOMKBY(jmfKcjvivWXRBW8avOaMhOcQSiH8v7OqSGgIrEKk2s(B4SXVGgkkSmzk23EfwTt5ePcfkqYR6fsfCyEGk0Ry4zFl8u66mIR4xaYMX2vOak9Hn3Ucbl1vNrfutYnz)eMcsHKkKk441nyEGkuaZduHul1vNrf0qmYJuXwYFdNn(f0qrHLjtX(2RWQDkNivOqbsEvVqQGdZduHEfl59TWtPRZiUIFbiBgBxbf3mUoJ2lis86msEexbu6dBUDfYoJH2Z3iKOzt8kSANYjsfkuGKx1lKk441nyEGkuaZduHvNXq(OY3iKiFvmXRakZIybPhiv5bMWkYhSmkJIZWf5hejs9rE(i5PGgIrEKk2s(B4SXVGgkkSmzk23EfutYnz)eMcsHKkKk4W8avaMWkYhSmkJIZWf5hejs9rE(i7vSKQVfEkDDgXv8lGsFyZTRq2zm0E(gHenBIxb1KCt2pHPGuiPcPcoEDdMhOcfW8avy1zmKpQ8ncjYxft8q(ATPDbuMfXcspqQYdmHvKpyzugfNHlYFfpI8uqdXipsfBj)nC24xqdffwMmf7BVcR2PCIuHcfi5v9cPcompqfGjSI8blJYO4mCr(R4rSxXWPVfEkDDgXv8lazZy7k45Bui0KKcdfr(QCvr(4Tak9Hn3UczNXq75Bes0SjEfwTt5ePcfkqYR6fsfC86gmpqfkG5bQWQZyiFu5BesKVkM4H81AP2fqzweli9aPkpWewr(GLrzuCgUiFuj9tEkOHyKhPITK)goB8lOHIcltMI9Txb1KCt2pHPGuiPcPcompqfGjSI8blJYO4mCr(Os6N9kMk13cpLUoJ4k(fGSzSDfscKVNVrHqheYfcrKq)WYSRak9Hn3UczNXq75Bes0SjEfwTt5ePcfkqYR6fsfC86gmpqfka2f7pvWnpgYel(fW8avy1zmKpQ8ncjYxft8q(AHxTlGYSiwq6bsvEGjSI8blJYO4mCr(pggJmrEkOHyKhPITK)goB8lOHIcltMI9Txb1KCt2pHPGuiPcPcompqfGjSI8blJYO4mCr(pggJmXEfBF7BHNsxNrCf)cq2m2UcjbY3Z3OqOdc5cHisOFyz2vaL(WMBxHSZyO98ncjA2eVcR2PCIuHcfi5v9cPcoEDdMhOcfW8avy1zmKpQ8ncjYxft8q(AHNAxaLzrSG0dKQ8atyf5dwgLrXz4I81NJEnZIfKHNcAig5rQyl5VHZg)cAOOWYKPyF7vqnj3K9tykifsQqQGdZdubycRiFWYOmkodxKV(C0RzwSGm9k2g)(w4P01zexXVaKnJTRGNVrHqheYfcrKq)WYSRak9Hn3UczNXq75Bes0SjEfwTt5ePcfkqYR6fsfC86gmpqfkG5bQWQZyiFu5BesKVkM4H81k5AxaLzrSG0dKQ8atyf5dwgLrXz4I81NJss7EK4PGgIrEKk2s(B4SXVGgkkSmzk23EfutYnz)eMcsHKkKk4W8avaMWkYhSmkJIZWf5RphLK29i1RxbmpqfGjSI8blJYO4mCr(C0d3ID9Ab]] )

    storeDefault( [[SimC Survival: precombat]], 'actionLists', 20171128.180630, [[dqdbeaGEIu1UKO02isLzlQBsIBtv7KI9I2nH9lrgMQyCejzOKuAWIKHlLoOe6yq1ZLQfkIwQuSyIA5K6Huspf8yOSoIuAIKumvk1KL00HCrj43Q8msQCDsYYuvTvvL2SevBNi(irsDyHptK40uzKeP4BIuJwegpjvDsvj)Ls01OeoVQuttIIlR8AvftCAtqnR8qvgXKemHFeaN3APuGkTeNKilTLs1Qh25LdeHMLx0hn)p4PXX)LQYIRolkdoobat7Areiued5orN20GtBcfeHCEvMKqrzx2HEtORY7pHLTdr4LO6Wc0PjioXiOC1VH2e(rGGj8JG1iNlLsTdvkfoHMLx0hn)p4PXFi0S(PsJToTjIG1ed7JYjz(jquMGYvnHFeiIMFAtOGiKZRYKekk7Yo0BcThYDccVevhwGonbXjgbLR(n0MWpcemHFeu7HCNGqZYl6JM)h804peAw)uPXwN2erWAIH9r5Km)eiktq5QMWpcerJ6OnHcIqoVktsOOSl7qVjm13MVUtYSePJwcVevhwGonbXjgbLR(n0MWpcemHFekO(281DswPu26OLqZYl6JM)h804peAw)uPXwN2erWAIH9r5Km)eiktq5QMWpcertzOnHcIqoVktsOOSl7qVj0rBzlr6OLWlr1HfOttqCIrq5QFdTj8Jabt4hbaTLlLYwhTeAwErF08)GNg)HqZ6Nkn260MicwtmSpkNK5Narzckx1e(rGiASG2ekic58QmjHIYUSd9Mqvhs5e9YD6zPu0te1r4LO6Wc0PjioXiOC1VH2e(rGGj8JGA0HuorVCNELsj16jI6i0S8I(O5)bpn(dHM1pvAS1PnreSMyyFuojZpbIYeuUQj8Jar0iD0MqbriNxLjjuu2LDO3ese627eeEjQoSaDAcItmckx9BOnHFeiyc)iinHU9obHMLx0hn)p4PXFi0S(PsJToTjIG1ed7JYjz(jquMGYvnHFeiIicq7WCr2j9bYDcA(TWcIib]] )

    storeDefault( [[SimC Survival: fillers]], 'actionLists', 20171128.180630, [[dieOlaqikv1LuffBcjvJsrCkQQwfLkELQO0TOev7cPmmvLJrvwgvLNbLKPrPsxdjLTPkc(MQuJtvKCoOKQ1PkcnpvrL9rjkhKuXcrsEOQWevfvDrvjBekP8rvruNKuPzQkICtj1ovQLIepf1uvvTvkH9k(RI0Gj6WsTys5XuzYk5YGntQ6ZivJMs50u8Ajz2kCBOA3e(nIHROoUQi1YH8CjMUkxhk2oL03PeX4PePZdLA9uQY8HsSFsoE5p8Zd6BmJlufE34qy2G)qjzmiRgR94jQK6nJbGkHPadOlq2((8E7557PO5HvuZUEEHzhYmFHdRJ7merj)z7L)WVeT2awHQWSdzMVWoczSiwIGgorqNqkWunZb0C2AeDOOKpNsIvH1rZmmh2H1pArLrqFA5qMkiSUILX1hbfwqeq4AYYIgTBCiC4DJdHXAJwuze0vs(qMkimfyaDbY23N3BVVWuGcbdYbL8Nl8dBGRQMyfWbXfTW1K1UXHW5Y2x(d)s0AdyfQcRJMzyoSdxMn3ze0N6iAOoSUILX1hbfwqeq4AYYIgTBCiC4DJdH5zZDgbDL8brd1HPadOlq2((8E79fMcuiyqoOK)CHFydCv1eRaoiUOfUMS2noeox2yv(d)s0AdyfQcRJMzyoSdVqnDIOO3GGP0rGOxqyDflJRpckSGiGW1KLfnA34q4W7ghc)8OMoru0BqGs(KrGOxqykWa6cKTVpV3EFHPafcgKdk5px4h2axvnXkGdIlAHRjRDJdHZLTDZF4xIwBaRqvy2HmZxyeOhbfBT2ausSGfL0(k5zCvgb9W6OzgMd7WJ2bO(GW6kwgxFeuybraHRjllA0UXHWH3noe(j1oa1heMcmGUaz77Z7T3xykqHGb5Gs(Zf(HnWvvtSc4G4Iw4AYA34q4CztT8h(LO1gWkufMDiZ8fwdJE90oFEt9npfS0zsbwt1pArfnmZkj1vs7RKwBKP1ganCs1FpaXbRW6OzgMd7WOE(iOPLdzQGW6kwgxFeuybraHRjllA0UXHWH3noeMspFeKsYhYubHPadOlq2((8E79fMcuiyqoOK)CHFydCv1eRaoiUOfUMS2noeox2pH8h(LO1gWkufMDiZ8fEIsE9aehTcGMbXnTCgbDAGO1gWsjPUsAFLCroAfandIBA5mc60oJRYiORK(dRJMzyoSdJ65JGMwoKPccRRyzC9rqHfebeUMSSOr7ghchE34qyk98rqkjFitfOKt88hMcmGUaz77Z7T3xykqHGb5Gs(Zf(HnWvvtSc4G4Iw4AYA34q4Cz)o)HFjATbScvHzhYmFHrGEeuS1AdqjXcwus7RKNXvze0dRJMzyoSdxoagtpuphwxXY46JGcliciCnzzrJ2noeo8UXHW8bWqj)r9CykWa6cKTVpV3EFHPafcgKdk5px4h2axvnXkGdIlAHRjRDJdHZL9tL)WVeT2awHQWSdzMVWiqpck2ATbOKyblkP9vYZ4Qmc6H1rZmmh2HD94qK5syDflJRpckSGiGW1KLfnA34q4W7ghc)OhhImxctbgqxGS995927lmfOqWGCqj)5c)Wg4QQjwbCqCrlCnzTBCiCUSX65p8lrRnGvOkSoAMH5WomyPZdsXyfMEOEoSUILX1hbfwqeq4AYYIgTBCiC4DJdHFzPZdsXyfuYFuphMcmGUaz77Z7T3xykqHGb5Gs(Zf(HnWvvtSc4G4Iw4AYA34q4Cz79L)WVeT2awHQWSdzMVWwBKP1gan9iJ9ShP86PXyMNHLssDLCroAJ2bO(aAiqpck2ATbOKuxjNOK6jomfAomieioL0YuYjk5eLKAFk5ZQK29tj9RKwUsorjNOKoczSiwIGM(rlQmc6tlhYub0qaEBefL8zus6ULs6xjTJsorj1tCyk0qaDqOK2rjP7wkPFL0Vs6xj9hwhnZWCyhwdZ5SbiSdRRyzC9rqHfebeUMSSOr7ghchE34qyQWCoBac7WuGb0fiBFFEV9(ctbkemihuYFUWpSbUQAIvahex0cxtw7ghcNlBpV8h(LO1gWkufMDiZ8f2AJmT2aOPhzSN9iLxpngZ8mSusQRKlYrB0oa1hqdb6rqXwRnaLK6k5eLupXHPqZHbHaXPKwMsorjNOKu7tjFwL0UFkPFL0YvYjk5eL0riJfXse00pArLrqFA5qMkGgcWBJOOKpJss3Tus)kPDuYjkPEIdtHgcOdcL0okjD3sj9RK(vs)kP)W6OzgMd7WUgzfcRRyzC9rqHfebeUMSSOr7ghchE34q4hnYkeMcmGUaz77Z7T3xykqHGb5Gs(Zf(HnWvvtSc4G4Iw4AYA34q4Cz75l)HFjATbScvH1rZmmh2H1pArLrqFA5qMkiSUILX1hbfwqeq4AYYIgTBCiC4DJdHXAJwuze0vs(qMkqjN45pmfyaDbY23N3BVVWuGcbdYbL8Nl8dBGRQMyfWbXfTW1K1UXHW5Y2dRYF4xIwBaRqvy2HmZx4jkP1gzATbqdNu93dqCWsjPUsQHrVEA4KkrF26X0RDNXvOHa82ikk5ZPK0DlL0okPDvs)kjwWIsorj1tCyk0CyqiqCkPLPKtuYjk5BQPKwUsQN4WuOHa6GqjTJss3Tus)kPFL0FyD0mdZHDyupFe00YHmvqyDflJRpckSGiGW1KLfnA34q4W7ghctPNpcsj5dzQaLCIp)HPadOlq2((8E79fMcuiyqoOK)CHFydCv1eRaoiUOfUMS2noeoxUW8m4m9WyV(mer2(Og1YLa]] )

    storeDefault( [[SimC Survival: mokMaintain]], 'actionLists', 20171128.180630, [[dmdJbaGEGs7ss9AOA2aMpi6Mq42Q0oHYEv2nj7hXOiQggvYVjmyKgUu6GGsNIkCmPAHeflfuTyQQLtQhckEkQLbrRtsYebIMkKAYsX0fUiqQll66uLTcKSzISDQOdt5BGutdOyEGKXjj1JLy0uPoTQojq4zGW1KeNNO0FHKVdu9Cv86d9yqMsMhqmzgJz3Cm)xyiu2t78DAavrOxboc7vH9QXWtG0o5Wq6QdDVJS66oevatVpMl6Vngpg2s8c1zOhwFOhdAL5dKntMXCr)TXy5eQVNKu9vGRSWTbGkSs8LtToV2RoekueQCcvN(EssOa)vncWjuhekKqsOYjuFpjP6RaxzHBdavyL4lN6tyfCcfkcfcc1bH6ymS(pWhYowBTHqJ6e6hphdcvZxSqOhReQCmcrdOmnMDZXJXSBogU1gcnHYH(XZXWtG0o5Wq6QdD31y45r4Pl5zOxmgg3zbhHWzEtvm)Xieny2nhVyXyUnlVb8G1IxOggYkvwSb]] )

    storeDefault( [[SimC Survival: bitePhase]], 'actionLists', 20180317.095948, [[dq0hlaqicv5sQkP2eHknkusNcLyvQkvVsvjAwGQu3sHOAxKIHbshJswgPQNbQQPPqexJuQ2MQsY3uvzCQkLZPqcRtHunpqvY9uiSpcv1bvvSqvv9qf0evvcxeuzJkK0hvirNKqzMkKYnPu7uvgQcrzPOupfzQGyRKs2R4VQWGPQdl1Ij4Xsmzv6YqBgf9zqz0KkNMKxtiZws3wr7gv)wPHJclNONtX0bUUkA7kW3jLY4juX5vOwVcrA(GQy)u5yfiH(cKzFwb5FiIbwuDvnsBGA55Px7ApeBSITbZtpuRFww6)MgRVb9RGFiQivmaHc9Paul3ei5zfiHGJ3cv8M)HOIuXaeQSB9UAJRzUCy7AWdbfa1u01syOX5hHZd)qFeuvfyCO5YHTRbpeuamKy8RQ0GvgIVCmK9E1QLVEIHc96jgYE5W21Go)FfadXgRyBW80d16Nf0qSrZEklOjqci0qDyrK9oaNiheHq2791tmua5PpqcbhVfQ4n)drfPIbiKWjtMAMlh2Ug8G5PCSgjoBf348IVZZQZdRCD(V78S68LDR3vBCnZLdBxdEiOaOMIUwcdno)x68woploplH(iOQkW4qmRnxKId7WaKkryiX4xvPbRmeF5yi79QvlF9edf61tm0OwBUifhMZtaPsegInwX2G5PhQ1plOHyJM9uwqtGeqOH6WIi7DaoroicHS37RNyOaYd(bsi44TqfV5FiQivmaH6cqnapMlh2Ug8G5PCCOpcQQcmo0C5W21Ghckagsm(vvAWkdXxogYEVA1YxpXqHE9edzVCy7AqN)VcGopRwSeInwX2G5PhQ1plOHyJM9uwqtGeqOH6WIi7DaoroicHS37RNyOaYBKeiHGJ3cv8M)HOIuXaeIvNx8C(bTu1cvuZCfbPRihGxNhEGhNNvNx4KjtnZveVb666bOlavXOrIZwXnoV478S68WkxN)7opRo)3C(V25HVZZIZZIZZIZZIZlUoV458cNmzQPnmWc4yzEa0HhydRIAoze6JGQQaJdX8uo(yzEa0HhydRIHgQdlIS3b4e5GieYEVA1YxpXqHE9ednQNYXo)Y05b6qNhUgwfd9rcZesXbOuEYaCOMt8QAaocl4TIdqP8Kb4qXCeLDR3vBCnZLdBxdEiOaOMIUwcdnJa(Wd8WkqvezoK4SvC41iSexHtMm1mxr8gORRhGUaufJgjoBf3aVGQ5hlHyJvSnyE6HA9ZcAi2OzpLf0eibesm(vvAWkdXxogYEVVEIHcipThiHGJ3cv8M)HOIuXae6Uan1UGYgGAKitjA01cv05fxNNvNN5wonAkNsjYboV478S68S68AhQZ)Lop81UZZIZpYDEwDEwD(YU17QnUgM1MlsXHDyasLiuJeNTIBC(V25HvUoplo)3DEwDEMB50OrIWqUZ)DNhw568S48S48S48Se6JGQQaJdv7ckBagsm(vvAWkdXxogYEVA1YxpXqHE9ednADbLnadXgRyBW80d16Nf0qSrZEklOjqci0qDyrK9oaNiheHq2791tmua59vbsi44TqfV5FiQivmaHeozYudqV1HEghO4Wyn49GzT5I0CYi0hbvvbghs2maR8WaKkryiX4xvPbRmeF5yi79QvlF9edf61tme7MbyLopbKkryi2yfBdMNEOw)SGgInA2tzbnbsaHgQdlIS3b4e5GieYEVVEIHciVFbsi44TqfV5FOpcQQcmoKHHcauCyhLvq2HeJFvLgSYq8LJHS3RwT81tmuOxpXqedfaO4WC(HRGSdXgRyBW80d16Nf0qSrZEklOjqci0qDyrK9oaNiheHq2791tmua59TajeC8wOI38p0hbvvbgh6kByl3WujXdysK3xmKy8RQ0GvgIVCmK9E1QLVEIHc96jg6lKnSLByQKOZpkLiVVyi2yfBdMNEOw)SGgInA2tzbnbsaHgQdlIS3b4e5GieYEVVEIHciVrrGecoEluXB(h6JGQQaJdzaiwpaYMriX4xvPbRmeF5yi79QvlF9edf61tmebqS68qKnJqSXk2gmp9qT(zbneB0SNYcAcKacnuhwezVdWjYbriK9EF9edfqEwqdKqWXBHkEZ)qFeuvfyCO(yEkVO8yzEuKR2mHeJFvLgSYq8LJHS3RwT81tmuOxpXqFCE7t5fLo)Y05hkxTzcXgRyBW80d16Nf0qSrZEklOjqci0qDyrK9oaNiheHq2791tmua5zzfiHGJ3cv8M)HOIuXaes8CEGQisXHf6JGQQaJdv6kqUmmHeJFvLgSYq8LJHS3RwT81tmuOxpXqd7kqUmmHyJvSnyE6HA9ZcAi2OzpLf0eibeAOoSiYEhGtKdIqi79(6jgkG8S0hiHGJ3cv8M)H(iOQkW4qO4WOUg1a8aiBgHeJFvLgSYq8LJHS3RwT81tmuOxpXqWjomQRrnaDEiYMri2yfBdMNEOw)SGgInA2tzbnbsaHgQdlIS3b4e5GieYEVVEIHcipl4hiHGJ3cv8M)HE9ednSRvN)tbOwUZpAkdievKkgGqHyJM9uwqtGeqOpcQQcmouPR1JUaul)OQmGqIXVQsdwzi(YXqSXk2gmp9qT(zbnK9EF9edrQ5qNNoLdud66O78mv1kknbeqOxpXqKAo05Pt5a1GUo6oVGcGJmDTbdiba]] )

    storeDefault( [[SimC Survival: biteTrigger]], 'actionLists', 20171128.180630, [[dqZicaGEHqBseSlrYRfI2NqvZKaz2qCtP42s1ovXEP2nQ2VGHjjJJqXGj1WjKdQsCmuSqvklLGwmKworpuLQNISmjSocutvsnzuA6Q6IQK(gbCzW1fPEmjBvO0HvA7IOZlKCAO(SuAEcv(TIVtO0OLOMMqQtkuSkcvUMi09iu1ZecEUO(RezZ4Atx5lkcWAutNTdMiC)EqtPLjXjxebh0O4hQL42wqAsiGaBg8POIragMcXKIXejcu4fbhX9Xd3NIet00f1JhE21(W4Atx5lkcW6BMiLel6njH(I55GoUGMj6GoHGodFj0HNoN6XGSOQu0IubD8bDvqNqqRMbHDelpvF4TZKHsO4hsjH(I55GoUGUvXg0IlOJGPlOye8hLjKvbY9btXWzXQ9hPj(WbtndBSR8SDWKPZ2btcAvGCFWKqab2m4trfJamvMec5jTubzx7309YGkYMjj0b(Butnd7z7Gj)(u4Atx5lkcW6BMiLel6nPkVYwih0Xl(GUW0fumc(JYuF4TZKHsO4hmfdNfR2FKM4dhm1mSXUYZ2btMoBhm1m82zYqqFd)GjHacSzWNIkgbyQmjeYtAPcYU2VP7LbvKntsOd83OMAg2Z2bt(9BIusSO3KFB]] )

    storeDefault( [[SimC Marksmanship: patient sniper]], 'actionLists', 20180424.164121, [[dCKxLaqiivweffLlbvfztssJsbDkfyvuuIxrrvZIIkDlkkLDPOHrGJPQSmjXZOOIPbvvDnOQY2GQs9nvqJdQk5CqvrToOQqZJIW9OiAFqvoifPfQc8qvitKIIuxufvNesvReQkyMuueUjHANsQHsrr1sHuEQstfsARQO8vkksElfLQ7srjTxs)fkdw0HLAXq8yQmzjUmYMPWNjKrRQ60GEnKy2u1TvPDJYVr1WHklNONtPPdCDvz7k03vrgpffoVkuRNIIO5tq7xy9trv3ZznINkkIUMPjJ(5b6b6w3xs3fEpksXTef7Tz2Fio8XiX1aiXarAzqCKux0ip1wsRRi4dFjWC(WxZpZb)mh8VIURtcXb0vxtDaiNzvu16pfvDpN1iEQOhO76KqCaDhgjO9edmTWcDcYkK0ojwJ4PsKvJ0X5(c)eBAHf6eKviPDA88Emj5(BPicdaVuKMiYcH8mmMJppJKnc0dbhpL0THmBKdISzLid8HHr64CFHFInTWcDcYkK0onEEpMKC)TueHbGxkYbrYLrg4ddJSqipdJ54ZZizJa9qWXtjDBiZg5aDnfb6HGJ1DSLWgXt6IEwb6AaxQlJZiDfZlN1Y6(s6o(8mStqwHFs36(s6k0zyiqGZzyy2xaxsrEw7FKzvOuxtLIS6Y6lzYXNNHDcYk8tMlhNjTeaAyUJT)rM0X5(c)eBAHf6eKviPDA88Emj5(BPicdaVK5o2(hHrElzYcH8mmMJppJKnINMs62qM1CDCwbcGCMjbTNyGPfwOtqwHK2jXAepvQ64CFHFInTWcDcYkK0onEEpMKC)TueHbGxYefc5zymhFEgjBepnL0THmRUOrEQTKwxrW3HFc0fnYYFshzvuvGUh9toueZhPlXakIUI5L6(s6QaTUIIQUNZAepv0d0DDsioGUTda5SzdVubZ(ZbZXNNH5AlWQRPiqpeCSUJTe2iEsx0Zkqxd4sDzCgPRyE5Sww3xs3XNNH1WlMRTaRU7p)KyEbAajPvr0TUVKUcDggce4CggM9fWLuKN1(hzwfkJC43aDnvkYQlRVKjhFEgwdVyU2cSMlhNjTeWChB)Jmz7aqoB2WlvWS)CWC85zyU2cS6Ig5P2sADfbFh(jqx0il)jDKvrvb6E0p5qrmFKUedOi6kMxQ7lPRc0AZrrv3ZznINk6b6Uojehq3XwcBepnhFEg2jiRWpfPjISDaiNnB4Lky2Foy6AladaVuKcfg5ylHnINMJppd7eKv4NIeVihBjSr80C85zyn8I5AlWgPzjY2bGC2SHxQGz)5GjzgK7bima8srA(if5krA(ifm)01ueOhcow3XwcBepPl6zfORbCPUmoJ0vmVCwlR7lPRRzyICfD3F(jX8c0assREGU19L0vOZWqGaNZWWSVaUKI8S2)iZQqzKdRmqxtLIS6Y6lzsxZWe5kM7y7FKjhBjSr80C85zyNGSc)KjAhaYzZgEPcM9NdMU2cWaWlju4ylHnINMJppd7eKv4NWBSLWgXtZXNNH1WlMRTaRzPDaiNnB4Lky2FoysMb5EacdaVK5f5kZBBgMxW8tx0ip1wsRRi47Wpb6Igz5pPJSkQkq3J(jhkI5J0LyafrxX8sDFjDvGwJ)kQ6EoRr8urpq31jH4a6cAPicmbWlHb4yfifPjICSLWgXtZXNNHDcYk8trwnY2bGJegXOlKSrAYi)01ueOhcowxx79yTda5mmp0c0f9Sc01aUuxgNr6kMxoRL19L0v36(s6k0zyiqGZzyy2pQ9(in1bGCwKMjGwGzvOuxtLIS6Y6lzsZSfEpksXTef7Tz2Fio8XibTuebkqYmtx0ip1wsRRi47Wpb6Igz5pPJSkQkq3J(jhkI5J0LyafrxX8sDFjDx49Oif3suS3Mz)H4WhJe0sreOajfO14NIQUNZAepv0d0DDsioGUoo3x4NytCqs6Gmry2Foy(Wfz1iBhaosyeJUqYgPjJ8lYQromYcH8mmMJppJKnINMpCrwnsKNHXC85zKSr80us3gYSrAIi)ICGUMIa9qWX6IdsshKjcZ(Zb6IEwb6AaxQlJZiDfZlN1Y6(s6QBDFjDnZHK0bzIIC)5aDrJ8uBjTUIGVd)eOlAKL)KoYQOQaDp6NCOiMpsxIbueDfZl19L0vbAn(wrv3ZznINk6b6UojehqxhN7l8tSjoijDqMim7phmF4ISAKTdahjmIrxizJeVi)ISAKfc5zymhFEgjBepnF4ISAKdJCyKOlsKNHXeiFK9NdMpCrwnsdU7zNUNusmqK4fj(sqKvJCyKfc5zymhFEgjBepnL0THmBKMiYVifkmYcH8mmM)pgGKwSBlrz(Wf5GihePqHromsKNHXeiFK9NdMpCrwnsdU7zNUNusmqK4f5Na8lYQrwiKNHXC85zKSr80us3gYSrAIiX3roiYb6Akc0dbhRloijDqMim7phOl6zfORbCPUmoJ0vmVCwlR7lPRU19L01mhsshKjkY9NdIC43aDrJ8uBjTUIGVd)eOlAKL)KoYQOQaDp6NCOiMpsxIbueDfZl19L0vbA9HkQ6EoRr8urpq31jH4a62oaCKWigDHKns8I8lYQrcApXatGe6qbZ(ZbtI1iEQez1ileYZWyo(8ms2iEAkPBdz2iXlsxBbya4LISAKdJe5zymTedazK3IzHI(btlODOejEMmY2bGJegXOlKSrAwIe)IuOWirEggtlXaqg5TywOOFW0cAhkrA(ihgz7aWrcJy0fs2iXNISsKdIeViRiisHcJCyKwcGHWzp7eajzfbyvW5IeVifez1irxKipdJjOIaSk4WCsia6ApwdVubR03wenF4ISAK4K04SHxQGz)5GihePqHrI8mmMEUdfSMvW88UmF4ISAKTdahjmIrxizJ0erAoroqxtrGEi4yDB4Lky2Foqx0Zkqxd4sDzCgPRyE5Sww3xsxDR7lPRPWlvIC)5aDrJ8uBjTUIGVd)eOlAKL)KoYQOQaDp6NCOiMpsxIbueDfZl19L0vbAn(srv3ZznINk6b6Uojehq32bGJegXOlKSrIxKF6Akc0dbhR7TLOqfm7phOl6zfORbCPUmoJ0vmVCwlR7lPRU19L0vClrHkrU)CGUOrEQTKwxrW3HFc0fnYYFshzvuvGUh9toueZhPlXakIUI5L6(s6QaTgFwrv3ZznINk6b6Uojehq32bGJegXOlKSrIxKFrwnYHrI8mmM3wIcKjcd0sreWoF4IuOWirEggtG8r2Foy(Wf5aDnfb6HGJ19(8aO9Nd0f9Sc01aUuxgNr6kMxoRL19L0v36(s6k(5bqZ2(Zb6Ig5P2sADfbFh(jqx0il)jDKvrvb6E0p5qrmFKUedOi6kMxQ7lPRc06pbkQ6EoRr8urpq31jH4a6o2syJ4P54ZZWA4fZ1wGnste5xKvJeDro2syJ4Pjoo3dzIWm4smCqs6Gmr6Akc0dbhR7jiRG8KwGUONvGUgWL6Y4msxX8YzTSUVKU6w3xsxZuqwb5jTaDrJ8uBjTUIGVd)eOlAKL)KoYQOQaDp6NCOiMpsxIbueDfZl19L0vbA93NIQUNZAepv0d0TUVKUh4BhkrAQuYpPl6zfORbCPUmoJ01ueOhcowxeF7qbRLs(jDrJS8N0rwfvfOlAKNAlP1ve8D4NaDxNeIdO7ylHnINMUMHjYvISAKdJeDro2syJ4Pjoo3dzIWm4smCqs6GmrrkuyKdJSqipdJ54ZZizJ4PPKUnKzJeVif5krwnsdU7zNUNusmqK4fj(c)ICqKdc8bfO1Fvuu19CwJ4PIEGURtcXb0DyKOlYXwcBepnXX5EiteMbxIHdsshKjksHcJSqipdJ54ZZizJ4PPKUnKzJeVif5kroiYQromsqlfrGjaEjmahRaPiXZKr2oaKZMn29jlKeJBG5K8t2PJZ9f(jwKMpYYt2aiNfPqHrcAPicm)P2d(N4CGinrKveePqHrcAPicmbWlHb4yfifPjI8dFh5GiRg5ylHnINMJppdRHxmxBb2inzKc01ueOhcow3g7(KfsIXnWCs(jRUONvGUgWL6Y4msxX8YzTSUVKU6w3xsxtJu8twizKCJipsYpz1fnYtTL06kc(o8tGUOrw(t6iRIQc09OFYHIy(iDjgqr0vmVu3xsxfO1FMJIQUNZAepv0d0DDsioGUTdahjmIrxizJeViRePqHromsqlfrG5p1EW)eNdePjISIGiRgjYZWyI88ElDmnTG2HsKMiYk4xKd01ueOhcowxKwkBrKUONvGUgWL6Y4msxX8YzTSUVKU6w3xs3dAPSfr6Ig5P2sADfbFh(jqx0il)jDKvrvb6E0p5qrmFKUedOi6kMxQ7lPRc06p8xrv3ZznINk6b6Uojehq3cH8mmMJppJKnINMpCrwnsKNHX0ZDOG1ScMN3L5dxKvJCyKOlYXwcBepnXX5EiteMbxIHdsshKjksHcJSqipdJ54ZZizJ4PPKUnKzJeVif5kroqxtrGEi4yDB4Lky2Foqx0Zkqxd4sDzCgPRyE5Sww3xsxDR7lPRPWlvIC)5Gih(nqx0ip1wsRRi47Wpb6Igz5pPJSkQkq3J(jhkI5J0LyafrxX8sDFjDvGw)HFkQ6EoRr8urpq31jH4a62oaCKWigDHKns8I8lYQrwiKNHXC85zKSr80us3gYSrIxKKzqUhGWaWlfz1ihgj6ICSLWgXttCCUhYeHzWLy4GK0bzIIuOWihgPb39St3tkjgis8I8tGGiRgzHqEggZXNNrYgXttjDBiZgjEromsYmi3dqya4LI08rkYvICqKdICGUMIa9qWX62WlvWS)CGUONvGUgWL6Y4msxX8YzTSUVKU6w3xsxtHxQe5(ZbroSYaDrJ8uBjTUIGVd)eOlAKL)KoYQOQaDp6NCOiMpsxIbueDfZl19L0vbA9h(wrv3ZznINk6b6Uojehq32bGJegXOlKSrIxKFrwnYXwcBepnDndtKRez1in4UND6EsjXarA(iDTfGjjrelsZhz7aqoB2WlvWS)CW01waMKerSinrKgC3ZoVTzez1ihgj6ICSLWgXttCCUhYeHzWLy4GK0bzIIuOWileYZWyo(8ms2iEAkPBdz2iXlsrUsKd01ueOhcow37ZdG2Foqx0Zkqxd4sDzCgPRyE5Sww3xsxDR7lPR4NhanB7phe5WVb6Ig5P2sADfbFh(jqx0il)jDKvrvb6E0p5qrmFKUedOi6kMxQ7lPRc06Vdvu19CwJ4PIEGURtcXb0TDa4iHrm6cjBKMmYViRg5WirxKwcGHWzp7eajzfbyvW5IeVifePqHrIUiBhaYzZgEPcM9NdMqgMHhk6hePqHrI8mmMGkcWQGdZjHaOR9yn8sfSsFBr0us3gYSrIxKTda5SzdVubZ(ZbtxBbya4LI08rkYvICqKvJCyKJTe2iEAo(8mSgEXCTfyJeVifePqHr2oaKZMNGScYtAbtidZWdf9dISAKOlslbWq4SNDcGKSYhg(JZfjErkiYbrwnYXwcBepnDndtKRez1in4UND6EsjXarA(iDTfGjjrelsZhz7aqoB2WlvWS)CW01waMKerSinrKgC3ZoVTzez1ihgj6ICSLWgXttCCUhYeHzWLy4GK0bzIIuOWileYZWyo(8ms2iEAkPBdz2iXlsrUsKd01ueOhcow3w6AgHz)5aDrpRaDnGl1LXzKUI5LZAzDFjD1TUVKUMkDnJIC)5aDrJ8uBjTUIGVd)eOlAKL)KoYQOQaDp6NCOiMpsxIbueDfZl19L0vbA9h(srv3ZznINk6b6Uojehqxq7jgyAHf6eKviPDsSgXtLiRg5WileYZWyo(8ms2iEAkPBdz2iXlsxBbya4LIuOWihgjYZWy65ouWAwbZZ7YSWpXISAKTda5S5jiRG8KwWeYWm8qr)Gihe5GiRg5WihBjSr80C85zyNGSc)uKMTihgjzgK7bima8srAwICSLWgXtZXNNH1WlMRTaBKdI0er(fPqHrAWDp7SqgqheePjmzKU2cWKKiIfPqHrI8mmMa5JS)CW8HlYbrwnYHr2oaCKWigDHKnstg5xKcfgPb39St3tkjgis8I8tGGihORPiqpeCSUn8sfm7phOl6zfORbCPUmoJ0vmVCwlR7lPRU19L01u4LkrU)CqKdnNb6Ig5P2sADfbFh(jqx0il)jDKvrvb6E0p5qrmFKUedOi6kMxQ7lPRc06p8zfvDpN1iEQOhO76KqCaDrxKG2tmW0cl0jiRqs7KynINkrwnYHrwiKNHXC85zKSr80us3gYSrIxKU2cWaWlfPqHromsKNHX0ZDOG1ScMN3LzHFIfz1iBhaYzZtqwb5jTGjKHz4HI(brwnYHrIUiTeadHZE2jasYkFy4poxK4fPGifkmYcH8mmM)pgGKwSBlrzw4NyroiYbroiYQroms0f5ylHnINM44CpKjcZGlXWbjPdYefPqHrwiKNHXC85zKSr80us3gYSrIxKKzqUhGWaWlfP5JuKRe5aDnfb6HGJ1THxQGz)5aDrpRaDnGl1LXzKUI5LZAzDFjD1TUVKUMcVujY9NdICi(pqx0ip1wsRRi47Wpb6Igz5pPJSkQkq3J(jhkI5J0LyafrxX8sDFjDvGwxrGIQUNZAepv0d0DDsioGUOlsq7jgyAHf6eKviPDsSgXtLiRg5WihgjYZWy65ouWAwbZZ7Y8HlYQrwiKNHXC85zKSr80SWpXICqKcfg5WihBjSr80C85zyNGSc)uKMiY2bGC2SHxQGz)5GPRTama8srwns0f5ylHnINM44CpKjcZGlXWbjPdYefz1ihgj6ISDaiNnpbzfKN0cMqgMHhk6hePqHrAjagcN9StaKKv(WWFCUiXlsbroiYQromYHrAWDp709KsIbIeViX34xKcfgjYZWycKpY(ZbZhUifkmYHr(fj(uKna0ouW(BlGICqK4f53SY3HrkuyKdJ8ls8PiBaODOG93waf5GiXlYV53HFrwnslbWq4SNDcGKSIam8hNls8IuqKdIuOWiTeadHZE2jasYkFy4poxK4fPGiRgj6I0sameo7zNaijRiaRcoxK4fPGihe5GihORPiqpeCSU3wIcvWS)CGUONvGUgWL6Y4msxX8YzTSUVKU6w3xsxXTefQe5(Zbro8BGUOrEQTKwxrW3HFc0fnYYFshzvuvGUh9toueZhPlXakIUI5L6(s6QaTUYNIQUNZAepv0d0DDsioGUG2tmW0cl0jiRqs7KynINkrwnYHro2syJ4P54ZZWA4fZ1wGnste5xKcfgjYZWycKpY(ZbZhUifkmYXwcBepnhFEg2jiRWpfPjISDaiNnB4Lky2Foy6AladaVuKd01ueOhcow3BlrHky2Foqx0Zkqxd4sDzCgPRyE5Sww3xsxDR7lPR4wIcvIC)5GihwzGUOrEQTKwxrW3HFc0fnYYFshzvuvGUh9toueZhPlXakIUI5L6(s6QaTUsffvDpN1iEQOhO76KqCaDn4UND6EsjXarA(iDTfGjjrels8I0G7E25TnJiRgjYZWy65ouWAwbZZ7YSWpXISAKOlsKNHX0smaKrElMfk6hmF401ueOhcow3gEPcM9Nd0f9Sc01aUuxgNr6kMxoRL19L0v36(s6Ak8sLi3FoiYH43aDrJ8uBjTUIGVd)eOlAKL)KoYQOQaDp6NCOiMpsxIbueDfZl19L0vbADfZrrv3ZznINk6b6Uojehq3HrIUileYZWy()yasAXUTeL5dxKcfg5WirxKipdJ5TLOazIWaTuebSZhUiRgj6Ie5zymbYhz)5G5dxKdICqKvJCyKdJe5zymVTefitegOLIiGD(Wfz1ihBjSr80C85zyn8I5AlWgPjI8lYbrkuyKipdJjq(i7phmF4IuOWiD)TuezXmKTda5S2hjEr(nXNJCGUMIa9qWX6AHf6eKviPvx0Zkqxd4sDzCgPRyE5Sww3xsxDR7lP7cl0jiRqsRUOrEQTKwxrW3HFc0fnYYFshzvuvGUh9toueZhPlXakIUI5L6(s6QaTUc(ROQ75SgXtf9aDxNeIdOB7aWrcJy0fs2inzKFrwnYHrIUihBjSr80ehN7HmrygCjgoijDqMOifkmYcH8mmMJppJKnINMs62qMns8IuKRe5aDnfb6HGJ1TLUMry2Foqx0Zkqxd4sDzCgPRyE5Sww3xsxDR7lPRPsxZOi3FoiYHFd0fnYtTL06kc(o8tGUOrw(t6iRIQc09OFYHIy(iDjgqr0vmVu3xsxfO1vWpfvDpN1iEQOhO76KqCaDBhaosyeJUqYgjEr(fz1ihgj6ICSLWgXttCCUhYeHzWLy4GK0bzIIuOWileYZWyo(8ms2iEAkPBdz2iXlsrUsKd01ueOhcow37ZdG2Foqx0Zkqxd4sDzCgPRyE5Sww3xsxDR7lPR4NhanB7phe5Wkd0fnYtTL06kc(o8tGUOrw(t6iRIQc09OFYHIy(iDjgqr0vmVu3xsxfOaDxCKd2EOzYga5mTUc(H)kqva]] )

    storeDefault( [[SimC Marksmanship: default]], 'actionLists', 20180317.214619, [[daK9iaqiQQIfHQWMqvAuceNsGQzbcPDrvgMI6yG0YarpJQQ00OQQCnHOTrfP8nQQmoqiwhiyEuvvDpHW(eOCqryHOQ8qQktKks6IcjNui1mbH6MIYoj0sfrpLYufkxLks1wPI6TurCxufTxO)kQgSKoSslMk9ysMmOUmYMj4ZuHrlsNwvVwrmBsDBf2Tu)gy4OYXPIelNONJY0v56cA7c47cvNhvvRxG08vK2VeJqXyOfvVUAcgDrZ4i1V6pO79GgfHms)dnNkjSH6d5dTKKMwgHIqodfIm7Vq9ZdAKrcjuicAMs(ChAOLqDpOzymuekgdTO61vtWiFOzk5ZDOroLWNJJG9yexAyqz5msjPRu5TuVv6GopyYnuqWtTS7BhEHCLkVLQca0WG4TNBOGGhJ4sddklNrkjDEHCLkVLQ)uQUHccEmIlnmOSCgPK05fYHwc3x)h)OPaH9rYCwk4ql6g(v7bKO1GMqlda78kf3bHgAI7GqZhiSpswQwk4qljPPLrOiKZq9d6mAjjgiuQiggdp08LsQjzGa0G6dDrldalUdcn8qriXyOfvVUAcg5dTeUV(p(rlKr5)rdgAr3WVApGeTg0eAzayNxP4oi0qtCheAtvccZZkLGGtC6mQuJ(ObJNtLOLK00YiueYzO(bDgTKedekvedJHhA(sj1KmqaAq9HUOLbGf3bHgEOO)IXqlQED1emYhAMs(ChAR6(auo104jwPgSsfYsL3s1nuqWlaqRj(9GbXB0s4(6)4hTaaTM4hTOB4xThqIwdAcTmaSZRuCheAOLKyGqPIyym8qtCheAod0AIF0siDWq7aoCOPianAjjnTmcfHCgQFqNrZsbXZaWVWtsgYhA(sj1KmqaAq9HUOLbGf3bHgEOO)HXqlQED1emYhAMs(ChA3QP(84EsQ(2rolfCEuVUAcUu5TuvaGggeV94EsQ(2rolfCEsASFZkv)VuJSu5TuHj3qbbVaH6MKRRM8K0y)MvQbRuvaGggeV94EsQ(2rolfCEsASFZkvEl1GuQUHccENmKyPGZdgeVl1Ptl1vDFakNAA8eRuJOuHwQbhTeUV(p(rlWk)1vtOfDd)Q9as0AqtOLbGDELI7GqJda0F7ixaiZ5EsQ(2bAjjgiuQiggdp0e3bH2uLGW8Ssji4e7asQuDE1HepNkrlH0bdTEhueCaG(Bh5cazo3ts13oGObwDifXTAQppUNKQVDKZsbNh1RRMG5vbaAyq82J7jP6Bh5SuW5jPX(nZ)JKxnioXU8aH6op(FPF7fzWM5vdItSlpqOUZJ)x63ErgmfaOHbXBpUNKQVDKZsbNNKg73mEdIBOGG3jdjwk48GbX7Ptx19bOCQPXtSiGgC0ssAAzekc5mu)GoJMLcINbGFHNKmKp08LsQjzGa0G6dDrldalUdcn8qXiXyOfvVUAcg5dTeUV(p(rtTAD(QUh056NDOfDd)Q9as0AqtOLbGDELI7GqdnXDqOnvjimpRuccoX3Q1LAc19GUuH4ND8CQeTeshm06DqrWd7h(k1SvoHn2ML(CqOuvaGggeVz8aTKKMwgHIqod1pOZOLKyGqPIyym8qZxkPMKbcqdQp0fTmaS4oi0SF4RuZw5e2yBw6ZbHsvbaAyq8MHhk60WyOfvVUAcg5dntjFUdTB1uFEC79uF5S(5iPh1RRMGrlH7R)JF0uRwNVQ7bDU(zhAr3WVApGeTg0eAzayNxP4oi0qtCheAtvccZZkLGGt8TADPMqDpOlvi(zhpNkl1Gan4OLq6GHwVdkcEy)WxPMTYjSX2S0NdcLk3Ep1xPY6NJK8aTKKMwgHIqod1pOZOLKyGqPIyym8qZxkPMKbcqdQp0fTmaS4oi0SF4RuZw5e2yBw6ZbHsLBVN6Ruz9Zrs8qr)WyOfvVUAcg5dntjFUdn)PuVvt95XT3t9LZ6NJKEuVUAcgTeUV(p(rtTAD(QUh056NDOfDd)Q9as0AqtOLbGDELI7GqdnXDqOnvjimpRuccoX3Q1LAc19GUuH4ND8CQSudcKbhTeshm06DqrWd7h(k1SvoHn2ML(CqOuBqxQC79uFLkRFosYd0ssAAzekc5mu)GoJwsIbcLkIHXWdnFPKAsgianO(qx0YaWI7GqZ(HVsnBLtyJTzPphek1g0Lk3Ep1xPY6NJK4HhAI7GqZ(HVsnBLtyJTzPphekvysyd1hEic]] )

    storeDefault( [[SimC Marksmanship: precombat]], 'actionLists', 20180317.214619, [[dqdtcaGEQs1Uqr51cvZwH5tvPBIk3ffvFtiTtQSxYUHA)cyyOQFRQHsvXGfOHJchuqDmiwOGSuP0IvQLROhIsEkyzkPNlQjsvstvkMSunDvUOq5YixxjonfBffzZOuBhs5XI8vQcnnQc(ovjoSKXrvLrle3MsNes8mQQ6AqsNhs1FPkL3svuRJQile1iigU2dQRTaGbLm1W496mpwUvu9GaVsSRLXPqcAPbvzsUvEe)49hjkZqqf1ve)eaPPHXjqq40zECwnYHOgbXW1EqDfsq4Tzyo0fKxS2h7ng0jafC3KQ7NcWpMeW9DMQPRSKabUYscyvJrGG(qxGGicAPbvzsUvEKOi8cAP8Vmtuwn6eWkcLIZ9OrwcFAlG77UYsc0j3QAeedx7b1vibH3MH5qxaJ)mpwak4Ujv3pfGFmjG77mvtxzjbcCLLe4BInBE(uInBp7ZFMhZCFNcAPbvzsUvEKOi8cAP8Vmtuwn6eWkcLIZ9OrwcFAlG77UYsc0jN)QrqmCThuxHeeEBgMdDbEXG77Lz(eGcUBs19tb4htc4(ot10vwsGaxzjbE0G77Lz(e0sdQYKCR8irr4f0s5FzMOSA0jGvekfN7rJSe(0wa33DLLeOtNaxzjbGXYkqqUAgpBlCoIHHNceKXKsVDxNoja]] )

    storeDefault( [[SimC Marksmanship: cooldowns]], 'actionLists', 20180317.214619, [[d8tnfaqAkTEQiztur4TkvW2OIu7tPkESiVwvQzlQ5dk3eG7Quj(gsX9ufANGSxPDtQ9tYOuf1WeQXPuvDyedvPIAWumCGCqa5uQcoMs5zurTqvjlLkSyv1Yj8qKQEkQLjeRtPs1evQKMkqnzbtxXfrQ8kQi6YqxxjBuPISvQK2mrTDQu9xa1HuQuMMsv67uPmpLQYNrknAq1TrYjPs8CQ6AQICEH0kvQq)wLDrK7wbxMon5NXq)LzqyYsYwNIm2txOipT3Y7kktw5PVk7aZiXJfks82(JDEJgPTNEkY2(lZjHf0uUmqPXEAFbxOTcUmDAYpJH(QmNewqtz5lT8sbu2MSJYSNhvgNJvgNqzEwz2nLzizupsEBaDZQdOWlHAYpJbLbgmLjDxoCUPL82a6MvhqHxkbNiOf9kZ(uMikZdLb6BZ2jAzIir0iWZjeOEk7IoytK5eL1Ngld4cUseqekSCzicfwgirIOrLb8jeOEk7aZiXJfks8gnBXLDG(BjsOVG7uME4y6nGZDKc1t)LbCbicfwUtHIuWLPtt(zm0xL5KWcAk)xYYsJyHE43iTavgOVnBNOL)OWJI3wnTLDrhSjYCIY6tJLbCbxjcicfwUmeHcl)cfEu82QPTSdmJepwOiXB0Sfx2b6VLiH(cUtz6HJP3ao3rkup9xgWfGiuy5ofY5cUmDAYpJH(QmNewqt5)swwAel0d)gPfOYa9Tz7eT8pFxay5LiAzx0bBImNOS(0yzaxWvIaIqHLldrOWYVY3fuMDAjIw2bMrIhluK4nA2Il7a93sKqFb3Pm9WX0BaN7ifQN(ld4cqekSCNcT3cUmDAYpJH(QmNewqt5NvM)swwAel0d)gPfiLXjuM)sww6NVlKx(rAbszEqzGbtz(lzzP)kN9yuusGK0OmpQmohR2XYa9Tz7eTmOBSNUSl6GnrMtuwFASmGl4krarOWYLHiuyzyjz544uswEh25BSNExGjk7aZiXJfks8gnBXLDG(BjsOVG7uME4y6nGZDKc1t)LbCbicfwUtHEQGltNM8ZyOVkZjHf0uESuOY8OYeRmWGPm)LSS0pFxiV8J0cKYadMY8SYmebT4inwke45aoyrLzpkZZkt6UC4CtlnIf6HFJuyjiJ90at7c9ELXjvMWsqg7PvMhuMhugyWuM)sww6VYzpgfLeijnkZJkJZXkdmykZqe0IJ0yPqGNd4GfvM9PmBoDzG(2SDIwEel0d)MYUOd2ezorz9PXYaUGRebeHclxgIqHLblwOh(nLDGzK4XcfjEJMT4Yoq)Tej0xWDktpCm9gW5osH6P)YaUaeHcl3PtzicfwMTu0RmaiI3EkI2d3cA3vM0D5W5M23Pf]] )

    storeDefault( [[SimC Marksmanship: non patient sniper]], 'actionLists', 20180318.135342, [[dieJuaqiif2KsvJIQOtrvLxPuKmlQQQ4wkfP2frggKCmfzzcQNPuuMgvvPRrvvSnLIQVrjmoif5CqkQ1rvvLMhvvL7bPK9Pu4GkLwiKQhsj1evkICrkrNKQs3urTtumuLIGLsv6PKMkLYwPQ4RuvvvVvPi0DvkIAVQ(RadMWHLAXq8yrnzrUmyZc5ZcYOfQtJ41evZwHBRKDd1VrA4eLLtXZPY0LCDuA7uQ(oLKXdPuNNQW6PQQkZxPY(r1F62UAjUrgq6ixz6fCvjlR5I52i3TASlMiZ)LlWumxiRlcGlUWHjYaZvvgKj9G4)1fHIpty)XFV6fgq7GZeg1eAc1MnzHu4j)DZNqZx1SHiRUEDBUiuS72oZ0TD1sCJmG0r)QMnez11QhaUKCaUiyyib4gzajUypx4jxGWgfjTAJCcouq1Mqq5KyLXf72XfiSrrsLHfCX0sIvgx4hxSNl6CrOyjhGlcggsR2i3fGb0UccLtx3IqgKYJR2BdPrgWvFXjsUlQ5kMIHRZ0KpTHPxWvRAsrWHcIOMahGlcggx1yQvZ0ejIag3r)ktVGR7YrrOqLZrrBIArnax4tpyHn5DMRBnHCxX9cqlRAsrWHcIOMahGlcgg(p27blGwvpaCj5aCrWWqcWnYas79eHnksA1g5eCOGQnHGYjXkB3oe2OiPYWcUyAjXkZV9DUiuSKdWfbddPvBK7cWaAxbHYPREHb0o4mHrnzXeQREbhL1Kb3T96Q1Xqw(m1oSaCDKRZ0etVGRVot4B7QL4gzaPJ(1TiKbP84kG2YguhXoe4IP1vFXjsUlQ5kMIHRZ0KpTHPxW1Rm9cUAjAlBqDe7axOX06QxyaTdotyutwmH6QxWrznzWDBVUADmKLptTdlaxh56mnX0l46RZSz32vlXnYash9RA2qKvxtacBuKKD2bgmnYaKmWQjyhxSbxGIl2Zfr0mRtkZAmaU4In4IjuOUUfHmiLhxLratMGdf4IP1vFXjsUlQ5kMIHRZ0KpTHPxW1Rm9cUUjqatMGdXfAmTU6fgq7GZeg1KftOU6fCuwtgC32RRwhdz5Zu7WcW1rUottm9cU(6m(7TD1sCJmG0r)QMnez11oxe7qaGHfbCCXgCXexSNlsacBuKKD2bgmnYaKmWQjyhxSbxKBxfuKfWf75cp5IQhaUKkdjlpWftlja3idiXf72XfiSrrsdAwEqJtbdANKyLXf(Xf75ce2OijhGlcggUahjuCj5QolNlqlUimQRBrids5X1MSGuGlMwx9fNi5UOMRykgUott(0gMEbxVY0l46wYcsCHgtRREHb0o4mHrnzXeQREbhL1Kb3T96Q1Xqw(m1oSaCDKRZ0etVGRVoJ)CBxTe3idiD0VQzdrwDTZfXoeayyrahxSbxmXf75IeGWgfjzNDGbtJmajdSAc2XfBWf52vbfzbCXEUO6bGlPYqYYdCX0scWnYasCXEUWbvacfZ6KkcycJkiSSmxSbxGIl2ZfObxGWgfjvHrfewwq2qksUhbnzbPGuV6qGeRmUypx05IqXsnzbPaxmTKi4GObjuCDDlczqkpU2KfKcCX06QV4ej3f1CftXW1zAYN2W0l46vMEbx3swqIl0yAXfEo53vVWaAhCMWOMSyc1vVGJYAYG72ED16yilFMAhwaUoY1zAIPxW1xNzZVTRwIBKbKo6x1SHiRU25IyhcamSiGJl2GlMUUfHmiLhxxTroKcCX06QV4ej3f1CftXW1zAYN2W0l46vMEbxNBJCiXfAmTU6fgq7GZeg1KftOU6fCuwtgC32RRwhdz5Zu7WcW1rUottm9cU(6mwCBxTe3idiD0VQzdrwDTZfXoeayyrahxSbxmXf75cp5ce2OiPvBKtWHcQ2eckNeRmUy3oUaHnksQmSGlMwsSY4c)UUfHmiLhxxSJI4IP1vFXjsUlQ5kMIHRZ0KpTHPxW1Rm9cUoZokYMwJP1vVWaAhCMWOMSyc1vVGJYAYG72ED16yilFMAhwaUoY1zAIPxW1xNbnDBxTe3idiD0VQzdrwDfn4IeGWgfjfZIlW4cwTrUeRSRBrids5XvhGlcggx9fNi5UOMRykgUott(0gMEbxVY0l4Qc4IGHXvVWaAhCMWOMSyc1vVGJYAYG72ED16yilFMAhwaUoY1zAIPxW1xNbnFBxTe3idiD0VQzdrwDT6bGljhjbwrWjW4KaCJmGexSBhx05IyhcamSiGJl8pUyZVY0l4k6JolNl2AmuRUUfHmiLhxrgDwEqBmuRU6lorYDrnxXumC1lmG2bNjmQjlMqD1l4OSMm4UTxVoZeQB7QL4gzaPJ(vnBiYQRvBcbLurwqqrdseGl2aT4IoxekwQdwSMeycOrbzd1kNuMshjQvyUytXfjwtxekMl2TJlQ2eckPyOhvSKSCXf(hxeg11TiKbP84AhSynjWeqJcYgQvUR(ItKCxuZvmfdxNPjFAdtVGRxz6fCDlxmZAsGHlOrCH1gQvUREHb0o4mHrnzXeQREbhL1Kb3T96Q1Xqw(m1oSaCDKRZ0etVGRVoZ00TD1sCJmG0r)6weYGuEC1kcoHWAC1vFXjsUlQ5kMIHRZ0KpTHPxW1Rm9cU6)tWjewJRU6fgq7GZeg1KftOU6fCuwtgC32RRwhdz5Zu7WcW1rUottm9cU(6mtHVTRwIBKbKo6x1SHiRU25IyhcamSiGJl2GlcZf72XfEYfvBcbLum0JkwswU4c)JlcJIl2ZfiSrrsiSJHd8aKCvNLZf(hxe2F4c)UUfHmiLhxrAJPdbx9fNi5UOMRykgUott(0gMEbxVY0l4k6TX0HGREHb0o4mHrnzXeQREbhL1Kb3T96Q1Xqw(m1oSaCDKRZ0etVGRVoZ0MDBxTe3idiD0VQzdrwDfHnksA1g5eCOGQnHGYjXkJl2TJlqyJIKkdl4IPLeRSRBrids5X1vBKdPaxmTU6lorYDrnxXumCDMM8Pnm9cUELPxW152ihsCHgtlUWZj)U6fgq7GZeg1KftOU6fCuwtgC32RRwhdz5Zu7WcW1rUottm9cU(6mt(7TD1sCJmG0r)QMnez1v0GlS3gsJmajRAsrWHcIOMahGlcggCXEUWtUibiSrrsXS4cmUGvBKlLOwH5ID74cp5ce2OiPYWcUyAjLOwH5I9CbcBuK0QnYj4qbvBcbLtkrTcZf(Xf(Xf75cp5cp5ce2OiPvBKtWHcQ2eckNeRmUy3oUaHnksQmSGlMwsSY4c)4ID74ICCBcbUGitNlcf3dUydUyscnXf(Xf75cp5IiAM1jLGisMuCXgCrUDvGbcbyUWVRBrids5XvhjbwrWjW4U6lorYDrnxXumCDMM8Pnm9cUELPxWvLKaRi4eyCx9cdODWzcJAYIjux9cokRjdUB71vRJHS8zQDyb46ixNPjMEbxFDMj)52UAjUrgq6OFvZgIS6A1daxsoscSIGtGXjb4gzajUypxKae2Oij7SdmyAKbizGvtWoUydUi3UkOil46weYGuECTjlif4IP1vFXjsUlQ5kMIHRZ0KpTHPxW1Rm9cUULSGexOX0Il8mSFx9cdODWzcJAYIjux9cokRjdUB71vRJHS8zQDyb46ixNPjMEbxFDMPn)2UAjUrgq6OFvZgIS6kAWfvpaCj5ijWkcobgNeGBKbK4I9CrcqyJIKSZoWGPrgGKbwnb74In4IC7QGISaUypx4jxGgCH92qAKbijJsheCOGiQjqgbmzcoexSBhx4jxGWgfjnOz5bnofmODsIvgxSNlsacBuKKD2bgmnYaKmWQjyhxSbxekN4c)4c)4I9CHNCrNlIDiaWWIaoUW)4c)Hl2TJlQEa4sQmKS8axmTKaCJmGexSBhxGWgfj5aCrWWWf4iHIljx1z5CbAXfHrXf(DDlczqkpU2KfKcCX06QV4ej3f1CftXW1zAYN2W0l46vMEbx3swqIl0yAXfEUz(D1lmG2bNjmQjlMqD1l4OSMm4UTxxTogYYNP2HfGRJCDMMy6fC91zMS42UAjUrgq6OFDlczqkpUUAJCif4IP1vFXjsUlQ5kMIHRZ0KpTHPxW1Rm9cUo3g5qIl0yAXfEg2VREHb0o4mHrnzXeQREbhL1Kb3T96Q1Xqw(m1oSaCDKRZ0etVGRVoZeA62UAjUrgq6OFvZgIS6AenZ6KYSgdGlUytXf52vbgieG5In4IiAM1jTA0Ml2ZfObxGWgfj5aCrWWWf4iHIljwzx3IqgKYJRnzbPaxmTU6lorYDrnxXumCDMM8Pnm9cUELPxW1TKfK4cnMwCHN(RFx9cdODWzcJAYIjux9cokRjdUB71vRJHS8zQDyb46ixNPjMEbxFDMj08TD1sCJmG0r)QMnez11oxe7qaGHfbCCXgCXexSNlqdUWEBinYaKSQjfbhkiIAcCaUiyyCDlczqkpUUyhfXftRR(ItKCxuZvmfdxNPjFAdtVGRxz6fCDMDuKnTgtlUWZj)U6fgq7GZeg1KftOU6fCuwtgC32RRwhdz5Zu7WcW1rUottm9cU(6mHrDBxTe3idiD0VQzdrwDTZfXoeayyrahxGwCXexSNlqdUWEBinYaKSQjfbhkiIAcCaUiyyCDlczqkpU2MCJHaxmTU6lorYDrnxXumCDMM8Pnm9cUELPxW1TMCJbUqJP1vVWaAhCMWOMSyc1vVGJYAYG72ED16yilFMAhwaUoY1zAIPxW1xVUUjbrn7Oo6V(b]] )

    storeDefault( [[SimC Marksmanship: targetdie]], 'actionLists', 20180317.214619, [[dudHeaGEjG2KsjTlOOxtf2NeOzdPBIkFtrANcTxYUrz)qLHPK(nIHIQQmyOQHRioiv0XOsluszPkvlgILtPhQu8uWYqvEUGjkbyQkXKPy6sDrjvNgPlR66kQhRWwHcBgvLTlroSOVIQQAAsq(UsPgNsj(Re1OLKNjb1jHs9zjuxtc58qj3MQ2gQQyDOQslxTiOolrqVricGjFqtuAbMnLWuKxrfsqbC(Yz0w1eSF0NHRiVv3TSwy3Py6wur8C3IayyPtAbcCoAkHf0IIUArqDwIGEJQjagw6KwG5iZ8XhMLMrz3MiOhZ5jcCIqrPnwcMqVDqzfxourAbyZm0r2eRagHDbCedgPnM(lqqm9xa)rVDqzfJdpurAb7h9z4kYB1DQ7QG9hiZ2XdArTGnvF4GJu6(ZAHiGJyIP)cuRipTiOolrqVr1e4eHIsBSeSnLzqMTHwa2mdDKnXkGryxahXGrAJP)ceet)fW)uMbz2gAb7h9z4kYB1DQ7QG9hiZ2XdArTGnvF4GJu6(ZAHiGJyIP)cuRyH1IG6Seb9gvtamS0jTaZrM5JpmlnJYUnrqpM27tklGdFbXHFKHUCt9hh(TIdFN2IFJzt9VCtkBOhh(cId)idD5M6VaNiuuAJLGK6VPCOI0cWMzOJSjwbmc7c4igmsBm9xGGy6VaNu)n4WdvKwW(rFgUI8wDN6Uky)bYSD8Gwulyt1ho4iLU)Swic4iMy6Va1kwiTiOolrqVr1e4eHIsBSe4tRJBkhQiTaSzg6iBIvaJWUaoIbJ0gt)fiiM(lGlToUbhEOI0c2p6ZWvK3Q7u3vb7pqMTJh0IAbBQ(WbhP09N1crahXet)fOwXI0IG6Seb9gvtGtekkTXsqAhj7LdvKwa2mdDKnXkGryxahXGrAJP)ceet)f40os2XHhQiTG9J(mCf5T6o1DvW(dKz74bTOwWMQpCWrkD)zTqeWrmX0FbQvKF0IG6Seb9gvtGtekkTXsqGA(2uM52GaSzg6iBIvaJWUaoIbJ0gt)fiiM(laOMVnLzUniy)OpdxrERUtDxfS)az2oEqlQfSP6dhCKs3FwlebCetm9xGA1cIP)caQFdo8CP1rWNSqfDc)IdFN2IFBOxTea]] )

    storeDefault( [[SimC Beast Mastery: default]], 'actionLists', 20180421.220053, [[dC04zaqiivztkr(KsqYOOQ4uuvAvOkLBbPsSlszyOWXKulJk8mQs10OkfxJQuABOkv9nuvnoLO4Ckb16ucI5HQK7PeyFkHoiQIfcj9qiLjQeLUiPQ2iKkPtsQYlHurntuLkDtL0orPHcPISuQONszQKkxvji1wPk5RqQqVfsfCxuLk2RQ)IkdgXHLAXq8yHMSixgSzj5ZOQmALYPj8ALQMTOUTe7MOFd1WrrhhsvTCsEUGPR46uPTdj(ovvJhsL68kvwVsunFQI9J0V(6UPVSrYq6i3wwOQDZZr9MfvcMZTBoHm0b4SoyuVmm8MAVR5WH3xyV79Bgtik6Sy59iWYZ6WB9(nEIJaldx3zRVUB6lBKmKoQ3SOsWCUnDgKJwyWfMAGSrYq6gpiISy2Dt5k564iWsUSim30tMeXEWQBsSeUX2f4Mn4ctkzzHQ2npucpOt8U3wXj2Ua3mrbnkb1vkXgCH5cHssqv7MNBoHm0b4SoyuZFnJBoHa2vfHW195MTH9VItIkbOch1B2OeXbTniU)O(5SoUUB6lBKmKoQ3SOsWCUDJherwm7UfXUYbuCHn8Ctpzse7bRUjXs42ko5vRy7cC7gBxGBOHDLdOOeBdp3CczOdWzDWOM)Ag3CcbSRkcHR7Zn02G4(vmkqbKZrUTItSDbU95SE)6UPVSrYq6OEJherwm7U5gaoXaLWn9KjrShS6MelHBR4KxTITlWTBSDbU5jwvXGrmwvHoSqhakrVbkbEhpQBoHm0b4SoyuZFnJBoHa2vfHW195gABqC)kgfOaY5i3wXj2Ua3(CwV56UPVSrYq6OEZIkbZ5wfo6g0sqLikgkzXfqjENXnEqezXS7wRITe4gSsbY5MEYKi2dwDtILWTvCYRwX2f42n2Ua34rfBjqj6WkfiNBoHm0b4SoyuZFnJBoHa2vfHW195gABqC)kgfOaY5i3wXj2Ua3(CwV96UPVSrYq6OEZIkbZ5gIBvLgcegrN58R6zttbLwiduYIuc)uYsuIpuc6rjby4qWs3G2iaLdgCoygPKfPeguIhpucIBvLgcegrN58R6zttbLwiducVOK6AkX3B8GiYIz3neqfa1EHKVB6jtIypy1njwc3wXjVAfBxGB3y7cCdvqfa1EHKVBoHm0b4SoyuZFnJBoHa2vfHW195gABqC)kgfOaY5i3wXj2Ua3(CwE)1DtFzJKH0r9MfvcMZne3QkneimIoZ5x1ZMMckTqgOKfPe(VXdIilMD3qYyCIRYvT7MEYKi2dwDtILWTvCYRwX2f42n2Ua3qnJXjkbD1vT7MtidDaoRdg18xZ4MtiGDvriCDFUH2ge3VIrbkGCoYTvCITlWTpNL)R7M(YgjdPJ6nEqezXS7gk4Cg2Dtpzse7bRUjXs42ko5vRy7cC7gBxGBEHZzy3nEu8fUny(4ldlalV5eYqhGZ6Grn)1mU5ecyxvecx3NBOTbX9RyuGciNJCBfNy7cC7ZzxMR7M(YgjdPJ6nlQemNBiUvvAiqyeDMZVQNnnxMuYsucIBvLwhycXHdxXnBaNFroP5Y8gpiISy2DJjEey5n9KjrShS6MelHBR4KxTITlWTBSDbU5jwvXGrmwvHoGoHhbwY74rDZjKHoaN1bJA(RzCZjeWUQieUUp3qBdI7xXOafqoh52koX2f42NZUWx3n9Lnsgsh1Bwujyo3IyCoH9l1qGWi6mNFvpBAkO0czGs4fL4DkXJhkzAfFWOnIcWnyUKaOeErj18(B8GiYIz3TMR4QsGIdxXfvy)HB6jtIypy1njwc3wXjVAfBxGB3y7cCJhkz1vLafLGROe0uy)HBoHm0b4SoyuZFnJBoHa2vfHW195gABqC)kgfOaY5i3wXj2Ua3(C2Agx3n9Lnsgsh1Bwujyo3qCRQ0qYyCk7ggnxMuIhpucIBvLgcegrN58R6ztZLjL4XdLeX4Cc7xQHaHr0zo)QE20uqPfYaLWRfqjoOepEOKPv8bJ2ika3G5scGs41cOKAV5gpiISy2DlmDHjKGB6jtIypy1njwc3wXjVAfBxGB3y7cCZMUWesWnNqg6aCwhmQ5VMXnNqa7QIq46(CdTniUFfJcua5CKBR4eBxGBFoBD91DtFzJKH0r9MfvcMZn0JsqCRQ0qGWi6mNFvpBAUmVXdIilMD3qGWi6mNFvpB30tMeXEWQBsSeUTItE1k2Ua3UX2f4gQqyeDMsqhv9SDZjKHoaN1bJA(RzCZjeWUQieUUp3qBdI7xXOafqoh52koX2f42NZw746UPVSrYq6OEZIkbZ5MpucG(UcMmHKwSZzoCf3SbC(f5eLSeLaOVRGjtiPfXsuafFGmcC4kUQEGaLSeLmDgKJgwcC(fZg3SbCm74Enq2izirj(sjE8qjiUvvAiqyeDMZVQNnnfuAHmqjlsj8tjE8qjtR4dgTruaUbZLeaLWlkP2XnEqezXS7whycXHdxXnBaNFroDtpzse7bRUjXs42ko5vRy7cC7gBxGB8eycXHsWvuYSbuc6OiNU5eYqhGZ6Grn)1mU5ecyxvecx3NBOTbX9RyuGciNJCBfNy7cC7ZzR9(1DtFzJKH0r9MfvcMZnFOe0JsModYrljuaxLcKlFNgiBKmKOepEOeFOee3QkTKqbCvkqU8DAkO0czGswKs4lMOeEJsQ1CqjE8qj(qjOhLG4wvPLekGRsbYLVtZLjLSeLGEuY0zqoAyjW5xmBCZgWXSJ71azJKHeL4lL4lL47nEqezXS72EroZfXLslt30tMeXEWQBsSeUTItE1k2Ua3UX2f4g6SiNPe0WLslt34rXx420k(GHtuTGIqUqqGWi6mxfOWrXSttbLwid3CczOdWzDWOM)Ag3CcbSRkcHR7Zn02G4(vmkqbKZrUTItSDbU95S1EZ1DtFzJKH0r9MfvcMZTamCiyPBqBeGYbdohmJuYIucdkzjkPJJafGdKqrabkzbusnLSeLGEucG(UcMmHKg63mZnhOGKRKZFR4WQeOOKLOeFOee3QkneimIoZ5x1ZMMltkzjkbXTQsdbcJOZC(v9SPPGslKbkHxucFXeLWBuIdkXxkzjkXhkb9OKPZGC0scfWvPa5Y3PbYgjdjkXJhkbXTQsljuaxLcKlFNMckTqgOKfPe(IjkH3OKAnhuIV34brKfZUBrmIQ5cB45MEYKi2dwDtILWTvCYRwX2f42n2Ua3qdJOAkX2WZnNqg6aCwhmQ5VMXnNqa7QIq46(CdTniUFfJcua5CKBR4eBxGBFoBT3ED30x2iziDuVzrLG5ClIX5e2VudbcJOZC(v9SPPGslKbkzrkXbLSeL4dL4dLGEucG(UcMmHKg63mZnhOGKRKZFR4WQeOOepEOKigNty)sT9ICMlIlLwM0uqPfYaLS4cOKAkXxkXJhkPYnN5uqCRv8bCJOaucVOe(IjkXJhkjIX5e2VuBetldCZMRmbknxMuIhpushhbkahiHIacuYIusnL47nEqezXS7wsOaoeOdZn9KjrShS6MelHBR4KxTITlWTBSDbUTScfqjOcDyU5eYqhGZ6Grn)1mU5ecyxvecx3NBOTbX9RyuGciNJCBfNy7cC7ZzR59x3n9Lnsgsh1Bwujyo3qCRQ0qGWi6mNFvpBAUmVXdIilMD3gX0Ya3S5ktG6MEYKi2dwDtILWTvCYRwX2f42n2Ua30jMwUqfOeDBUYeOU5eYqhGZ6Grn)1mU5ecyxvecx3NBOTbX9RyuGciNJCBfNy7cC7ZzR5)6UPVSrYq6OEZIkbZ5gIBvLwsOaUkfix(onfuAHmqj8AbucFXeLWBusTMdkXJhkXhkz6mihnSe48lMnUzd4y2X9AGSrYqIswIs8HsIyCoH9l1qGWi6mNFvpBAkO0czGswKs8oLSeLe3AfFqGRs1XrGLDMswKsQ1Cqj(sj(sjE8qjvU5mNcIBTIpGBefGs4fLWxmrjE8qjtR4dgTruaUbZLeaLWlkzHVXdIilMD3scfWvPa5Y3Dtpzse7bRUjXs42ko5vRy7cC7gBxGBlRqbuc6QcKlF3nNqg6aCwhmQ5VMXnNqa7QIq46(CdTniUFfJcua5CKBR4eBxGBFoB9YCD30x2iziDuVzrLG5CRJJafGdKqrabkzrkP(gpiISy2DdPvQMp4MEYKi2dwDtILWTvCYRwX2f42n2Ua3qTvQMp4MtidDaoRdg18xZ4MtiGDvriCDFUH2ge3VIrbkGCoYTvCITlWTpNTEHVUB6lBKmKoQ3SOsWCU1XrGcWbsOiGaLSiL4nuYsuIpucIBvLgc0HHlMHgfqtbLwiducVOe(IjkXJhkbXTQsdb6WWfZqJcOLW(LuIV34brKfZUBf38icB45MEYKi2dwDtILWTvCYRwX2f42n2Ua3wDZJaDX2WZnNqg6aCwhmQ5VMXnNqa7QIq46(CdTniUFfJcua5CKBR4eBxGBFoRdgx3n9Lnsgsh1B8GiYIz3T9ICMlIlLwMUPNmjI9Gv3KyjCBfN8QvSDbUDJTlWn0zrotjOHlLwMOeFQ99MtidDaoRdg18xZ4MtiGDvriCDFUH2ge3VIrbkGCoYTvCITlWTpN1r91DtFzJKH0r9MfvcMZToocuaoqcfbeOKfPKAkzjkXhkbXTQsdb6WWfZqJcOPGslKbkHxucFXeL4XdLG4wvPHaDy4IzOrb0sy)skX3B8GiYIz3TIBEeHn8Ctpzse7bRUjXs42ko5vRy7cC7gBxGBRU5rGUyB4Hs8P23BoHm0b4SoyuZFnJBoHa2vfHW195gABqC)kgfOaY5i3wXj2Ua3(CwhoUUB6lBKmKoQ3SOsWCUvHJUbTORsbYHs4fLSWmUXdIilMD3IBIsdQMlSHNB6jtIypy1njwc3wXjVAfBxGB3y7cCdTnrPbvtj2gEU5eYqhGZ6Grn)1mU5ecyxvecx3NBOTbX9RyuGciNJCBfNy7cC7ZzD49R7M(YgjdPJ6nlQemNBa67kyYesAkCR4WvCZgWfauajxwGLbkzjkPJJafGdKqrabkzbusnLSeL4dLeX4Cc7xQTxKZCrCP0YKMckTqgOKfPKkC0nOnIcWnyUsJUPeEJsyOTmElLSeLeX4Cc7xQHaHr0zo)QE20uqPfYaLSiLuHJUbTruaUbZvA0nLWBucdTLXBPeFVXdIilMD3IyevZf2WZn9KjrShS6MelHBR4KxTITlWTBSDbUHggr1uITHhkXNAFV5eYqhGZ6Grn)1mU5ecyxvecx3NBOTbX9RyuGciNJCBfNy7cC7ZzD4nx3n9Lnsgsh1Bwujyo38HsIyCoH9l12lYzUiUuAzstbLwiduYIusfo6g0grb4gmxPr3uYsuseJZjSFPgcegrN58R6zttbLwiduYIusfo6g0grb4gmxPr3uIVuIhpuIpucIBvLgcegrN58R6ztZLjLSeL4dL0XrGcWbsOiGaLSakPMs84HsQWr3GMc4dKucVrjrmoNW(LA7f5mxexkTmPPGslKbkzrkPJJal12lYzUiUuAzslIddL4lL4lL4XdLmTIpy0grb4gmxsaucVOKigNty)sT9ICMlIlLwM0uqPfYaL4XdL4dLaOVRGjtiPXSvbih4gSKpxGswIsqCRQ0y2QaKdCdwYNlOPGslKbkHxlGs4lMOeEJsCqj(EJherwm7UfXiQMlSHNB6jtIypy1njwc3wXjVAfBxGB3y7cCdnmIQPeBdpuIpo89MtidDaoRdg18xZ4MtiGDvriCDFUH2ge3VIrbkGCoYTvCITlWTpN1H3ED30x2iziDuVzrLG5CdXTQsdbcJOZC(v9SP5Y8gpiISy2Dljuahc0H5MEYKi2dwDtILWTvCYRwX2f42n2Ua3wwHcOeuHomuIp1(EZjKHoaN1bJA(RzCZjeWUQieUUp3qBdI7xXOafqoh52koX2f42Np3y7cCZef0OeuHomuYAhgqTBHqjjOQDZZNFa]] )

    storeDefault( [[SimC Beast Mastery: precombat]], 'actionLists', 20180421.220053, [[dqJPcaGEvOAxivETkQzlP5RI0nPu3vfOBtLDkv7LSBu2VOAyI0VvAOijdwugUioOkXXOKZPcYcvPwkcTyv1YL4HiXtbpMQEUuMOkGPQknzenDHlIaxg66uOTQIyZuKTJKAzQIXPcQPPcLVRcPdRyDiiJMI60O6KiL(lsvxdb15vj9mk4BifVvfILLEfqaB(vKuFbhanngRHUfa(cpjeiGiwXPHQ)KAD40JzzGUNhdhYGbbqc65tLF8j4lt9hcBqWfFWxwtVQBPxbeWMFfj1TaWx4jHGyQilORfRlHoKn)ksk4YNx5XvbfJm6hFWxg9vEleqlJK7NylcyldfyVK9XHcaUJsE2TDEgeRlHq5zjf0VU)ec6JdfaX6sYZOQG(19NqafZO)S9sn6qwOVaIyfNgQ(tQfnwPcaZ7rTxsUjowA6warSTglESPxfcGOW9bfZO)SUvO(JEfqaB(vKu3cU85vECvqZOZTm6tWqaTmsUFITiGTmuG9sEYu6JdfiOpouaLPwZZOcJ8mlbeXkonu9NulASsfqeBRXIhB6vHakMr)z7LA0HSqFb2lzFCOafQBqVciGn)ksQBbx(8kpUkizd(YeqlJK7NylcyldfyVKNmL(4qbc6JdfCQ3KP0uV3KPJq1g8LDWtlciIvCAO6pPw0yLkGi2wJfp20RcbumJ(Z2l1OdzH(cSxY(4qbkuiOpouaWDuYZUXPf5z2tlWYvcLNLuq)6(tOqca]] )

    storeDefault( [[SimC BM Stomp: default]], 'actionLists', 20180421.220053, [[dy0azaqiOk1Muc(eQkPgfvfNIkvRcQIUfuf0UiLHHchtsTmQONrvjtdvL6AkvOTPub(gQQgNsf5CkvuRdvLK5HQI7rvP2NsOdIQ0cHQ6HqLMiQkXfjvzJkvkojvkVeQcCtLYorPHQubzPujpLYujvUQsfuBLuvFvPsvVvPsL7QuP0Ev9xuzWiDyPwmuESqtwKld2SK8zufJwjDAcVwPQzlXTf1Uj63qgok64qvYYj55cMUIRtv2Us03PQA8qvOZdvSELkz(uH9J4xFD30t2yfiDSBSDgUzImUek(BeQnOmt(kcnbvTxzUzrLG5C7MlOaDaoRtg17ed(U2xAoD6RD2x(6MXeIIUi2vpcK8So3rFDJ34iqYW1D26R7MEYgRaPJ)nlQemNB34ftuedo3Iip5akUWkAU5MmjI9Gu3KijCBdL0VvSDgUDJTZWnCrEYbueQTIMBUGc0b4SozuZFnJBUGaYtfHW195gURqC)gAjKb5CSBBOeBNHBFoRZR7MEYgRaPJ)nEXefXGZnVaWjgihU5MmjI9Gu3KijCBdL0VvSDgUDJTZWnhXQkgmIXQQD3oCaiu3gih2Tou3CbfOdWzDYOM)Ag3CbbKNkcHR7ZnCxH4(n0sidY5y32qj2od3(CwFDD30t2yfiD8VzrLG5CRcf9cAjOsefdHUOVjuFX4gVyIIyW5wRITe4gKsbY5MBYKi2dsDtIKWTnus)wX2z42n2od34vfBjqO6qkfiNBUGc0b4SozuZFnJBUGaYtfHW195gURqC)gAjKb5CSBBOeBNHBFolFFD30t2yfiD8VzrLG5CdZRQsddcJOlC(v9SQPGClKbcDrcLFcDbc1hcfVj0amCyiPxqBeGYjdoNmJe6Iekdc1HdcfZRQsddcJOlC(v9SQPGClKbcLpeADnH6(nEXefXGZnmqfa1EHKNBUjtIypi1njsc32qj9BfBNHB3y7mCdFqfa1EHKNBUGc0b4SozuZFnJBUGaYtfHW195gURqC)gAjKb5CSBBOeBNHBFo7oED30t2yfiD8VzrLG5CdZRQsddcJOlC(v9SQPGClKbcDrcL)B8IjkIbNByfekXv5PW5MBYKi2dsDtIKWTnus)wX2z42n2od3WVGqjcD34PW5MlOaDaoRtg18xZ4MliG8uriCDFUH7ke3VHwczqoh72gkX2z42NZUdUUB6jBScKo(34ftuedo3wIkfaNBUjtIypi1njsc32qj9BfBNHB3y7mCtFuPa4CJxfpHBdIhEkGVrYBUGc0b4SozuZFnJBUGaYtfHW195gURqC)gAjKb5CSBBOeBNHBFol)x3n9Knwbsh)Bwujyo3W8QQ0WGWi6cNFvpRAEmj0fiumVQkToWeIdhQIBwbo)IssZJ5nEXefXGZnMOrGK3CtMeXEqQBsKeUTHs63k2od3UX2z4MJyvfdgXyv1UBhcncKC36qDZfuGoaN1jJA(RzCZfeqEQieUUp3WDfI73qlHmiNJDBdLy7mC7Zz3PR7MEYgRaPJ)nlQemNBreQKq(LAyqyeDHZVQNvnfKBHmqO8Hq9fH6WbHoTIhy0grg4gexsaekFi06DWnEXefXGZTMl7PsGIdvXfvi)HBUjtIypi1njsc32qj9BfBNHB3y7mCJxcDZtLafHIQiuCvi)HBUGc0b4SozuZFnJBUGaYtfHW195gURqC)gAjKb5CSBBOeBNHBFo7oFD30t2yfiD8VzrLG5CdZRQsdRGqPIxy08ysOoCqOyEvvAyqyeDHZVQNvnpMeQdheAeHkjKFPggegrx48R6zvtb5widekF8nH6KqD4GqNwXdmAJidCdIljacLp(MqR57B8IjkIbNBHPZmHeCZnzse7bPUjrs42gkPFRy7mC7gBNHB20zMqcU5ckqhGZ6Krn)1mU5ccipvecx3NB4UcX9BOLqgKZXUTHsSDgU95S1mUUB6jBScKo(3SOsWCUH3ekMxvLggegrx48R6zvZJ5nEXefXGZnmimIUW5x1Z6n3KjrShK6MejHBBOK(TITZWTBSDgUHpegrxi0DVQN1BUGc0b4SozuZFnJBUGaYtfHW195gURqC)gAjKb5CSBBOeBNHBFoBD91DtpzJvG0X)MfvcMZnFiuaV8emzcjTyxkCOkUzf48lkjcDbcfWlpbtMqslIKlbfpGmcCOkUQEGaHUaHoDbKJgscC(fZk3ScCm74Enq2yfirOUtOoCqOyEvvAyqyeDHZVQNvnfKBHmqOlsO8tOoCqOtR4bgTrKbUbXLeaHYhcT25nEXefXGZToWeIdhQIBwbo)Is6MBYKi2dsDtIKWTnus)wX2z42n2od34nWeIdHIQi0zfi0DVOKU5ckqhGZ6Krn)1mU5ccipvecx3NB4UcX9BOLqgKZXUTHsSDgU95S1oVUB6jBScKo(3SOsWCU5dHI3e60fqoAjHc4QuGCx4ObYgRajc1Hdc1hcfZRQsljuaxLcK7chnfKBHmqOlsO8etekEsO1AojuhoiuFiu8MqX8QQ0scfWvPa5UWrZJjHUaHI3e60fqoAijW5xmRCZkWXSJ71azJvGeH6oH6oH6(nEXefXGZT9IsHlIY5wMU5MmjI9Gu3KijCBdL0VvSDgUDJTZWn8arPqO4IY5wMUXRINWTPv8adNOY3zHKVcdcJOlCvGcffdoAki3cz4MlOaDaoRtg18xZ4MliG8uriCDFUH7ke3VHwczqoh72gkX2z42NZw7RR7MEYgRaPJ)nlQemNBby4WqsVG2iaLtgCozgj0fjuge6ceAhhXsGdKqwabc13eAnHUaHI3ekGxEcMmHKgE1mlnhOGKNKZFR4qQeOi0fiuFiumVQknmimIUW5x1ZQMhtcDbcfZRQsddcJOlC(v9SQPGClKbcLpekpXeHINeQtc1DcDbc1hcfVj0PlGC0scfWvPa5UWrdKnwbseQdhekMxvLwsOaUkfi3foAki3czGqxKq5jMiu8KqR1CsOUFJxmrrm4ClIWunxyfn3CtMeXEqQBsKeUTHs63k2od3UX2z4gUimvtO2kAU5ckqhGZ6Krn)1mU5ccipvecx3NB4UcX9BOLqgKZXUTHsSDgU95S1891DtpzJvG0X)MfvcMZTicvsi)snmimIUW5x1ZQMcYTqgi0fjuNe6ceQpeQpekEtOaE5jyYesA4vZS0CGcsEso)TIdPsGIqD4GqJiujH8l12lkfUikNBzstb5wide6I(MqRju3juhoi0kVsHtbX1wXdWnImqO8Hq5jMiuhoi0icvsi)sTrmTmWnREYeO08ysOoCqODCelboqczbei0fj0Ac19B8IjkIbNBjHc4WGom3CtMeXEqQBsKeUTHs63k2od3UX2z4gFrOacfFOdZnxqb6aCwNmQ5VMXnxqa5PIq46(Cd3viUFdTeYGCo2TnuITZWTpNTEhVUB6jBScKo(3SOsWCUH5vvPHbHr0fo)QEw18yEJxmrrm4CBetldCZQNmbQBUjtIypi1njsc32qj9BfBNHB3y7mCtNyAjFDGq1T6jtG6MlOaDaoRtg18xZ4MliG8uriCDFUH7ke3VHwczqoh72gkX2z42NZwVdUUB6jBScKo(3SOsWCUH5vvPLekGRsbYDHJMcYTqgiu(4BcLNyIqXtcTwZjH6WbH6dHoDbKJgscC(fZk3ScCm74Enq2yfirOlqO(qOreQKq(LAyqyeDHZVQNvnfKBHmqOlsO(IqxGqJRTIhiWvP64iqYUqOlsO1Aoju3ju3juhoi0kVsHtbX1wXdWnImqO8Hq5jMiuhoi0Pv8aJ2iYa3G4scGq5dHUZ34ftuedo3scfWvPa5UW5MBYKi2dsDtIKWTnus)wX2z42n2od34lcfqO7gfi3fo3CbfOdWzDYOM)Ag3CbbKNkcHR7ZnCxH4(n0sidY5y32qj2od3(C2A(VUB6jBScKo(3SOsWCU1XrSe4ajKfqGqxKqRVXlMOigCUH1kvZdCZnzse7bPUjrs42gkPFRy7mC7gBNHB43kvZdCZfuGoaN1jJA(RzCZfeqEQieUUp3WDfI73qlHmiNJDBdLy7mC7ZzR3PR7MEYgRaPJ)nlQemNBDCelboqczbei0fju(MqxGq9HqX8QQ0WGomCXc0lbnfKBHmqO8Hq5jMiuhoiumVQknmOddxSa9sqlH8lju3VXlMOigCUL9kJiSIMBUjtIypi1njsc32qj9BfBNHB3y7mCBZRmc8qBfn3CbfOdWzDYOM)Ag3CbbKNkcHR7ZnCxH4(n0sidY5y32qj2od3(C26D(6UPNSXkq64FJxmrrm4CBVOu4IOCULPBUjtIypi1njsc32qj9BfBNHB3y7mCdpqukekUOCULjc1NA3V5ckqhGZ6Krn)1mU5ccipvecx3NB4UcX9BOLqgKZXUTHsSDgU95SozCD30t2yfiD8VzrLG5CRJJyjWbsilGaHUiHwtOlqO(qOyEvvAyqhgUyb6LGMcYTqgiu(qO8eteQdhekMxvLgg0HHlwGEjOLq(LeQ734ftuedo3YELrewrZn3KjrShK6MejHBBOK(TITZWTBSDgUT5vgbEOTIgc1NA3V5ckqhGZ6Krn)1mU5ccipvecx3NB4UcX9BOLqgKZXUTHsSDgU95SoRVUB6jBScKo(3SOsWCUvHIEbTONsbYHq5dHUZmUXlMOigCUfxf5gunxyfn3CtMeXEqQBsKeUTHs63k2od3UX2z4gURICdQMqTv0CZfuGoaN1jJA(RzCZfeqEQieUUp3WDfI73qlHmiNJDBdLy7mC7ZzD686UPNSXkq64FZIkbZ5gGxEcMmHKMc1kouf3ScCbyji5kcKmqOlqODCelboqczbeiuFtO1e6ceQpeAeHkjKFP2ErPWfr5CltAki3czGqxKqRqrVG2iYa3G4YnEKqXtcLH2oTJe6ceAeHkjKFPggegrx48R6zvtb5wide6IeAfk6f0grg4gexUXJekEsOm02PDKqD)gVyIIyW5weHPAUWkAU5MmjI9Gu3KijCBdL0VvSDgUDJTZWnCryQMqTv0qO(u7(nxqb6aCwNmQ5VMXnxqa5PIq46(Cd3viUFdTeYGCo2TnuITZWTpN1PVUUB6jBScKo(3SOsWCU5dHgrOsc5xQTxukCruo3YKMcYTqgi0fj0ku0lOnImWniUCJhj0fi0icvsi)snmimIUW5x1ZQMcYTqgi0fj0ku0lOnImWniUCJhju3juhoiuFiumVQknmimIUW5x1ZQMhtcDbc1hcTJJyjWbsilGaH6BcTMqD4GqRqrVGMc4bKekEsOreQKq(LA7fLcxeLZTmPPGClKbcDrcTJJaj12lkfUikNBzslIcdH6oH6oH6WbHoTIhy0grg4gexsaekFi0icvsi)sT9IsHlIY5wM0uqUfYaH6WbH6dHc4LNGjtiPXSvbOe4gKKhpGqxGqX8QQ0y2QaucCdsYJhOPGClKbcLp(Mq5jMiu8KqDsOUFJxmrrm4ClIWunxyfn3CtMeXEqQBsKeUTHs63k2od3UX2z4gUimvtO2kAiuFC6(nxqb6aCwNmQ5VMXnxqa5PIq46(Cd3viUFdTeYGCo2TnuITZWTpN1jFFD30t2yfiD8VzrLG5CdZRQsddcJOlC(v9SQ5X8gVyIIyW5wsOaomOdZn3KjrShK6MejHBBOK(TITZWTBSDgUXxekGqXh6WqO(u7(nxqb6aCwNmQ5VMXnxqa5PIq46(Cd3viUFdTeYGCo2TnuITZWTpFUXxGQ2Rmh)p)]] )

    storeDefault( [[SimC BM Stomp: precombat]], 'actionLists', 20180421.220053, [[dmZTbaGEKsTlrOxJIA2IA(ivUjL6UkuUnv2PG9s2nf7xrggQ63knuuKbdKHlshueDmeDoKclevAPkQfJWYb1drfpv1YOK1HuYerkAQkyYGmDjxuHCzORJsTvusBgGTlcEosMgqLhl0HLACafJgPQttvNef8maDnGQopk03qj(RcvVfO0Iud6JmnrgHeHEODO(9ootG4Apb616sP1eOuymUoIU0Fe2Nw66ZygBkublEsWWdosGjAzbKgabQ)um67SN2D5xJcwGhOEYy5xdLguGud6JmnrgHex9Ke(SVyuNITZTMXtXsNbdKp21cRBwdQBVqS2WH2H66H2H6C6CEcetynbIuFgZytHkyXtYcjV(msTSHJiLguPZHEmYS9Ma6qtjcD7fk0ouxLcwAqFKPjYiK4QNKWN9fJ6PB5xJodgiFSRfw3Sgu3EHyTHdTd11dTd1PlcaapFmcaayzAl)AgJoy9zmJnfQGfpjlK86Zi1YgoIuAqLoh6XiZ2BcOdnLi0TxOq7qDvQ0PjcOzNlXvLe]] )


    storeDefault( [[Survival Primary]], 'displays', 20171128.135411, [[d8t6haWyKA9QiVKcv7cjk2gfGFd1mPinnkOMTcNNkUPIkNgLVrb5ysPDsP9k2nj7hs(jKAyeACuG6YQAOemyiA4iCqPQJIeLoSKZrbYcLklfjSyQQLt0dLIEkyzuupNuturPMkIMmQy6kDrv4QuiEMIsCDvAJsHTQOK2mvz7q4JkkETIQ(ms67kYiPqzDuinAu14vrDsuPBrb01qICpKOQBtLwlsu54ueN2qgGUiwgw1aRwyDgFa0gH0uU2Ja0fXYWQgy1cStFSTMdilf1Vj)tpF6c4pyNonZapf)aoO980)2SiwgwPJvmWz0EE6FBweldR0XkgWK7FFoCPXkGD6J1WIbCzQ(JynhWK7FFonlILHv60fWbTNN(xYss9xDSIbOS3)(6qgBBidCOk)XZjDb6PxgwHcPPm9gRbfWwUFakU6I3OOqsiFASRFTbO4hFP)ynl2AiXwrXaaTKrSbwM7t5fZgR5qg4qv(JNt6c0tVmScfstz6nwdoGTC)auC1fVrrHKZ7v3XgGIF8L(J1SyRHeBffZMnGMhpbtSLMV)iDb084P(7Itxa36mqgBBGTKu)TxrZJLb6qtsIEok4oJXid4eRbA2aedCowXaAE8ezjP(RoDbM3VxrZJLbirlqb3zmgzaASRFTcioIFa6IyzyvVIMhld0HMKe9CbaINMvd2PAzyvSMPeLcO5Xtaz6cyY9V)SzYNEzyvak4oJXidOUUCPXkDSgoGM4hJgJsZ3epWYqgOITnGm22auJTnGFSTzdO5XtnlILHv60f4mApp9V9xzfRyG6klshIpG)1ZlGBDU)U4yfdudc(QFmvoAbehX2gOge8fWJNeqCeBBGAqWxnXU(1kG4i22aZ(9Q7ytxGAmvoAbecPlacMM5ZgS1H0H4d4hGUiwgw1pyuvbAEyjpOiahMMyuoKoeFGkGSuuFshIpq5ZgS1jqDL1Cm1NUaMCz0ZpRmnSoJpqfyE)gy1cStFSTMdyl3paCLiyiQbkKcsMBjDcudc(ISKu)vaHqSTbCq75P)LRIdJUwSuhRya5pc08WsEqranXpgngLMp(bQbbFrwsQ)kG4i22amfhgDTyzVIMhldqb3zmgzatU)95WvXHrxlwQtxaxMQ)U4yfduxz1RO5XYaDOjjrpNPhnidSLK6VnWQfwNXhaTrinLR9iWC1zM71ffssM7h7SigqZJNGj2sZ3FxC6ca0sgXgiqni4R(Xu5OfqieBBG6klUkpmPdXhW)65fGqYClPtdSAb2Pp2wZbiKpn21V2Ebtdam3MOqcxjcgIAyuuijKpn21V2aAE8u)vwCvE44hWTo3FeRyaYA8QffYzK4lrSIb2ss9xbehXpaf)4l9hRzXwdjAaMPeLP1GOKzdBOacsMBjDqHSzrSmSkGwwldhGZ7v3X2lyAaG52efs4krWqudJIcjN3RUJnGdApp9VgVthRb2g4mApp9VKLK6V6yfdmVFdSAH1z8bqBest5Apc4G2Zt)B)vwXkgqZJN4Q4WORfl1Plqni4lGhpjGqi22a1yQC0ciosxG6klG4hdUZowZITIgCBanpEsaXr6cqJD9RvaHq8dmVFdSAdiqIcjuknkK2skXtb084P(J0fqZJNeqiKUaUmfqgRyGTKu)TbwTa70hBR5aNr75P)14D6yfdqxeldRAGvBabsuiHsPrH0wsjEkqni4RMyx)AfqieBBGdv5pEoPlGM5sm(E0hXAoG)GD60md8u)ye)aEy1g44mH816PYjWwsQ)kGqi(bm5(3VFWOQCF1gGoGMhpz83XNP4Wuu1PlGGK5wshuiBweldRqHS)kRaZHvuXy9JczJR0jaHK5wshU0yfWo9XAyXamAScikAMIASukaJgROCySBSZIyatU)950aRwGD6JT1CGTKu)TbwTbeirHekLgfsBjL4PaMC)7ZX4D60f4mApp9VCvCy01IL6yfduxzzefBdqmkNxMnba]] )

    storeDefault( [[Survival AOE]], 'displays', 20171128.135411, [[dee7haqiIe1MubPBPcIDbjfdtkoMcwgQ0ZisY0if5Aqs2gKu5BKcghKu6Cej16is5Eej0bLslurEivvtufuxuH2ivLpQcmssHojr8ssrntsj3ufYoP0pHOHsQokKu1svr9uWurYvjs1wjsWAjsK9kgmK6Wswmr9yKAYOIlRQntfFgHgnQ60O8AvOMTuDBQYUj8BOgoIooPulNINtY0v66Q02HW3vuJhsCEQ06vr2pcodHkaDrUmSWhwSW62)aiLoLwsSJbOlYLHf(WIfyN(yh4gWucIVF(N(4mfqUZoD6GoEoYbCr64O(1FrUmSqfBtauq64O(1FrUmSqfBtaTV)95iHgla2Ppwn1eWJjAhJLBaTV)954VixgwOYuaxKooQFPkdXFvX2ea1F)7RcvSdHkWOOK7pNmfOLEzybb0AXuBSsDaB59boFvfV0iGM080yp5AdC(7FP(y52mOHMHMMaaTHrUbwM3lfBYgl3qfyuuY9NtMc0sVmSGaATyQnwuBaB59boFvfV0iGMZ7u3(g483)s9XYTzqdndnnzZgqXJNHz2sZ3oMPaOG0Xr9lvzi(Rk2MamASailAMGySOkWwgI)2kO5XMatiPOqE0zjhOrQaUXEiChqvauITjGIhptvgI)QYuGJLBf08ytakK6NLCGgPcqJ9KRvhXyKdqxKldlAf08ytGjKuuipkaq(0SQZovldlILlQqvafpEgOYuaTV)9pmZ80ldlcCwYbAKkG46jHgluXQPakYV391lfVFChBcvGk2HaMyhcqm2HaYXoKnGIhp7VixgwOYuauq64O(T9AQyBcuxtr5s(bKVoob8kuAVlo2MavNKVA7ZLRshXySdbQojFb84zDeJXoeO6K8LFSNCT6igJDiWHFN623mfO6ZLRshHEMcGGPyYSoBDPCj)aYbOlYLHfTDgrra)JwQXZb4WuK9YLYL8dqhWucIpLl5hOKzD26gOUM6iM4ZuaTVm6JLcmfSU9pqf4yzFyXcStFSdCdylVpaCniyiQob0TihdOByELXLaA)f5YWccOBVMkWrybrmw9eq77ACd4XeT3fhl3aMVhW)OLA8Caf537(6LIpYbQojFrvgI)QJym2HaUiDCu)krWHrxl2OITjG23)(CKi4WORfBuzkGIhpdZSLMV9U4mfOUMQvqZJnbMqsrH8iTg9rfyldXF9HflSU9pasPtPLe7yGJkuyExpcOPyEFSsvtaVcfGk2MaaTHrUbumbX(FOs56U4avNKVA7ZLRshHESdbQRPKiCWuUKFa5RJtasdZRmU(WIfyN(yh4gG080yp5AB11kaW88tanCniyiQU0iGM080yp5AdO4XZT3fh5aEfkTJX2eGQ6VyjG(ad(sgBtGTme)vhXyKdOByELXLaA)f5YWIaktTmCafpEwZVRmtWHjiQYuaoVtD7BRUwbaMNFcOHRbbdr1Lgb0CEN623aUiDCu)Q5jvShYqGTme)1hwSb0PiGgkHIaABzm45ahl7dlwyD7FaKsNslj2XaUiDCu)2EnvSnbu84zjcom6AXgvMcuDs(c4XZ6i0JDiq1NlxLoIXmfOUMci)ExYHJTjGIhpRJymtbOXEY1QJqpYbow2hwSb0PiGgkHIaABzm45akE8C7yKdO4XZ6i0ZuapMaOILBGTme)1hwSa70h7a3aOG0Xr9RMNuXoeGUixgw4dl2a6ueqdLqraTTmg8CGQtYx(XEY1QJqp2HaJIsU)CYuafZJS)TihJLBa5o70Pd6452EpYb0((3VTZik8EXgGoWwgI)QJqpYbQojFrvgI)QJqp2HaN)(xQpwUndAOb1XfvOMbPgvC1KgcqAyELXvcnwaStFSAQjatWHrxl20kO5XMaNLCGgPcO4XZTxtjr4GJCagnwiLWyVyLQMaAF)7ZXhwSa70h7a3aoyXgyefsZRuZLBaTV)95O5jvMcGcshh1VseCy01InQyBcuxtjDbBdq2l33Knb]] )

    storeDefault( [[Marksmanship Primary]], 'displays', 20180317.224416, [[d4tviaGEqXlrsSlQqSncsCyjZKG62k0Sv01ie3ukYJrX3uPQ8CsTtkTxXUr1(Ps9tvyysLXPsvUSsdLKgSuy4i1bvWNrIJjLoUkLfsvwksQftvTCIEivYtHwMuuRJkuMOkvMkitwfnDvDrvYvjiEgssxhrBKqTvcsAZKy7e4Jur(kvOAAubFxQAKurnwvQQgncJhu6KGQBrfsNMIZJsVMqATeK63aN2afKPOFdGlgWF8zNBWdHajmC7vWVKu2xvGA8dkloL1fXYiA8c6pnWaJttqF8dYEOOO33vr)gaxhBxqypuu077QOFdGRJTl4OHpCflvdEJCj3txf9BaCD8cclRlaxWk)9mEbzpuu07dvsk7RJTlOMa0J9MNHy4kEb1eG(bYheVGAcqp2BEgIbYheVGFjPS)aNHaid6DabD0e1WDYzOGWEOOO3NkE6yBdQa4Fqvi3nWIRD3WwsjOpi7HIIE)72zXgBxqypuu07F3ol2y7cQja9qLKY(64fuu)bodbqge6qLA4o5muWBKl5EcNbWDCZ5teRiDbPLMXsYcNbWDEnui(yfPlOTg3Gnvsr1JfxtyOD3qvAgljBqd)0WupqoWziaYGud3jNHcAyaCpG8CLXlitr)gaFGZqaKb9oGGoAkiT0mwsw4maUJBoFIyfPlisVmMAAGPEdGhBZI4qqnbOhHIxWBKl5ENrUmVbWdsnCNCgkiNCeodGRJ1HGNRsro)bvHdIMrxUB0ujfvpwCnHH2XC34CvkY5huGrB8ntZZcXsVb9dQP35u8S0eUatGmqbRyBd6hBBqkX2gugBB(GAcqVRI(naUo(bPYU0dA6L5PUEdiEblszbXsVb9jvucAyaCHgagJLQDbHn2UGJfSdKpi2UG(tdmW40e0pmNXpynPjkKa0Rk4k22G1KMOCbg9RxvWvSTbhn8bYheBxq2dff9(uXthRJ2gSM9fRwvGA8ckQVya)dQc5UbwCT7g2skb9bzk63a4dtdfEqxxwOlQdEA00ZIfILEdwbhlyrOyBdkloLfILEdw(MP5zdwKYQjdFJxWBKl5oWziaYGud3jNHckQVya)rdmBSToee2dff9(W5NgM6bsDSDbRjnrbvsk7Rkqn22G3ixY9eodG78AOq8Xksxq5od66YcDrDqn9oNINLMi(bRjnrbvsk7Rk4k22G3ixYDyAOWhx(hKj4nYLCpHZpnm1dK64f8gPHruHQrJp7Cdwbp3zXkgWF8zNBWdHajmC7vWVKu2xmG)4Zo3Ghcbsy42RGN7Syh4meazqOdvHVedf8g5sU4Zo3Gud3jNHcEUZIvmG)ObMn2whcwtAIAy2xSAvbQX2gSiLfsVZj87ITliT0mwswXa(Jgy2yBDiiTCzaJ(1pOkCq0m6YDJMkPO6XIRjm0oM7g0YLbm6xFqnbOxvGA8cowWoCfBxqddG7bKNR0fycKbkyfBBq)y7csj2UGYy7Yh8ljL9vfCf)GuVZT0BSn31EVoQ2EFosZTIiuO69cQja9uzz9n8tdNIoEbp3zXkgW)GQqUBGfx7UHTKsqFqnbO)UDwSbHUUFOGFjPSVya)dQc5UbwCT7g2skb9bH9qrrVpujPSVo2UGAcq)aPSGZvaXpOMa0dNFAyQhi1Xli7HIIEF48tdt9aPo2UG1SVy1QcUIxqnbOF4kEb1eGEvbxXlidy0VEvbQXpyrkRbodbqg07ac6OjHVedfe2dff9(dKYk2UGShkk69hiLvSDbhnCek2UGFjPSVya)rdmBSToe8g5sUdCgcG8qrrVFSIeKPOFdGlgW)GQqUBGfx7UHTKsqFWAstuUaJ(1Rkqn22Gx8YFUNXlO2msp3HJRyBoOWL(Db4cwP2a4X2Cx796ABDWrOAqMI(naUya)rdmBSToeuuFXa(Jp7CdEieiHHBVcAyaCKUymCkXksWIuwW5kaiw6nOpPIsqgWOF9QcUIFq2yD0MBwKGcnam6cWfSYFpJxWAstuibOxvGASTbVrUK7Pya)rdmBSToe8UvPiNF8cEJCj3tQ4PJxWAstudZ(IvRk4k22GfPSec38bPNf7kZNa]] )

    storeDefault( [[Marksmanship AOE]], 'displays', 20180317.224416, [[d4tuiaGEqXlvPQDHsP2gkL0HLmtcPBRcZwrxJkLBkvYJrQVjvkEoP2jL2Ry3OA)uL(PcnmP04KkvxwPHsfdwQy4O4GsXNrIJrvDCvkluQAPiPwmrTCsEivXtHwgkfRJkrnrvQmvqMSkz6Q6IQORIK0ZqsCDeTrc1wLkL2mr2ok5JuP6RujY0qP67kyKujnwukXOry8GsNeuDlQe60uCEcEnHyTuj43ah)afKUyEdGlgWF8fMBWrQcjkC7zWVuu23HLtKdQkoL1dXsls6dkpnWaJ7tWqKdkmkjP33tX8gaxhBBqyhLK077PyEdGRJTn4HH3CglvcEJCj3lpfZBaCD6dcRGhaN1Q(9k9bfgLK07dvkk7RJTnOMamGdMNMO5mYb1eGHgYhe5GAcWaoyEAIgYhK(GFPOSFdNMaOc2pcbn2f1WD3vOGWokjP3)(EDS(bLa8pOdK3oyX1E7ylLcmeuyussV)D7SeITniSJss69VBNLqSTb1eGbOsrzFD6dkICdNMaOccn6qnC3Dfk4nYLCVGtd4UK56jI1T2GmkZrPeGtd4UUgkeFSU1g0whBWUkLi6JIRjmmE70mEg0WVm01dunCAcGki1WD3vOGgAaVhOUwv6dsxmVbWB40eavW(riOXUcYOmhLsaonG7sMRNiw3AdImlTPMgyQ3a4XYg3ypOMamGqPp4nYLCVZOw63a4bPgU7UcfKtEaNgW1XYEWRvQiNFJJObrZHhVD6QuIOpkUMWW4YE7CTsf58dYYOnYMP5fGey2GYb1m7CkEwAcpGjqfOGvS(bLJ1piLy9dQI1pFqnbyWtX8gaxh5G3VltJMzPFQR3asFWIuvqcmBqzsjPGgAa3faGJyPsBqyJTn4rbBd5dITnO80admUpbdnZzKdwtgIcjadoSoJ1pynzikpGd56DyDgRFWddVH8bX2guyussV)996yDr)G1COe0oSCsFqrKfd4FqhiVDWIR92XwkfyiiDX8gaVzAOWd650cDsDWlJMzwcqcmBq6GhfSiuS(bvfNYcjWSblzZ08cblsv1LHVPp4nYLCB40eavqQH7URqbfrwmG)ObMnwF2dc7OKKEF48ldD9aLo22G1KHOGkfL9Dy5eRFWBKl5EbNgWDDnui(yDRnOANb9CAHoPoOMzNtXZste5G1KHOGkfL9DyDgRFWBKl52mnu4hl)dsh8g5sUxW5xg66bkD6dEJ0qls3A04lm3GYbV2zjigWF8fMBWrQcjkC7zWVuu2xmG)4lm3GJufsu42ZGx7SeA40eavqOrhrpfdf8g5sU4lm3Gud3DxHcETZsqmG)ObMnwF2dwtgIQzoucAhwoX6hSivfYSZj87ITniJYCukbXa(Jgy2y9zpiJAPbhY134iAq0C4XBNUkLi6JIRjmmUS3omQLgCixFqnbyWHLt6dEuW2CgBBqdnG3duxRYdycubkyfRFq5yBdsj22GQyBZh8lfL9DyDg5GuVZT0BSSP1V7TuXVByB247gBLkDpOMamC)kiB4xgofD6dETZsqmG)bDG82blU2BhBPuGHGAcWWD7SeccDYwGc(LIY(Ib8pOdK3oyX1E7ylLcmee2rjj9(qLIY(6yBdQjadnKQcoxce5GAcWaC(LHUEGsN(GcJss69HZVm01du6yBdwZHsq7W6m9b1eGHMZihutagCyDM(G0Gd56Dy5e5GfPQA40eavW(riOXUe9umuqyhLK073qQQyBdkmkjP3VHuvX2g8WWrOyBd(LIY(Ib8hnWSX6ZEWBKl52WPjaQrjj9(X6wq6I5naUya)d6a5TdwCT3o2sPadbRjdr5bCixVdlNy9dEYl55EL(GAZbZCBgpJLnbfT0VhaN1Q0gapw20639wFF2zBQeKUyEdGlgWF0aZgRp7bfrwmG)4lm3GJufsu42ZGgAahzkAdNsSUfSivfCUeasGzdktkjfKgCixVdRZihuiwx0VBAd6caWHhaN1Q(9k9bRjdrHeGbhwoX6h8g5sUxIb8hnWSX6ZEW7wPIC(Pp4nYLCVUVxN(G1KHOAMdLG2H1zS(blsvrvU5dYmlHvLpba]] )

    storeDefault( [[Beast Mastery Primary]], 'displays', 20180412.221620, [[de0Zjaqlff1UuuOHrkhJkTmfvptvitdK4AeuTncsFdfjJtrPoNIcADkk5EOivhujwiv1dPctefXfvvTrQOpsQQrQk4KOWljOmtuu3KuLDsPFIqdvbhffPSuvrpfAQi5QeeBvvO6RQcLXQOaRvrr2RyWQkhwYIvKhJutwjDzP2mv5Zey0e60e9AqsZwPUTcTBs(nWWrPJJGwoQEoftxLRdQTtQ8DqmEqQZJO1Ja7xv64gQG0f7jbkNa1Hh5UdsuiumZW(hKUypjq5eOousqhR78G8sjODi20qn(bN2sciq)nasMcss0ZZ0NJI9KaLjwTGqt0ZZ0NJI9KaLjwTGec3W9kdAGcLe0XcfTGJs1YFSZdsiCd3Rok2tcuM4heAshaLUMF9A8dss0ZZ0hvXf0NjwTGmn4gUnHkw3qf8xvt7En(bxOpjq9(XS0CXoddARXo4tytjoR3pwEtdgNQl4ZE3LPJDUMltP5QPfeP5s2l4jhBMUwUyNhQG)QAA3RXp4c9jbQ3pMLMl2zh0wJDWNWMsCwVFRTxbVVGp7DxMo25AUmLMRMwUCbnIaiie5rlU8h)GgraKf4de)GsAGczlAPsqScpybZlgkpafjBhCc2ZlybZlks2o4eSNxqsIEEM(eMVj2z2nizSZ8CHl0GqhRwqsIEEM(ysVlYy1ccnrpptFmP3fzSAbnIaiufxqFM4heQtlkArapifXHNm0)bQGSC5yXjzqdupMC9eJvOAbjeUH7vg0a1JjxpXyHIwqOj65z6ty(My1cQtAKtYT8iPiz7Gtbz5YXItYGgOEOLceVyfQwWAZkwOiaYGUHyDd6buxWFOz5TXaPidAebqqQ4huQwL01b4lkArap4tg6)avWN9Ulth7CnxMY1D(SNr3hjCO46gKUypjqTOOfb8G(ePOiQxqhawY3pkqq)Um37NEL5Ao573axowCYGiBtlRTKG6KavSZf(JckPbkFaFT5XpiHWnCZejVPpjqf8jd9FGkOcEKbnqzIfkbL0a1mbaJXkuTGSC5yXjzqduOKGowOOf0W27TZDzeDa2aEOcwX6gCkw3GcI1nipw3CbnIaiok2tcuM4huyDZUyyB67zDsq8dU2Ef8(wgyoikhD8(53L5E)0RmxZjN173A7vW7litAVcEFzk4axowCY3phf7jbQ3VfyEfupGsaay63pNWCYGJf0lWhiwTGqt0ZZ0hd1QKUoa3eRwWAZkwOiaYGU)yDdwBwXYbyCQUbD)X6gCuQwGpqSAbPbJt1nO7ptbRnKI0mOBi(bH6KtG6coq9(HLY8(zlohajiDXEsGAzlfOc643s9)m4Q0WUlsks2oyf0W27TZDzeZuqEPe0uKSDWAsULhzWcMx6jvD8dsiCd3lkArap4tg6)avqOo5eOousqhR78GfmVq2EVzWKyNR5QnB3G1MvSOkUG(g0neRBqsIEEM(yOwL01b4My1cY7Dqh)wQ)NbVIlOpNa1fCG69dlL59ZwCoasWAZkwufxqFd6(J1nOreabHipAXf4de)GqDYjqD4rU7GefcfZmS)blyETOOfb8G(ePOiQhZ)oPcU27ICrrlc4bPioW8VtQGxXf0NtG6WJC3bjkekMzy)dQxbTCeE89Jso2X(iTGec3WnEK7o4tg6)avqKMlzVGbRnRyTSHuKMbDdX6gKq4gUxzOwL01b4M4hKLlhloPtG6qjbDSUZdYYBAW4uDldmheLJoE)87YCVF6vMR5KZ69JL30GXP6cEfxqFd6gYuWXc6L)y1csv7wDVF6ZbWSXQf8kUG(g09NPG1MvSw2qksZGU)yDdAebqewtojvRsLat8dAebqysVlYGu)ZaQGgraKbD)XpiHWsAO(4sdEK7oyfCT3fPtG6qjbDSUqjOKgO8b81M7aSb8qfSI1n4uSAbfeRwqESA5cAebqyOwL01b4M4h0icGmOBi(bRnKI0mO7p(bx7Dr6eOUGduVFyPmVF2IZbqcAebqw(JFqAW4uDd6gYuqsIEEM(wG5vSAbh4YXIt((5Oypjqf0WRtcccnrpptFlW8kwTGJsfsfRwWR4c6ZjqDOKGow35bjeUH7ffTiGt0ZZ0xScpiDXEsGYjqDbhOE)WszE)SfNdGeS2SILdW4uDd6gI1n4VQM29A8dAKJS7EH4FSZdYCzohaLUMBKavSZ1CNTMRluMXhf0icGSaZlgkpqMcsiCd3lBPa1yRUG0bjeUH7vg0a1dTuG4fRq1ccnrpptFufxqFMy1cowqJuX6g8kUG(wu0IaEqFIuue17jd9FGk4mbaJoakDn)614hCT3fPtG6WJC3bjkekMzy)dsiCd3RobQdLe0X6opOTg7G(DzU3p9kZ1CY3VbUCS4KbjeUH7vH5BIFWPTKac0FdGSS3zkybZlHOKxq2Dr28Cj]] )

    storeDefault( [[Beast Mastery AOE]], 'displays', 20180412.221620, [[dme1jaqiQOsBcvOCluHSlQOQHrrhJkTmLWZajMgiPRHcABurrFtjsJtjQohvuY6uIY9OIsDqf1cPQEivyIOcUOsAJuWhbPmsuGtIk9sQiMjc5MOI2jL(PQyOk0rrfQwkk0tHMkIUkvK2kvuXxvIWyPIcRvjI2RyWQQoSKfRGhJKjRkDzP2mv5ZOOrJQonjVgKQzRu3wr2nHFdmCu64iWYj65KA6QCDqTDk03bX4rqNhPwpc1(vvoUHmivXEkGWaqC4rV7GpoLKiU21Gxjz23OXXmeuwcMTd(Mc6XpibWnCpVvmftT4csfK(XZt3NJI9uaHowZGe(45P7ZrXEkGqhRzqwPAQK0CPacurChlundQ5bqMHLfxHhidbjaUH7xhf7PacD8dsiTdGWylV(n(bPF8809rwsM9PJ1mihhUHBDiJ1nKbxf1WUFJFWzQtbeF)eP0xSoRG2AQdYiSU4x23pRSPatd1fKXE3LUJDHP7snDnndIusf7f8utTZ2mxSlczWvrnS734hCM6uaX3prk9f7YdARPoiJW6IFzF)VTxbVVGm27U0DSlmDxQPRPzUCb18aiie1rXpVg)Ge(45P7JSKm7thRzqnpaccrDu8ZWhi(bVsYSVzbfpqg0)HK8Htg5cngqgCyRiMyOTbqM37me0bGL(7Nee0Vl999ZzPVws)9p)SgKowoAXsDd6bexWvczLTwdPOds)45P7Jd9UOJ1miHpEE6(4qVl6yndQ5bqiljZ(0Xpi0hMfu8azqYNrg5cngqgKvQMkjnxkGyjuVhFSq1mibWnC)YLciwc17XhlundwBw(c5bqgnogRBq6hppDFoXxhlh5gKvQMkjnxkGGbTIj)flumdQOaILeaMI1zAgurbeiBrPemJLHbjmwoIHmmOs8QOQdiNfu8azqg5cngqgCQiejJ1mivXEkGywqXdKb9FijF4mybllsA2o4aSNxqKTPu1wrCDkGi2fmekbvuaHpq(2Y4hKa4gU5Gs2uNcics0QbYGc4jUuaHowOeKWhppDFoXxhRBqo0Ef8(YqqnBV3g2LM3bydKHmyfRBWHyDdYmw3GYyDZfuZdG4OypfqOJFqN0n7SMTPogRtbIFW32RG338irbr1KJVF)U033pNL(Aj9Y((FBVcEFbjaUH7xUuabQiUJfQMbhLQPss)97Oypfq89pdlRGCcembaD)9BawshCQiCg(aXAgKWhppDFCfVkQ6asDSMbRnlFH8aiJgxJ1nyTz5lhGPH6gnUgRBqBn1b97sFF)Cw6RL0F)ZpRbPatd1nACndbRnKIwpACm(bnQ0Qb1wD0K0SDWHGuf7PaI5TIPiOJvl5kJbFvA2DrtsZ2bPcQz792WU08ziOSemBsA2oynO2QJoybllovIo(bjaUH7zbfpqgKOvdK(pKKpCge6dgaIdve3X6UiyTz5lhGPH6gnogRBWAZYxKLKzFJghJ1n4Ounvs6VFhf7PaIGAzDkqqzVd6y1sUYyWRKm7ZaqCbhj)(XsO)(TLucGeS2S8fzjz23OX1yDdsaSIc6ohLgp6DhScc9bdaXHh9Ud(4usI4Axds4JNNUVzyzfRzq6hppDFZWYkwZGxjz2NbG4WJE3bFCkjrCTRb5Siunbp99tQM6yHIzqcGB4gp6DhKrUqJbKbrkPI9cQvcM7MJ5Cl4deS2S818gsrRhnogRBqOpyaiUGJKF)yj0F)2skbqcYkvtLK2aqCOI4ow3fbzLnfyAOU5rIcIQjhF)(DPVVFol91s6L99ZkBkW0qDblyzXv4biPz7GdWEEbNkcNxJ1mizTBX99dnjaMnwZGxjz23OX1meKa4gUF5kEvu1bK64huZdG4KMEqjEvcM64h8T3fTbG4qfXDSUqnOMhazEndbRnlFnVHu06rJRX6gurbe(a5BlDa2azidwX6gCiwZGmJ1mOmwZCb18aiJghJFqnpacxXRIQoGuh)GV9UOnaehE07o4JtjjIRDnyTHu06rJRXp4BVl6zbfpqgK8zKOvdKb18aiJgxJFqkW0qDJghZqqg7Dx6o2fMUl11DXYDExOWqO66g8T3fTbG4cos(9JLq)9BlPeajOMhaHd9UOdsU6midoPeizSlcELKzFgaIdve3X6UiibWnCplO4bYhppDFXYWGuf7PacdaXfCK87hlH(73wsjasWcwwiBV3C5qSMbxf1WUFJFqTAID3ZpRXUiirL(CaegBPwbeXUW0D5MUUq15Hsq6hppDFCfVkQ6asDSMbPk2tbegaIdve3X6Ui4WwrmXqBdGKHGea3W9lxkGGbTIj)flumdoPeZRXUiOMhazg(azi4scatoacJT8634hSGL1SGIhid6)qs(WjrRgidsaCd3VgaIdve3X6Ui4KsmdFGyxeKa4gUFDIVo(b18aiiz8dwWYYPc1fKDx0Tmxca]] )


    ns.initializeClassModule = HunterInit

end
