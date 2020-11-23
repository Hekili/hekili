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


    spec:RegisterPack( "Subtlety", 20201123, [[daLmYbqiukEeLiBIs6tuceJcvPofkLwfOs6vOkMfkv3srr2Lc)suPHbQ4yGQwMOWZqvvtdvvUgLqBduP(gLagNIcDouLuTokbQ5jk6EkY(qv5FOkjWbrvsAHIkEiLOAIkk5IOkj0gbvIpsjkXiPeL0jrvszLkQEjLaPMjQsIUjLOWojk9tkbsgkQsyPOkrpfIPsuCvff0wPeL6RkkWzrvsq7LWFPyWQ6WclgfpwKjtYLr2miFgLmAiDAjRMsu0RfLMnPUnr2nWVvz4uQJROOwoupxPPt11rLTdk(or14vuQZlQA9ucA(Gs7xQfWlKrGOcNeYMbCYaoWdFg8FaVfTOfGFWTaXZBtce7iLnyrceqirceeogxtEEbIDKxFHsiJazpoCIeiOUBVwW5MlRYr5ygPtk3TK40HxhiHdip3TKs5kqy4kTZRbemcev4Kq2mGtgWbE4HhUhWzg5h)YaEbsW5OhwGGuswUabTukciyeikAtcel1pchJRjpF)8YJfh1ZTu)YEWqsmeU)m4p79NbCYaoceDT(kKrGSofAhLuczeYcVqgbcbcgnPe5iqs4YjCfceE3pdhe0yDk0o6GZUFyHTFgoiObmbOw0bND)SvGejVoGazrd1jFDCLLeUq2meYiqiqWOjLihbscxoHRqGWWbbnwuoCLLag)WGqDdo7(T2F6KyoJ9vaFhkcQsL3FMt9NHajsEDabsk0AtK86agDTUarxRBaHejqGkqTOcxil)fYiqiqWOjLihbscxoHRqGS2KwB8aZI8DSOC4klbmRFyP(N6NF9BT)0jXCg7Ra(2pFt9ZpbsK86acKuO1Mi51bm6ADbIUw3acjsGavGArfUqw(jKrGqGGrtkrocKeUCcxHajDsmNX(kGVdfbvPY7pZP(HV)zQFE3VhAc4dfr2e2Soo8GfjniqWOjv)w7NHdcAataQfDWz3pBfirYRdiqsHwBIKxhWOR1fi6ADdiKibcubQfv4czTOqgbcbcgnPe5iqs4YjCfcep0eWhGIfQVEOZs4bbcgnP63A)yoabDyw0WlqEJFZUsggDOObnZCLTnPeirYRdiqw0cgHlKfUfYiqiqWOjLihbscxoHRqGOjyiD)z2VfZOFR9RigoiObubug5uKfq7oWKuuGT)m7h((T2VhywKp8sIm(zuf1)m1pMKIcS9Zx)WTajsEDabYIgQt(64kljCHSwaHmcecemAsjYrGejVoGazrd1jFDCLLeijC5eUcbIIy4GGgqfqzKtrwaT7atsrb2(ZSF473A)RnP1gpWSiFhlkhUYsaZ6hwQ)mN6N)9BTFpWSiF4Lez8ZOkQ)zQFmjffy7NV(HBbskFstgpWSiFfYcVWfYoJczeieiy0KsKJajHlNWviqyt)EOjGpueztyZ64WdwK0GabJMu9BT)WcjC50GrhkYuaJJsMfnuN8DGdq2(N6N)9BT)1M0AJhywKVJfLdxzjGz9dl1)u)8xGejVoGazrd1jFDCLLeUqwEDHmcecemAsjYrGKWLt4keiWe4ky00GBjJnUoC55n4ZdVoq)w7N39RigoiObubug5uKfq7oWKuuGT)m7h((Hf2(9qtaFiNc7difRt4bbcgnP63A)RnP1gpWSiFhlkhUYsaZ6hwQ)mN6NF9dlS9hwiHlNgfGGP8GP0LNFqGGrtQ(T2pdhe0yZlXC61Cqgffo6GZUFR9V2KwB8aZI8DSOC4klbmRFyP(ZCQF(3pp9hwiHlNgm6qrMcyCuYSOH6KVdcemAs1pBfirYRdiqw0qDYxhxzjHlKfE4iKrGqGGrtkrocKeUCcxHazTjT24bMf5B)8n1p)7NN(5D)mCqqdBmjrQYdVoWGZUFyHTFgoiOHJsg85obgC29dlS9J5ae0HzrJiBe4An7XPnq4GLeb8bnZCLTnP63A)PdO4kFOiYMWgvWIfH3boaz7NVP(Ta9ZwbsK86acKfLdxzjGz9dljCHSWdVqgbcbcgnPe5iqs4YjCfcefXWbbnGkGYiNISaA3bMKIcS9N5u)W3pSW2F6oT6KdgBEjMtVMdYOOWrhyskkW2FM9d)m2V1(vedhe0aQakJCkYcODhyskkW2FM9NUtRo5GXMxI50R5GmkkC0bMKIcScKi51beilAOo5RJRSKWfYcFgczeieiy0KsKJab6WganBxil8cKi51bei23PnyApoCIeUqw45VqgbcbcgnPe5iqs4YjCfcegoiOHnHHoC4KYadvGDSEKY2pFt9BX(T2F6akUYh2eg6WHtkdmub2boaz7NVP(HN)cKi51beiS03jXOdfjCHSWZpHmcKi51beilAOo5RJRSKaHabJMuICeUWfi0UeirRqgHSWlKrGqGGrtkrocKeUCcxHaHaeMv(HxsKXpJum7(5RF473A)SPFgoiOXMxI50R5GmkkC0bND)w7N39ZM(vNpshirahhoPmq6qImmCyWWRu2cWQFR9ZM(JKxhyKoqIaooCszG0HenkGbsxSq9(Hf2(H40AdMsObMfz8sI6pZ(zLudPy29ZwbsK86acK0bseWXHtkdKoKiHlKndHmcecemAsjYrGKWLt4keiSP)0DA1jhmw0qDYnm6qr7GZUFR9NUtRo5GXMxI50R5GmkkC0bND)WcB)qflu3GjPOaB)zo1p8WrGejVoGaHrFNYCqghLmeGKYlCHS8xiJajsEDabclUaRQayoityHe(CubcbcgnPe5iCHS8tiJaHabJMuICeijC5eUcbcV7FTjT24bMf57yr5Wvwcyw)Ws9Z3u)z0pSW2pokLHGHa(iuQDuG(5RF4go9Z2(T2pB6pDNwDYbJnVeZPxZbzuu4Odo7(T2pB6NHdcAS5Lyo9AoiJIchDWz3V1(jaHzLFOiOkvE)8n1p)HJajsEDabc0L4wszclKWLtggkKeUqwlkKrGqGGrtkrocKeUCcxHazTjT24bMf57yr5Wvwcyw)Ws9Z3u)z0pSW2pokLHGHa(iuQDuG(5RF4gocKi51bei2C4ckFbyzy0X6cxilClKrGqGGrtkrocKeUCcxHaHHdcAGPuwnTRb6WjAWz3pSW2pdhe0atPSAAxd0HtKjDCaNWJ1Ju2(ZSF4HJajsEDabIJsgoaZXbugOdNiHlK1ciKrGejVoGabx22AYuaZAhjsGqGGrtkrocxi7mkKrGqGGrtkrocKeUCcxHajDNwDYbJnVeZPxZbzuu4Odmjffy7pZ(Ty)WcB)qflu3GjPOaB)z2p8ZOajsEDabI8dRvWqfWGP9abircxilVUqgbcbcgnPe5iqs4YjCfcecqyw57pZ(5hC63A)mCqqJnVeZPxZbzuu4OdoBbsK86acejs6W5nhKrZLkLrHPqAfUqw4HJqgbcbcgnPe5iqs4YjCfceOIfQBWKuuGT)m7h(Hf7hwy7N39Z7(9aZI8bkfAhDyN8(5R)zeo9dlS97bMf5duk0o6Wo59N5u)zaN(zB)w7N39hjVGHmeGKkA7FQF47hwy7hQyH6gmjffy7NV(ZGxVF22pB7hwy7N397bMf5dVKiJFg7KBYao9Zx)8ho9BTFE3FK8cgYqasQOT)P(HVFyHTFOIfQBWKuuGTF(6NF8RF22pBfirYRdiqWuyxawgiDirRWfUarrqbN2fYiKfEHmcKi51beizRuwbcbcgnPe5iCHSziKrGejVoGazLUSKH5Kyeieiy0KsKJWfYYFHmcecemAsjYrGC2cKLCbsK86aceycCfmAsGatO5ibcdhe0y1vImbqzuvIgC29dlS9V2KwB8aZI8DSOC4klbmRFyP(5BQF4wGatGnGqIeilqzshqvEDaHlKLFczeieiy0KsKJajsEDabsk0AtK86agDTUarxRBaHejqsQv4czTOqgbcbcgnPe5iqs4YjCfcK1Pq7OKAeATajsEDabcMdyIKxhWOR1fi6ADdiKibY6uODusjCHSWTqgbcbcgnPe5iqs4YjCfcK1M0AJhywKVJfLdxzjGz9dl1FM9d39BTFOIfQBWKuuGTF(6hU73A)mCqqJvxjYeaLrvjAGjPOaB)z2pRKAifZUFR9NojMZyFfW3(5BQF(1)m1pV73ljQ)m7hE40pB7hU2FgcKi51beiRUsKjakJQsKWfYAbeYiqiqWOjLihbYzlqwYfirYRdiqGjWvWOjbcmHMJei246WLN3Gpp86a9BT)1M0AJhywKVJfLdxzjGz9dl1pFt9NHabMaBaHejq4wYyJRdxEEd(8WRdiCHSZOqgbcbcgnPe5iqs4YjCfceycCfmAAWTKXgxhU88g85HxhqGejVoGajfATjsEDaJUwxGOR1nGqIeiRtH2rnj1kCHS86czeieiy0KsKJa5Sfil5cKi51beiWe4ky0KabMqZrcKmSy)80VhAc4dykwhEqGGrtQ(HR9NbC6NN(9qtaFifRtyZbzw0qDY3bbcgnP6hU2FgWPFE63dnb8XIgQtUb6sC7GabJMu9dx7pdl2pp97HMa(i0rcxE(bbcgnP6hU2FgWPFE6pdl2pCTFE3)AtATXdmlY3XIYHRSeWS(HL6NVP(5x)SvGatGnGqIeiRtH2rnokMw0tReUqw4HJqgbcbcgnPe5iqs4YjCfcecqyw5hkcQsL3FMt9dtGRGrtJ1Pq7Oghftl6PvcKi51beiPqRnrYRdy016ceDTUbesKazDk0oQjPwHlKfE4fYiqiqWOjLihbscxoHRqGG5ae0HzrdffoQoVzrd1jFh0mZv22KQFR9RoFSK9w7WRu2cWQFR9RoFSK9w7atsrb2(ZCQ)m63A)PtI5m2xb8TF(M6pdbsK86acKuO1Mi51bm6ADbIUw3acjsGavGArfUqw4ZqiJaHabJMuICeijC5eUcbs6KyoJ9vaF7FQ)ausrcnWSiLjzlqIKxhqGKcT2ejVoGrxRlq016gqirceOculQWfYcp)fYiqiqWOjLihbscxoHRqGKojMZyFfW3HIGQu59N5u)W3pSW2puXc1nyskkW2FMt9dF)w7pDsmNX(kGV9Z3u)8xGejVoGajfATjsEDaJUwxGOR1nGqIeiqfOwuHlKfE(jKrGqGGrtkrocKeUCcxHazTjT24bMf57yr5Wvwcyw)Ws9Z3u)8RFR9NojMZyFfW3(5BQF(jqIKxhqGKcT2ejVoGrxRlq016gqirceOculQWfYcVffYiqiqWOjLihbscxoHRqGqacZk)qrqvQ8(ZCQFycCfmAASofAh14OyArpTsGejVoGajfATjsEDaJUwxGOR1nGqIeimCLwjCHSWd3czeieiy0KsKJajHlNWviqiaHzLFOiOkvE)8n1p8wSFE6NaeMv(bMyrabsK86acKaNcaz8dJjGlCHSWBbeYiqIKxhqGe4uaiJnNEjbcbcgnPe5iCHSWpJczeirYRdiq0fluFnwMCkwseWfieiy0KsKJWfYcpVUqgbsK86aceMGL5GmoUszxbcbcgnPe5iCHlqSXu6KycxiJqw4fYiqIKxhqGe2268g7R2diqiqWOjLihHlKndHmcKi51beiRtH2rfieiy0KsKJWfYYFHmcecemAsjYrGejVoGarkWzjLb6WgffoQaXgtPtIjCZsPdOwbc8wu4cz5NqgbcbcgnPe5iqIKxhqGS6krMaOmQkrcKeUCcxHabtqyArdgnjqSXu6Kyc3Su6aQvGaVWfYArHmcecemAsjYrGKWLt4keiyoabDyw0qkWznhKXrjJuSoHnXUXUfyqZmxzBtkbsK86acKfnuNCdJou0kCHSWTqgbcbcgnPe5iqaHejqclCrdCSgOd4MdYyFYjSajsEDabsyHlAGJ1aDa3Cqg7toHfUWfimCLwjKril8czeieiy0KsKJajHlNWviqyt)EOjGpafluF9qNLWdcemAs1V1(XCac6WSOHxG8g)MDLmm6qrdAM5kBBsjqIKxhqGSOfmcxiBgczeieiy0KsKJajHlNWviqwBsRnEGzr(2pFt9Nr)80pV73dnb8bl9Dsm6qrdcemAs1V1(dlKWLtdBcdD4WPboaz7NVP(ZOF2kqIKxhqGSOC4klbmRFyjHlKL)czeieiy0KsKJajHlNWviqs3PvNCWyjmoCszyoazw7klnsObMfTgiCK86aHUF(M6pJHfWI9dlS9VhNMPaQHMcLHjVHMDizRPbbcgnP63A)SPFgoiOHMcLHjVHMDizRPbNTajsEDabYsyC4KYWCaYS2vws4cz5NqgbsK86acew67Ky0HIeieiy0KsKJWfYArHmcKi51beimrk76bJaHabJMuICeUWfij1kKril8czeieiy0KsKJajHlNWviqyt)mCqqJfnuNCJkajAWz3V1(z4GGglkhUYsaJFyqOUbND)w7NHdcASOC4klbm(HbH6gyskkW2FMt9Z)HffirYRdiqw0qDYnQaKibc3sMdcYWkPeYcVWfYMHqgbcbcgnPe5iqs4YjCfcegoiOXIYHRSeW4hgeQBWz3V1(z4GGglkhUYsaJFyqOUbMKIcS9N5u)8FyrbsK86acKnVeZPxZbzuu4OceULmheKHvsjKfEHlKL)czeieiy0KsKJajHlNWviqGjWvWOPXcuM0buLxhOFR9ZM(xNcTJsQHuaCnjqIKxhqGaPdwKwhEDaHlKLFczeieiy0KsKJajHlNWviquedhe0ashSiTo86admjffy7pZ(ZqGejVoGabshSiTo86aMKMcWscxiRffYiqiqWOjLihbscxoHRqGW7(XCac6WSOHuGZAoiJJsgPyDcBIDJDlWGMzUY2Mu9BT)0jXCg7Ra(oueuLkV)mN6N)9dlS9J5ae0HzrdffoQoVzrd1jFh0mZv22KQFR9NojMZyFfW3(ZSF47NT9BTFgoiOXMxI50R5GmkkC0bND)w7NHdcASOH6KBubirdo7(T2VuSoHnXUXUfWGjPOaB)t9dN(T2pdhe0qrHJQZBw0qDY3H6KdeirYRdiqGja1IkCHSWTqgbcbcgnPe5iqs4YjCfce20)6uODusncTUFR9dtGRGrtJfOmPdOkVoq)WcB)0UeirdgmfoQ5Gmokzu5laRHuyzE4(T2Vxsu)8n1FgcKi51beiPqRnrYRdy016ceDTUbesKaH2LajAfUqwlGqgbcbcgnPe5iqGoSbqZ2fYcVajsEDabI9DAdM2JdNibscxoHRqG4HMa(yr5Wvwcy8ddc1niqWOjv)w7Nn97HMa(yrd1j3aDjUDqGGrtkHlKDgfYiqiqWOjLihbscxoHRqGqacZkF)8n1pCdN(T2pmbUcgnnwGYKoGQ86a9BT)0DA1jhm28smNEnhKrrHJo4S73A)P70QtoySOH6KBubirJeAGzrB)8n1p8cKi51beilkhUYsaJFyqOoHlKLxxiJaHabJMuICeirYRdiqwcJdNugMdqM1UYscKeUCcxHabMaxbJMglqzshqvEDG(T2pB6xD(yjmoCszyoazw7klzuNp8kLTaS63A)EGzr(WljY4Nrvu)8n1FgW3pSW2puXc1nyskkW2FMt9BX(T2)AtATXdmlY3XIYHRSeWS(HL6pZ(5VajLpPjJhywKVczHx4czHhoczeieiy0KsKJajHlNWviqGjWvWOPXcuM0buLxhOFR9NojMZyFfW3HIGQu59Z3u)WlqIKxhqGSK9wRWfYcp8czeieiy0KsKJajHlNWviqGjWvWOPXcuM0buLxhOFR9ZM(t3PvNCWyrd1j3WOdfTdo7(T2pV73dnb8bbGH0NDbyzw0qDY3bbcgnP6hwy7pDNwDYbJfnuNCJkajAKqdmlA7NVP(HVF22V1(5D)SPFp0eWhlkhUYsaJFyqOUbbcgnP6hwy73dnb8XIgQtUb6sC7GabJMu9dlS9NUtRo5GXIYHRSeW4hgeQBGjPOaB)81Fg9Z2(T2pV7Nn9t7sGeny03PmhKXrjdbiP8dPWY8W9dlS9NUtRo5GbJ(oL5GmokziajLFGjPOaB)81Fg9ZwbsK86acKnVeZPxZbzuu4Ocxil8ziKrGqGGrtkrocKi51beisbolPmqh2OOWrfijC5eUcbcokLHGHa(iuQDWz3V1(5D)EGzr(WljY4Nrvu)z2F6KyoJ9vaFhkcQsL3pSW2pB6FDk0okPgHw3V1(tNeZzSVc47qrqvQ8(5BQ)KTrkMTzTjGQF2kqs5tAY4bMf5Rqw4fUqw45VqgbcbcgnPe5iqs4YjCfceCukdbdb8rOu7Oa9Zx)8ho9pt9JJsziyiGpcLAhkoC41b63A)PtI5m2xb8DOiOkvE)8n1FY2ifZ2S2eqjqIKxhqGif4SKYaDyJIchv4czHNFczeieiy0KsKJajHlNWviqGjWvWOPXcuM0buLxhOFR9NojMZyFfW3HIGQu59Z3u)ziqIKxhqGSOH6KBy0HIwHlKfElkKrGqGGrtkrocKeUCcxHabMaxbJMglqzshqvEDG(T2F6KyoJ9vaFhkcQsL3pFt9Z)(T2pV7hMaxbJMgClzSX1HlpVbFE41b6hwy7FTjT24bMf57yr5Wvwcyw)Ws9N5u)8RF2kqIKxhqGqj0RaSmyYgxsbqjCHSWd3czeieiy0KsKJajHlNWviq8qtaFSOH6KBGUe3oiqWOjv)w7hMaxbJMglqzshqvEDG(T2pdhe0yZlXC61Cqgffo6GZwGejVoGazr5Wvwcy8ddc1jCHSWBbeYiqiqWOjLihbscxoHRqGWM(z4GGglAOo5gvas0GZUFR9dvSqDdMKIcS9N5u)Zy)80VhAc4JLJXjmehlAqGGrtkbsK86acKfnuNCJkajs4czHFgfYiqIKxhqGyFEDabcbcgnPe5iCHSWZRlKrGqGGrtkrocKeUCcxHaHHdcAS5Lyo9AoiJIchDWzlqIKxhqGWOVtzG4W5fUq2mGJqgbcbcgnPe5iqs4YjCfcegoiOXMxI50R5GmkkC0bNTajsEDabcdHxcNTaSeUq2mGxiJaHabJMuICeijC5eUcbcdhe0yZlXC61Cqgffo6GZwGejVoGabQWeJ(oLWfYMrgczeieiy0KsKJajHlNWviqy4GGgBEjMtVMdYOOWrhC2cKi51beibirRJdTjfATWfYMb)fYiqiqWOjLihbsK86acKu(K(C8bQKHrhRlqs4YjCfce20)6uODusncTUFR9dtGRGrtJfOmPdOkVoq)w7Nn9ZWbbn28smNEnhKrrHJo4S73A)eGWSYpueuLkVF(M6N)WrGqqquYnGqIeiP8j954dujdJowx4czZGFczeieiy0KsKJabesKajSWfnWXAGoGBoiJ9jNWcKi51beiHfUObowd0bCZbzSp5ewGKWLt4keiSPFgoiOXIgQtUrfGen4S73A)P70QtoyS5Lyo9AoiJIchDGjPOaB)z2p8Wr4czZWIczeieiy0KsKJabesKajwuycaTgCyHh2KoCOfirYRdiqIffMaqRbhw4HnPdhAbscxoHRqGOigoiOboSWdBsho0gfXWbbnuNCq)WcB)kIHdcAKoGIl5fmKPaznkIHdcAWz3V1(9aZI8bkfAhDyN8(ZSF(Nr)w73dmlYhOuOD0HDY7NVP(5pC6hwy7Nn9RigoiOr6akUKxWqMcK1OigoiObND)w7N39RigoiOboSWdBsho0gfXWbbnwpsz7NVP(ZWI9pt9dpC6hU2VIy4GGgm67uMdY4OKHaKu(bND)WcB)qflu3GjPOaB)z2p)Gt)STFR9ZWbbn28smNEnhKrrHJoWKuuGTF(6FgfUq2mGBHmcecemAsjYrGacjsGiLxfRXdDTsbqGejVoGarkVkwJh6ALcGWfYMHfqiJaHabJMuICeijC5eUcbcdhe0yZlXC61Cqgffo6GZUFyHTFOIfQBWKuuGT)m7pd4iqIKxhqGWTKPCsAfUWfiRtH2rnj1kKril8czeieiy0KsKJa5Sfil5cKi51beiWe4ky0KabMqZrcK0DA1jhmw0qDYnQaKOrcnWSO1aHJKxhi09Z3u)WpSawuGatGnGqIeilQY4OyArpTs4czZqiJaHabJMuICeijC5eUcbcV7Nn9dtGRGrtJfvzCumTONw1pSW2pB63dnb8bOyH6Rh6SeEqGGrtQ(T2VhAc4dvGZAw0qDYheiy0KQF22V1(tNeZzSVc47qrqvQ8(5RF473A)SPFmhGGomlAif4SMdY4OKrkwNWMy3y3cmOzMRSTjLajsEDabcmbOwuHlKL)czeieiy0KsKJab6WganBxil8cKi51bei23PnyApoCIei0SDCycPJd4ce(bhHlKLFczeieiy0KsKJajHlNWviqiaHzLVF(M6NFWPFR9tacZk)qrqvQ8(5BQF4Ht)w7Nn9dtGRGrtJfvzCumTONw1V1(tNeZzSVc47qrqvQ8(5RF473A)kIHdcAavaLrofzb0Udmjffy7pZ(HxGejVoGazrd1jxI0kHlK1Iczeieiy0KsKJa5Sfil5cKi51beiWe4ky0KabMqZrcK0jXCg7Ra(oueuLkVF(M6NFceycSbesKazrvM0jXCg7Ra(kCHSWTqgbcbcgnPe5iqoBbYsUajsEDabcmbUcgnjqGj0CKajDsmNX(kGVdfbvPY7pZP(HxGKWLt4keiWe4ky00GBjJnUoC55n4ZdVoq)w7FTjT24bMf57yr5Wvwcyw)Ws9Z3u)8tGatGnGqIeilQYKojMZyFfWxHlK1ciKrGqGGrtkrocKeUCcxHabMaxbJMglQYKojMZyFfW3(T2pV7hMaxbJMglQY4OyArpTQFyHTFgoiOXMxI50R5GmkkC0bMKIcS9Z3u)WpYOFyHT)1M0AJhywKVJfLdxzjGz9dl1pFt9ZV(T2F6oT6KdgBEjMtVMdYOOWrhyskkW2pF9dpC6NTcKi51beilAOo5gvasKWfYoJczeieiy0KsKJajHlNWviqGjWvWOPXIQmPtI5m2xb8TFR9dvSqDdMKIcS9Nz)P70QtoyS5Lyo9AoiJIchDGjPOaRajsEDabYIgQtUrfGejCHlqGkqTOczeYcVqgbcbcgnPe5iqs4YjCfcK1M0AJhywKVJfLdxzjGz9dl1FM9d39BTF20pdhe0yrd1j3OcqIgC29BTFgoiOXQRezcGYOQenWKuuGT)m7hQyH6gmjffy73A)mCqqJvxjYeaLrvjAGjPOaB)z2pV7h((5P)0jXCg7Ra(2pB7hU2p8JzuGejVoGaz1vImbqzuvIeUq2meYiqiqWOjLihbYzlqwYfirYRdiqGjWvWOjbcmHMJeisX6e2e7g7wadMKIcS9Zx)WPFyHTF20VhAc4dqXc1xp0zj8GabJMu9BTFp0eWhQaN1SOH6KpiqWOjv)w7NHdcASOH6KBubirdo7(Hf2(xBsRnEGzr(owuoCLLaM1pSu)8n1pClqGjWgqircKnBzBWC2ohMeUqw(lKrGqGGrtkrocKeUCcxHaHn9dtGRGrtJnBzBWC2ohM63A)EGzr(WljY4Nrvu)Zu)yskkW2pF9d39BTFmbHPfny0KajsEDabcMZ25WKWfYYpHmcKi51beilLWKBCkHcQzMJeieiy0KsKJWfYArHmcecemAsjYrGejVoGabZz7CysGKWLt4keiSPFycCfmAASzlBdMZ25Wu)w7Nn9dtGRGrtdULm246WLN3Gpp86a9BT)1M0AJhywKVJfLdxzjGz9dl1pFt9Nr)w73dmlYhEjrg)mQI6NVP(5D)wSFE6N39Nr)W1(tNeZzSVc4B)STF22V1(XeeMw0GrtcKu(KMmEGzr(kKfEHlKfUfYiqiqWOjLihbscxoHRqGWM(HjWvWOPXMTSnyoBNdt9BTFmjffy7pZ(t3PvNCWyZlXC61Cqgffo6atsrb2(5PF4Ht)w7pDNwDYbJnVeZPxZbzuu4Odmjffy7pZP(Ty)w73dmlYhEjrg)mQI6FM6htsrb2(5R)0DA1jhm28smNEnhKrrHJoWKuuGTFE63IcKi51beiyoBNdtcxiRfqiJaHabJMuICeijC5eUcbcB6hMaxbJMgClzSX1HlpVbFE41b63A)RnP1gpWSiF7NVP(5VajsEDabcJoszn2NCfHfUq2zuiJajsEDabcbtTjchojqiqWOjLihHlCHlqGHWBDaHSzaNmGd8Wdp8ce5bguawRazgWRYlLLxtwllwW93VmOu)LK9H9(HoC)wqy4kTYcs)yAM5kmP6FpjQ)GZpPWjv)j0aWI2rpNxzbO(ZWcUFEjjDWqQ(TVT86agMiLT)ekLY2pVbN3Fatu6Grt9xG(jjoD41byB)8g(zZ2rpVNZRjzFyNu9pJ9hjVoq)6A9D0ZfiRnLeYMbCdVaXgFqLMeiwQFeogxtE((5LhloQNBP(L9GHKyiC)zWF27pd4KbC659Cl1pVatZKLFsmH3ZJKxhyh2ykDsmHZZuUHTToVX(Q9a98i51b2HnMsNet48mL76uOD0EEK86a7WgtPtIjCEMYvkWzjLb6Wgffok72ykDsmHBwkDa1obVf75rYRdSdBmLojMW5zk3vxjYeaLrvjIDBmLojMWnlLoGANGN9cActqyArdgn1ZJKxhyh2ykDsmHZZuUlAOo5ggDOOL9cAcZbiOdZIgsboR5GmokzKI1jSj2n2TadAM5kBBs1ZJKxhyh2ykDsmHZZuUClzkNKyhes0uyHlAGJ1aDa3Cqg7toH759Cl1VLruG(5LNhEDGEEK86a7u2kLTNBP(NHlP63V(vKtyPcq9lhLCuc3F6oT6Kd2(LhL3p0H7hbmR(zILu9FG(9aZI8D0ZJKxhy5zkxycCfmAIDqirtlqzshqvEDa2Hj0C0edhe0y1vImbqzuvIgC2Wc7AtATXdmlY3XIYHRSeWS(HL4BcU75wQFlhLsz73YN12F49dv4175rYRdS8mLBk0AtK86agDTo7GqIMsQTNBP(5LCG(H40689VYlpHsB)(1VJs9J4uODus1pV88WRd0pVzY3V6kaR(3J9Y7h6WjA73(oDby1Fb1p4C0cWQ)A7pGjkDWOj2o65rYRdS8mLlMdyIKxhWOR1zhes006uODusXEbnTofAhLuJqR75wQFEvBBD((xDLitaugvLO(dV)m4PFlNx0VIdxaw97Ou)qfE9(Hho9Vu6aQL9aYjC)oA49ZpE63Y5f9xq9xE)0STlmT9lVC0c0VJs9dOz79BzXYNv)hU)A7hCE)C298i51bwEMYD1vImbqzuvIyVGMwBsRnEGzr(owuoCLLaM1pSuMWTvOIfQBWKuuGLp42kdhe0y1vImbqzuvIgyskkWMjRKAifZ2A6KyoJ9vaF5BIFZeV9sIYeE4Ww4Ag9Cl1VfuaD((tObGf1p(8WRd0Fb1VCQF0agQFBCD4YZBWNhEDG(xY7paQ(L40EzRP(9aZI8TFo7rppsEDGLNPCHjWvWOj2bHenXTKXgxhU88g85HxhGDycnhnzJRdxEEd(8WRdyDTjT24bMf57yr5Wvwcyw)Ws8nLrp3s9ZlW1HlpF)8YZdVoaVc6Nxj5wq2(zvWq9h9NWHD)bZX59tacZkF)qhUFhL6FDk0oA)w(S2(5ndxPveU)1lTUFmT2uY7VC2o6NxHC2SxE)Pa0pd1VJgE)BjzRPrppsEDGLNPCtHwBIKxhWOR1zhes006uODutsTSxqtWe4ky00GBjJnUoC55n4ZdVoqp3s9pdxs1VF9RiOcq9lhLa97x)Cl1)6uOD0(T8zT9F4(z4kTIWBppsEDGLNPCHjWvWOj2bHenTofAh14OyArpTIDycnhnLHf5Xdnb8bmfRdpiqWOjfCnd4WJhAc4dPyDcBoiZIgQt(oiqWOjfCnd4WJhAc4JfnuNCd0L42bbcgnPGRzyrE8qtaFe6iHlp)GabJMuW1mGdpzyr4kVxBsRnEGzr(owuoCLLaM1pSeFt8JT9Cl1VLFGTueUFUTaS6p6hXPq7O9B5ZQF5OeOFmfj0cWQFhL6NaeMv((DumTONw1ZJKxhy5zk3uO1Mi51bm6AD2bHenTofAh1Kul7f0ebimR8dfbvPYZCcMaxbJMgRtH2rnokMw0tR65rYRdS8mLBk0AtK86agDTo7GqIMGkqTOSxqtyoabDyw0qrHJQZBw0qDY3bnZCLTnPSQoFSK9w7WRu2cWYQ68Xs2BTdmjffyZCkdRPtI5m2xb8LVPm65rYRdS8mLBk0AtK86agDTo7GqIMGkqTOSxqtPtI5m2xb8DkaLuKqdmlszs29Cl1pCPa1I2F49ZpE6xE5OhN3)SqyVFlYt)YlhT)zH0pVpoFlf1)6uODu22ZJKxhy5zk3uO1Mi51bm6AD2bHenbvGArzVGMsNeZzSVc47qrqvQ8mNGhwyHkwOUbtsrb2mNG3A6KyoJ9vaF5BI)9Cl1)mOC0(Nfs)HEV(HkqTO9hE)8JN(dwrbwVF(1VhywKV9Z7JZ3sr9VofAhLT98i51bwEMYnfATjsEDaJUwNDqirtqfOwu2lOP1M0AJhywKVJfLdxzjGz9dlX3e)SMojMZyFfWx(M4xp3s9pdxQ)OFgUsRiC)Yrjq)yksOfGv)ok1pbimR897OyArpTQNhjVoWYZuUPqRnrYRdy016SdcjAIHR0k2lOjcqyw5hkcQsLN5embUcgnnwNcTJACumTONw1ZTu)8kp5069BJRdxE((lq)Hw3)b1VJs9ZRYl4v2pdLcUL6V8(tb3sB)r)wwS8z1ZJKxhy5zk3aNcaz8dJjGZEbnracZk)qrqvQC(MG3I8qacZk)atSiqppsEDGLNPCdCkaKXMtVuppsEDGLNPC1fluFnwMCkwseW75rYRdS8mLltWYCqghxPSBpVNBP(T870Qtoy75wQ)z4s9pRaKO(piOzIvs1pdbDyQFhL6hQWR3)IYHRSeWS(HL6hcFs9lZHbH66pDs02Fbg98i51b2rsT8mL7IgQtUrfGeXo3sMdcYWkPMGN9cAInmCqqJfnuNCJkajAWzBLHdcASOC4klbm(HbH6gC2wz4GGglkhUYsaJFyqOUbMKIcSzoX)Hf75wQFEpdbAA3(dnMcv((5S7NHsb3s9lN63VlB)iOH6K3pC5sClB7NBP(rYlXC6T)dcAMyLu9ZqqhM63rP(Hk869VOC4klbmRFyP(HWNu)YCyqOU(tNeT9xGrppsEDGDKulpt5U5Lyo9AoiJIchLDULmheKHvsnbp7f0edhe0yr5Wvwcy8ddc1n4STYWbbnwuoCLLag)WGqDdmjffyZCI)dl2ZJKxhyhj1YZuUq6GfP1HxhG9cAcMaxbJMglqzshqvEDaRSzDk0okPgsbW1uppsEDGDKulpt5cPdwKwhEDatstbyj2lOjfXWbbnG0blsRdVoWatsrb2mZONhjVoWosQLNPCHja1IYEbnXBmhGGomlAif4SMdY4OKrkwNWMy3y3cmOzMRSTjL10jXCg7Ra(oueuLkpZj(dlSyoabDyw0qrHJQZBw0qDY3bnZCLTnPSMojMZyFfW3mHNTwz4GGgBEjMtVMdYOOWrhC2wz4GGglAOo5gvas0GZ2QuSoHnXUXUfWGjPOa7eCSYWbbnuu4O68MfnuN8DOo5GEEK86a7iPwEMYnfATjsEDaJUwNDqirt0Ueirl7f0eBwNcTJsQrO1wHjWvWOPXcuM0buLxhawyPDjqIgmykCuZbzCuYOYxawdPWY8Ww9sI4BkJEUL6NxCNUFOd3VmhgeQRFBmnti3S6xE5O9JGoR(XuOY3VCuc0p48(XCaqby1pcCz0ZJKxhyhj1YZuU23PnyApoCIyh6WganBFcE2lOjp0eWhlkhUYsaJFyqOUbbcgnPSYgp0eWhlAOo5gOlXTdcemAs1ZTu)ZWL6xMddc11VnM6h5Mv)Yrjq)YP(rdyO(DuQFcqyw57xok5OeUFi8j1V9D6cWQF5LJECE)iWL(pC)wMCR3plcq4qRZp65rYRdSJKA5zk3fLdxzjGXpmiuh7f0ebimR88nb3WXkmbUcgnnwGYKoGQ86awt3PvNCWyZlXC61Cqgffo6GZ2A6oT6KdglAOo5gvas0iHgyw0Y3e898i51b2rsT8mL7syC4KYWCaYS2vwI9u(KMmEGzr(obp7f0embUcgnnwGYKoGQ86awzJ68XsyC4KYWCaYS2vwYOoF4vkBbyz1dmlYhEjrg)mQI4Bkd4HfwOIfQBWKuuGnZjlADTjT24bMf57yr5Wvwcyw)WszY)EEK86a7iPwEMYDj7Tw2lOjycCfmAASaLjDav51bSMojMZyFfW3HIGQu58nbFp3s9pdxQFK8smNE7)a9NUtRo5G(5Da5eUFOcVE)iGzX2(5aAA3(Lt9hyQFwxby1VF9BF29lZHbH66paQ(vx)GZ7hnGH6hbnuN8(HlxIBh98i51b2rsT8mL7MxI50R5GmkkCu2lOjycCfmAASaLjDav51bSYM0DA1jhmw0qDYnm6qr7GZ2kV9qtaFqayi9zxawMfnuN8DqGGrtkyHnDNwDYbJfnuNCJkajAKqdmlA5BcE2AL3SXdnb8XIYHRSeW4hgeQBqGGrtkyH1dnb8XIgQtUb6sC7GabJMuWcB6oT6KdglkhUYsaJFyqOUbMKIcS8LbBTYB2q7sGeny03PmhKXrjdbiP8dPWY8WWcB6oT6Kdgm67uMdY4OKHaKu(bMKIcS8LbB75wQFEnO(dLA7pWu)C2S3)ckBQFhL6)au)YlhTF9jNwVFzKzwJ(NHl1VCuc0VkFby1puSoH73rdq)woVOFfbvPY7)W9doV)1Pq7OKQF5LJECE)biF)woVy0ZJKxhyhj1YZuUsbolPmqh2OOWrzpLpPjJhywKVtWZEbnHJsziyiGpcLAhC2w5ThywKp8sIm(zufLz6KyoJ9vaFhkcQsLdlSSzDk0okPgHwBnDsmNX(kGVdfbvPY5BkzBKIzBwBcOyBp3s9ZRb1p46puQTF5Lw3VQO(LxoAb63rP(b0S9(5pCw27NBP(TmGMv)hOFMB3(Lxo6X59hG89B58IrppsEDGDKulpt5kf4SKYaDyJIchL9cAchLYqWqaFek1okaF8hoZeokLHGHa(iuQDO4WHxhWA6KyoJ9vaFhkcQsLZ3uY2ifZ2S2eq1ZJKxhyhj1YZuUlAOo5ggDOOL9cAcMaxbJMglqzshqvEDaRPtI5m2xb8DOiOkvoFtz0ZJKxhyhj1YZuUuc9kaldMSXLuauSxqtWe4ky00ybkt6aQYRdynDsmNX(kGVdfbvPY5BI)w5nmbUcgnn4wYyJRdxEEd(8WRdalSRnP1gpWSiFhlkhUYsaZ6hwkZj(X2EUL6FguoA)iWf27VG6hCE)HgtHkF)QdqS3p3s9lZHbH66xE5O9JCZQFo7rppsEDGDKulpt5UOC4klbm(HbH6yVGM8qtaFSOH6KBGUe3oiqWOjLvycCfmAASaLjDav51bSYWbbn28smNEnhKrrHJo4S75rYRdSJKA5zk3fnuNCJkajI9cAInmCqqJfnuNCJkajAWzBfQyH6gmjffyZCAg5Xdnb8XYX4egIJfniqWOjvpVNBP(L9aZ0AtP(xNdcQF5LJ2V(Kt4(TX11ZJKxhyhj1YZuU2NxhONhjVoWosQLNPCz03PmqC48SxqtmCqqJnVeZPxZbzuu4Odo7EEK86a7iPwEMYLHWlHZwawSxqtmCqqJnVeZPxZbzuu4Odo7EEK86a7iPwEMYfQWeJ(of7f0edhe0yZlXC61Cqgffo6GZUNhjVoWosQLNPCdqIwhhAtk0A2lOjgoiOXMxI50R5GmkkC0bNDpVNhjVoWosQLNPC5wYuojXobbrj3acjAkLpPphFGkzy0X6SxqtSzDk0okPgHwBfMaxbJMglqzshqvEDaRSHHdcAS5Lyo9AoiJIchDWzBLaeMv(HIGQu58nXF40ZJKxhyhj1YZuUClzkNKyhes0uyHlAGJ1aDa3Cqg7toHzVGMyddhe0yrd1j3OcqIgC2wt3PvNCWyZlXC61Cqgffo6atsrb2mHho9Cl1)5OewETu)YlhTFKBw9hE)zyrE6F9iLD7)W9dVf5PF5LJ2FO3R)C03P6NZE0ZJKxhyhj1YZuUClzkNKyhes0uSOWeaAn4WcpSjD4qZEbnPigoiOboSWdBsho0gfXWbbnuNCaSWQigoiOr6akUKxWqMcK1OigoiObNTvpWSiFGsH2rh2jpt(NHvpWSiFGsH2rh2jNVj(dhyHLnkIHdcAKoGIl5fmKPaznkIHdcAWzBL3kIHdcAGdl8WM0HdTrrmCqqJ1Juw(MYWIZe8WbUQigoiObJ(oL5GmokziajLFWzdlSqflu3GjPOaBM8doS1kdhe0yZlXC61Cqgffo6atsrbw(MXEUL63YMW57hFCSq157hZPP(pO(DuojMcQiv)sHJU9Zq6tUfC)ZWL6h6W9ZRbYAFQ(t4Y75rYRdSJKA5zkxULmLtsSdcjAskVkwJh6ALcqp3s9plck40E)qHwZePS9dD4(52Grt9xojTwW9pdxQF5LJ2psEjMtV9Fq9plkC0rppsEDGDKulpt5YTKPCsAzVGMy4GGgBEjMtVMdYOOWrhC2WcluXc1nyskkWMzgWPN3ZTu)8QwiHlN6NxXDjqI2EEK86a7G2LajA5zk30bseWXHtkdKoKi2lOjcqyw5hEjrg)msXS5dERSHHdcAS5Lyo9AoiJIchDWzBL3SrD(iDGebCC4KYaPdjYWWHbdVszlalRSjsEDGr6ajc44WjLbshs0OagiDXc1HfwioT2GPeAGzrgVKOmzLudPy2STNhjVoWoODjqIwEMYLrFNYCqghLmeGKYZEbnXM0DA1jhmw0qDYnm6qr7GZ2A6oT6KdgBEjMtVMdYOOWrhC2WcluXc1nyskkWM5e8WPNhjVoWoODjqIwEMYLfxGvvamhKjSqcFoAppsEDGDq7sGeT8mLl0L4wszclKWLtggkKyVGM49AtATXdmlY3XIYHRSeWS(HL4BkdyHfhLYqWqaFek1okaFWnCyRv2KUtRo5GXMxI50R5GmkkC0bNTv2WWbbn28smNEnhKrrHJo4STsacZk)qrqvQC(M4pC65rYRdSdAxcKOLNPCT5Wfu(cWYWOJ1zVGMwBsRnEGzr(owuoCLLaM1pSeFtzalS4Ougcgc4JqP2rb4dUHtppsEDGDq7sGeT8mLRJsgoaZXbugOdNi2lOjgoiObMsz10UgOdNObNnSWYWbbnWukRM21aD4ezshhWj8y9iLnt4HtppsEDGDq7sGeT8mLlUST1KPaM1osuppsEDGDq7sGeT8mLR8dRvWqfWGP9abirSxqtP70QtoyS5Lyo9AoiJIchDGjPOaBMwewyHkwOUbtsrb2mHFg75rYRdSdAxcKOLNPCLiPdN3CqgnxQugfMcPL9cAIaeMv(m5hCSYWbbn28smNEnhKrrHJo4S75wQFlRNw1pVKc7cWQF4IoKOTFOd3pnBkX5u)4aWI6)W9NT06(z4GGw27VG63(2Ty00OFEvT8i)2VJZ3VF9ZI8(DuQF9jNwV)0DA1jh0ptSKQ)d0Fatu6Grt9tasQOD0ZJKxhyh0Ueirlpt5IPWUaSmq6qIw2lOjOIfQBWKuuGnt4hwewy5nV9aZI8bkfAhDyNC(Mr4alSEGzr(aLcTJoStEMtzah2AL3rYlyidbiPI2j4HfwOIfQBWKuuGLVm41zlBHfwE7bMf5dVKiJFg7KBYao8XF4yL3rYlyidbiPI2j4HfwOIfQBWKuuGLp(Xp2Y2EEp3s9J4uOD0(T870Qtoy75rYRdSJ1Pq7OMKA5zkxycCfmAIDqirtlQY4OyArpTIDycnhnLUtRo5GXIgQtUrfGensObMfTgiCK86aHMVj4hwalYULvsBt4(TSdCfmAQNBP(TSdqTO9xq9lN6pWu)PW2UaS6)a9pRaKO(tObMfTJ(5vmW689ZqqhM6hQWR3VkajQ)cQF5u)Obmu)GRFzlwO(6HolH7NHZ7FwboB)iOH6K3Fb6)Wkc3VF9ZI8(5LC2ohM6NZUFEdU(TmI1jC)8Q7g7wa2o65rYRdSJ1Pq7OMKA5zkxycqTOSxqt8MnWe4ky00yrvghftl6PvWclB8qtaFakwO(6HolHheiy0KYQhAc4dvGZAw0qDYheiy0KITwtNeZzSVc47qrqvQC(G3kBWCac6WSOHuGZAoiJJsgPyDcBIDJDlWGMzUY2Mu98i51b2X6uODutsT8mLR9DAdM2JdNi2HoSbqZ2NGNDA2oomH0Xb8j(bh25f3P7h6W9JGgQtUePv9Zt)iOH6KVoUYs9Zb00U9lN6pWu)bZX597x)PWU)d0)ScqI6pHgyw0o63ckGoF)Yrjq)WLcO6FgqrwaTB)12FWCCE)(1pMd0)X5JEEK86a7yDk0oQjPwEMYDrd1jxI0k2lOjcqyw55BIFWXkbimR8dfbvPY5BcE4yLnWe4ky00yrvghftl6PvwtNeZzSVc47qrqvQC(G3QIy4GGgqfqzKtrwaT7atsrb2mHVNhjVoWowNcTJAsQLNPCHjWvWOj2bHenTOkt6KyoJ9vaFzhMqZrtPtI5m2xb8DOiOkvoFt8JDlNx0pMMzUctseWTG7Fwbir9hE)6tE)woVOFM89RiOGt7JEUL63Y5f9JPzMRWKebCl4(Nvasu)hqNVFgc6Wu)qfOwucV9xq9lN6hnGH63gxhU889Jpp86a9hE)8JN(9aZI8D0ZJKxhyhRtH2rnj1YZuUWe4ky0e7GqIMwuLjDsmNX(kGVSdtO5OP0jXCg7Ra(oueuLkpZj4zVGMGjWvWOPb3sgBCD4YZBWNhEDaRRnP1gpWSiFhlkhUYsaZ6hwIVj(1ZTu)ZkajQFfhUaS6hjVeZP3(pC)bZbd1VJIPf90QrppsEDGDSofAh1Kulpt5UOH6KBubirSxqtWe4ky00yrvM0jXCg7Ra(AL3We4ky00yrvghftl6PvWcldhe0yZlXC61Cqgffo6atsrbw(MGFKbSWU2KwB8aZI8DSOC4klbmRFyj(M4N10DA1jhm28smNEnhKrrHJoWKuuGLp4HdB75wQ)C4WG(XKuuGcWQ)zfGeT9ZqqhM63rP(HkwOE)eqT9xq9JCZQF5hWcI3pd1pMcv((lq)EjrJEEK86a7yDk0oQjPwEMYDrd1j3OcqIyVGMGjWvWOPXIQmPtI5m2xb81kuXc1nyskkWMz6oT6KdgBEjMtVMdYOOWrhyskkW2Z75wQFeNcTJsQ(5LNhEDGEUL6NxdQFeNcTJMlmbOw0(dm1pNn79ZTu)iOH6KVoUYs97x)meGGkVFi8j1VJs9Bh7wWq9ZCaUT)aO6hUuav)ZakYcOD7NGHa9xq9lN6pWu)H3Vum7(TCEr)8gcFs97Ou)2ykDsmH3VLb0Sy7ONhjVoWowNcTJskEMYDrd1jFDCLLyVGM4ndhe0yDk0o6GZgwyz4GGgWeGArhC2STNBP(HlfOw0(dVF(Zt)woVOF5LJECE)ZcP)C7NF80V8Yr7Fwi9lVC0(rq5Wvwc0VmhgeQRFgoiO(5S73V(dyUs1)Esu)woVOF5X6u)B5CHxhyh98i51b2X6uODusXZuUPqRnrYRdy016SdcjAcQa1IYEbnXWbbnwuoCLLag)WGqDdoBRPtI5m2xb8DOiOkvEMtz0ZTu)8Q696FdiQF)6hQa1I2F49ZpE63Y5f9lVC0(PzhjxNVF(1VhywKVJ(5nsir9hB)hNVLI6FDk0o6GT98i51b2X6uODusXZuUPqRnrYRdy016SdcjAcQa1IYEbnT2KwB8aZI8DSOC4klbmRFyPj(znDsmNX(kGV8nXVEUL6hUuGAr7p8(5hp9B58I(Lxo6X59ple273I80V8Yr7FwiS3Fau9d39lVC0(Nfs)bKt4(TSdqTO98i51b2X6uODusXZuUPqRnrYRdy016SdcjAcQa1IYEbnLojMZyFfW3HIGQu5zob)mXBp0eWhkISjSzDC4blsAqGGrtkRmCqqdycqTOdoB22ZJKxhyhRtH2rjfpt5UOfmSxqtEOjGpafluF9qNLWdcemAszfZbiOdZIgEbYB8B2vYWOdfnOzMRSTjL11M0AJhywKVJfLdxzjGz9dlLPf75wQF4YH73gtZKD4ju27plr29dxkGQ)zafzb0U9Zz3)b63rP(TXLuGZ3VhywK3VIJ63V(bx)iOH6K3VLDWP9EEK86a7yDk0okP4zk3fnuN81XvwI9cAstWq6mTygwvedhe0aQakJCkYcODhyskkWMj8w9aZI8HxsKXpJQOzctsrbw(G7EUL6FgA3VF9Z)(9aZI8T)Sez3pND)WLcO6FgqrwaTB)m57pLpPlaR(rqd1jFDCLLg98i51b2X6uODusXZuUlAOo5RJRSe7P8jnz8aZI8DcE2lOjfXWbbnGkGYiNISaA3bMKIcSzcV11M0AJhywKVJfLdxzjGz9dlL5e)T6bMf5dVKiJFgvrZeMKIcS8b39Cl1)mOC0JZ7Fwezt4(rCC4blsQ)aO6N)9Zldq2T)dQ)C0HI6Va97Ou)iOH6KV9xE)12V8d7O9ZTfGv)iOH6KVoUYs9FG(5F)EGzr(o65rYRdSJ1Pq7OKINPCx0qDYxhxzj2lOj24HMa(qrKnHnRJdpyrsdcemAsznSqcxony0HImfW4OKzrd1jFh4aKDI)wxBsRnEGzr(owuoCLLaM1pS0e)75wQF4YH73gxhU889Jpp86aS3p3s9JGgQt(64kl1)bdH7hXpSu)WZ2(LxoA)ZalJ(dwrbwVFo7(9RF(1VhywKVS3FgST)cQF4YmO)A7hZbafGv)heu)8(a9hG89hshhW7)G63dmlYx2YE)hUF(Z2(9RFPy2LuzHu)i3S6NMTtGToq)YlhTFEnabt5btPlpF)hOF(3VhywKV9ZB(1V8Yr7pNYry7ONhjVoWowNcTJskEMYDrd1jFDCLLyVGMGjWvWOPb3sgBCD4YZBWNhEDaR8wrmCqqdOcOmYPilG2DGjPOaBMWdlSEOjGpKtH9bKI1j8GabJMuwxBsRnEGzr(owuoCLLaM1pSuMt8dwydlKWLtJcqWuEWu6YZpiqWOjLvgoiOXMxI50R5GmkkC0bNT11M0AJhywKVJfLdxzjGz9dlL5e)5jSqcxony0HImfW4OKzrd1jFheiy0KIT98i51b2X6uODusXZuUlkhUYsaZ6hwI9cAATjT24bMf5lFt8NhEZWbbnSXKePkp86adoByHLHdcA4OKbFUtGbNnSWI5ae0HzrJiBe4An7XPnq4GLeb8bnZCLTnPSMoGIR8HIiBcBublweEh4aKLVjlaB75rYRdSJ1Pq7OKINPCx0qDYxhxzj2lOjfXWbbnGkGYiNISaA3bMKIcSzobpSWMUtRo5GXMxI50R5GmkkC0bMKIcSzc)mAvrmCqqdOcOmYPilG2DGjPOaBMP70QtoyS5Lyo9AoiJIchDGjPOaBp3s9JGgQt(64kl1VF9JjimTO9dxkGQ)zafzb0U9hav)(1pbwom1VCQ)ua6pfyC((pyiC)r)qCAD)WLzq)fWV(DuQFanBVFKBw9xq9BF7wmAA0ZJKxhyhRtH2rjfpt5AFN2GP94WjIDOdBa0S9j475rYRdSJ1Pq7OKINPCzPVtIrhkI9cAIHdcAytyOdhoPmWqfyhRhPS8nzrRPdO4kFytyOdhoPmWqfyh4aKLVj45FppsEDGDSofAhLu8mL7IgQt(64kl1Z75wQF4sbQfLWBppsEDGDavGAr5zk3vxjYeaLrvjI9cAATjT24bMf57yr5Wvwcyw)Wszc3wzddhe0yrd1j3OcqIgC2wz4GGgRUsKjakJQs0atsrb2mHkwOUbtsrbwRmCqqJvxjYeaLrvjAGjPOaBM8gEEsNeZzSVc4lBHRWpMXEEK86a7aQa1IYZuUWe4ky0e7GqIM2SLTbZz7CyIDycnhnjfRtytSBSBbmyskkWYhCGfw24HMa(auSq91dDwcpiqWOjLvp0eWhQaN1SOH6KpiqWOjLvgoiOXIgQtUrfGen4SHf21M0AJhywKVJfLdxzjGz9dlX3eCZULvsBt4(TSdCfmAQFOd3pVKZ25W0OFKSLD)koCby1VLrSoH7NxD3y3c0)H7xXHlaR(Nvasu)YlhT)zf4S9hav)GRFzlwO(6HolHh9Cl1Vf0ez3pND)8soBNdt9xq9xE)12FWCCE)(1pMd0)X5JEEK86a7aQa1IYZuUyoBNdtSxqtSbMaxbJMgB2Y2G5SDomz1dmlYhEjrg)mQIMjmjffy5dUTIjimTObJM65rYRdSdOculkpt5UuctUXPekOMzoQNBP(Tm40EPo3laR(9aZI8TFhn8(LxAD)6cgQFOd3VJs9R4WHxhO)dQFEjNTZHP(XeeMw0(vC4cWQF7aOiPkn65rYRdSdOculkpt5I5SDomXEkFstgpWSiFNGN9cAInWe4ky00yZw2gmNTZHjRSbMaxbJMgClzSX1HlpVbFE41bSU2KwB8aZI8DSOC4klbmRFyj(MYWQhywKp8sIm(zufX3eVTip8od4A6KyoJ9vaFzlBTIjimTObJM65wQFEjbHPfTFEjNTZHP(PaRZ3Fb1F59lV06(PzBxyQFfhUaS6hjVeZP3r)Z663rdVFmbHPfT)cQFKBw9ZI8TFmfQ89xG(DuQFanBVFlUJEEK86a7aQa1IYZuUyoBNdtSxqtSbMaxbJMgB2Y2G5SDomzftsrb2mt3PvNCWyZlXC61Cqgffo6atsrbwEGhowt3PvNCWyZlXC61Cqgffo6atsrb2mNSOvpWSiF4Lez8ZOkAMWKuuGLV0DA1jhm28smNEnhKrrHJoWKuuGLhl2ZJKxhyhqfOwuEMYLrhPSg7tUIWSxqtSbMaxbJMgClzSX1HlpVbFE41bSU2KwB8aZI8LVj(3ZJKxhyhqfOwuEMYLGP2eHdN659Cl1FoCLwr4TNhjVoWoy4kTAArlyyVGMyJhAc4dqXc1xp0zj8GabJMuwXCac6WSOHxG8g)MDLmm6qrdAM5kBBszDTjT24bMf57yr5Wvwcyw)WszAXEEK86a7GHR0kEMYDr5Wvwcyw)WsSxqtRnP1gpWSiF5BkdE4ThAc4dw67Ky0HIgeiy0KYAyHeUCAytyOdhonWbilFtzy1(2YRdyyIuw22ZJKxhyhmCLwXZuUlHXHtkdZbiZAxzj2lOP0DA1jhmwcJdNugMdqM1UYsJeAGzrRbchjVoqO5BkJHfWIWc7ECAMcOgAkugM8gA2HKTMgeiy0KYkBy4GGgAkugM8gA2HKTMgC298i51b2bdxPv8mLll9Dsm6qr98i51b2bdxPv8mLltKYUEWiCHlea]] )


end
