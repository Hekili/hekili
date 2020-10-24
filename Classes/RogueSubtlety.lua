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
        shadow_techniques = {
            last = function () return state.query_time end,
            interval = function () return state.time_to_sht[5] end,
            value = 8,
            stop = function () return state.time_to_sht[5] == 0 or state.time_to_sht[5] == 3600 end,
        }, 
    } )

    spec:RegisterResource( Enum.PowerType.ComboPoints, {
        shadow_techniques = {
            last = function () return state.query_time end,
            interval = function () return state.time_to_sht[5] end,
            value = 1,
            stop = function () return state.time_to_sht[5] == 0 or state.time_to_sht[5] == 3600 end,
        },

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

            sht[1] = mh_next + ( 1 * mh_speed )
            sht[2] = mh_next + ( 2 * mh_speed )
            sht[3] = mh_next + ( 3 * mh_speed )
            sht[4] = mh_next + ( 4 * mh_speed )
            sht[5] = oh_next + ( 1 * oh_speed )
            sht[6] = oh_next + ( 2 * oh_speed )
            sht[7] = oh_next + ( 3 * oh_speed )
            sht[8] = oh_next + ( 4 * oh_speed )


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
            texture = 135430,

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


    spec:RegisterPack( "Subtlety", 20201024, [[dafy2bqiuQ8ifeBIs6tGevnkusDkqvTkqs1RqvmluLUfir2LO(LcXWav5yOuwgLONHQktJsW1uqABOK03OeIXbskNdKaRdvvH5PG6EGyFOQ8pqIk5GOuLSqfspKsOMiijxKsifBeLe9rqIkgjLqQojQQIwji1lbjQuZeLQuDtuvLANKK(jkvPmuusyPOufpfktLK4QGeLTIQQKVcsqNLsiL2lH)sXGv1HPAXO4XImzIUmYMv0NbLrdvNwQvtjK8Afy2K62Ky3a)wLHtPooiHwoKNR00fUoQSDqLVtsnEuQQZRqTEuvvZhLy)swWMqfbM0dsOQLWZs4Xg8S0cz2SKnlWpbwm2Mey2EAGdJeyaxHeyyCmHMIXcmBFS(CPqfb2ECOejWWJWE5pgzeyDGZXKtNYiBRWP9Opqc5ZyKTvsJiWy4ADWFcemcmPhKqvlHNLWJn4zPfYSzjBwWslIaZ5c8djWWAflwGH3sjbemcmjTjb2qQhJJj0umUE2ZbJJkOhs9S3sXXqO6T0c8wVLWZs4jW09gRqfb2gKRdCskurOkBcveyeWz0KumQalH6GqTlWyD9mCZzEdY1bEMZUEwyPEgU5mdNd6fpZzxp8fyEk6diWwCxEQ3a1diriu1sHkcmc4mAskgvGLqDqO2fymCZzEX5q9acyIdbC5L5SR3A9PtH5m2xdInlPzN6O(HHuVLcmpf9beyjxRnEk6dy09gcmDVHb4kKaB2GEXfHqv(jurGraNrtsXOcSeQdc1UaBTjT2eocgfBEX5q9acy24qk1dPEluV16tNcZzSVgeB98bPEliW8u0hqGLCT24POpGr3BiW09ggGRqcSzd6fxecvTGqfbgbCgnjfJkWsOoiu7cS0PWCg7RbXML0StDu)WqQNT6Hs1Z66dxtGiljYMqMnqE4WiLmbCgnjR3A9mCZzgoh0lEMZUE4lW8u0hqGLCT24POpGr3BiW09ggGRqcSzd6fxecvhQqfbgbCgnjfJkWsOoiu7cSW1eiYGggESHRhqOmbCgnjR3A9ioanpemkhnySjo2VtggTlPmbf5ABBskW8u0hqGT4nCIqOkRkurGraNrtsXOcSeQdc1UattWr66hU(HAz9wRxsmCZzE2aPrn5da0UzeP4nyRF46zRER1hocgf5OvitCgzt1dLQhrkEd265REwvG5POpGaBXD5PEdupGeHqvlIqfbgbCgnjfJkW8u0hqGT4U8uVbQhqcSeQdc1UatsmCZzE2aPrn5da0UzeP4nyRF46zRER1V2KwBchbJInV4COEabmBCiL6hgs98RER1hocgf5OvitCgzt1dLQhrkEd265REwvGLgN0KjCemkwHQSjcHQqnHkcmc4mAskgvGLqDqO2fySR(W1eiYsISjKzdKhomsjtaNrtY6TwVZ)eQdkZODjzAGjWjZI7Yt9Mroyq9qQNF1BT(1M0At4iyuS5fNd1diGzJdPupK65NaZtrFab2I7Yt9gOEajcHQqbcveyeWz0KumQalH6GqTlWGZrTZOPm3sgBuFOogBqx4rFG6TwpRRxsmCZzE2aPrn5da0UzeP4nyRF46zREwyP(W1eiYQj3(ak(gektaNrtY6Tw)AtATjCemk28IZH6beWSXHuQFyi1BH6zHL6D(NqDq5gqW1HZ06ogNjGZOjz9wRNHBoZ7yfMtVMBAKKh4zo76Tw)AtATjCemk28IZH6beWSXHuQFyi1ZV65PEN)juhuMr7sY0atGtMf3LN6ntaNrtY6HVaZtrFab2I7Yt9gOEajcHQSbpHkcmc4mAskgvGLqDqO2fyRnP1MWrWOyRNpi1ZV65PEwxpd3CMTrKcj7WJ(azo76zHL6z4MZCGtg0fbbYC21Zcl1J4a08qWOSpWDuVM940MjYHPqGitqrU22MK1BT(0bKCDKLeztiJ0HbJqBg5Gb1ZhK6Ti1dFbMNI(acSfNd1diGzJdPicHQSXMqfbgbCgnjfJkWsOoiu7cmjXWnN5zdKg1Kpaq7MrKI3GT(HHupB1Zcl1NUtlp1G8owH50R5Mgj5bEgrkEd26hUE2GA1BTEjXWnN5zdKg1Kpaq7MrKI3GT(HRpDNwEQb5DScZPxZnnsYd8mIu8gScmpf9beylUlp1BG6bKieQYMLcveyeWz0KumQaBEidGy)qOkBcmpf9bey23PniApouIeHqv24NqfbgbCgnjfJkWsOoiu7cm2vpIdqZdbJY(a3r9A2JtBMihMcbImbf5ABBswV16z4MZSnHMhYdsAGJAWM3WtdQNpi1ZV6TwF6asUoY2eAEipiPboQbBg5Gb1ZhK6zJF1dLQN11dfupuV(0bKCDKLeztiJ0HbJqzc4mAswpp1NoGKRJSKiBczKomyekJCWG6HVaZtrFabgm9DkmAxsIqOkBwqOIaJaoJMKIrfyjuheQDbgIdqZdbJY(a3r9A2JtBMihMcbImbf5ABBswV16z4MZSnHMhYdsAGJAWM3WtdQNpi1ZV6TwpRRpDajxhzBcnpKhK0ah1GnJCWG65P(0bKCDKLeztiJ0HbJqzKdgup8RNpi1ZgRkW8u0hqGbtFNcJ2LKieQY2qfQiW8u0hqGT4U8uVbQhqcmc4mAskgveIqGr7sGeTcveQYMqfbgbCgnjfJkWsOoiu7cmcqiyJZrRqM4mko7xpF1Zw9wRND1ZWnN5DScZPxZnnsYd8mND9wRN11ZU6LxKthirGa5bjntTRqggoeihDAqdGvV16zx9Ek6dKthirGa5bjntTRq5gyM6ggEuplSu)KtRnikH7iyKjAfQ(HRhwsMvC2VE4lW8u0hqGLoqIabYdsAMAxHeHqvlfQiWiGZOjPyubwc1bHAxGXU6t3PLNAqEXD5P2WODjTzo76TwF6oT8udY7yfMtVMBAKKh4zo76zHL6Nnm8WGifVbB9ddPE2GNaZtrFabgJ(oP5MMaNmeGuglcHQ8tOIaZtrFabgmohjBhyUPX5FcDbUaJaoJMKIrfHqvliurGraNrtsXOcSeQdc1UaJ11V2KwBchbJInV4COEabmBCiL65ds9wwplSupYBPHGJar2LYn3G65REwfE1d)6Twp7QpDNwEQb5DScZPxZnnsYd8mND9wRND1ZWnN5DScZPxZnnsYd8mND9wRNaec24SKMDQJ65ds98dEcmpf9beyZlXTK048pH6GmmKRicHQdvOIaJaoJMKIrfyjuheQDb2AtATjCemk28IZH6beWSXHuQNpi1Bz9SWs9iVLgcocezxk3CdQNV6zv4jW8u0hqGzZH654gaZWO9neHqvwvOIaJaoJMKIrfyjuheQDbgd3CMruAGM21mpuIYC21Zcl1ZWnNzeLgOPDnZdLit64abHYB4Pb1pC9SbpbMNI(acSaNmCaMJdinZdLiriu1IiurG5POpGad122AY0aZA7jsGraNrtsXOIqOkutOIaJaoJMKIrfyjuheQDbw6oT8udY7yfMtVMBAKKh4zeP4nyRF46hA9SWs9ZggEyqKI3GT(HRNnOMaZtrFabM6dPLWrnWGO9aoirIqOkuGqfbgbCgnjfJkWsOoiu7cmcqiyJRF46Ta8Q3A9mCZzEhRWC61CtJK8apZzlW8u0hqGPqkhAS5MgnxQLgjICLvecvzdEcveyeWz0KumQalH6GqTlWMnm8WGifVbB9dxpB5HwplSupRRN11hocgfzCY1bE2of1Zx9qn4vplSuF4iyuKXjxh4z7uu)WqQ3s4vp8R3A9SUEpfnCKHaKstB9qQNT6zHL6Nnm8WGifVbB98vVLqb1d)6HF9SWs9SU(WrWOihTczIZyNcJLWRE(QNFWRER1Z669u0WrgcqknT1dPE2QNfwQF2WWddIu8gS1Zx9wWc1d)6HVaZtrFabgIC7gaZm1UcTIqecmjnDoDiurOkBcveyEk6diWg0Pbcmc4mAskgvecvTuOIaJaoJMKIrfyNTaBPqG5POpGadoh1oJMeyW5AosGXWnN5v3jY4aPr2jkZzxplSu)AtATjCemk28IZH6beWSXHuQNpi1ZQcm4CKb4kKaBbst6aYo6dicHQ8tOIaJaoJMKIrfyEk6diWsUwB8u0hWO7ney6EddWvibwsUIqOQfeQiWiGZOjPyubwc1bHAxGTb56aNKzxRfyEk6diWqCaJNI(agDVHat3ByaUcjW2GCDGtsriuDOcveyeWz0KumQalH6GqTlWwBsRnHJGrXMxCoupGaMnoKs9dxpRwV16Nnm8WGifVbB98vpRwV16z4MZ8Q7ezCG0i7eLrKI3GT(HRhwsMvC2VER1NofMZyFni265ds9wOEOu9SU(OvO6hUE2Gx9WVEOE9wkW8u0hqGT6orghinYorIqOkRkurGraNrtsXOcSZwGTuiW8u0hqGbNJANrtcm4CnhjWSr9H6ySbDHh9bQ3A9RnP1MWrWOyZlohQhqaZghsPE(GuVLcm4CKb4kKaJBjJnQpuhJnOl8OpGieQAreQiWiGZOjPyubwc1bHAxGbNJANrtzULm2O(qDm2GUWJ(acmpf9beyjxRnEk6dy09gcmDVHb4kKaBdY1bUjjxriufQjurGraNrtsXOcSZwGTuiW8u0hqGbNJANrtcm4CnhjWSCO1Zt9HRjqKHRHDOmbCgnjRhQxVLWREEQpCnbISIVbHm30S4U8uVzc4mAswpuVElHx98uF4Ace5f3LNAZ8sCBMaoJMK1d1R3YHwpp1hUMar21Ec1X4mbCgnjRhQxVLWREEQ3YHwpuVEwx)AtATjCemk28IZH6beWSXHuQNpi1BH6HVadohzaUcjW2GCDGBcCeT4NwkcHQqbcveyeWz0KumQalH6GqTlWiaHGnolPzN6O(HHupCoQDgnL3GCDGBcCeT4NwkW8u0hqGLCT24POpGr3BiW09ggGRqcSnixh4MKCfHqv2GNqfbgbCgnjfJkWsOoiu7cmN)juhug0WWJ1ahbGroirzc4mAswV16zx9mCZzg0WWJ1ahbGroirzo76TwF6uyoJ91GyZsA2PoQNV6zRER1Z66xBsRnHJGrXMxCoupGaMnoKs9dxVL1Zcl1dNJANrtzULm2O(qDm2GUWJ(a1d)6TwpRRpDNwEQb5DScZPxZnnsYd8mIu8gS1pmK65x9SWs9SUEN)juhug0WWJ1ahbGroirzKdgupFqQ3Y6Twpd3CM3XkmNEn30ijpWZisXBWwpF1ZV6Twp7QFdY1bojZUwxV16t3PLNAqEXD5P2iDqIYjChbJwZe5POpGRRNpi1dVmuq9WVE4lW8u0hqGH4SdoejcHQSXMqfbgbCgnjfJkWsOoiu7cmehGMhcgLLKh46XMf3LN6ntqrU22MK1BTE5f5LS3EZrNg0ay1BTE5f5LS3EZisXBWw)WqQ3Y6TwF6uyoJ91GyRNpi1BPaZtrFabwY1AJNI(agDVHat3ByaUcjWMnOxCriuLnlfQiWiGZOjPyubwc1bHAxGLofMZyFni26HuVdAfpH7iyK0KSfyEk6diWsUwB8u0hWO7ney6EddWvib2Sb9IlcHQSXpHkcmc4mAskgvGLqDqO2fyPtH5m2xdInlPzN6O(HHupB1Zcl1pBy4HbrkEd26hgs9SvV16tNcZzSVgeB98bPE(jW8u0hqGLCT24POpGr3BiW09ggGRqcSzd6fxecvzZccveyeWz0KumQalH6GqTlWwBsRnHJGrXMxCoupGaMnoKs9qQ3c1BT(0PWCg7RbXwpFqQ3ccmpf9beyjxRnEk6dy09gcmDVHb4kKaB2GEXfHqv2gQqfbgbCgnjfJkWsOoiu7cmcqiyJZsA2PoQFyi1dNJANrt5nixh4Mahrl(PLcmpf9beyjxRnEk6dy09gcmDVHb4kKaJHR1sriuLnwvOIaJaoJMKIrfyjuheQDbgbieSXzjn7uh1ZhK6zBO1Zt9eGqWgNremciW8u0hqG5OKditCiebcriuLnlIqfbMNI(acmhLCazS50ljWiGZOjPyuriuLnOMqfbMNI(acmDddpwJffNeMcbcbgbCgnjfJkcHQSbfiurG5POpGaJXHzUPjqDAWkWiGZOjPyuricbMnIsNcJhcveQYMqfbMNI(acm32wp2yF9EabgbCgnjfJkcHQwkurG5POpGaBdY1bUaJaoJMKIrfHqv(jurGraNrtsXOcmpf9beykoAajnZdzKKh4cmBeLofgpmlLoGCfySnuriu1ccveyeWz0KumQaZtrFab2Q7ezCG0i7ejWsOoiu7cmenr0I7mAsGzJO0PW4HzP0bKRaJnriuDOcveyeWz0KumQalH6GqTlWqCaAEiyuwXrdm30e4KrX3GqgFxF3gKjOixBBtsbMNI(acSf3LNAdJ2L0kcHQSQqfbgbCgnjfJkWaUcjWC(FXDKVM5bcZnn2NAcjW8u0hqG58)I7iFnZdeMBASp1eseIqGXW1APqfHQSjurGraNrtsXOcSeQdc1UaJD1hUMarg0WWJnC9acLjGZOjz9wRhXbO5HGr5ObJnXX(DYWODjLjOixBBtsbMNI(acSfVHtecvTuOIaJaoJMKIrfyjuheQDb2AtATjCemk265ds9wwpp1Z66dxtGidtFNcJ2LuMaoJMK1BTEN)juhu2MqZd5bLroyq98bPElRh(cmpf9beylohQhqaZghsrecv5NqfbgbCgnjfJkWsOoiu7cS0DA5PgKxcH8GKgMdqM1Uhq5eUJGrRzI8u0hW11ZhK6TmBrgQaZtrFab2siKhK0WCaYS29asecvTGqfbMNI(acmy67uy0UKeyeWz0KumQieQouHkcmpf9beymEAWgoJaJaoJMKIrfHieyj5kurOkBcveyeWz0KumQalH6GqTlWyx9mCZzEXD5P2iDqIYC21BTEgU5mV4COEabmXHaU8YC21BTEgU5mV4COEabmXHaU8YisXBWw)WqQNF5HkW8u0hqGT4U8uBKoircmULm3CAGLKcvztecvTuOIaJaoJMKIrfyjuheQDbgd3CMxCoupGaM4qaxEzo76Twpd3CMxCoupGaM4qaxEzeP4nyRFyi1ZV8qfyEk6diW2XkmNEn30ijpWfyClzU50aljfQYMieQYpHkcmc4mAskgvGLqDqO2fyW5O2z0uEbst6aYo6duV16zx9BqUoWjzwXbHMeyEk6diWMAhgP1E0hqecvTGqfbgbCgnjfJkWsOoiu7cmjXWnN5P2HrATh9bYisXBWw)W1Bz9SWs9sIHBoZtTdJ0Ap6dK3WtdQNpi1Zp4jW8u0hqGn1omsR9OpGjPjhSKieQouHkcmc4mAskgvGLqDqO2fySUEehGMhcgLvC0aZnnbozu8niKX313TbzckY122KSER1NofMZyFni2SKMDQJ6hgs98REwyPEehGMhcgLLKh46XMf3LN6ntqrU22MK1BT(0PWCg7RbXw)W1Zw9WVER1ZWnN5DScZPxZnnsYd8mND9wRNHBoZlUlp1gPdsuMZUER1R4BqiJVRVBdmisXBWwpK6Hx9wRNHBoZsYdC9yZI7Yt9MLNAGaZtrFabgCoOxCriuLvfQiWiGZOjPyubwc1bHAxGXU63GCDGtYSR11BTE4Cu7mAkVaPjDazh9bQNfwQN2LajkZGipWn30e4KroUbWYkUf1HQ3A9rRq1ZhK6TuG5POpGal5ATXtrFaJU3qGP7nmaxHey0UeirRieQAreQiWiGZOjPyubMNI(acm770geThhkrcSeQdc1UaJD1hUMarEXD5P2mVe3MjGZOjPaBEidGy)qOkBIqOkutOIaJaoJMKIrfyjuheQDbgbieSX1ZhK6zv4vV16HZrTZOP8cKM0bKD0hOER1NUtlp1G8owH50R5Mgj5bEMZUER1NUtlp1G8I7YtTr6GeLt4ocgT1ZhK6ztG5POpGaBX5q9acyIdbC5jcHQqbcveyeWz0KumQaZtrFab2siKhK0WCaYS29asGLqDqO2fyW5O2z0uEbst6aYo6duV16zx9YlYlHqEqsdZbiZA3diJ8IC0Pbnaw9wRpCemkYrRqM4mYMQNpi1BjB1Zcl1pBy4HbrkEd26hgs9dTER1V2KwBchbJInV4COEabmBCiL6hUE(jWsJtAYeocgfRqv2eHqv2GNqfbgbCgnjfJkWsOoiu7cm4Cu7mAkVaPjDazh9bQ3A9SR(0DA5PgKxCxEQnmAxsBMZUER1Z66dxtGita4i9z3ayMf3LN6ntaNrtY6zHL6t3PLNAqEXD5P2iDqIYjChbJ265ds9Svp8R3A9SUE2vF4Ace5fNd1diGjoeWLxMaoJMK1Zcl1hUMarEXD5P2mVe3MjGZOjz9SWs9P70YtniV4COEabmXHaU8YisXBWwpF1Bz9WVER1Z66zx90Ueirzg9DsZnnboziaPmoR4wuhQEwyP(0DA5PgKz03jn30e4KHaKY4mIu8gS1Zx9wwp8fyEk6diW2XkmNEn30ijpWfHqv2ytOIaJaoJMKIrfyEk6diWuC0asAMhYijpWfyjuheQDbgYBPHGJar2LYnZzxV16zD9HJGrroAfYeNr2u9dxF6uyoJ91GyZsA2PoQNfwQND1Vb56aNKzxRR3A9PtH5m2xdInlPzN6OE(GuFY2O4SVzTjGSE4lWsJtAYeocgfRqv2eHqv2SuOIaJaoJMKIrfyjuheQDbgYBPHGJar2LYn3G65RE(bV6Hs1J8wAi4iqKDPCZsoKh9bQ3A9PtH5m2xdInlPzN6OE(GuFY2O4SVzTjGuG5POpGatXrdiPzEiJK8axecvzJFcveyeWz0KumQalH6GqTlWGZrTZOP8cKM0bKD0hOER1NofMZyFni2SKMDQJ65ds9wkW8u0hqGT4U8uBy0UKwriuLnliurGraNrtsXOcSeQdc1Uadoh1oJMYlqAshq2rFG6TwF6uyoJ91GyZsA2PoQNpi1ZV6Tw)AtATjCemk28IZH6beWSXHuQFyi1BbbMNI(acmkHFnaMbr2OwXbsriuLTHkurGraNrtsXOcSeQdc1UalCnbI8I7YtTzEjUntaNrtY6TwpCoQDgnLxG0KoGSJ(a1BTEgU5mVJvyo9AUPrsEGN5SfyEk6diWwCoupGaM4qaxEIqOkBSQqfbgbCgnjfJkWsOoiu7cm2vpd3CMxCxEQnshKOmND9wRF2WWddIu8gS1pmK6HA1Zt9HRjqKxoMGqtoyuMaoJMKcmpf9beylUlp1gPdsKieQYMfrOIaZtrFabM9f9beyeWz0KumQieQYgutOIaJaoJMKIrfyjuheQDbgd3CM3XkmNEn30ijpWZC2cmpf9beym67KMjhASieQYguGqfbgbCgnjfJkWsOoiu7cmgU5mVJvyo9AUPrsEGN5SfyEk6diWyi0sObnaMieQAj8eQiWiGZOjPyubwc1bHAxGXWnN5DScZPxZnnsYd8mNTaZtrFab2SreJ(oPieQAjBcveyeWz0KumQalH6GqTlWy4MZ8owH50R5Mgj5bEMZwG5POpGaZbjAdKRnjxRfHqvlTuOIaJaoJMKIrfyEk6diWsJt6lqhOtggTVHalH6GqTlWyx9BqUoWjz2166TwpCoQDgnLxG0KoGSJ(a1BTE2vpd3CM3XkmNEn30ijpWZC21BTEcqiyJZsA2PoQNpi1Zp4jWO5KsHb4kKalnoPVaDGozy0(gIqOQL8tOIaJaoJMKIrfyEk6diWC(FXDKVM5bcZnn2NAcjWsOoiu7cm2vpd3CMxCxEQnshKOmND9wRpDNwEQb5DScZPxZnnsYd8mIu8gS1pC9SbpbgWvibMZ)lUJ81mpqyUPX(utiriu1sliurGraNrtsXOcmpf9bey(IdNdO1GC()qM0HCTalH6GqTlWKed3CMro)Fit6qU2ijgU5mlp1G6zHL6Led3CMthqYLIgoY0GbgjXWnNzo76TwF4iyuKXjxh4z7uu)W1ZplR3A9HJGrrgNCDGNTtr98bPE(bV6zHL6zx9sIHBoZPdi5srdhzAWaJKy4MZmND9wRN11ljgU5mJC()qM0HCTrsmCZzEdpnOE(GuVLdTEOu9SbV6H61ljgU5mZOVtAUPjWjdbiLXzo76zHL6Nnm8WGifVbB9dxVfGx9WVER1ZWnN5DScZPxZnnsYd8mIu8gS1Zx9qnbgWvibMV4W5aAniN)pKjDixlcHQwouHkcmc4mAskgvGbCfsGPmw6RjCDVkoqG5POpGatzS0xt46EvCGieQAjRkurGraNrtsXOcSeQdc1UaJHBoZ7yfMtVMBAKKh4zo76zHL6Nnm8WGifVbB9dxVLWtG5POpGaJBjthKYkcriW2GCDGBsYvOIqv2eQiWiGZOjPyub2zlWwkeyEk6diWGZrTZOjbgCUMJeyP70YtniV4U8uBKoir5eUJGrRzI8u0hW11ZhK6zlBrgQadohzaUcjWwCPjWr0IFAPieQAPqfbgbCgnjfJkWsOoiu7cmwxp7Qhoh1oJMYlU0e4iAXpTSEwyPE2vF4Acezqddp2W1diuMaoJMK1BT(W1eiYshnWS4U8uNjGZOjz9WVER1NofMZyFni2SKMDQJ65RE2Q3A9SREehGMhcgLvC0aZnnbozu8niKX313TbzckY122KuG5POpGadoh0lUieQYpHkcmpf9beylzV9kWiGZOjPyuriu1ccveyeWz0KumQaZtrFabM9DAdI2JdLibgX(bYnUYXbcbMfGNaBEidGy)qOkBIqO6qfQiWiGZOjPyubwc1bHAxGracbBC98bPElaV6TwpbieSXzjn7uh1ZhK6zdE1BTE2vpCoQDgnLxCPjWr0IFAz9wRpDkmNX(AqSzjn7uh1Zx9SvV16Led3CMNnqAut(aaTBgrkEd26hUE2eyEk6diWwCxEQviTuecvzvHkcmc4mAskgvGD2cSLcbMNI(acm4Cu7mAsGbNR5ibw6uyoJ91GyZsA2PoQNpi1BbbgCoYaCfsGT4st6uyoJ91GyfHqvlIqfbgbCgnjfJkWoBb2sHaZtrFabgCoQDgnjWGZ1CKalDkmNX(AqSzjn7uh1pmK6ztGLqDqO2fyW5O2z0uMBjJnQpuhJnOl8OpGadohzaUcjWwCPjDkmNX(AqSIqOkutOIaJaoJMKIrfyjuheQDbgCoQDgnLxCPjDkmNX(AqS1BTEwxpCoQDgnLxCPjWr0IFAz9SWs9mCZzEhRWC61CtJK8apJifVbB98bPE2YwwplSu)AtATjCemk28IZH6beWSXHuQNpi1BH6TwF6oT8udY7yfMtVMBAKKh4zeP4nyRNV6zdE1dFbMNI(acSf3LNAJ0bjsecvHceQiWiGZOjPyubwc1bHAxGbNJANrt5fxAsNcZzSVgeB9wRF2WWddIu8gS1pC9P70YtniVJvyo9AUPrsEGNrKI3GvG5POpGaBXD5P2iDqIeHieyZg0lUqfHQSjurGraNrtsXOcSeQdc1UaBTjT2eocgfBEX5q9acy24qk1pC9SA9wRND1ZWnN5f3LNAJ0bjkZzxV16z4MZ8Q7ezCG0i7eLrKI3GT(HRF2WWddIu8gS1BTEgU5mV6orghinYorzeP4nyRF46zD9Svpp1NofMZyFni26HF9q96zld1eyEk6diWwDNiJdKgzNiriu1sHkcmc4mAskgvGD2cSLcbMNI(acm4Cu7mAsGbNR5ibMIVbHm(U(UnWGifVbB98vp8QNfwQND1hUMarg0WWJnC9acLjGZOjz9wRpCnbIS0rdmlUlp1zc4mAswV16z4MZ8I7YtTr6GeL5SRNfwQFTjT2eocgfBEX5q9acy24qk1ZhK6zvbgCoYaCfsGTdABdIZo4qKieQYpHkcmc4mAskgvGLqDqO2fySRE4Cu7mAkVdABdIZo4qu9wRpCemkYrRqM4mYMQhkvpIu8gS1Zx9SA9wRhrteT4oJMeyEk6diWqC2bhIeHqvliurG5POpGaBPeIctqjCqdf5ibgbCgnjfJkcHQdvOIaJaoJMKIrfyEk6diWqC2bhIeyjuheQDbg7Qhoh1oJMY7G22G4SdoevV16zx9W5O2z0uMBjJnQpuhJnOl8Opq9wRFTjT2eocgfBEX5q9acy24qk1ZhK6TSER1hocgf5OvitCgzt1ZhK6zD9dTEEQN11Bz9q96tNcZzSVgeB9WVE4xV16r0erlUZOjbwACstMWrWOyfQYMieQYQcveyeWz0KumQalH6GqTlWyx9W5O2z0uEh02geNDWHO6TwpIu8gS1pC9P70YtniVJvyo9AUPrsEGNrKI3GTEEQNn4vV16t3PLNAqEhRWC61CtJK8apJifVbB9ddP(HwV16dhbJIC0kKjoJSP6Hs1JifVbB98vF6oT8udY7yfMtVMBAKKh4zeP4nyRNN6hQaZtrFabgIZo4qKieQAreQiWiGZOjPyubwc1bHAxGXU6HZrTZOPm3sgBuFOogBqx4rFG6Tw)AtATjCemk265ds98tG5POpGaJr7Pbg7tTKqIqOkutOIaZtrFabgbxVjc5bjWiGZOjPyuricriWGJqBFaHQwcplHhBWZs4jWu7iqdGTcmOq2l2JQ8NQcLd)r91RcovFRyFOO(5HQhkpdxRLq5RhrqrUgrY63tHQ35ItXdswFc3bWOnxqZEVbu9wYFup7Huo4iz9232rFadJNguFcNsdQN1GlQ3HZBTZOP6Bq9KcN2J(aWVEwZg7d)CbDbn)PI9HcswpuREpf9bQx3BS5cAb2AtjHQwYQSjWSr3S1KaBi1JXXeAkgxp75GXrf0dPE2BP4yiu9wAbER3s4zj8kOlOhs9ScebLS4tHXJcApf9b2SnIsNcJh8aze32wp2yF9EGcApf9b2SnIsNcJh8azKnixh4f0Ek6dSzBeLofgp4bYikoAajnZdzKKh48AJO0PW4HzP0bKle2gAbTNI(aB2grPtHXdEGmYQ7ezCG0i7eXRnIsNcJhMLshqUqyJ3EcbrteT4oJMkO9u0hyZ2ikDkmEWdKrwCxEQnmAxslV9ecIdqZdbJYkoAG5MMaNmk(geY47672Gmbf5ABBswq7POpWMTru6uy8GhiJWTKPdsHxGRqqC(FXDKVM5bcZnn2NAcvqxqpK65V9gup75cp6duq7POpWczqNguq7POpWYdKrGZrTZOjEbUcbzbst6aYo6dWlCUMJGWWnN5v3jY4aPr2jkZzZclRnP1MWrWOyZlohQhqaZghsHpiSkVqzljRpU6LuqiLgq1RgNcCcvF6oT8ud26v7Du)8q1JbGQ6z8LK1FG6dhbJInxqpK6TyCknOElgQ269O(zJ2OG2trFGLhiJKCT24POpGr3BWlWviij5wqpK6zpCG6NCA946x1DKWPT(4QpWP6XcY1bojRN9CHh9bQN1mJRxEnaw97XBh1ppuI26TVt3ay13Z6bxG3ay13B9oCERDgnb)CbTNI(alpqgbXbmEk6dy09g8cCfcYgKRdCsYBpHSb56aNKzxRlOhs9Sx226X1V6orghinYor17r9wYt9wmROEjhQbWQpWP6NnAJ6zdE1Vu6aYLxFgeQ(a3J6Tap1BXSI67z9DupX(2nI26v3bEdQpWP6be7h1dLJfdv1FO67TEWf1Zzxq7POpWYdKrwDNiJdKgzNiE7jK1M0At4iyuS5fNd1diGzJdPmmRAD2WWddIu8gS8XQwz4MZ8Q7ezCG0i7eLrKI3GDyyjzwXzFRPtH5m2xdILpiwakX6OvOHzdEWhQBzb9qQN9gqpU(eUdGr1JUWJ(a13Z6vt1J7Wr1BJ6d1Xyd6cp6du)sr9oqwVcNoABnvF4iyuS1ZzNlO9u0hy5bYiW5O2z0eVaxHGWTKXg1hQJXg0fE0hGx4CnhbXg1hQJXg0fE0hW6AtATjCemk28IZH6beWSXHu4dILf0dPEwbQpuhJRN9CHh9bGYv9S3Pak)wpSgoQEV(eYTR3zoUOEcqiyJRFEO6dCQ(nixh41BXq1wpRz4ATKq1VrR11JO1Msr9Da)C9w0YzZBh1NCq9mu9bUh1VTITMYf0Ek6dS8azKKR1gpf9bm6EdEbUcbzdY1bUjjxE7je4Cu7mAkZTKXg1hQJXg0fE0hOGEi1dLTKS(4QxsZgq1RgNa1hx9Clv)gKRd86TyOAR)q1ZW1AjH2cApf9bwEGmcCoQDgnXlWviiBqUoWnboIw8tl5foxZrqSCO8eUMargUg2HYeWz0KeQBj84jCnbISIVbHm30S4U8uVzc4mAsc1TeE8eUMarEXD5P2mVe3MjGZOjju3YHYt4Acezx7juhJZeWz0KeQBj84XYHc1z9AtATjCemk28IZH6beWSXHu4dIfGFb9qQ3IpW2scvp32ay171JfKRd86TyOQE14eOEe5j8gaR(aNQNaec246dCeT4Nwwq7POpWYdKrsUwB8u0hWO7n4f4keKnixh4MKC5TNqiaHGnolPzN6yyiW5O2z0uEdY1bUjWr0IFAzb9qQx1ggEaLFRN)IaWihKi(J6zpC2bhIQNHMhIQhBScZP369OE9PUElMvuFC1NofMgq1tospUEenr0IxV6oWRhgfrdGvFGt1ZWnN1ZzNRN9sVx96tD9wmROEjhQbWQhBScZP36zOqnrG6HkhKOTE1DGxVL8uVQ8x5cApf9bwEGmcIZo4qeV9eIZ)eQdkdAy4XAGJaWihKOmbCgnjTYogU5mdAy4XAGJaWihKOmNT10PWCg7RbXML0StDWhBwz9AtATjCemk28IZH6beWSXHug2swyboh1oJMYClzSr9H6ySbDHh9bGVvwNUtlp1G8owH50R5Mgj5bEgrkEd2HHWpwyH1o)tOoOmOHHhRbocaJCqIYihmGpiwALHBoZ7yfMtVMBAKKh4zeP4ny5JFwz3gKRdCsMDT2A6oT8udYlUlp1gPdsuoH7iy0AMipf9bCnFqGxgka(WVG2trFGLhiJKCT24POpGr3BWlWviiZg0loV9ecIdqZdbJYsYdC9yZI7Yt9MjOixBBtsRYlYlzV9MJonObWSkViVK92BgrkEd2HHyP10PWCg7RbXYhellO9u0hy5bYijxRnEk6dy09g8cCfcYSb9IZBpHKofMZyFniwioOv8eUJGrstYUGEi1puEQxDh41dvy1Z6Jl2ws1Vb56ah(f0Ek6dS8azKKR1gpf9bm6EdEbUcbz2GEX5TNqsNcZzSVgeBwsZo1XWqyJfwMnm8WGifVb7WqyZA6uyoJ91Gy5dc)kOhs9SYg0lE9EuVf4PE1DGFCr9qfwb9qQhkSd86HkS6D9E1pBqV417r9wGN6DyEd2OEI99uOhxVfQpCemk26z9XfBlP63GCDGd)cApf9bwEGmsY1AJNI(agDVbVaxHGmBqV482tiRnP1MWrWOyZlohQhqaZghsbIfSMofMZyFniw(GyHc6Hupu2s171ZW1AjHQxnobQhrEcVbWQpWP6jaHGnU(ahrl(PLf0Ek6dS8azKKR1gpf9bm6EdEbUcbHHR1sE7jecqiyJZsA2PoggcCoQDgnL3GCDGBcCeT4NwwqpK6zVFQPnQ3g1hQJX13G6DTU(BwFGt1ZEXkyVxpdLCULQVJ6to3sB9E9q5yXqvbTNI(alpqgXrjhqM4qice82tieGqWgNL0StDWhe2gkpeGqWgNremcuq7POpWYdKrCuYbKXMtVubTNI(alpqgr3WWJ1yrXjHPqGOG2trFGLhiJW4Wm30eOonylOlOhs9w8DA5PgSf0dPEOSLQhQCqIQ)MtOeSKSEgAEiQ(aNQF2OnQFX5q9acy24qk1prNs9QCiGlV6tNcT13GCbTNI(aBojxEGmYI7YtTr6GeXl3sMBonWssiSXBpHWogU5mV4U8uBKoirzoBRmCZzEX5q9acyIdbC5L5STYWnN5fNd1diGjoeWLxgrkEd2HHWV8qlOhs9SgkdOPDR31iYLJRNZUEgk5ClvVAQ(4Ub1JH7YtD9SYlXTWVEULQhBScZP36V5ekbljRNHMhIQpWP6NnAJ6xCoupGaMnoKs9t0PuVkhc4YR(0PqB9nixq7POpWMtYLhiJSJvyo9AUPrsEGZl3sMBonWssiSXBpHWWnN5fNd1diGjoeWLxMZ2kd3CMxCoupGaM4qaxEzeP4nyhgc)YdTG2trFGnNKlpqgzQDyKw7rFaE7je4Cu7mAkVaPjDazh9bSYUnixh4KmR4Gqtf0Ek6dS5KC5bYitTdJ0Ap6dysAYblXBpHijgU5mp1omsR9OpqgrkEd2HTKfwKed3CMNAhgP1E0hiVHNgWhe(bVcApf9b2CsU8aze4CqV482tiSgXbO5HGrzfhnWCttGtgfFdcz8D9DBqMGICTTnjTMofMZyFni2SKMDQJHHWpwybXbO5HGrzj5bUESzXD5PEZeuKRTTjP10PWCg7RbXomBW3kd3CM3XkmNEn30ijpWZC2wz4MZ8I7YtTr6GeL5STQ4BqiJVRVBdmisXBWcbEwz4MZSK8axp2S4U8uVz5Pguq7POpWMtYLhiJKCT24POpGr3BWlWvii0UeirlV9ec72GCDGtYSR1wHZrTZOP8cKM0bKD0hGfwODjqIYmiYdCZnnbozKJBaSSIBrDiRrRq8bXYc6HupR4oD9ZdvVkhc4YREBebLWoOQE1DGxpgouvpIC546vJtG6bxupIdaAaS6XyL5cApf9b2CsU8aze770geThhkr8opKbqSFaHnE7je2fUMarEXD5P2mVe3MjGZOjzb9qQhkBP6v5qaxE1BJO6XoOQE14eOE1u94oCu9bovpbieSX1RgNcCcv)eDk1BFNUbWQxDh4hxupgRS(dvVff3g1dJaeY16X5cApf9b2CsU8azKfNd1diGjoeWLhV9ecbieSX8bHvHNv4Cu7mAkVaPjDazh9bSMUtlp1G8owH50R5Mgj5bEMZ2A6oT8udYlUlp1gPdsuoH7iy0Yhe2kO9u0hyZj5YdKrwcH8GKgMdqM1Uhq8MgN0KjCemkwiSXBpHaNJANrt5finPdi7OpGv2jViVec5bjnmhGmRDpGmYlYrNg0aywdhbJIC0kKjoJSj(GyjBSWYSHHhgeP4nyhgYqTU2KwBchbJInV4COEabmBCiLH5xb9qQhkBP6XgRWC6T(duF6oT8udQN1(miu9ZgTr9yaOc(1Zb00U1RMQ3ru9WUgaR(4Q3(SRxLdbC5vVdK1lV6bxupUdhvpgUlp11ZkVe3MlO9u0hyZj5YdKr2XkmNEn30ijpW5TNqGZrTZOP8cKM0bKD0hWk7s3PLNAqEXD5P2WODjTzoBRSoCnbImbGJ0NDdGzwCxEQ3mbCgnjzHL0DA5PgKxCxEQnshKOCc3rWOLpiSbFRSMDHRjqKxCoupGaM4qaxEzc4mAsYclHRjqKxCxEQnZlXTzc4mAsYclP70YtniV4COEabmXHaU8YisXBWYNLW3kRzhTlbsuMrFN0CttGtgcqkJZkUf1HyHL0DA5PgKz03jn30e4KHaKY4mIu8gS8zj8lOhs98NZ6DPCR3ru9C28w)cABQ(aNQ)au9Q7aVE9PM2OEvubQY1dLTu9QXjq9YXnaw9tFdcvFG7G6Tywr9sA2PoQ)q1dUO(nixh4KSE1DGFCr9oyC9wmRixq7POpWMtYLhiJO4ObK0mpKrsEGZBACstMWrWOyHWgV9ecYBPHGJar2LYnZzBL1HJGrroAfYeNr20WPtH5m2xdInlPzN6Gfwy3gKRdCsMDT2A6uyoJ91GyZsA2Po4dsY2O4SVzTjGe(f0dPE(Zz9GRExk36v3AD9YMQxDh4nO(aNQhqSFup)G3YB9Clvp)9eQQ)a1ZC7wV6oWpUOEhmUElMvKlO9u0hyZj5YdKruC0asAMhYijpW5TNqqElneCeiYUuU5gWh)Ghuc5T0qWrGi7s5MLCip6dynDkmNX(AqSzjn7uh8bjzBuC23S2eqwq7POpWMtYLhiJS4U8uBy0UKwE7je4Cu7mAkVaPjDazh9bSMofMZyFni2SKMDQd(GyzbTNI(aBojxEGmcLWVgaZGiBuR4ajV9ecCoQDgnLxG0KoGSJ(awtNcZzSVgeBwsZo1bFq4N11M0At4iyuS5fNd1diGzJdPmmeluqpK6Hc7aVEmwjV13Z6bxuVRrKlhxV8aeV1ZTu9QCiGlV6v3bE9yhuvpNDUG2trFGnNKlpqgzX5q9acyIdbC5XBpHeUMarEXD5P2mVe3MjGZOjPv4Cu7mAkVaPjDazh9bSYWnN5DScZPxZnnsYd8mNDbTNI(aBojxEGmYI7YtTr6GeXBpHWogU5mV4U8uBKoirzoBRZggEyqKI3GDyiqnEcxtGiVCmbHMCWOmbCgnjlOlOhs9QEaO0AtP63GBoRxDh41Rp1eQEBuFf0Ek6dS5KC5bYi2x0hOG2trFGnNKlpqgHrFN0m5qJ5TNqy4MZ8owH50R5Mgj5bEMZUG2trFGnNKlpqgHHqlHg0ay82timCZzEhRWC61CtJK8apZzxq7POpWMtYLhiJmBeXOVtYBpHWWnN5DScZPxZnnsYd8mNDbTNI(aBojxEGmIds0gixBsUwZBpHWWnN5DScZPxZnnsYd8mNDbDbTNI(aBojxEGmc3sMoifEP5KsHb4keK04K(c0b6KHr7BWBpHWUnixh4Km7ATv4Cu7mAkVaPjDazh9bSYogU5mVJvyo9AUPrsEGN5STsacbBCwsZo1bFq4h8kO9u0hyZj5YdKr4wY0bPWlWviio)V4oYxZ8aH5Mg7tnH4TNqyhd3CMxCxEQnshKOmNT10DA5PgK3XkmNEn30ijpWZisXBWomBWRGEi1FboHu3lvV6oWRh7GQ69OElhkp1VHNgS1FO6zBO8uV6oWR317v)O67K1ZzNlO9u0hyZj5YdKr4wY0bPWlWvii(IdNdO1GC()qM0HCnV9eIKy4MZmY5)dzshY1gjXWnNz5PgWclsIHBoZPdi5srdhzAWaJKy4MZmNT1WrWOiJtUoWZ2Pyy(zP1WrWOiJtUoWZ2PGpi8dESWc7Ked3CMthqYLIgoY0GbgjXWnNzoBRSwsmCZzg58)HmPd5AJKy4MZ8gEAaFqSCOqj2GhuxsmCZzMrFN0CttGtgcqkJZC2SWYSHHhgeP4nyh2cWd(wz4MZ8owH50R5Mgj5bEgrkEdw(GAf0dPE(lcnUE0XbdxpUEeNMQ)M1h4Ckm9Sjz9kEGV1Zq6tn)r9qzlv)8q1ZFcgyFY6tOokO9u0hyZj5YdKr4wY0bPWlWviikJL(Acx3RIdkOhs9qfnDoDu)01AgpnO(5HQNBDgnvFhKYYFupu2s1RUd86XgRWC6T(BwpurEGNlO9u0hyZj5YdKr4wY0bPS82timCZzEhRWC61CtJK8apZzZclZggEyqKI3GDylHxbDb9qQN9I)juhu9w0Slbs0wq7POpWMPDjqIwEGms6ajceipiPzQDfI3EcHaec24C0kKjoJIZ(8XMv2XWnN5DScZPxZnnsYd8mNTvwZo5f50bseiqEqsZu7kKHHdbYrNg0aywzNNI(a50bseiqEqsZu7kuUbMPUHHhSWYKtRnikH7iyKjAfAyyjzwXzF4xq7POpWMPDjqIwEGmcJ(oP5MMaNmeGugZBpHWU0DA5PgKxCxEQnmAxsBMZ2A6oT8udY7yfMtVMBAKKh4zoBwyz2WWddIu8gSddHn4vq7POpWMPDjqIwEGmcmohjBhyUPX5FcDbEbTNI(aBM2LajA5bYiZlXTK048pH6GmmKRWBpHW61M0At4iyuS5fNd1diGzJdPWhelzHfK3sdbhbISlLBUb8XQWd(wzx6oT8udY7yfMtVMBAKKh4zoBRSJHBoZ7yfMtVMBAKKh4zoBReGqWgNL0StDWhe(bVcApf9b2mTlbs0YdKrS5q9CCdGzy0(g82tiRnP1MWrWOyZlohQhqaZghsHpiwYcliVLgcocezxk3Cd4JvHxbTNI(aBM2LajA5bYiboz4amhhqAMhkr82timCZzgrPbAAxZ8qjkZzZclmCZzgrPbAAxZ8qjYKooqqO8gEAWWSbVcApf9b2mTlbs0YdKrqTTTMmnWS2EIkO9u0hyZ0Ueirlpqgr9H0s4Ogyq0EahKiE7jK0DA5PgK3XkmNEn30ijpWZisXBWo8qzHLzddpmisXBWomBqTcApf9b2mTlbs0YdKruiLdn2CtJMl1sJerUYYBpHqacbB8WwaEwz4MZ8owH50R5Mgj5bEMZUGEi1Br)0Y6zpKB3ay1Zk1UcT1ppu9e7tjUGQh5ayu9hQ(bTwxpd3CU8wFpR3(2Tz0uUE2lTAF8wFGgxFC1dJI6dCQE9PM2O(0DA5PgupJVKS(duVdN3ANrt1tasPPnxq7POpWMPDjqIwEGmcIC7gaZm1UcT82tiZggEyqKI3GDy2YdLfwynRdhbJImo56apBNc(GAWJfwchbJImo56apBNIHHyj8GVvw7POHJmeGuAAHWglSmBy4HbrkEdw(Seka(WNfwyD4iyuKJwHmXzStHXs4Xh)GNvw7POHJmeGuAAHWglSmBy4HbrkEdw(SGfGp8lOlOhs9yb56aVEl(oT8ud2cApf9b28gKRdCtsU8aze4Cu7mAIxGRqqwCPjWr0IFAjVW5Aocs6oT8udYlUlp1gPdsuoH7iy0AMipf9bCnFqylBrgkVw0jTnHQN)YrTZOPc6Hup)Ld6fV(EwVAQEhr1NCB7gaR(dupu5GevFc3rWOnxVfnospUEgAEiQ(zJ2OEPdsu99SE1u94oCu9GREvBy4XgUEaHQNHlQhQC0G6XWD5PU(gu)HKeQ(4Qhgf1ZE4SdoevpND9SgC1ZF7BqO6zV213TbWpxq7POpWM3GCDGBsYLhiJaNd6fN3EcH1Sdoh1oJMYlU0e4iAXpTKfwyx4Acezqddp2W1diuMaoJMKwdxtGilD0aZI7YtDMaoJMKW3A6uyoJ91GyZsA2Po4JnRSdXbO5HGrzfhnWCttGtgfFdcz8D9DBqMGICTTnjlO9u0hyZBqUoWnj5YdKrwYE7TG2trFGnVb56a3KKlpqgX(oTbr7XHseVZdzae7hqyJxI9dKBCLJdeqSa84LvCNU(5HQhd3LNAfslRNN6XWD5PEdupGQNdOPDRxnvVJO6DMJlQpU6tUD9hOEOYbjQ(eUJGrBUE2Ba946vJtG6zLnqwpui5da0U13B9oZXf1hx9ioq9hxKlO9u0hyZBqUoWnj5YdKrwCxEQviTK3EcHaec2y(Gyb4zLaec24SKMDQd(GWg8SYo4Cu7mAkV4stGJOf)0sRPtH5m2xdInlPzN6Gp2SkjgU5mpBG0OM8baA3mIu8gSdZwbTNI(aBEdY1bUjjxEGmcCoQDgnXlWviilU0KofMZyFniwEHZ1CeK0PWCg7RbXML0StDWhelWRfZkQhrqrUgrkei4pQhQCqIQ3J61N66Tywr9mJRxstNth5c6HuVfZkQhrqrUgrkei4pQhQCqIQ)a6X1ZqZdr1pBqV4eARVN1RMQh3HJQ3g1hQJX1JUWJ(a5cApf9b28gKRdCtsU8aze4Cu7mAIxGRqqwCPjDkmNX(AqS8cNR5iiPtH5m2xdInlPzN6yyiSXBpHaNJANrtzULm2O(qDm2GUWJ(af0dPEOYbjQEjhQbWQhBScZP36pu9oZbhvFGJOf)0YCbTNI(aBEdY1bUjjxEGmYI7YtTr6GeXBpHaNJANrt5fxAsNcZzSVgeRvwdNJANrt5fxAcCeT4NwYclmCZzEhRWC61CtJK8apJifVblFqylBjlSS2KwBchbJInV4COEabmBCif(GybRP70YtniVJvyo9AUPrsEGNrKI3GLp2Gh8lOhs9JYHa1JifVbnaw9qLds0wpdnpevFGt1pBy4r9eqU13Z6XoOQE1hakFupdvpIC546Bq9rRq5cApf9b28gKRdCtsU8azKf3LNAJ0bjI3Ecboh1oJMYlU0KofMZyFniwRZggEyqKI3GD40DA5PgK3XkmNEn30ijpWZisXBWwqxqpK6XcY1bojRN9CHh9bkOhs98NZ6XcY1b(iW5GEXR3ru9C28wp3s1JH7Yt9gOEavFC1ZqaA2r9t0PuFGt1B772Wr1ZCaUTEhiRNv2az9qHKpaq7wpbhbQVN1RMQ3ru9EuVIZ(1BXSI6z9eDk1h4u92ikDkmEup)9eQGFUG2trFGnVb56aNK8azKf3LN6nq9aI3EcH1mCZzEdY1bEMZMfwy4MZmCoOx8mNn8lOhs9SYg0lE9Eup)4PElMvuV6oWpUOEOcR(rQ3c8uV6oWRhQWQxDh41JHZH6beOEvoeWLx9mCZz9C21hx9oCxlRFpfQElMvuVAFdQ(Tdop6dS5cApf9b28gKRdCsYdKrsUwB8u0hWO7n4f4keKzd6fN3EcHHBoZlohQhqatCiGlVmNT10PWCg7RbXML0StDmmellOhs9Sx69QF9jvFC1pBqV417r9wGN6Tywr9Q7aVEI99uOhxVfQpCemk2C9SgZvO69T(Jl2ws1Vb56apd)cApf9b28gKRdCsYdKrsUwB8u0hWO7n4f4keKzd6fN3EczTjT2eocgfBEX5q9acy24qkqSG10PWCg7RbXYheluqpK6zLnOx869OElWt9wmROE1DGFCr9qfgV1puEQxDh41dvy8wVdK1ZQ1RUd86HkS69zqO65VCqV4f0Ek6dS5nixh4KKhiJKCT24POpGr3BWlWviiZg0loV9es6uyoJ91GyZsA2PoggcBqjwhUMarwsKnHmBG8WHrkzc4mAsALHBoZW5GEXZC2WVG2trFGnVb56aNK8azKfVHJ3EcjCnbImOHHhB46bektaNrtsRioanpemkhnySjo2VtggTlPmbf5ABBswqpK6zLhQEBebLS9iHZB9diYUEwzdK1dfs(aaTB9C21FG6dCQEBuR4OX1hocgf1l5O6JREWvpgUlp11ZF5C6OG2trFGnVb56aNK8azKf3LN6nq9aI3EcrtWr6HhQLwLed3CMNnqAut(aaTBgrkEd2HzZA4iyuKJwHmXzKnbLqKI3GLpwTGEi1dLzxFC1ZV6dhbJIT(bezxpND9SYgiRhkK8baA36zgxFACs3ay1JH7Yt9gOEaLlO9u0hyZBqUoWjjpqgzXD5PEdupG4nnoPjt4iyuSqyJ3EcrsmCZzE2aPrn5da0UzeP4nyhMnRRnP1MWrWOyZlohQhqaZghszyi8ZA4iyuKJwHmXzKnbLqKI3GLpwTGEi1df2b(Xf1dveztO6XcKhomsPEhiRNF1ZECWGT(Bw)OAxs13G6dCQEmCxEQ367O(ERx9Hc8652gaREmCxEQ3a1dO6pq98R(WrWOyZf0Ek6dS5nixh4KKhiJS4U8uVbQhq82tiSlCnbISKiBcz2a5HdJuYeWz0K0QZ)eQdkZODjzAGjWjZI7Yt9Mroyae(zDTjT2eocgfBEX5q9acy24qkq4xb9qQNvEO6Tr9H6yC9Ol8OpaV1ZTu9y4U8uVbQhq1FWrO6XIdPupBWVE1DGxpui)D9omVbBupND9XvVfQpCemkwER3s4xFpRNvcfwFV1J4aGgaR(BoRN1hOEhmUEx54ar93S(WrWOyHpV1FO65h8RpU6vC2VvA(NQh7GQ6j2piW2hOE1DGxp)jGGRdNP1DmU(dup)QpCemk26zTfQxDh41pAhyWpxq7POpWM3GCDGtsEGmYI7Yt9gOEaXBpHaNJANrtzULm2O(qDm2GUWJ(awzTKy4MZ8SbsJAYhaODZisXBWomBSWs4Acez1KBFafFdcLjGZOjP11M0At4iyuS5fNd1diGzJdPmmelWclo)tOoOCdi46WzADhJZeWz0K0kd3CM3XkmNEn30ijpWZC2wxBsRnHJGrXMxCoupGaMnoKYWq4hpo)tOoOmJ2LKPbMaNmlUlp1BMaoJMKWVG2trFGnVb56aNK8azKfNd1diGzJdPWBpHS2KwBchbJILpi8JhwZWnNzBePqYo8OpqMZMfwy4MZCGtg0fbbYC2SWcIdqZdbJY(a3r9A2JtBMihMcbImbf5ABBsAnDajxhzjr2eYiDyWi0MroyaFqSiWVG2trFGnVb56aNK8azKf3LN6nq9aI3EcrsmCZzE2aPrn5da0UzeP4nyhgcBSWs6oT8udY7yfMtVMBAKKh4zeP4nyhMnOMvjXWnN5zdKg1Kpaq7MrKI3GD40DA5PgK3XkmNEn30ijpWZisXBWwqpK6XWD5PEdupGQpU6r0erlE9SYgiRhkK8baA36DGS(4QNalhIQxnvFYb1NCeAC9hCeQEV(jNwxpRekS(gex9bovpGy)OESdQQVN1BF72mAkxq7POpWM3GCDGtsEGmI9DAdI2JdLiENhYai2pGWwbTNI(aBEdY1boj5bYiW03PWODjXBpHWoehGMhcgL9bUJ61ShN2mromfcezckY122K0kd3CMTj08qEqsdCud28gEAaFq4N10bKCDKTj08qEqsdCud2mYbd4dcB8dkXAOaOE6asUoYsISjKr6WGrOmbCgnj5jDajxhzjr2eYiDyWiug5GbWVG2trFGnVb56aNK8azey67uy0UK4TNqqCaAEiyu2h4oQxZECAZe5WuiqKjOixBBtsRmCZz2MqZd5bjnWrnyZB4Pb8bHFwzD6asUoY2eAEipiPboQbBg5Gb8KoGKRJSKiBczKomyekJCWa4Zhe2y1cApf9b28gKRdCsYdKrwCxEQ3a1dOc6c6HupRSb9ItOTG2trFGnpBqV48azKv3jY4aPr2jI3EczTjT2eocgfBEX5q9acy24qkdZQwzhd3CMxCxEQnshKOmNTvgU5mV6orghinYorzeP4nyhE2WWddIu8gSwz4MZ8Q7ezCG0i7eLrKI3GDywZgpPtH5m2xdIf(qD2YqTcApf9b28Sb9IZdKrGZrTZOjEbUcbzh02geNDWHiEHZ1CeefFdcz8D9DBGbrkEdw(GhlSWUW1eiYGggESHRhqOmbCgnjTgUMarw6ObMf3LN6mbCgnjTYWnN5f3LNAJ0bjkZzZclRnP1MWrWOyZlohQhqaZghsHpiSkVw0jTnHQN)YrTZOP6NhQE2dNDWHOC9ydA76LCOgaRE(BFdcvp71U(UnO(dvVKd1ay1dvoir1RUd86HkhnOEhiRhC1RAddp2W1diuUGEi1dLBISRNZUE2dNDWHO67z9DuFV17mhxuFC1J4a1FCrUG2trFGnpBqV48azeeNDWHiE7je2bNJANrt5DqBBqC2bhISgocgf5OvitCgztqjeP4ny5JvTIOjIwCNrtf0Ek6dS5zd6fNhiJSucrHjOeoOHICub9qQN)MthT8IObWQpCemk26dCpQxDR11RB4O6NhQ(aNQxYH8Opq93SE2dNDWHO6r0erlE9soudGvVTdKKsNYf0Ek6dS5zd6fNhiJG4SdoeXBACstMWrWOyHWgV9ec7GZrTZOP8oOTnio7GdrwzhCoQDgnL5wYyJ6d1Xyd6cp6dyDTjT2eocgfBEX5q9acy24qk8bXsRHJGrroAfYeNr2eFqy9q5H1wc1tNcZzSVgel8HVvenr0I7mAQGEi1ZEOjIw86zpC2bhIQNCKEC99S(oQxDR11tSVDJO6LCOgaRESXkmNEZ1dvx9bUh1JOjIw867z9yhuvpmk26rKlhxFdQpWP6be7h1p0nxq7POpWMNnOxCEGmcIZo4qeV9ec7GZrTZOP8oOTnio7GdrwrKI3GD40DA5PgK3XkmNEn30ijpWZisXBWYdBWZA6oT8udY7yfMtVMBAKKh4zeP4nyhgYqTgocgf5OvitCgztqjeP4ny5lDNwEQb5DScZPxZnnsYd8mIu8gS8m0cApf9b28Sb9IZdKry0EAGX(uljeV9ec7GZrTZOPm3sgBuFOogBqx4rFaRRnP1MWrWOy5dc)kO9u0hyZZg0lopqgHGR3eH8GkOlOhs9JY1AjH2cApf9b2mdxRLqw8goE7je2fUMarg0WWJnC9acLjGZOjPvehGMhcgLJgm2eh73jdJ2LuMGICTTnjlO9u0hyZmCTwYdKrwCoupGaMnoKcV9eYAtATjCemkw(GyjpSoCnbImm9DkmAxszc4mAsA15Fc1bLTj08qEqzKdgWhelTAFBh9bmmEAa8lO9u0hyZmCTwYdKrwcH8GKgMdqM1Uhq82tiP70YtniVec5bjnmhGmRDpGYjChbJwZe5POpGR5dILzlYqlO9u0hyZmCTwYdKrGPVtHr7sQG2trFGnZW1AjpqgHXtd2WzeHieca]] )


end
