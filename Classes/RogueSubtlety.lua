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


    spec:RegisterPack( "Subtlety", 20210414, [[davoZbqijk9isbBsPYNuQQgfQOofQiRIuu1RiLmluvDlsHAxa(fqQHjr0XqLSmubpdOQMgQkDnsr2MebFdvfzCkvL6CkvfSouvO5bKCpOQ9jr1)qvbYbbQsleOYdvQstevOlIQcQnkrOpQuvYirvrvNKuuALaLxIQIkZKuuCtsrLDkr6NOQagkPqwQefEkuMkPuxfOk2QsvH(QefnwLQIolQkqTxH(RKgmLdlAXO4XkzYKCzKndPpdvgneNwQvJQcYRvknBb3wc7wv)wXWjvhhvfLLd65QmDQUokTDG47OkJxPkoVsX8rLA)eh5kQDetLoflLdLKdCvs(YfFb4ah4ax8vtrmFJofX0Z12ehfX(SGIyySmEG8nrm9Ctysvu7i2nSWffXqCx)4JGg04AhHLbynfG(6c2q698lyI6G(6IfOJymSDW1SFKjIPsNILYHsYbUkjF5IVaCGdCGl(Y3iwY6idmIH1f7nIH0kf9rMiMIUvedJLXdKVrSYyWXscyGxDyheJl(YVyCOKCGlbmbmn3acjgijStMabWEuvh2dS9nv44P3ZlgRUy3iw7I1Nyh5IXqOdKeJhjg7rI1oGa2ENcM(jXkydERhiXwziuZL3Zxd95IrVdB6eZhXGKIDrIPpo9ENbXGeVbUfiIf6ZVO2rSZPm4iKkQDSuUIAhXOpzcKkcUiwU8E(i2HKQH35WElfXu0TGTU3ZhX0SOIH5ugCeqds(9HiwcjXy15xm2JeddjvdVZH9wsmFeJHEcTDXqHtHyocjMEExdcjgZ8SNy5ReRe7xjwzs52NUJFXiqOxSgvmEKyjKelDXkY9i2E1iX4m7hO7eJ96hNyAU8Cckg49U8U(5ueBbBNGDgX4SymSOOaNtzWray1fJBUfJHfffaK87dbGvxmoj2oXkYZjynVlVR)kKkY(pXWlwjJESuoe1oIrFYeiveCrmfDlyR798rSsS)(qelDX4RwITxnsmETJmSUyCeJFX0KwIXRDeX4ig)ILVsSsqmETJighXelrDck2(y(9HeXYL3ZhXwziuZL3Zxd95rSfSDc2zeJHfff4qyH9w6R(a)unaS6ITtS1uWmv9PF)aueAVAxmqHxmoig3Cl2PtHq1tioYpGdHf2BPVE(aledVy8vSDITMcMPQp97NyLJxm(kg3Cl2AkyMQ(0VFakcTxTlgOWlgxIPXIXzX8mqVdOisNG1ZHPN4Oca6tMaPeBNymSOOaGKFFiaS6IXPiwOpV(zbfXq7VpKOhlf8JAhXOpzcKkcUi2c2ob7mI5zGEh4BCi(5zylbbOpzcKsSDIbzFcDG4iaV)nvF2tVQmHura0Nmbsj2oXoDkeQEcXr(bCiSWEl91ZhyHyGsmnfXYL3ZhXoKgKOhlLVrTJy0NmbsfbxelxEpFe7qs1W7CyVLIyRnRav9eIJ8lwkxrSfSDc2zeRSIbsc7KjqaShv1H9aBFtfoE698ITtmfXWIIcG2VQYJYTpDhaKkY(pXaLyCj2oXoDkeQEcXr(bCiSWEl91ZhyHyGcVyGVy7eZtioYb8UGQ(uvnjMglgKkY(pXkxSsiIPOBbBDVNpIbE0fZhXaFX8eIJ8tmo)Jy6WE4KyBjsxmwDXkX(vIvMuU9P7eJzJyRnRq)4eddjvdVZH9wci6Xs1uu7ig9jtGurWfXYL3ZhXoKun8oh2BPiMIUfS19E(iwjoqX0H9aBFJyWXtVNNFXypsmmKun8oh2BjXgqiOyy(aleJx7iIvMAoXsCz)NlgRUy(igFfZtioYpXgOynQyLyzkwFIbz)VFCInOOIX55fl)nILfd77InOI5jeh5hNIyly7eSZigijStMabWEuvh2dS9nv44P3Zl2oX4SykIHfffaTFvLhLBF6oaivK9FIbkX4smU5wmpd07a8OuF(I8CccqFYeiLy7e70PqO6jeh5hWHWc7T0xpFGfIbk8IXxX4u0JLwcrTJy0NmbsfbxeBbBNGDgXoDkeQEcXr(jw54fd8ftlX4SymSOOaocvHJ70dWQlg3ClgK9j0bIJaYTzc7REdBOIctCf07a0NmbsjgNeBNyCwmgwuuGBtbZeU6Gwvu6i1K1NfSDawDX4MBXkRymSOOa6qQGuTNEppaRUyCZTyNofcvpH4i)eRC8IPjX4uelxEpFe7qyH9w6RNpWIOhlLpf1oIrFYeiveCrSC598rSdjvdVZH9wkIPOBbBDVNpIHHKQH35WEljMpIbjuiDiIvI9ReRmPC7t3jw(kX8rm6pwijgpsSv(ITsiCJydieuSumu2qqSsSmfRFFeZriXEApUyydhfRrftFURzceqeBbBNGDgXuedlkkaA)Qkpk3(0DaqQi7)edu4fJlX4MBXwZeudVh42uWmHRoOvfLocaKkY(pXaLyCTVfBNykIHfffaTFvLhLBF6oaivK9FIbkXwZeudVh42uWmHRoOvfLocaKkY(VOhlDFh1oIrFYeiveCrSfSDc2zeJHfffqNGOdmDsvbH6)aopxBfRC8IPjX2j2AEfB7a6eeDGPtQkiu)ham)TIvoEX4c8Jy5Y75Jy4cZuWesff9yP7drTJy5Y75JyhsQgENd7TueJ(KjqQi4IESuUkzu7ig9jtGurWfXwW2jyNrSYkMNqCKd0xLzUtSDITMcMPQp97hGIq7v7IvoEX4sSDIXWIIcCiJx7V6iuvLWTaS6ITtm6jiUnaExqvFQ8TKIvUy4wkGICprSC598rSfcL61dz8Oh9iMIqt2Gh1owkxrTJy5Y75JyB712ig9jtGurWf9yPCiQDeJ(KjqQi4IyJEe7ipILlVNpIbsc7KjqrmqYalfXyyrrbUqVOA(QQQxeaRUyCZTyNofcvpH4i)aoewyVL(65dSqSYXlwjeXu0TGTU3ZhXaphPeZhXuKtWI(jX4HqocbfBntqn8(tmEz7IHoqXWEokgtEKsS5fZtioYpGigijS(zbfXUxvxZRAVNp6Xsb)O2rm6tMaPIGlIn6rSJ8iwU8E(igijStMafXajdSueth2dS9nv44P3Zl2oXoDkeQEcXr(bCiSWEl91ZhyHyLJxmoeXu0TGTU3ZhX4d8HnITqYhhjgC8075fRrfJhjgsccjMoShy7BQWXtVNxSJCXYxjwbBWB9ajMNqCKFIXQdeXajH1plOig7rvDypW23uHJNEpF0JLY3O2rm6tMaPIGlIPOBbBDVNpITxeATvS9YXtS0fdTHNhXYL3ZhXwziuZL3Zxd95rSqFE9ZckITux0JLQPO2rm6tMaPIGlIPOBbBDVNpIvgSVyOSHWgXoETVqOtmFeZriXWCkdocPeRmgp9EEX4mZgXut)4e7g(Bxm0bUOtm9zc9JtSgvSFCK(XjwFILGKDizceNaIy5Y75Jyq2VMlVNVg6ZJyly7eSZi25ugCesbKHqel0Nx)SGIyNtzWriv0JLwcrTJy0NmbsfbxelxEpFe7c9IQ5RQQErrmfDlyR798rmWRUEyJyxOxunFvv1lsS0fJdAj2E1iXuSW(XjMJqIH2WZfJRsk2rR5vh)jQtqXCK0fJVAj2E1iXAuXAxmAp6nKoX41os)I5iKypThxS91E5OyduS(e7hxmw9i2c2ob7mID6uiu9eIJ8d4qyH9w6RNpWcXaLyLGy7edTXH4vivK9FIvUyLGy7eJHfff4c9IQ5RQQEraqQi7)eduIHBPakY9i2oXwtbZu1N(9tSYXlgFftJfJZI5DbjgOeJRskgNetZlghIESu(uu7ig9jtGurWfXu0TGTU3ZhX0iypW23iwzmE6988bjMMH89FIHRbHelfBbtDXsMH1fJEcIBJyOdumhHe7CkdoIy7LJNyCMHTdkck25DiigKoDA5I1oNaeJpywD(BxSv(IXqI5iPl21f6bciILlVNpITYqOMlVNVg6ZJyly7eSZigijStMabWEuvh2dS9nv44P3ZhXc951plOi25ugCK6sDrpw6(oQDeJ(KjqQi4IyJEe7ipILlVNpIbsc7KjqrmqYalfX4GMetlX8mqVdasJBGa0NmbsjMMxmousX0smpd07af55eSoO1djvdVdG(KjqkX08IXHskMwI5zGEh4qs1WRIol2dG(KjqkX08IXbnjMwI5zGEhid5c2(ga6tMaPetZlghkPyAjgh0KyAEX4SyNofcvpH4i)aoewyVL(65dSqSYXlgFfJtrmfDlyR798rmWZrkX8rmfH2pjgpe6fZhXypsSZPm4iITxoEInqXyy7GIGxedKew)SGIyNtzWrQocKoKjOIES09HO2rm6tMaPIGlIPOBbBDVNpIT35VwrqXyV(XjwkgMtzWreBVCumEi0lgKYfs)4eZriXONG42iMJaPdzcQiwU8E(i2kdHAU8E(AOppITGTtWoJy0tqCBaueAVAxmqHxmqsyNmbc4Ckdos1rG0Hmbvel0Nx)SGIyNtzWrQl1f9yPCvYO2rm6tMaPIGlIPOBbBDVNpIvMTJighXeld3igA)9Hiw6IXxTelXL9FUy8vmpH4i)eJZdRFTIe7CkdocNIy5Y75JyRmeQ5Y75RH(8i2c2ob7mITMcMPQp97Ny4fl)UixijehPQlDX4MBXwtbZu1N(9dqrO9QDXafEX4smU5wm0ghIxHur2)jgOWlgxITtS1uWmv9PF)eRC8Ib(IXn3IXWIIcCBkyMWvh0QIshPMS(SGTdWQl2oXwtbZu1N(9tSYXlgFfJBUf70PqO6jeh5hWHWc7T0xpFGfIvoEX4Ry7eBnfmtvF63pXkhVy8nIf6ZRFwqrm0(7dj6Xs5IRO2rm6tMaPIGlIPOBbBDVNpIbEosSumg2oOiOy8qOxmiLlK(XjMJqIrpbXTrmhbshYeurSC598rSvgc1C5981qFEeBbBNGDgXONG42aOi0E1UyGcVyGKWozceW5ugCKQJaPdzcQiwOpV(zbfXyy7Gk6Xs5IdrTJy0NmbsfbxelxEpFelHR8PQpqi9Eetr3c26EpFetZm8OZfth2dS9nI1Vyzii2GkMJqIbE1inJym0kzpsS2fBLShDILITV2lhJyly7eSZig9ee3gafH2R2fRC8IXLMetlXONG42aajC0h9yPCb(rTJy5Y75JyjCLpv1zdhfXOpzcKkcUOhlLl(g1oILlVNpIfACi(v5dXQWvqVhXOpzcKkcUOhlLlnf1oILlVNpIXK4QdA1H9A7fXOpzcKkcUOh9iMoKwtbt6rTJLYvu7iwU8E(iwQRh2u1N(MpIrFYeiveCrpwkhIAhXYL3ZhXyg3dKQIgYnKIx)4Q(SN(Jy0Nmbsfbx0JLc(rTJy5Y75JyNtzWrIy0Nmbsfbx0JLY3O2rm6tMaPIGlILlVNpIvKWTKQIoWQIshjIPdP1uWKE9O18QlIXLMIESunf1oIrFYeiveCrSC598rSl0lQMVQQ6ffXwW2jyNrmiHcPdjzcuethsRPGj96rR5vxeJROhlTeIAhXOpzcKkcUi2c2ob7mIbzFcDG4iGIeUToOvhHQf55eSM3L31pa9jtGurSC598rSdjvdVktiv0f9OhXyy7GkQDSuUIAhXOpzcKkcUi2c2ob7mIvwX8mqVd8noe)8mSLGa0Nmbsj2oXGSpHoqCeG3)MQp7PxvMqQia6tMaPeBNyNofcvpH4i)aoewyVL(65dSqmqjMMIy5Y75Jyhsds0JLYHO2rm6tMaPIGlITGTtWoJyNofcvpH4i)eRC8IXbX2jgNfBntqn8EGJGW0jvLzEQE69wcyHKqC0vrH5Y75ZGyGcVyCaGpPjX4MBXoDkeQEcXr(bCiSWEl91ZhyHyLlgFfJtrSC598rSdHf2BPVE(alIESuWpQDeJ(KjqQi4Iyly7eSZi2AMGA49ahbHPtQkZ8u907TeWcjH4ORIcZL3ZNbXkhVyCaGpPjX4MBXUHnW0VciqPQYSPs7jl0dea9jtGuITtSYkgdlkkqGsvLztL2twOhiaw9iwU8E(i2rqy6KQYmpvp9Elf9yP8nQDelxEpFedxyMcMqQOig9jtGurWf9yPAkQDelxEpFeJjxBppzIy0Nmbsfbx0JEeBPUO2Xs5kQDeJ(KjqQi4Iyly7eSZiwzfJHfff4qs1WRQYFraS6ITtmgwuuGdHf2BPV6d8t1aWQl2oXyyrrboewyVL(QpWpvdaKkY(pXafEXaFanfXypQoOOvClvSuUIy5Y75JyhsQgEvv(lkIPOBbBDVNpIbEosmoM)IeBqr1yClLyme6ajXCesm0gEUyhclS3sF98bwigkCket7b(PAeBnf0jw)arpwkhIAhXOpzcKkcUi2c2ob7mIXWIIcCiSWEl9vFGFQgawDX2jgdlkkWHWc7T0x9b(PAaGur2)jgOWlg4dOPig7r1bfTIBPILYvelxEpFe72uWmHRoOvfLosetr3c26EpFeJZGNpq3jwgGuQ2igRUym0kzpsmEKy(mBfddjvdpXkXzXECsm2JedBtbZeoXguung3sjgdHoqsmhHedTHNl2HWc7T0xpFGfIHcNcX0EGFQgXwtbDI1pq0JLc(rTJy0NmbsfbxeBbBNGDgXajHDYeiG7v118Q275fBNyLvSZPm4iKcOiFpqrSC598rm0qIJcH075JESu(g1oIrFYeiveCrSfSDc2zeJZIbzFcDG4iGIeUToOvhHQf55eSM3L31pa9jtGuITtS1uWmv9PF)aueAVAxmqHxmUetJfZZa9oGIiDcwphMoHJkaOpzcKsmU5wmi7tOdehbOO0rcBQhsQgEha9jtGuITtS1uWmv9PF)eduIXLyCsSDIXWIIcCBkyMWvh0QIshbGvxSDIXWIIcCiPA4vv5ViawDX2jwrEobR5D5D9xHur2)jgEXkPy7eJHfffqrPJe2upKun8oa1W7Jy5Y75JyGKFFirpwQMIAhXOpzcKkcUiMIUfS19E(iMgntqm0bkM2d8t1iMoK0ySHJIXRDeXWq4OyqkvBeJhc9I9JlgK9)(XjgwjceXqhy9P94Xs5kITGTtWoJyEgO3boewyVL(QpWpvda9jtGuITtSYkMNb6DGdjvdVk6Sypa6tMaPIy5Y75Jy6ZeQq6gw4IIES0siQDeJ(KjqQi4Iy5Y75JyhclS3sF1h4NQjIPOBbBDVNpIbEosmTh4NQrmDijg2WrX4HqVy8iXqsqiXCesm6jiUnIXdHCeckgkCketFMq)4eJx7idRlgwjk2afJpe75IHJEcMHWgGi2c2ob7mIrpbXTrSYXlwjusX2jgijStMabCVQUMx1EpVy7eBntqn8EGBtbZeU6Gwvu6iaS6ITtS1mb1W7boKun8QQ8xeWcjH4OtSYXlgxrpwkFkQDeJ(KjqQi4Iy5Y75JyhbHPtQkZ8u907TueBbBNGDgXajHDYeiG7v118Q275fBNyLvm14ahbHPtQkZ8u907TuvnoG3RT9JtSDI5jeh5aExqvFQQMeRC8IXbUeJBUfdTXH4vivK9FIbk8IPjX2j2PtHq1tioYpGdHf2BPVE(aleduIb(rS1MvGQEcXr(flLROhlDFh1oIrFYeiveCrSfSDc2zedKe2jtGaUxvxZRAVNxSDITMcMPQp97hGIq7v7IvoEX4kILlVNpIDK(1x0JLUpe1oIrFYeiveCrSC598rSBtbZeU6Gwvu6irmfDlyR798rmWZrIHTPGzcNyZl2AMGA49IX5e1jOyOn8CXWEoYjXy)aDNy8iXsijgUPFCI5Jy6JUyApWpvJy5RetnI9JlgsccjggsQgEIvIZI9aIyly7eSZigijStMabCVQUMx1EpVy7eJZI5zGEhGEqOWO3pU6HKQH3bqFYeiLyCZTyRzcQH3dCiPA4vv5ViGfscXrNyLJxmUeJtITtmolwzfZZa9oWHWc7T0x9b(PAaOpzcKsmU5wmpd07ahsQgEv0zXEa0Nmbsjg3Cl2AMGA49ahclS3sF1h4NQbasfz)NyLlgheJtrpwkxLmQDeJ(KjqQi4Iy5Y75JyfjClPQOdSQO0rIyH(P6sfX4cqtrS1MvGQEcXr(flLRi2c2ob7mIbZwvjqO3bsL6ay1fBNyCwmpH4ihW7cQ6tv1KyGsS1uWmv9PF)aueAVAxmU5wSYk25ugCesbKHGy7eBnfmtvF63pafH2R2fRC8IT0Rf5EQNo9kX4uetr3c26EpFetZIkwQuNyjKeJvNFXUV1jXCesS5jX41oIyHHhDUyARnhbed8CKy8qOxm1M(XjgAEobfZrYxS9QrIPi0E1UyduSFCXoNYGJqkX41oYW6IL)gX2Rgbe9yPCXvu7ig9jtGurWfXYL3ZhXks4wsvrhyvrPJeXu0TGTU3ZhX0SOI9JyPsDIXRdbXunjgV2r6xmhHe7P94Ib(L84xm2JetZHYrXMxmM5oX41oYW6IL)gX2RgbeXwW2jyNrmy2Qkbc9oqQuhq)IvUyGFjftJfdMTQsGqVdKk1bOyHP3Zl2oXwtbZu1N(9dqrO9QDXkhVyl9ArUN6PtVk6Xs5IdrTJy0NmbsfbxeBbBNGDgXajHDYeiG7v118Q275fBNyRPGzQ6t)(bOi0E1UyLJxmoeXYL3ZhXoKun8QmHurx0JLYf4h1oIrFYeiveCrSfSDc2zedKe2jtGaUxvxZRAVNxSDITMcMPQp97hGIq7v7IvoEX4Gy7eJZIbsc7KjqaShv1H9aBFtfoE698IXn3ID6uiu9eIJ8d4qyH9w6RNpWcXafEX4RyCkILlVNpIrlKPFCviPd7I8vrpwkx8nQDeJ(KjqQi4Iy5Y75JyhclS3sF1h4NQjIPOBbBDVNpIvMTJigwjYVynQy)4ILbiLQnIPMN4xm2Jet7b(PAeJx7iIHnCumwDGi2c2ob7mI5zGEh4qs1WRIol2dG(KjqkX2jgijStMabCVQUMx1EpVy7eJHfff42uWmHRoOvfLocaRE0JLYLMIAhXOpzcKkcUi2c2ob7mIvwXyyrrboKun8QQ8xeaRUy7edTXH4vivK9FIbk8ITVftlX8mqVdCSmobrzXra0NmbsfXYL3ZhXoKun8QQ8xu0JLYvje1oIrFYeiveCrSfSDc2zeJHfffGjmJkWEoaKYLlg3ClgAJdXRqQi7)eduIb(LumU5wmgwuuGBtbZeU6Gwvu6iaS6ITtmolgdlkkWHKQHxLjKk6ay1fJBUfBntqn8EGdjvdVktiv0baPIS)tmqHxmUkPyCkIPOBbBDVNpIv68A8PtlXoNffvmETJiwy4rqX0H9eXYL3ZhX0hVNp6Xs5Ipf1oIrFYeiveCrSfSDc2zeJHfff42uWmHRoOvfLocaREelxEpFeJjmJQIYc3e9yPCTVJAhXOpzcKkcUi2c2ob7mIXWIIcCBkyMWvh0QIshbGvpILlVNpIXqWJGB7hx0JLY1(qu7ig9jtGurWfXwW2jyNrmgwuuGBtbZeU6Gwvu6iaS6rSC598rm0gsmHzurpwkhkzu7ig9jtGurWfXwW2jyNrmgwuuGBtbZeU6Gwvu6iaS6rSC598rS8x05Wmuxzie9yPCGRO2rm6tMaPIGlILlVNpIXEuTDQ4Iyk6wWw375JyCKqt2GlgAgcm5ARyOdum2lzcKyTtfhFumWZrIXRDeXW2uWmHtSbvmosPJaeXwW2jyNrmgwuuGBtbZeU6Gwvu6iaS6IXn3IH24q8kKkY(pXaLyCOKrp6rSZPm4i1L6IAhlLRO2rm6tMaPIGlIn6rSJ8iwU8E(igijStMafXajdSueBntqn8EGdjvdVQk)fbSqsio6QOWC598zqSYXlgxa8jnfXajH1plOi2HOQocKoKjOIESuoe1oIrFYeiveCrSC598rmqYVpKiMIUfS19E(i2(y(9HiwJkgpsSesITsD9(Xj28IXX8xKylKeIJoaX4dNWWgXyi0bsIH2WZftL)IeRrfJhjgsccj2pIvAJdXppdBjOymSUyCmHBfddjvdpX6xSbQiOy(igoYfRmy1DwijgRUyC(hX0C55eumW7D5D9ZjGi2c2ob7mIXzXkRyGKWozceWHOQocKoKjOeJBUfRSI5zGEh4BCi(5zylbbOpzcKsSDI5zGEhqLWT1djvdpa6tMaPeJtITtS1uWmv9PF)aueAVAxSYfJlX2jwzfdY(e6aXrafjCBDqRocvlYZjynVlVRFa6tMaPIESuWpQDeJ(KjqQi4Iy5Y75Jy6ZeQq6gw4IIy0ECywZIH99igFlzedDG1N2JhlLROhlLVrTJy0NmbsfbxeBbBNGDgXONG42iw54fJVLuSDIrpbXTbqrO9QDXkhVyCvsX2jwzfdKe2jtGaoev1rG0HmbLy7eBnfmtvF63pafH2R2fRCX4sSDIPigwuua0(vvEuU9P7aGur2)jgOeJRiwU8E(i2HKQHxbfurpwQMIAhXOpzcKkcUi2OhXoYJy5Y75JyGKWozcuedKmWsrS1uWmv9PF)aueAVAxSYXlghetlXyyrrboKun8QmHurhaREetr3c26EpFeBVAKyocKoKjOoXqhOy07eSFCIHHKQHNyCm)ffXajH1plOi2HOQRPGzQ6t)(f9yPLqu7ig9jtGurWfXg9i2rEelxEpFedKe2jtGIyGKbwkITMcMPQp97hGIq7v7IvoEXa)i2c2ob7mITgqOpFhy7gyNFedKew)SGIyhIQUMcMPQp97x0JLYNIAhXOpzcKkcUi2OhXoYJy5Y75JyGKWozcuedKmWsrS1uWmv9PF)aueAVAxmqHxmUIyly7eSZigijStMabWEuvh2dS9nv44P3Zl2oXoDkeQEcXr(bCiSWEl91ZhyHyLJxm(gXajH1plOi2HOQRPGzQ6t)(f9yP77O2rm6tMaPIGlILlVNpIDiPA4vv5VOiMIUfS19E(ighZFrIPyH9JtmSnfmt4eBGILmdiKyocKoKjOaIyly7eSZigijStMabCiQ6AkyMQ(0VFITtmolgijStMabCiQQJaPdzckX4MBXyyrrbUnfmt4QdAvrPJaaPIS)tSYXlgxaCqmU5wStNcHQNqCKFahclS3sF98bwiw54fJVITtS1mb1W7bUnfmt4QdAvrPJaaPIS)tSYfJRskgNIES09HO2rm6tMaPIGlILlVNpIDiPA4vv5VOiMIUfS19E(ig4yHVyqQi7VFCIXX8x0jgdHoqsmhHedTXH4IrV6eRrfdB4Oy8MF)UymKyqkvBeRFX8UGaIyly7eSZigijStMabCiQ6AkyMQ(0VFITtm0ghIxHur2)jgOeBntqn8EGBtbZeU6Gwvu6iaqQi7)IE0JyO93hsu7yPCf1oIrFYeiveCrSrpIDKhXYL3ZhXajHDYeOigizGLIyEgO3b0HubPAp9EEa6tMaPeBNyNofcvpH4i)aoewyVL(65dSqmqjgNfttIPXITgqOpFh4PfCcdujgNeBNyLvS1ac957aB3a78Jyk6wWw375JyLjshiXyV(XjMgbPcs1E6988lwcY0kXw559JtmSqViXYxjgh7fjgpe6fddjvdpX4y(lsS(e7M5fZhXyiXypsXVy0EwKUlg6afJp3gyNFedKew)SGIy6qQGu17v118Q275JESuoe1oIrFYeiveCrSfSDc2zeRSIbsc7Kjqa6qQGu17v118Q275fBNyNofcvpH4i)aoewyVL(65dSqmqjwji2oXkRymSOOahsQgEvv(lcGvxSDIXWIIcCHEr18vvvViaivK9FIbkXqBCiEfsfz)Ny7edsOq6qsMafXYL3ZhXUqVOA(QQQxu0JLc(rTJy0NmbsfbxeBbBNGDgXajHDYeiaDivqQ69Q6AEv798ITtS1mb1W7boKun8QQ8xeWcjH4ORIcZL3ZNbXaLyCbWN0Ky7eJHfff4c9IQ5RQQEraqQi7)eduITMjOgEpWTPGzcxDqRkkDeaivK9FITtmol2AMGA49ahsQgEvv(lcasPAJy7eJHfff42uWmHRoOvfLocaKkY(pX0yXyyrrboKun8QQ8xeaKkY(pXaLyCbWbX4uelxEpFe7c9IQ5RQQErrpwkFJAhXOpzcKkcUi2OhXoYJy5Y75JyGKWozcuedKmWsrSI8CcwZ7Y76VcPIS)tSYfRKIXn3IvwX8mqVd8noe)8mSLGa0Nmbsj2oX8mqVdOs426HKQHha9jtGuITtmgwuuGdjvdVQk)fbWQlg3Cl2PtHq1tioYpGdHf2BPVE(aleRC8Ivcrmqsy9ZckIDBB9kKv3zHu0JLQPO2rm6tMaPIGlILlVNpIbz1DwifXu0TGTU3ZhX4ZrKUyS6IvgS6olKeRrfRDX6tSKzyDX8rmi7l2W6arSfSDc2zeJZIvwXajHDYeiGBBRxHS6olKeJBUfdKe2jtGaypQQd7b2(MkC8075fJtITtmpH4ihW7cQ6tv1KyASyqQi7)eRCXkbX2jgKqH0HKmbk6XslHO2rSC598rSJwqYRoTq(MpJLIy0Nmbsfbx0JLYNIAhXOpzcKkcUiwU8E(igKv3zHueBTzfOQNqCKFXs5kITGTtWoJyLvmqsyNmbc4226viRUZcjX2jwzfdKe2jtGaypQQd7b2(MkC8075fBNyNofcvpH4i)aoewyVL(65dSqSYXlgheBNyEcXroG3fu1NQQjXkhVyCwmnjMwIXzX4GyAEXwtbZu1N(9tmojgNeBNyqcfshsYeOiMIUfS19E(iMMJn4TACVFCI5jeh5Nyos6IXRdbXcniKyOdumhHetXctVNxSbvSYGv3zHKyqcfshIykwy)4etpFfv0lGOhlDFh1oIrFYeiveCrSC598rmiRUZcPiMIUfS19E(iwzqOq6qeRmy1DwijgLWWgXAuXAxmEDiigTh9gsIPyH9JtmSnfmt4aeJJJyos6IbjuiDiI1OIHnCumCKFIbPuTrS(fZriXEApUyA6aIyly7eSZiwzfdKe2jtGaUTTEfYQ7SqsSDIbPIS)tmqj2AMGA49a3McMjC1bTQO0raGur2)jMwIXvjfBNyRzcQH3dCBkyMWvh0QIshbasfz)NyGcVyAsSDI5jeh5aExqvFQQMetJfdsfz)NyLl2AMGA49a3McMjC1bTQO0raGur2)jMwIPPOhlDFiQDeJ(KjqQi4Iyly7eSZiwzfdKe2jtGaypQQd7b2(MkC8075fBNyNofcvpH4i)eRC8Ib(rSC598rmMqU2w1hEkcg9yPCvYO2rSC598rmcK(wemDkIrFYeiveCrp6rpIbcbVE(yPCOKCGRsc(CvYigVe(9J7IyLj4TmkvZw6(IpkMyAJqI1f6d0fdDGIT)ZPm4iKA)Ibj(m2gskXUPGelz9PiDsj2cjFC0biGPz6Ned85JIT35bHGoPeB)q2NqhiocyFUFX8rS9dzFcDG4iG9ja9jtGu7xmoZ1E4eGaMMPFsSsGpk2ENhec6KsS9dzFcDG4iG95(fZhX2pK9j0bIJa2Na0NmbsTFX4mx7HtacyAJqIHoHWWRFCILSW8eJhbjXypsjw)I5iKy5Y75fl0NlgdRlgpcsI9Jlg6W(kX6xmhHelvQ5ftLEYKhXhfWetJf72uWmHRoOvfLosnz9zbBxataRmbVLrPA2s3x8rXetBesSUqFGUyOduS9Ri0Kn47xmiXNX2qsj2nfKyjRpfPtkXwi5JJoabmTriXqNqy41poXswyEIXJGKyShPeRFXCesSC598If6ZfJH1fJhbjX(XfdDyFLy9lMJqILk18IPspzYJ4JcyIPXIDBkyMWvh0QIshPMS(SGTlGjGvMG3YOunBP7l(OyIPncjwxOpqxm0bk2(1H0AkysF)Ibj(m2gskXUPGelz9PiDsj2cjFC0biGPz6NeRe4JIT35bHGoPeB)q2NqhiocyFUFX8rS9dzFcDG4iG9ja9jtGu7xS0fJpmFanJyCMR9WjabmbSYe8wgLQzlDFXhftmTriX6c9b6IHoqX2)sD7xmiXNX2qsj2nfKyjRpfPtkXwi5JJoabmnt)Ky8Lpk2ENhec6KsS9dzFcDG4iG95(fZhX2pK9j0bIJa2Na0NmbsTFX4mh2dNaeWeWktWBzuQMT09fFumX0gHeRl0hOlg6afB)NtzWrQl1TFXGeFgBdjLy3uqILS(uKoPeBHKpo6aeW0m9tIXb(Oy7DEqiOtkX2pK9j0bIJa2N7xmFeB)q2NqhiocyFcqFYei1(flDX4dZhqZigN5ApCcqataRmbVLrPA2s3x8rXetBesSUqFGUyOduS9ZW2b1(fds8zSnKuIDtbjwY6tr6KsSfs(4OdqatZ0pjgx8rX278GqqNuITFi7tOdehbSp3Vy(i2(HSpHoqCeW(eG(KjqQ9lgN5ApCcqatatZwOpqNuIXNelxEpVyH(8dqalID60kwkhkbUIy6WbTduetdAqmmwgpq(gXkJbhljGPbnig4vh2bX4IV8lghkjh4satatdAqmn3acjgijStMabWEuvh2dS9nv44P3ZlgRUy3iw7I1Nyh5IXqOdKeJhjg7rI1oGaMg0Gy7Dky6NeRGn4TEGeBLHqnxEpFn0Nlg9oSPtmFedsk2fjM(407Dgeds8g4wabmbmnObX0iiPX7DkysxalxEp)bOdP1uWKUw4bDQRh2u1N(MxalxEp)bOdP1uWKUw4bnZ4EGuv0qUHu86hx1N90VawU8E(dqhsRPGjDTWd6ZPm4icy5Y75paDiTMcM01cpOls4wsvrhyvrPJWVoKwtbt61JwZRo8CPjbSC598hGoKwtbt6AHh0xOxunFvv1lIFDiTMcM0RhTMxD45I)gfpKqH0HKmbsalxEp)bOdP1uWKUw4b9HKQHxLjKk64VrXdzFcDG4iGIeUToOvhHQf55eSM3L31VaMaMg0GyAUSFXkJXtVNxalxEp)HFBV2kGPbXaphPeZhXuKtWI(jX4HqocbfBntqn8(tmEz7IHoqXWEokgtEKsS5fZtioYpabSC598Nw4bnijStMaX)Nfe(7v118Q2755hKmWs4zyrrbUqVOA(QQQxeaRo3CF6uiu9eIJ8d4qyH9w6RNpWIYXxccyAqm(aFyJylK8XrIbhp9EEXAuX4rIHKGqIPd7b2(MkC8075f7ixS8vIvWg8wpqI5jeh5NyS6acy5Y75pTWdAqsyNmbI)pli8Shv1H9aBFtfoE6988dsgyj86WEGTVPchp9E(DNofcvpH4i)aoewyVL(65dSOC8CqatdITxeATvS9YXtS0fdTHNlGLlVN)0cpOxziuZL3Zxd958)zbHFPobmniwzW(IHYgcBe741(cHoX8rmhHedZPm4iKsSYy8075fJZmBetn9JtSB4VDXqh4IoX0Nj0poXAuX(Xr6hNy9jwcs2HKjqCcqalxEp)PfEqdz)AU8E(AOpN)pli8NtzWrif)nk(ZPm4iKcidbbmnig4vxpSrSl0lQMVQQ6fjw6IXbTeBVAKykwy)4eZriXqB45IXvjf7O18QJ)e1jOyos6IXxTeBVAKynQyTlgTh9gsNy8AhPFXCesSN2Jl2(AVCuSbkwFI9JlgRUawU8E(tl8G(c9IQ5RQQEr83O4pDkeQEcXr(bCiSWEl91ZhybOkHDOnoeVcPIS)R8syhdlkkWf6fvZxvv9IaGur2)bkClfqrUNDRPGzQ6t)(voE(QXC27ccuCvsoP55GaMgetJG9aBFJyLX4P3ZZhKyAgY3)jgUgesSuSfm1flzgwxm6jiUnIHoqXCesSZPm4iITxoEIXzg2oOiOyN3HGyq60PLlw7Ccqm(Gz15VDXw5lgdjMJKUyxxOhiabSC598Nw4b9kdHAU8E(AOpN)pli8NtzWrQl1XFJIhKe2jtGaypQQd7b2(MkC8075fW0GyGNJuI5JykcTFsmEi0lMpIXEKyNtzWreBVC8eBGIXW2bfbpbSC598Nw4bnijStMaX)Nfe(ZPm4ivhbshYeu8dsgyj8CqtA5zGEhaKg3abOpzcKsZZHsQLNb6DGI8Ccwh06HKQH3bqFYeiLMNdLulpd07ahsQgEv0zXEa0NmbsP55GM0YZa9oqgYfS9na0NmbsP55qj1IdAsZZ5tNcHQNqCKFahclS3sF98bwuoE(Yjbmni2EN)AfbfJ96hNyPyyoLbhrS9YrX4HqVyqkxi9JtmhHeJEcIBJyocKoKjOeWYL3ZFAHh0RmeQ5Y75RH(C()SGWFoLbhPUuh)nkE6jiUnakcTxTdk8GKWozceW5ugCKQJaPdzckbmniwj2FFiILUy8vlX41oYW6IXrmXgOy8AhrmSHJITGTlgdlkk)IPjTeJx7iIXrmX48W6xRiXoNYGJWjbmniwz2oIyCetSmCJyO93hIyPlgF1sSex2)5IXxX8eIJ8tmopS(1ksSZPm4iCsalxEp)PfEqVYqOMlVNVg6Z5)ZccpA)9HWFJIFnfmtvF63p853f5cjH4ivDPZn3RPGzQ6t)(bOi0E1oOWZf3CJ24q8kKkY(pqHNRDRPGzQ6t)(voEWNBUzyrrbUnfmt4QdAvrPJutwFwW2by13TMcMPQp97x545l3CF6uiu9eIJ8d4qyH9w6RNpWIYXZ3DRPGzQ6t)(voE(kGPbXaphjwkgdBhueumEi0lgKYfs)4eZriXONG42iMJaPdzckbSC598Nw4b9kdHAU8E(AOpN)pli8mSDqXFJINEcIBdGIq7v7GcpijStMabCoLbhP6iq6qMGsatdIPzgE05IPd7b2(gX6xSmeeBqfZriXaVAKMrmgALShjw7ITs2JoXsX2x7LJcy5Y75pTWd6eUYNQ(aH0783O4PNG42aOi0E1E545stArpbXTbas4OxalxEp)PfEqNWv(uvNnCKawU8E(tl8Go04q8RYhIvHRGExalxEp)PfEqZK4QdA1H9A7jGjGPbnig4y7GIGNawU8E(dGHTdk8hsdc)nk(Y6zGEh4BCi(5zylbbOpzcKAhK9j0bIJa8(3u9zp9QYesfT70PqO6jeh5hWHWc7T0xpFGfGstcy5Y75pag2oO0cpOpewyVL(65dSG)gf)PtHq1tioYVYXZHDCEntqn8EGJGW0jvLzEQE69wcyHKqC0vrH5Y75ZaOWZba(KM4M7tNcHQNqCKFahclS3sF98bwuoF5KawU8E(dGHTdkTWd6JGW0jvLzEQE69wI)gf)AMGA49ahbHPtQkZ8u907TeWcjH4ORIcZL3ZNHYXZba(KM4M7Bydm9RacuQQmBQ0EYc9abqFYei1UYYWIIceOuvz2uP9Kf6bcGvxalxEp)bWW2bLw4bnUWmfmHurcy5Y75pag2oO0cpOzY12ZtgbmbmnObX27mb1W7pbmnig45iX4y(lsSbfvJXTuIXqOdKeZriXqB45IDiSWEl91ZhyHyOWPqmTh4NQrS1uqNy9diGLlVN)awQtl8G(qs1WRQYFr8ZEuDqrR4wk8CXFJIVSmSOOahsQgEvv(lcGvFhdlkkWHWc7T0x9b(PAay13XWIIcCiSWEl9vFGFQgaivK9FGcp4dOjbmnigNbpFGUtSmaPuTrmwDXyOvYEKy8iX8z2kggsQgEIvIZI94KyShjg2McMjCInOOAmULsmgcDGKyocjgAdpxSdHf2BPVE(aledfofIP9a)unITMc6eRFabSC598hWsDAHh03McMjC1bTQO0r4N9O6GIwXTu45I)gfpdlkkWHWc7T0x9b(PAay13XWIIcCiSWEl9vFGFQgaivK9FGcp4dOjbSC598hWsDAHh0OHehfcP3ZZFJIhKe2jtGaUxvxZRAVNFxzpNYGJqkGI89ajGLlVN)awQtl8GgK87dH)gfpNHSpHoqCeqrc3wh0QJq1I8CcwZ7Y76F3AkyMQ(0VFakcTxTdk8CPXEgO3buePtW65W0jCuba9jtGuCZnK9j0bIJauu6iHn1djvdVB3AkyMQ(0VFGIloTJHfff42uWmHRoOvfLocaR(ogwuuGdjvdVQk)fbWQVRipNG18U8U(RqQi7)WxYDmSOOakkDKWM6HKQH3bOgEVaMgetJMjig6aft7b(PAethsAm2WrX41oIyyiCumiLQnIXdHEX(XfdY(F)4edRebeWYL3ZFal1PfEqRptOcPByHlIF0bwFApoEU4VrX7zGEh4qyH9w6R(a)una0NmbsTRSEgO3boKun8QOZI9aOpzcKsatdIbEosmTh4NQrmDijg2WrX4HqVy8iXqsqiXCesm6jiUnIXdHCeckgkCketFMq)4eJx7idRlgwjk2afJpe75IHJEcMHWgabSC598hWsDAHh0hclS3sF1h4NQH)gfp9ee3MYXxcLChijStMabCVQUMx1Ep)U1mb1W7bUnfmt4QdAvrPJaWQVBntqn8EGdjvdVQk)fbSqsio6khpxcy5Y75pGL60cpOpcctNuvM5P6P3Bj(xBwbQ6jeh5hEU4VrXdsc7Kjqa3RQR5vT3ZVRSQXbocctNuvM5P6P3BPQACaVxB7h3opH4ihW7cQ6tv1u545axCZnAJdXRqQi7)afEnT70PqO6jeh5hWHWc7T0xpFGfGc8fWYL3ZFal1PfEqFK(1h)nkEqsyNmbc4EvDnVQ9E(DRPGzQ6t)(bOi0E1E545satdIbEosmSnfmt4eBEXwZeudVxmoNOobfdTHNlg2Zrojg7hO7eJhjwcjXWn9JtmFetF0ft7b(PAelFLyQrSFCXqsqiXWqs1WtSsCwShGawU8E(dyPoTWd6BtbZeU6Gwvu6i83O4bjHDYeiG7v118Q2753Xzpd07a0dcfg9(XvpKun8oa6tMaP4M71mb1W7boKun8QQ8xeWcjH4ORC8CXPDCUSEgO3boewyVL(QpWpvda9jtGuCZTNb6DGdjvdVk6Sypa6tMaP4M71mb1W7boewyVL(QpWpvdaKkY(VY5aNeW0GyAwuXsL6elHKyS68l29TojMJqInpjgV2relm8OZftBT5iGyGNJeJhc9IP20poXqZZjOyos(ITxnsmfH2R2fBGI9Jl25ugCesjgV2rgwxS83i2E1iabSC598hWsDAHh0fjClPQOdSQO0r4p0pvxk8CbOj(xBwbQ6jeh5hEU4VrXdZwvjqO3bsL6ay13XzpH4ihW7cQ6tv1eOwtbZu1N(9dqrO9QDU5USNtzWrifqgc7wtbZu1N(9dqrO9Q9YXV0Rf5EQNo9kojGPbX0SOI9JyPsDIXRdbXunjgV2r6xmhHe7P94Ib(L84xm2JetZHYrXMxmM5oX41oYW6IL)gX2RgbiGLlVN)awQtl8GUiHBjvfDGvfLoc)nkEy2Qkbc9oqQuhq)Ld(LuJHzRQei07aPsDakwy6987wtbZu1N(9dqrO9Q9YXV0Rf5EQNo9kbSC598hWsDAHh0hsQgEvMqQOJ)gfpijStMabCVQUMx1Ep)U1uWmv9PF)aueAVAVC8CqalxEp)bSuNw4bnTqM(XvHKoSlYxXFJIhKe2jtGaUxvxZRAVNF3AkyMQ(0VFakcTxTxoEoSJZGKWozcea7rvDypW23uHJNEpp3CF6uiu9eIJ8d4qyH9w6RNpWcqHNVCsatdIvMTJigwjYVynQy)4ILbiLQnIPMN4xm2Jet7b(PAeJx7iIHnCumwDabSC598hWsDAHh0hclS3sF1h4NQH)gfVNb6DGdjvdVk6Sypa6tMaP2bsc7Kjqa3RQR5vT3ZVJHfff42uWmHRoOvfLocaRUawU8E(dyPoTWd6djvdVQk)fXFJIVSmSOOahsQgEvv(lcGvFhAJdXRqQi7)af(9TwEgO3bowgNGOS4ia6tMaPeW0GyLoVgF60sSZzrrfJx7iIfgEeumDypcy5Y75pGL60cpO1hVNN)gfpdlkkatygvG9CaiLlNBUrBCiEfsfz)hOa)sYn3mSOOa3McMjC1bTQO0ray13XzgwuuGdjvdVktiv0bWQZn3RzcQH3dCiPA4vzcPIoaivK9FGcpxLKtcy5Y75pGL60cpOzcZOQOSWn83O4zyrrbUnfmt4QdAvrPJaWQlGLlVN)awQtl8GMHGhb32po(Bu8mSOOa3McMjC1bTQO0ray1fWYL3ZFal1PfEqJ2qIjmJI)gfpdlkkWTPGzcxDqRkkDeawDbSC598hWsDAHh05VOZHzOUYqG)gfpdlkkWTPGzcxDqRkkDeawDbmnighj0Kn4IHMHatU2kg6afJ9sMajw7uXXhfd8CKy8AhrmSnfmt4eBqfJJu6iacy5Y75pGL60cpOzpQ2ovC83O4zyrrbUnfmt4QdAvrPJaWQZn3OnoeVcPIS)duCOKcycyAqdIvI93hcbpbmniwzI0bsm2RFCIPrqQGuTNEpp)ILGmTsSvEE)4edl0lsS8vIXXErIXdHEXWqs1WtmoM)IeRpXUzEX8rmgsm2Ju8lgTNfP7IHoqX4ZTb25lGLlVN)aq7Vpe8GKWozce)Fwq41HubPQ3RQR5vT3ZZpizGLW7zGEhqhsfKQ9075bOpzcKA3PtHq1tioYpGdHf2BPVE(alafN1KgVgqOpFh4PfCcduXPDLDnGqF(oW2nWoFbSC598haA)9HOfEqFHEr18vvvVi(Bu8LfKe2jtGa0HubPQ3RQR5vT3ZV70PqO6jeh5hWHWc7T0xpFGfGQe2vwgwuuGdjvdVQk)fbWQVJHfff4c9IQ5RQQEraqQi7)afAJdXRqQi7)2bjuiDijtGeWYL3ZFaO93hIw4b9f6fvZxvv9I4VrXdsc7Kjqa6qQGu17v118Q2753TMjOgEpWHKQHxvL)IawijehDvuyU8E(makUa4tAAhdlkkWf6fvZxvv9IaGur2)bQ1mb1W7bUnfmt4QdAvrPJaaPIS)BhNxZeudVh4qs1WRQYFraqkvB2XWIIcCBkyMWvh0QIshbasfz)NgZWIIcCiPA4vv5ViaivK9FGIlaoWjbSC598haA)9HOfEqdsc7Kjq8)zbH)226viRUZcj(bjdSe(I8CcwZ7Y76VcPIS)R8sYn3L1Za9oW34q8ZZWwccqFYei1opd07aQeUTEiPA4bqFYei1ogwuuGdjvdVQk)fbWQZn3NofcvpH4i)aoewyVL(65dSOC8La)85PGobfBFmHDYeiXqhOyLbRUZcjaXW226IPyH9JtmnxEobfd8ExEx)InqXuSW(XjghZFrIXRDeX4yc3kw(kX(rSsBCi(5zylbbeW0Gy85isxmwDXkdwDNfsI1OI1Uy9jwYmSUy(igK9fByDabSC598haA)9HOfEqdz1DwiXFJINZLfKe2jtGaUTTEfYQ7SqIBUbjHDYeia2JQ6WEGTVPchp9EEoTZtioYb8UGQ(uvnPXqQi7)kVe2bjuiDijtGeWYL3ZFaO93hIw4b9rli5vNwiFZNXscyAqmnhBWB14E)4eZtioYpXCK0fJxhcIfAqiXqhOyocjMIfMEpVydQyLbRUZcjXGekKoeXuSW(XjME(kQOxacy5Y75pa0(7drl8GgYQ7SqI)1MvGQEcXr(HNl(Bu8LfKe2jtGaUTTEfYQ7SqAxzbjHDYeia2JQ6WEGTVPchp9E(DNofcvpH4i)aoewyVL(65dSOC8CyNNqCKd4Dbv9PQAQC8CwtAXzoO5xtbZu1N(9JtCAhKqH0HKmbsatdIvgekKoeXkdwDNfsIrjmSrSgvS2fJxhcIr7rVHKykwy)4edBtbZeoaX44iMJKUyqcfshIynQyydhfdh5NyqkvBeRFXCesSN2JlMMoabSC598haA)9HOfEqdz1DwiXFJIVSGKWozceWTT1RqwDNfs7Gur2)bQ1mb1W7bUnfmt4QdAvrPJaaPIS)tlUk5U1mb1W7bUnfmt4QdAvrPJaaPIS)du410opH4ihW7cQ6tv1KgdPIS)R81mb1W7bUnfmt4QdAvrPJaaPIS)tlnjGLlVN)aq7VpeTWdAMqU2w1hEkcYFJIVSGKWozcea7rvDypW23uHJNEp)UtNcHQNqCKFLJh8fWYL3ZFaO93hIw4bnbsFlcMojGjGPbnigMtzWreBVZeudV)eWYL3ZFaNtzWrQl1PfEqdsc7Kjq8)zbH)quvhbshYeu8dsgyj8RzcQH3dCiPA4vv5ViGfscXrxffMlVNpdLJNla(KM4Nppf0jOy7JjStMajGPbX2hZVpeXAuX4rILqsSvQR3poXMxmoM)IeBHKqC0bigF4eg2igdHoqsm0gEUyQ8xKynQy8iXqsqiX(rSsBCi(5zylbfJH1fJJjCRyyiPA4jw)InqfbfZhXWrUyLbRUZcjXy1fJZ)iMMlpNGIbEVlVRFobiGLlVN)aoNYGJuxQtl8GgK87dH)gfpNllijStMabCiQQJaPdzckU5USEgO3b(ghIFEg2sqa6tMaP25zGEhqLWT1djvdpa6tMaP40U1uWmv9PF)aueAVAVCU2vwi7tOdehbuKWT1bT6iuTipNG18U8U(fWYL3ZFaNtzWrQl1PfEqRptOcPByHlIF0bwFApoEU4N2JdZAwmSVJNVLKFnAMGyOdummKun8kOGsmTeddjvdVZH9wsm2pq3jgpsSesILmdRlMpITsDXMxmoM)IeBHKqC0bigFGpSrmEi0lwj2VsSYKYTpDNy9jwYmSUy(igK9fByDabSC598hW5ugCK6sDAHh0hsQgEfuqXFJINEcIBt545Bj3rpbXTbqrO9Q9YXZvj3vwqsyNmbc4quvhbshYeu7wtbZu1N(9dqrO9Q9Y5ANIyyrrbq7xv5r52NUdasfz)hO4satdITxnsmhbshYeuNyOdum6Dc2poXWqs1WtmoM)IeWYL3ZFaNtzWrQl1PfEqdsc7Kjq8)zbH)qu11uWmv9PF)4hKmWs4xtbZu1N(9dqrO9Q9YXZbTyyrrboKun8QmHurhaRUawU8E(d4CkdosDPoTWdAqsyNmbI)pli8hIQUMcMPQp97h)GKbwc)AkyMQ(0VFakcTxTxoEWN)gf)AaH(8DGTBGD(cy5Y75pGZPm4i1L60cpObjHDYei()SGWFiQ6AkyMQ(0VF8dsgyj8RPGzQ6t)(bOi0E1oOWZf)nkEqsyNmbcG9OQoShy7BQWXtVNF3PtHq1tioYpGdHf2BPVE(alkhpFfW0GyCm)fjMIf2poXW2uWmHtSbkwYmGqI5iq6qMGcqalxEp)bCoLbhPUuNw4b9HKQHxvL)I4VrXdsc7KjqahIQUMcMPQp973oodsc7KjqahIQ6iq6qMGIBUzyrrbUnfmt4QdAvrPJaaPIS)RC8CbWbU5(0PqO6jeh5hWHWc7T0xpFGfLJNV7wZeudVh42uWmHRoOvfLocaKkY(VY5QKCsatdIbow4lgKkY(7hNyCm)fDIXqOdKeZriXqBCiUy0RoXAuXWgokgV53VlgdjgKs1gX6xmVliabSC598hW5ugCK6sDAHh0hsQgEvv(lI)gfpijStMabCiQ6AkyMQ(0VF7qBCiEfsfz)hOwZeudVh42uWmHRoOvfLocaKkY(pbmbmnObXWCkdocPeRmgp9EEbmniMMfvmmNYGJaAqYVpeXsijgRo)IXEKyyiPA4DoS3sI5Jym0tOTlgkCkeZriX0Z7AqiXyMN9elFLyLy)kXktk3(0D8lgbc9I1OIXJelHKyPlwrUhX2RgjgNz)aDNySx)4etZLNtqXaV3L31pNeWYL3ZFaNtzWrif(djvdVZH9wI)gfpNzyrrboNYGJaWQZn3mSOOaGKFFiaS6CAxrEobR5D5D9xHur2)HVKcyAqSsS)(qelDXaFTeBVAKy8AhzyDX4iMyGwm(QLy8AhrmoIjgV2reddHf2BPxmTh4NQrmgwuuXy1fZhXsqMwj2nfKy7vJeJxEoj21oB698hGaMged8gUrSlrjX8rm0(7drS0fJVAj2E1iX41oIy0EYLh2igFfZtioYpaX4mwwqILNydRFTIe7CkdocaNeW0GyLy)9Hiw6IXxTeBVAKy8AhzyDX4ig)IPjTeJx7iIXrm(flFLyLGy8AhrmoIjwI6euS9X87dralxEp)bCoLbhHuAHh0RmeQ5Y75RH(C()SGWJ2FFi83O4zyrrboewyVL(QpWpvdaR(U1uWmv9PF)aueAVAhu45a3CF6uiu9eIJ8d4qyH9w6RNpWc88D3AkyMQ(0VFLJNVCZ9AkyMQ(0VFakcTxTdk8CPXC2Za9oGIiDcwphMEIJkaOpzcKAhdlkkai53hcaRoNeWYL3ZFaNtzWriLw4b9H0GWFJI3Za9oW34q8ZZWwccqFYei1oi7tOdehb49VP6ZE6vLjKkA3PtHq1tioYpGdHf2BPVE(alaLMeW0GyGhDX8rmWxmpH4i)eJZ)iMoShoj2wI0fJvxSsSFLyLjLBF6oXy2i2AZk0poXWqs1W7CyVLaeWYL3ZFaNtzWriLw4b9HKQH35WElX)AZkqvpH4i)WZf)nk(Ycsc7KjqaShv1H9aBFtfoE6987uedlkkaA)Qkpk3(0DaqQi7)afx7oDkeQEcXr(bCiSWEl91ZhybOWd(78eIJCaVlOQpvvtAmKkY(VYlbbmniwjoqX0H9aBFJyWXtVNNFXypsmmKun8oh2BjXgqiOyy(aleJx7iIvMAoXsCz)NlgRUy(igFfZtioYpXgOynQyLyzkwFIbz)VFCInOOIX55fl)nILfd77InOI5jeh5hNeWYL3ZFaNtzWriLw4b9HKQH35WElXFJIhKe2jtGaypQQd7b2(MkC80753XzfXWIIcG2VQYJYTpDhaKkY(pqXf3C7zGEhGhL6ZxKNtqa6tMaP2D6uiu9eIJ8d4qyH9w6RNpWcqHNVCsalxEp)bCoLbhHuAHh0hclS3sF98bwWFJI)0PqO6jeh5x54bFT4mdlkkGJqv44o9aS6CZnK9j0bIJaYTzc7REdBOIctCf07CAhNzyrrbUnfmt4QdAvrPJutwFwW2by15M7YYWIIcOdPcs1E698aS6CZ9PtHq1tioYVYXRjojGPbXWqs1W7CyVLeZhXGekKoeXkX(vIvMuU9P7elFLy(ig9hlKeJhj2kFXwjeUrSbeckwkgkBiiwjwMI1VpI5iKypThxmSHJI1OIPp31mbcqalxEp)bCoLbhHuAHh0hsQgENd7Te)nkEfXWIIcG2VQYJYTpDhaKkY(pqHNlU5Entqn8EGBtbZeU6Gwvu6iaqQi7)afx77DkIHfffaTFvLhLBF6oaivK9FGAntqn8EGBtbZeU6Gwvu6iaqQi7)eWYL3ZFaNtzWriLw4bnUWmfmHur83O4zyrrb0ji6atNuvqO(pGZZ12YXRPDR5vSTdOtq0bMoPQGq9FaW83woEUaFbSC598hW5ugCesPfEqFiPA4DoS3scy5Y75pGZPm4iKsl8GEHqPE9qgN)gfFz9eIJCG(QmZD7wtbZu1N(9dqrO9Q9YXZ1ogwuuGdz8A)vhHQQeUfGvFh9ee3gaVlOQpv(wYYXTuaf5EIE0Jra]] )

    
end
