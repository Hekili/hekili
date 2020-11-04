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


    spec:RegisterPack( "Subtlety", 20201103, [[dafH0bqiuQ8iQsztufFcuQYOqPQtHsXQqvjEfQIzHQ0Tuuu7su)sbzyGsogkPLPaEgQkMgvjDnQs12qPuFJQemofLY5uuqRtrPY8uGUNISpuv9pffk6GkkvTqfupKQenrfLCrffkSrqPYhrvjPrQOqPtckv1kvu9suvsWmvuO6MuLq2jrXprvjrdfukwkOu6PqAQeLUQIczROQK6RkkWzrvjH2lH)sLbRQdtzXO4XImzsDzKndYNbvJgItl1QPkH61kKztYTjYUb(TkdNQ64kkYYH65knDHRJkBhu8DIQXJsjNxHA9OQuZhLy)swWQqwbQ2csiZaWAayXkRWIp5b4J3NHS6feOXyFsG6BPrgCsGcmjsGIYXekkglq9TXQZ0czfO7XHtKafjc)D2n0qW7aHJjNoPH2wItzrFGe2GIH2wknKaLHRvbSpqWiq1wqczgawdalwzfw8jpaF8(mKv(iqnUa5Wcu0wYlfOiTwtabJavtBsG6T6r5ycffJRh2EW5OAU3QxMdgsIHW1ZhERFaynaSeOQEJviRaDdYubcPfYkKHvHScucymkslgwGMWDq42eOSVEgoiO8gKPcKmNF9SWs9mCqqzymqVizo)6zJa1srFab6Iy6t(g4EejcHmdiKvGsaJrrAXWc0eUdc3MaLHdckViC4EebCXHbM(YC(17P(0jXCo)RbXM1euN6O(bNQFabQLI(ac0KPuolf9bCQEdbQQ3WbmjsGc1GEreHqg(iKvGsaJrrAXWc0eUdc3MaD9jLYfggofBEr4W9ic424Ws1pvVxR3t9PtI5C(xdITE(NQ3Rculf9beOjtPCwk6d4u9gcuvVHdysKafQb9IicHmEviRaLagJI0IHfOjCheUnbA6KyoN)1GyZAcQtDu)Gt1ZA9ZC9SV(WueiYAI8jSBdSfgCsktaJrr669updheuggd0lsMZVE2iqTu0hqGMmLYzPOpGt1Biqv9goGjrcuOg0lIieY4DHScucymkslgwGMWDq42eOHPiqKbnCKydtnIWzcymksxVN6XCac6WWPC0GXU4yRo5yuMMY0mX1((KwGAPOpGaDrAyeHqg2wiRaLagJI0IHfOjCheUnbQIGHu1py9EFG69uVMy4GGYqnq7Kt2iaTBgtswd26hSEwR3t9HHHtroAjYfNt3u9ZC9ysYAWwp)1Z2culf9beOlIPp5BG7rKieY4feYkqjGXOiTyybQLI(ac0fX0N8nW9isGMWDq42eOAIHdckd1aTtozJa0UzmjznyRFW6zTEp1V(Ks5cddNInViC4EebCBCyP6hCQE(uVN6dddNIC0sKloNUP6N56XKK1GTE(RNTfOPXjf5cddNIvidRIqiZSjKvGsaJrrAXWc0eUdc3MaLD1hMIarwtKpHDBGTWGtszcymksxVN6n(MWDqzgLPjxdCbc5wetFY3m2aJQFQE(uVN6xFsPCHHHtXMxeoCpIaUnoSu9t1ZhbQLI(ac0fX0N8nW9iseczMHczfOeWyuKwmSanH7GWTjqHXWTXOOm3soFCF4og7WxyrFG69up7RxtmCqqzOgODYjBeG2nJjjRbB9dwpR1Zcl1hMIarwoz(hqY2GWzcymksxVN6xFsPCHHHtXMxeoCpIaUnoSu9dovVxRNfwQ34Bc3bLBabthgtR6yCMagJI017PEgoiO8owI5uR7GCAYcKmNF9EQF9jLYfggofBEr4W9ic424Ws1p4u98PEEQ34Bc3bLzuMMCnWfiKBrm9jFZeWyuKUE2iqTu0hqGUiM(KVbUhrIqidRWsiRaLagJI0IHfOjCheUnb66tkLlmmCk265FQE(upp1Z(6z4GGY(ysI0DyrFGmNF9SWs9mCqq5aHC4lccK58RNfwQhZbiOddNY2iZW962Jt5GWgCjcezAM4AFFsxVN6thqZ1rwtKpHDAdoCcVzSbgvp)t17fQNnculf9beOlchUhra3ghwseczyLvHScucymkslgwGMWDq42eOAIHdckd1aTtozJa0UzmjznyRFWP6zTEwyP(0Dk9jhK3XsmNADhKttwGKXKK1GT(bRN1zREp1RjgoiOmud0o5Kncq7MXKK1GT(bRpDNsFYb5DSeZPw3b50KfizmjznyfOwk6diqxetFY3a3JiriKH1beYkqjGXOiTyybk0HDaITcHmSkqTu0hqG6FNYHP94WjseczyLpczfOeWyuKwmSanH7GWTjqz4GGY(eg6WwqAhmud28gwAu98pvV3R3t9PdO56i7tyOdBbPDWqnyZydmQE(NQNv(iqTu0hqGcxDNeJY0KieYWQxfYkqTu0hqGUiM(KVbUhrcucymkslgweIqGs7sGeTczfYWQqwbkbmgfPfdlqt4oiCBcucqy4JZrlrU4CsgBvp)1ZA9EQND1ZWbbL3XsmNADhKttwGK58R3t9SVE2vV(IC6ajceyliTdszsKJHddYrNg1a417PE2vVLI(a50bseiWwqAhKYKOCdCqQgosuplSupeNs5WucXWWjx0su9dwp8KolzSv9SrGAPOpGanDGebcSfK2bPmjseczgqiRaLagJI0IHfOjCheUnbk7QpDNsFYb5fX0NChJY00M58R3t9P7u6toiVJLyo16oiNMSajZ5xplSupudhjCysYAWw)Gt1ZkSeOwk6diqzu3PDhKlqihbiPXIqidFeYkqTu0hqGcNZW62aUdYz8nHVarGsaJrrAXWIqiJxfYkqjGXOiTyybAc3bHBtGY(6xFsPCHHHtXMxeoCpIaUnoSu98pv)a1Zcl1JTw7iyiqKnTEZnOE(RNTHv9SPEp1ZU6t3P0NCqEhlXCQ1DqonzbsMZVEp1ZU6z4GGY7yjMtTUdYPjlqYC(17PEcqy4JZAcQtDup)t1ZhyjqTu0hqGcDjUL0oJVjChKJHmjriKX7czfOeWyuKwmSanH7GWTjqxFsPCHHHtXMxeoCpIaUnoSu98pv)a1Zcl1JTw7iyiqKnTEZnOE(RNTHLa1srFabQphUHg3a4ogLTHieYW2czfOeWyuKwmSanH7GWTjqz4GGYyknsr76GoCIYC(1Zcl1ZWbbLXuAKI21bD4e5shhiiCEdlnQ(bRNvyjqTu0hqGgiKJdWCCaTd6Wjsecz8cczfOwk6diqXTVVICnWT(wIeOeWyuKwmSieYmBczfOeWyuKwmSanH7GWTjqt3P0NCqEhlXCQ1Dqonzbsgtswd26hSEVxplSupudhjCysYAWw)G1Z6SjqTu0hqGk)WknmudCyApGbsKieYmdfYkqjGXOiTyybAc3bHBtGsacdFC9dwVxHv9EQNHdckVJLyo16oiNMSajZ5lqTu0hqGkrshES7GCkUuRDAmzsRieYWkSeYkqjGXOiTyybAc3bHBtGc1WrchMKSgS1py9SM9E9SWs9SVE2xFyy4uKritfiz)uup)1pBWQEwyP(WWWPiJqMkqY(PO(bNQFayvpBQ3t9SVElfnmKJaKutB9t1ZA9SWs9qnCKWHjjRbB98x)aZW6zt9SPEwyPE2xFyy4uKJwICX58tHBayvp)1ZhyvVN6zF9wkAyihbiPM26NQN16zHL6HA4iHdtswd265VEV616zt9SrGAPOpGaftMFdG7GuMeTIqecunbzCQqiRqgwfYkqTu0hqGoQtJeOeWyuKwmSieYmGqwbkbmgfPfdlqpFb6sHa1srFabkmgUngfjqHXuCKaLHdckVQorodOD6orzo)6zHL6xFsPCHHHtXMxeoCpIaUnoSu98pvpBlqHXWoGjrc0fODPdO7OpGieYWhHScucymkslgwGAPOpGanzkLZsrFaNQ3qGQ6nCatIeOj9kcHmEviRaLagJI0IHfOjCheUnb6gKPcesNnLsGAPOpGafZbCwk6d4u9gcuvVHdysKaDdYubcPfHqgVlKvGsaJrrAXWc0eUdc3MaD9jLYfggofBEr4W9ic424Ws1py9SD9EQhQHJeomjznyRN)6z769updheuEvDICgq70DIYysYAWw)G1dpPZsgBvVN6tNeZ58VgeB98pvVxRFMRN91hTev)G1ZkSQNn1ZxQFabQLI(ac0v1jYzaTt3jseczyBHScucymkslgwGE(c0LcbQLI(acuymCBmksGcJP4ibQpUpChJD4lSOpq9EQF9jLYfggofBEr4W9ic424Ws1Z)u9diqHXWoGjrcuULC(4(WDm2HVWI(aIqiJxqiRaLagJI0IHfOjCheUnbkmgUngfL5wY5J7d3Xyh(cl6diqTu0hqGMmLYzPOpGt1Biqv9goGjrc0nitfiUKEfHqMztiRaLagJI0IHfONVaDPqGAPOpGafgd3gJIeOWykosGoG3RNN6dtrGidtd)WzcymksxpFP(bGv98uFykcezjBdc7oi3Iy6t(MjGXOiD98L6haw1Zt9HPiqKxetFYDqxIBZeWyuKUE(s9d4965P(WueiYMYs4ogNjGXOiD98L6haw1Zt9d4965l1Z(6xFsPCHHHtXMxeoCpIaUnoSu98pvVxRNncuymSdysKaDdYubIlqW0ICkTieYmdfYkqjGXOiTyybAc3bHBtGsacdFCwtqDQJ6hCQEymCBmkkVbzQaXfiyAroLwGAPOpGanzkLZsrFaNQ3qGQ6nCatIeOBqMkqCj9kcHmSclHScucymkslgwGMWDq42eOgFt4oOmOHJeRdgcaNmqIYeWyuKUEp1ZU6z4GGYGgosSoyiaCYajkZ5xVN6tNeZ58VgeBwtqDQJ65VEwR3t9SV(1Nukxyy4uS5fHd3JiGBJdlv)G1pq9SWs9Wy42yuuMBjNpUpChJD4lSOpq9SPEp1Z(6t3P0NCqEhlXCQ1Dqonzbsgtswd26hCQE(uplSup7R34Bc3bLbnCKyDWqa4KbsugBGr1Z)u9duVN6z4GGY7yjMtTUdYPjlqYysYAWwp)1ZN69up7QFdYubcPZMsvVN6t3P0NCqErm9j3PnqIYjeddNwhe2srFatvp)t1dR8mSE2upBeOwk6diqXC(bhMeHqgwzviRaLagJI0IHfOjCheUnbkMdqqhgoL1KfiQXUfX0N8ntZex77t669uV(I8s(BV5OtJAa869uV(I8s(BVzmjznyRFWP6hOEp1NojMZ5Fni265FQ(beOwk6diqtMs5Su0hWP6neOQEdhWKibkud6freczyDaHScucymkslgwGMWDq42eOPtI5C(xdIT(P6nqlzjeddN0UKVa1srFabAYukNLI(aovVHav1B4aMejqHAqViIqidR8riRaLagJI0IHfOjCheUnbA6KyoN)1GyZAcQtDu)Gt1ZA9SWs9qnCKWHjjRbB9dovpR17P(0jXCo)RbXwp)t1ZhbQLI(ac0KPuolf9bCQEdbQQ3WbmjsGc1GEreHqgw9QqwbkbmgfPfdlqt4oiCBc01Nukxyy4uS5fHd3JiGBJdlv)u9ETEp1NojMZ5Fni265FQEVkqTu0hqGMmLYzPOpGt1Biqv9goGjrcuOg0lIieYWQ3fYkqjGXOiTyybAc3bHBtGsacdFCwtqDQJ6hCQEymCBmkkVbzQaXfiyAroLwGAPOpGanzkLZsrFaNQ3qGQ6nCatIeOmCTslcHmSY2czfOeWyuKwmSanH7GWTjqjaHHpoRjOo1r98pvpREVEEQNaeg(4mMGtabQLI(acudNma5IdJjqicHmS6feYkqTu0hqGA4KbiNpNAjbkbmgfPfdlcHmSoBczfOwk6diqvnCKyDEXCA4seieOeWyuKwmSieYW6muiRa1srFabkJb3DqUa3PrRaLagJI0IHfHieO(ykDsmwiKvidRczfOwk6diqnFF1yN)17beOeWyuKwmSieYmGqwbQLI(ac0nitficucymkslgwecz4JqwbkbmgfPfdlqTu0hqGkz4rK2bDyNMSarG6JP0jXyHBP0b0RaLvVlcHmEviRaLagJI0IHfOwk6diqxvNiNb0oDNibAc3bHBtGIjimTigJIeO(ykDsmw4wkDa9kqzvecz8UqwbkbmgfPfdlqt4oiCBcumhGGomCklz4rUdYfiKtY2GWoBxB3gKPzIR99jTa1srFab6Iy6tUJrzAAfHqg2wiRaLagJI0IHfOatIeOgFVig2wh0bc3b58p5ewGAPOpGa147fXW26Goq4oiN)jNWIqecuOg0lIqwHmSkKvGsaJrrAXWc0eUdc3MaD9jLYfggofBEr4W9ic424Ws1py9SD9EQND1ZWbbLxetFYDAdKOmNF9EQNHdckVQorodOD6orzmjznyRFW6HA4iHdtswd269updheuEvDICgq70DIYysYAWw)G1Z(6zTEEQpDsmNZ)AqS1ZM65l1ZAE2eOwk6diqxvNiNb0oDNiriKzaHScucymkslgwGE(c0LcbQLI(acuymCBmksGcJP4ibQKTbHD2U2UnWHjjRbB98xpSQNfwQND1hMIarg0WrInm1icNjGXOiD9EQpmfbIS2WJClIPp5zcymksxVN6z4GGYlIPp5oTbsuMZVEwyP(1Nukxyy4uS5fHd3JiGBJdlvp)t1Z2cuymSdysKaDh1(omNFWHjriKHpczfOeWyuKwmSanH7GWTjqzx9Wy42yuuEh1(omNFWHP69uFyy4uKJwICX50nv)mxpMKSgS1ZF9SD9EQhtqyArmgfjqTu0hqGI58domjcHmEviRa1srFab6sjmfUGsiGEM4ibkbmgfPfdlcHmExiRaLagJI0IHfOwk6diqXC(bhMeOjCheUnbk7Qhgd3gJIY7O23H58domvVN6zx9Wy42yuuMBjNpUpChJD4lSOpq9EQF9jLYfggofBEr4W9ic424Ws1Z)u9duVN6dddNIC0sKloNUP65FQE2xV3RNN6zF9dupFP(0jXCo)RbXwpBQNn17PEmbHPfXyuKannoPixyy4uSczyveczyBHScucymkslgwGMWDq42eOSREymCBmkkVJAFhMZp4Wu9EQhtswd26hS(0Dk9jhK3XsmNADhKttwGKXKK1GTEEQNvyvVN6t3P0NCqEhlXCQ1Dqonzbsgtswd26hCQEVxVN6dddNIC0sKloNUP6N56XKK1GTE(RpDNsFYb5DSeZPw3b50KfizmjznyRNN69Ua1srFabkMZp4WKieY4feYkqjGXOiTyybAc3bHBtGYU6HXWTXOOm3soFCF4og7WxyrFG69u)6tkLlmmCk265FQE(iqTu0hqGYOS0iN)jxtyriKz2eYkqTu0hqGsW0BIWwqcucymkslgweIqGM0RqwHmSkKvGsaJrrAXWc0eUdc3MaLD1ZWbbLxetFYDAdKOmNF9EQNHdckViC4EebCXHbM(YC(17PEgoiO8IWH7reWfhgy6lJjjRbB9dovpFYExGAPOpGaDrm9j3PnqIeOCl5oiih8KwidRIqiZaczfOeWyuKwmSanH7GWTjqz4GGYlchUhraxCyGPVmNF9EQNHdckViC4EebCXHbM(YysYAWw)Gt1ZNS3fOwk6diq3XsmNADhKttwGiq5wYDqqo4jTqgwfHqg(iKvGsaJrrAXWc0eUdc3Mafgd3gJIYlq7shq3rFG69up7QFdYubcPZsgiuKa1srFabkKYGtkLf9beHqgVkKvGsaJrrAXWc0eUdc3MavtmCqqziLbNukl6dKXKK1GT(bRFabQLI(acuiLbNukl6d4skYaljcHmExiRaLagJI0IHfOjCheUnbk7RhZbiOddNYsgEK7GCbc5KSniSZ212TbzAM4AFFsxVN6tNeZ58VgeBwtqDQJ6hCQE(uplSupMdqqhgoL1KfiQXUfX0N8ntZex77t669uF6KyoN)1GyRFW6zTE2uVN6z4GGY7yjMtTUdYPjlqYC(17PEgoiO8Iy6tUtBGeL58R3t9s2ge2z7A72ahMKSgS1pvpSQ3t9mCqqznzbIASBrm9jFZ6toqGAPOpGafgd0lIieYW2czfOeWyuKwmSanH7GWTjqzx9BqMkqiD2uQ69upmgUngfLxG2LoGUJ(a1Zcl1t7sGeLzWKfiUdYfiKtpUbWZsMx8HR3t9rlr1Z)u9diqTu0hqGMmLYzPOpGt1Biqv9goGjrcuAxcKOvecz8cczfOeWyuKwmSa1srFabQ)DkhM2JdNibAc3bHBtGgMIarEr4W9ic4Iddm9LjGXOiD9EQND1hMIarErm9j3bDjUntaJrrAbk0HDaITcHmSkcHmZMqwbkbmgfPfdlqt4oiCBcucqy4JRN)P6zByvVN6HXWTXOO8c0U0b0D0hOEp1NUtPp5G8owI5uR7GCAYcKmNF9EQpDNsFYb5fX0NCN2ajkNqmmCARN)P6zvGAPOpGaDr4W9ic4Iddm9jcHmZqHScucymkslgwGAPOpGaDjm2cs7yoa5w)Eejqt4oiCBcuymCBmkkVaTlDaDh9bQ3t9SRE9f5LWyliTJ5aKB97rKtFro60OgaVEp1hggof5OLixCoDt1Z)u9dWA9SWs9qnCKWHjjRbB9dovV3R3t9RpPuUWWWPyZlchUhra3ghwQ(bRNpc004KICHHHtXkKHvriKHvyjKvGsaJrrAXWc0eUdc3Mafgd3gJIYlq7shq3rFG69up7QpDNsFYb5fX0NChJY00M58R3t9SV(WueiYeagsD(naUBrm9jFZeWyuKUEwyP(0Dk9jhKxetFYDAdKOCcXWWPTE(NQN16zt9EQN91ZU6dtrGiViC4EebCXHbM(YeWyuKUEwyP(WueiYlIPp5oOlXTzcymksxplSuF6oL(KdYlchUhraxCyGPVmMKSgS1ZF9dupBQ3t9SVE2vpTlbsuMrDN2DqUaHCeGKgNLmV4dxplSuF6oL(KdYmQ70UdYfiKJaK04mMKSgS1ZF9dupBeOwk6diq3XsmNADhKttwGicHmSYQqwbkbmgfPfdlqTu0hqGkz4rK2bDyNMSarGMWDq42eOyR1ocgceztR3mNF9EQN91hggof5OLixCoDt1py9PtI5C(xdInRjOo1r9SWs9SR(nitfiKoBkv9EQpDsmNZ)AqSznb1PoQN)P6t(ojJTCRpb01ZgbAACsrUWWWPyfYWQieYW6aczfOeWyuKwmSanH7GWTjqXwRDemeiYMwV5gup)1Zhyv)mxp2ATJGHar206nR5Ww0hOEp1NojMZ5Fni2SMG6uh1Z)u9jFNKXwU1NaAbQLI(acujdpI0oOd70KfiIqidR8riRaLagJI0IHfOjCheUnbkmgUngfLxG2LoGUJ(a17P(0jXCo)RbXM1euN6OE(NQFabQLI(ac0fX0NChJY00kcHmS6vHScucymkslgwGMWDq42eOWy42yuuEbAx6a6o6duVN6tNeZ58VgeBwtqDQJ65FQE(uVN6xFsPCHHHtXMxeoCpIaUnoSu9dovVxfOwk6diqPeY1a4om5JBjdOfHqgw9UqwbkbmgfPfdlqt4oiCBc0WueiYlIPp5oOlXTzcymksxVN6HXWTXOO8c0U0b0D0hOEp1ZWbbL3XsmNADhKttwGK58fOwk6diqxeoCpIaU4WatFIqidRSTqwbkbmgfPfdlqt4oiCBcu2vpdheuErm9j3PnqIYC(17PEOgos4WKK1GT(bNQF2QNN6dtrGiVCmbHH4GtzcymkslqTu0hqGUiM(K70girIqidREbHSculf9beO(x0hqGsaJrrAXWIqidRZMqwbkbmgfPfdlqt4oiCBcugoiO8owI5uR7GCAYcKmNVa1srFabkJ6oTdIdpweczyDgkKvGsaJrrAXWc0eUdc3MaLHdckVJLyo16oiNMSajZ5lqTu0hqGYq4LWJAaCriKzayjKvGsaJrrAXWc0eUdc3MaLHdckVJLyo16oiNMSajZ5lqTu0hqGc1yIrDNweczgGvHScucymkslgwGMWDq42eOmCqq5DSeZPw3b50KfizoFbQLI(acudKOnWMYLmLseczgyaHScucymkslgwGAPOpGannoPUaFGo5yu2gc0eUdc3MaLD1VbzQaH0ztPQ3t9Wy42yuuEbAx6a6o6duVN6zx9mCqq5DSeZPw3b50Kfizo)69upbim8Xznb1PoQN)P65dSeOeeeLchWKibAACsDb(aDYXOSneHqMb4JqwbkbmgfPfdlqTu0hqGA89IyyBDqhiChKZ)KtybAc3bHBtGYU6z4GGYlIPp5oTbsuMZVEp1NUtPp5G8owI5uR7GCAYcKmMKSgS1py9SclbkWKibQX3lIHT1bDGWDqo)toHfHqMb8QqwbkbmgfPfdlqTu0hqGAlcmgGwh247d7sh2uc0eUdc3MavtmCqqzSX3h2LoSPCAIHdckRp5G6zHL61edheuoDanxkAyixdg50edheuMZVEp1hggofzeYubs2pf1py98zG69uFyy4uKritfiz)uup)t1ZhyvplSup7QxtmCqq50b0CPOHHCnyKttmCqqzo)69up7RxtmCqqzSX3h2LoSPCAIHdckVHLgvp)t1pG3RFMRNvyvpFPEnXWbbLzu3PDhKlqihbiPXzo)6zHL6HA4iHdtswd26hSEVcR6zt9EQNHdckVJLyo16oiNMSajJjjRbB98x)SjqbMejqTfbgdqRdB89HDPdBkriKzaVlKvGsaJrrAXWcuGjrcuPXABDHP6vYaculf9beOsJ126ct1RKbeHqMbyBHScucymkslgwGMWDq42eOmCqq5DSeZPw3b50Kfizo)6zHL6HA4iHdtswd26hS(bGLa1srFabk3sUoiPveIqGUbzQaXL0RqwHmSkKvGsaJrrAXWc0ZxGUuiqTu0hqGcJHBJrrcuymfhjqt3P0NCqErm9j3PnqIYjeddNwhe2srFatvp)t1ZA2l4Dbkmg2bmjsGUiAxGGPf5uAriKzaHScucymkslgwGMWDq42eOSVE2vpmgUngfLxeTlqW0ICkD9SWs9SR(WueiYGgosSHPgr4mbmgfPR3t9HPiqK1gEKBrm9jptaJrr66zt9EQpDsmNZ)AqSznb1PoQN)6zTEp1ZU6XCac6WWPSKHh5oixGqojBdc7SDTDBqMMjU23N0culf9beOWyGEreHqg(iKvGAPOpGaDj)TxbkbmgfPfdlcHmEviRaLagJI0IHfOwk6diq9Vt5W0EC4ejqj2kWMZKooqiq9kSeOqh2bi2keYWQieY4DHScucymkslgwGMWDq42eOeGWWhxp)t17vyvVN6jaHHpoRjOo1r98pvpRWQEp1ZU6HXWTXOO8IODbcMwKtPR3t9PtI5C(xdInRjOo1r98xpR17PEnXWbbLHAG2jNSraA3mMKSgS1py9SkqTu0hqGUiM(KlrkTieYW2czfOeWyuKwmSa98fOlfculf9beOWy42yuKafgtXrc00jXCo)RbXM1euN6OE(NQ3RcuymSdysKaDr0U0jXCo)RbXkcHmEbHScucymkslgwGE(c0LcbQLI(acuymCBmksGcJP4ibA6KyoN)1GyZAcQtDu)Gt1ZQanH7GWTjqHXWTXOOm3soFCF4og7WxyrFabkmg2bmjsGUiAx6KyoN)1GyfHqMztiRaLagJI0IHfOjCheUnbkmgUngfLxeTlDsmNZ)AqS17PE2xpmgUngfLxeTlqW0ICkD9SWs9mCqq5DSeZPw3b50KfizmjznyRN)P6znpq9SWs9RpPuUWWWPyZlchUhra3ghwQE(NQ3R17P(0Dk9jhK3XsmNADhKttwGKXKK1GTE(RNvyvpBeOwk6diqxetFYDAdKiriKzgkKvGsaJrrAXWc0eUdc3Mafgd3gJIYlI2LojMZ5Fni269upudhjCysYAWw)G1NUtPp5G8owI5uR7GCAYcKmMKSgSculf9beOlIPp5oTbsKieHaLHRvAHSczyviRaLagJI0IHfOjCheUnbk7QpmfbImOHJeByQreotaJrr669upMdqqhgoLJgm2fhB1jhJY0uMMjU23N0culf9beOlsdJieYmGqwbkbmgfPfdlqt4oiCBc01Nukxyy4uS1Z)u9dupp1Z(6dtrGidxDNeJY0uMagJI017PEJVjChu2NWqh2ckJnWO65FQ(bQNnculf9beOlchUhra3ghwsecz4JqwbkbmgfPfdlqt4oiCBc00Dk9jhKxcJTG0oMdqU1Vhr5eIHHtRdcBPOpGPQN)P6hi7f8Ua1srFab6sySfK2XCaYT(9isecz8QqwbQLI(acu4Q7KyuMMeOeWyuKwmSieY4DHSculf9beOmwA0ggJaLagJI0IHfHieHafgcV9beYmaSgawScRbyBbQCddAa8vGodM9WwzG9LHV6SR(6LfHQVL8pCup0HRh2JHRvAyV6X0mX1ysx)Esu9gxCswq66tigaoT5A(mEdO6hy2vpSLKoyiD9(32rFahJLgvFcHsJQN9GlQ3GXALXOO6Bq9KeNYI(aSPE2ZkBXMCnVMpdM9WwzG9LHV6SR(6LfHQVL8pCup0HRh2lPxyV6X0mX1ysx)Esu9gxCswq66tigaoT5A(mEdO696SR(zey589pCq66Tu0hOEypiLbNukl6d4skYalb7LR51CyFj)dhKU(zRElf9bQx1BS5AUa1hFqTIeOEREuoMqrX46HThCoQM7T6L5GHKyiC98H36hawdaRAEn3B1dBW0m7LNeJf1Clf9b2SpMsNeJf8mnK57Rg78VEpqn3srFGn7JP0jXybptdTbzQaPMBPOpWM9Xu6KySGNPHKm8is7GoSttwGWRpMsNeJfULshqVtS69AULI(aB2htPtIXcEMgAvDICgq70DI41htPtIXc3sPdO3jw5THMWeeMweJrr1Clf9b2SpMsNeJf8mn0Iy6tUJrzAA5THMWCac6WWPSKHh5oixGqojBdc7SDTDBqMMjU23N01Clf9b2SpMsNeJf8mne3sUoijEbMenz89IyyBDqhiChKZ)Kt4AEn3B17fznOEy7fw0hOMBPOpWonQtJQ5wk6dS8mnemgUngfXlWKOPfODPdO7OpaVWykoAIHdckVQorodOD6orzoFwyz9jLYfggofBEr4W9ic424Ws8pX28oJwsxFC1RPGWsnGQxocfieU(0Dk9jhS1l36OEOdxpkyw1ZylPR)a1hggofBUM7T69seknQEVCwB9wupuJ3OMBPOpWYZ0qjtPCwk6d4u9g8cmjAkP3AU3Qh2YbQhItPgx)kVJecT1hx9bcvpAqMkqiD9W2lSOpq9SNzC96RbWRFpE7OEOdNOTE)7unaE9nu9GlqAa867TEdgRvgJIytUMBPOpWYZ0qyoGZsrFaNQ3GxGjrtBqMkqinVn00gKPcesNnLQM7T6N9((QX1VQorodOD6or1Br9dWt9EjSPEnhUbWRpqO6HA8g1ZkSQFP0b0lVguq46delQ3R8uVxcBQVHQVJ6j2YVX0wV8oqAq9bcvpGyROE(QE5SQ)W13B9GlQNZVMBPOpWYZ0qRQtKZaANUteVn006tkLlmmCk28IWH7reWTXHLgKT9a1WrchMKSgS8Z2Ey4GGYRQtKZaANUtugtswd2bHN0zjJT8KojMZ5Fniw(N86mZ(OLObzfwSHVmqn3B1ZxjqnU(eIbGt1JVWI(a13q1lNQhXGHQ3h3hUJXo8fw0hO(LI6nGUEjov0(kQ(WWWPyRNZpxZTu0hy5zAiymCBmkIxGjrtCl58X9H7ySdFHf9b4fgtXrt(4(WDm2HVWI(aEwFsPCHHHtXMxeoCpIaUnoSe)tduZ9w9WgCF4ogxpS9cl6dmJz9Z4ua7T1dVHHQ3QpHn)6nMJlQNaeg(46HoC9bcv)gKPcK69YzT1ZEgUwPjC9B0kv9yA9PuuFhSjxpFf585TJ6tgOEgQ(aXI63wYxr5AULI(alptdLmLYzPOpGt1BWlWKOPnitfiUKE5THMGXWTXOOm3soFCF4og7WxyrFGAU3QFgTKU(4QxtqnGQxocbQpU65wQ(nitfi17LZAR)W1ZW1knH3AULI(alptdbJHBJrr8cmjAAdYubIlqW0ICknVWykoAAaVZtykcezyA4hotaJrrA(YaWINWueiYs2ge2DqUfX0N8ntaJrrA(YaWINWueiYlIPp5oOlXTzcymksZxgW78eMIar2uwc3X4mbmgfP5ldalEgW78f2V(Ks5cddNInViC4EebCBCyj(N8kBQ5EREV8aBRjC9CBdGxVvpAqMkqQ3lNv9Yriq9yYsinaE9bcvpbim8X1hiyAroLUMBPOpWYZ0qjtPCwk6d4u9g8cmjAAdYubIlPxEBOjcqy4JZAcQtDm4emgUngfL3GmvG4cemTiNsxZ9w9Y0WrcyVTE(AcaNmqIMD1dB58domvpdbDyQE0XsmNAR3I6vN869syt9XvF6KyAavpzy146XeeMwK6L3bs9WPiAa86deQEgoiO658Z1p7v7vV6KxVxcBQxZHBa86rhlXCQTEgkKteO(zzGeT1lVdK6hGN6LHVoxZTu0hy5zAimNFWHjEBOjJVjChug0WrI1bdbGtgirzcymks7HDmCqqzqdhjwhmeaozGeL589KojMZ5Fni2SMG6uh8ZQh2V(Ks5cddNInViC4EebCBCyPbhGfwGXWTXOOm3soFCF4og7WxyrFa24H9P7u6toiVJLyo16oiNMSajJjjRb7Gt8HfwyVX3eUdkdA4iX6GHaWjdKOm2aJ4FAapmCqq5DSeZPw3b50Kfizmjzny5NpEy3gKPcesNnLYt6oL(KdYlIPp5oTbsuoHyy406GWwk6dyk(NGvEgYg2uZTu0hy5zAOKPuolf9bCQEdEbMenb1GEr4THMWCac6WWPSMSarn2TiM(KVzAM4AFFs7rFrEj)T3C0PrnaUh9f5L83EZysYAWo40aEsNeZ58Vgel)tduZTu0hy5zAOKPuolf9bCQEdEbMenb1GEr4THMsNeZ58Vge7KbAjlHyy4K2L8R5EREVZt9Y7aP(zHwp7pUyBnv)gKPce2uZTu0hy5zAOKPuolf9bCQEdEbMenb1GEr4THMsNeZ58VgeBwtqDQJbNyLfwGA4iHdtswd2bNy1t6KyoN)1Gy5FIp1CVvpSRb9IuVf17vEQxEhihxu)SqR5ER(zqhi1pl06n1E1d1GErQ3I69kp1BWTgSr9eBzPqnUEVwFyy4uS1Z(Jl2wt1VbzQaHn1Clf9bwEMgkzkLZsrFaNQ3GxGjrtqnOxeEBOP1Nukxyy4uS5fHd3JiGBJdln5vpPtI5C(xdIL)jVwZ9w9ZOLQ3QNHRvAcxVCecupMSesdGxFGq1tacdFC9bcMwKtPR5wk6dS8mnuYukNLI(aovVbVatIMy4ALM3gAIaeg(4SMG6uhdobJHBJrr5nitfiUabtlYP01CVv)m(jN2OEFCF4ogxFdQ3uQ6pO6deQ(zpSzgVEgkzClvFh1NmUL26T65R6LZQMBPOpWYZ0qgozaYfhgtGG3gAIaeg(4SMG6uh8pXQ35Haeg(4mMGtGAULI(alptdz4KbiNpNAPAULI(alptdPA4iX68I50WLiquZTu0hy5zAigdU7GCbUtJ2AEn3B17L3P0NCWwZ9w9ZOLQFwgir1FqqZm8KUEgc6Wu9bcvpuJ3O(fHd3JiGBJdlvpe(KQx2ddm9vF6KOT(gKR5wk6dS5KE5zAOfX0NCN2ajIxULCheKdEspXkVn0e7y4GGYlIPp5oTbsuMZ3ddheuEr4W9ic4Iddm9L589WWbbLxeoCpIaU4WatFzmjznyhCIpzVxZ9w9SFgbu0U1Bkmz6X1Z5xpdLmULQxovFC3O6rrm9jVEy3L4w2up3s1JowI5uB9he0mdpPRNHGomvFGq1d14nQFr4W9ic424Ws1dHpP6L9WatF1NojARVb5AULI(aBoPxEMgAhlXCQ1DqonzbcVCl5oiih8KEIvEBOjgoiO8IWH7reWfhgy6lZ57HHdckViC4EebCXHbM(YysYAWo4eFYEVMBPOpWMt6LNPHGugCsPSOpaVn0emgUngfLxG2LoGUJ(aEy3gKPcesNLmqOOAULI(aBoPxEMgcszWjLYI(aUKImWs82qtAIHdckdPm4KszrFGmMKSgSdoqn3srFGnN0lptdbJb6fH3gAI9yoabDy4uwYWJChKlqiNKTbHD2U2UnitZex77tApPtI5C(xdInRjOo1XGt8HfwWCac6WWPSMSarn2TiM(KVzAM4AFFs7jDsmNZ)AqSdYkB8WWbbL3XsmNADhKttwGK589WWbbLxetFYDAdKOmNVhjBdc7SDTDBGdtswd2jy5HHdckRjlquJDlIPp5BwFYb1Clf9b2CsV8mnuYukNLI(aovVbVatIMODjqIwEBOj2TbzQaH0ztP8aJHBJrr5fODPdO7OpalSq7sGeLzWKfiUdYfiKtpUbWZsMx8H9eTeX)0a1CVvpS5ov9qhUEzpmW0x9(yAMrVzvV8oqQhfzw1JjtpUE5ieOEWf1J5aGgaVEuyxUMBPOpWMt6LNPH8Vt5W0EC4eXl0HDaITIjw5THMctrGiViC4EebCXHbM(YeWyuK2d7ctrGiViM(K7GUe3MjGXOiDn3B1pJwQEzpmW0x9(yQE0Bw1lhHa1lNQhXGHQpqO6jaHHpUE5iuGq46HWNu9(3PAa86L3bYXf1Jc7Q)W17fZTr9WjaHnLACUMBPOpWMt6LNPHweoCpIaU4WatF82qteGWWhZ)eBdlpWy42yuuEbAx6a6o6d4jDNsFYb5DSeZPw3b50KfizoFpP7u6toiViM(K70gir5eIHHtl)tSwZTu0hyZj9YZ0qlHXwqAhZbi363JiEtJtkYfggof7eR82qtWy42yuuEbAx6a6o6d4HD6lYlHXwqAhZbi363JiN(IC0PrnaUNWWWPihTe5IZPBI)PbyLfwGA4iHdtswd2bN8UN1Nukxyy4uS5fHd3JiGBJdlniFQ5ER(z0s1JowI5uB9hO(0Dk9jhup7nOGW1d14nQhfml2uphqr7wVCQEdt1d)Aa86JRE)ZVEzpmW0x9gqxV(QhCr9igmu9OiM(KxpS7sCBUMBPOpWMt6LNPH2XsmNADhKttwGWBdnbJHBJrr5fODPdO7OpGh2LUtPp5G8Iy6tUJrzAAZC(EyFykcezcadPo)ga3TiM(KVzcymksZclP7u6toiViM(K70gir5eIHHtl)tSYgpSNDHPiqKxeoCpIaU4WatFzcymksZclHPiqKxetFYDqxIBZeWyuKMfws3P0NCqEr4W9ic4Iddm9LXKK1GL)byJh2ZoAxcKOmJ6oT7GCbc5iajnolzEXhMfws3P0NCqMrDN2DqUaHCeGKgNXKK1GL)bytn3B1d7dvVP1B9gMQNZN36xq7t1hiu9hGQxEhi1Ro50g1lRSZkx)mAP6LJqG61JBa86HSniC9bIbQ3lHn1RjOo1r9hUEWf1VbzQaH01lVdKJlQ3aJR3lHn5AULI(aBoPxEMgsYWJiTd6WonzbcVPXjf5cddNIDIvEBOjS1AhbdbISP1BMZ3d7dddNIC0sKloNUPbtNeZ58VgeBwtqDQdwyHDBqMkqiD2ukpPtI5C(xdInRjOo1b)tjFNKXwU1NaA2uZ9w9W(q1dU6nTERxERu1RBQE5DG0G6deQEaXwr98bwlV1ZTu9ErqZQ(dupZTB9Y7a54I6nW469sytUMBPOpWMt6LNPHKm8is7GoSttwGWBdnHTw7iyiqKnTEZnGF(aRzgBT2rWqGiBA9M1Cyl6d4jDsmNZ)AqSznb1Po4Fk57Km2YT(eqxZTu0hyZj9YZ0qlIPp5ogLPPL3gAcgd3gJIYlq7shq3rFapPtI5C(xdInRjOo1b)tduZTu0hyZj9YZ0quc5AaChM8XTKb082qtWy42yuuEbAx6a6o6d4jDsmNZ)AqSznb1Po4FIpEwFsPCHHHtXMxeoCpIaUnoS0GtETM7T6NbDGupkSJ36BO6bxuVPWKPhxV(aeV1ZTu9YEyGPV6L3bs9O3SQNZpxZTu0hyZj9YZ0qlchUhraxCyGPpEBOPWueiYlIPp5oOlXTzcymks7bgd3gJIYlq7shq3rFapmCqq5DSeZPw3b50Kfizo)AULI(aBoPxEMgArm9j3PnqI4THMyhdheuErm9j3PnqIYC(EGA4iHdtswd2bNMnEctrGiVCmbHH4GtzcymksxZR5EREzoWmV(uQ(n4GGQxEhi1Ro5eUEFCF1Clf9b2CsV8mnK)f9bQ5wk6dS5KE5zAig1DAhehEmVn0edheuEhlXCQ1DqonzbsMZVMBPOpWMt6LNPHyi8s4rnaoVn0edheuEhlXCQ1DqonzbsMZVMBPOpWMt6LNPHGAmXOUtZBdnXWbbL3XsmNADhKttwGK58R5wk6dS5KE5zAidKOnWMYLmLI3gAIHdckVJLyo16oiNMSajZ5xZR5wk6dS5KE5zAiULCDqs8sqqukCatIMsJtQlWhOtogLTbVn0e72GmvGq6SPuEGXWTXOO8c0U0b0D0hWd7y4GGY7yjMtTUdYPjlqYC(EiaHHpoRjOo1b)t8bw1Clf9b2CsV8mne3sUoijEbMenz89IyyBDqhiChKZ)KtyEBOj2XWbbLxetFYDAdKOmNVN0Dk9jhK3XsmNADhKttwGKXKK1GDqwHvn3B1FbcHL3lvV8oqQh9Mv9wu)aENN63WsJ26pC9S6DEQxEhi1BQ9QFy1D6658Z1Clf9b2CsV8mne3sUoijEbMenzlcmgGwh247d7sh2u82qtAIHdckJn((WU0HnLttmCqqz9jhWclAIHdckNoGMlfnmKRbJCAIHdckZ57jmmCkYiKPcKSFkgKpd4jmmCkYiKPcKSFk4FIpWIfwyNMy4GGYPdO5srdd5AWiNMy4GGYC(EyVMy4GGYyJVpSlDyt50edheuEdlnI)Pb8(mZkS4lAIHdckZOUt7oixGqocqsJZC(SWcudhjCysYAWoOxHfB8WWbbL3XsmNADhKttwGKXKK1GL)zRM7T65Rj846XhhCe146XCkQ(dQ(aHtIPHAsxVKfiB9mK6Kp7QFgTu9qhUEyFWi)txFc3rn3srFGnN0lptdXTKRdsIxGjrtsJ126ct1RKbQ5ER(zrqgNkQhYukglnQEOdxp3AmkQ(oiPD2v)mAP6L3bs9OJLyo1w)bv)SilqY1Clf9b2CsV8mne3sUoiPL3gAIHdckVJLyo16oiNMSajZ5ZclqnCKWHjjRb7GdaRAEn3B1p75Bc3bv)mg7sGeT1Clf9b2mTlbs0YZ0qPdKiqGTG0oiLjr82qteGWWhNJwICX5Km2IFw9WogoiO8owI5uR7GCAYcKmNVh2Zo9f50bseiWwqAhKYKihdhgKJonQbW9Wolf9bYPdKiqGTG0oiLjr5g4GunCKGfwG4ukhMsiggo5IwIgeEsNLm2In1Clf9b2mTlbs0YZ0qmQ70UdYfiKJaK0yEBOj2LUtPp5G8Iy6tUJrzAAZC(Es3P0NCqEhlXCQ1DqonzbsMZNfwGA4iHdtswd2bNyfw1Clf9b2mTlbs0YZ0qW5mSUnG7GCgFt4lqQ5wk6dSzAxcKOLNPHGUe3sANX3eUdYXqMeVn0e7xFsPCHHHtXMxeoCpIaUnoSe)tdWclyR1ocgceztR3Cd4NTHfB8WU0Dk9jhK3XsmNADhKttwGK589WogoiO8owI5uR7GCAYcKmNVhcqy4JZAcQtDW)eFGvn3srFGnt7sGeT8mnKphUHg3a4ogLTbVn006tkLlmmCk28IWH7reWTXHL4FAawybBT2rWqGiBA9MBa)SnSQ5wk6dSzAxcKOLNPHceYXbyooG2bD4eXBdnXWbbLXuAKI21bD4eL58zHfgoiOmMsJu0UoOdNix64abHZByPrdYkSQ5wk6dSzAxcKOLNPHWTVVICnWT(wIQ5wk6dSzAxcKOLNPHKFyLggQbomThWajI3gAkDNsFYb5DSeZPw3b50Kfizmjznyh07SWcudhjCysYAWoiRZwn3srFGnt7sGeT8mnKejD4XUdYP4sT2PXKjT82qteGWWhpOxHLhgoiO8owI5uR7GCAYcKmNFn3B1pJ9u66HTK53a41d7uMeT1dD46j2IsCbvp2aWP6pC9JALQEgoiOL36BO69VDBgfLRF2RKBJ36d846JRE4uuFGq1Ro50g1NUtPp5G6zSL01FG6nySwzmkQEcqsnT5AULI(aBM2LajA5zAimz(naUdszs0YBdnb1WrchMKSgSdYA27SWc7zFyy4uKritfiz)uW)SblwyjmmCkYiKPcKSFkgCAayXgpS3srdd5iaj10oXklSa1WrchMKSgS8pWmKnSHfwyFyy4uKJwICX58tHBayXpFGLh2BPOHHCeGKAANyLfwGA4iHdtswdw(9QxzdBQ51CVvpAqMkqQ3lVtPp5GTMBPOpWM3GmvG4s6LNPHGXWTXOiEbMenTiAxGGPf5uAEHXuC0u6oL(KdYlIPp5oTbsuoHyy406GWwk6dyk(Nyn7f8oVZyjLpHRNV2WTXOOAU3QNV2a9IuFdvVCQEdt1NmF)gaV(du)SmqIQpHyy40MRFgddRgxpdbDyQEOgVr9AdKO6BO6Lt1JyWq1dU6LPHJeByQreUEgUO(zz4r1JIy6tE9nO(dRjC9XvpCkQh2Y5hCyQEo)6zp4Q3lY2GW1p7312TbSjxZTu0hyZBqMkqCj9YZ0qWyGEr4THMyp7GXWTXOO8IODbcMwKtPzHf2fMIarg0WrInm1icNjGXOiTNWueiYAdpYTiM(KNjGXOinB8KojMZ5Fni2SMG6uh8ZQh2H5ae0HHtzjdpYDqUaHCs2ge2z7A72GmntCTVpPR5wk6dS5nitfiUKE5zAOL83ER5wk6dS5nitfiUKE5zAi)7uomThhor8cDyhGyRyIvEj2kWMZKooqm5vyXlS5ov9qhUEuetFYLiLUEEQhfX0N8nW9iQEoGI2TE5u9gMQ3yoUO(4Qpz(1FG6NLbsu9jeddN2C98vcuJRxocbQh21aD9ZaYgbODRV36nMJlQpU6XCG6pUixZTu0hyZBqMkqCj9YZ0qlIPp5sKsZBdnracdFm)tEfwEiaHHpoRjOo1b)tSclpSdgd3gJIYlI2fiyAroL2t6KyoN)1GyZAcQtDWpRE0edheugQbANCYgbODZysYAWoiR1Clf9b28gKPcexsV8mnemgUngfXlWKOPfr7sNeZ58VgelVWykoAkDsmNZ)AqSznb1Po4FYR86LWM6X0mX1ysIaXSR(zzGevVf1Ro517LWM6zgxVMGmovKR5EREVe2upMMjUgtseiMD1pldKO6pGAC9me0HP6HAqVieERVHQxovpIbdvVpUpChJRhFHf9bY1Clf9b28gKPcexsV8mnemgUngfXlWKOPfr7sNeZ58VgelVWykoAkDsmNZ)AqSznb1PogCIvEBOjymCBmkkZTKZh3hUJXo8fw0hOM7T6NLbsu9AoCdGxp6yjMtT1F46nMdgQ(abtlYP05AULI(aBEdYubIlPxEMgArm9j3PnqI4THMGXWTXOO8IODPtI5C(xdI1d7HXWTXOO8IODbcMwKtPzHfgoiO8owI5uR7GCAYcKmMKSgS8pXAEawyz9jLYfggofBEr4W9ic424Ws8p5vpP7u6toiVJLyo16oiNMSajJjjRbl)Scl2uZ9w9dZHb1JjjRbnaE9ZYajARNHGomvFGq1d1WrI6jGERVHQh9Mv9YpaSxupdvpMm946Bq9rlr5AULI(aBEdYubIlPxEMgArm9j3PnqI4THMGXWTXOO8IODPtI5C(xdI1dudhjCysYAWoy6oL(KdY7yjMtTUdYPjlqYysYAWwZR5ERE0GmvGq66HTxyrFGAU3Qh2hQE0GmvGmemgOxK6nmvpNpV1ZTu9OiM(KVbUhr1hx9meGG6OEi8jvFGq17B72Wq1ZCaUTEdORh21aD9ZaYgbODRNGHa13q1lNQ3Wu9wuVKXw17LWM6zpe(KQpqO69Xu6KySOEViOzXMCn3srFGnVbzQaH08mn0Iy6t(g4EeXBdnXEgoiO8gKPcKmNplSWWbbLHXa9IK58ztn3B1d7AqVi1Br98HN69syt9Y7a54I6NfA9dvVx5PE5DGu)SqRxEhi1JIWH7reOEzpmW0x9mCqq1Z5xFC1BWCTU(9KO69syt9YTnO63o4SOpWMR5wk6dS5nitfiKMNPHsMs5Su0hWP6n4fys0eud6fH3gAIHdckViC4EebCXHbM(YC(EsNeZ58VgeBwtqDQJbNgOM7T6N9Q9QFniQ(4QhQb9IuVf17vEQ3lHn1lVdK6j2YsHAC9ET(WWWPyZ1ZEutIQ326pUyBnv)gKPcKmBQ5wk6dS5nitfiKMNPHsMs5Su0hWP6n4fys0eud6fH3gAA9jLYfggofBEr4W9ic424WstE1t6KyoN)1Gy5FYR1CVvpSRb9IuVf17vEQ3lHn1lVdKJlQFwO8wV35PE5DGu)Sq5TEdORNTRxEhi1pl06nOGW1ZxBGErQ5wk6dS5nitfiKMNPHsMs5Su0hWP6n4fys0eud6fH3gAkDsmNZ)AqSznb1PogCI1zM9HPiqK1e5ty3gylm4KuMagJI0Ey4GGYWyGErYC(SPMBPOpWM3GmvGqAEMgArAy4THMctrGidA4iXgMAeHZeWyuK2dMdqqhgoLJgm2fhB1jhJY0uMMjU23N01CVvpS7W17JPz23IecV1pIi)6HDnqx)mGSraA3658R)a1hiu9(4wYWJRpmmCkQxZr1hx9GREuetFYRNV24urn3srFGnVbzQaH08mn0Iy6t(g4EeXBdnPiyi1GEFapAIHdckd1aTtozJa0UzmjznyhKvpHHHtroAjYfNt30mJjjRbl)SDn3B1pJ8RpU65t9HHHtXw)iI8RNZVEyxd01pdiBeG2TEMX1NgNunaE9OiM(KVbUhr5AULI(aBEdYubcP5zAOfX0N8nW9iI304KICHHHtXoXkVn0KMy4GGYqnq7Kt2iaTBgtswd2bz1Z6tkLlmmCk28IWH7reWTXHLgCIpEcddNIC0sKloNUPzgtswdw(z7AU3QFg0bYXf1plI8jC9Ob2cdojvVb01ZN6HTgy0w)bv)Wktt13G6deQEuetFY367O(ERx(HdK652gaVEuetFY3a3JO6pq98P(WWWPyZ1Clf9b28gKPcesZZ0qlIPp5BG7reVn0e7ctrGiRjYNWUnWwyWjPmbmgfP9y8nH7GYmkttUg4ceYTiM(KVzSbgnXhpRpPuUWWWPyZlchUhra3ghwAIp1CVvpS7W17J7d3X46XxyrFaERNBP6rrm9jFdCpIQ)GHW1JghwQEwzt9Y7aP(zGxu9gCRbBupNF9XvVxRpmmCkwERFa2uFdvpSBguFV1J5aGgaV(dcQE2FG6nW46nPJde1Fq1hggoflB4T(dxpFyt9XvVKXwTuZ3u9O3SQNyRGaBFG6L3bs9W(acMomMw1X46pq98P(WWWPyRN9ETE5DGu)WDGYMCn3srFGnVbzQaH08mn0Iy6t(g4EeXBdnbJHBJrrzULC(4(WDm2HVWI(aEyVMy4GGYqnq7Kt2iaTBgtswd2bzLfwctrGilNm)dizBq4mbmgfP9S(Ks5cddNInViC4EebCBCyPbN8klSy8nH7GYnGGPdJPvDmotaJrrApmCqq5DSeZPw3b50KfizoFpRpPuUWWWPyZlchUhra3ghwAWj(WJX3eUdkZOmn5AGlqi3Iy6t(MjGXOinBQ5wk6dS5nitfiKMNPHweoCpIaUnoSeVn006tkLlmmCkw(N4dpSNHdck7Jjjs3Hf9bYC(SWcdheuoqih(IGazoFwybZbiOddNY2iZW962Jt5GWgCjcezAM4AFFs7jDanxhznr(e2Pn4Wj8MXgye)tEb2uZTu0hyZBqMkqinptdTiM(KVbUhr82qtAIHdckd1aTtozJa0UzmjznyhCIvwyjDNsFYb5DSeZPw3b50KfizmjznyhK1zZJMy4GGYqnq7Kt2iaTBgtswd2bt3P0NCqEhlXCQ1Dqonzbsgtswd2AU3QhfX0N8nW9iQ(4QhtqyArQh21aD9ZaYgbODR3a66JREcSCyQE5u9jduFYW4X1FWq46T6H4uQ6HDZG6BqC1hiu9aITI6rVzvFdvV)TBZOOCn3srFGnVbzQaH08mnK)DkhM2JdNiEHoSdqSvmXAn3srFGnVbzQaH08mneC1Dsmktt82qtmCqqzFcdDyliTdgQbBEdlnI)jV7jDanxhzFcdDyliTdgQbBgBGr8pXkFQ5wk6dS5nitfiKMNPHwetFY3a3JOAEn3B1d7AqVieER5wk6dSzOg0lcptdTQorodOD6or82qtRpPuUWWWPyZlchUhra3ghwAq22d7y4GGYlIPp5oTbsuMZ3ddheuEvDICgq70DIYysYAWoiudhjCysYAW6HHdckVQorodOD6orzmjznyhK9SYt6KyoN)1GyzdFH18SvZTu0hyZqnOxeEMgcgd3gJI4fys00oQ9Dyo)Gdt8cJP4OjjBdc7SDTDBGdtswdw(HflSWUWueiYGgosSHPgr4mbmgfP9eMIarwB4rUfX0N8mbmgfP9WWbbLxetFYDAdKOmNplSS(Ks5cddNInViC4EebCBCyj(NyBENXskFcxpFTHBJrr1dD46HTC(bhMY1JoQ9RxZHBa869ISniC9Z(DTDBq9hUEnhUbWRFwgir1lVdK6NLHhvVb01dU6LPHJeByQreoxZ9w98vGi)658Rh2Y5hCyQ(gQ(oQV36nMJlQpU6XCG6pUixZTu0hyZqnOxeEMgcZ5hCyI3gAIDWy42yuuEh1(omNFWHjpHHHtroAjYfNt30mJjjRbl)SThmbHPfXyuun3srFGnd1GEr4zAOLsykCbLqa9mXr1CVvVxeNkA9frdGxFyy4uS1hiwuV8wPQx1Wq1dD46deQEnh2I(a1Fq1dB58domvpMGW0IuVMd3a417Banj1PCn3srFGnd1GEr4zAimNFWHjEtJtkYfggof7eR82qtSdgd3gJIY7O23H58dom5HDWy42yuuMBjNpUpChJD4lSOpGN1Nukxyy4uS5fHd3JiGBJdlX)0aEcddNIC0sKloNUj(NyV35H9dWxsNeZ58VgelByJhmbHPfXyuun3B1dBjimTi1dB58domvpzy146BO67OE5TsvpXw(nMQxZHBa86rhlXCQnx)SU6delQhtqyArQVHQh9Mv9WPyRhtMEC9nO(aHQhqSvuV33Cn3srFGnd1GEr4zAimNFWHjEBOj2bJHBJrr5Du77WC(bhM8GjjRb7GP7u6toiVJLyo16oiNMSajJjjRblpSclpP7u6toiVJLyo16oiNMSajJjjRb7GtE3tyy4uKJwICX50nnZysYAWYF6oL(KdY7yjMtTUdYPjlqYysYAWYJ3R5wk6dSzOg0lcptdXOS0iN)jxtyEBOj2bJHBJrrzULC(4(WDm2HVWI(aEwFsPCHHHtXY)eFQ5wk6dSzOg0lcptdrW0BIWwq18AU3QFyUwPj8wZTu0hyZmCTspTinm82qtSlmfbImOHJeByQreotaJrrApyoabDy4uoAWyxCSvNCmkttzAM4AFFsxZTu0hyZmCTsZZ0qlchUhra3ghwI3gAA9jLYfggofl)tdWd7dtrGidxDNeJY0uMagJI0Em(MWDqzFcdDylOm2aJ4FAap(32rFahJLgXMAULI(aBMHRvAEMgAjm2cs7yoa5w)EeXBdnLUtPp5G8sySfK2XCaYT(9ikNqmmCADqylf9bmf)tdK9cEVMBPOpWMz4ALMNPHGRUtIrzAQMBPOpWMz4ALMNPHyS0Onmgb66tjHmdW2Skcrie]] )


end
