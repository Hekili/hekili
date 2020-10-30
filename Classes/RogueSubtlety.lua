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


    spec:RegisterPack( "Subtlety", 20201026, [[davr0bqiuQ8irbBse(KIsuJcLQofkfRcuQ6vOkMfQs3srH2Lc)suXWaLCmuslte5zOQY0er5AIcTnqP8nruX4uusNtrbwhQQcZtu09uK9HQY)uuIKdIsjzHIk9qru1evu0ffrLInckv(OIseJuevQojQQswPIQxQOePMjkLuDtuvLANeL(jkLugQIs1srPepfstLO4QkkHTIQQOVQOGoRiQuAVe(RGbRQdt1IrXJfAYK6YiBgKpdQgneNwQvlIk51IsZMKBtKDd8BvgUiDCfLYYH65knDkxhv2oO47evJhLsDErvRhvv18rj2VKfSkKrGQDJeYMeSscwScRKGTbRZGmMeRjjqT8PKan1JzD4Kaf4sKafLJXuKLxGM65vNRfYiq3JdhjbkIzPl)ro5aVneoMr8KYzBjoLB9bIyhYYzBPyocugUwz8xabJav7gjKnjyLeSyfwjbBdwNbzmjwfOoNHCybkAlL8cuKwRjGGrGQPnkqZq9OCmMIS81Zwo4Cunpd1ZwlAhdHRpjyJ36tcwjblbQQxBfYiqxJCLHqAHmczzviJaLaoJI0ICfOrCBeUDbk7RNHdcASg5kdzWLwplSupdhe0agh0lYGlTE2iq9O1hqGUiU(KVgUZsctiBsczeOeWzuKwKRanIBJWTlqz4GGglchUZsGGDyGRVbxA9jQpEsmxi9AGTdnb1X2QpZP6tsG6rRpGan6kvWJwFGGQxtGQ61caxIeOqnOxeHjKLFczeOeWzuKwKRanIBJWTlq3usPcMJHt2oweoCNLaH1oSu9t1NS6tuF8KyUq61aBRNVP6tMa1JwFabA0vQGhT(abvVMav1RfaUejqHAqVictiBYeYiqjGZOiTixbAe3gHBxGgpjMlKEnW2HMG6yB1N5u9Sw)mwp7R3CfbSHMOuchwd7MdNKgeWzuKU(e1ZWbbnGXb9Im4sRNncupA9beOrxPcE06deu9AcuvVwa4sKafQb9IimHSzuiJaLaoJI0ICfOrCBeUDbQ5kcydqdhXwZvzj8GaoJI01NOEmhGGomCAyniFWo2UJbgLRPbnBCDAkPfOE06diqxKggHjKf2eYiqjGZOiTixbAe3gHBxGQiyiv9zwFgtQ(e1RjgoiObud0b5KNfq7oWKK3GT(mRN16tuV5y4KnSwIc2f0nv)mwpMK8gS1Zx9WMa1JwFab6I46t(A4oljmHSjhHmcuc4mkslYvG6rRpGaDrC9jFnCNLeOrCBeUDbQMy4GGgqnqhKtEwaT7atsEd26ZSEwRpr9BkPubZXWjBhlchUZsGWAhwQ(mNQNF1NOEZXWjByTefSlOBQ(zSEmj5nyRNV6HnbAmFurbZXWjBfYYQWeYoRczeOeWzuKwKRanIBJWTlqzx9MRiGn0eLs4WAy3C4K0GaoJI01NOEN)jCB0Gr5Ak0GGHqHfX1N8DGDq26NQNF1NO(nLuQG5y4KTJfHd3zjqyTdlv)u98tG6rRpGaDrC9jFnCNLeMq2zGqgbkbCgfPf5kqJ42iC7cuyCC7mkAWTuif3hUT8b8zU1hO(e1Z(61edhe0aQb6GCYZcODhysYBWwFM1ZA9SWs9MRiGnKtE6bK81i8GaoJI01NO(nLuQG5y4KTJfHd3zjqyTdlvFMt1NS6zHL6D(NWTrJgqW0MZ0Q2YpiGZOiD9jQNHdcAS5Lyo1goOGMCdzWLwFI63usPcMJHt2oweoCNLaH1oSu9zovp)QNN6D(NWTrdgLRPqdcgcfwexFY3bbCgfPRNncupA9beOlIRp5RH7SKWeYYkSeYiqjGZOiTixbAe3gHBxGUPKsfmhdNSTE(MQNF1Zt9SVEgoiOrkMKiDBU1hyWLwplSupdhe0WqOa(mJadU06zHL6XCac6WWPHN1DCVH94ubiSdxIa2GMnUonL01NO(4b0CTn0eLs4G2HdNW7a7GS1Z3u9jN6zJa1JwFab6IWH7SeiS2HLeMqwwzviJaLaoJI0ICfOrCBeUDbQMy4GGgqnqhKtEwaT7atsEd26ZCQEwRNfwQpENsFYbJnVeZP2Wbf0KBidmj5nyRpZ6zDwRpr9AIHdcAa1aDqo5zb0Udmj5nyRpZ6J3P0NCWyZlXCQnCqbn5gYatsEdwbQhT(ac0fX1N81WDwsyczznjHmcuc4mkslYvGcD4aGyBtilRcupA9beOP3PcyApoCKeMqww5NqgbkbCgfPf5kqJ42iC7cugoiOrkHHoSBKoad1GDSMhZwpFt1NX6tuF8aAU2gPeg6WUr6amud2b2bzRNVP6zLFcupA9beOWv3jXOCnjmHSSMmHmcupA9beOlIRp5RH7SKaLaoJI0ICfMWeO0UeisRqgHSSkKrGsaNrrArUc0iUnc3UaLaegE(H1suWUGKZ21Zx9SwFI6zx9mCqqJnVeZP2Wbf0KBidU06tup7RND1RpBepqKag2nshGuUefy4WGH1XSnaE9jQND17rRpWiEGibmSBKoaPCjA0GaKQHJy1Zcl1dXPubmfrCmCkyTevFM1dpQhsoBxpBeOE06diqJhisad7gPdqkxIeMq2KeYiqjGZOiTixbAe3gHBxGYU6J3P0NCWyrC9jpWOCnTdU06tuF8oL(KdgBEjMtTHdkOj3qgCP1Zcl1d1WrSaMK8gS1N5u9SclbQhT(acug1D6WbfmekqaskVWeYYpHmcupA9beOW5CSUDq4Gco)t4ZqeOeWzuKwKRWeYMmHmcuc4mkslYvGgXTr42fOSV(nLuQG5y4KTJfHd3zjqyTdlvpFt1Nu9SWs9yV1bcgcydxR3rdQNV6HnyvpBQpr9SR(4Dk9jhm28smNAdhuqtUHm4sRpr9SREgoiOXMxI5uB4GcAYnKbxA9jQNaegE(HMG6yB1Z3u98dwcupA9beOqxKBjDW5Fc3gfyixsyczZOqgbkbCgfPf5kqJ42iC7c0nLuQG5y4KTJfHd3zjqyTdlvpFt1Nu9SWs9yV1bcgcydxR3rdQNV6Hnyjq9O1hqGMYHBO8naEGr5RjmHSWMqgbkbCgfPf5kqJ42iC7cugoiObMIzv0UbOdhPbxA9SWs9mCqqdmfZQODdqhosH4XbmcpwZJzRpZ6zfwcupA9beOgcf4amhhqhGoCKeMq2KJqgbQhT(acuCNMQOqdcBQhjbkbCgfPf5kmHSZQqgbkbCgfPf5kqJ42iC7c04Dk9jhm28smNAdhuqtUHmWKK3GT(mRpJ1Zcl1d1WrSaMK8gS1Nz9SoRcupA9beOYpSsdd1GaM2d4GijmHSZaHmcuc4mkslYvGgXTr42fOeGWWZxFM1NmyvFI6z4GGgBEjMtTHdkOj3qgCPcupA9beOsK0HZhoOGIl26GgtU0kmHSSclHmcuc4mkslYvGgXTr42fOqnCelGjjVbB9zwpRJmwplSup7RN91BogozdeYvgYinA1Zx9ZkSQNfwQ3CmCYgiKRmKrA0QpZP6tcw1ZM6tup7R3Jwddfiaj10w)u9SwplSupudhXcysYBWwpF1N0mOE2upBQNfwQN91BogozdRLOGDH0Ofscw1Zx98dw1NOE2xVhTggkqasQPT(P6zTEwyPEOgoIfWKK3GTE(QpzjRE2upBeOE06diqXKN2a4biLlrRWeMavtqoNYeYiKLvHmcupA9beOz7ywbkbCgfPf5kmHSjjKrGsaNrrArUc0lvGUKjq9O1hqGcJJBNrrcuyCfhjqz4GGgRQJuWb6GUJ0GlTEwyP(nLuQG5y4KTJfHd3zjqyTdlvpFt1dBcuyCCa4sKaDb6q8a626dimHS8tiJaLaoJI0ICfOE06diqJUsf8O1hiO61eOQETaWLibAuVctiBYeYiqjGZOiTixbAe3gHBxGUg5kdH0dxPeOE06diqXCGGhT(abvVMav1RfaUejqxJCLHqAHjKnJczeOeWzuKwKRanIBJWTlq3usPcMJHt2oweoCNLaH1oSu9zwpSvFI6HA4iwatsEd265REyR(e1ZWbbnwvhPGd0bDhPbMK8gS1Nz9WJ6HKZ21NO(4jXCH0Rb2wpFt1NS6NX6zF9wlr1Nz9ScR6zt9W(6tsG6rRpGaDvDKcoqh0DKeMqwytiJaLaoJI0ICfOxQaDjtG6rRpGafgh3oJIeOW4kosGMI7d3w(a(m36duFI63usPcMJHt2oweoCNLaH1oSu98nvFscuyCCa4sKaLBPqkUpCB5d4ZCRpGWeYMCeYiqjGZOiTixbAe3gHBxGcJJBNrrdULcP4(WTLpGpZT(acupA9beOrxPcE06deu9AcuvVwa4sKaDnYvgsiQxHjKDwfYiqjGZOiTixb6LkqxYeOE06diqHXXTZOibkmUIJeOjLX65PEZveWgW0Wp8GaoJI01d7Rpjyvpp1BUIa2qYxJWHdkSiU(KVdc4mksxpSV(KGv98uV5kcyJfX1N8a0f52bbCgfPRh2xFszSEEQ3CfbSHR8iUT8dc4mksxpSV(KGv98uFszSEyF9SV(nLuQG5y4KTJfHd3zjqyTdlvpFt1NS6zJafghhaUejqxJCLHememTiNslmHSZaHmcuc4mkslYvGgXTr42fOeGWWZp0euhBR(mNQhgh3oJIgRrUYqcgcMwKtPfOE06diqJUsf8O1hiO61eOQETaWLib6AKRmKquVctilRWsiJaLaoJI0ICfOrCBeUDbQZ)eUnAaA4i2gGHaWjhePbbCgfPRpr9SREgoiObOHJyBagcaNCqKgCP1NO(4jXCH0Rb2o0euhBRE(QN16tup7RFtjLkyogoz7yr4WDwcew7Ws1Nz9jvplSupmoUDgfn4wkKI7d3w(a(m36dupBQpr9SV(4Dk9jhm28smNAdhuqtUHmWKK3GT(mNQNF1Zcl1Z(6D(NWTrdqdhX2ameao5GinWoiB98nvFs1NOEgoiOXMxI5uB4GcAYnKbMK8gS1Zx98R(e1ZU6xJCLHq6HRu1NO(4Dk9jhmwexFYdAhePreXXWPnaH9O1hWv1Z3u9WAmdQNn1ZgbQhT(acumxQXHjHjKLvwfYiqjGZOiTixbAe3gHBxGI5ae0HHtdn5gIkFyrC9jFh0SX1PPKU(e1RpBSu627W6y2gaV(e1RpBSu627atsEd26ZCQ(KQpr9XtI5cPxdSTE(MQpjbQhT(ac0ORubpA9bcQEnbQQxlaCjsGc1GEreMqwwtsiJaLaoJI0ICfOrCBeUDbA8KyUq61aBRFQEh0sEeXXWjDiMkq9O1hqGgDLk4rRpqq1Rjqv9AbGlrcuOg0lIWeYYk)eYiqjGZOiTixbAe3gHBxGgpjMlKEnW2HMG6yB1N5u9SwplSupudhXcysYBWwFMt1ZA9jQpEsmxi9AGT1Z3u98tG6rRpGan6kvWJwFGGQxtGQ61caxIeOqnOxeHjKL1KjKrGsaNrrArUc0iUnc3UaDtjLkyogoz7yr4WDwcew7Ws1pvFYQpr9XtI5cPxdSTE(MQpzcupA9beOrxPcE06deu9AcuvVwa4sKafQb9IimHSSMrHmcuc4mkslYvGgXTr42fOeGWWZp0euhBR(mNQhgh3oJIgRrUYqcgcMwKtPfOE06diqJUsf8O1hiO61eOQETaWLibkdxR0ctilRWMqgbkbCgfPf5kqJ42iC7cucqy45hAcQJTvpFt1ZAgRNN6jaHHNFGj4eqG6rRpGa1Xrhqb7WycyctilRjhHmcupA9beOoo6akKYPwsGsaNrrArUctilRZQqgbQhT(acuvdhX2qYfNgUebmbkbCgfPf5kmHSSodeYiq9O1hqGY4WdhuWWDm7kqjGZOiTixHjmbAkMINeJBczeYYQqgbQhT(acupnvLpKE9EabkbCgfPf5kmHSjjKrG6rRpGaDnYvgIaLaoJI0ICfMqw(jKrGsaNrrArUcupA9beOsoolPdqhoOj3qeOPykEsmUfwkEa9kqznJctiBYeYiqjGZOiTixbQhT(ac0v1rk4aDq3rsGgXTr42fOycctlIZOibAkMINeJBHLIhqVcuwfMq2mkKrGsaNrrArUc0iUnc3UafZbiOddNgsooB4GcgcfK81iCW313TbdA2460uslq9O1hqGUiU(KhyuUMwHjKf2eYiqjGZOiTixbkWLibQZ)lIJ9naDalCqH0toHfOE06diqD(FrCSVbOdyHdkKEYjSWeMafQb9IiKrilRczeOeWzuKwKRanIBJWTlq3usPcMJHt2oweoCNLaH1oSu9zwpSvFI6zx9mCqqJfX1N8G2brAWLwFI6z4GGgRQJuWb6GUJ0atsEd26ZSEOgoIfWKK3GT(e1ZWbbnwvhPGd0bDhPbMK8gS1Nz9SVEwRNN6JNeZfsVgyB9SPEyF9SoMvbQhT(ac0v1rk4aDq3rsycztsiJaLaoJI0ICfOxQaDjtG6rRpGafgh3oJIeOW4kosGk5Rr4GVRVBdcysYBWwpF1dR6zHL6zx9MRiGnanCeBnxLLWdc4mksxFI6nxraBODC2WI46t(GaoJI01NOEgoiOXI46tEq7Gin4sRNfwQFtjLkyogoz7yr4WDwcew7Ws1Z3u9WMafghhaUejq3SDAaZLACysycz5NqgbkbCgfPf5kqJ42iC7cu2vpmoUDgfn2SDAaZLACyQ(e1BogozdRLOGDbDt1pJ1JjjVbB98vpSvFI6XeeMweNrrcupA9beOyUuJdtctiBYeYiq9O1hqGUuetwWOicONnosGsaNrrArUctiBgfYiqjGZOiTixbQhT(acumxQXHjbAe3gHBxGYU6HXXTZOOXMTtdyUuJdt1NOE2vpmoUDgfn4wkKI7d3w(a(m36duFI63usPcMJHt2oweoCNLaH1oSu98nvFs1NOEZXWjByTefSlOBQE(MQN91NX65PE2xFs1d7RpEsmxi9AGT1ZM6zt9jQhtqyArCgfjqJ5JkkyogozRqwwfMqwytiJaLaoJI0ICfOrCBeUDbk7Qhgh3oJIgB2onG5snomvFI6XKK3GT(mRpENsFYbJnVeZP2Wbf0KBidmj5nyRNN6zfw1NO(4Dk9jhm28smNAdhuqtUHmWKK3GT(mNQpJ1NOEZXWjByTefSlOBQ(zSEmj5nyRNV6J3P0NCWyZlXCQnCqbn5gYatsEd265P(mkq9O1hqGI5snomjmHSjhHmcuc4mkslYvGgXTr42fOSREyCC7mkAWTuif3hUT8b8zU1hO(e1VPKsfmhdNSTE(MQNFcupA9beOmkpMnKEY1ewyczNvHmcupA9beOem9gjSBKaLaoJI0ICfMWeOr9kKrilRczeOeWzuKwKRanIBJWTlqzx9mCqqJfX1N8G2brAWLwFI6z4GGglchUZsGGDyGRVbxA9jQNHdcASiC4olbc2HbU(gysYBWwFMt1ZVrgfOE06diqxexFYdAhejbk3sHdckapQfYYQWeYMKqgbkbCgfPf5kqJ42iC7cugoiOXIWH7Seiyhg46BWLwFI6z4GGglchUZsGGDyGRVbMK8gS1N5u98BKrbQhT(ac0nVeZP2Wbf0KBicuULcheuaEulKLvHjKLFczeOeWzuKwKRanIBJWTlqHXXTZOOXc0H4b0T1hO(e1ZU6xJCLHq6HKdmfjq9O1hqGcPC4Ks5wFaHjKnzczeOeWzuKwKRanIBJWTlq1edhe0as5WjLYT(admj5nyRpZ6tQEwyPEnXWbbnGuoCsPCRpWynpMTE(MQNFWsG6rRpGafs5WjLYT(aHOICWsctiBgfYiqjGZOiTixbAe3gHBxGY(6XCac6WWPHKJZgoOGHqbjFnch8D9DBWGMnUonL01NO(4jXCH0Rb2o0euhBR(mNQNF1Zcl1J5ae0HHtdn5gIkFyrC9jFh0SX1PPKU(e1hpjMlKEnW26ZSEwRNn1NOEgoiOXMxI5uB4GcAYnKbxA9jQNHdcASiU(Kh0oisdU06tuVKVgHd(U(UniGjjVbB9t1dR6tupdhe0qtUHOYhwexFY3H(KdeOE06diqHXb9IimHSWMqgbkbCgfPf5kqJ42iC7cu2v)AKRmespCLQ(e1dJJBNrrJfOdXdOBRpq9SWs90Ueisdgm5gs4Gcgcf05Ba8HKNCD46tuV1su98nvFscupA9beOrxPcE06deu9AcuvVwa4sKaL2LarAfMq2KJqgbkbCgfPf5kq9O1hqGMENkGP94WrsGgXTr42fOMRiGnweoCNLab7WaxFdc4mksxFI6zx9MRiGnwexFYdqxKBheWzuKwGcD4aGyBtilRcti7SkKrGsaNrrArUc0iUnc3UaLaegE(65BQEydw1NOEyCC7mkASaDiEaDB9bQpr9X7u6toyS5Lyo1goOGMCdzWLwFI6J3P0NCWyrC9jpODqKgrehdN265BQEwfOE06diqxeoCNLab7WaxFcti7mqiJaLaoJI0ICfOE06diqxcJDJ0bMdqHnTZsc0iUnc3Uafgh3oJIglqhIhq3wFG6tup7QxF2yjm2nshyoaf20olf0NnSoMTbWRpr9MJHt2WAjkyxq3u98nvFsSwplSupudhXcysYBWwFMt1NX6tu)MskvWCmCY2XIWH7SeiS2HLQpZ65NanMpQOG5y4KTczzvyczzfwczeOeWzuKwKRanIBJWTlqHXXTZOOXc0H4b0T1hO(e1ZU6J3P0NCWyrC9jpWOCnTdU06tup7R3CfbSbbGHuxAdGhwexFY3bbCgfPRNfwQpENsFYbJfX1N8G2brAerCmCARNVP6zTE2uFI6zF9SREZveWglchUZsGGDyGRVbbCgfPRNfwQ3CfbSXI46tEa6IC7GaoJI01Zcl1hVtPp5GXIWH7Seiyhg46BGjjVbB98vFs1ZM6tup7RND1t7sGinyu3PdhuWqOabiP8djp56W1Zcl1hVtPp5GbJ6oD4GcgcfiajLFGjjVbB98vFs1ZgbQhT(ac0nVeZP2Wbf0KBictilRSkKrGsaNrrArUcupA9beOsoolPdqhoOj3qeOrCBeUDbk2BDGGHa2W16DWLwFI6zF9MJHt2WAjkyxq3u9zwF8KyUq61aBhAcQJTvplSup7QFnYvgcPhUsvFI6JNeZfsVgy7qtqDST65BQ(yAqYz7WMsaD9SrGgZhvuWCmCYwHSSkmHSSMKqgbkbCgfPf5kqJ42iC7cuS36abdbSHR17Ob1Zx98dw1pJ1J9whiyiGnCTEhAoSB9bQpr9XtI5cPxdSDOjOo2w98nvFmni5SDytjGwG6rRpGavYXzjDa6Wbn5gIWeYYk)eYiqjGZOiTixbAe3gHBxGcJJBNrrJfOdXdOBRpq9jQpEsmxi9AGTdnb1X2QNVP6tsG6rRpGaDrC9jpWOCnTctilRjtiJaLaoJI0ICfOrCBeUDbkmoUDgfnwGoepGUT(a1NO(4jXCH0Rb2o0euhBRE(MQNF1NO(nLuQG5y4KTJfHd3zjqyTdlvFMt1NmbQhT(acukICnaEatP4wYbAHjKL1mkKrGsaNrrArUc0iUnc3Ua1CfbSXI46tEa6IC7GaoJI01NOEyCC7mkASaDiEaDB9bQpr9mCqqJnVeZP2Wbf0KBidUubQhT(ac0fHd3zjqWomW1NWeYYkSjKrGsaNrrArUc0iUnc3UaLD1ZWbbnwexFYdAhePbxA9jQhQHJybmj5nyRpZP6N165PEZveWglhJryio40GaoJI0cupA9beOlIRp5bTdIKWeYYAYriJa1JwFabA6z9beOeWzuKwKRWeYY6SkKrGsaNrrArUc0iUnc3UaLHdcAS5Lyo1goOGMCdzWLkq9O1hqGYOUthG4W5fMqwwNbczeOeWzuKwKRanIBJWTlqz4GGgBEjMtTHdkOj3qgCPcupA9beOmeEjC2gaxycztcwczeOeWzuKwKRanIBJWTlqz4GGgBEjMtTHdkOj3qgCPcupA9beOqnMyu3PfMq2KyviJaLaoJI0ICfOrCBeUDbkdhe0yZlXCQnCqbn5gYGlvG6rRpGa1brAnSRcrxPeMq2KssiJaLaoJI0ICfOE06diqJ5JQZWhOJbgLVManIBJWTlqzx9RrUYqi9WvQ6tupmoUDgfnwGoepGUT(a1NOE2vpdhe0yZlXCQnCqbn5gYGlT(e1tacdp)qtqDST65BQE(blbkbbrrlaCjsGgZhvNHpqhdmkFnHjKnj(jKrGsaNrrArUcupA9beOo)Vio23a0bSWbfsp5ewGgXTr42fOSREgoiOXI46tEq7Gin4sRpr9X7u6toyS5Lyo1goOGMCdzGjjVbB9zwpRWsGcCjsG68)I4yFdqhWchui9KtyHjKnPKjKrGsaNrrArUcupA9beO(IaJdOnGD()WH4HDLanIBJWTlq1edhe0a78)HdXd7QGMy4GGg6toOEwyPEnXWbbnIhqZfTggk0GSbnXWbbn4sRpr9MJHt2aHCLHmsJw9zwp)sQ(e1BogozdeYvgYinA1Z3u98dw1Zcl1ZU61edhe0iEanx0AyOqdYg0edhe0GlT(e1Z(61edhe0a78)HdXd7QGMy4GGgR5XS1Z3u9jLX6NX6zfw1d7RxtmCqqdg1D6Wbfmekqask)GlTEwyPEOgoIfWKK3GT(mRpzWQE2uFI6z4GGgBEjMtTHdkOj3qgysYBWwpF1pRcuGlrcuFrGXb0gWo)F4q8WUsycztkJczeOeWzuKwKRaf4sKavkV23G5QELCGa1JwFabQuETVbZv9k5aHjKnjytiJaLaoJI0ICfOrCBeUDbkdhe0yZlXCQnCqbn5gYGlTEwyPEOgoIfWKK3GT(mRpjyjq9O1hqGYTuOnsAfMWeORrUYqcr9kKrilRczeOeWzuKwKRa9sfOlzcupA9beOW442zuKafgxXrc04Dk9jhmwexFYdAhePreXXWPnaH9O1hWv1Z3u9SosozuGcJJdaxIeOlIoyiyAroLwycztsiJaLaoJI0ICfOrCBeUDbk7RND1dJJBNrrJfrhmemTiNsxplSup7Q3CfbSbOHJyR5QSeEqaNrr66tuV5kcydTJZgwexFYheWzuKUE2uFI6JNeZfsVgy7qtqDST65REwRpr9SREmhGGomCAi54SHdkyiuqYxJWbFxF3gmOzJRttjTa1JwFabkmoOxeHjKLFczeOE06diqxkD7vGsaNrrArUctiBYeYiqjGZOiTixbQhT(ac007ubmThhoscuITnShCPJdyc0Kblbk0HdaITnHSSkmHSzuiJaLaoJI0ICfOrCBeUDbkbim881Z3u9jdw1NOEcqy45hAcQJTvpFt1ZkSQpr9SREyCC7mkASi6GHGPf5u66tuF8KyUq61aBhAcQJTvpF1ZA9jQxtmCqqdOgOdYjplG2DGjjVbB9zwpRcupA9beOlIRp5sKslmHSWMqgbkbCgfPf5kqVub6sMa1JwFabkmoUDgfjqHXvCKanEsmxi9AGTdnb1X2QNVP6tMafghhaUejqxeDiEsmxi9AGTctiBYriJaLaoJI0ICfOxQaDjtG6rRpGafgh3oJIeOW4kosGgpjMlKEnW2HMG6yB1N5u9SkqJ42iC7cuyCC7mkAWTuif3hUT8b8zU1hqGcJJdaxIeOlIoepjMlKEnWwHjKDwfYiqjGZOiTixbAe3gHBxGcJJBNrrJfrhINeZfsVgyB9jQN91dJJBNrrJfrhmemTiNsxplSupdhe0yZlXCQnCqbn5gYatsEd265BQEwhjvplSu)MskvWCmCY2XIWH7SeiS2HLQNVP6tw9jQpENsFYbJnVeZP2Wbf0KBidmj5nyRNV6zfw1ZgbQhT(ac0fX1N8G2brsyczNbczeOeWzuKwKRanIBJWTlqHXXTZOOXIOdXtI5cPxdST(e1d1WrSaMK8gS1Nz9X7u6toyS5Lyo1goOGMCdzGjjVbRa1JwFab6I46tEq7GijmHjqz4ALwiJqwwfYiqjGZOiTixbAe3gHBxGYU6nxraBaA4i2AUklHheWzuKU(e1J5ae0HHtdRb5d2X2DmWOCnnOzJRttjTa1JwFab6I0WimHSjjKrGsaNrrArUc0iUnc3UaDtjLkyogozB98nvFs1Zt9SVEZveWgWv3jXOCnniGZOiD9jQ35Fc3gnsjm0HDJgyhKTE(MQpP6zJa1JwFab6IWH7SeiS2HLeMqw(jKrGsaNrrArUc0iUnc3UanENsFYbJLWy3iDG5auyt7S0iI4y40gGWE06d4Q65BQ(KgjNmkq9O1hqGUeg7gPdmhGcBANLeMq2KjKrG6rRpGafU6ojgLRjbkbCgfPf5kmHSzuiJa1JwFabkJhZUMZiqjGZOiTixHjmHjqHHWBFaHSjbRKGfRWkPKjqL7yqdGVc0ziBfBrw(lzNLWFuF9YGq13sPh2Qh6W1plZW1k9SC9yA24AmPRFpjQENZoj3iD9rehaN2rnNTEdO6tI)OE2cjDWq66tVTT(abgpMT(icfZwp7bNvVdJ3kNrr13G6jjoLB9byt9SNv2MnJAEnN)sk9WgPRFwR3JwFG6v9A7OMlqtXhuRibAgQhLJXuKLVE2YbNJQ5zOE2Ar7yiC9jbB8wFsWkjyvZR5zO(zhtZyYFsmUvZ9O1hyhPykEsmUXZuoEAQkFi969a1CpA9b2rkMINeJB8mLZAKRmKAUhT(a7iftXtIXnEMYrYXzjDa6Wbn5gcVPykEsmUfwkEa9oXAgR5E06dSJumfpjg34zkNv1rk4aDq3rI3umfpjg3clfpGENyL3gActqyArCgfvZ9O1hyhPykEsmUXZuolIRp5bgLRPL3gAcZbiOddNgsooB4GcgcfK81iCW313TbdA2460usxZ9O1hyhPykEsmUXZuoClfAJK4f4s0KZ)lIJ9naDalCqH0toHR518mup)T3G6zlN5wFGAUhT(a7u2oMTM7rRpWYZuoW442zueVaxIMwGoepGUT(a8cJR4OjgoiOXQ6ifCGoO7in4szHLnLuQG5y4KTJfHd3zjqyTdlX3eSX7SyjD92vVMmcl1aQE5iKHq46J3P0NCWwVCVT6HoC9OGzwpJVKU(duV5y4KTJAEgQp5rOy26t(zU17w9qnETAUhT(alpt5eDLk4rRpqq1RXlWLOPOER5zOE2chOEioLkF9R82Ii0wVD1Biu9Og5kdH01ZwoZT(a1ZEM81RVgaV(94TT6HoCK26tVt1a413q1dodPbWRV36Dy8w5mkInJAUhT(alpt5G5abpA9bcQEnEbUenTg5kdH082qtRrUYqi9WvQAEgQNTknvLV(v1rk4aDq3rQE3QpjEQp5N961C4gaVEdHQhQXRvpRWQ(LIhqV86qgHR3qCR(KXt9j)SxFdvFB1tSDAJPTE5TH0G6neQEaX2w9Zss(zw)HRV36bNvpxAn3JwFGLNPCwvhPGd0bDhjEBOPnLuQG5y4KTJfHd3zjqyTdlLjSLaQHJybmj5ny5d2sWWbbnwvhPGd0bDhPbMK8gSzcpQhsoBNiEsmxi9AGT8nLSzK9wlrzYkSydSpPAEgQNTgqLV(iIdGt1JpZT(a13q1lNQhXHHQpf3hUT8b8zU1hO(LS6DGUEjoL1PkQEZXWjBRNlDuZ9O1hy5zkhyCC7mkIxGlrtClfsX9HBlFaFMB9b4fgxXrtP4(WTLpGpZT(aj2usPcMJHt2oweoCNLaH1oSeFtjvZZq9ZoUpCB5RNTCMB9bMLQE26KnlV1dVHHQ3RpI906DMJZQNaegE(6HoC9gcv)AKRmK6t(zU1ZEgUwPjC9R1kv9yAtPOvFBSzuFYTCP82w9rhupdvVH4w9BlLQOrn3JwFGLNPCIUsf8O1hiO614f4s00AKRmKquV82qtW442zu0GBPqkUpCB5d4ZCRpqnpd1plwsxVD1RjOgq1lhHa1Bx9Clv)AKRmK6t(zU1F46z4ALMWBn3JwFGLNPCGXXTZOiEbUenTg5kdjyiyAroLMxyCfhnLug5XCfbSbmn8dpiGZOinSpjyXJ5kcydjFnchoOWI46t(oiGZOinSpjyXJ5kcyJfX1N8a0f52bbCgfPH9jLrEmxraB4kpIBl)GaoJI0W(KGfpjLryp73usPcMJHt2oweoCNLaH1oSeFtjJn18muFYFGT1eUEUTbWR3Rh1ixzi1N8ZSE5ieOEm5rKgaVEdHQNaegE(6nemTiNsxZ9O1hy5zkNORubpA9bcQEnEbUenTg5kdje1lVn0ebim88dnb1X2YCcgh3oJIgRrUYqcgcMwKtPR5zOEzB4i2S8wp)jbGtois8h1Zw4snomvpdbDyQE08smNAR3T6vN86t(zVE7QpEsmnGQNCSkF9ycctls9YBdPE4KznaE9gcvpdheu9CPJ6zRu7vV6KxFYp71R5WnaE9O5Lyo1wpdzYjcu)mDqK26L3gs9jXt9YYFoQ5E06dS8mLdMl14WeVn0KZ)eUnAaA4i2gGHaWjhePbbCgfPtWogoiObOHJyBagcaNCqKgCPjINeZfsVgy7qtqDSn(ynb73usPcMJHt2oweoCNLaH1oSuMjXclW442zu0GBPqkUpCB5d4ZCRpaBsW(4Dk9jhm28smNAdhuqtUHmWKK3GnZj(XclS35Fc3gnanCeBdWqa4KdI0a7GS8nLucgoiOXMxI5uB4GcAYnKbMK8gS8XVeSBnYvgcPhUsLiENsFYbJfX1N8G2brAerCmCAdqypA9bCfFtWAmdydBQ5E06dS8mLt0vQGhT(abvVgVaxIMGAqVi82qtyoabDy40qtUHOYhwexFY3bnBCDAkPtOpBSu627W6y2gapH(SXsPBVdmj5nyZCkPeXtI5cPxdSLVPKQ5E06dS8mLt0vQGhT(abvVgVaxIMGAqVi82qtXtI5cPxdSDYbTKhrCmCshIP18muFg5PE5THu)mrRN9hNTTMQFnYvgcBQ5E06dS8mLt0vQGhT(abvVgVaxIMGAqVi82qtXtI5cPxdSDOjOo2wMtSYclqnCelGjjVbBMtSMiEsmxi9AGT8nXVAEgQh21GErQ3T6tgp1lVnKJZQFMO18mu)mSnK6NjA9UAV6HAqVi17w9jJN6D4EdwREIT9OPYxFYQ3CmCY26z)XzBRP6xJCLHWMAUhT(alpt5eDLk4rRpqq1RXlWLOjOg0lcVn00MskvWCmCY2XIWH7SeiS2HLMswI4jXCH0Rb2Y3uYQ5zO(zXs171ZW1knHRxocbQhtEePbWR3qO6jaHHNVEdbtlYP01CpA9bwEMYj6kvWJwFGGQxJxGlrtmCTsZBdnracdp)qtqDSTmNGXXTZOOXAKRmKGHGPf5u6AEgQNT(jNwR(uCF42YxFdQ3vQ6pO6neQE2QzNTE9mu05wQ(2Qp6ClT171plj5Nzn3JwFGLNPCCC0buWomMagVn0ebim88dnb1X24BI1mYdbim88dmbNa1CpA9bwEMYXXrhqHuo1s1CpA9bwEMYr1WrSnKCXPHlraRM7rRpWYZuomo8WbfmChZU18AEgQp5VtPp5GTMNH6Nflv)mDqKQ)GGMr4rD9me0HP6neQEOgVw9lchUZsGWAhwQEi8jvVmhg46R(4jrB9nyuZ9O1hyhr9YZuolIRp5bTdIeVClfoiOa8OEIvEBOj2XWbbnwexFYdAhePbxAcgoiOXIWH7Seiyhg46BWLMGHdcASiC4olbc2HbU(gysYBWM5e)gzSMNH6z)SaOODR3vyY15RNlTEgk6ClvVCQE7US1JI46tE9WUlYTSPEULQhnVeZP26piOzeEuxpdbDyQEdHQhQXRv)IWH7SeiS2HLQhcFs1lZHbU(QpEs0wFdg1CpA9b2ruV8mLZMxI5uB4GcAYneE5wkCqqb4r9eR82qtmCqqJfHd3zjqWomW13Glnbdhe0yr4WDwceSddC9nWKK3GnZj(nYyn3JwFGDe1lpt5aPC4Ks5wFaEBOjyCC7mkASaDiEaDB9bsWU1ixziKEi5atr1CpA9b2ruV8mLdKYHtkLB9bcrf5GL4THM0edhe0as5WjLYT(admj5nyZmjwyrtmCqqdiLdNuk36dmwZJz5BIFWQM7rRpWoI6LNPCGXb9IWBdnXEmhGGomCAi54SHdkyiuqYxJWbFxF3gmOzJRttjDI4jXCH0Rb2o0euhBlZj(XclyoabDy40qtUHOYhwexFY3bnBCDAkPtepjMlKEnW2mzLnjy4GGgBEjMtTHdkOj3qgCPjy4GGglIRp5bTdI0GlnHKVgHd(U(UniGjjVb7eSsWWbbn0KBiQ8HfX1N8DOp5GAUhT(a7iQxEMYj6kvWJwFGGQxJxGlrt0UeislVn0e7wJCLHq6HRujGXXTZOOXc0H4b0T1hGfwODjqKgmyYnKWbfmekOZ3a4djp56WjSwI4BkPAEgQF2Vtvp0HRxMddC9vFkMMr0BM1lVnK6rrMz9yY15RxocbQhCw9yoaObWRhf2nQ5E06dSJOE5zkN07ubmThhos8cD4aGyBBIvEBOjZveWglchUZsGGDyGRVbbCgfPtWoZveWglIRp5bOlYTdc4mksxZZq9ZILQxMddC9vFkMQh9Mz9Yriq9YP6rCyO6neQEcqy45RxoczieUEi8jvF6DQgaVE5THCCw9OWU6pC9jxCRvpCcqyxPYpQ5E06dSJOE5zkNfHd3zjqWomW1hVn0ebim888nbBWkbmoUDgfnwGoepGUT(ajI3P0NCWyZlXCQnCqbn5gYGlnr8oL(KdglIRp5bTdI0iI4y40Y3eR1CpA9b2ruV8mLZsySBKoWCakSPDwI3y(OIcMJHt2oXkVn0emoUDgfnwGoepGUT(ajyN(SXsySBKoWCakSPDwkOpByDmBdGNWCmCYgwlrb7c6M4BkjwzHfOgoIfWKK3GnZPmMytjLkyogoz7yr4WDwcew7WszYVAEgQFwSu9O5Lyo1w)bQpENsFYb1ZEhYiC9qnET6rbZKn1Zbu0U1lNQ3Xu9WVgaVE7Qp9sRxMddC9vVd01RV6bNvpIddvpkIRp51d7Ui3oQ5E06dSJOE5zkNnVeZP2Wbf0KBi82qtW442zu0yb6q8a626dKGDX7u6toySiU(KhyuUM2bxAc2BUIa2GaWqQlTbWdlIRp57GaoJI0SWs8oL(KdglIRp5bTdI0iI4y40Y3eRSjb7zN5kcyJfHd3zjqWomW13GaoJI0SWI5kcyJfX1N8a0f52bbCgfPzHL4Dk9jhmweoCNLab7WaxFdmj5ny5lj2KG9SJ2LarAWOUthoOGHqbcqs5hsEY1HzHL4Dk9jhmyu3PdhuWqOabiP8dmj5ny5lj2uZZq98xq17A9wVJP65s5T(f0Pu9gcv)bO6L3gs9QtoTw9YiZmh1plwQE5ieOED(gaVEiFncxVH4G6t(zVEnb1X2Q)W1doR(1ixziKUE5THCCw9oiF9j)SpQ5E06dSJOE5zkhjhNL0bOdh0KBi8gZhvuWCmCY2jw5THMWERdemeWgUwVdU0eS3CmCYgwlrb7c6MYmEsmxi9AGTdnb1X2yHf2Tg5kdH0dxPsepjMlKEnW2HMG6yB8nftdsoBh2ucOztnpd1ZFbvp4Q316TE5TsvVUP6L3gsdQ3qO6beBB1ZpyT8wp3s1ZFdnZ6pq9m3U1lVnKJZQ3b5Rp5N9rn3JwFGDe1lpt5i54SKoaD4GMCdH3gAc7ToqWqaB4A9oAaF8dwZi2BDGGHa2W16DO5WU1hir8KyUq61aBhAcQJTX3umni5SDytjGUM7rRpWoI6LNPCwexFYdmkxtlVn0emoUDgfnwGoepGUT(ajINeZfsVgy7qtqDSn(MsQM7rRpWoI6LNPCOiY1a4bmLIBjhO5THMGXXTZOOXc0H4b0T1hir8KyUq61aBhAcQJTX3e)sSPKsfmhdNSDSiC4olbcRDyPmNswnpd1pdBdPEuyhV13q1doRExHjxNVE9biERNBP6L5WaxF1lVnK6rVzwpx6OM7rRpWoI6LNPCweoCNLab7WaxF82qtMRiGnwexFYdqxKBheWzuKobmoUDgfnwGoepGUT(ajy4GGgBEjMtTHdkOj3qgCP1CpA9b2ruV8mLZI46tEq7GiXBdnXogoiOXI46tEq7Gin4sta1WrSaMK8gSzonR8yUIa2y5ymcdXbNgeWzuKUMxZZq9YEGzCtPy9RXbbvV82qQxDYjC9P4(Q5E06dSJOE5zkN0Z6duZ9O1hyhr9YZuomQ70bioCEEBOjgoiOXMxI5uB4GcAYnKbxAn3JwFGDe1lpt5Wq4LWzBaCEBOjgoiOXMxI5uB4GcAYnKbxAn3JwFGDe1lpt5a1yIrDNM3gAIHdcAS5Lyo1goOGMCdzWLwZ9O1hyhr9YZuooisRHDvi6kfVn0edhe0yZlXCQnCqbn5gYGlTMxZ9O1hyhr9YZuoClfAJK4LGGOOfaUenfZhvNHpqhdmkFnEBOj2Tg5kdH0dxPsaJJBNrrJfOdXdOBRpqc2XWbbn28smNAdhuqtUHm4stqacdp)qtqDSn(M4hSQ5E06dSJOE5zkhULcTrs8cCjAY5)fXX(gGoGfoOq6jNW82qtSJHdcASiU(Kh0oisdU0eX7u6toyS5Lyo1goOGMCdzGjjVbBMScRAEgQ)meclVxQE5THup6nZ6DR(KYip1VMhZU1F46znJ8uV82qQ3v7vFUQ701ZLoQ5E06dSJOE5zkhULcTrs8cCjAYxeyCaTbSZ)hoepSR4THM0edhe0a78)HdXd7QGMy4GGg6toGfw0edhe0iEanx0AyOqdYg0edhe0GlnH5y4KnqixziJ0OLj)skH5y4KnqixziJ0OX3e)GflSWonXWbbnIhqZfTggk0GSbnXWbbn4stWEnXWbbnWo)F4q8WUkOjgoiOXAEmlFtjLXzKvyb71edhe0GrDNoCqbdHceGKYp4szHfOgoIfWKK3GnZKbl2KGHdcAS5Lyo1goOGMCdzGjjVblFZAnpd1ZFs481Jpo4iQ81J5uu9hu9gcNetd1KUEj3q26zi1jN)O(zXs1dD465VaztpD9rCB1CpA9b2ruV8mLd3sH2ijEbUenjLx7BWCvVsoOMNH6Njb5CkREixPy8y26HoC9CRZOO6BJKw(J6NflvV82qQhnVeZP26pO6Nj5gYOM7rRpWoI6LNPC4wk0gjT82qtmCqqJnVeZP2Wbf0KBidUuwybQHJybmj5nyZmjyvZR5zOE2k(NWTr1NCZUeisBn3JwFGDq7sGiT8mLt8arcyy3iDas5seVn0ebim88dRLOGDbjNT5J1eSJHdcAS5Lyo1goOGMCdzWLMG9StF2iEGibmSBKoaPCjkWWHbdRJzBa8eSZJwFGr8arcyy3iDas5s0ObbivdhXyHfioLkGPiIJHtbRLOmHh1djNTztn3JwFGDq7sGiT8mLdJ6oD4GcgcfiajLN3gAIDX7u6toySiU(KhyuUM2bxAI4Dk9jhm28smNAdhuqtUHm4szHfOgoIfWKK3GnZjwHvn3JwFGDq7sGiT8mLdCohRBheoOGZ)e(mKAUhT(a7G2LarA5zkhOlYTKo48pHBJcmKlXBdnX(nLuQG5y4KTJfHd3zjqyTdlX3usSWc2BDGGHa2W16D0a(GnyXMeSlENsFYbJnVeZP2Wbf0KBidU0eSJHdcAS5Lyo1goOGMCdzWLMGaegE(HMG6yB8nXpyvZ9O1hyh0Ueislpt5KYHBO8naEGr5RXBdnTPKsfmhdNSDSiC4olbcRDyj(MsIfwWERdemeWgUwVJgWhSbRAUhT(a7G2LarA5zkhdHcCaMJdOdqhos82qtmCqqdmfZQODdqhosdUuwyHHdcAGPywfTBa6WrkepoGr4XAEmBMScRAUhT(a7G2LarA5zkhCNMQOqdcBQhPAUhT(a7G2LarA5zkh5hwPHHAqat7bCqK4THMI3P0NCWyZlXCQnCqbn5gYatsEd2mZilSa1WrSaMK8gSzY6SwZ9O1hyh0Ueislpt5irshoF4GckUyRdAm5slVn0ebim88zMmyLGHdcAS5Lyo1goOGMCdzWLwZZq9j3pLUE2c5PnaE9WoLlrB9qhUEITPiNr1JDaCQ(dxF2wPQNHdcA5T(gQ(0B3MrrJ6zRuY98B9goF92vpCYQ3qO6vNCAT6J3P0NCq9m(s66pq9omERCgfvpbiPM2rn3JwFGDq7sGiT8mLdM80gapaPCjA5THMGA4iwatsEd2mzDKrwyH9S3CmCYgiKRmKrA04BwHflSyogozdeYvgYinAzoLeSytc27rRHHceGKAANyLfwGA4iwatsEdw(sAgWg2WclS3CmCYgwlrb7cPrlKeS4JFWkb79O1WqbcqsnTtSYclqnCelGjjVblFjlzSHn18AEgQh1ixzi1N83P0NCWwZ9O1hyhRrUYqcr9YZuoW442zueVaxIMweDWqW0ICknVW4koAkENsFYbJfX1N8G2brAerCmCAdqypA9bCfFtSosozK3K7KkLW1ZF642zuunpd1ZF6GErQVHQxovVJP6JEAAdGx)bQFMois1hrCmCAh1NCJJv5RNHGomvpuJxRETdIu9nu9YP6rCyO6bx9Y2WrS1CvwcxpdNv)mDC26rrC9jV(gu)H1eUE7Qhoz1Zw4snomvpxA9ShC1ZF7Rr46zR213TbSzuZ9O1hyhRrUYqcr9YZuoW4GEr4THMyp7GXXTZOOXIOdgcMwKtPzHf2zUIa2a0WrS1CvwcpiGZOiDcZveWgAhNnSiU(KpiGZOinBsepjMlKEnW2HMG6yB8XAc2H5ae0HHtdjhNnCqbdHcs(Aeo47672GbnBCDAkPR5E06dSJ1ixziHOE5zkNLs3ER5E06dSJ1ixziHOE5zkN07ubmThhos8cD4aGyBBIvEj22WEWLooGnLmyX7SFNQEOdxpkIRp5sKsxpp1JI46t(A4olvphqr7wVCQEht17mhNvVD1h906pq9Z0brQ(iIJHt7OE2Aav(6LJqG6HDnqx)mK8SaA367TEN54S6TREmhO(JZg1CpA9b2XAKRmKquV8mLZI46tUeP082qteGWWZZ3uYGvccqy45hAcQJTX3eRWkb7GXXTZOOXIOdgcMwKtPtepjMlKEnW2HMG6yB8XAcnXWbbnGAGoiN8SaA3bMK8gSzYAn3JwFGDSg5kdje1lpt5aJJBNrr8cCjAAr0H4jXCH0Rb2YlmUIJMINeZfsVgy7qtqDSn(MsgVj)SxpMMnUgtseW4pQFMois17w9QtE9j)Sxpt(61eKZPSrnpd1N8ZE9yA24AmjraJ)O(z6Giv)bu5RNHGomvpud6fHWB9nu9YP6rCyO6tX9HBlF94ZCRpWOM7rRpWowJCLHeI6LNPCGXXTZOiEbUenTi6q8KyUq61aB5fgxXrtXtI5cPxdSDOjOo2wMtSYBdnbJJBNrrdULcP4(WTLpGpZT(a18mu)mDqKQxZHBa86rZlXCQT(dxVZCWq1BiyAroLEuZ9O1hyhRrUYqcr9YZuolIRp5bTdIeVn0emoUDgfnweDiEsmxi9AGTjypmoUDgfnweDWqW0ICknlSWWbbn28smNAdhuqtUHmWKK3GLVjwhjXclBkPubZXWjBhlchUZsGWAhwIVPKLiENsFYbJnVeZP2Wbf0KBidmj5ny5JvyXMAEgQpxomOEmj5nObWRFMoisB9me0HP6neQEOgoIvpb0B9nu9O3mRx(bMLT6zO6XKRZxFdQ3AjAuZ9O1hyhRrUYqcr9YZuolIRp5bTdIeVn0emoUDgfnweDiEsmxi9AGTjGA4iwatsEd2mJ3P0NCWyZlXCQnCqbn5gYatsEd2AEnpd1JAKRmesxpB5m36duZZq98xq1JAKRmKCGXb9IuVJP65s5TEULQhfX1N81WDwQE7QNHaeuB1dHpP6neQ(uF3ggQEMdWT17aD9WUgORFgsEwaTB9emeO(gQE5u9oMQ3T6LC2U(KF2RN9q4tQEdHQpftXtIXT65VHMjBg1CpA9b2XAKRmesZZuolIRp5RH7SeVn0e7z4GGgRrUYqgCPSWcdhe0agh0lYGlLn18mupSRb9IuVB1ZpEQp5N96L3gYXz1pt06ZP(KXt9YBdP(zIwV82qQhfHd3zjq9YCyGRV6z4GGQNlTE7Q3H5AD97jr1N8ZE9Y91O6324CRpWoQ5E06dSJ1ixziKMNPCIUsf8O1hiO614f4s0eud6fH3gAIHdcASiC4olbc2HbU(gCPjINeZfsVgy7qtqDSTmNsQMNH6zRu7v)6qu92vpud6fPE3Qpz8uFYp71lVnK6j22JMkF9jREZXWjBh1ZEuxIQ336poBBnv)AKRmKbBQ5E06dSJ1ixziKMNPCIUsf8O1hiO614f4s0eud6fH3gAAtjLkyogoz7yr4WDwcew7Wstjlr8KyUq61aB5Bkz18mupSRb9IuVB1NmEQp5N96L3gYXz1ptuERpJ8uV82qQFMO8wVd01dB1lVnK6NjA9oKr465pDqVi1CpA9b2XAKRmesZZuorxPcE06deu9A8cCjAcQb9IWBdnfpjMlKEnW2HMG6yBzoX6mYEZveWgAIsjCynSBoCsAqaNrr6emCqqdyCqVidUu2uZ9O1hyhRrUYqinpt5Sinm82qtMRiGnanCeBnxLLWdc4mksNaZbiOddNgwdYhSJT7yGr5AAqZgxNMs6AEgQh2D46tX0mM6weH36ZsuA9WUgORFgsEwaTB9CP1FG6neQ(uCl5481Bogoz1R5O6TREWvpkIRp51ZF6CkRM7rRpWowJCLHqAEMYzrC9jFnCNL4THMuemKkZmMucnXWbbnGAGoiN8SaA3bMK8gSzYAcZXWjByTefSlOBAgXKK3GLpyRMNH6NfP1Bx98REZXWjBRplrP1ZLwpSRb66NHKNfq7wpt(6J5JQgaVEuexFYxd3zPrn3JwFGDSg5kdH08mLZI46t(A4olXBmFurbZXWjBNyL3gAstmCqqdOgOdYjplG2DGjjVbBMSMytjLkyogoz7yr4WDwcew7WszoXVeMJHt2WAjkyxq30mIjjVblFWwnpd1pdBd54S6NjrPeUEud7MdNKQ3b665x9SfhKDR)GQpxLRP6Bq9gcvpkIRp5B9TvFV1l)Wgs9CBdGxpkIRp5RH7Su9hOE(vV5y4KTJAUhT(a7ynYvgcP5zkNfX1N81WDwI3gAIDMRiGn0eLs4WAy3C4K0GaoJI0jC(NWTrdgLRPqdcgcfwexFY3b2bzN4xInLuQG5y4KTJfHd3zjqyTdlnXVAEgQh2D46tX9HBlF94ZCRpaV1ZTu9OiU(KVgUZs1FWq46rTdlvpRSPE5THu)mK)UEhU3G1QNlTE7Qpz1BogozlV1NeBQVHQh2ndRV36XCaqdGx)bbvp7pq9oiF9U0XbS6pO6nhdNSLn8w)HRNFSPE7QxYz7wQ5FQE0BM1tSTrGTpq9YBdPE(labtBotRAlF9hOE(vV5y4KT1Z(KvV82qQp32qzZOM7rRpWowJCLHqAEMYzrC9jFnCNL4THMGXXTZOOb3sHuCF42YhWN5wFGeSxtmCqqdOgOdYjplG2DGjjVbBMSYclMRiGnKtE6bK81i8GaoJI0j2usPcMJHt2oweoCNLaH1oSuMtjJfwC(NWTrJgqW0MZ0Q2YpiGZOiDcgoiOXMxI5uB4GcAYnKbxAInLuQG5y4KTJfHd3zjqyTdlL5e)4X5Fc3gnyuUMcniyiuyrC9jFheWzuKMn1CpA9b2XAKRmesZZuolchUZsGWAhwI3gAAtjLkyogozlFt8Jh2ZWbbnsXKePBZT(adUuwyHHdcAyiuaFMrGbxklSG5ae0HHtdpR74Ed7XPcqyhUebSbnBCDAkPtepGMRTHMOuch0oC4eEhyhKLVPKdBQ5E06dSJ1ixziKMNPCwexFYxd3zjEBOjnXWbbnGAGoiN8SaA3bMK8gSzoXklSeVtPp5GXMxI5uB4GcAYnKbMK8gSzY6SMqtmCqqdOgOdYjplG2DGjjVbBMX7u6toyS5Lyo1goOGMCdzGjjVbBnpd1JI46t(A4olvVD1JjimTi1d7AGU(zi5zb0U17aD92vpbwomvVCQ(OdQp6yC(6pyiC9E9qCkv9WUzy9nWU6neQEaX2w9O3mRVHQp92Tzu0OM7rRpWowJCLHqAEMYj9ovat7XHJeVqhoai22MyTM7rRpWowJCLHqAEMYbU6ojgLRjEBOjgoiOrkHHoSBKoad1GDSMhZY3ugtepGMRTrkHHoSBKoad1GDGDqw(MyLF1CpA9b2XAKRmesZZuolIRp5RH7SunVMNH6HDnOxecV1CpA9b2bud6fHNPCwvhPGd0bDhjEBOPnLuQG5y4KTJfHd3zjqyTdlLjSLGDmCqqJfX1N8G2brAWLMGHdcASQosbhOd6osdmj5nyZeQHJybmj5nytWWbbnwvhPGd0bDhPbMK8gSzYEw5jEsmxi9AGTSb2Z6ywR5E06dSdOg0lcpt5aJJBNrr8cCjAAZ2PbmxQXHjEHXvC0KKVgHd(U(UniGjjVblFWIfwyN5kcydqdhXwZvzj8GaoJI0jmxraBODC2WI46t(GaoJI0jy4GGglIRp5bTdI0GlLfw2usPcMJHt2oweoCNLaH1oSeFtWgVj3jvkHRN)0XTZOO6HoC9SfUuJdtJ6rZ2P1R5WnaE983(AeUE2QD9DBq9hUEnhUbWRFMois1lVnK6NPJZwVd01dU6LTHJyR5QSeEuZZq9ZstuA9CP1Zw4snomvFdvFB13B9oZXz1Bx9yoq9hNnQ5E06dSdOg0lcpt5G5snomXBdnXoyCC7mkASz70aMl14WucZXWjByTefSlOBAgXKK3GLpylbMGW0I4mkQM7rRpWoGAqVi8mLZsrmzbJIiGE24OAEgQN)MtzT(mRbWR3CmCY26ne3QxERu1RAyO6HoC9gcvVMd7wFG6pO6zlCPghMQhtqyArQxZHBa86tDGMK64OM7rRpWoGAqVi8mLdMl14WeVX8rffmhdNSDIvEBOj2bJJBNrrJnBNgWCPghMsWoyCC7mkAWTuif3hUT8b8zU1hiXMskvWCmCY2XIWH7SeiS2HL4BkPeMJHt2WAjkyxq3eFtSpJ8W(KG9XtI5cPxdSLnSjbMGW0I4mkQMNH6zleeMwK6zlCPghMQNCSkF9nu9TvV8wPQNy70gt1R5WnaE9O5Lyo1oQFMx9gIB1JjimTi13q1JEZSE4KT1JjxNV(guVHq1di22QpJ7OM7rRpWoGAqVi8mLdMl14WeVn0e7GXXTZOOXMTtdyUuJdtjWKK3GnZ4Dk9jhm28smNAdhuqtUHmWKK3GLhwHvI4Dk9jhm28smNAdhuqtUHmWKK3GnZPmMWCmCYgwlrb7c6MMrmj5ny5lENsFYbJnVeZP2Wbf0KBidmj5ny5jJ1CpA9b2bud6fHNPCyuEmBi9KRjmVn0e7GXXTZOOb3sHuCF42YhWN5wFGeBkPubZXWjB5BIF1CpA9b2bud6fHNPCiy6nsy3OAEnpd1NlxR0eER5E06dSdgUwPNwKggEBOj2zUIa2a0WrS1CvwcpiGZOiDcmhGGomCAyniFWo2UJbgLRPbnBCDAkPR5E06dSdgUwP5zkNfHd3zjqyTdlXBdnTPKsfmhdNSLVPK4H9MRiGnGRUtIr5AAqaNrr6eo)t42OrkHHoSB0a7GS8nLuI0BBRpqGXJzztn3JwFGDWW1knpt5Seg7gPdmhGcBANL4THMI3P0NCWyjm2nshyoaf20olnIiogoTbiShT(aUIVPKgjNmwZ9O1hyhmCTsZZuoWv3jXOCnvZ9O1hyhmCTsZZuomEm7AoJaDtPOq2KGnwfMWeca]] )


end
