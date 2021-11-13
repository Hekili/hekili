-- RogueSubtlety.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ] 

local class = Hekili.Class
local state = Hekili.State

local insert = table.insert

local PTR = ns.PTR


-- Conduits
-- [x] deeper_daggers
-- [x] perforated_veins
-- [-] planned_execution
-- [-] stiletto_staccato


if UnitClassBase( "player" ) == "ROGUE" then
    local spec = Hekili:NewSpecialization( 261 )

    spec:RegisterResource( Enum.PowerType.Energy, {
        shadow_techniques = {
            last = function () return state.query_time end,
            interval = function () return state.time_to_sht[5] end,
            value = 8,
            stop = function () return state.time_to_sht[5] == 0 or state.time_to_sht[5] == 3600 end,
        },

        vendetta_regen = {
            aura = "vendetta_regen",

            last = function ()
                local app = state.buff.vendetta_regen.applied
                local t = state.query_time

                return app + floor( t - app )
            end,

            interval = 1,
            value = 20,
        },
    } )

    spec:RegisterResource( Enum.PowerType.ComboPoints, {
        shadow_techniques = {
            last = function () return state.query_time end,
            interval = function () return state.time_to_sht[5] end,
            value = 1,
            stop = function () return state.time_to_sht[5] == 0 or state.time_to_sht[5] == 3600 end,
        },

        shuriken_tornado = {
            aura = "shuriken_tornado",
            last = function ()
                local app = state.buff.shuriken_tornado.applied
                local t = state.query_time

                return app + floor( t - app )
            end,

            stop = function( x ) return state.buff.shuriken_tornado.remains == 0 end,

            interval = 0.95,
            value = function () return state.active_enemies + ( state.buff.shadow_blades.up and 1 or 0 ) end,
        },
    } )

    -- Talents
    spec:RegisterTalents( {
        weaponmaster = 19233, -- 193537
        premeditation = 19234, -- 343160
        gloomblade = 19235, -- 200758

        nightstalker = 22331, -- 14062
        subterfuge = 22332, -- 108208
        shadow_focus = 22333, -- 108209

        vigor = 19239, -- 14983
        deeper_stratagem = 19240, -- 193531
        marked_for_death = 19241, -- 137619

        soothing_darkness = 22128, -- 200759
        cheat_death = 22122, -- 31230
        elusiveness = 22123, -- 79008

        shot_in_the_dark = 23078, -- 257505
        night_terrors = 23036, -- 277953
        prey_on_the_weak = 22115, -- 131511

        dark_shadow = 22335, -- 245687
        alacrity = 19249, -- 193539
        enveloping_shadows = 22336, -- 238104

        master_of_shadows = 22132, -- 196976
        secret_technique = 23183, -- 280719
        shuriken_tornado = 21188, -- 277925
    } )

    -- PvP Talents
    spec:RegisterPvpTalents( { 
        dagger_in_the_dark = 846, -- 198675
        death_from_above = 3462, -- 269513
        dismantle = 5406, -- 207777
        distracting_mirage = 5411, -- 354661
        maneuverability = 3447, -- 197000
        shadowy_duel = 153, -- 207736
        silhouette = 856, -- 197899
        smoke_bomb = 1209, -- 359053
        thick_as_thieves = 5409, -- 221622
        thiefs_bargain = 146, -- 354825
        veil_of_midnight = 136, -- 198952
    } )

    -- Auras
    spec:RegisterAuras( {
    	alacrity = {
            id = 193538,
            duration = 20,
            max_stack = 5,
        },
        blind = {
            id = 2094,
            duration = 60,
            max_stack = 1,
        },
        cheap_shot = {
            id = 1833,
            duration = 4,
            max_stack = 1,
        },
        cloak_of_shadows = {
            id = 31224,
            duration = 5,
            max_stack = 1,
        },
        death_from_above = {
            id = 152150,
            duration = 1,
        },
        crimson_vial = {
            id = 185311,
            duration = 4,
            max_stack = 1,
        },
        crippling_poison = {
            id = 3408,
            duration = 3600,
            max_stack = 1,
        },
        crippling_poison_dot = {
            id = 3409,
            duration = 12,
            max_stack = 1,
        },
        evasion = {
            id = 5277,
            duration = 10,
            max_stack = 1,
        },
        feint = {
            id = 1966,
            duration = 5,
            max_stack = 1,
        },
        find_weakness = {
            id = 316220,
            duration = 18,
            max_stack = 1,
        },
        fleet_footed = {
            id = 31209,
        },
        instant_poison = {
            id = 315584,
            duration = 3600,
            max_stack = 1,
        },
        kidney_shot = {
            id = 408,
            duration = 6,
            max_stack = 1,
        },
        marked_for_death = {
            id = 137619,
            duration = 60,
            max_stack = 1,
        },
        master_of_shadows = {
            id = 196980,
            duration = 3,
            max_stack = 1,
        },
        premeditation = {
            id = 343173,
            duration = 3600,
            max_stack = 1,
        },
        prey_on_the_weak = {
            id = 255909,
            duration = 6,
            max_stack = 1,
        },
        relentless_strikes = {
            id = 58423,
        },
        --[[ Share Assassination implementation to avoid errors.
        rupture = {
            id = 1943,
            duration = function () return talent.deeper_stratagem.enabled and 28 or 24 end,
            max_stack = 1,
        }, ]]
        shadow_blades = {
            id = 121471,
            duration = 20,
            max_stack = 1,
        },
        shadow_dance = {
            id = 185422,
            duration = function () return talent.subterfuge.enabled and 9 or 8 end,
            max_stack = 1,
        },
        shadows_grasp = {
            id = 206760,
            duration = 8,
            type = "Magic",
            max_stack = 1,
        },
        shadow_techniques = {
            id = 196912,
        },
        shadowstep = {
            id = 36554,
            duration = 2,
            max_stack = 1,
        },
        shot_in_the_dark = {
            id = 257506,
            duration = 3600,
            max_stack = 1,
        },
        shroud_of_concealment = {
            id = 114018,
            duration = 15,
            max_stack = 1,
        },
        shuriken_tornado = {
            id = 277925,
            duration = 4,
            max_stack = 1,
        },
        slice_and_dice = {
            id = 315496,
            duration = 10,
            max_stack = 1,
        },
        sprint = {
            id = 2983,
            duration = 8,
            max_stack = 1,
        },
        stealth = {
            id = function () return talent.subterfuge.enabled and 115191 or 1784 end,
            duration = 3600,
            max_stack = 1,
            copy = { 115191, 1784 }
        },
        subterfuge = {
            id = 115192,
            duration = 3,
            max_stack = 1,
        },
        symbols_of_death = {
            id = 212283,
            duration = 10,
            max_stack = 1,
        },
        symbols_of_death_crit = {
            id = 227151,
            duration = 10,
            max_stack = 1,
            copy = "symbols_of_death_autocrit"
        },
        vanish = {
            id = 11327,
            duration = 3,
            max_stack = 1,
        },
        wound_poison = {
            id = 8679,
            duration = 3600,
            max_stack = 1,
        },


        lethal_poison = {
            alias = { "instant_poison", "wound_poison", "slaughter_poison" },
            aliasMode = "first",
            aliasType = "buff",
            duration = 3600
        },
        nonlethal_poison = {
            alias = { "crippling_poison", "numbing_poison" },
            aliasMode = "first",
            aliasType = "buff",
            duration = 3600
        },


        -- Azerite Powers
        blade_in_the_shadows = {
            id = 279754,
            duration = 60,
            max_stack = 10,
        },

        nights_vengeance = {
            id = 273424,
            duration = 8,
            max_stack = 1,
        },

        perforate = {
            id = 277720,
            duration = 12,
            max_stack = 1
        },

        replicating_shadows = {
            id = 286131,
            duration = 1,
            max_stack = 50
        },

        the_first_dance = {
            id = 278981,
            duration = function () return buff.shadow_dance.duration end,
            max_stack = 1,
        },


        -- Legendaries (Shadowlands)
        deathly_shadows = {
            id = 341202,
            duration = 15,
            max_stack = 1,
        },

        master_assassins_mark = {
            id = 340094,
            duration = 4,
            max_stack = 1
        },

        the_rotten = {
            id = 341134,
            duration = 3,
            max_stack = 1
        }

    } )


    local true_stealth_change = 0
    local emu_stealth_change = 0

    spec:RegisterEvent( "UPDATE_STEALTH", function ()
        true_stealth_change = GetTime()
    end )


    local stealth = {
        rogue   = { "stealth", "vanish", "shadow_dance", "subterfuge" },
        mantle  = { "stealth", "vanish" },
        sepsis  = { "sepsis_buff" },
        all     = { "stealth", "vanish", "shadow_dance", "subterfuge", "shadowmeld", "sepsis_buff" }
    }


    spec:RegisterStateTable( "stealthed", setmetatable( {}, {
        __index = function( t, k )
            if k == "rogue" then
                return buff.stealth.up or buff.vanish.up or buff.shadow_dance.up or buff.subterfuge.up
            elseif k == "rogue_remains" then
                return max( buff.stealth.remains, buff.vanish.remains, buff.shadow_dance.remains, buff.subterfuge.remains )

            elseif k == "mantle" then
                return buff.stealth.up or buff.vanish.up
            elseif k == "mantle_remains" then
                return max( buff.stealth.remains, buff.vanish.remains )
            
            elseif k == "sepsis" then
                return buff.sepsis_buff.up
            elseif k == "sepsis_remains" then
                return buff.sepsis_buff.remains
            
            elseif k == "all" then
                return buff.stealth.up or buff.vanish.up or buff.shadow_dance.up or buff.subterfuge.up or buff.shadowmeld.up or buff.sepsis_buff.up
            elseif k == "remains" or k == "all_remains" then
                return max( buff.stealth.remains, buff.vanish.remains, buff.shadow_dance.remains, buff.subterfuge.remains, buff.shadowmeld.remains, buff.sepsis_buff.remains )
            end

            return false
        end
    } ) )


    local last_mh = 0
    local last_oh = 0
    local last_shadow_techniques = 0
    local swings_since_sht = 0

    spec:RegisterEvent( "COMBAT_LOG_EVENT_UNFILTERED", function()
        local event, _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName, _, amount, interrupt, a, b, c, d, offhand, multistrike = CombatLogGetCurrentEventInfo()

        if sourceGUID == state.GUID then
            if subtype == "SPELL_ENERGIZE" and spellID == 196911 then
                last_shadow_techniques = GetTime()
                swings_since_sht = 0
            end

            if subtype:sub( 1, 5 ) == "SWING" and not multistrike then
                if subtype == "SWING_MISSED" then
                    offhand = spellName
                end

                local now = GetTime()

                if now > last_shadow_techniques + 3 then
                    swings_since_sht = swings_since_sht + 1
                end

                if offhand then last_mh = GetTime()
                else last_mh = GetTime() end
            end
        end
    end )


    local sht = {}

    spec:RegisterStateTable( "time_to_sht", setmetatable( {}, {
        __index = function( t, k )
            local n = tonumber( k )
            n = n - ( n % 1 )

            if not n or n > 5 then return 3600 end

            if n <= swings_since_sht then return 0 end

            local mh_speed = swings.mainhand_speed
            local mh_next = ( swings.mainhand > now - 3 ) and ( swings.mainhand + mh_speed ) or now + ( mh_speed * 0.5 )

            local oh_speed = swings.offhand_speed
            local oh_next = ( swings.offhand > now - 3 ) and ( swings.offhand + oh_speed ) or now

            table.wipe( sht )

            if mh_speed and mh_speed > 0 then
                for i = 1, 4 do
                    insert( sht, mh_next + ( i * mh_speed ) )
                end
            end

            if oh_speed and oh_speed > 0 then
                for i = 1, 4 do
                    insert( sht, oh_next + ( i * oh_speed ) )
                end
            end

            local i = 1

            while( sht[i] ) do
                if sht[i] < last_shadow_techniques + 3 then
                    table.remove( sht, i )
                else
                    i = i + 1
                end
            end

            if #sht > 0 and n - swings_since_sht < #sht then
                table.sort( sht )
                return max( 0, sht[ n - swings_since_sht ] - query_time )
            else
                return 3600
            end
        end
    } ) )


    spec:RegisterStateExpr( "bleeds", function ()
        return ( debuff.garrote.up and 1 or 0 ) + ( debuff.rupture.up and 1 or 0 )
    end )


    spec:RegisterStateExpr( "cp_max_spend", function ()
        return combo_points.max
    end )

    -- Legendary from Legion, shows up in APL still.
    spec:RegisterGear( "cinidaria_the_symbiote", 133976 )
    spec:RegisterGear( "denial_of_the_halfgiants", 137100 )

    local function comboSpender( amt, resource )
        if resource == "combo_points" then
            if amt > 0 then
                gain( 6 * amt, "energy" )
            end

            if talent.alacrity.enabled and amt >= 5 then
                addStack( "alacrity", 20, 1 )
            end

            if talent.secret_technique.enabled then
                cooldown.secret_technique.expires = max( 0, cooldown.secret_technique.expires - amt )
            end

            reduceCooldown( "shadow_dance", amt * ( talent.enveloping_shadows.enabled and 1.5 or 1 ) )

            if legendary.obedience.enabled and buff.flagellation_buff.up then
                reduceCooldown( "flagellation", amt )
            end
        end
    end

    spec:RegisterHook( "spend", comboSpender )
    -- spec:RegisterHook( "spendResources", comboSpender )


    spec:RegisterStateExpr( "mantle_duration", function ()
        return legendary.mark_of_the_master_assassin.enabled and 4 or 0
    end )

    spec:RegisterStateExpr( "master_assassin_remains", function ()
        if not legendary.mark_of_the_master_assassin.enabled then return 0 end

        if stealthed.mantle then return cooldown.global_cooldown.remains + 4
        elseif buff.master_assassins_mark.up then return buff.master_assassins_mark.remains end
        return 0
    end )


    spec:RegisterStateExpr( "priority_rotation", function ()
        return settings.priority_rotation
    end )


    -- We need to break stealth when we start combat from an ability.
    spec:RegisterHook( "runHandler", function( ability )
        local a = class.abilities[ ability ]

        if stealthed.mantle and ( not a or a.startsCombat ) then
            if talent.subterfuge.enabled and stealthed.mantle then
                applyBuff( "subterfuge" )
            end

            if legendary.mark_of_the_master_assassin.enabled and stealthed.mantle then
                applyBuff( "master_assassins_mark", 4 )
            end

            if buff.stealth.up then 
                setCooldown( "stealth", 2 )
            end
            removeBuff( "stealth" )
            removeBuff( "vanish" )
            removeBuff( "shadowmeld" )
        end
    end )

    
    local ExpireSepsis = setfenv( function ()
        applyBuff( "sepsis_buff" )
    end, state )

    spec:RegisterHook( "reset_precast", function( amt, resource )
        if debuff.sepsis.up then
            state:QueueAuraExpiration( "sepsis", ExpireSepsis, debuff.sepsis.expires )
        end
    end )

    spec:RegisterCycle( function ()
        if active_enemies == 1 then return end
        if this_action == "marked_for_death" then
            if active_dot.marked_for_death >= cycle_enemies then return end -- As far as we can tell, MfD is on everything we care about, so we don't cycle.
            if debuff.marked_for_death.up then return "cycle" end -- If current target already has MfD, cycle.
            if target.time_to_die > 3 + Hekili:GetLowestTTD() and active_dot.marked_for_death == 0 then return "cycle" end -- If our target isn't lowest TTD, and we don't have to worry that the lowest TTD target is already MfD'd, cycle.
        end
    end )

    spec:RegisterGear( "insignia_of_ravenholdt", 137049 )
    spec:RegisterGear( "mantle_of_the_master_assassin", 144236 )
        spec:RegisterAura( "master_assassins_initiative", {
            id = 235027,
            duration = 5
        } )

        spec:RegisterStateExpr( "mantle_duration", function()
            if stealthed.mantle then return cooldown.global_cooldown.remains + buff.master_assassins_initiative.duration
            elseif buff.master_assassins_initiative.up then return buff.master_assassins_initiative.remains end
            return 0
        end )


    spec:RegisterGear( "shadow_satyrs_walk", 137032 )
        spec:RegisterStateExpr( "ssw_refund_offset", function()
            return target.distance
        end )

    spec:RegisterGear( "soul_of_the_shadowblade", 150936 )
    spec:RegisterGear( "the_dreadlords_deceit", 137021 )
        spec:RegisterAura( "the_dreadlords_deceit", {
            id = 228224, 
            duration = 3600,
            max_stack = 20,
            copy = 208693
        } )

    spec:RegisterGear( "the_first_of_the_dead", 151818 )
        spec:RegisterAura( "the_first_of_the_dead", {
            id = 248210, 
            duration = 2 
        } )

    spec:RegisterGear( "will_of_valeera", 137069 )
        spec:RegisterAura( "will_of_valeera", {
            id = 208403, 
            duration = 5 
        } )

    -- Tier Sets
    spec:RegisterGear( "tier21", 152163, 152165, 152161, 152160, 152162, 152164 )
    spec:RegisterGear( "tier20", 147172, 147174, 147170, 147169, 147171, 147173 )
    spec:RegisterGear( "tier19", 138332, 138338, 138371, 138326, 138329, 138335 )


    -- Abilities
    spec:RegisterAbilities( {
        backstab = {
            id = 53,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function () return 35 * ( ( talent.shadow_focus.enabled and ( buff.shadow_dance.up or buff.stealth.up ) ) and 0.8 or 1 ) end,
            spendType = "energy",

            startsCombat = true,
            texture = 132090,

            notalent = "gloomblade",

            handler = function ()
                applyDebuff( "target", "shadows_grasp", 8 )
                if azerite.perforate.enabled and buff.perforate.up then
                    -- We'll assume we're attacking from behind if we've already put up Perforate once.
                    addStack( "perforate", nil, 1 )
                    gainChargeTime( "shadow_blades", 0.5 )
                end
                gain( ( buff.shadow_blades.up and 2 or 1 ) + ( buff.the_rotten.up and 4 or 0 ), "combo_points" )
                removeBuff( "the_rotten" )
                removeBuff( "symbols_of_death_crit" )
                removeBuff( "perforated_veins" )
            end,
        },


        black_powder = {
            id = 319175,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = function () return 35 * ( ( talent.shadow_focus.enabled and ( buff.shadow_dance.up or buff.stealth.up ) ) and 0.8 or 1 ) end,
            spendType = "energy",
            
            startsCombat = true,
            texture = 608955,

            usable = function () return combo_points.current > 0, "requires combo_points" end,
            handler = function ()
                if talent.alacrity.enabled and combo_points.current > 4 then addStack( "alacrity", nil, 1 ) end
                if combo_points.current == animacharged_cp then removeBuff( "echoing_reprimand" ) end

                if buff.finality_black_powder.up then removeBuff( "finality_black_powder" )
                elseif legendary.finality.enabled then applyBuff( "finality_black_powder" ) end

                spend( min( talent.deeper_stratagem.enabled and 6 or 5, combo_points.current ), "combo_points" )
                if conduit.deeper_daggers.enabled then applyBuff( "deeper_daggers" ) end
            end,

            auras = {
                finality_black_powder = {
                    id = 340603,
                    duration = 30,
                    max_stack = 1
                }
            }
        },
        

        blind = {
            id = 2094,
            cast = 0,
            cooldown = function () return 120 - ( talent.blinding_powder.enabled and 30 or 0 ) end,
            gcd = "spell",

            startsCombat = true,
            texture = 136175,

            handler = function ()
              applyDebuff( "target", "blind", 60)
            end,
        },


        cheap_shot = {
            id = 1833,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function () 
                if buff.shot_in_the_dark.up then return 0 end
                return 40 * ( ( talent.shadow_focus.enabled and ( buff.shadow_dance.up or buff.stealth.up ) ) and 0.8 or 1 ) * ( 1 + conduit.rushed_setup.mod * 0.01 )
            end,
            spendType = "energy",

            startsCombat = true,
            texture = 132092,

            cycle = function ()
                if talent.prey_on_the_weak.enabled then return "prey_on_the_weak" end
            end,

            usable = function ()
                if boss then return false, "cheap_shot assumed unusable in boss fights" end
                return stealthed.all, "not stealthed"
            end,

            nodebuff = "cheap_shot",

            handler = function ()
                applyDebuff( "target", "find_weakness" )

                if talent.prey_on_the_weak.enabled then
                    applyDebuff( "target", "prey_on_the_weak" )
                end

                if talent.subterfuge.enabled then
                	applyBuff( "subterfuge" )
                end

                applyDebuff( "target", "cheap_shot" )
                removeBuff( "shot_in_the_dark" )

                if buff.sepsis_buff.up then removeBuff( "sepsis_buff" ) end

                gain( buff.shadow_blades.up and 2 or 1, "combo_points" )
                removeBuff( "symbols_of_death_crit" )
            end,
        },


        cloak_of_shadows = {
            id = 31224,
            cast = 0,
            cooldown = 120,
            gcd = "off",

            toggle = "cooldowns",

            startsCombat = false,
            texture = 136177,

            handler = function ()
                applyBuff( "cloak_of_shadows", 5 )
            end,
        },


        crimson_vial = {
            id = 185311,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            toggle = "cooldowns",

            spend = function () return ( 20 - conduit.nimble_fingers.mod ) * ( ( talent.shadow_focus.enabled and ( buff.shadow_dance.up or buff.stealth.up ) ) and 0.8 or 1 ) end,
            spendType = "energy",

            startsCombat = false,
            texture = 1373904,

            handler = function ()
                applyBuff( "crimson_vial", 6 )
            end,
        },


        crippling_poison = {
            id = 3408,
            cast = 1.5,
            cooldown = 0,
            gcd = "spell",

            essential = true,
            
            startsCombat = false,
            texture = 132274,
            
            readyTime = function () return buff.nonlethal_poison.remains - 120 end,

            handler = function ()
                applyBuff( "crippling_poison" )
            end,
        },


        distract = {
            id = 1725,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            spend = function () return 30 * ( ( talent.shadow_focus.enabled and ( buff.shadow_dance.up or buff.stealth.up ) ) and 0.8 or 1 ) * ( 1 + conduit.rushed_setup.mod * 0.01 ) end,
            spendType = "energy",

            startsCombat = false,
            texture = 132289,

            handler = function ()
            end,
        },


        evasion = {
            id = 5277,
            cast = 0,
            cooldown = 120,
            gcd = "off",

            toggle = "cooldowns",

            startsCombat = false,
            texture = 136205,

            handler = function ()
            	applyBuff( "evasion", 10 )
            end,
        },


        eviscerate = {
            id = 196819,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function () return 35 * ( ( talent.shadow_focus.enabled and ( buff.shadow_dance.up or buff.stealth.up ) ) and 0.8 or 1 ) end,
            spendType = "energy",

            startsCombat = true,
            texture = 132292,

            usable = function () return combo_points.current > 0 end,
            handler = function ()
            	if talent.alacrity.enabled and combo_points.current > 4 then
                    addStack( "alacrity", 20, 1 )
                end
                removeBuff( "nights_vengeance" )

                if buff.finality_eviscerate.up then removeBuff( "finality_eviscerate" )
                elseif legendary.finality.enabled then applyBuff( "finality_eviscerate" ) end

                if combo_points.current == animacharged_cp then removeBuff( "echoing_reprimand" ) end
                spend( min( talent.deeper_stratagem.enabled and 6 or 5, combo_points.current ), "combo_points" )

                if conduit.deeper_daggers.enabled then applyBuff( "deeper_daggers" ) end
            end,

            auras = {
                -- Conduit
                deeper_daggers = {
                    id = 341550,
                    duration = 5,
                    max_stack = 1
                },
                finality_eviscerate = {
                    id = 340600,
                    duration = 30,
                    max_stack = 1 
                }
            }
        },


        feint = {
            id = 1966,
            cast = 0,
            cooldown = 15,
            gcd = "spell",

            spend = function () return ( 35 - conduit.nimble_fingers.mod ) * ( ( talent.shadow_focus.enabled and ( buff.shadow_dance.up or buff.stealth.up ) ) and 0.8 or 1 ) end,
            spendType = "energy",

            startsCombat = false,
            texture = 132294,

            handler = function ()
                applyBuff( "feint", 5 )
            end,
        },


        gloomblade = {
            id = 200758,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function () return 35 * ( ( talent.shadow_focus.enabled and ( buff.shadow_dance.up or buff.stealth.up ) ) and 0.8 or 1 ) end,
            spendType = "energy",

            talent = "gloomblade",

            startsCombat = true,
            texture = 1035040,

            handler = function ()
                applyDebuff( "target", "shadows_grasp", 8 )
            	if buff.stealth.up then
            		removeBuff( "stealth" )
            	end
                gain( ( buff.shadow_blades.up and 2 or 1 ) + ( buff.the_rotten.up and 4 or 0 ), "combo_points" )
                removeBuff( "the_rotten" )
                removeBuff( "symbols_of_death_crit" )
            end,
        },


        instant_poison = {
            id = 315584,
            cast = 1.5,
            cooldown = 0,
            gcd = "spell",

            essential = true,
            
            startsCombat = false,
            texture = 132273,
            
            readyTime = function () return buff.lethal_poison.remains - 120 end,

            handler = function ()
                applyBuff( "instant_poison" )
            end,
        },


        kick = {
            id = 1766,
            cast = 0,
            cooldown = 15,
            gcd = "off",

            toggle = "interrupts", 
            interrupt = true,

            startsCombat = true,
            texture = 132219,

            debuff = "casting",
            readyTime = state.timeToInterrupt,

            handler = function ()
                interrupt()
                
                if conduit.prepared_for_all.enabled and cooldown.cloak_of_shadows.remains > 0 then
                    reduceCooldown( "cloak_of_shadows", 2 * conduit.prepared_for_all.mod )
                end
            end,
        },


        kidney_shot = {
            id = 408,
            cast = 0,
            cooldown = 20,
            gcd = "spell",

            spend = function () return 25 * ( ( talent.shadow_focus.enabled and ( buff.shadow_dance.up or buff.stealth.up ) ) and 0.8 or 1 ) * ( 1 + conduit.rushed_setup.mod * 0.01 ) end,
            spendType = "energy",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 132298,

            usable = function () return combo_points.current > 0 end,
            handler = function ()
                if talent.alacrity.enabled and combo_points.current > 4 then
                    addStack( "alacrity", 20, 1 )
                end

                local combo = min( talent.deeper_stratagem.enabled and 6 or 5, combo_points.current )
                applyDebuff( "target", "kidney_shot", 2 + 1 * ( combo - 1 ) )

                if talent.prey_on_the_weak.enabled then applyDebuff( "target", "prey_on_the_weak" ) end

                if combo_points.current == animacharged_cp then removeBuff( "echoing_reprimand" ) end
                spend( min( talent.deeper_stratagem.enabled and 6 or 5, combo_points.current ), "combo_points" )
            end,
        },


        marked_for_death = {
            id = 137619,
            cast = 0,
            cooldown = 60,
            gcd = "off",

            talent = "marked_for_death", 

            startsCombat = false,
            texture = 236364,

            usable = function ()
                return combo_points.current <= settings.mfd_points, "combo_point (" .. combo_points.current .. ") > user preference (" .. settings.mfd_points .. ")"
            end,

            handler = function ()
                gain( 5, "combo_points")
                applyDebuff( "target", "marked_for_death", 60 )
            end,
        },


        numbing_poison = {
            id = 5761,
            cast = 1.5,
            cooldown = 0,
            gcd = "spell",

            essential = true,
            
            startsCombat = false,
            texture = 136066,
            
            readyTime = function () return buff.nonlethal_poison.remains - 120 end,

            handler = function ()
                applyBuff( "numbing_poison" )
            end,
        },

        pick_lock = {
            id = 1804,
            cast = 1.5,
            cooldown = 0,
            gcd = "spell",

            startsCombat = false,
            texture = 136058,

            handler = function ()
            end,
        },


        pick_pocket = {
            id = 921,
            cast = 0,
            cooldown = 0.5,
            gcd = "spell",

            startsCombat = false,
            texture = 133644,

            handler = function ()
            end,
        },


        rupture = {
            id = 1943,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = function () return 25 * ( ( talent.shadow_focus.enabled and ( buff.shadow_dance.up or buff.stealth.up ) ) and 0.8 or 1 ) end,
            spendType = "energy",
            
            startsCombat = true,
            texture = 132302,
            
            handler = function ()
                if talent.alacrity.enabled and combo_points.current >= 5 then addStack( "alacrity", nil, 1 ) end
                applyDebuff( "target", "rupture", 4 + ( 4 * combo_points.current ) )

                if buff.finality_rupture.up then removeBuff( "finality_rupture" )
                elseif legendary.finality.enabled then applyBuff( "finality_rupture" ) end

                if combo_points.current == animacharged_cp then removeBuff( "echoing_reprimand" ) end
                spend( min( talent.deeper_stratagem.enabled and 6 or 5, combo_points.current ), "combo_points" )
            end,

            auras = {
                finality_rupture = {
                    id = 340601,
                    duration = 30,
                    max_stack = 1
                }
            }
        },


        sap = {
            id = 6770,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function () return 35 * ( ( talent.shadow_focus.enabled and ( buff.shadow_dance.up or buff.stealth.up ) ) and 0.8 or 1 ) * ( 1 + conduit.rushed_setup.mod * 0.01 ) end,
            spendType = "energy",

            startsCombat = false,
            texture = 132310,

            handler = function ()
                applyDebuff( "target", "sap", 60 )
            end,
        },


        secret_technique = {
            id = 280719,
            cast = 0,
            cooldown = function () return 45 - min( talent.deeper_stratagem.enabled and 6 or 5, combo_points.current ) end,
            gcd = "spell",

            spend = function () return 30 * ( ( talent.shadow_focus.enabled and ( buff.shadow_dance.up or buff.stealth.up ) ) and 0.8 or 1 ) end,
            spendType = "energy",

            startsCombat = true,
            texture = 132305,

            usable = function () return combo_points.current > 0, "requires combo_points" end,
            handler = function ()
                if talent.alacrity.enabled and combo_points.current > 4 then addStack( "alacrity", nil, 1 ) end                
                if combo_points.current == animacharged_cp then removeBuff( "echoing_reprimand" ) end
                spend( min( talent.deeper_stratagem.enabled and 6 or 5, combo_points.current ), "combo_points" )
            end,
        },


        shadow_blades = {
            id = 121471,
            cast = 0,
            cooldown = function () return ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * 180 end,
            gcd = "off",

            toggle = "cooldowns",

            startsCombat = false,
            texture = 376022,

            handler = function ()
            	applyBuff( "shadow_blades" )
            end,
        },


        shadow_dance = {
            id = 185313,
            cast = 0,
            charges = function () return talent.enveloping_shadows.enabled and 2 or nil end,
            cooldown = 60,
            recharge = function () return talent.enveloping_shadows.enabled and 60 or nil end,
            gcd = "off",

            startsCombat = false,
            texture = 236279,

            nobuff = "shadow_dance",

            usable = function () return not stealthed.all, "not used in stealth" end,
            handler = function ()
                applyBuff( "shadow_dance" )
                if talent.shot_in_the_dark.enabled then applyBuff( "shot_in_the_dark" ) end
                if talent.master_of_shadows.enabled then applyBuff( "master_of_shadows", 3 ) end
                if azerite.the_first_dance.enabled then
                    gain( 2, "combo_points" )
                    applyBuff( "the_first_dance" )
                end
            end,
        },


        shadowstep = {
            id = 36554,
            cast = 0,
            charges = 2,
            cooldown = function () return 30 * ( 1 - conduit.quick_decisions.mod * 0.01 ) end,
            recharge = function () return 30 * ( 1 - conduit.quick_decisions.mod * 0.01 ) end,
            gcd = "off",

            startsCombat = false,
            texture = 132303,

            handler = function ()
            	applyBuff( "shadowstep" )
            end,
        },


        shadowstrike = {
            id = 185438,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function () return ( azerite.blade_in_the_shadows.enabled and 38 or 40 ) * ( ( talent.shadow_focus.enabled and ( buff.shadow_dance.up or buff.stealth.up ) ) and 0.8 or 1 ) end,
            spendType = "energy",

            cycle = function () return talent.find_weakness.enabled and "find_weakness" or nil end,

            startsCombat = true,
            texture = 1373912,

            usable = function () return stealthed.all or buff.sepsis_buff.up, "requires stealth or sepsis_buff" end,
            handler = function ()
                gain( ( buff.shadow_blades.up and 3 or 2 ) + ( buff.the_rotten.up and 4 or 0 ), "combo_points" )
                removeBuff( "the_rotten" )
                removeBuff( "symbols_of_death_crit" )

                if azerite.blade_in_the_shadows.enabled then addStack( "blade_in_the_shadows", nil, 1 ) end
                if buff.premeditation.up then
                    if buff.slice_and_dice.up then
                        gain( 2, "combo_points" )
                        if buff.slice_and_dice.remains < 10 then buff.slice_and_dice.expires = query_time + 10 end
                    else
                        applyBuff( "slice_and_dice", 10 )
                    end
                    removeBuff( "premeditation" )
                end

                if conduit.perforated_veins.enabled then
                    addStack( "perforated_veins", nil, 1 )
                end

                removeBuff( "sepsis_buff" )

                applyDebuff( "target", "find_weakness" )
            end,

            auras = {
                -- Conduit
                perforated_veins = {
                    id = 341572,
                    duration = 12,
                    max_stack = 3
                },
            }
        },


        shiv = {
            id = 5938,
            cast = 0,
            cooldown = 25,
            gcd = "spell",
            
            spend = function ()
                if legendary.tiny_toxic_blade.enabled then return 0 end
                return 20 * ( ( talent.shadow_focus.enabled and ( buff.shadow_dance.up or buff.stealth.up ) ) and 0.8 or 1 )
            end,
            spendType = "energy",
            
            startsCombat = true,
            texture = 135428,
            
            handler = function ()
                gain( 1, "combo_points" )
                removeBuff( "symbols_of_death_crit" )
                applyDebuff( "target", "crippling_poison_shiv" )
            end,

            auras = {
                crippling_poison_shiv = {
                    id = 319504,
                    duration = 9,
                    max_stack = 1,        
                },
            }
        },


        shroud_of_concealment = {
            id = 114018,
            cast = 0,
            cooldown = 360,
            gcd = "spell",

            toggle = "cooldowns",

            startsCombat = false,
            texture = 635350,

            handler = function ()
                applyBuff( "shroud_of_concealment" )
                if conduit.fade_to_nothing.enabled then applyBuff( "fade_to_nothing" ) end
            end,
        },


        shuriken_storm = {
            id = 197835,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function () return 35 * ( ( talent.shadow_focus.enabled and ( buff.shadow_dance.up or buff.stealth.up ) ) and 0.8 or 1 ) end,
            spendType = "energy",

            startsCombat = true,
            texture = 1375677,

            handler = function ()
                gain( active_enemies + ( buff.shadow_blades.up and 1 or 0 ), "combo_points" )
                removeBuff( "symbols_of_death_crit" )
            end,
        },


        shuriken_tornado = {
            id = 277925,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            spend = function () return 60 * ( ( talent.shadow_focus.enabled and ( buff.shadow_dance.up or buff.stealth.up ) ) and 0.8 or 1 ) end,
            spendType = "energy",

            toggle = "cooldowns",

            talent = "shuriken_tornado",

            startsCombat = true,
            texture = 236282,

            handler = function ()
             	applyBuff( "shuriken_tornado" )
            end,
        },


        shuriken_toss = {
            id = 114014,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function () return 40 * ( ( talent.shadow_focus.enabled and ( buff.shadow_dance.up or buff.stealth.up ) ) and 0.8 or 1 ) end,
            spendType = "energy",

            startsCombat = true,
            texture = 135431,

            handler = function ()
                gain( active_enemies + ( buff.shadow_blades.up and 1 or 0 ), "combo_points" )
                removeBuff( "symbols_of_death_crit" )
            end,
        },


        slice_and_dice = {
            id = 315496,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 25,
            spendType = "energy",

            startsCombat = false,
            texture = 132306,

            usable = function()
                return combo_points.current > 0, "requires combo_points"
            end,

            handler = function ()
                if talent.alacrity.enabled and combo_points.current > 4 then
                    addStack( "alacrity", 20, 1 )
                end

                local combo = min( talent.deeper_stratagem.enabled and 6 or 5, combo_points.current )
                applyBuff( "slice_and_dice", 6 + 6 * combo )
                spend( combo, "combo_points" )
            end,
        },


        sprint = {
            id = 2983,
            cast = 0,
            cooldown = 120,
            gcd = "off",

            startsCombat = false,
            texture = 132307,

            handler = function ()
                applyBuff( "sprint" )
            end,
        },


        stealth = {
            id = function () return talent.subterfuge.enabled and 115191 or 1784 end,
            known = 1784,
            cast = 0,
            cooldown = 2,
            gcd = "off",

            startsCombat = false,
            texture = 132320,

            usable = function ()
                if time > 0 then return false, "cannot use in combat" end
                if buff.stealth.up then return false, "cannot use in stealth" end
                if buff.vanish.up then return false, "cannot use while vanished" end
                return true
            end,
            readyTime = function () return buff.shadow_dance.remains end,
            handler = function ()
                applyBuff( "stealth" )
                if talent.shot_in_the_dark.enabled then applyBuff( "shot_in_the_dark" ) end
                if talent.premeditation.enabled then applyBuff( "premeditation" ) end

                emu_stealth_change = query_time

                if conduit.cloaked_in_shadows.enabled then applyBuff( "cloaked_in_shadows" ) end  
                if conduit.fade_to_nothing.enabled then applyBuff( "fade_to_nothing" ) end              
            end,

            copy = { 1784, 115191 }
        },


        symbols_of_death = {
            id = 212283,
            cast = 0,
            charges = 1,
            cooldown = 30,
            recharge = 30,
            gcd = "off",

            spend = -40,
            spendType = "energy",

            startsCombat = false,
            texture = 252272,

            handler = function ()
                applyBuff( "symbols_of_death" )
                applyBuff( "symbols_of_death_crit" )

                if legendary.the_rotten.enabled then applyBuff( "the_rotten" ) end
            end,
        },


        tricks_of_the_trade = {
            id = 57934,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            startsCombat = false,
            texture = 236283,

            usable = function () return group, "requires an ally" end,
            handler = function ()
                applyBuff( "tricks_of_the_trade" )
            end,
        },


        vanish = {
            id = 1856,
            cast = 0,
            cooldown = 120,
            gcd = "off",

            toggle = "cooldowns",

            startsCombat = false,
            texture = 132331,

            disabled = function ()
                return not settings.solo_vanish and not ( boss and group ), "can only vanish in a boss encounter or with a group"
            end,

            handler = function ()
                applyBuff( "vanish", 3 )
                applyBuff( "stealth" )
                emu_stealth_change = query_time

                if legendary.deathly_shadows.enabled then
                    gain( 5, "combo_points" )
                    applyBuff( "deathly_shadows" )
                end

                if legendary.invigorating_shadowdust.enabled then
                    for name, cd in pairs( cooldown ) do
                        if cd.remains > 0 then reduceCooldown( name, 20 ) end
                    end
                end

                if conduit.cloaked_in_shadows.enabled then applyBuff( "cloaked_in_shadows" ) end
                if conduit.fade_to_nothing.enabled then applyBuff( "fade_to_nothing" ) end
            end,
        },


        wound_poison = {
            id = 8679,
            cast = 1.5,
            cooldown = 0,
            gcd = "spell",

            startsCombat = false,
            texture = 134194,

            readyTime = function () return buff.lethal_poison.remains - 120 end,

            handler = function ()
                applyBuff( "wound_poison" )
            end,
        },
    } )


    -- Override this for rechecking.
    spec:RegisterAbility( "shadowmeld", {
        id = 58984,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        usable = function () return boss and group end,
        handler = function ()
            applyBuff( "shadowmeld" )
        end,
    } )


    spec:RegisterOptions( {
        enabled = true,

        aoe = 2,

        nameplates = true,
        nameplateRange = 8,

        damage = true,
        damageExpiration = 6,

        potion = "phantom_fire",

        package = "Subtlety",
    } )



    spec:RegisterSetting( "mfd_points", 3, {
        name = "|T236340:0|t Marked for Death Combo Points",
        desc = "The addon will only recommend |T236364:0|t Marked for Death when you have the specified number of combo points or fewer.",
        type = "range",
        min = 0,
        max = 5,
        step = 1,
        width = "full"
    } )

    spec:RegisterSetting( "priority_rotation", false, {
        name = "Use Priority Rotation (Funnel Damage)",
        desc = "If checked, the default priority will recommend building combo points with |T1375677:0|t Shuriken Storm and spending on single-target finishers.",
        type = "toggle",
        width = "full"
    })

    spec:RegisterSetting( "solo_vanish", true, {
        name = "Allow |T132331:0|t Vanish when Solo",
        desc = "If unchecked, the addon will not recommend |T132331:0|t Vanish when you are alone (to avoid resetting combat).",
        type = "toggle",
        width = "full"
    } )

    spec:RegisterSetting( "allow_shadowmeld", nil, {
        name = "Allow |T132089:0|t Shadowmeld",
        desc = "If checked, |T132089:0|t Shadowmeld can be recommended for Night Elves when its conditions are met.  Your stealth-based abilities can be used in Shadowmeld, even if your action bar does not change.  " ..
            "Shadowmeld can only be recommended in boss fights or when you are in a group (to avoid resetting combat).",
        type = "toggle",
        width = "full",
        get = function () return not Hekili.DB.profile.specs[ 261 ].abilities.shadowmeld.disabled end,
        set = function ( _, val )
            Hekili.DB.profile.specs[ 261 ].abilities.shadowmeld.disabled = not val
        end,
    } )    


    spec:RegisterPack( "Subtlety", 20210916, [[devEgcqiuP8ikLSjkvFsrIrPsYPuu1QOuQ8kfPMfjYTiHYUuXVqLyyKOCmsWYGs8mvs10qL01ir12ujfFtrOmouPkoNIqL1Psv18uPY9qf7JsX)iHQQdIkv1cHs6HksAIKqUOkvrTrfH8ruPknssOQCsvQcRek1ljHQ0mrLkDtsOYovu5Nukv1qPuklvLu6PO0uveDvuPITsPuLVQsvASQuvoljufTxj9xjgmvhw0IH0JvyYK6YiBgIpdfJgfNwQvRsvKxROmBkUnjTBGFR0WrvhxrOQLd65QA6cxhQ2oL03PeJxrW5vjwpjufMVkL9tCvH6KvwDguDoSOmSOGckOW1pkOmUQmUILkBCHNQS85ywIHQSGuLQSS4OHHIlvw(8IztDDYk7V4WbvzzIG)VFUWfmDWGJEgRkx(wf3KrVGbmrcU8T6Glvwu82e3dqfTYQZGQZHfLHffuqbfU(rbLXvLXvfQSjEWSWklBRo1kltR1eOIwz10pQSS4OHHIlIFTlgCsWEU1kPIsqXv46kjowugwuqWwWEQmjad93VGTIjUIBTsIBnHDIAOd(tfEyVWoUuGBKrVaXX5f)xX7q8(f)PqCuczHK4wiXXFs8ooc2kM4tDvrBajUkUjAEdj(inMsoIEbft)H4eiGn9IhR4qsJpiX53GarNgXHKLfo7iyRyIR4YzK4tKHEMbmrcXBqqqioFiEdeFSQOziEJiUfs87j8pex3AX7qCKfkU11KrBOYVgReiovwt)XxNSY(bLMGH01jRZPqDYklbsudPRyTYMJOxqL9zs9A5dypJQSA6hWMp6fuzVhiIZguAcgUynb9ZiEcjXX5vsC8NeNLj1RLpG9ms8yfhLaeshIJaxvXdgsC(8)2kjo6cWFXtGw8jQbAXVxkNbO)vsCYkbeVre3cjEcjXZqC1CcIpvBt8RWbg6FXX)gGrCfx(bbfN7)F(FdMVYoGDqWoRSxjokocY5dknbZbNx8B3ehfhb5ynb9ZCW5fFEXTl(vI)8KXuIeIHI)8m4WEgbkFSqvXVtCUk(TBIBnHDIAOd(tfEyVWoUuGBKrVaXNxC7IRMFqWs(F(FdkqsnBWlohXvwnQZHL6KvwcKOgsxXALvt)a28rVGk7e1G(zepdX560IpvBtClDWS4H4kIvjXv(0IBPdgXveRsINaT4xJ4w6GrCfXkEIeeuCBVe0ptLnhrVGk7inMsoIEbft)rLDa7GGDwzTMWorn0HqqOr0wPYyvr3c)2G4f3goIp4lQ5ekppb0IF7M4O4iiNNbh2Ziqjwii17bNxC7Ipwv0TWVni(JMq6rhIFhhXXI43Uj(Ztgtjsigk(ZZGd7zeO8Xcvf3goIZvXTlU1e2jQHoeccnI2kvgRk6w43geV42WrCUk(TBIpwv0TWVni(JMq6rhIFhhXvqCft8RepsdbIJMiEcw(aMrIHupeirnKwC7IJIJGCSMG(zo48IpFL10FuaPkvzrAq)m1Oo31RtwzjqIAiDfRv2bSdc2zL9dknbdPppX)9lUDXFEYykrcXqXFEgCypJaLpwOQ43joxRS5i6fuzFMuVw(a2ZOAuNJR1jRSeirnKUI1k7a2bb7SYgPHaXb0yyIpsZmcEiqIAiT42fhIdiKfIHordUuIDc9OGAsnDiqIAiT42f)5jJPejedf)5zWH9mcu(yHQIFN4kVYMJOxqL9zAR1OoNYRtwzjqIAiDfRv2Ce9cQSptQxlFa7zuLDCzyOsKqmu815uOYoGDqWoRSCtCRjStudDWFQWd7f2XLcCJm6fiUDX1ekocYbPb6IfkNbO)pqsnBWl(DIRG42f)5jJPejedf)5zWH9mcu(yHQIFhhXVU42fpsigkorRsLyl6MexXehsQzdEXTr8RPYQPFaB(OxqLL7WlESIFDXJeIHIx8RaR48WENx8zeXlooV4tud0IFVuodq)lo6fXhxgMgGrCwMuVw(a2ZOtnQZDn1jRSeirnKUI1kBoIEbv2Nj1RLpG9mQYQPFaB(OxqLDIwO48WEHDCrC4gz0lqjXXFsCwMuVw(a2ZiXxReuC2yHQIBPdgXVxfN4jMSbFiooV4XkoxfpsigkEXxO4nI4t09kE)IdXbGgGr8fbr8RwG4j4I4P6IdcXxeXJeIHIF(k7a2bb7SYAnHDIAOd(tfEyVWoUuGBKrVaXTl(vIRjuCeKdsd0fluodq)FGKA2Gx87exbXVDt8ineiowOKFbQ5he8qGe1qAXTl(Ztgtjsigk(ZZGd7zeO8Xcvf)ooIZvXNVg15My1jRSeirnKUI1k7a2bb7SY(8KXuIeIHIxCB4i(1fFAXVsCuCeKtWqf4gbbo48IF7M4qCaHSqm0jNLjS)YV4MccmXOsG4qGe1qAXNxC7IFL4O4iiN)Ik6A(YIu0ugmLep2bSJdoV43Ujo3ehfhb5Wdjvs3rg9co48IF7M4ppzmLiHyO4f3goIRCXNVYMJOxqL9zWH9mcu(yHQ1Ooh3tDYklbsudPRyTYMJOxqL9zs9A5dypJQSA6hWMp6fuzzzs9A5dypJepwXHecKEgXNOgOf)EPCgG(x8eOfpwXjWJdjXTqIpsG4JecVi(ALGINIJGBmIpr3R4niwXdgsCanHqC2vrI3iIZV)3Og6uzhWoiyNvwnHIJGCqAGUyHYza6)dKuZg8IFhhXvq8B3eFSRrVwaN)Ik6A(YIu0ugmhiPMn4f)oXvG7rC7IRjuCeKdsd0fluodq)FGKA2Gx87eFSRrVwaN)Ik6A(YIu0ugmhiPMn4RrDUjU6KvwcKOgsxXALDa7GGDwzrXrqo8eezHzq6IvQb)5JCmtCB4iUYf3U4JfOX74WtqKfMbPlwPg8hycMjUnCexHRxzZr0lOYIXSRkQj1unQZPGYQtwzZr0lOY(mPET8bSNrvwcKOgsxXAnQZPGc1jRSeirnKUI1k7a2bb7SYYnXJeIHIt)f09FXTl(yvr3c)2G4pAcPhDiUnCexbXTlokocY5z2O0GsWqfDcNDW5f3U4eGGyUCIwLkXw4QYe3gXXm0h1Ccv2Ce9cQSdgk5lpZg1OgvwnHK4MOozDofQtwzZr0lOYoRhZQSeirnKUI1AuNdl1jRSeirnKUI1k7YxzFkQS5i6fuzTMWornuL1AAWPklkocY5n9Gkjqx09Go48IF7M4ppzmLiHyO4ppdoSNrGYhluvCB4i(1uz10pGnF0lOYYDEslESIRPGGQnGe3cdfmeu8XUg9Ab8IBj7qCKfkolqrIJMpPfFbIhjedf)PYAnHfqQsv2hOlJfO7OxqnQZD96KvwcKOgsxXALD5RSpfv2Ce9cQSwtyNOgQYAnn4uLLqqOr0wPYyvr3c)2G4RSA6hWMp6fuz5(JXIdcXrwO4SmtkoKYr0lq8OvjXrViEJbSWgGrCZArXMQTjEcA1CWKqmKwC1mgm0lEdepyiXv2r5V48qAqKUbyepfNFdceDAeNLzsX5H7OYAnHfqQsvwcbHgrBLkJvfDl8BdIVg154ADYklbsudPRyTYU8v2NIkBoIEbvwRjStudvzTMgCQYowv0TWVni(k7a2bb7SYowReibXz2fyNaXTloHGqJOTsLXQIUf(TbXlUnIpwv0TWVniEXTl(yvr3c)2G4pAcPhDiUnIJfXTlE0Quj2YZehUk(DIRSJYf3U4Ct8ReFSQOBHFBq8IZrCSiUDXrXrqo0GzBaMcK4HTAc0LRFW5f)2nXhRk6w43geV4Ce)6IBxCuCeKdny2gGPajEyRMaDHRhCEXVDt8XQIUf(TbXlohX5Q42fhfhb5qdMTbykqIh2Qjqxu(bNx85RSwtybKQuLLqqOr0wPYyvr3c)2G4RrDoLxNSYsGe1q6kwRSlFL9POYMJOxqL1Ac7e1qvwRPbNQS8WEHDCPa3iJEbIBx8NNmMsKqmu8NNbh2Ziq5JfQkUnCehlvwn9dyZh9cQS2(aZfXhmjadjoCJm6fiEJiUfsCM0kjopSxyhxkWnYOxG4pfINaT4Q4MO5nK4rcXqXloo)PYAnHfqQsvw8Nk8WEHDCPa3iJEb1Oo31uNSYsGe1q6kwRSlFL9POYMJOxqL1Ac7e1qvwRPbNQSyr5IpT4rAiqCS2yw4HajQH0IB7ehlkt8PfpsdbIJA(bblls5zs9A5peirnKwCBN4yrzIpT4rAiqCEMuVwki7a)peirnKwCBN4yr5IpT4rAiqCstoGDC5qGe1qAXTDIJfLj(0IJfLlUTt8Re)5jJPejedf)5zWH9mcu(yHQIBdhX5Q4Zxz10pGnF0lOYYDEslESIRjKgqIBHHaIhR44pj(huAcgXNQIEXxO4O4TrtWVYAnHfqQsv2pO0emLGbspZA01Oo3eRozLLajQH0vSwz10pGnF0lOYovgAmt8PQOx8mehPHFuzZr0lOYosJPKJOxqX0Fuzn9hfqQsv2H(RrDoUN6KvwcKOgsxXALvt)a28rVGk71Idehb3yUi(BPJbd9IhR4bdjoBqPjyiT4x7gz0lq8RqViUEBagX)vjX7qCKfoOxC(DnnaJ4nI4GnyAagX7x80A2Me1qZFQS5i6fuzH4GsoIEbft)rLDa7GGDwz)GstWq6tAmvwt)rbKQuL9dknbdPRrDUjU6KvwcKOgsxXALnhrVGk7B6bvsGUO7bvz10pGnF0lOYY955nxeN10ds8eOfxr9GepdXXY0IpvBtCnoSbyepyiXrA4hIRGYe)PXc0VsINibbfpyYqCUoT4t12eVreVdXPjW3q6f3shmnq8GHehqtieN7DQks8fkE)Id2qCC(k7a2bb7SY(8KXuIeIHI)8m4WEgbkFSqvXVt8RrC7IJ0yyIcKuZg8IBJ4xJ42fhfhb58MEqLeOl6EqhiPMn4f)oXXm0h1CcIBx8XQIUf(TbXlUnCeNRIRyIFL4rRsIFN4kOmXNxCBN4yPg15uqz1jRSeirnKUI1kRM(bS5JEbvwBd2lSJlIFTBKrVaf)IZDPykV4yARK4P4dyYlEIU4H4eGGyUioYcfpyiX)GstWi(uv0l(vO4TrtqX)OngXH0ZtJq8oM)iUIN48kjEhIpsG4OK4btgI)TkVHov2Ce9cQSJ0yk5i6fum9hv2pG9iQZPqLDa7GGDwzTMWorn0b)PcpSxyhxkWnYOxqL10FuaPkvz)GstWug6Vg15uqH6KvwcKOgsxXALvt)a28rVGk7uxW3Acko(3amINIZguAcgXNQIe3cdbehs5GPbyepyiXjabXCr8GbspZA0v2Ce9cQSJ0yk5i6fum9hv2bSdc2zLLaeeZLJMq6rhIFhhXTMWorn05dknbtjyG0ZSgDL10FuaPkvz)GstWug6Vg15ual1jRSeirnKUI1k7a2bb7SYEL4wtyNOg6qii0iARuzSQOBHFBq8IBdhXh8f1CcLNNaAXNx8B3e)kXhRk6w43ge)rti9OdXVJJ4ki(TBIJ0yyIcKuZg8IFhhXvqC7IBnHDIAOdHGqJOTsLXQIUf(TbXlUnCe)6IF7M4O4iiN)Ik6A(YIu0ugmLep2bSJdoV42f3Ac7e1qhcbHgrBLkJvfDl8BdIxCB4ioxfFEXVDt8Re)5jJPejedf)5zWH9mcu(yHQIBdhX5Q42f3Ac7e1qhcbHgrBLkJvfDl8BdIxCB4ioxfF(kBoIEbv2rAmLCe9ckM(JkRP)OasvQYI0G(zQrDofUEDYklbsudPRyTYQPFaB(OxqLL78K4P4O4TrtqXTWqaXHuoyAagXdgsCcqqmxepyG0ZSgDLnhrVGk7inMsoIEbft)rLDa7GGDwzjabXC5OjKE0H43XrCRjStudD(GstWucgi9mRrxzn9hfqQsvwu82ORrDof4ADYklbsudPRyTYMJOxqLnHJeqLyHqcevwn9dyZh9cQSC31c9H48WEHDCr8giEAmIViIhmK4CFBJ7kokns8NeVdXhj(tV4P4CVtvrv2bSdc2zLLaeeZLJMq6rhIBdhXvq5IpT4eGGyUCGegcuJ6CkO86Kv2Ce9cQSjCKaQWJBEQYsGe1q6kwRrDofUM6Kv2Ce9cQSMgdt8L7jCngvcevwcKOgsxXAnQZPWeRozLnhrVGklAIPSiLa2JzFLLajQH0vSwJAuz5H0yvrZOozDofQtwzZr0lOYM88Mlf(T)fuzjqIAiDfR1OohwQtwzZr0lOYIUryiDbXKxiTLgGPe7eAqLLajQH0vSwJ6CxVozLLajQH0vSwzhWoiyNv2FXnOnqF4X)a3qfcIZh9coeirnKw8B3e)xCdAd0hRRjJ2qLFnwjqCiqIAiDLnhrVGklIHEMbmrIAuNJR1jRS5i6fuz)GstWuzjqIAiDfR1OoNYRtwzjqIAiDfRv2Ce9cQSQjCgPlilSOPmyQS8qASQOzuEASa9xzvq51Oo31uNSYsGe1q6kwRS5i6fuzFtpOsc0fDpOk7a2bb7SYcjei9mjQHQS8qASQOzuEASa9xzvOg15My1jRSeirnKUI1k7a2bb7SYcXbeYcXqh1eoRSiLGHkQ5heSK)N)3GdbsudPRS5i6fuzFMuVwkOMutFnQrLfPb9ZuNSoNc1jRSeirnKUI1k7YxzFkQS5i6fuzTMWornuL1AAWPkBKgcehEiPs6oYOxWHajQH0IBx8NNmMsKqmu8NNbh2Ziq5JfQk(DIFL4kxCft8XALajioaAaxZc1IpV42fNBIpwReibXz2fyNGkRM(bS5JEbv27LPnK44FdWiUTbjvs3rg9cus8062AXh5hnaJ4SMEqINaT4kQhK4wyiG4SmPETiUIsWGeVFX)DbIhR4OK44pPvsCAcdIpehzHIR49cStqL1AclGuLQS8qsL0LhOlJfO7OxqnQZHL6KvwcKOgsxXALDa7GGDwz5M4wtyNOg6WdjvsxEGUmwGUJEbIBx8NNmMsKqmu8NNbh2Ziq5JfQk(DIFnIBxCUjokocY5zs9APOtWGo48IBxCuCeKZB6bvsGUO7bDGKA2Gx87ehPXWefiPMn4f3U4qcbsptIAOkBoIEbv230dQKaDr3dQg15UEDYklbsudPRyTYoGDqWoRSwtyNOg6WdjvsxEGUmwGUJEbIBx8XUg9AbCEMuVwk6emOZGjHyOVGaZr0linIFN4kCMykxC7IJIJGCEtpOsc0fDpOdKuZg8IFN4JDn61c48xurxZxwKIMYG5aj1SbV42f)kXh7A0RfW5zs9APOtWGoqk1xe3U4O4iiN)Ik6A(YIu0ugmhiPMn4fxXehfhb58mPETu0jyqhiPMn4f)oXv4GfXNVYMJOxqL9n9Gkjqx09GQrDoUwNSYsGe1q6kwRSlFL9POYMJOxqL1Ac7e1qvwRPbNQSQ5heSK)N)3GcKuZg8IBJ4kt8B3eNBIhPHaXb0yyIpsZmcEiqIAiT42fpsdbIJoHZkptQxlhcKOgslUDXrXrqoptQxlfDcg0bNx8B3e)5jJPejedf)5zWH9mcu(yHQIBdhX5ALvt)a28rVGkRIpYWtqXT9syNOgsCKfk(1IZh4q6io7SMxCnoSbyexXLFqqX5()N)3aXxO4ACydWiUIsWGe3shmIROeot8eOfhSIpxJHj(inZi4PYAnHfqQsv2FwZxG48boKQrDoLxNSYsGe1q6kwRS5i6fuzH48boKQSA6hWMp6fuzv8seV448IFT48boKeVreVdX7x8eDXdXJvCioq8fpov2bSdc2zL9kX5M4wtyNOg68ZA(ceNpWHK43UjU1e2jQHo4pv4H9c74sbUrg9ceFEXTlEKqmuCIwLkXw0njUIjoKuZg8IBJ4xJ42fhsiq6zsudvJ6CxtDYkBoIEbv2Ngqkkbnya9epovzjqIAiDfR1Oo3eRozLLajQH0vSwzZr0lOYcX5dCivzhxggQejedfFDofQSdyheSZkl3e3Ac7e1qNFwZxG48boKe3U4CtCRjStudDWFQWd7f2XLcCJm6fiUDXFEYykrcXqXFEgCypJaLpwOQ42WrCSiUDXJeIHIt0Quj2IUjXTHJ4xjUYfFAXVsCSiUTt8XQIUf(TbXl(8IpV42fhsiq6zsudvz10pGnF0lOYQ4WnrR3iAagXJeIHIx8GjdXT0gJ4M2kjoYcfpyiX14Wm6fi(Ii(1IZh4qsjXHecKEgX14WgGrC(eOj1ECQrDoUN6KvwcKOgsxXALnhrVGkleNpWHuLvt)a28rVGk71siq6ze)AX5dCijoLqZfXBeX7qClTXionb(gsIRXHnaJ4SxurxZFexrR4btgIdjei9mI3iIZUksCmu8IdPuFr8giEWqIdOjeIR8)uzhWoiyNvwUjU1e2jQHo)SMVaX5dCijUDXHKA2Gx87eFSRrVwaN)Ik6A(YIu0ugmhiPMn4fFAXvqzIBx8XUg9AbC(lQOR5llsrtzWCGKA2Gx874iUYf3U4rcXqXjAvQeBr3K4kM4qsnBWlUnIp21OxlGZFrfDnFzrkAkdMdKuZg8IpT4kVg15M4QtwzjqIAiDfRv2bSdc2zLLBIBnHDIAOd(tfEyVWoUuGBKrVaXTl(ZtgtjsigkEXTHJ4xVYMJOxqLf1KJzf(1IMG1OoNckRozLnhrVGklzT)bbZGQSeirnKUI1AuJk7q)1jRZPqDYklbsudPRyTYoGDqWoRSCtCuCeKZZK61srNGbDW5f3U4O4iiNNbh2Ziqjwii17bNxC7IJIJGCEgCypJaLyHGuVhiPMn4f)ooIF9JYRS4pvweKcMHUoNcv2Ce9cQSptQxlfDcguLvt)a28rVGkl35jXvucgK4lcIIHzOfhLqwijEWqIJ0Wpe)zWH9mcu(yHQIJaxvXNCHGuVIpwv6fVbNAuNdl1jRSeirnKUI1k7a2bb7SYIIJGCEgCypJaLyHGuVhCEXTlokocY5zWH9mcuIfcs9EGKA2Gx874i(1pkVYI)uzrqkyg66CkuzZr0lOY(xurxZxwKIMYGPYQPFaB(OxqL9kUdWq)lEAGuQViooV4O0iXFsClK4XUZeNLj1RfXNODG)Zlo(tIZErfDnV4lcIIHzOfhLqwijEWqIJ0WpeNLbh2ZiG4SXcvfhbUQIp5cbPEfFSQ0lEdo1Oo31RtwzjqIAiDfRv2bSdc2zL1Ac7e1qNhOlJfO7OxG42fNBI)bLMGH0h1eegsC7IJIJGC(lQOR5llsrtzWCW5f3U4JvfDl8BdIxCB4iUYRS5i6fuzrmjgYyYOxqnQZX16KvwcKOgsxXALDa7GGDwzVsCioGqwig6OMWzLfPemurn)GGL8)8)gCiqIAiT42fFSQOBHFBq8hnH0Joe)ooIRG4kM4rAiqC0eXtWYhWmimK6HajQH0IF7M4qCaHSqm0rtzWyUuEMuVw(dbsudPf3U4JvfDl8BdIx87exbXNxC7IJIJGC(lQOR5llsrtzWCW5f3U4O4iiNNj1RLIobd6GZlUDXvZpiyj)p)VbfiPMn4fNJ4ktC7IJIJGC0ugmMlLNj1RL)OxlGkBoIEbvwRjOFMAuNt51jRSeirnKUI1kRM(bS5JEbvwBBxJ4ilu8jxii1R48qsXyxfjULoyeNLrrIdPuFrClmeqCWgIdXbGgGrC2j6uzrwybqtiQZPqLDa7GGDwzJ0qG48m4WEgbkXcbPEpeirnKwC7IZnXJ0qG48mPETuq2b(FiqIAiDLnhrVGkl)UMcK(fhoOAuN7AQtwzjqIAiDfRv2Ce9cQSpdoSNrGsSqqQ3kRM(bS5JEbvwUZtIp5cbPEfNhsIZUksClmeqClK4mPvs8GHeNaeeZfXTWqbdbfhbUQIZVRPbye3shmlEio7ej(cf)Ec)dXXqacMgZLtLDa7GGDwzjabXCrCB4i(1OmXTlU1e2jQHopqxglq3rVaXTl(yxJETao)fv018LfPOPmyo48IBx8XUg9AbCEMuVwk6emOZGjHyOxCB4iUcIBx8ReNBIdXbeYcXqNfL0nbg0HajQH0IF7M4Acfhb5GysmKXKrVGdoV43Uj(Ztgtjsigk(ZZGd7zeO8Xcvf3goIFL4ki(0IZvXTDIFL4Ct8ineioGgdt8rAMrWdbsudPf3U4Ct8ineio6eoR8mPETCiqIAiT4Zl(8IpV42fFSQOBHFBq8IFhhXXI42f)kX5M4O4iihEiPs6oYOxWbNx8B3e)5jJPejedf)5zWH9mcu(yHQIBJ4Cv85f3U4xjo3eFSwjqcIJvcemxGIF7M4Ct8XUg9AbCqmjgYyYOxWbNx85RrDUjwDYklbsudPRyTYMJOxqL9jimdsxqxavE(EgvzhWoiyNvwRjStudDEGUmwGUJEbIBxCUjUEJZtqygKUGUaQ889mQO34e9ywdWiUDXJeIHIt0Quj2IUjXTHJ4yrbXTl(vIpwv0TWVni(JMq6rhIBdhXVs8bFbt2aXTrXV4Cv85fFEXTlo3ehfhb58m4WEgbkXcbPEp48IBx8ReNBIJIJGC4HKkP7iJEbhCEXVDt8NNmMsKqmu8NNbh2Ziq5JfQkUnIZvXNx8B3ehPXWefiPMn4f)ooIRCXTl(Ztgtjsigk(ZZGd7zeO8Xcvf)oXVELDCzyOsKqmu815uOg154EQtwzjqIAiDfRv2bSdc2zL1Ac7e1qNhOlJfO7OxG42fFSQOBHFBq8hnH0Joe3goIRqLnhrVGk7t8F)1Oo3exDYklbsudPRyTYMJOxqL9VOIUMVSifnLbtLvt)a28rVGkl35jXzVOIUMx8fi(yxJETae)QejiO4in8dXzbkAEXXbg6FXTqINqsCmBdWiESIZV8Ip5cbPEfpbAX1R4GneNjTsIZYK61I4t0oW)tLDa7GGDwzTMWorn05b6Yyb6o6fiUDXVs8ineioeWkzw(gGP8mPET8hcKOgsl(TBIp21OxlGZZK61srNGbDgmjed9IBdhXvq85f3U4xjo3epsdbIZZGd7zeOeleK69qGe1qAXVDt8ineioptQxlfKDG)hcKOgsl(TBIp21OxlGZZGd7zeOeleK69aj1SbV42ioweFEXTl(vIZnXhRvcKG4yLabZfO43Uj(yxJETaoiMedzmz0l4aj1SbV42iUckt8B3eFSRrVwahetIHmMm6fCW5f3U4JvfDl8BdIxCB4iUYfF(AuNtbLvNSYsGe1q6kwRS5i6fuzvt4msxqwyrtzWuznnGkdDLvHJYRSJlddvIeIHIVoNcv2bSdc2zLfMTUqwjqCsT(p48IBx8RepsigkorRsLyl6Me)oXhRk6w43ge)rti9OdXVDtCUj(huAcgsFsJrC7Ipwv0TWVni(JMq6rhIBdhXh8f1CcLNNaAXNVYQPFaB(OxqL9EGiEQ1V4jKehNxjXFqZtIhmK4lGe3shmIBwl0hIp5Kk6io35jXTWqaX1xAagXrYpiO4btceFQ2M4AcPhDi(cfhSH4FqPjyiT4w6GzXdXtWfXNQTDQrDofuOozLLajQH0vSwzZr0lOYQMWzKUGSWIMYGPYQPFaB(OxqL9EGioyfp16xClTXiUUjXT0btdepyiXb0ecXVUYELeh)jXvCiks8fio6(V4w6GzXdXtWfXNQTDQSdyheSZklmBDHSsG4KA9FAG42i(1vM4kM4WS1fYkbItQ1)rJdZOxG42fFSQOBHFBq8hnH0Joe3goIp4lQ5ekppb01OoNcyPozLLajQH0vSwzhWoiyNvwRjStudDEGUmwGUJEbIBx8XQIUf(TbXF0esp6qCB4iowe3U4xjokocY5VOIUMVSifnLbZbNx8B3ehD)xC7IJ0yyIcKuZg8IFhhXXIYeF(kBoIEbv2Nj1RLcQj10xJ6CkC96KvwcKOgsxXALDa7GGDwzTMWorn05b6Yyb6o6fiUDXhRk6w43ge)rti9OdXTHJ4yrC7IFL4wtyNOg6G)uHh2lSJlf4gz0lq8B3e)5jJPejedf)5zWH9mcu(yHQIFhhX5Q43UjoehqiledDG0V4aDdWugMe2XLdbsudPfF(kBoIEbvwAWSnatbs8Wwnb6AuNtbUwNSYsGe1q6kwRS5i6fuzFgCypJaLyHGuVvwn9dyZh9cQS3BhmIZorkjEJioydXtdKs9fX1lGusC8NeFYfcs9kULoyeNDvK448Nk7a2bb7SYgPHaX5zs9APGSd8)qGe1qAXTlU1e2jQHopqxglq3rVaXTlokocY5VOIUMVSifnLbZbNxC7Ipwv0TWVniEXVJJ4yrC7IFL4CtCuCeKdpKujDhz0l4GZl(TBI)8KXuIeIHI)8m4WEgbkFSqvXTrCUk(81OoNckVozLLajQH0vSwzhWoiyNvwUjokocY5zs9APOtWGo48IBxCKgdtuGKA2Gx874io3J4tlEKgceNhhniicog6qGe1q6kBoIEbv2Nj1RLIobdQg15u4AQtwzjqIAiDfRv2bSdc2zL9kX)f3G2a9Hh)dCdviioF0l4qGe1qAXVDt8FXnOnqFSUMmAdv(1yLaXHajQH0IpV42fNaeeZLJMq6rhIBdhXVUYe3U4Ct8pO0emK(KgJ42fhfhb58xurxZxwKIMYG5OxlGkBdcccX5JsJuz)f3G2a9X6AYOnu5xJvcev2geeeIZhLwvL0DguLvHkBoIEbvwed9mdyIev2geeeIZhfmMfnnvwfQrDofMy1jRSeirnKUI1k7a2bb7SYIIJGCqn7Qn4FCGuocXVDtCKgdtuGKA2Gx87e)6kt8B3ehfhb58xurxZxwKIMYG5GZlUDXVsCuCeKZZK61sb1KA6p48IF7M4JDn61c48mPETuqnPM(dKuZg8IFhhXvqzIpFLnhrVGkl)g9cQrDof4EQtwzjqIAiDfRv2bSdc2zLffhb58xurxZxwKIMYG5GZxzZr0lOYIA2vxqWHxQrDofM4QtwzjqIAiDfRv2bSdc2zLffhb58xurxZxwKIMYG5GZxzZr0lOYIsWNGZAaMAuNdlkRozLLajQH0vSwzhWoiyNvwuCeKZFrfDnFzrkAkdMdoFLnhrVGklsdjuZU6AuNdlkuNSYsGe1q6kwRSdyheSZklkocY5VOIUMVSifnLbZbNVYMJOxqLnbd6dyAkJ0yQrDoSGL6KvwcKOgsxXALnhrVGkl(tLoi1VYQPFaB(OxqLvresIBcXrsJbnhZehzHIJ)jQHeVds9VFX5opjULoyeN9Ik6AEXxeXveLbZPYoGDqWoRSO4iiN)Ik6A(YIu0ugmhCEXVDtCKgdtuGKA2Gx87ehlkRg1OY(bLMGPm0FDY6CkuNSYsGe1q6kwRSlFL9POYMJOxqL1Ac7e1qvwRPbNQSJDn61c48mPETu0jyqNbtcXqFbbMJOxqAe3goIRWzIP8kRM(bS5JEbvwfFKHNGIB7LWornuL1AclGuLQSpJUemq6zwJUg15WsDYklbsudPRyTYMJOxqL1Ac6NPYQPFaB(OxqL12lb9ZiEJiUfs8esIpsE(gGr8fiUIsWGeFWKqm0Fe)EoHMlIJsilKehPHFiUobds8grClK4mPvsCWk(CngM4J0mJGIJIhIROeotCwMuVweVbIVqnbfpwXXqH4xloFGdjXX5f)kWkUIl)GGIZ9)p)VbZFQSdyheSZk7vIZnXTMWorn05z0LGbspZA0IF7M4Ct8ineioGgdt8rAMrWdbsudPf3U4rAiqC0jCw5zs9A5qGe1qAXNxC7Ipwv0TWVni(JMq6rhIBJ4kiUDX5M4qCaHSqm0rnHZklsjyOIA(bbl5)5)n4qGe1q6AuN761jRSeirnKUI1kRM(bS5JEbvwBBxJ4iluCwMuVwujJw8PfNLj1RLpG9msCCGH(xClK4jKeprx8q8yfFK8IVaXvucgK4dMeIH(J42(aZfXTWqaXNOgOf)EPCgG(x8(fprx8q8yfhIdeFXJtLfzHfanHOoNcv2bSdc2zLfMd6aAmmrHmivwAcbmlP6IdIklxvwLnhrVGkl)UMcK(fhoOAuNJR1jRSeirnKUI1k7a2bb7SYsacI5I42WrCUQmXTlobiiMlhnH0Joe3goIRGYe3U4CtCRjStudDEgDjyG0ZSgT42fFSQOBHFBq8hnH0Joe3gXvqC7IRjuCeKdsd0fluodq)FGKA2Gx87exHkBoIEbv2Nj1RfvYORrDoLxNSYsGe1q6kwRSlFL9POYMJOxqL1Ac7e1qvwRPbNQSJvfDl8BdI)OjKE0H42WrCSi(0IJIJGCEMuVwkOMut)bNVYQPFaB(OxqLDQ2M4bdKEM1OFXrwO4eiiydWioltQxlIROemOkR1ewaPkvzFgDzSQOBHFBq81Oo31uNSYsGe1q6kwRSlFL9POYMJOxqL1Ac7e1qvwRPbNQSJvfDl8BdI)OjKE0H42Wr8RxzhWoiyNv2XALajioZUa7euzTMWcivPk7ZOlJvfDl8BdIVg15My1jRSeirnKUI1k7YxzFkQS5i6fuzTMWornuL1AAWPk7yvr3c)2G4pAcPhDi(DCexHk7a2bb7SYAnHDIAOd(tfEyVWoUuGBKrVaXTl(Ztgtjsigk(ZZGd7zeO8Xcvf3goIZ1kR1ewaPkvzFgDzSQOBHFBq81Ooh3tDYklbsudPRyTYMJOxqL9zs9APOtWGQSA6hWMp6fuzvucgK4ACydWio7fv018IVqXt01kjEWaPNzn6tLDa7GGDwzTMWorn05z0LXQIUf(TbXlUDXVsCRjStudDEgDjyG0ZSgT43UjokocY5VOIUMVSifnLbZbsQzdEXTHJ4kCWI43UjokocYzWK7xqtaDW5f)2nXFEYykrcXqXFEgCypJaLpwOQ42WrCUkUDXh7A0RfW5VOIUMVSifnLbZbsQzdEXTrCfuM4ZlUDXVsCuCeKdpbrwygKUyLAWF(ihZe)oX5Q43Uj(Ztgtjsigk(ZZGd7zeO8Xcvf3gXXI4ZxJ6CtC1jRSeirnKUI1kBoIEbv2Nj1RLIobdQYQPFaB(OxqLfR4qG4qsnBqdWiUIsWGEXrjKfsIhmK4ingMqCcOFXBeXzxfjULfmLqCusCiL6lI3aXJwLov2bSdc2zL1Ac7e1qNNrxgRk6w43geV42fhPXWefiPMn4f)oXh7A0RfW5VOIUMVSifnLbZbsQzd(AuJklkEB01jRZPqDYklbsudPRyTYoGDqWoRSCt8ineioGgdt8rAMrWdbsudPf3U4qCaHSqm0jAWLsStOhfutQPdbsudPf3U4ppzmLiHyO4ppdoSNrGYhluv87ex5v2Ce9cQSptBTg15WsDYklbsudPRyTYoGDqWoRSppzmLiHyO4f3goIJfXTl(vIZnXhRvcKG4aObCnlul(TBIp21OxlGZtqygKUGUaQ889m6OMtOmysig6fxXeFWKqm0xqG5i6fKgXTHJ4k7GfLl(TBI)8KXuIeIHI)8m4WEgbkFSqvXTrCUk(8IBxCuCeKdpbrwygKUyLAWF(ihZe)ooIZ1kBoIEbv2Nbh2Ziq5JfQwJ6CxVozLLajQH0vSwzhWoiyNv2XUg9AbCEccZG0f0fqLNVNrh1CcLbtcXqV4kM4dMeIH(ccmhrVG0i(DCexzhSOCXVDt8FXnOnqFmuQlOxk0esvEdDiqIAiT42fNBIJIJGCmuQlOxk0esvEdDW5f)2nX)f3G2a9zgzTbFzxfpitdWCiqIAiT42fNBIRjuCeKZmYAd(IfygmhC(kBoIEbv2NGWmiDbDbu557zunQZX16Kv2Ce9cQSym7QIAsnvzjqIAiDfR1OoNYRtwzZr0lOYIMJzFKOvwcKOgsxXAnQrnQSwj43lOohwugwuqztCkCnvwlje0amFL9E5(x7C3J54EVFXfFsgs8wLFHH4ilu8P8bLMGH0trCinXJ3qsl(VQK4jESQzqAXhmjad9hbBUBdiX569l(uxGvcgKw8PaXbeYcXqN7BkIhR4tbIdiKfIHo33HajQH0tr8RuycZFeS5UnGeFID)Ip1fyLGbPfFkqCaHSqm05(MI4Xk(uG4aczHyOZ9DiqIAi9ue)kfMW8hbBb77L7FTZDpMJ79(fx8jziXBv(fgIJSqXNcpKgRkAgtrCinXJ3qsl(VQK4jESQzqAXhmjad9hbBUBdiXV(9l(uxGvcgKw8P8lUbTb6Z9nfXJv8P8lUbTb6Z9DiqIAi9ue)kfMW8hbBUBdiXV(9l(uxGvcgKw8P8lUbTb6Z9nfXJv8P8lUbTb6Z9DiqIAi9uepdXVNT95UIFLcty(JGn3TbK4tS7x8PUaRemiT4tbIdiKfIHo33uepwXNcehqiledDUVdbsudPNI4zi(9STp3v8RuycZFeSfSVxU)1o39yoU37xCXNKHeVv5xyioYcfFkd9pfXH0epEdjT4)QsIN4XQMbPfFWKam0FeS5UnGeNR3V4tDbwjyqAXNcehqiledDUVPiESIpfioGqwig6CFhcKOgspfXVclty(JGn3TbK4xZ9l(uxGvcgKw8PaXbeYcXqN7BkIhR4tbIdiKfIHo33HajQH0tr8RuycZFeS5UnGexHRF)Ip1fyLGbPfFkqCaHSqm05(MI4Xk(uG4aczHyOZ9DiqIAi9ue)kfMW8hbBUBdiXv4AUFXN6cSsWG0IpLFXnOnqFUVPiESIpLFXnOnqFUVdbsudPNI4xHLjm)rWwW(E5(x7C3J54EVFXfFsgs8wLFHH4ilu8P8bLMGPm0)uehst84nK0I)RkjEIhRAgKw8btcWq)rWM72asCSC)Ip1fyLGbPfFkqCaHSqm05(MI4Xk(uG4aczHyOZ9DiqIAi9uepdXVNT95UIFLcty(JGTG99Y9V25UhZX9E)Il(KmK4Tk)cdXrwO4tbfVn6PioKM4XBiPf)xvs8epw1miT4dMeGH(JGn3TbK4kC)Ip1fyLGbPfFkqCaHSqm05(MI4Xk(uG4aczHyOZ9DiqIAi9ue)kfMW8hbBb77Hk)cdsl(et8Ce9ce30F8hb7klpCrAdvzTLTeNfhnmuCr8RDXGtc22YwIp3ALurjO4kCDLehlkdlkiylyBlBj(uzsag6VFbBBzlXvmXvCRvsCRjStudDWFQWd7f2XLcCJm6fiooV4)kEhI3V4pfIJsilKe3cjo(tI3XrW2w2sCft8PUQOnGexf3enVHeFKgtjhrVGIP)qCceWMEXJvCiPXhK48BqGOtJ4qYYcNDeSTLTexXexXLZiXNid9mdyIeI3GGGqC(q8gi(yvrZq8grClK43t4FiUU1I3H4iluCRRjJ2qLFnwjqCeSfSTLTe32GKIn1vfndb7Ce9c(dpKgRkAgtZHljpV5sHF7Fbc25i6f8hEinwv0mMMdxq3imKUGyYlK2sdWuIDcnqWohrVG)WdPXQIMX0C4cIHEMbmrcLAeo)IBqBG(WJ)bUHkeeNp6fC72V4g0gOpwxtgTHk)ASsGqWohrVG)WdPXQIMX0C4YhuAcgb7Ce9c(dpKgRkAgtZHlQjCgPlilSOPmyuIhsJvfnJYtJfOFokOCb7Ce9c(dpKgRkAgtZHlVPhujb6IUhKs8qASQOzuEASa9ZrbLAeoqcbsptIAib7Ce9c(dpKgRkAgtZHlptQxlfutQPxPgHdehqiledDut4SYIucgQOMFqWs(F(FdeSfSTLTexXLnq8RDJm6fiyNJOxWZzwpMjyBlX5opPfpwX1uqq1gqIBHHcgck(yxJETaEXTKDioYcfNfOiXrZN0IVaXJeIHI)iyNJOxWpnhUynHDIAiLaPkX5b6Yyb6o6fOK10GtCqXrqoVPhujb6IUh0bN)2TNNmMsKqmu8NNbh2Ziq5JfQAdNRrW2wIZ9hJfheIJSqXzzMuCiLJOxG4rRsIJEr8gdyHnaJ4M1IInvBt8e0Q5GjHyiT4QzmyOx8giEWqIRSJYFX5H0GiDdWiEko)gei60iolZKIZd3HGDoIEb)0C4I1e2jQHucKQehcbHgrBLkJvfDl8BdIxjRPbN4qii0iARuzSQOBHFBq8c25i6f8tZHlwtyNOgsjqQsCieeAeTvQmwv0TWVniELAeoJ1kbsqCMDb2jWoHGqJOTsLXQIUf(TbXBZyvr3c)2G4Tpwv0TWVni(JMq6rh2Gf7rRsLylptC46Dk7OC7C7QXQIUf(TbXZbl2rXrqo0GzBaMcK4HTAc0LRFW5VDBSQOBHFBq8CUUDuCeKdny2gGPajEyRMaDHRhC(B3gRk6w43gephUAhfhb5qdMTbykqIh2Qjqxu(bNFELSMgCIZyvr3c)2G4fSTL42(aZfXhmjadjoCJm6fiEJiUfsCM0kjopSxyhxkWnYOxG4pfINaT4Q4MO5nK4rcXqXloo)rWohrVGFAoCXAc7e1qkbsvId(tfEyVWoUuGBKrVaLSMgCIdpSxyhxkWnYOxG9NNmMsKqmu8NNbh2Ziq5JfQAdhSiyBlX5opPfpwX1esdiXTWqaXJvC8Ne)dknbJ4tvrV4luCu82Oj4lyNJOxWpnhUynHDIAiLaPkX5dknbtjyG0ZSgTswtdoXblkF6ineiowBml8qGe1qABhwu20rAiqCuZpiyzrkptQxl)HajQH02oSOSPJ0qG48mPETuq2b(FiqIAiTTdlkF6ineioPjhWoUCiqIAiTTdlkBASOCB3vppzmLiHyO4ppdoSNrGYhlu1goCDEbBBj(uzOXmXNQIEXZqCKg(HGDoIEb)0C4YinMsoIEbft)HsGuL4m0VGTTe)AXbIJGBmxe)T0XGHEXJv8GHeNnO0emKw8RDJm6fi(vOxexVnaJ4)QK4DioYch0lo)UMgGr8grCWgmnaJ49lEAnBtIAO5pc25i6f8tZHlqCqjhrVGIP)qjqQsC(GstWqALAeoFqPjyi9jngbBBjo3NN3CrCwtpiXtGwCf1ds8mehltl(uTnX14WgGr8GHehPHFiUckt8Nglq)kjEIeeu8GjdX560IpvBt8gr8oeNMaFdPxClDW0aXdgsCanHqCU3PQiXxO49loydXX5fSZr0l4NMdxEtpOsc0fDpiLAeoppzmLiHyO4ppdoSNrGYhlu9URXosJHjkqsnBWBZ1yhfhb58MEqLeOl6EqhiPMn4VdZqFuZjyFSQOBHFBq82WHRk2vrRs3PGYM32HfbBBjUTb7f2XfXV2nYOxGIFX5UumLxCmTvs8u8bm5fprx8qCcqqmxehzHIhmK4FqPjyeFQk6f)ku82OjO4F0gJ4q65PriEhZFexXtCELeVdXhjqCus8GjdX)wL3qhb7Ce9c(P5WLrAmLCe9ckM(dLaPkX5dknbtzOFL(a2JGJck1iCSMWorn0b)PcpSxyhxkWnYOxGGTTeFQl4Bnbfh)BagXtXzdknbJ4tvrIBHHaIdPCW0amIhmK4eGGyUiEWaPNznAb7Ce9c(P5WLrAmLCe9ckM(dLaPkX5dknbtzOFLAeoeGGyUC0esp64oowtyNOg68bLMGPemq6zwJwWohrVGFAoCzKgtjhrVGIP)qjqQsCqAq)mk1iCUYAc7e1qhcbHgrBLkJvfDl8BdI3god(IAoHYZta983UD1yvr3c)2G4pAcPhDChhfUDdPXWefiPMn4VJJc2TMWorn0HqqOr0wPYyvr3c)2G4THZ1VDdfhb58xurxZxwKIMYGPK4XoGDCW5TBnHDIAOdHGqJOTsLXQIUf(TbXBdhUo)TBx98KXuIeIHI)8m4WEgbkFSqvB4Wv7wtyNOg6qii0iARuzSQOBHFBq82WHRZlyBlX5opjEkokEB0euClmeqCiLdMgGr8GHeNaeeZfXdgi9mRrlyNJOxWpnhUmsJPKJOxqX0FOeivjoO4TrRuJWHaeeZLJMq6rh3XXAc7e1qNpO0emLGbspZA0c22sCU7AH(qCEyVWoUiEdepngXxeXdgsCUVTXDfhLgj(tI3H4Je)Px8uCU3PQib7Ce9c(P5WLeosavIfcjqOuJWHaeeZLJMq6rh2WrbLpnbiiMlhiHHac25i6f8tZHljCKaQWJBEsWohrVGFAoCX0yyIVCpHRXOsGqWohrVGFAoCbnXuwKsa7XSxWwW2w2sCSI3gnbFb7Ce9c(dkEB0CEM2QsnchUfPHaXb0yyIpsZmcEiqIAiTDioGqwig6en4sj2j0JcQj1K9NNmMsKqmu8NNbh2Ziq5JfQENYfSZr0l4pO4TrpnhU8m4WEgbkFSqvLAeoppzmLiHyO4THdwSFf3gRvcKG4aObCnluF72yxJETaopbHzq6c6cOYZ3ZOJAoHYGjHyOxXgmjed9feyoIEbPXgok7GfLF72Ztgtjsigk(ZZGd7zeO8XcvTHRZBhfhb5WtqKfMbPlwPg8NpYXS74Wvb7Ce9c(dkEB0tZHlpbHzq6c6cOYZ3ZiLAeoJDn61c48eeMbPlOlGkpFpJoQ5ekdMeIHEfBWKqm0xqG5i6fKM74OSdwu(TB)IBqBG(yOuxqVuOjKQ8g6qGe1qA7Cdfhb5yOuxqVuOjKQ8g6GZF72V4g0gOpZiRn4l7Q4bzAaMdbsudPTZnnHIJGCMrwBWxSaZG5GZlyNJOxWFqXBJEAoCbJzxvutQjb7Ce9c(dkEB0tZHlO5y2hjQGTGTTSL4tDxJETaEbBBjo35jXvucgK4lcIIHzOfhLqwijEWqIJ0Wpe)zWH9mcu(yHQIJaxvXNCHGuVIpwv6fVbhb7Ce9c(Zq)CEMuVwk6emiLWFQSiifmdnhfuQr4WnuCeKZZK61srNGbDW5TJIJGCEgCypJaLyHGuVhCE7O4iiNNbh2Ziqjwii17bsQzd(74C9JYfSTL4xXDag6FXtdKs9fXX5fhLgj(tIBHep2DM4SmPETi(eTd8FEXXFsC2lQOR5fFrqummdT4OeYcjXdgsCKg(H4Sm4WEgbeNnwOQ4iWvv8jxii1R4JvLEXBWrWohrVG)m0)0C4YFrfDnFzrkAkdgLWFQSiifmdnhfuQr4GIJGCEgCypJaLyHGuVhCE7O4iiNNbh2Ziqjwii17bsQzd(74C9JYfSZr0l4pd9pnhUGysmKXKrVaLAeowtyNOg68aDzSaDh9cSZTpO0emK(OMGWq2rXrqo)fv018LfPOPmyo482hRk6w43geVnCuUGDoIEb)zO)P5WfRjOFgLAeoxbXbeYcXqh1eoRSiLGHkQ5heSK)N)3a7JvfDl8BdI)OjKE0XDCuqXI0qG4OjINGLpGzqyi1dbsudPVDdIdiKfIHoAkdgZLYZK61YBFSQOBHFBq83PW82rXrqo)fv018LfPOPmyo482rXrqoptQxlfDcg0bN3UA(bbl5)5)nOaj1SbphLzhfhb5OPmymxkptQxl)rVwac22sCBBxJ4ilu8jxii1R48qsXyxfjULoyeNLrrIdPuFrClmeqCWgIdXbGgGrC2j6iyNJOxWFg6FAoCHFxtbs)IdhKsilSaOjeCuqPgHtKgceNNbh2Ziqjwii17HajQH025wKgceNNj1RLcYoW)dbsudPfSTL4CNNeFYfcs9kopKeNDvK4wyiG4wiXzsRK4bdjobiiMlIBHHcgckocCvfNFxtdWiULoyw8qC2js8fk(9e(hIJHaemnMlhb7Ce9c(Zq)tZHlpdoSNrGsSqqQxLAeoeGGyUydNRrz2TMWorn05b6Yyb6o6fyFSRrVwaN)Ik6A(YIu0ugmhCE7JDn61c48mPETu0jyqNbtcXqVnCuW(vCdIdiKfIHolkPBcmOB30ekocYbXKyiJjJEbhC(B3EEYykrcXqXFEgCypJaLpwOQnCUsHP5QT7kUfPHaXb0yyIpsZmcEiqIAiTDUfPHaXrNWzLNj1RLdbsudPNF(5Tpwv0TWVni(74Gf7xXnuCeKdpKujDhz0l4GZF72Ztgtjsigk(ZZGd7zeO8XcvTHRZB)kUnwReibXXkbcMlWB342yxJETaoiMedzmz0l4GZpVGDoIEb)zO)P5WLNGWmiDbDbu557zKsJlddvIeIHINJck1iCSMWorn05b6Yyb6o6fyNB6nopbHzq6c6cOYZ3ZOIEJt0JznaJ9iHyO4eTkvITOBYgoyrb7xnwv0TWVni(JMq6rh2W5QbFbt2aBu8Z15N3o3qXrqopdoSNrGsSqqQ3doV9R4gkocYHhsQKUJm6fCW5VD75jJPejedf)5zWH9mcu(yHQ2W15VDdPXWefiPMn4VJJYT)8KXuIeIHI)8m4WEgbkFSq17UUGDoIEb)zO)P5WLN4)(vQr4ynHDIAOZd0LXc0D0lW(yvr3c)2G4pAcPhDydhfeSTL4CNNeN9Ik6AEXxG4JDn61cq8RsKGGIJ0WpeNfOO5fhhyO)f3cjEcjXXSnaJ4Xko)Yl(KleK6v8eOfxVId2qCM0kjoltQxlIpr7a)pc25i6f8NH(NMdx(lQOR5llsrtzWOuJWXAc7e1qNhOlJfO7OxG9RI0qG4qaRKz5BaMYZK61YFiqIAi9TBJDn61c48mPETu0jyqNbtcXqVnCuyE7xXTineiopdoSNrGsSqqQ3dbsudPVDlsdbIZZK61sbzh4)HajQH03Un21OxlGZZGd7zeOeleK69aj1SbVnyzE7xXTXALajiowjqWCbE72yxJETaoiMedzmz0l4aj1SbVnkOSB3g7A0RfWbXKyiJjJEbhCE7JvfDl8BdI3gokFEbBBj(9ar8uRFXtijooVsI)GMNepyiXxajULoye3SwOpeFYjv0rCUZtIBHHaIRV0amIJKFqqXdMei(uTnX1esp6q8fkoydX)GstWqAXT0bZIhINGlIpvB7iyNJOxWFg6FAoCrnHZiDbzHfnLbJsMgqLHMJchLR04YWqLiHyO45OGsnchy26czLaXj16)GZB)QiHyO4eTkvITOB6UXQIUf(TbXF0esp642nU9bLMGH0N0ySpwv0TWVni(JMq6rh2WzWxuZjuEEcONxW2wIFpqehSINA9lUL2yex3K4w6GPbIhmK4aAcH4xxzVsIJ)K4koefj(cehD)xClDWS4H4j4I4t12oc25i6f8NH(NMdxut4msxqwyrtzWOuJWbMTUqwjqCsT(pnWMRRmfdMTUqwjqCsT(pACyg9cSpwv0TWVni(JMq6rh2WzWxuZjuEEcOfSZr0l4pd9pnhU8mPETuqnPMELAeowtyNOg68aDzSaDh9cSpwv0TWVni(JMq6rh2Wbl2Vcfhb58xurxZxwKIMYG5GZF7g6(VDKgdtuGKA2G)ooyrzZlyNJOxWFg6FAoCHgmBdWuGepSvtGwPgHJ1e2jQHopqxglq3rVa7JvfDl8BdI)OjKE0HnCWI9RSMWorn0b)PcpSxyhxkWnYOxWTBppzmLiHyO4ppdoSNrGYhlu9ooC92nioGqwig6aPFXb6gGPmmjSJlZlyBlXV3oyeNDIus8grCWgINgiL6lIRxaPK44pj(KleK6vClDWio7QiXX5pc25i6f8NH(NMdxEgCypJaLyHGuVk1iCI0qG48mPETuq2b(FiqIAiTDRjStudDEGUmwGUJEb2rXrqo)fv018LfPOPmyo482hRk6w43ge)DCWI9R4gkocYHhsQKUJm6fCW5VD75jJPejedf)5zWH9mcu(yHQ2W15fSZr0l4pd9pnhU8mPETu0jyqk1iC4gkocY5zs9APOtWGo482rAmmrbsQzd(74W9mDKgceNhhniicog6qGe1qAb7Ce9c(Zq)tZHlig6zgWejuQr4C1V4g0gOp84FGBOcbX5JEb3U9lUbTb6J11KrBOYVgReiM3obiiMlhnH0JoSHZ1vMDU9bLMGH0N0ySJIJGC(lQOR5llsrtzWC0RfGsniiieNpkTQkP7miokOudcccX5JcgZIMgokOudcccX5JsJW5xCdAd0hRRjJ2qLFnwjqiyNJOxWFg6FAoCHFJEbk1iCqXrqoOMD1g8poqkhXTBingMOaj1Sb)Dxxz3UHIJGC(lQOR5llsrtzWCW5TFfkocY5zs9APGAsn9hC(B3g7A0RfW5zs9APGAsn9hiPMn4VJJckBEb7Ce9c(Zq)tZHlOMD1feC4fLAeoO4iiN)Ik6A(YIu0ugmhCEb7Ce9c(Zq)tZHlOe8j4SgGrPgHdkocY5VOIUMVSifnLbZbNxWohrVG)m0)0C4csdjuZUALAeoO4iiN)Ik6A(YIu0ugmhCEb7Ce9c(Zq)tZHljyqFattzKgJsnchuCeKZFrfDnFzrkAkdMdoVGTTexresIBcXrsJbnhZehzHIJ)jQHeVds9VFX5opjULoyeN9Ik6AEXxeXveLbZrWohrVG)m0)0C4c(tLoi1xPgHdkocY5VOIUMVSifnLbZbN)2nKgdtuGKA2G)oSOmbBbBBzlXNOg0pdbFbBBj(9Y0gsC8Vbye32GKkP7iJEbkjEADBT4J8JgGrCwtpiXtGwCf1dsClmeqCwMuVwexrjyqI3V4)UaXJvCusC8N0kjonHbXhIJSqXv8Eb2jqWohrVG)G0G(z4ynHDIAiLaPkXHhsQKU8aDzSaDh9cuYAAWjorAiqC4HKkP7iJEbhcKOgsB)5jJPejedf)5zWH9mcu(yHQ3DLYvSXALajioaAaxZc1ZBNBJ1kbsqCMDb2jqWohrVG)G0G(zMMdxEtpOsc0fDpiLAeoCZAc7e1qhEiPs6Yd0LXc0D0lW(Ztgtjsigk(ZZGd7zeO8XcvV7ASZnuCeKZZK61srNGbDW5TJIJGCEtpOsc0fDpOdKuZg83H0yyIcKuZg82HecKEMe1qc25i6f8hKg0pZ0C4YB6bvsGUO7bPuJWXAc7e1qhEiPs6Yd0LXc0D0lW(yxJETaoptQxlfDcg0zWKqm0xqG5i6fKM7u4mXuUDuCeKZB6bvsGUO7bDGKA2G)UXUg9AbC(lQOR5llsrtzWCGKA2G3(vJDn61c48mPETu0jyqhiL6l2rXrqo)fv018LfPOPmyoqsnBWRyO4iiNNj1RLIobd6aj1Sb)DkCWY8c22sCfFKHNGIB7LWornK4ilu8RfNpWH0rC2znV4ACydWiUIl)GGIZ9)p)VbIVqX14WgGrCfLGbjULoyexrjCM4jqloyfFUgdt8rAMrWJGDoIEb)bPb9ZmnhUynHDIAiLaPkX5N18fioFGdjLSMgCIJA(bbl5)5)nOaj1SbVnk72nUfPHaXb0yyIpsZmcEiqIAiT9ineio6eoR8mPETCiqIAiTDuCeKZZK61srNGbDW5VD75jJPejedf)5zWH9mcu(yHQ2WHRc22sCfVeXlooV4xloFGdjXBeX7q8(fprx8q8yfhIdeFXJJGDoIEb)bPb9ZmnhUaX5dCiPuJW5kUznHDIAOZpR5lqC(ahs3UznHDIAOd(tfEyVWoUuGBKrVG5ThjedfNOvPsSfDtkgKuZg82Cn2HecKEMe1qc25i6f8hKg0pZ0C4YtdifLGgmGEIhNeSTL4koCt06nIgGr8iHyO4fpyYqClTXiUPTsIJSqXdgsCnomJEbIViIFT48boKusCiHaPNrCnoSbyeNpbAsThhb7Ce9c(dsd6NzAoCbIZh4qsPXLHHkrcXqXZrbLAeoCZAc7e1qNFwZxG48boKSZnRjStudDWFQWd7f2XLcCJm6fy)5jJPejedf)5zWH9mcu(yHQ2Wbl2JeIHIt0Quj2IUjB4CLYN(kSy7gRk6w43ge)8ZBhsiq6zsudjyBlXVwcbspJ4xloFGdjXPeAUiEJiEhIBPngXPjW3qsCnoSbyeN9Ik6A(J4kAfpyYqCiHaPNr8grC2vrIJHIxCiL6lI3aXdgsCanHqCL)hb7Ce9c(dsd6NzAoCbIZh4qsPgHd3SMWorn05N18fioFGdj7qsnBWF3yxJETao)fv018LfPOPmyoqsnBWpTckZ(yxJETao)fv018LfPOPmyoqsnBWFhhLBpsigkorRsLyl6MumiPMn4TzSRrVwaN)Ik6A(YIu0ugmhiPMn4Nw5c25i6f8hKg0pZ0C4cQjhZk8RfnbvQr4WnRjStudDWFQWd7f2XLcCJm6fy)5jJPejedfVnCUUGDoIEb)bPb9ZmnhUqw7FqWmibBbBBzlXzdknbJ4tDxJETaEbBBjUIpYWtqXT9syNOgsWohrVG)8bLMGPm0phRjStudPeivjopJUemq6zwJwjRPbN4m21OxlGZZK61srNGbDgmjed9feyoIEbPXgokCMykxW2wIB7LG(zeVre3cjEcjXhjpFdWi(cexrjyqIpysig6pIFpNqZfXrjKfsIJ0WpexNGbjEJiUfsCM0kjoyfFUgdt8rAMrqXrXdXvucNjoltQxlI3aXxOMGIhR4yOq8RfNpWHK448IFfyfxXLFqqX5()N)3G5pc25i6f8NpO0emLH(NMdxSMG(zuQr4Cf3SMWorn05z0LGbspZA03UXTineioGgdt8rAMrWdbsudPThPHaXrNWzLNj1RLdbsudPN3(yvr3c)2G4pAcPhDyJc25gehqiledDut4SYIucgQOMFqWs(F(FdeSTL422UgXrwO4SmPETOsgT4tloltQxlFa7zK44ad9V4wiXtijEIU4H4Xk(i5fFbIROemiXhmjed9hXT9bMlIBHHaIprnql(9s5ma9V49lEIU4H4Xkoehi(Ihhb7Ce9c(ZhuAcMYq)tZHl87Akq6xC4GuczHfanHGJckrtiGzjvxCqWHRktPgHdmh0b0yyIczqeSZr0l4pFqPjykd9pnhU8mPETOsgTsnchcqqmxSHdxvMDcqqmxoAcPhDydhfuMDUznHDIAOZZOlbdKEM1OTpwv0TWVni(JMq6rh2OGDnHIJGCqAGUyHYza6)dKuZg83PGGTTeFQ2M4bdKEM1OFXrwO4eiiydWioltQxlIROemib7Ce9c(ZhuAcMYq)tZHlwtyNOgsjqQsCEgDzSQOBHFBq8kznn4eNXQIUf(TbXF0esp6WgoyzAuCeKZZK61sb1KA6p48c25i6f8NpO0emLH(NMdxSMWornKsGuL48m6Yyvr3c)2G4vYAAWjoJvfDl8BdI)OjKE0HnCUUsncNXALajioZUa7eiyNJOxWF(GstWug6FAoCXAc7e1qkbsvIZZOlJvfDl8BdIxjRPbN4mwv0TWVni(JMq6rh3XrbLAeowtyNOg6G)uHh2lSJlf4gz0lW(Ztgtjsigk(ZZGd7zeO8XcvTHdxfSTL4kkbdsCnoSbyeN9Ik6AEXxO4j6ALepyG0ZSg9rWohrVG)8bLMGPm0)0C4YZK61srNGbPuJWXAc7e1qNNrxgRk6w43geV9RSMWorn05z0LGbspZA03UHIJGC(lQOR5llsrtzWCGKA2G3gokCWYTBO4iiNbtUFbnb0bN)2TNNmMsKqmu8NNbh2Ziq5JfQAdhUAFSRrVwaN)Ik6A(YIu0ugmhiPMn4TrbLnV9RqXrqo8eezHzq6IvQb)5JCm7oUE72Ztgtjsigk(ZZGd7zeO8XcvTblZlyBlXXkoeioKuZg0amIROemOxCuczHK4bdjosJHjeNa6x8grC2vrIBzbtjehLehsP(I4nq8OvPJGDoIEb)5dknbtzO)P5WLNj1RLIobdsPgHJ1e2jQHopJUmwv0TWVniE7ingMOaj1Sb)DJDn61c48xurxZxwKIMYG5aj1SbVGTGTTSL4SbLMGH0IFTBKrVabBBj(9arC2GstWWfRjOFgXtijooVsIJ)K4SmPET8bSNrIhR4OeGq6qCe4QkEWqIZN)3wjXrxa(lEc0Iprnql(9s5ma9VsItwjG4nI4wiXtijEgIRMtq8PABIFfoWq)lo(3amIR4YpiO4C))Z)BW8c25i6f8NpO0emKMZZK61YhWEgPuJW5kuCeKZhuAcMdo)TBO4iihRjOFMdo)82V65jJPejedf)5zWH9mcu(yHQ3X1B3SMWorn0b)PcpSxyhxkWnYOxW82vZpiyj)p)VbfiPMn45OmbBBj(e1G(zepdXV(0IpvBtClDWS4H4kIvCUioxNwClDWiUIyf3shmIZYGd7zeq8jxii1R4O4iiIJZlESINw3wl(VQK4t12e3s(bj(3bEg9c(JGTTeN7B(v8priXJvCKg0pJ4zioxNw8PABIBPdgXPjKJWCrCUkEKqmu8hXVInvjXZx8fp(wtI)bLMG5mVGTTeFIAq)mINH4CDAXNQTjULoyw8qCfXQK4kFAXT0bJ4kIvjXtGw8RrClDWiUIyfprcckUTxc6NrWohrVG)8bLMGH0tZHlJ0yk5i6fum9hkbsvIdsd6NrPgHJ1e2jQHoeccnI2kvgRk6w43geVnCg8f1CcLNNa6B3qXrqopdoSNrGsSqqQ3doV9XQIUf(TbXF0esp64ooy52TNNmMsKqmu8NNbh2Ziq5JfQAdhUA3Ac7e1qhcbHgrBLkJvfDl8BdI3goC92TXQIUf(TbXF0esp64ookOyxfPHaXrtepblFaZiXqQhcKOgsBhfhb5ynb9ZCW5NxWohrVG)8bLMGH0tZHlptQxlFa7zKsncNpO0emK(8e)3V9NNmMsKqmu8NNbh2Ziq5JfQEhxfSZr0l4pFqPjyi90C4YZ0wvQr4ePHaXb0yyIpsZmcEiqIAiTDioGqwig6en4sj2j0JcQj1K9NNmMsKqmu8NNbh2Ziq5JfQENYfSTL4ChEXJv8RlEKqmu8IFfyfNh278IpJiEXX5fFIAGw87LYza6FXrVi(4YW0amIZYK61YhWEgDeSZr0l4pFqPjyi90C4YZK61YhWEgP04YWqLiHyO45OGsnchUznHDIAOd(tfEyVWoUuGBKrVa7Acfhb5G0aDXcLZa0)hiPMn4Vtb7ppzmLiHyO4ppdoSNrGYhlu9oox3EKqmuCIwLkXw0nPyqsnBWBZ1iyBlXNOfkopSxyhxehUrg9cusC8NeNLj1RLpG9ms81kbfNnwOQ4w6Gr87vXjEIjBWhIJZlESIZvXJeIHIx8fkEJi(eDVI3V4qCaObyeFrqe)QfiEcUiEQU4Gq8fr8iHyO4NxWohrVG)8bLMGH0tZHlptQxlFa7zKsnchRjStudDWFQWd7f2XLcCJm6fy)knHIJGCqAGUyHYza6)dKuZg83PWTBrAiqCSqj)cuZpi4HajQH02FEYykrcXqXFEgCypJaLpwO6DC468c25i6f8NpO0emKEAoC5zWH9mcu(yHQk1iCEEYykrcXqXBdNRp9vO4iiNGHkWnccCW5VDdIdiKfIHo5SmH9x(f3uqGjgvceZB)kuCeKZFrfDnFzrkAkdMsIh7a2XbN)2nUHIJGC4HKkP7iJEbhC(B3EEYykrcXqXBdhLpVGTTeNLj1RLpG9ms8yfhsiq6zeFIAGw87LYza6FXtGw8yfNapoKe3cj(ibIpsi8I4RvckEkocUXi(eDVI3GyfpyiXb0ecXzxfjEJio)(FJAOJGDoIEb)5dknbdPNMdxEMuVw(a2ZiLAeoAcfhb5G0aDXcLZa0)hiPMn4VJJc3Un21OxlGZFrfDnFzrkAkdMdKuZg83Pa3JDnHIJGCqAGUyHYza6)dKuZg83n21OxlGZFrfDnFzrkAkdMdKuZg8c25i6f8NpO0emKEAoCbJzxvutQjLAeoO4iihEcISWmiDXk1G)8roMzdhLBFSanEhhEcISWmiDXk1G)atWmB4OW1fSZr0l4pFqPjyi90C4YZK61YhWEgjyNJOxWF(GstWq6P5WLbdL8LNzdLAeoClsigko9xq3)Tpwv0TWVni(JMq6rh2Wrb7O4iiNNzJsdkbdv0jC2bN3obiiMlNOvPsSfUQmBWm0h1Ccv2NNg15WY1OqnQrTc]] )

    
end
