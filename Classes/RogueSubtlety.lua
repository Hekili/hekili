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


    spec:RegisterPack( "Subtlety", 20210831, [[defhbcqiuP8iQKAtuv9jQkzusP6uQKSkQuHxjLywujUfQszxs1VqLyyuj5yOkwgKsptLQmnuLCnQu12ujv(gvLIXrvr5CuvuzDQuvnpvQCpuX(Os5FOkvLdIkPAHqkEOkPmruP6IOscTrQuPpIkjAKOkvvNKQsPvcP6LOkvPzIkPCtuLk7ukLFsLkQHsvrwkvLQNIstvkPRIkjTvQur(QkPQXQsv5SOkvH9kXFL0GPCyrlgfpwftMKlJSzi(mKmAO60kwnQKGxlfnBsDBQYUb(TsdNkoovfvTCqpxvtx46qz7sHVJQA8uv48QeRhvPkA(Qu2pXfEkTwyvzqL2qRRqlpUYNDpE6UYN5(7HwEvyJlouH1jpntuuHfKEuHLfJj0uCPW6Kx0BQkTwy)fdEOclEeo)9ZfUGAcCmM(z94YpEy6mMfCGjsWLF8oCPWYGn6W3ckmfwvguPn06k0YJR8z3JNUR8zU)EOTWMyb(clSSJ31kS4JsrGctHvr)PWYIXeAkUiMVVOWibDUogkSpe7E84IyO1vOLhbDb9RHNau0F)c68My8UTbjwJeojJM6ypvDGZcN4sfUrgZcedZrSFfBcXMxSNcXyiKfsIXNed7jXMOlOZBIDT1JzaKyEy6yC0KyNuRR5jMfu1ZhIrGao0lwSIbjf2HeZzdcetQfds8xyZUGoVjgVlBsI5UA6XpWejeBabbHyoHydqSZ6XKHydIy8jX4kG9HyQrj2eIHSqXAS6mgnv)v3GarVWQNp(sRf2pOuh4KQ0APnEkTwyjqYOjvbnf28eZckSpEQw(FaNMuHvr)booXSGcRVfrm2GsDGZLgjyECXsijgMJlIH9KyS4PA5)bCAsIfRymeGqMqme46jwGtI5K)pniXywa2lwcuI5Udqj21tzta9VlIrniGydIy8jXsijwgI5L(qSR5tI1ogqt)lg2pauIX7YpiOyC9)Z)hWvf2dCccozHTDXyWqq6FqPoW7yoID7Mymyii9gjyE8oMJyxjMFXAxS3H06AKquu89hhdonjq9Jf6j2DIXlXUDtSgjCsgn1XEQ6aNfoXLkCJmMfi2vI5xmV8dcwZ)Z)hqfsE5aEX4iMRkrPn0wATWsGKrtQcAkSk6pWXjMfuyD3bmpUyzigVArSR5tIXFc8fleJ7SUiM7Brm(tGlg3zDrSeOe76eJ)e4IXDwXsKGGI5oLG5XlS5jMfuypPwxZtmlOQNpkSh4eeCYclHGqNyAq1Z6XSvNDaXlMBCe74u9sFuFhcOe72nXyWqq6pogCAsGASqqQ2oMJy(f7SEmB1zhq8DfHmNje7ooIHwXUDtS3H06AKquu89hhdonjq9Jf6jMBCeJxI5xmcbHoX0GQN1JzRo7aIxm34igVe72nXoRhZwD2beFxriZzcXUJJy8igVjw7IfPMarxrKdbRFaZirrEDcKmAsjMFXyWqq6nsW84DmhXUQWQNpQG0JkSidyE8suA7ELwlSeiz0KQGMc7bobbNSW(bL6aNu9NC(5fZVyVdP11iHOO47pogCAsG6hl0tS7eJxf28eZckSpEQw(FaNMujkTXRsRfwcKmAsvqtH9aNGGtwyJutGOdgu4XhPUjb7eiz0Ksm)IbXaeYcrr9yaxQX6J5uz0PI6eiz0Ksm)I9oKwxJeIIIV)4yWPjbQFSqpXUtm3xyZtmlOW(4tJsuAZ9LwlSeiz0KQGMcBEIzbf2hpvl)pGttQWEUC0unsikk(sB8uypWji4KfwUjwJeojJM6ypvDGZcN4sfUrgZceZVykIbdbPJmavLpLnb0)Di5Ld4f7oX4rm)I9oKwxJeIIIV)4yWPjbQFSqpXUJJy3tm)Ifjeff9y8OASv1qIXBIbjVCaVyUj21vyv0FGJtmlOWYvDelwXUNyrcrrXlw7Gvmh4SxjwtICedZrm3DakXUEkBcO)fJ5IyNlh9aqjglEQw(FaNMuVeL2UUsRfwcKmAsvqtHnpXSGc7JNQL)hWPjvyv0FGJtmlOW6Ulumh4SWjUigCJmMf4IyypjglEQw(FaNMKyBdckgBSqpX4pbUyxpVtSevoGpedZrSyfJxIfjeffVyluSbrm396fBEXGyaWaqj2IGiw7lqSeCrS0BXaHylIyrcrrXFvH9aNGGtwyBKWjz0uh7PQdCw4exQWnYywGy(fRDXuedgcshzaQkFkBcO)7qYlhWl2DIXJy3UjwKAceD(u6SaV8dc2jqYOjLy(f7DiTUgjeffF)XXGttcu)yHEIDhhX4LyxvIsB(MsRfwcKmAsvqtH9aNGGtwyFhsRRrcrrXlMBCe7EI1IyTlgdgcspWPkCJGaDmhXUDtmigGqwikQNnZeoF9xmDfbMO8iq0jqYOjLyxjMFXAxmgmeK(FXJz1FDrQkkd8AIf7borhZrSB3eJBIXGHG0DGKhPMiJzbDmhXUDtS3H06AKquu8I5ghXCVyxvyZtmlOW(4yWPjbQFSqVsuAZNvATWsGKrtQcAkS5jMfuyF8uT8)aonPcRI(dCCIzbfww8uT8)aonjXIvmiHaPhxm3DakXUEkBcO)flbkXIvmc8yqsm(KyNei2jHWlITniOyPyiyATyU71l2aIvSaNedq(ieJD5UydIyo7)dJM6f2dCccozHvrmyiiDKbOQ8PSjG(VdjVCaVy3XrmEe72nXo7QvlFq)V4XS6VUivfLbEhsE5aEXUtmE8zI5xmfXGHG0rgGQYNYMa6)oK8Yb8IDNyND1QLpO)x8yw9xxKQIYaVdjVCaFjkT5ZvATWsGKrtQcAkSh4eeCYcldgcs3HGilmdsvBqd47FKNMI5ghXCVy(f7Saf2eDhcISWmivTbnGVdtqtXCJJy8CVcBEIzbfwu6D9y0PIkrPnECvP1cBEIzbf2hpvl)pGttQWsGKrtQcAkrPnE4P0AHLajJMuf0uypWji4KfwUjwKquu0NVYS)lMFXoRhZwD2beFxriZzcXCJJy8iMFXyWqq6p(g1budCQQsyZoMJy(fJaee1LEmEun2kVCLyUjgQJQ7L(OWMNywqH9GtPt9X3OeLOWQiKethLwlTXtP1cBEIzbf2MZPzHLajJMuf0uIsBOT0AHLajJMuf0uyxNc7trHnpXSGcBJeojJMkSnsngvyzWqq6VEounbQQAouhZrSB3e7DiTUgjeffF)XXGttcu)yHEI5ghXUUcRI(dCCIzbfwU6tkXIvmffe0BaKy8XPaNGID2vRw(Gxm(5eIHSqXybCxmM8jLylqSiHOO47f2gjScspQW(av9Sa1eZckrPT7vATWsGKrtQcAkSRtH9POWMNywqHTrcNKrtf2gPgJkSoWzHtCPc3iJzbI5xS3H06AKquu89hhdonjq9Jf6jMBCedTfwf9h44eZckSUZa9fXo4jafjgCJmMfi2GigFsm8SbjMdCw4exQWnYywGypfILaLyEy6yC0KyrcrrXlgMtVW2iHvq6rfwSNQoWzHtCPc3iJzbLO0gVkTwyjqYOjvbnf21PW(uuyZtmlOW2iHtYOPcBJuJrfw06EXArSi1ei6ngulStGKrtkXChIHwxjwlIfPMar3l)GG1fP(4PA5)DcKmAsjM7qm06kXArSi1ei6pEQw(vK9G9DcKmAsjM7qm06EXArSi1ei6PopWjU0jqYOjLyUdXqRReRfXqR7fZDiw7I9oKwxJeIIIV)4yWPjbQFSqpXCJJy8sSRkSk6pWXjMfuy5QpPelwXueYaiX4JtaXIvmSNe7dk1bUyxJ7VylumgSrRi4xyBKWki9Oc7huQd8AGdPhF1QsuAZ9LwlSeiz0KQGMcRI(dCCIzbf2RHtNMIDnU)ILHyid8JcBEIzbf2tQ118eZcQ65JcRE(OcspQWEuFjkTDDLwlSeiz0KQGMcRI(dCCIzbfwFhdigcMwFrSN)ehC6flwXcCsm2GsDGtkX89nYywGyTZCrm1oauI9RlInHyil8qVyo7QhakXgeXaBGpauInVyzJC0jJMUQxyZtmlOWcXa18eZcQ65Jc7bobbNSW(bL6aNu9uRlS65Jki9Oc7huQdCsvIsB(MsRfwcKmAsvqtHnpXSGc7RNdvtGQQMdvyv0FGJtmlOWY1DC0xeJvphsSeOeJ7ZHeldXqBlIDnFsmfgCaOelWjXqg4hIXJRe7PZcuVlILibbflWZqmE1IyxZNeBqeBcXiF4mq6fJ)e4dqSaNedq(ieJR8ACxSfk28Ib2qmmNc7bobbNSW(oKwxJeIIIV)4yWPjbQFSqpXUtSRtm)IHmOWJkK8Yb8I5MyxNy(fJbdbP)65q1eOQQ5qDi5Ld4f7oXqDuDV0hI5xSZ6XSvNDaXlMBCeJxIXBI1UyX4rIDNy84kXUsm3HyOTeL28zLwlSeiz0KQGMcRI(dCCIzbfwFcolCIlI57BKXSaEFIX1OWxVyOMgKyPyhy6iwYSyHyeGGOUigYcflWjX(GsDGl214(lw7myJwrqX(y0AXG07qNqSjUQlgVhyoUi2eIDsGymKybEgI9JNJM6f28eZckSNuRR5jMfu1Zhf2dCccozHTrcNKrtDSNQoWzHtCPc3iJzbfw98rfKEuH9dk1bE9O(suAZNR0AHLajJMuf0uyv0FGJtmlOWETf8JIGIH9daLyPySbL6axSRXDX4JtaXGuEWhakXcCsmcqquxelWH0JVAvHnpXSGc7j16AEIzbv98rH9aNGGtwyjabrDPRiK5mHy3XrSgjCsgn1)GsDGxdCi94Rwvy1Zhvq6rf2pOuh41J6lrPnECvP1clbsgnPkOPWEGtqWjlSTlgHGqNyAq1Z6XSvNDaXlMBCe74u9sFuFhcOe7kXUDtS2f7SEmB1zhq8DfHmNje7ooIXJy3UjgYGcpQqYlhWl2DCeJhX8lgHGqNyAq1Z6XSvNDaXlMBCe7EID7Mymyii9)IhZQ)6Iuvug41el2dCIoMJy(fJqqOtmnO6z9y2QZoG4fZnoIXlXUsSB3eRDXEhsRRrcrrX3FCm40Ka1pwONyUXrmEjMFXiee6etdQEwpMT6SdiEXCJJy8sSRkS5jMfuypPwxZtmlOQNpkS65Jki9OclYaMhVeL24HNsRfwcKmAsvqtHvr)booXSGclx9jXsXyWgTIGIXhNaIbP8GpauIf4KyeGGOUiwGdPhF1QcBEIzbf2tQ118eZcQ65Jc7bobbNSWsacI6sxriZzcXUJJyns4KmAQ)bL6aVg4q6XxTQWQNpQG0JkSmyJwvIsB8G2sRfwcKmAsvqtHnpXSGcBcpjGQXcHeikSk6pWXjMfuy5AlF6dXCGZcN4IydqSuRfBrelWjX46(extmg6Kypj2eIDsSNEXsX4kVg3lSh4eeCYclbiiQlDfHmNjeZnoIXJ7fRfXiabrDPdjueOeL245ELwlS5jMfuyt4jbu1bt)uHLajJMuf0uIsB8WRsRf28eZckS6bfE8vUcykuEeikSeiz0KQGMsuAJh3xATWMNywqHLjrvxKAaNtZVWsGKrtQcAkrjkSoq6SEmzuAT0gpLwlS5jMfuythh9LQZo)ckSeiz0KQGMsuAdTLwlS5jMfuyz2i0KQIOZlKI)aqvJ1hdOWsGKrtQcAkrPT7vATWsGKrtQcAkSh4eeCYc7VyAMbO6oyFGPPkbXCIzbDcKmAsj2TBI9lMMzaQEJvNXOP6V6gei6eiz0KQWMNywqHfrtp(bMirjkTXRsRf28eZckSFqPoWlSeiz0KQGMsuAZ9LwlSeiz0KQGMcBEIzbfwVe2KuvKfwvug4fwhiDwpMmQpDwG6lS84(suA76kTwyjqYOjvbnf28eZckSVEounbQQAouH9aNGGtwyHecKE8KrtfwhiDwpMmQpDwG6lS8uIsB(MsRfwcKmAsvqtH9aNGGtwyHyaczHOOUxcBwxKAGtvV8dcwZ)Z)hqNajJMuf28eZckSpEQw(vgDQOVeLOWImG5XlTwAJNsRfwcKmAsvqtHDDkSpff28eZckSns4KmAQW2i1yuHnsnbIUdK8i1ezmlOtGKrtkX8l27qADnsikk((JJbNMeO(Xc9e7oXAxm3lgVj2zBqGeeDaDGREHkXUsm)IXnXoBdcKGO38cCsqHvr)booXSGc71JpAsmSFaOeZNGKhPMiJzbUiw2yhLyN8JbGsmw9CiXsGsmUphsm(4eqmw8uT8fJ7j4qInVy)UaXIvmgsmSNuUig5Jd5eIHSqX49EbojOW2iHvq6rfwhi5rQ6du1ZcutmlOeL2qBP1clbsgnPkOPWEGtqWjlSCtSgjCsgn1DGKhPQpqvplqnXSaX8l27qADnsikk((JJbNMeO(Xc9e7oXUoX8lg3eJbdbP)4PA5xvj4qDmhX8lgdgcs)1ZHQjqvvZH6qYlhWl2DIHmOWJkK8Yb8I5xmiHaPhpz0uHnpXSGc7RNdvtGQQMdvIsB3R0AHLajJMuf0uypWji4Kf2gjCsgn1DGKhPQpqvplqnXSaX8l2zxTA5d6pEQw(vvcou)GNqu0xrG5jMfKAXUtmE6(g3lMFXyWqq6VEounbQQAouhsE5aEXUtSZUA1Yh0)lEmR(RlsvrzG3HKxoGxm)I1UyND1QLpO)4PA5xvj4qDiLQlI5xmgmeK(FXJz1FDrQkkd8oK8Yb8IXBIXGHG0F8uT8RQeCOoK8Yb8IDNy80rRyxvyZtmlOW(65q1eOQQ5qLO0gVkTwyjqYOjvbnf21PW(uuyZtmlOW2iHtYOPcBJuJrfwV8dcwZ)Z)hqfsE5aEXCtmxj2TBIXnXIutGOdgu4XhPUjb7eiz0Ksm)IfPMarxLWM1hpvl)obsgnPeZVymyii9hpvl)QkbhQJ5i2TBI9oKwxJeIIIV)4yWPjbQFSqpXCJJy8QWQO)ahNywqHL3pPDiOyUtjCsgnjgYcfZ3XCcmi1fJT54iMcdoauIX7YpiOyC9)Z)hGylumfgCaOeJ7j4qIXFcCX4EcBkwcuIbwXABqHhFK6MeSxyBKWki9Oc73CCQqmNadsLO0M7lTwyjqYOjvbnf28eZckSqmNadsfwf9h44eZckS8EjYrmmhX8DmNadsIniInHyZlwYSyHyXkgedi2If9c7bobbNSW2UyCtSgjCsgn1)MJtfI5eyqsSB3eRrcNKrtDSNQoWzHtCPc3iJzbIDLy(flsikk6X4r1yRQHeJ3edsE5aEXCtSRtm)Ibjei94jJMkrPTRR0AHnpXSGc7thif1Go4GXNhJkSeiz0KQGMsuAZ3uATWsGKrtQcAkS5jMfuyHyobgKkSNlhnvJeIIIV0gpf2dCccozHLBI1iHtYOP(3CCQqmNadsI5xmUjwJeojJM6ypvDGZcN4sfUrgZceZVyVdP11iHOO47pogCAsG6hl0tm34igAfZVyrcrrrpgpQgBvnKyUXrS2fZ9I1IyTlgAfZDi2z9y2QZoG4f7kXUsm)Ibjei94jJMkSk6pWXjMfuy5Dy6yuBedaLyrcrrXlwGNHy8hTwm90GedzHIf4KykmygZceBreZ3XCcmi5IyqcbspUykm4aqjMtcuK3C6LO0MpR0AHLajJMuf0uyZtmlOWcXCcmivyv0FGJtmlOW67ecKECX8DmNadsIrjuFrSbrSjeJ)O1Ir(WzGKykm4aqjg7fpMv)DX4(kwGNHyqcbspUydIySl3fdffVyqkvxeBaIf4KyaYhHyU)7f2dCccozHLBI1iHtYOP(3CCQqmNadsI5xmi5Ld4f7oXo7QvlFq)V4XS6VUivfLbEhsE5aEXArmECLy(f7SRwT8b9)IhZQ)6Iuvug4Di5Ld4f7ooI5EX8lwKquu0JXJQXwvdjgVjgK8Yb8I5MyND1QLpO)x8yw9xxKQIYaVdjVCaVyTiM7lrPnFUsRfwcKmAsvqtH9aNGGtwy5Myns4KmAQJ9u1bolCIlv4gzmlqm)I9oKwxJeIIIxm34i29kS5jMfuyz05Pz1z5RiyjkTXJRkTwyZtmlOWsnM)qWmOclbsgnPkOPeLOWEuFP1sB8uATWsGKrtQcAkSh4eeCYcl3eJbdbP)4PA5xvj4qDmhX8lgdgcs)XXGttcuJfcs12XCeZVymyii9hhdonjqnwiivBhsE5aEXUJJy3R7(cl2t1fbPI6OkTXtHnpXSGc7JNQLFvLGdvyv0FGJtmlOWYvFsmUNGdj2IGWBOokXyiKfsIf4Kyid8dXECm40Ka1pwONyiW1tSwxiivRyN1JEXgqVeL2qBP1clbsgnPkOPWEGtqWjlSmyii9hhdonjqnwiivBhZrm)IXGHG0FCm40Ka1yHGuTDi5Ld4f7ooIDVU7lSypvxeKkQJQ0gpf28eZckS)fpMv)1fPQOmWlSk6pWXjMfuyBNRc00)ILAiLQlIH5igdDsSNeJpjwSBtXyXt1Yxm3Dpy)vIH9KySx8yw9l2IGWBOokXyiKfsIf4Kyid8dXyXXGttcigBSqpXqGRNyTUqqQwXoRh9InGEjkTDVsRfwcKmAsvqtH9aNGGtwyBKWjz0u)bQ6zbQjMfiMFX4MyFqPoWjv3lbHMeZVymyii9)IhZQ)6Iuvug4DmhX8l2z9y2QZoG4fZnoI5(cBEIzbfweDII06mMfuIsB8Q0AHLajJMuf0uypWji4Kf22fdIbiKfII6EjSzDrQbov9Ypiyn)p)FaDcKmAsjMFXoRhZwD2beFxriZzcXUJJy8igVjwKAceDfroeS(bmdcf51jqYOjLy3Ujgedqilef1vug46l1hpvl)VtGKrtkX8l2z9y2QZoG4f7oX4rSReZVymyii9)IhZQ)6Iuvug4DmhX8lgdgcs)Xt1YVQsWH6yoI5xmV8dcwZ)Z)hqfsE5aEX4iMReZVymyiiDfLbU(s9Xt1Y)7QLpOWMNywqHTrcMhVeL2CFP1clbsgnPkOPWQO)ahNywqH1N2vlgYcfR1fcs1kMdK4n2L7IXFcCXyX5UyqkvxeJpobedSHyqmayaOeJ1D7fwKfwbKpIsB8uypWji4Kf2i1ei6pogCAsGASqqQ2obsgnPeZVyCtSi1ei6pEQw(vK9G9DcKmAsvyZtmlOW6SRUcPFXGhQeL2UUsRfwcKmAsvqtHnpXSGc7JJbNMeOgleKQTWQO)ahNywqHLR(KyTUqqQwXCGKySl3fJpobeJpjgE2GelWjXiabrDrm(4uGtqXqGRNyo7QhakX4pb(IfIX6UITqX4kG9HyOiabtT(sVWEGtqWjlSeGGOUiMBCe76CLy(fRrcNKrt9hOQNfOMywGy(f7SRwT8b9)IhZQ)6Iuvug4DmhX8l2zxTA5d6pEQw(vvcou)GNqu0lMBCeJhX8lw7IXnXGyaczHOO(YqQHahQtGKrtkXUDtmfXGHG0r0jksRZywqhZrSB3e7DiTUgjeffF)XXGttcu)yHEI5ghXAxmEeRfX4LyUdXAxmUjwKAceDWGcp(i1njyNajJMuI5xmUjwKAceDvcBwF8uT87eiz0KsSRe7kXUsm)IDwpMT6SdiEXUJJyOvm)I1UyCtmgmeKUdK8i1ezmlOJ5i2TBI9oKwxJeIIIV)4yWPjbQFSqpXCtmEj2vI5xS2fJBID2geibrVbbc8lqXUDtmUj2zxTA5d6i6efP1zmlOJ5i2vLO0MVP0AHLajJMuf0uyZtmlOW(eeMbPQmlGQVZ0KkSh4eeCYcBJeojJM6pqvplqnXSaX8lg3etTr)jimdsvzwavFNPjvvB0J50CaOeZVyrcrrrpgpQgBvnKyUXrm0YJy(fRDXoRhZwD2beFxriZzcXCJJyTl2XPIkhGyUX7tmEj2vIDLy(fJBIXGHG0FCm40Ka1yHGuTDmhX8lw7IXnXyWqq6oqYJutKXSGoMJy3Uj27qADnsikk((JJbNMeO(Xc9eZnX4Lyxj2TBIHmOWJkK8Yb8IDhhXCVy(f7DiTUgjeffF)XXGttcu)yHEIDNy3RWEUC0unsikk(sB8uIsB(SsRfwcKmAsvqtH9aNGGtwyBKWjz0u)bQ6zbQjMfiMFXoRhZwD2beFxriZzcXCJJy8uyZtmlOW(KZpFjkT5ZvATWsGKrtQcAkS5jMfuy)lEmR(RlsvrzGxyv0FGJtmlOWYvFsm2lEmR(fBbID2vRw(aXAprcckgYa)qmwa3VsmmGM(xm(KyjKed1oauIfRyoRJyTUqqQwXsGsm1kgydXWZgKyS4PA5lM7UhSVxypWji4Kf2gjCsgn1FGQEwGAIzbI5xS2flsnbIobAq61zaOQpEQw(FNajJMuID7MyND1QLpO)4PA5xvj4q9dEcrrVyUXrmEe7kX8lw7IXnXIutGO)4yWPjbQXcbPA7eiz0KsSB3elsnbI(JNQLFfzpyFNajJMuID7MyND1QLpO)4yWPjbQXcbPA7qYlhWlMBIHwXUsm)I1UyCtSZ2Gaji6niqGFbk2TBID2vRw(GoIorrADgZc6qYlhWlMBIXJRe72nXo7QvlFqhrNOiToJzbDmhX8l2z9y2QZoG4fZnoI5EXUQeL24XvLwlSeiz0KQGMcBEIzbfwVe2KuvKfwvug4fw9aO6rvy5P7(c75Yrt1iHOO4lTXtH9aNGGtwyH5OQudce9uP(oMJy(fRDXIeIIIEmEun2QAiXUtSZ6XSvNDaX3veYCMqSB3eJBI9bL6aNu9uRfZVyN1JzRo7aIVRiK5mHyUXrSJt1l9r9DiGsSRkSk6pWXjMfuy9TiILk1lwcjXWCCrShmoKyboj2ciX4pbUy6Lp9HyT2k37IXvFsm(4eqm1LbGsmK8dckwGNaXUMpjMIqMZeITqXaBi2huQdCsjg)jWxSqSeCrSR5t9suAJhEkTwyjqYOjvbnf28eZckSEjSjPQilSQOmWlSk6pWXjMfuy9TiIbwXsL6fJ)O1IPgsm(tGpaXcCsma5JqS75Q3fXWEsmEhc3fBbIXS)lg)jWxSqSeCrSR5t9c7bobbNSWcZrvPgei6Ps99biMBIDpxjgVjgmhvLAqGONk13vyWmMfiMFXoRhZwD2beFxriZzcXCJJyhNQx6J67qavjkTXdAlTwyjqYOjvbnf2dCccozHTrcNKrt9hOQNfOMywGy(f7SEmB1zhq8DfHmNjeZnoIHwX8lw7IXGHG0)lEmR(RlsvrzG3XCe72nXy2)fZVyidk8OcjVCaVy3Xrm06kXUQWMNywqH9Xt1YVYOtf9LO0gp3R0AHLajJMuf0uypWji4Kf2gjCsgn1FGQEwGAIzbI5xSZ6XSvNDaX3veYCMqm34igAfZVyTlwJeojJM6ypvDGZcN4sfUrgZce72nXEhsRRrcrrX3FCm40Ka1pwONy3XrmEj2TBIbXaeYcrrDi9lgqnau1JoHtCPtGKrtkXUQWMNywqHLo47aqvHKdC8sGQeL24HxLwlSeiz0KQGMcBEIzbf2hhdonjqnwiivBHvr)booXSGc71pbUySURlIniIb2qSudPuDrm1cixed7jXADHGuTIXFcCXyxUlgMtVWEGtqWjlSrQjq0F8uT8Ri7b77eiz0Ksm)I1iHtYOP(du1Zcutmlqm)IXGHG0)lEmR(RlsvrzG3XCeZVyN1JzRo7aIxS74igAfZVyTlg3eJbdbP7ajpsnrgZc6yoID7MyVdP11iHOO47pogCAsG6hl0tm3eJxIDvjkTXJ7lTwyjqYOjvbnf2dCccozHLBIXGHG0F8uT8RQeCOoMJy(fdzqHhvi5Ld4f7ooI5ZeRfXIutGO)ymbbrWqrDcKmAsvyZtmlOW(4PA5xvj4qLO0gpxxP1clbsgnPkOPWEGtqWjlSTl2VyAMbO6oyFGPPkbXCIzbDcKmAsj2TBI9lMMzaQEJvNXOP6V6gei6eiz0KsSReZVyeGGOU0veYCMqm34i29CLy(fJBI9bL6aNu9uRfZVymyii9)IhZQ)6Iuvug4D1YhuyhqqqiMtuhKc7VyAMbO6nwDgJMQ)QBqGOWoGGGqmNOoEEKAYGkS8uyZtmlOWIOPh)atKOWoGGGqmNOIsVmPUWYtjkTXJVP0AHLajJMuf0uypWji4KfwgmeKoJExLg7JoKYti2TBIHmOWJkK8Yb8IDNy3ZvID7Mymyii9)IhZQ)6Iuvug4DmhX8lw7IXGHG0F8uT8Rm6urFhZrSB3e7SRwT8b9hpvl)kJov03HKxoGxS74igpUsSRkS5jMfuyD2ywqjkTXJpR0AHLajJMuf0uypWji4KfwgmeK(FXJz1FDrQkkd8oMtHnpXSGclJExvfbdEPeL24XNR0AHLajJMuf0uypWji4KfwgmeK(FXJz1FDrQkkd8oMtHnpXSGcldbFc2CaOkrPn06QsRfwcKmAsvqtH9aNGGtwyzWqq6)fpMv)1fPQOmW7yof28eZckSidKy07QkrPn0YtP1clbsgnPkOPWEGtqWjlSmyii9)IhZQ)6Iuvug4DmNcBEIzbf2eCOpGPUEsTUeL2qlAlTwyjqYOjvbnf28eZckSypvNG8(cRI(dCCIzbfwUtijMoedj1AM80umKfkg2NmAsSjiV)(fJR(Ky8Naxm2lEmR(fBreJ7ug49c7bobbNSWYGHG0)lEmR(RlsvrzG3XCe72nXqgu4rfsE5aEXUtm06QsuIc7huQd86r9LwlTXtP1clbsgnPkOPWUof2NIcBEIzbf2gjCsgnvyBKAmQWE2vRw(G(JNQLFvLGd1p4jef9veyEIzbPwm34igpDFJ7lSk6pWXjMfuy59tAhckM7ucNKrtf2gjScspQW(4QAGdPhF1QsuAdTLwlSeiz0KQGMcBEIzbf2gjyE8cRI(dCCIzbfw3PempUydIy8jXsij2jDCgakXwGyCpbhsSdEcrrFxmUIjuFrmgczHKyid8dXuj4qIniIXNedpBqIbwXABqHhFK6MeumgSqmUNWMIXINQLVydqSfQiOyXkgkkeZ3XCcmijgMJyTdwX4D5heumU()5)d4QEH9aNGGtwyBxmUjwJeojJM6pUQg4q6XxTsSB3eJBIfPMarhmOWJpsDtc2jqYOjLy(flsnbIUkHnRpEQw(DcKmAsj2vI5xSZ6XSvNDaX3veYCMqm3eJhX8lg3edIbiKfII6EjSzDrQbov9Ypiyn)p)FaDcKmAsvIsB3R0AHLajJMuf0uyv0FGJtmlOW6t7QfdzHIXINQLVhPvI1IyS4PA5)bCAsIHb00)IXNelHKyjZIfIfRyN0rSfig3tWHe7GNqu03fZDgOVigFCciM7oaLyxpLnb0)InVyjZIfIfRyqmGylw0lSilSciFeL24PWEGtqWjlSW8qDWGcpQKgPWs(iGzn9wmquy5LRkS5jMfuyD2vxH0VyWdvIsB8Q0AHLajJMuf0uypWji4KfwcqquxeZnoIXlxjMFXiabrDPRiK5mHyUXrmECLy(fJBI1iHtYOP(JRQboKE8vReZVyN1JzRo7aIVRiK5mHyUjgpI5xmfXGHG0rgGQYNYMa6)oK8Yb8IDNy8uyZtmlOW(4PA57rAvjkT5(sRfwcKmAsvqtHDDkSpff28eZckSns4KmAQW2i1yuH9SEmB1zhq8DfHmNjeZnoIHwXArmgmeK(JNQLFLrNk67yofwf9h44eZckSxZNelWH0JVA1lgYcfJabbhakXyXt1YxmUNGdvyBKWki9Oc7JRQN1JzRo7aIVeL2UUsRfwcKmAsvqtHDDkSpff28eZckSns4KmAQW2i1yuH9SEmB1zhq8DfHmNjeZnoIDVc7bobbNSWE2geibrV5f4KGcBJewbPhvyFCv9SEmB1zhq8LO0MVP0AHLajJMuf0uyxNc7trHnpXSGcBJeojJMkSnsngvypRhZwD2beFxriZzcXUJJy8uypWji4Kf2gjCsgn1XEQ6aNfoXLkCJmMfiMFXEhsRRrcrrX3FCm40Ka1pwONyUXrmEvyBKWki9Oc7JRQN1JzRo7aIVeL28zLwlSeiz0KQGMcBEIzbf2hpvl)QkbhQWQO)ahNywqHL7j4qIPWGdaLySx8yw9l2cflz2gKyboKE8vR6f2dCccozHTrcNKrt9hxvpRhZwD2beVy(fRDXAKWjz0u)Xv1ahsp(QvID7Mymyii9)IhZQ)6Iuvug4Di5Ld4fZnoIXthTID7Mymyii9dEUFLjbuhZrSB3e7DiTUgjeffF)XXGttcu)yHEI5ghX4Ly(f7SRwT8b9)IhZQ)6Iuvug4Di5Ld4fZnX4XvIDLy(fRDXyWqq6oeezHzqQAdAaF)J80uS7eJxID7MyVdP11iHOO47pogCAsG6hl0tm3eJhXUQeL285kTwyjqYOjvbnf28eZckSpEQw(vvcouHvr)booXSGclAWGaXGKxoGbGsmUNGd9IXqilKelWjXqgu4Hyeq9IniIXUCxm(lWxHymKyqkvxeBaIfJh1lSh4eeCYcBJeojJM6pUQEwpMT6SdiEX8lgYGcpQqYlhWl2DID2vRw(G(FXJz1FDrQkkd8oK8Yb8LOefwgSrRkTwAJNsRfwcKmAsvqtH9aNGGtwy5MyrQjq0bdk84Ju3KGDcKmAsjMFXGyaczHOOEmGl1y9XCQm6urDcKmAsjMFXEhsRRrcrrX3FCm40Ka1pwONy3jM7lS5jMfuyF8PrjkTH2sRfwcKmAsvqtH9aNGGtwyFhsRRrcrrXlMBCedTI5xS2fJBID2geibrhqh4QxOsSB3e7SRwT8b9NGWmivLzbu9DMMu3l9r9GNqu0lgVj2bpHOOVIaZtmli1I5ghXCvhTUxSB3e7DiTUgjeffF)XXGttcu)yHEI5My8sSRkS5jMfuyFCm40Ka1pwOxjkTDVsRfwcKmAsvqtH9aNGGtwyp7QvlFq)jimdsvzwavFNPj19sFup4jef9IXBIDWtik6RiW8eZcsTy3Xrmx1rR7f72nX(ftZmavxtPQYCPs(i9C0uNajJMuI5xmUjgdgcsxtPQYCPs(i9C0uhZrSB3e7xmnZau9MuJb81D59K0davNajJMuI5xmUjMIyWqq6nPgd4R8HzG3XCkS5jMfuyFccZGuvMfq13zAsLO0gVkTwyZtmlOWIsVRhJovuHLajJMuf0uIsBUV0AHnpXSGcltEA(rYuyjqYOjvbnLOeLOW2GG)SGsBO1vOLhx5ZqRpxHLFcbda1xyVEUUV3MVTnUY7xmXAfNeB8CwyigYcfZxFqPoWjLVeds(8ydKuI9RhjwIfRxgKsSdEcqrFxqNRnasmED)IDTf0GGbPeZxqmaHSquu)(8LyXkMVGyaczHOO(91jqYOjLVeRDE8XvDbDU2aiX8n3VyxBbniyqkX8fedqilef1VpFjwSI5ligGqwikQFFDcKmAs5lXANhFCvxqxq)656(EB(224kVFXeRvCsSXZzHHyilumF5aPZ6XKHVeds(8ydKuI9RhjwIfRxgKsSdEcqrFxqNRnasS7D)IDTf0GGbPeZx)IPzgGQFF(sSyfZx)IPzgGQFFDcKmAs5lXANhFCvxqNRnasS7D)IDTf0GGbPeZx)IPzgGQFF(sSyfZx)IPzgGQFFDcKmAs5lXYqmUIUZCnXANhFCvxqNRnasmFZ9l21wqdcgKsmFbXaeYcrr97ZxIfRy(cIbiKfII63xNajJMu(sSmeJRO7mxtS25Xhx1f0f0VEUUV3MVTnUY7xmXAfNeB8CwyigYcfZxh17lXGKpp2ajLy)6rILyX6LbPe7GNau03f05AdGeJx3VyxBbniyqkX8fedqilef1VpFjwSI5ligGqwikQFFDcKmAs5lXAhT(4QUGoxBaKyx39l21wqdcgKsmFbXaeYcrr97ZxIfRy(cIbiKfII63xNajJMu(sS25Xhx1f05AdGeJN7D)IDTf0GGbPeZxqmaHSquu)(8LyXkMVGyaczHOO(91jqYOjLVeRDE8XvDbDU2aiX456UFXU2cAqWGuI5RFX0mdq1VpFjwSI5RFX0mdq1VVobsgnP8LyTJwFCvxqxq)656(EB(224kVFXeRvCsSXZzHHyilumF9bL6aVEuVVeds(8ydKuI9RhjwIfRxgKsSdEcqrFxqNRnasm0E)IDTf0GGbPeZxqmaHSquu)(8LyXkMVGyaczHOO(91jqYOjLVeldX4k6oZ1eRDE8XvDbDb9RNR77T5BBJR8(ftSwXjXgpNfgIHSqX8fd2Ov(smi5ZJnqsj2VEKyjwSEzqkXo4jaf9DbDU2aiX45(f7AlObbdsjMVGyaczHOO(95lXIvmFbXaeYcrr97RtGKrtkFjw784JR6c6c6(wpNfgKsmFJy5jMfiME(47c6fwh4ImAQW6AxlglgtOP4Iy((IcJe0DTRfJRJHc7dXUhpUigADfA5rqxq31UwSRHNau0F)c6U21IXBIX72gKyns4KmAQJ9u1bolCIlv4gzmlqmmhX(vSjeBEXEkeJHqwijgFsmSNeBIUGURDTy8MyxB9ygajMhMoghnj2j16AEIzbv98HyeiGd9IfRyqsHDiXC2GaXKAXGe)f2SlO7AxlgVjgVlBsI5UA6XpWejeBabbHyoHydqSZ6XKHydIy8jX4kG9HyQrj2eIHSqXAS6mgnv)v3Garxqxq31UwmFcs821wpMme0Ztml47oq6SEmz0chUKoo6lvND(fiONNywW3DG0z9yYOfoCHzJqtQkIoVqk(davnwFmab98eZc(UdKoRhtgTWHliA6XpWejCzq48lMMzaQUd2hyAQsqmNywWTB)IPzgGQ3y1zmAQ(RUbbcb98eZc(UdKoRhtgTWHlFqPoWf0Ztml47oq6SEmz0chU4LWMKQISWQIYa3fhiDwpMmQpDwG65WJ7f0Ztml47oq6SEmz0chU865q1eOQQ5qU4aPZ6XKr9PZcuphECzq4ajei94jJMe0Ztml47oq6SEmz0chU84PA5xz0PIExgeoqmaHSquu3lHnRlsnWPQx(bbR5)5)dqqxq31UwmExoaX89nYywGGEEIzbpNMZPPGURfJR(KsSyftrbb9gajgFCkWjOyND1QLp4fJFoHyilumwa3fJjFsj2celsikk(UGEEIzbFlC4sJeojJMCbKEeNhOQNfOMywGlnsngXHbdbP)65q1eOQQ5qDmNB3EhsRRrcrrX3FCm40Ka1pwONBCUobDxlM7mqFrSdEcqrIb3iJzbIniIXNedpBqI5aNfoXLkCJmMfi2tHyjqjMhMoghnjwKquu8IH50f0Ztml4BHdxAKWjz0KlG0J4G9u1bolCIlv4gzmlWLgPgJ44aNfoXLkCJmMf4)DiTUgjeffF)XXGttcu)yHEUXbTc6UwmU6tkXIvmfHmasm(4eqSyfd7jX(GsDGl214(l2cfJbB0kc(c65jMf8TWHlns4KmAYfq6rC(GsDGxdCi94Rw5sJuJrCqR7BjsnbIEJb1c7eiz0KYDGwx1sKAceDV8dcwxK6JNQL)3jqYOjL7aTUQLi1ei6pEQw(vK9G9DcKmAs5oqR7BjsnbIEQZdCIlDcKmAs5oqRRAbTU3D0(7qADnsikk((JJbNMeO(Xc9CJdVUsq31IDnC60uSRX9xSmedzGFiONNywW3chUCsTUMNywqvpF4ci9ioh1lO7AX8DmGyiyA9fXE(tCWPxSyflWjXydk1boPeZ33iJzbI1oZfXu7aqj2VUi2eIHSWd9I5SREaOeBqedSb(aqj28ILnYrNmA6QUGEEIzbFlC4ceduZtmlOQNpCbKEeNpOuh4KYLbHZhuQdCs1tTwq31IX1DC0xeJvphsSeOeJ7ZHeldXqBlIDnFsmfgCaOelWjXqg4hIXJRe7PZcuVlILibbflWZqmE1IyxZNeBqeBcXiF4mq6fJ)e4dqSaNedq(ieJR8ACxSfk28Ib2qmmhb98eZc(w4WLxphQMavvnhYLbHZ7qADnsikk((JJbNMeO(Xc9U768JmOWJkK8Yb8UDD(zWqq6VEounbQQAouhsE5a(7qDuDV0h(pRhZwD2beVBC4fV1EmE0D84QRChOvq31I5tWzHtCrmFFJmMfW7tmUgf(6fd10Gelf7athXsMfleJaee1fXqwOyboj2huQdCXUg3FXANbB0kck2hJwlgKEh6eInXvDX49aZXfXMqStceJHelWZqSF8C0uxqppXSGVfoC5KADnpXSGQE(Wfq6rC(GsDGxpQ3LbHtJeojJM6ypvDGZcN4sfUrgZce0DTyxBb)OiOyy)aqjwkgBqPoWf7ACxm(4eqmiLh8bGsSaNeJaee1fXcCi94RwjONNywW3chUCsTUMNywqvpF4ci9ioFqPoWRh17YGWHaee1LUIqMZe3XPrcNKrt9pOuh41ahsp(Qvc65jMf8TWHlNuRR5jMfu1ZhUaspIdYaMh3LbHt7eccDIPbvpRhZwD2beVBCoovV0h13HaQRUDR9Z6XSvNDaX3veYCM4oo8C7gYGcpQqYlhWFhhE8tii0jMgu9SEmB1zhq8UX5E3UXGHG0)lEmR(RlsvrzGxtSypWj6yo(jee6etdQEwpMT6SdiE34WRRUDR93H06AKquu89hhdonjq9Jf65ghE5NqqOtmnO6z9y2QZoG4DJdVUsq31IXvFsSumgSrRiOy8XjGyqkp4daLybojgbiiQlIf4q6XxTsqppXSGVfoC5KADnpXSGQE(Wfq6rCyWgTYLbHdbiiQlDfHmNjUJtJeojJM6FqPoWRboKE8vRe0DTyCTLp9HyoWzHtCrSbiwQ1ITiIf4KyCDFIRjgdDsSNeBcXoj2tVyPyCLxJ7c65jMf8TWHlj8KaQglesGWLbHdbiiQlDfHmNjCJdpUVfcqqux6qcfbe0Ztml4BHdxs4jbu1bt)KGEEIzbFlC4IEqHhFLRaMcLhbcb98eZc(w4WfMevDrQbConFbDbDx7AXqd2Ove8f0Ztml47myJwX5XNgUmiC4wKAceDWGcp(i1njyNajJMu(HyaczHOOEmGl1y9XCQm6ur(FhsRRrcrrX3FCm40Ka1pwO3DUxqppXSGVZGnAvlC4YJJbNMeO(Xc9Czq48oKwxJeIII3noO1F7C7SniqcIoGoWvVq1TBND1QLpO)eeMbPQmlGQVZ0K6EPpQh8eIIEE7GNqu0xrG5jMfKA344QoAD)TBVdP11iHOO47pogCAsG6hl0ZnEDLGEEIzbFNbB0Qw4WLNGWmivLzbu9DMMKldcNZUA1Yh0FccZGuvMfq13zAsDV0h1dEcrrpVDWtik6RiW8eZcs9DCCvhTU)2TFX0mdq11uQQmxQKpsphn1jqYOjLFUXGHG01uQQmxQKpsphn1XCUD7xmnZau9MuJb81D59K0davNajJMu(5MIyWqq6nPgd4R8HzG3XCe0Ztml47myJw1chUGsVRhJovKGEEIzbFNbB0Qw4WfM808JKrqxq31UwSRTRwT8bVGURfJR(KyCpbhsSfbH3qDuIXqilKelWjXqg4hI94yWPjbQFSqpXqGRNyTUqqQwXoRh9InGUGEEIzbF)OEopEQw(vvcoKlypvxeKkQJIdpUmiC4gdgcs)Xt1YVQsWH6yo(zWqq6pogCAsGASqqQ2oMJFgmeK(JJbNMeOgleKQTdjVCa)DCUx39c6UwS25Qan9VyPgsP6IyyoIXqNe7jX4tIf72umw8uT8fZD3d2FLyypjg7fpMv)ITii8gQJsmgczHKybojgYa)qmwCm40KaIXgl0tme46jwRleKQvSZ6rVydOlONNywW3pQVfoC5V4XS6VUivfLbUlypvxeKkQJIdpUmiCyWqq6pogCAsGASqqQ2oMJFgmeK(JJbNMeOgleKQTdjVCa)DCUx39c65jMf89J6BHdxq0jksRZywGldcNgjCsgn1FGQEwGAIzb(52huQdCs19sqOj)myii9)IhZQ)6Iuvug4Dmh)N1JzRo7aI3noUxqppXSGVFuFlC4sJempUldcN2HyaczHOOUxcBwxKAGtvV8dcwZ)Z)hG)Z6XSvNDaX3veYCM4oo8WBrQjq0ve5qW6hWmiuKxNajJMu3UbXaeYcrrDfLbU(s9Xt1Y)9FwpMT6Sdi(745k)myii9)IhZQ)6Iuvug4Dmh)myii9hpvl)QkbhQJ543l)GG18)8)buHKxoGNJR8ZGHG0vug46l1hpvl)VRw(abDxlMpTRwmKfkwRleKQvmhiXBSl3fJ)e4IXIZDXGuQUigFCcigydXGyaWaqjgR72f0Ztml47h13chU4SRUcPFXGhYfKfwbKpco84YGWjsnbI(JJbNMeOgleKQTtGKrtk)ClsnbI(JNQLFfzpyFNajJMuc6UwmU6tI16cbPAfZbsIXUCxm(4eqm(Ky4zdsSaNeJaee1fX4JtbobfdbUEI5SREaOeJ)e4lwigR7k2cfJRa2hIHIaem16lDb98eZc((r9TWHlpogCAsGASqqQwxgeoeGGOU4gNRZv(BKWjz0u)bQ6zbQjMf4)SRwT8b9)IhZQ)6Iuvug4Dmh)ND1QLpO)4PA5xvj4q9dEcrrVBC4XF7CdIbiKfII6ldPgcCOB3uedgcshrNOiToJzbDmNB3EhsRRrcrrX3FCm40Ka1pwONBCANNw4L7ODUfPMarhmOWJpsDtc2jqYOjLFUfPMarxLWM1hpvl)obsgnPU6QR8FwpMT6Sdi(74Gw)TZngmeKUdK8i1ezmlOJ5C727qADnsikk((JJbNMeO(Xc9CJxx5VDUD2geibrVbbc8lWB342zxTA5d6i6efP1zmlOJ5CLGEEIzbF)O(w4WLNGWmivLzbu9DMMKlNlhnvJeIIINdpUmiCAKWjz0u)bQ6zbQjMf4NBQn6pbHzqQkZcO67mnPQAJEmNMdaL)iHOOOhJhvJTQgYnoOLh)TFwpMT6Sdi(UIqMZeUXP9Jtfvoa349XRRUYp3yWqq6pogCAsGASqqQ2oMJ)25gdgcs3bsEKAImMf0XCUD7DiTUgjeffF)XXGttcu)yHEUXRRUDdzqHhvi5Ld4VJJ79)oKwxJeIIIV)4yWPjbQFSqV7UNGEEIzbF)O(w4WLNC(5Dzq40iHtYOP(du1ZcutmlW)z9y2QZoG47kczot4ghEe0DTyC1NeJ9IhZQFXwGyND1QLpqS2tKGGIHmWpeJfW9ReddOP)fJpjwcjXqTdaLyXkMZ6iwRleKQvSeOetTIb2qm8SbjglEQw(I5U7b77c65jMf89J6BHdx(lEmR(RlsvrzG7YGWPrcNKrt9hOQNfOMywG)2JutGOtGgKEDgaQ6JNQL)3jqYOj1TBND1QLpO)4PA5xvj4q9dEcrrVBC45k)TZTi1ei6pogCAsGASqqQ2obsgnPUDlsnbI(JNQLFfzpyFNajJMu3UD2vRw(G(JJbNMeOgleKQTdjVCaVBO9k)TZTZ2Gaji6niqGFbE72zxTA5d6i6efP1zmlOdjVCaVB84QB3o7QvlFqhrNOiToJzbDmh)N1JzRo7aI3noU)kbDxlMVfrSuPEXsijgMJlI9GXHelWjXwajg)jWftV8PpeR1w5ExmU6tIXhNaIPUmauIHKFqqXc8ei218jXueYCMqSfkgydX(GsDGtkX4pb(IfILGlIDnFQlONNywW3pQVfoCXlHnjvfzHvfLbUl6bq1JIdpD37Y5Yrt1iHOO45WJldchyoQk1GarpvQVJ54V9iHOOOhJhvJTQg6UZ6XSvNDaX3veYCM42nU9bL6aNu9uR9FwpMT6Sdi(UIqMZeUX54u9sFuFhcOUsq31I5BredSILk1lg)rRftnKy8NaFaIf4KyaYhHy3ZvVlIH9Ky8oeUl2ceJz)xm(tGVyHyj4IyxZN6c65jMf89J6BHdx8sytsvrwyvrzG7YGWbMJQsniq0tL67dWT75kEdMJQsniq0tL67kmygZc8FwpMT6Sdi(UIqMZeUX54u9sFuFhcOe0Ztml47h13chU84PA5xz0PIExgeons4KmAQ)av9Sa1eZc8FwpMT6Sdi(UIqMZeUXbT(BNbdbP)x8yw9xxKQIYaVJ5C7gZ(VFKbfEuHKxoG)ooO1vxjONNywW3pQVfoCHo47aqvHKdC8sGYLbHtJeojJM6pqvplqnXSa)N1JzRo7aIVRiK5mHBCqR)2BKWjz0uh7PQdCw4exQWnYywWTBVdP11iHOO47pogCAsG6hl07oo862nigGqwikQdPFXaQbGQE0jCIlxjO7AXU(jWfJ1DDrSbrmWgILAiLQlIPwa5IyypjwRleKQvm(tGlg7YDXWC6c65jMf89J6BHdxECm40Ka1yHGuTUmiCIutGO)4PA5xr2d23jqYOjL)gjCsgn1FGQEwGAIzb(zWqq6)fpMv)1fPQOmW7yo(pRhZwD2be)DCqR)25gdgcs3bsEKAImMf0XCUD7DiTUgjeffF)XXGttcu)yHEUXRRe0Ztml47h13chU84PA5xvj4qUmiC4gdgcs)Xt1YVQsWH6yo(rgu4rfsE5a(744ZAjsnbI(JXeeebdf1jqYOjLGEEIzbF)O(w4Wfen94hyIeUmiCA)xmnZauDhSpW0uLGyoXSGB3(ftZmavVXQZy0u9xDdcex5Naee1LUIqMZeUX5EUYp3(GsDGtQEQ1(zWqq6)fpMv)1fPQOmW7QLpWLbeeeI5e1XZJutgehECzabbHyorfLEzsnhECzabbHyorDq48lMMzaQEJvNXOP6V6geie0Ztml47h13chU4SXSaxgeomyiiDg9Ukn2hDiLN42nKbfEuHKxoG)U75QB3yWqq6)fpMv)1fPQOmW7yo(BNbdbP)4PA5xz0PI(oMZTBND1QLpO)4PA5xz0PI(oK8Yb83XHhxDLGEEIzbF)O(w4Wfg9UQkcg8IldchgmeK(FXJz1FDrQkkd8oMJGEEIzbF)O(w4Wfgc(eS5aq5YGWHbdbP)x8yw9xxKQIYaVJ5iONNywW3pQVfoCbzGeJExLldchgmeK(FXJz1FDrQkkd8oMJGEEIzbF)O(w4WLeCOpGPUEsT2LbHddgcs)V4XS6VUivfLbEhZrq31IXDcjX0HyiPwZKNMIHSqXW(KrtInb593VyC1NeJ)e4IXEXJz1VylIyCNYaVlONNywW3pQVfoCb7P6eK37YGWHbdbP)x8yw9xxKQIYaVJ5C7gYGcpQqYlhWFhADLGUGURDTyU7aMhNGVGURf76Xhnjg2pauI5tqYJutKXSaxelBSJsSt(XaqjgREoKyjqjg3NdjgFCciglEQw(IX9eCiXMxSFxGyXkgdjg2tkxeJ8XHCcXqwOy8EVaNeiONNywW3rgW84CAKWjz0KlG0J44ajpsvFGQEwGAIzbU0i1yeNi1ei6oqYJutKXSGobsgnP8)oKwxJeIIIV)4yWPjbQFSqV7A3982zBqGeeDaDGREHQR8ZTZ2Gaji6nVaNeiONNywW3rgW84TWHlVEounbQQAoKldchU1iHtYOPUdK8iv9bQ6zbQjMf4)DiTUgjeffF)XXGttcu)yHE3DD(5gdgcs)Xt1YVQsWH6yo(zWqq6VEounbQQAouhsE5a(7qgu4rfsE5aE)qcbspEYOjb98eZc(oYaMhVfoC51ZHQjqvvZHCzq40iHtYOPUdK8iv9bQ6zbQjMf4)SRwT8b9hpvl)QkbhQFWtik6RiW8eZcs9D809nU3pdgcs)1ZHQjqvvZH6qYlhWF3zxTA5d6)fpMv)1fPQOmW7qYlhW7V9ZUA1Yh0F8uT8RQeCOoKs1f)myii9)IhZQ)6Iuvug4Di5Ld45ngmeK(JNQLFvLGd1HKxoG)oE6O9kbDxlgVFs7qqXCNs4KmAsmKfkMVJ5eyqQlgBZXrmfgCaOeJ3LFqqX46)N)paXwOykm4aqjg3tWHeJ)e4IX9e2uSeOedSI12Gcp(i1njyxqppXSGVJmG5XBHdxAKWjz0KlG0J48nhNkeZjWGKlnsngXXl)GG18)8)buHKxoG3nxD7g3IutGOdgu4XhPUjb7eiz0KYFKAceDvcBwF8uT87eiz0KYpdgcs)Xt1YVQsWH6yo3U9oKwxJeIIIV)4yWPjbQFSqp34WlbDxlgVxICedZrmFhZjWGKydIyti28ILmlwiwSIbXaITyrxqppXSGVJmG5XBHdxGyobgKCzq40o3AKWjz0u)BooviMtGbPB3AKWjz0uh7PQdCw4exQWnYywWv(JeIIIEmEun2QAiEdsE5aE3Uo)qcbspEYOjb98eZc(oYaMhVfoC5PdKIAqhCW4ZJrc6UwmEhMog1gXaqjwKquu8If4zig)rRftpniXqwOybojMcdMXSaXweX8DmNadsUigKqG0JlMcdoauI5Kaf5nNUGEEIzbFhzaZJ3chUaXCcmi5Y5Yrt1iHOO45WJldchU1iHtYOP(3CCQqmNads(5wJeojJM6ypvDGZcN4sfUrgZc8)oKwxJeIIIV)4yWPjbQFSqp34Gw)rcrrrpgpQgBvnKBCA39T0oADhN1JzRo7aI)QR8djei94jJMe0DTy(oHaPhxmFhZjWGKyuc1xeBqeBcX4pATyKpCgijMcdoauIXEXJz1FxmUVIf4zigKqG0Jl2Gig7YDXqrXlgKs1fXgGybojgG8riM7)UGEEIzbFhzaZJ3chUaXCcmi5YGWHBns4KmAQ)nhNkeZjWGKFi5Ld4V7SRwT8b9)IhZQ)6Iuvug4Di5Ld4BHhx5)SRwT8b9)IhZQ)6Iuvug4Di5Ld4VJJ79hjeff9y8OASv1q8gK8Yb8UD2vRw(G(FXJz1FDrQkkd8oK8Yb8T4Eb98eZc(oYaMhVfoCHrNNMvNLVIGUmiC4wJeojJM6ypvDGZcN4sfUrgZc8)oKwxJeIII3no3tqppXSGVJmG5XBHdxOgZFiygKGUGURDTySbL6axSRTRwT8bVGURfJ3pPDiOyUtjCsgnjONNywW3)GsDGxpQNtJeojJMCbKEeNhxvdCi94Rw5sJuJrCo7QvlFq)Xt1YVQsWH6h8eII(kcmpXSGu7ghE6(g3lO7AXCNsW84IniIXNelHKyN0XzaOeBbIX9eCiXo4jef9DX4kMq9fXyiKfsIHmWpetLGdj2GigFsm8SbjgyfRTbfE8rQBsqXyWcX4EcBkglEQw(InaXwOIGIfRyOOqmFhZjWGKyyoI1oyfJ3LFqqX46)N)pGR6c65jMf89pOuh41J6BHdxAKG5XDzq40o3AKWjz0u)Xv1ahsp(Qv3UXTi1ei6GbfE8rQBsWobsgnP8hPMarxLWM1hpvl)obsgnPUY)z9y2QZoG47kczot4gp(5gedqilef19syZ6IudCQ6LFqWA(F()ae0DTy(0UAXqwOyS4PA57rALyTiglEQw(FaNMKyyan9Vy8jXsijwYSyHyXk2jDeBbIX9eCiXo4jef9DXCNb6lIXhNaI5Udqj21tzta9VyZlwYSyHyXkgedi2IfDb98eZc((huQd86r9TWHlo7QRq6xm4HCbzHva5JGdpUq(iGzn9wmqWHxUYLbHdmpuhmOWJkPre0Ztml47FqPoWRh13chU84PA57rALldchcqquxCJdVCLFcqqux6kczot4ghECLFU1iHtYOP(JRQboKE8vR8FwpMT6Sdi(UIqMZeUXJFfXGHG0rgGQYNYMa6)oK8Yb83XJGURf7A(KyboKE8vREXqwOyeii4aqjglEQw(IX9eCib98eZc((huQd86r9TWHlns4KmAYfq6rCECv9SEmB1zhq8U0i1yeNZ6XSvNDaX3veYCMWnoOTfgmeK(JNQLFLrNk67yoc65jMf89pOuh41J6BHdxAKWjz0KlG0J484Q6z9y2QZoG4DPrQXioN1JzRo7aIVRiK5mHBCUNldcNZ2Gaji6nVaNeiONNywW3)GsDGxpQVfoCPrcNKrtUaspIZJRQN1JzRo7aI3LgPgJ4CwpMT6Sdi(UIqMZe3XHhxgeons4KmAQJ9u1bolCIlv4gzmlW)7qADnsikk((JJbNMeO(Xc9CJdVe0DTyCpbhsmfgCaOeJ9IhZQFXwOyjZ2GelWH0JVAvxqppXSGV)bL6aVEuFlC4YJNQLFvLGd5YGWPrcNKrt9hxvpRhZwD2beV)2BKWjz0u)Xv1ahsp(Qv3UXGHG0)lEmR(RlsvrzG3HKxoG3no80r7TBmyii9dEUFLjbuhZ52T3H06AKquu89hhdonjq9Jf65ghE5)SRwT8b9)IhZQ)6Iuvug4Di5Ld4DJhxDL)2zWqq6oeezHzqQAdAaF)J808oED727qADnsikk((JJbNMeO(Xc9CJNRe0DTyObdcedsE5agakX4Eco0lgdHSqsSaNedzqHhIra1l2Gig7YDX4VaFfIXqIbPuDrSbiwmEuxqppXSGV)bL6aVEuFlC4YJNQLFvLGd5YGWPrcNKrt9hxvpRhZwD2beVFKbfEuHKxoG)UZUA1Yh0)lEmR(RlsvrzG3HKxoGxqxq31Uwm2GsDGtkX89nYywGGURfZ3IigBqPoW5sJempUyjKedZXfXWEsmw8uT8)aonjXIvmgcqitigcC9elWjXCY)NgKymla7flbkXC3bOe76PSjG(3fXOgeqSbrm(KyjKeldX8sFi218jXAhdOP)fd7hakX4D5heumU()5)d4kb98eZc((huQdCsX5Xt1Y)d40KCzq40odgcs)dk1bEhZ52ngmeKEJempEhZ5k)T)oKwxJeIIIV)4yWPjbQFSqV741TBns4KmAQJ9u1bolCIlv4gzml4k)E5heSM)N)pGkK8Yb8CCLGURfZDhW84ILHy3RfXUMpjg)jWxSqmUZkgxeJxTig)jWfJ7SIXFcCXyXXGttciwRleKQvmgmeeXWCelwXYg7Oe7xpsSR5tIXp)Ge7NalJzbFxq31IX11)k2NiKyXkgYaMhxSmeJxTi218jX4pbUyKpYtOVigVelsikk(UyTZMEKy5l2If)OiX(GsDG3Vsq31I5UdyECXYqmE1IyxZNeJ)e4lwig3zDrm33Iy8NaxmUZ6Iyjqj21jg)jWfJ7SILibbfZDkbZJlONNywW3)GsDGtQw4WLtQ118eZcQ65dxaPhXbzaZJ7YGWHqqOtmnO6z9y2QZoG4DJZXP6L(O(oeqD7gdgcs)XXGttcuJfcs12XC8FwpMT6Sdi(UIqMZe3XbT3U9oKwxJeIIIV)4yWPjbQFSqp34Wl)eccDIPbvpRhZwD2beVBC41TBN1JzRo7aIVRiK5mXDC4H3ApsnbIUIihcw)aMrII86eiz0KYpdgcsVrcMhVJ5CLGEEIzbF)dk1boPAHdxE8uT8)aonjxgeoFqPoWjv)jNFE)VdP11iHOO47pogCAsG6hl07oEjONNywW3)GsDGtQw4WLhFA4YGWjsnbIoyqHhFK6MeStGKrtk)qmaHSquupgWLAS(yovgDQi)VdP11iHOO47pogCAsG6hl07o3lO7AX4QoIfRy3tSiHOO4fRDWkMdC2ReRjroIH5iM7oaLyxpLnb0)IXCrSZLJEaOeJfpvl)pGttQlONNywW3)GsDGtQw4WLhpvl)pGttYLZLJMQrcrrXZHhxgeoCRrcNKrtDSNQoWzHtCPc3iJzb(vedgcshzaQkFkBcO)7qYlhWFhp(FhsRRrcrrX3FCm40Ka1pwO3DCUN)iHOOOhJhvJTQgI3GKxoG3TRtq31I5Ulumh4SWjUigCJmMf4IyypjglEQw(FaNMKyBdckgBSqpX4pbUyxpVtSevoGpedZrSyfJxIfjeffVyluSbrm396fBEXGyaWaqj2IGiw7lqSeCrS0BXaHylIyrcrrXFLGEEIzbF)dk1boPAHdxE8uT8)aonjxgeons4KmAQJ9u1bolCIlv4gzmlWF7kIbdbPJmavLpLnb0)Di5Ld4VJNB3IutGOZNsNf4LFqWobsgnP8)oKwxJeIIIV)4yWPjbQFSqV74WRRe0Ztml47FqPoWjvlC4YJJbNMeO(Xc9Czq48oKwxJeIII3no3RL2zWqq6bovHBeeOJ5C7gedqilef1ZMzcNV(lMUIatuEeiUYF7myii9)IhZQ)6Iuvug41el2dCIoMZTBCJbdbP7ajpsnrgZc6yo3U9oKwxJeIII3noU)kbDxlglEQw(FaNMKyXkgKqG0JlM7oaLyxpLnb0)ILaLyXkgbEmijgFsStce7Kq4fX2geuSumemTwm396fBaXkwGtIbiFeIXUCxSbrmN9)HrtDb98eZc((huQdCs1chU84PA5)bCAsUmiCuedgcshzaQkFkBcO)7qYlhWFhhEUD7SRwT8b9)IhZQ)6Iuvug4Di5Ld4VJhFMFfXGHG0rgGQYNYMa6)oK8Yb83D2vRw(G(FXJz1FDrQkkd8oK8Yb8c65jMf89pOuh4KQfoCbLExpgDQixgeomyiiDhcISWmivTbnGV)rEA6gh37)Saf2eDhcISWmivTbnGVdtqt34WZ9e0Ztml47FqPoWjvlC4YJNQL)hWPjjONNywW3)GsDGtQw4WLdoLo1hFdxgeoClsikk6Zxz2)9FwpMT6Sdi(UIqMZeUXHh)myii9hFJ6aQbovvjSzhZXpbiiQl9y8OASvE5k3qDuDV0hf23HoL2q71XtjkrPa]] )

    
end
