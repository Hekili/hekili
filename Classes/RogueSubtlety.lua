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


    spec:RegisterPack( "Subtlety", 20210310, [[da1hZbqijk9iuvAtkv(Ksv1Oqf1PqfzvKIuVIuYSqv1TifXUa8lGudJuOJHkzzOcEgqvMMerxtIW2ifLVrkGXPuvY5qvHADOQG5bKCpOQ9jr1)aQQKdIQISqGkpuPknruHUiqvvTrsr1hvQk1ivQkOtskqReO8sLQcmtsrYnrvrTtjs)eOQIHskOLkrHNcLPsk1vbQkBvPQqFvIIgRsvrNfOQsTxH(RKgmLdlAXO4XkzYKCzKndPpdvgneNwQvduvLxRuA2cUTe2TQ(TIHtQooQkKLd65QmDQUokTDG47OkJxPkoVsX8rLA)eh5kQDetLoflLdAKdCPrWJlncWfFCj4axCiI5B0PiMEU2M4Oi2NfuedJLXdKVjIPNBctQIAhXUHfUOigI76hFa0Ggx7iSmaRPa0xxWgsVNFbtuh0xxSaDeJHTdUg8Jmrmv6uSuoOroWLgbpU0iax8XLGdCXvelzDKbgXW6I9gXqALI(itetr3kIHXY4bY3iwzm4yjbm(CcxiIXLg5xmoOroWLaMagFEaHedKe2jtGaypQQd7b2(MkC8075fJvxSBeRDX6tSJCXyi0bsIXJeJ9iXAhqaBVtbt)KyfSbV1dKyRmeQ5Y75RH(CXO3HnDI5JyqsXUiX0hNEVZGyqI3a3ceXc95xu7i25ugCesf1owkxrTJy0NmbsfbxelxEpFe7qs1W7CyVLIyk6wWw375JyAquXWCkdocObj)(qelHKyS68lg7rIHHKQH35WEljMpIXqpH2UyOWPqmhHetpVRbHeJzE2tS8vIP59ReRmPC7t3XVyei0lwJkgpsSesILUyf5EeBVAOyCM9d0DIXE9Jtm(CEobfJpDxEx)CkITGTtWoJyCwmgwuuGZPm4iaS6IXn3IXWIIcas(9HaWQlgNeBNyf55eSM3L31Ffsfz)Ny4ftJrpwkhIAhXOpzcKkcUiMIUfS19E(iMM3FFiILUyLulX2RgkgV2rgwxmoIXVyLqlX41oIyCeJFXYxjMMjgV2reJJyILOobfBFm)(qIy5Y75JyRmeQ5Y75RH(8i2c2ob7mIXWIIcCiSWEl9vFGFQgawDX2j2AkyMQ(0VFakcTxTlgOWlgheJBUf70PqO6jeh5hWHWc7T0xpFGfIHxSsk2oXwtbZu1N(9tSYXlwjfJBUfBnfmtvF63pafH2R2fdu4fJlX0eX4SyEgO3buePtW65W0tCuba9jtGuITtmgwuuaqYVpeawDX4uel0Nx)SGIyO93hs0JLcErTJy0NmbsfbxeBbBNGDgX8mqVd8noe)8mSLGa0Nmbsj2oXGSpHoqCeG3)MQp7PxvMqQia6tMaPeBNyNofcvpH4i)aoewyVL(65dSqmqjwjIy5Y75Jyhsds0JLwYO2rm6tMaPIGlILlVNpIDiPA4DoS3srS1MvGQEcXr(flLRi2c2ob7mIvwXajHDYeia2JQ6WEGTVPchp9EEX2jMIyyrrbq7xv5r52NUdasfz)NyGsmUeBNyNofcvpH4i)aoewyVL(65dSqmqHxmWtSDI5jeh5aExqvFQQMettedsfz)NyLlMMfXu0TGTU3ZhXaF6I5JyGNyEcXr(jgN)rmDypCsSTePlgRUyAE)kXktk3(0DIXSrS1MvOFCIHHKQH35WElbe9yPLiQDeJ(KjqQi4Iy5Y75JyhsQgENd7Tuetr3c26EpFetZhOy6WEGTVrm44P3ZZVyShjggsQgENd7TKydieummFGfIXRDeXkt(SyjUS)ZfJvxmFeRKI5jeh5NyduSgvmnVmfRpXGS)3poXguuX488IL)gXYIH9DXguX8eIJ8JtrSfSDc2zedKe2jtGaypQQd7b2(MkC8075fBNyCwmfXWIIcG2VQYJYTpDhaKkY(pXaLyCjg3ClMNb6DaEuQpFrEobbOpzcKsSDID6uiu9eIJ8d4qyH9w6RNpWcXafEXkPyCk6Xs1SO2rm6tMaPIGlITGTtWoJyNofcvpH4i)eRC8IbEIPLyCwmgwuuahHQWXD6by1fJBUfdY(e6aXra52mH9vVHnurHjUc6Da6tMaPeJtITtmolgdlkkWTPGzcxDqRkkDKAY6Zc2oaRUyCZTyLvmgwuuaDivqQ2tVNhGvxmU5wStNcHQNqCKFIvoEXkHyCkILlVNpIDiSWEl91Zhyr0JLQbIAhXOpzcKkcUiwU8E(i2HKQH35WElfXu0TGTU3ZhXWqs1W7CyVLeZhXGekKoeX08(vIvMuU9P7elFLy(ig9hlKeJhj2kFXwjeUrSbeckwkgkBiiMMxMI1VpI5iKypThxmSHJI1OIPp31mbciITGTtWoJykIHfffaTFvLhLBF6oaivK9FIbk8IXLyCZTyRzcQH3dCBkyMWvh0QIshbasfz)NyGsmU2xITtmfXWIIcG2VQYJYTpDhaKkY(pXaLyRzcQH3dCBkyMWvh0QIshbasfz)x0JLUVIAhXOpzcKkcUi2c2ob7mIXWIIcOtq0bMoPQGq9FaNNRTIvoEXkHy7eBnVITDaDcIoW0jvfeQ)daM)wXkhVyCbErSC598rmCHzkycPIIESu(4O2rSC598rSdjvdVZH9wkIrFYeiveCrpwkxAmQDeJ(KjqQi4Iyly7eSZiwzfZtioYb6RYm3j2oXwtbZu1N(9dqrO9QDXkhVyCj2oXyyrrboKXR9xDeQQs4wawDX2jg9ee3gaVlOQp1sQrXkxmClfqrUNiwU8E(i2cHs96HmE0JEetrOjBWJAhlLRO2rSC598rST9ABeJ(KjqQi4IESuoe1oIrFYeiveCrSrpIDKhXYL3ZhXajHDYeOigizGLIymSOOaxOxunFvv1lcGvxmU5wStNcHQNqCKFahclS3sF98bwiw54ftZIyk6wWw375JyGVJuI5JykYjyr)Ky8qihHGITMjOgE)jgVSDXqhOyyphfJjpsj28I5jeh5hqedKew)SGIy3RQR5vT3Zh9yPGxu7ig9jtGurWfXg9i2rEelxEpFedKe2jtGIyGKbwkIPd7b2(MkC8075fBNyNofcvpH4i)aoewyVL(65dSqSYXlghIyk6wWw375JyGF(WgXwi5JJedoE698I1OIXJedjbHeth2dS9nv44P3Zl2rUy5ReRGn4TEGeZtioYpXy1bIyGKW6NfueJ9OQoShy7BQWXtVNp6Xslzu7ig9jtGurWfXu0TGTU3ZhX2lcT2k2E54jw6IH2WZJy5Y75JyRmeQ5Y75RH(8iwOpV(zbfXwQl6Xslru7ig9jtGurWfXu0TGTU3ZhXkd2xmu2qyJyhV2xi0jMpI5iKyyoLbhHuIvgJNEpVyCMzJyQPFCIDd)Tlg6ax0jM(mH(XjwJk2pos)4eRpXsqYoKmbItarSC598rmi7xZL3Zxd95rSfSDc2ze7CkdocPaYqiIf6ZRFwqrSZPm4iKk6Xs1SO2rm6tMaPIGlILlVNpIDHEr18vvvVOiMIUfS19E(igFsxpSrSl0lQMVQQ6fjw6IXbTeBVAOykwy)4eZriXqB45IXLgf7O18QJ)e1jOyos6IvsTeBVAOynQyTlgTh9gsNy8AhPFXCesSN2Jl2(EVCuSbkwFI9JlgREeBbBNGDgXoDkeQEcXr(bCiSWEl91ZhyHyGsmntSDIH24q8kKkY(pXkxmntSDIXWIIcCHEr18vvvViaivK9FIbkXWTuaf5EeBNyRPGzQ6t)(jw54fRKIPjIXzX8UGeduIXLgfJtIPPfJdrpwQgiQDeJ(KjqQi4Iyk6wWw375JyAiShy7BeRmgp9EEWVettr((pXW1GqILITGPUyjZW6IrpbXTrm0bkMJqIDoLbhrS9YXtmoZW2bfbf78oeedsNoTCXANtaIb(nRo)Tl2kFXyiXCK0f76c9abeXYL3ZhXwziuZL3Zxd95rSfSDc2zedKe2jtGaypQQd7b2(MkC8075JyH(86Nfue7CkdosDPUOhlDFf1oIrFYeiveCrSrpIDKhXYL3ZhXajHDYeOigizGLIyCOeIPLyEgO3baPXnqa6tMaPettlgh0OyAjMNb6DGI8Ccwh06HKQH3bqFYeiLyAAX4GgftlX8mqVdCiPA4vrNf7bqFYeiLyAAX4qjetlX8mqVdKHCbBFda9jtGuIPPfJdAumTeJdLqmnTyCwStNcHQNqCKFahclS3sF98bwiw54fRKIXPiMIUfS19E(ig47iLy(iMIq7NeJhc9I5JyShj25ugCeX2lhpXgOymSDqrWlIbscRFwqrSZPm4ivhbshYeurpwkFCu7ig9jtGurWfXu0TGTU3ZhX278xRiOySx)4elfdZPm4iITxokgpe6fds5cPFCI5iKy0tqCBeZrG0HmbvelxEpFeBLHqnxEpFn0NhXwW2jyNrm6jiUnakcTxTlgOWlgijStMabCoLbhP6iq6qMGkIf6ZRFwqrSZPm4i1L6IESuU0yu7ig9jtGurWfXu0TGTU3ZhXkZ2reJJyILHBedT)(qelDXkPwIL4Y(pxSskMNqCKFIX5H1VwrIDoLbhHtrSC598rSvgc1C5981qFEeBbBNGDgXwtbZu1N(9tm8ILFxKlKeIJu1LUyCZTyRPGzQ6t)(bOi0E1UyGcVyCjg3ClgAJdXRqQi7)edu4fJlX2j2AkyMQ(0VFIvoEXapX4MBXyyrrbUnfmt4QdAvrPJutwFwW2by1fBNyRPGzQ6t)(jw54fRKIXn3ID6uiu9eIJ8d4qyH9w6RNpWcXkhVyLuSDITMcMPQp97NyLJxSsgXc951plOigA)9He9yPCXvu7ig9jtGurWfXu0TGTU3ZhXaFhjwkgdBhueumEi0lgKYfs)4eZriXONG42iMJaPdzcQiwU8E(i2kdHAU8E(AOppITGTtWoJy0tqCBaueAVAxmqHxmqsyNmbc4Ckdos1rG0Hmbvel0Nx)SGIymSDqf9yPCXHO2rm6tMaPIGlILlVNpILWv(u1hiKEpIPOBbBDVNpIPPgE05IPd7b2(gX6xSmeeBqfZriX4tAOMsmgALShjw7ITs2JoXsX237LJrSfSDc2zeJEcIBdGIq7v7IvoEX4QeIPLy0tqCBaGeo6JESuUaVO2rSC598rSeUYNQ6SHJIy0Nmbsfbx0JLYvjJAhXYL3ZhXcnoe)QG)yv4kO3Jy0Nmbsfbx0JLYvjIAhXYL3ZhXysC1bT6WET9Iy0Nmbsfbx0JEethsRPGj9O2Xs5kQDelxEpFel11dBQ6tFZhXOpzcKkcUOhlLdrTJy5Y75JymJ7bsvrd5gsXRFCvF2t)rm6tMaPIGl6XsbVO2rSC598rSZPm4irm6tMaPIGl6Xslzu7ig9jtGurWfXYL3ZhXks4wsvrhyvrPJeX0H0AkysVE0AE1fX4QerpwAjIAhXOpzcKkcUiwU8E(i2f6fvZxvv9IIyly7eSZigKqH0HKmbkIPdP1uWKE9O18QlIXv0JLQzrTJy0NmbsfbxeBbBNGDgXGSpHoqCeqrc3wh0QJq1I8CcwZ7Y76hG(KjqQiwU8E(i2HKQHxLjKk6IE0JymSDqf1owkxrTJy0NmbsfbxeBbBNGDgXkRyEgO3b(ghIFEg2sqa6tMaPeBNyq2NqhiocW7Ft1N90Rktivea9jtGuITtStNcHQNqCKFahclS3sF98bwigOeRerSC598rSdPbj6Xs5qu7ig9jtGurWfXwW2jyNrStNcHQNqCKFIvoEX4Gy7eJZITMjOgEpWrqy6KQYmpvp9ElbSqsio6QOWC598zqmqHxmoaObkHyCZTyNofcvpH4i)aoewyVL(65dSqSYfRKIXPiwU8E(i2HWc7T0xpFGfrpwk4f1oIrFYeiveCrSfSDc2zeBntqn8EGJGW0jvLzEQE69wcyHKqC0vrH5Y75ZGyLJxmoaObkHyCZTy3Wgy6xbeOuvz2uP9Kf6bcG(KjqkX2jwzfJHfffiqPQYSPs7jl0deaREelxEpFe7iimDsvzMNQNEVLIES0sg1oILlVNpIHlmtbtivueJ(KjqQi4IES0se1oILlVNpIXKRTNNmrm6tMaPIGl6rpITuxu7yPCf1oIrFYeiveCrSfSDc2zeRSIXWIIcCiPA4vv5ViawDX2jgdlkkWHWc7T0x9b(PAay1fBNymSOOahclS3sF1h4NQbasfz)NyGcVyGhqjIyShvhu0kULkwkxrSC598rSdjvdVQk)ffXu0TGTU3ZhXaFhjghZFrInOOAcULsmgcDGKyocjgAdpxSdHf2BPVE(aledfofIP9a)unITMc6eRFGOhlLdrTJy0NmbsfbxeBbBNGDgXyyrrboewyVL(QpWpvdaRUy7eJHfff4qyH9w6R(a)unaqQi7)edu4fd8akreJ9O6GIwXTuXs5kILlVNpIDBkyMWvh0QIshjIPOBbBDVNpIXzW3hO7eldqkvBeJvxmgALShjgpsmFMTIHHKQHNyA(Sypojg7rIHTPGzcNydkQMGBPeJHqhijMJqIH2WZf7qyH9w6RNpWcXqHtHyApWpvJyRPGoX6hi6XsbVO2rm6tMaPIGlITGTtWoJyGKWozceW9Q6AEv798ITtSYk25ugCesbuKVhOiwU8E(igAiXrHq698rpwAjJAhXOpzcKkcUi2c2ob7mIXzXGSpHoqCeqrc3wh0QJq1I8CcwZ7Y76hG(KjqkX2j2AkyMQ(0VFakcTxTlgOWlgxIPjI5zGEhqrKobRNdtNWrfa0Nmbsjg3ClgK9j0bIJauu6iHn1djvdVdG(KjqkX2j2AkyMQ(0VFIbkX4smoj2oXyyrrbUnfmt4QdAvrPJaWQl2oXyyrrboKun8QQ8xeaRUy7eRipNG18U8U(RqQi7)edVyAuSDIXWIIcOO0rcBQhsQgEhGA49rSC598rmqYVpKOhlTerTJy0Nmbsfbxetr3c26EpFetdNjig6aft7b(PAethsAc2WrX41oIyyiCumiLQnIXdHEX(XfdY(F)4edtZbIyOdS(0E8yPCfXwW2jyNrmpd07ahclS3sF1h4NQbG(KjqkX2jwzfZZa9oWHKQHxfDwSha9jtGurSC598rm9zcviDdlCrrpwQMf1oIrFYeiveCrSC598rSdHf2BPV6d8t1eXu0TGTU3ZhXaFhjM2d8t1iMoKedB4Oy8qOxmEKyijiKyocjg9ee3gX4HqocbfdfofIPptOFCIXRDKH1fdtZfBGIb(J9CXWrpbZqydqeBbBNGDgXONG42iw54ftZ0Oy7edKe2jtGaUxvxZRAVNxSDITMjOgEpWTPGzcxDqRkkDeawDX2j2AMGA49ahsQgEvv(lcyHKqC0jw54fJROhlvde1oIrFYeiveCrSC598rSJGW0jvLzEQE69wkITGTtWoJyGKWozceW9Q6AEv798ITtSYkMACGJGW0jvLzEQE69wQQghW712(Xj2oX8eIJCaVlOQpvvtIvoEX4axIXn3IH24q8kKkY(pXafEXkHy7e70PqO6jeh5hWHWc7T0xpFGfIbkXaVi2AZkqvpH4i)ILYv0JLUVIAhXOpzcKkcUi2c2ob7mIbsc7Kjqa3RQR5vT3Zl2oXwtbZu1N(9dqrO9QDXkhVyCfXYL3ZhXos)6l6Xs5JJAhXOpzcKkcUiwU8E(i2TPGzcxDqRkkDKiMIUfS19E(ig47iXW2uWmHtS5fBntqn8EX4CI6eum0gEUyyph5KySFGUtmEKyjKed30poX8rm9rxmTh4NQrS8vIPgX(XfdjbHeddjvdpX08zXEarSfSDc2zedKe2jtGaUxvxZRAVNxSDIXzX8mqVdqpiuy07hx9qs1W7aOpzcKsmU5wS1mb1W7boKun8QQ8xeWcjH4OtSYXlgxIXjX2jgNfRSI5zGEh4qyH9w6R(a)una0Nmbsjg3ClMNb6DGdjvdVk6Sypa6tMaPeJBUfBntqn8EGdHf2BPV6d8t1aaPIS)tSYfJdIXPOhlLlng1oIrFYeiveCrSC598rSIeULuv0bwvu6irS1MvGQEcXr(flLRi2c2ob7mIbZwvjqO3bsL6ay1fBNyCwmpH4ihW7cQ6tv1KyGsS1uWmv9PF)aueAVAxmU5wSYk25ugCesbKHGy7eBnfmtvF63pafH2R2fRC8IT0Rf5EQNo9kX4uetr3c26EpFetdIkwQuNyjKeJvNFXUV1jXCesS5jX41oIyHHhDUyARnhbed8DKy8qOxm1M(XjgAEobfZrYxS9QHIPi0E1UyduSFCXoNYGJqkX41oYW6IL)gX2Rgce9yPCXvu7ig9jtGurWfXYL3ZhXks4wsvrhyvrPJeXu0TGTU3ZhX0GOI9JyPsDIXRdbXunjgV2r6xmhHe7P94IbEA84xm2JeJpJYrXMxmM5oX41oYW6IL)gX2RgceXwW2jyNrmy2Qkbc9oqQuhq)IvUyGNgfttedMTQsGqVdKk1bOyHP3Zl2oXwtbZu1N(9dqrO9QDXkhVyl9ArUN6PtVk6Xs5IdrTJy0NmbsfbxeBbBNGDgXajHDYeiG7v118Q275fBNyRPGzQ6t)(bOi0E1UyLJxmoeXYL3ZhXoKun8QmHurx0JLYf4f1oIrFYeiveCrSfSDc2zedKe2jtGaUxvxZRAVNxSDITMcMPQp97hGIq7v7IvoEX4Gy7eJZIbsc7KjqaShv1H9aBFtfoE698IXn3ID6uiu9eIJ8d4qyH9w6RNpWcXafEXkPyCkILlVNpIrlKPFCviPd7I8vrpwkxLmQDeJ(KjqQi4Iy5Y75JyhclS3sF1h4NQjIPOBbBDVNpIvMTJigMMZVynQy)4ILbiLQnIPMN4xm2Jet7b(PAeJx7iIHnCumwDGi2c2ob7mI5zGEh4qs1WRIol2dG(KjqkX2jgijStMabCVQUMx1EpVy7eJHfff42uWmHRoOvfLocaRE0JLYvjIAhXOpzcKkcUi2c2ob7mIvwXyyrrboKun8QQ8xeaRUy7edTXH4vivK9FIbk8ITVetlX8mqVdCSmobrzXra0NmbsfXYL3ZhXoKun8QQ8xu0JLYLMf1oIrFYeiveCrSfSDc2zeJHfffGjmJkWEoaKYLlg3ClgAJdXRqQi7)eduIbEAumU5wmgwuuGBtbZeU6Gwvu6iaS6ITtmolgdlkkWHKQHxLjKk6ay1fJBUfBntqn8EGdjvdVktiv0baPIS)tmqHxmU0OyCkIPOBbBDVNpIv68AYPtlXoNffvmETJiwy4rqX0H9eXYL3ZhX0hVNp6Xs5sde1oIrFYeiveCrSfSDc2zeJHfff42uWmHRoOvfLocaREelxEpFeJjmJQIYc3e9yPCTVIAhXOpzcKkcUi2c2ob7mIXWIIcCBkyMWvh0QIshbGvpILlVNpIXqWJGB7hx0JLYfFCu7ig9jtGurWfXwW2jyNrmgwuuGBtbZeU6Gwvu6iaS6rSC598rm0gsmHzurpwkh0yu7ig9jtGurWfXwW2jyNrmgwuuGBtbZeU6Gwvu6iaS6rSC598rS8x05Wmuxzie9yPCGRO2rm6tMaPIGlILlVNpIXEuTDQ4Iyk6wWw375JyCKqt2GlgAgcm5ARyOdum2lzcKyTtfhFqmW3rIXRDeXW2uWmHtSbvmosPJaeXwW2jyNrmgwuuGBtbZeU6Gwvu6iaS6IXn3IH24q8kKkY(pXaLyCqJrp6rSZPm4i1L6IAhlLRO2rm6tMaPIGlIn6rSJ8iwU8E(igijStMafXajdSueBntqn8EGdjvdVQk)fbSqsio6QOWC598zqSYXlgxaAGseXajH1plOi2HOQocKoKjOIESuoe1oIrFYeiveCrSC598rmqYVpKiMIUfS19E(i2(y(9HiwJkgpsSesITsD9(Xj28IXX8xKylKeIJoaXa)NWWgXyi0bsIH2WZftL)IeRrfJhjgsccj2pIvAJdXppdBjOymSUyCmHBfddjvdpX6xSbQiOy(igoYfRmy1DwijgRUyC(hX4Z55eum(0D5D9ZjGi2c2ob7mIXzXkRyGKWozceWHOQocKoKjOeJBUfRSI5zGEh4BCi(5zylbbOpzcKsSDI5zGEhqLWT1djvdpa6tMaPeJtITtS1uWmv9PF)aueAVAxSYfJlX2jwzfdY(e6aXrafjCBDqRocvlYZjynVlVRFa6tMaPIESuWlQDeJ(KjqQi4Iy5Y75Jy6ZeQq6gw4IIy0ECywZIH99iwj1yedDG1N2JhlLROhlTKrTJy0NmbsfbxeBbBNGDgXONG42iw54fRKAuSDIrpbXTbqrO9QDXkhVyCPrX2jwzfdKe2jtGaoev1rG0HmbLy7eBnfmtvF63pafH2R2fRCX4sSDIPigwuua0(vvEuU9P7aGur2)jgOeJRiwU8E(i2HKQHxbfurpwAjIAhXOpzcKkcUi2OhXoYJy5Y75JyGKWozcuedKmWsrS1uWmv9PF)aueAVAxSYXlghetlXyyrrboKun8QmHurhaREetr3c26EpFeBVAOyocKoKjOoXqhOy07eSFCIHHKQHNyCm)ffXajH1plOi2HOQRPGzQ6t)(f9yPAwu7ig9jtGurWfXg9i2rEelxEpFedKe2jtGIyGKbwkITMcMPQp97hGIq7v7IvoEXaVi2c2ob7mITgqOpFhy7gyNFedKew)SGIyhIQUMcMPQp97x0JLQbIAhXOpzcKkcUi2OhXoYJy5Y75JyGKWozcuedKmWsrS1uWmv9PF)aueAVAxmqHxmUIyly7eSZigijStMabWEuvh2dS9nv44P3Zl2oXoDkeQEcXr(bCiSWEl91ZhyHyLJxSsgXajH1plOi2HOQRPGzQ6t)(f9yP7RO2rm6tMaPIGlILlVNpIDiPA4vv5VOiMIUfS19E(ighZFrIPyH9JtmSnfmt4eBGILmdiKyocKoKjOaIyly7eSZigijStMabCiQ6AkyMQ(0VFITtmolgijStMabCiQQJaPdzckX4MBXyyrrbUnfmt4QdAvrPJaaPIS)tSYXlgxaCqmU5wStNcHQNqCKFahclS3sF98bwiw54fRKITtS1mb1W7bUnfmt4QdAvrPJaaPIS)tSYfJlnkgNIESu(4O2rm6tMaPIGlILlVNpIDiPA4vv5VOiMIUfS19E(ig4yHVyqQi7VFCIXX8x0jgdHoqsmhHedTXH4IrV6eRrfdB4Oy8MF)UymKyqkvBeRFX8UGaIyly7eSZigijStMabCiQ6AkyMQ(0VFITtm0ghIxHur2)jgOeBntqn8EGBtbZeU6Gwvu6iaqQi7)IE0JyO93hsu7yPCf1oIrFYeiveCrSrpIDKhXYL3ZhXajHDYeOigizGLIyEgO3b0HubPAp9EEa6tMaPeBNyNofcvpH4i)aoewyVL(65dSqmqjgNfReIPjITgqOpFh4PfCcdujgNeBNyLvS1ac957aB3a78Jyk6wWw375JyLjshiXyV(XjMgcPcs1E6988lwcY0kXw559JtmSqViXYxjgh7fjgpe6fddjvdpX4y(lsS(e7M5fZhXyiXypsXVy0EwKUlg6afBFWgyNFedKew)SGIy6qQGu17v118Q275JESuoe1oIrFYeiveCrSfSDc2zeRSIbsc7Kjqa6qQGu17v118Q275fBNyNofcvpH4i)aoewyVL(65dSqmqjMMj2oXkRymSOOahsQgEvv(lcGvxSDIXWIIcCHEr18vvvViaivK9FIbkXqBCiEfsfz)Ny7edsOq6qsMafXYL3ZhXUqVOA(QQQxu0JLcErTJy0NmbsfbxeBbBNGDgXajHDYeiaDivqQ69Q6AEv798ITtS1mb1W7boKun8QQ8xeWcjH4ORIcZL3ZNbXaLyCbObkHy7eJHfff4c9IQ5RQQEraqQi7)eduITMjOgEpWTPGzcxDqRkkDeaivK9FITtmol2AMGA49ahsQgEvv(lcasPAJy7eJHfff42uWmHRoOvfLocaKkY(pX0eXyyrrboKun8QQ8xeaKkY(pXaLyCbWbX4uelxEpFe7c9IQ5RQQErrpwAjJAhXOpzcKkcUi2OhXoYJy5Y75JyGKWozcuedKmWsrSI8CcwZ7Y76VcPIS)tSYftJIXn3IvwX8mqVd8noe)8mSLGa0Nmbsj2oX8mqVdOs426HKQHha9jtGuITtmgwuuGdjvdVQk)fbWQlg3Cl2PtHq1tioYpGdHf2BPVE(aleRC8IPzrmqsy9ZckIDBB9kKv3zHu0JLwIO2rm6tMaPIGlILlVNpIbz1DwifXu0TGTU3ZhX2hqKUyS6IvgS6olKeRrfRDX6tSKzyDX8rmi7l2W6arSfSDc2zeJZIvwXajHDYeiGBBRxHS6olKeJBUfdKe2jtGaypQQd7b2(MkC8075fJtITtmpH4ihW7cQ6tv1KyAIyqQi7)eRCX0mX2jgKqH0HKmbk6Xs1SO2rSC598rSJwqYRoTq(MpILIy0Nmbsfbx0JLQbIAhXOpzcKkcUiwU8E(igKv3zHueBTzfOQNqCKFXs5kITGTtWoJyLvmqsyNmbc4226viRUZcjX2jwzfdKe2jtGaypQQd7b2(MkC8075fBNyNofcvpH4i)aoewyVL(65dSqSYXlgheBNyEcXroG3fu1NQQjXkhVyCwSsiMwIXzX4GyAAXwtbZu1N(9tmojgNeBNyqcfshsYeOiMIUfS19E(igFMn4TACVFCI5jeh5Nyos6IXRdbXcniKyOdumhHetXctVNxSbvSYGv3zHKyqcfshIykwy)4etpFfv0lGOhlDFf1oIrFYeiveCrSC598rmiRUZcPiMIUfS19E(iwzqOq6qeRmy1DwijgLWWgXAuXAxmEDiigTh9gsIPyH9JtmSnfmt4aeJJJyos6IbjuiDiI1OIHnCumCKFIbPuTrS(fZriXEApUyL4aIyly7eSZiwzfdKe2jtGaUTTEfYQ7SqsSDIbPIS)tmqj2AMGA49a3McMjC1bTQO0raGur2)jMwIXLgfBNyRzcQH3dCBkyMWvh0QIshbasfz)NyGcVyLqSDI5jeh5aExqvFQQMettedsfz)NyLl2AMGA49a3McMjC1bTQO0raGur2)jMwIvIOhlLpoQDeJ(KjqQi4Iyly7eSZiwzfdKe2jtGaypQQd7b2(MkC8075fBNyNofcvpH4i)eRC8IbErSC598rmMqU2w1hEkcg9yPCPXO2rSC598rmcK(wemDkIrFYeiveCrp6rpIbcbVE(yPCqJCGlncEACFfX4LWVFCxeRm5tLrPAWs338bXetBesSUqFGUyOduS9FoLbhHu7xmiXhX2qsj2nfKyjRpfPtkXwi5JJoabmnv)KyGhFqS9opie0jLy7hY(e6aXra7Z9lMpITFi7tOdehbSpbOpzcKA)IXzU2dNaeW0u9tIPz8bX278GqqNuITFi7tOdehbSp3Vy(i2(HSpHoqCeW(eG(KjqQ9lgN5ApCcqatBesm0jegE9JtSKfMNy8iijg7rkX6xmhHelxEpVyH(CXyyDX4rqsSFCXqh2xjw)I5iKyPsnVyQ0tM8i(GaMyAIy3McMjC1bTQO0rQjRply7cycyLjFQmkvdw6(MpiMyAJqI1f6d0fdDGITFfHMSbF)Ibj(i2gskXUPGelz9PiDsj2cjFC0biGPncjg6ecdV(XjwYcZtmEeKeJ9iLy9lMJqILlVNxSqFUymSUy8iij2pUyOd7ReRFXCesSuPMxmv6jtEeFqatmnrSBtbZeU6Gwvu6i1K1NfSDbmbSYKpvgLQblDFZhetmTriX6c9b6IHoqX2VoKwtbt67xmiXhX2qsj2nfKyjRpfPtkXwi5JJoabmnv)KyAgFqS9opie0jLy7hY(e6aXra7Z9lMpITFi7tOdehbSpbOpzcKA)ILUyG)b)OPeJZCThobiGjGvM8PYOunyP7B(GyIPncjwxOpqxm0bk2(xQB)Ibj(i2gskXUPGelz9PiDsj2cjFC0biGPP6NeRK8bX278GqqNuITFi7tOdehbSp3Vy(i2(HSpHoqCeW(eG(KjqQ9lgN5WE4eGaMawzYNkJs1GLUV5dIjM2iKyDH(aDXqhOy7)CkdosDPU9lgK4JyBiPe7McsSK1NI0jLylK8XrhGaMMQFsmoWheBVZdcbDsj2(HSpHoqCeW(C)I5Jy7hY(e6aXra7ta6tMaP2VyPlg4FWpAkX4mx7HtacycyLjFQmkvdw6(MpiMyAJqI1f6d0fdDGITFg2oO2VyqIpITHKsSBkiXswFksNuITqYhhDacyAQ(jX4Ipi2ENhec6KsS9dzFcDG4iG95(fZhX2pK9j0bIJa2Na0NmbsTFX4mx7HtacycyAWc9b6KsmnGy5Y75fl0NFacyrStNwXs5GMXvethoODGIy8LVIHXY4bY3iwzm4yjbm(YxX4ZjCHigxAKFX4Gg5axcycy8LVIXNhqiXajHDYeia2JQ6WEGTVPchp9EEXy1f7gXAxS(e7ixmgcDGKy8iXypsS2beW4lFfBVtbt)KyfSbV1dKyRmeQ5Y75RH(CXO3HnDI5JyqsXUiX0hNEVZGyqI3a3ciGjGXx(kMgcjnzVtbt6cy5Y75paDiTMcM01cpOtD9WMQ(038cy5Y75paDiTMcM01cpOzg3dKQIgYnKIx)4Q(SN(fWYL3ZFa6qAnfmPRfEqFoLbhralxEp)bOdP1uWKUw4bDrc3sQk6aRkkDe(1H0AkysVE0AE1HNRsiGLlVN)a0H0Akysxl8G(c9IQ5RQQEr8RdP1uWKE9O18Qdpx83O4HekKoKKjqcy5Y75paDiTMcM01cpOpKun8QmHurh)nkEi7tOdehbuKWT1bT6iuTipNG18U8U(fWeW4lFfJpN9lwzmE698cy5Y75p8B71wbm(kg47iLy(iMICcw0pjgpeYriOyRzcQH3FIXlBxm0bkg2ZrXyYJuInVyEcXr(biGLlVN)0cpObjHDYei()SGWFVQUMx1Epp)GKbwcpdlkkWf6fvZxvv9Iay15M7tNcHQNqCKFahclS3sF98bwuoEntaJVIb(5dBeBHKposm44P3ZlwJkgpsmKeesmDypW23uHJNEpVyh5ILVsSc2G36bsmpH4i)eJvhqalxEp)PfEqdsc7Kjq8)zbHN9OQoShy7BQWXtVNNFqYalHxh2dS9nv44P3ZV70PqO6jeh5hWHWc7T0xpFGfLJNdcy8vS9IqRTITxoEILUyOn8CbSC598Nw4b9kdHAU8E(AOpN)pli8l1jGXxXkd2xmu2qyJyhV2xi0jMpI5iKyyoLbhHuIvgJNEpVyCMzJyQPFCIDd)Tlg6ax0jM(mH(XjwJk2pos)4eRpXsqYoKmbItacy5Y75pTWdAi7xZL3Zxd958)zbH)CkdocP4VrXFoLbhHuaziiGXxX4t66HnIDHEr18vvvViXsxmoOLy7vdftXc7hNyocjgAdpxmU0OyhTMxD8NOobfZrsxSsQLy7vdfRrfRDXO9O3q6eJx7i9lMJqI90ECX237LJInqX6tSFCXy1fWYL3ZFAHh0xOxunFvv1lI)gf)PtHq1tioYpGdHf2BPVE(alaLMTdTXH4vivK9FLRz7yyrrbUqVOA(QQQxeaKkY(pqHBPakY9SBnfmtvF63VYXxsnHZExqGIlnYjnnheW4RyAiShy7BeRmgp9EEWVettr((pXW1GqILITGPUyjZW6IrpbXTrm0bkMJqIDoLbhrS9YXtmoZW2bfbf78oeedsNoTCXANtaIb(nRo)Tl2kFXyiXCK0f76c9abiGLlVN)0cpOxziuZL3Zxd958)zbH)CkdosDPo(Bu8GKWozcea7rvDypW23uHJNEpVagFfd8DKsmFetrO9tIXdHEX8rm2Je7CkdoIy7LJNydumg2oOi4jGLlVN)0cpObjHDYei()SGWFoLbhP6iq6qMGIFqYalHNdLqlpd07aG04gia9jtGuAAoOrT8mqVduKNtW6GwpKun8oa6tMaP00CqJA5zGEh4qs1WRIol2dG(KjqknnhkHwEgO3bYqUGTVbG(Kjqknnh0OwCOeAAoF6uiu9eIJ8d4qyH9w6RNpWIYXxsojGXxX278xRiOySx)4elfdZPm4iITxokgpe6fds5cPFCI5iKy0tqCBeZrG0HmbLawU8E(tl8GELHqnxEpFn0NZ)Nfe(ZPm4i1L64VrXtpbXTbqrO9QDqHhKe2jtGaoNYGJuDeiDitqjGXxX08(7drS0fRKAjgV2rgwxmoIj2afJx7iIHnCuSfSDXyyrr5xSsOLy8AhrmoIjgNhw)Afj25ugCeojGXxXkZ2reJJyILHBedT)(qelDXkPwIL4Y(pxSskMNqCKFIX5H1VwrIDoLbhHtcy5Y75pTWd6vgc1C5981qFo)Fwq4r7Vpe(Bu8RPGzQ6t)(Hp)UixijehPQlDU5EnfmtvF63pafH2R2bfEU4MB0ghIxHur2)bk8CTBnfmtvF63VYXdECZndlkkWTPGzcxDqRkkDKAY6Zc2oaR(U1uWmv9PF)khFj5M7tNcHQNqCKFahclS3sF98bwuo(sUBnfmtvF63VYXxsbm(kg47iXsXyy7GIGIXdHEXGuUq6hNyocjg9ee3gXCeiDitqjGLlVN)0cpOxziuZL3Zxd958)zbHNHTdk(Bu80tqCBaueAVAhu4bjHDYeiGZPm4ivhbshYeucy8vmn1WJoxmDypW23iw)ILHGydQyocjgFsd1uIXqRK9iXAxSvYE0jwk2(EVCualxEp)PfEqNWv(u1hiKEN)gfp9ee3gafH2R2lhpxLql6jiUnaqch9cy5Y75pTWd6eUYNQ6SHJeWYL3ZFAHh0HghIFvWFSkCf07cy5Y75pTWdAMexDqRoSxBpbmbm(YxXahBhue8eWYL3ZFamSDqH)qAq4VrXxwpd07aFJdXppdBjia9jtGu7GSpHoqCeG3)MQp7PxvMqQODNofcvpH4i)aoewyVL(65dSauLqalxEp)bWW2bLw4b9HWc7T0xpFGf83O4pDkeQEcXr(voEoSJZRzcQH3dCeeMoPQmZt1tV3salKeIJUkkmxEpFgafEoaObkb3CF6uiu9eIJ8d4qyH9w6RNpWIYljNeWYL3ZFamSDqPfEqFeeMoPQmZt1tV3s83O4xZeudVh4iimDsvzMNQNEVLawijehDvuyU8E(muoEoaObkb3CFdBGPFfqGsvLztL2twOhia6tMaP2vwgwuuGaLQkZMkTNSqpqaS6cy5Y75pag2oO0cpOXfMPGjKksalxEp)bWW2bLw4bntU2EEYiGjGXx(k2ENjOgE)jGXxXaFhjghZFrInOOAcULsmgcDGKyocjgAdpxSdHf2BPVE(aledfofIP9a)unITMc6eRFabSC598hWsDAHh0hsQgEvv(lIF2JQdkAf3sHNl(Bu8LLHfff4qs1WRQYFraS67yyrrboewyVL(QpWpvdaR(ogwuuGdHf2BPV6d8t1aaPIS)du4bpGsiGXxX4m47d0DILbiLQnIXQlgdTs2JeJhjMpZwXWqs1WtmnFwShNeJ9iXW2uWmHtSbfvtWTuIXqOdKeZriXqB45IDiSWEl91ZhyHyOWPqmTh4NQrS1uqNy9diGLlVN)awQtl8G(2uWmHRoOvfLoc)Shvhu0kULcpx83O4zyrrboewyVL(QpWpvdaR(ogwuuGdHf2BPV6d8t1aaPIS)du4bpGsiGLlVN)awQtl8GgnK4Oqi9EE(Bu8GKWozceW9Q6AEv7987k75ugCesbuKVhibSC598hWsDAHh0GKFFi83O45mK9j0bIJaks426GwDeQwKNtWAExEx)7wtbZu1N(9dqrO9QDqHNlnXZa9oGIiDcwphMoHJkaOpzcKIBUHSpHoqCeGIshjSPEiPA4D7wtbZu1N(9duCXPDmSOOa3McMjC1bTQO0ray13XWIIcCiPA4vv5Viaw9Df55eSM3L31Ffsfz)hEnUJHfffqrPJe2upKun8oa1W7fW4RyA4mbXqhOyApWpvJy6qstWgokgV2reddHJIbPuTrmEi0l2pUyq2)7hNyyAoGawU8E(dyPoTWdA9zcviDdlCr8JoW6t7XXZf)nkEpd07ahclS3sF1h4NQbG(KjqQDL1Za9oWHKQHxfDwSha9jtGucy8vmW3rIP9a)unIPdjXWgokgpe6fJhjgsccjMJqIrpbXTrmEiKJqqXqHtHy6Ze6hNy8AhzyDXW0CXgOyG)ypxmC0tWme2aiGLlVN)awQtl8G(qyH9w6R(a)un83O4PNG42uoEntJ7ajHDYeiG7v118Q2753TMjOgEpWTPGzcxDqRkkDeaw9DRzcQH3dCiPA4vv5ViGfscXrx545salxEp)bSuNw4b9rqy6KQYmpvp9ElX)AZkqvpH4i)WZf)nkEqsyNmbc4EvDnVQ9E(DLvnoWrqy6KQYmpvp9ElvvJd49AB)425jeh5aExqvFQQMkhph4IBUrBCiEfsfz)hOWxIDNofcvpH4i)aoewyVL(65dSauGNawU8E(dyPoTWd6J0V(4VrXdsc7Kjqa3RQR5vT3ZVBnfmtvF63pafH2R2lhpxcy8vmW3rIHTPGzcNyZl2AMGA49IX5e1jOyOn8CXWEoYjXy)aDNy8iXsijgUPFCI5Jy6JUyApWpvJy5RetnI9JlgsccjggsQgEIP5ZI9aeWYL3ZFal1PfEqFBkyMWvh0QIshH)gfpijStMabCVQUMx1Ep)oo7zGEhGEqOWO3pU6HKQH3bqFYeif3CVMjOgEpWHKQHxvL)IawijehDLJNloTJZL1Za9oWHWc7T0x9b(PAaOpzcKIBU9mqVdCiPA4vrNf7bqFYeif3CVMjOgEpWHWc7T0x9b(PAaGur2)voh4KagFftdIkwQuNyjKeJvNFXUV1jXCesS5jX41oIyHHhDUyARnhbed8DKy8qOxm1M(XjgAEobfZrYxS9QHIPi0E1UyduSFCXoNYGJqkX41oYW6IL)gX2RgciGLlVN)awQtl8GUiHBjvfDGvfLoc)RnRav9eIJ8dpx83O4HzRQei07aPsDaS674SNqCKd4Dbv9PQAcuRPGzQ6t)(bOi0E1o3Cx2ZPm4iKcidHDRPGzQ6t)(bOi0E1E54x61ICp1tNEfNeW4RyAquX(rSuPoX41HGyQMeJx7i9lMJqI90ECXapnE8lg7rIXNr5OyZlgZCNy8AhzyDXYFJy7vdbeWYL3ZFal1PfEqxKWTKQIoWQIshH)gfpmBvLaHEhivQdO)YbpnQjWSvvce6DGuPoaflm9E(DRPGzQ6t)(bOi0E1E54x61ICp1tNELawU8E(dyPoTWd6djvdVktiv0XFJIhKe2jtGaUxvxZRAVNF3AkyMQ(0VFakcTxTxoEoiGLlVN)awQtl8GMwit)4Qqsh2f5R4VrXdsc7Kjqa3RQR5vT3ZVBnfmtvF63pafH2R2lhph2XzqsyNmbcG9OQoShy7BQWXtVNNBUpDkeQEcXr(bCiSWEl91ZhybOWxsojGXxXkZ2redtZ5xSgvSFCXYaKs1gXuZt8lg7rIP9a)unIXRDeXWgokgRoGawU8E(dyPoTWd6dHf2BPV6d8t1WFJI3Za9oWHKQHxfDwSha9jtGu7ajHDYeiG7v118Q2753XWIIcCBkyMWvh0QIshbGvxalxEp)bSuNw4b9HKQHxvL)I4VrXxwgwuuGdjvdVQk)fbWQVdTXH4vivK9FGc)(slpd07ahlJtquwCea9jtGucy8vSsNxtoDAj25SOOIXRDeXcdpckMoShbSC598hWsDAHh06J3ZZFJINHfffGjmJkWEoaKYLZn3OnoeVcPIS)duGNg5MBgwuuGBtbZeU6Gwvu6iaS674mdlkkWHKQHxLjKk6ay15M71mb1W7boKun8QmHurhaKkY(pqHNlnYjbSC598hWsDAHh0mHzuvuw4g(Bu8mSOOa3McMjC1bTQO0ray1fWYL3ZFal1PfEqZqWJGB7hh)nkEgwuuGBtbZeU6Gwvu6iaS6cy5Y75pGL60cpOrBiXeMrXFJINHfff42uWmHRoOvfLocaRUawU8E(dyPoTWd68x05WmuxziWFJINHfff42uWmHRoOvfLocaRUagFfJJeAYgCXqZqGjxBfdDGIXEjtGeRDQ44dIb(osmETJig2McMjCInOIXrkDeabSC598hWsDAHh0ShvBNko(Bu8mSOOa3McMjC1bTQO0ray15MB0ghIxHur2)bkoOrbmbm(YxX08(7dHGNagFfRmr6ajg71poX0qivqQ2tVNNFXsqMwj2kpVFCIHf6fjw(kX4yViX4HqVyyiPA4jghZFrI1Ny3mVy(igdjg7rk(fJ2ZI0DXqhOy7d2a78fWYL3ZFaO93hcEqsyNmbI)pli86qQGu17v118Q2755hKmWs49mqVdOdPcs1E698a0NmbsT70PqO6jeh5hWHWc7T0xpFGfGIZLqtwdi0NVd80coHbQ40UYUgqOpFhy7gyNVawU8E(daT)(q0cpOVqVOA(QQQxe)nk(Ycsc7Kjqa6qQGu17v118Q2753D6uiu9eIJ8d4qyH9w6RNpWcqPz7kldlkkWHKQHxvL)Iay13XWIIcCHEr18vvvViaivK9FGcTXH4vivK9F7GekKoKKjqcy5Y75pa0(7drl8G(c9IQ5RQQEr83O4bjHDYeiaDivqQ69Q6AEv7987wZeudVh4qs1WRQYFralKeIJUkkmxEpFgafxaAGsSJHfff4c9IQ5RQQEraqQi7)a1AMGA49a3McMjC1bTQO0raGur2)TJZRzcQH3dCiPA4vv5ViaiLQn7yyrrbUnfmt4QdAvrPJaaPIS)ttyyrrboKun8QQ8xeaKkY(pqXfah4KawU8E(daT)(q0cpObjHDYei()SGWFBB9kKv3zHe)GKbwcFrEobR5D5D9xHur2)vUg5M7Y6zGEh4BCi(5zylbbOpzcKANNb6Davc3wpKun8aOpzcKAhdlkkWHKQHxvL)Iay15M7tNcHQNqCKFahclS3sF98bwuoEnJ)9HuqNGITpMWozcKyOduSYGv3zHeGyyBBDXuSW(XjgFopNGIXNUlVRFXgOykwy)4eJJ5ViX41oIyCmHBflFLy)iwPnoe)8mSLGacy8vS9bePlgRUyLbRUZcjXAuXAxS(elzgwxmFedY(InSoGawU8E(daT)(q0cpOHS6olK4VrXZ5Ycsc7Kjqa32wVcz1DwiXn3GKWozcea7rvDypW23uHJNEppN25jeh5aExqvFQQM0eivK9FLRz7GekKoKKjqcy5Y75pa0(7drl8G(OfK8QtlKV5Jyjbm(kgFMn4TACVFCI5jeh5Nyos6IXRdbXcniKyOdumhHetXctVNxSbvSYGv3zHKyqcfshIykwy)4etpFfv0labSC598haA)9HOfEqdz1DwiX)AZkqvpH4i)WZf)nk(Ycsc7Kjqa32wVcz1DwiTRSGKWozcea7rvDypW23uHJNEp)UtNcHQNqCKFahclS3sF98bwuoEoSZtioYb8UGQ(uvnvoEoxcT4mh00RPGzQ6t)(XjoTdsOq6qsMajGXxXkdcfshIyLbRUZcjXOeg2iwJkw7IXRdbXO9O3qsmflSFCIHTPGzchGyCCeZrsxmiHcPdrSgvmSHJIHJ8tmiLQnI1Vyocj2t7XfRehGawU8E(daT)(q0cpOHS6olK4VrXxwqsyNmbc4226viRUZcPDqQi7)a1AMGA49a3McMjC1bTQO0raGur2)PfxAC3AMGA49a3McMjC1bTQO0raGur2)bk8LyNNqCKd4Dbv9PQAstGur2)v(AMGA49a3McMjC1bTQO0raGur2)PvjeWYL3ZFaO93hIw4bntixBR6dpfb5VrXxwqsyNmbcG9OQoShy7BQWXtVNF3PtHq1tioYVYXdEcy5Y75pa0(7drl8GMaPVfbtNeWeW4lFfdZPm4iIT3zcQH3Fcy5Y75pGZPm4i1L60cpObjHDYei()SGWFiQQJaPdzck(bjdSe(1mb1W7boKun8QQ8xeWcjH4ORIcZL3ZNHYXZfGgOe8VpKc6euS9Xe2jtGeW4Ry7J53hIynQy8iXsij2k117hNyZlghZFrITqsio6aed8FcdBeJHqhijgAdpxmv(lsSgvmEKyijiKy)iwPnoe)8mSLGIXW6IXXeUvmmKun8eRFXgOIGI5Jy4ixSYGv3zHKyS6IX5FeJpNNtqX4t3L31pNaeWYL3ZFaNtzWrQl1PfEqds(9HWFJINZLfKe2jtGaoev1rG0Hmbf3Cxwpd07aFJdXppdBjia9jtGu78mqVdOs426HKQHha9jtGuCA3AkyMQ(0VFakcTxTxox7klK9j0bIJaks426GwDeQwKNtWAExEx)cy5Y75pGZPm4i1L60cpO1NjuH0nSWfXp6aRpThhpx8t7XHznlg23XxsnYVgotqm0bkggsQgEfuqjMwIHHKQH35WEljg7hO7eJhjwcjXsMH1fZhXwPUyZlghZFrITqsio6aed8Zh2igpe6ftZ7xjwzs52NUtS(elzgwxmFedY(InSoGawU8E(d4CkdosDPoTWd6djvdVckO4VrXtpbXTPC8LuJ7ONG42aOi0E1E545sJ7klijStMabCiQQJaPdzcQDRPGzQ6t)(bOi0E1E5CTtrmSOOaO9RQ8OC7t3baPIS)duCjGXxX2RgkMJaPdzcQtm0bkg9ob7hNyyiPA4jghZFrcy5Y75pGZPm4i1L60cpObjHDYei()SGWFiQ6AkyMQ(0VF8dsgyj8RPGzQ6t)(bOi0E1E545GwmSOOahsQgEvMqQOdGvxalxEp)bCoLbhPUuNw4bnijStMaX)Nfe(drvxtbZu1N(9JFqYalHFnfmtvF63pafH2R2lhp4XFJIFnGqF(oW2nWoFbSC598hW5ugCK6sDAHh0GKWozce)Fwq4pevDnfmtvF63p(bjdSe(1uWmv9PF)aueAVAhu45I)gfpijStMabWEuvh2dS9nv44P3ZV70PqO6jeh5hWHWc7T0xpFGfLJVKcy8vmoM)IetXc7hNyyBkyMWj2aflzgqiXCeiDitqbiGLlVN)aoNYGJuxQtl8G(qs1WRQYFr83O4bjHDYeiGdrvxtbZu1N(9BhNbjHDYeiGdrvDeiDitqXn3mSOOa3McMjC1bTQO0raGur2)voEUa4a3CF6uiu9eIJ8d4qyH9w6RNpWIYXxYDRzcQH3dCBkyMWvh0QIshbasfz)x5CProjGXxXahl8fdsfz)9JtmoM)IoXyi0bsI5iKyOnoexm6vNynQyydhfJ3873fJHedsPAJy9lM3feGawU8E(d4CkdosDPoTWd6djvdVQk)fXFJIhKe2jtGaoevDnfmtvF63VDOnoeVcPIS)duRzcQH3dCBkyMWvh0QIshbasfz)NaMagF5RyyoLbhHuIvgJNEpVagFftdIkgMtzWrani53hIyjKeJvNFXypsmmKun8oh2BjX8rmg6j02fdfofI5iKy65DniKymZZEILVsmnVFLyLjLBF6o(fJaHEXAuX4rILqsS0fRi3Jy7vdfJZSFGUtm2RFCIXNZZjOy8P7Y76Ntcy5Y75pGZPm4iKc)HKQH35WElXFJINZmSOOaNtzWray15MBgwuuaqYVpeawDoTRipNG18U8U(RqQi7)WRrbm(kMM3FFiILUyGNwITxnumETJmSUyCetmqlwj1smETJighXeJx7iIHHWc7T0lM2d8t1igdlkQyS6I5JyjitRe7McsS9QHIXlpNe7ANn9E(dqaJVIXNc3i2LOKy(igA)9Hiw6IvsTeBVAOy8AhrmAp5YdBeRKI5jeh5hGyCglliXYtSH1VwrIDoLbhbGtcy8vmnV)(qelDXkPwITxnumETJmSUyCeJFXkHwIXRDeX4ig)ILVsmntmETJighXelrDck2(y(9HiGLlVN)aoNYGJqkTWd6vgc1C5981qFo)Fwq4r7Vpe(Bu8mSOOahclS3sF1h4NQbGvF3AkyMQ(0VFakcTxTdk8CGBUpDkeQEcXr(bCiSWEl91Zhyb(sUBnfmtvF63VYXxsU5EnfmtvF63pafH2R2bfEU0eo7zGEhqrKobRNdtpXrfa0NmbsTJHfffaK87dbGvNtcy5Y75pGZPm4iKsl8G(qAq4VrX7zGEh4BCi(5zylbbOpzcKAhK9j0bIJa8(3u9zp9QYesfT70PqO6jeh5hWHWc7T0xpFGfGQecy8vmWNUy(ig4jMNqCKFIX5Feth2dNeBlr6IXQlMM3VsSYKYTpDNymBeBTzf6hNyyiPA4DoS3sacy5Y75pGZPm4iKsl8G(qs1W7CyVL4FTzfOQNqCKF45I)gfFzbjHDYeia2JQ6WEGTVPchp9E(DkIHfffaTFvLhLBF6oaivK9FGIRDNofcvpH4i)aoewyVL(65dSau4bVDEcXroG3fu1NQQjnbsfz)x5AMagFftZhOy6WEGTVrm44P3ZZVyShjggsQgENd7TKydieummFGfIXRDeXkt(SyjUS)ZfJvxmFeRKI5jeh5NyduSgvmnVmfRpXGS)3poXguuX488IL)gXYIH9DXguX8eIJ8Jtcy5Y75pGZPm4iKsl8G(qs1W7CyVL4VrXdsc7KjqaShv1H9aBFtfoE69874SIyyrrbq7xv5r52NUdasfz)hO4IBU9mqVdWJs95lYZjia9jtGu7oDkeQEcXr(bCiSWEl91ZhybOWxsojGLlVN)aoNYGJqkTWd6dHf2BPVE(al4VrXF6uiu9eIJ8RC8GNwCMHfffWrOkCCNEawDU5gY(e6aXra52mH9vVHnurHjUc6DoTJZmSOOa3McMjC1bTQO0rQjRply7aS6CZDzzyrrb0HubPAp9EEawDU5(0PqO6jeh5x54lbNeW4RyyiPA4DoS3sI5JyqcfshIyAE)kXktk3(0DILVsmFeJ(JfsIXJeBLVyRec3i2acbflfdLneetZltX63hXCesSN2Jlg2WrXAuX0N7AMabiGLlVN)aoNYGJqkTWd6djvdVZH9wI)gfVIyyrrbq7xv5r52NUdasfz)hOWZf3CVMjOgEpWTPGzcxDqRkkDeaivK9FGIR91ofXWIIcG2VQYJYTpDhaKkY(pqTMjOgEpWTPGzcxDqRkkDeaivK9Fcy5Y75pGZPm4iKsl8GgxyMcMqQi(Bu8mSOOa6eeDGPtQkiu)hW55AB54lXU18k22b0ji6atNuvqO(pay(BlhpxGNawU8E(d4CkdocP0cpOpKun8oh2BjbSC598hW5ugCesPfEqVqOuVEiJZFJIVSEcXroqFvM5UDRPGzQ6t)(bOi0E1E545AhdlkkWHmET)QJqvvc3cWQVJEcIBdG3fu1NAj1y54wkGICprp6Xi]] )
    
end
