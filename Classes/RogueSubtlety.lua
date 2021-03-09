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
        cold_blood = 140, -- 213981
        dagger_in_the_dark = 846, -- 198675
        death_from_above = 3462, -- 269513
        honor_among_thieves = 3452, -- 198032
        maneuverability = 3447, -- 197000
        shadowy_duel = 153, -- 207736
        silhouette = 856, -- 197899
        smoke_bomb = 1209, -- 212182
        thiefs_bargain = 146, -- 212081
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
                removeBuff( "cold_blood" )

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

                gain( 2 + ( buff.shadow_blades.up and 1 or 0 ), "combo_points" )
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
                applyBuff( "kidney_shot", 2 + 1 * ( combo - 1 ) )

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
                removeBuff( "cold_blood" )

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


        -- PvP Ability (by request)
        cold_blood = {
            id = 213981,
            cast = 0,
            cooldown = 60,
            gcd = "off",
            
            pvptalent = "cold_blood",            

            startsCombat = false,
            texture = 135988,
            
            handler = function ()
                applyBuff( "cold_blood" )
            end,

            auras = {
                cold_blood = {
                    id = 213981,
                    duration = 3600,
                    max_stack = 1,
                },        
            }
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


    spec:RegisterPack( "Subtlety", 20210307, [[dafWZbqijk9isbBsPYNqfyuOI6uOISksj0RifnluvUfPqTla)ci1WiL0Xqv1Yak9mubnnjcxtIOTHQu(gqsghqI6COkvADOkrZtPQUhu1(KO6FOkb5GOkPwiqXdvQstevOlIQeQnskrFeirgjqc0jrvQALavVeibmtsj4MOkj7uI0prvcmusHSujk8uOmvsPUkqsTvGe0xLOOXcKqNfvjO2Rq)vsdMYHfTyu8yLmzsUmYMH0NHkJgItl1Qrvc51kLMTGBlHDRQFRy4KQJJQuXYb9CvMovxhL2oq8DuPXRufNxPy(Ok2pXr(JAhXuPtXsbRwbl)ALd1kOcaSGTe8gy5pI5B0PiMEU2M4Oi2NfuedJLXdKVjIPNBctQIAhXUHfUOigI76hVe0Ggx7iSmaRPa0xxWgsVNFbtuh0xxSaDeJHTdoV)Jmrmv6uSuWQvWYVw5qTcQaalylbVPvE3iwY6idmIH1f7nIH0kf9rMiMIUvedJLXdKVrSYyWXsc48QeUqeduXNyGvRGLFbCbCE1acjgijStMabWEuvh2dS9nv44P3ZlgRUy3iw7I1Nyh5IXqOdKeJljg7rI1oGa(ENcM(jXkydERhiXwziuZL3Zxd95IrVdB6eZhXGKIDrIPpo9ENbXGe3bUfiIf6ZVO2rSZPm4iKkQDSu(JAhXOpzcKkcMiwU8E(i2HKQH75WElfXu0TGTU3ZhX49OIH5ugCeqds(9HiwcjXy15tm2Jeddjvd3ZH9wsmFeJHEcTDXqHtHyocjMEExdcjgZ8SNy5Retl7xjwzs52NUJpXiqOxSgvmUKyjKelDXkY9i2E1iX4m7hO7eJ96hNy8Q8CckgV(U8U(5ueBbBNGDgX4SymSOOaNtzWray1fJhEeJHfffaK87dbGvxmoj2oXkYZjynVlVR)kKkY(pXWlMwJESuWg1oIrFYeivemrmfDlyR798rmTS)(qelDXkHMITxnsmUTJmSUyCeJpXkPMIXTDeX4igFILVsmEtmUTJighXelrDckgOW87djILlVNpITYqOMlVNVg6ZJyly7eSZigdlkkWHWc7T0x9b(PAay1fBNyRPGzQ6t)(bOi0E1Uy7JxmWkgp8i2PtHq1tioYpGdHf2BPVE(aledVyLqSDITMcMPQp97NyLJxSsigp8i2AkyMQ(0VFakcTxTl2(4fJFX0yX4SyEgO3buePtW65W0tCuba9jtGuITtmgwuuaqYVpeawDX4uel0Nx)SGIyO93hs0JLYHrTJy0NmbsfbteBbBNGDgX8mqVd8noe)8mSLGa0Nmbsj2oXGSpHoqCeG3)MQp7PxvMqQia6tMaPeBNyNofcvpH4i)aoewyVL(65dSqS9fRKrSC598rSdPbj6Xslru7ig9jtGurWeXYL3ZhXoKunCph2BPi2AZkqvpH4i)ILYFeBbBNGDgXkRyGKWozcea7rvDypW23uHJNEpVy7etrmSOOaO9RQCPC7t3baPIS)tS9fJFX2j2PtHq1tioYpGdHf2BPVE(aleBF8IXHITtmpH4ihW7cQ6tv1KyASyqQi7)eRCX4TiMIUfS19E(igOwxmFeJdfZtioYpX48pIPd7HtITLiDXy1ftl7xjwzs52NUtmMnIT2Sc9JtmmKunCph2BjGOhlTKrTJy0NmbsfbtelxEpFe7qs1W9CyVLIyk6wWw375JyA5afth2dS9nIbhp9EE(eJ9iXWqs1W9CyVLeBaHGIH5dSqmUTJiwzYRelXL9FUyS6I5JyLqmpH4i)eBGI1OIPLLPy9jgK9)(Xj2GIkgNNxS83iwwmSVl2GkMNqCKFCkITGTtWoJyGKWozcea7rvDypW23uHJNEpVy7eJZIPigwuua0(vvUuU9P7aGur2)j2(IXVy8WJyEgO3b4sP(8f55eeG(KjqkX2j2PtHq1tioYpGdHf2BPVE(aleBF8IvcX4u0JLYBrTJy0NmbsfbteBbBNGDgXoDkeQEcXr(jw54fJdfttX4SymSOOaocvHJ70dWQlgp8igK9j0bIJaYTzc7REdBOIctCf07a0NmbsjgNeBNyCwmgwuuGBtbZeU6Gwvu6i1K1NfSDawDX4HhXkRymSOOa6qQGuTNEppaRUy8WJyNofcvpH4i)eRC8IvsX4uelxEpFe7qyH9w6RNpWIOhlfuf1oIrFYeivemrSC598rSdjvd3ZH9wkIPOBbBDVNpIHHKQH75WEljMpIbjuiDiIPL9ReRmPC7t3jw(kX8rm6pwijgxsSv(ITsiCJydieuSumu2qqmTSmfRFFeZriXEApUyydhfRrftFURzceqeBbBNGDgXuedlkkaA)Qkxk3(0DaqQi7)eBF8IXVy8WJyRzcQH7dCBkyMWvh0QIshbasfz)Ny7lg)GYITtmfXWIIcG2VQYLYTpDhaKkY(pX2xS1mb1W9bUnfmt4QdAvrPJaaPIS)l6XsbLJAhXOpzcKkcMi2c2ob7mIXWIIcOtq0bMoPQGq9FaNNRTIvoEXkPy7eBnVITDaDcIoW0jvfeQ)daM)wXkhVy8ZHrSC598rmCHzkycPIIESuE3O2rSC598rSdjvd3ZH9wkIrFYeivemrpwk)AnQDeJ(KjqQiyIyly7eSZiwzfZtioYb6RYm3j2oXwtbZu1N(9dqrO9QDXkhVy8l2oXyyrrboKXR9xDeQQs4wawDX2jg9ee3gaVlOQp1sOvXkxmClfqrUNiwU8E(i2cHs96HmE0JEetrOjBWJAhlL)O2rSC598rST9ABeJ(KjqQiyIESuWg1oIrFYeivemrSrpIDKhXYL3ZhXajHDYeOigizGLIymSOOaxOxunFvv1lcGvxmE4rStNcHQNqCKFahclS3sF98bwiw54fJ3Iyk6wWw375JyG6JuI5JykYjyr)KyCrihHGITMjOgU)jg3SDXqhOyyphfJjpsj28I5jeh5hqedKew)SGIy3RQR5vT3Zh9yPCyu7ig9jtGurWeXg9i2rEelxEpFedKe2jtGIyGKbwkIPd7b2(MkC8075fBNyNofcvpH4i)aoewyVL(65dSqSYXlgyJyk6wWw375Jy8c(WgXwi5JJedoE698I1OIXLedjbHeth2dS9nv44P3Zl2rUy5ReRGn4TEGeZtioYpXy1bIyGKW6NfueJ9OQoShy7BQWXtVNp6Xslru7ig9jtGurWeXu0TGTU3ZhX2lcT2k2E54jw6IH2WZJy5Y75JyRmeQ5Y75RH(8iwOpV(zbfXwQl6Xslzu7ig9jtGurWeXu0TGTU3ZhXkd2xmu2qyJyh32xi0jMpI5iKyyoLbhHuIvgJNEpVyCMzJyQPFCIDdFTlg6ax0jM(mH(XjwJk2pos)4eRpXsqYoKmbItarSC598rmi7xZL3Zxd95rSfSDc2ze7CkdocPaYqiIf6ZRFwqrSZPm4iKk6Xs5TO2rm6tMaPIGjILlVNpIDHEr18vvvVOiMIUfS19E(igVwxpSrSl0lQMVQQ6fjw6IbwnfBVAKykwy)4eZriXqB45IXVwf7O18QJVe1jOyos6IvcnfBVAKynQyTlgTh9gsNyCBhPFXCesSN2JlgO0E5OyduS(e7hxmw9i2c2ob7mID6uiu9eIJ8d4qyH9w6RNpWcX2xmEtSDIH24q8kKkY(pXkxmEtSDIXWIIcCHEr18vvvViaivK9FITVy4wkGICpITtS1uWmv9PF)eRC8IvcX0yX4SyExqITVy8RvX4KyArXaB0JLcQIAhXOpzcKkcMiMIUfS19E(iMgb7b2(gXkJXtVNNxiX0cKZbNy4AqiXsXwWuxSKzyDXONG42ig6afZriXoNYGJi2E54jgNzy7GIGIDEhcIbPtNwUyTZjaX4fMvNV2fBLVymKyos6IDDHEGaIy5Y75JyRmeQ5Y75RH(8i2c2ob7mIbsc7KjqaShv1H9aBFtfoE698rSqFE9ZckIDoLbhPUux0JLckh1oIrFYeivemrSrpIDKhXYL3ZhXajHDYeOigizGLIyGTKIPPyEgO3baPXnqa6tMaPetlkgy1QyAkMNb6DGI8Ccwh06HKQH7bqFYeiLyArXaRwfttX8mqVdCiPA4wrNf7bqFYeiLyArXaBjfttX8mqVdKHCbBFda9jtGuIPffdSAvmnfdSLumTOyCwStNcHQNqCKFahclS3sF98bwiw54fReIXPiMIUfS19E(igO(iLy(iMIq7NeJlc9I5JyShj25ugCeX2lhpXgOymSDqrWlIbscRFwqrSZPm4ivhbshYeurpwkVBu7ig9jtGurWeXu0TGTU3ZhX278xRiOySx)4elfdZPm4iITxokgxe6fds5cPFCI5iKy0tqCBeZrG0HmbvelxEpFeBLHqnxEpFn0NhXwW2jyNrm6jiUnakcTxTl2(4fdKe2jtGaoNYGJuDeiDitqfXc951plOi25ugCK6sDrpwk)AnQDeJ(KjqQiyIyk6wWw375JyLz7iIXrmXYWnIH2FFiILUyLqtXsCz)NlwjeZtioYpX48W6xRiXoNYGJWPiwU8E(i2kdHAU8E(AOppITGTtWoJyRPGzQ6t)(jgEXYVlYfscXrQ6sxmE4rS1uWmv9PF)aueAVAxS9Xlg)IXdpIH24q8kKkY(pX2hVy8l2oXwtbZu1N(9tSYXlghkgp8igdlkkWTPGzcxDqRkkDKAY6Zc2oaRUy7eBnfmtvF63pXkhVyLqmE4rStNcHQNqCKFahclS3sF98bwiw54fReITtS1uWmv9PF)eRC8IvIiwOpV(zbfXq7VpKOhlLF(JAhXOpzcKkcMiMIUfS19E(igO(iXsXyy7GIGIXfHEXGuUq6hNyocjg9ee3gXCeiDitqfXYL3ZhXwziuZL3Zxd95rSfSDc2zeJEcIBdGIq7v7ITpEXajHDYeiGZPm4ivhbshYeurSqFE9ZckIXW2bv0JLYpyJAhXOpzcKkcMiwU8E(iwcx5tvFGq69iMIUfS19E(iMwy4sNlMoShy7BeRFXYqqSbvmhHeJxRrAbXyOvYEKyTl2kzp6elfduAVCmITGTtWoJy0tqCBaueAVAxSYXlg)LumnfJEcIBdaKWrF0JLYphg1oILlVNpILWv(uvNnCueJ(KjqQiyIESu(lru7iwU8E(iwOXH4xLxeRcxb9EeJ(KjqQiyIESu(lzu7iwU8E(igtIRoOvh2RTxeJ(KjqQiyIE0Jy6qAnfmPh1owk)rTJy5Y75JyPUEytvF6B(ig9jtGurWe9yPGnQDelxEpFeJzCpqQkAi3qkU9JR6ZE6pIrFYeivemrpwkhg1oILlVNpIDoLbhjIrFYeivemrpwAjIAhXOpzcKkcMiwU8E(iwrc3sQk6aRkkDKiMoKwtbt61JwZRUig)Lm6Xslzu7ig9jtGurWeXYL3ZhXUqVOA(QQQxueBbBNGDgXGekKoKKjqrmDiTMcM0RhTMxDrm(JESuElQDeJ(KjqQiyIyly7eSZigK9j0bIJaks426GwDeQwKNtWAExEx)a0NmbsfXYL3ZhXoKunCRmHurx0JEedT)(qIAhlL)O2rm6tMaPIGjIn6rSJ8iwU8E(igijStMafXajdSueZZa9oGoKkiv7P3ZdqFYeiLy7e70PqO6jeh5hWHWc7T0xpFGfITVyCwSskMgl2AaH(8DGNwWjmqLyCsSDIvwXwdi0NVdSDdSZpIPOBbBDVNpIvMiDGeJ96hNyAeKkiv7P3ZZNyjitReBLN3poXWc9IelFLyCSxKyCrOxmmKunCfJJ5ViX6tSBMxmFeJHeJ9ifFIr7zr6UyOdumqb2a78JyGKW6NfuethsfKQEVQUMx1EpF0JLc2O2rm6tMaPIGjITGTtWoJyLvmqsyNmbcqhsfKQEVQUMx1EpVy7e70PqO6jeh5hWHWc7T0xpFGfITVy8My7eRSIXWIIcCiPA4wv5ViawDX2jgdlkkWf6fvZxvv9IaGur2)j2(IH24q8kKkY(pX2jgKqH0HKmbkILlVNpIDHEr18vvvVOOhlLdJAhXOpzcKkcMi2c2ob7mIbsc7Kjqa6qQGu17v118Q275fBNyRzcQH7dCiPA4wv5ViGfscXrxffMlVNpdITVy8daQkPy7eJHfff4c9IQ5RQQEraqQi7)eBFXwZeud3h42uWmHRoOvfLocaKkY(pX2jgNfBntqnCFGdjvd3Qk)fbaPuTrSDIXWIIcCBkyMWvh0QIshbasfz)NyASymSOOahsQgUvv(lcasfz)Ny7lg)aGvmofXYL3ZhXUqVOA(QQQxu0JLwIO2rm6tMaPIGjIn6rSJ8iwU8E(igijStMafXajdSueRipNG18U8U(RqQi7)eRCX0Qy8WJyLvmpd07aFJdXppdBjia9jtGuITtmpd07aQeUTEiPA4cqFYeiLy7eJHfff4qs1WTQYFraS6IXdpID6uiu9eIJ8d4qyH9w6RNpWcXkhVy8wedKew)SGIy32wVcz1Dwif9yPLmQDeJ(KjqQiyIy5Y75JyqwDNfsrmfDlyR798rmqbisxmwDXkdwDNfsI1OI1Uy9jwYmSUy(igK9fByDGi2c2ob7mIXzXkRyGKWozceWTT1RqwDNfsIXdpIbsc7KjqaShv1H9aBFtfoE698IXjX2jMNqCKd4Dbv9PQAsmnwmivK9FIvUy8My7edsOq6qsMaf9yP8wu7iwU8E(i2rli5vNwiFZ7Wsrm6tMaPIGj6XsbvrTJy0NmbsfbtelxEpFedYQ7SqkIT2Scu1tioYVyP8hXwW2jyNrSYkgijStMabCBB9kKv3zHKy7eRSIbsc7KjqaShv1H9aBFtfoE698ITtStNcHQNqCKFahclS3sF98bwiw54fdSITtmpH4ihW7cQ6tv1KyLJxmolwjfttX4SyGvmTOyRPGzQ6t)(jgNeJtITtmiHcPdjzcuetr3c26EpFeJxXg8wnU3poX8eIJ8tmhjDX42HGyHgesm0bkMJqIPyHP3Zl2GkwzWQ7SqsmiHcPdrmflSFCIPNVIk6fq0JLckh1oIrFYeivemrSC598rmiRUZcPiMIUfS19E(iwzqOq6qeRmy1DwijgLWWgXAuXAxmUDiigTh9gsIPyH9JtmSnfmt4aeJJJyos6IbjuiDiI1OIHnCumCKFIbPuTrS(fZriXEApUyL8aIyly7eSZiwzfdKe2jtGaUTTEfYQ7SqsSDIbPIS)tS9fBntqnCFGBtbZeU6Gwvu6iaqQi7)ettX4xRITtS1mb1W9bUnfmt4QdAvrPJaaPIS)tS9XlwjfBNyEcXroG3fu1NQQjX0yXGur2)jw5ITMjOgUpWTPGzcxDqRkkDeaivK9FIPPyLm6Xs5DJAhXOpzcKkcMi2c2ob7mIvwXajHDYeia2JQ6WEGTVPchp9EEX2j2PtHq1tioYpXkhVyCyelxEpFeJjKRTv9HRIGrpwk)AnQDelxEpFeJaPVfbtNIy0Nmbsfbt0JEeBPUO2Xs5pQDeJ(KjqQiyIyly7eSZiwzfJHfff4qs1WTQYFraS6ITtmgwuuGdHf2BPV6d8t1aWQl2oXyyrrboewyVL(QpWpvdaKkY(pX2hVyCiqjJyShvhu0kULkwk)rSC598rSdjvd3Qk)ffXu0TGTU3ZhXa1hjghZFrInOOAmULsmgcDGKyocjgAdpxSdHf2BPVE(aledfofIP9a)unITMc6eRFGOhlfSrTJy0NmbsfbteBbBNGDgXyyrrboewyVL(QpWpvdaRUy7eJHfff4qyH9w6R(a)unaqQi7)eBF8IXHaLmIXEuDqrR4wQyP8hXYL3ZhXUnfmt4QdAvrPJeXu0TGTU3ZhX4mO(d0DILbiLQnIXQlgdTs2JeJljMpZwXWqs1WvmTCwShNeJ9iXW2uWmHtSbfvJXTuIXqOdKeZriXqB45IDiSWEl91ZhyHyOWPqmTh4NQrS1uqNy9de9yPCyu7ig9jtGurWeXwW2jyNrmqsyNmbc4EvDnVQ9EEX2jwzf7CkdocPakY3duelxEpFednK4Oqi9E(OhlTerTJy0NmbsfbteBbBNGDgXuedlkkaAiXrHq698aqQi7)eBFXaBelxEpFednK4Oqi9E(6kq5Fu0JLwYO2rm6tMaPIGjITGTtWoJyCwmi7tOdehbuKWT1bT6iuTipNG18U8U(bOpzcKsSDITMcMPQp97hGIq7v7ITpEX4xmnwmpd07akI0jy9Cy6eoQaG(KjqkX4HhXGSpHoqCeGIshjSPEiPA4Ea0Nmbsj2oXwtbZu1N(9tS9fJFX4Ky7eJHfff42uWmHRoOvfLocaRUy7eJHfff4qs1WTQYFraS6ITtSI8CcwZ7Y76VcPIS)tm8IPvX2jgdlkkGIshjSPEiPA4EaQH7hXYL3ZhXaj)(qIESuElQDeJ(KjqQiyIyk6wWw375JyA0mbXqhOyApWpvJy6qsJXgokg32reddHJIbPuTrmUi0l2pUyq2)7hNyyAjqedDG1N2JhlL)i2c2ob7mI5zGEh4qyH9w6R(a)una0Nmbsj2oXkRyEgO3boKunCROZI9aOpzcKkILlVNpIPptOcPByHlk6XsbvrTJy0NmbsfbtelxEpFe7qyH9w6R(a)unrmfDlyR798rmq9rIP9a)unIPdjXWgokgxe6fJljgsccjMJqIrpbXTrmUiKJqqXqHtHy6Ze6hNyCBhzyDXW0sXgOy8IypxmC0tWme2aeXwW2jyNrm6jiUnIvoEX4nTk2oXajHDYeiG7v118Q275fBNyRzcQH7dCBkyMWvh0QIshbGvxSDITMjOgUpWHKQHBvL)IawijehDIvoEX4p6XsbLJAhXOpzcKkcMiwU8E(i2rqy6KQYmpvp9ElfXwW2jyNrmqsyNmbc4EvDnVQ9EEX2jwzftnoWrqy6KQYmpvp9ElvvJd49AB)4eBNyEcXroG3fu1NQQjXkhVyGLFX4HhXqBCiEfsfz)Ny7JxSsk2oXoDkeQEcXr(bCiSWEl91ZhyHy7lghgXwBwbQ6jeh5xSu(JESuE3O2rm6tMaPIGjITGTtWoJyGKWozceW9Q6AEv798ITtS1uWmv9PF)aueAVAxSYXlg)rSC598rSJ0V(IESu(1Au7ig9jtGurWeXYL3ZhXUnfmt4QdAvrPJeXu0TGTU3ZhXa1hjg2McMjCInVyRzcQH7lgNtuNGIH2WZfd75iNeJ9d0DIXLelHKy4M(XjMpIPp6IP9a)unILVsm1i2pUyijiKyyiPA4kMwol2diITGTtWoJyGKWozceW9Q6AEv798ITtmolMNb6Da6bHcJE)4QhsQgUha9jtGuIXdpITMjOgUpWHKQHBvL)IawijehDIvoEX4xmoj2oX4SyLvmpd07ahclS3sF1h4NQbG(KjqkX4HhX8mqVdCiPA4wrNf7bqFYeiLy8WJyRzcQH7dCiSWEl9vFGFQgaivK9FIvUyGvmof9yP8ZFu7ig9jtGurWeXYL3ZhXks4wsvrhyvrPJeXwBwbQ6jeh5xSu(Jyly7eSZigmBvLaHEhivQdGvxSDIXzX8eIJCaVlOQpvvtITVyRPGzQ6t)(bOi0E1Uy8WJyLvSZPm4iKcidbX2j2AkyMQ(0VFakcTxTlw54fBPxlY9upD6vIXPiMIUfS19E(igVhvSuPoXsijgRoFIDFRtI5iKyZtIXTDeXcdx6CX0wBocigO(iX4IqVyQn9Jtm08CckMJKVy7vJetrO9QDXgOy)4IDoLbhHuIXTDKH1fl)nITxnci6Xs5hSrTJy0NmbsfbtelxEpFeRiHBjvfDGvfLosetr3c26EpFeJ3Jk2pILk1jg3oeet1KyCBhPFXCesSN2JlghQ1JpXypsmEfkhfBEXyM7eJB7idRlw(BeBVAeqeBbBNGDgXGzRQei07aPsDa9lw5IXHAvmnwmy2Qkbc9oqQuhGIfMEpVy7eBnfmtvF63pafH2R2fRC8IT0Rf5EQNo9QOhlLFomQDeJ(KjqQiyIyly7eSZigijStMabCVQUMx1EpVy7eBnfmtvF63pafH2R2fRC8Ib2iwU8E(i2HKQHBLjKk6IESu(lru7ig9jtGurWeXwW2jyNrmqsyNmbc4EvDnVQ9EEX2j2AkyMQ(0VFakcTxTlw54fdSITtmolgijStMabWEuvh2dS9nv44P3Zlgp8i2PtHq1tioYpGdHf2BPVE(aleBF8IvcX4uelxEpFeJwit)4Qqsh2f5RIESu(lzu7ig9jtGurWeXYL3ZhXoewyVL(QpWpvtetr3c26EpFeRmBhrmmTKpXAuX(XfldqkvBetnpXNyShjM2d8t1ig32redB4OyS6arSfSDc2zeZZa9oWHKQHBfDwSha9jtGuITtmqsyNmbc4EvDnVQ9EEX2jgdlkkWTPGzcxDqRkkDeaw9OhlLFElQDeJ(KjqQiyIyly7eSZiwzfJHfff4qs1WTQYFraS6ITtm0ghIxHur2)j2(4fduwmnfZZa9oWXY4eeLfhbqFYeivelxEpFe7qs1WTQYFrrpwk)GQO2rm6tMaPIGjITGTtWoJymSOOamHzub2ZbGuUCX4HhXqBCiEfsfz)Ny7lghQvX4HhXyyrrbUnfmt4QdAvrPJaWQl2oX4SymSOOahsQgUvMqQOdGvxmE4rS1mb1W9boKunCRmHurhaKkY(pX2hVy8RvX4uetr3c26EpFeR0514tNwIDolkQyCBhrSWWLGIPd7jILlVNpIPpEpF0JLYpOCu7ig9jtGurWeXwW2jyNrmgwuuGBtbZeU6Gwvu6iaS6rSC598rmMWmQkklCt0JLYpVBu7ig9jtGurWeXwW2jyNrmgwuuGBtbZeU6Gwvu6iaS6rSC598rmgcEeCB)4IESuWQ1O2rm6tMaPIGjITGTtWoJymSOOa3McMjC1bTQO0ray1Jy5Y75JyOnKycZOIESuWYFu7ig9jtGurWeXwW2jyNrmgwuuGBtbZeU6Gwvu6iaS6rSC598rS8x05Wmuxzie9yPGfSrTJy0NmbsfbtelxEpFeJ9OA7uXfXu0TGTU3ZhX4iHMSbxm0meyY1wXqhOySxYeiXANkoEPyG6JeJB7iIHTPGzcNydQyCKshbiITGTtWoJymSOOa3McMjC1bTQO0ray1fJhEedTXH4vivK9FITVyGvRrp6rSZPm4i1L6IAhlL)O2rm6tMaPIGjIn6rSJ8iwU8E(igijStMafXajdSueBntqnCFGdjvd3Qk)fbSqsio6QOWC598zqSYXlg)aGQsgXajH1plOi2HOQocKoKjOIESuWg1oIrFYeivemrSC598rmqYVpKiMIUfS19E(igOW87drSgvmUKyjKeBL669JtS5fJJ5ViXwijehDaIXloHHnIXqOdKedTHNlMk)fjwJkgxsmKeesSFeR0ghIFEg2sqXyyDX4yc3kggsQgUI1VydurqX8rmCKlwzWQ7SqsmwDX48pIXRYZjOy867Y76NtarSfSDc2zeJZIvwXajHDYeiGdrvDeiDitqjgp8iwzfZZa9oW34q8ZZWwccqFYeiLy7eZZa9oGkHBRhsQgUa0NmbsjgNeBNyRPGzQ6t)(bOi0E1UyLlg)ITtSYkgK9j0bIJaks426GwDeQwKNtWAExEx)a0Nmbsf9yPCyu7ig9jtGurWeXYL3ZhX0NjuH0nSWffXO94WSMfd77rSsO1ig6aRpThpwk)rpwAjIAhXOpzcKkcMi2c2ob7mIrpbXTrSYXlwj0Qy7eJEcIBdGIq7v7IvoEX4xRITtSYkgijStMabCiQQJaPdzckX2j2AkyMQ(0VFakcTxTlw5IXVy7etrmSOOaO9RQCPC7t3baPIS)tS9fJ)iwU8E(i2HKQHBbfurpwAjJAhXOpzcKkcMi2OhXoYJy5Y75JyGKWozcuedKmWsrS1uWmv9PF)aueAVAxSYXlgyfttXyyrrboKunCRmHurhaREetr3c26EpFeBVAKyocKoKjOoXqhOy07eSFCIHHKQHRyCm)ffXajH1plOi2HOQRPGzQ6t)(f9yP8wu7ig9jtGurWeXg9i2rEelxEpFedKe2jtGIyGKbwkITMcMPQp97hGIq7v7IvoEX4Wi2c2ob7mITgqOpFhy7gyNFedKew)SGIyhIQUMcMPQp97x0JLcQIAhXOpzcKkcMi2OhXoYJy5Y75JyGKWozcuedKmWsrS1uWmv9PF)aueAVAxS9Xlg)rSfSDc2zedKe2jtGaypQQd7b2(MkC8075fBNyNofcvpH4i)aoewyVL(65dSqSYXlwjIyGKW6Nfue7qu11uWmv9PF)IESuq5O2rm6tMaPIGjILlVNpIDiPA4wv5VOiMIUfS19E(ighZFrIPyH9JtmSnfmt4eBGILmdiKyocKoKjOaIyly7eSZigijStMabCiQ6AkyMQ(0VFITtmolgijStMabCiQQJaPdzckX4HhXyyrrbUnfmt4QdAvrPJaaPIS)tSYXlg)aGvmE4rStNcHQNqCKFahclS3sF98bwiw54fReITtS1mb1W9bUnfmt4QdAvrPJaaPIS)tSYfJFTkgNIESuE3O2rm6tMaPIGjILlVNpIDiPA4wv5VOiMIUfS19E(igyyHVyqQi7VFCIXX8x0jgdHoqsmhHedTXH4IrV6eRrfdB4OyCNNdCXyiXGuQ2iw)I5DbbeXwW2jyNrmqsyNmbc4qu11uWmv9PF)eBNyOnoeVcPIS)tS9fBntqnCFGBtbZeU6Gwvu6iaqQi7)IE0JymSDqf1owk)rTJy0NmbsfbteBbBNGDgXkRyEgO3b(ghIFEg2sqa6tMaPeBNyq2NqhiocW7Ft1N90Rktivea9jtGuITtStNcHQNqCKFahclS3sF98bwi2(IvYiwU8E(i2H0Ge9yPGnQDeJ(KjqQiyIyly7eSZi2PtHq1tioYpXkhVyGvSDIXzXwZeud3h4iimDsvzMNQNEVLawijehDvuyU8E(mi2(4fdSaGQskgp8i2PtHq1tioYpGdHf2BPVE(aleRCXkHyCkILlVNpIDiSWEl91Zhyr0JLYHrTJy0NmbsfbteBbBNGDgXwZeud3h4iimDsvzMNQNEVLawijehDvuyU8E(miw54fdSaGQskgp8i2nSbM(vabkvvMnvApzHEGaOpzcKsSDIvwXyyrrbcuQQmBQ0EYc9abWQhXYL3ZhXocctNuvM5P6P3BPOhlTerTJy5Y75Jy4cZuWesffXOpzcKkcMOhlTKrTJy5Y75Jym5A75jteJ(KjqQiyIE0JEedecE98XsbRwbRw5hS8dQIyCt43pUlIvM86YOuEFPGs8sXetBesSUqFGUyOdumo4CkdocP4aXGeVdBdjLy3uqILS(uKoPeBHKpo6aeW1c9tIXH8sX278GqqNuIXbq2NqhiocauKdeZhX4ai7tOdehbakcqFYeifhigN5FpCcqaxl0pjgVXlfBVZdcbDsjghazFcDG4iaqroqmFeJdGSpHoqCeaOia9jtGuCGyCM)9WjabCTriXqNqy42poXswyEIXLGKyShPeRFXCesSC598If6ZfJH1fJlbjX(XfdDyFLy9lMJqILk18IPspzYJ4Lc4IPXIDBkyMWvh0QIshPMS(SGTlGlGxM86YOuEFPGs8sXetBesSUqFGUyOdumoqrOjBW5aXGeVdBdjLy3uqILS(uKoPeBHKpo6aeW1gHedDcHHB)4elzH5jgxcsIXEKsS(fZriXYL3ZlwOpxmgwxmUeKe7hxm0H9vI1VyocjwQuZlMk9KjpIxkGlMgl2TPGzcxDqRkkDKAY6Zc2UaUaEzYRlJs59LckXlftmTriX6c9b6IHoqX4aDiTMcM05aXGeVdBdjLy3uqILS(uKoPeBHKpo6aeW1c9tIXB8sX278GqqNuIXbq2NqhiocauKdeZhX4ai7tOdehbakcqFYeifhiw6IXlMxGwqmoZ)E4eGaUaEzYRlJs59LckXlftmTriX6c9b6IHoqX4GL64aXGeVdBdjLy3uqILS(uKoPeBHKpo6aeW1c9tIvsEPy7DEqiOtkX4ai7tOdehbakYbI5JyCaK9j0bIJaafbOpzcKIdeJZGDpCcqaxaVm51LrP8(sbL4LIjM2iKyDH(aDXqhOyCW5ugCK6sDCGyqI3HTHKsSBkiXswFksNuITqYhhDac4AH(jXalVuS9opie0jLyCaK9j0bIJaaf5aX8rmoaY(e6aXraGIa0NmbsXbILUy8I5fOfeJZ8VhobiGlGxM86YOuEFPGs8sXetBesSUqFGUyOdumoGHTdkoqmiX7W2qsj2nfKyjRpfPtkXwi5JJoabCTq)Ky8ZlfBVZdcbDsjghazFcDG4iaqroqmFeJdGSpHoqCeaOia9jtGuCGyCM)9WjabCbCEFH(aDsjgOsSC598If6Zpab8iMoCq7afX0GgedJLXdKVrSYyWXsc4AqdIXRs4crmqfFIbwTcw(fWfW1GgeJxnGqIbsc7KjqaShv1H9aBFtfoE698IXQl2nI1Uy9j2rUyme6ajX4sIXEKyTdiGRbni2ENcM(jXkydERhiXwziuZL3Zxd95IrVdB6eZhXGKIDrIPpo9ENbXGe3bUfqaxaxdAqmncsA8ENcM0fWZL3ZFa6qAnfmPRjEqN66Hnv9PV5fWZL3ZFa6qAnfmPRjEqZmUhivfnKBif3(Xv9zp9lGNlVN)a0H0Akysxt8G(CkdoIaEU8E(dqhsRPGjDnXd6IeULuv0bwvu6i8PdP1uWKE9O18Qdp)LuapxEp)bOdP1uWKUM4b9f6fvZxvv9I4thsRPGj96rR5vhE(5RrXdjuiDijtGeWZL3ZFa6qAnfmPRjEqFiPA4wzcPIo(Au8q2NqhiocOiHBRdA1rOArEobR5D5D9lGlGRbnigVk7xSYy8075fWZL3ZF432RTc4Aqmq9rkX8rmf5eSOFsmUiKJqqXwZeud3)eJB2UyOdumSNJIXKhPeBEX8eIJ8dqapxEp)PjEqdsc7Kjq89zbH)EvDnVQ9EE(ajdSeEgwuuGl0lQMVQQ6fbWQZdpNofcvpH4i)aoewyVL(65dSOC88MaUgeJxWh2i2cjFCKyWXtVNxSgvmUKyijiKy6WEGTVPchp9EEXoYflFLyfSbV1dKyEcXr(jgRoGaEU8E(tt8GgKe2jtG47Zccp7rvDypW23uHJNEppFGKbwcVoShy7BQWXtVNF3PtHq1tioYpGdHf2BPVE(alkhpyfW1Gy7fHwBfBVC8elDXqB45c45Y75pnXd6vgc1C5981qFoFFwq4xQtaxdIvgSVyOSHWgXoUTVqOtmFeZriXWCkdocPeRmgp9EEX4mZgXut)4e7g(Axm0bUOtm9zc9JtSgvSFCK(XjwFILGKDizceNaeWZL3ZFAIh0q2VMlVNVg6Z57Zcc)5ugCesXxJI)CkdocPaYqqaxdIXR11dBe7c9IQ5RQQErILUyGvtX2RgjMIf2poXCesm0gEUy8RvXoAnV64lrDckMJKUyLqtX2RgjwJkw7Ir7rVH0jg32r6xmhHe7P94IbkTxok2afRpX(XfJvxapxEp)PjEqFHEr18vvvVi(Au8NofcvpH4i)aoewyVL(65dSyFEBhAJdXRqQi7)kN32XWIIcCHEr18vvvViaivK9F7JBPakY9SBnfmtvF63VYXxcnMZExq7ZVw5KweSc4Aqmnc2dS9nIvgJNEppVqIPfiNdoXW1GqILITGPUyjZW6IrpbXTrm0bkMJqIDoLbhrS9YXtmoZW2bfbf78oeedsNoTCXANtaIXlmRoFTl2kFXyiXCK0f76c9abiGNlVN)0epOxziuZL3Zxd9589zbH)CkdosDPo(Au8GKWozcea7rvDypW23uHJNEpVaUgeduFKsmFetrO9tIXfHEX8rm2Je7CkdoIy7LJNydumg2oOi4jGNlVN)0epObjHDYei((SGWFoLbhP6iq6qMGIpqYalHhSLutpd07aG04gia9jtGuArWQvn9mqVduKNtW6GwpKunCpa6tMaP0IGvRA6zGEh4qs1WTIol2dG(KjqkTiylPMEgO3bYqUGTVbG(KjqkTiy1QMGTKAroF6uiu9eIJ8d4qyH9w6RNpWIYXxcojGRbX278xRiOySx)4elfdZPm4iITxokgxe6fds5cPFCI5iKy0tqCBeZrG0HmbLaEU8E(tt8GELHqnxEpFn0NZ3Nfe(ZPm4i1L64RrXtpbXTbqrO9Q99Xdsc7KjqaNtzWrQocKoKjOeW1GyAz)9Hiw6IvcnfJB7idRlghXeBGIXTDeXWgok2c2UymSOO8jwj1umUTJighXeJZdRFTIe7CkdocNeW1GyLz7iIXrmXYWnIH2FFiILUyLqtXsCz)NlwjeZtioYpX48W6xRiXoNYGJWjb8C598NM4b9kdHAU8E(AOpNVpli8O93hcFnk(1uWmv9PF)WNFxKlKeIJu1Lop8SMcMPQp97hGIq7v77JNFE4bTXH4vivK9F7JN)DRPGzQ6t)(voEoKhEyyrrbUnfmt4QdAvrPJutwFwW2by13TMcMPQp97x54lbp8C6uiu9eIJ8d4qyH9w6RNpWIYXxIDRPGzQ6t)(vo(siGRbXa1hjwkgdBhueumUi0lgKYfs)4eZriXONG42iMJaPdzckb8C598NM4b9kdHAU8E(AOpNVpli8mSDqXxJINEcIBdGIq7v77JhKe2jtGaoNYGJuDeiDitqjGRbX0cdx6CX0H9aBFJy9lwgcInOI5iKy8AnsligdTs2JeRDXwj7rNyPyGs7LJc45Y75pnXd6eUYNQ(aH0781O4PNG42aOi0E1E545VKAspbXTbas4OxapxEp)PjEqNWv(uvNnCKaEU8E(tt8Go04q8RYlIvHRGExapxEp)PjEqZK4QdA1H9A7jGlGRbnigyy7GIGNaEU8E(dGHTdk8hsdcFnk(Y6zGEh4BCi(5zylbbOpzcKAhK9j0bIJa8(3u9zp9QYesfT70PqO6jeh5hWHWc7T0xpFGf7xsb8C598hadBhuAIh0hclS3sF98bwWxJI)0PqO6jeh5x54b7ooVMjOgUpWrqy6KQYmpvp9ElbSqsio6QOWC598zyF8GfauvsE450PqO6jeh5hWHWc7T0xpFGfLxcojGNlVN)ayy7Gst8G(iimDsvzMNQNEVL4RrXVMjOgUpWrqy6KQYmpvp9ElbSqsio6QOWC598zOC8GfauvsE45g2at)kGaLQkZMkTNSqpqa0NmbsTRSmSOOabkvvMnvApzHEGay1fWZL3ZFamSDqPjEqJlmtbtivKaEU8E(dGHTdknXdAMCT98KraxaxdAqS9otqnC)taxdIbQpsmoM)IeBqr1yClLyme6ajXCesm0gEUyhclS3sF98bwigkCket7b(PAeBnf0jw)ac45Y75pGL60epOpKunCRQ8xeFShvhu0kULcp)81O4lldlkkWHKQHBvL)Iay13XWIIcCiSWEl9vFGFQgaw9DmSOOahclS3sF1h4NQbasfz)3(45qGskGRbX4mO(d0DILbiLQnIXQlgdTs2JeJljMpZwXWqs1WvmTCwShNeJ9iXW2uWmHtSbfvJXTuIXqOdKeZriXqB45IDiSWEl91ZhyHyOWPqmTh4NQrS1uqNy9diGNlVN)awQtt8G(2uWmHRoOvfLocFShvhu0kULcp)81O4zyrrboewyVL(QpWpvdaR(ogwuuGdHf2BPV6d8t1aaPIS)BF8CiqjfWZL3ZFal1PjEqJgsCuiKEppFnkEqsyNmbc4EvDnVQ9E(DL9CkdocPakY3dKaEU8E(dyPonXdA0qIJcH075RRaL)r81O4vedlkkaAiXrHq698aqQi7)2hSc45Y75pGL60epObj)(q4RrXZzi7tOdehbuKWT1bT6iuTipNG18U8U(3TMcMPQp97hGIq7v77JNFn2Za9oGIiDcwphMoHJkaOpzcKIhEGSpHoqCeGIshjSPEiPA4E7wtbZu1N(9BF(50ogwuuGBtbZeU6Gwvu6iaS67yyrrboKunCRQ8xeaR(UI8CcwZ7Y76VcPIS)dVw3XWIIcOO0rcBQhsQgUhGA4(c4AqmnAMGyOdumTh4NQrmDiPXydhfJB7iIHHWrXGuQ2igxe6f7hxmi7)9JtmmTeqapxEp)bSuNM4bT(mHkKUHfUi(qhy9P9445NVgfVNb6DGdHf2BPV6d8t1aqFYei1UY6zGEh4qs1WTIol2dG(KjqkbCnigO(iX0EGFQgX0HKyydhfJlc9IXLedjbHeZriXONG42igxeYriOyOWPqm9zc9JtmUTJmSUyyAPydumErSNlgo6jygcBaeWZL3ZFal1PjEqFiSWEl9vFGFQg(Au80tqCBkhpVP1DGKWozceW9Q6AEv7987wZeud3h42uWmHRoOvfLocaR(U1mb1W9boKunCRQ8xeWcjH4ORC88lGNlVN)awQtt8G(iimDsvzMNQNEVL4BTzfOQNqCKF45NVgfpijStMabCVQUMx1Ep)UYQgh4iimDsvzMNQNEVLQQXb8ETTFC78eIJCaVlOQpvvtLJhS8ZdpOnoeVcPIS)BF8LC3PtHq1tioYpGdHf2BPVE(al2NdfWZL3ZFal1PjEqFK(1hFnkEqsyNmbc4EvDnVQ9E(DRPGzQ6t)(bOi0E1E545xaxdIbQpsmSnfmt4eBEXwZeud3xmoNOobfdTHNlg2Zrojg7hO7eJljwcjXWn9JtmFetF0ft7b(PAelFLyQrSFCXqsqiXWqs1WvmTCwShGaEU8E(dyPonXd6BtbZeU6Gwvu6i81O4bjHDYeiG7v118Q2753Xzpd07a0dcfg9(XvpKunCpa6tMaP4HN1mb1W9boKunCRQ8xeWcjH4ORC88ZPDCUSEgO3boewyVL(QpWpvda9jtGu8WJNb6DGdjvd3k6Sypa6tMaP4HN1mb1W9boewyVL(QpWpvdaKkY(VYblNeW1Gy8EuXsL6elHKyS68j29TojMJqInpjg32relmCPZftBT5iGyG6JeJlc9IP20poXqZZjOyos(ITxnsmfH2R2fBGI9Jl25ugCesjg32rgwxS83i2E1iab8C598hWsDAIh0fjClPQOdSQO0r4BTzfOQNqCKF45NVgfpmBvLaHEhivQdGvFhN9eIJCaVlOQpvvt7VMcMPQp97hGIq7v78WtzpNYGJqkGme2TMcMPQp97hGIq7v7LJFPxlY9upD6vCsaxdIX7rf7hXsL6eJBhcIPAsmUTJ0Vyocj2t7XfJd16XNyShjgVcLJInVymZDIXTDKH1fl)nITxncqapxEp)bSuNM4bDrc3sQk6aRkkDe(Au8WSvvce6DGuPoG(lNd1QgdZwvjqO3bsL6auSW0753TMcMPQp97hGIq7v7LJFPxlY9upD6vc45Y75pGL60epOpKunCRmHurhFnkEqsyNmbc4EvDnVQ9E(DRPGzQ6t)(bOi0E1E54bRaEU8E(dyPonXdAAHm9JRcjDyxKVIVgfpijStMabCVQUMx1Ep)U1uWmv9PF)aueAVAVC8GDhNbjHDYeia2JQ6WEGTVPchp9EEE450PqO6jeh5hWHWc7T0xpFGf7JVeCsaxdIvMTJigMwYNynQy)4ILbiLQnIPMN4tm2Jet7b(PAeJB7iIHnCumwDab8C598hWsDAIh0hclS3sF1h4NQHVgfVNb6DGdjvd3k6Sypa6tMaP2bsc7Kjqa3RQR5vT3ZVJHfff42uWmHRoOvfLocaRUaEU8E(dyPonXd6djvd3Qk)fXxJIVSmSOOahsQgUvv(lcGvFhAJdXRqQi7)2hpOSMEgO3bowgNGOS4ia6tMaPeW1GyLoVgF60sSZzrrfJB7iIfgUeumDypc45Y75pGL60epO1hVNNVgfpdlkkatygvG9CaiLlNhEqBCiEfsfz)3(COw5HhgwuuGBtbZeU6Gwvu6iaS674mdlkkWHKQHBLjKk6ay15HN1mb1W9boKunCRmHurhaKkY(V9XZVw5KaEU8E(dyPonXdAMWmQkklCdFnkEgwuuGBtbZeU6Gwvu6iaS6c45Y75pGL60epOzi4rWT9JJVgfpdlkkWTPGzcxDqRkkDeawDb8C598hWsDAIh0OnKycZO4RrXZWIIcCBkyMWvh0QIshbGvxapxEp)bSuNM4bD(l6CygQRme4RrXZWIIcCBkyMWvh0QIshbGvxaxdIXrcnzdUyOziWKRTIHoqXyVKjqI1ovC8sXa1hjg32redBtbZeoXguX4iLocGaEU8E(dyPonXdA2JQTtfhFnkEgwuuGBtbZeU6Gwvu6iaS68WdAJdXRqQi7)2hSAvaxaxdAqmTS)(qi4jGRbXktKoqIXE9JtmncsfKQ90755tSeKPvITYZ7hNyyHErILVsmo2lsmUi0lggsQgUIXX8xKy9j2nZlMpIXqIXEKIpXO9SiDxm0bkgOaBGD(c45Y75pa0(7dbpijStMaX3NfeEDivqQ69Q6AEv7988bsgyj8EgO3b0HubPAp9EEa6tMaP2D6uiu9eIJ8d4qyH9w6RNpWI95Cj141ac957apTGtyGkoTRSRbe6Z3b2Ub25lGNlVN)aq7VpenXd6l0lQMVQQ6fXxJIVSGKWozceGoKkiv9EvDnVQ9E(DNofcvpH4i)aoewyVL(65dSyFEBxzzyrrboKunCRQ8xeaR(ogwuuGl0lQMVQQ6fbaPIS)BF0ghIxHur2)TdsOq6qsMajGNlVN)aq7VpenXd6l0lQMVQQ6fXxJIhKe2jtGa0HubPQ3RQR5vT3ZVBntqnCFGdjvd3Qk)fbSqsio6QOWC598zyF(bavLChdlkkWf6fvZxvv9IaGur2)T)AMGA4(a3McMjC1bTQO0raGur2)TJZRzcQH7dCiPA4wv5ViaiLQn7yyrrbUnfmt4QdAvrPJaaPIS)tJzyrrboKunCRQ8xeaKkY(V95haSCsapxEp)bG2FFiAIh0GKWozceFFwq4VTTEfYQ7SqIpqYalHVipNG18U8U(RqQi7)kxR8Wtz9mqVd8noe)8mSLGa0NmbsTZZa9oGkHBRhsQgUa0NmbsTJHfff4qs1WTQYFraS68WZPtHq1tioYpGdHf2BPVE(alkhpVXhOGuqNGIbkmHDYeiXqhOyLbRUZcjaXW226IPyH9JtmEvEobfJxFxEx)InqXuSW(XjghZFrIXTDeX4yc3kw(kX(rSsBCi(5zylbbeW1GyGcqKUyS6IvgS6olKeRrfRDX6tSKzyDX8rmi7l2W6ac45Y75pa0(7drt8GgYQ7SqIVgfpNllijStMabCBB9kKv3zHep8asc7KjqaShv1H9aBFtfoE698CANNqCKd4Dbv9PQAsJHur2)voVTdsOq6qsMajGNlVN)aq7VpenXd6JwqYRoTq(M3HLeW1Gy8k2G3QX9(XjMNqCKFI5iPlg3oeel0GqIHoqXCesmflm9EEXguXkdwDNfsIbjuiDiIPyH9Jtm98vurVaeWZL3ZFaO93hIM4bnKv3zHeFRnRav9eIJ8dp)81O4llijStMabCBB9kKv3zH0UYcsc7KjqaShv1H9aBFtfoE6987oDkeQEcXr(bCiSWEl91Zhyr54b7opH4ihW7cQ6tv1u545Cj1KZGvlUMcMPQp97hN40oiHcPdjzcKaUgeRmiuiDiIvgS6olKeJsyyJynQyTlg3oeeJ2JEdjXuSW(Xjg2McMjCaIXXrmhjDXGekKoeXAuXWgokgoYpXGuQ2iw)I5iKypThxSsEac45Y75pa0(7drt8GgYQ7SqIVgfFzbjHDYeiGBBRxHS6olK2bPIS)B)1mb1W9bUnfmt4QdAvrPJaaPIS)tt(16U1mb1W9bUnfmt4QdAvrPJaaPIS)BF8LCNNqCKd4Dbv9PQAsJHur2)v(AMGA4(a3McMjC1bTQO0raGur2)PzjfWZL3ZFaO93hIM4bntixBR6dxfb5RrXxwqsyNmbcG9OQoShy7BQWXtVNF3PtHq1tioYVYXZHc45Y75pa0(7drt8GMaPVfbtNeWfW1GgedZPm4iIT3zcQH7Fc45Y75pGZPm4i1L60epObjHDYei((SGWFiQQJaPdzck(ajdSe(1mb1W9boKunCRQ8xeWcjH4ORIcZL3ZNHYXZpaOQK8bkif0jOyGctyNmbsaxdIbkm)(qeRrfJljwcjXwPUE)4eBEX4y(lsSfscXrhGy8ItyyJyme6ajXqB45IPYFrI1OIXLedjbHe7hXkTXH4NNHTeumgwxmoMWTIHHKQHRy9l2aveumFedh5IvgS6olKeJvxmo)Jy8Q8CckgV(U8U(5eGaEU8E(d4CkdosDPonXdAqYVpe(Au8CUSGKWozceWHOQocKoKjO4HNY6zGEh4BCi(5zylbbOpzcKANNb6Davc3wpKunCbOpzcKIt7wtbZu1N(9dqrO9Q9Y5FxzHSpHoqCeqrc3wh0QJq1I8CcwZ7Y76xapxEp)bCoLbhPUuNM4bT(mHkKUHfUi(qhy9P9445NpApomRzXW(o(sOv(0OzcIHoqXWqs1WTGckX0ummKunCph2BjXy)aDNyCjXsijwYmSUy(i2k1fBEX4y(lsSfscXrhGy8c(WgX4IqVyAz)kXktk3(0DI1NyjZW6I5Jyq2xSH1beWZL3ZFaNtzWrQl1PjEqFiPA4wqbfFnkE6jiUnLJVeADh9ee3gafH2R2lhp)ADxzbjHDYeiGdrvDeiDitqTBnfmtvF63pafH2R2lN)DkIHfffaTFvLlLBF6oaivK9F7ZVaUgeBVAKyocKoKjOoXqhOy07eSFCIHHKQHRyCm)fjGNlVN)aoNYGJuxQtt8GgKe2jtG47Zcc)HOQRPGzQ6t)(XhizGLWVMcMPQp97hGIq7v7LJhSAYWIIcCiPA4wzcPIoawDb8C598hW5ugCK6sDAIh0GKWozceFFwq4pevDnfmtvF63p(ajdSe(1uWmv9PF)aueAVAVC8CiFnk(1ac957aB3a78fWZL3ZFaNtzWrQl1PjEqdsc7Kjq89zbH)qu11uWmv9PF)4dKmWs4xtbZu1N(9dqrO9Q99XZpFnkEqsyNmbcG9OQoShy7BQWXtVNF3PtHq1tioYpGdHf2BPVE(alkhFjeW1GyCm)fjMIf2poXW2uWmHtSbkwYmGqI5iq6qMGcqapxEp)bCoLbhPUuNM4b9HKQHBvL)I4RrXdsc7KjqahIQUMcMPQp973oodsc7KjqahIQ6iq6qMGIhEyyrrbUnfmt4QdAvrPJaaPIS)RC88dawE450PqO6jeh5hWHWc7T0xpFGfLJVe7wZeud3h42uWmHRoOvfLocaKkY(VY5xRCsaxdIbgw4lgKkY(7hNyCm)fDIXqOdKeZriXqBCiUy0RoXAuXWgokg355axmgsmiLQnI1VyExqac45Y75pGZPm4i1L60epOpKunCRQ8xeFnkEqsyNmbc4qu11uWmv9PF)2H24q8kKkY(V9xZeud3h42uWmHRoOvfLocaKkY(pbCbCnObXWCkdocPeRmgp9EEbCnigVhvmmNYGJaAqYVpeXsijgRoFIXEKyyiPA4EoS3sI5Jym0tOTlgkCkeZriX0Z7AqiXyMN9elFLyAz)kXktk3(0D8jgbc9I1OIXLelHKyPlwrUhX2RgjgNz)aDNySx)4eJxLNtqX413L31pNeWZL3ZFaNtzWrif(djvd3ZH9wIVgfpNzyrrboNYGJaWQZdpmSOOaGKFFiaS6CAxrEobR5D5D9xHur2)HxRc4AqmTS)(qelDX4qnfBVAKyCBhzyDX4iMyGwSsOPyCBhrmoIjg32reddHf2BPxmTh4NQrmgwuuXy1fZhXsqMwj2nfKy7vJeJBEoj21oB698hGaUgeJxhUrSlrjX8rm0(7drS0fReAk2E1iX42oIy0EYLh2iwjeZtioYpaX4mwwqILNydRFTIe7CkdocaNeW1GyAz)9Hiw6IvcnfBVAKyCBhzyDX4igFIvsnfJB7iIXrm(elFLy8MyCBhrmoIjwI6eumqH53hIaEU8E(d4CkdocP0epOxziuZL3Zxd9589zbHhT)(q4RrXZWIIcCiSWEl9vFGFQgaw9DRPGzQ6t)(bOi0E1((4blp8C6uiu9eIJ8d4qyH9w6RNpWc8Ly3AkyMQ(0VFLJVe8WZAkyMQ(0VFakcTxTVpE(1yo7zGEhqrKobRNdtpXrfa0NmbsTJHfffaK87dbGvNtc45Y75pGZPm4iKst8G(qAq4RrX7zGEh4BCi(5zylbbOpzcKAhK9j0bIJa8(3u9zp9QYesfT70PqO6jeh5hWHWc7T0xpFGf7xsbCnigOwxmFeJdfZtioYpX48pIPd7HtITLiDXy1ftl7xjwzs52NUtmMnIT2Sc9JtmmKunCph2Bjab8C598hW5ugCesPjEqFiPA4EoS3s8T2Scu1tioYp88ZxJIVSGKWozcea7rvDypW23uHJNEp)ofXWIIcG2VQYLYTpDhaKkY(V95F3PtHq1tioYpGdHf2BPVE(al2hphUZtioYb8UGQ(uvnPXqQi7)kN3eW1GyA5afth2dS9nIbhp9EE(eJ9iXWqs1W9CyVLeBaHGIH5dSqmUTJiwzYRelXL9FUyS6I5JyLqmpH4i)eBGI1OIPLLPy9jgK9)(Xj2GIkgNNxS83iwwmSVl2GkMNqCKFCsapxEp)bCoLbhHuAIh0hsQgUNd7TeFnkEqsyNmbcG9OQoShy7BQWXtVNFhNvedlkkaA)Qkxk3(0DaqQi7)2NFE4XZa9oaxk1NVipNGa0NmbsT70PqO6jeh5hWHWc7T0xpFGf7JVeCsapxEp)bCoLbhHuAIh0hclS3sF98bwWxJI)0PqO6jeh5x545qn5mdlkkGJqv44o9aS68WdK9j0bIJaYTzc7REdBOIctCf07CAhNzyrrbUnfmt4QdAvrPJutwFwW2by15HNYYWIIcOdPcs1E698aS68WZPtHq1tioYVYXxsojGRbXWqs1W9CyVLeZhXGekKoeX0Y(vIvMuU9P7elFLy(ig9hlKeJlj2kFXwjeUrSbeckwkgkBiiMwwMI1VpI5iKypThxmSHJI1OIPp31mbcqapxEp)bCoLbhHuAIh0hsQgUNd7TeFnkEfXWIIcG2VQYLYTpDhaKkY(V9XZpp8SMjOgUpWTPGzcxDqRkkDeaivK9F7ZpO8ofXWIIcG2VQYLYTpDhaKkY(V9xZeud3h42uWmHRoOvfLocaKkY(pb8C598hW5ugCesPjEqJlmtbtiveFnkEgwuuaDcIoW0jvfeQ)d48CTTC8LC3AEfB7a6eeDGPtQkiu)ham)TLJNFouapxEp)bCoLbhHuAIh0hsQgUNd7TKaEU8E(d4CkdocP0epOxiuQxpKX5RrXxwpH4ihOVkZC3U1uWmv9PF)aueAVAVC88VJHfff4qgV2F1rOQkHBby13rpbXTbW7cQ6tTeATCClfqrUNi2PtRyPGL34p6rpgb]] )
    
end
