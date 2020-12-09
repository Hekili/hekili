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

    spec:RegisterSetting( "solo_vanish", true, {
        name = "Allow |T132331:0|t Vanish when Solo",
        desc = "If unchecked, the addon will not recommend |T132331:0|t Vanish when you are alone (to avoid resetting combat).",
        type = "toggle",
        width = "full"
    } )


    spec:RegisterPack( "Subtlety", 20201209, [[daLeJbqivbEePsTjj0NuvOrHuQtHu0QqsuVcj1SqIUfPsAxs6xQsmmKKogsyzQk6zGszAsqDnKs2gPs8nqj14KGKZHuiRduQAEQcDpvv7tc8pKcv5GsqyHQs6HifmrvbDrKeP2isc9rqPsJeuQGtkbPwPQuVeuQqZuvbCtKcLDIu5NGsfnuqjzPQkONcvtfPQRQQaTvKejFfjbJvcIolsHQAVK8xbdwLdtzXq5Xcnzcxg1Mb5ZGQrJWPLA1ifQ8AvrZMOBtk7g43knCj64ijILd55kMovxhrBxvPVtQA8GsCEqX8jvSFrROqrVcxyoRO7tQ(jvP4tQsJQuLgrrHPfnsH7WuYk8sl(0GZkCGPXkCCsmxYomk8sdg5Acf9k8zjrrwHt4E5a7F5f4TtqIvJR2ltRrknVxqezq(ltRfFrHJr2sVqduykCH5SIUpP6NuLIpPknQsvAeffMIpv4gPtSifoERrdkCIwiyGctHl4jQW1DE4KyUKDyY7dx4KC(w359qoYAymkpAeL59jv)KQkCzp(OOxHpoBsNGfk6v0rHIEfodmmjluVQWJO2zuBkCANhgjeuDC2KorLSmpD0jpmsiO6xd0drLSmpAMxX80SXzuWMXMPbbeRznyY7ppQQWTO3lqHpeMy1poQFYkxr3Nk6v4mWWKSq9QcpIANrTPWXiHGQdbjQFYGGViGj2kzzEfZlUAyBOCBGpvbd1X2Z7X)8(uHBrVxGcpAszWIEVGGShxHl7XdatJv4qnOhcLROd2u0RWzGHjzH6vfEe1oJAtHpLSugCdbN9PoeKO(jdcJViT8(ZRW5vmV4QHTHYTb(Kxb)5vyfUf9Ebk8OjLbl69ccYECfUShpamnwHd1GEiuUIUcROxHZadtYc1Rk8iQDg1McpUAyBOCBGpvbd1X2Z7X)8OipDnpANNBsg4vbZLmkmoYCdoRvzGHjzrEfZdJecQ(1a9qujlZJMkCl69cu4rtkdw07feK94kCzpEayASchQb9qOCfD0srVcNbgMKfQxv4ru7mQnfUBsg4vqdNWh3KpzuLbgMKf5vmpejGHweCU6naMGVWshdystWvgyyswKxX8MswkdUHGZ(uhcsu)KbHXxKwEpMhTu4w07fOWhI(RYv0Plk6v4mWWKSq9Qc3IEVaf(qyIv)4O(jRWJO2zuBkCbJrcbvHAGiONTNaEMkI1Sgm59yEuKxX8MswkdUHGZ(uhcsu)KbHXxKwEp(NhSLxX8CdbN9Q3ACW3GO58018qSM1GjVcYtxu4ryIso4gco7JIokuUIoyTIEfodmmjluVQWJO2zuBk8VgQnmjxjhouI6f1omb06M3liVI5r78emgjeufQbIGE2Ec4zQiwZAWK3J5rrE6OtEUjzGx1Zw5c0SXzuLbgMKf5vmVPKLYGBi4Sp1HGe1pzqy8fPL3J)5v48OPc3IEVaf(qyIv)4O(jRCfDfkf9kCgyyswOEvHhrTZO2u4tjlLb3qWzFYRG)8GT8OopANhgjeu1j4aADNbvYY80rN8qKagArW5Q90mupHzjLbiKbxJbELbgMKf5vmV4ceKTxfmxYOGWGdNrtfzGN5vWFEW68OzEfZJ25Hrcbvhy0Ww5ewOGGnNiyK(grTxjlZthDY7b5HrcbvlrSglA38EbvYY80rN8MswkdUHGZ(Kxb)5rR8OPc3IEVaf(qqI6Nmim(I0uUIoAKIEfodmmjluVQWJO2zuBkCbJrcbvHAGiONTNaEMkI1Sgm594FEuKNo6KxCxPy1dQdmAyRCcluqWMturSM1GjVhZJIcvEfZtWyKqqvOgic6z7jGNPIynRbtEpMxCxPy1dQdmAyRCcluqWMturSM1GrHBrVxGcFimXQFCu)KvUIokOQIEfodmmjluVQWJO2zuBkCmsiOAjJGwK5Si8LBWuh3IpZRG)8OvEfZlUabz71sgbTiZzr4l3GPImWZ8k4ppkGnfUf9EbkC4YD1WKMGvUIokOqrVc3IEVaf(qyIv)4O(jRWzGHjzH6vLRCfUGHmsPROxrhfk6v4w07fOWF2XNkCgyyswOEv5k6(urVcNbgMKfQxv4BPcFyxHBrVxGc)RHAdtYk8VMKKv4yKqq1r2royarq0rUswMNo6K3uYszWneC2N6qqI6Nmim(I0YRG)80ff(xdfaMgRWhGiexGO9EbkxrhSPOxHZadtYc1RkCl69cu4rtkdw07feK94kCzpEayAScpkgLRORWk6v4mWWKSq9QcpIANrTPWhNnPtWIQjLkCl69cu4isqWIEVGGShxHl7XdatJv4JZM0jyHYv0rlf9kCgyyswOEvHhrTZO2u4tjlLb3qWzFQdbjQFYGW4lslVhZtxYRyEqnCcpGynRbtEfKNUKxX8WiHGQJSJCWaIGOJCfXAwdM8Emp4rrvZGL8kMxC1W2q52aFYRG)8kCE6AE0opV148EmpkOAE0mpQCEFQWTO3lqHpYoYbdicIoYkxrNUOOxHZadtYc1Rk8TuHpSRWTO3lqH)1qTHjzf(xtsYk8suVO2HjGw38Eb5vmVPKLYGBi4Sp1HGe1pzqy8fPLxb)59Pc)RHcatJv4Kdhkr9IAhMaADZ7fOCfDWAf9kCgyyswOEvHhrTZO2u4FnuBysUsoCOe1lQDycO1nVxGc3IEVafE0KYGf9EbbzpUcx2JhaMgRWhNnPteIIr5k6kuk6v4mWWKSq9QcFlv4d7kCl69cu4FnuByswH)1KKSc)tALh155MKbE9BdFrvgyyswKhvoVpPAEuNNBsg4vnBCgfwOWqyIv)uzGHjzrEu58(KQ5rDEUjzGxhctS6dqBKCQmWWKSipQCEFsR8Oop3KmWRM0IO2HPYadtYI8OY59jvZJ68(Kw5rLZJ25nLSugCdbN9PoeKO(jdcJViT8k4pVcNhnv4FnuayAScFC2KorWjq8qSsHYv0rJu0RWzGHjzH6vfEe1oJAtHZagbhMQGH6y7594FEFnuBysUooBsNi4eiEiwPqHBrVxGcpAszWIEVGGShxHl7XdatJv4JZM0jcrXOCfDuqvf9kCgyyswOEvHhrTZO2u4XvdBdLBd8jV)8mqRzrcdbNfHyPc3IEVafE0KYGf9EbbzpUcx2JhaMgRWHAqpekxrhfuOOxHZadtYc1Rk8iQDg1McpUAyBOCBGpvbd1X2Z7X)8OipD0jpOgoHhqSM1GjVh)ZJI8kMxC1W2q52aFYRG)8GT80rN8WiHGQdmAyRCcluqWMtemsFJO2RKL5vmV4QHTHYTb(Kxb)5vyfUf9Ebk8OjLbl69ccYECfUShpamnwHd1GEiuUIok(urVcNbgMKfQxv4ru7mQnf(uYszWneC2N6qqI6Nmim(I0YRG)8kCEfZlUAyBOCBGp5vWFEfwHBrVxGcpAszWIEVGGShxHl7XdatJv4qnOhcLROJcytrVcNbgMKfQxv4ru7mQnfodyeCyQcgQJTN3J)591qTHj564SjDIGtG4HyLcfUf9Ebk8OjLbl69ccYECfUShpamnwHJr2sHYv0rrHv0RWzGHjzH6vfEe1oJAtHZagbhMQGH6y75vWFEuqR8OopgWi4WurmCgOWTO3lqHBOOb4GViedCLROJcAPOxHBrVxGc3qrdWHss5WkCgyyswOEv5k6Oqxu0RWTO3lqHlB4e(eOXrkGRXaxHZadtYc1RkxrhfWAf9kCl69cu4yg8WcfCuhFokCgyyswOEv5kxHxI44QHzUIEfDuOOxHBrVxGc3klLWek3EwGcNbgMKfQxvUIUpv0RWTO3lqHpoBsNqHZadtYc1RkxrhSPOxHZadtYc1RkCl69cu4Ag6jlcqlkiyZju4LioUAyMhgoUaXOWPGwkxrxHv0RWzGHjzH6vfUf9Ebk8r2royarq0rwHhrTZO2u4igcXdHHjzfEjIJRgM5HHJlqmkCkuUIoAPOxHZadtYc1Rk8iQDg1MchrcyOfbNRAg6zyHcobh0SXzuWMXMPbvgyyswOWTO3lqHpeMy1hWKMGhLRCfoud6HqrVIoku0RWzGHjzH6vf(wQWh2v4w07fOW)AO2WKSc)RjjzfUBsg41seRXI2nVxqLbgMKf5vmVPKLYGBi4Sp1HGe1pzqy8fPL3J5r78OvE6AEX9ldmGxbCeTYfjYJM5vmVhKxC)Yad41NWGAdOW)AOaW0yfEjI1yryaIqCbI27fOCfDFQOxHZadtYc1Rk8iQDg1Mc)b591qTHj5AjI1yryaIqCbI27fKxX8MswkdUHGZ(uhcsu)KbHXxKwEpMNUKxX8EqEyKqq1HWeR(GWarUswMxX8WiHGQJSJCWaIGOJCfXAwdM8EmpOgoHhqSM1GjVI5HyiepegMKv4w07fOWhzh5GbebrhzLROd2u0RWzGHjzH6vfEe1oJAtH)1qTHj5AjI1yryaIqCbI27fKxX8I7kfREqDimXQpimqKRrcdbNNaeYIEVatM3J5rrfwtR8kMhgjeuDKDKdgqeeDKRiwZAWK3J5f3vkw9G6aJg2kNWcfeS5eveRznyYRyE0oV4UsXQhuhctS6dcde5kInbm5vmpmsiO6aJg2kNWcfeS5eveRznyYtxZdJecQoeMy1hegiYveRznyY7X8OO(zE0uHBrVxGcFKDKdgqeeDKvUIUcROxHZadtYc1Rk8TuHpSRWTO3lqH)1qTHjzf(xtsYkCnBCgfSzSzAqaXAwdM8kipQMNo6K3dYZnjd8kOHt4JBYNmQYadtYI8kMNBsg4vHHEggctS6RmWWKSiVI5HrcbvhctS6dcde5kzzE6OtEtjlLb3qWzFQdbjQFYGW4lslVc(Ztxu4FnuayAScFE2LbezPtIyLROJwk6v4mWWKSq9QcpIANrTPWFqEFnuBysUop7YaIS0jrCEfZZneC2RERXbFdIMZtxZdXAwdM8kipDjVI5HyiepegMKv4w07fOWrKLojIvUIoDrrVc3IEVaf(Wre7bNJeGMkHKv4mWWKSq9QYv0bRv0RWzGHjzH6vfUf9EbkCezPtIyfEe1oJAtH)G8(AO2WKCDE2LbezPtI48kM3dY7RHAdtYvYHdLOErTdtaTU59cYRyEtjlLb3qWzFQdbjQFYGW4lslVc(Z7Z8kMNBi4Sx9wJd(genNxb)5r78OvEuNhTZ7Z8OY5fxnSnuUnWN8OzE0mVI5HyiepegMKv4ryIso4gco7JIokuUIUcLIEfodmmjluVQWJO2zuBk8hK3xd1gMKRZZUmGilDseNxX8qSM1GjVhZlURuS6b1bgnSvoHfkiyZjQiwZAWKh15rbvZRyEXDLIvpOoWOHTYjSqbbBorfXAwdM8E8ppALxX8CdbN9Q3ACW3GO58018qSM1GjVcYlURuS6b1bgnSvoHfkiyZjQiwZAWKh15rlfUf9EbkCezPtIyLROJgPOxHZadtYc1Rk8iQDg1Mc)b591qTHj5k5WHsuVO2HjGw38Eb5vmVPKLYGBi4Sp5vWFEWMc3IEVafoM0IpdLREbJuUIokOQIEfUf9EbkC(BprgzoRWzGHjzH6vLRCfEumk6v0rHIEfodmmjluVQWJO2zuBk8hKhgjeuDimXQpimqKRKL5vmpmsiO6qqI6Nmi4lcyITswMxX8WiHGQdbjQFYGGViGj2kI1Sgm594FEWwLwkCl69cu4dHjw9bHbIScNC4WcbfGhfk6Oq5k6(urVcNbgMKfQxv4ru7mQnfogjeuDiir9tge8fbmXwjlZRyEyKqq1HGe1pzqWxeWeBfXAwdM8E8ppyRslfUf9Ebk8bgnSvoHfkiyZju4KdhwiOa8OqrhfkxrhSPOxHZadtYc1Rk8iQDg1Mc)RHAdtY1bicXfiAVxqEfZ7b5noBsNGfvnd4swHBrVxGchsAWzP08EbkxrxHv0RWzGHjzH6vfEe1oJAtHlymsiOkK0GZsP59cQiwZAWK3J59Pc3IEVafoK0GZsP59ccrjBGHvUIoAPOxHZadtYc1Rk8iQDg1McN25Hibm0IGZvnd9mSqbNGdA24mkyZyZ0GkdmmjlYRyEXvdBdLBd8PkyOo2EEp(Nhf5PR55MKbEvWCjJcJJmNHZAvgyyswKNo6KhIeWqlcoxfS5esycdHjw9tLbgMKf5vmV4QHTHYTb(K3J5rrE0mVI5Hrcbvhy0Ww5ewOGGnNOswMxX8WiHGQdHjw9bHbICLSmVI5PzJZOGnJntdciwZAWK3FEunVI5HrcbvfS5esycdHjw9tvS6bkCl69cu4FnqpekxrNUOOxHZadtYc1RkCl69cu4L7kdiEwsuKv4ru7mQnfUBsg41HGe1pzqWxeWeBLbgMKf5vmVhKNBsg41HWeR(a0gjNkdmmjlu4qlkayyXv0rHYv0bRv0RWzGHjzH6vfEe1oJAtHZagbhM8k4ppDHQ5vmVVgQnmjxhGiexGO9Eb5vmV4UsXQhuhy0Ww5ewOGGnNOswMxX8I7kfREqDimXQpimqKRrcdbNN8k4ppku4w07fOWhcsu)KbbFratSkxrxHsrVcNbgMKfQxv4w07fOWhgHmNfbSfWHPSFYk8iQDg1Mc)RHAdtY1bicXfiAVxqEfZ7b5jwVomczolcylGdtz)KdI1REhF2a45vmp3qWzV6Tgh8niAoVc(Z7tkYthDYdQHt4beRznyY7X)8OvEfZBkzPm4gco7tDiir9tgegFrA59yEWMcpctuYb3qWzFu0rHYv0rJu0RWzGHjzH6vfEe1oJAtH)1qTHj56aeH4ceT3liVI5fxnSnuUnWNQGH6y75vWFEuOWTO3lqHpC50JYv0rbvv0RWzGHjzH6vfEe1oJAtH)1qTHj56aeH4ceT3liVI5r78CtYaVYGVSClBa8WqyIv)uzGHjzrE6OtEXDLIvpOoeMy1hegiY1iHHGZtEf8Nhf5rZ8kMhTZ7b55MKbEDiir9tge8fbmXwzGHjzrE6OtEUjzGxhctS6dqBKCQmWWKSipD0jV4UsXQhuhcsu)KbbFratSveRznyYRG8(mpAQWTO3lqHpWOHTYjSqbbBoHYv0rbfk6v4mWWKSq9Qc3IEVafUMHEYIa0Icc2CcfEe1oJAtHJSwe4VmWRMqmvYY8kMhTZZneC2RERXbFdIMZ7X8IRg2gk3g4tvWqDS980rN8EqEJZM0jyr1KY8kMxC1W2q52aFQcgQJTNxb)5fldAgSeMsgiYJMk8imrjhCdbN9rrhfkxrhfFQOxHZadtYc1Rk8iQDg1MchzTiWFzGxnHyQniVcYd2OAE6AEiRfb(ld8QjetvqImVxqEfZlUAyBOCBGpvbd1X2ZRG)8ILbndwctjdekCl69cu4Ag6jlcqlkiyZjuUIokGnf9kCgyyswOEvHhrTZO2u4FnuBysUoariUar79cYRyEXvdBdLBd8PkyOo2EEf8N3NkCl69cu4dHjw9bmPj4r5k6OOWk6v4mWWKSq9QcpIANrTPW)AO2WKCDaIqCbI27fKxX8IRg2gk3g4tvWqDS98k4pVpZRyE0oVVgQnmjxjhouI6f1omb06M3lipD0jVPKLYGBi4Sp1HGe1pzqy8fPL3J)5v48OPc3IEVafohj2gapG4suRzaHYv0rbTu0RWzGHjzH6vfEe1oJAtH7MKbEDimXQpaTrYPYadtYI8kM3xd1gMKRdqeIlq0EVG8kMhgjeuDGrdBLtyHcc2CIkzPc3IEVaf(qqI6Nmi4lcyIv5k6Oqxu0RWzGHjzH6vfEe1oJAtH)G8WiHGQdHjw9bHbICLSmVI5b1Wj8aI1Sgm594FEfQ8Oop3KmWRdjMZiis4CLbgMKfkCl69cu4dHjw9bHbISYv0rbSwrVcNbgMKfQxv4ru7mQnfogjeuftURqsoEfXw0ZthDYdQHt4beRznyY7X8GnQMNo6KhgjeuDGrdBLtyHcc2CIkzzEfZJ25HrcbvhctS6dystWtLSmpD0jV4UsXQhuhctS6dystWtfXAwdM8E8ppkOAE0uHBrVxGcVC9Ebkxrhffkf9kCgyyswOEvHhrTZO2u4yKqq1bgnSvoHfkiyZjQKLkCl69cu4yYDfbisemkxrhf0if9kCgyyswOEvHhrTZO2u4yKqq1bgnSvoHfkiyZjQKLkCl69cu4ymAy0Zgax5k6(KQk6v4mWWKSq9QcpIANrTPWXiHGQdmAyRCcluqWMtujlv4w07fOWHAeJj3vOCfDFsHIEfodmmjluVQWJO2zuBkCmsiO6aJg2kNWcfeS5evYsfUf9EbkCde5XrMmenPu5k6(8tf9kCgyyswOEvHhrTZO2u4yKqq1bgnSvoHfkiyZjQKL5PJo5b1Wj8aI1Sgm59yEFsvfUf9EbkCYHdTZAJYvUcFC2Korikgf9k6OqrVcNbgMKfQxv4BPcFyxHBrVxGc)RHAdtYk8VMKKv4XDLIvpOoeMy1hegiY1iHHGZtaczrVxGjZRG)8OOcRPLc)RHcatJv4dHi4eiEiwPq5k6(urVcNbgMKfQxv4ru7mQnfoTZ7b591qTHj56qicobIhIvkYthDY7b55MKbEf0Wj8Xn5tgvzGHjzrEfZZnjd8QWqpddHjw9vgyyswKhnZRyEXvdBdLBd8PkyOo2EEfKhf5vmVhKhIeWqlcox1m0ZWcfCcoOzJZOGnJntdQmWWKSqHBrVxGc)Rb6Hq5k6Gnf9kCgyyswOEvHBrVxGcVCxzaXZsIIScNHfhzbtBjbUcVWuvHdTOaGHfxrhfkxrxHv0RWzGHjzH6vfEe1oJAtHZagbhM8k4pVct18kMhdyeCyQcgQJTNxb)5rbvZRyEpiVVgQnmjxhcrWjq8qSsrEfZlUAyBOCBGpvbd1X2ZRG8OiVI5jymsiOkudeb9S9eWZurSM1GjVhZJcfUf9Ebk8HWeREnwkuUIoAPOxHZadtYc1Rk8TuHpSRWTO3lqH)1qTHjzf(xtsYk84QHTHYTb(ufmuhBpVc(Z7Z8OopmsiO6qyIvFatAcEQKLk8VgkamnwHpeIqC1W2q52aFuUIoDrrVcNbgMKfQxv4BPcFyxHBrVxGc)RHAdtYk8VMKKv4XvdBdLBd8PkyOo2EEf8NhSPWJO2zuBk84(LbgWRpHb1gqH)1qbGPXk8HqeIRg2gk3g4JYv0bRv0RWzGHjzH6vf(wQWh2v4w07fOW)AO2WKSc)RjjzfEC1W2q52aFQcgQJTN3J)5rHcpIANrTPW)AO2WKCLC4qjQxu7WeqRBEVG8kM3uYszWneC2N6qqI6Nmim(I0YRG)8kSc)RHcatJv4dHiexnSnuUnWhLRORqPOxHZadtYc1Rk8iQDg1Mc)RHAdtY1HqeIRg2gk3g4tEfZJ2591qTHj56qicobIhIvkYthDYdJecQoWOHTYjSqbbBorfXAwdM8k4ppkQFMNo6K3uYszWneC2N6qqI6Nmim(I0YRG)8kCEfZlURuS6b1bgnSvoHfkiyZjQiwZAWKxb5rbvZJMkCl69cu4dHjw9bHbISYv0rJu0RWzGHjzH6vfEe1oJAtH)1qTHj56qicXvdBdLBd8jVI5b1Wj8aI1Sgm59yEXDLIvpOoWOHTYjSqbbBorfXAwdgfUf9Ebk8HWeR(GWarw5kxHJr2sHIEfDuOOxHZadtYc1Rk8iQDg1Mc)b55MKbEf0Wj8Xn5tgvzGHjzrEfZdrcyOfbNREdGj4lS0XaM0eCLbgMKf5vmVPKLYGBi4Sp1HGe1pzqy8fPL3J5rlfUf9Ebk8HO)QCfDFQOxHZadtYc1Rk8iQDg1McFkzPm4gco7tEf8N3NkCl69cu4dbjQFYGW4lst5k6Gnf9kCgyyswOEvHhrTZO2u4XDLIvpOomczolcylGdtz)KRrcdbNNaeYIEVatMxb)59zfwtR80rN8MLuI1arvYMiGbtGHftRuYvgyyswKxX8EqEyKqqvjBIagmbgwmTsjxjlv4w07fOWhgHmNfbSfWHPSFYkxrxHv0RWTO3lqHdxURgM0eScNbgMKfQxvUIoAPOxHBrVxGchZIph3Wu4mWWKSq9QYvUYv4Fz00lqr3Nu9tQsXNufwRW1BiqdGpkCQqH4dPRqthSlSpV8ONGZR1kxKNh0IY7JJZM0jyXhZdXujKnIf5nRgNNr6RM5SiViHbGZtnF)bAaNhTG95rdl4lJCwK3hrKagArW5AH8J55BEFercyOfbNRfYkdmmjl(yE0McyHM189hObCEfkyFE0Wc(YiNf59rejGHweCUwi)yE(M3hrKagArW5AHSYadtYIpMhTPawOznFtpbNh0kLR(gappJeztE6zeNh5WI8AqEobNNf9Eb5j7XZdJ0ZtpJ48aRNh0sce51G8CcoptiwqEcZnmByyF(opDnVbgnSvoHfkiyZjcgPVru7578nvOq8H0vOPd2f2NxE0tW51ALlYZdAr59rbdzKs)J5HyQeYgXI8MvJZZi9vZCwKxKWaW5PMVPNGZdALYvFdGNNrISjp9mIZJCyrEnipNGZZIEVG8K945Hr65PNrCEG1ZdAjbI8AqEobNNjelipH5gMnmSpFNNUM3aJg2kNWcfeS5ebJ03iQ98D(Mkui(q6k00b7c7Zlp6j48ATYf55bTO8(yjIJRgM5FmpetLq2iwK3SACEgPVAMZI8Iegaop189hObCE0c2NhnSGVmYzrEFercyOfbNRfYpMNV59rejGHweCUwiRmWWKS4J5zEEuPHD(bYJ2ual0SMVZ3uHcXhsxHMoyxyFE5rpbNxRvUippOfL3hJI5J5HyQeYgXI8MvJZZi9vZCwKxKWaW5PMV)anGZJwW(8OHf8LrolY7JisadTi4CTq(X88nVpIibm0IGZ1czLbgMKfFmpA)jSqZA(oFtfkeFiDfA6GDH95Lh9eCETw5I88GwuEFCC2KorikMpMhIPsiBelYBwnopJ0xnZzrErcdaNNA((d0aoVpH95rdl4lJCwK3hrKagArW5AH8J55BEFercyOfbNRfYkdmmjl(yEMNhvAyNFG8OnfWcnR578nvOq8H0vOPd2f2NxE0tW51ALlYZdAr59rmYwk(yEiMkHSrSiVz148msF1mNf5fjmaCEQ57pqd48Oa2NhnSGVmYzrEFercyOfbNRfYpMNV59rejGHweCUwiRmWWKS4J5rBkGfAwZ357cTw5ICwKhSopl69cYt2Jp18TcVeTqTKv46opCsmxYom59HlCsoFR78EihznmgLhnIY8(KQFs18D(w35bRqSUsdRgM55Bl69cMAjIJRgM5u))IvwkHjuU9SG8Tf9EbtTeXXvdZCQ)FzC2Kor(2IEVGPwI44QHzo1)VOzONSiaTOGGnNGYsehxnmZddhxGy(PGw5Bl69cMAjIJRgM5u))Yi7ihmGii6itzjIJRgM5HHJlqm)uqzd9JyiepegMKZ3w07fm1sehxnmZP()LHWeR(aM0e8qzd9Jibm0IGZvnd9mSqbNGdA24mkyZyZ0G8D(w35rJzniVpCDZ7fKVTO3ly(F2XN5BDN3hCyrE(MNGDgP1aop9eStWO8I7kfREWKNER98GwuE4GhMhMnSiVfKNBi4Sp18Tf9Ebd1)V81qTHjzkbMg)pariUar79cO8Rjj5FmsiO6i7ihmGii6ixjl1rNPKLYGBi4Sp1HGe1pzqy8fPvWVUKV1DE0abhFMhn8WjpZZdQrJNVTO3lyO()LOjLbl69ccYECkbMg)hft(w359HKG8GiLsyYB03EKGN88npNGZd3zt6eSiVpCDZ7fKhTXGjpX2a45nlLTNh0II8Kx5UYgapVgkpW6enaEE9KN91APHjzAwZ3w07fmu))cIeeSO3lii7XPeyA8)4SjDcwqzd9poBsNGfvtkZ36oVcrzPeM8gzh5Gbebrh58mpVpPopAawLNGe1a455eCEqnA88OGQ5nCCbIHsdYzuEoH55vyQZJgGv51q51EEmSu2iEYtF7enipNGZdWWINhSln8W8wuE9Khy98ilZ3w07fmu))Yi7ihmGii6itzd9pLSugCdbN9PoeKO(jdcJViTh1LIqnCcpGynRbtb6srmsiO6i7ihmGii6ixrSM1G5r4rrvZGLIXvdBdLBd8PG)cRR02Bn(rkOknPYFMV1DEWobsyYlsya4CEO1nVxqEnuE658iSVCELOErTdtaTU59cYByppdiYtJu6DPKZZneC2N8ilR5Bl69cgQ)F5RHAdtYucmn(NC4qjQxu7WeqRBEVak)Ass(Ve1lQDycO1nVxqXPKLYGBi4Sp1HGe1pzqy8fPvW)N5BDNhSc1lQDyY7dx38Eb04L3hG9po5bV)Y5z5frwzEg2s65XagbhM8GwuEobN34SjDI8OHho5rBmYwkyuEJ3szEiEk5ONx70SMhn(KLu2EErdKhgNNtyEEtRvk5A(2IEVGH6)xIMugSO3lii7XPeyA8)4SjDIqumu2q)FnuBysUsoCOe1lQDycO1nVxq(w359bhwKNV5jyOgW5PNGb55BEKdN34SjDI8OHho5TO8WiBPGrt(2IEVGH6)x(AO2WKmLatJ)hNnPteCcepeRuq5xtsY)FslQDtYaV(THVOkdmmjlOYFsvQDtYaVQzJZOWcfgctS6NkdmmjlOYFsvQDtYaVoeMy1hG2i5uzGHjzbv(tArTBsg4vtAru7WuzGHjzbv(tQs9N0Ikt7PKLYGBi4Sp1HGe1pzqy8fPvWFHPz(w35rdlyAbJYJCAa88S8WD2KorE0WdZtpbdYdXwKObWZZj48yaJGdtEobIhIvkY3w07fmu))s0KYGf9EbbzpoLatJ)hNnPteIIHYg6Nbmcomvbd1X2F8)RHAdtY1Xzt6ebNaXdXkf5Bl69cgQ)FjAszWIEVGGShNsGPX)qnOhckBO)4QHTHYTb(8BGwZIegcolcXY8TUZJk2GEiYZ88km15PVDIL0Z7H45TO803orE47dZlIAppmsiikZJwuNN(2jY7H45r7L0NwW5noBsNGM5Bl69cgQ)FjAszWIEVGGShNsGPX)qnOhckBO)4QHTHYTb(ufmuhB)XFk0rhOgoHhqSM1G5XFkkgxnSnuUnWNc(HnD0bJecQoWOHTYjSqbbBorWi9nIAVswwmUAyBOCBGpf8x48TUZJk0orEpepptoBEqnOhI8mpVctDEgCRbJNxHZZneC2N8O9s6tl48gNnPtqZ8Tf9Ebd1)VenPmyrVxqq2JtjW04FOg0dbLn0)uYszWneC2N6qqI6Nmim(I0k4VWfJRg2gk3g4tb)foFR78(GdNNLhgzlfmkp9emipeBrIgappNGZJbmcom55eiEiwPiFBrVxWq9)lrtkdw07feK94ucmn(hJSLckBOFgWi4WufmuhB)X)VgQnmjxhNnPteCcepeRuKV1DEFGvppEELOErTdtEniptkZBHYZj48keWQpqEyC0ihoV2ZlAKdp5z5b7sdpmFBrVxWq9)lgkAao4lcXaNYg6Nbmcomvbd1X2l4NcArndyeCyQigodY3w07fmu))IHIgGdLKYHZ3w07fmu))ISHt4tGghPaUgd88Tf9Ebd1)VGzWdluWrD85KVZ36oVxjBPGrt(2IEVGPIr2sX)q0FPSH(FGBsg4vqdNWh3KpzuLbgMKffrKagArW5Q3ayc(clDmGjnbxCkzPm4gco7tDiir9tgegFrApsR8Tf9EbtfJSLcQ)Fziir9tgegFrAu2q)tjlLb3qWzFk4)Z8Tf9EbtfJSLcQ)FzyeYCweWwahMY(jtzd9h3vkw9G6WiK5SiGTaomL9tUgjmeCEcqil69cmzb)FwH10shDMLuI1arvYMiGbtGHftRuYvgyyswu8byKqqvjBIagmbgwmTsjxjlZ3w07fmvmYwkO()f4YD1WKMGZ3w07fmvmYwkO()fml(CCdlFNV1DE0WUsXQhm5BDN3hC48EObICEleKUcpkYdJHweNNtW5b1OXZBiir9tgegFrA5bHwT8OFratS5fxnEYRb18Tf9EbtnkgQ)FzimXQpimqKPKC4WcbfGhf)uqzd9)amsiO6qyIvFqyGixjllIrcbvhcsu)KbbFratSvYYIyKqq1HGe1pzqWxeWeBfXAwdMh)HTkTY36opA)bbsEM8mjInbm5rwMhghnYHZtpNNV7Z8WjmXQppQ4gjhAMh5W5HdJg2kN8wiiDfEuKhgdTiopNGZdQrJN3qqI6Nmim(I0YdcTA5r)IaMyZlUA8KxdQ5Bl69cMAumu))YaJg2kNWcfeS5eusoCyHGcWJIFkOSH(XiHGQdbjQFYGGViGj2kzzrmsiO6qqI6Nmi4lcyITIynRbZJ)WwLw5Bl69cMAumu))cK0GZsP59cOSH()AO2WKCDaIqCbI27fu8bJZM0jyrvZaUKZ3w07fm1OyO()fiPbNLsZ7feIs2adtzd9lymsiOkK0GZsP59cQiwZAW84N5Bl69cMAumu))Yxd0dbLn0pTrKagArW5QMHEgwOGtWbnBCgfSzSzAqX4QHTHYTb(ufmuhB)XFk0v3KmWRcMlzuyCK5mCwRYadtYcD0brcyOfbNRc2CcjmHHWeR(PyC1W2q52aFEKcAweJecQoWOHTYjSqbbBorLSSigjeuDimXQpimqKRKLf1SXzuWMXMPbbeRzny(PArmsiOQGnNqctyimXQFQIvpiFR78Gv7kZdAr5r)IaMyZReX6k((W803orE4epmpeBcyYtpbdYdSEEisaObWZdNkwZ3w07fm1OyO()LYDLbepljkYucTOaGHf)NckBOF3KmWRdbjQFYGGViGj2kdmmjlk(a3KmWRdHjw9bOnsovgyyswKV1DEFWHZJ(fbmXMxjIZdFFyE6jyqE658iSVCEobNhdyeCyYtpb7emkpi0QLx5UYgapp9TtSKEE4uX8wuE04ihpp4mGrMuctnFBrVxWuJIH6)xgcsu)KbbFratSu2q)mGrWHPGFDHQf)AO2WKCDaIqCbI27fumURuS6b1bgnSvoHfkiyZjQKLfJ7kfREqDimXQpimqKRrcdbNNc(PiFBrVxWuJIH6)xggHmNfbSfWHPSFYugHjk5GBi4Sp)uqzd9)1qTHj56aeH4ceT3lO4deRxhgHmNfbSfWHPSFYbX6vVJpBa8IUHGZE1Bno4Bq0Cb)FsHo6a1Wj8aI1Sgmp(tRItjlLb3qWzFQdbjQFYGW4ls7rylFBrVxWuJIH6)xgUC6HYg6)RHAdtY1bicXfiAVxqX4QHTHYTb(ufmuhBVGFkY36oVp4W5HdJg2kN8wqEXDLIvpipABqoJYdQrJNho4H0mpsGKNjp9CEgIZd(2a455BELBzE0ViGj28mGipXMhy98iSVCE4eMy1NhvCJKtnFBrVxWuJIH6)xgy0Ww5ewOGGnNGYg6)RHAdtY1bicXfiAVxqrA7MKbELbFz5w2a4HHWeR(PYadtYcD0jURuS6b1HWeR(GWarUgjmeCEk4NcAwK2pWnjd86qqI6Nmi4lcyITYadtYcD0Xnjd86qyIvFaAJKtLbgMKf6OtCxPy1dQdbjQFYGGViGj2kI1Sgmf8jnZ36oVcnuEMqm5ziopYskZBaDjNNtW5Taop9TtKNC1ZJNh90)WAEFWHZtpbdYtatdGNhKnoJYZjmqE0aSkpbd1X2ZBr5bwpVXzt6eSip9TtSKEEgaM8ObyvnFBrVxWuJIH6)x0m0tweGwuqWMtqzeMOKdUHGZ(8tbLn0pYArG)YaVAcXujllsB3qWzV6Tgh8niA(X4QHTHYTb(ufmuhBxhDEW4SjDcwunPSyC1W2q52aFQcgQJTxWFSmOzWsykzGGM5BDNxHgkpWMNjetE6BPmprZ5PVDIgKNtW5byyXZd2O6qzEKdNhng0dZBb5HTZKN(2jwsppdatE0aSQMVTO3lyQrXq9)lAg6jlcqlkiyZjOSH(rwlc8xg4vtiMAdka2OQUISwe4VmWRMqmvbjY8EbfJRg2gk3g4tvWqDS9c(JLbndwctjde5Bl69cMAumu))YqyIvFatAcEOSH()AO2WKCDaIqCbI27fumUAyBOCBGpvbd1X2l4)Z8Tf9EbtnkgQ)FHJeBdGhqCjQ1mGGYg6)RHAdtY1bicXfiAVxqX4QHTHYTb(ufmuhBVG)pls7VgQnmjxjhouI6f1omb06M3lqhDMswkdUHGZ(uhcsu)KbHXxK2J)fMM5BDNhvODI8WPIuMxdLhy98mjInbm5jwatzEKdNh9lcyInp9TtKh((W8ilR5Bl69cMAumu))YqqI6Nmi4lcyILYg63njd86qyIvFaAJKtLbgMKff)AO2WKCDaIqCbI27fueJecQoWOHTYjSqbbBorLSmFBrVxWuJIH6)xgctS6dcdezkBO)hGrcbvhctS6dcde5kzzrOgoHhqSM1G5X)cf1UjzGxhsmNrqKW5kdmmjlY36op6wGUoLCmVXjHGYtF7e5jx9mkVsuV5Bl69cMAumu))s569cOSH(XiHGQyYDfsYXRi2IUo6a1Wj8aI1SgmpcBuvhDWiHGQdmAyRCcluqWMtujllsBmsiO6qyIvFatAcEQKL6OtCxPy1dQdHjw9bmPj4PIynRbZJ)uqvAMVTO3lyQrXq9)lyYDfbisemu2q)yKqq1bgnSvoHfkiyZjQKL5Bl69cMAumu))cgJgg9SbWPSH(XiHGQdmAyRCcluqWMtujlZ3w07fm1OyO()fOgXyYDfu2q)yKqq1bgnSvoHfkiyZjQKL5Bl69cMAumu))IbI84itgIMuszd9Jrcbvhy0Ww5ewOGGnNOswMV1DEpKHmsPNhKjLyw8zEqlkpYXWKCETZAdSpVp4W5PVDI8WHrdBLtEluEpKnNOMVTO3lyQrXq9)lKdhAN1gkBOFmsiO6aJg2kNWcfeS5evYsD0bQHt4beRznyE8tQMVZ36opQyd6HGrt(w35rfiAjNh50a45bRqSglA38EbuMN9DBrErB8gappCzh58mGiVh2rop9emipCctS6Z7HgiY51tEZUG88npmopYHfuMhdlrU0ZdAr5b7imO2a5Bl69cMkud6H4)RHAdtYucmn(VeXASimariUar79cO8Rjj5F3KmWRLiwJfTBEVGkdmmjlkoLSugCdbN9PoeKO(jdcJViThPnT014(LbgWRaoIw5Ie0S4dI7xgyaV(eguBG8Tf9EbtfQb9qq9)lJSJCWaIGOJmLn0)d(AO2WKCTeXASimariUar79ckoLSugCdbN9PoeKO(jdcJViTh1LIpaJecQoeMy1hegiYvYYIyKqq1r2royarq0rUIynRbZJqnCcpGynRbtredH4HWWKC(2IEVGPc1GEiO()Lr2royarq0rMYg6)RHAdtY1seRXIWaeH4ceT3lOyCxPy1dQdHjw9bHbICnsyi48eGqw07fyYhPOcRPvrmsiO6i7ihmGii6ixrSM1G5X4UsXQhuhy0Ww5ewOGGnNOIynRbtrAh3vkw9G6qyIvFqyGixrSjGPigjeuDGrdBLtyHcc2CIkI1Sgm6kgjeuDimXQpimqKRiwZAW8if1pPz(2IEVGPc1GEiO()LVgQnmjtjW04)5zxgqKLojIP8Rjj5FnBCgfSzSzAqaXAwdMcOQo68a3KmWRGgoHpUjFYOkdmmjlk6MKbEvyONHHWeR(kdmmjlkIrcbvhctS6dcde5kzPo6mLSugCdbN9PoeKO(jdcJViTc(1fkHDGLLmkpQugQnmjNh0IY7djlDsexZd)zxMNGe1a45rJzJZO8keZyZ0G8wuEcsudGN3dnqKZtF7e59qd9mpdiYdS5rxdNWh3KpzunFR78GDK5Y8ilZ7djlDseNxdLx751tEg2s655BEisqElPxZ3w07fmvOg0db1)VGilDsetzd9)GVgQnmjxNNDzarw6KiUOBi4Sx9wJd(genRRiwZAWuGUueXqiEimmjNVTO3lyQqnOhcQ)Fz4iI9GZrcqtLqY5BDNhngP0BX6EdGNNBi4Sp55eMNN(wkZt2F58GwuEobNNGezEVG8wO8(qYsNeX5Hyiepe5jirnaEELgqWADSMVTO3lyQqnOhcQ)Fbrw6KiMYimrjhCdbN95NckBO)h81qTHj568SldiYsNeXfFWxd1gMKRKdhkr9IAhMaADZ7fuCkzPm4gco7tDiir9tgegFrAf8)zr3qWzV6Tgh8niAUGFAtlQP9Nu54QHTHYTb(qtAweXqiEimmjNV1DEFidH4HiVpKS0jrCESHKWKxdLx75PVLY8yyPSrCEcsudGNhomAyRCQ59WnpNW88qmeIhI8AO8W3hMhC2N8qSjGjVgKNtW5byyXZJwtnFBrVxWuHAqpeu))cIS0jrmLn0)d(AO2WKCDE2LbezPtI4IiwZAW8yCxPy1dQdmAyRCcluqWMturSM1GHAkOAX4UsXQhuhy0Ww5ewOGGnNOIynRbZJ)0QOBi4Sx9wJd(genRRiwZAWuqCxPy1dQdmAyRCcluqWMturSM1GHAALVTO3lyQqnOhcQ)FbtAXNHYvVGru2q)p4RHAdtYvYHdLOErTdtaTU59ckoLSugCdbN9PGFylFBrVxWuHAqpeu))c)TNiJmNZ35BDNhUZM0jYJg2vkw9GjFBrVxWuhNnPteIIH6)x(AO2WKmLatJ)hcrWjq8qSsbLFnjj)h3vkw9G6qyIvFqyGixJegcopbiKf9EbMSGFkQWAArjSdSSKr5rLYqTHj58TUZJkLb6HiVgkp9CEgIZlALLnaEEliVhAGiNxKWqW5PMhvAdjHjpmgArCEqnA88egiY51q5PNZJW(Y5b28ORHt4JBYNmkpmspVhAON5HtyIvFEniVfjyuE(MhC2Z7djlDseNhzzE0gS5rJzJZO8keZyZ0aAwZ3w07fm1Xzt6eHOyO()LVgOhckBOFA)GVgQnmjxhcrWjq8qSsHo68a3KmWRGgoHpUjFYOkdmmjlk6MKbEvyONHHWeR(kdmmjlOzX4QHTHYTb(ufmuhBVakk(aejGHweCUQzONHfk4eCqZgNrbBgBMgKVTO3lyQJZM0jcrXq9)lL7kdiEwsuKPeArbadl(pfuYWIJSGPTKa)VWuLsy1UY8GwuE4eMy1RXsrEuNhoHjw9JJ6NCEKajptE658meNNHTKEE(Mx0kZBb59qde58Iegcop18GDcKWKNEcgKhvSbI8OcS9eWZKxp5zylPNNV5Hib5TKEnFBrVxWuhNnPteIIH6)xgctS61yPGYg6Nbmcomf8xyQwKbmcomvbd1X2l4NcQw8bFnuBysUoeIGtG4HyLIIXvdBdLBd8PkyOo2EbuuuWyKqqvOgic6z7jGNPIynRbZJuKV1DE0aSkpNaXdXkftEqlkpg4mQbWZdNWeR(8EObIC(2IEVGPooBsNiefd1)V81qTHjzkbMg)peIqC1W2q52aFO8Rjj5)4QHTHYTb(ufmuhBVG)pPgJecQoeMy1hWKMGNkzz(2IEVGPooBsNiefd1)V81qTHjzkbMg)peIqC1W2q52aFO8Rjj5)4QHTHYTb(ufmuhBVGFyJYg6pUFzGb86tyqTbY3w07fm1Xzt6eHOyO()LVgQnmjtjW04)HqeIRg2gk3g4dLFnjj)hxnSnuUnWNQGH6y7p(tbLn0)xd1gMKRKdhkr9IAhMaADZ7fuCkzPm4gco7tDiir9tgegFrAf8x48TUZ7HgiY5jirnaEE4WOHTYjVfLNHTF58CcepeRuuZ3w07fm1Xzt6eHOyO()LHWeR(GWarMYg6)RHAdtY1HqeIRg2gk3g4trA)1qTHj56qicobIhIvk0rhmsiO6aJg2kNWcfeS5eveRznyk4NI6N6OZuYszWneC2N6qqI6Nmim(I0k4VWfJ7kfREqDGrdBLtyHcc2CIkI1SgmfqbvPz(w359kjcKhI1Sg0a459qde5jpmgArCEobNhudNWZJbIjVgkp89H5PFbF0ZdJZdXMaM8AqEERX18Tf9EbtDC2KorikgQ)FzimXQpimqKPSH()AO2WKCDieH4QHTHYTb(ueQHt4beRznyEmURuS6b1bgnSvoHfkiyZjQiwZAWKVZ36opCNnPtWI8(W1nVxq(w35vOHYd3zt6eV81a9qKNH48ilPmpYHZdNWeR(Xr9topFZdJbmu75bHwT8CcoVsBM(lNh2ciN8mGipQyde5rfy7jGNHY84VmiVgkp9CEgIZZ880myjpAawLhTjbsEM8iNgappAmBCgLxHygBMgqZ8Tf9EbtDC2Kobl(hctS6hh1pzkBOFAJrcbvhNnPtujl1rhmsiO6xd0drLSKMf1SXzuWMXMPbbeRzny(PA(w35rfBqpe5zEEWg15rdWQ803oXs659q88EjVctDE6BNiVhINN(2jYdNGe1pzqE0ViGj28WiHGYJSmpFZZ(UTiVz148ObyvE6TX58M2jnVxWuZ3w07fm1Xzt6eSG6)xIMugSO3lii7XPeyA8pud6HGYg6hJecQoeKO(jdc(IaMyRKLfJRg2gk3g4tvWqDS9h))mFR78keYzZBmiopFZdQb9qKN55vyQZJgGv5PVDI8yyXIUeM8kCEUHGZ(uZJ24MgNNn5TK(0coVXzt6evAMVTO3lyQJZM0jyb1)VenPmyrVxqq2JtjW04FOg0dbLn0)uYszWneC2N6qqI6Nmim(I0(lCX4QHTHYTb(uWFHZ36opQyd6HipZZRWuNhnaRYtF7elPN3dXPmpArDE6BNiVhItzEgqKNUKN(2jY7H45zqoJYJkLb6HiFBrVxWuhNnPtWcQ)FjAszWIEVGGShNsGPX)qnOhckBO)4QHTHYTb(ufmuhB)XFk0vA7MKbEvWCjJcJJm3GZAvgyyswueJecQ(1a9qujlPz(2IEVGPooBsNGfu))Yq0FPSH(DtYaVcA4e(4M8jJQmWWKSOiIeWqlcox9gatWxyPJbmPj4ItjlLb3qWzFQdbjQFYGW4ls7rALV1DEFWY88npylp3qWzFY7jZL5rwMhvSbI8OcS9eWZKhgm5fHjkBa88WjmXQFCu)KR5Bl69cM64SjDcwq9)ldHjw9JJ6NmLryIso4gco7Zpfu2q)cgJecQc1arqpBpb8mveRznyEKIItjlLb3qWzFQdbjQFYGW4ls7XFyROBi4Sx9wJd(genRRiwZAWuGUKV1DEuXfLxjQxu7WKhADZ7fqzEKdNhoHjw9JJ6NCE7xgLhUViT803orEubAS8m4wdgppYY88nVcNNBi4Sp5TO8AO8OIuH86jpeja0a45Tqq5r7fKNbGjptBjbEEluEUHGZ(qZ8Tf9EbtDC2KoblO()LHWeR(Xr9tMYg6)RHAdtYvYHdLOErTdtaTU59cksBbJrcbvHAGiONTNaEMkI1SgmpsHo64MKbEvpBLlqZgNrvgyyswuCkzPm4gco7tDiir9tgegFrAp(xyAMVTO3lyQJZM0jyb1)VmeKO(jdcJVinkBO)PKLYGBi4Spf8dButBmsiOQtWb06odQKL6OdIeWqlcoxTNMH6jmlPmaHm4AmWlgxGGS9QG5sgfegC4mAQid8SGFynnlsBmsiO6aJg2kNWcfeS5ebJ03iQ9kzPo68amsiOAjI1yr7M3lOswQJotjlLb3qWzFk4Nw0mFR78WjmXQFCu)KZZ38qmeIhI8OInqKhvGTNaEM8mGipFZJbdjIZtpNx0a5fnecM82VmkplpisPmpQiviVg4BEobNhGHfpp89H51q5vUZ0ysUMVTO3lyQJZM0jyb1)VmeMy1poQFYu2q)cgJecQc1arqpBpb8mveRznyE8NcD0jURuS6b1bgnSvoHfkiyZjQiwZAW8iffQIcgJecQc1arqpBpb8mveRznyEmURuS6b1bgnSvoHfkiyZjQiwZAWKVTO3lyQJZM0jyb1)VaxURgM0emLn0pgjeuTKrqlYCwe(YnyQJBXNf8tRIXfiiBVwYiOfzolcF5gmvKbEwWpfWw(2IEVGPooBsNGfu))YqyIv)4O(jRWNsoQO7tDHcLRCLc]] )

    
end
