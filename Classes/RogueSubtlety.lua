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
            duration = 12,
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
        elseif buff.master_assassins_mark.up then return buff.master_assassin_mark.remains end
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

            toggle = "cooldowns",

            startsCombat = false,
            texture = 236364,

            usable = function ()
                return settings.mfd_waste or combo_points.current == 0, "combo_point (" .. combo_points.current .. ") waste not allowed"
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
            gcd = "spell",
            
            pvptalent = "cold_blood",            

            startsCombat = true,
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


    spec:RegisterSetting( "mfd_waste", true, {
        name = "Allow |T236364:0|t Marked for Death Combo Waste",
        desc = "If unchecked, the addon will not recommend |T236364:0|t Marked for Death if it will waste combo points.",
        type = "toggle",
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


    spec:RegisterPack( "Subtlety", 20201217, [[da1RKbqiIs9iIs2Kq6tQQIrHkLtHkvRcvj6vOQmluf3siIDjPFPQWWqL0XqfwMQk9mvvLPje11qvQTHQK(MQkyCQQqoNQiW6qLG5PkQ7bk7ti8pvrq5GcrQfQQOhIkrtuvKUiQsO2OQQQ(OQQknsvvvWjvfrwPQsVuvvfAMQIq3uvfQDIQQFIQeYqvvLAPQQsEkkMkrXvvfrTvvvv0xrLqJvisoRQiOAVK6VcgSIdtzXq5XsmzcxgzZG8zq1OHQtl1Qvfb51QcZMKBtKDd8BLgUqDCuLGLd55QmDQUokTDvjFNOA8QQOZRk18rfTFrR5qlJMryoP5)xU(lx54xo(H6VCLR8Mdo0m(7ysZeBLhgCsZamjsZWWI5kYFRzIT3Q1eAz0m3YIkKMb394Jl8XhWBhNfRwwPpUwIvzEVGcYG8pUwQ8HMbJTv(tcOX0mcZjn))Y1F5kh)YXpu)LRCL3C9h0mgRJVindtlXLAg8wiiGgtZiOROzKvomSyUI8358xlCwk)kRCEkvijmcLdh)ap58lx)LR538RSY5hVVOCEzO2WuuL9OqmQxu7VdO1nVxqoSX5CBoTNtF5CKNdgbTikh5uoShLt718RSYHlxjSgq5iXQ8owr5umLkyfVxqq1NNdbCutxo(MdIeSfkN41jG3MkhejFrpQAgvF(PLrZCozkhNeAz08ZHwgndbmmfj0FQzkO2juBAgULdgleu9CYuoELnoho5mhmwiO6ld0hELnohUNt0CKSZjuWUZURbbejzn4YbwoCvZyfVxGM5WnXk)Cu)G0UM)F1YOziGHPiH(tntb1oHAtZGXcbvpCwu)GabFratSv24CIMtzLW2q82a)QccQlTNZZWY53C4KZCUysPcUHGt(vpCwu)GaHZxKuoWYjY5enNYkHTH4Tb(LteWYjY5WjN5uwjSneVnWVQGG6s758mSC4iNijhULJBkc4vbrXekCoYCdojvjGHPirorZbJfcQ(Ya9HxzJZH7AgR49c0mftPcwX7feu95AgvFEaysKMbQb9HRDn))tlJMHagMIe6p1mfu7eQnnJBkc4vqdh3p3upiuLagMIe5enhelGGweCQ6n4DW3F2LaMYeuLagMIe5enNlMuQGBi4KF1dNf1piq48fjLZZ5WBnJv8EbAMdVFPDn)rwlJMHagMIe6p1mwX7fOzoCtSYph1pintb1oHAtZi7CEzO2WuuL9OqmQxu7VdO1nVxqorZrqySqqvOgicYj7bGURIijRbxopNdh5enNlMuQGBi4KF1dNf1piq48fjLZZWY5F5enh3qWjV6Tef8niAkNijhejzn4YjIC4vnt5Drrb3qWj)08ZH218ZBTmAgcyyksO)uZuqTtO20mVmuBykQYEuig1lQ93b06M3liNO5WTCeegleufQbIGCYEaO7QisYAWLZZ5WroCYzoUPiGxLtw8cKSZjuLagMIe5enNlMuQGBi4KF1dNf1piq48fjLZZWYjY5WDnJv8EbAMd3eR8Zr9ds7A(5vTmAgcyyksO)uZuqTtO20mxmPub3qWj)Yjcy58VC4lhULdgleu1XPaADNav24C4KZCqSacArWPQ9WmuFHBzvbiKbxIaELagMIe5enNYceSTxfeftOGWGdNqxfzGh5ebSC(HC4EorZHB5GXcbvV3syR6cluqqMJhmwFlO2RSX5WjN5i7CWyHGQXisIeTBEVGkBCoCYzoxmPub3qWj)Yjcy5W7C4UMXkEVanZHZI6heiC(IK0UM)FqlJMHagMIe6p1mfu7eQnnJGWyHGQqnqeKt2daDxfrswdUCEgwoCKdNCMtzxLyLdQ3BjSvDHfkiiZXRisYAWLZZ5WXpkNO5iimwiOkudeb5K9aq3vrKK1GlNNZPSRsSYb17Te2QUWcfeK54vejzn40mwX7fOzoCtSYph1piTR5)hPLrZqadtrc9NAMcQDc1MMbJfcQgtiOfzojcVOgC1ZTYJCIawo8oNO5uwGGT9AmHGwK5Ki8IAWvrg4roralho(NMXkEVandC1UsyktqAxZ)tGwgnJv8EbAMd3eR8Zr9dsZqadtrc9NAxZphCvlJMHagMIe6p1mfu7eQnnJSZXneCYR9fW27YjAoLvcBdXBd8RkiOU0EoralhoYjAoySqq1dF9qdcoofeg6rLnoNO5qacb)D1Bjk4BiYCnNiYbEruLSFQzSI3lqZuWjloC4RRDTRzeeKXQCTmA(5qlJMXkEVanZJU8qZqadtrc9NAxZ)VAz0meWWuKq)PMzJ1mh5AgR49c0mVmuByksZ8YuSKMbJfcQEQUqbdicIUqv24C4KZCUysPcUHGt(vpCwu)GaHZxKuoralhEvZ8YqbGjrAMdicLfiAVxG218)pTmAgcyyksO)uZSXAMJCnJv8EbAMxgQnmfPzEzkwsZeJ6f1(7aADZ7fKt0CUysPcUHGt(vpCwu)GaHZxKuoralNF1mVmuaysKMH9OqmQxu7VdO1nVxG218hzTmAgcyyksO)uZyfVxGMPykvWkEVGGQpxZO6ZdatI0mfXPDn)8wlJMHagMIe6p1mfu7eQnnZ5KPCCsunLsZyfVxGMbXccwX7feu95AgvFEaysKM5CYuooj0UMFEvlJMHagMIe6p1mfu7eQnnZftkvWneCYV6HZI6heiC(IKY55C41CIMdudh3disYAWLte5WR5enhmwiO6P6cfmGii6cvrKK1GlNNZbEruLSFMt0CkRe2gI3g4xoralNiNtKKd3YXBjkNNZHdUMd3ZHxMZVAgR49c0mNQluWaIGOlK218)dAz0meWWuKq)PMPGANqTPzEzO2WuuL9OqmQxu7VdO1nVxGMXkEVantXuQGv8EbbvFUMr1NhaMePzoNmLJhkIt7A()rAz0meWWuKq)PMzJ1mh5AgR49c0mVmuByksZ8YuSKM5xENdF54MIaE9vdFrvcyyksKdVmNF5Ao8LJBkc4vj7CcfwOWHBIv(vjGHPiro8YC(LR5WxoUPiGxpCtSYdqBH9QeWWuKihEzo)Y7C4lh3ueWRMYkO2FxjGHPiro8YC(LR5Wxo)Y7C4L5WTCUysPcUHGt(vpCwu)GaHZxKuoralNiNd31mVmuaysKM5CYuoEWXr0HVkH218)eOLrZqadtrc9NAMcQDc1MMHaec(7QGG6s758mSCEzO2Wuu9CYuoEWXr0HVkHMXkEVantXuQGv8EbbvFUMr1NhaMePzoNmLJhkIt7A(5GRAz0meWWuKq)PMPGANqTPzkRe2gI3g4xoWYXaTKvWneCsekX5WjN5uwjSneVnWVQGG6s758mSC4iho5mhOgoUhqKK1GlNNHLdh5enNYkHTH4Tb(LteWY5F5WjN5GXcbvV3syR6cluqqMJhmwFlO2RSX5enNYkHTH4Tb(LteWYjY5WjN5CXKsfCdbN8RE4SO(bbcNViPCIaworoNO5uwjSneVnWVCIaworwZyfVxGMPykvWkEVGGQpxZO6ZdatI0mqnOpCTR5Ndo0YOziGHPiH(tntb1oHAtZqacb)DvqqDP9CEgwoVmuBykQEozkhp44i6WxLqZyfVxGMPykvWkEVGGQpxZO6ZdatI0mySTsODn)C8Rwgndbmmfj0FQzkO2juBAgcqi4VRccQlTNteWYHdENdF5qacb)DfrWjGMXkEVanJHkgGc(IqeW1UMFo(NwgnJv8EbAgdvmafIzvhPziGHPiH(tTR5NJiRLrZyfVxGMr1WX9l8eIvaxIaUMHagMIe6p1UMFo4TwgnJv8EbAgmdEyHcoQlpondbmmfj0FQDTRzIruzLWmxlJMFo0YOzSI3lqZyXXQ3H4TVfOziGHPiH(tTR5)xTmAgR49c0myR7kseGu2BsiVbWd((ZgOziGHPiH(tTR5)FAz0mwX7fOzoNmLJRziGHPiH(tTR5pYAz0meWWuKq)PMXkEVanJKHEqIa0IccYCCntmIkReM5HJklqCAgo4T218ZBTmAgcyyksO)uZyfVxGM5uDHcgqeeDH0mfu7eQnndIGq0HByksZeJOYkHzE4OYceNMHdTR5Nx1YOziGHPiH(tntb1oHAtZGybe0IGtvjd9iSqbhNcs25eky3z31Gkbmmfj0mwX7fOzoCtSYdyktqN21UMbJTvcTmA(5qlJMHagMIe6p1mfu7eQnnJSZXnfb8kOHJ7NBQheQsadtrICIMdIfqqlcov9g8o47p7satzcQsadtrICIMZftkvWneCYV6HZI6heiC(IKY55C4TMXkEVanZH3V0UM)F1YOziGHPiH(tntb1oHAtZCXKsfCdbN8lNiGLZVAgR49c0mholQFqGW5lss7A()Nwgndbmmfj0FQzkO2juBAMYUkXkhupcHmNebSfqHlUFq1cUHGtxaczfVxGPYjcy58B9h4DoCYzo3YQWAGOQiteWEhOFAsXkQsadtrICIMJSZbJfcQQiteWEhOFAsXkQYgRzSI3lqZCeczojcylGcxC)G0UM)iRLrZyfVxGMbUAxjmLjindbmmfj0FQDn)8wlJMXkEVandMvECUHPziGHPiH(tTRDntrCAz08ZHwgndbmmfj0FQzkO2juBAgzNdgleu9WnXkpimqHQSX5enhmwiO6HZI6hei4lcyITYgNt0CWyHGQholQFqGGViGj2kIKSgC58mSC(xL3AgR49c0mhUjw5bHbkKMH9OWcbfGxeA(5q7A()vlJMHagMIe6p1mfu7eQnndgleu9Wzr9dce8fbmXwzJZjAoySqq1dNf1piqWxeWeBfrswdUCEgwo)RYBnJv8EbAM7Te2QUWcfeK54Ag2JcleuaErO5NdTR5)FAz0meWWuKq)PMPGANqTPzEzO2Wuu9aIqzbI27fKt0CKDoNtMYXjrvYaUI0mwX7fOzGugCsPmVxG218hzTmAgcyyksO)uZuqTtO20mccJfcQcPm4KszEVGkIKSgC58Co)QzSI3lqZaPm4KszEVGqrrg4iTR5N3Az0meWWuKq)PMPGANqTPz4woiwabTi4uvYqpcluWXPGKDoHc2D2DnOsadtrICIMtzLW2q82a)QccQlTNZZWYHJCIKCCtraVkikMqHZrMtWjPkbmmfjYHtoZbXciOfbNQcYCC17WHBIv(vjGHPirorZPSsyBiEBGF58CoCKd3ZjAoySqq17Te2QUWcfeK54v24CIMdgleu9WnXkpimqHQSX5enhj7CcfS7S7AqarswdUCGLdxZjAoySqqvbzoU6D4WnXk)QIvoqZyfVxGM5Lb6dx7A(5vTmAgcyyksO)uZyfVxGMjExvar3YIkKMPGANqTPzCtraVE4SO(bbc(IaMyReWWuKiNO5i7CCtraVE4MyLhG2c7vjGHPiHMbArba9txZphAxZ)pOLrZqadtrc9NAMcQDc1MMHaec(7CIawo8kxZjAoVmuBykQEarOSar79cYjAoLDvIvoOEVLWw1fwOGGmhVYgNt0Ck7QeRCq9WnXkpimqHQfCdbNUCIawoCOzSI3lqZC4SO(bbc(IaMy1UM)FKwgndbmmfj0FQzSI3lqZCeczojcylGcxC)G0mfu7eQnnZld1gMIQhqeklq0EVGCIMJSZrSE9ieYCseWwafU4(bfeRx9U8ObWZjAoUHGtE1Bjk4Bq0uoralNF5iho5mhOgoUhqKK1GlNNHLdVZjAoxmPub3qWj)QholQFqGW5lskNNZ5FAMY7IIcUHGt(P5NdTR5)jqlJMHagMIe6p1mfu7eQnnZld1gMIQhqeklq0EVGCIMtzLW2q82a)QccQlTNteWYHdnJv8EbAMJIV(0UMFo4Qwgndbmmfj0FQzkO2juBAMxgQnmfvpGiuwGO9Eb5enhULJBkc4vc8IuBCdGhoCtSYVkbmmfjYHtoZPSRsSYb1d3eR8GWafQwWneC6Yjcy5WroCpNO5WTCKDoUPiGxpCwu)GabFratSvcyyksKdNCMJBkc41d3eR8a0wyVkbmmfjYHtoZPSRsSYb1dNf1piqWxeWeBfrswdUCIiNFZH7AgR49c0m3BjSvDHfkiiZX1UMFo4qlJMHagMIe6p1mwX7fOzKm0dseGwuqqMJRzkO2juBAgK1Ia9IaE1eIRYgNt0C4woUHGtE1Bjk4Bq0uopNtzLW2q82a)QccQlTNdNCMJSZ5CYuoojQMsLt0CkRe2gI3g4xvqqDP9CIawoL4GK9ZWftaroCxZuExuuWneCYpn)CODn)C8Rwgndbmmfj0FQzkO2juBAgK1Ia9IaE1eIR2GCIiN)X1CIKCqwlc0lc4vtiUQGfzEVGCIMtzLW2q82a)QccQlTNteWYPehKSFgUyci0mwX7fOzKm0dseGwuqqMJRDn)C8pTmAgcyyksO)uZuqTtO20mVmuBykQEarOSar79cYjAoLvcBdXBd8RkiOU0EoralNF1mwX7fOzoCtSYdyktqN218ZrK1YOziGHPiH(tntb1oHAtZ8YqTHPO6beHYceT3liNO5uwjSneVnWVQGG6s75ebSC(nNO5WTCEzO2WuuL9OqmQxu7VdO1nVxqoCYzoxmPub3qWj)QholQFqGW5lskNNHLtKZH7AgR49c0mubFBa8aIIrTKbeAxZph8wlJMHagMIe6p1mfu7eQnnJBkc41d3eR8a0wyVkbmmfjYjAoVmuBykQEarOSar79cYjAoySqq17Te2QUWcfeK54v2ynJv8EbAMdNf1piqWxeWeR218ZbVQLrZqadtrc9NAMcQDc1MMr25GXcbvpCtSYdcduOkBCorZbQHJ7bejzn4Y5zy58JYHVCCtraVESyoHGyHtvcyyksOzSI3lqZC4MyLhegOqAxZph)Gwgndbmmfj0FQzkO2juBAgmwiOkMAxHI98kISINdNCMdudh3disYAWLZZ58pUMdNCMdgleu9ElHTQlSqbbzoELnoNO5WTCWyHGQhUjw5bmLjORYgNdNCMtzxLyLdQhUjw5bmLjORIijRbxopdlho4AoCxZyfVxGMjE9EbAxZph)iTmAgcyyksO)uZuqTtO20mySqq17Te2QUWcfeK54v2ynJv8EbAgm1UIael6T218ZXtGwgndbmmfj0FQzkO2juBAgmwiO69wcBvxyHccYC8kBSMXkEVandgHoc9ObW1UM)F5Qwgndbmmfj0FQzkO2juBAgmwiO69wcBvxyHccYC8kBSMXkEVanduJim1UcTR5)xo0YOziGHPiH(tntb1oHAtZGXcbvV3syR6cluqqMJxzJ1mwX7fOzmqHohzQqXukTR5)3F1YOziGHPiH(tntb1oHAtZGXcbvV3syR6cluqqMJxzJZHtoZbQHJ7bejzn4Y55C(LRAgR49c0mShfANKoTRDnZ5KPC8qrCAz08ZHwgndbmmfj0FQz2ynZrUMXkEVanZld1gMI0mVmflPzk7QeRCq9WnXkpimqHQfCdbNUaeYkEVatLteWYHJ6pWBnZldfaMePzoCrWXr0HVkH218)Rwgndbmmfj0FQzkO2juBAgULJSZ5LHAdtr1dxeCCeD4RsKdNCMJSZXnfb8kOHJ7NBQheQsadtrICIMJBkc4vHHEeoCtSYReWWuKihUNt0CkRe2gI3g4xvqqDP9CIihoYjAoYohelGGweCQkzOhHfk44uqYoNqb7o7UgujGHPiHMXkEVanZld0hU218)pTmAgcyyksO)uZyfVxGMjExvar3YIkKMH(PJSGjTSaxZezUQzGwuaq)018ZH218hzTmAgcyyksO)uZuqTtO20meGqWFNteWYjYCnNO5qacb)DvqqDP9CIawoCW1CIMJSZ5LHAdtr1dxeCCeD4RsKt0CkRe2gI3g4xvqqDP9CIihoYjAoccJfcQc1arqozpa0Dvejzn4Y55C4qZyfVxGM5WnXkxIucTR5N3Az0meWWuKq)PMzJ1mh5AgR49c0mVmuByksZ8YuSKMPSsyBiEBGFvbb1L2Zjcy58Bo8Ldgleu9WnXkpGPmbDv2ynZldfaMePzoCrOSsyBiEBGFAxZpVQLrZqadtrc9NAMnwZCKRzSI3lqZ8YqTHPinZltXsAMYkHTH4Tb(vfeuxApNiGLZ)0mfu7eQnntzFrad41hVrTb0mVmuaysKM5WfHYkHTH4Tb(PDn))Gwgndbmmfj0FQz2ynZrUMXkEVanZld1gMI0mVmflPzkRe2gI3g4xvqqDP9CEgwoCOzkO2juBAMxgQnmfvzpkeJ6f1(7aADZ7fKt0CUysPcUHGt(vpCwu)GaHZxKuoralNiRzEzOaWKinZHlcLvcBdXBd8t7A()rAz0meWWuKq)PMPGANqTPzEzO2Wuu9WfHYkHTH4Tb(Lt0C4woVmuBykQE4IGJJOdFvIC4KZCWyHGQ3BjSvDHfkiiZXRisYAWLteWYHJ6V5WjN5CXKsfCdbN8RE4SO(bbcNViPCIaworoNO5u2vjw5G69wcBvxyHccYC8kIKSgC5eroCW1C4UMXkEVanZHBIvEqyGcPDn)pbAz0meWWuKq)PMPGANqTPzEzO2Wuu9WfHYkHTH4Tb(Lt0CGA44EarswdUCEoNYUkXkhuV3syR6cluqqMJxrKK1GtZyfVxGM5WnXkpimqH0U21mqnOpCTmA(5qlJMHagMIe6p1mBSM5ixZyfVxGM5LHAdtrAMxMIL0mUPiGxJrKejA38EbvcyyksKt0CUysPcUHGt(vpCwu)GaHZxKuopNd3YH35ej5u2xeWaEfqf0QwKihUNt0CKDoL9fbmGxF8g1gqZ8YqbGjrAMyejrIWbeHYceT3lq7A()vlJMHagMIe6p1mfu7eQnnJSZ5LHAdtr1yejrIWbeHYceT3liNO5CXKsfCdbN8RE4SO(bbcNViPCEohEnNO5i7CWyHGQhUjw5bHbkuLnoNO5GXcbvpvxOGbebrxOkIKSgC58CoqnCCpGijRbxorZbrqi6WnmfPzSI3lqZCQUqbdicIUqAxZ))0YOziGHPiH(tntb1oHAtZ8YqTHPOAmIKir4aIqzbI27fKt0Ck7QeRCq9WnXkpimqHQfCdbNUaeYkEVatLZZ5Wr9h4DorZbJfcQEQUqbdicIUqvejzn4Y55Ck7QeRCq9ElHTQlSqbbzoEfrswdUCIMd3YPSRsSYb1d3eR8GWafQIit8oNO5GXcbvV3syR6cluqqMJxrKK1GlNijhmwiO6HBIvEqyGcvrKK1GlNNZHJ6V5WDnJv8EbAMt1fkyarq0fs7A(JSwgndbmmfj0FQz2ynZrUMXkEVanZld1gMI0mVmflPzKSZjuWUZURbbejzn4YjIC4AoCYzoYoh3ueWRGgoUFUPEqOkbmmfjYjAoUPiGxfg6r4WnXkVsadtrICIMdgleu9WnXkpimqHQSX5WjN5CXKsfCdbN8RE4SO(bbcNViPCIawo8QM5LHcatI0m3JooGyJDwePDn)8wlJMHagMIe6p1mfu7eQnnd3Yr258YqTHPO69OJdi2yNfr5WjN58YqTHPOk7rHyuVO2FhqRBEVGC4EorZXneCYRElrbFdIMYjsYbrswdUCIihEnNO5GiieD4gMI0mwX7fOzqSXolI0UMFEvlJMXkEVanZrfe5bNk4GMxGL0meWWuKq)P218)dAz0meWWuKq)PMXkEVandIn2zrKMPGANqTPzKDoVmuBykQEp64aIn2zruorZr258YqTHPOk7rHyuVO2FhqRBEVGCIMZftkvWneCYV6HZI6heiC(IKYjcy58BorZXneCYRElrbFdIMYjcy5WTC4Do8Ld3Y53C4L5uwjSneVnWVC4EoCpNO5GiieD4gMI0mL3fffCdbN8tZphAxZ)pslJMHagMIe6p1mfu7eQnnJSZ5LHAdtr17rhhqSXolIYjAoisYAWLZZ5u2vjw5G69wcBvxyHccYC8kIKSgC5WxoCW1CIMtzxLyLdQ3BjSvDHfkiiZXRisYAWLZZWYH35enh3qWjV6Tef8niAkNijhejzn4YjICk7QeRCq9ElHTQlSqbbzoEfrswdUC4lhERzSI3lqZGyJDwePDn)pbAz0meWWuKq)PMPGANqTPzKDoVmuBykQYEuig1lQ93b06M3liNO5CXKsfCdbN8lNiGLZ)0mwX7fOzWuw5riELliK218Zbx1YOzSI3lqZqV6RqiZjndbmmfj0FQDTRDnZlcD9c08)lx)LRC8lh)tZi3qGga)0mCXi9FX)tI))lxiNCKbNYPLIxKNd0IY5pNtMYXjXFYbr8cSnIe5CReLJX6RK5KiNcUbGtxn)(eBaLZ)4c5WLl4fHCsKZFqSacArWPAK6p54Bo)bXciOfbNQrQkbmmfj(toCJJFY9A(9j2akhELlKdxUGxeYjro)bXciOfbNQrQ)KJV58helGGweCQgPQeWWuK4p5Wno(j3R5xzWPCGwLAL3a45ySi7YroHOCypsKtdYXXPCSI3lihvFEoySEoYjeLdy9CGwwGiNgKJJt5ycXcYryUHzhXfYV5ej5CVLWw1fwOGGmhpyS(wqTNFZVCXi9FX)tI))lxiNCKbNYPLIxKNd0IY5pccYyv(FYbr8cSnIe5CReLJX6RK5KiNcUbGtxn)kdoLd0QuR8gaphJfzxoYjeLd7rICAqoooLJv8Eb5O6ZZbJ1ZroHOCaRNd0Yce50GCCCkhtiwqocZnm7iUq(nNijN7Te2QUWcfeK54bJ13cQ98B(LlgP)l(Fs8)F5c5KJm4uoTu8I8CGwuo)jgrLvcZ8)KdI4fyBejY5wjkhJ1xjZjrofCdaNUA(9j2akhELlKdxUGxeYjro)bXciOfbNQrQ)KJV58helGGweCQgPQeWWuK4p5yEo8I5f9eZHBC8tUxZV5xUyK(V4)jX))LlKtoYGt50sXlYZbAr58NI4(toiIxGTrKiNBLOCmwFLmNe5uWnaC6Q53NydOC4nxihUCbViKtIC(dIfqqlcovJu)jhFZ5piwabTi4unsvjGHPiXFYHB)(tUxZV5xUyK(V4)jX))LlKtoYGt50sXlYZbAr58NZjt54HI4(toiIxGTrKiNBLOCmwFLmNe5uWnaC6Q53NydOC(LlKdxUGxeYjro)bXciOfbNQrQ)KJV58helGGweCQgPQeWWuK4p5yEo8I5f9eZHBC8tUxZV5xUyK(V4)jX))LlKtoYGt50sXlYZbAr58hm2wj(toiIxGTrKiNBLOCmwFLmNe5uWnaC6Q53NydOC4GlKdxUGxeYjro)bXciOfbNQrQ)KJV58helGGweCQgPQeWWuK4p5Wno(j3R5387tskErojY5hYXkEVGCu95xn)QzUyQO5)xELdntmAHAfPzKvomSyUI8358xlCwk)kRCEkvijmcLdh)ap58lx)LR538RSY5hVVOCEzO2WuuL9OqmQxu7VdO1nVxqoSX5CBoTNtF5CKNdgbTikh5uoShLt718RSYHlxjSgq5iXQ8owr5umLkyfVxqq1NNdbCutxo(MdIeSfkN41jG3MkhejFrpQ538RSY5VruKWLReM55xR49cUAmIkReM58b7dlow9oeV9TG8Rv8EbxngrLvcZC(G9b26UIebiL9MeYBa8GV)Sb5xR49cUAmIkReM58b7JZjt545xR49cUAmIkReM58b7djd9GebOffeK548eJOYkHzE4OYcehmo4D(1kEVGRgJOYkHzoFW(4uDHcgqeeDH4jgrLvcZ8WrLfioyCWtdbdrqi6WnmfLFTI3l4QXiQSsyMZhSpoCtSYdyktqhpnemelGGweCQkzOhHfk44uqYoNqb7o7UgKFZVYkNFS1GC(R1nVxq(1kEVGd2JU8i)kRCEYhjYX3CeKtiPgq5ihNCCcLtzxLyLdUCKBTNd0IYHb80CWSJe5SGCCdbN8RMFTI3l44d2hVmuBykIhGjrWoGiuwGO9Eb88YuSemmwiO6P6cfmGii6cvzJ5KZlMuQGBi4KF1dNf1piq48fjfbmEn)kRC4fbuVZPGBa4uoO1nVxqonuoYPCWTxuoXOErT)oGw38Eb5CKNJbe5iXQ8owr54gco5xoSX18Rv8EbhFW(4LHAdtr8amjcg7rHyuVO2FhqRBEVaEEzkwcwmQxu7VdO1nVxq0lMuQGBi4KF1dNf1piq48fjfbSFZVYkhUeNkpYHlF6LJ55a1OZZVwX7fC8b7JIPubR49ccQ(CEaMebRiU8RSY5Vyb5aXQuVZ5K3EbNUC8nhhNYHXjt54KiN)ADZ7fKd3WENJyBa8CULN2ZbArf6YjExvdGNtdLdyD8gapN(YXEzTYWue3R5xR49co(G9bIfeSI3liO6Z5byseSZjt54KGNgc25KPCCsunLk)kRCI0XXQ35CQUqbdicIUq5yEo)YxoC5FNJGf1a4544uoqn68C4GR5CuzbIJhdYjuooU55ez(YHl)7CAOCAph6NXnIUCK3oEdYXXPCa0p9C(VC5tZzr50xoG1ZHno)AfVxWXhSpovxOGbebrxiEAiyxmPub3qWj)QholQFqGW5ls6zEnkudh3disYAWfbVgfJfcQEQUqbdicIUqvejzn4EgEruLSFgTSsyBiEBGFralYrc38wIEMdUYDE5V5xzLZFJ6f1(7C(R1nVxWty58ej)pxoW7xuowofKfNJHTSEoeGqWFNd0IYXXPCoNmLJNdx(0lhUHX2kbHY58wPYbrxmv8CAN71CEcNnMN2ZPyGCWOCCCZZ5APyfvZVwX7fC8b7JIPubR49ccQ(CEaMeb7CYuoEOioEAiyVmuBykQYEuig1lQ93b06M3li)kRCEYhjYX3CeeudOCKJtGC8nh2JY5CYuoEoC5tVCwuoySTsqOl)AfVxWXhSpEzO2WuepatIGDozkhp44i6WxLGNxMILG9lV5Znfb86Rg(IQeWWuKGx(lx5Znfb8QKDoHclu4WnXk)QeWWuKGx(lx5Znfb86HBIvEaAlSxLagMIe8YF5nFUPiGxnLvqT)UsadtrcE5VCLVF5nVKBxmPub3qWj)QholQFqGW5lskcyrM75xzLdxUGRfekh2RbWZXYHXjt545WLpnh54eihezf8gaphhNYHaec(7CCCeD4RsKFTI3l44d2hftPcwX7feu958amjc25KPC8qrC80qWiaHG)UkiOU0(ZWEzO2Wuu9CYuoEWXr0HVkr(vw58)nOp8CmpNiZxoYBhFz9CEktolkh5TJNdZ(0CkO2ZbJfcINC4nF5iVD8CEktoCBz9RfuoNtMYX5E(vw5WfBhpNNYKJPUnhOg0hEoMNtK5lhdU1GZZjY54gco5xoCBz9RfuoNtMYX5E(1kEVGJpyFumLkyfVxqq1NZdWKiyqnOpCEAiyLvcBdXBd8dMbAjRGBi4KiuI5KZYkHTH4Tb(vfeuxA)zyCWjNqnCCpGijRb3ZW4iAzLW2q82a)Ia2)4KtmwiO69wcBvxyHccYC8GX6Bb1ELnoAzLW2q82a)IawK5KZlMuQGBi4KF1dNf1piq48fjfbSihTSsyBiEBGFralY5xzLZt(OCSCWyBLGq5ihNa5GiRG3a4544uoeGqWFNJJJOdFvI8Rv8EbhFW(OykvWkEVGGQpNhGjrWWyBLGNgcgbie83vbb1L2Fg2ld1gMIQNtMYXdooIo8vjYVYkNN4kNopNyuVO2FNtdYXuQCwOCCCkNi9F)eZbJkg7r50EofJ9OlhlN)lx(08Rv8EbhFW(WqfdqbFric480qWiaHG)UkiOU0EeW4G38racb)DfrWjq(1kEVGJpyFyOIbOqmR6O8Rv8EbhFW(q1WX9l8eIvaxIaE(1kEVGJpyFGzWdluWrD5XLFZVYkNpzBLGqx(1kEVGRIX2kbSdVFXtdbt2UPiGxbnCC)Ct9GqvcyyksefXciOfbNQEdEh89NDjGPmbf9IjLk4gco5x9Wzr9dceoFrspZ78Rv8EbxfJTvc(G9XHZI6heiC(IK4PHGDXKsfCdbN8lcy)MFTI3l4QySTsWhSpocHmNebSfqHlUFq80qWk7QeRCq9ieYCseWwafU4(bvl4gcoDbiKv8EbMkcy)w)bEZjN3YQWAGOQiteWEhOFAsXkQsadtrIOYgJfcQQiteWEhOFAsXkQYgNFTI3l4QySTsWhSpGR2vctzck)AfVxWvXyBLGpyFGzLhNBy538RSYHl3vjw5Gl)kRCEYhLZtnqHYzHGIe4froye0IOCCCkhOgDEoholQFqGW5lskhi0kLJmlcyInNYkrxonOMFTI3l4QfXXhSpoCtSYdcduiEypkSqqb4fbmo4PHGjBmwiO6HBIvEqyGcvzJJIXcbvpCwu)GabFratSv24OySqq1dNf1piqWxeWeBfrswdUNH9VkVZVYkhU9Kbk6UCmfImX7CyJZbJkg7r5iNYX39rom4MyLNZ)Vf2J75WEuomVLWw1LZcbfjWlICWiOfr544uoqn68CoCwu)GaHZxKuoqOvkhzweWeBoLvIUCAqn)AfVxWvlIJpyFCVLWw1fwOGGmhNh2JcleuaEraJdEAiyySqq1dNf1piqWxeWeBLnokgleu9Wzr9dce8fbmXwrKK1G7zy)RY78Rv8EbxTio(G9bKYGtkL59c4PHG9YqTHPO6beHYceT3liQSpNmLJtIQKbCfLFTI3l4QfXXhSpGugCsPmVxqOOidCepnembHXcbvHugCsPmVxqfrswdUN)n)AfVxWvlIJpyF8Ya9HZtdbJBiwabTi4uvYqpcluWXPGKDoHc2D2DniAzLW2q82a)QccQlT)mmoIe3ueWRcIIju4CK5eCsQsadtrco5eXciOfbNQcYCC17WHBIv(fTSsyBiEBGFpZb3JIXcbvV3syR6cluqqMJxzJJIXcbvpCtSYdcduOkBCuj7CcfS7S7AqarswdoyCnkgleuvqMJREhoCtSYVQyLdYVYkN)ExvoqlkhzweWeBoXiksy2NMJ82XZHb)P5Git8oh54eihW65GybGgaphM)VMFTI3l4QfXXhSpI3vfq0TSOcXd0Ica6Nomo4PHG5MIaE9Wzr9dce8fbmXwjGHPiruz7MIaE9WnXkpaTf2RsadtrI8RSY5jFuoYSiGj2CIruom7tZroobYroLdU9IYXXPCiaHG)oh54KJtOCGqRuoX7QAa8CK3o(Y65W8)5SOCEcXEEoWjaHmL6Dn)AfVxWvlIJpyFC4SO(bbc(IaMy5PHGracb)DeW4vUg9LHAdtr1dicLfiAVxq0YUkXkhuV3syR6cluqqMJxzJJw2vjw5G6HBIvEqyGcvl4gcoDraJJ8Rv8EbxTio(G9XriK5KiGTakCX9dINY7IIcUHGt(bJdEAiyVmuBykQEarOSar79cIkBX61JqiZjraBbu4I7huqSE17YJgapQBi4Kx9wIc(genfbSF5GtoHA44EarswdUNHX7OxmPub3qWj)QholQFqGW5ls65)LFTI3l4QfXXhSpok(6JNgc2ld1gMIQhqeklq0EVGOLvcBdXBd8RkiOU0EeW4i)kRCEYhLdZBjSvD5SGCk7QeRCqoCZGCcLduJophgWt5EoSafDxoYPCmeLd8TbWZX3CI34CKzratS5yaroInhW65GBVOCyWnXkpN)FlSxn)AfVxWvlIJpyFCVLWw1fwOGGmhNNgc2ld1gMIQhqeklq0EVGOCZnfb8kbErQnUbWdhUjw5xLagMIeCYzzxLyLdQhUjw5bHbkuTGBi40fbmo4EuUjB3ueWRholQFqGGViGj2kbmmfj4Kt3ueWRhUjw5bOTWEvcyyksWjNLDvIvoOE4SO(bbc(IaMyRisYAWfXVCp)kRCEsq5ycXLJHOCyJ5jNd0XuoooLZcOCK3oEoQvoDEoYiZtR58Kpkh54eihX7gaphi7CcLJJBGC4Y)ohbb1L2Zzr5awpNZjt54Kih5TJVSEog4DoC5FxZVwX7fC1I44d2hsg6bjcqlkiiZX5P8UOOGBi4KFW4GNgcgYArGEraVAcXvzJJYn3qWjV6Tef8niA65YkHTH4Tb(vfeuxANtoL95KPCCsunLkAzLW2q82a)QccQlThbSsCqY(z4IjGG75xzLZtckhWMJjexoYBLkhrt5iVD8gKJJt5aOF658pUE8Kd7r58JHEAolihS9UCK3o(Y65yG35WL)Dn)AfVxWvlIJpyFizOhKiaTOGGmhNNgcgYArGEraVAcXvBqe)JRrcYArGEraVAcXvfSiZ7feTSsyBiEBGFvbb1L2Jawjoiz)mCXeqKFTI3l4QfXXhSpoCtSYdyktqhpneSxgQnmfvpGiuwGO9EbrlRe2gI3g4xvqqDP9iG9B(1kEVGRwehFW(Gk4BdGhqumQLmGGNgc2ld1gMIQhqeklq0EVGOLvcBdXBd8RkiOU0EeW(nk3EzO2WuuL9OqmQxu7VdO1nVxaNCEXKsfCdbN8RE4SO(bbcNViPNHfzUNFLvoCX2XZH5)5jNgkhW65ykezI35iwaXtoShLJmlcyInh5TJNdZ(0CyJR5xR49cUArC8b7JdNf1piqWxeWelpnem3ueWRhUjw5bOTWEvcyykse9LHAdtr1dicLfiAVxqumwiO69wcBvxyHccYC8kBC(1kEVGRwehFW(4WnXkpimqH4PHGjBmwiO6HBIvEqyGcvzJJc1WX9aIKSgCpd7hXNBkc41JfZjeelCQsadtrI8RSYH)fejxmvY5CwiOCK3oEoQvoHYjg1B(1kEVGRwehFW(iE9Eb80qWWyHGQyQDfk2ZRiYkoNCc1WX9aIKSgCp)pUYjNySqq17Te2QUWcfeK54v24OCdJfcQE4MyLhWuMGUkBmNCw2vjw5G6HBIvEatzc6QisYAW9mmo4k3ZVwX7fC1I44d2hyQDfbiw0BEAiyySqq17Te2QUWcfeK54v248Rv8EbxTio(G9bgHoc9ObW5PHGHXcbvV3syR6cluqqMJxzJZVwX7fC1I44d2hqnIWu7k4PHGHXcbvV3syR6cluqqMJxzJZVwX7fC1I44d2hgOqNJmvOykfpnemmwiO69wcBvxyHccYC8kBC(vw58ucYyvEoqMsHzLh5aTOCypdtr50ojDCHCEYhLJ82XZH5Te2QUCwOCEkzoEn)AfVxWvlIJpyFWEuODs64PHGHXcbvV3syR6cluqqMJxzJ5KtOgoUhqKK1G75F5A(n)kRC()g0hoHU8RSYHlI3kkh2RbWZ5VrKejA38Eb8KJ9ABrof78gaphgvxOCmGiNN2fkh54eihgCtSYZ5PgOq50xo3UGC8nhmkh2Je8Kd9Zcf75aTOC(p(g1gi)AfVxWvHAqF4WEzO2WuepatIGfJijseoGiuwGO9Eb88YuSem3ueWRXisIeTBEVGkbmmfjIEXKsfCdbN8RE4SO(bbcNViPN5gVJKY(IagWRaQGw1IeCpQSl7lcyaV(4nQnq(1kEVGRc1G(W5d2hNQluWaIGOlepnemz)YqTHPOAmIKir4aIqzbI27fe9IjLk4gco5x9Wzr9dceoFrspZRrLngleu9WnXkpimqHQSXrXyHGQNQluWaIGOlufrswdUNHA44EarswdUOiccrhUHPO8Rv8EbxfQb9HZhSpovxOGbebrxiEAiyVmuBykQgJijseoGiuwGO9Ebrl7QeRCq9WnXkpimqHQfCdbNUaeYkEVat9mh1FG3rXyHGQNQluWaIGOlufrswdUNl7QeRCq9ElHTQlSqbbzoEfrswdUOCRSRsSYb1d3eR8GWafQIit8okgleu9ElHTQlSqbbzoEfrswdUibJfcQE4MyLhegOqvejzn4EMJ6VCp)AfVxWvHAqF48b7JxgQnmfXdWKiy3JooGyJDweXZltXsWKSZjuWUZURbbejzn4IGRCYPSDtraVcA44(5M6bHQeWWuKiQBkc4vHHEeoCtSYReWWuKikgleu9WnXkpimqHQSXCY5ftkvWneCYV6HZI6heiC(IKIagVYZ)bsftOC(pnuBykkhOfLZFXg7SiQMdZJoohblQbWZ5hBNtOCI03z31GCwuocwudGNZtnqHYrE7458ud9ihdiYbS5WFdh3p3upiun)kRC(psuCoSX58xSXolIYPHYP9C6lhdBz9C8nheliNL1R5xR49cUkud6dNpyFGyJDweXtdbJBY(LHAdtr17rhhqSXolI4KZxgQnmfvzpkeJ6f1(7aADZ7fW9OUHGtE1Bjk4Bq0uKGijRbxe8AuebHOd3Wuu(1kEVGRc1G(W5d2hhvqKhCQGdAEbwk)kRC(XSkVfR7naEoUHGt(LJJBEoYBLkhv)IYbAr544uocwK59cYzHY5VyJDweLdIGq0HNJGf1a45eBabj1LA(1kEVGRc1G(W5d2hi2yNfr8uExuuWneCYpyCWtdbt2VmuBykQEp64aIn2zruuz)YqTHPOk7rHyuVO2FhqRBEVGOxmPub3qWj)QholQFqGW5lskcy)g1neCYRElrbFdIMIag34nFC7xEzzLW2q82a)4o3JIiieD4gMIYVYkN)IGq0HNZFXg7SikhYqQ350q50EoYBLkh6NXnIYrWIAa8CyElHTQRMZt3CCCZZbrqi6WZPHYHzFAoWj)YbrM4DonihhNYbq)0ZH3xn)AfVxWvHAqF48b7deBSZIiEAiyY(LHAdtr17rhhqSXolIIIijRb3ZLDvIvoOEVLWw1fwOGGmhVIijRbhFCW1OLDvIvoOEVLWw1fwOGGmhVIijRb3ZW4Du3qWjV6Tef8niAksqKK1GlIYUkXkhuV3syR6cluqqMJxrKK1GJpENFTI3l4QqnOpC(G9bMYkpcXRCbH4PHGj7xgQnmfvzpkeJ6f1(7aADZ7fe9IjLk4gco5xeW(x(1kEVGRc1G(W5d2h0R(keYCk)MFLvomozkhphUCxLyLdU8Rv8Ebx9CYuoEOio(G9Xld1gMI4byseSdxeCCeD4RsWZltXsWk7QeRCq9WnXkpimqHQfCdbNUaeYkEVatfbmoQ)aV55)aPIjuo)NgQnmfLFLvo)NgOp8CAOCKt5yikNIfh3a45SGCEQbkuofCdbNUAo8InK6Doye0IOCGA055imqHYPHYroLdU9IYbS5WFdh3p3upiuoySEop1qpYHb3eR8CAqolsqOC8nh4KNZFXg7Sikh24C4gyZ5hBNtOCI03z31aUxZVwX7fC1Zjt54HI44d2hVmqF480qW4MSFzO2Wuu9Wfbhhrh(QeCYPSDtraVcA44(5M6bHQeWWuKiQBkc4vHHEeoCtSYReWWuKG7rlRe2gI3g4xvqqDP9i4iQSrSacArWPQKHEewOGJtbj7CcfS7S7Aq(1kEVGREozkhpuehFW(iExvar3YIkepqlkaOF6W4Gh6NoYcM0YcCyrMR8837QYbAr5WGBIvUePe5Wxom4MyLFoQFq5Wcu0D5iNYXquog2Y654BofloNfKZtnqHYPGBi40vZHxeq9oh54eiN)VbIC4IK9aq3LtF5yylRNJV5Gyb5SSEn)AfVxWvpNmLJhkIJpyFC4MyLlrkbpnemcqi4VJawK5Aucqi4VRccQlThbmo4Auz)YqTHPO6HlcooIo8vjIwwjSneVnWVQGG6s7rWrubHXcbvHAGiiNSha6UkIKSgCpZr(vw5WL)DoooIo8vjUCGwuoeWjudGNddUjw558uduO8Rv8Ebx9CYuoEOio(G9Xld1gMI4byseSdxekRe2gI3g4hpVmflbRSsyBiEBGFvbb1L2Ja2V8HXcbvpCtSYdyktqxLno)AfVxWvpNmLJhkIJpyF8YqTHPiEaMeb7WfHYkHTH4Tb(XZltXsWkRe2gI3g4xvqqDP9iG9pEAiyL9fbmGxF8g1gi)AfVxWvpNmLJhkIJpyF8YqTHPiEaMeb7WfHYkHTH4Tb(XZltXsWkRe2gI3g4xvqqDP9NHXbpneSxgQnmfvzpkeJ6f1(7aADZ7fe9IjLk4gco5x9Wzr9dceoFrsralY5xzLZtnqHYrWIAa8CyElHTQlNfLJHTVOCCCeD4RsuZVwX7fC1Zjt54HI44d2hhUjw5bHbkepneSxgQnmfvpCrOSsyBiEBGFr52ld1gMIQhUi44i6WxLGtoXyHGQ3BjSvDHfkiiZXRisYAWfbmoQ)YjNxmPub3qWj)QholQFqGW5lskcyroAzxLyLdQ3BjSvDHfkiiZXRisYAWfbhCL75xzLZNSiqoisYAqdGNZtnqHUCWiOfr544uoqnCCphciUCAOCy2NMJ8f8hphmkhezI350GC8wIQ5xR49cU65KPC8qrC8b7Jd3eR8GWafINgc2ld1gMIQhUiuwjSneVnWVOqnCCpGijRb3ZLDvIvoOEVLWw1fwOGGmhVIijRbx(n)kRCyCYuoojY5Vw38Eb5xzLZtckhgNmLJ)Xld0hEogIYHnMNCypkhgCtSYph1pOC8nhmcqqTNdeALYXXPCIT76xuoylG9YXaIC()giYHls2daDhp5qViqonuoYPCmeLJ55iz)mhU8VZHBSafDxoSxdGNZp2oNq5ePVZURbCp)AfVxWvpNmLJtcyhUjw5NJ6hepnemUHXcbvpNmLJxzJ5KtmwiO6ld0hELnM7rLSZjuWUZURbbejzn4GX18RSY5)BqF45yEo)JVC4Y)oh5TJVSEopLjNpYjY8LJ82XZ5Pm5iVD8CyWzr9dcKJmlcyInhmwiOCyJZX3CSxBlY5wjkhU8VZrUDoLZ1oR59cUA(vw5ePv3MZzquo(Mdud6dphZZjY8Ldx(35iVD8COFAfx9oNiNJBi4KF1C4gJjr5yxolRFTGY5CYuoEL75xzLZ)3G(WZX8CImF5WL)DoYBhFz9CEkdp5WB(YrE7458ugEYXaIC41CK3oEopLjhdYjuo)NgOp88Rv8Ebx9CYuooj4d2hftPcwX7feu958amjcgud6dNNgcggleu9Wzr9dce8fbmXwzJJwwjSneVnWVQGG6s7pd7xo58IjLk4gco5x9Wzr9dceoFrsWIC0YkHTH4Tb(fbSiZjNLvcBdXBd8RkiOU0(ZW4is4MBkc4vbrXekCoYCdojvjGHPirumwiO6ld0hELnM75xR49cU65KPCCsWhSpo8(fpnem3ueWRGgoUFUPEqOkbmmfjIIybe0IGtvVbVd((ZUeWuMGIEXKsfCdbN8RE4SO(bbcNViPN5D(vw58KJZX3C(xoUHGt(Ld3aBoXOE5Eopikoh24C()giYHls2daDxoyVZP8UOAa8CyWnXk)Cu)GQ5xR49cU65KPCCsWhSpoCtSYph1piEkVlkk4gco5hmo4PHGj7xgQnmfvzpkeJ6f1(7aADZ7fevqySqqvOgicYj7bGURIijRb3ZCe9IjLk4gco5x9Wzr9dceoFrspd7FrDdbN8Q3suW3GOPibrswdUi418RSY5)xuoXOErT)oh06M3lGNCypkhgCtSYph1pOC2xekhgFrs5iVD8C4I)4Cm4wdoph24C8nNiNJBi4KF5SOCAOC(FUyo9LdIfaAa8CwiOC42cYXaVZXKwwGNZcLJBi4KFCp)AfVxWvpNmLJtc(G9XHBIv(5O(bXtdb7LHAdtrv2JcXOErT)oGw38Ebr5MGWyHGQqnqeKt2daDxfrswdUN5GtoDtraVkNS4fizNtOkbmmfjIEXKsfCdbN8RE4SO(bbcNViPNHfzUNFTI3l4QNtMYXjbFW(4Wzr9dceoFrs80qWUysPcUHGt(fbS)Xh3WyHGQoofqR7eOYgZjNiwabTi4u1EygQVWTSQaeYGlrapAzbc22RcIIjuqyWHtORImWJiG9dCpk3WyHGQ3BjSvDHfkiiZXdgRVfu7v2yo5u2ySqq1yejrI2nVxqLnMtoVysPcUHGt(fbmEZ98RSYHb3eR8Zr9dkhFZbrqi6WZ5)BGihUizpa0D5yaro(MdboweLJCkNIbYPyi07C2xekhlhiwLkN)NlMtd8nhhNYbq)0ZHzFAonuoX7DnMIQ5xR49cU65KPCCsWhSpoCtSYph1piEAiyccJfcQc1arqozpa0Dvejzn4EgghCYzzxLyLdQ3BjSvDHfkiiZXRisYAW9mh)OOccJfcQc1arqozpa0Dvejzn4EUSRsSYb17Te2QUWcfeK54vejzn4YVwX7fC1Zjt54KGpyFaxTReMYeepnemmwiOAmHGwK5Ki8IAWvp3kpIagVJwwGGT9AmHGwK5Ki8IAWvrg4reW44F5xR49cU65KPCCsWhSpoCtSYph1pO8Rv8Ebx9CYuooj4d2hfCYIdh(680qWKTBi4Kx7lGT3fTSsyBiEBGFvbb1L2JaghrXyHGQh(6HgeCCkim0JkBCucqi4VRElrbFdrMRraViQs2p1U21A]] )
    
end
