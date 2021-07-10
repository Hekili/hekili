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


    spec:RegisterPack( "Subtlety", 20210709, [[deLB(bqiuL6ruPytkrFIkjJsLItPsQvrvj5vuv1SOsCluPYUuXVqLyyOk5yOkwgKkpdvsMgvQ6AuP02usL(gvsX4uPu6CQukwNkL08uj5EOI9rvX)qLuLoiQuvlesvpKQsnruPCrLuLAJujvFevsLrIkPQojvLuRes5LkPkYmvPuDtuPk7ujLFQKQWqPQelvjv8uuAQuv5QOskBLkPKVQsjgRsQQZQKQO2Re)vsdMYHfTyO6Xk1Kj5YiBgIpdjJgkNwQvRKQKxRsmBsDBQYUb(TIHtfhNkPulh0Zv10fUok2Us47OQgpvQCELK1JkPkMVkv7N4cpf)kSQmOYAOJxOJhE5A41T5GoEHo37w0vyJvouH1j3xsuuHfKEuHLLbp0uSQW6KR0tQk(vy)HbUPclweo)TYfUGQdmg8ZE84Y3Em6m6bSHjsWLV92CPWIZ06Wxdk4fwvguzn0Xl0XdVCn862CqhVqN7D)TPWMmb2alSSTNVlSyTsrGcEHvr)UWYYGhAkwj26mOyibn0y0Re724IyOJxOJhbnbnFJLau0FRcACNyCVzbj2Ie2jUMompvDG9a7yvforg9aeJXrSFeRdX6xSNcXWjKbsIXNeJ5jX64iOXDI57XdVbKyEm6OD0Ky7uRR5o6bu19hIrGa20lwmIbjfZMeZzcceDQfds8h4LJGg3jg3lVqI56A6X2WejeRbbbHmoHynqS94HNHynIy8jXwVy(qmvReRdXqgOylgDgTMQ)OxqG4uy19hFXVc7huQdmsv8RSgpf)kSeiX1KQG(cBUJEaf2hlvd)pG9fQWQOFdBNOhqH1xJigBqPoW4YIe0pMyjKeJXXfXyEsmwSun8)a2xiXIrmCcqiDigcC8elWiXCY)7fKy4dG5flbkXC9gOe7wO8cG(3fXOfeqSgrm(KyjKeldX8s3jMV9fXUHbOP)fJ5BakX4E5heumU))5)n46c7g2bb7SWEJy4miiNpOuhyhghXUFxmCgeKZIe0p2HXrSRfBPyE5heSM)N)3GkK8Yg8IXrmEvIYAOR4xHLajUMuf0xyv0VHTt0dOW66nOFmXYqm37Vy(2xeJFhydtig3yDrm36Vy87atmUX6Iyjqj26kg)oWeJBSILibbfZ1kb9JvyZD0dOWUtTUM7Ohqv3Fuy3WoiyNfwcbH2rVGQ7XdFQotdIxmF4i22P6LUR(oeqj297IHZGGCEmgyFHa1yGGunhghXwk2E8WNQZ0G4pkcP3Di2vCedDID)UyVdP11iHOO4ppgdSVqG6hd0tmF4iM7fBPyeccTJEbv3Jh(uDMgeVy(Wrm3l297IThp8P6mni(JIq6DhIDfhX4rmUtSBelsnbIJIihcw)aMrII8oeiX1KsSLIHZGGCwKG(XomoIDDHv3FubPhvyrAq)yLOSgxv8RWsGextQc6lSByheSZc7huQdmsDEY57xSLI9oKwxJeIII)8ymW(cbQFmqpXUsm3xyZD0dOW(yPA4)bSVqLOSM7l(vyjqIRjvb9f2nSdc2zHnsnbIdOrHfFK6le8qGextkXwkgKbqidefDIgSQgJ76DfxNk6qGextkXwk27qADnsikk(ZJXa7leO(Xa9e7kXCBHn3rpGc7J1lkrzn3w8RWsGextQc6lS5o6buyFSun8)a2xOc7E1wt1iHOO4lRXtHDd7GGDwy5TylsyN4A6W8u1b2dSJvv4ez0dqSLIPiCgeKdsduv(uEbq)FGKx2GxSReJhXwk27qADnsikk(ZJXa7leO(Xa9e7koIXvITuSiHOO4eThvJPQAsmUtmi5Ln4fZhXw3cRI(nSDIEafwUMJyXigxjwKquu8IDdyeZb2Z1IDHihXyCeZ1BGsSBHYla6FXWxj2E1w3auIXILQH)hW(cDkrzT1T4xHLajUMuf0xyZD0dOW(yPA4)bSVqfwf9By7e9akSU(afZb2dSJvIbNiJEaUigZtIXILQH)hW(cj2SGGIXgd0tm(DGj2TW9elrLn4dXyCelgXCVyrcrrXl2afRreZ1VfX6xmida0auIniiIDZaelbRel9ggqi2GiwKquu8xxy3WoiyNf2fjStCnDyEQ6a7b2XQkCIm6bi2sXUrmfHZGGCqAGQYNYla6)dK8Yg8IDLy8i297IfPMaXHpLodWl)GGhcK4Asj2sXEhsRRrcrrXFEmgyFHa1pgONyxXrm3l21LOSMRP4xHLajUMuf0xy3WoiyNf23H06AKquu8I5dhX4kX8xSBedNbb5eyuforqGdJJy3VlgKbqidefDYlzc7V(dJUIatuEeioeiX1KsSRfBPy3igodcY5x5Hp6VoivfLbwnzIzd74W4i297IXBXWzqqooqYJuDKrpGdJJy3Vl27qADnsikkEX8HJyUvSRlS5o6buyFmgyFHa1pgOxjkRDBl(vyjqIRjvb9f2Ch9akSpwQg(Fa7luHvr)g2orpGcllwQg(Fa7lKyXigKqG0JjMR3aLy3cLxa0)ILaLyXigbEgijgFsSDceBNq4kXMfeuSumegTwmx)weRbXiwGrIbi3fIXoCtSgrmN5)gxtNc7g2bb7SWQiCgeKdsduv(uEbq)FGKx2GxSR4igpID)Uy7z0QHp48R8Wh9xhKQIYa7ajVSbVyxjgp3wXwkMIWzqqoinqv5t5fa9)bsEzdEXUsS9mA1WhC(vE4J(RdsvrzGDGKx2GVeL1Unf)kSeiX1KQG(c7g2bb7SWIZGGCCiiYaZGu1fud(Zh5(Iy(Wrm3k2sX2dqX0XXHGidmdsvxqn4pWeCrmF4igpCvHn3rpGclk9mE46urLOSgp8Q4xHn3rpGc7JLQH)hW(cvyjqIRjvb9LOSgp8u8RWsGextQc6lSByheSZclVflsikko9xXN)fBPy7XdFQotdI)OiKE3Hy(WrmEeBPy4miiNhBIAdQbgvvj8YHXrSLIracIA1jApQgt198smFed1wD8s3vyZD0dOWUXO0P(ytuIsuyvesYOJIFL14P4xHn3rpGc7LEFPWsGextQc6lrzn0v8RWsGextQc6lSJtH9POWM7OhqHDrc7extf2fPMHkS4miiNx3BQMavv1B6W4i297I9oKwxJeIII)8ymW(cbQFmqpX8HJyRBHvr)g2orpGclx7jLyXiMIcc61asm(yuGrqX2ZOvdFWlg)SdXqgOySaUjgE(KsSbiwKquu8Nc7IewbPhvyFGQUhGQJEaLOSgxv8RWsGextQc6lSJtH9POWM7OhqHDrc7extf2fPMHkSoWEGDSQcNiJEaITuS3H06AKquu8NhJb2xiq9Jb6jMpCedDfwf9By7e9akSRha9kX2yjafjgCIm6biwJigFsmSCbjMdShyhRQWjYOhGypfILaLyEm6OD0KyrcrrXlgJZPWUiHvq6rfwMNQoWEGDSQcNiJEaLOSM7l(vyjqIRjvb9f2XPW(uuyZD0dOWUiHDIRPc7IuZqfw05wX8xSi1eiolAud8qGextkX8vIHoEjM)IfPMaXXl)GG1bP(yPA4)hcK4AsjMVsm0XlX8xSi1eiopwQg(vKzZ8hcK4AsjMVsm05wX8xSi1eioPo3WowDiqIRjLy(kXqhVeZFXqNBfZxj2nI9oKwxJeIII)8ymW(cbQFmqpX8HJyUxSRlSk63W2j6buy5ApPelgXuesdiX4JraXIrmMNe7dk1bMy(MBVydumCMwRi4xyxKWki9Oc7huQdSAGbPhB0QsuwZTf)kSeiX1KQG(cRI(nSDIEafwFJr7lI5BU9ILHyin8JcBUJEaf2DQ11Ch9aQ6(JcRU)OcspQWUvFjkRTUf)kSeiX1KQG(cRI(nSDIEaf21HbigcJwVsSNFhBm6flgXcmsm2GsDGrkXwNjYOhGy3GVsm10auI9JlI1HyidCtVyoZOBakXAeXatG1auI1Vy5IS1jUMU(uyZD0dOWcza1Ch9aQ6(Jc7g2bb7SW(bL6aJuNuRlS6(Jki9Oc7huQdmsvIYAUMIFfwcK4AsvqFHn3rpGc7R7nvtGQQ6nvyv0VHTt0dOWY9DC0ReJv3BsSeOeJB9MeldXqN)I5BFrmfdSbOelWiXqA4hIXdVe7P9auVlILibbflWYqm37Vy(2xeRreRdXi350q6fJFhynqSaJedqUleJRZ3CtSbkw)IbMqmgNc7g2bb7SW(oKwxJeIII)8ymW(cbQFmqpXUsS1vSLIH0OWIkK8Yg8I5JyRRylfdNbb586Et1eOQQEthi5Ln4f7kXqTvhV0DITuS94HpvNPbXlMpCeZ9IXDIDJyr7rIDLy8WlXUwmFLyOReL1UTf)kSeiX1KQG(cRI(nSDIEafwFb2dSJvITotKrpaUEf72PWvVyO6fKyPyBy6iwIpmHyeGGOwjgYaflWiX(GsDGjMV52l2n4mTwrqX(O1AXG07q7qSoU(i26zghxeRdX2jqmCsSaldX(2ZrtNcBUJEaf2DQ11Ch9aQ6(Jc7g2bb7SWUiHDIRPdZtvhypWowvHtKrpGcRU)OcspQW(bL6aRUvFjkRDBk(vyjqIRjvb9fwf9By7e9akS(EaFRiOymFdqjwkgBqPoWeZ3Ctm(yeqmiLBSgGsSaJeJaee1kXcmi9yJwvyZD0dOWUtTUM7Ohqv3Fuy3WoiyNfwcqquRokcP3Di2vCeBrc7extNpOuhy1adsp2OvfwD)rfKEuH9dk1bwDR(suwJhEv8RWsGextQc6lSByheSZc7nIrii0o6fuDpE4t1zAq8I5dhX2ovV0D13HakXUwS73f7gX2Jh(uDMge)rri9UdXUIJy8i297IH0OWIkK8Yg8IDfhX4rSLIrii0o6fuDpE4t1zAq8I5dhX4kXUFxmCgeKZVYdF0FDqQkkdSAYeZg2XHXrSLIrii0o6fuDpE4t1zAq8I5dhXCVyxl297IDJyVdP11iHOO4ppgdSVqG6hd0tmF4iM7fBPyeccTJEbv3Jh(uDMgeVy(Wrm3l21f2Ch9akS7uRR5o6bu19hfwD)rfKEuHfPb9JvIYA8WtXVclbsCnPkOVWQOFdBNOhqHLR9KyPy4mTwrqX4JraXGuUXAakXcmsmcqquRelWG0JnAvHn3rpGc7o16AUJEavD)rHDd7GGDwyjabrT6OiKE3HyxXrSfjStCnD(GsDGvdmi9yJwvy19hvq6rfwCMwRkrznEqxXVclbsCnPkOVWM7OhqHnH7eq1yGqcefwf9By7e9akS3(WN(qmhypWowjwdel1AXgeXcmsmUVVC7IHt7K5jX6qSDY80lwkgxNV5wHDd7GGDwyjabrT6OiKE3Hy(WrmECRy(lgbiiQvhiHIaLOSgpCvXVcBUJEaf2eUtavDy0pvyjqIRjvb9LOSgpUV4xHn3rpGcRUrHfFD9IrHYJarHLajUMuf0xIYA842IFf2Ch9akS4jQ6GudyVV8fwcK4AsvqFjkrH1bs7XdpJIFL14P4xHn3rpGcB64OxvDM(hqHLajUMuf0xIYAOR4xHn3rpGcl(eHMuveDUIu8BaQAmURbfwcK4AsvqFjkRXvf)kSeiX1KQG(c7g2bb7SW(dJgVbQJdZhmAQsqgNOhWHajUMuID)Uy)WOXBG6Sy0z0AQ(JEbbIdbsCnPkS5o6buyr00JTHjsuIYAUV4xHn3rpGc7huQdSclbsCnPkOVeL1CBXVclbsCnPkOVWM7OhqH1lHxivfzGvfLbwH1bs7XdpJ6t7bO(clpUTeL1w3IFfwcK4AsvqFHn3rpGc7R7nvtGQQ6nvy3WoiyNfwiHaPhlX1uH1bs7XdpJ6t7bO(clpLOSMRP4xHLajUMuf0xy3WoiyNfwidGqgik64LWl1bPgyu1l)GG18)8)gCiqIRjvHn3rpGc7JLQHFfxNk6lrjkS4mTwv8RSgpf)kSeiX1KQG(c7g2bb7SWYBXIutG4aAuyXhP(cbpeiX1KsSLIbzaeYarrNObRQX4UExX1PIoeiX1KsSLI9oKwxJeIII)8ymW(cbQFmqpXUsm3wyZD0dOW(y9IsuwdDf)kSeiX1KQG(c7g2bb7SW(oKwxJeIIIxmF4ig6eBPy3igVfBpliqcIdG2WrpqLy3Vl2EgTA4dopbHzqQk(aO670xOJx6U6glHOOxmUtSnwcrrFfbM7OhqQfZhoIXRd6CRy3Vl27qADnsikk(ZJXa7leO(Xa9eZhXCVyxxyZD0dOW(ymW(cbQFmqVsuwJRk(vyjqIRjvb9f2nSdc2zHDpJwn8bNNGWmivfFau9D6l0XlDxDJLqu0lg3j2glHOOVIaZD0di1IDfhX41bDUvS73f7hgnEduhnLQk(Qk5U0ZrthcK4Asj2sX4Ty4miihnLQk(Qk5U0ZrthghXUFxSFy04nqDUqlAWxNHRhs3auhcK4Asj2sX4TykcNbb5CHw0GVYhMb2HXPWM7OhqH9jimdsvXhavFN(cvIYAUV4xHn3rpGclk9mE46urfwcK4AsvqFjkR52IFf2Ch9akS45(YhjEHLajUMuf0xIsuy3QV4xznEk(vyjqIRjvb9f2nSdc2zHL3IHZGGCESun8RQeSPdJJylfdNbb58ymW(cbQXabPAomoITumCgeKZJXa7leOgdeKQ5ajVSbVyxXrmU642clZt1bbPIARkRXtHn3rpGc7JLQHFvLGnvyv0VHTt0dOWY1EsmULGnj2GGWDO2kXWjKbsIfyKyin8dXEmgyFHa1pgONyiWXtm)giivJy7XJEXAWPeL1qxXVclbsCnPkOVWUHDqWolS4miiNhJb2xiqngiivZHXrSLIHZGGCEmgyFHa1yGGunhi5Ln4f7koIXvh3wyzEQoiivuBvznEkS5o6buy)vE4J(RdsvrzGvyv0VHTt0dOWEdxdOP)fl1qkvReJXrmCANmpjgFsSyMlIXILQHVyU(Sz(RfJ5jXyx5Hp6xSbbH7qTvIHtidKelWiXqA4hIXIXa7leqm2yGEIHahpX8BGGunIThp6fRbNsuwJRk(vyjqIRjvb9f2nSdc2zHDrc7extNhOQ7bO6OhGylfJ3I9bL6aJuhVeeAsSLIHZGGC(vE4J(RdsvrzGDyCeBPy7XdFQotdIxmF4iMBlS5o6buyr0jksRZOhqjkR5(IFfwcK4AsvqFHDd7GGDwyVrmidGqgik64LWl1bPgyu1l)GG18)8)gCiqIRjLylfBpE4t1zAq8hfH07oe7koIXJyCNyrQjqCue5qW6hWmiuK3HajUMuID)UyqgaHmqu0rrzGPxvFSun8)dbsCnPeBPy7XdFQotdIxSReJhXUwSLIHZGGC(vE4J(RdsvrzGDyCeBPy4miiNhlvd)QkbB6W4i2sX8Ypiyn)p)Vbvi5Ln4fJJy8sSLIHZGGCuugy6v1hlvd))Og(GcBUJEaf2fjOFSsuwZTf)kSeiX1KQG(cRI(nSDIEafwFzgTyidum)giivJyoqI7yhUjg)oWeJfJBIbPuTsm(yeqmWeIbzaGgGsmwx)uyrgyfqUlkRXtHDd7GGDwyJutG48ymW(cbQXabPAoeiX1KsSLIXBXIutG48yPA4xrMnZFiqIRjvHn3rpGcRZm6kK(HbUPsuwBDl(vyjqIRjvb9f2Ch9akSpgdSVqGAmqqQMcRI(nSDIEafwU2tI53abPAeZbsIXoCtm(yeqm(Kyy5csSaJeJaee1kX4JrbgbfdboEI5mJUbOeJFhydtigRRl2afB9I5dXqracMA9QtHDd7GGDwyjabrTsmF4i26YlXwk2Ie2jUMopqv3dq1rpaXwk2EgTA4do)kp8r)1bPQOmWomoITuS9mA1WhCESun8RQeSPZglHOOxmF4igpITuSBeJ3IbzaeYarrNbNunb20HajUMuID)UykcNbb5GOtuKwNrpGdJJyxl2sX2Jh(uDMgeVyxXrm0j2sXUrmElgodcYXbsEKQJm6bCyCe7(DXEhsRRrcrrXFEmgyFHa1pgONy(iM7f76suwZ1u8RWsGextQc6lS5o6buyFccZGuv8bq13PVqf2nSdc2zHDrc7extNhOQ7bO6OhGylfJ3IPM48eeMbPQ4dGQVtFHQQjorVV0auITuSiHOO4eThvJPQAsmF4ig64rS73fdPrHfvi5Ln4f7koI5wXwk27qADnsikk(ZJXa7leO(Xa9e7kX4Qc7E1wt1iHOO4lRXtjkRDBl(vyjqIRjvb9f2nSdc2zHDrc7extNhOQ7bO6OhGylfBpE4t1zAq8hfH07oeZhoIXtHn3rpGc7toF)LOS2TP4xHLajUMuf0xyZD0dOW(R8Wh9xhKQIYaRWQOFdBNOhqHLR9KySR8Wh9l2aeBpJwn8bIDtIeeumKg(HySaUDTyman9Vy8jXsijgQPbOelgXCghX8BGGunILaLyQrmWeIHLliXyXs1WxmxF2m)PWUHDqWolSlsyN4A68avDpavh9aeBPy3iwKAcehcSG0JtdqvFSun8)dbsCnPe7(DX2ZOvdFW5Xs1WVQsWMoBSeIIEX8HJy8i21ITuSBeJ3IfPMaX5XyG9fcuJbcs1CiqIRjLy3VlwKAceNhlvd)kYSz(dbsCnPe7(DX2ZOvdFW5XyG9fcuJbcs1CGKx2GxmFedDIDTylf7gX4Ty7zbbsqCwqGaBfuS73fBpJwn8bheDII06m6bCGKx2GxmFeJhEj297ITNrRg(GdIorrADg9aomoITuS94HpvNPbXlMpCeZTIDDjkRXdVk(vyjqIRjvb9f2Ch9akSEj8cPQidSQOmWkS6gq1TQWYZXTf29QTMQrcrrXxwJNc7g2bb7SWcZwvPfeioPs9hghXwk2nIfjeffNO9OAmvvtIDLy7XdFQotdI)OiKE3Hy3VlgVf7dk1bgPoPwl2sX2Jh(uDMge)rri9UdX8HJyBNQx6U67qaLyxxyv0VHTt0dOW6RrelvQxSesIX44IypODiXcmsSbqIXVdmX0dF6dX8ZpUDeJR9Ky8XiGyQvnaLyi5heuSalbI5BFrmfH07oeBGIbMqSpOuhyKsm(DGnmHyjyLy(2xoLOSgp8u8RWsGextQc6lS5o6buy9s4fsvrgyvrzGvyv0VHTt0dOW6RredmILk1lg)wRft1Ky87aRbIfyKyaYDHyCfVExeJ5jX4EiCtSbig(8Vy87aBycXsWkX8TVCkSByheSZclmBvLwqG4Kk1FAGy(igxXlX4oXGzRQ0cceNuP(JIbMrpaXwk2E8WNQZ0G4pkcP3DiMpCeB7u9s3vFhcOkrznEqxXVclbsCnPkOVWUHDqWolSlsyN4A68avDpavh9aeBPy7XdFQotdI)OiKE3Hy(Wrm0j2sXUrS9mA1WhC(vE4J(RdsvrzGDGKx2GxSReJhXUFxmCgeKZVYdF0FDqQkkdSdJJy3VlgsJclQqYlBWl2vCedD8sSRlS5o6buyFSun8R46urFjkRXdxv8RWsGextQc6lSByheSZc7Ie2jUMopqv3dq1rpaXwk2E8WNQZ0G4pkcP3DiMpCedDITuSBeBrc7exthMNQoWEGDSQcNiJEaID)UyVdP11iHOO4ppgdSVqG6hd0tSR4iM7f7(DXGmaczGOOdK(HbOAaQ6wNWowDiqIRjLyxxyZD0dOWsBSPbOQqYb2EjqvIYA84(IFfwcK4AsvqFHn3rpGc7JXa7leOgdeKQPWQOFdBNOhqH9w6atmwx3fXAeXatiwQHuQwjMAaKlIX8Ky(nqqQgX43bMySd3eJX5uy3WoiyNf2i1eiopwQg(vKzZ8hcK4Asj2sXwKWoX105bQ6EaQo6bi2sXWzqqo)kp8r)1bPQOmWomoITuS94HpvNPbXl2vCedDITuSBeJ3IHZGGCCGKhP6iJEahghXUFxS3H06AKquu8NhJb2xiq9Jb6jMpI5EXUUeL14XTf)kSeiX1KQG(c7g2bb7SWYBXWzqqopwQg(vvc20HXrSLIH0OWIkK8Yg8IDfhXUTI5VyrQjqCEg8GGimOOdbsCnPkS5o6buyFSun8RQeSPsuwJN1T4xHLajUMuf0xy3WoiyNf2Be7hgnEduhhMpy0uLGmorpGdbsCnPe7(DX(HrJ3a1zXOZO1u9h9ccehcK4Asj21ITumcqquRokcP3DiMpCeJR4LylfJ3I9bL6aJuNuRfBPy4miiNFLh(O)6Guvugyh1WhuyBqqqiJtuBKc7pmA8gOolgDgTMQ)OxqGOW2GGGqgNO2EEKQZGkS8uyZD0dOWIOPhBdtKOW2GGGqgNOIsp4PUWYtjkRXJRP4xHLajUMuf0xy3WoiyNfwCgeKdUEgLM5JdKYDi297IH0OWIkK8Yg8IDLyCfVe7(DXWzqqo)kp8r)1bPQOmWomoITuSBedNbb58yPA4xX1PI(dJJy3Vl2EgTA4dopwQg(vCDQO)ajVSbVyxXrmE4LyxxyZD0dOW6mrpGsuwJNBBXVclbsCnPkOVWUHDqWolS4miiNFLh(O)6GuvugyhgNcBUJEafwC9mQkcdCvjkRXZTP4xHLajUMuf0xy3WoiyNfwCgeKZVYdF0FDqQkkdSdJtHn3rpGclobFcEPbOkrzn0XRIFfwcK4AsvqFHDd7GGDwyXzqqo)kp8r)1bPQOmWomof2Ch9akSinKW1ZOkrzn0XtXVclbsCnPkOVWUHDqWolS4miiNFLh(O)6GuvugyhgNcBUJEaf2eSPpGPUUtTUeL1qh6k(vyjqIRjvb9f2Ch9akSmpv7G8(cRI(nSDIEafwUrijJoedj1A8CFrmKbkgZN4AsSoiV)wfJR9Ky87atm2vE4J(fBqeJBugyNc7g2bb7SWIZGGC(vE4J(RdsvrzGDyCe7(DXqAuyrfsEzdEXUsm0XRsuIc7huQdS6w9f)kRXtXVclbsCnPkOVWoof2NIcBUJEaf2fjStCnvyxKAgQWUNrRg(GZJLQHFvLGnD2yjef9veyUJEaPwmF4igphxJBlSk63W2j6buy56tAhckMRvc7extf2fjScspQW(yQAGbPhB0QsuwdDf)kSeiX1KQG(cBUJEaf2fjOFScRI(nSDIEafwxRe0pMynIy8jXsij2oDCAakXgGyClbBsSnwcrr)rS17eQxjgoHmqsmKg(HyQeSjXAeX4tIHLliXaJyR1OWIps9fckgotig3s4fXyXs1WxSgi2aveuSyedffITomobdKeJXrSBaJyCV8dckg3))8)gC9PWUHDqWolS3igVfBrc7extNhtvdmi9yJwj297IXBXIutG4aAuyXhP(cbpeiX1KsSLIfPMaXrLWl1hlvd)dbsCnPe7AXwk2E8WNQZ0G4pkcP3DiMpIXJylfJ3IbzaeYarrhVeEPoi1aJQE5heSM)N)3GdbsCnPkrznUQ4xHLajUMuf0xyv0VHTt0dOW6lZOfdzGIXILQHVhPvI5VySyPA4)bSVqIXa00)IXNelHKyj(WeIfJy70rSbig3sWMeBJLqu0FeB9aOxjgFmciMR3aLy3cLxa0)I1Vyj(WeIfJyqgGydtCkSidSci3fL14PWUHDqWolSWCthqJclQKgPWsUlGzn9ggquyDpVkS5o6buyDMrxH0pmWnvIYAUV4xHLajUMuf0xy3WoiyNfwcqquReZhoI5EEj2sXiabrT6OiKE3Hy(WrmE4LylfJ3ITiHDIRPZJPQbgKESrReBPy7XdFQotdI)OiKE3Hy(igpITumfHZGGCqAGQYNYla6)dK8Yg8IDLy8uyZD0dOW(yPA47rAvjkR52IFfwcK4AsvqFHDCkSpff2Ch9akSlsyN4AQWUi1muHDpE4t1zAq8hfH07oeZhoIHoX8xmCgeKZJLQHFfxNk6pmofwf9By7e9akS(2xelWG0JnA1lgYafJabbBakXyXs1WxmULGnvyxKWki9Oc7JPQ7XdFQotdIVeL1w3IFfwcK4AsvqFHDCkSpff2Ch9akSlsyN4AQWUi1muHDpE4t1zAq8hfH07oeZhoIXvf2nSdc2zHDpliqcIZLvWobf2fjScspQW(yQ6E8WNQZ0G4lrznxtXVclbsCnPkOVWoof2NIcBUJEaf2fjStCnvyxKAgQWUhp8P6mni(JIq6DhIDfhX4PWUHDqWolSlsyN4A6W8u1b2dSJvv4ez0dqSLI9oKwxJeIII)8ymW(cbQFmqpX8HJyUVWUiHvq6rf2htv3Jh(uDMgeFjkRDBl(vyjqIRjvb9f2Ch9akSpwQg(vvc2uHvr)g2orpGcl3sWMetXaBakXyx5Hp6xSbkwIpliXcmi9yJwDkSByheSZc7Ie2jUMopMQUhp8P6mniEXwk2nITiHDIRPZJPQbgKESrRe7(DXWzqqo)kp8r)1bPQOmWoqYlBWlMpCeJNd6e7(DXEhsRRrcrrXFEmgyFHa1pgONy(Wrm3l2sX2ZOvdFW5x5Hp6VoivfLb2bsEzdEX8rmE4LyxxIYA3MIFfwcK4AsvqFHn3rpGc7JLQHFvLGnvyv0VHTt0dOWIEgiqmi5LnObOeJBjytVy4eYajXcmsmKgfwigbuVynIySd3eJ)aCvigojgKs1kXAGyr7rNc7g2bb7SWUiHDIRPZJPQ7XdFQotdIxSLIH0OWIkK8Yg8IDLy7z0QHp48R8Wh9xhKQIYa7ajVSbFjkrHfPb9Jv8RSgpf)kSeiX1KQG(c74uyFkkS5o6buyxKWoX1uHDrQzOcBKAcehhi5rQoYOhWHajUMuITuS3H06AKquu8NhJb2xiq9Jb6j2vIDJyUvmUtS9SGajioaAdh9avIDTylfJ3ITNfeibX5YkyNGcRI(nSDIEaf2BbR1KymFdqjMVajps1rg9aCrSCX0kX25hnaLyS6EtILaLyCR3Ky8XiGySyPA4lg3sWMeRFX(zaIfJy4KympPCrmYDBYjedzGITEAfStqHDrcRG0JkSoqYJu1hOQ7bO6OhqjkRHUIFfwcK4AsvqFHDd7GGDwy5TylsyN4A64ajpsvFGQUhGQJEaITuS3H06AKquu8NhJb2xiq9Jb6j2vITUITumElgodcY5Xs1WVQsWMomoITumCgeKZR7nvtGQQ6nDGKx2GxSRedPrHfvi5Ln4fBPyqcbspwIRPcBUJEaf2x3BQMavv1BQeL14QIFfwcK4AsvqFHDd7GGDwyxKWoX10XbsEKQ(avDpavh9aeBPy7z0QHp48yPA4xvjytNnwcrrFfbM7OhqQf7kX454ACRylfdNbb586Et1eOQQEthi5Ln4f7kX2ZOvdFW5x5Hp6VoivfLb2bsEzdEXwk2nITNrRg(GZJLQHFvLGnDGuQwj2sXWzqqo)kp8r)1bPQOmWoqYlBWlg3jgodcY5Xs1WVQsWMoqYlBWl2vIXZbDIDDHn3rpGc7R7nvtGQQ6nvIYAUV4xHLajUMuf0xyhNc7trHn3rpGc7Ie2jUMkSlsndvy9Ypiyn)p)Vbvi5Ln4fZhX4Ly3VlgVflsnbIdOrHfFK6le8qGextkXwkwKAcehvcVuFSun8peiX1KsSLIHZGGCESun8RQeSPdJJy3Vl27qADnsikk(ZJXa7leO(Xa9eZhoIDJyUvmUtmidGqgik6G0Gu3XQdbsCnPe76cRI(nSDIEafwU(K2HGI5ALWoX1KyiduS1HXjyG0rm2lTJykgydqjg3l)GGIX9)p)VbInqXumWgGsmULGnjg)oWeJBj8IyjqjgyeBTgfw8rQVqWtHDrcRG0JkS)L2PczCcgivIYAUT4xHLajUMuf0xyZD0dOWczCcgivyv0VHTt0dOWUEIihXyCeBDyCcgijwJiwhI1Vyj(WeIfJyqgGydtCkSByheSZc7nIXBXwKWoX105V0oviJtWajXUFxSfjStCnDyEQ6a7b2XQkCIm6bi21ITuSiHOO4eThvJPQAsmUtmi5Ln4fZhXwxXwkgKqG0JL4AQeL1w3IFf2Ch9akSpTHuudAJbAxBgQWsGextQc6lrznxtXVclbsCnPkOVWM7OhqHfY4emqQWUxT1unsikk(YA8uy3WoiyNfwEl2Ie2jUMo)L2PczCcgij2sX4TylsyN4A6W8u1b2dSJvv4ez0dqSLI9oKwxJeIII)8ymW(cbQFmqpX8HJyOtSLIfjeffNO9OAmvvtI5dhXUrm3kM)IDJyOtmFLy7XdFQotdIxSRf7AXwkgKqG0JL4AQWQOFdBNOhqHL7XOJwnr0auIfjeffVybwgIXV1AX09csmKbkwGrIPyGz0dqSbrS1HXjyGKlIbjei9yIPyGnaLyojqrE9(uIYA32IFfwcK4AsvqFHn3rpGclKXjyGuHvr)g2orpGc76qiq6XeBDyCcgijgLq9kXAeX6qm(Twlg5oNgsIPyGnaLySR8Wh9FeJBJybwgIbjei9yI1iIXoCtmuu8IbPuTsSgiwGrIbi3fI52)uy3WoiyNfwEl2Ie2jUMo)L2PczCcgij2sXGKx2GxSReBpJwn8bNFLh(O)6Guvugyhi5Ln4fZFX4HxITuS9mA1WhC(vE4J(RdsvrzGDGKx2GxSR4iMBfBPyrcrrXjApQgtv1KyCNyqYlBWlMpITNrRg(GZVYdF0FDqQkkdSdK8Yg8I5VyUTeL1Unf)kSeiX1KQG(c7g2bb7SWYBXwKWoX10H5PQdShyhRQWjYOhGylf7DiTUgjeffVy(WrmUQWM7OhqHfxN7lvNHVIGLOSgp8Q4xHn3rpGclTO)nbZGkSeiX1KQG(suIsuyxqWVhqzn0Xl0XdVCn862wy5Nqqdq9f2BH7VoR5RxJR7wftm)WiXApNbgIHmqXC1huQdms5kXGKRntdjLy)4rILmX4LbPeBJLau0Fe0U9gqI5(BvmFpGfemiLyUcYaiKbIIoRVRelgXCfKbqidefDw)dbsCnPCLy3WJ7U(iOD7nGeZ1CRI57bSGGbPeZvqgaHmqu0z9DLyXiMRGmaczGOOZ6FiqIRjLRe7gEC31hbnbTBH7VoR5RxJR7wftm)WiXApNbgIHmqXCLdK2JhEgUsmi5AZ0qsj2pEKyjtmEzqkX2yjaf9hbTBVbKyC1TkMVhWccgKsmx9dJgVbQZ67kXIrmx9dJgVbQZ6FiqIRjLRe7gEC31hbTBVbKyC1TkMVhWccgKsmx9dJgVbQZ67kXIrmx9dJgVbQZ6FiqIRjLReldXwVxpUDXUHh3D9rq72BajMR5wfZ3dybbdsjMRGmaczGOOZ67kXIrmxbzaeYarrN1)qGextkxjwgITEVEC7IDdpU76JGMG2TW9xN181RX1DRIjMFyKyTNZadXqgOyUcPb9J5kXGKRntdjLy)4rILmX4LbPeBJLau0Fe0U9gqI5(BvmFpGfemiLyUcYaiKbIIoRVRelgXCfKbqidefDw)dbsCnPCLy3WJ7U(iOjODlC)1znF9ACD3QyI5hgjw75mWqmKbkMR2Q3vIbjxBMgskX(XJelzIXldsj2glbOO)iOD7nGeZ93Qy(EaliyqkXCfKbqidefDwFxjwmI5kidGqgik6S(hcK4As5kXUbDU76JG2T3asS19wfZ3dybbdsjMRGmaczGOOZ67kXIrmxbzaeYarrN1)qGextkxj2n84URpcA3EdiX4HRUvX89awqWGuI5kidGqgik6S(UsSyeZvqgaHmqu0z9peiX1KYvIDdpU76JG2T3asmEw3BvmFpGfemiLyU6hgnEduN13vIfJyU6hgnEduN1)qGextkxj2nOZDxFe0e0UfU)6SMVEnUUBvmX8dJeR9CgyigYafZvFqPoWQB17kXGKRntdjLy)4rILmX4LbPeBJLau0Fe0U9gqIHUBvmFpGfemiLyUcYaiKbIIoRVRelgXCfKbqidefDw)dbsCnPCLyzi2696XTl2n84URpcAcA3c3FDwZxVgx3TkMy(HrI1EodmedzGI5kCMwRCLyqY1MPHKsSF8iXsMy8YGuITXsak6pcA3EdiX45wfZ3dybbdsjMRGmaczGOOZ67kXIrmxbzaeYarrN1)qGextkxj2n84URpcAcA(ApNbgKsmxJy5o6biMU)4pcAf23H2L1q36YtH1boiTMkSUXnIXYGhAkwj26mOyibn34gXqJrVsSBJlIHoEHoEe0e0CJBeZ3yjaf93QGMBCJyCNyCVzbj2Ie2jUMompvDG9a7yvforg9aeJXrSFeRdX6xSNcXWjKbsIXNeJ5jX64iO5g3ig3jMVhp8gqI5XOJ2rtITtTUM7Ohqv3FigbcytVyXigKumBsmNjiq0PwmiXFGxocAUXnIXDIX9YlKyUUMESnmrcXAqqqiJtiwdeBpE4ziwJigFsS1lMpet1kX6qmKbk2IrNrRP6p6feiocAcAUXnI5lqI7894HNHGwUJEa)Xbs7Xdpd)5WL0XrVQ6m9pabTCh9a(JdK2JhEg(ZHl4teAsvr05ksXVbOQX4UgiOL7OhWFCG0E8WZWFoCbrtp2gMiHlncNFy04nqDCy(GrtvcY4e9aUF)hgnEduNfJoJwt1F0liqiOL7OhWFCG0E8WZWFoC5dk1bMGwUJEa)Xbs7Xdpd)5WfVeEHuvKbwvugyU4aP94HNr9P9auphECRGwUJEa)Xbs7Xdpd)5WLx3BQMavv1BYfhiThp8mQpThG65WJlnchiHaPhlX1KGwUJEa)Xbs7Xdpd)5WLhlvd)kUov07sJWbYaiKbIIoEj8sDqQbgv9Ypiyn)p)VbcAcAUXnIX9Ygi26mrg9ae0YD0d45CP3xe0CJyCTNuIfJykkiOxdiX4JrbgbfBpJwn8bVy8ZoedzGIXc4My45tkXgGyrcrrXFe0YD0d49NdxwKWoX1KlG0J48avDpavh9aCzrQzio4miiNx3BQMavv1B6W4C)(7qADnsikk(ZJXa7leO(Xa98HZ6kO5gXwpa6vITXsaksm4ez0dqSgrm(Kyy5csmhypWowvHtKrpaXEkelbkX8y0r7OjXIeIIIxmgNJGwUJEaV)C4YIe2jUMCbKEehMNQoWEGDSQcNiJEaUSi1mehhypWowvHtKrpGLVdP11iHOO4ppgdSVqG6hd0ZhoOtqZnIX1EsjwmIPiKgqIXhJaIfJympj2huQdmX8n3EXgOy4mTwrWxql3rpG3FoCzrc7extUaspIZhuQdSAGbPhB0kxwKAgId6CR)rQjqCw0Og4HajUMu(k0Xl)JutG44LFqW6GuFSun8)dbsCnP8vOJx(hPMaX5Xs1WVImBM)qGextkFf6CR)rQjqCsDUHDS6qGextkFf64L)OZT(QBEhsRRrcrrXFEmgyFHa1pgONpCC)1cAUrmFJr7lI5BU9ILHyin8dbTCh9aE)5WLDQ11Ch9aQ6(dxaPhXzREbn3i26WaedHrRxj2ZVJng9IfJybgjgBqPoWiLyRZez0dqSBWxjMAAakX(XfX6qmKbUPxmNz0naLynIyGjWAakX6xSCr26extxFe0YD0d49NdxGmGAUJEavD)HlG0J48bL6aJuU0iC(GsDGrQtQ1cAUrmUVJJELyS6EtILaLyCR3Kyzig68xmF7lIPyGnaLybgjgsd)qmE4LypThG6DrSejiOybwgI5E)fZ3(IynIyDig5oNgsVy87aRbIfyKyaYDHyCD(MBInqX6xmWeIX4iOL7OhW7phU86Et1eOQQEtU0iCEhsRRrcrrXFEmgyFHa1pgO3vR7sKgfwuHKx2G3N1DjodcY519MQjqvv9MoqYlBWFfQT64LUB5E8WNQZ0G49HJ75UBI2JUIhEDTVcDcAUrmFb2dSJvITotKrpaUEf72PWvVyO6fKyPyBy6iwIpmHyeGGOwjgYaflWiX(GsDGjMV52l2n4mTwrqX(O1AXG07q7qSoU(i26zghxeRdX2jqmCsSaldX(2ZrthbTCh9aE)5WLDQ11Ch9aQ6(dxaPhX5dk1bwDRExAeolsyN4A6W8u1b2dSJvv4ez0dqqZnI57b8TIGIX8naLyPySbL6atmFZnX4JraXGuUXAakXcmsmcqquRelWG0JnALGwUJEaV)C4Yo16AUJEavD)HlG0J48bL6aRUvVlnchcqquRokcP3DCfNfjStCnD(GsDGvdmi9yJwjOL7OhW7phUStTUM7Ohqv3F4ci9ioinOFmxAeo3qii0o6fuDpE4t1zAq8(Wz7u9s3vFhcOU((9B2Jh(uDMge)rri9UJR4WZ97inkSOcjVSb)vC4zjHGq7Oxq194HpvNPbX7dhU6(DCgeKZVYdF0FDqQkkdSAYeZg2XHXzjHGq7Oxq194HpvNPbX7dh3F99738oKwxJeIII)8ymW(cbQFmqpF44(LeccTJEbv3Jh(uDMgeVpCC)1cAUrmU2tILIHZ0AfbfJpgbeds5gRbOelWiXiabrTsSadsp2OvcA5o6b8(ZHl7uRR5o6bu19hUaspIdotRvU0iCiabrT6OiKE3XvCwKWoX105dk1bwnWG0JnALGMBe72h(0hI5a7b2XkXAGyPwl2GiwGrIX99LBxmCANmpjwhITtMNEXsX468n3e0YD0d49Ndxs4obungiKaHlnchcqquRokcP3D4dhECR)eGGOwDGekciOL7OhW7phUKWDcOQdJ(jbTCh9aE)5WfDJcl(66fJcLhbcbTCh9aE)5Wf8evDqQbS3xEbnbn34gXqptRve8f0YD0d4p4mTwX5X6fU0iC4DKAcehqJcl(i1xi4HajUMulHmaczGOOt0Gv1yCxVR46urlFhsRRrcrrXFEmgyFHa1pgO3vUvql3rpG)GZ0AL)C4YJXa7leO(Xa9CPr48oKwxJeIII3hoOB5n8EpliqcIdG2Wrpq1977z0QHp48eeMbPQ4dGQVtFHoEP7QBSeIIEUBJLqu0xrG5o6bKAF4WRd6C797VdP11iHOO4ppgdSVqG6hd0Zh3FTGwUJEa)bNP1k)5WLNGWmivfFau9D6lKlncN9mA1WhCEccZGuv8bq13PVqhV0D1nwcrrp3TXsik6RiWCh9as9vC41bDU9(9Fy04nqD0uQQ4RQK7sphnDiqIRj1sEJZGGC0uQQ4RQK7sphnDyCUF)hgnEduNl0Ig81z46H0na1HajUMul5TIWzqqoxOfn4R8HzGDyCe0YD0d4p4mTw5phUGspJhUovKGwUJEa)bNP1k)5Wf8CF5JexqtqZnUrmFpJwn8bVGMBeJR9KyClbBsSbbH7qTvIHtidKelWiXqA4hI9ymW(cbQFmqpXqGJNy(nqqQgX2Jh9I1GJGwUJEa)zREopwQg(vvc2KlmpvheKkQTIdpU0iC4nodcY5Xs1WVQsWMomolXzqqopgdSVqGAmqqQMdJZsCgeKZJXa7leOgdeKQ5ajVSb)vC4QJBf0CJy3W1aA6FXsnKs1kXyCedN2jZtIXNelM5IySyPA4lMRpBM)AXyEsm2vE4J(fBqq4ouBLy4eYajXcmsmKg(HySymW(cbeJngONyiWXtm)giivJy7XJEXAWrql3rpG)SvV)C4YVYdF0FDqQkkdmxyEQoiivuBfhECPr4GZGGCEmgyFHa1yGGunhgNL4miiNhJb2xiqngiivZbsEzd(R4Wvh3kOL7OhWF2Q3FoCbrNOiToJEaU0iCwKWoX105bQ6EaQo6bSK3FqPoWi1XlbHMwIZGGC(vE4J(RdsvrzGDyCwUhp8P6mniEF44wbTCh9a(Zw9(ZHllsq)yU0iCUbYaiKbIIoEj8sDqQbgv9Ypiyn)p)Vbl3Jh(uDMge)rri9UJR4Wd3fPMaXrrKdbRFaZGqrEhcK4AsD)oKbqidefDuugy6v1hlvd)F5E8WNQZ0G4VINRxIZGGC(vE4J(RdsvrzGDyCwIZGGCESun8RQeSPdJZsV8dcwZ)Z)BqfsEzdEo8AjodcYrrzGPxvFSun8)JA4de0CJy(YmAXqgOy(nqqQgXCGe3XoCtm(DGjglg3edsPALy8XiGyGjedYaanaLySU(rql3rpG)SvV)C4IZm6kK(HbUjxqgyfqUl4WJlncNi1eiopgdSVqGAmqqQMdbsCnPwY7i1eiopwQg(vKzZ8hcK4AsjO5gX4ApjMFdeKQrmhijg7WnX4JraX4tIHLliXcmsmcqquReJpgfyeume44jMZm6gGsm(DGnmHySUUyduS1lMpedfbiyQ1RocA5o6b8NT69NdxEmgyFHa1yGGunU0iCiabrTYhoRlVwUiHDIRPZdu19auD0dy5EgTA4do)kp8r)1bPQOmWomol3ZOvdFW5Xs1WVQsWMoBSeIIEF4WZYB4nKbqidefDgCs1eyt3VRiCgeKdIorrADg9aomoxVCpE4t1zAq8xXbDlVH34miihhi5rQoYOhWHX5(93H06AKquu8NhJb2xiq9Jb65J7Vwql3rpG)SvV)C4YtqygKQIpaQ(o9fYL9QTMQrcrrXZHhxAeolsyN4A68avDpavh9awYB1eNNGWmivfFau9D6luvnXj69LgGAzKquuCI2JQXuvn5dh0XZ97inkSOcjVSb)vCC7Y3H06AKquu8NhJb2xiq9Jb6DfxjOL7OhWF2Q3FoC5jNVFxAeolsyN4A68avDpavh9awUhp8P6mni(JIq6Dh(WHhbn3igx7jXyx5Hp6xSbi2EgTA4de7MejiOyin8dXybC7AXyaA6FX4tILqsmutdqjwmI5moI53abPAelbkXuJyGjedlxqIXILQHVyU(Sz(JGwUJEa)zRE)5WLFLh(O)6GuvugyU0iCwKWoX105bQ6EaQo6bS8Mi1eioeybPhNgGQ(yPA4)hcK4AsD)(EgTA4dopwQg(vvc20zJLqu07dhEUE5n8osnbIZJXa7leOgdeKQ5qGextQ73JutG48yPA4xrMnZFiqIRj1977z0QHp48ymW(cbQXabPAoqYlBW7d6UE5n8EpliqcIZcceyRG3VVNrRg(GdIorrADg9aoqYlBW7dp86(99mA1WhCq0jksRZOhWHXz5E8WNQZ0G49HJBVwqZnI5RrelvQxSesIX44IypODiXcmsSbqIXVdmX0dF6dX8ZpUDeJR9Ky8XiGyQvnaLyi5heuSalbI5BFrmfH07oeBGIbMqSpOuhyKsm(DGnmHyjyLy(2xocA5o6b8NT69Ndx8s4fsvrgyvrzG5IUbuDR4WZXTUSxT1unsikkEo84sJWbMTQsliqCsL6pmolVjsikkor7r1yQQMUApE4t1zAq8hfH07oUFN3FqPoWi1j16L7XdFQotdI)OiKE3HpC2ovV0D13HaQRf0CJy(AeXaJyPs9IXV1AXunjg)oWAGybgjgGCxigxXR3fXyEsmUhc3eBaIHp)lg)oWgMqSeSsmF7lhbTCh9a(Zw9(ZHlEj8cPQidSQOmWCPr4aZwvPfeioPs9Ng4dxXlUdMTQsliqCsL6pkgyg9awUhp8P6mni(JIq6Dh(Wz7u9s3vFhcOe0YD0d4pB17phU8yPA4xX1PIExAeolsyN4A68avDpavh9awUhp8P6mni(JIq6Dh(WbDlVzpJwn8bNFLh(O)6Guvugyhi5Ln4VIN73Xzqqo)kp8r)1bPQOmWomo3VJ0OWIkK8Yg8xXbD86AbTCh9a(Zw9(ZHl0gBAaQkKCGTxcuU0iCwKWoX105bQ6EaQo6bSCpE4t1zAq8hfH07o8Hd6wEZIe2jUMompvDG9a7yvforg9aUF)DiTUgjeff)5XyG9fcu)yGExXX93VdzaeYarrhi9ddq1au1ToHDS6Abn3i2T0bMySUUlI1iIbMqSudPuTsm1aixeJ5jX8BGGunIXVdmXyhUjgJZrql3rpG)SvV)C4YJXa7leOgdeKQXLgHtKAceNhlvd)kYSz(dbsCnPwUiHDIRPZdu19auD0dyjodcY5x5Hp6VoivfLb2HXz5E8WNQZ0G4VId6wEdVXzqqooqYJuDKrpGdJZ97VdP11iHOO4ppgdSVqG6hd0Zh3FTGwUJEa)zRE)5WLhlvd)QkbBYLgHdVXzqqopwQg(vvc20HXzjsJclQqYlBWFfNBR)rQjqCEg8GGimOOdbsCnPe0YD0d4pB17phUGOPhBdtKWLgHZn)WOXBG64W8bJMQeKXj6bC)(pmA8gOolgDgTMQ)OxqG46LeGGOwDuesV7WhoCfVwY7pOuhyK6KA9sCgeKZVYdF0FDqQkkdSJA4dCPbbbHmorT98ivNbXHhxAqqqiJturPh8uZHhxAqqqiJtuBeo)WOXBG6Sy0z0AQ(JEbbcbTCh9a(Zw9(ZHlot0dWLgHdodcYbxpJsZ8Xbs5oUFhPrHfvi5Ln4VIR41974miiNFLh(O)6GuvugyhgNL3GZGGCESun8R46ur)HX5(99mA1WhCESun8R46ur)bsEzd(R4WdVUwql3rpG)SvV)C4cUEgvfHbUYLgHdodcY5x5Hp6VoivfLb2HXrql3rpG)SvV)C4cobFcEPbOCPr4GZGGC(vE4J(RdsvrzGDyCe0YD0d4pB17phUG0qcxpJYLgHdodcY5x5Hp6VoivfLb2HXrql3rpG)SvV)C4sc20hWux3Pw7sJWbNbb58R8Wh9xhKQIYa7W4iO5gX4gHKm6qmKuRXZ9fXqgOymFIRjX6G8(BvmU2tIXVdmXyx5Hp6xSbrmUrzGDe0YD0d4pB17phUW8uTdY7DPr4GZGGC(vE4J(RdsvrzGDyCUFhPrHfvi5Ln4VcD8sqtqZnUrmxVb9JrWxqZnIDlyTMeJ5BakX8fi5rQoYOhGlILlMwj2o)ObOeJv3BsSeOeJB9MeJpgbeJflvdFX4wc2Ky9l2pdqSyedNeJ5jLlIrUBtoHyiduS1tRGDce0YD0d4pinOFmolsyN4AYfq6rCCGKhPQpqv3dq1rpaxwKAgItKAcehhi5rQoYOhWHajUMulFhsRRrcrrXFEmgyFHa1pgO3v34wUBpliqcIdG2Wrpq11l59EwqGeeNlRGDce0YD0d4pinOFm)5WLx3BQMavv1BYLgHdVxKWoX10XbsEKQ(avDpavh9aw(oKwxJeIII)8ymW(cbQFmqVRw3L8gNbb58yPA4xvjythgNL4miiNx3BQMavv1B6ajVSb)vinkSOcjVSb)siHaPhlX1KGwUJEa)bPb9J5phU86Et1eOQQEtU0iCwKWoX10XbsEKQ(avDpavh9awUNrRg(GZJLQHFvLGnD2yjef9veyUJEaP(kEoUg3UeNbb586Et1eOQQEthi5Ln4VApJwn8bNFLh(O)6Guvugyhi5Ln4xEZEgTA4dopwQg(vvc20bsPA1sCgeKZVYdF0FDqQkkdSdK8Yg8ChodcY5Xs1WVQsWMoqYlBWFfph0DTGMBeJRpPDiOyUwjStCnjgYafBDyCcgiDeJ9s7iMIb2auIX9YpiOyC))Z)BGydumfdSbOeJBjytIXVdmX4wcViwcuIbgXwRrHfFK6le8iOL7OhWFqAq)y(ZHllsyN4AYfq6rC(lTtfY4emqYLfPMH44LFqWA(F(FdQqYlBW7dVUFN3rQjqCankS4JuFHGhcK4AsTmsnbIJkHxQpwQg(hcK4AsTeNbb58yPA4xvjythgN73FhsRRrcrrXFEmgyFHa1pgONpCUXTChKbqidefDqAqQ7y11cAUrS1te5igJJyRdJtWajXAeX6qS(flXhMqSyedYaeByIJGwUJEa)bPb9J5phUazCcgi5sJW5gEViHDIRPZFPDQqgNGbs3VViHDIRPdZtvhypWowvHtKrpGRxgjeffNO9OAmvvtChK8Yg8(SUlHecKESextcA5o6b8hKg0pM)C4YtBif1G2yG21MHe0CJyCpgD0QjIgGsSiHOO4flWYqm(TwlMUxqIHmqXcmsmfdmJEaIniITomobdKCrmiHaPhtmfdSbOeZjbkYR3hbTCh9a(dsd6hZFoCbY4emqYL9QTMQrcrrXZHhxAeo8Erc7extN)s7uHmobdKwY7fjStCnDyEQ6a7b2XQkCIm6bS8DiTUgjeff)5XyG9fcu)yGE(WbDlJeIIIt0EunMQQjF4CJB9)g05R2Jh(uDMge)1xVesiq6XsCnjO5gXwhcbspMyRdJtWajXOeQxjwJiwhIXV1AXi350qsmfdSbOeJDLh(O)JyCBelWYqmiHaPhtSgrm2HBIHIIxmiLQvI1aXcmsma5Uqm3(hbTCh9a(dsd6hZFoCbY4emqYLgHdVxKWoX105V0oviJtWaPLqYlBWF1EgTA4do)kp8r)1bPQOmWoqYlBW7pp8A5EgTA4do)kp8r)1bPQOmWoqYlBWFfh3Umsikkor7r1yQQM4oi5Ln49zpJwn8bNFLh(O)6Guvugyhi5Ln493TcA5o6b8hKg0pM)C4cUo3xQodFfbDPr4W7fjStCnDyEQ6a7b2XQkCIm6bS8DiTUgjeffVpC4kbTCh9a(dsd6hZFoCHw0)MGzqcAcAUXnIXguQdmX89mA1Wh8cAUrmU(K2HGI5ALWoX1KGwUJEa)5dk1bwDREolsyN4AYfq6rCEmvnWG0JnALllsndXzpJwn8bNhlvd)QkbB6SXsik6RiWCh9asTpC454ACRGMBeZ1kb9JjwJigFsSesITthNgGsSbig3sWMeBJLqu0FeB9oH6vIHtidKedPHFiMkbBsSgrm(Kyy5csmWi2AnkS4JuFHGIHZeIXTeErmwSun8fRbInqfbflgXqrHyRdJtWajXyCe7gWig3l)GGIX9)p)VbxFe0YD0d4pFqPoWQB17phUSib9J5sJW5gEViHDIRPZJPQbgKESrRUFN3rQjqCankS4JuFHGhcK4AsTmsnbIJkHxQpwQg(hcK4AsD9Y94HpvNPbXFuesV7WhEwYBidGqgik64LWl1bPgyu1l)GG18)8)giO5gX8Lz0IHmqXyXs1W3J0kX8xmwSun8)a2xiXyaA6FX4tILqsSeFycXIrSD6i2aeJBjytITXsik6pITEa0ReJpgbeZ1BGsSBHYla6FX6xSeFycXIrmidqSHjocA5o6b8NpOuhy1T69NdxCMrxH0pmWn5cYaRaYDbhECHCxaZA6nmGGJ75LlnchyUPdOrHfvsJiOL7OhWF(GsDGv3Q3FoC5Xs1W3J0kxAeoeGGOw5dh3ZRLeGGOwDuesV7Who8WRL8Erc7extNhtvdmi9yJwTCpE4t1zAq8hfH07o8HNLkcNbb5G0avLpLxa0)hi5Ln4VIhbn3iMV9fXcmi9yJw9IHmqXiqqWgGsmwSun8fJBjytcA5o6b8NpOuhy1T69NdxwKWoX1KlG0J48yQ6E8WNQZ0G4DzrQzio7XdFQotdI)OiKE3HpCqN)4miiNhlvd)kUov0FyCe0YD0d4pFqPoWQB17phUSiHDIRjxaPhX5Xu194HpvNPbX7YIuZqC2Jh(uDMge)rri9UdF4WvU0iC2ZccKG4CzfStGGwUJEa)5dk1bwDRE)5WLfjStCn5ci9iopMQUhp8P6mniExwKAgIZE8WNQZ0G4pkcP3DCfhECPr4SiHDIRPdZtvhypWowvHtKrpGLVdP11iHOO4ppgdSVqG6hd0ZhoUxqZnIXTeSjXumWgGsm2vE4J(fBGIL4ZcsSadsp2OvhbTCh9a(ZhuQdS6w9(ZHlpwQg(vvc2KlncNfjStCnDEmvDpE4t1zAq8lVzrc7extNhtvdmi9yJwD)oodcY5x5Hp6VoivfLb2bsEzdEF4WZbD3V)oKwxJeIII)8ymW(cbQFmqpF44(L7z0QHp48R8Wh9xhKQIYa7ajVSbVp8WRRf0CJyONbcedsEzdAakX4wc20lgoHmqsSaJedPrHfIra1lwJig7WnX4paxfIHtIbPuTsSgiw0E0rql3rpG)8bL6aRUvV)C4YJLQHFvLGn5sJWzrc7extNhtv3Jh(uDMge)sKgfwuHKx2G)Q9mA1WhC(vE4J(RdsvrzGDGKx2GxqtqZnUrm2GsDGrkXwNjYOhGGMBeZxJigBqPoW4YIe0pMyjKeJXXfXyEsmwSun8)a2xiXIrmCcqiDigcC8elWiXCY)7fKy4dG5flbkXC9gOe7wO8cG(3fXOfeqSgrm(KyjKeldX8s3jMV9fXUHbOP)fJ5BakX4E5heumU))5)n4AbTCh9a(ZhuQdmsX5Xs1W)dyFHCPr4CdodcY5dk1b2HX5(DCgeKZIe0p2HX56LE5heSM)N)3GkK8Yg8C4LGMBeZ1Bq)yILHyCL)I5BFrm(DGnmHyCJvmUiM79xm(DGjg3yfJFhyIXIXa7leqm)giivJy4miiIX4iwmILlMwj2pEKy(2xeJF(bj23btg9a(JGMBeJ7R)rSpriXIrmKg0pMyziM79xmF7lIXVdmXi3L7qVsm3lwKquu8hXUHn9iXYxSHj(wrI9bL6a7CTGMBeZ1Bq)yILHyU3FX8TVig)oWgMqmUX6IyU1FX43bMyCJ1fXsGsS1vm(DGjg3yflrcckMRvc6htql3rpG)8bL6aJu(ZHl7uRR5o6bu19hUaspIdsd6hZLgHdHGq7Oxq194HpvNPbX7dNTt1lDx9DiG6(DCgeKZJXa7leOgdeKQ5W4SCpE4t1zAq8hfH07oUId6UF)DiTUgjeff)5XyG9fcu)yGE(WX9ljeeAh9cQUhp8P6mniEF44(733Jh(uDMge)rri9UJR4Wd3DtKAcehfroeS(bmJef5DiqIRj1sCgeKZIe0p2HX5AbTCh9a(ZhuQdms5phU8yPA4)bSVqU0iC(GsDGrQZtoF)lFhsRRrcrrXFEmgyFHa1pgO3vUxql3rpG)8bL6aJu(ZHlpwVWLgHtKAcehqJcl(i1xi4HajUMulHmaczGOOt0Gv1yCxVR46urlFhsRRrcrrXFEmgyFHa1pgO3vUvqZnIX1CelgX4kXIeIIIxSBaJyoWEUwSle5igJJyUEduIDluEbq)lg(kX2R26gGsmwSun8)a2xOJGwUJEa)5dk1bgP8NdxESun8)a2xix2R2AQgjeffphECPr4W7fjStCnDyEQ6a7b2XQkCIm6bSur4miihKgOQ8P8cG()ajVSb)v8S8DiTUgjeff)5XyG9fcu)yGExXHRwgjeffNO9OAmvvtChK8Yg8(SUcAUrmxFGI5a7b2XkXGtKrpaxeJ5jXyXs1W)dyFHeBwqqXyJb6jg)oWe7w4EILOYg8HymoIfJyUxSiHOO4fBGI1iI563Iy9lgKbaAakXgeeXUzaILGvILEddieBqelsikk(Rf0YD0d4pFqPoWiL)C4YJLQH)hW(c5sJWzrc7exthMNQoWEGDSQcNiJEalVrr4miihKgOQ8P8cG()ajVSb)v8C)EKAceh(u6maV8dcEiqIRj1Y3H06AKquu8NhJb2xiq9Jb6Dfh3FTGwUJEa)5dk1bgP8NdxEmgyFHa1pgONlncN3H06AKquu8(WHR8)gCgeKtGrv4ebbomo3VdzaeYarrN8sMW(R)WORiWeLhbIRxEdodcY5x5Hp6VoivfLbwnzIzd74W4C)oVXzqqooqYJuDKrpGdJZ97VdP11iHOO49HJBVwqZnIXILQH)hW(cjwmIbjei9yI56nqj2Tq5fa9VyjqjwmIrGNbsIXNeBNaX2jeUsSzbbflfdHrRfZ1VfXAqmIfyKyaYDHySd3eRreZz(VX10rql3rpG)8bL6aJu(ZHlpwQg(Fa7lKlnchfHZGGCqAGQYNYla6)dK8Yg8xXHN733ZOvdFW5x5Hp6VoivfLb2bsEzd(R452Uur4miihKgOQ8P8cG()ajVSb)v7z0QHp48R8Wh9xhKQIYa7ajVSbVGwUJEa)5dk1bgP8NdxqPNXdxNkYLgHdodcYXHGidmdsvxqn4pFK7l(WXTl3dqX0XXHGidmdsvxqn4pWeCXho8WvcA5o6b8NpOuhyKYFoC5Xs1W)dyFHe0YD0d4pFqPoWiL)C4YgJsN6JnHlnchEhjeffN(R4Z)l3Jh(uDMge)rri9UdF4WZsCgeKZJnrTb1aJQQeE5W4SKaee1Qt0EunMQ75LpO2QJx6UsuIsb]] )

    
end
