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


    spec:RegisterPack( "Subtlety", 20210627, [[da1G3bqifv8isvSjG4tkQYOqL4uqjTkuPQELqvZcvPBHkf7cWVasnmsfDmufldOQNHkLMMqrxJuP2gPc(gQuX4uuv15iviToOeAEaj3dvSpHs)dkrjhekrwiqLhQOstevsxevQK2iPk1hvuvzKOsLQtsQqTsGYlrLkLzsQKCtuPk7uOYpHsumusvYsjvINcvtLuvxfkbBLuH4RkQkJLuj1zHsuQ9kXFL0GPCyrlgfpwHjtYLr2meFgkgnKoTuRgvQeVwrmBb3wi7wv)wPHtkhhkr1Yb9CvMovxhL2UIY3rvnEHcNxrA(qP2pXfEk6xWvPtL4aVobpp6uhap3bGhUtm5b86OfCFQgvW1YXKedvW)mIk44SmEG8PfCTCAytvr)c(TSWbvWrDx7WIGg0yAhLLbySrG(6i2q69(dyI4G(6ObOl4mSDW1XFHPGRsNkXbEDcEE0PoaEUdapCNyYdp6qbpzD0fwWX7O5wWrBLI(ctbxr3OGJZY4bYNkMUSyyjbmWyFsmWZD4vmWRtWZJaMag3BNrInlHDYeia2JQAWEHTpTcxp9EFXy1e7wXAxS(e7ixmgczHKy8jXypsS2beWM7gX0pjweBWBTaj2idHAo8E)AOpxm6DytNy(kgKuSdsmT1P37migK4VWjaf8qF(v0VGFoLbhLuf9lXXtr)co9jtGufWvWZH37xWp0uT8ph2tOcUIUbS18E)cUogrmCNYGJc6z53hQyjKeJvJxXypsmC0uT8ph2tiX8vmg6jK2fdbUrI5OKyA5D9msmM9zpXYxjME3VsS5JYjpDhVIrZOxSgrm(KyjKelDXIYyi2C1lX4c7hO7eJ96hJyCV8Cckgw6U8U(XAbFaBNGDwW5IymSiiaNtzWrby1edBSfJHfbbyw(9HcWQjgwfdeXIYZjynVlVR)kKIY(pX4iMolEjoWx0VGtFYeivbCfCfDdyR59(fC9U)(qflDXIz8Inx9sm(TJUSUyCfNxX0D8IXVDuX4koVILVsmDqm(TJkgxXflrCckMos(9HwWZH37xWhziuZH37xd95f8bSDc2zbNqqOH3ZO6yJy2Q22VFIflhXgA1Omg1tJELyyJTymSiiahklSNqF1x4NQfGvtmqeBSrmBvB73pafH0J2fduCed8IHn2IDAuiu9eIH8d4qzH9e6RNVWiXILJyXumqeJqqOH3ZO6yJy2Q22VFIflhXIPyyJTyJnIzRAB)(bOiKE0UyGIJy8ig3igxeZZa9oGIincwphMEIHIaOpzcKsmqeJHfbbyw(9HcWQjgwl4H(86NrubhP)(qlEjoUTOFbN(KjqQc4k4dy7eSZcUNb6DGVXG6NNHjeeG(KjqkXarmi7tiledb49pT6Bm6rLjKkcG(KjqkXarStJcHQNqmKFahklSNqF98fgjgOet3f8C49(f8dTNv8sCXSOFbN(KjqQc4k45W79l4hAQw(Nd7jubFmDeOQNqmKFL44PGpGTtWol4ZrSzjStMabWEuvd2lS9Pv46P37lgiIPigweeaK(vv(uo5P7aGuu2)jgOeJhXarStJcHQNqmKFahklSNqF98fgjgO4ig3kgiI5jed5aEhrvFRQMeJBedsrz)NyXkMouWv0nGTM37xWXcAI5RyCRyEcXq(jgx(vmnyVyvSjePjgRMy6D)kXMpkN80DIXmvSX0rOFmIHJMQL)5WEcbu8sC6UOFbN(KjqQc4k45W79l4hAQw(Nd7jubxr3a2AEVFbxVxOyAWEHTpvm46P37ZRyShjgoAQw(Nd7jKy7mckgUVWiX43oQyZh3tSet2)5IXQjMVIftX8eIH8tSfkwJiMEpFI1Nyq2)7hJylcIyCzFXYFQyz0Y(UylIyEcXq(H1c(a2ob7SGplHDYeia2JQAWEHTpTcxp9EFXarmUiMIyyrqaq6xv5t5KNUdasrz)NyGsmEedBSfZZa9oaFk12pkpNGa0NmbsjgiIDAuiu9eIH8d4qzH9e6RNVWiXafhXIPyyT4L40HI(fC6tMaPkGRGpGTtWol4NgfcvpHyi)elwoIXTIfVyCrmgweeahLQW1D6by1edBSfdY(eYcXqa5KmH9vVLnurGjMi6Da6tMaPedRIbIyCrmgweeGBAeZgU6Iuvu6O1K13bSDawnXWgBXMJymSiiaAqkIuTNEVpaRMyyJTyNgfcvpHyi)elwoIPBXWAbphEVFb)qzH9e6RNVWOIxIJ7u0VGtFYeivbCf8C49(f8dnvl)ZH9eQGROBaBnV3VGJJMQL)5WEcjMVIbjeiDOIP39ReB(OCYt3jw(kX8vm6pwijgFsSr(InsiCQy7mckwkgcBiiMEpFI1VVI5OKypfdxm8LRI1iIPT31mbcOGpGTtWol4kIHfbbaPFvLpLtE6oaifL9FIbkoIXJyyJTyJDdQL)dCtJy2WvxKQIshfasrz)NyGsmEM)IbIykIHfbbaPFvLpLtE6oaifL9FIbkXg7gul)h4MgXSHRUivfLokaKIY(VIxIB(x0VGtFYeivbCf8bSDc2zbNHfbbqJGilmDsvNr9FaNNJjIflhX0TyGi2yFfB7aAeezHPtQ6mQ)daM)eXILJy8WTf8C49(fCmHDJycPIkEjoD0I(f8C49(f8dnvl)ZH9eQGtFYeivbCfVehp6SOFbN(KjqQc4k4dy7eSZc(CeZtigYb6RYS3jgiIn2iMTQT97hGIq6r7IflhX4rmqeJHfbb4qxV2F1rPQkHtay1edeXONGyMc4Dev9TgtDkwSIHzOaIYyuWZH37xWhOuQvp01lEXl4kcjzdEr)sC8u0VGNdV3VGpPhtk40NmbsvaxXlXb(I(fC6tMaPkGRGVAf8J8cEo8E)c(Se2jtGk4ZYalvWzyrqaUqpOA(QQQheaRMyyJTyNgfcvpHyi)aouwypH(65lmsSy5iMouWv0nGTM37xWXchPeZxXuKtWO(jX4JsokbfBSBqT8)tm(z7IHSqXWFUkgtEKsS9fZtigYpGc(Sew)mIk43RQJ9vT37x8sCCBr)co9jtGufWvWxTc(rEbphEVFbFwc7Kjqf8zzGLk4AWEHTpTcxp9EFXarStJcHQNqmKFahklSNqF98fgjwSCed8fCfDdyR59(fCSmFyQyd08XqIbxp9EFXAeX4tIHMZiX0G9cBFAfUE69(IDKlw(kXIydERfiX8eIH8tmwnGc(Sew)mIk4Shv1G9cBFAfUE69(fVexml6xWPpzcKQaUcUIUbS18E)c(CrPXeXMlxpXsxmKgEEbphEVFbFKHqnhEVFn0NxWd951pJOc(qDfVeNUl6xWPpzcKQaUcUIUbS18E)cUUW(IHWgctf743(aLoX8vmhLed3Pm4OKsmDz9079fJlmtftT9JrSB5TDXqw4GoX02n0pgXAeX(1r7hJy9jwol7qYeiScuWZH37xWHSFnhEVFn0NxWhW2jyNf8ZPm4OKcidHcEOpV(zevWpNYGJsQIxIthk6xWPpzcKQaUcEo8E)c(f6bvZxvv9Gk4k6gWwZ79l4yjnTWuXUqpOA(QQQhKyPlg4JxS5QxIPyH9JrmhLedPHNlgp6uSJg7RoEteNGI5OPlwmJxS5QxI1iI1Uyum0AiDIXVD0(fZrjXEkgUyZV5YvXwOy9j2VUySAf8bSDc2zb)0OqO6jed5hWHYc7j0xpFHrIbkX0bXarmKgdQxHuu2)jwSIPdIbIymSiiaxOhunFvv1dcasrz)NyGsmmdfqugdXarSXgXSvTTF)elwoIftX4gX4IyEhrIbkX4rNIHvX4(Ib(IxIJ7u0VGtFYeivbCfCfDdyR59(fC9c2lS9PIPlRNEVpwwIPRiFENyy6zKyPydyQjwYSSUy0tqmtfdzHI5OKyNtzWrfBUC9eJlmSDqrqXoVdbXG0PrdxS2XkGyyzZQXB7InYxmgsmhnDXUoslqaf8C49(f8rgc1C49(1qFEbFaBNGDwWNLWozcea7rvnyVW2NwHRNEVFbp0Nx)mIk4NtzWrRd1v8sCZ)I(fC6tMaPkGRGVAf8J8cEo8E)c(Se2jtGk4ZYalvWbVUflEX8mqVdmRXSqa6tMaPeJ7lg41PyXlMNb6DGO8CcwxK6HMQL)bqFYeiLyCFXaVoflEX8mqVdCOPA5xr2b7bqFYeiLyCFXaVUflEX8mqVdKHCaBFka9jtGuIX9fd86uS4fd86wmUVyCrStJcHQNqmKFahklSNqF98fgjwSCelMIH1cUIUbS18E)cow4iLy(kMIq6NeJpk9I5RyShj25ugCuXMlxpXwOymSDqrWRGplH1pJOc(5ugC0QJcPdDdQIxIthTOFbN(KjqQc4k4k6gWwZ79l4ZD)Rveum2RFmILIH7ugCuXMlxfJpk9IbPCG2pgXCusm6jiMPI5Oq6q3GQGNdV3VGpYqOMdV3Vg6Zl4dy7eSZco9eeZuafH0J2fduCeBwc7KjqaNtzWrRokKo0nOk4H(86Nrub)CkdoADOUIxIJhDw0VGtFYeivbCf8bSDc2zbNlIrii0W7zuDSrmBvB73pXILJydTAugJ6PrVsmSkg2ylgxeBSrmBvB73pafH0J2fduCeJhXWgBXqAmOEfsrz)NyGIJy8igiIrii0W7zuDSrmBvB73pXILJyCRyyJTymSiia30iMnC1fPQO0rRjRVdy7aSAIbIyeccn8EgvhBeZw12(9tSy5iwmfdRIHn2IXfXonkeQEcXq(bCOSWEc91ZxyKyXYrSykgiIrii0W7zuDSrmBvB73pXILJyXumSwWZH37xWhziuZH37xd95f8qFE9ZiQGJ0FFOfVehp8u0VGtFYeivbCfCfDdyR59(fCSWrILIXW2bfbfJpk9IbPCG2pgXCusm6jiMPI5Oq6q3GQGNdV3VGpYqOMdV3Vg6Zl4dy7eSZco9eeZuafH0J2fduCeBwc7KjqaNtzWrRokKo0nOk4H(86NrubNHTdQIxIJhWx0VGtFYeivbCf8C49(f8eoYNQ(cH07fCfDdyR59(fCD1YNoxmnyVW2Nkw)ILHGylIyokjgwsV0vIXqJK9iXAxSrYE0jwk28BUCTGpGTtWol40tqmtbuespAxSy5igp6wS4fJEcIzkaKWqFXlXXd3w0VGNdV3VGNWr(uvJnCubN(KjqQc4kEjoEIzr)cEo8E)cEOXG6xL7cRcte9EbN(KjqQc4kEjoE0Dr)cEo8E)cotIPUivh2JjxbN(KjqQc4kEXl4AqASrmPx0Vehpf9l45W79l4PMwyAvB7B)co9jtGufWv8sCGVOFbphEVFbNzDpqQksiNsk(9JP6Bm6VGtFYeivbCfVeh3w0VGNdV3VGFoLbhTGtFYeivbCfVexml6xWPpzcKQaUcEo8E)cEucNqQkYcRkkD0cUgKgBet61Jg7RUcop6U4L40Dr)co9jtGufWvWZH37xWVqpOA(QQQhubFaBNGDwWHecKo0KjqfCnin2iM0Rhn2xDfCEkEjoDOOFbN(KjqQc4k4dy7eSZcoK9jKfIHaIs4K6IuDuQgLNtWAExEx)a0NmbsvWZH37xWp0uT8RmHurxXlEbhP)(ql6xIJNI(fC6tMaPkGRGVAf8J8cEo8E)c(Se2jtGk4ZYalvW9mqVdObPis1E69(a0NmbsjgiIDAuiu9eIH8d4qzH9e6RNVWiXaLyCrmDlg3i2yNrF(oWtd4gwOsmSkgiInhXg7m6Z3bMmf25xWv0nGTM37xWNp0oqIXE9Jrm9csrKQ90795vSC22kXg559Jrm8qpiXYxjgx7bjgFu6fdhnvlFX4A(dsS(e729fZxXyiXypsXRyumgKMlgYcfJ72uyNFbFwcRFgrfCnifrQ69Q6yFv79(fVeh4l6xWPpzcKQaUc(a2ob7SGphXMLWozceGgKIiv9EvDSVQ9EFXarStJcHQNqmKFahklSNqF98fgjgOethedeXMJymSiiahAQw(vv(dcGvtmqeJHfbb4c9GQ5RQQEqaqkk7)eduIH0yq9kKIY(pXarmiHaPdnzcubphEVFb)c9GQ5RQQEqfVeh3w0VGtFYeivbCf8bSDc2zbFwc7KjqaAqkIu17v1X(Q279fdeXg7gul)h4qt1YVQYFqad0eIHUkcmhEVFgeduIXda3r3IbIymSiiaxOhunFvv1dcasrz)NyGsSXUb1Y)bUPrmB4QlsvrPJcaPOS)tmqeJlIn2nOw(pWHMQLFvL)GaGuQMkgiIXWIGaCtJy2WvxKQIshfasrz)NyCJymSiiahAQw(vv(dcasrz)NyGsmEaaVyyTGNdV3VGFHEq18vvvpOIxIlMf9l40NmbsvaxbF1k4h5f8C49(f8zjStMavWNLbwQGhLNtWAExEx)vifL9FIfRy6umSXwS5iMNb6DGVXG6NNHjeeG(KjqkXarmpd07aQeoPEOPA5dqFYeiLyGigdlccWHMQLFvL)Gay1edBSf70OqO6jed5hWHYc7j0xpFHrIflhX0Hc(Sew)mIk43KwRcz1Cwiv8sC6UOFbN(KjqQc4k4Rwb)iVGNdV3VGplHDYeOc(SmWsf8O8CcwZ7Y76VcPOS)tSyftNIHn2InhX8mqVd8ngu)8mmHGa0NmbsjgiI5zGEhqLWj1dnvlFa6tMaPedeXyyrqao0uT8RQ8heaRMyyJTyNgfcvpHyi)aouwypH(65lmsSy5igxet3IXnIP5qX4(IbzFczHyiaK(Zq7tbOpzcKsmSwWv0nGTM37xW5UtbnckMosc7KjqIHSqX0fwnNfsaIHpP1etXc7hJyCV8Cckgw6U8U(fBHIPyH9JrmUM)GeJF7OIX1eorS8vI9RyX1yq9ZZWeccuWNLW6Nrub)M0AviRMZcPIxIthk6xWPpzcKQaUcEo8E)coKvZzHubxr3a2AEVFbN7grAIXQjMUWQ5SqsSgrS2fRpXsML1fZxXGSVylRduWhW2jyNfCUi2CeBwc7Kjqa3KwRcz1Cwijg2yl2Se2jtGaypQQb7f2(0kC9079fdRIbIyEcXqoG3ru13QQjX4gXGuu2)jwSIPdIbIyqcbshAYeOIxIJ7u0VGNdV3VGF0asE1Pb63y5SubN(KjqQc4kEjU5Fr)co9jtGufWvWZH37xWHSAolKk4JPJav9eIH8Rehpf8bSDc2zbFoInlHDYeiGBsRvHSAolKedeXMJyZsyNmbcG9OQgSxy7tRW1tV3xmqe70OqO6jed5hWHYc7j0xpFHrIflhXaVyGiMNqmKd4Dev9TQAsSy5igxet3IfVyCrmWlg3xSXgXSvTTF)edRIHvXarmiHaPdnzcubxr3a2AEVFbN7Xg8wTU3pgX8eIH8tmhnDX43HGyHEgjgYcfZrjXuSW079fBretxy1CwijgKqG0HkMIf2pgX0Yxrr9aO4L40rl6xWPpzcKQaUcEo8E)coKvZzHubxr3a2AEVFbxxieiDOIPlSAolKeJsyyQynIyTlg)oeeJIHwdjXuSW(Xig(0iMnCaIX1vmhnDXGecKouXAeXWxUkggYpXGuQMkw)I5OKypfdxmDFaf8bSDc2zbFoInlHDYeiGBsRvHSAolKedeXGuu2)jgOeBSBqT8FGBAeZgU6Iuvu6Oaqkk7)elEX4rNIbIyJDdQL)dCtJy2WvxKQIshfasrz)NyGIJy6wmqeZtigYb8oIQ(wvnjg3igKIY(pXIvSXUb1Y)bUPrmB4QlsvrPJcaPOS)tS4ft3fVehp6SOFbN(KjqQc4k4dy7eSZc(CeBwc7KjqaShv1G9cBFAfUE69(IbIyNgfcvpHyi)elwoIfZcEo8E)cotihtQAlFfblEjoE4POFbphEVFbNM13GGPtfC6tMaPkGR4fVGpuxr)sC8u0VGtFYeivbCf8bSDc2zbFoIXWIGaCOPA5xv5piawnXarmgweeGdLf2tOV6l8t1cWQjgiIXWIGaCOSWEc9vFHFQwaifL9FIbkoIXTa6UGZEuDrqQygQsC8uWZH37xWp0uT8RQ8hubxr3a2AEVFbhlCKyCn)bj2IGWnygkXyiKfsI5OKyin8CXouwypH(65lmsme4gjM(l8t1k2yJOtS(bkEjoWx0VGtFYeivbCf8bSDc2zbNHfbb4qzH9e6R(c)uTaSAIbIymSiiahklSNqF1x4NQfasrz)NyGIJyClGUl4ShvxeKkMHQehpf8C49(f8BAeZgU6Iuvu6OfCfDdyR59(fCUGf(aDNyzasPAQySAIXqJK9iX4tI57ormC0uT8ftV3b7HvXypsm8PrmB4eBrq4gmdLymeYcjXCusmKgEUyhklSNqF98fgjgcCJet)f(PAfBSr0jw)afVeh3w0VGtFYeivbCf8bSDc2zbFwc7Kjqa3RQJ9vT37lgiInhXoNYGJskGO89avWZH37xWrcjgkesV3V4L4Izr)co9jtGufWvWhW2jyNfCUigK9jKfIHaIs4K6IuDuQgLNtWAExEx)a0NmbsjgiIn2iMTQT97hGIq6r7IbkoIXJyCJyEgO3buePrW65W0jmuea9jtGuIHn2IbzFczHyiafLoAyA9qt1Y)aOpzcKsmqeBSrmBvB73pXaLy8igwfdeXyyrqaUPrmB4QlsvrPJcWQjgiIXWIGaCOPA5xv5piawnXarSO8CcwZ7Y76VcPOS)tmoIPtXarmgweeafLoAyA9qt1Y)aul)VGNdV3VGpl)(qlEjoDx0VGtFYeivbCfCfDdyR59(fC9A3Gyilum9x4NQvmniXn4lxfJF7OIHJYvXGuQMkgFu6f7xxmi7)9JrmC9gOGJSW6tXWlXXtbFaBNGDwW9mqVdCOSWEc9vFHFQwa6tMaPedeXMJyEgO3bo0uT8Ri7G9aOpzcKQGNdV3VGRTBOcPBzHdQ4L40HI(fC6tMaPkGRGNdV3VGFOSWEc9vFHFQ2cUIUbS18E)cow4iX0FHFQwX0GKy4lxfJpk9IXNednNrI5OKy0tqmtfJpk5Oeume4gjM2UH(Xig)2rxwxmC9wSfkg3f2Zfdd9emdHPaf8bSDc2zbNEcIzQyXYrmDqNIbIyZsyNmbc4EvDSVQ9EFXarSXUb1Y)bUPrmB4QlsvrPJcWQjgiIn2nOw(pWHMQLFvL)GagOjedDIflhX4P4L44of9l40NmbsvaxbphEVFb)iimDsvz2NQNwpHk4dy7eSZc(Se2jtGaUxvh7RAV3xmqeBoIPwh4iimDsvz2NQNwpHQQ1b8EmPFmIbIyEcXqoG3ru13QQjXILJyGNhXWgBXqAmOEfsrz)NyGIJy6wmqe70OqO6jed5hWHYc7j0xpFHrIbkX42c(y6iqvpHyi)kXXtXlXn)l6xWPpzcKQaUc(a2ob7SGplHDYeiG7v1X(Q279fdeXgBeZw12(9dqri9ODXILJy8uWZH37xWps76R4L40rl6xWPpzcKQaUcEo8E)c(nnIzdxDrQkkD0cUIUbS18E)cow4iXWNgXSHtS9fBSBqT8FX4sI4eumKgEUy4pxXQySFGUtm(KyjKedZ2pgX8vmTvtm9x4NQvS8vIPwX(1fdnNrIHJMQLVy69oypGc(a2ob7SGplHDYeiG7v1X(Q279fdeX4IyEgO3bOFgfwT(Xup0uT8pa6tMaPedBSfBSBqT8FGdnvl)Qk)bbmqtig6elwoIXJyyvmqeJlInhX8mqVdCOSWEc9vFHFQwa6tMaPedBSfZZa9oWHMQLFfzhSha9jtGuIHn2In2nOw(pWHYc7j0x9f(PAbGuu2)jwSIbEXWAXlXXJol6xWPpzcKQaUcEo8E)cEucNqQkYcRkkD0cEOFQoufCEa0DbFmDeOQNqmKFL44PGpGTtWol4WSvvAg9oqQuhaRMyGigxeZtigYb8oIQ(wvnjgOeBSrmBvB73pafH0J2fdBSfBoIDoLbhLuaziigiIn2iMTQT97hGIq6r7IflhXgA1Omg1tJELyyTGROBaBnV3VGRJrelvQtSesIXQXRy33AKyokj2(Ky8BhvSWYNoxm91NRaIHfosm(O0lMAA)yedjpNGI5O5l2C1lXuespAxSfk2VUyNtzWrjLy8BhDzDXYFQyZvVakEjoE4POFbN(KjqQc4k45W79l4rjCcPQilSQO0rl4k6gWwZ79l46yeX(vSuPoX43HGyQMeJF7O9lMJsI9umCX4wDE8kg7rIX9q4Qy7lgZENy8BhDzDXYFQyZvVak4dy7eSZcomBvLMrVdKk1b0VyXkg3QtX4gXGzRQ0m6DGuPoaflm9EFXarSXgXSvTTF)auespAxSy5i2qRgLXOEA0RkEjoEaFr)co9jtGufWvWhW2jyNf8zjStMabCVQo2x1EVVyGi2yJy2Q22VFakcPhTlwSCed8IbIyCrSXUb1Y)bUPrmB4QlsvrPJcaPOS)tmqjgpIHn2IXWIGaCtJy2WvxKQIshfGvtmSXwmKgdQxHuu2)jgO4ig41PyyTGNdV3VGFOPA5xzcPIUIxIJhUTOFbN(KjqQc4k4dy7eSZc(Se2jtGaUxvh7RAV3xmqeBSrmBvB73pafH0J2flwoIbEXarmUi2Se2jtGaypQQb7f2(0kC9079fdBSf70OqO6jed5hWHYc7j0xpFHrIbkoIftXWAbphEVFbNgOB)yQqsd2r5RkEjoEIzr)co9jtGufWvWZH37xWpuwypH(QVWpvBbxr3a2AEVFbF(AhvmC9MxXAeX(1fldqkvtftTpXRyShjM(l8t1kg)2rfdF5QySAaf8bSDc2zb3Za9oWHMQLFfzhSha9jtGuIbIyZsyNmbc4EvDSVQ9EFXarmgweeGBAeZgU6Iuvu6OaSAfVehp6UOFbN(KjqQc4k4dy7eSZc(CeJHfbb4qt1YVQYFqaSAIbIyinguVcPOS)tmqXrS5VyXlMNb6DGJLXjiclgcG(KjqQcEo8E)c(HMQLFvL)GkEjoE0HI(fC6tMaPkGRGpGTtWol4mSiiamHDvb2ZbGuoCXWgBXqAmOEfsrz)NyGsmUvNIHn2IXWIGaCtJy2WvxKQIshfGvtmqeJlIXWIGaCOPA5xzcPIoawnXWgBXg7gul)h4qt1YVYesfDaqkk7)eduCeJhDkgwl4k6gWwZ79l4XTp3CA0qSZzrqeJF7OIfw(eumnyVf8C49(fCT179lEjoE4of9l40NmbsvaxbFaBNGDwWzyrqaUPrmB4QlsvrPJcWQvWZH37xWzc7QQiSWPfVehpZ)I(fC6tMaPkGRGpGTtWol4mSiia30iMnC1fPQO0rby1k45W79l4me8i4K(Xu8sC8OJw0VGtFYeivbCf8bSDc2zbNHfbb4MgXSHRUivfLokaRwbphEVFbhPHetyxvXlXbEDw0VGtFYeivbCf8bSDc2zbNHfbb4MgXSHRUivfLokaRwbphEVFbp)bDomd1rgcfVeh45POFbN(KjqQc4k45W79l4ShvBNIUcUIUbS18E)coxjKKn4IHKHatoMigYcfJ9sMajw7u0HffdlCKy8Bhvm8PrmB4eBreJRu6Oaf8bSDc2zbNHfbb4MgXSHRUivfLokaRMyyJTyinguVcPOS)tmqjg41zXlEb)CkdoADOUI(L44POFbN(KjqQc4k4Rwb)iVGNdV3VGplHDYeOc(SmWsf8XUb1Y)bo0uT8RQ8heWanHyORIaZH37NbXILJy8aWD0DbFwcRFgrf8dvvDuiDOBqv8sCGVOFbN(KjqQc4k45W79l4ZYVp0cUIUbS18E)cUos(9HkwJigFsSesInsnT(Xi2(IX18hKyd0eIHoaX4UMWWuXyiKfsIH0WZftL)GeRreJpjgAoJe7xXIRXG6NNHjeumgwxmUMWjIHJMQLVy9l2cveumFfdd5IPlSAolKeJvtmU8RyCV8Cckgw6U8U(XkqbFaBNGDwW5IyZrSzjStMabCOQQJcPdDdkXWgBXMJyEgO3b(gdQFEgMqqa6tMaPedeX8mqVdOs4K6HMQLpa9jtGuIHvXarSXgXSvTTF)auespAxSyfJhXarS5igK9jKfIHaIs4K6IuDuQgLNtWAExEx)a0Nmbsv8sCCBr)co9jtGufWvWZH37xW12nuH0TSWbvWPy4WSMrl77f8yQZcoYcRpfdVehpfVexml6xWPpzcKQaUc(a2ob7SGtpbXmvSy5iwm1PyGig9eeZuafH0J2flwoIXJofdeXMJyZsyNmbc4qvvhfsh6guIbIyJnIzRAB)(bOiKE0UyXkgpIbIykIHfbbaPFvLpLtE6oaifL9FIbkX4PGNdV3VGFOPA5hrbvXlXP7I(fC6tMaPkGRGVAf8J8cEo8E)c(Se2jtGk4ZYalvWhBeZw12(9dqri9ODXILJyGxS4fJHfbb4qt1YVYesfDaSAfCfDdyR59(f85QxI5Oq6q3G6edzHIrVtW(XigoAQw(IX18hubFwcRFgrf8dvvhBeZw12(9R4L40HI(fC6tMaPkGRGVAf8J8cEo8E)c(Se2jtGk4ZYalvWhBeZw12(9dqri9ODXILJyCBbFaBNGDwWh7m6Z3bMmf25xWNLW6Nrub)qv1XgXSvTTF)kEjoUtr)co9jtGufWvWxTc(rEbphEVFbFwc7Kjqf8zzGLk4JnIzRAB)(bOiKE0UyGIJy8uWhW2jyNf8zjStMabWEuvd2lS9Pv46P37lgiIDAuiu9eIH8d4qzH9e6RNVWiXILJyXSGplH1pJOc(HQQJnIzRAB)(v8sCZ)I(fC6tMaPkGRGNdV3VGFOPA5xv5pOcUIUbS18E)coxZFqIPyH9Jrm8PrmB4eBHILm7msmhfsh6guaf8bSDc2zbFwc7KjqahQQo2iMTQT97NyGigxeBwc7KjqahQQ6Oq6q3GsmSXwmgweeGBAeZgU6Iuvu6Oaqkk7)elwoIXda4fdBSf70OqO6jed5hWHYc7j0xpFHrIflhXIPyGi2y3GA5)a30iMnC1fPQO0rbGuu2)jwSIXJofdRfVeNoAr)co9jtGufWvWZH37xWp0uT8RQ8hubxr3a2AEVFbhCSWxmifL93pgX4A(d6eJHqwijMJsIH0yqDXOxDI1iIHVCvm(7ppxmgsmiLQPI1VyEhraf8bSDc2zbFwc7KjqahQQo2iMTQT97NyGigsJb1Rqkk7)eduIn2nOw(pWnnIzdxDrQkkDuaifL9FfV4fCg2oOk6xIJNI(fC6tMaPkGRGpGTtWol4Zrmpd07aFJb1ppdtiia9jtGuIbIyq2NqwigcW7FA13y0Jktivea9jtGuIbIyNgfcvpHyi)aouwypH(65lmsmqjMUl45W79l4hApR4L4aFr)co9jtGufWvWhW2jyNf8tJcHQNqmKFIflhXaVyGigxeBSBqT8FGJGW0jvLzFQEA9ecikJrDGMqm0jg3i2anHyORIaZH37NbXILJy6ea86wmSXwStJcHQNqmKFahklSNqF98fgjwSIftXWAbphEVFb)qzH9e6RNVWOIxIJBl6xWPpzcKQaUc(a2ob7SGp2nOw(pWrqy6KQYSpvpTEcbeLXOoqtig6eJBeBGMqm0vrG5W79ZGyGIJy6ea86wmSXwSBzdm9RacuQQmtRumYiTabqFYeiLyGi2CeJHfbbiqPQYmTsXiJ0ceaRwbphEVFb)iimDsvz2NQNwpHkEjUyw0VGNdV3VGJjSBetivubN(KjqQc4kEjoDx0VGNdV3VGZKJjNNmfC6tMaPkGR4fV4f8ze869lXbEDcEE0zm5jMfC(j87hZvWNpSKUeNooU5hwumX0hLeRJ0wOlgYcfBENtzWrj18edsy5SnKuIDBejwY6Bu6KsSbA(yOdqatx1pjg3IffBU7pJGoPeBEq2NqwigcqxppX8vS5bzFczHyiaDna9jtGuZtmUWtmWkGaMUQFsmDalk2C3FgbDsj28GSpHSqmeGUEEI5RyZdY(eYcXqa6Aa6tMaPMNyCHNyGvabm9rjXq2qy53pgXswyEIXNGKyShPeRFXCusSC49(If6ZfJH1fJpbjX(1fdzzFLy9lMJsILk1(IPspzYJWIcyIXnIDtJy2WvxKQIshTMS(oGTlGjGnFyjDjoDCCZpSOyIPpkjwhPTqxmKfk28uesYg85jgKWYzBiPe72isSK13O0jLyd08XqhGaM(OKyiBiS87hJyjlmpX4tqsm2JuI1Vyokjwo8EFXc95IXW6IXNGKy)6IHSSVsS(fZrjXsLAFXuPNm5ryrbmX4gXUPrmB4QlsvrPJwtwFhW2fWeWMpSKUeNooU5hwumX0hLeRJ0wOlgYcfBEAqASrmPppXGewoBdjLy3grILS(gLoPeBGMpg6aeW0v9tIPdyrXM7(ZiOtkXMhK9jKfIHa01ZtmFfBEq2NqwigcqxdqFYei18elDX4UILrxjgx4jgyfqataB(Ws6sC644MFyrXetFusSosBHUyiluS5H0FFOZtmiHLZ2qsj2TrKyjRVrPtkXgO5JHoabmDv)Ky6glk2C3FgbDsj28GSpHSqmeGUEEI5RyZdY(eYcXqa6Aa6tMaPMNyCHNyGvabmbS5dlPlXPJJB(Hfftm9rjX6iTf6IHSqXM3qDZtmiHLZ2qsj2TrKyjRVrPtkXgO5JHoabmDv)KyXelk2C3FgbDsj28GSpHSqmeGUEEI5RyZdY(eYcXqa6Aa6tMaPMNyCb8XaRacycyZhwsxIthh38dlkMy6JsI1rAl0fdzHInVZPm4O1H6MNyqclNTHKsSBJiXswFJsNuInqZhdDacy6Q(jXapwuS5U)mc6KsS5bzFczHyiaD98eZxXMhK9jKfIHa01a0NmbsnpXsxmURyz0vIXfEIbwbeWeWMpSKUeNooU5hwumX0hLeRJ0wOlgYcfBEmSDqnpXGewoBdjLy3grILS(gLoPeBGMpg6aeW0v9tIXdwuS5U)mc6KsS5bzFczHyiaD98eZxXMhK9jKfIHa01a0NmbsnpX4cpXaRacycy64iTf6KsmUJy5W79fl0NFacyfCn4I0bQGRh9igolJhiFQy6YIHLeW0JEedm2Ned8ChEfd86e88iGjGPh9ig3BNrInlHDYeia2JQAWEHTpTcxp9EFXy1e7wXAxS(e7ixmgczHKy8jXypsS2beW0JEeBUBet)KyrSbV1cKyJmeQ5W79RH(CXO3HnDI5RyqsXoiX0wNEVZGyqI)cNaiGjGPh9iMEbjUzUBet6cy5W79panin2iM0JNdOtnTW0Q223(cy5W79panin2iM0JNdOzw3dKQIeYPKIF)yQ(gJ(fWYH37FaAqASrmPhphqFoLbhvalhEV)bObPXgXKE8CaDucNqQkYcRkkDuE1G0yJysVE0yF1XHhDlGLdV3)a0G0yJyspEoG(c9GQ5RQQEq8QbPXgXKE9OX(QJdp82iCGecKo0Kjqcy5W79panin2iM0JNdOp0uT8RmHurhVnchi7tiledbeLWj1fP6OunkpNG18U8U(fWeW0JEeJ7L9lMUSE69(cy5W79pot6Xebm9igw4iLy(kMICcg1pjgFuYrjOyJDdQL)FIXpBxmKfkg(ZvXyYJuITVyEcXq(biGLdV3)INdONLWozceVFgrCUxvh7RAV3N3zzGL4WWIGaCHEq18vvvpiawnSX(0OqO6jed5hWHYc7j0xpFHrXYrheW0Jyyz(WuXgO5JHedUE69(I1iIXNednNrIPb7f2(0kC9079f7ixS8vIfXg8wlqI5jed5NySAacy5W79V45a6zjStMaX7Nreh2JQAWEHTpTcxp9EFENLbwIJgSxy7tRW1tV3hKtJcHQNqmKFahklSNqF98fgflhWlGPhXMlknMi2C56jw6IH0WZfWYH37FXZb0JmeQ5W79RH(CE)mI4muNaMEetxyFXqydHPID8BFGsNy(kMJsIH7ugCusjMUSE69(IXfMPIP2(Xi2T82UyilCqNyA7g6hJynIy)6O9JrS(elNLDizcewbeWYH37FXZb0q2VMdV3Vg6Z59ZiIZ5ugCusXBJW5CkdokPaYqqatpIHL00ctf7c9GQ5RQQEqILUyGpEXMREjMIf2pgXCusmKgEUy8OtXoASV64nrCckMJMUyXmEXMREjwJiw7IrXqRH0jg)2r7xmhLe7Py4In)MlxfBHI1Ny)6IXQjGLdV3)INdOVqpOA(QQQheVncNtJcHQNqmKFahklSNqF98fgbkDaeKgdQxHuu2)fRoacdlccWf6bvZxvv9GaGuu2)bkmdfqugdqgBeZw12(9lwoXKB4I3reO4rNyL7dEbm9iMEb7f2(uX0L1tV3hllX0vKpVtmm9msSuSbm1elzwwxm6jiMPIHSqXCusSZPm4OInxUEIXfg2oOiOyN3HGyq60OHlw7yfqmSSz14TDXg5lgdjMJMUyxhPfiabSC49(x8Ca9idHAo8E)AOpN3pJioNtzWrRd1XBJWzwc7KjqaShv1G9cBFAfUE69(cy6rmSWrkX8vmfH0pjgFu6fZxXypsSZPm4OInxUEITqXyy7GIGNawo8E)lEoGEwc7Kjq8(zeX5CkdoA1rH0HUbfVZYalXb86oEpd07aZAmleG(KjqkUp41z8EgO3bIYZjyDrQhAQw(ha9jtGuCFWRZ49mqVdCOPA5xr2b7bqFYeif3h86oEpd07azihW2NcqFYeif3h86mEWRBUpxonkeQEcXq(bCOSWEc91ZxyuSCIjwfW0JyZD)Rveum2RFmILIH7ugCuXMlxfJpk9IbPCG2pgXCusm6jiMPI5Oq6q3GsalhEV)fphqpYqOMdV3Vg6Z59ZiIZ5ugC06qD82iCONGyMcOiKE0oO4mlHDYeiGZPm4Ovhfsh6gucy5W79V45a6rgc1C49(1qFoVFgrCq6VpuEBeoCHqqOH3ZO6yJy2Q22VFXYzOvJYyupn6vyfBS5YyJy2Q22VFakcPhTdko8Gn2inguVcPOS)duC4becbHgEpJQJnIzRAB)(flhUfBSzyrqaUPrmB4QlsvrPJwtwFhW2by1aHqqOH3ZO6yJy2Q22VFXYjMyfBS5YPrHq1tigYpGdLf2tOVE(cJILtmbHqqOH3ZO6yJy2Q22VFXYjMyvatpIHfosSumg2oOiOy8rPxmiLd0(XiMJsIrpbXmvmhfsh6gucy5W79V45a6rgc1C49(1qFoVFgrCyy7GI3gHd9eeZuafH0J2bfNzjStMabCoLbhT6Oq6q3GsatpIPRw(05IPb7f2(uX6xSmeeBreZrjXWs6LUsmgAKShjw7Ins2JoXsXMFZLRcy5W79V45a6eoYNQ(cH0782iCONGyMcOiKE0ESC4r3XtpbXmfasyOxalhEV)fphqNWr(uvJnCKawo8E)lEoGo0yq9RYDHvHjIExalhEV)fphqZKyQls1H9yYjGjGPh9ig4y7GIGNawo8E)dGHTdkohApJ3gHZC8mqVd8ngu)8mmHGa0NmbsbcK9jKfIHa8(Nw9ng9OYesfbYPrHq1tigYpGdLf2tOVE(cJaLUfWYH37FamSDqfphqFOSWEc91ZxyeVncNtJcHQNqmKFXYb8GWLXUb1Y)bocctNuvM9P6P1tiGOmg1bAcXqh3mqtig6QiWC49(ziwo6ea86gBSpnkeQEcXq(bCOSWEc91ZxyuSXeRcy5W79pag2oOINdOpcctNuvM9P6P1tiEBeoJDdQL)dCeeMoPQm7t1tRNqarzmQd0eIHoUzGMqm0vrG5W79ZaO4OtaWRBSX(w2at)kGaLQkZ0kfJmslqa0NmbsbYCyyrqacuQQmtRumYiTabWQjGLdV3)ayy7GkEoGgty3iMqQibSC49(hadBhuXZb0m5yY5jJaMaME0JyZD3GA5)NaMEedlCKyCn)bj2IGWnygkXyiKfsI5OKyin8CXouwypH(65lmsme4gjM(l8t1k2yJOtS(beWYH37Fad1fphqFOPA5xv5piEzpQUiivmdfhE4Tr4mhgweeGdnvl)Qk)bbWQbcdlccWHYc7j0x9f(PAby1aHHfbb4qzH9e6R(c)uTaqkk7)afhUfq3cy6rmUGf(aDNyzasPAQySAIXqJK9iX4tI57ormC0uT8ftV3b7HvXypsm8PrmB4eBrq4gmdLymeYcjXCusmKgEUyhklSNqF98fgjgcCJet)f(PAfBSr0jw)acy5W79pGH6INdOVPrmB4QlsvrPJYl7r1fbPIzO4WdVnchgweeGdLf2tOV6l8t1cWQbcdlccWHYc7j0x9f(PAbGuu2)bkoClGUfWYH37Fad1fphqJesmuiKEVpVncNzjStMabCVQo2x1EVpiZ5CkdokPaIY3dKawo8E)dyOU45a6z53hkVnchUazFczHyiGOeoPUivhLQr55eSM3L31piJnIzRAB)(bOiKE0oO4Wd34zGEhqrKgbRNdtNWqra0NmbsHn2q2NqwigcqrPJgMwp0uT8pqgBeZw12(9du8GvqyyrqaUPrmB4QlsvrPJcWQbcdlccWHMQLFvL)Gay1ajkpNG18U8U(Rqkk7)4Otqyyrqauu6OHP1dnvl)dqT8Fbm9iMETBqmKfkM(l8t1kMgK4g8LRIXVDuXWr5QyqkvtfJpk9I9RlgK9)(XigUEdiGLdV3)agQlEoGwB3qfs3YcheVilS(umCo8WBJWXZa9oWHYc7j0x9f(PAbOpzcKcK54zGEh4qt1YVISd2dG(Kjqkbm9igw4iX0FHFQwX0GKy4lxfJpk9IXNednNrI5OKy0tqmtfJpk5Oeume4gjM2UH(Xig)2rxwxmC9wSfkg3f2Zfdd9emdHPacy5W79pGH6INdOpuwypH(QVWpvlVnch6jiMPXYrh0jiZsyNmbc4EvDSVQ9EFqg7gul)h4MgXSHRUivfLokaRgiJDdQL)dCOPA5xv5piGbAcXqxSC4ralhEV)bmux8Ca9rqy6KQYSpvpTEcX7y6iqvpHyi)4WdVncNzjStMabCVQo2x1EVpiZrToWrqy6KQYSpvpTEcvvRd49ys)yaXtigYb8oIQ(wvnflhWZd2yJ0yq9kKIY(pqXr3GCAuiu9eIH8d4qzH9e6RNVWiqXTcy5W79pGH6INdOps76J3gHZSe2jtGaUxvh7RAV3hKXgXSvTTF)auespApwo8iGPhXWchjg(0iMnCITVyJDdQL)lgxseNGIH0WZfd)5kwfJ9d0DIXNelHKyy2(XiMVIPTAIP)c)uTILVsm1k2VUyO5msmC0uT8ftV3b7biGLdV3)agQlEoG(MgXSHRUivfLokVncNzjStMabCVQo2x1EVpiCXZa9oa9ZOWQ1pM6HMQL)bqFYeif2yp2nOw(pWHMQLFvL)GagOjedDXYHhSccxMJNb6DGdLf2tOV6l8t1cqFYeif2y7zGEh4qt1YVISd2dG(KjqkSXESBqT8FGdLf2tOV6l8t1caPOS)lwWJvbm9iMogrSuPoXsijgRgVIDFRrI5OKy7tIXVDuXclF6CX0xFUcigw4iX4JsVyQP9JrmK8CckMJMVyZvVetri9ODXwOy)6IDoLbhLuIXVD0L1fl)PInx9cqalhEV)bmux8CaDucNqQkYcRkkDuEd9t1HIdpa6M3X0rGQEcXq(XHhEBeoWSvvAg9oqQuhaRgiCXtigYb8oIQ(wvnbQXgXSvTTF)auespAhBSNZ5ugCusbKHaiJnIzRAB)(bOiKE0ESCgA1Omg1tJEfwfW0Jy6yeX(vSuPoX43HGyQMeJF7O9lMJsI9umCX4wDE8kg7rIX9q4Qy7lgZENy8BhDzDXYFQyZvVaeWYH37Fad1fphqhLWjKQISWQIshL3gHdmBvLMrVdKk1b0FSCRo5gy2QknJEhivQdqXctV3hKXgXSvTTF)auespApwodTAugJ6PrVsalhEV)bmux8Ca9HMQLFLjKk64Tr4mlHDYeiG7v1X(Q279bzSrmBvB73pafH0J2JLd4bHlJDdQL)dCtJy2WvxKQIshfasrz)hO4bBSzyrqaUPrmB4QlsvrPJcWQHn2inguVcPOS)duCaVoXQawo8E)dyOU45aAAGU9JPcjnyhLVI3gHZSe2jtGaUxvh7RAV3hKXgXSvTTF)auespApwoGheUmlHDYeia2JQAWEHTpTcxp9EFSX(0OqO6jed5hWHYc7j0xpFHrGItmXQaMEeB(AhvmC9MxXAeX(1fldqkvtftTpXRyShjM(l8t1kg)2rfdF5QySAacy5W79pGH6INdOpuwypH(QVWpvlVnchpd07ahAQw(vKDWEa0NmbsbYSe2jtGaUxvh7RAV3hegweeGBAeZgU6Iuvu6OaSAcy5W79pGH6INdOp0uT8RQ8heVncN5WWIGaCOPA5xv5piawnqqAmOEfsrz)hO4m)J3Za9oWXY4eeHfdbqFYeiLaMEelU95MtJgIDolcIy8BhvSWYNGIPb7valhEV)bmux8CaT269(82iCyyrqayc7QcSNdaPC4yJnsJb1Rqkk7)af3QtSXMHfbb4MgXSHRUivfLokaRgiCHHfbb4qt1YVYesfDaSAyJ9y3GA5)ahAQw(vMqQOdasrz)hO4WJoXQawo8E)dyOU45aAMWUQkclCkVnchgweeGBAeZgU6Iuvu6OaSAcy5W79pGH6INdOzi4rWj9JH3gHddlccWnnIzdxDrQkkDuawnbSC49(hWqDXZb0inKyc7Q4Tr4WWIGaCtJy2WvxKQIshfGvtalhEV)bmux8CaD(d6CygQJme4Tr4WWIGaCtJy2WvxKQIshfGvtatpIXvcjzdUyiziWKJjIHSqXyVKjqI1ofDyrXWchjg)2rfdFAeZgoXweX4kLokGawo8E)dyOU45aA2JQTtrhVnchgweeGBAeZgU6Iuvu6OaSAyJnsJb1Rqkk7)af41PaMaME0Jy6D)9HsWtatpInFODGeJ96hJy6fKIiv7P37ZRy5STvInYZ7hJy4HEqILVsmU2dsm(O0lgoAQw(IX18hKy9j2T7lMVIXqIXEKIxXOyminxmKfkg3TPWoFbSC49(has)9HYzwc7Kjq8(zeXrdsrKQEVQo2x1EVpVZYalXXZa9oGgKIiv7P37dqFYeifiNgfcvpHyi)aouwypH(65lmcuCr3CZyNrF(oWtd4gwOcRGmNXoJ(8DGjtHD(cy5W79paK(7dnEoG(c9GQ5RQQEq82iCMZSe2jtGa0GuePQ3RQJ9vT37dYPrHq1tigYpGdLf2tOVE(cJaLoaYCyyrqao0uT8RQ8heaRgimSiiaxOhunFvv1dcasrz)hOqAmOEfsrz)hiqcbshAYeibSC49(has)9HgphqFHEq18vvvpiEBeoZsyNmbcqdsrKQEVQo2x1EVpiJDdQL)dCOPA5xv5piGbAcXqxfbMdV3pdGIhaUJUbHHfbb4c9GQ5RQQEqaqkk7)a1y3GA5)a30iMnC1fPQO0rbGuu2)bcxg7gul)h4qt1YVQYFqaqkvtbHHfbb4MgXSHRUivfLokaKIY(pUHHfbb4qt1YVQYFqaqkk7)afpaGhRcy5W79paK(7dnEoGEwc7Kjq8(zeX5M0AviRMZcjENLbwItuEobR5D5D9xHuu2)fRoXg754zGEh4BmO(5zycbbOpzcKcepd07aQeoPEOPA5dqFYeifimSiiahAQw(vv(dcGvdBSpnkeQEcXq(bCOSWEc91ZxyuSC0bE5UtbnckMosc7KjqIHSqX0fwnNfsaIHpP1etXc7hJyCV8Cckgw6U8U(fBHIPyH9JrmUM)GeJF7OIX1eorS8vI9RyX1yq9ZZWecciGPhX4UtbnckMosc7KjqIHSqX0fwnNfsaIHpP1etXc7hJyCV8Cckgw6U8U(fBHIPyH9JrmUM)GeJF7OIX1eorS8vI9RyX1yq9ZZWecciGLdV3)aq6Vp045a6zjStMaX7NreNBsRvHSAolK4Dwgyjor55eSM3L31Ffsrz)xS6eBSNJNb6DGVXG6NNHjeeG(Kjqkq8mqVdOs4K6HMQLpa9jtGuGWWIGaCOPA5xv5piawnSX(0OqO6jed5hWHYc7j0xpFHrXYHl6MB0Ci3hY(eYcXqai9NH2NIvbm9ig3nI0eJvtmDHvZzHKynIyTlwFILmlRlMVIbzFXwwhqalhEV)bG0FFOXZb0qwnNfs82iC4YCMLWozceWnP1QqwnNfsyJ9Se2jtGaypQQb7f2(0kC9079XkiEcXqoG3ru13QQjUbsrz)xS6aiqcbshAYeibSC49(has)9HgphqF0asE1Pb63y5SKaMEeJ7Xg8wTU3pgX8eIH8tmhnDX43HGyHEgjgYcfZrjXuSW079fBretxy1CwijgKqG0HkMIf2pgX0Yxrr9aqalhEV)bG0FFOXZb0qwnNfs8oMocu1tigYpo8WBJWzoZsyNmbc4M0AviRMZcjqMZSe2jtGaypQQb7f2(0kC9079b50OqO6jed5hWHYc7j0xpFHrXYb8G4jed5aEhrvFRQMILdx0D8Cb8C)XgXSvTTF)Wkwbbsiq6qtMajGPhX0fcbshQy6cRMZcjXOegMkwJiw7IXVdbXOyO1qsmflSFmIHpnIzdhGyCDfZrtxmiHaPdvSgrm8LRIHH8tmiLQPI1Vyokj2tXWft3hGawo8E)daP)(qJNdOHSAolK4Tr4mNzjStMabCtATkKvZzHeiqkk7)a1y3GA5)a30iMnC1fPQO0rbGuu2)fpp6eKXUb1Y)bUPrmB4QlsvrPJcaPOS)duC0niEcXqoG3ru13QQjUbsrz)xSJDdQL)dCtJy2WvxKQIshfasrz)x86walhEV)bG0FFOXZb0mHCmPQT8veK3gHZCMLWozcea7rvnyVW2NwHRNEVpiNgfcvpHyi)ILtmfWYH37Fai93hA8CannRVbbtNeWeW0JEed3Pm4OIn3DdQL)Fcy5W79pGZPm4O1H6INdONLWozceVFgrCouv1rH0HUbfVZYalXzSBqT8FGdnvl)Qk)bbmqtig6QiWC49(ziwo8aWD0nVC3PGgbfthjHDYeibm9iMos(9HkwJigFsSesInsnT(Xi2(IX18hKyd0eIHoaX4UMWWuXyiKfsIH0WZftL)GeRreJpjgAoJe7xXIRXG6NNHjeumgwxmUMWjIHJMQLVy9l2cveumFfdd5IPlSAolKeJvtmU8RyCV8Cckgw6U8U(XkGawo8E)d4CkdoADOU45a6z53hkVnchUmNzjStMabCOQQJcPdDdkSXEoEgO3b(gdQFEgMqqa6tMaPaXZa9oGkHtQhAQw(a0NmbsHvqgBeZw12(9dqri9O9y5bK5azFczHyiGOeoPUivhLQr55eSM3L31Vawo8E)d4CkdoADOU45aATDdviDllCq8ISW6tXW5WdVumCywZOL9DoXuN8Qx7gedzHIHJMQLFefuIfVy4OPA5FoSNqIX(b6oX4tILqsSKzzDX8vSrQj2(IX18hKyd0eIHoaXWY8HPIXhLEX07(vInFuo5P7eRpXsML1fZxXGSVylRdiGLdV3)aoNYGJwhQlEoG(qt1YpIckEBeo0tqmtJLtm1ji0tqmtbuespApwo8OtqMZSe2jtGaouv1rH0HUbfiJnIzRAB)(bOiKE0ES8aIIyyrqaq6xv5t5KNUdasrz)hO4ratpInx9smhfsh6guNyilum6Dc2pgXWrt1YxmUM)GeWYH37FaNtzWrRd1fphqplHDYeiE)mI4COQ6yJy2Q22VF8oldSeNXgXSvTTF)auespApwoGpEgweeGdnvl)ktiv0bWQjGLdV3)aoNYGJwhQlEoGEwc7Kjq8(zeX5qv1XgXSvTTF)4DwgyjoJnIzRAB)(bOiKE0ESC4wEBeoJDg957atMc78fWYH37FaNtzWrRd1fphqplHDYeiE)mI4COQ6yJy2Q22VF8oldSeNXgXSvTTF)auespAhuC4H3gHZSe2jtGaypQQb7f2(0kC9079b50OqO6jed5hWHYc7j0xpFHrXYjMcy6rmUM)GetXc7hJy4tJy2Wj2cflz2zKyokKo0nOaeWYH37FaNtzWrRd1fphqFOPA5xv5piEBeoZsyNmbc4qv1XgXSvTTF)aHlZsyNmbc4qvvhfsh6guyJndlccWnnIzdxDrQkkDuaifL9FXYHhaWJn2NgfcvpHyi)aouwypH(65lmkwoXeKXUb1Y)bUPrmB4QlsvrPJcaPOS)lwE0jwfW0JyGJf(IbPOS)(XigxZFqNymeYcjXCusmKgdQlg9QtSgrm8LRIXF)55IXqIbPunvS(fZ7icqalhEV)bCoLbhToux8Ca9HMQLFvL)G4Tr4mlHDYeiGdvvhBeZw12(9deKgdQxHuu2)bQXUb1Y)bUPrmB4QlsvrPJcaPOS)tatatp6rmCNYGJskX0L1tV3xatpIPJred3Pm4OGEw(9HkwcjXy14vm2Jedhnvl)ZH9esmFfJHEcPDXqGBKyokjMwExpJeJzF2tS8vIP39ReB(OCYt3XRy0m6fRreJpjwcjXsxSOmgInx9smUW(b6oXyV(Xig3lpNGIHLUlVRFSkGLdV3)aoNYGJskohAQw(Nd7jeVnchUWWIGaCoLbhfGvdBSzyrqaMLFFOaSAyfKO8CcwZ7Y76VcPOS)JJofW0Jy6D)9Hkw6IXTXl2C1lX43o6Y6IXvCXaTyXmEX43oQyCfxm(TJkgoklSNqVy6VWpvRymSiiIXQjMVILZ2wj2TrKyZvVeJFEoj21oB69(hGaMEedlfUvSlriX8vmK(7dvS0flMXl2C1lX43oQyumYHhMkwmfZtigYpaX4cEgrILNylRFTIe7CkdokawfW0Jy6D)9Hkw6IfZ4fBU6Ly8BhDzDX4koVIP74fJF7OIXvCEflFLy6Gy8BhvmUIlwI4eumDK87dvalhEV)bCoLbhLuXZb0JmeQ5W79RH(CE)mI4G0FFO82iCieeA49mQo2iMTQT97xSCgA1Omg1tJEf2yZWIGaCOSWEc9vFHFQwawnqgBeZw12(9dqri9ODqXb8yJ9PrHq1tigYpGdLf2tOVE(cJILtmbHqqOH3ZO6yJy2Q22VFXYjMyJ9yJy2Q22VFakcPhTdko8WnCXZa9oGIincwphMEIHIaOpzcKcegweeGz53hkaRgwfWYH37FaNtzWrjv8Ca9H2Z4Tr44zGEh4BmO(5zycbbOpzcKcei7tiledb49pT6Bm6rLjKkcKtJcHQNqmKFahklSNqF98fgbkDlGPhXWcAI5RyCRyEcXq(jgx(vmnyVyvSjePjgRMy6D)kXMpkN80DIXmvSX0rOFmIHJMQL)5WEcbiGLdV3)aoNYGJsQ45a6dnvl)ZH9eI3X0rGQEcXq(XHhEBeoZzwc7KjqaShv1G9cBFAfUE69(GOigweeaK(vv(uo5P7aGuu2)bkEa50OqO6jed5hWHYc7j0xpFHrGId3cINqmKd4Dev9TQAIBGuu2)fRoiGPhX07fkMgSxy7tfdUE69(8kg7rIHJMQL)5WEcj2oJGIH7lmsm(TJk28X9elXK9FUySAI5RyXumpHyi)eBHI1iIP3ZNy9jgK9)(Xi2IGigx2xS8NkwgTSVl2IiMNqmKFyvalhEV)bCoLbhLuXZb0hAQw(Nd7jeVncNzjStMabWEuvd2lS9Pv46P37dcxuedlccas)QkFkN80Daqkk7)afpyJTNb6Da(uQTFuEobbOpzcKcKtJcHQNqmKFahklSNqF98fgbkoXeRcy5W79pGZPm4OKkEoG(qzH9e6RNVWiEBeoNgfcvpHyi)ILd3gpxyyrqaCuQcx3PhGvdBSHSpHSqmeqojtyF1BzdveyIjIEhRGWfgweeGBAeZgU6Iuvu6O1K13bSDawnSXEomSiiaAqkIuTNEVpaRg2yFAuiu9eIH8lwo6gRcy6rmC0uT8ph2tiX8vmiHaPdvm9UFLyZhLtE6oXYxjMVIr)XcjX4tInYxSrcHtfBNrqXsXqydbX075tS(9vmhLe7Py4IHVCvSgrmT9UMjqacy5W79pGZPm4OKkEoG(qt1Y)CypH4Tr4OigweeaK(vv(uo5P7aGuu2)bko8Gn2JDdQL)dCtJy2WvxKQIshfasrz)hO4z(dIIyyrqaq6xv5t5KNUdasrz)hOg7gul)h4MgXSHRUivfLokaKIY(pbSC49(hW5ugCusfphqJjSBetiveVnchgweeancISW0jvDg1)bCEoMelhDdYyFfB7aAeezHPtQ6mQ)daM)Ky5Wd3kGLdV3)aoNYGJsQ45a6dnvl)ZH9esalhEV)bCoLbhLuXZb0duk1Qh6682iCMJNqmKd0xLzVdKXgXSvTTF)auespApwo8acdlccWHUET)QJsvvcNaWQbc9eeZuaVJOQV1yQZyXmuarzmk4NgnkXbEDGNIx8sb]] )

    
end
