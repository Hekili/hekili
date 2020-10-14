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


    spec:RegisterPack( "Subtlety", 20201014, [[da1J0bqiKcpIOOnrj9jfLOgfcYPafTkeu8keQzHu5wkkLDjQFPqmmqHJHqwgLONHuLPHuvxtrHTHuKVPaW4uusNtbqRJOqAEkq3tr2hsP)PakPdIGkTqfspubOjQOOlQakXgrqvFurjIrQak1jjkeRur1lvuIuZebv4Mefk7Ks4NiOIgQIs1srqPNcXujkDvfq1wvafFvrjCwfLizVe(lPgSQomvlgrpwKjtYLrTzq(mOA0q60sTAIcvVwbnBkUnr2nWVvA4uQJRaYYH65QmDHRJKTJaFNOA8efCEfQ1JuuZhuA)swqKqwbIYdwyHLWWsyqemiI(zISKi6pJbOajgBZceBpn0HZceGlXceekYWWXybITp2SUsiRa5wkCIfiOryFYOJmc8oqPiZPvAKRLOmE0liHDOyKRLsJiqiPAtiJaeKceLhSWclHHLWGiyqe9Zezjr0Fg0xG4ub6IfiiT0akqqBLIbcsbIIVKarM1JqrggogxpHDHtX1CzwpHZuSKmUEIOpD1BjmSegcetFXjKvGCb7MaLvczfwqKqwbcdCsdReJkqs4oyC7cecvpjfeu(c2nbAMYUEyHTEskiOmboOp0mLD9WuG4POxGa5qD1k)cCpKfHWclfYkqyGtAyLyubsc3bJBxGqsbbLpukCpKb6yXaxTzk76TwFALixT92G4YkgQtDu)Gt1BPaXtrVabsYngTNIEbAtFHaX0xObUelqGAqFOIqyb9eYkqyGtAyLyubsc3bJBxGC2SXOdhdNJlFOu4Eid0xSyP6NQN(1BT(0krUA7TbXvpTt1tFbINIEbcKKBmApf9c0M(cbIPVqdCjwGa1G(qfHWc6lKvGWaN0WkXOcKeUdg3UajTsKR2EBqCzfd1PoQFWP6jQ(zREcvF4ggezfZ2mwFb2dholLzGtAyv9wRNKccktGd6dntzxpmfiEk6fiqsUXO9u0lqB6leiM(cnWLybcud6dveclMHqwbcdCsdReJkq8u0lqGCOUALFbUhYcKeUdg3UarXKuqqzOgO0YzFiGVlJzjVbx9dwpr1BT(ZMngD4y4CC5dLc3dzG(Iflv)Gt1tV6TwF4y4CKJwI1XQvnx)SvpML8gC1tB90KajnozyD4y4CCcliseclOjHSceg4KgwjgvGKWDW42fi0O(WnmiYkMTzS(cShoCwkZaN0WQ6TwVtZmUdotACfRBGoqz9H6Qv(LXoyy9t1tV6Tw)zZgJoCmCoU8HsH7HmqFXILQFQE6jq8u0lqGCOUALFbUhYIqyXaqiRaHboPHvIrfijChmUDbcboUDsdNPowBJ7f3XynEdp6fuV16ju9kMKcckd1aLwo7db8Dzml5n4QFW6jQEyHT(WnmiYYz3Ebs(fmoZaN0WQ6Tw)zZgJoCmCoU8HsH7HmqFXILQFWP6PF9WcB9onZ4o4Cdyc6WjBthJZmWjnSQER1tsbbLVXsKR50lKwXEGMPSR3A9NnBm6WXW54YhkfUhYa9flwQ(bNQNE1tC9onZ4o4mPXvSUb6aL1hQRw5xMboPHv1dtbINIEbcKd1vR8lW9qweclMvHSceg4KgwjgvGKWDW42fiNnBm6WXW54QN2P6Px9expHQNKcckBJzjw1Hh9cYu21dlS1tsbbLduwJ3iyqMYUEyHTEmfGHwmCo7dDh3N(wkJgc7WLyqK5bIQTTzv9wRpTafvhzfZ2mwRC4Wz8LXoyy90ov)aOEykq8u0lqGCOu4Eid0xSyjriSyakKvGWaN0WkXOcKeUdg3UarXKuqqzOgO0YzFiGVlJzjVbx9dovpr1dlS1N21Ow5G8nwICnNEH0k2d0mML8gC1py9enR1BTEftsbbLHAGslN9Ha(UmML8gC1py9PDnQvoiFJLixZPxiTI9anJzjVbNaXtrVabYH6Qv(f4EilcHfebdHSceg4KgwjgvGaTynGLHqybrcepf9cei27A0y(wkCIfHWcIisiRaHboPHvIrfijChmUDbcnQhtbyOfdNZ(q3X9PVLYOHWoCjgezEGOABBwvV16jPGGY2mgAXEWknbCdU8fEAy90ovp9Q3A9PfOO6iBZyOf7bR0eWn4YyhmSEANQNi6v)SvpHQFawpHP(0cuuDKvmBZyTYHdNXzg4KgwvpX1NwGIQJSIzBgRvoC4moJDWW6HPaXtrVabcCZUsKgxXIqybrwkKvGWaN0WkXOcKeUdg3UabtbyOfdNZ(q3X9PVLYOHWoCjgezEGOABBwvV16jPGGY2mgAXEWknbCdU8fEAy90ovp9Q3A9eQ(0cuuDKTzm0I9GvAc4gCzSdgwpX1NwGIQJSIzBgRvoC4moJDWW6Hz90ovpr0KaXtrVabcCZUsKgxXIqybr0tiRaXtrVabYH6Qv(f4EilqyGtAyLyuricbcFhds8jKvybrczfimWjnSsmQajH7GXTlqyaJHpohTeRJvl5Yq90wpr1BTEAupjfeu(glrUMtVqAf7bAMYUER1tO6Pr9QnYPfKyqG9GvAiJlXAskmihDAydGxV16Pr9Ek6fKtliXGa7bR0qgxIZnqdzA4Or9WcB9qugJgZjuhdN1rlX1py9WtQSKld1dtbINIEbcK0csmiWEWknKXLyriSWsHSceg4KgwjgvGKWDW42fi0O(0Ug1khKpuxTY1KgxXxMYUER1N21Ow5G8nwICnNEH0k2d0mLD9WcB9qnC0qJzjVbx9dovprWqG4POxGaH0SRsVq6aL1mGLglcHf0tiRaXtrVabcCkhRAhOxiTtZmEdubcdCsdReJkcHf0xiRaHboPHvIrfijChmUDbcHQ)SzJrhogohx(qPW9qgOVyXs1t7u9wwpSWwp2BLMjGbr2vQl3G6PTEAcg1dZ6TwpnQpTRrTYb5BSe5Ao9cPvShOzk76TwpnQNKcckFJLixZPxiTI9antzxV16zaJHpoRyOo1r90ovp9GHaXtrVabc0MOowPDAMXDWAs2LeHWIziKvGWaN0WkXOcKeUdg3Ua5SzJrhogohx(qPW9qgOVyXs1t7u9wwpSWwp2BLMjGbr2vQl3G6PTEAcgcepf9cei2u4gACdGRjn(fIqybnjKvGWaN0WkXOcKeUdg3UaHKcckJ50qdFNgAXjotzxpSWwpjfeugZPHg(on0ItSoTuGGX5l80W6hSEIGHaXtrVabsGYAka5sbuAOfNyriSyaiKvG4POxGab322gw3a9z7jwGWaN0WkXOIqyXSkKvGWaN0WkXOcKeUdg3UajTRrTYb5BSe5Ao9cPvShOzml5n4QFW6Nr9WcB9qnC0qJzjVbx9dwprZQaXtrVabI8fBueWnqJ5BboiXIqyXauiRaHboPHvIrfijChmUDbcdym8X1py90hg1BTEskiO8nwICnNEH0k2d0mLTaXtrVabIelT4X6fsBOsTsRWSlDIqybrWqiRaHboPHvIrfijChmUDbcudhn0ywYBWv)G1tuEg1dlS1tO6ju9HJHZrgLDtGMTtr90w)ScJ6Hf26dhdNJmk7ManBNI6hCQElHr9WSER1tO69u0eWAgWsnF1pvpr1dlS1d1WrdnML8gC1tB9woaRhM1dZ6Hf26ju9HJHZroAjwhR2ofAlHr90wp9Gr9wRNq17POjG1mGLA(QFQEIQhwyRhQHJgAml5n4QN26Pp9RhM1dtbINIEbcem72naUgY4s8jcriqumKtzcHSclisiRaXtrVabYWonuGWaN0WkXOIqyHLczfimWjnSsmQazTfihhcepf9ceie442jnSaHa3qXceskiO8z6eRDGsR6eNPSRhwyR)SzJrhogohx(qPW9qgOVyXs1t7u90KaHahRbUelqoGsNwGQJEbIqyb9eYkqyGtAyLyubINIEbcKKBmApf9c0M(cbIPVqdCjwGKuNiewqFHSceg4KgwjgvGKWDW42fixWUjqzv2ngbINIEbcemfq7POxG20xiqm9fAGlXcKly3eOSseclMHqwbcdCsdReJkqs4oyC7cKZMngD4y4CC5dLc3dzG(Iflv)G1tt1BTEOgoAOXSK3GREARNMQ3A9Kuqq5Z0jw7aLw1joJzjVbx9dwp8Kkl5Yq9wRpTsKR2EBqC1t7u90V(zREcvF0sC9dwprWOEywpHPElfiEk6fiqotNyTduAvNyriSGMeYkqyGtAyLyubYAlqooeiEk6fiqiWXTtAybcbUHIfi24EXDmwJ3WJEb1BT(ZMngD4y4CC5dLc3dzG(IflvpTt1BPaHahRbUelqOowBJ7f3XynEdp6ficHfdaHSceg4KgwjgvGKWDW42fie442jnCM6yTnUxChJ14n8OxGaXtrVabsYngTNIEbAtFHaX0xObUelqUGDtGQtQteclMvHSceg4KgwjgvGS2cKJdbINIEbcecCC7KgwGqGBOybILZOEIRpCddImbn8fNzGtAyv9eM6Teg1tC9HByqKL8lySEH0hQRw5xMboPHv1tyQ3syupX1hUHbr(qD1kxdTjQlZaN0WQ6jm1B5mQN46d3WGi7gpH7yCMboPHv1tyQ3syupX1B5mQNWupHQ)SzJrhogohx(qPW9qgOVyXs1t7u90VEykqiWXAGlXcKly3eO6afZh6AuIqyXauiRaHboPHvIrfijChmUDbcdym8Xzfd1PoQFWP6jWXTtA48fSBcuDGI5dDnkbINIEbcKKBmApf9c0M(cbIPVqdCjwGCb7MavNuNiewqemeYkqyGtAyLyubsc3bJBxG40mJ7GZGgoACAcyaC2bjoZaN0WQ6TwpnQNKcckdA4OXPjGbWzhK4mLD9wRpTsKR2EBqCzfd1PoQN26jQER1tO6pB2y0HJHZXLpukCpKb6lwSu9dwVL1dlS1tGJBN0WzQJ124EXDmwJ3WJEb1dZ6TwpHQpTRrTYb5BSe5Ao9cPvShOzml5n4QFWP6Px9WcB9eQENMzChCg0WrJttadGZoiXzSdgwpTt1Bz9wRNKcckFJLixZPxiTI9anJzjVbx90wp9Q3A90O(ly3eOSk7gt9wRpTRrTYb5d1vRCTYbjoNqDmC(0qypf9cCt90ovpmYdW6Hz9WuG4POxGabtzhuywecliIiHSceg4KgwjgvGKWDW42fiykadTy4CwXEGAgRpuxTYVmpquTTnRQ3A9QnYhBF9LJonSbWR3A9QnYhBF9LXSK3GR(bNQ3Y6TwFALixT92G4QN2P6TuG4POxGaj5gJ2trVaTPVqGy6l0axIfiqnOpuriSGilfYkqyGtAyLyubsc3bJBxGK21Ow5G8nwICnNEH0k2d0mML8gC1p4u9wwV16tRe5QT3gex90ovVL1BTEmfGHwmCohOSgVrWGmpquTTnReiEk6fiqsUXO9u0lqB6leiM(cnWLybcud6dvecliIEczfimWjnSsmQajH7GXTlqsRe5QT3gex9t17GwYtOogoR0jBbINIEbcKKBmApf9c0M(cbIPVqdCjwGa1G(qfHWcIOVqwbcdCsdReJkqs4oyC7cK0krUA7TbXLvmuN6O(bNQNO6Hf26HA4OHgZsEdU6hCQEIQ3A9PvIC12BdIREANQNEcepf9ceij3y0Ek6fOn9fcetFHg4sSabQb9HkcHfendHSceg4KgwjgvGKWDW42fiNnBm6WXW54YhkfUhYa9flwQ(P6PF9wRpTsKR2EBqC1t7u90xG4POxGaj5gJ2trVaTPVqGy6l0axIfiqnOpuriSGiAsiRaHboPHvIrfijChmUDbcdym8Xzfd1PoQFWP6jWXTtA48fSBcuDGI5dDnkbINIEbcKKBmApf9c0M(cbIPVqdCjwGqs1gLiewq0aqiRaHboPHvIrfijChmUDbcdym8Xzfd1PoQN2P6jAg1tC9mGXWhNXmCgiq8u0lqG44KdyDSymdcriSGOzviRaXtrVabIJtoG12uMJfimWjnSsmQiewq0auiRaXtrVabIPHJgNwgNsbxIbHaHboPHvIrfHWclHHqwbINIEbceshUEH0bUtdpbcdCsdReJkcriqSXCALi9qiRWcIeYkq8u0lqG422MXA7TVfiqyGtAyLyuriSWsHScepf9ceixWUjqfimWjnSsmQiewqpHSceg4KgwjgvG4POxGarYXdzLgAXAf7bQaXgZPvI0d9XPfOobcrZqeclOVqwbcdCsdReJkq8u0lqGCMoXAhO0QoXceBmNwjsp0hNwG6eiejcHfZqiRaHboPHvIrfijChmUDbcMcWqlgoNLC8q9cPduwl5xWyTFNFxdY8ar122SsG4POxGa5qD1kxtACfFIqybnjKvGWaN0WkXOceGlXceNMpuh7NgAbHEH02RCglq8u0lqG408H6y)0qli0lK2ELZyricbcud6dviRWcIeYkqyGtAyLyubsc3bJBxGC2SXOdhdNJlFOu4Eid0xSyP6hSEAQER1tJ6jPGGYhQRw5ALdsCMYUER1tsbbLptNyTduAvN4mML8gC1py9qnC0qJzjVbx9wRNKcckFMoXAhO0QoXzml5n4QFW6ju9evpX1NwjYvBVniU6Hz9eM6jkpRcepf9ceiNPtS2bkTQtSiewyPqwbcdCsdReJkqwBbYXHaXtrVabcboUDsdlqiWnuSarYVGXA)o)UgOXSK3GREARhg1dlS1tJ6d3WGidA4OXfUziJZmWjnSQER1hUHbrw54H6d1vR8mdCsdRQ3A9Kuqq5d1vRCTYbjotzxpSWw)zZgJoCmCoU8HsH7HmqFXILQN2P6PjbcbowdCjwGCdBBnMYoOWSiewqpHSceg4KgwjgvGKWDW42fi0OEcCC7KgoFdBBnMYoOWC9wRpCmCoYrlX6y1QMRF2QhZsEdU6PTEAQER1JzimFOoPHfiEk6fiqWu2bfMfHWc6lKvG4POxGa54eMdDWjuqpquSaHboPHvIrfHWIziKvGWaN0WkXOcepf9ceiyk7GcZcKeUdg3UaHg1tGJBN0W5ByBRXu2bfMR3A90OEcCC7KgotDS2g3lUJXA8gE0lOER1F2SXOdhdNJlFOu4Eid0xSyP6PDQElR3A9HJHZroAjwhRw1C90ovpHQFg1tC9eQElRNWuFALixT92G4QhM1dZ6TwpMHW8H6KgwGKgNmSoCmCooHfejcHf0KqwbcdCsdReJkqs4oyC7ceAupboUDsdNVHTTgtzhuyUER1JzjVbx9dwFAxJALdY3yjY1C6fsRypqZywYBWvpX1temQ3A9PDnQvoiFJLixZPxiTI9anJzjVbx9dov)mQ3A9HJHZroAjwhRw1C9Zw9ywYBWvpT1N21Ow5G8nwICnNEH0k2d0mML8gC1tC9ZqG4POxGabtzhuyweclgaczfimWjnSsmQajH7GXTlqOr9e442jnCM6yTnUxChJ14n8Oxq9wR)SzJrhogohx90ovp9eiEk6fiqinEAO2ELRySiewmRczfiEk6fiqyc6lXypybcdCsdReJkcriqsQtiRWcIeYkqyGtAyLyubsc3bJBxGqJ6jPGGYhQRw5ALdsCMYUER1tsbbLpukCpKb6yXaxTzk76Twpjfeu(qPW9qgOJfdC1MXSK3GR(bNQNE5ziq8u0lqGCOUALRvoiXceQJ1leKgEsjSGiriSWsHSceg4KgwjgvGKWDW42fiKuqq5dLc3dzGowmWvBMYUER1tsbbLpukCpKb6yXaxTzml5n4QFWP6PxEgcepf9cei3yjY1C6fsRypqfiuhRxiin8KsybrIqyb9eYkqyGtAyLyubsc3bJBxGqGJBN0W5dO0PfO6Oxq9wRNg1Fb7MaLvzjhegwG4POxGabY4WzJXJEbIqyb9fYkqyGtAyLyubsc3bJBxGOyskiOmKXHZgJh9cYywYBWv)G1Bz9WcB9kMKcckdzC4SX4rVG8fEAy90ovp9HHaXtrVabcKXHZgJh9c0jd7GJfHWIziKvGWaN0WkXOcKeUdg3UaHq1JPam0IHZzjhpuVq6aL1s(fmw73531GmpquTTnRQ3A9PvIC12BdIlRyOo1r9dovp9QhwyRhtbyOfdNZk2duZy9H6Qv(L5bIQTTzv9wRpTsKR2EBqC1py9evpmR3A9Kuqq5BSe5Ao9cPvShOzk76Twpjfeu(qD1kxRCqIZu21BTEj)cgR9787AGgZsEdU6NQhg1BTEskiOSI9a1mwFOUALFz1khiq8u0lqGqGd6dveclOjHSceg4KgwjgvGKWDW42fi0O(ly3eOSk7gt9wRNah3oPHZhqPtlq1rVG6Hf2657yqIZKy2du9cPduwRg3a4zjxgFX1BT(OL46PDQElfiEk6fiqsUXO9u0lqB6leiM(cnWLybcFhds8jcHfdaHSceg4KgwjgvG4POxGaXExJgZ3sHtSajH7GXTlqOr9HByqKpuxTY1qBI6YmWjnSsGaTynGLHqybrIqyXSkKvGWaN0WkXOcKeUdg3UaHbmg(46PDQEAcg1BTEcCC7KgoFaLoTavh9cQ3A9PDnQvoiFJLixZPxiTI9antzxV16t7AuRCq(qD1kxRCqIZjuhdNV6PDQEIeiEk6fiqoukCpKb6yXaxTIqyXauiRaHboPHvIrfiEk6fiqogJ9GvAYfW6ZUhYcKeUdg3UaHah3oPHZhqPtlq1rVG6TwpnQxTr(ym2dwPjxaRp7EiRvBKJonSbWRhwyRhQHJgAml5n4QFWP6NHajnozyD4y4CCcliseclicgczfimWjnSsmQajH7GXTlqiWXTtA48bu60cuD0lOER1tJ6t7AuRCq(qD1kxtACfFzk76TwpHQpCddImdiGnRDdGRpuxTYVmdCsdRQhwyRpTRrTYb5d1vRCTYbjoNqDmC(QN2P6jQEywV16ju90O(WnmiYhkfUhYaDSyGR2mdCsdRQhwyRpCddI8H6QvUgAtuxMboPHv1dlS1N21Ow5G8HsH7Hmqhlg4QnJzjVbx90wVL1dZ6TwpHQNg1JPam0IHZ5aL14ncgK5bIQTTzv9WcB9PvIC12BdIR(bNQ3Y6Hz9wRNq1tJ657yqIZKMDv6fshOSMbS04SKlJV46Hf26t7AuRCqM0SRsVq6aL1mGLgNXSK3GREAR3Y6HPaXtrVabYnwICnNEH0k2duriSGiIeYkqyGtAyLyubINIEbcejhpKvAOfRvShOcKeUdg3Uab7TsZeWGi7k1LPSR3A9eQ(WXW5ihTeRJvRAU(bRpTsKR2EBqCzfd1PoQhwyRNg1Fb7MaLvz3yQ3A9PvIC12BdIlRyOo1r90ovFYwl5YG(SzGQEykqsJtgwhogohNWcIeHWcISuiRaHboPHvIrfijChmUDbc2BLMjGbr2vQl3G6PTE6bJ6NT6XER0mbmiYUsDzff2JEb1BT(0krUA7TbXLvmuN6OEANQpzRLCzqF2mqjq8u0lqGi54HSsdTyTI9avecliIEczfimWjnSsmQajH7GXTlqiWXTtA48bu60cuD0lOER1NwjYvBVniUSIH6uh1t7u9wkq8u0lqGCOUALRjnUIpriSGi6lKvGWaN0WkXOcKeUdg3UaHah3oPHZhqPtlq1rVG6TwFALixT92G4YkgQtDupTt1tV6Tw)zZgJoCmCoU8HsH7HmqFXILQFWP6PVaXtrVabcNq3gaxJzBCl5aLiewq0meYkqyGtAyLyubsc3bJBxGeUHbr(qD1kxdTjQlZaN0WQ6TwpboUDsdNpGsNwGQJEb1BTEskiO8nwICnNEH0k2d0mLTaXtrVabYHsH7Hmqhlg4QvecliIMeYkqyGtAyLyubsc3bJBxGqJ6jPGGYhQRw5ALdsCMYUER1d1WrdnML8gC1p4u9ZA9exF4gge5JImymefCoZaN0WkbINIEbcKd1vRCTYbjwecliAaiKvG4POxGaXEJEbceg4KgwjgvecliAwfYkqyGtAyLyubsc3bJBxGqsbbLVXsKR50lKwXEGMPSfiEk6fiqin7Q0qu4XIqybrdqHSceg4KgwjgvGKWDW42fiKuqq5BSe5Ao9cPvShOzkBbINIEbcesgFmEydGlcHfwcdHSceg4KgwjgvGKWDW42fiKuqq5BSe5Ao9cPvShOzkBbINIEbceOgZKMDvIqyHLejKvGWaN0WkXOcKeUdg3UaHKcckFJLixZPxiTI9antzlq8u0lqG4GeFb2n6KBmIqyHLwkKvGWaN0WkXOcepf9ceiPXjZg4f0jnPXVqGKWDW42fi0O(ly3eOSk7gt9wRNah3oPHZhqPtlq1rVG6TwpnQNKcckFJLixZPxiTI9antzxV16zaJHpoRyOo1r90ovp9GHaHHG4uObUelqsJtMnWlOtAsJFHiewyj9eYkqyGtAyLyubINIEbceNMpuh7NgAbHEH02RCglqs4oyC7ceAupjfeu(qD1kxRCqIZu21BT(0Ug1khKVXsKR50lKwXEGMXSK3GR(bRNiyiqaUelqCA(qDSFAOfe6fsBVYzSiewyj9fYkqyGtAyLyubINIEbce)qjWb8PXonVyDAXUrGKWDW42fikMKcckJDAEX60IDJwXKuqqz1khupSWwVIjPGGYPfOOsrtaRBWqTIjPGGYu21BT(WXW5iJYUjqZ2PO(bRNEwwV16dhdNJmk7ManBNI6PDQE6bJ6Hf26Pr9kMKcckNwGIkfnbSUbd1kMKccktzxV16ju9kMKcckJDAEX60IDJwXKuqq5l80W6PDQElNr9Zw9ebJ6jm1RyskiOmPzxLEH0bkRzalnotzxpSWwpudhn0ywYBWv)G1tFyupmR3A9Kuqq5BSe5Ao9cPvShOzml5n4QN26NvbcWLybIFOe4a(0yNMxSoTy3icHfwodHSceg4KgwjgvGaCjwGinw5NoCtFsoqG4POxGarASYpD4M(KCGiewyjnjKvGWaN0WkXOcKeUdg3UaHKcckFJLixZPxiTI9antzxpSWwpudhn0ywYBWv)G1BjmeiEk6fiqOow3blDIqecKly3eO6K6eYkSGiHSceg4KgwjgvGS2cKJdbINIEbcecCC7KgwGqGBOybsAxJALdYhQRw5ALdsCoH6y48PHWEk6f4M6PDQEIYdGziqiWXAGlXcKdvPdumFORrjcHfwkKvGWaN0WkXOcKeUdg3UaHq1tJ6jWXTtA48HQ0bkMp01OQhwyRNg1hUHbrg0WrJlCZqgNzGtAyv9wRpCddISYXd1hQRw5zg4KgwvpmR3A9PvIC12BdIlRyOo1r90wpr1BTEAupMcWqlgoNLC8q9cPduwl5xWyTFNFxdY8ar122SsG4POxGaHah0hQiewqpHScepf9ceihBF9jqyGtAyLyuriSG(czfimWjnSsmQaXtrVabI9UgnMVLcNybcldb21U0sbcbc9HHabAXAaldHWcIeHWIziKvGWaN0WkXOcKeUdg3UaHbmg(46PDQE6dJ6Twpdym8Xzfd1PoQN2P6jcg1BTEAupboUDsdNpuLoqX8HUgv9wRpTsKR2EBqCzfd1PoQN26jQER1RyskiOmuduA5SpeW3LXSK3GR(bRNibINIEbcKd1vRCj2OeHWcAsiRaHboPHvIrfiRTa54qG4POxGaHah3oPHfie4gkwGKwjYvBVniUSIH6uh1t7u90xGqGJ1axIfihQsNwjYvBVnioriSyaiKvGWaN0WkXOcK1wGCCiq8u0lqGqGJBN0WcecCdflqsRe5QT3gexwXqDQJ6hCQEIeijChmUDbcboUDsdNPowBJ7f3XynEdp6fiqiWXAGlXcKdvPtRe5QT3geNiewmRczfimWjnSsmQajH7GXTlqiWXTtA48HQ0PvIC12BdIRER1tO6jWXTtA48HQ0bkMp01OQhwyRNKcckFJLixZPxiTI9anJzjVbx90ovprzlRhwyR)SzJrhogohx(qPW9qgOVyXs1t7u90VER1N21Ow5G8nwICnNEH0k2d0mML8gC1tB9ebJ6HPaXtrVabYH6QvUw5GelcHfdqHSceg4KgwjgvGKWDW42fie442jnC(qv60krUA7TbXvV16HA4OHgZsEdU6hS(0Ug1khKVXsKR50lKwXEGMXSK3GtG4POxGa5qD1kxRCqIfHieiKuTrjKvybrczfimWjnSsmQajH7GXTlqoB2y0HJHZXvpTt1Bz9expHQpCddImCZUsKgxXzg4KgwvV16DAMXDWzBgdTyp4m2bdRN2P6TSEykq8u0lqGCOu4Eid0xSyjriSWsHSceg4KgwjgvGKWDW42fiPDnQvoiFmg7bR0KlG1NDpKZjuhdNpne2trVa3upTt1BzEamdbINIEbcKJXypyLMCbS(S7HSiewqpHScepf9ceiWn7krACflqyGtAyLyuriSG(czfiEk6fiqi90WlCsbcdCsdReJkcricbcbm(6fiSWsyyjmicgerpbIChdAa8tGmliCjSwiJyXSez06RxwuU(wYEXr9qlU(zzsQ2OMLRhZdevJzv93kX17uXk5bRQpH6a48LR5eoAaxprYO1tyzPLawvV9ED0lqt6PH1Nq50W6jeyJ6Dc824KgU(guplrz8OxamRNqejdWmxZR5Yis2loyv9ZA9Ek6fuVPV4Y1CbInEHAdlqKz9iuKHHJX1tyx4uCnxM1t4mfljJRNi6tx9wcdlHrnVMlZ6NDmpBd4kr6rn3trVGlBJ50kr6bXtJ422MXA7TVfuZ9u0l4Y2yoTsKEq80ixWUjqR5Ek6fCzBmNwjspiEAejhpKvAOfRvShO0zJ50kr6H(40cu3erZOM7POxWLTXCALi9G4ProtNyTduAvNy6SXCALi9qFCAbQBIOAUNIEbx2gZPvI0dINg5qD1kxtACfF01qtykadTy4CwYXd1lKoqzTKFbJ1(D(DniZdevBBZQAUNIEbx2gZPvI0dINgH6yDhSeDaxINCA(qDSFAOfe6fsBVYzCnVMlZ6LX8gupHDdp6fuZ9u0l4Mg2PH1Cpf9coINgHah3oPHPd4s80bu60cuD0lGocCdfprsbbLptNyTduAvN4mLnSWE2SXOdhdNJlFOu4Eid0xSyjANOj6g4hRQp26vCWyPgW1lhLdugxFAxJALdU6L7Dup0IRhbmZ6j9Jv1VG6dhdNJlxZLz9dikNgw)aoZREpQhQXxuZ9u0l4iEAKKBmApf9c0M(c6aUepLuxnxM1tyPa1drzmJR)K3rcLV6JT(aLRhjy3eOSQEc7gE0lOEcroUE12a41FlDDup0It8vV9UMgaV(gQEWgOnaE99vVtG3gN0WWmxZ9u0l4iEAemfq7POxG20xqhWL4Ply3eOSIUgA6c2nbkRYUXuZLz9eU22MX1FMoXAhO0QoX17r9wsC9d4SxVIc3a41hOC9qn(I6jcg1FCAbQJohkyC9bQh1tFIRFaN96BO67OEwgSBmF1lVd0guFGY1dyziQFwYaoZ6xC99vpyJ6PSR5Ek6fCepnYz6eRDGsR6etxdnD2SXOdhdNJlFOu4Eid0xSyPbPjRqnC0qJzjVbhT0KvskiO8z6eRDGsR6eNXSK3GBq4jvwYLbRPvIC12BdIJ2j6pBekAjEqIGbmjmwwZLz9eobMX1NqDaCUE8gE0lO(gQE5C9OobC924EXDmwJ3WJEb1FCuVdu1lrzI22W1hogohx9u25AUNIEbhXtJqGJBN0W0bCjEI6yTnUxChJ14n8OxaDe4gkEYg3lUJXA8gE0lW6zZgJoCmCoU8HsH7HmqFXILODYYAUmRF2X9I7yC9e2n8OxWaR1t4GJz5RE4nbC9E9jSBxVtUur9mGXWhxp0IRpq56VGDtGw)aoZREcrs1gfJR)I2yQhZNnNI67aM56NLIYMUoQp5G6j56dupQ)AjBdNR5Ek6fCepnsYngTNIEbAtFbDaxINUGDtGQtQJUgAIah3oPHZuhRTX9I7ySgVHh9cQ5YS(b(XQ6JTEfd1aUE5OmO(yRN646VGDtGw)aoZR(fxpjvBum(Q5Ek6fCepncboUDsdthWL4Ply3eO6afZh6Au0rGBO4jlNbXHByqKjOHV4mdCsdRimwcdId3WGil5xWy9cPpuxTYVmdCsdRimwcdId3WGiFOUALRH2e1LzGtAyfHXYzqC4ggez34jChJZmWjnSIWyjmi2Yzqyi0zZgJoCmCoU8HsH7HmqFXILODI(WSMlZ6hWfCTIX1tDnaE9E9ib7MaT(bCM1lhLb1JzpH2a41hOC9mGXWhxFGI5dDnQAUNIEbhXtJKCJr7POxG20xqhWL4Ply3eO6K6ORHMyaJHpoRyOo1XGte442jnC(c2nbQoqX8HUgvnxM1BrdhnMLV6hyyaC2bjwgTEclLDqH56jzOfZ1JmwICnx9EuVzLx)ao71hB9PvISbC9SJnJRhZqy(qRxEhO1dNJObWRpq56jPGGQNYoxpHR526nR86hWzVEffUbWRhzSe5AU6j5qoZG6NPds8vV8oqR3sIR3IbMCn3trVGJ4PrWu2bfMPRHMCAMXDWzqdhnonbmao7GeNzGtAyLvAqsbbLbnC040eWa4SdsCMY2AALixT92G4YkgQtDqlrwj0zZgJoCmCoU8HsH7HmqFXILg0syHLah3oPHZuhRTX9I7ySgVHh9cGPvcL21Ow5G8nwICnNEH0k2d0mML8gCdorpyHLqonZ4o4mOHJgNMagaNDqIZyhmK2jlTssbbLVXsKR50lKwXEGMXSK3GJw6zLgxWUjqzv2ngRPDnQvoiFOUALRvoiX5eQJHZNgc7POxGBODcg5bimHzn3trVGJ4PrsUXO9u0lqB6lOd4s8eud6dLUgActbyOfdNZk2duZy9H6Qv(L5bIQTTzLv1g5JTV(YrNg2a4wvBKp2(6lJzjVb3GtwAnTsKR2EBqC0ozzn3trVGJ4PrsUXO9u0lqB6lOd4s8eud6dLUgAkTRrTYb5BSe5Ao9cPvShOzml5n4gCYsRPvIC12BdIJ2jlTIPam0IHZ5aL14ncgK5bIQTTzvn3trVGJ4PrsUXO9u0lqB6lOd4s8eud6dLUgAkTsKR2EBqCtoOL8eQJHZkDYUMlZ6NbX1lVd06Njs9eAPIRvC9xWUjqHzn3trVGJ4PrsUXO9u0lqB6lOd4s8eud6dLUgAkTsKR2EBqCzfd1PogCIiyHfQHJgAml5n4gCIiRPvIC12BdIJ2j6vZLz9e(g0hA9Eup9jUE5DGUur9ZePMlZ6NfDGw)mrQ3n3wpud6dTEpQN(exVd3BWf1ZYGNcZ46PF9HJHZXvpHwQ4Afx)fSBcuywZ9u0l4iEAKKBmApf9c0M(c6aUepb1G(qPRHMoB2y0HJHZXLpukCpKb6lwS0e9TMwjYvBVnioANOFnxM1pWpUEVEsQ2OyC9Yrzq9y2tOnaE9bkxpdym8X1hOy(qxJQM7POxWr80ij3y0Ek6fOn9f0bCjEIKQnk6AOjgWy4JZkgQtDm4eboUDsdNVGDtGQdumFORrvZLz9eow58f1BJ7f3X46Bq9UXu)cvFGY1t4o7eoQNKto1X13r9jN64REV(zjd4mR5Ek6fCepnIJtoG1XIXmiORHMyaJHpoRyOo1bTtendIzaJHpoJz4mOM7POxWr80ioo5awBtzoUM7POxWr80iMgoACAzCkfCjge1Cpf9coINgH0HRxiDG70WRMxZLz9d4Ug1khC1Czw)a)46NPdsC9le0SbpPQNKHwmxFGY1d14lQ)qPW9qgOVyXs1dHxP6LDXaxT1Nwj(QVb5AUNIEbxoPoINg5qD1kxRCqIPJ6y9cbPHNuterxdnrdskiO8H6QvUw5GeNPSTssbbLpukCpKb6yXaxTzkBRKuqq5dLc3dzGowmWvBgZsEdUbNOxEg1CzwpHg4adFx9UbZUAC9u21tYjN646LZ1h7oSEeuxTYRNWVjQdM1tDC9iJLixZv)cbnBWtQ6jzOfZ1hOC9qn(I6pukCpKb6lwSu9q4vQEzxmWvB9PvIV6BqUM7POxWLtQJ4PrUXsKR50lKwXEGsh1X6fcsdpPMiIUgAIKcckFOu4Eid0XIbUAZu2wjPGGYhkfUhYaDSyGR2mML8gCdorV8mQ5Ek6fC5K6iEAeiJdNngp6fqxdnrGJBN0W5dO0PfO6OxGvACb7MaLvzjhegUM7POxWLtQJ4PrGmoC2y8OxGozyhCmDn0KIjPGGYqghoBmE0liJzjVb3GwclSkMKcckdzC4SX4rVG8fEAiTt0hg1Cpf9cUCsDepncboOpu6AOjcHPam0IHZzjhpuVq6aL1s(fmw73531GmpquTTnRSMwjYvBVniUSIH6uhdorpyHftbyOfdNZk2duZy9H6Qv(L5bIQTTzL10krUA7TbXnirW0kjfeu(glrUMtVqAf7bAMY2kjfeu(qD1kxRCqIZu2wL8lyS2VZVRbAml5n4MGHvskiOSI9a1mwFOUALFz1khuZ9u0l4Yj1r80ij3y0Ek6fOn9f0bCjEIVJbj(ORHMOXfSBcuwLDJXkboUDsdNpGsNwGQJEbWclFhdsCMeZEGQxiDGYA14gapl5Y4l2A0smTtwwZLz9Z(UM6HwC9YUyGR26TX8SHSZSE5DGwpc6mRhZUAC9Yrzq9GnQhtbanaE9ie(Cn3trVGlNuhXtJyVRrJ5BPWjMoOfRbSmeterxdnrJWnmiYhQRw5AOnrDzg4KgwvZLz9d8JRx2fdC1wVnMRhzNz9Yrzq9Y56rDc46duUEgWy4JRxokhOmUEi8kvV9UMgaVE5DGUur9ie(6xC9Y4uxupCgWy3ygNR5Ek6fC5K6iEAKdLc3dzGowmWvlDn0edym8X0ortWWkboUDsdNpGsNwGQJEbwt7AuRCq(glrUMtVqAf7bAMY2AAxJALdYhQRw5ALdsCoH6y48r7er1Cpf9cUCsDepnYXyShSstUawF29qMU04KH1HJHZXnreDn0eboUDsdNpGsNwGQJEbwPHAJ8XyShSstUawF29qwR2ihDAydGdlSqnC0qJzjVb3GtZOMlZ6h4hxpYyjY1C1VG6t7AuRCq9eYHcgxpuJVOEeWmHz9uadFx9Y56Dmxp8TbWRp26Tx76LDXaxT17av9QTEWg1J6eW1JG6QvE9e(nrD56jCSYRFaN96HwC9YIY1ty3iyqUM7POxWLtQJ4PrUXsKR50lKwXEGsxdnrGJBN0W5dO0PfO6OxGvAK21Ow5G8H6QvUM04k(Yu2wju4ggezgqaBw7gaxFOUALFzg4KgwblSPDnQvoiFOUALRvoiX5eQJHZhTtebtReIgHByqKpukCpKb6yXaxTzg4KgwblSHByqKpuxTY1qBI6YmWjnScwyt7AuRCq(qPW9qgOJfdC1MXSK3GJwlHPvcrdmfGHwmCohOSgVrWGmpquTTnRGf20krUA7TbXn4KLW0kHObFhdsCM0SRsVq6aL1mGLgNLCz8fdlSPDnQvoitA2vPxiDGYAgWsJZywYBWrRLWSMlZ6LrGQ3vQREhZ1tztx9hOT56duU(fW1lVd06nRC(I6Lv2zMRFGFC9Yrzq9QXnaE9q(fmU(a1b1pGZE9kgQtDu)IRhSr9xWUjqzv9Y7aDPI6DW46hWzpxZ9u0l4Yj1r80isoEiR0qlwRypqPlnozyD4y4CCterxdnH9wPzcyqKDL6Yu2wju4y4CKJwI1XQvnpyALixT92G4YkgQtDalS04c2nbkRYUXynTsKR2EBqCzfd1PoODkzRLCzqF2mqbZAUmRxgbQEWwVRux9YBJPEvZ1lVd0guFGY1dyziQNEW4OREQJRxgdAM1VG6j37QxEhOlvuVdgx)ao75AUNIEbxoPoINgrYXdzLgAXAf7bkDn0e2BLMjGbr2vQl3aAPhmMnS3kntadISRuxwrH9OxG10krUA7TbXLvmuN6G2PKTwYLb9zZavn3trVGlNuhXtJCOUALRjnUIp6AOjcCC7KgoFaLoTavh9cSMwjYvBVniUSIH6uh0ozzn3trVGlNuhXtJWj0TbW1y2g3soqrxdnrGJBN0W5dO0PfO6OxG10krUA7TbXLvmuN6G2j6z9SzJrhogohx(qPW9qgOVyXsdor)AUmRFw0bA9ieE6QVHQhSr9UbZUAC9QfW0vp1X1l7IbUARxEhO1JSZSEk7Cn3trVGlNuhXtJCOu4Eid0XIbUAPRHMc3WGiFOUALRH2e1LzGtAyLvcCC7KgoFaLoTavh9cSssbbLVXsKR50lKwXEGMPSR5Ek6fC5K6iEAKd1vRCTYbjMUgAIgKuqq5d1vRCTYbjotzBfQHJgAml5n4gCAwjoCddI8rrgmgIcoNzGtAyvnVMlZ6TybZ2zZP6VGccQE5DGwVzLZ46TX9wZ9u0l4Yj1r80i2B0lOM7POxWLtQJ4Prin7Q0qu4X01qtKuqq5BSe5Ao9cPvShOzk7AUNIEbxoPoINgHKXhJh2a401qtKuqq5BSe5Ao9cPvShOzk7AUNIEbxoPoINgbQXmPzxfDn0ejfeu(glrUMtVqAf7bAMYUM7POxWLtQJ4PrCqIVa7gDYng6AOjskiO8nwICnNEH0k2d0mLDnVM7POxWLtQJ4PrOow3blrhdbXPqdCjEknoz2aVGoPjn(f01qt04c2nbkRYUXyLah3oPHZhqPtlq1rVaR0GKcckFJLixZPxiTI9antzBLbmg(4SIH6uh0orpyuZ9u0l4Yj1r80iuhR7GLOd4s8KtZhQJ9tdTGqVqA7voJPRHMObjfeu(qD1kxRCqIZu2wt7AuRCq(glrUMtVqAf7bAgZsEdUbjcg1Czw)gOmwEFC9Y7aTEKDM17r9wodIR)cpn8QFX1t0miUE5DGwVBUT(rn7QQNYoxZ9u0l4Yj1r80iuhR7GLOd4s8KFOe4a(0yNMxSoTy3qxdnPyskiOm2P5fRtl2nAftsbbLvRCaSWQyskiOCAbkQu0eW6gmuRyskiOmLT1WXW5iJYUjqZ2Pyq6zP1WXW5iJYUjqZ2PG2j6bdyHLgkMKcckNwGIkfnbSUbd1kMKccktzBLqkMKcckJDAEX60IDJwXKuqq5l80qANSCgZgrWGWOyskiOmPzxLEH0bkRzalnotzdlSqnC0qJzjVb3G0hgW0kjfeu(glrUMtVqAf7bAgZsEdoAN1AUmRFGHXJRhVuWrnJRhtz46xO6dukjYgQzv9sEGE1tYMvUmA9d8JRhAX1lJagAVQ6t4oQ5Ek6fC5K6iEAeQJ1DWs0bCjEsASYpD4M(KCqnxM1ptgYPmr9qUXq6PH1dT46PoN0W13blDYO1pWpUE5DGwpYyjY1C1Vq1pt2d0Cn3trVGlNuhXtJqDSUdw6ORHMiPGGY3yjY1C6fsRypqZu2Wcludhn0ywYBWnOLWOMxZLz9eU0mJ7GRFGL7yqIVAUNIEbxMVJbj(iEAK0csmiWEWknKXLy6AOjgWy4JZrlX6y1sUmqlrwPbjfeu(glrUMtVqAf7bAMY2kHOHAJCAbjgeypyLgY4sSMKcdYrNg2a4wPHNIEb50csmiWEWknKXL4Cd0qMgoAalSqugJgZjuhdN1rlXdcpPYsUmaZAUNIEbxMVJbj(iEAesZUk9cPduwZawAmDn0ens7AuRCq(qD1kxtACfFzkBRPDnQvoiFJLixZPxiTI9antzdlSqnC0qJzjVb3GtebJAUNIEbxMVJbj(iEAe4uow1oqVqANMz8gO1Cpf9cUmFhds8r80iqBI6yL2Pzg3bRjzxIUgAIqNnBm6WXW54YhkfUhYa9flwI2jlHfwS3kntadISRuxUb0stWaMwPrAxJALdY3yjY1C6fsRypqZu2wPbjfeu(glrUMtVqAf7bAMY2kdym8Xzfd1PoODIEWOM7POxWL57yqIpINgXMc3qJBaCnPXVGUgA6SzJrhogohx(qPW9qgOVyXs0ozjSWI9wPzcyqKDL6YnGwAcg1Cpf9cUmFhds8r80ibkRPaKlfqPHwCIPRHMiPGGYyon0W3PHwCIZu2WcljfeugZPHg(on0ItSoTuGGX5l80Wbjcg1Cpf9cUmFhds8r80i4222W6gOpBpX1Cpf9cUmFhds8r80iYxSrra3anMVf4GetxdnL21Ow5G8nwICnNEH0k2d0mML8gCdodyHfQHJgAml5n4gKOzTM7POxWL57yqIpINgrILw8y9cPnuPwPvy2Lo6AOjgWy4JhK(WWkjfeu(glrUMtVqAf7bAMYUMlZ6hyVgv9ew2TBa86j8gxIV6HwC9SmWjQGRh7a4C9lU(HTXupjfe0rx9nu927DnPHZ1t4AK7JV6d846JTE4CuFGY1Bw58f1N21Ow5G6j9Jv1VG6Dc824KgUEgWsnF5AUNIEbxMVJbj(iEAem72naUgY4s8rxdnb1WrdnML8gCdsuEgWclHiu4y4CKrz3eOz7uq7ScdyHnCmCoYOSBc0SDkgCYsyatReYtrtaRzal18nreSWc1WrdnML8gC0A5aeMWewyju4y4CKJwI1XQTtH2syql9GHvc5POjG1mGLA(MicwyHA4OHgZsEdoAPp9HjmR51CzwpsWUjqRFa31Ow5GRM7POxWLVGDtGQtQJ4PriWXTtAy6aUepDOkDGI5dDnk6iWnu8uAxJALdYhQRw5ALdsCoH6y48PHWEk6f4gANikpaMbDdSzJnJRFGXXTtA4AUmRFGXb9HwFdvVCUEhZ1NCB7gaV(fu)mDqIRpH6y48LRFGfhBgxpjdTyUEOgFr9khK46BO6LZ1J6eW1d26TOHJgx4MHmUEsQO(z64H1JG6QvE9nO(fRyC9XwpCoQNWszhuyUEk76jeyRxgZVGX1t4ENFxdGzUM7POxWLVGDtGQtQJ4PriWb9HsxdnriAqGJBN0W5dvPdumFORrblS0iCddImOHJgx4MHmoZaN0WkRHByqKvoEO(qD1kpZaN0WkyAnTsKR2EBqCzfd1PoOLiR0atbyOfdNZsoEOEH0bkRL8lyS2VZVRbzEGOABBwvZ9u0l4YxWUjq1j1r80ihBF9vZ9u0l4YxWUjq1j1r80i27A0y(wkCIPdAXAaldXer0XYqGDTlTuGyI(WGUzFxt9qlUEeuxTYLyJQEIRhb1vR8lW9qUEkGHVRE5C9oMR3jxQO(yRp521VG6NPdsC9juhdNVC9eobMX1lhLb1t4BGQ(zb7db8D13x9o5sf1hB9ykq9lvKR5Ek6fC5ly3eO6K6iEAKd1vRCj2OORHMyaJHpM2j6ddRmGXWhNvmuN6G2jIGHvAqGJBN0W5dvPdumFORrznTsKR2EBqCzfd1PoOLiRkMKcckd1aLwo7db8Dzml5n4gKOAUNIEbx(c2nbQoPoINgHah3oPHPd4s80HQ0PvIC12BdIJocCdfpLwjYvBVniUSIH6uh0orF6gWzVEmpqunMLyqiJw)mDqIR3J6nR86hWzVEYX1RyiNYe5AUmRFaN96X8ar1ywIbHmA9Z0bjU(fygxpjdTyUEOg0hkJV6BO6LZ1J6eW1BJ7f3X46XB4rVGCn3trVGlFb7MavNuhXtJqGJBN0W0bCjE6qv60krUA7TbXrhbUHINsRe5QT3gexwXqDQJbNiIUgAIah3oPHZuhRTX9I7ySgVHh9cQ5YS(z6GexVIc3a41JmwICnx9lUENCjGRpqX8HUgvUM7POxWLVGDtGQtQJ4ProuxTY1khKy6AOjcCC7KgoFOkDALixT92G4SsicCC7KgoFOkDGI5dDnkyHLKcckFJLixZPxiTI9anJzjVbhTteLTewypB2y0HJHZXLpukCpKb6lwSeTt03AAxJALdY3yjY1C6fsRypqZywYBWrlrWaM1Czw)Ouyq9ywYBqdGx)mDqIV6jzOfZ1hOC9qnC0OEgOU6BO6r2zwV8fmlh1tY1JzxnU(guF0sCUM7POxWLVGDtGQtQJ4ProuxTY1khKy6AOjcCC7KgoFOkDALixT92G4Sc1WrdnML8gCdM21Ow5G8nwICnNEH0k2d0mML8gC18AUmRhjy3eOSQEc7gE0lOMlZ6LrGQhjy3eOJqGd6dTEhZ1tztx9uhxpcQRw5xG7HC9XwpjdyOoQhcVs1hOC92(DnbC9KlG6Q3bQ6j8nqv)SG9Ha(U6zcyq9nu9Y56DmxVh1l5Yq9d4SxpHGWRu9bkxVnMtRePh1lJbntyMR5Ek6fC5ly3eOSI4ProuxTYVa3dz6AOjcrsbbLVGDtGMPSHfwskiOmboOp0mLnmR5YSEcFd6dTEpQNEex)ao71lVd0LkQFMi1ps90N46L3bA9ZePE5DGwpckfUhYG6LDXaxT1tsbbvpLD9XwVtW2Q6VvIRFaN96L7xW1FDq5rVGlxZ9u0l4YxWUjqzfXtJKCJr7POxG20xqhWL4jOg0hkDn0ejfeu(qPW9qgOJfdC1MPSTMwjYvBVniUSIH6uhdozznxM1t4AUT(ZH46JTEOg0hA9Eup9jU(bC2RxEhO1ZYGNcZ46PF9HJHZXLRNqiUexVF1VuX1kU(ly3eOzywZ9u0l4YxWUjqzfXtJKCJr7POxG20xqhWL4jOg0hkDn00zZgJoCmCoU8HsH7HmqFXILMOV10krUA7TbXr7e9R5YSEcFd6dTEpQN(ex)ao71lVd0LkQFMi1Czw)miUE5DGw)mrQ5YSEhOQNMQxEhO1ptK6DOGX1pW4G(qR5Ek6fC5ly3eOSI4PrsUXO9u0lqB6lOd4s8eud6dLUgAkTsKR2EBqCzfd1PogCIOzJqHByqKvmBZy9fypC4SuMboPHvwjPGGYe4G(qZu2WSMlZ6h421hB90R(WXW54QFiZ21tzxpHVbQ6NfSpeW3vp546tJtMgaVEeuxTYVa3d5Cn3trVGlFb7MaLvepnYH6Qv(f4EitxACYW6WXW54MiIUgAsXKuqqzOgO0YzFiGVlJzjVb3Gez9SzJrhogohx(qPW9qgOVyXsdorpRHJHZroAjwhRw18SHzjVbhT0unxM1pl6aDPI6NjZ2mUEKa7HdNLQ3bQ6Px9ewhm8QFHQFuJR46Bq9bkxpcQRw5x9DuFF1lFXbA9uxdGxpcQRw5xG7HC9lOE6vF4y4CC5AUNIEbx(c2nbkRiEAKd1vR8lW9qMUgAIgHByqKvmBZy9fypC4SuMboPHvwDAMXDWzsJRyDd0bkRpuxTYVm2bdNON1ZMngD4y4CC5dLc3dzG(IflnrVAUmRNWV46TX9I7yC94n8OxaD1tDC9iOUALFbUhY1VeW46rIflvprWSE5DGw)SqgREhU3GlQNYU(yRN(1hogohxnxM1BjmRVHQNWplQVV6XuaqdGx)cbvpHwq9oyC9U0sbI6xO6dhdNJdM1Czw)IRNEWS(yRxYLHwQPzUEKDM1ZYqWGRxq9Y7aTEzeatqhozB6yC9lOE6vF4y4CC1ti6xV8oqRF0oqGzUM7POxWLVGDtGYkINg5qD1k)cCpKPRHMiWXTtA4m1XABCV4ogRXB4rVaResXKuqqzOgO0YzFiGVlJzjVb3GeblSHByqKLZU9cK8lyCMboPHvwpB2y0HJHZXLpukCpKb6lwS0Gt0hwyDAMXDW5gWe0Ht2MogNzGtAyLvskiO8nwICnNEH0k2d0mLT1ZMngD4y4CC5dLc3dzG(Ifln4e9i2Pzg3bNjnUI1nqhOS(qD1k)YmWjnScM1Cpf9cU8fSBcuwr80ihkfUhYa9flwIUgA6SzJrhogohhTt0JycrsbbLTXSeR6WJEbzkByHLKcckhOSgVrWGmLnSWIPam0IHZzFO74(03sz0qyhUedImpquTTnRSMwGIQJSIzBgRvoC4m(YyhmK2PbamR5Ek6fC5ly3eOSI4ProuxTYVa3dz6AOjftsbbLHAGslN9Ha(UmML8gCdoreSWM21Ow5G8nwICnNEH0k2d0mML8gCds0SAvXKuqqzOgO0YzFiGVlJzjVb3GPDnQvoiFJLixZPxiTI9anJzjVbxnxM1JG6Qv(f4EixFS1JzimFO1t4BGQ(zb7db8D17av9XwpdokmxVCU(KdQp5y846xcyC9E9qugt9e(zr9ni26duUEaldr9i7mRVHQ3EVRjnCUM7POxWLVGDtGYkINgXExJgZ3sHtmDqlwdyziMiQM7POxWLVGDtGYkINgbUzxjsJRy6AOjAGPam0IHZzFO74(03sz0qyhUedImpquTTnRSssbbLTzm0I9GvAc4gC5l80qANON10cuuDKTzm0I9GvAc4gCzSdgs7er0B2i0aKWKwGIQJSIzBgRvoC4moZaN0WkItlqr1rwXSnJ1khoCgNXoyimR5Ek6fC5ly3eOSI4PrGB2vI04kMUgActbyOfdNZ(q3X9PVLYOHWoCjgezEGOABBwzLKcckBZyOf7bR0eWn4Yx4PH0orpRekTafvhzBgdTypyLMaUbxg7GHeNwGIQJSIzBgRvoC4moJDWqys7er0un3trVGlFb7MaLvepnYH6Qv(f4EixZR5YSEcFd6dLXxn3trVGld1G(qjEAKZ0jw7aLw1jMUgA6SzJrhogohx(qPW9qgOVyXsdstwPbjfeu(qD1kxRCqIZu2wjPGGYNPtS2bkTQtCgZsEdUbHA4OHgZsEdoRKuqq5Z0jw7aLw1joJzjVb3GeIiItRe5QT3gehmjmeLN1AUNIEbxgQb9Hs80ie442jnmDaxINUHTTgtzhuyMocCdfpj5xWyTFNFxd0ywYBWrlmGfwAeUHbrg0WrJlCZqgNzGtAyL1WnmiYkhpuFOUALNzGtAyLvskiO8H6QvUw5GeNPSHf2ZMngD4y4CC5dLc3dzG(Iflr7enr3aB2yZ46hyCC7KgUEOfxpHLYoOWCUEKHTD9kkCdGxVmMFbJRNW9o)Ugu)IRxrHBa86NPdsC9Y7aT(z64H17av9GTElA4OXfUziJZ1Czw)S0mBxpLD9ewk7GcZ13q13r99vVtUur9XwpMcu)sf5AUNIEbxgQb9Hs80iyk7GcZ01qt0Gah3oPHZ3W2wJPSdkmBnCmCoYrlX6y1QMNnml5n4OLMSIzimFOoPHR5Ek6fCzOg0hkXtJCCcZHo4ekOhikUMlZ6LXOmrR2iAa86dhdNJR(a1J6L3gt9MMaUEOfxFGY1ROWE0lO(fQEclLDqH56XmeMp06vu4gaVEBhOyPoLR5Ek6fCzOg0hkXtJGPSdkmtxACYW6WXW54MiIUgAIge442jnC(g22AmLDqHzR0Gah3oPHZuhRTX9I7ySgVHh9cSE2SXOdhdNJlFOu4Eid0xSyjANS0A4y4CKJwI1XQvnt7eHMbXeYsctALixT92G4GjmTIzimFOoPHR5YSEcldH5dTEclLDqH56zhBgxFdvFh1lVnM6zzWUXC9kkCdGxpYyjY1C56N5wFG6r9ygcZhA9nu9i7mRhohx9y2vJRVb1hOC9awgI6NXLR5Ek6fCzOg0hkXtJGPSdkmtxdnrdcCC7KgoFdBBnMYoOWSvml5n4gmTRrTYb5BSe5Ao9cPvShOzml5n4iMiyynTRrTYb5BSe5Ao9cPvShOzml5n4gCAgwdhdNJC0sSowTQ5zdZsEdoAt7AuRCq(glrUMtVqAf7bAgZsEdoINrn3trVGld1G(qjEAesJNgQTx5kgtxdnrdcCC7KgotDS2g3lUJXA8gE0lW6zZgJoCmCooANOxn3trVGld1G(qjEAeMG(sm2dUMxZLz9Js1gfJVAUNIEbxMKQnkINg5qPW9qgOVyXs01qtNnBm6WXW54ODYsIju4ggez4MDLinUIZmWjnSYQtZmUdoBZyOf7bNXoyiTtwA1EVo6fOj90qywZ9u0l4YKuTrr80ihJXEWkn5cy9z3dz6AOP0Ug1khKpgJ9GvAYfW6ZUhY5eQJHZNgc7POxGBODYY8ayg1Cpf9cUmjvBuepncCZUsKgxX1Cpf9cUmjvBuepncPNgEHtkqoBojSWsAIiricHaa]] )


end
