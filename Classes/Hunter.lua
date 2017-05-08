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
        addGearSet( 'tier19', 138342, 138344, 138813, 138339, 138347, 138368 )
        addGearSet( 'talonclaw', 128808 )

        setArtifact( 'talonclaw' )

        addGearSet( 'the_shadow_hunters_voodoo_mask', 137064 )
        addGearSet( 'prydaz_xavarics_magnum_opus', 132444 )
        addGearSet( 'butchers_bone_apron', 144361 )
        addGearSet( 'call_of_the_wild', 137101 )
        addGearSet( 'helbrine_rope_of_the_mist_marauder', 137082 )
        addGearSet( 'roots_of_shaladrassil', 132466 )
        addGearSet( 'nesingwarys_trapping_threads', 137034 )
        addGearSet( 'sephuzs_secret', 132452 )
        addGearSet( 'frizzos_fingertrap', 137043 )
        addGearSet( 'kiljaedens_burning_wish', 144259 )


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
            health.current = min( health.max, health.current + ( health.max * 0.3 ) )
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
            if equipped.the_shadow_hunters_voodoo_mask then health.current = min( health.max, health.current + ( health.max * 0.2 ) ) end
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
            applyDebuff( 'target', 'lacerate', 12 )
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


    storeDefault( [[SimC Survival: biteFill]], 'actionLists', 20170423.221805, [[dSt(gaGEubBcvr7sP61ePzIkunBrDtcEosDBP8njQDk0EP2nu7xP0Hjnmj14qfPoVK40OmyLKHtOdkHESuDmr6COIWcvIwQeSyKSCepev1tblJOADOcPjIkuMkrzYcMUIlkrMgQcDzvxNiAJOIKTQKAZOkTDuPpIkI(orOplIMNsqptj0FfHrljnEur1jvk2grW1ucCpuH43qooQOCiufStTmdLWkv(btziQTBayn(Bxbss4Y4Qzo62vuS5CkwoBOWZxPVJYRtlxZJYxCp1ai(otZmoOddHDu(cwGHI9HHW0wMJPwMHsyLk)GxAa6eM4yyqjtM)EhHYbKeX0gksXYSPIbAr2mmCYeDefrnWV67sfqCF74XugeqH1kjQTBWquB3aiYMHHtUDfFefrnu45R03r51PLtRnSbhyDDqedye(geqHO2Ubpok3YmucRu5h8sdqNWehdNZKKjk(WoVegh4aIobVmCYtgIkYZaA2ZA)eD(o5nLHPx4I7sWqrkwMnvmqj50REsfd8R(Uube33oEmLbbuyTsIA7gme12nSuYPx9Kkgk88v67O860YP1g2GdSUoiIbmcFdcOquB3Ghhx0YmucRu5h8sdqNWehdNZKKjk(WoVegh4aIobVmCYtgIkYZaA2ZA)eD(o5nLHPx4I7sWqrkwMnvm0vc3BGF13LkG4(2XJPmiGcRvsuB3GHO2Ub(kH7nu45R03r51PLtRnSbhyDDqedye(geqHO2UbpoYJwMHsyLk)GxAa6eM4yiGM9S2prNVtEtzy6fU4UemuKILztfdzTFIo3a)QVlvaX9TJhtzqafwRKO2UbdrTDdCCTFIo3qHNVsFhLxNwoT2WgCG11brmGr4BqafIA7g844cSmdLWkv(bV0a0jmXXG2hg3N443yNMJKYZrZhp70NiE8KGEy4K7hRu5h4jpeqZo9jIhpjOhgo5(W6sz4KgksXYSPIbIkoisc6HWKEd8R(Uube33oEmLbbuyTsIA7gme12nuqfhez7kyimP3qHNVsFhLxNwoT2WgCG11brmGr4BqafIA7g84OeSmdLWkv(bV0GakSwjrTDdgIA7gG5pVDLmIkAydoW66GigWi8nuKILztfd0ZFoXqurd8R(Uube33oEmLHcpFL(okVoTCATbbuiQTBWJJLTmdLWkv(bV0GakSwjrTDdgIA7gkUDLGKKWjBxH4D7k(eKePnSbhyDDqedye(gksXYSPIbnrtss4KeiEt0jijsBGF13LkG4(2XJPmu45R03r51PLtRniGcrTDdECKtBzgkHvQ8dEPbbuyTsIA7gme12nWXiAseMMxg5BxXjjhRHBydoW66GigWi8nuKILztfdbIMeHP5LrEIKKJ1WnWV67sfqCF74Xugk88v67O860YP1geqHO2UbpoYjSmdLWkv(bV0GakSwjrTDdgIA7gkX5IzenJ73UsgrfnSbhyDDqedye(gksXYSPIHZ5IzenJ7tmev0a)QVlvaX9TJhtzOWZxPVJYRtlNwBqafIA7g84yATLzOewPYp4LgGoHjog4HaA27AEiir69H1LYWjnuKILztfdDnpeKiTb(vFxQaI7BhpMYGakSwjrTDdgIA7g4R5HGePnu45R03r51PLtRnSbhyDDqedye(geqHO2UbpEmaDctCm4Xga]] )

    storeDefault( [[SimC Survival: CDs]], 'actionLists', 20170423.221805, [[dSJihaGEcL0Mev2fbBtuvzFek1SPYnfLVPu1Tv4WQStvzVs7gY(Pknkkvdtv14evv9mcvnucf1GPkgov1bfHtrPCmr6EeQSqLslfPYIry5u8qvfRIqHwMiADekyIekYuvQmzLmDOUOsXPfCzW1PKnsOeBLO0Mr02vv6Xc9DKQMMOkmprvAKIQOpJKrJuEUIojrXFjY1evLZtipf1RjQ(nPBA3vEd6iCWQeLF3akZHXhVEylZ3W3Zjg865JyAwMoWb3e6l5F6()8iP4fslZ(qmCUGy9Wbf1xY8LVYjI4GIMDxFPDx5nOJWbRUTmhnbFCzSsr5aHOQULspAMZoPgTMcrlJbq48koX)BRCcIGlGfv(mXdbsy1yaeU8hAquEM(fgacxIYz6s2Z8UbuU87gq5eM4HaVE2PgdGWLPdCWnH(s(NUp9VSmOviEy1ugPiOCMUE3akxCFj7UYBqhHdwDBzoAc(4YyLIYbcrvDlLE0mNDclssHB6drSKskHPbsWr5ablFBLtqeCbSOYeGzcg5bev5p0GO8m9lmaeUeLZ0LSN5DdOC53nGYBbZemYdiQY0bo4MqFj)t3N(xwg0kepSAkJueuotxVBaLlUpX3DL3GochS62YC0e8XLXkfLdeIQ6wk9Ozo7ewKKc30hIyjLuctdKGJYbcw(2kNGi4cyrLjCQUKiTmIk)HgeLNPFHbGWLOCMUK9mVBaLl)UbuERt1LxpIflJOY0bo4MqFj)t3N(xwg0kepSAkJueuotxVBaLlUV8O7kVbDeoy1TL5Oj4JlJvkkhi4R4GIM5StyrskCtFiILusjmnqcokhiy5BRCcIGlGfv2xXbfv(dnikpt)cdaHlr5mDj7zE3akx(DdOSywXbfvMoWb3e6l5F6(0)YYGwH4HvtzKIGYz66DdOCX9LVUR8g0r4Gv3wMJMGpUmwPOCGquv3sPhnZzNWIKu4M(qelPKsyAGeCuoqWY3w5eebxalQmbyMGrEarv(dnikpt)cdaHlr5mDj7zE3akx(DdO8wWmbJ8aIYRh7P2kth4GBc9L8pDF6FzzqRq8WQPmsrq5mD9UbuU4(YVUR8g0r4Gv3wMJMGpUmwPOCGquv3sPhnZzpQQBP0JegkIs1jireWGqK2zOGP4(ZryrskmueLQtqI0YisWaJlGMIT4fJuXLTYjicUawu5j6Kds0SqyWu(dnikpt)cdaHlr5mDj7zE3akx(DdOmJo5Gxp5PfcdMY0bo4MqFj)t3N(xwg0kepSAkJueuotxVBaLlUV9Dx5nOJWbRUTmhnbFCzSsr5aHOQULspAMZUDclssHHIOuDcsKwgrcgyCb0mVIlnnhHfjPWqruQobjslJiblFB5Shv1Tu6rcKwgrskPeMgibhLdemW4cOPytyrskmueLQtqI0YisWaJlGM2SvobrWfWIkFtFiILusjmnqcokhu(dnikpt)cdaHlr5mDj7zE3akx(DdOCIPpeXE9OKE9GPbE9S5OCqz6ahCtOVK)P7t)lldAfIhwnLrkckNPR3nGYf3x(3DL3GochS62YC0e8XLXkfLdeIQ6wk9Ozo72jSijfgkIs1jirAzejyGXfqZ8kU95iSijfgkIs1jirAzejy5BZw5eebxalQ8n9HiwsjLW0aj4OCq5p0GO8m9lmaeUeLZ0LSN5DdOC53nGYjM(qe71Js61dMg41ZMJYbE9yp1wz6ahCtOVK)P7t)lldAfIhwnLrkckNPR3nGYfxCzoAc(4Yf3ca]] )

    storeDefault( [[SimC Survival: AOE]], 'actionLists', 20170423.221805, [[dmtDdaGEekTjrI2ff51uu7dHOzlQBIQUTuTtQAVKDdz)Oi)eHIHjP(nsdgL0WPuhKs6uiK6yuyHsslvKAXQQLtLhIGNQSmvP1HqYurPMSuMUkxevCzW1fjTvvrphrBxeFtsCyHPHc8zuItd1JLy0uIXJq1jvfoekORHI68OsptKWFrHgfcHLHyRXbf)m00xZhDqB4obMyDP6sWjrMOyIvRedhT0qgcsq(3AJk1m4nfMm0MnuWrgtSXHPi5FzMznRLdtrKIT8gITghu8Zqtv14PTNHZhDqtZhDqRAQxXc44Q9a1WL4OonefbAw)4m(4Q9t9kwahxncwGIzEAc0b0PVwAidbji)BTrfJAnEAZhDqtN8VITghu8Zqtv1wXHTpng2ONPsKph1M00HlMXiw0S(Xz8XvRe5ZrTj1iybkM5PjqhqN(A802ZW5JoOP5JoOriYNJAtQLgYqqcY)wBuXOw7bQHlXrDAikc04PnF0bnDYNcXwJdk(zOPQA802ZW5JoOP5JoOXH42zkjobyIv2UWw7bQHlXrDAikc0S(Xz8XvdiUDMsItagpxyRrWcumZttGoGo91sdziib5FRnQyuRXtB(OdA6KNbITghu8Zqtv1wXHTpTlYa6mrcoBaDmsEyelMau8ZqlLmSrptKGZgqhJKhgXIPdxmJrSOz9JZ4JRwjCjGgblqXmpnb6a60xJN2EgoF0bnnF0bncHlb0sdziib5FRnQyuR9a1WL4OonefbA80Mp6GMo5zwS14GIFgAQQ2koS9PfLdNamciOJbsIKznRFCgFC1kHlb0iybkM5PjqhqN(A802ZW5JoOP5JoOriCjatSsegeTwAidbji)BTrfJAThOgUeh1PHOiqJN28rh00PtBfh2(00jb]] )

    storeDefault( [[SimC Survival: default]], 'actionLists', 20170423.221805, [[d0JWhaGEueBscv2LeSnsjSpuPyMsiZwP5JkvDtr65GCBQ8nuODcQ9QA3iTFjnkQkggQyCsOQdtzOKszWsz4aYbLOtrvPJHqNhbwikyPOswmQA5IArIWtHwgvvRJQ0errQPIGMmknDfxeiDAHltCDa2iQuzRufTza12r0JLQ)cuttcLVtkrFgiEgPKgnP4qOi5KufEiP6AKs19qr9tuP0Vj51IOpXt4rqPg)kSN)iS5KJy40RneqMmiT1BTXkaBa25ixYkgKCy)CiYiNI5xRfiEebs6HTbtSju0d7x7A)yzFcff6eEyINWJGsn(vypdhXEoaAookqazLcbDKCgaqduX5ZyzqKPaRWdayGl0nOjOGuaaq(ESKp2yi4OdatyYkh11i9KPksXj058htvSEAzyZjhpcBo5ykaMWKvoYLSIbjh2phImsKZrpOSr3gv(ivrLJPkwyZjh)Cy)NWJGsn(vypdhXEoaAoo2k0PGwAeawbm4rJa2PssTrJTfeQXVc7Xs(yJHGJDBxWwFcff8gqZrpOSr3gv(ivrLJPkwpTmS5KJhHnNCu32T2k7tOO1wrb0CSmdc0rQ5eMtGHtV2qazYG0wV1MtLm1c6ybnXrUKvmi5W(5qKrICoQRr6jtvKItOZ5pMQyHnNCedNETHaYKbPTERnNkzQf0Xc6NdR1t4rqPg)kSNHJyphanh5bamWfCQKuB0yl4X6t0Hkanwpj3WSFUN7zQXwHof0sJaWkGbpAeWovsQnASTGqn(vypwYhBmeCSB7c26tOOG3aAo6bLn62OYhPkQCmvX6PLHnNC8iS5KJ62U1wzFcfT2kkGMAZhI(ESmdc0rQ5eMtGHtV2qazYG0wV1MotdL4ixYkgKCy)CiYiroh11i9KPksXj058htvSWMtoIHtV2qazYG0wV1Motd95Wf7eEeuQXVc7z4i2ZbqZrMIhaWaxWPOGOuqcyGbKjOaaGowYhBmeCSB7c26tOOG3aAo6bLn62OYhPkQCmvX6PLHnNC8iS5KJ62U1wzFcfT2kkGMAZh)(ESmdc0rQ5eMtGHtV2qazYG0wV1gqzHHyeTPXGKeh5swXGKd7NdrgjY5OUgPNmvrkoHoN)yQIf2CYrmC61gcitgK26T2aklmeJOnngK85WA)eEeuQXVc7z4i2ZbqZrRpbPawOIleiUHzTESKp2yi4y32fS1NqrbVb0C0dkB0TrLpsvu5yQI1tldBo54ryZjh1TDRTY(ekATvuan1MpA13JLzqGosnNWCcmC61gcitgK26T2k5wqtCKlzfdsoSFoezKiNJ6AKEYufP4e6C(JPkwyZjhXWPxBiGmzqAR3ARKBb9ZH1It4rqPg)kSNHJL8Xgdbh72UGT(ekk4nGMJEqzJUnQ8rQIkhtvSEAzyZjhpcBo5OUTBTv2NqrRTIcOP28Py(ESmdc0rQ5eMtGHtV2qazYG0wV1gFmI20yqsIJCjRyqYH9ZHiJe5CuxJ0tMQifNqNZFmvXcBo5igo9AdbKjdsB9wB8XiAtJbjFomJNWJGsn(vypdhl5Jngco2TDbB9juuWBanh9GYgDBu5JufvoMQy90YWMtoEe2CYrDB3ARSpHIwBffqtT5J299yzgeOJuZjmNadNETHaYKbPTERn(yeUl2nXrUKvmi5W(5qKrICoQRr6jtvKItOZ5pMQyHnNCedNETHaYKbPTERn(yeUl29ZHl(t4rqPg)kSNHJL8Xgdbh72UGT(ekk4nGMJEqzJUnQ8rQIkhtvSEAzyZjhpcBo5OUTBTv2NqrRTIcOP28rl89yzgeOJuZjmNadNETHaYKbPTERnGJDLmuIJCjRyqYH9ZHiJe5CuxJ0tMQifNqNZFmvXcBo5igo9AdbKjdsB9wBah7kzOpFoI9Ca0C8Zpa]] )

    storeDefault( [[SimC Survival: precombat]], 'actionLists', 20170423.221805, [[dmtVdaGEKcTlKsEnGA2cDteUTGDIYEj7g0(frdts(TudfPOblPmCk6GIWXq0cbKLsPAXaTCjEif8uLLbvwhuvAIqvXuHIjlQPd5IuONtjxw11rQQhJKTcGnJuQTdL(iuv1HPAAiv5Vukgjuv50OA0IKXJuXjLu9mKkDnkLopa9zOkBdPGVjsTifgnJqhm(Sa1yE4AJhmKS2OFblhRhX3K1mlNQdGosZ(J3TUy4QitxrpC0LwKAZ8uCpYPrhXBOy4S1wTeuiEdTegXifgnJqhm(SasJOZa4fMhUMgZdxZGhJjRrZJswJuRomZPCux0Gn8Aja5rocqnl6hcn0gZJ0mK6uat0yF4qKa1S)4DRlgUkY0KvAeDM5HRjKy4egnJqhm(SasBufUjsd14Hx80YSr8gAPLaKh5ia1mBeVHAgsDkGjASpCisGAeDgaVW8W10yE4A0Sr8gQz)X7wxmCvKPjR0QdZCkh1fnydVgrNzE4AcjgDfgnJqhm(SasJOZa4fMhUMgZdxZiDmJTfh7twdtXn1QdZCkh1fnydVwcqEKJau70Xm2wCS3guXn1mK6uat0yF4qKa1S)4DRlgUkY0KvAeDM5HRjKy0ty0mcDW4ZcinIodGxyE4AAmpCTH(JjRHP4MA1HzoLJ6IgSHxlbipYraQzH(J2GkUPMHuNcyIg7dhIeOM9hVBDXWvrMMSsJOZmpCnHeZwHrZi0bJplG0i6maEH5HRPX8W1WNIJxdTOnV8K1W)YHE(A1HzoLJ6IgSHxlbipYraQLloEn0I28YTbVYHE(AgsDkGjASpCisGA2F8U1fdxfzAYknIoZ8W1esmAqy0mcDW4ZcinIodGxyE4AAmpCn8ZlMDd1QdZCkh1fnydVwcqEKJaulLxm7gQzi1PaMOX(WHibQz)X7wxmCvKPjR0i6mZdxtiH0gvHBI0esca]] )

    storeDefault( [[SimC Survival: fillers]], 'actionLists', 20170423.221805, [[dGtceaGEbqBsjyxa1RbyFkHMTc3uOUTuTtrTxQDdA)srJcinma9Bu9CenyH0WvQoOu4uOihJO(gqSqIKLkilgLwoHhkepfAziyDePQhlYufOjROPl5IkLELaWZeqUokyAkrTvuuBwPy7sPtJ03vI8zb18isPdt6qePYOjIXlaDsuOBrKIRPKCELu)fHUSQvjGAl7Gg3cv2XNM1yw73is7rAgfzq0sB1H03m6g6yCbPXqFCL8otaOmiaxMqGalBe3FIQdAaQfLdDMWQvgBKkkhs6Gol7Gg3cv2XNwkJysq3lJAQOTN4HVtp5IYlu64Wcm5f7hwejlkmm4dv2XNliDtEbM8I9dlIKffggCrtaOWWgBWsh0ATXKkAVXisEcqmV99dlZAmMpzwfzTFJgZA)gJOI2Bm0hxjVZeakdImqJmcN0KwCHrihEJX8zw73OlNj4Gg3cv2XNwkJX8jZQiR9B0yw73yqjc(suy4MrBeWtAKr4KM0Ilmc5WBSblDqR1gljc(suyyIAapPXisEcqmV99dlZAm0hxjVZeakdImqJX8zw73OlNdKdACluzhFAPmIjbDVmQPI2EIh(o9KlsWydw6GwRnMur7ngrYtaI5TVFyzwJX8jZQiR9B0yw73yev0(MrbvMjJH(4k5DMaqzqKbAKr4KM0Ilmc5WBmMpZA)gD58YoOXTqLD8PLYiMe09YiOLooSaVKUMiFdXsYj25aGAjrhGpuzhFUaldB2aUZba1sIoiwAQOjsWI3vkKuAdNMbEzMm2GLoO1AJcDV4cIKLGc4gJi5jaX823pSmRXy(KzvK1(nAmR9BmKUxCrZOyjOaUXqFCL8otaOmiYanYiCstAXfgHC4ngZNzTFJUCELdACluzhFAPmIjbDVmUHNyGeCIbH4WArqbLWkPzdpXajyXdFyGdNMmfaRwXKXgS0bTwBuO7fxqKSeua3yejpbiM3((HLzngZNmRIS2VrJzTFJH09IlAgflbfWBgfuzMmg6JRK3zcaLbrgOrgHtAslUWiKdVXy(mR9B0LlJysq3lJUSb]] )

    storeDefault( [[SimC Survival: preBitePhase]], 'actionLists', 20170423.221805, [[d4dniaGEuQSjrI2fkzBIK8CuzMeu1HjnBr9njPBIQoVe52s50iTtH2l1UHA)kfJIGcdtjghkvvpwQgkbLmyLKHlIdkrDkck1XiYXfjyHsOLkblgflhXdjKNcwgHADOuftKGIMkrzYcMUIlkjMgbvUSQRlPYgrPiBvj1MjiBNaFeLQ03LuLptunpjv1ZqP05qPQmArQXlsOtQu6VskxdLc3dLI6qIK61kv)gYwYYmubRm5hmJHO2UbG2eTzfuhravGMzpBwLqEr6CHvAL7gk88vU7O4fPQlcNy2YsYaK8ovZu2PdfHDumBWggk3hkcZzzokzzgQGvM8dUObEuyTsIA7gme12nWMYkENILVzfme6(nSfhODDqedye(gkZqZ0PKbHYkENILxJBi09Bqu6335rcE74Xmgk88vU7O4fPQslg4rHO2Ubpok2YmubRm5hCrdqNqtgddsU88z1rOCavpmNHYm0mDkzGlHodflVwhXqudIs)(opsWBhpMXapkSwjrTDdgIA7gGe6muS8nReHyiQHcpFL7okErQQ0IHT4aTRdIyaJW3apke12n4Xr2AzgQGvM8dUObOtOjJHuhqdRS2prNZAO9DkwUHYm0mDkziR9t05geL(9DEKG3oEmJbEuyTsIA7gme12ni8A)eDUHcpFL7okErQQ0IHT4aTRdIyaJW3apke12n4XrHZYmubRm5hCrdqNqtgdAFOcETJFJEo2SukhnF8WI7KKJNACdflN1Xkt(HuM6aAyXDsYXtnUHILZAO9DkwUHYm0mDkzGOjdIuJBi09Bqu6335rcE74Xmg4rH1kjQTBWquB3qbnzqKnRGHq3VHcpFL7okErQQ0IHT4aTRdIyaJW3apke12n4Xr2WYmubRm5hCrd8OWALe12nyiQTBaM)8MvYiAIHT4aTRdIyaJW3qzgAMoLmWn)5Adrtmik9778ibVD8ygdfE(k3Du8IuvPfd8OquB3GhhtLLzOcwzYp4Ig4rH1kjQTBWquB3q5nR4RJeozZkKqBwjIGQhNHT4aTRdIyaJW3qzgAMoLmO1A1rcNudjuTobvpodIs)(opsWBhpMXqHNVYDhfVivvAXapke12n4XXQwMHkyLj)GlAGhfwRKO2UbdrTDdctIkhH5eIs(MvSxYXA4g2Id0UoiIbmcFdLzOz6uYqGOYryoHOKxto5ynCdIs)(opsWBhpMXqHNVYDhfVivvAXapke12n4Xr2VLzOcwzYp4Ig4rH1kjQTBWquB3qLumjJ4Oc(MvYiAIHT4aTRdIyaJW3qzgAMoLm8umjJ4OcETHOjgeL(9DEKG3oEmJHcpFL7okErQQ0IbEuiQTBWJJSplZqfSYKFWfnaDcnzmK6aAy118qqjCSgAFNILBOmdntNsg6AEiOeodIs)(opsWBhpMXapkSwjrTDdgIA7geP5HGs4mu45RC3rXlsvLwmSfhODDqedye(g4rHO2UbpokTyzgQGvM8dUObOtOjJHNc1rtsEGLqek7yhIRMquS8tgIMKYaAyL1(j6CwK3ukMR(SLvQmuMHMPtjdm1n90NuYGO0VVZJe82XJzmWJcRvsuB3GHO2UHI1n90NuYqHNVYDhfVivvAXWwCG21brmGr4BGhfIA7g84OKKLzOcwzYp4IgGoHMmgEkuhnj5bwcrOSJDiUAcrXYpziAskdOHvw7NOZzrEtPyU6ZwwPYqzgAMoLm0vIGBqu6335rcE74Xmg4rH1kjQTBWquB3GiLi4gk88vU7O4fPQslg2Id0UoiIbmcFd8OquB3GhhLeBzgQGvM8dUObOtOjJHaAyL1(j6CwK3ukMR(SLvQmuMHMPtjdzTFIo3GO0VVZJe82XJzmWJcRvsuB3GHO2UbHx7NOZ3SsyijSnu45RC3rXlsvLwmSfhODDqedye(g4rHO2UbpEmaDcnzm4Xga]] )

    storeDefault( [[SimC Survival: mokMaintain]], 'actionLists', 20170423.221805, [[daZ8baGEufTlq8AKmBa3uc3ws7uQ2Ry3OSFqzuOkmmLYVHAWGQHtPoOsQtHuvhdvwiQklfKwmqlhXdvsEQQLjrRdPIPsrMmKMovxuj6YexNsSvkuBwPA7usphIPHuP5rbDysFtjmAkQhlLtsboTIRHQQZJQ0FrkFNc5ziv5Wft5lzkiGGgW8UwL8p1vWGFleRJvfGoWGxXuf6WCDy5qfarrK0l34wSr3s6bHl)2sBuGHNQpyw6L8ZF(6MpygsmLoxmLVKPGacA4l)nYy75Gw23HuXum1nRa0CT5tdbcrQ6WqmKiGw23Pz0WqXgLVgCagN3CIA7ycneNmus(kZsJQaBvQcZdyEbg1yL01QKN31QKdvTDmbg87KHsYHkaIIiPxUXTGBl3ag60uhtYzyMKxGr7AvYJNEzmLVKPGacA4l)nYy75Gw23HuXum1nRa0CT5tdbcIRnkdlZxdoaJZBorTDmHgItgkjFLzPrvGTkvH5bmVaJASs6AvYZ7AvYHQ2oMad(DYqjWGZdo6NdvaefrsVCJBb3wUbm0PPoMKZWmjVaJ21QKhpE(BKX2ZJNa]] )

    storeDefault( [[SimC Survival: bitePhase]], 'actionLists', 20170423.221805, [[d0tefaGEGqTjkWUiPxlW(qb9CPA2cnFua3us(gkPBtPdlANiSxv7wP9tkgffzyOs)MQZJsnuuGgmP0WPqheu5uuuhtsDAKwiOyPOOwmGLlXdrjEkXYqfRJur9yPmvqvtgKPR4IaPxbe0LHUoqTruO2kPsBMeBhu6saHCiGiFgvnpui)frpJuHrlOVtQQtsQY0aI6AOiUhf0QqrABabghPI8Rp8xaDtGicDGlePfViullA0kGlWsHnJ6SgTa0bzWWSJxygJy2XtWHBnRCbzo6qT(IyeB0msbX5q99eCyctUaxBO(2p8NO(WFb0nbIi0H5I0kuJZftG0KrChv9t2KUc5eIKwpyZjmJQ4MareIbyaaWkkQwpyZjmJKt2gARRwqBs3odnX3GyQjDcePdZMnBaayffvRV8U3rsfWf2Q9jBbgccUahansh2xuaxyt6kKtisIjFeVO3crB54LlRV4Lkhs3SqKw8YfI0Ixym4cBnADfnANquJwqt(iEbUcF)cDhSuaBCiPkgAAYiUJQ(jBsxHCcrsRhS5eMrvCtGiczaayffvRhS5eMrYjBdT1vlOnPBNrgo0wa5qTO5lmJrm74j4WTM1AUxyjeBbvoSOf35axQCiI0Ix(Ccoh(lGUjqeHomxKwHACU0cZcp2zOHCmO5EeY1FvT(Y7EhjbOdQwqBs3oJ4BqmLZf4aOr6W(I1xE37ijaDWlSeITGkhw0I7CGlvoKUzHiT4LlePfVu5lV7DuJwyOdEHzmIzhpbhU1SwZ9IEleTLJxUS(IxQCiI0Ix(CcDC4Va6Mare6WCrAfQX5IjtaGvuuT(Y7EhjvaxyRwqBs3odnX3GyQPM7rix)v16lV7DKeGoOAlml8yheYXSzZg0Cpc56VQwF5DVJKa0bvBHzHh7mYWAZgasaGvuuZUrSnKUc5eIKyYhrvWgVahansh2xuI5gqxEY(uOb4fwcXwqLdlAXDoWLkhs3SqKw8YfI0IxyCm3a6YRrRmfAaEHzmIzhpbhU1SwZ9IEleTLJxUS(IxQCiI0Ix(Ccq(WFb0nbIi0H5I0kuJZfaWkkQwF5DVJKkGlSvbB8cCa0iDyFX6lV7DKeGo4fwcXwqLdlAXDoWLkhs3SqKw8YfI0IxQ8L39oQrlm0b1O1uT5lmJrm74j4WTM1AUx0BHOTC8YL1x8sLdrKw8YNtWKd)fq3eiIqhMlvoKUzHiT4LlePfVW4yUb0LxJwzk0auJwt1MVO3crB54LlRV4f4aOr6W(Ism3a6Yt2NcnaVWsi2cQCyrlUZbUWmgXSJNGd3AwR5EPYHislE5ZNlsRqnox(8d]] )


    storeDefault( [[Survival Primary]], 'displays', 20170423.221805, [[d8d5haWyKA9kQEjfs7cckBdjI(nuZKc10OqmBfopfDtiWPr5BuvQJjvTtkTxXUjz)qQFcjddvnoKi1Lv1qj0GHOHJWbLkhfjsoSKZHeHfkLwksyXuLLt0dLcpfSmPONtQjcbzQiAYOIPR0fvHRsvjpJcQRRsBKQQTcbvBMkTDv0hvu8AfL(ms67kYiPawhfOrtW4HqNev6wir11OGCpKO0TPI1IefhNQItFidqxeldR8JvlSMJpakFrAmx7ra6IyzyLFSAb28p2(MbKLI63q4PNnTb8gS5ZNzGNIxatuUU6FBueldR0XYharuUU6FBueldR0XYhGqYCkPjxAScyZ)yncFahMQ7i2Mb85(3NtJIyzyLoTbmr56Q)LSKu)vhlFak19VVoKX2hYahQYB8CsBGo6LHvOrAmtVXsjcylNpafxDjyq0ijKpn2XR2au8JV0FSn579nFppFaGwYi2alZ5PS8zJTzidCOkVXZjTb6OxgwHgPXm9glLoGTC(auC1LGbrJKZ7w3XgGIF8L(JTjFVV5755ZMnGwapbtSLwO7iTb0c4PU7ItBaTaEcMylTq3DXPnWwsQ)2POfWYaTOijrHak4oJbidyglL3KsYhaXy5dOfWtKLK6V60gywVofTawgGeLifCNXaKbOXoE1kEEeVa0fXYWQofTawgOffjjkeeaiEAwnyZRLHvX20qgkGwapbKPnGp3)(iet(0ldRcqb3zmaza11HlnwPJ1ib0e)y4FuAHg4bwgYavS9bKX2hGAS9b8ITpBaTaEQrrSmSsN2aiIY1v)B3vwXYhOUYI0K4d4DDDd4ui2DxCS8bQbHq1nMktT45rS9bQbHqbc4jXZJy7dudcHQb2XRwXZJy7dGqVBDhBAduJPYulEkM2aNmnZJnyRjPjXhWlaDrSmSQBWOQc04WsEqraomnXOmjnj(avazPO(KMeFGYJnyRzG6kleWuFAd4ZLrplcNPH1C8bQaZ65hRwGn)JTVzaB58bGR8KDwd0ifLmNsAgOgecfzjP(R4PyS9bmr56Q)LRIdJUwSuhlFa5pc04WsEqranXpg(hLwiEbQbHqrwsQ)kEEeBFaMIdJUwSStrlGLbOG7mgGmGp3)(C4Q4WORfl1PnGdt1DxCS8bQRS6u0cyzGwuKKOqGXh(jdSLK6V(XQfwZXhaLVinMR9iackezoxh0ijzoFSgMpaJgRaIIMPOgRHca0sgXgiqnieQUXuzQfpfJTpqDLfxLlM0K4d4DDDdqizoL00pwTaB(hBFZaeYNg74vBNOXbaMtd0iHR8KDwddIgjH8PXoE1gqlGN6UYIRYfhVaofIDhXYhGSgVArJCgj(selFGTKu)v88iEbeLmNsAIgzJIyzyvaTSwgoGwapz030JP4Wuu1PnaN3TUJTt04aaZPbAKWvEYoRHbrJKZ7w3XgWeLRR(xJ2QJLY7dGikxx9VKLK6V6y5dmRNFSAH1C8bq5lsJ5ApcyIY1v)B3vwXYhqlGN4Q4WORfl1PnqniekqapjEkgBFGAmvMAXZJ0gOUYci(XGlcflFaTaEs88iTbOXoE1kEkgVaZ65hR2aIKOrcLsJgPTKs8uaTaEQ7iTb0c4jXtX0gWHPaYy5dSLK6V(XQfyZ)y7BgaruUU6FnARow(a0fXYWk)y1gqKensOuA0iTLuINcudcHQb2XRwXtXy7dCOkVXZjTb0mhIX3H6i2Mb8gS5ZNzGN6gJ4fWfR2ahisiFTEQmdSLK6VINIXlGp3)(DdgvLZR2a0bO4hFP)yBY37BEJW3eH1ByEEdBOaIsMtjnrJSrrSmScnYURScGaSIkgRF0i9FLMb85(3NdxAScyZ)yncFaNcrGm2(amASIYGXoXAy(a(C)7ZXpwTaB(hBFZaBjP(RFSAdisIgjuknAK2skXtb85(3NJrB1PnaIOCD1)YvXHrxlwQJLpqDLLVuSnaXOmFz2ea]] )

    storeDefault( [[Survival AOE]], 'displays', 20170423.221805, [[dae7haqisc1MqKIBrfv2fvu1WiLJjLwgv4zKKAAKeDnejFtfuJJKaNJKGwhjj3drkDqfSqf5HsrtufKlQO2Ou4JQaJKkkNev6LKuAMKuDtvO2jL(jenus1rrKQwQkQNcMksUkjfBLKqwlIuzVIbdPoSKftIhJutgvCzvTzQ0NruJgvDAuETkKzlv3MQSBc)gQHJWXPISCkEortxPRRsBhcFxHgpI48uvRxfz)qYPnubOlILHfnWIfw)(haPAOuNRDoaDrSmSObwSa70hBRJaMsq(BY)0hLPakD2Pth0XJrjGpsxx5VnlILHfYy1cqcsxx5VnlILHfYy1c409VphU0ybWo9XQsTasE84W1uCfU4OeWP7FFonlILHfYmfWhPRR8xQYq(xzSAbi93)(YqfBBOcmlkL(ZjtbgOxgwGcT6m5gRkmGT8(aNVYIxvOqtyEASNsTbo)9VKFSo0ApSwRMwaG2Wi2alZ7jTAzJ1rOcmlkL(ZjtbgOxgwGcT6m5gRkiGT8(aNVYIxvOqZ5DRBFdC(7Fj)yDO1EyTwnTSzdi5XJWiBP5hMZuasq66k)LQmK)vgRwajpEegzln)WDXzkWwgY)oiO5XMatiPOqE8zUh4mQa(X6CoAjvaxSydmtcH5LYXYpGKhpsvgY)kZuGJuge08ytakK6N5EGZOcqJ9uQvhXCucqxeldlge08ytGjKuuipoaq80SQZovldlI1bPivajpEeOYuaNU)9peZ80ldlcCM7boJkG46XLglKXQYasIV3B0ljFtChBcvGk22aMyBdqo22akX2MnGKhp2SiwgwiZuasq66k)D4AQy1cuxtr5t8buUUUb8ksgUlowTavNGVg6JLVuhXCSTbQobFb84rDeZX2gO6e8vtSNsT6iMJTnWHE3623mfO6JLVuhHEMcGGjzkSoB9P8j(akbOlILHfdDgzrGMZwQ5Zb4WKe9YNYN4dqhWucYpLpXhOuyD26hOUM6yM4ZuaNUm6JurmjS(9pqf4iLgyXcStFSTocylVpaCniyiQok0diNdOByELXhf6MfXYWcuOhUMkWXybzmw(Oq34A8d4Xed3fhRJaMVhO5SLA(CajX37n6LKpkbQobFrvgY)QJyo22a(iDDL)YvWHrxl2iJvlGt3)(C4k4WORfBKzkaJglaIIMjihlPcuxtniO5XMatiPOqES6ZnOcSLH8VnWIfw)(haPAOuNRDoWXfjmVRhk0umVpwvRfWRibOIvlaqByeBajtqU)KgvCDxCGQtWxd9XYxQJqp22a11uCfUykFIpGY11naHH5vg)gyXcStFSTocqyEASNsTd6QhayEnrHgUgemevxvOqtyEASNsTbK84XH7IJsaVIKH5y1cqv9xSOqFGbFjIvlWwgY)QJyokbK84r1((kmbhMGSmtbo)9VKFSo0ApSMk1C48TQwtt1KkaN3TU9Dqx9aaZRjk0W1GGHO6QcfAoVBD7BaFKUUYFv7KmwNRnWwgY)2al2a6uOqdLqIcTTmg8yGJuAGflS(9pas1qPox7CaFKUUYFhUMkwTasE8ixbhgDTyJmtbQobFb84rDe6X2gO6JLVuhXCMcuxtbeFVZ9qXQfqYJh1rmNPa0ypLA1rOhLahP0al2a6uOqdLqIcTTmg8yajpECyokbK84rDe6zkGhtauX6iWwgY)2alwGD6JT1rasq66k)vTtYyBdqxeldlAGfBaDkuOHsirH2wgdEmq1j4RMypLA1rOhBBGzrP0FozkGK5r0)bKZX6iGsND60bD84qVhLaoD)7p0zKfEVydqhyld5F1rOhLavNGVOkd5F1rOhBBaDdZRm(Oq3SiwgweqAQLHdqyyELXNlnwaStFSQulatWHrxl2miO5XMaN5EGZOc4XedZX6iaJgliDySxSQwlGt3)(CAGflWo9X26iajXQfWP7FFoQDsMPaKG01v(lxbhgDTyJmwTa11uQrW2ae9Y)nzta]] )


    ns.initializeClassModule = HunterInit

end
