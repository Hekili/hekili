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


    spec:RegisterPack( "Subtlety", 20210629, [[daLU7bqiQO8iQiTjLkFcvkJsvPoLQkwfvuvVIQQMfQs3Ikq7sv(fQedJkKJHQyzQQYZqLKPPuKRrfQTrfv(gvemovvQCovvIwNQkL5PQK7Hk2hvf)Jka4GOsQwOQQ6HuvPjIkvxuvLqBKQk6JQQu1iPcqDsQOkRes5LubqZuvL0nPIq7uPWpvvjyOur0svkkpfftLQsxfvszRubKVQuunwQQWzPcaTxj(RKgmLdlAXq1JvYKj5YiBgIpdjJgkNwQvtfG8AvfZMu3MQSBGFRy4uPJtfqTCqpxLPlCDuA7kv9DuvJNkOZRuA(qQ2pXfEk(wyuzqLn(Zr)XJJCU)(LpE4XX8Wv)vyITUuHXnxFsuuHbKEuHHHfp0uSTW4MB1tQk(wyUHfUOcdweU3VXfUGQdmw83A84Y1ES6m6bSGjsWLR9wCPWGZ26W5bk4fgvguzJ)C0F84iN7VF5JhECmp)5ekmjBGnWcdt753cdwRueOGxyu0TkmmS4HMITITzdkwsqdnwaj2F)sEf7ph9hpcAcAoXzpj2(e2jUMEShvDH9a7yBforg9aeJ1vSBeRdX6tSJcXWjKbsIXNeJ9iX64jO53XdVbKyES6OD1KyRuRR5k6bu19fIrGa20jwmIbjf7IeZDcceDQfds8h4NxHr3xCfFlmxqPoWivX3Yg8u8TWqGextQY)fMCf9akmhwQg(xa7puHrr3c2UrpGcJZdrmMGsDGXL9jOpmXsijgRlVIXEKymyPA4FbS)qIfJy4eGq6qme44jwGrI5M317jXWha7jwcuI5Nnqj2Mt5haDhVIr7jGynIy8jXsijwgI5Loum)6KI9nlqt3jg71auI5eZliOyC97Y7AWpfMfSdc2zH5BXWzrqExqPoWESUIHo6IHZIG82NG(WESUI9Jy7eZlVGG18U8UguHKx2GtmoI5Osu24VIVfgcK4Asv(VWOOBbB3OhqHXpBqFyILHyBYFX8Rtkg)oWg2qmUZWRyo2FX43bMyCNHxXsGsmNtm(DGjg3zelrcckMduc6dRWKROhqHzLADnxrpGQUVOWSGDqWolmeccTIEpvxJh(uDNgeNy(WrSLB1lDy9CjGsm0rxmCweK3HXc7peOgdeKQ5X6k2oXwJh(uDNge3tri9QdX(IJy)jg6Ol25sADnsikkU3HXc7peOEXa9eZhoITjX2jgHGqRO3t114Hpv3PbXjMpCeBtIHo6ITgp8P6oniUNIq6vhI9fhX4rmhuSVflsnbINIixcwVaMrII8EeiX1KsSDIHZIG82NG(WESUI9tHr3xubPhvyqAqFyLOSbxv8TWqGextQY)fMfSdc2zH5ck1bgPEh5E9j2oXoxsRRrcrrX9omwy)Ha1lgONyFj2Mkm5k6buyoSun8Va2FOsu2ytfFlmeiX1KQ8FHzb7GGDwyIutG4bAuyXfP(dbFeiX1KsSDIbzbeYarrVObBRX4WEvX1PIEeiX1KsSDIDUKwxJeIII7DySW(dbQxmqpX(smhxyYv0dOWCy9(su2WXfFlmeiX1KQ8FHjxrpGcZHLQH)fW(dvywBxAQgjeffxzdEkmlyheSZcJZeBFc7extp2JQUWEGDSTcNiJEaITtmfHZIG8qAGQYNYpa6UhK8YgCI9Ly8i2oXoxsRRrcrrX9omwy)Ha1lgONyFXrmUsSDIfjeffVO9OAmvvtI5GIbjVSbNy(iMZvyu0TGTB0dOWW1CflgX4kXIeIIItSVbJyUWE(rSpe5kgRRy(zduIT5u(bq3jg(wXwBx6gGsmgSun8Va2FOxjkB4CfFlmeiX1KQ8FHjxrpGcZHLQH)fW(dvyu0TGTB0dOW4NdumxypWo2kgCIm6bWRyShjgdwQg(xa7pKyZEckgtmqpX43bMyBUtuSev2GleJ1vSyeBtIfjeffNyduSgrm)CZfRpXGSaqdqj2GGi23dqSeSvS0BybHydIyrcrrX9tHzb7GGDwy2NWoX10J9OQlShyhBRWjYOhGy7e7BXueolcYdPbQkFk)aO7EqYlBWj2xIXJyOJUyrQjq84tP7a8Yli4JajUMuITtSZL06AKquuCVdJf2Fiq9Ib6j2xCeBtI9tjkB4ek(wyiqIRjv5)cZc2bb7SWCUKwxJeIIItmF4igxjM)I9Ty4SiiVaJQWjcc8yDfdD0fdYciKbIIE5NmH9vVHvxrGjkpcepcK4Asj2pITtSVfdNfb5DB9Wh9vhKQIYaRMSXSGD8yDfdD0fZzIHZIG8CHKhP6iJEapwxXqhDXoxsRRrcrrXjMpCeZXI9tHjxrpGcZHXc7peOEXa9krzJFxX3cdbsCnPk)xyYv0dOWCyPA4FbS)qfgfDly7g9akmmyPA4FbS)qIfJyqcbshMy(zduIT5u(bq3jwcuIfJye4yHKy8jXwjqSvcHBfB2tqXsXqy1AX8ZnxSgeJybgjgGCyigZWDXAeXCN7ACn9kmlyheSZcJIWzrqEinqv5t5haD3dsEzdoX(IJy8ig6Ol2AgTA4dE3wp8rF1bPQOmWEqYlBWj2xIXZVtSDIPiCweKhsduv(u(bq39GKx2GtSVeBnJwn8bVBRh(OV6Guvugypi5Ln4krzJFzX3cdbsCnPk)xywWoiyNfgCweKNlbrgygKQUNAW9UixFeZhoI5yX2j2Aak2oEUeezGzqQ6EQb3dMGpI5dhX4HRkm5k6buyqPNXdxNkQeLn4XrfFlm5k6buyoSun8Va2FOcdbsCnPk)xIYg8WtX3cdbsCnPk)xywWoiyNfgNjwKquu86RIp3j2oXwJh(uDNge3tri9QdX8HJy8i2oXWzrqEh2e1gudmQQs4NhRRy7eJaee12x0EunM6MCKy(igQL65LoSWKROhqHzHrPB9WMOeLOWOiKKvhfFlBWtX3ctUIEafMp96tHHajUMuL)lrzJ)k(wyiqIRjv5)cZ4wyokkm5k6buy2NWoX1uHzFQzPcdolcY709IQjqvv9IESUIHo6IDUKwxJeIII7DySW(dbQxmqpX8HJyoxHrr3c2UrpGcdx7iLyXiMIcc61asm(yuGrqXwZOvdFWjg)SdXqgOymaUlgEEKsSbiwKquuCVcZ(ewbPhvyoGQUgGQJEaLOSbxv8TWqGextQY)fgfDly7g9akm(fJwFeZVC)eldXqA4ffMCf9akmRuRR5k6bu19ffgDFrfKEuHzPUsu2ytfFlmeiX1KQ8FHrr3c2UrpGcZMXcedHvR3k2XVJfgDIfJybgjgtqPoWiLyB2ez0dqSVX3kMAAakXUHxX6qmKbUOtm3z0naLynIyGjWAakX6tSCF26ext)8km5k6buyGSGAUIEavDFrHzb7GGDwyUGsDGrQxQ1fgDFrfKEuH5ck1bgPkrzdhx8TWqGextQY)fMCf9akmNUxunbQQQxuHrr3c2UrpGcdx31vVvmgDViXsGsmU3lsSme7p)fZVoPykwydqjwGrIH0WleJhhj2rRbOoEflrcckwGLHyBYFX8RtkwJiwhIro0TH0jg)oWAGybgjgGCyi2V3VCxSbkwFIbMqmw3cZc2bb7SWCUKwxJeIII7DySW(dbQxmqpX(smNtSDIH0OWIkK8YgCI5JyoNy7edNfb5D6Er1eOQQErpi5Ln4e7lXqTupV0HITtS14Hpv3PbXjMpCeBtI5GI9Tyr7rI9Ly84iX(rmNVy)vIYgoxX3cdbsCnPk)xyg3cZrrHjxrpGcZ(e2jUMkm7tnlvyCH9a7yBforg9aeBNyNlP11iHOO4EhglS)qG6fd0tmF4i2FfgfDly7g9akm)ca9wXwyjafjgCIm6biwJigFsmSCpjMlShyhBRWjYOhGyhfILaLyES6OD1KyrcrrXjgR7RWSpHvq6rfg2JQUWEGDSTcNiJEaLOSHtO4BHHajUMuL)lmk6wW2n6buyCsypWo2k2Mnrg9aCaqSFLcUDIHQ3tILITGPRyj(WgIracIARyiduSaJe7ck1bMy(L7NyFJZ2Afbf7IwRfdsNlTcX64NNyoaY6YRyDi2kbIHtIfyzi21EUA6vyYv0dOWSsTUMROhqv3xuywWoiyNfM9jStCn9ypQ6c7b2X2kCIm6buy09fvq6rfMlOuhy1L6krzJFxX3cdbsCnPk)xyg3cZrrHjxrpGcZ(e2jUMkm7tnlvy(ZXI5VyrQjq823Og4JajUMuI58f7phjM)IfPMaXZlVGG1bPEyPA4FpcK4AsjMZxS)CKy(lwKAceVdlvd)kYSyVhbsCnPeZ5l2Fowm)flsnbIxQZfSJTpcK4AsjMZxS)CKy(l2FowmNVyFl25sADnsikkU3HXc7peOEXa9eZhoITjX(PWOOBbB3OhqHHRDKsSyetrinGeJpgbelgXypsSlOuhyI5xUFInqXWzBTIGxHzFcRG0JkmxqPoWQbgKoSrRkrzJFzX3cdbsCnPk)xyu0TGTB0dOW43bCTIGIXEnaLyPymbL6atm)YDX4JraXGuUWAakXcmsmcqquBflWG0HnAvHjxrpGcZk16AUIEavDFrHzb7GGDwyiabrT9PiKE1HyFXrS9jStCn9UGsDGvdmiDyJwvy09fvq6rfMlOuhy1L6krzdECuX3cdbsCnPk)xywWoiyNfMVfJqqOv07P6A8WNQ70G4eZhoITCREPdRNlbuI9JyOJUyFl2A8WNQ70G4EkcPxDi2xCeJhXqhDXqAuyrfsEzdoX(IJy8i2oXieeAf9EQUgp8P6onioX8HJyCLyOJUy4SiiVBRh(OV6Guvugy1KnMfSJhRRy7eJqqOv07P6A8WNQ70G4eZhoITjX(rm0rxSVf7CjTUgjeff37WyH9hcuVyGEI5dhX2Ky7eJqqOv07P6A8WNQ70G4eZhoITjX(PWKROhqHzLADnxrpGQUVOWO7lQG0JkminOpSsu2GhEk(wyiqIRjv5)cJIUfSDJEafgU2rILIHZ2AfbfJpgbeds5cRbOelWiXiabrTvSadsh2OvfMCf9akmRuRR5k6bu19ffMfSdc2zHHaee12NIq6vhI9fhX2NWoX107ck1bwnWG0HnAvHr3xubPhvyWzBTQeLn45VIVfgcK4Asv(VWKROhqHjHReq1yGqcefgfDly7g9akm)6WNUqmxypWo2kwdel1AXgeXcmsmUUt(RIHtRK9iX6qSvYE0jwk2V3VCVWSGDqWolmeGGO2(uesV6qmF4igpowm)fJaee12hKqrGsu2GhUQ4BHjxrpGctcxjGQUS6JkmeiX1KQ8FjkBWZMk(wyYv0dOWOBuyXvDaXQq5rGOWqGextQY)LOSbpoU4BHjxrpGcdEIQoi1a2RpxHHajUMuL)lrjkmUqAnE4zu8TSbpfFlm5k6buysxx92Q703akmeiX1KQ8FjkB8xX3ctUIEafg8jcnPQi6ClP43au1yCydkmeiX1KQ8FjkBWvfFlmeiX1KQ8FHzb7GGDwyUHvJ3a1ZL9cwnvjiRB0d4rGextkXqhDXUHvJ3a1B)OZO1u9g9EcepcK4AsvyYv0dOWGOPdBbtKOeLn2uX3ctUIEafMlOuhyfgcK4Asv(VeLnCCX3cdbsCnPk)xyYv0dOW4LWpKQImWQIYaRW4cP14HNr9O1auxHHhhxIYgoxX3cdbsCnPk)xyYv0dOWC6Er1eOQQErfMfSdc2zHbsiq6WsCnvyCH0A8WZOE0AaQRWWtjkB4ek(wyiqIRjv5)cZc2bb7SWazbeYarrpVe(Poi1aJQE5feSM3L31GhbsCnPkm5k6buyoSun8R46urxjkrHbPb9Hv8TSbpfFlmeiX1KQ8FHzClmhffMCf9akm7tyN4AQWSp1SuHjsnbINlK8ivhz0d4rGextkX2j25sADnsikkU3HXc7peOEXa9e7lX(wmhlMdk2A2tGeepaTGJEGkX(rSDI5mXwZEcKG49zlStqHrr3c2UrpGcZMJ1Asm2RbOeZjHKhP6iJEa8kwUFALyR8IgGsmgDViXsGsmU3lsm(yeqmgSun8fJ7jyrI1Ny3maXIrmCsm2Ju8kg5Wf5gIHmqXCaUf2jOWSpHvq6rfgxi5rQ6bu11auD0dOeLn(R4BHHajUMuL)lmlyheSZcJZeBFc7extpxi5rQ6bu11auD0dqSDIDUKwxJeIII7DySW(dbQxmqpX(smNtSDI5mXWzrqEhwQg(vvcw0J1vSDIHZIG8oDVOAcuvvVOhK8YgCI9LyinkSOcjVSbNy7edsiq6WsCnvyYv0dOWC6Er1eOQQErLOSbxv8TWqGextQY)fMfSdc2zHzFc7extpxi5rQ6bu11auD0dqSDITMrRg(G3HLQHFvLGf9wyjefDveyUIEaPwSVeJNNtWXITtmCweK3P7fvtGQQ6f9GKx2GtSVeBnJwn8bVBRh(OV6Guvugypi5Ln4eBNyFl2AgTA4dEhwQg(vvcw0dsPARy7edNfb5DB9Wh9vhKQIYa7bjVSbNyoOy4SiiVdlvd)Qkbl6bjVSbNyFjgpV)e7NctUIEafMt3lQMavv1lQeLn2uX3cdbsCnPk)xyg3cZrrHjxrpGcZ(e2jUMkm7tnlvy8YliynVlVRbvi5Ln4eZhXCKyOJUyotSi1eiEGgfwCrQ)qWhbsCnPeBNyrQjq8uj8t9Ws1W)rGextkX2jgolcY7Ws1WVQsWIESUIHo6IDUKwxJeIII7DySW(dbQxmqpX8HJyFlMJfZbfdYciKbIIEini1DS9rGextkX(PWOOBbB3OhqHXbmPDjOyoqjStCnjgYafBZyDdwi9eJ5t7kMIf2auI5eZliOyC97Y7AGydumflSbOeJ7jyrIXVdmX4Ec)iwcuIbgX2OrHfxK6pe8vy2NWki9OcZ9PDRqw3GfsLOSHJl(wyiqIRjv5)ctUIEafgiRBWcPcJIUfSDJEafghGe5kgRRyBgRBWcjXAeX6qS(elXh2qSyedYceByJxHzb7GGDwy(wmNj2(e2jUME3N2TczDdwijg6Ol2(e2jUMEShvDH9a7yBforg9ae7hX2jwKquu8I2JQXuvnjMdkgK8YgCI5JyoNy7edsiq6WsCnvIYgoxX3ctUIEafMJwqkQbTWaTdmlvyiqIRjv5)su2Wju8TWqGextQY)fMCf9akmqw3GfsfM12LMQrcrrXv2GNcZc2bb7SW4mX2NWoX107(0UviRBWcjX2jMZeBFc7extp2JQUWEGDSTcNiJEaITtSZL06AKquuCVdJf2Fiq9Ib6jMpCe7pX2jwKquu8I2JQXuvnjMpCe7BXCSy(l23I9NyoFXwJh(uDNgeNy)i2pITtmiHaPdlX1uHrr3c2UrpGcJtKvhTAIObOelsikkoXcSmeJFR1IP79KyiduSaJetXcZOhGydIyBgRBWcjEfdsiq6WetXcBakXCtGI861ReLn(DfFlmeiX1KQ8FHjxrpGcdK1nyHuHrr3c2UrpGcZMriq6WeBZyDdwijgLq9wXAeX6qm(Twlg5q3gsIPyHnaLymB9Wh99eJ7JybwgIbjeiDyI1iIXmCxmuuCIbPuTvSgiwGrIbihgI547vywWoiyNfgNj2(e2jUME3N2TczDdwij2oXGKx2GtSVeBnJwn8bVBRh(OV6Guvugypi5Ln4eZFX4XrITtS1mA1Wh8UTE4J(QdsvrzG9GKx2GtSV4iMJfBNyrcrrXlApQgtv1KyoOyqYlBWjMpITMrRg(G3T1dF0xDqQkkdShK8YgCI5VyoUeLn(LfFlmeiX1KQ8FHzb7GGDwyCMy7tyN4A6XEu1f2dSJTv4ez0dqSDIDUKwxJeIIItmF4igxvyYv0dOWGRZ1NQ7WxrWsu2Ghhv8TWKROhqHH233IGzqfgcK4Asv(VeLOWSuxX3Yg8u8TWqGextQY)fMfSdc2zHXzIHZIG8oSun8RQeSOhRRy7edNfb5DySW(dbQXabPAESUITtmCweK3HXc7peOgdeKQ5bjVSbNyFXrmU654cd7r1bbPIAPkBWtHjxrpGcZHLQHFvLGfvyu0TGTB0dOWW1osmUNGfj2GG4GOwkXWjKbsIfyKyin8cXomwy)Ha1lgONyiWXtmFhiivJyRXJoXAWReLn(R4BHHajUMuL)lmlyheSZcdolcY7WyH9hcuJbcs18yDfBNy4SiiVdJf2FiqngiivZdsEzdoX(IJyC1ZXfg2JQdcsf1sv2GNctUIEafMBRh(OV6GuvugyfgfDly7g9akmFZ1aA6oXsnKs1wXyDfdNwj7rIXNelM5JymyPA4lMFol27hXypsmMTE4J(eBqqCqulLy4eYajXcmsmKgEHymySW(dbeJjgONyiWXtmFhiivJyRXJoXAWReLn4QIVfgcK4Asv(VWSGDqWolm7tyN4A6DavDnavh9aeBNyotSlOuhyK65LGqtITtSVfZzIbzbeYarrVbNunbw0JajUMuIHo6ITMrRg(G3T1dF0xDqQkkdShRRy7eBnE4t1DAqCI5dhXCSy)uyYv0dOWGOtuKwNrpGsu2ytfFlmeiX1KQ8FHzb7GGDwy(wmilGqgik65LWp1bPgyu1lVGG18U8Ug8iqIRjLy7eBnE4t1DAqCpfH0Roe7loIXJyoOyrQjq8ue5sW6fWmiuK3JajUMuIHo6IbzbeYarrpfLbMEB9Ws1W)EeiX1KsSDITgp8P6onioX(smEe7hX2jgolcY726Hp6RoivfLb2J1vSDIHZIG8oSun8RQeSOhRRy7eZlVGG18U8UguHKx2GtmoI5iX2jgolcYtrzGP3wpSun8VNA4dkm5k6buy2NG(Wkrzdhx8TWqGextQY)fgfDly7g9akmo5mAXqgOy(oqqQgXCHKdYmCxm(DGjgdg3fdsPARy8XiGyGjedYcanaLym(5RWGmWkGCyu2GNcZc2bb7SWePMaX7WyH9hcuJbcs18iqIRjLy7eZzIfPMaX7Ws1WVIml27rGextQctUIEafg3z0viDdlCrLOSHZv8TWqGextQY)fMCf9akmhglS)qGAmqqQMcJIUfSDJEafgU2rI57abPAeZfsIXmCxm(yeqm(Kyy5EsSaJeJaee1wX4JrbgbfdboEI5oJUbOeJFhydBigJFk2afZbe7fIHIaem16TVcZc2bb7SWqacIARy(WrmNZrITtS9jStCn9oGQUgGQJEaITtS1mA1Wh8UTE4J(QdsvrzG9yDfBNyRz0QHp4DyPA4xvjyrVfwcrrNy(WrmEeBNyFlMZedYciKbIIEdoPAcSOhbsCnPedD0ftr4SiipeDII06m6b8yDf7hX2j2A8WNQ70G4e7loI9xjkB4ek(wyiqIRjv5)ctUIEafMJGWmivfFau9C7puHzb7GGDwy2NWoX107aQ6AaQo6bi2oXCMyQjEhbHzqQk(aO652FOQAIx0RpnaLy7elsikkEr7r1yQQMeZhoI9hpIHo6IH0OWIkK8YgCI9fhXCSy7e7CjTUgjeff37WyH9hcuVyGEI9LyCvHzTDPPAKquuCLn4PeLn(DfFlmeiX1KQ8FHzb7GGDwy2NWoX107aQ6AaQo6bi2oXwJh(uDNge3tri9QdX8HJy8uyYv0dOWCK71xjkB8ll(wyiqIRjv5)ctUIEafMBRh(OV6GuvugyfgfDly7g9akmCTJeJzRh(OpXgGyRz0QHpqSVtKGGIH0WleJbW9FeJfOP7eJpjwcjXqnnaLyXiM74kMVdeKQrSeOetnIbMqmSCpjgdwQg(I5NZI9EfMfSdc2zHzFc7extVdOQRbO6OhGy7e7BXIutG4rG9KECBaQ6HLQH)9iqIRjLyOJUyRz0QHp4DyPA4xvjyrVfwcrrNy(WrmEe7hX2j23I5mXIutG4DySW(dbQXabPAEeiX1Ksm0rxSi1eiEhwQg(vKzXEpcK4Asjg6Ol2AgTA4dEhglS)qGAmqqQMhK8YgCI5Jy)j2pITtSVfZzIbzbeYarrVbNunbw0JajUMuIHo6ITMrRg(GhIorrADg9aEqYlBWjMpI9NJe7Nsu2Ghhv8TWqGextQY)fMCf9akmEj8dPQidSQOmWkm6gq1LQWWZZXfM12LMQrcrrXv2GNcZc2bb7SWaZwvP9eiEPsDpwxX2j23IfjeffVO9OAmvvtI9LyRXdFQUtdI7PiKE1HyOJUyotSlOuhyK6LATy7eBnE4t1DAqCpfH0RoeZhoITCREPdRNlbuI9tHrr3c2UrpGcJZdrSuPoXsijgRlVIDG2LelWiXgajg)oWetp8PleZxF5(tmU2rIXhJaIP22auIHKxqqXcSeiMFDsXuesV6qSbkgycXUGsDGrkX43b2WgILGTI5xN8vIYg8WtX3cdbsCnPk)xyYv0dOW4LWpKQImWQIYaRWOOBbB3OhqHX5HigyelvQtm(TwlMQjX43bwdelWiXaKddX4khD8kg7rI5er4Uydqm85oX43b2WgILGTI5xN8vywWoiyNfgy2QkTNaXlvQ71aX8rmUYrI5GIbZwvP9eiEPsDpflmJEaITtS14Hpv3PbX9uesV6qmF4i2YT6LoSEUeqvIYg88xX3cdbsCnPk)xywWoiyNfM9jStCn9oGQUgGQJEaITtS14Hpv3PbX9uesV6qmF4i2FITtSVfBnJwn8bVBRh(OV6Guvugypi5Ln4e7lX4rm0rxmCweK3T1dF0xDqQkkdShRRyOJUyinkSOcjVSbNyFXrS)CKy)uyYv0dOWCyPA4xX1PIUsu2GhUQ4BHHajUMuL)lmlyheSZcZ(e2jUMEhqvxdq1rpaX2j2A8WNQ70G4EkcPxDiMpCe7pX2j23ITpHDIRPh7rvxypWo2wHtKrpaXqhDXoxsRRrcrrX9omwy)Ha1lgONyFXrSnjg6OlgKfqidef9G0nSavdqvx6e2X2hbsCnPe7NctUIEafgAHnnavfsUW2lbQsu2GNnv8TWqGextQY)fMCf9akmhglS)qGAmqqQMcJIUfSDJEafMnVdmXy8tEfRredmHyPgsPARyQbq8kg7rI57abPAeJFhyIXmCxmw3xHzb7GGDwyIutG4DyPA4xrMf79iqIRjLy7eBFc7extVdOQRbO6OhGy7edNfb5DB9Wh9vhKQIYa7X6k2oXwJh(uDNgeNyFXrS)krzdECCX3cdbsCnPk)xywWoiyNfgNjgolcY7Ws1WVQsWIESUITtmKgfwuHKx2GtSV4i2Vtm)flsnbI3XIheeHff9iqIRjvHjxrpGcZHLQHFvLGfvIYg84CfFlmeiX1KQ8FHzb7GGDwy(wSBy14nq9CzVGvtvcY6g9aEeiX1Ksm0rxSBy14nq92p6mAnvVrVNaXJajUMuI9Jy7eJaee12NIq6vhI5dhX4khj2oXCMyxqPoWi1l1AX2jgolcY726Hp6RoivfLb2tn8bfMCf9akmiA6WwWejkrzdECcfFlmeiX1KQ8FHzb7GGDwyWzrqE46zuA2lEqkxHyOJUyinkSOcjVSbNyFjgx5iXqhDXWzrqE3wp8rF1bPQOmWESUITtSVfdNfb5DyPA4xX1PIUhRRyOJUyRz0QHp4DyPA4xX1PIUhK8YgCI9fhX4XrI9tHjxrpGcJ7e9akrzdE(DfFlmeiX1KQ8FHzb7GGDwyWzrqE3wp8rF1bPQOmWESUfMCf9akm46zuvew42su2GNFzX3cdbsCnPk)xywWoiyNfgCweK3T1dF0xDqQkkdShRBHjxrpGcdobpc(PbOkrzJ)CuX3cdbsCnPk)xywWoiyNfgCweK3T1dF0xDqQkkdShRBHjxrpGcdsdjC9mQsu24pEk(wyiqIRjv5)cZc2bb7SWGZIG8UTE4J(QdsvrzG9yDlm5k6buysWIUaM66k16su24V)k(wyiqIRjv5)ctUIEafg2JQDqExHrr3c2UrpGcd3jKKvhIHKAnEU(igYafJ9sCnjwhK39BIX1osm(DGjgZwp8rFIniIXDkdSxHzb7GGDwyWzrqE3wp8rF1bPQOmWESUIHo6IH0OWIkK8YgCI9Ly)5OsuIcZfuQdS6sDfFlBWtX3cdbsCnPk)xyg3cZrrHjxrpGcZ(e2jUMkm7tnlvywZOvdFW7Ws1WVQsWIElSeIIUkcmxrpGulMpCeJNNtWXfgfDly7g9akmoGjTlbfZbkHDIRPcZ(ewbPhvyomvnWG0HnAvjkB8xX3cdbsCnPk)xyYv0dOWSpb9Hvyu0TGTB0dOW4aLG(WeRreJpjwcjXwPRBdqj2aeJ7jyrITWsik6EI9lMq9wXWjKbsIH0WletLGfjwJigFsmSCpjgyeBJgfwCrQ)qqXWzdX4Ec)igdwQg(I1aXgOIGIfJyOOqSnJ1nyHKySUI9nyeZjMxqqX463L31GFEfMfSdc2zH5BXCMy7tyN4A6DyQAGbPdB0kXqhDXCMyrQjq8ankS4Iu)HGpcK4Asj2oXIutG4Ps4N6HLQH)JajUMuI9Jy7eBnE4t1DAqCpfH0RoeZhX4rSDI5mXGSaczGOONxc)uhKAGrvV8ccwZ7Y7AWJajUMuLOSbxv8TWqGextQY)fgfDly7g9akmo5mAXqgOymyPA47rALy(lgdwQg(xa7pKySanDNy8jXsijwIpSHyXi2kDfBaIX9eSiXwyjefDpX(fa6TIXhJaI5Nnqj2Mt5haDNy9jwIpSHyXigKfi2WgVcdYaRaYHrzdEkmlyheSZcdmx0d0OWIkPrkmKddywtVHfefMn5OctUIEafg3z0viDdlCrLOSXMk(wyiqIRjv5)cZc2bb7SWqacIARy(WrSn5iX2jgbiiQTpfH0RoeZhoIXJJeBNyotS9jStCn9omvnWG0HnALy7eBnE4t1DAqCpfH0RoeZhX4rSDIPiCweKhsduv(u(bq39GKx2GtSVeJNctUIEafMdlvdFpsRkrzdhx8TWqGextQY)fMXTWCuuyYv0dOWSpHDIRPcZ(uZsfM14Hpv3PbX9uesV6qmF4i2FI5Vy4SiiVdlvd)kUov09yDlmk6wW2n6buy8RtkwGbPdB0QtmKbkgbcc2auIXGLQHVyCpblQWSpHvq6rfMdtvxJh(uDNgexjkB4CfFlmeiX1KQ8FHzClmhffMCf9akm7tyN4AQWSp1SuHznE4t1DAqCpfH0RoeZhoIXvfMfSdc2zHzn7jqcI3NTWobfM9jScspQWCyQ6A8WNQ70G4krzdNqX3cdbsCnPk)xyg3cZrrHjxrpGcZ(e2jUMkm7tnlvywJh(uDNge3tri9QdX(IJy8uywWoiyNfM9jStCn9ypQ6c7b2X2kCIm6bi2oXoxsRRrcrrX9omwy)Ha1lgONy(WrSnvy2NWki9OcZHPQRXdFQUtdIReLn(DfFlmeiX1KQ8FHjxrpGcZHLQHFvLGfvyu0TGTB0dOWW9eSiXuSWgGsmMTE4J(eBGIL4ZEsSadsh2OvVcZc2bb7SWSpHDIRP3HPQRXdFQUtdItSDI9Ty7tyN4A6DyQAGbPdB0kXqhDXWzrqE3wp8rF1bPQOmWEqYlBWjMpCeJN3FIHo6IDUKwxJeIII7DySW(dbQxmqpX8HJyBsSDITMrRg(G3T1dF0xDqQkkdShK8YgCI5Jy84iX(PeLn(LfFlmeiX1KQ8FHjxrpGcZHLQHFvLGfvyu0TGTB0dOW8pleigK8Yg0auIX9eSOtmCczGKybgjgsJcleJaQtSgrmMH7IXFaCledNedsPARynqSO9OxHzb7GGDwy2NWoX107Wu114Hpv3PbXj2oXqAuyrfsEzdoX(sS1mA1Wh8UTE4J(QdsvrzG9GKx2GReLOWGZ2AvX3Yg8u8TWqGextQY)fMfSdc2zHXzIfPMaXd0OWIls9hc(iqIRjLy7edYciKbIIErd2wJXH9QIRtf9iqIRjLy7e7CjTUgjeff37WyH9hcuVyGEI9LyoUWKROhqH5W69LOSXFfFlmeiX1KQ8FHzb7GGDwyoxsRRrcrrXjMpCe7pX2j23ITMrRg(G3rqygKQIpaQEU9h65LoSUWsik6eZbfBHLqu0vrG5k6bKAX8HJyo69NJfdD0f7CjTUgjeff37WyH9hcuVyGEI5JyBsSFkm5k6buyomwy)Ha1lgOxjkBWvfFlmeiX1KQ8FHzb7GGDwywZOvdFW7iimdsvXhavp3(d98shwxyjefDI5GITWsik6QiWCf9asTyFXrmh9(ZXIHo6IDdRgVbQNMsvfFBLCy65QPhbsCnPeBNyotmCweKNMsvfFBLCy65QPhRBHjxrpGcZrqygKQIpaQEU9hQeLn2uX3ctUIEafgu6z8W1PIkmeiX1KQ8FjkB44IVfMCf9akm456ZfjEHHajUMuL)lrjkrHzpbVEaLn(Zr)XJJCU)(Dfg(je0auxHzZ56B2goVn(9)MyI5lgjw75oWqmKbkg3UGsDGrkUjgKCGzBiPe7gpsSKngVmiLylSeGIUNG2V2asSn9BI53bSNGbPeJBqwaHmqu0Zp4MyXig3GSaczGOONF8iqIRjf3e7BEC4ppbTFTbKyoHFtm)oG9emiLyCdYciKbIIE(b3elgX4gKfqidef98JhbsCnP4MyFZJd)5jOjOT5C9nBdN3g)(FtmX8fJeR9ChyigYafJBUqAnE4zWnXGKdmBdjLy34rILSX4LbPeBHLau09e0(1gqIXv)My(Da7jyqkX42nSA8gOE(b3elgX42nSA8gOE(XJajUMuCtSV5XH)8e0(1gqIXv)My(Da7jyqkX42nSA8gOE(b3elgX42nSA8gOE(XJajUMuCtSme7x8x4xf7BEC4ppbTFTbKyoHFtm)oG9emiLyCdYciKbIIE(b3elgX4gKfqidef98JhbsCnP4Myzi2V4VWVk2384WFEcAcABoxFZ2W5TXV)3etmFXiXAp3bgIHmqX4gsd6dJBIbjhy2gskXUXJelzJXldsj2clbOO7jO9RnGeBt)My(Da7jyqkX4gKfqidef98dUjwmIXnilGqgik65hpcK4AsXnX(Mhh(ZtqtqBZ56B2goVn(9)MyI5lgjw75oWqmKbkg3wQJBIbjhy2gskXUXJelzJXldsj2clbOO7jO9RnGeJR(nX87a2tWGuIXnilGqgik65hCtSyeJBqwaHmqu0ZpEeiX1KIBI9npo8NNG2V2asSn9BI53bSNGbPeJBqwaHmqu0Zp4MyXig3GSaczGOONF8iqIRjf3e77)C4ppbTFTbKyo3VjMFhWEcgKsmUbzbeYarrp)GBIfJyCdYciKbIIE(XJajUMuCtSV5XH)8e0(1gqI9l)nX87a2tWGuIXnilGqgik65hCtSyeJBqwaHmqu0ZpEeiX1KIBI9npo8NNG2V2asmE4QFtm)oG9emiLyCdYciKbIIE(b3elgX4gKfqidef98JhbsCnP4MyFZJd)5jO9RnGeJhN73eZVdypbdsjg3UHvJ3a1Zp4MyXig3UHvJ3a1ZpEeiX1KIBI99Fo8NNGMG2MZ13SnCEB87)nXeZxmsS2ZDGHyidumUDbL6aRUuh3edsoWSnKuIDJhjwYgJxgKsSfwcqr3tq7xBaj2F)My(Da7jyqkX4gKfqidef98dUjwmIXnilGqgik65hpcK4AsXnXYqSFXFHFvSV5XH)8e0e02CU(MTHZBJF)VjMy(IrI1EUdmedzGIXnC2wR4MyqYbMTHKsSB8iXs2y8YGuITWsak6EcA)AdiX453eZVdypbdsjg3GSaczGOONFWnXIrmUbzbeYarrp)4rGextkUj2384WFEcAcAopp3bgKsmNGy5k6biMUV4EcAfgx4G0AQW4uNkgdlEOPyRyB2GILe0CQtfdnwaj2F)sEf7ph9hpcAcAo1PI5eN9Ky7tyN4A6XEu1f2dSJTv4ez0dqmwxXUrSoeRpXokedNqgijgFsm2JeRJNGMtDQy(D8WBajMhRoAxnj2k16AUIEavDFHyeiGnDIfJyqsXUiXCNGarNAXGe)b(5jOjO5uNkMtcjh0VJhEgcA5k6bCpxiTgp8m8Ndxsxx92Q703ae0Yv0d4EUqAnE4z4phUGprOjvfrNBjf)gGQgJdBGGwUIEa3ZfsRXdpd)5WfenDylyIe82iCUHvJ3a1ZL9cwnvjiRB0daD0VHvJ3a1B)OZO1u9g9EcecA5k6bCpxiTgp8m8NdxUGsDGjOLROhW9CH0A8WZWFoCXlHFivfzGvfLbgVUqAnE4zupAna1XHhhlOLROhW9CH0A8WZWFoC509IQjqvv9I41fsRXdpJ6rRbOoo8WBJWbsiq6WsCnjOLROhW9CH0A8WZWFoC5Ws1WVIRtfD82iCGSaczGOONxc)uhKAGrvV8ccwZ7Y7AGGMGMtDQyoXSbITztKrpabTCf9aooF61hbnNkgx7iLyXiMIcc61asm(yuGrqXwZOvdFWjg)SdXqgOymaUlgEEKsSbiwKquuCpbTCf9ao)5WL9jStCnXli9iohqvxdq1rpaE3NAwIdolcY709IQjqvv9IESUOJ(5sADnsikkU3HXc7peOEXa98HJZjO5uX8lgT(iMF5(jwgIH0Wle0Yv0d48NdxwPwxZv0dOQ7l4fKEeNL6e0CQyBglqmewTERyh)owy0jwmIfyKymbL6aJuITztKrpaX(gFRyQPbOe7gEfRdXqg4IoXCNr3auI1iIbMaRbOeRpXY9zRtCn9ZtqlxrpGZFoCbYcQ5k6bu19f8cspIZfuQdmsXBJW5ck1bgPEPwlO5uX46UU6TIXO7fjwcuIX9ErILHy)5Vy(1jftXcBakXcmsmKgEHy84iXoAna1XRyjsqqXcSmeBt(lMFDsXAeX6qmYHUnKoX43bwdelWiXaKddX(9(L7InqX6tmWeIX6kOLROhW5phUC6Er1eOQQEr82iCoxsRRrcrrX9omwy)Ha1lgO3xo3oKgfwuHKx2GZhNBholcY709IQjqvv9IEqYlBW9fQL65LoC3A8WNQ70G48HZMCWVJ2J(Ihh9JZ)pbnNk2VaqVvSfwcqrIbNiJEaI1iIXNedl3tI5c7b2X2kCIm6bi2rHyjqjMhRoAxnjwKquuCIX6(e0Yv0d48Ndx2NWoX1eVG0J4WEu1f2dSJTv4ez0dG39PML44c7b2X2kCIm6bS7CjTUgjeff37WyH9hcuVyGE(W5pbnNkMtc7b2XwX2SjYOhGdaI9RuWTtmu9EsSuSfmDflXh2qmcqquBfdzGIfyKyxqPoWeZVC)e7BC2wRiOyx0ATyq6CPviwh)8eZbqwxEfRdXwjqmCsSaldXU2ZvtpbTCf9ao)5WLvQ11Cf9aQ6(cEbPhX5ck1bwDPoEBeo7tyN4A6XEu1f2dSJTv4ez0dqqZPIX1osjwmIPiKgqIXhJaIfJyShj2fuQdmX8l3pXgOy4STwrWtqlxrpGZFoCzFc7ext8cspIZfuQdSAGbPdB0kE3NAwIZFo2)i1eiE7Bud8rGextkN)FoY)i1eiEE5feSoi1dlvd)7rGextkN)FoY)i1eiEhwQg(vKzXEpcK4As58)ZX(hPMaXl15c2X2hbsCnPC()5i))ZXo)VpxsRRrcrrX9omwy)Ha1lgONpC20pcAovm)oGRveum2RbOelfJjOuhyI5xUlgFmcigKYfwdqjwGrIracIARybgKoSrRe0Yv0d48NdxwPwxZv0dOQ7l4fKEeNlOuhy1L64Tr4qacIA7tri9QJV4SpHDIRP3fuQdSAGbPdB0kbTCf9ao)5WLvQ11Cf9aQ6(cEbPhXbPb9HXBJW5BcbHwrVNQRXdFQUtdIZhol3Qx6W65sa1pOJ(3RXdFQUtdI7PiKE1XxC4bD0rAuyrfsEzdUV4WZocbHwrVNQRXdFQUtdIZhoCf6OJZIG8UTE4J(QdsvrzGvt2ywWoESU7ieeAf9EQUgp8P6onioF4SPFqh9VpxsRRrcrrX9omwy)Ha1lgONpC20ocbHwrVNQRXdFQUtdIZhoB6hbnNkgx7iXsXWzBTIGIXhJaIbPCH1auIfyKyeGGO2kwGbPdB0kbTCf9ao)5WLvQ11Cf9aQ6(cEbPhXbNT1kEBeoeGGO2(uesV64lo7tyN4A6DbL6aRgyq6WgTsqZPI9RdF6cXCH9a7yRynqSuRfBqelWiX46o5VkgoTs2JeRdXwj7rNyPy)E)YDbTCf9ao)5WLeUsavJbcjqWBJWHaee12NIq6vh(WHhh7pbiiQTpiHIacA5k6bC(ZHljCLaQ6YQpsqlxrpGZFoCr3OWIR6aIvHYJaHGwUIEaN)C4cEIQoi1a2RpNGMGMtDQy)Z2AfbpbTCf9aUhoBRvCoSEpVnchNfPMaXd0OWIls9hc(iqIRj1oilGqgik6fnyBngh2RkUov0UZL06AKquuCVdJf2Fiq9Ib69LJf0Yv0d4E4STw5phUCySW(dbQxmqpEBeoNlP11iHOO48HZF7(EnJwn8bVJGWmivfFau9C7p0ZlDyDHLqu05GlSeIIUkcmxrpGu7dhh9(ZXOJ(5sADnsikkU3HXc7peOEXa98zt)iOLROhW9WzBTYFoC5iimdsvXhavp3(dXBJWznJwn8bVJGWmivfFau9C7p0ZlDyDHLqu05GlSeIIUkcmxrpGu)fhh9(ZXOJ(nSA8gOEAkvv8TvYHPNRMEeiX1KANZWzrqEAkvv8TvYHPNRMESUcA5k6bCpC2wR8NdxqPNXdxNksqlxrpG7HZ2AL)C4cEU(CrIlOjO5uNkMFNrRg(GtqZPIX1osmUNGfj2GG4GOwkXWjKbsIfyKyin8cXomwy)Ha1lgONyiWXtmFhiivJyRXJoXAWtqlxrpG7TuhNdlvd)QkblIx2JQdcsf1sXHhEBeoodNfb5DyPA4xvjyrpw3D4SiiVdJf2FiqngiivZJ1DholcY7WyH9hcuJbcs18GKx2G7loC1ZXcAovSV5AanDNyPgsPARySUIHtRK9iX4tIfZ8rmgSun8fZpNf79JyShjgZwp8rFIniioiQLsmCczGKybgjgsdVqmgmwy)HaIXed0tme44jMVdeKQrS14rNyn4jOLROhW9wQZFoC526Hp6RoivfLbgVShvheKkQLIdp82iCWzrqEhglS)qGAmqqQMhR7oCweK3HXc7peOgdeKQ5bjVSb3xC4QNJf0Yv0d4El15phUGOtuKwNrpaEBeo7tyN4A6DavDnavh9a25SlOuhyK65LGqt7(2zqwaHmqu0BWjvtGfHo6Rz0QHp4DB9Wh9vhKQIYa7X6UBnE4t1DAqC(WXX)iOLROhW9wQZFoCzFc6dJ3gHZ3qwaHmqu0ZlHFQdsnWOQxEbbR5D5Dny3A8WNQ70G4EkcPxD8fhECWi1eiEkICjy9cygekY7rGextk0rhYciKbIIEkkdm926HLQH)TBnE4t1DAqCFXZp7WzrqE3wp8rF1bPQOmWESU7WzrqEhwQg(vvcw0J1DNxEbbR5D5DnOcjVSbhhhTdNfb5POmW0BRhwQg(3tn8bcAovmNCgTyidumFhiivJyUqYbzgUlg)oWeJbJ7IbPuTvm(yeqmWeIbzbGgGsmg)8jOLROhW9wQZFoCXDgDfs3WcxeVidScihgC4H3gHtKAceVdJf2FiqngiivZJajUMu7CwKAceVdlvd)kYSyVhbsCnPe0CQyCTJeZ3bcs1iMlKeJz4Uy8XiGy8jXWY9KybgjgbiiQTIXhJcmckgcC8eZDgDdqjg)oWg2qmg)uSbkMdi2ledfbiyQ1BFcA5k6bCVL68Ndxomwy)Ha1yGGun82iCiabrT1hooNJ2TpHDIRP3bu11auD0dy3AgTA4dE3wp8rF1bPQOmWESU7wZOvdFW7Ws1WVQsWIElSeIIoF4WZUVDgKfqidef9gCs1eyrOJUIWzrqEi6efP1z0d4X6(ZU14Hpv3PbX9fN)e0Yv0d4El15phUCeeMbPQ4dGQNB)H4DTDPPAKquuCC4H3gHZ(e2jUMEhqvxdq1rpGDotnX7iimdsvXhavp3(dvvt8IE9PbO2fjeffVO9OAmvvt(W5pEqhDKgfwuHKx2G7looE35sADnsikkU3HXc7peOEXa9(IRe0Yv0d4El15phUCK71hVncN9jStCn9oGQUgGQJEa7wJh(uDNge3tri9QdF4WJGMtfJRDKymB9Wh9j2aeBnJwn8bI9DIeeumKgEHymaU)JySanDNy8jXsijgQPbOelgXChxX8DGGunILaLyQrmWeIHL7jXyWs1Wxm)CwS3tqlxrpG7TuN)C4YT1dF0xDqQkkdmEBeo7tyN4A6DavDnavh9a29DKAcepcSN0JBdqvpSun8VhbsCnPqh91mA1Wh8oSun8RQeSO3clHOOZho88ZUVDwKAceVdJf2FiqngiivZJajUMuOJEKAceVdlvd)kYSyVhbsCnPqh91mA1Wh8omwy)Ha1yGGunpi5Ln485VF29TZGSaczGOO3GtQMalcD0xZOvdFWdrNOiToJEapi5Ln485ph9JGMtfZ5HiwQuNyjKeJ1LxXoq7sIfyKydGeJFhyIPh(0fI5RVC)jgx7iX4JraXuBBakXqYliOybwceZVoPykcPxDi2afdmHyxqPoWiLy87aBydXsWwX8Rt(e0Yv0d4El15phU4LWpKQImWQIYaJxDdO6sXHNNJ5DTDPPAKquuCC4H3gHdmBvL2tG4Lk19yD39DKquu8I2JQXuvn91A8WNQ70G4EkcPxDGo6o7ck1bgPEPwVBnE4t1DAqCpfH0Ro8HZYT6LoSEUeq9JGMtfZ5HigyelvQtm(TwlMQjX43bwdelWiXaKddX4khD8kg7rI5er4Uydqm85oX43b2WgILGTI5xN8jOLROhW9wQZFoCXlHFivfzGvfLbgVnchy2QkTNaXlvQ71aF4kh5GWSvvApbIxQu3tXcZOhWU14Hpv3PbX9uesV6Whol3Qx6W65saLGwUIEa3BPo)5WLdlvd)kUov0XBJWzFc7extVdOQRbO6OhWU14Hpv3PbX9uesV6Who)T771mA1Wh8UTE4J(QdsvrzG9GKx2G7lEqhDCweK3T1dF0xDqQkkdShRl6OJ0OWIkK8YgCFX5ph9JGwUIEa3BPo)5WfAHnnavfsUW2lbkEBeo7tyN4A6DavDnavh9a2Tgp8P6oniUNIq6vh(W5VDFVpHDIRPh7rvxypWo2wHtKrpa0r)CjTUgjeff37WyH9hcuVyGEFXztOJoKfqidef9G0nSavdqvx6e2X2Fe0CQyBEhyIX4N8kwJigycXsnKs1wXudG4vm2JeZ3bcs1ig)oWeJz4UySUpbTCf9aU3sD(ZHlhglS)qGAmqqQgEBeorQjq8oSun8RiZI9EeiX1KA3(e2jUMEhqvxdq1rpGD4SiiVBRh(OV6Guvugypw3DRXdFQUtdI7lo)jOLROhW9wQZFoC5Ws1WVQsWI4Tr44mCweK3HLQHFvLGf9yD3H0OWIkK8YgCFX535FKAceVJfpiiclk6rGextkbTCf9aU3sD(ZHliA6WwWej4Tr489nSA8gOEUSxWQPkbzDJEaOJ(nSA8gOE7hDgTMQ3O3tG4NDeGGO2(uesV6WhoCLJ25SlOuhyK6LA9oCweK3T1dF0xDqQkkdSNA4de0Yv0d4El15phU4orpaEBeo4SiipC9mkn7fpiLRaD0rAuyrfsEzdUV4khHo64SiiVBRh(OV6Guvugypw3DFJZIG8oSun8R46ur3J1fD0xZOvdFW7Ws1WVIRtfDpi5Ln4(Idpo6hbTCf9aU3sD(ZHl46zuvew4wEBeo4SiiVBRh(OV6GuvugypwxbTCf9aU3sD(ZHl4e8i4NgGI3gHdolcY726Hp6RoivfLb2J1vqlxrpG7TuN)C4csdjC9mkEBeo4SiiVBRh(OV6GuvugypwxbTCf9aU3sD(ZHljyrxatDDLAnVnchCweK3T1dF0xDqQkkdShRRGMtfJ7esYQdXqsTgpxFedzGIXEjUMeRdY7(nX4Ahjg)oWeJzRh(OpXgeX4oLb2tqlxrpG7TuN)C4c7r1oiVJ3gHdolcY726Hp6RoivfLb2J1fD0rAuyrfsEzdUV(ZrcAcAo1PI5NnOpmcEcAovSnhR1KySxdqjMtcjps1rg9a4vSC)0kXw5fnaLym6ErILaLyCVxKy8XiGymyPA4lg3tWIeRpXUzaIfJy4KyShP4vmYHlYnedzGI5aClStGGwUIEa3dPb9HXzFc7ext8cspIJlK8iv9aQ6AaQo6bW7(uZsCIutG45cjps1rg9aEeiX1KA35sADnsikkU3HXc7peOEXa9(6Bh7GRzpbsq8a0co6bQ(zNZwZEcKG49zlStGGwUIEa3dPb9H5phUC6Er1eOQQEr82iCC2(e2jUMEUqYJu1dOQRbO6OhWUZL06AKquuCVdJf2Fiq9Ib69LZTZz4SiiVdlvd)Qkbl6X6UdNfb5D6Er1eOQQErpi5Ln4(cPrHfvi5Ln42bjeiDyjUMe0Yv0d4EinOpm)5WLt3lQMavv1lI3gHZ(e2jUMEUqYJu1dOQRbO6OhWU1mA1Wh8oSun8RQeSO3clHOORIaZv0di1FXZZj44D4SiiVt3lQMavv1l6bjVSb3xRz0QHp4DB9Wh9vhKQIYa7bjVSb3UVxZOvdFW7Ws1WVQsWIEqkvB3HZIG8UTE4J(QdsvrzG9GKx2GZbXzrqEhwQg(vvcw0dsEzdUV4593pcAovmhWK2LGI5aLWoX1KyiduSnJ1nyH0tmMpTRykwydqjMtmVGGIX1VlVRbInqXuSWgGsmUNGfjg)oWeJ7j8JyjqjgyeBJgfwCrQ)qWNGwUIEa3dPb9H5phUSpHDIRjEbPhX5(0UviRBWcjE3NAwIJxEbbR5D5DnOcjVSbNpocD0DwKAcepqJclUi1Fi4JajUMu7IutG4Ps4N6HLQH)JajUMu7WzrqEhwQg(vvcw0J1fD0pxsRRrcrrX9omwy)Ha1lgONpC(2XoiKfqidef9qAqQ7y7pcAovmhGe5kgRRyBgRBWcjXAeX6qS(elXh2qSyedYceByJNGwUIEa3dPb9H5phUazDdwiXBJW5BNTpHDIRP39PDRqw3GfsOJ((e2jUMEShvDH9a7yBforg9a(zxKquu8I2JQXuvn5GqYlBW5JZTdsiq6WsCnjOLROhW9qAqFy(ZHlhTGuudAHbAhywsqZPI5ez1rRMiAakXIeIIItSaldX43ATy6EpjgYaflWiXuSWm6bi2Gi2MX6gSqIxXGecKomXuSWgGsm3eOiVE9e0Yv0d4EinOpm)5WfiRBWcjExBxAQgjeffhhE4Tr44S9jStCn9UpTBfY6gSqANZ2NWoX10J9OQlShyhBRWjYOhWUZL06AKquuCVdJf2Fiq9Ib65dN)2fjeffVO9OAmvvt(W5Bh7)3)58xJh(uDNge3p)Sdsiq6WsCnjO5uX2mcbshMyBgRBWcjXOeQ3kwJiwhIXV1AXih62qsmflSbOeJzRh(OVNyCFelWYqmiHaPdtSgrmMH7IHIItmiLQTI1aXcmsma5WqmhFpbTCf9aUhsd6dZFoCbY6gSqI3gHJZ2NWoX107(0UviRBWcPDqYlBW91AgTA4dE3wp8rF1bPQOmWEqYlBW5ppoA3AgTA4dE3wp8rF1bPQOmWEqYlBW9fhhVlsikkEr7r1yQQMCqi5Ln48znJwn8bVBRh(OV6Guvugypi5Ln483XcA5k6bCpKg0hM)C4cUoxFQUdFfb5Tr44S9jStCn9ypQ6c7b2X2kCIm6bS7CjTUgjeffNpC4kbTCf9aUhsd6dZFoCH233IGzqcAcAo1PIXeuQdmX87mA1WhCcAovmhWK2LGI5aLWoX1KGwUIEa37ck1bwDPoo7tyN4AIxq6rComvnWG0HnAfV7tnlXznJwn8bVdlvd)Qkbl6TWsik6QiWCf9asTpC455eCSGMtfZbkb9HjwJigFsSesITsx3gGsSbig3tWIeBHLqu09e7xmH6TIHtidKedPHxiMkblsSgrm(Kyy5EsmWi2gnkS4Iu)HGIHZgIX9e(rmgSun8fRbInqfbflgXqrHyBgRBWcjXyDf7BWiMtmVGGIX1VlVRb)8e0Yv0d4ExqPoWQl15phUSpb9HXBJW5BNTpHDIRP3HPQbgKoSrRqhDNfPMaXd0OWIls9hc(iqIRj1Ui1eiEQe(PEyPA4)iqIRj1p7wJh(uDNge3tri9QdF4zNZGSaczGOONxc)uhKAGrvV8ccwZ7Y7AGGMtfZjNrlgYafJblvdFpsReZFXyWs1W)cy)HeJfOP7eJpjwcjXs8HnelgXwPRydqmUNGfj2clHOO7j2VaqVvm(yeqm)SbkX2Ck)aO7eRpXs8HnelgXGSaXg24jOLROhW9UGsDGvxQZFoCXDgDfs3WcxeVidScihgC4HxYHbmRP3WccoBYr82iCG5IEGgfwujnIGwUIEa37ck1bwDPo)5WLdlvdFpsR4Tr4qacIARpC2KJ2racIA7tri9QdF4WJJ25S9jStCn9omvnWG0HnA1U14Hpv3PbX9uesV6WhE2PiCweKhsduv(u(bq39GKx2G7lEe0CQy(1jflWG0HnA1jgYafJabbBakXyWs1WxmUNGfjOLROhW9UGsDGvxQZFoCzFc7ext8cspIZHPQRXdFQUtdIJ39PML4Sgp8P6oniUNIq6vh(W5p)XzrqEhwQg(vCDQO7X6kOLROhW9UGsDGvxQZFoCzFc7ext8cspIZHPQRXdFQUtdIJ39PML4Sgp8P6oniUNIq6vh(WHR4Tr4SM9eibX7ZwyNabTCf9aU3fuQdS6sD(ZHl7tyN4AIxq6rComvDnE4t1DAqC8Up1SeN14Hpv3PbX9uesV64lo8WBJWzFc7extp2JQUWEGDSTcNiJEa7oxsRRrcrrX9omwy)Ha1lgONpC2KGMtfJ7jyrIPyHnaLymB9Wh9j2aflXN9KybgKoSrREcA5k6bCVlOuhy1L68NdxoSun8RQeSiEBeo7tyN4A6DyQ6A8WNQ70G4299(e2jUMEhMQgyq6WgTcD0XzrqE3wp8rF1bPQOmWEqYlBW5dhEE)Ho6NlP11iHOO4EhglS)qG6fd0ZhoBA3AgTA4dE3wp8rF1bPQOmWEqYlBW5dpo6hbnNk2)SqGyqYlBqdqjg3tWIoXWjKbsIfyKyinkSqmcOoXAeXygUlg)bWTqmCsmiLQTI1aXI2JEcA5k6bCVlOuhy1L68NdxoSun8RQeSiEBeo7tyN4A6DyQ6A8WNQ70G42H0OWIkK8YgCFTMrRg(G3T1dF0xDqQkkdShK8YgCcAcAo1PIXeuQdmsj2Mnrg9ae0CQyopeXyck1bgx2NG(WelHKySU8kg7rIXGLQH)fW(djwmIHtacPdXqGJNybgjMBExVNedFaSNyjqjMF2aLyBoLFa0D8kgTNaI1iIXNelHKyziMx6qX8Rtk23SanDNySxdqjMtmVGGIX1VlVRb)iOLROhW9UGsDGrkohwQg(xa7peVncNVXzrqExqPoWESUOJoolcYBFc6d7X6(ZoV8ccwZ7Y7AqfsEzdooosqZPI5NnOpmXYqmUYFX8Rtkg)oWg2qmUZigxeBt(lg)oWeJ7mIXVdmXyWyH9hciMVdeKQrmCweeXyDflgXY9tRe7gpsm)6KIXpVGe76GnJEa3tqZPIX113i2LiKyXigsd6dtSmeBt(lMFDsX43bMyKdZvO3k2MelsikkUNyFZKEKy5j2WgxRiXUGsDG9(rqZPI5NnOpmXYqSn5Vy(1jfJFhydBig3z4vmh7Vy87atmUZWRyjqjMZjg)oWeJ7mILibbfZbkb9HjOLROhW9UGsDGrk)5WLvQ11Cf9aQ6(cEbPhXbPb9HXBJWHqqOv07P6A8WNQ70G48HZYT6LoSEUeqHo64SiiVdJf2FiqngiivZJ1D3A8WNQ70G4EkcPxD8fN)qh9ZL06AKquuCVdJf2Fiq9Ib65dNnTJqqOv07P6A8WNQ70G48HZMqh914Hpv3PbX9uesV64lo84GFhPMaXtrKlbRxaZirrEpcK4AsTdNfb5Tpb9H9yD)rqlxrpG7DbL6aJu(ZHlhwQg(xa7peVncNlOuhyK6DK713UZL06AKquuCVdJf2Fiq9Ib691Me0Yv0d4ExqPoWiL)C4YH175Tr4ePMaXd0OWIls9hc(iqIRj1oilGqgik6fnyBngh2RkUov0UZL06AKquuCVdJf2Fiq9Ib69LJf0CQyCnxXIrmUsSiHOO4e7BWiMlSNFe7drUIX6kMF2aLyBoLFa0DIHVvS12LUbOeJblvd)lG9h6jOLROhW9UGsDGrk)5WLdlvd)lG9hI312LMQrcrrXXHhEBeooBFc7extp2JQUWEGDSTcNiJEa7ueolcYdPbQkFk)aO7EqYlBW9fp7oxsRRrcrrX9omwy)Ha1lgO3xC4QDrcrrXlApQgtv1KdcjVSbNpoNGMtfZphOyUWEGDSvm4ez0dGxXypsmgSun8Va2FiXM9eumMyGEIXVdmX2CNOyjQSbxigRRyXi2MelsikkoXgOynIy(5MlwFIbzbGgGsSbbrSVhGyjyRyP3WccXgeXIeIII7hbTCf9aU3fuQdms5phUCyPA4FbS)q82iC2NWoX10J9OQlShyhBRWjYOhWUVveolcYdPbQkFk)aO7EqYlBW9fpOJEKAcep(u6oaV8cc(iqIRj1UZL06AKquuCVdJf2Fiq9Ib69fNn9JGwUIEa37ck1bgP8Ndxomwy)Ha1lgOhVncNZL06AKquuC(WHR8)BCweKxGrv4ebbESUOJoKfqidef9Ypzc7REdRUIatuEei(z334SiiVBRh(OV6Guvugy1KnMfSJhRl6O7mCweKNlK8ivhz0d4X6Io6NlP11iHOO48HJJ)rqZPIXGLQH)fW(djwmIbjeiDyI5Nnqj2Mt5haDNyjqjwmIrGJfsIXNeBLaXwjeUvSzpbflfdHvRfZp3CXAqmIfyKyaYHHymd3fRreZDURX10tqlxrpG7DbL6aJu(ZHlhwQg(xa7peVnchfHZIG8qAGQYNYpa6UhK8YgCFXHh0rFnJwn8bVBRh(OV6Guvugypi5Ln4(INF3ofHZIG8qAGQYNYpa6UhK8YgCFTMrRg(G3T1dF0xDqQkkdShK8YgCcA5k6bCVlOuhyKYFoCbLEgpCDQiEBeo4SiipxcImWmivDp1G7DrU(4dhhVBnafBhpxcImWmivDp1G7btWhF4WdxjOLROhW9UGsDGrk)5WLdlvd)lG9hsqlxrpG7DbL6aJu(ZHllmkDRh2e82iCCwKquu86RIp3TBnE4t1DAqCpfH0Ro8Hdp7WzrqEh2e1gudmQQs4NhR7ocqquBFr7r1yQBYr(GAPEEPdlmNlTkB8NZXtjkrPa]] )

    
end
