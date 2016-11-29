-- Paladin.lua
-- October 2016

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
local addTalent = ns.addTalent
local addPerk = ns.addPerk
local addResource = ns.addResource
local addStance = ns.addStance

local registerCustomVariable = ns.registerCustomVariable

local removeResource = ns.removeResource

local setClass = ns.setClass
local setPotion = ns.setPotion
local setRole = ns.setRole

local RegisterEvent = ns.RegisterEvent
local storeDefault = ns.storeDefault


-- This table gets loaded only if there's a supported class/specialization.
if (select(2, UnitClass('player')) == 'PALADIN') then

    ns.initializeClassModule = function ()

        setClass( 'PALADIN' )

        -- addResource( SPELL_POWER_HEALTH )
        addResource( 'mana', true )
        addResource( 'holy_power' )

        addTalent( 'final_verdict', 198038 )
        addTalent( 'execution_sentence', 213757 )
        addTalent( 'consecration', 205228 )

        addTalent( 'the_fires_of_justice', 203316 )
        addTalent( 'zeal', 217020 )
        addTalent( 'greater_judgment', 218178 )

        addTalent( 'fist_of_justice', 198054 )
        addTalent( 'repentence', 20066 )
        addTalent( 'blinding_light', 115750 )

        addTalent( 'virtues_blade', 202271 )
        addTalent( 'blade_of_wrath', 202270 )
        addTalent( 'divine_hammer', 198034 )

        addTalent( 'justicars_vengeance', 215661 )
        addTalent( 'eye_for_an_eye', 205191 )
        addTalent( 'word_of_glory', 210191 )

        addTalent( 'divine_intervention', 213313 )
        addTalent( 'cavalier', 230332 )
        addTalent( 'seal_of_light', 202273 )

        addTalent( 'divine_purpose', 223817 )
        addTalent( 'crusade', 224668 )
        addTalent( 'holy_wrath', 210220 )


        -- Player Buffs.
        addAura( 'avenging_wrath', 31884 )
        addAura( 'blade_of_wrath', 202270 )
        addAura( 'crusade', 224668 )
        addAura( 'divine_purpose', 223819 )
        addAura( 'divine_hammer', 198137 )
        addAura( 'execution_sentence', 213757, 'duration', 7 )
        addAura( 'hammer_of_justice', 853, 'duration', 6 )
        addAura( 'shield_of_vengeance', 184662, 'duration', 15 )
        addAura( 'the_fires_of_justice', 209785 )
        addAura( 'whisper_of_the_nathrezim', 207633 )
        addAura( 'zeal', 217020, 'max_stack', 3 )


        -- Fake Buffs.

        local judgment = GetSpellInfo( 197277 )

        addAura( 'judgment', 197277, 'duration', 9, 'feign', function ()

            local name, _, _, count, _, duration, expires, caster, _, _, id, _, _, _, _, timeMod = UnitDebuff( 'target', judgment, nil, 'PLAYER' )

            if not name then
                if player.lastcast == 'judgment' and state.now - player.casttime <= state.gcd then
                    debuff.judgment.name = judgment
                    debuff.judgment.count = 1
                    debuff.judgment.expires = player.casttime + 9
                    debuff.judgment.applied = player.casttime
                    debuff.judgment.caster = 'player'
                else
                    debuff.judgment.name = judgment
                    debuff.judgment.count = 0
                    debuff.judgment.expires = 0
                    debuff.judgment.applied = 0
                    debuff.judgment.caster = 'none'
                end
                return

            end

            debuff.judgment.name = name
            debuff.judgment.count = 1
            debuff.judgment.expires = expires
            debuff.judgment.applied = expires - duration
            debuff.judgment.caster = caster
        end )


        --[[
        registerCustomVariable( 'last_feral_spirit', 0 )
        registerCustomVariable( 'last_crash_lightning', 0 )
        registerCustomVariable( 'last_rainfall', 0 )


        RegisterEvent( "UNIT_SPELLCAST_SUCCEEDED", function( _, unit, spell, _, spellID )

            if unit ~= 'player' then return end

            if spell == class.abilities[ 'feral_spirit' ].name then
                state.last_feral_spirit = GetTime()
            
            elseif spell == class.abilities[ 'crash_lightning' ].name then
                state.last_crash_lightning = GetTime()

            elseif spell == class.abilities[ 'rainfall' ].name then
                state.last_rainfall = GetTime()

            end

        end )

        addAura( 'feral_spirit', -10, 'name', 'Feral Spirit', 'duration', 15, 'feign', function ()
            local up = last_feral_spirit
            buff.feral_spirit.name = 'Feral Spirit'
            buff.feral_spirit.count = up and 1 or 0
            buff.feral_spirit.expires = up and last_feral_spirit + 15 or 0
            buff.feral_spirit.applied = up and last_feral_spirit or 0
            buff.feral_spirit.caster = 'player'
        end )

        addAura( 'alpha_wolf', -11, 'name', 'Alpha Wolf', 'duration', 8, 'feign', function ()
            local time_since_cl = now + offset - last_crash_lightning        
            local up = buff.feral_spirit.up and last_crash_lightning > buff.feral_spirit.applied
            buff.alpha_wolf.name = 'Alpha Wolf'
            buff.alpha_wolf.count = up and 1 or 0
            buff.alpha_wolf.expires = up and min( last_crash_lightning + 8, buff.alpha_wolf.expires ) or 0
            buff.alpha_wolf.applied = up and last_crash_lightning or 0
            buff.alpha_wolf.caster = 'player'
        end ) ]]


        -- Special handler for Liadrin's Fury Unleashed legendary ring.
        -- This will cause the addon to predict HoPo gains during Crusader/AW uptime if you have the ring.
        addHook( 'advance', function( t )
            if not state.equipped.liadrins_fury_unleashed then return t end

            local buff_remaining = 0

            if state.buff.crusade.up then buff_remaining = state.buff.crusade.remains
            elseif state.buff.avenging_wrath.up then buff_remaining = state.buff.avenging_wrath.remains end

            if buff_remaining < 2.5 then return t end

            local ticks_before = math.floor( buff_remaining / 2.5 )
            local ticks_after = math.floor( max( 0, ( buff_remaining - t ) / 2.5 ) )

            state.gain( ticks_before - ticks_after, 'holy_power' )

            return t
        end )

        --[[ LegionFix:  Set up HoPo for prediction over time (for Liadrin's Fury Unleashed).
        ns.addResourceMetaFunction( 'current', function( t )
            if t.resource ~= 'holy_power' then return 'nofunc' end
        end ) ]]


        ns.addMetaFunction( 'state', 'divine_storm_targets', function()
            if settings.ds_targets == 'a' then
                return spec.retribution and ( ( artifact.divine_tempest.enabled or artifact.righteous_blade.rank >= 2 ) and 2 or 3 ) or 0
            end
            return state.settings.ds_targets == 'c' and 3 or 2
        end )

        ns.addMetaFunction( 'state', 'judgment_override', function()
            return spec.retribution and not settings.strict_finishers and cooldown.judgment.remains > gcd * 2 and holy_power.current >= 5
        end )


        -- Gear Sets
        addGearSet( 'tier19', 138350, 138353, 138356, 138359, 138362, 138369 )
        addGearSet( 'class', 139690, 139691, 139692, 139693, 139694, 139695, 139696, 139697 )
        addGearSet( 'ashbringer', 120978 )
        addGearSet( 'whisper_of_the_nathrezim', 137020 )


        addHook( 'specializationChanged', function ()
            setPotion( 'old_war' )
            setRole( 'attack' )
        end )


        -- Class/Spec Settings
        ns.addToggle( 'wake_of_ashes', true, 'Wake of Ashes', 'Set a keybinding to toggle Wake of Ashes on/off in your priority lists.' )

        ns.addSetting( 'wake_of_ashes_cooldown', true, {
            name = "Wake of Ashes: Cooldown Override",
            type = "toggle",
            desc = "If |cFF00FF00true|r, when your Cooldown toggle is |cFF00FF00ON|r then the toggle for Wake of Ashes will be overriden and Wake of Ashes will be shown.",
            width = "full"
        } )

        ns.addSetting( 'strict_finishers', false, {
            name = "Strict Finishers",
            type = "toggle",
            desc = "If |cFF00FF00true|r, the addon will not recommend Holy Power spenders unless the Judgment debuff is on your target.\r\n\r\n" ..
                "This may have adverse effects in situations where you are target swapping.\r\n\r\n" ..
                "You may incorporate this into your custom action lists with the |cFFFFD100settings.strict_finishers|r flag.  It is also " ..
                "bundled into the |cFFFFD100judgment_override|r flag, which is |cFF00FF00true|r when all of the following is true:  Strict " ..
                " Finishers is disabled, Judgment remains on cooldown for 2 GCDs, and your Holy Power is greater than or equal to 5.",
            width = "full"
        } )

        ns.addSetting( 'ds_targets', 'a', {
            name = "Divine Storm Targets",
            type = "select",
            desc = "If set to |cFF00FF00auto|r, the addon will recommend Divine Storm (vs. Templar's Verdict) based on your artifact traits.\r\n\r\n" ..
                "If set to 2 or 3, the artifact will recommend Divine Storm with the specified number of targets.  If using a manual setting, using " ..
                "Divine Storm on 2 targets is recommended if you have the Righteous Blade and Divine Tempest artifact traits.",
            values = {
                a = 'Automatic',
                b = '2',
                c = '3'
            }
        } )

        ns.addSetting( 'shield_damage', 20, {
            name = "Shield of Vengeance: Damage Threshold",
            type = "range",
            desc = "The Shield of Vengeance ability is only recommended if/when you are taking damage.  Specify how much damage, as a percentage " ..
                "of your maximum health, that you must take in the preceding 3 seconds before Shield of Vengeance can be recommended.\r\n\r\n" ..
                "If set to 100, Shield of Vengeance will never be recommended.\r\n" ..
                "If set to 0, Shield of Vengeance will always be available.\r\n",
            width = "full",
            min = 0,
            max = 100,
            step = 1
        } )


        addAbility( 'avenging_wrath', {
            id = 31884,
            spend = 0,
            spend_type = 'mana',
            cast = 0,
            gcdType = 'off',
            cooldown = 120,
            charges = 1,
            recharge = 120,
            known = function () return not talent.crusade.enabled end,
            usable = function () return not talent.crusade.enabled and not buff.avenging_wrath.up end,
            toggle = 'cooldowns'
        } )

        addHandler( 'avenging_wrath', function ()
            applyBuff( 'avenging_wrath', 20 + ( artifact.wrath_of_the_ashbringer.rank * 2.5 ) )
        end )


        addAbility( 'blade_of_justice', {
            id = 184575,
            spend = -2,
            spend_type = 'holy_power',
            cast = 0,
            gcdType = 'melee',
            cooldown = 10.5,
            known = function() return not talent.divine_hammer.enabled end
        } )

        modifyAbility( 'blade_of_justice', 'cooldown', function( x )
            return x * haste
        end )


        --[[ removed in 7.1
        
        addAbility( 'blade_of_wrath', {
            id = 202270,
            spend = -2,
            spend_type = 'holy_power',
            cast = 0,
            gcdType = 'melee',
            cooldown = 10.5,
            known = function () return talent.blade_of_wrath.enabled end,
        } )

        modifyAbility( 'blade_of_wrath', 'cooldown', function( x )
            return x * haste
        end )

        addHandler( 'blade_of_wrath', function ()
            applyDebuff( 'target', 'blade_of_wrath', 6 * haste )
        end ) ]]


        addAbility( 'consecration', {
            id = 205228,
            spend = 0,
            spend_type = 'mana',
            cast = 0,
            gcdType = 'spell',
            cooldown = 12,
            known = function () return talent.consecration.enabled end,
        } )

        modifyAbility( 'consecration', 'cooldown', function( x )
            return x * haste
        end )


        addAbility( 'crusade', {
            id = 224668,
            spend = 0,
            spend_type = 'mana',
            cast = 0,
            gcdType = 'off',
            cooldown = 120,
            charges = 1,
            recharge = 120,
            known = function () return talent.crusade.enabled end,
            usable = function () return not buff.crusade.up end,
            toggle = 'cooldowns'
        } )

        addHandler( 'crusade', function ()
            applyBuff( 'crusade', 20 + ( artifact.wrath_of_the_ashbringer.rank * 2.5 ) )
        end )


        addAbility( 'crusader_strike', {
            id = 35395,
            spend = -1,
            spend_type = 'holy_power',
            cast = 0,
            gcdType = 'melee',
            cooldown = 4.5,
            charges = 2,
            recharge = 4.5,
            known = function () return not talent.zeal.enabled end
        } )

        modifyAbility( 'crusader_strike', 'cooldown', function( x )
            if talent.the_fires_of_justice.enabled then x = x - 1 end
            return x * haste
        end )

        modifyAbility( 'crusader_strike', 'recharge', function( x )
            if talent.the_fires_of_justice.enabled then x = x - 1 end
            return x * haste
        end )


        addAbility( 'divine_storm', {
            id = 53385,
            spend = 3,
            spend_type = 'holy_power',
            cast = 0,
            gcdType = 'melee',
            cooldown = 0,
        } )

        modifyAbility( 'divine_storm', 'spend', function( x )
            if buff.divine_purpose.up then return 0
			elseif buff.the_fires_of_justice.up then return x - 1 end
            return x
        end )

        addHandler( 'divine_storm', function ()
            if buff.divine_purpose.up then removeBuff( 'divine_purpose' )
            elseif buff.the_fires_of_justice.up then removeBuff( 'the_fires_of_justice' ) end
            if equipped.whisper_of_the_nathrezim then applyBuff( 'whisper_of_the_nathrezim', 4 ) end
            if talent.fist_of_justice.enabled then
                setCooldown( 'hammer_of_justice', cooldown.hammer_of_justice.remains - 8 )
            end
        end )


        addAbility( 'divine_hammer', {
            id = 198034,
            spend = -2,
            spend_type = 'holy_power',
            cast = 0,
            gcdType = 'spell',
            cooldown = 12,
            known = function () return talent.divine_hammer.enabled end
        } )

        addHandler( 'divine_hammer', function ()
            applyBuff( 'divine_hammer', 12 )
        end )


        addAbility( 'execution_sentence', {
            id = 213757,
            spend = 3,
            spend_type = 'holy_power',
            cast = 0,
            gcdType = 'spell',
            cooldown = 20,
            known = function () return talent.execution_sentence.enabled end
        } )

		modifyAbility( 'execution_sentence', 'spend', function( x )
			if buff.the_fires_of_justice.up then return x -1 end
			return x
		end )

        addHandler( 'execution_sentence', function ()
            applyDebuff( 'target', 'execution_sentence', 7 ) 
        end )


        addAbility( 'hammer_of_justice', {
            id = 853,
            spend = 0.035,
            spend_type = 'mana',
            cast = 0,
            gcdType = 'spell',
            cooldown = 60
        } )

        modifyAbility( 'hammer_of_justice', 'cooldown', function( x )
            if equipped.justice_gaze and target.health.percent > 75 then
                return x * 0.75
            end
            return x
        end )

        addHandler( 'hammer_of_justice', function ()
            applyDebuff( 'target', 'hammer_of_justice', 6 )
        end )


        addAbility( 'holy_wrath', {
            id = 210220,
            spend = 0,
            spend_type = 'mana',
            cast = 0,
            gcdType = 'spell',
            cooldown = 180,
            known = function() return talent.holy_wrath.enabled end,
            toggle = 'cooldowns'
        } )


        addAbility( 'judgment', {
            id = 20271,
            spend = 0,
            spend_type = 'mana',
            cast = 0,
            gcdType = 'spell',
            cooldown = 12
        } )

        modifyAbility( 'judgment', 'cooldown', function( x )
            return x * haste
        end )

        addHandler( 'judgment', function ()
            applyDebuff( 'target', 'judgment', 8 )
        end )


        addAbility( 'justicars_vengeance', {
            id = 215661,
            spend = 5,
            spend_type = 'holy_power',
            cast = 0,
            gcdType = 'spell',
            cooldown = 0,
            known = function () return talent.justicars_vengeance.enabled end
        } )

        modifyAbility( 'justicars_vengeance', 'spend', function( x )
            if buff.divine_purpose.up then return 0
			elseif buff.the_fires_of_justice.up then return x - 1 end
            return x
        end )

        addHandler( 'justicars_vengeance', function ()
            if buff.divine_purpose.up then removeBuff( 'divine_purpose' )
            elseif buff.the_fires_of_justice.up then removeBuff( 'the_fires_of_justice' ) end
        end )


        addAbility( 'rebuke', {
            id = 96231,
            spend = 0,
            spend_type = 'mana',
            cast = 0,
            gcdType = 'off',
            cooldown = 15,
            usable = function () return target.casting end,
            toggle = 'interrupts'
        } )

        addHandler( 'rebuke', function ()
            interrupt()
        end )


        addAbility( 'shield_of_vengeance', {
            id = 184662,
            spend = 0,
            spend_type = 'mana',
            cast = 0,
            gcdType = 'spell',
            cooldown = 120,
            usable = function () return settings.shield_damage == 0 or incoming_damage_3s > ( health.max * settings.shield_damage / 100 ) end,
        } )

        addHandler( 'shield_of_vengeance', function ()
            applyBuff( 'shield_of_vengeance', 15 )
        end )


        addAbility( 'templars_verdict', {
            id = 85256,
            spend = 3,
            spend_type = 'holy_power',
            cast = 0,
            gcdType = 'spell',
            cooldown = 0,
        } )

        modifyAbility( 'templars_verdict', 'spend', function( x )
            if buff.divine_purpose.up then return 0
            elseif buff.the_fires_of_justice.up then return x - 1 end
            return x
        end )

        addHandler( 'templars_verdict', function ()
            if buff.divine_purpose.up then removeBuff( 'divine_purpose' )
            elseif buff.the_fires_of_justice.up then removeBuff( 'the_fires_of_justice' ) end
            if equipped.whisper_of_the_nathrezim then applyBuff( 'whisper_of_the_nathrezim', 4 ) end
        end )


        addAbility( 'wake_of_ashes', {
            id = 205273,
            spend = 0,
            spend_type = 'holy_power',
            cast = 0,
            gcdType = 'spell',
            cooldown = 30,
            known = function () return equipped.ashbringer and ( toggle.wake_of_ashes or ( toggle.cooldowns and settings.wake_of_ashes_cooldown ) ) end
        } )

        modifyAbility( 'wake_of_ashes', 'spend', function( x ) 
            if artifact.ashes_to_ashes.enabled then return -5 end
            return x
        end )


        addAbility( 'zeal', {
            id = 217020,
            spend = -1,
            spend_type = 'holy_power',
            cast = 0,
            gcdType = 'melee',
            cooldown = 4.5,
            charges = 2,
            recharge = 4.5,
            known = function () return talent.zeal.enabled end
        } )

        modifyAbility( 'zeal', 'cooldown', function( x )
            return x * haste
        end )

        modifyAbility( 'zeal', 'recharge', function( x )
            return x * haste
        end )

        addHandler( 'zeal', function ()
            addStack( 'zeal', 12, 1 )
        end )

    end


    storeDefault( 'SimC Import: default', 'actionLists', 20161106.1, [[dqehKaqirr2eLYNqvHrruDkIYQOuPDrLHHuDmISmb6zeQPPuX1OuX2uQ6BqvghLQkNJsvvRdvfvMNOW9Gk2hQOdcv1crfEiQkLjIQsUiHyJOQOQrIQsLtsiTsuvKDksdfvfLwkQQEQKPcvARII6RuQkTwuvQAVK(lugSO0Hv1IPKhtXKr5YGnlOplIrJuonKvlQ61kvA2u1TrYUL63igobhNsvXYv8CHMUkxxjBhv57OsJhvffNxaRNsvMVsz)IkRskUAjs)wEGPCOv6tbAvik(wUSIsjqMJpxUSmi8x(tl(cc)L)uo0IFWdFe00G0L2ljrxYjPvzgKWPLw4BoePJkUAQKIRwI0VLhykhAvMbjCADKKep4q9bZSeUOw4BH8OlGwdyT2f0s0MHm)rgTAsdAL(uGw8dwRDbT4h8WhbnniDP9s45OlwspnnOIRwI0VLhykhAvMbjCADKKep4meINr42rBYLBTcdDwEcH5xXZTe22SwHHUNh0jOobJ78hn3syBZAfg6mZk(mWTe22UFsGZDika7iymeKbo7qxMmTWFsIA1pfGdXZW4(Jw4BH8OlGwcKdrATeTziZFKrRM0GwPpfOfFwYHiTw8dE4JGMgKU0Ej8C0flPNMkwXvlr63YdmLdTkZGeoTossIhCgcXZiC7Ow4BH8OlGw0i(ayCN)OPLOndz(JmA1Kg0k9PaT47i(a5YAFN)OPf)Gh(iOPbPlTxcphDXs6PP7O4QLi9B5bMYHwLzqcNwhjjXdodH4zeUDul8TqE0fqRNh0jOobJ78hnTeTziZFKrRM0GwPpfOf(8Gob1j5YAFN)OPf)Gh(iOPbPlTxcphDXs6PP2rXvlr63YdmLdTsFkqRIgc8SCzjH5YMzOtGVnGw4BH8OlGwrAiWZWiHy8Gob(2aAjAZqM)iJwnPbT4h8WhbnniDP9s45OlwspnDVIRwI0VLhykhAvMbjCADKKep4meINr42rBYPr8bWeiCHXzwZa9Xjo2rMw4BH8OlGwMzfFgOLOndz(JmA1Kg0k9PaT4BZk(mql(bp8rqtdsxAVeEo6IL0ttXtXvlr63YdmLdTkZGeoTKtJ4dGjq4cJZSMb6dh6BBz6Ndf(MZ9rAqe7iyFKgeDq)wEGjZ2HOGmcQf(wip6cOf3FxaJeI9rAqulrBgY8hz0QjnOv6tbAzF)DHCzjH5YIFKge1IFWdFe00G0L2lHNJUyj90u7NIRwI0VLhykhAvMbjCA9MdXdWGgOqqKtCeBtUHq8mc32LFXsOG(Cdq9OoMrIHz3DC2zBJbwRWqx(flHc6Zna1J6iNjgMD3XThpz2KNP79qFoZSIpdCq)wEGTTziepJWTDMzfFg4gG6rDKZedZUbLPf(wip6cOfWNbmRdrASi0h0gqlrBgY8hz0QjnOv6tbAjcFgWSoePZLTG(G2aAXp4HpcAAq6s7LWZrxSKEAQ9xXvlr63YdmLdTkZGeoTossIhCgcXZiC7Ow4BH8OlGwwEcHHfUMaAjAZqM)iJwnPbTsFkqlo8eclxw(8RjGw8dE4JGMgKU0Ej8C0flPNMkrxXvlr63YdmLdTkZGeoTossIhCgcXZiC7Ow4BH8OlGwwWeHzxuNOLOndz(JmA1Kg0k9PaT4aMim7I6eT4h8WhbnniDP9s45OlwspnvssXvlr63YdmLdTkZGeoTossIhCgcXZiC7On50i(ayceUW4mRzG(YWoY0cFlKhDb06hZ3a2rMb6tlrBgY8hz0QjnOv6tbAH)y(gYLfxYmqFAXp4HpcAAq6s7LWZrxSKEAQuqfxTePFlpWuo0Qmds40sodSwHHU8lwcf0NBjSTLFXsOG(Wi8GzqmqMT3CiEag0afcICIddXd1aw8idf29tcCrBwRWqhdXd1aMWAeirWTeSzTcdDmepudycRrGeb3aupQJzKyy2nOw4BH8OlGwmepudyXJmuAjAZqM)iJwnPbTsFkql(cXd1qUS1rgkT4h8WhbnniDP9s45OlwspnvsSIRwI0VLhykhAvMbjCAjNbwRWqx(flHc6ZTe22YVyjuqFyeEWmigiZ2BoepadAGcbroXHH4HAalEKHc7(jbUOnAeFambcxyCM1mqFCIJDSzTcdDmepudycRrGeb3sql8TqE0fqlgIhQbS4rgkTeTziZFKrRM0GwPpfOfFH4HAix26idvUSYLKPf)Gh(iOPbPlTxcphDXs6PPs7O4QLi9B5bMYHwLzqcNwYzG1km0LFXsOG(ClHTT8lwcf0hgHhmdIbYS9MdXdWGgOqqKtCyiEOgWIhzOWUFsGlAJgXhatGWfgNznd0hN4yhBYZ09EOpNzwXNboOFlpW22meINr42oZSIpdCdq9OoYzIHzxXY0cFlKhDb0IH4HAalEKHslrBgY8hz0QjnOv6tbAXxiEOgYLToYqLlR8GY0IFWdFe00G0L2lHNJUyj90uj7O4QLi9B5bMYHwLzqcNwYzG1km0LFXsOG(ClHTT8lwcf0hgHhmdIbYSzTcdDmepudycRrGeb3sWM1km0Xq8qnGjSgbseCdq9OoMrIHz3G2YeyFwibbG54sdffGbJeID0aS(pAdypeLw4BH8OlGw5xXdz(jIXd6e4BdOLOndz(JmA1Kg0k9PaT4tR4Hm)WhXCzZm0jW3gql(bp8rqtdsxAVeEo6IL0ttL2R4QLi9B5bMYHwLzqcNwYzG1km0LFXsOG(ClHTT8lwcf0hgHhmdIbYSrJ4dGjq4cJZSMb6JtCSJnRvyOJH4HAatyncKi4wc2YeyFwibbG54sdffGbJeID0aS(pAdypeLw4BH8OlGw5xXdz(jIXd6e4BdOLOndz(JmA1Kg0k9PaT4tR4Hm)WhXCzZm0jW3gixw5sY0IFWdFe00G0L2lHNJUyj90uj8uC1sK(T8at5qRYmiHtl5mWAfg6YVyjuqFULW2w(flHc6dJWdMbXaz2SwHHogIhQbmH1iqIGBjyZAfg6yiEOgWewJajcUbOEuhZiXWSBqTW3c5rxaToGsW)teJhmmK50s0MHm)rgTAsdAL(uGw4cuc(F4JyUSzgggYCAXp4HpcAAq6s7LWZrxSKEAQK9tXvlr63YdmLdTkZGeoTKZaRvyOl)ILqb95wcBB5xSekOpmcpygedKzJgXhatGWfgNznd0hN4yhBwRWqhdXd1aMWAeirWTe0cFlKhDb06akb)prmEWWqMtlrBgY8hz0QjnOv6tbAHlqj4)HpI5YMzyyiZLlRCjzAXp4HpcAAq6s7LWZrxSKEAQK9xXvlr63YdmLdTkZGeoTKZaRvyOl)ILqb95wcBB5xSekOpmcpygedKzJgXhatGWfgNznd0hN4yhBYZ09EOpNzwXNboOFlpW22meINr42oZSIpdCdq9OoYzIHzxXY0cFlKhDb06akb)prmEWWqMtlrBgY8hz0QjnOv6tbAHlqj4)HpI5YMzyyiZLlR8GY0IFWdFe00G0L2lHNJUyj900G0vC1sK(T8at5qRYmiHtl5mWAfg6YVyjuqFULW2w(flHc6dJWdMbXaz2Or8bWeiCHXzwZa9XjoIT9MdXdWGgOqqKtCyiEOgWIhzOWUFsGlAtUHq8mc32X93fWiHyFKgeDdq9OoMrIHz3G2(5qHV5CC)Dbmsi2hPbrh0VLhyBBwRWqhxAOOamyKqSJgG1)rBa7HOClbBwRWqhxAOOamyKqSJgG1)rBa7HOCdq9OoMrIHjZM8mDVh6ZzMv8zGd63YdSTndH4zeUTZmR4Za3aupQJCMyy2DhzAHVfYJUaAXq8qnGfpYqPLOndz(JmA1Kg0k9PaT4lepud5YwhzOYLvUyzAXp4HpcAAq6s7LWZrxSKEAAqjfxTePFlpWuo0Qmds40sodSwHHU8lwcf0NBjSTLFXsOG(Wi8GzqmqMnAeFambcxyCM1mqFCIJyBwRWqhdXd1aMWAeirWTeSziepJWTDC)Dbmsi2hPbr3aupQJzKyy2nOTFou4Boh3FxaJeI9rAq0b9B5bMTmb2NfsqayoU0qrbyWiHyhnaR)J2a2drPf(wip6cOv(v8qMFIy8Gob(2aAjAZqM)iJwnPbTsFkql(0kEiZp8rmx2mdDc8TbYLvEqzAXp4HpcAAq6s7LWZrxSKEAAWGkUAjs)wEGPCOvzgKWPLCgyTcdD5xSekOp3syBl)ILqb9Hr4bZGyGmB0i(ayceUW4mRzG(4ehX2KBiepJWTDC)Dbmsi2hPbr3aupQJzKyy2nOTFou4Boh3FxaJeI9rAq0b9B5b22M1km0XLgkkadgje7Oby9F0gWEik3sWM1km0XLgkkadgje7Oby9F0gWEik3aupQJzKyyYSjpt37H(CMzfFg4G(T8aBBZqiEgHB7mZk(mWna1J6iNjgMD3rMw4BH8OlGwhqj4)jIXdggYCAjAZqM)iJwnPbTsFkqlCbkb)p8rmx2mdddzUCzLlwMw8dE4JGMgKU0Ej8C0flPNMguSIRwI0VLhykhAvMbjCArJ4dGjq4cJZSMb6dh6BB0i(ayceUW4mRzG(WrYMCdH4zeUTZY)maJeILFfpKbCdq9OoYzIHTTziepJWTDmepudy0EkkyCdq9OoYzIHjBBJgXhatGWfgNznd0hobTj3qiEgHB7Sh8ENH2pjqelCEZHi97Zah6U92zBZqiEgHB7mZk(myWI3G2fCgA)KarSW5nhI0VpdCO72BhzAHVfYJUaAX93fWiHyFKge1s0MHm)rgTAsdAL(uGw23FxixwsyUS4hPbXCzLljtl(bp8rqtdsxAVeEo6IL0ttdUJIRwI0VLhykhAvMbjCAzO9tceXjOnAeFambcxyCM1mqFzGZoAHVfYJUaAzp49AjAZqM)iJwnPbTsFkql(E49AXp4HpcAAq6s7LWZrxSKEAAq7O4QLi9B5bMYHwLzqcNwgA)KarCcAJgXhatGWfgNznd0xg4SJw4BH8OlGwMzfFgmyXBq7cAjAZqM)iJwnPbTsFkql(2SIpdMCzRBq7cAXp4HpcAAq6s7LWZrxSKEAAW9kUAjs)wEGPCOvzgKWPfnIpaMaHlmoZAgOVmWj42MCAeFambcxyCM1mqFzGJyBYneINr42o7bV3zO9tceXcN3Cis)(mWrYjENTndH4zeUTZmR4ZGblEdAxWzO9tceXcN3Cis)(mWrYjEhzY0cFlKhDb0YY)maJeILFfpKb0s0MHm)rgTAsdAL(uGwC4FgKlljmxw(0kEidOf)Gh(iOPbPlTxcphDXs6PPbXtXvlr63YdmLdTkZGeoTOr8bWeiCHXzwZa9Lbob32KtJ4dGjq4cJZSMb6ldCeBtUHq8mc32zp49odTFsGiw48Mdr63NbosoX7STziepJWTDMzfFgmyXBq7codTFsGiw48Mdr63NbosoX7itMw4BH8OlGwmepudy0Ekky0s0MHm)rgTAsdAL(uGw8fIhQHCz57Ekky0IFWdFe00G0L2lHNJUyj900G2pfxTePFlpWuo0Qmds40IgXhatGWfgNznd0hN4iEBtUCdH4zeUTZEW7DgA)KarSW5nhI0VpdCKC7XBBZqiEgHB7mZk(myWI3G2fCgA)KarSW5nhI0VpdCKC7XtMn5gcXZiCBhdXd1agTNIcg3aupQJCMyyBBgcXZiCBNL)zagjel)kEid4gG6rDKZedtMSTn537H(Cjd8hmy5xSekOph0VLhy2UFsGZrdE)rZjyooTdDzAHVfYJUaALFXsOG(0s0MHm)rgTAsdAL(uGw8PflHc6tl(bp8rqtdsxAVeEo6IL0ttdA)vC1sK(T8at5qR0Nc0IVr6iyM)qKwl8TqE0fqldPJGz(drATeTziZFKrRM0Gw8dE4JGMgKU0Ej8C0flPNMkMUIRwI0VLhykhAvMbjCAjNbwRWqx(flHc6ZTe22YVyjuqFyeEWmigiZ2BoepadAGcbroXHH4HAalEKHc7(jbUOnRvyOJH4HAatyncKi4wcAHVfYJUaAXq8qnGfpYqPLOndz(JmA1Kg0k9PaT4lepud5YwhzOYLv(oY0IFWdFe00G0L2lHNJUyj90uXskUAjs)wEGPCOvzgKWPLCgyTcdD5xSekOp3syBl)ILqb9Hr4bZGyGmBV5q8amObkee5ehgIhQbS4rgkS7Ne4I2SwHHUJgGfIgiIrcXYVIhYaULGn5z6Ep0NZmR4Zah0VLhyBBgcXZiCBNzwXNbUbOEuh5mXWSRyzAHVfYJUaAXq8qnGfpYqPLOndz(JmA1Kg0k9PaT4lepud5YwhzOYLvUDKPf)Gh(iOPbPlTxcphDXs6PPIdQ4QLi9B5bMYHwLzqcNwYzG1km0LFXsOG(ClHTT8lwcf0hgHhmdIbYS9MdXdWGgOqqKtCyiEOgWIhzOWUFsGlAtonIpaMaHlmoZAgOpoXzNTn5YneINr42o7bV3zO9tceXcN3Cis)(mWrYjENTndH4zeUTZmR4ZGblEdAxWzO9tceXcN3Cis)(mWrYjEhz2KBiepJWTDmepudy0EkkyCdq9OoYzIHTTziepJWTDw(NbyKqS8R4HmGBaQh1rotmmzYKztEMU3d95mZk(mWb9B5b22MHq8mc32zMv8zGBaQh1rotmm7UJmTW3c5rxaTyiEOgWIhzO0s0MHm)rgTAsdAL(uGw8fIhQHCzRJmu5YkFVmT4h8WhbnniDP9s45OlwspnvSyfxTePFlpWuo0Qmds40sodSwHHU8lwcf0NBjSTLFXsOG(Wi8GzqmqMnRvyOJH4HAatyncKi4wc2YeyFwibbG54sdffGbJeID0aS(pAdypeLw4BH8OlGw5xXdz(jIXd6e4BdOLOndz(JmA1Kg0k9PaT4tR4Hm)WhXCzZm0jW3gixw5ILPf)Gh(iOPbPlTxcphDXs6PPI3rXvlr63YdmLdTkZGeoTKZaRvyOl)ILqb95wcBB5xSekOpmcpygedKzZAfg6yiEOgWewJajcULGw4BH8OlGwhqj4)jIXdggYCAjAZqM)iJwnPbTsFkqlCbkb)p8rmx2mdddzUCzLVJmT4h8WhbnniDP9s45OlwspnvSDuC1sK(T8at5qRYmiHtl5mWAfg6YVyjuqFULW2w(flHc6dJWdMbXaz2SwHHUJgGfIgiIrcXYVIhYaULGn5z6Ep0NZmR4Zah0VLhyBBgcXZiCBNzwXNbUbOEuh5mXWSRyzAHVfYJUaADaLG)NigpyyiZPLOndz(JmA1Kg0k9PaTWfOe8)WhXCzZmmmK5YLvUDKPf)Gh(iOPbPlTxcphDXs6PPI3R4QLi9B5bMYHwLzqcNwYzG1km0LFXsOG(ClHTT8lwcf0hgHhmdIbYSjNgXhatGWfgNznd0hN4SZ2MC5gcXZiCBN9G37m0(jbIyHZBoePFFg4i5eVZ2MHq8mc32zMv8zWGfVbTl4m0(jbIyHZBoePFFg4i5eVJmBYneINr42ogIhQbmApffmUbOEuh5mXW22meINr42ol)Zamsiw(v8qgWna1J6iNjgMmzYSjpt37H(CMzfFg4G(T8aBBZqiEgHB7mZk(mWna1J6iNjgMD3rMw4BH8OlGwhqj4)jIXdggYCAjAZqM)iJwnPbTsFkqlCbkb)p8rmx2mdddzUCzLVxMw8dE4JGMgKU0Ej8C0flPNMkgpfxTePFlpWuo0Qmds40IgXhatGWfgNznd0xg4SJw4BH8OlGw2dEVwI2mK5pYOvtAqR0Nc0IVhEFUSYLKPf)Gh(iOPbPlTxcphDXs6PPITFkUAjs)wEGPCOvzgKWPfnIpaMaHlmoZAgOVmWzhTW3c5rxaTmZk(myWI3G2f0s0MHm)rgTAsdAL(uGw8TzfFgm5Yw3G2fYLvUKmT4h8WhbnniDP9s45OlwspnvS9xXvlr63YdmLdTkZGeoTKZaRvyOl)ILqb95wcBB5xSekOpmcpygedKzJgXhatGWfgNznd0hN4i22BoepadAGcbroXHH4HAalEKHc7(jbUOn5z6Ep0NZmR4Zah0VLhyBBgcXZiCBNzwXNbUbOEuh5mXWSRDKPf(wip6cOfdXd1aw8idLwI2mK5pYOvtAqR0Nc0IVq8qnKlBDKHkxw54jtl(bp8rqtdsxAVeEo6IL0tt3HUIRwI0VLhykhAvMbjCAjNbwRWqx(flHc6ZTe22YVyjuqFyeEWmigiZgnIpaMaHlmoZAgOpoXrSn5z6Ep0NZmR4Zah0VLhyBBgcXZiCBNzwXNbUbOEuh5mXWSRDKPf(wip6cO1buc(FIy8GHHmNwI2mK5pYOvtAqR0Nc0cxGsW)dFeZLnZWWqMlxw54jtl(bp8rqtdsxAVeEo6IL0tpTkbWGEpYE)HiTMIhD9uf]] )

    storeDefault( 'SimC Import: precombat', 'actionLists', 20161106.1, [[b4vmErLxtvKBHjgBLrMxc51uofwBL51utLwBd5hyj1gCVjhD64hyWjxzJ9wBIfgDEnfrLzwy1XgDEjKxtjvzSvwyZvMxojdmXytmXatmUeJxtn1yYLgC051uEnvqJrxAV52CErLxofJxu51uf5wyIXwzK5LqEn1uJjxAWrNxtr3BNDgBL5YyV9gBK92DUnNxtfKCNnNxt5wyTvwpVXgzFDxyY51ubjwASLgD551uW9gDP9MBEnvsUrwAJfgDVjNxt52BUvMxt5uyTvMxtb1B0L2BU51usvgBLf2CL5LtYatm2eZnUaZmX4fDErNxtnfCLnwAHXwA6fgDP9MBE50nW4fDE5f]] )


    storeDefault( 'Retribution AOE', 'displays', 20161106.1, [[dSZKeaGEKQ2fOsBJkIMPiHzl4Wa3ub9CqCBQ6Aif7KWEL2TO2pPFks1WuL(TqNxv0qrYGPmCICqQ0rrKoMIohvKAHQclvbwSiwUsEii9uuldrTorsnre0uvvnzeX0H6Ik0vPIQEMiLRRuBeP03OIInJaBhH(OirFguMgOIVlsYiPIKhRQmAQW4rQCsqv3IOonK7rfLUSkRLkcVMkQCN9VmP7BFKOgTXmwngr)vXKCzkIuQjR2pyb7WnPm1c5bRNQbfiHrXSAU7fOC51fkdDu8poOSZd5uJLUqG2aaIJMuMLaFOmSkOPmfXr1KvJWJaWoG7JYuehvtwnOrFca3KYdb0H8BVA)i)vrAVLDIy0xXKMY83cjHldbLHfUYuePutwnOrFca3KYuePutwncpca7aUpk)Sc5Ptttz6Q4T8GlCaixfKFNo5C(oH7S8aqg2Pguh3NZHYWkdsqbe(zz3noQMSAdb0H8BFfVLPwipy9un4)Iz1ye9xfW5TmJYWcNAYQneLr(TVI0ktrKsnz1i8iaSdy1CdsoavmltrCunz1i8iaSdy1CdsoavmltrKsnz1Gg9jaSAUbjhGkMLPioQMSAqJ(eawn3GKdqfZYS0fc0gaqCOg0yiU6FzqfZYRkMLHvXSCsfZIlZs3hceq0dWOyUcN5TmHhbGDa3hLjDF7tncrR7dJI5YdGpLo1Fz3noQMSAdrzKF7RiTYKUV9rIAW)fZQXi6VkGZBzkIJQjR2pyb7WQ5gKCaQywEmdschj9rzkIuQjR2pyb7WQ5gKCaQywMrzyHtnz1gcOd53(kEl7M(OAYQneLr(TVI0k)dcxgRwkxXTufVLH)lMHOg7iMQCfWPSB6JQjR2qaDi)2xXBzQfYdwpvdkqcJI5YyWc2HHuMAH8G1t1OnMXQXi6VkMKltBmJl7UqGGAcWAftvzbWFLhC4fkzJrXSAUPpwgAu6PA)XYdo8cLSXOywn30hltrCunz1(blyhUjLjDF7ds)Ry2)YJzqs4iPpk7(HrXSAPabbxb5YcG)kZipu1G3lfx4uRM06(I(eaU8GlCaixfKFN0mNWLm5zz(BHKWLXi)5SVfxb5(xEmdschj9rz3pmkMvlfii4kMLfa)vMrEOQbVxkUWPwnsoca7aU8GlCaixfKFN0mNWLm5zXfx29dJIz1GcKWOygsFuM09Tp1Cdiyz)LXL)kUfa]] )

    storeDefault( 'Retribution Primary', 'displays', 20161106.1, [[dOdAeaGEKKDHeSnfuZKKOzlPBQqDyvDBsToss2jH9k2TuTFQ(jjPggs9BPCnsknuegmLHtuhuIokrYXuQZRqwiGSuG0ILWYv0drKNIAzkWZbPjcuMkiMmq10H6IiQRIeYLv56kzJirFJiL2mqSDq1hjP4ZGY0uq(ojHrsKIhdWOjIXJK6KaQBrItd5EePYZiPATePQxJeQZoqcl16wh4UrzRJDJruDrSheMaoHBkUb5NWoCkctmr6FoYnsVmg16UvUMF4Wue0Znw(QvkRpujPiml)aqDyrO2WeWj7MIBGDG8RkoafMaoz3uCJutx84ueE8tnsV0UbbPViuNoS03A6i2QnmdyIKXHdtaNWnf3i10fpofHjGt4MIBGDG8RkoafEuekdgIom1rqhg0REp0lIb07H3B6nf2Hb97Wo3ij5aqXOoSWFbQIWJcxUWn3uCB8tnsV0rqhMaoHBkUb5NWoSBLvzjFe7WmQdREUP42yuhPx6iOdl16wNBLveSU(64WacxcaJAD3i9YyuRdnafMaoz3uCdYpHD4ueMLVALY6dvIBKA12mqc)rSdxeXomSi2HNrSdomlFaqFfr1JrTEeslDyIjs)ZrUrzRJDJruDrShewQ1To3adnpayuRhguGvJ0ajmXeP)5i3agqR7gJO6Iyi6WsTU1bUBadO1DJruDrmeDyXRVWGE4jQyHrTUBetK(NJctU)f1d8auykBDC4Yj6RUj(5SPIWLQMSBkUn(PgPx6iOdxQAYUP42yuhPx6iupmWaADOUXsAQOhXqHH81RJDtnZ2soc6WmQdREUP424NAKEPJyhMyI0)CKBKEzmQ1dJ)jSddnmyhi)QIdqHjGt2nf3G8tyh2TYQSKpID4YfU5MIBJrDKEPJGombCYUP4gPMU4XUvwLL8rSdtaNWnf3i10fp2TYQSKpIDyPw36GgirSdKWK7Fr9apafUeag16UPseuCedclE9fMrAsUbSwUnXQYn55bOPlECyqV69qVigqVhEttRof2HzatKmomgPpPJo4igeiHj3)I6bEakCjamQ1DtLiO4i2HfV(cZinj3awl3Myv5g4hi)QIdd6vVh6fXa69WBAA1PWo4GdtaNSBkUb2bYVQy3kRYs(i2HjGt4MIBGDG8Rk2TYQSKpIDWja]] )


end