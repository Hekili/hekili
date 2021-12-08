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


    spec:RegisterPack( "Subtlety", 20211207, [[defTgcqisGhrPuBIs1NuKyuQKCkfvTkkLOxPi1SirUfju2Lk(fQedJeLJHk1YuPQNPsQMgQKUgjQ2MkP4BKqLXrckoNIqL1bLOMNkvUhQyFuk(hLsOoijOAHqj9qfjnrsixekb1gveYhjbLgjLsiNekbwjuQxsPe0mjbXnjHQ2PIk)urO0qPuslvLu6PO0uveDvsqARkcfFfkHgluICwkLaTxj9xjgmvhw0IH0JvyYK6YiBgIpdfJgfNwQvdLG8AfLztXTjPDd8BLgoQ64kcvTCqpxvtx46q12PK(oLy8kcoVkX6Pucy(Qu2pXvURtwz1zq15Uxz3Zn33Rmf35(RFp3Cv5v24cpvz5ZXSedvzbPkvzzXrddfxQS85fZM66Kv2FXHdQYYeb)JL5cxW0bdo6zSQC5BvCtg9cgWej4Y3QdUuzrXBtGfaQOvwDguDU7v29CZ99ktXDU)63ZnxRSjEWSWklBRo1kltR1eOIwz10pQSS4OHHIlIFTlgCsWEU1kPIsqX5(6kj(9k7EUfSfSNktcWqpwwWwXexXVwjXTMWorn0b)PcpSxyhxkWnYOxG448I)R4DiE)I)uiokHSqsClK44pjEhhbBft8PUQOnGexf3enVHeFKgtjhrVGIP)qCceWMEXJvCiPXhK48BqGOtJ4qYYcNDeSvmXv85ms8jYqpZaMiH4niiieNpeVbIpwv0meVre3cjowi8pex3AX7qCKfkU11KrBOYVgReiovwt)XxNSY(bLMGH01jRZXDDYklbsudPRyTYMJOxqL9zs9A5dypJQSA6hWMp6fuzXcqeNnO0emCXAc6Nr8esIJZRK44pjoltQxlFa7zK4XkokbiKoehbUQIhmK485)TvsC0fG)INaT4tud0IJfPCgG(xjXjReq8grClK4jKepdXvZji(uTvXVchyO)fh)BagXv85heuCf()5)ny(k7a2bb7SYEL4O4iiNpO0emhCEXVDtCuCeKJ1e0pZbNx85f3U4xj(Ztgtjsigk(ZZGd7zeO8Xcvf)oX5Q43UjU1e2jQHo4pv4H9c74sbUrg9ceFEXTlUA(bbl5)5)nOaj1SbV4Cexz1Oo391jRSeirnKUI1kRM(bS5JEbv2jQb9ZiEgIZ1PfFQ2Q4w6GzXdXveRsIR8Pf3shmIRiwLepbAXVgXT0bJ4kIv8ejiO4tmjOFMkBoIEbv2rAmLCe9ckM(Jk7a2bb7SYAnHDIAOdHGqJOTsLXQIUf(TbXlUnCeFWxuZjuEEcOf)2nXrXrqopdoSNrGsSqqQ3doV42fFSQOBHFBq8hnH0Joe)ooIFV43Uj(Ztgtjsigk(ZZGd7zeO8Xcvf3goIZvXTlU1e2jQHoeccnI2kvgRk6w43geV42WrCUk(TBIpwv0TWVni(JMq6rhIFhhX5wCft8RepsdbIJMiEcw(aMrIHupeirnKwC7IJIJGCSMG(zo48IpFL10FuaPkvzrAq)m1Oo31RtwzjqIAiDfRv2bSdc2zL9dknbdPppX)9lUDXFEYykrcXqXFEgCypJaLpwOQ43joxRS5i6fuzFMuVw(a2ZOAuNJR1jRSeirnKUI1k7a2bb7SYgPHaXb0yyIpsZmcEiqIAiT42fhIdiKfIHordUuIDc9OGAsnDiqIAiT42f)5jJPejedf)5zWH9mcu(yHQIFN4kVYMJOxqL9zAR1OoNYRtwzjqIAiDfRv2Ce9cQSptQxlFa7zuLDCzyOsKqmu8154UYoGDqWoRSkqCRjStudDWFQWd7f2XLcCJm6fiUDX1ekocYbPb6IfkNbO)pqsnBWl(DIZT42f)5jJPejedf)5zWH9mcu(yHQIFhhXVU42fpsigkorRsLyl6MexXehsQzdEXTr8RPYQPFaB(OxqLvHYlESIFDXJeIHIx8RaR48WENx8zeXlooV4tud0IJfPCgG(xC0lIpUmmnaJ4SmPET8bSNrNAuN7AQtwzjqIAiDfRv2Ce9cQSptQxlFa7zuLvt)a28rVGk7eTqX5H9c74I4WnYOxGsIJ)K4SmPET8bSNrIVwjO4SXcvf3shmIJfv8INyYg8H448IhR4Cv8iHyO4fFHI3iIpryrX7xCioa0amIViiIF1cepbxepvxCqi(IiEKqmu8ZxzhWoiyNvwRjStudDWFQWd7f2XLcCJm6fiUDXVsCnHIJGCqAGUyHYza6)dKuZg8IFN4Cl(TBIhPHaXXcL8lqn)GGhcKOgslUDXFEYykrcXqXFEgCypJaLpwOQ43XrCUk(81OoNIRozLLajQH0vSwzhWoiyNv2NNmMsKqmu8IBdhXVU4tl(vIJIJGCcgQa3iiWbNx8B3ehIdiKfIHo5SmH9x(f3uqGjgvcehcKOgsl(8IBx8Rehfhb58xurxZxwKIMYGPK4XoGDCW5f)2nXvG4O4iihEiPs6oYOxWbNx8B3e)5jJPejedfV42WrCLl(8v2Ce9cQSpdoSNrGYhluTg15uyQtwzjqIAiDfRv2Ce9cQSptQxlFa7zuLvt)a28rVGklltQxlFa7zK4XkoKqG0Zi(e1aT4yrkNbO)fpbAXJvCc84qsClK4Jei(iHWlIVwjO4P4i4gJ4tewu8geR4bdjoGMqio7QiXBeX53)BudDQSdyheSZkRMqXrqoinqxSq5ma9)bsQzdEXVJJ4Cl(TBIp21OxlGZFrfDnFzrkAkdMdKuZg8IFN4CRWiUDX1ekocYbPb6IfkNbO)pqsnBWl(DIp21OxlGZFrfDnFzrkAkdMdKuZg81Oo3exDYklbsudPRyTYoGDqWoRSO4iihEcISWmiDXk1G)8roMjUnCex5IBx8Xc04DC4jiYcZG0fRud(dmbZe3goIZ91RS5i6fuzXy2vf1KAQg154wz1jRS5i6fuzFMuVw(a2ZOklbsudPRyTg154M76KvwcKOgsxXALDa7GGDwzvG4rcXqXP)c6(V42fFSQOBHFBq8hnH0Joe3goIZT42fhfhb58mBuAqjyOIoHZo48IBxCcqqmxorRsLylCvzIBJ4yg6JAoHkBoIEbv2bdL8LNzJAuJkRMqsCtuNSoh31jRS5i6fuzN1JzvwcKOgsxXAnQZDFDYklbsudPRyTYU8v2NIkBoIEbvwRjStudvzTMgCQYIIJGCEtpOsc0fDpOdoV43Uj(Ztgtjsigk(ZZGd7zeO8Xcvf3goIFnvwn9dyZh9cQSk0N0IhR4AkiOAdiXTWqbdbfFSRrVwaV4wYoehzHIZcuK4O5tAXxG4rcXqXFQSwtybKQuL9b6Yyb6o6fuJ6CxVozLLajQH0vSwzx(k7trLnhrVGkR1e2jQHQSwtdovzjeeAeTvQmwv0TWVni(kRM(bS5JEbvwf(yS4GqCKfkolZKIdPCe9cepAvsC0lI3yalSbye3SwuSPARINGwnhmjedPfxnJbd9I3aXdgsCLDu(lopKgePBagXtX53GarNgXzzMuCE4oQSwtybKQuLLqqOr0wPYyvr3c)2G4RrDoUwNSYsGe1q6kwRSlFL9POYMJOxqL1Ac7e1qvwRPbNQSJvfDl8BdIVYoGDqWoRSJ1kbsqCMDb2jqC7Itii0iARuzSQOBHFBq8IBJ4JvfDl8BdIxC7Ipwv0TWVni(JMq6rhIBJ43lUDXJwLkXwEM4WvXVtCLDuU42fxbIFL4JvfDl8BdIxCoIFV42fhfhb5qdMTbykqIh2QjqxU(bNx8B3eFSQOBHFBq8IZr8RlUDXrXrqo0GzBaMcK4HTAc0fUEW5f)2nXhRk6w43geV4CeNRIBxCuCeKdny2gGPajEyRMaDr5hCEXNVYAnHfqQsvwcbHgrBLkJvfDl8BdIVg15uEDYklbsudPRyTYU8v2NIkBoIEbvwRjStudvzTMgCQYYd7f2XLcCJm6fiUDXFEYykrcXqXFEgCypJaLpwOQ42Wr87RSA6hWMp6fuzNybMlIpysagsC4gz0lq8grClK4mPvsCEyVWoUuGBKrVaXFkepbAXvXnrZBiXJeIHIxCC(tL1AclGuLQS4pv4H9c74sbUrg9cQrDURPozLLajQH0vSwzx(k7trLnhrVGkR1e2jQHQSwtdovzVx5IpT4rAiqCS2yw4HajQH0IBlf)ELj(0IhPHaXrn)GGLfP8mPET8hcKOgslUTu87vM4tlEKgceNNj1RLcYoW)dbsudPf3wk(9kx8PfpsdbItAYbSJlhcKOgslUTu87vM4tl(9kxCBP4xj(Ztgtjsigk(ZZGd7zeO8Xcvf3goIZvXNVYQPFaB(OxqLvH(Kw8yfxtinGe3cdbepwXXFs8pO0emIpvf9IVqXrXBJMGFL1AclGuLQSFqPjykbdKEM1ORrDofxDYklbsudPRyTYQPFaB(OxqLDQm0yM4tvrV4ziosd)OYMJOxqLDKgtjhrVGIP)OYA6pkGuLQSd9xJ6Ckm1jRSeirnKUI1kRM(bS5JEbv2RfhiocUXCr83shdg6fpwXdgsC2GstWqAXV2nYOxG4xHErC92amI)RsI3H4ilCqV487AAagXBeXbBW0amI3V4P1SnjQHM)uzZr0lOYcXbLCe9ckM(Jk7hWEe154UYoGDqWoRSFqPjyi9jnMkRP)OasvQY(bLMGH01Oo3exDYklbsudPRyTYMJOxqL9n9Gkjqx09GQSA6hWMp6fuzv488MlIZA6bjEc0IROEqINH43pT4t1wfxJdBagXdgsCKg(H4CRmXFASa9RK4jsqqXdMmeNRtl(uTvXBeX7qCAc8nKEXT0btdepyiXb0ecXvyNQIeFHI3V4GnehNVYoGDqWoRSppzmLiHyO4ppdoSNrGYhluv87e)Ae3U4ingMOaj1SbV42i(1iUDXrXrqoVPhujb6IUh0bsQzdEXVtCmd9rnNG42fFSQOBHFBq8IBdhX5Q4kM4xjE0QK43jo3kt85f3wk(91Ooh3kRozLLajQH0vSwz10pGnF0lOYARWEHDCr8RDJm6fylwCfcft5fhtBLepfFatEXt0fpeNaeeZfXrwO4bdj(huAcgXNQIEXVcfVnAck(hTXioKEEAeI3X8hXTfeNxjX7q8rcehLepyYq8Vv5n0PYMJOxqLDKgtjhrVGIP)OY(bShrDoURSdyheSZkR1e2jQHo4pv4H9c74sbUrg9cQSM(JcivPk7huAcMYq)1Ooh3CxNSYsGe1q6kwRSA6hWMp6fuzN6c(wtqXX)gGr8uC2GstWi(uvK4wyiG4qkhmnaJ4bdjobiiMlIhmq6zwJUYMJOxqLDKgtjhrVGIP)OY(bShrDoURSdyheSZklbiiMlhnH0Joe)ooIBnHDIAOZhuAcMsWaPNzn6kRP)OasvQY(bLMGPm0FnQZX991jRSeirnKUI1k7a2bb7SYEL4wtyNOg6qii0iARuzSQOBHFBq8IBdhXh8f1CcLNNaAXNx8B3e)kXhRk6w43ge)rti9OdXVJJ4Cl(TBIJ0yyIcKuZg8IFhhX5wC7IBnHDIAOdHGqJOTsLXQIUf(TbXlUnCe)6IF7M4O4iiN)Ik6A(YIu0ugmLep2bSJdoV42f3Ac7e1qhcbHgrBLkJvfDl8BdIxCB4ioxfFEXVDt8Re)5jJPejedf)5zWH9mcu(yHQIBdhX5Q42f3Ac7e1qhcbHgrBLkJvfDl8BdIxCB4ioxfF(kBoIEbv2rAmLCe9ckM(JkRP)OasvQYI0G(zQrDoUVEDYklbsudPRyTYQPFaB(OxqLvH(K4P4O4TrtqXTWqaXHuoyAagXdgsCcqqmxepyG0ZSgDLnhrVGk7inMsoIEbft)rL9dypI6CCxzhWoiyNvwcqqmxoAcPhDi(DCe3Ac7e1qNpO0emLGbspZA0vwt)rbKQuLffVn6AuNJBUwNSYsGe1q6kwRS5i6fuzt4ibujwiKarLvt)a28rVGkRczTqFiopSxyhxeVbINgJ4lI4bdjUc3wviIJsJe)jX7q8rI)0lEkUc7uvuLDa7GGDwzjabXC5OjKE0H42WrCUvU4tlobiiMlhiHHa1Ooh3kVozLnhrVGkBchjGk84MNQSeirnKUI1AuNJ7RPozLnhrVGkRPXWeFbleUgJkbIklbsudPRyTg154wXvNSYMJOxqLfnXuwKsa7XSVYsGe1q6kwRrnQS8qASQOzuNSoh31jRS5i6fuztEEZLc)2)cQSeirnKUI1AuN7(6Kv2Ce9cQSOBegsxqm5fsBPbykXoHguzjqIAiDfR1Oo31RtwzjqIAiDfRv2bSdc2zL9xCdAd0hE8pWnuHG48rVGdbsudPf)2nX)f3G2a9X6AYOnu5xJvcehcKOgsxzZr0lOYIyONzatKOg154ADYkBoIEbv2pO0emvwcKOgsxXAnQZP86KvwcKOgsxXALnhrVGkRAcNr6cYclAkdMklpKgRkAgLNglq)vwUvEnQZDn1jRSeirnKUI1kBoIEbv230dQKaDr3dQYoGDqWoRSqcbsptIAOklpKgRkAgLNglq)vwURrDofxDYklbsudPRyTYoGDqWoRSqCaHSqm0rnHZklsjyOIA(bbl5)5)n4qGe1q6kBoIEbv2Nj1RLcQj10xJAuzrXBJUozDoURtwzjqIAiDfRv2bSdc2zLvbIhPHaXb0yyIpsZmcEiqIAiT42fhIdiKfIHordUuIDc9OGAsnDiqIAiT42f)5jJPejedf)5zWH9mcu(yHQIFN4kVYMJOxqL9zAR1Oo391jRSeirnKUI1k7a2bb7SY(8KXuIeIHIxCB4i(9IBx8RexbIpwReibXbqd4AwOw8B3eFSRrVwaNNGWmiDbDbu557z0rnNqzWKqm0lUIj(GjHyOVGaZr0linIBdhXv25ELl(TBI)8KXuIeIHI)8m4WEgbkFSqvXTrCUk(8IBxCuCeKdpbrwygKUyLAWF(ihZe)ooIZ1kBoIEbv2Nbh2Ziq5JfQwJ6CxVozLLajQH0vSwzhWoiyNv2XUg9AbCEccZG0f0fqLNVNrh1CcLbtcXqV4kM4dMeIH(ccmhrVG0i(DCexzN7vU43Uj(V4g0gOpgk1f0lfAcPkVHoeirnKwC7IRaXrXrqogk1f0lfAcPkVHo48IF7M4)IBqBG(mJS2GVSRTaKPbyoeirnKwC7IRaX1ekocYzgzTbFXcmdMdoFLnhrVGk7tqygKUGUaQ889mQg154ADYkBoIEbvwmMDvrnPMQSeirnKUI1AuNt51jRS5i6fuzrZXSps0klbsudPRyTg1OYo0FDY6CCxNSYsGe1q6kwRSdyheSZkRcehfhb58mPETu0jyqhCEXTlokocY5zWH9mcuIfcs9EW5f3U4O4iiNNbh2Ziqjwii17bsQzdEXVJJ4x)O8kl(tLfbPGzORZXDLnhrVGk7ZK61srNGbvz10pGnF0lOYQqFsCfLGbj(IGOyygAXrjKfsIhmK4in8dXFgCypJaLpwOQ4iWvv8jxii1R4JvLEXBWPg15UVozLLajQH0vSwzhWoiyNvwuCeKZZGd7zeOeleK69GZlUDXrXrqopdoSNrGsSqqQ3dKuZg8IFhhXV(r5vw8NklcsbZqxNJ7kBoIEbv2)Ik6A(YIu0ugmvwn9dyZh9cQSxPqbg6FXtdKs9fXX5fhLgj(tIBHep2DM4SmPETi(eTd8FEXXFsC2lQOR5fFrqummdT4OeYcjXdgsCKg(H4Sm4WEgbeNnwOQ4iWvv8jxii1R4JvLEXBWPg15UEDYklbsudPRyTYoGDqWoRSwtyNOg68aDzSaDh9ce3U4kq8pO0emK(OMGWqIBxCuCeKZFrfDnFzrkAkdMdoV42fFSQOBHFBq8IBdhXvELnhrVGklIjXqgtg9cQrDoUwNSYsGe1q6kwRSdyheSZk7vIdXbeYcXqh1eoRSiLGHkQ5heSK)N)3GdbsudPf3U4JvfDl8BdI)OjKE0H43XrCUfxXepsdbIJMiEcw(aMbHHupeirnKw8B3ehIdiKfIHoAkdgZLYZK61YFiqIAiT42fFSQOBHFBq8IFN4Cl(8IBxCuCeKZFrfDnFzrkAkdMdoV42fhfhb58mPETu0jyqhCEXTlUA(bbl5)5)nOaj1SbV4CexzIBxCuCeKJMYGXCP8mPET8h9AbuzZr0lOYAnb9ZuJ6CkVozLLajQH0vSwz10pGnF0lOYAR7AehzHIp5cbPEfNhskg7QiXT0bJ4SmksCiL6lIBHHaId2qCioa0amIZorNklYclaAcrDoURSdyheSZkBKgceNNbh2Ziqjwii17HajQH0IBxCfiEKgceNNj1RLcYoW)dbsudPRS5i6fuz531uG0V4WbvJ6CxtDYklbsudPRyTYMJOxqL9zWH9mcuIfcs9wz10pGnF0lOYQqFs8jxii1R48qsC2vrIBHHaIBHeNjTsIhmK4eGGyUiUfgkyiO4iWvvC(DnnaJ4w6GzXdXzNiXxO4yHW)qCmeGGPXC5uzhWoiyNvwcqqmxe3goIFnktC7IBnHDIAOZd0LXc0D0lqC7Ip21OxlGZFrfDnFzrkAkdMdoV42fFSRrVwaNNj1RLIobd6mysig6f3goIZT42f)kXvG4qCaHSqm0zrjDtGbDiqIAiT43UjUMqXrqoiMedzmz0l4GZl(TBI)8KXuIeIHI)8m4WEgbkFSqvXTHJ4xjo3IpT4CvCBP4xjUcepsdbIdOXWeFKMze8qGe1qAXTlUcepsdbIJoHZkptQxlhcKOgsl(8IpV4ZlUDXhRk6w43geV43Xr87f3U4xjUcehfhb5Wdjvs3rg9co48IF7M4ppzmLiHyO4ppdoSNrGYhluvCBeNRIpV42f)kXvG4J1kbsqCSsGG5cu8B3exbIp21OxlGdIjXqgtg9co48IpFnQZP4QtwzjqIAiDfRv2Ce9cQSpbHzq6c6cOYZ3ZOk7a2bb7SYAnHDIAOZd0LXc0D0lqC7IRaX1BCEccZG0f0fqLNVNrf9gNOhZAagXTlEKqmuCIwLkXw0njUnCe)EUf3U4xj(yvr3c)2G4pAcPhDiUnCe)kXh8fmzde3gBXIZvXNx85f3U4kqCuCeKZZGd7zeOeleK69GZlUDXVsCfiokocYHhsQKUJm6fCW5f)2nXFEYykrcXqXFEgCypJaLpwOQ42ioxfFEXVDtCKgdtuGKA2Gx874iUYf3U4ppzmLiHyO4ppdoSNrGYhluv87e)6v2XLHHkrcXqXxNJ7AuNtHPozLLajQH0vSwzhWoiyNvwRjStudDEGUmwGUJEbIBx8XQIUf(TbXF0esp6qCB4io3v2Ce9cQSpX)9xJ6CtC1jRSeirnKUI1kBoIEbv2)Ik6A(YIu0ugmvwn9dyZh9cQSk0NeN9Ik6AEXxG4JDn61cq8RsKGGIJ0WpeNfOO5fhhyO)f3cjEcjXXSnaJ4Xko)Yl(KleK6v8eOfxVId2qCM0kjoltQxlIpr7a)pv2bSdc2zL1Ac7e1qNhOlJfO7OxG42f)kXJ0qG4qaRKz5BaMYZK61YFiqIAiT43Uj(yxJETaoptQxlfDcg0zWKqm0lUnCeNBXNxC7IFL4kq8ineiopdoSNrGsSqqQ3dbsudPf)2nXJ0qG48mPETuq2b(FiqIAiT43Uj(yxJETaopdoSNrGsSqqQ3dKuZg8IBJ43l(8IBx8RexbIpwReibXXkbcMlqXVDt8XUg9AbCqmjgYyYOxWbsQzdEXTrCUvM43Uj(yxJETaoiMedzmz0l4GZlUDXhRk6w43geV42WrCLl(81Ooh3kRozLLajQH0vSwzZr0lOYQMWzKUGSWIMYGPYAAavg6kl3hLxzhxggQejedfFDoURSdyheSZklmBDHSsG4KA9FW5f3U4xjEKqmuCIwLkXw0nj(DIpwv0TWVni(JMq6rhIF7M4kq8pO0emK(KgJ42fFSQOBHFBq8hnH0Joe3goIp4lQ5ekppb0IpFLvt)a28rVGklwaI4Pw)INqsCCELe)bnpjEWqIVasClDWiUzTqFi(KtQOJ4k0Ne3cdbexFPbyehj)GGIhmjq8PARIRjKE0H4luCWgI)bLMGH0IBPdMfpepbxeFQ26Pg154M76KvwcKOgsxXALnhrVGkRAcNr6cYclAkdMkRM(bS5JEbvwSaeXbR4Pw)IBPngX1njULoyAG4bdjoGMqi(1v2RK44pjUIhrrIVaXr3)f3shmlEiEcUi(uT1tLDa7GGDwzHzRlKvceNuR)tde3gXVUYexXehMTUqwjqCsT(pACyg9ce3U4JvfDl8BdI)OjKE0H42Wr8bFrnNq55jGUg154((6KvwcKOgsxXALDa7GGDwzTMWorn05b6Yyb6o6fiUDXhRk6w43ge)rti9OdXTHJ43lUDXVsCuCeKZFrfDnFzrkAkdMdoV43Ujo6(V42fhPXWefiPMn4f)ooIFVYeF(kBoIEbv2Nj1RLcQj10xJ6CCF96KvwcKOgsxXALDa7GGDwzTMWorn05b6Yyb6o6fiUDXhRk6w43ge)rti9OdXTHJ43lUDXVsCRjStudDWFQWd7f2XLcCJm6fi(TBI)8KXuIeIHI)8m4WEgbkFSqvXVJJ4Cv8B3ehIdiKfIHoq6xCGUbykdtc74YHajQH0IpFLnhrVGklny2gGPajEyRMaDnQZXnxRtwzjqIAiDfRv2Ce9cQSpdoSNrGsSqqQ3kRM(bS5JEbvwSyhmIZorkjEJioydXtdKs9fX1lGusC8NeFYfcs9kULoyeNDvK448Nk7a2bb7SYgPHaX5zs9APGSd8)qGe1qAXTlU1e2jQHopqxglq3rVaXTlokocY5VOIUMVSifnLbZbNxC7Ipwv0TWVniEXVJJ43lUDXVsCfiokocYHhsQKUJm6fCW5f)2nXFEYykrcXqXFEgCypJaLpwOQ42ioxfF(AuNJBLxNSYsGe1q6kwRSdyheSZkRcehfhb58mPETu0jyqhCEXTlosJHjkqsnBWl(DCexHr8PfpsdbIZJJgeebhdDiqIAiDLnhrVGk7ZK61srNGbvJ6CCFn1jRSeirnKUI1k7a2bb7SYEL4)IBqBG(WJ)bUHkeeNp6fCiqIAiT43Uj(V4g0gOpwxtgTHk)ASsG4qGe1qAXNxC7ItacI5Yrti9OdXTHJ4xxzIBxCfi(huAcgsFsJrC7IJIJGC(lQOR5llsrtzWC0RfqLTbbbH48rPrQS)IBqBG(yDnz0gQ8RXkbIkBdcccX5JsRQs6odQYYDLnhrVGklIHEMbmrIkBdcccX5JcgZIMMkl31Ooh3kU6KvwcKOgsxXALDa7GGDwzrXrqoOMD1g8poqkhH43UjosJHjkqsnBWl(DIFDLj(TBIJIJGC(lQOR5llsrtzWCW5f3U4xjokocY5zs9APGAsn9hCEXVDt8XUg9AbCEMuVwkOMut)bsQzdEXVJJ4CRmXNVYMJOxqLLFJEb1Ooh3km1jRSeirnKUI1k7a2bb7SYIIJGC(lQOR5llsrtzWCW5RS5i6fuzrn7Qli4Wl1Ooh3tC1jRSeirnKUI1k7a2bb7SYIIJGC(lQOR5llsrtzWCW5RS5i6fuzrj4tWznatnQZDVYQtwzjqIAiDfRv2bSdc2zLffhb58xurxZxwKIMYG5GZxzZr0lOYI0qc1SRUg15UN76KvwcKOgsxXALDa7GGDwzrXrqo)fv018LfPOPmyo48v2Ce9cQSjyqFattzKgtnQZD)91jRSeirnKUI1kBoIEbvw8NkDqQFLvt)a28rVGkRIiKe3eIJKgdAoMjoYcfh)tudjEhK6JLfxH(K4w6GrC2lQOR5fFrexrugmNk7a2bb7SYIIJGC(lQOR5llsrtzWCW5f)2nXrAmmrbsQzdEXVt87vwnQrL9dknbtzO)6K154UozLLajQH0vSwzx(k7trLnhrVGkR1e2jQHQSwtdovzh7A0RfW5zs9APOtWGodMeIH(ccmhrVG0iUnCeN7JIt5vwn9dyZh9cQS2IidpbfFIjHDIAOkR1ewaPkvzFgDjyG0ZSgDnQZDFDYklbsudPRyTYMJOxqL1Ac6NPYQPFaB(OxqLDIjb9ZiEJiUfs8esIpsE(gGr8fiUIsWGeFWKqm0FehlCcnxehLqwijosd)qCDcgK4nI4wiXzsRK4Gv85AmmXhPzgbfhfpexrjCM4SmPETiEdeFHAckESIJHcXVwC(ahsIJZl(vGvCfF(bbfxH)F(FdM)uzhWoiyNv2RexbIBnHDIAOZZOlbdKEM1Of)2nXvG4rAiqCangM4J0mJGhcKOgslUDXJ0qG4Ot4SYZK61YHajQH0IpV42fFSQOBHFBq8hnH0Joe3gX5wC7IRaXH4aczHyOJAcNvwKsWqf18dcwY)Z)BWHajQH01Oo31RtwzjqIAiDfRvwn9dyZh9cQS26UgXrwO4SmPETOsgT4tloltQxlFa7zK44ad9V4wiXtijEIU4H4Xk(i5fFbIROemiXhmjed9hXNybMlIBHHaIprnqlowKYza6FX7x8eDXdXJvCioq8fpovwKfwa0eI6CCxzhWoiyNvwyoOdOXWefYGuzPjeWSKQloiQSCvzv2Ce9cQS87Akq6xC4GQrDoUwNSYsGe1q6kwRSdyheSZklbiiMlIBdhX5QYe3U4eGGyUC0esp6qCB4io3ktC7IRaXTMWorn05z0LGbspZA0IBx8XQIUf(TbXF0esp6qCBeNBXTlUMqXrqoinqxSq5ma9)bsQzdEXVtCURS5i6fuzFMuVwujJUg15uEDYklbsudPRyTYU8v2NIkBoIEbvwRjStudvzTMgCQYowv0TWVni(JMq6rhIBdhXVx8Pfhfhb58mPETuqnPM(doFLvt)a28rVGk7uTvXdgi9mRr)IJSqXjqqWgGrCwMuVwexrjyqvwRjSasvQY(m6Yyvr3c)2G4RrDURPozLLajQH0vSwzx(k7trLnhrVGkR1e2jQHQSwtdovzhRk6w43ge)rti9OdXTHJ4xVYoGDqWoRSJ1kbsqCMDb2jOYAnHfqQsv2NrxgRk6w43geFnQZP4QtwzjqIAiDfRv2LVY(uuzZr0lOYAnHDIAOkR10Gtv2XQIUf(TbXF0esp6q874io3v2bSdc2zL1Ac7e1qh8Nk8WEHDCPa3iJEbIBx8NNmMsKqmu8NNbh2Ziq5JfQkUnCeNRvwRjSasvQY(m6Yyvr3c)2G4RrDofM6KvwcKOgsxXALnhrVGk7ZK61srNGbvz10pGnF0lOYQOemiX14WgGrC2lQOR5fFHINORvs8GbspZA0Nk7a2bb7SYAnHDIAOZZOlJvfDl8BdIxC7IFL4wtyNOg68m6sWaPNznAXVDtCuCeKZFrfDnFzrkAkdMdKuZg8IBdhX5(CV43UjokocYzWK7xqtaDW5f)2nXFEYykrcXqXFEgCypJaLpwOQ42WrCUkUDXh7A0RfW5VOIUMVSifnLbZbsQzdEXTrCUvM4ZlUDXVsCuCeKdpbrwygKUyLAWF(ihZe)oX5Q43Uj(Ztgtjsigk(ZZGd7zeO8Xcvf3gXVx85RrDUjU6KvwcKOgsxXALnhrVGk7ZK61srNGbvz10pGnF0lOYIvCiqCiPMnObyexrjyqV4OeYcjXdgsCKgdtiob0V4nI4SRIe3YcMsiokjoKs9fXBG4rRsNk7a2bb7SYAnHDIAOZZOlJvfDl8BdIxC7IJ0yyIcKuZg8IFN4JDn61c48xurxZxwKIMYG5aj1SbFnQrLfPb9ZuNSoh31jRSeirnKUI1k7YxzFkQS5i6fuzTMWornuL1AAWPkBKgcehEiPs6oYOxWHajQH0IBx8NNmMsKqmu8NNbh2Ziq5JfQk(DIFL4kxCft8XALajioaAaxZc1IpV42fxbIpwReibXz2fyNGkRM(bS5JEbvwSitBiXX)gGrCBfsQKUJm6fOK4P1T1IpYpAagXzn9GepbAXvupiXTWqaXzzs9ArCfLGbjE)I)7cepwXrjXXFsRK40egeFioYcf3w4fyNGkR1ewaPkvz5HKkPlpqxglq3rVGAuN7(6KvwcKOgsxXALDa7GGDwzvG4wtyNOg6WdjvsxEGUmwGUJEbIBx8NNmMsKqmu8NNbh2Ziq5JfQk(DIFnIBxCfiokocY5zs9APOtWGo48IBxCuCeKZB6bvsGUO7bDGKA2Gx87ehPXWefiPMn4f3U4qcbsptIAOkBoIEbv230dQKaDr3dQg15UEDYklbsudPRyTYoGDqWoRSwtyNOg6WdjvsxEGUmwGUJEbIBx8XUg9AbCEMuVwk6emOZGjHyOVGaZr0linIFN4CFuCkxC7IJIJGCEtpOsc0fDpOdKuZg8IFN4JDn61c48xurxZxwKIMYG5aj1SbV42f)kXh7A0RfW5zs9APOtWGoqk1xe3U4O4iiN)Ik6A(YIu0ugmhiPMn4fxXehfhb58mPETu0jyqhiPMn4f)oX5(CV4ZxzZr0lOY(MEqLeOl6Eq1OohxRtwzjqIAiDfRv2LVY(uuzZr0lOYAnHDIAOkR10Gtvw18dcwY)Z)BqbsQzdEXTrCLj(TBIRaXJ0qG4aAmmXhPzgbpeirnKwC7IhPHaXrNWzLNj1RLdbsudPf3U4O4iiNNj1RLIobd6GZl(TBI)8KXuIeIHI)8m4WEgbkFSqvXTHJ4CTYQPFaB(OxqL1wez4jO4tmjStudjoYcf)AX5dCiDeNDwZlUgh2amIR4ZpiO4k8)Z)BG4luCnoSbyexrjyqIBPdgXvucNjEc0IdwXNRXWeFKMze8uzTMWcivPk7pR5lqC(ahs1OoNYRtwzjqIAiDfRv2Ce9cQSqC(ahsvwn9dyZh9cQS2cjIxCCEXVwC(ahsI3iI3H49lEIU4H4Xkoehi(IhNk7a2bb7SYEL4kqCRjStudD(znFbIZh4qs8B3e3Ac7e1qh8Nk8WEHDCPa3iJEbIpV42fpsigkorRsLyl6MexXehsQzdEXTr8RrC7Idjei9mjQHQrDURPozLnhrVGk7tdifLGgmGEIhNQSeirnKUI1AuNtXvNSYsGe1q6kwRS5i6fuzH48boKQSJlddvIeIHIVoh3v2bSdc2zLvbIBnHDIAOZpR5lqC(ahsIBxCfiU1e2jQHo4pv4H9c74sbUrg9ce3U4ppzmLiHyO4ppdoSNrGYhluvCB4i(9IBx8iHyO4eTkvITOBsCB4i(vIRCXNw8Re)EXTLIpwv0TWVniEXNx85f3U4qcbsptIAOkRM(bS5JEbvwfpUjA9grdWiEKqmu8IhmziUL2ye30wjXrwO4bdjUghMrVaXxeXVwC(ahskjoKqG0ZiUgh2amIZNanP2JtnQZPWuNSYsGe1q6kwRS5i6fuzH48boKQSA6hWMp6fuzVwcbspJ4xloFGdjXPeAUiEJiEhIBPngXPjW3qsCnoSbyeN9Ik6A(J4kAfpyYqCiHaPNr8grC2vrIJHIxCiL6lI3aXdgsCanHqCL)Nk7a2bb7SYQaXTMWorn05N18fioFGdjXTloKuZg8IFN4JDn61c48xurxZxwKIMYG5aj1SbV4tlo3ktC7Ip21OxlGZFrfDnFzrkAkdMdKuZg8IFhhXvU42fpsigkorRsLyl6MexXehsQzdEXTr8XUg9AbC(lQOR5llsrtzWCGKA2Gx8Pfx51Oo3exDYklbsudPRyTYoGDqWoRSkqCRjStudDWFQWd7f2XLcCJm6fiUDXFEYykrcXqXlUnCe)6v2Ce9cQSOMCmRWVw0eSg154wz1jRS5i6fuzjR9piyguLLajQH0vSwJAuJkRvc(9cQZDVYUNBLnXX91uzTKqqdW8vwSOc)ANdlyofwSS4IpjdjERYVWqCKfk(u(GstWq6PioKM4XBiPf)xvs8epw1miT4dMeGH(JGTcPbK4Cfll(uxGvcgKw8PaXbeYcXqhS0uepwXNcehqiledDWshcKOgspfXVI7jm)rWwH0asCfhww8PUaRemiT4tbIdiKfIHoyPPiESIpfioGqwig6GLoeirnKEkIFf3ty(JGTGnwuHFTZHfmNclwwCXNKHeVv5xyioYcfFk8qASQOzmfXH0epEdjT4)QsIN4XQMbPfFWKam0FeSvinGe)6yzXN6cSsWG0IpLFXnOnqFWstr8yfFk)IBqBG(GLoeirnKEkIFf3ty(JGTcPbK4xhll(uxGvcgKw8P8lUbTb6dwAkIhR4t5xCdAd0hS0HajQH0tr8mehl8eRcr8R4EcZFeSvinGexXHLfFQlWkbdsl(uG4aczHyOdwAkIhR4tbIdiKfIHoyPdbsudPNI4ziow4jwfI4xX9eM)iylyJfv4x7CybZPWILfx8jziXBv(fgIJSqXNYq)trCinXJ3qsl(VQK4jESQzqAXhmjad9hbBfsdiX5kww8PUaRemiT4tbIdiKfIHoyPPiESIpfioGqwig6GLoeirnKEkIF19ty(JGTcPbK4xdww8PUaRemiT4tbIdiKfIHoyPPiESIpfioGqwig6GLoeirnKEkIFf3ty(JGTcPbK4CFDSS4tDbwjyqAXNcehqiledDWstr8yfFkqCaHSqm0blDiqIAi9ue)kUNW8hbBfsdiX5(AWYIp1fyLGbPfFk)IBqBG(GLMI4Xk(u(f3G2a9blDiqIAi9ue)Q7NW8hbBbBSOc)ANdlyofwSS4IpjdjERYVWqCKfk(u(GstWug6FkIdPjE8gsAX)vLepXJvndsl(GjbyO)iyRqAaj(9yzXN6cSsWG0IpfioGqwig6GLMI4Xk(uG4aczHyOdw6qGe1q6PiEgIJfEIvHi(vCpH5pc2c2yrf(1ohwWCkSyzXfFsgs8wLFHH4ilu8PGI3g9uehst84nK0I)RkjEIhRAgKw8btcWq)rWwH0asCUXYIp1fyLGbPfFkqCaHSqm0blnfXJv8PaXbeYcXqhS0HajQH0tr8R4EcZFeSfSXcu5xyqAXvCINJOxG4M(J)iyxzFEAuN7(RH7klpCrAdvzTTTfNfhnmuCr8RDXGtc2222Ip3ALurjO4CFDLe)ELDp3c2c2222IpvMeGHESSGTTTT4kM4k(1kjU1e2jQHo4pv4H9c74sbUrg9cehNx8FfVdX7x8NcXrjKfsIBHeh)jX74iyBBBlUIj(uxv0gqIRIBIM3qIpsJPKJOxqX0FiobcytV4XkoK04dsC(niq0PrCizzHZoc2222IRyIR4ZzK4tKHEMbmrcXBqqqioFiEdeFSQOziEJiUfsCSq4FiUU1I3H4iluCRRjJ2qLFnwjqCeSfSTTTf3wHKIn1vfndb7Ce9c(dpKgRkAgtZHljpV5sHF7Fbc25i6f8hEinwv0mMMdxq3imKUGyYlK2sdWuIDcnqWohrVG)WdPXQIMX0C4cIHEMbmrcLAeo)IBqBG(WJ)bUHkeeNp6fC72V4g0gOpwxtgTHk)ASsGqWohrVG)WdPXQIMX0C4YhuAcgb7Ce9c(dpKgRkAgtZHlQjCgPlilSOPmyuIhsJvfnJYtJfOFoCRCb7Ce9c(dpKgRkAgtZHlVPhujb6IUhKs8qASQOzuEASa9ZHBLAeoqcbsptIAib7Ce9c(dpKgRkAgtZHlptQxlfutQPxPgHdehqiledDut4SYIucgQOMFqWs(F(FdeSfSTTTfxXNnq8RDJm6fiyNJOxWZzwpMjyBBXvOpPfpwX1uqq1gqIBHHcgck(yxJETaEXTKDioYcfNfOiXrZN0IVaXJeIHI)iyNJOxWpnhUynHDIAiLaPkX5b6Yyb6o6fOK10GtCqXrqoVPhujb6IUh0bN)2TNNmMsKqmu8NNbh2Ziq5JfQAdNRrW22IRWhJfheIJSqXzzMuCiLJOxG4rRsIJEr8gdyHnaJ4M1IInvBv8e0Q5GjHyiT4QzmyOx8giEWqIRSJYFX5H0GiDdWiEko)gei60iolZKIZd3HGDoIEb)0C4I1e2jQHucKQehcbHgrBLkJvfDl8BdIxjRPbN4qii0iARuzSQOBHFBq8c25i6f8tZHlwtyNOgsjqQsCieeAeTvQmwv0TWVniELAeoJ1kbsqCMDb2jWoHGqJOTsLXQIUf(TbXBZyvr3c)2G4Tpwv0TWVni(JMq6rh2CV9OvPsSLNjoC9oLDuUDfC1yvr3c)2G45CVDuCeKdny2gGPajEyRMaD56hC(B3gRk6w43gepNRBhfhb5qdMTbykqIh2Qjqx46bN)2TXQIUf(TbXZHR2rXrqo0GzBaMcK4HTAc0fLFW5NxjRPbN4mwv0TWVniEbBBl(elWCr8btcWqId3iJEbI3iIBHeNjTsIZd7f2XLcCJm6fi(tH4jqlUkUjAEdjEKqmu8IJZFeSZr0l4NMdxSMWornKsGuL4G)uHh2lSJlf4gz0lqjRPbN4Wd7f2XLcCJm6fy)5jJPejedf)5zWH9mcu(yHQ2W5EbBBlUc9jT4XkUMqAajUfgciESIJ)K4FqPjyeFQk6fFHIJI3gnbFb7Ce9c(P5WfRjStudPeivjoFqPjykbdKEM1OvYAAWjo3R8PJ0qG4yTXSWdbsudPTL3RSPJ0qG4OMFqWYIuEMuVw(dbsudPTL3RSPJ0qG48mPETuq2b(FiqIAiTT8ELpDKgceN0KdyhxoeirnK2wEVYM(ELBlV65jJPejedf)5zWH9mcu(yHQ2WHRZlyBBXNkdnMj(uv0lEgIJ0WpeSZr0l4NMdxgPXuYr0lOy6pucKQeNH(fSTT4xloqCeCJ5I4VLogm0lESIhmK4SbLMGH0IFTBKrVaXVc9I46Tbye)xLeVdXrw4GEX5310amI3iId2GPbyeVFXtRzBsudn)rWohrVGFAoCbIdk5i6fum9hkbsvIZhuAcgsR0hWEeC4wPgHZhuAcgsFsJrW22IRW55nxeN10ds8eOfxr9GepdXVFAXNQTkUgh2amIhmK4in8dX5wzI)0yb6xjXtKGGIhmzioxNw8PARI3iI3H40e4Bi9IBPdMgiEWqIdOjeIRWovfj(cfVFXbBiooVGDoIEb)0C4YB6bvsGUO7bPuJW55jJPejedf)5zWH9mcu(yHQ3Dn2rAmmrbsQzdEBUg7O4iiN30dQKaDr3d6aj1Sb)Dyg6JAob7JvfDl8BdI3goCvXUkAv6oUv282Y7fSTT42kSxyhxe)A3iJEb2IfxHqXuEXX0wjXtXhWKx8eDXdXjabXCrCKfkEWqI)bLMGr8PQOx8RqXBJMGI)rBmIdPNNgH4Dm)rCBbX5vs8oeFKaXrjXdMme)BvEdDeSZr0l4NMdxgPXuYr0lOy6pucKQeNpO0emLH(v6dypcoCRuJWXAc7e1qh8Nk8WEHDCPa3iJEbc22w8PUGV1euC8VbyepfNnO0emIpvfjUfgcioKYbtdWiEWqItacI5I4bdKEM1OfSZr0l4NMdxgPXuYr0lOy6pucKQeNpO0emLH(v6dypcoCRuJWHaeeZLJMq6rh3XXAc7e1qNpO0emLGbspZA0c25i6f8tZHlJ0yk5i6fum9hkbsvIdsd6NrPgHZvwtyNOg6qii0iARuzSQOBHFBq82WzWxuZjuEEcON)2TRgRk6w43ge)rti9OJ74W9TBingMOaj1Sb)DC42U1e2jQHoeccnI2kvgRk6w43geVnCU(TBO4iiN)Ik6A(YIu0ugmLep2bSJdoVDRjStudDieeAeTvQmwv0TWVniEB4W15VD7QNNmMsKqmu8NNbh2Ziq5JfQAdhUA3Ac7e1qhcbHgrBLkJvfDl8BdI3goCDEbBBlUc9jXtXrXBJMGIBHHaIdPCW0amIhmK4eGGyUiEWaPNznAb7Ce9c(P5WLrAmLCe9ckM(dLaPkXbfVnAL(a2JGd3k1iCiabXC5OjKE0XDCSMWorn05dknbtjyG0ZSgTGTTfxHSwOpeNh2lSJlI3aXtJr8fr8GHexHBRkeXrPrI)K4Di(iXF6fpfxHDQksWohrVGFAoCjHJeqLyHqcek1iCiabXC5OjKE0HnC4w5ttacI5YbsyiGGDoIEb)0C4schjGk84MNeSZr0l4NMdxmngM4lyHW1yujqiyNJOxWpnhUGMyklsjG9y2lylyBBBlowXBJMGVGDoIEb)bfVnAoptBvPgHJcI0qG4aAmmXhPzgbpeirnK2oehqiledDIgCPe7e6rb1KAY(Ztgtjsigk(ZZGd7zeO8XcvVt5c25i6f8hu82ONMdxEgCypJaLpwOQsncNNNmMsKqmu82W5E7xPGXALajioaAaxZc13Un21OxlGZtqygKUGUaQ889m6OMtOmysig6vSbtcXqFbbMJOxqASHJYo3R8B3EEYykrcXqXFEgCypJaLpwOQnCDE7O4iihEcISWmiDXk1G)8roMDhhUkyNJOxWFqXBJEAoC5jimdsxqxavE(EgPuJWzSRrVwaNNGWmiDbDbu557z0rnNqzWKqm0RydMeIH(ccmhrVG0ChhLDUx53U9lUbTb6JHsDb9sHMqQYBOdbsudPTRauCeKJHsDb9sHMqQYBOdo)TB)IBqBG(mJS2GVSRTaKPbyoeirnK2Uc0ekocYzgzTbFXcmdMdoVGDoIEb)bfVn6P5WfmMDvrnPMeSZr0l4pO4TrpnhUGMJzFKOc2c2222Ip1Dn61c4fSTT4k0NexrjyqIViikgMHwCuczHK4bdjosd)q8Nbh2Ziq5JfQkocCvfFYfcs9k(yvPx8gCeSZr0l4pd9Z5zs9APOtWGuc)PYIGuWm0C4wPgHJcqXrqoptQxlfDcg0bN3okocY5zWH9mcuIfcs9EW5TJIJGCEgCypJaLyHGuVhiPMn4VJZ1pkxW22IFLcfyO)fpnqk1xehNxCuAK4pjUfs8y3zIZYK61I4t0oW)5fh)jXzVOIUMx8fbrXWm0IJsilKepyiXrA4hIZYGd7zeqC2yHQIJaxvXNCHGuVIpwv6fVbhb7Ce9c(Zq)tZHl)fv018LfPOPmyuc)PYIGuWm0C4wPgHdkocY5zWH9mcuIfcs9EW5TJIJGCEgCypJaLyHGuVhiPMn4VJZ1pkxWohrVG)m0)0C4cIjXqgtg9cuQr4ynHDIAOZd0LXc0D0lWUc(GstWq6JAccdzhfhb58xurxZxwKIMYG5GZBFSQOBHFBq82Wr5c25i6f8NH(NMdxSMG(zuQr4CfehqiledDut4SYIucgQOMFqWs(F(FdSpwv0TWVni(JMq6rh3XHBflsdbIJMiEcw(aMbHHupeirnK(2nioGqwig6OPmymxkptQxlV9XQIUf(TbXFh3ZBhfhb58xurxZxwKIMYG5GZBhfhb58mPETu0jyqhCE7Q5heSK)N)3GcKuZg8CuMDuCeKJMYGXCP8mPET8h9AbiyBBXT1DnIJSqXNCHGuVIZdjfJDvK4w6GrCwgfjoKs9fXTWqaXbBioehaAagXzNOJGDoIEb)zO)P5Wf(Dnfi9loCqkHSWcGMqWHBLAeorAiqCEgCypJaLyHGuVhcKOgsBxbrAiqCEMuVwki7a)peirnKwW22IRqFs8jxii1R48qsC2vrIBHHaIBHeNjTsIhmK4eGGyUiUfgkyiO4iWvvC(DnnaJ4w6GzXdXzNiXxO4yHW)qCmeGGPXC5iyNJOxWFg6FAoC5zWH9mcuIfcs9QuJWHaeeZfB4CnkZU1e2jQHopqxglq3rVa7JDn61c48xurxZxwKIMYG5GZBFSRrVwaNNj1RLIobd6mysig6THd32VsbqCaHSqm0zrjDtGbD7MMqXrqoiMedzmz0l4GZF72Ztgtjsigk(ZZGd7zeO8XcvTHZvCpnxTLxPGineioGgdt8rAMrWdbsudPTRGineio6eoR8mPETCiqIAi98ZpV9XQIUf(TbXFhN7TFLcqXrqo8qsL0DKrVGdo)TBppzmLiHyO4ppdoSNrGYhlu1gUoV9RuWyTsGeehReiyUaVDtbJDn61c4GysmKXKrVGdo)8c25i6f8NH(NMdxEccZG0f0fqLNVNrknUmmujsigkEoCRuJWXAc7e1qNhOlJfO7OxGDfO348eeMbPlOlGkpFpJk6norpM1am2JeIHIt0Quj2IUjB4Cp32VASQOBHFBq8hnH0JoSHZvd(cMSb2ylMRZpVDfGIJGCEgCypJaLyHGuVhCE7xPauCeKdpKujDhz0l4GZF72Ztgtjsigk(ZZGd7zeO8XcvTHRZF7gsJHjkqsnBWFhhLB)5jJPejedf)5zWH9mcu(yHQ3DDb7Ce9c(Zq)tZHlpX)9RuJWXAc7e1qNhOlJfO7OxG9XQIUf(TbXF0esp6WgoClyBBXvOpjo7fv018IVaXh7A0RfG4xLibbfhPHFiolqrZlooWq)lUfs8esIJzBagXJvC(Lx8jxii1R4jqlUEfhSH4mPvsCwMuVweFI2b(FeSZr0l4pd9pnhU8xurxZxwKIMYGrPgHJ1e2jQHopqxglq3rVa7xfPHaXHawjZY3amLNj1RL)qGe1q6B3g7A0RfW5zs9APOtWGodMeIHEB4W982VsbrAiqCEgCypJaLyHGuVhcKOgsF7wKgceNNj1RLcYoW)dbsudPVDBSRrVwaNNbh2Ziqjwii17bsQzdEBUFE7xPGXALajiowjqWCbE72yxJETaoiMedzmz0l4aj1SbVnCRSB3g7A0RfWbXKyiJjJEbhCE7JvfDl8BdI3gokFEbBBlowaI4Pw)INqsCCELe)bnpjEWqIVasClDWiUzTqFi(KtQOJ4k0Ne3cdbexFPbyehj)GGIhmjq8PARIRjKE0H4luCWgI)bLMGH0IBPdMfpepbxeFQ26rWohrVG)m0)0C4IAcNr6cYclAkdgLmnGkdnhUpkxPXLHHkrcXqXZHBLAeoWS1fYkbItQ1)bN3(vrcXqXjAvQeBr30DJvfDl8BdI)OjKE0XTBk4dknbdPpPXyFSQOBHFBq8hnH0JoSHZGVOMtO88eqpVGTTfhlarCWkEQ1V4wAJrCDtIBPdMgiEWqIdOjeIFDL9kjo(tIR4ruK4lqC09FXT0bZIhINGlIpvB9iyNJOxWFg6FAoCrnHZiDbzHfnLbJsnchy26czLaXj16)0aBUUYumy26czLaXj16)OXHz0lW(yvr3c)2G4pAcPhDydNbFrnNq55jGwWohrVG)m0)0C4YZK61sb1KA6vQr4ynHDIAOZd0LXc0D0lW(yvr3c)2G4pAcPhDydN7TFfkocY5VOIUMVSifnLbZbN)2n09F7ingMOaj1Sb)DCUxzZlyNJOxWFg6FAoCHgmBdWuGepSvtGwPgHJ1e2jQHopqxglq3rVa7JvfDl8BdI)OjKE0HnCU3(vwtyNOg6G)uHh2lSJlf4gz0l42TNNmMsKqmu8NNbh2Ziq5JfQEhhUE7gehqiledDG0V4aDdWugMe2XL5fSTT4yXoyeNDIus8grCWgINgiL6lIRxaPK44pj(KleK6vClDWio7QiXX5pc25i6f8NH(NMdxEgCypJaLyHGuVk1iCI0qG48mPETuq2b(FiqIAiTDRjStudDEGUmwGUJEb2rXrqo)fv018LfPOPmyo482hRk6w43ge)DCU3(vkafhb5Wdjvs3rg9co483U98KXuIeIHI)8m4WEgbkFSqvB468c25i6f8NH(NMdxEMuVwk6emiLAeokafhb58mPETu0jyqhCE7ingMOaj1Sb)DCuyMosdbIZJJgeebhdDiqIAiTGDoIEb)zO)P5Wfed9mdyIek1iCU6xCdAd0hE8pWnuHG48rVGB3(f3G2a9X6AYOnu5xJvceZBNaeeZLJMq6rh2W56kZUc(GstWq6tAm2rXrqo)fv018LfPOPmyo61cqPgeeeIZhLwvL0DgehUvQbbbH48rbJzrtdhUvQbbbH48rPr48lUbTb6J11KrBOYVgReieSZr0l4pd9pnhUWVrVaLAeoO4iihuZUAd(hhiLJ42nKgdtuGKA2G)URRSB3qXrqo)fv018LfPOPmyo482Vcfhb58mPETuqnPM(do)TBJDn61c48mPETuqnPM(dKuZg83XHBLnVGDoIEb)zO)P5WfuZU6cco8IsnchuCeKZFrfDnFzrkAkdMdoVGDoIEb)zO)P5Wfuc(eCwdWOuJWbfhb58xurxZxwKIMYG5GZlyNJOxWFg6FAoCbPHeQzxTsnchuCeKZFrfDnFzrkAkdMdoVGDoIEb)zO)P5WLemOpGPPmsJrPgHdkocY5VOIUMVSifnLbZbNxW22IRicjXnH4iPXGMJzIJSqXX)e1qI3bP(yzXvOpjULoyeN9Ik6AEXxeXveLbZrWohrVG)m0)0C4c(tLoi1xPgHdkocY5VOIUMVSifnLbZbN)2nKgdtuGKA2G)U7vMGTGTTTT4tud6NHGVGTTfhlY0gsC8Vbye3wHKkP7iJEbkjEADBT4J8JgGrCwtpiXtGwCf1dsClmeqCwMuVwexrjyqI3V4)UaXJvCusC8N0kjonHbXhIJSqXTfEb2jqWohrVG)G0G(z4ynHDIAiLaPkXHhsQKU8aDzSaDh9cuYAAWjorAiqC4HKkP7iJEbhcKOgsB)5jJPejedf)5zWH9mcu(yHQ3DLYvSXALajioaAaxZc1ZBxbJ1kbsqCMDb2jqWohrVG)G0G(zMMdxEtpOsc0fDpiLAeokWAc7e1qhEiPs6Yd0LXc0D0lW(Ztgtjsigk(ZZGd7zeO8XcvV7ASRauCeKZZK61srNGbDW5TJIJGCEtpOsc0fDpOdKuZg83H0yyIcKuZg82HecKEMe1qc25i6f8hKg0pZ0C4YB6bvsGUO7bPuJWXAc7e1qhEiPs6Yd0LXc0D0lW(yxJETaoptQxlfDcg0zWKqm0xqG5i6fKM74(O4uUDuCeKZB6bvsGUO7bDGKA2G)UXUg9AbC(lQOR5llsrtzWCGKA2G3(vJDn61c48mPETu0jyqhiL6l2rXrqo)fv018LfPOPmyoqsnBWRyO4iiNNj1RLIobd6aj1Sb)DCFUFEbBBlUTiYWtqXNysyNOgsCKfk(1IZh4q6io7SMxCnoSbyexXNFqqXv4)N)3aXxO4ACydWiUIsWGe3shmIROeot8eOfhSIpxJHj(inZi4rWohrVG)G0G(zMMdxSMWornKsGuL48ZA(ceNpWHKswtdoXrn)GGL8)8)guGKA2G3gLD7McI0qG4aAmmXhPzgbpeirnK2EKgcehDcNvEMuVwoeirnK2okocY5zs9APOtWGo483U98KXuIeIHI)8m4WEgbkFSqvB4WvbBBlUTqI4fhNx8RfNpWHK4nI4DiE)INOlEiESIdXbIV4XrWohrVG)G0G(zMMdxG48boKuQr4CLcSMWorn05N18fioFGdPB3SMWorn0b)PcpSxyhxkWnYOxW82JeIHIt0Quj2IUjfdsQzdEBUg7qcbsptIAib7Ce9c(dsd6NzAoC5PbKIsqdgqpXJtc22wCfpUjA9grdWiEKqmu8IhmziUL2ye30wjXrwO4bdjUghMrVaXxeXVwC(ahskjoKqG0ZiUgh2amIZNanP2JJGDoIEb)bPb9ZmnhUaX5dCiP04YWqLiHyO45WTsnchfynHDIAOZpR5lqC(ahs2vG1e2jQHo4pv4H9c74sbUrg9cS)8KXuIeIHI)8m4WEgbkFSqvB4CV9iHyO4eTkvITOBYgoxP8PV6EB5yvr3c)2G4NFE7qcbsptIAibBBl(1siq6ze)AX5dCijoLqZfXBeX7qClTXionb(gsIRXHnaJ4SxurxZFexrR4btgIdjei9mI3iIZUksCmu8IdPuFr8giEWqIdOjeIR8)iyNJOxWFqAq)mtZHlqC(ahsk1iCuG1e2jQHo)SMVaX5dCizhsQzd(7g7A0RfW5VOIUMVSifnLbZbsQzd(P5wz2h7A0RfW5VOIUMVSifnLbZbsQzd(74OC7rcXqXjAvQeBr3KIbj1SbVnJDn61c48xurxZxwKIMYG5aj1Sb)0kxWohrVG)G0G(zMMdxqn5ywHFTOjOsnchfynHDIAOd(tfEyVWoUuGBKrVa7ppzmLiHyO4THZ1fSZr0l4pinOFMP5WfYA)dcMbjylyBBBloBqPjyeFQ7A0RfWlyBBXTfrgEck(etc7e1qc25i6f8NpO0emLH(5ynHDIAiLaPkX5z0LGbspZA0kznn4eNXUg9AbCEMuVwk6emOZGjHyOVGaZr0lin2WH7JIt5c22w8jMe0pJ4nI4wiXtij(i55BagXxG4kkbds8btcXq)rCSWj0CrCuczHK4in8dX1jyqI3iIBHeNjTsIdwXNRXWeFKMzeuCu8qCfLWzIZYK61I4nq8fQjO4Xkogke)AX5dCijooV4xbwXv85heuCf()5)ny(JGDoIEb)5dknbtzO)P5WfRjOFgLAeoxPaRjStudDEgDjyG0ZSg9TBkisdbIdOXWeFKMze8qGe1qA7rAiqC0jCw5zs9A5qGe1q65Tpwv0TWVni(JMq6rh2WTDfaXbeYcXqh1eoRSiLGHkQ5heSK)N)3abBBlUTURrCKfkoltQxlQKrl(0IZYK61YhWEgjooWq)lUfs8esINOlEiESIpsEXxG4kkbds8btcXq)r8jwG5I4wyiG4tud0IJfPCgG(x8(fprx8q8yfhIdeFXJJGDoIEb)5dknbtzO)P5Wf(Dnfi9loCqkHSWcGMqWHBLOjeWSKQloi4WvLPuJWbMd6aAmmrHmic25i6f8NpO0emLH(NMdxEMuVwujJwPgHdbiiMl2WHRkZobiiMlhnH0JoSHd3kZUcSMWorn05z0LGbspZA02hRk6w43ge)rti9OdB42UMqXrqoinqxSq5ma9)bsQzd(74wW22IpvBv8GbspZA0V4iluCceeSbyeNLj1RfXvucgKGDoIEb)5dknbtzO)P5WfRjStudPeivjopJUmwv0TWVniELSMgCIZyvr3c)2G4pAcPhDydN7Ngfhb58mPETuqnPM(doVGDoIEb)5dknbtzO)P5WfRjStudPeivjopJUmwv0TWVniELSMgCIZyvr3c)2G4pAcPhDydNRRuJWzSwjqcIZSlWobc25i6f8NpO0emLH(NMdxSMWornKsGuL48m6Yyvr3c)2G4vYAAWjoJvfDl8BdI)OjKE0XDC4wPgHJ1e2jQHo4pv4H9c74sbUrg9cS)8KXuIeIHI)8m4WEgbkFSqvB4WvbBBlUIsWGexJdBagXzVOIUMx8fkEIUwjXdgi9mRrFeSZr0l4pFqPjykd9pnhU8mPETu0jyqk1iCSMWorn05z0LXQIUf(TbXB)kRjStudDEgDjyG0ZSg9TBO4iiN)Ik6A(YIu0ugmhiPMn4THd3N7VDdfhb5myY9lOjGo483U98KXuIeIHI)8m4WEgbkFSqvB4Wv7JDn61c48xurxZxwKIMYG5aj1SbVnCRS5TFfkocYHNGilmdsxSsn4pFKJz3X1B3EEYykrcXqXFEgCypJaLpwOQn3pVGTTfhR4qG4qsnBqdWiUIsWGEXrjKfsIhmK4ingMqCcOFXBeXzxfjULfmLqCusCiL6lI3aXJwLoc25i6f8NpO0emLH(NMdxEMuVwk6emiLAeowtyNOg68m6Yyvr3c)2G4TJ0yyIcKuZg83n21OxlGZFrfDnFzrkAkdMdKuZg8c2c2222IZguAcgsl(1Urg9ceSTT4ybiIZguAcgUynb9ZiEcjXX5vsC8NeNLj1RLpG9ms8yfhLaeshIJaxvXdgsC(8)2kjo6cWFXtGw8jQbAXXIuodq)RK4KvciEJiUfs8esINH4Q5eeFQ2Q4xHdm0)IJ)naJ4k(8dckUc))8)gmVGDoIEb)5dknbdP58mPET8bSNrk1iCUcfhb58bLMG5GZF7gkocYXAc6N5GZpV9REEYykrcXqXFEgCypJaLpwO6DC92nRjStudDWFQWd7f2XLcCJm6fmVD18dcwY)Z)BqbsQzdEoktW22IprnOFgXZq8RpT4t1wf3shmlEiUIyfNlIZ1Pf3shmIRiwXT0bJ4Sm4WEgbeFYfcs9kokocI448IhR4P1T1I)Rkj(uTvXTKFqI)DGNrVG)iyBBXv4MFf)tes8yfhPb9ZiEgIZ1PfFQ2Q4w6GrCAc5imxeNRIhjedf)r8Rytvs88fFXJV1K4FqPjyoZlyBBXNOg0pJ4zioxNw8PARIBPdMfpexrSkjUYNwClDWiUIyvs8eOf)Ae3shmIRiwXtKGGIpXKG(zeSZr0l4pFqPjyi90C4YinMsoIEbft)HsGuL4G0G(zuQr4ynHDIAOdHGqJOTsLXQIUf(TbXBdNbFrnNq55jG(2nuCeKZZGd7zeOeleK69GZBFSQOBHFBq8hnH0JoUJZ93U98KXuIeIHI)8m4WEgbkFSqvB4Wv7wtyNOg6qii0iARuzSQOBHFBq82WHR3Unwv0TWVni(JMq6rh3XHBf7QineioAI4jy5dygjgs9qGe1qA7O4iihRjOFMdo)8c25i6f8NpO0emKEAoC5zs9A5dypJuQr48bLMGH0NN4)(T)8KXuIeIHI)8m4WEgbkFSq174QGDoIEb)5dknbdPNMdxEM2QsncNineioGgdt8rAMrWdbsudPTdXbeYcXqNObxkXoHEuqnPMS)8KXuIeIHI)8m4WEgbkFSq17uUGTTfxHYlESIFDXJeIHIx8RaR48WENx8zeXlooV4tud0IJfPCgG(xC0lIpUmmnaJ4SmPET8bSNrhb7Ce9c(ZhuAcgspnhU8mPET8bSNrknUmmujsigkEoCRuJWrbwtyNOg6G)uHh2lSJlf4gz0lWUMqXrqoinqxSq5ma9)bsQzd(742(Ztgtjsigk(ZZGd7zeO8XcvVJZ1ThjedfNOvPsSfDtkgKuZg82Cnc22w8jAHIZd7f2XfXHBKrVaLeh)jXzzs9A5dypJeFTsqXzJfQkULoyehlQ4fpXKn4dXX5fpwX5Q4rcXqXl(cfVreFIWII3V4qCaObyeFrqe)QfiEcUiEQU4Gq8fr8iHyO4NxWohrVG)8bLMGH0tZHlptQxlFa7zKsnchRjStudDWFQWd7f2XLcCJm6fy)knHIJGCqAGUyHYza6)dKuZg83X9TBrAiqCSqj)cuZpi4HajQH02FEYykrcXqXFEgCypJaLpwO6DC468c25i6f8NpO0emKEAoC5zWH9mcu(yHQk1iCEEYykrcXqXBdNRp9vO4iiNGHkWnccCW5VDdIdiKfIHo5SmH9x(f3uqGjgvceZB)kuCeKZFrfDnFzrkAkdMsIh7a2XbN)2nfGIJGC4HKkP7iJEbhC(B3EEYykrcXqXBdhLpVGTTfNLj1RLpG9ms8yfhsiq6zeFIAGwCSiLZa0)INaT4XkobECijUfs8rceFKq4fXxReu8uCeCJr8jclkEdIv8GHehqtieNDvK4nI487)nQHoc25i6f8NpO0emKEAoC5zs9A5dypJuQr4OjuCeKdsd0fluodq)FGKA2G)ooCF72yxJETao)fv018LfPOPmyoqsnBWFh3km21ekocYbPb6IfkNbO)pqsnBWF3yxJETao)fv018LfPOPmyoqsnBWlyNJOxWF(GstWq6P5WfmMDvrnPMuQr4GIJGC4jiYcZG0fRud(Zh5yMnCuU9Xc04DC4jiYcZG0fRud(dmbZSHd3xxWohrVG)8bLMGH0tZHlptQxlFa7zKGDoIEb)5dknbdPNMdxgmuYxEMnuQr4OGiHyO40FbD)3(yvr3c)2G4pAcPhDydhUTJIJGCEMnknOemurNWzhCE7eGGyUCIwLkXw4QYSbZqFuZjuJAuRa]] )

    
end
