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

local RegisterEvent = ns.RegisterEvent

local retireDefaults = ns.retireDefaults
local storeDefault = ns.storeDefault


local PTR = ns.PTR


if select( 2, UnitClass( 'player' ) ) == 'HUNTER' then

    local function HunterInit()

        Hekili:Print("Initializing Hunter Class Module.")

        setClass( 'HUNTER' )

        addResource( 'focus', true )

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
        addAura( 'feign_death', 5384, 'duration', 360 )
        addAura( 'freezing_trap', 3355, 'duration', 60 )
        addAura( 'harpoon', 190927, 'duration', 3 )
        addAura( 'helbrine_rope_of_the_mist_marauder', 213154, 'duration', 10 )
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

        if PTR then 
            addGearSet( 'soul_of_the_huntermaster', 151641 )
            addGearSet( 'celerity_of_the_windrunners', 151803 )
            addGearSet( 'parsels_tongue', 151805 )
            addGearSet( 'unseen_predators_cloak', 151807 )
        end


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


        addHook( 'reset_precast', function()
            rawset( state.pet, 'ferocity', IsSpellKnown( 55709, true ) )
            rawset( state.pet, 'tenacity', IsSpellKnown( 53478, true ) )
            rawset( state.pet, 'cunning', IsSpellKnown( 53490, true ) )
        end )


        addToggle( 'artifact_ability', true, 'Artifact Ability',
            'Set a keybinding to toggle your artifact ability on/off in your priority lists.' )

        addSetting( 'artifact_cooldown', true, {
            name = "Artifact Ability: Cooldown Override",
            type = "toggle",
            desc = "If |cFF00FF00true|r, when your Cooldown toggle is |cFF00FF00ON|r then the toggle for your artifact ability will be overridden and your artifact ability will be shown regardless of its toggle above.",
            width = "full"
        } )

        addSetting( 'moknathal_padding', true, {
            name = "Way of the Mok'Nathal Padding",
            type = "toggle",
            desc = "If checked, the addon will save an internal buffer of 25 Focus to spend on Raptor Strike for Mok'Nathal Tactics stacks.",
            width = "full"
        } )

        addSetting( 'spend_apron_stacks', false, {
            name = "Survival: Spend Butcher's Bone Apron Stacks in Single Target",
            type = "toggle",
            desc = "If |cFF00FF00true|r and you are wearing Butcher's Bone Apron, the addon may recommend Carve or Butchery in single-target situations if you reach maximum stacks (10) of the buff.  " ..
                "This may avoid wasting stacks, but can also cause you to spend stacks in single-target when you would've rather saved them for an upcoming AOE / add-phase.  You may want to re-evaluate " ..
                "this setting on a per-fight basis.",
            width = "full",
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
            toggle = 'cooldowns'
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
            known = function () return talent.butchery.enabled end,
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
            summonPet( 'made_up_pet' )
        end )


        addAbility( 'caltrops', {
            id = 194277,
            spend = 0,
            spend_type = 'focus',
            cast = 0,
            gcdType = 'spell',
            cooldown = 15,
            passive = true,
            known = function () return talent.caltrops.enabled end,
        } )

        -- addHandler() -- Maybe for the snare?


        addAbility( 'camouflage', {
            id = 199483,
            spend = 0,
            spend_type = 'focus',
            cast = 0,
            gcdType = 'off',
            passive = true,
            known = function () return talent.camouflage.enabled end,
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
            known = function () return not talent.butchery.enabled end,
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
            known = function () return talent.dragonsfire_grenade.enabled end,
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
            known = function () return equipped.talonclaw and ( toggle.artifact_ability or ( toggle.cooldowns and settings.artifact_cooldown ) ) end,
            channeled = true
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
            toggle = 'interrupts'
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
        } )

        addHandler( 'raptor_strike', function ()
            if talent.way_of_the_moknathal.enabled then
                addStack( 'moknathal_tactics', 10, 1 )
            end

            if talent.serpent_sting.enabled then
                applyDebuff( 'target', 'serpent_sting', 15 )
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
            known = function () return talent.spitting_cobra.enabled end,
        } )

        addHandler( 'spitting_cobra', function ()
            summonPet( 'spiting_cobra', 30 )
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
            known = function () return talent.snake_hunter.enabled end,
            toggle = 'cooldowns'
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
            known = function () return not talent.steel_trap.enabled end,
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
            known = function () return not talent.caltrops.enabled end,
        } )


        addAbility( 'steel_trap', {
            id = 162488,
            spend = 0,
            spend_type = 'focus',
            cast = 0,
            gcdType = 'spell',
            cooldown = 60,
            passive = true,
            known = function () return talent.steel_trap.enabled end,
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
            known = function () return talent.sticky_bomb.enabled end,
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
            known = function () return talent.throwing_axes.enabled end
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
            known = function () return talent.a_murder_of_crows.enabled end
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


    storeDefault( [[SimC Survival: biteFill]], 'actionLists', 20170612.221649, [[d4thiaGEcrBIkLDjjVMeonrZKqvCykZwH5tsYnPINrOY3uLCEvv2Pu2Ry3i2Vkgfjfdts9BOEUknoQuXGv0Wj4GQQ6uKu6ys4CeQQwOQulvvXIHy5i9qQKNI6Xs16OsLMijrnvjYKPQPR0fvvAAKeCzW1jfBKqvzResBwIA7KOpsOk9DcbFMu18ie62q6VQIrtknEscDscLTrsvxJKu3JkvTmsLdrsKJtsLtrkf(lXqgGpiHvzOSPzS5Dywa6sBifPTsmjnDQw1H)adWUqA6QlEvRc6exLoDfUtTQdZDQuydh(FFLyYnLsRiLc)LyidWN3H5ovkSHxSE9dOQJXdpwei3W)rKd5(l8vqURKO)PJrOwyxAHUchSsafiBqc7G9IA0MHcHd3muimli3vs0FMUWiul8hya2fstxDXRI6WIr8YUTyAycMaHDW(MHcHZMMUuk8xIHmaFEhM7uPWgwnNjOonsbbWxHOz7Ab69bbtGhtGIjNPBNjIMYLRq0SDTa9(GGjWJjqXKQ7ADfNP7pZI6Z0TZ8c7kj6VvxbG4FmbkM8CxRR4EMQ9mvLQot1CMG60ifeaFvzQuKIeFFklj6b6snHZ0TZ0J3QH1bQTqffqnj5EMI4zkUk1FMQn8Fe5qU)cJOz7Ab6VWU0cDfoyLakq2Ge2b7f1OndfchUzOq43A2UwG(l8hya2fstxDXRI6WIr8YUTyAycMaHDW(MHcHZMM4sPWFjgYa85DyUtLcBy1CMG60ifeaFfIMTRfO3hembEmbkMCMUDMiAkxUcrZ21c07dcMapMaftQUR1vCMU)mlQpt3oZlSRKO)wDfaI)XeOyYZDTUI7zQ2ZuvQ6mvZzcQtJuqa8vLPsrks89PSKOhOl1eot3otpERgwhO2cvua1KK7zkINP4Qu)zQ2W)rKd5(lC3OkHWU0cDfoyLakq2Ge2b7f1OndfchUzOqyxgvje(dma7cPPRU4vrDyXiEz3wmnmbtGWoyFZqHWzttfsPWFjgYa85DyUtLcBypERgwhO2cvua1KK7zkINP4QuF4)iYHC)fEyDGAle2LwORWbReqbYgKWoyVOgTzOq4WndfclESoqTfc)bgGDH00vx8QOoSyeVSBlMgMGjqyhSVzOq4SPP6uk8xIHmaFEhM7uPWg26Ruj8aeavc3Z09NzXz62zU2aiB1fOcazFURKOVcigYa8NPBNPkDME8wDbQaq2N7kj6RwzxHKOp8Fe5qU)ctnHftFUlvQac7sl0v4GvcOazdsyhSxuJ2muiC4MHcH)yclMEM8sLkGWFGbyxinD1fVkQdlgXl72IPHjyce2b7BgkeoBAQpLc)LyidWN3HDWErnAZqHWHBgkeMxagNzjQjewmIx2TftdtWei8Fe5qU)cFxagpl1ec7sl0v4GvcOazds4pWaSlKMU6Ixf1HDW(MHcHZM2Ruk8xIHmaFEh2b7f1OndfchUzOq4)NPJgQhONjU8z6IIfHByXiEz3wmnmbtGW)rKd5(lS9GQH6b6dU8tNIfHByxAHUchSsafiBqc)bgGDH00vx8QOoSd23muiC20CNuk8xIHmaFEh2b7f1OndfchUzOqyvMA6XKBzjfotXlfiMhclgXl72IPHjyce(pICi3FH9utpMCllPWJEkqmpe2LwORWbReqbYgKWFGbyxinD1fVkQd7G9ndfcNnnXFkf(lXqgGpVd7G9IA0MHcHd3mui8xvuyGVsLWzwIAcHfJ4LDBX0Wembc)hroK7VWGkkmWxPs4zPMqyxAHUchSsafiBqc)bgGDH00vx8QOoSd23muiC20kQtPWFjgYa85DyUtLcByv6m94TQBJLIfUvRSRqs0h(pICi3FH72yPyHByxAHUchSsafiBqc7G9IA0MHcHd3muiSlBSuSWn8hya2fstxDXRI6WIr8YUTyAycMaHDW(MHcHZMnCZqHWSe11zYAOkLkTH7EMiYfeFYXiBca]] )

    storeDefault( [[SimC Survival: CDs]], 'actionLists', 20170612.221649, [[dSZJhaGEuQsBsLYUOW2OuL2hQkmBHUPuCAr9nvshwv7eO9QSBK2pPgLKQHbIFt1ZqvLHIsvmysgUiDqjLtjjDmP09qvvlusSuuklgulxWdbjRcLkAzIW6qPctevfnvvIjdy6iUOkvpwIldDDkAJOujBLsLnJITdsnokvX8OuvFgv(oLsJeLk1ZvXOrj)LsojLIPHsvDnuv68OkpL41IOBlvV2DzYD6dhrGbpHprM3mswLjskwYFmZEFs2PdmbF57e2Wi(hCGjG0Efc7NGFgjs0Apq47ePeYPKjtQvizNE2Lb2UltUtF4icSktKsiNsMW4fZJrXmeqkrRSp)1k(bzsn4Cmt4n5dLNIwepeqkzcuSWsYghASJuYGN04a29bWVJtMa(DCsTq5POwDXdbKsMWggX)GdmbK2RTqMydfixEIhMqDkoPXba)oozKbMyxMCN(WreyvMiLqoLmH4CCr0O4EeWTLE0QBAvDTc2KHX4pPyHy5mwewOf(Cr0WmvRQoPgCoMj8MaJHdgsMPCtGIfws24qJDKsg8KghWUpa(DCYeWVJtQGHdgsMPCtydJ4FWbMas71witSHcKlpXdtOofN04aGFhNmYa53Um5o9HJiWQmrkHCkzcX54IOrX9iGBl9Ov30Q6AfSjdJXFsXcXYzSiSql85IOHzQwvDsn4Cmt4nbo6oGfJzG3eOyHLKno0yhPKbpPXbS7dGFhNmb874Kkr3b0k2LzG3e2Wi(hCGjG0ETfYeBOa5Yt8WeQtXjnoa43XjJmq2FxMCN(WreyvMiLqoLmH4CCr0i1jzNE0QBAvDTc2KHX4pPyHy5mwewOf(Cr0WmvRQoPgCoMj8MK6KStNaflSKSXHg7iLm4jnoGDFa874KjGFhNWECs2PtydJ4FWbMas71witSHcKlpXdtOofN04aGFhNmYa57Um5o9HJiWQmrkHCkzcX54IOrX9iGBl9Ov30Q6AfSjdJXFsXcXYzSiSql85IOHzQwvDsn4Cmt4nbgdhmKmt5MaflSKSXHg7iLm4jnoGDFa874KjGFhNubdhmKmt50Q6TvNWggX)GdmbK2RTqMydfixEIhMqDkoPXba)oozKbAV7YK70hoIaRYePeYPKjeNJlIgf3JaUT0JwDtRQRvf3JaUTuJUt5C)GwWzcAuy9bo8Ov8xRGOv30kytggJUt5C)GwmMbEgbS)z6rR4dTIFAf7uR4kaAv1j1GZXmH3Kd9tIwSmPemmbkwyjzJdn2rkzWtACa7(a43Xjta)oorOFsuRy3MucgMWggX)GdmbK2RTqMydfixEIhMqDkoPXba)oozKbEDxMCN(WreyvMiLqoLmH4CCr0O4EeWTLE0QBAvDTQUwbBYWy0DkN7h0IXmWZiG9ptpAL95Vw12Qv30kytggJUt5C)GwmMbEgMPAvvT6MwvxRkUhbCBPgmMbEwoJfHfAHpxency)Z0JwXhAfSjdJr3PCUFqlgZapJa2)m9Ovv1QQtQbNJzcVj)jflelNXIWcTWNlItGIfws24qJDKsg8KghWUpa(DCYeWVJtQDsXcrRCgTIWc1Q7pxeNWggX)GdmbK2RTqMydfixEIhMqDkoPXba)oozKbAp7YK70hoIaRYePeYPKjeNJlIgf3JaUT0JwDtRQRv11kytggJUt5C)GwmMbEgbS)z6rRSp)1QRA1nTc2KHXO7uo3pOfJzGNHzQwvvRQoPgCoMj8M8NuSqSCglcl0cFUiobkwyjzJdn2rkzWtACa7(a43Xjta)ooP2jfleTYz0kcluRU)CruRQ3wDcBye)doWeqAV2czInuGC5jEyc1P4Kgha874Krgzc43XjsUdLwjMbOZq)r2HwbfFEgzd]] )

    storeDefault( [[SimC Survival: AOE]], 'actionLists', 20170612.221649, [[dytKdaGEKu1MKkQDrf9AQW(KkYSL4Mu03KQStQAVKDd1(HWOqsPHju)gLbdrdxihKs6uiPYXOWcPelvQ0IH0Yf8qK4PQwMs55i1ersXurvMSuMUIlIQ60iUm46sfoSOTkv1Mrsy7uPNHk0JL00qf8zujJdjr3wjJMsz8OICsLkhcvuxtPQZtP6VOsToKK6NijzziE68XjAbAcvNAaQi7OmYI(JGkjleQphcdl)2(96DHcK0G8BXg9I5WghDUTzqLX71FnqIgDDR1HWW0IN8gINoFCIwGMSOBYA9ZGpxGUUpxGULoMQniyxFhUrQ5Wc6ygg0TIskKXUoAht1geSRtXguDyYCHfGhHQ3fkqsdYVfB0Ziw3K185c01i)M4PZhNOfOjl6VgirJoNrGSXgN1SmbweTZHuDqWCPBfLuiJD9AwMalIwNInO6WK5clapcv3K16NbFUaDDFUaDkzzcSiA9UqbsAq(TyJEgX67WnsnhwqhZWGUjR5ZfORrEokE68XjAbAYIUjR1pd(Cb66(Cb685uuHrtCbei5fYi9D4gPMdlOJzyq3kkPqg76aNIkmAIlW9eYiDk2GQdtMlSa8iu9UqbsAq(TyJEgX6MSMpxGUg55G4PZhNOfOjl6VgirJ(KfapoPHqeGhUPhcMlNaorlqdbYoJajNrGSXgN0qicWd30dbZLZHuDqWCPBfLuiJD9AgCbDk2GQdtMlSa8iuDtwRFg85c0195c0PKbxqVluGKgKFl2ONrS(oCJuZHf0XmmOBYA(Cb6AKFV4PZhNOfOjl6VgirJEwhIlWnGHfbOrGStiqUx3kkPqg761m4c6uSbvhMmxyb4rO6MSw)m4ZfOR7ZfOtjdUacKuRb1P3fkqsdYVfB0ZiwFhUrQ5Wc6ygg0nznFUaDnA095c0pzrbbY3rWL4MfQgbsRufFns]] )

    storeDefault( [[SimC Survival: default]], 'actionLists', 20170612.221649, [[d0J6haGEerBssK2LK02iLu7drOzkuz2knFev1nLOtl6BikhMYoryVQ2ns7xWOKeggk53K8msPmusPAWu1WLkDqPQtju1XavNhiTqqXsrPAXOQLlLfjbpfAzKQEoitusutfrAYOY0vCrqP1juUmX1LuBerv2kPInlvSDumojr8xGAAic(oPeEmGBtLrtk(mqCssLEOqUgIk3dLYHiLOFskjVwc9HFspcl14xH78hRS0XQ35WCe7kaPTjjTjv0tONCK7i7YkgKCc9SGtglsqV2QQxp8kHf5oIaTS7C8ypWKkk0j9eWpPhHLA8RWDyoIaTS7CCuGaYkvt6iTwD3bk4R0GVIGFSgiYuLt4R70PkGbnjfKQ1Dd(4p2ZNBoGE0vtssUYXincqXsfJ4e6C(JLkoDSgH5KJhjmNCSSMKKCLJSlRyqYj0ZcozWzDuxkxcyJQDKQOYXsfhH5KJFoH(t6ryPg)kChMJiql7ohhBf6uvlmqbR6aE0iGDQIuB0yBvHA8RWDSNp3Ca9iGTlydysff8MqZrDPCjGnQ2rQIkhlvC6yncZjhpsyo5yKTBW3dmPIg8XLqZX(giqhPMtyRaMUOGhRBmjJTXcENQyPL0XsAHJSlRyqYj0ZcozWzDmsJauSuXioHoN)yPIJWCYrmDrbpw3ysgBJf8ovXslPJL0pNqBN0JWsn(v4omhrGw2DoYx3PtvNQi1gn2cEmGjbGQcngqXGNezl41h8Kp5h8AzWp2k0PQwyGcw1b8Ora7ufP2OX2Qc14xH7ypFU5a6raBxWgWKkk4nHMJ6s5saBuTJufvowQ40XAeMtoEKWCYXiB3GVhysfn4JlHMGVc4XFSVbc0rQ5e2kGPlk4X6gtYyBSGpQYqfoYUSIbjNqpl4KbN1XincqXsfJ4e6C(JLkocZjhX0ff8yDJjzSnwWhvzOpNGeoPhHLA8RWDyoIaTS7CuldE(6oDQ6uuqukibCN6gOvR7ESNp3Ca9iGTlydysff8MqZrDPCjGnQ2rQIkhlvC6yncZjhpsyo5yKTBW3dmPIg8XLqtWxH(4p23ab6i1CcBfW0ff8yDJjzSnwW3TjWKJODngKu4i7YkgKCc9SGtgCwhJ0iaflvmItOZ5pwQ4imNCetxuWJ1nMKX2ybF3MatoI21yqYNtqUt6ryPg)kChMJiql7ohnGjzeWcvCPaf8KiBbV2o2ZNBoGEeW2fSbmPIcEtO5OUuUeWgv7ivrLJLkoDSgH5KJhjmNCmY2n47bMurd(4sOj4RqBXFSVbc0rQ5e2kGPlk4X6gtYyBSGVxRGTWr2Lvmi5e6zbNm4SogPrakwQyeNqNZFSuXryo5iMUOGhRBmjJTXc(ETc2pNqRpPhHLA8RWDyo2ZNBoGEeW2fSbmPIcEtO5OUuUeWgv7ivrLJLkoDSgH5KJhjmNCmY2n47bMurd(4sOj4RGeI)yFdeOJuZjSvatxuWJ1nMKX2ybpFoI21yqsHJSlRyqYj0ZcozWzDmsJauSuXioHoN)yPIJWCYrmDrbpw3ysgBJf885iAxJbjFobzN0JWsn(v4omh75Znhqpcy7c2aMurbVj0CuxkxcyJQDKQOYXsfNowJWCYXJeMtogz7g89atQObFCj0e8vqU4p23ab6i1CcBfW0ff8yDJjzSnwWZNJqE5UfoYUSIbjNqpl4KbN1XincqXsfJ4e6C(JLkocZjhX0ff8yDJjzSnwWZNJqE5UForLCspcl14xH7WCSNp3Ca9iGTlydysff8MqZrDPCjGnQ2rQIkhlvC6yncZjhpsyo5yKTBW3dmPIg8XLqtWxHwh)X(giqhPMtyRaMUOGhRBmjJTXc(o5UsdQWr2Lvmi5e6zbNm4SogPrakwQyeNqNZFSuXryo5iMUOGhRBmjJTXc(o5Usd6ZNJeMtoIPlk4X6gtYyBSGNt6y1785ha]] )

    storeDefault( [[SimC Survival: precombat]], 'actionLists', 20170612.221649, [[dqtZdaGEcPAxekETk0SfCtc(MOYojzVODRQ9lknmk1VLAOeQmyHYWfYbfvDmICAsTqrXsfQwmuwUKEif5PkltL8CkzIeknvOYKLy6qUif6WuDzW1vPYZiu1wvPSzkQ2ou1hjKYTfzAuG(mHyKQuvJtLQmAvW4PaoPkYFPOCnkOZRIABesADes8yIAkrCCgFhlafIXjwWC)UaIz4weiR9Gw0DKUFQUm0qU4qaClGQlBPC2g8s8I56s6E2gYn5QocXXLxgP73I4OsI44m(owakmdNqxU5vLNaooLNaotEiKnM4au2ysCN(Iw2rDL77h4YJPdA0zoR7sP(nlcqCMoaYhfA8qcEeX4IdbWTaQUSLYjzZj0fLNaoIO6I44m(owakmd3KR6iehQfrKaiMOgP73IlpMoOrN5IAKUFotha5JcnEibpIyCcD5MxvEc44uEc4exJ09ZfhcGBbuDzlLtYM70x0YoQRCF)aNqxuEc4iIkXtCCgFhlafMHtOl38QYtahNYtaNrdefAlnEiBmCvpI70x0YoQRCF)axEmDqJoZbgik0wA8GzOQhXz6aiFuOXdj4reJloea3cO6YwkNKnNqxuEc4iIkdsCCgFhlafMHtOl38QYtahNYta3qaeYgdx1J4o9fTSJ6k33pWLhth0OZCwiacMHQEeNPdG8rHgpKGhrmU4qaClGQlBPCs2CcDr5jGJiQmK44m(owakmdNqxU5vLNaooLNaoXwDr63YCDfYgt0QW7fG70x0YoQRCF)axEmDqJoZvQUi9BzUUcMjsfEVaCMoaYhfA8qcEeX4IdbWTaQUSLYjzZj0fLNaoIOsujooJVJfGcZWj0LBEv5jGJt5jG7(EnQ7N70x0YoQRCF)axEmDqJoZDWRrD)CMoaYhfA8qcEeX4IdbWTaQUSLYjzZj0fLNaoIiIt5jGB6KPSX2Dv8A8EquYglQcYDcZrerc]] )

    storeDefault( [[SimC Survival: fillers]], 'actionLists', 20170612.221649, [[dOZueaGEkL0MuHSli1RHW(GKmBP6MsY3uvCAuTtLSxXUHA)umkukdtLmokL4Wu9mjkgmPgoeDqvWPqP6yuYTvQfcjwQeSycTCsEiLQvjrPLPs9CumrkfAQsOjRktxXfvv5vqs1Lbxxvv)fLSvc0MLuTDv00uH67su9zjY8OuupwkhIsbJMGgpLsDsc4wqs5AskNxvP1rPipf53eDSsXq)WUyhErmKnc19)9jOeIqcnU352QpCjoR7A1cva6GZazDFz95647YG((2YwUQfIAkoYjuOdTHlXmPywwPyOFyxSdVGsiQP4iNqEB4NaladBoWy0OYOTm6Jm6X7aEqZakKaEyXmCCj0a2f7WZOpYOTbJ(jh0mGcjGhwmdhxc9WBi44sHoiY785BOMRoHq2fcnevYtyd4jIHQKpbD1Y3qOqlFdHS7QtiubOdodK19L1hRRqcGF8MpsviSedHQKVLVHqzY6ofd9d7ID4fucvjFc6QLVHqHw(gcvuOswohxYOpyBGjKa4hV5JufclXqOdI8oF(gAeQKLZXLy52gyczxi0qujpHnGNigQa0bNbY6(Y6J1vOk5B5BiuMSktkg6h2f7WlOeIAkoYjK3g(jWcWWMdmgnQm67qhe5D(8nuZvNqi7cHgIk5jSb8eXqvYNGUA5BiuOLVHq2D1jy0SzXEOcqhCgiR7lRpwxHea)4nFKQqyjgcvjFlFdHYK1XPyOFyxSdVGsiQP4iNqSz0J3b8GUC)llzDwJqG1wIa7JqVJgWUyhEg9rgT4)61rVLiW(i07SgVn8gdAfSDoMXOTzJUu7z0L1Op2Ozp0brENpFdPCKJuXIzuCeqi7cHgIk5jSb8eXqvYNGUA5BiuOLVHqfCKJuz00O4iGqfGo4mqw3xwFSUcja(XB(ivHWsmeQs(w(gcLjRAPyOFyxSdVGsiQP4iNq1LT)mOB)vkapgnQmA2mA2m67AgnQz01LT)mOvqjaB0L1Ol1Egn7gnQB01Qz0Sh6GiVZNVHuoYrQyXmkociKDHqdrL8e2aEIyOk5tqxT8nek0Y3qOcoYrQmAAuCeGrZMf7HkaDWzGSUVS(yDfsa8J38rQcHLyiuL8T8nektMqlFdHi(2Urt)vN8tVBtgDDEVdkMmja]] )

    storeDefault( [[SimC Survival: preBitePhase]], 'actionLists', 20170612.221649, [[d8dIjaqAIwpjuBss0UKkBJkLomLzskvEgjKzRK5tLQUjP68QcFtv0ZvXoLYEf7gQ9RuJIuIHjv9BeJJaKHskLAWQ0Wj0bvLCksjDmQ44uPYcLuTui0IH0Yr6Hujpf1YiPwhPu0ejLQMQKYKPQPR4IqWJL4YGRljTrcqTvsWMvLA7KIpskfMgvk6ZKOVtampjb)fIgnjz8uPWjjqhIaQRjj09iGCosPKBRQEnbDCsTWiGn0f4dAyThEBvxtQhMfHI0wsfBJKGttDfRyyeHfyhin19op7Dt1kQtTAhbuFfdZfQuCch(vzKe8j1sZj1cJa2qxGp1dZfQuCcxiKLNia4UpbRKqoasu5aDfvgvjC23kSVkk8lu5sopc)EzyHsSsKNHkfcHDPckc1jAGpGNGgwN4vWOn7dHd3SpewaVmSqjw5(YdvkecJiSa7aPPU35PtFybXEzXgcnmMGHW6eFZ(q4mPPo1cJa2qxGp1dZfQuCcpeLkxqxHqwEIaGpHFHkxY5r4JOCgjwjYcbLAHDPckc1jAGpGNGgwN4vWOn7dHd3SpeMfLZiXk3xxeuQfgryb2bstDVZtN(WcI9YIneAymbdH1j(M9HWzstrPwyeWg6c8PEyUqLItybEF9KPBzfGAd0nYIqjwz4xOYLCEeEzfGAde2LkOiuNOb(aEcAyDIxbJ2SpeoCZ(qyTZka1gimIWcSdKM6ENNo9Hfe7LfBi0WycgcRt8n7dHZKMBMAHraBOlWN6H5cvkoHTYi1aibm8LWzFfO91zFRCFhBb4P7aurapipJeRSdWg6c87BL7RaVVEY0DaQiGhKNrIv2nYIqjwz4xOYLCEeMAIdHI8muPqiSlvqrOord8b8e0W6eVcgTzFiC4M9HWiAIdHUV8qLcHWiclWoqAQ7DE60hwqSxwSHqdJjyiSoX3SpeotAvm1cJa2qxGp1dRt8ky0M9HWHB2hcZdaR9Tg1edli2ll2qOHXeme(fQCjNhHpdalKd1ed7sfueQt0aFapbnmIWcSdKM6ENNo9H1j(M9HWzsZTPwyeWg6c8PEyDIxbJ2SpeoCZ(q4x7REvQhO7l59(6IseGtybXEzXgcnmMGHWVqLl58iSH8xL6bksYBKfkraoHDPckc1jAGpGNGggryb2bstDVZtN(W6eFZ(q4mP9m1cJa2qxGp1dRt8ky0M9HWHB2hcR9utjbFElPW(QnOa28qybXEzXgcnmMGHWVqLl58iSNAkj4ZBjfqQKcyZdHDPckc1jAGpGNGggryb2bstDVZtN(W6eFZ(q4mPjGsTWiGn0f4t9W6eVcgTzFiC4M9HWi4gIlYrQb23AutmSGyVSydHggtWq4xOYLCEegCdXf5i1aihQjg2LkOiuNOb(aEcAyeHfyhin19opD6dRt8n7dHZKM2k1cJa2qxGp1dZfQuCclW7RNmDfBnuI4PBKfHsSYWVqLl58iCXwdLiEc7sfueQt0aFapbnSoXRGrB2hchUzFiSlBnuI4jmIWcSdKM6ENNo9Hfe7LfBi0WycgcRt8n7dHZKMtFQfgbSHUaFQhMluP4ewl7l4UQsrrW3HwDkQa6bjkbdinrkbVVvUVOvF)UdT6uub0dsucgqAIucU7mwr4(kq7Rt)(w5(EGzKyLNUJiG9inrkbJ8mwr4zF16(6E3VVAzFb3vvkkc(U3uPIvm5G8TeReOd1e33k3xpz6wwbO2aDu4Bs8zFRW(QOo3UVAn8lu5sopcJwDkQa6JWUubfH6enWhWtqdRt8ky0M9HWHB2hcxV6uub0hHrewGDG0u3780PpSGyVSydHggtWqyDIVzFiCM0CCsTWiGn0f4t9WCHkfNWAzFb3vvkkc(o0QtrfqpirjyaPjsj49TY9fT673DOvNIkGEqIsWastKsWDNXkc3xbAFD633k33dmJeR80DebShPjsjyKNXkcp7Rw3x37(9vl7l4UQsrrW39MkvSIjhKVLyLaDOM4(w5(6jt3Yka1gOJcFtIp7Bf2xf1529vRHFHkxY5r4Ir1aHDPckc1jAGpGNGgwN4vWOn7dHd3Spe2Lr1aHrewGDG0u3780PpSGyVSydHggtWqyDIVzFiCM0CuNAHraBOlWN6H5cvkoH9KPBzfGAd0rHVjXN9Tc7RI6CB4xOYLCEeEzfGAde2LkOiuNOb(aEcAyDIxbJ2SpeoCZ(qyTZka1gyF1IJwdJiSa7aPPU35PtFybXEzXgcnmMGHW6eFZ(q4mzc3SpeMLFx7lxLQrQXwAZ9vKc1LdOTvzhitca]] )

    storeDefault( [[SimC Survival: mokMaintain]], 'actionLists', 20170612.221649, [[diZccaGEIkTli1RHQzRKBkfFtrzNk1Ef7gv7NqJIOudtk9BedMidxsoOKQtPkvhdLwOIQLcHfRQwospuv4PGLrWZrXejkzQsktgktNQlQk6YKUoeTvjOnRiBxICAvomLPruX8Kq9mvP8DjKrlr9xi5KevnoIcxtvY5LapwHBlvRJOOdBQf4j3(lfl)aYsNmKlpZdav64S1jxZpcpBHxVcGqxQXOzl0YoRvocVHwqGvgTVcad6v5bcuF4hHZKAzZMAbEYT)sXY8aWGEvEGpYPj0Dco38Y2cLBd)gmOPA3ooJOuXIsu9JCAcvrhhJuuG6)BDEbbOwLtOOyC6HRbEuwh4nKsAx5E(bAiyfA0T11ab2wxdGWQCcvucC6HRbqOl1y0SfAzNX2gqEo2nmNqdWjCnqdbBBDnq8SfsTap52FPyzEayqVkpWh50e6obNBEzBHYTHFdg0mUnWfLkwusiq9)ToVGauRYjuumo9W1apkRd8gsjTRCp)aneScn626AGaBRRbqyvoHkkbo9WvrjzZ(Eae6sngnBHw2zSTbKNJDdZj0aCcxd0qW2wxdepEGT11aW1FikbiPLUs2sMIsDcEJDC3oE8ea]] )

    storeDefault( [[SimC Survival: bitePhase]], 'actionLists', 20170612.221649, [[d4dMfaGEvI0MOszxuX2if0(uj1Pj6WIMTqZxLOUPc9msr(gPKZtO2jb7fA3QA)GgLGmmc53swLkLgQkHmyGHlOoisXPeOJPGXPssluLQLsk1Iry5s1dPs8ukldrwNkbMOkbnvKQMmsMUsxeP0Rujuxg11ruBKuOTkG2mjTDKkxsLiESI(mPAEKI62u1FjXOLsFxaojvstJuGRPsX9Os1ZvXHujXRLIXbKE0O9tIitHeODHSAsoU4D0SW8uMr5LMRSEuG0n3GM2CKZdJcKenOLinGKMCirA4QIUbnB2LHx0qJM5kR)G0Jcdi9Or7NerMcVJMn7YWlAHGGRabBg5FDcifRuQkBlR4RMp32m6WFsezki4YxgciiRQ64RMp32mQS5CLZJtN9P8pqW1qqiiqFsbb3cbHGGRcbxceOjiiieeecccbUbbeKvvD81Rx1Hvuj3f7C2C2abUdbAiA0qiJYvmAQK7IvkvLTLv4upYO56tjN5wD0(6z0glQaZUq6z0qti9mAAKCxmeuQqW2YqaTPEKrJMU(bn5VCVto8QivDp0Mr(xNasXkLQY2Yk(Q5ZTnJo8NerMYncYQQo(Q5ZTnJkBox5840zFk)JMDFLZgLv65GOPnh58WOajrdAnicnxA5zZyrh75Frc0glkH0ZOHlkqcPhnA)KiYu4D0SzxgErB2MDD(abx7oeqccCdcMvfPQaEhF96vDyfc5YoD2NY)abAgc0NuqWTqaj0OHqgLRy081Rx1HviKlJMlT8SzSOJ98VibAJfvGzxi9mAOjKEgTX61R6WqWD5YOPnh58WOajrdAnicnxFk5m3QJ2xpJ2yrjKEgnCrbnH0JgTFsezk8oA2SldVOfcccbbeKvvD81Rx1Hvuj3f70zFk)deCneecc0NuqWTqqiiywvKQc4D81Rx1HviKl7mBZUoFGGlgcibbbHGGqqqiWniywvKQc4D81Rx1HviKl7mBZUoFGan7oemabbHa3GGRabeKvvDYtyEUkLQY2YkCQhzhYHrJgczuUIrtnMFJ81voBx2WO5slpBgl6yp)lsG2yrfy2fspJgAcPNrtJX8BKVoeyBx2WOPnh58WOajrdAnicnxFk5m3QJ2xpJ2yrjKEgnCrbnaPhnA)KiYu4D0SzxgErJGSQQJVE9QoSIk5UyNo7t5FGGRHGyU8pfdb3cbKqJgczuUIrZxVEvhwHqUmAU0YZMXIo2Z)IeOnwubMDH0ZOHMq6z0gRxVQddb3LldbHgcIM2CKZdJcKenO1Gi0C9PKZCRoAF9mAJfLq6z0WffUbPhnA)KiYu4D0glQaZUq6z0qti9mAAmMFJ81HaB7YggccneenxFk5m3QJ2xpJgneYOCfJMAm)g5RRC2USHrZLwE2mw0XE(xKanT5iNhgfijAqRbrOnwucPNrdxCrti9mAM07ceyK70jPlJxaeqix(IAZdJlIa]] )


    storeDefault( [[Survival Primary]], 'displays', 20170612.221649, [[d8d5haWyKA9QsEjfu7cjs2gsu63qntkutJc0Sv48uLBQkQtJY3uf0XKQ2jL2Ry3eTFi1pHKHrOXHevxwLHsWGHOHJWbLkhfjkoSKZHeHfkLwQQulMkTCsEOu0tblJI8CsnrvHAQiAYOIPR0fvuxLc4zQc56QQnkf2QQaTzQQTdHpsr1Rvf5ZiPVRiJKcP1rbz0OQXJeojQ0TufW1OqCpKi1TPI1IerhNIYPpKbOlILHLnWYfwVXfaLbinMRDoaDrSmSSbwUa71fBVPaQss9AYF0pL2aUd2RxMpWtXnGhkFF9TnlILHL6yfdqbkFF9TnlILHL6yfdqOyoLYJlnwcSxxSgumGdt2nhRPaM9V)XPzrSmSuN2aEO8913swkQ3QJvmaL5F)thYy7dzGzz5oooPnqh9YWs0inMP3yPebSLZf49xx8gcnsc1rJDCRnW7BCL(I1Ky)df7ffda0kgXgyzohLwmBSMczGzz5oooPnqh9YWs0inMP3yP8a2Y5c8(RlEdHgjNZV(JnW7BCL(I1Ky)df7ffZMnGMhpbtSLMVBoTb084PU)ItBanpEcMylnF3FXPnWwkQ32jP5XQaTOijr98BUMBuYaEX(aMOSIbOiwXaAE8ezPOERoTbEYTtsZJvbirj8MR5gLman2XTwbeZXnaDrSmSStsZJvbArrsI65aaXrZQb7vTmSmwtgXib084jGmTbm7F)7Xm1rVmSmWBUMBuYaYVdxASuhRbdOjUXOXO08nXdSkKbQy7dOITpa1y7d4gBF2aAE8uZIyzyPoTbOaLVV(2UVQIvmq9vfPhXfW977hWPOO7V4yfdudc(QBmvEAbeZX2hOge8fWJNeqmhBFGAqWxnXoU1kGyo2(ap(8R)ytBGAmvEAbecPnacMM5YgS1J0J4c4gGUiwgw2nyuLbAoBjNFhGdttmkpspIlqfqvsQhPhXfOCzd26fO(Q6zM8sBaZ(m6NEqMgwVXfOc8KBdSCb2Rl2EtbOaLVV(wUsom6AXkDSIbQbbFrwkQ3kGqi2(aEO8913YvYHrxlwPJvmG6gbAoBjNFhqtCJrJrP5JBGAqWxKLI6TciMJTpWwkQ32al3acKOrcLuJgPTuk8uaZ(3)4WvYHrxlwPtBahMS7V4yfdWOXskjg7e7JedSLI6TnWYfwVXfaLbinMRDoWZffmNVdAKKmNl2hjgWPOaiJTpaqRyeBGa1GGV6gtLNwaHqS9bm7F)JdxASeyVUynOyacfZPuEnWYfyVUy7nfGqD0yh3A7emoaWCAIgj8viyiQHHqJKqD0yh3AdiOyoLYdnYMfXYWs0i7(QkWZyjvmwFOr24R8c4uu0nhRyaYACYfnsZv4prSIb2sr9wbeZXnGMhpz4ZZLj5WKu1PnW7BCL(I1Ky)dfnOPhrPmzQNYfnsaZ(3)6gmQsNtUbOdSLI6TcieIBaFSCdmtbH606PYlG7G96L5d8u3ye3aEO891329vvSIb084jUsom6AXkDAdudc(c4XtcieITpqnMkpTaI50gOge8vtSJBTcieITpGMhpjGyoTbOXoU1kGqiUbEYTbwUbeirJekPgnsBPu4PauGY3xFRHB1XkgqZJNeqiK2aomjqgRyGTuuVTbwUa71fBVPaAE8u3CAdqxeldlBGLBabs0iHsQrJ0wkfEkq9vfqCJb3hhRyGzz5oooPnGM5qmUouZXAkWtUnWYfwVXfaLbinMRDoafO8913swkQ3QJvmGhkFF9TgUvh7d0hGZ5x)X2jyCaG50ens4RqWquddHgjNZV(JnGGI5ukp0iBweldldOv1YWb084PUVQ4k9XXnq9vfxPpM0J4c4(99dWOXsGOOzsQXAKa1xvDsAESkqlkssupB8CdYaM9V)XPbwUa71fBVPamjhgDTyvNKMhRc8MR5gLmGz)7FCmCRoTbSLZfa(keme1ansbfZPuEbQVQmGKTbigL3PYMa]] )

    storeDefault( [[Survival AOE]], 'displays', 20170612.221649, [[dae7haqiIe1MqKIBrKKDHiLggv6ykyzOsptfKPrKQRHi5BQGACej15isW6is5EisLdkLwOc9qPOjsrvxurTrPWhvbgjfvojr8skIMjfPBQc1oP0pHOHsHJIivTuvupfmvKCvkcBLirwlrcTxXGHuhwYIjQhJutgvCzvTzQ4ZiQrJQonkVwfYSLQBtvTBc)gQHJWXPOSCs9CsMUsxxL2oe(UImEeX5PkRxfz)qYziubOlILHfnWIfwV(haPjOmvIDoaDrSmSObwSa70h7a3a6sq(BY)0hLXaYD2Pth0XtroGhshh1VnlILHfQyDdqcshh1VnlILHfQyDdy29Vphj0ybWo9XkD3akE8u7vxseo4ihWS7FFonlILHfQmgWdPJJ6xQst(xvSUbi93)(Qqf7qOcmlk5(ZjJbAPxgwGcTPm1gRuiGT8)aNVQIxAOqtOFASVCTbo)9VuFSCDhoS7GRBaGwZi2alZ)jDUzJLBOcmlk5(ZjJbAPxgwGcTPm1gRuhWw(FGZxvXlnuO58o1TVbo)9VuFSCDhoS7GRB2Sbu84jyIT08TZzmajiDCu)svAY)QI1nGFrcqfRBGT0K)TvqZJ1bgrsrH84ZsoWCub8IvQ4oqQaoyXgyMec9RutLxafpEIQ0K)vLXahj3kO5X6auinol5aZrfGg7lxRbI5ihGUiwgw0kO5X6aJiPOqECaG4PzvNDQwgwelxsrQakE8eqLXaMD)7BEM(Pxgwe4SKdmhvaX1xcnwOIv6bueFV3Oxk(M4owhQavSdb0XoeGCSdbKJDiBafpEQzrSmSqLXaKG0Xr9B7vxX6gOU6IYJ4diFDCc4xK0ExCSUbQobF12NkpLbI5yhcuDc(c4XtgiMJDiq1j4RMyF5Anqmh7qaZ)o1TVzmq1NkpLbcJmgabtXKzD26r5r8bKdqxeldlA7mYIanNTuZNdWHPi6LhLhXhGoGUeKFkpIpqjZ6S1lqD11XmXNXaMDz0hjLyky96FGkWrYnWIfyN(yh4gGeKooQFLi4WORfRvX6gWqZ8lThk0nlILHfOq3E1vGJXcYyS6rHUXv7fWNjAVlowUb0FpqZzl185akIV3B0lfFKduDc(IQ0K)1aXCSdbijw3aMD)7ZrIGdJUwSwLXakE8emXwA(27IZyagnwifXy)ypKBGT0K)TbwSW61)ainbLPsSZboUiH5F9rHMI5)XEi3a(mr7CSCda0AgXgqXeK7pPrkx3fhO6e8vBFQ8ugimIDiatWHrxlw3kO5X6aNLCG5OcqOz(L2RbwSa70h7a3ae6Ng7lxBRHPbaMFtuOHRgbdr1Lgk0e6Ng7lxBacnZV0EsOXcGD6Jv6Ub8lsANJ1nav1FXIc9bA8Liw3aBPj)RbI5ih483)s9XY1D4WUsN7HiTC5oi1UKkGHM5xApuOBweldlcO01YWbQobFrvAY)AGWi2HaBPj)RbcJihWS7F)2oJSW)fBa6aYD2Pth0XtT9EKd4H0Xr9B7vxX6gqXJNKi4WORfRvzmq1j4lGhpzGWi2HavFQ8ugiMZyGQtWxnX(Y1AGWi2HakE8KbI5mgGg7lxRbcJih4i5gyXgWGcfAOekuOTLwJNcqcshh1VMCuf7qafpEYaHrgd4ZeavSCdSLM8VnWIfyN(yh4gqXJNANJCa6IyzyrdSydyqHcnucfk02sRXtbQRUaIV3Ly(yDdmlk5(ZjJbumFI(3ICowUbosUbwSW61)ainbLPsSZb2st(3gyXgWGcfAOekuOTLwJNc4H0Xr9RjhvXkvdb48o1TVTgMgay(nrHgUAemevxAOqZ5DQBFdO4XtM89KzcombzvgdO4XtT3fh5a1vxseoykpIpG81XjaJglaIIMjihlPcuxD1kO5X6aJiPOqESPZnOcy29VpNgyXcStFSdCd4H0Xr9RebhgDTyTkw3aMD)7ZXKJQmgWw(Fa4QrWquDuOBrohOU6Yec2gGOxEVoBca]] )


    ns.initializeClassModule = HunterInit

end
