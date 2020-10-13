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


    spec:RegisterPack( "Subtlety", 20201013, [[daf3YbqiKcpsKWMeP(KIsuJcb1PafTkeeEfc1SqQClfLYUe1VuGggOWXqiltb8mKIMMijxtrHTHufFtKigNIs6CIeP1Huv08uiDpfzFiL(NiPs6GiiPfQq8qrIAIkk6IIKkXgrqQpQOeXifjvQtIuvyLkQEPIsKAMiiHBIuvYojj9teKOHQOuTuee9uiMkjXvfjvTvrsfFvrjCwfLizVe(lPgSQomvlgrpMstMOlJAZG8zq1OH0PLA1ivL61kOztXTjXUb(TsdxehxKuwoupxLPlCDKSDe47KuJhPkDEfQ1JuvnFqP9lzbrcveispyHQdaJbGbrWGiAMHrkLMdKkIeiX4ewGK42HoCwGaCfwGGqrggoglqs8XM1Lcvei3sHTSabnIKJ(CWbH3bkfz2UkdETcLXJEbwSdfdETIDqbcjvBc6dGGuGi9GfQoamgagebdIOzggPuAoanhqG4ub6IfiiTsklqqBPKbcsbIKpRajf1JqrggogxpHCHtX18uupHsBSKmUEIOjD1pamgagcetFXjurGCb7MaLLcveQsKqfbcdCsdlfJiqS4oyC7cecxpjfeu(c2nbAMkPEyHTEskiOmboOp0mvs9WuG42OxGa5qD5Q(cCpKfHq1beQiqyGtAyPyebIf3bJBxGqsbbLpukCpKb6yXaxUzQK6txVDvixDY2G4YsgQTDu)Ot1pGaXTrVabI1ngTBJEbAtFHaX0xObUclqGAqFOIqOknfQiqyGtAyPyebIf3bJBxGCjSXOdhdNJlFOu4Eid0xSyL6NQpv1NUE7QqU6KTbXvpTt1NkbIBJEbceRBmA3g9c0M(cbIPVqdCfwGa1G(qfHq1ujurGWaN0WsXicelUdg3UaXUkKRozBqCzjd12oQF0P6jQ(zREcxF4ggezjZjmwFb2dhoRKzGtAyz9PRNKccktGd6dntLupmfiUn6fiqSUXODB0lqB6leiM(cnWvybcud6dvecvNHqfbcdCsdlfJiqCB0lqGCOUCvFbUhYcelUdg3UarYKuqqzOgi1QzFiGVlJzfVbx9Jwpr1NU(lHngD4y4CC5dLc3dzG(IfRu)Ot1tZ6txF4y4CKJwH1XQLnx)SvpMv8gC1tB90JaXo2AyD4y4CCcvjsecvPhHkceg4KgwkgrGyXDW42fi0O(WnmiYsMtyS(cShoCwjZaN0WY6txVt)mUdotACjRBGoqz9H6Yv9LXoyy9t1tZ6tx)LWgJoCmCoU8HsH7HmqFXIvQFQEAkqCB0lqGCOUCvFbUhYIqOAkrOIaHboPHLIreiwChmUDbcboUDsdNPowNG7f3XynEdp6fuF66jC9sMKcckd1aPwn7db8DzmR4n4QF06jQEyHT(WnmiYQzpzbk(fmoZaN0WY6tx)LWgJoCmCoU8HsH7HmqFXIvQF0P6tv9WcB9o9Z4o4Cdyc6WjBthJZmWjnSS(01tsbbLVXkKR50lKwYEGMPsQpD9xcBm6WXW54YhkfUhYa9flwP(rNQNM1tC9o9Z4o4mPXLSUb6aL1hQlx1xMboPHL1dtbIBJEbcKd1LR6lW9qwecvNvHkceg4KgwkgrGyXDW42fixcBm6WXW54QN2P6Pz9expHRNKcckNGzfw2Hh9cYuj1dlS1tsbbLduwJ3iyqMkPEyHTEmfGHwmCo7dDh3N(wkJgc7WvyqK5uJQtsyz9PR3UajvhzjZjmwlD4Wz8LXoyy90ovFkPEykqCB0lqGCOu4Eid0xSyfriunLkurGWaN0WsXicelUdg3UarYKuqqzOgi1QzFiGVlJzfVbx9Jovpr1dlS1B31ix1G8nwHCnNEH0s2d0mMv8gC1pA9enR1NUEjtsbbLHAGuRM9Ha(UmMv8gC1pA92DnYvniFJvixZPxiTK9anJzfVbNaXTrVabYH6Yv9f4EilcHQebdHkceg4KgwkgrGaTynGP3qOkrce3g9ceij7A0y(wkSLfHqvIisOIaHboPHLIreiwChmUDbcnQhtbyOfdNZ(q3X9PVLYOHWoCfgezo1O6KewwF66jPGGYjmgAXEWsnbCdU8fUDy90ovpnRpD92fiP6iNWyOf7bl1eWn4YyhmSEANQNiAw)SvpHRpLwpHOE7cKuDKLmNWyT0HdNXzg4KgwwpX1BxGKQJSK5egRLoC4moJDWW6HPaXTrVabcCZUkKgxYIqOkrdiurGWaN0WsXicelUdg3UabtbyOfdNZ(q3X9PVLYOHWoCfgezo1O6KewwF66jPGGYjmgAXEWsnbCdU8fUDy90ovpnRpD9eUE7cKuDKtym0I9GLAc4gCzSdgwpX1BxGKQJSK5egRLoC4moJDWW6Hz90ovpr0JaXTrVabcCZUkKgxYIqOkr0uOIaXTrVabYH6Yv9f4EilqyGtAyPyericbcFhdS8jurOkrcveimWjnSumIaXI7GXTlqyaJHpohTcRJvR40B90wpr1NUEAupjfeu(gRqUMtVqAj7bAMkP(01t46Pr9YnY2fyzqG9GLAiJRWAskmihTDydGxF66Pr9Un6fKTlWYGa7bl1qgxHZnqdzA4Or9WcB9qugJgZwuhdN1rRW1pA9WTYSItV1dtbIBJEbce7cSmiWEWsnKXvyriuDaHkceg4KgwkgrGyXDW42fi0OE7Ug5QgKpuxUQ1KgxYxMkP(01B31ix1G8nwHCnNEH0s2d0mvs9WcB9qnC0qJzfVbx9JovprWqG42OxGaH0SRuVq6aL1mGvglcHQ0uOIaXTrVabcCkhlBhOxiTt)mEdubcdCsdlfJicHQPsOIaHboPHLIreiwChmUDbcHR)syJrhogohx(qPW9qgOVyXk1t7u9dupSWwp2BPMjGbr2LYl3G6PTE6bg1dZ6txpnQ3URrUQb5BSc5Ao9cPLShOzQK6txpnQNKcckFJvixZPxiTK9antLuF66zaJHpolzO22r90ovpnHHaXTrVabc0APowQD6NXDWAs2veHq1ziurGWaN0WsXicelUdg3Ua5syJrhogohx(qPW9qgOVyXk1t7u9dupSWwp2BPMjGbr2LYl3G6PTE6bgce3g9ceiju4gACdGRjn(fIqOk9iurGWaN0WsXicelUdg3UaHKcckJz7qdFNgAXwotLupSWwpjfeugZ2Hg(on0ITS2UuGGX5lC7W6hTEIGHaXTrVabsGYAka5sbKAOfBzriunLiurG42OxGab3jjgw3a9L4wwGWaN0WsXiIqO6SkurGWaN0WsXicelUdg3UaXURrUQb5BSc5Ao9cPLShOzmR4n4QF06Nr9WcB9qnC0qJzfVbx9JwprZQaXTrVabI6fBKeWnqJ5BboWYIqOAkvOIaHboPHLIreiwChmUDbcdym8X1pA9Pcg1NUEskiO8nwHCnNEH0s2d0mvIaXTrVabIcRS4X6fsBOSTulXSRCIqOkrWqOIaHboPHLIreiwChmUDbcudhn0ywXBWv)O1tuEg1dlS1t46jC9HJHZrgLDtGMtSr90w)ScJ6Hf26dhdNJmk7ManNyJ6hDQ(bGr9WS(01t46DB0eWAgWknF1pvpr1dlS1d1WrdnMv8gC1tB9dKsRhM1dZ6Hf26jC9HJHZroAfwhRoXg6bGr90wpnHr9PRNW172OjG1mGvA(QFQEIQhwyRhQHJgAmR4n4QN26tvQQhM1dtbIBJEbcem7jnaUgY4k8jcriqKmKtzcHkcvjsOIaXTrVabYW2ouGWaN0WsXiIqO6acveimWjnSumIazteihhce3g9ceie442jnSaHa3qXceskiO8zAlRDGulBlNPsQhwyR)syJrhogohx(qPW9qgOVyXk1t7u90JaHahRbUclqoGuBxGSJEbIqOknfQiqyGtAyPyebIBJEbceRBmA3g9c0M(cbIPVqdCfwGyLNieQMkHkceg4KgwkgrGyXDW42fixWUjqzz2ngbIBJEbcemfq72OxG20xiqm9fAGRWcKly3eOSuecvNHqfbcdCsdlfJiqS4oyC7cKlHngD4y4CC5dLc3dzG(IfRu)O1tp1NUEOgoAOXSI3GREARNEQpD9Kuqq5Z0ww7aPw2woJzfVbx9JwpCRmR40B9PR3UkKRozBqC1t7u9PQ(zREcxF0kC9JwprWOEywpHO(beiUn6fiqotBzTdKAzBzriuLEeQiqyGtAyPyebYMiqooeiUn6fiqiWXTtAybcbUHIfij4EXDmwJ3WJEb1NU(lHngD4y4CC5dLc3dzG(IfRupTt1pGaHahRbUclqOowNG7f3XynEdp6ficHQPeHkceg4KgwkgrGyXDW42fie442jnCM6yDcUxChJ14n8OxGaXTrVabI1ngTBJEbAtFHaX0xObUclqUGDtGQTYtecvNvHkceg4KgwkgrGSjcKJdbIBJEbcecCC7KgwGqGBOybYaZOEIRpCddImbn8fNzGtAyz9eI6hag1tC9HByqKv8lySEH0hQlx1xMboPHL1tiQFayupX1hUHbr(qD5QwdTwQlZaN0WY6je1pWmQN46d3WGi7g3I7yCMboPHL1tiQFayupX1pWmQNqupHR)syJrhogohx(qPW9qgOVyXk1t7u9PQEykqiWXAGRWcKly3eO6afZh6AKIqOAkvOIaHboPHLIreiwChmUDbcdym8Xzjd12oQF0P6jWXTtA48fSBcuDGI5dDnsbIBJEbceRBmA3g9c0M(cbIPVqdCfwGCb7MavBLNieQsemeQiqyGtAyPyebIf3bJBxGGPam0IHZzj7bQzS(qD5Q(YCQr1jjSS(01l3iFCY1xoA7WgaV(01l3iFCY1xgZkEdU6hDQ(bQpD92vHC1jBdIREANQFabIBJEbceRBmA3g9c0M(cbIPVqdCfwGa1G(qfHqvIisOIaHboPHLIreiwChmUDbIDxJCvdY3yfY1C6fslzpqZywXBWv)Ot1pq9PR3UkKRozBqC1t7u9duF66XuagAXW5CGYA8gbdYCQr1jjSuG42OxGaX6gJ2TrVaTPVqGy6l0axHfiqnOpuriuLObeQiqyGtAyPyebIf3bJBxGyxfYvNSniU6NQ3bTIBrDmCwQTjce3g9ceiw3y0Un6fOn9fcetFHg4kSabQb9HkcHQertHkceg4KgwkgrGyXDW42fi2vHC1jBdIllzO22r9Jovpr1dlS1d1WrdnMv8gC1p6u9evF66TRc5Qt2gex90ovpnfiUn6fiqSUXODB0lqB6leiM(cnWvybcud6dvecvjkvcveimWjnSumIaXI7GXTlqUe2y0HJHZXLpukCpKb6lwSs9t1NQ6txVDvixDY2G4QN2P6tLaXTrVabI1ngTBJEbAtFHaX0xObUclqGAqFOIqOkrZqOIaHboPHLIreiwChmUDbcdym8Xzjd12oQF0P6jWXTtA48fSBcuDGI5dDnsbIBJEbceRBmA3g9c0M(cbIPVqdCfwGqs1gPieQse9iurGWaN0WsXicelUdg3UaHbmg(4SKHABh1t7u9enJ6jUEgWy4JZygodeiUn6fiqCS1bSowmMbHieQsukrOIaXTrVabIJToG1juMJfimWjnSumIieQs0SkurG42OxGaX0WrJttFtjHRWGqGWaN0WsXiIqOkrPuHkce3g9ceiKoC9cPdCBhEceg4KgwkgreIqGKGz7Qq6HqfHQejurG42OxGaXtsmJ1jBFlqGWaN0WsXiIqO6acveiUn6fiqUGDtGkqyGtAyPyeriuLMcveimWjnSumIaXTrVabIIJhYsn0I1s2dubscMTRcPh6JTlqEceIMHieQMkHkceg4KgwkgrG42OxGa5mTL1oqQLTLfijy2UkKEOp2Ua5jqisecvNHqfbcdCsdlfJiqS4oyC7cemfGHwmCoR44H6fshOSwXVGXA)o)UgK5uJQtsyPaXTrVabYH6YvTM04s(eHqv6rOIaHboPHLIreiaxHfio9FOo2pn0cc9cPtw1mwG42OxGaXP)d1X(PHwqOxiDYQMXIqeceOg0hQqfHQejurGWaN0WsXicelUdg3Ua5syJrhogohx(qPW9qgOVyXk1pA90t9PRNg1tsbbLpuxUQ1shy5mvs9PRNKcckFM2YAhi1Y2YzmR4n4QF06HA4OHgZkEdU6txpjfeu(mTL1oqQLTLZywXBWv)O1t46jQEIR3UkKRozBqC1dZ6je1tuEwfiUn6fiqotBzTdKAzBzriuDaHkceg4KgwkgrGSjcKJdbIBJEbcecCC7KgwGqGBOybIIFbJ1(D(DnqJzfVbx90wpmQhwyRNg1hUHbrg0WrJlCZqgNzGtAyz9PRpCddIS0Xd1hQlx1zg4KgwwF66jPGGYhQlx1APdSCMkPEyHT(lHngD4y4CC5dLc3dzG(IfRupTt1tpcecCSg4kSa5g2jAmvsqHzriuLMcveimWjnSumIaXI7GXTlqOr9e442jnC(g2jAmvsqH56txF4y4CKJwH1XQLnx)SvpMv8gC1tB90t9PRhZqy(qDsdlqCB0lqGGPsckmlcHQPsOIaXTrVabYXwmh6GTOGo1OybcdCsdlfJicHQZqOIaHboPHLIreiUn6fiqWujbfMfiwChmUDbcnQNah3oPHZ3WorJPsckmxF66Pr9e442jnCM6yDcUxChJ14n8Oxq9PR)syJrhogohx(qPW9qgOVyXk1t7u9duF66dhdNJC0kSowTS56PDQEcx)mQN46jC9dupHOE7QqU6KTbXvpmRhM1NUEmdH5d1jnSaXo2AyD4y4CCcvjsecvPhHkceg4KgwkgrGyXDW42fi0OEcCC7KgoFd7enMkjOWC9PRhZkEdU6hTE7Ug5QgKVXkKR50lKwYEGMXSI3GREIRNiyuF66T7AKRAq(gRqUMtVqAj7bAgZkEdU6hDQ(zuF66dhdNJC0kSowTS56NT6XSI3GREAR3URrUQb5BSc5Ao9cPLShOzmR4n4QN46NHaXTrVabcMkjOWSieQMseQiqyGtAyPyebIf3bJBxGqJ6jWXTtA4m1X6eCV4ogRXB4rVG6tx)LWgJoCmCoU6PDQEAkqCB0lqGqAC7qDYQwYyriuDwfQiqCB0lqGWe0NLXEWceg4KgwkgreIqGyLNqfHQejurGWaN0WsXicelUdg3UaHg1tsbbLpuxUQ1shy5mvs9PRNKcckFOu4Eid0XIbUCZuj1NUEskiO8HsH7Hmqhlg4YnJzfVbx9JovpnZZqG42OxGa5qD5QwlDGLfiuhRxiinCRuOkrIqO6acveimWjnSumIaXI7GXTlqiPGGYhkfUhYaDSyGl3mvs9PRNKcckFOu4Eid0XIbUCZywXBWv)Ot1tZ8meiUn6fiqUXkKR50lKwYEGkqOowVqqA4wPqvIeHqvAkurGWaN0WsXicelUdg3UaHah3oPHZhqQTlq2rVG6txpnQ)c2nbklZkoimSaXTrVabcKXHZgJh9ceHq1ujurGWaN0WsXicelUdg3UarYKuqqziJdNngp6fKXSI3GR(rRFG6Hf26LmjfeugY4WzJXJEb5lC7W6PDQ(ubdbIBJEbceiJdNngp6fOTg2bhlcHQZqOIaHboPHLIreiwChmUDbcHRhtbyOfdNZkoEOEH0bkRv8lyS2VZVRbzo1O6KewwF66TRc5Qt2gexwYqTTJ6hDQEAwpSWwpMcWqlgoNLShOMX6d1LR6lZPgvNKWY6txVDvixDY2G4QF06jQEywF66jPGGY3yfY1C6fslzpqZuj1NUEskiO8H6YvTw6alNPsQpD9k(fmw73531anMv8gC1pvpmQpD9Kuqqzj7bQzS(qD5Q(YYvnqG42OxGaHah0hQieQspcveimWjnSumIaXI7GXTlqOr9xWUjqzz2nM6txpboUDsdNpGuBxGSJEb1dlS1Z3XalNjXShO6fshOSwoUbWZko99IRpD9rRW1t7u9diqCB0lqGyDJr72OxG20xiqm9fAGRWce(ogy5tecvtjcveimWjnSumIaXTrVabsYUgnMVLcBzbIf3bJBxGqJ6d3WGiFOUCvRHwl1LzGtAyPabAXAatVHqvIeHq1zvOIaHboPHLIreiwChmUDbcdym8X1t7u90dmQpD9e442jnC(asTDbYo6fuF66T7AKRAq(gRqUMtVqAj7bAMkP(01B31ix1G8H6YvTw6alNTOogoF1t7u9ejqCB0lqGCOu4Eid0XIbUCfHq1uQqfbcdCsdlfJiqCB0lqGCmg7bl1KlG1xspKfiwChmUDbcboUDsdNpGuBxGSJEb1NUEAuVCJ8XyShSutUawFj9qwl3ihTDydGxpSWwpudhn0ywXBWv)Ot1pdbIDS1W6WXW54eQsKieQsemeQiqyGtAyPyebIf3bJBxGqGJBN0W5di12fi7Oxq9PRNg1B31ix1G8H6YvTM04s(Yuj1NUEcxF4ggezgqaB2KgaxFOUCvFzg4KgwwpSWwVDxJCvdYhQlx1APdSC2I6y48vpTt1tu9WS(01t46Pr9HByqKpukCpKb6yXaxUzg4KgwwpSWwF4gge5d1LRAn0APUmdCsdlRhwyR3URrUQb5dLc3dzGowmWLBgZkEdU6PT(bQhM1NUEcxpnQhtbyOfdNZbkRXBemiZPgvNKWY6Hf26TRc5Qt2gex9Jov)a1dZ6txpHRNg1Z3XalNjn7k1lKoqzndyLXzfN(EX1dlS1B31ix1GmPzxPEH0bkRzaRmoJzfVbx90w)a1dtbIBJEbcKBSc5Ao9cPLShOIqOkrejurGWaN0WsXice3g9ceikoEil1qlwlzpqfiwChmUDbc2BPMjGbr2LYltLuF66jC9HJHZroAfwhRw2C9JwVDvixDY2G4YsgQTDupSWwpnQ)c2nbklZUXuF66TRc5Qt2gexwYqTTJ6PDQEBIwXPx9LWaz9WuGyhBnSoCmCooHQejcHQenGqfbcdCsdlfJiqS4oyC7ceS3sntadISlLxUb1tB90eg1pB1J9wQzcyqKDP8YskSh9cQpD92vHC1jBdIllzO22r90ovVnrR40R(syGuG42OxGarXXdzPgAXAj7bQieQsenfQiqyGtAyPyebIf3bJBxGqGJBN0W5di12fi7Oxq9PR3UkKRozBqCzjd12oQN2P6hqG42OxGa5qD5QwtACjFIqOkrPsOIaHboPHLIreiwChmUDbcboUDsdNpGuBxGSJEb1NUE7QqU6KTbXLLmuB7OEANQNM1NU(lHngD4y4CC5dLc3dzG(IfRu)Ot1NkbIBJEbce2IUnaUgZj4wXbsriuLOziurGWaN0WsXicelUdg3UajCddI8H6YvTgATuxMboPHL1NUEcCC7KgoFaP2Uazh9cQpD9Kuqq5BSc5Ao9cPLShOzQebIBJEbcKdLc3dzGowmWLRieQse9iurGWaN0WsXicelUdg3UaHg1tsbbLpuxUQ1shy5mvs9PRhQHJgAmR4n4QF0P6N16jU(WnmiYhfzWyik4CMboPHLce3g9ceihQlx1APdSSieQsukrOIaXTrVabsYg9ceimWjnSumIieQs0SkurGWaN0WsXicelUdg3UaHKcckFJvixZPxiTK9antLiqCB0lqGqA2vQHOWJfHqvIsPcveimWjnSumIaXI7GXTlqiPGGY3yfY1C6fslzpqZujce3g9ceiKm(y8WgaxecvhagcveimWjnSumIaXI7GXTlqiPGGY3yfY1C6fslzpqZujce3g9ceiqnMjn7kfHq1bisOIaHboPHLIreiwChmUDbcjfeu(gRqUMtVqAj7bAMkrG42OxGaXbw(cSB0w3yeHq1bgqOIaHboPHLIreiUn6fiqSJTMnWlOTAsJFHaXI7GXTlqOr9xWUjqzz2nM6txpboUDsdNpGuBxGSJEb1NUEAupjfeu(gRqUMtVqAj7bAMkP(01ZagdFCwYqTTJ6PDQEAcdbcdbX2qdCfwGyhBnBGxqB1Kg)criuDaAkurGWaN0WsXice3g9ceio9FOo2pn0cc9cPtw1mwGyXDW42fi0OEskiO8H6YvTw6alNPsQpD92DnYvniFJvixZPxiTK9anJzfVbx9JwprWqGaCfwG40)H6y)0qli0lKozvZyriuDGujurGWaN0WsXice3g9cei(HsGd4tJD6FXA7IDJaXI7GXTlqKmjfeug70)I12f7gTKjPGGYYvnOEyHTEjtsbbLTlqszJMaw3GHAjtsbbLPsQpD9HJHZrgLDtGMtSr9JwpnhO(01hogohzu2nbAoXg1t7u90eg1dlS1tJ6Lmjfeu2UajLnAcyDdgQLmjfeuMkP(01t46Lmjfeug70)I12f7gTKjPGGYx42H1t7u9dmJ6NT6jcg1tiQxYKuqqzsZUs9cPduwZawzCMkPEyHTEOgoAOXSI3GR(rRpvWOEywF66jPGGY3yfY1C6fslzpqZywXBWvpT1pRceGRWce)qjWb8PXo9VyTDXUrecvhygcveimWjnSumIab4kSarzS0pD4M(uCGaXTrVabIYyPF6Wn9P4ariuDa6rOIaHboPHLIreiwChmUDbcjfeu(gRqUMtVqAj7bAMkPEyHTEOgoAOXSI3GR(rRFayiqCB0lqGqDSUdw5eHieixWUjq1w5jurOkrcveimWjnSumIazteihhce3g9ceie442jnSaHa3qXce7Ug5QgKpuxUQ1shy5Sf1XW5tdHDB0lWn1t7u9eLtjZqGqGJ1axHfihQuhOy(qxJuecvhqOIaHboPHLIreiwChmUDbcHRNg1tGJBN0W5dvQdumFORrwpSWwpnQpCddImOHJgx4MHmoZaN0WY6txF4ggezPJhQpuxUQZmWjnSSEywF66TRc5Qt2gexwYqTTJ6PTEIQpD90OEmfGHwmCoR44H6fshOSwXVGXA)o)UgK5uJQtsyPaXTrVabcboOpuriuLMcveiUn6fiqoo56tGWaN0WsXiIqOAQeQiqyGtAyPyebIBJEbcKKDnAmFlf2YceMEdSRDLLcecKubdbc0I1aMEdHQejcHQZqOIaHboPHLIreiwChmUDbcdym8X1t7u9Pcg1NUEgWy4JZsgQTDupTt1temQpD90OEcCC7KgoFOsDGI5dDnY6txVDvixDY2G4YsgQTDupT1tu9PRxYKuqqzOgi1QzFiGVlJzfVbx9Jwprce3g9ceihQlx1kSrkcHQ0JqfbcdCsdlfJiq2ebYXHaXTrVabcboUDsdlqiWnuSaXUkKRozBqCzjd12oQN2P6tLaHahRbUclqouP2UkKRozBqCIqOAkrOIaHboPHLIreiBIa54qG42OxGaHah3oPHfie4gkwGyxfYvNSniUSKHABh1p6u9ejqS4oyC7cecCC7KgotDSob3lUJXA8gE0lqGqGJ1axHfihQuBxfYvNSnioriuDwfQiqyGtAyPyebIf3bJBxGqGJBN0W5dvQTRc5Qt2gex9PRNW1tGJBN0W5dvQdumFORrwpSWwpjfeu(gRqUMtVqAj7bAgZkEdU6PDQEIYdupSWw)LWgJoCmCoU8HsH7HmqFXIvQN2P6tv9PR3URrUQb5BSc5Ao9cPLShOzmR4n4QN26jcg1dtbIBJEbcKd1LRAT0bwwecvtPcveimWjnSumIaXI7GXTlqiWXTtA48Hk12vHC1jBdIR(01d1WrdnMv8gC1pA92DnYvniFJvixZPxiTK9anJzfVbNaXTrVabYH6YvTw6allcriqiPAJuOIqvIeQiqyGtAyPyebIf3bJBxGCjSXOdhdNJREANQFG6jUEcxF4ggez4MDvinUKZmWjnSS(0170pJ7GZjmgAXEWzSdgwpTt1pq9WuG42OxGa5qPW9qgOVyXkIqO6acveimWjnSumIaXI7GXTlqS7AKRAq(ym2dwQjxaRVKEiNTOogoFAiSBJEbUPEANQFGCkzgce3g9ceihJXEWsn5cy9L0dzriuLMcveiUn6fiqGB2vH04swGWaN0WsXiIqOAQeQiqCB0lqGq62Hx4Kceg4KgwkgreIqececy81lqO6aWyayqemiIibIAhdAa8tGmliujKQsFO6Se6Z6RxfuU(wjzXr9qlU(zzsQ2iNLRhZPgvJzz93QW17uXQ4blR3I6a48LR5ekAaxpr0N1tizLLawwFYED0lqt62H1Brz7W6jmyJ6Dc824KgU(gupRqz8OxamRNWerVWmxZR50hkjloyz9ZA9Un6fuVPV4Y1CbscEHAdlqsr9iuKHHJX1tix4uCnpf1tO0gljJRNiAsx9daJbGrnVMNI6NDmpBP8Qq6rn3TrVGlNGz7Qq6bXtd6jjMX6KTVfuZDB0l4Yjy2UkKEq80GxWUjqR5Un6fC5emBxfspiEAqfhpKLAOfRLShO0LGz7Qq6H(y7cK3erZOM72OxWLtWSDvi9G4PbptBzTdKAzBz6sWSDvi9qFSDbYBIOAUBJEbxobZ2vH0dINg8qD5QwtACjF01qtykadTy4CwXXd1lKoqzTIFbJ1(D(DniZPgvNKWYAUBJEbxobZ2vH0dINgK6yDhScDaxHNC6)qDSFAOfe6fsNSQzCnVMNI6PV8gupHCdp6fuZDB0l4Mg22H1C3g9coINgKah3oPHPd4k80bKA7cKD0lGocCdfprsbbLptBzTdKAzB5mvcSWEjSXOdhdNJlFOu4Eid0xSyfANOh6s9hlRp26LCWyLgW1RgLdugxVDxJCvdU6v7Dup0IRhbmZ6j9JL1VG6dhdNJlxZtr9PmkBhwFkpZREpQhQXxuZDB0l4iEAqRBmA3g9c0M(c6aUcpzLxnpf1tiPa1drzmJR)u3HfLV6JT(aLRhjy3eOSSEc5gE0lOEctoUE52a41FlDDup0IT8vFYUMgaV(gQEWgOnaE99vVtG3gN0WWmxZDB0l4iEAqmfq72OxG20xqhWv4Ply3eOSKUgA6c2nbklZUXuZtr9eQjjMX1FM2YAhi1Y2Y17r9dqC9P8SxVKc3a41hOC9qn(I6jcg1FSDbYJohkyC9bQh1NkIRpLN96BO67OEMEtAmF1RUd0guFGY1dy6nQFwskpZ6xC99vpyJ6PsQ5Un6fCepn4zAlRDGulBltxdnDjSXOdhdNJlFOu4Eid0xSyLrPN0qnC0qJzfVbhT0tAskiO8zAlRDGulBlNXSI3GBu4wzwXP302vHC1jBdIJ2PunBeoAfEuIGbmjeduZtr9ekbMX1BrDaCUE8gE0lO(gQE1C9OobC9j4EXDmwJ3WJEb1FCuVdK1RqzIoXW1hogohx9uj5AUBJEbhXtdsGJBN0W0bCfEI6yDcUxChJ14n8OxaDe4gkEkb3lUJXA8gE0li9LWgJoCmCoU8HsH7HmqFXIvODAGAEkQF2X9I7yC9eYn8OxqQR1tOGJz5RE4nbC9E9wSNuVtUur9mGXWhxp0IRpq56VGDtGwFkpZREcts1gjJR)I2yQhZxcBJ67aM56NLIkHUoQ36G6j56dupQ)ALedNR5Un6fCepnO1ngTBJEbAtFbDaxHNUGDtGQTYJUgAIah3oPHZuhRtW9I7ySgVHh9cQ5PO(u)XY6JTEjd1aUE1OmO(yRN646VGDtGwFkpZR(fxpjvBKm(Q5Un6fCepniboUDsdthWv4Ply3eO6afZh6AK0rGBO4PbMbXHByqKjOHV4mdCsdljedadId3WGiR4xWy9cPpuxUQVmdCsdljedadId3WGiFOUCvRHwl1LzGtAyjHyGzqC4ggez34wChJZmWjnSKqmamiEGzqii8LWgJoCmCoU8HsH7HmqFXIvODkvWSMNI6t5fCTKX1tDnaE9E9ib7MaT(uEM1RgLb1Jz3I2a41hOC9mGXWhxFGI5dDnYAUBJEbhXtdADJr72OxG20xqhWv4Ply3eOAR8ORHMyaJHpolzO22XOte442jnC(c2nbQoqX8HUgznpf1RAdhnMLV6tDyaC2bwM(SEcjvsqH56jzOfZ1JmwHCnx9EuVzvxFkp71hB92vHSbC9SJnJRhZqy(qRxDhO1dNJObWRpq56jPGGQNkjxpHQ526nR66t5zVEjfUbWRhzSc5AU6j5qnZG6NPdS8vV6oqRFaIRx1uNCnpf172OxWr80GyQKGcZ01qto9Z4o4mOHJgNMagaNDGLZmWjnSmnniPGGYGgoACAcyaC2bwotLK2UkKRozBqCzjd12oOLO0e(syJrhogohx(qPW9qgOVyXkJoaSWsGJBN0WzQJ1j4EXDmwJ3WJEbWmnHT7AKRAq(gRqUMtVqAj7bAgZkEdUrNOjSWsyN(zChCg0WrJttadGZoWYzSdgs70aPjPGGY3yfY1C6fslzpqZywXBWrlnttJly3eOSm7gtA7Ug5QgKpuxUQ1shy5Sf1XW5tdHDB0lWn0obJCkfMWSM72OxWr80Gw3y0Un6fOn9f0bCfEcQb9HsxdnHPam0IHZzj7bQzS(qD5Q(YCQr1jjSmTCJ8XjxF5OTdBa80YnYhNC9LXSI3GB0PbsBxfYvNSnioANgOM72OxWr80Gw3y0Un6fOn9f0bCfEcQb9Hsxdnz31ix1G8nwHCnNEH0s2d0mMv8gCJonqA7QqU6KTbXr70aPXuagAXW5CGYA8gbdYCQr1jjSSM72OxWr80Gw3y0Un6fOn9f0bCfEcQb9HsxdnzxfYvNSniUjh0kUf1XWzP2MuZtr9ZG46v3bA9ZePEcVuX1sU(ly3eOWSM72OxWr80Gw3y0Un6fOn9f0bCfEcQb9HsxdnzxfYvNSniUSKHABhJoreSWc1WrdnMv8gCJoruA7QqU6KTbXr7enR5POEcDd6dTEpQpvexV6oqxQO(zIuZtr9ZIoqRFMi17MBRhQb9HwVh1NkIR3H7n4I6z61THzC9PQ(WXW54QNWlvCTKR)c2nbkmR5Un6fCepnO1ngTBJEbAtFbDaxHNGAqFO01qtxcBm6WXW54YhkfUhYa9flwzkvPTRc5Qt2gehTtPQMNI6t9hxVxpjvBKmUE1OmOEm7w0gaV(aLRNbmg(46dumFORrwZDB0l4iEAqRBmA3g9c0M(c6aUcprs1gjDn0edym8Xzjd12ogDIah3oPHZxWUjq1bkMp01iR5POEcfRA(I6tW9I7yC9nOE3yQFHQpq56juNDcf1tYwN6467OERtD8vVx)SKuEM1C3g9coINg0XwhW6yXyge01qtmGXWhNLmuB7G2jIMbXmGXWhNXmCguZDB0l4iEAqhBDaRtOmhxZDB0l4iEAqtdhnon9nLeUcdIAUBJEbhXtds6W1lKoWTD4vZR5PO(uExJCvdUAEkQp1FC9Z0bwU(fcA2GBL1tYqlMRpq56HA8f1FOu4Eid0xSyL6HWRs9QSyGl36TRcF13GCn3TrVGlBLhXtdEOUCvRLoWY0rDSEHG0WTYjIORHMObjfeu(qD5QwlDGLZujPjPGGYhkfUhYaDSyGl3mvsAskiO8HsH7Hmqhlg4YnJzfVb3Ot0mpJAEkQNWPEGHVRE3GzxoUEQK6jzRtDC9Q56JDhwpcQlx11tOxl1bZ6PoUEKXkKR5QFHGMn4wz9Km0I56duUEOgFr9hkfUhYa9flwPEi8QuVklg4YTE7QWx9nixZDB0l4Yw5r80G3yfY1C6fslzpqPJ6y9cbPHBLterxdnrsbbLpukCpKb6yXaxUzQK0Kuqq5dLc3dzGowmWLBgZkEdUrNOzEg1C3g9cUSvEepniKXHZgJh9cORHMiWXTtA48bKA7cKD0linnUGDtGYYSIdcdxZDB0l4Yw5r80GqghoBmE0lqBnSdoMUgAsYKuqqziJdNngp6fKXSI3GB0bGfwjtsbbLHmoC2y8Oxq(c3oK2PubJAUBJEbx2kpINgKah0hkDn0eHXuagAXW5SIJhQxiDGYAf)cgR9787AqMtnQojHLPTRc5Qt2gexwYqTTJrNOjSWIPam0IHZzj7bQzS(qD5Q(YCQr1jjSmTDvixDY2G4gLiyMMKcckFJvixZPxiTK9antLKMKcckFOUCvRLoWYzQK0k(fmw73531anMv8gCtWinjfeuwYEGAgRpuxUQVSCvdQ5Un6fCzR8iEAqRBmA3g9c0M(c6aUcpX3XalF01qt04c2nbklZUXKMah3oPHZhqQTlq2rVayHLVJbwotIzpq1lKoqzTCCdGNvC67fNoAfM2PbQ5PO(zFxt9qlUEvwmWLB9jyE2q2zwV6oqRhbDM1JzxoUE1OmOEWg1JPaGgaVEecDUM72OxWLTYJ4Pbt21OX8Tuylth0I1aMEJjIORHMOr4gge5d1LRAn0APUmdCsdlR5PO(u)X1RYIbUCRpbZ1JSZSE1OmOE1C9OobC9bkxpdym8X1RgLdugxpeEvQpzxtdGxV6oqxQOEecD9lUE6BQlQhodySBmJZ1C3g9cUSvEepn4HsH7Hmqhlg4YLUgAIbmg(yANOhyKMah3oPHZhqQTlq2rVG02DnYvniFJvixZPxiTK9antLK2URrUQb5d1LRAT0bwoBrDmC(ODIOAUBJEbx2kpINg8ym2dwQjxaRVKEitNDS1W6WXW54MiIUgAIah3oPHZhqQTlq2rVG00qUr(ym2dwQjxaRVKEiRLBKJ2oSbWHfwOgoAOXSI3GB0PzuZtr9P(JRhzSc5AU6xq92DnYvnOEc7qbJRhQXxupcyMWSEkGHVRE1C9oMRh(2a41hB9jBs9QSyGl36DGSE5wpyJ6rDc46rqD5QUEc9APUC9ekw11NYZE9qlUEvq56jKBemixZDB0l4Yw5r80G3yfY1C6fslzpqPRHMiWXTtA48bKA7cKD0linnS7AKRAq(qD5QwtACjFzQK0eoCddImdiGnBsdGRpuxUQVmdCsdlHfw7Ug5QgKpuxUQ1shy5Sf1XW5J2jIGzActJWnmiYhkfUhYaDSyGl3mdCsdlHf2WnmiYhQlx1AO1sDzg4KgwclS2DnYvniFOu4Eid0XIbUCZywXBWr7aWmnHPbMcWqlgoNduwJ3iyqMtnQojHLWcRDvixDY2G4gDAayMMW0GVJbwotA2vQxiDGYAgWkJZko99IHfw7Ug5QgKjn7k1lKoqzndyLXzmR4n4ODaywZtr90hq17s5vVJ56PsOR(d0jC9bkx)c46v3bA9MvnFr9QOYmZ1N6pUE1OmOE54gaVEi)cgxFG6G6t5zVEjd12oQFX1d2O(ly3eOSSE1DGUur9oyC9P8SNR5Un6fCzR8iEAqfhpKLAOfRLShO0zhBnSoCmCoUjIORHMWEl1mbmiYUuEzQK0eoCmCoYrRW6y1YMh1UkKRozBqCzjd12oGfwACb7MaLLz3ysBxfYvNSniUSKHABh0ozt0ko9QVegiHznpf1tFavpyR3LYRE1TXuVS56v3bAdQpq56bm9g1ttyC0vp1X1tFbnZ6xq9K7D1RUd0LkQ3bJRpLN9Cn3TrVGlBLhXtdQ44HSudTyTK9aLUgAc7TuZeWGi7s5LBaT0egZg2BPMjGbr2LYllPWE0liTDvixDY2G4YsgQTDq7KnrR40R(syGSM72OxWLTYJ4PbpuxUQ1KgxYhDn0eboUDsdNpGuBxGSJEbPTRc5Qt2gexwYqTTdANgOM72OxWLTYJ4Pbzl62a4AmNGBfhiPRHMiWXTtA48bKA7cKD0liTDvixDY2G4YsgQTDq7entFjSXOdhdNJlFOu4Eid0xSyLrNsvnpf1pl6aTEecnD13q1d2OE3GzxoUE5cy6QN646vzXaxU1RUd06r2zwpvsUM72OxWLTYJ4PbpukCpKb6yXaxU01qtHByqKpuxUQ1qRL6YmWjnSmnboUDsdNpGuBxGSJEbPjPGGY3yfY1C6fslzpqZuj1C3g9cUSvEepn4H6YvTw6altxdnrdskiO8H6YvTw6alNPssd1WrdnMv8gCJonRehUHbr(OidgdrbNZmWjnSSMxZtr9QUGz7syB9xqbbvV6oqR3SQzC9j4ER5Un6fCzR8iEAWKn6fuZDB0l4Yw5r80GKMDLAik8y6AOjskiO8nwHCnNEH0s2d0mvsn3TrVGlBLhXtdsY4JXdBaC6AOjskiO8nwHCnNEH0s2d0mvsn3TrVGlBLhXtdc1yM0SRKUgAIKcckFJvixZPxiTK9antLuZDB0l4Yw5r80GoWYxGDJ26gdDn0ejfeu(gRqUMtVqAj7bAMkPMxZDB0l4Yw5r80GuhR7GvOJHGyBObUcpzhBnBGxqB1Kg)c6AOjACb7MaLLz3ystGJBN0W5di12fi7OxqAAqsbbLVXkKR50lKwYEGMPssZagdFCwYqTTdANOjmQ5Un6fCzR8iEAqQJ1DWk0bCfEYP)d1X(PHwqOxiDYQMX01qt0GKcckFOUCvRLoWYzQK02DnYvniFJvixZPxiTK9anJzfVb3OebJAEkQFdugRUpUE1DGwpYoZ69O(bMbX1FHBhE1V46jAgexV6oqR3n3w)iMDL1tLKR5Un6fCzR8iEAqQJ1DWk0bCfEYpucCaFASt)lwBxSBORHMKmjfeug70)I12f7gTKjPGGYYvnawyLmjfeu2UajLnAcyDdgQLmjfeuMkjD4y4CKrz3eO5eBmknhiD4y4CKrz3eO5eBq7enHbSWsdjtsbbLTlqszJMaw3GHAjtsbbLPsstyjtsbbLXo9VyTDXUrlzskiO8fUDiTtdmJzJiyqiKmjfeuM0SRuVq6aL1mGvgNPsGfwOgoAOXSI3GB0ubdyMMKcckFJvixZPxiTK9anJzfVbhTZAnpf1N6W4X1Jxk4OMX1JPmC9lu9bkLczd1SSEfpqV6jzZQM(S(u)X1dT46Ppadtwz9wCh1C3g9cUSvEepni1X6oyf6aUcpPmw6NoCtFkoOMNI6Njd5uMOEi3yiD7W6HwC9uNtA467Gvo6Z6t9hxV6oqRhzSc5AU6xO6Nj7bAUM72OxWLTYJ4PbPow3bRC01qtKuqq5BSc5Ao9cPLShOzQeyHfQHJgAmR4n4gDayuZR5POEcv6NXDW1N6YDmWYxn3TrVGlZ3XalFepnODbwgeypyPgY4kmDn0edym8X5OvyDSAfNEPLO00GKcckFJvixZPxiTK9antLKMW0qUr2UaldcShSudzCfwtsHb5OTdBa800WTrVGSDbwgeypyPgY4kCUbAitdhnGfwikJrJzlQJHZ6Ov4rHBLzfNEHzn3TrVGlZ3XalFepniPzxPEH0bkRzaRmMUgAIg2DnYvniFOUCvRjnUKVmvsA7Ug5QgKVXkKR50lKwYEGMPsGfwOgoAOXSI3GB0jIGrn3TrVGlZ3XalFepniCkhlBhOxiTt)mEd0AUBJEbxMVJbw(iEAqO1sDSu70pJ7G1KSRqxdnr4lHngD4y4CC5dLc3dzG(IfRq70aWcl2BPMjGbr2LYl3aAPhyaZ00WURrUQb5BSc5Ao9cPLShOzQK00GKcckFJvixZPxiTK9antLKMbmg(4SKHABh0ortyuZDB0l4Y8DmWYhXtdMqHBOXnaUM04xqxdnDjSXOdhdNJlFOu4Eid0xSyfANgawyXEl1mbmiYUuE5gql9aJAUBJEbxMVJbw(iEAWaL1uaYLci1ql2Y01qtKuqqzmBhA470ql2YzQeyHLKcckJz7qdFNgAXwwBxkqW48fUD4OebJAUBJEbxMVJbw(iEAqCNKyyDd0xIB5AUBJEbxMVJbw(iEAq1l2ijGBGgZ3cCGLPRHMS7AKRAq(gRqUMtVqAj7bAgZkEdUrNbSWc1WrdnMv8gCJs0SwZDB0l4Y8DmWYhXtdQWklESEH0gkBl1sm7khDn0edym8XJMkyKMKcckFJvixZPxiTK9antLuZtr9PUxJSEcj7jnaE9eAJRWx9qlUEMEzlvW1JDaCU(fx)W2yQNKcc6OR(gQ(K9UM0W56junQ9Xx9bEC9XwpCoQpq56nRA(I6T7AKRAq9K(XY6xq9obEBCsdxpdyLMVCn3TrVGlZ3XalFepniM9KgaxdzCf(ORHMGA4OHgZkEdUrjkpdyHLWeoCmCoYOSBc0CInODwHbSWgogohzu2nbAoXgJonamGzAc72OjG1mGvA(MicwyHA4OHgZkEdoAhiLctyclSeoCmCoYrRW6y1j2qpamOLMWinHDB0eWAgWknFteblSqnC0qJzfVbhTPkvWeM18AEkQhjy3eO1NY7AKRAWvZDB0l4YxWUjq1w5r80Ge442jnmDaxHNouPoqX8HUgjDe4gkEYURrUQb5d1LRAT0bwoBrDmC(0qy3g9cCdTteLtjZGUu3SjHX1N6442jnCnpf1N64G(qRVHQxnxVJ56TEssdGx)cQFMoWY1BrDmC(Y1N6IJnJRNKHwmxpuJVOEPdSC9nu9Q56rDc46bB9Q2WrJlCZqgxpjvu)mD8W6rqD5QU(gu)ILmU(yRhoh1tiPsckmxpvs9egS1tF5xW46juVZVRbWmxZDB0l4YxWUjq1w5r80Ge4G(qPRHMimniWXTtA48Hk1bkMp01iHfwAeUHbrg0WrJlCZqgNzGtAyz6WnmiYshpuFOUCvNzGtAyjmtBxfYvNSniUSKHABh0suAAGPam0IHZzfhpuVq6aL1k(fmw73531GmNAuDsclR5Un6fC5ly3eOAR8iEAWJtU(Q5Un6fC5ly3eOAR8iEAWKDnAmFlf2Y0bTynGP3yIi6y6nWU2vwkqmLkyq3SVRPEOfxpcQlx1kSrwpX1JG6Yv9f4EixpfWW3vVAUEhZ17KlvuFS1B9K6xq9Z0bwUElQJHZxUEcLaZ46vJYG6j0nqw)SG9Ha(U67RENCPI6JTEmfO(LkY1C3g9cU8fSBcuTvEepn4H6YvTcBK01qtmGXWht7uQGrAgWy4JZsgQTDq7erWinniWXTtA48Hk1bkMp01itBxfYvNSniUSKHABh0suAjtsbbLHAGuRM9Ha(UmMv8gCJsun3TrVGlFb7MavBLhXtdsGJBN0W0bCfE6qLA7QqU6KTbXrhbUHINSRc5Qt2gexwYqTTdANsfDP8SxpMtnQgZkmiOpRFMoWY17r9MvD9P8Sxp546LmKtzICnpf1NYZE9yo1OAmRWGG(S(z6alx)cmJRNKHwmxpud6dLXx9nu9Q56rDc46tW9I7yC94n8OxqUM72OxWLVGDtGQTYJ4PbjWXTtAy6aUcpDOsTDvixDY2G4OJa3qXt2vHC1jBdIllzO22XOterxdnrGJBN0WzQJ1j4EXDmwJ3WJEb18uu)mDGLRxsHBa86rgRqUMR(fxVtUeW1hOy(qxJmxZDB0l4YxWUjq1w5r80GhQlx1APdSmDn0eboUDsdNpuP2UkKRozBqCPjmboUDsdNpuPoqX8HUgjSWssbbLVXkKR50lKwYEGMXSI3GJ2jIYdalSxcBm6WXW54YhkfUhYa9flwH2PuL2URrUQb5BSc5Ao9cPLShOzmR4n4OLiyaZAEkQFekmOEmR4nObWRFMoWYx9Km0I56duUEOgoAupdKx9nu9i7mRx9cMLJ6j56XSlhxFdQpAfoxZDB0l4YxWUjq1w5r80GhQlx1APdSmDn0eboUDsdNpuP2UkKRozBqCPHA4OHgZkEdUrT7AKRAq(gRqUMtVqAj7bAgZkEdUAEnpf1JeSBcuwwpHCdp6fuZtr90hq1JeSBc0bjWb9HwVJ56PsOREQJRhb1LR6lW9qU(yRNKbmuh1dHxL6duU(e)UMaUEYfqD17az9e6giRFwW(qaFx9mbmO(gQE1C9oMR3J6vC6T(uE2RNWq4vP(aLRpbZ2vH0J6PVGMjmZ1C3g9cU8fSBcuws80GhQlx1xG7HmDn0eHjPGGYxWUjqZujWcljfeuMah0hAMkbM18uupHUb9HwVh1ttIRpLN96v3b6sf1ptK6hS(urC9Q7aT(zIuV6oqRhbLc3dzq9QSyGl36jPGGQNkP(yR3jyBz93QW1NYZE9Q9l46VoO8OxWLR5Un6fC5ly3eOSK4PbTUXODB0lqB6lOd4k8eud6dLUgAIKcckFOu4Eid0XIbUCZujPTRc5Qt2gexwYqTTJrNgOMNI6jun3w)5qC9Xwpud6dTEpQpvexFkp71RUd06z61THzC9PQ(WXW54Y1tyexHR3V6xQ4Ajx)fSBc0mmR5Un6fC5ly3eOSK4PbTUXODB0lqB6lOd4k8eud6dLUgA6syJrhogohx(qPW9qgOVyXktPkTDvixDY2G4ODkv18uupHUb9HwVh1NkIRpLN96v3b6sf1ptKAEkQFgexV6oqRFMi18uuVdK1tp1RUd06Njs9ouW46tDCqFO1C3g9cU8fSBcuws80Gw3y0Un6fOn9f0bCfEcQb9HsxdnzxfYvNSniUSKHABhJor0Sr4WnmiYsMtyS(cShoCwjZaN0WY0KuqqzcCqFOzQeywZtr9P(K6JTEAwF4y4CC1pK5K6PsQNq3az9Zc2hc47QNCC92XwtdGxpcQlx1xG7HCUM72OxWLVGDtGYsINg8qD5Q(cCpKPZo2AyD4y4CCterxdnjzskiOmudKA1SpeW3LXSI3GBuIsFjSXOdhdNJlFOu4Eid0xSyLrNOz6WXW5ihTcRJvlBE2WSI3GJw6PMNI6NfDGUur9ZK5egxpsG9WHZk17az90SEcPdgE1Vq1pIXLC9nO(aLRhb1LR6R(oQVV6vV4aTEQRbWRhb1LR6lW9qU(fupnRpCmCoUCn3TrVGlFb7MaLLepn4H6Yv9f4EitxdnrJWnmiYsMtyS(cShoCwjZaN0WY0o9Z4o4mPXLSUb6aL1hQlx1xg7GHt0m9LWgJoCmCoU8HsH7HmqFXIvMOznpf1tOxC9j4EXDmUE8gE0lGU6PoUEeuxUQVa3d56xcyC9iXIvQNiywV6oqRFwqFvVd3BWf1tLuFS1NQ6dhdNJRMNI6haM13q1tONf13x9ykaObWRFHGQNWlOEhmUExzPar9lu9HJHZXbZAEkQFX1ttywFS1R40BR00pxpYoZ6z6nyW1lOE1DGwp9bGjOdNSnDmU(fupnRpCmCoU6jCQQxDhO1pshiWmxZDB0l4YxWUjqzjXtdEOUCvFbUhY01qte442jnCM6yDcUxChJ14n8OxqAclzskiOmudKA1SpeW3LXSI3GBuIGf2WnmiYQzpzbk(fmoZaN0WY0xcBm6WXW54YhkfUhYa9flwz0PublSo9Z4o4Cdyc6WjBthJZmWjnSmnjfeu(gRqUMtVqAj7bAMkj9LWgJoCmCoU8HsH7HmqFXIvgDIMe70pJ7GZKgxY6gOduwFOUCvFzg4KgwcZAUBJEbx(c2nbkljEAWdLc3dzG(IfRqxdnDjSXOdhdNJJ2jAsmHjPGGYjywHLD4rVGmvcSWssbbLduwJ3iyqMkbwyXuagAXW5Sp0DCF6BPmAiSdxHbrMtnQojHLPTlqs1rwYCcJ1shoCgFzSdgs7ukbM1C3g9cU8fSBcuws80GhQlx1xG7HmDn0KKjPGGYqnqQvZ(qaFxgZkEdUrNicwyT7AKRAq(gRqUMtVqAj7bAgZkEdUrjAwtlzskiOmudKA1SpeW3LXSI3GBu7Ug5QgKVXkKR50lKwYEGMXSI3GRMNI6rqD5Q(cCpKRp26XmeMp06j0nqw)SG9Ha(U6DGS(yRNbhfMRxnxV1b1BDmEC9lbmUEVEikJPEc9SO(geB9bkxpGP3OEKDM13q1NS31KgoxZDB0l4YxWUjqzjXtdMSRrJ5BPWwMoOfRbm9gtevZDB0l4YxWUjqzjXtdc3SRcPXLmDn0enWuagAXW5Sp0DCF6BPmAiSdxHbrMtnQojHLPjPGGYjmgAXEWsnbCdU8fUDiTt0mTDbsQoYjmgAXEWsnbCdUm2bdPDIiAoBeoLsiSlqs1rwYCcJ1shoCgNzGtAyjX2fiP6ilzoHXAPdhoJZyhmeM1C3g9cU8fSBcuws80GWn7QqACjtxdnHPam0IHZzFO74(03sz0qyhUcdImNAuDsclttsbbLtym0I9GLAc4gC5lC7qANOzAcBxGKQJCcJHwShSuta3GlJDWqITlqs1rwYCcJ1shoCgNXoyimPDIi6PM72OxWLVGDtGYsINg8qD5Q(cCpKR518uupHUb9HY4RM72OxWLHAqFOepn4zAlRDGulBltxdnDjSXOdhdNJlFOu4Eid0xSyLrPN00GKcckFOUCvRLoWYzQK0Kuqq5Z0ww7aPw2woJzfVb3OqnC0qJzfVbxAskiO8zAlRDGulBlNXSI3GBucteX2vHC1jBdIdMecIYZAn3TrVGld1G(qjEAqcCC7KgMoGRWt3WorJPsckmthbUHINu8lyS2VZVRbAmR4n4OfgWclnc3WGidA4OXfUziJZmWjnSmD4ggezPJhQpuxUQZmWjnSmnjfeu(qD5QwlDGLZujWc7LWgJoCmCoU8HsH7HmqFXIvODIEOl1nBsyC9PooUDsdxp0IRNqsLeuyoxpYWoPEjfUbWRN(YVGX1tOENFxdQFX1lPWnaE9Z0bwUE1DGw)mD8W6DGSEWwVQnC04c3mKX5AEkQFwAMtQNkPEcjvsqH56BO67O((Q3jxQO(yRhtbQFPICn3TrVGld1G(qjEAqmvsqHz6AOjAqGJBN0W5ByNOXujbfMthogoh5OvyDSAzZZgMv8gC0spPXmeMpuN0W1C3g9cUmud6dL4Pbp2I5qhSff0PgfxZtr90xuMOLBenaE9HJHZXvFG6r9QBJPEttaxp0IRpq56Luyp6fu)cvpHKkjOWC9ygcZhA9skCdGxFIdKSsBZ1C3g9cUmud6dL4PbXujbfMPZo2AyD4y4CCterxdnrdcCC7KgoFd7enMkjOWCAAqGJBN0WzQJ1j4EXDmwJ3WJEbPVe2y0HJHZXLpukCpKb6lwScTtdKoCmCoYrRW6y1YMPDIWZGycpaHWUkKRozBqCWeMPXmeMpuN0W18uupHKHW8HwpHKkjOWC9SJnJRVHQVJ6v3gt9m9M0yUEjfUbWRhzSc5AUC9ZCRpq9OEmdH5dT(gQEKDM1dNJREm7YX13G6duUEatVr9Z4Y1C3g9cUmud6dL4PbXujbfMPRHMObboUDsdNVHDIgtLeuyonMv8gCJA31ix1G8nwHCnNEH0s2d0mMv8gCetemsB31ix1G8nwHCnNEH0s2d0mMv8gCJonJ0HJHZroAfwhRw28SHzfVbhT2DnYvniFJvixZPxiTK9anJzfVbhXZOM72OxWLHAqFOepniPXTd1jRAjJPRHMObboUDsdNPowNG7f3XynEdp6fK(syJrhogohhTt0SM72OxWLHAqFOepnitqFwg7bxZR5PO(rOAJKXxn3TrVGlts1gjXtdEOu4Eid0xSyf6AOPlHngD4y4CC0onaXeoCddImCZUkKgxYzg4KgwM2PFg3bNtym0I9GZyhmK2PbsNSxh9c0KUDimR5Un6fCzsQ2ijEAWJXypyPMCbS(s6HmDn0KDxJCvdYhJXEWsn5cy9L0d5Sf1XW5tdHDB0lWn0onqoLmJAUBJEbxMKQnsINgeUzxfsJl5AUBJEbxMKQnsINgK0TdVWjfixcBfQoa9qKieHqaa]] )


end
