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

            usable = function () return stealthed.all, "requires stealth" end,
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


    spec:RegisterPack( "Subtlety", 20201111, [[davYXbqiuQ8ikr2eL0NOeigfQsDkuQAvGsPxHQywOuULIcTlf(LOOHPO0XavTmrHNrsQPrsY1OeABOkX3OeW4uuuNdvjvRJsGAEIkDpfzFOQ8puLe4GOkjTqrfpKsunrqjUiQscTrqP4JuIsmskrjDsuLuwPIQxsjqQzIQKOBsjkStsIFsjqYqbLklfuQ6PqmvuvDvff0wPeL6RkkWzrvsq7LWFPyWQ6WuTyu8yrMmrxgzZG8zuYOH0PLSAkrrVwuA2K62Ky3a)wLHtPoUIISCOEUstx46OY2bfFNKA8Gs68IQwpLGMpOY(LAb8c(fispiHkzmBgZcp8WNXy2zN1IwmdbsK3Mei2EkRZIeiaxHeiiCmHMI8ceBpV(CPGFbYEC4ejqqJWETGZmtwvGYXmsNsMBPWP9Ooqc7qrMBPKYuGWWv6GxdiyeispiHkzmBgZcp8WNXy2zN1IQIxxG4Cb6HfiiLILlqqlPKacgbIK2KaXs9JWXeAkY3pS)yXr9Cl1VkhmKcdH7hE4zR)mMnJzfi6AJvWVazdY1bkjf8lubEb)cec4mAskYrGKWvq4Yfi8UFgoiOXgKRd0bND)Wbx)mCqqdyCqTOdo7(zVaXtrDabYI6Yt9g4kljcHkzi4xGqaNrtsrocKeUccxUaHHdcASOC4klbmXHbU8gC29BT)0PWCg7RaXoKeuLQO)CN6pdbINI6acKKR1gpf1bm6AdbIU2WaCfsGavGArfHqfvl4xGqaNrtsrocKeUccxUazTjT2eoMff7yr5Wvwcy24Wk9p1VQ63A)PtH5m2xbITF(M6xvcepf1beijxRnEkQdy01gceDTHb4kKabQa1IkcHkQsWVaHaoJMKICeijCfeUCbs6uyoJ9vGyhscQsv0FUt9dF)Zy)8U)W1eigsISjSzdSholszqaNrtY(T2pdhe0aghul6GZUF2lq8uuhqGKCT24POoGrxBiq01ggGRqceOculQieQyrb)cec4mAskYrGKWvq4YfiHRjqmafl0ydxNLWdc4mAs2V1(XCac6WSOruG8M4G1kzy0UKg0mXv22KuG4POoGazrlyeHqfErWVaHaoJMKICeijCfeUCbIMGH09NB)wmJ(T2VKy4GGgqfqAutEwaT7atkEb2(ZTF473A)HJzrXikfYeNrwu)Zy)ysXlW2pF9Zlcepf1beilQlp1BGRSKieQybe8lqiGZOjPihbINI6acKf1LN6nWvwsGKWvq4YfisIHdcAavaPrn5zb0UdmP4fy7p3(HVFR9V2KwBchZIIDSOC4klbmBCyL(ZDQFv3V1(dhZIIrukKjoJSO(NX(XKIxGTF(6NxeiP8jnzchZIIvOc8IqOYml4xGqaNrtsrocKeUccxUaHD9hUMaXqsKnHnBG9Wzrkdc4mAs2V1(DlKWvqdgTljtbmbkzwuxEQ3b2bz7FQFv3V1(xBsRnHJzrXowuoCLLaMnoSs)t9RAbINI6acKf1LN6nWvwsecv41f8lqiGZOjPihbscxbHlxGaJJlNrtdULm246WvK3GVWJ6a9BTFE3VKy4GGgqfqAutEwaT7atkEb2(ZTF47ho46pCnbIHAYTpGIVbHheWz0KSFR9V2KwBchZIIDSOC4klbmBCyL(ZDQFv1pCW1VBHeUcAuacMkCMsxr(bbCgnj73A)mCqqJnVcZPxZbzKKhOdo7(T2)AtATjCmlk2XIYHRSeWSXHv6p3P(vD)80VBHeUcAWODjzkGjqjZI6Yt9oiGZOjz)SxG4POoGazrD5PEdCLLeHqf4NvWVaHaoJMKICeijCfeUCbYAtATjCmlk2(5BQFv3pp9Z7(z4GGg2ysHKv4rDGbND)Wbx)mCqqJaLm4lccm4S7ho46hZbiOdZIgEw3X1A2JtBGWolfcedAM4kBBs2V1(thqYvXqsKnHnsNflcVdSdY2pFt9Bb6N9cepf1beilkhUYsaZghwrecvGhEb)cec4mAskYrGKWvq4YfisIHdcAavaPrn5zb0UdmP4fy7p3P(HVF4GR)0DA5Pgm28kmNEnhKrsEGoWKIxGT)C7h(zUFR9ljgoiObubKg1KNfq7oWKIxGT)C7pDNwEQbJnVcZPxZbzKKhOdmP4fyfiEkQdiqwuxEQ3axzjriub(me8lqiGZOjPihbc0HnacwdHkWlq8uuhqGyFN2GP94WjsecvGx1c(fieWz0KuKJajHRGWLlqy4GGg2eg6WEqsdmub2XgEkB)8n1Vf73A)Pdi5QyytyOd7bjnWqfyhyhKTF(M6hEvlq8uuhqGWsFNcJ2LKieQaVQe8lq8uuhqGSOU8uVbUYscec4mAskYreIqGq7sGeTc(fQaVGFbcbCgnjf5iqs4kiC5cecqyw5hrPqM4mkoS2pF9dF)w7ND9ZWbbn28kmNEnhKrsEGo4S73A)8UF21V8Ir6ajceypiPbs7kKHHddgrLYwaw9BTF21VNI6aJ0bseiWEqsdK2vOrbmq6IfA0pCW1peNwBWuc1XSituku)52pRKCO4WA)SxG4POoGajDGebcShK0aPDfsecvYqWVaHaoJMKICeijCfeUCbc76pDNwEQbJf1LNAdJ2L0o4S73A)P70YtnyS5vyo9AoiJK8aDWz3pCW1puXcnmysXlW2FUt9d)Scepf1beim67KMdYeOKHaKsEriur1c(fiEkQdiqyX5yz5aZbzClKWxGkqiGZOjPihriurvc(fieWz0KuKJajHRGWLlq4D)RnP1MWXSOyhlkhUYsaZghwPF(M6pJ(HdU(XEjnemeigUuUJc0pF9ZlZ2p773A)SR)0DA5Pgm28kmNEnhKrsEGo4S73A)SRFgoiOXMxH50R5GmsYd0bND)w7NaeMv(HKGQuf9Z3u)QEwbINI6aceOlXTK04wiHRGmmKRicHkwuWVaHaoJMKICeijCfeUCbYAtATjCmlk2XIYHRSeWSXHv6NVP(ZOF4GRFSxsdbdbIHlL7Oa9Zx)8YScepf1bei2C4ckFbyzy0(gIqOcVi4xGqaNrtsrocKeUccxUaHHdcAGPuwnTRb6WjAWz3pCW1pdhe0atPSAAxd0HtKjDCGGWJn8u2(ZTF4NvG4POoGajqjdhG54asd0HtKieQybe8lq8uuhqGGlBBnzkGzT9ejqiGZOjPihriuzMf8lqiGZOjPihbscxbHlxGKUtlp1GXMxH50R5GmsYd0bMu8cS9NB)wSF4GRFOIfAyWKIxGT)C7h(zwG4POoGar9H1syOcyW0EahKiriuHxxWVaHaoJMKICeijCfeUCbcbimR89NB)QA2(T2pdhe0yZRWC61Cqgj5b6GZwG4POoGarHuoCEZbz0CPsAKyYvwriub(zf8lqiGZOjPihbscxbHlxGavSqddMu8cS9NB)WpSy)Wbx)8UFE3F4ywumqjxhOd7u0pF9pZZ2pCW1F4ywumqjxhOd7u0FUt9NXS9Z((T2pV73trbdziaPu02)u)W3pCW1puXcnmysXlW2pF9NbVE)SVF23pCW1pV7pCmlkgrPqM4m2PWKXS9Zx)QE2(T2pV73trbdziaPu02)u)W3pCW1puXcnmysXlW2pF9Rkv1p77N9cepf1beiyYTlaldK2vOveIqGijiNthc(fQaVGFbINI6acKSvkRaHaoJMKICeHqLme8lqiGZOjPihbYzlqwkeiEkQdiqGXXLZOjbcmUMJeimCqqJvxjY4aPrwjAWz3pCW1)AtATjCmlk2XIYHRSeWSXHv6NVP(5fbcmo2aCfsGSaPjDazf1beHqfvl4xGqaNrtsrocepf1beijxRnEkQdy01gceDTHb4kKajjxriurvc(fieWz0KuKJajHRGWLlq2GCDGsYHR1cepf1beiyoGXtrDaJU2qGORnmaxHeiBqUoqjPieQyrb)cec4mAskYrGKWvq4YfiRnP1MWXSOyhlkhUYsaZghwP)C7Nx63A)qfl0WGjfVaB)81pV0V1(z4GGgRUsKXbsJSs0atkEb2(ZTFwj5qXH1(T2F6uyoJ9vGy7NVP(vv)Zy)8U)OuO(ZTF4NTF23pST)meiEkQdiqwDLiJdKgzLiriuHxe8lqiGZOjPihbYzlqwkeiEkQdiqGXXLZOjbcmUMJei246WvK3GVWJ6a9BT)1M0At4ywuSJfLdxzjGzJdR0pFt9NHabghBaUcjq4wYyJRdxrEd(cpQdicHkwab)cec4mAskYrGKWvq4YfiW44Yz00GBjJnUoCf5n4l8OoGaXtrDabsY1AJNI6agDTHarxByaUcjq2GCDGAsYvecvMzb)cec4mAskYrGC2cKLcbINI6aceyCC5mAsGaJR5ibsgwSFE6pCnbIbmfRdpiGZOjz)W2(Zy2(5P)W1eigk(ge2CqMf1LN6DqaNrtY(HT9NXS9Zt)HRjqmwuxEQnqxIBheWz0KSFyB)zyX(5P)W1eigU2t4kYpiGZOjz)W2(Zy2(5P)mSy)W2(5D)RnP1MWXSOyhlkhUYsaZghwPF(M6xv9ZEbcmo2aCfsGSb56a1eOyArpTuecv41f8lqiGZOjPihbscxbHlxGqacZk)qsqvQI(ZDQFyCC5mAASb56a1eOyArpTuG4POoGaj5ATXtrDaJU2qGORnmaxHeiBqUoqnj5kcHkWpRGFbcbCgnjf5iqs4kiC5cemhGGomlAijpq15nlQlp17GMjUY2MK9BTF5fJLS3AhrLYwaw9BTF5fJLS3AhysXlW2FUt9Nr)w7pDkmNX(kqS9Z3u)ziq8uuhqGKCT24POoGrxBiq01ggGRqceOculQieQap8c(fieWz0KuKJajHRGWLlqsNcZzSVceB)t97GsXtOoMfjnjBbINI6acKKR1gpf1bm6AdbIU2WaCfsGavGArfHqf4ZqWVaHaoJMKICeijCfeUCbs6uyoJ9vGyhscQsv0FUt9dF)Wbx)qfl0WGjfVaB)5o1p89BT)0PWCg7RaX2pFt9RAbINI6acKKR1gpf1bm6AdbIU2WaCfsGavGArfHqf4vTGFbcbCgnjf5iqs4kiC5cK1M0At4ywuSJfLdxzjGzJdR0pFt9RQ(T2F6uyoJ9vGy7NVP(vLaXtrDabsY1AJNI6agDTHarxByaUcjqGkqTOIqOc8QsWVaHaoJMKICeijCfeUCbcbimR8djbvPk6p3P(HXXLZOPXgKRdutGIPf90sbINI6acKKR1gpf1bm6AdbIU2WaCfsGWWvAPieQaVff8lqiGZOjPihbscxbHlxGqacZk)qsqvQI(5BQF4Ty)80pbimR8dmXIacepf1beioo5aYehgtGqecvGNxe8lq8uuhqG44KdiJnNEjbcbCgnjf5icHkWBbe8lq8uuhqGOlwOXASm5KSuiqiqiGZOjPihriub(zwWVaXtrDabcJZYCqMaxPSRaHaoJMKICeHiei2ykDkmEi4xOc8c(fiEkQdiqCBBDEJ9v7beieWz0KuKJieQKHGFbINI6acKnixhOcec4mAskYrecvuTGFbcbCgnjf5iq8uuhqGO44SK0aDyJK8avGyJP0PW4HzP0bKRabElkcHkQsWVaHaoJMKICeiEkQdiqwDLiJdKgzLibscxbHlxGGjimTOoJMei2ykDkmEywkDa5kqGxecvSOGFbcbCgnjf5iqs4kiC5cemhGGomlAO44SMdYeOKrX3GWgFxF3cmOzIRSTjPaXtrDabYI6YtTHr7sAfHqfErWVaHaoJMKICeiaxHeiUfUOo2xd0bcZbzSp1ewG4POoGaXTWf1X(AGoqyoiJ9PMWIqeceOculQGFHkWl4xGqaNrtsrocKeUccxUazTjT2eoMff7yr5Wvwcy24Wk9NB)8s)w7ND9ZWbbnwuxEQnshKObND)w7NHdcAS6krghinYkrdmP4fy7p3(HkwOHbtkEb2(T2pdhe0y1vImoqAKvIgysXlW2FU9Z7(HVFE6pDkmNX(kqS9Z((HT9d)yMfiEkQdiqwDLiJdKgzLiriujdb)cec4mAskYrGC2cKLcbINI6aceyCC5mAsGaJR5ibIIVbHn(U(UfWGjfVaB)81)S9dhC9ZU(dxtGyakwOXgUolHheWz0KSFR9hUMaXq64SMf1LN6bbCgnj73A)mCqqJf1LNAJ0bjAWz3pCW1)AtATjCmlk2XIYHRSeWSXHv6NVP(5fbcmo2aCfsGSzlBdMZo4WKieQOAb)cec4mAskYrGKWvq4YfiSRFyCC5mAASzlBdMZo4Wu)w7pCmlkgrPqM4mYI6Fg7htkEb2(5RFEPFR9JjimTOoJMeiEkQdiqWC2bhMeHqfvj4xG4POoGazPeMctqjuqntCKaHaoJMKICeHqflk4xGqaNrtsrocepf1beiyo7GdtcKeUccxUaHD9dJJlNrtJnBzBWC2bhM63A)SRFyCC5mAAWTKXgxhUI8g8fEuhOFR9V2KwBchZIIDSOC4klbmBCyL(5BQ)m63A)HJzrXikfYeNrwu)8n1pV73I9Zt)8U)m6h22F6uyoJ9vGy7N99Z((T2pMGW0I6mAsGKYN0KjCmlkwHkWlcHk8IGFbcbCgnjf5iqs4kiC5ce21pmoUCgnn2SLTbZzhCyQFR9JjfVaB)52F6oT8udgBEfMtVMdYijpqhysXlW2pp9d)S9BT)0DA5Pgm28kmNEnhKrsEGoWKIxGT)CN63I9BT)WXSOyeLczIZilQ)zSFmP4fy7NV(t3PLNAWyZRWC61Cqgj5b6atkEb2(5PFlkq8uuhqGG5SdomjcHkwab)cec4mAskYrGKWvq4YfiSRFyCC5mAAWTKXgxhUI8g8fEuhOFR9V2KwBchZIITF(M6x1cepf1beimApL1yFQLewecvMzb)cepf1beiem1MiShKaHaoJMKICeHieij5k4xOc8c(fieWz0KuKJajHRGWLlqyx)mCqqJf1LNAJ0bjAWz3V1(z4GGglkhUYsatCyGlVbND)w7NHdcASOC4klbmXHbU8gysXlW2FUt9R6HffiEkQdiqwuxEQnshKibc3sMdcYWkjfQaVieQKHGFbcbCgnjf5iqs4kiC5cegoiOXIYHRSeWehg4YBWz3V1(z4GGglkhUYsatCyGlVbMu8cS9N7u)QEyrbINI6acKnVcZPxZbzKKhOceULmheKHvskubEriur1c(fieWz0KuKJajHRGWLlqGXXLZOPXcKM0bKvuhOFR9ZU(3GCDGsYHIdcnjq8uuhqGaPDwKw7rDariurvc(fieWz0KuKJajHRGWLlqKedhe0as7SiT2J6admP4fy7p3(ZqG4POoGabs7SiT2J6aMKMCWsIqOIff8lqiGZOjPihbscxbHlxGW7(XCac6WSOHIJZAoitGsgfFdcB8D9DlWGMjUY2MK9BT)0PWCg7RaXoKeuLQO)CN6x19dhC9J5ae0Hzrdj5bQoVzrD5PEh0mXv22KSFR9NofMZyFfi2(ZTF47N99BTFgoiOXMxH50R5GmsYd0bND)w7NHdcASOU8uBKoirdo7(T2VIVbHn(U(UfWGjfVaB)t9pB)w7NHdcAijpq15nlQlp17qEQbcepf1beiW4GArfHqfErWVaHaoJMKICeijCfeUCbc76FdY1bkjhUw3V1(HXXLZOPXcKM0bKvuhOF4GRFAxcKObdM8a1CqMaLmY8fG1qXTmpC)w7pkfQF(M6pdbINI6acKKR1gpf1bm6AdbIU2WaCfsGq7sGeTIqOIfqWVaHaoJMKICeiEkQdiqSVtBW0EC4ejqs4kiC5cKW1eiglkhUYsatCyGlVbbCgnj73A)SR)W1eiglQlp1gOlXTdc4mAskqGoSbqWAiubEriuzMf8lqiGZOjPihbscxbHlxGqacZkF)8n1pVmB)w7hghxoJMglqAshqwrDG(T2F6oT8udgBEfMtVMdYijpqhC29BT)0DA5PgmwuxEQnshKOrc1XSOTF(M6hEbINI6acKfLdxzjGjomWLNieQWRl4xGqaNrtsrocepf1beilHXEqsdZbiZAxzjbscxbHlxGaJJlNrtJfinPdiROoq)w7ND9lVySeg7bjnmhGmRDLLmYlgrLYwaw9BT)WXSOyeLczIZilQF(M6pd47ho46hQyHggmP4fy7p3P(Ty)w7FTjT2eoMff7yr5Wvwcy24Wk9NB)QwGKYN0KjCmlkwHkWlcHkWpRGFbcbCgnjf5iqs4kiC5ceyCC5mAASaPjDazf1b63A)PtH5m2xbIDijOkvr)8n1p8cepf1beilzV1kcHkWdVGFbcbCgnjf5iqs4kiC5ceyCC5mAASaPjDazf1b63A)SR)0DA5PgmwuxEQnmAxs7GZUFR9Z7(dxtGyqayi9zxawMf1LN6DqaNrtY(HdU(t3PLNAWyrD5P2iDqIgjuhZI2(5BQF47N99BTFE3p76pCnbIXIYHRSeWehg4YBqaNrtY(HdU(dxtGySOU8uBGUe3oiGZOjz)Wbx)P70YtnySOC4klbmXHbU8gysXlW2pF9Nr)SVFR9Z7(zx)0Ueirdg9DsZbzcuYqasj)qXTmpC)Wbx)P70YtnyWOVtAoitGsgcqk5hysXlW2pF9Nr)SxG4POoGazZRWC61Cqgj5bQieQaFgc(fieWz0KuKJaXtrDabIIJZssd0HnsYdubscxbHlxGG9sAiyiqmCPChC29BTFE3F4ywumIsHmXzKf1FU9NofMZyFfi2HKGQuf9dhC9ZU(3GCDGsYHR19BT)0PWCg7RaXoKeuLQOF(M6pzBuCy1S2eq2p7fiP8jnzchZIIvOc8IqOc8QwWVaHaoJMKICeijCfeUCbc2lPHGHaXWLYDuG(5RFvpB)Zy)yVKgcgcedxk3HKd7rDG(T2F6uyoJ9vGyhscQsv0pFt9NSnkoSAwBcifiEkQdiquCCwsAGoSrsEGkcHkWRkb)cec4mAskYrGKWvq4YfiW44Yz00ybst6aYkQd0V1(tNcZzSVce7qsqvQI(5BQ)meiEkQdiqwuxEQnmAxsRieQaVff8lqiGZOjPihbscxbHlxGaJJlNrtJfinPdiROoq)w7pDkmNX(kqSdjbvPk6NVP(vD)w7N39dJJlNrtdULm246WvK3GVWJ6a9dhC9V2KwBchZIIDSOC4klbmBCyL(ZDQFv1p7fiEkQdiqOe6vawgmzJlfhifHqf45fb)cec4mAskYrGKWvq4YfiHRjqmwuxEQnqxIBheWz0KSFR9dJJlNrtJfinPdiROoq)w7NHdcAS5vyo9AoiJK8aDWzlq8uuhqGSOC4klbmXHbU8eHqf4Tac(fieWz0KuKJajHRGWLlqyx)mCqqJf1LNAJ0bjAWz3V1(HkwOHbtkEb2(ZDQ)zUFE6pCnbIXYXeegIJfniGZOjPaXtrDabYI6YtTr6GejcHkWpZc(fiEkQdiqSVOoGaHaoJMKICeHqf451f8lqiGZOjPihbscxbHlxGWWbbn28kmNEnhKrsEGo4SfiEkQdiqy03jnqC48IqOsgZk4xGqaNrtsrocKeUccxUaHHdcAS5vyo9AoiJK8aDWzlq8uuhqGWq4LWzlalriujd4f8lqiGZOjPihbscxbHlxGWWbbn28kmNEnhKrsEGo4SfiEkQdiqGkmXOVtkcHkzKHGFbcbCgnjf5iqs4kiC5cegoiOXMxH50R5GmsYd0bNTaXtrDabIds0gyxBsUwlcHkzOAb)cec4mAskYrG4POoGajLpPVaFGkzy0(gcKeUccxUaHD9Vb56aLKdxR73A)W44Yz00ybst6aYkQd0V1(zx)mCqqJnVcZPxZbzKKhOdo7(T2pbimR8djbvPk6NVP(v9SceccIsHb4kKajLpPVaFGkzy0(gIqOsgQsWVaHaoJMKICeiEkQdiqClCrDSVgOdeMdYyFQjSajHRGWLlqyx)mCqqJf1LNAJ0bjAWz3V1(t3PLNAWyZRWC61Cqgj5b6atkEb2(ZTF4NvGaCfsG4w4I6yFnqhimhKX(utyriujdlk4xGqaNrtsrocepf1bei(IcJdO1GDl8WM0HDTajHRGWLlqKedhe0a7w4HnPd7AJKy4GGgYtnOF4GRFjXWbbnshqYLIcgYuGSgjXWbbn4S73A)HJzrXaLCDGoStr)52VQZOFR9hoMffduY1b6Wof9Z3u)QE2(HdU(zx)sIHdcAKoGKlffmKPaznsIHdcAWz3V1(5D)sIHdcAGDl8WM0HDTrsmCqqJn8u2(5BQ)mSy)Zy)WpB)W2(Ledhe0GrFN0CqMaLmeGuYp4S7ho46hQyHggmP4fy7p3(v1S9Z((T2pdhe0yZRWC61Cqgj5b6atkEb2(5R)zwGaCfsG4lkmoGwd2TWdBsh21IqOsg8IGFbcbCgnjf5iqaUcjquYl91eUUwfhiq8uuhqGOKx6RjCDTkoqecvYWci4xGqaNrtsrocKeUccxUaHHdcAS5vyo9AoiJK8aDWz3pCW1puXcnmysXlW2FU9NXScepf1beiClzQGuwricbYgKRdutsUc(fQaVGFbcbCgnjf5iqoBbYsHaXtrDabcmoUCgnjqGX1CKajDNwEQbJf1LNAJ0bjAKqDmlAnqypf1bCD)8n1p8dlGffiW4ydWvibYIknbkMw0tlfHqLme8lqiGZOjPihbscxbHlxGW7(zx)W44Yz00yrLMaftl6PL9dhC9ZU(dxtGyakwOXgUolHheWz0KSFR9hUMaXq64SMf1LN6bbCgnj7N99BT)0PWCg7RaXoKeuLQOF(6h((T2p76hZbiOdZIgkooR5Gmbkzu8niSX313TadAM4kBBskq8uuhqGaJdQfvecvuTGFbcbCgnjf5iq8uuhqGyFN2GP94WjsGqWAGDJRCCGqGOQzfiqh2aiyneQaVieQOkb)cec4mAskYrGKWvq4YfieGWSY3pFt9RQz73A)eGWSYpKeuLQOF(M6h(z73A)SRFyCC5mAASOstGIPf90Y(T2F6uyoJ9vGyhscQsv0pF9dF)w7xsmCqqdOcinQjplG2DGjfVaB)52p8cepf1beilQlp1kKwkcHkwuWVaHaoJMKICeiNTazPqG4POoGabghxoJMeiW4AosGKofMZyFfi2HKGQuf9Z3u)QsGaJJnaxHeilQ0KofMZyFfiwriuHxe8lqiGZOjPihbYzlqwkeiEkQdiqGXXLZOjbcmUMJeiPtH5m2xbIDijOkvr)5o1p8cKeUccxUabghxoJMgClzSX1HRiVbFHh1b63A)RnP1MWXSOyhlkhUYsaZghwPF(M6xvceyCSb4kKazrLM0PWCg7RaXkcHkwab)cec4mAskYrGKWvq4YfiW44Yz00yrLM0PWCg7RaX2V1(5D)W44Yz00yrLMaftl6PL9dhC9ZWbbn28kmNEnhKrsEGoWKIxGTF(M6h(rg9dhC9V2KwBchZIIDSOC4klbmBCyL(5BQFv1V1(t3PLNAWyZRWC61Cqgj5b6atkEb2(5RF4NTF2lq8uuhqGSOU8uBKoirIqOYml4xGqaNrtsrocKeUccxUabghxoJMglQ0KofMZyFfi2(T2puXcnmysXlW2FU9NUtlp1GXMxH50R5GmsYd0bMu8cScepf1beilQlp1gPdsKieHaHHR0sb)cvGxWVaHaoJMKICeijCfeUCbc76pCnbIbOyHgB46SeEqaNrtY(T2pMdqqhMfnIcK3ehSwjdJ2L0GMjUY2MKcepf1beilAbJieQKHGFbcbCgnjf5iqs4kiC5cK1M0At4ywuS9Z3u)z0pp9Z7(dxtGyWsFNcJ2L0GaoJMK9BTF3cjCf0WMWqh2dAGDq2(5BQ)m6N9cepf1beilkhUYsaZghwrecvuTGFbcbCgnjf5iqs4kiC5cK0DA5PgmwcJ9GKgMdqM1UYsJeQJzrRbc7POoGR7NVP(ZyybSy)Wbx)7XPzkGCOjxAyYBiy1vS10GaoJMK9BTF21pdhe0qtU0WK3qWQRyRPbNTaXtrDabYsyShK0WCaYS2vwsecvuLGFbINI6acew67uy0UKeieWz0KuKJieQyrb)cepf1beimEk7goJaHaoJMKICeHieHabgcV1beQKXSzml8WplViqu7yqbyTcKzaVkSxfEnvSSyb3F)8Js9xk2ho6h6W9BbHHR0sli9JPzIRWKS)9uO(DU4u8GK9NqDalAh9CELfG6pdl4(H9KYbdj73(2kQdyy8u2(tOukB)8gCr)omEPDgn1Fb6Nu40EuhG99ZB4Hv2p659CEnf7dhKS)zUFpf1b6xxBSJEUaXgFqLMeiwQFeoMqtr((H9hloQNBP(v5GHuyiC)WdpB9NXSzmBpVNBP(HDyAgT8tHXJEUNI6a7WgtPtHXdEMY0TT15n2xThON7POoWoSXu6uy8GNPm3GCDG2Z9uuhyh2ykDkmEWZuMkooljnqh2ijpqzZgtPtHXdZsPdi3j4Typ3trDGDyJP0PW4bptzU6krghinYkrSzJP0PW4HzP0bK7e8SvqtycctlQZOPEUNI6a7WgtPtHXdEMYCrD5P2WODjTSvqtyoabDyw0qXXznhKjqjJIVbHn(U(UfyqZexzBtYEUNI6a7WgtPtHXdEMYKBjtfKcBaxHMClCrDSVgOdeMdYyFQjCpVNBP(Tm8c0pS)cpQd0Z9uuhyNYwPS9Cpf1bwEMYeghxoJMyd4k00cKM0bKvuhGnyCnhnXWbbnwDLiJdKgzLObNnCWT2KwBchZIIDSOC4klbmBCyf(M4f2MHlj7pU(LuqyLcq9RgLcuc3F6oT8ud2(v7v0p0H7hbal9Z4lj7)a9hoMff7ONBP(TCukLTFlhw2(9OFOcVrp3trDGLNPmtUwB8uuhWORnyd4k0usU9Cl1pSNd0peNwNV)vDfjuA7pU(duQFKGCDGsY(H9x4rDG(5nt((Lxby1)ESvr)qhorB)23PlaR(lO(bxGwaw9xB)omEPDgnX(rp3trDGLNPmXCaJNI6agDTbBaxHM2GCDGss2kOPnixhOKC4ADp3s9ZRABRZ3)QRezCG0iRe1Vh9Nbp9B5WU(LC4cWQ)aL6hQWB0p8Z2)sPdix2COGW9hOE0VQ4PFlh21Fb1Ff9tWQDHPTF1vGwG(duQFabRr)wwSCyP)d3FT9dUOFo7EUNI6alptzU6krghinYkrSvqtRnP1MWXSOyhlkhUYsaZghwjxEXkuXcnmysXlWYhVyLHdcAS6krghinYkrdmP4fyZLvsouCy1A6uyoJ9vGy5BsvZiVJsHYf(zzpSnJEUL63ckGoF)juhWI6hFHh1b6VG6xn1pQdd1VnUoCf5n4l8Ooq)lf97az)kC6OS1u)HJzrX2pN9ON7POoWYZuMW44Yz0eBaxHM4wYyJRdxrEd(cpQdWgmUMJMSX1HRiVbFHh1bSU2KwBchZIIDSOC4klbmBCyf(MYONBP(HD46WvKVFy)fEuhGxb9ZRKcliB)SkyO(9(ty3UFN54I(jaHzLVFOd3FGs9Vb56aTFlhw2(5ndxPLeU)nkTUFmT2uk6Vc2p6NxHC2Svr)jh0pd1FG6r)BPyRPrp3trDGLNPmtUwB8uuhWORnyd4k00gKRdutsUSvqtW44Yz00GBjJnUoCf5n4l8Ooqp3s9pdxs2FC9ljOcq9RgLa9hx)Cl1)gKRd0(TCyz7)W9ZWvAjH3EUNI6alptzcJJlNrtSbCfAAdY1bQjqX0IEAjBW4AoAkdlYt4AcedykwhEqaNrtsyBgZYt4AcedfFdcBoiZI6Yt9oiGZOjjSnJz5jCnbIXI6YtTb6sC7GaoJMKW2mSipHRjqmCTNWvKFqaNrtsyBgZYtgwe2Y71M0At4ywuSJfLdxzjGzJdRW3KQyFp3s9B5hyljH7NBlaR(9(rcY1bA)woS0VAuc0pM8eAby1FGs9tacZkF)bkMw0tl75EkQdS8mLzY1AJNI6agDTbBaxHM2GCDGAsYLTcAIaeMv(HKGQuf5obJJlNrtJnixhOMaftl6PL9Cpf1bwEMYm5ATXtrDaJU2GnGRqtqfOwu2kOjmhGGomlAijpq15nlQlp17GMjUY2MKwLxmwYERDevkBbyzvEXyj7T2bMu8cS5oLH10PWCg7RaXY3ug9Cpf1bwEMYm5ATXtrDaJU2GnGRqtqfOwu2kOP0PWCg7RaXo5GsXtOoMfjnj7EUL6h2uGAr73J(vfp9RUc0Jl6hwqyRFlYt)QRaTFybPFEFCXwsQ)nixhOSVN7POoWYZuMjxRnEkQdy01gSbCfAcQa1IYwbnLofMZyFfi2HKGQuf5obpCWbvSqddMu8cS5obV10PWCg7RaXY3KQ75wQ)zqfO9dli97696hQa1I2Vh9RkE63z5fyJ(vv)HJzrX2pVpUylj1)gKRdu23Z9uuhy5zkZKR1gpf1bm6Ad2aUcnbvGArzRGMwBsRnHJzrXowuoCLLaMnoScFtQYA6uyoJ9vGy5Bsv9Cl1)mCP(9(z4kTKW9RgLa9JjpHwaw9hOu)eGWSY3FGIPf90YEUNI6alptzMCT24POoGrxBWgWvOjgUslzRGMiaHzLFijOkvrUtW44Yz00ydY1bQjqX0IEAzp3s9ZR8utB0VnUoCf57Va97AD)hu)bk1pVkSJxz)muY5wQ)k6p5ClT979BzXYHLEUNI6alptz64KditCymbc2kOjcqyw5hscQsvW3e8wKhcqyw5hyIfb65EkQdS8mLPJtoGm2C6L65EkQdS8mLPUyHgRXYKtYsHarp3trDGLNPmzCwMdYe4kLD759Cl1VLFNwEQbBp3s9pdxQFyXbjQ)dcAgzLK9ZqqhM6pqP(Hk8g9VOC4klbmBCyL(HWNs)8FyGlV(tNcT9xGrp3trDGDKKlptzUOU8uBKoirSXTK5GGmSsYj4zRGMyhdhe0yrD5P2iDqIgC2wz4GGglkhUYsatCyGlVbNTvgoiOXIYHRSeWehg4YBGjfVaBUtQEyXEUL6N3ZqGM2TFxJjxMVFo7(zOKZTu)QP(J7Y2pcQlp19dBUe3Y((5wQFK8kmNE7)GGMrwjz)me0HP(duQFOcVr)lkhUYsaZghwPFi8P0p)hg4YR)0PqB)fy0Z9uuhyhj5YZuMBEfMtVMdYijpqzJBjZbbzyLKtWZwbnXWbbnwuoCLLaM4WaxEdoBRmCqqJfLdxzjGjomWL3atkEb2CNu9WI9Cpf1b2rsU8mLjK2zrATh1byRGMGXXLZOPXcKM0bKvuhWk72GCDGsYHIdcn1Z9uuhyhj5YZuMqANfP1EuhWK0KdwITcAssmCqqdiTZI0ApQdmWKIxGn3m65EkQdSJKC5zktyCqTOSvqt8gZbiOdZIgkooR5Gmbkzu8niSX313TadAM4kBBsAnDkmNX(kqSdjbvPkYDs1WbhMdqqhMfnKKhO68Mf1LN6DqZexzBtsRPtH5m2xbInx4zVvgoiOXMxH50R5GmsYd0bNTvgoiOXI6YtTr6Gen4STQ4BqyJVRVBbmysXlWonRvgoiOHK8avN3SOU8uVd5Pg0Z9uuhyhj5YZuMjxRnEkQdy01gSbCfAI2LajAzRGMy3gKRdusoCT2kmoUCgnnwG0KoGSI6aWbhTlbs0GbtEGAoitGsgz(cWAO4wMh2AukeFtz0ZTu)WU709dD4(5)WaxE9BJPze5GL(vxbA)iOWs)yYL57xnkb6hCr)yoaOaS6hb2m65EkQdSJKC5zkt770gmThhorSbDydGG1ycE2kOPW1eiglkhUYsatCyGlVbbCgnjTYUW1eiglQlp1gOlXTdc4mAs2ZTu)ZWL6N)ddC51VnM6h5GL(vJsG(vt9J6Wq9hOu)eGWSY3VAukqjC)q4tPF770fGv)QRa94I(rGn9F4(Tm52OFweGWUwNF0Z9uuhyhj5YZuMlkhUYsatCyGlp2kOjcqyw55BIxM1kmoUCgnnwG0KoGSI6awt3PLNAWyZRWC61Cqgj5b6GZ2A6oT8udglQlp1gPds0iH6yw0Y3e89Cpf1b2rsU8mL5syShK0WCaYS2vwITu(KMmHJzrXobpBf0emoUCgnnwG0KoGSI6awzN8IXsyShK0WCaYS2vwYiVyevkBbyznCmlkgrPqM4mYI4Bkd4HdoOIfAyWKIxGn3jlADTjT2eoMff7yr5Wvwcy24Wk5Q6EUNI6a7ijxEMYCj7Tw2kOjyCC5mAASaPjDazf1bSMofMZyFfi2HKGQuf8nbFp3s9pdxQFK8kmNE7)a9NUtlp1G(5TdfeUFOcVr)iayH99Zb00U9RM63Xu)SUcWQ)463(S7N)ddC51VdK9lV(bx0pQdd1pcQlp19dBUe3o65EkQdSJKC5zkZnVcZPxZbzKKhOSvqtW44Yz00ybst6aYkQdyLDP70YtnySOU8uBy0UK2bNTvEhUMaXGaWq6ZUaSmlQlp17GaoJMKWbx6oT8udglQlp1gPds0iH6yw0Y3e8S3kVzx4AceJfLdxzjGjomWL3GaoJMKWbx4AceJf1LNAd0L42bbCgnjHdU0DA5PgmwuoCLLaM4WaxEdmP4fy5ld2BL3SJ2LajAWOVtAoitGsgcqk5hkUL5HHdU0DA5Pgmy03jnhKjqjdbiL8dmP4fy5ld23ZTu)8Aq97s52VJP(5SzR)fu2u)bk1)bO(vxbA)6tnTr)8ZpSm6FgUu)Qrjq)Y8fGv)q(geU)a1b9B5WU(LeuLQO)d3p4I(3GCDGsY(vxb6Xf97G89B5WUrp3trDGDKKlptzQ44SK0aDyJK8aLTu(KMmHJzrXobpBf0e2lPHGHaXWLYDWzBL3HJzrXikfYeNrwuUPtH5m2xbIDijOkvbCWXUnixhOKC4AT10PWCg7RaXoKeuLQGVPKTrXHvZAtaj775wQFEnO(bx)UuU9RU06(Lf1V6kqlq)bk1pGG1OFvp7Yw)Cl1VLbeS0)b6N52TF1vGECr)oiF)woSB0Z9uuhyhj5YZuMkooljnqh2ijpqzRGMWEjnemeigUuUJcWNQNDgXEjnemeigUuUdjh2J6awtNcZzSVce7qsqvQc(Ms2gfhwnRnbK9Cpf1b2rsU8mL5I6YtTHr7sAzRGMGXXLZOPXcKM0bKvuhWA6uyoJ9vGyhscQsvW3ug9Cpf1b2rsU8mLjLqVcWYGjBCP4ajBf0emoUCgnnwG0KoGSI6awtNcZzSVce7qsqvQc(MuTvEdJJlNrtdULm246WvK3GVWJ6aWb3AtATjCmlk2XIYHRSeWSXHvYDsvSVNBP(NbvG2pcSHT(lO(bx0VRXKlZ3V8aeB9ZTu)8FyGlV(vxbA)ihS0pN9ON7POoWosYLNPmxuoCLLaM4WaxESvqtHRjqmwuxEQnqxIBheWz0K0kmoUCgnnwG0KoGSI6awz4GGgBEfMtVMdYijpqhC29Cpf1b2rsU8mL5I6YtTr6GeXwbnXogoiOXI6YtTr6Gen4STcvSqddMu8cS5onZ8eUMaXy5yccdXXIgeWz0KSN3ZTu)QCGzCTPu)BWbb1V6kq7xFQjC)24665EkQdSJKC5zkt7lQd0Z9uuhyhj5YZuMm67KgioCE2kOjgoiOXMxH50R5GmsYd0bNDp3trDGDKKlptzYq4LWzlal2kOjgoiOXMxH50R5GmsYd0bNDp3trDGDKKlptzcvyIrFNKTcAIHdcAS5vyo9AoiJK8aDWz3Z9uuhyhj5YZuMoirBGDTj5AnBf0edhe0yZRWC61Cqgj5b6GZUN3Z9uuhyhj5YZuMClzQGuyJGGOuyaUcnLYN0xGpqLmmAFd2kOj2Tb56aLKdxRTcJJlNrtJfinPdiROoGv2XWbbn28kmNEnhKrsEGo4STsacZk)qsqvQc(Mu9S9Cpf1b2rsU8mLj3sMkif2aUcn5w4I6yFnqhimhKX(uty2kOj2XWbbnwuxEQnshKObNT10DA5Pgm28kmNEnhKrsEGoWKIxGnx4NTNBP(VaLWQRL6xDfO9JCWs)E0FgwKN(3Wtz3(pC)WBrE6xDfO97696ph9DY(5Sh9Cpf1b2rsU8mLj3sMkif2aUcn5lkmoGwd2TWdBsh21SvqtsIHdcAGDl8WM0HDTrsmCqqd5PgahCsIHdcAKoGKlffmKPaznsIHdcAWzBnCmlkgOKRd0HDkYv1zynCmlkgOKRd0HDk4Bs1ZchCStsmCqqJ0bKCPOGHmfiRrsmCqqdoBR8wsmCqqdSBHh2KoSRnsIHdcASHNYY3ugwCgHFwyRKy4GGgm67KMdYeOKHaKs(bNnCWbvSqddMu8cS5QQzzVvgoiOXMxH50R5GmsYd0bMu8cS8nZ9Cl1VLnHZ3p(4yHQZ3pMtt9Fq9hOCkmfurY(v8aD7NH0NAl4(NHl1p0H7NxdK1(K9NWv0Z9uuhyhj5YZuMClzQGuyd4k0KsEPVMW11Q4GEUL6hwiiNth9d5AnJNY2p0H7NBDgn1FfKYAb3)mCP(vxbA)i5vyo92)b1pSqEGo65EkQdSJKC5zktULmvqklBf0edhe0yZRWC61Cqgj5b6GZgo4GkwOHbtkEb2CZy2EEp3s9ZRAHeUcQFEf3LajA75EkQdSdAxcKOLNPmthirGa7bjnqAxHyRGMiaHzLFeLczIZO4WkFWBLDmCqqJnVcZPxZbzKKhOdoBR8MDYlgPdKiqG9GKgiTRqggomyevkBbyzLDEkQdmshirGa7bjnqAxHgfWaPlwObCWbXP1gmLqDmlYeLcLlRKCO4Wk775EkQdSdAxcKOLNPmz03jnhKjqjdbiL8SvqtSlDNwEQbJf1LNAdJ2L0o4STMUtlp1GXMxH50R5GmsYd0bNnCWbvSqddMu8cS5ob)S9Cpf1b2bTlbs0YZuMS4CSSCG5GmUfs4lq75EkQdSdAxcKOLNPmHUe3ssJBHeUcYWqUcBf0eVxBsRnHJzrXowuoCLLaMnoScFtzahCyVKgcgcedxk3rb4JxML9wzx6oT8udgBEfMtVMdYijpqhC2wzhdhe0yZRWC61Cqgj5b6GZ2kbimR8djbvPk4Bs1Z2Z9uuhyh0UeirlptzAZHlO8fGLHr7BWwbnT2KwBchZIIDSOC4klbmBCyf(MYao4WEjnemeigUuUJcWhVmBp3trDGDq7sGeT8mLzGsgoaZXbKgOdNi2kOjgoiObMsz10UgOdNObNnCWXWbbnWukRM21aD4ezshhii8ydpLnx4NTN7POoWoODjqIwEMYex22AYuaZA7jQN7POoWoODjqIwEMYu9H1syOcyW0EahKi2kOP0DA5Pgm28kmNEnhKrsEGoWKIxGnxlchCqfl0WGjfVaBUWpZ9Cpf1b2bTlbs0YZuMkKYHZBoiJMlvsJetUYYwbnracZkFUQAwRmCqqJnVcZPxZbzKKhOdo7EUL63Y6PL9d7j3UaS6h2ODfA7h6W9tWkL4cQFSdyr9F4(ZwAD)mCqqlB9xq9BF7wmAA0pVQwTNF7pW57pU(zrr)bk1V(utB0F6oT8ud6NXxs2)b63HXlTZOP(jaPu0o65EkQdSdAxcKOLNPmXKBxawgiTRqlBf0euXcnmysXlWMl8dlchC8M3HJzrXaLCDGoStbFZ8SWbx4ywumqjxhOd7uK7ugZYER82trbdziaPu0obpCWbvSqddMu8cS8LbVo7zpCWX7WXSOyeLczIZyNctgZYNQN1kV9uuWqgcqkfTtWdhCqfl0WGjfValFQsvSN998EUL6hjixhO9B53PLNAW2Z9uuhyhBqUoqnj5YZuMW44Yz0eBaxHMwuPjqX0IEAjBW4AoAkDNwEQbJf1LNAJ0bjAKqDmlAnqypf1bCnFtWpSawKnlRK2MW9Bz74Yz0up3s9Bz7GAr7VG6xn1VJP(tUTDby1)b6hwCqI6pH6yw0o6NxrhRZ3pdbDyQFOcVr)shKO(lO(vt9J6Wq9dU(vPyHgB46SeUFgUOFyXXz7hb1LN6(lq)hws4(JRFwu0pSNZo4Wu)C29ZBW1VLHVbH7NxDxF3cW(rp3trDGDSb56a1KKlptzcJdQfLTcAI3SdghxoJMglQ0eOyArpTeo4yx4AcedqXcn2W1zj8GaoJMKwdxtGyiDCwZI6Yt9GaoJMKS3A6uyoJ9vGyhscQsvWh8wzhMdqqhMfnuCCwZbzcuYO4BqyJVRVBbg0mXv22KSN7POoWo2GCDGAsYLNPmTVtBW0EC4eXg0HnacwJj4zJG1a7gx54aXKQMLny3D6(HoC)iOU8uRqAz)80pcQlp1BGRSu)CanTB)QP(Dm1VZCCr)X1FYT7)a9dloir9NqDmlAh9BbfqNVF1OeOFytbK9pdiplG2T)A73zoUO)46hZb6)4Irp3trDGDSb56a1KKlptzUOU8uRqAjBf0ebimR88nPQzTsacZk)qsqvQc(MGFwRSdghxoJMglQ0eOyArpT0A6uyoJ9vGyhscQsvWh8wLedhe0aQasJAYZcODhysXlWMl89Cpf1b2XgKRdutsU8mLjmoUCgnXgWvOPfvAsNcZzSVcelBW4AoAkDkmNX(kqSdjbvPk4BsvSz5WU(X0mXvysHaHfC)WIdsu)E0V(u3VLd76NjF)scY50XONBP(TCyx)yAM4kmPqGWcUFyXbjQ)dOZ3pdbDyQFOculkH3(lO(vt9J6Wq9BJRdxr((Xx4rDG(9OFvXt)HJzrXo65EkQdSJnixhOMKC5zktyCC5mAInGRqtlQ0KofMZyFfiw2GX1C0u6uyoJ9vGyhscQsvK7e8SvqtW44Yz00GBjJnUoCf5n4l8OoG11M0At4ywuSJfLdxzjGzJdRW3KQ65wQFyXbjQFjhUaS6hjVcZP3(pC)oZbd1FGIPf90Yrp3trDGDSb56a1KKlptzUOU8uBKoirSvqtW44Yz00yrLM0PWCg7RaXAL3W44Yz00yrLMaftl6PLWbhdhe0yZRWC61Cqgj5b6atkEbw(MGFKbCWT2KwBchZIIDSOC4klbmBCyf(MuL10DA5Pgm28kmNEnhKrsEGoWKIxGLp4NL99Cl1FoCyq)ysXlqby1pS4GeT9ZqqhM6pqP(HkwOr)eqU9xq9JCWs)QpGfKOFgQFm5Y89xG(JsHg9Cpf1b2XgKRdutsU8mL5I6YtTr6GeXwbnbJJlNrtJfvAsNcZzSVceRvOIfAyWKIxGn30DA5Pgm28kmNEnhKrsEGoWKIxGTN3ZTu)ib56aLK9d7VWJ6a9Cl1pVgu)ib56antyCqTO97yQFoB26NBP(rqD5PEdCLL6pU(ziabvr)q4tP)aL6323TGH6N5aCB)oq2pSPaY(NbKNfq72pbdb6VG6xn1VJP(9OFfhw73YHD9ZBi8P0FGs9BJP0PW4r)wgqWc7h9Cpf1b2XgKRdusYZuMlQlp1BGRSeBf0eVz4GGgBqUoqhC2Wbhdhe0aghul6GZM99Cl1pSPa1I2Vh9RAE63YHD9RUc0Jl6hwq6pZ(vfp9RUc0(HfK(vxbA)iOC4klb6N)ddC51pdheu)C29hx)omxj7FpfQFlh21VAFdQ)TcopQdSJEUNI6a7ydY1bkj5zkZKR1gpf1bm6Ad2aUcnbvGArzRGMy4GGglkhUYsatCyGlVbNT10PWCg7RaXoKeuLQi3Pm65wQFEv9E9Voe1FC9dvGAr73J(vfp9B5WU(vxbA)eS6PqNVFv1F4ywuSJ(5nIRq97B)hxSLK6FdY1b6G99Cpf1b2XgKRdusYZuMjxRnEkQdy01gSbCfAcQa1IYwbnT2KwBchZIIDSOC4klbmBCyLjvznDkmNX(kqS8nPQEUL6h2uGAr73J(vfp9B5WU(vxb6Xf9dliS1Vf5PF1vG2pSGWw)oq2pV0V6kq7hwq63Hcc3VLTdQfTN7POoWo2GCDGssEMYm5ATXtrDaJU2GnGRqtqfOwu2kOP0PWCg7RaXoKeuLQi3j4NrEhUMaXqsKnHnBG9Wzrkdc4mAsALHdcAaJdQfDWzZ(EUNI6a7ydY1bkj5zkZfTGHTcAkCnbIbOyHgB46SeEqaNrtsRyoabDyw0ikqEtCWALmmAxsdAM4kBBs2ZTu)WMd3VnMMrBpsOS1FwIS7h2uaz)ZaYZcOD7NZU)d0FGs9BJlfhNV)WXSOOFjh1FC9dU(rqD5PUFlBNth9Cpf1b2XgKRdusYZuMlQlp1BGRSeBf0KMGH05AXmSkjgoiObubKg1KNfq7oWKIxGnx4TgoMffJOuitCgzrZiMu8cS8Xl9Cl1)m0U)46x19hoMffB)zjYUFo7(Hnfq2)mG8SaA3(zY3FkFsxaw9JG6Yt9g4kln65EkQdSJnixhOKKNPmxuxEQ3axzj2s5tAYeoMff7e8SvqtsIHdcAavaPrn5zb0UdmP4fyZfERRnP1MWXSOyhlkhUYsaZghwj3jvBnCmlkgrPqM4mYIMrmP4fy5Jx65wQ)zqfOhx0pSqKnH7hjWE4SiL(DGSFv3pS3bz3(pO(Zr7sQ)c0FGs9JG6Yt92Ff9xB)QpCG2p3waw9JG6Yt9g4kl1)b6x19hoMff7ON7POoWo2GCDGssEMYCrD5PEdCLLyRGMyx4Acedjr2e2Sb2dNfPmiGZOjPv3cjCf0Gr7sYuatGsMf1LN6DGDq2jvBDTjT2eoMff7yr5Wvwcy24WktQUNBP(HnhUFBCD4kY3p(cpQdWw)Cl1pcQlp1BGRSu)hmeUFK4Wk9dp77xDfO9pdSm63z5fyJ(5S7pU(vv)HJzrXYw)zW((lO(HnZG(RTFmhauaw9Fqq9Z7d0VdY3VRCCGO)dQ)WXSOyzpB9F4(vn77pU(vCyTuklK6h5GL(jyniWwhOF1vG2pVgGGPcNP0vKV)d0VQ7pCmlk2(5TQ6xDfO9NtfiSF0Z9uuhyhBqUoqjjptzUOU8uVbUYsSvqtW44Yz00GBjJnUoCf5n4l8OoGvEljgoiObubKg1KNfq7oWKIxGnx4HdUW1eigQj3(ak(geEqaNrtsRRnP1MWXSOyhlkhUYsaZghwj3jvbhCUfs4kOrbiyQWzkDf5heWz0K0kdhe0yZRWC61Cqgj5b6GZ26AtATjCmlk2XIYHRSeWSXHvYDs184wiHRGgmAxsMcycuYSOU8uVdc4mAsY(EUNI6a7ydY1bkj5zkZfLdxzjGzJdRWwbnT2KwBchZIILVjvZdVz4GGg2ysHKv4rDGbNnCWXWbbncuYGViiWGZgo4WCac6WSOHN1DCTM940giSZsHaXGMjUY2MKwthqYvXqsKnHnsNflcVdSdYY3KfG99Cpf1b2XgKRdusYZuMlQlp1BGRSeBf0KKy4GGgqfqAutEwaT7atkEb2CNGho4s3PLNAWyZRWC61Cqgj5b6atkEb2CHFMTkjgoiObubKg1KNfq7oWKIxGn30DA5Pgm28kmNEnhKrsEGoWKIxGTNBP(rqD5PEdCLL6pU(XeeMw0(Hnfq2)mG8SaA3(DGS)46NalhM6xn1FYb9NCmoF)hmeUFVFioTUFyZmO)cex)bk1pGG1OFKdw6VG63(2Ty00ON7POoWo2GCDGssEMY0(oTbt7XHteBqh2aiynMGVN7POoWo2GCDGssEMYKL(ofgTlj2kOjgoiOHnHHoShK0advGDSHNYY3KfTMoGKRIHnHHoShK0advGDGDqw(MGx19Cpf1b2XgKRdusYZuMlQlp1BGRSupVNBP(HnfOwucV9Cpf1b2bubQfLNPmxDLiJdKgzLi2kOP1M0At4ywuSJfLdxzjGzJdRKlVyLDmCqqJf1LNAJ0bjAWzBLHdcAS6krghinYkrdmP4fyZfQyHggmP4fyTYWbbnwDLiJdKgzLObMu8cS5YB45jDkmNX(kqSSh2c)yM75EkQdSdOculkptzcJJlNrtSbCfAAZw2gmNDWHj2GX1C0KIVbHn(U(UfWGjfValFZchCSlCnbIbOyHgB46SeEqaNrtsRHRjqmKooRzrD5PEqaNrtsRmCqqJf1LNAJ0bjAWzdhCRnP1MWXSOyhlkhUYsaZghwHVjEHnlRK2MW9Bz74Yz0u)qhUFypNDWHPr)izl7(LC4cWQFldFdc3pV6U(UfO)d3VKdxaw9dloir9RUc0(HfhNTFhi7hC9RsXcn2W1zj8ONBP(TGMi7(5S7h2ZzhCyQ)cQ)k6V2(DMJl6pU(XCG(pUy0Z9uuhyhqfOwuEMYeZzhCyITcAIDW44Yz00yZw2gmNDWHjRHJzrXikfYeNrw0mIjfValF8IvmbHPf1z0up3trDGDavGAr5zkZLsykmbLqb1mXr9Cl1VLbNok5frby1F4ywuS9hOE0V6sR7xxWq9dD4(duQFjh2J6a9Fq9d75Sdom1pMGW0I2VKdxaw9B7ajPuPrp3trDGDavGAr5zktmNDWHj2s5tAYeoMff7e8SvqtSdghxoJMgB2Y2G5SdomzLDW44Yz00GBjJnUoCf5n4l8OoG11M0At4ywuSJfLdxzjGzJdRW3ugwdhZIIrukKjoJSi(M4Tf5H3zaBtNcZzSVcel7zVvmbHPf1z0up3s9d7jimTO9d75Sdom1p5yD((lO(ROF1Lw3pbR2fM6xYHlaR(rYRWC6D0pSC9hOE0pMGW0I2Fb1pYbl9ZIITFm5Y89xG(duQFabRr)wCh9Cpf1b2bubQfLNPmXC2bhMyRGMyhmoUCgnn2SLTbZzhCyYkMu8cS5MUtlp1GXMxH50R5GmsYd0bMu8cS8a)Swt3PLNAWyZRWC61Cqgj5b6atkEb2CNSO1WXSOyeLczIZilAgXKIxGLV0DA5Pgm28kmNEnhKrsEGoWKIxGLhl2Z9uuhyhqfOwuEMYKr7PSg7tTKWSvqtSdghxoJMgClzSX1HRiVbFHh1bSU2KwBchZIILVjv3Z9uuhyhqfOwuEMYKGP2eH9G659Cl1FoCLws4TN7POoWoy4kTCArlyyRGMyx4AcedqXcn2W1zj8GaoJMKwXCac6WSOruG8M4G1kzy0UKg0mXv22KSN7POoWoy4kTKNPmxuoCLLaMnoScBf00AtATjCmlkw(MYGhEhUMaXGL(ofgTlPbbCgnjT6wiHRGg2eg6WEqdSdYY3ugwTVTI6aggpLL99Cpf1b2bdxPL8mL5syShK0WCaYS2vwITcAkDNwEQbJLWypiPH5aKzTRS0iH6yw0AGWEkQd4A(MYyybSiCWThNMPaYHMCPHjVHGvxXwtdc4mAsALDmCqqdn5sdtEdbRUITMgC29Cpf1b2bdxPL8mLjl9DkmAxs9Cpf1b2bdxPL8mLjJNYUHZiqwBkjujdEbEricHaa]] )


end
