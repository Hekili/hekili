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
            known = function () return equipped.talonclaw end,
            toggle = 'artifact',
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


    storeDefault( [[SimC Survival: biteFill]], 'actionLists', 20170717.202456, [[dOJNhaGEKQSjPc2LuLTHQeZePQy2ICtk5BssNMIDkQ9s2nk7hPCyQ(Rq1Vr8yPCEPsdgOgUqoesvvJdvHCmj15qvKfQkSuGSyKSCqpKs5PqlJs1ZfmruL0uvLMSetxLlQk6ZQQ8mufQRJk2isvPTQQQnlu2oQ0hrQQCCuLY0qvQ(UuHETK42agnQQXJQOojsLlRCnPIUhQcADOkWWuvoOuvRA9k8jZPsRikH86I5CsNEieJwZ4jd98ZqykBVZofcAP5HPS9V6QF8I9o7vZtDAN3RkeBqt0juy)2ziSGEvUwVcFYCQ0k6HqSbnrNWJ87xA9AesQq6iliSpLjzUUcdrM7mSFXBekOlKowX08JafYiSj0Iu(7WSdmHcZoWeIrM7mSF0aBJqbDHGwAEykB)RUA9Nqqlq4aBlOxDcTXFTkweUdyStucTiLSdmH6u2UEf(K5uPv0dHydAIoHJ34yIIwPxmOHE0JeIhZW(n4b9iAG7anWfY1l5Tb9B9GlgCb(ovAc7tzsMRRqkoxJ)GDfshRyA(rGcze2eArk)Dy2bMqHzhycFW5A8hSRqqlnpmLT)vxT(tiOfiCGTf0RoH24Vwflc3bm2jkHwKs2bMqDkZJ1RWNmNkTIEieBqt0jC8ghtu0k9Ibn0JEKq8yg2VbpOhrdChObUqUEjVnOFRhCXGlW3PstyFktYCDf2Ci3jKowX08JafYiSj0Iu(7WSdmHcZoWeAZHCNqqlnpmLT)vxT(tiOfiCGTf0RoH24Vwflc3bm2jkHwKs2bMqDkZ76v4tMtLwrpeInOj6ecxm4c8DQ0e2NYKmxxHjVnOFtiDSIP5hbkKrytOfP83HzhycfMDGjK(4Tb9BcbT08Wu2(xD16pHGwGWb2wqV6eAJ)AvSiChWyNOeArkzhyc1PCN6v4tMtLwrpeInOj6e6TZWDXhBaMfObMhsdCnnWDGg4ZtJD9cdgn2fpCg2VEJ5uPvObUd0axixVWGrJDXdNH9RhCXGlW3PstyFktYCDfc9OJaJhoOPYeshRyA(rGcze2eArk)Dy2bMqHzhycb5rhbsdmEqtLje0sZdtz7F1vR)ecAbchyBb9QtOn(RvXIWDaJDIsOfPKDGjuNY8IEf(K5uPv0dH9PmjZ1vy42sXpOhjKowX08JafYiSj0Iu(7WSdmHcZoWeI3wIg4xOhje0sZdtz7F1vR)ecAbchyBb9QtOn(RvXIWDaJDIsOfPKDGjuNYv1RWNmNkTIEiSpLjzUUc94aCGLbJtIfVbjDmiKowX08JafYiSj0Iu(7WSdmHcZoWe2NgyloWYG0atIrdSniPJbHGwAEykB)RUA9Nqqlq4aBlOxDcTXFTkweUdyStucTiLSdmH6uMhPxHpzovAf9qyFktYCDfwG(pcleZax8FWX8YeshRyA(rGcze2eArk)Dy2bMqHzhyc5vO)JWcXmWrdm9doMxMqqlnpmLT)vxT(tiOfiCGTf0RoH24Vwflc3bm2jkHwKs2bMqDkZt6v4tMtLwrpe2NYKmxxHJNJsKGH7IFqpsiDSIP5hbkKrytOfP83HzhycfMDGj8jphLibd3rd8l0JecAP5HPS9V6Q1FcbTaHdSTGE1j0g)1Qyr4oGXorj0IuYoWeQt56p9k8jZPsROhcXg0eDcP)0aFMwfd7NW(uMK56kS5PdsIccPJvmn)iqHmcBcTiL)om7atOWSdmH280bjrbHGwAEykB)RUA9Nqqlq4aBlOxDcTXFTkweUdyStucTiLSdmH60jm7atiAaSrdmYbY1W1t8aAGPm3OVMusNea]] )

    storeDefault( [[SimC Survival: CDs]], 'actionLists', 20170717.202456, [[dSJ(faGELQOnbfTlQ02uQs7JKWSv4MkLtROVbfoSQ2jK2R0UrA)KAuIQmmOQFl8yQAOkjXGPy4kXbvsDkrvDmOY5uQcluPYsjulMGLtPhcLSkePSmQW6usktuPQAQiQjdX0v5IqPUhjrxgCDISrLK0wjjTzIA7iIPPuvEgIKptIVts1irKQBJWOjK)kkNKKY8usQUMsIZtf9ArLNlYtrDXvYLXM(cdaPcL3pi)sJR7kZlGF(J5E(3mOf1XkRuwmmGpbf1bECyGFVowXf3ESIJ9Hrz2BNlx5YR93mOPsUO4k5YytFHbG0DLzVDUCLLdVuY1lzTa90MvxLAdPWxETWCmpNLFR)Pq2fwlqVYQrrM()cBzAqHYBbIQVf9jGYLrFcO8AR)PG2qoSwGELfdd4tqrDGhhg4WxwmKcjRhsLCVYyjc852csacGEvO8wGG(eq5Ef1rjxgB6lmaKURm7TZLR8fkkdW1hXajuNM0gm1M80gbjzz3pTa(llKZorqg8kdWvArBYV8AH5yEolla2eyZnPkLvJIm9)f2Y0GcL3cevFl6taLlJ(eq5DGnb2CtQszXWa(euuh4XHbo8LfdPqY6Huj3RmwIaFUTGeGaOxfkVfiOpbuUxrjvjxgB6lmaKURm7TZLR8fkkdW1hXajuNM0gm1M80gbjzz3pTa(llKZorqg8kdWvArBYV8AH5yEollmIajtwY6SSAuKP)VWwMguO8wGO6BrFcOCz0NakVBebI2SQswNLfdd4tqrDGhhg4WxwmKcjRhsLCVYyjc852csacGEvO8wGG(eq5EfDFLCzSPVWaq6UYS3oxUYxOOma3L4MbnPnyQn5PncsYYUFAb8xwiNDIGm4vgGR0I2KF51cZX8CwEjUzqlRgfz6)lSLPbfkVfiQ(w0Nakxg9jGYRsCZGwwmmGpbf1bECyGdFzXqkKSEivY9kJLiWNBlibia6vHYBbc6taL7v0vk5YytFHbG0DLzVDUCLVqrzaU(igiH60K2GP2KN24JyGeQtDjcQsejityEGRx0BvGK2OsTbV2GP2iijl7seuLisqMSK1PRfi(jnPnQqBiL2qAAJIhrBWuBeKKLD)0c4VSqo7ebzWRmaxKqDQ2KF51cZX8Cwor)CqMij6b2YQrrM()cBzAqHYBbIQVf9jGYLrFcOmt)CG2q6s0dSLfdd4tqrDGhhg4WxwmKcjRhsLCVYyjc852csacGEvO8wGG(eq5EfDVLCzSPVWaq6UYS3oxUYxOOmaxFedKqDAsBWuBYtBeKKLDjcQsejitwY60nDVpN2OcvQno0gm1gbjzzxIGQercYKLSoDTaXpPjTrfAdP0gstBu8iAt(LxlmhZZz5pTa(llKZorqg8kdOSAuKP)VWwMguO8wGO6BrFcOCz0NakVoTa(tBczT5ebAd2VYaklggWNGI6apomWHVSyifswpKk5ELXse4ZTfKaea9Qq5Tab9jGY96vg9jGY8KalTHLSKmj5hRM2G1(t9Ab]] )

    storeDefault( [[SimC Survival: AOE]], 'actionLists', 20170717.202456, [[dCd0daGEuQ0MGq1UGk2guj2hekZwKBsL(MuyNc2lz3iTFu0OGkPHjv9BedgQA4sLdsP6uqLQJrfNdLclKQyPq0IHYYr1drjpfSmi1Zf1eHkLPkLMSQmDvUiLYPP4YkxhfoSKTcjTzuQA7uvpwOxlfnnkbpdLIUTQ6qOuQrtjnEkHojK4ZqixdcopvP)sjADOuYprPILJAfyJwyP9eMaCBSVyKo5ra0TOPsg2TodHQaAeqqaYLwLNcO7DA0JlOrahh2ab0wOHaiYnDNab2JNHqZQvbh1kWgTWs7jpcSJzsMZRamgx064EfGc9zI1r4cOe6e4sEOw8q9NabH6pbEyCrRJ7vaYLwLNcO7DA40la5Yeg84YQvNawwxSPlXF)rpHjWL8c1Fc0PaA1kWgTWs7jpcGi30DcyBM4ptSPHIib2XmjZ5vqSshN0LfGc9zI1r4cOe6e4sEOw8q9NabH6pbSQ0XjDzbixAvEkGU3PHtVaKltyWJlRwDcyzDXMUe)9h9eMaxYlu)jqNcSPAfyJwyP9Khb2XmjZ5vWSyxIKn(ZYJxDcqH(mX6iCbucDcCjpulEO(tGGq9NaBwSlrYg)XeFlV6eGCPv5Pa6ENgo9cqUmHbpUSA1jGL1fB6s83F0tycCjVq9NaDkyb1kWgTWs7jpcGi30DcUkn6HtE8UrplZNHIiCgTWs7XepIZe)JC4KhVB0ZY8zOich(ypFzRfwAcSJzsMZRGyX9NauOptSocxaLqNaxYd1IhQ)eiiu)jGvX9NaKlTkpfq370WPxaYLjm4XLvRobSSUytxI)(JEctGl5fQ)eOtbeuRaB0clTN8iaICt3jOINXFwo6(MLzIhXyIhbb2XmjZ5vqS4(tak0NjwhHlGsOtGl5HAXd1FceeQ)eWQ4(JjEC1b3fGCPv5Pa6ENgo9cqUmHbpUSA1jGL1fB6s83F0tycCjVq9NaD6eeQ)eaMplM4bgCFJFLylM4TZo20jb]] )

    storeDefault( [[SimC Survival: default]], 'actionLists', 20170717.202456, [[d4ZMiaGEOQAtKuWUuf12uLQ2hjfzMQICALMnKdt1nfPhRW3GkopczNqzVs7MW(v0pjPsddrnoskQNtPHssvdwudhH6qKusNsvOJHGZrsPwiuPLsswmPSCHwKQKNcwMiSob1evLktLeMmsnDvUOQkxLKcDzuxxGnssfBLe1MfeBhjFwvvptvknnvP47KuIBtXRHQmAr0FrKtsI8qs11GQY9eKgLQGdQQ8BIUeQIc)eUgIPRwH3XH4bOR4waiMhRJw873kfflb(WxbvmIDlxSeKjGd53NaFptqTXxI3GtbyexIVcf(g3kf2QOyeQIc)eUgIPlUfGrCj(kCY))r8ZR44ymG4ZoZQHz(Hz(84F(EMM1ccjKNhU9wX)NdiEMFSWN2I2JOcMa8JFexqjb9o8tgliKcUqQKwzpI5gUqbm3WfsdWp(rCbvmIDlxSeKjGdbYfuXwzqCW2QOxb9K8aVujfByXvTcPsAm3Wf6vSevrHFcxdX0f3cFAlApIkeyzs7XgBbLe07WpzSGqk4cPsAL9iMB4cfWCdxqnA5zwPJn2cQye7wUyjitahcKlOITYG4GTvrVc6j5bEPsk2WIRAfsL0yUHl0RyVTkk8t4AiMU4wagXL4RW5iwCpRwCIijdH0LKjzK4j8lPJEMfUgIPl8PTO9iQWWris(4wPGeATxbLe07WpzSGqk4cPsAL9iMB4cfWCdxq3rOz(BCRumZpT2RWx8VTGWnCOVG1OpZqqKAPCu4z2iXl1xX5R4vbvmIDlxSeKjGdbYfuXwzqCW2QOxb9K8aVujfByXvTcPsAm3WfG1OpZqqKAPCu4z2iXl1xX5ROxXEtvu4NW1qmDXTWN2I2JOcdhHi5JBLcsO1EfusqVd)KXccPGlKkPv2JyUHluaZnCbDhHM5VXTsXm)0AVz(bcpw4l(3wq4go0xWA0NziisTuok8mR)o7RcQye7wUyjitahcKlOITYG4GTvrVc6j5bEPsk2WIRAfsL0yUHlaRrFMHGi1s5OWZS(7S9kg(QIc)eUgIPlUfGrCj(kOwNzFClftYif)LsltkKGirf(0w0Eevy4iejFCRuqcT2RGsc6D4NmwqifCHujTYEeZnCHcyUHlO7i0m)nUvkM5Nw7nZpK4XcFX)2cc3WH(cwJ(mdbrQLYrHNzIJmU7XQpPB5xfuXi2TCXsqMaoeixqfBLbXbBRIEf0tYd8sLuSHfx1kKkPXCdxawJ(mdbrQLYrHNzIJmU7XQpPB5Ef79vrHFcxdX0f3cWiUeFf8XTumjwWMLTZSAk0z(Tf(0w0Eevy4iejFCRuqcT2RGsc6D4NmwqifCHujTYEeZnCHcyUHlO7i0m)nUvkM5Nw7nZp82hl8f)BliCdh6lyn6ZmeePwkhfEM)u3FVkOIrSB5ILGmbCiqUGk2kdId2wf9kONKh4LkPydlUQvivsJ5gUaSg9zgcIulLJcpZFQ7VEfdNQOWpHRHy6IBHpTfThrfgocrYh3kfKqR9kOKGEh(jJfesbxivsRShXCdxOaMB4c6ocnZFJBLIz(P1EZ8dV5XcFX)2cc3WH(cwJ(mdbrQLYrHNzT9y1N0T8RcQye7wUyjitahcKlOITYG4GTvrVc6j5bEPsk2WIRAfsL0yUHlaRrFMHGi1s5OWZS2ES6t6wUxXuZvrHFcxdX0f3cFAlApIkmCeIKpUvkiHw7vqjb9o8tgliKcUqQKwzpI5gUqbm3Wf0DeAM)g3kfZ8tR9M5hW3Jf(I)TfeUHd9fSg9zgcIulLJcpZA7XQZIqVkOIrSB5ILGmbCiqUGk2kdId2wf9kONKh4LkPydlUQvivsJ5gUaSg9zgcIulLJcpZA7XQZIq9kMAxff(jCnetxCl8PTO9iQWWris(4wPGeATxbLe07WpzSGqk4cPsAL9iMB4cfWCdxq3rOz(BCRumZpT2BMF49pw4l(3wq4go0xWA0NziisTuok8mhYIqC0(QGkgXULlwcYeWHa5cQyRmioyBv0RGEsEGxQKInS4QwHujnMB4cWA0NziisTuok8mhYIqC02Rxbm3WfG1OpZqqKAPCu4zMMdXdqxVwa]] )

    storeDefault( [[SimC Survival: precombat]], 'actionLists', 20170717.202456, [[dqZjeaGEIs1UOcSnQGMTi3KeFJQYoP0Er7MW(LKgMK63kgkvOgSOQHlkhKQQJrsNJOKwOKyPkXIHQLtQhsL6PGLPu9CPAIuHmvQYKLY0HCrQKttXLvDDIQdlSvLsBMiy7ePpseYJHYNjIEgrPmsIs8ALIrlQmEQioPsQBlX1ikoVsY0OI0FPIADeHAQspcUebE6nItWrxcH8eIviazhZejJShiZiODxgziS80J(PDVw1xTd3LXbQYQm7o1hbatBYqei4hdzgrNE0QspcUebE6nwHGFCtYGwrOlVugHZzhryTOzWc0OjigXjOmTTH2gLtGGnkNG7iLQM3XhvnVkHLNE0pT71Q(uRjS8(ixJ9o9iIG7ChBJYi9LlqeNGY0Sr5eiI2D6rWLiWtVXkeamTjdranskz6oiBqMr0j4h3KmOveYgKzeewlAgSanAcIrCcktBBOTr5eiyJYj44bzgbHLNE0pT71Q(uRjS8(ixJ9o9iIG7ChBJYi9LlqeNGY0Sr5eiIwzJEeCjc80BScb)4MKbTIWDswA6gP3zKoYiSw0mybA0eeJ4euM22qBJYjqWgLtWLtYst3i9vZ7PJmclp9OFA3Rv9Pwty59rUg7D6reb35o2gLr6lxGiobLPzJYjqeToLEeCjc80BScb)4MKbTIqh9NCgPJmcRfndwGgnbXiobLPTn02OCceSr5ea0FQAEpDKry5Ph9t7ETQp1AclVpY1yVtpIi4o3X2OmsF5ceXjOmnBuobIOvg6rWLiWtVXke8JBsg0kcnDi5i6sWOVZsQViANWArZGfOrtqmItqzABdTnkNabBuobhPdjhrxcg9RMxI0xeTty5Ph9t7ETQp1AclVpY1yVtpIi4o3X2OmsF5ceXjOmnBuobIO1H0JGlrGNEJvi4h3KmOveYf6SzeewlAgSanAcIrCcktBBOTr5eiyJYjilHoBgbHLNE0pT71Q(uRjS8(ixJ9o9iIG7ChBJYi9LlqeNGY0Sr5eiIic2OCcGP4UAEqUwQrAKK4Q5Z0hBk4bIisa]] )

    storeDefault( [[SimC Survival: fillers]], 'actionLists', 20170717.202456, [[dOZNeaGEsvPnHGAxePTHaAFiiZwj3uQ6Ba40KStLAVu7gv7xWOivmme53eoSKhlLbl0WrHdkv6uevDmrCosvXcrOwkiTysz5i9qrQvrQQwgI65IAIKQWub0Kb10vCruKxrQsUSQRtepdfvTvIkBwKSDq8xuQVJannuuMhkQ8AuYNbOrtugpcWjjv6wKQORjvCEeY6ivPEk0TbANyGgzIxARdBnJ6XtvswJj2iY4nvTu6Bnkb3BYD6ye6xVY3BYKsaGebsUJ0e9PdzMbGrSrvmgJg72gLGNnqVtmqJmXlT1HnXgXgvXymwTrb5Sp)GQNdrcfIjHiHdXPwNpsZNY48HDEuCaLEEPToCis4qewmsZNY48HDEuCaLsFk6ZYkT1n2vtTudrgBffYnQlhw1QrqnYf8BSxalxr3f4nACxG3y6Ic5gH(1R89MmPeasize6Zcj02ZgOhJPL9gREbKdE(ynJ9c4DbEJE8MSbAKjEPToSj2yxn1snezCKrfeuXbKDrapBuxoSQvJGAKl43yVawUIUlWB04UaVrGYOccQ4agIDjGNnc9Rx57nzsjaKqYi0NfsOTNnqpgtl7nw9cih88XAg7fW7c8g94nZBGgzIxARdBInInQIXySAJcYzF(bvphIekejBSRMAPgIm2kkKBuxoSQvJGAKl43yVawUIUlWB04UaVX0ffYdrDsK3i0VELV3KjLaqcjJqFwiH2E2a9ymTS3y1lGCWZhRzSxaVlWB0J3mZanYeV0wh2eBeBufJXOoH4uRZhPeSiITif7r2zdkyXRrwTKEEPToCis4qutsQusbfS41iRwSNQnQwwk9GLINdrMlebSbhI6pezwikVXUAQLAiYiTymck78qvSUrD5WQwncQrUGFJ9cy5k6UaVrJ7c8gHwmgbneXHQyDJq)6v(EtMucajKmc9zHeA7zd0JX0YEJvVaYbpFSMXEb8UaVrpE3XanYeV0wh2eBeBufJXykrtswAtcLE(eIeke1je1jej3je1ZqmLOjjlLEappe1FicydoeLpe1RqStNquEJD1ul1qKrAXyeu25HQyDJ6YHvTAeuJCb)g7fWYv0DbEJg3f4ncTymcAiIdvX6HOojYBe6xVY3BYKsaiHKrOplKqBpBGEmMw2BS6fqo45J1m2lG3f4n6XJXDbEJOcmDiIsOquqQLEhIPuR1Pzp2]] )

    storeDefault( [[SimC Survival: preBitePhase]], 'actionLists', 20170717.202456, [[d8ZWkaqAcRxssBcvk7svyBssv7tveMPKu5WIMTuESq3KOoVQkFts1ZfStj2l1Urz)KYOufvnmvLXjjf9zuLHkjfgmPA4QshuvvNsvKCmsCCvrPfkPSuKyXi1Yr8qjXtHwgrADssjtuvKAQaAYs10v5Ia0Rrfxw56eXgvfrBfvYMbW2jjFusk13rLQPHKW8uff3gONHKOrJQA8QIkNej1FjPUMKe3djPoess6CijXVbTvmqJaYs626M24tpasjTZ1mIVlkYMOQ5jGmxKwLQyKYAldZfPFk1)QEPv5HcvPksPI6gXir8Egn(pEcilyGUOyGgbKL0T1DnJyKiEpJriS1HCN9aeY4bHHPMwC7rKFs4TGM(ZOPtLg)tlAI7NraAjJJGXtD4icoZi1SUiMhKyKbzZOmSZvskj4mASKGZ4t2sghbJNMoEebNzKYAldZfPFk1v(mszbOesCbd0NXk8xKJmu1ah7mTrzyVKGZOpxKAGgbKL0T1DnJyKiEpJhKhV2EeHWwhYDwW4FArtC)mgEf3jy8uhH0K0i1SUiMhKyKbzZOmSZvskj4mASKGZi(kUtW4PPxbstsJuwBzyUi9tPUYNrklaLqIlyG(mwH)ICKHQg4yNPnkd7LeCg95cvAGgbKL0T1DnJ)PfnX9ZyNK8GSaacYuZJmw2NrQzDrmpiXidYMrzyNRKusWz0yjbNXNMK8GSaacY00R2KXY(mszTLH5I0pL6kFgPSaucjUGb6Zyf(lYrgQAGJDM2OmSxsWz0NluHbAeqws3w31mIrI49mMXtOAQhBGIf00PAnDfnDUPPFzBS7ryK3Xo1HtW49ySKUTUMo3007W7ryK3Xo1HtW49GmailWpPBZ4FArtC)msY3dsuhoIGZmsnRlI5bjgzq2mkd7CLKscoJglj4msjFpirthpIGZmszTLH5I0pL6kFgPSaucjUGb6Zyf(lYrgQAGJDM2OmSxsWz0NlvXancilPBR7Ag)tlAI7NXWT1uFK81i1SUiMhKyKbzZOmSZvskj4mASKGZiEBnnDGK81iL1wgMls)uQR8zKYcqjK4cgOpJv4VihzOQbo2zAJYWEjbNrFUu9gOrazjDBDxZ4FArtC)mMQbLq6JOgcG6ibY9GrQzDrmpiXidYMrzyNRKusWz0yjbNX)A6Ysi9r00HaOPxHa5EWiL1wgMls)uQR8zKYcqjK4cgOpJv4VihzOQbo2zAJYWEjbNrFUu3ancilPBR7Ag)tlAI7NX9CVnyqOAQps(AKAwxeZdsmYGSzug25kjLeCgnwsWzeWN7TbdcvtthijFnszTLH5I0pL6kFgPSaucjUGb6Zyf(lYrgQAGJDM2OmSxsWz0Nlvtd0iGSKUTURzeJeX7zKmailWpPBZ4FArtC)m2Y4i5nJuZ6IyEqIrgKnJYWoxjPKGZOXscoJvxghjVzKYAldZfPFk1v(mszbOesCbd0NXk8xKJmu1ah7mTrzyVKGZOpxOkgOrazjDBDxZigjI3Z4EwjI331Faaru1QcdQbqW4nYrYxnDUPP3H3JwghjV9GmailWpPBZ4FArtC)msl5I8h5NrQzDrmpiXidYMrzyNRKusWz0yjbNXAsUi)r(zKYAldZfPFk1v(mszbOesCbd0NXk8xKJmu1ah7mTrzyVKGZOpxu(mqJaYs626UMrmseVNX9SseVVR)aaIOQvfgudGGXBKJKVA6CttVdVhTmosE7bzaqwGFs3MX)0IM4(zmMevZi1SUiMhKyKbzZOmSZvskj4mASKGZyLKOAgPS2YWCr6NsDLpJuwakHexWa9zSc)f5idvnWXotBug2lj4m6Zfffd0iGSKUTURzeJeX7zmYpj8wqtNQ10PsnDUPPhHWwhYD2daAjJJGXtD4ico7bzGPGf00FcQwtNxSB8pTOjUFgbHmEqyyQPf3msnRlI5bjgzq2mkd7CLKscoJglj4mkdz8GWW00RjUzKYAldZfPFk1v(mszbOesCbd0NXk8xKJmu1ah7mTrzyVKGZOpxuKAGgbKL0T1DnJyKiEpJuvn9te5iy8m(Nw0e3pJXSDe4BWi1SUiMhKyKbzZOmSZvskj4mASKGZyLSDe4BWiL1wgMls)uQR8zKYcqjK4cgOpJv4VihzOQbo2zAJYWEjbNrFUOqLgOrazjDBDxZ4FArtC)mcqlzCemEQdhrWzgPM1fX8GeJmiBgLHDUssjbNrJLeCgFYwY4iy800XJi4mn9Nx5PmszTLH5I0pL6kFgPSaucjUGb6Zyf(lYrgQAGJDM2OmSxsWz0NlkuHbAeqws3w31mIrI49msgykybn9NrtxHk005MMEyNAAits4Xjgr6NAPVrn9Nqt)Z4FArtC)m2Y4i5nJuZ6IyEqIrgKnJYWoxjPKGZOXscoJvxghjVPP)8kpLrkRTmmxK(Pux5ZiLfGsiXfmqFgRWFroYqvdCSZ0gLH9scoJ(8zSKGZikaROPJsiQeQYw1st)LSAIBvd(zy(Sba]] )

    storeDefault( [[SimC Survival: mokMaintain]], 'actionLists', 20170717.202456, [[ditkcaGEsfTlczBirMTkDtf6BsODQI9k2nr7NeJIqXWGWVHAWKYWLKdQu1Piv4yK05iuAHsLwQu1IH0Yr8qKWtblts9CLmrcvnviAYemDQUOsLlJ66kyRsGnRu2UuXPv10qIAEKQ6WuESugTe57KkDssvEnsDnjQZlbDBf9xK06iu5OgKb2jn0lle0aIN3SHRNUbGkU9291P5pwMtD5Yb65lBloNAeQfrqP6YIufB5Akxma0iFLhiW(M)y5kiZrnidStAOxwiDdanYx5bqh22enX0sZlzxQU18VTer4P9YLIM(kAegDyBJQUVuaRBG9O)99cdqSkhtOUCYtZb0tk8nZXKasSKdmIfkWihBYbcCSjhO3QCmrrdCYtZb65lBloNAeQfvreONx4bsJxbz8auuIB0J4o8KLEqdmIfo2KdepN6GmWoPHEzH0na0iFLhaDyBt0etlnVKDP6wZ)2s0YTgTIM(kA1b2J(33lmaXQCmH6YjpnhqpPW3mhtciXsoWiwOaJCSjhiWXMCGERYXefnWjpnROjgvDeONVST4CQrOwufrGEEHhinEfKXdqrjUrpI7Wtw6bnWiw4ytoq84bo2Kda)KcfnyG057yxXPOnX0J2lD7LXta]] )

    storeDefault( [[SimC Survival: bitePhase]], 'actionLists', 20170717.202456, [[daePhaqiqjxcGkBIagLK0PKuwfrfVIOKSlcnmc6yazzuONjemnqHRbkABeLQVrQY4ikfNti06ikPMhrLUhOu7JuPdsu1cjkEOq0ejkrxKuvBeGYjbqZeGQUjOANKYqjkLwQKQNs1uLeBfa2l0FrXGv5WsTyqESGjJsxgzZu0NjYOb0Pj51a1Sv0Tvy3O63IgofSCjEoLMUsxxO2ob67KkoVqA9eLW8bi7xvJGWkORpVHMelcHUSKm745IYGUBGcQEQKf9QsoQzeMWe960KAlHAgfcspHYUrykckIW0im0dDpuugw0rx(WQsUfRGAGWkORpVHMelkd6EOOmSOx9py932tIVI60rzstMfiXmsW8Eb2trI3qtI9pabO)GInnfhjyEVa7jZ2HvfSIfA0kU9pD)R6Fsb2)KZFv)t28hG7Vi8xT)Q9xT)e4pOyttXrYLY0smMXLOI2TdG)t3)IWFc8xiZjBQdxCKCPmTedKAjXaWUir2)K7FG(tG)G1FqXMMIT1afwM0KzbsmulnjXydOlpKAQ2OOBgxIYKMmlqIHAPjHoa5SQqVzbDEYj0HNSaOlA9GqhDTEqOdyXLO)LM)TaP)0VLMe6YxKSOR4lvkXgwgLjSRU9K4ROoDuM0KzbsmJemVxG9uK4n0Kyfak20uCKG59cSNmBhwvWkwOrR4w5c7vfaZSQbvdqaQAiZjBQdxCKCPmTedKAjXaWUirwyhHAOxNMuBjuZOqq6bsi61jBgxcKfRGl6rcKcGHNcsdIVie6WtwTEqOJlQzeRGU(8gAsSOmO7HIYWIoS(JnxXzhOsVK4QcGvCP)e4plTmqjp2kUkQyuidmme(t3)e(Na)bfBAkosUuMwIXmUevKnU0Rk5)P7FHmNSPoCXrYLY0smqQLeda7Iez)to)jfyrxEi1uTrrF2bQ0lHoa5SQqVzbDEYj0HNSaOlA9GqhDTEqOd47av6LqVonP2sOMrHG0dKq0Rt2mUeilwbx0JeifadpfKgeFri0HNSA9Gqhxulcyf01N3qtIfLbDpuugw0da7Iez)txy)NX)e4VqMt2uhU4i5szAjgi1sIfA0kU9p5(NuG9p58Nr0LhsnvBu0hjxktlXaPwcDaYzvHEZc68KtOdpzbqx06bHo6A9GqhEYLY0s)jJAj0RttQTeQzuii9aje96KnJlbYIvWf9ibsbWWtbPbXxecD4jRwpi0Xf1GbwbD95n0Kyrzq3dfLHf9Q)v9pOyttXrYLY0smMXLOIfA0kU9pD)R6Fsb2)KZFv)lK5Kn1HlosUuMwIbsTKyayxKi7FYQ)m(xT)Q9xT)e4VqMt2uhU4i5szAjgi1sIbGDrIS)jxy)hO)Q9Na)v9py9NLwgOKhBfxfvafrgyyi8NU)j8pabO)Q(NLwgOKhBfxfvafrgyyi8NU)j8pb(dw)bfBAk2wduyzstMfiXqT0KeJn8xT)QHU8qQPAJIU5S5GvCjg7wuGj0biNvf6nlOZtoHo8KfaDrRhe6OR1dcDaB2CWkU0F(wuGj0RttQTeQzuii9aje96KnJlbYIvWf9ibsbWWtbPbXxecD4jRwpi0Xf1GjwbD95n0Kyrzq3dfLHf9oSkbjMrYLY0smMXLOOlpKAQ2OOpsUuMwIbsTe6aKZQc9Mf05jNqhEYcGUO1dcD016bHo8KlLPL(tg1s)vfun0RttQTeQzuii9aje96KnJlbYIvWf9ibsbWWtbPbXxecD4jRwpi0Xf1KDSc66ZBOjXIYGU8qQPAJIU5S5GvCjg7wuGj0biNvf6nlOZtoHo8KfaDrRhe6OR1dcDaB2CWkU0F(wuGP)QcQg61Pj1wc1mkeKEGeIEDYMXLazXk4IEKaPay4PG0G4lcHo8KvRhe64Il6A9Gq3vJi)ZJlcQeSNY6)GuljBb2wcxeb]] )


    storeDefault( [[Survival Primary]], 'displays', 20170625.195247, [[d8d5haWyKA9QsEjjP2fse2MQq9BOMjjvtJKOzRW5PIBQkYPr5BQcCmP0oP0Ef7MO9dj)esnmkmoKi5YQmusmyiA4iCqPQJIePoSKZrsWcLklfjSyQQLt4HsrpfSmkYZj1evfYur0KrftxPlQOUkjLEgsuDDv1gLcBfjI2mvz7q4Juu9Avr9zK03vKrssX6ijz0OQXRk1jrLUfjHUMQGUhsu62uP1IefhNIYPnKbOlILHLnWYfwNXfaTAjvNRDoaDrSmSSbwUa71fBRPaIss9AYF0pNUa(d2RxMpWtXpGdApp9TnlILHL6ync8gTNN(2MfXYWsDSgbiem3s4WLglb2RlwvAeWLj7NJ1uaZ(3)40SiwgwQtxah0EE6Bjlb1B1XAeGs)V)PdzSTHmWSS8hhN0fONEzyjkKQZ0BSQqaB5EbO4RlEvHcjH4OXU(1gGIBCL(I1Kr7dmAnmca0cgXgyzUhL1iBSMczGzz5pooPlqp9YWsuivNP3yPubSL7fGIVU4vfkKCoV6p2auCJR0xSMmAFGrRHr2Sb084jyIT089ZPlGMhp1)xC6cO5XtWeBP57)loDb2sq92EjnpweOdnjj6NOGR5QHmGtSQOPhBe4DSgb084jYsq9wD6c8SFVKMhlcqIwHcUMRgYa0yx)Avqmh)a0fXYWYEjnpweOdnjj6NcaehnRgSx1YWYyn9WhgqZJNaY0fWS)9VhXeh9YWYauW1C1qgq(D5sJL6yvzanXngngLMVjEGfHmqfBBarSTbOgBBa)yBZgqZJNAweldl1PlWB0EE6B7)IkwJa1xuKoexa)VNxa36D)FXXAeOge8v)yQC0kiMJTnqni4lGhpPGyo22a1GGVAID9RvbXCSTbE05v)XMUa1yQC0kiusxaemnZNnyRdPdXfWpaDrSmSSFWOkd0C2sotraomnXOCiDiUavarjPEKoexGYNnyRtG6lQNyYlDbm7ZOFMsY0W6mUavGN9BGLlWEDX2AkGTCVaWxGGHOgOqQiyULWjqni4lYsq9wfekX2gWbTNN(wUsom6AXcDSgbe3iqZzl5mfb0e3y0yuA(4hOge8fzjOERcI5yBdWKCy01If9sAESiafCnxnKbm7F)JdxjhgDTyHoDbCzY()IJ1iq9fvVKMhlc0HMKe9tQp3GmWwcQ32alxyDgxa0QLuDU25apvVzUFxuijzUxSuUragnwcefntsn2hgaOfmInqGAqWx9JPYrRGqj22a1xuCLEyshIlG)3ZlaHG5wcNgy5cSxxSTMcqioASRFT9kQhayUnrHe(ceme1qvOqsioASRFTb084P(VO4k9WXpGB9UFowJaK14KlkKMlWFIyncSLG6TkiMJFafbZTeoOq2SiwgwgqlQLHdO5XtQ(C8zsomjvD6cW58Q)y7vupaWCBIcj8fiyiQHQqHKZ5v)XgWbTNN(wv3PJvfBd8gTNN(wYsq9wDSgbE2VbwUW6mUaOvlP6CTZbCq75PVT)lQyncO5XtCLCy01If60fOge8fWJNuqOeBBGAmvoAfeZPlq9ffqCJb3hfRranpEsbXC6cqJD9RvbHs8d8SFdSCdOqIcjusnkK2siWtb084P(50fqZJNuqOKUaUmjqgRrGTeuVTbwUa71fBRPaVr75PVv1D6yncqxeldlBGLBafsuiHsQrH0wcbEkqni4RMyx)AvqOeBBGzz5pooPlGM5smUE0ZXAkG)G96L5d8u)ye)aEy5gy(nH406PYjWwcQ3QGqj(bm7F)RFWOkDp5gGoaf34k9fRjJ2hy84wtuctMAFSkvHakcMBjCqHSzrSmSefY(VOc8ewsfJ1hkKn(cNaM9V)XHlnwcSxxSQ0iGB9giJTnaJglPmySBSuUraZ(3)40alxG96IT1uGTeuVTbwUbuirHekPgfsBje4PaM9V)Xr1D60f4nApp9TCLCy01If6yncuFrPwjBdqmkNtKnba]] )

    storeDefault( [[Survival AOE]], 'displays', 20170625.195247, [[dee7haqiKuvBcjfDlIKAxiPWWKshtkwgQ0ZisyAKICnIuTnIK8nvqnoKuY5is06ifCpKuQdQGfQipKQQjQcYfvOnsv5JQaJKiLtseVKuOzsk5MQqTtk9tiAOKQJIKkwQkQNcMkIUkPO2ksQ0Arsv2RyWqYHLSyI6Xi1KrfxwvBMk(msmAu1Pr51QqMTuDBQYUj8BOgochNuQLtXZjz6kDDvA7q47kQXJKCEQ06vr2pK60eYa0fXYWcFyXcRB)dGuZKAjXogGUiwgw4dlwGD6JTHBatjO8(5F6JYua5o70Pd645ihWfPJJ6x)fXYWcvSTbOcPJJ6x)fXYWcvSTb0((3NJeASayN(y1uBafpEE4AkjchCKdO99Vph)fXYWcvMc4I0Xr9lzzO8Rk22auN7FFviJTjKbgfLC)5KPad0ldlqJslMAJvkdylVpW5RQ41aAueMNg7jxBGZF)l1hl32Md3202gaOnmInWY8EQDB2y5gYaJIsU)CYuGb6LHfOrPftTXsTcylVpW5RQ41aAuCEN623aN)(xQpwUTnhUTPTnB2akE8mmZwA(HXmfGkKooQFjldLFvX2gWROciJTnWwgk)oiO5XMatijjrE8zjhinYaUXk1CBKEahSydmsfH5vQ5YnGIhptwgk)QYuGJKhe08ytasK6NLCG0idqJ9KRvhXyKdqxeldlge08ytGjKKKipoaq80SQZovldlILR0LEafpEgiZuaTV)9peZ80ldlcCwYbsJmG46jHgluXQPakIV391lfVFChBczGk2MaMyBcqj2MaYX2KnGIhp7ViwgwOYuaQq64O(D4AQyBduxtr6s8bKVoob8kQgUlo22avNGVg6ZLRshXySnbQobFb84zDeJX2eO6e8LFSNCT6igJTjWHEN623mfO6ZLRshHEMcGGPyYSoBDjDj(aYbOlILHfdDgfra)JwYXZb4Wue9YL0L4dqhWuckpPlXhOKzD26gOUM6yM4ZuaTVm6JOUmfSU9pqf4izFyXcStFSnCdylVpaCniyiQoAudihdOByELXfnk)fXYWc0OgUMkWXybfmw9Or57ACd4Xed3fhl3aMVhW)OLC8CafX37(6LIpYbQobFrwgk)QJym2MaUiDCu)krWHrxl2OITnG23)(CKi4WORfBuzkGIhpdZSLMF4U4mfOUMAqqZJnbMqssI8yTg9rgyldLF9HflSU9pasntQLe7yGJlQyExp0OizEFSsrBagnwaefntqjwPhaOnmInGIjO0FQj1VUloq1j4RH(C5Q0rOhBtG6AkjchmPlXhq(64eGWW8kJRpSyb2Pp2gUbimpn2tU2bDTcamp)OrbxdcgIQRb0Oimpn2tU2akE88WDXroGxr1WySTbiR(lw0OoWGVeX2gyldLF1rmg5akE8SgFxzMGdtqrLPaN)(xQpwUTnhUvQA4sn4YTrQ0KugGZ7u3(oORvaG55hnk4AqWquDnGgfN3PU9nGlshh1VACsfRu3eyldLF9HfBaDs0OGsOqJYwgdEoWrY(WIfw3(haPMj1sIDmGlshh1VdxtfBBafpEwIGdJUwSrLPavNGVaE8Soc9yBcu95YvPJymtbQRPaIV3LCOyBdO4XZ6igZuaASNCT6i0JCGJK9HfBaDs0OGsOqJYwgdEoGIhppmg5akE8Soc9mfWJjaYy5gyldLF9HflWo9X2WnaviDCu)QXjvSnbOlILHf(WInGojAuqjuOrzlJbphO6e8LFSNCT6i0JTjWOOK7pNmfqX8i6)aYXy5gqUZoD6GoEEO3JCaTV)9h6mkcVxSbOdSLHYV6i0JCGQtWxKLHYV6i0JTjGUH5vgx0O8xeldlcOm1YWbimmVY4kHgla2Ppwn1gGj4WORfBge08ytGZsoqAKb8yIHXy5gGrJfupm2lwPOnG23)(C8HflWo9X2WnavX2gq77FFoACsLPauH0Xr9RebhgDTyJk22a11uAwW2ae9Y9nzta]] )


    ns.initializeClassModule = HunterInit

end
