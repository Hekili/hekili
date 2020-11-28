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
        return false
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


    spec:RegisterPack( "Subtlety", 20201128, [[dafqJbqisf9isLAtIsFccOyuifDkKcRcreVcrzwiQUfeK2Ls(fPQggIWXGqltuXZevY0ivY1ivX2GG6BKkOXrQsDoerL1bbuAEIuDpLY(qk9perv1bjvGwOiLhsQsMOOsDrervzJqq8riGQgjPcvojeawPsvVKuHQmtsfkUjPcyNiv9tiGkdfruwkPc5PGAQivUkeG2kIOkFfciNLuHQAVe(lvgmWHfwmcpMQMmjxg1Mb5Zq0OH0PLSAsfk9ArXSj62KYUv1Vvz4I44iI0YH65kMoLRJKTRu57IKXdb68IQwpeanFeP9l1cef0jGvHXc6ZHe5qcermh9EHicJijYvocylFclGtcFMajlG)qJfWWueMKT8c4KiV8cLGob8CuyplGrnlzqGvF9rwgkfXYFA6pLgLmS6EpoGm9NsZRVaMGQKgcGxqiGvHXc6ZHe5qcermh9EHicJijYjxc4GYqpSagU00lbmAPu8lieWkE8cyD3aykctYw(gOJoKuCVx3nG(BhRrW4gKJEtEdYHe5qcbSSgBe0jGhJdPHYkbDc6ruqNaM)GqYkrAcypUmgxHaMMnGGccAnghsdDrL0asjTbeuqqRDXxd6IkPb0qahERUxapOH6sngUYWctqFoc6eW8heswjsta7XLX4keWeuqqRbLcxz43zh(d1TOsAq2g4pnIZLC1BZsXqLVSgK(wdYrahERUxa7dP0fERU3jRXeWYAm3hASagQ(AqfMG(CjOtaZFqizLinbShxgJRqapjSu6SaJKTznOu4kd)UXoSwd2AGUAq2g4pnIZLC1BtdODRb6sahERUxa7dP0fERU3jRXeWYAm3hASagQ(AqfMGEDjOtaZFqizLinbShxgJRqa7pnIZLC1BZsXqLVSgK(wdqSbi0gqZgyHKFBPyoHXUXWHfizTf)bHKvniBdiOGGw7IVg0fvsdOHao8wDVa2hsPl8wDVtwJjGL1yUp0ybmu91Gkmb96rqNaM)GqYkrAcypUmgxHa2cj)26lKO2yHmdJx8hesw1GSnat9m0HrYlR(8o7qWY7iKHIxmjLQssyvdY2GjHLsNfyKSnRbLcxz43n2H1Aq6nqpc4WB19c4bT2jmb9iSGobm)bHKvI0eWH3Q7fWdAOUuJHRmSa2JlJXviGvmbfe0cQELlfhzEEMfM1I6NgKEdqSbzBWKWsPZcms2M1GsHRm87g7WAni9TgKRgKTbwGrY2Ykn2zNtvCdqOnaZAr9tdOTbiSa2N3lzNfyKSnc6ruyc61Hc6eW8heswjsta7XLX4keW7cCfesErnSlbxhUS8o8zHv33GSnGMnqXeuqqlO6vUuCK55zwywlQFAq6naXgqkPnWcj)2kfhj3RfJX4f)bHKvniBdMewkDwGrY2SgukCLHF3yhwRbPV1aD1aAiGdVv3lGh0qDPgdxzyHjOxVf0jG5piKSsKMa2JlJXviGNewkDwGrY20aA3AqUAaznGMnGGccALGznwvwy19lQKgqkPnGGccAzOSdFMX)IkPbKsAdWupdDyK8kYebUg3CusheoqQXVTyskvLKWQgKTb(7vuLTumNWyNkqIKXZchFMgq7wd0HnGgc4WB19c4bLcxz43n2H1eMGEsobDcy(dcjRePjG94YyCfcyftqbbTGQx5sXrMNNzHzTO(PbPV1aeBaPK2a)Ds1L6xtEnItoUdYP4WqxywlQFAq6nar9UbzBGIjOGGwq1RCP4iZZZSWSwu)0G0BG)oP6s9RjVgXjh3b5uCyOlmRf1pc4WB19c4bnuxQXWvgwyc6rKec6eW8heswjstadDy3ZiOjOhrbC4T6EbCYDshMNJc7zHjOhref0jG5piKSsKMa2JlJXviGjOGGwjmg6WHXk3oU(znw4Z0aA3AGEAq2g4Vxrv2kHXqhomw52X1plC8zAaTBnaXCjGdVv3lGrkVtJqgkwyc6rmhbDc4WB19c4bnuxQXWvgwaZFqizLinHjmbmpd)EEe0jOhrbDcy(dcjRePjG94YyCfcy(zmY8lR0yNDoTabBaTnaXgKTb6SbeuqqRjVgXjh3b5uCyOlQKgKTb0Sb6SbQZw(798B4WyLdsgASJGc)lR8zQhzdY2aD2GWB19l)9E(nCySYbjdnEvVdswirTgqkPnaIskDy2JgyKSZknUbP3aKE1slqWgqdbC4T6EbS)Ep)gomw5GKHglmb95iOtaZFqizLinbShxgJRqaRZg4VtQUu)Aqd1LYridfplQKgKTb(7KQl1VM8AeNCChKtXHHUOsAaPK2aOcjQ5WSwu)0G03AaIKqahERUxatiVt5oiNHYo(zT8ctqFUe0jGdVv3lGrsfyvfV7GCbcqgFgQaM)GqYkrActqVUe0jG5piKSsKMa2JlJXviGPzdMewkDwGrY2SgukCLHF3yhwRb0U1GCAaPK2aCukhVJFBfk1SQVb02aeMenGgniBd0zd83jvxQFn51io54oiNIddDrL0GSnqNnGGccAn51io54oiNIddDrL0GSnGFgJm)sXqLVSgq7wdYfjeWH3Q7fWqNNAyLlqaY4YyhbhActqVEe0jG5piKSsKMa2JlJXviGNewkDwGrY2SgukCLHF3yhwRb0U1GCAaPK2aCukhVJFBfk1SQVb02aeMec4WB19c4ekCbLVEKoczmMWe0JWc6eW8heswjsta7XLX4keWeuqqlm7Zi5zCqh2ZlQKgqkPnGGccAHzFgjpJd6WE25pQ3y8ASWNPbP3aejHao8wDVa2qzh1tCuVYbDyplmb96qbDc4WB19cyCLKizx9Ujj8SaM)GqYkrActqVElOtaZFqizLinbShxgJRqa7VtQUu)AYRrCYXDqofhg6cZAr9tdsVb6PbKsAdGkKOMdZAr9tdsVbiQ3c4WB19c4uhwQ2X17W8CF8Ewyc6j5e0jG5piKSsKMa2JlJXviG5NXiZ3G0BGUirdY2ackiO1KxJ4KJ7GCkom0fvIao8wDVawJ1oCE3b5Ku(s5uyo0gHjOhrsiOtaZFqizLinbShxgJRqadvirnhM1I6NgKEdqCPNgqkPnGMnGMnWcms2wOCin0vI3AaTnqVjrdiL0gybgjBluoKg6kXBni9TgKdjAanAq2gqZgeER2Xo(zTINgS1aeBaPK2aOcjQ5WSwu)0aABqoKCnGgnGgnGusBanBGfyKSTSsJD25s8Mlhs0aABqUirdY2aA2GWB1o2XpRv80GTgGydiL0gavirnhM1I6NgqBd0LUAanAaneWH3Q7fWyosQhPdsgA8imHjGvmuqjnbDc6ruqNao8wDVaot5ZiG5piKSsKMWe0NJGobm)bHKvI0eWxIaEytahERUxaVlWvqizb8UqsXcyckiO1ilp7Ix5uLNxujnGusBWKWsPZcms2M1GsHRm87g7WAnG2TgGWc4Db29HglGNx583RkRUxyc6ZLGobm)bHKvI0eWH3Q7fW(qkDH3Q7DYAmbSSgZ9HglG9Qryc61LGobm)bHKvI0eWECzmUcb8yCinuwTcPuahERUxaJPEx4T6ENSgtalRXCFOXc4X4qAOSsyc61JGobm)bHKvI0eWECzmUcb8KWsPZcms2M1GsHRm87g7WAni9gGWniBdGkKOMdZAr9tdOTbiCdY2ackiO1ilp7Ix5uLNxywlQFAq6naPxT0ceSbzBG)0ioxYvVnnG2TgORgGqBanBGvACdsVbisIgqJgqsAqoc4WB19c4rwE2fVYPkplmb9iSGobm)bHKvI0eWxIaEytahERUxaVlWvqizb8UqsXc4eCD4YY7WNfwDFdY2GjHLsNfyKSnRbLcxz43n2H1AaTBnihb8Ua7(qJfWud7sW1HllVdFwy19ctqVouqNaM)GqYkrAcypUmgxHaExGRGqYlQHDj46WLL3HplS6EbC4T6EbSpKsx4T6ENSgtalRXCFOXc4X4qAOoVAeMGE9wqNaM)GqYkrAc4lrapSjGdVv3lG3f4kiKSaExiPybCo6PbK1alK8BRDfYdV4piKSQbKKgKdjAaznWcj)2slgJXUdYnOH6snl(dcjRAajPb5qIgqwdSqYVTg0qDPCqNNAw8hesw1assdYrpnGSgyHKFBfYWJll)I)GqYQgqsAqoKObK1GC0tdijnGMnysyP0zbgjBZAqPWvg(DJDyTgq7wd0vdOHaExGDFOXc4X4qAOodfZd6jvctqpjNGobm)bHKvI0eWECzmUcbm)mgz(LIHkFzni9TgSlWvqi51yCinuNHI5b9KkbC4T6EbSpKsx4T6ENSgtalRXCFOXc4X4qAOoVAeMGEejHGobm)bHKvI0eWECzmUcbS)0ioxYvVnnyRbXxAHhnWizLZNiGdVv3lG9Hu6cVv37K1ycyznM7dnwadvFnOctqpIikOtaZFqizLinbShxgJRqa7pnIZLC1BZsXqLVSgK(wdqSbKsAdGkKOMdZAr9tdsFRbi2GSnWFAeNl5Q3Mgq7wdYLao8wDVa2hsPl8wDVtwJjGL1yUp0ybmu91Gkmb9iMJGobm)bHKvI0eWECzmUcb8KWsPZcms2M1GsHRm87g7WAnG2TgORgKTb(tJ4Cjx920aA3AGUeWH3Q7fW(qkDH3Q7DYAmbSSgZ9HglGHQVguHjOhXCjOtaZFqizLinbShxgJRqaZpJrMFPyOYxwdsFRb7cCfesEnghsd1zOyEqpPsahERUxa7dP0fERU3jRXeWYAm3hASaMGQKkHjOhrDjOtaZFqizLinbShxgJRqaZpJrMFPyOYxwdODRbiQNgqwd4NXiZVWms(fWH3Q7fWb2hp7SdJ53eMGEe1JGobC4T6EbCG9XZUek5Wcy(dcjRePjmb9iIWc6eWH3Q7fWYcjQnoDSukKA8Bcy(dcjRePjmb9iQdf0jGdVv3lGjcKUdYz4YNzeW8heswjstyctaNGz)PreMGob9ikOtahERUxahjjY8UKRM7fW8heswjstyc6ZrqNao8wDVaEmoKgQaM)GqYkrActqFUe0jG5piKSsKMao8wDVawlWzyLd6WofhgQaobZ(tJim3W(7vJagr9imb96sqNaM)GqYkrAc4WB19c4rwE2fVYPkplG94YyCfcymdH5bniKSaobZ(tJim3W(7vJagrHjOxpc6eW8heswjsta7XLX4keWyQNHomsEPf4mUdYzOStlgJXUyMyM6xmjLQssyLao8wDVaEqd1LYridfpctycycQsQe0jOhrbDcy(dcjRePjG94YyCfcyD2alK8BRVqIAJfYmmEXFqizvdY2am1ZqhgjVS6Z7SdblVJqgkEXKuQkjHvniBdMewkDwGrY2SgukCLHF3yhwRbP3a9iGdVv3lGh0ANWe0NJGobm)bHKvI0eWECzmUcb8KWsPZcms2Mgq7wdYrahERUxapOu4kd)UXoSMWe0NlbDcy(dcjRePjG94YyCfcy)Ds1L6xdJXHXkhX9SBsQm8YJgyK84GWH3Q7dzdODRb5S0H6PbKsAdMJssuVAj5q5iY7yem0sK8I)GqYQgKTb6SbeuqqljhkhrEhJGHwIKxujc4WB19c4HX4WyLJ4E2njvgwyc61LGobC4T6Ebms5DAeYqXcy(dcjRePjmb96rqNao8wDVaMi8zglieW8heswjstycta7vJGob9ikOtaZFqizLinbShxgJRqaRZgqqbbTg0qDPCQ498IkPbzBabfe0AqPWvg(D2H)qDlQKgKTbeuqqRbLcxz43zh(d1TWSwu)0G03AqUw6rahERUxapOH6s5uX7zbm1WUdcYH0Re0JOWe0NJGobm)bHKvI0eWECzmUcbmbfe0AqPWvg(D2H)qDlQKgKTbeuqqRbLcxz43zh(d1TWSwu)0G03AqUw6rahERUxap51io54oiNIddvatnS7GGCi9kb9ikmb95sqNaM)GqYkrAcypUmgxHaExGRGqYR5vo)9QYQ7Bq2gOZgmghsdLvlT4njlGdVv3lGHKbswkdRUxyc61LGobm)bHKvI0eWECzmUcbSIjOGGwqYajlLHv3VWSwu)0G0Bqoc4WB19cyizGKLYWQ7DEjh)WctqVEe0jG5piKSsKMa2JlJXviGPzdWupdDyK8slWzChKZqzNwmgJDXmXm1VyskvLKWQgKTb(tJ4Cjx92Sumu5lRbPV1GC1asjTbyQNHomsEP4WqL5DdAOUuZIjPuvscRAq2g4pnIZLC1BtdsVbi2aA0GSnGGccAn51io54oiNIddDrL0GSnGGccAnOH6s5uX75fvsdY2aTymg7IzIzQ3HzTO(PbBnGeniBdiOGGwkomuzE3GgQl1SuxQxahERUxaVl(AqfMGEewqNaM)GqYkrAc4WB19c4K7Komphf2ZcypUmgxHa2cj)2AqPWvg(D2H)qDl(dcjRAq2gOZgyHKFBnOH6s5Gop1S4piKSsadDy3ZiOjOhrHjOxhkOtaZFqizLinbShxgJRqaZpJrMVb0U1aeMeniBd2f4kiK8AELZFVQS6(gKTb(7KQl1VM8AeNCChKtXHHUOsAq2g4VtQUu)Aqd1LYPI3ZlpAGrYtdODRbikGdVv3lGhukCLHFND4puNWe0R3c6eW8heswjstahERUxapmghgRCe3ZUjPYWcypUmgxHaExGRGqYR5vo)9QYQ7Bq2gOZgOoBnmghgRCe3ZUjPYWo1zlR8zQhzdY2alWizBzLg7SZPkUb0U1GCqSbKsAdGkKOMdZAr9tdsFRb6PbzBWKWsPZcms2M1GsHRm87g7WAni9gKlbSpVxYolWizBe0JOWe0tYjOtaZFqizLinbShxgJRqaVlWvqi518kN)Evz19niBd8NgX5sU6TzPyOYxwdODRbikGdVv3lGhozQryc6rKec6eW8heswjsta7XLX4keW7cCfesEnVY5VxvwDFdY2aA2alK8Bl(3XYlPEKUbnuxQzXFqizvdiL0g4VtQUu)Aqd1LYPI3ZlpAGrYtdODRbi2aA0GSnGMnqNnWcj)2AqPWvg(D2H)qDl(dcjRAaPK2alK8BRbnuxkh05PMf)bHKvnGusBG)oP6s9RbLcxz43zh(d1TWSwu)0aABqonGgc4WB19c4jVgXjh3b5uCyOctqpIikOtaZFqizLinbC4T6EbSwGZWkh0HDkomubShxgJRqaJJs54D8BRqPMfvsdY2aA2alWizBzLg7SZPkUbP3a)PrCUKREBwkgQ8L1asjTb6SbJXH0qz1kKYgKTb(tJ4Cjx92Sumu5lRb0U1aFItlqq3KWVQb0qa7Z7LSZcms2gb9ikmb9iMJGobm)bHKvI0eWECzmUcbmokLJ3XVTcLAw13aABqUirdqOnahLYX743wHsnlffoS6(gKTb(tJ4Cjx92Sumu5lRb0U1aFItlqq3KWVsahERUxaRf4mSYbDyNIddvyc6rmxc6eW8heswjsta7XLX4keW7cCfesEnVY5VxvwDFdY2a)PrCUKREBwkgQ8L1aA3Aqoc4WB19c4bnuxkhHmu8imb9iQlbDcy(dcjRePjG94YyCfc4DbUccjVMx583RkRUVbzBG)0ioxYvVnlfdv(YAaTBniNgKTb0Sb7cCfesErnSlbxhUS8o8zHv33asjTbtclLolWizBwdkfUYWVBSdR1G03AGUAaneWH3Q7fWSh9QhPdZj4slELWe0JOEe0jG5piKSsKMa2JlJXviGTqYVTg0qDPCqNNAw8hesw1GSnyxGRGqYR5vo)9QYQ7Bq2gqqbbTM8AeNCChKtXHHUOseWH3Q7fWdkfUYWVZo8hQtyc6reHf0jG5piKSsKMa2JlJXviG1zdiOGGwdAOUuov8EErL0GSnaQqIAomRf1pni9TgO3nGSgyHKFBnuegJHOqYl(dcjReWH3Q7fWdAOUuov8Ewyc6ruhkOtahERUxaNCwDVaM)GqYkrActqpI6TGobm)bHKvI0eWECzmUcbmbfe0AYRrCYXDqofhg6IkrahERUxatiVt5GOW5fMGEej5e0jG5piKSsKMa2JlJXviGjOGGwtEnItoUdYP4Wqxujc4WB19cycgpmot9ifMG(CiHGobm)bHKvI0eWECzmUcbmbfe0AYRrCYXDqofhg6IkrahERUxadvyMqENsyc6ZbrbDcy(dcjRePjG94YyCfcyckiO1KxJ4KJ7GCkom0fvIao8wDVaoEppgoKoFiLctqFo5iOtaZFqizLinbShxgJRqatqbbTM8AeNCChKtXHHUOsAaPK2aOcjQ5WSwu)0G0BqoKqahERUxatnSRmwBeMWeWJXH0qDE1iOtqpIc6eW8heswjstaFjc4HnbC4T6Eb8UaxbHKfW7cjflG93jvxQFnOH6s5uX75LhnWi5XbHdVv3hYgq7wdqCPd1JaExGDFOXc4bv5mumpONujmb95iOtaZFqizLinbShxgJRqatZgOZgSlWvqi51GQCgkMh0tQAaPK2aD2alK8BRVqIAJfYmmEXFqizvdY2alK8BlvGZ4g0qDPw8hesw1aA0GSnWFAeNl5Q3MLIHkFznG2gGydY2aD2am1ZqhgjV0cCg3b5mu2PfJXyxmtmt9lMKsvjjSsahERUxaVl(AqfMG(CjOtaZFqizLinbC4T6EbCYDshMNJc7zbmJGgoCH2r9MawxKqadDy3ZiOjOhrHjOxxc6eW8heswjsta7XLX4keW8ZyK5BaTBnqxKObzBa)mgz(LIHkFznG2TgGijAq2gOZgSlWvqi51GQCgkMh0tQAq2g4pnIZLC1BZsXqLVSgqBdqSbzBGIjOGGwq1RCP4iZZZSWSwu)0G0BaIc4WB19c4bnuxknwQeMGE9iOtaZFqizLinb8LiGh2eWH3Q7fW7cCfeswaVlKuSa2FAeNl5Q3MLIHkFznG2TgKtdiRbeuqqRbnuxkhHmu8SOseW7cS7dnwapOkN)0ioxYvVnctqpclOtaZFqizLinb8LiGh2eWH3Q7fW7cCfeswaVlKuSa2FAeNl5Q3MLIHkFznG2TgKlbShxgJRqa7VD8hVTYKhxXlG3fy3hASaEqvo)PrCUKREBeMGEDOGobm)bHKvI0eWxIaEytahERUxaVlWvqizb8UqsXcy)PrCUKREBwkgQ8L1G03AaIcypUmgxHaExGRGqYlQHDj46WLL3HplS6(gKTbtclLolWizBwdkfUYWVBSdR1aA3AGUeW7cS7dnwapOkN)0ioxYvVnctqVElOtaZFqizLinbShxgJRqaVlWvqi51GQC(tJ4Cjx920GSnGMnyxGRGqYRbv5mumpONu1asjTbeuqqRjVgXjh3b5uCyOlmRf1pnG2TgG4kNgqkPnysyP0zbgjBZAqPWvg(DJDyTgq7wd0vdY2a)Ds1L6xtEnItoUdYP4WqxywlQFAaTnars0aAiGdVv3lGh0qDPCQ49SWe0tYjOtaZFqizLinbShxgJRqaVlWvqi51GQC(tJ4Cjx920GSnaQqIAomRf1pni9g4VtQUu)AYRrCYXDqofhg6cZAr9Jao8wDVaEqd1LYPI3ZctycyO6RbvqNGEef0jG5piKSsKMa2JlJXviGNewkDwGrY2SgukCLHF3yhwRbP3aeUbzBGoBabfe0Aqd1LYPI3ZlQKgKTbeuqqRrwE2fVYPkpVWSwu)0G0BauHe1CywlQFAq2gqqbbTgz5zx8kNQ88cZAr9tdsVb0Sbi2aYAG)0ioxYvVnnGgnGK0aex6Tao8wDVaEKLNDXRCQYZctqFoc6eW8heswjstaFjc4HnbC4T6Eb8UaxbHKfW7cjflG1IXySlMjMPEhM1I6NgqBdirdiL0gOZgyHKFB9fsuBSqMHXl(dcjRAq2gyHKFBPcCg3GgQl1I)GqYQgKTbeuqqRbnuxkNkEpVOsAaPK2GjHLsNfyKSnRbLcxz43n2H1AaTBnaHfW7cS7dnwapzQehMkXOWSWe0NlbDcy(dcjRePjG94YyCfcyD2GDbUccjVMmvIdtLyuyUbzBGfyKSTSsJD25uf3aeAdWSwu)0aABac3GSnaZqyEqdcjlGdVv3lGXujgfMfMGEDjOtahERUxapShZMZyp6xKukwaZFqizLinHjOxpc6eW8heswjstahERUxaJPsmkmlG94YyCfcyD2GDbUccjVMmvIdtLyuyUbzBGoBWUaxbHKxud7sW1HllVdFwy19niBdMewkDwGrY2SgukCLHF3yhwRb0U1GCAq2gybgjBlR0yNDovXnG2TgqZgONgqwdOzdYPbKKg4pnIZLC1BtdOrdOrdY2amdH5bniKSa2N3lzNfyKSnc6ruyc6rybDcy(dcjRePjG94YyCfcyD2GDbUccjVMmvIdtLyuyUbzBaM1I6NgKEd83jvxQFn51io54oiNIddDHzTO(PbK1aejrdY2a)Ds1L6xtEnItoUdYP4WqxywlQFAq6BnqpniBdSaJKTLvASZoNQ4gGqBaM1I6NgqBd83jvxQFn51io54oiNIddDHzTO(PbK1a9iGdVv3lGXujgfMfMGEDOGobm)bHKvI0eWECzmUcbSoBWUaxbHKxud7sW1HllVdFwy19niBdMewkDwGrY20aA3AqUeWH3Q7fWeYWNXLCPumwyc61BbDc4WB19cyExnEghglG5piKSsKMWeMWeW7y8u3lOphsKdjqeXCqybCQa)1JCeWia0soSXQgO3ni8wDFdK1yZQ3lGNe2lOphegrbCc(GkjlG1DdGPimjB5BGo6qsX9ED3a6VDSgbJBqo6n5nihsKdj699ED3asgMrO61PrewVp8wD)SsWS)0icJSn9JKezExYvZ99(WB19ZkbZ(tJimY20FmoKgAVp8wD)SsWS)0icJSn91cCgw5GoStXHHsEcM9NgryUH93RMne1tVp8wD)SsWS)0icJSn9hz5zx8kNQ8m5jy2FAeH5g2FVA2qK8cAdZqyEqdcj37dVv3pRem7pnIWiBt)bnuxkhHmu8qEbTHPEg6Wi5LwGZ4oiNHYoTymg7IzIzQFXKuQkjHv9(EVUBGoquFd0rNfwDFVp8wD)SLP8z696UbiGdRAGDnqXgJ1QNBqku2qzCd83jvxQFAqQOSgaD4ga)5UbeXWQgCFdSaJKTz17dVv3pKTP)UaxbHKj)dnEBELZFVQS6EY3fskEJGccAnYYZU4vov55fvcPKojSu6SaJKTznOu4kd)UXoSgTBiCVx3nqVqzFMgOx5EAqynaQWJ17dVv3pKTPVpKsx4T6ENSgJ8p04nVA696Ub6iQVbqusz(gmPkZJYtdSRbgk3ayJdPHYQgOJolS6(gqtI8nqD1JSbZrEzna6WEEAqYDY6r2GcQb)zO1JSb10GyxuYGqY0y17dVv3pKTPpM6DH3Q7DYAmY)qJ3gJdPHYkYlOTX4qAOSAfszVx3nqhmjrMVbJS8SlELtvEUbH1GCiRb6fjRbkkC9iBGHYnaQWJ1aejrdg2FVAipGmg3adnSgOlYAGErYAqb1GYAaJGjfMNgKQm06BGHYn4ze0Aac86vUBWHBqnn4pRbuj9(WB19dzB6pYYZU4vov5zYlOTjHLsNfyKSnRbLcxz43n2H1shHZcvirnhM1I6hAr4SeuqqRrwE2fVYPkpVWSwu)KosVAPfiyw)PrCUKREBODtxiuAALgNoIKGgKKC696UbiW9Y8nWJgpsUb4ZcRUVbfudsXnan2XnibxhUS8o8zHv33GHTgeVQbAusRsKCdSaJKTPbujREF4T6(HSn93f4kiKm5FOXBud7sW1HllVdFwy19KVlKu8wcUoCz5D4ZcRUp7KWsPZcms2M1GsHRm87g7WA0ULtVx3nGKHRdxw(gOJolS6Es(BGog2qGzAaYAh3GObECK0GG4OSgWpJrMVbqhUbgk3GX4qAOnqVY90aAsqvsfJBWyLu2ampjS3Aqz0y1aD8PsiVSg4JVbeCdm0WAWuAjsE17dVv3pKTPVpKsx4T6ENSgJ8p04TX4qAOoVAiVG22f4kiK8IAyxcUoCz5D4ZcRUV3R7gGaoSQb21afdvp3GuO83a7Aa1WnymoKgAd0RCpn4WnGGQKkgp9(WB19dzB6VlWvqizY)qJ3gJdPH6mumpONur(UqsXB5OhYSqYVT2vip8I)GqYkssoKGmlK8BlTymg7oi3GgQl1S4piKSIKKdjiZcj)2Aqd1LYbDEQzXFqizfjjh9qMfs(TvidpUS8l(dcjRij5qcYYrpKeAojSu6SaJKTznOu4kd)UXoSgTB6Ig9ED3a96(PumUbut9iBq0ayJdPH2a9k3nifk)naZHhTEKnWq5gWpJrMVbgkMh0tQ69H3Q7hY203hsPl8wDVtwJr(hA82yCinuNxnKxqB8ZyK5xkgQ8LL(2UaxbHKxJXH0qDgkMh0tQ69H3Q7hY203hsPl8wDVtwJr(hA8gu91GsEbT5pnIZLC1BZw8Lw4rdmsw58j9ED3aes91G2GWAGUiRbPkd9OSgKByYBGEiRbPkdTb5gUb08OSPuCdgJdPHsJEF4T6(HSn99Hu6cVv37K1yK)HgVbvFnOKxqB(tJ4Cjx92Sumu5ll9nejLuOcjQ5WSwu)K(gIz9NgX5sU6TH2TC171DdqGkdTb5gUbHCUgavFnOniSgOlYAqGmQFSgORgybgjBtdO5rztP4gmghsdLg9(WB19dzB67dP0fERU3jRXi)dnEdQ(AqjVG2MewkDwGrY2SgukCLHF3yhwJ2nDL1FAeNl5Q3gA30vVx3nabC4genGGQKkg3GuO83amhE06r2adLBa)mgz(gyOyEqpPQ3hERUFiBtFFiLUWB19ozng5FOXBeuLurEbTXpJrMFPyOYxw6B7cCfesEnghsd1zOyEqpPQ3R7gOJ5sXJ1GeCD4YY3G6BqiLn4GAGHYnqhKKPJPbeSpOgUbL1aFqn80GObiWRx5U3hERUFiBt)a7JND2HX8BKxqB8ZyK5xkgQ8Lr7gI6Hm(zmY8lmJK)EF4T6(HSn9dSpE2LqjhU3hERUFiBtFzHe1gNowkfsn(TEF4T6(HSn9jcKUdYz4YNz699ED3a96oP6s9tVx3nabC4gK749CdoiieksVQbem0H5gyOCdGk8ynyqPWvg(DJDyTgaHpTgq3H)qDnWFA80G6x9(WB19ZYRgY20Fqd1LYPI3ZKtnS7GGCi9QnejVG20jbfe0Aqd1LYPI3ZlQKSeuqqRbLcxz43zh(d1TOsYsqbbTgukCLHFND4pu3cZAr9t6B5APNEVUBanraFjptdcjMdv(gqL0ac2hud3GuCdS7Y0ay0qDPAac58udnAa1WnaoVgXjNgCqqiuKEvdiyOdZnWq5gav4XAWGsHRm87g7WAnacFAnGUd)H6AG)04Pb1V69H3Q7NLxnKTP)KxJ4KJ7GCkomuYPg2DqqoKE1gIKxqBeuqqRbLcxz43zh(d1TOsYsqbbTgukCLHFND4pu3cZAr9t6B5APNEF4T6(z5vdzB6djdKSugwDp5f02UaxbHKxZRC(7vLv3NvNJXH0qz1slEtY9(WB19ZYRgY20hsgizPmS6ENxYXpm5f0MIjOGGwqYajlLHv3VWSwu)KEo9(WB19ZYRgY20Fx81GsEbTrtm1ZqhgjV0cCg3b5mu2PfJXyxmtmt9lMKsvjjSkR)0ioxYvVnlfdv(YsFlxKskM6zOdJKxkomuzE3GgQl1SyskvLKWQS(tJ4Cjx92KoI0ilbfe0AYRrCYXDqofhg6Ikjlbfe0Aqd1LYPI3ZlQKSAXym2fZeZuVdZAr9ZgjYsqbbTuCyOY8UbnuxQzPUuFVx3nGKDNSbqhUb0D4puxdsWmcf(YDdsvgAdGrZDdWCOY3GuO83G)SgGP(VEKnagHS69H3Q7NLxnKTPFYDshMNJc7zYHoS7ze02qK8cAZcj)2AqPWvg(D2H)qDl(dcjRYQtlK8BRbnuxkh05PMf)bHKv9ED3aeWHBaDh(d11Gem3a4l3nifk)nif3a0yh3adLBa)mgz(gKcLnug3ai8P1GK7K1JSbPkd9OSgaJqAWHBGowQXAas(zCiL5x9(WB19ZYRgY20FqPWvg(D2H)qDKxqB8ZyK5PDdHjr2DbUccjVMx583RkRUpR)oP6s9RjVgXjh3b5uCyOlQKS(7KQl1Vg0qDPCQ498YJgyK8q7gI9(WB19ZYRgY20Fymomw5iUNDtsLHj3N3lzNfyKSnBisEbTTlWvqi518kN)Evz19z1P6S1WyCySYrCp7MKkd7uNTSYNPEKzTaJKTLvASZoNQyA3YbrsjfQqIAomRf1pPVPNStclLolWizBwdkfUYWVBSdRLEU69H3Q7NLxnKTP)WjtnKxqB7cCfesEnVY5VxvwDFw)PrCUKREBwkgQ8Lr7gI9ED3aeWHBaCEnIton4(g4VtQUuFdOzazmUbqfESga)5MgnG6L8mnif3GaZna5vpYgyxdsUKgq3H)qDniEvduxd(ZAaASJBamAOUunaHCEQz17dVv3plVAiBt)jVgXjh3b5uCyOKxqB7cCfesEnVY5VxvwDFwAAHKFBX)owEj1J0nOH6snl(dcjRiLu)Ds1L6xdAOUuov8EE5rdmsEODdrAKLM60cj)2AqPWvg(D2H)qDl(dcjRiLulK8BRbnuxkh05PMf)bHKvKsQ)oP6s9RbLcxz43zh(d1TWSwu)qBo0O3R7gGaaQbHsnniWCdOsiVbZxjCdmuUb3ZnivzOnqEP4XAaD0L7vdqahUbPq5VbQ81JSbqXymUbgA8nqViznqXqLVSgC4g8N1GX4qAOSQbPkd9OSgeF(gOxKSvVp8wD)S8QHSn91cCgw5GoStXHHsUpVxYolWizB2qK8cAdhLYX743wHsnlQKS00cms2wwPXo7CQIt3FAeNl5Q3MLIHkFzKsQohJdPHYQviLz9NgX5sU6TzPyOYxgTB(eNwGGUjHFfn696UbiaGAWFniuQPbPkPSbQIBqQYqRVbgk3GNrqRb5Ied5nGA4gOdaL7gCFdiUzAqQYqpkRbXNVb6fjB17dVv3plVAiBtFTaNHvoOd7uCyOKxqB4OuoEh)2kuQzvpT5IeiuCukhVJFBfk1Suu4WQ7Z6pnIZLC1BZsXqLVmA38joTabDtc)QEF4T6(z5vdzB6pOH6s5iKHIhYlOTDbUccjVMx583RkRUpR)0ioxYvVnlfdv(YODlNEF4T6(z5vdzB6ZE0REKomNGlT4vKxqB7cCfesEnVY5VxvwDFw)PrCUKREBwkgQ8Lr7wozP5UaxbHKxud7sW1HllVdFwy19Ks6KWsPZcms2M1GsHRm87g7WAPVPlA071DdqGkdTbWieYBqb1G)SgesmhQ8nqDptEdOgUb0D4puxdsvgAdGVC3aQKvVp8wD)S8QHSn9hukCLHFND4puh5f0Mfs(T1GgQlLd68uZI)GqYQS7cCfesEnVY5VxvwDFwckiO1KxJ4KJ7GCkom0fvsVp8wD)S8QHSn9h0qDPCQ49m5f0MojOGGwdAOUuov8EErLKfQqIAomRf1pPVP3KzHKFBnuegJHOqYl(dcjR696Ub0FpcDsyFdgJccQbPkdTbYlfJBqcUUEF4T6(z5vdzB6NCwDFVp8wD)S8QHSn9jK3PCqu48KxqBeuqqRjVgXjh3b5uCyOlQKEF4T6(z5vdzB6tW4HXzQhj5f0gbfe0AYRrCYXDqofhg6IkP3hERUFwE1q2M(qfMjK3PiVG2iOGGwtEnItoUdYP4Wqxuj9(WB19ZYRgY20pEppgoKoFiLKxqBeuqqRjVgXjh3b5uCyOlQKEVUBqUzOGsAnakKsIWNPbqhUbutqi5gugRniW2aeWHBqQYqBaCEnIton4GAqU5Wqx9(WB19ZYRgY20NAyxzS2qEbTrqbbTM8AeNCChKtXHHUOsiLuOcjQ5WSwu)KEoKO3371Dd0braY4Y4gqY3m875P3hERUFw8m875HSn993753WHXkhKm0yYlOn(zmY8lR0yNDoTabPfXS6KGccAn51io54oiNIddDrLKLM6uD2YFVNFdhgRCqYqJDeu4FzLpt9iZQZWB19l)9E(nCySYbjdnEvVdswirnsjfIskDy2JgyKSZknoDKE1slqqA07dVv3plEg(98q2M(eY7uUdYzOSJFwlp5f0Mo93jvxQFnOH6s5iKHINfvsw)Ds1L6xtEnItoUdYP4WqxujKskuHe1CywlQFsFdrs07dVv3plEg(98q2M(iPcSQI3DqUabiJpdT3hERUFw8m875HSn9Hop1WkxGaKXLXoco0iVG2O5KWsPZcms2M1GsHRm87g7WA0ULdPKIJs54D8BRqPMv90IWKGgz1P)oP6s9RjVgXjh3b5uCyOlQKS6KGccAn51io54oiNIddDrLKLFgJm)sXqLVmA3Yfj69H3Q7Nfpd)EEiBt)ekCbLVEKoczmg5f02KWsPZcms2M1GsHRm87g7WA0ULdPKIJs54D8BRqPMv90IWKO3hERUFw8m875HSn9nu2r9eh1RCqh2ZKxqBeuqqlm7Zi5zCqh2ZlQesjLGccAHzFgjpJd6WE25pQ3y8ASWNjDejrVp8wD)S4z43ZdzB6JRKej7Q3njHN79H3Q7Nfpd)EEiBt)uhwQ2X17W8CF8EM8cAZFNuDP(1KxJ4KJ7GCkom0fM1I6N01dPKcvirnhM1I6N0ruV79H3Q7Nfpd)EEiBtFnw7W5DhKts5lLtH5qBiVG24NXiZNUUirwckiO1KxJ4KJ7GCkom0fvsVx3nqh3jvnqhXrs9iBacrgA80aOd3agbzpLXnahpsUbhUbzkPSbeuqqd5nOGAqYntri5vd0bLPI8tdmC(gyxdqYwdmuUbYlfpwd83jvxQVbeXWQgCFdIDrjdcj3a(zTINvVp8wD)S4z43ZdzB6J5iPEKoizOXd5f0guHe1CywlQFshXLEiLuAstlWizBHYH0qxjEJw9MeKsQfyKSTq5qAOReVL(woKGgzPz4TAh74N1kE2qKusHkKOMdZAr9dT5qYrdAqkP00cms2wwPXo7CjEZLdjOnxKilndVv7yh)SwXZgIKskuHe1CywlQFOvx6Ig0O3371DdGnoKgAd0R7KQl1p9(WB19ZAmoKgQZRgY20FxGRGqYK)HgVnOkNHI5b9KkY3fskEZFNuDP(1GgQlLtfVNxE0aJKhheo8wDFiPDdXLoupKRJJLjmUbK8cCfesU3R7gqYl(AqBqb1GuCdcm3aFKKupYgCFdYD8EUbE0aJKNvdi5lWY8nGGHom3aOcpwduX75guqnif3a0yh3G)Aa9fsuBSqMHXnGGYAqUdCMgaJgQlvdQVbhwX4gyxdqYwd0rujgfMBavsdO5FnqhigJXnqhCMyM6PXQ3hERUFwJXH0qDE1q2M(7IVguYlOnAQZDbUccjVguLZqX8GEsfPKQtlK8BRVqIAJfYmmEXFqizvwlK8BlvGZ4g0qDPw8heswrJS(tJ4Cjx92Sumu5lJweZQtm1ZqhgjV0cCg3b5mu2PfJXyxmtmt9lMKsvjjSQ3hERUFwJXH0qDE1q2M(j3jDyEokSNjh6WUNrqBdrYze0WHl0oQ320fjiNKDNSbqhUbWOH6sPXsvdiRbWOH6sngUYWnG6L8mnif3GaZniiokRb21aFK0G7BqUJ3ZnWJgyK8SAacCVmFdsHYFdqi1RAacehzEEMgutdcIJYAGDnat9n4OSvVp8wD)SgJdPH68QHSn9h0qDP0yPI8cAJFgJmpTB6Iez5NXiZVumu5lJ2nejrwDUlWvqi51GQCgkMh0tQY6pnIZLC1BZsXqLVmArmRIjOGGwq1RCP4iZZZSWSwu)KoI9ED3a9IK1adfZd6jvtdGoCd43yC9iBamAOUuni3X75EF4T6(znghsd15vdzB6VlWvqizY)qJ3guLZFAeNl5Q3gY3fskEZFAeNl5Q3MLIHkFz0ULdzeuqqRbnuxkhHmu8SOs69H3Q7N1yCinuNxnKTP)UaxbHKj)dnEBqvo)PrCUKREBiFxiP4n)PrCUKREBwkgQ8Lr7wUiVG283o(J3wzYJR479H3Q7N1yCinuNxnKTP)UaxbHKj)dnEBqvo)PrCUKREBiFxiP4n)PrCUKREBwkgQ8LL(gIKxqB7cCfesErnSlbxhUS8o8zHv3NDsyP0zbgjBZAqPWvg(DJDynA30vVx3ni3X75gOOW1JSbW51io50Gd3GG42XnWqX8GEs1Q3hERUFwJXH0qDE1q2M(dAOUuov8EM8cABxGRGqYRbv58NgX5sU6Tjln3f4kiK8AqvodfZd6jvKskbfe0AYRrCYXDqofhg6cZAr9dTBiUYHusNewkDwGrY2SgukCLHF3yhwJ2nDL1FNuDP(1KxJ4KJ7GCkom0fM1I6hArKe0O3R7gKgf(BaM1I6RhzdYD8EEAabdDyUbgk3aOcjQ1a(vtdkOgaF5UbPUhbgRbeCdWCOY3G6BGvA8Q3hERUFwJXH0qDE1q2M(dAOUuov8EM8cABxGRGqYRbv58NgX5sU6TjluHe1CywlQFs3FNuDP(1KxJ4KJ7GCkom0fM1I6NEFVx3na24qAOSQb6OZcRUV3R7gGaaQbWghsdv)DXxdAdcm3aQeYBa1WnagnuxQXWvgUb21ac(zOYAae(0AGHYnijMP2XnG4EQPbXRAacPEvdqG4iZZZ0aEh)nOGAqkUbbMBqynqlqWgOxKSgqti8P1adLBqcM9Ngrynqhak30y17dVv3pRX4qAOSISn9h0qDPgdxzyYlOnAsqbbTgJdPHUOsiLuckiO1U4RbDrLqJEVUBacP(AqBqynixK1a9IK1GuLHEuwdYnCd0Vb6ISgKQm0gKB4gKQm0gaJsHRm83a6o8hQRbeuqqnGkPb21Gy3vQgmNg3a9IK1GuXyCdMYOcRUFw9(WB19ZAmoKgkRiBtFFiLUWB19ozng5FOXBq1xdk5f0gbfe0AqPWvg(D2H)qDlQKS(tJ4Cjx92Sumu5ll9TC696Ub6GY5AWeqCdSRbq1xdAdcRb6ISgOxKSgKQm0gWiy4nz(gORgybgjBZQb0eo04getdokBkf3GX4qAOlA07dVv3pRX4qAOSISn99Hu6cVv37K1yK)HgVbvFnOKxqBtclLolWizBwdkfUYWVBSdRTPRS(tJ4Cjx92q7MU696UbiK6RbTbH1aDrwd0lswdsvg6rzni3WK3a9qwdsvgAdYnm5niEvdq4gKQm0gKB4geqgJBajV4RbT3hERUFwJXH0qzfzB67dP0fERU3jRXi)dnEdQ(AqjVG28NgX5sU6TzPyOYxw6BiIqPPfs(TLI5eg7gdhwGK1w8heswLLGccATl(Aqxuj0O3hERUFwJXH0qzfzB6pO1oYlOnlK8BRVqIAJfYmmEXFqizvwm1ZqhgjVS6Z7SdblVJqgkEXKuQkjHvzNewkDwGrY2SgukCLHF3yhwlD9071DdqatAGDnixnWcms2MgKH5KgqL0aes9QgGaXrMNNPbe5BGpVxwpYgaJgQl1y4kdV69H3Q7N1yCinuwr2M(dAOUuJHRmm5(8Ej7SaJKTzdrYlOnftqbbTGQx5sXrMNNzHzTO(jDeZojSu6SaJKTznOu4kd)UXoSw6B5kRfyKSTSsJD25ufJqXSwu)qlc371DdqihUbj46WLLVb4ZcRUN8gqnCdGrd1LAmCLHBWTJXna2oSwdsvgAdqG0bAqGmQFSgqL0a7AGUAGfyKSnn4WnOGAacbbQb10am1)1JSbheudO59ni(8ni0oQ3AWb1alWizBOrVp8wD)SgJdPHYkY20Fqd1LAmCLHjVG22f4kiK8IAyxcUoCz5D4ZcRUplnvmbfe0cQELlfhzEEMfM1I6N0rKusTqYVTsXrY9AXymEXFqizv2jHLsNfyKSnRbLcxz43n2H1sFtx0O3hERUFwJXH0qzfzB6pOu4kd)UXoSg5f02KWsPZcms2gA3Yfz0KGccALGznwvwy19lQesjLGccAzOSdFMX)IkHusXupdDyK8kYebUg3CusheoqQXVTyskvLKWQS(7vuLTumNWyNkqIKXZchFgA30H0O3hERUFwJXH0qzfzB6pOH6sngUYWKxqBkMGccAbvVYLIJmppZcZAr9t6BiskP(7KQl1VM8AeNCChKtXHHUWSwu)KoI6DwftqbbTGQx5sXrMNNzHzTO(jD)Ds1L6xtEnItoUdYP4WqxywlQF696UbWOH6sngUYWnWUgGzimpOnaHuVQbiqCK55zAq8Qgyxd4FOWCdsXnWhFd8bgNVb3og3GObquszdqiiqnOE7AGHYn4ze0Aa8L7guqni5MPiK8Q3hERUFwJXH0qzfzB6NCN0H55OWEMCOd7EgbTne79H3Q7N1yCinuwr2M(iL3PridftEbTrqbbTsym0HdJvUDC9ZASWNH2n9K1FVIQSvcJHoCySYTJRFw44Zq7gI5Q3hERUFwJXH0qzfzB6pOH6sngUYW9(EVUBacP(Aqz807dVv3plO6RbLSn9hz5zx8kNQ8m5f02KWsPZcms2M1GsHRm87g7WAPJWz1jbfe0Aqd1LYPI3ZlQKSeuqqRrwE2fVYPkpVWSwu)KouHe1CywlQFYsqbbTgz5zx8kNQ88cZAr9t60erY8NgX5sU6THgKeex6DVp8wD)SGQVguY20FxGRGqYK)HgVnzQehMkXOWm57cjfVPfJXyxmtmt9omRf1p0scsjvNwi53wFHe1glKzy8I)GqYQSwi53wQaNXnOH6sT4piKSklbfe0Aqd1LYPI3ZlQesjDsyP0zbgjBZAqPWvg(DJDynA3qyY1XXYeg3asEbUccj3aOd3aDevIrH5vdGZujnqrHRhzd0bIXyCd0bNjMP(gC4gOOW1JSb5oEp3GuLH2GCh4mniEvd(Rb0xirTXczggV696Ub64XCsdOsAGoIkXOWCdkOguwdQPbbXrznWUgGP(gCu2Q3hERUFwq1xdkzB6JPsmkmtEbTPZDbUccjVMmvIdtLyuyoRfyKSTSsJD25ufJqXSwu)qlcNfZqyEqdcj37dVv3plO6RbLSn9h2JzZzSh9lskf371Dd0bOKwPoZQhzdSaJKTPbgAynivjLnqw74gaD4gyOCduu4WQ7BWb1aDevIrH5gGzimpOnqrHRhzdsIxXALF17dVv3plO6RbLSn9XujgfMj3N3lzNfyKSnBisEbTPZDbUccjVMmvIdtLyuyoRo3f4kiK8IAyxcUoCz5D4ZcRUp7KWsPZcms2M1GsHRm87g7WA0ULtwlWizBzLg7SZPkM2nAQhYOzoKe)PrCUKREBObnYIzimpObHK796Ub6igcZdAd0rujgfMBahyz(guqnOSgKQKYgWiysH5gOOW1JSbW51io5SAqUVgyOH1amdH5bTbfudGVC3aKSnnaZHkFdQVbgk3GNrqRb6zw9(WB19ZcQ(AqjBtFmvIrHzYlOnDUlWvqi51KPsCyQeJcZzXSwu)KU)oP6s9RjVgXjh3b5uCyOlmRf1pKHijY6VtQUu)AYRrCYXDqofhg6cZAr9t6B6jRfyKSTSsJD25ufJqXSwu)qR)oP6s9RjVgXjh3b5uCyOlmRf1pKPNEF4T6(zbvFnOKTPpHm8zCjxkfJjVG205UaxbHKxud7sW1HllVdFwy19zNewkDwGrY2q7wU69H3Q7Nfu91Gs2M(8UA8momU3371DdsJQKkgp9(WB19ZIGQKQTbT2rEbTPtlK8BRVqIAJfYmmEXFqizvwm1ZqhgjVS6Z7SdblVJqgkEXKuQkjHvzNewkDwGrY2SgukCLHF3yhwlD907dVv3plcQsQiBt)bLcxz43n2H1iVG2MewkDwGrY2q7wo9(WB19ZIGQKkY20Fymomw5iUNDtsLHjVG283jvxQFnmghgRCe3ZUjPYWlpAGrYJdchERUpK0ULZshQhsjDokjr9QLKdLJiVJrWqlrYl(dcjRYQtckiOLKdLJiVJrWqlrYlQKEF4T6(zrqvsfzB6JuENgHmuCVp8wD)SiOkPISn9jcFMXccHjmHaa]] )


end
