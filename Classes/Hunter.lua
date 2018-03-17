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

        addTalent( 'animal_instincts', 204315 )
        addTalent( 'throwing_axes', 200163 )
        addTalent( 'way_of_the_moknathal', 201082 )

        addTalent( 'a_murder_of_crows', 206505 )
        addTalent( 'mortal_wounds', 201075 )
        addTalent( 'snake_hunter', 201078 )

        addTalent( 'posthaste', 109215 )
        addTalent( 'disengage', 781 )
        addTalent( 'trailblazer', 199921 )

        addTalent( 'caltrops', 194277 )
        addTalent( 'guerrilla_tactics', 236698 )
        addTalent( 'steel_trap', 162488 )

        addTalent( 'sticky_bomb', 191241 )
        addTalent( 'rangers_net', 200108 )
        addTalent( 'camouflage', 199483 )

        addTalent( 'butchery', 212436 )
        addTalent( 'dragonsfire_grenade', 2194855 )
        addTalent( 'serpent_sting', 87935 )

        addTalent( 'spitting_cobra', 194407 )
        addTalent( 'expert_trapper', 199543 )
        addTalent( 'aspect_of_the_beast', 191384 )


        addTrait( "aspect_of_the_skylord", 203755 )
        addTrait( "bird_of_prey", 224764 )
        addTrait( "concordance_of_the_legionfall", 239042 )
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


        -- Buffs/Debuffs
        addAura( 'a_murder_of_crows', 206505, 'duration', 15 )
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


        -- Gear Sets
        addGearSet( 'tier19', 138342, 138347, 138368, 138339, 138340, 138344 )
        addGearSet( 'tier20', 147142, 147144, 147140, 147139, 147141, 147143 )
        addGearSet( 'tier21', 152133, 152135, 152131, 152130, 152132, 152134 )

        addGearSet( 'talonclaw', 128808 )
        setArtifact( 'talonclaw' )

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

        addHook( 'specializationChanged', function ()
            setPotion( 'old_war' ) -- true for Sv, anyway.
            setRole( 'attack' )
        end )


        local floor = math.floor

        addHook( 'advance', function( t )
            if not state.talent.spitting_cobra.enabled then return t end

            if state.buff.spitting_cobra.up then
                local ticks_before = floor( state.buff.spitting_cobra.remains )
                local ticks_after = floor( max( 0, state.buff.spitting_cobra.remains - t ) )
                local gain = 3 * ( ticks_before - ticks_after )

                state.gain( gain, 'focus' )
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


        --[[ addToggle( 'artifact_ability', true, 'Artifact Ability',
            'Set a keybinding to toggle your artifact ability on/off in your priority lists.' )

        addSetting( 'artifact_cooldown', true, {
            name = "Artifact Ability: Cooldown Override",
            type = "toggle",
            desc = "If |cFF00FF00true|r, when your Cooldown toggle is |cFF00FF00ON|r then the toggle for your artifact ability will be overridden and your artifact ability will be shown regardless of its toggle above.",
            width = "full"
        } ) ]]

        addSetting( 'moknathal_padding', true, {
            name = "Way of the Mok'Nathal Padding",
            type = "toggle",
            desc = "If checked, the addon will save an internal buffer of 25 Focus to spend on Raptor Strike for Mok'Nathal Tactics stacks.",
            width = "full"
        } )

        --[[ addSetting( 'spend_apron_stacks', false, {
            name = "Survival: Spend Butcher's Bone Apron Stacks in Single Target",
            type = "toggle",
            desc = "If |cFF00FF00true|r and you are wearing Butcher's Bone Apron, the addon may recommend Carve or Butchery in single-target situations if you reach maximum stacks (10) of the buff.  " ..
                "This may avoid wasting stacks, but can also cause you to spend stacks in single-target when you would've rather saved them for an upcoming AOE / add-phase.  You may want to re-evaluate " ..
                "this setting on a per-fight basis.",
            width = "full",
        } ) ]]
        
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
            usable = function () return not pet.exists end
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
            -- NYI: Also heal pet.
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
        } )

        modifyAbility( 'a_murder_of_crows', 'ready', function( x )
            if not talent.way_of_the_moknathal.enabled or not settings.moknathal_padding then
                return x
            end

            local ticks = floor( ( buff.moknathal_tactics.remains - refresh_window ) / focus.tick_rate )
            return x + max( 0, 25 - floor( focus.regen * ticks * focus.tick_rate ) ), "focus"
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


    storeDefault( [[Survival Primary]], 'displays', 20171128.135411, [[d8t6haWyKA9QiVKcv7cjk2gfGFd1mPinnkOMTcNNkUPIkNgLVrb5ysPDsP9k2nj7hs(jKAyeACuG6YQAOemyiA4iCqPQJIeLoSKZrbYcLklfjSyQQLt0dLIEkyzuupNuturPMkIMmQy6kDrv4QuiEMIsCDvAJsHTQOK2mvz7q4JkkETIQ(ms67kYiPqzDuinAu14vrDsuPBrb01qICpKOQBtLwlsu54ueN2qgGUiwgw1aRwyDgFa0gH0uU2Ja0fXYWQgy1cStFSTMdilf1Vj)tpF6c4pyNonZapf)aoO980)2SiwgwPJvmWz0EE6FBweldR0XkgWK7FFoCPXkGD6J1WIbCzQ(JynhWK7FFonlILHv60fWbTNN(xYss9xDSIbOS3)(6qgBBidCOk)XZjDb6PxgwHcPPm9gRbfWwUFakU6I3OOqsiFASRFTbO4hFP)ynl2AiXwrXaaTKrSbwM7t5fZgR5qg4qv(JNt6c0tVmScfstz6nwdoGTC)auC1fVrrHKZ7v3XgGIF8L(J1SyRHeBffZMnGMhpbtSLMV)iDb084P(7Itxa36mqgBBGTKu)TxrZJLb6qtsIEok4oJXid4eRbA2aedCowXaAE8ezjP(RoDbM3VxrZJLbirlqb3zmgzaASRFTcioIFa6IyzyvVIMhld0HMKe9CbaINMvd2PAzyvSMPeLcO5Xtaz6cyY9V)SzYNEzyvak4oJXidOUUCPXkDSgoGM4hJgJsZ3epWYqgOITnGm22auJTnGFSTzdO5XtnlILHv60f4mApp9V9xzfRyG6klshIpG)1ZlGBDU)U4yfdudc(QFmvoAbehX2gOge8fWJNeqCeBBGAqWxnXU(1kG4i22aZ(9Q7ytxGAmvoAbecPlacMM5ZgS1H0H4d4hGUiwgw1pyuvbAEyjpOiahMMyuoKoeFGkGSuuFshIpq5ZgS1jqDL1Cm1NUaMCz0ZpRmnSoJpqfyE)gy1cStFSTMdyl3paCLiyiQbkKcsMBjDcudc(ISKu)vaHqSTbCq75P)LRIdJUwSuhRya5pc08WsEqranXpgngLMp(bQbbFrwsQ)kG4i22amfhgDTyzVIMhldqb3zmgzatU)95WvXHrxlwQtxaxMQ)U4yfduxz1RO5XYaDOjjrpNPhnidSLK6VnWQfwNXhaTrinLR9iWC1zM71ffssM7h7SigqZJNGj2sZ3FxC6ca0sgXgiqni4R(Xu5OfqieBBG6klUkpmPdXhW)65fGqYClPtdSAb2Pp2wZbiKpn21V2Ebtdam3MOqcxjcgIAyuuijKpn21V2aAE8u)vwCvE44hWTo3FeRyaYA8QffYzK4lrSIb2ss9xbehXpaf)4l9hRzXwdjAaMPeLP1GOKzdBOacsMBjDqHSzrSmSkGwwldhGZ7v3X2lyAaG52efs4krWqudJIcjN3RUJnGdApp9VgVthRb2g4mApp9VKLK6V6yfdmVFdSAH1z8bqBest5Apc4G2Zt)B)vwXkgqZJN4Q4WORfl1Plqni4lGhpjGqi22a1yQC0ciosxG6klG4hdUZowZITIgCBanpEsaXr6cqJD9RvaHq8dmVFdSAdiqIcjuknkK2skXtb084P(J0fqZJNeqiKUaUmfqgRyGTKu)TbwTa70hBR5aNr75P)14D6yfdqxeldRAGvBabsuiHsPrH0wsjEkqni4RMyx)AfqieBBGdv5pEoPlGM5sm(E0hXAoG)GD60md8u)ye)aEy1g44mH816PYjWwsQ)kGqi(bm5(3VFWOQCF1gGoGMhpz83XNP4Wuu1PlGGK5wshuiBweldRqHS)kRaZHvuXy9JczJR0jaHK5wshU0yfWo9XAyXamAScikAMIASukaJgROCySBSZIyatU)950aRwGD6JT1CGTKu)TbwTbeirHekLgfsBjL4PaMC)7ZX4D60f4mApp9VCvCy01IL6yfduxzzefBdqmkNxMnba]] )

    storeDefault( [[Survival AOE]], 'displays', 20171128.135411, [[dee7haqiIe1MubPBPcIDbjfdtkoMcwgQ0ZisY0if5Aqs2gKu5BKcghKu6Cej16is5Eej0bLslurEivvtufuxuH2ivLpQcmssHojr8ssrntsj3ufYoP0pHOHsQokKu1svr9uWurYvjs1wjsWAjsK9kgmK6Wswmr9yKAYOIlRQntfFgHgnQ60O8AvOMTuDBQYUj8BOgoIooPulNINtY0v66Q02HW3vuJhsCEQ06vr2pcodHkaDrUmSWhwSW62)aiLoLwsSJbOlYLHf(WIfyN(yh4gWucIVF(N(4mfqUZoD6GoEoYbCr64O(1FrUmSqfBtauq64O(1FrUmSqfBtaTV)95iHgla2Ppwn1eWJjAhJLBaTV)954VixgwOYuaxKooQFPkdXFvX2ea1F)7RcvSdHkWOOK7pNmfOLEzybb0AXuBSsDaB59boFvfV0iGM080yp5AdC(7FP(y52mOHMHMMaaTHrUbwM3lfBYgl3qfyuuY9NtMc0sVmSGaATyQnwuBaB59boFvfV0iGMZ7u3(g483)s9XYTzqdndnnzZgqXJNHz2sZ3oMPaOG0Xr9lvzi(Rk2MamASailAMGySOkWwgI)2kO5XMatiPOqE0zjhOrQaUXEiChqvauITjGIhptvgI)QYuGJLBf08ytakK6NLCGgPcqJ9KRvhXyKdqxKldlAf08ytGjKuuipkaq(0SQZovldlILlQqvafpEgOYuaTV)9pmZ80ldlcCwYbAKkG46jHgluXQPakYV391lfVFChBcvGk2HaMyhcqm2HaYXoKnGIhp7VixgwOYuauq64O(T9AQyBcuxtr5s(bKVoob8kuAVlo2MavNKVA7ZLRshXySdbQojFb84zDeJXoeO6K8LFSNCT6igJDiWHFN623mfO6ZLRshHEMcGGPyYSoBDPCj)aYbOlYLHfTDgrra)JwQXZb4WuK9YLYL8dqhWucIpLl5hOKzD26gOUM6iM4ZuaTVm6JLcmfSU9pqf4yzFyXcStFSdCdylVpaCniyiQob0TihdOByELXLaA)f5YWccOBVMkWrybrmw9eq77ACd4XeT3fhl3aMVhW)OLA8Caf537(6LIpYbQojFrvgI)QJym2HaUiDCu)krWHrxl2OITjG23)(CKi4WORfBuzkGIhpdZSLMV9U4mfOUMQvqZJnbMqsrH8iTg9rfyldXF9HflSU9pasPtPLe7yGJkuyExpcOPyEFSsvtaVcfGk2MaaTHrUbumbX(FOs56U4avNKVA7ZLRshHESdbQRPKiCWuUKFa5RJtasdZRmU(WIfyN(yh4gG080yp5AB11kaW88tanCniyiQU0iGM080yp5AdO4XZT3fh5aEfkTJX2eGQ6VyjG(ad(sgBtGTme)vhXyKdOByELXLaA)f5YWIaktTmCafpEwZVRmtWHjiQYuaoVtD7BRUwbaMNFcOHRbbdr1Lgb0CEN623aUiDCu)Q5jvShYqGTme)1hwSb0PiGgkHIaABzm45ahl7dlwyD7FaKsNslj2XaUiDCu)2EnvSnbu84zjcom6AXgvMcuDs(c4XZ6i0JDiq1NlxLoIXmfOUMci)ExYHJTjGIhpRJymtbOXEY1QJqpYbow2hwSb0PiGgkHIaABzm45akE8C7yKdO4XZ6i0ZuapMaOILBGTme)1hwSa70h7a3aOG0Xr9RMNuXoeGUixgw4dl2a6ueqdLqraTTmg8CGQtYx(XEY1QJqp2HaJIsU)CYuafZJS)TihJLBa5o70Pd6452EpYb0((3VTZik8EXgGoWwgI)QJqpYbQojFrvgI)QJqp2HaN)(xQpwUndAOb1XfvOMbPgvC1KgcqAyELXvcnwaStFSAQjatWHrxl20kO5XMaNLCGgPcO4XZTxtjr4GJCagnwiLWyVyLQMaAF)7ZXhwSa70h7a3aoyXgyefsZRuZLBaTV)95O5jvMcGcshh1VseCy01InQyBcuxtjDbBdq2l33Knb]] )


    ns.initializeClassModule = HunterInit

end
