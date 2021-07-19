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


    spec:RegisterPack( "Subtlety", 20210719, [[defBacqiufEevf2Kc8jQKmkvsDkvswfvsLxrvLzrL4wOkXUu0VqLyyuP0XqLAzOs6zQuvtJkfxdvP2Mcv6BqQkJdsvQZrLuQ1PsvAEQu5EOI9rLQ)rLuOdIQKAHqQ8qQk1erv0fvOk1gPQeFesvYiPskQtQqvSsiLxsLuKzcPkUjQsYovO8tQKQAOuvslvHkEkknvQQ6QqQQ2kvsv(QkvXyvOQolvsbTxj(RKgmLdlAXO4XQyYKCzKndXNHKrdLtl1QvOk51kKztQBtv2nWVvA4uXXPskz5GEUQMUW1HQTRG(oQQXtvrNxLy9ujfy(Qu2pXfUl(xyvzqLX4QB5k3Uf9XTR9K77ZBEF)7xyJlouH1jpJsuuHfKEuHLfNj0uCPW6Kx0BQk(xy)fhEOclweo)9YfUGQdmCM5z94Y3E46m6fCGjsWLV9oCPWYG36y8akmfwvguzmU6wUYTBrFC7Ap5((8M3Cf9vyt8aBHfw22Z3fwSwPiqHPWQO)uyzXzcnfxeBCwu4KGgA46lIXn6ZfX4QB5k3cAcA(glbOO)Ef04fX4v7qsSHjStgnnXFQ6a7f2XLkCJm6figUJy)kwhI1VypfIXqilKeJpjg(tI1XuqJxeZ3RhtdiX8W1r7OjXoPwxZt0lOQ7peJabSPxSyfdsk8djMZgei6ulgK4VWrtbnErmEvoIeZx00JDGjsiwdcccXDcXAGyN1JjdXAeX4tInEH)HyQwjwhIHSqXgU6mAnv)vpKaXSWQ7p(I)f2pOuhyKQ4FzmUl(xyjqYOjvbDf28e9ckSpwQw(Fa7ruHvr)b2orVGc74brm2GsDGXLHjOFmXsijgUJlIH)KySyPA5)bShrIfRymeGq6qme46jwGrI5K)3djXywa(lwcuI5lnqj29q5ia9VlIrdjGynIy8jXsijwgI5L(umF7RIDnoqt)lg(3auIXRYpiOy86)Z)BWvf2dSdc2zH9AXyWrqMFqPoWM4oID7Mym4iiZHjOFSjUJyxj2aX8Ypiyn)p)Vbvi5Ln4fJJyUTeLX4AX)clbsgnPkORWQO)aBNOxqH1xAq)yILHyUXpX8TVkg)oWw8qmEY6Iy82pX43bMy8K1fXsGsSXvm(DGjgpzflrcckMRxc6hRWMNOxqH9KADnprVGQU)OWEGDqWolSeccDIEivpRhZwD2geVyUZrSJt1l9z9DiGsSB3eJbhbz(y4WEebQXcbPAN4oInqSZ6XSvNTbXpvesF6qS74igxf72nXEhsRRrcrrXpFmCypIa1pwONyUZrm3i2aXiee6e9qQEwpMT6SniEXCNJyUrSB3e7SEmB1zBq8tfH0Noe7ooIXTy8IyxlwKAcetfroeS(bmJef5njqYOjLydeJbhbzomb9JnXDe7QcRU)OcspQWI0G(XkrzS7x8VWsGKrtQc6kShyheSZc7huQdmsnFY57xSbI9oKwxJeIIIF(y4WEebQFSqpXUtm3uyZt0lOW(yPA5)bShrLOmMBk(xyjqYOjvbDf2dSdc2zHnsnbIjOrHfFK6reCsGKrtkXgigehqilefnJgCPgRp7tLrNkAsGKrtkXgi27qADnsikk(5JHd7reO(Xc9e7oX4DHnprVGc7J1dlrzmEx8VWsGKrtQc6kS5j6fuyFSuT8)a2JOc75Yrt1iHOO4lJXDH9a7GGDwy5HydtyNmAAI)u1b2lSJlv4gz0lqSbIPigCeKjsduv(uocq)pHKx2GxS7eJBXgi27qADnsikk(5JHd7reO(Xc9e7ooIDFXgiwKquumJ2JQXwvnjgVigK8Yg8I5UyJBHvr)b2orVGcl63rSyf7(IfjeffVyxdwXCG9ELyJiYrmChX8LgOe7EOCeG(xmMlIDUC0naLySyPA5)bShrZsugBCl(xyjqYOjvbDf28e9ckSpwQw(Fa7ruHvr)b2orVGcRVSqXCG9c74IyWnYOxGlIH)KySyPA5)bShrITdjOySXc9eJFhyIDp8kXsuzd(qmChXIvm3iwKquu8ITqXAeX8L7rS(fdIdanaLylcIyxVaXsWfXsVfheITiIfjeff)vf2dSdc2zHDyc7Krtt8NQoWEHDCPc3iJEbInqSRftrm4iitKgOQ8PCeG(FcjVSbVy3jg3ID7MyrQjqm5tPZc8Ypi4KajJMuInqS3H06AKquu8Zhdh2Jiq9Jf6j2DCeZnIDvjkJH(k(xyjqYOjvbDf2dSdc2zH9DiTUgjeffVyUZrS7lMFIDTym4iiZaJQWnccmXDe72nXG4aczHOOzokty)1FX1veyIYJaXKajJMuIDLyde7AXyWrqM)fpMv)1fPQOmWQjEShyhtChXUDtmEigdocY0bsEKQJm6fmXDe72nXEhsRRrcrrXlM7CeJ3IDvHnprVGc7JHd7reO(Xc9krzm07I)fwcKmAsvqxHnprVGc7JLQL)hWEevyv0FGTt0lOWYILQL)hWEejwSIbjei9yI5lnqj29q5ia9VyjqjwSIrGhhsIXNe7KaXojeErSDibflfdbxRfZxUhXAqSIfyKyaYNHySlpfRreZz)Vz00SWEGDqWolSkIbhbzI0avLpLJa0)ti5Ln4f7ooIXTy3Uj2zxTA5dM)fpMv)1fPQOmWMqYlBWl2DIXn6Tydetrm4iitKgOQ8PCeG(FcjVSbVy3j2zxTA5dM)fpMv)1fPQOmWMqYlBWxIYyU2f)lSeiz0KQGUc7b2bb7SWYGJGmDiiYcZGu1Hud(5h5zKyUZrmEl2aXolqH3X0HGilmdsvhsn4NWemsm35ig33VWMNOxqHfLExpgDQOsugJB3w8VWMNOxqH9Xs1Y)dypIkSeiz0KQGUsugJBUl(xyjqYOjvbDf2dSdc2zHLhIfjeffZ(Rm7)InqSZ6XSvNTbXpvesF6qm35ig3InqmgCeK5JTrTb1aJQQeoAI7i2aXiabrDzgThvJT6g3kM7IH6OMEPplS5j6fuypyu6uFSnkrjkSkcjX1rX)YyCx8VWMNOxqHDuFgvyjqYOjvbDLOmgxl(xyjqYOjvbDf21PW(uuyZt0lOWomHDYOPc7WuJtfwgCeK5R7dvtGQQ6dnXDe72nXEhsRRrcrrXpFmCypIa1pwONyUZrSXTWQO)aBNOxqHf9)KsSyftrbb9AajgFmkWiOyND1QLp4fJF2HyilumwapfJjFsj2celsikk(zHDycRG0JkSpqvplq1rVGsug7(f)lSeiz0KQGUc76uyFkkS5j6fuyhMWoz0uHDyQXPcRdSxyhxQWnYOxGyde7DiTUgjeff)8XWH9icu)yHEI5ohX4AHvr)b2orVGcRRpqFrSdwcqrIb3iJEbI1iIXNedlhsI5a7f2XLkCJm6fi2tHyjqjMhUoAhnjwKquu8IH7mlSdtyfKEuHf)PQdSxyhxQWnYOxqjkJ5MI)fwcKmAsvqxHDDkSpff28e9ckSdtyNmAQWom14uHLR8wm)elsnbI5Wg1cNeiz0KsmxNyC1TI5NyrQjqm9YpiyDrQpwQw()KajJMuI56eJRUvm)elsnbI5JLQLFfzp4)KajJMuI56eJR8wm)elsnbIzQZdSJltcKmAsjMRtmU6wX8tmUYBXCDIDTyVdP11iHOO4NpgoShrG6hl0tm35iMBe7QcRI(dSDIEbfw0)tkXIvmfH0asm(yeqSyfd)jX(GsDGjMV55l2cfJbV1kc(f2HjScspQW(bL6aRgyq6XwTQeLX4DX)clbsgnPkORWQO)aBNOxqH13y0zKy(MNVyzigsd)OWMNOxqH9KADnprVGQU)OWQ7pQG0JkSh1xIYyJBX)clbsgnPkORWQO)aBNOxqHDCWbIHGR1xe753XbJEXIvSaJeJnOuhyKsSXzJm6fi21mxetTnaLy)6IyDigYcp0lMZU6gGsSgrmWgynaLy9lwomBDYOPRMf28e9ckSqCqnprVGQU)OWEGDqWolSFqPoWi1m16cRU)OcspQW(bL6aJuLOmg6R4FHLajJMuf0vyZt0lOW(6(q1eOQQ(qfwf9hy7e9ckS8Ahh9fXy19HelbkX4zFiXYqmU6Ny(2xftHdBakXcmsmKg(HyC7wXE6Sa17IyjsqqXcSmeZn(jMV9vXAeX6qmYNonKEX43bwdelWiXaKpdXqV8npfBHI1VyGned3PWEGDqWolSVdP11iHOO4NpgoShrG6hl0tS7eBCfBGyinkSOcjVSbVyUl24k2aXyWrqMVUpunbQQQp0esEzdEXUtmuh10l9Pyde7SEmB1zBq8I5ohXCJy8Iyxlw0EKy3jg3UvSReZ1jgxlrzm07I)fwcKmAsvqxHvr)b2orVGcRVc7f2XfXgNnYOxGRrXqpu4Qxmu9qsSuSdmDelzw8qmcqquxedzHIfyKyFqPoWeZ388f7Ag8wRiOyF0ATyq6DOtiwhxnfZ1qChxeRdXojqmgsSaldX(2ZrtZcBEIEbf2tQ118e9cQ6(Jc7b2bb7SWomHDYOPj(tvhyVWoUuHBKrVGcRU)OcspQW(bL6aREuFjkJ5Ax8VWsGKrtQc6kSk6pW2j6fuy99c(wrqXW)gGsSum2GsDGjMV5Py8XiGyqkpynaLybgjgbiiQlIfyq6XwTQWMNOxqH9KADnprVGQU)OWEGDqWolSeGGOUmvesF6qS74i2We2jJMMFqPoWQbgKESvRkS6(Jki9Oc7huQdS6r9LOmg3UT4FHLajJMuf0vypWoiyNf2RfJqqOt0dP6z9y2QZ2G4fZDoIDCQEPpRVdbuIDLy3Uj21IDwpMT6Sni(PIq6thIDhhX4wSB3edPrHfvi5Ln4f7ooIXTydeJqqOt0dP6z9y2QZ2G4fZDoIDFXUDtmgCeK5FXJz1FDrQkkdSAIh7b2Xe3rSbIrii0j6Hu9SEmB1zBq8I5ohXCJyxj2TBIDTyVdP11iHOO4NpgoShrG6hl0tm35iMBeBGyeccDIEivpRhZwD2geVyUZrm3i2vf28e9ckSNuRR5j6fu19hfwD)rfKEuHfPb9JvIYyCZDX)clbsgnPkORWQO)aBNOxqHf9)KyPym4TwrqX4JraXGuEWAakXcmsmcqquxelWG0JTAvHnprVGc7j16AEIEbvD)rH9a7GGDwyjabrDzQiK(0Hy3XrSHjStgnn)GsDGvdmi9yRwvy19hvq6rfwg8wRkrzmU5AX)clbsgnPkORWMNOxqHnHNeq1yHqcefwf9hy7e9ckSONLp9HyoWEHDCrSgiwQ1ITiIfyKy8AFf9igdDs8NeRdXoj(tVyPyOx(MNf2dSdc2zHLaee1LPIq6thI5ohX4M3I5NyeGGOUmHekcuIYyCF)I)f28e9ckSj8KaQ6GRFQWsGKrtQc6krzmUDtX)cBEIEbfwDJcl(64fUcLhbIclbsgnPkOReLX4M3f)lS5j6fuyzsu1fPgW(m6lSeiz0KQGUsuIcRdKoRhtgf)lJXDX)cBEIEbf20XrFP6S9VGclbsgnPkOReLX4AX)cBEIEbfwMncnPQi68cP43au1y9zdkSeiz0KQGUsug7(f)lSeiz0KQGUc7b2bb7SW(lUMPbQPd(h4AQsqCNOxWKajJMuID7My)IRzAGAoC1z0AQ(REibIjbsgnPkS5j6fuyr00JDGjsuIYyUP4FHnprVGc7huQdSclbsgnPkOReLX4DX)clbsgnPkORWMNOxqH1lHJivfzHvfLbwH1bsN1JjJ6tNfO(cl38UeLXg3I)fwcKmAsvqxHnprVGc7R7dvtGQQ6dvypWoiyNfwiHaPhlz0uH1bsN1JjJ6tNfO(cl3LOmg6R4FHLajJMuf0vypWoiyNfwioGqwikA6LWr1fPgyu1l)GG18)8)gmjqYOjvHnprVGc7JLQLFLrNk6lrjkSinOFSI)LX4U4FHLajJMuf0vyxNc7trHnprVGc7We2jJMkSdtnovyJutGy6ajps1rg9cMeiz0KsSbI9oKwxJeIIIF(y4WEebQFSqpXUtSRfJ3IXlID2HeibXeqh4QxOsSReBGy8qSZoKajiMJUa7euyv0FGTt0lOWEpyTMed)BakX8vi5rQoYOxGlILd3wj2j)ObOeJv3hsSeOeJN9HeJpgbeJflvlFX4zcoKy9l2VlqSyfJHed)jLlIr(8qoHyilumxtxGDckSdtyfKEuH1bsEKQ(av9Savh9ckrzmUw8VWsGKrtQc6kShyheSZclpeByc7Krtthi5rQ6du1ZcuD0lqSbI9oKwxJeIIIF(y4WEebQFSqpXUtSXvSbIXdXyWrqMpwQw(vvco0e3rSbIXGJGmFDFOAcuvvFOjK8Yg8IDNyinkSOcjVSbVydedsiq6XsgnvyZt0lOW(6(q1eOQQ(qLOm29l(xyjqYOjvbDf2dSdc2zHDyc7Krtthi5rQ6du1ZcuD0lqSbID2vRw(G5JLQLFvLGdnpyjef9veyEIEbPwS7eJ7j6J3InqmgCeK5R7dvtGQQ6dnHKx2GxS7e7SRwT8bZ)IhZQ)6Iuvugyti5Ln4fBGyxl2zxTA5dMpwQw(vvco0esP6IydeJbhbz(x8yw9xxKQIYaBcjVSbVy8Iym4iiZhlvl)QkbhAcjVSbVy3jg3tUk2vf28e9ckSVUpunbQQQpujkJ5MI)fwcKmAsvqxHDDkSpff28e9ckSdtyNmAQWom14uH1l)GG18)8)guHKx2Gxm3fZTID7My8qSi1eiMGgfw8rQhrWjbsgnPeBGyrQjqmvjCu9Xs1YFsGKrtkXgigdocY8Xs1YVQsWHM4oID7MyVdP11iHOO4NpgoShrG6hl0tm35i21IXBX4fXG4aczHOOjsdsDhxMeiz0KsSRkSk6pW2j6fuyDntAhckMRxc7KrtIHSqXghCNahstXyh1oIPWHnaLy8Q8dckgV()8)gi2cftHdBakX4zcoKy87atmEMWrILaLyGvSXAuyXhPEebNf2HjScspQW(JANke3jWHujkJX7I)fwcKmAsvqxHnprVGcle3jWHuHvr)b2orVGcRRjICed3rSXb3jWHKynIyDiw)ILmlEiwSIbXbIT4XSWEGDqWolSxlgpeByc7KrtZFu7uH4oboKe72nXgMWoz00e)PQdSxyhxQWnYOxGyxj2aXIeIIIz0Eun2QQjX4fXGKx2Gxm3fBCfBGyqcbspwYOPsugBCl(xyZt0lOW(0bsrnOdgODTWPclbsgnPkOReLXqFf)lSeiz0KQGUcBEIEbfwiUtGdPc75Yrt1iHOO4lJXDH9a7GGDwy5HydtyNmAA(JANke3jWHKydeJhInmHDYOPj(tvhyVWoUuHBKrVaXgi27qADnsikk(5JHd7reO(Xc9eZDoIXvXgiwKquumJ2JQXwvnjM7Ce7AX4Ty(j21IXvXCDIDwpMT6SniEXUsSReBGyqcbspwYOPcRI(dSDIEbfwEfUoA1grdqjwKquu8Ifyzig)wRft3djXqwOybgjMchMrVaXweXghCNahsUigKqG0JjMch2auI5Kaf51NzjkJHEx8VWsGKrtQc6kS5j6fuyH4oboKkSk6pW2j6fuyhhcbspMyJdUtGdjXOeQViwJiwhIXV1AXiF60qsmfoSbOeJ9IhZQ)Py8CflWYqmiHaPhtSgrm2LNIHIIxmiLQlI1aXcmsma5ZqmE)Zc7b2bb7SWYdXgMWoz008h1oviUtGdjXgigK8Yg8IDNyND1QLpy(x8yw9xxKQIYaBcjVSbVy(jg3UvSbID2vRw(G5FXJz1FDrQkkdSjK8Yg8IDhhX4TydelsikkMr7r1yRQMeJxedsEzdEXCxSZUA1Yhm)lEmR(RlsvrzGnHKx2Gxm)eJ3LOmMRDX)clbsgnPkORWEGDqWolS8qSHjStgnnXFQ6a7f2XLkCJm6fi2aXEhsRRrcrrXlM7Ce7(f28e9ckSm68mQ6S8veSeLX42Tf)lS5j6fuyPH9FiyguHLajJMuf0vIsuypQV4FzmUl(xyjqYOjvbDf2dSdc2zHLhIXGJGmFSuT8RQeCOjUJydeJbhbz(y4WEebQXcbPAN4oInqmgCeK5JHd7reOgleKQDcjVSbVy3XrS7p5DHf)P6IGurDuLX4UWMNOxqH9Xs1YVQsWHkSk6pW2j6fuyr)pjgptWHeBrq4fuhLymeYcjXcmsmKg(HypgoShrG6hl0tme46jM)leKQvSZ6rVynywIYyCT4FHLajJMuf0vypWoiyNfwgCeK5JHd7reOgleKQDI7i2aXyWrqMpgoShrGASqqQ2jK8Yg8IDhhXU)K3fw8NQlcsf1rvgJ7cBEIEbf2)IhZQ)6Iuvugyfwf9hy7e9ckSxJ(bA6FXsnKs1fXWDeJHoj(tIXNel2DKySyPA5lMVSh8)kXWFsm2lEmR(fBrq4fuhLymeYcjXcmsmKg(HySy4WEebeJnwONyiW1tm)xiivRyN1JEXAWSeLXUFX)clbsgnPkORWEGDqWolSdtyNmAA(av9Savh9ceBGy8qSpOuhyKA6LGqtInqmgCeK5FXJz1FDrQkkdSjUJyde7SEmB1zBq8I5ohX4DHnprVGclIorrADg9ckrzm3u8VWsGKrtQc6kShyheSZc71IbXbeYcrrtVeoQUi1aJQE5heSM)N)3GjbsgnPeBGyN1JzRoBdIFQiK(0Hy3XrmUfJxelsnbIPIihcw)aMbHI8Meiz0KsSB3edIdiKfIIMkkdm9L6JLQL)pjqYOjLyde7SEmB1zBq8IDNyCl2vInqmgCeK5FXJz1FDrQkkdSjUJydeJbhbz(yPA5xvj4qtChXgiMx(bbR5)5)nOcjVSbVyCeZTInqmgCeKPIYatFP(yPA5)t1YhuyZt0lOWomb9JvIYy8U4FHLajJMuf0vyv0FGTt0lOW6R7QfdzHI5)cbPAfZbs8c7YtX43bMySy8umiLQlIXhJaIb2qmioa0auIX6lZclYcRaYNrzmUlShyheSZcBKAceZhdh2Jiqnwiiv7KajJMuInqmEiwKAceZhlvl)kYEW)jbsgnPkS5j6fuyD2vxH0V4WdvIYyJBX)clbsgnPkORWMNOxqH9XWH9icuJfcs1wyv0FGTt0lOWI(Fsm)xiivRyoqsm2LNIXhJaIXNedlhsIfyKyeGGOUigFmkWiOyiW1tmND1naLy87aBXdXy9fXwOyJx4FigkcqWuRVmlShyheSZclbiiQlI5ohXgx3k2aXgMWoz008bQ6zbQo6fi2aXo7QvlFW8V4XS6VUivfLb2e3rSbID2vRw(G5JLQLFvLGdnpyjef9I5ohX4wSbIDTy8qmioGqwikAUmKQjWHMeiz0KsSB3etrm4iiteDII06m6fmXDe72nXEhsRRrcrrXpFmCypIa1pwONyUZrSRfJBX8tm3iMRtSRfJhIfPMaXe0OWIps9icojqYOjLydeJhIfPMaXuLWr1hlvl)jbsgnPe7kXUsSReBGyN1JzRoBdIxS74igxfBGyxlgpeJbhbz6ajps1rg9cM4oID7MyVdP11iHOO4NpgoShrG6hl0tm3fZnIDvjkJH(k(xyjqYOjvbDf28e9ckSpbHzqQkZcO670JOc7b2bb7SWomHDYOP5du1ZcuD0lqSbIXdXuBmFccZGuvMfq13Phrv1gZOpJAakXgiwKquumJ2JQXwvnjM7CeJRCl2aXUwSZ6XSvNTbXpvesF6qm35i21IDCQOYgiM7UgfZnIDLyxj2aX4Hym4iiZhdh2Jiqnwiiv7e3rSbIDTy8qmgCeKPdK8ivhz0lyI7i2TBI9oKwxJeIIIF(y4WEebQFSqpXCxm3i2vID7MyinkSOcjVSbVy3XrmEl2aXEhsRRrcrrXpFmCypIa1pwONy3j29lSNlhnvJeIIIVmg3LOmg6DX)clbsgnPkORWEGDqWolSdtyNmAA(av9Savh9ceBGyN1JzRoBdIFQiK(0HyUZrmUlS5j6fuyFY57VeLXCTl(xyjqYOjvbDf28e9ckS)fpMv)1fPQOmWkSk6pW2j6fuyr)pjg7fpMv)ITaXo7QvlFGyxNibbfdPHFiglGNxjgoqt)lgFsSesIHABakXIvmN1rm)xiivRyjqjMAfdSHyy5qsmwSuT8fZx2d(plShyheSZc7We2jJMMpqvplq1rVaXgi21IfPMaXKadj960au1hlvl)FsGKrtkXUDtSZUA1YhmFSuT8RQeCO5blHOOxm35ig3IDLyde7AX4HyrQjqmFmCypIa1yHGuTtcKmAsj2TBIfPMaX8Xs1YVISh8FsGKrtkXUDtSZUA1YhmFmCypIa1yHGuTti5Ln4fZDX4Qyxj2aXUwmEi2zhsGeeZHeiWUaf72nXo7QvlFWerNOiToJEbti5Ln4fZDX42TID7MyND1QLpyIOtuKwNrVGjUJyde7SEmB1zBq8I5ohX4TyxvIYyC72I)fwcKmAsvqxHnprVGcRxchrQkYcRkkdScRUbu9OkSCp5DH9C5OPAKquu8LX4UWEGDqWolSWSvvAibIzQu)e3rSbIDTyrcrrXmApQgBv1Ky3j2z9y2QZ2G4NkcPpDi2TBIXdX(GsDGrQzQ1InqSZ6XSvNTbXpvesF6qm35i2XP6L(S(oeqj2vfwf9hy7e9ckSJheXsL6flHKy4oUi2dAhsSaJeBbKy87atm9YN(qm)9NNtXq)pjgFmciM6sdqjgs(bbflWsGy(2xftri9PdXwOyGne7dk1bgPeJFhylEiwcUiMV91zjkJXn3f)lSeiz0KQGUcBEIEbfwVeoIuvKfwvugyfwf9hy7e9ckSJheXaRyPs9IXV1AXunjg)oWAGybgjgG8zi29D77Iy4pjgVcHNITaXy2)fJFhylEiwcUiMV91zH9a7GGDwyHzRQ0qceZuP(zdeZDXUVBfJxedMTQsdjqmtL6NkCyg9ceBGyN1JzRoBdIFQiK(0HyUZrSJt1l9z9DiGQeLX4MRf)lSeiz0KQGUc7b2bb7SWomHDYOP5du1ZcuD0lqSbIDwpMT6Sni(PIq6thI5ohX4Qyde7AXo7QvlFW8V4XS6VUivfLb2esEzdEXUtmUf72nXyWrqM)fpMv)1fPQOmWM4oID7MyinkSOcjVSbVy3XrmU6wXUQWMNOxqH9Xs1YVYOtf9LOmg33V4FHLajJMuf0vypWoiyNf2HjStgnnFGQEwGQJEbInqSZ6XSvNTbXpvesF6qm35igxfBGyxl2We2jJMM4pvDG9c74sfUrg9ce72nXEhsRRrcrrXpFmCypIa1pwONy3Xrm3i2TBIbXbeYcrrti9loq1au1JoHDCzsGKrtkXUQWMNOxqHLoyBdqvHKdS9sGQeLX42nf)lSeiz0KQGUcBEIEbf2hdh2JiqnwiivBHvr)b2orVGc790bMyS(IlI1iIb2qSudPuDrm1cixed)jX8FHGuTIXVdmXyxEkgUZSWEGDqWolSrQjqmFSuT8Ri7b)Neiz0KsSbInmHDYOP5du1ZcuD0lqSbIXGJGm)lEmR(RlsvrzGnXDeBGyN1JzRoBdIxS74igxfBGyxlgpeJbhbz6ajps1rg9cM4oID7MyVdP11iHOO4NpgoShrG6hl0tm3fZnIDvjkJXnVl(xyjqYOjvbDf2dSdc2zHLhIXGJGmFSuT8RQeCOjUJydedPrHfvi5Ln4f7ooIHElMFIfPMaX8XzccIGJIMeiz0KQWMNOxqH9Xs1YVQsWHkrzmUh3I)fwcKmAsvqxH9a7GGDwyVwSFX1mnqnDW)axtvcI7e9cMeiz0KsSB3e7xCntduZHRoJwt1F1djqmjqYOjLyxj2aXiabrDzQiK(0HyUZrS77wXgigpe7dk1bgPMPwl2aXyWrqM)fpMv)1fPQOmWMQLpOW2GGGqCNO2if2FX1mnqnhU6mAnv)vpKarHTbbbH4orT98ivNbvy5UWMNOxqHfrtp2bMirHTbbbH4orfLEzsDHL7sugJB0xX)clbsgnPkORWEGDqWolSm4iitg9Ukn(htiLNqSB3edPrHfvi5Ln4f7oXUVBf72nXyWrqM)fpMv)1fPQOmWM4oInqSRfJbhbz(yPA5xz0PI(jUJy3Uj2zxTA5dMpwQw(vgDQOFcjVSbVy3XrmUDRyxvyZt0lOW6SrVGsugJB07I)fwcKmAsvqxH9a7GGDwyzWrqM)fpMv)1fPQOmWM4of28e9ckSm6DvveC4LsugJBx7I)fwcKmAsvqxH9a7GGDwyzWrqM)fpMv)1fPQOmWM4of28e9ckSme8j4OgGQeLX4QBl(xyjqYOjvbDf2dSdc2zHLbhbz(x8yw9xxKQIYaBI7uyZt0lOWI0qIrVRQeLX4k3f)lSeiz0KQGUc7b2bb7SWYGJGm)lEmR(RlsvrzGnXDkS5j6fuytWH(aM66j16sugJRCT4FHLajJMuf0vyZt0lOWI)uTdY7lSk6pW2j6fuy5jHK46qmKuRzYZiXqwOy4FYOjX6G8(7vm0)tIXVdmXyV4XS6xSfrmEszGnlShyheSZcldocY8V4XS6VUivfLb2e3rSB3edPrHfvi5Ln4f7oX4QBlrjkSFqPoWQh1x8Vmg3f)lSeiz0KQGUc76uyFkkS5j6fuyhMWoz0uHDyQXPc7zxTA5dMpwQw(vvco08GLqu0xrG5j6fKAXCNJyCprF8UWQO)aBNOxqH11mPDiOyUEjStgnvyhMWki9Oc7JPQbgKESvRkrzmUw8VWsGKrtQc6kS5j6fuyhMG(XkSk6pW2j6fuyD9sq)yI1iIXNelHKyN0XPbOeBbIXZeCiXoyjef9tXgVtO(IymeYcjXqA4hIPsWHeRreJpjgwoKedSInwJcl(i1JiOym4Hy8mHJeJflvlFXAGylurqXIvmuui24G7e4qsmChXUgSIXRYpiOy86)Z)BWvZc7b2bb7SWETy8qSHjStgnnFmvnWG0JTALy3UjgpelsnbIjOrHfFK6reCsGKrtkXgiwKAcetvchvFSuT8Neiz0KsSReBGyN1JzRoBdIFQiK(0HyUlg3InqmEigehqilefn9s4O6IudmQ6LFqWA(F(FdMeiz0KQeLXUFX)clbsgnPkORWQO)aBNOxqH1x3vlgYcfJflvlFpsReZpXyXs1Y)dypIedhOP)fJpjwcjXsMfpelwXoPJylqmEMGdj2blHOOFkMRpqFrm(yeqmFPbkXUhkhbO)fRFXsMfpelwXG4aXw8ywyrwyfq(mkJXDH9a7GGDwyH5HMGgfwujnsHL8zaZA6T4GOW6g3wyZt0lOW6SRUcPFXHhQeLXCtX)clbsgnPkORWEGDqWolSeGGOUiM7CeZnUvSbIracI6Yuri9PdXCNJyC7wXgigpeByc7KrtZhtvdmi9yRwj2aXoRhZwD2ge)uri9PdXCxmUfBGykIbhbzI0avLpLJa0)ti5Ln4f7oX4UWMNOxqH9Xs1Y3J0QsugJ3f)lSeiz0KQGUc76uyFkkS5j6fuyhMWoz0uHDyQXPc7z9y2QZ2G4NkcPpDiM7CeJRI5Nym4iiZhlvl)kJov0pXDkSk6pW2j6fuy9TVkwGbPhB1QxmKfkgbcc2auIXILQLVy8mbhQWomHvq6rf2htvpRhZwD2geFjkJnUf)lSeiz0KQGUc76uyFkkS5j6fuyhMWoz0uHDyQXPc7z9y2QZ2G4NkcPpDiM7Ce7(f2dSdc2zH9SdjqcI5OlWobf2HjScspQW(yQ6z9y2QZ2G4lrzm0xX)clbsgnPkORWUof2NIcBEIEbf2HjStgnvyhMACQWEwpMT6Sni(PIq6thIDhhX4UWEGDqWolSdtyNmAAI)u1b2lSJlv4gz0lqSbI9oKwxJeIIIF(y4WEebQFSqpXCNJyUPWomHvq6rf2htvpRhZwD2geFjkJHEx8VWsGKrtQc6kS5j6fuyFSuT8RQeCOcRI(dSDIEbfwEMGdjMch2auIXEXJz1VyluSKzhsIfyq6XwTAwypWoiyNf2HjStgnnFmv9SEmB1zBq8InqSRfByc7KrtZhtvdmi9yRwj2TBIXGJGm)lEmR(RlsvrzGnHKx2Gxm35ig3tUk2TBI9oKwxJeIIIF(y4WEebQFSqpXCNJyUrSbID2vRw(G5FXJz1FDrQkkdSjK8Yg8I5UyC7wXUQeLXCTl(xyjqYOjvbDf28e9ckSpwQw(vvcouHvr)b2orVGcl6WHaXGKx2GgGsmEMGd9IXqilKelWiXqAuyHyeq9I1iIXU8um(lWvHymKyqkvxeRbIfThnlShyheSZc7We2jJMMpMQEwpMT6SniEXgigsJclQqYlBWl2DID2vRw(G5FXJz1FDrQkkdSjK8Yg8LOefwg8wRk(xgJ7I)fwcKmAsvqxH9a7GGDwy5HyrQjqmbnkS4JupIGtcKmAsj2aXG4aczHOOz0Gl1y9zFQm6urtcKmAsj2aXEhsRRrcrrXpFmCypIa1pwONy3jgVlS5j6fuyFSEyjkJX1I)fwcKmAsvqxH9a7GGDwyFhsRRrcrrXlM7CeJRInqSRfJhID2HeibXeqh4QxOsSB3e7SRwT8bZNGWmivLzbu9D6r00l9z9GLqu0lgVi2blHOOVIaZt0li1I5ohXC7KR8wSB3e7DiTUgjeff)8XWH9icu)yHEI5UyUrSRkS5j6fuyFmCypIa1pwOxjkJD)I)fwcKmAsvqxH9a7GGDwyp7QvlFW8jimdsvzwavFNEen9sFwpyjef9IXlIDWsik6RiW8e9csTy3Xrm3o5kVf72nX(fxZ0a1utPQYCPs(m9C00KajJMuInqmEigdocYutPQYCPs(m9C00e3rSB3e7xCntduZr0Wg81DDnG0na1KajJMuInqmEiMIyWrqMJOHn4R8HzGnXDkS5j6fuyFccZGuvMfq13PhrLOmMBk(xyZt0lOWIsVRhJovuHLajJMuf0vIYy8U4FHnprVGcltEg9rYuyjqYOjvbDLOeLOWoKGFVGYyC1TCLB3I(4((fw(je0auFH9E41JZyJNXqVUxXeZFmsS2ZzHHyilumx9bL6aJuUsmi5AH3qsj2VEKyjESEzqkXoyjaf9tbn0tdiXCZ9kMVxWqcgKsmxbXbeYcrrZX3vIfRyUcIdiKfIIMJ)KajJMuUsSR52Nxnf0qpnGed9DVI57fmKGbPeZvqCaHSqu0C8DLyXkMRG4aczHOO54pjqYOjLRe7AU95vtbnbT7HxpoJnEgd96Eftm)XiXApNfgIHSqXCLdKoRhtgUsmi5AH3qsj2VEKyjESEzqkXoyjaf9tbn0tdiXU)9kMVxWqcgKsmx9lUMPbQ547kXIvmx9lUMPbQ54pjqYOjLRe7AU95vtbn0tdiXU)9kMVxWqcgKsmx9lUMPbQ547kXIvmx9lUMPbQ54pjqYOjLReldXgVD9rpIDn3(8QPGg6PbKyOV7vmFVGHemiLyUcIdiKfIIMJVRelwXCfehqilefnh)jbsgnPCLyzi24TRp6rSR52Nxnf0e0UhE94m24zm0R7vmX8hJeR9CwyigYcfZvinOFmxjgKCTWBiPe7xpsSepwVmiLyhSeGI(PGg6PbKyU5EfZ3lyibdsjMRG4aczHOO547kXIvmxbXbeYcrrZXFsGKrtkxj21C7ZRMcAcA3dVECgB8mg619kMy(JrI1EolmedzHI5QJ6DLyqY1cVHKsSF9iXs8y9YGuIDWsak6NcAONgqI5M7vmFVGHemiLyUcIdiKfIIMJVRelwXCfehqilefnh)jbsgnPCLyxZvFE1uqd90asSX9EfZ3lyibdsjMRG4aczHOO547kXIvmxbXbeYcrrZXFsGKrtkxj21C7ZRMcAONgqIX99VxX89cgsWGuI5kioGqwikAo(UsSyfZvqCaHSqu0C8Neiz0KYvIDn3(8QPGg6PbKyCpU3Ry(EbdjyqkXC1V4AMgOMJVRelwXC1V4AMgOMJ)KajJMuUsSR5QpVAkOjODp86XzSXZyOx3RyI5pgjw75SWqmKfkMR(GsDGvpQ3vIbjxl8gskX(1JelXJ1ldsj2blbOOFkOHEAajgxVxX89cgsWGuI5kioGqwikAo(UsSyfZvqCaHSqu0C8Neiz0KYvILHyJ3U(OhXUMBFE1uqtq7E41JZyJNXqVUxXeZFmsS2ZzHHyilumxXG3ALRedsUw4nKuI9RhjwIhRxgKsSdwcqr)uqd90asmUVxX89cgsWGuI5kioGqwikAo(UsSyfZvqCaHSqu0C8Neiz0KYvIDn3(8QPGMG24XZzHbPed9jwEIEbIP7p(PGwH1bUiTMkS(WhIXIZeAkUi24SOWjbnF4dXqdxFrmUrFUigxDlx5wqtqZh(qmFJLau0FVcA(WhIXlIXR2HKydtyNmAAI)u1b2lSJlv4gz0lqmChX(vSoeRFXEkeJHqwijgFsm8NeRJPGMp8Hy8Iy(E9yAajMhUoAhnj2j16AEIEbvD)HyeiGn9IfRyqsHFiXC2GarNAXGe)foAkO5dFigVigVkhrI5lA6XoWejeRbbbH4oHynqSZ6XKHynIy8jXgVW)qmvReRdXqwOydxDgTMQ)QhsGykOjO5dFiMVcjEX3RhtgcA5j6f8thiDwpMm8Jdxshh9LQZ2)ce0Yt0l4Noq6SEmz4hhUWSrOjvfrNxif)gGQgRpBGGwEIEb)0bsN1Jjd)4Wfen9yhyIeU0iC(fxZ0a10b)dCnvjiUt0l42TFX1mnqnhU6mAnv)vpKaHGwEIEb)0bsN1Jjd)4WLpOuhycA5j6f8thiDwpMm8Jdx8s4isvrwyvrzG5IdKoRhtg1Nolq9C4M3cA5j6f8thiDwpMm8JdxEDFOAcuvvFixCG0z9yYO(0zbQNd3U0iCGecKESKrtcA5j6f8thiDwpMm8JdxESuT8Rm6urVlnchioGqwikA6LWr1fPgyu1l)GG18)8)giOjO5dFigVkBGyJZgz0lqqlprVGNZO(msqZhIH(FsjwSIPOGGEnGeJpgfyeuSZUA1Yh8IXp7qmKfkglGNIXKpPeBbIfjeff)uqlprVG3poCzyc7KrtUaspIZdu1ZcuD0lWLHPgN4WGJGmFDFOAcuvvFOjUZTBVdP11iHOO4NpgoShrG6hl0ZDoJRGMpeZ1hOVi2blbOiXGBKrVaXAeX4tIHLdjXCG9c74sfUrg9ce7PqSeOeZdxhTJMelsikkEXWDMcA5j6f8(XHldtyNmAYfq6rCWFQ6a7f2XLkCJm6f4YWuJtCCG9c74sfUrg9cg8oKwxJeIIIF(y4WEebQFSqp35WvbnFig6)jLyXkMIqAajgFmciwSIH)KyFqPoWeZ388fBHIXG3AfbFbT8e9cE)4WLHjStgn5ci9ioFqPoWQbgKESvRCzyQXjoCL3(fPMaXCyJAHtcKmAs564QB9lsnbIPx(bbRls9Xs1Y)Neiz0KY1Xv36xKAceZhlvl)kYEW)jbsgnPCDCL3(fPMaXm15b2XLjbsgnPCDC1T(XvE76U(DiTUgjeff)8XWH9icu)yHEUZXnxjO5dX8ngDgjMV55lwgIH0Wpe0Yt0l49JdxoPwxZt0lOQ7pCbKEeNJ6f08HyJdoqmeCT(Iyp)ooy0lwSIfyKySbL6aJuInoBKrVaXUM5IyQTbOe7xxeRdXqw4HEXC2v3auI1iIb2aRbOeRFXYHzRtgnD1uqlprVG3poCbIdQ5j6fu19hUaspIZhuQdms5sJW5dk1bgPMPwlO5dX41oo6lIXQ7djwcuIXZ(qILHyC1pX8TVkMch2auIfyKyin8dX42TI90zbQ3fXsKGGIfyziMB8tmF7RI1iI1HyKpDAi9IXVdSgiwGrIbiFgIHE5BEk2cfRFXaBigUJGwEIEbVFC4YR7dvtGQQ6d5sJW5DiTUgjeff)8XWH9icu)yHE3nUdqAuyrfsEzdE3h3bm4iiZx3hQMavv1hAcjVSb)DOoQPx6ZbN1JzRoBdI3DoUHxUoAp6oUD7vUoUkO5dX8vyVWoUi24Srg9cCnkg6Hcx9IHQhsILIDGPJyjZIhIracI6IyiluSaJe7dk1bMy(MNVyxZG3Afbf7JwRfdsVdDcX64QPyUgI74IyDi2jbIXqIfyzi23EoAAkOLNOxW7hhUCsTUMNOxqv3F4ci9ioFqPoWQh17sJWzyc7Krtt8NQoWEHDCPc3iJEbcA(qmFVGVveum8VbOelfJnOuhyI5BEkgFmcigKYdwdqjwGrIracI6IybgKESvRe0Yt0l49JdxoPwxZt0lOQ7pCbKEeNpOuhy1J6DPr4qacI6Yuri9PJ74mmHDYOP5huQdSAGbPhB1kbT8e9cE)4WLtQ118e9cQ6(dxaPhXbPb9J5sJW5AcbHorpKQN1JzRoBdI3DohNQx6Z67qa1v3UD9z9y2QZ2G4NkcPpDChhUVDdPrHfvi5Ln4VJd3diee6e9qQEwpMT6SniE35C)B3yWrqM)fpMv)1fPQOmWQjEShyhtCNbeccDIEivpRhZwD2geV7CCZv3UD97qADnsikk(5JHd7reO(Xc9CNJBgqii0j6Hu9SEmB1zBq8UZXnxjO5dXq)pjwkgdERveum(yeqmiLhSgGsSaJeJaee1fXcmi9yRwjOLNOxW7hhUCsTUMNOxqv3F4ci9iom4Tw5sJWHaee1LPIq6th3Xzyc7KrtZpOuhy1adsp2QvcA(qm0ZYN(qmhyVWoUiwdel1AXweXcmsmETVIEeJHoj(tI1HyNe)PxSum0lFZtbT8e9cE)4WLeEsavJfcjq4sJWHaee1LPIq6thUZHBE7hbiiQltiHIacA5j6f8(XHlj8KaQ6GRFsqlprVG3poCr3OWIVoEHRq5rGqqlprVG3poCHjrvxKAa7ZOxqtqZh(qm0H3AfbFbT8e9c(jdERvCESEOlnchEePMaXe0OWIps9icojqYOj1aioGqwikAgn4snwF2NkJov0G3H06AKquu8Zhdh2Jiq9Jf6DhVf0Yt0l4Nm4Tw5hhU8y4WEebQFSqpxAeoVdP11iHOO4DNdxhCnpo7qcKGycOdC1luD72zxTA5dMpbHzqQkZcO670JOPx6Z6blHOONxoyjef9veyEIEbP2DoUDYvEF727qADnsikk(5JHd7reO(Xc9C3nxjOLNOxWpzWBTYpoC5jimdsvzwavFNEe5sJW5SRwT8bZNGWmivLzbu9D6r00l9z9GLqu0ZlhSeII(kcmprVGuFhh3o5kVVD7xCntdutnLQkZLk5Z0ZrttcKmAsnGhm4iitnLQkZLk5Z0ZrttCNB3(fxZ0a1CenSbFDxxdiDdqnjqYOj1aEOigCeK5iAyd(kFygytChbT8e9c(jdERv(XHlO076XOtfjOLNOxWpzWBTYpoCHjpJ(ize0e08HpeZ37QvlFWlO5dXq)pjgptWHeBrq4fuhLymeYcjXcmsmKg(HypgoShrG6hl0tme46jM)leKQvSZ6rVynykOLNOxWppQNZJLQLFvLGd5c(t1fbPI6O4WTlnchEWGJGmFSuT8RQeCOjUZagCeK5JHd7reOgleKQDI7mGbhbz(y4WEebQXcbPANqYlBWFhN7p5TGMpe7A0pqt)lwQHuQUigUJym0jXFsm(KyXUJeJflvlFX8L9G)xjg(tIXEXJz1VylccVG6OeJHqwijwGrIH0WpeJfdh2JiGySXc9edbUEI5)cbPAf7SE0lwdMcA5j6f8ZJ69Jdx(lEmR(RlsvrzG5c(t1fbPI6O4WTlnchgCeK5JHd7reOgleKQDI7mGbhbz(y4WEebQXcbPANqYlBWFhN7p5TGwEIEb)8OE)4WfeDII06m6f4sJWzyc7KrtZhOQNfO6OxWaE8bL6aJutVeeAAadocY8V4XS6VUivfLb2e3zWz9y2QZ2G4DNdVf0Yt0l4Nh17hhUmmb9J5sJW5AioGqwikA6LWr1fPgyu1l)GG18)8)gm4SEmB1zBq8tfH0NoUJd38sKAcetfroeS(bmdcf5njqYOj1TBqCaHSqu0urzGPVuFSuT8)bN1JzRoBdI)oUVAadocY8V4XS6VUivfLb2e3zadocY8Xs1YVQsWHM4od8Ypiyn)p)Vbvi5Ln4542bm4iitfLbM(s9Xs1Y)NQLpqqZhI5R7QfdzHI5)cbPAfZbs8c7YtX43bMySy8umiLQlIXhJaIb2qmioa0auIX6ltbT8e9c(5r9(XHlo7QRq6xC4HCbzHva5ZGd3U0iCIutGy(y4WEebQXcbPANeiz0KAapIutGy(yPA5xr2d(pjqYOjLGMped9)Ky(VqqQwXCGKySlpfJpgbeJpjgwoKelWiXiabrDrm(yuGrqXqGRNyo7QBakX43b2IhIX6lITqXgVW)qmueGGPwFzkOLNOxWppQ3poC5XWH9icuJfcs16sJWHaee1f35mUUDWWe2jJMMpqvplq1rVGbND1QLpy(x8yw9xxKQIYaBI7m4SRwT8bZhlvl)QkbhAEWsik6DNd3dUMhqCaHSqu0CzivtGdD7MIyWrqMi6efP1z0lyI7C727qADnsikk(5JHd7reO(Xc9CNZ1C7NBCDxZJi1eiMGgfw8rQhrWjbsgnPgWJi1eiMQeoQ(yPA5pjqYOj1vxD1GZ6XSvNTbXFhhUo4AEWGJGmDGKhP6iJEbtCNB3EhsRRrcrrXpFmCypIa1pwON7U5kbT8e9c(5r9(XHlpbHzqQkZcO670JixoxoAQgjeffphUDPr4mmHDYOP5du1ZcuD0lyapuBmFccZGuvMfq13Phrv1gZOpJAaQbrcrrXmApQgBv1K7C4k3dU(SEmB1zBq8tfH0NoCNZ1hNkQSbU7A0nxD1aEWGJGmFmCypIa1yHGuTtCNbxZdgCeKPdK8ivhz0lyI7C727qADnsikk(5JHd7reO(Xc9C3nxD7gsJclQqYlBWFhhEp4DiTUgjeff)8XWH9icu)yHE3DFbT8e9c(5r9(XHlp5897sJWzyc7KrtZhOQNfO6OxWGZ6XSvNTbXpvesF6WDoClO5dXq)pjg7fpMv)ITaXo7QvlFGyxNibbfdPHFiglGNxjgoqt)lgFsSesIHABakXIvmN1rm)xiivRyjqjMAfdSHyy5qsmwSuT8fZx2d(pf0Yt0l4Nh17hhU8x8yw9xxKQIYaZLgHZWe2jJMMpqvplq1rVGbxhPMaXKadj960au1hlvl)FsGKrtQB3o7QvlFW8Xs1YVQsWHMhSeIIE35W9vdUMhrQjqmFmCypIa1yHGuTtcKmAsD7wKAceZhlvl)kYEW)jbsgnPUD7SRwT8bZhdh2Jiqnwiiv7esEzdE356vdUMhNDibsqmhsGa7c82TZUA1Yhmr0jksRZOxWesEzdE352T3UD2vRw(GjIorrADg9cM4odoRhZwD2geV7C49vcA(qSXdIyPs9ILqsmChxe7bTdjwGrITasm(DGjME5tFiM)(ZZPyO)NeJpgbetDPbOedj)GGIfyjqmF7RIPiK(0HylumWgI9bL6aJuIXVdSfpelbxeZ3(6uqlprVGFEuVFC4IxchrQkYcRkkdmx0nGQhfhUN82LZLJMQrcrrXZHBxAeoWSvvAibIzQu)e3zW1rcrrXmApQgBv10DN1JzRoBdIFQiK(0XTB84dk1bgPMPwp4SEmB1zBq8tfH0NoCNZXP6L(S(oeqDLGMpeB8GigyflvQxm(TwlMQjX43bwdelWiXaKpdXUVBFxed)jX4vi8uSfigZ(Vy87aBXdXsWfX8TVof0Yt0l4Nh17hhU4LWrKQISWQIYaZLgHdmBvLgsGyMk1pBG733T8cmBvLgsGyMk1pv4Wm6fm4SEmB1zBq8tfH0NoCNZXP6L(S(oeqjOLNOxWppQ3poC5Xs1YVYOtf9U0iCgMWoz008bQ6zbQo6fm4SEmB1zBq8tfH0NoCNdxhC9zxTA5dM)fpMv)1fPQOmWMqYlBWFh33UXGJGm)lEmR(RlsvrzGnXDUDdPrHfvi5Ln4VJdxD7vcA5j6f8ZJ69JdxOd22auvi5aBVeOCPr4mmHDYOP5du1ZcuD0lyWz9y2QZ2G4NkcPpD4ohUo46HjStgnnXFQ6a7f2XLkCJm6fC727qADnsikk(5JHd7reO(Xc9UJJBUDdIdiKfIIMq6xCGQbOQhDc74YvcA(qS7PdmXy9fxeRredSHyPgsP6IyQfqUig(tI5)cbPAfJFhyIXU8umCNPGwEIEb)8OE)4WLhdh2JiqnwiivRlncNi1eiMpwQw(vK9G)tcKmAsnyyc7KrtZhOQNfO6OxWagCeK5FXJz1FDrQkkdSjUZGZ6XSvNTbXFhhUo4AEWGJGmDGKhP6iJEbtCNB3EhsRRrcrrXpFmCypIa1pwON7U5kbT8e9c(5r9(XHlpwQw(vvcoKlnchEWGJGmFSuT8RQeCOjUZaKgfwuHKx2G)ooO3(fPMaX8XzccIGJIMeiz0KsqlprVGFEuVFC4cIMESdmrcxAeox)lUMPbQPd(h4AQsqCNOxWTB)IRzAGAoC1z0AQ(REibIRgqacI6Yuri9Pd35CF3oGhFqPoWi1m16bm4iiZ)IhZQ)6Iuvugyt1Yh4sdcccXDIA75rQodId3U0GGGqCNOIsVmPMd3U0GGGqCNO2iC(fxZ0a1C4QZO1u9x9qcecA5j6f8ZJ69JdxC2OxGlnchgCeKjJExLg)JjKYtC7gsJclQqYlBWF39D7TBm4iiZ)IhZQ)6IuvugytCNbxZGJGmFSuT8Rm6ur)e352TZUA1YhmFSuT8Rm6ur)esEzd(74WTBVsqlprVGFEuVFC4cJExvfbhEXLgHddocY8V4XS6VUivfLb2e3rqlprVGFEuVFC4cdbFcoQbOCPr4WGJGm)lEmR(RlsvrzGnXDe0Yt0l4Nh17hhUG0qIrVRYLgHddocY8V4XS6VUivfLb2e3rqlprVGFEuVFC4sco0hWuxpPw7sJWHbhbz(x8yw9xxKQIYaBI7iO5dX4jHK46qmKuRzYZiXqwOy4FYOjX6G8(7vm0)tIXVdmXyV4XS6xSfrmEszGnf0Yt0l4Nh17hhUG)uTdY7DPr4WGJGm)lEmR(RlsvrzGnXDUDdPrHfvi5Ln4VJRUvqtqZh(qmFPb9JrWxqZhIDpyTMed)BakX8vi5rQoYOxGlILd3wj2j)ObOeJv3hsSeOeJN9HeJpgbeJflvlFX4zcoKy9l2VlqSyfJHed)jLlIr(8qoHyilumxtxGDce0Yt0l4NinOFmodtyNmAYfq6rCCGKhPQpqvplq1rVaxgMACItKAcethi5rQoYOxWKajJMudEhsRRrcrrXpFmCypIa1pwO3DxZBE5SdjqcIjGoWvVq1vd4XzhsGeeZrxGDce0Yt0l4NinOFm)4WLx3hQMavv1hYLgHdpgMWoz000bsEKQ(av9Savh9cg8oKwxJeIIIF(y4WEebQFSqV7g3b8Gbhbz(yPA5xvj4qtCNbm4iiZx3hQMavv1hAcjVSb)DinkSOcjVSb)aiHaPhlz0KGwEIEb)ePb9J5hhU86(q1eOQQ(qU0iCgMWoz000bsEKQ(av9Savh9cgC2vRw(G5JLQLFvLGdnpyjef9veyEIEbP(oUNOpEpGbhbz(6(q1eOQQ(qti5Ln4V7SRwT8bZ)IhZQ)6Iuvugyti5Ln4hC9zxTA5dMpwQw(vvco0esP6YagCeK5FXJz1FDrQkkdSjK8Yg88cdocY8Xs1YVQsWHMqYlBWFh3tUELGMpeZ1mPDiOyUEjStgnjgYcfBCWDcCinfJDu7iMch2auIXRYpiOy86)Z)BGylumfoSbOeJNj4qIXVdmX4zchjwcuIbwXgRrHfFK6reCkOLNOxWprAq)y(XHldtyNmAYfq6rC(rTtfI7e4qYLHPgN44LFqWA(F(FdQqYlBW7UBVDJhrQjqmbnkS4JupIGtcKmAsnisnbIPkHJQpwQw(tcKmAsnGbhbz(yPA5xvj4qtCNB3EhsRRrcrrXpFmCypIa1pwON7CUM38cehqilefnrAqQ74YvcA(qmxte5igUJyJdUtGdjXAeX6qS(flzw8qSyfdIdeBXJPGwEIEb)ePb9J5hhUaXDcCi5sJW5AEmmHDYOP5pQDQqCNahs3UnmHDYOPj(tvhyVWoUuHBKrVGRgejeffZO9OASvvt8cK8Yg8UpUdGecKESKrtcA5j6f8tKg0pMFC4Ythif1GoyG21cNe08Hy8kCD0QnIgGsSiHOO4flWYqm(TwlMUhsIHSqXcmsmfomJEbITiIno4oboKCrmiHaPhtmfoSbOeZjbkYRptbT8e9c(jsd6hZpoCbI7e4qYLZLJMQrcrrXZHBxAeo8yyc7KrtZFu7uH4oboKgWJHjStgnnXFQ6a7f2XLkCJm6fm4DiTUgjeff)8XWH9icu)yHEUZHRdIeIIIz0Eun2QQj35CnV97AU66oRhZwD2ge)vxnasiq6XsgnjO5dXghcbspMyJdUtGdjXOeQViwJiwhIXV1AXiF60qsmfoSbOeJ9IhZQ)Py8CflWYqmiHaPhtSgrm2LNIHIIxmiLQlI1aXcmsma5ZqmE)tbT8e9c(jsd6hZpoCbI7e4qYLgHdpgMWoz008h1oviUtGdPbqYlBWF3zxTA5dM)fpMv)1fPQOmWMqYlBW7h3UDWzxTA5dM)fpMv)1fPQOmWMqYlBWFhhEpisikkMr7r1yRQM4fi5Ln4D)SRwT8bZ)IhZQ)6Iuvugyti5Ln49J3cA5j6f8tKg0pMFC4cJopJQolFfbDPr4WJHjStgnnXFQ6a7f2XLkCJm6fm4DiTUgjeffV7CUVGwEIEb)ePb9J5hhUqd7)qWmibnbnF4dXydk1bMy(ExTA5dEbnFiMRzs7qqXC9syNmAsqlprVGF(bL6aREupNHjStgn5ci9iopMQgyq6XwTYLHPgN4C2vRw(G5JLQLFvLGdnpyjef9veyEIEbP2DoCprF8wqZhI56LG(XeRreJpjwcjXoPJtdqj2ceJNj4qIDWsik6NInENq9fXyiKfsIH0WpetLGdjwJigFsmSCijgyfBSgfw8rQhrqXyWdX4zchjglwQw(I1aXwOIGIfRyOOqSXb3jWHKy4oIDnyfJxLFqqX41)N)3GRMcA5j6f8ZpOuhy1J69JdxgMG(XCPr4CnpgMWoz008Xu1adsp2Qv3UXJi1eiMGgfw8rQhrWjbsgnPgePMaXuLWr1hlvl)jbsgnPUAWz9y2QZ2G4NkcPpD4o3d4behqilefn9s4O6IudmQ6LFqWA(F(Fde08Hy(6UAXqwOySyPA57rALy(jglwQw(Fa7rKy4an9Vy8jXsijwYS4HyXk2jDeBbIXZeCiXoyjef9tXC9b6lIXhJaI5lnqj29q5ia9Vy9lwYS4HyXkgehi2IhtbT8e9c(5huQdS6r9(XHlo7QRq6xC4HCbzHva5ZGd3Uq(mGzn9wCqWXnU1LgHdmp0e0OWIkPre0Yt0l4NFqPoWQh17hhU8yPA57rALlnchcqquxCNJBC7acqquxMkcPpD4ohUD7aEmmHDYOP5JPQbgKESvRgCwpMT6Sni(PIq6thUZ9afXGJGmrAGQYNYra6)jK8Yg83XTGMpeZ3(QybgKESvREXqwOyeiiydqjglwQw(IXZeCibT8e9c(5huQdS6r9(XHldtyNmAYfq6rCEmv9SEmB1zBq8Umm14eNZ6XSvNTbXpvesF6WDoC1pgCeK5JLQLFLrNk6N4ocA5j6f8ZpOuhy1J69JdxgMWoz0KlG0J48yQ6z9y2QZ2G4DzyQXjoN1JzRoBdIFQiK(0H7CUVlncNZoKajiMJUa7eiOLNOxWp)GsDGvpQ3poCzyc7KrtUaspIZJPQN1JzRoBdI3LHPgN4CwpMT6Sni(PIq6th3XHBxAeodtyNmAAI)u1b2lSJlv4gz0lyW7qADnsikk(5JHd7reO(Xc9CNJBe08Hy8mbhsmfoSbOeJ9IhZQFXwOyjZoKelWG0JTA1uqlprVGF(bL6aREuVFC4YJLQLFvLGd5sJWzyc7KrtZhtvpRhZwD2ge)GRhMWoz008Xu1adsp2Qv3UXGJGm)lEmR(RlsvrzGnHKx2G3DoCp56TBVdP11iHOO4NpgoShrG6hl0ZDoUzWzxTA5dM)fpMv)1fPQOmWMqYlBW7o3U9kbnFig6WHaXGKx2GgGsmEMGd9IXqilKelWiXqAuyHyeq9I1iIXU8um(lWvHymKyqkvxeRbIfThnf0Yt0l4NFqPoWQh17hhU8yPA5xvj4qU0iCgMWoz008Xu1Z6XSvNTbXpaPrHfvi5Ln4V7SRwT8bZ)IhZQ)6Iuvugyti5Ln4f0e08HpeJnOuhyKsSXzJm6fiO5dXgpiIXguQdmUmmb9JjwcjXWDCrm8NeJflvl)pG9isSyfJHaeshIHaxpXcmsmN8)EijgZcWFXsGsmFPbkXUhkhbO)DrmAibeRreJpjwcjXYqmV0NI5BFvSRXbA6FXW)gGsmEv(bbfJx)F(FdUsqlprVGF(bL6aJuCESuT8)a2JixAeoxZGJGm)GsDGnXDUDJbhbzomb9JnXDUAGx(bbR5)5)nOcjVSbph3kO5dX8Lg0pMyzi299tmF7RIXVdSfpeJNSIXfXCJFIXVdmX4jRy87atmwmCypIaI5)cbPAfJbhbrmChXIvSC42kX(1JeZ3(Qy8ZpiX(oWZOxWpf08Hy8A9VI9jcjwSIH0G(XeldXCJFI5BFvm(DGjg5Z8e6lI5gXIeIIIFk21SPhjw(IT4X3ksSpOuhyZRe08Hy(sd6htSmeZn(jMV9vX43b2IhIXtwxeJ3(jg)oWeJNSUiwcuInUIXVdmX4jRyjsqqXC9sq)ycA5j6f8ZpOuhyKYpoC5KADnprVGQU)Wfq6rCqAq)yU0iCiee6e9qQEwpMT6SniE35CCQEPpRVdbu3UXGJGmFmCypIa1yHGuTtCNbN1JzRoBdIFQiK(0XDC46TBVdP11iHOO4NpgoShrG6hl0ZDoUzaHGqNOhs1Z6XSvNTbX7oh3C72z9y2QZ2G4NkcPpDChhU5LRJutGyQiYHG1pGzKOiVjbsgnPgWGJGmhMG(XM4oxjOLNOxWp)GsDGrk)4WLhlvl)pG9iYLgHZhuQdmsnFY57FW7qADnsikk(5JHd7reO(Xc9UZncA5j6f8ZpOuhyKYpoC5X6HU0iCIutGycAuyXhPEebNeiz0KAaehqilefnJgCPgRp7tLrNkAW7qADnsikk(5JHd7reO(Xc9UJ3cA(qm0VJyXk29flsikkEXUgSI5a79kXgrKJy4oI5lnqj29q5ia9Vymxe7C5OBakXyXs1Y)dypIMcA5j6f8ZpOuhyKYpoC5Xs1Y)dypIC5C5OPAKquu8C42LgHdpgMWoz00e)PQdSxyhxQWnYOxWafXGJGmrAGQYNYra6)jK8Yg83X9G3H06AKquu8Zhdh2Jiq9Jf6DhN7pisikkMr7r1yRQM4fi5Ln4DFCf08Hy(YcfZb2lSJlIb3iJEbUig(tIXILQL)hWEej2oKGIXgl0tm(DGj29WRelrLn4dXWDelwXCJyrcrrXl2cfRreZxUhX6xmioa0auITiiID9celbxel9wCqi2IiwKquu8xjOLNOxWp)GsDGrk)4WLhlvl)pG9iYLgHZWe2jJMM4pvDG9c74sfUrg9cgCTIyWrqMinqv5t5ia9)esEzd(74(2Ti1eiM8P0zbE5heCsGKrtQbVdP11iHOO4NpgoShrG6hl07ooU5kbT8e9c(5huQdms5hhU8y4WEebQFSqpxAeoVdP11iHOO4DNZ997AgCeKzGrv4gbbM4o3UbXbeYcrrZCuMW(R)IRRiWeLhbIRgCndocY8V4XS6VUivfLbwnXJ9a7yI7C7gpyWrqMoqYJuDKrVGjUZTBVdP11iHOO4DNdVVsqZhIXILQL)hWEejwSIbjei9yI5lnqj29q5ia9VyjqjwSIrGhhsIXNe7KaXojeErSDibflfdbxRfZxUhXAqSIfyKyaYNHySlpfRreZz)Vz00uqlprVGF(bL6aJu(XHlpwQw(Fa7rKlnchfXGJGmrAGQYNYra6)jK8Yg83XH7B3o7QvlFW8V4XS6VUivfLb2esEzd(74g9EGIyWrqMinqv5t5ia9)esEzd(7o7QvlFW8V4XS6VUivfLb2esEzdEbT8e9c(5huQdms5hhUGsVRhJovKlnchgCeKPdbrwygKQoKAWp)ipJCNdVhCwGcVJPdbrwygKQoKAWpHjyK7C4((cA5j6f8ZpOuhyKYpoC5Xs1Y)dypIe0Yt0l4NFqPoWiLFC4YbJsN6JTHlnchEejeffZ(Rm7)doRhZwD2ge)uri9Pd35W9agCeK5JTrTb1aJQQeoAI7mGaee1Lz0Eun2QBCR7OoQPx6Zc77qNYyCDC5UeLOuaa]] )

    
end
