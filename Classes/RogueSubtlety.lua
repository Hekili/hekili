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


    spec:RegisterPack( "Subtlety", 20201213, [[daveKbqiHipcvL2Kq6tQQuJcvrNcvfRcvu6vOknluPUfrPSlj9lvjnmufogQWYuvLNPksttiQRruY2qfvFtvvX4uvjCovrG1HkcZtvu3du2Nq4FQIGYbjkvTqvv8qurAIQs4IOIIAJQQQ6JQQQ0ivvvbNuvezLQs9svvvOzQkcDtvvI2jQQ(jQOidvvvPLQQs6POyQefxvve1wvvvrFfvenwIsLZQkcQ2lP(RGbR4WuwmuESetMWLr2miFgunAO60sTAvrqETQWSj52ez3a)wPHluhhvuy5qEUktNQRJsBxvX3jQgVQeDEvLMpQK9lAnhAz0mcZjn))XJ)4bh)XXtRC8uo(N)EQMX)gtAMyR8WGtAgGjrAggwmxr(xntS9vTMqlJM5wwuH0m4UhFCIxFfE74Sy1Yk961sSkZ7fuqgK)61sLx1mySTYFsanMMryoP5)pE8hp44poEALJNYX)WbNRzmwhFrAgMwIt1m4TqqanMMrqxrZW3CyyXCf5FZ5xx4Su(MV58cQqsyekhoEk358hp(Jh578nFZ5xUFOC(yO2WuuL9OqmQxu7FdO1nVxqoSX5CBoTNtF5CKNdgbTikh5uoShLt718nFZHtxjSgq5iXQ8owr5umLkyfVxqq1NNdbCutxo(MdIeSfkN41jG3MkhejFrpQAgvF(PLrZCozkhNeAz08ZHwgndbmmfj0)OzkO2juBAgEMdgleu9CYuoELnohU4khmwiO6hd0hELnoh(Kt0CKSZjuWUZURbbejzn4Ybwo8qZyfVxGM5WnXk)Cu)G0UM))0YOziGHPiH(hntb1oHAtZGXcbvpCwu)GabFratSv24CIMtzLW2q82a)QccQlTNZZWY5VC4IRCUysPcUHGt(vpCwu)GaHZxKuoWYjY5enNYkHTH4Tb(LteWYjY5Wfx5uwjSneVnWVQGG6s758mSC4ihzlhEMJBkc4vbrXekCoYCdojvjGHPirorZbJfcQ(Xa9HxzJZHpAgR49c0mftPcwX7feu95AgvFEaysKMbQb9HRDn)pvlJMHagMIe6F0mfu7eQnnJBkc4vqdh3p3upiuLagMIe5enhelGGweCQ6n4BW3x2LaMYeuLagMIe5enNlMuQGBi4KF1dNf1piq48fjLZZ5ilnJv8EbAMdV)ODn)rwlJMHagMIe6F0mwX7fOzoCtSYph1pintb1oHAtZiimwiOkudeb5K9aq3vrKK1GlNNZHJCIMZftkvWneCYV6HZI6heiC(IKY5zy580CIMJBi4Kx9wIc(genLJSLdIKSgC5eroCUMP8TOOGBi4KFA(5q7A(LLwgndbmmfj0)OzkO2juBAMpgQnmfvzpkeJ6f1(3aADZ7fKt0C4zoccJfcQc1arqozpa0Dvejzn4Y55C4ihU4kh3ueWRYjlEbs25eQsadtrICIMZftkvWneCYV6HZI6heiC(IKY5zy5e5C4JMXkEVanZHBIv(5O(bPDn)CUwgndbmmfj0)OzkO2juBAMlMuQGBi4KF5ebSCEAo8MdpZbJfcQ64uaTUtGkBCoCXvoiwabTi4u1EygQVWTSQaeYGlraVsadtrICIMtzbc22RcIIjuqyWHtORImWJCIawo)to8jNO5WZCWyHGQ3xjSvDHfkiiZXdgRVfu7v24C4IRCIuoySqq1yejrI2nVxqLnohU4kNlMuQGBi4KF5ebSCKvo8rZyfVxGM5Wzr9dceoFrsAxZ))OLrZqadtrc9pAMcQDc1MMrqySqqvOgicYj7bGURIijRbxopdlhoYHlUYPSRsSYb17Re2QUWcfeK54vejzn4Y55C44xKt0CeegleufQbIGCYEaO7QisYAWLZZ5u2vjw5G69vcBvxyHccYC8kIKSgCAgR49c0mhUjw5NJ6hK218)l0YOziGHPiH(hntb1oHAtZGXcbvJje0ImNeHpudU65w5roralhzLt0CklqW2EnMqqlYCse(qn4Qid8iNiGLdhpvZyfVxGMbUAxjmLjiTR5)jqlJMXkEVanZHBIv(5O(bPziGHPiH(hTR5NdEOLrZqadtrc9pAMcQDc1MMjs54gco51(cy7D5enNYkHTH4Tb(vfeuxApNiGLdh5enhmwiO6HVEObbhNccd9OYgNt0CiaHG)T6Tef8nezEKte5aViQs2l1mwX7fOzk4Kfho811U21mccYyvUwgn)COLrZyfVxGM5rxEOziGHPiH(hTR5)pTmAgcyyksO)rZSXAMJCnJv8EbAMpgQnmfPz(ykwsZGXcbvpvxOGbebrxOkBCoCXvoxmPub3qWj)QholQFqGW5lskNiGLdNRz(yOaWKinZbeHYceT3lq7A(FQwgndbmmfj0)Oz2ynZrUMXkEVanZhd1gMI0mFmflPzIr9IA)BaTU59cYjAoxmPub3qWj)QholQFqGW5lskNiGLZFAMpgkamjsZWEuig1lQ9Vb06M3lq7A(JSwgndbmmfj0)OzSI3lqZumLkyfVxqq1NRzu95bGjrAMI40UMFzPLrZqadtrc9pAMcQDc1MM5CYuoojQMsPzSI3lqZGybbR49ccQ(CnJQppamjsZCozkhNeAxZpNRLrZqadtrc9pAMcQDc1MM5IjLk4gco5x9Wzr9dceoFrs58CoCEorZbQHJ7bejzn4YjIC48CIMdgleu9uDHcgqeeDHQisYAWLZZ5aViQs2lZjAoLvcBdXBd8lNiGLtKZr2YHN54TeLZZ5WbpYHp5WzZ5pnJv8EbAMt1fkyarq0fs7A()hTmAgcyyksO)rZuqTtO20mFmuBykQYEuig1lQ9Vb06M3lqZyfVxGMPykvWkEVGGQpxZO6ZdatI0mNtMYXdfXPDn))cTmAgcyyksO)rZSXAMJCnJv8EbAMpgQnmfPz(ykwsZ8NSYH3CCtraV(PHVOkbmmfjYHZMZF8ihEZXnfb8QKDoHclu4WnXk)QeWWuKihoBo)XJC4nh3ueWRhUjw5bOTWEvcyyksKdNnN)Kvo8MJBkc4vtzfu7FReWWuKihoBo)XJC4nN)KvoC2C4zoxmPub3qWj)QholQFqGW5lskNiGLtKZHpAMpgkamjsZCozkhp44i6WxLq7A(Fc0YOziGHPiH(hntb1oHAtZqacb)BvqqDP9CEgwoFmuBykQEozkhp44i6WxLqZyfVxGMPykvWkEVGGQpxZO6ZdatI0mNtMYXdfXPDn)CWdTmAgcyyksO)rZuqTtO20mLvcBdXBd8lhy5yGwYk4gcojcL4C4IRCkRe2gI3g4xvqqDP9CEgwoCKdxCLdudh3disYAWLZZWYHJCIMtzLW2q82a)Yjcy580C4IRCWyHGQ3xjSvDHfkiiZXdgRVfu7v24CIMtzLW2q82a)Yjcy5e5C4IRCUysPcUHGt(vpCwu)GaHZxKuoralNiNt0CkRe2gI3g4xoralNiRzSI3lqZumLkyfVxqq1NRzu95bGjrAgOg0hU218ZbhAz0meWWuKq)JMPGANqTPziaHG)TkiOU0EopdlNpgQnmfvpNmLJhCCeD4RsOzSI3lqZumLkyfVxqq1NRzu95bGjrAgm2wj0UMFo(tlJMHagMIe6F0mfu7eQnndbie8Vvbb1L2Zjcy5WHSYH3CiaHG)TIi4eqZyfVxGMXqfdqbFric4AxZphpvlJMXkEVanJHkgGcXSQJ0meWWuKq)J218ZrK1YOzSI3lqZOA44(fEcXkGlraxZqadtrc9pAxZphYslJMXkEVandMbpSqbh1LhNMHagMIe6F0U21mXiQSsyMRLrZphAz0mwX7fOzS4y13q823c0meWWuKq)J218)NwgnJv8EbAgS1Dfjcqk7ljK3a4bFFzd0meWWuKq)J218)uTmAgR49c0mNtMYX1meWWuKq)J218hzTmAgcyyksO)rZyfVxGMrYqpiraArbbzoUMjgrLvcZ8WrLfiondhYs7A(LLwgndbmmfj0)OzSI3lqZCQUqbdicIUqAMcQDc1MMbrqi6WnmfPzIruzLWmpCuzbItZWH218Z5Az0meWWuKq)JMPGANqTPzqSacArWPQKHEewOGJtbj7CcfS7S7AqLagMIeAgR49c0mhUjw5bmLjOt7AxZa1G(W1YO5NdTmAgcyyksO)rZSXAMJCnJv8EbAMpgQnmfPz(ykwsZ4MIaEngrsKODZ7fujGHPirorZ5IjLk4gco5x9Wzr9dceoFrs58Co8mhzLJSLtz)qad4vavqRArIC4torZjs5u2peWaE9XxuBanZhdfaMePzIrKejchqeklq0EVaTR5)pTmAgcyyksO)rZuqTtO20mrkNpgQnmfvJrKejchqeklq0EVGCIMZftkvWneCYV6HZI6heiC(IKY55C48CIMtKYbJfcQE4MyLhegOqv24CIMdgleu9uDHcgqeeDHQisYAWLZZ5a1WX9aIKSgC5enhebHOd3WuKMXkEVanZP6cfmGii6cPDn)pvlJMHagMIe6F0mfu7eQnnZhd1gMIQXisIeHdicLfiAVxqorZPSRsSYb1d3eR8GWafQwWneC6cqiR49cmvopNdh1)rw5enhmwiO6P6cfmGii6cvrKK1GlNNZPSRsSYb17Re2QUWcfeK54vejzn4YjAo8mNYUkXkhupCtSYdcduOkImX3CIMdgleu9(kHTQlSqbbzoEfrswdUCKTCWyHGQhUjw5bHbkufrswdUCEohoQ)LdF0mwX7fOzovxOGbebrxiTR5pYAz0meWWuKq)JMzJ1mh5AgR49c0mFmuByksZ8XuSKMrYoNqb7o7UgeqKK1GlNiYHh5Wfx5ePCCtraVcA44(5M6bHQeWWuKiNO54MIaEvyOhHd3eR8kbmmfjYjAoySqq1d3eR8GWafQYgNdxCLZftkvWneCYV6HZI6heiC(IKYjcy5W5AMpgkamjsZCp64aIn2zrK218llTmAgcyyksO)rZuqTtO20mrkNpgQnmfvVhDCaXg7SikNO54gco5vVLOGVbrt5iB5GijRbxorKdNNt0CqeeIoCdtrAgR49c0mi2yNfrAxZpNRLrZyfVxGM5OcI8GtfCqZzWsAgcyyksO)r7A()hTmAgcyyksO)rZyfVxGMbXg7SisZuqTtO20mrkNpgQnmfvVhDCaXg7SikNO5ePC(yO2WuuL9OqmQxu7FdO1nVxqorZ5IjLk4gco5x9Wzr9dceoFrs5ebSC(lNO54gco5vVLOGVbrt5ebSC4zoYkhEZHN58xoC2CkRe2gI3g4xo8jh(Kt0CqeeIoCdtrAMY3IIcUHGt(P5NdTR5)xOLrZqadtrc9pAMcQDc1MMjs58XqTHPO69OJdi2yNfr5enhejzn4Y55Ck7QeRCq9(kHTQlSqbbzoEfrswdUC4nho4rorZPSRsSYb17Re2QUWcfeK54vejzn4Y5zy5iRCIMJBi4Kx9wIc(genLJSLdIKSgC5eroLDvIvoOEFLWw1fwOGGmhVIijRbxo8MJS0mwX7fOzqSXolI0UM)NaTmAgcyyksO)rZuqTtO20mrkNpgQnmfvzpkeJ6f1(3aADZ7fKt0CUysPcUHGt(LteWY5PAgR49c0mykR8ieVYfes7A(5GhAz0mwX7fOzOp9viK5KMHagMIe6F0U21mfXPLrZphAz0meWWuKq)JMPGANqTPzIuoySqq1d3eR8GWafQYgNt0CWyHGQholQFqGGViGj2kBCorZbJfcQE4SO(bbc(IaMyRisYAWLZZWY5PvzPzSI3lqZC4MyLhegOqAg2JcleuaErO5NdTR5)pTmAgcyyksO)rZuqTtO20mySqq1dNf1piqWxeWeBLnoNO5GXcbvpCwu)GabFratSvejzn4Y5zy580QS0mwX7fOzUVsyR6cluqqMJRzypkSqqb4fHMFo0UM)NQLrZqadtrc9pAMcQDc1MM5JHAdtr1dicLfiAVxqorZjs5CozkhNevjd4ksZyfVxGMbszWjLY8EbAxZFK1YOziGHPiH(hntb1oHAtZiimwiOkKYGtkL59cQisYAWLZZ58NMXkEVandKYGtkL59ccffzGJ0UMFzPLrZqadtrc9pAMcQDc1MMHN5Gybe0IGtvjd9iSqbhNcs25eky3z31GkbmmfjYjAoLvcBdXBd8RkiOU0EopdlhoYr2YXnfb8QGOycfohzobNKQeWWuKihU4khelGGweCQkiZXvFdhUjw5xLagMIe5enNYkHTH4Tb(LZZ5Wro8jNO5GXcbvVVsyR6cluqqMJxzJZjAoySqq1d3eR8GWafQYgNt0CKSZjuWUZURbbejzn4Ybwo8iNO5GXcbvfK54QVHd3eR8Rkw5anJv8EbAMpgOpCTR5NZ1YOziGHPiH(hnJv8EbAM4DvbeDllQqAMcQDc1MMXnfb86HZI6hei4lcyITsadtrICIMtKYXnfb86HBIvEaAlSxLagMIeAgOffa0lDn)CODn))Jwgndbmmfj0)OzkO2juBAgcqi4FZjcy5W58iNO58XqTHPO6beHYceT3liNO5u2vjw5G69vcBvxyHccYC8kBCorZPSRsSYb1d3eR8GWafQwWneC6Yjcy5WHMXkEVanZHZI6hei4lcyIv7A()fAz0meWWuKq)JMXkEVanZriK5KiGTakCX9dsZuqTtO20mFmuBykQEarOSar79cYjAorkhX61JqiZjraBbu4I7huqSE17YJgapNO54gco5vVLOGVbrt5ebSC(JJC4IRCGA44EarswdUCEgwoYkNO5CXKsfCdbN8RE4SO(bbcNViPCEoNNQzkFlkk4gco5NMFo0UM)NaTmAgcyyksO)rZuqTtO20mFmuBykQEarOSar79cYjAoLvcBdXBd8RkiOU0Eoralho0mwX7fOzok(6t7A(5GhAz0meWWuKq)JMPGANqTPz(yO2Wuu9aIqzbI27fKt0C4zoUPiGxjWhsTXnaE4WnXk)QeWWuKihU4kNYUkXkhupCtSYdcduOAb3qWPlNiGLdh5WNCIMdpZjs54MIaE9Wzr9dce8fbmXwjGHPiroCXvoUPiGxpCtSYdqBH9QeWWuKihU4kNYUkXkhupCwu)GabFratSvejzn4YjIC(lh(OzSI3lqZCFLWw1fwOGGmhx7A(5GdTmAgcyyksO)rZyfVxGMrYqpiraArbbzoUMPGANqTPzqwlc0hc4vtiUkBCorZHN54gco5vVLOGVbrt58CoLvcBdXBd8RkiOU0EoCXvorkNZjt54KOAkvorZPSsyBiEBGFvbb1L2Zjcy5uIds2ldxmbe5Whnt5Brrb3qWj)08ZH218ZXFAz0meWWuKq)JMPGANqTPzqwlc0hc4vtiUAdYjICEkpYr2YbzTiqFiGxnH4QcwK59cYjAoLvcBdXBd8RkiOU0EoralNsCqYEz4IjGqZyfVxGMrYqpiraArbbzoU218ZXt1YOziGHPiH(hntb1oHAtZ8XqTHPO6beHYceT3liNO5uwjSneVnWVQGG6s75ebSC(tZyfVxGM5WnXkpGPmbDAxZphrwlJMHagMIe6F0mfu7eQnnZhd1gMIQhqeklq0EVGCIMtzLW2q82a)QccQlTNteWY5VCIMdpZ5JHAdtrv2JcXOErT)nGw38Eb5Wfx5CXKsfCdbN8RE4SO(bbcNViPCEgworoh(OzSI3lqZqf8TbWdikg1sgqODn)CilTmAgcyyksO)rZuqTtO20mUPiGxpCtSYdqBH9QeWWuKiNO58XqTHPO6beHYceT3liNO5GXcbvVVsyR6cluqqMJxzJ1mwX7fOzoCwu)GabFratSAxZphCUwgndbmmfj0)OzkO2juBAMiLdgleu9WnXkpimqHQSX5enhOgoUhqKK1GlNNHLZVihEZXnfb86XI5ecIfovjGHPiHMXkEVanZHBIvEqyGcPDn)C8pAz0meWWuKq)JMPGANqTPzWyHGQyQDfk2ZRiYkEoCXvoqnCCpGijRbxopNZt5roCXvoySqq17Re2QUWcfeK54v24CIMdpZbJfcQE4MyLhWuMGUkBCoCXvoLDvIvoOE4MyLhWuMGUkIKSgC58mSC4Gh5WhnJv8EbAM417fODn)C8l0YOziGHPiH(hntb1oHAtZGXcbvVVsyR6cluqqMJxzJ1mwX7fOzWu7kcqSOVAxZphpbAz0meWWuKq)JMPGANqTPzWyHGQ3xjSvDHfkiiZXRSXAgR49c0mye6i0Jgax7A()JhAz0meWWuKq)JMPGANqTPzWyHGQ3xjSvDHfkiiZXRSXAgR49c0mqnIWu7k0UM))4qlJMHagMIe6F0mfu7eQnndgleu9(kHTQlSqbbzoELnwZyfVxGMXaf6CKPcftP0UM))(tlJMHagMIe6F0mfu7eQnndgleu9(kHTQlSqbbzoELnohU4khOgoUhqKK1GlNNZ5pEOzSI3lqZWEuODs60U21mNtMYXdfXPLrZphAz0meWWuKq)JMzJ1mh5AgR49c0mFmuByksZ8XuSKMPSRsSYb1d3eR8GWafQwWneC6cqiR49cmvoralhoQ)JS0mFmuaysKM5Wfbhhrh(QeAxZ)FAz0meWWuKq)JMPGANqTPz4zorkNpgQnmfvpCrWXr0HVkroCXvorkh3ueWRGgoUFUPEqOkbmmfjYjAoUPiGxfg6r4WnXkVsadtrIC4torZPSsyBiEBGFvbb1L2ZjIC4iNO5ePCqSacArWPQKHEewOGJtbj7CcfS7S7AqLagMIeAgR49c0mFmqF4AxZ)t1YOziGHPiH(hnJv8EbAM4DvbeDllQqAg6LoYcM0YcCntK5HMbArba9sxZphAxZFK1YOziGHPiH(hntb1oHAtZqacb)BoralNiZJCIMdbie8Vvbb1L2Zjcy5WbpYjAorkNpgQnmfvpCrWXr0HVkrorZPSsyBiEBGFvbb1L2ZjIC4iNO5iimwiOkudeb5K9aq3vrKK1GlNNZHdnJv8EbAMd3eRCjsj0UMFzPLrZqadtrc9pAMnwZCKRzSI3lqZ8XqTHPinZhtXsAMYkHTH4Tb(vfeuxApNiGLZF5WBoySqq1d3eR8aMYe0vzJ1mFmuaysKM5WfHYkHTH4Tb(PDn)CUwgndbmmfj0)Oz2ynZrUMXkEVanZhd1gMI0mFmflPzkRe2gI3g4xvqqDP9CIawopvZuqTtO20mL9dbmGxF8f1gqZ8XqbGjrAMdxekRe2gI3g4N218)pAz0meWWuKq)JMzJ1mh5AgR49c0mFmuByksZ8XuSKMPSsyBiEBGFvbb1L2Z5zy5WHMPGANqTPz(yO2WuuL9OqmQxu7FdO1nVxqorZ5IjLk4gco5x9Wzr9dceoFrs5ebSCISM5JHcatI0mhUiuwjSneVnWpTR5)xOLrZqadtrc9pAMcQDc1MM5JHAdtr1dxekRe2gI3g4xorZHN58XqTHPO6HlcooIo8vjYHlUYbJfcQEFLWw1fwOGGmhVIijRbxoralhoQ)LdxCLZftkvWneCYV6HZI6heiC(IKYjcy5e5CIMtzxLyLdQ3xjSvDHfkiiZXRisYAWLte5WbpYHpAgR49c0mhUjw5bHbkK218)eOLrZqadtrc9pAMcQDc1MM5JHAdtr1dxekRe2gI3g4xorZbQHJ7bejzn4Y55Ck7QeRCq9(kHTQlSqbbzoEfrswdonJv8EbAMd3eR8GWafs7AxZGX2kHwgn)COLrZqadtrc9pAMcQDc1MMjs54MIaEf0WX9Zn1dcvjGHPirorZbXciOfbNQEd(g89LDjGPmbvjGHPirorZ5IjLk4gco5x9Wzr9dceoFrs58CoYsZyfVxGM5W7pAxZ)FAz0meWWuKq)JMPGANqTPzUysPcUHGt(LteWY5pnJv8EbAMdNf1piq48fjPDn)pvlJMHagMIe6F0mfu7eQnntzxLyLdQhHqMtIa2cOWf3pOAb3qWPlaHSI3lWu5ebSC(R(pYkhU4kNBzvynquvKjcyFd0lnPyfvjGHPirorZjs5GXcbvvKjcyFd0lnPyfvzJ1mwX7fOzocHmNebSfqHlUFqAxZFK1YOzSI3lqZaxTReMYeKMHagMIe6F0UMFzPLrZyfVxGMbZkpo3W0meWWuKq)J21U21mFi01lqZ)F84pEWXFCWdnJCdbAa8tZWjL9)k)pj()VCICYrgCkNwkErEoqlkNFFozkhNe)oheXzW2isKZTsuogRVsMtICk4gaoD189tSbuopLtKdNUGpeYjro)gXciOfbNQYUFNJV58BelGGweCQk7QeWWuK435WtoEjFQ57NydOC4CoroC6c(qiNe58BelGGweCQk7(Do(MZVrSacArWPQSRsadtrIFNdp54L8PMVLbNYbAvQvEdGNJXISlh5eIYH9ironihhNYXkEVGCu955GX65iNquoG1ZbAzbICAqoooLJjelihH5gMDeNiFNJSLZ9vcBvxyHccYC8GX6Bb1E(oFZjL9)k)pj()VCICYrgCkNwkErEoqlkNFliiJv5)oheXzW2isKZTsuogRVsMtICk4gaoD18Tm4uoqRsTYBa8CmwKD5iNquoShjYPb544uowX7fKJQpphmwph5eIYbSEoqllqKtdYXXPCmHyb5im3WSJ4e57CKTCUVsyR6cluqqMJhmwFlO2Z35BoPS)x5)jX))LtKtoYGt50sXlYZbAr587yevwjmZ)DoiIZGTrKiNBLOCmwFLmNe5uWnaC6Q57NydOC4CoroC6c(qiNe58BelGGweCQk7(Do(MZVrSacArWPQSRsadtrIFNJ55WzMZ0tmhEYXl5tnFNV5KY(FL)Ne))xoro5idoLtlfViphOfLZVlI735Giod2grICUvIYXy9vYCsKtb3aWPRMVFInGYrwCIC40f8HqojY53iwabTi4uv297C8nNFJybe0IGtvzxLagMIe)ohE(3l5tnFNV5KY(FL)Ne))xoro5idoLtlfViphOfLZVpNmLJhkI735Giod2grICUvIYXy9vYCsKtb3aWPRMVFInGY5poroC6c(qiNe58BelGGweCQk7(Do(MZVrSacArWPQSRsadtrIFNJ55WzMZ0tmhEYXl5tnFNV5KY(FL)Ne))xoro5idoLtlfViphOfLZVXyBL435Giod2grICUvIYXy9vYCsKtb3aWPRMVFInGYHdoroC6c(qiNe58BelGGweCQk7(Do(MZVrSacArWPQSRsadtrIFNdp54L8PMVZ3pjP4f5KiN)jhR49cYr1NF18TMjgTqTI0m8nhgwmxr(3C(1folLV5BoVGkKegHYHJNYDo)XJ)4r(oFZ3C(L7hkNpgQnmfvzpkeJ6f1(3aADZ7fKdBCo3Mt750xoh55GrqlIYroLd7r50EnFZ3C40vcRbuosSkVJvuoftPcwX7feu955qah10LJV5GibBHYjEDc4TPYbrYx0JA(oFZ3C(xejBC6kHzE(2kEVGRgJOYkHzoVWE1IJvFdXBFliFBfVxWvJruzLWmNxyVITURiraszFjH8gap47lBq(2kEVGRgJOYkHzoVWE9CYuoE(2kEVGRgJOYkHzoVWEvYqpiraArbbzoo3XiQSsyMhoQSaXbJdzLVTI3l4QXiQSsyMZlSxpvxOGbebrxiUJruzLWmpCuzbIdghC3qWqeeIoCdtr5BR49cUAmIkReM58c71d3eR8aMYe0XDdbdXciOfbNQsg6ryHcoofKSZjuWUZURb578nFZ5xAniNFDDZ7fKVTI3l4G9OlpY38nNN8rIC8nhb5esQbuoYXjhNq5u2vjw5Glh5w75aTOCyaVihm7irolih3qWj)Q5BR49coEH96hd1gMI4gyseSdicLfiAVxa3FmflbdJfcQEQUqbdicIUqv2yU46IjLk4gco5x9Wzr9dceoFrsraJZZ38nhota13Ck4gaoLdADZ7fKtdLJCkhC7dLtmQxu7FdO1nVxqoh55yarosSkVJvuoUHGt(LdBCnFBfVxWXlSx)yO2Wue3atIGXEuig1lQ9Vb06M3lG7pMILGfJ6f1(3aADZ7fe9IjLk4gco5x9Wzr9dceoFrsra7V8nFZHtXPYJC40xC5yEoqn688Tv8EbhVWETykvWkEVGGQpNBGjrWkIlFZ3C(vwqoqSk13Co5TxWPlhFZXXPCyCYuoojY5xx38Eb5WtSV5i2gapNB5U9CGwuHUCI3v1a450q5awhVbWZPVCSpwRmmfXNA(2kEVGJxyVIybbR49ccQ(CUbMeb7CYuooj4UHGDozkhNevtPY38nhzFCS6BoNQluWaIGOluoMNZF8MdN(V5iyrnaEoooLduJopho4rohvwG442GCcLJJBEorM3C40)nNgkN2ZHEzCJOlh5TJ3GCCCkha9spN)lN(ICwuo9Ldy9CyJZ3wX7fC8c71t1fkyarq0fI7gc2ftkvWneCYV6HZI6heiC(IKEMZJc1WX9aIKSgCrW5rXyHGQNQluWaIGOlufrswdUNHxevj7LrlRe2gI3g4xeWISSXtVLON5Gh8HZ(x(MV58VOErT)nNFDDZ7f8ewoprY)9Ld8(dLJLtbzX5yylRNdbie8V5aTOCCCkNZjt545WPV4YHNySTsqOCoVvQCq0ftfpN25tnNNWzJ5U9Ckgihmkhh38CUwkwr18Tv8EbhVWETykvWkEVGGQpNBGjrWoNmLJhkIJ7gc2hd1gMIQShfIr9IA)BaTU59cY38nNN8rIC8nhbb1akh54eihFZH9OCoNmLJNdN(IlNfLdgBRee6Y3wX7fC8c71pgQnmfXnWKiyNtMYXdooIo8vj4(JPyjy)jlEDtraV(PHVOkbmmfj4S)XdEDtraVkzNtOWcfoCtSYVkbmmfj4S)XdEDtraVE4MyLhG2c7vjGHPibN9pzXRBkc4vtzfu7FReWWuKGZ(hp49pzXz55ftkvWneCYV6HZI6heiC(IKIawK5t(MV5WPl4AbHYH9Aa8CSCyCYuoEoC6lYroobYbrwbVbWZXXPCiaHG)nhhhrh(Qe5BR49coEH9AXuQGv8EbbvFo3atIGDozkhpueh3nemcqi4FRccQlT)mSpgQnmfvpNmLJhCCeD4RsKV5Bo)Fd6dphZZjY8MJ82XxwpNxWKZIYrE745WSViNcQ9CWyHG4ohzXBoYBhpNxWKdpxw)AbLZ5KPCC(KV5BoCY2XZ5fm5yQBZbQb9HNJ55ezEZXGBn48CICoUHGt(Ldpxw)AbLZ5KPCC(KVTI3l44f2RftPcwX7feu95Cdmjcgud6dN7gcwzLW2q82a)GzGwYk4gcojcLyU4QSsyBiEBGFvbb1L2FgghCXfudh3disYAW9mmoIwwjSneVnWViG9uU4cJfcQEFLWw1fwOGGmhpyS(wqTxzJJwwjSneVnWViGfzU46IjLk4gco5x9Wzr9dceoFrsralYrlRe2gI3g4xeWIC(MV58Kpkhlhm2wjiuoYXjqoiYk4naEoooLdbie8V544i6WxLiFBfVxWXlSxlMsfSI3liO6Z5gysemm2wj4UHGracb)BvqqDP9NH9XqTHPO65KPC8GJJOdFvI8nFZ5jUYPZZjg1lQ9V50GCmLkNfkhhNYr2)VpXCWOIXEuoTNtXyp6YXY5)YPViFBfVxWXlSxnuXauWxeIao3nemcqi4FRccQlThbmoKfVeGqW)wreCcKVTI3l44f2RgQyakeZQokFBfVxWXlSxvnCC)cpHyfWLiGNVTI3l44f2Ryg8WcfCuxEC578nFZ5h2wji0LVTI3l4QySTsa7W7pC3qWIKBkc4vqdh3p3upiuLagMIerrSacArWPQ3GVbFFzxcyktqrVysPcUHGt(vpCwu)GaHZxK0ZYkFBfVxWvXyBLGxyVE4SO(bbcNVijUBiyxmPub3qWj)Ia2F5BR49cUkgBRe8c71JqiZjraBbu4I7he3neSYUkXkhupcHmNebSfqHlUFq1cUHGtxaczfVxGPIa2F1)rwCX1TSkSgiQkYebSVb6LMuSIQeWWuKiAKWyHGQkYebSVb6LMuSIQSX5BR49cUkgBRe8c7v4QDLWuMGY3wX7fCvm2wj4f2Ryw5X5gw(oFZ3C40DvIvo4Y38nNN8r58cduOCwiizdErKdgbTikhhNYbQrNNZHZI6heiC(IKYbcTs5iZIaMyZPSs0LtdQ5BR49cUArC8c71d3eR8GWafIB2JcleuaEraJdUBiyrcJfcQE4MyLhegOqv24OySqq1dNf1piqWxeWeBLnokgleu9Wzr9dce8fbmXwrKK1G7zypTkR8nFZHNpzGIUlhtHit8nh24CWOIXEuoYPC8DFKddUjw558)BH94toShLdZxjSvD5SqqYg8IihmcAruoooLduJopNdNf1piq48fjLdeALYrMfbmXMtzLOlNguZ3wX7fC1I44f2R3xjSvDHfkiiZX5M9OWcbfGxeW4G7gcggleu9Wzr9dce8fbmXwzJJIXcbvpCwu)GabFratSvejzn4Eg2tRYkFBfVxWvlIJxyVcPm4KszEVaUBiyFmuBykQEarOSar79cIgPZjt54KOkzaxr5BR49cUArC8c7viLbNukZ7fekkYahXDdbtqySqqviLbNukZ7furKK1G75)Y3wX7fC1I44f2RFmqF4C3qW4jIfqqlcovLm0JWcfCCkizNtOGDNDxdIwwjSneVnWVQGG6s7pdJdzZnfb8QGOycfohzobNKQeWWuKGlUqSacArWPQGmhx9nC4MyLFrlRe2gI3g43ZCWNOySqq17Re2QUWcfeK54v24OySqq1d3eR8GWafQYghvYoNqb7o7UgeqKK1GdgpIIXcbvfK54QVHd3eR8Rkw5G8nFZ5F3vLd0IYrMfbmXMtmIKnM9f5iVD8CyWFroiYeFZroobYbSEoiwaObWZH5)R5BR49cUArC8c714DvbeDllQqCdTOaGEPdJdUBiyUPiGxpCwu)GabFratSvcyyksensUPiGxpCtSYdqBH9QeWWuKiFZ3CEYhLJmlcyInNyeLdZ(ICKJtGCKt5GBFOCCCkhcqi4FZroo54ekhi0kLt8UQgaph5TJVSEom)FolkNNqSNNdCcqitP(wZ3wX7fC1I44f2RholQFqGGViGjwUBiyeGqW)gbmoNhr)yO2Wuu9aIqzbI27feTSRsSYb17Re2QUWcfeK54v24OLDvIvoOE4MyLhegOq1cUHGtxeW4iFBfVxWvlIJxyVEeczojcylGcxC)G4U8TOOGBi4KFW4G7gc2hd1gMIQhqeklq0EVGOrsSE9ieYCseWwafU4(bfeRx9U8ObWJ6gco5vVLOGVbrtra7po4IlOgoUhqKK1G7zyYk6ftkvWneCYV6HZI6heiC(IKE(P5BR49cUArC8c71JIV(4UHG9XqTHPO6beHYceT3liAzLW2q82a)QccQlThbmoY38nNN8r5W8vcBvxoliNYUkXkhKdpniNq5a1OZZHb8c(Kdlqr3LJCkhdr5aFBa8C8nN4nohzweWeBogqKJyZbSEo42hkhgCtSYZ5)3c7vZ3wX7fC1I44f2R3xjSvDHfkiiZX5UHG9XqTHPO6beHYceT3likpDtraVsGpKAJBa8WHBIv(vjGHPibxCv2vjw5G6HBIvEqyGcvl4gcoDraJd(eLNrYnfb86HZI6hei4lcyITsadtrcU4Ynfb86HBIvEaAlSxLagMIeCXvzxLyLdQholQFqGGViGj2kIKSgCr8hFY38nNNeuoMqC5yikh2yUZ5aDmLJJt5Sakh5TJNJALtNNJmY8IAop5JYroobYr8TbWZbYoNq544giho9FZrqqDP9CwuoG1Z5CYuoojYrE74lRNJb(MdN(V18Tv8EbxTioEH9QKHEqIa0IccYCCUlFlkk4gco5hmo4UHGHSweOpeWRMqCv24O80neCYRElrbFdIMEUSsyBiEBGFvbb1L25IRiDozkhNevtPIwwjSneVnWVQGG6s7raRehKSxgUyci4t(MV58KGYbS5ycXLJ8wPYr0uoYBhVb544uoa6LEopLhh35WEuo)sOxKZcYbBVlh5TJVSEog4BoC6)wZ3wX7fC1I44f2Rsg6bjcqlkiiZX5UHGHSweOpeWRMqC1geXt5HSHSweOpeWRMqCvblY8EbrlRe2gI3g4xvqqDP9iGvIds2ldxmbe5BR49cUArC8c71d3eR8aMYe0XDdb7JHAdtr1dicLfiAVxq0YkHTH4Tb(vfeuxApcy)LVTI3l4QfXXlSxPc(2a4befJAjdi4UHG9XqTHPO6beHYceT3liAzLW2q82a)QccQlThbS)IYZpgQnmfvzpkeJ6f1(3aADZ7fWfxxmPub3qWj)QholQFqGW5ls6zyrMp5B(MdNSD8Cy(FUZPHYbSEoMcrM4BoIfqCNd7r5iZIaMyZrE745WSVih24A(2kEVGRwehVWE9Wzr9dce8fbmXYDdbZnfb86HBIvEaAlSxLagMIer)yO2Wuu9aIqzbI27fefJfcQEFLWw1fwOGGmhVYgNVTI3l4QfXXlSxpCtSYdcduiUBiyrcJfcQE4MyLhegOqv24OqnCCpGijRb3ZW(f86MIaE9yXCcbXcNQeWWuKiFZ3C4FbY2ftLCoNfckh5TJNJALtOCIr9MVTI3l4QfXXlSxJxVxa3nemmwiOkMAxHI98kISIZfxqnCCpGijRb3ZpLhCXfgleu9(kHTQlSqbbzoELnokpXyHGQhUjw5bmLjORYgZfxLDvIvoOE4MyLhWuMGUkIKSgCpdJdEWN8Tv8EbxTioEH9kMAxraIf9L7gcggleu9(kHTQlSqbbzoELnoFBfVxWvlIJxyVIrOJqpAaCUBiyySqq17Re2QUWcfeK54v248Tv8EbxTioEH9kuJim1UcUBiyySqq17Re2QUWcfeK54v248Tv8EbxTioEH9Qbk05itfkMsXDdbdJfcQEFLWw1fwOGGmhVYgNV5BoVGGmwLNdKPuyw5roqlkh2ZWuuoTtshNiNN8r5iVD8Cy(kHTQlNfkNxqMJxZ3wX7fC1I44f2RShfANKoUBiyySqq17Re2QUWcfeK54v2yU4cQHJ7bejzn4E(pEKVZ38nN)Vb9HtOlFZ3C4K4TIYH9Aa8C(xejrI2nVxa35yF2wKtXoVbWZHr1fkhdiY5fDHYroobYHb3eR8CEHbkuo9LZTlihFZbJYH9ib35qVSqXEoqlkN)JFrTbY3wX7fCvOg0hoSpgQnmfXnWKiyXisIeHdicLfiAVxa3FmflbZnfb8AmIKir7M3lOsadtrIOxmPub3qWj)QholQFqGW5ls6zEklzRSFiGb8kGkOvTibFIgPY(HagWRp(IAdKVTI3l4QqnOpCEH96P6cfmGii6cXDdblsFmuBykQgJijseoGiuwGO9EbrVysPcUHGt(vpCwu)GaHZxK0ZCE0iHXcbvpCtSYdcduOkBCumwiO6P6cfmGii6cvrKK1G7zOgoUhqKK1GlkIGq0HBykkFBfVxWvHAqF48c71t1fkyarq0fI7gc2hd1gMIQXisIeHdicLfiAVxq0YUkXkhupCtSYdcduOAb3qWPlaHSI3lWupZr9FKvumwiO6P6cfmGii6cvrKK1G75YUkXkhuVVsyR6cluqqMJxrKK1Glkpl7QeRCq9WnXkpimqHQiYeFJIXcbvVVsyR6cluqqMJxrKK1Gt2WyHGQhUjw5bHbkufrswdUN5O(hFY3wX7fCvOg0hoVWE9JHAdtrCdmjc29OJdi2yNfrC)XuSemj7CcfS7S7AqarswdUi4bxCfj3ueWRGgoUFUPEqOkbmmfjI6MIaEvyOhHd3eR8kbmmfjIIXcbvpCtSYdcduOkBmxCDXKsfCdbN8RE4SO(bbcNViPiGX5C)FGuXekN)td1gMIYbAr58RSXolIQ5W8OJZrWIAa8C(L25ekhz)D2DniNfLJGf1a458cduOCK3oEoVWqpYXaICaBo83WX9Zn1dcvZ38nN)JefNdBCo)kBSZIOCAOCApN(YXWwwphFZbXcYzz9A(2kEVGRc1G(W5f2Ri2yNfrC3qWI0hd1gMIQ3JooGyJDwef1neCYRElrbFdIMKnejzn4IGZJIiieD4gMIY3wX7fCvOg0hoVWE9OcI8GtfCqZzWs5B(MZVKv5TyDVbWZXneCYVCCCZZrERu5O6puoqlkhhNYrWImVxqoluo)kBSZIOCqeeIo8CeSOgapNydiiPUuZ3wX7fCvOg0hoVWEfXg7SiI7Y3IIcUHGt(bJdUBiyr6JHAdtr17rhhqSXolIIgPpgQnmfvzpkeJ6f1(3aADZ7fe9IjLk4gco5x9Wzr9dceoFrsra7VOUHGtE1Bjk4Bq0ueW4PS4LN)XzlRe2gI3g4hF4tuebHOd3Wuu(MV58ReeIo8C(v2yNfr5qgs9nNgkN2ZrERu5qVmUruocwudGNdZxjSvD1CEXMJJBEoiccrhEonuom7lYbo5xoiYeFZPb544uoa6LEoY6Q5BR49cUkud6dNxyVIyJDweXDdblsFmuBykQEp64aIn2zruuejzn4EUSRsSYb17Re2QUWcfeK54vejzn44LdEeTSRsSYb17Re2QUWcfeK54vejzn4EgMSI6gco5vVLOGVbrtYgIKSgCru2vjw5G69vcBvxyHccYC8kIKSgC8kR8Tv8EbxfQb9HZlSxXuw5riELlie3neSi9XqTHPOk7rHyuVO2)gqRBEVGOxmPub3qWj)Ia2tZ3wX7fCvOg0hoVWEL(0xHqMt578nFZHXjt545WP7QeRCWLVTI3l4QNtMYXdfXXlSx)yO2Wue3atIGD4IGJJOdFvcU)ykwcwzxLyLdQhUjw5bHbkuTGBi40fGqwX7fyQiGXr9FKf3)hivmHY5)0qTHPO8nFZ5)0a9HNtdLJCkhdr5uS44gapNfKZlmqHYPGBi40vZHZSHuFZbJGweLduJophHbkuonuoYPCWTpuoGnh(B44(5M6bHYbJ1Z5fg6rom4MyLNtdYzrccLJV5aN8C(v2yNfr5WgNdpbBo)s7CcLJS)o7UgWNA(2kEVGREozkhpuehVWE9Jb6dN7gcgpJ0hd1gMIQhUi44i6WxLGlUIKBkc4vqdh3p3upiuLagMIerDtraVkm0JWHBIvELagMIe8jAzLW2q82a)QccQlThbhrJeIfqqlcovLm0JWcfCCkizNtOGDNDxdY3wX7fC1Zjt54HI44f2RX7Qci6wwuH4gArba9shghCtV0rwWKwwGdlY8G7)DxvoqlkhgCtSYLiLihEZHb3eR8Zr9dkhwGIUlh5uogIYXWwwphFZPyX5SGCEHbkuofCdbNUAoCMaQV5ihNa58)nqKdNKSha6UC6lhdBz9C8nheliNL1R5BR49cU65KPC8qrC8c71d3eRCjsj4UHGracb)BeWImpIsacb)BvqqDP9iGXbpIgPpgQnmfvpCrWXr0HVkr0YkHTH4Tb(vfeuxApcoIkimwiOkudeb5K9aq3vrKK1G7zoY38nho9FZXXr0HVkXLd0IYHaoHAa8CyWnXkpNxyGcLVTI3l4QNtMYXdfXXlSx)yO2Wue3atIGD4IqzLW2q82a)4(JPyjyLvcBdXBd8RkiOU0EeW(JxmwiO6HBIvEatzc6QSX5BR49cU65KPC8qrC8c71pgQnmfXnWKiyhUiuwjSneVnWpU)ykwcwzLW2q82a)QccQlThbSNYDdbRSFiGb86JVO2a5BR49cU65KPC8qrC8c71pgQnmfXnWKiyhUiuwjSneVnWpU)ykwcwzLW2q82a)QccQlT)mmo4UHG9XqTHPOk7rHyuVO2)gqRBEVGOxmPub3qWj)QholQFqGW5lskcyroFZ3CEHbkuocwudGNdZxjSvD5SOCmS9dLJJJOdFvIA(2kEVGREozkhpuehVWE9WnXkpimqH4UHG9XqTHPO6HlcLvcBdXBd8lkp)yO2Wuu9Wfbhhrh(QeCXfgleu9(kHTQlSqbbzoEfrswdUiGXr9pU46IjLk4gco5x9Wzr9dceoFrsralYrl7QeRCq9(kHTQlSqbbzoEfrswdUi4Gh8jFZ3C(HfbYbrswdAa8CEHbk0LdgbTikhhNYbQHJ75qaXLtdLdZ(ICKVGF75Gr5Git8nNgKJ3sunFBfVxWvpNmLJhkIJxyVE4MyLhegOqC3qW(yO2Wuu9WfHYkHTH4Tb(ffQHJ7bejzn4EUSRsSYb17Re2QUWcfeK54vejzn4Y35B(MdJtMYXjro)66M3liFZ3CEsq5W4KPC8x)yG(WZXquoSXCNd7r5WGBIv(5O(bLJV5GracQ9CGqRuoooLtSDx)HYbBbSxogqKZ)3aroCsYEaO74oh6dbYPHYroLJHOCmphj7L5WP)Bo8KfOO7YH9Aa8C(L25ekhz)D2DnGp5BR49cU65KPCCsa7WnXk)Cu)G4UHGXtmwiO65KPC8kBmxCHXcbv)yG(WRSX8jQKDoHc2D2DniGijRbhmEKV5Bo)Fd6dphZZ5P8MdN(V5iVD8L1Z5fm58AorM3CK3oEoVGjh5TJNddolQFqGCKzratS5GXcbLdBCo(MJ9zBro3kr5WP)BoYTZPCU2znVxWvZ38nhzV62CodIYX3CGAqF45yEorM3C40)nh5TJNd9sR4QV5e5CCdbN8RMdpzmjkh7Yzz9RfuoNtMYXR8jFZ3C()g0hEoMNtK5nho9FZrE74lRNZly4ohzXBoYBhpNxWWDogqKdNNJ82XZ5fm5yqoHY5)0a9HNVTI3l4QNtMYXjbVWETykvWkEVGGQpNBGjrWGAqF4C3qWWyHGQholQFqGGViGj2kBC0YkHTH4Tb(vfeuxA)zy)XfxxmPub3qWj)QholQFqGW5lscwKJwwjSneVnWViGfzU4QSsyBiEBGFvbb1L2FgghYgpDtraVkikMqHZrMBWjPkbmmfjIIXcbv)yG(WRSX8jFBfVxWvpNmLJtcEH96H3F4UHG5MIaEf0WX9Zn1dcvjGHPiruelGGweCQ6n4BW3x2LaMYeu0lMuQGBi4KF1dNf1piq48fj9SSY38nNNCCo(MZtZXneCYVCEquCoSX58)nqKdNKSha6UCW(Mt5Br1a45WGBIv(5O(bvZ3wX7fC1Zjt54KGxyVE4MyLFoQFqCx(wuuWneCYpyCWDdbtqySqqvOgicYj7bGURIijRb3ZCe9IjLk4gco5x9Wzr9dceoFrspd7PrDdbN8Q3suW3GOjzdrswdUi488nFZ5)xuoXOErT)nh06M3lG7CypkhgCtSYph1pOC2pekhgFrs5iVD8C4K)YCm4wdoph24C8nNiNJBi4KF5SOCAOC(Fozo9LdIfaAa8CwiOC45cYXaFZXKwwGNZcLJBi4KF8jFBfVxWvpNmLJtcEH96HBIv(5O(bXDdb7JHAdtrv2JcXOErT)nGw38Ebr5PGWyHGQqnqeKt2daDxfrswdUN5GlUCtraVkNS4fizNtOkbmmfjIEXKsfCdbN8RE4SO(bbcNViPNHfz(KVTI3l4QNtMYXjbVWE9Wzr9dceoFrsC3qWUysPcUHGt(fbSNYlpXyHGQoofqR7eOYgZfxiwabTi4u1EygQVWTSQaeYGlrapAzbc22RcIIjuqyWHtORImWJiG9p8jkpXyHGQ3xjSvDHfkiiZXdgRVfu7v2yU4ksySqq1yejrI2nVxqLnMlUUysPcUHGt(fbmzXN8nFZHb3eR8Zr9dkhFZbrqi6WZ5)BGihojzpa0D5yaro(MdboweLJCkNIbYPyi03C2pekhlhiwLkN)NtMtd8nhhNYbqV0ZHzFronuoX7DnMIQ5BR49cU65KPCCsWlSxpCtSYph1piUBiyccJfcQc1arqozpa0Dvejzn4EgghCXvzxLyLdQ3xjSvDHfkiiZXRisYAW9mh)IOccJfcQc1arqozpa0Dvejzn4EUSRsSYb17Re2QUWcfeK54vejzn4Y3wX7fC1Zjt54KGxyVcxTReMYee3nemmwiOAmHGwK5Ki8HAWvp3kpIaMSIwwGGT9AmHGwK5Ki8HAWvrg4reW44P5BR49cU65KPCCsWlSxpCtSYph1pO8Tv8Ebx9CYuooj4f2RfCYIdh(6C3qWIKBi4Kx7lGT3fTSsyBiEBGFvbb1L2JaghrXyHGQh(6HgeCCkim0JkBCucqi4FRElrbFdrMhraViQs2l1mxmv08)hNZH21Uwd]] )

    
end
