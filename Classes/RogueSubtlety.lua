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


    spec:RegisterPack( "Subtlety", 20201020, [[dav51bqiuQ8iQQYMOQ8jqvsnkusDkuswfOk1RqvmluLULIISlr9lfudtrPJHszzkipdvvMgvv6AuvvBduv9nQQqJtrrDoQQG1HQQW8uiDpfzFOQ8pqvsYbrPkzHkepKQkAIGQ4IkkqSrqvPpcQsIrQOa1jrvv0kvu9sqvsQzIsvQUjQQsTtss)eLQugkOQyPOufpfIPssCvqvITIQQKVQOGoRIcK2lH)sLbRQdtzXO4XImzIUmYMb5ZGYOH0PLA1kkGxRaZMu3Me7g43QmCQYXvuOLd1ZvA6cxhv2oOY3jPgpkv15vOwpQQQ5JsSFjlytOIarAbjuDOzhAw2MDOzZS5h43m7F4xGeJ9ibINLgyWibcWuibcchtOPySaXZgRptkurGShhorce0i8w(JHhgwhOCm50Pm82kCAl6dKWgum82kPHfimCTo4pbcgbI0csO6qZo0SSn7qZMzZpWVz2)djqmUa9WceKwXpfiOTusabJarsBsG4V6r4ycnfJRN9CW4OAU)QN9wkogcx)qZYB9dn7qZkq09gRqfbYgKPduskurOkBcveieWy0KumIajH7GWTjqyD9mCqq5nithOzoV6zHL6z4GGYWzGErZCE1ZkbILI(acKf1KN6nW9asecvhsOIaHagJMKIreijCheUnbcdheuEr5W9ac4Iddm5L58Q3x9PtH5CExdInljOo1r9Jov)qcelf9beijtRDwk6d409gceDVHdykKabQb9IkcHQ8tOIaHagJMKIreijCheUnbY6rATlmmmk28IYH7beWTXHvQFQE)wVV6tNcZ58UgeB98nvVFfiwk6diqsMw7Su0hWP7nei6EdhWuibcud6fvecv9RqfbcbmgnjfJiqs4oiCBcK0PWCoVRbXMLeuN6O(rNQNT6NP6zD9HPjqKLe5ry3gylmyKsMagJMK17REgoiOmCgOx0mNx9SsGyPOpGajzATZsrFaNU3qGO7nCatHeiqnOxuriu1)cveieWy0KumIajH7GWTjqcttGidAyOXgMEaHZeWy0KSEF1J5ae0HHr5ObJDXX(DYXOnjLPzKR98iPaXsrFabYI2WjcHQWVqfbcbmgnjfJiqs4oiCBcenbhPRF069)q17REjXWbbLHAG0PMSbaA3mMuSgS1pA9SvVV6dddJIC0kKloNSP6NP6XKI1GTE(Qh(fiwk6diqwutEQ3a3diriu1pkurGqaJrtsXicelf9beilQjp1BG7bKajH7GWTjqKedheugQbsNAYgaODZysXAWw)O1Zw9(QF9iT2fgggfBEr5W9ac424Wk1p6u98REF1hgggf5OvixCozt1pt1JjfRbB98vp8lqsJtAYfgggfRqv2eHq1zwOIaHagJMKIreijCheUnbc7QpmnbISKipc72aBHbJuYeWy0KSEF1B8pH7GYmAtsUg4cuYTOM8uVzSbgu)u98REF1VEKw7cddJInVOC4EabCBCyL6NQNFcelf9beilQjp1BG7bKieQ6heQiqiGXOjPyebsc3bHBtGaNHBJrtzULCE4(WDm2HVWI(a17REwxVKy4GGYqnq6ut2aaTBgtkwd26hTE2QNfwQpmnbISAY8oGITbHZeWy0KSEF1VEKw7cddJInVOC4EabCBCyL6hDQE)wplSuVX)eUdk3acUomMw3X4mbmgnjR3x9mCqq5DScZPx3b5KKfOzoV69v)6rATlmmmk28IYH7beWTXHvQF0P65x98uVX)eUdkZOnj5AGlqj3IAYt9MjGXOjz9SsGyPOpGazrn5PEdCpGeHqv2MvOIaHagJMKIreijCheUnbY6rATlmmmk265BQE(vpp1Z66z4GGYEysHKDyrFGmNx9SWs9mCqq5aLC4lccK58QNfwQhZbiOddJY2aZW962Jt7GWgmfcezAg5AppswVV6thqY1rwsKhHDsdgmcVzSbgupFt17hRNvcelf9beilkhUhqa3ghwrecvzJnHkcecymAskgrGKWDq42eisIHdckd1aPtnzda0UzmPynyRF0P6zREwyP(0DA5PgK3XkmNEDhKtswGMXKI1GT(rRNTzUEF1ljgoiOmudKo1Knaq7MXKI1GT(rRpDNwEQb5DScZPx3b5KKfOzmPynyfiwk6diqwutEQ3a3diriuLTHeQiqiGXOjPyebc0HDaI9dHQSjqSu0hqG4DN2HP94WjsecvzJFcveieWy0KumIajH7GWTjqyx9yoabDyyu2gygUx3ECAhe2GPqGitZix75rY69vpdheu2JWqh2cs6GJAWM3WsdQNVP65x9(QpDajxhzpcdDyliPdoQbBgBGb1Z3u9SXV6NP6zD9(H6H31NoGKRJSKipc7KgmyeotaJrtY65P(0bKCDKLe5ryN0GbJWzSbgupReiwk6diqGPVtHrBssecvzZVcveieWy0KumIajH7GWTjqWCac6WWOSnWmCVU940oiSbtHarMMrU2ZJK17REgoiOShHHoSfK0bh1GnVHLgupFt1ZV69vpRRpDajxhzpcdDyliPdoQbBgBGb1Zt9Pdi56iljYJWoPbdgHZydmOEwvpFt1Zg8lqSu0hqGatFNcJ2KKieQYM)fQiqSu0hqGSOM8uVbUhqcecymAskgreIqGq7sGeTcveQYMqfbcbmgnjfJiqs4oiCBcecqyyJZrRqU4Ckg7xpF1Zw9(QND1ZWbbL3XkmNEDhKtswGM58Q3x9SUE2vV8IC6ajceyliPdsBkKJHddYrNg0ay17RE2vVLI(a50bseiWwqshK2uOCdCq6ggAuplSupeNw7Wuc1WWix0ku9JwpSKmRySF9SsGyPOpGajDGebcSfK0bPnfsecvhsOIaHagJMKIreijCheUnbc7QpDNwEQb5f1KNAhJ2K0M58Q3x9P70YtniVJvyo96oiNKSanZ5vplSupuddnCysXAWw)Ot1Z2Scelf9beim67KUdYfOKJaKYyriuLFcveiwk6diqGXzyzBa3b5m(NWxGkqiGXOjPyeriu1VcveieWy0KumIajH7GWTjqyD9RhP1UWWWOyZlkhUhqa3ghwPE(MQFO6zHL6XwlDeCeiYMuU5gupF1d)ZwpRQ3x9SR(0DA5PgK3XkmNEDhKtswGM58Q3x9SREgoiO8owH50R7GCsYc0mNx9(QNaeg24SKG6uh1Z3u98BwbILI(aceOlXTK0z8pH7GCmKPicHQ(xOIaHagJMKIreijCheUnbY6rATlmmmk28IYH7beWTXHvQNVP6hQEwyPES1shbhbISjLBUb1Zx9W)Scelf9beiEC4gACdG5y02gIqOk8lurGqaJrtsXicKeUdc3MaHHdckJP0anTRd6WjkZ5vplSupdheugtPbAAxh0HtKlDCGGW5nS0G6hTE2MvGyPOpGajqjhhG54ash0HtKieQ6hfQiqSu0hqGGBppn5AGB9SejqiGXOjPyeriuDMfQiqiGXOjPyebsc3bHBtGKUtlp1G8owH50R7GCsYc0mMuSgS1pA9(VEwyPEOggA4WKI1GT(rRNTzwGyPOpGar9H1s4Og4W0EadKiriu1piurGqaJrtsXicKeUdc3MaHaeg246hTE)oB9(QNHdckVJvyo96oiNKSanZ5jqSu0hqGOqkhES7GCAUulDsmzkRieQY2ScveieWy0KumIajH7GWTjqGAyOHdtkwd26hTE2Y(VEwyPEwxpRRpmmmkYOKPd0SxkQNV6N5zRNfwQpmmmkYOKPd0SxkQF0P6hA26zv9(QN11BPOHJCeGuAARFQE2QNfwQhQHHgomPynyRNV6hYpupRQNv1Zcl1Z66dddJIC0kKloNxkCdnB98vp)MTEF1Z66Tu0WrocqknT1pvpB1Zcl1d1WqdhMuSgS1Zx9(1V1ZQ6zLaXsrFabcMmVgaZbPnfAfHieiscY40HqfHQSjurGyPOpGazqNgiqiGXOjPyeriuDiHkcecymAskgrGCEcKLcbILI(ace4mCBmAsGaNP5ibcdheuE1DICgq6KDIYCE1Zcl1VEKw7cddJInVOC4EabCBCyL65BQE4xGaNHDatHeilq6shq2rFariuLFcveieWy0KumIaXsrFabsY0ANLI(aoDVHar3B4aMcjqsYvecv9RqfbcbmgnjfJiqs4oiCBcKnithOKmBATaXsrFabcMd4Su0hWP7nei6EdhWuibYgKPduskcHQ(xOIaHagJMKIreijCheUnbY6rATlmmmk28IYH7beWTXHvQF06H)69vpuddnCysXAWwpF1d)17REgoiO8Q7e5mG0j7eLXKI1GT(rRhwsMvm2VEF1NofMZ5Dni265BQE)w)mvpRRpAfQ(rRNTzRNv1dVRFibILI(acKv3jYzaPt2jsecvHFHkcecymAskgrGCEcKLcbILI(ace4mCBmAsGaNP5ibIhUpChJD4lSOpq9(QF9iT2fgggfBEr5W9ac424Wk1Z3u9djqGZWoGPqceULCE4(WDm2HVWI(aIqOQFuOIaHagJMKIreijCheUnbcCgUngnL5wY5H7d3Xyh(cl6diqSu0hqGKmT2zPOpGt3Biq09goGPqcKnithOUKCfHq1zwOIaHagJMKIreiNNazPqGyPOpGabod3gJMeiWzAosGmK)RNN6dttGidxd7WzcymAswp8U(HMTEEQpmnbISITbHDhKBrn5PEZeWy0KSE4D9dnB98uFyAce5f1KNAh0L42mbmgnjRhEx)q(VEEQpmnbISPTeUJXzcymAswp8U(HMTEEQFi)xp8UEwx)6rATlmmmk28IYH7beWTXHvQNVP69B9SsGaNHDatHeiBqMoqDbkMw0tlfHqv)GqfbcbmgnjfJiqs4oiCBcecqyyJZscQtDu)Ot1dNHBJrt5nithOUaftl6PLcelf9beijtRDwk6d409gceDVHdykKazdY0bQljxriuLTzfQiqiGXOjPyebsc3bHBtGy8pH7GYGggASo4iamYajktaJrtY69vp7QNHdckdAyOX6GJaWidKOmNx9(QpDkmNZ7AqSzjb1PoQNV6zREF1Z66xpsRDHHHrXMxuoCpGaUnoSs9Jw)q1Zcl1dNHBJrtzULCE4(WDm2HVWI(a1ZQ69vpRRpDNwEQb5DScZPx3b5KKfOzmPynyRF0P65x9SWs9SUEJ)jChug0WqJ1bhbGrgirzSbgupFt1pu9(QNHdckVJvyo96oiNKSanJjfRbB98vp)Q3x9SR(nithOKmBAD9(QpDNwEQb5f1KNAN0ajkNqnmmADqylf9bmD98nv)Sz)q9SQEwjqSu0hqGG58comjcHQSXMqfbcbmgnjfJiqs4oiCBcemhGGommkljlq1JDlQjp1BMMrU2ZJK17RE5f5L82EZrNg0ay17RE5f5L82EZysXAWw)Ot1pu9(QpDkmNZ7AqS1Z3u9djqSu0hqGKmT2zPOpGt3Biq09goGPqceOg0lQieQY2qcveieWy0KumIajH7GWTjqsNcZ58UgeB9t1BGwXsOgggjDjpbILI(acKKP1olf9bC6EdbIU3WbmfsGa1GErfHqv24NqfbcbmgnjfJiqs4oiCBcK0PWCoVRbXMLeuN6O(rNQNT6zHL6HAyOHdtkwd26hDQE2Q3x9PtH5CExdITE(MQNFcelf9beijtRDwk6d409gceDVHdykKabQb9IkcHQS5xHkcecymAskgrGKWDq42eiRhP1UWWWOyZlkhUhqa3ghwP(P69B9(QpDkmNZ7AqS1Z3u9(vGyPOpGajzATZsrFaNU3qGO7nCatHeiqnOxuriuLn)lurGqaJrtsXicKeUdc3MaHaeg24SKG6uh1p6u9Wz42y0uEdY0bQlqX0IEAPaXsrFabsY0ANLI(aoDVHar3B4aMcjqy4ATuecvzd(fQiqiGXOjPyebsc3bHBtGqacdBCwsqDQJ65BQE28F98upbimSXzmbJacelf9beigozaYfhgtGqecvzZpkurGyPOpGaXWjdqopo9scecymAskgrecvzBMfQiqSu0hqGOByOX6Mb4KWuiqiqiGXOjPyeriuLn)GqfbILI(acegdM7GCbUtdwbcbmgnjfJicriq8Wu6uySqOIqv2eQiqSu0hqGyEE6XoVR3diqiGXOjPyeriuDiHkcelf9beiBqMoqfieWy0KumIieQYpHkcecymAskgrGyPOpGarXWdiPd6WojzbQaXdtPtHXc3sPdixbcB(xecv9RqfbcbmgnjfJiqSu0hqGS6orodiDYorcKeUdc3MabtqyArngnjq8Wu6uySWTu6aYvGWMieQ6FHkcecymAskgrGKWDq42eiyoabDyyuwXWdChKlqjNITbHD2U2UnitZix75rsbILI(acKf1KNAhJ2K0kcHQWVqfbcbmgnjfJiqaMcjqm(FrnSToOdeUdY5DQjSaXsrFabIX)lQHT1bDGWDqoVtnHfHieiqnOxuHkcvztOIaHagJMKIreijCheUnbY6rATlmmmk28IYH7beWTXHvQF06H)69vp7QNHdckVOM8u7KgirzoV69vpdheuE1DICgq6KDIYysXAWw)O1d1WqdhMuSgS17REgoiO8Q7e5mG0j7eLXKI1GT(rRN11Zw98uF6uyoN31GyRNv1dVRNT8mlqSu0hqGS6orodiDYorIqO6qcveieWy0KumIa58eilfcelf9beiWz42y0KabotZrcefBdc7SDTDBGdtkwd265R(zRNfwQND1hMMarg0WqJnm9acNjGXOjz9(QpmnbIS0WdClQjp1zcymAswVV6z4GGYlQjp1oPbsuMZREwyP(1J0AxyyyuS5fLd3diGBJdRupFt1d)ce4mSdykKazh0EomNxWHjriuLFcveieWy0KumIajH7GWTjqyx9Wz42y0uEh0EomNxWHP69vFyyyuKJwHCX5Knv)mvpMuSgS1Zx9WF9(QhtqyArngnjqSu0hqGG58comjcHQ(vOIaXsrFabYsjmfUGsOGEg5ibcbmgnjfJicHQ(xOIaHagJMKIreiwk6diqWCEbhMeijCheUnbc7Qhod3gJMY7G2ZH58comvVV6zx9Wz42y0uMBjNhUpChJD4lSOpq9(QF9iT2fgggfBEr5W9ac424Wk1Z3u9dvVV6dddJIC0kKloNSP65BQEwxV)RNN6zD9dvp8U(0PWCoVRbXwpRQNv17REmbHPf1y0KajnoPjxyyyuScvztecvHFHkcecymAskgrGKWDq42eiSRE4mCBmAkVdAphMZl4Wu9(Qhtkwd26hT(0DA5PgK3XkmNEDhKtswGMXKI1GTEEQNTzR3x9P70YtniVJvyo96oiNKSanJjfRbB9JovV)R3x9HHHrroAfYfNt2u9Zu9ysXAWwpF1NUtlp1G8owH50R7GCsYc0mMuSgS1Zt9(xGyPOpGabZ5fCysecv9JcveieWy0KumIajH7GWTjqyx9Wz42y0uMBjNhUpChJD4lSOpq9(QF9iT2fgggfB98nvp)eiwk6diqy0wAGZ7uljSieQoZcveiwk6diqi46nrylibcbmgnjfJicriqsYvOIqv2eQiqiGXOjPyebsc3bHBtGWU6z4GGYlQjp1oPbsuMZREF1ZWbbLxuoCpGaU4WatEzoV69vpdheuEr5W9ac4Iddm5LXKI1GT(rNQNFz)lqSu0hqGSOM8u7KgirceULCheKdwskuLnriuDiHkcecymAskgrGKWDq42eimCqq5fLd3diGlomWKxMZREF1ZWbbLxuoCpGaU4WatEzmPynyRF0P65x2)celf9bei7yfMtVUdYjjlqfiCl5oiihSKuOkBIqOk)eQiqiGXOjPyebsc3bHBtGaNHBJrt5fiDPdi7Opq9(QND1Vbz6aLKzfdeAsGyPOpGabsBWiT2I(aIqOQFfQiqiGXOjPyebsc3bHBtGijgoiOmK2GrATf9bYysXAWw)O1pu9SWs9sIHdckdPnyKwBrFG8gwAq98nvVFNvGyPOpGabsBWiT2I(aUKMmWsIqOQ)fQiqiGXOjPyebsc3bHBtGW66XCac6WWOSIHh4oixGsofBdc7SDTDBqMMrU2ZJK17R(0PWCoVRbXMLeuN6O(rNQNF1Zcl1J5ae0HHrzjzbQESBrn5PEZ0mY1EEKSEF1NofMZ5Dni26hTE2QNv17REgoiO8owH50R7GCsYc0mNx9(QNHdckVOM8u7KgirzoV69vVITbHD2U2UnWHjfRbB9t1pB9(QNHdckljlq1JDlQjp1BwEQbcelf9beiWzGErfHqv4xOIaHagJMKIreijCheUnbc7QFdY0bkjZMwxVV6HZWTXOP8cKU0bKD0hOEwyPEAxcKOmdMSa1DqUaLCYXnawwXMboC9(QpAfQE(MQFibILI(acKKP1olf9bC6EdbIU3WbmfsGq7sGeTIqOQFuOIaHagJMKIreiwk6diq8Ut7W0EC4ejqs4oiCBce2vFyAce5f1KNAh0L42mbmgnjfiqh2bi2peQYMieQoZcveieWy0KumIajH7GWTjqiaHHnUE(MQh(NTEF1dNHBJrt5fiDPdi7Opq9(QpDNwEQb5DScZPx3b5KKfOzoV69vF6oT8udYlQjp1oPbsuoHAyy0wpFt1ZMaXsrFabYIYH7beWfhgyYtecv9dcveieWy0KumIaXsrFabYsySfK0XCaYTE9asGKWDq42eiWz42y0uEbsx6aYo6duVV6zx9YlYlHXwqshZbi361diN8IC0Pbnaw9SWs9qnm0WHjfRbB9JovV)fiPXjn5cddJIvOkBIqOkBZkurGqaJrtsXicKeUdc3Mabod3gJMYlq6shq2rFG69vp7QpDNwEQb5f1KNAhJ2K0M58Q3x9SU(W0eiYeaosFEnaMBrn5PEZeWy0KSEwyP(0DA5PgKxutEQDsdKOCc1WWOTE(MQNT6zv9(QN11ZU6dttGiVOC4EabCXHbM8YeWy0KSEwyP(W0eiYlQjp1oOlXTzcymAswplSuF6oT8udYlkhUhqaxCyGjVmMuSgS1Zx9dvpRQ3x9SUE2vpTlbsuMrFN0DqUaLCeGugNvSzGdxplSuF6oT8udYm67KUdYfOKJaKY4mMuSgS1Zx9dvpReiwk6diq2XkmNEDhKtswGkcHQSXMqfbcbmgnjfJiqSu0hqGOy4bK0bDyNKSavGKWDq42eiyRLococeztk3mNx9(QN11hgggf5OvixCozt1pA9PtH5CExdInljOo1r9SWs9SR(nithOKmBAD9(QpDkmNZ7AqSzjb1PoQNVP6tEofJ9DRhbK1ZkbsACstUWWWOyfQYMieQY2qcveieWy0KumIajH7GWTjqWwlDeCeiYMuU5gupF1ZVzRFMQhBT0rWrGiBs5MLCyl6duVV6tNcZ58UgeBwsqDQJ65BQ(KNtXyF36raPaXsrFabIIHhqsh0HDsYcuriuLn(jurGqaJrtsXicKeUdc3Mabod3gJMYlq6shq2rFG69vF6uyoN31GyZscQtDupFt1pKaXsrFabYIAYtTJrBsAfHqv28RqfbcbmgnjfJiqs4oiCBce4mCBmAkVaPlDazh9bQ3x9PtH5CExdInljOo1r98nvp)Q3x9RhP1UWWWOyZlkhUhqa3ghwP(rNQ3Vcelf9beiuc9AamhM8WTIbKIqOkB(xOIaHagJMKIreijCheUnbsyAce5f1KNAh0L42mbmgnjR3x9Wz42y0uEbsx6aYo6duVV6z4GGY7yfMtVUdYjjlqZCEcelf9beilkhUhqaxCyGjpriuLn4xOIaHagJMKIreijCheUnbc7QNHdckVOM8u7KgirzoV69vpuddnCysXAWw)Ot1pZ1Zt9HPjqKxoMGWqCWOmbmgnjfiwk6diqwutEQDsdKiriuLn)OqfbILI(aceVl6diqiGXOjPyeriuLTzwOIaHagJMKIreijCheUnbcdheuEhRWC61DqojzbAMZtGyPOpGaHrFN0bXHhlcHQS5heQiqiGXOjPyebsc3bHBtGWWbbL3XkmNEDhKtswGM58eiwk6diqyi8s4bnaMieQo0ScveieWy0KumIajH7GWTjqy4GGY7yfMtVUdYjjlqZCEcelf9beiqnMy03jfHq1HytOIaHagJMKIreijCheUnbcdheuEhRWC61DqojzbAMZtGyPOpGaXajAdSPDjtRfHq1HgsOIaHagJMKIreiwk6diqsJt6lWhOtogTTHajH7GWTjqyx9BqMoqjz20669vpCgUngnLxG0LoGSJ(a17RE2vpdheuEhRWC61DqojzbAMZREF1tacdBCwsqDQJ65BQE(nRaHGGOu4aMcjqsJt6lWhOtogTTHieQoe)eQiqiGXOjPyebILI(aceJ)xudBRd6aH7GCENAclqs4oiCBce2vpdheuErn5P2jnqIYCE17R(0DA5PgK3XkmNEDhKtswGMXKI1GT(rRNTzfiatHeig)VOg2wh0bc3b58o1ewecvhYVcveieWy0KumIaXsrFabITOWzaADyJ)pSlDytlqs4oiCBcejXWbbLXg)Fyx6WM2jjgoiOS8udQNfwQxsmCqq50bKCPOHJCnyGtsmCqqzoV69vFyyyuKrjthOzVuu)O1ZVHQ3x9HHHrrgLmDGM9sr98nvp)MTEwyPE2vVKy4GGYPdi5srdh5AWaNKy4GGYCE17REwxVKy4GGYyJ)pSlDyt7KedheuEdlnOE(MQFi)x)mvpBZwp8UEjXWbbLz03jDhKlqjhbiLXzoV6zHL6HAyOHdtkwd26hTE)oB9SQEF1ZWbbL3XkmNEDhKtswGMXKI1GTE(QFMfiatHei2IcNbO1Hn()WU0HnTieQoK)fQiqiGXOjPyebcWuibIYyPTUW09QyabILI(aceLXsBDHP7vXaIqO6qWVqfbcbmgnjfJiqs4oiCBcegoiO8owH50R7GCsYc0mNx9SWs9qnm0WHjfRbB9Jw)qZkqSu0hqGWTKRdszfHieiBqMoqDj5kurOkBcveieWy0KumIa58eilfcelf9beiWz42y0KabotZrcK0DA5PgKxutEQDsdKOCc1WWO1bHTu0hW01Z3u9SL9J(xGaNHDatHeilQ0fOyArpTuecvhsOIaHagJMKIreijCheUnbcRRND1dNHBJrt5fv6cumTONwwplSup7QpmnbImOHHgBy6beotaJrtY69vFyAcezPHh4wutEQZeWy0KSEwvVV6tNcZ58UgeBwsqDQJ65RE2Q3x9SREmhGGommkRy4bUdYfOKtX2GWoBxB3gKPzKR98iPaXsrFabcCgOxuriuLFcveiwk6diqwYB7vGqaJrtsXiIqOQFfQiqiGXOjPyebILI(aceV70omThhorceI9dS5mLJdece)oRab6WoaX(Hqv2eHqv)lurGqaJrtsXicKeUdc3MaHaeg2465BQE)oB9(QNaeg24SKG6uh1Z3u9SnB9(QND1dNHBJrt5fv6cumTONwwVV6tNcZ58UgeBwsqDQJ65RE2Q3x9sIHdckd1aPtnzda0UzmPynyRF06ztGyPOpGazrn5PwH0sriuf(fQiqiGXOjPyebY5jqwkeiwk6diqGZWTXOjbcCMMJeiPtH5CExdInljOo1r98nvVFfiWzyhWuibYIkDPtH5CExdIvecv9JcveieWy0KumIa58eilfcelf9beiWz42y0KabotZrcK0PWCoVRbXMLeuN6O(rNQNnbsc3bHBtGaNHBJrtzULCE4(WDm2HVWI(ace4mSdykKazrLU0PWCoVRbXkcHQZSqfbcbmgnjfJiqs4oiCBce4mCBmAkVOsx6uyoN31GyR3x9SUE4mCBmAkVOsxGIPf90Y6zHL6z4GGY7yfMtVUdYjjlqZysXAWwpFt1ZwEO6zHL6xpsRDHHHrXMxuoCpGaUnoSs98nvVFR3x9P70YtniVJvyo96oiNKSanJjfRbB98vpBZwpReiwk6diqwutEQDsdKiriu1piurGqaJrtsXicKeUdc3Mabod3gJMYlQ0LofMZ5Dni269vpuddnCysXAWw)O1NUtlp1G8owH50R7GCsYc0mMuSgScelf9beilQjp1oPbsKieHaHHR1sHkcvztOIaHagJMKIreijCheUnbc7QpmnbImOHHgBy6beotaJrtY69vpMdqqhggLJgm2fh73jhJ2KuMMrU2ZJKcelf9beilAdNieQoKqfbcbmgnjfJiqs4oiCBcK1J0AxyyyuS1Z3u9dvpp1Z66dttGidtFNcJ2KuMagJMK17REJ)jChu2JWqh2ckJnWG65BQ(HQNvcelf9beilkhUhqa3ghwrecv5NqfbcbmgnjfJiqs4oiCBcK0DA5PgKxcJTGKoMdqU1Rhq5eQHHrRdcBPOpGPRNVP6hk7h9VaXsrFabYsySfK0XCaYTE9asecv9RqfbILI(acey67uy0MKeieWy0KumIieQ6FHkcelf9beimwAWggJaHagJMKIreHieHabocV9beQo0SdnlBZYg8lquByqdGTcKzi7f7rv(tvHxH)O(6vbLQVv8oCup0HRhEndxRLWRRhtZixJjz97Pq1BCXPybjRpHAay0MR5S3Bav)q8h1ZEiLdoswV3TD0hWXyPb1NqP0G6zn4I6n4SwBmAQ(gupPWPTOpaRQN1SX(SkxZR58NkEhoiz9ZC9wk6duVU3yZ1CbIh(GAnjq8x9iCmHMIX1ZEoyCun3F1ZElfhdHRFOz5T(HMDOzR51C)vp8btZKFEkmwuZTu0hyZEykDkmwWZ0WMNNESZ769a1Clf9b2ShMsNcJf8mn8gKPd0AULI(aB2dtPtHXcEMgwXWdiPd6WojzbkVEykDkmw4wkDa5oXM)R5wk6dSzpmLofgl4zA4v3jYzaPt2jIxpmLofglClLoGCNyJ3gActqyArngnvZTu0hyZEykDkmwWZ0WlQjp1ogTjPL3gAcZbiOddJYkgEG7GCbk5uSniSZ212TbzAg5AppswZTu0hyZEykDkmwWZ0WCl56Gu4fyk0KX)lQHT1bDGWDqoVtnHR51C)vp)T1G6zpxyrFGAULI(a70GonOMBPOpWYZ0WWz42y0eVatHMwG0LoGSJ(a8cNP5OjgoiO8Q7e5mG0j7eL58yHL1J0AxyyyuS5fLd3diGBJdRW3e8Zl8YsY6JREjfewPbu9QrPaLW1NUtlp1GTE1wh1dD46raWt9m2sY6pq9HHHrXMR5(RE)eLsdQ3pHNTElQhQXBuZTu0hy5zA4KP1olf9bC6EdEbMcnLKBn3F1ZE4a1dXP1JRFv3rcL26JR(aLQhjithOKSE2Zfw0hOEwZmUE51ay1VhVDup0Ht0wV3D6gaR(gQEWfOnaw99wVbN1AJrtSkxZTu0hy5zAymhWzPOpGt3BWlWuOPnithOKK3gAAdY0bkjZMwxZ9x9SxEE6X1V6orodiDYor1Br9dXt9(j8PEjhUbWQpqP6HA8g1Z2S1Vu6aYLxdkiC9bQf17xEQ3pHp13q13r9e771yARxDhOnO(aLQhqSFup8k(j8u)HRV36bxupNxn3srFGLNPHxDNiNbKozNiEBOP1J0AxyyyuS5fLd3diGBJdRmk87dQHHgomPyny5d(9XWbbLxDNiNbKozNOmMuSgSJcljZkg77lDkmNZ7AqS8n53zI1rRqJY2SScEpun3F1ZEdOhxFc1aWO6XxyrFG6BO6vt1JAWr17H7d3Xyh(cl6du)sr9gqwVcNoApnvFyyyuS1Z5LR5wk6dS8mnmCgUngnXlWuOjULCE4(WDm2HVWI(a8cNP5OjpCF4og7WxyrFaFRhP1UWWWOyZlkhUhqa3ghwHVPHQ5(RE4dUpChJRN9CHf9bGxv9S3PaE9wpSgoQER(e28Q3yoUOEcqyyJRh6W1hOu9BqMoqR3pHNTEwZW1AjHRFJwRRhtRhLI67Gv56NbLZJ3oQpzG6zO6dulQFBfpnLR5wk6dS8mnCY0ANLI(aoDVbVatHM2GmDG6sYL3gAcod3gJMYCl58W9H7ySdFHf9bQ5(RE4LLK1hx9scQbu9Qrjq9Xvp3s1Vbz6aTE)eE26pC9mCTws4TMBPOpWYZ0WWz42y0eVatHM2GmDG6cumTONwYlCMMJMgY)8eMMargUg2HZeWy0KeEp0S8eMMarwX2GWUdYTOM8uVzcymAscVhAwEcttGiVOM8u7GUe3MjGXOjj8Ei)ZtyAceztBjChJZeWy0KeEp0S8mK)H3SE9iT2fgggfBEr5W9ac424Wk8n5xwvZ9x9(5b2ws4652gaREREKGmDGwVFcp1RgLa1JjlH2ay1hOu9eGWWgxFGIPf90YAULI(alptdNmT2zPOpGt3BWlWuOPnithOUKC5THMiaHHnoljOo1XOtWz42y0uEdY0bQlqX0IEAzn3F1RAddnGxV1ZFrayKbse)r9ShoVGdt1ZqqhMQhzScZP36TOE9PUE)e(uFC1NofMgq1tgwpUEmbHPfTE1DGwpmkIgaR(aLQNHdcQEoVC9Sx69QxFQR3pHp1l5Wnaw9iJvyo9wpdfQjcup8yGeT1RUd06hIN6vL)kxZTu0hy5zAymNxWHjEBOjJ)jChug0WqJ1bhbGrgirzcymAs6JDmCqqzqddnwhCeagzGeL588LofMZ5Dni2SKG6uh8XMpwVEKw7cddJInVOC4EabCBCyLrhIfwGZWTXOPm3sopCF4og7WxyrFaw5J1P70YtniVJvyo96oiNKSanJjfRb7Ot8JfwyTX)eUdkdAyOX6GJaWidKOm2ad4BAiFmCqq5DScZPx3b5KKfOzmPyny5JF(y3gKPdusMnT2x6oT8udYlQjp1oPbsuoHAyy06GWwk6dyA(MMn7hyfRQ5wk6dS8mnCY0ANLI(aoDVbVatHMGAqVO82qtyoabDyyuwswGQh7wutEQ3mnJCTNhj9jViVK32Bo60GgaZN8I8sEBVzmPynyhDAiFPtH5CExdILVPHQ5wk6dS8mnCY0ANLI(aoDVbVatHMGAqVO82qtPtH5CExdIDYaTILqnmms6sE1C)vV)5PE1DGwp8GupRpUyBjv)gKPduwvZTu0hy5zA4KP1olf9bC6EdEbMcnb1GEr5THMsNcZ58UgeBwsqDQJrNyJfwGAyOHdtkwd2rNyZx6uyoN31Gy5BIF1C)vp8Tb9IwVf17xEQxDhOhxup8GuZ9x9ZWoqRhEqQ307vpud6fTElQ3V8uVbZAWg1tSVLc9469B9HHHrXwpRpUyBjv)gKPduwvZTu0hy5zA4KP1olf9bC6EdEbMcnb1GEr5THMwpsRDHHHrXMxuoCpGaUnoSYKF9LofMZ5Dniw(M8Bn3F1dVSu9w9mCTws46vJsG6XKLqBaS6duQEcqyyJRpqX0IEAzn3srFGLNPHtMw7Su0hWP7n4fyk0edxRL82qteGWWgNLeuN6y0j4mCBmAkVbz6a1fOyArpTSM7V6zVFQPnQ3d3hUJX13G6nTU(dQ(aLQN9c(WEVEgkzClvFh1NmUL26T6HxXpHNAULI(alptdB4KbixCymbcEBOjcqyyJZscQtDW3eB(NhcqyyJZycgbQ5wk6dS8mnSHtgGCEC6LQ5wk6dS8mnSUHHgRBgGtctHarn3srFGLNPHzmyUdYf4onyR51C)vVFENwEQbBn3F1dVSu9WJbsu9he0mbljRNHGomvFGs1d14nQFr5W9ac424Wk1dHpL6v5WatE1NofARVb5AULI(aBojxEMgErn5P2jnqI4LBj3bb5GLKtSXBdnXogoiO8IAYtTtAGeL588XWbbLxuoCpGaU4WatEzopFmCqq5fLd3diGlomWKxgtkwd2rN4x2)1C)vpRHxaAA36nnMm54658QNHsg3s1RMQpUBq9iOM8uxp89sClRQNBP6rgRWC6T(dcAMGLK1ZqqhMQpqP6HA8g1VOC4EabCBCyL6HWNs9QCyGjV6tNcT13GCn3srFGnNKlptdVJvyo96oiNKSaLxULCheKdwsoXgVn0edheuEr5W9ac4Iddm5L588XWbbLxuoCpGaU4WatEzmPynyhDIFz)xZTu0hyZj5YZ0WqAdgP1w0hG3gAcod3gJMYlq6shq2rFaFSBdY0bkjZkgi0un3srFGnNKlptddPnyKwBrFaxstgyjEBOjjXWbbLH0gmsRTOpqgtkwd2rhIfwKedheugsBWiT2I(a5nS0a(M87S1Clf9b2CsU8mnmCgOxuEBOjwJ5ae0HHrzfdpWDqUaLCk2ge2z7A72GmnJCTNhj9LofMZ5Dni2SKG6uhJoXpwybZbiOddJYsYcu9y3IAYt9MPzKR98iPV0PWCoVRbXokBSYhdheuEhRWC61DqojzbAMZZhdheuErn5P2jnqIYCE(uSniSZ212TbomPynyNM1hdheuwswGQh7wutEQ3S8udQ5wk6dS5KC5zA4KP1olf9bC6EdEbMcnr7sGeT82qtSBdY0bkjZMw7dod3gJMYlq6shq2rFawyH2LajkZGjlqDhKlqjNCCdGLvSzGd7lAfIVPHQ5(RE4ZD66HoC9QCyGjV69W0mHCWt9Q7aTEeu4PEmzYX1RgLa1dUOEmha0ay1JaFZ1Clf9b2CsU8mnS3DAhM2JdNiEHoSdqSFmXgVn0e7cttGiVOM8u7GUe3MjGXOjzn3F1dVSu9QCyGjV69Wu9ih8uVAucuVAQEudoQ(aLQNaeg246vJsbkHRhcFk17DNUbWQxDhOhxupc8T(dx)ma3g1dJae206X5AULI(aBojxEMgEr5W9ac4Iddm5XBdnracdBmFtW)S(GZWTXOP8cKU0bKD0hWx6oT8udY7yfMtVUdYjjlqZCE(s3PLNAqErn5P2jnqIYjuddJw(MyRMBPOpWMtYLNPHxcJTGKoMdqU1Rhq8MgN0Klmmmk2j24THMGZWTXOP8cKU0bKD0hWh7KxKxcJTGKoMdqU1Rhqo5f5OtdAamwybQHHgomPynyhDY)1C)vp8Ys1JmwH50B9hO(0DA5PgupRnOGW1d14nQhbapSQEoGM2TE1u9gMQh21ay1hx9ENx9QCyGjV6nGSE5vp4I6rn4O6rqn5PUE47L42Cn3srFGnNKlptdVJvyo96oiNKSaL3gAcod3gJMYlq6shq2rFaFSlDNwEQb5f1KNAhJ2K0M588X6W0eiYeaosFEnaMBrn5PEZeWy0KKfws3PLNAqErn5P2jnqIYjuddJw(MyJv(yn7cttGiVOC4EabCXHbM8YeWy0KKfwcttGiVOM8u7GUe3MjGXOjjlSKUtlp1G8IYH7beWfhgyYlJjfRblFdXkFSMD0Ueirzg9Ds3b5cuYraszCwXMbomlSKUtlp1GmJ(oP7GCbk5iaPmoJjfRblFdXQAU)QN)eQEtk36nmvpNhV1VG2JQpqP6pavV6oqRxFQPnQxfvGNC9WllvVAucuVCCdGvpKTbHRpqnq9(j8PEjb1PoQ)W1dUO(nithOKSE1DGECr9gyC9(j8jxZTu0hyZj5YZ0WkgEajDqh2jjlq5nnoPjxyyyuStSXBdnHTw6i4iqKnPCZCE(yDyyyuKJwHCX5KnnA6uyoN31GyZscQtDWclSBdY0bkjZMw7lDkmNZ7AqSzjb1Po4Bk55um23TEeqYQAU)QN)eQEWvVjLB9QBTUEzt1RUd0guFGs1di2pQNFZU8wp3s1ZFdbp1FG6zUDRxDhOhxuVbgxVFcFY1Clf9b2CsU8mnSIHhqsh0HDsYcuEBOjS1shbhbISjLBUb8XVzNjS1shbhbISjLBwYHTOpGV0PWCoVRbXMLeuN6GVPKNtXyF36razn3srFGnNKlptdVOM8u7y0MKwEBOj4mCBmAkVaPlDazh9b8LofMZ5Dni2SKG6uh8nnun3srFGnNKlptdtj0RbWCyYd3kgqYBdnbNHBJrt5fiDPdi7OpGV0PWCoVRbXMLeuN6GVj(5B9iT2fgggfBEr5W9ac424WkJo53AU)QFg2bA9iWxERVHQhCr9MgtMCC9Ydq8wp3s1RYHbM8QxDhO1JCWt9CE5AULI(aBojxEMgEr5W9ac4Iddm5XBdnfMMarErn5P2bDjUntaJrtsFWz42y0uEbsx6aYo6d4JHdckVJvyo96oiNKSanZ5vZTu0hyZj5YZ0WlQjp1oPbseVn0e7y4GGYlQjp1oPbsuMZZhuddnCysXAWo60mZtyAce5LJjimehmktaJrtYAEn3F1R6bMP1Js1Vbheu9Q7aTE9PMW17H7RMBPOpWMtYLNPH9UOpqn3srFGnNKlptdZOVt6G4WJ5THMy4GGY7yfMtVUdYjjlqZCE1Clf9b2CsU8mnmdHxcpObW4THMy4GGY7yfMtVUdYjjlqZCE1Clf9b2CsU8mnmuJjg9DsEBOjgoiO8owH50R7GCsYc0mNxn3srFGnNKlptdBGeTb20UKP182qtmCqq5DScZPx3b5KKfOzoVAEn3srFGnNKlptdZTKRdsHxccIsHdyk0uACsFb(aDYXOTn4THMy3gKPdusMnT2hCgUngnLxG0LoGSJ(a(yhdheuEhRWC61DqojzbAMZZhbimSXzjb1Po4BIFZwZTu0hyZj5YZ0WCl56Gu4fyk0KX)lQHT1bDGWDqoVtnH5THMyhdheuErn5P2jnqIYCE(s3PLNAqEhRWC61DqojzbAgtkwd2rzB2AU)Q)cucRUxQE1DGwpYbp1Br9d5FEQFdlnyR)W1ZM)5PE1DGwVP3R(r03jRNZlxZTu0hyZj5YZ0WCl56Gu4fyk0KTOWzaADyJ)pSlDytZBdnjjgoiOm24)d7sh20ojXWbbLLNAalSijgoiOC6asUu0WrUgmWjjgoiOmNNVWWWOiJsMoqZEPyu(nKVWWWOiJsMoqZEPGVj(nllSWojXWbbLthqYLIgoY1GbojXWbbL588XAjXWbbLXg)Fyx6WM2jjgoiO8gwAaFtd5)zITzH3sIHdckZOVt6oixGsocqkJZCESWcuddnCysXAWoQFNLv(y4GGY7yfMtVUdYjjlqZysXAWY3mxZ9x98xeEC94JdgQEC9yonv)bvFGYPW0qnjRxXc0TEgsFQ5pQhEzP6HoC98NGbENS(eUJAULI(aBojxEMgMBjxhKcVatHMuglT1fMUxfduZ9x9WdbzC6OEitRzS0G6HoC9CRXOP67Guw(J6HxwQE1DGwpYyfMtV1Fq1dpKfO5AULI(aBojxEMgMBjxhKYYBdnXWbbL3XkmNEDhKtswGM58yHfOggA4WKI1GD0HMTMxZ9x9Sx8pH7GQFgKDjqI2AULI(aBM2LajA5zA40bseiWwqshK2uiEBOjcqyyJZrRqU4Ckg7ZhB(yhdheuEhRWC61DqojzbAMZZhRzN8IC6ajceyliPdsBkKJHddYrNg0ay(yNLI(a50bseiWwqshK2uOCdCq6ggAWclqCATdtjuddJCrRqJcljZkg7ZQAULI(aBM2LajA5zAyg9Ds3b5cuYraszmVn0e7s3PLNAqErn5P2XOnjTzopFP70YtniVJvyo96oiNKSanZ5Xclqnm0WHjfRb7OtSnBn3srFGnt7sGeT8mnmmodlBd4oiNX)e(c0AULI(aBM2LajA5zAyOlXTK0z8pH7GCmKPWBdnX61J0AxyyyuS5fLd3diGBJdRW30qSWc2APJGJar2KYn3a(G)zzLp2LUtlp1G8owH50R7GCsYc0mNNp2XWbbL3XkmNEDhKtswGM588racdBCwsqDQd(M43S1Clf9b2mTlbs0YZ0WEC4gACdG5y02g82qtRhP1UWWWOyZlkhUhqa3ghwHVPHyHfS1shbhbISjLBUb8b)ZwZTu0hyZ0UeirlptdhOKJdWCCaPd6WjI3gAIHdckJP0anTRd6WjkZ5XclmCqqzmLgOPDDqhorU0XbccN3WsdgLTzR5wk6dSzAxcKOLNPHXTNNMCnWTEwIQ5wk6dSzAxcKOLNPHvFyTeoQbomThWajI3gAkDNwEQb5DScZPx3b5KKfOzmPynyh1)SWcuddnCysXAWokBZCn3srFGnt7sGeT8mnScPC4XUdYP5sT0jXKPS82qteGWWgpQFN1hdheuEhRWC61DqojzbAMZRM7V6NbFAz9ShY8AaS6HVAtH26HoC9e7tjUGQhBayu9hU(bTwxpdhe0YB9nu9E3UnJMY1ZEPvBJ36d846JREyuuFGs1Rp10g1NUtlp1G6zSLK1FG6n4SwBmAQEcqknT5AULI(aBM2LajA5zAymzEnaMdsBk0YBdnb1WqdhMuSgSJYw2)SWcRzDyyyuKrjthOzVuW3mpllSegggfzuY0bA2lfJon0SSYhRTu0WrocqknTtSXclqnm0WHjfRblFd5hyfRyHfwhgggf5OvixCoVu4gAw(43S(yTLIgoYrasPPDInwybQHHgomPyny5ZV(LvSQMxZ9x9ibz6aTE)8oT8ud2AULI(aBEdY0bQljxEMggod3gJM4fyk00IkDbkMw0tl5fotZrtP70YtniVOM8u7Kgir5eQHHrRdcBPOpGP5BITSF0)8odM0EeUE(ld3gJMQ5(RE(ld0lA9nu9QP6nmvFY88AaS6pq9WJbsu9juddJ2C9ZGyy946ziOdt1d14nQxAGevFdvVAQEudoQEWvVQnm0ydtpGW1ZWf1dpgEq9iOM8uxFdQ)WscxFC1dJI6zpCEbhMQNZREwdU65VTniC9Sx7A72awLR5wk6dS5nithOUKC5zAy4mqVO82qtSMDWz42y0uErLUaftl6PLSWc7cttGidAyOXgMEaHZeWy0K0xyAcezPHh4wutEQZeWy0KKv(sNcZ58UgeBwsqDQd(yZh7WCac6WWOSIHh4oixGsofBdc7SDTDBqMMrU2ZJK1Clf9b28gKPduxsU8mn8sEBV1Clf9b28gKPduxsU8mnS3DAhM2JdNiEHoSdqSFmXgVe7hyZzkhhiM87S8cFUtxp0HRhb1KNAfslRNN6rqn5PEdCpGQNdOPDRxnvVHP6nMJlQpU6tMx9hOE4XajQ(eQHHrBUE2Ba946vJsG6HVnqw)mKSbaA367TEJ54I6JREmhO(JlY1Clf9b28gKPduxsU8mn8IAYtTcPL82qteGWWgZ3KFN1hbimSXzjb1Po4BITz9Xo4mCBmAkVOsxGIPf90sFPtH5CExdInljOo1bFS5tsmCqqzOgiDQjBaG2nJjfRb7OSvZTu0hyZBqMoqDj5YZ0WWz42y0eVatHMwuPlDkmNZ7AqS8cNP5OP0PWCoVRbXMLeuN6GVj)YRFcFQhtZixJjfce8h1dpgir1Br96tD9(j8PEMX1ljiJth5AU)Q3pHp1JPzKRXKcbc(J6HhdKO6pGEC9me0HP6HAqVOeERVHQxnvpQbhvVhUpChJRhFHf9bY1Clf9b28gKPduxsU8mnmCgUngnXlWuOPfv6sNcZ58UgelVWzAoAkDkmNZ7AqSzjb1PogDInEBOj4mCBmAkZTKZd3hUJXo8fw0hOM7V6HhdKO6LC4gaREKXkmNER)W1BmhCu9bkMw0tlZ1Clf9b28gKPduxsU8mn8IAYtTtAGeXBdnbNHBJrt5fv6sNcZ58UgeRpwdNHBJrt5fv6cumTONwYclmCqq5DScZPx3b5KKfOzmPyny5BIT8qSWY6rATlmmmk28IYH7beWTXHv4BYV(s3PLNAqEhRWC61DqojzbAgtkwdw(yBwwvZ9x9JWHb1JjfRbnaw9WJbs0wpdbDyQ(aLQhQHHg1ta5wFdvpYbp1R(aWRJ6zO6XKjhxFdQpAfkxZTu0hyZBqMoqDj5YZ0WlQjp1oPbseVn0eCgUngnLxuPlDkmNZ7AqS(GAyOHdtkwd2rt3PLNAqEhRWC61DqojzbAgtkwd2AEn3F1JeKPduswp75cl6duZ9x98Nq1JeKPd0HHZa9IwVHP6584TEULQhb1KN6nW9aQ(4QNHaeuh1dHpL6duQEpB3goQEMdWT1Baz9W3giRFgs2aaTB9eCeO(gQE1u9gMQ3I6vm2VE)e(upRHWNs9bkvVhMsNcJf1ZFdbpSkxZTu0hyZBqMoqjjptdVOM8uVbUhq82qtSMHdckVbz6anZ5XclmCqqz4mqVOzopwvZ9x9W3g0lA9wup)4PE)e(uV6oqpUOE4bP(HR3V8uV6oqRhEqQxDhO1JGYH7beOEvomWKx9mCqq1Z5vFC1BWDTS(9uO69t4t9QTnO63o4SOpWMR5wk6dS5nithOKKNPHtMw7Su0hWP7n4fyk0eud6fL3gAIHdckVOC4EabCXHbM8YCE(sNcZ58UgeBwsqDQJrNgQM7V6zV07v)Aqu9Xvpud6fTElQ3V8uVFcFQxDhO1tSVLc9469B9HHHrXMRN1iMcvVT1FCX2sQ(nithOzwvZTu0hyZBqMoqjjptdNmT2zPOpGt3BWlWuOjOg0lkVn006rATlmmmk28IYH7beWTXHvM8RV0PWCoVRbXY3KFR5(RE4Bd6fTElQ3V8uVFcFQxDhOhxup8GWB9(NN6v3bA9WdcV1Baz9WF9Q7aTE4bPEdkiC98xgOx0AULI(aBEdY0bkj5zA4KP1olf9bC6EdEbMcnb1GEr5THMsNcZ58UgeBwsqDQJrNyBMyDyAcezjrEe2Tb2cdgPKjGXOjPpgoiOmCgOx0mNhRQ5wk6dS5nithOKKNPHx0goEBOPW0eiYGggASHPhq4mbmgnj9H5ae0HHr5ObJDXX(DYXOnjLPzKR98izn3F1dFpC9EyAM8SiHYB9diYRE4BdK1pdjBaG2TEoV6pq9bkvVhUvm846dddJI6LCu9Xvp4Qhb1KN665VmoDuZTu0hyZBqMoqjjptdVOM8uVbUhq82qtAcospQ)hYNKy4GGYqnq6ut2aaTBgtkwd2rzZxyyyuKJwHCX5KnntysXAWYh8xZ9x9WlE1hx98R(WWWOyRFarE1Z5vp8TbY6NHKnaq7wpZ46tJt6gaREeutEQ3a3dOCn3srFGnVbz6aLK8mn8IAYt9g4EaXBACstUWWWOyNyJ3gAssmCqqzOgiDQjBaG2nJjfRb7OS5B9iT2fgggfBEr5W9ac424WkJoXpFHHHrroAfYfNt20mHjfRblFWFn3F1pd7a94I6HhI8iC9ib2cdgPuVbK1ZV6zpgyWw)bv)iAts13G6duQEeutEQ367O(ERx9Hd0652gaREeutEQ3a3dO6pq98R(WWWOyZ1Clf9b28gKPdusYZ0WlQjp1BG7beVn0e7cttGiljYJWUnWwyWiLmbmgnj9z8pH7GYmAtsUg4cuYTOM8uVzSbgmXpFRhP1UWWWOyZlkhUhqa3ghwzIF1C)vp89W17H7d3X46XxyrFaERNBP6rqn5PEdCpGQ)GJW1JehwPE2yv9Q7aT(zi)D9gmRbBupNx9XvVFRpmmmkwERFiwvFdvp8DgwFV1J5aGgaR(dcQEwFG6nW46nLJde1Fq1hgggflR4T(dxp)yv9XvVIX(TsZ)u9ih8upX(bb2(a1RUd065pbeCDymTUJX1FG65x9HHHrXwpR9B9Q7aT(r6aHv5AULI(aBEdY0bkj5zA4f1KN6nW9aI3gAcod3gJMYCl58W9H7ySdFHf9b8XAjXWbbLHAG0PMSbaA3mMuSgSJYglSeMMarwnzEhqX2GWzcymAs6B9iT2fgggfBEr5W9ac424WkJo5xwyX4Fc3bLBabxhgtR7yCMagJMK(y4GGY7yfMtVUdYjjlqZCE(wpsRDHHHrXMxuoCpGaUnoSYOt8JhJ)jChuMrBsY1axGsUf1KN6ntaJrtswvZTu0hyZBqMoqjjptdVOC4EabCBCyfEBOP1J0AxyyyuS8nXpEyndheu2dtkKSdl6dK58yHfgoiOCGso8fbbYCESWcMdqqhggLTbMH71ThN2bHnykeiY0mY1EEK0x6asUoYsI8iStAWGr4nJnWa(M8JSQMBPOpWM3GmDGssEMgErn5PEdCpG4THMKedheugQbsNAYgaODZysXAWo6eBSWs6oT8udY7yfMtVUdYjjlqZysXAWokBZSpjXWbbLHAG0PMSbaA3mMuSgSJMUtlp1G8owH50R7GCsYc0mMuSgS1C)vpcQjp1BG7bu9XvpMGW0Iwp8TbY6NHKnaq7wVbK1hx9ey5Wu9QP6tgO(KHXJR)GJW1B1dXP11dFNH13G4QpqP6be7h1JCWt9nu9E3UnJMY1Clf9b28gKPdusYZ0WE3PDyApoCI4f6WoaX(XeB1Clf9b28gKPdusYZ0WW03PWOnjXBdnXomhGGommkBdmd3RBpoTdcBWuiqKPzKR98iPpgoiOShHHoSfK0bh1GnVHLgW3e)8LoGKRJShHHoSfK0bh1GnJnWa(MyJFZeR9dW70bKCDKLe5ryN0GbJWzcymAsYt6asUoYsI8iStAWGr4m2adyvn3srFGnVbz6aLK8mnmm9DkmAts82qtyoabDyyu2gygUx3ECAhe2GPqGitZix75rsFmCqqzpcdDyliPdoQbBEdlnGVj(5J1Pdi56i7ryOdBbjDWrnyZydmGN0bKCDKLe5ryN0GbJWzSbgWk(Myd(R5wk6dS5nithOKKNPHxutEQ3a3dOAEn3F1dFBqVOeER5wk6dSzOg0lkptdV6orodiDYor82qtRhP1UWWWOyZlkhUhqa3ghwzu43h7y4GGYlQjp1oPbsuMZZhdheuE1DICgq6KDIYysXAWokuddnCysXAW6JHdckV6orodiDYorzmPynyhL1SXt6uyoN31Gyzf8MT8mxZTu0hyZqnOxuEMggod3gJM4fyk00oO9CyoVGdt8cNP5OjfBdc7SDTDBGdtkwdw(MLfwyxyAcezqddn2W0diCMagJMK(cttGiln8a3IAYtDMagJMK(y4GGYlQjp1oPbsuMZJfwwpsRDHHHrXMxuoCpGaUnoScFtWpVZGjThHRN)YWTXOP6HoC9ShoVGdt56rg0E1l5Wnaw9832geUE2RDTDBq9hUEjhUbWQhEmqIQxDhO1dpgEq9gqwp4Qx1ggASHPhq4Cn3F1dVAI8QNZRE2dNxWHP6BO67O(ER3yoUO(4QhZbQ)4ICn3srFGnd1GEr5zAymNxWHjEBOj2bNHBJrt5Dq75WCEbhM8fgggf5OvixCoztZeMuSgS8b)(WeeMwuJrt1Clf9b2mud6fLNPHxkHPWfucf0ZihvZ9x983C6OLxenaw9HHHrXwFGAr9QBTUEDdhvp0HRpqP6LCyl6du)bvp7HZl4Wu9ycctlA9soCdGvVNbKKsNY1Clf9b2mud6fLNPHXCEbhM4nnoPjxyyyuStSXBdnXo4mCBmAkVdAphMZl4WKp2bNHBJrtzULCE4(WDm2HVWI(a(wpsRDHHHrXMxuoCpGaUnoScFtd5lmmmkYrRqU4CYM4BI1(Nhwpe8oDkmNZ7AqSSIv(WeeMwuJrt1C)vp7HGW0Iwp7HZl4Wu9KH1JRVHQVJ6v3AD9e771yQEjhUbWQhzScZP3C9WZvFGAr9ycctlA9nu9ih8upmk26XKjhxFdQpqP6be7h17)nxZTu0hyZqnOxuEMggZ5fCyI3gAIDWz42y0uEh0EomNxWHjFysXAWoA6oT8udY7yfMtVUdYjjlqZysXAWYdBZ6lDNwEQb5DScZPx3b5KKfOzmPynyhDY)(cddJIC0kKloNSPzctkwdw(s3PLNAqEhRWC61DqojzbAgtkwdwE8Fn3srFGnd1GEr5zAygTLg48o1scZBdnXo4mCBmAkZTKZd3hUJXo8fw0hW36rATlmmmkw(M4xn3srFGnd1GEr5zAycUEte2cQMxZ9x9JW1AjH3AULI(aBMHR1YPfTHJ3gAIDHPjqKbnm0ydtpGWzcymAs6dZbiOddJYrdg7IJ97KJrBsktZix75rYAULI(aBMHR1sEMgEr5W9ac424Wk82qtRhP1UWWWOy5BAiEyDyAcezy67uy0MKYeWy0K0NX)eUdk7ryOdBbLXgyaFtd5Z72o6d4yS0awvZTu0hyZmCTwYZ0WlHXwqshZbi361diEBOP0DA5PgKxcJTGKoMdqU1Rhq5eQHHrRdcBPOpGP5BAOSF0)1Clf9b2mdxRL8mnmm9DkmAts1Clf9b2mdxRL8mnmJLgSHXiqwpkjuDi4NnricHa]] )


end
