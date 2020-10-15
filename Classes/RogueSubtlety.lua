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
            duration = 15,
            max_stack = 3,
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

            cooldown.shadow_blades.expires = max( 0, cooldown.shadow_blades.expires - ( amt * 1.5 ) )
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
                spend( min( talent.deeper_stratagem.enabled and 6 or 5, combo_points.current ), "combo_points" )
                if conduit.deeper_daggers.enabled then applyBuff( "deeper_daggers" ) end
            end,
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

                if combo_points.current == animacharged_cp then removeBuff( "echoing_reprimand" ) end
                spend( min( talent.deeper_stratagem.enabled and 6 or 5, combo_points.current ), "combo_points" )
            end,
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
            
            spend = function () return 25 * ( ( talent.shadow_focus.enabled and ( buff.shadow_dance.up or buff.stealth.up ) ) and 0.8 or 1 ) end,
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
        }


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


    spec:RegisterPack( "Subtlety", 20201015, [[daL51bqiufEeLO2eL0NqHumkuOofivRcfcVcf1Sqv5wGezxI6xkeddKYXqrwMc4zOQY0OeCnkr2gQI8nkH04ajLZrjeRdvrX8uGUhi2hQs)dKOsoikKQfQq6Huc1ebj5IGei2ike9rqIkgjibQtIQOYkbfVeKOsntqIQUjQIQ2jrPFIcP0qbjvlffsEkuMkrXvbjkBfvrPVcsqNfKaP9s4VKAWQ6WuTyu6XImzsUmYMv0NbvJgQoTuRgKaETcA2uCBISBGFR0WPuhhKqlhYZvz6cxhv2oO03jQgpQQQZRqTEuvL5Jc2VKfmjKrGP8GeYoa0gaAmbnMSugAwelXKfSGalgBtcmBpn0HtcmGlrcmmo2WqXybMTp2SUsiJa7wouIey4ryF8mJmc8oW5yZPvAKRL4mE0liH8zmY1sPreySCTj45acwbMYdsi7aqBaOXe0yYszOzrSet8ZscmNlWxKadRLSybgERueqWkWu0LeywUEmo2WqX46zulCoQGXY1ZOnfllHQNjlXx9daTbGMaZ0xCczeyxqUjWjLqgHSmjKrGraN1qkXOcSeQdc1UaJX1ZYnN5li3e4zo76zGH6z5MZmSoOp8mND9qxG5POxGa7WD1k)cupKeHq2beYiWiGZAiLyubwc1bHAxGXYnN5dNd1djGoweWvBMZUER1Nwj2vBVniUSIMDQJ6hes9diW8u0lqGLCJr7POxG20xiWm9fAGlrcSzd6dxecz5NqgbgbCwdPeJkWsOoiu7cSZMmgD4i4uC5dNd1djG(IfjvpK6Tq9wRpTsSR2EBqC1ZlK6TGaZtrVabwYngTNIEbAtFHaZ0xObUejWMnOpCriK1cczeyeWznKsmQalH6GqTlWsRe7QT3gexwrZo1r9dcPEMQhkvpJRpCdbISIiBcPVa5HdNKYeWznKQER1ZYnNzyDqF4zo76HUaZtrVabwYngTNIEbAtFHaZ0xObUejWMnOpCriK1sczeyeWznKsmQalH6GqTlWmeSKP(bR3sduV16vel3CMNnqPLt(qaDxgrsEdU6hSEMQ3A9HJGtroAjshRw1u9qP6rKK3GREERNNeyEk6fiWoCxTYVa1djriKLNeYiWiGZAiLyubMNIEbcSd3vR8lq9qsGLqDqO2fykILBoZZgO0YjFiGUlJijVbx9dwpt1BT(ZMmgD4i4uC5dNd1djG(Ifjv)GqQNF1BT(WrWPihTePJvRAQEOu9isYBWvpV1ZtcS04KH0HJGtXjKLjriK1IkKrGraN1qkXOcSeQdc1UaJh1hUHarwrKnH0xG8WHtszc4SgsvV16D(JqDqzwJRiDd0boPpCxTYVmYbdRhs98RER1F2KXOdhbNIlF4COEib0xSiP6Hup)eyEk6fiWoCxTYVa1djriKfQjKrGraN1qkXOcSeQdc1Uadwh1oRHYChPTr9I6ySgTHh9cQ3A9mUEfXYnN5zduA5Kpeq3LrKK3GR(bRNP6zGH6d3qGilNC7fi5xqOmbCwdPQ3A9Nnzm6WrWP4YhohQhsa9flsQ(bHuVfQNbgQ35pc1bLBabBhoBB6yCMaoRHu1BTEwU5mFJLyxZP3PwrEGN5SR3A9Nnzm6WrWP4YhohQhsa9flsQ(bHup)QN56D(JqDqzwJRiDd0boPpCxTYVmbCwdPQh6cmpf9ceyhURw5xG6HKieYAreYiWiGZAiLyubwc1bHAxGD2KXOdhbNIREEHup)QN56zC9SCZz2grsKQdp6fK5SRNbgQNLBoZboPrBeeiZzxpdmupIdqZfbNY(q3r9PVLZONihUebImbf5ABBsvV16tlqX1rwrKnH0khoCcDzKdgwpVqQ3Iwp0fyEk6fiWoCoupKa6lwKKieYYe0eYiWiGZAiLyubwc1bHAxGPiwU5mpBGslN8Ha6UmIK8gC1piK6zQEgyO(0Ug1khKVXsSR507uRipWZisYBWv)G1ZeuRER1RiwU5mpBGslN8Ha6UmIK8gC1py9PDnQvoiFJLyxZP3PwrEGNrKK3GtG5POxGa7WD1k)cupKeHqwMysiJaJaoRHuIrfyZfPbe)hczzsG5POxGaZExJgr3YHsKieYY0aczeyeWznKsmQalH6GqTlW4r9ioanxeCk7dDh1N(woJEIC4seiYeuKRTTjv9wRNLBoZ2eAUipiLgwQbx(cpnSEEHup)Q3A9PfO46iBtO5I8GuAyPgCzKdgwpVqQNj(vpuQEgxVfPEgr9PfO46iRiYMqALdhoHYeWznKQEMRpTafxhzfr2esRC4Wjug5GH1dDbMNIEbcm4MDLynUIeHqwM4NqgbgbCwdPeJkWsOoiu7cmehGMlcoL9HUJ6tFlNrproCjcezckY122KQER1ZYnNzBcnxKhKsdl1GlFHNgwpVqQNF1BTEgxFAbkUoY2eAUipiLgwQbxg5GH1ZC9PfO46iRiYMqALdhoHYihmSEOxpVqQNjEsG5POxGadUzxjwJRiriKLjliKrG5POxGa7WD1k)cupKeyeWznKsmQieHaJUJaj6eYiKLjHmcmc4SgsjgvGLqDqO2fyeGqWhNJwI0XQLC(VEERNP6TwppQNLBoZ3yj21C6DQvKh4zo76TwpJRNh1R2iNwqIabYdsPNgxI0SCiqo60WgaVER1ZJ69u0liNwqIabYdsPNgxIYnqpnnC8OEgyO(jNXOruc3rWjD0su9dwp8Kkl58F9qxG5POxGalTGebcKhKspnUejcHSdiKrGraN1qkXOcSeQdc1UaJh1N21Ow5G8H7QvUM14k6YC21BT(0Ug1khKVXsSR507uRipWZC21Zad1pB44HgrsEdU6hes9mbnbMNIEbcmwZUk9o1boPjajnwecz5NqgbMNIEbcm4Cos1oqVtTZFeAdCbgbCwdPeJkcHSwqiJaJaoRHuIrfyjuheQDbgJR)SjJrhocofx(W5q9qcOVyrs1ZlK6hOEgyOEK3knblbISRuxUb1ZB98e0Qh61BTEEuFAxJALdY3yj21C6DQvKh4zo76TwppQNLBoZ3yj21C6DQvKh4zo76Twpbie8Xzfn7uh1ZlK65h0eyEk6fiWMBI7iL25pc1bPzjxseczTKqgbgbCwdPeJkWsOoiu7cSZMmgD4i4uC5dNd1djG(IfjvpVqQFG6zGH6rER0eSeiYUsD5gupV1ZtqtG5POxGaZMd1ZXnaUM14xicHS8KqgbgbCwdPeJkWsOoiu7cmwU5mJO0qdDNEUOeL5SRNbgQNLBoZikn0q3PNlkr60YbccLVWtdRFW6zcAcmpf9ceyboP5aSlhqPNlkrIqiRfviJaZtrVabgQTTnKUb6Z2tKaJaoRHuIrfHqwOMqgbgbCwdPeJkWsOoiu7cS0Ug1khKVXsSR507uRipWZisYBWv)G1BP6zGH6NnC8qJijVbx9dwptqnbMNIEbcm5lYOGLAGgr3cCqIeHqwlIqgbgbCwdPeJkWsOoiu7cmcqi4JRFW6Ta0Q3A9SCZz(glXUMtVtTI8apZzlW8u0lqGjrslASENAdxQvAfICPteczzcAczeyeWznKsmQalH6GqTlWMnC8qJijVbx9dwptzlvpdmupJRNX1hocofzCYnbE2of1ZB9qnOvpdmuF4i4uKXj3e4z7uu)GqQFaOvp0R3A9mUEpfnSKMaKutx9qQNP6zGH6NnC8qJijVbx98w)awK6HE9qVEgyOEgxF4i4uKJwI0XQTtHEaOvpV1ZpOvV16zC9EkAyjnbiPMU6Hupt1Zad1pB44HgrsEdU65TElyH6HE9qxG5POxGadrUDdGRNgxIoricbMIMoNjeYiKLjHmcmpf9ceyd70qbgbCwdPeJkcHSdiKrGraN1qkXOcS1wGDuiW8u0lqGbRJAN1qcmyDdhjWy5MZ8z6ePDGsR6eL5SRNbgQ)SjJrhocofx(W5q9qcOVyrs1ZlK65jbgSosdCjsGDaLoTavh9ceHqw(jKrGraN1qkXOcmpf9ceyj3y0Ek6fOn9fcmtFHg4sKalPoriK1cczeyeWznKsmQalH6GqTlWUGCtGtQSBmcmpf9ceyioG2trVaTPVqGz6l0axIeyxqUjWjLieYAjHmcmc4SgsjgvGLqDqO2fyNnzm6WrWP4YhohQhsa9flsQ(bRNNQ3A9ZgoEOrKK3GREERNNQ3A9SCZz(mDI0oqPvDIYisYBWv)G1dpPYso)xV16tRe7QT3gex98cPElupuQEgxF0su9dwptqREOxpJO(beyEk6fiWotNiTduAvNiriKLNeYiWiGZAiLyub2AlWokeyEk6fiWG1rTZAibgSUHJey2OErDmwJ2WJEb1BT(ZMmgD4i4uC5dNd1djG(IfjvpVqQFabgSosdCjsGXDK2g1lQJXA0gE0lqeczTOczeyeWznKsmQalH6GqTlWG1rTZAOm3rABuVOogRrB4rVabMNIEbcSKBmApf9c0M(cbMPVqdCjsGDb5MaxNuNieYc1eYiWiGZAiLyub2AlWokeyEk6fiWG1rTZAibgSUHJeydyP6zU(WneiYW2WxuMaoRHu1ZiQFaOvpZ1hUHarwYVGq6DQpCxTYVmbCwdPQNru)aqREMRpCdbI8H7QvUEUjUltaN1qQ6ze1pGLQN56d3qGi7gpH6yCMaoRHu1ZiQFaOvpZ1pGLQNrupJR)SjJrhocofx(W5q9qcOVyrs1ZlK6Tq9qxGbRJ0axIeyxqUjW1boIo81OeHqwlIqgbgbCwdPeJkWsOoiu7cmcqi4JZkA2PoQFqi1dRJAN1q5li3e46ahrh(Aucmpf9ceyj3y0Ek6fOn9fcmtFHg4sKa7cYnbUoPoriKLjOjKrGraN1qkXOcSeQdc1UaZ5pc1bLbnC840Wsa4KdsuMaoRHu1BTEEupl3CMbnC840Wsa4KdsuMZUER1Nwj2vBVniUSIMDQJ65TEMQ3A9mU(ZMmgD4i4uC5dNd1djG(Ifjv)G1pq9mWq9W6O2znuM7iTnQxuhJ1On8Oxq9qVER1Z46t7AuRCq(glXUMtVtTI8apJijVbx9dcPE(vpdmupJR35pc1bLbnC840Wsa4Kdsug5GH1ZlK6hOER1ZYnN5BSe7Ao9o1kYd8mIK8gC1ZB98RER1ZJ6VGCtGtQSBm1BT(0Ug1khKpCxTY1khKOCc3rWPtprEk6f4M65fs9qlBrQh61dDbMNIEbcmeNDWHiriKLjMeYiWiGZAiLyubwc1bHAxGH4a0CrWPSI8a3mwF4UALFzckY122KQER1R2iFK91xo60WgaVER1R2iFK91xgrsEdU6hes9duV16tRe7QT3gex98cP(beyEk6fiWsUXO9u0lqB6leyM(cnWLib2Sb9HlcHSmnGqgbgbCwdPeJkWsOoiu7cS0Ug1khKVXsSR507uRipWZisYBWv)GqQFG6TwFALyxT92G4QNxi1pq9wRhXbO5IGt5aN0OnccKjOixBBtkbMNIEbcSKBmApf9c0M(cbMPVqdCjsGnBqF4Iqilt8tiJaJaoRHuIrfyjuheQDbwALyxT92G4Qhs9oOL8eUJGtkDYwG5POxGal5gJ2trVaTPVqGz6l0axIeyZg0hUieYYKfeYiWiGZAiLyubwc1bHAxGLwj2vBVniUSIMDQJ6hes9mvpdmu)SHJhAej5n4QFqi1Zu9wRpTsSR2EBqC1ZlK65NaZtrVabwYngTNIEbAtFHaZ0xObUejWMnOpCriKLjljKrGraN1qkXOcSeQdc1Ua7SjJrhocofx(W5q9qcOVyrs1dPEluV16tRe7QT3gex98cPEliW8u0lqGLCJr7POxG20xiWm9fAGlrcSzd6dxeczzINeYiWiGZAiLyubwc1bHAxGracbFCwrZo1r9dcPEyDu7SgkFb5Maxh4i6WxJsG5POxGal5gJ2trVaTPVqGz6l0axIeySCTrjcHSmzrfYiWiGZAiLyubwc1bHAxGracbFCwrZo1r98cPEMSu9mxpbie8XzebNacmpf9ceyok5ashlcrGqeczzcQjKrG5POxGaZrjhqABoZrcmc4SgsjgveczzYIiKrG5POxGaZ0WXJtdfGtbxIaHaJaoRHuIrfHq2bGMqgbMNIEbcmwhUEN6a1PHNaJaoRHuIrfHiey2ikTsSEiKriltczeyEk6fiWCBBZyT923ceyeWznKsmQieYoGqgbMNIEbcSli3e4cmc4Sgsjgvecz5NqgbgbCwdPeJkW8u0lqGj5OHKspxKwrEGlWSruALy9qFuAbQtGXKLeHqwliKrGraN1qkXOcmpf9ceyNPtK2bkTQtKaZgrPvI1d9rPfOobgtIqiRLeYiWiGZAiLyubwc1bHAxGH4a0CrWPSKJgQ3PoWjTKFbH0(D(DnitqrU22Mucmpf9ceyhURw5AwJROtecz5jHmcmc4SgsjgvGbCjsG583H7i)0Zfe6DQTx5esG5POxGaZ5Vd3r(PNli07uBVYjKieHaJLRnkHmczzsiJaJaoRHuIrfyjuheQDb2ztgJoCeCkU65fs9dupZ1Z46d3qGid3SReRXvuMaoRHu1BTEN)iuhu2MqZf5bLroyy98cP(bQh6cmpf9ceyhohQhsa9flsseczhqiJaJaoRHuIrfyjuheQDbwAxJALdYhHqEqkn7ci9z3dPCc3rWPtprEk6f4M65fs9dKTOwsG5POxGa7ieYdsPzxaPp7EijcHS8tiJaZtrVabgCZUsSgxrcmc4SgsjgveczTGqgbMNIEbcmwpn8cNvGraN1qkXOIqecSK6eYiKLjHmcmc4SgsjgvGLqDqO2fy8OEwU5mF4UALRvoirzo76Twpl3CMpCoupKa6yraxTzo76Twpl3CMpCoupKa6yraxTzej5n4QFqi1ZVSLeyEk6fiWoCxTY1khKibg3r6Do1WtkHSmjcHSdiKrGraN1qkXOcSeQdc1UaJLBoZhohQhsaDSiGR2mND9wRNLBoZhohQhsaDSiGR2mIK8gC1piK65x2scmpf9cey3yj21C6DQvKh4cmUJ07CQHNuczzsecz5NqgbgbCwdPeJkWsOoiu7cmyDu7SgkFaLoTavh9cQ3A98O(li3e4Kkl5GWqcmpf9ceytJdNmgp6ficHSwqiJaJaoRHuIrfyjuheQDbMIy5MZ804WjJXJEbzej5n4QFW6hOEgyOEfXYnN5PXHtgJh9cYx4PH1ZlK6Ta0eyEk6fiWMghozmE0lqNmKdoseczTKqgbgbCwdPeJkWsOoiu7cmgxpIdqZfbNYsoAOEN6aN0s(fes73531Gmbf5ABBsvV16tRe7QT3gexwrZo1r9dcPE(vpdmupIdqZfbNYkYdCZy9H7Qv(LjOixBBtQ6TwFALyxT92G4QFW6zQEOxV16z5MZ8nwIDnNENAf5bEMZUER1ZYnN5d3vRCTYbjkZzxV16L8liK2VZVRbAej5n4Qhs9qRER1ZYnNzf5bUzS(WD1k)YQvoqG5POxGadwh0hUieYYtczeyeWznKsmQalH6GqTlW4r9xqUjWjv2nM6TwpSoQDwdLpGsNwGQJEb1Zad1t3rGeLzrKh46DQdCsRg3a4zjhkWIQ3A9rlr1ZlK6hqG5POxGal5gJ2trVaTPVqGz6l0axIey0DeirNieYArfYiWiGZAiLyubMNIEbcm7DnAeDlhkrcSeQdc1UaJh1hUHar(WD1kxp3e3LjGZAiLaBUinG4)qiltIqilutiJaJaoRHuIrfyjuheQDbgbie8X1ZlK65jOvV16H1rTZAO8bu60cuD0lOER1N21Ow5G8nwIDnNENAf5bEMZUER1N21Ow5G8H7QvUw5GeLt4ocoD1ZlK6zsG5POxGa7W5q9qcOJfbC1kcHSweHmcmc4SgsjgvG5POxGa7ieYdsPzxaPp7EijWsOoiu7cmyDu7SgkFaLoTavh9cQ3A98OE1g5JqipiLMDbK(S7HKwTro60WgaVEgyO(zdhp0isYBWv)GqQ3scS04KH0HJGtXjKLjriKLjOjKrGraN1qkXOcSeQdc1Uadwh1oRHYhqPtlq1rVG6TwppQpTRrTYb5d3vRCnRXv0L5SR3A9mU(WneiYeawYS2naU(WD1k)YeWznKQEgyO(0Ug1khKpCxTY1khKOCc3rWPREEHupt1d96TwpJRNh1hUHar(W5q9qcOJfbC1MjGZAiv9mWq9HBiqKpCxTY1ZnXDzc4SgsvpdmuFAxJALdYhohQhsaDSiGR2mIK8gC1ZB9dup0R3A9mUEEupIdqZfbNYboPrBeeitqrU22Mu1Zad1Nwj2vBVniU6hes9dup0R3A9mUEEupDhbsuM1SRsVtDGtAcqsJZsouGfvpdmuFAxJALdYSMDv6DQdCstasACgrsEdU65T(bQh6cmpf9cey3yj21C6DQvKh4IqiltmjKrGraN1qkXOcmpf9ceysoAiP0ZfPvKh4cSeQdc1Uad5TstWsGi7k1L5SR3A9mU(WrWPihTePJvRAQ(bRpTsSR2EBqCzfn7uh1Zad1ZJ6VGCtGtQSBm1BT(0kXUA7TbXLv0StDupVqQpzRLC(xF2eqvp0fyPXjdPdhbNItiltIqiltdiKrGraN1qkXOcSeQdc1Uad5TstWsGi7k1LBq98wp)Gw9qP6rER0eSeiYUsDzfhYJEb1BT(0kXUA7TbXLv0StDupVqQpzRLC(xF2eqjW8u0lqGj5OHKspxKwrEGlcHSmXpHmcmc4SgsjgvGLqDqO2fyW6O2znu(akDAbQo6fuV16tRe7QT3gexwrZo1r98cP(beyEk6fiWoCxTY1SgxrNieYYKfeYiWiGZAiLyubwc1bHAxGbRJAN1q5dO0PfO6Oxq9wRpTsSR2EBqCzfn7uh1ZlK65x9wR)SjJrhocofx(W5q9qcOVyrs1piK6TGaZtrVabgLW3gaxJiBul5aLieYYKLeYiWiGZAiLyubwc1bHAxGfUHar(WD1kxp3e3LjGZAiv9wRhwh1oRHYhqPtlq1rVG6Twpl3CMVXsSR507uRipWZC2cmpf9ceyhohQhsaDSiGRwriKLjEsiJaJaoRHuIrfyjuheQDbgpQNLBoZhURw5ALdsuMZUER1pB44HgrsEdU6hes9qT6zU(WneiYhhBqOjhCktaN1qkbMNIEbcSd3vRCTYbjseczzYIkKrG5POxGaZEJEbcmc4SgsjgveczzcQjKrGraN1qkXOcSeQdc1UaJLBoZ3yj21C6DQvKh4zoBbMNIEbcmwZUk9KdnweczzYIiKrGraN1qkXOcSeQdc1UaJLBoZ3yj21C6DQvKh4zoBbMNIEbcmwcDeAydGlcHSdanHmcmc4SgsjgvGLqDqO2fySCZz(glXUMtVtTI8apZzlW8u0lqGnBeXA2vjcHSdWKqgbgbCwdPeJkWsOoiu7cmwU5mFJLyxZP3PwrEGN5SfyEk6fiWCqIUa5gDYngriKDGbeYiWiGZAiLyubMNIEbcS04Kzd0c6KM14xiWsOoiu7cmEu)fKBcCsLDJPER1dRJAN1q5dO0PfO6Oxq9wRNh1ZYnN5BSe7Ao9o1kYd8mND9wRNaec(4SIMDQJ65fs98dAcmAoPuObUejWsJtMnqlOtAwJFHieYoa)eYiWiGZAiLyubMNIEbcmN)oCh5NEUGqVtT9kNqcSeQdc1UaJh1ZYnN5d3vRCTYbjkZzxV16t7AuRCq(glXUMtVtTI8apJijVbx9dwptqtGbCjsG583H7i)0Zfe6DQTx5eseczhWcczeyeWznKsmQaZtrVabMF4W6a60iN)wKoTi3iWsOoiu7cmfXYnNzKZFlsNwKB0kILBoZQvoOEgyOEfXYnN50cuCPOHL0nyOwrSCZzMZUER1hocofzCYnbE2of1py98BG6TwF4i4uKXj3e4z7uupVqQNFqREgyOEEuVIy5MZCAbkUu0Ws6gmuRiwU5mZzxV16zC9kILBoZiN)wKoTi3Ovel3CMVWtdRNxi1pGLQhkvptqREgr9kILBoZSMDv6DQdCstasACMZUEgyO(zdhp0isYBWv)G1BbOvp0R3A9SCZz(glXUMtVtTI8apJijVbx98wputGbCjsG5hoSoGonY5VfPtlYnIqi7awsiJaJaoRHuIrfyaxIeysJv(Pd30NKdeyEk6fiWKgR8thUPpjhicHSdWtczeyeWznKsmQalH6GqTlWy5MZ8nwIDnNENAf5bEMZUEgyO(zdhp0isYBWv)G1pa0eyEk6fiW4os3bjDIqecSli3e46K6eYiKLjHmcmc4SgsjgvGT2cSJcbMNIEbcmyDu7SgsGbRB4ibwAxJALdYhURw5ALdsuoH7i40PNipf9cCt98cPEMYwuljWG1rAGlrcSdxPdCeD4RrjcHSdiKrGraN1qkXOcSeQdc1UaJX1ZJ6H1rTZAO8HR0boIo81OQNbgQNh1hUHarg0WXJlCZqcLjGZAiv9wRpCdbISYrd1hURw5zc4Sgsvp0R3A9PvID12BdIlROzN6OEERNP6TwppQhXbO5IGtzjhnuVtDGtAj)ccP9787AqMGICTTnPeyEk6fiWG1b9HlcHS8tiJaZtrVab2r2xFcmc4SgsjgveczTGqgbgbCwdPeJkW8u0lqGzVRrJOB5qjsGr8FGCTlTCGqGzbOjWMlsdi(peYYKieYAjHmcmc4SgsjgvGLqDqO2fyeGqWhxpVqQ3cqRER1tacbFCwrZo1r98cPEMGw9wRNh1dRJAN1q5dxPdCeD4RrvV16tRe7QT3gexwrZo1r98wpt1BTEfXYnN5zduA5Kpeq3LrKK3GR(bRNjbMNIEbcSd3vRCjYOeHqwEsiJaJaoRHuIrfyRTa7OqG5POxGadwh1oRHeyW6gosGLwj2vBVniUSIMDQJ65fs9wqGbRJ0axIeyhUsNwj2vBVnioriK1IkKrGraN1qkXOcS1wGDuiW8u0lqGbRJAN1qcmyDdhjWsRe7QT3gexwrZo1r9dcPEMeyjuheQDbgSoQDwdL5osBJ6f1XynAdp6fiWG1rAGlrcSdxPtRe7QT3geNieYc1eYiWiGZAiLyubwc1bHAxGbRJAN1q5dxPtRe7QT3gex9wRNX1dRJAN1q5dxPdCeD4Rrvpdmupl3CMVXsSR507uRipWZisYBWvpVqQNP8a1Zad1F2KXOdhbNIlF4COEib0xSiP65fs9wOER1N21Ow5G8nwIDnNENAf5bEgrsEdU65TEMGw9qxG5POxGa7WD1kxRCqIeHqwlIqgbgbCwdPeJkWsOoiu7cmyDu7SgkF4kDALyxT92G4Q3A9ZgoEOrKK3GR(bRpTRrTYb5BSe7Ao9o1kYd8mIK8gCcmpf9ceyhURw5ALdsKieHaB2G(WfYiKLjHmcmc4SgsjgvGLqDqO2fyNnzm6WrWP4YhohQhsa9flsQ(bRNNQ3A98OEwU5mF4UALRvoirzo76Twpl3CMptNiTduAvNOmIK8gC1py9ZgoEOrKK3GRER1ZYnN5Z0js7aLw1jkJijVbx9dwpJRNP6zU(0kXUA7TbXvp0RNruptzOMaZtrVab2z6ePDGsR6ejcHSdiKrGraN1qkXOcS1wGDuiW8u0lqGbRJAN1qcmyDdhjWK8liK2VZVRbAej5n4QN36Hw9mWq98O(WneiYGgoECHBgsOmbCwdPQ3A9HBiqKvoAO(WD1kptaN1qQ6Twpl3CMpCxTY1khKOmND9mWq9Nnzm6WrWP4YhohQhsa9flsQEEHuppjWG1rAGlrcSByBRrC2bhIeHqw(jKrGraN1qkXOcSeQdc1UaJh1dRJAN1q5ByBRrC2bhIQ3A9HJGtroAjshRw1u9qP6rKK3GREERNNQ3A9iAIOd3znKaZtrVabgIZo4qKieYAbHmcmpf9ceyhLquOdkHdAOihjWiGZAiLyuriK1sczeyeWznKsmQaZtrVabgIZo4qKalH6GqTlW4r9W6O2znu(g22AeNDWHO6TwppQhwh1oRHYChPTr9I6ySgTHh9cQ3A9Nnzm6WrWP4YhohQhsa9flsQEEHu)a1BT(WrWPihTePJvRAQEEHupJR3s1ZC9mU(bQNruFALyxT92G4Qh61d96TwpIMi6WDwdjWsJtgshocofNqwMeHqwEsiJaJaoRHuIrfyjuheQDbgpQhwh1oRHY3W2wJ4SdoevV16rKK3GR(bRpTRrTYb5BSe7Ao9o1kYd8mIK8gC1ZC9mbT6TwFAxJALdY3yj21C6DQvKh4zej5n4QFqi1BP6TwF4i4uKJwI0XQvnvpuQEej5n4QN36t7AuRCq(glXUMtVtTI8apJijVbx9mxVLeyEk6fiWqC2bhIeHqwlQqgbgbCwdPeJkWsOoiu7cmEupSoQDwdL5osBJ6f1XynAdp6fuV16pBYy0HJGtXvpVqQNFcmpf9ceySgpnuBVYveseczHAczeyEk6fiWiy7lripibgbCwdPeJkcricbgSe66fiKDaOna0ycAmzbbMChbAa8tGbfYOZOKLNtwOC4zQVEzWP6Bj7ff1pxu9mAy5AJIrt9ickY1isv)Tsu9oxSsEqQ6t4oaoD5cgO8nGQNjEM6zuK0clPQ3EVo6fOz90W6t4uAy9mgSr9oSEBCwdvFdQNK4mE0la61ZyM4FONlyky45KSxuqQ6HA17POxq9M(IlxWiWoBkjKDaEIjbMnANTHeywUEmo2WqX46zulCoQGXY1ZOnfllHQNjlXx9daTbGwbtbJLRhQJiOKfVsSEuW4POxWLTruALy9GziJ422MXA7TVfuW4POxWLTruALy9GziJCb5MaVGXtrVGlBJO0kX6bZqgrYrdjLEUiTI8aNpBeLwjwp0hLwG6GWKLky8u0l4Y2ikTsSEWmKrotNiTduAvNi(SruALy9qFuAbQdctfmEk6fCzBeLwjwpygYihURw5AwJROJVEcbXbO5IGtzjhnuVtDGtAj)ccP9787AqMGICTTnPky8u0l4Y2ikTsSEWmKr4os3bjXhWLiio)D4oYp9CbHENA7voHkykySC988EdQNrTHh9cky8u0l4GmStdly8u0l4ygYiW6O2zneFaxIGCaLoTavh9c4dw3Wrqy5MZ8z6ePDGsR6eL5SzGHZMmgD4i4uC5dNd1djG(IfjXleEIpOSJu1hB9kkiKudO6LJtboHQpTRrTYbx9Y9oQFUO6Xaqv9S(rQ6xq9HJGtXLlySC9wmoLgwVfdvx9Eu)SrxuW4POxWXmKrsUXO9u0lqB6l4d4seKK6kySC9mkoq9toJzC9N8os40vFS1h4u9yb5MaNu1ZO2WJEb1Zy2X1R2gaV(B5RJ6Nlkrx927AAa867z9GnWBa867REhwVnoRHGEUGXtrVGJziJG4aApf9c0M(c(aUeb5cYnboP4RNqUGCtGtQSBmfmwUEgDBBZ46ptNiTduAvNO69O(byUElgQxVId1a41h4u9ZgDr9mbT6pkTa1XNpdcvFG7r9wG56TyOE99S(oQN4F7grx9Y7aVb1h4u9aI)J6HYXIHQ6xu99vpyJ65Sly8u0l4ygYiNPtK2bkTQteF9eYztgJoCeCkU8HZH6HeqFXIKgKNSoB44HgrsEdoE5jRSCZz(mDI0oqPvDIYisYBWni8Kkl58V10kXUA7TbXXlelaLyC0s0GmbnOZigOGXY1ZOfygxFc3bWP6rB4rVG67z9YP6XDyP6Tr9I6ySgTHh9cQ)OOEhOQxIZeTTHQpCeCkU65SZfmEk6fCmdzeyDu7SgIpGlrq4osBJ6f1XynAdp6fWhSUHJGyJ6f1XynAdp6fy9SjJrhocofx(W5q9qcOVyrs8czGcglxpuh1lQJX1ZO2WJEbq5QEO8uWO5QhEdlvVxFc5217Slxupbie8X1pxu9bov)fKBc86TyO6QNXSCTrrO6VOnM6r0ztPO(oGEUEOGYzZxh1NCq9Su9bUh1FTKTHYfmEk6fCmdzKKBmApf9c0M(c(aUeb5cYnbUoPo(6jeyDu7SgkZDK2g1lQJXA0gE0lOGXY1dLDKQ(yRxrZgq1lhNa1hB9Chv)fKBc86TyO6QFr1ZY1gfHUcgpf9coMHmcSoQDwdXhWLiixqUjW1boIo81O4dw3WrqgWsmhUHarg2g(IYeWznKIrma0yoCdbISKFbH07uF4UALFzc4SgsXigaAmhUHar(WD1kxp3e3LjGZAifJyalXC4gcez34juhJZeWznKIrma0yEalXiy8ztgJoCeCkU8HZH6HeqFXIK4fIfGEbJLR3IxW1kcvp31a4171JfKBc86TyOQE54eOEe5j8gaV(aNQNaec(46dCeD4RrvW4POxWXmKrsUXO9u0lqB6l4d4seKli3e46K64RNqiaHGpoROzN6yqiW6O2znu(cYnbUoWr0HVgvbJLRx2goEWO5QNNLaWjhKiEM6zuC2bhIQNLMlIQhBSe7AU69OEZkVElgQxFS1Nwj2gq1toYmUEenr0HxV8oWRhofrdGxFGt1ZYnN1ZzNRNr3CB9MvE9wmuVEfhQbWRhBSe7AU6zPqorG6HkhKORE5DGx)amxVS8S5cgpf9coMHmcIZo4qeF9eIZFeQdkdA44XPHLaWjhKOmbCwdPSYdwU5mdA44XPHLaWjhKOmNT10kXUA7TbXLv0StDWltwz8ztgJoCeCkU8HZH6HeqFXIKgCagyawh1oRHYChPTr9I6ySgTHh9cGUvgN21Ow5G8nwIDnNENAf5bEgrsEdUbHWpgyGXo)rOoOmOHJhNgwcaNCqIYihmKxidyLLBoZ3yj21C6DQvKh4zej5n44LFw5XfKBcCsLDJXAAxJALdYhURw5ALdsuoH7i40PNipf9cCdVqGw2IaDOxW4POxWXmKrsUXO9u0lqB6l4d4seKzd6dNVEcbXbO5IGtzf5bUzS(WD1k)YeuKRTTjLv1g5JSV(YrNg2a4wvBKpY(6lJijVb3GqgWAALyxT92G44fYafmEk6fCmdzKKBmApf9c0M(c(aUebz2G(W5RNqs7AuRCq(glXUMtVtTI8apJijVb3GqgWAALyxT92G44fYawrCaAUi4uoWjnAJGazckY122KQGXtrVGJziJKCJr7POxG20xWhWLiiZg0hoF9esALyxT92G4G4GwYt4ocoP0j7cglxVLyUE5DGxpuHvpJxU4Afv)fKBcCOxW4POxWXmKrsUXO9u0lqB6l4d4seKzd6dNVEcjTsSR2EBqCzfn7uhdcHjgyy2WXdnIK8gCdcHjRPvID12BdIJxi8RGXY1ZiBqF417r9wG56L3b(Yf1dvyfmwUEOWoWRhQWQ3n3w)Sb9HxVh1BbMR3H7n4I6j(3tHzC9wO(WrWP4QNXlxCTIQ)cYnbo0ly8u0l4ygYij3y0Ek6fOn9f8bCjcYSb9HZxpHC2KXOdhbNIlF4COEib0xSijiwWAALyxT92G44fIfkySC9qzhvVxplxBueQE54eOEe5j8gaV(aNQNaec(46dCeD4RrvW4POxWXmKrsUXO9u0lqB6l4d4seewU2O4RNqiaHGpoROzN6yqiW6O2znu(cYnbUoWr0HVgvbJLRhk)kNUOEBuVOogxFdQ3nM63z9bovpJouhkF9SuY5oQ(oQp5ChD171dLJfdvfmEk6fCmdzehLCaPJfHiqWxpHqacbFCwrZo1bVqyYsmtacbFCgrWjqbJNIEbhZqgXrjhqABoZrfmEk6fCmdzetdhponuaofCjcefmEk6fCmdzewhUEN6a1PHxbtbJLR3I31Ow5GRGXY1dLDu9qLdsu97CcLGNu1ZsZfr1h4u9ZgDr9hohQhsa9flsQ(jALQxMfbC1wFALOR(gKly8u0l4Yj1XmKroCxTY1khKi(4osVZPgEsbHj(6jeEWYnN5d3vRCTYbjkZzBLLBoZhohQhsaDSiGR2mNTvwU5mF4COEib0XIaUAZisYBWnie(LTubJLRNXqzadDx9UbrUAC9C21ZsjN7O6Lt1h7oSEmCxTYRNrUjUd61ZDu9yJLyxZv)oNqj4jv9S0Cru9bov)Srxu)HZH6HeqFXIKQFIwP6LzraxT1Nwj6QVb5cgpf9cUCsDmdzKBSe7Ao9o1kYdC(4osVZPgEsbHj(6jewU5mF4COEib0XIaUAZC2wz5MZ8HZH6Heqhlc4QnJijVb3Gq4x2sfmEk6fC5K6ygYitJdNmgp6fWxpHaRJAN1q5dO0PfO6OxGvECb5MaNuzjhegQGXtrVGlNuhZqgzAC4KX4rVaDYqo4i(6jefXYnN5PXHtgJh9cYisYBWn4amWGIy5MZ804WjJXJEb5l80qEHybOvW4POxWLtQJziJaRd6dNVEcHXioanxeCkl5OH6DQdCsl5xqiTFNFxdYeuKRTTjL10kXUA7TbXLv0StDmie(XadioanxeCkRipWnJ1hURw5xMGICTTnPSMwj2vBVniUbzc6wz5MZ8nwIDnNENAf5bEMZ2kl3CMpCxTY1khKOmNTvj)ccP9787AGgrsEdoiqZkl3CMvKh4MX6d3vR8lRw5Gcgpf9cUCsDmdzKKBmApf9c0M(c(aUebHUJaj64RNq4XfKBcCsLDJXkSoQDwdLpGsNwGQJEbmWaDhbsuMfrEGR3PoWjTACdGNLCOalYA0seVqgOGXY1d131u)Cr1lZIaUAR3grqjSfQQxEh41JHdv1JixnUE54eOEWg1J4aGgaVEmgzUGXtrVGlNuhZqgXExJgr3YHseFZfPbe)hqyIVEcHhHBiqKpCxTY1ZnXDzc4SgsvWy56HYoQEzweWvB92iQESfQQxoobQxovpUdlvFGt1tacbFC9YXPaNq1prRu927AAa86L3b(Yf1JXiRFr1dfG7I6Htac5gZ4CbJNIEbxoPoMHmYHZH6Heqhlc4QLVEcHaec(yEHWtqZkSoQDwdLpGsNwGQJEbwt7AuRCq(glXUMtVtTI8apZzBnTRrTYb5d3vRCTYbjkNWDeC64fctfmEk6fC5K6ygYihHqEqkn7ci9z3dj(sJtgshocofheM4RNqG1rTZAO8bu60cuD0lWkpuBKpcH8GuA2fq6ZUhsA1g5OtdBaCgyy2WXdnIK8gCdcXsfmwUEOSJQhBSe7AU6xq9PDnQvoOEg7ZGq1pB0f1JbGkOxphWq3vVCQEhr1dFBa86JTE71UEzweWvB9oqvVARhSr94oSu9y4UALxpJCtCxUEO8R86TyOE9ZfvVm4u9mQnccKly8u0l4Yj1XmKrUXsSR507uRipW5RNqG1rTZAO8bu60cuD0lWkps7AuRCq(WD1kxZACfDzoBRmoCdbImbGLmRDdGRpCxTYVmbCwdPyGH0Ug1khKpCxTY1khKOCc3rWPJximbDRmMhHBiqKpCoupKa6yraxTzc4SgsXadHBiqKpCxTY1ZnXDzc4SgsXadPDnQvoiF4COEib0XIaUAZisYBWX7aq3kJ5bIdqZfbNYboPrBeeitqrU22MumWqALyxT92G4geYaq3kJ5bDhbsuM1SRsVtDGtAcqsJZsouGfXadPDnQvoiZA2vP3PoWjnbiPXzej5n44DaOxWy5655M17k1vVJO65S5R(d02u9bov)cO6L3bE9MvoDr9YiduLRhk7O6LJtG6vJBa86N(feQ(a3b1BXq96v0StDu)IQhSr9xqUjWjv9Y7aF5I6DW46TyOEUGXtrVGlNuhZqgrYrdjLEUiTI8aNV04KH0HJGtXbHj(6jeK3knblbISRuxMZ2kJdhbNIC0sKowTQPbtRe7QT3gexwrZo1bdmWJli3e4Kk7gJ10kXUA7TbXLv0StDWlKKTwY5F9ztaf0lySC98CZ6bB9UsD1lVnM6vnvV8oWBq9bovpG4)OE(bTJV65oQEE(juv)cQNDVRE5DGVCr9oyC9wmupxW4POxWLtQJziJi5OHKspxKwrEGZxpHG8wPjyjqKDL6YnGx(bnOeYBLMGLar2vQlR4qE0lWAALyxT92G4YkA2Po4fsYwl58V(SjGQGXtrVGlNuhZqg5WD1kxZACfD81tiW6O2znu(akDAbQo6fynTsSR2EBqCzfn7uh8czGcgpf9cUCsDmdzekHVnaUgr2OwYbk(6jeyDu7SgkFaLoTavh9cSMwj2vBVniUSIMDQdEHWpRNnzm6WrWP4YhohQhsa9flsAqiwOGXY1df2bE9yms(QVN1d2OE3GixnUE1ci(QN7O6LzraxT1lVd86XwOQEo7CbJNIEbxoPoMHmYHZH6Heqhlc4QLVEcjCdbI8H7QvUEUjUltaN1qkRW6O2znu(akDAbQo6fyLLBoZ3yj21C6DQvKh4zo7cgpf9cUCsDmdzKd3vRCTYbjIVEcHhSCZz(WD1kxRCqIYC2wNnC8qJijVb3GqGAmhUHar(4ydcn5Gtzc4SgsvWuWy56LDbqPZMs1Fb3CwV8oWR3SYju92OEly8u0l4Yj1XmKrS3OxqbJNIEbxoPoMHmcRzxLEYHgZxpHWYnN5BSe7Ao9o1kYd8mNDbJNIEbxoPoMHmclHocnSbW5RNqy5MZ8nwIDnNENAf5bEMZUGXtrVGlNuhZqgz2iI1SRIVEcHLBoZ3yj21C6DQvKh4zo7cgpf9cUCsDmdzehKOlqUrNCJHVEcHLBoZ3yj21C6DQvKh4zo7cMcgpf9cUCsDmdzeUJ0Dqs8rZjLcnWLiiPXjZgOf0jnRXVGVEcHhxqUjWjv2ngRW6O2znu(akDAbQo6fyLhSCZz(glXUMtVtTI8apZzBLaec(4SIMDQdEHWpOvW4POxWLtQJziJWDKUdsIpGlrqC(7WDKF65cc9o12RCcXxpHWdwU5mF4UALRvoirzoBRPDnQvoiFJLyxZP3PwrEGNrKK3GBqMGwbJLRFdCcjVpQE5DGxp2cv17r9dyjMR)cpn8QFr1ZKLyUE5DGxVBUT(rn7QQNZoxW4POxWLtQJziJWDKUdsIpGlrq8dhwhqNg583I0Pf5g(6jefXYnNzKZFlsNwKB0kILBoZQvoGbguel3CMtlqXLIgws3GHAfXYnNzoBRHJGtrgNCtGNTtXG8BaRHJGtrgNCtGNTtbVq4h0yGbEOiwU5mNwGIlfnSKUbd1kILBoZC2wzSIy5MZmY5VfPtlYnAfXYnN5l80qEHmGLGsmbngHIy5MZmRzxLEN6aN0eGKgN5SzGHzdhp0isYBWnOfGg0TYYnN5BSe7Ao9o1kYd8mIK8gC8c1kySC98SeAC9OLdoUzC9iodv)oRpW5Ky7ztQ6L8a)QNLmRCEM6HYoQ(5IQNNdm0Ev1NqDuW4POxWLtQJziJWDKUdsIpGlrqKgR8thUPpjhuWy56HkA6CMO(PBmSEAy9Zfvp35SgQ(oiPJNPEOSJQxEh41JnwIDnx97SEOI8apxW4POxWLtQJziJWDKUds64RNqy5MZ8nwIDnNENAf5bEMZMbgMnC8qJijVb3GdaTcMcglxpJo)rOoO6HcYDeirxbJNIEbxMUJaj6ygYiPfKiqG8Gu6PXLi(6jecqi4JZrlr6y1so)Zltw5bl3CMVXsSR507uRipWZC2wzmpuBKtlirGa5bP0tJlrAwoeihDAydGBLhEk6fKtlirGa5bP0tJlr5gONMgoEWadtoJrJOeUJGt6OLObHNuzjN)HEbJNIEbxMUJaj6ygYiSMDv6DQdCstasAmF9ecps7AuRCq(WD1kxZACfDzoBRPDnQvoiFJLyxZP3PwrEGN5SzGHzdhp0isYBWnieMGwbJNIEbxMUJaj6ygYiW5CKQDGENAN)i0g4fmEk6fCz6ocKOJziJm3e3rkTZFeQdsZsUeF9ecJpBYy0HJGtXLpCoupKa6lwKeVqgGbgqER0eSeiYUsD5gWlpbnOBLhPDnQvoiFJLyxZP3PwrEGN5STYdwU5mFJLyxZP3PwrEGN5STsacbFCwrZo1bVq4h0ky8u0l4Y0DeirhZqgXMd1ZXnaUM14xWxpHC2KXOdhbNIlF4COEib0xSijEHmadmG8wPjyjqKDL6YnGxEcAfmEk6fCz6ocKOJziJe4KMdWUCaLEUOeXxpHWYnNzeLgAO70ZfLOmNndmWYnNzeLgAO70ZfLiDA5abHYx4PHdYe0ky8u0l4Y0DeirhZqgb122gs3a9z7jQGXtrVGlt3rGeDmdze5lYOGLAGgr3cCqI4RNqs7AuRCq(glXUMtVtTI8apJijVb3GwIbgMnC8qJijVb3Gmb1ky8u0l4Y0DeirhZqgrIKw0y9o1gUuR0ke5shF9ecbie8XdAbOzLLBoZ3yj21C6DQvKh4zo7cglxpuWRrvpJIC7gaVEgPXLOR(5IQN4FkXfu9ihaNQFr1pSnM6z5MZJV67z927DnRHY1ZOBK7JV6d046JTE4uuFGt1Bw50f1N21Ow5G6z9Ju1VG6Dy924SgQEcqsnD5cgpf9cUmDhbs0XmKrqKB3a46PXLOJVEcz2WXdnIK8gCdYu2smWaJzC4i4uKXj3e4z7uWludAmWq4i4uKXj3e4z7umiKbGg0TYypfnSKMaKutheMyGHzdhp0isYBWX7aweOdDgyGXHJGtroAjshR2of6bGgV8dAwzSNIgwstasQPdctmWWSHJhAej5n441cwa6qVGPGXY1JfKBc86T4DnQvo4ky8u0l4YxqUjW1j1XmKrG1rTZAi(aUeb5Wv6ahrh(Au8bRB4iiPDnQvoiF4UALRvoir5eUJGtNEI8u0lWn8cHPSf1s8bfmzSju98SoQDwdvWy565zDqF413Z6Lt17iQ(KBB3a41VG6HkhKO6t4ocoD56HcIJmJRNLMlIQF2OlQx5GevFpRxovpUdlvpyRx2goECHBgsO6z5I6HkhnSEmCxTYRVb1VifHQp26Htr9mko7Gdr1ZzxpJbB988(feQEg9787Aa0ZfmEk6fC5li3e46K6ygYiW6G(W5RNqympG1rTZAO8HR0boIo81OyGbEeUHarg0WXJlCZqcLjGZAiL1WneiYkhnuF4UALNjGZAif0TMwj2vBVniUSIMDQdEzYkpqCaAUi4uwYrd17uh4KwYVGqA)o)UgKjOixBBtQcgpf9cU8fKBcCDsDmdzKJSV(ky8u0l4YxqUjW1j1XmKrS31Or0TCOeX3CrAaX)beM4J4)a5AxA5abelan(G67AQFUO6XWD1kxImQ6zUEmCxTYVa1dP65ag6U6Lt17iQEND5I6JT(KBx)cQhQCqIQpH7i40LRNrlWmUE54eOEgzdu1dfs(qaDx99vVZUCr9XwpIdu)Yf5cgpf9cU8fKBcCDsDmdzKd3vRCjYO4RNqiaHGpMxiwaAwjaHGpoROzN6GximbnR8awh1oRHYhUsh4i6WxJYAALyxT92G4YkA2Po4LjRkILBoZZgO0YjFiGUlJijVb3GmvW4POxWLVGCtGRtQJziJaRJAN1q8bCjcYHR0PvID12BdIJpyDdhbjTsSR2EBqCzfn7uh8cXc8zXq96reuKRrKebcEM6HkhKO69OEZkVElgQxp746v005mrUGXY1BXq96reuKRrKebcEM6HkhKO6xGzC9S0Cru9Zg0hoHU67z9YP6XDyP6Tr9I6yC9On8OxqUGXtrVGlFb5MaxNuhZqgbwh1oRH4d4seKdxPtRe7QT3gehFW6gocsALyxT92G4YkA2Pogect81tiW6O2znuM7iTnQxuhJ1On8OxqbJLRhQCqIQxXHAa86XglXUMR(fvVZUWs1h4i6WxJkxW4POxWLVGCtGRtQJziJC4UALRvoir81tiW6O2znu(Wv60kXUA7TbXzLXW6O2znu(Wv6ahrh(AumWal3CMVXsSR507uRipWZisYBWXleMYdWadNnzm6WrWP4YhohQhsa9flsIxiwWAAxJALdY3yj21C6DQvKh4zej5n44LjOb9cglx)OCiq9isYBqdGxpu5GeD1ZsZfr1h4u9ZgoEupbux99SESfQQx(cy0e1Zs1JixnU(guF0suUGXtrVGlFb5MaxNuhZqg5WD1kxRCqI4RNqG1rTZAO8HR0PvID12BdIZ6SHJhAej5n4gmTRrTYb5BSe7Ao9o1kYd8mIK8gCfmfmwUESGCtGtQ6zuB4rVGcglxpp3SESGCtGpcSoOp86DevpNnF1ZDu9y4UALFbQhs1hB9SeGMDu)eTs1h4u92(DnSu9SlG7Q3bQ6zKnqvpui5db0D1tWsG67z9YP6DevVh1l58F9wmuVEgprRu9bovVnIsReRh1ZZpHkONly8u0l4YxqUjWjfZqg5WD1k)cupK4RNqyml3CMVGCtGN5SzGbwU5mdRd6dpZzd9cglxpJSb9HxVh1ZpMR3IH61lVd8LlQhQWQFK6TaZ1lVd86HkS6L3bE9y4COEibQxMfbC1wpl3CwpND9XwVd72Q6VvIQ3IH61l3VGQ)6GZJEbxUGXtrVGlFb5MaNumdzKKBmApf9c0M(c(aUebz2G(W5RNqy5MZ8HZH6Heqhlc4QnZzBnTsSR2EBqCzfn7uhdczGcglxpJU526pFs1hB9Zg0hE9EuVfyUElgQxV8oWRN4FpfMX1BH6dhbNIlxpJXCjQE)QF5IRvu9xqUjWZqVGXtrVGlFb5MaNumdzKKBmApf9c0M(c(aUebz2G(W5RNqoBYy0HJGtXLpCoupKa6lwKeelynTsSR2EBqC8cXcfmwUEgzd6dVEpQ3cmxVfd1RxEh4lxupuHXx9wI56L3bE9qfgF17av98u9Y7aVEOcREFgeQEEwh0hEbJNIEbx(cYnboPygYij3y0Ek6fOn9f8bCjcYSb9HZxpHKwj2vBVniUSIMDQJbHWeuIXHBiqKvezti9fipC4KuMaoRHuwz5MZmSoOp8mNn0lySC9mYfvVnIGs2EKW5R(HezxpJSbQ6HcjFiGUREo76xq9bovVnQLC046dhbNI6vCu9XwpyRhd3vR865zDotuW4POxWLVGCtGtkMHmYH7Qv(fOEiXxpHyiyjZGwAaRkILBoZZgO0YjFiGUlJijVb3GmznCeCkYrlr6y1QMGsisYBWXlpvWy56HYSRp265x9HJGtXv)qISRNZUEgzdu1dfs(qaDx9SJRpnozAa86XWD1k)cupKYfmEk6fC5li3e4KIziJC4UALFbQhs8LgNmKoCeCkoimXxpHOiwU5mpBGslN8Ha6UmIK8gCdYK1ZMmgD4i4uC5dNd1djG(Ifjnie(znCeCkYrlr6y1QMGsisYBWXlpvWy56Hc7aF5I6HkISju9ybYdhojvVdu1ZV6zuoy4v)oRFuJRO6Bq9bovpgURw5x9DuFF1lFrbE9CxdGxpgURw5xG6Hu9lOE(vF4i4uC5cgpf9cU8fKBcCsXmKroCxTYVa1dj(6jeEeUHarwrKnH0xG8WHtszc4Sgsz15pc1bLznUI0nqh4K(WD1k)Yihmec)SE2KXOdhbNIlF4COEib0xSiji8RGXY1Zixu92OErDmUE0gE0lGV65oQEmCxTYVa1dP6xyju9yXIKQNjOxV8oWRhkKNVEhU3GlQNZU(yR3c1hocofhF1pa0RVN1ZiHcRVV6rCaqdGx)oN1Z4fuVdgxVlTCGO(DwF4i4uCqNV6xu98d61hB9so)3sn)r1JTqv9e)he46fuV8oWRNNdqW2HZ2Mogx)cQNF1hocofx9m2c1lVd86hTdmONly8u0l4YxqUjWjfZqg5WD1k)cupK4RNqG1rTZAOm3rABuVOogRrB4rVaRmwrSCZzE2aLwo5db0Dzej5n4gKjgyiCdbISCYTxGKFbHYeWznKY6ztgJoCeCkU8HZH6HeqFXIKgeIfyGbN)iuhuUbeSD4STPJXzc4SgszLLBoZ3yj21C6DQvKh4zoBRNnzm6WrWP4YhohQhsa9flsAqi8JzN)iuhuM14ks3aDGt6d3vR8ltaN1qkOxW4POxWLVGCtGtkMHmYHZH6HeqFXIK4RNqoBYy0HJGtXXle(XmJz5MZSnIKivhE0liZzZadSCZzoWjnAJGazoBgyaXbO5IGtzFO7O(03Yz0tKdxIarMGICTTnPSMwGIRJSIiBcPvoC4e6YihmKxiwuOxW4POxWLVGCtGtkMHmYH7Qv(fOEiXxpHOiwU5mpBGslN8Ha6UmIK8gCdcHjgyiTRrTYb5BSe7Ao9o1kYd8mIK8gCdYeuZQIy5MZ8SbkTCYhcO7YisYBWnyAxJALdY3yj21C6DQvKh4zej5n4kySC9y4UALFbQhs1hB9iAIOdVEgzdu1dfs(qaDx9oqvFS1tGJdr1lNQp5G6tocnU(fwcvVx)KZyQNrcfwFdIT(aNQhq8Fup2cv13Z6T37AwdLly8u0l4YxqUjWjfZqgXExJgr3YHseFZfPbe)hqyQGXtrVGlFb5MaNumdze4MDLynUI4RNq4bIdqZfbNY(q3r9PVLZONihUebImbf5ABBszLLBoZ2eAUipiLgwQbx(cpnKxi8ZAAbkUoY2eAUipiLgwQbxg5GH8cHj(bLySfHrKwGIRJSIiBcPvoC4ektaN1qkMtlqX1rwrKnH0khoCcLroyi0ly8u0l4YxqUjWjfZqgbUzxjwJRi(6jeehGMlcoL9HUJ6tFlNrproCjcezckY122KYkl3CMTj0CrEqknSudU8fEAiVq4NvgNwGIRJSnHMlYdsPHLAWLroyiZPfO46iRiYMqALdhoHYihme68cHjEQGXtrVGlFb5MaNumdzKd3vR8lq9qQGPGXY1ZiBqF4e6ky8u0l4YZg0hoZqg5mDI0oqPvDI4RNqoBYy0HJGtXLpCoupKa6lwK0G8KvEWYnN5d3vRCTYbjkZzBLLBoZNPtK2bkTQtugrsEdUbNnC8qJijVbNvwU5mFMorAhO0Qorzej5n4gKXmXCALyxT92G4GoJGPmuRGXtrVGlpBqF4mdzeyDu7SgIpGlrqUHTTgXzhCiIpyDdhbrYVGqA)o)UgOrKK3GJxOXad8iCdbImOHJhx4MHektaN1qkRHBiqKvoAO(WD1kptaN1qkRSCZz(WD1kxRCqIYC2mWWztgJoCeCkU8HZH6HeqFXIK4fcpXhuWKXMq1ZZ6O2znu9ZfvpJIZo4quUESHTD9koudGxppVFbHQNr)o)Ugu)IQxXHAa86HkhKO6L3bE9qLJgwVdu1d26LTHJhx4MHekxWy56HYnr21ZzxpJIZo4qu99S(oQVV6D2LlQp26rCG6xUixW4POxWLNnOpCMHmcIZo4qeF9ecpG1rTZAO8nST1io7GdrwdhbNIC0sKowTQjOeIK8gC8Ytwr0erhUZAOcgpf9cU8Sb9HZmKrokHOqhuch0qroQGXY1ZZZzIwTr0a41hocofx9bUh1lVnM6nnSu9ZfvFGt1R4qE0lO(DwpJIZo4qu9iAIOdVEfhQbWR32bksQt5cgpf9cU8Sb9HZmKrqC2bhI4lnoziD4i4uCqyIVEcHhW6O2znu(g22AeNDWHiR8awh1oRHYChPTr9I6ySgTHh9cSE2KXOdhbNIlF4COEib0xSijEHmG1WrWPihTePJvRAIxim2smZ4byePvID12BdId6q3kIMi6WDwdvWy56zu0erhE9mko7Gdr1toYmU(EwFh1lVnM6j(3Uru9koudGxp2yj21C56HQT(a3J6r0erhE99SESfQQhofx9iYvJRVb1h4u9aI)J6T0Lly8u0l4YZg0hoZqgbXzhCiIVEcHhW6O2znu(g22AeNDWHiRisYBWnyAxJALdY3yj21C6DQvKh4zej5n4yMjOznTRrTYb5BSe7Ao9o1kYd8mIK8gCdcXswdhbNIC0sKowTQjOeIK8gC8M21Ow5G8nwIDnNENAf5bEgrsEdoMTubJNIEbxE2G(WzgYiSgpnuBVYveIVEcHhW6O2znuM7iTnQxuhJ1On8OxG1ZMmgD4i4uC8cHFfmEk6fC5zd6dNziJqW2xIqEqfmfmwU(r5AJIqxbJNIEbxMLRnkMHmYHZH6HeqFXIK4RNqoBYy0HJGtXXlKbyMXHBiqKHB2vI14kktaN1qkRo)rOoOSnHMlYdkJCWqEHmGv796OxGM1tdHEbJNIEbxMLRnkMHmYriKhKsZUasF29qIVEcjTRrTYb5JqipiLMDbK(S7HuoH7i40PNipf9cCdVqgiBrTubJNIEbxMLRnkMHmcCZUsSgxrfmEk6fCzwU2OygYiSEA4foRieHqa]] )


end
