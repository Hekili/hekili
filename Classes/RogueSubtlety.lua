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
        if this_action == "marked_for_death" and target.time_to_die > 3 + Hekili:GetLowestTTD() then return "cycle" end
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


    spec:RegisterPack( "Subtlety", 20210705, [[dafB9bqiQO8iQi2KsvFcvkJsvLoLQkwfvuLxrvvZcvLBHQe7sv(fKQggQsDmufldvsptvPAAkfCnuvzBkfY3qLOgNsHQZrfj16uvkMNQsUhQyFuv6FOsKYbrvsTqivEivfMiQuDrujs2ivu5JOseJKksOtsfv1kvv1lPIemtuj4MOkj7uPOFQuOyOurQLsvrEkkMkvvUkQeARurs(QQsPXsvrDwujs1EL4VsAWuoSOfdvpwjtMKlJSzi(mKmAOCAPwTsHsVwvXSj1TPk7g43kgov64urIwoONRY0fUokTDLsFNkmEuv15vQmFiL9tCHNIFfgvguztUYBUYdV5Y8MFpEVX3a)2a)kmXoxQW4MRpjkQWaspQWWWIhAk2vyCZD6jvf)km3WcxuHblc37Bqp6r1bgl(BnEO)ApwDg9awWejq)1El0xyWzBD48bf8cJkdQSjx5nx5H3CzEZVhV34BGFFNlxys2aBGfgM2ZhfgSwPiqbVWOOBvyyyXdnf7eZNguSK8)pRENy8JpX4kV5kpYF5VpWsak6(g5pVigVA2sITnHDIRPh7rvxypWo2vHtKrpaXyDf7gX6qS(e7OqmCczGKyoiXypsSoEYFErmFmE4nGeZJvhTRMeBLADnxrpGQUVqmceWMoXIrmiPyxKyUtqGOtTyqYXa)8K)8Iy8Q8djMZPPdBbtKqSgeeeY6gI1aXwJhEgI1iI5GeBJL9cXuTsSoedzGITD0z0AQEJElbIxHr3xCf)kmxqPoWivXVYM8u8RWqGextQc6km5k6buyoSunoUa2FOcJIUfSDJEafgNpIymbL6ad9BtqFyILqsmwx(eJ9iXyWs144cy)HelgXWjaH0HyiWXtSaJeZnVR3sIHpa2tSeOeZ5AGsSVLYpa6o(eJ2saXAeXCqILqsSmeZl5Vy(WPf7xwGMUtm2RbOeJxLxqqX413L31GFkmlyheSZcZVIHZIG8UGsDG9yDfdn0edNfb5Tnb9H9yDf7hX2lMxEbbR5D5DnOcjVSbNyCeJ3LOSjxl(vyiqIRjvbDfgfDly7g9akmoxd6dtSmeBd(lMpCAXC0b2WgIXDg(eJF(lMJoWeJ7m8jwcuITrI5OdmX4oJyjsqqXCQsqFyfMCf9akmRuRR5k6bu19ffMfSdc2zHHqqOv0BP6A8WNQ70G4eZxoITCREj)RNlbuIHgAIHZIG8omwy)Ha1yGGunpwxX2l2A8WNQ70G4EkcPxDi2xCeJRIHgAIDUKwxJeIII7DySW(dbQxmqpX8LJyBqS9Irii0k6TuDnE4t1DAqCI5lhX2GyOHMyRXdFQUtdI7PiKE1HyFXrmEeJxe7xXIutG4PiYLG1lGzKOiVhbsCnPeBVy4SiiVTjOpShRRy)uy09fvq6rfgKg0hwjkB(9IFfgcK4AsvqxHzb7GGDwyUGsDGrQ3rUxFITxSZL06AKquuCVdJf2Fiq9Ib6j2xITHctUIEafMdlvJJlG9hQeLn3qXVcdbsCnPkORWSGDqWolmrQjq8ankS4Iu)HGpcK4Asj2EXGSaczGOOx0GD1y4FVQ46urpcK4Asj2EXoxsRRrcrrX9omwy)Ha1lgONyFjg)km5k6buyoSEBjkBYVIFfgcK4AsvqxHjxrpGcZHLQXXfW(dvyw7wAQgjeffxztEkmlyheSZcJZeBBc7extp2JQUWEGDSRcNiJEaITxmfHZIG8qAGQ6GYpa6UhK8YgCI9Ly8i2EXoxsRRrcrrX9omwy)Ha1lgONyFXrSVl2EXIeIIIx0EunMQQjX4fXGKx2GtmFfBJkmk6wW2n6buy4IUIfJyFxSiHOO4e7xWiMlSNFe7drUIX6kMZ1aLyFlLFa0DIHVtS1ULUbOeJblvJJlG9h6vIYMBuXVcdbsCnPkORWKROhqH5Ws144cy)Hkmk6wW2n6buyCUbkMlShyh7edorg9a4tm2JeJblvJJlG9hsSzlbfJjgONyo6atSVLxjwIkBWfIX6kwmITbXIeIIItSbkwJiMZ9TI1NyqwaObOeBqqe73biwc2jw6nSGqSbrSiHOO4(PWSGDqWolmBtyN4A6XEu1f2dSJDv4ez0dqS9I9RykcNfb5H0av1bLFa0Dpi5Ln4e7lX4rm0qtSi1eiEoO0DaE5fe8rGextkX2l25sADnsikkU3HXc7peOEXa9e7loITbX(PeLn5Yf)kmeiX1KQGUcZc2bb7SWCUKwxJeIIItmF5i23fZFX(vmCweKxGrv4ebbESUIHgAIbzbeYarrV8tMW(Q3WQRiWeLhbIhbsCnPe7hX2l2VIHZIG8UDE4J(QdsvrzGvt2ywWoESUIHgAI5mXWzrqEUqYJuDKrpGhRRyOHMyNlP11iHOO4eZxoIXpX(PWKROhqH5WyH9hcuVyGELOS5gV4xHHajUMuf0vyYv0dOWCyPACCbS)qfgfDly7g9akmmyPACCbS)qIfJyqcbshMyoxduI9Tu(bq3jwcuIfJye4yHKyoiXwjqSvcH7eB2sqXsXqy1AXCUVvSgeJybgjgG4FigZWDXAeXCN7ACn9kmlyheSZcJIWzrqEinqvDq5haD3dsEzdoX(IJy8igAOj2AgTACaE3op8rF1bPQOmWEqYlBWj2xIXZgxS9IPiCweKhsduvhu(bq39GKx2GtSVeBnJwnoaVBNh(OV6Guvugypi5Ln4krztN6IFfgcK4AsvqxHzb7GGDwyWzrqEUeezGzqQ6wQb37IC9rmF5ig)eBVyRbOy745sqKbMbPQBPgCpyc(iMVCeJNVxyYv0dOWGspJhUovujkBYdVl(vyYv0dOWCyPACCbS)qfgcK4AsvqxjkBYdpf)kmeiX1KQGUcZc2bb7SW4mXIeIIIxFv85oX2l2A8WNQ70G4EkcPxDiMVCeJhX2lgolcY7WMO2GAGrvvc)8yDfBVyeGGO29I2JQXu3aVfZxXqTupVK)fMCf9akmlmkDRh2eLOefgfHKS6O4xztEk(vyYv0dOW8PxFkmeiX1KQGUsu2KRf)kmeiX1KQGUcZ4wyokkm5k6buy2MWoX1uHzBQzPcdolcY709IQjqvv9IESUIHgAIDUKwxJeIII7DySW(dbQxmqpX8LJyBuHrr3c2UrpGcdx8iLyXiMIcc61asmhyuGrqXwZOvJdWjMJSdXqgOymaUlgEEKsSbiwKquuCVcZ2ewbPhvyoGQUgGQJEaLOS53l(vyiqIRjvbDfMXTWCuuyYv0dOWSnHDIRPcZ2uZsfgxypWo2vHtKrpaX2l25sADnsikkU3HXc7peOEXa9eZxoIX1cJIUfSDJEafMngGENylSeGIedorg9aeRreZbjgwULeZf2dSJDv4ez0dqSJcXsGsmpwD0UAsSiHOO4eJ19vy2MWki9Ocd7rvxypWo2vHtKrpGsu2Cdf)kmeiX1KQGUcZ4wyokkm5k6buy2MWoX1uHzBQzPcdx5Ny(lwKAceVTnQb(iqIRjLyopX4kVfZFXIutG45LxqW6GupSunoUhbsCnPeZ5jgx5Ty(lwKAceVdlvJJkYSyVhbsCnPeZ5jgx5Ny(lwKAceVuNlyh7EeiX1KsmNNyCL3I5VyCLFI58e7xXoxsRRrcrrX9omwy)Ha1lgONy(YrSni2pfgfDly7g9akmCXJuIfJykcPbKyoWiGyXig7rIDbL6atmFW9tSbkgoBRve8kmBtyfKEuH5ck1bwnWG0HnAvjkBYVIFfgcK4AsvqxHrr3c2UrpGcJpWO1hX8b3pXYqmKgErHjxrpGcZk16AUIEavDFrHr3xubPhvywQReLn3OIFfgcK4AsvqxHrr3c2UrpGcJpXcedHvR3j25OJfgDIfJybgjgtqPoWiLy(0ez0dqSFX3jMAAakXUHpX6qmKbUOtm3z0naLynIyGjWAakX6tSCB26ext)8km5k6buyGSGAUIEavDFrHzb7GGDwyUGsDGrQxQ1fgDFrfKEuH5ck1bgPkrztUCXVcdbsCnPkORWKROhqH509IQjqvv9Ikmk6wW2n6buy41UU6DIXO7fjwcuIX9ErILHyC1FX8HtlMIf2auIfyKyin8cX4H3ID0AaQJpXsKGGIfyzi2g8xmF40I1iI1Hye)DBiDI5OdSgiwGrIbi(hIXL4dUl2afRpXatigRBHzb7GGDwyoxsRRrcrrX9omwy)Ha1lgONyFj2gj2EXqAuyrfsEzdoX8vSnsS9IHZIG8oDVOAcuvvVOhK8YgCI9LyOwQNxYFX2l2A8WNQ70G4eZxoITbX4fX(vSO9iX(smE4Ty)iMZtmUwIYMB8IFfgcK4AsvqxHrr3c2UrpGcJtd7b2XoX8PjYOhaxAIXfOGBNyO6TKyPyly6kwIpSHyeGGO2jgYaflWiXUGsDGjMp4(j2V4STwrqXUO1AXG05sRqSo(5jgx6SU8jwhITsGy4KybwgIDTNRMEfMCf9akmRuRR5k6bu19ffMfSdc2zHzBc7extp2JQUWEGDSRcNiJEafgDFrfKEuH5ck1bwDPUsu20PU4xHHajUMuf0vyu0TGTB0dOW4JbCTIGIXEnaLyPymbL6atmFWDXCGraXGuUWAakXcmsmcqqu7elWG0HnAvHjxrpGcZk16AUIEavDFrHzb7GGDwyiabrT7PiKE1HyFXrSTjStCn9UGsDGvdmiDyJwvy09fvq6rfMlOuhy1L6krztE4DXVcdbsCnPkORWSGDqWolm)kgHGqRO3s114Hpv3PbXjMVCeB5w9s(xpxcOe7hXqdnX(vS14Hpv3PbX9uesV6qSV4igpIHgAIH0OWIkK8YgCI9fhX4rS9Irii0k6TuDnE4t1DAqCI5lhX(UyOHMy4SiiVBNh(OV6Guvugy1KnMfSJhRRy7fJqqOv0BP6A8WNQ70G4eZxoITbX(rm0qtSFf7CjTUgjeff37WyH9hcuVyGEI5lhX2Gy7fJqqOv0BP6A8WNQ70G4eZxoITbX(PWKROhqHzLADnxrpGQUVOWO7lQG0JkminOpSsu2KhEk(vyiqIRjvbDfgfDly7g9akmCXJelfdNT1kckMdmcigKYfwdqjwGrIracIANybgKoSrRkm5k6buywPwxZv0dOQ7lkmlyheSZcdbiiQDpfH0Roe7loITnHDIRP3fuQdSAGbPdB0QcJUVOcspQWGZ2AvjkBYdxl(vyiqIRjvbDfMCf9akmjCLaQgdesGOWOOBbB3OhqHHlmoOleZf2dSJDI1aXsTwSbrSaJeJx70CbXWPvYEKyDi2kzp6elfJlXhCVWSGDqWolmeGGO29uesV6qmF5igp8tm)fJaee1UhKqrGsu2KNVx8RWKROhqHjHReqvxw9rfgcK4AsvqxjkBYZgk(vyYv0dOWOBuyXv3yzvO8iquyiqIRjvbDLOSjp8R4xHjxrpGcdEIQoi1a2RpxHHajUMuf0vIsuyCH0A8WZO4xztEk(vyYv0dOWKUU6Dv3PVbuyiqIRjvbDLOSjxl(vyYv0dOWGprOjvfrN7iLJgGQgd)BqHHajUMuf0vIYMFV4xHHajUMuf0vywWoiyNfMBy14nq9CzVGvtvcY6g9aEeiX1Ksm0qtSBy14nq92o6mAnvVrVLaXJajUMufMCf9akmiA6WwWejkrzZnu8RWKROhqH5ck1bwHHajUMuf0vIYM8R4xHHajUMuf0vyYv0dOW4LWpKQImWQIYaRW4cP14HNr9O1auxHHh(vIYMBuXVcdbsCnPkORWKROhqH509IQjqvv9IkmlyheSZcdKqG0HL4AQW4cP14HNr9O1auxHHNsu2Klx8RWqGextQc6kmlyheSZcdKfqidef98s4N6GudmQ6LxqWAExExdEeiX1KQWKROhqH5Ws14OIRtfDLOefgKg0hwXVYM8u8RWqGextQc6kmJBH5OOWKROhqHzBc7extfMTPMLkmrQjq8CHKhP6iJEapcK4Asj2EXoxsRRrcrrX9omwy)Ha1lgONyFj2VIXpX4fXwZwcKG4bOfC0duj2pITxmNj2A2sGeeVp7GDckmk6wW2n6buy(wSwtIXEnaLyonK8ivhz0dGpXYTtReBLx0auIXO7fjwcuIX9ErI5aJaIXGLQXHyCpblsS(e7MbiwmIHtIXEKIpXi(Vi3qmKbkMtHDWobfMTjScspQW4cjpsvpGQUgGQJEaLOSjxl(vyiqIRjvbDfMfSdc2zHXzITnHDIRPNlK8iv9aQ6AaQo6bi2EXoxsRRrcrrX9omwy)Ha1lgONyFj2gj2EXCMy4SiiVdlvJJQkbl6X6k2EXWzrqENUxunbQQQx0dsEzdoX(smKgfwuHKx2GtS9IbjeiDyjUMkm5k6buyoDVOAcuvvVOsu287f)kmeiX1KQGUcZc2bb7SWSnHDIRPNlK8iv9aQ6AaQo6bi2EXwZOvJdW7Ws14OQsWIElSeIIUkcmxrpGul2xIXZJlZpX2lgolcY709IQjqvv9IEqYlBWj2xITMrRghG3TZdF0xDqQkkdShK8YgCITxSFfBnJwnoaVdlvJJQkbl6bPuTtS9IHZIG8UDE4J(QdsvrzG9GKx2GtmErmCweK3HLQXrvLGf9GKx2GtSVeJNhxf7NctUIEafMt3lQMavv1lQeLn3qXVcdbsCnPkORWmUfMJIctUIEafMTjStCnvy2MAwQW4LxqWAExExdQqYlBWjMVIXBXqdnXCMyrQjq8ankS4Iu)HGpcK4Asj2EXIutG4Ps4N6HLQXXJajUMuITxmCweK3HLQXrvLGf9yDfdn0e7CjTUgjeff37WyH9hcuVyGEI5lhX(vm(jgVigKfqidef9qAqQ7y3JajUMuI9tHrr3c2UrpGcJtrs7sqXCQsyN4AsmKbkMpX6gSq6jgZN2vmflSbOeJxLxqqX413L31aXgOykwydqjg3tWIeZrhyIX9e(rSeOedmITzJclUi1Fi4RWSnHvq6rfM7t7wHSUblKkrzt(v8RWqGextQc6km5k6buyGSUblKkmk6wW2n6buyCkqKRySUI5tSUblKeRreRdX6tSeFydXIrmilqSHnEfMfSdc2zH5xXCMyBtyN4A6DFA3kK1nyHKyOHMyBtyN4A6XEu1f2dSJDv4ez0dqSFeBVyrcrrXlApQgtv1Ky8IyqYlBWjMVITrITxmiHaPdlX1ujkBUrf)km5k6buyoAbPOg0cd0oLSuHHajUMuf0vIYMC5IFfgcK4AsvqxHjxrpGcdK1nyHuHzTBPPAKquuCLn5PWSGDqWolmotSTjStCn9UpTBfY6gSqsS9I5mX2MWoX10J9OQlShyh7QWjYOhGy7f7CjTUgjeff37WyH9hcuVyGEI5lhX4Qy7flsikkEr7r1yQQMeZxoI9Ry8tm)f7xX4QyopXwJh(uDNgeNy)i2pITxmiHaPdlX1uHrr3c2UrpGcdVIvhTAIObOelsikkoXcSmeZrR1IP7TKyiduSaJetXcZOhGydIy(eRBWcj(edsiq6WetXcBakXCtGI861ReLn34f)kmeiX1KQGUctUIEafgiRBWcPcJIUfSDJEafgFIqG0HjMpX6gSqsmkH6DI1iI1HyoATwmI)UnKetXcBakXy25Hp67jg3hXcSmedsiq6WeRreJz4UyOO4edsPANynqSaJedq8peJF3RWSGDqWolmotSTjStCn9UpTBfY6gSqsS9IbjVSbNyFj2AgTACaE3op8rF1bPQOmWEqYlBWjM)IXdVfBVyRz0QXb4D78Wh9vhKQIYa7bjVSbNyFXrm(j2EXIeIIIx0EunMQQjX4fXGKx2GtmFfBnJwnoaVBNh(OV6Guvugypi5Ln4eZFX4xjkB6ux8RWqGextQc6kmlyheSZcJZeBBc7extp2JQUWEGDSRcNiJEaITxSZL06AKquuCI5lhX(EHjxrpGcdUoxFQUJdfblrztE4DXVctUIEafgABFlcMbvyiqIRjvbDLOefML6k(v2KNIFfgcK4AsvqxHzb7GGDwyCMy4SiiVdlvJJQkbl6X6k2EXWzrqEhglS)qGAmqqQMhRRy7fdNfb5DySW(dbQXabPAEqYlBWj2xCe77p(vyypQoiivulvztEkm5k6buyoSunoQQeSOcJIUfSDJEafgU4rIX9eSiXgeeEb1sjgoHmqsSaJedPHxi2HXc7peOEXa9edboEI53abPAeBnE0jwdELOSjxl(vyiqIRjvbDfMfSdc2zHbNfb5DySW(dbQXabPAESUITxmCweK3HXc7peOgdeKQ5bjVSbNyFXrSV)4xHH9O6GGurTuLn5PWKROhqH525Hp6RoivfLbwHrr3c2UrpGcZVCrGMUtSudPuTtmwxXWPvYEKyoiXIz(igdwQghI5CZI9(rm2JeJzNh(OpXgeeEb1sjgoHmqsSaJedPHxigdglS)qaXyIb6jgcC8eZVbcs1i2A8OtSg8krzZVx8RWqGextQc6kmlyheSZcZ2e2jUMEhqvxdq1rpaX2lMZe7ck1bgPEEji0Ky7f7xXCMyqwaHmqu0BWjvtGf9iqIRjLyOHMyRz0QXb4D78Wh9vhKQIYa7X6k2EXwJh(uDNgeNy(Yrm(j2pfMCf9akmi6efP1z0dOeLn3qXVcdbsCnPkORWSGDqWolm)kgKfqidef98s4N6GudmQ6LxqWAExExdEeiX1KsS9ITgp8P6oniUNIq6vhI9fhX4rmErSi1eiEkICjy9cygekY7rGextkXqdnXGSaczGOONIYatVREyPACCpcK4Asj2EXwJh(uDNgeNyFjgpI9Jy7fdNfb5D78Wh9vhKQIYa7X6k2EXWzrqEhwQghvvcw0J1vS9I5LxqWAExExdQqYlBWjghX4Ty7fdNfb5POmW07QhwQgh3tnoafMCf9akmBtqFyLOSj)k(vyiqIRjvbDfgfDly7g9akmo9mAXqgOy(nqqQgXCHeVWmCxmhDGjgdg3fdsPANyoWiGyGjedYcanaLymo3RWGmWkG4Fu2KNcZc2bb7SWePMaX7WyH9hcuJbcs18iqIRjLy7fZzIfPMaX7Ws14OIml27rGextQctUIEafg3z0viDdlCrLOS5gv8RWqGextQc6km5k6buyomwy)Ha1yGGunfgfDly7g9akmCXJeZVbcs1iMlKeJz4UyoWiGyoiXWYTKybgjgbiiQDI5aJcmckgcC8eZDgDdqjMJoWg2qmgNtSbk2gl7fIHIaem16DVcZc2bb7SWqacIANy(YrSnI3ITxSTjStCn9oGQUgGQJEaITxS1mA14a8UDE4J(QdsvrzG9yDfBVyRz0QXb4DyPACuvjyrVfwcrrNy(YrmEeBVy)kMZedYciKbIIEdoPAcSOhbsCnPedn0etr4SiipeDII06m6b8yDf7hX2l2A8WNQ70G4e7loIX1su2Klx8RWqGextQc6km5k6buyoccZGuv8bq1ZT)qfMfSdc2zHzBc7extVdOQRbO6OhGy7fZzIPM4DeeMbPQ4dGQNB)HQQjErV(0auITxSiHOO4fThvJPQAsmF5igx5rm0qtmKgfwuHKx2GtSV4ig)eBVyNlP11iHOO4EhglS)qG6fd0tSVe77fM1ULMQrcrrXv2KNsu2CJx8RWqGextQc6kmlyheSZcZ2e2jUMEhqvxdq1rpaX2l2A8WNQ70G4EkcPxDiMVCeJNctUIEafMJCV(krztN6IFfgcK4AsvqxHjxrpGcZTZdF0xDqQkkdScJIUfSDJEafgU4rIXSZdF0NydqS1mA14ai2VjsqqXqA4fIXa4(pIXc00DI5GelHKyOMgGsSyeZDCfZVbcs1iwcuIPgXatigwULeJblvJdXCUzXEVcZc2bb7SWSnHDIRP3bu11auD0dqS9I9RyrQjq8iWwspUnav9Ws144EeiX1Ksm0qtS1mA14a8oSunoQQeSO3clHOOtmF5igpI9Jy7f7xXCMyrQjq8omwy)Ha1yGGunpcK4AsjgAOjwKAceVdlvJJkYSyVhbsCnPedn0eBnJwnoaVdJf2FiqngiivZdsEzdoX8vmUk2pITxSFfZzIbzbeYarrVbNunbw0JajUMuIHgAITMrRghGhIorrADg9aEqYlBWjMVIXdVf7Nsu2KhEx8RWqGextQc6km5k6buy8s4hsvrgyvrzGvy0nGQlvHHNh)kmRDlnvJeIIIRSjpfMfSdc2zHbMTQsBjq8sL6ESUITxSFflsikkEr7r1yQQMe7lXwJh(uDNge3tri9QdXqdnXCMyxqPoWi1l1AX2l2A8WNQ70G4EkcPxDiMVCeB5w9s(xpxcOe7NcJIUfSDJEafgNpIyPsDILqsmwx(e7aTljwGrInasmhDGjMECqxiMF(X9NyCXJeZbgbetTRbOedjVGGIfyjqmF40IPiKE1HydumWeIDbL6aJuI5OdSHnelb7eZho9ReLn5HNIFfgcK4AsvqxHjxrpGcJxc)qQkYaRkkdScJIUfSDJEafgNpIyGrSuPoXC0ATyQMeZrhynqSaJedq8pe778(4tm2JeJxHWDXgGy4ZDI5OdSHnelb7eZho9RWSGDqWolmWSvvAlbIxQu3RbI5RyFN3IXlIbZwvPTeiEPsDpflmJEaITxS14Hpv3PbX9uesV6qmF5i2YT6L8VEUeqvIYM8W1IFfgcK4AsvqxHzb7GGDwy2MWoX107aQ6AaQo6bi2EXwJh(uDNge3tri9QdX8LJyCvS9I9RyRz0QXb4D78Wh9vhKQIYa7bjVSbNyFjgpIHgAIHZIG8UDE4J(QdsvrzG9yDfdn0edPrHfvi5Ln4e7loIXvEl2pfMCf9akmhwQghvCDQOReLn557f)kmeiX1KQGUcZc2bb7SWSnHDIRP3bu11auD0dqS9ITgp8P6oniUNIq6vhI5lhX4Qy7f7xX2MWoX10J9OQlShyh7QWjYOhGyOHMyNlP11iHOO4EhglS)qG6fd0tSV4i2gedn0edYciKbIIEq6gwGQbOQlDc7y3JajUMuI9tHjxrpGcdTWMgGQcjxy7LavjkBYZgk(vyiqIRjvbDfMCf9akmhglS)qGAmqqQMcJIUfSDJEafMVTdmXyCo(eRredmHyPgsPANyQbq8jg7rI53abPAeZrhyIXmCxmw3xHzb7GGDwyIutG4DyPACurMf79iqIRjLy7fBBc7extVdOQRbO6OhGy7fdNfb5D78Wh9vhKQIYa7X6k2EXwJh(uDNgeNyFXrmUwIYM8WVIFfgcK4AsvqxHzb7GGDwyCMy4SiiVdlvJJQkbl6X6k2EXqAuyrfsEzdoX(IJyBCX8xSi1eiEhlEqqewu0JajUMufMCf9akmhwQghvvcwujkBYZgv8RWqGextQc6kmlyheSZcZVIDdRgVbQNl7fSAQsqw3OhWJajUMuIHgAIDdRgVbQ32rNrRP6n6TeiEeiX1KsSFeBVyeGGO29uesV6qmF5i235Ty7fZzIDbL6aJuVuRfBVy4SiiVBNh(OV6Guvugyp14auyAqqqiRBuBKcZnSA8gOEBhDgTMQ3O3sGOW0GGGqw3O2EEKQZGkm8uyYv0dOWGOPdBbtKOW0GGGqw3OIsp4PUWWtjkBYdxU4xHHajUMuf0vywWoiyNfgCweKhUEgLM9IhKYvigAOjgsJclQqYlBWj2xI9DElgAOjgolcY725Hp6RoivfLb2J1vS9I9Ry4SiiVdlvJJkUov09yDfdn0eBnJwnoaVdlvJJkUov09GKx2GtSV4igp8wSFkm5k6buyCNOhqjkBYZgV4xHHajUMuf0vywWoiyNfgCweK3TZdF0xDqQkkdShRBHjxrpGcdUEgvfHfUReLn5XPU4xHHajUMuf0vywWoiyNfgCweK3TZdF0xDqQkkdShRBHjxrpGcdobpc(PbOkrztUY7IFfgcK4AsvqxHzb7GGDwyWzrqE3op8rF1bPQOmWESUfMCf9akminKW1ZOkrztUYtXVcdbsCnPkORWSGDqWolm4SiiVBNh(OV6Guvugypw3ctUIEafMeSOlGPUUsTUeLn5kxl(vyiqIRjvbDfMCf9akmShv7G8UcJIUfSDJEafgUtijRoedj1A8C9rmKbkg7L4AsSoiV7BeJlEKyo6atmMDE4J(eBqeJ7ugyVcZc2bb7SWGZIG8UDE4J(QdsvrzG9yDfdn0edPrHfvi5Ln4e7lX4kVlrjkmxqPoWQl1v8RSjpf)kmeiX1KQGUcZ4wyokkm5k6buy2MWoX1uHzBQzPcZAgTACaEhwQghvvcw0BHLqu0vrG5k6bKAX8LJy884Y8RWOOBbB3OhqHXPiPDjOyovjStCnvy2MWki9OcZHPQbgKoSrRkrztUw8RWqGextQc6km5k6buy2MG(Wkmk6wW2n6buyCQsqFyI1iI5GelHKyR01TbOeBaIX9eSiXwyjefDpX4sLq9oXWjKbsIH0WletLGfjwJiMdsmSCljgyeBZgfwCrQ)qqXWzdX4Ec)igdwQghI1aXgOIGIfJyOOqmFI1nyHKySUI9lyeJxLxqqX413L31GFEfMfSdc2zH5xXCMyBtyN4A6DyQAGbPdB0kXqdnXCMyrQjq8ankS4Iu)HGpcK4Asj2EXIutG4Ps4N6HLQXXJajUMuI9Jy7fBnE4t1DAqCpfH0RoeZxX4rS9I5mXGSaczGOONxc)uhKAGrvV8ccwZ7Y7AWJajUMuLOS53l(vyiqIRjvbDfgfDly7g9akmo9mAXqgOymyPAC4rALy(lgdwQghxa7pKySanDNyoiXsijwIpSHyXi2kDfBaIX9eSiXwyjefDpX2ya6DI5aJaI5Cnqj23s5haDNy9jwIpSHyXigKfi2WgVcdYaRaI)rztEkmlyheSZcdmx0d0OWIkPrkme)dywtVHfefMnW7ctUIEafg3z0viDdlCrLOS5gk(vyiqIRjvbDfMfSdc2zHHaee1oX8LJyBG3ITxmcqqu7EkcPxDiMVCeJhEl2EXCMyBtyN4A6DyQAGbPdB0kX2l2A8WNQ70G4EkcPxDiMVIXJy7ftr4SiipKgOQoO8dGU7bjVSbNyFjgpfMCf9akmhwQghEKwvIYM8R4xHHajUMuf0vyg3cZrrHjxrpGcZ2e2jUMkmBtnlvywJh(uDNge3tri9QdX8LJyCvm)fdNfb5DyPACuX1PIUhRBHrr3c2UrpGcJpCAXcmiDyJwDIHmqXiqqWgGsmgSunoeJ7jyrfMTjScspQWCyQ6A8WNQ70G4krzZnQ4xHHajUMuf0vyg3cZrrHjxrpGcZ2e2jUMkmBtnlvywJh(uDNge3tri9QdX8LJyFVWSGDqWolmRzlbsq8(Sd2jOWSnHvq6rfMdtvxJh(uDNgexjkBYLl(vyiqIRjvbDfMXTWCuuyYv0dOWSnHDIRPcZ2uZsfM14Hpv3PbX9uesV6qSV4igpfMfSdc2zHzBc7extp2JQUWEGDSRcNiJEaITxSZL06AKquuCVdJf2Fiq9Ib6jMVCeBdfMTjScspQWCyQ6A8WNQ70G4krzZnEXVcdbsCnPkORWKROhqH5Ws14OQsWIkmk6wW2n6buy4EcwKykwydqjgZop8rFInqXs8zljwGbPdB0QxHzb7GGDwy2MWoX107Wu114Hpv3PbXj2EX(vSTjStCn9omvnWG0HnALyOHMy4SiiVBNh(OV6Guvugypi5Ln4eZxoIXZJRIHgAIDUKwxJeIII7DySW(dbQxmqpX8LJyBqS9ITMrRghG3TZdF0xDqQkkdShK8YgCI5Ry8WBX(PeLnDQl(vyiqIRjvbDfMCf9akmhwQghvvcwuHrr3c2UrpGcd6yHaXGKx2GgGsmUNGfDIHtidKelWiXqAuyHyeqDI1iIXmCxmhdGBHy4Kyqkv7eRbIfTh9kmlyheSZcZ2e2jUMEhMQUgp8P6onioX2lgsJclQqYlBWj2xITMrRghG3TZdF0xDqQkkdShK8YgCLOefgC2wRk(v2KNIFfgcK4AsvqxHzb7GGDwyCMyrQjq8ankS4Iu)HGpcK4Asj2EXGSaczGOOx0GD1y4FVQ46urpcK4Asj2EXoxsRRrcrrX9omwy)Ha1lgONyFjg)km5k6buyoSEBjkBY1IFfgcK4AsvqxHzb7GGDwyoxsRRrcrrXjMVCeJRITxSFfZzITMTeibXdql4OhOsm0qtS1mA14a8occZGuv8bq1ZT)qpVK)1fwcrrNy8IylSeIIUkcmxrpGulMVCeJ3pUYpXqdnXoxsRRrcrrX9omwy)Ha1lgONy(k2ge7NctUIEafMdJf2Fiq9Ib6vIYMFV4xHHajUMuf0vywWoiyNfM1mA14a8occZGuv8bq1ZT)qpVK)1fwcrrNy8IylSeIIUkcmxrpGul2xCeJ3pUYpXqdnXUHvJ3a1ttPQIVRs8p9C10JajUMuITxmNjgolcYttPQIVRs8p9C10J1TWKROhqH5iimdsvXhavp3(dvIYMBO4xHjxrpGcdk9mE46urfgcK4AsvqxjkBYVIFfMCf9akm456ZfjEHHajUMuf0vIsuIcZwcE9akBYvEZvE4nxM3FVW4iHGgG6kmFlV2N205VjxY3iMy(HrI1EUdmedzGIXTlOuhyKIBIbjNs2gskXUXJelzJXldsj2clbOO7j)5cnGeBdFJy(yaBjyqkX4gKfqidef98zUjwmIXnilGqgik65ZpcK4AsXnX(Lh()Zt(ZfAajgx(BeZhdylbdsjg3GSaczGOONpZnXIrmUbzbeYarrpF(rGextkUj2V8W)FEYF5)3YR9PnD(BYL8nIjMFyKyTN7adXqgOyCZfsRXdpdUjgKCkzBiPe7gpsSKngVmiLylSeGIUN8Nl0asSV)nI5JbSLGbPeJB3WQXBG65ZCtSyeJB3WQXBG65ZpcK4AsXnX(Lh()Zt(ZfAaj23)gX8Xa2sWGuIXTBy14nq98zUjwmIXTBy14nq985hbsCnP4MyzigxQngUGy)Yd))5j)5cnGeJl)nI5JbSLGbPeJBqwaHmqu0ZN5MyXig3GSaczGOONp)iqIRjf3eldX4sTXWfe7xE4)pp5V8)B51(0Mo)n5s(gXeZpmsS2ZDGHyidumUH0G(W4MyqYPKTHKsSB8iXs2y8YGuITWsak6EYFUqdiX2W3iMpgWwcgKsmUbzbeYarrpFMBIfJyCdYciKbIIE(8JajUMuCtSF5H))8K)Y)VLx7tB683Kl5Betm)WiXAp3bgIHmqX42sDCtmi5uY2qsj2nEKyjBmEzqkXwyjafDp5pxObKyF)BeZhdylbdsjg3GSaczGOONpZnXIrmUbzbeYarrpF(rGextkUj2V8W)FEYFUqdiX2W3iMpgWwcgKsmUbzbeYarrpFMBIfJyCdYciKbIIE(8JajUMuCtSF5k))5j)5cnGeBJ(gX8Xa2sWGuIXnilGqgik65ZCtSyeJBqwaHmqu0ZNFeiX1KIBI9lp8)NN8Nl0asmN6VrmFmGTemiLyCdYciKbIIE(m3elgX4gKfqidef985hbsCnP4My)Yd))5j)5cnGeJNV)nI5JbSLGbPeJBqwaHmqu0ZN5MyXig3GSaczGOONp)iqIRjf3e7xE4)pp5pxObKy8SrFJy(yaBjyqkX42nSA8gOE(m3elgX42nSA8gOE(8JajUMuCtSF5k))5j)L)FlV2N205VjxY3iMy(HrI1EUdmedzGIXTlOuhy1L64MyqYPKTHKsSB8iXs2y8YGuITWsak6EYFUqdiX463iMpgWwcgKsmUbzbeYarrpFMBIfJyCdYciKbIIE(8JajUMuCtSmeJl1gdxqSF5H))8K)Y)VLx7tB683Kl5Betm)WiXAp3bgIHmqX4goBRvCtmi5uY2qsj2nEKyjBmEzqkXwyjafDp5pxObKy88nI5JbSLGbPeJBqwaHmqu0ZN5MyXig3GSaczGOONp)iqIRjf3e7xE4)pp5V83575oWGuIXLflxrpaX09f3t(xyCHdsRPcJtCIymS4HMIDI5tdkws(7eNi2Fw9oX4hFIXvEZvEK)YFN4eX8bwcqr33i)DIteJxeJxnBjX2MWoX10J9OQlShyh7QWjYOhGySUIDJyDiwFIDuigoHmqsmhKyShjwhp5VtCIy8Iy(y8WBajMhRoAxnj2k16AUIEavDFHyeiGnDIfJyqsXUiXCNGarNAXGKJb(5j)DIteJxeJxLFiXConDylyIeI1GGGqw3qSgi2A8WZqSgrmhKyBSSxiMQvI1HyiduSTJoJwt1B0Bjq8K)YFN4eXCAiXl(y8WZq(NROhW9CH0A8WZWFoOpDD17QUtFdq(NROhW9CH0A8WZWFoOhFIqtQkIo3rkhnavng(3a5FUIEa3ZfsRXdpd)5GEenDylyIe81iCUHvJ3a1ZL9cwnvjiRB0dan0UHvJ3a1B7OZO1u9g9wceY)Cf9aUNlKwJhEg(Zb9xqPoWK)5k6bCpxiTgp8m8Nd69s4hsvrgyvrzGXNlKwJhEg1JwdqDC4HFY)Cf9aUNlKwJhEg(Zb9NUxunbQQQxeFUqAnE4zupAna1XHh(AeoqcbshwIRj5FUIEa3ZfsRXdpd)5G(dlvJJkUov0XxJWbYciKbIIEEj8tDqQbgv9YliynVlVRbYF5VtCIy8QSbI5ttKrpa5FUIEahNp96J83jIXfpsjwmIPOGGEnGeZbgfyeuS1mA14aCI5i7qmKbkgdG7IHNhPeBaIfjeff3t(NROhW5ph0VnHDIRj(aPhX5aQ6AaQo6bW32uZsCWzrqENUxunbQQQx0J1fn0oxsRRrcrrX9omwy)Ha1lgONVC2i5VteBJbO3j2clbOiXGtKrpaXAeXCqIHLBjXCH9a7yxforg9ae7OqSeOeZJvhTRMelsikkoXyDFY)Cf9ao)5G(TjStCnXhi9ioShvDH9a7yxforg9a4BBQzjoUWEGDSRcNiJEa7pxsRRrcrrX9omwy)Ha1lgONVC4Q83jIXfpsjwmIPiKgqI5aJaIfJyShj2fuQdmX8b3pXgOy4STwrWt(NROhW5ph0VnHDIRj(aPhX5ck1bwnWG0HnAfFBtnlXHR8Z)i1eiEBBud8rGextkNhx5T)rQjq88YliyDqQhwQgh3JajUMuopUYB)JutG4DyPACurMf79iqIRjLZJR8Z)i1eiEPoxWo29iqIRjLZJR82FUYpN3VNlP11iHOO4EhglS)qG6fd0ZxoB4h5VteZhy06Jy(G7NyzigsdVq(NROhW5ph0VsTUMROhqv3xWhi9iol1j)DIy(elqmewTENyNJowy0jwmIfyKymbL6aJuI5ttKrpaX(fFNyQPbOe7g(eRdXqg4IoXCNr3auI1iIbMaRbOeRpXYTzRtCn9Zt(NROhW5ph0dzb1Cf9aQ6(c(aPhX5ck1bgP4Rr4CbL6aJuVuRL)ormETRRENym6ErILaLyCVxKyzigx9xmF40IPyHnaLybgjgsdVqmE4TyhTgG64tSejiOybwgITb)fZhoTynIyDigXF3gsNyo6aRbIfyKyaI)HyCj(G7InqX6tmWeIX6k)Zv0d48Nd6pDVOAcuvvVi(AeoNlP11iHOO4EhglS)qG6fd07RnApsJclQqYlBW57gThNfb5D6Er1eOQQErpi5Ln4(c1s98s(VFnE4t1DAqC(Yzd8YVr7rFXdV)X5Xv5VteZPH9a7yNy(0ez0dGlnX4cuWTtmu9wsSuSfmDflXh2qmcqqu7edzGIfyKyxqPoWeZhC)e7xC2wRiOyx0ATyq6CPviwh)8eJlDwx(eRdXwjqmCsSaldXU2Zvtp5FUIEaN)Cq)k16AUIEavDFbFG0J4CbL6aRUuhFncNTjStCn9ypQ6c7b2XUkCIm6bi)DIy(yaxRiOySxdqjwkgtqPoWeZhCxmhyeqmiLlSgGsSaJeJaee1oXcmiDyJwj)Zv0d48Nd6xPwxZv0dOQ7l4dKEeNlOuhy1L64Rr4qacIA3tri9QJV4SnHDIRP3fuQdSAGbPdB0k5FUIEaN)Cq)k16AUIEavDFbFG0J4G0G(W4Rr48lHGqRO3s114Hpv3PbX5lNLB1l5F9CjG6h0q7314Hpv3PbX9uesV64lo8GgAinkSOcjVSb3xC4zpHGqRO3s114Hpv3PbX5lNVJgA4SiiVBNh(OV6Guvugy1KnMfSJhR7EcbHwrVLQRXdFQUtdIZxoB4h0q73ZL06AKquuCVdJf2Fiq9Ib65lNnSNqqOv0BP6A8WNQ70G48LZg(r(7eX4IhjwkgoBRveumhyeqmiLlSgGsSaJeJaee1oXcmiDyJwj)Zv0d48Nd6xPwxZv0dOQ7l4dKEehC2wR4Rr4qacIA3tri9QJV4SnHDIRP3fuQdSAGbPdB0k5VteJlmoOleZf2dSJDI1aXsTwSbrSaJeJx70CbXWPvYEKyDi2kzp6elfJlXhCx(NROhW5ph0NWvcOAmqibc(AeoeGGO29uesV6Wxo8Wp)jabrT7bjueq(NROhW5ph0NWvcOQlR(i5FUIEaN)CqVUrHfxDJLvHYJaH8pxrpGZFoOhprvhKAa71Nt(l)DItedDSTwrWt(NROhW9WzBTIZH1B5Rr44Si1eiEGgfwCrQ)qWhbsCnP2dzbeYarrVOb7QXW)EvX1PI2FUKwxJeIII7DySW(dbQxmqVV4N8pxrpG7HZ2AL)Cq)HXc7peOEXa94Rr4CUKwxJeIIIZxoCD)VoBnBjqcIhGwWrpqfAOTMrRghG3rqygKQIpaQEU9h65L8VUWsik64LfwcrrxfbMROhqQ9LdVFCLFOH25sADnsikkU3HXc7peOEXa98Dd)i)Zv0d4E4STw5ph0FeeMbPQ4dGQNB)H4Rr4SMrRghG3rqygKQIpaQEU9h65L8VUWsik64LfwcrrxfbMROhqQ)IdVFCLFOH2nSA8gOEAkvv8DvI)PNRMEeiX1KAVZWzrqEAkvv8DvI)PNRMESUY)Cf9aUhoBRv(Zb9O0Z4HRtfj)Zv0d4E4STw5ph0JNRpxK4YF5VtCIy(ygTACao5VteJlEKyCpblsSbbHxqTuIHtidKelWiXqA4fIDySW(dbQxmqpXqGJNy(nqqQgXwJhDI1GN8pxrpG7TuhNdlvJJQkblIp2JQdcsf1sXHh(AeoodNfb5DyPACuvjyrpw394SiiVdJf2FiqngiivZJ1DpolcY7WyH9hcuJbcs18GKx2G7loF)Xp5Vte7xUiqt3jwQHuQ2jgRRy40kzpsmhKyXmFeJblvJdXCUzXE)ig7rIXSZdF0NydccVGAPedNqgijwGrIH0WleJbJf2FiGymXa9edboEI53abPAeBnE0jwdEY)Cf9aU3sD(Zb93op8rF1bPQOmW4J9O6GGurTuC4HVgHdolcY7WyH9hcuJbcs18yD3JZIG8omwy)Ha1yGGunpi5Ln4(IZ3F8t(NROhW9wQZFoOhrNOiToJEa81iC2MWoX107aQ6AaQo6bS3zxqPoWi1ZlbHM2)RZGSaczGOO3GtQMalcn0wZOvJdW725Hp6RoivfLb2J1D)A8WNQ70G48Ld)(r(NROhW9wQZFoOFBc6dJVgHZVqwaHmqu0ZlHFQdsnWOQxEbbR5D5Dny)A8WNQ70G4EkcPxD8fhE4Li1eiEkICjy9cygekY7rGextk0qdYciKbIIEkkdm9U6HLQXXTFnE4t1DAqCFXZp7XzrqE3op8rF1bPQOmWESU7XzrqEhwQghvvcw0J1DVxEbbR5D5DnOcjVSbhhEVhNfb5POmW07QhwQgh3tnoaYFNiMtpJwmKbkMFdeKQrmxiXlmd3fZrhyIXGXDXGuQ2jMdmcigycXGSaqdqjgJZ9K)5k6bCVL68Nd6DNrxH0nSWfXhYaRaI)bhE4Rr4ePMaX7WyH9hcuJbcs18iqIRj1ENfPMaX7Ws14OIml27rGextk5VteJlEKy(nqqQgXCHKymd3fZbgbeZbjgwULelWiXiabrTtmhyuGrqXqGJNyUZOBakXC0b2WgIX4CInqX2yzVqmueGGPwV7j)Zv0d4El15ph0FySW(dbQXabPA4Rr4qacIANVC2iEVFBc7extVdOQRbO6OhW(1mA14a8UDE4J(QdsvrzG9yD3VMrRghG3HLQXrvLGf9wyjefD(YHN9)6milGqgik6n4KQjWIqdnfHZIG8q0jksRZOhWJ19N9RXdFQUtdI7loCv(NROhW9wQZFoO)iimdsvXhavp3(dX3A3st1iHOO44WdFncNTjStCn9oGQUgGQJEa7DMAI3rqygKQIpaQEU9hQQM4f96tdqTpsikkEr7r1yQQM8Ldx5bn0qAuyrfsEzdUV4WV9NlP11iHOO4EhglS)qG6fd07RVl)Zv0d4El15ph0FK71hFncNTjStCn9oGQUgGQJEa7xJh(uDNge3tri9QdF5WJ83jIXfpsmMDE4J(eBaITMrRghaX(nrcckgsdVqmga3)rmwGMUtmhKyjKed10auIfJyUJRy(nqqQgXsGsm1igycXWYTKymyPACiMZnl27j)Zv0d4El15ph0F78Wh9vhKQIYaJVgHZ2e2jUMEhqvxdq1rpG9)gPMaXJaBj942au1dlvJJ7rGextk0qBnJwnoaVdlvJJQkbl6TWsik68Ldp)S)xNfPMaX7WyH9hcuJbcs18iqIRjfAOfPMaX7Ws14OIml27rGextk0qBnJwnoaVdJf2FiqngiivZdsEzdoF56p7)1zqwaHmqu0BWjvtGfHgARz0QXb4HOtuKwNrpGhK8YgC(YdV)r(7eXC(iILk1jwcjXyD5tSd0UKybgj2aiXC0bMy6XbDHy(5h3FIXfpsmhyeqm1UgGsmK8cckwGLaX8HtlMIq6vhInqXati2fuQdmsjMJoWg2qSeStmF40p5FUIEa3BPo)5GEVe(HuvKbwvugy8PBavxko884hFRDlnvJeIIIJdp81iCGzRQ0wceVuPUhR7(FJeIIIx0EunMQQPVwJh(uDNge3tri9Qd0qZzxqPoWi1l169RXdFQUtdI7PiKE1HVCwUvVK)1ZLaQFK)ormNpIyGrSuPoXC0ATyQMeZrhynqSaJedq8pe778(4tm2JeJxHWDXgGy4ZDI5OdSHnelb7eZho9t(NROhW9wQZFoO3lHFivfzGvfLbgFnchy2QkTLaXlvQ71aF)oV5fy2QkTLaXlvQ7PyHz0dy)A8WNQ70G4EkcPxD4lNLB1l5F9CjGs(NROhW9wQZFoO)Ws14OIRtfD81iC2MWoX107aQ6AaQo6bSFnE4t1DAqCpfH0Ro8Ldx3)7AgTACaE3op8rF1bPQOmWEqYlBW9fpOHgolcY725Hp6RoivfLb2J1fn0qAuyrfsEzdUV4WvE)J8pxrpG7TuN)CqpTWMgGQcjxy7LafFncNTjStCn9oGQUgGQJEa7xJh(uDNge3tri9QdF5W19)UnHDIRPh7rvxypWo2vHtKrpa0q7CjTUgjeff37WyH9hcuVyGEFXzdOHgKfqidef9G0nSavdqvx6e2XUFK)orSVTdmXyCo(eRredmHyPgsPANyQbq8jg7rI53abPAeZrhyIXmCxmw3N8pxrpG7TuN)Cq)HXc7peOgdeKQHVgHtKAceVdlvJJkYSyVhbsCnP2VnHDIRP3bu11auD0dypolcY725Hp6RoivfLb2J1D)A8WNQ70G4(IdxL)5k6bCVL68Nd6pSunoQQeSi(AeoodNfb5DyPACuvjyrpw39inkSOcjVSb3xC24(hPMaX7yXdcIWIIEeiX1Ks(NROhW9wQZFoOhrth2cMibFncNFVHvJ3a1ZL9cwnvjiRB0dan0UHvJ3a1B7OZO1u9g9wce)SNaee1UNIq6vh(Y578EVZUGsDGrQxQ17XzrqE3op8rF1bPQOmWEQXbGVgeeeY6g12ZJuDgehE4RbbbHSUrfLEWtnhE4RbbbHSUrTr4CdRgVbQ32rNrRP6n6TeiK)5k6bCVL68Nd6DNOhaFnchCweKhUEgLM9IhKYvGgAinkSOcjVSb3xFN3OHgolcY725Hp6RoivfLb2J1D)V4SiiVdlvJJkUov09yDrdT1mA14a8oSunoQ46ur3dsEzdUV4WdV)r(NROhW9wQZFoOhxpJQIWc3XxJWbNfb5D78Wh9vhKQIYa7X6k)Zv0d4El15ph0JtWJGFAak(Aeo4SiiVBNh(OV6Guvugypwx5FUIEa3BPo)5GEKgs46zu81iCWzrqE3op8rF1bPQOmWESUY)Cf9aU3sD(Zb9jyrxatDDLAnFnchCweK3TZdF0xDqQkkdShRR83jIXDcjz1HyiPwJNRpIHmqXyVextI1b5DFJyCXJeZrhyIXSZdF0NydIyCNYa7j)Zv0d4El15ph0ZEuTdY74Rr4GZIG8UDE4J(QdsvrzG9yDrdnKgfwuHKx2G7lUYB5V83jormNRb9HrWt(7eX(wSwtIXEnaLyonK8ivhz0dGpXYTtReBLx0auIXO7fjwcuIX9ErI5aJaIXGLQXHyCpblsS(e7MbiwmIHtIXEKIpXi(Vi3qmKbkMtHDWobY)Cf9aUhsd6dJZ2e2jUM4dKEehxi5rQ6bu11auD0dGVTPML4ePMaXZfsEKQJm6b8iqIRj1(ZL06AKquuCVdJf2Fiq9Ib691V8JxwZwcKG4bOfC0du9ZENTMTeibX7ZoyNa5FUIEa3dPb9H5ph0F6Er1eOQQEr81iCC22e2jUMEUqYJu1dOQRbO6OhW(ZL06AKquuCVdJf2Fiq9Ib691gT3z4SiiVdlvJJQkbl6X6UhNfb5D6Er1eOQQErpi5Ln4(cPrHfvi5Ln42djeiDyjUMK)5k6bCpKg0hM)Cq)P7fvtGQQ6fXxJWzBc7extpxi5rQ6bu11auD0dy)AgTACaEhwQghvvcw0BHLqu0vrG5k6bK6V45XL53ECweK3P7fvtGQQ6f9GKx2G7R1mA14a8UDE4J(QdsvrzG9GKx2GB)VRz0QXb4DyPACuvjyrpiLQD7XzrqE3op8rF1bPQOmWEqYlBWXl4SiiVdlvJJQkbl6bjVSb3x8846pYFNiMtrs7sqXCQsyN4AsmKbkMpX6gSq6jgZN2vmflSbOeJxLxqqX413L31aXgOykwydqjg3tWIeZrhyIX9e(rSeOedmITzJclUi1Fi4t(NROhW9qAqFy(Zb9BtyN4AIpq6rCUpTBfY6gSqIVTPML44LxqWAExExdQqYlBW5lVrdnNfPMaXd0OWIls9hc(iqIRj1(i1eiEQe(PEyPAC8iqIRj1ECweK3HLQXrvLGf9yDrdTZL06AKquuCVdJf2Fiq9Ib65lNF5hVazbeYarrpKgK6o29J83jI5uGixXyDfZNyDdwijwJiwhI1Nyj(WgIfJyqwGydB8K)5k6bCpKg0hM)CqpK1nyHeFncNFD22e2jUME3N2TczDdwiHgABtyN4A6XEu1f2dSJDv4ez0d4N9rcrrXlApQgtv1eVajVSbNVB0EiHaPdlX1K8pxrpG7H0G(W8Nd6pAbPOg0cd0oLSK83jIXRy1rRMiAakXIeIIItSaldXC0ATy6EljgYaflWiXuSWm6bi2GiMpX6gSqIpXGecKomXuSWgGsm3eOiVE9K)5k6bCpKg0hM)CqpK1nyHeFRDlnvJeIIIJdp81iCC22e2jUME3N2TczDdwiT3zBtyN4A6XEu1f2dSJDv4ez0dy)5sADnsikkU3HXc7peOEXa98Ldx3hjeffVO9OAmvvt(Y5x(5)VC15Tgp8P6oniUF(zpKqG0HL4As(7eX8jcbshMy(eRBWcjXOeQ3jwJiwhI5O1AXi(72qsmflSbOeJzNh(OVNyCFelWYqmiHaPdtSgrmMH7IHIItmiLQDI1aXcmsmaX)qm(Dp5FUIEa3dPb9H5ph0dzDdwiXxJWXzBtyN4A6DFA3kK1nyH0Ei5Ln4(AnJwnoaVBNh(OV6Guvugypi5Ln48NhEVFnJwnoaVBNh(OV6Guvugypi5Ln4(Id)2hjeffVO9OAmvvt8cK8YgC(UMrRghG3TZdF0xDqQkkdShK8YgC(Zp5FUIEa3dPb9H5ph0JRZ1NQ74qrq(AeooBBc7extp2JQUWEGDSRcNiJEa7pxsRRrcrrX5lNVl)Zv0d4EinOpm)5GEABFlcMbj)L)oXjIXeuQdmX8XmA14aCYFNiMtrs7sqXCQsyN4As(NROhW9UGsDGvxQJZ2e2jUM4dKEeNdtvdmiDyJwX32uZsCwZOvJdW7Ws14OQsWIElSeIIUkcmxrpGu7lhEECz(j)DIyovjOpmXAeXCqILqsSv662auInaX4EcwKylSeIIUNyCPsOENy4eYajXqA4fIPsWIeRreZbjgwULedmITzJclUi1FiOy4SHyCpHFeJblvJdXAGydurqXIrmuuiMpX6gSqsmwxX(fmIXRYliOy867Y7AWpp5FUIEa37ck1bwDPo)5G(TjOpm(Aeo)6STjStCn9omvnWG0HnAfAO5Si1eiEGgfwCrQ)qWhbsCnP2hPMaXtLWp1dlvJJhbsCnP(z)A8WNQ70G4EkcPxD4lp7DgKfqidef98s4N6GudmQ6LxqWAExExdK)ormNEgTyidumgSuno8iTsm)fJblvJJlG9hsmwGMUtmhKyjKelXh2qSyeBLUInaX4EcwKylSeIIUNyBma9oXCGraXCUgOe7BP8dGUtS(elXh2qSyedYceByJN8pxrpG7DbL6aRUuN)CqV7m6kKUHfUi(qgyfq8p4WdFe)dywtVHfeC2aV5Rr4aZf9ankSOsAe5FUIEa37ck1bwDPo)5G(dlvJdpsR4Rr4qacIANVC2aV3tacIA3tri9QdF5WdV37STjStCn9omvnWG0HnA1(14Hpv3PbX9uesV6WxE2RiCweKhsduvhu(bq39GKx2G7lEK)ormF40Ifyq6WgT6edzGIrGGGnaLymyPACig3tWIK)5k6bCVlOuhy1L68Nd63MWoX1eFG0J4CyQ6A8WNQ70G44BBQzjoRXdFQUtdI7PiKE1HVC4Q)4SiiVdlvJJkUov09yDL)5k6bCVlOuhy1L68Nd63MWoX1eFG0J4CyQ6A8WNQ70G44BBQzjoRXdFQUtdI7PiKE1HVC(oFncN1SLajiEF2b7ei)Zv0d4ExqPoWQl15ph0VnHDIRj(aPhX5Wu114Hpv3PbXX32uZsCwJh(uDNge3tri9QJV4WdFncNTjStCn9ypQ6c7b2XUkCIm6bS)CjTUgjeff37WyH9hcuVyGE(YzdYFNig3tWIetXcBakXy25Hp6tSbkwIpBjXcmiDyJw9K)5k6bCVlOuhy1L68Nd6pSunoQQeSi(AeoBtyN4A6DyQ6A8WNQ70G42)72e2jUMEhMQgyq6WgTcn0WzrqE3op8rF1bPQOmWEqYlBW5lhEECfn0oxsRRrcrrX9omwy)Ha1lgONVC2W(1mA14a8UDE4J(QdsvrzG9GKx2GZxE49pYFNig6yHaXGKx2GgGsmUNGfDIHtidKelWiXqAuyHyeqDI1iIXmCxmhdGBHy4Kyqkv7eRbIfTh9K)5k6bCVlOuhy1L68Nd6pSunoQQeSi(AeoBtyN4A6DyQ6A8WNQ70G42J0OWIkK8YgCFTMrRghG3TZdF0xDqQkkdShK8YgCYF5VtCIymbL6aJuI5ttKrpa5VteZ5JigtqPoWq)2e0hMyjKeJ1LpXypsmgSunoUa2FiXIrmCcqiDigcC8elWiXCZ76TKy4dG9elbkXCUgOe7BP8dGUJpXOTeqSgrmhKyjKeldX8s(lMpCAX(LfOP7eJ9AakX4v5feumE9D5Dn4h5FUIEa37ck1bgP4CyPACCbS)q81iC(fNfb5DbL6a7X6IgA4SiiVTjOpShR7p79YliynVlVRbvi5Ln44WB5VteZ5AqFyILHyF3FX8HtlMJoWg2qmUZig6fBd(lMJoWeJ7mI5OdmXyWyH9hciMFdeKQrmCweeXyDflgXYTtRe7gpsmF40I5iVGe76GnJEa3t(7eX416Be7sesSyedPb9HjwgITb)fZhoTyo6atmI)5k07eBdIfjeff3tSFzspsS8eByJRvKyxqPoWE)i)DIyoxd6dtSmeBd(lMpCAXC0b2WgIXDg(eJF(lMJoWeJ7m8jwcuITrI5OdmX4oJyjsqqXCQsqFyY)Cf9aU3fuQdms5ph0VsTUMROhqv3xWhi9ioinOpm(AeoeccTIElvxJh(uDNgeNVCwUvVK)1ZLak0qdNfb5DySW(dbQXabPAESU7xJh(uDNge3tri9QJV4Wv0q7CjTUgjeff37WyH9hcuVyGE(Yzd7jeeAf9wQUgp8P6onioF5Sb0qBnE4t1DAqCpfH0Ro(Idp8YVrQjq8ue5sW6fWmsuK3JajUMu7XzrqEBtqFypw3FK)5k6bCVlOuhyKYFoO)Ws144cy)H4Rr4CbL6aJuVJCV(2FUKwxJeIII7DySW(dbQxmqVV2G8pxrpG7DbL6aJu(Zb9hwVLVgHtKAcepqJclUi1Fi4JajUMu7HSaczGOOx0GD1y4FVQ46ur7pxsRRrcrrX9omwy)Ha1lgO3x8t(7eX4IUIfJyFxSiHOO4e7xWiMlSNFe7drUIX6kMZ1aLyFlLFa0DIHVtS1ULUbOeJblvJJlG9h6j)Zv0d4ExqPoWiL)Cq)HLQXXfW(dX3A3st1iHOO44WdFnchNTnHDIRPh7rvxypWo2vHtKrpG9kcNfb5H0av1bLFa0Dpi5Ln4(IN9NlP11iHOO4EhglS)qG6fd07loFFFKquu8I2JQXuvnXlqYlBW57gj)DIyo3afZf2dSJDIbNiJEa8jg7rIXGLQXXfW(dj2SLGIXed0tmhDGj23YRelrLn4cXyDflgX2GyrcrrXj2afRreZ5(wX6tmila0auIniiI97aelb7el9gwqi2GiwKquuC)i)Zv0d4ExqPoWiL)Cq)HLQXXfW(dXxJWzBc7extp2JQUWEGDSRcNiJEa7)vr4SiipKgOQoO8dGU7bjVSb3x8GgArQjq8CqP7a8Yli4JajUMu7pxsRRrcrrX9omwy)Ha1lgO3xC2WpY)Cf9aU3fuQdms5ph0FySW(dbQxmqp(AeoNlP11iHOO48LZ39)xCweKxGrv4ebbESUOHgKfqidef9Ypzc7REdRUIatuEei(z)V4SiiVBNh(OV6Guvugy1KnMfSJhRlAO5mCweKNlK8ivhz0d4X6IgANlP11iHOO48Ld)(r(7eXyWs144cy)HelgXGecKomXCUgOe7BP8dGUtSeOelgXiWXcjXCqITsGyRec3j2SLGILIHWQ1I5CFRynigXcmsmaX)qmMH7I1iI5o314A6j)Zv0d4ExqPoWiL)Cq)HLQXXfW(dXxJWrr4SiipKgOQoO8dGU7bjVSb3xC4bn0wZOvJdW725Hp6RoivfLb2dsEzdUV4zJVxr4SiipKgOQoO8dGU7bjVSb3xRz0QXb4D78Wh9vhKQIYa7bjVSbN8pxrpG7DbL6aJu(Zb9O0Z4HRtfXxJWbNfb55sqKbMbPQBPgCVlY1hF5WV9RbOy745sqKbMbPQBPgCpyc(4lhE(U8pxrpG7DbL6aJu(Zb9hwQghxa7pK8pxrpG7DbL6aJu(Zb9lmkDRh2e81iCCwKquu86RIp3TFnE4t1DAqCpfH0Ro8Ldp7XzrqEh2e1gudmQQs4NhR7Ecqqu7Er7r1yQBG3(IAPEEj)lmNlTkBY1nINsuIsba]] )

    
end
