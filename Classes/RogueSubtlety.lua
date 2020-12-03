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
        --[[ shadow_techniques = {
            last = function () return state.query_time end,
            interval = function () return state.time_to_sht[5] end,
            value = 8,
            stop = function () return state.time_to_sht[5] == 0 or state.time_to_sht[5] == 3600 end,
        }, ]]
    } )

    spec:RegisterResource( Enum.PowerType.ComboPoints, {
        --[[ shadow_techniques = {
            last = function () return state.query_time end,
            interval = function () return state.time_to_sht[5] end,
            value = 1,
            stop = function () return state.time_to_sht[5] == 0 or state.time_to_sht[5] == 3600 end,
        }, ]]

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
            duration = function () return talent.subterfuge.enabled and 6 or 5 end,
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

        mark_of_the_master_assassin = {
            id = 318587,
            duration = 3600,
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


    spec:RegisterStateTable( "stealthed", setmetatable( {}, {
        __index = function( t, k )
            if k == "rogue" then
                return buff.stealth.up or buff.vanish.up or buff.shadow_dance.up or buff.subterfuge.up or buff.sepsis_buff.up
            elseif k == "rogue_remains" then
                return max( buff.stealth.remains, buff.vanish.remains, buff.shadow_dance.remains, buff.subterfuge.remains, buff.sepsis_buff.remains )

            elseif k == "mantle" then
                return buff.stealth.up or buff.vanish.up
            elseif k == "mantle_remains" then
                return max( buff.stealth.remains, buff.vanish.remains )
            
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

            cooldown.shadow_dance.expires = max( 0, cooldown.shadow_dance.remains - ( amt * ( talent.enveloping_shadows.enabled and 1.5 or 1 ) ) )
        end
    end

    spec:RegisterHook( "spend", comboSpender )
    -- spec:RegisterHook( "spendResources", comboSpender )


    spec:RegisterStateExpr( "mantle_duration", function ()
        return 0

        --[[ if stealthed.mantle then return cooldown.global_cooldown.remains + 5
        elseif buff.master_assassins_initiative.up then return buff.master_assassins_initiative.remains end
        return 0 ]]
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
                applyBuff( "mark_of_the_master_assassin", 4 )
            end

            if buff.stealth.up then 
                setCooldown( "stealth", 2 )
            end
            removeBuff( "stealth" )
            removeBuff( "vanish" )
            removeBuff( "shadowmeld" )
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
                return stealthed.all or buff.subterfuge.up, "not stealthed"
            end,

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
            charges = 2,
            cooldown = 60,
            recharge = 60,
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
                return not ( boss and group )
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

        potion = "potion_of_unbridled_fury",

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


    spec:RegisterPack( "Subtlety", 20201201, [[de1tSbqiskEejvTjj0NaL0OqPYPqP0QqvP6vOknluf3sfk2LK(LkOHbk1XqjwMkjptLunnsQCnuvSnuvY3qPQACOuOZHsbwhkvL5PcCpvQ9rs8pukiCqskLfQc5HKuYevHQlIsvOnIsr(iQkfJufkHtQcLALQeVeLcsZuLu4MOQuANKK(jkfudfLIAPQKspfktfvvxvLu0wrPk4ROuLgljLQZIsbr7LO)kyWQ6Wuwmu9yHMmHlJSzq(mOA0O40sTAvOe9AvKztQBtIDd8BfdxIookvrlhYZvA6uDDuz7GIVlbJhuIZRIA9QqjnFus7x0swK8lXeMtsvVc2xbBwUc2SuzrDW(68HfjMFUKKyLw8KbNKyatHKyyC4UM8ZsSs7SEmHKFj2oCOijXyCVCzFhEi82z4WRXr5WTv40M3diImi)WTvIhkXW5ATFSbsCjMWCsQ6vW(kyZYvWMLklQd2xNpsmJZzgKedRvuljgtleeqIlXe0gLyQpFmoCxt(58V2bohLxuF(hNIKcoHYNfEY)kyFfSLy6E9vYVeBDY0odjK8lvLfj)smcy4AsipsIfrTtO2KySlFCoiO66KPDMkxz(SYA(4CqqvymqVmvUY8zReZIEpaj2YyIPW6O(ejDPQxj5xIradxtc5rsSiQDc1MedNdcQUmCO(ebc(GaMyQCL5xm)4OGpHYPb(wfeuhBp)dUZ)kjMf9EasSOP1bl69ac6EDjMUxpamfsIb1GEzKUu1Rl5xIradxtc5rsSiQDc1MeBljTo4gco5BDz4q9jcewFqk5FNV6YVy(XrbFcLtd8nFvUZxDsml69aKyrtRdw07be096smDVEaykKedQb9YiDPQQtYVeJagUMeYJKyru7eQnjwCuWNq50aFRccQJTN)b35Zs(ht(SlF30eWRcIkjuyDK5gCsPsadxtI8lMpoheufgd0ltLRmF2kXSO3dqIfnToyrVhqq3RlX096bGPqsmOg0lJ0LQYhj)smcy4AsipsIfrTtO2KyUPjGxbnCgFDtFIqvcy4AsKFX8rCacAqWPQ3GZbFGLogW1MGQeWW1Ki)I5VLKwhCdbN8TUmCO(ebcRpiL8piF(iXSO3dqITmnmsxQkFj5xIradxtc5rsml69aKylJjMcRJ6tKelIANqTjXeeoheufQbIqbYobODRisXAWM)b5Zs(fZFljTo4gco5BDz4q9jcewFqk5FWD(xp)I57gco5vVvOGpbrt5Fm5JifRbB(QKpFjXINJAk4gco5RuvwKUuv2VKFjgbmCnjKhjXIO2juBsmymuB4AQYTuOe1dQ9Zb04M3di)I5ZU8feoheufQbIqbYobODRisXAWM)b5Zs(SYA(UPjGxlqw5auS1juLagUMe5xm)TK06GBi4KV1LHd1Niqy9bPK)b35RU8zReZIEpaj2YyIPW6O(ejDPQSrj)smcy4AsipsIfrTtO2KyBjP1b3qWjFZxL78VE(8Mp7YhNdcQ6muanUtGkxz(SYA(ioabni4u1ozgQ3WoC6aeYGRqaVsadxtI8lMFCacU2RcIkjuqyWHtOTImWP8v5oF2F(Sn)I5ZU8X5GGQ7zf8rVHbkiiZzcgNpru7vUY8zL18vt(4Cqq1sePqI2nVhqLRmFwzn)TK06GBi4KV5RYD(8jF2kXSO3dqITmCO(ebcRpifPlvLnqYVeJagUMeYJKyru7eQnjMGW5GGQqnqekq2jaTBfrkwd28p4oFwYNvwZpoJwmfa19Sc(O3WafeK5mvePynyZ)G8zHnMFX8feoheufQbIqbYobODRisXAWM)b5hNrlMcG6EwbF0ByGccYCMkIuSgSsml69aKylJjMcRJ6tK0LQYcSL8lXiGHRjH8ijwe1oHAtIHZbbvlje0GmNebyOgS11T4P8v5oF(KFX8JdqW1ETKqqdYCseGHAWwrg4u(QCNplxxIzrVhGedUEgfCTjiPlvLfwK8lXSO3dqITmMykSoQprsmcy4Asips6sxIr7sGiTs(LQYIKFjgbmCnjKhjXIO2juBsmcqi4NRERqbFckgSKVk5Zs(fZxn5JZbbv3Zk4JEdduqqMZu5kZVy(SlF1KVy8ACarc4iZjrasBkuaNdbQEhp1a45xmF1KVf9Ea14aIeWrMtIaK2uOAdcq6goJNpRSMpeNwhquKXqWPG3ku(hKp8OOQyWs(SvIzrVhGeloGibCK5KiaPnfs6svVsYVeJagUMeYJKyru7eQnjMAYpoJwmfa1LXetHaU2e0w5kZVy(Xz0IPaOUNvWh9ggOGGmNPYvMpRSMpudNXdisXAWM)b35ZcSLyw07biXW1ZicduWzOabiLZsxQ61L8lXSO3dqIbNZqI2aHbkyhReACgjgbmCnjKhjDPQQtYVeJagUMeYJKyru7eQnjg7YFljTo4gco5BDz4q9jcewFqk5RYD(xLpRSMpYArGGHaE1eIT2G8vjF(c25Z28lMVAYpoJwmfa19Sc(O3WafeK5mvUY8lMVAYhNdcQUNvWh9ggOGGmNPYvMFX8jaHGFUkiOo2E(QCN)1HTeZIEpajg0e5wseSJvc1ofWjtr6sv5JKFjgbmCnjKhjXIO2juBsSTK06GBi4KV1LHd1Niqy9bPKVk35Fv(SYA(iRfbcgc4vti2AdYxL85lylXSO3dqIvYHAOZnaEaxBRlDPQ8LKFjgbmCnjKhjXIO2juBsmCoiOkIIN00UbObfPkxz(SYA(4CqqvefpPPDdqdksH4WbCcvx3INY)G8zb2sml69aKyodf4a4dhqeGguKKUuv2VKFjMf9EasmuxwQPqdcBPfjjgbmCnjKhjDPQSrj)smcy4AsipsIfrTtO2KyXz0IPaOUNvWh9ggOGGmNPIifRbB(hKpFYNvwZhQHZ4bePynyZ)G8zHnkXSO3dqIvyqAbmudciAhGbIK0LQYgi5xIradxtc5rsSiQDc1MeJaec(58piF1b78lMpoheuDpRGp6nmqbbzotLRuIzrVhGetHug05Waf0CXweeiYuwPlvLfyl5xIradxtc5rsSiQDc1MedQHZ4bePynyZ)G8zPYN8zL18zx(SlF3qWjVYqM2zQLrpFvYNnc78zL18DdbN8kdzANPwg98p4o)RGD(Sn)I5ZU8TO3WqbcqknT5FNpl5ZkR5d1Wz8aIuSgS5Rs(xXgKpBZNT5ZkR5ZU8DdbN8Q3kuWNqz0dxb78vj)Rd78lMp7Y3IEddfiaP00M)D(SKpRSMpudNXdisXAWMVk5Ro1LpBZNTsml69aKyiYkBa8aK2uOv6sxIjiiJt7s(LQYIKFjMf9EasStD8KeJagUMeYJKUu1RK8lXiGHRjH8ij2ukXwYLyw07biXGXqTHRjjgmMMJKy4Cqq1v3rkyarq0rQYvMpRSM)wsADWneCY36YWH6teiS(GuYxL785ljgmgkamfsITarioar79aKUu1Rl5xIradxtc5rsml69aKyrtRdw07be096smDVEaykKelkwPlvvDs(LyeWW1KqEKelIANqTjXwNmTZqIQP1sml69aKyioqWIEpGGUxxIP71datHKyRtM2ziH0LQYhj)smcy4AsipsIfrTtO2KyBjP1b3qWjFRldhQprGW6dsj)dYNVYVy(qnCgpGifRbB(QKpFLFX8X5GGQRUJuWaIGOJufrkwd28piF4rrvXGL8lMFCuWNq50aFZxL78vx(ht(SlFVvO8piFwGD(SnF(E(xjXSO3dqIT6osbdicIossxQkFj5xIradxtc5rsSPuITKlXSO3dqIbJHAdxtsmymnhjXkr9GA)CanU59aYVy(BjP1b3qWjFRldhQprGW6dsjFvUZ)kjgmgkamfsIXTuOe1dQ9Zb04M3dq6svz)s(LyeWW1KqEKelIANqTjXGXqTHRPk3sHsupO2phqJBEpajMf9EasSOP1bl69ac6EDjMUxpamfsITozANjefR0LQYgL8lXiGHRjH8ij2ukXwYLyw07biXGXqTHRjjgmMMJKyxXN85nF30eWRW0WhuLagUMe5Z3Z)kyNpV57MMaEvXwNqHbkSmMykSvcy4AsKpFp)RGD(8MVBAc41LXetHa0e52kbmCnjYNVN)v8jFEZ3nnb8QPTiQ9Zvcy4AsKpFp)RGD(8M)v8jF(E(Sl)TK06GBi4KV1LHd1Niqy9bPKVk35RU8zRedgdfaMcjXwNmTZeCgeTmJwiDPQSbs(LyeWW1KqEKelIANqTjXiaHGFUkiOo2E(hCNpmgQnCnvxNmTZeCgeTmJwiXSO3dqIfnToyrVhqq3RlX096bGPqsS1jt7mHOyLUuvwGTKFjgbmCnjKhjXIO2juBsS4OGpHYPb(M)D(gOvSiJHGtIqSuIzrVhGelAADWIEpGGUxxIP71datHKyqnOxgPlvLfwK8lXiGHRjH8ijwe1oHAtIfhf8juonW3QGG6y75FWD(SKpRSMpudNXdisXAWM)b35Zs(fZpok4tOCAGV5RYD(xpFwznFCoiO6EwbF0ByGccYCMGX5te1ELRm)I5hhf8juonW38v5oF1jXSO3dqIfnToyrVhqq3RlX096bGPqsmOg0lJ0LQYYvs(LyeWW1KqEKelIANqTjX2ssRdUHGt(wxgouFIaH1hKs(QCNV6YVy(XrbFcLtd8nFvUZxDsml69aKyrtRdw07be096smDVEaykKedQb9YiDPQSCDj)smcy4AsipsIfrTtO2KyeGqWpxfeuhBp)dUZhgd1gUMQRtM2zcodIwMrlKyw07biXIMwhSO3diO71Ly6E9aWuijgoxRfsxQklQtYVeJagUMeYJKyru7eQnjgbie8Zvbb1X2ZxL78zHp5ZB(eGqWpxreCciXSO3dqIzOObOGpiebCPlvLf(i5xIzrVhGeZqrdqHso9ssmcy4Asips6svzHVK8lXSO3dqIPB4m(gowYjGRqaxIradxtc5rsxQklSFj)sml69aKy4g8WafCuhpTsmcy4Asips6sxIvIO4OGBUKFPQSi5xIzrVhGeZkl1NdLtVdqIradxtc5rsxQ6vs(Lyw07biXwNmTZiXiGHRjH8iPlv96s(LyeWW1KqEKeZIEpajMIHorIa0GccYCgjwjIIJcU5HLIdqSsmw4J0LQQoj)smcy4AsipsIzrVhGeB1DKcgqeeDKKyru7eQnjgIGq0Yy4AsIvIO4OGBEyP4aeReJfPlvLps(LyeWW1KqEKelIANqTjXqCacAqWPQIHofgOGZqbfBDcfSDTDBqLagUMesml69aKylJjMcbCTjOv6sxIb1GEzK8lvLfj)smcy4AsipsInLsSLCjMf9EasmymuB4AsIbJP5ijMBAc41sePqI2nVhqLagUMe5xm)TK06GBi4KV5Fq(SlF(K)XKFCGHagWRakIg9Ge5Z28lMVAYpoWqad41tNrTbKyWyOaWuijwjIuirybIqCaI27biDPQxj5xIradxtc5rsSiQDc1Metn5dJHAdxt1sePqIWceH4aeT3di)I5VLKwhCdbN8TUmCO(ebcRpiL8piF(k)I5RM8X5GGQlJjMcbHbIuLRm)I5JZbbvxDhPGbebrhPkIuSgS5Fq(qnCgpGifRbB(fZhrqiAzmCnjXSO3dqIT6osbdicIossxQ61L8lXiGHRjH8ijwe1oHAtIbJHAdxt1sePqIWceH4aeT3di)I5hNrlMcG6YyIPqqyGivJmgcoTbiKf9EaMo)dYNLk7Np5xmFCoiO6Q7ifmGii6ivrKI1Gn)dYpoJwmfa19Sc(O3WafeK5mvePynyZVy(Sl)4mAXuauxgtmfccdePkImX58lMpoheuDpRGp6nmqbbzotfrkwd28pM8X5GGQlJjMcbHbIufrkwd28piFwQxLpBLyw07biXwDhPGbebrhjPlvvDs(LyeWW1KqEKeBkLyl5sml69aKyWyO2W1KedgtZrsmfBDcfSDTDBqarkwd28vjFyNpRSMVAY3nnb8kOHZ4RB6teQsadxtI8lMVBAc4vHHofwgtmfQeWW1Ki)I5JZbbvxgtmfccdePkxz(SYA(BjP1b3qWjFRldhQprGW6dsjFvUZNVKyWyOaWuij2EQldiUsNdrsxQkFK8lXiGHRjH8ijwe1oHAtIPM8HXqTHRP6EQldiUsNdr5xmF3qWjV6Tcf8jiAk)JjFePynyZxL85R8lMpIGq0Yy4AsIzrVhGedXv6Cis6sv5lj)sml69aKylfrKhCkYaA2tosIradxtc5rsxQk7xYVeJagUMeYJKyw07biXqCLohIKyru7eQnjMAYhgd1gUMQ7PUmG4kDoeLFX8vt(WyO2W1uLBPqjQhu7NdOXnVhq(fZFljTo4gco5BDz4q9jcewFqk5RYD(xLFX8DdbN8Q3kuWNGOP8v5oF2LpFYN38zx(xLpFp)4OGpHYPb(MpBZNT5xmFebHOLXW1KelEoQPGBi4KVsvzr6svzJs(LyeWW1KqEKelIANqTjXut(WyO2W1uDp1LbexPZHO8lMpIuSgS5Fq(Xz0IPaOUNvWh9ggOGGmNPIifRbB(8MplWo)I5hNrlMcG6EwbF0ByGccYCMkIuSgS5FWD(8j)I57gco5vVvOGpbrt5Fm5JifRbB(QKFCgTykaQ7zf8rVHbkiiZzQisXAWMpV5ZhjMf9EasmexPZHiPlvLnqYVeJagUMeYJKyru7eQnjMAYhgd1gUMQClfkr9GA)CanU59aYVy(BjP1b3qWjFZxL78VUeZIEpajgU2INcLtbbHKUuvwGTKFjMf9EasmcMEJeYCsIradxtc5rsx6sSOyL8lvLfj)smcy4AsipsIfrTtO2KyQjFCoiO6YyIPqqyGiv5kZVy(4Cqq1LHd1NiqWheWetLRm)I5JZbbvxgouFIabFqatmvePynyZ)G78VELpsml69aKylJjMcbHbIKeJBPWabfGhfsvzr6svVsYVeJagUMeYJKyru7eQnjgoheuDz4q9jce8bbmXu5kZVy(4Cqq1LHd1NiqWheWetfrkwd28p4o)Rx5JeZIEpaj2EwbF0ByGccYCgjg3sHbckapkKQYI0LQEDj)smcy4AsipsIfrTtO2KyWyO2W1uDbIqCaI27bKFX8vt(RtM2zirvXaUMKyw07biXG0gCsRnVhG0LQQoj)smcy4AsipsIfrTtO2KyccNdcQcPn4KwBEpGkIuSgS5Fq(xjXSO3dqIbPn4KwBEpGqutgyjPlvLps(LyeWW1KqEKelIANqTjXyx(ioabni4uvXqNcduWzOGIToHc2U2UnOsadxtI8lMFCuWNq50aFRccQJTN)b35F98zL18rCacAqWPQGmNrFoSmMykSvcy4AsKFX8JJc(ekNg4B(hKpl5Z28lMpoheuDpRGp6nmqbbzotLRm)I5JZbbvxgtmfccdePkxz(fZxXwNqbBxB3geqKI1Gn)78HD(fZhNdcQkiZz0NdlJjMcBvmfasml69aKyWyGEzKUuv(sYVeJagUMeYJKyw07biXkNrhq0oCOijXIO2juBsm30eWRldhQprGGpiGjMkbmCnjYVy(QjF30eWRlJjMcbOjYTvcy4AsiXGguaqWIlvLfPlvL9l5xIradxtc5rsSiQDc1MeJaec(58v5oF(c25xmFymuB4AQUarioar79aYVy(Xz0IPaOUNvWh9ggOGGmNPYvMFX8JZOftbqDzmXuiimqKQrgdbN28v5oFwKyw07biXwgouFIabFqatmsxQkBuYVeJagUMeYJKyw07biXwcHmNeb8bqHTSprsSiQDc1Medgd1gUMQlqeIdq0EpG8lMVAYxmEDjeYCseWhaf2Y(efeJx9oEQbWZVy(UHGtE1Bfk4tq0u(QCN)vSKpRSMpudNXdisXAWM)b35ZN8lM)wsADWneCY36YWH6teiS(GuY)G8VUelEoQPGBi4KVsvzr6svzdK8lXiGHRjH8ijwe1oHAtIbJHAdxt1ficXbiAVhq(fZpok4tOCAGVvbb1X2ZxL78zrIzrVhGeBPYTxPlvLfyl5xIradxtc5rsSiQDc1Medgd1gUMQlqeIdq0EpG8lMp7Y3nnb8kbGH0tzdGhwgtmf2kbmCnjYNvwZpoJwmfa1LXetHGWarQgzmeCAZxL78zjF2MFX8zx(QjF30eWRldhQprGGpiGjMkbmCnjYNvwZ3nnb86YyIPqaAICBLagUMe5ZkR5hNrlMcG6YWH6tei4dcyIPIifRbB(QK)v5ZwjMf9EasS9Sc(O3WafeK5msxQklSi5xIradxtc5rsml69aKykg6ejcqdkiiZzKyru7eQnjgYArGGHaE1eITYvMFX8zx(UHGtE1Bfk4tq0u(hKFCuWNq50aFRccQJTNpRSMVAYFDY0odjQMwNFX8JJc(ekNg4BvqqDS98v5o)yzqXGLWwsar(SvIfph1uWneCYxPQSiDPQSCLKFjgbmCnjKhjXIO2juBsmK1Iabdb8QjeBTb5Rs(xh25Fm5JSweiyiGxnHyRcoK59aYVy(XrbFcLtd8TkiOo2E(QCNFSmOyWsyljGqIzrVhGetXqNiraAqbbzoJ0LQYY1L8lXiGHRjH8ijwe1oHAtIbJHAdxt1ficXbiAVhq(fZpok4tOCAGVvbb1X2ZxL78VsIzrVhGeBzmXuiGRnbTsxQklQtYVeJagUMeYJKyru7eQnjgmgQnCnvxGiehGO9Ea5xm)4OGpHYPb(wfeuhBpFvUZ)Q8lMp7Yhgd1gUMQClfkr9GA)CanU59aYNvwZFljTo4gco5BDz4q9jcewFqk5FWD(QlF2kXSO3dqIrrMPbWdiQe1kgqiDPQSWhj)smcy4AsipsIfrTtO2KyUPjGxxgtmfcqtKBReWW1Ki)I5dJHAdxt1ficXbiAVhq(fZhNdcQUNvWh9ggOGGmNPYvkXSO3dqITmCO(ebc(GaMyKUuvw4lj)smcy4AsipsIfrTtO2KyQjFCoiO6YyIPqqyGiv5kZVy(qnCgpGifRbB(hCNpBmFEZ3nnb86YH7ecIdovjGHRjHeZIEpaj2YyIPqqyGijDPQSW(L8lXSO3dqIvoEpajgbmCnjKhjDPQSWgL8lXiGHRjH8ijwe1oHAtIHZbbv3Zk4JEdduqqMZu5kLyw07biXW1ZicqCOZsxQklSbs(LyeWW1KqEKelIANqTjXW5GGQ7zf8rVHbkiiZzQCLsml69aKy4eAj0Pgax6svVc2s(LyeWW1KqEKelIANqTjXW5GGQ7zf8rVHbkiiZzQCLsml69aKyqnIW1ZiKUu1RyrYVeJagUMeYJKyru7eQnjgoheuDpRGp6nmqbbzotLRuIzrVhGeZarADKPdrtRLUu1RUsYVeJagUMeYJKyru7eQnjgoheuDpRGp6nmqbbzotLRmFwznFOgoJhqKI1Gn)dY)kylXSO3dqIXTuODszLU0LyRtM2zcrXk5xQkls(LyeWW1KqEKeBkLyl5sml69aKyWyO2W1KedgtZrsS4mAXuauxgtmfccdePAKXqWPnaHSO3dW05RYD(Suz)8rIbJHcatHKylJi4miAzgTq6svVsYVeJagUMeYJKyru7eQnjg7Yxn5dJHAdxt1LreCgeTmJwKpRSMVAY3nnb8kOHZ4RB6teQsadxtI8lMVBAc4vHHofwgtmfQeWW1KiF2MFX8JJc(ekNg4BvqqDS98vjFwYVy(QjFehGGgeCQQyOtHbk4muqXwNqbBxB3gujGHRjHeZIEpajgmgOxgPlv96s(LyeWW1KqEKeZIEpajw5m6aI2HdfjjgbloYcMYWbCjM6GTedAqbablUuvwKUuv1j5xIradxtc5rsSiQDc1MeJaec(58v5oF1b78lMpbie8Zvbb1X2ZxL78zb25xmF1KpmgQnCnvxgrWzq0YmAr(fZpok4tOCAGVvbb1X2ZxL8zj)I5liCoiOkudeHcKDcq7wrKI1Gn)dYNfjMf9EasSLXetbfslKUuv(i5xIradxtc5rsSPuITKlXSO3dqIbJHAdxtsmymnhjXIJc(ekNg4BvqqDS98v5o)RYN38X5GGQlJjMcbCTjOTYvkXGXqbGPqsSLreIJc(ekNg4R0LQYxs(LyeWW1KqEKeBkLyl5sml69aKyWyO2W1KedgtZrsS4OGpHYPb(wfeuhBpFvUZ)6sSiQDc1MeloWqad41tNrTbKyWyOaWuij2YicXrbFcLtd8v6svz)s(LyeWW1KqEKeBkLyl5sml69aKyWyO2W1KedgtZrsS4OGpHYPb(wfeuhBp)dUZNfjwe1oHAtIbJHAdxtvULcLOEqTFoGg38Ea5xm)TK06GBi4KV1LHd1Niqy9bPKVk35RojgmgkamfsITmIqCuWNq50aFLUuv2OKFjgbmCnjKhjXIO2juBsmymuB4AQUmIqCuWNq50aFZVy(SlFymuB4AQUmIGZGOLz0I8zL18X5GGQ7zf8rVHbkiiZzQisXAWMVk35Zs9Q8zL183ssRdUHGt(wxgouFIaH1hKs(QCNV6YVy(Xz0IPaOUNvWh9ggOGGmNPIifRbB(QKplWoF2kXSO3dqITmMykeegissxQkBGKFjgbmCnjKhjXIO2juBsmymuB4AQUmIqCuWNq50aFZVy(qnCgpGifRbB(hKFCgTykaQ7zf8rVHbkiiZzQisXAWkXSO3dqITmMykeegissx6smCUwlK8lvLfj)smcy4AsipsIfrTtO2KyQjF30eWRGgoJVUPprOkbmCnjYVy(ioabni4u1BW5GpWshd4Atqvcy4AsKFX83ssRdUHGt(wxgouFIaH1hKs(hKpFKyw07biXwMggPlv9kj)smcy4AsipsIfrTtO2KyBjP1b3qWjFZxL78VsIzrVhGeBz4q9jcewFqksxQ61L8lXiGHRjH8ijwe1oHAtIfNrlMcG6siK5KiGpakSL9jQgzmeCAdqil69amD(QCN)vv2pFYNvwZFhonEdevnzIa(5ablMsPMQeWW1Ki)I5RM8X5GGQAYeb8ZbcwmLsnv5kLyw07biXwcHmNeb8bqHTSprsxQQ6K8lXSO3dqIbxpJcU2eKeJagUMeYJKUuv(i5xIzrVhGed3INw3WLyeWW1KqEK0LU0LyWqOThGu1RG9vWMfwUInqIvWqGgaFLySx121Q6Xwv(g2x(5ZpdLFRuoipFObLpSUozANHeWA(iI9KRrKi)DuO8noFumNe5hzmaCAR5LRrdO85d7lF1AaWqiNe5dRioabni4uvTdR57t(WkIdqqdcovv7vcy4AsaR5ZowGf2wZlxJgq5ZgzF5Rwdagc5KiFyfXbiObbNQQDynFFYhwrCacAqWPQAVsadxtcynF2XcSW2AEHFgkFOrRNcnaE(ghY28lqikFULe53G8DgkFl69aYx3RNpoNNFbcr5dgpFOHdiYVb57mu(MqmG8fMB42sSV8s(ht(7zf8rVHbkiiZzcgNpru75L8c7vTDTQESvLVH9LF(8Zq53kLdYZhAq5dRccY40oSMpIyp5AejYFhfkFJZhfZjr(rgdaN2AEHFgkFOrRNcnaE(ghY28lqikFULe53G8DgkFl69aYx3RNpoNNFbcr5dgpFOHdiYVb57mu(MqmG8fMB42sSV8s(ht(7zf8rVHbkiiZzcgNpru75L8c7vTDTQESvLVH9LF(8Zq53kLdYZhAq5dRLikok4MdR5Ji2tUgrI83rHY348rXCsKFKXaWPTMxUgnGYNpSV8vRbadHCsKpSI4ae0GGtv1oSMVp5dRioabni4uvTxjGHRjbSMV55ZEKn81iF2XcSW2AEjVWEvBxRQhBv5ByF5Np)mu(Ts5G88Hgu(WkoxRfWA(iI9KRrKi)DuO8noFumNe5hzmaCAR5LRrdO8zH9LVAnayiKtI8HvehGGgeCQQ2H189jFyfXbiObbNQQ9kbmCnjG18zhlWcBR5L8c7vTDTQESvLVH9LF(8Zq53kLdYZhAq5dRrXcR5Ji2tUgrI83rHY348rXCsKFKXaWPTMxUgnGYNpSV8vRbadHCsKpSI4ae0GGtv1oSMVp5dRioabni4uvTxjGHRjbSMp7UcwyBnVKxyVQTRv1JTQ8nSV8ZNFgk)wPCqE(qdkFyDDY0otikwynFeXEY1isK)oku(gNpkMtI8JmgaoT18Y1Obu(xX(YxTgameYjr(WkIdqqdcovv7WA((KpSI4ae0GGtv1ELagUMeWA(MNp7r2WxJ8zhlWcBR5L8YXwPCqojYNnMVf9Ea5R713AErIvIgOwtsm1NpghURj)C(x7aNJYlQp)JtrsbNq5Zcp5FfSVc25L8I6ZNnJOJrTgfCZZlw07bS1sefhfCZ59(qRSuFouo9oG8If9EaBTerXrb3CEVpCDY0otEXIEpGTwIO4OGBoV3hQyOtKianOGGmNHNsefhfCZdlfhGyVzHp5fl69a2AjIIJcU58EF4Q7ifmGii6iXtjIIJcU5HLIdqS3SWtdDJiieTmgUMYlw07bS1sefhfCZ59(WLXetHaU2e0YtdDJ4ae0GGtvfdDkmqbNHck26eky7A72G8sEr95Z3Ani)RDCZ7bKxSO3dyVp1Xt5f1N)1Cjr((KVGCcP0ak)cmKZqO8JZOftbWMFbR98Hgu(yGJNpUTKi)bKVBi4KV18If9EalV3hcJHAdxt8amf6EbIqCaI27bWdmMMJUX5GGQRUJuWaIGOJuLRKvw3ssRdUHGt(wxgouFIaH1hKIk38vEr95Rwmu8u(Q1X38npFOgTEEXIEpGL37dJMwhSO3diO715byk0DuS5f1N)1YbYhItRpN)wO9idT57t(odLpMtM2zir(x74M3diF2HFoFX0a45VdpTNp0GI0MF5m6gap)gkFW4mnaE(9MVbJ1AdxtSTMxSO3dy59(qehiyrVhqq3RZdWuO71jt7mKGNg6EDY0odjQMwNxuF(QTYs958xDhPGbebrhP8np)R4nF1InNVGd1a457mu(qnA98zb25VuCaILhdYju(oJ55RoEZxTyZ53q53E(eSu2iAZVq7mniFNHYhqWINpFJAD88hu(9Mpy885kZlw07bS8EF4Q7ifmGii6iXtdDVLKwhCdbN8TUmCO(ebcRpiLd4RIqnCgpGifRbRk8vrCoiO6Q7ifmGii6ivrKI1G9a4rrvXGLIXrbFcLtd8vLB1DmSZBf6awGnB57xLxuF(SHb6Z5hzmaCkF04M3di)gk)cu(mgmu(LOEqTFoGg38Ea5VKNVbe5RWP9Uut57gco5B(CL18If9EalV3hcJHAdxt8amf6MBPqjQhu7NdOXnVhapWyAo6Ue1dQ9Zb04M3dO4wsADWneCY36YWH6teiS(Guu5(Q8I6ZNnJ6b1(58V2XnVhaBiY)AqoSU5dVHHY3YpISY8n8HZZNaec(58Hgu(odL)6KPDM8vRJV5ZoCUwliu(R3AD(iAlPONF7STMpBi5k5P98JgiFCkFNX883wPut18If9EalV3hgnToyrVhqq3RZdWuO71jt7mHOy5PHUHXqTHRPk3sHsupO2phqJBEpG8I6Z)AUKiFFYxqqnGYVadbY3N85wk)1jt7m5RwhFZFq5JZ1AbH28If9EalV3hcJHAdxt8amf6EDY0otWzq0YmAbpWyAo6(k(WRBAc4vyA4dQsadxtc((vWMx30eWRk26ekmqHLXetHTsadxtc((vWMx30eWRlJjMcbOjYTvcy4AsW3VIp86MMaE10we1(5kbmCnj47xbBEVIp8D2TLKwhCdbN8TUmCO(ebcRpifvUvhBZlQpF1AaBliu(CBdGNVLpMtM2zYxToE(fyiq(iYImnaE(odLpbie8Z57miAzgTiVyrVhWY79HrtRdw07be0968amf6EDY0otikwEAOBcqi4NRccQJTFWnmgQnCnvxNmTZeCgeTmJwKxSO3dy59(WOP1bl69ac6EDEaMcDd1GEz4PHUJJc(ekNg47TbAflYyi4KielZlQpF2ud6LjFZZxD8MFH2zgop)JJL)GYVq7m5Jnhp)iQ98X5GG4jF(WB(fANj)JJLp7goFBbL)6KPDg2MxSO3dy59(WOP1bl69ac6EDEaMcDd1GEz4PHUJJc(ekNg4BvqqDS9dUzHvwHA4mEarkwd2dUzPyCuWNq50aFv5(6SYkoheuDpRGp6nmqbbzotW48jIAVYvwmok4tOCAGVQCRU8I6ZN92ot(hhlFtVt(qnOxM8npF1XB(gCRbRNV6Y3neCY38z3W5BlO8xNmTZW28If9EalV3hgnToyrVhqq3RZdWuOBOg0ldpn09wsADWneCY36YWH6teiS(Guu5wDfJJc(ekNg4Rk3QlVO(8VMlLVLpoxRfek)cmeiFezrMgapFNHYNaec(58DgeTmJwKxSO3dy59(WOP1bl69ac6EDEaMcDJZ1Abpn0nbie8Zvbb1X2p4ggd1gUMQRtM2zcodIwMrlYlQp)RXuGwp)supO2pNFdY3068hO8DgkF1gB(AKpofnULYV98Jg3sB(w(8nQ1XZlw07bS8EFOHIgGc(GqeW5PHUjaHGFUkiOo2Uk3SWhEjaHGFUIi4eiVyrVhWY79HgkAakuYPxkVyrVhWY79H6goJVHJLCc4keWZlw07bS8EFiUbpmqbh1XtBEjVO(8vRz0IPayZlQp)R5s5FCdeP8hiOJbEuKpobnikFNHYhQrRN)YWH6teiS(GuYhcnk5Z)GaMyYpok0MFdQ5fl69a2AuS8EF4YyIPqqyGiXd3sHbckapkUzHNg6wn4Cqq1LXetHGWarQYvweNdcQUmCO(ebc(GaMyQCLfX5GGQldhQprGGpiGjMkIuSgShCF9kFYlQpF2DnbAA38nnImX585kZhNIg3s5xGY3N5u(ymMykKpBAIClBZNBP8XoRGp6n)bc6yGhf5JtqdIY3zO8HA065VmCO(ebcRpiL8HqJs(8piGjM8JJcT53GAEXIEpGTgflV3hUNvWh9ggOGGmNHhULcdeuaEuCZcpn0noheuDz4q9jce8bbmXu5klIZbbvxgouFIabFqatmvePynyp4(6v(KxSO3dyRrXY79HqAdoP1M3dGNg6ggd1gUMQlqeIdq0EpGIQzDY0odjQkgW1uEXIEpGTgflV3hcPn4KwBEpGqutgyjEAOBbHZbbvH0gCsRnVhqfrkwd2dUkVyrVhWwJIL37dHXa9YWtdDZoehGGgeCQQyOtHbk4muqXwNqbBxB3gumok4tOCAGVvbb1X2p4(6SYkIdqqdcovfK5m6ZHLXetHTyCuWNq50aFpGf2weNdcQUNvWh9ggOGGmNPYvweNdcQUmMykeegisvUYIk26eky7A72GaIuSgS3WUioheuvqMZOphwgtmf2QykaYlQpF28m68Hgu(8piGjM8lr0XGnhp)cTZKpgZXZhrM4C(fyiq(GXZhXbanaE(ySPAEXIEpGTgflV3hwoJoGOD4qrIhObfaeS43SWtdD7MMaEDz4q9jce8bbmXujGHRjrr14MMaEDzmXuianrUTsadxtI8I6Z)AUu(8piGjM8lru(yZXZVadbYVaLpJbdLVZq5tacb)C(fyiNHq5dHgL8lNr3a45xODMHZZhJnL)GY)yj365dNaeY06Z18If9EaBnkwEVpCz4q9jce8bbmXWtdDtacb)Sk38fSlcJHAdxt1ficXbiAVhqX4mAXuau3Zk4JEdduqqMZu5klgNrlMcG6YyIPqqyGivJmgcoTQCZsEXIEpGTgflV3hUeczojc4dGcBzFI4jEoQPGBi4KV3SWtdDdJHAdxt1ficXbiAVhqr1igVUeczojc4dGcBzFIcIXREhp1a4fDdbN8Q3kuWNGOjvUVIfwzfQHZ4bePynyp4Mpf3ssRdUHGt(wxgouFIaH1hKYbxpVyrVhWwJIL37dxQC7LNg6ggd1gUMQlqeIdq0EpGIXrbFcLtd8TkiOo2Uk3SKxuF(xZLYh7Sc(O38hq(Xz0IPaiF2zqoHYhQrRNpg44SnFoGM2n)cu(gIYh(0a457t(Ltz(8piGjM8nGiFXKpy88zmyO8XymXuiF20e52AEXIEpGTgflV3hUNvWh9ggOGGmNHNg6ggd1gUMQlqeIdq0EpGISZnnb8kbGH0tzdGhwgtmf2kbmCnjyL14mAXuauxgtmfccdePAKXqWPvLBwyBr2Pg30eWRldhQprGGpiGjMkbmCnjyLv30eWRlJjMcbOjYTvcy4AsWkRXz0IPaOUmCO(ebc(GaMyQisXAWQYvSnVO(8p2q5BcXMVHO85k5j)f0Lu(odL)aO8l0ot(6PaTE(8Z)XR5Fnxk)cmeiFX5gapFiBDcLVZyG8vl2C(ccQJTN)GYhmE(RtM2zir(fANz488nW58vl2CnVyrVhWwJIL37dvm0jseGguqqMZWt8Cutb3qWjFVzHNg6gzTiqWqaVAcXw5klYo3qWjV6Tcf8jiA6G4OGpHYPb(wfeuhBNvwvZ6KPDgsunTUyCuWNq50aFRccQJTRYDSmOyWsyljGGT5f1N)XgkFWKVjeB(fAToFrt5xODMgKVZq5diyXZ)6WE5jFULYNVf645pG8XNDZVq7mdNNVboNVAXMR5fl69a2AuS8EFOIHorIa0GccYCgEAOBK1Iabdb8QjeBTbQCDyFmiRfbcgc4vti2QGdzEpGIXrbFcLtd8TkiOo2Uk3XYGIblHTKaI8If9EaBnkwEVpCzmXuiGRnbT80q3WyO2W1uDbIqCaI27bumok4tOCAGVvbb1X2v5(Q8If9EaBnkwEVpKImtdGhqujQvmGGNg6ggd1gUMQlqeIdq0EpGIXrbFcLtd8TkiOo2Uk3xvKDWyO2W1uLBPqjQhu7NdOXnVhaRSULKwhCdbN8TUmCO(ebcRpiLdUvhBZlQpF2B7m5JXM4j)gkFW45BAezIZ5lgaXt(ClLp)dcyIj)cTZKp2C885kR5fl69a2AuS8EF4YWH6tei4dcyIHNg62nnb86YyIPqaAICBLagUMefHXqTHRP6ceH4aeT3dOioheuDpRGp6nmqbbzotLRmVyrVhWwJIL37dxgtmfccdejEAOB1GZbbvxgtmfccdePkxzrOgoJhqKI1G9GB2iVUPjGxxoCNqqCWPkbmCnjYlQpFvhWXSLum)15GGYVq7m5RNcek)sup5fl69a2AuS8EFy549aYlw07bS1Oy59(qC9mIaeh6mpn0noheuDpRGp6nmqbbzotLRmVyrVhWwJIL37dXj0sOtnaopn0noheuDpRGp6nmqbbzotLRmVyrVhWwJIL37dHAeHRNrWtdDJZbbv3Zk4JEdduqqMZu5kZlw07bS1Oy59(qdeP1rMoenTMNg6gNdcQUNvWh9ggOGGmNPYvMxuF(hNGmoTNpKP14w8u(qdkFU1W1u(Ttkl7l)R5s5xODM8XoRGp6n)bk)JtMZuZlw07bS1Oy59(qULcTtklpn0noheuDpRGp6nmqbbzotLRKvwHA4mEarkwd2dUc25L8I6ZxTDSsO2P8zpUlbI0MxSO3dyR0UeislV3hghqKaoYCseG0McXtdDtacb)C1Bfk4tqXGfvyPOAW5GGQ7zf8rVHbkiiZzQCLfzNAeJxJdisahzojcqAtHc4Ciq174PgaVOASO3dOghqKaoYCseG0McvBqas3WzCwzfItRdikYyi4uWBf6a4rrvXGf2MxSO3dyR0UeislV3hIRNregOGZqbcqkN5PHUvtCgTykaQlJjMcbCTjOTYvwmoJwmfa19Sc(O3WafeK5mvUswzfQHZ4bePynyp4MfyNxSO3dyR0UeislV3hcNZqI2aHbkyhReACM8If9EaBL2LarA59(qOjYTKiyhReQDkGtMcpn0n72ssRdUHGt(wxgouFIaH1hKIk3xXkRiRfbcgc4vti2AduHVGnBlQM4mAXuau3Zk4JEdduqqMZu5klQgCoiO6EwbF0ByGccYCMkxzrcqi4NRccQJTRY91HDEXIEpGTs7sGiT8EFyjhQHo3a4bCTTopn09wsADWneCY36YWH6teiS(Guu5(kwzfzTiqWqaVAcXwBGk8fSZlw07bSvAxcePL37dDgkWbWhoGianOiXtdDJZbbvru8KM2nanOiv5kzLvCoiOkIIN00UbObfPqC4aoHQRBXthWcSZlw07bSvAxcePL37drDzPMcniSLwKYlw07bSvAxcePL37dlmiTagQbbeTdWarINg6ooJwmfa19Sc(O3WafeK5mvePynypGpSYkudNXdisXAWEalSX8If9EaBL2LarA59(qfszqNdduqZfBrqGitz5PHUjaHGF(a1b7I4Cqq19Sc(O3WafeK5mvUY8I6Z)yXOf5FTKv2a45ZM0McT5dnO8jyHICoLpYaWP8hu(NAToFCoiOLN8BO8lNDBCnvZxTPlyN38D0589jF4KNVZq5RNc065hNrlMcG8XTLe5pG8nySwB4AkFcqknT18If9EaBL2LarA59(qezLnaEasBk0YtdDd1Wz8aIuSgShWsLpSYk7yNBi4Kxzit7m1YORcBe2SYQBi4Kxzit7m1YOFW9vWMTfzNf9ggkqasPP9MfwzfQHZ4bePynyv5k2a2YwwzLDUHGtE1Bfk4tOm6HRGTkxh2fzNf9ggkqasPP9MfwzfQHZ4bePynyvrDQJTSnVKxuF(yozANjF1AgTyka28If9EaBDDY0otikwEVpegd1gUM4byk09YicodIwMrl4bgtZr3Xz0IPaOUmMykeegis1iJHGtBaczrVhGPv5MLk7Np8CSG0LekF2dgQnCnLxuF(ShmqVm53q5xGY3qu(rRSSbWZFa5FCdeP8JmgcoT18zpAi958XjObr5d1O1ZxyGiLFdLFbkFgdgkFWKVQnCgFDtFIq5JZ55FCdDkFmgtmfYVb5pibHY3N8HtE(xlxPZHO85kZNDGjF(wBDcLVABxB3gW2AEXIEpGTUozANjeflV3hcJb6LHNg6MDQbgd1gUMQlJi4miAzgTGvwvJBAc4vqdNXx30NiuLagUMefDttaVkm0PWYyIPqLagUMeSTyCuWNq50aFRccQJTRclfvdIdqqdcovvm0PWafCgkOyRtOGTRTBdYlw07bS11jt7mHOy59(WYz0beTdhks8anOaGGf)MfEiyXrwWugoGFRoyZdBEgD(qdkFmgtmfuiTiFEZhJXetH1r9jkFoGM2n)cu(gIY3WhopFFYpAL5pG8pUbIu(rgdbN2A(SHb6Z5xGHa5ZMAGiF2lzNa0U53B(g(W557t(ioq(dNxZlw07bS11jt7mHOy59(WLXetbfsl4PHUjaHGFwLB1b7IeGqWpxfeuhBxLBwGDr1aJHAdxt1LreCgeTmJwumok4tOCAGVvbb1X2vHLIccNdcQc1arOazNa0UvePynypGL8I6ZxTyZ57miAzgTyZhAq5taNqnaE(ymMykK)XnqKYlw07bS11jt7mHOy59(qymuB4AIhGPq3lJiehf8juonWxEGX0C0DCuWNq50aFRccQJTRY9v8IZbbvxgtmfc4AtqBLRmVyrVhWwxNmTZeIIL37dHXqTHRjEaMcDVmIqCuWNq50aF5bgtZr3XrbFcLtd8TkiOo2Uk3xNNg6ooWqad41tNrTbYlw07bS11jt7mHOy59(qymuB4AIhGPq3lJiehf8juonWxEGX0C0DCuWNq50aFRccQJTFWnl80q3WyO2W1uLBPqjQhu7NdOXnVhqXTK06GBi4KV1LHd1Niqy9bPOYT6YlQp)JBGiLVGd1a45JDwbF0B(dkFdFGHY3zq0YmArnVyrVhWwxNmTZeIIL37dxgtmfccdejEAOBymuB4AQUmIqCuWNq50aFlYoymuB4AQUmIGZGOLz0cwzfNdcQUNvWh9ggOGGmNPIifRbRk3SuVIvw3ssRdUHGt(wxgouFIaH1hKIk3QRyCgTykaQ7zf8rVHbkiiZzQisXAWQclWMT5f1N)rCiq(isXAqdGN)XnqK28XjObr57mu(qnCgpFci28BO8XMJNFHbaRE(4u(iYeNZVb57TcvZlw07bS11jt7mHOy59(WLXetHGWarINg6ggd1gUMQlJiehf8juonW3IqnCgpGifRb7bXz0IPaOUNvWh9ggOGGmNPIifRbBEjVO(8XCY0odjY)Ah38Ea5f1N)XgkFmNmTZCimgOxM8neLpxjp5ZTu(ymMykSoQpr57t(4eGGApFi0OKVZq5xA72Wq5JpaUnFdiYNn1ar(SxYobODZNGHa53q5xGY3qu(MNVIbl5RwS58zheAuY3zO8lruCuWnpF(wOJZ2AEXIEpGTUozANHe8EF4YyIPW6O(eXtdDZoCoiO66KPDMkxjRSIZbbvHXa9Yu5kzBEr95ZMAqVm5BE(xN38vl2C(fANz488pow(hMV64n)cTZK)XXYVq7m5JXWH6teiF(heWet(4Cqq5ZvMVp5BWmTi)DuO8vl2C(fS1P8325mVhWwZlw07bS11jt7mKG37dJMwhSO3diO715byk0nud6LHNg6gNdcQUmCO(ebc(GaMyQCLfJJc(ekNg4BvqqDS9dUVkVO(8vB6DYFnikFFYhQb9YKV55RoEZxTyZ5xODM8jyXIU(C(QlF3qWjFR5ZomtHY328hoFBbL)6KPDMkBZlw07bS11jt7mKG37dJMwhSO3diO715byk0nud6LHNg6EljTo4gco5BDz4q9jcewFqk3QRyCuWNq50aFv5wD5f1NpBQb9YKV55RoEZxTyZ5xODMHZZ)4y8KpF4n)cTZK)XX4jFdiYNVYVq7m5FCS8niNq5ZEWa9YKxSO3dyRRtM2zibV3hgnToyrVhqq3RZdWuOBOg0ldpn0DCuWNq50aFRccQJTFWnlhd7CttaVkiQKqH1rMBWjLkbmCnjkIZbbvHXa9Yu5kzBEXIEpGTUozANHe8EF4Y0WWtdD7MMaEf0Wz81n9jcvjGHRjrrehGGgeCQ6n4CWhyPJbCTjOIBjP1b3qWjFRldhQprGW6ds5a(KxuF(xZY89j)RNVBi4KV5FIOY85kZNn1ar(SxYobODZh)C(XZrDdGNpgJjMcRJ6tunVyrVhWwxNmTZqcEVpCzmXuyDuFI4jEoQPGBi4KV3SWtdDliCoiOkudeHcKDcq7wrKI1G9awkULKwhCdbN8TUmCO(ebcRpiLdUVEr3qWjV6Tcf8jiA6yqKI1Gvf(kVO(8ztdk)supO2pNpACZ7bWt(ClLpgJjMcRJ6tu(dmekFmFqk5xODM8zV8T5BWTgSE(CL57t(QlF3qWjFZFq53q5ZMyV53B(ioaObWZFGGYNDdiFdCoFtz4aE(du(UHGt(Y28If9EaBDDY0odj49(WLXetH1r9jINg6ggd1gUMQClfkr9GA)CanU59akYobHZbbvHAGiuGStaA3kIuSgShWcRS6MMaETazLdqXwNqvcy4AsuCljTo4gco5BDz4q9jcewFqkhCRo2MxSO3dyRRtM2zibV3hUmCO(ebcRpifEAO7TK06GBi4KVQCFDEzhoheu1zOaACNavUswzfXbiObbNQ2jZq9g2HthGqgCfc4fJdqW1EvqujHccdoCcTvKboPYn7NTfzhoheuDpRGp6nmqbbzotW48jIAVYvYkRQbNdcQwIifs0U59aQCLSY6wsADWneCYxvU5dBZlQpFmgtmfwh1NO89jFebHOLjF2ude5ZEj7eG2nFdiY3N8jWYHO8lq5hnq(rdHoN)adHY3YhItRZNnXEZVb(KVZq5diyXZhBoE(nu(LZUnUMQ5fl69a266KPDgsW79HlJjMcRJ6tepn0TGW5GGQqnqekq2jaTBfrkwd2dUzHvwJZOftbqDpRGp6nmqbbzotfrkwd2dyHnwuq4CqqvOgicfi7eG2TIifRb7bXz0IPaOUNvWh9ggOGGmNPIifRbBEXIEpGTUozANHe8EFiC9mk4Atq80q34Cqq1scbniZjragQbBDDlEsLB(umoabx71scbniZjragQbBfzGtQCZY1Zlw07bS11jt7mKG37dxgtmfwh1NO8sEr95ZMAqVmeAZlQpF2ltRP852gapF2mIuir7M3dGN8nyMwKF0wVbWZht3rkFdiY)4DKYVadbYhJXetH8pUbIu(9M)odiFFYhNYNBjbp5tWsKk98Hgu(SHEg1giVyrVhWwHAqVm3WyO2W1epatHUlrKcjclqeIdq0EpaEGX0C0TBAc41sePqI2nVhqLagUMef3ssRdUHGt(Ea74ZXehyiGb8kGIOrpibBlQM4adbmGxpDg1giVyrVhWwHAqVm8EF4Q7ifmGii6iXtdDRgymuB4AQwIifsewGiehGO9Eaf3ssRdUHGt(wxgouFIaH1hKYb8vr1GZbbvxgtmfccdePkxzrCoiO6Q7ifmGii6ivrKI1G9aOgoJhqKI1GTiIGq0Yy4AkVyrVhWwHAqVm8EF4Q7ifmGii6iXtdDdJHAdxt1sePqIWceH4aeT3dOyCgTykaQlJjMcbHbIunYyi40gGqw07by6dyPY(5trCoiO6Q7ifmGii6ivrKI1G9G4mAXuau3Zk4JEdduqqMZurKI1GTi7IZOftbqDzmXuiimqKQiYeNlIZbbv3Zk4JEdduqqMZurKI1G9yW5GGQlJjMcbHbIufrkwd2dyPEfBZlw07bSvOg0ldV3hcJHAdxt8amf6Ep1LbexPZHiEGX0C0TIToHc2U2UniGifRbRkWMvwvJBAc4vqdNXx30NiuLagUMefDttaVkm0PWYyIPqLagUMefX5GGQlJjMcbHbIuLRKvw3ssRdUHGt(wxgouFIaH1hKIk38fphliDjHYN9GHAdxt5dnO8VwUsNdr18Xo1L5l4qnaE(8T26ekF12U2Uni)bLVGd1a45FCdeP8l0ot(h3qNY3aI8bt(Q2Wz81n9jcvZlQpF2qjQmFUY8VwUsNdr53q53E(9MVHpCE((KpIdK)W518If9EaBfQb9YW79HiUsNdr80q3Qbgd1gUMQ7PUmG4kDoev0neCYRERqbFcIMogePynyvHVkIiieTmgUMYlw07bSvOg0ldV3hUuerEWPidOzp5O8I6ZNVLt7TyCVbWZ3neCY38DgZZVqR15RByO8Hgu(odLVGdzEpG8hO8VwUsNdr5JiieTm5l4qnaE(LgqqkDSMxSO3dyRqnOxgEVpeXv6CiIN45OMcUHGt(EZcpn0TAGXqTHRP6EQldiUsNdrfvdmgQnCnv5wkuI6b1(5aACZ7buCljTo4gco5BDz4q9jcewFqkQCFvr3qWjV6Tcf8jiAsLB2XhEz3v894OGpHYPb(Yw2werqiAzmCnLxuF(xlbHOLj)RLR05qu(KH0NZVHYV98l0AD(eSu2ikFbhQbWZh7Sc(O3A(hFY3zmpFebHOLj)gkFS545dN8nFezIZ53G8DgkFablE(8zR5fl69a2kud6LH37drCLohI4PHUvdmgQnCnv3tDzaXv6CiQiIuSgSheNrlMcG6EwbF0ByGccYCMkIuSgS8YcSlgNrlMcG6EwbF0ByGccYCMkIuSgShCZNIUHGtE1Bfk4tq00XGifRbRkXz0IPaOUNvWh9ggOGGmNPIifRblV8jVyrVhWwHAqVm8EFiU2INcLtbbH4PHUvdmgQnCnv5wkuI6b1(5aACZ7buCljTo4gco5Rk3xpVyrVhWwHAqVm8EFibtVrczoLxYlQp)J4ATGqBEXIEpGTIZ1AX9Y0WWtdDRg30eWRGgoJVUPprOkbmCnjkI4ae0GGtvVbNd(alDmGRnbvCljTo4gco5BDz4q9jcewFqkhWN8If9EaBfNR1cEVpCz4q9jcewFqk80q3BjP1b3qWjFv5(Q8If9EaBfNR1cEVpCjeYCseWhaf2Y(eXtdDhNrlMcG6siK5KiGpakSL9jQgzmeCAdqil69amTk3xvz)8Hvw3HtJ3arvtMiGFoqWIPuQPkbmCnjkQgCoiOQMmra)CGGftPutvUY8If9EaBfNR1cEVpeUEgfCTjO8If9EaBfNR1cEVpe3INw3WLyBjfLQEfFXI0LUuc]] )


end
