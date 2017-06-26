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


    storeDefault( [[SimC Survival: biteFill]], 'actionLists', 20170625.195247, [[d4thiaGEckBIKQDjrBtvspxLMjbv5WuMTcZNKu3KkUnK(MQIZRQ0oL0Ef7gX(v0OubmmvX4ubQtt0NjvnyPA4e6qKe5uKuCmjCoscwibSuvPwmelhPhsL8uulJuADeuXejj0uPsnzQA6kDrvvDCssEgjLUoPyJeuPTsG2Sk02jrFKGQ67QGmnvGmpvj8yP8Asy0KkJNKOojb5YGRPkr3tfuhuvL)QI(nuNI4o8FIHmaFqcRIWrtZyJaHRgkeMLOUMDwdvPuPneoZoICbHRCmc)ggGDHu1(u8551cTLA1w86bPcH5gvkUHd)RTsm5g3Pwe3H)tmKb4JaH5gvkUHxSE9dOSHXdp(qKB4FiYHC)g(kk3vs0F2WiulSlDqtHdwjGcKniHDWEbnA1qHWHRgkeMfL7kj6NDxyeQf(nma7cPQ9P4tXtyHiEzZwmnmbtGWoyF1qHWztvBCh(pXqgGpceMBuP4g(aZoOknsrrWxIOzB6a69ebtGttKIjZU6ZoIMJhlr0SnDa9EIGjWPjsXKY7AnfZ(HN9INzx9z)c7kj6VLxrG4pnrkMCExRP4o7Qz2vTQN9dm7GQ0iffbF5rQuycdFppkj6b6snXzx9z3J3YH1aQTqjfqnj5o7Vy2vB5RZUAc)droK73WiA2MoG(nSlDqtHdwjGcKniHDWEbnA1qHWHRgkewanBthq)g(nma7cPQ9P4tXtyHiEzZwmnmbtGWoyF1qHWztvTXD4)edza(iqyUrLIB4dm7GQ0iffbFjIMTPdO3tembonrkMm7Qp7iAoESerZ20b07jcMaNMiftkVR1um7hE2lEMD1N9lSRKO)wEfbI)0ePyY5DTMI7SRMzx1QE2pWSdQsJuue8LhPsHjm898OKOhOl1eND1NDpElhwdO2cLua1KK7S)IzxTLVo7Qj8pe5qUFd3mQsiSlDqtHdwjGcKniHDWEbnA1qHWHRgke2LrvcHFddWUqQAFk(u8ewiIx2SftdtWeiSd2xnuiC2upO4o8FIHmaFeim3OsXnShVLdRbuBHskGAsYD2FXSR2Yxd)droK73WdRbuBHWU0bnfoyLakq2Ge2b7f0OvdfchUAOqyHN1aQTq43WaSlKQ2NIpfpHfI4LnBX0Wembc7G9vdfcNn1xg3H)tmKb4JaH5gvkUHT2kvcNabqLWD2p8Sxm7Qp7RnaYwEbQiq2Z7kj6lbIHma)SR(SRsZUhVLxGkcK98UsI(Yv2uij6d)droK73WutCX0Z7sLkGWU0bnfoyLakq2Ge2b7f0OvdfchUAOq43M4IPZoVuPci8Bya2fsv7tXNINWcr8YMTyAycMaHDW(QHcHZM6RXD4)edza(iqyhSxqJwnuiC4QHcH5fGXS7MAIH)HihY9B47cW4CPMy43WaSlKQ2NIpfpHDPdAkCWkbuGSbjSqeVSzlMgMGjqyhSVAOq4SP(jUd)NyidWhbc7G9cA0QHcHdxnui8Vz3rd1d0zhFC2DrXh6g(hICi3VHTtunupqpXhpBu8HUHFddWUqQAFk(u8e2LoOPWbReqbYgKWcr8YMTyAycMaHDW(QHcHZM6bh3H)tmKb4JaHDWEbnA1qHWHRgkewfPMEm5EusHzx4tbI5HW)qKd5(nSNA6XK7rjfo1tbI5HWVHbyxivTpfFkEc7sh0u4GvcOazdsyHiEzZwmnmbtGWoyF1qHWztvfI7W)jgYa8rGWoyVGgTAOq4Wvdfc)xLfh4Rujm7UPMy4FiYHC)gguzXb(kvcNl1ed)ggGDHu1(u8P4jSlDqtHdwjGcKniHfI4LnBX0Wembc7G9vdfcNn1IN4o8FIHmaFeim3OsXnSkn7E8w2SXsXI3Yv2uij6d)droK73WnBSuS4nSlDqtHdwjGcKniHDWEbnA1qHWHRgke2Lnwkw8g(nma7cPQ9P4tXtyHiEzZwmnmbtGWoyF1qHWzZgMfHM0gsHzRetsv7lFz2ea]] )

    storeDefault( [[SimC Survival: CDs]], 'actionLists', 20170625.195247, [[dWZJhaGEuvOnPszxuyBIiTpuvYSf65Q4MsPdRQVPsCBPANaTxLDJ0(j1OKIgginoukv3teXqrvbdMKHlshukCkjYXKW5qPiluIAPOuTyqTCbpeewfkf1YeH1HsjnruvQPQsAYaMoIlQs1Pf1LHUofTrukLTsP0MrX2brpwsZtevFgv(oQQgjkL4zIOmAuYFPKtsPyAOQORHsHZJQ8uIxtP63u9k21j3PpCebg8e(gzEZizLNa(DCIK7qOvIzaYmKFKTQvqW3NjSJr8p4ataT4c0KwKWirIIKYNSPjsnKtjtM0OsYo9SRdSyxNCN(WreyLNi1qoLmHXRMhJQziGuIwL8KOvjd6KgW5yMWBYhQpfTiEiGuYeiyHv7ToKyhPKbpP1bS9dGFhNmb874KgH6trT6QhciLmHDmI)bhycOfxkGoXgkqU(epmH6uCsRda(DCYidmXUo5o9HJiWkprQHCkzcX54IOr19iGZp9Ov30QMAfSjdJXFsXkXYzSiSql85IOHzQwvAsd4Cmt4nbgdhmypt5MablSAV1He7iLm4jToGTFa874KjGFhNugdhmypt5MWogX)Gdmb0IlfqNydfixFIhMqDkoP1ba)oozKbMSDDYD6dhrGvEIud5uYeIZXfrJQ7raNF6rRUPvn1kytggJ)KIvILZyryHw4ZfrdZuTQ0KgW5yMWBcC0DalgZaVjqWcR2BDiXosjdEsRdy7ha)oozc43XjLJUdOvSnZaVjSJr8p4ataT4sb0j2qbY1N4HjuNItADaWVJtgzG85Uo5o9HJiWkprQHCkzcX54IOrQtYo9Ov30QMAfSjdJXFsXkXYzSiSql85IOHzQwvAsd4Cmt4nj1jzNobcwy1ERdj2rkzWtADaB)a43Xjta)ooHp4KStNWogX)Gdmb0IlfqNydfixFIhMqDkoP1ba)oozKbYg76K70hoIaR8ePgYPKjeNJlIgv3Jao)0JwDtRAQvWMmmg)jfRelNXIWcTWNlIgMPAvPjnGZXmH3eymCWG9mLBceSWQ9whsSJuYGN06a2(bWVJtMa(DCszmCWG9mLtRAwuAc7ye)doWeqlUuaDInuGC9jEyc1P4Kwha874Krgys31j3PpCebw5jsnKtjtiohxenQUhbC(PhT6Mw1uRQUhbC(PgDNY5(bTGZe0OY6dC4rRsIwbvRUPvWMmmgDNY5(bTymd8mcy)Z0JwXxAvY0k2SwXvb0QstAaNJzcVjh6BhTyzsjyyceSWQ9whsSJuYGN06a2(bWVJtMa(DCIqF7OwXwmPemmHDmI)bhycOfxkGoXgkqU(epmH6uCsRda(DCYid8YUo5o9HJiWkprQHCkzcX54IOr19iGZp9Ov30QMAvtTc2KHXO7uo3pOfJzGNra7FME0QKNeTQOqRUPvWMmmgDNY5(bTymd8mmt1QsA1nTQPwvDpc48tnymd8SCglcl0cFUiAeW(NPhTIV0kytggJUt5C)GwmMbEgbS)z6rRkPvLM0aohZeEt(tkwjwoJfHfAHpxeNablSAV1He7iLm4jToGTFa874KjGFhN04KIvIw5mAfHfQv3FUioHDmI)bhycOfxkGoXgkqU(epmH6uCsRda(DCYidKTVRtUtF4icSYtKAiNsMqCoUiAuDpc48tpA1nTQPw1uRGnzym6oLZ9dAXyg4zeW(NPhTk5jrRUOv30kytggJUt5C)GwmMbEgMPAvjTQ0KgW5yMWBYFsXkXYzSiSql85I4eiyHv7ToKyhPKbpP1bS9dGFhNmb874KgNuSs0kNrRiSqT6(ZfrTQzrPjSJr8p4ataT4sb0j2qbY1N4HjuNItADaWVJtgzKjskwZFmZhFs2PdmbBWgJSb]] )

    storeDefault( [[SimC Survival: AOE]], 'actionLists', 20170625.195247, [[dCtKdaGEKuAtquAxusBdvW(GOYSL4Mu0TvYoPQ9s2nu7hc)KsudtQ8BugSs1WfYbPIofssDmkCoKuSqHYsfQwmKwUGhIepv1YukRdIQMieftfv1KLY0vCruLNJuxgCDuPoSOTcr2mscBNk9nPkpdjrtJsKtJ4Xs6qOcnAQW4rs1jLQ6ZucxdvY5PuEnLQ)IkAuijzzi(68WjAbAcvhzaQi5UmkMUpxG(jlki2p3bxIBwqEe7oTmp94qbsAq(ToJEDCWyZ62MbhSe1O)AGen66oRdHHPfF5neFDE4eTanft3K1qkd(Cb66(Cb6X4EQoGGnDNOKczSPJY9uDabB6XHcK0G8BDg9m60P4aQ2nzUWcWJq17JBKAoSGoMHbDtwZNlqxJ8BIVopCIwGMIP)AGen6CeXEJnwRzzcSiARdPANGTq3jkPqgB61SmbweTofhq1UjZfwaEeQUjRHug85c0195c0PKLjWIO1JdfiPb536m6z0P3h3i1CybDmdd6MSMpxGUg5PsXxNhorlqtX0nznKYGpxGUUpxGopQhvy0exaXo)qgP7eLuiJnDG6rfgnXf4CczKECOajni)wNrpJoDkoGQDtMlSa8iu9(4gPMdlOJzyq3K185c01iVLeFDE4eTanft)1ajA0NSa4XkneIa8Wj9qWwyfWjAbAi2rwe7CeXEJnwPHqeGhoPhc2cRdPANGTq3jkPqgB61m4c6uCav7Mmxyb4rO6MSgszWNlqx3NlqNsgCb94qbsAq(ToJEgD69XnsnhwqhZWGUjR5ZfORrEUeFDE4eTanft)1ajA0Z6qCbobmSianIDKdXox6orjfYytVMbxqNIdOA3K5clapcv3K1qkd(Cb66(Cb6uYGlGyNQmOA94qbsAq(ToJEgD69XnsnhwqhZWGUjR5ZfORrJ(JGkjleQnhcdl)gxCPrc]] )

    storeDefault( [[SimC Survival: default]], 'actionLists', 20170625.195247, [[d4J6haGEGuBcvkSlPITrkL9HkLMPqLNdYSvA(sI4Ms0HP8neLBtLDIWEvTBK2pvnkHQggQyCsI05bLgkPunybdhioOu1PKeogO6COsrleuSuevlgvTCP8qH8uOLrQADcLjcK0urKMmknDfxerCArpdiX1LuBKucBLuXMLK2ok(SuPltmnjr9Dsj61sOhdy0KI)cuNKuPfjbxJus3dvYHqLk)evQ63K8HFspsc14xH98hbvPQvVZH5iH5KJy6I8bSUXKm2gZhyLQw9ohjxwXGKtONdCY4On467OxpCTvzU5reOLGmhp2dmPIcDspb8t6rsOg)kShMJiqlbzooQUDxPtshP1QbzG8bUHpeVpmwRRmDyf(6Qv7ayqts72PgeFOIJ985MdShD1Gg0RCmsJauSuXioHoN)yPIvhRryo54rcZjhlRbnOx5i5YkgKCc9CGtgCoh1LYMa2OAhPkQCSuXsyo54NtO)KEKeQXVc7H5ic0sqMJJTcD6OLgSGvvbpAeWovrQnASTJqn(vyp2ZNBoWEeW2fSbmPIcEtO5OUu2eWgv7ivrLJLkwDSgH5KJhjmNCmY21h6bMur9H4sO5yFRl0rQ5eUkGPlYhW6gtYyBmFWPkwAjDSKw4i5YkgKCc9CGtgCohJ0iaflvmItOZ5pwQyjmNCetxKpG1nMKX2y(GtvS0s6yj9ZjaLt6rsOg)kShMJiqlbzoYxxTAhNQi1gn2cEmGjbG6angqrFGB5Yh07dvsL4dCNpm2k0PJwAWcwvf8Ora7ufP2OX2oc14xH9ypFU5a7raBxWgWKkk4nHMJ6sztaBuTJufvowQy1XAeMtoEKWCYXiBxFOhysf1hIlHgFiE4vCSV1f6i1CcxfW0f5dyDJjzSnMpebQqfosUSIbjNqph4KbNZXincqXsfJ4e6C(JLkwcZjhX0f5dyDJjzSnMpebQqForLpPhjHA8RWEyoIaTeK5i35d81vR2XPODvkibC16gSDQb5ypFU5a7raBxWgWKkk4nHMJ6sztaBuTJufvowQy1XAeMtoEKWCYXiBxFOhysf1hIlHgFiE9vCSV1f6i1CcxfW0f5dyDJjzSnMpastGjhr7AmiPWrYLvmi5e65aNm4CogPrakwQyeNqNZFSuXsyo5iMUiFaRBmjJTX8bqAcm5iAxJbjFoHwpPhjHA8RWEyoIaTeK5ObmjJawOIlfiFGB5YhaLJ985MdShbSDbBatQOG3eAoQlLnbSr1osvu5yPIvhRryo54rcZjhJSD9HEGjvuFiUeA8H4bLko236cDKAoHRcy6I8bSUXKm2gZh65EskCKCzfdsoHEoWjdoNJrAeGILkgXj058hlvSeMtoIPlYhW6gtYyBmFON7j5Zj02j9ijuJFf2dZXE(CZb2Ja2UGnGjvuWBcnh1LYMa2OAhPkQCSuXQJ1imNC8iH5KJr2U(qpWKkQpexcn(q8vUIJ9TUqhPMt4QaMUiFaRBmjJTX8b(CeTRXGKchjxwXGKtONdCYGZ5yKgbOyPIrCcDo)XsflH5KJy6I8bSUXKm2gZh4Zr0Ugds(CcYoPhjHA8RWEyo2ZNBoWEeW2fSbmPIcEtO5OUu2eWgv7ivrLJLkwDSgH5KJhjmNCmY21h6bMur9H4sOXhIxRvCSV1f6i1CcxfW0f5dyDJjzSnMpWNJOf5UfosUSIbjNqph4KbNZXincqXsfJ4e6C(JLkwcZjhX0f5dyDJjzSnMpWNJOf5UForLEspsc14xH9WCSNp3CG9iGTlydysff8MqZrDPSjGnQ2rQIkhlvS6yncZjhpsyo5yKTRp0dmPI6dXLqJpeV2Q4yFRl0rQ5eUkGPlYhW6gtYyBmFOAUR0GkCKCzfdsoHEoWjdoNJrAeGILkgXj058hlvSeMtoIPlYhW6gtYyBmFOAUR0G(85icIaK2MG2MurpHETQ1p)a]] )

    storeDefault( [[SimC Survival: precombat]], 'actionLists', 20170625.195247, [[dqtZdaGEKeTlKK2MkuZwWnr0TfANOAVKDRQ9trnmr1VLAOiPAWIWWPuhuK6yiCoKOAHIKLkkTyOSCjEif5PkpgPwhsKMisktfQAYsA6qUif6WuDzW1vbEoLSvvsBwfY2HkFejILPs9zKWFPGgjsuonkJwenEkGtQI8nrX1ubDEvINHKW0Oa9AvulcHxZ47ybOkmnQbh5heqkLg3JG2yrtMtSdk4y48aLAoHDbO7iMJ0YcbWTaXVZjYKFmXnvVVjo2GuU2OlmBKMwAAeRFlHxCcHxZ47ybOQuAKD9Qx4Ee004Ee0m5HG5euhqMtqOLgJfyOlAwheJ9BOnG0YcbWTaXVZjYqKRzkjqFMSXbr4rct70xz0oQlAF)Ggzx5Ee0es8BHxZ47ybOQuAJUWSrAOMckcavTBeRFlT0ySadDrZUrS(1mLeOpt24Gi8iHPr21REH7rqtJ7rqJ6nI1VwwiaUfi(DorgICTtFLr7OUO99dAKDL7rqtiXPcHxZ47ybOQuAKD9Qx4Ee004Ee0mAa7qBXWbMtGV42APXybg6Igya7qBXWbgIkUTwwiaUfi(DorgICntjb6ZKnoicpsyAN(kJ2rDr77h0i7k3JGMqIBqHxZ47ybOQuAKD9Qx4Ee004Ee0gcGG5e4lUTwAmwGHUOzHaiyiQ42AzHa4wG435eziY1mLeOpt24Gi8iHPD6RmAh1fTVFqJSRCpcAcj(HcVMX3XcqvP0i76vVW9iOPX9iOrTItr)whXkG5eusbEVcAPXybg6IwT4u0V1rScyiff49kOLfcGBbIFNtKHixZusG(mzJdIWJeM2PVYODux0((bnYUY9iOjK4hl8AgFhlavLsJSRx9c3JGMg3JGgL5f7UFT0ySadDrlPxS7(1YcbWTaXVZjYqKRzkjqFMSXbr4rct70xz0oQlAF)Ggzx5Ee0esiTzd0mpWOshX6x87dpuija]] )

    storeDefault( [[SimC Survival: fillers]], 'actionLists', 20170625.195247, [[dSZueaGEkLQnPkYUGuBtIs7tvuZwQUPK8Cu8nvPomv7uj7vSBO2pPgfkvddc)MKBRuhIsjnykgoeDqjvNIaDmk5CukQfQQYsPuTycTCIEOeSkjQSmv06OuWePuktvImzvA6kUOQsVIsrUm46QsonQ2kkLnlPSDvyAQc(UQqFwcnpkf61qYJLYOjOXlrXjjGBjrvxtvvNxvXZOuINI8xuYXkLc9f7ID4gXq2guZF1N8l0Y3qiIVlOn0l5b)W72G2uJ37GKjKDOdodK1jcR3ikR1j6ZtRY(GnhIAsoYjuO6THRWmPuwwPuOVyxSd38le1KCKtiVn8dGfGHnhy0MN1glT5jTz8oGh0mGejGhwmdhxenGDXoC1MN0gBvBUQbndirc4HfZWXfrp8gkoUyO6I8oF(eQ5YdiubHqdvL6a2aEIyOk1LnxU8nek0Y3qOcU8aczh6GZazDIW6TfIqcGV8MpkziScdHQu3LVHqzY6mLc9f7ID4MFHQux2C5Y3qOqlFdHkjuQEKJlQn1ldWeQUiVZNpHgHs1JCCrwEzaMq2Ho4mqwNiSEBHiubHqdvL6a2aEIyibWxEZhLmewHHqvQ7Y3qOmzzlPuOVyxSd38le1KCKtiVn8dGfGHnhy0MN1MZq1f5D(8juZLhqOccHgQk1bSb8eXqvQlBUC5BiuOLVHqfC5bOnSBjyi7qhCgiRtewVTqesa8L38rjdHvyiuL6U8nektwpKsH(IDXoCZVqutYroHyxBgVd4b9J(hwQASgHaRTcf2hHEhnGDXoC1MN0gXx1QHERqH9rO3znEB4ng0sy7CmJ2yJAtX2vBkN28G2iyO6I8oF(es6ihLKfZi5OGqfecnuvQdyd4jIHQux2C5Y3qOqlFdHS7ihLuBOrYrbHSdDWzGSory92cribWxEZhLmewHHqvQ7Y3qOmz9pLc9f7ID4MFHOMKJCcvt1EXGU9skb8OnpRnSRnSRnN)1MYRn1uTxmOLqraRnLtBk2UAJGAJnPn))RncgQUiVZNpHKoYrjzXmsokiubHqdvL6a2aEIyOk1LnxU8nek0Y3qi7oYrj1gAKCuG2WULGHSdDWzGSory92cribWxEZhLmewHHqvQ7Y3qOmzcriHg37CB3hUcN15))zsa]] )

    storeDefault( [[SimC Survival: preBitePhase]], 'actionLists', 20170625.195247, [[d8dIjaWCvA9KqTjjr7sj2gjKdtzMuPW3ufMTunFQu1nPIZRk62QQtt0oLYEf7gQ9RuJIKI)crJJKQ4ZKKHsqObRIHtOdQk5uKu5yKQJljyHsQwkeSyiTCKEivYtrTmsX6iPknrQuYuLuMmvnDfxec9AcCzW1LK2ijvvBLeSzvP2oP0hjPQ8DjHMgvk18OsLhlXZiP0OjrJNkfDscQdrqY1ii19iiAykPZrqWVrC0tTWiIn0o4dAy3cEBv7tQhUzFiml)U2hUkvRuR1vV7JifQlhqiQ0UqyeGoyxinnR6pwvKUMfnA0vKBlecZfQuCch(vzKe8n1stp1cJi2q7Gp1dZfQuCcxiKUNur8YNGvrixajQCGLIsJQcU7J72h1g(fQSlNNHF3nSajwfY7qLcGWUucfboeTWhWtqd7q8ky0M9HWHB2hcR(7gwGeRAF4HkfaHra6GDH00SQ)qFnSWyVSydHggtWqyhIVzFiCM00KAHreBODWN6H5cvkoHhIkvDyPqiDpPI4B4xOYUCEg(kkNrIvHSqqPwyxkHIahIw4d4jOHDiEfmAZ(q4Wn7dHzr5msSQ9XfbLAHra6GDH00SQ)qFnSWyVSydHggtWqyhIVzFiCM0uBQfgrSH2bFQhMluP4ewO2hpzw6wbO2alJSiqIvf(fQSlNNH7wbO2aHDPekcCiAHpGNGg2H4vWOn7dHd3Spe2nScqTbcJa0b7cPPzv)H(AyHXEzXgcnmMGHWoeFZ(q4mP52PwyeXgAh8PEyUqLItyRmsTasadFjC3hHCF03Nk3NX6aEwUaveWdY7iXQwaSH2b)(u5(iu7JNmlxGkc4b5DKyvlJSiqIvf(fQSlNNHPM4qOiVdvkac7sjue4q0cFapbnSdXRGrB2hchUzFimcM4qO7dpuPaimcqhSlKMMv9h6RHfg7LfBi0Wycgc7q8n7dHZKMqNAHreBODWN6HDiEfmAZ(q4Wn7dH5bG((uJAIHFHk7Y5z47aqh5qnXWiaDWUqAAw1FOVg2LsOiWHOf(aEcAyHXEzXgcnmMGHWoeFZ(q4mPPOulmIydTd(upSdXRGrB2hchUzFi8R9XPk1d09H8EFCrjv8g(fQSlNNHnK)QupqrsEJSqjv8ggbOd2fstZQ(d91WUucfboeTWhWtqdlm2ll2qOHXeme2H4B2hcNjThPwyeXgAh8PEyhIxbJ2SpeoCZ(qy3IAQi47Bjf2h1hfWMhc)cv2LZZWEQPIGVVLuaPkkGnpegbOd2fstZQ(d91WUucfboeTWhWtqdlm2ll2qOHXeme2H4B2hcNjn1tQfgrSH2bFQh2H4vWOn7dHd3Spegr3uStUsTW(uJAIHFHk7Y5zyWnf7KRulGCOMyyeGoyxinnR6p0xd7sjue4q0cFapbnSWyVSydHggtWqyhIVzFiCM0ecPwyeXgAh8PEyUqLItyHAF8KzPy9HseVlJSiqIvf(fQSlNNHlwFOeXByxkHIahIw4d4jOHDiEfmAZ(q4Wn7dHDz9HseVHra6GDH00SQ)qFnSWyVSydHggtWqyhIVzFiCM00xtTWiIn0o4t9WCHkfNWQzFGkuvkkc(f0QtrjqVirjyaPjsj49PY9bT673lOvNIsGErIsWastKsWl3Xkc2hHCF0x3Nk3NlmJeR6UCfbShPjsjyK3XkcU7J62h37(9rn7duHQsrrWV8MkvSIjxKVLyvaDOM4(u5(4jZs3ka1gyHcFtIV7J72h1UOO9rDHFHk7Y5zy0QtrjqFg2LsOiWHOf(aEcAyhIxbJ2SpeoCZ(q46vNIsG(mmcqhSlKMMv9h6RHfg7LfBi0Wycgc7q8n7dHZKMUEQfgrSH2bFQhMluP4ewn7duHQsrrWVGwDkkb6fjkbdinrkbVpvUpOvF)EbT6uuc0lsucgqAIucE5owrW(iK7J(6(u5(CHzKyv3LRiG9inrkbJ8owrWDFu3(4E3VpQzFGkuvkkc(L3uPIvm5I8TeRcOd1e3Nk3hpzw6wbO2alu4Bs8DFC3(O2ffTpQl8luzxopdxmQwiSlLqrGdrl8b8e0WoeVcgTzFiC4M9HWUmQwimcqhSlKMMv9h6RHfg7LfBi0Wycgc7q8n7dHZKMUMulmIydTd(upmxOsXjSNmlDRauBGfk8nj(UpUBFu7IIc)cv2LZZWDRauBGWUucfboeTWhWtqd7q8ky0M9HWHB2hc7gwbO2a7JA0vxyeGoyxinnR6p0xdlm2ll2qOHXeme2H4B2hcNjtyweksRlvSnsconncTqNjb]] )

    storeDefault( [[SimC Survival: mokMaintain]], 'actionLists', 20170625.195247, [[diZccaGEIsTli61iA2k5MsXTLQDQO9k2nQ2pHgfrHHPk(nsdMGHljhuP4uQs1Xq4CeLSqvjlfswSQA5O8qLQEkyzezDQszIsQAQsktgQMovxuPYLjDDi1wLq2SuA7suhMY0ikAEsOEou(MsPrlrEScNusLtRY1iQ68sqFNOY2Ka)fchIulWoU9xkE(bQxBn0lpVcmTUgaU(ErbanR8v2wVjk0PKn2XD74bqPl1W0mLEi2(uaHesjjIcKPScad2v5bcSz4hLJLAzsKAb2XT)sXZRaWGDvEGp62wKDkj38s2cHBd)gyizA3ooMOqXIcm9JUTfHChhNkxGn)BDEHbywLtziWC2rQb2xshKn0YAx5E(bAO4fzSP11abMwxdGYQCktuaC2rQbqPl1W0mLEi2s8eOoo(nmNYcWPCnqdfFADnq8mLsTa742FP45vayWUkpWhDBlYoLKBEjBHWTHFdmKyUniffkwuqkWM)ToVWamRYPmeyo7i1a7lPdYgAzTRCp)anu8Im206AGatRRbqzvoLjkao7ivrbzq8Eau6snmntPhITepbQJJFdZPSaCkxd0qXNwxdepEaOshNTozB(r5zkjV8Xta]] )

    storeDefault( [[SimC Survival: bitePhase]], 'actionLists', 20170625.195247, [[d8dPfaWCLA9ujvBIQk7Ik2gjs7tjPdl6BKkMTqZNeHBQeNNeUTGtt0ojyVq7g0(v1OOsnmsv)wYHuOyOKiAWQmCfYbrkofvXXKsNJQQQfQKAPujwmclxQEiPspLYJv06OQQmrQQIPIuAYiz6axePYRuOQNPqPRJiBKkjBLQsBMK2osvxIQQ0Fj00uOY8ir5ZKYRLIrRGVtvXjPk1QusCnsuDpQsghvs5YOwgIASfPfn6GjrKPqc08hwnjfb4A0eYaJMjd6(NrQtVK(m6F)ribSsoKBgnx4iNBgfiRVvh9kTLSdzYTkDC(pA2SlhbqdnAMazb3iTOqlslA0btIitHRrZMD5iaAU)Bm)bYidbo(KkelvrWalgQgycgYOddtIit9NsOe)rqsv1junWemKrrqobY52PZHuc3)T6FU)tBs93k)5(px7p)9VX(NN)88NN)87pcsQQoHcQv1Mfvj1v4Sb5S5pV(tPOrdHmkbkqtLuxHyPkcgyro1ImAEdPKZeuD0GfKrBPO8n7czGrdnHmWO5ksDf)vQ)bg4)Ol1ImA0012OjHaU3jncikv9YniJme44tQqSufbdSyOAGjyiJommjImLFeKuvDcvdmbdzueKtGCUD6CiLWTY8ciNnIazG9GMlCKZnJcK13QtRE00DGNnlf9CGHaKaTLIsidmAiafiJ0IgDWKiYu4A0SzxocG2Ci7A8(Vv96pY)53FZQIuLpqNqb1QAZIesa705qkH7)u2FAtQ)w5pYOrdHmkbkqluqTQ2SiHeWOP7apBwk65adbibAlfLVzxidmAOjKbgTLcQv1M)BTeWO5ch5CZOaz9T60QhnVHuYzcQoAWcYOTuuczGrdbOWyrArJoysezkCnA2SlhbqZ9FU)JGKQQtOGAvTzrvsDfoDoKs4(Vv)Z9FAtQ)w5p3)nRksv(aDcfuRQnlsibSZCi7A8(VX)h5)88NN)88NF)nRksv(aDcfuRQnlsibSZCi7A8(pL51FT)55p)(Bm)rqsv1j3J4jqSufbdSiNAr2H0i0OHqgLafOPgtyJeQjUbDzdJMUd8SzPONdmeGeOTuu(MDHmWOHMqgy0CvmHnsO2FgOlBy0CHJCUzuGS(wDA1JM3qk5mbvhnybz0wkkHmWOHauyCiTOrhmjImfUgnB2LJaOrqsv1juqTQ2SOkPUcNohsjC)3QAtQ)g)FU)lMagov83k)r(ppOrdHmkbkqluqTQ2SiHeWOP7apBwk65adbibAlfLVzxidmAOjKbgTLcQv1M)BTeW)5U1dAUWro3mkqwFRoT6rZBiLCMGQJgSGmAlfLqgy0qakOCKw0OdMerMcxJ2sr5B2fYaJgAczGrZvXe2iHA)zGUSH)ZDRh0OHqgLafOPgtyJeQjUbDzdJMlCKZnJcK13QtRE00DGNnlf9CGHaKanVHuYzcQoAWcYOTuuczGrdbianBepLzu66jqwquGSYvocqea]] )


    storeDefault( [[Survival Primary]], 'displays', 20170625.195247, [[d8d5haWyKA9QsEjjP2fse2MQq9BOMjjvtJKOzRW5PIBQkYPr5BQcCmP0oP0Ef7MO9dj)esnmkmoKi5YQmusmyiA4iCqPQJIePoSKZrsWcLklfjSyQQLt4HsrpfSmkYZj1evfYur0KrftxPlQOUkjLEgsuDDv1gLcBfjI2mvz7q4Juu9Avr9zK03vKrssX6ijz0OQXRk1jrLUfjHUMQGUhsu62uP1IefhNIYPnKbOlILHLnWYfwNXfaTAjvNRDoaDrSmSSbwUa71fBRPaIss9AYF0pNUa(d2RxMpWtXpGdApp9TnlILHL6ync8gTNN(2MfXYWsDSgbiem3s4WLglb2RlwvAeWLj7NJ1uaZ(3)40SiwgwQtxah0EE6Bjlb1B1XAeGs)V)PdzSTHmWSS8hhN0fONEzyjkKQZ0BSQqaB5EbO4RlEvHcjH4OXU(1gGIBCL(I1Kr7dmAnmca0cgXgyzUhL1iBSMczGzz5pooPlqp9YWsuivNP3yPubSL7fGIVU4vfkKCoV6p2auCJR0xSMmAFGrRHr2Sb084jyIT089ZPlGMhp1)xC6cO5XtWeBP57)loDb2sq92EjnpweOdnjj6NOGR5QHmGtSQOPhBe4DSgb084jYsq9wD6c8SFVKMhlcqIwHcUMRgYa0yx)Avqmh)a0fXYWYEjnpweOdnjj6NcaehnRgSx1YWYyn9WhgqZJNaY0fWS)9VhXeh9YWYauW1C1qgq(D5sJL6yvzanXngngLMVjEGfHmqfBBarSTbOgBBa)yBZgqZJNAweldl1PlWB0EE6B7)IkwJa1xuKoexa)VNxa36D)FXXAeOge8v)yQC0kiMJTnqni4lGhpPGyo22a1GGVAID9RvbXCSTbE05v)XMUa1yQC0kiusxaemnZNnyRdPdXfWpaDrSmSSFWOkd0C2sotraomnXOCiDiUavarjPEKoexGYNnyRtG6lQNyYlDbm7ZOFMsY0W6mUavGN9BGLlWEDX2AkGTCVaWxGGHOgOqQiyULWjqni4lYsq9wfekX2gWbTNN(wUsom6AXcDSgbe3iqZzl5mfb0e3y0yuA(4hOge8fzjOERcI5yBdWKCy01If9sAESiafCnxnKbm7F)JdxjhgDTyHoDbCzY()IJ1iq9fvVKMhlc0HMKe9tQp3GmWwcQ32alxyDgxa0QLuDU25apvVzUFxuijzUxSuUragnwcefntsn2hgaOfmInqGAqWx9JPYrRGqj22a1xuCLEyshIlG)3ZlaHG5wcNgy5cSxxSTMcqioASRFT9kQhayUnrHe(ceme1qvOqsioASRFTb084P(VO4k9WXpGB9UFowJaK14KlkKMlWFIyncSLG6TkiMJFafbZTeoOq2SiwgwgqlQLHdO5XtQ(C8zsomjvD6cW58Q)y7vupaWCBIcj8fiyiQHQqHKZ5v)XgWbTNN(wv3PJvfBd8gTNN(wYsq9wDSgbE2VbwUW6mUaOvlP6CTZbCq75PVT)lQyncO5XtCLCy01If60fOge8fWJNuqOeBBGAmvoAfeZPlq9ffqCJb3hfRranpEsbXC6cqJD9RvbHs8d8SFdSCdOqIcjusnkK2siWtb084P(50fqZJNuqOKUaUmjqgRrGTeuVTbwUa71fBRPaVr75PVv1D6yncqxeldlBGLBafsuiHsQrH0wcbEkqni4RMyx)AvqOeBBGzz5pooPlGM5smUE0ZXAkG)G96L5d8u)ye)aEy5gy(nH406PYjWwcQ3QGqj(bm7F)RFWOkDp5gGoaf34k9fRjJ2hy84wtuctMAFSkvHakcMBjCqHSzrSmSefY(VOc8ewsfJ1hkKn(cNaM9V)XHlnwcSxxSQ0iGB9giJTnaJglPmySBSuUraZ(3)40alxG96IT1uGTeuVTbwUbuirHekPgfsBje4PaM9V)Xr1D60f4nApp9TCLCy01If6yncuFrPwjBdqmkNtKnba]] )

    storeDefault( [[Survival AOE]], 'displays', 20170625.195247, [[dee7haqiKuvBcjfDlIKAxiPWWKshtkwgQ0ZisyAKICnIuTnIK8nvqnoKuY5is06ifCpKuQdQGfQipKQQjQcYfvOnsv5JQaJKiLtseVKuOzsk5MQqTtk9tiAOKQJIKkwQkQNcMkIUkPO2ksQ0Arsv2RyWqYHLSyI6Xi1KrfxwvBMk(msmAu1Pr51QqMTuDBQYUj8BOgochNuQLtXZjz6kDDvA7q47kQXJKCEQ06vr2pK60eYa0fXYWcFyXcRB)dGuZKAjXogGUiwgw4dlwGD6JTHBatjO8(5F6JYua5o70Pd645ihWfPJJ6x)fXYWcvSTbOcPJJ6x)fXYWcvSTb0((3NJeASayN(y1uBafpEE4AkjchCKdO99Vph)fXYWcvMc4I0Xr9lzzO8Rk22auN7FFviJTjKbgfLC)5KPad0ldlqJslMAJvkdylVpW5RQ41aAueMNg7jxBGZF)l1hl32Md3202gaOnmInWY8EQDB2y5gYaJIsU)CYuGb6LHfOrPftTXsTcylVpW5RQ41aAuCEN623aN)(xQpwUTnhUTPTnB2akE8mmZwA(HXmfGkKooQFjldLFvX2gWROciJTnWwgk)oiO5XMatijjrE8zjhinYaUXk1CBKEahSydmsfH5vQ5YnGIhptwgk)QYuGJKhe08ytasK6NLCG0idqJ9KRvhXyKdqxeldlge08ytGjKKKipoaq80SQZovldlILR0LEafpEgiZuaTV)9peZ80ldlcCwYbsJmG46jHgluXQPakIV391lfVFChBczGk2MaMyBcqj2MaYX2KnGIhp7ViwgwOYuaQq64O(D4AQyBduxtr6s8bKVoob8kQgUlo22avNGVg6ZLRshXySnbQobFb84zDeJX2eO6e8LFSNCT6igJTjWHEN623mfO6ZLRshHEMcGGPyYSoBDjDj(aYbOlILHfdDgfra)JwYXZb4Wue9YL0L4dqhWuckpPlXhOKzD26gOUM6yM4ZuaTVm6JOUmfSU9pqf4izFyXcStFSnCdylVpaCniyiQoAudihdOByELXfnk)fXYWc0OgUMkWXybfmw9Or57ACd4Xed3fhl3aMVhW)OLC8CafX37(6LIpYbQobFrwgk)QJym2MaUiDCu)krWHrxl2OITnG23)(CKi4WORfBuzkGIhpdZSLMF4U4mfOUMAqqZJnbMqssI8yTg9rgyldLF9HflSU9pasntQLe7yGJlQyExp0OizEFSsrBagnwaefntqjwPhaOnmInGIjO0FQj1VUloq1j4RH(C5Q0rOhBtG6AkjchmPlXhq(64eGWW8kJRpSyb2Pp2gUbimpn2tU2bDTcamp)OrbxdcgIQRb0Oimpn2tU2akE88WDXroGxr1WySTbiR(lw0OoWGVeX2gyldLF1rmg5akE8SgFxzMGdtqrLPaN)(xQpwUTnhUvQA4sn4YTrQ0KugGZ7u3(oORvaG55hnk4AqWquDnGgfN3PU9nGlshh1VACsfRu3eyldLF9HfBaDs0OGsOqJYwgdEoWrY(WIfw3(haPMj1sIDmGlshh1VdxtfBBafpEwIGdJUwSrLPavNGVaE8Soc9yBcu95YvPJymtbQRPaIV3LCOyBdO4XZ6igZuaASNCT6i0JCGJK9HfBaDs0OGsOqJYwgdEoGIhppmg5akE8Soc9mfWJjaYy5gyldLF9HflWo9X2WnaviDCu)QXjvSnbOlILHf(WInGojAuqjuOrzlJbphO6e8LFSNCT6i0JTjWOOK7pNmfqX8i6)aYXy5gqUZoD6GoEEO3JCaTV)9h6mkcVxSbOdSLHYV6i0JCGQtWxKLHYV6i0JTjGUH5vgx0O8xeldlcOm1YWbimmVY4kHgla2Ppwn1gGj4WORfBge08ytGZsoqAKb8yIHXy5gGrJfupm2lwPOnG23)(C8HflWo9X2WnavX2gq77FFoACsLPauH0Xr9RebhgDTyJk22a11uAwW2ae9Y9nzta]] )


    ns.initializeClassModule = HunterInit

end
