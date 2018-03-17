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
local setRole = ns.setRole
local setTalentLegendary = ns.setTalentLegendary

local RegisterEvent = ns.RegisterEvent

local retireDefaults = ns.retireDefaults
local storeDefault = ns.storeDefault


local PTR = ns.PTR


if select( 2, UnitClass( 'player' ) ) == 'HUNTER' then

    local function HunterInit()
        setClass( 'HUNTER' )
        addResource( 'focus', SPELL_POWER_FOCUS )

        addTalent( 'a_murder_of_crows', 206505 ) -- MM, 131894
        addTalent( 'animal_instincts', 204315 )
        addTalent( 'aspect_of_the_beast', 191384 )
        addTalent( "barrage", 120360 ) -- 22002
        addTalent( "binding_shot", 109248 ) -- 22284
        addTalent( "black_arrow", 194599 ) -- 22497
        addTalent( 'butchery', 212436 )
        addTalent( 'caltrops', 194277 )
        addTalent( 'camouflage', 199483 )
        addTalent( "careful_aim", 53238 ) -- 22289
        addTalent( 'disengage', 781 )
        addTalent( 'dragonsfire_grenade', 2194855 )
        addTalent( 'expert_trapper', 199543 )
        addTalent( "explosive_shot", 212431 ) -- 22267
        addTalent( "farstrider", 199523 ) -- 19348
        addTalent( 'guerrilla_tactics', 236698 )
        addTalent( "lock_and_load", 194595 ) -- 22495
        addTalent( "lone_wolf", 155228 ) -- 22279
        addTalent( 'mortal_wounds', 201075 )
        addTalent( "patient_sniper", 234588 ) -- 21998
        addTalent( "piercing_shot", 198670 ) -- 22308
        addTalent( 'posthaste', 109215 )
        addTalent( 'rangers_net', 200108 )
        addTalent( "sentinel", 206817 ) -- 22286
        addTalent( 'serpent_sting', 87935 )
        addTalent( "sidewinders", 214579 ) -- 22274
        addTalent( 'snake_hunter', 201078 )
        addTalent( 'spitting_cobra', 194407 )
        addTalent( "steady_focus", 193533 ) -- 22501
        addTalent( 'steel_trap', 162488 )
        addTalent( 'sticky_bomb', 191241 )
        addTalent( 'throwing_axes', 200163 )
        addTalent( 'trailblazer', 199921 )
        addTalent( "trick_shot", 199522 ) -- 22288
        addTalent( "true_aim", 199527 ) -- 22498
        addTalent( "volley", 194386 ) -- 22287
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
                if spec.marksmanship then return 131894 end
                return x
            end )
            class.auras[ 131894 ] = class.auras[ 206505 ]

        addAura( 'aspect_of_the_cheetah', 186258, 'duration', 12 )
        addAura( 'aspect_of_the_cheetah_sprint', 186257, 'duration', 3 )
        addAura( 'aspect_of_the_eagle', 186289, 'duration', 10 )
        addAura( 'aspect_of_the_turtle', 186265, 'duration', 8 )
        addAura( 'butchers_bone_apron', 236446, 'duration', 30, 'max_stack', 10 )
        addAura( 'caltrops', 194279, 'duration', 6 )
        addAura( 'camouflage', 199483, 'duration', 60 )
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
        addAura( "true_aim", 199803, "duration", 10, "max_stack", 10 )
        addAura( "wyvern_sting", 19386, "duration", 30 ) -- Remove when hit.


        -- Auras: MM
        addAura( "bombardment", 35110, "duration", 5 )
        addAura( "binding_shot", 117405, "duration", 10 )
        addAura( "binding_shot_stun", 117526, "duration", 5 )
        addAura( "bullseye", 204090, "duration", 6, "max_stack", 30 )
        addAura( "bursting_shot", 224729, "duration", 4 )
        addAura( "concussive_shot", 5116, "duration", 6 )
        -- addAura( "eagle_eye", 6197 )
        addAura( "hunters_mark", 185365, "duration", 12 )
        -- addAura( "hunting_party", 212658 )
        addAura( "lock_and_load", 194594, "duration", 15, "max_stack", 2 )
        addAura( "marking_targets", 223138, "duration", 15 )
        -- addAura( "marksmans_focus", 231554 )
        -- addAura( "mastery_sniper_training", 193468 )
        addAura( "sentinels_sight", 208913, "duration", 20, "max_stack", 20 )
        addAura( "steady_focus", 193534, "duration", 12 )
        -- addAura( "t20_2p_critical_aimed_damage" ) -- need aura ID.
        addAura( "trueshot", 193526, "duration", 15 )
        addAura( "volley", 194386, "duration", 3600 )
        addAura( "vulnerability", 187131, "duration", 7 )
            class.auras.vulnerable = class.auras.vulnerability


        -- Gear Sets
        addGearSet( 'tier19', 138342, 138347, 138368, 138339, 138340, 138344 )
        addGearSet( 'tier20', 147142, 147144, 147140, 147139, 147141, 147143 )
        addGearSet( 'tier21', 152133, 152135, 152131, 152130, 152132, 152134 )

        addGearSet( 'talonclaw', 128808 )
        setArtifact( 'talonclaw' )

        addGearSet( 'thasdorah_legacy_of_the_windrunners', 128826 )
        setArtifact( 'thasdorah_legacy_of_the_windrunners' )

        addGearSet( 'butchers_bone_apron', 144361 )
        addGearSet( 'call_of_the_wild', 137101 )
        addGearSet( 'frizzos_fingertrap', 137043 )
        addGearSet( 'helbrine_rope_of_the_mist_marauder', 137082 )
        addGearSet( 'kiljaedens_burning_wish', 144259 )
        addGearSet( 'nesingwarys_trapping_threads', 137034 )
        addGearSet( 'prydaz_xavarics_magnum_opus', 132444 )
        addGearSet( 'roots_of_shaladrassil', 132466 )
        addGearSet( 'sephuzs_secret', 132452 )
        addGearSet( 'the_shadow_hunters_voodoo_mask', 137064 )

        addGearSet( 'soul_of_the_huntmaster', 151641 )
        addGearSet( 'celerity_of_the_windrunners', 151803 )
        addGearSet( 'parsels_tongue', 151805 )
        addGearSet( 'unseen_predators_cloak', 151807 )

        setTalentLegendary( 'soul_of_the_huntmaster', 'survival', 'serpent_sting' )
        setTalentLegendary( 'soul_of_the_huntmaster', 'marksmanship', 'lock_and_load' )


        addHook( 'specializationChanged', function ()
            --[[ if spec.marksmanship then setSpecialization( "marksmanship" )
            elseif spec.survival then setSpecialization( "survival" )
            else setSpecialization( "beast_mastery" ) end ]]
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



        -- ignoreCastOnReset( "fury_of_the_eagle" )



        local function genericHasteMod( x )
            return x * haste
        end

        setfenv( genericHasteMod, state )


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
            vuln_casts = function ()
                local rem = min( cooldown.sidewinders.full_recharge_time, debuff.vulnerability.remains )

                local casts = floor( rem / action.aimed_shot.cast )
                
                local regen = focus.current + ( focus.regen * rem )
                
                return min( casts, regen / ( action.aimed_shot.cost > 0 and action.aimed_shot.cost or 50 ) )
            end
        } )

        modifyAbility( 'aimed_shot', 'cast', genericHasteMod )


        addHandler( "aimed_shot", function ()
            -- proto
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
            min_range = 0,
            max_range = 47.171875,
        } )

        addHandler( "arcane_shot", function ()
            if buff.trueshot.up or buff.marking_targets.up then
                applyDebuff( "target", "hunters_mark" )
                removeBuff( "marking_targets" )
            end
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

        modifyAbility( "barrage", "cast", genericHasteMod )

        addHandler( "barrage", function ()
            -- proto
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

        addHandler( "bursting_shot", function ()
            applyDebuff( "target", "bursting_shot", 4 )
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
            -- proto
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
            usable = function () return active_dot.hunters_mark > 0 end
        } )

        addHandler( "marked_shot", function ()
            if debuff.hunters_mark.up then
                applyDebuff( "target", "vulnerable" )
                removeDebuff( "target", "hunters_mark" )
            end
            active_dot.vulnerable = active_dot.hunters_mark
            active_dot.hunters_mark = 0
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
        } )

        modifyAbility( "multishot", "spend", function( x )
            return x * active_enemies
        end )

        addHandler( "multishot", function ()
            if buff.marking_targets.up or buff.trueshot.up then
                applyDebuff( "target", "hunters_mark" )
                removeBuff( "marking_targets" )
                active_dot.hunters_mark = active_enemies
            end
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
        } )

        addHandler( "piercing_shot", function ()
            spend( min( focus.current, 80 ), "focus" )
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
            -- Track when cast. 
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
        } )

        modifyAbility( "sidewinders", "cooldown", genericHasteMod )
        modifyAbility( "sidewinders", "recharge", genericHasteMod )

        addCooldownMetaFunction( "sidewinders", "full_recharge_time", function( x )
            return ( cooldown.sidewinders.max_charges - cooldown.sidewinders.charges_fractional ) * cooldown.sidewinders.recharge
        end )

        addHandler( "sidewinders", function ()
            if buff.marking_targets.up or buff.trueshot.up then
                applyDebuff( "target", "hunters_mark" )
                active_dot.hunters_mark = active_enemies
                removeBuff( "marking_targets" )
            end
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
            return x - ts_qs_ranks[ artifact.quick_shot.rank ]    
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
            toggle = "artifact"
        } )

        modifyAbility( "windburst", "cast", genericHasteMod )

        addHandler( "windburst", function ()
            -- proto
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
            if spec.marksmanship then return 131894 end
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

    storeDefault( [[SimC Marksmanship: patient sniper]], 'actionLists', 20180317.155218, [[duKVJaqiiQwefsPlPuQ0MKunkLItPKAvuOWRukLzrHQUffs1UuvddQ6ykvlts5zOIW0OqY1OqLTHkI(MsIXrHIoNsPQwNsPkZdvu3JcX(qfoifyHGepujPlcs6KquMPsPIUjQYoLKHQuQWsHipvXuHqBvPKVsHu0BPqPUlfkzVK(lugSWHLAXq6XuzYsCzKntrFgv1ObXPbEni1SPQBRk7gLFty4qLLt0ZP00v56GA7kX3HGXJksNNcA9uifMpQ0(fTURiQduznQNkkQov9J0zaVvZGxlH2(AMfca32ldC9bi2LHLbWrsDqI8uBjTQg(DJjEoX(k)DDgCKd0EGrJ(acMwvZ4mkDmWDabZQiQv7kI6avwJ6PIcfDgNeG70Xje(Iab23ckecawHK2VjS3JjjhKwYNWoWJ0XauGhCgQZslbnQN0bzScW1NqQdtWiD4jkB1YQ(r6Sa7zyiayfbc6u1pshUott84DottJ9CcjLXwThMmwCL6yGKVvhw)iJSa7zyiayfbcgVaNrS0bmn(L2dtgXje(Iab23ckecawHK2VjS3JjjhKwYNWoWJm(L2dtyK3sgPqOWMM)fypJKnkWdod)s61aM14DcwbCabZix7j29TGcHaGviP9tSg1tL6oHWxeiW(wqHqaWkK0(nH9Emj5G0s(e2bEeNlekSP5Fb2ZizJc8GZWVKEnGz1bjYtTL0QA43xzhVoirwbS0rwfr90zviKdAEIf6rStr1HNOu1psh90QAkI6avwJ6PIcfDgNeG70PDhqW(n4rfmleX9xG9mmxBpRogGc8GZqDwAjOr9KoiJvaU(esDycgPdprzRww1psNfypdRbpmxBpRoirwbS0rwfr90PQFKoCDMM4X7CMMg75eskJTApmzS4kZyZ(ADmqY3QdRFKrwG9mSg8WCT9SgVaNrS0z8lThMms7oGG9BWJkywiI7Va7zyU2EwDqI8uBjTQg(9v2XRZarGaprbyciPvr1zviKdAEIf6rStr1HNOu1psh90koHIOoqL1OEQOqrNXjb4oDwAjOr90Fb2ZWqaWkceYGZz0Udiy)g8OcMfI4(U2Eyh4rzWLBglTe0OE6Va7zyiayfbczWrglTe0OE6Va7zyn4H5A7zZWyKr7oGG9BWJkywiI7tCk5Gpc7apkJTLbFxjJTLb()UogGc8GZqDwAjOr9KoiJvaU(esDycgPdprzRww1pshxZW47k6GezfWshzve1tNQ(r6W1zAIhVZzAASNtiPm2Q9WKXIRmJn1wRJbs(wDy9JmIRzy8DfJFP9WKrwAjOr90Fb2ZWqaWkce4C7oGG9BWJkywiI77A7HDGhXL7slbnQN(lWEggcawrGahlTe0OE6Va7zyn4H5A7zngT7ac2VbpQGzHiUpXPKd(iSd8OTX3v(VMt3g()UoirEQTKwvd)(k741zGiqGNOambK0QqrNvHqoO5jwOhXofvhEIsv)iD0tRmkfrDGkRr9urHIoJtcWD6CTKpD)d8iStGvaugCoJLwcAup9xG9mmeaSIaHmQNr7oWcHrm6biBggjJDDmaf4bNH64AVhRDhqWW8a7PdYyfGRpHuhMGr6Wtu2QLv9J0rNQ(r6W1zAIhVZzAASxT9(mmWDablJTtG9mwCL6yGKVvhw)iJy0oG3QzWRLqBFnZcbGB7LX1s(0vaKrRoirEQTKwvd)(k741bjYkGLoYQiQNoRcHCqZtSqpIDkQo8eLQ(r6mG3QzWRLqBFnZcbGB7LX1s(0vaKEALXPiQduznQNkku0zCsaUthNq4lceyFCas6am(ywiI7dJlJ6z0UdSqyeJEaYMHrYypJ6zSjJcHcBA(xG9ms2OE6dJlJ6zGcBA(xG9ms2OE6lPxdy2m4Cg7zSwhdqbEWzOo4aK0by8XSqeNoiJvaU(esDycgPdprzRww1pshDQ6hPZ2bGKoaJFgdeXPdsKNAlPv1WVVYoEDqIScyPJSkI6PZQqih08el0JyNIQdprPQFKo6PvCsfrDGkRr9urHIoJtcWD64ecFrGa7JdqshGXhZcrCFyCzupJ2DGfcJy0dq2m4iJ9mQNrHqHnn)lWEgjBup9HXLr9m2KXMmqEgOWMM)tctwiI7dJlJ6zykCW2Vdwkj2LbhzymXNr9m2KrHqHnn)lWEgjBup9L0RbmBgCoJ9m4YnJcHcBA(HaZosAXETe6pmUmwNX6m4YnJnzGcBA(pjmzHiUpmUmQNHPWbB)oyPKyxgCKXoEJlJ6zuiuytZ)cSNrYg1tFj9AaZMbNZGtMX6mwRJbOap4muhCas6am(ywiIthKXkaxFcPombJ0HNOSvlR6hPJov9J0z7aqshGXpJbI4YyZ(ADqI8uBjTQg(9v2XRdsKvalDKvrupDwfc5GMNyHEe7uuD4jkv9J0rpTAffrDGkRr9urHIoJtcWD60UdSqyeJEaYMbhzSNr9mU2tS7FsGdAmleX9jwJ6Psg1ZOqOWMM)fypJKnkWdod)s61aMndoYW12d7apkJ6zSjduytZVLyhGrElMfWhY9Tx7GodomsgT7alegXOhGSzymYW4YGl3mqHnn)wIDag5TywaFi33ETd6m2wgBYODhyHWig9aKnJTBg1YyDgCKrn8zWLBgBYWshgQGbB)hGK1WJvdNldoYaFg1Za5zGcBA(VA4XQHdZjbhW1ESg8OcwPFnF6dJlJ6zGtsl)g8OcMfI4YyDgC5MbkSP53lCqJ1ScMx0LpmUmQNr7oWcHrm6biBgCodorgR1XauGhCgQtdEubZcrC6Gmwb46ti1HjyKo8eLTAzv)iD0PQFKogaEujJbI40bjYtTL0QA43xzhVoirwbS0rwfr90zviKdAEIf6rStr1HNOu1psh90kJPIOoqL1OEQOqrNXjb4oDA3bwimIrpazZGJm21XauGhCgQZRLqtfmleXPdYyfGRpHuhMGr6Wtu2QLv9J0rNQ(r6WRLqtLmgiIthKip1wsRQHFFLD86GezfWshzve1tNvHqoO5jwOhXofvhEIsv)iD0tR2(kI6avwJ6PIcfDgNeG70PDhyHWig9aKndoYypJ6zSjduytZ)RLqdy8XUwYNo7hgxgC5MbkSP5)KWKfI4(W4YyTogGc8GZqDEW(dyHioDqgRaC9jK6WemshEIYwTSQFKo6u1pshEW(dy0hiIthKip1wsRQHFFLD86GezfWshzve1tNvHqoO5jwOhXofvhEIsv)iD0tR2XRiQduznQNkku0zCsaUtNLwcAup9xG9mSg8WCT9SzW5m2ZOEgipJLwcAup9XjeEaJpMPqIHdqshGXxhdqbEWzOoiayfuyP90bzScW1NqQdtWiD4jkB1YQ(r6Otv)iDmAcyfuyP90bjYtTL0QA43xzhVoirwbS0rwfr90zviKdAEIf6rStr1HNOu1psh90Q9DfrDGkRr9urHIoJtcWD6SjdKNXslbnQN(4ecpGXhZuiXWbiPdW4NbxUzuiuytZ)cSNrYg1tFj9AaZMbhzW3vYyDg1Zytgxl5t3)apc7eyfaLbhgjdNq4lceyzSTmkWY(acwgC5MX1s(09HqT)G8X5Um4Cg1WNbxUzCTKpD)d8iStGvaugCoJDozgRZOEglTe0OE6Va7zyn4H5A7zZWizGxhdqbEWzOon2dwwijMWeZjfiy1bzScW1NqQdtWiD4jkB1YQ(r6Otv)iDmidEWYcjZqyMXQsbcwDqI8uBjTQg(9v2XRdsKvalDKvrupDwfc5GMNyHEe7uuD4jkv9J0rpTAVMIOoqL1OEQOqrNXjb4oDA3bwimIrpazZGJmQLbxUzSjJRL8P7dHA)b5JZDzW5mQHpJ6zGcBA(rH9Elzi9Tx7GodoNrnJlJ16yakWdod1bTLYMpPdYyfGRpHuhMGr6Wtu2QLv9J0rNQ(r6aLwkB(KoirEQTKwvd)(k741bjYkGLoYQiQNoRcHCqZtSqpIDkQo8eLQ(r6ONwTZjue1bQSg1tffk6moja3PtHqHnn)lWEgjBuGhCg(HXLr9mqHnn)EHdASMvW8IU8HXLr9m2KbYZyPLGg1tFCcHhW4JzkKy4aK0by8ZGl3mkekSP5Fb2ZizJ6PVKEnGzZGJm47kzSwhdqbEWzOon4rfmleXPdYyfGRpHuhMGr6Wtu2QLv9J0rNQ(r6ya4rLmgiIlJn7R1bjYtTL0QA43xzhVoirwbS0rwfr90zviKdAEIf6rStr1HNOu1psh90QDJsruhOYAupvuOOZ4KaCNoT7alegXOhGSzWrg7zupJcHcBA(xG9ms2Oap4m8lPxdy2m4idItjh8ryh4rzupJnzG8mwAjOr90hNq4bm(yMcjgoajDag)m4YnJnzykCW2Vdwkj2LbhzSJhFg1ZOqOWMM)fypJKnkWdod)s61aMndoYytgeNso4JWoWJYyBzW3vYyDgRZyTogGc8GZqDAWJkywiIthKXkaxFcPombJ0HNOSvlR6hPJov9J0XaWJkzmqexgBQTwhKip1wsRQHFFLD86GezfWshzve1tNvHqoO5jwOhXofvhEIsv)iD0tR2nofrDGkRr9urHIoJtcWD60UdSqyeJEaYMbhzSNr9mwAjOr9031mm(Usg1ZWu4GTFhSusSlJTLHRThMK4tSm2wgT7ac2VbpQGzHiUVRThMK4tSm4CgMchS9)AonJ6zSjdKNXslbnQN(4ecpGXhZuiXWbiPdW4NbxUzuiuytZ)cSNrYgf4bNHFj9AaZMbhzW3vYyTogGc8GZqDEW(dyHioDqgRaC9jK6WemshEIYwTSQFKo6u1pshEW(dy0hiIlJn7R1bjYtTL0QA43xzhVoirwbS0rwfr90zviKdAEIf6rStr1HNOu1psh90QDoPIOoqL1OEQOqrNXjb4oDA3bwimIrpazZWizSNr9m2KbYZWshgQGbB)hGK1WJvdNldoYaFgC5MbYZODhqW(n4rfmleX9bmmtpGpKldUCZaf208F1WJvdhMtcoGR9yn4rfSs)A(0xsVgWSzWrgT7ac2VbpQGzHiUVRTh2bEugBld(UsgRZOEgBYyPLGg1t)fypdRbpmxBpBgCKb(m4YnJ2Dab7JaGvqHL27dyyMEaFixg1Za5zyPddvWGT)dqYA7ygfoxgCKb(mwNr9mwAjOr9031mm(Usg1ZWu4GTFhSusSlJTLHRThMK4tSm2wgT7ac2VbpQGzHiUVRThMK4tSm4CgMchS9)AonJ6zSjdKNXslbnQN(4ecpGXhZuiXWbiPdW4NbxUzuiuytZ)cSNrYgf4bNHFj9AaZMbhzW3vYyTogGc8GZqDAPRzeMfI40bzScW1NqQdtWiD4jkB1YQ(r6Otv)iDmq6AgLXarC6Ge5P2sAvn87RSJxhKiRaw6iRIOE6SkeYbnpXc9i2PO6WtuQ6hPJEA1(kkI6avwJ6PIcfDgNeG705ApXUVfuieaScjTFI1OEQKr9m2KrHqHnn)lWEgjBuGhCg(L0RbmBgCKHRTh2bEugC5MXMmqHnn)EHdASMvW8IU8lceyzupJ2Dab7JaGvqHL27dyyMEaFixgRZyDg1ZytglTe0OE6Va7zyiayfbczy0ZytgeNso4JWoWJYWyKXslbnQN(lWEgwdEyU2E2mwNbNZypdUCZWu4GT)czcCGldoBKmCT9WKeFILbxUzGcBA(pjmzHiUpmUmwNr9m2Kr7oWcHrm6biBggjJ9m4YndtHd2(DWsjXUm4iJD84ZyTogGc8GZqDAWJkywiIthKXkaxFcPombJ0HNOSvlR6hPJov9J0XaWJkzmqexgB4eR1bjYtTL0QA43xzhVoirwbS0rwfr90zviKdAEIf6rStr1HNOu1psh90QDJPIOoqL1OEQOqrNXjb4oDqEgx7j29TGcHaGviP9tSg1tLmQNXMmkekSP5Fb2ZizJc8GZWVKEnGzZGJmCT9WoWJYGl3m2KbkSP53lCqJ1ScMx0LFrGalJ6z0UdiyFeaSckS0EFadZ0d4d5YOEgBYa5zyPddvWGT)dqYA7ygfoxgCKb(m4YnJcHcBA(HaZosAXETe6FrGalJ1zSoJ1zupJnzG8mwAjOr90hNq4bm(yMcjgoajDag)m4YnJcHcBA(xG9ms2Oap4m8lPxdy2m4idItjh8ryh4rzSTm47kzSwhdqbEWzOon4rfmleXPdYyfGRpHuhMGr6Wtu2QLv9J0rNQ(r6ya4rLmgiIlJng1ADqI8uBjTQg(9v2XRdsKvalDKvrupDwfc5GMNyHEe7uuD4jkv9J0rpTAF7RiQduznQNkku0zCsaUthKNX1EIDFlOqiayfsA)eRr9ujJ6zSjJnzGcBA(9ch0ynRG5fD5dJlJ6zuiuytZ)cSNrYgf4bNH)IabwgRZGl3m2KXslbnQN(lWEggcawrGqgCoJ2Dab73GhvWSqe3312d7apkJ6zG8mwAjOr90hNq4bm(yMcjgoajDag)mQNXMmqEgT7ac2hbaRGclT3hWWm9a(qUm4YndlDyOcgS9FaswBhZOW5YGJmWNX6mQNXMm2KHPWbB)oyPKyxgCKbN04YGl3mqHnn)NeMSqe3hgxgC5MXMm2Zy7MrFx7GgdsBpkJ1zWrg7)A7RKbxUzSjJ9m2Uz031oOXG02JYyDgCKX(FFL9mQNHLomubd2(pajRHhZOW5YGJmWNX6m4YndlDyOcgS9FaswBhZOW5YGJmWNr9mqEgw6Wqfmy7)aKSgESA4CzWrg4ZyDgRZyTogGc8GZqDETeAQGzHioDqgRaC9jK6WemshEIYwTSQFKo6u1pshETeAQKXarCzSzFToirEQTKwvd)(k741bjYkGLoYQiQNoRcHCqZtSqpIDkQo8eLQ(r6ONwvdVIOoqL1OEQOqrNXjb4oDU2tS7BbfcbaRqs7NynQNkzupJnzS0sqJ6P)cSNH1GhMRTNndoNXEgC5MbkSP5)KWKfI4(W4YGl3mwAjOr90Fb2ZWqaWkceYGZz0Udiy)g8OcMfI4(U2Eyh4rzSwhdqbEWzOoVwcnvWSqeNoiJvaU(esDycgPdprzRww1pshDQ6hPdVwcnvYyGiUm2uBToirEQTKwvd)(k741bjYkGLoYQiQNoRcHCqZtSqpIDkQo8eLQ(r6ONwvBxruhOYAupvuOOZ4KaCNoMchS97GLsIDzSTmCT9WKeFILbhzykCW2)R50mQNbkSP53lCqJ1ScMx0LFrGalJ6zG8mqHnn)wIDag5TywaFi3hgNogGc8GZqDAWJkywiIthKXkaxFcPombJ0HNOSvlR6hPJov9J0XaWJkzmqexgBmU16Ge5P2sAvn87RSJxhKiRaw6iRIOE6SkeYbnpXc9i2PO6WtuQ6hPJEAvTAkI6avwJ6PIcfDgNeG70ztgipJcHcBA(HaZosAXETe6pmUm4YnJnzG8mqHnn)VwcnGXh7AjF6SFyCzupdKNbkSP5)KWKfI4(W4YyDgRZOEgBYytgOWMM)xlHgW4JDTKpD2pmUmQNXslbnQN(lWEgwdEyU2E2m4Cg7zSodUCZaf208FsyYcrCFyCzWLBgoiTKpzXmLT7acw7ZGJm2)B)mwRJbOap4muhlOqiayfsA1bzScW1NqQdtWiD4jkB1YQ(r6Otv)iDgqHqaWkK0QdsKNAlPv1WVVYoEDqIScyPJSkI6PZQqih08el0JyNIQdprPQFKo6Pv14ekI6avwJ6PIcfDgNeG70PDhyHWig9aKndJKXEg1ZytgipJLwcAup9XjeEaJpMPqIHdqshGXpdUCZOqOWMM)fypJKnkWdod)s61aMndoYGVRKXADmaf4bNH60sxZimleXPdYyfGRpHuhMGr6Wtu2QLv9J0rNQ(r6yG01mkJbI4YyZ(ADqI8uBjTQg(9v2XRdsKvalDKvrupDwfc5GMNyHEe7uuD4jkv9J0rpTQMrPiQduznQNkku0zCsaUtN2DGfcJy0dq2m4iJ9mQNXMmqEglTe0OE6Jti8agFmtHedhGKoaJFgC5MrHqHnn)lWEgjBuGhCg(L0RbmBgCKbFxjJ16yakWdod15b7pGfI40bzScW1NqQdtWiD4jkB1YQ(r6Otv)iD4b7pGrFGiUm2uBToirEQTKwvd)(k741bjYkGLoYQiQNoRcHCqZtSqpIDkQo8eLQ(r6ONE6moja3PJEQc]] )

    storeDefault( [[SimC Marksmanship: default]], 'actionLists', 20180317.155218, [[d8J5iaGorvTEbInHQyxKQTHQQ0(evXmrvIdR0SPY8vKUPiDxuv52k8mQQIDsu7fA3sTFjnkQQQHPOghQsY5rv50QmyjgoQCqH0PeiDmq1XrvsTqsPwQOYIPklNWIaf9ukldu65O8ysMQqmzqMUQUOG0vrvvCzKRluFJuYwPQYMjY2fWBrvQzjQsnnQQsZdvv1Njf)vugTi(UG6Kcu)g4AGc3tq8qQkhsuL8AfXiCmcAH2RNJGqp0K3bHMDdF1s6kMWgBZsoU8RfisAJDpA5ihTmcLHDgoVA2FGRLoC0mosDR7cY(hOrzyHH)Iwu1FGMHrqz4ye0cTxphbHAJMPeh3JgXRJpoocsNrCjXbHLXiLG(AHNA5xHg61HiVyjjD1Y(R1OhZvl8ulkaWbbc36EXss6mIljoiSmgPe0RhZvl8ul5vT4fljPZiUK4GWYyKsqVEmhAr9o398HMce3pjYyjGhTGBOtTpqGwdAcTuaKFRqEheAOjVdcnFG4(jrTyjGhTCKJwgHYWodxl4ZOLJyGyHIyye8rZxcPMKccqdQF0dTuaK8oi0WhLHfJGwO965iiuB0I6DU75dTygLDpnyOfCdDQ9bc0AqtOLcG8BfY7Gqdn5DqOnvjjnpRuss8M)WOAj4Ngm(nvGwoYrlJqzyNHRf8z0YrmqSqrmmc(O5lHutsbbOb1p6HwkasEheA4JY(dgbTq71ZrqO2OzkXX9OTQ)cqzutJJy1sEQfyRfEQfVyjj9aaNJ4thceUrlQ35UNp0caCoIp0cUHo1(abAnOj0sbq(Tc5DqOHMLacNcGoPJemuB0K3bHMFaNJ4dTOcnm0EGgnokeqJwoYrlJqzyNHRf8z0YrmqSqrmmc(O5lHutsbbOb1p6HwkasEheA4JY(lgbTq71ZrqO2OzkXX9O9RJ6xN7iH6AnzSeWRt965iOAHNArbaoiq4wN7iH6AnzSeWRlOXEnRw4)Abg1cp1ce5fljPhi21Ky9CKUGg71SAjp1IcaCqGWTo3rc11AYyjGxxqJ9AwTWtT4)AXlwss)fXelb86qGWDTmDATSQ)cqzutJJy1si1c8AjOOf17C3ZhAbwXTEocTGBOtTpqGwdAcTuaKFRqEheACaG7Anzsarg3rc11AqZsaHtbqN0rcgQnAY7GqBQssAEwPKK4T9abvl(TUyIFtfOfvOHHwVdkeoaWDTMmjGiJ7iH6An5DG1ftH8RJ6xN7iH6AnzSeWRt965iiEuaGdceU15osOUwtglb86cASxZ4FyWJdeMyFwGyxNf((KR1HrEM5XbctSplqSRZcFFY16WipkaWbbc36ChjuxRjJLaEDbn2Rz84FVyjj9xetSeWRdbc3tNUQ)cqzutJJyHapOOLJC0Yiug2z4AbFgTCedeluedJGpA(si1KuqaAq9JEOLcGK3bHg(OmmWiOfAVEocc1gTOEN7E(qtTox2Q(d0zUJ9OfCdDQ9bc0AqtOLcG8BfY7Gqdn5DqOnvjjnpRuss8236C1su1FGUw4LJ98BQaTOcnm06DqHat7g(QL0vmHn2MLCC5xlkaWbbc3myIwoYrlJqzyNHRf8z0YrmqSqrmmc(O5lHutsbbOb1p6HwkasEheA2n8vlPRycBSnl54YVwuaGdceUz4JY8xmcAH2RNJGqTrZuIJ7r7xh1Vo3(h1FgRposOt965ii0I6DU75dn16CzR6pqN5o2JwWn0P2hiqRbnHwkaYVviVdcn0K3bH2uLK08SsjjXBFRZvlrv)b6AHxo2ZVPIAX)WdkArfAyO17GcbM2n8vlPRycBSnl54YVw42)O(RfwFCKaMOLJC0Yiug2z4AbFgTCedeluedJGpA(si1KuqaAq9JEOLcGK3bHMDdF1s6kMWgBZsoU8RfU9pQ)AH1hhjWhL1cJGwO965iiuB0mL44E0YRA5xh1Vo3(h1FgRposOt965ii0I6DU75dn16CzR6pqN5o2JwWn0P2hiqRbnHwkaYVviVdcn0K3bH2uLK08SsjjXBFRZvlrv)b6AHxo2ZVPIAX)Wgu0Ik0WqR3bfcmTB4RwsxXe2yBwYXLFT0GUw42)O(RfwFCKaMOLJC0Yiug2z4AbFgTCedeluedJGpA(si1KuqaAq9JEOLcGK3bHMDdF1s6kMWgBZsoU8RLg01c3(h1FTW6JJe4JpAMsCCpA4Ji]] )

    storeDefault( [[SimC Marksmanship: precombat]], 'actionLists', 20180317.155218, [[dmdpcaGEkQAxIQ61cYSv08fv5Mu4UOqUnL2jv2lz3qTFQQggk9BGHsv0GPQmCiCqQshdsleKAPGyXkSCjEik6PQESipxOPkktwstxPlkGlJCDiADOqTvuWMfOTdkoSuFLIIPrrPVtrLLbQghfrJwqDAuDsqYZOkCnksopO0FPi13evElfHfQY0dG7XKQAO7AlPFULPFFgDju024yyocg73hIcLa2rV6qOj1rso4SOMK1d0C5JQFeuI3tU57LdWYb3uMv3BA5aCuzYHQm9a4EmPQGw37Gp5lS6rKwlaBAe0QdfUYt9ck6yaM0navg6IRTKUURTKoZEo97ZtA97dvhcnPosYbNfnhkRoekcqwsuuzA1zgMsHmaWqwcVAOBaQU2s6ALdUY0dG7XKQcADVd(KVWQJaSCawhkCLN6fu0XamPBaQm0fxBjDDxBj98sbdYYMsbdAcpblhGzuEfDi0K6ijhCw0COS6qOiazjrrLPvNzykfYaadzj8QHUbO6AlPRvopuMEaCpMuvqR7DWN8fwDZXX1bYsC1Hcx5PEbfDmat6gGkdDX1wsx31ws3mCCDGSexDi0K6ijhCw0COS6qOiazjrrLPvNzykfYaadzj8QHUbO6AlPRvR(tfoIvxRea]] )

    storeDefault( [[SimC Marksmanship: cooldowns]], 'actionLists', 20180317.155218, [[d4tjfaGEvc1MujQDHuBJcv2NkromI1PsiZwuZhi3uv6UuPQUns(la2ji7vA3OA)KmkvkgMq9BLUNkPgQkbgmPgoGoiaDkvkDmvXPP0cbflLISyv1Yr5HuGNsSmH45u1ZOsmvGAYcMUIlsH8kvc6YqxxfBKkvARuu2mvSDQKMgfkESiFguAEQK0HOqPXrHQgnO67uuDsQu(gf01ujX5fsRKkv8AvQElvQY9PGRyeN8ZyO)kqekSIyPmqPFjS7Ekc3d3c8Iu60U5WAo3xXeMrIhluK4hJp2LhdPFQiaXKLKTxmzSlVqrUIXubW0yxUVGl0tbxXio5NXqHPIKywGtfNnD80b0XMSJsFPRvAxIv6lR03O0gRspKmYhAVnGMB5bK5Pro5NXGsdcKsN2nhwZ50EBan3YdiZtNGtyWIEL(QkDeL(2ka(Tz7eTcHLiCeGzzmKpvCJhSjYSSk8LJvE3GzegeHcRubIqHvaKLiCuPbVmgYNkMWms8yHIe)y4tCftOFpSe6l4ovmaoMU)UUIuiF6VY7gGiuyLofksbxXio5NXqHPIKywGtL)XXHEyh0dFh6dWka(Tz7eTYhzEKD3YHTIB8GnrMLvHVCSY7gmJWGiuyLkqekScmiZJS7woSvmHzK4Xcfj(XWN4kMq)Eyj0xWDQyaCmD)DDfPq(0FL3narOWkDkKlfCfJ4KFgdfMksIzbov(hhh6HDqp8DOpaRa43MTt0k)8UbaCoSOvCJhSjYSSk8LJvE3GzegeHcRubIqHvGjVBqPD3dlAftygjESqrIFm8jUIj0Vhwc9fCNkgaht3FxxrkKp9x5DdqekSsNczmfCfJ4KFgdfMksIzbovUrP)hhh6HDqp8DOpav6lR0)JJd9pVBiF8d9bOsFRsdcKs)poo0)to7XOindjPrPVwPDjw5ova8BZ2jAfG7yxEf34bBImlRcF5yL3nygHbrOWkvGiuyfqjhN44uYXX9UGDSl39bXQycZiXJfks8JHpXvmH(9WsOVG7uXa4y6(76ksH8P)kVBaIqHv6uORuWvmIt(zmuyQijMf4uzSuOsFTshR0GaP0)JJd9pVBiF8d9bOsdcKsFJspegS4qpwkeGzbiyrL(sk9nkDA3CynNtpSd6HVdD4WiJD5aa7b9EL(cv6WHrg7Yv6Bv6BvAqGu6)XXH(FYzpgfPzijnk91kTlXkniqk9qyWId9yPqaMfGGfv6RQ0pgxfa)2SDIwzyh0dFNkUXd2ezwwf(YXkVBWmcdIqHvQarOWkGzh0dFNkMWms8yHIe)y4tCftOFpSe6l4ovmaoMU)UUIuiF6VY7gGiuyLoDQijMf4uPtla]] )

    storeDefault( [[SimC Marksmanship: non patient sniper]], 'actionLists', 20180317.155218, [[deuYtaqiLIAtkvnkQsofLQELsHywkfe3sPGAxezyqLJjjlti9mLc10ukIRbvvTnOQiFJsyCqvHZPuiToLcK5PuKUhuvAFcHdQuAHuIEiLuxKsYjPk1nLu7ejdvPaAPuvEkPPsvSvkv(QsbQ3Quq6UkfG9Q6VcAWO6WsTyO8yfnzjUmyZc8zQQgTqDAiVMOA2k52kSBe)gLHtuwofpNktx01rQTtP8DHOXdvvopuL1dvf18vQSFc)Q75QvKgBbLJDLQhWvfnSwWRBJC3OjUyKSnibNWicUSorajfChbjdmx9blODWPIIRcFGBJRSqQ6QkdMOEHWN7eXiNkk(Vjx3oteJ4UNtvDpxTI0ylOClVQtdswEn7fqsjhqsebwsaPXwqrW3l4Ej4y0bbsJ2ihr8hMTXpKojAzc(UDcogDqGuAObxmlLOLj42l47f8EMigrYbKerGL0OnYDHea)Yq)ZY1TyOfkX7QT2GASfC1Bsbn7KzUsye4AnRyxBO6bCnYgLiI)WaMj0bKerG1vFGJrBMG7EEELQhW1DZGaC4MZGGnunzgqWTRx0WgWoZ1Tg)URKEa4BKnkre)HbmtOdijIaRneB9IgW3SxajLCajreyjbKgBbL9EHrheinAJCeXFy2g)q6KOLTBhgDqGuAObxmlLOLz)(EMigrYbKerGL0OnYDHea)Yq)ZYvFWcAhCQO4QSOc3vnMfznRGcqGXDlVADmmLxZSbdGKh7AnRq1d46Ztf9EUAfPXwq5wEDlgAHs8Uc4NSfZHSbHUywE1Bsbn7KzUsye4AnRyxBO6bC9kvpGRwHFYwmhYgi4AmlV6dwq7GtffxLfv4U6dCmAZeC3ZZRwhdt51mBWai5XUwZku9aU(8uB89C1ksJTGYT8Qoniz51cGrheizJEratJHwOepjdmAeXj4ri44e89cEaBs7KM0gdqsbpcbVchURBXqluI3vziWmre)HUywE1Bsbn7KzUsye4AnRyxBO6bC9kvpGRBGiWmre)cUgZYR(Gf0o4urXvzrfUR(ahJ2mb3988Q1XWuEnZgmasESR1ScvpGRpp1MCpxTI0ylOClVQtdswETNjYgeceyGaNGhHGxj47f8cGrheizJEratJHwOepjdmAeXj4ri4Z2LHjAac(Eb3lbp7fqsP0GMYdDXSucin2ckc(UDcogDqG0InLh2Ks4I1fjAzcU9c(EbhJoiqYbKerGLl0H8hNsUSNYfC8vWJI76wm0cL4DTrdOe6Iz5vVjf0StM5kHrGR1SIDTHQhW1Ru9aUUfnGIGRXS8QpybTdovuCvwuH7QpWXOntWDppVADmmLxZSbdGKh7AnRq1d46ZtH)3ZvRin2ck3YR60GKLx7zISbHabgiWj4ri4vc(EbVay0bbs2OxeW0yOfkXtYaJgrCcEec(SDzyIgGGVxWZEbKuknOP8qxmlLasJTGIGVxWDqgIXi0oPebMO4cJkBk4ri44e89c(MfCm6GaPmkUWOYcNguIM9kSrdOew6r7hKOLj47f8EMigrQrdOe6IzPeIegSq(JZRBXqluI31gnGsOlMLx9MuqZozMRegbUwZk21gQEaxVs1d46w0akcUgZsb3Rk7V6dwq7GtffxLfv4U6dCmAZeC3ZZRwhdt51mBWai5XUwZku9aU(8u4t3ZvRin2ck3YR60GKLx7zISbHabgiWj4ri4vx3IHwOeVRJ2ihkHUywE1Bsbn7KzUsye4AnRyxBO6bC9kvpGR1TroueCnMLx9blODWPIIRYIkCx9bogTzcU755vRJHP8AMnyaK8yxRzfQEaxFEklUNRwrASfuULx1PbjlV2ZezdcbcmqGtWJqWRe89cUxcogDqG0OnYre)HzB8dPtIwMGVBNGJrheiLgAWfZsjAzcU9x3IHwOeVRd6vICXS8Q3KcA2jZCLWiW1AwXU2q1d46vQEaxRPxjAdRXS8QpybTdovuCvwuH7QpWXOntWDppVADmmLxZSbdGKh7AnRq1d46ZtHpUNRwrASfuULx1PbjlVUzbVay0bbsX0KemUWrBKlrl76wm0cL4D1bKerG1vVjf0StM5kHrGR1SIDTHQhW1Ru9aUQajreyD1hSG2bNkkUklQWD1h4y0Mj4UNNxTogMYRz2GbqYJDTMvO6bC95P2O3ZvRin2ck3YR60GKLxZ24hsPenGWKfwqGGhb(k4tgBvyrse8nIGxOnDIyebF3obpBJFiLIHELXsYMPGVPcEuCx3IHwOeVRD4G2uatiliCAyr6U6nPGMDYmxjmcCTMvSRnu9aUELQhW1TcEnTPagbNfi4wByr6U6dwq7GtffxLfv4U6dCmAZeC3ZZRwhdt51mBWai5XUwZku9aU(8uv4UNRwrASfuULx3IHwOeVRrIifmAJlV6nPGMDYmxjmcCTMvSRnu9aUELQhW1nyePGrBC5vFWcAhCQO4QSOc3vFGJrBMG7EEE16yykVMzdgajp21AwHQhW1NNQQ6EUAfPXwq5wEvNgKS8AptKnieiWabobpcbpQGVBNG7LGNTXpKsXqVYyjzZuW3ubpkobFVGJrheiHrVwoapqYL9uUGVPcEu8xWT)6wm0cL4DfRnM2pC1Bsbn7KzUsye4AnRyxBO6bC9kvpGRw2gt7hU6dwq7GtffxLfv4U6dCmAZeC3ZZRwhdt51mBWai5XUwZku9aU(8uvrVNRwrASfuULx1PbjlVIrheinAJCeXFy2g)q6KOLj472j4y0bbsPHgCXSuIw21TyOfkX76OnYHsOlMLx9MuqZozMRegbUwZk21gQEaxVs1d4ADBKdfbxJzPG7vL9x9blODWPIIRYIkCx9bogTzcU755vRJHP8AMnyaK8yxRzfQEaxFEQQn(EUAfPXwq5wEvNgKS86MfCBTb1ylqkYgLiI)WaMj0bKerGLGVxW9sWlagDqGumnjbJlC0g5sfwKebF3ob3lbhJoiqkn0GlMLsfwKebFVGJrheinAJCeXFy2g)q6KkSijcU9cU9c(Eb3lb3lbhJoiqA0g5iI)WSn(H0jrltW3TtWXOdcKsdn4IzPeTmb3EbF3obFg3g)GlmW0ZeXi9sWJqWRKWhcU9c(Eb3lbpGnPDsfianrPGhHGpBxgAa)arWT)6wm0cL4D1HkqKisbmUREtkOzNmZvcJaxRzf7AdvpGRxP6bCvrfisePag3vFWcAhCQO4QSOc3vFGJrBMG7EEE16yykVMzdgajp21AwHQhW1NNQAtUNRwrASfuULx1PbjlVM9ciPKdvGirKcyCsaPXwqrW3l4faJoiqYg9IaMgdTqjEsgy0iItWJqWNTldt0aUUfdTqjExB0akHUywE1Bsbn7KzUsye4AnRyxBO6bC9kvpGRBrdOi4AmlfCVIA)vFWcAhCQO4QSOc3vFGJrBMG7EEE16yykVMzdgajp21AwHQhW1NNQc)VNRwrASfuULx1PbjlVUzbp7fqsjhQarIifW4KasJTGIGVxWlagDqGKn6fbmngAHs8KmWOreNGhHGpBxgMObi47fCVe8nl42AdQXwGKmgBHi(ddyMqziWmre)c(UDcUxcogDqG0InLh2Ks4I1fjAzc(EbVay0bbs2OxeW0yOfkXtYaJgrCcEecU)zrWTxWTxW3l4Ej49mr2GqGade4e8nvWXFbF3obp7fqsP0GMYdDXSucin2ckc(UDcogDqGKdijIalxOd5poLCzpLl44RGhfNGB)1TyOfkX7AJgqj0fZYREtkOzNmZvcJaxRzf7AdvpGRxP6bCDlAafbxJzPG71gB)vFWcAhCQO4QSOc3vFGJrBMG7EEE16yykVMzdgajp21AwHQhW1NNQcF6EUAfPXwq5wEDlgAHs8UoAJCOe6Iz5vVjf0StM5kHrGR1SIDTHQhW1Ru9aUw3g5qrW1ywk4Ef1(R(Gf0o4urXvzrfUR(ahJ2mb3988Q1XWuEnZgmasESR1ScvpGRppvLf3ZvRin2ck3YR60GKLxdytAN0K2yask4BebF2Um0a(bIGhHGhWM0oPrJFc(EbFZcogDqGKdijIalxOd5poLOLDDlgAHs8U2ObucDXS8Q3KcA2jZCLWiW1AwXU2q1d46vQEax3IgqrW1ywk4ETj2F1hSG2bNkkUklQWD1h4y0Mj4UNNxTogMYRz2GbqYJDTMvO6bC95PQWh3ZvRin2ck3YR60GKLx7zISbHabgiWj4ri4vc(EbFZcUT2GASfifzJseXFyaZe6asIiW66wm0cL4DDqVsKlMLx9MuqZozMRegbUwZk21gQEaxVs1d4An9krBynMLcUxv2F1hSG2bNkkUklQWD1h4y0Mj4UNNxTogMYRz2GbqYJDTMvO6bC95PQ2O3ZvRin2ck3YR60GKLx7zISbHabgiWj44RGxj47f8nl42AdQXwGuKnkre)HbmtOdijIaRRBXqluI312mBce6Iz5vVjf0StM5kHrGR1SIDTHQhW1Ru9aUU1mBci4AmlV6dwq7GtffxLfv4U6dCmAZeC3ZZRwhdt51mBWai5XUwZku9aU(85vDAqYYRp)b]] )

    storeDefault( [[SimC Marksmanship: targetdie]], 'actionLists', 20180317.155218, [[dqJEeaGEQiAtqeTlKkBdPQAFurz2q6Mu42u1ofAVKDJY(rsdtjghsvAOuryWiLHlPCqkYXOsleIAPqyXk1YP0dLu9uWYOcpxWuvutgvtxQlQiwhsvCzvxxjDyrBfjSzjOTlrEgvK(ksv5ZsGVdr6BksNgQrljpwHtIennQO6AqeoVe1FLq)gXRPOwUAwWewUrpxBbX0Fba2xNknJ0Ao4twOcxJEOsRtBbV54laXrFgUIowCP3fN6oLoxbqTpWjk2jZgtyk6ajCUatJgtybnRORMfmHLB0ZfYcGHfxRfW)ETWcPR0kk72CJrXDz6wRjW0gJI7YcQHVDGzfumurAbuY44r2eRagHDbgeofPnM(lqqm9xGtGVDGzfqLgurAbio6ZWv0XI7u3fbiEGSAhpOz1cQx9HzdsP7pR1wGbHht)fOwrhAwWewUrpxilW0gJI7YcqkMX3R2qlGsghpYMyfWiSlWGWPiTX0FbcIP)cOpmJVxTHwaIJ(mCfDS4o1DraIhiR2XdAwTG6vFy2Gu6(ZATfyq4X0FbQv0PAwWewUrpxilagwCTwa)71clKUsROSBZngf3LPZEFIzbQ0CgvAJm0fBS)uPHKuP1PTG301y)l2KIC8PsZzuPnYqxSX(lW0gJI7YcsS)8IHkslGsghpYMyfWiSlWGWPiTX0FbcIP)cmH9NtLgurAbio6ZWv0XI7u3fbiEGSAhpOz1cQx9HzdsP7pR1wGbHht)fOwrNRzbty5g9CHSatBmkUllWNwZNxmurAbuY44r2eRagHDbgeofPnM(lqqm9xGrAnFovAqfPfG4OpdxrhlUtDxeG4bYQD8GMvlOE1hMniLU)SwBbgeEm9xGAfrcnlycl3ONlKfyAJrXDzbPDKSxmurAbuY44r2eRagHDbgeofPnM(lqqm9xGj7izNknOI0cqC0NHROJf3PUlcq8az1oEqZQfuV6dZgKs3FwRTadcpM(lqTI0VMfmHLB0ZfYcmTXO4USGaMFKIz8BdcOKXXJSjwbmc7cmiCksBm9xGGy6VaaZpsXm(Tbbio6ZWv0XI7u3fbiEGSAhpOz1cQx9HzdsP7pR1wGbHht)fOwTayyX1AbQLa]] )


    storeDefault( [[Survival Primary]], 'displays', 20171128.135411, [[d8t6haWyKA9QiVKcv7cjk2gfGFd1mPinnkOMTcNNkUPIkNgLVrb5ysPDsP9k2nj7hs(jKAyeACuG6YQAOemyiA4iCqPQJIeLoSKZrbYcLklfjSyQQLt0dLIEkyzuupNuturPMkIMmQy6kDrv4QuiEMIsCDvAJsHTQOK2mvz7q4JkkETIQ(ms67kYiPqzDuinAu14vrDsuPBrb01qICpKOQBtLwlsu54ueN2qgGUiwgw1aRwyDgFa0gH0uU2Ja0fXYWQgy1cStFSTMdilf1Vj)tpF6c4pyNonZapf)aoO980)2SiwgwPJvmWz0EE6FBweldR0XkgWK7FFoCPXkGD6J1WIbCzQ(JynhWK7FFonlILHv60fWbTNN(xYss9xDSIbOS3)(6qgBBidCOk)XZjDb6PxgwHcPPm9gRbfWwUFakU6I3OOqsiFASRFTbO4hFP)ynl2AiXwrXaaTKrSbwM7t5fZgR5qg4qv(JNt6c0tVmScfstz6nwdoGTC)auC1fVrrHKZ7v3XgGIF8L(J1SyRHeBffZMnGMhpbtSLMV)iDb084P(7Itxa36mqgBBGTKu)TxrZJLb6qtsIEok4oJXid4eRbA2aedCowXaAE8ezjP(RoDbM3VxrZJLbirlqb3zmgzaASRFTcioIFa6IyzyvVIMhld0HMKe9CbaINMvd2PAzyvSMPeLcO5Xtaz6cyY9V)SzYNEzyvak4oJXidOUUCPXkDSgoGM4hJgJsZ3epWYqgOITnGm22auJTnGFSTzdO5XtnlILHv60f4mApp9V9xzfRyG6klshIpG)1ZlGBDU)U4yfdudc(QFmvoAbehX2gOge8fWJNeqCeBBGAqWxnXU(1kG4i22aZ(9Q7ytxGAmvoAbecPlacMM5ZgS1H0H4d4hGUiwgw1pyuvbAEyjpOiahMMyuoKoeFGkGSuuFshIpq5ZgS1jqDL1Cm1NUaMCz0ZpRmnSoJpqfyE)gy1cStFSTMdyl3paCLiyiQbkKcsMBjDcudc(ISKu)vaHqSTbCq75P)LRIdJUwSuhRya5pc08WsEqranXpgngLMp(bQbbFrwsQ)kG4i22amfhgDTyzVIMhldqb3zmgzatU)95WvXHrxlwQtxaxMQ)U4yfduxz1RO5XYaDOjjrpNPhnidSLK6VnWQfwNXhaTrinLR9iWC1zM71ffssM7h7SigqZJNGj2sZ3FxC6ca0sgXgiqni4R(Xu5OfqieBBG6klUkpmPdXhW)65fGqYClPtdSAb2Pp2wZbiKpn21V2Ebtdam3MOqcxjcgIAyuuijKpn21V2aAE8u)vwCvE44hWTo3FeRyaYA8QffYzK4lrSIb2ss9xbehXpaf)4l9hRzXwdjAaMPeLP1GOKzdBOacsMBjDqHSzrSmSkGwwldhGZ7v3X2lyAaG52efs4krWqudJIcjN3RUJnGdApp9VgVthRb2g4mApp9VKLK6V6yfdmVFdSAH1z8bqBest5Apc4G2Zt)B)vwXkgqZJN4Q4WORfl1Plqni4lGhpjGqi22a1yQC0ciosxG6klG4hdUZowZITIgCBanpEsaXr6cqJD9RvaHq8dmVFdSAdiqIcjuknkK2skXtb084P(J0fqZJNeqiKUaUmfqgRyGTKu)TbwTa70hBR5aNr75P)14D6yfdqxeldRAGvBabsuiHsPrH0wsjEkqni4RMyx)AfqieBBGdv5pEoPlGM5sm(E0hXAoG)GD60md8u)ye)aEy1g44mH816PYjWwsQ)kGqi(bm5(3VFWOQCF1gGoGMhpz83XNP4Wuu1PlGGK5wshuiBweldRqHS)kRaZHvuXy9JczJR0jaHK5wshU0yfWo9XAyXamAScikAMIASukaJgROCySBSZIyatU)950aRwGD6JT1CGTKu)TbwTbeirHekLgfsBjL4PaMC)7ZX4D60f4mApp9VCvCy01IL6yfduxzzefBdqmkNxMnba]] )

    storeDefault( [[Survival AOE]], 'displays', 20171128.135411, [[dee7haqiIe1MubPBPcIDbjfdtkoMcwgQ0ZisY0if5Aqs2gKu5BKcghKu6Cej16is5Eej0bLslurEivvtufuxuH2ivLpQcmssHojr8ssrntsj3ufYoP0pHOHsQokKu1svr9uWurYvjs1wjsWAjsK9kgmK6Wswmr9yKAYOIlRQntfFgHgnQ60O8AvOMTuDBQYUj8BOgoIooPulNINtY0v66Q02HW3vuJhsCEQ06vr2pcodHkaDrUmSWhwSW62)aiLoLwsSJbOlYLHf(WIfyN(yh4gWucIVF(N(4mfqUZoD6GoEoYbCr64O(1FrUmSqfBtauq64O(1FrUmSqfBtaTV)95iHgla2Ppwn1eWJjAhJLBaTV)954VixgwOYuaxKooQFPkdXFvX2ea1F)7RcvSdHkWOOK7pNmfOLEzybb0AXuBSsDaB59boFvfV0iGM080yp5AdC(7FP(y52mOHMHMMaaTHrUbwM3lfBYgl3qfyuuY9NtMc0sVmSGaATyQnwuBaB59boFvfV0iGMZ7u3(g483)s9XYTzqdndnnzZgqXJNHz2sZ3oMPaOG0Xr9lvzi(Rk2MamASailAMGySOkWwgI)2kO5XMatiPOqE0zjhOrQaUXEiChqvauITjGIhptvgI)QYuGJLBf08ytakK6NLCGgPcqJ9KRvhXyKdqxKldlAf08ytGjKuuipkaq(0SQZovldlILlQqvafpEgOYuaTV)9pmZ80ldlcCwYbAKkG46jHgluXQPakYV391lfVFChBcvGk2HaMyhcqm2HaYXoKnGIhp7VixgwOYuauq64O(T9AQyBcuxtr5s(bKVoob8kuAVlo2MavNKVA7ZLRshXySdbQojFb84zDeJXoeO6K8LFSNCT6igJDiWHFN623mfO6ZLRshHEMcGGPyYSoBDPCj)aYbOlYLHfTDgrra)JwQXZb4WuK9YLYL8dqhWucIpLl5hOKzD26gOUM6iM4ZuaTVm6JLcmfSU9pqf4yzFyXcStFSdCdylVpaCniyiQob0TihdOByELXLaA)f5YWccOBVMkWrybrmw9eq77ACd4XeT3fhl3aMVhW)OLA8Caf537(6LIpYbQojFrvgI)QJym2HaUiDCu)krWHrxl2OITjG23)(CKi4WORfBuzkGIhpdZSLMV9U4mfOUMQvqZJnbMqsrH8iTg9rfyldXF9HflSU9pasPtPLe7yGJkuyExpcOPyEFSsvtaVcfGk2MaaTHrUbumbX(FOs56U4avNKVA7ZLRshHESdbQRPKiCWuUKFa5RJtasdZRmU(WIfyN(yh4gG080yp5AB11kaW88tanCniyiQU0iGM080yp5AdO4XZT3fh5aEfkTJX2eGQ6VyjG(ad(sgBtGTme)vhXyKdOByELXLaA)f5YWIaktTmCafpEwZVRmtWHjiQYuaoVtD7BRUwbaMNFcOHRbbdr1Lgb0CEN623aUiDCu)Q5jvShYqGTme)1hwSb0PiGgkHIaABzm45ahl7dlwyD7FaKsNslj2XaUiDCu)2EnvSnbu84zjcom6AXgvMcuDs(c4XZ6i0JDiq1NlxLoIXmfOUMci)ExYHJTjGIhpRJymtbOXEY1QJqpYbow2hwSb0PiGgkHIaABzm45akE8C7yKdO4XZ6i0ZuapMaOILBGTme)1hwSa70h7a3aOG0Xr9RMNuXoeGUixgw4dl2a6ueqdLqraTTmg8CGQtYx(XEY1QJqp2HaJIsU)CYuafZJS)TihJLBa5o70Pd6452EpYb0((3VTZik8EXgGoWwgI)QJqpYbQojFrvgI)QJqp2HaN)(xQpwUndAOb1XfvOMbPgvC1KgcqAyELXvcnwaStFSAQjatWHrxl20kO5XMaNLCGgPcO4XZTxtjr4GJCagnwiLWyVyLQMaAF)7ZXhwSa70h7a3aoyXgyefsZRuZLBaTV)95O5jvMcGcshh1VseCy01InQyBcuxtjDbBdq2l33Knb]] )

    storeDefault( [[Marksmanship Primary]], 'displays', 20180317.155218, [[d0duiaGEqXlrsAxui61eKzsqDyjZwrFJcHUPukxJc1TvONtYoP0Ef7gv7NQ0pvrdtQmoQI4YknukAWsjdhPoOc(msCmP44Quwiv1srsTyQ0Yj6HurpfAzQuzDuizIsPAQGmzvy6Q6IQKRIK4zQu11r0gPGTsHGntOTtGpsf6Rui10Oc(Uu1iPkmwQIQrJW4bLojO6wufLttQZJspgfRLQi9BGttGcYu0VgWna4p(SZn4jvGegU9k4xsk7BkWmUbLfNY6Kyzek(bDNAyGXXjOpUbzpffv77SOFnGRITliSNIIQ9Dw0VgWvX2fCuZhUI9(G3ixY9Wzr)Aaxf)GWY6eWfSYFpIFq2trr1(qLKY(Qy7cQia9yV(zigUIFqfbOFG8bXpOIa0J96NHyG8bXp4xsk7pWziaYG(NqqNTrnCh9akiSNIIQ9PQVk2MGIa(h0eYBlS4kVTSLuc6dYEkkQ2V9DwSX2fe2trr1(TVZIn2UGkcqpujPSVk(bfYDGZqaKbHonPgUJEaf8g5sUhWzaCJwF8eXACxqAPESKSWzaCpwnfIpwJ7cARXnyBLui1yXveAAVTmL6XsYguZp0m1dKdCgcGmi1WD0dOGAga3hipwz8dYu0VgWh4meazq)tiOZ2cEJCj3dQ6RIFqKEz01udt9Aap27m2HGkcqpcf)G3ixYTDTCzEnGhKA4o6buqo5iCgaxf79bzJ1ZU7oJdcBSDbv07CAywkcNGjqgOGvSnbLX2eKsSnbDJTjFqfbO3zr)Aaxf3GuDx6bf9Y8uxVge)GfPSGyP3GUKIIbRjnrHeGEtbMX2euZa4iDXO5uI14GJfSdKpi2UGUtnmW44e0pmNXnynPjkKa0Bk4k2MG1KMOCcgDR3uWvSnbBFflY5h3Gc5AaW)GMqEBHfx5TLTKsqFWA2xSktbMXpOaTs7QN6NfILEd6gKPOFnGpm1u4bDEzHUOo4Hwrplwiw6n4rWIuwW5Iaiw6nOlPOyqzXPSqS0BWYvp1pBWIuwTP5B8dEJCj3bodbqgKA4o6buqHCna4pQHzJTXHGmf9RbCda(JAy2yBCiynPjkOsszFtbMX2eSM0e1WSVyvMcUITjOCNbDEzHUOoOIENtdZsre3G1KMOGkjL9nfCfBtWBKl5EaNFOzQhivXpOqUga8hF25g8Kkqcd3EfKbm6wVPGR4g8yNfRba)XNDUbpPcKWWTxb)sszFda(Jp7CdEsfiHHBVcESZIDGZqaKbHonf(YauWBKl5Ip7CdsnCh9ak4Xolwda(JAy2yBCiynPjQHzFXQmfygBtWAstuobJU1BkWm2MG0s9yjzna4pQHzJTXHG0YLbm6w)GPWbr9OtVTARKcPglUIqtBuEBrlxgWOB9bPENBP2G3114jD33yenYMGJfSdxX2fuZa4(a5XkDcMazGcwX2eugBxqkX2f0n2U8b)sszFtbxXnOIa0t1L1vZp0CkQ4hura6nfyg)Gh7Syna4FqtiVTWIR82YwsjOpOIa03(ol2GqxEouq2trr1(dKYk2UGWEkkQ2FGuwX2fSiL1aNHaid6FcbD2MWxgGcQia9W5hAM6bsv8dYEkkQ2ho)qZupqQITlyn7lwLPGR4hura6nfCf)Gkcq)Wv8dYagDR3uGzCdQia9dKYcoxee3GWEkkQ2hQKu2xfBxWVKu23aG)bnH82clUYBlBjLG(GJAocfBxWVKu23aG)OgMn2ghcEJCj3bodbqEkkQ2pwJdYu0VgWna4FqtiVTWIR82YwsjOpyrklKENt4ThBxWlE5o3J4huPhPN7W5vS3fu4s9obCbRuPb8yVRRXt6AACWiVp4nsnJqgbTcF25gScEJCj3HPMcFC5FqMG3ixY9aodG7XQPq8XACxqypffv7dNFOzQhivX2fCSGfHITji7POOAFQ6RI1ZAc6PaWOtaxWk)9i(b1maUNcaJXEFxWBKl5EyaWFudZgBJdbpwXIC(dMche1Jo92QTskKAS4kcnTr5T1XkwKZpiTupwsw4maUrRpEIynUl4OMpq(Gy7cwKYIkC9hKEwSRmFca]] )

    storeDefault( [[Marksmanship AOE]], 'displays', 20180317.155218, [[d0dtiaGEvQEjbYUiq1RjiZKG6WsMTcJJKc3KQORjvYTvHNtQDsP9k2nQ2pvPFQidtk9BGlR0qPIblvmCuCqP4ZiXXOQoUkLfQOwkbSysSCIEivQNcTmsQADKuYeLk1ubzYQKPRQlQIUkOQEgOkxhrBKKSvcuSzcTDK0hPk8vskAAuj9DPQrsLySeO0Ory8GkNeuUfjvCAkopk9yKATKuQVrsLo(bkiDX8gaxfG)4Zo2GtWhsyy2ZGFjPSVdvNOeuwCkRBILwOmhuzyUF3JbOpkbzNef177UyEdGRJTniCtII69DxmVbW1X2g8WWBoJfEbVrUK7L7I5naUoZbHJ1nGtDL)EL5GStII69HkjL91X2guta6XEZtt0CgLGAcqFd5dIsqnbOh7npnrd5dYCWVKu2VHttaKbNNGGM8uayE4cuq4Mef17lOzDS(bfb8pOdK3oyX1E7ylPe0hKDsuuVF37OyJTniCtII697EhfBSTb1eGEOsszFDMdkKsdNMaidcn5iampCbk4nYLCVGrd4QP56jITR2GmsZrjzHrd4USgkeFSD1g0whBqplPq6JIRjmmE70mDg0WVm01dKnCAcGmOaW8WfOGgAaFgiVwzMdsxmVbWB40eazW5jiOjpdEJCj3lbnRZCqKzPn1WCVEdGhR67Y1GAcqpcL5G3ixYTBJCPFdGhuayE4cuqo5bmAaxhl8cYgR64RUTbHl22GAMDmunknHBWaiduWkw)GYy9dsjw)GkX6NpOMa07UyEdGRJsqbTltJMzPFbQ3aYCWIuwqSmBqfsrXG1GHOqcqVdvNy9dAObCKPOnCkX2vWJcUgYheBBqLH5(DpgG(MXikbRbdrHeGEhQNX6hSgmeLBWHs9oupJ1py3Ryro(Oeuifva(h0bYBhS4AVDSLuc6dwJ(Iv7q1jZbPA0gfZW8SqSmBqLG0fZBa8MHHcpO7tl0PabVmAMrXcXYSbPdwKYcgxeaXYSbviffdkloLfILzdwkMH5zdwKYYtdFZCWBKl52WPjaYGcaZdxGckKIka)rZ9nwFxdsxmVbWvb4pAUVX67AWAWquqLKY(ouDI1pynyiQMrFXQDOEgRFq5oc6(0cDkqqnZogQgLMikbRbdrbvsk77q9mw)G3ixY9cg)YqxpqQZCqHuub4p(SJn4e8HegM9min4qPEhQNrj41okwva(Jp7ydobFiHHzpd(LKY(Qa8hF2XgCc(qcdZEg8AhfBdNMaidcn5i8PkOG3ixYfF2XguayE4cuWRDuSQa8hn33y9DnynyiQMrFXQDO6eRFWAWquUbhk17q1jw)GmsZrjzvb4pAUVX67Aqg5sdouQVXr4GO5WT3oEwsH0hfxtyyulVDyKln4qP(GcSJT0Bq136RgTWZxDfC)GhfCnNX2g0qd4Za51kDdgazGcwX6hugBBqkX2guj228b)sszFhQNrjOMa0lOLvXWVmCk6mhuta6DO6K5Gx7Oyvb4FqhiVDWIR92XwsjOpOMa039ok2GqNcwOGStII69BiLvSTbHBsuuVFdPSITnyrkRgonbqgCEccAYtHpvbfuta6HXVm01dK6mhKDsuuVpm(LHUEGuhBBWA0xSAhQNzoOMa07q9mZb1eG(MZOeKgCOuVdvNOeuta6BiLfmUiikbHBsuuVpujPSVo22GFjPSVka)d6a5TdwCT3o2skb9bpmCek22GFjPSVka)rZ9nwFxdEJCj3gonbqojkQ3p2UcsxmVbWvb4FqhiVDWIR92XwsjOpyrklKzhdyDhBBWtEPm2RmhuBoygBZ0zSQpOWL(Dd4uxP2a4XQ(wF1O133vbhEbVrAOfsWy04Zo2GkbVrUKBZWqHFS8piDWBKl5EbJgWDznui(y7QniCtII69HXVm01dK6yBdEuWHqX6hKDsuuVVGM1XQo(bvBa4WnGtDL)EL5GgAaxTbGJyHxBWBKl5EPcWF0CFJ131GxRyro(ghHdIMd3E74zjfsFuCnHHrT825AflYXhKrAokjlmAaxnnxprSD1g8WWBiFqSTblszbFU5dYmk2vMpb]] )


    ns.initializeClassModule = HunterInit

end
