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


    spec:RegisterPack( "Subtlety", 20201126, [[da1fXbqiuk9ikr2eL0NqPO0OqvQtHQKvHsbVcLQzHQ4wkk0Uu4xIkggOKJbQAzIcpdvvMgQQ6AucTnqP8nfL04uuIZrjkADucuZtu09uK9HQY)qPOGdsjaluuPhsjQMOIIUiLakBurP6JuIsmskrjDsukQwPIQxIsrHMjLaYnPei7KK0prPOOHIsHwkkf5PqmvsIRQOG2kLOuFvrbolLaQ2lH)sXGv1HfwmkESitMuxgzZG8zuYOH0PLA1uIcVwuA2eDBsSBGFRYWPuhxrPSCOEUstNQRJkBhu8DsQXdkvNxu16Pe08bv2VKfWlurGOdNeQMbSYawWdFgW2awZk)M1m4VaXZBtce7iLnyrceqOqceeogxsEEbIDKxEHwOIazpoCIeiOUBVwW5KdR2r5ygPtjNTv4KH3hiHdipNTvs5iqy4APZMdemceD4Kq1mGvgWcE4Za2gWAw53SMrgcKGZrpSabPvSCbcAR1eqWiq00MeiwQEeogxsE(6zthloQMBP6v9GHuyiC9zaB8uFgWkdyjqK96RqfbY6uiDuslurOk8cveieiyKKwKRajHBNWDiq4D9mCqqJ1Pq6Odo76HdU6z4GGgWeGErhC21ZlbsK8(acKfn0N61XDws4cvZqOIaHabJK0ICfijC7eUdbcdhe0yr5WDwcy8ddc9n4SR3A9PtH5m2xd8DOjOo1E9zovFgcKi59beiPqknrY7dyK96cezVUbekKabQb9IkCHQ8tOIaHabJK0ICfijC7eUdbYAtsPXdmlY3XIYH7SeWS(HvQFQE(xV16tNcZzSVg4B98nvp)firY7diqsHuAIK3hWi71fiYEDdiuibcud6fv4cv5VqfbcbcgjPf5kqs42jChcK0PWCg7Rb(o0euNAV(mNQh(6NX65D9EijGp0eztyZ64WdwKYGabJK01BTEgoiObmbOx0bND98sGejVpGajfsPjsEFaJSxxGi71nGqHeiqnOxuHlu1IcveieiyKKwKRajHBNWDiq8qsaFaAwO(6HmlHheiyKKUER1J5ae0HzrdVb5n(b7DYWidnnOzJRTTjD9wRFTjP04bMf57yr5WDwcyw)Wk1Nz9wuGejVpGazrByeUqvytOIaHabJK0ICfijC7eUdbIKGHK1Nz9wmJ6TwVMy4GGgqnqButrwaT7atkrd26ZSE4R3A9EGzr(WBfY4Nr3u9Zy9ysjAWwpF1dBcKi59beilAOp1RJ7SKWfQoRcveieiyKKwKRajsEFabYIg6t964oljqs42jChcenXWbbnGAG2OMISaA3bMuIgS1Nz9WxV16xBsknEGzr(owuoCNLaM1pSs9zovp)Q3A9EGzr(WBfY4Nr3u9Zy9ysjAWwpF1dBcKu(KKmEGzr(kufEHluDweQiqiqWijTixbsc3oH7qGW269qsaFOjYMWM1XHhSiLbbcgjPR3A9Hfs42PbJm0KPbghLmlAOp17ahGS1pvp)Q3A9RnjLgpWSiFhlkhUZsaZ6hwP(P65NajsEFabYIg6t964oljCHQwMcveieiyKKwKRajHBNWDiqGjWDWiPb3sgBCF42ZBWNhEFG6TwpVRxtmCqqdOgOnQPilG2DGjLObB9zwp81dhC17HKa(qnf2hqjwNWdcemssxV16xBsknEGzr(owuoCNLaM1pSs9zovp)Rho4QpSqc3onAabt7btlBp)GabJK01BTEgoiOXMxH5KR5GmAkC0bND9wRFTjP04bMf57yr5WDwcyw)Wk1N5u98RE2RpSqc3onyKHMmnW4OKzrd9PEheiyKKUEEjqIK3hqGSOH(uVoUZscxOk8WsOIaHabJK0ICfijC7eUdbYAtsPXdmlY365BQE(vp71Z76z4GGg2ysH0ThEFGbND9Wbx9mCqqdhLm4ZDcm4SRho4QhZbiOdZIgr2iW9A2JtAGWblfc4dA24ABBsxV16thqZ1(qtKnHn6GflcVdCaYwpFt1pR1ZlbsK8(acKfLd3zjGz9dRiCHQWdVqfbcbcgjPf5kqs42jChcenXWbbnGAG2OMISaA3bMuIgS1N5u9WxpCWvF6oP(udgBEfMtUMdYOPWrhysjAWwFM1d)SuV161edhe0aQbAJAkYcODhysjAWwFM1NUtQp1GXMxH5KR5GmAkC0bMuIgScKi59beilAOp1RJ7SKWfQcFgcveieiyKKwKRab6Wgab7Uqv4firY7diqSVtAW0EC4ejCHQWZpHkcecemsslYvGKWTt4oeimCqqdBcdD4WjTbgQb7y9iLTE(MQ3I1BT(0b0CTpSjm0HdN0gyOgSdCaYwpFt1dp)eirY7diqyjVtHrgAs4cvHN)cveirY7diqw0qFQxh3zjbcbcgjPf5kCHlqODjqIwHkcvHxOIaHabJK0ICfijC7eUdbcbimR8dVviJFgLa2RNV6HVER1Z26z4GGgBEfMtUMdYOPWrhC21BTEExpBRxF(iDGebCC4K2ajdfYWWHbdVtzBaR6TwpBRpsEFGr6ajc44WjTbsgk0ObgizZc1Rho4QhItknykHgywKXBfQ(mRNvspucyVEEjqIK3hqGKoqIaooCsBGKHcjCHQziurGqGGrsArUcKeUDc3HaHT1NUtQp1GXIg6tTHrgAAhC21BT(0Ds9Pgm28kmNCnhKrtHJo4SRho4QhQzH6gmPenyRpZP6HhwcKi59beimY70MdY4OKHaKsEHluLFcveirY7diqyXfyDhaZbzclKWNJkqiqWijTixHluL)cveieiyKKwKRajHBNWDiq4D9RnjLgpWSiFhlkhUZsaZ6hwPE(MQpJ6HdU6XrRnemeWhHwVJgupF1dBWQEEvV16zB9P7K6tnyS5vyo5AoiJMchDWzxV16zB9mCqqJnVcZjxZbz0u4Odo76TwpbimR8dnb1P2RNVP65hSeirY7diqGUe3sAtyHeUDYWqHIWfQArHkcecemsslYvGKWTt4oeiRnjLgpWSiFhlkhUZsaZ6hwPE(MQpJ6HdU6XrRnemeWhHwVJgupF1dBWsGejVpGaXMd3q5BaldJmwx4cvHnHkcecemsslYvGKWTt4oeimCqqdmLYkPDnqhordo76HdU6z4GGgykLvs7AGoCImPJd4eESEKYwFM1dpSeirY7diqCuYWbyooG2aD4ejCHQZQqfbsK8(aceCBBljtdmRDKibcbcgjPf5kCHQZIqfbcbcgjPf5kqs42jChcK0Ds9Pgm28kmNCnhKrtHJoWKs0GT(mR3I1dhC1d1SqDdMuIgS1Nz9WplcKi59beiQpSudd1adM2deGejCHQwMcveieiyKKwKRajHBNWDiqiaHzLV(mRN)WQER1ZWbbn28kmNCnhKrtHJo4SfirY7diquiLdN3CqgjxQ1gnMcLv4cvHhwcveieiyKKwKRajHBNWDiqGAwOUbtkrd26ZSE4hwSE4GREExpVR3dmlYhOuiD0HDYRNV6NfyvpCWvVhywKpqPq6Od7KxFMt1NbSQNx1BTEExFK8ggYqasPPT(P6HVE4GREOMfQBWKs0GTE(QpdlZ65v98QE4GREExVhywKp8wHm(zStUjdyvpF1ZpyvV165D9rYByidbiLM26NQh(6HdU6HAwOUbtkrd265RE(Z)65v98sGejVpGabtHDdyzGKHcTcx4cenbfCsxOIqv4fQiqIK3hqGKTtzfieiyKKwKRWfQMHqfbcbcgjPf5kqoBbYsUajsEFabcmbUdgjjqGjKCKaHHdcASYorMaOn6ordo76HdU6xBsknEGzr(owuoCNLaM1pSs98nvpSjqGjWgqOqcKfOnPdOBVpGWfQYpHkcecemsslYvGejVpGajfsPjsEFaJSxxGi71nGqHeij9kCHQ8xOIaHabJK0ICfijC7eUdbY6uiDuspcPuGejVpGabZbmrY7dyK96cezVUbekKazDkKokPfUqvlkurGqGGrsArUcKeUDc3HazTjP04bMf57yr5WDwcyw)Wk1Nz9Ww9wRhQzH6gmPenyRNV6HT6Twpdhe0yLDImbqB0DIgysjAWwFM1ZkPhkbSxV16tNcZzSVg4B98nvp)RFgRN317TcvFM1dpSQNx1ZgQpdbsK8(acKv2jYeaTr3js4cvHnHkcecemsslYvGC2cKLCbsK8(aceycChmssGati5ibInUpC75n4ZdVpq9wRFTjP04bMf57yr5WDwcyw)Wk1Z3u9ziqGjWgqOqceULm24(WTN3Gpp8(acxO6SkurGqGGrsArUcKeUDc3HabMa3bJKgClzSX9HBpVbFE49beirY7diqsHuAIK3hWi71fiYEDdiuibY6uiDutsVcxO6SiurGqGGrsArUcKZwGSKlqIK3hqGatG7GrsceycjhjqYWI1ZE9EijGpGPzD4bbcgjPRNnuFgWQE2R3djb8HsSoHnhKzrd9PEheiyKKUE2q9zaR6zVEpKeWhlAOp1gOlXTdcemssxpBO(mSy9SxVhsc4JqgjC75heiyKKUE2q9zaR6zV(mSy9SH65D9RnjLgpWSiFhlkhUZsaZ6hwPE(MQN)1Zlbcmb2acfsGSofsh14OyArpPw4cvTmfQiqiqWijTixbsc3oH7qGqacZk)qtqDQ96ZCQEycChmsASofsh14OyArpPwGejVpGajfsPjsEFaJSxxGi71nGqHeiRtH0rnj9kCHQWdlHkcecemsslYvGKWTt4oeiPtH5m2xd8T(P6dqRej0aZI0MKTajsEFabskKstK8(agzVUar2RBaHcjqGAqVOcxOk8WlurGqGGrsArUcKeUDc3HajDkmNX(AGVdnb1P2RpZP6HVE4GREOMfQBWKs0GT(mNQh(6TwF6uyoJ91aFRNVP65NajsEFabskKstK8(agzVUar2RBaHcjqGAqVOcxOk8ziurGqGGrsArUcKeUDc3HazTjP04bMf57yr5WDwcyw)Wk1Z3u98VER1NofMZyFnW365BQE(lqIK3hqGKcP0ejVpGr2RlqK96gqOqceOg0lQWfQcp)eQiqiqWijTixbsc3oH7qGqacZk)qtqDQ96ZCQEycChmsASofsh14OyArpPwGejVpGajfsPjsEFaJSxxGi71nGqHeimCTulCHQWZFHkcecemsslYvGKWTt4oeieGWSYp0euNAVE(MQhElwp71tacZk)atSiGajsEFabsGtbGm(HXeWfUqv4TOqfbsK8(acKaNcazS5KljqiqWijTixHlufEytOIajsEFabISzH6RXYGtZsHaUaHabJK0ICfUqv4NvHkcKi59beimblZbzCCNYUcecemsslYv4cxGyJP0PWeUqfHQWlurGejVpGajSTL5n2xVhqGqGGrsArUcxOAgcveirY7diqwNcPJkqiqWijTixHluLFcveieiyKKwKRajsEFabIsGZsAd0HnAkCubInMsNct4MLshqVce4TOWfQYFHkcecemsslYvGejVpGazLDImbqB0DIeijC7eUdbcMGW0IgmssGyJP0PWeUzP0b0RabEHlu1IcveieiyKKwKRajHBNWDiqWCac6WSOHsGZAoiJJsgLyDcBIDJDBWGMnU22M0cKi59beilAOp1ggzOPv4cvHnHkcecemsslYvGacfsGew4Ig4ynqhWnhKX(utybsK8(acKWcx0ahRb6aU5Gm2NAclCHlqy4APwOIqv4fQiqiqWijTixbsc3oH7qGW269qsaFaAwO(6HmlHheiyKKUER1J5ae0HzrdVb5n(b7DYWidnnOzJRTTjD9wRFTjP04bMf57yr5WDwcyw)Wk1Nz9wuGejVpGazrByeUq1meQiqiqWijTixbsc3oH7qGS2KuA8aZI8TE(MQpJ6zVEExVhsc4dwY7uyKHMgeiyKKUER1hwiHBNg2eg6WHtdCaYwpFt1Nr98sGejVpGazr5WDwcyw)WkcxOk)eQiqiqWijTixbsc3oH7qGKUtQp1GXsyC4K2WCaYS2DwAKqdmlAnq4i59bcz98nvFgJz1I1dhC1VhNKPb6HKcTHjVHG9qXwsdcemssxV16zB9mCqqdjfAdtEdb7HITKgC2cKi59beilHXHtAdZbiZA3zjHluL)cveirY7diqyjVtHrgAsGqGGrsArUcxOQffQiqIK3hqGWePSRhmcecemsslYv4cxGK0RqfHQWlurGqGGrsArUcKeUDc3HaHT1ZWbbnw0qFQn6aKObND9wRNHdcASOC4olbm(HbH(gC21BTEgoiOXIYH7SeW4hge6BGjLObB9zovp)gwuGejVpGazrd9P2OdqIeiClzoiidRKwOk8cxOAgcveieiyKKwKRajHBNWDiqy4GGglkhUZsaJFyqOVbND9wRNHdcASOC4olbm(HbH(gysjAWwFMt1ZVHffirY7diq28kmNCnhKrtHJkq4wYCqqgwjTqv4fUqv(jurGqGGrsArUcKeUDc3HabMa3bJKglqBshq3EFG6TwpBRFDkKokPhkbWLKajsEFabcKmyrsz49beUqv(lurGqGGrsArUcKeUDc3HartmCqqdizWIKYW7dmWKs0GT(mRpdbsK8(aceizWIKYW7dysskaljCHQwuOIaHabJK0ICfijC7eUdbcVRhZbiOdZIgkboR5GmokzuI1jSj2n2TbdA24ABBsxV16tNcZzSVg47qtqDQ96ZCQE(vpCWvpMdqqhMfn0u4OY8Mfn0N6DqZgxBBt66TwF6uyoJ91aFRpZ6HVEEvV16z4GGgBEfMtUMdYOPWrhC21BTEgoiOXIg6tTrhGen4SR3A9kX6e2e7g72adMuIgS1pvpSQ3A9mCqqdnfoQmVzrd9PEh6tnqGejVpGabMa0lQWfQcBcveieiyKKwKRajHBNWDiqyB9RtH0rj9iKY6TwpmbUdgjnwG2KoGU9(a1dhC1t7sGenyWu4OMdY4OKrNVbSgkHLXHR3A9ERq1Z3u9ziqIK3hqGKcP0ejVpGr2RlqK96gqOqceAxcKOv4cvNvHkcecemsslYvGejVpGaX(oPbt7XHtKajHBNWDiq8qsaFSOC4olbm(HbH(geiyKKUER1Z269qsaFSOH(uBGUe3oiqWijTab6Wgab7Uqv4fUq1zrOIaHabJK0ICfijC7eUdbcbimR81Z3u9WgSQ3A9We4oyK0ybAt6a627duV16t3j1NAWyZRWCY1Cqgnfo6GZUER1NUtQp1GXIg6tTrhGensObMfT1Z3u9WlqIK3hqGSOC4olbm(HbH(eUqvltHkcecemsslYvGejVpGazjmoCsByoazw7oljqs42jChceycChmsASaTjDaD79bQ3A9STE95JLW4WjTH5aKzT7SKrF(W7u2gWQER17bMf5dVviJFgDt1Z3u9zaF9Wbx9qnlu3GjLObB9zovVfR3A9RnjLgpWSiFhlkhUZsaZ6hwP(mRNFcKu(KKmEGzr(kufEHlufEyjurGqGGrsArUcKeUDc3HabMa3bJKglqBshq3EFG6TwF6uyoJ91aFhAcQtTxpFt1dVajsEFabYs2BVcxOk8WlurGqGGrsArUcKeUDc3HabMa3bJKglqBshq3EFG6TwpBRpDNuFQbJfn0NAdJm00o4SR3A98UEpKeWheagsE2nGLzrd9PEheiyKKUE4GR(0Ds9Pgmw0qFQn6aKOrcnWSOTE(MQh(65v9wRN31Z269qsaFSOC4olbm(HbH(geiyKKUE4GREpKeWhlAOp1gOlXTdcemssxpCWvF6oP(udglkhUZsaJFyqOVbMuIgS1Zx9zupVQ3A98UE2wpTlbs0GrEN2CqghLmeGuYpuclJdxpCWvF6oP(udgmY70MdY4OKHaKs(bMuIgS1Zx9zupVeirY7diq28kmNCnhKrtHJkCHQWNHqfbcbcgjPf5kqIK3hqGOe4SK2aDyJMchvGKWTt4oei4O1gcgc4JqR3bND9wRN317bMf5dVviJFgDt1Nz9PtH5m2xd8DOjOo1E9Wbx9ST(1Pq6OKEesz9wRpDkmNX(AGVdnb1P2RNVP6t2gLa2nRnb01ZlbskFssgpWSiFfQcVWfQcp)eQiqiqWijTixbsc3oH7qGGJwBiyiGpcTEhnOE(QNFWQ(zSEC0Adbdb8rO17qZHdVpq9wRpDkmNX(AGVdnb1P2RNVP6t2gLa2nRnb0cKi59beikbolPnqh2OPWrfUqv45VqfbcbcgjPf5kqs42jChceycChmsASaTjDaD79bQ3A9PtH5m2xd8DOjOo1E98nvFgcKi59beilAOp1ggzOPv4cvH3IcveieiyKKwKRajHBNWDiqGjWDWiPXc0M0b0T3hOER1NofMZyFnW3HMG6u71Z3u98RER1Z76HjWDWiPb3sgBCF42ZBWNhEFG6HdU6xBsknEGzr(owuoCNLaM1pSs9zovp)RNxcKi59beiuc9AaldMSXTsa0cxOk8WMqfbcbcgjPf5kqs42jChcepKeWhlAOp1gOlXTdcemssxV16HjWDWiPXc0M0b0T3hOER1ZWbbn28kmNCnhKrtHJo4SfirY7diqwuoCNLag)WGqFcxOk8ZQqfbcbcgjPf5kqs42jChce2wpdhe0yrd9P2OdqIgC21BTEOMfQBWKs0GT(mNQFwQN969qsaFSCmoHH4yrdcemsslqIK3hqGSOH(uB0bircxOk8ZIqfbsK8(ace7Z7diqiqWijTixHlufEltHkcecemsslYvGKWTt4oeimCqqJnVcZjxZbz0u4OdoBbsK8(aceg5DAdehoVWfQMbSeQiqiqWijTixbsc3oH7qGWWbbn28kmNCnhKrtHJo4SfirY7diqyi8s4SnGLWfQMb8cveieiyKKwKRajHBNWDiqy4GGgBEfMtUMdYOPWrhC2cKi59beiqnMyK3PfUq1mYqOIaHabJK0ICfijC7eUdbcdhe0yZRWCY1Cqgnfo6GZwGejVpGajajADCinPqkfUq1m4NqfbcbcgjPf5kqIK3hqGKYNKNJpqNmmYyDbsc3oH7qGW26xNcPJs6riL1BTEycChmsASaTjDaD79bQ3A9STEgoiOXMxH5KR5GmAkC0bND9wRNaeMv(HMG6u71Z3u98dwceccIsUbekKajLpjphFGozyKX6cxOAg8xOIaHabJK0ICfirY7diqclCrdCSgOd4MdYyFQjSajHBNWDiqyB9mCqqJfn0NAJoajAWzxV16t3j1NAWyZRWCY1Cqgnfo6atkrd26ZSE4HLabekKajSWfnWXAGoGBoiJ9PMWcxOAgwuOIaHabJK0ICfirY7diqIffMaqRbhw4HnPdhsbsc3oH7qGOjgoiOboSWdBshoKgnXWbbn0NAq9Wbx9AIHdcAKoGMl5nmKPbznAIHdcAWzxV169aZI8bkfshDyN86ZSE(Lr9wR3dmlYhOuiD0HDYRNVP65hSQho4QNT1RjgoiOr6aAUK3WqMgK1OjgoiObND9wRN31RjgoiOboSWdBshoKgnXWbbnwpszRNVP6ZWI1pJ1dpSQNnuVMy4GGgmY70MdY4OKHaKs(bND9Wbx9qnlu3GjLObB9zwp)Hv98QER1ZWbbn28kmNCnhKrtHJoWKs0GTE(QFweiGqHeiXIctaO1Gdl8WM0HdPWfQMbSjurGqGGrsArUceqOqceL86ynEi7vjacKi59beik51XA8q2RsaeUq1mMvHkcecemsslYvGKWTt4oeimCqqJnVcZjxZbz0u4Odo76HdU6HAwOUbtkrd26ZS(mGLajsEFabc3sM2jLv4cxGSofsh1K0RqfHQWlurGqGGrsArUcKZwGSKlqIK3hqGatG7Grsceycjhjqs3j1NAWyrd9P2OdqIgj0aZIwdeosEFGqwpFt1d)ywTOabMaBaHcjqwuTXrX0IEsTWfQMHqfbcbcgjPf5kqs42jChceExpBRhMa3bJKglQ24OyArpPUE4GRE2wVhsc4dqZc1xpKzj8GabJK01BTEpKeWh6aN1SOH(upiqWijD98QER1NofMZyFnW3HMG6u71Zx9WxV16zB9yoabDyw0qjWznhKXrjJsSoHnXUXUnyqZgxBBtAbsK8(aceycqVOcxOk)eQiqiqWijTixbsK8(ace77KgmThhorcec2DCycLJd4ce(dlbc0Hnac2DHQWlCHQ8xOIaHabJK0ICfijC7eUdbcbimR81Z3u98hw1BTEcqyw5hAcQtTxpFt1dpSQ3A9STEycChmsASOAJJIPf9K66TwF6uyoJ91aFhAcQtTxpF1dF9wRxtmCqqdOgOnQPilG2DGjLObB9zwp8cKi59beilAOp1kKulCHQwuOIaHabJK0ICfiNTazjxGejVpGabMa3bJKeiWesosGKofMZyFnW3HMG6u71Z3u98xGatGnGqHeilQ2KofMZyFnWxHluf2eQiqiqWijTixbYzlqwYfirY7diqGjWDWijbcmHKJeiPtH5m2xd8DOjOo1E9zovp8cKeUDc3HabMa3bJKgClzSX9HBpVbFE49bQ3A9RnjLgpWSiFhlkhUZsaZ6hwPE(MQN)ceycSbekKazr1M0PWCg7Rb(kCHQZQqfbcbcgjPf5kqs42jChceycChmsASOAt6uyoJ91aFR3A98UEycChmsASOAJJIPf9K66HdU6z4GGgBEfMtUMdYOPWrhysjAWwpFt1d)iJ6HdU6xBsknEGzr(owuoCNLaM1pSs98nvp)R3A9P7K6tnyS5vyo5AoiJMchDGjLObB98vp8WQEEjqIK3hqGSOH(uB0bircxO6SiurGqGGrsArUcKeUDc3HabMa3bJKglQ2KofMZyFnW36TwpuZc1nysjAWwFM1NUtQp1GXMxH5KR5GmAkC0bMuIgScKi59beilAOp1gDasKWfUabQb9IkurOk8cveieiyKKwKRajHBNWDiqwBsknEGzr(owuoCNLaM1pSs9zwpSvV16zB9mCqqJfn0NAJoajAWzxV16z4GGgRStKjaAJUt0atkrd26ZSEOMfQBWKs0GTER1ZWbbnwzNita0gDNObMuIgS1Nz98UE4RN96tNcZzSVg4B98QE2q9WpMfbsK8(acKv2jYeaTr3js4cvZqOIaHabJK0ICfiNTazjxGejVpGabMa3bJKeiWesosGOeRtytSBSBdmysjAWwpF1dR6HdU6zB9EijGpanluF9qMLWdcemssxV169qsaFOdCwZIg6t9GabJK01BTEgoiOXIg6tTrhGen4SRho4QFTjP04bMf57yr5WDwcyw)Wk1Z3u9WMabMaBaHcjq2STTbZz7Cys4cv5NqfbcbcgjPf5kqs42jChce2wpmbUdgjn2STTbZz7CyQER17bMf5dVviJFgDt1pJ1JjLObB98vpSvV16XeeMw0GrscKi59beiyoBNdtcxOk)fQiqIK3hqGSuctUXPekONnosGqGGrsArUcxOQffQiqiqWijTixbsK8(acemNTZHjbsc3oH7qGW26HjWDWiPXMTTnyoBNdt1BTE2wpmbUdgjn4wYyJ7d3EEd(8W7duV16xBsknEGzr(owuoCNLaM1pSs98nvFg1BTEpWSiF4Tcz8ZOBQE(MQN31BX6zVEExFg1ZgQpDkmNX(AGV1ZR65v9wRhtqyArdgjjqs5tsY4bMf5Rqv4fUqvytOIaHabJK0ICfijC7eUdbcBRhMa3bJKgB222G5SDomvV16XKs0GT(mRpDNuFQbJnVcZjxZbz0u4OdmPenyRN96Hhw1BT(0Ds9Pgm28kmNCnhKrtHJoWKs0GT(mNQ3I1BTEpWSiF4Tcz8ZOBQ(zSEmPenyRNV6t3j1NAWyZRWCY1Cqgnfo6atkrd26zVElkqIK3hqGG5SDomjCHQZQqfbcbcgjPf5kqs42jChce2wpmbUdgjn4wYyJ7d3EEd(8W7duV16xBsknEGzr(wpFt1ZpbsK8(acegzKYASp1AclCHQZIqfbsK8(acecMEteoCsGqGGrsArUcx4cxGadH3(acvZawzal4Hpd(jquhyqdyTcKzGfaBsv2CvTSybxF9QGs13k2h2Rh6W1ZMLHRLA2S1JPzJRXKU(9uO6do)ucN01NqdalAh1ClqnGQpdl46ztKYbdPR3(227dyyIu26tOukB98gCE9bmrldgjvFdQNu4KH3hGx1ZB4HDEnQ51C2Cf7d7KU(zP(i59bQx2RVJAUazTPKq1mGn4fi24dQLKaXs1JWX4sYZxpB6yXr1ClvVQhmKcdHRpdyJN6ZawzaRAEn3s1ZgX0mA5Nct418i59b2HnMsNct4SpLtyBlZBSVEpqnpsEFGDyJP0PWeo7t5SofshTMhjVpWoSXu6uycN9PCucCwsBGoSrtHJYJnMsNct4MLshqVtWBXAEK8(a7WgtPtHjC2NYzLDImbqB0DI4XgtPtHjCZsPdO3j45PHMWeeMw0Grs18i59b2HnMsNct4SpLZIg6tTHrgAA5PHMWCac6WSOHsGZAoiJJsgLyDcBIDJDBWGMnU22M018i59b2HnMsNct4SpLd3sM2jfEaHcnfw4Ig4ynqhWnhKX(ut4AEn3s1BbfnOE205H3hOMhjVpWoLTtzR5wQ(z4s669REn5ewPbu9QrjhLW1NUtQp1GTE1r71dD46raZSEMyjD9hOEpWSiFh18i59bw2NYbMa3bJK4bek00c0M0b0T3hGhycjhnXWbbnwzNita0gDNObNnCWT2KuA8aZI8DSOC4olbmRFyf(MGTAULQ3YrPu26T8zU1hE9qnE9AEK8(al7t5KcP0ejVpGr2RZdiuOPKER5wQE2ehOEioPmF9R62tO0wVF17Ou9iofshL01ZMop8(a1ZBM81RVgWQ(94P96HoCI26TVt2aw13q1dohTbSQV36dyIwgmsIxJAEK8(al7t5G5aMi59bmYEDEaHcnTofshL080qtRtH0rj9iKYAULQ3cW2wMV(v2jYeaTr3jQ(WRpd2R3YzJ1R5WnGv9okvpuJxVE4Hv9lLoGE5jGCcxVJgE98N96TC2y9nu9Txpb72nM26v3oAdQ3rP6beS71BzXYNz9hU(ERhCE9C218i59bw2NYzLDImbqB0DI4PHMwBsknEGzr(owuoCNLaM1pSsMWMvOMfQBWKs0GLpyZkdhe0yLDImbqB0DIgysjAWMjRKEOeWU10PWCg7Rb(Y3e)NrE7TcLj8WIxSHmQ5wQE2mbY81NqdalQE85H3hO(gQE1u9Obmu924(WTN3Gpp8(a1VKxFa01RWj92ws17bMf5B9C2JAEK8(al7t5atG7Grs8acfAIBjJnUpC75n4ZdVpapWesoAYg3hU98g85H3hW6AtsPXdmlY3XIYH7SeWS(Hv4BkJAULQNnI7d3E(6ztNhEFa2muVfiYzZU1ZQHHQpQpHd76dMJZRNaeMv(6HoC9okv)6uiD06T8zU1ZBgUwQjC9R3sz9yATPKxF78AuVf4C280E9PaupdvVJgE9BRylPrnpsEFGL9PCsHuAIK3hWi715bek006uiDutsV80qtWe4oyK0GBjJnUpC75n4ZdVpqn3s1pdxsxVF1RjOgq1RgLa17x9Clv)6uiD06T8zU1F46z4APMWBnpsEFGL9PCGjWDWijEaHcnTofsh14OyArpPMhycjhnLHfz3djb8bmnRdpiqWijnBidyXUhsc4dLyDcBoiZIg6t9oiqWijnBidyXUhsc4Jfn0NAd0L42bbcgjPzdzyr29qsaFeYiHBp)GabJK0SHmGf7zyr2aVxBsknEGzr(owuoCNLaM1pScFt8Nx1ClvVLFGT1eUEUTbSQpQhXPq6O1B5ZSE1OeOEmfj0gWQEhLQNaeMv(6DumTONuxZJK3hyzFkNuiLMi59bmYEDEaHcnTofsh1K0lpn0ebimR8dnb1P2ZCcMa3bJKgRtH0rnokMw0tQR5rY7dSSpLtkKstK8(agzVopGqHMGAqVO80qtPtH5m2xd8DkaTsKqdmlsBs21Clv)S3GErRp865p71RUD0JZRFMi8uVfzVE1TJw)mrQN3hNVTMQFDkKokVQ5rY7dSSpLtkKstK8(agzVopGqHMGAqVO80qtPtH5m2xd8DOjOo1EMtWdhCqnlu3GjLObBMtWBnDkmNX(AGV8nXVAULQFg0oA9ZeP(qUx9qnOx06dVE(ZE9bRObRxp)R3dmlY3659X5BRP6xNcPJYRAEK8(al7t5KcP0ejVpGr2RZdiuOjOg0lkpn00AtsPXdmlY3XIYH7SeWS(Hv4BI)wtNcZzSVg4lFt8VMBP6NHlvFupdxl1eUE1OeOEmfj0gWQEhLQNaeMv(6DumTONuxZJK3hyzFkNuiLMi59bmYEDEaHcnXW1snpn0ebimR8dnb1P2ZCcMa3bJKgRtH0rnokMw0tQR5wQElqNAA96TX9HBpF9nO(qkR)GQ3rP6TayJwGQNHsb3s13E9PGBPT(OEllw(mR5rY7dSSpLtGtbGm(HXeW5PHMiaHzLFOjOo1oFtWBr2jaHzLFGjweOMhjVpWY(uobofaYyZjxQMhjVpWY(uoYMfQVgldonlfc418i59bw2NYHjyzoiJJ7u2TMxZTu9w(Ds9PgS1Clv)mCP6Nzasu9he0mYkPRNHGomvVJs1d141RFr5WDwcyw)Wk1dHpL6v5WGqF1NofARVbJAEK8(a7iPx2NYzrd9P2OdqI4HBjZbbzyL0tWZtdnXwgoiOXIg6tTrhGen4STYWbbnwuoCNLag)WGqFdoBRmCqqJfLd3zjGXpmi03atkrd2mN43WI1ClvpVNHajTB9HetHoF9C21ZqPGBP6vt173LTEe0qFQRF2Ve3YR65wQEK8kmNCR)GGMrwjD9me0HP6DuQEOgVE9lkhUZsaZ6hwPEi8PuVkhge6R(0PqB9nyuZJK3hyhj9Y(uoBEfMtUMdYOPWr5HBjZbbzyL0tWZtdnXWbbnwuoCNLag)WGqFdoBRmCqqJfLd3zjGXpmi03atkrd2mN43WI18i59b2rsVSpLdKmyrsz49b4PHMGjWDWiPXc0M0b0T3hWkBxNcPJs6HsaCjvZJK3hyhj9Y(uoqYGfjLH3hWKKuawINgAstmCqqdizWIKYW7dmWKs0GnZmQ5rY7dSJKEzFkhycqVO80qt8gZbiOdZIgkboR5GmokzuI1jSj2n2TbdA24ABBsBnDkmNX(AGVdnb1P2ZCIFWbhMdqqhMfn0u4OY8Mfn0N6DqZgxBBtARPtH5m2xd8nt45LvgoiOXMxH5KR5GmAkC0bNTvgoiOXIg6tTrhGen4STQeRtytSBSBdmysjAWoblRmCqqdnfoQmVzrd9PEh6tnOMhjVpWos6L9PCsHuAIK3hWi715bek0eTlbs0YtdnX21Pq6OKEesPvycChmsASaTjDaD79bGdoAxcKObdMch1CqghLm68nG1qjSmoSvVvi(MYOMBP6zJ3jRh6W1RYHbH(Q3gtZiYnZ6v3oA9iOZSEmf681RgLa1doVEmha0aw1Jm7JAEK8(a7iPx2NYX(oPbt7XHtepqh2aiy3NGNNgAYdjb8XIYH7SeW4hge6BqGGrsARS1djb8XIg6tTb6sC7GabJK01Clv)mCP6v5WGqF1BJP6rUzwVAucuVAQE0agQEhLQNaeMv(6vJsokHRhcFk1BFNSbSQxD7OhNxpYSx)HR3YGB96zrachsz(rnpsEFGDK0l7t5SOC4olbm(HbH(4PHMiaHzLNVjydwwHjWDWiPXc0M0b0T3hWA6oP(udgBEfMtUMdYOPWrhC2wt3j1NAWyrd9P2OdqIgj0aZIw(MGVMhjVpWos6L9PCwcJdN0gMdqM1UZs8KYNKKXdmlY3j45PHMGjWDWiPXc0M0b0T3hWkB1NpwcJdN0gMdqM1UZsg95dVtzBalREGzr(WBfY4Nr3eFtzapCWb1SqDdMuIgSzozrRRnjLgpWSiFhlkhUZsaZ6hwjt(vZJK3hyhj9Y(uolzV9YtdnbtG7GrsJfOnPdOBVpG10PWCg7Rb(o0euNANVj4R5wQ(z4s1JKxH5KB9hO(0Ds9PgupVdiNW1d141RhbmtEvphqs7wVAQ(at1Z6AaR69RE7ZUEvomi0x9bqxV(QhCE9Obmu9iOH(ux)SFjUDuZJK3hyhj9Y(uoBEfMtUMdYOPWr5PHMGjWDWiPXc0M0b0T3hWkBt3j1NAWyrd9P2WidnTdoBR82djb8bbGHKNDdyzw0qFQ3bbcgjPHdU0Ds9Pgmw0qFQn6aKOrcnWSOLVj45LvEZwpKeWhlkhUZsaJFyqOVbbcgjPHdopKeWhlAOp1gOlXTdcemssdhCP7K6tnySOC4olbm(HbH(gysjAWYxg8YkVzlTlbs0GrEN2CqghLmeGuYpuclJddhCP7K6tnyWiVtBoiJJsgcqk5hysjAWYxg8QMBP6zZHQp06T(at1ZzZt9lOTP6DuQ(dq1RUD06LNAA96vrLzoQFgUu9Qrjq968nGv9qX6eUEhna1B5SX61euNAV(dxp486xNcPJs66v3o6X51hG81B5SXrnpsEFGDK0l7t5Oe4SK2aDyJMchLNu(KKmEGzr(obppn0eoATHGHa(i06DWzBL3EGzr(WBfY4Nr3uMPtH5m2xd8DOjOo1oCWX21Pq6OKEesP10PWCg7Rb(o0euNANVPKTrjGDZAtanVQ5wQE2CO6bx9HwV1RULY61nvV62rBq9okvpGGDVE(bRLN65wQEliOzw)bQN52TE1TJECE9biF9woBCuZJK3hyhj9Y(uokbolPnqh2OPWr5PHMWrRnemeWhHwVJgWh)G1mIJwBiyiGpcTEhAoC49bSMofMZyFnW3HMG6u78nLSnkbSBwBcOR5rY7dSJKEzFkNfn0NAdJm00YtdnbtG7GrsJfOnPdOBVpG10PWCg7Rb(o0euNANVPmQ5rY7dSJKEzFkhkHEnGLbt24wjaAEAOjycChmsASaTjDaD79bSMofMZyFnW3HMG6u78nXpR8gMa3bJKgClzSX9HBpVbFE49bGdU1MKsJhywKVJfLd3zjGz9dRK5e)5vn3s1pdAhTEKzNN6BO6bNxFiXuOZxV(aep1ZTu9QCyqOV6v3oA9i3mRNZEuZJK3hyhj9Y(uolkhUZsaJFyqOpEAOjpKeWhlAOp1gOlXTdcemssBfMa3bJKglqBshq3EFaRmCqqJnVcZjxZbz0u4Odo7AEK8(a7iPx2NYzrd9P2OdqI4PHMyldhe0yrd9P2OdqIgC2wHAwOUbtkrd2mNMf29qsaFSCmoHH4yrdcemssxZR5wQEvpWmU2uQ(15GGQxD7O1lp1eUEBCF18i59b2rsVSpLJ959bQ5rY7dSJKEzFkhg5DAdehoppn0edhe0yZRWCY1Cqgnfo6GZUMhjVpWos6L9PCyi8s4SnGfpn0edhe0yZRWCY1Cqgnfo6GZUMhjVpWos6L9PCGAmXiVtZtdnXWbbn28kmNCnhKrtHJo4SR5rY7dSJKEzFkNaKO1XH0KcPKNgAIHdcAS5vyo5AoiJMchDWzxZR5rY7dSJKEzFkhULmTtk8qqquYnGqHMs5tYZXhOtggzSopn0eBxNcPJs6riLwHjWDWiPXc0M0b0T3hWkBz4GGgBEfMtUMdYOPWrhC2wjaHzLFOjOo1oFt8dw18i59b2rsVSpLd3sM2jfEaHcnfw4Ig4ynqhWnhKX(utyEAOj2YWbbnw0qFQn6aKObNT10Ds9Pgm28kmNCnhKrtHJoWKs0Gnt4Hvn3s1FokHv3lvV62rRh5Mz9HxFgwK96xpsz36pC9WBr2RxD7O1hY9Qpx5D665Sh18i59b2rsVSpLd3sM2jfEaHcnflkmbGwdoSWdBshoK80qtAIHdcAGdl8WM0HdPrtmCqqd9PgahCAIHdcAKoGMl5nmKPbznAIHdcAWzB1dmlYhOuiD0HDYZKFzy1dmlYhOuiD0HDY5BIFWco4yRMy4GGgPdO5sEddzAqwJMy4GGgC2w5TMy4GGg4WcpSjD4qA0edhe0y9iLLVPmS4mcpSydAIHdcAWiVtBoiJJsgcqk5hC2WbhuZc1nysjAWMj)HfVSYWbbn28kmNCnhKrtHJoWKs0GLVzPMBP6TSjC(6Xhhluz(6XCsQ(dQEhLtHPHAsxVs4OB9mK8uBbx)mCP6HoC9S5GS2NU(eU9AEK8(a7iPx2NYHBjt7KcpGqHMuYRJ14HSxLauZTu9ZKGcoPxpuiLmrkB9qhUEUnyKu9TtkRfC9ZWLQxD7O1JKxH5KB9hu9ZKchDuZJK3hyhj9Y(uoClzANuwEAOjgoiOXMxH5KR5GmAkC0bNnCWb1SqDdMuIgSzMbSQ51ClvVfGfs42P6TaBxcKOTMhjVpWoODjqIw2NYjDGebCC4K2ajdfINgAIaeMv(H3kKXpJsa78bVv2YWbbn28kmNCnhKrtHJo4STYB2QpFKoqIaooCsBGKHczy4WGH3PSnGLv2gjVpWiDGebCC4K2ajdfA0adKSzH6WbheNuAWucnWSiJ3kuMSs6Hsa78QMhjVpWoODjqIw2NYHrEN2CqghLmeGuYZtdnX20Ds9Pgmw0qFQnmYqt7GZ2A6oP(udgBEfMtUMdYOPWrhC2WbhuZc1nysjAWM5e8WQMhjVpWoODjqIw2NYHfxG1DamhKjSqcFoAnpsEFGDq7sGeTSpLd0L4wsBclKWTtggku4PHM49AtsPXdmlY3XIYH7SeWS(Hv4Bkd4GdhT2qWqaFeA9oAaFWgS4Lv2MUtQp1GXMxH5KR5GmAkC0bNTv2YWbbn28kmNCnhKrtHJo4STsacZk)qtqDQD(M4hSQ5rY7dSdAxcKOL9PCS5Wnu(gWYWiJ15PHMwBsknEGzr(owuoCNLaM1pScFtzahC4O1gcgc4JqR3rd4d2GvnpsEFGDq7sGeTSpLJJsgoaZXb0gOdNiEAOjgoiObMszL0UgOdNObNnCWXWbbnWukRK21aD4ezshhWj8y9iLnt4HvnpsEFGDq7sGeTSpLdUTTLKPbM1osunpsEFGDq7sGeTSpLJ6dl1WqnWGP9abir80qtP7K6tnyS5vyo5AoiJMchDGjLObBMweo4GAwOUbtkrd2mHFwQ5rY7dSdAxcKOL9PCuiLdN3CqgjxQ1gnMcLLNgAIaeMv(m5pSSYWbbn28kmNCnhKrtHJo4SR5wQElRNuxpBIc7gWQ(zxgk0wp0HRNGDkX5u94aWIQ)W1NTLY6z4GGwEQVHQ3(2TzK0OElaP6i)wVJZxVF1ZI86DuQE5PMwV(0Ds9PguptSKU(duFat0YGrs1tasPPDuZJK3hyh0Ueirl7t5GPWUbSmqYqHwEAOjOMfQBWKs0Gnt4hweo44nV9aZI8bkfshDyNC(MfybhCEGzr(aLcPJoStEMtzalEzL3rYByidbiLM2j4HdoOMfQBWKs0GLVmSm5fVGdoE7bMf5dVviJFg7KBYaw8XpyzL3rYByidbiLM2j4HdoOMfQBWKs0GLp(ZFEXRAEn3s1J4uiD06T87K6tnyR5rY7dSJ1Pq6OMKEzFkhycChmsIhqOqtlQ24OyArpPMhycjhnLUtQp1GXIg6tTrhGensObMfTgiCK8(aHKVj4hZQf5XYkjTjC9w2bUdgjvZTu9w2bOx06BO6vt1hyQ(uyB3aw1FG6Nzasu9j0aZI2r9wGfyz(6ziOdt1d141RxhGevFdvVAQE0agQEWvVQnluF9qMLW1ZW51pZaNTEe0qFQRVb1FynHR3V6zrE9SjoBNdt1ZzxpVbx9wqX6eUElGDJDBaVg18i59b2X6uiDutsVSpLdmbOxuEAOjEZwycChmsASOAJJIPf9KA4GJTEijGpanluF9qMLWdcemssB1djb8HoWznlAOp1dcemssZlRPtH5m2xd8DOjOo1oFWBLTyoabDyw0qjWznhKXrjJsSoHnXUXUnyqZgxBBt6AEK8(a7yDkKoQjPx2NYX(oPbt7XHtepqh2aiy3NGNhc2DCycLJd4t8hw8WgVtwp0HRhbn0NAfsQRN96rqd9PEDCNLQNdiPDRxnvFGP6dMJZR3V6tHD9hO(zgGevFcnWSODupBMaz(6vJsG6N9gORFgqrwaTB99wFWCCE9(vpMdu)X5JAEK8(a7yDkKoQjPx2NYzrd9PwHKAEAOjcqyw55BI)WYkbimR8dnb1P25BcEyzLTWe4oyK0yr1ghftl6j1wtNcZzSVg47qtqDQD(G3QMy4GGgqnqButrwaT7atkrd2mHVMhjVpWowNcPJAs6L9PCGjWDWijEaHcnTOAt6uyoJ91aF5bMqYrtPtH5m2xd8DOjOo1oFt8NhlNnwpMMnUgtkeWTGRFMbir1hE9YtD9woBSEM81RjOGt6JAULQ3YzJ1JPzJRXKcbCl46Nzasu9hqMVEgc6Wu9qnOxucV13q1RMQhnGHQ3g3hU981Jpp8(a1hE98N969aZI8DuZJK3hyhRtH0rnj9Y(uoWe4oyKepGqHMwuTjDkmNX(AGV8ati5OP0PWCg7Rb(o0euNApZj45PHMGjWDWiPb3sgBCF42ZBWNhEFaRRnjLgpWSiFhlkhUZsaZ6hwHVj(xZTu9ZmajQEnhUbSQhjVcZj36pC9bZbdvVJIPf9K6rnpsEFGDSofsh1K0l7t5SOH(uB0bir80qtWe4oyK0yr1M0PWCg7Rb(AL3We4oyK0yr1ghftl6j1Wbhdhe0yZRWCY1Cqgnfo6atkrdw(MGFKbCWT2KuA8aZI8DSOC4olbmRFyf(M4V10Ds9Pgm28kmNCnhKrtHJoWKs0GLp4HfVQ5wQ(C5WG6XKs0GgWQ(zgGeT1ZqqhMQ3rP6HAwOE9eqV13q1JCZSE1hGnRxpdvpMcD(6Bq9ERqJAEK8(a7yDkKoQjPx2NYzrd9P2OdqI4PHMGjWDWiPXIQnPtH5m2xd81kuZc1nysjAWMz6oP(udgBEfMtUMdYOPWrhysjAWwZR5wQEeNcPJs66ztNhEFGAULQNnhQEeNcPJMdmbOx06dmvpNnp1ZTu9iOH(uVoUZs17x9meGGAVEi8PuVJs1Bh72Wq1ZCaUT(aORF2BGU(zafzb0U1tWqG6BO6vt1hyQ(WRxjG96TC2y98gcFk17Ou92ykDkmHxVfe0m51OMhjVpWowNcPJsA2NYzrd9PEDCNL4PHM4ndhe0yDkKo6GZgo4y4GGgWeGErhC28QMBP6N9g0lA9Hxp)yVElNnwV62rpoV(zIuFo1ZF2RxD7O1ptK6v3oA9iOC4olbQxLddc9vpdheu9C217x9bmxRRFpfQElNnwV6yDQ(TDUW7dSJAEK8(a7yDkKokPzFkNuiLMi59bmYEDEaHcnb1GEr5PHMy4GGglkhUZsaJFyqOVbNT10PWCg7Rb(o0euNApZPmQ5wQEla5E1VbevVF1d1GErRp865p71B5SX6v3oA9eShjxMVE(xVhywKVJ65nsOq1hB9hNVTMQFDkKo6Gx18i59b2X6uiDusZ(uoPqknrY7dyK968acfAcQb9IYtdnT2KuA8aZI8DSOC4olbmRFyLj(BnDkmNX(AGV8nX)AULQF2BqVO1hE98N96TC2y9QBh9486Njcp1Br2RxD7O1pteEQpa66HT6v3oA9ZeP(aYjC9w2bOx0AEK8(a7yDkKokPzFkNuiLMi59bmYEDEaHcnb1GEr5PHMsNcZzSVg47qtqDQ9mNGFg5Thsc4dnr2e2Soo8GfPmiqWijTvgoiObmbOx0bNnVQ5rY7dSJ1Pq6OKM9PCw0ggEAOjpKeWhGMfQVEiZs4bbcgjPTI5ae0HzrdVb5n(b7DYWidnnOzJRTTjT11MKsJhywKVJfLd3zjGz9dRKPfR5wQ(z)W1BJPz0o8ekp1NLi76N9gORFgqrwaTB9C21FG6DuQEBCRe4817bMf51R5O69REWvpcAOp11BzhCsVMhjVpWowNcPJsA2NYzrd9PEDCNL4PHMKemKmtlMHvnXWbbnGAG2OMISaA3bMuIgSzcVvpWSiF4Tcz8ZOBAgXKs0GLpyRMBP6NH217x98REpWSiFRplr21Zzx)S3aD9ZakYcODRNjF9P8jzdyvpcAOp1RJ7S0OMhjVpWowNcPJsA2NYzrd9PEDCNL4jLpjjJhywKVtWZtdnPjgoiObud0g1uKfq7oWKs0Gnt4TU2KuA8aZI8DSOC4olbmRFyLmN4NvpWSiF4Tcz8ZOBAgXKs0GLpyRMBP6NbTJECE9ZKiBcxpIJdpyrk1haD98RE2uaYU1Fq1NRm0u9nOEhLQhbn0N6T(2RV36vFyhTEUTbSQhbn0N61XDwQ(dup)Q3dmlY3rnpsEFGDSofshL0SpLZIg6t964olXtdnXwpKeWhAISjSzDC4blszqGGrsARHfs42PbJm0KPbghLmlAOp17ahGSt8Z6AtsPXdmlY3XIYH7SeWS(HvM4xn3s1p7hUEBCF42Zxp(8W7dWt9ClvpcAOp1RJ7Su9hmeUEe)Wk1dpVQxD7O1pdSGQpyfny965SR3V65F9EGzr(Yt9zWR6BO6N9zq99wpMdaAaR6piO659bQpa5RpuooGx)bvVhywKV8IN6pC98Jx17x9kbS3kTfs1JCZSEc2DcS9bQxD7O1ZMdiyApyAz75R)a1ZV69aZI8TEEZ)6v3oA952ocVg18i59b2X6uiDusZ(uolAOp1RJ7Sepn0embUdgjn4wYyJ7d3EEd(8W7dyL3AIHdcAa1aTrnfzb0UdmPenyZeE4GZdjb8HAkSpGsSoHheiyKK26AtsPXdmlY3XIYH7SeWS(HvYCI)WbxyHeUDA0acM2dMw2E(bbcgjPTYWbbn28kmNCnhKrtHJo4STU2KuA8aZI8DSOC4olbmRFyLmN4h7Hfs42PbJm0KPbghLmlAOp17GabJK08QMhjVpWowNcPJsA2NYzr5WDwcyw)Wk80qtRnjLgpWSiF5BIFSZBgoiOHnMuiD7H3hyWzdhCmCqqdhLm4ZDcm4SHdomhGGomlAezJa3RzpoPbchSuiGpOzJRTTjT10b0CTp0eztyJoyXIW7ahGS8nnR8QMhjVpWowNcPJsA2NYzrd9PEDCNL4PHM0edhe0aQbAJAkYcODhysjAWM5e8Wbx6oP(udgBEfMtUMdYOPWrhysjAWMj8ZIvnXWbbnGAG2OMISaA3bMuIgSzMUtQp1GXMxH5KR5GmAkC0bMuIgS1ClvpcAOp1RJ7Su9(vpMGW0Iw)S3aD9ZakYcODRpa669REcSCyQE1u9PauFkW481FWq46J6H4KY6N9zq9nWV6DuQEab7E9i3mRVHQ3(2TzK0OMhjVpWowNcPJsA2NYX(oPbt7XHtepqh2aiy3NGVMhjVpWowNcPJsA2NYHL8ofgzOjEAOjgoiOHnHHoC4K2ad1GDSEKYY3KfTMoGMR9HnHHoC4K2ad1GDGdqw(MGNF18i59b2X6uiDusZ(uolAOp1RJ7SunVMBP6N9g0lkH3AEK8(a7aQb9IY(uoRStKjaAJUtepn00AtsPXdmlY3XIYH7SeWS(HvYe2SYwgoiOXIg6tTrhGen4STYWbbnwzNita0gDNObMuIgSzc1SqDdMuIgSwz4GGgRStKjaAJUt0atkrd2m5n8SNofMZyFnWxEXgGFml18i59b2bud6fL9PCGjWDWijEaHcnTzBBdMZ25WepWesoAsjwNWMy3y3gyWKs0GLpybhCS1djb8bOzH6RhYSeEqGGrsAREijGp0boRzrd9PEqGGrsARmCqqJfn0NAJoajAWzdhCRnjLgpWSiFhlkhUZsaZ6hwHVjyJhlRK0MW1Bzh4oyKu9qhUE2eNTZHPr9izB761C4gWQElOyDcxVfWUXUnO(dxVMd3aw1pZaKO6v3oA9ZmWzRpa66bx9Q2Sq91dzwcpQ5wQE2msKD9C21ZM4SDomvFdvF713B9bZX517x9yoq9hNpQ5rY7dSdOg0lk7t5G5SDomXtdnXwycChmsASzBBdMZ25WKvpWSiF4Tcz8ZOBAgXKs0GLpyZkMGW0IgmsQMhjVpWoGAqVOSpLZsjm5gNsOGE24OAULQ3cIt6T(CVbSQ3dmlY36D0WRxDlL1lByO6HoC9okvVMdhEFG6pO6ztC2ohMQhtqyArRxZHBaR6TdGMu60OMhjVpWoGAqVOSpLdMZ25WepP8jjz8aZI8DcEEAOj2ctG7GrsJnBBBWC2ohMSYwycChmsAWTKXg3hU98g85H3hW6AtsPXdmlY3XIYH7SeWS(Hv4BkdREGzr(WBfY4Nr3eFt82ISZ7mydPtH5m2xd8Lx8YkMGW0IgmsQMBP6zteeMw06ztC2ohMQNcSmF9nu9TxV6wkRNGD7gt1R5WnGv9i5vyo5oQFMx9oA41JjimTO13q1JCZSEwKV1JPqNV(guVJs1diy3R3I7OMhjVpWoGAqVOSpLdMZ25Wepn0eBHjWDWiPXMTTnyoBNdtwXKs0GnZ0Ds9Pgm28kmNCnhKrtHJoWKs0GLD4HL10Ds9Pgm28kmNCnhKrtHJoWKs0GnZjlA1dmlYhERqg)m6MMrmPeny5lDNuFQbJnVcZjxZbz0u4OdmPenyz3I18i59b2bud6fL9PCyKrkRX(uRjmpn0eBHjWDWiPb3sgBCF42ZBWNhEFaRRnjLgpWSiF5BIF18i59b2bud6fL9PCiy6nr4WPAEn3s1Nlxl1eER5rY7dSdgUwQNw0ggEAOj26HKa(a0Sq91dzwcpiqWijTvmhGGomlA4niVXpyVtggzOPbnBCTTnPTU2KuA8aZI8DSOC4olbmRFyLmTynpsEFGDWW1sn7t5SOC4olbmRFyfEAOP1MKsJhywKV8nLb782djb8bl5DkmYqtdcemssBnSqc3onSjm0HdNg4aKLVPmSAFB79bmmrklVQ5rY7dSdgUwQzFkNLW4WjTH5aKzT7Sepn0u6oP(udglHXHtAdZbiZA3zPrcnWSO1aHJK3hiK8nLXywTiCWThNKPb6HKcTHjVHG9qXwsdcemssBLTmCqqdjfAdtEdb7HITKgC218i59b2bdxl1SpLdl5DkmYqt18i59b2bdxl1SpLdtKYUEWiCHlea]] )


end
