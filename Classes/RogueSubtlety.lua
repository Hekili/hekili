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


    spec:RegisterPack( "Subtlety", 20210308, [[dafc0bqijk9isbBsPYNuQQgfQOofQiRsII8ksjZcvLBrkIDb4xaPgMeHJHQQLHk4zavzAKcDnjI2gPO8nuPIXrksDoGQQwhQuyEaj3dQAFsu9pGQk5GOsjleOYdvQktevOlkrrXgjfvFuPkQrkrrPtskswjq5LOsrAMOsLUjQuQDkr6NavvmuuPQLkrHNcLPsk1vbQkBvIIQVQufgRsvKZcuvP2Rq)vsdMYHfTyu8yLmzsUmYMH0NHkJgItl1QrLI41kLMTGBlHDRQFRy4KQJJkf1Yb9CvMovxhL2oq8DuLXRuLoVsX8rLSFIJ8h1oIPsNILYHsWb(lb4vcnnah4xJG)Ae8pI5B0PiMEU2M4Oi2NfuedJLXdKVjIPNBctQIAhXUHfUOigI76h3a0Ggx7iSmaRPa0xxWgsVNFbtuh0xxSaDeJHTdUM6Jmrmv6uSuoucoWFjaVsOPb4a)Ae8xJCiILSoYaJyyDX(IyiTsrFKjIPOBfXWyz8a5BeRmgCSKag3oHleX008jghkbh4xataJBpGqIbsc7KjqaShv1H9aBFtfoE698IXQl2nI1Uy9j2rUyme6ajX4rIXEKyTdiGTVPGPFsSc2G36bsSvgc1C5981qFUy07WMoX8rmiPyxKy6JtV3zqmiXBGBbIyH(8lQDe7CkdocPIAhlL)O2rm6tMaPIGlILlVNpIDiPA4DoS3srmfDlyR798rmnfQyyoLbhb0GKFFiILqsmwD(eJ9iXWqs1W7CyVLeZhXyONqBxmu4uiMJqIPN31GqIXmp7jw(kX08(vIThuU9P74tmce6fRrfJhjwcjXsxSICVITpUxmoZ(b6oXyV(Xjg3opNGIXTUlVRFofXwW2jyNrmolgdlkkW5ugCeawDX4IlXyyrrbaj)(qay1fJtITtSI8CcwZ7Y76VcPIS)tm8IvIOhlLdrTJy0Nmbsfbxetr3c26EpFetZ7VpeXsxmnQLy7J7fJx7idRlghX4tSsQLy8AhrmoIXNy5RetZeJx7iIXrmXsuNGIvMNFFirSC598rSvgc1C5981qFEeBbBNGDgXyyrrboewyVL(QpWpvdaRUy7eBnfmtvF63pafH2R2fdu4fJdIXfxID6uiu9eIJ8d4qyH9w6RNpWcXWlMgfBNyRPGzQ6t)(jw54ftJIXfxITMcMPQp97hGIq7v7Ibk8IXVyAIyCwmpd07akI0jy9Cy6joQaG(KjqkX2jgdlkkai53hcaRUyCkIf6ZRFwqrm0(7dj6XsbVO2rm6tMaPIGlITGTtWoJyEgO3b(ghIFEg2sqa6tMaPeBNyq2NqhiocW7Ft1N92Rktivea9jtGuITtStNcHQNqCKFahclS3sF98bwigOeRKrSC598rSdPbj6Xs1yu7ig9jtGurWfXYL3ZhXoKun8oh2BPi2AZkqvpH4i)ILYFeBbBNGDgXkRyGKWozcea7rvDypW23uHJNEpVy7etrmSOOaO9RQ8OC7t3baPIS)tmqjg)ITtStNcHQNqCKFahclS3sF98bwigOWlg4j2oX8eIJCaVlOQpvvtIPjIbPIS)tSYftZIyk6wWw375JyGpDX8rmWtmpH4i)eJZ)iMoShoj2wI0fJvxmnVFLy7bLBF6oXy2i2AZk0poXWqs1W7CyVLaIES0sg1oIrFYeiveCrSC598rSdjvdVZH9wkIPOBbBDVNpIP5dumDypW23igC80755tm2JeddjvdVZH9wsSbeckgMpWcX41oIy7b3wSex2)5IXQlMpIPrX8eIJ8tSbkwJkMMVhI1Nyq2)7hNydkQyCEEXYFJyzXW(UydQyEcXr(XPi2c2ob7mIbsc7KjqaShv1H9aBFtfoE698ITtmolMIyyrrbq7xv5r52NUdasfz)NyGsm(fJlUeZZa9oapk1NVipNGa0Nmbsj2oXoDkeQEcXr(bCiSWEl91ZhyHyGcVyAumof9yPAwu7ig9jtGurWfXwW2jyNrStNcHQNqCKFIvoEXapX0smolgdlkkGJqv44o9aS6IXfxIbzFcDG4iGCBMW(Q3WgQOWexb9oa9jtGuIXjX2jgNfJHfff42uWmHRoOvfLosnz9zbBhGvxmU4sSYkgdlkkGoKkiv7P3ZdWQlgxCj2PtHq1tioYpXkhVyLumofXYL3ZhXoewyVL(65dSi6Xs5orTJy0NmbsfbxelxEpFe7qs1W7CyVLIyk6wWw375JyyiPA4DoS3sI5JyqcfshIyAE)kX2dk3(0DILVsmFeJ(JfsIXJeBLVyRec3i2acbflfdLneetZ3dX63hXCesSN2Rlg2WrXAuX0N7AMabeXwW2jyNrmfXWIIcG2VQYJYTpDhaKkY(pXafEX4xmU4sS1mb1W7bUnfmt4QdAvrPJaaPIS)tmqjg)AAX2jMIyyrrbq7xv5r52NUdasfz)NyGsS1mb1W7bUnfmt4QdAvrPJaaPIS)l6Xs10rTJy0NmbsfbxeBbBNGDgXyyrrb0ji6atNuvqO(pGZZ1wXkhVyLuSDITMxX2oGobrhy6KQcc1)baZFRyLJxm(bViwU8E(igUWmfmHurrpwk4Fu7iwU8E(i2HKQH35WElfXOpzcKkcUOhlL)se1oIrFYeiveCrSfSDc2zeRSI5jeh5a9vzM7eBNyRPGzQ6t)(bOi0E1UyLJxm(fBNymSOOahY41(RocvvjClaRUy7eJEcIBdG3fu1NQglHyLlgULcOi3BelxEpFeBHqPE9qgp6rpIPi0Kn4rTJLYFu7iwU8E(i22ETnIrFYeiveCrpwkhIAhXOpzcKkcUi2OhXoYJy5Y75JyGKWozcuedKmWsrmgwuuGl0lQMVQQ6fbWQlgxCj2PtHq1tioYpGdHf2BPVE(aleRC8IPzrmfDlyR798rmW3rkX8rmf5eSOFsmEiKJqqXwZeudV)eJx2UyOdumSNJIXKhPeBEX8eIJ8diIbscRFwqrS7v118Q275JESuWlQDeJ(KjqQi4IyJEe7ipILlVNpIbsc7KjqrmqYalfX0H9aBFtfoE698ITtStNcHQNqCKFahclS3sF98bwiw54fJdrmfDlyR798rmWpFyJylK8XrIbhp9EEXAuX4rIHKGqIPd7b2(MkC8075f7ixS8vIvWg8wpqI5jeh5NyS6armqsy9ZckIXEuvh2dS9nv44P3Zh9yPAmQDeJ(KjqQi4Iyk6wWw375Jy7dHwBfBFC8elDXqB45rSC598rSvgc1C5981qFEel0Nx)SGIyl1f9yPLmQDeJ(KjqQi4Iyk6wWw375JyLb7lgkBiSrSJx7le6eZhXCesmmNYGJqkXkJXtVNxmoZSrm10poXUHV2fdDGl6etFMq)4eRrf7hhPFCI1NyjizhsMaXjGiwU8E(igK9R5Y75RH(8i2c2ob7mIDoLbhHuazieXc951plOi25ugCesf9yPAwu7ig9jtGurWfXYL3ZhXUqVOA(QQQxuetr3c26EpFeJBPRh2i2f6fvZxvv9IelDX4GwITpUxmflSFCI5iKyOn8CX4VeID0AE1XxI6eumhjDX0OwITpUxSgvS2fJ2REdPtmETJ0Vyocj2t71fBpVpok2afRpX(XfJvpITGTtWoJyNofcvpH4i)aoewyVL(65dSqmqjMMj2oXqBCiEfsfz)NyLlMMj2oXyyrrbUqVOA(QQQxeaKkY(pXaLy4wkGICVITtS1uWmv9PF)eRC8IPrX0eX4SyExqIbkX4VeIXjXktIXHOhlL7e1oIrFYeiveCrmfDlyR798rmUh2dS9nIvgJNEpp4xIXDjF)Ny4AqiXsXwWuxSKzyDXONG42ig6afZriXoNYGJi2(44jgNzy7GIGIDEhcIbPtNwUyTZjaXa)MvNV2fBLVymKyos6IDDHEGaIy5Y75JyRmeQ5Y75RH(8i2c2ob7mIbsc7KjqaShv1H9aBFtfoE698rSqFE9ZckIDoLbhPUux0JLQPJAhXOpzcKkcUi2OhXoYJy5Y75JyGKWozcuedKmWsrmousX0smpd07aG04gia9jtGuIvMeJdLqmTeZZa9oqrEobRdA9qs1W7aOpzcKsSYKyCOeIPLyEgO3boKun8QOZI9aOpzcKsSYKyCOKIPLyEgO3bYqUGTVbG(KjqkXktIXHsiMwIXHskwzsmol2PtHq1tioYpGdHf2BPVE(aleRC8IPrX4uetr3c26EpFed8DKsmFetrO9tIXdHEX8rm2Je7CkdoIy7JJNydumg2oOi4fXajH1plOi25ugCKQJaPdzcQOhlf8pQDeJ(KjqQi4Iyk6wWw375Jy7B(Rveum2RFCILIH5ugCeX2hhfJhc9IbPCH0poXCesm6jiUnI5iq6qMGkILlVNpITYqOMlVNVg6ZJyly7eSZig9ee3gafH2R2fdu4fdKe2jtGaoNYGJuDeiDitqfXc951plOi25ugCK6sDrpwk)LiQDeJ(KjqQi4Iyk6wWw375Jy7r7iIXrmXYWnIH2FFiILUyAulXsCz)NlMgfZtioYpX48W6xRiXoNYGJWPiwU8E(i2kdHAU8E(AOppITGTtWoJyRPGzQ6t)(jgEXYVlYfscXrQ6sxmU4sS1uWmv9PF)aueAVAxmqHxm(fJlUedTXH4vivK9FIbk8IXVy7eBnfmtvF63pXkhVyGNyCXLymSOOa3McMjC1bTQO0rQjRply7aS6ITtS1uWmv9PF)eRC8IPrX4IlXoDkeQEcXr(bCiSWEl91ZhyHyLJxmnk2oXwtbZu1N(9tSYXlMgJyH(86NfuedT)(qIESu(5pQDeJ(KjqQi4Iyk6wWw375JyGVJelfJHTdkckgpe6fds5cPFCI5iKy0tqCBeZrG0HmbvelxEpFeBLHqnxEpFn0NhXwW2jyNrm6jiUnakcTxTlgOWlgijStMabCoLbhP6iq6qMGkIf6ZRFwqrmg2oOIESu(5qu7ig9jtGurWfXYL3ZhXs4kFQ6desVhXu0TGTU3ZhX4Udp6CX0H9aBFJy9lwgcInOI5iKyClUN7kgdTs2JeRDXwj7rNyPy759XXi2c2ob7mIrpbXTbqrO9QDXkhVy8xsX0sm6jiUnaqch9rpwk)Gxu7iwU8E(iwcx5tvD2Wrrm6tMaPIGl6Xs5xJrTJy5Y75JyHghIFvUjSkCf07rm6tMaPIGl6Xs5VKrTJy5Y75JymjU6GwDyV2Erm6tMaPIGl6rpIPdP1uWKEu7yP8h1oILlVNpIL66Hnv9PV5Jy0Nmbsfbx0JLYHO2rSC598rmMX9aPQOHCdP41pUQp7T)ig9jtGurWf9yPGxu7iwU8E(i25ugCKig9jtGurWf9yPAmQDeJ(KjqQi4Iy5Y75JyfjClPQOdSQO0rIy6qAnfmPxpAnV6Iy8xYOhlTKrTJy0NmbsfbxelxEpFe7c9IQ5RQQErrSfSDc2zedsOq6qsMafX0H0AkysVE0AE1fX4p6Xs1SO2rm6tMaPIGlITGTtWoJyq2NqhiocOiHBRdA1rOArEobR5D5D9dqFYeivelxEpFe7qs1WRYesfDrp6rmg2oOIAhlL)O2rm6tMaPIGlITGTtWoJyLvmpd07aFJdXppdBjia9jtGuITtmi7tOdehb49VP6ZE7vLjKkcG(KjqkX2j2PtHq1tioYpGdHf2BPVE(aleduIvYiwU8E(i2H0Ge9yPCiQDeJ(KjqQi4Iyly7eSZi2PtHq1tioYpXkhVyCqSDIXzXwZeudVh4iimDsvzMNQNEVLawijehDvuyU8E(migOWlgha4oLumU4sStNcHQNqCKFahclS3sF98bwiw5IPrX4uelxEpFe7qyH9w6RNpWIOhlf8IAhXOpzcKkcUi2c2ob7mITMjOgEpWrqy6KQYmpvp9ElbSqsio6QOWC598zqSYXlgha4oLumU4sSBydm9RacuQQmBQ0EZc9abqFYeiLy7eRSIXWIIceOuvz2uP9Mf6bcGvpILlVNpIDeeMoPQmZt1tV3srpwQgJAhXYL3ZhXWfMPGjKkkIrFYeiveCrpwAjJAhXYL3ZhXyY12ZtMig9jtGurWf9OhXwQlQDSu(JAhXOpzcKkcUi2c2ob7mIvwXyyrrboKun8QQ8xeaRUy7eJHfff4qyH9w6R(a)unaS6ITtmgwuuGdHf2BPV6d8t1aaPIS)tmqHxmWdOKrm2JQdkAf3sflL)iwU8E(i2HKQHxvL)IIyk6wWw375JyGVJeJJ5ViXguunb3sjgdHoqsmhHedTHNl2HWc7T0xpFGfIHcNcX0EGFQgXwtbDI1pq0JLYHO2rm6tMaPIGlITGTtWoJymSOOahclS3sF1h4NQbGvxSDIXWIIcCiSWEl9vFGFQgaivK9FIbk8IbEaLmIXEuDqrR4wQyP8hXYL3ZhXUnfmt4QdAvrPJeXu0TGTU3ZhX4m47d0DILbiLQnIXQlgdTs2JeJhjMpZwXWqs1WtmnFwShNeJ9iXW2uWmHtSbfvtWTuIXqOdKeZriXqB45IDiSWEl91ZhyHyOWPqmTh4NQrS1uqNy9de9yPGxu7ig9jtGurWfXwW2jyNrmqsyNmbc4EvDnVQ9EEX2jwzf7CkdocPakY3duelxEpFednK4Oqi9E(OhlvJrTJy0NmbsfbxeBbBNGDgXkRy6ouSDIPigwuua0qIJcH075bGur2)jgOeJdrSC598rm0qIJcH075RRaL)rrpwAjJAhXOpzcKkcUi2c2ob7mIXzXGSpHoqCeqrc3wh0QJq1I8CcwZ7Y76hG(KjqkX2j2AkyMQ(0VFakcTxTlgOWlg)IPjI5zGEhqrKobRNdtNWrfa0NmbsjgxCjgK9j0bIJauu6iHn1djvdVdG(KjqkX2j2AkyMQ(0VFIbkX4xmoj2oXyyrrbUnfmt4QdAvrPJaWQl2oXyyrrboKun8QQ8xeaRUy7eRipNG18U8U(RqQi7)edVyLqSDIXWIIcOO0rcBQhsQgEhGA49rSC598rmqYVpKOhlvZIAhXOpzcKkcUiMIUfS19E(ig3ptqm0bkM2d8t1iMoK0eSHJIXRDeXWq4OyqkvBeJhc9I9JlgK9)(XjgMMdeXqhy9P96Xs5pITGTtWoJyEgO3boewyVL(QpWpvda9jtGuITtSYkMNb6DGdjvdVk6Sypa6tMaPIy5Y75Jy6ZeQq6gw4IIESuUtu7ig9jtGurWfXYL3ZhXoewyVL(QpWpvtetr3c26EpFed8DKyApWpvJy6qsmSHJIXdHEX4rIHKGqI5iKy0tqCBeJhc5ieumu4uiM(mH(XjgV2rgwxmmnxSbkg3e2Zfdh9emdHnarSfSDc2zeJEcIBJyLJxmnReITtmqsyNmbc4EvDnVQ9EEX2j2AMGA49a3McMjC1bTQO0ray1fBNyRzcQH3dCiPA4vv5ViGfscXrNyLJxm(JESunDu7ig9jtGurWfXYL3ZhXocctNuvM5P6P3BPi2c2ob7mIbsc7Kjqa3RQR5vT3Zl2oXkRyQXbocctNuvM5P6P3BPQACaVxB7hNy7eZtioYb8UGQ(uvnjw54fJd8lgxCjgAJdXRqQi7)edu4fRKITtStNcHQNqCKFahclS3sF98bwigOed8IyRnRav9eIJ8lwk)rpwk4Fu7ig9jtGurWfXwW2jyNrmqsyNmbc4EvDnVQ9EEX2j2AkyMQ(0VFakcTxTlw54fJ)iwU8E(i2r6xFrpwk)LiQDeJ(KjqQi4Iy5Y75Jy3McMjC1bTQO0rIyk6wWw375JyGVJedBtbZeoXMxS1mb1W7fJZjQtqXqB45IH9CKtIX(b6oX4rILqsmCt)4eZhX0hDX0EGFQgXYxjMAe7hxmKeesmmKun8etZNf7beXwW2jyNrmqsyNmbc4EvDnVQ9EEX2jgNfZZa9oa9GqHrVFC1djvdVdG(KjqkX4IlXwZeudVh4qs1WRQYFralKeIJoXkhVy8lgNeBNyCwSYkMNb6DGdHf2BPV6d8t1aqFYeiLyCXLyEgO3boKun8QOZI9aOpzcKsmU4sS1mb1W7boewyVL(QpWpvdaKkY(pXkxmoigNIESu(5pQDeJ(KjqQi4Iy5Y75JyfjClPQOdSQO0rIyRnRav9eIJ8lwk)rSfSDc2zedMTQsGqVdKk1bWQl2oX4SyEcXroG3fu1NQQjXaLyRPGzQ6t)(bOi0E1UyCXLyLvSZPm4iKcidbX2j2AkyMQ(0VFakcTxTlw54fBPxlY9wpD6vIXPiMIUfS19E(iMMcvSuPoXsijgRoFIDFRtI5iKyZtIXRDeXcdp6CX0wBocig47iX4HqVyQn9Jtm08CckMJKVy7J7ftrO9QDXgOy)4IDoLbhHuIXRDKH1fl)nITpUhi6Xs5NdrTJy0NmbsfbxelxEpFeRiHBjvfDGvfLosetr3c26EpFettHk2pILk1jgVoeet1Ky8AhPFXCesSN2Rlg4vIJpXypsmUnkhfBEXyM7eJx7idRlw(BeBFCpqeBbBNGDgXGzRQei07aPsDa9lw5IbELqmnrmy2Qkbc9oqQuhGIfMEpVy7eBnfmtvF63pafH2R2fRC8IT0Rf5ERNo9QOhlLFWlQDeJ(KjqQi4Iyly7eSZigijStMabCVQUMx1EpVy7eBnfmtvF63pafH2R2fRC8IXHiwU8E(i2HKQHxLjKk6IESu(1yu7ig9jtGurWfXwW2jyNrmqsyNmbc4EvDnVQ9EEX2j2AkyMQ(0VFakcTxTlw54fJdITtmolgijStMabWEuvh2dS9nv44P3ZlgxCj2PtHq1tioYpGdHf2BPVE(aledu4ftJIXPiwU8E(igTqM(XvHKoSlYxf9yP8xYO2rm6tMaPIGlILlVNpIDiSWEl9vFGFQMiMIUfS19E(i2E0oIyyAoFI1OI9JlwgGuQ2iMAEIpXypsmTh4NQrmETJig2WrXy1bIyly7eSZiMNb6DGdjvdVk6Sypa6tMaPeBNyGKWozceW9Q6AEv798ITtmgwuuGBtbZeU6Gwvu6iaS6rpwk)Awu7ig9jtGurWfXwW2jyNrSYkgdlkkWHKQHxvL)Iay1fBNyOnoeVcPIS)tmqHxmnTyAjMNb6DGJLXjiklocG(KjqQiwU8E(i2HKQHxvL)IIESu(5orTJy0NmbsfbxeBbBNGDgXyyrrbycZOcSNdaPC5IXfxIH24q8kKkY(pXaLyGxjeJlUeJHfff42uWmHRoOvfLocaRUy7eJZIXWIIcCiPA4vzcPIoawDX4IlXwZeudVh4qs1WRYesfDaqQi7)edu4fJ)sigNIyk6wWw375JyLoVMC60sSZzrrfJx7iIfgEeumDyprSC598rm9X75JESu(10rTJy0NmbsfbxeBbBNGDgXyyrrbUnfmt4QdAvrPJaWQhXYL3ZhXycZOQOSWnrpwk)G)rTJy0NmbsfbxeBbBNGDgXyyrrbUnfmt4QdAvrPJaWQhXYL3ZhXyi4rWT9Jl6Xs5qjIAhXOpzcKkcUi2c2ob7mIXWIIcCBkyMWvh0QIshbGvpILlVNpIH2qIjmJk6Xs5a)rTJy0NmbsfbxeBbBNGDgXyyrrbUnfmt4QdAvrPJaWQhXYL3ZhXYFrNdZqDLHq0JLYboe1oIrFYeiveCrSC598rm2JQTtfxetr3c26EpFeJJeAYgCXqZqGjxBfdDGIXEjtGeRDQ44gIb(osmETJig2McMjCInOIXrkDeGi2c2ob7mIXWIIcCBkyMWvh0QIshbGvxmU4sm0ghIxHur2)jgOeJdLi6rpIDoLbhPUuxu7yP8h1oIrFYeiveCrSrpIDKhXYL3ZhXajHDYeOigizGLIyRzcQH3dCiPA4vv5ViGfscXrxffMlVNpdIvoEX4hG7uYigijS(zbfXoev1rG0Hmbv0JLYHO2rm6tMaPIGlILlVNpIbs(9HeXu0TGTU3ZhXkZZVpeXAuX4rILqsSvQR3poXMxmoM)IeBHKqC0biwzMeg2igdHoqsm0gEUyQ8xKynQy8iXqsqiX(rSsBCi(5zylbfJH1fJJjCRyyiPA4jw)InqfbfZhXWrUyLbRUZcjXy1fJZ)ig3opNGIXTUlVRFobeXwW2jyNrmolwzfdKe2jtGaoev1rG0HmbLyCXLyLvmpd07aFJdXppdBjia9jtGuITtmpd07aQeUTEiPA4bqFYeiLyCsSDITMcMPQp97hGIq7v7IvUy8l2oXkRyq2NqhiocOiHBRdA1rOArEobR5D5D9dqFYeiv0JLcErTJy0NmbsfbxelxEpFetFMqfs3WcxueJ2RdZAwmSVhX0yjIyOdS(0E9yP8h9yPAmQDeJ(KjqQi4Iyly7eSZig9ee3gXkhVyASeITtm6jiUnakcTxTlw54fJ)si2oXkRyGKWozceWHOQocKoKjOeBNyRPGzQ6t)(bOi0E1UyLlg)ITtmfXWIIcG2VQYJYTpDhaKkY(pXaLy8hXYL3ZhXoKun8kOGk6Xslzu7ig9jtGurWfXg9i2rEelxEpFedKe2jtGIyGKbwkITMcMPQp97hGIq7v7IvoEX4GyAjgdlkkWHKQHxLjKk6ay1Jyk6wWw375Jy7J7fZrG0Hmb1jg6afJENG9JtmmKun8eJJ5VOigijS(zbfXoevDnfmtvF63VOhlvZIAhXOpzcKkcUi2OhXoYJy5Y75JyGKWozcuedKmWsrS1uWmv9PF)aueAVAxSYXlg4fXwW2jyNrS1ac957aB3a78JyGKW6Nfue7qu11uWmv9PF)IESuUtu7ig9jtGurWfXg9i2rEelxEpFedKe2jtGIyGKbwkITMcMPQp97hGIq7v7Ibk8IXFeBbBNGDgXajHDYeia2JQ6WEGTVPchp9EEX2j2PtHq1tioYpGdHf2BPVE(aleRC8IPXigijS(zbfXoevDnfmtvF63VOhlvth1oIrFYeiveCrSC598rSdjvdVQk)ffXu0TGTU3ZhX4y(lsmflSFCIHTPGzcNyduSKzaHeZrG0HmbfqeBbBNGDgXajHDYeiGdrvxtbZu1N(9tSDIXzXajHDYeiGdrvDeiDitqjgxCjgdlkkWTPGzcxDqRkkDeaivK9FIvoEX4hGdIXfxID6uiu9eIJ8d4qyH9w6RNpWcXkhVyAuSDITMjOgEpWTPGzcxDqRkkDeaivK9FIvUy8xcX4u0JLc(h1oIrFYeiveCrSC598rSdjvdVQk)ffXu0TGTU3ZhXahl8fdsfz)9JtmoM)IoXyi0bsI5iKyOnoexm6vNynQyydhfJ3873fJHedsPAJy9lM3feqeBbBNGDgXajHDYeiGdrvxtbZu1N(9tSDIH24q8kKkY(pXaLyRzcQH3dCBkyMWvh0QIshbasfz)x0JEedT)(qIAhlL)O2rm6tMaPIGlIn6rSJ8iwU8E(igijStMafXajdSueZZa9oGoKkiv7P3ZdqFYeiLy7e70PqO6jeh5hWHWc7T0xpFGfIbkX4SyLumnrS1ac957apTGtyGkX4Ky7eRSITgqOpFhy7gyNFetr3c26EpFeBpq6ajg71poX4EivqQ2tVNNpXsqMwj2kpVFCIHf6fjw(kX4yViX4HqVyyiPA4jghZFrI1Ny3mVy(igdjg7rk(eJ27I0DXqhOyCt3a78JyGKW6NfuethsfKQEVQUMx1EpF0JLYHO2rm6tMaPIGlITGTtWoJyLvmqsyNmbcqhsfKQEVQUMx1EpVy7e70PqO6jeh5hWHWc7T0xpFGfIbkX0mX2jwzfJHfff4qs1WRQYFraS6ITtmgwuuGl0lQMVQQ6fbaPIS)tmqjgAJdXRqQi7)eBNyqcfshsYeOiwU8E(i2f6fvZxvv9IIESuWlQDeJ(KjqQi4Iyly7eSZigijStMabOdPcsvVxvxZRAVNxSDITMjOgEpWHKQHxvL)IawijehDvuyU8E(migOeJFaUtjfBNymSOOaxOxunFvv1lcasfz)NyGsS1mb1W7bUnfmt4QdAvrPJaaPIS)tSDIXzXwZeudVh4qs1WRQYFraqkvBeBNymSOOa3McMjC1bTQO0raGur2)jMMigdlkkWHKQHxvL)IaGur2)jgOeJFaoigNIy5Y75JyxOxunFvv1lk6Xs1yu7ig9jtGurWfXg9i2rEelxEpFedKe2jtGIyGKbwkIvKNtWAExEx)vivK9FIvUyLqmU4sSYkMNb6DGVXH4NNHTeeG(KjqkX2jMNb6Davc3wpKun8aOpzcKsSDIXWIIcCiPA4vv5ViawDX4IlXoDkeQEcXr(bCiSWEl91ZhyHyLJxmnlIbscRFwqrSBBRxHS6olKIES0sg1oIrFYeiveCrSC598rmiRUZcPiMIUfS19E(ig3uI0fJvxSYGv3zHKynQyTlwFILmdRlMpIbzFXgwhiITGTtWoJyCwSYkgijStMabCBB9kKv3zHKyCXLyGKWozcea7rvDypW23uHJNEpVyCsSDI5jeh5aExqvFQQMettedsfz)NyLlMMj2oXGekKoKKjqrpwQMf1oILlVNpID0csE1PfY3CZSueJ(KjqQi4IESuUtu7ig9jtGurWfXYL3ZhXGS6olKIyRnRav9eIJ8lwk)rSfSDc2zeRSIbsc7Kjqa32wVcz1Dwij2oXkRyGKWozcea7rvDypW23uHJNEpVy7e70PqO6jeh5hWHWc7T0xpFGfIvoEX4Gy7eZtioYb8UGQ(uvnjw54fJZIvsX0smolgheRmj2AkyMQ(0VFIXjX4Ky7edsOq6qsMafXu0TGTU3ZhX42SbVvJ79JtmpH4i)eZrsxmEDiiwObHedDGI5iKykwy698InOIvgS6olKedsOq6qetXc7hNy65ROIEbe9yPA6O2rm6tMaPIGlILlVNpIbz1DwifXu0TGTU3ZhXkdcfshIyLbRUZcjXOeg2iwJkw7IXRdbXO9Q3qsmflSFCIHTPGzchGyCCeZrsxmiHcPdrSgvmSHJIHJ8tmiLQnI1Vyocj2t71fRKhqeBbBNGDgXkRyGKWozceWTT1RqwDNfsITtmivK9FIbkXwZeudVh42uWmHRoOvfLocaKkY(pX0sm(lHy7eBntqn8EGBtbZeU6Gwvu6iaqQi7)edu4fRKITtmpH4ihW7cQ6tv1KyAIyqQi7)eRCXwZeudVh42uWmHRoOvfLocaKkY(pX0sSsg9yPG)rTJy0NmbsfbxeBbBNGDgXkRyGKWozcea7rvDypW23uHJNEpVy7e70PqO6jeh5NyLJxmWlILlVNpIXeY12Q(WtrWOhlL)se1oILlVNpIrG03IGPtrm6tMaPIGl6rp6rmqi41ZhlLdLGd8xcWReCNigVe(9J7Iy7b3Qmkvtv6EMBiMyAJqI1f6d0fdDGIT)ZPm4iKA)IbjUz2gskXUPGelz9PiDsj2cjFC0biGXD7Ned84gITV5bHGoPeB)q2NqhiocypTFX8rS9dzFcDG4iG9ea9jtGu7xmoZ)E5eGag3TFsmnJBi2(Mhec6KsS9dzFcDG4iG90(fZhX2pK9j0bIJa2ta0NmbsTFX4m)7LtacyAJqIHoHWWRFCILSW8eJhbjXypsjw)I5iKy5Y75fl0NlgdRlgpcsI9Jlg6W(kX6xmhHelvQ5ftLEYKhXneWette72uWmHRoOvfLosnz9zbBxataBp4wLrPAQs3ZCdXetBesSUqFGUyOduS9Ri0Kn47xmiXnZ2qsj2nfKyjRpfPtkXwi5JJoabmTriXqNqy41poXswyEIXJGKyShPeRFXCesSC598If6ZfJH1fJhbjX(XfdDyFLy9lMJqILk18IPspzYJ4gcyIPjIDBkyMWvh0QIshPMS(SGTlGjGThCRYOunvP7zUHyIPncjwxOpqxm0bk2(1H0AkysF)IbjUz2gskXUPGelz9PiDsj2cjFC0biGXD7NetZ4gITV5bHGoPeB)q2NqhiocypTFX8rS9dzFcDG4iG9ea9jtGu7xS0fRmd4hURyCM)9YjabmbS9GBvgLQPkDpZnetmTriX6c9b6IHoqX2)sD7xmiXnZ2qsj2nfKyjRpfPtkXwi5JJoabmUB)KyAKBig47pwD9b6KsSC598ITF0qIJcH075RRaL)r7hqaJ72pjwj5gITV5bHGoPeB)q2NqhiocypTFX8rS9dzFcDG4iG9ea9jtGu7xmoZH9YjabmbS9GBvgLQPkDpZnetmTriX6c9b6IHoqX2)5ugCK6sD7xmiXnZ2qsj2nfKyjRpfPtkXwi5JJoabmUB)KyCGBi2(Mhec6KsS9dzFcDG4iG90(fZhX2pK9j0bIJa2ta0NmbsTFXsxSYmGF4UIXz(3lNaeWeW2dUvzuQMQ09m3qmX0gHeRl0hOlg6afB)mSDqTFXGe3mBdjLy3uqILS(uKoPeBHKpo6aeW4U9tIXp3qS9npie0jLy7hY(e6aXra7P9lMpITFi7tOdehbSNaOpzcKA)IXz(3lNaeWeW0uf6d0jLyChXYL3ZlwOp)aeWIyNoTILYbnJ)iMoCq7afX0GgedJLXdKVrSYyWXscyAqdIXTt4crmnnFIXHsWb(fWeW0GgeJBpGqIbsc7KjqaShv1H9aBFtfoE698IXQl2nI1Uy9j2rUyme6ajX4rIXEKyTdiGPbni2(McM(jXkydERhiXwziuZL3Zxd95IrVdB6eZhXGKIDrIPpo9ENbXGeVbUfqatatdAqmUhsAY(McM0fWYL3ZFa6qAnfmPRfEqN66Hnv9PV5fWYL3ZFa6qAnfmPRfEqZmUhivfnKBifV(Xv9zV9lGLlVN)a0H0Akysxl8G(CkdoIawU8E(dqhsRPGjDTWd6IeULuv0bwvu6i8PdP1uWKE9O18Qdp)LualxEp)bOdP1uWKUw4b9f6fvZxvv9I4thsRPGj96rR5vhE(5RrXdjuiDijtGeWYL3ZFa6qAnfmPRfEqFiPA4vzcPIo(Au8q2NqhiocOiHBRdA1rOArEobR5D5D9lGjGPbnig3o7xSYy8075fWYL3ZF432RTcyAqmW3rkX8rmf5eSOFsmEiKJqqXwZeudV)eJx2UyOdumSNJIXKhPeBEX8eIJ8dqalxEp)PfEqdsc7Kjq89zbH)EvDnVQ9EE(ajdSeEgwuuGl0lQMVQQ6fbWQZfxNofcvpH4i)aoewyVL(65dSOC8AMaMged8Zh2i2cjFCKyWXtVNxSgvmEKyijiKy6WEGTVPchp9EEXoYflFLyfSbV1dKyEcXr(jgRoGawU8E(tl8GgKe2jtG47Zccp7rvDypW23uHJNEppFGKbwcVoShy7BQWXtVNF3PtHq1tioYpGdHf2BPVE(alkhpheW0Gy7dHwBfBFC8elDXqB45cy5Y75pTWd6vgc1C5981qFoFFwq4xQtatdIvgSVyOSHWgXoETVqOtmFeZriXWCkdocPeRmgp9EEX4mZgXut)4e7g(Axm0bUOtm9zc9JtSgvSFCK(XjwFILGKDizceNaeWYL3ZFAHh0q2VMlVNVg6Z57Zcc)5ugCesXxJI)CkdocPaYqqatdIXT01dBe7c9IQ5RQQErILUyCqlX2h3lMIf2poXCesm0gEUy8xcXoAnV64lrDckMJKUyAulX2h3lwJkw7Ir7vVH0jgV2r6xmhHe7P96ITN3hhfBGI1Ny)4IXQlGLlVN)0cpOVqVOA(QQQxeFnk(tNcHQNqCKFahclS3sF98bwaknBhAJdXRqQi7)kxZ2XWIIcCHEr18vvvViaivK9FGc3sbuK7D3AkyMQ(0VFLJxJAcN9UGaf)LGtLjoiGPbX4EypW23iwzmE698GFjg3L89FIHRbHelfBbtDXsMH1fJEcIBJyOdumhHe7CkdoIy7JJNyCMHTdkck25DiigKoDA5I1oNaed8BwD(AxSv(IXqI5iPl21f6bcqalxEp)PfEqVYqOMlVNVg6Z57Zcc)5ugCK6sD81O4bjHDYeia2JQ6WEGTVPchp9EEbmnig47iLy(iMIq7NeJhc9I5JyShj25ugCeX2hhpXgOymSDqrWtalxEp)PfEqdsc7Kjq89zbH)Ckdos1rG0HmbfFGKbwcphkPwEgO3baPXnqa6tMaPktCOeA5zGEhOipNG1bTEiPA4Da0NmbsvM4qj0YZa9oWHKQHxfDwSha9jtGuLjousT8mqVdKHCbBFda9jtGuLjoucT4qjltC(0PqO6jeh5hWHWc7T0xpFGfLJxJCsatdITV5VwrqXyV(XjwkgMtzWreBFCumEi0lgKYfs)4eZriXONG42iMJaPdzckbSC598Nw4b9kdHAU8E(AOpNVpli8NtzWrQl1XxJINEcIBdGIq7v7GcpijStMabCoLbhP6iq6qMGsatdIP593hIyPlMg1smETJmSUyCetSbkgV2redB4Oyly7IXWIIYNyLulX41oIyCetmopS(1ksSZPm4iCsatdIThTJighXeld3igA)9Hiw6IPrTelXL9FUyAumpH4i)eJZdRFTIe7CkdocNeWYL3ZFAHh0RmeQ5Y75RH(C((SGWJ2FFi81O4xtbZu1N(9dF(DrUqsiosvx6CX1AkyMQ(0VFakcTxTdk88ZfxOnoeVcPIS)du45F3AkyMQ(0VFLJh84IlgwuuGBtbZeU6Gwvu6i1K1NfSDaw9DRPGzQ6t)(voEnYfxNofcvpH4i)aoewyVL(65dSOC8AC3AkyMQ(0VFLJxJcyAqmW3rILIXW2bfbfJhc9IbPCH0poXCesm6jiUnI5iq6qMGsalxEp)PfEqVYqOMlVNVg6Z57ZccpdBhu81O4PNG42aOi0E1oOWdsc7KjqaNtzWrQocKoKjOeW0GyC3HhDUy6WEGTVrS(fldbXguXCesmUf3ZDfJHwj7rI1UyRK9OtSuS98(4OawU8E(tl8GoHR8PQpqi9oFnkE6jiUnakcTxTxoE(lPw0tqCBaGeo6fWYL3ZFAHh0jCLpv1zdhjGLlVN)0cpOdnoe)QCtyv4kO3fWYL3ZFAHh0mjU6GwDyV2EcycyAqdIbo2oOi4jGLlVN)ayy7Gc)H0GWxJIVSEgO3b(ghIFEg2sqa6tMaP2bzFcDG4iaV)nvF2BVQmHur7oDkeQEcXr(bCiSWEl91ZhybOkPawU8E(dGHTdkTWd6dHf2BPVE(al4RrXF6uiu9eIJ8RC8CyhNxZeudVh4iimDsvzMNQNEVLawijehDvuyU8E(mak8CaG7usU460PqO6jeh5hWHWc7T0xpFGfLRrojGLlVN)ayy7Gsl8G(iimDsvzMNQNEVL4RrXVMjOgEpWrqy6KQYmpvp9ElbSqsio6QOWC598zOC8CaG7usU46g2at)kGaLQkZMkT3Sqpqa0NmbsTRSmSOOabkvvMnvAVzHEGay1fWYL3ZFamSDqPfEqJlmtbtivKawU8E(dGHTdkTWdAMCT98KratatdAqS9ntqn8(tatdIb(osmoM)IeBqr1eClLyme6ajXCesm0gEUyhclS3sF98bwigkCket7b(PAeBnf0jw)acy5Y75pGL60cpOpKun8QQ8xeFShvhu0kULcp)81O4lldlkkWHKQHxvL)Iay13XWIIcCiSWEl9vFGFQgaw9DmSOOahclS3sF1h4NQbasfz)hOWdEaLuatdIXzW3hO7eldqkvBeJvxmgALShjgpsmFMTIHHKQHNyA(Sypojg7rIHTPGzcNydkQMGBPeJHqhijMJqIH2WZf7qyH9w6RNpWcXqHtHyApWpvJyRPGoX6hqalxEp)bSuNw4b9TPGzcxDqRkkDe(ypQoOOvClfE(5RrXZWIIcCiSWEl9vFGFQgaw9DmSOOahclS3sF1h4NQbasfz)hOWdEaLualxEp)bSuNw4bnAiXrHq69881O4bjHDYeiG7v118Q2753v2ZPm4iKcOiFpqcy5Y75pGL60cpOrdjokesVNVUcu(hXxJIVS6oCNIyyrrbqdjokesVNhasfz)hO4GawU8E(dyPoTWdAqYVpe(Au8CgY(e6aXrafjCBDqRocvlYZjynVlVR)DRPGzQ6t)(bOi0E1oOWZVM4zGEhqrKobRNdtNWrfa0NmbsXfxq2NqhiocqrPJe2upKun8UDRPGzQ6t)(bk(50ogwuuGBtbZeU6Gwvu6iaS67yyrrboKun8QQ8xeaR(UI8CcwZ7Y76VcPIS)dFj2XWIIcOO0rcBQhsQgEhGA49cyAqmUFMGyOdumTh4NQrmDiPjydhfJx7iIHHWrXGuQ2igpe6f7hxmi7)9JtmmnhqalxEp)bSuNw4bT(mHkKUHfUi(qhy9P9645NVgfVNb6DGdHf2BPV6d8t1aqFYei1UY6zGEh4qs1WRIol2dG(Kjqkbmnig47iX0EGFQgX0HKyydhfJhc9IXJedjbHeZriXONG42igpeYriOyOWPqm9zc9JtmETJmSUyyAUydumUjSNlgo6jygcBaeWYL3ZFal1PfEqFiSWEl9vFGFQg(Au80tqCBkhVMvIDGKWozceW9Q6AEv7987wZeudVh42uWmHRoOvfLocaR(U1mb1W7boKun8QQ8xeWcjH4ORC88lGLlVN)awQtl8G(iimDsvzMNQNEVL4BTzfOQNqCKF45NVgfpijStMabCVQUMx1Ep)UYQgh4iimDsvzMNQNEVLQQXb8ETTFC78eIJCaVlOQpvvtLJNd8ZfxOnoeVcPIS)du4l5UtNcHQNqCKFahclS3sF98bwakWtalxEp)bSuNw4b9r6xF81O4bjHDYeiG7v118Q2753TMcMPQp97hGIq7v7LJNFbmnig47iXW2uWmHtS5fBntqn8EX4CI6eum0gEUyyph5KySFGUtmEKyjKed30poX8rm9rxmTh4NQrS8vIPgX(XfdjbHeddjvdpX08zXEacy5Y75pGL60cpOVnfmt4QdAvrPJWxJIhKe2jtGaUxvxZRAVNFhN9mqVdqpiuy07hx9qs1W7aOpzcKIlUwZeudVh4qs1WRQYFralKeIJUYXZpN2X5Y6zGEh4qyH9w6R(a)una0NmbsXfxEgO3boKun8QOZI9aOpzcKIlUwZeudVh4qyH9w6R(a)unaqQi7)kNdCsatdIPPqflvQtSesIXQZNy336Kyocj28Ky8AhrSWWJoxmT1MJaIb(osmEi0lMAt)4ednpNGI5i5l2(4EXueAVAxSbk2pUyNtzWriLy8AhzyDXYFJy7J7beWYL3ZFal1PfEqxKWTKQIoWQIshHV1MvGQEcXr(HNF(Au8WSvvce6DGuPoaw9DC2tioYb8UGQ(uvnbQ1uWmv9PF)aueAVANlUk75ugCesbKHWU1uWmv9PF)aueAVAVC8l9ArU36PtVItcyAqmnfQy)iwQuNy86qqmvtIXRDK(fZriXEAVUyGxjo(eJ9iX42OCuS5fJzUtmETJmSUy5VrS9X9acy5Y75pGL60cpOls4wsvrhyvrPJWxJIhMTQsGqVdKk1b0F5Gxj0ey2Qkbc9oqQuhGIfMEp)U1uWmv9PF)aueAVAVC8l9ArU36PtVsalxEp)bSuNw4b9HKQHxLjKk64RrXdsc7Kjqa3RQR5vT3ZVBnfmtvF63pafH2R2lhpheWYL3ZFal1PfEqtlKPFCviPd7I8v81O4bjHDYeiG7v118Q2753TMcMPQp97hGIq7v7LJNd74mijStMabWEuvh2dS9nv44P3ZZfxNofcvpH4i)aoewyVL(65dSau41iNeW0Gy7r7iIHP58jwJk2pUyzasPAJyQ5j(eJ9iX0EGFQgX41oIyydhfJvhqalxEp)bSuNw4b9HWc7T0x9b(PA4RrX7zGEh4qs1WRIol2dG(KjqQDGKWozceW9Q6AEv7987yyrrbUnfmt4QdAvrPJaWQlGLlVN)awQtl8G(qs1WRQYFr81O4lldlkkWHKQHxvL)Iay13H24q8kKkY(pqHxtRLNb6DGJLXjiklocG(KjqkbmniwPZRjNoTe7CwuuX41oIyHHhbfth2JawU8E(dyPoTWdA9X755RrXZWIIcWeMrfyphas5Y5Il0ghIxHur2)bkWReCXfdlkkWTPGzcxDqRkkDeaw9DCMHfff4qs1WRYesfDaS6CX1AMGA49ahsQgEvMqQOdasfz)hOWZFj4KawU8E(dyPoTWdAMWmQkklCdFnkEgwuuGBtbZeU6Gwvu6iaS6cy5Y75pGL60cpOzi4rWT9JJVgfpdlkkWTPGzcxDqRkkDeawDbSC598hWsDAHh0OnKycZO4RrXZWIIcCBkyMWvh0QIshbGvxalxEp)bSuNw4bD(l6CygQRme4RrXZWIIcCBkyMWvh0QIshbGvxatdIXrcnzdUyOziWKRTIHoqXyVKjqI1ovCCdXaFhjgV2redBtbZeoXguX4iLocGawU8E(dyPoTWdA2JQTtfhFnkEgwuuGBtbZeU6Gwvu6iaS6CXfAJdXRqQi7)afhkHaMaMg0GyAE)9HqWtatdIThiDGeJ96hNyCpKkiv7P3ZZNyjitReBLN3poXWc9IelFLyCSxKy8qOxmmKun8eJJ5ViX6tSBMxmFeJHeJ9ifFIr7Dr6UyOdumUPBGD(cy5Y75pa0(7dbpijStMaX3NfeEDivqQ69Q6AEv7988bsgyj8EgO3b0HubPAp9EEa6tMaP2D6uiu9eIJ8d4qyH9w6RNpWcqX5sQjRbe6Z3bEAbNWavCAxzxdi0NVdSDdSZxalxEp)bG2FFiAHh0xOxunFvv1lIVgfFzbjHDYeiaDivqQ69Q6AEv7987oDkeQEcXr(bCiSWEl91ZhybO0SDLLHfff4qs1WRQYFraS67yyrrbUqVOA(QQQxeaKkY(pqH24q8kKkY(VDqcfshsYeibSC598haA)9HOfEqFHEr18vvvVi(Au8GKWozceGoKkiv9EvDnVQ9E(DRzcQH3dCiPA4vv5ViGfscXrxffMlVNpdGIFaUtj3XWIIcCHEr18vvvViaivK9FGAntqn8EGBtbZeU6Gwvu6iaqQi7)2X51mb1W7boKun8QQ8xeaKs1MDmSOOa3McMjC1bTQO0raGur2)PjmSOOahsQgEvv(lcasfz)hO4hGdCsalxEp)bG2FFiAHh0GKWozceFFwq4VTTEfYQ7SqIpqYalHVipNG18U8U(RqQi7)kVeCXvz9mqVd8noe)8mSLGa0NmbsTZZa9oGkHBRhsQgEa0NmbsTJHfff4qs1WRQYFraS6CX1PtHq1tioYpGdHf2BPVE(alkhVMXxzwkOtqXkZtyNmbsm0bkwzWQ7SqcqmSTTUykwy)4eJBNNtqX4w3L31VydumflSFCIXX8xKy8AhrmoMWTILVsSFeR0ghIFEg2sqabmnig3uI0fJvxSYGv3zHKynQyTlwFILmdRlMpIbzFXgwhqalxEp)bG2FFiAHh0qwDNfs81O45CzbjHDYeiGBBRxHS6olK4IlqsyNmbcG9OQoShy7BQWXtVNNt78eIJCaVlOQpvvtAcKkY(VY1SDqcfshsYeibSC598haA)9HOfEqF0csE1PfY3CZSKaMgeJBZg8wnU3poX8eIJ8tmhjDX41HGyHgesm0bkMJqIPyHP3Zl2GkwzWQ7SqsmiHcPdrmflSFCIPNVIk6fGawU8E(daT)(q0cpOHS6olK4BTzfOQNqCKF45NVgfFzbjHDYeiGBBRxHS6olK2vwqsyNmbcG9OQoShy7BQWXtVNF3PtHq1tioYpGdHf2BPVE(alkhph25jeh5aExqvFQQMkhpNlPwCMdLP1uWmv9PF)4eN2bjuiDijtGeW0GyLbHcPdrSYGv3zHKyucdBeRrfRDX41HGy0E1BijMIf2poXW2uWmHdqmooI5iPlgKqH0HiwJkg2WrXWr(jgKs1gX6xmhHe7P96IvYdqalxEp)bG2FFiAHh0qwDNfs81O4llijStMabCBB9kKv3zH0oivK9FGAntqn8EGBtbZeU6Gwvu6iaqQi7)0I)sSBntqn8EGBtbZeU6Gwvu6iaqQi7)af(sUZtioYb8UGQ(uvnPjqQi7)kFntqn8EGBtbZeU6Gwvu6iaqQi7)0QKcy5Y75pa0(7drl8GMjKRTv9HNIG81O4llijStMabWEuvh2dS9nv44P3ZV70PqO6jeh5x54bpbSC598haA)9HOfEqtG03IGPtcycyAqdIH5ugCeX23mb1W7pbSC598hW5ugCK6sDAHh0GKWozceFFwq4pev1rG0HmbfFGKbwc)AMGA49ahsQgEvv(lcyHKqC0vrH5Y75Zq545hG7us(kZsbDckwzEc7KjqcyAqSY887drSgvmEKyjKeBL669JtS5fJJ5ViXwijehDaIvMjHHnIXqOdKedTHNlMk)fjwJkgpsmKeesSFeR0ghIFEg2sqXyyDX4yc3kggsQgEI1VydurqX8rmCKlwzWQ7SqsmwDX48pIXTZZjOyCR7Y76Ntacy5Y75pGZPm4i1L60cpObj)(q4RrXZ5Ycsc7KjqahIQ6iq6qMGIlUkRNb6DGVXH4NNHTeeG(KjqQDEgO3bujCB9qs1WdG(KjqkoTBnfmtvF63pafH2R2lN)DLfY(e6aXrafjCBDqRocvlYZjynVlVRFbSC598hW5ugCK6sDAHh06ZeQq6gw4I4dDG1N2RJNF(O96WSMfd7741yj4J7Njig6afddjvdVckOetlXWqs1W7CyVLeJ9d0DIXJelHKyjZW6I5JyRuxS5fJJ5ViXwijehDaIb(5dBeJhc9IP59ReBpOC7t3jwFILmdRlMpIbzFXgwhqalxEp)bCoLbhPUuNw4b9HKQHxbfu81O4PNG42uoEnwID0tqCBaueAVAVC88xIDLfKe2jtGaoev1rG0Hmb1U1uWmv9PF)aueAVAVC(3Pigwuua0(vvEuU9P7aGur2)bk(fW0Gy7J7fZrG0Hmb1jg6afJENG9JtmmKun8eJJ5VibSC598hW5ugCK6sDAHh0GKWozceFFwq4pevDnfmtvF63p(ajdSe(1uWmv9PF)aueAVAVC8CqlgwuuGdjvdVktiv0bWQlGLlVN)aoNYGJuxQtl8GgKe2jtG47Zcc)HOQRPGzQ6t)(XhizGLWVMcMPQp97hGIq7v7LJh84RrXVgqOpFhy7gyNVawU8E(d4CkdosDPoTWdAqsyNmbIVpli8hIQUMcMPQp97hFGKbwc)AkyMQ(0VFakcTxTdk88ZxJIhKe2jtGaypQQd7b2(MkC80753D6uiu9eIJ8d4qyH9w6RNpWIYXRrbmnighZFrIPyH9JtmSnfmt4eBGILmdiKyocKoKjOaeWYL3ZFaNtzWrQl1PfEqFiPA4vv5Vi(Au8GKWozceWHOQRPGzQ6t)(TJZGKWozceWHOQocKoKjO4IlgwuuGBtbZeU6Gwvu6iaqQi7)khp)aCGlUoDkeQEcXr(bCiSWEl91Zhyr5414U1mb1W7bUnfmt4QdAvrPJaaPIS)RC(lbNeW0GyGJf(IbPIS)(XjghZFrNyme6ajXCesm0ghIlg9QtSgvmSHJIXB(97IXqIbPuTrS(fZ7ccqalxEp)bCoLbhPUuNw4b9HKQHxvL)I4RrXdsc7KjqahIQUMcMPQp973o0ghIxHur2)bQ1mb1W7bUnfmt4QdAvrPJaaPIS)tatatdAqmmNYGJqkXkJXtVNxatdIPPqfdZPm4iGgK87drSesIXQZNyShjggsQgENd7TKy(igd9eA7IHcNcXCesm98UgesmM5zpXYxjMM3VsS9GYTpDhFIrGqVynQy8iXsijw6IvK7vS9X9IXz2pq3jg71poX4255eumU1D5D9ZjbSC598hW5ugCesH)qs1W7CyVL4RrXZzgwuuGZPm4iaS6CXfdlkkai53hcaRoN2vKNtWAExEx)vivK9F4lHaMgetZ7VpeXsxmWtlX2h3lgV2rgwxmoIjgOftJAjgV2reJJyIXRDeXWqyH9w6ft7b(PAeJHffvmwDX8rSeKPvIDtbj2(4EX4LNtIDTZMEp)biGPbX4wHBe7susmFedT)(qelDX0OwITpUxmETJigT3C5HnIPrX8eIJ8dqmoJLfKy5j2W6xRiXoNYGJaWjbmniMM3FFiILUyAulX2h3lgV2rgwxmoIXNyLulX41oIyCeJpXYxjMMjgV2reJJyILOobfRmp)(qeWYL3ZFaNtzWriLw4b9kdHAU8E(AOpNVpli8O93hcFnkEgwuuGdHf2BPV6d8t1aWQVBnfmtvF63pafH2R2bfEoWfxNofcvpH4i)aoewyVL(65dSaVg3TMcMPQp97x541ixCTMcMPQp97hGIq7v7Gcp)AcN9mqVdOisNG1ZHPN4Oca6tMaP2XWIIcas(9HaWQZjbSC598hW5ugCesPfEqFini81O49mqVd8noe)8mSLGa0NmbsTdY(e6aXraE)BQ(S3EvzcPI2D6uiu9eIJ8d4qyH9w6RNpWcqvsbmnig4txmFed8eZtioYpX48pIPd7HtITLiDXy1ftZ7xj2Eq52NUtmMnIT2Sc9JtmmKun8oh2BjabSC598hW5ugCesPfEqFiPA4DoS3s8T2Scu1tioYp88ZxJIVSGKWozcea7rvDypW23uHJNEp)ofXWIIcG2VQYJYTpDhaKkY(pqX)UtNcHQNqCKFahclS3sF98bwak8G3opH4ihW7cQ6tv1KMaPIS)RCntatdIP5dumDypW23igC80755tm2JeddjvdVZH9wsSbeckgMpWcX41oIy7b3wSex2)5IXQlMpIPrX8eIJ8tSbkwJkMMVhI1Nyq2)7hNydkQyCEEXYFJyzXW(UydQyEcXr(XjbSC598hW5ugCesPfEqFiPA4DoS3s81O4bjHDYeia2JQ6WEGTVPchp9E(DCwrmSOOaO9RQ8OC7t3baPIS)du8ZfxEgO3b4rP(8f55eeG(KjqQDNofcvpH4i)aoewyVL(65dSau41iNeWYL3ZFaNtzWriLw4b9HWc7T0xpFGf81O4pDkeQEcXr(voEWtloZWIIc4iufoUtpaRoxCbzFcDG4iGCBMW(Q3WgQOWexb9oN2XzgwuuGBtbZeU6Gwvu6i1K1NfSDawDU4QSmSOOa6qQGuTNEppaRoxCD6uiu9eIJ8RC8LKtcyAqmmKun8oh2BjX8rmiHcPdrmnVFLy7bLBF6oXYxjMpIr)XcjX4rITYxSvcHBeBaHGILIHYgcIP57Hy97Jyocj2t71fdB4OynQy6ZDntGaeWYL3ZFaNtzWriLw4b9HKQH35WElXxJIxrmSOOaO9RQ8OC7t3baPIS)du45NlUwZeudVh42uWmHRoOvfLocaKkY(pqXVMENIyyrrbq7xv5r52NUdasfz)hOwZeudVh42uWmHRoOvfLocaKkY(pbSC598hW5ugCesPfEqJlmtbtiveFnkEgwuuaDcIoW0jvfeQ)d48CTTC8LC3AEfB7a6eeDGPtQkiu)ham)TLJNFWtalxEp)bCoLbhHuAHh0hsQgENd7TKawU8E(d4CkdocP0cpOxiuQxpKX5RrXxwpH4ihOVkZC3U1uWmv9PF)aueAVAVC88VJHfff4qgV2F1rOQkHBby13rpbXTbW7cQ6tvJLOCClfqrU3Oh9ye]] )
    
end
