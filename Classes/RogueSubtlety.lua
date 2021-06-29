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


    spec:RegisterPack( "Subtlety", 20210628, [[daLJ5bqiQk8isvAtkv(eQunkvvCkvvAvkffVIQQMfQs3IuH2LQ8livggPsogQILPQupdsvMgvfDnsvSnsvX3ivknosvPohPcQ1PQkzEQk5EOI9rvL)bPQehesv1cvvvpuPitevkxuPOuBKuv5JqQkgjPcOtsQkzLqkVesvPMPQQOBsQuStLc)uPOKHsQuTusvvpfQMkvLUQQQuBLub6RkfvJvvv4SqQkP9kXFL0GPCyrlgfpwjtMKlJSzi(mKmAOCAPwnPcWRvQA2u52uLDd8BfdNuooPcYYb9CvMUW1rPTRQ47OQgpPIoVsP5Jkz)ex4P4BbxLbv24BD9np6sF(wF)(g98538Opf8yRgvW1Y1(efvWbPhvWXzzchfBl4A5w3KQIVf8ByHlQGJfH29xOdDO6aJL5Tgp0DThRlJEalyIeO7AVf6k4mSTl0xGctbxLbv24BD9np6sF(wF)(g985388DbpzdSbwWXBVnvWXALIafMcUIUvbhNLjCuSvm9FqXscAOXciX(wFZRyFRRV5rqtqt3mFiX(KWozC0J9OQgShyhBRWjYOhGySAIDJyDiwFIDuigdHmqsm(KyShjwhpbTnnEmnGeZJ1fTMJeBLoxnxrpGQRVqmceWMoXIrmiPyxKyAtqGOtNyqI)a3)k4U(IR4Bb)ckDbgPk(w2GNIVfCcKmosv(VGNROhqb)Ws1W)cyVNk4k6wWwl6buW1xiIHhu6cm09jb9HjwcjXy14vm2Jedhlvd)lG9EsSyeJHaeshIHahpXcmsmT8U(djgZaypXsGsm9RbkX2Ck3dO74vm6dbeRreJpjwcjXYqmVuNITjDxSFybo6oXyVgGsmDtEbbfd9FxExd(TGVGDqWol4)igdlcY7ckDb2JvtmU4smgweK3Ne0h2JvtSFfBNyE5feSM3L31GkK8YgCIXrmDvIYgFx8TGtGKXrQY)fCfDlyRf9ak46xd6dtSmeZN(l2M0DX43b2WgIXnCEftp(lg)oWeJB48kwcuIPpIXVdmX4gUyjsqqX0btqFyf8Cf9ak4R05Q5k6buD9ff8fSdc2zbNqqOv0FO6A8yMQ20G4eZpoIT0QEPoRNgbuIXfxIXWIG8omwyVNa1yGGunpwnX2j2A8yMQ20G4EkcPxDi2xCe7BX4IlXonY5QrcrrX9omwyVNa1lgONy(XrmFk2oXieeAf9hQUgpMPQnnioX8JJy(umU4sS14XmvTPbX9uesV6qSV4igpIPJI9Jyr6iq8uePrW6fWmsuK3JajJJuITtmgweK3Ne0h2JvtSFl4U(Iki9Ocosd6dReLnqVIVfCcKmosv(VGVGDqWol4xqPlWi17iTRpX2j2ProxnsikkU3HXc79eOEXa9e7lX8zbpxrpGc(HLQH)fWEpvIYg(S4BbNajJJuL)l4lyheSZcEKocepqJclUiD7j4JajJJuITtmilGqgik6fnyBngD2RkJlv0JajJJuITtStJCUAKquuCVdJf27jq9Ib6j2xIPNcEUIEaf8dR)uIYg6P4BbNajJJuL)l45k6buWpSun8Va27Pc(A7Yr1iHOO4kBWtbFb7GGDwW9HyFsyNmo6XEuvd2dSJTv4ez0dqSDIPigweKhsduv(uUhq39GKx2GtSVeJhX2j2ProxnsikkU3HXc79eOEXa9e7loIHEITtSiHOO4fThvJPQAsmDumi5Ln4eZpX0NcUIUfS1IEaf8)wtSyed9elsikkoX(bmIPb75xX2tKMySAIPFnqj2Mt5EaDNymBfBTD5AakXWXs1W)cyVNELOSH(u8TGtGKXrQY)f8Cf9ak4hwQg(xa79ubxr3c2ArpGcU(nqX0G9a7yRyWjYOhaVIXEKy4yPA4FbS3tInFiOy4Xa9eJFhyIT56gXsuzdUqmwnXIrmFkwKquuCInqXAeX0VnxS(edYcanaLydcIy)maXsWwXsVHfeIniIfjeff3Vf8fSdc2zb)tc7KXrp2JQAWEGDSTcNiJEaITtSFetrmSiipKgOQ8PCpGU7bjVSbNyFjgpIXfxIfPJaXJpLAdWlVGGpcKmosj2oXonY5QrcrrX9omwyVNa1lgONyFXrmFk2VLOSHUT4BbNajJJuL)l4lyheSZc(ProxnsikkoX8JJyONy(l2pIXWIG8cmQcNiiWJvtmU4smilGqgik6L7Ze2x9gwxfbMO8iq8iqY4iLy)k2oX(rmgweK3T1JzCxDqQkkdSAYgZc2XJvtmU4smFigdlcYtdsEKQJm6b8y1eJlUe70iNRgjeffNy(Xrm9i2Vf8Cf9ak4hglS3tG6fd0ReLn03fFl4eizCKQ8FbpxrpGc(HLQH)fWEpvWv0TGTw0dOGJJLQH)fWEpjwmIbjeiDyIPFnqj2Mt5EaDNyjqjwmIrGJfsIXNeBLaXwjeUvS5dbflfdH15et)2CXAqmIfyKyasNHy4d3eRretBURzC0RGVGDqWol4kIHfb5H0avLpL7b0Dpi5Ln4e7loIXJyCXLyRzCQHp4DB9yg3vhKQIYa7bjVSbNyFjgp6BX2jMIyyrqEinqv5t5EaD3dsEzdoX(sS1mo1Wh8UTEmJ7QdsvrzG9GKx2GReLn0Hl(wWjqY4iv5)c(c2bb7SGZWIG80iiYaZGu1pudU3f5AVy(Xrm9i2oXwdqX2XtJGidmdsv)qn4EWeSxm)4igpOxbpxrpGcok3mEmUurLOSbp6Q4BbpxrpGc(HLQH)fWEpvWjqY4iv5)su2GhEk(wWjqY4iv5)c(c2bb7SG7dXIeIIIxFvM5oX2j2A8yMQ20G4EkcPxDiMFCeJhX2jgdlcY7WMO2GAGrvvc3)y1eBNyeGGO2(I2JQXu9PUeZpXqTupVuNf8Cf9ak4lmk1Qh2eLOefCfHKSUO4BzdEk(wWZv0dOGVVx7l4eizCKQ8FjkB8DX3cobsghPk)xWhTc(rrbpxrpGc(Ne2jJJk4FshlvWzyrqENRxunbQQQx0JvtmU4sStJCUAKquuCVdJf27jq9Ib6jMFCetFk4k6wWwl6buW)7JuIfJykkiOxdiX4JrbgbfBnJtn8bNy8ZoedzGIHd4Mym5rkXgGyrcrrX9k4FsyfKEub)aQ6AaQo6buIYgOxX3cobsghPk)xWv0TGTw0dOGVjmATxSnXTtSmedPHxuWZv0dOGVsNRMROhq11xuWD9fvq6rf8L6krzdFw8TGtGKXrQY)fCfDlyRf9ak46plqmewNBRyh)owy0jwmIfyKy4bLUaJuIP)tKrpaX(HzRyQPbOe7gEfRdXqg4IoX0MX1auI1iIbMaRbOeRpXYpz7sgh97RGNROhqbhYcQ5k6buD9ff8fSdc2zb)ckDbgPEPZvWD9fvq6rf8lO0fyKQeLn0tX3cobsghPk)xWZv0dOGFUEr1eOQQErfCfDlyRf9ak4OFnn3wXWD9IelbkX4wViXYqSV9xSnP7IPyHnaLybgjgsdVqmE0LyhTgG64vSejiOybwgI5t)fBt6UynIyDigPtTgsNy87aRbIfyKyasNHyOpBIBInqX6tmWeIXQvWxWoiyNf8tJCUAKquuCVdJf27jq9Ib6j2xIPpITtmKgfwuHKx2Gtm)etFeBNymSiiVZ1lQMavv1l6bjVSbNyFjgQL65L6uSDITgpMPQnnioX8JJy(umDuSFelApsSVeJhDj2VITze77su2qFk(wWjqY4iv5)c(OvWpkk45k6buW)KWozCub)t6yPcUgShyhBRWjYOhGy7e70iNRgjeff37WyH9EcuVyGEI5hhX(UGROBbBTOhqbFZc42k2clbOiXGtKrpaXAeX4tIHLFiX0G9a7yBforg9ae7OqSeOeZJ1fTMJelsikkoXy1Ef8pjScspQGZEuvd2dSJTv4ez0dOeLn0TfFl4eizCKQ8Fbxr3c2ArpGcUUd7b2XwX0)jYOha6lI9NuW9tmu9hsSuSfm1elzg2qmcqquBfdzGIfyKyxqPlWeBtC7e7hg22PiOyx0oNyq60Oviwh)(ed9vwnEfRdXwjqmgsSaldXU2tZrVcEUIEaf8v6C1Cf9aQU(Ic(c2bb7SG)jHDY4Oh7rvnypWo2wHtKrpGcURVOcspQGFbLUaRUuxjkBOVl(wWjqY4iv5)c(OvWpkk45k6buW)KWozCub)t6yPc(36rm)flshbI3Ng1aFeizCKsSnJyFRlX8xSiDeiEE5feSoi1dlvd)7rGKXrkX2mI9TUeZFXI0rG4DyPA4xrMf79iqY4iLyBgX(wpI5Vyr6iq8sxUGDS9rGKXrkX2mI9TUeZFX(wpITze7hXonY5QrcrrX9omwyVNa1lgONy(XrmFk2VfCfDlyRf9ak4)9rkXIrmfH0asm(yeqSyeJ9iXUGsxGj2M42j2afJHTDkcEf8pjScspQGFbLUaRgyq6WgNQeLn0Hl(wWjqY4iv5)cUIUfS1IEaf8nnGRveum2RbOelfdpO0fyITjUjgFmcigKYfwdqjwGrIracIARybgKoSXPk45k6buWxPZvZv0dO66lk4lyheSZcobiiQTpfH0Roe7loI9jHDY4O3fu6cSAGbPdBCQcURVOcspQGFbLUaRUuxjkBWJUk(wWjqY4iv5)c(c2bb7SG)JyeccTI(dvxJhZu1MgeNy(XrSLw1l1z90iGsSFfJlUe7hXwJhZu1Mge3tri9QdX(IJy8igxCjgsJclQqYlBWj2xCeJhX2jgHGqRO)q114XmvTPbXjMFCed9eJlUeJHfb5DB9yg3vhKQIYaRMSXSGD8y1eBNyeccTI(dvxJhZu1MgeNy(XrmFk2VIXfxI9JyNg5C1iHOO4EhglS3tG6fd0tm)4iMpfBNyeccTI(dvxJhZu1MgeNy(XrmFk2Vf8Cf9ak4R05Q5k6buD9ffCxFrfKEubhPb9HvIYg8WtX3cobsghPk)xWv0TGTw0dOG)3hjwkgdB7ueum(yeqmiLlSgGsSaJeJaee1wXcmiDyJtvWZv0dOGVsNRMROhq11xuWxWoiyNfCcqquBFkcPxDi2xCe7tc7KXrVlO0fy1adsh24ufCxFrfKEubNHTDQsu2GNVl(wWjqY4iv5)cEUIEaf8eUsavJbcjquWv0TGTw0dOG)NdF6cX0G9a7yRynqS05eBqelWiXq)6(FkgdTs2JeRdXwj7rNyPyOpBIBf8fSdc2zbNaee12NIq6vhI5hhX4rpI5VyeGGO2(GekcuIYg8GEfFl45k6buWt4kbuvJ1DubNajJJuL)lrzdE8zX3cEUIEafCxJclUQoawfkpcefCcKmosv(VeLn4rpfFl45k6buWzsu1bPgWET)k4eizCKQ8FjkrbxdsRXJjJIVLn4P4BbpxrpGcEQP52w1M(gqbNajJJuL)lrzJVl(wWZv0dOGZmr4ivfXLBjf)gGQgJoBqbNajJJuL)lrzd0R4BbNajJJuL)l4lyheSZc(nSoMgOEASxW6Okbz1IEapcKmosvWZv0dOGJ4OdBbtKOeLn8zX3cEUIEaf8lO0fyfCcKmosv(VeLn0tX3cobsghPk)xWZv0dOG7LW9KQImWQIYaRGRbP14XKr9O1auxbNh9uIYg6tX3cobsghPk)xWZv0dOGFUEr1eOQQErf8fSdc2zbhsiq6WsghvW1G0A8yYOE0AaQRGZtjkBOBl(wWjqY4iv5)c(c2bb7SGdzbeYarrpVeUVoi1aJQE5feSM3L31GhbsghPk45k6buWpSun8RmUurxjkrbhPb9Hv8TSbpfFl4eizCKQ8FbF0k4hff8Cf9ak4FsyNmoQG)jDSubpshbINgK8ivhz0d4rGKXrkX2j2ProxnsikkU3HXc79eOEXa9e7lX(rm9iMok2A(qGeepaTGJBGkX(vSDI5dXwZhcKG4TFlStqbxr3c2ArpGc(MJ1osm2RbOet3HKhP6iJEa8kw(zALyR8IgGsmCxViXsGsmU1lsm(yeqmCSun8fJBjyrI1Ny3maXIrmgsm2Ju8kgPZfPfIHmqXqFVf2jOG)jHvq6rfCni5rQ6bu11auD0dOeLn(U4BbNajJJuL)l4lyheSZcUpe7tc7KXrpni5rQ6bu11auD0dqSDIDAKZvJeIII7DySWEpbQxmqpX(sm9rSDI5dXyyrqEhwQg(vvcw0JvtSDIXWIG8oxVOAcuvvVOhK8YgCI9LyinkSOcjVSbNy7edsiq6WsghvWZv0dOGFUEr1eOQQErLOSb6v8TGtGKXrQY)f8fSdc2zb)tc7KXrpni5rQ6bu11auD0dqSDITMXPg(G3HLQHFvLGf9wyjefDveyUIEaPtSVeJNNUvpITtmgweK356fvtGQQ6f9GKx2GtSVeBnJtn8bVBRhZ4U6Guvugypi5Ln4eBNy)i2AgNA4dEhwQg(vvcw0dsPARy7eJHfb5DB9yg3vhKQIYa7bjVSbNy6OymSiiVdlvd)Qkbl6bjVSbNyFjgpVVf73cEUIEaf8Z1lQMavv1lQeLn8zX3cobsghPk)xWhTc(rrbpxrpGc(Ne2jJJk4FshlvW9YliynVlVRbvi5Ln4eZpX0LyCXLy(qSiDeiEGgfwCr62tWhbsghPeBNyr6iq8ujCF9Ws1W)rGKXrkX2jgdlcY7Ws1WVQsWIESAIXfxIDAKZvJeIII7DySWEpbQxmqpX8JJy)iMEethfdYciKbIIEiniDDS9rGKXrkX(TGROBbBTOhqbxhi50iOy6GjStghjgYaft)z1cwi9edFFRjMIf2auIPBYliOyO)7Y7AGydumflSbOeJBjyrIXVdmX4wc3lwcuIbgX2OrHfxKU9e8vW)KWki9Oc(TV1QqwTGfsLOSHEk(wWjqY4iv5)cEUIEafCiRwWcPcUIUfS1IEafC03ePjgRMy6pRwWcjXAeX6qS(elzg2qSyedYceByJxbFb7GGDwW)rmFi2Ne2jJJE3(wRcz1cwijgxCj2Ne2jJJEShv1G9a7yBforg9ae7xX2jwKquu8I2JQXuvnjMokgK8YgCI5Ny6Jy7edsiq6WsghvIYg6tX3cEUIEaf8JwqkQbTWaToelvWjqY4iv5)su2q3w8TGtGKXrQY)f8Cf9ak4qwTGfsf812LJQrcrrXv2GNc(c2bb7SG7dX(KWozC0723AviRwWcjX2jMpe7tc7KXrp2JQAWEGDSTcNiJEaITtStJCUAKquuCVdJf27jq9Ib6jMFCe7BX2jwKquu8I2JQXuvnjMFCe7hX0Jy(l2pI9TyBgXwJhZu1MgeNy)k2VITtmiHaPdlzCubxr3c2ArpGcUUH1fTAIObOelsikkoXcSmeJF7CI56pKyiduSaJetXcZOhGydIy6pRwWcjEfdsiq6WetXcBakX0sGI861ReLn03fFl4eizCKQ8FbpxrpGcoKvlyHubxr3c2ArpGcU(tiq6Wet)z1cwijgLq3wXAeX6qm(TZjgPtTgsIPyHnaLy4B9yg39eJBJybwgIbjeiDyI1iIHpCtmuuCIbPuTvSgiwGrIbiDgIPN7vWxWoiyNfCFi2Ne2jJJE3(wRcz1cwij2oXGKx2GtSVeBnJtn8bVBRhZ4U6Guvugypi5Ln4eZFX4rxITtS1mo1Wh8UTEmJ7QdsvrzG9GKx2GtSV4iMEeBNyrcrrXlApQgtv1Ky6OyqYlBWjMFITMXPg(G3T1JzCxDqQkkdShK8YgCI5Vy6PeLn0Hl(wWjqY4iv5)c(c2bb7SG7dX(KWozC0J9OQgShyhBRWjYOhGy7e70iNRgjeffNy(Xrm0RGNROhqbNXLR9vTHVIGLOSbp6Q4BbpxrpGco9PVfbZGk4eizCKQ8FjkrbFPUIVLn4P4BbNajJJuL)l4lyheSZcUpeJHfb5DyPA4xvjyrpwnX2jgdlcY7WyH9EcuJbcs18y1eBNymSiiVdJf27jqngiivZdsEzdoX(IJyO3tpfC2JQdcsf1sv2GNcEUIEaf8dlvd)QkblQGROBbBTOhqb)VpsmULGfj2GGOJOwkXyiKbsIfyKyin8cXomwyVNa1lgONyiWXtmFhiivJyRXJoXAWReLn(U4BbNajJJuL)l4lyheSZcodlcY7WyH9EcuJbcs18y1eBNymSiiVdJf27jqngiivZdsEzdoX(IJyO3tpfC2JQdcsf1sv2GNcEUIEaf8BRhZ4U6GuvugyfCfDlyRf9ak4)83ahDNyPdsPARySAIXqRK9iX4tIfZSxmCSun8ft)Mf79RyShjg(wpMXDInii6iQLsmgczGKybgjgsdVqmCmwyVNaIHhd0tme44jMVdeKQrS14rNyn4vIYgOxX3cobsghPk)xWxWoiyNf8pjStgh9oGQUgGQJEaITtmFi2fu6cms98sq4iX2j2pI5dXGSaczGOO3WqQMal6rGKXrkX4IlXwZ4udFW726XmURoivfLb2JvtSDITgpMPQnnioX8JJy6rSFl45k6buWrCjkY5YOhqjkB4ZIVfCcKmosv(VGVGDqWol4)igKfqidef98s4(6GudmQ6LxqWAExExdEeizCKsSDITgpMPQnniUNIq6vhI9fhX4rmDuSiDeiEkI0iy9cygekY7rGKXrkX4IlXGSaczGOONIYaZTTEyPA4FpcKmosj2oXwJhZu1MgeNyFjgpI9Ry7eJHfb5DB9yg3vhKQIYa7XQj2oXyyrqEhwQg(vvcw0JvtSDI5LxqWAExExdQqYlBWjghX0Ly7eJHfb5POmWCBRhwQg(3tn8bf8Cf9ak4FsqFyLOSHEk(wWjqY4iv5)cUIUfS1IEafCDFgNyidumFhiivJyAqshXhUjg)oWedhJBIbPuTvm(yeqmWeIbzbGgGsmC97vWrgyfq6mkBWtbFb7GGDwWJ0rG4DySWEpbQXabPAEeizCKsSDI5dXI0rG4DyPA4xrMf79iqY4ivbpxrpGcU2mUkKUHfUOsu2qFk(wWjqY4iv5)cEUIEaf8dJf27jqngiivtbxr3c2ArpGc(FFKy(oqqQgX0GKy4d3eJpgbeJpjgw(HelWiXiabrTvm(yuGrqXqGJNyAZ4AakX43b2WgIHRFInqX0bWEHyOiabtNB7RGVGDqWol4eGGO2kMFCetF0Ly7e7tc7KXrVdOQRbO6OhGy7eBnJtn8bVBRhZ4U6GuvugypwnX2j2AgNA4dEhwQg(vvcw0BHLqu0jMFCeJhX2j2pI5dXGSaczGOO3WqQMal6rGKXrkX4IlXuedlcYdXLOiNlJEapwnX(vSDITgpMPQnnioX(IJyFxIYg62IVfCcKmosv(VGNROhqb)iimdsvzgavpTEpvWxWoiyNf8pjStgh9oGQUgGQJEaITtmFiMAI3rqygKQYmaQEA9EQQM4f9AFdqj2oXIeIIIx0EunMQQjX8JJyFZJyCXLyinkSOcjVSbNyFXrm9i2oXonY5QrcrrX9omwyVNa1lgONyFjg6vWxBxoQgjeffxzdEkrzd9DX3cobsghPk)xWxWoiyNf8pjStgh9oGQUgGQJEaITtS14XmvTPbX9uesV6qm)4igpf8Cf9ak4hPD9vIYg6WfFl4eizCKQ8FbpxrpGc(T1JzCxDqQkkdScUIUfS1IEaf8)(iXW36XmUtSbi2AgNA4de7NejiOyin8cXWbC7xXybo6oX4tILqsmutdqjwmIPnAI57abPAelbkXuJyGjedl)qIHJLQHVy63SyVxbFb7GGDwW)KWozC07aQ6AaQo6bi2oX(rSiDeiEe4d5gTgGQEyPA4FpcKmosjgxCj2AgNA4dEhwQg(vvcw0BHLqu0jMFCeJhX(vSDI9Jy(qSiDeiEhglS3tGAmqqQMhbsghPeJlUelshbI3HLQHFfzwS3JajJJuIXfxITMXPg(G3HXc79eOgdeKQ5bjVSbNy(j23I9Ry7e7hX8HyqwaHmqu0ByivtGf9iqY4iLyCXLyRzCQHp4H4suKZLrpGhK8YgCI5NyFRlX(TeLn4rxfFl4eizCKQ8FbpxrpGcUxc3tQkYaRkkdScURbuDPk4880tbFTD5OAKquuCLn4PGVGDqWol4WSvv6dbIxQu3JvtSDI9JyrcrrXlApQgtv1KyFj2A8yMQ20G4EkcPxDigxCjMpe7ckDbgPEPZj2oXwJhZu1Mge3tri9QdX8JJylTQxQZ6PraLy)wWv0TGTw0dOGRVqelvQtSesIXQXRyhO1iXcmsSbqIXVdmXCdF6cX81xU9e7Vpsm(yeqm12gGsmK8cckwGLaX2KUlMIq6vhInqXati2fu6cmsjg)oWg2qSeSvSnP7Vsu2GhEk(wWjqY4iv5)cEUIEafCVeUNuvKbwvugyfCfDlyRf9ak46leXaJyPsDIXVDoXunjg)oWAGybgjgG0zig6PRJxXypsmDdc3eBaIXm3jg)oWg2qSeSvSnP7Vc(c2bb7SGdZwvPpeiEPsDVgiMFIHE6smDumy2Qk9HaXlvQ7PyHz0dqSDITgpMPQnniUNIq6vhI5hhXwAvVuN1tJaQsu2GNVl(wWjqY4iv5)c(c2bb7SG)jHDY4O3bu11auD0dqSDITgpMPQnniUNIq6vhI5hhX(wSDI9JyRzCQHp4DB9yg3vhKQIYa7bjVSbNyFjgpIXfxIXWIG8UTEmJ7QdsvrzG9y1eJlUedPrHfvi5Ln4e7loI9TUe73cEUIEaf8dlvd)kJlv0vIYg8GEfFl4eizCKQ8FbFb7GGDwW)KWozC07aQ6AaQo6bi2oXwJhZu1Mge3tri9QdX8JJyFl2oX(rSpjStgh9ypQQb7b2X2kCIm6bigxCj2ProxnsikkU3HXc79eOEXa9e7loI5tX4IlXGSaczGOOhKUHfOAaQ6YLWo2(iqY4iLy)wWZv0dOGtlSPbOQqsd2EjqvIYg84ZIVfCcKmosv(VGNROhqb)WyH9EcuJbcs1uWv0TGTw0dOGV5DGjgU(XRynIyGjelDqkvBftnaIxXypsmFhiivJy87atm8HBIXQ9k4lyheSZcEKoceVdlvd)kYSyVhbsghPeBNyFsyNmo6DavDnavh9aeBNymSiiVBRhZ4U6GuvugypwnX2j2A8yMQ20G4e7loI9DjkBWJEk(wWjqY4iv5)c(c2bb7SG7dXyyrqEhwQg(vvcw0JvtSDIH0OWIkK8YgCI9fhX03I5Vyr6iq8owMGGiSOOhbsghPk45k6buWpSun8RQeSOsu2Gh9P4BbNajJJuL)l4lyheSZcodlcYJXnJYXEXds5keJlUedPrHfvi5Ln4e7lXqpDjgxCjgdlcY726XmURoivfLb2JvtSDI9JymSiiVdlvd)kJlv09y1eJlUeBnJtn8bVdlvd)kJlv09GKx2GtSV4igp6sSFl45k6buW1MOhqjkBWJUT4BbNajJJuL)l4lyheSZcodlcY726XmURoivfLb2JvRGNROhqbNXnJQIWc3wIYg8OVl(wWjqY4iv5)c(c2bb7SGZWIG8UTEmJ7QdsvrzG9y1k45k6buWzi4rW9navjkBWJoCX3cobsghPk)xWxWoiyNfCgweK3T1JzCxDqQkkdShRwbpxrpGcosdjg3mQsu24BDv8TGtGKXrQY)f8fSdc2zbNHfb5DB9yg3vhKQIYa7XQvWZv0dOGNGfDbmD1v6CLOSX38u8TGtGKXrQY)f8Cf9ak4Shv7G8UcUIUfS1IEafCUrijRledjDoMCTxmKbkg7LmosSoiV7Ve7Vpsm(DGjg(wpMXDIniIXnkdSxbFb7GGDwWzyrqE3wpMXD1bPQOmWESAIXfxIH0OWIkK8YgCI9LyFRRsuIc(fu6cS6sDfFlBWtX3cobsghPk)xWhTc(rrbpxrpGc(Ne2jJJk4FshlvWxZ4udFW7Ws1WVQsWIElSeIIUkcmxrpG0jMFCeJNNUvpfCfDlyRf9ak46ajNgbfthmHDY4Oc(NewbPhvWpmvnWG0HnovjkB8DX3cobsghPk)xWZv0dOG)jb9HvWv0TGTw0dOGRdMG(WeRreJpjwcjXwPMwdqj2aeJBjyrITWsik6EITzNq3wXyiKbsIH0WletLGfjwJigFsmS8djgyeBJgfwCr62tqXyydX4wc3lgowQg(I1aXgOIGIfJyOOqm9NvlyHKySAI9dyet3KxqqXq)3L31GFFf8fSdc2zb)hX8HyFsyNmo6DyQAGbPdBCkX4IlX8Hyr6iq8ankS4I0TNGpcKmosj2oXI0rG4Ps4(6HLQH)JajJJuI9Ry7eBnEmtvBAqCpfH0RoeZpX4rSDI5dXGSaczGOONxc3xhKAGrvV8ccwZ7Y7AWJajJJuLOSb6v8TGtGKXrQY)fCfDlyRf9ak46(moXqgOy4yPA47roLy(lgowQg(xa79KySahDNy8jXsijwYmSHyXi2k1eBaIXTeSiXwyjefDpX2SaUTIXhJaIPFnqj2Mt5EaDNy9jwYmSHyXigKfi2WgVcoYaRasNrzdEk4lyheSZcomx0d0OWIk5qk4KodywtVHfefCFQRcEUIEafCTzCviDdlCrLOSHpl(wWjqY4iv5)c(c2bb7SGtacIARy(XrmFQlX2jgbiiQTpfH0RoeZpoIXJUeBNy(qSpjStgh9omvnWG0HnoLy7eBnEmtvBAqCpfH0RoeZpX4rSDIPigweKhsduv(uUhq39GKx2GtSVeJNcEUIEaf8dlvdFpYPkrzd9u8TGtGKXrQY)f8rRGFuuWZv0dOG)jHDY4Oc(N0Xsf814XmvTPbX9uesV6qm)4i23I5VymSiiVdlvd)kJlv09y1k4k6wWwl6buW3KUlwGbPdBCQtmKbkgbcc2auIHJLQHVyClblQG)jHvq6rf8dtvxJhZu1MgexjkBOpfFl4eizCKQ8FbF0k4hff8Cf9ak4FsyNmoQG)jDSubFnEmtvBAqCpfH0RoeZpoIHEf8fSdc2zbFnFiqcI3(TWobf8pjScspQGFyQ6A8yMQ20G4krzdDBX3cobsghPk)xWhTc(rrbpxrpGc(Ne2jJJk4FshlvWxJhZu1Mge3tri9QdX(IJy8uWxWoiyNf8pjStgh9ypQQb7b2X2kCIm6bi2oXonY5QrcrrX9omwyVNa1lgONy(XrmFwW)KWki9Oc(HPQRXJzQAtdIReLn03fFl4eizCKQ8FbpxrpGc(HLQHFvLGfvWv0TGTw0dOGZTeSiXuSWgGsm8TEmJ7eBGILmZhsSadsh24uVc(c2bb7SG)jHDY4O3HPQRXJzQAtdItSDI9JyFsyNmo6DyQAGbPdBCkX4IlXyyrqE3wpMXD1bPQOmWEqYlBWjMFCeJN33IXfxIDAKZvJeIII7DySWEpbQxmqpX8JJy(uSDITMXPg(G3T1JzCxDqQkkdShK8YgCI5Ny8OlX(TeLn0Hl(wWjqY4iv5)cEUIEaf8dlvd)QkblQGROBbBTOhqb)Fwiqmi5LnObOeJBjyrNymeYajXcmsmKgfwigbuNynIy4d3eJ)a4EigdjgKs1wXAGyr7rVc(c2bb7SG)jHDY4O3HPQRXJzQAtdItSDIH0OWIkK8YgCI9LyRzCQHp4DB9yg3vhKQIYa7bjVSbxjkrbNHTDQIVLn4P4BbNajJJuL)l4lyheSZcUpelshbIhOrHfxKU9e8rGKXrkX2jgKfqidef9IgSTgJo7vLXLk6rGKXrkX2j2ProxnsikkU3HXc79eOEXa9e7lX0tbpxrpGc(H1FkrzJVl(wWjqY4iv5)c(c2bb7SGFAKZvJeIIItm)4i23ITtSFeBnJtn8bVJGWmivLzau90690Zl1zDHLqu0jMok2clHOORIaZv0diDI5hhX017B9igxCj2ProxnsikkU3HXc79eOEXa9eZpX8Py)wWZv0dOGFySWEpbQxmqVsu2a9k(wWjqY4iv5)c(c2bb7SGVMXPg(G3rqygKQYmaQEA9E65L6SUWsik6ethfBHLqu0vrG5k6bKoX(IJy669TEeJlUe7gwhtduphLQkZ2kPZ0tZrpcKmosj2oX8HymSiiphLQkZ2kPZ0tZrpwTcEUIEaf8JGWmivLzau9069ujkB4ZIVf8Cf9ak4OCZ4X4sfvWjqY4iv5)su2qpfFl45k6buWzY1(lsMcobsghPk)xIsuIc(hcE9akB8TU(MhDPpFRBl48tiObOUc(MJ(1)n0xBG(8xIjMVyKyTN2adXqgOyC)ckDbgP4UyqshITHKsSB8iXs2y8YGuITWsak6EcA)zdiX85Fj2MgWhcgKsmUdzbeYarrV)G7IfJyChYciKbIIE)XJajJJuCxSF4rN)(e0(ZgqIPB)lX20a(qWGuIXDilGqgik69hCxSyeJ7qwaHmqu07pEeizCKI7I9dp683NGMG2MJ(1)n0xBG(8xIjMVyKyTN2adXqgOyCxdsRXJjdUlgK0HyBiPe7gpsSKngVmiLylSeGIUNG2F2asm07VeBtd4dbdsjg3VH1X0a17p4UyXig3VH1X0a17pEeizCKI7ILHyB2Bw)Py)WJo)9jO9NnGet3(xITPb8HGbPeJ7qwaHmqu07p4UyXig3HSaczGOO3F8iqY4if3fldX2S3S(tX(HhD(7tqtqBZr)6)g6RnqF(lXeZxmsS2tBGHyidumUJ0G(W4UyqshITHKsSB8iXs2y8YGuITWsak6EcA)zdiX85Fj2MgWhcgKsmUdzbeYarrV)G7IfJyChYciKbIIE)XJajJJuCxSF4rN)(e0e02C0V(VH(Ad0N)smX8fJeR90gyigYafJ7l1XDXGKoeBdjLy34rILSX4LbPeBHLau09e0(ZgqIHE)LyBAaFiyqkX4oKfqidef9(dUlwmIXDilGqgik69hpcKmosXDX(HhD(7tq7pBajMp)lX20a(qWGuIXDilGqgik69hCxSyeJ7qwaHmqu07pEeizCKI7I9Z3683NG2F2asm95VeBtd4dbdsjg3HSaczGOO3FWDXIrmUdzbeYarrV)4rGKXrkUl2p8OZFFcA)zdiX0H)lX20a(qWGuIXDilGqgik69hCxSyeJ7qwaHmqu07pEeizCKI7I9dp683NG2F2asmEqV)sSnnGpemiLyChYciKbIIE)b3flgX4oKfqidef9(JhbsghP4Uy)WJo)9jOjOT5OF9Fd91gOp)LyI5lgjw7PnWqmKbkg3VGsxGvxQJ7IbjDi2gskXUXJelzJXldsj2clbOO7jO9NnGe77)sSnnGpemiLyChYciKbIIE)b3flgX4oKfqidef9(JhbsghP4Uyzi2M9M1Fk2p8OZFFcAcABo6x)3qFTb6ZFjMy(IrI1EAdmedzGIXDg22P4UyqshITHKsSB8iXs2y8YGuITWsak6EcA)zdiX45VeBtd4dbdsjg3HSaczGOO3FWDXIrmUdzbeYarrV)4rGKXrkUl2p8OZFFcAcA6lpTbgKsmDRy5k6biMRV4EcAfCn4G0oQGRx9kgolt4OyRy6)GILe00REfdnwaj236BEf7BD9npcAcA6vVIPBMpKyFsyNmo6XEuvd2dSJTv4ez0dqmwnXUrSoeRpXokeJHqgijgFsm2JeRJNGME1RyBA8yAajMhRlAnhj2kDUAUIEavxFHyeiGnDIfJyqsXUiX0MGarNoXGe)bU)jOjOPx9kMUdjDCtJhtgcA5k6bCpniTgpMm8Nd6snn32Q203ae0Yv0d4EAqAnEmz4ph0Xmr4ivfXLBjf)gGQgJoBGGwUIEa3tdsRXJjd)5GoehDylyIe82iCUH1X0a1tJ9cwhvjiRw0dqqlxrpG7PbP14XKH)Cq3fu6cmbTCf9aUNgKwJhtg(ZbDEjCpPQidSQOmW4vdsRXJjJ6rRbOoo8OhbTCf9aUNgKwJhtg(ZbDNRxunbQQQxeVAqAnEmzupAna1XHhEBeoqcbshwY4ibTCf9aUNgKwJhtg(ZbDhwQg(vgxQOJ3gHdKfqidef98s4(6GudmQ6LxqWAExExde0e00REft3Knqm9FIm6biOLROhWXzFV2lOPxX(7JuIfJykkiOxdiX4JrbgbfBnJtn8bNy8ZoedzGIHd4Mym5rkXgGyrcrrX9e0Yv0d48Nd6(KWozCeVG0J4CavDnavh9a49t6yjomSiiVZ1lQMavv1l6XQXfxNg5C1iHOO4EhglS3tG6fd0Zpo6JGMEfBty0AVyBIBNyzigsdVqqlxrpGZFoOBLoxnxrpGQRVGxq6rCwQtqtVIP)SaXqyDUTID87yHrNyXiwGrIHhu6cmsjM(prg9ae7hMTIPMgGsSB4vSoedzGl6etBgxdqjwJigycSgGsS(el)KTlzC0VpbTCf9ao)5GoilOMROhq11xWli9ioxqPlWifVncNlO0fyK6LoNGMEfd9RP52kgURxKyjqjg36fjwgI9T)ITjDxmflSbOelWiXqA4fIXJUe7O1auhVILibbflWYqmF6VyBs3fRreRdXiDQ1q6eJFhynqSaJedq6med9ztCtSbkwFIbMqmwnbTCf9ao)5GUZ1lQMavv1lI3gHZProxnsikkU3HXc79eOEXa9(sF2H0OWIkK8YgC(Pp7yyrqENRxunbQQQx0dsEzdUVqTupVuN7wJhZu1MgeNFC8Po(t0E0x8ORF3mFlOPxX2SaUTITWsaksm4ez0dqSgrm(Kyy5hsmnypWo2wHtKrpaXokelbkX8yDrR5iXIeIIItmwTNGwUIEaN)Cq3Ne2jJJ4fKEeh2JQAWEGDSTcNiJEa8(jDSehnypWo2wHtKrpGDNg5C1iHOO4EhglS3tG6fd0ZpoFlOPxX0DypWo2kM(prg9aqFrS)KcUFIHQ)qILITGPMyjZWgIracIARyiduSaJe7ckDbMyBIBNy)WW2ofbf7I25edsNgTcX643NyOVYQXRyDi2kbIXqIfyzi21EAo6jOLROhW5ph0TsNRMROhq11xWli9ioxqPlWQl1XBJW5tc7KXrp2JQAWEGDSTcNiJEacA6vS)(iLyXiMIqAajgFmciwmIXEKyxqPlWeBtC7eBGIXW2ofbpbTCf9ao)5GUpjStghXli9ioxqPlWQbgKoSXP49t6yjoFRh)J0rG49PrnWhbsghP2mFRl)J0rG45LxqW6GupSun8VhbsghP2mFRl)J0rG4DyPA4xrMf79iqY4i1M5B94FKoceV0LlyhBFeizCKAZ8TU8)B9Sz(50iNRgjeff37WyH9EcuVyGE(XXN)kOPxX20aUwrqXyVgGsSum8GsxGj2M4My8XiGyqkxynaLybgjgbiiQTIfyq6WgNsqlxrpGZFoOBLoxnxrpGQRVGxq6rCUGsxGvxQJ3gHdbiiQTpfH0Ro(IZNe2jJJExqPlWQbgKoSXPe0Yv0d48Nd6wPZvZv0dO66l4fKEehKg0hgVncNFieeAf9hQUgpMPQnnio)4S0QEPoRNgbu)Yfx)SgpMPQnniUNIq6vhFXHhU4cPrHfvi5Ln4(Idp7ieeAf9hQUgpMPQnnio)4GECXfdlcY726XmURoivfLbwnzJzb74XQTJqqOv0FO6A8yMQ20G48JJp)LlU(50iNRgjeff37WyH9EcuVyGE(XXN7ieeAf9hQUgpMPQnnio)44ZFf00Ry)9rILIXW2ofbfJpgbeds5cRbOelWiXiabrTvSadsh24ucA5k6bC(ZbDR05Q5k6buD9f8cspIddB7u82iCiabrT9PiKE1XxC(KWozC07ckDbwnWG0HnoLGMEf7ph(0fIPb7b2XwXAGyPZj2GiwGrIH(19)umgALShjwhITs2JoXsXqF2e3e0Yv0d48Nd6s4kbungiKabVnchcqquBFkcPxD4hhE0J)eGGO2(GekciOLROhW5ph0LWvcOQgR7ibTCf9ao)5GoxJclUQoawfkpcecA5k6bC(ZbDmjQ6GudyV2FcAcA6vVI9pB7ue8e0Yv0d4EmSTtX5W6p82iC8rKocepqJclUiD7j4JajJJu7GSaczGOOx0GT1y0zVQmUur7onY5QrcrrX9omwyVNa1lgO3x6rqlxrpG7XW2oL)Cq3HXc79eOEXa94Tr4CAKZvJeIIIZpoFV7N1mo1Wh8occZGuvMbq1tR3tpVuN1fwcrrNoUWsik6QiWCf9asNFC017B9WfxNg5C1iHOO4EhglS3tG6fd0ZpF(RGwUIEa3JHTDk)5GUJGWmivLzau9069eVncN1mo1Wh8occZGuvMbq1tR3tpVuN1fwcrrNoUWsik6QiWCf9as3xC017B9Wfx3W6yAG65Ouvz2wjDMEAo6rGKXrQD(GHfb55Ouvz2wjDMEAo6XQjOLROhW9yyBNYFoOdLBgpgxQibTCf9aUhdB7u(ZbDm5A)fjJGMGME1RyBAgNA4dobn9k2FFKyClblsSbbrhrTuIXqidKelWiXqA4fIDySWEpbQxmqpXqGJNy(oqqQgXwJhDI1GNGwUIEa3BPoohwQg(vvcweVShvheKkQLIdp82iC8bdlcY7Ws1WVQsWIESA7yyrqEhglS3tGAmqqQMhR2ogweK3HXc79eOgdeKQ5bjVSb3xCqVNEe00Ry)83ahDNyPdsPARySAIXqRK9iX4tIfZSxmCSun8ft)Mf79RyShjg(wpMXDInii6iQLsmgczGKybgjgsdVqmCmwyVNaIHhd0tme44jMVdeKQrS14rNyn4jOLROhW9wQZFoO726XmURoivfLbgVShvheKkQLIdp82iCyyrqEhglS3tGAmqqQMhR2ogweK3HXc79eOgdeKQ5bjVSb3xCqVNEe0Yv0d4El15ph0H4suKZLrpaEBeoFsyNmo6DavDnavh9a25JlO0fyK65LGWr7(XhqwaHmqu0ByivtGfXfxRzCQHp4DB9yg3vhKQIYa7XQTBnEmtvBAqC(Xrp)kOLROhW9wQZFoO7tc6dJ3gHZpqwaHmqu0ZlH7RdsnWOQxEbbR5D5Dny3A8yMQ20G4EkcPxD8fhE0XiDeiEkI0iy9cygekY7rGKXrkU4cYciKbIIEkkdm326HLQH)TBnEmtvBAqCFXZV7yyrqE3wpMXD1bPQOmWESA7yyrqEhwQg(vvcw0JvBNxEbbR5D5DnOcjVSbhhDTJHfb5POmWCBRhwQg(3tn8bcA6vmDFgNyidumFhiivJyAqshXhUjg)oWedhJBIbPuTvm(yeqmWeIbzbGgGsmC97jOLROhW9wQZFoOtBgxfs3WcxeVidSciDgC4H3gHtKoceVdJf27jqngiivZJajJJu78rKoceVdlvd)kYSyVhbsghPe00Ry)9rI57abPAetdsIHpCtm(yeqm(Kyy5hsSaJeJaee1wX4JrbgbfdboEIPnJRbOeJFhydBigU(j2aftha7fIHIaemDUTpbTCf9aU3sD(ZbDhglS3tGAmqqQgEBeoeGGO26hh9rx7(KWozC07aQ6AaQo6bSBnJtn8bVBRhZ4U6GuvugypwTDRzCQHp4DyPA4xvjyrVfwcrrNFC4z3p(aYciKbIIEddPAcSiU4srmSiipexIICUm6b8y1(D3A8yMQ20G4(IZ3cA5k6bCVL68Nd6occZGuvMbq1tR3t8U2UCunsikkoo8WBJW5tc7KXrVdOQRbO6OhWoFOM4DeeMbPQmdGQNwVNQQjErV23au7IeIIIx0EunMQQj)48npCXfsJclQqYlBW9fh9S70iNRgjeff37WyH9EcuVyGEFHEcA5k6bCVL68Nd6os76J3gHZNe2jJJEhqvxdq1rpGDRXJzQAtdI7PiKE1HFC4rqtVI93hjg(wpMXDInaXwZ4udFGy)KibbfdPHxigoGB)kglWr3jgFsSesIHAAakXIrmTrtmFhiivJyjqjMAedmHyy5hsmCSun8ft)Mf79e0Yv0d4El15ph0DB9yg3vhKQIYaJ3gHZNe2jJJEhqvxdq1rpGD)ePJaXJaFi3O1au1dlvd)7rGKXrkU4AnJtn8bVdlvd)Qkbl6TWsik68Jdp)U7hFePJaX7WyH9EcuJbcs18iqY4ifxCfPJaX7Ws1WVIml27rGKXrkU4AnJtn8bVdJf27jqngiivZdsEzdo)((3D)4dilGqgik6nmKQjWI4IR1mo1Wh8qCjkY5YOhWdsEzdo)(wx)kOPxX0xiILk1jwcjXy14vSd0AKybgj2aiX43bMyUHpDHy(6l3EI93hjgFmciMABdqjgsEbbflWsGyBs3ftri9QdXgOyGje7ckDbgPeJFhydBiwc2k2M09NGwUIEa3BPo)5GoVeUNuvKbwvugy86Aavxko880dVRTlhvJeIIIJdp82iCGzRQ0hceVuPUhR2UFIeIIIx0EunMQQPVwJhZu1Mge3tri9QdU4YhxqPlWi1lDUDRXJzQAtdI7PiKE1HFCwAvVuN1tJaQFf00Ry6leXaJyPsDIXVDoXunjg)oWAGybgjgG0zig6PRJxXypsmDdc3eBaIXm3jg)oWg2qSeSvSnP7pbTCf9aU3sD(ZbDEjCpPQidSQOmW4Tr4aZwvPpeiEPsDVg4h6PlDeMTQsFiq8sL6Ekwyg9a2TgpMPQnniUNIq6vh(XzPv9sDwpncOe0Yv0d4El15ph0DyPA4xzCPIoEBeoFsyNmo6DavDnavh9a2TgpMPQnniUNIq6vh(X57D)SMXPg(G3T1JzCxDqQkkdShK8YgCFXdxCXWIG8UTEmJ7QdsvrzG9y14IlKgfwuHKx2G7loFRRFf0Yv0d4El15ph0rlSPbOQqsd2EjqXBJW5tc7KXrVdOQRbO6OhWU14XmvTPbX9uesV6WpoFV7NpjStgh9ypQQb7b2X2kCIm6bWfxNg5C1iHOO4EhglS3tG6fd07lo(KlUGSaczGOOhKUHfOAaQ6YLWo2(RGMEfBZ7atmC9JxXAeXatiw6GuQ2kMAaeVIXEKy(oqqQgX43bMy4d3eJv7jOLROhW9wQZFoO7WyH9EcuJbcs1WBJWjshbI3HLQHFfzwS3JajJJu7(KWozC07aQ6AaQo6bSJHfb5DB9yg3vhKQIYa7XQTBnEmtvBAqCFX5BbTCf9aU3sD(ZbDhwQg(vvcweVnchFWWIG8oSun8RQeSOhR2oKgfwuHKx2G7lo6B)J0rG4DSmbbryrrpcKmosjOLROhW9wQZFoOtBIEa82iCyyrqEmUzuo2lEqkxbxCH0OWIkK8YgCFHE6IlUyyrqE3wpMXD1bPQOmWESA7(HHfb5DyPA4xzCPIUhRgxCTMXPg(G3HLQHFLXLk6EqYlBW9fhE01VcA5k6bCVL68Nd6yCZOQiSWT82iCyyrqE3wpMXD1bPQOmWESAcA5k6bCVL68Nd6yi4rW9nafVnchgweK3T1JzCxDqQkkdShRMGwUIEa3BPo)5GoKgsmUzu82iCyyrqE3wpMXD1bPQOmWESAcA5k6bCVL68Nd6sWIUaMU6kDoEBeomSiiVBRhZ4U6Guvugypwnbn9kg3iKK1fIHKohtU2lgYafJ9sghjwhK39xI93hjg)oWedFRhZ4oXgeX4gLb2tqlxrpG7TuN)Cqh7r1oiVJ3gHddlcY726XmURoivfLb2JvJlUqAuyrfsEzdUV(wxcAcA6vVIPFnOpmcEcA6vSnhRDKySxdqjMUdjps1rg9a4vS8Z0kXw5fnaLy4UErILaLyCRxKy8XiGy4yPA4lg3sWIeRpXUzaIfJymKyShP4vmsNlsledzGIH(ElStGGwUIEa3dPb9HX5tc7KXr8cspIJgK8iv9aQ6AaQo6bW7N0XsCI0rG4Pbjps1rg9aEeizCKA3ProxnsikkU3HXc79eOEXa9(6h9OJR5dbsq8a0coUbQ(DNpwZhcKG4TFlStGGwUIEa3dPb9H5ph0DUEr1eOQQEr82iC8XNe2jJJEAqYJu1dOQRbO6OhWUtJCUAKquuCVdJf27jq9Ib69L(SZhmSiiVdlvd)Qkbl6XQTJHfb5DUEr1eOQQErpi5Ln4(cPrHfvi5Ln42bjeiDyjJJe0Yv0d4EinOpm)5GUZ1lQMavv1lI3gHZNe2jJJEAqYJu1dOQRbO6OhWU1mo1Wh8oSun8RQeSO3clHOORIaZv0diDFXZt3QNDmSiiVZ1lQMavv1l6bjVSb3xRzCQHp4DB9yg3vhKQIYa7bjVSb3UFwZ4udFW7Ws1WVQsWIEqkvB3XWIG8UTEmJ7QdsvrzG9GKx2GthzyrqEhwQg(vvcw0dsEzdUV4599VcA6vmDGKtJGIPdMWozCKyidum9NvlyH0tm89TMykwydqjMUjVGGIH(VlVRbInqXuSWgGsmULGfjg)oWeJBjCVyjqjgyeBJgfwCr62tWNGwUIEa3dPb9H5ph09jHDY4iEbPhX523AviRwWcjE)KowIJxEbbR5D5DnOcjVSbNF6IlU8rKocepqJclUiD7j4JajJJu7I0rG4Ps4(6HLQH)JajJJu7yyrqEhwQg(vvcw0JvJlUonY5QrcrrX9omwyVNa1lgONFC(rp6iKfqidef9qAq66y7VcA6vm03ePjgRMy6pRwWcjXAeX6qS(elzg2qSyedYceByJNGwUIEa3dPb9H5ph0bz1cwiXBJW5hF8jHDY4O3TV1QqwTGfsCX1Ne2jJJEShv1G9a7yBforg9a(DxKquu8I2JQXuvnPJqYlBW5N(Sdsiq6WsghjOLROhW9qAqFy(ZbDhTGuudAHbADiwsqtVIPByDrRMiAakXIeIIItSaldX43oNyU(djgYaflWiXuSWm6bi2GiM(ZQfSqIxXGecKomXuSWgGsmTeOiVE9e0Yv0d4EinOpm)5GoiRwWcjExBxoQgjeffhhE4Tr44JpjStgh9U9TwfYQfSqANp(KWozC0J9OQgShyhBRWjYOhWUtJCUAKquuCVdJf27jq9Ib65hNV3fjeffVO9OAmvvt(X5h94)pFVzwJhZu1Mge3V)Udsiq6WsghjOPxX0FcbshMy6pRwWcjXOe62kwJiwhIXVDoXiDQ1qsmflSbOedFRhZ4UNyCBelWYqmiHaPdtSgrm8HBIHIItmiLQTI1aXcmsmaPZqm9CpbTCf9aUhsd6dZFoOdYQfSqI3gHJp(KWozC0723AviRwWcPDqYlBW91AgNA4dE3wpMXD1bPQOmWEqYlBW5pp6A3AgNA4dE3wpMXD1bPQOmWEqYlBW9fh9SlsikkEr7r1yQQM0ri5Ln48BnJtn8bVBRhZ4U6Guvugypi5Ln48xpcA5k6bCpKg0hM)CqhJlx7RAdFfb5Tr44JpjStgh9ypQQb7b2X2kCIm6bS70iNRgjeffNFCqpbTCf9aUhsd6dZFoOJ(03IGzqcAcA6vVIHhu6cmX20mo1WhCcA6vmDGKtJGIPdMWozCKGwUIEa37ckDbwDPooFsyNmoIxq6rComvnWG0HnofVFshlXznJtn8bVdlvd)Qkbl6TWsik6QiWCf9asNFC45PB1JGMEfthmb9HjwJigFsSesITsnTgGsSbig3sWIeBHLqu09eBZoHUTIXqidKedPHxiMkblsSgrm(Kyy5hsmWi2gnkS4I0TNGIXWgIXTeUxmCSun8fRbInqfbflgXqrHy6pRwWcjXy1e7hWiMUjVGGIH(VlVRb)(e0Yv0d4ExqPlWQl15ph09jb9HXBJW5hF8jHDY4O3HPQbgKoSXP4IlFePJaXd0OWIls3Ec(iqY4i1UiDeiEQeUVEyPA4)iqY4i1V7wJhZu1Mge3tri9Qd)4zNpGSaczGOONxc3xhKAGrvV8ccwZ7Y7AGGMEft3NXjgYafdhlvdFpYPeZFXWXs1W)cyVNeJf4O7eJpjwcjXsMHnelgXwPMydqmULGfj2clHOO7j2MfWTvm(yeqm9RbkX2Ck3dO7eRpXsMHnelgXGSaXg24jOLROhW9UGsxGvxQZFoOtBgxfs3WcxeVidSciDgC4HxsNbmRP3Wcco(ux82iCG5IEGgfwujhIGwUIEa37ckDbwDPo)5GUdlvdFpYP4Tr4qacIARFC8PU2racIA7tri9Qd)4WJU25JpjStgh9omvnWG0Hno1U14XmvTPbX9uesV6WpE2PigweKhsduv(uUhq39GKx2G7lEe00RyBs3flWG0Hno1jgYafJabbBakXWXs1WxmULGfjOLROhW9UGsxGvxQZFoO7tc7KXr8cspIZHPQRXJzQAtdIJ3pPJL4SgpMPQnniUNIq6vh(X5B)zyrqEhwQg(vgxQO7XQjOLROhW9UGsxGvxQZFoO7tc7KXr8cspIZHPQRXJzQAtdIJ3pPJL4SgpMPQnniUNIq6vh(Xb94Tr4SMpeibXB)wyNabTCf9aU3fu6cS6sD(ZbDFsyNmoIxq6rComvDnEmtvBAqC8(jDSeN14XmvTPbX9uesV64lo8WBJW5tc7KXrp2JQAWEGDSTcNiJEa7onY5QrcrrX9omwyVNa1lgONFC8PGMEfJBjyrIPyHnaLy4B9yg3j2aflzMpKybgKoSXPEcA5k6bCVlO0fy1L68Nd6oSun8RQeSiEBeoFsyNmo6DyQ6A8yMQ20G429ZNe2jJJEhMQgyq6WgNIlUyyrqE3wpMXD1bPQOmWEqYlBW5hhEEFZfxNg5C1iHOO4EhglS3tG6fd0Zpo(C3AgNA4dE3wpMXD1bPQOmWEqYlBW5hp66xbn9k2)SqGyqYlBqdqjg3sWIoXyiKbsIfyKyinkSqmcOoXAeXWhUjg)bW9qmgsmiLQTI1aXI2JEcA5k6bCVlO0fy1L68Nd6oSun8RQeSiEBeoFsyNmo6DyQ6A8yMQ20G42H0OWIkK8YgCFTMXPg(G3T1JzCxDqQkkdShK8YgCcAcA6vVIHhu6cmsjM(prg9ae00Ry6leXWdkDbg6(KG(WelHKySA8kg7rIHJLQH)fWEpjwmIXqacPdXqGJNybgjMwEx)HeJzaSNyjqjM(1aLyBoL7b0D8kg9HaI1iIXNelHKyziMxQtX2KUl2pSahDNySxdqjMUjVGGIH(VlVRb)kOLROhW9UGsxGrkohwQg(xa79eVncNFyyrqExqPlWESACXfdlcY7tc6d7XQ97oV8ccwZ7Y7AqfsEzdoo6sqtVIPFnOpmXYqm0ZFX2KUlg)oWg2qmUHlg6eZN(lg)oWeJB4IXVdmXWXyH9EciMVdeKQrmgweeXy1elgXYptRe7gpsSnP7IXpVGe76GnJEa3tqtVIH(D3i2LiKyXigsd6dtSmeZN(l2M0DX43bMyKoZv42kMpflsikkUNy)GNEKy5j2WgxRiXUGsxG9(vqtVIPFnOpmXYqmF6VyBs3fJFhydBig3W5vm94Vy87atmUHZRyjqjM(ig)oWeJB4ILibbfthmb9HjOLROhW9UGsxGrk)5GUv6C1Cf9aQU(cEbPhXbPb9HXBJWHqqOv0FO6A8yMQ20G48JZsR6L6SEAeqXfxmSiiVdJf27jqngiivZJvB3A8yMQ20G4EkcPxD8fNV5IRtJCUAKquuCVdJf27jq9Ib65hhFUJqqOv0FO6A8yMQ20G48JJp5IR14XmvTPbX9uesV64lo8OJ)ePJaXtrKgbRxaZirrEpcKmosTJHfb59jb9H9y1(vqlxrpG7DbLUaJu(ZbDhwQg(xa79eVncNlO0fyK6DK213UtJCUAKquuCVdJf27jq9Ib69Lpf0Yv0d4ExqPlWiL)Cq3H1F4Tr4ePJaXd0OWIls3Ec(iqY4i1oilGqgik6fnyBngD2RkJlv0UtJCUAKquuCVdJf27jq9Ib69LEe00Ry)TMyXig6jwKquuCI9dyetd2ZVITNinXy1et)AGsSnNY9a6oXy2k2A7Y1auIHJLQH)fWEp9e0Yv0d4ExqPlWiL)Cq3HLQH)fWEpX7A7Yr1iHOO44WdVnchF8jHDY4Oh7rvnypWo2wHtKrpGDkIHfb5H0avLpL7b0Dpi5Ln4(INDNg5C1iHOO4EhglS3tG6fd07loO3UiHOO4fThvJPQAshHKx2GZp9rqtVIPFdumnypWo2kgCIm6bWRyShjgowQg(xa79KyZhckgEmqpX43bMyBUUrSev2GleJvtSyeZNIfjeffNyduSgrm9BZfRpXGSaqdqj2GGi2pdqSeSvS0BybHydIyrcrrX9RGwUIEa37ckDbgP8Nd6oSun8Va27jEBeoFsyNmo6XEuvd2dSJTv4ez0dy3pkIHfb5H0avLpL7b0Dpi5Ln4(IhU4kshbIhFk1gGxEbbFeizCKA3ProxnsikkU3HXc79eOEXa9(IJp)vqlxrpG7DbLUaJu(ZbDhglS3tG6fd0J3gHZProxnsikko)4GE()ddlcYlWOkCIGapwnU4cYciKbIIE5(mH9vVH1vrGjkpce)U7hgweK3T1JzCxDqQkkdSAYgZc2XJvJlU8bdlcYtdsEKQJm6b8y14IRtJCUAKquuC(Xrp)kOPxXWXs1W)cyVNelgXGecKomX0VgOeBZPCpGUtSeOelgXiWXcjX4tITsGyRec3k28HGILIHW6CIPFBUynigXcmsmaPZqm8HBI1iIPn31mo6jOLROhW9UGsxGrk)5GUdlvd)lG9EI3gHJIyyrqEinqv5t5EaD3dsEzdUV4WdxCTMXPg(G3T1JzCxDqQkkdShK8YgCFXJ(ENIyyrqEinqv5t5EaD3dsEzdUVwZ4udFW726XmURoivfLb2dsEzdobTCf9aU3fu6cms5ph0HYnJhJlveVnchgweKNgbrgygKQ(HAW9Uix79JJE2TgGITJNgbrgygKQ(HAW9GjyVFC4b9e0Yv0d4ExqPlWiL)Cq3HLQH)fWEpjOLROhW9UGsxGrk)5GUfgLA1dBcEBeo(isikkE9vzM72TgpMPQnniUNIq6vh(XHNDmSiiVdBIAdQbgvvjC)JvBhbiiQTVO9OAmvFQl)qTupVuNf8tJwLn(wF4PeLOua]] )

    
end
