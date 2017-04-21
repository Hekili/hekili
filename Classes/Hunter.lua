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


    storeDefault( [[SimC Survival: nomok]], 'actionLists', 20170402.130035, [[diKHBaqiKkuBsumkb0PeOwLaOEfsfKBHuHyxOQHbshdrwgr5zGGPjaCnrPSnrP6BGsJdboNaiRdPcP5bcDpbY(eLCqqXcLuEOK0erQaxeeTrbO(isLIrIub1jrQAMivkDte1orLLIGEkPPkPAVQ(lvAWuHdR0Iv4Xu1KL4YqBgjFMiJwuDAcVgHMTi3wr7wQFtz4GQJJuPA5O8CHMoW1f02LeFNkA8ivY5rkRhPIMVaK9tu9j96xHS3rclV2vUDIxvXSQChAiRIOYMOJk3rBtJ4vfo6fBsqNlqy95KLTSDLqmHBepNmOKGfkeGauEzqHauia7v1ZeWbxVcJhiSo(6NJ0RFfYEhjS8Ax52jEvHlaarlj3rvBW2RQNjGdUcmjPeY7nlvmNDmtGJqkk(P1sMfrxQqgn(siBbcRZkigsXWyURtrxmNz8MLkMZMFATKzr0DiaiVpFzsymRGGMzesrXpTwYSi6sfYOXhbRNiedGGVwnh9ejBvWj2GpUsiMWnINtgusWcLGR03fHFbg7ABnEfMHija0UgHlaarl56TbBVs2kC7eVEW5K96xHS3rclV2vUDIxvaIj5oQZw4xvptahCDesrXpTwYSi6sfYOXxczlqyDwbXqkggZDDk6I5mZiKIIFATKzr0LkKrJpcwpris6A1C0tKSvbNyd(4kHyc3iEozqjblucUsFxe(fySRT14vygIKaq7AeGyYfWw4xjBfUDIxp4Cq41VczVJewETRC7eVcJChKdzfKj3Hrj3rvM5mEv9mbCWvVzPI5S5NwlzweDhcaY7ZxMegZkiOzgHuu8tRLmlIUuHmA8rW6jcXa4A1C0tKSvbNyd(4kHyc3iEozqjblucUsFxe(fySRT14vygIKaq766odzfK5AuUEM5mELSv42jE9GZfaV(vi7DKWYRDLBN4vTxIOCh0HdBaYUQEMao4kWKKsiV3SuXC2XmbUEGWA(P1sMfr3HaG8(8LjHrige0mJqkk(P1sMfrxQqgnEgoxrhZccbyjFjdqmXSiLTGVwnh9ejBvWj2GpUsiMWnINtgusWcLGR03fHFbg7ABnEfMHija0Ug7Li6Mh2aKDLSv42jE9GZLTx)kK9osy51UYTt8A1nbyg84v1ZeWbxdCesrXpTwYSi6sfYOXxczlqyDwbXqkggZDDk6I5mZiKIIFATKzr0LkKrJpcwprigazOJlgG3VjaZGh5bcprrlf81Q5ONizRcoXg8XvcXeUr8CYGscwOeCL(Ui8lWyxBRXRWmejbG2v)MamdE8kzRWTt86bNl7V(vi7DKWYRDLBN41aoTnrrlj3HcycI4v1ZeWbx9MLkMZMFATKzr0DiaiVpFzsyeIbrkZiKIIFJWrpW1OCb5OlUsjKNHZv0XScIHummM76u0fZ51Q5ONizRcoXg8XvcXeUr8CYGscwOeCL(Ui8lWyxBRXRWmejbG2vQ02efTKBeWeeXRKTc3oXRhCoyF9Rq27iHLx7k3oXRvxwf8Q6zc4GRiDpuahow4Pyc6KoTOlLOLqgGTWZumaFA9iBbipq4jkAPmfdWNwpYwaYZqkggZ3rcZqz(WiVpKXWgKv2ZwMriff)0AjZIOlviJgpdNROJzfedPyym31POlMZRvZrprYwfCIn4JReIjCJ45KbLeSqj4k9Dr4xGXU2wJxHziscaTR(LvbVs2kC7eVEW5i41VczVJewETRC7eVwle4ZrgTRQNjGdUI09qbC4yHNIjOt60IUuIwcza2cptXa8P1JSfG8aHNOOLYumaFA9iBbipdPyymFhjmdL5dJ8(qgdBqwzpBzgHuu8tRLmlIUuHmA8mCUIoMvqmKIHXCxNIUyoVwnh9ejBvWj2GpUsiMWnINtgusWcLGR03fHFbg7ABnEfMHija0Uocb(CKr7kzRWTt86bNla96xHS3rclV2vUDIxPBxpYwaEv9mbCW1riff)0AjZIOlviJgFjKTaH1zfedPyym31POlMZmmKIHX8DKWmEZsfZzZpTwYSi6oeaK3NVmjmge0mJqkk(P1sMfrxQqgn(iy9eHOSakGgHuu8tRLmlIUuHmA8fZzNXBwQyoB(P1sMfr3HaG8(8LjHricHmmKIHX8DKWRvZrprYwfCIn4JReIjCJ45KbLeSqj4k9Dr4xGXU2wJxHziscaTRP1JSfGxjBfUDIxp4CKG(6xHS3rclV2vUDIxPdyRK1rkbdL7GUHH9wWRQNjGdUocPO4NwlzweDPcz04lHSfiSoRGyifdJ5UofDXCMXBwQyoB(P1sMfr3HaG8(8LjHrigePmJqkk(P1sMfrxQqgn(iy9eHiecOaAesrXpTwYSi6sfYOXxmNDgVzPI5S5NwlzweDhcaY7ZxMegHieUwnh9ejBvWj2GpUsiMWnINtgusWcLGR03fHFbg7ABnEfMHija0UwyRK1rkbdDLyyVf8kzRWTt86bNJePx)kK9osy51UYTt8kK0f8Kffvq5oQZw4xvptahCDesrXpTwYSi6sfYOXxczlqyDwbXqkggZDDk6I5mJ3SuXC28tRLmlIUdba595ltcJzfe0mJqkk(P1sMfrxQqgn(iy9eHyaCTAo6js2QGtSbFCLqmHBepNmOKGfkbxPVlc)cm212A8kmdrsaODfPl4jlkQGUa2c)kzRWTt86bNJKSx)kK9osy51UYTt8kHlCGXK7qbmbr8Q6zc4GRGnHnGpIm4ydCJarlXJ9osyjtXa8rKbhBGBeiAjEgsXWy(osyMriff)0AjZIOlviJgFeSEIqecz8MLkMZMFATKzr0DiaiVpFzsyeIKUwnh9ejBvWj2GpUsiMWnINtgusWcLGR03fHFbg7ABnEfMHija0UYw4aJ5gbmbr8kzRWTt86bNJeeE9Rq27iHLx7k3oXRbCiJMChgLChGCuUdixPeEv9mbCW1riff)0AjZIOlviJgFeSEIbL9mEZsfZzZpTwYSi6oeaK3NVmjmcXGiDTAo6js2QGtSbFCLqmHBepNmOKGfkbxPVlc)cm212A8kmdrsaODLkKrZ1OCb5OlUsj8kzRWTt86bNJua86xHS3rclV2vUDIxjBTKzruUJAcaEv9mbCW1riff)gHJEGRr5cYrxCLsiFi8mJqkk(P1sMfrxQqgn(q4xRMJEIKTk4eBWhxjet4gXZjdkjyHsWv67IWVaJDTTgVcZqKeaAxNwlzweDhcaELSv42jE9GZrkBV(vi7DKWYRDLBN4vyIWrpqUdJsUdqok3bKRucVQEMao4kWKKsiV3SuXC2XmbocPO4NwlzweDPcz04dHNzesrXpTwYSi6sfYOXxczlqyDwzpJ3SuXC28tRLmlIUdba595ltcJzfKSGVwnh9ejBvWj2GpUsiMWnINtgusWcLGR03fHFbg7ABnEfMHija0UUr4Oh4AuUGC0fxPeELSv42jE9GZrk7V(vi7DKWYRDLBN41aoKrtUdJsUdqok3bKRucL7iqsbFv9mbCWvVzPI5S5NwlzweDhcaY7ZxMegHyqKYmcPO4NwlzweDPcz04lHSfiSoRSFTAo6js2QGtSbFCLqmHBepNmOKGfkbxPVlc)cm212A8kmdrsaODLkKrZ1OCb5OlUsj8kzRWTt86bNJeSV(vi7DKWYRDLBN41aoTnrrlj3HcycIOChbsk4RQNjGdU6nlvmNn)0AjZIO7qaqEF(YKWiedIuMriff)0AjZIOlviJgpdNROJzfij6qRhiSMFATKzr0DiaiVpFzsymal5lbFTAo6js2QGtSbFCLqmHBepNmOKGfkbxPVlc)cm212A8kmdrsaODLkTnrrl5gbmbr8kzRWTt86bNJebV(vi7DKWYRDLBN4vYwlzweL7OMaGYDeiPGVQEMao46iKIIFATKzr0LkKrJpeEMriff)0AjZIOlviJgpdNROJq0BwQyoB(nch9axJYfKJU4kLqEgoxrhVwnh9ejBvWj2GpUsiMWnINtgusWcLGR03fHFbg7ABnEfMHija0UoTwYSi6oea8kzRWTt86bNJua61VczVJewETRC7eVgWPTjkAj5ouatqeL7iqzbFv9mbCWvWMWgWVTyUjxrhbI2dI8yVJewY4nlvmNn)0AjZIO7qaqEF(YKWieHW1Q5ONizRcoXg8XvcXeUr8CYGscwOeCL(Ui8lWyxBRXRWmejbG2vQ02efTKBeWeeXRKTc3oXRhCozqF9Rq27iHLx7k3oXRkCbaiAj5oQAd2k3rGKc(Q6zc4GRatskH8EZsfZzhVwnh9ejBvWj2GpUsiMWnINtgusWcLGR03fHFbg7ABnEfMHija0UgHlaarl56TbBVs2kC7eVEW5Kr61VczVJewETRC7eVQaetYDuNTWL7iqsbFLqmHBepNmOKGfkbxHziscaTRraIjxaBHFL(Ui8lWyxBRXRvZrprYwfCIn4JRKTc3oXRhCozYE9Rq27iHLx7k3oXRWi3b5qwbzYDyuYDuLzoJYDeiPGVsiMWnINtgusWcLGRWmejbG211DgYkiZ1OC9mZz8k9Dr4xGXU2wJxRMJEIKTk4eBWhxjBfUDIxp4CYGWRFfYEhjS8Ax52jET6MamdEuUJajf8v1ZeWbxdKoUyaE)MamdEKhi8efTuWxRMJEIKTk4eBWhxjet4gXZjdkjyHsWv67IWVaJDTTgVcZqKeaAx9BcWm4XRKTc3oXRhCozbWRFfYEhjS8Ax52jEfs6cEYIIkOCh1zlC5ocKuWxjet4gXZjdkjyHsWvygIKaq7ksxWtwuubDbSf(v67IWVaJDTTgVwnh9ejBvWj2GpUs2kC7eVEW5KLTx)kK9osy51UYTt8A1LvbL7iqsbFv9mbCWvKUhkGdhl8umbDsNw0Ls0sidWw4zkgGpTEKTaKhi8efTuMIb4tRhzla5zifdJ57iHzOmFyK3hYyydYk7z7A1C0tKSvbNyd(4kHyc3iEozqjblucUsFxe(fySRT14vygIKaq7QFzvWRKTc3oXRhCozz)1VczVJewETRC7eVwle4Zrgn5ocKuWxvptahCfP7Hc4WXcpftqN0PfDPeTeYaSfEMIb4tRhzla5bcprrlLPya(06r2cqEgsXWy(osygkZhg59Hmg2GSYE2Uwnh9ejBvWj2GpUsiMWnINtgusWcLGR03fHFbg7ABnEfMHija0Uocb(CKr7kzRWTt86bNtgSV(vi7DKWYRDLBN4v621JSfGYDeiPGVQEMao4kdPyymFhj8A1C0tKSvbNyd(4kHyc3iEozqjblucUsFxe(fySRT14vygIKaq7AA9iBb4vYwHBN41doNmcE9Rq27iHLx7k3oXR0bSvY6iLGHYDq3WWElOChbsk4ReIjCJ45KbLeSqj4kmdrsaODTWwjRJucg6kXWEl4v67IWVaJDTTgVwnh9ejBvWj2GpUs2kC7eVEW5KfGE9Rq27iHLx7k3oXR1ZzMtrlj3bm0fgVQEMao4Q3SuXC28GCM5u0sUlDHrEF(YKWyqYUwnh9ejBvWj2GpUsiMWnINtgusWcLGR03fHFbg7ABnEfMHija0UcYzMtrl5U0fgVs2kC7eVEW5Ga0x)kK9osy51UYTt8kzRLmlIYDutaq5ocuwWxvptahCnqF(YKWywbjlJ3SuXC28tRLmlIUdba5z4CfDeIbXqkggZDDk6I5mGciF(YKWyqqi4RvZrprYwfCIn4JReIjCJ45KbLeSqj4k9Dr4xGXU2wJxHziscaTRtRLmlIUdbaVs2kC7eVEW5GaPx)kK9osy51UYTt8AaN2MOOLK7qbmbruUJaHqWxjet4gXZjdkjyHsWvygIKaq7kvABIIwYncycI4v67IWVaJDTTgVwnh9ejBvWj2GpUs2kC7eVEW5GGSx)kK9osy51UYTt8ATqGphz0K7iqzbFLqmHBepNmOKGfkbxHziscaTRJqGphz0UsFxe(fySRT141Q5ONizRcoXg8XvYwHBN41doheGWRFfYEhjS8Ax52jETEoZCkAj5oGHUWOChbsk4ReIjCJ45KbLeSqj4kmdrsaODfKZmNIwYDPlmEL(Ui8lWyxBRXRvZrprYwfCIn4JRKTc3oXRhCoieaV(vi7DKWYRDLBN4vcx4aJj3HcycIOChbsk4RQNjGdUsz(WiVpKXWgKfSzJoI3SuXC28uPTjkAj3iGjiI8mCUIogGPmFyKNHsyFTAo6js2QGtSbFCLqmHBepNmOKGfkbxPVlc)cm212A8kmdrsaODLTWbgZncycI4vYwHBN41do4kDasTHjWRDWpa]] )

    storeDefault( [[SimC Survival: moknathal]], 'actionLists', 20170402.130035, [[deeGHaqiQcsBsumkskNIKQvHkLBrvu7sjddsDmuLLrv1ZqjmnuICnrjBJQiFdsmosIZHsuSouIknpuP6EIsTpujheLQfQQ0dvvmruIsxesAJufuFeLOQrIsuXjjjntQcIBIQANKyPOuEkLPIsAVi)LugmvLdl1IvLht0KH4YGnlYNjvJwuDAcVwPmBjDBj2Tk)wy4QQoovHy5q9CQmDfxhfBxPY3vQA8ufsNhvSEQcmFQc1(PknXJyLmuV(vbe6lzkDbiZeLpE9zm4DIDDLLRxFLy76jVRKz)Gu0vHh0JiosXFwzrgBqfAhqk(rZdf0SGfOx(rZc0SafYmjw8pKrg7YreNJyLu4rSsgQx)Qac9LmLUaKXw)pb2RpBWInGmtIf)dzpMuAvITRN8UQnTCes3YnTCJ7zZJSp5GCJFSdkWn0Jm2Gk0oGu8JMhkOvHmvpeHSNat2fhqg7prvmCid3)tG1CdwSbKXpqu6cqgnKIFIvYq96xfqOVKP0fGm26)jWE9zdwSbE9Pgp1jZKyX)q2JjLwLy76jVRAtlhH0TWqPfNJ7yiHbxU2EXHe7j7toi34h7GcCd9iJnOcTdif)O5HcAvit1dri7jWKDXbKX(tufdhYW9)eyn3GfBaz8deLUaKrdPWcIvYq96xfqOVKP0fGm76nWRpwom3ayYmjw8pKnHUEfwYiQiX(ZLrnzevKy)TkXPhHd0EIbwY8gRdoUNn6mpMuAvItpchOLyWCwyO0IZXfl4MUejZikax8YsDY(KdYn(XoOa3qpYydQq7asXpAEOGwfYu9qeYEcmzxCazS)evXWHm31BGwoZnaMm(bIsxaYOHuyjIvYq96xfqOVKP0fGm7xmJ40967t8WnzMel(hYMqxVclzevKy)5YO2JjLwL40JWbAjgmNfcdUhrCCLngsyWLRTxCiX(mYiQiX(BvItpchO9edSK5nwhCCLn6mpMuAvItpchOLyWCwUPLBCNLY8ysPvj2UEY7Q20YriDl30YTSzH6K9jhKB8JDqbUHEKXguH2bKIF08qbTkKP6HiK9eyYU4aYy)jQIHdzUFXmItxtgpCtg)arPlaz0qkzrSsgQx)Qac9LmLUaKzdavV(yf3)KzsS4Fi7XKsRsC6r4aTedMZcHb3JioUYgdjm4Y12loKyFMhtkTkXPhHd0smyol30YnUZJSp5GCJFSdkWn0Jm2Gk0oGu8JMhkOvHmvpeHSNat2fhqg7prvmCiZnau1gC)tg)arPlaz0qkEIyLmuV(vbe6lzkDbiJDV(4ZGraSxFrYRVp4yVJmtIf)dzPqY4wsgmgUHRSYYZpMuAvITRN8UQnTCes3cdLwCoULcjJBHbD4Y8ysPvjo9iCGwIbZz5MwUXDwkZJjLwL40JWbAjgmNfcdUhrCCLngsyWLRTxCiXEY(KdYn(XoOa3qpYydQq7asXpAEOGwfYu9qeYEcmzxCazS)evXWHSwRWGraSwK0K4yVJm(bIsxaYOHuqHyLmuV(vbe6lzkDbiZdx7BtC6E9zdwSbKzsS4Fitgrfj2FRsC6r4aTNyGLmVX6GJ7zZltkKmULKbJHB4cLS88JjLwLy76jVRAtlhH0TWqPfNJBPqY4wyqhoY(KdYn(XoOa3qpYydQq7asXpAEOGwfYu9qeYEcmzxCazS)evXWHSuTVnXPR5gSydiJFGO0fGmAifviwjd1RFvaH(sMsxaY(04DazMel(hYapcJ4)hqwjSWd8GWPLeNoGhC)NbjMvTLaUhync5M40ZGeZQ2sa3dSWqcdU8(vHmPqY4wsgmgUHlpLLNFmP0QeBxp5DvBA5iKUfgkT4CClfsg3cd6WL5XKsRsC6r4aTedMZcdLwCoUYgdjm4Y12loKypzFYb5g)yhuGBOhzSbvODaP4hnpuqRczQEiczpbMSloGm2FIQy4qMSX7aY4hikDbiJgsHLHyLmuV(vbe6lzkDbi7lZiZbmhYmjw8pKbEegX)pGSsyHh4bHtljoDap4(pdsmRAlbCpWAeYnXPNbjMvTLaUhyHHegC59RczsHKXTKmymCdxEklp)ysPvj2UEY7Q20YriDlmuAX54wkKmUfg0HlZJjLwL40JWbAjgmNfgkT4CCLngsyWLRTxCiXEY(KdYn(XoOa3qpYydQq7asXpAEOGwfYu9qeYEcmzxCazS)evXWHShZiZbmhY4hikDbiJgsHhAIvYq96xfqOVKP0fGmpKwc4EaYmjw8pKHHegC59RczutTuizCljdgd3Wvwz55htkTkX21tEx1MwocPBHHsloh3sHKXTWGoCzEmP0QeNEeoqlXG5SqyW9iIJRSXqcdUCT9Idj2Nrgrfj2FRsC6r4aTNyGLmVX6GlB0zEmP0QeNEeoqlXG5SCtl34olu3J9y1sHKXTKmymCdxEklp)ysPvj2UEY7Q20YriDlmuAX54wkKmUfg0HlZJjLwL40JWbAjgmNfsS)YiJOIe7Vvjo9iCG2tmWsM3yDWXDwOU6K9jhKB8JDqbUHEKXguH2bKIF08qbTkKP6HiK9eyYU4aYy)jQIHdz1wc4EaY4hikDbiJgsHhpIvYq96xfqOVKP0fGSpDDWXVJmtIf)dzQ9ysPvjo9iCGwIbZzHWG7rehxzJHegC5A7fhsSpZJjLwL40JWbAjgmNLBA5g35LXdfjMLSRdo(DRri3eNU6K9jhKB8JDqbUHEKXguH2bKIF08qbTkKP6HiK9eyYU4aYy)jQIHdzYUo443rg)arPlaz0qk88tSsgQx)Qac9LmLUaKHQh9VgoXoWRpwX9pzMel(hYEmP0QeNEeoqlXG5SqyW9iIJRSXqcdUCT9Idj2Nrgrfj2FRsC6r4aTNyGLmVX6GlB0zEmP0QeNEeoqlXG5SCtl34opY(KdYn(XoOa3qpYydQq7asXpAEOGwfYu9qeYEcmzxCazS)evXWHmWJ(xdNyhOn4(Nm(bIsxaYOHu4XcIvYq96xfqOVKP0fGSVmJmhWC86tnEQtMjXI)HSwoIDGgCqraoU4Ljfsg3sYGXWnC5PS88JjLwLy76jVRAtlhH0TWqPfNJBPqY4wyqhUmQ9ysPvjo9iCGwIbZzHe7pp2JFmP0QeNEeoqlXG5SWqPfNJlDjc3KrurI93QeNEeoq7jgyjZBSo4uNSp5GCJFSdkWn0Jm2Gk0oGu8JMhkOvHmvpeHSNat2fhqg7prvmCi7XmYCaZHm(bIsxaYOHu4XseRKH61VkGqFjtPlazFA8oWRp14PozMel(hYA5i2bAWbfb44IxMuizCljdgd3WLNYYZpMuAvITRN8UQnTCes3cdLwCoULcjJBHbD4YO2JjLwL40JWbAjgmNfsS)YKcjJBjzWy4gU8uwE(XKsRsSD9K3vTPLJq6wyO0IZXTuizClmOdNh7XpMuAvItpchOLyWCwyO0IZXLUeHBYiQiX(BvItpchO9edSK5nwhCzsHKXTKmymCdxOG2ZpMuAvITRN8UQnTCes3cdLwCoULcjJBHbD4uNSp5GCJFSdkWn0Jm2Gk0oGu8JMhkOvHmvpeHSNat2fhqg7prvmCit24Daz8deLUaKrdPWllIvYq96xfqOVKP0fGm26)jWE9zdwSbE9PMF1jZKyX)q2JjLwLy76jVRAtlhH0TCtl3Y2pzFYb5g)yhuGBOhzSbvODaP4hnpuqRczQEiczpbMSloGm2FIQy4qgU)NaR5gSydiJFGO0fGmAifEEIyLmuV(vbe6lzkDbiJLf36X5scm41hlpgUgbiZKyX)q2JjLwL40JWbAjgmNfcdUhrCCLngsyWLRTxCiX(mYiQiX(BvItpchO9edSK5nwhCCLn6mpMuAvItpchOLyWCwUPLBCNhzFYb5g)yhuGBOhzSbvODaP4hnpuqRczQEiczpbMSloGm2FIQy4qgcU1JZLeyqthdxJaKXpqu6cqgnKcpuiwjd1RFvaH(sMsxaYyR)Na71NnyXg41NASqDYmjw8pK9ysPvj2UEY7Q20YriDlmuAX54olL5XKsRsC6r4aTedMZYnTClBpL5XKsRsC6r4aTedMZcdLwCoUKrurI93kXG5OfjTjh0GwVclmuAX5YiJOIe7VvIbZrlsAtoObTEfwyO0IZX9SZISp5GCJFSdkWn0Jm2Gk0oGu8JMhkOvHmvpeHSNat2fhqg7prvmCid3)tG1CdwSbKXpqu6cqgnKcpviwjd1RFvaH(sMsxaY8WmyoE9fjV(MCWRpuB9kqMjXI)HShtkTkX21tEx1MwocPBHHslohxSuMhtkTkXPhHd0smyol30YTS9ugzevKy)TkXPhHd0EIbwY8gRdoUNnpY(KdYn(XoOa3qpYydQq7asXpAEOGwfYu9qeYEcmzxCazS)evXWHSedMJwK0MCqdA9kqg)arPlaz0qk8yziwjd1RFvaH(sMsxaY4hNEeoWRVVIbiZKyX)q2JjLwT7hKJwK0MCqdA9kSy(Z8ysPvjo9iCGwIbZzX8N5XKsRsSD9K3vTPLJq6wUPLBCLnlr2NCqUXp2bf4g6rgBqfAhqk(rZdf0QqMQhIq2tGj7IdiJ9NOkgoKvItpchO9edqg)arPlaz0qk(rtSsgQx)Qac9LmLUaK5HzWC86lsE9n5GxFO26vWRp14PozMel(hYEmP0QeNEeoqlXG5Sy(Z8ysPvjo9iCGwIbZzHHsloh3Z2p30LiK9jhKB8JDqbUHEKXguH2bKIF08qbTkKP6HiK9eyYU4aYy)jQIHdzjgmhTiPn5Gg06vGm(bIsxaYOHu8ZJyLmuV(vbe6lzkDbiJD3pihV(IKxFto41hQTEfiZKyX)q2e66vyjJOIe7pxg1EmP0QeNEeoqlXG5SCtl34ILYmIcWDEzPozFYb5g)yhuGBOhzSbvODaP4hnpuqRczQEiczpbMSloGm2FIQy4qw7(b5OfjTjh0GwVcKXpqu6cqgnKIF)eRKH61VkGqFjtPlazS7(b541xK86BYbV(qT1RGxFQXtDYmjw8pKnHUEfwYiQiX(ZLrThtkTkXPhHd0smyol30YnU4LzefGlEzPozFYb5g)yhuGBOhzSbvODaP4hnpuqRczQEiczpbMSloGm2FIQy4qw7(b5OfjTjh0GwVcKXpqu6cqgnKIFwqSsgQx)Qac9LmLUaKXU7hKJxFrYRVjh86d1wVcE9PMF1jZKyX)q2e66vyjJOIe7pxg1EmP0QeNEeoqlXG5Sy(Z8ysPvjo9iCGwIbZzHHslohxEkJmIksS)wL40JWbApXalzEJ1bh39RozFYb5g)yhuGBOhzSbvODaP4hnpuqRczQEiczpbMSloGm2FIQy4qw7(b5OfjTjh0GwVcKXpqu6cqgnKIFwIyLmuV(vbe6lzkDbiJFC6r4aV((kgWRp14PozMel(hYEmP0QeNEeoqlXG5Sy(Z8ysPvjo9iCGwIbZzHHsloh3LrurI93QD)GC0IK2KdAqRxHfgkT4CK9jhKB8JDqbUHEKXguH2bKIF08qbTkKP6HiK9eyYU4aYy)jQIHdzL40JWbApXaKXpqu6cqgnKI)Siwjd1RFvaH(sMsxaYSFXmIt3RVpXd3E9Pgp1jZKyX)q2e66vyjJOIe7phzFYb5g)yhuGBOhzSbvODaP4hnpuqRczQEiczpbMSloGm2FIQy4qM7xmJ401KXd3KXpqu6cqgnKIFprSsgQx)Qac9LmLUaKzdavV(yf3)E9Pgp1jJnOcTdif)O5HcAviJ9NOkgoK5gaQAdU)jt1dri7jWKDXbK9jhKB8JDqbUHEKXpqu6cqgnKIFuiwjd1RFvaH(sMsxaYy3Rp(myea71xK867do2786tnEQtMjXI)HSuizCljdgd3Wvwz55htkTkX21tEx1MwocPBHHsloh3sHKXTWGoCK9jhKB8JDqbUHEKXguH2bKIF08qbTkKP6HiK9eyYU4aYy)jQIHdzTwHbJayTiPjXXEhz8deLUaKrdP4xfIvYq96xfqOVKP0fGSpDDWXVZRp14PozMel(hYuZdfjMLSRdo(DRri3eNU6K9jhKB8JDqbUHEKXguH2bKIF08qbTkKP6HiK9eyYU4aYy)jQIHdzYUo443rg)arPlaz0qk(zziwjd1RFvaH(sMsxaYq1J(xdNyh41hR4(3Rp14PozSbvODaP4hnpuqRczS)evXWHmWJ(xdNyhOn4(NmvpeHSNat2fhq2NCqUXp2bf4g6rg)arPlaz0qkSanXkzOE9Rci0xYu6cq2NgVd86tn)QtMjXI)HmWJWi()bKvcl8apiCAjXPd4b3)zqIzvBjG7bwJqUjo9miXSQTeW9almKWGlVFvitkKmULKbJHB4Ytz55htkTkX21tEx1MwocPBHHsloh3sHKXTWGoCK9jhKB8JDqbUHEKXguH2bKIF08qbTkKP6HiK9eyYU4aYy)jQIHdzYgVdiJFGO0fGmAifwWJyLmuV(vbe6lzkDbi7lZiZbmhV(uZV6KzsS4Fid8imI)FazLWcpWdcNwsC6aEW9FgKyw1wc4EG1iKBItpdsmRAlbCpWcdjm4Y7xfYKcjJBjzWy4gU8uwE(XKsRsSD9K3vTPLJq6wyO0IZXTuizClmOdhzFYb5g)yhuGBOhzSbvODaP4hnpuqRczQEiczpbMSloGm2FIQy4q2JzK5aMdz8deLUaKrdPWc)eRKH61VkGqFjtPlazEiTeW9aE9Pgp1jZKyX)qggsyWL3VkKjfsg3sYGXWnCLvwE(XKsRsSD9K3vTPLJq6wyO0IZXTuizClmOdhzFYb5g)yhuGBOhzSbvODaP4hnpuqRczQEiczpbMSloGm2FIQy4qwTLaUhGm(bIsxaYOHuybliwjd1RFvaH(sMsxaYyzXTECUKadE9XYJHRraV(uJN6KXguH2bKIF08qbTkKX(tufdhYqWTECUKadA6y4AeGmvpeHSNat2fhq2NCqUXp2bf4g6rg)arPlaz0qkSGLiwjd1RFvaH(sMsxaY4hNEeoWRVVIb86tn)QtMjXI)Hm1K5nwhCCLT)mYiQiX(BvItpchO9edSWqPfNJ7zRlr8ypwM3yDWLnluNSp5GCJFSdkWn0Jm2Gk0oGu8JMhkOvHmvpeHSNat2fhqg7prvmCiReNEeoq7jgGm(bIsxaYOHuyrweRKH61VkGqFjtPlazE4AFBIt3RpBWInWRp14PozSbvODaP4hnpuqRczS)evXWHSuTVnXPR5gSydit1dri7jWKDXbK9jhKB8JDqbUHEKXpqu6cqgnKcl8eXkzOE9Rci0xYu6cq2xMrMdyoE9PgluNmtIf)dzPqY4wsgmgUHlpLLNFmP0QeBxp5DvBA5iKUfgkT4CClfsg3cd6Wr2NCqUXp2bf4g6rgBqfAhqk(rZdf0QqMQhIq2tGj7IdiJ9NOkgoK9ygzoG5qg)arPlaz0qkSafIvYq96xfqOVKP0fGm26)jWE9zdwSbE9PglPozMel(hYsHKXTKmymCdxOKLNLrurI93kv7BtC6AUbl2GfgkT4CClfsg3cd6Wr2NCqUXp2bf4g6rgBqfAhqk(rZdf0QqMQhIq2tGj7IdiJ9NOkgoKH7)jWAUbl2aY4hikDbiJgAiJLfsntDOV0qea]] )

    storeDefault( [[SimC Survival: default]], 'actionLists', 20170402.130035, [[dSJJgaGEcrAtsODPITriI9rPsZKquZgY8Pu1nfu3gk7Ks2ly3kTFOYOuedtv53sDAKgkHqnyvvdhHdsrDkjQJPi9yHwOIYsPiwSclxslscEkPLjqRtI0eje0uvunzcMovxKi1HfDzuxNO2iHqUhHKnJOTtO(Rk9nIKPriW3Pi9mjINRkJgQACcWjfqFMcxJsfNxqoeHupKs51eXWuyoOsV5aXcWmqTsmguLIzd3VkxftfNOsX9lWKPmYbvj4inrurA60EbRG2XoGAcJ48XGvWVPs9vsjFNGFL8vIuGQXkLWbfuZrN27dMdwtH5Gk9MdelaZa1kXyqnxJ5Y4(N31kVoOASsjCq92WaXNy3iH209vCczhLFhbMKgPUDfvjFLb1gEokjClMX41HbOMWioFmyf8BQuFbaAGRanMExbD7Lb18GIOEiqZAmx(6DTYRdA4wWkXyqbhSccZbv6nhiwaMbQvIXGoJRpUkHUgGQXkLWb1BddeFIDJeAt3xXjtgYKKNhb1D6ACJ9OMhzIIdzsYdwVgD)4lPCn055zuIDdwCitsEYhbh9BtED88LtdeFKjkBV9teTNiE9ZJG6oDnUXEuZdV5aXcfhYKKN8rWr)2KxhpF50aXhzIYLb1gEokjClMX41HbOMWioFmyf8BQuFbaAGRanMExbD7Lb18GIOEiqhC9Xvj01a0WTGvIXGcoyvcmhuP3CGybygOwjgd6mu3c4(frY1qGQXkLWb1BddeFIDJeAt3xXjtgYKKNhb1D6ACJ9OMhzIIdzsYdwVgD)4lPCn055zuIDdwCitsEYhbh9BtED88LtdeFKjkBV9teTNiE9ZJG6oDnUXEuZdV5aXcfhYKKN8rWr)2KxhpF50aXhzIYLb1gEokjClMX41HbOMWioFmyf8BQuFbaAGRanMExbD7Lb18GIOEiqhOUfUKY1qGgUfSsmguWblramhuP3CGybygOASsjCq92WaXhI2P9(kozINiE9ZJG6oDnUXEuZdV5aXcfhYKKNhb1D6ACJ9OMhzIY2B)er7jIx)8iOUtxJBSh18WBoqSqXHmj5jFeC0Vn51XZxonq8rMOCzqnpOiQhcuI2P9cAGRanMExbD7Lb1kXyqfXTt7fuZvJhOBIXIQarTr9AWcxI2uUwautyeNpgSc(nvQVaa1gEokjClMX41HbOHBbReJbTarTr9AWcxI2uUwaCWYoWCqLEZbIfGzGQXkLWb1teV(X0m0TjVoE(I1s20XNOdV5aXcGAEqrupeOXeHUz0P9Er0NdAGRanMExbD7Lb1kXyqTLieUFZrN2lUFrM(CqnxnEGUjglQckfZgUFvUkMkorLI7hRLSPJprfa1egX5JbRGFtL6laqTHNJsc3IzmEDyaA4wWkXyqlOumB4(v5QyQ4evkUFSwYMo(evaCWsKaZbv6nhiwaMbQgRuchur7jIx)yAg62KxhpFXAjB64t0H3CGybqnpOiQhc0yIq3m60EVi6ZbnWvGgtVRGU9YGALymO2sec3V5Ot7f3VitFoU)jtldQ5QXd0nXyrvqPy2W9RYvXuXjQuC)BJ1skaQjmIZhdwb)Mk1xaGAdphLeUfZy86Wa0WTGvIXGwqPy2W9RYvXuXjQuC)BJ1skao4GkczYug5WmWbaa]] )

    storeDefault( [[SimC Survival: precombat]], 'actionLists', 20170402.130035, [[dydQdaGEKOAxiPABkQYSP0nvKBRWofAVKDR0(PsnmK63sonQgkvsgmvXWr0bPOEmkogu6WIwifAPuLwmclxWdrPEkyzqL1rLutejXuHIjlvthYfrjNxk6ziHRtvvJtk5BuWMvuz7qvFejkFMImnKi9DKugPIQ6VsHrtvz8ijDsfLlR6Auv5Eir8CQyrujETuQfwHraRnjSVlJcI54ca(GTBpG)b8C8P11U9qgotnisKaG8m80YP8eXRvrC(5NaV3(05kIJgRbAkOGM64OPGMcdcaMaNejqGzgeVwhHrrScJawBsyFxgfeZXfWoTw3EC1rU9GvG3BF6CfXrJ1aDlbMj4woQPah)hJABqEKGzBNZKOkiyR9cy77mTNk8F8fjcbtvpMJlqifXjmcyTjH9DzuaWe4KibOYKj7PozH416iWmb3YrnfqwiETcMTDotIQGGT2liMJlWvfIxRaZbtoc2CCkXfYqzR107nilQ9Glc8E7tNRioASgOBjGTVZ0EQW)XxKiemv9yoUaxidLTwtV3GSO2dUiKIuimcyTjH9DzuqmhxalQsAlho(72dMqskW7TpDUI4OXAGULaZeClh1uWPkPTC44FduijfmB7CMevbbBTxaBFNP9uH)JViriyQ6XCCbcPiLkmcyTjH9DzuqmhxaG(TU9GjKKc8E7tNRioASgOBjWmb3Yrnf4G(TnqHKuWSTZzsufeS1EbS9DM2tf(p(IeHGPQhZXfiKI(jmcyTjH9DzuqmhxavcPPADMJhUBpuw4B2VaV3(05kIJgRb6wcmtWTCutb9qAQwN54H3Wu4B2VGzBNZKOkiyR9cy77mTNk8F8fjcbtvpMJlqifNNWiG1Me23LrbXCCbZpdKvTc8E7tNRioASgOBjWmb3Yrnf4ldKvTcMTDotIQGGT2lGTVZ0EQW)XxKiemv9yoUaHesav(CP)wKmkKea]] )

    storeDefault( [[Rusah: biteFill]], 'actionLists', 20170402.130035, [[dSt8faGEfvPnHqyxiyBientfv1Sj6MkY6KQkDBGoSODQWEP2Ts7hLAusvvggP8BqlJGoVuPbtGHtQoOe6ukQKJHIoNIk1cLOwkHAXiA5O6HKONc9yj9CateHutfLmzPmDHlkbNgPlR66iu2OIk6BKuBwQkBNK8rfv47KattrvmpPQI)krgNuXOLQmEesoPIYNjKRrc6Esvv9msOdHq1RrHntZYyHnjLV5Ygj63xsmz4Yghj4nkMyazV(LTasA85KkLgr9xPPKoVzqHRhcvOcnk(YNa3dHAmvRPOIAeeQPOMIQnk(zRllk4n2GbHAkdouhGqqRmORi2cYTXwqdgeQPm4qDac8dM0fGTaiNTanJfRbfUaMLhmnlJf2Ku(MlBCKG3iQtJGUIylqjKKNgXkNQhgdOirYtOcHYgublGrXx(e4EiuJPAToglssL0ORraDAe0vuPkKKNgNTnAndi34c3BuzVxzmbvDWVHjnobBJe8gD4HqZYyHnjLV5Yghj4no)SEEg3iw5u9WiXBWGGmRNNXje0kd6kYO4lFcCpeQXuTwhJfjPsA01OmRNNXnoBB0AgqUXfU3OYEVYycQ6GFdtACc2gj4n6WdfnlJf2Ku(MlBCKG3O4upGC2cWGtzCJyLt1dJznOQEPVhKEG(NjreP8Bqa4C9VrjGGUIi8njLVreeVbdcaNR)nkbe0veHGwzqxrgfF5tG7HqnMQ16ySijvsJUg5PEa5LacoLXnoBB0AgqUXfU3OYEVYycQ6GFdtACc2gj4n6WJ5XSmwyts5BUSXrcEJy8lzlGfp1nk(YNa3dHAmvR1XyrsQKgDnce)Ysbp1noBB0AgqUXfU3OYEVYycQ6GFdtACc2gj4n6WdfAwglSjP8nx24ibVXISfmrmE7C2cG9XwGsoubagfF5tG7HqnMQ16ySijvsJUgZsGeJ3oVeSVsvoubagNTnAndi34c3BuzVxzmbvDWVHjnobBJe8gD4brAwglSjP8nx24ibVrIMNIGlqFu(zlyo4FZ2nk(YNa3dHAmvR1XyrsQKgDn24Pi4c0hL)sI4FZ2noBB0AgqUXfU3OYEVYycQ6GFdtACc2gj4n6Wd1MLXcBskFZLnosWBSarPlHauvNTaw8u3O4lFcCpeQXuTwhJfjPsA014jkDjeGQ6LcEQBC22O1mGCJlCVrL9ELXeu1b)gM04eSnsWB0HhDmlJf2Ku(MlBCKG3OYugCOoGrSYP6HrI3GbHAkdouhGqqRmORiJIV8jW9qOgt1ADmwKKkPrxJ1ugCOoGXzBJwZaYnUW9gv27vgtqvh8BysJtW2ibVrhEm3MLXcBskFZLnosWBC(z98moBb9hZ5Yiw5u9WydgeKz98mob(bt6c0pksGink(YNa3dHAmvR1XyrsQKgDnkZ65zCJZ2gTMbKBCH7nQS3RmMGQo43WKgNGTrcEJoCyeRCQEy0Hna]] )

    storeDefault( [[Rusah: CDs]], 'actionLists', 20170402.130035, [[d0ZHgaGEukPnjrTleTnkKAFuizDsjYSPQdJ0nPOwMO03KqNxQANOQ9QSBv2pcnkjyysXVjoTqdfLsmyuYWPKdsP6uIQogfCokLSqjYsLkwmKwovwefIvjLOESipxWerPutvuzYqmDOUOuPNrH6YGRJInIsrEkPnlPTtPyCueFxk10qPOMhLsnsuk4VOYOrWNvvNKI0TqPqxtkH7jL0drP61IIBRkpdl30Uhf1diR0u2gQugpELMYtFW0ombkHwIil2z7Wu1csrQpYwP4OCJpBlAX0oGhOby8zBmuSXyJBiZ2yCJXfN2bOi95IpykktTs(K7lsa4QmUEsglISOhcrwOm1k5tUVibGRY46jDWJgVarwSrISmyGilXrKLTSLTMApHJYfwUXBy5M29OOEazLMYtFWu7Ue9aISYjohC4PAYfTWtXY)7bYKiEeP9fkxOkjMazIX5GdB7wnUj)0oGhOby8zBmuSXKP2rJ(iUFk1LOhWHfNdo8utpKyIIf30toyk7eGugZInWdo8qNAwq4Ppy6WJp7YnT7rr9aYknLN(GPLaxaCzI3FQMCrl8uS8)EGmjIhrAFHYfqzQvsAWcsyoPYHjaCa97bsgR8t7aEGgGXNTXqXgtMAhn6J4(POGlaUmX7p10djMOyXn9KdMYobiLXSyd8Gdp0PMfeE6dMo84nE5M29OOEazLMYtFW0sErqiYInX46NQjx0cpfl)VhitI4rK2xOCbuMALKgSGeMtQCycahq)EGKXk)0oGhOby8zBmuSXKP2rJ(iUFkQxeeUkJRFQPhsmrXIB6jhmLDcqkJzXg4bhEOtnli80hmD4XZMxUPDpkQhqwPPAYfTWtXY)7bslbhLluUaktTssdwqcZjvombGdOFpqYyLFQD0OpI7NAj4OCtn9qIjkwCtp5GP80hmLTi4OCtT7(HPh9bTAelN4L7diCwsBWzKPDapqdW4Z2yOyJjtzNaKYywSbEWHh6uZccp9btnILt8Y9beolPn4mYWJVfl30Uhf1diR0uE6dMQhndqKfBG5WGBQMCrl8uS8)EGmjIhrAFHYfsI4rK2h5tUVibGdnIbYebQ7dHwBkJYuRKp5(IeaUkJRN0bpA8cgLXT8pHKFAhWd0am(Sngk2yYu7OrFe3pnC0mahbMddUPMEiXeflUPNCWu2jaPmMfBGhC4Ho1SGWtFW0HhVrVCt7EuupGSst5PpyQ9GfKWezjvISWeaIS6s)EyQMCrl8uS8)EGmjIhrAFHYfkGYuRKp5(IeaUkJRN0bpA8c2UvdgkJYuRKp5(IeaUkJRNKXkF5cjr8is7JSY465KkhMaWb0VhiDWJgVGrHYuRKp5(IeaUkJRN0bpA8c5ZpTd4bAagF2gdfBmzQD0OpI7NsdwqcZjvombGdOFpm10djMOyXn9KdMYobiLXSyd8Gdp0PMfeE6dMo84lUCt7EuupGSst5PpyQ9GfKWezjvISWeaIS6s)EGiRcgYpvtUOfEkw(FpqMeXJiTVq5cfqzQvYNCFrcaxLX1t6GhnEbB3AXYOm1k5tUVibGRY46jzSYNFAhWd0am(Sngk2yYu7OrFe3pLgSGeMtQCycahq)EyQPhsmrXIB6jhmLDcqkJzXg4bhEOtnli80hmD4HNQjx0cpD4na]] )

    storeDefault( [[Rusah: mokMaintain]], 'actionLists', 20170402.130035, [[dettcaGErsTlbEnqZwLUjQYTLYorL9QSBi7hKrjsyyG63inyOmCbDqa6uIKCmPYcfvwQkSyeTCuEOOupL4Xc9CjnrrIMkQQjJW0P6IaQlt56svBgQ2UOW6aqhM0YurZda(Me60QA0I4Vs0jfPClrQUMOOZdiFxu14eL8mj41n(tagPKxJy5MKsdx7V(YnHtB2KJ(QMaqiSgfKN(ixF0ej0IVE)uR(trJ7mZmNCyxtR24oH7kcxOaCWjCb4cfNCykbq8)MnHShhpOrbrQNO3sxJ(hRb9HqykIacJShhpOrbrQNO3sxJ(hRbmRPpQcHLoegZWzwnPm)JiO5HWshcdoaUdcJYGWGNay0FkQo(JRB8NamsjVgXYnHtB2Kdn0PmimXzpOnrISp0Nq2JJh0OGi1t0BPRr)J1aM10hvbaZWzwnPm)JiO5NCyxtR24oH7kcN1eaj)77anHPHoLvwD2dAtsdr8r1PSjikYMKDIfb5rZWAgYh5eEucoTztMpUZXFcWiL8Ael3eoTzto0qNYGWeN9Ggewk6s1ejY(qFczpoEqJcIuprVLUg9pwdQUgbbW5Kd7AA1g3jCxr4SMai5FFhOjmn0PSYQZEqBsAiIpQoLnbrr2KStSiipAgwZq(iNWJsWPnBY85tKi7d9jZ3aa]] )

    storeDefault( [[Rusah: default]], 'actionLists', 20170402.130035, [[dStugaGEKIAxqsBdsL2hKcZePQzRQ5dPu3ekDBapNKDIO9QSBq7hOrrvLHjv9BQCykdfPWGHy4sLoOGofPshtu1YivTqrXsfyXiz5c5HqLNI6XISoOQjsvvMQuXKPktxYfLsoVOYLjUUuSrQQQtRYMfL2ou0Zqk9zOW0qkY3HuYFfQVjLA0imosfNePYIiLRbPQ7bjoeKk(jKIEnvLx(1zClOr9I3YmM0aKXbnkJapiINK1A(AmNIUU14X(tYAnFTmJdKxmLms995B3tlT9OQVN2EABpoqmVCDoaz84WuDoOADgz(1zClOr9I3YmMtrx3ACzValurllxSlBCriXaoFqRiShvbAuV4noK6(RYnoz)hBP6CW4)u1y6GExYkx0yOdkJjnazmo7FqKWuDoiic9NQghgHHAm0aeu0cAugbEqeaNpS2bl7GAJdKxmLms995B3RZyCesYhwhMcGaRrngRZJ0aKXAbnkJapicGZhw7GLDqTvJu)6mUf0OEXBzgZPORBnMQjBwubC(GwryFCzP6skuvLL8HgOOhTrB0PSxGfQOLLl2LnUiKyaNpOve2JQanQx8ghsD)v5gNS)JTuDoy8FQAmDqVlzLlAm0bLXKgGmgN9pisyQoheeH(tvGi(Lx3XHryOgdnabfTGgLrGhebN)uAJdKxmLms995B3RZyCesYhwhMcGaRrngRZJ0aKXAbnkJapico)P0wnsAxNXTGg1lElZyofDDRXOdvt2SOc4Gy4CkjoBtuouB6ooK6(RYnoz)hBP6CW4)u1y6GExYkx0yOdkJjnazmo7FqKWuDoiic9NQar8tVUJdJWqngAackAbnkJapis3ijZvcnimLOnoqEXuYi13NVDVoJXrijFyDykacSg1ySopsdqgRf0Omc8GiDJKmxj0GWuI2QrstRZ4wqJ6fVLzmNIUU1ylvhMsSafGtuObk0ooK6(RYnoz)hBP6CW4)u1y6GExYkx0yOdkJjnazmo7FqKWuDoiic9NQar8JwDhhgHHAm0aeu0cAugbEqKq0SL24a5ftjJuFF(296mghHK8H1HPaiWAuJX68inazSwqJYiWdIeIMT0wns0VoJBbnQx8wMXHu3FvUXj7)ylvNdg)NQgtAaYyC2)GiHP6Cqqe6pvbI4hnP74WimuJHgGGIwqJYiWdIqDLqdctjAJdKxmLms995B3RZy6GExYkx0yOdkJXrijFyDykacSg1ySopsdqgRf0Omc8Giuxj0GWuI2QrIURZ4wqJ6fVLzCi19xLBCY(p2s15GX)PQXKgGmgN9pisyQoheeH(tvGi(HEDhhgHHAm0aeu0cAugbEqeQRe)F)RnoqEXuYi13NVDVoJPd6DjRCrJHoOmghHK8H1HPaiWAuJX68inazSwqJYiWdIqDL4)7FTvJS96mUf0OEXBzghsD)v5gNS)JTuDoy8FQAmPbiJXz)dIeMQZbbrO)ufiIFORUJdJWqngAackAbnkJapis27FjsPnoqEXuYi13NVDVoJPd6DjRCrJHoOmghHK8H1HPaiWAuJX68inazSwqJYiWdIK9(xIuARwnM7kPZ(JMT6CWrQh9OF1ga]] )

    storeDefault( [[Rusah: precombat]], 'actionLists', 20170402.130035, [[dyZNdaGEeQAxOKABkuz2u5Mk42kANu1Ej7wP9lLAyO43swhfvnuuIgScz4i6GOkpgjhdkDyrleLAPOIfdvlxWdfINcwgu8CKAIuuzQiyYs10HCrk48srpdHCDHKttPVHkTzHuBNc9reQ8zuvtdHsFhLKrQqvJtOA0uKXJs4KcLlR6AkuUhcf)vkzruuETuyHveeyytC37ITaFoVaorrNMmF7rKHtvt8ejaipLnDwIpr2ALhZyJjGZDpPV8yyWYLHiIyynggIyiIRaGkyjrceWJczRLweKhRiiWWM4U3fBb(CEbrsNR9iwEu7ryfW5UN0xEmmy5YexapCRZIAkGoQ5S2wKhji22TujQcc2AVGiMovJHY4NFrcxWq1958cesEmIGadBI7ExSfaubljsaQ4Z3DwtwiBT0c4HBDwutbKfYwRGyB3sLOkiyR9c858cyzHS1kGxGpTGnNNymJmuUA5)ElYIvpyMao39K(YJHblxM4cIy6ungkJF(fjCbdv3NZlWmYq5QL)7Tilw9GzcjprIGadBI7ExSf4Z5fyGfKUI2A8ThriKKc4C3t6lpggSCzIlGhU1zrnfCwq6kARX3cfssbX2ULkrvqWw7feX0PAmug)8ls4cgQUpNxGqYtSIGadBI7ExSf4Z5faOFx7recjPao39K(YJHblxM4c4HBDwutb0OFxluijfeB7wQevbbBTxqetNQXqz8ZViHlyO6(CEbcj)yIGadBI7ExSf4Z5fyUqYVw6OTH3EeXf(M9lGZDpPV8yyWYLjUaE4wNf1uqpK8RLoAB4T4h(M9li22TujQcc2AVGiMovJHY4NFrcxWq1958ces(XjccmSjU7DXwGpNxW4ZazvRao39K(YJHblxM4c4HBDwutbMYazvRGyB3sLOkiyR9cIy6ungkJF(fjCbdv3NZlqiHeyUhDgLdj2cjb]] )

    storeDefault( [[Rusah: preBitePhase]], 'actionLists', 20170402.130035, [[dWdEgaGEiPQnHIKDbP2gkcZefrZMK1jrvUPICyHBdXYqvTtf2l1UvA)OuJsIQAye53iDEPkdfskgmQy4sLdkHofKu6yOW5GKklKOSuuLfJOLt4Hevpf8yP8CeMikQmvuYKL00fDrj40qDzvxhfLncjrFJuSzjkBNu6Jqs47suzAqsY8qrv)vImoPQgnPQXJIuNes8zuPRrQO7bjPEgPshIuHxRO2mmldf2Gu9QLzG5EzbZuPLzyei3apMre6lp2C6exgopQrFqCdq3B4qHr9rIPRh81PonW7Qhe3d(sm0iPRUsO5lPRKUAmW7rThlmYnuPjAv0UiYJoXTz8YLnNyRS5uPjAv0UiYJwCKaVeS5qfS5izOylX0LWS8GHzzOWgKQxTmdJa5gGoCM4LlBoYPKIWa0e4U0qs5YvD0nkvvPLBjmW7Qhe3d(sm0i13qrsScN9mq0HZeVCl1OKIWakBf3IKkmS09gKR)T5jQ2J8nnPHjADei3Gtp4BwgkSbP6vlZWiqUbuPk2z8YLnhif45BG3vpiUh8LyOrQVHIKyfo7zOmvSZ4LBjIuGNVbu2kUfjvyyP7nix)BZtuTh5BAsdt06iqUbNEORzzOWgKQxTmdJa5gyYODrK3a0e4U0GoQ0eTkAxe5rN42mE5AG3vpiUh8LyOrQVHIKyfo7zqfTlI8gqzR4wKuHHLU3GC9Vnpr1EKVPjnmrRJa5gC6bQYSmuyds1RwMHrGCdYdvkODegGMa3Lg0rLMOBHkf0oc0jUnJxUg4D1dI7bFjgAK6BOijwHZEgAHkf0ocdOSvClsQWWs3BqU(3MNOApY30KgMO1rGCdo9qNMLHcBqQE1YmmcKBGx0LubBoqkWZ3a0e4U0q0sS2x67rWNavZGPYq9nrtCr33SerIxUO)gKQxzkDuPjAIl6(MLis8YfDIBZ4LRbEx9G4EWxIHgP(gksIv4SNbr0LurjIuGNVbu2kUfjvyyP7nix)BZtuTh5BAsdt06iqUbNEWeMLHcBqQE1YmmcKBaYFfBoSerNbEx9G4EWxIHgP(gksIv4SNbI8xvkfrNbu2kUfjvyyP7nix)BZtuTh5BAsdt06iqUbNEOXSmuyds1RwMHrGCdfzZzIzI6fS5qlJnh5cA5imW7Qhe3d(sm0i13qrsScN9meLqyMOErjAzLAcA5imGYwXTiPcdlDVb56FBEIQ9iFttAyIwhbYn40J(MLHcBqQE1YmmcKBG5ebx6sugwC2CqfIVr9g4D1dI7bFjgAK6BOijwHZEgQIGlDjkdlEjUIVr9gqzR4wKuHHLU3GC9Vnpr1EKVPjnmrRJa5gC6bQZSmuyds1RwMHrGCdfy6ofLaR9S5WseDg4D1dI7bFjgAK6BOijwHZEgot3POeyTVukIodOSvClsQWWs3BqU(3MNOApY30KgMO1rGCdo9GHKzzOWgKQxTmdJa5gyYODrKNnNYNbQ1a0e4U0qLMOvr7IipAXrc8sW86IMjmW7Qhe3d(sm0i13qrsScN9mOI2frEdOSvClsQWWs3BqU(3MNOApY30KgMO1rGCdoDAaAcCxAWPna]] )

    storeDefault( [[Rusah: fillers]], 'actionLists', 20170402.130035, [[dKZveaGEbjTjHKDjWRvu7tqz2kCtk42qStOAVs7wL9tPgfsyyuYVjADccoSObtrdxPCqHQtbP6yqPLrilurAPeQftWYj5HcLvjO6XK65kzIcsmvk0KvvtNQlcP8kbrDzW1HIdjiYPrSzvPTJK(ms57qctti18ee6BcXFvQgTQy8csDsKOBbj6AivoVIyCqspdPQNI6ITglJ2Lcd43PLdf4nXm8oTmEIaLfJzLpHGT5lzma1QmVbAsoiHA6e5vCr0rxzXWaYfuCrwyJyrp9wbISO3I(iLfd5FIrccuwaZ7BaIC(s)jh7EQDIEfGzZ2mVVTPaM33ae58L(to29u7e9kqbij5w2MO02KcBtA6VTz42MrBBIUTziBBAfyH12uQSnTkhx7e5TQXIJTglJ2Lcd43PLXteOCSurfkZAfzZlNANqf2HdqiWkmSr55aopybQn489LtoAbWLcd4hvi9LEWcuBW57lNC0cCIEMC0klggqUGIlYcBelulhxGmi(KY6urfkt59j60LQYN8GYXEa9SbjvaboVcLni)4jcuUEXfvJLr7sHb870Y4jcu24JsIcYrZ2mEOHvzXWaYfuCrwyJyHA54cKbXNu2FusuqoA7zOHvzkVprNUuv(Khuo2dONniPciW5vOSb5hprGY1lo91yz0Uuya)oTmEIaLJLkQGTjfyrVmRvKnVCQDcvyhoaHaRWef1RuJzfOXOuW5HHkDOKIxPgZkqb0GlCA6p6LfddixqXfzHnIfQLJlqgeFszDQOcLP8(eD6sv5tEq5ypGE2GKkGaNxHYgKF8ebkxV4rxJLr7sHb870Y4jcuwCU5sLTj7kYmuM1kYMxMcphW5bOiNSlF39hyhroFP)KJa4sHb8JsaZ7BaIC(s)jh7EQDIEfOaKKCRqKM(hE0OxwmmGCbfxKf2iwOwoUazq8jLv5Mlv7lxrMHYuEFIoDPQ8jpOCShqpBqsfqGZRqzdYpEIaLRxC6QXYODPWa(DAz8ebklo3CPY2KDfzgSnPal6LzTIS5LFLAmRangLcopSi0HskELAmRafqdUWPP)OxwmmGCbfxKf2iwOwoUazq8jLv5Mlv7lxrMHYuEFIoDPQ8jpOCShqpBqsfqGZRqzdYpEIaLRxVmRvKnVC9wa]] )

    storeDefault( [[Rusah: AOE]], 'actionLists', 20170402.130035, [[dutEdaGEKk1MKsQDPiVMq2NusMTGBQuUni7uH9sTBG9ts9tLQ0WiYVrzWKWWjQdssofsfDmKYcrvTuuLfJKLl0djWtHEmPEUsMisLmvqzYs10fDrc1LvDDuH1PufhwYMvQQ2UuSmq1HqQQPPuvonIVrIgNIQrtqJhPkNur5zkvUMuIZJk9zPu)fv0OqQWMMHzumOOcVB(gPRV)IJqA(ghf0nYJJvjCpQvOAVInIYxtQaHURKWaEaVLwmY7HxR7bCjAkL2TtAcU0oPDknY7vNlmc0n2z5KUczKjVMsIweb0wTIc0vROZYjDfYitEnfpural1kyr1kKmQsNegyzyEqZWmkguuH3nFJJc6g5ZrQf(ixJ8E416EaxIMsP5gvrrcKKRrkosTWh5ACgOt0vYIgbmWnkq41I2ynh6G0ug3y9rbDJo9aUHzumOOcVB(ghf0nkOczKjVmI6irons)olN0viJm51us0IiG2g59WR19aUenLsZnQIIeijxJ6kKrM8Y4mqNORKfncyGBuGWRfTXAo0bPPmUX6Jc6gD6XodZOyqrfE38nokOBum9KdSfP5QvalwYg59WR19aUenLsZnQIIeijxJNEYb2I0CoZyjBCgOt0vYIgbmWnkq41I2ynh6G0ug3y9rbDJo9yFgMrXGIk8U5BCuq3OGk2CJOosKtJzfoiNwpkFqY5kjG2thuuH3Bn97SCA9O8bjNRKaApLeTicOTrEp8ADpGlrtP0CJQOibsY1OUIn34mqNORKfncyGBuGWRfTXAo0bPPmUX6Jc6gD6rlgMrXGIk8U5BCuq3OGk2C1kOdA0PruhjYPXsNKMZ5bhI8vRAXiVhETUhWLOPuAUrvuKaj5AuxXMBCgOt0vYIgbmWnkq41I2ynh6G0ug3y9rbDJoDAe1rICA0Pna]] )

    storeDefault( [[Rusah: bitePhase]], 'actionLists', 20170402.130035, [[d0d6eaGEQQsBIi1UqX2OQk2hQQCAKMnvMpvv1nrvEScFdK6Ws2jb7v1UvA)uuJIcgMI63cNhrgkQQYGPidNqDqqYPOqhJqghQklKQYsvelgWYb6HejpL0YiI1rvLAIOQQMQI0KrLPl1fbrVIQkCzORtjBerPNHOAZGA7eLojrvhcrX0OQsMhiOBlYFry0uLVtu5suvrFgLUgi09ikwfiWZf1RPuFrF6vi3cWHC33vDasf3xVQIXbTCu)TAASxqceH4v(hHllxFFxNGoSY4fKmlc6zYjFMrYm5ZKd91jyXrAknHxVc1OPXM)0li6tVc5waoK7(Ukuj8kVyzJiJMn5J24vDasf3xjdGfmmtkw2iYibSfijglXspIWXfYTmPyzJiJea0gzgEfilM5NmsUobDyLXlizwe0Z8DfkaQJ2KUMILnImsaqB8Q8lhDuDaEDJfVkLhoS5fYIjC7dCLxWjuj867li5tVc5waoK7(UQdqQ4(QbY0Ld3MrUIerat0EirkS3Q9khdUfGd58V)bSGHzsH9wTx5i6A00rMbetfDZ8Za7GdcmWNFsUrJgLgWcgMjflBezKa2cKetURHTm(ZvOaOoAt6kSfijIaMO9qcSyD4v5xo6O6a86glEvOs4vYAbsYSPa2SP2dnBcYI1HxHcKnFLUnccAjUjOWYyOlhUnJCfjIaMO9qIuyVv7vogClahYjnGfmmtkS3Q9khrxJMoYmGyQOBgcLPPdBIMMqJxNGoSY4fKmlc6z(UkLhoS5fYIjC7dCLxWjuj867lq(NEfYTaCi39DvOs4vY6Q1MUSMnPni1gVQdqQ4(QbdawWWmPyzJiJeWwGKyaXur3m)mWo4GadJiCCHCltkw2iYibaTrMHxbYIz)qIrJgLEeHJlKBzsXYgrgjaOnYm8kqwmdHYiYO0KbWcgMPYIXrteWeThsGfRdzSeFDc6WkJxqYSiON57kuauhTjDf2vRnDzjYni1gVk)YrhvhGx3yXRs5HdBEHSyc3(ax5fCcvcV((c(1NEfYTaCi39DvOs4vEXYgrgnBYhTrZMmiY4vDasf3xbSGHzsXYgrgjGTajXyj(6e0HvgVGKzrqpZ3vOaOoAt6Akw2iYibaTXRYVC0r1b41nw8QuE4WMxilMWTpWvEbNqLWRVVae)0RqUfGd5UVRcvcVswxT20L1SjTbP2Oztgez86e0HvgVGKzrqpZ3vOaOoAt6kSRwB6YsKBqQnEv(LJoQoaVUXIxLYdh28czXeU9bUYl4eQeE997RcvcVoXkxE(Tzta0g5pVkJV)b]] )


    storeDefault( [[Survival Primary]], 'displays', 20170402.130035, [[d8J0haWyKA9QiVKcXUGsjBJcq)gYmPqnnvGMTcNNkUPkOtJQVrb1XuKDsP9k2nj7hr9tOyyemoOuLlRQHsObJidhQoOu5OqPQoSKZrbWcLILkLAXu0Yj1dvr9uWYKsEortekftfHjJsMUsxurDvkKEMkuxxL2ivPTcLsTzQ02rIpsv0RvH8zK03LQgjfK1rbA0Oy8qjNeL6wuaDnva3dkv62uvRfkvCCQcNPqeGUWxos5fPwyDgFamgLWy225a0f(YrkVi1c8tFStTcOlf1)mZtFuAcyo4No55a1hZaoyCDL)EUWxosjJviawyCDL)EUWxosjJviaUM7xAh20ifWp9XEqHa(Cv3CSTc4X9VpRZf(YrkzAc4GX1v(lrPP(RmwHay)7FFziIDkebMvL54zLMaD0lhPitYyUCJ1aeWw(FG2xzXyqYKW1pnY3S2aT)XxYp2wctgwysqiaqR54BGL7)yxHSX2kebMvL54zLMaD0lhPitYyUCJf7fWw(FG2xzXyqYKy9U1DSbA)JVKFSTeMmSWKGq2SbKmOEONV0mDZPjGKb13DxuAcizq9qpFPz6Ulknb2st93ofndshObdbbMdBZ2tdreWjwdSLbuiawXkeqYG6jkn1FLPjWrMDkAgKoabgX2S90qebOr(M1kszoMbOl8LJuDkAgKoqdgccmhgaWFAEn4NQLJuX26ahiGKb1dePjGh3)(ydx)0lhPc0MTNgIiG66ZMgPKXEWas8Fm8okjZz0aPdrGk2PaMXofGAStb0XoLnGKb1FUWxosjttaSW46k)T7QRyfcuxDr4G)bmVUUb8lS6UlkwHa1aNP6g9LJuKYCStbQbotbmOErkZXofOg4m1zKVzTIuMJDka28U1DSPjqn6lhPifX0eGcxYn5d(6q4G)bmdqx4lhP6gCQQaNNTeZTdWIlXhLdHd(hOcOlf1NWb)duM8bFDcuxDDix9PjGhxo9ryBUewNXhOcCKPxKAb(Pp2PwbWcJRR8x2kwC6ArAzScbQbotruAQ)ksrm2PaoyCDL)YwXItxlslJviG(hbopBjMBhqI)JH3rjzIzGAGZueLM6VIuMJDkWwAQ)6fP2aIeKjbLssMKT0AuFapU)9zXwXItxlsltta)clGi2PaCAKc7Gq(XESqGT0u)1lsTW6m(aymkHXSTZboSWI7F9jtIG7)XESqapU)9zXMgPa(Pp2dkeaO1C8nqGAGZuDJ(Yrksrm2Pa(Cv3DrXkeaxZ9lTJxKAb(Pp2PwbW1pnY3S2orJd0(klgdsMeU(Pr(M1gquZ9lTdzsNl8LJubK6A5Oa(fwDZXkeGOgVAjtYtn6IhRqGT0u)vKYCmdiQ5(L2HmPZf(YrkYK6U6kWHifves(Kj59QDcizq9g5Dm5kwCfvzAc4X9VF3Gtv5)QnaDGT0u)vKIymd4IuBGzSW1Vu2xobmh8tN8CG67gJygWbJRR83URUIviGKb1ZwXItxlslttGAGZuadQxKIyStbQrF5ifPmNMa1aNPoJ8nRvKIyStbKmOErkZPjanY3SwrkIXmWrMErQnGibzsqPKKjzlTg1halmUUYFnsJmwHasguVifX0eWNRaIyfcSLM6VErQf4N(yNAfqYG67Mtta6cF5iLxKAdisqMeukjzs2sRr9bQRUa8FmyJnXkeywvMJNvAci5(4JVdZCSTcCKPxKAH1z8bWyucJzBNdGfgxx5VeLM6VYyfc4GX1v(RrAKXAGtby9U1DSDIghO9vwmgKmjwVBDhBG2)4l5hBlHjdlC8XcyRwchlCSHdizq9DxDXw5IIzG6Ql2kxeHd(hW866gGtJuaErZvuJ9abQRU6u0miDGgmeeyo04zVeb84(3NLxKAb(Pp2Pwb4kwC6Ar6ofndshOnBpnerapU)9zzKgzAcyl)paC1u4uQbzsIAUFPDcuxDzufFdGpkNxNnb]] )

    storeDefault( [[Survival AOE]], 'displays', 20170402.130035, [[daK2haqisc1MGOIBrjv2fLu1WiLJjvwgL4zQqMgvv5AKK6BKKmoscCoscADKeDpiQ0bLIfkv9qvKjsvvDrfzJuv(ivvgjjLojk1lPKYmPKCtik7KIFcHHsQokev1svbpfmveUkjfBLKqwlevzVIbJehwYIjXJrQjJsUSQ2mL6ZiYOrXPr1RvHA2kCBP0Uj63qnCiDCsQwovEoHPR01vPTJK(UIA8qKZtvwVkQ9JOoDHiaDHUCS0hwUW6n(aiudHvSntbOl0LJL(WYf4N)y6SeWvss)jMN(40hqzWpF2VbEokb8qyBl(9uHUCSueJwaKqyBl(9uHUCSueJwa1V)9zXMglb(5pg)PfqWGNBUUIT0ghLaQF)7Z6uHUCSuK(aEiSTf)suos)kIrlaY)(3xeIy6crGjzPmEwPpqd9YXsYuSIl2yuHbmv7h4WvumQKmfu3tJBvQnWHF8L4JXIwNQ0600ca0oo6gy5TpYvlBmwcrGjzPmEwPpqd9YXsYuSIl2yubbmv7h4WvumQKmfwVDDhBGd)4lXhJfTovP1PPLnBabdEgM5lntZu6dGecBBXVeLJ0VIy0ciyWZWmFPzAUlo9b2Yr63gjnd2fOhbbbcKDGTFQLiGxmwNLovhWgl3atiH6EHyU8ciyWZeLJ0VI0h4yLgjnd2fGaH(b2(PwIa04wLA1PofLa0f6YXYgjnd2fOhbbbcKfaqFAEn4NRLJLXyr1QoGGbpdePpG63)((N7E6LJLboW2p1seqEBztJLIy8xab6pg(gLG5eEGDHiqftxaLy6cqkMUaUy6YgqWGNpvOlhlfPpasiSTf)2CDvmAbQRRi8q)akxB7aTfsn3fhJwGAGYunJ5YtOtDkMUa1aLPag8So1Py6cuduM6eUvPwDQtX0fW)VDDhB6duJ5YtOtvp9bOYfCf(GVEeEOFaLa0f6YXYMbNKmWPjdX0HaS4c0r5r4H(bOd4kjPNWd9duk8bF9cuxxHmU8tFa1VC6JvrCbSEJpqf4yfFy5c8ZFmDwcGecBBXVSLS401IDIy0cO74TLZJmLtf6YXsYuAUUkaYWssyS4jtX315fOLlBUloglbC)iWPjdX0Hac0Fm8nkbtucuduMIOCK(vN6umDbqkgTaQF)7ZITKfNUwStK(aCASeqlAUKumQoaNglrEyCBmhPfylhPF9HLlSEJpac1qyfBZuaKviXBVTKPqWB)yoslqlx2mfJLaaTJJUbeCjPXJCuX1DXbQbkt1mMlpHov9y6cWLS401IDnsAgSlWb2(PwIaOoEB588HLlWp)X0zjaQ7PXTk12OBvGdxrXOsYuqDpnUvP2acg8S1EpfUKfxssK(aTfsntXOfGOgVCjtXph(IgJwGTCK(vN6uucG64TLZJnnwc8ZFm(tlWHF8L4JXIwNQ0o6inR3I2rAhPQa1aLPikhPF1PQhtxGTCK(vNQEucO(9VFZGts2(YnaDaLb)8z)g45MXikb8qyBl(T56Qy0ciyWZSLS401IDI0hOgOmfWGN1PQhtxGAmxEcDQtPpqnqzQt4wLA1PQhtxabdEwN6u6dqJBvQvNQEucCSIpSCdOtqMcusbzkMY5WZbqcHTT4xR1lIPlGGbpRtvp9bA5sGiglb2Yr6xFy5c8ZFmDwciyWZntrjaDHUCS0hwUb0jitbkPGmft5C45a11va6pgS9FmAbMKLY4zL(acEl64BqmfJLahR4dlxy9gFaeQHWk2MPaB5i9RpSCdOtqMcusbzkMY5WZb8qyBl(1A9IySUUaSE76o2gDRcC4kkgvsMcR3UUJnGUJ3wopYuovOlhldiC1YXbem45M7IJsG66k2sBmHh6hq5ABhOTqciIrlqDDvJKMb7c0JGGabYSAYhra1V)9z5dlxGF(JPZsape22IFzlzXPRf7eXOfq97FFwwRxK(aMQ9daxhvo1AqMsdIPa11vQrY3aOJY7Dzta]] )


    ns.initializeClassModule = HunterInit

end
