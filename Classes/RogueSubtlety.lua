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


    spec:RegisterPack( "Subtlety", 20210706, [[dafZ(bqiuv1JOI0Mus(eQugLkPoLkfRsjGEfvvnluvUfQsSlv8livnmuL6yOkwgQKEMkjnnQk5AOQY2OIsFdvIACQKqNJkkQ1PeuZtLs3dvSpQk(hQePCquLulesLhsvPMiQuDrujs2ivu1hrLigjvuGtQeGvcP8sQOGMjQeCtuLKDQe6NQKadLkQSuLG8uuAQuv5QOsOTsff6RQKOXQeOZIkrQ2Re)vsdMYHfTyO8yLAYKCzKndXNHKrJItl1Qvjb9AvIztQBtv2nWVvmCQ0XPIISCqpxvtx46q12vI(ovy8urCELuZxLQ9tCHNIFfwvguzrUYBUYdV5Y82zp8C1REv(DflSXAxQW6M7ljkQWcspQWYIJfAkwxyDZ16jvf)kS)Gd3uHLjc3FHrp6r1bdo2zpEO)BpCDg9a2Wejq)3EB0xyXWBDSaafScRkdQSix5nx5H3CzE7ShEU6vVk)4Yf2epygyHLT98DHLPvkcuWkSk63fwwCSqtXAXwObfojOHgUETyolFIXvEZvEe0e08ntcqr)clOXlIXRMLKyltyNyA6G)u1f2dSJ1v4ez0dqmCxX(rSoeRFXEkedJqgijMdsm8NeRJJGgViMVhpSgqI5HRJ2vtITtTUM7Ohqv3FigbcytVyXigKu4Bsm3jiq0Pwmi5yGxocA8Iy8Q8cjMZRPNzdtKqSgeeeI7gI1aX2JhwgI1iI5Ge7ke)dXuTsSoedzGITC0z0AQ(JEjbItHv3F8f)kSFqPoyivXVYI8u8RWsGettQc6kS5o6buyFMuno(a2xOcRI(nSDJEaf2faIySbL6Gb9ltq)mILqsmCx(ed)jXyzs144dyFHelgXWiaH0HyiWXtSGHeZn)VxsIHna8xSeOeZ5BGsSRKYla6F(eJwsaXAeXCqILqsSmeZlDIy(25e7ACGM(xm8VbOeJxLFqqX41)N)3GBkSByheSZc71IHHJGC(GsDWCWDf7(DXWWrqoltq)mhCxXUrSvI5LFqWA(F(FdQqYlBWlghX4DjklY1IFfwcKyAsvqxHvr)g2UrpGcRZ3G(zeldX8L)I5BNtmhDWm4HyCNLpX4N)I5OdgX4olFILaLyoRyo6GrmUZkwIeeumNXe0ptHn3rpGc7o16AUJEavD)rHDd7GGDwyjeeAh9sQUhpSP6oniEX8HJyB3Qx6K67saLy3VlggocY5zWH9fcuJbcs1CWDfBLy7XdBQUtdI)OiKE3Hy3YrmUk297I9UKwxJeIII)8m4W(cbQFmqpX8HJy(sSvIrii0o6LuDpEyt1DAq8I5dhX8Ly3Vl2E8WMQ70G4pkcP3Di2TCeJhX4fXUwSi1eiokICjy9dygjkY7qGettkXwjggocYzzc6N5G7k2nfwD)rfKEuHfPb9ZuIYIxT4xHLajMMuf0vy3WoiyNf2pOuhmK68K73VyRe7DjTUgjeff)5zWH9fcu)yGEIDRy(QWM7OhqH9zs144dyFHkrzrFv8RWsGettQc6kSByheSZcBKAcehqJIj(i1xi4HajMMuITsmioGqgik6enyDngN07kMov0HajMMuITsS3L06AKquu8NNbh2xiq9Jb6j2TIXVcBUJEaf2NPxwIYI8R4xHLajMMuf0vyZD0dOW(mPAC8bSVqf296TMQrcrrXxwKNc7g2bb7SWYFXwMWoX00b)PQlShyhRRWjYOhGyRetry4iihKgOQoO8cG()ajVSbVy3kgpITsS3L06AKquu8NNbh2xiq9Jb6j2TCe7QITsSiHOO4eThvJPQAsmErmi5Ln4fZhXC2cRI(nSDJEafwUORyXi2vflsikkEXUgmI5c75gXUqKRy4UI58nqj2vs5fa9VyyRfBVERBakXyzs144dyFHoLOSOZw8RWsGettQc6kS5o6buyFMuno(a2xOcRI(nSDJEafwNFGI5c7b2XAXGtKrpa(ed)jXyzs144dyFHeBwsqXyJb6jMJoye7k5vILOYg8Hy4UIfJy(sSiHOO4fBGI1iI58xPy9lgehaAakXgeeXUEaILG1ILEdoieBqelsikk(BkSByheSZc7Ye2jMMo4pvDH9a7yDforg9aeBLyxlMIWWrqoinqvDq5fa9)bsEzdEXUvmEe7(DXIutG44Gs3b4LFqWdbsmnPeBLyVlP11iHOO4ppdoSVqG6hd0tSB5iMVe7MsuwKlx8RWsGettQc6kSByheSZc77sADnsikkEX8HJyxvm)f7AXWWrqobdvHtee4G7k297IbXbeYarrN8sMW(R)GRRiWeLhbIdbsmnPe7gXwj21IHHJGC(1EyJ(RdsvrzWut8y2Woo4UID)Uy8xmmCeKJlK8ivhz0d4G7k297I9UKwxJeIIIxmF4ig)e7McBUJEaf2Nbh2xiq9Jb6vIYIxXIFfwcKyAsvqxHn3rpGc7ZKQXXhW(cvyv0VHTB0dOWYYKQXXhW(cjwmIbjei9mI58nqj2vs5fa9VyjqjwmIrGhhsI5GeBNaX2jeUwSzjbflfdbxRfZ5VsXAqmIfmKyaYjHySd3fRreZD(VX00PWUHDqWolSkcdhb5G0av1bLxa0)hi5Ln4f7woIXJy3Vl2EgTACao)ApSr)1bPQOmyoqYlBWl2TIXZvuSvIPimCeKdsduvhuEbq)FGKx2GxSBfBpJwnoaNFTh2O)6Guvugmhi5Ln4lrzrN5IFfwcKyAsvqxHDd7GGDwyXWrqoUeezGzqQ6sQb)5JCFrmF4ig)eBLy7bOW744sqKbMbPQlPg8hycUiMpCeJNRwyZD0dOWIspJhMovujklYdVl(vyZD0dOW(mPAC8bSVqfwcKyAsvqxjklYdpf)kSeiX0KQGUc7g2bb7SWYFXIeIIIt)vS5FXwj2E8WMQ70G4pkcP3DiMpCeJhXwjggocY5zMO2GAWqvvcVCWDfBLyeGGOwFI2JQXu9fVfZhXqTvhV0jf2Ch9akSBgkDRpZeLOefwfHK46O4xzrEk(vyZD0dOWEP3xkSeiX0KQGUsuwKRf)kSeiX0KQGUc74wyFkkS5o6buyxMWoX0uHDzQXPclgocY519MQjqvv9Mo4UID)UyVlP11iHOO4ppdoSVqG6hd0tmF4iMZwyv0VHTB0dOWYfFsjwmIPOGGEnGeZbdfmeuS9mA14a8I5i7qmKbkglG7IHLpPeBaIfjeff)PWUmHvq6rf2hOQ7bO6OhqjklE1IFfwcKyAsvqxHDClSpff2Ch9akSltyNyAQWUm14uH1f2dSJ1v4ez0dqSvI9UKwxJeIII)8m4W(cbQFmqpX8HJyCTWQOFdB3OhqH9kaOxl2MjbOiXGtKrpaXAeXCqIXKljXCH9a7yDforg9ae7PqSeOeZdxhTRMelsikkEXWDpf2LjScspQWI)u1f2dSJ1v4ez0dOeLf9vXVclbsmnPkORWoUf2NIcBUJEaf2LjStmnvyxMACQWYv(jM)IfPMaXzzJAGhcKyAsj2cumUYBX8xSi1eioE5heSoi1NjvJJ)qGettkXwGIXvElM)IfPMaX5zs14OImB8)qGettkXwGIXv(jM)IfPMaXj15g2X6dbsmnPeBbkgx5Ty(lgx5NylqXUwS3L06AKquu8NNbh2xiq9Jb6jMpCeZxIDtHvr)g2UrpGclx8jLyXiMIqAajMdgciwmIH)KyFqPoyeZ3C)fBGIHH3Afb)c7YewbPhvy)GsDWudgi9mJwvIYI8R4xHLajMMuf0vyv0VHTB0dOW6BgAFrmFZ9xSmedPHFuyZD0dOWUtTUM7Ohqv3Fuy19hvq6rf2T6lrzrNT4xHLajMMuf0vyv0VHTB0dOWUq4aXqW161I9o6yZqVyXiwWqIXguQdgsj2cnrg9ae7AS1IPMgGsSF4tSoedzGB6fZDgDdqjwJigycMgGsS(flxMToX00nNcBUJEafwioOM7Ohqv3Fuy3WoiyNf2pOuhmK6KADHv3FubPhvy)GsDWqQsuwKlx8RWsGettQc6kS5o6buyFDVPAcuvvVPcRI(nSDJEafwETRRETyS6EtILaLyCV3Kyzigx9xmF7CIPWHnaLybdjgsd)qmE4TypThG65tSejiOybtgI5l)fZ3oNynIyDig5e3gsVyo6GPbIfmKyaYjHyCj(M7InqX6xmWeIH7wy3WoiyNf23L06AKquu8NNbh2xiq9Jb6j2TI5SITsmKgftuHKx2GxmFeZzfBLyy4iiNx3BQMavv1B6ajVSbVy3kgQT64LorSvIThpSP6oniEX8HJy(smErSRflApsSBfJhEl2nITafJRLOS4vS4xHLajMMuf0vyv0VHTB0dOW6CWEGDSwSfAIm6bWLMyCbk42lgQEjjwk2gMUILydEigbiiQ1IHmqXcgsSpOuhmI5BU)IDngERveuSpATwmi9U0oeRJBoIXLoUlFI1Hy7eiggjwWKHyF75QPtHn3rpGc7o16AUJEavD)rHDd7GGDwyxMWoX00b)PQlShyhRRWjYOhqHv3FubPhvy)GsDWu3QVeLfDMl(vyjqIPjvbDfwf9By7g9akS(EaFRiOy4FdqjwkgBqPoyeZ3CxmhmeqmiLBMgGsSGHeJaee1AXcgi9mJwvyZD0dOWUtTUM7Ohqv3Fuy3WoiyNfwcqquRpkcP3Di2TCeBzc7ettNpOuhm1GbspZOvfwD)rfKEuH9dk1btDR(suwKhEx8RWsGettQc6kSByheSZc71Irii0o6LuDpEyt1DAq8I5dhX2UvV0j13LakXUrS73f7AX2Jh2uDNge)rri9UdXULJy8i297IH0OyIkK8Yg8IDlhX4rSvIrii0o6LuDpEyt1DAq8I5dhXUQy3VlggocY5x7Hn6VoivfLbtnXJzd74G7k2kXieeAh9sQUhpSP6oniEX8HJy(sSBe7(DXUwS3L06AKquu8NNbh2xiq9Jb6jMpCeZxITsmcbH2rVKQ7XdBQUtdIxmF4iMVe7McBUJEaf2DQ11Ch9aQ6(JcRU)OcspQWI0G(zkrzrE4P4xHLajMMuf0vyv0VHTB0dOWYfFsSumm8wRiOyoyiGyqk3mnaLybdjgbiiQ1Ifmq6zgTQWM7OhqHDNADn3rpGQU)OWUHDqWolSeGGOwFuesV7qSB5i2Ye2jMMoFqPoyQbdKEMrRkS6(Jki9OclgERvLOSipCT4xHLajMMuf0vyZD0dOWMWDcOAmqibIcRI(nSDJEafwUW4G(qmxypWowlwdel1AXgeXcgsmETZXfedJ2j(tI1Hy7e)PxSumUeFZ9c7g2bb7SWsacIA9rri9UdX8HJy8WpX8xmcqquRpqcfbkrzrEUAXVcBUJEaf2eUtavDX1pvyjqIPjvbDLOSip(Q4xHn3rpGcRUrXeF9kexHYJarHLajMMuf0vIYI8WVIFf2Ch9akSyjQ6GudyVV8fwcKyAsvqxjkrH1fs7XdlJIFLf5P4xHn3rpGcB66QxxDN(hqHLajMMuf0vIYICT4xHn3rpGcl2eHMuveDUMuoAaQAmoPbfwcKyAsvqxjklE1IFfwcKyAsvqxHDd7GGDwy)bxJ1a1Xf)dCnvjiUB0d4qGettkXUFxSFW1ynqDwo6mAnv)rVKaXHajMMuf2Ch9akSiA6z2WejkrzrFv8RWM7OhqH9dk1btHLajMMuf0vIYI8R4xHLajMMuf0vyZD0dOW6LWlKQImWQIYGPW6cP94HLr9P9auFHLh(vIYIoBXVclbsmnPkORWM7OhqH919MQjqvv9MkSByheSZclKqG0ZKyAQW6cP94HLr9P9auFHLNsuwKlx8RWsGettQc6kSByheSZclehqidefD8s4L6GudgQ6LFqWA(F(FdoeiX0KQWM7OhqH9zs14OIPtf9LOefwKg0ptXVYI8u8RWsGettQc6kSJBH9POWM7OhqHDzc7ettf2LPgNkSrQjqCCHKhP6iJEahcKyAsj2kXExsRRrcrrXFEgCyFHa1pgONy3k21IXpX4fX2ZscKG4aOnC0duj2nITsm(l2EwsGeeNlRHDckSk63W2n6buyVsMwtIH)naLyohK8ivhz0dGpXYLtReBNF0auIXQ7njwcuIX9EtI5GHaIXYKQXHyCpbBsS(f7NbiwmIHrIH)KIpXiNSj3qmKbkMZW1Wobf2LjScspQW6cjpsvFGQUhGQJEaLOSixl(vyjqIPjvbDf2nSdc2zHL)ITmHDIPPJlK8iv9bQ6EaQo6bi2kXExsRRrcrrXFEgCyFHa1pgONy3kMZk2kX4Vyy4iiNNjvJJQkbB6G7k2kXWWrqoVU3unbQQQ30bsEzdEXUvmKgftuHKx2GxSvIbjei9mjMMkS5o6buyFDVPAcuvvVPsuw8Qf)kSeiX0KQGUc7g2bb7SWUmHDIPPJlK8iv9bQ6EaQo6bi2kX2ZOvJdW5zs14OQsWMoBMeII(kcm3rpGul2TIXZHlZpXwjggocY519MQjqvv9MoqYlBWl2TITNrRghGZV2dB0FDqQkkdMdK8Yg8ITsSRfBpJwnoaNNjvJJQkbB6aPuTwSvIHHJGC(1EyJ(RdsvrzWCGKx2GxmErmmCeKZZKQXrvLGnDGKx2GxSBfJNdxf7McBUJEaf2x3BQMavv1BQeLf9vXVclbsmnPkORWoUf2NIcBUJEaf2LjStmnvyxMACQW6LFqWA(F(FdQqYlBWlMpIXBXUFxm(lwKAcehqJIj(i1xi4HajMMuITsSi1eioQeEP(mPACCiqIPjLyReddhb58mPACuvjythCxXUFxS3L06AKquu8NNbh2xiq9Jb6jMpCe7AX4Ny8IyqCaHmqu0bPbPUJ1hcKyAsj2nfwf9By7g9akSodiTlbfZzmHDIPjXqgOyleUBGdPJySxAxXu4WgGsmEv(bbfJx)F(FdeBGIPWHnaLyCpbBsmhDWig3t4fXsGsmWi2InkM4JuFHGNc7YewbPhvy)lTBfI7g4qQeLf5xXVclbsmnPkORWM7OhqHfI7g4qQWQOFdB3OhqH1zirUIH7k2cH7g4qsSgrSoeRFXsSbpelgXG4aXg84uy3WoiyNf2RfJ)ITmHDIPPZFPDRqC3ahsID)UyltyNyA6G)u1f2dSJ1v4ez0dqSBeBLyrcrrXjApQgtv1Ky8IyqYlBWlMpI5SITsmiHaPNjX0ujkl6Sf)kS5o6buyFAdPOg0Mb0ot4uHLajMMuf0vIYIC5IFfwcKyAsvqxHn3rpGcle3nWHuHDVERPAKquu8Lf5PWUHDqWolS8xSLjStmnD(lTBfI7g4qsSvIXFXwMWoX00b)PQlShyhRRWjYOhGyRe7DjTUgjeff)5zWH9fcu)yGEI5dhX4QyRelsikkor7r1yQQMeZhoIDTy8tm)f7AX4QylqX2Jh2uDNgeVy3i2nITsmiHaPNjX0uHvr)g2UrpGclVcxhTAIObOelsikkEXcMmeZrR1IP7LKyiduSGHetHdZOhGydIyleUBGdj(edsiq6zetHdBakXCtGI869PeLfVIf)kSeiX0KQGUcBUJEafwiUBGdPcRI(nSDJEaf2fIqG0Zi2cH7g4qsmkH61I1iI1HyoATwmYjUnKetHdBakXyx7Hn6)ig3hXcMmedsiq6zeRreJD4UyOO4fdsPATynqSGHedqojeJF)PWUHDqWolS8xSLjStmnD(lTBfI7g4qsSvIbjVSbVy3k2EgTACao)ApSr)1bPQOmyoqYlBWlM)IXdVfBLy7z0QXb48R9Wg9xhKQIYG5ajVSbVy3Yrm(j2kXIeIIIt0EunMQQjX4fXGKx2GxmFeBpJwnoaNFTh2O)6Guvugmhi5Ln4fZFX4xjkl6mx8RWsGettQc6kSByheSZcl)fBzc7etth8NQUWEGDSUcNiJEaITsS3L06AKquu8I5dhXUAHn3rpGclMo3xQUJdfblrzrE4DXVcBUJEafwAz)BcMbvyjqIPjvbDLOef2T6l(vwKNIFfwcKyAsvqxHDd7GGDwy5Vyy4iiNNjvJJQkbB6G7k2kXWWrqopdoSVqGAmqqQMdURyReddhb58m4W(cbQXabPAoqYlBWl2TCe7Qh(vyXFQoiivuBvzrEkS5o6buyFMunoQQeSPcRI(nSDJEafwU4tIX9eSjXgeeEb1wjggHmqsSGHedPHFi2ZGd7leO(Xa9edboEI53abPAeBpE0lwdoLOSixl(vyjqIPjvbDf2nSdc2zHfdhb58m4W(cbQXabPAo4UITsmmCeKZZGd7leOgdeKQ5ajVSbVy3YrSRE4xHf)P6GGurTvLf5PWM7OhqH9x7Hn6VoivfLbtHvr)g2UrpGc71CrGM(xSudPuTwmCxXWODI)KyoiXIzUigltQghI58Zg)Vrm8NeJDTh2OFXgeeEb1wjggHmqsSGHedPHFigldoSVqaXyJb6jgcC8eZVbcs1i2E8OxSgCkrzXRw8RWsGettQc6kSByheSZc7Ye2jMMopqv3dq1rpaXwjg)f7dk1bdPoEji0KyRe7AX4VyqCaHmqu0zWivtGnDiqIPjLy3VlggocY5x7Hn6VoivfLbZb3vSvIThpSP6oniEX8HJy8tSBkS5o6buyr0jksRZOhqjkl6RIFfwcKyAsvqxHDd7GGDwyVwmioGqgik64LWl1bPgmu1l)GG18)8)gCiqIPjLyReBpEyt1DAq8hfH07oe7woIXJy8IyrQjqCue5sW6hWmiuK3HajMMuID)UyqCaHmqu0rrzWOxxFMuno(dbsmnPeBLy7XdBQUtdIxSBfJhXUrSvIHHJGC(1EyJ(RdsvrzWCWDfBLyy4iiNNjvJJQkbB6G7k2kX8Ypiyn)p)Vbvi5Ln4fJJy8wSvIHHJGCuugm611NjvJJ)OghGcBUJEaf2LjOFMsuwKFf)kSeiX0KQGUcRI(nSDJEafwNBgTyidum)giivJyUqIxyhUlMJoyeJLH7IbPuTwmhmeqmWeIbXbGgGsmwN)uyrgyfqojklYtHDd7GGDwyJutG48m4W(cbQXabPAoeiX0KsSvIXFXIutG48mPACurMn(FiqIPjvHn3rpGcR7m6kK(bhUPsuw0zl(vyjqIPjvbDf2Ch9akSpdoSVqGAmqqQMcRI(nSDJEafwU4tI53abPAeZfsIXoCxmhmeqmhKym5ssSGHeJaee1AXCWqbdbfdboEI5oJUbOeZrhmdEigRZl2af7ke)dXqracMA96tHDd7GGDwyjabrTwmF4iMZYBXwj2Ye2jMMopqv3dq1rpaXwj2EgTACao)ApSr)1bPQOmyo4UITsS9mA14aCEMunoQQeSPZMjHOOxmF4igpITsSRfJ)IbXbeYarrNbJunb20HajMMuID)Uykcdhb5GOtuKwNrpGdURy3i2kX2Jh2uDNgeVy3YrmUk2kXUwm(lggocYXfsEKQJm6bCWDf7(DXExsRRrcrrXFEgCyFHa1pgONy(iMVe7MsuwKlx8RWsGettQc6kS5o6buyFccZGuvSbq13TVqf2nSdc2zHDzc7ettNhOQ7bO6OhGyReJ)IPM48eeMbPQydGQVBFHQQjorVV0auITsSiHOO4eThvJPQAsmF4igx5rS73fdPrXevi5Ln4f7woIXpXwj27sADnsikk(ZZGd7leO(Xa9e7wXUAHDVERPAKquu8Lf5PeLfVIf)kSeiX0KQGUc7g2bb7SWUmHDIPPZdu19auD0dqSvIThpSP6oni(JIq6DhI5dhX4PWM7OhqH9j3V)suw0zU4xHLajMMuf0vyZD0dOW(R9Wg9xhKQIYGPWQOFdB3OhqHLl(KySR9Wg9l2aeBpJwnoaIDDIeeumKg(HySaUFJy4an9VyoiXsijgQPbOelgXChxX8BGGunILaLyQrmWeIXKljXyzs14qmNF24)PWUHDqWolSltyNyA68avDpavh9aeBLyxlwKAcehcSK0JBdqvFMuno(dbsmnPe7(DX2ZOvJdW5zs14OQsWMoBMeIIEX8HJy8i2nITsSRfJ)IfPMaX5zWH9fcuJbcs1CiqIPjLy3VlwKAceNNjvJJkYSX)dbsmnPe7(DX2ZOvJdW5zWH9fcuJbcs1CGKx2GxmFeJRIDJyRe7AX4VyqCaHmqu0zWivtGnDiqIPjLy3Vl2EgTACaoi6efP1z0d4ajVSbVy(igp8wS73fBpJwnoaheDII06m6bCWDfBLy7XdBQUtdIxmF4ig)e7MsuwKhEx8RWsGettQc6kS5o6buy9s4fsvrgyvrzWuy1nGQBvHLNd)kS71BnvJeIIIVSipf2nSdc2zHfMTQsljqCsL6p4UITsSRflsikkor7r1yQQMe7wX2Jh2uDNge)rri9UdXUFxm(l2huQdgsDsTwSvIThpSP6oni(JIq6DhI5dhX2UvV0j13LakXUPWQOFdB3OhqHDbGiwQuVyjKed3LpXEq7sIfmKydGeZrhmIPhh0hI5NFC)igx8jXCWqaXuRBakXqYpiOybtceZ3oNykcP3Di2afdmHyFqPoyiLyo6GzWdXsWAX8TZDkrzrE4P4xHLajMMuf0vyZD0dOW6LWlKQImWQIYGPWQOFdB3OhqHDbGigyelvQxmhTwlMQjXC0btdelyiXaKtcXUkVF(ed)jX4viCxSbig28Vyo6GzWdXsWAX8TZDkSByheSZclmBvLwsG4Kk1FAGy(i2v5Ty8IyWSvvAjbItQu)rHdZOhGyReBpEyt1DAq8hfH07oeZhoITDREPtQVlbuLOSipCT4xHLajMMuf0vy3WoiyNf2LjStmnDEGQUhGQJEaITsS94Hnv3PbXFuesV7qmF4igxfBLyxl2EgTACao)ApSr)1bPQOmyoqYlBWl2TIXJy3VlggocY5x7Hn6VoivfLbZb3vS73fdPrXevi5Ln4f7woIXvEl2nf2Ch9akSptQghvmDQOVeLf55Qf)kSeiX0KQGUc7g2bb7SWUmHDIPPZdu19auD0dqSvIThpSP6oni(JIq6DhI5dhX4QyRe7AXwMWoX00b)PQlShyhRRWjYOhGy3Vl27sADnsikk(ZZGd7leO(Xa9e7woI5lXUFxmioGqgik6aPFWbQgGQU1jSJ1hcKyAsj2nf2Ch9akS0MzAaQkKCHTxcuLOSip(Q4xHLajMMuf0vyZD0dOW(m4W(cbQXabPAkSk63W2n6buyVYoyeJ155tSgrmWeILAiLQ1IPgaXNy4pjMFdeKQrmhDWig7WDXWDpf2nSdc2zHnsnbIZZKQXrfz24)HajMMuITsSLjStmnDEGQUhGQJEaITsmmCeKZV2dB0FDqQkkdMdURyReBpEyt1DAq8IDlhX4QyRe7AX4Vyy4iihxi5rQoYOhWb3vS73f7DjTUgjeff)5zWH9fcu)yGEI5Jy(sSBkrzrE4xXVclbsmnPkORWUHDqWolS8xmmCeKZZKQXrvLGnDWDfBLyinkMOcjVSbVy3YrSROy(lwKAceNhhliicok6qGettQcBUJEaf2NjvJJQkbBQeLf5Xzl(vyjqIPjvbDf2nSdc2zH9AX(bxJ1a1Xf)dCnvjiUB0d4qGettkXUFxSFW1ynqDwo6mAnv)rVKaXHajMMuIDJyReJaee16JIq6DhI5dhXUkVfBLy8xSpOuhmK6KATyReddhb58R9Wg9xhKQIYG5OghGcBdcccXDJAJuy)bxJ1a1z5OZO1u9h9scef2geeeI7g12ZJuDguHLNcBUJEafwen9mByIef2geeeI7gvu6bl1fwEkrzrE4Yf)kSeiX0KQGUc7g2bb7SWIHJGCW0ZO04FCGuUdXUFxmKgftuHKx2GxSBf7Q8wS73fddhb58R9Wg9xhKQIYG5G7k2kXUwmmCeKZZKQXrftNk6p4UID)Uy7z0QXb48mPACuX0PI(dK8Yg8IDlhX4H3IDtHn3rpGcR7e9akrzrEUIf)kSeiX0KQGUc7g2bb7SWIHJGC(1EyJ(RdsvrzWCWDlS5o6buyX0ZOQi4W1LOSipoZf)kSeiX0KQGUc7g2bb7SWIHJGC(1EyJ(RdsvrzWCWDlS5o6buyXi4tWlnavjklYvEx8RWsGettQc6kSByheSZclgocY5x7Hn6VoivfLbZb3TWM7OhqHfPHeMEgvjklYvEk(vyjqIPjvbDf2nSdc2zHfdhb58R9Wg9xhKQIYG5G7wyZD0dOWMGn9bm11DQ1LOSix5AXVclbsmnPkORWM7OhqHf)PAhK3xyv0VHTB0dOWYDcjX1HyiPwJL7lIHmqXW)ettI1b59lSyCXNeZrhmIXU2dB0VydIyCNYG5uy3WoiyNfwmCeKZV2dB0FDqQkkdMdURy3VlgsJIjQqYlBWl2TIXvExIsuy)GsDWu3QV4xzrEk(vyjqIPjvbDf2XTW(uuyZD0dOWUmHDIPPc7YuJtf29mA14aCEMunoQQeSPZMjHOOVIaZD0di1I5dhX45WL5xHvr)g2UrpGcRZas7sqXCgtyNyAQWUmHvq6rf2Nrvdgi9mJwvIYICT4xHLajMMuf0vyZD0dOWUmb9Zuyv0VHTB0dOW6mMG(zeRreZbjwcjX2PRBdqj2aeJ7jytITzsik6pIXLkH61IHridKedPHFiMkbBsSgrmhKym5ssmWi2InkM4JuFHGIHHhIX9eErmwMunoeRbInqfbflgXqrHyleUBGdjXWDf7AWigVk)GGIXR)p)Vb3CkSByheSZc71IXFXwMWoX005zu1GbspZOvID)Uy8xSi1eioGgft8rQVqWdbsmnPeBLyrQjqCuj8s9zs144qGettkXUrSvIThpSP6oni(JIq6DhI5Jy8i2kX4VyqCaHmqu0XlHxQdsnyOQx(bbR5)5)n4qGettQsuw8Qf)kSeiX0KQGUcRI(nSDJEafwNBgTyidumwMuno8iTsm)fJLjvJJpG9fsmCGM(xmhKyjKelXg8qSyeBNUInaX4Ec2KyBMeII(Jyxba9AXCWqaXC(gOe7kP8cG(xS(flXg8qSyedIdeBWJtHfzGva5KOSipf2nSdc2zHfMB6aAumrL0ifwYjbmRP3GdIcRV4DHn3rpGcR7m6kK(bhUPsuw0xf)kSeiX0KQGUc7g2bb7SWsacIATy(WrmFXBXwjgbiiQ1hfH07oeZhoIXdVfBLy8xSLjStmnDEgvnyG0ZmALyReBpEyt1DAq8hfH07oeZhX4rSvIPimCeKdsduvhuEbq)FGKx2GxSBfJNcBUJEaf2NjvJdpsRkrzr(v8RWsGettQc6kSJBH9POWM7OhqHDzc7ettf2LPgNkS7XdBQUtdI)OiKE3Hy(WrmUkM)IHHJGCEMunoQy6ur)b3TWQOFdB3OhqH13oNybdKEMrREXqgOyeiiydqjgltQghIX9eSPc7YewbPhvyFgvDpEyt1DAq8LOSOZw8RWsGettQc6kSJBH9POWM7OhqHDzc7ettf2LPgNkS7XdBQUtdI)OiKE3Hy(WrSRwy3WoiyNf29SKajioxwd7euyxMWki9Oc7ZOQ7XdBQUtdIVeLf5Yf)kSeiX0KQGUc74wyFkkS5o6buyxMWoX0uHDzQXPc7E8WMQ70G4pkcP3Di2TCeJNc7g2bb7SWUmHDIPPd(tvxypWowxHtKrpaXwj27sADnsikk(ZZGd7leO(Xa9eZhoI5Rc7YewbPhvyFgvDpEyt1DAq8LOS4vS4xHLajMMuf0vyZD0dOW(mPACuvjytfwf9By7g9akSCpbBsmfoSbOeJDTh2OFXgOyj2SKelyG0ZmA1PWUHDqWolSltyNyA68mQ6E8WMQ70G4fBLyxl2Ye2jMMopJQgmq6zgTsS73fddhb58R9Wg9xhKQIYG5ajVSbVy(WrmEoCvS73f7DjTUgjeff)5zWH9fcu)yGEI5dhX8LyReBpJwnoaNFTh2O)6Guvugmhi5Ln4fZhX4H3IDtjkl6mx8RWsGettQc6kS5o6buyFMunoQQeSPcRI(nSDJEafw0HdbIbjVSbnaLyCpbB6fdJqgijwWqIH0OycXiG6fRreJD4Uyoga3cXWiXGuQwlwdelAp6uy3WoiyNf2LjStmnDEgvDpEyt1DAq8ITsmKgftuHKx2GxSBfBpJwnoaNFTh2O)6Guvugmhi5Ln4lrjkSy4Twv8RSipf)kSeiX0KQGUc7g2bb7SWYFXIutG4aAumXhP(cbpeiX0KsSvIbXbeYarrNObRRX4KExX0PIoeiX0KsSvI9UKwxJeIII)8m4W(cbQFmqpXUvm(vyZD0dOW(m9YsuwKRf)kSeiX0KQGUc7g2bb7SW(UKwxJeIIIxmF4igxfBLyxlg)fBpljqcIdG2WrpqLy3Vl2EgTACaopbHzqQk2aO672xOJx6K6MjHOOxmErSntcrrFfbM7OhqQfZhoIX7dx5Ny3Vl27sADnsikk(ZZGd7leO(Xa9eZhX8Ly3uyZD0dOW(m4W(cbQFmqVsuw8Qf)kSeiX0KQGUc7g2bb7SWUNrRghGZtqygKQInaQ(U9f64LoPUzsik6fJxeBZKqu0xrG5o6bKAXULJy8(Wv(j297I9dUgRbQJMsvfBDLCs65QPdbsmnPeBLy8xmmCeKJMsvfBDLCs65QPdUBHn3rpGc7tqygKQInaQ(U9fQeLf9vXVcBUJEafwu6z8W0PIkSeiX0KQGUsuwKFf)kS5o6buyXY9LpsSclbsmnPkOReLOef2Le87buwKR8MR8WBUmV5xH1rcbna1xyVsE9cT4cyrUKfwmX8JHeR9ChyigYafJBFqPoyif3edsot4nKuI9JhjwIhJxgKsSntcqr)rqJl0asmFTWI57bSKGbPeJBqCaHmqu0zb5MyXig3G4aczGOOZcEiqIPjf3e7AECYnhbnUqdiX4YlSy(EaljyqkX4gehqidefDwqUjwmIXnioGqgik6SGhcKyAsXnXUMhNCZrqtq7k51l0IlGf5swyXeZpgsS2ZDGHyidumU5cP94HLb3edsot4nKuI9JhjwIhJxgKsSntcqr)rqJl0asSRUWI57bSKGbPeJB)GRXAG6SGCtSyeJB)GRXAG6SGhcKyAsXnXUMhNCZrqJl0asSRUWI57bSKGbPeJB)GRXAG6SGCtSyeJB)GRXAG6SGhcKyAsXnXYqmUuxbCbXUMhNCZrqJl0asmU8clMVhWscgKsmUbXbeYarrNfKBIfJyCdIdiKbIIol4HajMMuCtSmeJl1vaxqSR5Xj3Ce0e0UsE9cT4cyrUKfwmX8JHeR9ChyigYafJBinOFgUjgKCMWBiPe7hpsSepgVmiLyBMeGI(JGgxObKy(AHfZ3dyjbdsjg3G4aczGOOZcYnXIrmUbXbeYarrNf8qGettkUj2184KBocAcAxjVEHwCbSixYclMy(XqI1EUdmedzGIXTT65MyqYzcVHKsSF8iXs8y8YGuITzsak6pcACHgqID1fwmFpGLemiLyCdIdiKbIIoli3elgX4gehqidefDwWdbsmnP4MyxZJtU5iOXfAajMVwyX89awsWGuIXnioGqgik6SGCtSyeJBqCaHmqu0zbpeiX0KIBIDnxDYnhbnUqdiXC2fwmFpGLemiLyCdIdiKbIIoli3elgX4gehqidefDwWdbsmnP4MyxZJtU5iOXfAajMZ8clMVhWscgKsmUbXbeYarrNfKBIfJyCdIdiKbIIol4HajMMuCtSR5Xj3Ce04cnGeJNRUWI57bSKGbPeJBqCaHmqu0zb5MyXig3G4aczGOOZcEiqIPjf3e7AECYnhbnUqdiX4XzxyX89awsWGuIXTFW1ynqDwqUjwmIXTFW1ynqDwWdbsmnP4MyxZvNCZrqtq7k51l0IlGf5swyXeZpgsS2ZDGHyidumU9bL6GPUvp3edsot4nKuI9JhjwIhJxgKsSntcqr)rqJl0asmUUWI57bSKGbPeJBqCaHmqu0zb5MyXig3G4aczGOOZcEiqIPjf3eldX4sDfWfe7AECYnhbnbTRKxVqlUawKlzHftm)yiXAp3bgIHmqX4ggERvCtmi5mH3qsj2pEKyjEmEzqkX2mjaf9hbnUqdiX4zHfZ3dyjbdsjg3G4aczGOOZcYnXIrmUbXbeYarrNf8qGettkUj2184KBocAcAlap3bgKsmUSy5o6biMU)4pcAfwx4G0AQW6uNkglowOPyTyl0GcNe0CQtfdnC9AXCw(eJR8MR8iOjO5uNkMVzsak6xybnN6uX4fX4vZssSLjStmnDWFQ6c7b2X6kCIm6bigURy)iwhI1VypfIHridKeZbjg(tI1XrqZPovmErmFpEynGeZdxhTRMeBNADn3rpGQU)qmceWMEXIrmiPW3KyUtqGOtTyqYXaVCe0CQtfJxeJxLxiXCEn9mByIeI1GGGqC3qSgi2E8WYqSgrmhKyxH4FiMQvI1HyiduSLJoJwt1F0ljqCe0e0CQtfZ5GeV47XdldbTCh9a(JlK2Jhwg(Zb9PRRED1D6FacA5o6b8hxiThpSm8Nd6XMi0KQIOZ1KYrdqvJXjnqql3rpG)4cP94HLH)CqpIMEMnmrc(Aeo)GRXAG64I)bUMQee3n6bC)(p4ASgOolhDgTMQ)OxsGqql3rpG)4cP94HLH)Cq)huQdgbTCh9a(JlK2Jhwg(Zb9Ej8cPQidSQOmy4Zfs7XdlJ6t7bOEo8WpbTCh9a(JlK2Jhwg(Zb9VU3unbQQQ3eFUqApEyzuFApa1ZHh(AeoqcbsptIPjbTCh9a(JlK2Jhwg(Zb9ptQghvmDQONVgHdehqidefD8s4L6GudgQ6LFqWA(F(Fde0e0CQtfJxLnqSfAIm6biOL7OhWZ5sVViO5uX4IpPelgXuuqqVgqI5GHcgck2EgTACaEXCKDigYafJfWDXWYNuInaXIeIII)iOL7OhW7ph0VmHDIPj(aPhX5bQ6EaQo6bW3YuJtCWWrqoVU3unbQQQ30b39(93L06AKquu8NNbh2xiq9Jb65dhNvqZPIDfa0RfBZKauKyWjYOhGynIyoiXyYLKyUWEGDSUcNiJEaI9uiwcuI5HRJ2vtIfjeffVy4UhbTCh9aE)5G(LjStmnXhi9io4pvDH9a7yDforg9a4BzQXjoUWEGDSUcNiJEaRExsRRrcrrXFEgCyFHa1pgONpC4QGMtfJl(KsSyetrinGeZbdbelgXWFsSpOuhmI5BU)InqXWWBTIGVGwUJEaV)Cq)Ye2jMM4dKEeNpOuhm1GbspZOv8Tm14ehUYp)JutG4SSrnWdbsmnPwGCL3(hPMaXXl)GG1bP(mPAC8hcKyAsTa5kV9psnbIZZKQXrfz24)HajMMulqUYp)JutG4K6Cd7y9HajMMulqUYB)5k)wGx)UKwxJeIII)8m4W(cbQFmqpF44RBe0CQy(MH2xeZ3C)fldXqA4hcA5o6b8(Zb97uRR5o6bu19h8bspIZw9cAovSfchigcUwVwS3rhBg6flgXcgsm2GsDWqkXwOjYOhGyxJTwm10auI9dFI1HyidCtVyUZOBakXAeXatW0auI1Vy5YS1jMMU5iOL7OhW7ph0dXb1Ch9aQ6(d(aPhX5dk1bdP4Rr48bL6GHuNuRf0CQy8Axx9AXy19MelbkX4EVjXYqmU6Vy(25etHdBakXcgsmKg(Hy8WBXEApa1ZNyjsqqXcMmeZx(lMVDoXAeX6qmYjUnKEXC0btdelyiXaKtcX4s8n3fBGI1VyGjed3vql3rpG3FoO)19MQjqvv9M4Rr48UKwxJeIII)8m4W(cbQFmqVBD2vinkMOcjVSbVpo7kmCeKZR7nvtGQQ6nDGKx2G)wuB1XlDYQ94Hnv3PbX7dhFXlxhThDlp8(Mfixf0CQyohShyhRfBHMiJEaCPjgxGcU9IHQxsILITHPRyj2GhIracIATyiduSGHe7dk1bJy(M7VyxJH3Afbf7JwRfdsVlTdX64MJyCPJ7YNyDi2obIHrIfmzi23EUA6iOL7OhW7ph0VtTUM7Ohqv3FWhi9ioFqPoyQB1ZxJWzzc7etth8NQUWEGDSUcNiJEacAovmFpGVveum8VbOelfJnOuhmI5BUlMdgcigKYntdqjwWqIracIATybdKEMrRe0YD0d49Nd63PwxZD0dOQ7p4dKEeNpOuhm1T65Rr4qacIA9rri9UJB5SmHDIPPZhuQdMAWaPNz0kbTCh9aE)5G(DQ11Ch9aQ6(d(aPhXbPb9ZWxJW5AcbH2rVKQ7XdBQUtdI3hoB3Qx6K67sa1n3VF9E8WMQ70G4pkcP3DClhEUFhPrXevi5Ln4VLdpRieeAh9sQUhpSP6oniEF4C173XWrqo)ApSr)1bPQOmyQjEmByhhC3veccTJEjv3Jh2uDNgeVpC81n3VF97sADnsikk(ZZGd7leO(Xa98HJVwrii0o6LuDpEyt1DAq8(WXx3iO5uX4IpjwkggERveumhmeqmiLBMgGsSGHeJaee1AXcgi9mJwjOL7OhW7ph0VtTUM7Ohqv3FWhi9ioy4TwXxJWHaee16JIq6Dh3Yzzc7ettNpOuhm1GbspZOvcAovmUW4G(qmxypWowlwdel1AXgeXcgsmETZXfedJ2j(tI1Hy7e)PxSumUeFZDbTCh9aE)5G(eUtavJbcjqWxJWHaee16JIq6Dh(WHh(5pbiiQ1hiHIacA5o6b8(Zb9jCNaQ6IRFsql3rpG3FoOx3OyIVEfIRq5rGqql3rpG3FoOhlrvhKAa79LxqtqZPovm0H3AfbFbTCh9a(dgERvCEMEjFnch(hPMaXb0OyIps9fcEiqIPj1kioGqgik6enyDngN07kMov0Q3L06AKquu8NNbh2xiq9Jb6Dl)e0YD0d4py4Tw5ph0)m4W(cbQFmqp(AeoVlP11iHOO49HdxxDn)3ZscKG4aOnC0duD)(EgTACaopbHzqQk2aO672xOJx6K6MjHOONx2mjef9veyUJEaP2ho8(Wv(D)(7sADnsikk(ZZGd7leO(Xa98Xx3iOL7OhWFWWBTYFoO)jimdsvXgavF3(cXxJWzpJwnoaNNGWmivfBau9D7l0XlDsDZKqu0ZlBMeII(kcm3rpGuFlhEF4k)UF)hCnwduhnLQk26k5K0ZvthcKyAsTI)y4iihnLQk26k5K0ZvthCxbTCh9a(dgERv(Zb9O0Z4HPtfjOL7OhWFWWBTYFoOhl3x(iXe0e0CQtfZ3ZOvJdWlO5uX4Ipjg3tWMeBqq4fuBLyyeYajXcgsmKg(HypdoSVqG6hd0tme44jMFdeKQrS94rVyn4iOL7OhWF2QNZZKQXrvLGnXh(t1bbPIAR4WdFnch(JHJGCEMunoQQeSPdU7kmCeKZZGd7leOgdeKQ5G7Ucdhb58m4W(cbQXabPAoqYlBWFlNRE4NGMtf7AUiqt)lwQHuQwlgURyy0oXFsmhKyXmxeJLjvJdXC(zJ)3ig(tIXU2dB0VydccVGARedJqgijwWqIH0WpeJLbh2xiGySXa9edboEI53abPAeBpE0lwdocA5o6b8NT69Nd6)1EyJ(RdsvrzWWh(t1bbPIAR4WdFnchmCeKZZGd7leOgdeKQ5G7Ucdhb58m4W(cbQXabPAoqYlBWFlNRE4NGwUJEa)zRE)5GEeDII06m6bWxJWzzc7ettNhOQ7bO6OhWk()bL6GHuhVeeAA118hIdiKbIIodgPAcSP73XWrqo)ApSr)1bPQOmyo4UR2Jh2uDNgeVpC43ncA5o6b8NT69Nd6xMG(z4Rr4CnehqidefD8s4L6GudgQ6LFqWA(F(FdwThpSP6oni(JIq6Dh3YHhEjsnbIJIixcw)aMbHI8oeiX0K6(DioGqgik6OOmy0RRptQgh)Q94Hnv3PbXFlp3Scdhb58R9Wg9xhKQIYG5G7Ucdhb58mPACuvjythC3vE5heSM)N)3GkK8Yg8C49kmCeKJIYGrVU(mPAC8h14aiO5uXCUz0IHmqX8BGGunI5cjEHD4Uyo6GrmwgUlgKs1AXCWqaXatigehaAakXyD(JGwUJEa)zRE)5GE3z0vi9doCt8HmWkGCsWHh(AeorQjqCEgCyFHa1yGGunhcKyAsTI)rQjqCEMunoQiZg)peiX0KsqZPIXfFsm)giivJyUqsm2H7I5GHaI5GeJjxsIfmKyeGGOwlMdgkyiOyiWXtm3z0naLyo6GzWdXyDEXgOyxH4FigkcqWuRxFe0YD0d4pB17ph0)m4W(cbQXabPA4Rr4qacIATpCCwEVAzc7ettNhOQ7bO6OhWQ9mA14aC(1EyJ(RdsvrzWCWDxTNrRghGZZKQXrvLGnD2mjef9(WHNvxZFioGqgik6myKQjWMUFxry4iiheDII06m6bCWDVz1E8WMQ70G4VLdxxDn)XWrqoUqYJuDKrpGdU797VlP11iHOO4ppdoSVqG6hd0ZhFDJGwUJEa)zRE)5G(NGWmivfBau9D7leF71BnvJeIIINdp81iCwMWoX005bQ6EaQo6bSI)QjopbHzqQk2aO672xOQAIt07lna1QiHOO4eThvJPQAYhoCLN73rAumrfsEzd(B5WVvVlP11iHOO4ppdoSVqG6hd072RkOL7OhWF2Q3FoO)j3VF(AeoltyNyA68avDpavh9awThpSP6oni(JIq6Dh(WHhbnNkgx8jXyx7Hn6xSbi2EgTACae76ejiOyin8dXybC)gXWbA6FXCqILqsmutdqjwmI5oUI53abPAelbkXuJyGjeJjxsIXYKQXHyo)SX)JGwUJEa)zRE)5G(FTh2O)6Guvugm81iCwMWoX005bQ6EaQo6bS66i1eioeyjPh3gGQ(mPAC8hcKyAsD)(EgTACaoptQghvvc20zZKqu07dhEUz118psnbIZZGd7leOgdeKQ5qGettQ73JutG48mPACurMn(FiqIPj1977z0QXb48m4W(cbQXabPAoqYlBW7dxVz118hIdiKbIIodgPAcSP733ZOvJdWbrNOiToJEahi5Ln49HhEF)(EgTACaoi6efP1z0d4G7UApEyt1DAq8(WHF3iO5uXwaiILk1lwcjXWD5tSh0UKybdj2aiXC0bJy6Xb9Hy(5h3pIXfFsmhmeqm16gGsmK8dckwWKaX8TZjMIq6DhInqXati2huQdgsjMJoyg8qSeSwmF7ChbTCh9a(Zw9(Zb9Ej8cPQidSQOmy4t3aQUvC45Wp(2R3AQgjeffphE4Rr4aZwvPLeioPs9hC3vxhjeffNO9OAmvvt3UhpSP6oni(JIq6Dh3VZ)pOuhmK6KA9Q94Hnv3PbXFuesV7WhoB3Qx6K67sa1ncAovSfaIyGrSuPEXC0ATyQMeZrhmnqSGHedqoje7Q8(5tm8NeJxHWDXgGyyZ)I5OdMbpelbRfZ3o3rql3rpG)SvV)CqVxcVqQkYaRkkdg(AeoWSvvAjbItQu)Pb(CvEZlWSvvAjbItQu)rHdZOhWQ94Hnv3PbXFuesV7WhoB3Qx6K67saLGwUJEa)zRE)5G(NjvJJkMov0ZxJWzzc7ettNhOQ7bO6OhWQ94Hnv3PbXFuesV7WhoCD117z0QXb48R9Wg9xhKQIYG5ajVSb)T8C)ogocY5x7Hn6VoivfLbZb39(DKgftuHKx2G)woCL33iOL7OhWF2Q3FoON2mtdqvHKlS9sGIVgHZYe2jMMopqv3dq1rpGv7XdBQUtdI)OiKE3HpC46QRxMWoX00b)PQlShyhRRWjYOhW97VlP11iHOO4ppdoSVqG6hd07wo(6(DioGqgik6aPFWbQgGQU1jSJ13iO5uXUYoyeJ155tSgrmWeILAiLQ1IPgaXNy4pjMFdeKQrmhDWig7WDXWDpcA5o6b8NT69Nd6FgCyFHa1yGGun81iCIutG48mPACurMn(FiqIPj1QLjStmnDEGQUhGQJEaRWWrqo)ApSr)1bPQOmyo4UR2Jh2uDNge)TC46QR5pgocYXfsEKQJm6bCWDVF)DjTUgjeff)5zWH9fcu)yGE(4RBe0YD0d4pB17ph0)mPACuvjyt81iC4pgocY5zs14OQsWMo4URqAumrfsEzd(B5Cf9psnbIZJJfeebhfDiqIPjLGwUJEa)zRE)5GEen9mByIe81iCU(hCnwduhx8pW1uLG4UrpG73)bxJ1a1z5OZO1u9h9sce3SIaee16JIq6Dh(W5Q8Ef))GsDWqQtQ1RWWrqo)ApSr)1bPQOmyoQXbGVgeeeI7g12ZJuDgehE4RbbbH4UrfLEWsnhE4RbbbH4UrTr48dUgRbQZYrNrRP6p6Leie0YD0d4pB17ph07orpa(Aeoy4iihm9mkn(hhiL74(DKgftuHKx2G)2RY773XWrqo)ApSr)1bPQOmyo4URUgdhb58mPACuX0PI(dU7977z0QXb48mPACuX0PI(dK8Yg83YHhEFJGwUJEa)zRE)5GEm9mQkcoCnFnchmCeKZV2dB0FDqQkkdMdURGwUJEa)zRE)5GEmc(e8sdqXxJWbdhb58R9Wg9xhKQIYG5G7kOL7OhWF2Q3FoOhPHeMEgfFnchmCeKZV2dB0FDqQkkdMdURGwUJEa)zRE)5G(eSPpGPUUtTMVgHdgocY5x7Hn6VoivfLbZb3vqZPIXDcjX1HyiPwJL7lIHmqXW)ettI1b59lSyCXNeZrhmIXU2dB0VydIyCNYG5iOL7OhWF2Q3FoOh)PAhK3ZxJWbdhb58R9Wg9xhKQIYG5G7E)osJIjQqYlBWFlx5TGMGMtDQyoFd6NHGVGMtf7kzAnjg(3auI5CqYJuDKrpa(elxoTsSD(rdqjgRU3Kyjqjg37njMdgcigltQghIX9eSjX6xSFgGyXiggjg(tk(eJCYMCdXqgOyodxd7eiOL7OhWFqAq)mCwMWoX0eFG0J44cjpsvFGQUhGQJEa8Tm14eNi1eioUqYJuDKrpGdbsmnPw9UKwxJeIII)8m4W(cbQFmqVBVMF8YEwsGeehaTHJEGQBwX)9SKajioxwd7eiOL7OhWFqAq)m(Zb9VU3unbQQQ3eFnch(VmHDIPPJlK8iv9bQ6EaQo6bS6DjTUgjeff)5zWH9fcu)yGE36SR4pgocY5zs14OQsWMo4URWWrqoVU3unbQQQ30bsEzd(BrAumrfsEzd(vqcbsptIPjbTCh9a(dsd6NXFoO)19MQjqvv9M4Rr4SmHDIPPJlK8iv9bQ6EaQo6bSApJwnoaNNjvJJQkbB6Szsik6RiWCh9as9T8C4Y8BfgocY519MQjqvv9MoqYlBWF7EgTACao)ApSr)1bPQOmyoqYlBWV669mA14aCEMunoQQeSPdKs16vy4iiNFTh2O)6Guvugmhi5Ln45fmCeKZZKQXrvLGnDGKx2G)wEoC9gbnNkMZas7sqXCgtyNyAsmKbk2cH7g4q6ig7L2vmfoSbOeJxLFqqX41)N)3aXgOykCydqjg3tWMeZrhmIX9eErSeOedmITyJIj(i1xi4rql3rpG)G0G(z8Nd6xMWoX0eFG0J48xA3ke3nWHeFltnoXXl)GG18)8)guHKx2G3hEF)o)JutG4aAumXhP(cbpeiX0KAvKAcehvcVuFMunooeiX0KAfgocY5zs14OQsWMo4U3V)UKwxJeIII)8m4W(cbQFmqpF4Cn)4fioGqgik6G0Gu3X6Be0CQyodjYvmCxXwiC3ahsI1iI1Hy9lwIn4HyXigehi2GhhbTCh9a(dsd6NXFoOhI7g4qIVgHZ18Fzc7ettN)s7wH4UboKUFFzc7etth8NQUWEGDSUcNiJEa3Sksikkor7r1yQQM4fi5Ln49Xzxbjei9mjMMe0YD0d4pinOFg)5G(N2qkQbTzaTZeojO5uX4v46OvtenaLyrcrrXlwWKHyoATwmDVKedzGIfmKykCyg9aeBqeBHWDdCiXNyqcbspJykCydqjMBcuKxVpcA5o6b8hKg0pJ)Cqpe3nWHeF71BnvJeIIINdp81iC4)Ye2jMMo)L2TcXDdCiTI)ltyNyA6G)u1f2dSJ1v4ez0dy17sADnsikk(ZZGd7leO(Xa98HdxxfjeffNO9OAmvvt(W5A(5)1CDbUhpSP6oni(BUzfKqG0ZKyAsqZPITqecKEgXwiC3ahsIrjuVwSgrSoeZrR1IroXTHKykCydqjg7ApSr)hX4(iwWKHyqcbspJynIySd3fdffVyqkvRfRbIfmKyaYjHy87pcA5o6b8hKg0pJ)Cqpe3nWHeFnch(VmHDIPPZFPDRqC3ahsRGKx2G)29mA14aC(1EyJ(RdsvrzWCGKx2G3FE49Q9mA14aC(1EyJ(RdsvrzWCGKx2G)wo8BvKquuCI2JQXuvnXlqYlBW7ZEgTACao)ApSr)1bPQOmyoqYlBW7p)e0YD0d4pinOFg)5GEmDUVuDhhkcYxJWH)ltyNyA6G)u1f2dSJ1v4ez0dy17sADnsikkEF4CvbTCh9a(dsd6NXFoONw2)MGzqcAcAo1PIXguQdgX89mA14a8cAovmNbK2LGI5mMWoX0KGwUJEa)5dk1btDREoltyNyAIpq6rCEgvnyG0ZmAfFltnoXzpJwnoaNNjvJJQkbB6Szsik6RiWCh9asTpC45WL5NGMtfZzmb9ZiwJiMdsSesITtx3gGsSbig3tWMeBZKqu0FeJlvc1RfdJqgijgsd)qmvc2KynIyoiXyYLKyGrSfBumXhP(cbfddpeJ7j8IySmPACiwdeBGkckwmIHIcXwiC3ahsIH7k21GrmEv(bbfJx)F(FdU5iOL7OhWF(GsDWu3Q3FoOFzc6NHVgHZ18Fzc7ettNNrvdgi9mJwD)o)JutG4aAumXhP(cbpeiX0KAvKAcehvcVuFMunooeiX0K6Mv7XdBQUtdI)OiKE3Hp8SI)qCaHmqu0XlHxQdsnyOQx(bbR5)5)nqqZPI5CZOfdzGIXYKQXHhPvI5VySmPAC8bSVqIHd00)I5GelHKyj2GhIfJy70vSbig3tWMeBZKqu0Fe7kaOxlMdgciMZ3aLyxjLxa0)I1Vyj2GhIfJyqCGydECe0YD0d4pFqPoyQB17ph07oJUcPFWHBIpKbwbKtco8Wh5KaM10BWbbhFXB(AeoWCthqJIjQKgrql3rpG)8bL6GPUvV)Cq)ZKQXHhPv81iCiabrT2ho(I3RiabrT(OiKE3HpC4H3R4)Ye2jMMopJQgmq6zgTA1E8WMQ70G4pkcP3D4dpRuegocYbPbQQdkVaO)pqYlBWFlpcAovmF7CIfmq6zgT6fdzGIrGGGnaLySmPACig3tWMe0YD0d4pFqPoyQB17ph0VmHDIPj(aPhX5zu194Hnv3PbXZ3YuJtC2Jh2uDNge)rri9UdF4Wv)XWrqoptQghvmDQO)G7kOL7OhWF(GsDWu3Q3FoOFzc7ett8bspIZZOQ7XdBQUtdINVLPgN4ShpSP6oni(JIq6Dh(W5Q81iC2ZscKG4CznStGGwUJEa)5dk1btDRE)5G(LjStmnXhi9iopJQUhpSP6oniE(wMACIZE8WMQ70G4pkcP3DClhE4Rr4SmHDIPPd(tvxypWowxHtKrpGvVlP11iHOO4ppdoSVqG6hd0Zho(sqZPIX9eSjXu4WgGsm21EyJ(fBGILyZssSGbspZOvhbTCh9a(ZhuQdM6w9(Zb9ptQghvvc2eFncNLjStmnDEgvDpEyt1DAq8RUEzc7ettNNrvdgi9mJwD)ogocY5x7Hn6VoivfLbZbsEzdEF4WZHR3V)UKwxJeIII)8m4W(cbQFmqpF44Rv7z0QXb48R9Wg9xhKQIYG5ajVSbVp8W7Be0CQyOdhcedsEzdAakX4Ec20lggHmqsSGHedPrXeIra1lwJig7WDXCmaUfIHrIbPuTwSgiw0E0rql3rpG)8bL6GPUvV)Cq)ZKQXrvLGnXxJWzzc7ettNNrv3Jh2uDNge)kKgftuHKx2G)29mA14aC(1EyJ(RdsvrzWCGKx2GxqtqZPovm2GsDWqkXwOjYOhGGMtfBbGigBqPoyq)Ye0pJyjKed3LpXWFsmwMuno(a2xiXIrmmcqiDigcC8elyiXCZ)7LKyyda)flbkXC(gOe7kP8cG(NpXOLeqSgrmhKyjKeldX8sNiMVDoXUghOP)fd)BakX4v5heumE9)5)n4gbTCh9a(ZhuQdgsX5zs144dyFH4Rr4CngocY5dk1bZb39(DmCeKZYe0pZb39MvE5heSM)N)3GkK8Yg8C4TGMtfZ5Bq)mILHyx1FX8TZjMJoyg8qmUZkg6fZx(lMJoyeJ7SI5OdgXyzWH9fciMFdeKQrmmCeeXWDflgXYLtRe7hpsmF7CI5i)Ge77apJEa)rqZPIXR1)i2NiKyXigsd6NrSmeZx(lMVDoXC0bJyKtYDOxlMVelsikk(JyxZMEKy5l2GhFRiX(GsDWCUrqZPI58nOFgXYqmF5Vy(25eZrhmdEig3z5tm(5Vyo6GrmUZYNyjqjMZkMJoyeJ7SILibbfZzmb9ZiOL7OhWF(GsDWqk)5G(DQ11Ch9aQ6(d(aPhXbPb9ZWxJWHqqOD0lP6E8WMQ70G49HZ2T6LoP(UeqD)ogocY5zWH9fcuJbcs1CWDxThpSP6oni(JIq6Dh3YHR3V)UKwxJeIII)8m4W(cbQFmqpF44RveccTJEjv3Jh2uDNgeVpC81977XdBQUtdI)OiKE3XTC4HxUosnbIJIixcw)aMrII8oeiX0KAfgocYzzc6N5G7EJGwUJEa)5dk1bdP8Nd6FMuno(a2xi(AeoFqPoyi15j3V)vVlP11iHOO4ppdoSVqG6hd07wFjOL7OhWF(GsDWqk)5G(NPxYxJWjsnbIdOrXeFK6le8qGettQvqCaHmqu0jAW6AmoP3vmDQOvVlP11iHOO4ppdoSVqG6hd07w(jO5uX4IUIfJyxvSiHOO4f7AWiMlSNBe7crUIH7kMZ3aLyxjLxa0)IHTwS96TUbOeJLjvJJpG9f6iOL7OhWF(GsDWqk)5G(NjvJJpG9fIV96TMQrcrrXZHh(Aeo8Fzc7etth8NQUWEGDSUcNiJEaRuegocYbPbQQdkVaO)pqYlBWFlpRExsRRrcrrXFEgCyFHa1pgO3TCU6QiHOO4eThvJPQAIxGKx2G3hNvqZPI58dumxypWowlgCIm6bWNy4pjgltQghFa7lKyZsckgBmqpXC0bJyxjVsSev2Gped3vSyeZxIfjeffVyduSgrmN)kfRFXG4aqdqj2GGi21dqSeSwS0BWbHydIyrcrrXFJGwUJEa)5dk1bdP8Nd6FMuno(a2xi(AeoltyNyA6G)u1f2dSJ1v4ez0dy11kcdhb5G0av1bLxa0)hi5Ln4VLN73JutG44Gs3b4LFqWdbsmnPw9UKwxJeIII)8m4W(cbQFmqVB54RBe0YD0d4pFqPoyiL)Cq)ZGd7leO(Xa94Rr48UKwxJeIII3hox1)RXWrqobdvHtee4G7E)oehqidefDYlzc7V(dUUIatuEeiUz11y4iiNFTh2O)6Guvugm1epMnSJdU7978hdhb54cjps1rg9ao4U3V)UKwxJeIII3ho87gbnNkgltQghFa7lKyXigKqG0ZiMZ3aLyxjLxa0)ILaLyXigbECijMdsSDceBNq4AXMLeuSumeCTwmN)kfRbXiwWqIbiNeIXoCxSgrm35)gtthbTCh9a(ZhuQdgs5ph0)mPAC8bSVq81iCuegocYbPbQQdkVaO)pqYlBWFlhEUFFpJwnoaNFTh2O)6Guvugmhi5Ln4VLNR4kfHHJGCqAGQ6GYla6)dK8Yg83UNrRghGZV2dB0FDqQkkdMdK8Yg8cA5o6b8NpOuhmKYFoOhLEgpmDQi(Aeoy4iihxcImWmivDj1G)8rUV4dh(TApafEhhxcImWmivDj1G)atWfF4WZvf0YD0d4pFqPoyiL)Cq)ZKQXXhW(cjOL7OhWF(GsDWqk)5G(ndLU1Nzc(Aeo8psikko9xXM)xThpSP6oni(JIq6Dh(WHNvy4iiNNzIAdQbdvvj8Yb3DfbiiQ1NO9OAmvFXBFqTvhV0jf23L2Lf5QZYtjkrPa]] )

    
end
