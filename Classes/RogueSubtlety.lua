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
                return buff.stealth.up or buff.vanish.up or buff.shadow_dance.up or buff.subterfuge.up
            elseif k == "rogue_remains" then
                return max( buff.stealth.remains, buff.vanish.remains, buff.shadow_dance.remains, buff.subterfuge.remains )

            elseif k == "mantle" then
                return buff.stealth.up or buff.vanish.up
            elseif k == "mantle_remains" then
                return max( buff.stealth.remains, buff.vanish.remains )
            
            elseif k == "all" then
                return buff.stealth.up or buff.vanish.up or buff.shadow_dance.up or buff.subterfuge.up or buff.shadowmeld.up
            elseif k == "remains" or k == "all_remains" then
                return max( buff.stealth.remains, buff.vanish.remains, buff.shadow_dance.remains, buff.subterfuge.remains, buff.shadowmeld.remains )
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
                gain( ( buff.shadow_blades.up and 2 or 1 ) + ( buff.the_rotten.up and 3 or 0 ), "combo_points" )
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
            texture = 136181,

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
                gain( ( buff.shadow_blades.up and 2 or 1 ) + ( buff.the_rotten.up and 3 or 0 ), "combo_points" )
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

            usable = function () return stealthed.all, "requires stealth" end,
            handler = function ()
                removeBuff( "cold_blood" )

                gain( ( buff.shadow_blades.up and 3 or 2 ) + ( buff.the_rotten.up and 3 or 0 ), "combo_points" )
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
                if legendary.tiny_toxic_blades.enabled then return 0 end
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
                        if cd.remains > 0 then reduceCooldown( name, 15 ) end
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


    spec:RegisterPack( "Subtlety", 20201106, [[daLe1bqiuQ6rkG2eL4tkkLmkukDkukwfkr1RqvmluLULIcTlr9lfIHHs4yOKwgLupdvvnnkjUgLK2gkr(gQQOXPOKoNIsX6qvfAEkq3tr2hQk)trPu6GOurwOcPhQa0evu0fvaq2ikr5JkakJubq1jrPIALGIxQaGAMkaWnvaKDsu8tfLs1qvuQwkkv4PqAQeLUQIcAROQc(QIcCwfLsXEj8xkgSQoSWIrXJfzYK6YiBgKpdQgneNwQvRaqVwbnBsUnr2nWVvz4uQJROelhQNR00P66OY2vu9DIQXJsLoVc16rvLMpO0(LSGvHScuD4KqgRzH1SGvwzblLT2ARYQvTwG6JTjbQDKggWjbkiKibkkhJRiFSa1ogRUqlKvGUhhorcue3Tx(XrgbE7iCm50jnY2sCQW7dKWbKpY2sPreOmCTYzNbcgbQoCsiJ1SWAwWkRSGLYwBTvz1kZgbAW5ihwGI2sdOafP1AciyeOAAtc0bwpkhJRiFC9SJdohvWmW6L5MtsmeUEwI36TMfwZcbQQxFfYkqxNcLJqAHSczyviRaLabJI0IrfOjC7eUdbkBRNHdckVofkhjZzxpSWwpdheuEEa6fjZzxpBeOrY7diqxKqFYxh3djHlKXAHScucemkslgvGMWTt4oeOmCqq5fHd3djGXpmi0xMZUEl1NojMZyFnW3SMG6u71p4u9wlqJK3hqGMcLYejVpGr1Rlqv96gqircuOg0lIWfYWFHScucemkslgvGMWTt4oeORnPugpWWjFZlchUhsaZ6hwQ(P6Ts9wQpDsmNX(AGV1Z3u9wrGgjVpGanfkLjsEFaJQxxGQ61nGqIeOqnOxeHlKXkczfOeiyuKwmQanHBNWDiqtNeZzSVg4BwtqDQ96hCQEwRFgRNT17HIaEwtKnHnRJdpGtszcemksxVL6z4GGYZdqVizo76zJansEFabAkuktK8(agvVUav1RBaHejqHAqVicxiJvfYkqjqWOiTyubAc3oH7qG6HIaEg0Wr81d1qcNjqWOiD9wQhZbiOddNYEdgB8JD7KHrfAktZcxBBtAbAK8(ac0fPNlCHmSKqwbkbcgfPfJkqt42jChcufnNu1py9w166TuVMy4GGYqnqBKtXqaTBgtsrd26hSEwR3s9EGHtE2BjY4Nr3u9Zy9yskAWwpF1Zsc0i59beOlsOp5RJ7HKWfYWpfYkqjqWOiTyubAK8(ac0fj0N81X9qsGMWTt4oeOAIHdckd1aTrofdb0UzmjfnyRFW6zTEl1V2Ksz8adN8nViC4EibmRFyP6hCQE(xVL69adN8S3sKXpJUP6NX6XKu0GTE(QNLeOPXjfz8adN8vidRcxiZSkKvGsGGrrAXOc0eUDc3HaL917HIaEwtKnHnRJdpGtszcemksxVL6d(LWTtzgvOjtdmoczwKqFY3moadRFQE(xVL6xBsPmEGHt(MxeoCpKaM1pSu9t1ZFbAK8(ac0fj0N81X9qs4czMnczfOeiyuKwmQanHBNWDiqNh4oyuuMBjJnUpC7Jn4ZdVpq9wQNT1RjgoiOmud0g5umeq7MXKu0GT(bRN16Hf269qraplNc7difRt4mbcgfPR3s9RnPugpWWjFZlchUhsaZ6hwQ(bNQ3k1dlS1h8lHBNYnGM3EW0Q2hNjqWOiD9wQNHdckVJLyo1AoiJMchjZzxVL6xBsPmEGHt(MxeoCpKaM1pSu9dovp)RNN6d(LWTtzgvOjtdmoczwKqFY3mbcgfPRNnc0i59beOlsOp5RJ7HKWfYWkleYkqjqWOiTyubAc3oH7qGU2Ksz8adN8TE(MQN)1Zt9STEgoiOSnMKiD7H3hiZzxpSWwpdheu2rid(CNazo76Hf26XCac6WWPCmmcCVM94ugiCaxIaEMMfU22M01BP(0b0CTN1eztyJoGdNWBghGH1Z3u98Z6zJansEFab6IWH7HeWS(HLeUqgwzviRaLabJI0IrfOjC7eUdbQMy4GGYqnqBKtXqaTBgtsrd26hCQEwRhwyRpDNsFYb5DSeZPwZbz0u4izmjfnyRFW6zDwR3s9AIHdckd1aTrofdb0UzmjfnyRFW6t3P0NCqEhlXCQ1CqgnfosgtsrdwbAK8(ac0fj0N81X9qs4czy1AHScucemkslgvGcDydGyxxidRc0i59beO23PmyApoCIeUqgw5VqwbkbcgfPfJkqt42jChcugoiOSnHHoC4K2mNAWMxpsdRNVP6TA9wQpDanx7zBcdD4WjTzo1GnJdWW65BQEw5VansEFabkC1DsmQqtcxidRwriRansEFab6Ie6t(64EijqjqWOiTyuHlCbkTlbs0kKvidRczfOeiyuKwmQanHBNWDiqjaHHpo7Tez8ZifSB98vpR1BPE2xpdheuEhlXCQ1CqgnfosMZUEl1Z26zF96ZZPdKiGJdN0givirggomi7DAydGxVL6zF9rY7dKthirahhoPnqQqIYnWaPA4iE9WcB9qCkLbtjKadNmElr1py9Wt6SuWU1ZgbAK8(ac00bseWXHtAdKkKiHlKXAHScucemkslgvGMWTt4oeOSV(0Dk9jhKxKqFYnmQqtBMZUEl1NUtPp5G8owI5uR5GmAkCKmND9WcB9qnCe3GjPObB9dovpRSqGgjVpGaLrDN2CqghHmeGKglCHm8xiRansEFabkCUaR7ayoitWVe(CebkbcgfPfJkCHmwriRaLabJI0IrfOjC7eUdbkBRFTjLY4bgo5BEr4W9qcyw)Ws1Z3u9wxpSWwpoATHMtaphA9MBq98vplXI6zt9wQN91NUtPp5G8owI5uR5GmAkCKmND9wQN91ZWbbL3XsmNAnhKrtHJK5SR3s9eGWWhN1euNAVE(MQN)SqGgjVpGaf6sClPnb)s42jddfscxiJvfYkqjqWOiTyubAc3oH7qGU2Ksz8adN8nViC4EibmRFyP65BQERRhwyRhhT2qZjGNdTEZnOE(QNLyHansEFabQnhUHg3a4ggvSUWfYWsczfOeiyuKwmQanHBNWDiqz4GGYyknur7AGoCIYC21dlS1ZWbbLXuAOI21aD4ezshhWjCE9inS(bRNvwiqJK3hqG6iKHdWCCaTb6Wjs4cz4NczfOrY7diqXTTTImnWS2rIeOeiyuKwmQWfYmRczfOeiyuKwmQanHBNWDiqt3P0NCqEhlXCQ1Cqgnfosgtsrd26hSERwpSWwpudhXnyskAWw)G1Z6SkqJK3hqGk)Wk9CQbgmThiajs4czMnczfOeiyuKwmQanHBNWDiqjaHHpU(bR3kSOEl1ZWbbL3XsmNAnhKrtHJK5SfOrY7diqLiPdp2CqgfxQ1gnMcPv4czyLfczfOeiyuKwmQanHBNWDiqHA4iUbtsrd26hSEwZwTEyHTE2wpBR3dmCYZiuOCKSDYRNV6NvwupSWwVhy4KNrOq5iz7Kx)Gt1BnlQNn1BPE2wFK8Eoziaj10w)u9SwpSWwpudhXnyskAWwpF1B9SPE2upBQhwyRNT17bgo5zVLiJFg7KBSMf1Zx98Nf1BPE2wFK8Eoziaj10w)u9SwpSWwpudhXnyskAWwpF1BfRupBQNnc0i59beOykSBaCdKkKOv4cxGQjOGt5czfYWQqwbAK8(ac0HDAOaLabJI0IrfUqgRfYkqjqWOiTyub6zlqxYfOrY7diqNh4oyuKaDEO4ibkdheuEvDImbqB0DIYC21dlS1V2Ksz8adN8nViC4EibmRFyP65BQEwsGopWgqirc0fOnPdOBVpGWfYWFHScucemkslgvGgjVpGanfkLjsEFaJQxxGQ61nGqIeOj9kCHmwriRaLabJI0IrfOjC7eUdb66uOCesNdLsGgjVpGafZbmrY7dyu96cuvVUbesKaDDkuocPfUqgRkKvGsGGrrAXOc0eUDc3HaDTjLY4bgo5BEr4W9qcyw)Ws1py9Su9wQhQHJ4gmjfnyRNV6zP6TupdheuEvDImbqB0DIYyskAWw)G1dpPZsb7wVL6tNeZzSVg4B98nvVvQFgRNT17Tev)G1ZklQNn1ZYR3AbAK8(ac0v1jYeaTr3js4czyjHScucemkslgvGE2c0LCbAK8(ac05bUdgfjqNhkosGAJ7d3(yd(8W7duVL6xBsPmEGHt(MxeoCpKaM1pSu98nvV1c05b2acjsGYTKXg3hU9Xg85H3hq4cz4NczfOeiyuKwmQanHBNWDiqNh4oyuuMBjJnUpC7Jn4ZdVpGansEFabAkuktK8(agvVUav1RBaHejqxNcLJys6v4czMvHScucemkslgvGE2c0LCbAK8(ac05bUdgfjqNhkosGATvRNN69qrappVHF4mbcgfPRNLxV1SOEEQ3dfb8SuSoHnhKzrc9jFZeiyuKUEwE9wZI65PEpueWZlsOp5gOlXTzcemksxplVERTA98uVhkc45qfjC7JZeiyuKUEwE9wZI65PERTA9S86zB9RnPugpWWjFZlchUhsaZ6hwQE(MQ3k1Zgb68aBaHejqxNcLJyCemTiNslCHmZgHScucemkslgvGMWTt4oeOeGWWhN1euNAV(bNQFEG7Grr51Pq5ighbtlYP0c0i59beOPqPmrY7dyu96cuvVUbesKaDDkuoIjPxHlKHvwiKvGsGGrrAXOc0eUDc3Han4xc3oLbnCeFnZjaCkajktGGrr66Tup7RNHdckdA4i(AMta4uasuMZUEl1NojMZyFnW3SMG6u71Zx9SwVL6zB9RnPugpWWjFZlchUhsaZ6hwQ(bR366Hf26Nh4oyuuMBjJnUpC7Jn4ZdVpq9SPEl1Z26t3P0NCqEhlXCQ1Cqgnfosgtsrd26hCQE(xpSWwpBRp4xc3oLbnCeFnZjaCkajkJdWW65BQERR3s9mCqq5DSeZPwZbz0u4izmjfnyRNV65F9wQN91VofkhH05qPQ3s9P7u6toiViH(KB0bir5esGHtRbchjVpqOQNVP6zrE2upBQNnc0i59beOyoBNdtcxidRSkKvGsGGrrAXOc0eUDc3HafZbiOddNYAkCe1yZIe6t(MPzHRTTjD9wQxFEEj7T3S3PHnaE9wQxFEEj7T3mMKIgS1p4u9wxVL6tNeZzSVg4B98nvV1c0i59beOPqPmrY7dyu96cuvVUbesKafQb9IiCHmSATqwbkbcgfPfJkqt42jChc00jXCg7Rb(w)u9bOLIesGHtAtYwGgjVpGanfkLjsEFaJQxxGQ61nGqIeOqnOxeHlKHv(lKvGsGGrrAXOc0eUDc3HanDsmNX(AGVznb1P2RFWP6zTEyHTEOgoIBWKu0GT(bNQN16TuF6KyoJ91aFRNVP65VansEFabAkuktK8(agvVUav1RBaHejqHAqVicxidRwriRaLabJI0IrfOjC7eUdb6AtkLXdmCY38IWH7HeWS(HLQFQERuVL6tNeZzSVg4B98nvVveOrY7diqtHszIK3hWO61fOQEDdiKibkud6fr4czy1QczfOeiyuKwmQanHBNWDiqjaHHpoRjOo1E9dov)8a3bJIYRtHYrmocMwKtPfOrY7diqtHszIK3hWO61fOQEDdiKibkdxR0cxidRSKqwbkbcgfPfJkqt42jChcucqy4JZAcQtTxpFt1ZQvRNN6jaHHpoJj4eqGgjVpGanWPaqg)Wyc4cxidR8tHSc0i59beObofaYyZPwsGsGGrrAXOcxidRZQqwbAK8(acuvdhXxZaiNgUebCbkbcgfPfJkCHmSoBeYkqJK3hqGYeWnhKXXDA4kqjqWOiTyuHlCbQnMsNet4czfYWQqwbAK8(ac0W2wn2yF9EabkbcgfPfJkCHmwlKvGgjVpGaDDkuoIaLabJI0IrfUqg(lKvGsGGrrAXOc0i59beOsbEiPnqh2OPWreO2ykDsmHBwkDa9kqz1QcxiJveYkqjqWOiTyubAK8(ac0v1jYeaTr3jsGMWTt4oeOycctlsWOibQnMsNet4MLshqVcuwfUqgRkKvGsGGrrAXOc0eUDc3HafZbiOddNYsbEO5GmoczKI1jSj2n2TbzAw4ABBslqJK3hqGUiH(KByuHMwHlKHLeYkqjqWOiTyubkiKibAWVlsGJ1aDa3Cqg7toHfOrY7diqd(DrcCSgOd4MdYyFYjSWfUafQb9IiKvidRczfOeiyuKwmQanHBNWDiqxBsPmEGHt(MxeoCpKaM1pSu9dwplvVL6zF9mCqq5fj0NCJoajkZzxVL6z4GGYRQtKjaAJUtugtsrd26hSEOgoIBWKu0GTEl1ZWbbLxvNita0gDNOmMKIgS1py9STEwRNN6tNeZzSVg4B9SPEwE9SMNvbAK8(ac0v1jYeaTr3js4czSwiRaLabJI0IrfONTaDjxGgjVpGaDEG7Grrc05HIJeOsX6e2e7g72adMKIgS1Zx9SOEyHTE2xVhkc4zqdhXxpudjCMabJI01BPEpueWZ6ap0SiH(KNjqWOiD9wQNHdckViH(KB0birzo76Hf26xBsPmEGHt(MxeoCpKaM1pSu98nvpljqNhydiKib6oSTnyoBNdtcxid)fYkqjqWOiTyubAc3oH7qGY(6Nh4oyuuEh22gmNTZHP6TuVhy4KN9wIm(z0nv)mwpMKIgS1Zx9Su9wQhtqyArcgfjqJK3hqGI5SDomjCHmwriRansEFab6sjm5gNsiGEw4ibkbcgfPfJkCHmwviRaLabJI0IrfOrY7diqXC2ohMeOjC7eUdbk7RFEG7Grr5DyBBWC2ohMQ3s9SV(5bUdgfL5wYyJ7d3(yd(8W7duVL6xBsPmEGHt(MxeoCpKaM1pSu98nvV11BPEpWWjp7Tez8ZOBQE(MQNT1B165PE2wV11ZYRpDsmNX(AGV1ZM6zt9wQhtqyArcgfjqtJtkY4bgo5RqgwfUqgwsiRaLabJI0IrfOjC7eUdbk7RFEG7Grr5DyBBWC2ohMQ3s9yskAWw)G1NUtPp5G8owI5uR5GmAkCKmMKIgS1Zt9SYI6TuF6oL(KdY7yjMtTMdYOPWrYyskAWw)Gt1B16TuVhy4KN9wIm(z0nv)mwpMKIgS1Zx9P7u6toiVJLyo1AoiJMchjJjPObB98uVvfOrY7diqXC2ohMeUqg(PqwbkbcgfPfJkqt42jChcu2x)8a3bJIYClzSX9HBFSbFE49bQ3s9RnPugpWWjFRNVP65VansEFabkJksdn2NCnHfUqMzviRansEFabknV3eHdNeOeiyuKwmQWfUanPxHSczyviRaLabJI0IrfOjC7eUdbk7RNHdckViH(KB0birzo76TupdheuEr4W9qcy8ddc9L5SR3s9mCqq5fHd3djGXpmi0xgtsrd26hCQE(NTQansEFab6Ie6tUrhGejq5wYCqqg4jTqgwfUqgRfYkqjqWOiTyubAc3oH7qGYWbbLxeoCpKag)WGqFzo76TupdheuEr4W9qcy8ddc9LXKu0GT(bNQN)zRkqJK3hqGUJLyo1AoiJMchrGYTK5GGmWtAHmSkCHm8xiRaLabJI0IrfOjC7eUdb68a3bJIYlqBshq3EFG6Tup7RFDkuocPZsbWvKansEFabkKkGtkv49beUqgRiKvGsGGrrAXOc0eUDc3HavtmCqqzivaNuQW7dKXKu0GT(bR3AbAK8(acuivaNuQW7dyskkaljCHmwviRaLabJI0IrfOjC7eUdbkBRhZbiOddNYsbEO5GmoczKI1jSj2n2TbzAw4ABBsxVL6tNeZzSVg4BwtqDQ96hCQE(xpSWwpMdqqhgoL1u4iQXMfj0N8ntZcxBBt66TuF6KyoJ91aFRFW6zTE2uVL6z4GGY7yjMtTMdYOPWrYC21BPEgoiO8Ie6tUrhGeL5SR3s9sX6e2e7g72adMKIgS1pvplQ3s9mCqqznfoIASzrc9jFZ6toqGgjVpGaDEa6fr4czyjHScucemkslgvGMWTt4oeOSV(1Pq5iKohkv9wQFEG7Grr5fOnPdOBVpq9WcB90UeirzgmfoI5Gmocz0JBa8SumaE46TuV3su98nvV1c0i59beOPqPmrY7dyu96cuvVUbesKaL2LajAfUqg(PqwbkbcgfPfJkqJK3hqGAFNYGP94WjsGMWTt4oeOEOiGNxeoCpKag)WGqFzcemksxVL6zF9EOiGNxKqFYnqxIBZeiyuKwGcDydGyxxidRcxiZSkKvGsGGrrAXOc0eUDc3HaLaeg(465BQEwIf1BP(5bUdgfLxG2KoGU9(a1BP(0Dk9jhK3XsmNAnhKrtHJK5SR3s9P7u6toiViH(KB0bir5esGHtB98nvpRc0i59beOlchUhsaJFyqOpHlKz2iKvGsGGrrAXOc0i59beOlHXHtAdZbiZA3djbAc3oH7qGopWDWOO8c0M0b0T3hOEl1Z(61NNxcJdN0gMdqM1Uhsg95zVtdBa86TuVhy4KN9wIm(z0nvpFt1BnR1dlS1d1WrCdMKIgS1p4u9wTEl1V2Ksz8adN8nViC4EibmRFyP6hSE(lqtJtkY4bgo5RqgwfUqgwzHqwbkbcgfPfJkqt42jChc05bUdgfLxG2KoGU9(a1BP(0jXCg7Rb(M1euNAVE(MQNvbAK8(ac0LS3EfUqgwzviRaLabJI0IrfOjC7eUdb68a3bJIYlqBshq3EFG6Tup7RpDNsFYb5fj0NCdJk00M5SR3s9STEpueWZeyoPo7ga3SiH(KVzcemksxpSWwF6oL(KdYlsOp5gDasuoHey40wpFt1ZA9SPEl1Z26zF9EOiGNxeoCpKag)WGqFzcemksxpSWwVhkc45fj0NCd0L42mbcgfPRhwyRpDNsFYb5fHd3djGXpmi0xgtsrd265RERRNn1BPE2wp7RN2LajkZOUtBoiJJqgcqsJZsXa4HRhwyRpDNsFYbzg1DAZbzCeYqasACgtsrd265RERRNnc0i59beO7yjMtTMdYOPWreUqgwTwiRaLabJI0IrfOrY7diqLc8qsBGoSrtHJiqt42jChcuC0AdnNaEo06nZzxVL6zB9EGHtE2BjY4Nr3u9dwF6KyoJ91aFZAcQtTxpSWwp7RFDkuocPZHsvVL6tNeZzSVg4BwtqDQ965BQ(KTrkyxZAtaD9SrGMgNuKXdmCYxHmSkCHmSYFHScucemkslgvGMWTt4oeO4O1gAob8CO1BUb1Zx98Nf1pJ1JJwBO5eWZHwVznho8(a1BP(0jXCg7Rb(M1euNAVE(MQpzBKc21S2eqlqJK3hqGkf4HK2aDyJMchr4czy1kczfOeiyuKwmQanHBNWDiqNh4oyuuEbAt6a627duVL6tNeZzSVg4BwtqDQ965BQERfOrY7diqxKqFYnmQqtRWfYWQvfYkqjqWOiTyubAc3oH7qGopWDWOO8c0M0b0T3hOEl1NojMZyFnW3SMG6u71Z3u98VEl1Z26Nh4oyuuMBjJnUpC7Jn4ZdVpq9WcB9RnPugpWWjFZlchUhsaZ6hwQ(bNQ3k1ZgbAK8(acukHCnaUbt24wkaAHlKHvwsiRaLabJI0IrfOjC7eUdbQhkc45fj0NCd0L42mbcgfPR3s9ZdChmkkVaTjDaD79bQ3s9mCqq5DSeZPwZbz0u4izoBbAK8(ac0fHd3djGXpmi0NWfYWk)uiRaLabJI0IrfOjC7eUdbk7RNHdckViH(KB0birzo76TupudhXnyskAWw)Gt1pR1Zt9EOiGNxogNWqCWPmbcgfPfOrY7diqxKqFYn6aKiHlKH1zviRansEFabQ959beOeiyuKwmQWfYW6SriRaLabJI0IrfOjC7eUdbkdheuEhlXCQ1CqgnfosMZwGgjVpGaLrDN2aXHhlCHmwZcHScucemkslgvGMWTt4oeOmCqq5DSeZPwZbz0u4izoBbAK8(acugcVeEydGlCHmwZQqwbkbcgfPfJkqt42jChcugoiO8owI5uR5GmAkCKmNTansEFabkuJjg1DAHlKXARfYkqjqWOiTyubAc3oH7qGYWbbL3XsmNAnhKrtHJK5SfOrY7diqdqIwhhktkukHlKXA(lKvGsGGrrAXOc0i59beOPXj154d0jdJkwxGMWTt4oeOSV(1Pq5iKohkv9wQFEG7Grr5fOnPdOBVpq9wQN91ZWbbL3XsmNAnhKrtHJK5SR3s9eGWWhN1euNAVE(MQN)SqGsqquYnGqIeOPXj154d0jdJkwx4czS2kczfOeiyuKwmQansEFabAWVlsGJ1aDa3Cqg7toHfOjC7eUdbk7RNHdckViH(KB0birzo76TuF6oL(KdY7yjMtTMdYOPWrYyskAWw)G1ZkleOGqIeOb)Uibowd0bCZbzSp5ew4czS2QczfOeiyuKwmQansEFabASiZdaTgCWVh2KoCOeOjC7eUdbQMy4GGY4GFpSjD4qz0edheuwFYb1dlS1RjgoiOC6aAUK3ZjtdgA0edheuMZUEl17bgo5zekuos2o51py98366TuVhy4KNrOq5iz7KxpFt1ZFwupSWwp7RxtmCqq50b0CjVNtMgm0OjgoiOmND9wQNT1RjgoiOmo43dBshougnXWbbLxpsdRNVP6T2Q1pJ1ZklQNLxVMy4GGYmQ70MdY4iKHaK04mND9WcB9qnCe3GjPObB9dwVvyr9SPEl1ZWbbL3XsmNAnhKrtHJKXKu0GTE(QFwfOGqIeOXImpa0AWb)Eyt6WHs4czSMLeYkqjqWOiTyubkiKibQ0yDSgpu9kfabAK8(acuPX6ynEO6vkacxiJ18tHScucemkslgvGMWTt4oeOmCqq5DSeZPwZbz0u4izo76Hf26HA4iUbtsrd26hSERzHansEFabk3sM2jPv4cxGUofkhXK0RqwHmSkKvGsGGrrAXOc0ZwGUKlqJK3hqGopWDWOib68qXrc00Dk9jhKxKqFYn6aKOCcjWWP1aHJK3hiu1Z3u9SM5NwvGopWgqirc0frBCemTiNslCHmwlKvGsGGrrAXOc0eUDc3HaLT1Z(6Nh4oyuuEr0ghbtlYP01dlS1Z(69qrapdA4i(6HAiHZeiyuKUEl17HIaEwh4HMfj0N8mbcgfPRNn1BP(0jXCg7Rb(M1euNAVE(QN16Tup7RhZbiOddNYsbEO5GmoczKI1jSj2n2TbzAw4ABBslqJK3hqGopa9IiCHm8xiRaLabJI0IrfOrY7diqTVtzW0EC4ejqj21XHjKooGlqTcleOqh2ai21fYWQWfYyfHScucemkslgvGMWTt4oeOeGWWhxpFt1BfwuVL6jaHHpoRjOo1E98nvpRSOEl1Z(6Nh4oyuuEr0ghbtlYP01BP(0jXCg7Rb(M1euNAVE(QN16TuVMy4GGYqnqBKtXqaTBgtsrd26hSEwfOrY7diqxKqFYLiLw4czSQqwbkbcgfPfJkqpBb6sUansEFab68a3bJIeOZdfhjqtNeZzSVg4BwtqDQ965BQERiqNhydiKib6IOnPtI5m2xd8v4czyjHScucemkslgvGE2c0LCbAK8(ac05bUdgfjqNhkosGMojMZyFnW3SMG6u71p4u9Skqt42jChc05bUdgfL5wYyJ7d3(yd(8W7duVL6xBsPmEGHt(MxeoCpKaM1pSu98nvVveOZdSbesKaDr0M0jXCg7Rb(kCHm8tHScucemkslgvGMWTt4oeOZdChmkkViAt6KyoJ91aFR3s9ST(5bUdgfLxeTXrW0ICkD9WcB9mCqq5DSeZPwZbz0u4izmjfnyRNVP6znBD9WcB9RnPugpWWjFZlchUhsaZ6hwQE(MQ3k1BP(0Dk9jhK3XsmNAnhKrtHJKXKu0GTE(QNvwupBeOrY7diqxKqFYn6aKiHlKzwfYkqjqWOiTyubAc3oH7qGopWDWOO8IOnPtI5m2xd8TEl1d1WrCdMKIgS1py9P7u6toiVJLyo1AoiJMchjJjPObRansEFab6Ie6tUrhGejCHlqz4ALwiRqgwfYkqjqWOiTyubAc3oH7qGY(69qrapdA4i(6HAiHZeiyuKUEl1J5ae0HHtzVbJn(XUDYWOcnLPzHRTTjTansEFab6I0ZfUqgRfYkqjqWOiTyubAc3oH7qGU2Ksz8adN8TE(MQ3665PE2wVhkc4z4Q7KyuHMYeiyuKUEl1h8lHBNY2eg6WHtzCagwpFt1BD9SrGgjVpGaDr4W9qcyw)Wscxid)fYkqjqWOiTyubAc3oH7qGMUtPp5G8syC4K2WCaYS29qkNqcmCAnq4i59bcv98nvV1z(PvfOrY7diqxcJdN0gMdqM1UhscxiJveYkqJK3hqGcxDNeJk0KaLabJI0IrfUqgRkKvGgjVpGaLjsdxpyeOeiyuKwmQWfUWfOZj82hqiJ1SWAwWkRSG)cu5bg0a4RaDgWoXoKHDwMby8J1xVSiu9TK9H96HoC9ZwmCTspBvpMMfUgt663tIQp48tkCsxFcjaWPnxWmaObu9wZpwp7GKU5KUE7BBVpGHjsdRpHqPH1ZwW51hZJwfmkQ(gupjXPcVpaBQNTSYUSjxWuWWolzFyN01pR1hjVpq9QE9nxWiqTXhuRib6aRhLJXvKpUE2XbNJkygy9YCZjjgcxplXB9wZcRzrbtbZaRF2X0moGNet4fmrY7dSzBmLojMW5zAKW2wn2yF9EGcMi59b2SnMsNet48mnY6uOCKcMi59b2SnMsNet48mnIuGhsAd0HnAkCeETXu6Kyc3Su6a6DIvRwWejVpWMTXu6KycNNPrwvNita0gDNiETXu6Kyc3Su6a6DIvEBOjmbHPfjyuubtK8(aB2gtPtIjCEMgzrc9j3WOcnT82qtyoabDy4uwkWdnhKXriJuSoHnXUXUnitZcxBBt6cMi59b2SnMsNet48mnc3sM2jjEbHenf87Ie4ynqhWnhKX(Kt4cMcMbw)au0G6zhNhEFGcMi59b2PHDAybtK8(alptJmpWDWOiEbHenTaTjDaD79b4DEO4OjgoiO8Q6ezcG2O7eL5SHf21MukJhy4KV5fHd3djGz9dlX3elX7mCjD9(vVMCcl1aQE5iKJq46t3P0NCWwV8O96HoC9OGzwptSKU(duVhy4KV5cMbw)aIqPH1pGZCRp86HA86fmrY7dS8mnskuktK8(agvVoVGqIMs6TGzG1Zo4a1dXPuJRFL3EcH269REhHQh1Pq5iKUE2X5H3hOE2YmUE91a41VhVTxp0Ht0wV9DQgaV(gQEW5inaE99wFmpAvWOi2KlyIK3hy5zAemhWejVpGr1RZliKOP1Pq5iKM3gAADkuocPZHsvWmW6zNSTvJRFvDImbqB0DIQp86TMN6hWzVEnhUbWR3rO6HA861ZklQFP0b0lVbKt46DKWR3k8u)ao713q13E9e7A3yARxE7inOEhHQhqSRx)aSbCM1F467TEW51ZzxWejVpWYZ0iRQtKjaAJUteVn00AtkLXdmCY38IWH7HeWS(HLgKLSa1WrCdMKIgS8Xswy4GGYRQtKjaAJUtugtsrd2bHN0zPGDTKojMZyFnWx(MSYmYwVLObzLfSHLBDbZaRF2oqnU(esaGt1Jpp8(a13q1lNQhjMt1BJ7d3(yd(8W7du)sE9bqxVeNYBBfvVhy4KV1ZzNlyIK3hy5zAK5bUdgfXliKOjULm24(WTp2Gpp8(a8opuC0KnUpC7Jn4ZdVpGL1MukJhy4KV5fHd3djGz9dlX3K1fmdS(zh3hU9X1Zoop8(aZ2w)aaYNT26H3ZP6J6t4WU(G5486jaHHpUEOdxVJq1VofkhP(bCMB9SLHRvAcx)6TsvpMwBk513oBY1pBdNnVTxFka1Zq17iHx)2s2kkxWejVpWYZ0iPqPmrY7dyu968ccjAADkuoIjPxEBOP5bUdgfL5wYyJ7d3(yd(8W7duWmW6NHlPR3V61eudO6LJqG69REULQFDkuos9d4m36pC9mCTst4TGjsEFGLNPrMh4oyueVGqIMwNcLJyCemTiNsZ78qXrtwBvE8qrappVHF4mbcgfPz5wZcE8qraplfRtyZbzwKqFY3mbcgfPz5wZcE8qrapViH(KBGUe3MjqWOinl3ARYJhkc45qfjC7JZeiyuKMLBnl4XARYYz7AtkLXdmCY38IWH7HeWS(HL4BYkSPGzG1pGhyBnHRNBBa86J6rDkuos9d4mRxocbQhtrcPbWR3rO6jaHHpUEhbtlYP0fmrY7dS8mnskuktK8(agvVoVGqIMwNcLJys6L3gAIaeg(4SMG6u7donpWDWOO86uOCeJJGPf5u6cMbwVmnCeF2ARNFGaWPaKi(X6zhC2ohMQNHGomvp6yjMtT1hE9QtE9d4SxVF1NojMgq1tbwnUEmbHPfPE5TJupCY9gaVEhHQNHdcQEo7C9StQ9QxDYRFaN961C4gaVE0XsmNARNHC5ebQFMbirB9YBhPER5PEz4hYfmrY7dS8mncMZ25WeVn0uWVeUDkdA4i(AMta4uasuMabJI0wypdheug0Wr81mNaWPaKOmNTL0jXCg7Rb(M1euNANpwTW21MukJhy4KV5fHd3djGz9dlnO1Wc78a3bJIYClzSX9HBFSbFE49byJf2MUtPp5G8owI5uR5GmAkCKmMKIgSdoXFyHLTb)s42PmOHJ4RzobGtbirzCagY3K1wy4GGY7yjMtTMdYOPWrYyskAWYh)TW(1Pq5iKohkLL0Dk9jhKxKqFYn6aKOCcjWWP1aHJK3hiu8nXI8SHnSPGjsEFGLNPrsHszIK3hWO615fes0eud6fH3gAcZbiOddNYAkCe1yZIe6t(MPzHRTTjTf955LS3EZENg2a4w0NNxYE7nJjPOb7GtwBjDsmNX(AGV8nzDbtK8(alptJKcLYejVpGr1RZliKOjOg0lcVn0u6KyoJ91aFNcqlfjKadN0MKDbZaR3Q8uV82rQFMO1Z2JZ3wt1VofkhHnfmrY7dS8mnskuktK8(agvVoVGqIMGAqVi82qtPtI5m2xd8nRjOo1(GtSclSqnCe3GjPOb7GtSAjDsmNX(AGV8nX)cMbwplRb9IuF41BfEQxE7ihNx)mrlygy9ZG2rQFMO1hQ9QhQb9IuF41BfEQpGhny96j2nsUAC9wPEpWWjFRNThNVTMQFDkuocBkyIK3hy5zAKuOuMi59bmQEDEbHenb1GEr4THMwBsPmEGHt(MxeoCpKaM1pS0KvSKojMZyFnWx(MSsbZaRFgUu9r9mCTst46LJqG6XuKqAa86DeQEcqy4JR3rW0ICkDbtK8(alptJKcLYejVpGr1RZliKOjgUwP5THMiaHHpoRjOo1(GtZdChmkkVofkhX4iyAroLUGzG1pa4KtRxVnUpC7JRVb1hkv9hu9ocvp70SpaOEgkfClvF71NcUL26J6hGnGZSGjsEFGLNPrcCkaKXpmMaoVn0ebim8Xznb1P25BIvRYdbim8XzmbNafmrY7dS8mnsGtbGm2CQLkyIK3hy5zAevdhXxZaiNgUeb8cMi59bwEMgHjGBoiJJ70WTGPGzG1pG3P0NCWwWmW6NHlv)mdqIQ)GGMr4jD9me0HP6DeQEOgVE9lchUhsaZ6hwQEi8jvVShge6R(0jrB9nixWejVpWMt6LNPrwKqFYn6aKiE5wYCqqg4j9eR82qtSNHdckViH(KB0birzoBlmCqq5fHd3djGXpmi0xMZ2cdheuEr4W9qcy8ddc9LXKu0GDWj(NTAbZaRNTZqGI2T(qHPqpUEo76zOuWTu9YP697gwpksOp51ZYUe3YM65wQE0XsmNAR)GGMr4jD9me0HP6DeQEOgVE9lchUhsaZ6hwQEi8jvVShge6R(0jrB9nixWejVpWMt6LNPr2XsmNAnhKrtHJWl3sMdcYapPNyL3gAIHdckViC4Eibm(HbH(YC2wy4GGYlchUhsaJFyqOVmMKIgSdoX)SvlyIK3hyZj9YZ0iqQaoPuH3hG3gAAEG7Grr5fOnPdOBVpGf2VofkhH0zPa4kQGjsEFGnN0lptJaPc4KsfEFatsrbyjEBOjnXWbbLHubCsPcVpqgtsrd2bTUGjsEFGnN0lptJmpa9IWBdnXwmhGGomCklf4HMdY4iKrkwNWMy3y3gKPzHRTTjTL0jXCg7Rb(M1euNAFWj(dlSyoabDy4uwtHJOgBwKqFY3mnlCTTnPTKojMZyFnW3bzLnwy4GGY7yjMtTMdYOPWrYC2wy4GGYlsOp5gDasuMZ2IuSoHnXUXUnWGjPOb7elSWWbbL1u4iQXMfj0N8nRp5GcMi59b2CsV8mnskuktK8(agvVoVGqIMODjqIwEBOj2VofkhH05qPSmpWDWOO8c0M0b0T3hawyPDjqIYmykCeZbzCeYOh3a4zPya8Ww8wI4BY6cMbw)SFNQEOdxVShge6REBmnJO3mRxE7i1JImZ6XuOhxVCecup486XCaqdGxpkllxWejVpWMt6LNPrSVtzW0EC4eXl0HnaID9jw5THM8qrapViC4Eibm(HbH(YeiyuK2c79qrapViH(KBGUe3MjqWOiDbZaRFgUu9YEyqOV6TXu9O3mRxocbQxovpsmNQ3rO6jaHHpUE5iKJq46HWNu923PAa86L3oYX51JYYQ)W1paYTE9WjaHdLACUGjsEFGnN0lptJSiC4Eibm(HbH(4THMiaHHpMVjwIfwMh4oyuuEbAt6a627dyjDNsFYb5DSeZPwZbz0u4izoBlP7u6toiViH(KB0bir5esGHtlFtSwWejVpWMt6LNPrwcJdN0gMdqM1Uhs8MgNuKXdmCY3jw5THMMh4oyuuEbAt6a627dyH96ZZlHXHtAdZbiZA3djJ(8S3PHnaUfpWWjp7Tez8ZOBIVjRzfwyHA4iUbtsrd2bNSQL1MukJhy4KV5fHd3djGz9dlni)lyIK3hyZj9YZ0ilzV9YBdnnpWDWOO8c0M0b0T3hWs6KyoJ91aFZAcQtTZ3eRfmdS(z4s1JowI5uB9hO(0Dk9jhupBdiNW1d141Rhfmt2uphqr7wVCQ(at1d)Aa869RE7ZUEzpmi0x9bqxV(QhCE9iXCQEuKqFYRNLDjUnxWejVpWMt6LNPr2XsmNAnhKrtHJWBdnnpWDWOO8c0M0b0T3hWc7t3P0NCqErc9j3WOcnTzoBlS1dfb8mbMtQZUbWnlsOp5BMabJI0WcB6oL(KdYlsOp5gDasuoHey40Y3eRSXcBzVhkc45fHd3djGXpmi0xMabJI0WcRhkc45fj0NCd0L42mbcgfPHf20Dk9jhKxeoCpKag)WGqFzmjfny5ZA2yHTSN2LajkZOUtBoiJJqgcqsJZsXa4HHf20Dk9jhKzu3PnhKXridbiPXzmjfny5ZA2uWmW6zNHQp06T(at1ZzZB9lOTP6DeQ(dq1lVDK6vNCA96Lv2zMRFgUu9Yriq96XnaE9qX6eUEhja1pGZE9AcQtTx)HRhCE9RtHYriD9YBh5486dW46hWzpxWejVpWMt6LNPrKc8qsBGoSrtHJWBACsrgpWWjFNyL3gAchT2qZjGNdTEZC2wyRhy4KN9wIm(z0nny6KyoJ91aFZAcQtTdlSSFDkuocPZHszjDsmNX(AGVznb1P25BkzBKc21S2eqZMcMbwp7mu9GR(qR36L3kv96MQxE7inOEhHQhqSRxp)zXYB9Clv)ae0mR)a1ZC7wV82rooV(amU(bC2ZfmrY7dS5KE5zAePapK0gOdB0u4i82qt4O1gAob8CO1BUb8XFwmJ4O1gAob8CO1BwZHdVpGL0jXCg7Rb(M1euNANVPKTrkyxZAtaDbtK8(aBoPxEMgzrc9j3WOcnT82qtZdChmkkVaTjDaD79bSKojMZyFnW3SMG6u78nzDbtK8(aBoPxEMgHsixdGBWKnULcGM3gAAEG7Grr5fOnPdOBVpGL0jXCg7Rb(M1euNANVj(BHTZdChmkkZTKXg3hU9Xg85H3hawyxBsPmEGHt(MxeoCpKaM1pS0GtwHnfmdS(zq7i1JYY4T(gQEW51hkmf6X1RpaXB9ClvVShge6RE5TJup6nZ65SZfmrY7dS5KE5zAKfHd3djGXpmi0hVn0Khkc45fj0NCd0L42mbcgfPTmpWDWOO8c0M0b0T3hWcdheuEhlXCQ1CqgnfosMZUGjsEFGnN0lptJSiH(KB0bir82qtSNHdckViH(KB0birzoBlqnCe3GjPOb7GtZkpEOiGNxogNWqCWPmbcgfPlykygy9YCGzCTPu9RZbbvV82rQxDYjC924(kyIK3hyZj9YZ0i2N3hOGjsEFGnN0lptJWOUtBG4WJ5THMy4GGY7yjMtTMdYOPWrYC2fmrY7dS5KE5zAegcVeEydGZBdnXWbbL3XsmNAnhKrtHJK5SlyIK3hyZj9YZ0iqnMyu3P5THMy4GGY7yjMtTMdYOPWrYC2fmrY7dS5KE5zAKaKO1XHYKcLI3gAIHdckVJLyo1AoiJMchjZzxWuWejVpWMt6LNPr4wY0ojXlbbrj3acjAknoPohFGozyuX682qtSFDkuocPZHszzEG7Grr5fOnPdOBVpGf2ZWbbL3XsmNAnhKrtHJK5STqacdFCwtqDQD(M4plkyIK3hyZj9YZ0iClzANK4fes0uWVlsGJ1aDa3Cqg7toH5THMypdheuErc9j3OdqIYC2ws3P0NCqEhlXCQ1Cqgnfosgtsrd2bzLffmdS(ZriS8EP6L3os9O3mRp86T2Q8u)6rA4w)HRNvRYt9YBhP(qTx9JQUtxpNDUGjsEFGnN0lptJWTKPDsIxqirtXImpa0AWb)Eyt6WHI3gAstmCqqzCWVh2KoCOmAIHdckRp5ayHvtmCqq50b0CjVNtMgm0OjgoiOmNTfpWWjpJqHYrY2jFq(BTfpWWjpJqHYrY2jNVj(ZcyHL9AIHdckNoGMl59CY0GHgnXWbbL5STWwnXWbbLXb)Eyt6WHYOjgoiO86rAiFtwB1zKvwWY1edheuMrDN2CqghHmeGKgN5SHfwOgoIBWKu0GDqRWc2yHHdckVJLyo1AoiJMchjJjPOblFZAbZaRNFGWJRhFCWruJRhZPO6pO6DeojMgQjD9sHJS1ZqQto)y9ZWLQh6W1ZodgAF66t42lyIK3hyZj9YZ0iClzANK4fes0K0yDSgpu9kfGcMbw)mjOGt51dfkftKgwp0HRNBdgfvF7K0Ypw)mCP6L3os9OJLyo1w)bv)mPWrYfmrY7dS5KE5zAeULmTtslVn0edheuEhlXCQ1CqgnfosMZgwyHA4iUbtsrd2bTMffmfmdSE2j(LWTt1pa0UeirBbtK8(aBM2LajA5zAK0bseWXHtAdKkKiEBOjcqy4JZElrg)msb7YhRwypdheuEhlXCQ1CqgnfosMZ2cBzV(8C6ajc44WjTbsfsKHHddYENg2a4wyFK8(a50bseWXHtAdKkKOCdmqQgoIdlSqCkLbtjKadNmElrdcpPZsb7YMcMi59b2mTlbs0YZ0imQ70MdY4iKHaK0yEBOj2NUtPp5G8Ie6tUHrfAAZC2ws3P0NCqEhlXCQ1CqgnfosMZgwyHA4iUbtsrd2bNyLffmrY7dSzAxcKOLNPrGZfyDhaZbzc(LWNJuWejVpWMPDjqIwEMgb6sClPnb)s42jddfs82qtSDTjLY4bgo5BEr4W9qcyw)Ws8nznSWIJwBO5eWZHwV5gWhlXc2yH9P7u6toiVJLyo1AoiJMchjZzBH9mCqq5DSeZPwZbz0u4izoBleGWWhN1euNANVj(ZIcMi59b2mTlbs0YZ0i2C4gACdGByuX682qtRnPugpWWjFZlchUhsaZ6hwIVjRHfwC0AdnNaEo06n3a(yjwuWejVpWMPDjqIwEMgXridhG54aAd0HteVn0edheugtPHkAxd0HtuMZgwyz4GGYyknur7AGoCImPJd4eoVEKgoiRSOGjsEFGnt7sGeT8mncUTTvKPbM1osubtK8(aBM2LajA5zAe5hwPNtnWGP9abir82qtP7u6toiVJLyo1AoiJMchjJjPOb7GwfwyHA4iUbtsrd2bzDwlyIK3hyZ0UeirlptJirshES5GmkUuRnAmfslVn0ebim8XdAfwyHHdckVJLyo1AoiJMchjZzxWmW6hGFkD9SdkSBa86zzQqI26HoC9e7sjoNQhha4u9hU(HTsvpdhe0YB9nu923UnJIY1ZoPKhJ36D8469RE4KxVJq1Ro5061NUtPp5G6zIL01FG6J5rRcgfvpbiPM2CbtK8(aBM2LajA5zAemf2naUbsfs0YBdnb1WrCdMKIgSdYA2QWclBzRhy4KNrOq5iz7KZ3SYcyH1dmCYZiuOCKSDYhCYAwWglSnsEpNmeGKAANyfwyHA4iUbtsrdw(SE2Wg2alSS1dmCYZElrg)m2j3ynl4J)SWcBJK3ZjdbiPM2jwHfwOgoIBWKu0GLpRyf2WMcMcMbwpQtHYrQFaVtPp5GTGjsEFGnVofkhXK0lptJmpWDWOiEbHenTiAJJGPf5uAENhkoAkDNsFYb5fj0NCJoajkNqcmCAnq4i59bcfFtSM5NwL3b4KYMW1Zpe4oyuubZaRNFia9IuFdvVCQ(at1NcB7gaV(du)mdqIQpHey40MRFaOaRgxpdbDyQEOgVE96aKO6BO6Lt1JeZP6bx9Y0Wr81d1qcxpdNx)md8W6rrc9jV(gu)H1eUE)Qho51Zo4SDomvpND9SfC1pafRt46zN2n2TbSjxWejVpWMxNcLJys6LNPrMhGEr4THMyl7Nh4oyuuEr0ghbtlYP0Wcl79qrapdA4i(6HAiHZeiyuK2Ihkc4zDGhAwKqFYZeiyuKMnwsNeZzSVg4BwtqDQD(y1c7XCac6WWPSuGhAoiJJqgPyDcBIDJDBqMMfU22M0fmrY7dS51Pq5iMKE5zAe77ugmThhor8cDydGyxFIvEj21XHjKooGpzfwW7SFNQEOdxpksOp5sKsxpp1JIe6t(64Eivphqr7wVCQ(at1hmhNxVF1Nc76pq9ZmajQ(esGHtBU(z7a146LJqG6zznqx)mGIHaA367T(G54869REmhO(JZZfmrY7dS51Pq5iMKE5zAKfj0NCjsP5THMiaHHpMVjRWcleGWWhN1euNANVjwzHf2ppWDWOO8IOnocMwKtPTKojMZyFnW3SMG6u78XQfnXWbbLHAG2iNIHaA3mMKIgSdYAbtK8(aBEDkuoIjPxEMgzEG7Grr8ccjAAr0M0jXCg7Rb(Y78qXrtPtI5m2xd8nRjOo1oFtwH3bC2RhtZcxJjjc48J1pZaKO6dVE1jV(bC2RNzC9Ack4uEUGzG1pGZE9yAw4AmjraNFS(zgGev)buJRNHGomvpud6fHWB9nu9YP6rI5u924(WTpUE85H3hO(WR3k8uVhy4KV5cMi59b286uOCetsV8mnY8a3bJI4fes00IOnPtI5m2xd8L35HIJMsNeZzSVg4BwtqDQ9bNyL3gAAEG7GrrzULm24(WTp2Gpp8(awwBsPmEGHt(MxeoCpKaM1pSeFtwPGzG1pZaKO61C4gaVE0XsmNAR)W1hm3CQEhbtlYP05cMi59b286uOCetsV8mnYIe6tUrhGeXBdnnpWDWOO8IOnPtI5m2xd81cBNh4oyuuEr0ghbtlYP0WcldheuEhlXCQ1Cqgnfosgtsrdw(MynBnSWU2Ksz8adN8nViC4EibmRFyj(MSIL0Dk9jhK3XsmNAnhKrtHJKXKu0GLpwzbBkygy9JYHb1JjPObnaE9ZmajARNHGomvVJq1d1Wr86jGERVHQh9Mz9YpWSLxpdvpMc946Bq9Elr5cMi59b286uOCetsV8mnYIe6tUrhGeXBdnnpWDWOO8IOnPtI5m2xd81cudhXnyskAWoy6oL(KdY7yjMtTMdYOPWrYyskAWwWuWmW6rDkuocPRNDCE49bkygy9SZq1J6uOCKrMhGErQpWu9C28wp3s1JIe6t(64EivVF1ZqacQ96HWNu9ocvVDSBpNQN5aCB9bqxplRb66Nbumeq7wpnNa13q1lNQpWu9HxVuWU1pGZE9SfcFs17iu92ykDsmHx)ae0mztUGjsEFGnVofkhH08mnYIe6t(64EiXBdnXwgoiO86uOCKmNnSWYWbbLNhGErYC2SPGzG1ZYAqVi1hE98NN6hWzVE5TJCCE9ZeT(rQ3k8uV82rQFMO1lVDK6rr4W9qcuVShge6REgoiO65SR3V6J5xRRFpjQ(bC2RxESov)2ox49b2CbtK8(aBEDkuocP5zAKuOuMi59bmQEDEbHenb1GEr4THMy4GGYlchUhsaJFyqOVmNTL0jXCg7Rb(M1euNAFWjRlygy9StQ9QFdiQE)QhQb9IuF41BfEQFaN96L3os9e7gjxnUERuVhy4KV56zlAir1hB9hNVTMQFDkuosMnfmrY7dS51Pq5iKMNPrsHszIK3hWO615fes0eud6fH3gAATjLY4bgo5BEr4W9qcyw)WstwXs6KyoJ91aF5BYkfmdSEwwd6fP(WR3k8u)ao71lVDKJZRFMO8wVv5PE5TJu)mr5T(aORNLQxE7i1pt06diNW1ZpeGErkyIK3hyZRtHYrinptJKcLYejVpGr1RZliKOjOg0lcVn0u6KyoJ91aFZAcQtTp4eRZiB9qrapRjYMWM1XHhWjPmbcgfPTWWbbLNhGErYC2SPGjsEFGnVofkhH08mnYI0Z5THM8qrapdA4i(6HAiHZeiyuK2cMdqqhgoL9gm24h72jdJk0uMMfU22M0fmdSEw2HR3gtZOD4jeERFir21ZYAGU(zafdb0U1Zzx)bQ3rO6TXTuGhxVhy4KxVMJQ3V6bx9OiH(Kxp)qWP8cMi59b286uOCesZZ0ilsOp5RJ7HeVn0KIMtQbTQ1w0edheugQbAJCkgcODZyskAWoiRw8adN8S3sKXpJUPzetsrdw(yPcMbw)m0UE)QN)17bgo5B9djYUEo76zznqx)mGIHaA36zgxFACs1a41JIe6t(64EiLlyIK3hyZRtHYrinptJSiH(KVoUhs8MgNuKXdmCY3jw5THM0edheugQbAJCkgcODZyskAWoiRwwBsPmEGHt(MxeoCpKaM1pS0Gt83Ihy4KN9wIm(z0nnJyskAWYhlvWmW6NbTJCCE9ZKiBcxpQJdpGts1haD98VE2ragU1Fq1pQk0u9nOEhHQhfj0N8T(2RV36LFyhPEUTbWRhfj0N81X9qQ(dup)R3dmCY3CbtK8(aBEDkuocP5zAKfj0N81X9qI3gAI9EOiGN1eztyZ64Wd4KuMabJI0wc(LWTtzgvOjtdmoczwKqFY3moadN4VL1MukJhy4KV5fHd3djGz9dlnX)cMbwpl7W1BJ7d3(46XNhEFaERNBP6rrc9jFDCpKQ)Mt46r9dlvpRSPE5TJu)myaQ(aE0G1RNZUE)Q3k17bgo5lV1BnBQVHQNLndQV36XCaqdGx)bbvpBpq9byC9H0Xb86pO69adN8Ln8w)HRN)SPE)Qxky3wQ5xQE0BM1tSRtGTpq9YBhPE2zanV9GPvTpU(dup)R3dmCY36zRvQxE7i1pA7OSjxWejVpWMxNcLJqAEMgzrc9jFDCpK4THMMh4oyuuMBjJnUpC7Jn4ZdVpGf2QjgoiOmud0g5umeq7MXKu0GDqwHfwpueWZYPW(asX6eotGGrrAlRnPugpWWjFZlchUhsaZ6hwAWjRalSb)s42PCdO5ThmTQ9XzcemksBHHdckVJLyo1AoiJMchjZzBzTjLY4bgo5BEr4W9qcyw)WsdoXFEc(LWTtzgvOjtdmoczwKqFY3mbcgfPztbtK8(aBEDkuocP5zAKfHd3djGz9dlXBdnT2Ksz8adN8LVj(ZdBz4GGY2ysI0ThEFGmNnSWYWbbLDeYGp3jqMZgwyXCac6WWPCmmcCVM94ugiCaxIaEMMfU22M0wshqZ1EwtKnHn6aoCcVzCagY3e)KnfmrY7dS51Pq5iKMNPrwKqFYxh3djEBOjnXWbbLHAG2iNIHaA3mMKIgSdoXkSWMUtPp5G8owI5uR5GmAkCKmMKIgSdY6SArtmCqqzOgOnYPyiG2nJjPOb7GP7u6toiVJLyo1AoiJMchjJjPObBbZaRhfj0N81X9qQE)QhtqyArQNL1aD9ZakgcODRpa669REcSCyQE5u9PauFkW4X1FZjC9r9qCkv9SSzq9nWV6DeQEaXUE9O3mRVHQ3(2TzuuUGjsEFGnVofkhH08mnI9DkdM2JdNiEHoSbqSRpXAbtK8(aBEDkuocP5zAe4Q7KyuHM4THMy4GGY2eg6WHtAZCQbBE9inKVjRAjDanx7zBcdD4WjTzo1GnJdWq(MyL)fmrY7dS51Pq5iKMNPrwKqFYxh3dPcMcMbwplRb9Iq4TGjsEFGnd1GEr4zAKv1jYeaTr3jI3gAATjLY4bgo5BEr4W9qcyw)WsdYswypdheuErc9j3OdqIYC2wy4GGYRQtKjaAJUtugtsrd2bHA4iUbtsrdwlmCqq5v1jYeaTr3jkJjPOb7GSLvEsNeZzSVg4lBy5SMN1cMi59b2mud6fHNPrMh4oyueVGqIM2HTTbZz7CyI35HIJMKI1jSj2n2Tbgmjfny5JfWcl79qrapdA4i(6HAiHZeiyuK2Ihkc4zDGhAwKqFYZeiyuK2cdheuErc9j3OdqIYC2Wc7AtkLXdmCY38IWH7HeWS(HL4BIL4DaoPSjC98dbUdgfvp0HRNDWz7Cykxp6W2UEnhUbWRFakwNW1ZoTBSBdQ)W1R5WnaE9ZmajQE5TJu)md8W6dGUEWvVmnCeF9qnKW5cMbw)aWezxpND9SdoBNdt13q13E99wFWCCE9(vpMdu)X55cMi59b2mud6fHNPrWC2ohM4THMy)8a3bJIY7W22G5SDomzXdmCYZElrg)m6MMrmjfny5JLSGjimTibJIkyIK3hyZqnOxeEMgzPeMCJtjeqplCubZaRFaIt5T(CVbWR3dmCY36DKWRxERu1R65u9qhUEhHQxZHdVpq9hu9SdoBNdt1JjimTi1R5WnaE92bqtsDkxWejVpWMHAqVi8mncMZ25WeVPXjfz8adN8DIvEBOj2ppWDWOO8oSTnyoBNdtwy)8a3bJIYClzSX9HBFSbFE49bSS2Ksz8adN8nViC4EibmRFyj(MS2Ihy4KN9wIm(z0nX3eBTkpS1AwE6KyoJ91aFzdBSGjimTibJIkygy9Sdcctls9SdoBNdt1tbwnU(gQ(2RxERu1tSRDJP61C4gaVE0XsmNAZ1pZREhj86XeeMwK6BO6rVzwpCY36XuOhxFdQ3rO6be761B1nxWejVpWMHAqVi8mncMZ25WeVn0e7Nh4oyuuEh22gmNTZHjlyskAWoy6oL(KdY7yjMtTMdYOPWrYyskAWYdRSWs6oL(KdY7yjMtTMdYOPWrYyskAWo4KvT4bgo5zVLiJFgDtZiMKIgS8LUtPp5G8owI5uR5GmAkCKmMKIgS8y1cMi59b2mud6fHNPryurAOX(KRjmVn0e7Nh4oyuuMBjJnUpC7Jn4ZdVpGL1MukJhy4KV8nX)cMi59b2mud6fHNPrO59MiC4ubtbZaRFuUwPj8wWejVpWMz4ALEAr6582qtS3dfb8mOHJ4RhQHeotGGrrAlyoabDy4u2BWyJFSBNmmQqtzAw4ABBsxWejVpWMz4ALMNPrweoCpKaM1pSeVn00AtkLXdmCYx(MSMh26HIaEgU6ojgvOPmbcgfPTe8lHBNY2eg6WHtzCagY3K1wSVT9(agMinKnfmrY7dSzgUwP5zAKLW4WjTH5aKzT7HeVn0u6oL(KdYlHXHtAdZbiZA3dPCcjWWP1aHJK3hiu8nzDMFA1cMi59b2mdxR08mncC1DsmQqtfmrY7dSzgUwP5zAeMinC9GrGU2usiJ1SeRcx4cba]] )


end
