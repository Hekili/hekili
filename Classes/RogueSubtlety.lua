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


    spec:RegisterPack( "Subtlety", 20201206, [[defDTbqiIkEervTjvWNaL0Oqu5uisTkKkQxHuAwif3sfk2LK(LeQHbk1XquwMkHNPsutJOkxdPsBdrIVHuHghIK6CisI1HubZtc5EQu7JO4Fiss4GevklufYdjQKjQcvxervrBerv8rKkIrQcLWjvHsTsvsVerssZuLiCtKks7KO0prKKAOiQslvLi9uOAQivDvvIOTIOQWxruvnwIkvNfrsI2lj)LkdwvhMYIHYJPQjt4YO2miFgunAeoTuRwfkrVwfz2K62ez3a)wXWLOJJOQ0YH8CLMUW1rY2bfFxcgpOeNxf16vHsA(iI9lAfzk6v4clyLSxa7lGnzxaBsPEbSLhPq3lu4X5swHxA(tgCwHdmjwHJtHfAooRWlTZ6Xek6v47qH8ScNiIYLouCXW7GGcR6hPI3wIsBrpapYGII3wYxSchJQ1XXgOWu4clyLSxa7lGnzxaBsPEbSLhPipsffUrfedsHJ3sYLcNOfcgOWu4cE9kC5NpofwO54C(x6aNIZRYp)JZEwcJr5tk0K)fW(cyRW19gRIEf(gSPdcwOOxjlzk6v4mWW0SqDKc3J6GrTPWjx(yuqq1nythevQY8jHK8XOGGQWyGEjQuL5tAfU5JEak8LWetHnq9jwfkzVqrVcNbgMMfQJu4EuhmQnfogfeuDjOq9jg4IbbmXuPkZ)q((rcBCLtdITkyO23r(fDN)fkCZh9au4EtRDMp6b409gkCDVHdysSchQb9sOcLSxwrVcNbgMMfQJu4EuhmQnf(wYATlmeCo26sqH6tmWTXGKY)oF5L)H89Je24kNgeB(YCNV8u4Mp6bOW9Mw7mF0dWP7nu46EdhWKyfoud6LqfkzLNIEfodmmnluhPW9OoyuBkC)iHnUYPbXwfmu77i)IUZNS8pM8jx(HPzqufmxYi3gilm4SuLbgMMf5FiFmkiOkmgOxIkvz(KwHB(OhGc3BATZ8rpaNU3qHR7nCatIv4qnOxcvOKLUk6v4mWW0SqDKc3J6GrTPWdtZGOcA4eXgM(eJQmWW0Si)d5JOam0GGZ1ObNDXalT3HPnbxzGHPzr(hYFlzT2fgcohBDjOq9jg42yqs5xu(0vHB(OhGcFjAyuHswsrrVcNbgMMfQJu4Mp6bOWxctmf2a1NyfUh1bJAtHlymkiOkudeUcSDcW7wrSK1Gn)IYNS8pK)wYATlmeCo26sqH6tmWTXGKYVO78VC(hYpmeCoQrlXUyCIMZ)yYhXswd28LjFsrH7p71SlmeCowLSKPcLS0rf9kCgyyAwOosH7rDWO2u4WyO2W0CLAzxjQhuhNDOjSOhq(hYNC5lymkiOkudeUcSDcW7wrSK1Gn)IYNS8jHK8dtZGOwGTYbizBWOkdmmnlY)q(BjR1UWqW5yRlbfQpXa3gdsk)IUZxE5tAfU5JEak8LWetHnq9jwfkzj1k6v4mWW0SqDKc3J6GrTPW3swRDHHGZXMVm35F58PnFYLpgfeuniyhAIGbvQY8jHK8ruagAqW5QDYmuVUDO0oiKbxIbrLbgMMf5FiF)aeuDufmxYiNWGdNrBfzGt5lZD(0X8jD(hYNC5Jrbbv3ZsyJEDdKtWwq4mQy8OoQuL5tcj5lN8XOGGQLiwIfDyrpGkvz(Kqs(BjR1UWqW5yZxM78PB(KwHB(OhGcFjOq9jg42yqsQqjlPIIEfodmmnluhPW9OoyuBkCbJrbbvHAGWvGTtaE3kILSgS5x0D(KLpjKKVFgTykaQ7zjSrVUbYjyliQiwYAWMFr5tgPo)d5lymkiOkudeUcSDcW7wrSK1Gn)IY3pJwmfa19Se2Ox3a5eSfevelznyv4Mp6bOWxctmf2a1NyvOKLmyROxHZadtZc1rkCpQdg1MchJccQwYiObzblCWWnyRBy(t5lZD(0n)d57hGGQJAjJGgKfSWbd3GTImWP8L5oFYUSc38rpafoC9msyAtWQqjlzKPOxHB(OhGcFjmXuyduFIv4mWW0SqDKkuHcN3LbEEv0RKLmf9kCgyyAwOosH7rDWO2u4mGrWpxJwIDX4KmyjFzYNS8pKVCYhJccQUNLWg96giNGTGOsvM)H8jx(YjFXev)a8miqwWchK2KyhgfcuJ2FQbWZ)q(YjFZh9aQ(b4zqGSGfoiTjX1g4G0nCIiFsijFikT2HypHHGZUOL48lkF4ErvYGL8jTc38rpafUFaEgeilyHdsBsSkuYEHIEfodmmnluhPW9OoyuBkC5KVFgTykaQlHjMcomTj4TsvM)H89ZOftbqDplHn61nqobBbrLQmFsijFOgor4qSK1Gn)IUZNmyRWnF0dqHJPNr4gixqWogWsNvHs2lROxHB(OhGchoLHeTbCdKZowz0eekCgyyAwOosfkzLNIEfodmmnluhPW9OoyuBkCYL)wYATlmeCo26sqH6tmWTXGKYxM78ViFsijFK1chdddIQjeBTb5lt(KcSZN05FiF5KVFgTykaQ7zjSrVUbYjyliQuL5FiF5KpgfeuDplHn61nqobBbrLQm)d5Zagb)CvWqTVJ8L5o)ldBfU5JEakCOXtTSWzhRmQd2HXMKkuYsxf9kCgyyAwOosH7rDWO2u4BjR1UWqW5yRlbfQpXa3gdskFzUZ)I8jHK8rwlCmmmiQMqS1gKVm5tkWwHB(OhGcVKc1qNBaChM22qfkzjff9kCgyyAwOosH7rDWO2u4yuqqve7pP5DDqdYZvQY8jHK8XOGGQi2FsZ76GgKND(HcemQUH5pLFr5tgSv4Mp6bOWdc2rbWgkGWbnipRcLS0rf9kCZh9au4OUSuZUg42sZZkCgyyAwOosfkzj1k6v4mWW0SqDKc3J6GrTPW9ZOftbqDplHn61nqobBbrfXswd28lkF6MpjKKpudNiCiwYAWMFr5tgPwHB(OhGcVWG0cy4g4q8oad4zvOKLurrVcNbgMMfQJu4EuhmQnfodye8Z5xu(Yd25FiFmkiO6EwcB0RBGCc2cIkvPc38rpafUelnOZUbYPP8TWjqSjTQqjlzWwrVcNbgMMfQJu4EuhmQnfoudNiCiwYAWMFr5twLU5tcj5tU8jx(HHGZrLGnDqul9r(YKpPg25tcj5hgcohvc20brT0h5x0D(xa78jD(hYNC5B(OHHDmGLAEZ)oFYYNesYhQHteoelznyZxM8VGujFsNpPZNesYNC5hgcoh1OLyxmUsF4Ua25lt(xg25FiFYLV5Jgg2XawQ5n)78jlFsijFOgor4qSK1GnFzYxEYlFsNpPv4Mp6bOWrSv2a4oiTjXRkuHcxWqgLou0RKLmf9kCZh9au4NA)jfodmmnluhPcLSxOOxHZadtZc1rk8PuHVCOWnF0dqHdJHAdtZkCymnfRWXOGGQRU9SZacNO9CLQmFsij)TK1Axyi4CS1LGc1NyGBJbjLVm35tkkCymKdysScFbcNFaIo6bOcLSxwrVcNbgMMfQJu4Mp6bOW9Mw7mF0dWP7nu46EdhWKyfUxSQqjR8u0RWzGHPzH6ifUh1bJAtHVbB6GGfvtRv4Mp6bOWruaN5JEaoDVHcx3B4aMeRW3GnDqWcvOKLUk6v4mWW0SqDKc3J6GrTPW3swRDHHGZXwxckuFIbUngKu(fLpPK)H8HA4eHdXswd28LjFsj)d5JrbbvxD7zNbeor75kILSgS5xu(W9IQKbl5FiF)iHnUYPbXMVm35lV8pM8jx(rlX5xu(Kb78jD(058VqHB(OhGcF1TNDgq4eTNvHswsrrVcNbgMMfQJu4tPcF5qHB(OhGchgd1gMMv4WyAkwHxI6b1XzhAcl6bK)H83swRDHHGZXwxckuFIbUngKu(YCN)fkCymKdysScNAzxjQhuhNDOjSOhGkuYshv0RWzGHPzH6ifUh1bJAtHdJHAdtZvQLDLOEqDC2HMWIEakCZh9au4EtRDMp6b409gkCDVHdysScFd20bHZlwvOKLuROxHZadtZc1rk8PuHVCOWnF0dqHdJHAdtZkCymnfRWVGU5tB(HPzquHPHpOkdmmnlYNoN)fWoFAZpmndIQKTbJCdKBjmXuyRmWW0SiF6C(xa78Pn)W0miQlHjMcoOXtTvgyyAwKpDo)lOB(0MFyAgevtBEuhNRmWW0SiF6C(xa78Pn)lOB(058jx(BjR1UWqW5yRlbfQpXa3gdskFzUZxE5tAfomgYbmjwHVbB6GWfeiEjgTqfkzjvu0RWzGHPzH6ifUh1bJAtHZagb)CvWqTVJ8l6oFymuByAUUbB6GWfeiEjgTqHB(OhGc3BATZ8rpaNU3qHR7nCatIv4BWMoiCEXQcLSKbBf9kCgyyAwOosH7rDWO2u4(rcBCLtdIn)78nqlzEcdbNfoFPc38rpafU30AN5JEaoDVHcx3B4aMeRWHAqVeQqjlzKPOxHZadtZc1rkCpQdg1Mc3psyJRCAqSvbd1(oYVO78jlFsijFOgor4qSK1Gn)IUZNS8pKVFKWgx50GyZxM78VC(Kqs(yuqq19Se2Ox3a5eSfeoJkgpQJkvz(hY3psyJRCAqS5lZD(YtHB(OhGc3BATZ8rpaNU3qHR7nCatIv4qnOxcvOKLSlu0RWzGHPzH6ifUh1bJAtHVLSw7cdbNJTUeuO(edCBmiP8L5oF5L)H89Je24kNgeB(YCNV8u4Mp6bOW9Mw7mF0dWP7nu46EdhWKyfoud6Lqfkzj7Yk6v4mWW0SqDKc3J6GrTPWzaJGFUkyO23r(fDNpmgQnmnx3GnDq4cceVeJwOWnF0dqH7nT2z(OhGt3BOW19goGjXkCmQwluHswYKNIEfodmmnluhPW9OoyuBkCgWi4NRcgQ9DKVm35tgDZN28zaJGFUIy4mqHB(OhGc3qEdWUyqigeQqjlz0vrVc38rpafUH8gGDLu6Lv4mWW0SqDKkuYsgPOOxHB(OhGcx3WjI1DSKsaxIbHcNbgMMfQJuHswYOJk6v4Mp6bOWXm4UbYfO2FAv4mWW0SqDKkuHcVeX(rcZcf9kzjtrVc38rpafUvwQp7kNEhGcNbgMMfQJuHs2lu0RWnF0dqHVbB6GqHZadtZc1rQqj7Lv0RWzGHPzH6ifU5JEakCjdDIfoOb5eSfek8se7hjmlCl7hGyv4KrxvOKvEk6v4mWW0SqDKc38rpaf(QBp7mGWjApRW9OoyuBkCedH4LWW0ScVeX(rcZc3Y(biwfozQqjlDv0RWzGHPzH6ifUh1bJAtHJOam0GGZvjdDYnqUGGDs2gmYz7A72Gkdmmnlu4Mp6bOWxctmfCyAtWRkuHchJQ1cf9kzjtrVcNbgMMfQJu4EuhmQnfUCYpmndIkOHteBy6tmQYadtZI8pKpIcWqdcoxJgC2fdS0EhM2eCLbgMMf5Fi)TK1Axyi4CS1LGc1NyGBJbjLFr5txfU5JEak8LOHrfkzVqrVcNbgMMfQJu4EuhmQnf(wYATlmeCo28L5o)lu4Mp6bOWxckuFIbUngKKkuYEzf9kCgyyAwOosH7rDWO2u4(z0IPaOUmczblCydGDBzFIREcdbNxheY8rpatNVm35FrLos38jHK83HsJ1arvZMWHD2XWIjvQ5kdmmnlY)q(YjFmkiOQMnHd7SJHftQuZvQsfU5JEak8LrilyHdBaSBl7tSkuYkpf9kCZh9au4W1ZiHPnbRWzGHPzH6ivOKLUk6v4Mp6bOWXm)PnmmfodmmnluhPcvOW9IvrVswYu0RWzGHPzH6ifUh1bJAtHlN8XOGGQlHjMcoHb8CLQm)d5JrbbvxckuFIbUyqatmvQY8pKpgfeuDjOq9jg4IbbmXurSK1Gn)IUZ)Yv6QWnF0dqHVeMyk4egWZkCQLDdeKdUxOKLmvOK9cf9kCgyyAwOosH7rDWO2u4yuqq1LGc1NyGlgeWetLQm)d5JrbbvxckuFIbUyqatmvelznyZVO78VCLUkCZh9au47zjSrVUbYjyliu4ul7giihCVqjlzQqj7Lv0RWzGHPzH6ifUh1bJAtHdJHAdtZ1fiC(bi6Ohq(hYxo5VbB6GGfvjdeAwHB(OhGchsBWzT2IEaQqjR8u0RWzGHPzH6ifUh1bJAtHlymkiOkK2GZATf9aQiwYAWMFr5FHc38rpafoK2GZATf9aCEnBGLvHsw6QOxHZadtZc1rkCpQdg1McNC5JOam0GGZvjdDYnqUGGDs2gmYz7A72GkdmmnlY)q((rcBCLtdITkyO23r(fDN)LZNesYhrbyObbNRc2cc9z3syIPWwzGHPzr(hY3psyJRCAqS5xu(KLpPZ)q(yuqq19Se2Ox3a5eSfevQY8pKpgfeuDjmXuWjmGNRuL5FiFjBdg5SDTDBGdXswd28VZh25FiFmkiOQGTGqF2TeMykSvXuaOWnF0dqHdJb6Lqfkzjff9kCgyyAwOosHB(OhGcVCgTdX7qH8Sc3J6GrTPWdtZGOUeuO(edCXGaMyQmWW0Si)d5lN8dtZGOUeMyk4Ggp1wzGHPzHchAqoadlHswYuHsw6OIEfodmmnluhPW9OoyuBkCgWi4NZxM78jfyN)H8HXqTHP56ceo)aeD0di)d57NrlMcG6EwcB0RBGCc2cIkvz(hY3pJwmfa1LWetbNWaEU6jmeCEZxM78jtHB(OhGcFjOq9jg4IbbmXOcLSKAf9kCgyyAwOosHB(OhGcFzeYcw4Wga72Y(eRW9OoyuBkCymuByAUUaHZparh9aY)q(YjFXe1LrilyHdBaSBl7tStmrnA)Pgap)d5hgcoh1OLyxmorZ5lZD(xqw(Kqs(qnCIWHyjRbB(fDNpDZ)q(BjR1UWqW5yRlbfQpXa3gdsk)IY)YkC)zVMDHHGZXQKLmvOKLurrVcNbgMMfQJu4EuhmQnfomgQnmnxxGW5hGOJEa5FiF)iHnUYPbXwfmu77iFzUZNmfU5JEak8Ll3EvHswYGTIEfodmmnluhPW9OoyuBkCymuByAUUaHZparh9aY)q(Kl)W0miQmagwpLnaUBjmXuyRmWW0SiFsijF)mAXuauxctmfCcd45QNWqW5nFzUZNS8jD(hYNC5lN8dtZGOUeuO(edCXGaMyQmWW0SiFsij)W0miQlHjMcoOXtTvgyyAwKpjKKVFgTykaQlbfQpXaxmiGjMkILSgS5lt(xKpPv4Mp6bOW3ZsyJEDdKtWwqOcLSKrMIEfodmmnluhPWnF0dqHlzOtSWbniNGTGqH7rDWO2u4iRfogggevti2kvz(hYNC5hgcoh1OLyxmorZ5xu((rcBCLtdITkyO23r(Kqs(Yj)nytheSOAAD(hY3psyJRCAqSvbd1(oYxM789LojdwCBjde5tAfU)SxZUWqW5yvYsMkuYs2fk6v4mWW0SqDKc3J6GrTPWrwlCmmmiQMqS1gKVm5FzyN)XKpYAHJHHbr1eITkOqw0di)d57hjSXvoni2QGHAFh5lZD((sNKblUTKbcfU5JEakCjdDIfoOb5eSfeQqjlzxwrVcNbgMMfQJu4EuhmQnfomgQnmnxxGW5hGOJEa5FiF)iHnUYPbXwfmu77iFzUZ)cfU5JEak8LWetbhM2e8QcLSKjpf9kCgyyAwOosH7rDWO2u4WyO2W0CDbcNFaIo6bK)H89Je24kNgeBvWqTVJ8L5o)lY)q(KlFymuByAUsTSRe1dQJZo0ew0diFsij)TK1Axyi4CS1LGc1NyGBJbjLFr35lV8jTc38rpafo7jMga3H4sulzaHkuYsgDv0RWzGHPzH6ifUh1bJAtHhMMbrDjmXuWbnEQTYadtZI8pKpmgQnmnxxGW5hGOJEa5FiFmkiO6EwcB0RBGCc2cIkvPc38rpaf(sqH6tmWfdcyIrfkzjJuu0RWzGHPzH6ifUh1bJAtHlN8XOGGQlHjMcoHb8CLQm)d5d1WjchILSgS5x0D(K68Pn)W0miQlfwWiik4CLbgMMfkCZh9au4lHjMcoHb8SkuYsgDurVcNbgMMfQJu4EuhmQnfogfeuftpJqtTrfXMpYNesYhQHteoelznyZVO8VmSZNesYhJccQUNLWg96giNGTGOsvM)H8jx(yuqq1LWetbhM2e8wPkZNesY3pJwmfa1LWetbhM2e8wrSK1Gn)IUZNmyNpPv4Mp6bOWlNOhGkuYsgPwrVcNbgMMfQJu4EuhmQnfogfeuDplHn61nqobBbrLQuHB(OhGchtpJWbrHoRcLSKrQOOxHZadtZc1rkCpQdg1MchJccQUNLWg96giNGTGOsvQWnF0dqHJXOLrNAaCvOK9cyROxHZadtZc1rkCpQdg1MchJccQUNLWg96giNGTGOsvQWnF0dqHd1igtpJqfkzVGmf9kCgyyAwOosH7rDWO2u4yuqq19Se2Ox3a5eSfevQsfU5JEakCd45nqM25nTwfkzV4cf9kCgyyAwOosH7rDWO2u4yuqq19Se2Ox3a5eSfevQY8jHK8HA4eHdXswd28lk)lGTc38rpafo1YUoyPvfQqHVbB6GW5fRIELSKPOxHZadtZc1rk8PuHVCOWnF0dqHdJHAdtZkCymnfRW9ZOftbqDjmXuWjmGNREcdbNxheY8rpatNVm35twLosxfomgYbmjwHVecxqG4Ly0cvOK9cf9kCgyyAwOosH7rDWO2u4KlF5KpmgQnmnxxcHliq8smAr(Kqs(Yj)W0miQGgorSHPpXOkdmmnlY)q(HPzqufg6KBjmXuOYadtZI8jD(hY3psyJRCAqSvbd1(oYxM8jl)d5lN8ruagAqW5QKHo5gixqWojBdg5SDTDBqLbgMMfkCZh9au4WyGEjuHs2lROxHZadtZc1rkCZh9au4LZODiEhkKNv4mSeiZzsdfiu4Yd2kCOb5amSekzjtfkzLNIEfodmmnluhPW9OoyuBkCgWi4NZxM78LhSZ)q(mGrWpxfmu77iFzUZNmyN)H8Lt(WyO2W0CDjeUGaXlXOf5FiF)iHnUYPbXwfmu77iFzYNS8pKVGXOGGQqnq4kW2jaVBfXswd28lkFYu4Mp6bOWxctmfKyTqfkzPRIEfodmmnluhPWNsf(YHc38rpafomgQnmnRWHX0uSc3psyJRCAqSvbd1(oYxM78ViFAZhJccQUeMyk4W0MG3kvPchgd5aMeRWxcHZpsyJRCAqSQqjlPOOxHZadtZc1rk8PuHVCOWnF0dqHdJHAdtZkCymnfRW9Je24kNgeBvWqTVJ8L5o)lRW9OoyuBkC)addmqupDg1gqHdJHCatIv4lHW5hjSXvoniwvOKLoQOxHZadtZc1rk8PuHVCOWnF0dqHdJHAdtZkCymnfRW9Je24kNgeBvWqTVJ8l6oFYu4EuhmQnfomgQnmnxPw2vI6b1XzhAcl6bK)H83swRDHHGZXwxckuFIbUngKu(YCNV8u4WyihWKyf(siC(rcBCLtdIvfkzj1k6v4mWW0SqDKc3J6GrTPWHXqTHP56siC(rcBCLtdIn)d5tU8HXqTHP56siCbbIxIrlYNesYhJccQUNLWg96giNGTGOIyjRbB(YCNpz1lYNesYFlzT2fgcohBDjOq9jg42yqs5lZD(Yl)d57NrlMcG6EwcB0RBGCc2cIkILSgS5lt(Kb78jTc38rpaf(syIPGtyapRcLSKkk6v4mWW0SqDKc3J6GrTPWHXqTHP56siC(rcBCLtdIn)d5d1WjchILSgS5xu((z0IPaOUNLWg96giNGTGOIyjRbRc38rpaf(syIPGtyapRcvOWHAqVek6vYsMIEfodmmnluhPWNsf(YHc38rpafomgQnmnRWHX0uScpmndIAjILyrhw0dOYadtZI8pK)wYATlmeCo28lkFYLpDZ)yY3pWWadeva7rJEqI8jD(hYxo57hyyGbI6PZO2akCymKdysScVeXsSWTaHZparh9auHs2lu0RWzGHPzH6ifUh1bJAtHlN8HXqTHP5AjILyHBbcNFaIo6bK)H83swRDHHGZXwxckuFIbUngKu(fLpPK)H8Lt(yuqq1LWetbNWaEUsvM)H8XOGGQRU9SZacNO9CfXswd28lkFOgor4qSK1Gn)d5JyieVegMMv4Mp6bOWxD7zNbeor7zvOK9Yk6v4mWW0SqDKc3J6GrTPWHXqTHP5AjILyHBbcNFaIo6bK)H89ZOftbqDjmXuWjmGNREcdbNxheY8rpatNFr5twLos38pKpgfeuD1TNDgq4eTNRiwYAWMFr57NrlMcG6EwcB0RBGCc2cIkILSgS5FiFYLVFgTykaQlHjMcoHb8CfXM4C(hYhJccQUNLWg96giNGTGOIyjRbB(ht(yuqq1LWetbNWaEUIyjRbB(fLpz1lYN0kCZh9au4RU9SZacNO9SkuYkpf9kCgyyAwOosHpLk8LdfU5JEakCymuByAwHdJPPyfUKTbJC2U2UnWHyjRbB(YKpSZNesYxo5hMMbrf0WjInm9jgvzGHPzr(hYpmndIQWqNClHjMcvgyyAwK)H8XOGGQlHjMcoHb8CLQmFsij)TK1Axyi4CS1LGc1NyGBJbjLVm35tkkCymKdysScFp1LoevzqHyvOKLUk6v4mWW0SqDKc3J6GrTPWLt(WyO2W0CDp1LoevzqH48pKFyi4CuJwIDX4enN)XKpILSgS5lt(Ks(hYhXqiEjmmnRWnF0dqHJOkdkeRcLSKIIEfU5JEak8L9ioCb7jan5lfRWzGHPzH6ivOKLoQOxHZadtZc1rkCZh9au4iQYGcXkCpQdg1Mcxo5dJHAdtZ19ux6quLbfIZ)q(YjFymuByAUsTSRe1dQJZo0ew0di)d5VLSw7cdbNJTUeuO(edCBmiP8L5o)lY)q(HHGZrnAj2fJt0C(YCNp5YNU5tB(Kl)lYNoNVFKWgx50GyZN05t68pKpIHq8syyAwH7p71SlmeCowLSKPcLSKAf9kCgyyAwOosH7rDWO2u4YjFymuByAUUN6shIQmOqC(hYhXswd28lkF)mAXuau3ZsyJEDdKtWwqurSK1GnFAZNmyN)H89ZOftbqDplHn61nqobBbrfXswd28l6oF6M)H8ddbNJA0sSlgNO58pM8rSK1GnFzY3pJwmfa19Se2Ox3a5eSfevelznyZN28PRc38rpafoIQmOqSkuYsQOOxHZadtZc1rkCpQdg1Mcxo5dJHAdtZvQLDLOEqDC2HMWIEa5Fi)TK1Axyi4CS5lZD(xwHB(OhGchtB(tUYPGGrQqjlzWwrVc38rpafodtVEgzbRWzGHPzH6ivOcvOWHHrBpaLSxa7lGnzxaBYu4fmeObWxfo5xUDPYESLLoHoKF(0tW53sLdkYhAq5dRBWMoiybSMpIjFPAelYFhjoFJkgjlyr(EcdaN3AE9s0aoF6shYxUgammkyr(WkIcWqdcoxL7WA(XKpSIOam0GGZv5ELbgMMfWA(KJmyH0186LObC(KA6q(Y1aGHrblYhwruagAqW5QChwZpM8HvefGHgeCUk3RmWW0SawZNCKblKUMxPNGZhA06PqdGNVrHSn)cmIZNAzr(ni)GGZ38rpG819g5Jrf5xGrC(GjYhAOaI8Bq(bbNVjediFHfgMTmDiVM)XK)EwcB0RBGCc2ccNrfJh1rEnVs(LBxQShBzPtOd5Np9eC(Tu5GI8Hgu(WQGHmkDaR5JyYxQgXI83rIZ3OIrYcwKVNWaW5TMxPNGZhA06PqdGNVrHSn)cmIZNAzr(ni)GGZ38rpG819g5Jrf5xGrC(GjYhAOaI8Bq(bbNVjediFHfgMTmDiVM)XK)EwcB0RBGCc2ccNrfJh1rEnVs(LBxQShBzPtOd5Np9eC(Tu5GI8Hgu(WAjI9JeMfWA(iM8LQrSi)DK48nQyKSGf57jmaCER51lrd48PlDiF5AaWWOGf5dRikadni4CvUdR5ht(WkIcWqdcoxL7vgyyAwaR5Br(KpjvFjYNCKblKUMxZRKF52Lk7Xww6e6q(5tpbNFlvoOiFObLpSIr1AbSMpIjFPAelYFhjoFJkgjlyr(EcdaN3AE9s0aoFYOd5lxdaggfSiFyfrbyObbNRYDyn)yYhwruagAqW5QCVYadtZcynFYrgSq6AEnVs(LBxQShBzPtOd5Np9eC(Tu5GI8Hgu(WQxSWA(iM8LQrSi)DK48nQyKSGf57jmaCER51lrd48PlDiF5AaWWOGf5dRikadni4CvUdR5ht(WkIcWqdcoxL7vgyyAwaR5tUlGfsxZR5vYVC7sL9yllDcDi)8PNGZVLkhuKp0GYhw3GnDq48IfwZhXKVunIf5VJeNVrfJKfSiFpHbGZBnVEjAaN)f0H8LRbadJcwKpSIOam0GGZv5oSMFm5dRikadni4CvUxzGHPzbSMVf5t(Ku9LiFYrgSq6AEnVESLkhuWI8j15B(Ohq(6EJTMxv4Bj7vYEbPqMcVenqTMv4YpFCkSqZX58V0bofNxLF(hN9SegJYNuOj)lG9fWoVMxLF(KxeFmY1iHzrE18rpGTwIy)iHzbT3fBLL6ZUYP3bKxnF0dyRLi2psywq7DXBWMoiYRMp6bS1se7hjmlO9UyjdDIfoOb5eSfe0uIy)iHzHBz)ae7nz0nVA(OhWwlrSFKWSG27IxD7zNbeor7zAkrSFKWSWTSFaI9MmAAOBedH4LWW0CE18rpGTwIy)iHzbT3fVeMyk4W0MGxAAOBefGHgeCUkzOtUbYfeStY2GroBxB3gKxZRYpF6uRb5FPtyrpG8Q5JEa79P2FkVk)8VKllYpM8fCWiPgW5xGGdcgLVFgTyka28lyDKp0GYhhC88XSLf5pG8ddbNJTMxnF0dyP9UyymuByAMgGjX3lq48dq0rpaAGX0u8ngfeuD1TNDgq4eTNRuLKqYwYATlmeCo26sqH6tmWTXGKK5MuYRYpF5IG9NYxUo(MVf5d1OnYRMp6bS0ExS30AN5JEaoDVbnatIV9InVk)8Vukq(quA9583cD4j4n)yYpi48Xd20bblY)sNWIEa5toSZ5lMgap)DOPJ8HgKN38lNr3a453q5dMGObWZV38nySwByAM018Q5JEalT3fJOaoZh9aC6EdAaMeFVbB6GGf00q3BWMoiyr1068Q8ZxUvwQpN)QBp7mGWjApNVf5FbT5lxK38fuOgap)GGZhQrBKpzWo)L9dqS0yqbJYpiSiF5rB(Yf5n)gk)oYNHLYgXB(f6GOb5heC(agwI8PtKRJN)GYV38btKpvzE18rpGL27IxD7zNbeor7zAAO7TK1Axyi4CS1LGc1NyGBJbjvePCaQHteoelznyLHuoGrbbvxD7zNbeor75kILSgSfb3lQsgSCWpsyJRCAqSYClVJHCrlXfrgSjnD(I8Q8ZNunqFoFpHbGZ5JMWIEa53q5xGZNWGHZVe1dQJZo0ew0di)LJ8nGiFjkD0LAo)WqW5yZNQSMxnF0dyP9UyymuByAMgGjX3ul7kr9G64SdnHf9aObgttX3LOEqDC2HMWIEah2swRDHHGZXwxckuFIbUngKKm3xKxLF(KxupOooN)LoHf9aivr(xcoG1nF4nmC(w(EKvMVHnur(mGrWpNp0GYpi483GnDqKVCD8nFYHr1AbJYFJwRZhXBj7J87G018jvjvjnDKV3a5JX5hewK)2sLAUMxnF0dyP9UyVP1oZh9aC6EdAaMeFVbB6GW5flnn0nmgQnmnxPw2vI6b1XzhAcl6bKxLF(xYLf5ht(cgQbC(fiyq(XKp1Y5VbB6GiF564B(dkFmQwly0MxnF0dyP9UyymuByAMgGjX3BWMoiCbbIxIrlObgttX3xqxAdtZGOctdFqvgyyAwqNVa20gMMbrvY2GrUbYTeMykSvgyyAwqNVa20gMMbrDjmXuWbnEQTYadtZc68f0L2W0miQM28OooxzGHPzbD(cyt7f0LotUTK1Axyi4CS1LGc1NyGBJbjjZT8iDEv(5lxdyBbJYNABa88T8Xd20br(Y1XZVabdYhXMNObWZpi48zaJGFo)GaXlXOf5vZh9awAVl2BATZ8rpaNU3GgGjX3BWMoiCEXstdDZagb)CvWqTVJIUHXqTHP56gSPdcxqG4Ly0I8Q5JEalT3f7nT2z(OhGt3BqdWK4BOg0lbnn0TFKWgx50GyVnqlzEcdbNfoFzEv(5tEAqVe5Br(YJ28l0bXqf5FC88hu(f6GiF85457rDKpgfeen5txAZVqhe5FC88j3qfBl483GnDqq68Q5JEalT3f7nT2z(OhGt3BqdWK4BOg0lbnn0TFKWgx50GyRcgQ9Du0nzKqcudNiCiwYAWw0nzh8Je24kNgeRm3xMesWOGGQ7zjSrVUbYjyliCgvmEuhvQYd(rcBCLtdIvMB5LxLF(K)oiY)445B6DYhQb9sKVf5lpAZ3GBnyJ8Lx(HHGZXMp5gQyBbN)gSPdcsNxnF0dyP9UyVP1oZh9aC6EdAaMeFd1GEjOPHU3swRDHHGZXwxckuFIbUngKKm3Y7GFKWgx50GyL5wE5v5N)LC58T8XOATGr5xGGb5JyZt0a45heC(mGrWpNFqG4Ly0I8Q5JEalT3f7nT2z(OhGt3BqdWK4BmQwlOPHUzaJGFUkyO23rr3WyO2W0CDd20bHliq8smArEv(5FjMc8g5xI6b1X58Bq(MwN)aLFqW5l3iVxI8XyVrTC(DKV3OwEZ3YNorUoEE18rpGL27InK3aSlgeIbbnn0ndye8Zvbd1(oK5Mm6sldye8ZvedNb5vZh9awAVl2qEdWUsk9Y5vZh9awAVlw3WjI1DSKsaxIbrE18rpGL27IXm4UbYfO2FAZR5v5NVCnJwmfaBEv(5Fjxo)JBapN)abDmW9I8XyObX5heC(qnAJ8xckuFIbUngKu(qOrkF6heWet((rI38BqnVA(OhWw9IL27IxctmfCcd4zAOw2nqqo4EXnz00q3YbJccQUeMyk4egWZvQYdyuqq1LGc1NyGlgeWetLQ8agfeuDjOq9jg4IbbmXurSK1GTO7lxPBEv(5tUljqZ7MVPrSjoNpvz(yS3Owo)cC(XmNYhNWetH8jpJNAjD(ulNp(zjSrV5pqqhdCViFmgAqC(bbNpuJ2i)LGc1NyGBJbjLpeAKYN(bbmXKVFK4n)guZRMp6bSvVyP9U49Se2Ox3a5eSfe0qTSBGGCW9IBYOPHUXOGGQlbfQpXaxmiGjMkv5bmkiO6sqH6tmWfdcyIPIyjRbBr3xUs38Q5JEaB1lwAVlgsBWzT2IEa00q3WyO2W0CDbcNFaIo6bCqoBWMoiyrvYaHMZRMp6bSvVyP9UyiTbN1Al6b48A2alttdDlymkiOkK2GZATf9aQiwYAWw0f5vZh9a2QxS0ExmmgOxcAAOBYHOam0GGZvjdDYnqUGGDs2gmYz7A72Gd(rcBCLtdITkyO23rr3xMesquagAqW5QGTGqF2TeMykSh8Je24kNgeBrKr6dyuqq19Se2Ox3a5eSfevQYdyuqq1LWetbNWaEUsvEqY2GroBxB3g4qSK1G9g2hWOGGQc2cc9z3syIPWwftbqEv(5tENrNp0GYN(bbmXKFjIpg8545xOdI8XjoE(i2eNZVabdYhmr(ikaObWZhN8uZRMp6bSvVyP9U4Yz0oeVdfYZ0anihGHL4MmAAO7W0miQlbfQpXaxmiGjMkdmmnloiNW0miQlHjMcoOXtTvgyyAwKxLF(xYLZN(bbmXKFjIZhFoE(fiyq(f48jmy48dcoFgWi4NZVabhemkFi0iLF5m6gap)cDqmur(4KN8hu(hlP2iF4mGrMwFUMxnF0dyREXs7DXlbfQpXaxmiGjgAAOBgWi4NL5MuG9bymuByAUUaHZparh9ao4NrlMcG6EwcB0RBGCc2cIkv5b)mAXuauxctmfCcd45QNWqW5vMBYYRMp6bSvVyP9U4LrilyHdBaSBl7tmn(ZEn7cdbNJ9MmAAOBymuByAUUaHZparh9aoihXe1LrilyHdBaSBl7tStmrnA)Pga)qyi4CuJwIDX4enlZ9fKrcjqnCIWHyjRbBr309WwYATlmeCo26sqH6tmWTXGKk6Y5vZh9a2QxS0Ex8YLBV00q3WyO2W0CDbcNFaIo6bCWpsyJRCAqSvbd1(oK5MS8Q8Z)sUC(4NLWg9M)aY3pJwmfa5todkyu(qnAJ8XbhN05tb08U5xGZ3qC(WNgap)yYVCkZN(bbmXKVbe5lM8btKpHbdNpoHjMc5tEgp1wZRMp6bSvVyP9U49Se2Ox3a5eSfe00q3WyO2W0CDbcNFaIo6bCGCHPzquzamSEkBaC3syIPWwzGHPzbjK4NrlMcG6syIPGtyapx9egcoVYCtgPpqo5eMMbrDjOq9jg4IbbmXuzGHPzbjKeMMbrDjmXuWbnEQTYadtZcsiXpJwmfa1LGc1NyGlgeWetfXswdwzUG05v5N)XgkFti28neNpvjn5VGUKZpi48haNFHoiYxpf4nYNE6pEn)l5Y5xGGb5lo3a45dzBWO8dcdKVCrEZxWqTVJ8hu(GjYFd20bblYVqhedvKVboNVCrER5vZh9a2QxS0ExSKHoXch0GCc2ccA8N9A2fgcoh7nz00q3iRfogggevti2kv5bYfgcoh1OLyxmorZf5hjSXvoni2QGHAFhKqIC2GnDqWIQP1h8Je24kNgeBvWqTVdzU9LojdwCBjdeKoVk)8p2q5dM8nHyZVqR15lAo)cDq0G8dcoFadlr(xg2ln5tTC(0Pqhp)bKp2SB(f6GyOI8nW58LlYBnVA(OhWw9IL27ILm0jw4GgKtWwqqtdDJSw4yyyqunHyRnqMld7JbzTWXWWGOAcXwfuil6bCWpsyJRCAqSvbd1(oK52x6KmyXTLmqKxnF0dyREXs7DXlHjMcomTj4LMg6ggd1gMMRlq48dq0rpGd(rcBCLtdITkyO23Hm3xKxnF0dyREXs7DXSNyAaChIlrTKbe00q3WyO2W0CDbcNFaIo6bCWpsyJRCAqSvbd1(oK5(IdKdgd1gMMRul7kr9G64SdnHf9aiHKTK1Axyi4CS1LGc1NyGBJbjv0T8iDEv(5t(7GiFCYdn53q5dMiFtJytCoFXayAYNA58PFqatm5xOdI8XNJNpvznVA(OhWw9IL27IxckuFIbUyqatm00q3HPzquxctmfCqJNARmWW0S4amgQnmnxxGW5hGOJEahWOGGQ7zjSrVUbYjyliQuL5vZh9a2QxS0Ex8syIPGtyapttdDlhmkiO6syIPGtyapxPkpa1WjchILSgSfDtQPnmndI6sHfmcIcoxzGHPzrEv(5l7aoMTK95Vbfeu(f6GiF9uGr5xI6jVA(OhWw9IL27IlNOhann0ngfeuftpJqtTrfXMpiHeOgor4qSK1GTOldBsibJccQUNLWg96giNGTGOsvEGCyuqq1LWetbhM2e8wPkjHe)mAXuauxctmfCyAtWBfXswd2IUjd2KoVA(OhWw9IL27IX0ZiCquOZ00q3yuqq19Se2Ox3a5eSfevQY8Q5JEaB1lwAVlgJrlJo1a400q3yuqq19Se2Ox3a5eSfevQY8Q5JEaB1lwAVlgQrmMEgbnn0ngfeuDplHn61nqobBbrLQmVA(OhWw9IL27InGN3azAN30AAAOBmkiO6EwcB0RBGCc2cIkvzEv(5FCgYO0r(qMwJz(t5dnO8PwdtZ53blT0H8VKlNFHoiYh)Se2O38hO8poBbrnVA(OhWw9IL27IPw21blT00q3yuqq19Se2Ox3a5eSfevQssibQHteoelznyl6cyNxZRYpF52XkJ6GZN85UmWZBE18rpGTY7YapV0ExSFaEgeilyHdsBsmnn0ndye8Z1OLyxmojdwKHSdYbJccQUNLWg96giNGTGOsvEGCYrmr1papdcKfSWbPnj2HrHa1O9NAa8dYX8rpGQFaEgeilyHdsBsCTboiDdNiiHeikT2HypHHGZUOL4IG7fvjdwiDE18rpGTY7YapV0ExmMEgHBGCbb7yalDMMg6wo(z0IPaOUeMyk4W0MG3kv5b)mAXuau3ZsyJEDdKtWwquPkjHeOgor4qSK1GTOBYGDE18rpGTY7YapV0ExmCkdjAd4giNDSYOjiYRMp6bSvExg45L27IHgp1YcNDSYOoyhgBs00q3KBlzT2fgcohBDjOq9jg42yqsYCFbjKGSw4yyyqunHyRnqgsb2K(GC8ZOftbqDplHn61nqobBbrLQ8GCWOGGQ7zjSrVUbYjyliQuLhyaJGFUkyO23Hm3xg25vZh9a2kVld88s7DXLuOg6CdG7W02g00q3BjR1UWqW5yRlbfQpXa3gdssM7liHeK1chdddIQjeBTbYqkWoVA(OhWw5DzGNxAVloiyhfaBOach0G8mnn0ngfeufX(tAExh0G8CLQKesWOGGQi2FsZ76GgKND(HcemQUH5pvezWoVA(OhWw5DzGNxAVlg1LLA21a3wAEoVA(OhWw5DzGNxAVlUWG0cy4g4q8oad4zAAOB)mAXuau3ZsyJEDdKtWwqurSK1GTi6scjqnCIWHyjRbBrKrQZRMp6bSvExg45L27ILyPbD2nqonLVfobInPLMg6Mbmc(5IKhSpGrbbv3ZsyJEDdKtWwquPkZRYp)JfJwK)LYwzdGNp5rBs8Mp0GYNHf2tfC(idaNZFq5FQ168XOGGwAYVHYVC2TX0CnF5MUGDEZpqNZpM8HZr(bbNVEkWBKVFgTykaYhZwwK)aY3GXATHP58zal18wZRMp6bSvExg45L27IrSv2a4oiTjXlnn0nudNiCiwYAWwezv6scjKJCHHGZrLGnDqul9HmKAytcjHHGZrLGnDqul9rr3xaBsFGCMpAyyhdyPM3BYiHeOgor4qSK1GvMlivinPjHeYfgcoh1OLyxmUsF4Ua2YCzyFGCMpAyyhdyPM3BYiHeOgor4qSK1Gvg5jpst68AEv(5JhSPdI8LRz0IPayZRMp6bS1nytheoVyP9UyymuByAMgGjX3lHWfeiEjgTGgymnfF7NrlMcG6syIPGtyapx9egcoVoiK5JEaMwMBYQ0r6sZXcwxYO8jFyO2W0CEv(5t(Wa9sKFdLFboFdX57TYYgap)bK)XnGNZ3tyi48wZN8PH0NZhJHgeNpuJ2iFHb8C(nu(f48jmy48bt(Y2WjInm9jgLpgvK)Xn0P8XjmXui)gK)Gemk)yYhoh5FPuLbfIZNQmFYbM8PtTnyu(YTDTDBaPR5vZh9a26gSPdcNxS0ExmmgOxcAAOBYjhymuByAUUecxqG4Ly0csiroHPzqubnCIydtFIrvgyyAwCimndIQWqNClHjMcvgyyAwq6d(rcBCLtdITkyO23HmKDqoikadni4CvYqNCdKliyNKTbJC2U2UniVA(OhWw3GnDq48IL27IlNr7q8ouiptd0GCagwIBYOHHLazotAOaXT8GnnK3z05dnO8XjmXuqI1I8PnFCctmf2a1N48PaAE38lW5BioFdBOI8JjFVvM)aY)4gWZ57jmeCER5tQgOpNFbcgKp5PbI8j)SDcW7MFV5BydvKFm5JOa5purnVA(OhWw3GnDq48IL27IxctmfKyTGMg6Mbmc(zzULhSpWagb)CvWqTVdzUjd2hKdmgQnmnxxcHliq8smAXb)iHnUYPbXwfmu77qgYoiymkiOkudeUcSDcW7wrSK1GTiYYRYpF5I8MFqG4Ly0InFObLpdcg1a45JtyIPq(h3aEoVA(OhWw3GnDq48IL27IHXqTHPzAaMeFVecNFKWgx50GyPbgttX3(rcBCLtdITkyO23Hm3xqlgfeuDjmXuWHPnbVvQY8Q5JEaBDd20bHZlwAVlggd1gMMPbys89siC(rcBCLtdILgymnfF7hjSXvoni2QGHAFhYCFzAAOB)addmqupDg1giVA(OhWw3GnDq48IL27IHXqTHPzAaMeFVecNFKWgx50GyPbgttX3(rcBCLtdITkyO23rr3KrtdDdJHAdtZvQLDLOEqDC2HMWIEah2swRDHHGZXwxckuFIbUngKKm3YlVk)8pUb8C(ckudGNp(zjSrV5pO8nSbgo)GaXlXOf18Q5JEaBDd20bHZlwAVlEjmXuWjmGNPPHUHXqTHP56siC(rcBCLtdI9a5GXqTHP56siCbbIxIrliHemkiO6EwcB0RBGCc2cIkILSgSYCtw9csizlzT2fgcohBDjOq9jg42yqsYClVd(z0IPaOUNLWg96giNGTGOIyjRbRmKbBsNxLF(hrHa5JyjRbnaE(h3aEEZhJHgeNFqW5d1WjI8zGyZVHYhFoE(fgaSg5JX5JytCo)gKF0sCnVA(OhWw3GnDq48IL27IxctmfCcd4zAAOBymuByAUUecNFKWgx50Gypa1WjchILSgSf5NrlMcG6EwcB0RBGCc2cIkILSgS518Q8ZhpytheSi)lDcl6bKxLF(hBO8Xd20brXWyGEjY3qC(uL0Kp1Y5JtyIPWgO(eNFm5JXagQJ8HqJu(bbNFPTBddNp2aO28nGiFYtde5t(z7eG3nFgggKFdLFboFdX5Br(sgSKVCrEZNCqOrk)GGZVeX(rcZI8PtHooPR5vZh9a26gSPdcwq7DXlHjMcBG6tmnn0n5WOGGQBWMoiQuLKqcgfeufgd0lrLQK05v5Np5Pb9sKVf5FzAZxUiV5xOdIHkY)445xC(YJ28l0br(hhp)cDqKpobfQpXG8PFqatm5JrbbLpvz(XKVbZ0I83rIZxUiV5xW2GZF7GYIEaBnVA(OhWw3GnDqWcAVl2BATZ8rpaNU3GgGjX3qnOxcAAOBmkiO6sqH6tmWfdcyIPsvEWpsyJRCAqSvbd1(ok6(I8Q8ZxUP3j)1G48JjFOg0lr(wKV8OnF5I8MFHoiYNHfZh6Z5lV8ddbNJTMp5WnjoFBZFOITfC(BWMoiQKoVA(OhWw3GnDqWcAVl2BATZ8rpaNU3GgGjX3qnOxcAAO7TK1Axyi4CS1LGc1NyGBJbjDlVd(rcBCLtdIvMB5LxLF(KNg0lr(wKV8OnF5I8MFHoigQi)JJtt(0L28l0br(hhNM8nGiFsj)cDqK)XXZ3GcgLp5dd0lrE18rpGTUbB6GGf0ExS30AN5JEaoDVbnatIVHAqVe00q3(rcBCLtdITkyO23rr3KDmKlmndIQG5sg52azHbNLQmWW0S4agfeufgd0lrLQK05vZh9a26gSPdcwq7DXlrddnn0DyAgevqdNi2W0NyuLbgMMfhquagAqW5A0GZUyGL27W0MGpSLSw7cdbNJTUeuO(edCBmiPIOBEv(5FjlZpM8VC(HHGZXM)jMlZNQmFYtde5t(z7eG3nFSZ57p71naE(4eMykSbQpX18Q5JEaBDd20bblO9U4LWetHnq9jMg)zVMDHHGZXEtgnn0TGXOGGQqnq4kW2jaVBfXswd2Ii7WwYATlmeCo26sqH6tmWTXGKk6(YhcdbNJA0sSlgNO5JbXswdwziL8Q8ZN8mO8lr9G64C(OjSOhan5tTC(4eMykSbQpX5pWWO8XJbjLFHoiYN8tNMVb3AWg5tvMFm5lV8ddbNJn)bLFdLp5H8NFV5JOaGgap)bckFYnG8nW58nPHce5pq5hgcohlPZRMp6bS1nytheSG27Ixctmf2a1NyAAOBymuByAUsTSRe1dQJZo0ew0d4a5emgfeufQbcxb2ob4DRiwYAWwezKqsyAge1cSvoajBdgvzGHPzXHTK1Axyi4CS1LGc1NyGBJbjv0T8iDE18rpGTUbB6GGf0Ex8sqH6tmWTXGKOPHU3swRDHHGZXkZ9LPLCyuqq1GGDOjcguPkjHeefGHgeCUANmd1RBhkTdczWLyqCWpabvhvbZLmYjm4Wz0wrg4Km30rsFGCyuqq19Se2Ox3a5eSfeoJkgpQJkvjjKihmkiOAjILyrhw0dOsvscjBjR1UWqW5yL5MUKoVk)8XjmXuyduFIZpM8rmeIxI8jpnqKp5NTtaE38nGi)yYNblfIZVaNV3a57ne6C(dmmkFlFikToFYd5p)get(bbNpGHLiF85453q5xo72yAUMxnF0dyRBWMoiybT3fVeMykSbQpX00q3cgJccQc1aHRaBNa8Uvelznyl6MmsiXpJwmfa19Se2Ox3a5eSfevelznylIms9bbJrbbvHAGWvGTtaE3kILSgSf5NrlMcG6EwcB0RBGCc2cIkILSgS5vZh9a26gSPdcwq7DXW1ZiHPnbttdDJrbbvlze0GSGfoy4gS1nm)jzUP7b)aeuDulze0GSGfoy4gSvKbojZnzxoVA(OhWw3GnDqWcAVlEjmXuyduFIZR5v5Np5Pb9sWOnVk)8j)eTMZNABa88jViwIfDyrpaAY3GzAr(EBJgapFCD758nGi)J3Eo)cemiFCctmfY)4gWZ53B(7mG8JjFmoFQLf0KpdlEUmYhAq5tQ6zuBG8Q5JEaBfQb9sCdJHAdtZ0amj(UeXsSWTaHZparh9aObgttX3HPzqulrSel6WIEavgyyAwCylzT2fgcohBrKJUhJFGHbgiQa2Jg9GeK(GC8dmmWar90zuBG8Q5JEaBfQb9sq7DXRU9SZacNO9mnn0TCGXqTHP5AjILyHBbcNFaIo6bCylzT2fgcohBDjOq9jg42yqsfrkhKdgfeuDjmXuWjmGNRuLhWOGGQRU9SZacNO9CfXswd2IGA4eHdXswd2digcXlHHP58Q5JEaBfQb9sq7DXRU9SZacNO9mnn0nmgQnmnxlrSelClq48dq0rpGd(z0IPaOUeMyk4egWZvpHHGZRdcz(OhGPlISkDKUhWOGGQRU9SZacNO9CfXswd2I8ZOftbqDplHn61nqobBbrfXswd2dKZpJwmfa1LWetbNWaEUIytC(agfeuDplHn61nqobBbrfXswd2JbJccQUeMyk4egWZvelznylIS6fKoVA(OhWwHAqVe0ExmmgQnmntdWK479ux6quLbfIPbgttX3s2gmYz7A72ahILSgSYaBsiroHPzqubnCIydtFIrvgyyAwCimndIQWqNClHjMcvgyyAwCaJccQUeMyk4egWZvQssizlzT2fgcohBDjOq9jg42yqsYCtk0CSG1LmkFYhgQnmnNp0GY)sPkdkexZh)uxMVGc1a45tNABWO8LB7A72G8hu(ckudGN)XnGNZVqhe5FCdDkFdiYhm5lBdNi2W0NyunVk)8jvL5Y8PkZ)sPkdkeNFdLFh53B(g2qf5ht(ikq(dvuZRMp6bSvOg0lbT3fJOkdkettdDlhymuByAUUN6shIQmOq8HWqW5OgTe7IXjA(yqSK1Gvgs5aIHq8syyAoVA(OhWwHAqVe0Ex8YEehUG9eGM8LIZRYpF6ukD0IjIgap)WqW5yZpiSi)cTwNVUHHZhAq5heC(ckKf9aYFGY)sPkdkeNpIHq8sKVGc1a45xAabl1(AE18rpGTc1GEjO9UyevzqHyA8N9A2fgcoh7nz00q3Ybgd1gMMR7PU0HOkdkeFqoWyO2W0CLAzxjQhuhNDOjSOhWHTK1Axyi4CS1LGc1NyGBJbjjZ9fhcdbNJA0sSlgNOzzUjhDPLCxqN9Je24kNgelPj9bedH4LWW0CEv(5FPmeIxI8VuQYGcX5ZgsFo)gk)oYVqR15ZWszJ48fuOgapF8ZsyJER5F8j)GWI8rmeIxI8BO8XNJNpCo28rSjoNFdYpi48bmSe5t3TMxnF0dyRqnOxcAVlgrvguiMMg6woWyO2W0CDp1LoevzqH4diwYAWwKFgTykaQ7zjSrVUbYjyliQiwYAWslzW(GFgTykaQ7zjSrVUbYjyliQiwYAWw0nDpegcoh1OLyxmorZhdILSgSY4NrlMcG6EwcB0RBGCc2cIkILSgS0s38Q5JEaBfQb9sq7DXyAZFYvofemIMg6woWyO2W0CLAzxjQhuhNDOjSOhWHTK1Axyi4CSYCF58Q5JEaBfQb9sq7DXmm96zKfCEnVk)8pIQ1cgT5vZh9a2kgvRf3lrddnn0TCctZGOcA4eXgM(eJQmWW0S4aIcWqdcoxJgC2fdS0EhM2e8HTK1Axyi4CS1LGc1NyGBJbjveDZRMp6bSvmQwlO9U4LGc1NyGBJbjrtdDVLSw7cdbNJvM7lYRMp6bSvmQwlO9U4LrilyHdBaSBl7tmnn0TFgTykaQlJqwWch2ay3w2N4QNWqW51bHmF0dW0YCFrLosxsizhknwdevnBch2zhdlMuPMRmWW0S4GCWOGGQA2eoSZogwmPsnxPkZRMp6bSvmQwlO9Uy46zKW0MGZRMp6bSvmQwlO9UymZFAddtfQqPaa]] )

    
end
