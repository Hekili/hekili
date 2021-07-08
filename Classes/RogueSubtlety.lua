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


    spec:RegisterPack( "Subtlety", 20210708, [[da179bqiQK6rujztkjFcvPgLQsDkvvSkLOIxrvvZIkXTqLu7sv(fQeddvjhdvQLbPQNPQsnnQk5AuP02OQu(gQIQXrLQQZPevY6uvjnpvLCpuX(OQ4FOkIYbrvuwiKkpujktevHlIQiYgPsv(iQIWiPsb6KuPQSsiLxsLcyMOsIBIQiTtLi)KkfQHsLIwkvLQNIstLQkxfvsARuPq(QQkXyvIQolQIOAVs8xjnykhw0IHQhRutMKlJSzi(mKmAOCAPwTsuPETQIztQBtv2nWVvmCQ44uPGwoONRY0fUok2Us47OQgpvQCELuZxvv7N4c3f)kSQmOYsONxONBEXZ5L7)XnVqp3)UWgRDOcRtU)KOOcli9OclldEOPyDH1jxRNuv8RWEddCtfwSiCUFLlCbvhym4V94XLR9y0z0dydtKGlx7T5sHfNP1H7duWlSQmOYsONxONBEXZ5L7)XnVqp3O33kSjtGnWclB7TSclwRueOGxyv0TlSSm4HMI1I57dkgsqdng9AXC)Uig65f65wqtqBzyjafD)QGgxlgpDwqITiHDIRPhZrvhypWowxHtKrpaXyCe7gX6qS(e7OqmCczGKy8jXyosSoEcACTylB8WBajMhJoAhnj2o16AUJEavDFHyeiGnDIfJyqsXSjXCMGarNAXGe)b(5jOX1IXtZpKyUNMoSnmrcXAqqqiJtiwdeBpE4ziwJigFsSLBMlet1kX6qmKbk2IrNrRP6n6feiEfwDFXv8RWEbL6aJuf)klXDXVclbsCnPkORWM7OhqH9Ws1W)cy)HkSk62W2j6buyDFiIXguQdmUSib9HjwcjXyCCrmMJeJflvd)lG9hsSyedNaeshIHahpXcmsmN8UEbjg(ayoXsGsm3RbkX(fk)aO7CrmAbbeRreJpjwcjXYqmV0DITm3uSVzaA6oXyUgGsmEAEbbfJNDxExd(PWUHDqWolSFlgodcY7ck1b2JXrS))fdNbb5Tib9H9yCe7hXwjMxEbbR5D5DnOcjVSbNyCeJxLOSe6l(vyjqIRjvbDfwfDBy7e9akSUxd6dtSmeZx(l2YCtX43b2WeIXdwxeZT(lg)oWeJhSUiwcuI5BIXVdmX4bRyjsqqXCJsqFyf2Ch9akS7uRR5o6bu19ff2nSdc2zHLqqOD0lO6E8WNQZ0G4eZhoITDQEP7QNdbuI9)Vy4miiVdJb2FiqngiivZJXrSvIThp8P6mniUNIq6DhI9fhXqVy))l25qADnsikkU3HXa7peOEXa9eZhoI5lXwjgHGq7Oxq194HpvNPbXjMpCeZxI9)Vy7XdFQotdI7PiKE3HyFXrmUfJRf7BXIutG4PiYHG1lGzKOiVhbsCnPeBLy4miiVfjOpShJJy)uy19fvq6rfwKg0hwjkl97IFfwcK4AsvqxHDd7GGDwyVGsDGrQ3roxFITsSZH06AKquuCVdJb2Fiq9Ib6j2xI5RcBUJEaf2dlvd)lG9hQeLL8vXVclbsCnPkORWUHDqWolSrQjq8ankS4Iu)HGpcK4Asj2kXGmaczGOOx0G11yCxVR46urpcK4Asj2kXohsRRrcrrX9omgy)Ha1lgONyFjMBlS5o6buypSErjkl52IFfwcK4AsvqxHn3rpGc7HLQH)fW(dvy3R3AQgjeffxzjUlSByheSZcRRfBrc7extpMJQoWEGDSUcNiJEaITsmfHZGG8qAGQYNYpa6UhK8YgCI9LyCl2kXohsRRrcrrX9omgy)Ha1lgONyFXrSFl2kXIeIIIx0EunMQQjX4AXGKx2GtmFeZ3kSk62W2j6buy5QoIfJy)wSiHOO4e7BWiMdSNFe7droIX4iM71aLy)cLFa0DIHVwS96TUbOeJflvd)lG9h6vIYs(wXVclbsCnPkORWM7OhqH9Ws1W)cy)HkSk62W2j6buyDVbkMdShyhRfdorg9aCrmMJeJflvd)lG9hsSzbbfJngONy87atSFHNkwIkBWfIX4iwmI5lXIeIIItSbkwJiM79lI1NyqgaObOeBqqe77biwcwlw6nmGqSbrSiHOO4(PWUHDqWolSlsyN4A6XCu1b2dSJ1v4ez0dqSvI9TykcNbb5H0avLpLFa0Dpi5Ln4e7lX4wS))flsnbIhFkDgGxEbbFeiX1KsSvIDoKwxJeIII7DymW(dbQxmqpX(IJy(sSFkrzjEEXVclbsCnPkORWUHDqWolSNdP11iHOO4eZhoI9BX8xSVfdNbb5fyuforqGhJJy))lgKbqidef9Ypzc7REdJUIatuEeiEeiX1KsSFeBLyFlgodcY7w7Hp6RoivfLbwnzIzd74X4i2))I5AXWzqqEoqYJuDKrpGhJJy))l25qADnsikkoX8HJyUvSFkS5o6buypmgy)Ha1lgOxjkl5(l(vyjqIRjvbDf2Ch9akShwQg(xa7puHvr3g2orpGcllwQg(xa7pKyXigKqG0HjM71aLy)cLFa0DILaLyXigbogijgFsSDceBNq4AXMfeuSumegTwm37xeRbXiwGrIbi3fIXo8qSgrmN5UgxtVc7g2bb7SWQiCgeKhsduv(u(bq39GKx2GtSV4ig3I9)Vy7z0QHp4DR9Wh9vhKQIYa7bjVSbNyFjg3UFXwjMIWzqqEinqv5t5haD3dsEzdoX(sS9mA1Wh8U1E4J(QdsvrzG9GKx2GReLLwUk(vyjqIRjvbDf2nSdc2zHfNbb55qqKbMbPQlOgCVlY9hX8HJyUvSvIThGIPJNdbrgygKQUGAW9Gj4Jy(WrmU)DHn3rpGclk9mE46urLOSe38Q4xHn3rpGc7HLQH)fW(dvyjqIRjvbDLOSe3Cx8RWsGextQc6kSByheSZcRRflsikkE9vXN7eBLy7XdFQotdI7PiKE3Hy(WrmUfBLy4miiVdBIAdQbgvvj8ZJXrSvIracIA9lApQgt1x8smFed1w98s3vyZD0dOWUXO0PEytuIsuyvesYOJIFLL4U4xHn3rpGc7NE)PWsGextQc6krzj0x8RWsGextQc6kSJtH9OOWM7OhqHDrc7extf2fPMHkS4miiVt3BQMavv1B6X4i2))IDoKwxJeIII7DymW(dbQxmqpX8HJy(wHvr3g2orpGclx9iLyXiMIcc61asm(yuGrqX2ZOvdFWjg)SdXqgOySaEigEEKsSbiwKquuCVc7IewbPhvypGQUhGQJEaLOS0Vl(vyjqIRjvbDf2XPWEuuyZD0dOWUiHDIRPc7IuZqfwhypWowxHtKrpaXwj25qADnsikkU3HXa7peOEXa9eZhoIH(cRIUnSDIEafw3yGETyBSeGIedorg9aeRreJpjgwUGeZb2dSJ1v4ez0dqSJcXsGsmpgD0oAsSiHOO4eJX5vyxKWki9OclZrvhypWowxHtKrpGsuwYxf)kSeiX1KQGUc74uypkkS5o6buyxKWoX1uHDrQzOcl6DRy(lwKAceVfnQb(iqIRjLylhXqpVeZFXIutG45LxqW6GupSun8VhbsCnPeB5ig65Ly(lwKAceVdlvd)kYSzUhbsCnPeB5ig6DRy(lwKAceVuNByhRFeiX1KsSLJyONxI5VyO3TITCe7BXohsRRrcrrX9omgy)Ha1lgONy(WrmFj2pfwfDBy7e9akSC1JuIfJykcPbKy8XiGyXigZrIDbL6atSLXJtSbkgotRve8kSlsyfKEuH9ck1bwnWG0HnAvjkl52IFfwcK4AsvqxHvr3g2orpGc7YWO9hXwgpoXYqmKgErHn3rpGc7o16AUJEavDFrHv3xubPhvy3QReLL8TIFfwcK4AsvqxHvr3g2orpGcRVZaedHrRxl2XVJngDIfJybgjgBqPoWiLy((ez0dqSVXxlMAAakXUXfX6qmKbUPtmNz0naLynIyGjWAakX6tSCr26ext)8kS5o6buyHmGAUJEavDFrHDd7GGDwyVGsDGrQxQ1fwDFrfKEuH9ck1bgPkrzjEEXVclbsCnPkORWM7OhqH909MQjqvv9MkSk62W2j6buy5zoo61IXQ7njwcuIXJEtILHyO3FXwMBkMIb2auIfyKyin8cX4MxID0EaQZfXsKGGIfyziMV8xSL5MI1iI1HyK7CAiDIXVdSgiwGrIbi3fIXtSmEi2afRpXatigJtHDd7GGDwyphsRRrcrrX9omgy)Ha1lgONyFjMVj2kXqAuyrfsEzdoX8rmFtSvIHZGG8oDVPAcuvvVPhK8YgCI9LyO2QNx6oXwj2E8WNQZ0G4eZhoI5lX4AX(wSO9iX(smU5Ly)i2Yrm0xIYsU)IFfwcK4AsvqxHvr3g2orpGcRBc7b2XAX89jYOhapzIXvOG3NyO6fKyPyBy6iwIpmHyeGGOwlgYaflWiXUGsDGj2Y4Xj234mTwrqXUO1AXG05q7qSo(5jgp5moUiwhITtGy4KybwgIDTNJMEf2Ch9akS7uRR5o6bu19ff2nSdc2zHDrc7extpMJQoWEGDSUcNiJEafwDFrfKEuH9ck1bwDRUsuwA5Q4xHLajUMuf0vyv0THTt0dOWUSbCTIGIXCnaLyPySbL6atSLXdX4JraXGuUXAakXcmsmcqquRflWG0HnAvHn3rpGc7o16AUJEavDFrHDd7GGDwyjabrT(PiKE3HyFXrSfjStCn9UGsDGvdmiDyJwvy19fvq6rf2lOuhy1T6krzjU5vXVclbsCnPkORWUHDqWolSFlgHGq7Oxq194HpvNPbXjMpCeB7u9s3vphcOe7hX()xSVfBpE4t1zAqCpfH07oe7loIXTy))lgsJclQqYlBWj2xCeJBXwjgHGq7Oxq194HpvNPbXjMpCe73I9)Vy4miiVBTh(OV6Guvugy1KjMnSJhJJyReJqqOD0lO6E8WNQZ0G4eZhoI5lX(rS))f7BXohsRRrcrrX9omgy)Ha1lgONy(WrmFj2kXieeAh9cQUhp8P6mnioX8HJy(sSFkS5o6buy3PwxZD0dOQ7lkS6(Iki9Oclsd6dReLL4M7IFfwcK4AsvqxHvr3g2orpGclx9iXsXWzATIGIXhJaIbPCJ1auIfyKyeGGOwlwGbPdB0QcBUJEaf2DQ11Ch9aQ6(Ic7g2bb7SWsacIA9tri9UdX(IJylsyN4A6DbL6aRgyq6WgTQWQ7lQG0JkS4mTwvIYsCJ(IFfwcK4AsvqxHn3rpGcBc3jGQXaHeikSk62W2j6buy5kdF6cXCG9a7yTynqSuRfBqelWiX4zUjxrmCANmhjwhITtMJoXsX4jwgpkSByheSZclbiiQ1pfH07oeZhoIXTBfZFXiabrT(bjueOeLL4(3f)kS5o6buyt4obu1HrFuHLajUMuf0vIYsC7RIFf2Ch9akS6gfwC1LBgfkpcefwcK4AsvqxjklXTBl(vyZD0dOWINOQdsnG9(ZvyjqIRjvbDLOefwhiThp8mk(vwI7IFf2Ch9akSPJJED1z6BafwcK4AsvqxjklH(IFf2Ch9akS4teAsvr05AsXVbOQX4UguyjqIRjvbDLOS0Vl(vyjqIRjvbDf2nSdc2zH9ggnEduphMly0uLGmorpGhbsCnPe7)FXUHrJ3a1BXOZO1u9g9ccepcK4AsvyZD0dOWIOPdBdtKOeLL8vXVcBUJEaf2lOuhyfwcK4Asvqxjkl52IFfwcK4AsvqxHn3rpGcRxc)qQkYaRkkdScRdK2JhEg1J2dqDfwUDBjkl5Bf)kSeiX1KQGUcBUJEaf2t3BQMavv1BQWUHDqWolSqcbshwIRPcRdK2JhEg1J2dqDfwUlrzjEEXVclbsCnPkORWUHDqWolSqgaHmqu0ZlHFQdsnWOQxEbbR5D5Dn4rGextQcBUJEaf2dlvd)kUov0vIsuyrAqFyf)klXDXVclbsCnPkORWoof2JIcBUJEaf2fjStCnvyxKAgQWgPMaXZbsEKQJm6b8iqIRjLyRe7CiTUgjeff37WyG9hcuVyGEI9LyFlMBfJRfBpliqcIhG2WrpqLy)i2kXCTy7zbbsq8(Sg2jOWQOBdBNOhqH9xWAnjgZ1auI5MqYJuDKrpaxelxmTsSDErdqjgRU3Kyjqjgp6njgFmciglwQg(IXJeSjX6tSBgGyXigojgZrkxeJC3MCcXqgOyUbwd7euyxKWki9OcRdK8iv9aQ6EaQo6buIYsOV4xHLajUMuf0vy3WoiyNfwxl2Ie2jUMEoqYJu1dOQ7bO6OhGyRe7CiTUgjeff37WyG9hcuVyGEI9Ly(MyReZ1IHZGG8oSun8RQeSPhJJyRedNbb5D6Et1eOQQEtpi5Ln4e7lXqAuyrfsEzdoXwjgKqG0HL4AQWM7OhqH909MQjqvv9MkrzPFx8RWsGextQc6kSByheSZc7Ie2jUMEoqYJu1dOQ7bO6OhGyReBpJwn8bVdlvd)QkbB6TXsik6QiWCh9asTyFjg3pEUBfBLy4miiVt3BQMavv1B6bjVSbNyFj2EgTA4dE3Ap8rF1bPQOmWEqYlBWj2kX(wS9mA1Wh8oSun8RQeSPhKs1AXwjgodcY7w7Hp6RoivfLb2dsEzdoX4AXWzqqEhwQg(vvc20dsEzdoX(smUFOxSFkS5o6buypDVPAcuvvVPsuwYxf)kSeiX1KQGUc74uypkkS5o6buyxKWoX1uHDrQzOcRxEbbR5D5DnOcjVSbNy(igVe7)FXCTyrQjq8ankS4Iu)HGpcK4Asj2kXIutG4Ps4N6HLQH)JajUMuITsmCgeK3HLQHFvLGn9yCe7)FXohsRRrcrrX9omgy)Ha1lgONy(WrSVfZTIX1IbzaeYarrpKgK6ow)iqIRjLy)uyv0THTt0dOW6gK0oeum3Oe2jUMedzGI57mobdKEIX(PDetXaBakX4P5feumE2D5DnqSbkMIb2auIXJeSjX43bMy8iHFelbkXaJyl1OWIls9hc(kSlsyfKEuH9(0oviJtWaPsuwYTf)kSeiX1KQGUcBUJEafwiJtWaPcRIUnSDIEafw3ae5igJJy(oJtWajXAeX6qS(elXhMqSyedYaeByIxHDd7GGDwy)wmxl2Ie2jUME3N2PczCcgij2))ITiHDIRPhZrvhypWowxHtKrpaX(rSvIfjeffVO9OAmvvtIX1IbjVSbNy(iMVj2kXGecKoSextLOSKVv8RWM7OhqH9OnKIAqBmq7gYqfwcK4AsvqxjklXZl(vyjqIRjvbDf2Ch9akSqgNGbsf296TMQrcrrXvwI7c7g2bb7SW6AXwKWoX107(0oviJtWajXwjMRfBrc7extpMJQoWEGDSUcNiJEaITsSZH06AKquuCVdJb2Fiq9Ib6jMpCed9ITsSiHOO4fThvJPQAsmF4i23I5wX8xSVfd9ITCeBpE4t1zAqCI9Jy)i2kXGecKoSextfwfDBy7e9akS8ugD0QjIgGsSiHOO4elWYqm(TwlMUxqIHmqXcmsmfdmJEaIniI57mobdKCrmiHaPdtmfdSbOeZjbkYR3VsuwY9x8RWsGextQc6kS5o6buyHmobdKkSk62W2j6buy9DcbshMy(oJtWajXOeQxlwJiwhIXV1AXi350qsmfdSbOeJDTh(OVNy8yelWYqmiHaPdtSgrm2HhIHIItmiLQ1I1aXcmsma5Uqm3EVc7g2bb7SW6AXwKWoX107(0oviJtWajXwjgK8YgCI9Ly7z0QHp4DR9Wh9vhKQIYa7bjVSbNy(lg38sSvITNrRg(G3T2dF0xDqQkkdShK8YgCI9fhXCRyRelsikkEr7r1yQQMeJRfdsEzdoX8rS9mA1Wh8U1E4J(QdsvrzG9GKx2Gtm)fZTLOS0YvXVclbsCnPkORWUHDqWolSUwSfjStCn9yoQ6a7b2X6kCIm6bi2kXohsRRrcrrXjMpCe73f2Ch9akS46C)P6m8veSeLL4Mxf)kS5o6buyPf9TjyguHLajUMuf0vIsuy3QR4xzjUl(vyjqIRjvbDf2nSdc2zH11IHZGG8oSun8RQeSPhJJyRedNbb5DymW(dbQXabPAEmoITsmCgeK3HXa7peOgdeKQ5bjVSbNyFXrSF)CBHL5O6GGurTvLL4UWM7OhqH9Ws1WVQsWMkSk62W2j6buy5QhjgpsWMeBqq4AuBLy4eYajXcmsmKgEHyhgdS)qG6fd0tme44jMFdeKQrS94rNyn4vIYsOV4xHLajUMuf0vy3WoiyNfwCgeK3HXa7peOgdeKQ5X4i2kXWzqqEhgdS)qGAmqqQMhK8YgCI9fhX(9ZTfwMJQdcsf1wvwI7cBUJEaf2BTh(OV6GuvugyfwfDBy7e9akSFZvbA6oXsnKs1AXyCedN2jZrIXNelM5JySyPA4lM7nBM7hXyosm21E4J(eBqq4AuBLy4eYajXcmsmKgEHySymW(dbeJngONyiWXtm)giivJy7XJoXAWReLL(DXVclbsCnPkORWUHDqWolSlsyN4A6DavDpavh9aeBLyUwSlOuhyK65LGqtITsmCgeK3T2dF0xDqQkkdShJJyReBpE4t1zAqCI5dhXCBHn3rpGclIorrADg9akrzjFv8RWsGextQc6kSByheSZc73IbzaeYarrpVe(Poi1aJQE5feSM3L31GhbsCnPeBLy7XdFQotdI7PiKE3HyFXrmUfJRflsnbINIihcwVaMbHI8EeiX1KsS))fdYaiKbIIEkkdm966HLQH)9iqIRjLyReBpE4t1zAqCI9LyCl2pITsmCgeK3T2dF0xDqQkkdShJJyRedNbb5DyPA4xvjytpghXwjMxEbbR5D5DnOcjVSbNyCeJxITsmCgeKNIYatVUEyPA4Fp1WhuyZD0dOWUib9HvIYsUT4xHLajUMuf0vyv0THTt0dOW6MZOfdzGI53abPAeZbsCn7WdX43bMySy8qmiLQ1IXhJaIbMqmida0auIX6EVclYaRaYDrzjUlSByheSZcBKAceVdJb2FiqngiivZJajUMuITsmxlwKAceVdlvd)kYSzUhbsCnPkS5o6buyDMrxH0nmWnvIYs(wXVclbsCnPkORWM7OhqH9WyG9hcuJbcs1uyv0THTt0dOWYvpsm)giivJyoqsm2HhIXhJaIXNedlxqIfyKyeGGOwlgFmkWiOyiWXtmNz0naLy87aBycXyDpXgOyl3mxigkcqWuRx)kSByheSZclbiiQ1I5dhX8nEj2kXwKWoX107aQ6EaQo6bi2kX2ZOvdFW7w7Hp6RoivfLb2JXrSvITNrRg(G3HLQHFvLGn92yjefDI5dhX4wSvI9TyUwmidGqgik6n4KQjWMEeiX1KsS))ftr4miipeDII06m6b8yCe7hXwj2E8WNQZ0G4e7loIHEXwj23I5AXWzqqEoqYJuDKrpGhJJy))l25qADnsikkU3HXa7peOEXa9eZhX8Ly)uIYs88IFfwcK4AsvqxHn3rpGc7rqygKQIpaQEo9hQWUHDqWolSlsyN4A6DavDpavh9aeBLyUwm1eVJGWmivfFau9C6puvnXl69NgGsSvIfjeffVO9OAmvvtI5dhXqp3I9)VyinkSOcjVSbNyFXrm3k2kXohsRRrcrrX9omgy)Ha1lgONyFj2VlS71BnvJeIIIRSe3LOSK7V4xHLajUMuf0vy3WoiyNf2fjStCn9oGQUhGQJEaITsS94HpvNPbX9uesV7qmF4ig3f2Ch9akSh5C9vIYslxf)kSeiX1KQGUcBUJEaf2BTh(OV6GuvugyfwfDBy7e9akSC1JeJDTh(OpXgGy7z0QHpqSVtKGGIH0WleJfWJFeJbOP7eJpjwcjXqnnaLyXiMZ4iMFdeKQrSeOetnIbMqmSCbjglwQg(I5EZM5Ef2nSdc2zHDrc7extVdOQ7bO6OhGyRe7BXIutG4rGfKECAaQ6HLQH)9iqIRjLy))l2EgTA4dEhwQg(vvc20BJLqu0jMpCeJBX(rSvI9TyUwSi1eiEhgdS)qGAmqqQMhbsCnPe7)FXIutG4DyPA4xrMnZ9iqIRjLy))l2EgTA4dEhgdS)qGAmqqQMhK8YgCI5JyOxSFeBLyFlMRfBpliqcI3cceyRHI9)Vy7z0QHp4HOtuKwNrpGhK8YgCI5JyCZlX()xS9mA1Wh8q0jksRZOhWJXrSvIThp8P6mnioX8HJyUvSFkrzjU5vXVclbsCnPkORWM7OhqH1lHFivfzGvfLbwHv3aQUvfwUFUTWUxV1unsikkUYsCxy3WoiyNfwy2QkTGaXlvQ7X4i2kX(wSiHOO4fThvJPQAsSVeBpE4t1zAqCpfH07oe7)FXCTyxqPoWi1l1AXwj2E8WNQZ0G4EkcP3DiMpCeB7u9s3vphcOe7NcRIUnSDIEafw3hIyPsDILqsmghxe7aTdjwGrInasm(DGjME4txiMF(XJNyC1JeJpgbetTUbOedjVGGIfyjqSL5MIPiKE3HydumWeIDbL6aJuIXVdSHjelbRfBzU5ReLL4M7IFfwcK4AsvqxHn3rpGcRxc)qQkYaRkkdScRIUnSDIEafw3hIyGrSuPoX43ATyQMeJFhynqSaJedqUle7386CrmMJeJNIWdXgGy4ZDIXVdSHjelbRfBzU5RWUHDqWolSWSvvAbbIxQu3RbI5Jy)MxIX1IbZwvPfeiEPsDpfdmJEaITsS94HpvNPbX9uesV7qmF4i22P6LUREoeqvIYsCJ(IFfwcK4AsvqxHDd7GGDwyxKWoX107aQ6EaQo6bi2kX2Jh(uDMge3tri9UdX8HJyOxSvI9Ty7z0QHp4DR9Wh9vhKQIYa7bjVSbNyFjg3I9)Vy4miiVBTh(OV6GuvugypghX()xmKgfwuHKx2GtSV4ig65Ly)uyZD0dOWEyPA4xX1PIUsuwI7Fx8RWsGextQc6kSByheSZc7Ie2jUMEhqv3dq1rpaXwj2E8WNQZ0G4EkcP3DiMpCed9ITsSVfBrc7extpMJQoWEGDSUcNiJEaI9)VyNdP11iHOO4EhgdS)qG6fd0tSV4iMVe7)FXGmaczGOOhKUHbOAaQ6wNWow)iqIRjLy)uyZD0dOWsBSPbOQqYb2EjqvIYsC7RIFfwcK4AsvqxHn3rpGc7HXa7peOgdeKQPWQOBdBNOhqH9x6atmw3ZfXAeXatiwQHuQwlMAaKlIXCKy(nqqQgX43bMySdpeJX5vy3WoiyNf2i1eiEhwQg(vKzZCpcK4Asj2kXwKWoX107aQ6EaQo6bi2kXWzqqE3Ap8rF1bPQOmWEmoITsS94HpvNPbXj2xCed9ITsSVfZ1IHZGG8CGKhP6iJEapghX()xSZH06AKquuCVdJb2Fiq9Ib6jMpI5lX(PeLL42Tf)kSeiX1KQGUc7g2bb7SW6AXWzqqEhwQg(vvc20JXrSvIH0OWIkK8YgCI9fhXC)I5VyrQjq8og8GGimOOhbsCnPkS5o6buypSun8RQeSPsuwIBFR4xHLajUMuf0vy3WoiyNf2Vf7ggnEduphMly0uLGmorpGhbsCnPe7)FXUHrJ3a1BXOZO1u9g9ccepcK4Asj2pITsmcqquRFkcP3DiMpCe738sSvI5AXUGsDGrQxQ1ITsmCgeK3T2dF0xDqQkkdSNA4dkSniiiKXjQnsH9ggnEduVfJoJwt1B0liquyBqqqiJtuBpps1zqfwUlS5o6buyr00HTHjsuyBqqqiJturPh8uxy5UeLL4MNx8RWsGextQc6kSByheSZclodcYdxpJsZCXds5oe7)FXqAuyrfsEzdoX(sSFZlX()xmCgeK3T2dF0xDqQkkdShJJyRe7BXWzqqEhwQg(vCDQO7X4i2))ITNrRg(G3HLQHFfxNk6EqYlBWj2xCeJBEj2pf2Ch9akSot0dOeLL429x8RWsGextQc6kSByheSZclodcY7w7Hp6RoivfLb2JXPWM7OhqHfxpJQIWaxxIYsCVCv8RWsGextQc6kSByheSZclodcY7w7Hp6RoivfLb2JXPWM7OhqHfNGhb)0auLOSe65vXVclbsCnPkORWUHDqWolS4miiVBTh(OV6GuvugypgNcBUJEafwKgs46zuLOSe65U4xHLajUMuf0vy3WoiyNfwCgeK3T2dF0xDqQkkdShJtHn3rpGcBc20fWux3PwxIYsOh9f)kSeiX1KQGUcBUJEafwMJQDqExHvr3g2orpGclpiKKrhIHKAnEU)igYafJ5sCnjwhK39RIXvpsm(DGjg7Ap8rFIniIXdkdSxHDd7GGDwyXzqqE3Ap8rF1bPQOmWEmoI9)VyinkSOcjVSbNyFjg65vjkrH9ck1bwDRUIFLL4U4xHLajUMuf0vyhNc7rrHn3rpGc7Ie2jUMkSlsndvy3ZOvdFW7Ws1WVQsWMEBSeIIUkcm3rpGulMpCeJ7hp3TfwfDBy7e9akSUbjTdbfZnkHDIRPc7IewbPhvypmvnWG0HnAvjklH(IFfwcK4AsvqxHn3rpGc7Ie0hwHvr3g2orpGcRBuc6dtSgrm(KyjKeBNoonaLydqmEKGnj2glHOO7jgpPeQxlgoHmqsmKgEHyQeSjXAeX4tIHLliXaJyl1OWIls9hckgotigps4hXyXs1WxSgi2aveuSyedffI57mobdKeJXrSVbJy808cckgp7U8Ug8ZRWUHDqWolSFlMRfBrc7extVdtvdmiDyJwj2))I5AXIutG4bAuyXfP(dbFeiX1KsSvIfPMaXtLWp1dlvd)hbsCnPe7hXwj2E8WNQZ0G4EkcP3DiMpIXTyReZ1IbzaeYarrpVe(Poi1aJQE5feSM3L31GhbsCnPkrzPFx8RWsGextQc6kSk62W2j6buyDZz0IHmqXyXs1W3J0kX8xmwSun8Va2FiXyaA6oX4tILqsSeFycXIrSD6i2aeJhjytITXsik6EI5gd0RfJpgbeZ9AGsSFHYpa6oX6tSeFycXIrmidqSHjEfwKbwbK7IYsCxy3WoiyNfwyUPhOrHfvsJuyj3fWSMEddikS(Ixf2Ch9akSoZORq6gg4MkrzjFv8RWsGextQc6kSByheSZclbiiQ1I5dhX8fVeBLyeGGOw)uesV7qmF4ig38sSvI5AXwKWoX107Wu1adsh2OvITsS94HpvNPbX9uesV7qmFeJBXwjMIWzqqEinqv5t5haD3dsEzdoX(smUlS5o6buypSun89iTQeLLCBXVclbsCnPkORWoof2JIcBUJEaf2fjStCnvyxKAgQWUhp8P6mniUNIq6DhI5dhXqVy(lgodcY7Ws1WVIRtfDpgNcRIUnSDIEaf2L5MIfyq6WgT6edzGIrGGGnaLySyPA4lgpsWMkSlsyfKEuH9Wu194HpvNPbXvIYs(wXVclbsCnPkORWoof2JIcBUJEaf2fjStCnvyxKAgQWUhp8P6mniUNIq6DhI5dhX(DHDd7GGDwy3ZccKG49znStqHDrcRG0JkShMQUhp8P6mniUsuwINx8RWsGextQc6kSJtH9OOWM7OhqHDrc7extf2fPMHkS7XdFQotdI7PiKE3HyFXrmUlSByheSZc7Ie2jUMEmhvDG9a7yDforg9aeBLyNdP11iHOO4EhgdS)qG6fd0tmF4iMVkSlsyfKEuH9Wu194HpvNPbXvIYsU)IFfwcK4AsvqxHn3rpGc7HLQHFvLGnvyv0THTt0dOWYJeSjXumWgGsm21E4J(eBGIL4ZcsSadsh2OvVc7g2bb7SWUiHDIRP3HPQ7XdFQotdItSvI9TylsyN4A6DyQAGbPdB0kX()xmCgeK3T2dF0xDqQkkdShK8YgCI5dhX4(HEX()xSZH06AKquuCVdJb2Fiq9Ib6jMpCeZxITsS9mA1Wh8U1E4J(QdsvrzG9GKx2GtmFeJBEj2pLOS0YvXVclbsCnPkORWM7OhqH9Ws1WVQsWMkSk62W2j6buyrhdeigK8Yg0auIXJeSPtmCczGKybgjgsJcleJaQtSgrm2HhIXFa8oedNedsPATynqSO9OxHDd7GGDwyxKWoX107Wu194HpvNPbXj2kXqAuyrfsEzdoX(sS9mA1Wh8U1E4J(QdsvrzG9GKx2GReLOWIZ0AvXVYsCx8RWsGextQc6kSByheSZcRRflsnbIhOrHfxK6pe8rGextkXwjgKbqidef9IgSUgJ76DfxNk6rGextkXwj25qADnsikkU3HXa7peOEXa9e7lXCBHn3rpGc7H1lkrzj0x8RWsGextQc6kSByheSZc75qADnsikkoX8HJyOxSvI9TyUwS9SGajiEaAdh9avI9)Vy7z0QHp4DeeMbPQ4dGQNt)HEEP7QBSeIIoX4AX2yjefDveyUJEaPwmF4igVEO3TI9)VyNdP11iHOO4EhgdS)qG6fd0tmFeZxI9tHn3rpGc7HXa7peOEXa9krzPFx8RWsGextQc6kSByheSZc7EgTA4dEhbHzqQk(aO650FONx6U6glHOOtmUwSnwcrrxfbM7OhqQf7loIXRh6DRy))l2nmA8gOEAkvv81vYDPNJMEeiX1KsSvI5AXWzqqEAkvv81vYDPNJMEmof2Ch9akShbHzqQk(aO650FOsuwYxf)kS5o6buyrPNXdxNkQWsGextQc6krzj3w8RWM7OhqHfp3FUiXlSeiX1KQGUsuIsuyxqWRhqzj0Zl0ZnV458Y3kS8tiObOUc7VWZ89LCFlXt8RIjMFyKyTNZadXqgOy8(ck1bgP4TyqYnKPHKsSB8iXsMy8YGuITXsak6EcACLgqI5RFvSLnGfemiLy8gYaiKbIIElpVflgX4nKbqidef9w(hbsCnP4TyFZT7(5jOXvAajgp)xfBzdybbdsjgVHmaczGOO3YZBXIrmEdzaeYarrVL)rGextkEl23C7UFEcAcA)cpZ3xY9TepXVkMy(HrI1EodmedzGIXBhiThp8m4TyqYnKPHKsSB8iXsMy8YGuITXsak6EcACLgqI97FvSLnGfemiLy8(ggnEduVLN3IfJy8(ggnEduVL)rGextkEl23C7UFEcACLgqI97FvSLnGfemiLy8(ggnEduVLN3IfJy8(ggnEduVL)rGextkElwgIXtYnMRi23C7UFEcACLgqIXZ)vXw2awqWGuIXBidGqgik6T88wSyeJ3qgaHmqu0B5FeiX1KI3ILHy8KCJ5kI9n3U7NNGMG2VWZ89LCFlXt8RIjMFyKyTNZadXqgOy8gPb9HXBXGKBitdjLy34rILmX4LbPeBJLau09e04knGeZx)QylBaliyqkX4nKbqidef9wEElwmIXBidGqgik6T8pcK4AsXBX(MB39Ztqtq7x4z((sUVL4j(vXeZpmsS2ZzGHyidumEVvhVfdsUHmnKuIDJhjwYeJxgKsSnwcqr3tqJR0asmF9RITSbSGGbPeJ3qgaHmqu0B55TyXigVHmaczGOO3Y)iqIRjfVf7B07UFEcACLgqI5B)QylBaliyqkX4nKbqidef9wEElwmIXBidGqgik6T8pcK4AsXBX(MB39ZtqJR0asmU)9Vk2YgWccgKsmEdzaeYarrVLN3IfJy8gYaiKbIIEl)JajUMu8wSV52D)8e04knGeJBF7xfBzdybbdsjgVVHrJ3a1B55TyXigVVHrJ3a1B5FeiX1KI3I9n6D3ppbnbTFHN57l5(wIN4xftm)WiXApNbgIHmqX49fuQdS6wD8wmi5gY0qsj2nEKyjtmEzqkX2yjafDpbnUsdiXq)Vk2YgWccgKsmEdzaeYarrVLN3IfJy8gYaiKbIIEl)JajUMu8wSmeJNKBmxrSV52D)8e0e0(fEMVVK7BjEIFvmX8dJeR9CgyigYafJ34mTwXBXGKBitdjLy34rILmX4LbPeBJLau09e04knGeJ7FvSLnGfemiLy8gYaiKbIIElpVflgX4nKbqidef9w(hbsCnP4TyFZT7(5jOjO5(8CgyqkX45IL7OhGy6(I7jOvyDGdsRPcRRCLySm4HMI1I57dkgsqZvUsm0y0RfZ97IyONxONBbnbnx5kXwgwcqr3VkO5kxjgxlgpDwqITiHDIRPhZrvhypWowxHtKrpaXyCe7gX6qS(e7OqmCczGKy8jXyosSoEcAUYvIX1ITSXdVbKyEm6OD0Ky7uRR5o6bu19fIrGa20jwmIbjfZMeZzcceDQfds8h4NNGMRCLyCTy808djM7PPdBdtKqSgeeeY4eI1aX2JhEgI1iIXNeB5M5cXuTsSoedzGITy0z0AQEJEbbINGMGMRCLyUjK46LnE4ziOL7OhW9CG0E8WZWFoCjDC0RRotFdqql3rpG75aP94HNH)C4c(eHMuveDUMu8BaQAmURbcA5o6bCphiThp8m8Ndxq00HTHjs4sJW5ggnEduphMly0uLGmorpG))VHrJ3a1BXOZO1u9g9ccecA5o6bCphiThp8m8NdxUGsDGjOL7OhW9CG0E8WZWFoCXlHFivfzGvfLbMloqApE4zupApa1XHB3kOL7OhW9CG0E8WZWFoC509MQjqvv9MCXbs7XdpJ6r7bOooC7sJWbsiq6WsCnjOL7OhW9CG0E8WZWFoC5Ws1WVIRtfDU0iCGmaczGOONxc)uhKAGrvV8ccwZ7Y7AGGMGMRCLy80SbI57tKrpabTCh9aooF69hbnxjgx9iLyXiMIcc61asm(yuGrqX2ZOvdFWjg)SdXqgOySaEigEEKsSbiwKquuCpbTCh9ao)5WLfjStCn5ci9iohqv3dq1rpaxwKAgIdodcY709MQjqvv9MEmo))FoKwxJeIII7DymW(dbQxmqpF44BcAUsm3yGETyBSeGIedorg9aeRreJpjgwUGeZb2dSJ1v4ez0dqSJcXsGsmpgD0oAsSiHOO4eJX5jOL7OhW5phUSiHDIRjxaPhXH5OQdShyhRRWjYOhGllsndXXb2dSJ1v4ez0dy15qADnsikkU3HXa7peOEXa98Hd6f0CLyC1JuIfJykcPbKy8XiGyXigZrIDbL6atSLXJtSbkgotRve8e0YD0d48NdxwKWoX1KlG0J4CbL6aRgyq6WgTYLfPMH4GE36FKAceVfnQb(iqIRj1Yb98Y)i1eiEE5feSoi1dlvd)7rGextQLd65L)rQjq8oSun8RiZM5EeiX1KA5GE36FKAceVuNByhRFeiX1KA5GEE5p6D7Y57ZH06AKquuCVdJb2Fiq9Ib65dhF9JGMReBzy0(JylJhNyzigsdVqql3rpGZFoCzNADn3rpGQUVWfq6rC2QtqZvI57maXqy061ID87yJrNyXiwGrIXguQdmsjMVprg9ae7B81IPMgGsSBCrSoedzGB6eZzgDdqjwJigycSgGsS(elxKToX10ppbTCh9ao)5WfidOM7Ohqv3x4ci9ioxqPoWiLlncNlOuhyK6LATGMReJN54OxlgRU3Kyjqjgp6njwgIHE)fBzUPykgydqjwGrIH0WleJBEj2r7bOoxelrcckwGLHy(YFXwMBkwJiwhIrUZPH0jg)oWAGybgjgGCxigpXY4HyduS(edmHymocA5o6bC(ZHlNU3unbQQQ3KlncNZH06AKquuCVdJb2Fiq9Ib69LVTcPrHfvi5Ln48X3wHZGG8oDVPAcuvvVPhK8YgCFHAREEP7wThp8P6mnioF44lU(7O9OV4Mx)SCqVGMReZnH9a7yTy((ez0dGNmX4kuW7tmu9csSuSnmDelXhMqmcqquRfdzGIfyKyxqPoWeBz84e7BCMwRiOyx0ATyq6CODiwh)8eJNCghxeRdX2jqmCsSaldXU2ZrtpbTCh9ao)5WLDQ11Ch9aQ6(cxaPhX5ck1bwDRoxAeolsyN4A6XCu1b2dSJ1v4ez0dqqZvITSbCTIGIXCnaLyPySbL6atSLXdX4JraXGuUXAakXcmsmcqquRflWG0HnALGwUJEaN)C4Yo16AUJEavDFHlG0J4CbL6aRUvNlnchcqquRFkcP3D8fNfjStCn9UGsDGvdmiDyJwjOL7OhW5phUStTUM7Ohqv3x4ci9ioinOpmxAeoFtii0o6fuDpE4t1zAqC(Wz7u9s3vphcO(5))V3Jh(uDMge3tri9UJV4W9))inkSOcjVSb3xC4EfHGq7Oxq194HpvNPbX5dNF))podcY7w7Hp6RoivfLbwnzIzd74X4SIqqOD0lO6E8WNQZ0G48HJV(5))VphsRRrcrrX9omgy)Ha1lgONpC81kcbH2rVGQ7XdFQotdIZho(6hbnxjgx9iXsXWzATIGIXhJaIbPCJ1auIfyKyeGGOwlwGbPdB0kbTCh9ao)5WLDQ11Ch9aQ6(cxaPhXbNP1kxAeoeGGOw)uesV74lolsyN4A6DbL6aRgyq6WgTsqZvIXvg(0fI5a7b2XAXAGyPwl2GiwGrIXZCtUIy40ozosSoeBNmhDILIXtSmEiOL7OhW5phUKWDcOAmqibcxAeoeGGOw)uesV7WhoC7w)jabrT(bjueqql3rpGZFoCjH7eqvhg9rcA5o6bC(ZHl6gfwC1LBgfkpcecA5o6bC(ZHl4jQ6GudyV)CcAcAUYvIHoMwRi4jOL7OhW9WzATIZH1lCPr446i1eiEGgfwCrQ)qWhbsCnPwbzaeYarrVObRRX4UExX1PIwDoKwxJeIII7DymW(dbQxmqVVCRGwUJEa3dNP1k)5WLdJb2Fiq9Ib65sJW5CiTUgjeffNpCq)QVD9EwqGeepaTHJEGQ))3ZOvdFW7iimdsvXhavpN(d98s3v3yjefDC9glHOORIaZD0di1(WHxp072))phsRRrcrrX9omgy)Ha1lgONp(6hbTCh9aUhotRv(ZHlhbHzqQk(aO650FixAeo7z0QHp4DeeMbPQ4dGQNt)HEEP7QBSeIIoUEJLqu0vrG5o6bK6V4WRh6D7))3WOXBG6PPuvXxxj3LEoA6rGextQvUgNbb5PPuvXxxj3LEoA6X4iOL7OhW9WzATYFoCbLEgpCDQibTCh9aUhotRv(ZHl45(ZfjUGMGMRCLylBgTA4dobnxjgx9iX4rc2KydccxJARedNqgijwGrIH0Wle7WyG9hcuVyGEIHahpX8BGGunIThp6eRbpbTCh9aU3wDCoSun8RQeSjxyoQoiivuBfhUDPr44ACgeK3HLQHFvLGn9yCwHZGG8omgy)Ha1yGGunpgNv4miiVdJb2FiqngiivZdsEzdUV487NBf0CLyFZvbA6oXsnKs1AXyCedN2jZrIXNelM5JySyPA4lM7nBM7hXyosm21E4J(eBqq4AuBLy4eYajXcmsmKgEHySymW(dbeJngONyiWXtm)giivJy7XJoXAWtql3rpG7TvN)C4YT2dF0xDqQkkdmxyoQoiivuBfhUDPr4GZGG8omgy)Ha1yGGunpgNv4miiVdJb2FiqngiivZdsEzdUV487NBf0YD0d4EB15phUGOtuKwNrpaxAeolsyN4A6DavDpavh9aw56lOuhyK65LGqtRWzqqE3Ap8rF1bPQOmWEmoR2Jh(uDMgeNpCCRGwUJEa3BRo)5WLfjOpmxAeoFdzaeYarrpVe(Poi1aJQE5feSM3L31Gv7XdFQotdI7PiKE3XxC4MRJutG4PiYHG1lGzqOiVhbsCnP()hYaiKbIIEkkdm966HLQH)TApE4t1zAqCFX9pRWzqqE3Ap8rF1bPQOmWEmoRWzqqEhwQg(vvc20JXzLxEbbR5D5DnOcjVSbhhETcNbb5POmW0RRhwQg(3tn8bcAUsm3CgTyidum)giivJyoqIRzhEig)oWeJfJhIbPuTwm(yeqmWeIbzaGgGsmw37jOL7OhW92QZFoCXzgDfs3Wa3KlidSci3fC42LgHtKAceVdJb2FiqngiivZJajUMuRCDKAceVdlvd)kYSzUhbsCnPe0CLyC1JeZVbcs1iMdKeJD4Hy8XiGy8jXWYfKybgjgbiiQ1IXhJcmckgcC8eZzgDdqjg)oWgMqmw3tSbk2YnZfIHIaem161pbTCh9aU3wD(ZHlhgdS)qGAmqqQgxAeoeGGOw7dhFJxRwKWoX107aQ6EaQo6bSApJwn8bVBTh(OV6GuvugypgNv7z0QHp4DyPA4xvjytVnwcrrNpC4E13UgYaiKbIIEdoPAcSP))veodcYdrNOiToJEapgNFwThp8P6mniUV4G(vF7ACgeKNdK8ivhz0d4X48))5qADnsikkU3HXa7peOEXa98Xx)iOL7OhW92QZFoC5iimdsvXhavpN(d5YE9wt1iHOO44WTlncNfjStCn9oGQUhGQJEaRCTAI3rqygKQIpaQEo9hQQM4f9(tdqTksikkEr7r1yQQM8Hd65()FKgfwuHKx2G7loUD15qADnsikkU3HXa7peOEXa9(63cA5o6bCVT68NdxoY56ZLgHZIe2jUMEhqv3dq1rpGv7XdFQotdI7PiKE3HpC4wqZvIXvpsm21E4J(eBaITNrRg(aX(orcckgsdVqmwap(rmgGMUtm(KyjKed10auIfJyoJJy(nqqQgXsGsm1igycXWYfKySyPA4lM7nBM7jOL7OhW92QZFoC5w7Hp6RoivfLbMlncNfjStCn9oGQUhGQJEaR(osnbIhbwq6XPbOQhwQg(3JajUMu))VNrRg(G3HLQHFvLGn92yjefD(WH7Fw9TRJutG4DymW(dbQXabPAEeiX1K6))i1eiEhwQg(vKzZCpcK4As9))EgTA4dEhgdS)qGAmqqQMhK8YgC(G(Fw9TR3ZccKG4TGab2A4))7z0QHp4HOtuKwNrpGhK8YgC(WnV()FpJwn8bpeDII06m6b8yCwThp8P6mnioF442Fe0CLyUpeXsL6elHKymoUi2bAhsSaJeBaKy87atm9WNUqm)8JhpX4QhjgFmciMADdqjgsEbbflWsGylZnftri9UdXgOyGje7ck1bgPeJFhydtiwcwl2YCZNGwUJEa3BRo)5WfVe(HuvKbwvugyUOBav3koC)CRl71BnvJeIIIJd3U0iCGzRQ0cceVuPUhJZQVJeIIIx0EunMQQPV2Jh(uDMge3tri9UJ))D9fuQdms9sTE1E8WNQZ0G4EkcP3D4dNTt1lDx9CiG6hbnxjM7drmWiwQuNy8BTwmvtIXVdSgiwGrIbi3fI9BEDUigZrIXtr4Hydqm85oX43b2WeILG1ITm38jOL7OhW92QZFoCXlHFivfzGvfLbMlnchy2QkTGaXlvQ71aF(nV4Ay2QkTGaXlvQ7PyGz0dy1E8WNQZ0G4EkcP3D4dNTt1lDx9CiGsql3rpG7TvN)C4YHLQHFfxNk6CPr4SiHDIRP3bu19auD0dy1E8WNQZ0G4EkcP3D4dh0V679mA1Wh8U1E4J(QdsvrzG9GKx2G7lU))hNbb5DR9Wh9vhKQIYa7X48)psJclQqYlBW9fh0ZRFe0YD0d4EB15phUqBSPbOQqYb2Ejq5sJWzrc7extVdOQ7bO6OhWQ94HpvNPbX9uesV7WhoOF13lsyN4A6XCu1b2dSJ1v4ez0d4))ZH06AKquuCVdJb2Fiq9Ib69fhF9)pKbqidef9G0nmavdqv36e2X6Fe0CLy)shyIX6EUiwJigycXsnKs1AXudGCrmMJeZVbcs1ig)oWeJD4HymopbTCh9aU3wD(ZHlhgdS)qGAmqqQgxAeorQjq8oSun8RiZM5EeiX1KA1Ie2jUMEhqv3dq1rpGv4miiVBTh(OV6GuvugypgNv7XdFQotdI7loOF13UgNbb55ajps1rg9aEmo))FoKwxJeIII7DymW(dbQxmqpF81pcA5o6bCVT68NdxoSun8RQeSjxAeoUgNbb5DyPA4xvjytpgNvinkSOcjVSb3xCC)(hPMaX7yWdcIWGIEeiX1Ksql3rpG7TvN)C4cIMoSnmrcxAeoFFdJgVbQNdZfmAQsqgNOhW))3WOXBG6Ty0z0AQEJEbbIFwracIA9tri9UdF48BETY1xqPoWi1l16v4miiVBTh(OV6Guvugyp1Wh4sdccczCIA75rQodId3U0GGGqgNOIsp4PMd3U0GGGqgNO2iCUHrJ3a1BXOZO1u9g9ccecA5o6bCVT68NdxCMOhGlnchCgeKhUEgLM5IhKYD8)psJclQqYlBW91V51))4miiVBTh(OV6GuvugypgNvFJZGG8oSun8R46ur3JX5))9mA1Wh8oSun8R46ur3dsEzdUV4WnV(rql3rpG7TvN)C4cUEgvfHbU2LgHdodcY7w7Hp6RoivfLb2JXrql3rpG7TvN)C4cobpc(PbOCPr4GZGG8U1E4J(QdsvrzG9yCe0YD0d4EB15phUG0qcxpJYLgHdodcY7w7Hp6RoivfLb2JXrql3rpG7TvN)C4sc20fWux3Pw7sJWbNbb5DR9Wh9vhKQIYa7X4iO5kX4bHKm6qmKuRXZ9hXqgOymxIRjX6G8UFvmU6rIXVdmXyx7Hp6tSbrmEqzG9e0YD0d4EB15phUWCuTdY7CPr4GZGG8U1E4J(QdsvrzG9yC()hPrHfvi5Ln4(c98sqtqZvUsm3Rb9HrWtqZvI9lyTMeJ5AakXCti5rQoYOhGlILlMwj2oVObOeJv3BsSeOeJh9MeJpgbeJflvdFX4rc2Ky9j2ndqSyedNeJ5iLlIrUBtoHyidum3aRHDce0YD0d4EinOpmolsyN4AYfq6rCCGKhPQhqv3dq1rpaxwKAgItKAcephi5rQoYOhWJajUMuRohsRRrcrrX9omgy)Ha1lgO3xF7wUEpliqcIhG2Wrpq1pRC9EwqGeeVpRHDce0YD0d4EinOpm)5WLt3BQMavv1BYLgHJRxKWoX10ZbsEKQEavDpavh9awDoKwxJeIII7DymW(dbQxmqVV8TvUgNbb5DyPA4xvjytpgNv4miiVt3BQMavv1B6bjVSb3xinkSOcjVSb3kiHaPdlX1KGwUJEa3dPb9H5phUC6Et1eOQQEtU0iCwKWoX10ZbsEKQEavDpavh9awTNrRg(G3HLQHFvLGn92yjefDveyUJEaP(lUF8C3UcNbb5D6Et1eOQQEtpi5Ln4(ApJwn8bVBTh(OV6Guvugypi5Ln4w99EgTA4dEhwQg(vvc20dsPA9kCgeK3T2dF0xDqQkkdShK8YgCCnodcY7Ws1WVQsWMEqYlBW9f3p0)JGMReZniPDiOyUrjStCnjgYafZ3zCcgi9eJ9t7iMIb2auIXtZliOy8S7Y7AGydumfdSbOeJhjytIXVdmX4rc)iwcuIbgXwQrHfxK6pe8jOL7OhW9qAqFy(ZHllsyN4AYfq6rCUpTtfY4emqYLfPMH44LxqWAExExdQqYlBW5dV()31rQjq8ankS4Iu)HGpcK4AsTksnbINkHFQhwQg(pcK4AsTcNbb5DyPA4xvjytpgN))phsRRrcrrX9omgy)Ha1lgONpC(2TCnKbqidef9qAqQ7y9pcAUsm3ae5igJJy(oJtWajXAeX6qS(elXhMqSyedYaeByINGwUJEa3dPb9H5phUazCcgi5sJW5BxViHDIRP39PDQqgNGbs))ViHDIRPhZrvhypWowxHtKrpGFwfjeffVO9OAmvvtCnK8YgC(4BRGecKoSextcA5o6bCpKg0hM)C4YrBif1G2yG2nKHe0CLy8ugD0QjIgGsSiHOO4elWYqm(TwlMUxqIHmqXcmsmfdmJEaIniI57mobdKCrmiHaPdtmfdSbOeZjbkYR3pbTCh9aUhsd6dZFoCbY4emqYL96TMQrcrrXXHBxAeoUErc7extV7t7uHmobdKw56fjStCn9yoQ6a7b2X6kCIm6bS6CiTUgjeff37WyG9hcuVyGE(Wb9RIeIIIx0EunMQQjF48TB9)B0VC2Jh(uDMge3p)Scsiq6WsCnjO5kX8DcbshMy(oJtWajXOeQxlwJiwhIXV1AXi350qsmfdSbOeJDTh(OVNy8yelWYqmiHaPdtSgrm2HhIHIItmiLQ1I1aXcmsma5Uqm3EpbTCh9aUhsd6dZFoCbY4emqYLgHJRxKWoX107(0oviJtWaPvqYlBW91EgTA4dE3Ap8rF1bPQOmWEqYlBW5p38A1EgTA4dE3Ap8rF1bPQOmWEqYlBW9fh3UksikkEr7r1yQQM4Ai5Ln48zpJwn8bVBTh(OV6Guvugypi5Ln483TcA5o6bCpKg0hM)C4cUo3FQodFfbDPr446fjStCn9yoQ6a7b2X6kCIm6bS6CiTUgjeffNpC(TGwUJEa3dPb9H5phUql6BtWmibnbnx5kXydk1bMylBgTA4dobnxjMBqs7qqXCJsyN4Asql3rpG7DbL6aRUvhNfjStCn5ci9iohMQgyq6WgTYLfPMH4SNrRg(G3HLQHFvLGn92yjefDveyUJEaP2hoC)45UvqZvI5gLG(WeRreJpjwcjX2PJtdqj2aeJhjytITXsik6EIXtkH61IHtidKedPHxiMkbBsSgrm(Kyy5csmWi2snkS4Iu)HGIHZeIXJe(rmwSun8fRbInqfbflgXqrHy(oJtWajXyCe7BWigpnVGGIXZUlVRb)8e0YD0d4ExqPoWQB15phUSib9H5sJW5BxViHDIRP3HPQbgKoSrR()31rQjq8ankS4Iu)HGpcK4AsTksnbINkHFQhwQg(pcK4As9ZQ94HpvNPbX9uesV7WhUx5AidGqgik65LWp1bPgyu1lVGG18U8UgiO5kXCZz0IHmqXyXs1W3J0kX8xmwSun8Va2FiXyaA6oX4tILqsSeFycXIrSD6i2aeJhjytITXsik6EI5gd0RfJpgbeZ9AGsSFHYpa6oX6tSeFycXIrmidqSHjEcA5o6bCVlOuhy1T68NdxCMrxH0nmWn5cYaRaYDbhUDHCxaZA6nmGGJV4LlnchyUPhOrHfvsJiOL7OhW9UGsDGv3QZFoC5Ws1W3J0kxAeoeGGOw7dhFXRveGGOw)uesV7WhoCZRvUErc7extVdtvdmiDyJwTApE4t1zAqCpfH07o8H7vkcNbb5H0avLpLFa0Dpi5Ln4(IBbnxj2YCtXcmiDyJwDIHmqXiqqWgGsmwSun8fJhjytcA5o6bCVlOuhy1T68NdxwKWoX1KlG0J4CyQ6E8WNQZ0G4CzrQzio7XdFQotdI7PiKE3HpCqV)4miiVdlvd)kUov09yCe0YD0d4ExqPoWQB15phUSiHDIRjxaPhX5Wu194HpvNPbX5YIuZqC2Jh(uDMge3tri9UdF48BxAeo7zbbsq8(Sg2jqql3rpG7DbL6aRUvN)C4YIe2jUMCbKEeNdtv3Jh(uDMgeNllsndXzpE4t1zAqCpfH07o(Id3U0iCwKWoX10J5OQdShyhRRWjYOhWQZH06AKquuCVdJb2Fiq9Ib65dhFjO5kX4rc2Kykgydqjg7Ap8rFInqXs8zbjwGbPdB0QNGwUJEa37ck1bwDRo)5WLdlvd)QkbBYLgHZIe2jUMEhMQUhp8P6mniUvFViHDIRP3HPQbgKoSrR()hNbb5DR9Wh9vhKQIYa7bjVSbNpC4(H())phsRRrcrrX9omgy)Ha1lgONpC81Q9mA1Wh8U1E4J(QdsvrzG9GKx2GZhU51pcAUsm0XabIbjVSbnaLy8ibB6edNqgijwGrIH0OWcXiG6eRreJD4Hy8haVdXWjXGuQwlwdelAp6jOL7OhW9UGsDGv3QZFoC5Ws1WVQsWMCPr4SiHDIRP3HPQ7XdFQotdIBfsJclQqYlBW91EgTA4dE3Ap8rF1bPQOmWEqYlBWjOjO5kxjgBqPoWiLy((ez0dqqZvI5(qeJnOuhyCzrc6dtSesIX44IymhjglwQg(xa7pKyXigobiKoedboEIfyKyo5D9csm8bWCILaLyUxduI9lu(bq35Iy0cciwJigFsSesILHyEP7eBzUPyFZa00DIXCnaLy808cckgp7U8Ug8JGwUJEa37ck1bgP4CyPA4FbS)qU0iC(gNbb5DbL6a7X48)podcYBrc6d7X48ZkV8ccwZ7Y7AqfsEzdoo8sqZvI5EnOpmXYqSF7VylZnfJFhydtigpyfJlI5l)fJFhyIXdwX43bMySymW(dbeZVbcs1igodcIymoIfJy5IPvIDJhj2YCtX4NxqIDDWKrpG7jO5kX4z6Be7sesSyedPb9HjwgI5l)fBzUPy87atmYD5o0RfZxIfjeff3tSVztpsS8eByIRvKyxqPoWE)iO5kXCVg0hMyziMV8xSL5MIXVdSHjeJhSUiMB9xm(DGjgpyDrSeOeZ3eJFhyIXdwXsKGGI5gLG(We0YD0d4ExqPoWiL)C4Yo16AUJEavDFHlG0J4G0G(WCPr4qii0o6fuDpE4t1zAqC(Wz7u9s3vphcO()hNbb5DymW(dbQXabPAEmoR2Jh(uDMge3tri9UJV4G())phsRRrcrrX9omgy)Ha1lgONpC81kcbH2rVGQ7XdFQotdIZho(6))94HpvNPbX9uesV74loCZ1FhPMaXtrKdbRxaZirrEpcK4AsTcNbb5Tib9H9yC(rql3rpG7DbL6aJu(ZHlhwQg(xa7pKlncNlOuhyK6DKZ13QZH06AKquuCVdJb2Fiq9Ib69LVe0YD0d4ExqPoWiL)C4YH1lCPr4ePMaXd0OWIls9hc(iqIRj1kidGqgik6fnyDng317kUov0QZH06AKquuCVdJb2Fiq9Ib69LBf0CLyCvhXIrSFlwKquuCI9nyeZb2ZpI9HihXyCeZ9AGsSFHYpa6oXWxl2E9w3auIXILQH)fW(d9e0YD0d4ExqPoWiL)C4YHLQH)fW(d5YE9wt1iHOO44WTlnchxViHDIRPhZrvhypWowxHtKrpGvkcNbb5H0avLpLFa0Dpi5Ln4(I7vNdP11iHOO4EhgdS)qG6fd07lo)EvKquu8I2JQXuvnX1qYlBW5JVjO5kXCVbkMdShyhRfdorg9aCrmMJeJflvd)lG9hsSzbbfJngONy87atSFHNkwIkBWfIX4iwmI5lXIeIIItSbkwJiM79lI1NyqgaObOeBqqe77biwcwlw6nmGqSbrSiHOO4(rql3rpG7DbL6aJu(ZHlhwQg(xa7pKlncNfjStCn9yoQ6a7b2X6kCIm6bS6BfHZGG8qAGQYNYpa6UhK8YgCFX9))rQjq84tPZa8Yli4JajUMuRohsRRrcrrX9omgy)Ha1lgO3xC81pcA5o6bCVlOuhyKYFoC5WyG9hcuVyGEU0iCohsRRrcrrX5dNF7)34miiVaJQWjcc8yC()hYaiKbIIE5NmH9vVHrxrGjkpce)S6BCgeK3T2dF0xDqQkkdSAYeZg2XJX5)FxJZGG8CGKhP6iJEapgN))phsRRrcrrX5dh3(JGMReJflvd)lG9hsSyedsiq6WeZ9AGsSFHYpa6oXsGsSyeJahdKeJpj2obITtiCTyZcckwkgcJwlM79lI1GyelWiXaK7cXyhEiwJiMZCxJRPNGwUJEa37ck1bgP8NdxoSun8Va2FixAeokcNbb5H0avLpLFa0Dpi5Ln4(Id3))VNrRg(G3T2dF0xDqQkkdShK8YgCFXT7FLIWzqqEinqv5t5haD3dsEzdUV2ZOvdFW7w7Hp6RoivfLb2dsEzdobTCh9aU3fuQdms5phUGspJhUovKlnchCgeKNdbrgygKQUGAW9Ui3F8HJBxThGIPJNdbrgygKQUGAW9Gj4JpC4(3cA5o6bCVlOuhyKYFoC5Ws1W)cy)He0YD0d4ExqPoWiL)C4YgJsN6HnHlnchxhjeffV(Q4ZDR2Jh(uDMge3tri9UdF4W9kCgeK3HnrTb1aJQQe(5X4SIaee16x0EunMQV4LpO2QNx6Uc75q7YsO334UeLOua]] )

    
end
