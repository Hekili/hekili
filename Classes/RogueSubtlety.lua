-- RogueSubtlety.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ] 

local class = Hekili.Class
local state =  Hekili.State

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
                sht[1] = mh_next + ( 1 * mh_speed )
                sht[2] = mh_next + ( 2 * mh_speed )
                sht[3] = mh_next + ( 3 * mh_speed )
                sht[4] = mh_next + ( 4 * mh_speed )
            end

            if oh_speed and oh_speed > 0 then
                sht[5] = oh_next + ( 1 * oh_speed )
                sht[6] = oh_next + ( 2 * oh_speed )
                sht[7] = oh_next + ( 3 * oh_speed )
                sht[8] = oh_next + ( 4 * oh_speed )
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
                return 40 * ( ( talent.shadow_focus.enabled and ( buff.shadow_dance.up or buff.stealth.up ) ) and 0.8 or 1 ) * ( 1 - conduit.rushed_setup.mod * 0.01 )
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

            spend = function () return 30 * ( ( talent.shadow_focus.enabled and ( buff.shadow_dance.up or buff.stealth.up ) ) and 0.8 or 1 ) * ( 1 - conduit.rushed_setup.mod * 0.01 ) end,
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

            spend = function () return 25 * ( ( talent.shadow_focus.enabled and ( buff.shadow_dance.up or buff.stealth.up ) ) and 0.8 or 1 ) * ( 1 - conduit.rushed_setup.mod * 0.01 ) end,
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

            spend = function () return 35 * ( ( talent.shadow_focus.enabled and ( buff.shadow_dance.up or buff.stealth.up ) ) and 0.8 or 1 ) * ( 1 - conduit.rushed_setup.mod * 0.01 ) end,
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


    spec:RegisterPack( "Subtlety", 20210713, [[defJ)bqiuL8isvSjf0NivYOuj5uQKAvuvs9kQQAwKkUfQISlf9lujggQsDmuPwgQKEMkLAAKk11OQW2uOkFdsv14uOsDoQkjTovkP5PsX9qf7Juv)JuLOoiQIQfcPYdPQutevHlcPk0gjvP(iKQOrsQsOtQqLSsiLxsQsKzcPkDtufLDQq5NuvsmuQkXsvOINIstLQkxfsvzRKQK6RQuIXQqvDwsvcAVs8xjnykhw0IrXJvXKj5YiBgIpdjJgQoTuRgsvWRviZMk3MQSBGFR0WjLJtQsYYb9CvnDHRdLTRaFhv14PQOZRsSEsvcmFvQ2pXfUl(vyvzqLX4kV5k38g9Z9TN8ECZB0VU9rHnUOrfwT8mkrrfwq6rfwwmMWrXLcRwEXTPQ4xH9xm4HkS4rO93kx4cQoWXyMN1JlF7H5YOxWbMibx(27WLcldw7IXfOWuyvzqLX4kV5k38g9Z9TN8ECZB0VU5UWMyb(clSSTNVlS4TsrGctHvr)PWYIXeokUi24SOWibn0WCxeJ7BRJyCL3CLBbnbnFJNau0FRcA8Ky8SDaj2Ge2jJJMypv1G9c74sfUrg9cedttSFfRdX6xSNcXyiKfsIXNed7jX6ykOXtI571JPbKyEyUO1CKyN05Q5j6fuD9hIrGa20lwSIbjf2HetBdceD6eds8x4OPGgpjgplhrIP3o6XpWejeRbbbHyAHynqSZ6XKHynIy8jXqpG9HyQwjwhIHSqXgSUmAhv)1nGaXSW66p(IFf2pO0f4KQ4xzmUl(vyjqY4ivbDf28e9ckSpEQw(Fa7ruHvr)b2ArVGc74crm2GsxGZLbjOFCXsijgMMoIH9KyS4PA5)bShrIfRymeGq6qme46jwGtIPL)3diXywa2lwcuIP3nqj2Tq5ia9VoIrdiGynIy8jXsijwgI5L(umF7lIDfgWr)lg23auIXZYpiOy88)Z)BW1f2dSdc2zH9kXyWqqMFqPlWNyAID)UymyiiZbjOF8jMMyxl2qX8Ypiyn)p)Vbvi5Ln4fJJy8UeLX4AXVclbsghPkORWQO)aBTOxqHvVBq)4ILHy62FX8TVig)oWxSqmEWQJy(WFX43bUy8GvhXsGsSXtm(DGlgpyflrcckMEDc6hVWMNOxqH9KoxnprVGQR)OWEGDqWolSeccDIEavpRhZw12geVy6ZrSJw1l9z91iGsS73fJbdbz(4yWEebQXcbPANyAInuSZ6XSvTTbXpvesF6qSB4igxf7(DXEnY5QrcrrXpFCmypIa1pwONy6ZrmDl2qXiee6e9aQEwpMTQTniEX0NJy6wS73f7SEmBvBBq8tfH0Noe7goIXTy8KyxjwKocetfrAeS(bmJef5njqY4iLydfJbdbzoib9JpX0e76cRR)OcspQWI0G(XlrzSBx8RWsGKXrQc6kShyheSZc7hu6cCsnFs77xSHI9AKZvJeIIIF(4yWEebQFSqpXUrmDxyZt0lOW(4PA5)bShrLOmMUl(vyjqY4ivbDf2dSdc2zHnshbIjOrHhFKUreCsGKXrkXgkgedqilefnJgCPgRp7tLXLkAsGKXrkXgk2Rroxnsikk(5JJb7reO(Xc9e7gX8rHnprVGc7J3dkrzmFu8RWsGKXrQc6kS5j6fuyF8uT8)a2JOc75YXr1iHOO4lJXDH9a7GGDwy5LydsyNmoAI9uvd2lSJlv4gz0lqSHIPigmeKjsduv(uocq)pHKx2GxSBeJBXgk2Rroxnsikk(5JJb7reO(Xc9e7goIDBXgkwKquumJ2JQXwvnjgpjgK8Yg8IPVyJxHvr)b2ArVGcl6ttSyf72IfjeffVyxbwX0G9ETyJistmmnX07gOe7wOCeG(xmMlIDUCCnaLyS4PA5)bShrZsugB8k(vyjqY4ivbDf28e9ckSpEQw(Fa7ruHvr)b2ArVGcREVqX0G9c74IyWnYOxGoIH9KyS4PA5)bShrITdiOySXc9eJFh4IDl8mXsuzd(qmmnXIvmDlwKquu8ITqXAeX07BrS(fdIbanaLylcIyxTaXsWfXsVfdeITiIfjeff)1f2dSdc2zHDqc7KXrtSNQAWEHDCPc3iJEbInuSRetrmyiitKgOQ8PCeG(FcjVSbVy3ig3ID)Uyr6iqm5tP2c8Ypi4KajJJuInuSxJCUAKquu8Zhhd2Jiq9Jf6j2nCet3IDDjkJH(l(vyjqY4ivbDf2dSdc2zH91iNRgjeffVy6ZrSBlM)IDLymyiiZaNQWnccmX0e7(DXGyaczHOOzokty)1FXCveyIYJaXKajJJuIDTydf7kXyWqqM)fpM191fPQOmWRjwShyhtmnXUFxmEjgdgcYudsEKQJm6fmX0e7(DXEnY5QrcrrXlM(CeZhIDDHnprVGc7JJb7reO(Xc9krzSXDXVclbsghPkORWMNOxqH9Xt1Y)dypIkSk6pWwl6fuyzXt1Y)dypIelwXGecKECX07gOe7wOCeG(xSeOelwXiWJbjX4tIDsGyNecVi2oGGILIHG5CIP33IyniwXcCsma5Zqm2LhI1iIPT)3moAwypWoiyNfwfXGHGmrAGQYNYra6)jK8Yg8IDdhX4wS73f7SRtT8bZ)IhZ6(6Iuvug4ti5Ln4f7gX4ECl2qXuedgcYePbQkFkhbO)NqYlBWl2nID21Pw(G5FXJzDFDrQkkd8jK8Yg8LOmMVAXVclbsghPkORWEGDqWolSmyiitncISWmivDa1GF(rEgjM(CeZhInuSZcuyDm1iiYcZGu1bud(jmbJetFoIX9TlS5j6fuyr521JXLkQeLX4M3f)kS5j6fuyF8uT8)a2JOclbsghPkOReLX4M7IFfwcKmosvqxH9a7GGDwy5LyrcrrXS)kZ(Vydf7SEmBvBBq8tfH0NoetFoIXTydfJbdbz(4BuBqnWPQkHJMyAInumcqquxMr7r1yR6M3IPVyOoQPx6ZcBEIEbf2doLA1hFJsuIcRIqsmxu8Rmg3f)kS5j6fuyh1NrfwcKmosvqxjkJX1IFfwcKmosvqxHD1kSpff28e9ckSdsyNmoQWoiDyuHLbdbz(U(q1eOQQ(qtmnXUFxSxJCUAKquu8Zhhd2Jiq9Jf6jM(CeB8kSk6pWwl6fuyrFpPelwXuuqqVgqIXhNcCck2zxNA5dEX4NDigYcfJfWdXyYNuITaXIeIIIFwyhKWki9Oc7du1ZcuD0lOeLXUDXVclbsghPkORWUAf2NIcBEIEbf2bjStghvyhKomQWQb7f2XLkCJm6fi2qXEnY5QrcrrXpFCmypIa1pwONy6ZrmUwyv0FGTw0lOW6RaCxe7GNauKyWnYOxGynIy8jXWZbKyAWEHDCPc3iJEbI9uiwcuI5H5IwZrIfjeffVyyAZc7GewbPhvyXEQQb7f2XLkCJm6fuIYy6U4xHLajJJuf0vyxTc7trHnprVGc7Ge2jJJkSdshgvy5QpeZFXI0rGyoOrTWjbsghPeZxlgx5Ty(lwKocetV8dcwxK6JNQL)pjqY4iLy(AX4kVfZFXI0rGy(4PA5xr2d2pjqY4iLy(AX4QpeZFXI0rGyMU8a74YKajJJuI5RfJR8wm)fJR(qmFTyxj2Rroxnsikk(5JJb7reO(Xc9etFoIPBXUUWQO)aBTOxqHf99KsSyftrinGeJpobelwXWEsSpO0f4I5BE8ITqXyWANIGFHDqcRG0JkSFqPlWRboKE81PkrzmFu8RWsGKXrQc6kSk6pWwl6fuy9noDgjMV5XlwgIH0WpkS5j6fuypPZvZt0lO66pkSU(Jki9Oc7r9LOm24v8RWsGKXrQc6kSk6pWwl6fuyhhmGyiyo3fXE(DCWPxSyflWjXydkDboPeBC2iJEbIDfZfXuBdqj2V6iwhIHSWd9IPTRRbOeRredSbEdqjw)ILdY2Lmo66zHnprVGcleduZt0lO66pkShyheSZc7hu6cCsntNRW66pQG0JkSFqPlWjvjkJH(l(vyjqY4ivbDf28e9ckSVRpunbQQQpuHvr)b2ArVGclpxtZDrmwxFiXsGsmE0hsSmeJR(lMV9fXuyWgGsSaNedPHFig38wSNolq96iwIeeuSapdX0T)I5BFrSgrSoeJ8PwdPxm(DG3aXcCsma5Zqm0tFZdXwOy9lgydXW0kShyheSZc7Rroxnsikk(5JJb7reO(Xc9e7gXgpXgkgsJcpQqYlBWlM(InEInumgmeK576dvtGQQ6dnHKx2GxSBed1rn9sFk2qXoRhZw12geVy6ZrmDlgpj2vIfThj2nIXnVf7AX81IX1sugBCx8RWsGKXrQc6kSk6pWwl6fuy9fyVWoUi24Srg9c0llg6LcD9IHQhqILIDGPMyjZIfIracI6IyiluSaNe7dkDbUy(MhVyxXG1ofbf7J25edsVgDcX646Py6fIPPJyDi2jbIXqIf4zi23EAoAwyZt0lOWEsNRMNOxq11FuypWoiyNf2bjStghnXEQQb7f2XLkCJm6fuyD9hvq6rf2pO0f41J6lrzmF1IFfwcKmosvqxHvr)b2ArVGcRVxW3kckg23auILIXgu6cCX8npeJpobeds5bVbOelWjXiabrDrSahsp(6uf28e9ckSN05Q5j6fuD9hf2dSdc2zHLaee1LPIq6thIDdhXgKWozC08dkDbEnWH0JVovH11FubPhvy)GsxGxpQVeLX4M3f)kSeizCKQGUc7b2bb7SWELyeccDIEavpRhZw12geVy6ZrSJw1l9z91iGsSRf7(DXUsSZ6XSvTTbXpvesF6qSB4ig3ID)Uyink8OcjVSbVy3WrmUfBOyeccDIEavpRhZw12geVy6ZrSBl297IXGHGm)lEmR7RlsvrzGxtSypWoMyAInumcbHorpGQN1JzRABdIxm95iMUf7AXUFxSRe71iNRgjeff)8XXG9icu)yHEIPphX0TydfJqqOt0dO6z9y2Q22G4ftFoIPBXUUWMNOxqH9KoxnprVGQR)OW66pQG0JkSinOF8sugJBUl(vyjqY4ivbDfwf9hyRf9ckSOVNelfJbRDkckgFCcigKYdEdqjwGtIracI6IyboKE81PkS5j6fuypPZvZt0lO66pkShyheSZclbiiQltfH0Noe7goIniHDY4O5hu6c8AGdPhFDQcRR)OcspQWYG1ovjkJXnxl(vyjqY4ivbDf28e9ckSj8KaQglesGOWQO)aBTOxqHf9U8Ppetd2lSJlI1aXsNtSfrSaNeJN7lOxXyOtI9KyDi2jXE6flfd9038OWEGDqWolSeGGOUmvesF6qm95ig3(qm)fJaee1LjKqrGsugJ7Bx8RWMNOxqHnHNeqvnm3tfwcKmosvqxjkJXTUl(vyZt0lOW6Au4XxrpGPq5rGOWsGKXrQc6krzmU9rXVcBEIEbfwMevDrQbSpJ(clbsghPkOReLOWQbPZ6XKrXVYyCx8RWMNOxqHn10CxQAB)lOWsGKXrQc6krzmUw8RWMNOxqHLzJWrQkIlVqk(navnwF2GclbsghPkOReLXUDXVclbsghPkORWEGDqWolS)I5yAGAQH9bMJQeetl6fmjqY4iLy3Vl2VyoMgOMdwxgTJQ)6gqGysGKXrQcBEIEbfweh94hyIeLOmMUl(vyZt0lOW(bLUaVWsGKXrQc6krzmFu8RWsGKXrQc6kS5j6fuy9s4isvrwyvrzGxy1G0z9yYO(0zbQVWYTpkrzSXR4xHLajJJuf0vyZt0lOW(U(q1eOQQ(qf2dSdc2zHfsiq6Xtghvy1G0z9yYO(0zbQVWYDjkJH(l(vyjqY4ivbDf2dSdc2zHfIbiKfIIMEjCuDrQbov9Ypiyn)p)VbtcKmosvyZt0lOW(4PA5xzCPI(suIclsd6hV4xzmUl(vyjqY4ivbDf2vRW(uuyZt0lOWoiHDY4Oc7G0Hrf2iDeiMAqYJuDKrVGjbsghPeBOyVg5C1iHOO4NpogShrG6hl0tSBe7kX8Hy8KyNDabsqmb0bUUfQe7AXgkgVe7SdiqcI5OlWobfwf9hyRf9ckS3cE7iXW(gGsmFbsEKQJm6fOJy5GTvIDYpAakXyD9HelbkX4rFiX4JtaXyXt1YxmEKGdjw)I97celwXyiXWEsPJyKppKwigYcftV0fyNGc7GewbPhvy1GKhPQpqvplq1rVGsugJRf)kSeizCKQGUc7b2bb7SWYlXgKWozC0udsEKQ(av9Savh9ceBOyVg5C1iHOO4NpogShrG6hl0tSBeB8eBOy8smgmeK5JNQLFvLGdnX0eBOymyiiZ31hQMavv1hAcjVSbVy3igsJcpQqYlBWl2qXGecKE8KXrf28e9ckSVRpunbQQQpujkJD7IFfwcKmosvqxH9a7GGDwyhKWozC0udsEKQ(av9Savh9ceBOyNDDQLpy(4PA5xvj4qZdEcrrFfbMNOxq6e7gX4EI(9HydfJbdbz(U(q1eOQQ(qti5Ln4f7gXo76ulFW8V4XSUVUivfLb(esEzdEXgk2vID21Pw(G5JNQLFvLGdnHuQUi2qXyWqqM)fpM191fPQOmWNqYlBWlgpjgdgcY8Xt1YVQsWHMqYlBWl2nIX9KRIDDHnprVGc776dvtGQQ6dvIYy6U4xHLajJJuf0vyxTc7trHnprVGc7Ge2jJJkSdshgvy9Ypiyn)p)Vbvi5Ln4ftFX4Ty3VlgVelshbIjOrHhFKUreCsGKXrkXgkwKocetvchvF8uT8NeizCKsSHIXGHGmF8uT8RQeCOjMMy3Vl2Rroxnsikk(5JJb7reO(Xc9etFoIDLy(qmEsmigGqwikAI0G01XLjbsghPe76cRI(dS1IEbfw9IKtJGIPxNWozCKyiluSXbtlWG0um2rTMykmydqjgpl)GGIXZ)p)VbITqXuyWgGsmEKGdjg)oWfJhjCKyjqjgyfBSgfE8r6grWzHDqcRG0JkS)OwRcX0cmivIYy(O4xHLajJJuf0vyZt0lOWcX0cmivyv0FGTw0lOWQxIinXW0eBCW0cmijwJiwhI1VyjZIfIfRyqmGylwmlShyheSZc7vIXlXgKWozC08h1AviMwGbjXUFxSbjStghnXEQQb7f2XLkCJm6fi21InuSiHOOygThvJTQAsmEsmi5Ln4ftFXgpXgkgKqG0JNmoQeLXgVIFf28e9ckSpDGuud6GdA9kmQWsGKXrQc6krzm0FXVclbsghPkORWMNOxqHfIPfyqQWEUCCunsikk(YyCxypWoiyNfwEj2Ge2jJJM)OwRcX0cmij2qX4LydsyNmoAI9uvd2lSJlv4gz0lqSHI9AKZvJeIIIF(4yWEebQFSqpX0NJyCvSHIfjeffZO9OASvvtIPphXUsmFiM)IDLyCvmFTyN1JzRABdIxSRf7AXgkgKqG0JNmoQWQO)aBTOxqHLNH5IwTr0auIfjeffVybEgIXVDoXC9asmKfkwGtIPWGz0lqSfrSXbtlWGKoIbjei94IPWGnaLyAjqrE9zwIYyJ7IFfwcKmosvqxHnprVGcletlWGuHvr)b2ArVGc74qiq6XfBCW0cmijgLq3fXAeX6qm(TZjg5tTgsIPWGnaLySx8yw3pfJhRybEgIbjei94I1iIXU8qmuu8IbPuDrSgiwGtIbiFgI5JFwypWoiyNfwEj2Ge2jJJM)OwRcX0cmij2qXGKx2GxSBe7SRtT8bZ)IhZ6(6Iuvug4ti5Ln4fZFX4M3InuSZUo1Yhm)lEmR7RlsvrzGpHKx2GxSB4iMpeBOyrcrrXmApQgBv1Ky8KyqYlBWlM(ID21Pw(G5FXJzDFDrQkkd8jK8Yg8I5Vy(OeLX8vl(vyjqY4ivbDf2dSdc2zHLxIniHDY4Oj2tvnyVWoUuHBKrVaXgk2RroxnsikkEX0NJy3UWMNOxqHLXLNrvTLVIGLOmg38U4xHnprVGclnO)dbZGkSeizCKQGUsuIc7r9f)kJXDXVclbsghPkORWEGDqWolS8smgmeK5JNQLFvLGdnX0eBOymyiiZhhd2Jiqnwiiv7ettSHIXGHGmFCmypIa1yHGuTti5Ln4f7goID7PpkSypvxeKkQJQmg3f28e9ckSpEQw(vvcouHvr)b2ArVGcl67jX4rcoKylccpH6OeJHqwijwGtIH0Wpe7XXG9icu)yHEIHaxpX8BHGuTIDwp6fRbZsugJRf)kSeizCKQGUc7b2bb7SWYGHGmFCmypIa1yHGuTtmnXgkgdgcY8XXG9icuJfcs1oHKx2GxSB4i2TN(OWI9uDrqQOoQYyCxyZt0lOW(x8yw3xxKQIYaVWQO)aBTOxqH9k0hWr)lw6GuQUigMMym0jXEsm(KyXUJeJfpvlFX079G9xlg2tIXEXJzDVylccpH6OeJHqwijwGtIH0WpeJfhd2JiGySXc9edbUEI53cbPAf7SE0lwdMLOm2Tl(vyjqY4ivbDf2dSdc2zHDqc7KXrZhOQNfO6OxGydfJxI9bLUaNutVeeosSHIXGHGm)lEmR7RlsvrzGpX0eBOyN1JzRABdIxm95iMpkS5j6fuyrCjkY5YOxqjkJP7IFfwcKmosvqxH9a7GGDwyVsmigGqwikA6LWr1fPg4u1l)GG18)8)gmjqY4iLydf7SEmBvBBq8tfH0Noe7goIXTy8Kyr6iqmvePrW6hWmiuK3KajJJuID)UyqmaHSqu0urzG7UuF8uT8)jbsghPeBOyN1JzRABdIxSBeJBXUwSHIXGHGm)lEmR7RlsvrzGpX0eBOymyiiZhpvl)QkbhAIPj2qX8Ypiyn)p)Vbvi5Ln4fJJy8wSHIXGHGmvug4Ul1hpvl)FQw(GcBEIEbf2bjOF8sugZhf)kSeizCKQGUcRI(dS1IEbfwFzxNyilum)wiivRyAqINyxEig)oWfJfNhIbPuDrm(4eqmWgIbXaGgGsmw9Ewyrwyfq(mkJXDH9a7GGDwyJ0rGy(4yWEebQXcbPANeizCKsSHIXlXI0rGy(4PA5xr2d2pjqY4ivHnprVGcR2UUkK(fdEOsugB8k(vyjqY4ivbDf28e9ckSpogShrGASqqQ2cRI(dS1IEbfw03tI53cbPAftdsIXU8qm(4eqm(Ky45asSaNeJaee1fX4JtbobfdbUEIPTRRbOeJFh4lwigREl2cfd9a2hIHIaemDUlZc7b2bb7SWsacI6Iy6ZrSXJ3InuSbjStghnFGQEwGQJEbInuSZUo1Yhm)lEmR7RlsvrzGpX0eBOyNDDQLpy(4PA5xvj4qZdEcrrVy6ZrmUfBOyxjgVedIbiKfIIMldPAcCOjbsghPe7(DXuedgcYeXLOiNlJEbtmnXUwSHIDwpMTQTniEXUHJyCvSHIDLy8smgmeKPgK8ivhz0lyIPj297I9AKZvJeIIIF(4yWEebQFSqpX0xmDl21LOmg6V4xHLajJJuf0vyZt0lOW(eeMbPQmlGQVwpIkShyheSZc7Ge2jJJMpqvplq1rVaXgkgVetTX8jimdsvzwavFTEevvBmJ(mQbOeBOyrcrrXmApQgBv1Ky6ZrmUYTydf7kXoRhZw12ge)uri9PdX0NJyxj2rRIkBGy6RxwmDl21IDTydfJxIXGHGmFCmypIa1yHGuTtmnXgk2vIXlXyWqqMAqYJuDKrVGjMMy3Vl2Rroxnsikk(5JJb7reO(Xc9etFX0Tyxl297IH0OWJkK8Yg8IDdhX8Hydf71iNRgjeff)8XXG9icu)yHEIDJy3UWEUCCunsikk(YyCxIYyJ7IFfwcKmosvqxH9a7GGDwyhKWozC08bQ6zbQo6fi2qXoRhZw12ge)uri9PdX0NJyCxyZt0lOW(K23FjkJ5Rw8RWsGKXrQc6kS5j6fuy)lEmR7RlsvrzGxyv0FGTw0lOWI(Esm2lEmR7fBbID21Pw(aXUkrcckgsd)qmwapUwmmGJ(xm(KyjKed12auIfRyARMy(TqqQwXsGsm1kgydXWZbKyS4PA5lMEVhSFwypWoiyNf2bjStghnFGQEwGQJEbInuSRelshbIjbgqUvRbOQpEQw()KajJJuID)UyNDDQLpy(4PA5xvj4qZdEcrrVy6ZrmUf7AXgk2vIXlXI0rGy(4yWEebQXcbPANeizCKsS73flshbI5JNQLFfzpy)KajJJuID)UyNDDQLpy(4yWEebQXcbPANqYlBWlM(IXvXUwSHIDLy8sSZoGajiMdiqGFbk297ID21Pw(GjIlrroxg9cMqYlBWlM(IXnVf7(DXo76ulFWeXLOiNlJEbtmnXgk2z9y2Q22G4ftFoI5dXUUeLX4M3f)kSeizCKQGUcBEIEbfwVeoIuvKfwvug4fwxdO6rvy5E6Jc75YXr1iHOO4lJXDH9a7GGDwyHzRQ0aceZuP(jMMydf7kXIeIIIz0Eun2QQjXUrSZ6XSvTTbXpvesF6qS73fJxI9bLUaNuZ05eBOyN1JzRABdIFQiK(0Hy6ZrSJw1l9z91iGsSRlSk6pWwl6fuyhxiILk1lwcjXW00rSh0AKyboj2ciX43bUyULp9Hy(5hpMIH(Esm(4eqm1LgGsmK8dckwGNaX8TViMIq6thITqXaBi2hu6cCsjg)oWxSqSeCrmF7lZsugJBUl(vyjqY4ivbDf28e9ckSEjCePQilSQOmWlSk6pWwl6fuyhxiIbwXsL6fJF7CIPAsm(DG3aXcCsma5ZqSBZ7xhXWEsmEgcpeBbIXS)lg)oWxSqSeCrmF7lZc7b2bb7SWcZwvPbeiMPs9ZgiM(IDBElgpjgmBvLgqGyMk1pvyWm6fi2qXoRhZw12ge)uri9PdX0NJyhTQx6Z6RravjkJXnxl(vyjqY4ivbDf2dSdc2zHDqc7KXrZhOQNfO6OxGydf7SEmBvBBq8tfH0NoetFoIXvXgk2vID21Pw(G5FXJzDFDrQkkd8jK8Yg8IDJyCl297IXGHGm)lEmR7RlsvrzGpX0e7(DXqAu4rfsEzdEXUHJyCL3IDDHnprVGc7JNQLFLXLk6lrzmUVDXVclbsghPkORWEGDqWolSdsyNmoA(av9Savh9ceBOyN1JzRABdIFQiK(0Hy6ZrmUk2qXUsSbjStghnXEQQb7f2XLkCJm6fi297I9AKZvJeIIIF(4yWEebQFSqpXUHJy6wS73fdIbiKfIIMq6xmGQbOQhxc74YKajJJuIDDHnprVGclDW3gGQcjny7LavjkJXTUl(vyjqY4ivbDf28e9ckSpogShrGASqqQ2cRI(dS1IEbf2BPdCXy1BDeRredSHyPdsP6IyQfq6ig2tI53cbPAfJFh4IXU8qmmTzH9a7GGDwyJ0rGy(4PA5xr2d2pjqY4iLydfBqc7KXrZhOQNfO6OxGydfJbdbz(x8yw3xxKQIYaFIPj2qXoRhZw12geVy3WrmUk2qXUsmEjgdgcYudsEKQJm6fmX0e7(DXEnY5QrcrrXpFCmypIa1pwONy6lMUf76sugJBFu8RWsGKXrQc6kShyheSZclVeJbdbz(4PA5xvj4qtmnXgkgsJcpQqYlBWl2nCeBClM)IfPJaX8XyccIGHIMeizCKQWMNOxqH9Xt1YVQsWHkrzmUhVIFfwcKmosvqxH9a7GGDwyVsSFXCmnqn1W(aZrvcIPf9cMeizCKsS73f7xmhtduZbRlJ2r1FDdiqmjqY4iLyxl2qXiabrDzQiK(0Hy6ZrSBZBXgkgVe7dkDboPMPZj2qXyWqqM)fpM191fPQOmWNQLpOW2GGGqmTO2if2FXCmnqnhSUmAhv)1nGarHTbbbHyArT98ivNbvy5UWMNOxqHfXrp(bMirHTbbbHyArfLBzsxHL7sugJB0FXVclbsghPkORWEGDqWolSmyiitg3Ukh2htiLNqS73fdPrHhvi5Ln4f7gXUnVf7(DXyWqqM)fpM191fPQOmWNyAInuSReJbdbz(4PA5xzCPI(jMMy3Vl2zxNA5dMpEQw(vgxQOFcjVSbVy3WrmU5TyxxyZt0lOWQTrVGsugJ7XDXVclbsghPkORWEGDqWolSmyiiZ)IhZ6(6Iuvug4tmTcBEIEbfwg3UQkcg8sjkJXTVAXVclbsghPkORWEGDqWolSmyiiZ)IhZ6(6Iuvug4tmTcBEIEbfwgc(eCudqvIYyCL3f)kSeizCKQGUc7b2bb7SWYGHGm)lEmR7RlsvrzGpX0kS5j6fuyrAiX42vvIYyCL7IFfwcKmosvqxH9a7GGDwyzWqqM)fpM191fPQOmWNyAf28e9ckSj4qFatx9KoxjkJXvUw8RWsGKXrQc6kS5j6fuyXEQ2b59fwf9hyRf9ckS8Gqsmxigs6Cm5zKyilumSpzCKyDqE)Tkg67jX43bUySx8yw3l2IigpOmWNf2dSdc2zHLbdbz(x8yw3xxKQIYaFIPj297IH0OWJkK8Yg8IDJyCL3LOef2pO0f41J6l(vgJ7IFfwcKmosvqxHD1kSpff28e9ckSdsyNmoQWoiDyuH9SRtT8bZhpvl)QkbhAEWtik6RiW8e9csNy6ZrmUNOFFuyv0FGTw0lOWQxKCAeum96e2jJJkSdsyfKEuH9Xv1ahsp(6uLOmgxl(vyjqY4ivbDf28e9ckSdsq)4fwf9hyRf9ckS61jOFCXAeX4tILqsStQP1auITaX4rcoKyh8eII(PyOhtO7IymeYcjXqA4hIPsWHeRreJpjgEoGedSInwJcp(iDJiOymyHy8iHJeJfpvlFXAGylurqXIvmuui24GPfyqsmmnXUcSIXZYpiOy88)Z)BW1Zc7b2bb7SWELy8sSbjStghnFCvnWH0JVoLy3VlgVelshbIjOrHhFKUreCsGKXrkXgkwKocetvchvF8uT8NeizCKsSRfBOyN1JzRABdIFQiK(0Hy6lg3InumEjgedqilefn9s4O6IudCQ6LFqWA(F(FdMeizCKQeLXUDXVclbsghPkORWQO)aBTOxqH1x21jgYcfJfpvlFpYPeZFXyXt1Y)dypIedd4O)fJpjwcjXsMflelwXoPMylqmEKGdj2bpHOOFkMVcWDrm(4eqm9UbkXUfkhbO)fRFXsMflelwXGyaXwSywyrwyfq(mkJXDH9a7GGDwyH5HMGgfEujhsHL8zaZA6TyGOWQBExyZt0lOWQTRRcPFXGhQeLX0DXVclbsghPkORWEGDqWolSeGGOUiM(Cet38wSHIracI6Yuri9PdX0NJyCZBXgkgVeBqc7KXrZhxvdCi94Rtj2qXoRhZw12ge)uri9PdX0xmUfBOykIbdbzI0avLpLJa0)ti5Ln4f7gX4UWMNOxqH9Xt1Y3JCQsugZhf)kSeizCKQGUc7QvyFkkS5j6fuyhKWozCuHDq6WOc7z9y2Q22G4NkcPpDiM(CeJRI5VymyiiZhpvl)kJlv0pX0kSk6pWwl6fuy9TViwGdPhFDQxmKfkgbcc2auIXINQLVy8ibhQWoiHvq6rf2hxvpRhZw12geFjkJnEf)kSeizCKQGUc7QvyFkkS5j6fuyhKWozCuHDq6WOc7z9y2Q22G4NkcPpDiM(Ce72f2dSdc2zH9SdiqcI5OlWobf2bjScspQW(4Q6z9y2Q22G4lrzm0FXVclbsghPkORWUAf2NIcBEIEbf2bjStghvyhKomQWEwpMTQTni(PIq6thIDdhX4UWEGDqWolSdsyNmoAI9uvd2lSJlv4gz0lqSHI9AKZvJeIIIF(4yWEebQFSqpX0NJy6UWoiHvq6rf2hxvpRhZw12geFjkJnUl(vyjqY4ivbDf28e9ckSpEQw(vvcouHvr)b2ArVGclpsWHetHbBakXyV4XSUxSfkwYSdiXcCi94RtnlShyheSZc7Ge2jJJMpUQEwpMTQTniEXgk2vIniHDY4O5JRQboKE81Pe7(DXyWqqM)fpM191fPQOmWNqYlBWlM(CeJ7jxf7(DXEnY5QrcrrXpFCmypIa1pwONy6ZrmDl2qXo76ulFW8V4XSUVUivfLb(esEzdEX0xmU5TyxxIYy(Qf)kSeizCKQGUcBEIEbf2hpvl)QkbhQWQO)aBTOxqHfDyqGyqYlBqdqjgpsWHEXyiKfsIf4Kyink8qmcOEXAeXyxEig)fORqmgsmiLQlI1aXI2JMf2dSdc2zHDqc7KXrZhxvpRhZw12geVydfdPrHhvi5Ln4f7gXo76ulFW8V4XSUVUivfLb(esEzd(suIcldw7uf)kJXDXVclbsghPkORWEGDqWolS8sSiDeiMGgfE8r6grWjbsghPeBOyqmaHSqu0mAWLAS(SpvgxQOjbsghPeBOyVg5C1iHOO4NpogShrG6hl0tSBeZhf28e9ckSpEpOeLX4AXVclbsghPkORWEGDqWolSVg5C1iHOO4ftFoIXvXgk2vIXlXo7acKGycOdCDluj297ID21Pw(G5tqygKQYSaQ(A9iA6L(SEWtik6fJNe7GNqu0xrG5j6fKoX0NJy8EYvFi297I9AKZvJeIIIF(4yWEebQFSqpX0xmDl21f28e9ckSpogShrG6hl0ReLXUDXVclbsghPkORWEGDqWolSNDDQLpy(eeMbPQmlGQVwpIMEPpRh8eIIEX4jXo4jef9veyEIEbPtSB4igVNC1hID)Uy)I5yAGA6OuvzUujFMEAoAsGKXrkXgkgVeJbdbz6OuvzUujFMEAoAIPj297I9lMJPbQ5iAqd(6U6fqUgGAsGKXrkXgkgVetrmyiiZr0Gg8v(WmWNyAf28e9ckSpbHzqQkZcO6R1JOsugt3f)kS5j6fuyr521JXLkQWsGKXrQc6krzmFu8RWMNOxqHLjpJ(izkSeizCKQGUsuIsuyhqWVxqzmUYBUYnVr)82xTWYpHGgG6lS3cpFCgBCng65TkMy(HtI1EAlmedzHIPRpO0f4KsxIbj9kSgskX(1JelXI1ldsj2bpbOOFkOHEBajMUVvX89cgqWGuIPligGqwikAo(6sSyftxqmaHSqu0C8NeizCKsxIDf3(86PGg6TbKyO)BvmFVGbemiLy6cIbiKfIIMJVUelwX0fedqilefnh)jbsghP0LyxXTpVEkOjODl88XzSX1yON3QyI5hojw7PTWqmKfkMU0G0z9yYqxIbj9kSgskX(1JelXI1ldsj2bpbOOFkOHEBaj2TVvX89cgqWGuIPRFXCmnqnhFDjwSIPRFXCmnqnh)jbsghP0LyxXTpVEkOHEBaj2TVvX89cgqWGuIPRFXCmnqnhFDjwSIPRFXCmnqnh)jbsghP0Lyzig6rFf0RyxXTpVEkOHEBajg6)wfZ3lyabdsjMUGyaczHOO54RlXIvmDbXaeYcrrZXFsGKXrkDjwgIHE0xb9k2vC7ZRNcAcA3cpFCgBCng65TkMy(HtI1EAlmedzHIPlKg0pUUeds6vynKuI9RhjwIfRxgKsSdEcqr)uqd92asmDFRI57fmGGbPetxqmaHSqu0C81LyXkMUGyaczHOO54pjqY4iLUe7kU951tbnbTBHNpoJnUgd98wftm)WjXApTfgIHSqX01r96smiPxH1qsj2VEKyjwSEzqkXo4jaf9tbn0BdiX09TkMVxWacgKsmDbXaeYcrrZXxxIfRy6cIbiKfIIMJ)KajJJu6sSR4QpVEkOHEBaj24DRI57fmGGbPetxqmaHSqu0C81LyXkMUGyaczHOO54pjqY4iLUe7kU951tbn0BdiX4(23Qy(EbdiyqkX0fedqilefnhFDjwSIPligGqwikAo(tcKmosPlXUIBFE9uqd92asmUhVBvmFVGbemiLy66xmhtduZXxxIfRy66xmhtduZXFsGKXrkDj2vC1Nxpf0e0UfE(4m24Am0ZBvmX8dNeR90wyigYcftxFqPlWRh1RlXGKEfwdjLy)6rILyX6LbPe7GNau0pf0qVnGeJR3Qy(EbdiyqkX0fedqilefnhFDjwSIPligGqwikAo(tcKmosPlXYqm0J(kOxXUIBFE9uqtq7w45JZyJRXqpVvXeZpCsS2tBHHyilumDXG1oLUeds6vynKuI9RhjwIfRxgKsSdEcqr)uqd92asmUVvX89cgqWGuIPligGqwikAo(6sSyftxqmaHSqu0C8NeizCKsxIDf3(86PGMG24YtBHbPed9lwEIEbI56p(PGwHvdUiTJkS6rpIXIXeokUi24SOWibn9OhXqdZDrmUVToIXvEZvUf0e00JEeZ34jaf93QGME0Jy8Ky8SDaj2Ge2jJJMypv1G9c74sfUrg9cedttSFfRdX6xSNcXyiKfsIXNed7jX6ykOPh9igpjMVxpMgqI5H5IwZrIDsNRMNOxq11FigbcytVyXkgKuyhsmTniq0PtmiXFHJMcA6rpIXtIXZYrKy6TJE8dmrcXAqqqiMwiwde7SEmziwJigFsm0dyFiMQvI1HyiluSbRlJ2r1FDdiqmf0e00JEeZxGep571JjdbT8e9c(PgKoRhtg(ZHlPMM7svB7FbcA5j6f8tniDwpMm8Ndxy2iCKQI4YlKIFdqvJ1NnqqlprVGFQbPZ6XKH)C4cIJE8dmrcDAeo)I5yAGAQH9bMJQeetl6fC)(VyoMgOMdwxgTJQ)6gqGqqlprVGFQbPZ6XKH)C4Yhu6cCbT8e9c(PgKoRhtg(ZHlEjCePQilSQOmW1rdsN1JjJ6tNfOEoC7dbT8e9c(PgKoRhtg(ZHlVRpunbQQQpKoAq6SEmzuF6Sa1ZHBDAeoqcbspEY4ibT8e9c(PgKoRhtg(ZHlpEQw(vgxQOxNgHdedqilefn9s4O6IudCQ6LFqWA(F(Fde0e00JEeJNLnqSXzJm6fiOLNOxWZzuFgjOPhXqFpPelwXuuqqVgqIXhNcCck2zxNA5dEX4NDigYcfJfWdXyYNuITaXIeIIIFkOLNOxW7phUmiHDY4iDaPhX5bQ6zbQo6fOZG0HrCyWqqMVRpunbQQQp0et7(9xJCUAKquu8Zhhd2Jiq9Jf6PpNXtqtpI5RaCxe7GNauKyWnYOxGynIy8jXWZbKyAWEHDCPc3iJEbI9uiwcuI5H5IwZrIfjeffVyyAtbT8e9cE)5WLbjStghPdi9ioypv1G9c74sfUrg9c0zq6WioAWEHDCPc3iJEbdFnY5QrcrrXpFCmypIa1pwON(C4QGMEed99KsSyftrinGeJpobelwXWEsSpO0f4I5BE8ITqXyWANIGVGwEIEbV)C4YGe2jJJ0bKEeNpO0f41ahsp(6u6miDyehU6d)J0rGyoOrTWjbsghP81CL3(hPJaX0l)GG1fP(4PA5)tcKmos5R5kV9pshbI5JNQLFfzpy)KajJJu(AU6d)J0rGyMU8a74YKajJJu(AUYB)5Qp81x9AKZvJeIIIF(4yWEebQFSqp95O7Rf00Jy(gNoJeZ384fldXqA4hcA5j6f8(ZHlN05Q5j6fuD9h6aspIZr9cA6rSXbdigcMZDrSNFhhC6flwXcCsm2GsxGtkXgNnYOxGyxXCrm12auI9RoI1Hyil8qVyA76AakXAeXaBG3auI1Vy5GSDjJJUEkOLNOxW7phUaXa18e9cQU(dDaPhX5dkDboP0Pr48bLUaNuZ05e00Jy8Cnn3fXyD9HelbkX4rFiXYqmU6Vy(2xetHbBakXcCsmKg(HyCZBXE6Sa1RJyjsqqXc8met3(lMV9fXAeX6qmYNAnKEX43bEdelWjXaKpdXqp9npeBHI1VyGnedttqlprVG3FoC5D9HQjqvv9H0Pr48AKZvJeIIIF(4yWEebQFSqVBgVHink8OcjVSbV(J3qgmeK576dvtGQQ6dnHKx2G)guh10l95WZ6XSvTTbXRphDZtxfThDd38(AFnxf00Jy(cSxyhxeBC2iJEb6Lfd9sHUEXq1diXsXoWutSKzXcXiabrDrmKfkwGtI9bLUaxmFZJxSRyWANIGI9r7CIbPxJoHyDC9um9cX00rSoe7KaXyiXc8me7Bpnhnf0Yt0l49NdxoPZvZt0lO66p0bKEeNpO0f41J61Pr4miHDY4Oj2tvnyVWoUuHBKrVabn9iMVxW3kckg23auILIXgu6cCX8npeJpobeds5bVbOelWjXiabrDrSahsp(6ucA5j6f8(ZHlN05Q5j6fuD9h6aspIZhu6c86r960iCiabrDzQiK(0XnCgKWozC08dkDbEnWH0JVoLGwEIEbV)C4YjDUAEIEbvx)HoG0J4G0G(X1Pr4CfHGqNOhq1Z6XSvTTbXRpNJw1l9z91iG6673V6SEmBvBBq8tfH0NoUHd33VJ0OWJkK8Yg83WH7HeccDIEavpRhZw12geV(CU997myiiZ)IhZ6(6Iuvug41el2dSJjM2qcbHorpGQN1JzRABdIxFo6(673V61iNRgjeff)8XXG9icu)yHE6Zr3djee6e9aQEwpMTQTniE95O7Rf00JyOVNelfJbRDkckgFCcigKYdEdqjwGtIracI6IyboKE81Pe0Yt0l49NdxoPZvZt0lO66p0bKEehgS2P0Pr4qacI6Yuri9PJB4miHDY4O5hu6c8AGdPhFDkbn9ig6D5tFiMgSxyhxeRbILoNylIybojgp3xqVIXqNe7jX6qStI90lwkg6PV5HGwEIEbV)C4scpjGQXcHei0Pr4qacI6Yuri9Pd95WTp8Naee1LjKqrabT8e9cE)5WLeEsav1WCpjOLNOxW7phU4Au4XxrpGPq5rGqqlprVG3FoCHjrvxKAa7ZOxqtqtp6rm0H1ofbFbT8e9c(jdw7uCE8EGonchEfPJaXe0OWJps3icojqY4i1qigGqwikAgn4snwF2NkJlv0WxJCUAKquu8Zhhd2Jiq9Jf6DJpe0Yt0l4NmyTt5phU84yWEebQFSqpDAeoVg5C1iHOO41NdxhEfVo7acKGycOdCDluD)(zxNA5dMpbHzqQkZcO6R1JOPx6Z6bpHOONNo4jef9veyEIEbPtFo8EYvFC)(Rroxnsikk(5JJb7reO(Xc90x3xlOLNOxWpzWANYFoC5jimdsvzwavFTEePtJW5SRtT8bZNGWmivLzbu916r00l9z9GNqu0Zth8eII(kcmprVG0DdhEp5QpUF)xmhtduthLQkZLk5Z0tZrtcKmosnKxmyiithLQkZLk5Z0tZrtmT73)fZX0a1CenObFDx9cixdqnjqY4i1qEPigmeK5iAqd(kFyg4tmnbT8e9c(jdw7u(ZHlOC76X4sfjOLNOxWpzWANYFoCHjpJ(ize0e00JEeZ376ulFWlOPhXqFpjgpsWHeBrq4juhLymeYcjXcCsmKg(HypogShrG6hl0tme46jMFleKQvSZ6rVynykOLNOxWppQNZJNQLFvLGdPd2t1fbPI6O4WTonchEXGHGmF8uT8RQeCOjM2qgmeK5JJb7reOgleKQDIPnKbdbz(4yWEebQXcbPANqYlBWFdNBp9HGMEe7k0hWr)lw6GuQUigMMym0jXEsm(KyXUJeJfpvlFX079G9xlg2tIXEXJzDVylccpH6OeJHqwijwGtIH0WpeJfhd2JiGySXc9edbUEI53cbPAf7SE0lwdMcA5j6f8ZJ69Ndx(lEmR7RlsvrzGRd2t1fbPI6O4WTonchgmeK5JJb7reOgleKQDIPnKbdbz(4yWEebQXcbPANqYlBWFdNBp9HGwEIEb)8OE)5WfexIICUm6fOtJWzqc7KXrZhOQNfO6OxWqE9bLUaNutVeeoAidgcY8V4XSUVUivfLb(etB4z9y2Q22G41NJpe0Yt0l4Nh17phUmib9JRtJW5kigGqwikA6LWr1fPg4u1l)GG18)8)gm8SEmBvBBq8tfH0NoUHd38uKocetfrAeS(bmdcf5njqY4i197qmaHSqu0urzG7UuF8uT8)HN1JzRABdI)gUVEidgcY8V4XSUVUivfLb(etBidgcY8Xt1YVQsWHMyAd9Ypiyn)p)Vbvi5Ln45W7HmyiitfLbU7s9Xt1Y)NQLpqqtpI5l76edzHI53cbPAftds8e7YdX43bUyS48qmiLQlIXhNaIb2qmiga0auIXQ3tbT8e9c(5r9(ZHlA76Qq6xm4H0bzHva5ZGd360iCI0rGy(4yWEebQXcbPANeizCKAiVI0rGy(4PA5xr2d2pjqY4iLGMEed99Ky(TqqQwX0GKySlpeJpobeJpjgEoGelWjXiabrDrm(4uGtqXqGRNyA76AakX43b(IfIXQ3ITqXqpG9HyOiabtN7YuqlprVGFEuV)C4YJJb7reOgleKQvNgHdbiiQl6Zz849WbjStghnFGQEwGQJEbdp76ulFW8V4XSUVUivfLb(etB4zxNA5dMpEQw(vvco08GNqu0RphUhEfVGyaczHOO5YqQMah6(DfXGHGmrCjkY5YOxWet76HN1JzRABdI)goCD4v8IbdbzQbjps1rg9cMyA3V)AKZvJeIIIF(4yWEebQFSqp9191cA5j6f8ZJ69NdxEccZGuvMfq1xRhr6CUCCunsikkEoCRtJWzqc7KXrZhOQNfO6OxWqEP2y(eeMbPQmlGQVwpIQQnMrFg1audJeIIIz0Eun2QQj95WvUhE1z9y2Q22G4NkcPpDOpNRoAvuzd0xVSUV(6H8Ibdbz(4yWEebQXcbPANyAdVIxmyiitni5rQoYOxWet7(9xJCUAKquu8Zhhd2Jiq9Jf6PVUV((DKgfEuHKx2G)go(y4Rroxnsikk(5JJb7reO(Xc9U52cA5j6f8ZJ69NdxEs77xNgHZGe2jJJMpqvplq1rVGHN1JzRABdIFQiK(0H(C4wqtpIH(Esm2lEmR7fBbID21Pw(aXUkrcckgsd)qmwapUwmmGJ(xm(KyjKed12auIfRyARMy(TqqQwXsGsm1kgydXWZbKyS4PA5lMEVhSFkOLNOxWppQ3FoC5V4XSUVUivfLbUoncNbjStghnFGQEwGQJEbdVkshbIjbgqUvRbOQpEQw()KajJJu3VF21Pw(G5JNQLFvLGdnp4jef96ZH7RhEfVI0rGy(4yWEebQXcbPANeizCK6(9iDeiMpEQw(vK9G9tcKmosD)(zxNA5dMpogShrGASqqQ2jK8Yg86Z1RhEfVo7acKGyoGab(f497NDDQLpyI4suKZLrVGjK8Yg86ZnVVF)SRtT8btexIICUm6fmX0gEwpMTQTniE954JRf00JyJleXsL6flHKyyA6i2dAnsSaNeBbKy87axm3YN(qm)8JhtXqFpjgFCciM6sdqjgs(bbflWtGy(2xetri9PdXwOyGne7dkDboPeJFh4lwiwcUiMV9LPGwEIEb)8OE)5WfVeoIuvKfwvug464AavpkoCp9HoNlhhvJeIIINd360iCGzRQ0aceZuP(jM2WRIeIIIz0Eun2QQPBoRhZw12ge)uri9PJ7351hu6cCsntNB4z9y2Q22G4NkcPpDOpNJw1l9z91iG6Abn9i24crmWkwQuVy8BNtmvtIXVd8giwGtIbiFgIDBE)6ig2tIXZq4HylqmM9FX43b(IfILGlI5BFzkOLNOxWppQ3FoCXlHJivfzHvfLbUonchy2QknGaXmvQF2a9VnV5jy2QknGaXmvQFQWGz0ly4z9y2Q22G4NkcPpDOpNJw1l9z91iGsqlprVGFEuV)C4YJNQLFLXLk61Pr4miHDY4O5du1ZcuD0ly4z9y2Q22G4NkcPpDOphUo8QZUo1Yhm)lEmR7RlsvrzGpHKx2G)gUVFNbdbz(x8yw3xxKQIYaFIPD)osJcpQqYlBWFdhUY7Rf0Yt0l4Nh17phUqh8TbOQqsd2EjqPtJWzqc7KXrZhOQNfO6OxWWZ6XSvTTbXpvesF6qFoCD4vdsyNmoAI9uvd2lSJlv4gz0l4(9xJCUAKquu8Zhhd2Jiq9Jf6DdhDF)oedqilefnH0VyavdqvpUe2XLRf00Jy3sh4IXQ36iwJigydXshKs1fXulG0rmSNeZVfcs1kg)oWfJD5HyyAtbT8e9c(5r9(ZHlpogShrGASqqQwDAeor6iqmF8uT8Ri7b7NeizCKA4Ge2jJJMpqvplq1rVGHmyiiZ)IhZ6(6Iuvug4tmTHN1JzRABdI)goCD4v8IbdbzQbjps1rg9cMyA3V)AKZvJeIIIF(4yWEebQFSqp9191cA5j6f8ZJ69NdxE8uT8RQeCiDAeo8Ibdbz(4PA5xvj4qtmTHink8OcjVSb)nCg3(hPJaX8XyccIGHIMeizCKsqlprVGFEuV)C4cIJE8dmrcDAeox9lMJPbQPg2hyoQsqmTOxW97)I5yAGAoyDz0oQ(RBabIRhsacI6Yuri9Pd95CBEpKxFqPlWj1mDUHmyiiZ)IhZ6(6Iuvug4t1YhOtdcccX0IA75rQodId360GGGqmTOIYTmPJd360GGGqmTO2iC(fZX0a1CW6YODu9x3acecA5j6f8ZJ69Ndx02OxGonchgmeKjJBxLd7JjKYtC)osJcpQqYlBWFZT5997myiiZ)IhZ6(6Iuvug4tmTHxXGHGmF8uT8RmUur)et7(9ZUo1YhmF8uT8RmUur)esEzd(B4WnVVwqlprVGFEuV)C4cJBxvfbdErNgHddgcY8V4XSUVUivfLb(ettqlprVGFEuV)C4cdbFcoQbO0Pr4WGHGm)lEmR7RlsvrzGpX0e0Yt0l4Nh17phUG0qIXTRsNgHddgcY8V4XSUVUivfLb(ettqlprVGFEuV)C4sco0hW0vpPZPtJWHbdbz(x8yw3xxKQIYaFIPjOPhX4bHKyUqmK05yYZiXqwOyyFY4iX6G8(Bvm03tIXVdCXyV4XSUxSfrmEqzGpf0Yt0l4Nh17phUG9uTdY71Pr4WGHGm)lEmR7RlsvrzGpX0UFhPrHhvi5Ln4VHR8wqtqtp6rm9Ub9JtWxqtpIDl4TJed7BakX8fi5rQoYOxGoILd2wj2j)ObOeJ11hsSeOeJh9HeJpobeJfpvlFX4rcoKy9l2VlqSyfJHed7jLoIr(8qAHyilum9sxGDce0Yt0l4NinOFCodsyNmoshq6rC0GKhPQpqvplq1rVaDgKomItKocetni5rQoYOxWKajJJudFnY5QrcrrXpFCmypIa1pwO3nx5dE6SdiqcIjGoW1Tq11d51zhqGeeZrxGDce0Yt0l4NinOFC)5WL31hQMavv1hsNgHdVgKWozC0udsEKQ(av9Savh9cg(AKZvJeIIIF(4yWEebQFSqVBgVH8Ibdbz(4PA5xvj4qtmTHmyiiZ31hQMavv1hAcjVSb)nink8OcjVSb)qiHaPhpzCKGwEIEb)ePb9J7phU8U(q1eOQQ(q60iCgKWozC0udsEKQ(av9Savh9cgE21Pw(G5JNQLFvLGdnp4jef9veyEIEbP7gUNOFFmKbdbz(U(q1eOQQ(qti5Ln4V5SRtT8bZ)IhZ6(6Iuvug4ti5Ln4hE1zxNA5dMpEQw(vvco0esP6YqgmeK5FXJzDFDrQkkd8jK8Yg88edgcY8Xt1YVQsWHMqYlBWFd3tUETGMEetVi50iOy61jStghjgYcfBCW0cminfJDuRjMcd2auIXZYpiOy88)Z)BGylumfgSbOeJhj4qIXVdCX4rchjwcuIbwXgRrHhFKUreCkOLNOxWprAq)4(ZHldsyNmoshq6rC(rTwfIPfyqsNbPdJ44LFqWA(F(FdQqYlBWRpVVFNxr6iqmbnk84J0nIGtcKmosnmshbIPkHJQpEQw(tcKmosnKbdbz(4PA5xvj4qtmT73FnY5QrcrrXpFCmypIa1pwON(CUYh8eedqilefnrAq664Y1cA6rm9sePjgMMyJdMwGbjXAeX6qS(flzwSqSyfdIbeBXIPGwEIEb)ePb9J7phUaX0cmiPtJW5kEniHDY4O5pQ1QqmTads3VpiHDY4Oj2tvnyVWoUuHBKrVGRhgjeffZO9OASvvt8eK8Yg86pEdHecKE8KXrcA5j6f8tKg0pU)C4Ythif1Go4GwVcJe00Jy8mmx0QnIgGsSiHOO4flWZqm(TZjMRhqIHSqXcCsmfgmJEbITiInoyAbgK0rmiHaPhxmfgSbOetlbkYRptbT8e9c(jsd6h3FoCbIPfyqsNZLJJQrcrrXZHBDAeo8Aqc7KXrZFuRvHyAbgKgYRbjStghnXEQQb7f2XLkCJm6fm81iNRgjeff)8XXG9icu)yHE6ZHRdJeIIIz0Eun2QQj95CLp8)kU6RpRhZw12ge)1xpesiq6XtghjOPhXghcbspUyJdMwGbjXOe6UiwJiwhIXVDoXiFQ1qsmfgSbOeJ9IhZ6(Py8yflWZqmiHaPhxSgrm2LhIHIIxmiLQlI1aXcCsma5ZqmF8tbT8e9c(jsd6h3FoCbIPfyqsNgHdVgKWozC08h1AviMwGbPHqYlBWFZzxNA5dM)fpM191fPQOmWNqYlBW7p38E4zxNA5dM)fpM191fPQOmWNqYlBWFdhFmmsikkMr7r1yRQM4ji5Ln41)SRtT8bZ)IhZ6(6Iuvug4ti5Ln493hcA5j6f8tKg0pU)C4cJlpJQAlFfb1Pr4WRbjStghnXEQQb7f2XLkCJm6fm81iNRgjeffV(CUTGwEIEb)ePb9J7phUqd6)qWmibnbn9OhXydkDbUy(ExNA5dEbn9iMErYPrqX0RtyNmosqlprVGF(bLUaVEupNbjStghPdi9iopUQg4q6XxNsNbPdJ4C21Pw(G5JNQLFvLGdnp4jef9veyEIEbPtFoCpr)(qqtpIPxNG(XfRreJpjwcjXoPMwdqj2ceJhj4qIDWtik6NIHEmHUlIXqilKedPHFiMkbhsSgrm(Ky45asmWk2ynk84J0nIGIXGfIXJeosmw8uT8fRbITqfbflwXqrHyJdMwGbjXW0e7kWkgpl)GGIXZ)p)Vbxpf0Yt0l4NFqPlWRh17phUmib9JRtJW5kEniHDY4O5JRQboKE81PUFNxr6iqmbnk84J0nIGtcKmosnmshbIPkHJQpEQw(tcKmosD9WZ6XSvTTbXpvesF6qFUhYligGqwikA6LWr1fPg4u1l)GG18)8)giOPhX8LDDIHSqXyXt1Y3JCkX8xmw8uT8)a2JiXWao6FX4tILqsSKzXcXIvStQj2ceJhj4qIDWtik6NI5RaCxeJpobetVBGsSBHYra6FX6xSKzXcXIvmigqSflMcA5j6f8ZpO0f41J69Ndx021vH0VyWdPdYcRaYNbhU1H8zaZA6TyGGJU5TonchyEOjOrHhvYHiOLNOxWp)GsxGxpQ3FoC5Xt1Y3JCkDAeoeGGOUOphDZ7HeGGOUmvesF6qFoCZ7H8Aqc7KXrZhxvdCi94Rtn8SEmBvBBq8tfH0No0N7HkIbdbzI0avLpLJa0)ti5Ln4VHBbn9iMV9fXcCi94Rt9IHSqXiqqWgGsmw8uT8fJhj4qcA5j6f8ZpO0f41J69NdxgKWozCKoG0J484Q6z9y2Q22G41zq6WioN1JzRABdIFQiK(0H(C4Q)myiiZhpvl)kJlv0pX0e0Yt0l4NFqPlWRh17phUmiHDY4iDaPhX5Xv1Z6XSvTTbXRZG0HrCoRhZw12ge)uri9Pd95CBDAeoNDabsqmhDb2jqqlprVGF(bLUaVEuV)C4YGe2jJJ0bKEeNhxvpRhZw12geVodshgX5SEmBvBBq8tfH0NoUHd360iCgKWozC0e7PQgSxyhxQWnYOxWWxJCUAKquu8Zhhd2Jiq9Jf6PphDlOPhX4rcoKykmydqjg7fpM19ITqXsMDajwGdPhFDQPGwEIEb)8dkDbE9OE)5WLhpvl)QkbhsNgHZGe2jJJMpUQEwpMTQTni(HxniHDY4O5JRQboKE81PUFNbdbz(x8yw3xxKQIYaFcjVSbV(C4EY173FnY5QrcrrXpFCmypIa1pwON(C09WZUo1Yhm)lEmR7RlsvrzGpHKx2GxFU591cA6rm0HbbIbjVSbnaLy8ibh6fJHqwijwGtIH0OWdXiG6fRreJD5Hy8xGUcXyiXGuQUiwdelApAkOLNOxWp)GsxGxpQ3FoC5Xt1YVQsWH0Pr4miHDY4O5JRQN1JzRABdIFisJcpQqYlBWFZzxNA5dM)fpM191fPQOmWNqYlBWlOjOPh9igBqPlWjLyJZgz0lqqtpInUqeJnO0f4Czqc6hxSesIHPPJyypjglEQw(Fa7rKyXkgdbiKoedbUEIf4KyA5)9asmMfG9ILaLy6DduIDluocq)RJy0aciwJigFsSesILHyEPpfZ3(IyxHbC0)IH9naLy8S8dckgp))8)gCTGwEIEb)8dkDboP484PA5)bShr60iCUIbdbz(bLUaFIPD)odgcYCqc6hFIPD9qV8dcwZ)Z)BqfsEzdEo8wqtpIP3nOFCXYqSB7Vy(2xeJFh4lwigpyfJlIPB)fJFh4IXdwX43bUyS4yWEebeZVfcs1kgdgcIyyAIfRy5GTvI9RhjMV9fX4NFqI9DGLrVGFkOPhX45UFf7tesSyfdPb9JlwgIPB)fZ3(Iy87axmYN5jCxet3Ifjeff)uSRytpsS8fBXIVvKyFqPlWNxlOPhX07g0pUyziMU9xmF7lIXVd8fleJhS6iMp8xm(DGlgpy1rSeOeB8eJFh4IXdwXsKGGIPxNG(Xf0Yt0l4NFqPlWjL)C4YjDUAEIEbvx)HoG0J4G0G(X1Pr4qii0j6bu9SEmBvBBq86Z5Ov9sFwFncOUFNbdbz(4yWEebQXcbPANyAdpRhZw12ge)uri9PJB4W173FnY5QrcrrXpFCmypIa1pwON(C09qcbHorpGQN1JzRABdIxFo6((9Z6XSvTTbXpvesF64goCZtxfPJaXurKgbRFaZirrEtcKmosnKbdbzoib9JpX0UwqlprVGF(bLUaNu(ZHlpEQw(Fa7rKoncNpO0f4KA(K23)WxJCUAKquu8Zhhd2Jiq9Jf6DJUf0Yt0l4NFqPlWjL)C4YJ3d0Pr4ePJaXe0OWJps3icojqY4i1qigGqwikAgn4snwF2NkJlv0WxJCUAKquu8Zhhd2Jiq9Jf6DJpe00JyOpnXIvSBlwKquu8IDfyftd271InIinXW0etVBGsSBHYra6FXyUi25YX1auIXINQL)hWEenf0Yt0l4NFqPlWjL)C4YJNQL)hWEePZ5YXr1iHOO45WTonchEniHDY4Oj2tvnyVWoUuHBKrVGHkIbdbzI0avLpLJa0)ti5Ln4VH7HVg5C1iHOO4NpogShrG6hl07go3EyKquumJ2JQXwvnXtqYlBWR)4jOPhX07fkMgSxyhxedUrg9c0rmSNeJfpvl)pG9isSDabfJnwONy87axSBHNjwIkBWhIHPjwSIPBXIeIIIxSfkwJiMEFlI1VyqmaObOeBrqe7QfiwcUiw6TyGqSfrSiHOO4VwqlprVGF(bLUaNu(ZHlpEQw(Fa7rKoncNbjStghnXEQQb7f2XLkCJm6fm8kfXGHGmrAGQYNYra6)jK8Yg83W997r6iqm5tP2c8Ypi4KajJJudFnY5QrcrrXpFCmypIa1pwO3nC091cA5j6f8ZpO0f4KYFoC5XXG9icu)yHE60iCEnY5QrcrrXRpNB7)vmyiiZaNQWnccmX0UFhIbiKfIIM5OmH9x)fZvrGjkpcexp8kgmeK5FXJzDFDrQkkd8AIf7b2Xet7(DEXGHGm1GKhP6iJEbtmT73FnY5QrcrrXRphFCTGMEeJfpvl)pG9isSyfdsiq6XftVBGsSBHYra6FXsGsSyfJapgKeJpj2jbIDsi8Iy7ackwkgcMZjMEFlI1GyflWjXaKpdXyxEiwJiM2(FZ4OPGwEIEb)8dkDboP8NdxE8uT8)a2JiDAeokIbdbzI0avLpLJa0)ti5Ln4VHd33VF21Pw(G5FXJzDFDrQkkd8jK8Yg83W94EOIyWqqMinqv5t5ia9)esEzd(Bo76ulFW8V4XSUVUivfLb(esEzdEbT8e9c(5hu6cCs5phUGYTRhJlvKonchgmeKPgbrwygKQoGAWp)ipJ0NJpgEwGcRJPgbrwygKQoGAWpHjyK(C4(2cA5j6f8ZpO0f4KYFoC5Xt1Y)dypIe0Yt0l4NFqPlWjL)C4YbNsT6JVHonchEfjeffZ(Rm7)dpRhZw12ge)uri9Pd95W9qgmeK5JVrTb1aNQQeoAIPnKaee1Lz0Eun2QU5T(OoQPx6Zc7RrNYyCD84UeLOuaa]] )

    
end
