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


    spec:RegisterPack( "Subtlety", 20210916, [[devAbcqiuP8isLAtuv9jQkzuQKCkPuTksvHxjLywKkUfQszxs1VGu1WivYXqvSmujEMkv10qvY1OQOTrQQ8nQkfJtLQOZPsvyDOsI5PsL7Hk2hPk)dvsvDqsvrlesLhQsktevQUOkPsTrsvPpIkPYirvQItQsQyLqkVevPkntujLBIQuzNsP8tQkLmusvvlLQs1trPPkL0vrLK2kQsv9vvsvJvLQ0zrLuL2Re)vsdMYHfTyO6XQyYKCzKndXNHKrJItRy1QKk51srZMk3MQSBGFR0WjLJtvPulh0Zv10fUou2Uu47OQgpvfoVkX6rLufZxLY(jUWtP1cRkdQ0gx0fx4rx3dE0Vop3dEXJUUhf24Igvy1YtZefvybPhvyzXWdhfxkSA5f3MQsRf2FXGhQWYeH2Zvqp6rnbdgE)SEO)hpmxgZcoWejq)pEh0xyXXgxCDaf8cRkdQ0gx0fx4rx3dE0Vop3dEXJU8nf2elywyHLD8UwHLzukcuWlSk6pfwwm8WrXfX89ffgjOXsAb5HtqX4r)0rmUOlUWJGMG21ysak65kcA8My8UTbjwJeojUJ6ypv1GZcN4sfUrgZcedttSFfBcXMxSNcXWjKfsIXNed7jXMOlOXBIDT1dFaKyEyUy0CKyN05Q5jMfuDZhIrGao0lwSIbjf2HetBdcet6eds8xyZUGgVjgVlBsIPVo6zoWejeBabbHyAHydqSZ6HNHydIy8jXUUW(qm1OeBcXqwOynwxgJJQ)6AqGOxyDZhFP1c7hu6cgsvAT0gpLwlSeiXDKQGUcBEIzbf2Njvl)pGttQWQO)ahTywqH96GigBqPlyqFJempJyjKedtthXWEsmwMuT8)aonjXIvmCcqitigcC9elyiX0Y)NgKy4la7flbkX03bOe76PSjG(xhXOgeqSbrm(KyjKeldX8sFi210FXUcd4O)fd7hakX4D5heum95)5)dO9c7bobbNSWELy4yii9pO0fmDmnXUDtmCmeKEJempthttS2fZVyxj2Rroxnsikk((ZGbNMeO(Xc9e7oX4Ly3UjwJeojUJ6ypv1GZcN4sfUrgZceRDX8lMx(bbR5)5)dOcjVCaVyCetxLO0gxkTwyjqI7ivbDfwf9h4OfZckS67aMNrSmeJxTi210FX4pbZIfIXDwDeZNTig)jyeJ7S6iwcuIPFIXFcgX4oRyjsqqX49tW8mf28eZckSN05Q5jMfuDZhf2dCccozHLqqOtmnO6z9W3Q2oG4ftpoID0QEPpQVgbuID7My4yii9NbdonjqnwiivBhttm)IDwp8TQTdi(UIqMZeIDhhX4Iy3Uj2Rroxnsikk((ZGbNMeO(Xc9etpoIXlX8lgHGqNyAq1Z6HVvTDaXlMECeJxID7MyN1dFRA7aIVRiK5mHy3XrmEeJ3e7kXI0rGORisJG1pGzKOiVobsChPeZVy4yii9gjyEMoMMyTxyDZhvq6rfwKbmptjkTD)sRfwcK4osvqxH9aNGGtwy)GsxWqQ(tA)8I5xSxJCUAKquu89Nbdonjq9Jf6j2DIXRcBEIzbf2Njvl)pGttQeL24vP1clbsChPkORWEGtqWjlSr6iq0bdkM4J01KGDcK4osjMFXGyaczHOOEmGl1y9XCQ4UurDcK4osjMFXEnY5QrcrrX3Fgm40Ka1pwONy3jMplS5jMfuyFMPrjkT5ZsRfwcK4osvqxHnpXSGc7ZKQL)hWPjvypxooQgjeffFPnEkSh4eeCYcl3eRrcNe3rDSNQAWzHtCPc3iJzbI5xmfHJHG0rgGQYNYMa6)oK8Yb8IDNy8iMFXEnY5QrcrrX3Fgm40Ka1pwONy3XrS7lMFXIeIIIEmEun2QAiX4nXGKxoGxm9et)kSk6pWrlMfuy5QAIfRy3xSiHOO4f7kWkMgC22fRjrAIHPjM(oaLyxpLnb0)IHFrSZLJBaOeJLjvl)pGttQxIsB6xP1clbsChPkORWMNywqH9zs1Y)d40KkSk6pWrlMfuy13fkMgCw4exedUrgZc0rmSNeJLjvl)pGttsSTbbfJnwONy8NGrSRN3jwIkhWhIHPjwSIXlXIeIIIxSfk2GiM(E9InVyqmayaOeBrqe7QfiwcUiw6TyGqSfrSiHOO4BVWEGtqWjlSns4K4oQJ9uvdolCIlv4gzmlqm)IDLykchdbPJmavLpLnb0)Di5Ld4f7oX4rSB3elshbIoFk1wGx(bb7eiXDKsm)I9AKZvJeIIIV)myWPjbQFSqpXUJJy8sS2lrPnFtP1clbsChPkORWEGtqWjlSVg5C1iHOO4ftpoIDFXArSRedhdbPhmufUrqGoMMy3Ujgedqilef1ZMzcNV(lMRIatuEei6eiXDKsS2fZVyxjgogcs)V4HVUVUivfLbtnXI9aNOJPj2TBIXnXWXqq6AqYJutKXSGoMMy3Uj2RroxnsikkEX0JJy(uS2lS5jMfuyFgm40Ka1pwOxjkTDplTwyjqI7ivbDf28eZckSptQw(FaNMuHvr)boAXSGclltQw(FaNMKyXkgKqG0ZiM(oaLyxpLnb0)ILaLyXkgbEmijgFsStce7Kq4fX2geuSumemNtm996fBaXkwWqIbiFeIXUCxSbrmT9)b3r9c7bobbNSWQiCmeKoYauv(u2eq)3HKxoGxS74igpID7MyNDDQLpO)x8Wx3xxKQIYGPdjVCaVy3jgp3tX8lMIWXqq6idqv5tzta9FhsE5aEXUtSZUo1Yh0)lE4R7RlsvrzW0HKxoGVeL2UhLwlSeiXDKQGUc7bobbNSWIJHG01iiYcZGu1g0a((h5PPy6XrmFkMFXolqHnrxJGilmdsvBqd47We0um94igp3VWMNywqHfLBxpCxQOsuAJhDvATWMNywqH9zs1Y)d40KkSeiXDKQGUsuAJhEkTwyjqI7ivbDf2dCccozHLBIfjeff95R47)I5xSZ6HVvTDaX3veYCMqm94igpI5xmCmeK(ZSrDa1GHQQe2SJPjMFXiabrDPhJhvJTYlDjMEIH6O6EPpkS5jMfuypmuQvFMnkrjkSkcjXCrP1sB8uATWMNywqHT5CAwyjqI7ivbDLO0gxkTwyjqI7ivbDf2vRW(uuyZtmlOW2iHtI7OcBJ0HrfwCmeK(7MdvtGQQMd1X0e72nXEnY5QrcrrX3Fgm40Ka1pwONy6Xrm9RWQO)ahTywqHLR(KsSyftrbb9gajgFgkyiOyNDDQLp4fJFoHyilumwa3fdpFsj2celsikk(EHTrcRG0JkSpqvplqnXSGsuA7(LwlSeiXDKQGUc7QvyFkkS5jMfuyBKWjXDuHTr6WOcRgCw4exQWnYywGy(f71iNRgjeffF)zWGttcu)yHEIPhhX4sHvr)boAXSGcRVfWDrSdtcqrIb3iJzbIniIXNeJjBqIPbNfoXLkCJmMfi2tHyjqjMhMlgnhjwKquu8IHP1lSnsyfKEuHf7PQgCw4exQWnYywqjkTXRsRfwcK4osvqxHD1kSpff28eZckSns4K4oQW2iDyuHLl(uSwelshbIEJb1c7eiXDKsm9HyCrxI1Iyr6iq09YpiyDrQptQw(FNajUJuIPpeJl6sSwelshbI(ZKQLFfzpyFNajUJuIPpeJl(uSwelshbIE6YdCIlDcK4osjM(qmUOlXArmU4tX0hIDLyVg5C1iHOO47pdgCAsG6hl0tm94igVeR9cRI(dC0IzbfwU6tkXIvmfHmasm(meqSyfd7jX(GsxWi214(l2cfdhBCkc(f2gjScspQW(bLUGPgmq6zwNQeL28zP1clbsChPkORWQO)ahTywqH9Am0PPyxJ7VyzigYa)OWMNywqH9KoxnpXSGQB(OW6MpQG0JkSh1xIsB6xP1clbsChPkORWQO)ahTywqH13XaIHG5Cxe75pXHHEXIvSGHeJnO0fmKsmFFJmMfi2v4xetTdaLy)QJytigYcp0lM2UUbGsSbrmWgmdaLyZlw2ihxI7O27f28eZckSqmqnpXSGQB(OWEGtqWjlSFqPlyivpDUcRB(OcspQW(bLUGHuLO0MVP0AHLajUJuf0vyZtmlOW(U5q1eOQQ5qfwf9h4OfZckS6tnn3fXyDZHelbkX4(CiXYqmU0Iyxt)ftHbhakXcgsmKb(Hy8OlXE6Sa1RJyjsqqXcMmeJxTi210FXgeXMqmYhAdKEX4pbZaelyiXaKpcX46Ug3fBHInVyGnedtRWEGtqWjlSVg5C1iHOO47pdgCAsG6hl0tS7et)eZVyidkMOcjVCaVy6jM(jMFXWXqq6VBounbQQAouhsE5aEXUtmuhv3l9Hy(f7SE4BvBhq8IPhhX4Ly8MyxjwmEKy3jgp6sS2ftFigxkrPT7zP1clbsChPkORWQO)ahTywqHv)HZcN4Iy((gzmlGRVyCnk81lgQPbjwk2bMAIL4lwigbiiQlIHSqXcgsSpO0fmIDnU)IDfo24ueuSpgNtmi9A0jeBI27IX1lMMoInHyNeigojwWKHy)4P5OEHnpXSGc7jDUAEIzbv38rH9aNGGtwyBKWjXDuh7PQgCw4exQWnYywqH1nFubPhvy)GsxWupQVeL2UhLwlSeiXDKQGUcRI(dC0Izbf2RTGFueumSFaOelfJnO0fmIDnUlgFgcigKYdZaqjwWqIracI6IybdKEM1PkS5jMfuypPZvZtmlO6MpkSh4eeCYclbiiQlDfHmNje7ooI1iHtI7O(hu6cMAWaPNzDQcRB(OcspQW(bLUGPEuFjkTXJUkTwyjqI7ivbDf2dCccozH9kXiee6etdQEwp8TQTdiEX0JJyhTQx6J6RraLyTl2TBIDLyN1dFRA7aIVRiK5mHy3XrmEe72nXqgumrfsE5aEXUJJy8iMFXiee6etdQEwp8TQTdiEX0JJy3xSB3edhdbP)x8Wx3xxKQIYGPMyXEGt0X0eZVyeccDIPbvpRh(w12beVy6XrmEjw7ID7Myxj2Rroxnsikk((ZGbNMeO(Xc9etpoIXlX8lgHGqNyAq1Z6HVvTDaXlMECeJxI1EHnpXSGc7jDUAEIzbv38rH1nFubPhvyrgW8mLO0gp8uATWsGe3rQc6kSk6pWrlMfuy5Qpjwkgo24ueum(meqmiLhMbGsSGHeJaee1fXcgi9mRtvyZtmlOWEsNRMNywq1nFuypWji4Kfwcqqux6kczoti2DCeRrcNe3r9pO0fm1GbspZ6ufw38rfKEuHfhBCQsuAJhUuATWsGe3rQc6kS5jMfuyt4jbunwiKarHvr)boAXSGclxB5tFiMgCw4exeBaILoNylIybdjM(u)5AIHtNe7jXMqStI90lwkgx314EH9aNGGtwyjabrDPRiK5mHy6XrmE8PyTigbiiQlDiHIaLO0gp3V0AHnpXSGcBcpjGQAyUNkSeiXDKQGUsuAJhEvATWMNywqH1nOyIVEDHPq5rGOWsGe3rQc6krPnE8zP1cBEIzbfw8evDrQbCon)clbsChPkOReLOWQbPZ6HNrP1sB8uATWMNywqHn10CxQA78lOWsGe3rQc6krPnUuATWMNywqHfFJWrQkIlVqk(davnwFmGclbsChPkOReL2UFP1clbsChPkORWEGtqWjlS)I5WhGQRH9bMJQeetlMf0jqI7iLy3Uj2Vyo8bO6nwxgJJQ)6AqGOtGe3rQcBEIzbfweh9mhyIeLO0gVkTwyZtmlOW(bLUGPWsGe3rQc6krPnFwATWsGe3rQc6kS5jMfuy9sytsvrwyvrzWuy1G0z9WZO(0zbQVWYJplrPn9R0AHLajUJuf0vyZtmlOW(U5q1eOQQ5qf2dCccozHfsiq6zsChvy1G0z9WZO(0zbQVWYtjkT5BkTwyjqI7ivbDf2dCccozHfIbiKfII6EjSzDrQbdv9Ypiyn)p)FaDcK4osvyZtmlOW(mPA5xXDPI(suIclYaMNP0APnEkTwyjqI7ivbDf2vRW(uuyZtmlOW2iHtI7OcBJ0Hrf2iDei6AqYJutKXSGobsChPeZVyVg5C1iHOO47pdgCAsG6hl0tS7e7kX8Py8MyNTbbsq0b0bUUfQeRDX8lg3e7SniqcIEZlWjbfwf9h4OfZckSxpZ4iXW(bGsm9hsEKAImMfOJyzJDuIDYpgakXyDZHelbkX4(CiX4ZqaXyzs1YxmUNGdj28I97celwXWjXWEsPJyKpoKwigYcfJ37f4KGcBJewbPhvy1GKhPQpqvplqnXSGsuAJlLwlSeiXDKQGUc7bobbNSWYnXAKWjXDuxdsEKQ(av9Sa1eZceZVyVg5C1iHOO47pdgCAsG6hl0tS7et)eZVyCtmCmeK(ZKQLFvLGd1X0eZVy4yii93nhQMavvnhQdjVCaVy3jgYGIjQqYlhWlMFXGecKEMe3rf28eZckSVBounbQQAoujkTD)sRfwcK4osvqxH9aNGGtwyBKWjXDuxdsEKQ(av9Sa1eZceZVyNDDQLpO)mPA5xvj4q9dtcrrFfbMNywq6e7oX4P7B8Py(fdhdbP)U5q1eOQQ5qDi5Ld4f7oXo76ulFq)V4HVUVUivfLbthsE5aEX8l2vID21Pw(G(ZKQLFvLGd1HuQUiMFXWXqq6)fp8191fPQOmy6qYlhWlgVjgogcs)zs1YVQsWH6qYlhWl2DIXtNlI1EHnpXSGc77MdvtGQQMdvIsB8Q0AHLajUJuf0vyxTc7trHnpXSGcBJeojUJkSnshgvy9Ypiyn)p)Favi5Ld4ftpX0Ly3Ujg3elshbIoyqXeFKUMeStGe3rkX8lwKoceDvcBwFMuT87eiXDKsm)IHJHG0FMuT8RQeCOoMMy3Uj2Rroxnsikk((ZGbNMeO(Xc9etpoIXRcRI(dC0IzbfwEpKtJGIX7NWjXDKyilumFhtlWGuxm2MJMykm4aqjgVl)GGIPp)p)FaITqXuyWbGsmUNGdjg)jyeJ7jSPyjqjgyfRTbft8r6AsWEHTrcRG0JkSFZrRcX0cmivIsB(S0AHLajUJuf0vyZtmlOWcX0cmivyv0FGJwmlOWY7LinXW0eZ3X0cmij2Gi2eInVyj(IfIfRyqmGylw0lSh4eeCYc7vIXnXAKWjXDu)BoAviMwGbjXUDtSgjCsCh1XEQQbNfoXLkCJmMfiw7I5xSiHOOOhJhvJTQgsmEtmi5Ld4ftpX0pX8lgKqG0ZK4oQeL20VsRf28eZckSpDGuud6WagFBmQWsGe3rQc6krPnFtP1clbsChPkORWMNywqHfIPfyqQWEUCCunsikk(sB8uypWji4KfwUjwJeojUJ6FZrRcX0cmijMFX4Myns4K4oQJ9uvdolCIlv4gzmlqm)I9AKZvJeIIIV)myWPjbQFSqpX0JJyCrm)Ifjeff9y8OASv1qIPhhXUsmFkwlIDLyCrm9HyN1dFRA7aIxS2fRDX8lgKqG0ZK4oQWQO)ahTywqHL3H5IrTrmauIfjeffVybtgIXFCoXCtdsmKfkwWqIPWGzmlqSfrmFhtlWGKoIbjei9mIPWGdaLyAjqrEZPxIsB3ZsRfwcK4osvqxHnpXSGcletlWGuHvr)boAXSGcRVtiq6zeZ3X0cmijgLq3fXgeXMqm(JZjg5dTbsIPWGdaLySx8Wx33fJ7RybtgIbjei9mIniIXUCxmuu8IbPuDrSbiwWqIbiFeI5ZVxypWji4KfwUjwJeojUJ6FZrRcX0cmijMFXGKxoGxS7e7SRtT8b9)Ih(6(6IuvugmDi5Ld4fRfX4rxI5xSZUo1Yh0)lE4R7RlsvrzW0HKxoGxS74iMpfZVyrcrrrpgpQgBvnKy8MyqYlhWlMEID21Pw(G(FXdFDFDrQkkdMoK8Yb8I1Iy(SeL2UhLwlSeiXDKQGUc7bobbNSWYnXAKWjXDuh7PQgCw4exQWnYywGy(f71iNRgjeffVy6XrS7xyZtmlOWI7YtZQ2YxrWsuAJhDvATWMNywqHLAm)HGzqfwcK4osvqxjkrH9O(sRL24P0AHLajUJuf0vypWji4KfwUjgogcs)zs1YVQsWH6yAI5xmCmeK(ZGbNMeOgleKQTJPjMFXWXqq6pdgCAsGASqqQ2oK8Yb8IDhhXUF3NfwSNQlcsf1rvAJNcBEIzbf2Njvl)QkbhQWQO)ahTywqHLR(KyCpbhsSfbH3qDuIHtilKelyiXqg4hI9myWPjbQFSqpXqGRNyTUqqQwXoRh9InGEjkTXLsRfwcK4osvqxH9aNGGtwyXXqq6pdgCAsGASqqQ2oMMy(fdhdbP)myWPjbQXcbPA7qYlhWl2DCe7(DFwyXEQUiivuhvPnEkS5jMfuy)lE4R7RlsvrzWuyv0FGJwmlOWEfxf4O)flDqkvxedttmC6KypjgFsSy3MIXYKQLVy67EW(2fd7jXyV4HVUxSfbH3qDuIHtilKelyiXqg4hIXYGbNMeqm2yHEIHaxpXADHGuTIDwp6fBa9suA7(LwlSeiXDKQGUc7bobbNSW2iHtI7O(du1Zcutmlqm)IXnX(GsxWqQUxcchjMFXWXqq6)fp8191fPQOmy6yAI5xSZ6HVvTDaXlMECeZNf28eZckSiUef5CzmlOeL24vP1clbsChPkORWEGtqWjlSxjgedqilef19syZ6IudgQ6LFqWA(F()a6eiXDKsm)IDwp8TQTdi(UIqMZeIDhhX4rmEtSiDei6kI0iy9dygekYRtGe3rkXUDtmigGqwikQROmyCxQptQw(FNajUJuI5xSZ6HVvTDaXl2DIXJyTlMFXWXqq6)fp8191fPQOmy6yAI5xmCmeK(ZKQLFvLGd1X0eZVyE5heSM)N)pGkK8Yb8IXrmDjMFXWXqq6kkdg3L6ZKQL)3vlFqHnpXSGcBJemptjkT5ZsRfwcK4osvqxHvr)boAXSGcR(VRtmKfkwRleKQvmniXBSl3fJ)emIXYWDXGuQUigFgcigydXGyaWaqjgR(2lSilSciFeL24PWEGtqWjlSr6iq0Fgm40Ka1yHGuTDcK4osjMFX4Myr6iq0FMuT8Ri7b77eiXDKQWMNywqHvBxxfs)IbpujkTPFLwlSeiXDKQGUcBEIzbf2NbdonjqnwiivBHvr)boAXSGclx9jXADHGuTIPbjXyxUlgFgcigFsmMSbjwWqIracI6Iy8zOGHGIHaxpX021nauIXFcMfleJvFfBHIDDH9HyOiabtN7sVWEGtqWjlSeGGOUiMECet)0Ly(fRrcNe3r9hOQNfOMywGy(f7SRtT8b9)Ih(6(6IuvugmDmnX8l2zxNA5d6ptQw(vvcou)WKqu0lMECeJhX8l2vIXnXGyaczHOO(ItQHahQtGe3rkXUDtmfHJHG0rCjkY5YywqhttSB3e71iNRgjeffF)zWGttcu)yHEIPhhXUsmEeRfX4Ly6dXUsmUjwKoceDWGIj(iDnjyNajUJuI5xmUjwKoceDvcBwFMuT87eiXDKsS2fRDXAxm)IDwp8TQTdiEXUJJyCrm)IDLyCtmCmeKUgK8i1ezmlOJPj2TBI9AKZvJeIIIV)myWPjbQFSqpX0tmEjw7I5xSReJBID2geibrVbbcMlqXUDtmUj2zxNA5d6iUef5CzmlOJPjw7LO0MVP0AHLajUJuf0vyZtmlOW(eeMbPQ4lGQV20KkSh4eeCYcBJeojUJ6pqvplqnXSaX8lg3etTr)jimdsvXxavFTPjvvB0J50CaOeZVyrcrrrpgpQgBvnKy6XrmUWJy(f7kXoRh(w12beFxriZzcX0JJyxj2rRIkhGy6X1xmEjw7I1Uy(fJBIHJHG0Fgm40Ka1yHGuTDmnX8l2vIXnXWXqq6AqYJutKXSGoMMy3Uj2Rroxnsikk((ZGbNMeO(Xc9etpX4LyTl2TBIHmOyIkK8Yb8IDhhX8Py(f71iNRgjeffF)zWGttcu)yHEIDNy3VWEUCCunsikk(sB8uIsB3ZsRfwcK4osvqxH9aNGGtwyBKWjXDu)bQ6zbQjMfiMFXoRh(w12beFxriZzcX0JJy8uyZtmlOW(K2pFjkTDpkTwyjqI7ivbDf28eZckS)fp8191fPQOmykSk6pWrlMfuy5Qpjg7fp819ITaXo76ulFGyxLibbfdzGFiglG7TlggWr)lgFsSesIHAhakXIvmTvtSwxiivRyjqjMAfdSHymzdsmwMuT8ftF3d23lSh4eeCYcBJeojUJ6pqvplqnXSaX8l2vIfPJarNani3Qnau1Njvl)VtGe3rkXUDtSZUo1Yh0FMuT8RQeCO(HjHOOxm94igpI1Uy(f7kX4Myr6iq0Fgm40Ka1yHGuTDcK4osj2TBIfPJar)zs1YVIShSVtGe3rkXUDtSZUo1Yh0Fgm40Ka1yHGuTDi5Ld4ftpX4IyTlMFXUsmUj2zBqGee9geiyUaf72nXo76ulFqhXLOiNlJzbDi5Ld4ftpX4rxID7MyNDDQLpOJ4suKZLXSGoMMy(f7SE4BvBhq8IPhhX8PyTxIsB8ORsRfwcK4osvqxHnpXSGcRxcBsQkYcRkkdMcRBau9OkS809zH9C54OAKquu8L24PWEGtqWjlSWCuvQbbIEQuFhttm)IDLyrcrrrpgpQgBvnKy3j2z9W3Q2oG47kczoti2TBIXnX(GsxWqQE6CI5xSZ6HVvTDaX3veYCMqm94i2rR6L(O(Aeqjw7fwf9h4OfZckSxheXsL6flHKyyA6i2dgnsSGHeBbKy8NGrm3YN(qSwBL7DX4QpjgFgciM6Yaqjgs(bbflysGyxt)ftriZzcXwOyGne7dkDbdPeJ)emlwiwcUi210)EjkTXdpLwlSeiXDKQGUcBEIzbfwVe2KuvKfwvugmfwf9h4OfZckSxheXaRyPs9IXFCoXudjg)jygGybdjgG8ri2911RJyypjgVdH7ITaXW3)fJ)emlwiwcUi210)EH9aNGGtwyH5OQudce9uP((aetpXUVUeJ3edMJQsniq0tL67kmygZceZVyN1dFRA7aIVRiK5mHy6XrSJw1l9r91iGQeL24HlLwlSeiXDKQGUc7bobbNSW2iHtI7O(du1Zcutmlqm)IDwp8TQTdi(UIqMZeIPhhX4Iy(f7kXWXqq6)fp8191fPQOmy6yAID7My47)I5xmKbftuHKxoGxS74igx0LyTxyZtmlOW(mPA5xXDPI(suAJN7xATWsGe3rQc6kSh4eeCYcBJeojUJ6pqvplqnXSaX8l2z9W3Q2oG47kczotiMECeJlI5xSReRrcNe3rDSNQAWzHtCPc3iJzbID7MyVg5C1iHOO47pdgCAsG6hl0tS74igVe72nXGyaczHOOoK(fdOgaQ6XLWjU0jqI7iLyTxyZtmlOWshMDaOQqsdoEjqvIsB8WRsRfwcK4osvqxHnpXSGc7ZGbNMeOgleKQTWQO)ahTywqH96NGrmw9vhXgeXaBiw6GuQUiMAbKoIH9KyTUqqQwX4pbJySl3fdtRxypWji4Kf2iDei6ptQw(vK9G9DcK4osjMFXAKWjXDu)bQ6zbQjMfiMFXWXqq6)fp8191fPQOmy6yAI5xSZ6HVvTDaXl2DCeJlI5xSReJBIHJHG01GKhPMiJzbDmnXUDtSxJCUAKquu89Nbdonjq9Jf6jMEIXlXAVeL24XNLwlSeiXDKQGUc7bobbNSWYnXWXqq6ptQw(vvcouhttm)IHmOyIkK8Yb8IDhhXUNI1Iyr6iq0Fm8GGiyOOobsChPkS5jMfuyFMuT8RQeCOsuAJh9R0AHLajUJuf0vypWji4Kf2Re7xmh(auDnSpWCuLGyAXSGobsChPe72nX(fZHpavVX6YyCu9xxdceDcK4osjw7I5xmcqqux6kczotiMECe7(6sm)IXnX(GsxWqQE6CI5xmCmeK(FXdFDFDrQkkdMUA5dkSdiiietlQdsH9xmh(au9gRlJXr1FDniquyhqqqiMwuhppsnzqfwEkS5jMfuyrC0ZCGjsuyhqqqiMwur5w80vy5PeL24X3uATWsGe3rQc6kSh4eeCYclogcsh3TRYH9rhs5je72nXqgumrfsE5aEXUtS7RlXUDtmCmeK(FXdFDFDrQkkdMoMMy(f7kXWXqq6ptQw(vCxQOVJPj2TBID21Pw(G(ZKQLFf3Lk67qYlhWl2DCeJhDjw7f28eZckSABmlOeL245EwATWsGe3rQc6kSh4eeCYclogcs)V4HVUVUivfLbthtRWMNywqHf3TRQIGbVuIsB8CpkTwyjqI7ivbDf2dCccozHfhdbP)x8Wx3xxKQIYGPJPvyZtmlOWItWNGnhaQsuAJl6Q0AHLajUJuf0vypWji4KfwCmeK(FXdFDFDrQkkdMoMwHnpXSGclYajC3UQsuAJl8uATWsGe3rQc6kSh4eeCYclogcs)V4HVUVUivfLbthtRWMNywqHnbh6dy6QN05krPnUWLsRfwcK4osvqxHnpXSGcl2t1jiVVWQO)ahTywqHL7esI5cXqsNdppnfdzHIH9jUJeBcY75kIXvFsm(tWig7fp819ITiIXDkdMEH9aNGGtwyXXqq6)fp8191fPQOmy6yAID7MyidkMOcjVCaVy3jgx0vjkrH9dkDbt9O(sRL24P0AHLajUJuf0vyxTc7trHnpXSGcBJeojUJkSnshgvyp76ulFq)zs1YVQsWH6hMeII(kcmpXSG0jMECeJNUVXNfwf9h4OfZckS8EiNgbfJ3pHtI7OcBJewbPhvyFgvnyG0ZSovjkTXLsRfwcK4osvqxHnpXSGcBJemptHvr)boAXSGclVFcMNrSbrm(KyjKe7KAAdaLylqmUNGdj2HjHOOVl21DcDxedNqwijgYa)qmvcoKydIy8jXyYgKyGvS2gumXhPRjbfdhleJ7jSPySmPA5l2aeBHkckwSIHIcX8DmTadsIHPj2vGvmEx(bbftF(F()aAVxypWji4Kf2ReJBI1iHtI7O(ZOQbdKEM1Pe72nX4Myr6iq0bdkM4J01KGDcK4osjMFXI0rGORsyZ6ZKQLFNajUJuI1Uy(f7SE4BvBhq8DfHmNjetpX4rm)IXnXGyaczHOOUxcBwxKAWqvV8dcwZ)Z)hqNajUJuLO029lTwyjqI7ivbDfwf9h4OfZckS6)UoXqwOySmPA57roLyTigltQw(FaNMKyyah9Vy8jXsijwIVyHyXk2j1eBbIX9eCiXomjef9DX8TaUlIXNHaIPVdqj21tzta9VyZlwIVyHyXkgedi2If9clYcRaYhrPnEkSh4eeCYclmpuhmOyIk5qkSKpcywtVfdefwEPRcBEIzbfwTDDvi9lg8qLO0gVkTwyjqI7ivbDf2dCccozHLaee1fX0JJy8sxI5xmcqqux6kczotiMECeJhDjMFX4Myns4K4oQ)mQAWaPNzDkX8l2z9W3Q2oG47kczotiMEIXJy(ftr4yiiDKbOQ8PSjG(VdjVCaVy3jgpf28eZckSptQw(EKtvIsB(S0AHLajUJuf0vyxTc7trHnpXSGcBJeojUJkSnshgvypRh(w12beFxriZzcX0JJyCrSwedhdbP)mPA5xXDPI(oMwHvr)boAXSGc710FXcgi9mRt9IHSqXiqqWbGsmwMuT8fJ7j4qf2gjScspQW(mQ6z9W3Q2oG4lrPn9R0AHLajUJuf0vyxTc7trHnpXSGcBJeojUJkSnshgvypRh(w12beFxriZzcX0JJy3VWEGtqWjlSNTbbsq0BEbojOW2iHvq6rf2NrvpRh(w12beFjkT5BkTwyjqI7ivbDf2vRW(uuyZtmlOW2iHtI7OcBJ0Hrf2Z6HVvTDaX3veYCMqS74igpf2dCccozHTrcNe3rDSNQAWzHtCPc3iJzbI5xSxJCUAKquu89Nbdonjq9Jf6jMECeJxf2gjScspQW(mQ6z9W3Q2oG4lrPT7zP1clbsChPkORWMNywqH9zs1YVQsWHkSk6pWrlMfuy5EcoKykm4aqjg7fp819ITqXs8TbjwWaPNzDQEH9aNGGtwyBKWjXDu)zu1Z6HVvTDaXlMFXUsSgjCsCh1FgvnyG0ZSoLy3Ujgogcs)V4HVUVUivfLbthsE5aEX0JJy805Iy3Ujgogcs)WK7xXta1X0e72nXEnY5QrcrrX3Fgm40Ka1pwONy6XrmEjMFXo76ulFq)V4HVUVUivfLbthsE5aEX0tmE0LyTlMFXUsmCmeKUgbrwygKQ2GgW3)ipnf7oX4Ly3Uj2Rroxnsikk((ZGbNMeO(Xc9etpX4IyTxIsB3JsRfwcK4osvqxHnpXSGc7ZKQLFvLGdvyv0FGJwmlOWIomiqmi5LdyaOeJ7j4qVy4eYcjXcgsmKbftigbuVydIySl3fJ)c8vigojgKs1fXgGyX4r9c7bobbNSW2iHtI7O(ZOQN1dFRA7aIxm)IHmOyIkK8Yb8IDNyNDDQLpO)x8Wx3xxKQIYGPdjVCaFjkrHfhBCQsRL24P0AHLajUJuf0vypWji4KfwUjwKoceDWGIj(iDnjyNajUJuI5xmigGqwikQhd4snwFmNkUlvuNajUJuI5xSxJCUAKquu89Nbdonjq9Jf6j2DI5ZcBEIzbf2NzAuIsBCP0AHLajUJuf0vypWji4Kf2xJCUAKquu8IPhhX4Iy(f7kX4MyNTbbsq0b0bUUfQe72nXo76ulFq)jimdsvXxavFTPj19sFupmjef9IXBIDysik6RiW8eZcsNy6XrmD15Ipf72nXEnY5QrcrrX3Fgm40Ka1pwONy6jgVeRDX8lgogcsxJGilmdsvBqd47FKNMIDhhX4vHnpXSGc7ZGbNMeO(Xc9krPT7xATWsGe3rQc6kSh4eeCYc7zxNA5d6pbHzqQk(cO6RnnPUx6J6HjHOOxmEtSdtcrrFfbMNywq6e7ooIPRox8Py3Uj2Vyo8bO6okvv8lvYhPNMJ6eiXDKsm)IXnXWXqq6okvv8lvYhPNMJ6yAID7My)I5WhGQ3KAmGVUlxpKBaO6eiXDKsm)IXnXueogcsVj1yaFLpmdMoMwHnpXSGc7tqygKQIVaQ(AttQeL24vP1cBEIzbfwuUD9WDPIkSeiXDKQGUsuAZNLwlS5jMfuyXZtZps8clbsChPkOReLOef2ge8NfuAJl6Il8OR7595PWYpHGbG6lSxV(03B760gxhxrmXALHeB80wyigYcfZxFqPlyiLVeds(2ydKuI9RhjwIfRxgKsSdtcqrFxqJRnasmEXve7AlObbdsjMVGyaczHOO(96lXIvmFbXaeYcrr97TtGe3rkFj2v84J27cACTbqI5B4kIDTf0GGbPeZxqmaHSquu)E9LyXkMVGyaczHOO(92jqI7iLVe7kE8r7DbnbTRxF67TDDAJRJRiMyTYqInEAlmedzHI5lniDwp8m8LyqY3gBGKsSF9iXsSy9YGuIDysak67cACTbqIDFUIyxBbniyqkX81Vyo8bO63RVelwX81Vyo8bO63BNajUJu(sSR4XhT3f04AdGe7(CfXU2cAqWGuI5RFXC4dq1VxFjwSI5RFXC4dq1V3obsChP8Lyzi21TVfxtSR4XhT3f04AdGeZ3Wve7AlObbdsjMVGyaczHOO(96lXIvmFbXaeYcrr97TtGe3rkFjwgIDD7BX1e7kE8r7DbnbTRxF67TDDAJRJRiMyTYqInEAlmedzHI5RJ69LyqY3gBGKsSF9iXsSy9YGuIDysak67cACTbqIXlUIyxBbniyqkX8fedqilef1VxFjwSI5ligGqwikQFVDcK4os5lXUIl(O9UGgxBaKy6hxrSRTGgemiLy(cIbiKfII63RVelwX8fedqilef1V3obsChP8LyxXJpAVlOX1gajgp3NRi21wqdcgKsmFbXaeYcrr971xIfRy(cIbiKfII63BNajUJu(sSR4XhT3f04AdGeJh9JRi21wqdcgKsmF9lMdFaQ(96lXIvmF9lMdFaQ(92jqI7iLVe7kU4J27cAcAxV(03B760gxhxrmXALHeB80wyigYcfZxFqPlyQh17lXGKVn2ajLy)6rILyX6LbPe7WKau03f04AdGeJlCfXU2cAqWGuI5ligGqwikQFV(sSyfZxqmaHSquu)E7eiXDKYxILHyx3(wCnXUIhF0Exqtq761N(EBxN2464kIjwRmKyJN2cdXqwOy(chBCkFjgK8TXgiPe7xpsSelwVmiLyhMeGI(UGgxBaKy8Wve7AlObbdsjMVGyaczHOO(96lXIvmFbXaeYcrr97TtGe3rkFj2v84J27cAcAxhpTfgKsmFJy5jMfiMB(47cAfwn4ImoQWQBDlglgE4O4Iy((IcJe00TUfJL0cYdNGIXJ(PJyCrxCHhbnbnDRBXUgtcqrpxrqt36wmEtmE32GeRrcNe3rDSNQAWzHtCPc3iJzbIHPj2VInHyZl2tHy4eYcjX4tIH9Kyt0f00TUfJ3e7ARh(aiX8WCXO5iXoPZvZtmlO6MpeJabCOxSyfdskSdjM2geiM0jgK4VWMDbnDRBX4nX4Dztsm91rpZbMiHydiiietleBaIDwp8meBqeJpj21f2hIPgLytigYcfRX6YyCu9xxdceDbnbnDRBX0FiXBxB9WZqqlpXSGVRbPZ6HNrlCqFQP5Uu125xGGwEIzbFxdsN1dpJw4GE8nchPQiU8cP4pau1y9Xae0Ytml47Aq6SE4z0ch0J4ON5atKqNbHZVyo8bO6AyFG5OkbX0Izb3U9lMdFaQEJ1LX4O6VUgeie0Ytml47Aq6SE4z0ch0)bLUGrqlpXSGVRbPZ6HNrlCqVxcBsQkYcRkkdgD0G0z9WZO(0zbQNdp(uqlpXSGVRbPZ6HNrlCq)7MdvtGQQMdPJgKoRhEg1Nolq9C4rNbHdKqG0ZK4osqlpXSGVRbPZ6HNrlCq)ZKQLFf3Lk61zq4aXaeYcrrDVe2SUi1GHQE5heSM)N)pabnbnDRBX4D5aeZ33iJzbcA5jMf8CAoNMcA6wmU6tkXIvmffe0BaKy8zOGHGID21Pw(Gxm(5eIHSqXybCxm88jLylqSiHOO47cA5jMf8TWb9ns4K4oshq6rCEGQEwGAIzb60iDyehCmeK(7MdvtGQQMd1X0UD71iNRgjeffF)zWGttcu)yHE6Xr)e00Ty(wa3fXomjafjgCJmMfi2GigFsmMSbjMgCw4exQWnYywGypfILaLyEyUy0CKyrcrrXlgMwxqlpXSGVfoOVrcNe3r6aspId2tvn4SWjUuHBKXSaDAKomIJgCw4exQWnYywG)xJCUAKquu89Nbdonjq9Jf6PhhUiOPBX4QpPelwXueYaiX4ZqaXIvmSNe7dkDbJyxJ7VylumCSXPi4lOLNywW3ch03iHtI7iDaPhX5dkDbtnyG0ZSoLonshgXHl(SLiDei6ngulStGe3rk9bx0vlr6iq09YpiyDrQptQw(FNajUJu6dUORwI0rGO)mPA5xr2d23jqI7iL(Gl(SLiDei6PlpWjU0jqI7iL(Gl6QfU4t9XvVg5C1iHOO47pdgCAsG6hl0tpo8QDbnDl21yOttXUg3FXYqmKb(HGwEIzbFlCq)jDUAEIzbv38HoG0J4CuVGMUfZ3XaIHG5Cxe75pXHHEXIvSGHeJnO0fmKsmFFJmMfi2v4xetTdaLy)QJytigYcp0lM2UUbGsSbrmWgmdaLyZlw2ihxI7O27cA5jMf8TWb9qmqnpXSGQB(qhq6rC(GsxWqkDgeoFqPlyivpDobnDlM(utZDrmw3CiXsGsmUphsSmeJlTi210FXuyWbGsSGHedzGFigp6sSNolq96iwIeeuSGjdX4vlIDn9xSbrSjeJ8H2aPxm(tWmaXcgsma5JqmUURXDXwOyZlgydXW0e0Ytml4BHd6F3COAcuv1CiDgeoVg5C1iHOO47pdgCAsG6hl07o9ZpYGIjQqYlhWRN(5hhdbP)U5q1eOQQ5qDi5Ld4Vd1r19sF4)SE4BvBhq86XHx82vX4r3XJUAxFWfbnDlM(dNfoXfX89nYywaxFX4Au4RxmutdsSuSdm1elXxSqmcqquxedzHIfmKyFqPlye7AC)f7kCSXPiOyFmoNyq61Oti2eT3fJRxmnDeBcXojqmCsSGjdX(XtZrDbT8eZc(w4G(t6C18eZcQU5dDaPhX5dkDbt9OEDgeons4K4oQJ9uvdolCIlv4gzmlqqt3IDTf8JIGIH9daLyPySbLUGrSRXDX4ZqaXGuEygakXcgsmcqquxelyG0ZSoLGwEIzbFlCq)jDUAEIzbv38HoG0J48bLUGPEuVodchcqqux6kczotChNgjCsCh1)GsxWudgi9mRtjOLNywW3ch0FsNRMNywq1nFOdi9ioidyEgDgeoxrii0jMgu9SE4BvBhq86X5Ov9sFuFncOA)2TRoRh(w12beFxriZzI74WZTBidkMOcjVCa)DC4XpHGqNyAq1Z6HVvTDaXRhN7F7gogcs)V4HVUVUivfLbtnXI9aNOJP5NqqOtmnO6z9W3Q2oG41JdVA)2TREnY5QrcrrX3Fgm40Ka1pwONEC4LFcbHoX0GQN1dFRA7aIxpo8QDbnDlgx9jXsXWXgNIGIXNHaIbP8WmauIfmKyeGGOUiwWaPNzDkbT8eZc(w4G(t6C18eZcQU5dDaPhXbhBCkDgeoeGGOU0veYCM4oons4K4oQ)bLUGPgmq6zwNsqt3IX1w(0hIPbNfoXfXgGyPZj2IiwWqIPp1FUMy40jXEsSje7Kyp9ILIX1DnUlOLNywW3ch0NWtcOASqibcDgeoeGGOU0veYCMqpo84ZwiabrDPdjueqqlpXSGVfoOpHNeqvnm3tcA5jMf8TWb9Ubft81RlmfkpcecA5jMf8TWb94jQ6Iud4CA(cAcA6w3IHoSXPi4lOLNywW3XXgNIZZmn0zq4WTiDei6Gbft8r6AsWobsChP8dXaeYcrr9yaxQX6J5uXDPI8)AKZvJeIIIV)myWPjbQFSqV78PGwEIzbFhhBCQw4G(Nbdonjq9Jf6PZGW51iNRgjeffVEC4I)R42zBqGeeDaDGRBHQB3o76ulFq)jimdsvXxavFTPj19sFupmjef982HjHOOVIaZtmliD6XrxDU4ZB3EnY5QrcrrX3Fgm40Ka1pwONE8QD)4yiiDncISWmivTbnGV)rEAEhhEjOLNywW3XXgNQfoO)jimdsvXxavFTPjPZGW5SRtT8b9NGWmivfFbu91MMu3l9r9WKqu0ZBhMeII(kcmpXSG0DhhD15IpVD7xmh(auDhLQk(Lk5J0tZrDcK4os5NB4yiiDhLQk(Lk5J0tZrDmTB3(fZHpavVj1yaFDxUEi3aq1jqI7iLFUPiCmeKEtQXa(kFygmDmnbT8eZc(oo24uTWb9OC76H7sfjOLNywW3XXgNQfoOhppn)iXf0e00TUf7A76ulFWlOPBX4Qpjg3tWHeBrq4nuhLy4eYcjXcgsmKb(HypdgCAsG6hl0tme46jwRleKQvSZ6rVydOlOLNywW3pQNZZKQLFvLGdPd2t1fbPI6O4WJodchUHJHG0FMuT8RQeCOoMMFCmeK(ZGbNMeOgleKQTJP5hhdbP)myWPjbQXcbPA7qYlhWFhN739PGMUf7kUkWr)lw6GuQUigMMy40jXEsm(KyXUnfJLjvlFX039G9Tlg2tIXEXdFDVylccVH6OedNqwijwWqIHmWpeJLbdonjGySXc9edbUEI16cbPAf7SE0l2a6cA5jMf89J6BHd6)lE4R7RlsvrzWOd2t1fbPI6O4WJodchCmeK(ZGbNMeOgleKQTJP5hhdbP)myWPjbQXcbPA7qYlhWFhN739PGwEIzbF)O(w4GEexIICUmMfOZGWPrcNe3r9hOQNfOMywGFU9bLUGHuDVeeoYpogcs)V4HVUVUivfLbthtZ)z9W3Q2oG41JJpf0Ytml47h13ch03ibZZOZGW5kigGqwikQ7LWM1fPgmu1l)GG18)8)b4)SE4BvBhq8DfHmNjUJdp8wKoceDfrAeS(bmdcf51jqI7i1TBqmaHSquuxrzW4UuFMuT8F)N1dFRA7aI)oEA3pogcs)V4HVUVUivfLbthtZpogcs)zs1YVQsWH6yA(9Ypiyn)p)Favi5Ld45Ol)4yiiDfLbJ7s9zs1Y)7QLpqqt3IP)76edzHI16cbPAftds8g7YDX4pbJySmCxmiLQlIXNHaIb2qmigamauIXQVDbT8eZc((r9TWb9A76Qq6xm4H0bzHva5JGdp6miCI0rGO)myWPjbQXcbPA7eiXDKYp3I0rGO)mPA5xr2d23jqI7iLGMUfJR(KyTUqqQwX0GKySl3fJpdbeJpjgt2GelyiXiabrDrm(muWqqXqGRNyA76gakX4pbZIfIXQVITqXUUW(qmueGGPZDPlOLNywW3pQVfoO)zWGttcuJfcs1QZGWHaee1f94OF6YFJeojUJ6pqvplqnXSa)NDDQLpO)x8Wx3xxKQIYGPJP5)SRtT8b9Njvl)QkbhQFysik61Jdp(VIBqmaHSquuFXj1qGdD7MIWXqq6iUef5CzmlOJPD72Rroxnsikk((ZGbNMeO(Xc90JZv80cV0hxXTiDei6Gbft8r6AsWobsChP8ZTiDei6Qe2S(mPA53jqI7iv7T3U)Z6HVvTDaXFhhU4)kUHJHG01GKhPMiJzbDmTB3EnY5QrcrrX3Fgm40Ka1pwONE8QD)xXTZ2Gaji6niqWCbE7g3o76ulFqhXLOiNlJzbDmT2f0Ytml47h13ch0)eeMbPQ4lGQV20K05C54OAKquu8C4rNbHtJeojUJ6pqvplqnXSa)CtTr)jimdsvXxavFTPjvvB0J50CaO8hjeff9y8OASv1q6XHl84)QZ6HVvTDaX3veYCMqpoxD0QOYbOhxFE1E7(5gogcs)zWGttcuJfcs12X08Ff3WXqq6AqYJutKXSGoM2TBVg5C1iHOO47pdgCAsG6hl0tpE1(TBidkMOcjVCa)DC8P)xJCUAKquu89Nbdonjq9Jf6D39f0Ytml47h13ch0)K2pVodcNgjCsCh1FGQEwGAIzb(pRh(w12beFxriZzc94WJGMUfJR(KySx8Wx3l2ce7SRtT8bIDvIeeumKb(HySaU3Uyyah9Vy8jXsijgQDaOelwX0wnXADHGuTILaLyQvmWgIXKniXyzs1Yxm9DpyFxqlpXSGVFuFlCq)FXdFDFDrQkkdgDgeons4K4oQ)av9Sa1eZc8FvKoceDc0GCR2aqvFMuT8)obsChPUD7SRtT8b9Njvl)QkbhQFysik61JdpT7)kUfPJar)zWGttcuJfcs12jqI7i1TBr6iq0FMuT8Ri7b77eiXDK62TZUo1Yh0Fgm40Ka1yHGuTDi5Ld41JlT7)kUD2geibrVbbcMlWB3o76ulFqhXLOiNlJzbDi5Ld41JhDD72zxNA5d6iUef5CzmlOJP5)SE4BvBhq86XXNTlOPBXUoiILk1lwcjXW00rShmAKybdj2ciX4pbJyULp9HyT2k37IXvFsm(meqm1LbGsmK8dckwWKaXUM(lMIqMZeITqXaBi2hu6cgsjg)jywSqSeCrSRP)DbT8eZc((r9TWb9EjSjPQilSQOmy0XnaQEuC4P7tDoxooQgjeffphE0zq4aZrvPgei6Ps9Dmn)xfjeff9y8OASv1q3Dwp8TQTdi(UIqMZe3UXTpO0fmKQNoN)Z6HVvTDaX3veYCMqpohTQx6J6Rrav7cA6wSRdIyGvSuPEX4poNyQHeJ)emdqSGHedq(ie7(661rmSNeJ3HWDXwGy47)IXFcMflelbxe7A6FxqlpXSGVFuFlCqVxcBsQkYcRkkdgDgeoWCuvQbbIEQuFFa6DFDXBWCuvQbbIEQuFxHbZywG)Z6HVvTDaX3veYCMqpohTQx6J6RraLGwEIzbF)O(w4G(Njvl)kUlv0RZGWPrcNe3r9hOQNfOMywG)Z6HVvTDaX3veYCMqpoCX)v4yii9)Ih(6(6IuvugmDmTB3W3)9JmOyIkK8Yb83XHl6QDbT8eZc((r9TWb90HzhaQkK0GJxcu6miCAKWjXDu)bQ6zbQjMf4)SE4BvBhq8DfHmNj0Jdx8FvJeojUJ6ypv1GZcN4sfUrgZcUD71iNRgjeffF)zWGttcu)yHE3XHx3UbXaeYcrrDi9lgqnau1JlHtCPDbnDl21pbJyS6RoIniIb2qS0bPuDrm1ciDed7jXADHGuTIXFcgXyxUlgMwxqlpXSGVFuFlCq)ZGbNMeOgleKQvNbHtKoce9Njvl)kYEW(obsChP83iHtI7O(du1ZcutmlWpogcs)V4HVUVUivfLbthtZ)z9W3Q2oG4VJdx8Ff3WXqq6AqYJutKXSGoM2TBVg5C1iHOO47pdgCAsG6hl0tpE1UGwEIzbF)O(w4G(Njvl)QkbhsNbHd3WXqq6ptQw(vvcouhtZpYGIjQqYlhWFhN7zlr6iq0Fm8GGiyOOobsChPe0Ytml47h13ch0J4ON5atKqNbHZv)I5WhGQRH9bMJQeetlMfC72Vyo8bO6nwxgJJQ)6AqGOD)eGGOU0veYCMqpo3xx(52hu6cgs1tNZpogcs)V4HVUVUivfLbtxT8b6mGGGqmTOoEEKAYG4WJodiiietlQOClE64WJodiiietlQdcNFXC4dq1BSUmghv)11GaHGwEIzbF)O(w4GETnMfOZGWbhdbPJ72v5W(OdP8e3UHmOyIkK8Yb83DFDD7gogcs)V4HVUVUivfLbthtZ)v4yii9Njvl)kUlv03X0UD7SRtT8b9Njvl)kUlv03HKxoG)oo8OR2f0Ytml47h13ch0J72vvrWGx0zq4GJHG0)lE4R7RlsvrzW0X0e0Ytml47h13ch0JtWNGnhakDgeo4yii9)Ih(6(6IuvugmDmnbT8eZc((r9TWb9idKWD7Q0zq4GJHG0)lE4R7RlsvrzW0X0e0Ytml47h13ch0NGd9bmD1t6C6miCWXqq6)fp8191fPQOmy6yAcA6wmUtijMledjDo880umKfkg2N4osSjiVNRigx9jX4pbJySx8Wx3l2Iig3Pmy6cA5jMf89J6BHd6XEQob596miCWXqq6)fp8191fPQOmy6yA3UHmOyIkK8Yb83XfDjOjOPBDlM(oG5zi4lOPBXUEMXrIH9daLy6pK8i1ezmlqhXYg7Oe7KFmauIX6MdjwcuIX95qIXNHaIXYKQLVyCpbhsS5f73fiwSIHtIH9KshXiFCiTqmKfkgV3lWjbcA5jMf8DKbmpdNgjCsChPdi9ioAqYJu1hOQNfOMywGonshgXjshbIUgK8i1ezmlOtGe3rk)Vg5C1iHOO47pdgCAsG6hl07UR8jVD2geibrhqh46wOQD)C7SniqcIEZlWjbcA5jMf8DKbmptlCq)7MdvtGQQMdPZGWHBns4K4oQRbjpsvFGQEwGAIzb(FnY5QrcrrX3Fgm40Ka1pwO3D6NFUHJHG0FMuT8RQeCOoMMFCmeK(7MdvtGQQMd1HKxoG)oKbftuHKxoG3pKqG0ZK4osqlpXSGVJmG5zAHd6F3COAcuv1CiDgeons4K4oQRbjpsvFGQEwGAIzb(p76ulFq)zs1YVQsWH6hMeII(kcmpXSG0DhpDFJp9JJHG0F3COAcuv1COoK8Yb83D21Pw(G(FXdFDFDrQkkdMoK8Yb8(V6SRtT8b9Njvl)QkbhQdPuDXpogcs)V4HVUVUivfLbthsE5aEEdhdbP)mPA5xvj4qDi5Ld4VJNoxAxqt3IX7HCAeumE)eojUJedzHI57yAbgK6IX2C0etHbhakX4D5heum95)5)dqSfkMcdoauIX9eCiX4pbJyCpHnflbkXaRyTnOyIpsxtc2f0Ytml47idyEMw4G(gjCsChPdi9ioFZrRcX0cmiPtJ0HrC8Ypiyn)p)Favi5Ld41tx3UXTiDei6Gbft8r6AsWobsChP8hPJarxLWM1Njvl)obsChP8JJHG0FMuT8RQeCOoM2TBVg5C1iHOO47pdgCAsG6hl0tpo8sqt3IX7LinXW0eZ3X0cmij2Gi2eInVyj(IfIfRyqmGylw0f0Ytml47idyEMw4GEiMwGbjDgeoxXTgjCsCh1)MJwfIPfyq62TgjCsCh1XEQQbNfoXLkCJmMf0U)iHOOOhJhvJTQgI3GKxoGxp9ZpKqG0ZK4osqlpXSGVJmG5zAHd6F6aPOg0Hbm(2yKGMUfJ3H5IrTrmauIfjeffVybtgIXFCoXCtdsmKfkwWqIPWGzmlqSfrmFhtlWGKoIbjei9mIPWGdaLyAjqrEZPlOLNywW3rgW8mTWb9qmTads6CUCCunsikkEo8OZGWHBns4K4oQ)nhTketlWGKFU1iHtI7Oo2tvn4SWjUuHBKXSa)Vg5C1iHOO47pdgCAsG6hl0tpoCXFKquu0JXJQXwvdPhNR8zlxXf9Xz9W3Q2oG4BVD)qcbsptI7ibnDlMVtiq6zeZ3X0cmijgLq3fXgeXMqm(JZjg5dTbsIPWGdaLySx8Wx33fJ7RybtgIbjei9mIniIXUCxmuu8IbPuDrSbiwWqIbiFeI5ZVlOLNywW3rgW8mTWb9qmTads6miC4wJeojUJ6FZrRcX0cmi5hsE5a(7o76ulFq)V4HVUVUivfLbthsE5a(w4rx(p76ulFq)V4HVUVUivfLbthsE5a(744t)rcrrrpgpQgBvneVbjVCaVENDDQLpO)x8Wx3xxKQIYGPdjVCaFl(uqlpXSGVJmG5zAHd6XD5PzvB5RiOodchU1iHtI7Oo2tvn4SWjUuHBKXSa)Vg5C1iHOO41JZ9f0Ytml47idyEMw4GEQX8hcMbjOjOPBDlgBqPlye7A76ulFWlOPBX49qonckgVFcNe3rcA5jMf89pO0fm1J650iHtI7iDaPhX5zu1GbspZ6u60iDyeNZUo1Yh0FMuT8RQeCO(HjHOOVIaZtmliD6XHNUVXNcA6wmE)empJydIy8jXsij2j10gakXwGyCpbhsSdtcrrFxSR7e6UigoHSqsmKb(HyQeCiXgeX4tIXKniXaRyTnOyIpsxtckgowig3tytXyzs1YxSbi2cveuSyfdffI57yAbgKedttSRaRy8U8dckM(8)8)b0ExqlpXSGV)bLUGPEuFlCqFJempJodcNR4wJeojUJ6pJQgmq6zwN62nUfPJarhmOyIpsxtc2jqI7iL)iDei6Qe2S(mPA53jqI7iv7(pRh(w12beFxriZzc94Xp3GyaczHOOUxcBwxKAWqvV8dcwZ)Z)hGGMUft)31jgYcfJLjvlFpYPeRfXyzs1Y)d40Kedd4O)fJpjwcjXs8flelwXoPMylqmUNGdj2HjHOOVlMVfWDrm(meqm9DakXUEkBcO)fBEXs8flelwXGyaXwSOlOLNywW3)GsxWupQVfoOxBxxfs)IbpKoilSciFeC4rhYhbmRP3Ibco8sx6miCG5H6GbftujhIGwEIzbF)dkDbt9O(w4G(NjvlFpYP0zq4qacI6IEC4LU8tacI6sxriZzc94WJU8ZTgjCsCh1FgvnyG0ZSoL)Z6HVvTDaX3veYCMqpE8RiCmeKoYauv(u2eq)3HKxoG)oEe00Tyxt)flyG0ZSo1lgYcfJabbhakXyzs1YxmUNGdjOLNywW3)GsxWupQVfoOVrcNe3r6aspIZZOQN1dFRA7aIxNgPdJ4Cwp8TQTdi(UIqMZe6XHlTGJHG0FMuT8R4UurFhttqlpXSGV)bLUGPEuFlCqFJeojUJ0bKEeNNrvpRh(w12beVonshgX5SE4BvBhq8DfHmNj0JZ91zq4C2geibrV5f4KabT8eZc((hu6cM6r9TWb9ns4K4oshq6rCEgv9SE4BvBhq860iDyeNZ6HVvTDaX3veYCM4oo8OZGWPrcNe3rDSNQAWzHtCPc3iJzb(FnY5QrcrrX3Fgm40Ka1pwONEC4LGMUfJ7j4qIPWGdaLySx8Wx3l2cflX3gKybdKEM1P6cA5jMf89pO0fm1J6BHd6FMuT8RQeCiDgeons4K4oQ)mQ6z9W3Q2oG49FvJeojUJ6pJQgmq6zwN62nCmeK(FXdFDFDrQkkdMoK8Yb86XHNoxUDdhdbPFyY9R4jG6yA3U9AKZvJeIIIV)myWPjbQFSqp94Wl)NDDQLpO)x8Wx3xxKQIYGPdjVCaVE8OR29FfogcsxJGilmdsvBqd47FKNM3XRB3EnY5QrcrrX3Fgm40Ka1pwONECPDbnDlg6WGaXGKxoGbGsmUNGd9IHtilKelyiXqgumHyeq9IniIXUCxm(lWxHy4KyqkvxeBaIfJh1f0Ytml47FqPlyQh13ch0)mPA5xvj4q6miCAKWjXDu)zu1Z6HVvTDaX7hzqXevi5Ld4V7SRtT8b9)Ih(6(6IuvugmDi5Ld4f0e00TUfJnO0fmKsmFFJmMfiOPBXUoiIXgu6cg03ibZZiwcjXW00rmSNeJLjvl)pGttsSyfdNaeYeIHaxpXcgsmT8)Pbjg(cWEXsGsm9DakXUEkBcO)1rmQbbeBqeJpjwcjXYqmV0hIDn9xSRWao6FXW(bGsmEx(bbftF(F()aAxqlpXSGV)bLUGHuCEMuT8)aonjDgeoxHJHG0)GsxW0X0UDdhdbP3ibZZ0X0A3)vVg5C1iHOO47pdgCAsG6hl07oED7wJeojUJ6ypv1GZcN4sfUrgZcA3Vx(bbR5)5)dOcjVCaphDjOPBX03bmpJyzi29BrSRP)IXFcMfleJ7SIHEX4vlIXFcgX4oRy8NGrmwgm40KaI16cbPAfdhdbrmmnXIvSSXokX(1Je7A6Vy8ZpiX(jWYywW3f00Ty6t3VI9jcjwSIHmG5zeldX4vlIDn9xm(tWig5J8eUlIXlXIeIIIVl2vSPhjw(ITyXpksSpO0fm92f00Ty67aMNrSmeJxTi210FX4pbZIfIXDwDeZNTig)jyeJ7S6iwcuIPFIXFcgX4oRyjsqqX49tW8mcA5jMf89pO0fmKQfoO)KoxnpXSGQB(qhq6rCqgW8m6miCiee6etdQEwp8TQTdiE94C0QEPpQVgbu3UHJHG0Fgm40Ka1yHGuTDmn)N1dFRA7aIVRiK5mXDC4YTBVg5C1iHOO47pdgCAsG6hl0tpo8YpHGqNyAq1Z6HVvTDaXRhhED72z9W3Q2oG47kczotChhE4TRI0rGORisJG1pGzKOiVobsChP8JJHG0BKG5z6yATlOLNywW3)GsxWqQw4G(Njvl)pGttsNbHZhu6cgs1Fs7N3)Rroxnsikk((ZGbNMeO(Xc9UJxcA5jMf89pO0fmKQfoO)zMg6miCI0rGOdgumXhPRjb7eiXDKYpedqilef1JbCPgRpMtf3LkY)Rroxnsikk((ZGbNMeO(Xc9UZNcA6wmUQMyXk29flsikkEXUcSIPbNTDXAsKMyyAIPVdqj21tzta9Vy4xe7C54gakXyzs1Y)d40K6cA5jMf89pO0fmKQfoO)zs1Y)d40K05C54OAKquu8C4rNbHd3AKWjXDuh7PQgCw4exQWnYywGFfHJHG0rgGQYNYMa6)oK8Yb83XJ)xJCUAKquu89Nbdonjq9Jf6DhN77psikk6X4r1yRQH4ni5Ld41t)e00Ty67cftdolCIlIb3iJzb6ig2tIXYKQL)hWPjj22GGIXgl0tm(tWi21Z7elrLd4dXW0elwX4LyrcrrXl2cfBqetFVEXMxmigamauITiiID1celbxel9wmqi2IiwKquu8TlOLNywW3)GsxWqQw4G(Njvl)pGttsNbHtJeojUJ6ypv1GZcN4sfUrgZc8FLIWXqq6idqv5tzta9FhsE5a(7452TiDei68PuBbE5heStGe3rk)Vg5C1iHOO47pdgCAsG6hl07oo8QDbT8eZc((hu6cgs1ch0)myWPjbQFSqpDgeoVg5C1iHOO41JZ9B5kCmeKEWqv4gbb6yA3UbXaeYcrr9SzMW5R)I5QiWeLhbI29Ffogcs)V4HVUVUivfLbtnXI9aNOJPD7g3WXqq6AqYJutKXSGoM2TBVg5C1iHOO41JJpBxqt3IXYKQL)hWPjjwSIbjei9mIPVdqj21tzta9VyjqjwSIrGhdsIXNe7KaXojeErSTbbflfdbZ5etFVEXgqSIfmKyaYhHySl3fBqetB)FWDuxqlpXSGV)bLUGHuTWb9ptQw(FaNMKodchfHJHG0rgGQYNYMa6)oK8Yb83XHNB3o76ulFq)V4HVUVUivfLbthsE5a(745E6xr4yiiDKbOQ8PSjG(VdjVCa)DNDDQLpO)x8Wx3xxKQIYGPdjVCaVGwEIzbF)dkDbdPAHd6r521d3LksNbHdogcsxJGilmdsvBqd47FKNM6XXN(plqHnrxJGilmdsvBqd47We0upo8CFbT8eZc((hu6cgs1ch0)mPA5)bCAscA5jMf89pO0fmKQfoO)WqPw9z2qNbHd3IeIII(8v89F)N1dFRA7aIVRiK5mHEC4Xpogcs)z2OoGAWqvvcB2X08tacI6spgpQgBLx6spuhv3l9rH91OtPnUOF8uIsuka]] )

    
end
