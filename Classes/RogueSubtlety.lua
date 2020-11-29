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


    spec:RegisterPack( "Subtlety", 20201129, [[deLeQbqiskEejv2Kc8jqPmkusDkukwfjL0RqfnluHBPiKDjQFjIAyOKCmuILPq6zkImnsQ6AOsSnuk13qPeJtrOohQK06iPuMNiY9uu7JK0)aLuHdssPAHkepevsnrfrDrukjTrqPQpIsj1iveiojOKYkbfVeusLMPIGCtskr7evQFIsjXqbLklfusEkuMkjXvveuBfusvFfvsmwfbCwqjv0Ej8xQmyGdtzXq1JPQjt0Lr2miFgunAuCAPwTIaPxRGMnPUnj2TQ(TkdxKoojLWYH8CLMUW1rvBxr67IW4bL48kuRxrGA(OuTFjlyrOIatAbj4EuwnkRyHLr5QzwnXtIRYf2wGfJtjbwQ5hAWjb2BkKadJhp0umwGLAJ1NjfQiW2Jh5jbgtePRAl5KH3bdpE2FkjVTcV2I(EpYGIK3wXNSadNV1bS2lWfyslib3JYQrzflSmkxnZQjEsCvUiWm(G5qcmSwHRfymTusVaxGjP1lWuxbW4XdnfJlaS6GZtfmQRaCFtjfCcvGr5QCuGrz1OSsGP7nwHkcSnithmKuOIGBweQiWO3W1KumIaZJ6GqTjWyDbW5HGYBqMoyY8PfGD2laopeuEQ99YK5tlaBeyMp67fylJjVeBG6HKieCpQqfbg9gUMKIreyEuheQnbgopeuEz4r9q6DXHEtEz(0cmOa(tb)CPx)XMLeu77OajnxGrfyMp67fyEtRDMp67D6EdbMU3W9McjWG6Vxgri4Escvey0B4AskgrG5rDqO2eyBkP1UWqWPyZldpQhsVBJdPuG5cO(cmOa(tb)CPx)XwavNlG6fyMp67fyEtRDMp67D6EdbMU3W9McjWG6Vxgri4w9cvey0B4AskgrG5rDqO2ey(tb)CPx)XMLeu77OajnxawkWevawxGW00hzjrPeYTbYcdoPKP3W1KSadkaopeuEQ99YK5tlaBeyMp67fyEtRDMp67D6EdbMU3W9McjWG6Vxgri4Mlcvey0B4AskgrG5rDqO2eyHPPpYFdNj2W0djuMEdxtYcmOai(NGoeCkh9p2fhS0EhU2KuMEdxtYcmOaBkP1UWqWPyZldpQhsVBJdPuGKkaxeyMp67fyltpvecUzBHkcm6nCnjfJiWmF03lWwgtEj2a1djbMh1bHAtGjjCEiOmu)sxcYg(0UzePy9VfiPcWsbguGnL0Axyi4uS5LHh1dP3TXHukqsZfysfyqbcdbNIC0kKloNSPcmrfarkw)BbuTaSTaZp2Rjxyi4uScUzrecUzlcvey0B4AskgrG5rDqO2eytnuB4AkZVKlf1hQJXo0fw03xGbfG1fqs48qqzO(LUeKn8PDZisX6FlqsfGLcWo7fimn9robzP3RyBqOm9gUMKfyqb2usRDHHGtXMxgEupKE3ghsPajnxa1xa2iWmF03lWwgtEj2a1djri4EIfQiWO3W1KumIaZJ6GqTjW2usRDHHGtXwavNlWKkaNfG1faNhckhmKdDrqFMpTaSZEbq8pbDi4u2gAgQx3E8AheYGRqFKP3W1KSadkG)EjFhzjrPeYjn4Wj0Mr2pSaQoxa2sbytbguawxa1uaCEiOCkIuizhw03N5tla7SxGnL0Axyi4uSfq15cWLcWgbM5J(Eb2YWJ6H0724qkIqWnxvOIaJEdxtsXicmpQdc1Mats48qqzO(LUeKn8PDZisX6FlqsZfGLcWo7fWFNwEj(8owb)0R7GCsYcMmIuS(3cKubyzIlWGcijCEiOmu)sxcYg(0UzePy9VfiPc4VtlVeFEhRGF61Dqojzbtgrkw)RaZ8rFVaBzm5LydupKeHGBwyLqfbg9gUMKIreyEuheQnbgopeuoLqqhYcs6Ms9V5nm)WcO6Cb4sbgua)9s(oYPec6qwqs3uQ)nJSFybuDUaSmjbM5J(EbgC9Dk4AtsIqWnlSiurGz(OVxGTmM8sSbQhscm6nCnjfJicriWODP3tRqfb3SiurGrVHRjPyebMh1bHAtGrpHGpohTc5IZPyWsbuTaSuGbfqnfaNhckVJvWp96oiNKSGjZNwGbfG1fqnfqEr2FVN(azbjDqAtHC48OphTFy)WlWGcOMcy(OVp7V3tFGSGKoiTPq5(Dq6gotua2zVaq8ATdrEgdbNCrRqfiPca3lZkgSua2iWmF03lW837PpqwqshK2uiri4EuHkcm6nCnjfJiW8OoiuBcm1ua)DA5L4ZlJjVeoCTjPnZNwGbfWFNwEj(8owb)0R7GCsYcMmFAbyN9ca1WzchIuS(3cK0CbyHvcmZh99cmC9Ds3b5cgYrpPmwecUNKqfbM5J(EbgCEdjB7DhKZMGj0fmcm6nCnjfJicb3QxOIaJEdxtsXicmpQdc1MaJ1fytjT2fgcofBEz4r9q6DBCiLcO6CbgTaSZEbqwlD0u6JSjLBU)cOAbyBwva2uGbfqnfWFNwEj(8owb)0R7GCsYcMmFAbgua1uaCEiO8owb)0R7GCsYcMmFAbgua6je8Xzjb1(okGQZfysSsGz(OVxGbDE(LKoBcMqDqoCYueHGBUiurGrVHRjPyebMh1bHAtGTPKw7cdbNInVm8OEi9UnoKsbuDUaJwa2zVaiRLoAk9r2KYn3FbuTaSnReyMp67fyP8OgAC)WD4ABdri4MTfQiWO3W1KumIaZJ6GqTjWW5HGYiYput76GoKNY8PfGD2laopeugr(HAAxh0H8KZF8FqO8gMFybsQaSWkbM5J(EbwWqo(h)4FPd6qEsecUzlcveyMp67fyOonvtU(DBQ5jbg9gUMKIreHG7jwOIaJEdxtsXicmpQdc1MaZFNwEj(8owb)0R7GCsYcMmIuS(3cKub4sbyN9ca1WzchIuS(3cKubyzIfyMp67fyjoKwoL63HO9E79KieCZvfQiWO3W1KumIaZJ6GqTjWONqWhxGKkG6zvbguaCEiO8owb)0R7GCsYcMmFQaZ8rFVatHuo0y3b508(w6KiYuwri4MfwjurGrVHRjPyebMh1bHAtGb1WzchIuS(3cKubyjZLcWo7fG1fG1fimeCkYmKPdMCQpkGQfyIzvbyN9cegcofzgY0bto1hfiP5cmkRkaBkWGcW6cy(ONso6jLM2cmxawka7SxaOgot4qKI1)wavlWOC1cWMcWMcWo7fG1fimeCkYrRqU4CP(WnkRkGQfysSQadkaRlG5JEk5ONuAAlWCbyPaSZEbGA4mHdrkw)BbuTaQx9fGnfGncmZh99cmezP9d3bPnfAfHieyscY41Hqfb3SiurGz(OVxGnS9dfy0B4AskgrecUhvOIaJEdxtsXicSlvGTuiWmF03lWMAO2W1KaBQP5jbgopeuE1TNC2lDY2tz(0cWo7fytjT2fgcofBEz4r9q6DBCiLcO6CbyBb2ud5EtHey7lD(7LD03lcb3tsOIaJEdxtsXicmZh99cmVP1oZh99oDVHat3B4EtHeyE5kcb3QxOIaJEdxtsXicmpQdc1MaBdY0bdjZMwlWmF03lWq8VZ8rFVt3BiW09gU3uib2gKPdgskcb3CrOIaJEdxtsXicmpQdc1MaBtjT2fgcofBEz4r9q6DBCiLcKuby7cmOaqnCMWHifR)TaQwa2UadkaopeuE1TNC2lDY2tzePy9VfiPca3lZkgSuGbfWFk4Nl96p2cO6CbuFbMOcW6ceTcvGKkalSQaSPaQ1cmQaZ8rFVaB1TNC2lDY2tIqWnBlurGrVHRjPyeb2LkWwkeyMp67fytnuB4AsGn108Kalf1hQJXo0fw03xGbfytjT2fgcofBEz4r9q6DBCiLcO6CbgvGn1qU3uibg)sUuuFOog7qxyrFVieCZweQiWO3W1KumIaZJ6GqTjWMAO2W1uMFjxkQpuhJDOlSOVxGz(OVxG5nT2z(OV3P7ney6Ed3BkKaBdY0bJZlxri4EIfQiWO3W1KumIa7sfylfcmZh99cSPgQnCnjWMAAEsGnkxkaNfimn9rEAd)qz6nCnjlGATaJYQcWzbcttFKvSniK7GClJjVeBMEdxtYcOwlWOSQaCwGW00h5LXKxch0553m9gUMKfqTwGr5sb4SaHPPpYM28OogNP3W1KSaQ1cmkRkaNfyuUua1AbyDb2usRDHHGtXMxgEupKE3ghsPaQoxa1xa2iWMAi3BkKaBdY0bJlyq0YCAPieCZvfQiWO3W1KumIaZJ6GqTjWONqWhNLeu77OajnxGPgQnCnL3GmDW4cgeTmNwkWmF03lW8Mw7mF03709gcmDVH7nfsGTbz6GX5LRieCZcReQiWO3W1KumIaZJ6GqTjW8Nc(5sV(JTaZfW(wX8mgcojD(ubM5J(EbM30AN5J(ENU3qGP7nCVPqcmO(7LrecUzHfHkcm6nCnjfJiW8OoiuBcm)PGFU0R)yZscQ9DuGKMlalfGD2laudNjCisX6FlqsZfGLcmOa(tb)CPx)XwavNlWKeyMp67fyEtRDMp67D6EdbMU3W9McjWG6Vxgri4MLrfQiWO3W1KumIaZJ6GqTjW2usRDHHGtXMxgEupKE3ghsPaQoxa1xGbfWFk4Nl96p2cO6CbuVaZ8rFVaZBATZ8rFVt3BiW09gU3uibgu)9Yicb3SmjHkcm6nCnjfJiW8OoiuBcm6je8Xzjb1(okqsZfyQHAdxt5nithmUGbrlZPLcmZh99cmVP1oZh99oDVHat3B4EtHey48Twkcb3SOEHkcm6nCnjfJiW8OoiuBcm6je8Xzjb1(okGQZfGfUuaola9ec(4mIGtVaZ8rFVaZqE7jxCie9HieCZcxeQiWmF03lWmK3EYLYRxsGrVHRjPyeri4Mf2wOIaZ8rFVat3WzI1nbLxcxH(qGrVHRjPyeri4Mf2IqfbM5J(EbgUb3DqUa1(HRaJEdxtsXiIqecSue5pfCleQi4MfHkcmZh99cmlnvp2LE9EVaJEdxtsXiIqW9OcveyMp67fyBqMoyey0B4AskgrecUNKqfbg9gUMKIreyMp67fykgAijDqhYjjlyeyPiYFk4w4wYFVCfySWfri4w9cvey0B4AskgrGz(OVxGT62to7Loz7jbMh1bHAtGHiieTmgUMeyPiYFk4w4wYFVCfySicb3CrOIaJEdxtsXicmpQdc1MadX)e0HGtzfdn0DqUGHCk2geYz7A72FMEdxtsbM5J(Eb2YyYlHdxBsAfHiey48TwkurWnlcvey0B4AskgrG5rDqO2eyQPaHPPpYFdNj2W0djuMEdxtYcmOai(NGoeCkh9p2fhS0EhU2KuMEdxtYcmOaBkP1UWqWPyZldpQhsVBJdPuGKkaxeyMp67fyltpvecUhvOIaJEdxtsXicmpQdc1MaBtjT2fgcofBbuDUaJkWmF03lWwgEupKE3ghsrecUNKqfbg9gUMKIreyEuheQnbM)oT8s85LqiliPd)EYTP9qk7zmeCADqiZh99MUaQoxGrZSfUua2zVa7XRX7xM1KjD4JDeSykPAktVHRjzbgua1uaCEiOSMmPdFSJGftjvtz(ubM5J(Eb2siKfK0HFp520Eijcb3QxOIaZ8rFVadU(ofCTjjbg9gUMKIreHGBUiurGz(OVxGHB(HBy4cm6nCnjfJicriW8YvOIGBweQiWO3W1KumIaZJ6GqTjWutbW5HGYlJjVeoP9EkZNwGbfaNhckVm8OEi9U4qVjVmFAbguaCEiO8YWJ6H07Id9M8YisX6FlqsZfyszUiWmF03lWwgtEjCs79KaJFj3bb5G7LcUzrecUhvOIaJEdxtsXicmpQdc1MadNhckVm8OEi9U4qVjVmFAbguaCEiO8YWJ6H07Id9M8YisX6FlqsZfyszUiWmF03lW2Xk4NEDhKtswWiW4xYDqqo4EPGBweHG7jjurGrVHRjPyebMh1bHAtGn1qTHRP8(sN)Ezh99fyqbutb2GmDWqYSI9HMeyMp67fyqAdoP1w03lcb3QxOIaJEdxtsXicmpQdc1Mats48qqziTbN0Al67ZisX6FlqsfyubM5J(EbgK2GtATf99oVMSFjri4Mlcvey0B4AskgrG5rDqO2eySUai(NGoeCkRyOHUdYfmKtX2GqoBxB3(Z0B4AswGbfWFk4Nl96p2SKGAFhfiP5cmPcWo7faX)e0HGtzjzbJESBzm5LyZ0B4AswGbfWFk4Nl96p2cKubyPaSPadkaopeuEhRGF61DqojzbtMpTadkaopeuEzm5LWjT3tz(0cmOak2geYz7A72Vdrkw)BbMlaRkWGcGZdbLLKfm6XULXKxInlVeVaZ8rFVaBQ99Yicb3STqfbg9gUMKIreyMp67fyP3PDiApEKNeyEuheQnbwyA6J8YWJ6H07Id9M8Y0B4AswGbfqnfimn9rEzm5LWbDE(ntVHRjPad6qUNGLqWnlIqWnBrOIaJEdxtsXicmpQdc1MaJEcbFCbuDUaSnRkWGcm1qTHRP8(sN)Ezh99fyqb83PLxIpVJvWp96oiNKSGjZNwGbfWFNwEj(8YyYlHtAVNYEgdbN2cO6CbyrGz(OVxGTm8OEi9U4qVjpri4EIfQiWO3W1KumIaZ8rFVaBjeYcs6WVNCBApKeyEuheQnb2ud1gUMY7lD(7LD03xGbfqnfqErEjeYcs6WVNCBApKCYlYr7h2p8cmOaHHGtroAfYfNt2ubuDUaJYsbyN9ca1WzchIuS(3cK0Cb4sbguGnL0Axyi4uS5LHh1dP3TXHukqsfyscm)yVMCHHGtXk4Mfri4MRkurGrVHRjPyebMh1bHAtGn1qTHRP8(sN)Ezh99fyqb8Nc(5sV(JnljO23rbuDUaSiWmF03lWwkD7vecUzHvcvey0B4AskgrG5rDqO2eytnuB4AkVV05Vx2rFFbguawxGW00hz6Ns6lTF4ULXKxIntVHRjzbyN9c4VtlVeFEzm5LWjT3tzpJHGtBbuDUaSua2uGbfG1fqnfimn9rEz4r9q6DXHEtEz6nCnjla7SxGW00h5LXKxch0553m9gUMKfGD2lG)oT8s85LHh1dP3fh6n5LrKI1)wavlWOfGncmZh99cSDSc(Px3b5KKfmIqWnlSiurGrVHRjPyebM5J(EbMIHgssh0HCsYcgbMh1bHAtGHSw6OP0hztk3mFAbguawxGWqWPihTc5IZjBQajva)PGFU0R)yZscQ9Dua2zVaQPaBqMoyiz206cmOa(tb)CPx)XMLeu77OaQoxaFQtXGf3MsVSaSrG5h71KlmeCkwb3Sicb3SmQqfbg9gUMKIreyEuheQnbgYAPJMsFKnPCZ9xavlWKyvbMOcGSw6OP0hztk3SKhzrFFbgua)PGFU0R)yZscQ9DuavNlGp1PyWIBtPxkWmF03lWum0qs6GoKtswWicb3SmjHkcm6nCnjfJiW8OoiuBcSPgQnCnL3x683l7OVVadkG)uWpx61FSzjb1(okGQZfyubM5J(Eb2YyYlHdxBsAfHGBwuVqfbg9gUMKIreyEuheQnb2ud1gUMY7lD(7LD03xGbfWFk4Nl96p2SKGAFhfq15cmAbguawxGPgQnCnL5xYLI6d1Xyh6cl67la7SxGnL0Axyi4uS5LHh1dP3TXHukqsZfq9fGncmZh99cmYZC9d3HOuuRyVuecUzHlcvey0B4AskgrG5rDqO2eyHPPpYlJjVeoOZZVz6nCnjlWGcm1qTHRP8(sN)Ezh99fyqbW5HGY7yf8tVUdYjjlyY8PcmZh99cSLHh1dP3fh6n5jcb3SW2cvey0B4AskgrG5rDqO2eyQPa48qq5LXKxcN0EpL5tlWGca1WzchIuS(3cK0CbM4cWzbcttFKxE8Gqq8WPm9gUMKcmZh99cSLXKxcN0Epjcb3SWweQiWmF03lWsVOVxGrVHRjPyeri4MLjwOIaJEdxtsXicmpQdc1MadNhckVJvWp96oiNKSGjZNkWmF03lWW13jDq8OXIqWnlCvHkcm6nCnjfJiW8OoiuBcmCEiO8owb)0R7GCsYcMmFQaZ8rFVadNqlHg2pCri4EuwjurGrVHRjPyebMh1bHAtGHZdbL3Xk4NEDhKtswWK5tfyMp67fyqnIW13jfHG7rzrOIaJEdxtsXicmpQdc1MadNhckVJvWp96oiNKSGjZNkWmF03lWS3tBGmTZBATieCp6Ocvey0B4AskgrG5rDqO2ey48qq5DSc(Px3b5KKfmz(0cWo7faQHZeoePy9VfiPcmkReyMp67fy8l56Guwricb2gKPdgNxUcveCZIqfbg9gUMKIreyxQaBPqGz(OVxGn1qTHRjb2utZtcm)DA5L4ZlJjVeoP9Ek7zmeCADqiZh99MUaQoxawYSfUiWMAi3BkKaBzKUGbrlZPLIqW9Ocvey0B4AskgrG5rDqO2eySUaQPatnuB4AkVmsxWGOL50YcWo7fqnfimn9r(B4mXgMEiHY0B4AswGbfimn9rwAOHULXKxIm9gUMKfGnfyqb8Nc(5sV(JnljO23rbuTaSuGbfqnfaX)e0HGtzfdn0DqUGHCk2geYz7A72FMEdxtsbM5J(Eb2u77LrecUNKqfbg9gUMKIreyMp67fyP3PDiApEKNeyeSeiZzkh)hcm1Zkbg0HCpblHGBweHGB1lurGrVHRjPyebMh1bHAtGrpHGpUaQoxa1ZQcmOa0ti4JZscQ9DuavNlalSQadkGAkWud1gUMYlJ0fmiAzoTSadkG)uWpx61FSzjb1(okGQfGLcmOascNhckd1V0LGSHpTBgrkw)BbsQaSiWmF03lWwgtEjuiTuecU5Iqfbg9gUMKIreyxQaBPqGz(OVxGn1qTHRjb2utZtcm)PGFU0R)yZscQ9DuavNlWOfGZcGZdbLxgtEjC4AtsBMpvGn1qU3uib2YiD(tb)CPx)Xkcb3STqfbg9gUMKIreyxQaBPqGz(OVxGn1qTHRjb2utZtcm)PGFU0R)yZscQ9DuavNlWKeyEuheQnbM)MsV9rE4yuBVaBQHCVPqcSLr68Nc(5sV(JvecUzlcvey0B4AskgrGDPcSLcbM5J(Eb2ud1gUMeytnnpjW8Nc(5sV(JnljO23rbsAUaSiW8OoiuBcSPgQnCnL5xYLI6d1Xyh6cl67lWGcSPKw7cdbNInVm8OEi9UnoKsbuDUaQxGn1qU3uib2YiD(tb)CPx)Xkcb3tSqfbg9gUMKIreyEuheQnb2ud1gUMYlJ05pf8ZLE9hBbguawxGPgQnCnLxgPlyq0YCAzbyN9cGZdbL3Xk4NEDhKtswWKrKI1)wavNlal5rla7SxGnL0Axyi4uS5LHh1dP3TXHukGQZfq9fyqb83PLxIpVJvWp96oiNKSGjJifR)TaQwawyvbyJaZ8rFVaBzm5LWjT3tIqWnxvOIaJEdxtsXicmpQdc1MaBQHAdxt5Lr68Nc(5sV(JTadkaudNjCisX6FlqsfWFNwEj(8owb)0R7GCsYcMmIuS(xbM5J(Eb2YyYlHtAVNeHieyq93lJqfb3SiurGrVHRjPyeb2LkWwkeyMp67fytnuB4AsGn108Kalmn9rofrkKSdl67Z0B4AswGbfytjT2fgcofBbsQaSUaCPatub83u6TpYp5rN(qYcWMcmOaQPa(Bk92h5HJrT9cSPgY9McjWsrKcjD7lD(7LD03lcb3JkurGrVHRjPyebMh1bHAtGPMcm1qTHRPCkIuiPBFPZFVSJ((cmOaBkP1UWqWPyZldpQhsVBJdPuGKkaBxGbfqnfaNhckVmM8s4K27PmFAbguaCEiO8QBp5Sx6KTNYisX6FlqsfaQHZeoePy9VfyqbqeeIwgdxtcmZh99cSv3EYzV0jBpjcb3tsOIaJEdxtsXicmpQdc1MaBQHAdxt5uePqs3(sN)Ezh99fyqb83PLxIpVmM8s4K27PSNXqWP1bHmF03B6cKubyjZw4sbguaCEiO8QBp5Sx6KTNYisX6FlqsfWFNwEj(8owb)0R7GCsYcMmIuS(3cmOaSUa(70YlXNxgtEjCs79ugrMCCbguaCEiO8owb)0R7GCsYcMmIuS(3cmrfaNhckVmM8s4K27PmIuS(3cKubyjpAbyJaZ8rFVaB1TNC2lDY2tIqWT6fQiWO3W1KumIa7sfylfcmZh99cSPgQnCnjWMAAEsGPyBqiNTRTB)oePy9Vfq1cWQcWo7fqnfimn9r(B4mXgMEiHY0B4AswGbfimn9rwAOHULXKxIm9gUMKfyqbW5HGYlJjVeoP9EkZNwa2zVaBkP1UWqWPyZldpQhsVBJdPuavNlaBlWMAi3BkKaBh2PoeFAWJiri4Mlcvey0B4AskgrG5rDqO2eyQPatnuB4AkVd7uhIpn4rubguGWqWPihTc5IZjBQatubqKI1)wavlaBxGbfarqiAzmCnjWmF03lWq8PbpIeHGB2wOIaZ8rFVaBjpIcxqEMVvl4jbg9gUMKIreHGB2Iqfbg9gUMKIreyMp67fyi(0GhrcmpQdc1MatnfyQHAdxt5DyN6q8PbpIkWGcOMcm1qTHRPm)sUuuFOog7qxyrFFbguGnL0Axyi4uS5LHh1dP3TXHukGQZfy0cmOaHHGtroAfYfNt2ubuDUaSUaCPaCwawxGrlGATa(tb)CPx)Xwa2ua2uGbfarqiAzmCnjW8J9AYfgcofRGBweHG7jwOIaJEdxtsXicmpQdc1MatnfyQHAdxt5DyN6q8PbpIkWGcGifR)Tajva)DA5L4Z7yf8tVUdYjjlyYisX6FlaNfGfwvGbfWFNwEj(8owb)0R7GCsYcMmIuS(3cK0Cb4sbguGWqWPihTc5IZjBQatubqKI1)wavlG)oT8s85DSc(Px3b5KKfmzePy9VfGZcWfbM5J(EbgIpn4rKieCZvfQiWO3W1KumIaZJ6GqTjWutbMAO2W1uMFjxkQpuhJDOlSOVVadkWMsATlmeCk2cO6CbMKaZ8rFVadxB(HU0lHKqIqWnlSsOIaZ8rFVaJM2RNqwqcm6nCnjfJicricb2ucT99cUhLvJYkwyz0jwGLWqF)WxbgxrTdR4gwJB2A1wbkGkmubAL0dffa6qfa22GmDWqsyRaisTGVrKSa7PqfW4JtXcswapJ9WPnxWmH6NkaxuBfGRVFkHcswaydX)e0HGt5jaSvG4kaSH4Fc6qWP8eitVHRjjSvawZcSWMCbZeQFQatSARaC99tjuqYcaBi(NGoeCkpbGTcexbGne)tqhcoLNaz6nCnjHTcWAwGf2Klyky4kQDyf3WACZwR2kqbuHHkqRKEOOaqhQaWwkI8NcUfWwbqKAbFJizb2tHkGXhNIfKSaEg7HtBUGzc1pvaUO2kaxF)ucfKSaWgI)jOdbNYtayRaXvaydX)e0HGt5jqMEdxtsyRawua2QSvMqfG1SalSjxWuWWvu7WkUH14MTwTvGcOcdvGwj9qrbGoubGnC(wlHTcGi1c(grYcSNcvaJpoflizb8m2dN2CbZeQFQaSO2kaxF)ucfKSaWgI)jOdbNYtayRaXvaydX)e0HGt5jqMEdxtsyRaSMfyHn5cMcgUIAhwXnSg3S1QTcuavyOc0kPhkka0HkaS5LlSvaePwW3iswG9uOcy8XPybjlGNXE40MlyMq9tfGlQTcW13pLqbjlaSH4Fc6qWP8ea2kqCfa2q8pbDi4uEcKP3W1Ke2kaRhfwytUGPGHRO2HvCdRXnBTARafqfgQaTs6HIcaDOcaBBqMoyCE5cBfarQf8nIKfypfQagFCkwqYc4zShoT5cMju)ubgvTvaU((PekizbGne)tqhcoLNaWwbIRaWgI)jOdbNYtGm9gUMKWwbSOaSvzRmHkaRzbwytUGPGbwtj9qbjlWexaZh99fq3BS5cgb2MsEb3JY2SiWsrhuRjbM6kagpEOPyCbGvhCEQGrDfG7BkPGtOcmkxLJcmkRgLvfmfmQRaWoenrC9PGBrbJ5J((nNIi)PGBbNZjBPP6XU0R37lymF03V5ue5pfCl4Co5nithmfmMp673CkI8NcUfCoNSIHgssh0HCsYcgosrK)uWTWTK)E5oZcxkymF03V5ue5pfCl4Co5v3EYzV0jBpXrkI8NcUfUL83l3zw4OHMreeIwgdxtfmMp673CkI8NcUfCoN8YyYlHdxBsA5OHMr8pbDi4uwXqdDhKlyiNITbHC2U2U9xWuWOUcOwA9xay1fw03xWy(OVFNh2(HfmQRat4LKfiUciPGqk9tfibdfmeQa(70YlXVfiH1rbGoubW(jxaCBjzbUVaHHGtXMlymF03VCoN8ud1gUM44nfAEFPZFVSJ(EoMAAEAgNhckV62to7Loz7PmFk7SVPKw7cdbNInVm8OEi9UnoKIQZSDbJ6kaxZq(HfGRN8walkauJ2OGX8rF)Y5CYEtRDMp67D6EdoEtHM9YTGrDfawX)faIxRhxGnrhEgAlqCfiyOcGfKPdgsway1fw03xawJpUaYRF4fypo6OaqhYtBbsVt3p8c0qf4VGPF4fO3cytTwB4AIn5cgZh99lNZjJ4FN5J(ENU3GJ3uO5nithmKKJgAEdY0bdjZMwxWOUcO2tt1JlWQBp5Sx6KTNkGffyuolaxd7kGKh1p8cemubGA0gfGfwvGL83lxomOGqfiySOaQNZcW1WUc0qfOJcqWsAJOTaj6GP)cemubEcwIcWwZ1tUahQa9wG)IcWNwWy(OVF5Co5v3EYzV0jBpXrdnVPKw7cdbNInVm8OEi9UnoKssS9aOgot4qKI1)QkBpaNhckV62to7Loz7PmIuS(3KG7Lzfdwg4pf8ZLE9hRQZQFIyD0kusSWk2OwhTGrDfGTYRhxapJ9WPcGUWI((c0qfibvagBkvGuuFOog7qxyrFFbwkkG9YcOWRJovtfimeCk2cWNMlymF03VCoN8ud1gUM44nfAMFjxkQpuhJDOlSOVNJPMMNMtr9H6ySdDHf99d2usRDHHGtXMxgEupKE3ghsr15rlyuxbGDO(qDmUaWQlSOVhwhfycrbSTfaEpLkGvapYslGHF8rbONqWhxaOdvGGHkWgKPdMcW1tElaRX5BTKqfyJwRlaI2uYhfOd2KlaSo5t5OJc4TVa4ubcglkW2kPAkxWy(OVF5CozVP1oZh99oDVbhVPqZBqMoyCE5Yrdnp1qTHRPm)sUuuFOog7qxyrFFbJ6kWeEjzbIRascQFQajyOVaXva(LkWgKPdMcW1tElWHkaoFRLeAlymF03VCoN8ud1gUM44nfAEdY0bJlyq0YCAjhtnnpnpkx4mmn9rEAd)qz6nCnjvRJYkodttFKvSniK7GClJjVeBMEdxts16OSIZW00h5LXKxch0553m9gUMKQ1r5cNHPPpYM28OogNP3W1KuTokR4CuUOwz9MsATlmeCk28YWJ6H0724qkQoRE2uWOUcW13VTKqfGF7hEbScGfKPdMcW1tUajyOVaiY8m9dVabdva6je8Xfiyq0YCAzbJ5J((LZ5K9Mw7mF03709gC8McnVbz6GX5Llhn0m9ec(4SKGAFhjnp1qTHRP8gKPdgxWGOL50YcgZh99lNZj7nT2z(OV3P7n44nfAgQ)Ez4OHM9Nc(5sV(JD2(wX8mgcojD(0cg1vayF)9YualkG65Saj6G54Jcmzmokax4Saj6GPatgRaS(4JTLub2GmDWWMcgZh99lNZj7nT2z(OV3P7n44nfAgQ)Ez4OHM9Nc(5sV(JnljO23rsZSWo7qnCMWHifR)nPzwg4pf8ZLE9hRQZtQGrDfGR0btbMmwbm9EfaQ)EzkGffq9CwadU1)gfq9fimeCk2cW6Jp2wsfydY0bdBkymF03VCoNS30AN5J(ENU3GJ3uOzO(7LHJgAEtjT2fgcofBEz4r9q6DBCifvNv)a)PGFU0R)yvDw9fmQRat4LkGvaC(wljubsWqFbqK5z6hEbcgQa0ti4JlqWGOL50YcgZh99lNZj7nT2z(OV3P7n44nfAgNV1soAOz6je8Xzjb1(osAEQHAdxt5nithmUGbrlZPLfmQRatOlbTrbsr9H6yCb6VaMwxGdQabdva1oSBcvaCYB8lvGokG34xAlGva2AUEYfmMp67xoNt2qE7jxCie9bhn0m9ec(4SKGAFhQoZcx4KEcbFCgrWPVGX8rF)Y5CYgYBp5s51lvWy(OVF5CozDdNjw3euEjCf6JcgZh99lNZjJBWDhKlqTF4wWuWOUcW13PLxIFlyuxbMWlvGjBVNkWbbnrW9YcGtqhIkqWqfaQrBuGLHh1dP3TXHukae6ukGkh6n5va)PqBb6pxWy(OVFZE5Y5CYlJjVeoP9EId(LCheKdUxoZchn0SAW5HGYlJjVeoP9EkZNoaNhckVm8OEi9U4qVjVmF6aCEiO8YWJ6H07Id9M8YisX6FtAEszUuWOUcW6j8RPDlGPrKjhxa(0cGtEJFPcKGkqC3WcGXyYlrbG9NNFztb4xQayJvWp9wGdcAIG7LfaNGoevGGHkauJ2OaldpQhsVBJdPuai0Puavo0BYRa(tH2c0FUGX8rF)M9YLZ5K3Xk4NEDhKtswWWb)sUdcYb3lNzHJgAgNhckVm8OEi9U4qVjVmF6aCEiO8YWJ6H07Id9M8YisX6FtAEszUuWy(OVFZE5Y5CYqAdoP1w03Zrdnp1qTHRP8(sN)Ezh99duZgKPdgsMvSp0ubJ5J((n7LlNZjdPn4KwBrFVZRj7xIJgAws48qqziTbN0Al67ZisX6FtA0cgZh99B2lxoNtEQ99YWrdnZAe)tqhcoLvm0q3b5cgYPyBqiNTRTB)d8Nc(5sV(JnljO23rsZtID2r8pbDi4uwswWOh7wgtEj2b(tb)CPx)XMelSzaopeuEhRGF61DqojzbtMpDaopeuEzm5LWjT3tz(0bk2geYz7A72Vdrkw)7mRgGZdbLLKfm6XULXKxInlVeFbJ6kaS7oDbGoubu5qVjVcKIOjc7MCbs0btbWyMCbqKjhxGem0xG)IcG4)VF4fad2NlymF03VzVC5Co5070oeThpYtCaDi3tWsmZchn0CyA6J8YWJ6H07Id9M8Y0B4AsoqnHPPpYlJjVeoOZZVz6nCnjlyuxbMWlvavo0BYRaPiQay3Klqcg6lqcQam2uQabdva6je8XfibdfmeQaqOtPaP3P7hEbs0bZXhfad2xGdvGjO8Bua40titRhNlymF03VzVC5Co5LHh1dP3fh6n5XrdntpHGpw1z2MvdMAO2W1uEFPZFVSJ((b(70YlXN3Xk4NEDhKtswWK5th4VtlVeFEzm5LWjT3tzpJHGtRQZSuWy(OVFZE5Y5CYlHqwqsh(9KBt7Heh(XEn5cdbNIDMfoAO5PgQnCnL3x683l7OVFGAKxKxcHSGKo87j3M2djN8IC0(H9dFqyi4uKJwHCX5KnP68OSWo7qnCMWHifR)nPzUmytjT2fgcofBEz4r9q6DBCiLKMubJ5J((n7LlNZjVu62lhn08ud1gUMY7lD(7LD03pWFk4Nl96p2SKGAFhQoZsbJ6kWeEPcGnwb)0BbUVa(70YlXxawBqbHkauJ2Oay)Kztb4FnTBbsqfWqubGF9dVaXvG0lTaQCO3KxbSxwa5vG)IcWytPcGXyYlrbG9NNFZfmMp673SxUCoN8owb)0R7GCsYcgoAO5PgQnCnL3x683l7OVFaRdttFKPFkPV0(H7wgtEj2m9gUMKSZU)oT8s85LXKxcN0EpL9mgcoTQoZcBgWA1eMM(iVm8OEi9U4qVjVm9gUMKSZEyA6J8YyYlHd688BMEdxts2z3FNwEj(8YWJ6H07Id9M8YisX6FvDu2uWOUcaRbvatk3cyiQa8PCuG97uQabdvG7PcKOdMcOVe0gfqfvMCUat4Lkqcg6lGCC)WlaKTbHkqWyFb4AyxbKeu77OahQa)ffydY0bdjlqIoyo(Oa2pUaCnSlxWy(OVFZE5Y5CYkgAijDqhYjjly4Wp2Rjxyi4uSZSWrdnJSw6OP0hztk3mF6awhgcof5OvixCoztj5pf8ZLE9hBwsqTVd2zxnBqMoyiz206b(tb)CPx)XMLeu77q1zFQtXGf3MsVKnfmQRaWAqf4Vcys5wGeTwxaztfirhm9xGGHkWtWsuGjXQLJcWVubulHMCbUVa43UfirhmhFua7hxaUg2LlymF03VzVC5CozfdnKKoOd5KKfmC0qZiRLoAk9r2KYn3VQtIvteYAPJMsFKnPCZsEKf99d8Nc(5sV(JnljO23HQZ(uNIblUnLEzbJ5J((n7LlNZjVmM8s4W1MKwoAO5PgQnCnL3x683l7OVFG)uWpx61FSzjb1(ouDE0cgZh99B2lxoNtM8mx)WDikf1k2l5OHMNAO2W1uEFPZFVSJ((b(tb)CPx)XMLeu77q15rhW6PgQnCnL5xYLI6d1Xyh6cl67zN9nL0Axyi4uS5LHh1dP3TXHusAw9SPGrDfGR0btbWG9CuGgQa)ffW0iYKJlG8EIJcWVubu5qVjVcKOdMcGDtUa8P5cgZh99B2lxoNtEz4r9q6DXHEtEC0qZHPPpYlJjVeoOZZVz6nCnjhm1qTHRP8(sN)Ezh99dW5HGY7yf8tVUdYjjlyY8PfmMp673SxUCoN8YyYlHtAVN4OHMvdopeuEzm5LWjT3tz(0bqnCMWHifR)nP5jMZW00h5LhpieepCktVHRjzbJ6ka33prBk5lWg8qqfirhmfqFjiubsr9vWy(OVFZE5Y5CYPx03xWy(OVFZE5Y5CY467KoiE0yoAOzCEiO8owb)0R7GCsYcMmFAbJ5J((n7LlNZjJtOLqd7hohn0mopeuEhRGF61DqojzbtMpTGX8rF)M9YLZ5KHAeHRVtYrdnJZdbL3Xk4NEDhKtswWK5tlymF03VzVC5Coz790git78MwZrdnJZdbL3Xk4NEDhKtswWK5tlyuxbMmbz86OaqMwJB(Hfa6qfGFnCnvGoiLvTvGj8sfirhmfaBSc(P3cCqfyYKfm5cgZh99B2lxoNtMFjxhKYYrdnJZdbL3Xk4NEDhKtswWK5tzNDOgot4qKI1)M0OSQGPGrDfqTpbtOoOcWwDx690wWy(OVFZ0U07PLZ5K937PpqwqshK2uioAOz6je8X5OvixCofdwuLLbQbNhckVJvWp96oiNKSGjZNoG1QrEr2FVN(azbjDqAtHC48OphTFy)WhOgZh99z)9E6dKfK0bPnfk3Vds3Wzc2zhIxRDiYZyi4KlAfkj4EzwXGf2uWy(OVFZ0U07PLZ5KX13jDhKlyih9KYyoAOz14VtlVeFEzm5LWHRnjTz(0b(70YlXN3Xk4NEDhKtswWK5tzNDOgot4qKI1)M0mlSQGX8rF)MPDP3tlNZjdN3qY2E3b5SjycDbtbJ5J((nt7sVNwoNtg688ljD2emH6GC4KPWrdnZ6nL0Axyi4uS5LHh1dP3TXHuuDEu2zhzT0rtPpYMuU5(vLTzfBgOg)DA5L4Z7yf8tVUdYjjlyY8PdudopeuEhRGF61DqojzbtMpDa9ec(4SKGAFhQopjwvWy(OVFZ0U07PLZ5Kt5rn04(H7W12gC0qZBkP1UWqWPyZldpQhsVBJdPO68OSZoYAPJMsFKnPCZ9RkBZQcgZh99BM2LEpTCoNCWqo(h)4FPd6qEIJgAgNhckJi)qnTRd6qEkZNYo748qqze5hQPDDqhYto)X)bHYBy(HjXcRkymF03VzAx690Y5CYOonvtU(DBQ5PcgZh99BM2LEpTCoNCIdPLtP(DiAV3EpXrdn7VtlVeFEhRGF61Dqojzbtgrkw)BsCHD2HA4mHdrkw)BsSmXfmMp673mTl9EA5Cozfs5qJDhKtZ7BPtIitz5OHMPNqWhNK6z1aCEiO8owb)0R7GCsYcMmFAbJ6kWeKtllaSIS0(HxayV2uOTaqhQaeSqE(GkaYE4uboubg2ADbW5HGwokqdvG0B3gxt5cO21jSXBbc04cexbGtrbcgQa6lbTrb83PLxIVa42sYcCFbSPwRnCnva6jLM2CbJ5J((nt7sVNwoNtgrwA)WDqAtHwoAOzOgot4qKI1)MelzUWo7SM1HHGtrMHmDWKt9HQtmRyN9WqWPiZqMoyYP(iP5rzfBgWAZh9uYrpP00oZc7Sd1WzchIuS(xvhLRYg2Wo7SomeCkYrRqU4CP(WnkRuDsSAaRnF0tjh9Kst7mlSZoudNjCisX6Fvv9QNnSPGPGrDfalithmfGRVtlVe)wWy(OVFZBqMoyCE5Y5CYtnuB4AIJ3uO5Lr6cgeTmNwYXutZtZ(70YlXNxgtEjCs79u2Zyi406GqMp67nTQZSKzlCHJjiKoLqfawVHAdxtfmQRaW6TVxMc0qfibvadrfWBPP9dVa3xGjBVNkGNXqWPnxa2QgspUa4e0HOca1OnkG0EpvGgQajOcWytPc8xb4UHZeBy6HeQa48rbMSHgwamgtEjkq)f4qscvG4kaCkkaSIpn4rub4tlaR)RaQL2geQaQ9DTD7Nn5cgZh99BEdY0bJZlxoNtEQ99YWrdnZA1m1qTHRP8YiDbdIwMtlzND1eMM(i)nCMydtpKqz6nCnjheMM(iln0q3YyYlrMEdxts2mWFk4Nl96p2SKGAFhQYYa1G4Fc6qWPSIHg6oixWqofBdc5SDTD7VGX8rF)M3GmDW48YLZ5KtVt7q0E8ipXb0HCpblXmlCqWsGmNPC8FmREwXbS7oDbGoubWym5LqH0YcWzbWym5LydupKka)RPDlqcQagIkGHF8rbIRaElTa3xGjBVNkGNXqWPnxa2kVECbsWqFbG99llaxHSHpTBb6Tag(XhfiUcG4)cC8rUGX8rF)M3GmDW48YLZ5KxgtEjuiTKJgAMEcbFSQZQNvdONqWhNLeu77q1zwy1a1m1qTHRP8YiDbdIwMtlh4pf8ZLE9hBwsqTVdvzzGKW5HGYq9lDjiB4t7MrKI1)MelfmQRaCnSRabdIwMtl3caDOcqFqO(HxamgtEjkWKT3tfmMp6738gKPdgNxUCoN8ud1gUM44nfAEzKo)PGFU0R)y5yQP5Pz)PGFU0R)yZscQ9DO68OCIZdbLxgtEjC4AtsBMpTGX8rF)M3GmDW48YLZ5KNAO2W1ehVPqZlJ05pf8ZLE9hlhtnnpn7pf8ZLE9hBwsqTVdvNNehn0S)MsV9rE4yuBFbJ5J((nVbz6GX5LlNZjp1qTHRjoEtHMxgPZFk4Nl96pwoMAAEA2Fk4Nl96p2SKGAFhjnZchn08ud1gUMY8l5sr9H6ySdDHf99d2usRDHHGtXMxgEupKE3ghsr1z1xWOUcmz79ubK8O(HxaSXk4NElWHkGHFtPcemiAzoTmxWy(OVFZBqMoyCE5Y5CYlJjVeoP9EIJgAEQHAdxt5Lr68Nc(5sV(JDaRNAO2W1uEzKUGbrlZPLSZoopeuEhRGF61Dqojzbtgrkw)RQZSKhLD23usRDHHGtXMxgEupKE3ghsr1z1pWFNwEj(8owb)0R7GCsYcMmIuS(xvzHvSPGrDfyeE0xaePy93p8cmz790waCc6qubcgQaqnCMOa0l3c0qfa7MCbsCpSffaNkaIm54c0FbIwHYfmMp6738gKPdgNxUCoN8YyYlHtAVN4OHMNAO2W1uEzKo)PGFU0R)yha1WzchIuS(3K83PLxIpVJvWp96oiNKSGjJifR)TGPGrDfalithmKSaWQlSOVVGrDfawdQaybz6Gj5P23ltbmeva(uoka)sfaJXKxInq9qQaXvaC6jOokae6ukqWqfi12TNsfa)E(Ta2llaSVFzb4kKn8PDlanL(c0qfibvadrfWIcOyWsb4Ayxbyne6ukqWqfifr(tb3IcOwcnz2KlymF03V5nithmKKZ5KxgtEj2a1djoAOzwJZdbL3GmDWK5tzNDCEiO8u77LjZNYMcg1vayF)9YualkWK4SaCnSRaj6G54JcmzScKCbupNfirhmfyYyfirhmfaJHh1dPVaQCO3KxbW5HGkaFAbIRa20RLfypfQaCnSRajSnOcSDWBrF)MlymF03V5nithmKKZ5K9Mw7mF03709gC8Mcnd1FVmC0qZ48qq5LHh1dP3fh6n5L5th4pf8ZLE9hBwsqTVJKMhTGrDfqTR3RaRbrfiUca1FVmfWIcOEolaxd7kqIoykablMp0JlG6lqyi4uS5cWAmtHkGTf44JTLub2GmDWKztbJ5J((nVbz6GHKCoNS30AN5J(ENU3GJ3uOzO(7LHJgAEtjT2fgcofBEz4r9q6DBCiLz1pWFk4Nl96pwvNvFbJ6kaSV)EzkGffq9CwaUg2vGeDWC8rbMmghfGlCwGeDWuGjJXrbSxwa2Uaj6GPatgRaguqOcaR3(EzkymF03V5nithmKKZ5K9Mw7mF03709gC8Mcnd1FVmC0qZ(tb)CPx)XMLeu77iPzwMiwhMM(iljkLqUnqwyWjLm9gUMKdW5HGYtTVxMmFkBkymF03V5nithmKKZ5KxMEkhn0CyA6J83WzInm9qcLP3W1KCaI)jOdbNYr)JDXblT3HRnjnytjT2fgcofBEz4r9q6DBCiLK4sbJ6kWeoTaXvGjvGWqWPylWqIslaFAbG99llaxHSHpTBbWhxa)yVUF4faJXKxInq9qkxWy(OVFZBqMoyijNZjVmM8sSbQhsC4h71KlmeCk2zw4OHMLeopeugQFPlbzdFA3mIuS(3KyzWMsATlmeCk28YWJ6H0724qkjnpPbHHGtroAfYfNt20eHifR)vv2UGrDfa2FOcKI6d1X4cGUWI(Eoka)sfaJXKxInq9qQa3ucvaS4qkfirhmfGROwwadU1)gfGpTaXva1xGWqWPylWHkqdvaypxPa9wae))9dVaheuby99fW(XfWuo(pkWbvGWqWPyztbJ5J((nVbz6GHKCoN8YyYlXgOEiXrdnp1qTHRPm)sUuuFOog7qxyrF)awljCEiOmu)sxcYg(0UzePy9VjXc7ShMM(iNGS07vSniuMEdxtYbBkP1UWqWPyZldpQhsVBJdPK0S6ztbJ5J((nVbz6GHKCoN8YWJ6H0724qkC0qZBkP1UWqWPyvDEsCYACEiOCWqo0fb9z(u2zhX)e0HGtzBOzOED7XRDqidUc9Xa)9s(oYsIsjKtAWHtOnJSFOQZSf2mG1QbNhckNIifs2Hf99z(u2zFtjT2fgcofRQZCHnfmQRaymM8sSbQhsfiUcGiieTmfa23VSaCfYg(0UfWEzbIRa0V8iQajOc4TVaEdHgxGBkHkGvaiETUaWEUsb6pUcemubEcwIcGDtUanubsVDBCnLlymF03V5nithmKKZ5KxgtEj2a1djoAOzjHZdbLH6x6sq2WN2nJifR)nPzwyND)DA5L4Z7yf8tVUdYjjlyYisX6FtILjEGKW5HGYq9lDjiB4t7MrKI1)MK)oT8s85DSc(Px3b5KKfmzePy9VfmMp6738gKPdgsY5CYW13PGRnjXrdnJZdbLtje0HSGKUPu)BEdZpu1zUmWFVKVJCkHGoKfK0nL6FZi7hQ6mltQGX8rF)M3GmDWqsoNtEzm5LydupKkykyuxbG993ldH2cg1vaUctRPcWV9dVaWoePqYoSOVNJcytVwwaVTr)WlaMU9ubSxwGj3EQajyOVaymM8suGjBVNkqVfyV7lqCfaNka)ssokablEknka0HkaSUJrT9fmMp673mu)9Ymp1qTHRjoEtHMtrKcjD7lD(7LD03ZXutZtZHPPpYPisHKDyrFFMEdxtYbBkP1UWqWPytI1CzI83u6TpYp5rN(qs2mqn(Bk92h5HJrT9fmMp673mu)9YW5CYRU9KZEPt2EIJgAwntnuB4AkNIifs62x683l7OVFWMsATlmeCk28YWJ6H0724qkjX2dudopeuEzm5LWjT3tz(0b48qq5v3EYzV0jBpLrKI1)MeudNjCisX6FhGiieTmgUMkymF03VzO(7LHZ5KxD7jN9sNS9ehn08ud1gUMYPisHKU9Lo)9Yo67h4VtlVeFEzm5LWjT3tzpJHGtRdcz(OV30jXsMTWLb48qq5v3EYzV0jBpLrKI1)MK)oT8s85DSc(Px3b5KKfmzePy9VdyT)oT8s85LXKxcN0EpLrKjhpaNhckVJvWp96oiNKSGjJifR)DIW5HGYlJjVeoP9EkJifR)njwYJYMcgZh99BgQ)Ez4Co5PgQnCnXXBk08oStDi(0GhrCm1080SITbHC2U2U97qKI1)QkRyND1eMM(i)nCMydtpKqz6nCnjheMM(iln0q3YyYlrMEdxtYb48qq5LXKxcN0EpL5tzN9nL0Axyi4uS5LHh1dP3TXHuuDMT5yccPtjubG1BO2W1ubGoubGv8PbpIYfaByNwajpQF4fqT02GqfqTVRTB)f4qfqYJ6hEbMS9EQaj6GPat2qdlG9Yc8xb4UHZeBy6HekxWOUcaRlrPfGpTaWk(0GhrfOHkqhfO3cy4hFuG4kaI)lWXh5cgZh99BgQ)Ez4CozeFAWJioAOz1m1qTHRP8oStDi(0GhrdcdbNIC0kKloNSPjcrkw)RQS9aebHOLXW1ubJ5J((nd1FVmCoN8sEefUG8mFRwWtfmQRaQL86OLxe9dVaHHGtXwGGXIcKO16cO7PubGoubcgQasEKf99f4GkaSIpn4rubqeeIwMci5r9dVaP2ljL2NlymF03VzO(7LHZ5Kr8PbpI4Wp2Rjxyi4uSZSWrdnRMPgQnCnL3HDQdXNg8iAGAMAO2W1uMFjxkQpuhJDOlSOVFWMsATlmeCk28YWJ6H0724qkQop6GWqWPihTc5IZjBs1zwZfoz9OQv)PGFU0R)yzdBgGiieTmgUMkyuxbGveeIwMcaR4tdEevaYq6XfOHkqhfirR1fGGL0grfqYJ6hEbWgRGF6nxGjFfiySOaiccrltbAOcGDtUaWPylaIm54c0FbcgQapblrb4YMlymF03VzO(7LHZ5Kr8PbpI4OHMvZud1gUMY7Wo1H4tdEenarkw)Bs(70YlXN3Xk4NEDhKtswWKrKI1)YjlSAG)oT8s85DSc(Px3b5KKfmzePy9VjnZLbHHGtroAfYfNt20eHifR)vv)DA5L4Z7yf8tVUdYjjlyYisX6F5KlfmMp673mu)9YW5CY4AZp0LEjKeIJgAwntnuB4AkZVKlf1hQJXo0fw03pytjT2fgcofRQZtQGX8rF)MH6VxgoNtMM2RNqwqfmfmQRaJW3AjH2cgZh99BgNV1Y5LPNYrdnRMW00h5VHZeBy6HektVHRj5ae)tqhcoLJ(h7IdwAVdxBsAWMsATlmeCk28YWJ6H0724qkjXLcgZh99BgNV1soNtEz4r9q6DBCifoAO5nL0Axyi4uSQopAbJ5J((nJZ3AjNZjVeczbjD43tUnThsC0qZ(70YlXNxcHSGKo87j3M2dPSNXqWP1bHmF03BAvNhnZw4c7SVhVgVFzwtM0Hp2rWIPKQPm9gUMKdudopeuwtM0Hp2rWIPKQPmFAbJ5J((nJZ3AjNZjdxFNcU2KubJ5J((nJZ3AjNZjJB(HBy4Iqecba]] )


end
