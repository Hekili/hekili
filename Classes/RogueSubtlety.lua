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


    spec:RegisterPack( "Subtlety", 20201011, [[daf3YbqiKcpIKKnrP6tkkrnkiLofOOvbPGxbPAwivULIszxI6xkqddu4yqslJsPNHuLPrsQRPOW2qkY3uaY4uusNtbuwhsvrZtH09uK9Hu6Fkav6GqksluH4HkaMOIIUOcqfBesr9rfLigPcqvNePQWkvu9sfLi1mHueUjsvj7KsXpHuenufLQLcPqpfIPssCvfq1wvakFvrjCwfLizVe(lPgSQomvlgrpwKjt0LrTzq(mOA0iCAPwnsvPETcA2uCBsSBGFR0WPKJRaYYH65QmDHRJKTdj(oj14rkQZRqTEKQQ5dkTFjlqvOIar6blSXwyylmqfgOIA2wuPNTQEGjqIXwSaXYtdD4Sab4kSabHImmCmwGy5JnRlfQiqULcNybcrewh95GdcVdckYCAvg8AfkJh9csyhkg8AL0GcesQ2e0habPar6blSXwyylmqfgOIA2wuTfvyOAbItfelwGG0kdGaHOLsgiifis(scevvpcfzy4yC9OXfofxZvv9OjtXsY46rfv6Q3wyylmeiM(ItOIa5c2nbblfQiSbvHkceg4KgwkgrGKWDW42fiOTEskiO8fSBcImLv9WcB9KuqqzuCqFezkR6HPaXtrVabYr4Yv9f4EilcHn2kurGWaN0WsXicepf9ceij3y0Ek6fOn9fcKeUdg3UaHKcckFeu4Eid0XIbUCZuw1BV(0QqUARTbXLLmuN6O(rNQ3wbIPVqdCfwGa1G(ieHWg6jurGWaN0WsXicepf9ceij3y0Ek6fOn9fcKeUdg3Ua5SyJrhogohx(iOW9qgOVyXk1pvVQR3E9PvHC1wBdIREANQx1cetFHg4kSabQb9ricHnQwOIaHboPHLIreiEk6fiqsUXO9u0lqB6leijChmUDbsAvixT12G4YsgQtDu)Ot1JA9Zw9OT(WnmiYsMTyS(cShoCwjZaN0WY6Txpjfeugfh0hrMYQEykqm9fAGRWceOg0hHie2mdHkceg4KgwkgrGKWDW42fisMKcckd1aPwn7db8DzmR4n4QF06rTE71FwSXOdhdNJlFeu4Eid0xSyL6hDQE6vV96dhdNJC0kSowTS56NT6XSI3GREARNMeiEk6fiqocxUQVa3dzbsACYW6WXW54e2GQie2qtcveimWjnSumIajH7GXTlqOr9HByqKLmBXy9fypC4SsMboPHL1BVEN(zChCM04sw3aDqW6JWLR6lJDWW6NQNE1BV(ZIngD4y4CC5JGc3dzG(IfRu)u90tG4POxGa5iC5Q(cCpKfHWMbKqfbcdCsdlfJiqs4oyC7ceuCC7KgotDS2c3lUJXA8gE0lOE71J26LmjfeugQbsTA2hc47YywXBWv)O1JA9WcB9HByqKvZU1cu8lyCMboPHL1BV(ZIngD4y4CC5JGc3dzG(IfRu)Ot1R66Hf26D6NXDW5gWO0Ht2MogNzGtAyz92RNKcckFJvixZPxiTK9GitzvV96pl2y0HJHZXLpckCpKb6lwSs9Jovp9Qh96D6NXDWzsJlzDd0bbRpcxUQVmdCsdlRhMcepf9ceihHlx1xG7HSie2mRcveimWjnSumIajH7GXTlqol2y0HJHZXvpTt1tV6rVE0wpjfeu2cZkSSdp6fKPSQhwyRNKcckheSgVrWGmLv9WcB9ykadTy4C2h6oUp9Tugne2HRWGiZdevBzXY6TxFAbsQoYsMTySw6WHZ4lJDWW6PDQ(bu9WuG4POxGa5iOW9qgOVyXkIqyZatOIaHboPHLIreijChmUDbIKjPGGYqnqQvZ(qaFxgZkEdU6hDQEuRhwyRpTRrUQb5BSc5Ao9cPLShezmR4n4QF06rDwR3E9sMKcckd1aPwn7db8DzmR4n4QF06t7AKRAq(gRqUMtVqAj7brgZkEdobINIEbcKJWLR6lW9qwecBqfgcveimWjnSumIabAXAatZHWgufiEk6fiqS21OX8Tu4elcHnOIQqfbcdCsdlfJiqs4oyC7ceAupMcWqlgoN9HUJ7tFlLrdHD4kmiY8ar1wwSSE71tsbbLTym0I9GLAu4gC5l80W6PDQE6vV96tlqs1r2IXql2dwQrHBWLXoyy90ovpQ0R(zRE0w)aRE0q9PfiP6ilz2IXAPdhoJZmWjnSSE0RpTajvhzjZwmwlD4WzCg7GH1dtbINIEbce4MDvinUKfHWguTvOIaHboPHLIreijChmUDbcMcWqlgoN9HUJ7tFlLrdHD4kmiY8ar1wwSSE71tsbbLTym0I9GLAu4gC5l80W6PDQE6vV96rB9PfiP6iBXyOf7bl1OWn4YyhmSE0RpTajvhzjZwmwlD4WzCg7GH1dZ6PDQEuPjbINIEbce4MDvinUKfHWguPNqfbINIEbcKJWLR6lW9qwGWaN0WsXiIqece(ogK4tOIWgufQiqyGtAyPyebsc3bJBxGWagdFCoAfwhRwXP56PTEuR3E90OEskiO8nwHCnNEH0s2dImLv92RhT1tJ6LBKtliXGa7bl1qgxH1Kuyqo60WgaVE71tJ69u0liNwqIbb2dwQHmUcNBGgY0WjI6Hf26HOmgnMteogoRJwHRF06HNKzfNMRhMcepf9ceiPfKyqG9GLAiJRWIqyJTcveimWjnSumIajH7GXTlqOr9PDnYvniFeUCvRjnUKVmLv92RpTRrUQb5BSc5Ao9cPLShezkR6Hf26HA4eHgZkEdU6hDQEuHHaXtrVabcPzxPEH0bbRzaRmwecBONqfbINIEbce4uow2oqVqAN(z8geceg4KgwkgrecBuTqfbcdCsdlfJiqs4oyC7ce0w)zXgJoCmCoU8rqH7HmqFXIvQN2P6TTEyHTES3snJcdISlLxUb1tB90emQhM1BVEAuFAxJCvdY3yfY1C6fslzpiYuw1BVEAupjfeu(gRqUMtVqAj7brMYQE71ZagdFCwYqDQJ6PDQE6bdbINIEbceOnrDSu70pJ7G1KSRicHnZqOIaHboPHLIreijChmUDbYzXgJoCmCoU8rqH7HmqFXIvQN2P6TTEyHTES3snJcdISlLxUb1tB90emeiEk6fiqSOWn04gaxtA8leHWgAsOIaHboPHLIreijChmUDbcjfeugZPHg(on0ItCMYQEyHTEskiOmMtdn8DAOfNyDAPabJZx4PH1pA9OcdbINIEbcKGG1uaYLci1qloXIqyZasOIaXtrVabcUTSmSUb6ZYtSaHboPHLIreHWMzvOIaHboPHLIreijChmUDbsAxJCvdY3yfY1C6fslzpiYywXBWv)O1pJ6Hf26HA4eHgZkEdU6hTEuNvbINIEbce1l2irHBGgZ3cCqIfHWMbMqfbcdCsdlfJiqs4oyC7cegWy4JRF06vnmQ3E9Kuqq5BSc5Ao9cPLShezklbINIEbcefwzXJ1lK2qLAPwIzx5eHWguHHqfbcdCsdlfJiqs4oyC7ceOgorOXSI3GR(rRh18mQhwyRhT1J26dhdNJmb7MGiBLI6PT(zfg1dlS1hogohzc2nbr2kf1p6u92cJ6Hz92RhT17POrH1mGvA(QFQEuRhwyRhQHteAmR4n4QN26TDGvpmRhM1dlS1J26dhdNJC0kSowTvk02cJ6PTE6bJ6TxpAR3trJcRzaR08v)u9OwpSWwpudNi0ywXBWvpT1RAvxpmRhMcepf9ceiy2TAaCnKXv4teIqGiziNYecve2GQqfbINIEbcKHDAOaHboPHLIreHWgBfQiqyGtAyPyebYAjqooeiEk6fiqqXXTtAybckUHIfiKuqq5Z0jw7aPw2jotzvpSWw)zXgJoCmCoU8rqH7HmqFXIvQN2P6PjbckowdCfwGCaPoTazh9ceHWg6jurGWaN0WsXicepf9ceij3y0Ek6fOn9fcetFHg4kSajjpriSr1cveimWjnSumIaXtrVabcMcO9u0lqB6leijChmUDbYfSBccwMDJrGy6l0axHfixWUjiyPie2mdHkceg4KgwkgrGKWDW42fiNfBm6WXW54YhbfUhYa9flwP(rRNMQ3E9qnCIqJzfVbx90wpnvV96jPGGYNPtS2bsTStCgZkEdU6hTE4jzwXP56TxFAvixT12G4QN2P6vD9Zw9OT(Ov46hTEuHr9WSE0q92kq8u0lqGCMoXAhi1YoXIqydnjurGWaN0WsXicK1sGCCiq8u0lqGGIJBN0WceuCdflqSW9I7ySgVHh9cQ3E9NfBm6WXW54YhbfUhYa9flwPEANQ3wbckowdCfwGqDS2c3lUJXA8gE0lqecBgqcveimWjnSumIaXtrVabsYngTNIEbAtFHajH7GXTlqqXXTtA4m1XAlCV4ogRXB4rVabIPVqdCfwGCb7MGqNKNie2mRcveimWjnSumIazTeihhcepf9ceiO442jnSabf3qXceBNr9OxF4ggezuA4loZaN0WY6rd1BlmQh96d3WGiR4xWy9cPpcxUQVmdCsdlRhnuVTWOE0RpCddI8r4YvTgAtuxMboPHL1JgQ32zup61hUHbr2nEc3X4mdCsdlRhnuVTWOE0R32zupAOE0w)zXgJoCmCoU8rqH7HmqFXIvQN2P6vD9WuGGIJ1axHfixWUji0bbMpI1ifHWMbMqfbcdCsdlfJiq8u0lqGKCJr7POxG20xiqs4oyC7cegWy4JZsgQtDu)Ot1JIJBN0W5ly3ee6GaZhXAKcetFHg4kSa5c2nbHojpriSbvyiurGWaN0WsXicepf9ceij3y0Ek6fOn9fcKeUdg3UabtbyOfdNZs2dcZy9r4Yv9L5bIQTSyz92RxUr(yRRVC0PHnaE92RxUr(yRRVmMv8gC1p6u92wV96tRc5QT2gex90ovVTcetFHg4kSabQb9ricHnOIQqfbcdCsdlfJiq8u0lqGKCJr7POxG20xiqs4oyC7cK0Ug5QgKVXkKR50lKwYEqKXSI3GR(rNQ326TxFAvixT12G4QN2P6TTE71JPam0IHZ5GG14ncgK5bIQTSyPaX0xObUclqGAqFeIqydQ2kurGWaN0WsXicepf9ceij3y0Ek6fOn9fcKeUdg3UajTkKR2ABqC1pvVdAfpr4y4SuNSeiM(cnWvybcud6JqecBqLEcveimWjnSumIaXtrVabsYngTNIEbAtFHajH7GXTlqsRc5QT2gexwYqDQJ6hDQEuRhwyRhQHteAmR4n4QF0P6rTE71NwfYvBTniU6PDQE6jqm9fAGRWceOg0hHie2GQQfQiqyGtAyPyebINIEbcKKBmApf9c0M(cbsc3bJBxGCwSXOdhdNJlFeu4Eid0xSyL6NQx11BV(0QqUARTbXvpTt1RAbIPVqdCfwGa1G(ieHWguNHqfbcdCsdlfJiq8u0lqGKCJr7POxG20xiqs4oyC7cegWy4JZsgQtDu)Ot1JIJBN0W5ly3ee6GaZhXAKcetFHg4kSaHKQnsriSbvAsOIaHboPHLIreijChmUDbcdym8Xzjd1PoQN2P6rDg1JE9mGXWhNXmCgiq8u0lqG44KdyDSymdcriSb1bKqfbINIEbcehNCaRTOmhlqyGtAyPyeriSb1zvOIaXtrVabIPHteNM(MscxHbHaHboPHLIreHWguhycveiEk6fiqiD46fsh4on8eimWjnSumIieHaXcZPvH0dHkcBqvOIaXtrVabIBzzgRT2(wGaHboPHLIreHWgBfQiq8u0lqGCb7MGqGWaN0WsXiIqyd9eQiqyGtAyPyebINIEbcefhpKLAOfRLShecelmNwfsp0hNwG8eiOodriSr1cveimWjnSumIaXtrVabYz6eRDGul7elqSWCAvi9qFCAbYtGGQie2mdHkceg4KgwkgrGKWDW42fiykadTy4CwXXd1lKoiyTIFbJ1(D(DniZdevBzXsbINIEbcKJWLRAnPXL8jcHn0KqfbcdCsdlfJiqaUclqC6)iCSFAOfe6fsBTQzSaXtrVabIt)hHJ9tdTGqVqARvnJfHieiKuTrkurydQcveimWjnSumIajH7GXTlqol2y0HJHZXvpTt1BB9OxpARpCddImCZUkKgxYzg4KgwwV96D6NXDWzlgdTyp4m2bdRN2P6TTEykq8u0lqGCeu4Eid0xSyfriSXwHkceg4KgwkgrGKWDW42fiPDnYvniFmg7bl1KlG1NvpKZjchdNpne2trVa3upTt1BBEandbINIEbcKJXypyPMCbS(S6HSie2qpHkcepf9ceiWn7QqACjlqyGtAyPyeriSr1cveiEk6fiqi90WlCsbcdCsdlfJicriqsYtOIWgufQiqOowVqqA4jPWgufimWjnSumIajH7GXTlqOr9Kuqq5JWLRAT0bjotzvV96jPGGYhbfUhYaDSyGl3mLv92RNKcckFeu4Eid0XIbUCZywXBWv)Ot1tV8meiEk6fiqocxUQ1shKyriSXwHkceQJ1leKgEskSbvbcdCsdlfJiqs4oyC7ceskiO8rqH7Hmqhlg4YntzvV96jPGGYhbfUhYaDSyGl3mMv8gC1p6u90lpdbINIEbcKBSc5Ao9cPLSheIqyd9eQiqyGtAyPyebsc3bJBxGGIJBN0W5di1Pfi7Oxq92RNg1Fb7MGGLzfhegwG4POxGabY4WzJXJEbIqyJQfQiqyGtAyPyebsc3bJBxGizskiOmKXHZgJh9cYywXBWv)O1BB9WcB9sMKcckdzC4SX4rVG8fEAy90ovVQHHaXtrVabcKXHZgJh9c0jd7GJfHWMziurGWaN0WsXicKeUdg3UabT1JPam0IHZzfhpuVq6GG1k(fmw73531GmpquTLflR3E9PvHC1wBdIllzOo1r9Jovp9QhwyRhtbyOfdNZs2dcZy9r4Yv9L5bIQTSyz92RpTkKR2ABqC1pA9OwpmR3E9Kuqq5BSc5Ao9cPLShezkR6Txpjfeu(iC5QwlDqIZuw1BVEf)cgR9787AGgZkEdU6NQhg1BVEskiOSK9GWmwFeUCvFz5Qgiq8u0lqGGId6JqecBOjHkceg4KgwkgrG4POxGaj5gJ2trVaTPVqGKWDW42fi0O(ly3eeSm7gt92Rhfh3oPHZhqQtlq2rVG6Hf2657yqIZKy2dc9cPdcwlh3a4zfN(EX1BV(Ov46PDQEBfiM(cnWvybcFhds8jcHndiHkceg4KgwkgrGaTynGP5qydQcepf9ceiw7A0y(wkCIfijChmUDbcnQpCddI8r4YvTgAtuxMboPHLIqyZSkurGWaN0WsXicKeUdg3UaHbmg(46PDQEAcg1BVEuCC7KgoFaPoTazh9cQ3E9PDnYvniFJvixZPxiTK9GitzvV96t7AKRAq(iC5QwlDqIZjchdNV6PDQEufiEk6fiqockCpKb6yXaxUIqyZatOIaHboPHLIreijChmUDbckoUDsdNpGuNwGSJEb1BVEAuVCJ8XyShSutUawFw9qwl3ihDAydGxpSWwpudNi0ywXBWv)Ot1pdbINIEbcKJXypyPMCbS(S6HSajnozyD4y4CCcBqvecBqfgcveimWjnSumIajH7GXTlqqXXTtA48bK60cKD0lOE71tJ6t7AKRAq(iC5QwtACjFzkR6TxpARpCddImdqHnRvdGRpcxUQVmdCsdlRhwyRpTRrUQb5JWLRAT0bjoNiCmC(QN2P6rTEywV96rB90O(WnmiYhbfUhYaDSyGl3mdCsdlRhwyRpCddI8r4YvTgAtuxMboPHL1dlS1N21ix1G8rqH7Hmqhlg4YnJzfVbx90wVT1dZ6TxpARNg1JPam0IHZ5GG14ncgK5bIQTSyz9WcB9PvHC1wBdIR(rNQ326Hz92RhT1tJ657yqIZKMDL6fsheSMbSY4SItFV46Hf26t7AKRAqM0SRuVq6GG1mGvgNXSI3GREAR326HPaXtrVabYnwHCnNEH0s2dcriSbvufQiqyGtAyPyebsc3bJBxGG9wQzuyqKDP8Yuw1BVE0wF4y4CKJwH1XQLnx)O1NwfYvBTniUSKH6uh1dlS1tJ6VGDtqWYSBm1BV(0QqUARTbXLLmuN6OEANQpzPvCAwFwmqwpmfiEk6fiquC8qwQHwSwYEqiqsJtgwhogohNWgufHWguTvOIaHboPHLIreijChmUDbc2BPMrHbr2LYl3G6PTE6bJ6NT6XEl1mkmiYUuEzjf2JEb1BV(0QqUARTbXLLmuN6OEANQpzPvCAwFwmqkq8u0lqGO44HSudTyTK9GqecBqLEcveimWjnSumIajH7GXTlqqXXTtA48bK60cKD0lOE71NwfYvBTniUSKH6uh1t7u92kq8u0lqGCeUCvRjnUKpriSbvvlurGWaN0WsXicKeUdg3Uabfh3oPHZhqQtlq2rVG6TxFAvixT12G4YsgQtDupTt1tV6Tx)zXgJoCmCoU8rqH7HmqFXIvQF0P6vTaXtrVabcNi2gaxJzlCR4aPie2G6meQiqyGtAyPyebsc3bJBxGeUHbr(iC5QwdTjQlZaN0WY6TxpkoUDsdNpGuNwGSJEb1BVEskiO8nwHCnNEH0s2dImLLaXtrVabYrqH7Hmqhlg4YvecBqLMeQiqyGtAyPyebsc3bJBxGqJ6jPGGYhHlx1APdsCMYQE71d1WjcnMv8gC1p6u9ZA9OxF4gge5JImymefCoZaN0WsbINIEbcKJWLRAT0bjwecBqDajurG4POxGaXAJEbceg4KgwkgrecBqDwfQiqyGtAyPyebsc3bJBxGqsbbLVXkKR50lKwYEqKPSeiEk6fiqin7k1qu4XIqydQdmHkceg4KgwkgrGKWDW42fiKuqq5BSc5Ao9cPLShezklbINIEbcesgFmEydGlcHn2cdHkceg4KgwkgrGKWDW42fiKuqq5BSc5Ao9cPLShezklbINIEbceOgZKMDLIqyJTOkurGWaN0WsXicKeUdg3UaHKcckFJvixZPxiTK9Gitzjq8u0lqG4GeFb2n6KBmIqyJT2kurGWaN0WsXicKeUdg3UaHg1Fb7MGGLz3yQ3E9O442jnC(asDAbYo6fuV96Pr9Kuqq5BSc5Ao9cPLShezkR6Txpdym8Xzjd1PoQN2P6PhmeiEk6fiqsJtMnWlOtAsJFHaHHG4uObUclqsJtMnWlOtAsJFHie2yl9eQiqyGtAyPyebcWvybIt)hHJ9tdTGqVqARvnJfiEk6fiqC6)iCSFAOfe6fsBTQzSajH7GXTlqOr9Kuqq5JWLRAT0bjotzvV96t7AKRAq(gRqUMtVqAj7brgZkEdU6hTEuHHie2yRQfQiqyGtAyPyebcWvybIFeO4a(0yN(xSoTy3iq8u0lqG4hbkoGpn2P)fRtl2ncKeUdg3UarYKuqqzSt)lwNwSB0sMKccklx1G6Hf26LmjfeuoTajvkAuyDdgQLmjfeuMYQE71hogohzc2nbr2kf1pA90Z26TxF4y4CKjy3eezRuupTt1tpyupSWwpnQxYKuqq50cKuPOrH1nyOwYKuqqzkR6TxpARxYKuqqzSt)lwNwSB0sMKcckFHNgwpTt1B7mQF2QhvyupAOEjtsbbLjn7k1lKoiyndyLXzkR6Hf26HA4eHgZkEdU6hTEvdJ6Hz92RNKcckFJvixZPxiTK9GiJzfVbx90w)SkcHn2odHkceg4KgwkgrGaCfwGOmw6NoCtFkoqG4POxGarzS0pD4M(uCGie2ylnjurGWaN0WsXicKeUdg3UaHKcckFJvixZPxiTK9GitzvpSWwpudNi0ywXBWv)O1BlmeiEk6fiqOow3bRCIqecKly3ee6K8eQiSbvHkceg4KgwkgrGSwcKJdbINIEbceuCC7KgwGGIBOybsAxJCvdYhHlx1APdsCor4y48PHWEk6f4M6PDQEuZdOziqqXXAGRWcKJqQdcmFeRrkcHn2kurGWaN0WsXicKeUdg3UabT1tJ6rXXTtA48ri1bbMpI1iRhwyRNg1hUHbrg0WjIlCZqgNzGtAyz92RpCddIS0Xd1hHlx1zg4KgwwpmR3E9PvHC1wBdIllzOo1r90wpQ1BVEAupMcWqlgoNvC8q9cPdcwR4xWyTFNFxdY8ar1wwSuG4POxGabfh0hHie2qpHkcepf9ceihBD9jqyGtAyPyeriSr1cveimWjnSumIabAXAatZHWgufiEk6fiqS21OX8Tu4elqyAoWU2vwkqiqunmeHWMziurGWaN0WsXicKeUdg3UaHbmg(46PDQEvdJ6Txpdym8Xzjd1PoQN2P6rfg1BVEAupkoUDsdNpcPoiW8rSgz92RpTkKR2ABqCzjd1PoQN26rTE71lzskiOmudKA1SpeW3LXSI3GR(rRhvbINIEbcKJWLRAf2ifHWgAsOIaHboPHLIreiRLa54qG4POxGabfh3oPHfiO4gkwGKwfYvBTniUSKH6uh1t7u9QwGGIJ1axHfihHuNwfYvBTnioriSzajurGWaN0WsXicK1sGCCiq8u0lqGGIJBN0WceuCdflqsRc5QT2gexwYqDQJ6hDQEufiO4ynWvybYri1PvHC1wBdItGKWDW42fiO442jnCM6yTfUxChJ14n8OxGie2mRcveimWjnSumIajH7GXTlqqXXTtA48ri1PvHC1wBdIRE71J26rXXTtA48ri1bbMpI1iRhwyRNKcckFJvixZPxiTK9GiJzfVbx90ovpQzBRhwyR)SyJrhogohx(iOW9qgOVyXk1t7u9QUE71N21ix1G8nwHCnNEH0s2dImMv8gC1tB9OcJ6HPaXtrVabYr4YvTw6GelcHndmHkceg4KgwkgrGKWDW42fiO442jnC(iK60QqUARTbXvV96HA4eHgZkEdU6hT(0Ug5QgKVXkKR50lKwYEqKXSI3GtG4POxGa5iC5QwlDqIfHieiqnOpcHkcBqvOIaHboPHLIreijChmUDbYzXgJoCmCoU8rqH7HmqFXIvQF06PP6TxpnQNKcckFeUCvRLoiXzkR6Txpjfeu(mDI1oqQLDIZywXBWv)O1d1WjcnMv8gC1BVEskiO8z6eRDGul7eNXSI3GR(rRhT1JA9OxFAvixT12G4QhM1JgQh18Skq8u0lqGCMoXAhi1YoXIqyJTcveimWjnSumIazTeihhcepf9ceiO442jnSabf3qXcef)cgR9787AGgZkEdU6PTEyupSWwpnQpCddImOHtex4MHmoZaN0WY6TxF4ggezPJhQpcxUQZmWjnSSE71tsbbLpcxUQ1shK4mLv9WcB9NfBm6WXW54YhbfUhYa9flwPEANQNMeiO4ynWvybYnST0ykRGcZIqyd9eQiqyGtAyPyebsc3bJBxGqJ6rXXTtA48nST0ykRGcZ1BV(WXW5ihTcRJvlBU(zREmR4n4QN26PP6TxpMHW8r4KgwG4POxGabtzfuywecBuTqfbINIEbcKJtyo0bNia9arXceg4KgwkgrecBMHqfbcdCsdlfJiqs4oyC7ceAupkoUDsdNVHTLgtzfuyUE71tJ6rXXTtA4m1XAlCV4ogRXB4rVG6Tx)zXgJoCmCoU8rqH7HmqFXIvQN2P6TTE71hogoh5OvyDSAzZ1t7u9OT(zup61J26TTE0q9PvHC1wBdIREywpmR3E9ygcZhHtAybINIEbcemLvqHzbsACYW6WXW54e2GQie2qtcveimWjnSumIajH7GXTlqOr9O442jnC(g2wAmLvqH56TxpMv8gC1pA9PDnYvniFJvixZPxiTK9GiJzfVbx9OxpQWOE71N21ix1G8nwHCnNEH0s2dImMv8gC1p6u9ZOE71hogoh5OvyDSAzZ1pB1JzfVbx90wFAxJCvdY3yfY1C6fslzpiYywXBWvp61pdbINIEbcemLvqHzriSzajurGWaN0WsXicKeUdg3UaHg1JIJBN0WzQJ1w4EXDmwJ3WJEb1BV(ZIngD4y4CC1t7u90tG4POxGaH04PHARvTKXIqyZSkurG4POxGaHrPVeJ9GfimWjnSumIieHieiOW4RxGWgBHHTWavyGkQce1og0a4NazwGMIgTH(WMzj0N1xVkeC9TI1IJ6HwC9ZYKuTrolxpMhiQgZY6VvHR3PIvXdwwFIWbW5lxZrt0aUEuPpRhnYklkSSER96OxGM0tdRprWPH1JwWg17O4TXjnC9nOEwHY4rVaywpArLMHzUMxZPpuSwCWY6N169u0lOEtFXLR5cKZItcBSLMqvGyHxO2Wcevvpcfzy4yC9OXfofxZvv9OjtXsY46rfv6Q3wyylmQ51Cvv)SJ5zBawfspQ5Ek6fCzlmNwfspqFAq3YYmwBT9TGAUNIEbx2cZPvH0d0Ng8c2nbrn3trVGlBH50Qq6b6tdQ44HSudTyTK9GGolmNwfsp0hNwG8MqDg1Cpf9cUSfMtRcPhOpn4z6eRDGul7etNfMtRcPh6JtlqEtOwZ9u0l4YwyoTkKEG(0GhHlx1AsJl5JUgActbyOfdNZkoEOEH0bbRv8lyS2VZVRbzEGOAllwwZ9u0l4YwyoTkKEG(0GuhR7GvOd4k8Kt)hHJ9tdTGqVqARvnJR51Cvvp9L3G6rJB4rVGAUNIEb30WonSM7POxWH(0GO442jnmDaxHNoGuNwGSJEb0HIBO4jskiO8z6eRDGul7eNPSGf2ZIngD4y4CC5JGc3dzG(IfRq7enr3a)yz9XwVKdgR0aUE1eCqW46t7AKRAWvVAVJ6HwC9iGzwpPFSS(fuF4y4CC5AUQQFai40W6hGzE17r9qn(IAUNIEbh6tdMCJr7POxG20xqhWv4PK8Q5QQE0ifOEikJzC9N6ose8vFS1heC9ib7MGGL1Jg3WJEb1JwYX1l3gaV(BPRJ6HwCIV6T210a413q1d2GObWRVV6Du824KggM5AUNIEbh6tdIPaApf9c0M(c6aUcpDb7MGGL01qtxWUjiyz2nMAUQQhn1YYmU(Z0jw7aPw2jUEpQ3w0RFaM96Lu4gaV(GGRhQXxupQWO(JtlqE05qbJRpi8OEvJE9dWSxFdvFh1Z0SvJ5RE1Dq0G6dcUEatZr9ZsgGzw)IRVV6bBupLvn3trVGd9PbptNyTdKAzNy6AOPZIngD4y4CC5JGc3dzG(IfRmknzhQHteAmR4n4OLMStsbbLptNyTdKAzN4mMv8gCJcpjZkonBpTkKR2ABqC0oP6zdTrRWJIkmGjAW2AUQQhnjWmU(eHdGZ1J3WJEb13q1RMRNWrHR3c3lUJXA8gE0lO(JJ6DGSEfkt0wgU(WXW54QNYkxZ9u0l4qFAquCC7KgMoGRWtuhRTW9I7ySgVHh9cOdf3qXtw4EXDmwJ3WJEb2pl2y0HJHZXLpckCpKb6lwScTt2wZvv9ZoUxChJRhnUHh9cgWTE0eCmlF1dVrHR3RpHDR6DYLkQNbmg(46HwC9bbx)fSBcI6hGzE1JwsQ2izC9x0gt9y(S4uuFhWmx)Suuw01r9jhupjxFq4r9xRyz4Cn3trVGd9PbtUXO9u0lqB6lOd4k80fSBccDsE01qtO442jnCM6yTfUxChJ14n8Oxqnxv1pWpwwFS1lzOgW1RMGb1hB9uhx)fSBcI6hGzE1V46jPAJKXxn3trVGd9PbrXXTtAy6aUcpDb7MGqhey(iwJKouCdfpz7mqpCddImkn8fNzGtAyjAWwyGE4ggezf)cgRxi9r4Yv9LzGtAyjAWwyGE4gge5JWLRAn0MOUmdCsdlrd2od0d3WGi7gpH7yCMboPHLObBHb62od0aApl2y0HJHZXLpckCpKb6lwScTtQgM1Cvv)aSGRLmUEQRbWR3Rhjy3ee1paZSE1emOEm7jIgaV(GGRNbmg(46dcmFeRrwZ9u0l4qFAWKBmApf9c0M(c6aUcpDb7MGqNKhDn0edym8Xzjd1PogDcfh3oPHZxWUji0bbMpI1iR5QQEBA4eXS8v)agdGZoiX0N1JgPSckmxpjdTyUEKXkKR5Q3J6nR66hGzV(yRpTkKnGRNDSzC9ygcZhr9Q7GOE4CenaE9bbxpjfeu9uw56rtn3wVzvx)am71lPWnaE9iJvixZvpjhQzgu)mDqIV6v3br92IE92mGLR5QQEpf9co0NgetzfuyMUgAYPFg3bNbnCI40OWa4SdsCMboPHL2Pbjfeug0WjItJcdGZoiXzkl7PvHC1wBdIllzOo1bTOAhTNfBm6WXW54YhbfUhYa9flwzuBHfwuCC7KgotDS2c3lUJXA8gE0laM2rBAxJCvdY3yfY1C6fslzpiYywXBWn6e9Gfw060pJ7GZGgorCAuyaC2bjoJDWqANS1ojfeu(gRqUMtVqAj7brgZkEdoAPNDACb7MGGLz3ySN21ix1G8r4YvTw6GeNteogoFAiSNIEbUH2jyKhyWeM1Cpf9co0Ngm5gJ2trVaTPVGoGRWtqnOpc6AOjmfGHwmColzpimJ1hHlx1xMhiQ2YIL2LBKp266lhDAydGBxUr(yRRVmMv8gCJozR90QqUARTbXr7KT1Cpf9co0Ngm5gJ2trVaTPVGoGRWtqnOpc6AOP0Ug5QgKVXkKR50lKwYEqKXSI3GB0jBTNwfYvBTnioANS1oMcWqlgoNdcwJ3iyqMhiQ2YIL1Cpf9co0Ngm5gJ2trVaTPVGoGRWtqnOpc6AOP0QqUARTbXn5GwXteogol1jRAUQQFgOxV6oiQFMi1J2LkUwY1Fb7MGaM1Cpf9co0Ngm5gJ2trVaTPVGoGRWtqnOpc6AOP0QqUARTbXLLmuN6y0juHfwOgorOXSI3GB0juTNwfYvBTnioANOxnxv1JMBqFe17r9Qg96v3bXsf1ptKAUQQFw0br9ZePE3CB9qnOpI69OEvJE9oCVbxuptZEkmJRx11hogohx9ODPIRLC9xWUjiGzn3trVGd9PbtUXO9u0lqB6lOd4k8eud6JGUgA6SyJrhogohx(iOW9qgOVyXktQ2EAvixT12G4ODs11Cvv)a)4696jPAJKX1RMGb1Jzpr0a41heC9mGXWhxFqG5JynYAUNIEbh6tdMCJr7POxG20xqhWv4jsQ2iPRHMyaJHpolzOo1XOtO442jnC(c2nbHoiW8rSgznxv1JMyvZxuVfUxChJRVb17gt9lu9bbxpA6SJMOEso5uhxFh1NCQJV696NLmaZSM7POxWH(0Goo5awhlgZGGUgAIbmg(4SKH6uh0oH6mqNbmg(4mMHZGAUNIEbh6td64KdyTfL54AUNIEbh6tdAA4eXPPVPKWvyquZ9u0l4qFAqshUEH0bUtdVAEnxv1pa7AKRAWvZvv9d8JRFMoiX1VqqZg8KSEsgAXC9bbxpuJVO(JGc3dzG(IfRupeEvQxLfdC5wFAv4R(gKR5Ek6fC5K8qFAWJWLRAT0bjMoQJ1leKgEsoHkDn0eniPGGYhHlx1APdsCMYYojfeu(iOW9qgOJfdC5MPSStsbbLpckCpKb6yXaxUzmR4n4gDIE5zuZvv9ODGdm8D17gm7YX1tzvpjNCQJRxnxFS7W6riC5QUE08MOoywp1X1JmwHCnx9le0SbpjRNKHwmxFqW1d14lQ)iOW9qgOVyXk1dHxL6vzXaxU1Nwf(QVb5AUNIEbxojp0Ng8gRqUMtVqAj7bbDuhRxiin8KCcv6AOjskiO8rqH7Hmqhlg4YntzzNKcckFeu4Eid0XIbUCZywXBWn6e9YZOM7POxWLtYd9PbHmoC2y8OxaDn0ekoUDsdNpGuNwGSJEb2PXfSBccwMvCqy4AUNIEbxojp0NgeY4WzJXJEb6KHDWX01qtsMKcckdzC4SX4rVGmMv8gCJAlSWkzskiOmKXHZgJh9cYx4PH0oPAyuZ9u0l4Yj5H(0GO4G(iORHMqlMcWqlgoNvC8q9cPdcwR4xWyTFNFxdY8ar1wwS0EAvixT12G4YsgQtDm6e9GfwmfGHwmColzpimJ1hHlx1xMhiQ2YIL2tRc5QT2ge3OOct7Kuqq5BSc5Ao9cPLShezkl7Kuqq5JWLRAT0bjotzzxXVGXA)o)UgOXSI3GBcg2jPGGYs2dcZy9r4Yv9LLRAqn3trVGlNKh6tdMCJr7POxG20xqhWv4j(ogK4JUgAIgxWUjiyz2ng7O442jnC(asDAbYo6falS8DmiXzsm7bHEH0bbRLJBa8SItFVy7rRW0ozBnxv1p77AQhAX1RYIbUCR3cZZgYoZ6v3br9ieZSEm7YX1RMGb1d2OEmfa0a41JGMZ1Cpf9cUCsEOpnO1UgnMVLcNy6GwSgW0CmHkDn0enc3WGiFeUCvRH2e1LzGtAyznxv1pWpUEvwmWLB9wyUEKDM1RMGb1RMRNWrHRpi46zaJHpUE1eCqW46HWRs9w7AAa86v3bXsf1JGMRFX1tFtDr9WzaJDJzCUM7POxWLtYd9PbpckCpKb6yXaxU01qtmGXWht7enbd7O442jnC(asDAbYo6fypTRrUQb5BSc5Ao9cPLShezkl7PDnYvniFeUCvRLoiX5eHJHZhTtOwZ9u0l4Yj5H(0GhJXEWsn5cy9z1dz6sJtgwhogoh3eQ01qtO442jnC(asDAbYo6fyNgYnYhJXEWsn5cy9z1dzTCJC0PHnaoSWc1WjcnMv8gCJonJAUQQFGFC9iJvixZv)cQpTRrUQb1JwhkyC9qn(I6raZeM1tbm8D1RMR3XC9W3gaV(yR3ATQxLfdC5wVdK1l36bBupHJcxpcHlx11JM3e1LRhnXQU(by2RhAX1RcbxpACJGb5AUNIEbxojp0Ng8gRqUMtVqAj7bbDn0ekoUDsdNpGuNwGSJEb2PrAxJCvdYhHlx1AsJl5ltzzhTHByqKzakSzTAaC9r4Yv9LzGtAyjSWM21ix1G8r4YvTw6GeNteogoF0oHkmTJwAeUHbr(iOW9qgOJfdC5MzGtAyjSWgUHbr(iC5QwdTjQlZaN0WsyHnTRrUQb5JGc3dzGowmWLBgZkEdoATfM2rlnWuagAXW5CqWA8gbdY8ar1wwSewytRc5QT2ge3Ot2ct7OLg8DmiXzsZUs9cPdcwZawzCwXPVxmSWM21ix1GmPzxPEH0bbRzaRmoJzfVbhT2cZAUQQN(aQExkV6DmxpLfD1FG2IRpi46xaxV6oiQ3SQ5lQxfvMzU(b(X1RMGb1lh3a41d5xW46dchu)am71lzOo1r9lUEWg1Fb7MGGL1RUdILkQ3bJRFaM9Cn3trVGlNKh6tdQ44HSudTyTK9GGU04KH1HJHZXnHkDn0e2BPMrHbr2LYltzzhTHJHZroAfwhRw28OPvHC1wBdIllzOo1bSWsJly3eeSm7gJ90QqUARTbXLLmuN6G2PKLwXPz9zXajmR5QQE6dO6bB9UuE1RUnM6LnxV6oiAq9bbxpGP5OE6bJJU6PoUE6lOzw)cQNCVRE1DqSur9oyC9dWSNR5Ek6fC5K8qFAqfhpKLAOfRLShe01qtyVLAgfgezxkVCdOLEWy2WEl1mkmiYUuEzjf2JEb2tRc5QT2gexwYqDQdANswAfNM1NfdK1Cpf9cUCsEOpn4r4YvTM04s(ORHMqXXTtA48bK60cKD0lWEAvixT12G4YsgQtDq7KT1Cpf9cUCsEOpniNi2gaxJzlCR4ajDn0ekoUDsdNpGuNwGSJEb2tRc5QT2gexwYqDQdANON9ZIngD4y4CC5JGc3dzG(IfRm6KQR5QQ(zrhe1JGMPR(gQEWg17gm7YX1lxatx9uhxVklg4YTE1DqupYoZ6PSY1Cpf9cUCsEOpn4rqH7Hmqhlg4YLUgAkCddI8r4YvTgAtuxMboPHL2rXXTtA48bK60cKD0lWojfeu(gRqUMtVqAj7brMYQM7POxWLtYd9PbpcxUQ1shKy6AOjAqsbbLpcxUQ1shK4mLLDOgorOXSI3GB0Pzf9WnmiYhfzWyik4CMboPHL18AUQQ3MfmBNfNQ)ckiO6v3br9MvnJR3c3Bn3trVGlNKh6tdATrVGAUNIEbxojp0NgK0SRudrHhtxdnrsbbLVXkKR50lKwYEqKPSQ5Ek6fC5K8qFAqsgFmEydGtxdnrsbbLVXkKR50lKwYEqKPSQ5Ek6fC5K8qFAqOgZKMDL01qtKuqq5BSc5Ao9cPLShezkRAUNIEbxojp0Ng0bj(cSB0j3yORHMiPGGY3yfY1C6fslzpiYuw18AUNIEbxojp0NgK6yDhScDmeeNcnWv4P04Kzd8c6KM04xqxdnrJly3eeSm7gJDuCC7KgoFaPoTazh9cStdskiO8nwHCnNEH0s2dImLLDgWy4JZsgQtDq7e9Grn3trVGlNKh6tdsDSUdwHoGRWto9Feo2pn0cc9cPTw1mMUgAIgKuqq5JWLRAT0bjotzzpTRrUQb5BSc5Ao9cPLShezmR4n4gfvyuZvv9BqWy19X1RUdI6r2zwVh1B7mqV(l80WR(fxpQZa96v3br9U526hXSRSEkRCn3trVGlNKh6tdsDSUdwHoGRWt(rGId4tJD6FX60IDdDn0KKjPGGYyN(xSoTy3OLmjfeuwUQbWcRKjPGGYPfiPsrJcRBWqTKjPGGYuw2dhdNJmb7MGiBLIrPNT2dhdNJmb7MGiBLcANOhmGfwAizskiOCAbsQu0OW6gmulzskiOmLLD0kzskiOm2P)fRtl2nAjtsbbLVWtdPDY2zmBOcd0GKjPGGYKMDL6fsheSMbSY4mLfSWc1WjcnMv8gCJQAyat7Kuqq5BSc5Ao9cPLShezmR4n4ODwR5QQ(bmgpUE8sbNWmUEmLHRFHQpiOuiBOML1R4bXvpjBw10N1pWpUEOfxp9byO1kRpH7OM7POxWLtYd9PbPow3bRqhWv4jLXs)0HB6tXb1Cvv)mziNYe1d5gdPNgwp0IRN6CsdxFhSYrFw)a)46v3br9iJvixZv)cv)mzpiY1Cpf9cUCsEOpni1X6oyLJUgAIKcckFJvixZPxiTK9GitzblSqnCIqJzfVb3O2cJAEnxv1JMs)mUdU(bCUJbj(Q5Ek6fCz(ogK4d9PbtliXGa7bl1qgxHPRHMyaJHpohTcRJvR40mTOANgKuqq5BSc5Ao9cPLShezkl7OLgYnYPfKyqG9GLAiJRWAskmihDAydGBNgEk6fKtliXGa7bl1qgxHZnqdzA4ebSWcrzmAmNiCmCwhTcpk8KmR40mmR5Ek6fCz(ogK4d9Pbjn7k1lKoiyndyLX01qt0iTRrUQb5JWLRAnPXL8LPSSN21ix1G8nwHCnNEH0s2dImLfSWc1WjcnMv8gCJoHkmQ5Ek6fCz(ogK4d9PbHt5yz7a9cPD6NXBquZ9u0l4Y8DmiXh6tdcTjQJLAN(zChSMKDf6AOj0EwSXOdhdNJlFeu4Eid0xSyfANSfwyXEl1mkmiYUuE5gqlnbdyANgPDnYvniFJvixZPxiTK9GitzzNgKuqq5BSc5Ao9cPLShezkl7mGXWhNLmuN6G2j6bJAUNIEbxMVJbj(qFAqlkCdnUbW1Kg)c6AOPZIngD4y4CC5JGc3dzG(IfRq7KTWcl2BPMrHbr2LYl3aAPjyuZ9u0l4Y8DmiXh6tdgeSMcqUuaPgAXjMUgAIKcckJ50qdFNgAXjotzblSKuqqzmNgA470qloX60sbcgNVWtdhfvyuZ9u0l4Y8DmiXh6tdIBlldRBG(S8exZ9u0l4Y8DmiXh6tdQEXgjkCd0y(wGdsmDn0uAxJCvdY3yfY1C6fslzpiYywXBWn6mGfwOgorOXSI3GBuuN1AUNIEbxMVJbj(qFAqfwzXJ1lK2qLAPwIzx5ORHMyaJHpEuvdd7Kuqq5BSc5Ao9cPLShezkRAUQQFa)AK1Jgz3QbWRhnBCf(QhAX1Z0mNOcUESdGZ1V46h2gt9KuqqhD13q1BT31KgoxpAQrTp(QpWJRp26HZr9bbxVzvZxuFAxJCvdQN0pww)cQ3rXBJtA46zaR08LR5Ek6fCz(ogK4d9PbXSB1a4AiJRWhDn0eudNi0ywXBWnkQ5zalSOfTHJHZrMGDtqKTsbTZkmGf2WXW5itWUjiYwPy0jBHbmTJwpfnkSMbSsZ3eQWcludNi0ywXBWrRTdmyctyHfTHJHZroAfwhR2kfABHbT0dg2rRNIgfwZawP5BcvyHfQHteAmR4n4Ov1QgMWSMxZvv9ib7MGO(byxJCvdUAUNIEbx(c2nbHojp0Ngefh3oPHPd4k80ri1bbMpI1iPdf3qXtPDnYvniFeUCvRLoiX5eHJHZNgc7POxGBODc18aAg0nGNnwmU(bmh3oPHR5QQ(bmh0hr9nu9Q56DmxFYTSAa86xq9Z0bjU(eHJHZxU(bCCSzC9Km0I56HA8f1lDqIRVHQxnxpHJcxpyR3MgorCHBgY46jPI6NPJhwpcHlx113G6xSKX1hB9W5OE0iLvqH56PSQhTGTE6l)cgxpA6D(DnaM5AUNIEbx(c2nbHojp0Ngefh0hbDn0eAPbkoUDsdNpcPoiW8rSgjSWsJWnmiYGgorCHBgY4mdCsdlThUHbrw64H6JWLR6mdCsdlHP90QqUARTbXLLmuN6GwuTtdmfGHwmCoR44H6fsheSwXVGXA)o)UgK5bIQTSyzn3trVGlFb7MGqNKh6tdES11xn3trVGlFb7MGqNKh6tdATRrJ5BPWjMoOfRbmnhtOshtZb21UYsbIjvdd6M9Dn1dT46riC5QwHnY6rVEecxUQVa3d56Pag(U6vZ17yUENCPI6JT(KBv)cQFMoiX1NiCmC(Y1JMeygxVAcgupAUbY6NfSpeW3vFF17KlvuFS1JPa1VurUM7POxWLVGDtqOtYd9PbpcxUQvyJKUgAIbmg(yANunmSZagdFCwYqDQdANqfg2PbkoUDsdNpcPoiW8rSgP90QqUARTbXLLmuN6GwuTlzskiOmudKA1SpeW3LXSI3GBuuR5Ek6fC5ly3ee6K8qFAquCC7KgMoGRWthHuNwfYvBTnio6qXnu8uAvixT12G4YsgQtDq7KQPBaM96X8ar1ywHbb9z9Z0bjUEpQ3SQRFaM96jhxVKHCktKR5QQ(by2RhZdevJzfge0N1pthK46xGzC9Km0I56HAqFem(QVHQxnxpHJcxVfUxChJRhVHh9cY1Cpf9cU8fSBccDsEOpnikoUDsdthWv4PJqQtRc5QT2gehDO4gkEkTkKR2ABqCzjd1PogDcv6AOjuCC7KgotDS2c3lUJXA8gE0lOMRQ6NPdsC9skCdGxpYyfY1C1V46DYffU(GaZhXAK5AUNIEbx(c2nbHojp0Ng8iC5QwlDqIPRHMqXXTtA48ri1PvHC1wBdIZoArXXTtA48ri1bbMpI1iHfwskiO8nwHCnNEH0s2dImMv8gC0oHA2wyH9SyJrhogohx(iOW9qgOVyXk0oPA7PDnYvniFJvixZPxiTK9GiJzfVbhTOcdywZvv9JqHb1JzfVbnaE9Z0bj(QNKHwmxFqW1d1WjI6zG8QVHQhzNz9QxWSCupjxpMD546Bq9rRW5AUNIEbx(c2nbHojp0Ng8iC5QwlDqIPRHMqXXTtA48ri1PvHC1wBdIZoudNi0ywXBWnAAxJCvdY3yfY1C6fslzpiYywXBWvZR5QQEKGDtqWY6rJB4rVGAUQQN(aQEKGDtqmikoOpI6DmxpLfD1tDC9ieUCvFbUhY1hB9KmGH6OEi8QuFqW1B531OW1tUaQREhiRhn3az9Zc2hc47QNrHb13q1RMR3XC9EuVItZ1paZE9OfcVk1heC9wyoTkKEup9f0mHzUM7POxWLVGDtqWs0Ng8iC5Q(cCpKPRHMqljfeu(c2nbrMYcwyjPGGYO4G(iYuwWSMRQ6rZnOpI69OE6HE9dWSxV6oiwQO(zIu)G1RA0RxDhe1ptK6v3br9ieu4EidQxLfdC5wpjfeu9uw1hB9okBlR)wfU(by2RxTFbx)1bLh9cUCn3trVGlFb7MGGLOpnyYngTNIEbAtFbDaxHNGAqFe01qtKuqq5JGc3dzGowmWLBMYYEAvixT12G4YsgQtDm6KT1CvvpAQ526phIRp26HAqFe17r9Qg96hGzVE1DquptZEkmJRx11hogohxUE0I4kC9(v)sfxl56VGDtqKHzn3trVGlFb7MGGLOpnyYngTNIEbAtFbDaxHNGAqFe01qtNfBm6WXW54YhbfUhYa9flwzs12tRc5QT2gehTtQUMRQ6rZnOpI69OEvJE9dWSxV6oiwQO(zIuZvv9Za96v3br9ZePMRQ6DGSEAQE1Dqu)mrQ3Hcgx)aMd6JOM7POxWLVGDtqWs0Ngm5gJ2trVaTPVGoGRWtqnOpc6AOP0QqUARTbXLLmuN6y0juNn0gUHbrwYSfJ1xG9WHZkzg4KgwANKcckJId6JitzbZAUQQFGBvFS1tV6dhdNJR(HmBvpLv9O5giRFwW(qaFx9KJRpnozAa86riC5Q(cCpKZ1Cpf9cU8fSBccwI(0GhHlx1xG7HmDPXjdRdhdNJBcv6AOjjtsbbLHAGuRM9Ha(UmMv8gCJIQ9ZIngD4y4CC5JGc3dzG(IfRm6e9Shogoh5OvyDSAzZZgMv8gC0st1Cvv)SOdILkQFMmBX46rcShoCwPEhiRNE1JgDWWR(fQ(rmUKRVb1heC9ieUCvF13r99vV6fhe1tDnaE9ieUCvFbUhY1VG6Px9HJHZXLR5Ek6fC5ly3eeSe9PbpcxUQVa3dz6AOjAeUHbrwYSfJ1xG9WHZkzg4KgwA3PFg3bNjnUK1nqheS(iC5Q(YyhmCIE2pl2y0HJHZXLpckCpKb6lwSYe9Q5QQE08IR3c3lUJX1J3WJEb0vp1X1Jq4Yv9f4Eix)IcJRhjwSs9OcZ6v3br9Zc6R6D4EdUOEkR6JTEvxF4y4CC1CvvVTWS(gQE08SO((QhtbanaE9leu9ODb17GX17klfiQFHQpCmCooywZvv9lUE6bZ6JTEfNMBLM(56r2zwptZbdUEb1RUdI6PpamkD4KTPJX1VG6Px9HJHZXvpAvD9Q7GO(r6abM5AUNIEbx(c2nbblrFAWJWLR6lW9qMUgAcfh3oPHZuhRTW9I7ySgVHh9cSJwjtsbbLHAGuRM9Ha(UmMv8gCJIkSWgUHbrwn7wlqXVGXzg4KgwA)SyJrhogohx(iOW9qgOVyXkJoPAyH1PFg3bNBaJshozB6yCMboPHL2jPGGY3yfY1C6fslzpiYuw2pl2y0HJHZXLpckCpKb6lwSYOt0dDN(zChCM04sw3aDqW6JWLR6lZaN0WsywZ9u0l4YxWUjiyj6tdEeu4Eid0xSyf6AOPZIngD4y4CC0orp0rljfeu2cZkSSdp6fKPSGfwskiOCqWA8gbdYuwWclMcWqlgoN9HUJ7tFlLrdHD4kmiY8ar1wwS0EAbsQoYsMTySw6WHZ4lJDWqANgqWSM7POxWLVGDtqWs0Ng8iC5Q(cCpKPRHMKmjfeugQbsTA2hc47YywXBWn6eQWcBAxJCvdY3yfY1C6fslzpiYywXBWnkQZQDjtsbbLHAGuRM9Ha(UmMv8gCJM21ix1G8nwHCnNEH0s2dImMv8gC1CvvpcHlx1xG7HC9XwpMHW8rupAUbY6NfSpeW3vVdK1hB9m4OWC9Q56toO(KJXJRFrHX171drzm1JMNf13GyRpi46bmnh1JSZS(gQER9UM0W5AUNIEbx(c2nbblrFAqRDnAmFlfoX0bTynGP5yc1AUNIEbx(c2nbblrFAq4MDvinUKPRHMObMcWqlgoN9HUJ7tFlLrdHD4kmiY8ar1wwS0ojfeu2IXql2dwQrHBWLVWtdPDIE2tlqs1r2IXql2dwQrHBWLXoyiTtOsVzdTdm0qAbsQoYsMTySw6WHZ4mdCsdlrpTajvhzjZwmwlD4WzCg7GHWSM7POxWLVGDtqWs0NgeUzxfsJlz6AOjmfGHwmCo7dDh3N(wkJgc7WvyqK5bIQTSyPDskiOSfJHwShSuJc3GlFHNgs7e9SJ20cKuDKTym0I9GLAu4gCzSdgIEAbsQoYsMTySw6WHZ4m2bdHjTtOst1Cpf9cU8fSBccwI(0GhHlx1xG7HCnVMRQ6rZnOpcgF1Cpf9cUmud6Ja9PbptNyTdKAzNy6AOPZIngD4y4CC5JGc3dzG(IfRmknzNgKuqq5JWLRAT0bjotzzNKcckFMoXAhi1YoXzmR4n4gfQHteAmR4n4StsbbLptNyTdKAzN4mMv8gCJIwurpTkKR2ABqCWenGAEwR5Ek6fCzOg0hb6tdIIJBN0W0bCfE6g2wAmLvqHz6qXnu8KIFbJ1(D(DnqJzfVbhTWawyPr4ggezqdNiUWndzCMboPHL2d3WGilD8q9r4YvDMboPHL2jPGGYhHlx1APdsCMYcwypl2y0HJHZXLpckCpKb6lwScTt0eDd4zJfJRFaZXTtA46HwC9OrkRGcZ56rg2w1lPWnaE90x(fmUE00787Aq9lUEjfUbWRFMoiX1RUdI6NPJhwVdK1d26TPHtex4MHmoxZvv9ZsZSv9uw1JgPSckmxFdvFh13x9o5sf1hB9ykq9lvKR5Ek6fCzOg0hb6tdIPSckmtxdnrduCC7KgoFdBlnMYkOWS9WXW5ihTcRJvlBE2WSI3GJwAYoMHW8r4KgUM7POxWLHAqFeOpn4Xjmh6GteGEGO4AUQQN(IYeTCJObWRpCmCoU6dcpQxDBm1BAu46HwC9bbxVKc7rVG6xO6rJuwbfMRhZqy(iQxsHBa86TCGKv6uUM7POxWLHAqFeOpniMYkOWmDPXjdRdhdNJBcv6AOjAGIJBN0W5ByBPXuwbfMTtduCC7KgotDS2c3lUJXA8gE0lW(zXgJoCmCoU8rqH7HmqFXIvODYw7HJHZroAfwhRw2mTtODgOJwBrdPvHC1wBdIdMW0oMHW8r4KgUMRQ6rJmeMpI6rJuwbfMRNDSzC9nu9DuV62yQNPzRgZ1lPWnaE9iJvixZLRFMB9bHh1JzimFe13q1JSZSE4CC1JzxoU(guFqW1dyAoQFgxUM7POxWLHAqFeOpniMYkOWmDn0enqXXTtA48nST0ykRGcZ2XSI3GB00Ug5QgKVXkKR50lKwYEqKXSI3GdDuHH90Ug5QgKVXkKR50lKwYEqKXSI3GB0PzypCmCoYrRW6y1YMNnmR4n4OnTRrUQb5BSc5Ao9cPLShezmR4n4qFg1Cpf9cUmud6Ja9PbjnEAO2AvlzmDn0enqXXTtA4m1XAlCV4ogRXB4rVa7NfBm6WXW54ODIE1Cpf9cUmud6Ja9Pbzu6lXyp4AEnxv1pcvBKm(Q5Ek6fCzsQ2irFAWJGc3dzG(IfRqxdnDwSXOdhdNJJ2jBrhTHByqKHB2vH04soZaN0Ws7o9Z4o4SfJHwShCg7GH0ozRDR96OxGM0tdHzn3trVGlts1gj6tdEmg7bl1KlG1NvpKPRHMs7AKRAq(ym2dwQjxaRpREiNteogoFAiSNIEbUH2jBZdOzuZ9u0l4YKuTrI(0GWn7QqACjxZ9u0l4YKuTrI(0GKEA4foPieHqa]] )


end
