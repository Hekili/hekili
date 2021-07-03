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


    spec:RegisterPack( "Subtlety", 20210703, [[daL57bqiQi9iQOSjLQ(eQugLkfNsLsRIkQ0ROQQzrfClQqzxQ4xOsmmuLCmufldsLNPsQMMsrUgveBJkQ6BOsQghQKIZHQuQ1PsknpvsUhQyFuv8pujL4GOkflesvpKQknruP6IOscTrQQOpIkjAKOkL0jPIkwjKYlrLuQzQskUjQsv7uPWprLemuQq1svkkpfftLQsxfvsAROkv8vLIQXsvfolQKsAVs8xjnykhw0IHQhRKjtYLr2meFgsgnuoTIvJQuIxRsmBsDBQYUb(TudNkDCuLkTCqpxvtx46O02vQ8DuvJNkKZRuA(QuTFIl8u8TWOYGkBGoEHoE4fxNxx)Wd6qhxVWeBDPcJBUUKOOcdi9OcddlEOPyBHXn3Q7uv8TW8nlCrfgSiC)RLlCb1eyS4Nv7XLF8y1zmnybtKGl)4T4sHbND0HZbuWlmQmOYgOJxOJhEX1511p8Go058oXjfMKnWAyHHz88BHbBukcuWlmk6xfggw8qtXwX2SgfljOHgRERyx3bXqhVqhpcAcA8(Ehj2UeojUMoSpvDHtdNyBf2rgtdeJ1vSVfBcXMxSNcXWjKgsIXNeJ9jXM4iO532dFaKyES6yC1KyRuRR5kMgu1ZhIrGao0lw0Ibjf7IeZTdcetQfds8B4LtHrpF8fFlmFqPoWivX3Yg8u8TWqGextQc6lm5kMguyESu18)aoxOcJI(fCCJPbfgNdIymbL6aJl7sW8yILqsmwxheJ9jXyWsvZ)d4CHelAXWjaHmHyiW2tSaJeZn)F2rIH3a2xSeOeZphGsSnNYla6FheJ2raXgeX4tILqsSmeZlDKy(1Xf7gwGM(xm2FaOeJ3NFqqX4n)N)pGBlml4eeCYcZnIHZIGC(GsDGDyDf7(DXWzrqo7sW8yhwxXUvS9I5LFqWA(F()aQqYlhWlghX4vjkBGUIVfgcK4AsvqFHrr)coUX0GcJFoG5XeldX2K)I5xhxm(tG1SHyCNXbXCI)IXFcmX4oJdILaLyoVy8NatmUZiwIeeumENempwHjxX0GcZk16AUIPbv98rHzbNGGtwyieeAfZoQUAp8U62diEX8HJyl3Qx6O67saLy3VlgolcY5XyHZfcuJgcsvFyDfBVyR2dVRU9aI)OiKznHyxXrm0j297I9UKwxJeIII)8ySW5cbQF0qpX8HJyBsS9Irii0kMDuD1E4D1Thq8I5dhX2Ky3Vl2Q9W7QBpG4pkczwti2vCeJhXCmXUrSi1eiokICjy9dygjkY7qGextkX2lgolcYzxcMh7W6k2Tfg98rfKEuHbzaZJvIYgxV4BHHajUMuf0xywWji4KfMpOuhyK68K7pVy7f7DjTUgjeff)5XyHZfcu)OHEIDLyBQWKRyAqH5XsvZ)d4CHkrzJnv8TWqGextQc6lml4eeCYctKAcehWGcl(i1xi4HajUMuITxmilGqAik6edyBnAhnRkUov0HajUMuITxS3L06AKquu8NhJfoxiq9Jg6j2vI5KctUIPbfMhB2vIYgoP4BHHajUMuf0xyYvmnOW8yPQ5)bCUqfM12LMQrcrrXx2GNcZcobbNSW4uX2LWjX10H9PQlCA4eBRWoYyAGy7ftr4SiihKbOQ8P8cG()ajVCaVyxjgpITxS3L06AKquu8NhJfoxiq9Jg6j2vCe76ITxSiHOO4eJhvJUQgsmhtmi5Ld4fZhXC(cJI(fCCJPbfgUQRyrl21flsikkEXUb0I5cN(wXUqKRySUI5Ndqj2Mt5fa9Vy4BfBTDPhakXyWsvZ)d4CHoLOSHZx8TWqGextQc6lm5kMguyESu18)aoxOcJI(fCCJPbfg)SHI5cNgoXwXGDKX0aheJ9jXyWsvZ)d4CHeR3rqXyIg6jg)jWeBZ59ILOYb8HySUIfTyBsSiHOO4fRHIniI5NBUyZlgKfagakXAeeXUPbILGTILEnlieRrelsikk(Blml4eeCYcZUeojUMoSpvDHtdNyBf2rgtdeBVy3iMIWzrqoidqv5t5fa9)bsE5aEXUsmEe7(DXIutG4WNs3g4LFqWdbsCnPeBVyVlP11iHOO4ppglCUqG6hn0tSR4i2Me72su2GRx8TWqGextQc6lml4eeCYcZ7sADnsikkEX8HJyxxm)f7gXWzrqobgvHDee4W6k297IbzbesdrrN8sMW5RFZQRiWeLhbIdbsCnPe7wX2l2nIHZIGC(TE4T(RnsvrzGvt2OxWjoSUID)UyovmCweKJlK8i1ezmn4W6k297I9UKwxJeIIIxmF4iMte72ctUIPbfMhJfoxiq9Jg6vIYgCnfFlmeiX1KQG(ctUIPbfMhlvn)pGZfQWOOFbh3yAqHHblvn)pGZfsSOfdsiq6XeZphGsSnNYla6FXsGsSOfJaplKeJpj2kbITsiCRy9ockwkgcRwlMFU5InGOflWiXaKJcXyAUl2GiMB))GRPtHzbNGGtwyueolcYbzaQkFkVaO)pqYlhWl2vCeJhXUFxSv3AvZhC(TE4T(RnsvrzGDGKxoGxSReJhUgX2lMIWzrqoidqv5t5fa9)bsE5aEXUsSv3AvZhC(TE4T(RnsvrzGDGKxoGVeLn4Tl(wyiqIRjvb9fMfCccozHbNfb54sqKgMbPQ7Ob8NpY1fX8HJyorS9ITAGIDIJlbrAygKQUJgWFGj4Iy(WrmEUEHjxX0GcdkD3E46urLOSbp8Q4BHjxX0GcZJLQM)hW5cvyiqIRjvb9LOSbp8u8TWqGextQc6lml4eeCYcJtflsikkoZxX7)fBVyR2dVRU9aI)OiKznHy(WrmEeBVy4SiiNhRJ6aQbgvvj8YH1vS9IracIA7jgpQgDDt8smFed1sD8shvyYvmnOWSWO0T(yDuIsuyuesYQJIVLn4P4BHjxX0GcZLzDPWqGextQc6lrzd0v8TWqGextQc6lmTBH5POWKRyAqHzxcNextfMDPMLkm4SiiNxplQMavvnl6W6k297I9UKwxJeIII)8ySW5cbQF0qpX8HJyoFHrr)coUX0Gcdx9jLyrlMIcc6nasm(yuGrqXwDRvnFWlg)CcXqAOymaUlgE(KsSgiwKquu8NcZUewbPhvyEGQUAGAIPbLOSX1l(wyiqIRjvb9fM2TW8uuyYvmnOWSlHtIRPcZUuZsfgx40Wj2wHDKX0aX2l27sADnsikk(ZJXcNleO(rd9eZhoIHUcJI(fCCJPbfgUca9wXwyjafjgSJmMgi2GigFsmSChjMlCA4eBRWoYyAGypfILaLyES6yC1KyrcrrXlgR7PWSlHvq6rfg2NQUWPHtSTc7iJPbLOSXMk(wyiqIRjvb9fM2TW8uuyYvmnOWSlHtIRPcZUuZsfg05eX8xSi1eio7gun8qGextkXCUIHoEjM)IfPMaXXl)GG1gP(yPQ5)hcK4AsjMZvm0XlX8xSi1eiopwQA(vKEX(hcK4AsjMZvm05eX8xSi1eioPoxWj2EiqIRjLyoxXqhVeZFXqNteZ5k2nI9UKwxJeIII)8ySW5cbQF0qpX8HJyBsSBlmk6xWXnMguy4QpPelAXueYaiX4JraXIwm2Ne7dk1bMy(L7VynumC2rRi4xy2LWki9OcZhuQdSAGbPhR1Qsu2WjfFlmeiX1KQG(cJI(fCCJPbfg)IrRlI5xU)ILHyid8JctUIPbfMvQ11CftdQ65JcJE(OcspQWSuFjkB48fFlmeiX1KQG(cJI(fCCJPbfMnJfigcRwVvSN)elm6flAXcmsmMGsDGrkX2SoYyAGy3GVvmvpauI9TdInHyinCrVyUDRhakXgeXaDGnauInVy5UC0jUMU9uyYvmnOWazb1CftdQ65JcZcobbNSW8bL6aJuNuRlm65Jki9OcZhuQdmsvIYgC9IVfgcK4AsvqFHjxX0GcZRNfvtGQQMfvyu0VGJBmnOWWBCD1BfJrplsSeOeJ7ZIeldXqN)I5xhxmflCaOelWiXqg4hIXdVe7PvduVdILibbflWYqSn5Vy(1XfBqeBcXih5oq6fJ)eydqSaJedqokeJR0VCxSgk28Ib6qmw3cZcobbNSW8UKwxJeIII)8ySW5cbQF0qpXUsmNxS9IHmOWIkK8Yb8I5JyoVy7fdNfb586zr1eOQQzrhi5Ld4f7kXqTuhV0rITxSv7H3v3EaXlMpCeBtI5yIDJyX4rIDLy8WlXUvmNRyOReLn4Ak(wyiqIRjvb9fgf9l44gtdkmooCA4eBfBZ6iJPbCTi21qb3EXqn7iXsXwW0vSeVzdXiabrTvmKgkwGrI9bL6atm)Y9xSBWzhTIGI9XO1IbP3LwHytC7rmUwzDDqSjeBLaXWjXcSme7hpxnDkm5kMguywPwxZvmnOQNpkml4eeCYcZUeojUMoSpvDHtdNyBf2rgtdkm65Jki9OcZhuQdS6s9LOSbVDX3cdbsCnPkOVWOOFbh3yAqHXVn4hfbfJ9hakXsXyck1bMy(L7IXhJaIbPCHnauIfyKyeGGO2kwGbPhR1QctUIPbfMvQ11CftdQ65JcZcobbNSWqacIA7rriZAcXUIJy7s4K4A68bL6aRgyq6XATQWONpQG0JkmFqPoWQl1xIYg8WRIVfgcK4AsvqFHzbNGGtwyUrmcbHwXSJQR2dVRU9aIxmF4i2YT6LoQ(Ueqj2TID)Uy3i2Q9W7QBpG4pkczwti2vCeJhXUFxmKbfwuHKxoGxSR4igpITxmcbHwXSJQR2dVRU9aIxmF4i21f7(DXWzrqo)wp8w)1gPQOmWQjB0l4ehwxX2lgHGqRy2r1v7H3v3EaXlMpCeBtIDRy3Vl2nI9UKwxJeIII)8ySW5cbQF0qpX8HJyBsS9Irii0kMDuD1E4D1Thq8I5dhX2Ky3wyYvmnOWSsTUMRyAqvpFuy0Zhvq6rfgKbmpwjkBWdpfFlmeiX1KQG(cJI(fCCJPbfgU6tILIHZoAfbfJpgbeds5cBaOelWiXiabrTvSadspwRvfMCftdkmRuRR5kMgu1ZhfMfCccozHHaee12JIqM1eIDfhX2LWjX105dk1bwnWG0J1AvHrpFubPhvyWzhTQeLn4bDfFlmeiX1KQG(ctUIPbfMeUsavJgcjquyu0VGJBmnOWCnnF6dXCHtdNyRydqSuRfRrelWiX4no(1igoTs2NeBcXwj7tVyPyCL(L7fMfCccozHHaee12JIqM1eI5dhX4XjI5VyeGGO2EGekcuIYg8C9IVfMCftdkmjCLaQ6YQFQWqGextQc6lrzdE2uX3ctUIPbfg9Gcl(kVfwfkpcefgcK4AsvqFjkBWJtk(wyYvmnOWGNOQnsnGZ6YxyiqIRjvb9LOefgxiTAp8mk(w2GNIVfMCftdkmPRREB1TNVbfgcK4AsvqFjkBGUIVfMCftdkm4DeAsvr05wsXFaOQr7ObuyiqIRjvb9LOSX1l(wyiqIRjvb9fMfCccozH5Bwn(auhx2py1uLGSUX0GdbsCnPe7(DX(MvJpa1zxRZy0u9B9ocehcK4AsvyYvmnOWGOPhBbtKOeLn2uX3ctUIPbfMpOuhyfgcK4AsvqFjkB4KIVfgcK4AsvqFHjxX0GcJxcVqQksdRkkdScJlKwThEg1Nwnq9fgECsjkB48fFlmeiX1KQG(ctUIPbfMxplQMavvnlQWSGtqWjlmqcbspwIRPcJlKwThEg1Nwnq9fgEkrzdUEX3cdbsCnPkOVWSGtqWjlmqwaH0qu0XlHxQnsnWOQx(bbR5)5)d4qGextQctUIPbfMhlvn)kUov0xIsuyqgW8yfFlBWtX3cdbsCnPkOVW0UfMNIctUIPbfMDjCsCnvy2LAwQWePMaXXfsEKAImMgCiqIRjLy7f7DjTUgjeff)5XyHZfcu)OHEIDLy3iMteZXeB17iqcIdGwWw3qLy3k2EXCQyREhbsqCUSfojOWOOFbh3yAqHzZXgnjg7pauI54qYJutKX0ahel31JsSv(XaqjgJEwKyjqjg3NfjgFmcigdwQA(IX9eSiXMxSVBGyrlgojg7tkheJC0ICdXqAOyCT3cNeuy2LWki9OcJlK8iv9bQ6QbQjMguIYgOR4BHHajUMuf0xywWji4KfgNk2UeojUMoUqYJu1hOQRgOMyAGy7f7DjTUgjeff)5XyHZfcu)OHEIDLyoVy7fZPIHZIGCESu18RQeSOdRRy7fdNfb586zr1eOQQzrhi5Ld4f7kXqguyrfsE5aEX2lgKqG0JL4AQWKRyAqH51ZIQjqvvZIkrzJRx8TWqGextQc6lml4eeCYcZUeojUMoUqYJu1hOQRgOMyAGy7fB1Tw18bNhlvn)Qkbl6SWsik6RiWCftdsTyxjgphUUteBVy4SiiNxplQMavvnl6ajVCaVyxj2QBTQ5do)wp8w)1gPQOmWoqYlhWl2EXUrSv3AvZhCESu18RQeSOdKs1wX2lgolcY536H36V2ivfLb2bsE5aEXCmXWzrqopwQA(vvcw0bsE5aEXUsmEoOtSBlm5kMguyE9SOAcuv1SOsu2ytfFlmeiX1KQG(ct7wyEkkm5kMguy2LWjX1uHzxQzPcJx(bbR5)5)dOcjVCaVy(igVe7(DXCQyrQjqCadkS4JuFHGhcK4Asj2EXIutG4Os4L6JLQM)HajUMuITxmCweKZJLQMFvLGfDyDf7(DXExsRRrcrrXFEmw4CHa1pAONy(WrSBeZjI5yIbzbesdrrhKbK6j2EiqIRjLy3wyu0VGJBmnOWWBL0UeumENeojUMedPHITzSUblKoIXCzCftXchakX495heumEZ)5)dqSgkMIfoauIX9eSiX4pbMyCpHxelbkXaTyBmOWIps9fcEkm7syfKEuH5VmUviRBWcPsu2WjfFlmeiX1KQG(ctUIPbfgiRBWcPcJI(fCCJPbfgU2e5kgRRyBgRBWcjXgeXMqS5flXB2qSOfdYceRzJtHzbNGGtwyUrmNk2UeojUMo)LXTczDdwij297ITlHtIRPd7tvx40Wj2wHDKX0aXUvS9IfjeffNy8OA0v1qI5yIbjVCaVy(iMZl2EXGecKESextLOSHZx8TWKRyAqH5PfKIAqlmWW7YsfgcK4AsvqFjkBW1l(wyiqIRjvb9fMCftdkmqw3GfsfM12LMQrcrrXx2GNcZcobbNSW4uX2LWjX105VmUviRBWcjX2lMtfBxcNexth2NQUWPHtSTc7iJPbITxS3L06AKquu8NhJfoxiq9Jg6jMpCedDITxSiHOO4eJhvJUQgsmF4i2nI5eX8xSBedDI5CfB1E4D1Thq8IDRy3k2EXGecKESextfgf9l44gtdkm8EwDmQoIbGsSiHOO4flWYqm(JwlME2rIH0qXcmsmflmJPbI1iITzSUblKCqmiHaPhtmflCaOeZnbkYBwNsu2GRP4BHHajUMuf0xyYvmnOWazDdwivyu0VGJBmnOWSzecKEmX2mw3GfsIrjuVvSbrSjeJ)O1IroYDGKykw4aqjgZwp8w)hX4ElwGLHyqcbspMydIymn3fdffVyqkvBfBaIfyKyaYrHyo5pfMfCccozHXPITlHtIRPZFzCRqw3GfsITxmi5Ld4f7kXwDRvnFW536H36V2ivfLb2bsE5aEX8xmE4Ly7fB1Tw18bNFRhER)AJuvugyhi5Ld4f7koI5eX2lwKquuCIXJQrxvdjMJjgK8Yb8I5JyRU1QMp48B9WB9xBKQIYa7ajVCaVy(lMtkrzdE7IVfgcK4AsvqFHzbNGGtwyCQy7s4K4A6W(u1fonCITvyhzmnqS9I9UKwxJeIIIxmF4i21lm5kMguyW156s1T5RiyjkBWdVk(wyYvmnOWq7MFrWmOcdbsCnPkOVeLOWSuFX3Yg8u8TWqGextQc6lml4eeCYcJtfdNfb58yPQ5xvjyrhwxX2lgolcY5XyHZfcuJgcsvFyDfBVy4SiiNhJfoxiqnAiiv9bsE5aEXUIJyx)4Kcd7t1gbPIAPkBWtHjxX0GcZJLQMFvLGfvyu0VGJBmnOWWvFsmUNGfjwJG4yOwkXWjKgsIfyKyid8dXEmw4CHa1pAONyiW2tmFBiivTyR2JEXgWPeLnqxX3cdbsCnPkOVWSGtqWjlm4SiiNhJfoxiqnAiiv9H1vS9IHZIGCEmw4CHa1OHGu1hi5Ld4f7koID9JtkmSpvBeKkQLQSbpfMCftdkm)wp8w)1gPQOmWkmk6xWXnMguyUHRc00)ILAiLQTIX6kgoTs2NeJpjw09fXyWsvZxm)SxS)TIX(KymB9WB9lwJG4yOwkXWjKgsIfyKyid8dXyWyHZfcigt0qpXqGTNy(2qqQAXwTh9InGtjkBC9IVfgcK4AsvqFHzbNGGtwy2LWjX105bQ6QbQjMgi2EXCQyFqPoWi1XlbHMeBVy3iMtfdYciKgIIonoPgcSOdbsCnPe7(DXwDRvnFW536H36V2ivfLb2H1vS9ITAp8U62diEX8HJyorSBlm5kMguyq0jksRZyAqjkBSPIVfgcK4AsvqFHzbNGGtwyUrmilGqAik64LWl1gPgyu1l)GG18)8)bCiqIRjLy7fB1E4D1Thq8hfHmRje7koIXJyoMyrQjqCue5sW6hWmiuK3HajUMuID)UyqwaH0qu0rrzGP3wFSu18)dbsCnPeBVyR2dVRU9aIxSReJhXUvS9IHZIGC(TE4T(RnsvrzGDyDfBVy4SiiNhlvn)Qkbl6W6k2EX8Ypiyn)p)Favi5Ld4fJJy8sS9IHZIGCuugy6T1hlvn))OA(GctUIPbfMDjyESsu2WjfFlmeiX1KQG(cJI(fCCJPbfghVBTyinumFBiivTyUqYXyAUlg)jWeJbJ7IbPuTvm(yeqmqhIbzbGbGsmg)8uyqAyfqokkBWtHzbNGGtwyIutG48ySW5cbQrdbPQpeiX1KsS9I5uXIutG48yPQ5xr6f7FiqIRjvHjxX0GcJB36kK(MfUOsu2W5l(wyiqIRjvb9fMCftdkmpglCUqGA0qqQ6cJI(fCCJPbfgU6tI5BdbPQfZfsIX0Cxm(yeqm(Kyy5osSaJeJaee1wX4Jrbgbfdb2EI52TEaOeJ)eynBigJFkwdfJ3c7hIHIaem16TNcZcobbNSWqacIARy(WrmNNxITxSDjCsCnDEGQUAGAIPbITxSv3AvZhC(TE4T(RnsvrzGDyDfBVyRU1QMp48yPQ5xvjyrNfwcrrVy(WrmEeBVy3iMtfdYciKgIIonoPgcSOdbsCnPe7(DXueolcYbrNOiToJPbhwxXUvS9ITAp8U62diEXUIJyOReLn46fFlmeiX1KQG(ctUIPbfMNGWmivfVbu9DNluHzbNGGtwy2LWjX105bQ6QbQjMgi2EXCQyQoopbHzqQkEdO67oxOQQJtmRldaLy7flsikkoX4r1ORQHeZhoIHoEe7(DXqguyrfsE5aEXUIJyorS9I9UKwxJeIII)8ySW5cbQF0qpXUsSRxywBxAQgjeffFzdEkrzdUMIVfgcK4AsvqFHzbNGGtwy2LWjX105bQ6QbQjMgi2EXwThExD7be)rriZAcX8HJy8uyYvmnOW8K7pFjkBWBx8TWqGextQc6lm5kMguy(TE4T(RnsvrzGvyu0VGJBmnOWWvFsmMTE4T(fRbIT6wRA(aXUjrcckgYa)qmga3VvmwGM(xm(KyjKedvpauIfTyUTRy(2qqQAXsGsmvlgOdXWYDKymyPQ5lMF2l2)uywWji4KfMDjCsCnDEGQUAGAIPbITxSBelsnbIdb2r62DaOQpwQA()HajUMuID)UyRU1QMp48yPQ5xvjyrNfwcrrVy(WrmEe7wX2l2nI5uXIutG48ySW5cbQrdbPQpeiX1KsS73flsnbIZJLQMFfPxS)HajUMuID)UyRU1QMp48ySW5cbQrdbPQpqYlhWlMpIHoXUvS9IDJyovmilGqAik604KAiWIoeiX1KsS73fB1Tw18bheDII06mMgCGKxoGxmFeJhEj2TLOSbp8Q4BHHajUMuf0xyYvmnOW4LWlKQI0WQIYaRWOhavxQcdphNuywBxAQgjeffFzdEkml4eeCYcdmhvL2rG4Kk1FyDfBVy3iwKquuCIXJQrxvdj2vITAp8U62di(JIqM1eID)UyovSpOuhyK6KATy7fB1E4D1Thq8hfHmRjeZhoITCREPJQVlbuIDBHrr)coUX0GcJZbrSuPEXsijgRRdI9GXLelWiXAajg)jWet38PpeZxF5(rmU6tIXhJaIP2oauIHKFqqXcSeiMFDCXueYSMqSgkgOdX(GsDGrkX4pbwZgILGTI5xh)uIYg8WtX3cdbsCnPkOVWKRyAqHXlHxivfPHvfLbwHrr)coUX0GcJZbrmqlwQuVy8hTwm1qIXFcSbiwGrIbihfIDDE9oig7tIX7r4Uynqm8(FX4pbwZgILGTI5xh)uywWji4KfgyoQkTJaXjvQ)maX8rSRZlXCmXG5OQ0oceNuP(JIfMX0aX2l2Q9W7QBpG4pkczwtiMpCeB5w9shvFxcOkrzdEqxX3cdbsCnPkOVWSGtqWjlm7s4K4A68avD1a1etdeBVyR2dVRU9aI)OiKznHy(Wrm0j2EXUrSv3AvZhC(TE4T(RnsvrzGDGKxoGxSReJhXUFxmCweKZV1dV1FTrQkkdSdRRy3VlgYGclQqYlhWl2vCedD8sSBlm5kMguyESu18R46urFjkBWZ1l(wyiqIRjvb9fMfCccozHzxcNextNhOQRgOMyAGy7fB1E4D1Thq8hfHmRjeZhoIHoX2l2nITlHtIRPd7tvx40Wj2wHDKX0aXUFxS3L06AKquu8NhJfoxiq9Jg6j2vCeBtID)UyqwaH0qu0bsFZcudavDPt4eBpeiX1KsSBlm5kMguyOfwpauvi5chVeOkrzdE2uX3cdbsCnPkOVWKRyAqH5XyHZfcuJgcsvxyu0VGJBmnOWS5tGjgJF6GydIyGoel1qkvBft1aYbXyFsmFBiivTy8NatmMM7IX6Ekml4eeCYctKAceNhlvn)ksVy)dbsCnPeBVy7s4K4A68avD1a1etdeBVy4SiiNFRhER)AJuvugyhwxX2l2Q9W7QBpG4f7koIHUsu2GhNu8TWqGextQc6lml4eeCYcJtfdNfb58yPQ5xvjyrhwxX2lgYGclQqYlhWl2vCeJRrm)flsnbIZZIheeHffDiqIRjvHjxX0GcZJLQMFvLGfvIYg848fFlmeiX1KQG(cZcobbNSWCJyFZQXhG64Y(bRMQeK1nMgCiqIRjLy3Vl23SA8bOo7ADgJMQFR3rG4qGextkXUvS9IracIA7rriZAcX8HJyxNxITxmNk2huQdmsDsTwS9IHZIGC(TE4T(RnsvrzGDunFqHjxX0GcdIMESfmrIsu2GhUEX3cdbsCnPkOVWSGtqWjlm4SiihCD3kn7hhiLRqS73fdzqHfvi5Ld4f7kXUoVe7(DXWzrqo)wp8w)1gPQOmWoSUITxSBedNfb58yPQ5xX1PI(dRRy3Vl2QBTQ5dopwQA(vCDQO)ajVCaVyxXrmE4Ly3wyYvmnOW42X0Gsu2GhUMIVfgcK4AsvqFHzbNGGtwyWzrqo)wp8w)1gPQOmWoSUfMCftdkm46Uvvew42su2GhE7IVfgcK4AsvqFHzbNGGtwyWzrqo)wp8w)1gPQOmWoSUfMCftdkm4e8j4LbGQeLnqhVk(wyiqIRjvb9fMfCccozHbNfb58B9WB9xBKQIYa7W6wyYvmnOWGmqcx3TQeLnqhpfFlmeiX1KQG(cZcobbNSWGZIGC(TE4T(RnsvrzGDyDlm5kMguysWI(aM66k16su2aDOR4BHHajUMuf0xyYvmnOWW(uDcY7lmk6xWXnMguy4oHKS6qmKuRXZ1fXqAOySFIRjXMG8(RvmU6tIXFcmXy26H36xSgrmUtzGDkml4eeCYcdolcY536H36V2ivfLb2H1vS73fdzqHfvi5Ld4f7kXqhVkrjkmFqPoWQl1x8TSbpfFlmeiX1KQG(ct7wyEkkm5kMguy2LWjX1uHzxQzPcZQBTQ5dopwQA(vvcw0zHLqu0xrG5kMgKAX8HJy8C46oPWOOFbh3yAqHH3kPDjOy8ojCsCnvy2LWki9OcZJPQbgKESwRkrzd0v8TWqGextQc6lm5kMguy2LG5Xkmk6xWXnMguy4DsW8yIniIXNelHKyR01DaOeRbIX9eSiXwyjef9hX4kMq9wXWjKgsIHmWpetLGfj2GigFsmSChjgOfBJbfw8rQVqqXWzdX4EcVigdwQA(InaXAOIGIfTyOOqSnJ1nyHKySUIDdOfJ3NFqqX4n)N)pGBpfMfCccozH5gXCQy7s4K4A68yQAGbPhR1kXUFxmNkwKAcehWGcl(i1xi4HajUMuITxSi1eioQeEP(yPQ5FiqIRjLy3k2EXwThExD7be)rriZAcX8rmEeBVyovmilGqAik64LWl1gPgyu1l)GG18)8)bCiqIRjvjkBC9IVfgcK4AsvqFHrr)coUX0GcJJ3TwmKgkgdwQA(EKwjM)IXGLQM)hW5cjglqt)lgFsSesIL4nBiw0ITsxXAGyCpblsSfwcrr)rmUca9wX4JraX8ZbOeBZP8cG(xS5flXB2qSOfdYceRzJtHbPHva5OOSbpfMfCccozHbMl6aguyrL0ifgYrbmRPxZcIcZM4vHjxX0GcJB36kK(MfUOsu2ytfFlmeiX1KQG(cZcobbNSWqacIARy(WrSnXlX2lgbiiQThfHmRjeZhoIXdVeBVyovSDjCsCnDEmvnWG0J1ALy7fB1E4D1Thq8hfHmRjeZhX4rS9IPiCweKdYauv(uEbq)FGKxoGxSReJNctUIPbfMhlvnFpsRkrzdNu8TWqGextQc6lmTBH5POWKRyAqHzxcNextfMDPMLkmR2dVRU9aI)OiKznHy(Wrm0jM)IHZIGCESu18R46ur)H1TWOOFbh3yAqHXVoUybgKESwREXqAOyeii4aqjgdwQA(IX9eSOcZUewbPhvyEmvD1E4D1Thq8LOSHZx8TWqGextQc6lmTBH5POWKRyAqHzxcNextfMDPMLkmR2dVRU9aI)OiKznHy(WrSRxywWji4KfMvVJajiox2cNeuy2LWki9OcZJPQR2dVRU9aIVeLn46fFlmeiX1KQG(ct7wyEkkm5kMguy2LWjX1uHzxQzPcZQ9W7QBpG4pkczwti2vCeJNcZcobbNSWSlHtIRPd7tvx40Wj2wHDKX0aX2l27sADnsikk(ZJXcNleO(rd9eZhoITPcZUewbPhvyEmvD1E4D1Thq8LOSbxtX3cdbsCnPkOVWKRyAqH5XsvZVQsWIkmk6xWXnMguy4EcwKykw4aqjgZwp8w)I1qXs8EhjwGbPhR1QtHzbNGGtwy2LWjX105Xu1v7H3v3EaXl2EXUrSDjCsCnDEmvnWG0J1ALy3VlgolcY536H36V2ivfLb2bsE5aEX8HJy8CqNy3Vl27sADnsikk(ZJXcNleO(rd9eZhoITjX2l2QBTQ5do)wp8w)1gPQOmWoqYlhWlMpIXdVe72su2G3U4BHHajUMuf0xyYvmnOW8yPQ5xvjyrfgf9l44gtdkmONfcedsE5agakX4Ecw0lgoH0qsSaJedzqHfIra1l2GigtZDX43aUfIHtIbPuTvSbiwmE0PWSGtqWjlm7s4K4A68yQ6Q9W7QBpG4fBVyidkSOcjVCaVyxj2QBTQ5do)wp8w)1gPQOmWoqYlhWxIsuyWzhTQ4BzdEk(wyiqIRjvb9fMfCccozHXPIfPMaXbmOWIps9fcEiqIRjLy7fdYciKgIIoXa2wJ2rZQIRtfDiqIRjLy7f7DjTUgjeff)5XyHZfcu)OHEIDLyoPWKRyAqH5XMDLOSb6k(wyiqIRjvb9fMfCccozH5DjTUgjeffVy(Wrm0j2EXUrmNk2Q3rGeehaTGTUHkXUFxSv3AvZhCEccZGuv8gq13DUqhV0r1fwcrrVyoMylSeII(kcmxX0GulMpCeJxh05eXUFxS3L06AKquu8NhJfoxiq9Jg6jMpITjXUTWKRyAqH5XyHZfcu)OHELOSX1l(wyiqIRjvb9fMfCccozHz1Tw18bNNGWmivfVbu9DNl0XlDuDHLqu0lMJj2clHOOVIaZvmni1IDfhX41bDorS73f7Bwn(auhnLQk(2k5O0ZvthcK4Asj2EXCQy4SiihnLQk(2k5O0Zvthw3ctUIPbfMNGWmivfVbu9DNlujkBSPIVfMCftdkmO0D7HRtfvyiqIRjvb9LOSHtk(wyYvmnOWGNRlFK4fgcK4AsvqFjkrjkm7i4pnOSb64f64Hxop64Tlm8tiyaO(cZMZB2SnCoBWvETIjMVyKyJNBddXqAOyC7dk1bgP4MyqI3LDGKsSV9iXs2O9YGuITWsak6pcAxZaiX201kMFBWocgKsmUbzbesdrrh)GBIfTyCdYciKgIIo(XHajUMuCtSB4Xr3Ee0UMbqIX1VwX8Bd2rWGuIXnilGqAik64hCtSOfJBqwaH0qu0XpoeiX1KIBIDdpo62JGMG2MZB2SnCoBWvETIjMVyKyJNBddXqAOyCZfsR2dpdUjgK4DzhiPe7BpsSKnAVmiLylSeGI(JG21masSRFTI53gSJGbPeJBFZQXhG64hCtSOfJBFZQXhG64hhcK4AsXnXUHhhD7rq7Agaj21VwX8Bd2rWGuIXTVz14dqD8dUjw0IXTVz14dqD8JdbsCnP4MyzigxrUcxJy3WJJU9iODndGeJRFTI53gSJGbPeJBqwaH0qu0Xp4Myrlg3GSacPHOOJFCiqIRjf3eldX4kYv4Ae7gEC0ThbnbTnN3SzB4C2GR8AftmFXiXgp3ggIH0qX4gYaMhJBIbjEx2bskX(2JelzJ2ldsj2clbOO)iODndGeBtxRy(Tb7iyqkX4gKfqinefD8dUjw0IXnilGqAik64hhcK4AsXnXUHhhD7rqtqBZ5nB2goNn4kVwXeZxmsSXZTHHyinumUTup3eds8USdKuI9ThjwYgTxgKsSfwcqr)rq7Agaj21VwX8Bd2rWGuIXnilGqAik64hCtSOfJBqwaH0qu0XpoeiX1KIBIDdpo62JG21masSnDTI53gSJGbPeJBqwaH0qu0Xp4Myrlg3GSacPHOOJFCiqIRjf3e7g05OBpcAxZaiXC(Rvm)2GDemiLyCdYciKgIIo(b3elAX4gKfqinefD8JdbsCnP4My3WJJU9iODndGeJ3(AfZVnyhbdsjg3GSacPHOOJFWnXIwmUbzbesdrrh)4qGextkUj2n84OBpcAxZaiX456xRy(Tb7iyqkX4gKfqinefD8dUjw0IXnilGqAik64hhcK4AsXnXUHhhD7rq7Agajgpo)1kMFBWocgKsmU9nRgFaQJFWnXIwmU9nRgFaQJFCiqIRjf3e7g05OBpcAcABoVzZ2W5Sbx51kMy(IrInEUnmedPHIXTpOuhy1L65MyqI3LDGKsSV9iXs2O9YGuITWsak6pcAxZaiXq31kMFBWocgKsmUbzbesdrrh)GBIfTyCdYciKgIIo(XHajUMuCtSmeJRixHRrSB4Xr3Ee0e02CEZMTHZzdUYRvmX8fJeB8CByigsdfJB4SJwXnXGeVl7ajLyF7rILSr7LbPeBHLau0Fe0UMbqIXZ1kMFBWocgKsmUbzbesdrrh)GBIfTyCdYciKgIIo(XHajUMuCtSB4Xr3Ee0e0CoEUnmiLyCDXYvmnqm98XFe0kmUWgz0uHXzotmgw8qtXwX2SgfljO5mNjgAS6TIDDhedD8cD8iOjO5mNjgVV3rITlHtIRPd7tvx40Wj2wHDKX0aXyDf7BXMqS5f7PqmCcPHKy8jXyFsSjocAoZzI532dFaKyES6yC1KyRuRR5kMgu1ZhIrGao0lw0Ibjf7IeZTdcetQfds8B4LJGMGMZCMyooKCm)2E4ziOLRyAWFCH0Q9WZWFoCjDD1BRU98nqqlxX0G)4cPv7HNH)C4cEhHMuveDULu8haQA0oAacA5kMg8hxiTAp8m8Ndxq00JTGjs4WGW5Bwn(auhx2py1uLGSUX0G73)MvJpa1zxRZy0u9B9ocecA5kMg8hxiTAp8m8Ndx(GsDGjOLRyAWFCH0Q9WZWFoCXlHxivfPHvfLbMdUqA1E4zuFA1a1ZHhNiOLRyAWFCH0Q9WZWFoC51ZIQjqvvZICWfsR2dpJ6tRgOEo84WGWbsiq6XsCnjOLRyAWFCH0Q9WZWFoC5XsvZVIRtf9omiCGSacPHOOJxcVuBKAGrvV8dcwZ)Z)hGGMGMZCMy8(CaITzDKX0abTCftdEoxM1fbnNjgx9jLyrlMIcc6nasm(yuGrqXwDRvnFWlg)CcXqAOymaUlgE(KsSgiwKquu8hbTCftdE)5WLDjCsCn5ai9iopqvxnqnX0ah2LAwIdolcY51ZIQjqvvZIoSU3V)UKwxJeIII)8ySW5cbQF0qpF448cAotmUca9wXwyjafjgSJmMgi2GigFsmSChjMlCA4eBRWoYyAGypfILaLyES6yC1KyrcrrXlgR7rqlxX0G3FoCzxcNextoaspId7tvx40Wj2wHDKX0ah2LAwIJlCA4eBRWoYyAW(3L06AKquu8NhJfoxiq9Jg65dh0jO5mX4QpPelAXueYaiX4JraXIwm2Ne7dk1bMy(L7VynumC2rRi4lOLRyAW7phUSlHtIRjhaPhX5dk1bwnWG0J1ALd7snlXbDoX)i1eio7gun8qGextkNl64L)rQjqC8YpiyTrQpwQA()HajUMuox0Xl)JutG48yPQ5xr6f7FiqIRjLZfDoX)i1eioPoxWj2EiqIRjLZfD8YF05eN7nVlP11iHOO4ppglCUqG6hn0ZhoB6wbnNjMFXO1fX8l3FXYqmKb(HGwUIPbV)C4Yk16AUIPbv98HdG0J4SuVGMZeBZybIHWQ1Bf75pXcJEXIwSaJeJjOuhyKsSnRJmMgi2n4Bft1daLyF7Gytigsdx0lMB36bGsSbrmqhydaLyZlwUlhDIRPBpcA5kMg8(ZHlqwqnxX0GQE(Wbq6rC(GsDGrkhgeoFqPoWi1j1AbnNjgVX1vVvmg9SiXsGsmUplsSmedD(lMFDCXuSWbGsSaJedzGFigp8sSNwnq9oiwIeeuSaldX2K)I5xhxSbrSjeJCK7aPxm(tGnaXcmsma5OqmUs)YDXAOyZlgOdXyDf0Yvmn49NdxE9SOAcuv1SihgeoVlP11iHOO4ppglCUqG6hn07kNFpYGclQqYlhW7JZVhNfb586zr1eOQQzrhi5Ld4Vc1sD8shTF1E4D1Thq8(Wzto2nX4rxXdVU15IobnNjMJdNgoXwX2SoYyAaxlIDnuWTxmuZosSuSfmDflXB2qmcqquBfdPHIfyKyFqPoWeZVC)f7gC2rRiOyFmATyq6DPvi2e3EeJRvwxheBcXwjqmCsSaldX(XZvthbTCftdE)5WLvQ11CftdQ65dhaPhX5dk1bwDPEhgeo7s4K4A6W(u1fonCITvyhzmnqqZzI53g8JIGIX(daLyPymbL6atm)YDX4JraXGuUWgakXcmsmcqquBflWG0J1ALGwUIPbV)C4Yk16AUIPbv98HdG0J48bL6aRUuVddchcqquBpkczwtCfNDjCsCnD(GsDGvdmi9yTwjOLRyAW7phUSsTUMRyAqvpF4ai9ioidyEmhgeo3qii0kMDuD1E4D1Thq8(Wz5w9shvFxcOU9(9BwThExD7be)rriZAIR4WZ97idkSOcjVCa)vC4zpHGqRy2r1v7H3v3EaX7dNRF)oolcY536H36V2ivfLbwnzJEbN4W6UNqqOvm7O6Q9W7QBpG49HZMU9(9BExsRRrcrrXFEmw4CHa1pAONpC20EcbHwXSJQR2dVRU9aI3hoB6wbnNjgx9jXsXWzhTIGIXhJaIbPCHnauIfyKyeGGO2kwGbPhR1kbTCftdE)5WLvQ11CftdQ65dhaPhXbND0khgeoeGGO2EueYSM4ko7s4K4A68bL6aRgyq6XATsqZzIDnnF6dXCHtdNyRydqSuRfRrelWiX4no(1igoTs2NeBcXwj7tVyPyCL(L7cA5kMg8(ZHljCLaQgnesGWHbHdbiiQThfHmRj8HdpoXFcqquBpqcfbe0Yvmn49Ndxs4kbu1Lv)KGwUIPbV)C4IEqHfFL3cRcLhbcbTCftdE)5Wf8evTrQbCwxEbnbnN5mXqp7Ove8f0Yvmn4p4SJwX5XMDomiCCAKAcehWGcl(i1xi4HajUMu7HSacPHOOtmGT1OD0SQ46ur7FxsRRrcrrXFEmw4CHa1pAO3vorqlxX0G)GZoAL)C4YJXcNleO(rd9Cyq48UKwxJeIII3hoOB)noD17iqcIdGwWw3q197RU1QMp48eeMbPQ4nGQV7CHoEPJQlSeIIEhBHLqu0xrG5kMgKAF4WRd6CY97VlP11iHOO4ppglCUqG6hn0ZNnDRGwUIPb)bND0k)5WLNGWmivfVbu9DNlKddcNv3AvZhCEccZGuv8gq13DUqhV0r1fwcrrVJTWsik6RiWCftds9vC41bDo5(9Vz14dqD0uQQ4BRKJspxnDiqIRj1ENIZIGC0uQQ4BRKJspxnDyDf0Yvmn4p4SJw5phUGs3ThUovKGwUIPb)bND0k)5Wf8CD5JexqtqZzotm)2Tw18bVGMZeJR(KyCpblsSgbXXqTuIHtinKelWiXqg4hI9ySW5cbQF0qpXqGTNy(2qqQAXwTh9InGJGwUIPb)zPEopwQA(vvcwKdSpvBeKkQLIdpomiCCkolcY5XsvZVQsWIoSU7XzrqopglCUqGA0qqQ6dR7ECweKZJXcNleOgneKQ(ajVCa)vCU(XjcAotSB4Qan9VyPgsPARySUIHtRK9jX4tIfDFrmgSu18fZp7f7FRySpjgZwp8w)I1iiogQLsmCcPHKybgjgYa)qmgmw4CHaIXen0tmey7jMVneKQwSv7rVyd4iOLRyAWFwQ3FoC536H36V2ivfLbMdSpvBeKkQLIdpomiCWzrqopglCUqGA0qqQ6dR7ECweKZJXcNleOgneKQ(ajVCa)vCU(XjcA5kMg8NL69Ndxq0jksRZyAGddcNDjCsCnDEGQUAGAIPb7D6huQdmsD8sqOP934uilGqAik604KAiWIUFF1Tw18bNFRhER)AJuvugyhw39R2dVRU9aI3hoo5wbTCftd(Zs9(ZHl7sW8yomiCUbYciKgIIoEj8sTrQbgv9Ypiyn)p)Fa7xThExD7be)rriZAIR4WJJfPMaXrrKlbRFaZGqrEhcK4AsD)oKfqinefDuugy6T1hlvn)F)Q9W7QBpG4VINB3JZIGC(TE4T(RnsvrzGDyD3JZIGCESu18RQeSOdR7EV8dcwZ)Z)hqfsE5aEo8ApolcYrrzGP3wFSu18)JQ5de0CMyoE3AXqAOy(2qqQAXCHKJX0Cxm(tGjgdg3fdsPARy8XiGyGoedYcadaLym(5rqlxX0G)SuV)C4IB36kK(MfUihqAyfqok4WJddcNi1eiopglCUqGA0qqQ6dbsCnP270i1eiopwQA(vKEX(hcK4AsjO5mX4QpjMVneKQwmxijgtZDX4JraX4tIHL7iXcmsmcqquBfJpgfyeumey7jMB36bGsm(tG1SHym(PynumElSFigkcqWuR3Ee0Yvmn4pl17phU8ySW5cbQrdbPQDyq4qacIARpCCEETFxcNextNhOQRgOMyAW(v3AvZhC(TE4T(RnsvrzGDyD3V6wRA(GZJLQMFvLGfDwyjef9(WHN934uilGqAik604KAiWIUFxr4SiiheDII06mMgCyDVD)Q9W7QBpG4VId6e0Yvmn4pl17phU8eeMbPQ4nGQV7CHCyTDPPAKquu8C4XHbHZUeojUMopqvxnqnX0G9ov1X5jimdsvXBavF35cvvDCIzDzaO2hjeffNy8OA0v1q(WbD8C)oYGclQqYlhWFfhNS)DjTUgjeff)5XyHZfcu)OHExDDbTCftd(Zs9(ZHlp5(Z7WGWzxcNextNhOQRgOMyAW(v7H3v3EaXFueYSMWho8iO5mX4QpjgZwp8w)I1aXwDRvnFGy3KibbfdzGFigdG73kglqt)lgFsSesIHQhakXIwm32vmFBiivTyjqjMQfd0Hyy5osmgSu18fZp7f7Fe0Yvmn4pl17phU8B9WB9xBKQIYaZHbHZUeojUMopqvxnqnX0G93ePMaXHa7iD7oau1hlvn))qGextQ73xDRvnFW5XsvZVQsWIolSeIIEF4WZT7VXPrQjqCEmw4CHa1OHGu1hcK4AsD)EKAceNhlvn)ksVy)dbsCnPUFF1Tw18bNhJfoxiqnAiiv9bsE5aEFq3T7VXPqwaH0qu0PXj1qGfD)(QBTQ5doi6efP1zmn4ajVCaVp8WRBf0CMyoheXsL6flHKySUoi2dgxsSaJeRbKy8NatmDZN(qmF9L7hX4QpjgFmciMA7aqjgs(bbflWsGy(1XftriZAcXAOyGoe7dk1bgPeJ)eynBiwc2kMFD8JGwUIPb)zPE)5WfVeEHuvKgwvugyoOhavxko8CCIdRTlnvJeIIINdpomiCG5OQ0oceNuP(dR7(BIeIIItmEun6QAORwThExD7be)rriZAI73D6huQdmsDsTE)Q9W7QBpG4pkczwt4dNLB1lDu9DjG6wbnNjMZbrmqlwQuVy8hTwm1qIXFcSbiwGrIbihfIDDE9oig7tIX7r4Uynqm8(FX4pbwZgILGTI5xh)iOLRyAWFwQ3FoCXlHxivfPHvfLbMddchyoQkTJaXjvQ)maFUoVCmyoQkTJaXjvQ)OyHzmny)Q9W7QBpG4pkczwt4dNLB1lDu9DjGsqlxX0G)SuV)C4YJLQMFfxNk6Dyq4SlHtIRPZdu1vdutmny)Q9W7QBpG4pkczwt4dh0T)Mv3AvZhC(TE4T(RnsvrzGDGKxoG)kEUFhNfb58B9WB9xBKQIYa7W6E)oYGclQqYlhWFfh0XRBf0Yvmn4pl17phUqlSEaOQqYfoEjq5WGWzxcNextNhOQRgOMyAW(v7H3v3EaXFueYSMWhoOB)n7s4K4A6W(u1fonCITvyhzmn4(93L06AKquu8NhJfoxiq9Jg6DfNnD)oKfqinefDG03Sa1aqvx6eoX2Bf0CMyB(eyIX4Noi2GigOdXsnKs1wXunGCqm2NeZ3gcsvlg)jWeJP5UySUhbTCftd(Zs9(ZHlpglCUqGA0qqQAhgeorQjqCESu18Ri9I9peiX1KA)UeojUMopqvxnqnX0G94SiiNFRhER)AJuvugyhw39R2dVRU9aI)koOtqlxX0G)SuV)C4YJLQMFvLGf5WGWXP4SiiNhlvn)Qkbl6W6UhzqHfvi5Ld4VIdxJ)rQjqCEw8GGiSOOdbsCnPe0Yvmn4pl17phUGOPhBbtKWHbHZnFZQXhG64Y(bRMQeK1nMgC)(3SA8bOo7ADgJMQFR3rG429eGGO2EueYSMWhoxNx7D6huQdmsDsTEpolcY536H36V2ivfLb2r18bcA5kMg8NL69NdxC7yAGddchCweKdUUBLM9JdKYvC)oYGclQqYlhWF1151974SiiNFRhER)AJuvugyhw393GZIGCESu18R46ur)H19(9v3AvZhCESu18R46ur)bsE5a(R4WdVUvqlxX0G)SuV)C4cUUBvfHfU1HbHdolcY536H36V2ivfLb2H1vqlxX0G)SuV)C4cobFcEzaOCyq4GZIGC(TE4T(RnsvrzGDyDf0Yvmn4pl17phUGmqcx3TYHbHdolcY536H36V2ivfLb2H1vqlxX0G)SuV)C4scw0hWuxxPw7WGWbNfb58B9WB9xBKQIYa7W6kO5mX4oHKS6qmKuRXZ1fXqAOySFIRjXMG8(RvmU6tIXFcmXy26H36xSgrmUtzGDe0Yvmn4pl17phUW(uDcY7Dyq4GZIGC(TE4T(RnsvrzGDyDVFhzqHfvi5Ld4VcD8sqtqZzotm)CaZJrWxqZzIT5yJMeJ9hakXCCi5rQjYyAGdIL76rj2k)yaOeJrplsSeOeJ7ZIeJpgbeJblvnFX4EcwKyZl23nqSOfdNeJ9jLdIroArUHyinumU2BHtce0Yvmn4pidyEmo7s4K4AYbq6rCCHKhPQpqvxnqnX0ah2LAwItKAcehxi5rQjYyAWHajUMu7FxsRRrcrrXFEmw4CHa1pAO3v34ehB17iqcIdGwWw3q1T7D6Q3rGeeNlBHtce0Yvmn4pidyEm)5WLxplQMavvnlYHbHJt3LWjX10XfsEKQ(avD1a1etd2)UKwxJeIII)8ySW5cbQF0qVRC(9ofNfb58yPQ5xvjyrhw394SiiNxplQMavvnl6ajVCa)vidkSOcjVCa)EiHaPhlX1KGwUIPb)bzaZJ5phU86zr1eOQQzromiC2LWjX10XfsEKQ(avD1a1etd2V6wRA(GZJLQMFvLGfDwyjef9veyUIPbP(kEoCDNShNfb586zr1eOQQzrhi5Ld4VA1Tw18bNFRhER)AJuvugyhi5Ld43FZQBTQ5dopwQA(vvcw0bsPA7ECweKZV1dV1FTrQkkdSdK8Yb8ogolcY5XsvZVQsWIoqYlhWFfph0DRGMZeJ3kPDjOy8ojCsCnjgsdfBZyDdwiDeJ5Y4kMIfoauIX7ZpiOy8M)Z)hGynumflCaOeJ7jyrIXFcmX4EcViwcuIbAX2yqHfFK6le8iOLRyAWFqgW8y(ZHl7s4K4AYbq6rC(lJBfY6gSqYHDPML44LFqWA(F()aQqYlhW7dVUF3PrQjqCadkS4JuFHGhcK4AsTpsnbIJkHxQpwQA(hcK4AsThNfb58yPQ5xvjyrhw373FxsRRrcrrXFEmw4CHa1pAONpCUXjogKfqinefDqgqQNy7TcAotmU2e5kgRRyBgRBWcjXgeXMqS5flXB2qSOfdYceRzJJGwUIPb)bzaZJ5phUazDdwi5WGW5gNUlHtIRPZFzCRqw3Gfs3VVlHtIRPd7tvx40Wj2wHDKX0GB3hjeffNy8OA0v1qogK8Yb8(487HecKESextcA5kMg8hKbmpM)C4Ytlif1GwyGH3LLe0CMy8EwDmQoIbGsSiHOO4flWYqm(JwlME2rIH0qXcmsmflmJPbI1iITzSUblKCqmiHaPhtmflCaOeZnbkYBwhbTCftd(dYaMhZFoCbY6gSqYH12LMQrcrrXZHhhgeooDxcNextN)Y4wHSUblK270DjCsCnDyFQ6cNgoX2kSJmMgS)DjTUgjeff)5XyHZfcu)OHE(WbD7JeIIItmEun6QAiF4CJt8)g05CxThExD7be)T3Uhsiq6XsCnjO5mX2mcbspMyBgRBWcjXOeQ3k2Gi2eIXF0AXih5oqsmflCaOeJzRhER)JyCVflWYqmiHaPhtSbrmMM7IHIIxmiLQTInaXcmsma5OqmN8hbTCftd(dYaMhZFoCbY6gSqYHbHJt3LWjX105VmUviRBWcP9qYlhWF1QBTQ5do)wp8w)1gPQOmWoqYlhW7pp8A)QBTQ5do)wp8w)1gPQOmWoqYlhWFfhNSpsikkoX4r1ORQHCmi5Ld49z1Tw18bNFRhER)AJuvugyhi5Ld493jcA5kMg8hKbmpM)C4cUoxxQUnFfbDyq440DjCsCnDyFQ6cNgoX2kSJmMgS)DjTUgjeffVpCUUGwUIPb)bzaZJ5phUq7MFrWmibnbnN5mXyck1bMy(TBTQ5dEbnNjgVvs7sqX4Ds4K4AsqlxX0G)8bL6aRUupNDjCsCn5ai9iopMQgyq6XATYHDPML4S6wRA(GZJLQMFvLGfDwyjef9veyUIPbP2ho8C46orqZzIX7KG5XeBqeJpjwcjXwPR7aqjwdeJ7jyrITWsik6pIXvmH6TIHtinKedzGFiMkblsSbrm(Kyy5osmql2gdkS4JuFHGIHZgIX9eErmgSu18fBaI1qfbflAXqrHyBgRBWcjXyDf7gqlgVp)GGIXB(p)Fa3Ee0Yvmn4pFqPoWQl17phUSlbZJ5WGW5gNUlHtIRPZJPQbgKESwRUF3PrQjqCadkS4JuFHGhcK4AsTpsnbIJkHxQpwQA(hcK4AsD7(v7H3v3EaXFueYSMWhE27uilGqAik64LWl1gPgyu1l)GG18)8)biO5mXC8U1IH0qXyWsvZ3J0kX8xmgSu18)aoxiXybA6FX4tILqsSeVzdXIwSv6kwdeJ7jyrITWsik6pIXvaO3kgFmciMFoaLyBoLxa0)InVyjEZgIfTyqwGynBCe0Yvmn4pFqPoWQl17phU42TUcPVzHlYbKgwbKJco84a5OaM10RzbbNnXlhgeoWCrhWGclQKgrqlxX0G)8bL6aRUuV)C4YJLQMVhPvomiCiabrT1hoBIx7jabrT9OiKznHpC4Hx7D6UeojUMopMQgyq6XATA)Q9W7QBpG4pkczwt4dp7veolcYbzaQkFkVaO)pqYlhWFfpcAotm)64Ifyq6XAT6fdPHIrGGGdaLymyPQ5lg3tWIe0Yvmn4pFqPoWQl17phUSlHtIRjhaPhX5Xu1v7H3v3EaX7WUuZsCwThExD7be)rriZAcF4Go)XzrqopwQA(vCDQO)W6kOLRyAWF(GsDGvxQ3FoCzxcNextoaspIZJPQR2dVRU9aI3HDPML4SAp8U62di(JIqM1e(W56omiCw9ocKG4CzlCsGGwUIPb)5dk1bwDPE)5WLDjCsCn5ai9iopMQUAp8U62diEh2LAwIZQ9W7QBpG4pkczwtCfhECyq4SlHtIRPd7tvx40Wj2wHDKX0G9VlP11iHOO4ppglCUqG6hn0ZhoBsqZzIX9eSiXuSWbGsmMTE4T(fRHIL49osSadspwRvhbTCftd(ZhuQdS6s9(ZHlpwQA(vvcwKddcNDjCsCnDEmvD1E4D1Thq87VzxcNextNhtvdmi9yTwD)oolcY536H36V2ivfLb2bsE5aEF4WZbD3V)UKwxJeIII)8ySW5cbQF0qpF4SP9RU1QMp48B9WB9xBKQIYa7ajVCaVp8WRBf0CMyONfcedsE5agakX4Ecw0lgoH0qsSaJedzqHfIra1l2GigtZDX43aUfIHtIbPuTvSbiwmE0rqlxX0G)8bL6aRUuV)C4YJLQMFvLGf5WGWzxcNextNhtvxThExD7be)EKbfwuHKxoG)Qv3AvZhC(TE4T(RnsvrzGDGKxoGxqtqZzotmMGsDGrkX2SoYyAGGMZeZ5GigtqPoW4YUempMyjKeJ11bXyFsmgSu18)aoxiXIwmCcqitigcS9elWiXCZ)NDKy4nG9flbkX8ZbOeBZP8cG(3bXODeqSbrm(KyjKeldX8shjMFDCXUHfOP)fJ9hakX495heumEZ)5)d4wbTCftd(ZhuQdmsX5XsvZ)d4CHCyq4CdolcY5dk1b2H19(DCweKZUemp2H1929E5heSM)N)pGkK8Yb8C4LGMZeZphW8yILHyx3FX8RJlg)jWA2qmUZigxeBt(lg)jWeJ7mIXFcmXyWyHZfciMVneKQwmCweeXyDflAXYD9Oe7Bpsm)64IXp)Ge7NGnJPb)rqZzIXB0Fl2NiKyrlgYaMhtSmeBt(lMFDCX4pbMyKJYvO3k2Melsikk(Jy3WKEKy5lwZg)OiX(GsDGDUvqZzI5NdyEmXYqSn5Vy(1XfJ)eynBig3zCqmN4Vy8NatmUZ4GyjqjMZlg)jWeJ7mILibbfJ3jbZJjOLRyAWF(GsDGrk)5WLvQ11CftdQ65dhaPhXbzaZJ5WGWHqqOvm7O6Q9W7QBpG49HZYT6LoQ(UeqD)oolcY5XyHZfcuJgcsvFyD3VAp8U62di(JIqM1exXbD3V)UKwxJeIII)8ySW5cbQF0qpF4SP9eccTIzhvxThExD7beVpC2097R2dVRU9aI)OiKznXvC4XXUjsnbIJIixcw)aMrII8oeiX1KApolcYzxcMh7W6ERGwUIPb)5dk1bgP8NdxESu18)aoxihgeoFqPoWi15j3F(9VlP11iHOO4ppglCUqG6hn07QnjOLRyAWF(GsDGrk)5WLhB25WGWjsnbIdyqHfFK6le8qGextQ9qwaH0qu0jgW2A0oAwvCDQO9VlP11iHOO4ppglCUqG6hn07kNiO5mX4QUIfTyxxSiHOO4f7gqlMlC6Bf7crUIX6kMFoaLyBoLxa0)IHVvS12LEaOeJblvn)pGZf6iOLRyAWF(GsDGrk)5WLhlvn)pGZfYH12LMQrcrrXZHhhgeooDxcNexth2NQUWPHtSTc7iJPb7veolcYbzaQkFkVaO)pqYlhWFfp7FxsRRrcrrXFEmw4CHa1pAO3vCU((iHOO4eJhvJUQgYXGKxoG3hNxqZzI5Nnumx40Wj2kgSJmMg4GySpjgdwQA(FaNlKy9ockgt0qpX4pbMyBoVxSevoGpeJ1vSOfBtIfjeffVynuSbrm)CZfBEXGSaWaqjwJGi2nnqSeSvS0RzbHynIyrcrrXFRGwUIPb)5dk1bgP8NdxESu18)aoxihgeo7s4K4A6W(u1fonCITvyhzmny)nkcNfb5GmavLpLxa0)hi5Ld4VIN73JutG4WNs3g4LFqWdbsCnP2)UKwxJeIII)8ySW5cbQF0qVR4SPBf0Yvmn4pFqPoWiL)C4YJXcNleO(rd9Cyq48UKwxJeIII3hox3)BWzrqobgvHDee4W6E)oKfqinefDYlzcNV(nRUIatuEeiUD)n4SiiNFRhER)AJuvugy1Kn6fCIdR797ofNfb54cjpsnrgtdoSU3V)UKwxJeIII3hoo5wbnNjgdwQA(FaNlKyrlgKqG0JjMFoaLyBoLxa0)ILaLyrlgbEwijgFsSvceBLq4wX6DeuSumewTwm)CZfBarlwGrIbihfIX0CxSbrm3()bxthbTCftd(ZhuQdms5phU8yPQ5)bCUqomiCueolcYbzaQkFkVaO)pqYlhWFfhEUFF1Tw18bNFRhER)AJuvugyhi5Ld4VIhUM9kcNfb5GmavLpLxa0)hi5Ld4VA1Tw18bNFRhER)AJuvugyhi5Ld4f0Yvmn4pFqPoWiL)C4ckD3E46uromiCWzrqoUeePHzqQ6oAa)5JCDXhooz)Qbk2joUeePHzqQ6oAa)bMGl(WHNRlOLRyAWF(GsDGrk)5WLhlvn)pGZfsqlxX0G)8bL6aJu(ZHllmkDRpwhomiCCAKquuCMVI3)VF1E4D1Thq8hfHmRj8Hdp7Xzrqopwh1budmQQs4LdR7EcqquBpX4r1ORBIx(GAPoEPJkmVlTkBGoNNNsuIsb]] )

    
end
