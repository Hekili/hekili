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


    spec:RegisterPack( "Subtlety", 20210829, [[devIacqiuP8iQKAtuv9jQkzuQK6uQKSkQuLELuKzrL4wOkXUKQFHkXWOsLJHQyzqkEMkv10qvQRrLKTrvP8nQkkJtLO05uPkADOsI5PsL7Hk2hvk)dvjPoiQKQfcP0dvjYerLQlQsvOnsLQ6JOkjgjvQcoPkrXkHu9sQufAMOsk3evj1ovj8tQkQmuQkYsPQu9uuAQsrDvujPTsLQOVQsunwvQsNfvjjTxj(RKgmLdlAXO4XQyYKCzKndXNHKrdvNwXQvPk41sjZMu3MQSBGFR0WPIJtvrvlh0Zv10fUou2Uu47OQgpvfoVuQ1JQKeZxLY(jUWtP5cRkdQCbAChA4XDxw0Cp784BUYvUY3kSrBhQW6KNwjkQWcspQWYIXeAkAxyDY26nvLMlS)IbpuHfpcNNRWfUGAcCmM(z94YpEy6mMfCGjsWLF8oCPWYGn64Yakmfwvgu5c04o0WJ7USO5E25X3CLRC19lSjwGVWcl74DPcl(OueOWuyv0FkSSymHMI2I57lkmsqNRJHc7dXqZ90fXqJ7qdpc6c6xcpbOONRiOZlIXR3gKyns4KmAQJ9u1bolCI2v4gzmlqmmhX(vSjeBEXEkeJHqwijgFsmSNeBIUGoVi2LwpMbqI5HPJXrtIDsTUMNywqvpFigbc4qVyXkgKuyhsmNniqmPwmiXFHT6c68Iy86SfjM7RPh)atKqSbeeeI5eInaXoRhtgIniIXNe7Ea7dXuJsSjedzHI1y1zmAQ(RUbbIEHvpF8LMlSFqPoWjvP5Yf8uAUWsGKrtQcAlS5jMfuyF8uT8)aoTOcRI(dCCIzbf2ldIySbL6aNlnsW84ILqsmmhxed7jXyXt1Y)d40IelwXyiaHmHyiW1tSaNeZj)FAqIXSaSxSeOeZ9hGsSlNYwa6FxeJAqaXgeX4tILqsSmeZl9HyxYNe7AmGM(xmSFaOeJxNFqqX46)N)pGRkSh4eeCYc71IXGHG0)GsDG3XCe72nXyWqq6nsW84DmhXUsm)IDTyVdP11iHOO47pogCArG6hl0tS7eJ3ID7Myns4KmAQJ9u1bolCI2v4gzmlqSReZVyE5heSM)N)pGkK8Yb8IXrm3vIYfOP0CHLajJMuf0wyv0FGJtmlOW6(dyECXYqmE3KyxYNeJ)e4lwig3zDrmx1Ky8NaxmUZ6IyjqjMVjg)jWfJ7SILibbfZ9mbZJxyZtmlOWEsTUMNywqvpFuypWji4KfwcbHoX0GQN1JzRo7aIxm34i2XP6L(O(oeqj2TBIXGHG0FCm40Ia1yHGuTDmhX8l2z9y2QZoG47kczoti2DCednID7MyVdP11iHOO47pogCArG6hl0tm34igVfZVyeccDIPbvpRhZwD2beVyUXrmEl2TBIDwpMT6Sdi(UIqMZeIDhhX4rmErSRflsnbIUIihcw)aMrII86eiz0Ksm)IXGHG0BKG5X7yoIDvHvpFubPhvyrgW84LOCX9lnxyjqYOjvbTf2dCccozH9dk1boP6p58ZlMFXEhsRRrcrrX3FCm40Ia1pwONy3jgVlS5jMfuyF8uT8)aoTOsuUG3LMlSeiz0KQG2c7bobbNSWgPMarhmOWJpsDlc2jqYOjLy(fdIbiKfII6XaAxJ1hZPYOtf1jqYOjLy(f7DiTUgjeffF)XXGtlcu)yHEIDNyUQWMNywqH9XNgLOCHRknxyjqYOjvbTf28eZckSpEQw(FaNwuH90(OPAKquu8Ll4PWEGtqWjlSCtSgjCsgn1XEQ6aNfor7kCJmMfiMFXuedgcshzaQkFkBbO)7qYlhWl2DIXJy(f7DiTUgjeffF)XXGtlcu)yHEIDhhXUVy(flsikk6X4r1yRQHeJxedsE5aEXCtmFRWQO)ahNywqHLR6iwSIDFXIeIIIxSRbRyoWzVsSwe5igMJyU)auID5u2cq)lgtBXoTp6bGsmw8uT8)aoTOEjkx4BLMlSeiz0KQG2cBEIzbf2hpvl)pGtlQWQO)ahNywqH19xOyoWzHt0wm4gzmlWfXWEsmw8uT8)aoTiX2geum2yHEIXFcCXUCETyjQCaFigMJyXkgVflsikkEXwOydIyU)Ll28IbXaGbGsSfbrSRxGyjOTyP3IbcXweXIeIII)Qc7bobbNSW2iHtYOPo2tvh4SWjAxHBKXSaX8l21IPigmeKoYauv(u2cq)3HKxoGxS7eJhXUDtSi1ei68P0zbE5heStGKrtkX8l27qADnsikk((JJbNweO(Xc9e7ooIXBXUQeLl8zLMlSeiz0KQG2c7bobbNSW(oKwxJeIIIxm34i29fRjXUwmgmeKEGtv4gbb6yoID7MyqmaHSquupBLjC(6Vy6kcmr5rGOtGKrtkXUsm)IDTymyii9VThZQ)6Iuvug41el2dCIoMJy3Ujg3eJbdbP7ajpsnrgZc6yoID7MyVdP11iHOO4fZnoI5kXUQWMNywqH9XXGtlcu)yHELOCXLT0CHLajJMuf0wyZtmlOW(4PA5)bCArfwf9h44eZckSS4PA5)bCArIfRyqcbspUyU)auID5u2cq)lwcuIfRye4XGKy8jXojqStcHTfBBqqXsXqW0AXC)lxSbeRybojgG8rig7YDXgeXC2)hgn1lSh4eeCYcRIyWqq6idqv5tzla9FhsE5aEXUJJy8i2TBID2vRw(G(32Jz1FDrQkkd8oK8Yb8IDNy8CzfZVykIbdbPJmavLpLTa0)Di5Ld4f7oXo7QvlFq)B7XS6VUivfLbEhsE5a(suU4EwAUWsGKrtQcAlSh4eeCYcldgcs3HGilmdsvBqd47FKNwI5ghXCLy(f7Saf2eDhcISWmivTbnGVdtqlXCJJy8C)cBEIzbfwu6D9y0PIkr5cECxP5cBEIzbf2hpvl)pGtlQWsGKrtQcAlr5cE4P0CHLajJMuf0wypWji4KfwUjwKquu0NVYS)lMFXoRhZwD2beFxriZzcXCJJy8iMFXyWqq6p(g1budCQQsyRoMJy(fJaeev7EmEun2kVDNyUjgQJQ7L(OWMNywqH9GtPt9X3OeLOWQiKethLMlxWtP5cBEIzbf2wZPvHLajJMuf0wIYfOP0CHLajJMuf0wyxNc7trHnpXSGcBJeojJMkSnsngvyzWqq6VEounbQQAouhZrSB3e7DiTUgjeffF)XXGtlcu)yHEI5ghX8TcRI(dCCIzbfwU6tkXIvmffe0BaKy8XPaNGID2vRw(Gxm(5eIHSqXybCxmM8jLylqSiHOO47f2gjScspQW(av9Sa1eZckr5I7xAUWsGKrtQcAlSRtH9POWMNywqHTrcNKrtf2gPgJkSoWzHt0Uc3iJzbI5xS3H06AKquu89hhdoTiq9Jf6jMBCednfwf9h44eZckS(CaDBXo4jafjgCJmMfi2GigFsm8SbjMdCw4eTRWnYywGypfILaLyEy6yC0KyrcrrXlgMtVW2iHvq6rfwSNQoWzHt0Uc3iJzbLOCbVlnxyjqYOjvbTf21PW(uuyZtmlOW2iHtYOPcBJuJrfw04kXAsSi1ei6ngulStGKrtkXCVIHg3jwtIfPMar3l)GG1fP(4PA5)DcKmAsjM7vm04oXAsSi1ei6pEQw(vK9G9DcKmAsjM7vm04kXAsSi1ei6PopWjA3jqYOjLyUxXqJ7eRjXqJReZ9k21I9oKwxJeIIIV)4yWPfbQFSqpXCJJy8wSRkSk6pWXjMfuy5QpPelwXueYaiX4JtaXIvmSNe7dk1bUyxI7VylumgSrRi4xyBKWki9Oc7huQd8AGdPhF1QsuUWvLMlSeiz0KQG2cRI(dCCIzbf2lHtNwIDjU)ILHyid8JcBEIzbf2tQ118eZcQ65JcRE(OcspQWEuFjkx4BLMlSeiz0KQG2cRI(dCCIzbfwFhdigcMw3wSN)ehC6flwXcCsm2GsDGtkX89nYywGyxZ0wm1oauI9RlInHyil8qVyo7QhakXgeXaBGpauInVyzJC0jJMUQxyZtmlOWcXa18eZcQ65Jc7bobbNSW(bL6aNu9uRlS65Jki9Oc7huQdCsvIYf(SsZfwcKmAsvqBHnpXSGc7RNdvtGQQMdvyv0FGJtmlOWY1DC0TfJvphsSeOeJ7ZHeldXqttIDjFsmfgCaOelWjXqg4hIXJ7e7PZcuVlILibbflWZqmE3KyxYNeBqeBcXiF4mq6fJ)e4dqSaNedq(ieJx5sCxSfk28Ib2qmmNc7bobbNSW(oKwxJeIIIV)4yWPfbQFSqpXUtmFtm)IHmOWJkK8Yb8I5My(My(fJbdbP)65q1eOQQ5qDi5Ld4f7oXqDuDV0hI5xSZ6XSvNDaXlMBCeJ3IXlIDTyX4rIDNy84oXUsm3RyOPeLlUSLMlSeiz0KQG2cRI(dCCIzbfwFcolCI2I57BKXSaE1IX1OWxVyOMgKyPyhy6iwYSyHyeGGOAlgYcflWjX(GsDGl2L4(l21myJwrqX(y0AXG07qNqSjUQlgVQyoUi2eIDsGymKybEgI9JNJM6f28eZckSNuRR5jMfu1Zhf2dCccozHTrcNKrtDSNQoWzHt0Uc3iJzbfw98rfKEuH9dk1bE9O(suU4EwAUWsGKrtQcAlSk6pWXjMfuyV0c(rrqXW(bGsSum2GsDGl2L4Uy8XjGyqkp4daLybojgbiiQ2If4q6XxTQWMNywqH9KADnpXSGQE(OWEGtqWjlSeGGOA3veYCMqS74iwJeojJM6FqPoWRboKE8vRkS65Jki9Oc7huQd86r9LOCbpUR0CHLajJMuf0wypWji4Kf2RfJqqOtmnO6z9y2QZoG4fZnoIDCQEPpQVdbuIDLy3Uj21IDwpMT6Sdi(UIqMZeIDhhX4rSB3edzqHhvi5Ld4f7ooIXJy(fJqqOtmnO6z9y2QZoG4fZnoIDFXUDtmgmeK(32Jz1FDrQkkd8AIf7borhZrm)Irii0jMgu9SEmB1zhq8I5ghX4Tyxj2TBIDTyVdP11iHOO47pogCArG6hl0tm34igVfZVyeccDIPbvpRhZwD2beVyUXrmEl2vf28eZckSNuRR5jMfu1Zhfw98rfKEuHfzaZJxIYf8WtP5clbsgnPkOTWQO)ahNywqHLR(KyPymyJwrqX4JtaXGuEWhakXcCsmcqquTflWH0JVAvHnpXSGc7j16AEIzbv98rH9aNGGtwyjabr1URiK5mHy3XrSgjCsgn1)GsDGxdCi94Rwvy1Zhvq6rfwgSrRkr5cEqtP5clbsgnPkOTWMNywqHnHNeq1yHqcefwf9h44eZckSCTLp9HyoWzHt0wSbiwQ1ITiIf4KyCDFIRjgdDsSNeBcXoj2tVyPy8kxI7f2dCccozHLaeev7UIqMZeI5ghX4XvI1KyeGGOA3HekcuIYf8C)sZf28eZckSj8KaQ6GPFQWsGKrtQcAlr5cE4DP5cBEIzbfw9Gcp(69aMcLhbIclbsgnPkOTeLl4XvLMlS5jMfuyzsu1fPgW506lSeiz0KQG2suIcRdKoRhtgLMlxWtP5cBEIzbf20Xr3U6SZVGclbsgnPkOTeLlqtP5cBEIzbfwMncnPQi6SnP4pau1y9XakSeiz0KQG2suU4(LMlSeiz0KQG2c7bobbNSW(lMMzaQUd2hyAQsqmNywqNajJMuID7My)IPzgGQ3y1zmAQ(RUbbIobsgnPkS5jMfuyr00JFGjsuIYf8U0CHnpXSGc7huQd8clbsgnPkOTeLlCvP5clbsgnPkOTWMNywqH1lHTivfzHvfLbEH1bsN1JjJ6tNfO(clpUQeLl8TsZfwcKmAsvqBHnpXSGc7RNdvtGQQMdvypWji4KfwiHaPhpz0uH1bsN1JjJ6tNfO(clpLOCHpR0CHLajJMuf0wypWji4KfwigGqwikQ7LWw1fPg4u1l)GG18)8)b0jqYOjvHnpXSGc7JNQLFLrNk6lrjkSidyE8sZLl4P0CHLajJMuf0wyxNc7trHnpXSGcBJeojJMkSnsngvyJutGO7ajpsnrgZc6eiz0Ksm)I9oKwxJeIIIV)4yWPfbQFSqpXUtSRfZvIXlID2geibrhqh4QxOsSReZVyCtSZ2Gaji6TAdNeuyv0FGJtmlOWE54JMed7hakX8ji5rQjYywGlILn2rj2j)yaOeJvphsSeOeJ7ZHeJpobeJfpvlFX4EcoKyZl2VlqSyfJHed7jLlIr(4qoHyilum3JTHtckSnsyfKEuH1bsEKQ(av9Sa1eZckr5c0uAUWsGKrtQcAlSh4eeCYcl3eRrcNKrtDhi5rQ6du1Zcutmlqm)I9oKwxJeIIIV)4yWPfbQFSqpXUtmFtm)IXnXyWqq6pEQw(vvcouhZrm)IXGHG0F9COAcuv1COoK8Yb8IDNyidk8OcjVCaVy(fdsiq6XtgnvyZtmlOW(65q1eOQQ5qLOCX9lnxyjqYOjvbTf2dCccozHTrcNKrtDhi5rQ6du1Zcutmlqm)ID2vRw(G(JNQLFvLGd1p4jef9veyEIzbPwS7eJNUpZvI5xmgmeK(RNdvtGQQMd1HKxoGxS7e7SRwT8b9VThZQ)6Iuvug4Di5Ld4fZVyxl2zxTA5d6pEQw(vvcouhsPQTy(fJbdbP)T9yw9xxKQIYaVdjVCaVy8Iymyii9hpvl)QkbhQdjVCaVy3jgpD0i2vf28eZckSVEounbQQAoujkxW7sZfwcKmAsvqBHDDkSpff28eZckSns4KmAQW2i1yuH1l)GG18)8)buHKxoGxm3eZDID7MyCtSi1ei6GbfE8rQBrWobsgnPeZVyrQjq0vjSv9Xt1YVtGKrtkX8lgdgcs)Xt1YVQsWH6yoID7MyVdP11iHOO47pogCArG6hl0tm34igVlSk6pWXjMfuyDpqAhckM7zcNKrtIHSqX8DmNadsDXyBnoIPWGdaLy868dckgx))8)bi2cftHbhakX4EcoKy8NaxmUNWwILaLyGvSlgu4XhPUfb7f2gjScspQW(TgNkeZjWGujkx4QsZfwcKmAsvqBHnpXSGcleZjWGuHvr)booXSGcR7rICedZrmFhZjWGKydIyti28ILmlwiwSIbXaITyrVWEGtqWjlSxlg3eRrcNKrt9V14uHyobgKe72nXAKWjz0uh7PQdCw4eTRWnYywGyxjMFXIeIIIEmEun2QAiX4fXGKxoGxm3eZ3eZVyqcbspEYOPsuUW3knxyZtmlOW(0bsrnOdoy85XOclbsgnPkOTeLl8zLMlSeiz0KQG2cBEIzbfwiMtGbPc7P9rt1iHOO4lxWtH9aNGGtwy5Myns4KmAQ)TgNkeZjWGKy(fJBI1iHtYOPo2tvh4SWjAxHBKXSaX8l27qADnsikk((JJbNweO(Xc9eZnoIHgX8lwKquu0JXJQXwvdjMBCe7AXCLynj21IHgXCVIDwpMT6SdiEXUsSReZVyqcbspEYOPcRI(dCCIzbfwEnMog1gXaqjwKquu8If4zig)rRftpniXqwOybojMcdMXSaXweX8DmNadsUigKqG0JlMcdoauI5Kaf5nNEjkxCzlnxyjqYOjvbTf28eZckSqmNadsfwf9h44eZckS(oHaPhxmFhZjWGKyuc1TfBqeBcX4pATyKpCgijMcdoauIX22Jz1FxmUVIf4zigKqG0Jl2Gig7YDXqrXlgKsvBXgGybojgG8riMR(EH9aNGGtwy5Myns4KmAQ)TgNkeZjWGKy(fdsE5aEXUtSZUA1Yh0)2EmR(RlsvrzG3HKxoGxSMeJh3jMFXo7QvlFq)B7XS6VUivfLbEhsE5aEXUJJyUsm)Ifjeff9y8OASv1qIXlIbjVCaVyUj2zxTA5d6FBpMv)1fPQOmW7qYlhWlwtI5QsuU4EwAUWsGKrtQcAlSh4eeCYcl3eRrcNKrtDSNQoWzHt0Uc3iJzbI5xS3H06AKquu8I5ghXUFHnpXSGclJopTQolFfblr5cECxP5cBEIzbfwQX8hcMbvyjqYOjvbTLOef2J6lnxUGNsZfwcKmAsvqBH9aNGGtwy5Mymyii9hpvl)QkbhQJ5iMFXyWqq6pogCArGASqqQ2oMJy(fJbdbP)4yWPfbQXcbPA7qYlhWl2DCe7(DxvyXEQUiivuhv5cEkS5jMfuyF8uT8RQeCOcRI(dCCIzbfwU6tIX9eCiXweeEb1rjgdHSqsSaNedzGFi2JJbNweO(Xc9edbUEI18cbPAf7SE0l2a6LOCbAknxyjqYOjvbTf2dCccozHLbdbP)4yWPfbQXcbPA7yoI5xmgmeK(JJbNweOgleKQTdjVCaVy3XrS73DvHf7P6IGurDuLl4PWMNywqH9B7XS6VUivfLbEHvr)booXSGc71CvGM(xSudPu1wmmhXyOtI9Ky8jXIDBjglEQw(I5(7b7VsmSNeJTThZQFXweeEb1rjgdHSqsSaNedzGFiglogCAraXyJf6jgcC9eR5fcs1k2z9OxSb0lr5I7xAUWsGKrtQcAlSh4eeCYcBJeojJM6pqvplqnXSaX8lg3e7dk1boP6Eji0Ky(fJbdbP)T9yw9xxKQIYaVJ5iMFXoRhZwD2beVyUXrmxvyZtmlOWIOtuKwNXSGsuUG3LMlSeiz0KQG2c7bobbNSWETyqmaHSquu3lHTQlsnWPQx(bbR5)5)dOtGKrtkX8l2z9y2QZoG47kczoti2DCeJhX4fXIutGORiYHG1pGzqOiVobsgnPe72nXGyaczHOOUIYax3U(4PA5)DcKmAsjMFXoRhZwD2beVy3jgpIDLy(fJbdbP)T9yw9xxKQIYaVJ5iMFXyWqq6pEQw(vvcouhZrm)I5LFqWA(F()aQqYlhWlghXCNy(fJbdbPROmW1TRpEQw(FxT8bf28eZckSnsW84LOCHRknxyjqYOjvbTfwf9h44eZckS(0UAXqwOynVqqQwXCGeVWUCxm(tGlglo3fdsPQTy8XjGyGnedIbadaLySUFVWISWkG8ruUGNc7bobbNSWgPMar)XXGtlcuJfcs12jqYOjLy(fJBIfPMar)Xt1YVIShSVtGKrtQcBEIzbfwND1vi9lg8qLOCHVvAUWsGKrtQcAlS5jMfuyFCm40Ia1yHGuTfwf9h44eZckSC1NeR5fcs1kMdKeJD5Uy8XjGy8jXWZgKybojgbiiQ2IXhNcCckgcC9eZzx9aqjg)jWxSqmw3xSfk29a2hIHIaem1629c7bobbNSWsacIQTyUXrmFZDI5xSgjCsgn1FGQEwGAIzbI5xSZUA1Yh0)2EmR(RlsvrzG3XCeZVyND1QLpO)4PA5xvj4q9dEcrrVyUXrmEeZVyxlg3edIbiKfII6ldPgcCOobsgnPe72nXuedgcshrNOiToJzbDmhXUDtS3H06AKquu89hhdoTiq9Jf6jMBCe7AX4rSMeJ3I5Ef7AX4MyrQjq0bdk84Ju3IGDcKmAsjMFX4MyrQjq0vjSv9Xt1YVtGKrtkXUsSRe7kX8l2z9y2QZoG4f7ooIHgX8l21IXnXyWqq6oqYJutKXSGoMJy3Uj27qADnsikk((JJbNweO(Xc9eZnX4TyxjMFXUwmUj2zBqGee9geiWBdf72nX4MyND1QLpOJOtuKwNXSGoMJyxvIYf(SsZfwcKmAsvqBHnpXSGc7tqygKQYSaQ(otlQWEGtqWjlSns4KmAQ)av9Sa1eZceZVyCtm1g9NGWmivLzbu9DMwuvTrpMtRbGsm)Ifjeff9y8OASv1qI5ghXqdpI5xSRf7SEmB1zhq8DfHmNjeZnoIDTyhNkQCaI5gVAX4Tyxj2vI5xmUjgdgcs)XXGtlcuJfcs12XCeZVyxlg3eJbdbP7ajpsnrgZc6yoID7MyVdP11iHOO47pogCArG6hl0tm3eJ3IDLy3UjgYGcpQqYlhWl2DCeZvI5xS3H06AKquu89hhdoTiq9Jf6j2DID)c7P9rt1iHOO4lxWtjkxCzlnxyjqYOjvbTf2dCccozHTrcNKrt9hOQNfOMywGy(f7SEmB1zhq8DfHmNjeZnoIXtHnpXSGc7to)8LOCX9S0CHLajJMuf0wyZtmlOW(T9yw9xxKQIYaVWQO)ahNywqHLR(KyST9yw9l2ce7SRwT8bIDDIeeumKb(HySaUFLyyan9Vy8jXsijgQDaOelwXCwhXAEHGuTILaLyQvmWgIHNniXyXt1Yxm3FpyFVWEGtqWjlSns4KmAQ)av9Sa1eZceZVyxlwKAceDc0G0RZaqvF8uT8)obsgnPe72nXo7QvlFq)Xt1YVQsWH6h8eIIEXCJJy8i2vI5xSRfJBIfPMar)XXGtlcuJfcs12jqYOjLy3UjwKAce9hpvl)kYEW(obsgnPe72nXo7QvlFq)XXGtlcuJfcs12HKxoGxm3ednIDLy(f7AX4MyNTbbsq0BqGaVnuSB3e7SRwT8bDeDII06mMf0HKxoGxm3eJh3j2TBID2vRw(GoIorrADgZc6yoI5xSZ6XSvNDaXlMBCeZvIDvjkxWJ7knxyjqYOjvbTf28eZckSEjSfPQilSQOmWlS6bq1JQWYt3vf2t7JMQrcrrXxUGNc7bobbNSWcZrvPgei6Ps9DmhX8l21Ifjeff9y8OASv1qIDNyN1JzRo7aIVRiK5mHy3Ujg3e7dk1boP6PwlMFXoRhZwD2beFxriZzcXCJJyhNQx6J67qaLyxvyv0FGJtmlOWEzqelvQxSesIH54IypyCiXcCsSfqIXFcCX0lF6dXAUzU3fJR(Ky8XjGyQ2daLyi5heuSapbIDjFsmfHmNjeBHIb2qSpOuh4Ksm(tGVyHyjOTyxYN6LOCbp8uAUWsGKrtQcAlS5jMfuy9sylsvrwyvrzGxyv0FGJtmlOWEzqedSILk1lg)rRftnKy8NaFaIf4KyaYhHy33DVlIH9Ky8AeUl2ceJz)xm(tGVyHyjOTyxYN6f2dCccozHfMJQsniq0tL67dqm3e7(UtmErmyoQk1GarpvQVRWGzmlqm)IDwpMT6Sdi(UIqMZeI5ghXoovV0h13HaQsuUGh0uAUWsGKrtQcAlSh4eeCYcBJeojJM6pqvplqnXSaX8l2z9y2QZoG47kczotiMBCednI5xSRfJbdbP)T9yw9xxKQIYaVJ5i2TBIXS)lMFXqgu4rfsE5aEXUJJyOXDIDvHnpXSGc7JNQLFLrNk6lr5cEUFP5clbsgnPkOTWEGtqWjlSns4KmAQ)av9Sa1eZceZVyN1JzRo7aIVRiK5mHyUXrm0iMFXUwSgjCsgn1XEQ6aNfor7kCJmMfi2TBI9oKwxJeIIIV)4yWPfbQFSqpXUJJy8wSB3edIbiKfII6q6xmGAaOQhDcNODNajJMuIDvHnpXSGclDW3bGQcjh44LavjkxWdVlnxyjqYOjvbTf28eZckSpogCArGASqqQ2cRI(dCCIzbf2lFcCXyDFxeBqedSHyPgsPQTyQfqUig2tI18cbPAfJ)e4IXUCxmmNEH9aNGGtwyJutGO)4PA5xr2d23jqYOjLy(fRrcNKrt9hOQNfOMywGy(fJbdbP)T9yw9xxKQIYaVJ5iMFXoRhZwD2beVy3Xrm0iMFXUwmUjgdgcs3bsEKAImMf0XCe72nXEhsRRrcrrX3FCm40Ia1pwONyUjgVf7QsuUGhxvAUWsGKrtQcAlSh4eeCYcl3eJbdbP)4PA5xvj4qDmhX8lgYGcpQqYlhWl2DCe7YkwtIfPMar)XyccIGHI6eiz0KQWMNywqH9Xt1YVQsWHkr5cE8TsZfwcKmAsvqBH9aNGGtwyVwSFX0mdq1DW(attvcI5eZc6eiz0KsSB3e7xmnZau9gRoJrt1F1niq0jqYOjLyxjMFXiabr1URiK5mHyUXrS77oX8lg3e7dk1boP6PwlMFXyWqq6FBpMv)1fPQOmW7QLpOWoGGGqmNOoif2FX0mdq1BS6mgnv)v3GarHDabbHyorD88i1Kbvy5PWMNywqHfrtp(bMirHDabbHyorfLEzsDHLNsuUGhFwP5clbsgnPkOTWEGtqWjlSmyiiDg9Ukn2hDiLNqSB3edzqHhvi5Ld4f7oXUV7e72nXyWqq6FBpMv)1fPQOmW7yoI5xSRfJbdbP)4PA5xz0PI(oMJy3Uj2zxTA5d6pEQw(vgDQOVdjVCaVy3XrmECNyxvyZtmlOW6SXSGsuUGNlBP5clbsgnPkOTWEGtqWjlSmyii9VThZQ)6Iuvug4DmNcBEIzbfwg9UQkcgSDjkxWZ9S0CHLajJMuf0wypWji4KfwgmeK(32Jz1FDrQkkd8oMtHnpXSGcldbFc2AaOkr5c04UsZfwcKmAsvqBH9aNGGtwyzWqq6FBpMv)1fPQOmW7yof28eZckSidKy07Qkr5c0WtP5clbsgnPkOTWEGtqWjlSmyii9VThZQ)6Iuvug4DmNcBEIzbf2eCOpGPUEsTUeLlqdAknxyjqYOjvbTf28eZckSypvNG8(cRI(dCCIzbfwUtijMoedj1AM80smKfkg2NmAsSjiVNRigx9jX4pbUyST9yw9l2Iig3PmW7f2dCccozHLbdbP)T9yw9xxKQIYaVJ5i2TBIHmOWJkK8Yb8IDNyOXDLOef2pOuh41J6lnxUGNsZfwcKmAsvqBHDDkSpff28eZckSns4KmAQW2i1yuH9SRwT8b9hpvl)QkbhQFWtik6RiW8eZcsTyUXrmE6(mxvyv0FGJtmlOW6EG0oeum3ZeojJMkSnsyfKEuH9Xv1ahsp(QvLOCbAknxyjqYOjvbTf28eZckSnsW84fwf9h44eZckSUNjyECXgeX4tILqsSt64mauITaX4EcoKyh8eII(Uy3Jju3wmgczHKyid8dXuj4qIniIXNedpBqIbwXUyqHhFK6weumgSqmUNWwIXINQLVydqSfQiOyXkgkkeZ3XCcmijgMJyxdwX415heumU()5)d4QEH9aNGGtwyVwmUjwJeojJM6pUQg4q6XxTsSB3eJBIfPMarhmOWJpsDlc2jqYOjLy(flsnbIUkHTQpEQw(DcKmAsj2vI5xSZ6XSvNDaX3veYCMqm3eJhX8lg3edIbiKfII6EjSvDrQbov9Ypiyn)p)FaDcKmAsvIYf3V0CHLajJMuf0wyv0FGJtmlOW6t7QfdzHIXINQLVhPvI1KyS4PA5)bCArIHb00)IXNelHKyjZIfIfRyN0rSfig3tWHe7GNqu03fZNdOBlgFCciM7paLyxoLTa0)InVyjZIfIfRyqmGylw0lSilSciFeLl4PWEGtqWjlSW8qDWGcpQKgPWs(iGzn9wmquy5T7kS5jMfuyD2vxH0VyWdvIYf8U0CHLajJMuf0wypWji4KfwcqquTfZnoIXB3jMFXiabr1URiK5mHyUXrmECNy(fJBI1iHtYOP(JRQboKE8vReZVyN1JzRo7aIVRiK5mHyUjgpI5xmfXGHG0rgGQYNYwa6)oK8Yb8IDNy8uyZtmlOW(4PA57rAvjkx4QsZfwcKmAsvqBHDDkSpff28eZckSns4KmAQW2i1yuH9SEmB1zhq8DfHmNjeZnoIHgXAsmgmeK(JNQLFLrNk67yofwf9h44eZckSxYNelWH0JVA1lgYcfJabbhakXyXt1YxmUNGdvyBKWki9Oc7JRQN1JzRo7aIVeLl8TsZfwcKmAsvqBHDDkSpff28eZckSns4KmAQW2i1yuH9SEmB1zhq8DfHmNjeZnoID)c7bobbNSWE2geibrVvB4KGcBJewbPhvyFCv9SEmB1zhq8LOCHpR0CHLajJMuf0wyxNc7trHnpXSGcBJeojJMkSnsngvypRhZwD2beFxriZzcXUJJy8uypWji4Kf2gjCsgn1XEQ6aNfor7kCJmMfiMFXEhsRRrcrrX3FCm40Ia1pwONyUXrmExyBKWki9Oc7JRQN1JzRo7aIVeLlUSLMlSeiz0KQG2cBEIzbf2hpvl)QkbhQWQO)ahNywqHL7j4qIPWGdaLyST9yw9l2cflz2gKyboKE8vR6f2dCccozHTrcNKrt9hxvpRhZwD2beVy(f7AXAKWjz0u)Xv1ahsp(QvID7Mymyii9VThZQ)6Iuvug4Di5Ld4fZnoIXthnID7Mymyii9dEUFLjbuhZrSB3e7DiTUgjeffF)XXGtlcu)yHEI5ghX4Ty(f7SRwT8b9VThZQ)6Iuvug4Di5Ld4fZnX4XDIDvjkxCplnxyjqYOjvbTf28eZckSpEQw(vvcouHvr)booXSGclAXGaXGKxoGbGsmUNGd9IXqilKelWjXqgu4Hyeq9IniIXUCxm(lWxHymKyqkvTfBaIfJh1lSh4eeCYcBJeojJM6pUQEwpMT6SdiEX8lgYGcpQqYlhWl2DID2vRw(G(32Jz1FDrQkkd8oK8Yb8LOefwgSrRknxUGNsZfwcKmAsvqBH9aNGGtwy5MyrQjq0bdk84Ju3IGDcKmAsjMFXGyaczHOOEmG21y9XCQm6urDcKmAsjMFXEhsRRrcrrX3FCm40Ia1pwONy3jMRkS5jMfuyF8PrjkxGMsZfwcKmAsvqBH9aNGGtwyFhsRRrcrrXlMBCednI5xSRfJBID2geibrhqh4QxOsSB3e7SRwT8b9NGWmivLzbu9DMwu3l9r9GNqu0lgVi2bpHOOVIaZtmli1I5ghXCxhnUsSB3e7DiTUgjeffF)XXGtlcu)yHEI5My8wSRkS5jMfuyFCm40Ia1pwOxjkxC)sZfwcKmAsvqBH9aNGGtwyp7QvlFq)jimdsvzwavFNPf19sFup4jef9IXlIDWtik6RiW8eZcsTy3Xrm31rJRe72nX(ftZmavxtPQY0Us(i9C0uNajJMuI5xmUjgdgcsxtPQY0Us(i9C0uhZrSB3e7xmnZau9wuJb81D5vH0davNajJMuI5xmUjMIyWqq6TOgd4R8HzG3XCkS5jMfuyFccZGuvMfq13zArLOCbVlnxyZtmlOWIsVRhJovuHLajJMuf0wIYfUQ0CHnpXSGcltEA9rYuyjqYOjvbTLOeLOW2GG)SGYfOXDOHh35Z45Ewy5NqWaq9f2lNR77xCzUGxHRiMynJtInEolmedzHI5RpOuh4KYxIbjFESbskX(1JelXI1ldsj2bpbOOVlOZ1gajgV5kIDPf0GGbPeZxqmaHSquu)E9LyXkMVGyaczHOO(92jqYOjLVe7AE8XvDbDU2aiX8zCfXU0cAqWGuI5ligGqwikQFV(sSyfZxqmaHSquu)E7eiz0KYxIDnp(4QUGUG(LZ199lUmxWRWvetSMXjXgpNfgIHSqX8LdKoRhtg(smi5ZJnqsj2VEKyjwSEzqkXo4jaf9DbDU2aiXUpxrSlTGgemiLy(6xmnZau971xIfRy(6xmnZau97TtGKrtkFj2184JR6c6CTbqIDFUIyxAbniyqkX81VyAMbO63RVelwX81VyAMbO63BNajJMu(sSme7E0NJRj2184JR6c6CTbqI5Z4kIDPf0GGbPeZxqmaHSquu)E9LyXkMVGyaczHOO(92jqYOjLVeldXUh954AIDnp(4QUGUG(LZ199lUmxWRWvetSMXjXgpNfgIHSqX81r9(smi5ZJnqsj2VEKyjwSEzqkXo4jaf9DbDU2aiX4nxrSlTGgemiLy(cIbiKfII63RVelwX8fedqilef1V3obsgnP8LyxJgFCvxqNRnasmFJRi2LwqdcgKsmFbXaeYcrr971xIfRy(cIbiKfII63BNajJMu(sSR5Xhx1f05AdGeJN7Zve7slObbdsjMVGyaczHOO(96lXIvmFbXaeYcrr97TtGKrtkFj2184JR6c6CTbqIXJVXve7slObbdsjMV(ftZmav)E9LyXkMV(ftZmav)E7eiz0KYxIDnA8XvDbDb9lNR77xCzUGxHRiMynJtInEolmedzHI5RpOuh41J69LyqYNhBGKsSF9iXsSy9YGuIDWtak67c6CTbqIHgUIyxAbniyqkX8fedqilef1VxFjwSI5ligGqwikQFVDcKmAs5lXYqS7rFoUMyxZJpUQlOlOF5CDF)IlZf8kCfXeRzCsSXZzHHyilumFXGnALVeds(8ydKuI9RhjwIfRxgKsSdEcqrFxqNRnasmE4kIDPf0GGbPeZxqmaHSquu)E9LyXkMVGyaczHOO(92jqYOjLVe7AE8XvDbDb9lJNZcdsjMptS8eZcetpF8Db9cRdCrgnvyDTRfJfJj0u0wmFFrHrc6U21IX1XqH9HyO5E6IyOXDOHhbDbDx7AXUeEcqrpxrq31UwmErmE92GeRrcNKrtDSNQoWzHt0Uc3iJzbIH5i2VInHyZl2tHymeYcjX4tIH9Kyt0f0DTRfJxe7sRhZaiX8W0X4OjXoPwxZtmlOQNpeJabCOxSyfdskSdjMZgeiMulgK4VWwDbDx7AX4fX41zlsm3xtp(bMiHydiiieZjeBaIDwpMmeBqeJpj29a2hIPgLytigYcfRXQZy0u9xDdceDbDbDx7AX8jiXlxA9yYqqppXSGV7aPZ6XKrtC4s64OBxD25xGGEEIzbF3bsN1JjJM4WfMncnPQi6SnP4pau1y9Xae0Ztml47oq6SEmz0ehUGOPh)atKWLbHZVyAMbO6oyFGPPkbXCIzb3U9lMMzaQEJvNXOP6V6geie0Ztml47oq6SEmz0ehU8bL6axqppXSGV7aPZ6XKrtC4IxcBrQkYcRkkdCxCG0z9yYO(0zbQNdpUsqppXSGV7aPZ6XKrtC4YRNdvtGQQMd5IdKoRhtg1Nolq9C4XLbHdKqG0JNmAsqppXSGV7aPZ6XKrtC4YJNQLFLrNk6Dzq4aXaeYcrrDVe2QUi1aNQE5heSM)N)pabDbDx7AX415aeZ33iJzbc65jMf8CAnNwc6UwmU6tkXIvmffe0BaKy8XPaNGID2vRw(Gxm(5eIHSqXybCxmM8jLylqSiHOO47c65jMf8nXHlns4KmAYfq6rCEGQEwGAIzbU0i1yehgmeK(RNdvtGQQMd1XCUD7DiTUgjeffF)XXGtlcu)yHEUXX3e0DTy(CaDBXo4jafjgCJmMfi2GigFsm8SbjMdCw4eTRWnYywGypfILaLyEy6yC0KyrcrrXlgMtxqppXSGVjoCPrcNKrtUaspId2tvh4SWjAxHBKXSaxAKAmIJdCw4eTRWnYywG)3H06AKquu89hhdoTiq9Jf65gh0iO7AX4QpPelwXueYaiX4JtaXIvmSNe7dk1bUyxI7VylumgSrRi4lONNywW3ehU0iHtYOjxaPhX5dk1bEnWH0JVALlnsngXbnUQPi1ei6ngulStGKrtk3lACxtrQjq09YpiyDrQpEQw(FNajJMuUx04UMIutGO)4PA5xr2d23jqYOjL7fnUQPi1ei6PopWjA3jqYOjL7fnURj04k371VdP11iHOO47pogCArG6hl0Zno8(kbDxl2LWPtlXUe3FXYqmKb(HGEEIzbFtC4Yj16AEIzbv98HlG0J4CuVGURfZ3XaIHGP1Tf75pXbNEXIvSaNeJnOuh4KsmFFJmMfi21mTftTdaLy)6IytigYcp0lMZU6bGsSbrmWg4daLyZlw2ihDYOPR6c65jMf8nXHlqmqnpXSGQE(Wfq6rC(GsDGtkxgeoFqPoWjvp1AbDxlgx3Xr3wmw9CiXsGsmUphsSmednnj2L8jXuyWbGsSaNedzGFigpUtSNolq9UiwIeeuSapdX4DtIDjFsSbrSjeJ8HZaPxm(tGpaXcCsma5JqmELlXDXwOyZlgydXWCe0Ztml4BIdxE9COAcuv1CixgeoVdP11iHOO47pogCArG6hl07oFZpYGcpQqYlhW7MV5NbdbP)65q1eOQQ5qDi5Ld4Vd1r19sF4)SEmB1zhq8UXH38Y1X4r3XJ7UY9IgbDxlMpbNforBX89nYywaVAX4Au4RxmutdsSuSdmDelzwSqmcqquTfdzHIf4KyFqPoWf7sC)f7AgSrRiOyFmATyq6DOti2ex1fJxvmhxeBcXojqmgsSapdX(XZrtDb98eZc(M4WLtQ118eZcQ65dxaPhX5dk1bE9OExgeons4KmAQJ9u1bolCI2v4gzmlqq31IDPf8JIGIH9daLyPySbL6axSlXDX4JtaXGuEWhakXcCsmcqquTflWH0JVALGEEIzbFtC4Yj16AEIzbv98HlG0J48bL6aVEuVldchcqquT7kczotChNgjCsgn1)GsDGxdCi94RwjONNywW3ehUCsTUMNywqvpF4ci9ioidyECxgeoxtii0jMgu9SEmB1zhq8UX54u9sFuFhcOU62TRpRhZwD2beFxriZzI74WZTBidk8OcjVCa)DC4XpHGqNyAq1Z6XSvNDaX7gN7F7gdgcs)B7XS6VUivfLbEnXI9aNOJ54NqqOtmnO6z9y2QZoG4DJdVV62TRFhsRRrcrrX3FCm40Ia1pwONBC4TFcbHoX0GQN1JzRo7aI3no8(kbDxlgx9jXsXyWgTIGIXhNaIbP8GpauIf4KyeGGOAlwGdPhF1kb98eZc(M4WLtQ118eZcQ65dxaPhXHbB0kxgeoeGGOA3veYCM4oons4KmAQ)bL6aVg4q6XxTsq31IX1w(0hI5aNforBXgGyPwl2IiwGtIX19jUMym0jXEsSje7Kyp9ILIXRCjUlONNywW3ehUKWtcOASqibcxgeoeGGOA3veYCMWno84QMiabr1UdjueqqppXSGVjoCjHNeqvhm9tc65jMf8nXHl6bfE817bmfkpcec65jMf8nXHlmjQ6Iud4CA9c6c6U21IHwSrRi4lONNywW3zWgTIZJpnCzq4WTi1ei6GbfE8rQBrWobsgnP8dXaeYcrr9yaTRX6J5uz0PI8)oKwxJeIIIV)4yWPfbQFSqV7CLGEEIzbFNbB0QM4WLhhdoTiq9Jf65YGW5DiTUgjeffVBCqJ)R52zBqGeeDaDGREHQB3o7QvlFq)jimdsvzwavFNPf19sFup4jef98YbpHOOVIaZtmli1UXXDD04QB3EhsRRrcrrX3FCm40Ia1pwONB8(kb98eZc(od2OvnXHlpbHzqQkZcO67mTixgeoND1QLpO)eeMbPQmlGQVZ0I6EPpQh8eIIEE5GNqu0xrG5jMfK6744UoAC1TB)IPzgGQRPuvzAxjFKEoAQtGKrtk)CJbdbPRPuvzAxjFKEoAQJ5C72VyAMbO6TOgd4R7YRcPhaQobsgnP8ZnfXGHG0BrngWx5dZaVJ5iONNywW3zWgTQjoCbLExpgDQib98eZc(od2OvnXHlm5P1hjJGUGURDTyxAxTA5dEbDxlgx9jX4EcoKylccVG6OeJHqwijwGtIHmWpe7XXGtlcu)yHEIHaxpXAEHGuTIDwp6fBaDb98eZc((r9CE8uT8RQeCixWEQUiivuhfhECzq4WngmeK(JNQLFvLGd1XC8ZGHG0FCm40Ia1yHGuTDmh)myii9hhdoTiqnwiivBhsE5a(74C)URe0DTyxZvbA6FXsnKsvBXWCeJHoj2tIXNel2TLyS4PA5lM7VhS)kXWEsm22EmR(fBrq4fuhLymeYcjXcCsmKb(HyS4yWPfbeJnwONyiW1tSMxiivRyN1JEXgqxqppXSGVFuFtC4Y32Jz1FDrQkkdCxWEQUiivuhfhECzq4WGHG0FCm40Ia1yHGuTDmh)myii9hhdoTiqnwiivBhsE5a(74C)URe0Ztml47h13ehUGOtuKwNXSaxgeons4KmAQ)av9Sa1eZc8ZTpOuh4KQ7LGqt(zWqq6FBpMv)1fPQOmW7yo(pRhZwD2beVBCCLGEEIzbF)O(M4WLgjyECxgeoxdXaeYcrrDVe2QUi1aNQE5heSM)N)pa)N1JzRo7aIVRiK5mXDC4HxIutGORiYHG1pGzqOiVobsgnPUDdIbiKfII6kkdCD76JNQL)7)SEmB1zhq83XZv(zWqq6FBpMv)1fPQOmW7yo(zWqq6pEQw(vvcouhZXVx(bbR5)5)dOcjVCaph35NbdbPROmW1TRpEQw(FxT8bc6UwmFAxTyiluSMxiivRyoqIxyxUlg)jWfJfN7IbPu1wm(4eqmWgIbXaGbGsmw3VlONNywW3pQVjoCXzxDfs)IbpKlilSciFeC4XLbHtKAce9hhdoTiqnwiivBNajJMu(5wKAce9hpvl)kYEW(obsgnPe0DTyC1NeR5fcs1kMdKeJD5Uy8XjGy8jXWZgKybojgbiiQ2IXhNcCckgcC9eZzx9aqjg)jWxSqmw3xSfk29a2hIHIaem162Db98eZc((r9nXHlpogCArGASqqQwxgeoeGGOA7ghFZD(BKWjz0u)bQ6zbQjMf4)SRwT8b9VThZQ)6Iuvug4Dmh)ND1QLpO)4PA5xvj4q9dEcrrVBC4X)1CdIbiKfII6ldPgcCOB3uedgcshrNOiToJzbDmNB3EhsRRrcrrX3FCm40Ia1pwONBCUMNM4T79AUfPMarhmOWJpsDlc2jqYOjLFUfPMarxLWw1hpvl)obsgnPU6QR8FwpMT6Sdi(74Gg)xZngmeKUdK8i1ezmlOJ5C727qADnsikk((JJbNweO(Xc9CJ3x5)AUD2geibrVbbc82WB342zxTA5d6i6efP1zmlOJ5CLGEEIzbF)O(M4WLNGWmivLzbu9DMwKlN2hnvJeIIINdpUmiCAKWjz0u)bQ6zbQjMf4NBQn6pbHzqQkZcO67mTOQAJEmNwdaL)iHOOOhJhvJTQgYnoOHh)xFwpMT6Sdi(UIqMZeUX56Jtfvoa34vZ7RUYp3yWqq6pogCArGASqqQ2oMJ)R5gdgcs3bsEKAImMf0XCUD7DiTUgjeffF)XXGtlcu)yHEUX7RUDdzqHhvi5Ld4VJJR8)oKwxJeIIIV)4yWPfbQFSqV7UVGEEIzbF)O(M4WLNC(5Dzq40iHtYOP(du1ZcutmlW)z9y2QZoG47kczot4ghEe0DTyC1NeJTThZQFXwGyND1QLpqSRtKGGIHmWpeJfW9ReddOP)fJpjwcjXqTdaLyXkMZ6iwZleKQvSeOetTIb2qm8SbjglEQw(I5(7b77c65jMf89J6BIdx(2EmR(RlsvrzG7YGWPrcNKrt9hOQNfOMywG)RJutGOtGgKEDgaQ6JNQL)3jqYOj1TBND1QLpO)4PA5xvj4q9dEcrrVBC45k)xZTi1ei6pogCArGASqqQ2obsgnPUDlsnbI(JNQLFfzpyFNajJMu3UD2vRw(G(JJbNweOgleKQTdjVCaVBO5k)xZTZ2Gaji6niqG3gE72zxTA5d6i6efP1zmlOdjVCaVB84UB3o7QvlFqhrNOiToJzbDmh)N1JzRo7aI3noU6kbDxl2LbrSuPEXsijgMJlI9GXHelWjXwajg)jWftV8PpeR5M5ExmU6tIXhNaIPApauIHKFqqXc8ei2L8jXueYCMqSfkgydX(GsDGtkX4pb(IfILG2IDjFQlONNywW3pQVjoCXlHTivfzHvfLbUl6bq1JIdpDx5YP9rt1iHOO45WJldchyoQk1GarpvQVJ54)6iHOOOhJhvJTQg6UZ6XSvNDaX3veYCM42nU9bL6aNu9uR9FwpMT6Sdi(UIqMZeUX54u9sFuFhcOUsq31IDzqedSILk1lg)rRftnKy8NaFaIf4KyaYhHy33DVlIH9Ky8AeUl2ceJz)xm(tGVyHyjOTyxYN6c65jMf89J6BIdx8sylsvrwyvrzG7YGWbMJQsniq0tL67dWT77oEbMJQsniq0tL67kmygZc8FwpMT6Sdi(UIqMZeUX54u9sFuFhcOe0Ztml47h13ehU84PA5xz0PIExgeons4KmAQ)av9Sa1eZc8FwpMT6Sdi(UIqMZeUXbn(VMbdbP)T9yw9xxKQIYaVJ5C7gZ(VFKbfEuHKxoG)ooOXDxjONNywW3pQVjoCHo47aqvHKdC8sGYLbHtJeojJM6pqvplqnXSa)N1JzRo7aIVRiK5mHBCqJ)RBKWjz0uh7PQdCw4eTRWnYywWTBVdP11iHOO47pogCArG6hl07oo8(2nigGqwikQdPFXaQbGQE0jCI2xjO7AXU8jWfJ19DrSbrmWgILAiLQ2IPwa5IyypjwZleKQvm(tGlg7YDXWC6c65jMf89J6BIdxECm40Ia1yHGuTUmiCIutGO)4PA5xr2d23jqYOjL)gjCsgn1FGQEwGAIzb(zWqq6FBpMv)1fPQOmW7yo(pRhZwD2be)DCqJ)R5gdgcs3bsEKAImMf0XCUD7DiTUgjeffF)XXGtlcu)yHEUX7Re0Ztml47h13ehU84PA5xvj4qUmiC4gdgcs)Xt1YVQsWH6yo(rgu4rfsE5a(74CzBksnbI(JXeeebdf1jqYOjLGEEIzbF)O(M4Wfen94hyIeUmiCU(xmnZauDhSpW0uLGyoXSGB3(ftZmavVXQZy0u9xDdcex5Naeev7UIqMZeUX5(UZp3(GsDGtQEQ1(zWqq6FBpMv)1fPQOmW7QLpWLbeeeI5e1XZJutgehECzabbHyorfLEzsnhECzabbHyorDq48lMMzaQEJvNXOP6V6geie0Ztml47h13ehU4SXSaxgeomyiiDg9Ukn2hDiLN42nKbfEuHKxoG)U77UB3yWqq6FBpMv)1fPQOmW7yo(VMbdbP)4PA5xz0PI(oMZTBND1QLpO)4PA5xz0PI(oK8Yb83XHh3DLGEEIzbF)O(M4Wfg9UQkcgSTldchgmeK(32Jz1FDrQkkd8oMJGEEIzbF)O(M4Wfgc(eS1aq5YGWHbdbP)T9yw9xxKQIYaVJ5iONNywW3pQVjoCbzGeJExLldchgmeK(32Jz1FDrQkkd8oMJGEEIzbF)O(M4WLeCOpGPUEsT2LbHddgcs)B7XS6VUivfLbEhZrq31IXDcjX0HyiPwZKNwIHSqXW(KrtInb59CfX4Qpjg)jWfJTThZQFXweX4oLbExqppXSGVFuFtC4c2t1jiV3LbHddgcs)B7XS6VUivfLbEhZ52nKbfEuHKxoG)o04obDbDx7AXC)bmpobFbDxl2LJpAsmSFaOeZNGKhPMiJzbUiw2yhLyN8JbGsmw9CiXsGsmUphsm(4eqmw8uT8fJ7j4qInVy)UaXIvmgsmSNuUig5Jd5eIHSqXCp2gojqqppXSGVJmG5X50iHtYOjxaPhXXbsEKQ(av9Sa1eZcCPrQXiorQjq0DGKhPMiJzbDcKmAs5)DiTUgjeffF)XXGtlcu)yHE3DTR4LZ2Gaji6a6ax9cvx5NBNTbbsq0B1gojqqppXSGVJmG5XBIdxE9COAcuv1CixgeoCRrcNKrtDhi5rQ6du1ZcutmlW)7qADnsikk((JJbNweO(Xc9UZ38ZngmeK(JNQLFvLGd1XC8ZGHG0F9COAcuv1COoK8Yb83HmOWJkK8Yb8(HecKE8Krtc65jMf8DKbmpEtC4YRNdvtGQQMd5YGWPrcNKrtDhi5rQ6du1ZcutmlW)zxTA5d6pEQw(vvcou)GNqu0xrG5jMfK674P7ZCLFgmeK(RNdvtGQQMd1HKxoG)UZUA1Yh0)2EmR(RlsvrzG3HKxoG3)1ND1QLpO)4PA5xvj4qDiLQ2(zWqq6FBpMv)1fPQOmW7qYlhWZlmyii9hpvl)QkbhQdjVCa)D80rZvc6Uwm3dK2HGI5EMWjz0KyilumFhZjWGuxm2wJJykm4aqjgVo)GGIX1)p)FaITqXuyWbGsmUNGdjg)jWfJ7jSLyjqjgyf7IbfE8rQBrWUGEEIzbFhzaZJ3ehU0iHtYOjxaPhX5BnoviMtGbjxAKAmIJx(bbR5)5)dOcjVCaVBU72nUfPMarhmOWJpsDlc2jqYOjL)i1ei6Qe2Q(4PA53jqYOjLFgmeK(JNQLFvLGd1XCUD7DiTUgjeffF)XXGtlcu)yHEUXH3c6Uwm3Je5igMJy(oMtGbjXgeXMqS5flzwSqSyfdIbeBXIUGEEIzbFhzaZJ3ehUaXCcmi5YGW5AU1iHtYOP(3ACQqmNads3U1iHtYOPo2tvh4SWjAxHBKXSGR8hjeff9y8OASv1q8cK8Yb8U5B(HecKE8Krtc65jMf8DKbmpEtC4Ythif1Go4GXNhJe0DTy8AmDmQnIbGsSiHOO4flWZqm(JwlMEAqIHSqXcCsmfgmJzbITiI57yobgKCrmiHaPhxmfgCaOeZjbkYBoDb98eZc(oYaMhVjoCbI5eyqYLt7JMQrcrrXZHhxgeoCRrcNKrt9V14uHyobgK8ZTgjCsgn1XEQ6aNfor7kCJmMf4)DiTUgjeffF)XXGtlcu)yHEUXbn(JeIIIEmEun2QAi34CTRA6A04EpRhZwD2be)vx5hsiq6XtgnjO7AX8DcbspUy(oMtGbjXOeQBl2Gi2eIXF0AXiF4mqsmfgCaOeJTThZQ)UyCFflWZqmiHaPhxSbrm2L7IHIIxmiLQ2InaXcCsma5Jqmx9Db98eZc(oYaMhVjoCbI5eyqYLbHd3AKWjz0u)BnoviMtGbj)qYlhWF3zxTA5d6FBpMv)1fPQOmW7qYlhW3epUZ)zxTA5d6FBpMv)1fPQOmW7qYlhWFhhx5psikk6X4r1yRQH4fi5Ld4D7SRwT8b9VThZQ)6Iuvug4Di5Ld4BYvc65jMf8DKbmpEtC4cJopTQolFfbDzq4WTgjCsgn1XEQ6aNfor7kCJmMf4)DiTUgjeffVBCUVGEEIzbFhzaZJ3ehUqnM)qWmibDbDx7AXydk1bUyxAxTA5dEbDxlM7bs7qqXCpt4KmAsqppXSGV)bL6aVEupNgjCsgn5ci9iopUQg4q6XxTYLgPgJ4C2vRw(G(JNQLFvLGd1p4jef9veyEIzbP2no809zUsq31I5EMG5XfBqeJpjwcjXoPJZaqj2ceJ7j4qIDWtik67IDpMqDBXyiKfsIHmWpetLGdj2GigFsm8Sbjgyf7IbfE8rQBrqXyWcX4EcBjglEQw(InaXwOIGIfRyOOqmFhZjWGKyyoIDnyfJxNFqqX46)N)pGR6c65jMf89pOuh41J6BIdxAKG5XDzq4Cn3AKWjz0u)Xv1ahsp(Qv3UXTi1ei6GbfE8rQBrWobsgnP8hPMarxLWw1hpvl)obsgnPUY)z9y2QZoG47kczot4gp(5gedqilef19syR6IudCQ6LFqWA(F()ae0DTy(0UAXqwOyS4PA57rALynjglEQw(FaNwKyyan9Vy8jXsijwYSyHyXk2jDeBbIX9eCiXo4jef9DX85a62IXhNaI5(dqj2Ltzla9VyZlwYSyHyXkgedi2IfDb98eZc((huQd86r9nXHlo7QRq6xm4HCbzHva5JGdpUq(iGzn9wmqWH3UZLbHdmpuhmOWJkPre0Ztml47FqPoWRh13ehU84PA57rALldchcqquTDJdVDNFcqquT7kczot4ghECNFU1iHtYOP(JRQboKE8vR8FwpMT6Sdi(UIqMZeUXJFfXGHG0rgGQYNYwa6)oK8Yb83XJGURf7s(KyboKE8vREXqwOyeii4aqjglEQw(IX9eCib98eZc((huQd86r9nXHlns4KmAYfq6rCECv9SEmB1zhq8U0i1yeNZ6XSvNDaX3veYCMWnoOPjgmeK(JNQLFLrNk67yoc65jMf89pOuh41J6BIdxAKWjz0KlG0J484Q6z9y2QZoG4DPrQXioN1JzRo7aIVRiK5mHBCUVldcNZ2Gaji6TAdNeiONNywW3)GsDGxpQVjoCPrcNKrtUaspIZJRQN1JzRo7aI3LgPgJ4CwpMT6Sdi(UIqMZe3XHhxgeons4KmAQJ9u1bolCI2v4gzmlW)7qADnsikk((JJbNweO(Xc9CJdVf0DTyCpbhsmfgCaOeJTThZQFXwOyjZ2GelWH0JVAvxqppXSGV)bL6aVEuFtC4YJNQLFvLGd5YGWPrcNKrt9hxvpRhZwD2beV)RBKWjz0u)Xv1ahsp(Qv3UXGHG0)2EmR(RlsvrzG3HKxoG3no80rZTBmyii9dEUFLjbuhZ52T3H06AKquu89hhdoTiq9Jf65ghE7)SRwT8b9VThZQ)6Iuvug4Di5Ld4DJh3DLGURfdTyqGyqYlhWaqjg3tWHEXyiKfsIf4Kyidk8qmcOEXgeXyxUlg)f4RqmgsmiLQ2InaXIXJ6c65jMf89pOuh41J6BIdxE8uT8RQeCixgeons4KmAQ)4Q6z9y2QZoG49JmOWJkK8Yb83D2vRw(G(32Jz1FDrQkkd8oK8Yb8c6c6U21IXguQdCsjMVVrgZce0DTyxgeXydk1boxAKG5XflHKyyoUig2tIXINQL)hWPfjwSIXqaczcXqGRNybojMt()0GeJzbyVyjqjM7paLyxoLTa0)Uig1GaIniIXNelHKyziMx6dXUKpj21yan9Vyy)aqjgVo)GGIX1)p)FaxjONNywW3)GsDGtkopEQw(FaNwKldcNRzWqq6FqPoW7yo3UXGHG0BKG5X7yox5)63H06AKquu89hhdoTiq9Jf6DhVVDRrcNKrtDSNQoWzHt0Uc3iJzbx53l)GG18)8)buHKxoGNJ7e0DTyU)aMhxSme7(nj2L8jX4pb(IfIXDwX4Iy8UjX4pbUyCNvm(tGlglogCAraXAEHGuTIXGHGigMJyXkw2yhLy)6rIDjFsm(5hKy)eyzml47c6UwmUU(xX(eHelwXqgW84ILHy8UjXUKpjg)jWfJ8rEcDBX4TyrcrrX3f7A20JelFXwS4hfj2huQd8(vc6Uwm3FaZJlwgIX7Me7s(Ky8NaFXcX4oRlI5QMeJ)e4IXDwxelbkX8nX4pbUyCNvSejiOyUNjyECb98eZc((huQdCs1ehUCsTUMNywqvpF4ci9ioidyECxgeoeccDIPbvpRhZwD2beVBCoovV0h13HaQB3yWqq6pogCArGASqqQ2oMJ)Z6XSvNDaX3veYCM4ooO52T3H06AKquu89hhdoTiq9Jf65ghE7NqqOtmnO6z9y2QZoG4DJdVVD7SEmB1zhq8DfHmNjUJdp8Y1rQjq0ve5qW6hWmsuKxNajJMu(zWqq6nsW84DmNRe0Ztml47FqPoWjvtC4YJNQL)hWPf5YGW5dk1boP6p58Z7)DiTUgjeffF)XXGtlcu)yHE3XBb98eZc((huQdCs1ehU84tdxgeorQjq0bdk84Ju3IGDcKmAs5hIbiKfII6XaAxJ1hZPYOtf5)DiTUgjeffF)XXGtlcu)yHE35kbDxlgx1rSyf7(IfjeffVyxdwXCGZELyTiYrmmhXC)bOe7YPSfG(xmM2IDAF0daLyS4PA5)bCArDb98eZc((huQdCs1ehU84PA5)bCArUCAF0unsikkEo84YGWHBns4KmAQJ9u1bolCI2v4gzmlWVIyWqq6idqv5tzla9FhsE5a(74X)7qADnsikk((JJbNweO(Xc9UJZ99hjeff9y8OASv1q8cK8Yb8U5Bc6Uwm3FHI5aNforBXGBKXSaxed7jXyXt1Y)d40IeBBqqXyJf6jg)jWf7Y51ILOYb8HyyoIfRy8wSiHOO4fBHIniI5(xUyZlgedagakXweeXUEbILG2ILElgieBrelsikk(Re0Ztml47FqPoWjvtC4YJNQL)hWPf5YGWPrcNKrtDSNQoWzHt0Uc3iJzb(VwrmyiiDKbOQ8PSfG(VdjVCa)D8C7wKAceD(u6SaV8dc2jqYOjL)3H06AKquu89hhdoTiq9Jf6DhhEFLGEEIzbF)dk1boPAIdxECm40Ia1pwONldcN3H06AKquu8UX5(nDndgcspWPkCJGaDmNB3GyaczHOOE2kt481FX0veyIYJaXv(VMbdbP)T9yw9xxKQIYaVMyXEGt0XCUDJBmyiiDhi5rQjYywqhZ52T3H06AKquu8UXXvxjO7AXyXt1Y)d40IelwXGecKECXC)bOe7YPSfG(xSeOelwXiWJbjX4tIDsGyNecBl22GGILIHGP1I5(xUydiwXcCsma5Jqm2L7IniI5S)pmAQlONNywW3)GsDGtQM4WLhpvl)pGtlYLbHJIyWqq6idqv5tzla9FhsE5a(74WZTBND1QLpO)T9yw9xxKQIYaVdjVCa)D8Cz9RigmeKoYauv(u2cq)3HKxoG)UZUA1Yh0)2EmR(RlsvrzG3HKxoGxqppXSGV)bL6aNunXHlO076XOtf5YGWHbdbP7qqKfMbPQnOb89pYtl344k)NfOWMO7qqKfMbPQnOb8DycA5ghEUVGEEIzbF)dk1boPAIdxE8uT8)aoTib98eZc((huQdCs1ehUCWP0P(4B4YGWHBrcrrrF(kZ(V)Z6XSvNDaX3veYCMWno84NbdbP)4BuhqnWPQkHT6yo(jabr1UhJhvJTYB35gQJQ7L(OW(o0PCbA8nEkrjkfa]] )

    
end
