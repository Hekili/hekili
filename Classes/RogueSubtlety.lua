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


    spec:RegisterPack( "Subtlety", 20201207, [[def(TbqiIkEervTjj0NqKyuiQCkePwfsf1RqknlKIBPkk2LK(LQqdduYXquwMQcpduktJOkxdPsBdPcFtvu14qKuNtvuP1HOQAEQcUNQQ9ru8pqPQWbjQuwOQipKOsMOQICrevj2iIK8revPgPQOeoPQOIvQQ0lbLQsZuvuQBIurANeL(jOuvnuevXsbLkpfQMksvxfuQYwruL0xruvglrLQZckvfTxs(lvgSkhMYIHYJPQjt4YO2miFgunAeoTuRwvuIETQKztQBtKDd8BLgUeDCKkILd55kMUW1rY2bfFxcgVQI68QsTEvrjnFeX(fTImf9kCHfSs2pG1hWISpG1ZxjdwFq2hpVcpExYk8sZ)YGZkCGjXkCCkSqZXBfEP9wVMqrVcFwkKNv4eruoK)hFeEheuyv)k940suAl6f4rgu840s(hv4yuToEoafMcxybRK9dy9bSi7dy98vYG1hWISNRc3OcIfPWXBj5sHt0cbduykCbpEfU8ZdNcl0C8opy3cNIZVYpVpXEwcJr5980K3hW6dyPW19eJIEf(eSPdcwOOxjlzk6v4mWW0Sq9Kc3J6GrTPWjxEyuqq1jythevQY8iHK8WOGGQWyGEiQuL5r68kMNKnbJC2m2mnWHyjRbtE)5blfU5JEbk8HWeBHjq9lwfkz)qrVcNbgMMfQNu4EuhmQnfogfeuDiOq9lg4IfbmXwPkZRyE(vcBDLBdIPkyO23rEp8N3hkCZh9cu4EtRDMp6f409ekCDpHdysSchQb9qOcLSWMIEfodmmnlupPW9OoyuBk8PK1Axyi4Cm1HGc1VyGBIfjL3FEYlVI55xjS1vUniM8K5pp5PWnF0lqH7nT2z(OxGt3tOW19eoGjXkCOg0dHkuYkpf9kCgyyAwOEsH7rDWO2u4(vcBDLBdIPkyO23rEp8Nhz59m5rU8ctZGOkyUKrUjqwyWzPkdmmnlYRyEyuqqvymqpevQY8iTc38rVafU30AN5JEboDpHcx3t4aMeRWHAqpeQqjlDv0RWzGHPzH6jfUh1bJAtHhMMbrf0WjIjm9lgvzGHPzrEfZdrbyOfbNRrdE7I9ZT3HPnbxzGHPzrEfZBkzT2fgcohtDiOq9lg4Myrs59qE0vHB(OxGcFiAyuHsw6qrVcNbgMMfQNu4Mp6fOWhctSfMa1VyfUh1bJAtHlymkiOkudeUcS9cWZurSK1GjVhYJS8kM3uYATlmeCoM6qqH6xmWnXIKY7H)8GT8kMxyi4CuJwIDX6enN3ZKhILSgm5jtE0Hc3)2Rzxyi4CmkzjtfkzFEf9kCgyyAwOEsH7rDWO2u4WyO2W0CLAyxjQxuhVDOnSOxqEfZJC5jymkiOkudeUcS9cWZurSK1GjVhYJS8iHK8ctZGOwGTYfiztWOkdmmnlYRyEtjR1UWqW5yQdbfQFXa3elskVh(ZtE5rAfU5JEbk8HWeBHjq9lwfkzj1k6v4mWW0Sq9Kc3J6GrTPWNswRDHHGZXKNm)5bB5rBEKlpmkiOAqWo0gbdQuL5rcj5HOam0IGZv7LzOECZsPDqidUedIkdmmnlYRyE(fiO6OkyUKroHbhoJMkYaVYtM)8E(8iDEfZJC5HrbbvN3syREClKtWwq4mQy9OoQuL5rcj5jN8WOGGQLiwIfDyrVGkvzEKqsEtjR1UWqW5yYtM)8OBEKwHB(OxGcFiOq9lg4MyrsQqj7ZvrVcNbgMMfQNu4EuhmQnfUGXOGGQqnq4kW2laptfXswdM8E4ppYYJesYZVRwSfa15Te2Qh3c5eSfevelznyY7H8iJuNxX8emgfeufQbcxb2Eb4zQiwYAWK3d553vl2cG68wcB1JBHCc2cIkILSgmkCZh9cu4dHj2ctG6xSkuYsgSu0RWzGHPzH6jfUh1bJAtHJrbbvlze0ISGfoy4gm1jm)R8K5pp6MxX88lqq1rTKrqlYcw4GHBWurg4vEY8NhzWMc38rVafoC9UsyAtWQqjlzKPOxHB(OxGcFimXwycu)Iv4mWW0Sq9KkuHcNNHbEEu0RKLmf9kCgyyAwOEsH7rDWO2u4mGrWFxJwIDX6KSpNNm5rwEfZto5HrbbvN3syREClKtWwquPkZRyEKlp5KNyJQFbEgeilyHdsBsSdJcbQr7F1a45vmp5KN5JEbv)c8miqwWchK2K4AdCq6gorKhjKKheLw7qSNWqWzx0sCEpKhCVOkzFopsRWnF0lqH7xGNbbYcw4G0MeRcLSFOOxHZadtZc1tkCpQdg1Mcxo553vl2cG6qyITGdtBcEQuL5vmp)UAXwauN3syREClKtWwquPkZJesYdQHteoelznyY7H)8idwkCZh9cu4y6DfUfYfeSJbS0BvOKf2u0RWnF0lqHdNYqI2aUfYzpRmAdcfodmmnlupPcLSYtrVcNbgMMfQNu4EuhmQnfo5YBkzT2fgcohtDiOq9lg4Myrs5jZFEFKhjKKhYAHJHHbr1eIP2G8Kjp6aw5r68kMNCYZVRwSfa15Te2Qh3c5eSfevQY8kMNCYdJccQoVLWw94wiNGTGOsvMxX8yaJG)UkyO23rEY8NhSblfU5JEbkCO1tnSWzpRmQd2HXMKkuYsxf9kCgyyAwOEsH7rDWO2u4tjR1UWqW5yQdbfQFXa3elskpz(Z7J8iHK8qwlCmmmiQMqm1gKNm5rhWsHB(OxGcVKc1qVBaChM2MqfkzPdf9kCgyyAwOEsH7rDWO2u4yuqqve7FP5zCqlYZvQY8iHK8WOGGQi2)sZZ4GwKND(LcemQoH5FL3d5rgSu4Mp6fOWdc2rbWwkGWbTipRcLSpVIEfU5JEbkCuxwQzxdCtP5zfodmmnlupPcLSKAf9kCgyyAwOEsH7rDWO2u4(D1ITaOoVLWw94wiNGTGOIyjRbtEpKhDZJesYdQHteoelznyY7H8iJuRWnF0lqHxyrAbmCdCiEwGb8SkuY(Cv0RWzGHPzH6jfUh1bJAtHZagb)DEpKN8GvEfZdJccQoVLWw94wiNGTGOsvQWnF0lqHlXsl6TBHCAkFlCceBsJkuYsgSu0RWzGHPzH6jfUh1bJAtHd1WjchILSgm59qEKvPBEKqsEKlpYLxyi4Cujythe1sFKNm5rQHvEKqsEHHGZrLGnDqul9rEp8N3hWkpsNxX8ixEMpAyyhdyPMN8(ZJS8iHK8GA4eHdXswdM8KjVpEU5r68iDEKqsEKlVWqW5OgTe7I1v6d3hWkpzYd2GvEfZJC5z(OHHDmGLAEY7ppYYJesYdQHteoelznyYtM8KN8YJ05rAfU5JEbkCeBLnaUdsBs8OcvOWfmKrPdf9kzjtrVc38rVaf(R2)sHZadtZc1tQqj7hk6v4mWW0Sq9KcFlv4dhkCZh9cu4WyO2W0SchgttXkCmkiO6OBp7mGWjApxPkZJesYBkzT2fgcohtDiOq9lg4Myrs5jZFE0Hchgd5aMeRWhGW5xGOJEbQqjlSPOxHZadtZc1tkCZh9cu4EtRDMp6f409ekCDpHdysSc3lgvOKvEk6v4mWW0Sq9Kc3J6GrTPWNGnDqWIQP1kCZh9cu4ikGZ8rVaNUNqHR7jCatIv4tWMoiyHkuYsxf9kCgyyAwOEsH7rDWO2u4tjR1UWqW5yQdbfQFXa3elskVhYJoYRyEqnCIWHyjRbtEYKhDKxX8WOGGQJU9SZacNO9CfXswdM8Eip4ErvY(CEfZZVsyRRCBqm5jZFEYlVNjpYLx0sCEpKhzWkpsNhDoVpu4Mp6fOWhD7zNbeor7zvOKLou0RWzGHPzH6jf(wQWhou4Mp6fOWHXqTHPzfomMMIv4LOErD82H2WIEb5vmVPK1Axyi4Cm1HGc1VyGBIfjLNm)59Hchgd5aMeRWPg2vI6f1XBhAdl6fOcLSpVIEfodmmnlupPW9OoyuBkCymuByAUsnSRe1lQJ3o0gw0lqHB(OxGc3BATZ8rVaNUNqHR7jCatIv4tWMoiCEXOcLSKAf9kCgyyAwOEsHVLk8HdfU5JEbkCymuByAwHdJPPyf(h0npAZlmndIkmn8fvzGHPzrE058(aw5rBEHPzquLSjyKBHCdHj2ctLbgMMf5rNZ7dyLhT5fMMbrDimXwWbTEQPYadtZI8OZ59bDZJ28ctZGOAAZJ64DLbgMMf5rNZ7dyLhT59bDZJoNh5YBkzT2fgcohtDiOq9lg4Myrs5jZFEYlpsRWHXqoGjXk8jytheUGaXdXQfQqj7ZvrVcNbgMMfQNu4EuhmQnfodye83vbd1(oY7H)8GXqTHP56eSPdcxqG4Hy1cfU5JEbkCVP1oZh9cC6EcfUUNWbmjwHpbB6GW5fJkuYsgSu0RWzGHPzH6jfUh1bJAtH7xjS1vUniM8(ZZaTK5jmeCw48LkCZh9cu4EtRDMp6f409ekCDpHdysSchQb9qOcLSKrMIEfodmmnlupPW9OoyuBkC)kHTUYTbXufmu77iVh(ZJS8iHK8GA4eHdXswdM8E4ppYYRyE(vcBDLBdIjpz(Zd2YJesYdJccQoVLWw94wiNGTGWzuX6rDuPkZRyE(vcBDLBdIjpz(ZtEkCZh9cu4EtRDMp6f409ekCDpHdysSchQb9qOcLSK9HIEfodmmnlupPW9OoyuBk8PK1Axyi4Cm1HGc1VyGBIfjLNm)5jV8kMNFLWwx52GyYtM)8KNc38rVafU30AN5JEboDpHcx3t4aMeRWHAqpeQqjlzWMIEfodmmnlupPW9OoyuBkCgWi4VRcgQ9DK3d)5bJHAdtZ1jytheUGaXdXQfkCZh9cu4EtRDMp6f409ekCDpHdysSchJQ1cvOKLm5POxHZadtZc1tkCpQdg1McNbmc(7QGHAFh5jZFEKr38OnpgWi4VRigodu4Mp6fOWnK3aSlweIbHkuYsgDv0RWnF0lqHBiVbyxjLEyfodmmnlupPcLSKrhk6v4Mp6fOW1nCIyCplPeWLyqOWzGHPzH6jvOKLSNxrVc38rVafoMb3TqUa1(xJcNbgMMfQNuHku4Li2VsywOOxjlzk6v4Mp6fOWTYs9Bx52Zcu4mWW0Sq9KkuY(HIEfU5JEbk8jythekCgyyAwOEsfkzHnf9kCgyyAwOEsHB(OxGcxYqVyHdArobBbHcVeX(vcZc3W(figfoz0vfkzLNIEfodmmnlupPWnF0lqHp62ZodiCI2ZkCpQdg1MchXqiEimmnRWlrSFLWSWnSFbIrHtMkuYsxf9kCgyyAwOEsH7rDWO2u4ikadTi4CvYqVClKliyNKnbJC2m2mnOYadtZcfU5JEbk8HWeBbhM2e8OcvOWXOATqrVswYu0RWzGHPzH6jfUh1bJAtHlN8ctZGOcA4eXeM(fJQmWW0SiVI5HOam0IGZ1ObVDX(527W0MGRmWW0SiVI5nLSw7cdbNJPoeuO(fdCtSiP8Eip6QWnF0lqHpenmQqj7hk6v4mWW0Sq9Kc3J6GrTPWNswRDHHGZXKNm)59Hc38rVaf(qqH6xmWnXIKuHswytrVcNbgMMfQNu4EuhmQnfUFxTylaQdJqwWch2cy3u2V4QNWqW5XbHmF0lW05jZFEFuFE6MhjKK3SuASgiQA2eoS3o(ZMuPMRmWW0SiVI5jN8WOGGQA2eoS3o(ZMuPMRuLkCZh9cu4dJqwWch2cy3u2VyvOKvEk6v4Mp6fOWHR3vctBcwHZadtZc1tQqjlDv0RWnF0lqHJz(xtyykCgyyAwOEsfQqH7fJIELSKPOxHZadtZc1tkCpQdg1Mcxo5HrbbvhctSfCcd45kvzEfZdJccQoeuO(fdCXIaMyRuL5vmpmkiO6qqH6xmWflcyITIyjRbtEp8NhSvPRc38rVaf(qyITGtyapRWPg2Tqqo4EHswYuHs2pu0RWzGHPzH6jfUh1bJAtHJrbbvhcku)IbUyratSvQY8kMhgfeuDiOq9lg4IfbmXwrSK1GjVh(Zd2Q0vHB(OxGcFElHT6XTqobBbHcNAy3cb5G7fkzjtfkzHnf9kCgyyAwOEsH7rDWO2u4WyO2W0CDacNFbIo6fKxX8KtEtWMoiyrvYaHMv4Mp6fOWH0gCwRTOxGkuYkpf9kCgyyAwOEsH7rDWO2u4cgJccQcPn4SwBrVGkILSgm59qEFOWnF0lqHdPn4SwBrVaNxZgyyvOKLUk6v4mWW0Sq9Kc3J6GrTPWjxEikadTi4CvYqVClKliyNKnbJC2m2mnOYadtZI8kMNFLWwx52GyQcgQ9DK3d)5rwEptEHPzqufmxYi3eily4SuLbgMMf5rcj5HOam0IGZvbBbH(TBimXwyQmWW0SiVI55xjS1vUniM8EipYYJ05vmpmkiO68wcB1JBHCc2cIkvzEfZdJccQoeMyl4egWZvQY8kMNKnbJC2m2mnWHyjRbtE)5bR8kMhgfeuvWwqOF7gctSfMQylau4Mp6fOWHXa9qOcLS0HIEfodmmnlupPWnF0lqHxUR2H4zPqEwH7rDWO2u4HPzquhcku)IbUyratSvgyyAwKxX8KtEHPzquhctSfCqRNAQmWW0SqHdTihG)COKLmvOK95v0RWzGHPzH6jfUh1bJAtHZagb)DEY8NhDaR8kMhmgQnmnxhGW5xGOJEb5vmp)UAXwauN3syREClKtWwquPkZRyE(D1ITaOoeMyl4egWZvpHHGZtEY8NhzkCZh9cu4dbfQFXaxSiGjwvOKLuROxHZadtZc1tkCZh9cu4dJqwWch2cy3u2VyfUh1bJAtHdJHAdtZ1biC(fi6OxqEfZto5j2OomczblCylGDtz)IDInQr7F1a45vmVWqW5OgTe7I1jAopz(Z7dYYJesYdQHteoelznyY7H)8OBEfZBkzT2fgcohtDiOq9lg4Myrs59qEWMc3)2Rzxyi4CmkzjtfkzFUk6v4mWW0Sq9Kc3J6GrTPWHXqTHP56aeo)ceD0liVI55xjS1vUniMQGHAFh5jZFEKPWnF0lqHpC50JkuYsgSu0RWzGHPzH6jfUh1bJAtHdJHAdtZ1biC(fi6OxqEfZJC5fMMbrLbWW6TSbWDdHj2ctLbgMMf5rcj553vl2cG6qyITGtyapx9egcop5jZFEKLhPZRyEKlp5KxyAge1HGc1VyGlweWeBLbgMMf5rcj5fMMbrDimXwWbTEQPYadtZI8iHK887QfBbqDiOq9lg4IfbmXwrSK1GjpzY7J8iTc38rVaf(8wcB1JBHCc2ccvOKLmYu0RWzGHPzH6jfU5JEbkCjd9IfoOf5eSfekCpQdg1MchzTWXWWGOAcXuPkZRyEKlVWqW5OgTe7I1jAoVhYZVsyRRCBqmvbd1(oYJesYto5nbB6GGfvtRZRyE(vcBDLBdIPkyO23rEY8NNV0jzF2nLmqKhPv4(3En7cdbNJrjlzQqjlzFOOxHZadtZc1tkCpQdg1MchzTWXWWGOAcXuBqEYKhSbR8EM8qwlCmmmiQMqmvbfYIEb5vmp)kHTUYTbXufmu77ipz(ZZx6KSp7Msgiu4Mp6fOWLm0lw4GwKtWwqOcLSKbBk6v4mWW0Sq9Kc3J6GrTPWHXqTHP56aeo)ceD0liVI55xjS1vUniMQGHAFh5jZFEFOWnF0lqHpeMyl4W0MGhvOKLm5POxHZadtZc1tkCpQdg1Mchgd1gMMRdq48lq0rVG8kMNFLWwx52GyQcgQ9DKNm)59rEfZJC5bJHAdtZvQHDLOErD82H2WIEb5rcj5nLSw7cdbNJPoeuO(fdCtSiP8E4pp5LhPv4Mp6fOWzpX2a4oexIAjdiuHswYORIEfodmmnlupPW9OoyuBk8W0miQdHj2coO1tnvgyyAwKxX8GXqTHP56aeo)ceD0liVI5HrbbvN3syREClKtWwquPkv4Mp6fOWhcku)IbUyratSQqjlz0HIEfodmmnlupPW9OoyuBkC5KhgfeuDimXwWjmGNRuL5vmpOgor4qSK1GjVh(ZJuNhT5fMMbrDOWcgbrbNRmWW0SqHB(OxGcFimXwWjmGNvHswYEEf9kCgyyAwOEsH7rDWO2u4yuqqvm9Ucn1eveB(ipsijpOgor4qSK1GjVhYd2GvEKqsEyuqq15Te2Qh3c5eSfevQY8kMh5YdJccQoeMyl4W0MGNkvzEKqsE(D1ITaOoeMyl4W0MGNkILSgm59WFEKbR8iTc38rVafE5g9cuHswYi1k6v4mWW0Sq9Kc3J6GrTPWXOGGQZBjSvpUfYjyliQuLkCZh9cu4y6Dfoik0BvOKLSNRIEfodmmnlupPW9OoyuBkCmkiO68wcB1JBHCc2cIkvPc38rVafogJgg9QbWvHs2pGLIEfodmmnlupPW9OoyuBkCmkiO68wcB1JBHCc2cIkvPc38rVafouJym9UcvOK9dYu0RWzGHPzH6jfUh1bJAtHJrbbvN3syREClKtWwquPkv4Mp6fOWnGNNazAN30AvOK9Jpu0RWzGHPzH6jfUh1bJAtHJrbbvN3syREClKtWwquPkZJesYdQHteoelznyY7H8(awkCZh9cu4ud76GLgvOcf(eSPdcNxmk6vYsMIEfodmmnlupPW3sf(WHc38rVafomgQnmnRWHX0uSc3VRwSfa1HWeBbNWaEU6jmeCECqiZh9cmDEY8Nhz1NNUkCymKdysScFieUGaXdXQfQqj7hk6v4mWW0Sq9Kc3J6GrTPWjxEYjpymuByAUoecxqG4Hy1I8iHK8KtEHPzqubnCIyct)IrvgyyAwKxX8ctZGOkm0l3qyITqLbgMMf5r68kMNFLWwx52GyQcgQ9DKNm5rwEfZto5HOam0IGZvjd9YTqUGGDs2emYzZyZ0Gkdmmnlu4Mp6fOWHXa9qOcLSWMIEfodmmnlupPWnF0lqHxUR2H4zPqEwHZFoqMZKwkqOWLhSu4qlYb4phkzjtfkzLNIEfodmmnlupPW9OoyuBkCgWi4VZtM)8KhSYRyEmGrWFxfmu77ipz(ZJmyLxX8KtEWyO2W0CDieUGaXdXQf5vmp)kHTUYTbXufmu77ipzYJS8kMNGXOGGQqnq4kW2laptfXswdM8EipYu4Mp6fOWhctSfKyTqfkzPRIEfodmmnlupPW3sf(WHc38rVafomgQnmnRWHX0uSc3VsyRRCBqmvbd1(oYtM)8(ipAZdJccQoeMyl4W0MGNkvPchgd5aMeRWhcHZVsyRRCBqmQqjlDOOxHZadtZc1tk8TuHpCOWnF0lqHdJHAdtZkCymnfRW9Re26k3getvWqTVJ8K5ppytH7rDWO2u4(fggyGO(6nQnGchgd5aMeRWhcHZVsyRRCBqmQqj7ZROxHZadtZc1tk8TuHpCOWnF0lqHdJHAdtZkCymnfRW9Re26k3getvWqTVJ8E4ppYu4EuhmQnfomgQnmnxPg2vI6f1XBhAdl6fKxX8MswRDHHGZXuhcku)IbUjwKuEY8NN8u4WyihWKyf(qiC(vcBDLBdIrfkzj1k6v4mWW0Sq9Kc3J6GrTPWHXqTHP56qiC(vcBDLBdIjVI5rU8GXqTHP56qiCbbIhIvlYJesYdJccQoVLWw94wiNGTGOIyjRbtEY8Nhz1pYJesYBkzT2fgcohtDiOq9lg4Myrs5jZFEYlVI553vl2cG68wcB1JBHCc2cIkILSgm5jtEKbR8iTc38rVaf(qyITGtyapRcLSpxf9kCgyyAwOEsH7rDWO2u4WyO2W0CDieo)kHTUYTbXKxX8GA4eHdXswdM8Eip)UAXwauN3syREClKtWwqurSK1GrHB(OxGcFimXwWjmGNvHku4qnOhcf9kzjtrVcNbgMMfQNu4BPcF4qHB(OxGchgd1gMMv4WyAkwHhMMbrTeXsSOdl6fuzGHPzrEfZBkzT2fgcohtEpKh5YJU59m55xyyGbIkG9OvVirEKoVI5jN88lmmWar91BuBafomgYbmjwHxIyjw4gGW5xGOJEbQqj7hk6v4mWW0Sq9Kc3J6GrTPWLtEWyO2W0CTeXsSWnaHZVarh9cYRyEtjR1UWqW5yQdbfQFXa3elskVhYJoYRyEYjpmkiO6qyITGtyapxPkZRyEyuqq1r3E2zaHt0EUIyjRbtEpKhudNiCiwYAWKxX8qmeIhcdtZkCZh9cu4JU9SZacNO9SkuYcBk6v4mWW0Sq9Kc3J6GrTPWHXqTHP5AjILyHBacNFbIo6fKxX887QfBbqDimXwWjmGNREcdbNhheY8rVatN3d5rw95PBEfZdJccQo62ZodiCI2ZvelznyY7H887QfBbqDElHT6XTqobBbrfXswdM8kMh5YZVRwSfa1HWeBbNWaEUIyt8oVI5HrbbvN3syREClKtWwqurSK1GjVNjpmkiO6qyITGtyapxrSK1GjVhYJS6h5rAfU5JEbk8r3E2zaHt0EwfkzLNIEfodmmnlupPW3sf(WHc38rVafomgQnmnRWHX0uScxYMGroBgBMg4qSK1GjpzYdw5rcj5jN8ctZGOcA4eXeM(fJQmWW0SiVI5fMMbrvyOxUHWeBHkdmmnlYRyEyuqq1HWeBbNWaEUsvMhjKK3uYATlmeCoM6qqH6xmWnXIKYtM)8OdfomgYbmjwHpV6shIQmOqSkuYsxf9kCgyyAwOEsH7rDWO2u4YjpymuByAUoV6shIQmOqCEfZlmeCoQrlXUyDIMZ7zYdXswdM8Kjp6iVI5HyiepegMMv4Mp6fOWruLbfIvHsw6qrVc38rVaf(WEehUG9eGMoHIv4mWW0Sq9KkuY(8k6v4mWW0Sq9Kc38rVafoIQmOqSc3J6GrTPWLtEWyO2W0CDE1LoevzqH48kMNCYdgd1gMMRud7kr9I64TdTHf9cYRyEtjR1UWqW5yQdbfQFXa3elskpz(Z7J8kMxyi4CuJwIDX6enNNm)5rU8OBE0Mh5Y7J8OZ55xjS1vUniM8iDEKoVI5HyiepegMMv4(3En7cdbNJrjlzQqjlPwrVcNbgMMfQNu4EuhmQnfUCYdgd1gMMRZRU0HOkdkeNxX8qSK1GjVhYZVRwSfa15Te2Qh3c5eSfevelznyYJ28idw5vmp)UAXwauN3syREClKtWwqurSK1GjVh(ZJU5vmVWqW5OgTe7I1jAoVNjpelznyYtM887QfBbqDElHT6XTqobBbrfXswdM8Onp6QWnF0lqHJOkdkeRcLSpxf9kCgyyAwOEsH7rDWO2u4YjpymuByAUsnSRe1lQJ3o0gw0liVI5nLSw7cdbNJjpz(Zd2u4Mp6fOWX0M)LRCliyKkuYsgSu0RWnF0lqHZW0JNrwWkCgyyAwOEsfQqfkCyy00lqj7hW6dyr2hWIou4fmeObWhfo5tUb7K95il5n5pV8ONGZRLkxuKh0IYJuMGnDqWcsjpetNq1iwK3SsCEgvSswWI88egaop187ZUbCE0L8NNCTayyuWI8ifefGHweCUk3jL8InpsbrbyOfbNRY9kdmmnliL8ihzFM0187ZUbCEKAYFEY1cGHrblYJuquagArW5QCNuYl28ifefGHweCUk3RmWW0SGuYJCK9zsxZV0tW5bTA9wObWZZOq2KxbgX5rnSiVgKxqW5z(OxqE6EI8WOI8kWiopWg5bTuarEniVGGZZeIfKNWcdZgM8NFZ7zYBElHT6XTqobBbHZOI1J6i)MFjFYnyNSphzjVj)5Lh9eCETu5II8GwuEKIGHmkDqk5Hy6eQgXI8MvIZZOIvYcwKNNWaW5PMFPNGZdA16TqdGNNrHSjVcmIZJAyrEniVGGZZ8rVG809e5Hrf5vGrCEGnYdAPaI8AqEbbNNjelipHfgMnm5p)M3ZK38wcB1JBHCc2ccNrfRh1r(n)s(KBWozFoYsEt(Zlp6j48APYff5bTO8iLse7xjmliL8qmDcvJyrEZkX5zuXkzblYZtya48uZVp7gW5rxYFEY1cGHrblYJuquagArW5QCNuYl28ifefGHweCUk3RmWW0SGuYZI8iVa7)zNh5i7ZKUMFZVKp5gSt2NJSK3K)8YJEcoVwQCrrEqlkpsbJQ1csjpetNq1iwK3SsCEgvSswWI88egaop187ZUbCEKr(ZtUwammkyrEKcIcWqlcoxL7KsEXMhPGOam0IGZv5ELbgMMfKsEKJSpt6A(n)s(KBWozFoYsEt(Zlp6j48APYff5bTO8ifVyiL8qmDcvJyrEZkX5zuXkzblYZtya48uZVp7gW5rxYFEY1cGHrblYJuquagArW5QCNuYl28ifefGHweCUk3RmWW0SGuYJCF8zsxZV5xYNCd2j7ZrwYBYFE5rpbNxlvUOipOfLhPmbB6GW5fdPKhIPtOAelYBwjopJkwjlyrEEcdaNNA(9z3aoVpi)5jxlaggfSipsbrbyOfbNRYDsjVyZJuquagArW5QCVYadtZcsjplYJ8cS)NDEKJSpt6A(n)(CKkxuWI8i15z(OxqE6EIPMFv4tj7vY(bDqMcVeTqTMv4YppCkSqZX78GDlCko)k)8(e7zjmgL3ZttEFaRpGv(n)k)8ipi(zKRvcZI8R5JEbtTeX(vcZcA)F0kl1VDLBpli)A(OxWulrSFLWSG2)hNGnDqKFnF0lyQLi2Vsywq7)Jsg6flCqlYjyliOPeX(vcZc3W(fiMFYOB(18rVGPwIy)kHzbT)po62ZodiCI2Z0uIy)kHzHBy)ceZpz00q)igcXdHHP58R5JEbtTeX(vcZcA)FCimXwWHPnbp00q)ikadTi4CvYqVClKliyNKnbJC2m2mni)MFLFE0PwdYd2THf9cYVMp6fm)VA)R8R8Zd2ByrEXMNGdgj1aoVceCqWO887QfBbWKxbRJ8GwuE4GpLhMnSiVfKxyi4Cm18R5JEbdT)pcJHAdtZ0amj(FacNFbIo6fqdmMMI)XOGGQJU9SZacNO9CLQKesMswRDHHGZXuhcku)IbUjwKKm)0r(v(5jxeS)vEY1NM8SipOgnr(18rVGH2)h9Mw7mF0lWP7jObys8Vxm5x5NhSJcKheLw)oVPqhEcEYl28ccop8GnDqWI8GDByrVG8ih278eBdGN3S00rEqlYZtEL7QBa88AO8aBq0a451tEgmwRnmnt6A(18rVGH2)hruaN5JEboDpbnatI)NGnDqWcAAO)jytheSOAAD(v(5j3kl1VZB0TNDgq4eTNZZI8(G28KlYtEckudGNxqW5b1OjYJmyL3W(figAmOGr5fewKN8Onp5I8KxdLxh5XFUSr8KxHoiAqEbbNhG)CKh5TC9P8wuE9KhyJ8OkZVMp6fm0()4OBp7mGWjApttd9pLSw7cdbNJPoeuO(fdCtSiPhOJIqnCIWHyjRbJm0rrmkiO6OBp7mGWjApxrSK1G5b4ErvY(Cr)kHTUYTbXiZV8EgYfTe)azWI005pYVYppy)a9788egaoNhAdl6fKxdLxbopcdgoVsuVOoE7qByrVG8goYZaI8KO0rxQ58cdbNJjpQYA(18rVGH2)hHXqTHPzAaMe)tnSRe1lQJ3o0gw0lGgymnf)xI6f1XBhAdl6fuCkzT2fgcohtDiOq9lg4MyrsY8)r(v(5rEq9I64DEWUnSOxaSpY7zZbPm5bVHHZZYZJSY8mSLkYJbmc(78GwuEbbN3eSPdI8KRpn5romQwlyuEt0ADEiEkzFKxhKUMhSpPkPPJ88gipmoVGWI8MwQuZ18R5JEbdT)p6nT2z(OxGt3tqdWK4)jytheoVyOPH(HXqTHP5k1WUsuVOoE7qByrVG8R8Zd2ByrEXMNGHAaNxbcgKxS5rnCEtWMoiYtU(0K3IYdJQ1cgn5xZh9cgA)Fegd1gMMPbys8)eSPdcxqG4Hy1cAGX0u8)h0L2W0miQW0WxuLbgMMf05pGfTHPzquLSjyKBHCdHj2ctLbgMMf05pGfTHPzquhctSfCqRNAQmWW0SGo)bDPnmndIQPnpQJ3vgyyAwqN)aw0(bDPZKBkzT2fgcohtDiOq9lg4MyrsY8lpsNFLFEY1cMwWO8OMgapplp8GnDqKNC9P8kqWG8qS5jAa88ccopgWi4VZliq8qSAr(18rVGH2)h9Mw7mF0lWP7jObys8)eSPdcNxm00q)mGrWFxfmu774HFymuByAUobB6GWfeiEiwTi)A(OxWq7)JEtRDMp6f409e0amj(hQb9qqtd97xjS1vUniMFd0sMNWqWzHZxMFLFEKQg0drEwKN8OnVcDqSurEFcpVfLxHoiYdF)uEEuh5HrbbrtE0L28k0brEFcppYTuX0coVjytheKo)A(OxWq7)JEtRDMp6f409e0amj(hQb9qqtd97xjS1vUniMQGHAFhp8tgjKa1WjchILSgmp8twr)kHTUYTbXiZpSrcjyuqq15Te2Qh3c5eSfeoJkwpQJkvzr)kHTUYTbXiZV8YVYppYxhe59j88m9S5b1GEiYZI8KhT5zWTgmrEYlVWqW5yYJClvmTGZBc20bbPZVMp6fm0()O30AN5JEboDpbnatI)HAqpe00q)tjR1UWqW5yQdbfQFXa3elssMF5v0VsyRRCBqmY8lV8R8Zd2B48S8WOATGr5vGGb5HyZt0a45feCEmGrWFNxqG4Hy1I8R5JEbdT)p6nT2z(OxGt3tqdWK4FmQwlOPH(zaJG)UkyO23Xd)WyO2W0CDc20bHliq8qSAr(v(59S3c8e5vI6f1X78AqEMwN3cLxqW5j3ipp78WyVrnCEDKN3OgEYZYJ8wU(u(18rVGH2)hnK3aSlweIbbnn0pdye83vbd1(oK5Nm6sldye83vedNb5xZh9cgA)F0qEdWUsk9W5xZh9cgA)Fu3WjIX9SKsaxIbr(18rVGH2)hXm4UfYfO2)AYV5x5NNCTRwSfat(v(5b7nCEFYaEoVfc6zG7f5HXqlIZli48GA0e5neuO(fdCtSiP8GqRuE0ViGj288Rep51GA(18rVGP6fdT)poeMyl4egWZ0qnSBHGCW9IFYOPH(LdgfeuDimXwWjmGNRuLfXOGGQdbfQFXaxSiGj2kvzrmkiO6qqH6xmWflcyITIyjRbZd)WwLU5x5Nh5G9aAEM8mnInX78OkZdJ9g1W5vGZl29vE4eMylKhPA9udPZJA48WFlHT6jVfc6zG7f5HXqlIZli48GA0e5neuO(fdCtSiP8GqRuE0ViGj288Rep51GA(18rVGP6fdT)poVLWw94wiNGTGGgQHDleKdUx8tgnn0pgfeuDiOq9lg4IfbmXwPklIrbbvhcku)IbUyratSvelznyE4h2Q0n)A(OxWu9IH2)hH0gCwRTOxann0pmgQnmnxhGW5xGOJEbfLZeSPdcwuLmqO58R5JEbt1lgA)FesBWzT2IEboVMnWW00q)cgJccQcPn4SwBrVGkILSgmp8r(18rVGP6fdT)pcJb6HGMg6NCikadTi4CvYqVClKliyNKnbJC2m2mnOOFLWwx52GyQcgQ9D8WpzptyAgevbZLmYnbYcgolvzGHPzbjKGOam0IGZvbBbH(TBimXwyk6xjS1vUniMhiJ0fXOGGQZBjSvpUfYjyliQuLfXOGGQdHj2coHb8CLQSOKnbJC2m2mnWHyjRbZpSkIrbbvfSfe63UHWeBHPk2cG8R8ZJ8SRopOfLh9lcyInVse)m47NYRqhe5Ht8P8qSjENxbcgKhyJ8quaqdGNhoPQMFnF0lyQEXq7)JL7QDiEwkKNPbAroa)54NmAAO)W0miQdbfQFXaxSiGj2kdmmnlkkNW0miQdHj2coO1tnvgyyAwKFLFEWEdNh9lcyInVseNh((P8kqWG8kW5ryWW5feCEmGrWFNxbcoiyuEqOvkVYD1naEEf6GyPI8Wjv5TO8EwsnrEWzaJmT(Dn)A(OxWu9IH2)hhcku)IbUyratS00q)mGrWFlZpDaRIWyO2W0CDacNFbIo6fu0VRwSfa15Te2Qh3c5eSfevQYI(D1ITaOoeMyl4egWZvpHHGZJm)KLFnF0lyQEXq7)JdJqwWch2cy3u2VyA8V9A2fgcohZpz00q)WyO2W0CDacNFbIo6fuuoInQdJqwWch2cy3u2VyNyJA0(xnaEXWqW5OgTe7I1jAwM)piJesGA4eHdXswdMh(PBXPK1Axyi4Cm1HGc1VyGBIfj9aSLFnF0lyQEXq7)Jdxo9qtd9dJHAdtZ1biC(fi6Oxqr)kHTUYTbXufmu77qMFYYVYppyVHZd)Te2QN8wqE(D1ITaipYzqbJYdQrtKho4tKopkGMNjVcCEgIZd(2a45fBELBzE0ViGj28mGipXMhyJ8imy48WjmXwips16PMA(18rVGP6fdT)poVLWw94wiNGTGGMg6hgd1gMMRdq48lq0rVGIKlmndIkdGH1BzdG7gctSfMkdmmnliHe)UAXwauhctSfCcd45QNWqW5rMFYiDrYjNW0miQdbfQFXaxSiGj2kdmmnliHKW0miQdHj2coO1tnvgyyAwqcj(D1ITaOoeuO(fdCXIaMyRiwYAWiZhKo)k)8Eoq5zcXKNH48OkPjVb0LCEbbN3c48k0brE6TaprE0t)NQ5b7nCEfiyqEI3naEEq2emkVGWa5jxKN8emu77iVfLhyJ8MGnDqWI8k0bXsf5zG35jxKNA(18rVGP6fdT)pkzOxSWbTiNGTGGg)BVMDHHGZX8tgnn0pYAHJHHbr1eIPsvwKCHHGZrnAj2fRt08d(vcBDLBdIPkyO23bjKiNjytheSOAADr)kHTUYTbXufmu77qMFFPtY(SBkzGG05x5N3ZbkpWMNjetEfAToprZ5vOdIgKxqW5b4ph5bBWAOjpQHZJof6t5TG8W2zYRqhelvKNbENNCrEQ5xZh9cMQxm0()OKHEXch0ICc2ccAAOFK1chdddIQjetTbYaBW6zqwlCmmmiQMqmvbfYIEbf9Re26k3getvWqTVdz(9Loj7ZUPKbI8R5JEbt1lgA)FCimXwWHPnbp00q)WyO2W0CDacNFbIo6fu0VsyRRCBqmvbd1(oK5)J8R5JEbt1lgA)FK9eBdG7qCjQLmGGMg6hgd1gMMRdq48lq0rVGI(vcBDLBdIPkyO23Hm)FuKCWyO2W0CLAyxjQxuhVDOnSOxajKmLSw7cdbNJPoeuO(fdCtSiPh(LhPZVYppYxhe5HtQOjVgkpWg5zAeBI35jwattEudNh9lcyInVcDqKh((P8OkR5xZh9cMQxm0()4qqH6xmWflcyILMg6pmndI6qyITGdA9utLbgMMffHXqTHP56aeo)ceD0lOigfeuDElHT6XTqobBbrLQm)A(OxWu9IH2)hhctSfCcd4zAAOF5GrbbvhctSfCcd45kvzrOgor4qSK1G5HFsnTHPzquhkSGrquW5kdmmnlYVYppzxWZmLSpVjOGGYRqhe5P3cmkVsuV5xZh9cMQxm0()y5g9cOPH(XOGGQy6DfAQjQi28bjKa1WjchILSgmpaBWIesWOGGQZBjSvpUfYjyliQuLfjhgfeuDimXwWHPnbpvQssiXVRwSfa1HWeBbhM2e8urSK1G5HFYGfPZVMp6fmvVyO9)rm9Uchef6nnn0pgfeuDElHT6XTqobBbrLQm)A(OxWu9IH2)hXy0WOxnaonn0pgfeuDElHT6XTqobBbrLQm)A(OxWu9IH2)hHAeJP3vqtd9JrbbvN3syREClKtWwquPkZVMp6fmvVyO9)rd45jqM25nTMMg6hJccQoVLWw94wiNGTGOsvMFLFEFIHmkDKhKP1yM)vEqlkpQXW0CEDWsd5ppyVHZRqhe5H)wcB1tEluEFITGOMFnF0lyQEXq7)Jud76GLgAAOFmkiO68wcB1JBHCc2cIkvjjKa1WjchILSgmp8bSYV5x5NNC7zLrDW5rEzgg45j)A(OxWu5zyGNhA)F0VapdcKfSWbPnjMMg6Nbmc(7A0sSlwNK9zziROCWOGGQZBjSvpUfYjyliQuLfjNCeBu9lWZGazblCqAtIDyuiqnA)RgaVOCmF0lO6xGNbbYcw4G0MexBGds3WjcsibIsRDi2tyi4SlAj(b4ErvY(mPZVMp6fmvEgg45H2)hX07kClKliyhdyP300q)YXVRwSfa1HWeBbhM2e8uPkl63vl2cG68wcB1JBHCc2cIkvjjKa1WjchILSgmp8tgSYVMp6fmvEgg45H2)hHtzirBa3c5SNvgTbr(18rVGPYZWapp0()i06Pgw4SNvg1b7WytIMg6NCtjR1UWqW5yQdbfQFXa3elssM)piHeK1chdddIQjetTbYqhWI0fLJFxTylaQZBjSvpUfYjyliQuLfLdgfeuDElHT6XTqobBbrLQSidye83vbd1(oK5h2Gv(18rVGPYZWapp0()yjfQHE3a4omTnbnn0)uYATlmeCoM6qqH6xmWnXIKK5)dsibzTWXWWGOAcXuBGm0bSYVMp6fmvEgg45H2)hdc2rbWwkGWbTipttd9JrbbvrS)LMNXbTipxPkjHemkiOkI9V08moOf5zNFPabJQty(xpqgSYVMp6fmvEgg45H2)hrDzPMDnWnLMNZVMp6fmvEgg45H2)hlSiTagUboeplWaEMMg63VRwSfa15Te2Qh3c5eSfevelznyEGUKqcudNiCiwYAW8azK68R5JEbtLNHbEEO9)rjwArVDlKtt5BHtGytAOPH(zaJG)(b5bRIyuqq15Te2Qh3c5eSfevQY8R8Z7zXQf5b7yRSbWZJuPnjEYdAr5XFM9ubNhYaW58wuEVATopmkiOHM8AO8k3zAmnxZtUPlyVN8c078Inp4CKxqW5P3c8e553vl2cG8WSHf5TG8mySwByAopgWsnp18R5JEbtLNHbEEO9)reBLnaUdsBs8qtd9d1WjchILSgmpqwLUKqc5ixyi4Cujythe1sFidPgwKqsyi4Cujythe1sF8W)hWI0fjN5Jgg2XawQ55NmsibQHteoelznyK5JNlPjnjKqUWqW5OgTe7I1v6d3hWsgydwfjN5Jgg2XawQ55NmsibQHteoelznyKrEYJ0Ko)MFLFE4bB6Gip5AxTylaM8R5JEbtDc20bHZlgA)Fegd1gMMPbys8)qiCbbIhIvlObgttX)(D1ITaOoeMyl4egWZvpHHGZJdcz(OxGPL5NS6ZtxAEwW6sgLh5vd1gMMZVYppYRgOhI8AO8kW5ziopVvw2a45TG8(Kb8CEEcdbNNAEKxmK(DEym0I48GA0e5jmGNZRHYRaNhHbdNhyZt2gormHPFXO8WOI8(KHELhoHj2c51G8wKGr5fBEW5ipyhvzqH48OkZJCGnp6uBcgLNCBgBMgq6A(18rVGPobB6GW5fdT)pcJb6HGMg6NCYbgd1gMMRdHWfeiEiwTGesKtyAgevqdNiMW0VyuLbgMMffdtZGOkm0l3qyITqLbgMMfKUOFLWwx52GyQcgQ9DidzfLdIcWqlcoxLm0l3c5cc2jztWiNnJntdYVMp6fm1jytheoVyO9)XYD1oeplfYZ0aTihG)C8tgn8NdK5mPLce)Ydw0qE2vNh0IYdNWeBbjwlYJ28WjmXwycu)IZJcO5zYRaNNH48mSLkYl288wzEliVpzapNNNWqW5PMhSFG(DEfiyqEKQgiYJ8X2laptE9KNHTurEXMhIcK3sf18R5JEbtDc20bHZlgA)FCimXwqI1cAAOFgWi4VL5xEWQidye83vbd1(oK5NmyvuoWyO2W0CDieUGaXdXQff9Re26k3getvWqTVdziROGXOGGQqnq4kW2laptfXswdMhil)k)8KlYtEbbIhIvlM8GwuEmiyudGNhoHj2c59jd458R5JEbtDc20bHZlgA)Fegd1gMMPbys8)qiC(vcBDLBdIHgymnf)7xjS1vUniMQGHAFhY8)bTyuqq1HWeBbhM2e8uPkZVMp6fm1jytheoVyO9)rymuByAMgGjX)dHW5xjS1vUnigAGX0u8VFLWwx52GyQcgQ9DiZpSrtd97xyyGbI6R3O2a5xZh9cM6eSPdcNxm0()imgQnmntdWK4)Hq48Re26k3gednWyAk(3VsyRRCBqmvbd1(oE4NmAAOFymuByAUsnSRe1lQJ3o0gw0lO4uYATlmeCoM6qqH6xmWnXIKK5xE5x5N3NmGNZtqHAa88WFlHT6jVfLNHTWW5feiEiwTOMFnF0lyQtWMoiCEXq7)JdHj2coHb8mnn0pmgQnmnxhcHZVsyRRCBqmfjhmgQnmnxhcHliq8qSAbjKGrbbvN3syREClKtWwqurSK1GrMFYQFqcjtjR1UWqW5yQdbfQFXa3elssMF5v0VRwSfa15Te2Qh3c5eSfevelznyKHmyr68R8Z7jkeipelznObWZ7tgWZtEym0I48ccopOgorKhdetEnuE47NYRWciLipmopeBI351G8IwIR5xZh9cM6eSPdcNxm0()4qyITGtyapttd9dJHAdtZ1Hq48Re26k3getrOgor4qSK1G5b)UAXwauN3syREClKtWwqurSK1Gj)MFLFE4bB6GGf5b72WIEb5x5N3Zbkp8GnDq8imgOhI8meNhvjn5rnCE4eMylmbQFX5fBEymGH6ipi0kLxqW5vAZ0WW5HTaQjpdiYJu1arEKp2Eb4zOjpgggKxdLxbopdX5zrEs2NZtUip5rokGMNjpQPbWZJo1MGr5j3MXMPbKo)A(OxWuNGnDqWI)HWeBHjq9lMMg6NCyuqq1jythevQssibJccQcJb6HOsvs6Is2emYzZyZ0ahILSgm)Wk)k)8ivnOhI8SipyJ28KlYtEf6GyPI8(eEEpMN8OnVcDqK3NWZRqhe5HtqH6xmip6xeWeBEyuqq5rvMxS5zWSTiVzL48KlYtEfSj48MoOSOxWuZVMp6fm1jytheSG2)h9Mw7mF0lWP7jObys8pud6HGMg6hJccQoeuO(fdCXIaMyRuLf9Re26k3getvWqTVJh()i)k)8KB6zZBmioVyZdQb9qKNf5jpAZtUip5vOdI84pB(q)op5Lxyi4Cm18ihUjX5ztElvmTGZBc20brL05xZh9cM6eSPdcwq7)JEtRDMp6f409e0amj(hQb9qqtd9pLSw7cdbNJPoeuO(fdCtSiPF5v0VsyRRCBqmY8lV8R8ZJu1GEiYZI8KhT5jxKN8k0bXsf59jCAYJU0MxHoiY7t40KNbe5rh5vOdI8(eEEguWO8iVAGEiYVMp6fm1jytheSG2)h9Mw7mF0lWP7jObys8pud6HGMg63VsyRRCBqmvbd1(oE4NSNHCHPzqufmxYi3eilm4SuLbgMMffXOGGQWyGEiQuLKo)A(OxWuNGnDqWcA)FCiAyOPH(dtZGOcA4eXeM(fJQmWW0SOiIcWqlcoxJg82f7NBVdtBcU4uYATlmeCoM6qqH6xmWnXIKEGU5x5NhSxzEXMhSLxyi4Cm59I5Y8OkZJu1arEKp2Eb4zYd7DE(3EDdGNhoHj2ctG6xCn)A(OxWuNGnDqWcA)FCimXwycu)IPX)2Rzxyi4Cm)Krtd9lymkiOkudeUcS9cWZurSK1G5bYkoLSw7cdbNJPoeuO(fdCtSiPh(HTIHHGZrnAj2fRt08ZGyjRbJm0r(v(5rQwuELOErD8op0gw0lGM8OgopCctSfMa1V48wyyuE4XIKYRqhe5r(OtZZGBnyI8OkZl28KxEHHGZXK3IYRHYJur(YRN8quaqdGN3cbLh5wqEg4DEM0sbI8wO8cdbNJH05xZh9cM6eSPdcwq7)JdHj2ctG6xmnn0pmgQnmnxPg2vI6f1XBhAdl6fuKCcgJccQc1aHRaBVa8mvelznyEGmsijmndIAb2kxGKnbJQmWW0SO4uYATlmeCoM6qqH6xmWnXIKE4xEKo)A(OxWuNGnDqWcA)FCiOq9lg4Myrs00q)tjR1UWqW5yK5h2OLCyuqq1GGDOncguPkjHeefGHweCUAVmd1JBwkTdczWLyqu0VabvhvbZLmYjm4Wz0urg4Lm)ppPlsomkiO68wcB1JBHCc2ccNrfRh1rLQKesKdgfeuTeXsSOdl6fuPkjHKPK1Axyi4CmY8txsNFLFE4eMylmbQFX5fBEigcXdrEKQgiYJ8X2laptEgqKxS5XGHcX5vGZZBG88gc9oVfggLNLheLwNhPI8LxdInVGGZdWFoYdF)uEnuEL7mnMMR5xZh9cM6eSPdcwq7)JdHj2ctG6xmnn0VGXOGGQqnq4kW2laptfXswdMh(jJes87QfBbqDElHT6XTqobBbrfXswdMhiJuxuWyuqqvOgiCfy7fGNPIyjRbZd(D1ITaOoVLWw94wiNGTGOIyjRbt(18rVGPobB6GGf0()iC9UsyAtW00q)yuqq1sgbTilyHdgUbtDcZ)sMF6w0Vabvh1sgbTilyHdgUbtfzGxY8tgSLFnF0lyQtWMoiybT)poeMylmbQFX538R8ZJu1GEiy0KFLFEKpIwZ5rnnaEEKhelXIoSOxan5zWSTipVnrdGNhUU9CEgqK3NApNxbcgKhoHj2c59jd4586jVzxqEXMhgNh1WcAYJ)SNlJ8GwuEW((g1gi)A(OxWuHAqpe)WyO2W0mnatI)lrSelCdq48lq0rVaAGX0u8FyAge1selXIoSOxqLbgMMffNswRDHHGZX8a5O7Z4xyyGbIkG9OvVibPlkh)cddmquF9g1gi)A(OxWuHAqpe0()4OBp7mGWjApttd9lhymuByAUwIyjw4gGW5xGOJEbfNswRDHHGZXuhcku)IbUjwK0d0rr5GrbbvhctSfCcd45kvzrmkiO6OBp7mGWjApxrSK1G5bOgor4qSK1GPiIHq8qyyAo)A(OxWuHAqpe0()4OBp7mGWjApttd9dJHAdtZ1selXc3aeo)ceD0lOOFxTylaQdHj2coHb8C1tyi484GqMp6fy6hiR(80TigfeuD0TNDgq4eTNRiwYAW8GFxTylaQZBjSvpUfYjyliQiwYAWuKC(D1ITaOoeMyl4egWZveBI3fXOGGQZBjSvpUfYjyliQiwYAW8myuqq1HWeBbNWaEUIyjRbZdKv)G05xZh9cMkud6HG2)hHXqTHPzAaMe)pV6shIQmOqmnWyAk(xYMGroBgBMg4qSK1GrgyrcjYjmndIkOHtety6xmQYadtZIIHPzqufg6LBimXwOYadtZIIyuqq1HWeBbNWaEUsvscjtjR1UWqW5yQdbfQFXa3elssMF6GMNfSUKr5rE1qTHP58GwuEWoQYGcX18WF1L5jOqnaEE0P2emkp52m2mniVfLNGc1a459jd458k0brEFYqVYZaI8aBEY2WjIjm9lgvZVYppyFzUmpQY8GDuLbfIZRHYRJ86jpdBPI8InpefiVLkQ5xZh9cMkud6HG2)hruLbfIPPH(LdmgQnmnxNxDPdrvguiUyyi4CuJwIDX6en)miwYAWidDueXqiEimmnNFnF0lyQqnOhcA)FCypIdxWEcqtNqX5x5NhDkLoAXgrdGNxyi4Cm5fewKxHwRZt3WW5bTO8ccopbfYIEb5Tq5b7OkdkeNhIHq8qKNGc1a45vAabl1(A(18rVGPc1GEiO9)revzqHyA8V9A2fgcohZpz00q)Ybgd1gMMRZRU0HOkdkexuoWyO2W0CLAyxjQxuhVDOnSOxqXPK1Axyi4Cm1HGc1VyGBIfjjZ)hfddbNJA0sSlwNOzz(jhDPLCFqN9Re26k3gedPjDredH4HWW0C(v(5b7yiepe5b7OkdkeNhBi978AO86iVcTwNh)5YgX5jOqnaEE4VLWw9uZ7tBEbHf5Hyiepe51q5HVFkp4Cm5Hyt8oVgKxqW5b4ph5r3PMFnF0lyQqnOhcA)FervguiMMg6xoWyO2W0CDE1LoevzqH4IiwYAW8GFxTylaQZBjSvpUfYjyliQiwYAWqlzWQOFxTylaQZBjSvpUfYjyliQiwYAW8WpDlggcoh1OLyxSorZpdILSgmY43vl2cG68wcB1JBHCc2cIkILSgm0s38R5JEbtfQb9qq7)JyAZ)YvUfemIMg6xoWyO2W0CLAyxjQxuhVDOnSOxqXPK1Axyi4CmY8dB5xZh9cMkud6HG2)hzy6XZil48B(v(59evRfmAYVMp6fmvmQwl(hIggAAOF5eMMbrf0WjIjm9lgvzGHPzrrefGHweCUgn4Tl2p3EhM2eCXPK1Axyi4Cm1HGc1VyGBIfj9aDZVMp6fmvmQwlO9)XHGc1VyGBIfjrtd9pLSw7cdbNJrM)pYVMp6fmvmQwlO9)XHrilyHdBbSBk7xmnn0VFxTylaQdJqwWch2cy3u2V4QNWqW5XbHmF0lW0Y8)r95PljKmlLgRbIQMnHd7TJ)SjvQ5kdmmnlkkhmkiOQMnHd7TJ)SjvQ5kvz(18rVGPIr1AbT)pcxVReM2eC(18rVGPIr1AbT)pIz(xtyyQqfkf]] )

    
end
