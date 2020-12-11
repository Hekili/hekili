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


    spec:RegisterPack( "Subtlety", 20201210, [[daLJIbqirr9iIs2KO0NuvuJcvrNcvjRcvb9kuvMfQu3IOu2LK(LQcddvuhdvyzQk1ZuvfttuKRHQuBdvH(gQcmovb05uvewNQQQMNQq3du2NOW)ikvkhKOu1cvvYdrfPjQkOlsuQOnIkI(OQQknsvvfXjvfOwPQKxQQQintvbYnvvvyNOQ6NQQkQHQQQ0svvKEkkMkrXvvveTvIsf(kQimwvb4SeLkv7Lu)vKbR4WuwmuESetMWLr2miFgunAO60sTAIsL8AvrZMKBtKDd8BLgUO64QQQy5qEUktNQRJsBxvQVtunEvvPZRQY8rLSFH1COLrZimN08)nN)MZC8nhCUYXNGZCotFRz8F5KMj3kpn4KMbysKMHHfZvK)tZKB)uRj0YOzULfvindU753))XhWBhNfRwwPpUwIvzEVGcYG8pUwQ8HMbJTv(dgOX0mcZjn)FZ5V5mhFZbNRC8a59NitFcnJX64lsZW0sCQMbVfccOX0mc6kAgzfddlMRi)xmF6cNLIxYkMhsfscJqXWbN5oMV583CoEfVKvm)J9nfZBd1gMIQShLYr9IA)xcTU59cIHnpMBJP9y6lMJ8yWiOfrXiNIH9OyAVgVKvmC6kH1akgjwL35kkMIPujR49csQ(8yiGJA6IX3yqKGTqXKVob82uXGi5l6zvZO6ZpTmAMZjt54KqlJMFo0YOziGHPiH(lntb1oHAtZWZyWyHGQNtMYXRS5XWfxXGXcbvFBG(WRS5XWRyYgJKDoHs2D2DniHijRbxmWIHZAgR49c0mhUjw5NJ6NK218)Twgndbmmfj0FPzkO2juBAgmwiO6HZI6Nei5lcyITYMht2ykRe2MY3g4xvqqDP9yEewmFhdxCfZLtkvYneCYV6HZI6NeiD(IKIbwmzkMSXuwjSnLVnWVyYawmzkgU4kMYkHTP8Tb(vfeuxApMhHfdhXiBXWZyCtraVkikNqPZrMBWjPkbmmfjIjBmySqq13gOp8kBEm8sZyfVxGMPykvYkEVGKQpxZO6ZtatI0mqnOpCTR5)pAz0meWWuKq)LMPGANqTPzCtraVcA44(5M6jHQeWWuKiMSXGybe0IGtvVb)s((3UKWuMGQeWWuKiMSXC5KsLCdbN8RE4SO(jbsNViPyEmgERzSI3lqZC49BTR5ptAz0meWWuKq)LMXkEVanZHBIv(5O(jPzkO2juBAgbHXcbvHAGijNSNa6UkIKSgCX8ymCet2yUCsPsUHGt(vpCwu)KaPZxKumpclM)et2yCdbN8Q3suY3KOPyKTyqKK1GlMmIHh1mLFffLCdbN8tZphAxZpV1YOziGHPiH(lntb1oHAtZ82qTHPOk7rPCuVO2)LqRBEVGyYgdpJrqySqqvOgisYj7jGURIijRbxmpgdhXWfxX4MIaEvoz5lqYoNqvcyykset2yUCsPsUHGt(vpCwu)KaPZxKumpclMmfdV0mwX7fOzoCtSYph1pjTR5Nh1YOziGHPiH(lntb1oHAtZC5KsLCdbN8lMmGfZFIHVy4zmySqqvhNsO1DcuzZJHlUIbXciOfbNQ2tZq9LULvLGqgCjc4vcyykset2yklqW2EvquoHscdoCcDvKbEgtgWIHhedVIjBm8mgmwiO69tcBvxAHscYC8KX6Bb1ELnpgU4kMmhdgleunhrsKODZ7fuzZJHlUI5YjLk5gco5xmzalgEhdV0mwX7fOzoCwu)KaPZxKK218Zd0YOziGHPiH(lntb1oHAtZiimwiOkudej5K9eq3vrKK1GlMhHfdhXWfxXu2vjw5G69tcBvxAHscYC8kIKSgCX8ymC8aJjBmccJfcQc1arsozpb0Dvejzn4I5Xyk7QeRCq9(jHTQlTqjbzoEfrswdonJv8EbAMd3eR8Zr9ts7A(FGAz0meWWuKq)LMPGANqTPzWyHGQ5ecArMtI0BQbx9CR8mMmGfdVJjBmLfiyBVMtiOfzojsVPgCvKbEgtgWIHJ)OzSI3lqZaxTReMYeK218)j0YOzSI3lqZC4MyLFoQFsAgcyyksO)s7AxZiiiJv5Az08ZHwgnJv8EbAMND5PMHagMIe6V0UM)V1YOziGHPiH(lnZMRzoY1mwX7fOzEBO2WuKM5TPyjndgleu9uDHsgqKeDHQS5XWfxXC5KsLCdbN8RE4SO(jbsNViPyYawm8OM5THsatI0mhqKklq0EVaTR5)pAz0meWWuKq)LMzZ1mh5AgR49c0mVnuByksZ82uSKMjh1lQ9Fj06M3liMSXC5KsLCdbN8RE4SO(jbsNViPyYawmFRzEBOeWKind7rPCuVO2)LqRBEVaTR5ptAz0meWWuKq)LMXkEVantXuQKv8EbjvFUMr1NNaMePzkIt7A(5Twgndbmmfj0FPzkO2juBAMZjt54KOAkLMXkEVandIfKSI3liP6Z1mQ(8eWKinZ5KPCCsODn)8Owgndbmmfj0FPzkO2juBAMlNuQKBi4KF1dNf1pjq68fjfZJXWJXKngOgoUNqKK1GlMmIHhJjBmySqq1t1fkzars0fQIijRbxmpgd8IOkz)nMSXuwjSnLVnWVyYawmzkgzlgEgJ3sumpgdhCogEfdpmMV1mwX7fOzovxOKbejrxiTR5NhOLrZqadtrc9xAMcQDc1MM5THAdtrv2Js5OErT)lHw38EbAgR49c0mftPswX7fKu95AgvFEcysKM5CYuoEQioTR5)bQLrZqadtrc9xAMnxZCKRzSI3lqZ82qTHPinZBtXsAMV5Dm8fJBkc413n8fvjGHPirm8Wy(MZXWxmUPiGxLSZjuAHshUjw5xLagMIeXWdJ5BohdFX4MIaE9WnXkpbTf2RsadtrIy4HX8nVJHVyCtraVAkRGA)xLagMIeXWdJ5BohdFX8nVJHhgdpJ5YjLk5gco5x9Wzr9tcKoFrsXKbSyYum8sZ82qjGjrAMZjt54jhhrh(QeAxZ)NqlJMHagMIe6V0mfu7eQnndbie8Fvbb1L2J5ryX82qTHPO65KPC8KJJOdFvcnJv8EbAMIPujR49csQ(CnJQppbmjsZCozkhpveN218ZbN1YOziGHPiH(lntb1oHAtZuwjSnLVnWVyGfJbAjRGBi4KivYJHlUIPSsyBkFBGFvbb1L2J5ryXWrmCXvmqnCCpHijRbxmpclgoIjBmLvcBt5Bd8lMmGfZFIHlUIbJfcQE)KWw1LwOKGmhpzS(wqTxzZJjBmLvcBt5Bd8lMmGftMIHlUI5YjLk5gco5x9Wzr9tcKoFrsXKbSyYumzJPSsyBkFBGFXKbSyYKMXkEVantXuQKv8EbjvFUMr1NNaMePzGAqF4AxZphCOLrZqadtrc9xAMcQDc1MMHaec(VQGG6s7X8iSyEBO2Wuu9CYuoEYXr0HVkHMXkEVantXuQKv8EbjvFUMr1NNaMePzWyBLq7A(54BTmAgcyyksO)sZuqTtO20meGqW)vfeuxApMmGfdh8og(IHaec(VkIGtanJv8EbAgdvmaL8fHiGRDn)C8hTmAgR49c0mgQyakLZQosZqadtrc9xAxZphzslJMXkEVanJQHJ7xs2fRaUebCndbmmfj0FPDn)CWBTmAgR49c0myg80cLCuxEEAgcyyksO)s7AxZKJOYkHzUwgn)COLrZyfVxGMXYZv)s5BFlqZqadtrc9xAxZ)3Az0mwX7fOzoNmLJRziGHPiH(lTR5)pAz0meWWuKq)LMXkEVanJKHEsIe0IscYCCntoIkReM5PJklqCAgo4T218NjTmAgcyyksO)sZyfVxGM5uDHsgqKeDH0mfu7eQnndIGq0HByksZKJOYkHzE6OYceNMHdTR5N3Az0meWWuKq)LMPGANqTPzqSacArWPQKHEMwOKJtjj7CcLS7S7AqLagMIeAgR49c0mhUjw5jmLjOt7AxZGX2kHwgn)COLrZqadtrc9xAMcQDc1MMjZX4MIaEf0WX9Zn1tcvjGHPirmzJbXciOfbNQEd(L89VDjHPmbvjGHPirmzJ5YjLk5gco5x9Wzr9tcKoFrsX8ym8wZyfVxGM5W73AxZ)3Az0meWWuKq)LMPGANqTPzUCsPsUHGt(ftgWI5BnJv8EbAMdNf1pjq68fjPDn))rlJMHagMIe6V0mfu7eQnntzxLyLdQhHqMtIe2cO0L3pPAb3qWPlbHSI3lWuXKbSy(UYd4DmCXvm3YQWAGOQitKW(LO)As5kQsadtrIyYgtMJbJfcQQitKW(LO)As5kQYMRzSI3lqZCeczojsylGsxE)K0UM)mPLrZyfVxGMbUAxjmLjindbmmfj0FPDn)8wlJMXkEVandMvEEUHPziGHPiH(lTRDntrCAz08ZHwgndbmmfj0FPzkO2juBAMmhdgleu9WnXkpjmqHQS5XKngmwiO6HZI6Nei5lcyITYMht2yWyHGQholQFsGKViGj2kIKSgCX8iSy(tL3AgR49c0mhUjw5jHbkKMH9O0cbLGxeA(5q7A()wlJMHagMIe6V0mfu7eQnndgleu9Wzr9tcK8fbmXwzZJjBmySqq1dNf1pjqYxeWeBfrswdUyEewm)PYBnJv8EbAM7Ne2QU0cLeK54Ag2JsleucErO5NdTR5)pAz0meWWuKq)LMPGANqTPzEBO2Wuu9aIuzbI27fet2yYCmNtMYXjrvYaUI0mwX7fOzGugCsPmVxG218NjTmAgcyyksO)sZuqTtO20mccJfcQcPm4KszEVGkIKSgCX8ymFRzSI3lqZaPm4KszEVGurrg4iTR5N3Az0meWWuKq)LMPGANqTPz4zmiwabTi4uvYqptluYXPKKDoHs2D2DnOsadtrIyYgtzLW2u(2a)QccQlThZJWIHJyKTyCtraVkikNqPZrMtWjPkbmmfjIHlUIbXciOfbNQcYCC1V0HBIv(vjGHPirmzJPSsyBkFBGFX8ymCedVIjBmySqq17Ne2QU0cLeK54v28yYgdgleu9WnXkpjmqHQS5XKngj7CcLS7S7AqcrswdUyGfdNJjBmySqqvbzoU6x6WnXk)QIvoqZyfVxGM5Tb6dx7A(5rTmAgcyyksO)sZyfVxGMjFxvcr3YIkKMPGANqTPzCtraVE4SO(jbs(IaMyReWWuKiMSXK5yCtraVE4MyLNG2c7vjGHPiHMbArja9xxZphAxZppqlJMHagMIe6V0mfu7eQnndbie8FXKbSy4roht2yEBO2Wuu9aIuzbI27fet2yk7QeRCq9(jHTQlTqjbzoELnpMSXu2vjw5G6HBIvEsyGcvl4gcoDXKbSy4qZyfVxGM5Wzr9tcK8fbmXQDn)pqTmAgcyyksO)sZyfVxGM5ieYCsKWwaLU8(jPzkO2juBAM3gQnmfvpGivwGO9EbXKnMmhJy96riK5KiHTakD59tkjwV6D5zdGht2yCdbN8Q3suY3KOPyYawmFZrmCXvmqnCCpHijRbxmpclgEht2yUCsPsUHGt(vpCwu)KaPZxKumpgZF0mLFffLCdbN8tZphAxZ)NqlJMHagMIe6V0mfu7eQnnZBd1gMIQhqKklq0EVGyYgtzLW2u(2a)QccQlThtgWIHdnJv8EbAMJYV(0UMFo4Swgndbmmfj0FPzkO2juBAM3gQnmfvpGivwGO9EbXKngEgJBkc4vc8MuBEdGNoCtSYVkbmmfjIHlUIPSRsSYb1d3eR8KWafQwWneC6IjdyXWrm8kMSXWZyYCmUPiGxpCwu)KajFratSvcyyksedxCfJBkc41d3eR8e0wyVkbmmfjIHlUIPSRsSYb1dNf1pjqYxeWeBfrswdUyYiMVJHxAgR49c0m3pjSvDPfkjiZX1UMFo4qlJMHagMIe6V0mwX7fOzKm0tsKGwusqMJRzkO2juBAgK1Ie9MaE1eIRYMht2y4zmUHGtE1Bjk5Bs0umpgtzLW2u(2a)QccQlThdxCftMJ5CYuoojQMsft2ykRe2MY3g4xvqqDP9yYawmL8KK930Ltarm8sZu(vuuYneCYpn)CODn)C8Twgndbmmfj0FPzkO2juBAgK1Ie9MaE1eIR2GyYiM)W5yKTyqwls0Bc4vtiUQGfzEVGyYgtzLW2u(2a)QccQlThtgWIPKNKS)MUCci0mwX7fOzKm0tsKGwusqMJRDn)C8hTmAgcyyksO)sZuqTtO20mVnuBykQEarQSar79cIjBmLvcBt5Bd8RkiOU0EmzalMV1mwX7fOzoCtSYtyktqN218ZrM0YOziGHPiH(lntb1oHAtZ82qTHPO6bePYceT3liMSXuwjSnLVnWVQGG6s7XKbSy(oMSXWZyEBO2WuuL9OuoQxu7)sO1nVxqmCXvmxoPuj3qWj)QholQFsG05lskMhHftMIHxAgR49c0mubFBa8eIYrTKbeAxZph8wlJMHagMIe6V0mfu7eQnnJBkc41d3eR8e0wyVkbmmfjIjBmVnuBykQEarQSar79cIjBmySqq17Ne2QU0cLeK54v2CnJv8EbAMdNf1pjqYxeWeR218ZbpQLrZqadtrc9xAMcQDc1MMjZXGXcbvpCtSYtcduOkBEmzJbQHJ7jejzn4I5ryX8aJHVyCtraVESyoHGyHtvcyyksOzSI3lqZC4MyLNegOqAxZph8aTmAgcyyksO)sZuqTtO20mySqqvm1Ucf75vezfpgU4kgOgoUNqKK1GlMhJ5pCogU4kgmwiO69tcBvxAHscYC8kBEmzJHNXGXcbvpCtSYtyktqxLnpgU4kMYUkXkhupCtSYtyktqxfrswdUyEewmCW5y4LMXkEVant(69c0UMFoEGAz0meWWuKq)LMPGANqTPzWyHGQ3pjSvDPfkjiZXRS5AgR49c0myQDfjiw0pTR5NJpHwgndbmmfj0FPzkO2juBAgmwiO69tcBvxAHscYC8kBUMXkEVandgHoc9SbW1UM)V5Swgndbmmfj0FPzkO2juBAgmwiO69tcBvxAHscYC8kBUMXkEVanduJim1UcTR5)Bo0YOziGHPiH(lntb1oHAtZGXcbvVFsyR6slusqMJxzZ1mwX7fOzmqHohzQuXukTR5)7V1YOziGHPiH(lntb1oHAtZGXcbvVFsyR6slusqMJxzZJHlUIbQHJ7jejzn4I5Xy(MZAgR49c0mShLANKoTRDnZ5KPC8urCAz08ZHwgndbmmfj0FPz2CnZrUMXkEVanZBd1gMI0mVnflPzk7QeRCq9WnXkpjmqHQfCdbNUeeYkEVatftgWIHJkpG3AM3gkbmjsZC4IKJJOdFvcTR5)BTmAgcyyksO)sZuqTtO20m8mMmhZBd1gMIQhUi54i6WxLigU4kMmhJBkc4vqdh3p3upjuLagMIeXKng3ueWRcd9mD4MyLxjGHPirm8kMSXuwjSnLVnWVQGG6s7XKrmCet2yYCmiwabTi4uvYqptluYXPKKDoHs2D2DnOsadtrcnJv8EbAM3gOpCTR5)pAz0meWWuKq)LMXkEVant(UQeIULfvind9xhzjtAzbUMjtCwZaTOeG(RR5NdTR5ptAz0meWWuKq)LMPGANqTPziaHG)lMmGftM4CmzJHaec(VQGG6s7XKbSy4GZXKnMmhZBd1gMIQhUi54i6WxLiMSXuwjSnLVnWVQGG6s7XKrmCet2yeegleufQbIKCYEcO7QisYAWfZJXWHMXkEVanZHBIvUePeAxZpV1YOziGHPiH(lnZMRzoY1mwX7fOzEBO2WuKM5TPyjntzLW2u(2a)QccQlThtgWI57y4lgmwiO6HBIvEctzc6QS5AM3gkbmjsZC4IuzLW2u(2a)0UMFEulJMHagMIe6V0mBUM5ixZyfVxGM5THAdtrAM3MIL0mLvcBt5Bd8RkiOU0EmzalM)OzkO2juBAMY(MagWRp)HAdOzEBOeWKinZHlsLvcBt5Bd8t7A(5bAz0meWWuKq)LMzZ1mh5AgR49c0mVnuByksZ82uSKMPSsyBkFBGFvbb1L2J5ryXWHMPGANqTPzEBO2WuuL9OuoQxu7)sO1nVxqmzJ5YjLk5gco5x9Wzr9tcKoFrsXKbSyYKM5THsatI0mhUivwjSnLVnWpTR5)bQLrZqadtrc9xAMcQDc1MM5THAdtr1dxKkRe2MY3g4xmzJHNX82qTHPO6HlsooIo8vjIHlUIbJfcQE)KWw1LwOKGmhVIijRbxmzalgoQFhdxCfZLtkvYneCYV6HZI6NeiD(IKIjdyXKPyYgtzxLyLdQ3pjSvDPfkjiZXRisYAWftgXWbNJHxAgR49c0mhUjw5jHbkK218)j0YOziGHPiH(lntb1oHAtZ82qTHPO6HlsLvcBt5Bd8lMSXa1WX9eIKSgCX8ymLDvIvoOE)KWw1LwOKGmhVIijRbNMXkEVanZHBIvEsyGcPDTRzGAqF4Az08ZHwgndbmmfj0FPz2CnZrUMXkEVanZBd1gMI0mVnflPzCtraVMJijs0U59cQeWWuKiMSXC5KsLCdbN8RE4SO(jbsNViPyEmgEgdVJr2IPSVjGb8kGkOvTirm8kMSXK5yk7BcyaV(8hQnGM5THsatI0m5isIePdisLfiAVxG218)Twgndbmmfj0FPzkO2juBAMmhZBd1gMIQ5isIePdisLfiAVxqmzJ5YjLk5gco5x9Wzr9tcKoFrsX8ym8ymzJjZXGXcbvpCtSYtcduOkBEmzJbJfcQEQUqjdisIUqvejzn4I5XyGA44EcrswdUyYgdIGq0HByksZyfVxGM5uDHsgqKeDH0UM))OLrZqadtrc9xAMcQDc1MM5THAdtr1CejrI0bePYceT3liMSXu2vjw5G6HBIvEsyGcvl4gcoDjiKv8EbMkMhJHJkpG3XKngmwiO6P6cLmGij6cvrKK1GlMhJPSRsSYb17Ne2QU0cLeK54vejzn4IjBm8mMYUkXkhupCtSYtcduOkImXVyYgdgleu9(jHTQlTqjbzoEfrswdUyKTyWyHGQhUjw5jHbkufrswdUyEmgoQFhdV0mwX7fOzovxOKbejrxiTR5ptAz0meWWuKq)LMzZ1mh5AgR49c0mVnuByksZ82uSKMrYoNqj7o7UgKqKK1GlMmIHZXWfxXK5yCtraVcA44(5M6jHQeWWuKiMSX4MIaEvyONPd3eR8kbmmfjIjBmySqq1d3eR8KWafQYMhdxCfZLtkvYneCYV6HZI6NeiD(IKIjdyXWJAM3gkbmjsZCp78eIn3zrK218ZBTmAgcyyksO)sZuqTtO20mzoM3gQnmfvVNDEcXM7SikMSX4gco5vVLOKVjrtXiBXGijRbxmzedpgt2yqeeIoCdtrAgR49c0mi2CNfrAxZppQLrZyfVxGM5OcI8KtfCq)Fyjndbmmfj0FPDn)8aTmAgcyyksO)sZyfVxGMbXM7SisZuqTtO20mzoM3gQnmfvVNDEcXM7SikMSXK5yEBO2WuuL9OuoQxu7)sO1nVxqmzJ5YjLk5gco5x9Wzr9tcKoFrsXKbSy(oMSX4gco5vVLOKVjrtXKbSy4zm8og(IHNX8Dm8WykRe2MY3g4xm8kgEft2yqeeIoCdtrAMYVIIsUHGt(P5NdTR5)bQLrZqadtrc9xAMcQDc1MMjZX82qTHPO69SZti2CNfrXKngejzn4I5Xyk7QeRCq9(jHTQlTqjbzoEfrswdUy4lgo4CmzJPSRsSYb17Ne2QU0cLeK54vejzn4I5ryXW7yYgJBi4Kx9wIs(MenfJSfdIKSgCXKrmLDvIvoOE)KWw1LwOKGmhVIijRbxm8fdV1mwX7fOzqS5olI0UM)pHwgndbmmfj0FPzkO2juBAMmhZBd1gMIQShLYr9IA)xcTU59cIjBmxoPuj3qWj)IjdyX8hnJv8EbAgmLvEMYx5ccPDn)CWzTmAgR49c0m07(keYCsZqadtrc9xAx7AxZ8MqxVan)FZ5V5mhFZ5pHMrUHana(Pz4eY(pL)hm))3)pMyKbNIPLYxKhd0II5ZNtMYXjXNJbr)h2grIyUvIIXy9vYCsetb3aWPRgVEqnGI5p)FmC6cEtiNeX8zelGGweCQ(a(Cm(gZNrSacArWP6dOsadtrIphdp54V8QgVEqnGIHh))y40f8MqojI5ZiwabTi4u9b85y8nMpJybe0IGt1hqLagMIeFogEYXF5vnEjdofd0QuR8gapgJfzxmYjefd7rIyAqmoofJv8EbXO6ZJbJ1JroHOyaRhd0YceX0GyCCkgtiwqmcZnm7O)pEfJSfZ9tcBvxAHscYC8KX6Bb1E8kEXjK9Fk)py()V)FmXidoftlLVipgOffZNfeKXQ8phdI(pSnIeXCRefJX6RK5KiMcUbGtxnEjdofd0QuR8gapgJfzxmYjefd7rIyAqmoofJv8EbXO6ZJbJ1JroHOyaRhd0YceX0GyCCkgtiwqmcZnm7O)pEfJSfZ9tcBvxAHscYC8KX6Bb1E8kEXjK9Fk)py()V)FmXidoftlLVipgOffZNZruzLWm)ZXGO)dBJirm3krXyS(kzojIPGBa40vJxpOgqXW7)pgoDbVjKtIy(mIfqqlcovFaFogFJ5ZiwabTi4u9bujGHPiXNJX8yKD(p)GIHNC8xEvJxXloHS)t5)bZ))9)JjgzWPyAP8f5XaTOy(CrCFoge9FyBejI5wjkgJ1xjZjrmfCdaNUA86b1akgE))XWPl4nHCseZNrSacArWP6d4ZX4BmFgXciOfbNQpGkbmmfj(Cm887)YRA8kEXjK9Fk)py()V)FmXidoftlLVipgOffZNpNmLJNkI7ZXGO)dBJirm3krXyS(kzojIPGBa40vJxpOgqX89)hdNUG3eYjrmFgXciOfbNQpGphJVX8zelGGweCQ(aQeWWuK4ZXyEmYo)NFqXWto(lVQXR4fNq2)P8)G5))()XeJm4umTu(I8yGwumFgJTvIphdI(pSnIeXCRefJX6RK5KiMcUbGtxnE9GAafdh)FmC6cEtiNeX8zelGGweCQ(a(Cm(gZNrSacArWP6dOsadtrIphdp54V8QgVIxpyP8f5KigEqmwX7feJQp)QXlnZLtfn)FZJCOzYrluRinJSIHHfZvK)lMpDHZsXlzfZdPcjHrOy4GZChZ3C(BohVIxYkM)X(MI5THAdtrv2Js5OErT)lHw38EbXWMhZTX0Em9fZrEmye0IOyKtXWEumTxJxYkgoDLWAafJeRY7CfftXuQKv8EbjvFEmeWrnDX4BmisWwOyYxNaEBQyqK8f9SgVIxYkM)frYgNUsyMhVSI3l4Q5iQSsyMZhSpS8C1Vu(23cIxwX7fC1CevwjmZ5d2hNtMYXJxwX7fC1CevwjmZ5d2hsg6jjsqlkjiZX5ohrLvcZ80rLfioyCW74Lv8EbxnhrLvcZC(G9XP6cLmGij6cXDoIkReM5PJklqCW4G7gcgIGq0HBykkEzfVxWvZruzLWmNpyFC4MyLNWuMGoUBiyiwabTi4uvYqptluYXPKKDoHs2D2DniEfVKvm)dRbX8PRBEVG4Lv8EbhSND5z8swX8jpseJVXiiNqsnGIroo54ekMYUkXkhCXi3ApgOffdd4HXGzhjIzbX4gco5xnEzfVxWXhSpEBO2Wue3atIGDarQSar79c4(TPyjyySqq1t1fkzars0fQYMZfxxoPuj3qWj)QholQFsG05lskdy8y8swX8pdu)IPGBa4umO1nVxqmnumYPyWT3um5OErT)lHw38EbXCKhJbeXiXQ8oxrX4gco5xmS514Lv8EbhFW(4THAdtrCdmjcg7rPCuVO2)LqRBEVaUFBkwcwoQxu7)sO1nVxq2lNuQKBi4KF1dNf1pjq68fjLbSVJxYkgofNkpJHtF4fJ5Xa1OZJxwX7fC8b7JIPujR49csQ(CUbMebRiU4LSI5tzbXaXQu)I5K3EbNUy8nghNIHXjt54KiMpDDZ7fedpX(fJyBa8yUL72JbArf6IjFxvdGhtdfdyD8gapM(IXEBTYWueVQXlR49co(G9bIfKSI3liP6Z5gyseSZjt54KG7gc25KPCCsunLkEjRyK955QFXCQUqjdisIUqXyEmFZxmC6)gJGf1a4X44umqn68y4GZXCuzbIJBdYjumoU5XKj(IHt)3yAOyApg6V5nIUyK3oEdIXXPya0F9y(VC6dJzrX0xmG1JHnpEzfVxWXhSpovxOKbejrxiUBiyxoPuj3qWj)QholQFsG05ls6rEmludh3tisYAWLbpMfJfcQEQUqjdisIUqvejzn4EeEruLS)MTSsyBkFBGFzaltYgp9wIEKdoZlE43XlzfZ)I6f1(Vy(01nVxGSBX8Gi)ZxmW73umwmfKLhJHTSEmeGqW)fd0IIXXPyoNmLJhdN(WlgEIX2kbHI58wPIbrxov8yANx1yKDNnN72JPyGyWOyCCZJ5APCfvJxwX7fC8b7JIPujR49csQ(CUbMeb7CYuoEQioUBiyVnuBykQYEukh1lQ9Fj06M3liEjRy(KhjIX3yeeudOyKJtGy8ng2JI5CYuoEmC6dVywumySTsqOlEzfVxWXhSpEBO2Wue3atIGDozkhp54i6WxLG73MILG9nV5Znfb867g(IQeWWuKGh(nN5Znfb8QKDoHslu6WnXk)QeWWuKGh(nN5Znfb86HBIvEcAlSxLagMIe8WV5nFUPiGxnLvqT)RsadtrcE43CMVV5npKNxoPuj3qWj)QholQFsG05lskdyzIxXlzfdNUGRfekg2RbWJXIHXjt54XWPpmg54eigezf8gapghNIHaec(VyCCeD4RseVSI3l44d2hftPswX7fKu95Cdmjc25KPC8urCC3qWiaHG)RkiOU0(JWEBO2Wuu9CYuoEYXr0HVkr8swXWjBqF4XyEmzIVyK3o(Y6X8qMywumYBhpgM9HXuqThdglee3XWB(IrE74X8qMy45Y6xlOyoNmLJZR4LSIHt0oEmpKjgtDBmqnOp8ympMmXxmgCRbNhtMIXneCYVy45Y6xlOyoNmLJZR4Lv8EbhFW(OykvYkEVGKQpNBGjrWGAqF4C3qWkRe2MY3g4hmd0swb3qWjrQKZfxLvcBt5Bd8RkiOU0(JW4GlUGA44EcrswdUhHXr2YkHTP8Tb(LbS)WfxySqq17Ne2QU0cLeK54jJ13cQ9kBE2YkHTP8Tb(LbSmXfxxoPuj3qWj)QholQFsG05lskdyzkBzLW2u(2a)YawMIxYkMp5rXyXGX2kbHIroobIbrwbVbWJXXPyiaHG)lghhrh(QeXlR49co(G9rXuQKv8EbjvFo3atIGHX2kb3nemcqi4)QccQlT)iS3gQnmfvpNmLJNCCeD4RseVKvmpOvoDEm5OErT)lMgeJPuXSqX44umY()9bfdgvm2JIP9ykg7rxmwm)xo9HXlR49co(G9HHkgGs(IqeW5UHGracb)xvqqDP9mGXbV5Jaec(VkIGtG4Lv8EbhFW(WqfdqPCw1rXlR49co(G9HQHJ7xs2fRaUeb84Lv8EbhFW(aZGNwOKJ6YZlEfVKvmFX2kbHU4Lv8EbxfJTvcyhE)M7gcwMDtraVcA44(5M6jHQeWWuKilIfqqlcov9g8l57F7sctzck7LtkvYneCYV6HZI6NeiD(IKEK3XlR49cUkgBRe8b7JdNf1pjq68fjXDdb7YjLk5gco5xgW(oEzfVxWvXyBLGpyFCeczojsylGsxE)K4UHGv2vjw5G6riK5KiHTakD59tQwWneC6sqiR49cmvgW(UYd4nxCDlRcRbIQImrc7xI(RjLROkbmmfjYMzmwiOQImrc7xI(RjLROkBE8YkEVGRIX2kbFW(aUAxjmLjO4Lv8EbxfJTvc(G9bMvEEUHfVIxYkgoDxLyLdU4LSI5tEump0afkMfcs2GxeXGrqlIIXXPyGA05XC4SO(jbsNViPyGqRumYSiGj2ykReDX0GA8YkEVGRwehFW(4WnXkpjmqH4M9O0cbLGxeW4G7gcwMXyHGQhUjw5jHbkuLnplgleu9Wzr9tcK8fbmXwzZZIXcbvpCwu)KajFratSvejzn4Ee2FQ8oEjRy45NeOO7IXuiYe)IHnpgmQyShfJCkgF3NXWGBIvEmCYTWE8kg2JIH5Ne2QUywiizdEredgbTikghNIbQrNhZHZI6NeiD(IKIbcTsXiZIaMyJPSs0ftdQXlR49cUArC8b7J7Ne2QU0cLeK54CZEuAHGsWlcyCWDdbdJfcQE4SO(jbs(IaMyRS5zXyHGQholQFsGKViGj2kIKSgCpc7pvEhVSI3l4QfXXhSpGugCsPmVxa3neS3gQnmfvpGivwGO9EbzZ85KPCCsuLmGRO4Lv8EbxTio(G9bKYGtkL59csffzGJ4UHGjimwiOkKYGtkL59cQisYAW943XlR49cUArC8b7J3gOpCUBiy8eXciOfbNQsg6zAHsooLKSZjuYUZURbzlRe2MY3g4xvqqDP9hHXHS5MIaEvquoHsNJmNGtsvcyyksWfxiwabTi4uvqMJR(LoCtSYVSLvcBt5Bd87ro4vwmwiO69tcBvxAHscYC8kBEwmwiO6HBIvEsyGcvzZZkzNtOKDNDxdsisYAWbJZzXyHGQcYCC1V0HBIv(vfRCq8swX8V7QIbArXiZIaMyJjhrYgZ(WyK3oEmm4pmgezIFXihNaXawpgela0a4XWWjRXlR49cUArC8b7J8DvjeDllQqCdTOeG(RdJdUBiyUPiGxpCwu)KajFratSvcyyksKnZUPiGxpCtSYtqBH9QeWWuKiEjRy(KhfJmlcyInMCefdZ(WyKJtGyKtXGBVPyCCkgcqi4)Iroo54ekgi0kft(UQgapg5TJVSEmmCYywumYUyppg4eGqMs9RgVSI3l4QfXXhSpoCwu)KajFratSC3qWiaHG)ldy8iNZ(2qTHPO6bePYceT3liBzxLyLdQ3pjSvDPfkjiZXRS5zl7QeRCq9WnXkpjmqHQfCdbNUmGXr8YkEVGRwehFW(4ieYCsKWwaLU8(jXD5xrrj3qWj)GXb3neS3gQnmfvpGivwGO9EbzZSy96riK5KiHTakD59tkjwV6D5zdGN1neCYRElrjFtIMYa23CWfxqnCCpHijRb3JW4D2lNuQKBi4KF1dNf1pjq68fj94FIxwX7fC1I44d2hhLF9XDdb7THAdtr1disLfiAVxq2YkHTP8Tb(vfeuxApdyCeVKvmFYJIH5Ne2QUywqmLDvIvoigEAqoHIbQrNhdd4H8kgwGIUlg5umgIIb(2a4X4Bm5BEmYSiGj2ymGigXgdy9yWT3umm4MyLhdNClSxnEzfVxWvlIJpyFC)KWw1LwOKGmhN7gc2Bd1gMIQhqKklq0EVGS80nfb8kbEtQnVbWthUjw5xLagMIeCXvzxLyLdQhUjw5jHbkuTGBi40Lbmo4vwEMz3ueWRholQFsGKViGj2kbmmfj4Il3ueWRhUjw5jOTWEvcyyksWfxLDvIvoOE4SO(jbs(IaMyRisYAWLX38kEjRyEWqXycXfJHOyyZ5oMd05umoofZcOyK3oEmQvoDEmYiZdRX8jpkg54eigXVgapgi7CcfJJBGy40)ngbb1L2JzrXawpMZjt54Kig5TJVSEmg4xmC6)wJxwX7fC1I44d2hsg6jjsqlkjiZX5U8ROOKBi4KFW4G7gcgYArIEtaVAcXvzZZYt3qWjV6TeL8njA6XYkHTP8Tb(vfeuxANlUY85KPCCsunLkBzLW2u(2a)QccQlTNbSsEsY(B6YjGGxXlzfZdgkgWgJjexmYBLkgrtXiVD8geJJtXaO)6X8hoFChd7rX8pGEymligS9UyK3o(Y6XyGFXWP)BnEzfVxWvlIJpyFizONKibTOKGmhN7gcgYArIEtaVAcXvBqg)HZYgYArIEtaVAcXvfSiZ7fKTSsyBkFBGFvbb1L2Zawjpjz)nD5eqeVSI3l4QfXXhSpoCtSYtyktqh3neS3gQnmfvpGivwGO9EbzlRe2MY3g4xvqqDP9mG9D8YkEVGRwehFW(Gk4BdGNquoQLmGG7gc2Bd1gMIQhqKklq0EVGSLvcBt5Bd8RkiOU0EgW(olpFBO2WuuL9OuoQxu7)sO1nVxaxCD5KsLCdbN8RE4SO(jbsNViPhHLjEfVKvmCI2XJHHtYDmnumG1JXuiYe)IrSaI7yypkgzweWeBmYBhpgM9HXWMxJxwX7fC1I44d2hholQFsGKViGjwUBiyUPiGxpCtSYtqBH9QeWWuKi7Bd1gMIQhqKklq0EVGSySqq17Ne2QU0cLeK54v284Lv8EbxTio(G9XHBIvEsyGcXDdblZySqq1d3eR8KWafQYMNfQHJ7jejzn4Ee2dKp3ueWRhlMtiiw4uLagMIeXlzfd)lq2UCQeZ5SqqXiVD8yuRCcftoQ34Lv8EbxTio(G9r(69c4UHGHXcbvXu7kuSNxrKvCU4cQHJ7jejzn4E8pCMlUWyHGQ3pjSvDPfkjiZXRS5z5jgleu9WnXkpHPmbDv2CU4QSRsSYb1d3eR8eMYe0vrKK1G7ryCWzEfVSI3l4QfXXhSpWu7ksqSOFC3qWWyHGQ3pjSvDPfkjiZXRS5XlR49cUArC8b7dmcDe6zdGZDdbdJfcQE)KWw1LwOKGmhVYMhVSI3l4QfXXhSpGAeHP2vWDdbdJfcQE)KWw1LwOKGmhVYMhVSI3l4QfXXhSpmqHohzQuXukUBiyySqq17Ne2QU0cLeK54v284LSI5HeKXQ8yGmLcZkpJbArXWEgMIIPDs6()y(KhfJ82XJH5Ne2QUywOyEizoEnEzfVxWvlIJpyFWEuQDs64UHGHXcbvVFsyR6slusqMJxzZ5IlOgoUNqKK1G7XV5C8kEjRy4KnOpCcDXlzfdNaVvumSxdGhZ)Iijs0U59c4og792Iyk25naEmmQUqXyarmpSlumYXjqmm4MyLhZdnqHIPVyUDbX4BmyumShj4og6Vfk3JbArX8p9hQnq8YkEVGRc1G(WH92qTHPiUbMeblhrsKiDarQSar79c4(TPyjyUPiGxZrKejA38EbvcyyksK9YjLk5gco5x9Wzr9tcKoFrspYtElBL9nbmGxbubTQfj4v2mx23eWaE95puBG4Lv8EbxfQb9HZhSpovxOKbejrxiUBiyz(THAdtr1CejrI0bePYceT3li7LtkvYneCYV6HZI6NeiD(IKEKhZMzmwiO6HBIvEsyGcvzZZIXcbvpvxOKbejrxOkIKSgCpc1WX9eIKSgCzreeIoCdtrXlR49cUkud6dNpyFCQUqjdisIUqC3qWEBO2WuunhrsKiDarQSar79cYw2vjw5G6HBIvEsyGcvl4gcoDjiKv8EbM6roQ8aENfJfcQEQUqjdisIUqvejzn4ESSRsSYb17Ne2QU0cLeK54vejzn4YYZYUkXkhupCtSYtcduOkImXVSySqq17Ne2QU0cLeK54vejzn4KnmwiO6HBIvEsyGcvrKK1G7roQFZR4Lv8EbxfQb9HZhSpEBO2Wue3atIGDp78eIn3zre3VnflbtYoNqj7o7UgKqKK1GldoZfxz2nfb8kOHJ7NBQNeQsadtrISUPiGxfg6z6WnXkVsadtrISySqq1d3eR8KWafQYMZfxxoPuj3qWj)QholQFsG05lskdy8i3)tivoHIr2HHAdtrXaTOy(u2CNfr1yyE25XiyrnaEm)d7CcfJS)o7UgeZIIrWIAa8yEObkumYBhpMhAONXyarmGng(B44(5M6jHQXlzfZ)uIYJHnpMpLn3zrumnumThtFXyylRhJVXGybXSSEnEzfVxWvHAqF48b7deBUZIiUBiyz(THAdtr17zNNqS5olIY6gco5vVLOKVjrtYgIKSgCzWJzreeIoCdtrXlR49cUkud6dNpyFCubrEYPcoO)pSu8swX8pyvElw3Ba8yCdbN8lgh38yK3kvmQ(nfd0IIXXPyeSiZ7feZcfZNYM7SikgebHOdpgblQbWJj3acsQl14Lv8EbxfQb9HZhSpqS5olI4U8ROOKBi4KFW4G7gcwMFBO2Wuu9E25jeBUZIOSz(THAdtrv2Js5OErT)lHw38EbzVCsPsUHGt(vpCwu)KaPZxKugW(oRBi4Kx9wIs(MenLbmEYB(4538WYkHTP8Tb(XlELfrqi6WnmffVKvmFkbHOdpMpLn3zrumKHu)IPHIP9yK3kvm0FZBefJGf1a4XW8tcBvxnMhUX44MhdIGq0HhtdfdZ(WyGt(fdImXVyAqmoofdG(RhdVVA8YkEVGRc1G(W5d2hi2CNfrC3qWY8Bd1gMIQ3ZopHyZDweLfrswdUhl7QeRCq9(jHTQlTqjbzoEfrswdo(4GZzl7QeRCq9(jHTQlTqjbzoEfrswdUhHX7SUHGtE1Bjk5Bs0KSHijRbxgLDvIvoOE)KWw1LwOKGmhVIijRbhF8oEzfVxWvHAqF48b7dmLvEMYx5ccXDdblZVnuBykQYEukh1lQ9Fj06M3li7LtkvYneCYVmG9N4Lv8EbxfQb9HZhSpO39viK5u8kEjRyyCYuoEmC6UkXkhCXlR49cU65KPC8urC8b7J3gQnmfXnWKiyhUi54i6WxLG73MILGv2vjw5G6HBIvEsyGcvl4gcoDjiKv8EbMkdyCu5b8M7)jKkNqXi7WqTHPO4LSIr2Hb6dpMgkg5umgIIPy55naEmliMhAGcftb3qWPRgJStdP(fdgbTikgOgDEmcduOyAOyKtXGBVPyaBm83WX9Zn1tcfdgRhZdn0ZyyWnXkpMgeZIeekgFJbo5X8PS5olIIHnpgEc2y(h25ekgz)D2DnGx14Lv8Ebx9CYuoEQio(G9XBd0ho3nemEM53gQnmfvpCrYXr0HVkbxCLz3ueWRGgoUFUPEsOkbmmfjY6MIaEvyONPd3eR8kbmmfj4v2YkHTP8Tb(vfeuxApdoYMzelGGweCQkzONPfk54usYoNqj7o7UgeVSI3l4QNtMYXtfXXhSpY3vLq0TSOcXn0Isa6Vomo4M(RJSKjTSahwM4m3)7UQyGwumm4MyLlrkrm8fddUjw5NJ6NumSafDxmYPymefJHTSEm(gtXYJzbX8qduOyk4gcoD1y(NbQFXihNaXWjBGigobzpb0DX0xmg2Y6X4BmiwqmlRxJxwX7fC1Zjt54PI44d2hhUjw5sKsWDdbJaec(VmGLjoNLaec(VQGG6s7zaJdoNnZVnuBykQE4IKJJOdFvISLvcBt5Bd8RkiOU0EgCKvqySqqvOgisYj7jGURIijRb3JCeVKvmC6)gJJJOdFvIlgOffdbCc1a4XWGBIvEmp0afkEzfVxWvpNmLJNkIJpyF82qTHPiUbMeb7WfPYkHTP8Tb(X9BtXsWkRe2MY3g4xvqqDP9mG9nFySqq1d3eR8eMYe0vzZJxwX7fC1Zjt54PI44d2hVnuBykIBGjrWoCrQSsyBkFBGFC)2uSeSYkHTP8Tb(vfeuxApdy)H7gcwzFtad41N)qTbIxwX7fC1Zjt54PI44d2hVnuBykIBGjrWoCrQSsyBkFBGFC)2uSeSYkHTP8Tb(vfeuxA)ryCWDdb7THAdtrv2Js5OErT)lHw38EbzVCsPsUHGt(vpCwu)KaPZxKugWYu8swX8qduOyeSOgapgMFsyR6IzrXyy7Bkghhrh(Qe14Lv8Ebx9CYuoEQio(G9XHBIvEsyGcXDdb7THAdtr1dxKkRe2MY3g4xwE(2qTHPO6HlsooIo8vj4IlmwiO69tcBvxAHscYC8kIKSgCzaJJ63CX1LtkvYneCYV6HZI6NeiD(IKYawMYw2vjw5G69tcBvxAHscYC8kIKSgCzWbN5v8swX8flcedIKSg0a4X8qduOlgmcArumoofdudh3JHaIlMgkgM9HXiFbF2JbJIbrM4xmnigVLOA8YkEVGREozkhpvehFW(4WnXkpjmqH4UHG92qTHPO6HlsLvcBt5Bd8lludh3tisYAW9yzxLyLdQ3pjSvDPfkjiZXRisYAWfVIxYkggNmLJtIy(01nVxq8swX8GHIHXjt54F82a9HhJHOyyZ5og2JIHb3eR8Zr9tkgFJbJaeu7XaHwPyCCkMC7U(nfd2cyVymGigozdeXWji7jGUJ7yO3eiMgkg5umgIIX8yKS)gdN(VXWtwGIUlg2RbWJ5FyNtOyK93z31aEfVSI3l4QNtMYXjbSd3eR8Zr9tI7gcgpXyHGQNtMYXRS5CXfgleu9Tb6dVYMZRSs25ekz3z31GeIKSgCW4C8swXWjBqF4XyEm)HVy40)ng5TJVSEmpKjMpIjt8fJ82XJ5HmXiVD8yyWzr9tceJmlcyIngmwiOyyZJX3yS3BlI5wjkgo9FJrUDofZ1oR59cUA8swXi7v3gZzqum(gdud6dpgZJjt8fdN(VXiVD8yO)Afx9lMmfJBi4KF1y4jJjrXyxmlRFTGI5CYuoELxXlzfdNSb9HhJ5XKj(IHt)3yK3o(Y6X8qgUJH38fJ82XJ5HmChJbeXWJXiVD8yEitmgKtOyKDyG(WJxwX7fC1Zjt54KGpyFumLkzfVxqs1NZnWKiyqnOpCUBiyySqq1dNf1pjqYxeWeBLnpBzLW2u(2a)QccQlT)iSV5IRlNuQKBi4KF1dNf1pjq68fjbltzlRe2MY3g4xgWYexCvwjSnLVnWVQGG6s7pcJdzJNUPiGxfeLtO05iZn4KuLagMIezXyHGQVnqF4v2CEfVSI3l4QNtMYXjbFW(4W73C3qWCtraVcA44(5M6jHQeWWuKilIfqqlcov9g8l57F7sctzck7LtkvYneCYV6HZI6NeiD(IKEK3XlzfZNmpgFJ5pX4gco5xmpjkpg28y4KnqedNGSNa6UyW(ft5xr1a4XWGBIv(5O(jvJxwX7fC1Zjt54KGpyFC4MyLFoQFsCx(vuuYneCYpyCWDdbtqySqqvOgisYj7jGURIijRb3JCK9YjLk5gco5x9Wzr9tcKoFrspc7pzDdbN8Q3suY3KOjzdrswdUm4X4LSIHtUOyYr9IA)xmO1nVxa3XWEumm4MyLFoQFsXSVjumm(IKIrE74XWj(hXyWTgCEmS5X4Bmzkg3qWj)IzrX0qXWj5eX0xmiwaObWJzHGIHNligd8lgtAzbEmlumUHGt(XR4Lv8Ebx9CYuooj4d2hhUjw5NJ6Ne3neS3gQnmfvzpkLJ6f1(VeADZ7fKLNccJfcQc1arsozpb0Dvejzn4EKdU4Ynfb8QCYYxGKDoHQeWWuKi7LtkvYneCYV6HZI6NeiD(IKEewM4v8YkEVGREozkhNe8b7JdNf1pjq68fjXDdb7YjLk5gco5xgW(dF8eJfcQ64ucTUtGkBoxCHybe0IGtv7PzO(s3YQsqidUeb8SLfiyBVkikNqjHbhoHUkYapZagpGxz5jgleu9(jHTQlTqjbzoEYy9TGAVYMZfxzgJfcQMJijs0U59cQS5CX1LtkvYneCYVmGXBEfVKvmm4MyLFoQFsX4BmiccrhEmCYgiIHtq2taDxmgqeJVXqGJfrXiNIPyGykgc9lM9nHIXIbIvPIHtYjIPb(gJJtXaO)6XWSpmMgkM89Ugtr14Lv8Ebx9CYuooj4d2hhUjw5NJ6Ne3nembHXcbvHAGijNSNa6UkIKSgCpcJdU4QSRsSYb17Ne2QU0cLeK54vejzn4EKJhywbHXcbvHAGijNSNa6UkIKSgCpw2vjw5G69tcBvxAHscYC8kIKSgCXlR49cU65KPCCsWhSpGR2vctzcI7gcggleunNqqlYCsKEtn4QNBLNzaJ3zllqW2EnNqqlYCsKEtn4Qid8mdyC8N4Lv8Ebx9CYuooj4d2hhUjw5NJ6NK21Uwda]] )

    
end
