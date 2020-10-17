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


    spec:RegisterPack( "Subtlety", 20201016, [[daLc2bqiufEKcKnrj9jufjgfkuNcfYQafLxHIAwOQClqISlr9lfIHbkCmuKLrj6zOQY0ik5AGe2gOiFJOuzCGKY5uGI1HQOyEkG7bI9HQ0)ajQKdIQi1cvi9qIszIGKCrIsvXgbfvFeKOIrsuQQojQIkReK6LGevQzcsu1nrvu1oPe(jQIKgkiPAPOkINcLPsuCvqIYwrvu6RkqPZsuQkTxc)LIbRQdt1IrPhlYKj5YiBwrFgunAO60sTAIsvETcA2K62ez3a)wPHtPoUcuTCipxLPlCDuz7GsFNOA8OQQoVc16rvvMpky)swWKqgbMYdsyHLWWsyWemycMYwYKSKLSSuGfJTjbMTNg6WjbgWLibgghBOPySaZ2hRxxjKrGDlhkrcm8iSpEMrgbEh4CS50knY1sCAp6fKq(mg5AP0icmwUwh8CabRat5bjSWsyyjmycgmbtzlzswYswcmNlWxKadRLKnbgERueqWkWu0LeydQEmo2qtX465jlCoQGEq1ZtnfllHQNjyQElHHLWqGP7loHmcSlixh4KsiJWcMeYiWiGZQjLyubwc1bHAxGX46z5MZ8fKRd8mND9mWq9SCZzgwh0hEMZUEgjW8u0lqGD4UALFbQhsIqyHLczeyeWz1KsmQalH6GqTlWy5MZ8HZH6HeWelc4QnZzxV16tRe7AS3gexwrZo1r9daPElfyEk6fiWsUwB8u0lWO7ley6(cdWLib2Sb9HlcHf8tiJaJaoRMuIrfyjuheQDb2ztATjCeCkU8HZH6HeWCXIKQhs9YQER1Nwj21yVniU65fs9YsG5POxGal5ATXtrVaJUVqGP7lmaxIeyZg0hUiewilHmcmc4SAsjgvGLqDqO2fyPvIDn2BdIlROzN6O(bGupt1dLQNX1hUMarwrKnHmxG8WHtszc4SAsvV16z5MZmSoOp8mND9msG5POxGal5ATXtrVaJUVqGP7lmaxIeyZg0hUiewafczeyeWz1KsmQalH6GqTlW0eSKU(bQhkSSER1RiwU5mpBGYiN8Ha6UmIK8gC1pq9mvV16dhbNIC0sKjwJQP6Hs1JijVbx98wpmjW8u0lqGD4UALFbQhsIqybmjKrGraNvtkXOcmpf9ceyhURw5xG6HKalH6GqTlWuel3CMNnqzKt(qaDxgrsEdU6hOEMQ3A9NnP1MWrWP4YhohQhsaZflsQ(bGup)Q3A9HJGtroAjYeRr1u9qP6rKK3GREERhMeyPXjnzchbNItybtIqyHStiJaJaoRMuIrfyjuheQDbgpQpCnbISIiBczUa5HdNKYeWz1KQER178hH6GYSAxrMgycCYC4UALFzKdgwpK65x9wR)SjT2eocofx(W5q9qcyUyrs1dPE(jW8u0lqGD4UALFbQhsIqybutiJaJaoRMuIrfyjuheQDbgSoQDwnL5oYyJ6f1XydAdp6fuV16zC9kILBoZZgOmYjFiGUlJijVbx9dupt1Zad1hUMarwo52lqYVGqzc4SAsvV16pBsRnHJGtXLpCoupKaMlwKu9daPEzvpdmuVZFeQdk3ac2oC2w3X4mbCwnPQ3A9SCZz(glXU6ZStJI8apZzxV16pBsRnHJGtXLpCoupKaMlwKu9daPE(vpZ178hH6GYSAxrMgycCYC4UALFzc4SAsvpJeyEk6fiWoCxTYVa1djriSyWiKrGraNvtkXOcSeQdc1Ua7SjT2eocofx98cPE(vpZ1Z46z5MZSnIKivhE0liZzxpdmupl3CMdCYG2iiqMZUEgyOEehGMlcoL9HUJ6ZClN2mroCjcezAW5ABBsvV16tlqX1rwrKnHmkhoCcDzKdgwpVqQx2vpJeyEk6fiWoCoupKaMlwKKiewWemeYiWiGZQjLyubwc1bHAxGPiwU5mpBGYiN8Ha6UmIK8gC1paK6zQEgyO(0UA1khKVXsSR(m70OipWZisYBWv)a1ZeuRER1RiwU5mpBGYiN8Ha6UmIK8gC1pq9PD1QvoiFJLyx9z2PrrEGNrKK3GtG5POxGa7WD1k)cupKeHWcMysiJaJaoRMuIrfyZfzae)hclysG5POxGaZExTbr3YHsKiewWKLczeyeWz1KsmQalH6GqTlW4r9ioanxeCk7dDh1N5woTzIC4seiY0GZ122KQER1ZYnNzBcnxKhKYal1GlFHNgwpVqQNF1BT(0cuCDKTj0CrEqkdSudUmYbdRNxi1Ze)QhkvpJRFWupmR(0cuCDKveztiJYHdNqzc4SAsvpZ1NwGIRJSIiBczuoC4ekJCWW6zKaZtrVabgC9UsSAxrIqybt8tiJaJaoRMuIrfyjuheQDbgIdqZfbNY(q3r9zULtBMihUebImn4CTTnPQ3A9SCZz2MqZf5bPmWsn4Yx4PH1ZlK65x9wRNX1NwGIRJSnHMlYdszGLAWLroyy9mxFAbkUoYkISjKr5WHtOmYbdRNr1ZlK6zcMeyEk6fiWGR3vIv7kseclyswczeyEk6fiWoCxTYVa1djbgbCwnPeJkcriWO7iqIoHmclysiJaJaoRMuIrfyjuheQDbgbie8X5OLitSgjN)RN36zQER1ZJ6z5MZ8nwID1NzNgf5bEMZUER1Z465r9QnYPfKiqG8GuMP2LidlhcKJonSbWR3A98OEpf9cYPfKiqG8GuMP2LOCdmtDdhpQNbgQFYP1geLWDeCYeTev)a1dpPYso)xpJeyEk6fiWslirGa5bPmtTlrIqyHLczeyeWz1KsmQalH6GqTlW4r9PD1QvoiF4UALBy1UIUmND9wRpTRwTYb5BSe7QpZonkYd8mND9mWq9ZgoEyqKK3GR(bGuptWqG5POxGaJvVRYSttGtgcqsJfHWc(jKrG5POxGadoNJuTdm7048hH2axGraNvtkXOIqyHSeYiWiGZQjLyubwc1bHAxGX46pBsRnHJGtXLpCoupKaMlwKu98cPElRNbgQh5TYqWsGi7k1LBq98wpmbJ6zu9wRNh1N2vRw5G8nwID1NzNgf5bEMZUER1ZJ6z5MZ8nwID1NzNgf5bEMZUER1tacbFCwrZo1r98cPE(bdbMNIEbcS5M4oszC(JqDqgwYLeHWcOqiJaJaoRMuIrfyjuheQDb2ztATjCeCkU8HZH6HeWCXIKQNxi1Bz9mWq9iVvgcwcezxPUCdQN36HjyiW8u0lqGzZH654ga3WQ9leHWcysiJaJaoRMuIrfyjuheQDbgl3CMruAOMUZmxuIYC21Zad1ZYnNzeLgQP7mZfLitA5abHYx4PH1pq9mbdbMNIEbcSaNmCa2LdOmZfLiriSq2jKrG5POxGad122AY0aZz7jsGraNvtkXOIqybutiJaJaoRMuIrfyjuheQDbwAxTALdY3yj2vFMDAuKh4zej5n4QFG6HI6zGH6NnC8WGijVbx9duptqnbMNIEbcm5lsRGLAGbr3cCqIeHWIbJqgbgbCwnPeJkWsOoiu7cmcqi4JRFG6LfmQ3A9SCZz(glXU6ZStJI8apZzlW8u0lqGjrslASzNgnxQvgfICPteclycgczeyeWz1KsmQalH6GqTlWMnC8WGijVbx9duptzOOEgyOEgxpJRpCeCkY4KRd8SDkQN36HAWOEgyO(WrWPiJtUoWZ2PO(bGuVLWOEgvV16zC9EkAyjdbiPMU6Hupt1Zad1pB44HbrsEdU65TElhm1ZO6zu9mWq9mU(WrWPihTezI1yNcJLWOEERNFWOER1Z469u0WsgcqsnD1dPEMQNbgQF2WXddIK8gC1ZB9Ysw1ZO6zKaZtrVabgIC7ga3m1UeDIqecmfnDoDiKrybtczeyEk6fiWg2PHcmc4SAsjgveclSuiJaJaoRMuIrfyRTa7OqG5POxGadwh1oRMeyW6AosGXYnN5t3jY4aLr1jkZzxpdmu)ztATjCeCkU8HZH6HeWCXIKQNxi1dtcmyDKb4sKa7aktAbQo6ficHf8tiJaJaoRMuIrfyEk6fiWsUwB8u0lWO7ley6(cdWLibwsDIqyHSeYiWiGZQjLyubwc1bHAxGDb56aNuzxRfyEk6fiWqCaJNIEbgDFHat3xyaUejWUGCDGtkriSakeYiWiGZQjLyubwc1bHAxGD2KwBchbNIlF4COEibmxSiP6hOEyQER1pB44HbrsEdU65TEyQER1ZYnN5t3jY4aLr1jkJijVbx9dup8Kkl58F9wRpTsSRXEBqC1ZlK6Lv9qP6zC9rlr1pq9mbJ6zu9WS6TuG5POxGa70DImoqzuDIeHWcysiJaJaoRMuIrfyRTa7OqG5POxGadwh1oRMeyW6AosGzJ6f1XydAdp6fuV16pBsRnHJGtXLpCoupKaMlwKu98cPElfyW6idWLibg3rgBuVOogBqB4rVariSq2jKrGraNvtkXOcSeQdc1Uadwh1oRMYChzSr9I6ySbTHh9ceyEk6fiWsUwB8u0lWO7ley6(cdWLib2fKRdCtsDIqybutiJaJaoRMuIrfyRTa7OqG5POxGadwh1oRMeyW6AosGzjuupZ1hUMarg2g(IYeWz1KQEyw9wcJ6zU(W1eiYs(feYStZH7Qv(LjGZQjv9WS6Teg1ZC9HRjqKpCxTYnZnXDzc4SAsvpmRElHI6zU(W1eiYU2tOogNjGZQjv9WS6Teg1ZC9wcf1dZQNX1F2KwBchbNIlF4COEibmxSiP65fs9YQEgjWG1rgGlrcSlixh4Mahrh(QvIqyXGriJaJaoRMuIrfyjuheQDbgbie8Xzfn7uh1paK6H1rTZQP8fKRdCtGJOdF1kbMNIEbcSKR1gpf9cm6(cbMUVWaCjsGDb56a3KuNiewWemeYiWiGZQjLyubwc1bHAxG58hH6GYGgoECgyjaCYbjktaNvtQ6TwppQNLBoZGgoECgyjaCYbjkZzxV16tRe7AS3gexwrZo1r98wpt1BTEgx)ztATjCeCkU8HZH6HeWCXIKQFG6TSEgyOEyDu7SAkZDKXg1lQJXg0gE0lOEgvV16zC9PD1QvoiFJLyx9z2PrrEGNrKK3GR(bGup)QNbgQNX178hH6GYGgoECgyjaCYbjkJCWW65fs9wwV16z5MZ8nwID1NzNgf5bEgrsEdU65TE(vV165r9xqUoWjv2166TwFAxTALdYhURw5gLdsuoH7i40zMipf9cCD98cPEyKhm1ZO6zKaZtrVabgIZo4qKiewWetczeyeWz1KsmQalH6GqTlWqCaAUi4uwrEGRhBoCxTYVmn4CTTnPQ3A9QnYhzF9LJonSbWR3A9QnYhzF9LrKK3GR(bGuVL1BT(0kXUg7TbXvpVqQ3sbMNIEbcSKR1gpf9cm6(cbMUVWaCjsGnBqF4IqybtwkKrGraNvtkXOcSeQdc1UalTRwTYb5BSe7QpZonkYd8mIK8gC1paK6TSER1Nwj21yVniU65fs9wwV16rCaAUi4uoWjdAJGazAW5ABBsjW8u0lqGLCT24POxGr3xiW09fgGlrcSzd6dxeclyIFczeyeWz1KsmQalH6GqTlWsRe7AS3gex9qQ3bTKNWDeCszs2cmpf9ceyjxRnEk6fy09fcmDFHb4sKaB2G(WfHWcMKLqgbgbCwnPeJkWsOoiu7cS0kXUg7TbXLv0StDu)aqQNP6zGH6NnC8WGijVbx9daPEMQ3A9PvIDn2BdIREEHup)eyEk6fiWsUwB8u0lWO7ley6(cdWLib2Sb9HlcHfmbfczeyeWz1KsmQalH6GqTlWoBsRnHJGtXLpCoupKaMlwKu9qQxw1BT(0kXUg7TbXvpVqQxwcmpf9ceyjxRnEk6fy09fcmDFHb4sKaB2G(WfHWcMGjHmcmc4SAsjgvGLqDqO2fyeGqWhNv0StDu)aqQhwh1oRMYxqUoWnboIo8vReyEk6fiWsUwB8u0lWO7ley6(cdWLibglxRvIqybtYoHmcmc4SAsjgvGLqDqO2fyeGqWhNv0StDupVqQNjOOEMRNaec(4mIGtabMNIEbcmhLCazIfHiqicHfmb1eYiW8u0lqG5OKdiJnN(ibgbCwnPeJkcHfmnyeYiW8u0lqGPB44XzK94uWLiqiWiGZQjLyuriSWsyiKrG5POxGaJ1HB2PjqDA4jWiGZQjLyuricbMnIsReRhczewWKqgbMNIEbcm32wp2yV9TabgbCwnPeJkcHfwkKrG5POxGa7cY1bUaJaoRMuIrfHWc(jKrGraNvtkXOcmpf9ceysoAiPmZfzuKh4cmBeLwjwpmhLwG6eymbfIqyHSeYiWiGZQjLyubMNIEbcSt3jY4aLr1jsGLqDqO2fyiAIOd3z1KaZgrPvI1dZrPfOobgtIqybuiKrGraNvtkXOcSeQdc1UadXbO5IGtzjhn0SttGtgj)ccz8787AqMgCU22Mucmpf9ceyhURw5gwTROteclGjHmcmc4SAsjgvGbCjsG583H7i)mZfeMDASx5esG5POxGaZ5Vd3r(zMlim70yVYjKieHaB2G(WfYiSGjHmcmc4SAsjgvGLqDqO2fyNnP1MWrWP4YhohQhsaZflsQ(bQhMQ3A98OEwU5mF4UALBuoirzo76Twpl3CMpDNiJdugvNOmIK8gC1pq9ZgoEyqKK3GRER1ZYnN5t3jY4aLr1jkJijVbx9dupJRNP6zU(0kXUg7TbXvpJQhMvptzOMaZtrVab2P7ezCGYO6ejcHfwkKrGraNvtkXOcS1wGDuiW8u0lqGbRJANvtcmyDnhjWK8liKXVZVRbgej5n4QN36Hr9mWq98O(W1eiYGgoECHRhsOmbCwnPQ3A9HRjqKvoAO5WD1kptaNvtQ6Twpl3CMpCxTYnkhKOmND9mWq9NnP1MWrWP4YhohQhsaZflsQEEHupmjWG1rgGlrcSByBBqC2bhIeHWc(jKrGraNvtkXOcSeQdc1UaJh1dRJANvt5ByBBqC2bhIQ3A9HJGtroAjYeRr1u9qP6rKK3GREERhMQ3A9iAIOd3z1KaZtrVabgIZo4qKiewilHmcmpf9ceyhLquyckHd6bNJeyeWz1KsmQiewafczeyeWz1KsmQaZtrVabgIZo4qKalH6GqTlW4r9W6O2z1u(g22geNDWHO6TwppQhwh1oRMYChzSr9I6ySbTHh9cQ3A9NnP1MWrWP4YhohQhsaZflsQEEHuVL1BT(WrWPihTezI1OAQEEHupJRhkQN56zC9wwpmR(0kXUg7TbXvpJQNr1BTEenr0H7SAsGLgN0KjCeCkoHfmjcHfWKqgbgbCwnPeJkWsOoiu7cmEupSoQDwnLVHTTbXzhCiQER1JijVbx9duFAxTALdY3yj2vFMDAuKh4zej5n4QN56zcg1BT(0UA1khKVXsSR(m70OipWZisYBWv)aqQhkQ3A9HJGtroAjYeRr1u9qP6rKK3GREERpTRwTYb5BSe7QpZonkYd8mIK8gC1ZC9qHaZtrVabgIZo4qKiewi7eYiWiGZQjLyubwc1bHAxGXJ6H1rTZQPm3rgBuVOogBqB4rVG6Tw)ztATjCeCkU65fs98tG5POxGaJv7PHg7vUIqIqybutiJaZtrVabgbBFjc5bjWiGZQjLyuricbwsDczewWKqgbgbCwnPeJkWsOoiu7cmEupl3CMpCxTYnkhKOmND9wRNLBoZhohQhsatSiGR2mND9wRNLBoZhohQhsatSiGR2mIK8gC1paK65xgkeyEk6fiWoCxTYnkhKibg3rMDonWtkHfmjcHfwkKrGraNvtkXOcSeQdc1UaJLBoZhohQhsatSiGR2mND9wRNLBoZhohQhsatSiGR2mIK8gC1paK65xgkeyEk6fiWUXsSR(m70OipWfyChz250apPewWKiewWpHmcmc4SAsjgvGLqDqO2fyW6O2z1u(aktAbQo6fuV165r9xqUoWjvwYbHMeyEk6fiWMAhoP1E0lqeclKLqgbgbCwnPeJkWsOoiu7cmfXYnN5P2HtATh9cYisYBWv)a1Bz9mWq9kILBoZtTdN0Ap6fKVWtdRNxi1llyiW8u0lqGn1oCsR9OxGjPjhCKiewafczeyeWz1KsmQalH6GqTlWyC9ioanxeCkl5OHMDAcCYi5xqiJFNFxdY0GZ122KQER1Nwj21yVniUSIMDQJ6has98REgyOEehGMlcoLvKh46XMd3vR8ltdoxBBtQ6TwFALyxJ92G4QFG6zQEgvV16z5MZ8nwID1NzNgf5bEMZUER1ZYnN5d3vRCJYbjkZzxV16L8liKXVZVRbgej5n4Qhs9WOER1ZYnNzf5bUES5WD1k)YQvoqG5POxGadwh0hUiewatczeyeWz1KsmQalH6GqTlW4r9xqUoWjv2166TwpSoQDwnLpGYKwGQJEb1Zad1t3rGeLzrKh4MDAcCYOg3a4zjx2Br1BT(OLO65fs9wkW8u0lqGLCT24POxGr3xiW09fgGlrcm6ocKOteclKDczeyeWz1KsmQaZtrVabM9UAdIULdLibwc1bHAxGXJ6dxtGiF4UALBMBI7YeWz1KsGnxKbq8FiSGjriSaQjKrGraNvtkXOcSeQdc1UaJaec(465fs9WemQ3A9W6O2z1u(aktAbQo6fuV16t7QvRCq(glXU6ZStJI8apZzxV16t7QvRCq(WD1k3OCqIYjChbNU65fs9mjW8u0lqGD4COEibmXIaUAfHWIbJqgbgbCwnPeJkW8u0lqGDec5bPmSlGmNDpKeyjuheQDbgSoQDwnLpGYKwGQJEb1BTEEuVAJ8riKhKYWUaYC29qYO2ihDAydGxpdmu)SHJhgej5n4QFai1dfcS04KMmHJGtXjSGjriSGjyiKrGraNvtkXOcSeQdc1Uadwh1oRMYhqzslq1rVG6TwppQpTRwTYb5d3vRCdR2v0L5SR3A9mU(W1eiYeawsV2naU5WD1k)YeWz1KQEgyO(0UA1khKpCxTYnkhKOCc3rWPREEHupt1ZO6TwpJRNh1hUMar(W5q9qcyIfbC1MjGZQjv9mWq9HRjqKpCxTYnZnXDzc4SAsvpdmuFAxTALdYhohQhsatSiGR2mIK8gC1ZB9wwpJQ3A9mUEEupIdqZfbNYbozqBeeitdoxBBtQ6zGH6tRe7AS3gex9daPElRNr1BTEgxppQNUJajkZQ3vz2PjWjdbiPXzjx2Br1Zad1N2vRw5GmRExLzNMaNmeGKgNrKK3GREER3Y6zKaZtrVab2nwID1NzNgf5bUiewWetczeyeWz1KsmQaZtrVabMKJgskZCrgf5bUalH6GqTlWqERmeSeiYUsDzo76TwpJRpCeCkYrlrMynQMQFG6tRe7AS3gexwrZo1r9mWq98O(lixh4Kk7AD9wRpTsSRXEBqCzfn7uh1ZlK6t2gjN)nNnbu1ZibwACstMWrWP4ewWKiewWKLczeyeWz1KsmQalH6GqTlWqERmeSeiYUsD5gupV1ZpyupuQEK3kdblbISRuxwXH8Oxq9wRpTsSRXEBqCzfn7uh1ZlK6t2gjN)nNnbucmpf9ceysoAiPmZfzuKh4Iqybt8tiJaJaoRMuIrfyjuheQDbgSoQDwnLpGYKwGQJEb1BT(0kXUg7TbXLv0StDupVqQ3sbMNIEbcSd3vRCdR2v0jcHfmjlHmcmc4SAsjgvGLqDqO2fyW6O2z1u(aktAbQo6fuV16tRe7AS3gexwrZo1r98cPE(vV16pBsRnHJGtXLpCoupKaMlwKu9daPEzjW8u0lqGrj8TbWniYg1soqjcHfmbfczeyeWz1KsmQalH6GqTlWcxtGiF4UALBMBI7YeWz1KQER1dRJANvt5dOmPfO6Oxq9wRNLBoZ3yj2vFMDAuKh4zoBbMNIEbcSdNd1djGjweWvRiewWemjKrGraNvtkXOcSeQdc1UaJh1ZYnN5d3vRCJYbjkZzxV16NnC8WGijVbx9daPEOw9mxF4Ace5JJni0KdoLjGZQjLaZtrVab2H7QvUr5GejcHfmj7eYiW8u0lqGzVrVabgbCwnPeJkcHfmb1eYiWiGZQjLyubwc1bHAxGXYnN5BSe7QpZonkYd8mNTaZtrVabgRExLzYHglcHfmnyeYiWiGZQjLyubwc1bHAxGXYnN5BSe7QpZonkYd8mNTaZtrVabglHocnSbWfHWclHHqgbgbCwnPeJkWsOoiu7cmwU5mFJLyx9z2PrrEGN5SfyEk6fiWMnIy17QeHWclzsiJaJaoRMuIrfyjuheQDbgl3CMVXsSR(m70OipWZC2cmpf9ceyoirxGCTj5ATiewyPLczeyeWz1KsmQaZtrVabwACsVbAbDYWQ9leyjuheQDbgpQ)cY1boPYUwxV16H1rTZQP8buM0cuD0lOER1ZJ6z5MZ8nwID1NzNgf5bEMZUER1tacbFCwrZo1r98cPE(bdbgnNukmaxIeyPXj9gOf0jdR2VqeclSKFczeyeWz1KsmQaZtrVabMZFhUJ8Zmxqy2PXELtibwc1bHAxGXJ6z5MZ8H7QvUr5GeL5SR3A9PD1QvoiFJLyx9z2PrrEGNrKK3GR(bQNjyiWaUejWC(7WDKFM5ccZon2RCcjcHfwklHmcmc4SAsjgvG5POxGaZpCyDaDgKZFlYKwKRfyjuheQDbMIy5MZmY5VfzslY1gfXYnNz1khupdmuVIy5MZCAbkUu0WsMgm0OiwU5mZzxV16dhbNImo56apBNI6hOE(zz9wRpCeCkY4KRd8SDkQNxi1ZpyupdmuppQxrSCZzoTafxkAyjtdgAuel3CM5SR3A9mUEfXYnNzKZFlYKwKRnkILBoZx4PH1ZlK6TekQhkvptWOEyw9kILBoZS6DvMDAcCYqasACMZUEgyO(zdhpmisYBWv)a1llyupJQ3A9SCZz(glXU6ZStJI8apJijVbx98wputGbCjsG5hoSoGodY5VfzslY1IqyHLqHqgbgbCwnPeJkWaUejWKgR8ZeUUpjhiW8u0lqGjnw5NjCDFsoqeclSeMeYiWiGZQjLyubwc1bHAxGXYnN5BSe7QpZonkYd8mND9mWq9ZgoEyqKK3GR(bQ3syiW8u0lqGXDKPds6eHieyxqUoWnj1jKrybtczeyeWz1KsmQaBTfyhfcmpf9ceyW6O2z1KadwxZrcS0UA1khKpCxTYnkhKOCc3rWPZmrEk6f4665fs9mLLDqHadwhzaUejWoCLjWr0HVALiewyPqgbgbCwnPeJkWsOoiu7cmgxppQhwh1oRMYhUYe4i6WxTQEgyOEEuF4AcezqdhpUW1djuMaoRMu1BT(W1eiYkhn0C4UALNjGZQjv9mQER1Nwj21yVniUSIMDQJ65TEMQ3A98OEehGMlcoLLC0qZonbozK8liKXVZVRbzAW5ABBsjW8u0lqGbRd6dxecl4NqgbMNIEbcSJSV(eyeWz1KsmQiewilHmcmc4SAsjgvG5POxGaZExTbr3YHsKaJ4)a5gxA5aHatwWqGnxKbq8FiSGjriSakeYiWiGZQjLyubwc1bHAxGracbFC98cPEzbJ6Twpbie8Xzfn7uh1ZlK6zcg1BTEEupSoQDwnLpCLjWr0HVAv9wRpTsSRXEBqCzfn7uh1ZB9mvV16vel3CMNnqzKt(qaDxgrsEdU6hOEMeyEk6fiWoCxTYLiTseclGjHmcmc4SAsjgvGT2cSJcbMNIEbcmyDu7SAsGbRR5ibwALyxJ92G4YkA2PoQNxi1llbgSoYaCjsGD4ktALyxJ92G4eHWczNqgbgbCwnPeJkWwBb2rHaZtrVabgSoQDwnjWG11CKalTsSRXEBqCzfn7uh1paK6zsGLqDqO2fyW6O2z1uM7iJnQxuhJnOn8OxGadwhzaUejWoCLjTsSRXEBqCIqybutiJaJaoRMuIrfyjuheQDbgSoQDwnLpCLjTsSRXEBqC1BTEgxpSoQDwnLpCLjWr0HVAv9mWq9SCZz(glXU6ZStJI8apJijVbx98cPEMYwwpdmu)ztATjCeCkU8HZH6HeWCXIKQNxi1lR6TwFAxTALdY3yj2vFMDAuKh4zej5n4QN36zcg1ZibMNIEbcSd3vRCJYbjseclgmczeyeWz1KsmQalH6GqTlWG1rTZQP8HRmPvIDn2BdIRER1pB44HbrsEdU6hO(0UA1khKVXsSR(m70OipWZisYBWjW8u0lqGD4UALBuoirIqecmwUwReYiSGjHmcmc4SAsjgvGLqDqO2fyNnP1MWrWP4QNxi1Bz9mxpJRpCnbImC9UsSAxrzc4SAsvV16D(JqDqzBcnxKhug5GH1ZlK6TSEgjW8u0lqGD4COEibmxSijriSWsHmcmc4SAsjgvGLqDqO2fyPD1QvoiFec5bPmSlGmNDpKYjChbNoZe5POxGRRNxi1Bzw2bfcmpf9ceyhHqEqkd7ciZz3djriSGFczeyEk6fiWGR3vIv7ksGraNvtkXOIqyHSeYiW8u0lqGX6PHx4Scmc4SAsjgveIqecmyj01lqyHLWWsyWemyckeyYDeObWpb2GLNMNybpNfq5WZuF9YGt13s2lkQFUO65PWY1AfpL6r0GZ1isv)Tsu9oxSsEqQ6t4oaoD5cAO8nGQNjEM65jK0clPQ3EVo6fyy90W6t4uAy9mgSr9oSERDwnvFdQNK40E0lGr1ZyM4FgLlOlO55KSxuqQ6HA17POxq96(IlxqlWSr7S1KaBq1JXXgAkgxppzHZrf0dQEEQPyzju9mbt8vVLWWsyuqxqpO6H6ickjBReRhf0Ek6fCzBeLwjwpygYiUTTESXE7Bbf0Ek6fCzBeLwjwpygYixqUoWlO9u0l4Y2ikTsSEWmKrKC0qszMlYOipW5ZgrPvI1dZrPfOoimbff0Ek6fCzBeLwjwpygYiNUtKXbkJQteF2ikTsSEyokTa1bHj(6jeenr0H7SAQG2trVGlBJO0kX6bZqg5WD1k3WQDfD81tiioanxeCkl5OHMDAcCYi5xqiJFNFxdY0GZ122KQG2trVGlBJO0kX6bZqgH7ithKeFaxIG483H7i)mZfeMDASx5eQGUGEq1ZZ7nOEEYgE0lOG2trVGdYWonSG2trVGJziJaRJANvt8bCjcYbuM0cuD0lGpyDnhbHLBoZNUtKXbkJQtuMZMbgoBsRnHJGtXLpCoupKaMlwKeVqGj(GYosvFS1ROGqsnGQxoof4eQ(0UA1khC1l37O(5IQhdav1Z6hPQFb1hocofxUGEq1lB4uAy9YguD17r9ZgDrbTNIEbhZqgj5ATXtrVaJUVGpGlrqsQRGEq1Zt4a1p506X1FY7iHtx9XwFGt1JfKRdCsvppzdp6fupJzhxVABa86VLVoQFUOeD1BVRUbWRVN1d2aVbWRVV6Dy9w7SAIr5cApf9coMHmcIdy8u0lWO7l4d4seKlixh4KIVEc5cY1boPYUwxqpO65PTT1JR)0DImoqzuDIQ3J6TK56LnOE9koudGxFGt1pB0f1ZemQ)O0cuhF(miu9bUh1llMRx2G613Z67OEI)TBeD1lVd8guFGt1di(pQhkhzdQQFr13x9GnQNZUG2trVGJziJC6orghOmQor81tiNnP1MWrWP4YhohQhsaZflsAayY6SHJhgej5n44fMSYYnN5t3jY4aLr1jkJijVb3aWtQSKZ)wtRe7AS3gehVqKfuIXrlrdWemyemZYc6bvppvGEC9jChaNQhTHh9cQVN1lNQh3HLQ3g1lQJXg0gE0lO(JI6DGQEjoD02AQ(WrWP4QNZoxq7POxWXmKrG1rTZQj(aUebH7iJnQxuhJnOn8OxaFW6AocInQxuhJnOn8OxG1ZM0At4i4uC5dNd1djG5IfjXlellOhu9qDuVOogxppzdp6faLR6HYtbpLRE4nSu9E9jKBxVZUCr9eGqWhx)Cr1h4u9xqUoWRx2GQREgZY1AfHQ)IwRRhrNnLI67Gr56L9LZMVoQp5G6zP6dCpQ)AjBnLlO9u0l4ygYijxRnEk6fy09f8bCjcYfKRdCtsD81tiW6O2z1uM7iJnQxuhJnOn8Oxqb9GQhk7iv9XwVIMnGQxoobQp265oQ(lixh41lBq1v)IQNLR1kcDf0Ek6fCmdzeyDu7SAIpGlrqUGCDGBcCeD4RwXhSUMJGyjuWC4AcezyB4lktaNvtkyMLWG5W1eiYs(feYStZH7Qv(LjGZQjfmZsyWC4Ace5d3vRCZCtCxMaoRMuWmlHcMdxtGi7ApH6yCMaoRMuWmlHbZwcfWmgF2KwBchbNIlF4COEibmxSijEHilgvqpO6LTfCTIq1ZDnaE9E9yb56aVEzdQQxoobQhrEcVbWRpWP6jaHGpU(ahrh(Qvf0Ek6fCmdzKKR1gpf9cm6(c(aUeb5cY1bUjPo(6jecqi4JZkA2PogacSoQDwnLVGCDGBcCeD4RwvqpO6TOHJh8uU65zjaCYbjINPEEcNDWHO6zP5IO6XglXU6REpQxVYRx2G61hB9PvITbu9KJ0JRhrteD41lVd86Htr0a41h4u9SCZz9C2565P13wVELxVSb1RxXHAa86XglXU6REwkKteOEOYbj6QxEh41BjZ1BbpBUG2trVGJziJG4SdoeXxpH48hH6GYGgoECgyjaCYbjktaNvtkR8GLBoZGgoECgyjaCYbjkZzBnTsSRXEBqCzfn7uh8YKvgF2KwBchbNIlF4COEibmxSiPbSKbgG1rTZQPm3rgBuVOogBqB4rVagzLXPD1QvoiFJLyx9z2PrrEGNrKK3GBai8JbgySZFeQdkdA44XzGLaWjhKOmYbd5fILwz5MZ8nwID1NzNgf5bEgrsEdoE5NvECb56aNuzxRTM2vRw5G8H7QvUr5GeLt4ocoDMjYtrVaxZleyKhmmIrf0Ek6fCmdzKKR1gpf9cm6(c(aUebz2G(W5RNqqCaAUi4uwrEGRhBoCxTYVmn4CTTnPSQ2iFK91xo60Wga3QAJ8r2xFzej5n4gaILwtRe7AS3gehVqSSG2trVGJziJKCT24POxGr3xWhWLiiZg0hoF9esAxTALdY3yj2vFMDAuKh4zej5n4gaILwtRe7AS3gehVqS0kIdqZfbNYbozqBeeitdoxBBtQcApf9coMHmsY1AJNIEbgDFbFaxIGmBqF481tiPvIDn2BdIdIdAjpH7i4KYKSlOhu9qbZ1lVd86HkS6z8YfxRO6VGCDGZOcApf9coMHmsY1AJNIEbgDFbFaxIGmBqF481tiPvIDn2BdIlROzN6yaimXadZgoEyqKK3GBaimznTsSRXEBqC8cHFf0dQEyEd6dVEpQxwmxV8oWxUOEOcRGEq1py7aVEOcRExFB9Zg0hE9EuVSyUEhU3GlQN4Fpf6X1lR6dhbNIREgVCX1kQ(lixh4mQG2trVGJziJKCT24POxGr3xWhWLiiZg0hoF9eYztATjCeCkU8HZH6HeWCXIKGilRPvIDn2BdIJxiYQGEq1dLDu9E9SCTwrO6LJtG6rKNWBa86dCQEcqi4JRpWr0HVAvbTNIEbhZqgj5ATXtrVaJUVGpGlrqy5ATIVEcHaec(4SIMDQJbGaRJANvt5lixh4Mahrh(Qvf0dQEO8RC6I6Tr9I6yC9nOExRRFN1h4u980qDO81ZsjN7O67O(KZD0vVxpuoYguvq7POxWXmKrCuYbKjweIabF9ecbie8Xzfn7uh8cHjOGzcqi4JZicobkO9u0l4ygYiok5aYyZPpQG2trVGJziJOB44XzK94uWLiquq7POxWXmKryD4MDAcuNgEf0f0dQEzBxTALdUc6bvpu2r1dvoir1VZjucEsvplnxevFGt1pB0f1F4COEibmxSiP6NOvQEzweWvB9PvIU6BqUG2trVGlNuhZqg5WD1k3OCqI4J7iZoNg4jfeM4RNq4bl3CMpCxTYnkhKOmNTvwU5mF4COEibmXIaUAZC2wz5MZ8HZH6HeWelc4QnJijVb3aq4xgkkOhu9mgkdOP7Q31iYvJRNZUEwk5ChvVCQ(y3H1JH7QvE9W8nXDmQEUJQhBSe7QV635ekbpPQNLMlIQpWP6Nn6I6pCoupKaMlwKu9t0kvVmlc4QT(0krx9nixq7POxWLtQJziJCJLyx9z2PrrEGZh3rMDonWtkimXxpHWYnN5dNd1djGjweWvBMZ2kl3CMpCoupKaMyraxTzej5n4gac)YqrbTNIEbxoPoMHmYu7WjT2JEb81tiW6O2z1u(aktAbQo6fyLhxqUoWjvwYbHMkO9u0l4Yj1XmKrMAhoP1E0lWK0KdoIVEcrrSCZzEQD4Kw7rVGmIK8gCdyjdmOiwU5mp1oCsR9Oxq(cpnKxiYcgf0Ek6fC5K6ygYiW6G(W5RNqymIdqZfbNYsoAOzNMaNms(feY43531Gmn4CTTnPSMwj21yVniUSIMDQJbGWpgyaXbO5IGtzf5bUES5WD1k)Y0GZ122KYAALyxJ92G4gGjgzLLBoZ3yj2vFMDAuKh4zoBRSCZz(WD1k3OCqIYC2wL8liKXVZVRbgej5n4GadRSCZzwrEGRhBoCxTYVSALdkO9u0l4Yj1XmKrsUwB8u0lWO7l4d4see6ocKOJVEcHhxqUoWjv21ARW6O2z1u(aktAbQo6fWad0Deirzwe5bUzNMaNmQXnaEwYL9wK1OLiEHyzb9GQhQVRU(5IQxMfbC1wVnIGsyluvV8oWRhdhQQhrUAC9YXjq9GnQhXbanaE9yW8CbTNIEbxoPoMHmI9UAdIULdLi(MlYai(pGWeF9ecpcxtGiF4UALBMBI7YeWz1KQGEq1dLDu9YSiGR26Tru9yluvVCCcuVCQEChwQ(aNQNaec(46LJtboHQFIwP6T3v3a41lVd8LlQhdMx)IQx2J7I6Htac5A94CbTNIEbxoPoMHmYHZH6HeWelc4QLVEcHaec(yEHatWWkSoQDwnLpGYKwGQJEbwt7QvRCq(glXU6ZStJI8apZzBnTRwTYb5d3vRCJYbjkNWDeC64fctf0Ek6fC5K6ygYihHqEqkd7ciZz3dj(sJtAYeocofheM4RNqG1rTZQP8buM0cuD0lWkpuBKpcH8Gug2fqMZUhsg1g5OtdBaCgyy2WXddIK8gCdabkkOhu9qzhvp2yj2vF1VG6t7QvRCq9m2NbHQF2OlQhdavmQEoGMURE5u9oIQh(2a41hB92RD9YSiGR26DGQE1wpyJ6XDyP6XWD1kVEy(M4UC9q5x51lBq96NlQEzWP65jBeeixq7POxWLtQJziJCJLyx9z2PrrEGZxpHaRJANvt5dOmPfO6OxGvEK2vRw5G8H7QvUHv7k6YC2wzC4AcezcalPx7ga3C4UALFzc4SAsXadPD1QvoiF4UALBuoir5eUJGthVqyIrwzmpcxtGiF4COEibmXIaUAZeWz1KIbgcxtGiF4UALBMBI7YeWz1KIbgs7QvRCq(W5q9qcyIfbC1MrKK3GJxlzKvgZdehGMlcoLdCYG2iiqMgCU22MumWqALyxJ92G4gaILmYkJ5bDhbsuMvVRYSttGtgcqsJZsUS3IyGH0UA1khKz17Qm70e4KHaK04mIK8gC8AjJkOhu98CZ6DL6Q3ru9C28v)bABQ(aNQFbu9Y7aVE9kNUOEzKbQY1dLDu9YXjq9QXnaE9t)ccvFG7G6LnOE9kA2PoQFr1d2O(lixh4KQE5DGVCr9oyC9Ygupxq7POxWLtQJziJi5OHKYmxKrrEGZxACstMWrWP4GWeF9ecYBLHGLar2vQlZzBLXHJGtroAjYeRr10aPvIDn2BdIlROzN6Gbg4XfKRdCsLDT2AALyxJ92G4YkA2Po4fsY2i58V5SjGIrf0dQEEUz9GTExPU6L3AD9QMQxEh4nO(aNQhq8Fup)GXXx9Chvpp)eQQFb1ZU3vV8oWxUOEhmUEzdQNlO9u0l4Yj1XmKrKC0qszMlYOipW5RNqqERmeSeiYUsD5gWl)Gbuc5TYqWsGi7k1LvCip6fynTsSRXEBqCzfn7uh8cjzBKC(3C2eqvq7POxWLtQJziJC4UALBy1UIo(6jeyDu7SAkFaLjTavh9cSMwj21yVniUSIMDQdEHyzbTNIEbxoPoMHmcLW3ga3GiBul5afF9ecSoQDwnLpGYKwGQJEbwtRe7AS3gexwrZo1bVq4N1ZM0At4i4uC5dNd1djG5IfjnaezvqpO6hSDGxpgmNV67z9GnQ31iYvJRxTaIV65oQEzweWvB9Y7aVESfQQNZoxq7POxWLtQJziJC4COEibmXIaUA5RNqcxtGiF4UALBMBI7YeWz1KYkSoQDwnLpGYKwGQJEbwz5MZ8nwID1NzNgf5bEMZUG2trVGlNuhZqg5WD1k3OCqI4RNq4bl3CMpCxTYnkhKOmNT1zdhpmisYBWnaeOgZHRjqKpo2Gqto4uMaoRMuf0f0dQElwau6SPu9xWnN1lVd861RCcvVnQ3cApf9cUCsDmdze7n6fuq7POxWLtQJziJWQ3vzMCOX81tiSCZz(glXU6ZStJI8apZzxq7POxWLtQJziJWsOJqdBaC(6jewU5mFJLyx9z2PrrEGN5SlO9u0l4Yj1XmKrMnIy17Q4RNqy5MZ8nwID1NzNgf5bEMZUG2trVGlNuhZqgXbj6cKRnjxR5RNqy5MZ8nwID1NzNgf5bEMZUGUG2trVGlNuhZqgH7ithKeF0CsPWaCjcsACsVbAbDYWQ9l4RNq4XfKRdCsLDT2kSoQDwnLpGYKwGQJEbw5bl3CMVXsSR(m70OipWZC2wjaHGpoROzN6Gxi8dgf0Ek6fC5K6ygYiChz6GK4d4seeN)oCh5NzUGWStJ9kNq81ti8GLBoZhURw5gLdsuMZ2AAxTALdY3yj2vFMDAuKh4zej5n4gGjyuqpO63aNqY7JQxEh41JTqv9EuVLqbZ1FHNgE1VO6zckyUE5DGxVRVT(r17QQNZoxq7POxWLtQJziJWDKPdsIpGlrq8dhwhqNb583ImPf5A(6jefXYnNzKZFlYKwKRnkILBoZQvoGbguel3CMtlqXLIgwY0GHgfXYnNzoBRHJGtrgNCDGNTtXa8ZsRHJGtrgNCDGNTtbVq4hmyGbEOiwU5mNwGIlfnSKPbdnkILBoZC2wzSIy5MZmY5VfzslY1gfXYnN5l80qEHyjuaLycgWmfXYnNzw9UkZonboziajnoZzZadZgoEyqKK3GBazbdgzLLBoZ3yj2vFMDAuKh4zej5n44fQvqpO65zj046rlhCC946rCAQ(DwFGZjX2ZMu1l5b(vplPx58m1dLDu9ZfvpphyO9QQpH6OG2trVGlNuhZqgH7ithKeFaxIGinw5NjCDFsoOGEq1dv0050r9txRz90W6NlQEUZz1u9Dqshpt9qzhvV8oWRhBSe7QV63z9qf5bEUG2trVGlNuhZqgH7ithK0XxpHWYnN5BSe7QpZonkYd8mNndmmB44HbrsEdUbSegf0f0dQEEA(JqDq1l7ZDeirxbTNIEbxMUJaj6ygYiPfKiqG8GuMP2Li(6jecqi4JZrlrMynso)Zltw5bl3CMVXsSR(m70OipWZC2wzmpuBKtlirGa5bPmtTlrgwoeihDAydGBLhEk6fKtlirGa5bPmtTlr5gyM6goEWadtoT2GOeUJGtMOLObGNuzjN)zubTNIEbxMUJaj6ygYiS6DvMDAcCYqasAmF9ecps7QvRCq(WD1k3WQDfDzoBRPD1QvoiFJLyx9z2PrrEGN5SzGHzdhpmisYBWnaeMGrbTNIEbxMUJaj6ygYiW5CKQDGzNgN)i0g4f0Ek6fCz6ocKOJziJm3e3rkJZFeQdYWsUeF9ecJpBsRnHJGtXLpCoupKaMlwKeVqSKbgqERmeSeiYUsD5gWlmbdgzLhPD1QvoiFJLyx9z2PrrEGN5STYdwU5mFJLyx9z2PrrEGN5STsacbFCwrZo1bVq4hmkO9u0l4Y0DeirhZqgXMd1ZXnaUHv7xWxpHC2KwBchbNIlF4COEibmxSijEHyjdmG8wziyjqKDL6YnGxycgf0Ek6fCz6ocKOJziJe4KHdWUCaLzUOeXxpHWYnNzeLgQP7mZfLOmNndmWYnNzeLgQP7mZfLitA5abHYx4PHdWemkO9u0l4Y0DeirhZqgb122AY0aZz7jQG2trVGlt3rGeDmdze5lsRGLAGbr3cCqI4RNqs7QvRCq(glXU6ZStJI8apJijVb3aqbdmmB44HbrsEdUbycQvq7POxWLP7iqIoMHmIejTOXMDA0CPwzuiYLo(6jecqi4JhqwWWkl3CMVXsSR(m70OipWZC2f0dQEz)RwvppHC7gaVEyU2LOR(5IQN4FkXfu9ihaNQFr1pS166z5MZJV67z927DnRMY1ZtRL7JV6d046JTE4uuFGt1Rx50f1N2vRw5G6z9Ju1VG6Dy9w7SAQEcqsnD5cApf9cUmDhbs0XmKrqKB3a4MP2LOJVEcz2WXddIK8gCdWugkyGbgZ4WrWPiJtUoWZ2PGxOgmyGHWrWPiJtUoWZ2PyaiwcdgzLXEkAyjdbiPMoimXadZgoEyqKK3GJxlhmmIrmWaJdhbNIC0sKjwJDkmwcdE5hmSYypfnSKHaKutheMyGHzdhpmisYBWXRSKfJyubDb9GQhlixh41lB7QvRCWvq7POxWLVGCDGBsQJziJaRJANvt8bCjcYHRmboIo8vR4dwxZrqs7QvRCq(WD1k3OCqIYjChbNoZe5POxGR5fctzzhuWNSFsBtO65zDu7SAQGEq1ZZ6G(WRVN1lNQ3ru9j32UbWRFb1dvoir1NWDeC6Y1l7JJ0JRNLMlIQF2OlQx5GevFpRxovpUdlvpyR3IgoECHRhsO6z5I6HkhnSEmCxTYRVb1VifHQp26Htr98eo7Gdr1ZzxpJbB988(feQEE6787AaJYf0Ek6fC5lixh4MK6ygYiW6G(W5RNqympG1rTZQP8HRmboIo8vRyGbEeUMarg0WXJlC9qcLjGZQjL1W1eiYkhn0C4UALNjGZQjfJSMwj21yVniUSIMDQdEzYkpqCaAUi4uwYrdn70e4KrYVGqg)o)UgKPbNRTTjvbTNIEbx(cY1bUjPoMHmYr2xFf0Ek6fC5lixh4MK6ygYi27Qni6wouI4BUidG4)act8r8FGCJlTCGaISGbFq9D11pxu9y4UALlrAv9mxpgURw5xG6Hu9CanDx9YP6DevVZUCr9XwFYTRFb1dvoir1NWDeC6Y1ZtfOhxVCCcupmVbQ6hSKpeq3vFF17SlxuFS1J4a1VCrUG2trVGlFb56a3KuhZqg5WD1kxI0k(6jecqi4J5fISGHvcqi4JZkA2Po4fctWWkpG1rTZQP8HRmboIo8vRSMwj21yVniUSIMDQdEzYQIy5MZ8SbkJCYhcO7YisYBWnatf0Ek6fC5lixh4MK6ygYiW6O2z1eFaxIGC4ktALyxJ92G44dwxZrqsRe7AS3gexwrZo1bVqKfFYguVEen4CnIKiqWZupu5GevVh1Rx51lBq96zhxVIMoNoYf0dQEzdQxpIgCUgrsei4zQhQCqIQFb6X1ZsZfr1pBqF4e6QVN1lNQh3HLQ3g1lQJX1J2WJEb5cApf9cU8fKRdCtsDmdzeyDu7SAIpGlrqoCLjTsSRXEBqC8bRR5iiPvIDn2BdIlROzN6yaimXxpHaRJANvtzUJm2OErDm2G2WJEbf0dQEOYbjQEfhQbWRhBSe7QV6xu9o7clvFGJOdF1QCbTNIEbx(cY1bUjPoMHmYH7QvUr5GeXxpHaRJANvt5dxzsRe7AS3geNvgdRJANvt5dxzcCeD4RwXadSCZz(glXU6ZStJI8apJijVbhVqykBjdmC2KwBchbNIlF4COEibmxSijEHilRPD1QvoiFJLyx9z2PrrEGNrKK3GJxMGbJkOhu9JYHa1JijVbnaE9qLds0vplnxevFGt1pB44r9eqD13Z6XwOQE5lGNsuplvpIC146Bq9rlr5cApf9cU8fKRdCtsDmdzKd3vRCJYbjIVEcbwh1oRMYhUYKwj21yVnioRZgoEyqKK3GBG0UA1khKVXsSR(m70OipWZisYBWvqxqpO6XcY1boPQNNSHh9ckOhu98CZ6XcY1b(iW6G(WR3ru9C28vp3r1JH7Qv(fOEivFS1ZsaA2r9t0kvFGt1B731Ws1ZUaUREhOQhM3av9dwYhcO7QNGLa13Z6Lt17iQEpQxY5)6LnOE9mEIwP6dCQEBeLwjwpQNNFcvmkxq7POxWLVGCDGtkMHmYH7Qv(fOEiXxpHWywU5mFb56apZzZadSCZzgwh0hEMZMrf0dQEyEd6dVEpQNFmxVSb1RxEh4lxupuHv)i1llMRxEh41dvy1lVd86XW5q9qcuVmlc4QTEwU5SEo76JTEh2Tv1FRevVSb1RxUFbv)1bNh9cUCbTNIEbx(cY1boPygYijxRnEk6fy09f8bCjcYSb9HZxpHWYnN5dNd1djGjweWvBMZ2AALyxJ92G4YkA2PogaILf0dQEEA9T1F(KQp26NnOp869OEzXC9YguVE5DGxpX)Ek0JRxw1hocofxUEgJ5su9(v)YfxRO6VGCDGNzubTNIEbx(cY1boPygYijxRnEk6fy09f8bCjcYSb9HZxpHC2KwBchbNIlF4COEibmxSijiYYAALyxJ92G44fISkOhu9W8g0hE9EuVSyUEzdQxV8oWxUOEOcJV6HcMRxEh41dvy8vVdu1dt1lVd86HkS69zqO65zDqF4f0Ek6fC5lixh4KIziJKCT24POxGr3xWhWLiiZg0hoF9esALyxJ92G4YkA2PogactqjghUMarwrKnHmxG8WHtszc4SAszLLBoZW6G(WZC2mQGEq1dZxu92ickz7rcNV6hsKD9W8gOQFWs(qaDx9C21VG6dCQEBul5OX1hocof1R4O6JTEWwpgURw51ZZ6C6OG2trVGlFb56aNumdzKd3vR8lq9qIVEcrtWs6bGclTQiwU5mpBGYiN8Ha6UmIK8gCdWK1WrWPihTezI1OAckHijVbhVWub9GQhkZU(yRNF1hocofx9djYUEo76H5nqv)GL8Ha6U6zhxFACs3a41JH7Qv(fOEiLlO9u0l4YxqUoWjfZqg5WD1k)cupK4lnoPjt4i4uCqyIVEcrrSCZzE2aLro5db0Dzej5n4gGjRNnP1MWrWP4YhohQhsaZflsAai8ZA4i4uKJwImXAunbLqKK3GJxyQGEq1py7aF5I6HkISju9ybYdhojvVdu1ZV65joy4v)oRFuTRO6Bq9bovpgURw5x9DuFF1lFrbE9CxdGxpgURw5xG6Hu9lOE(vF4i4uC5cApf9cU8fKRdCsXmKroCxTYVa1dj(6jeEeUMarwrKnHmxG8WHtszc4SAsz15pc1bLz1UImnWe4K5WD1k)Yihmec)SE2KwBchbNIlF4COEibmxSiji8RGEq1dZxu92OErDmUE0gE0lGV65oQEmCxTYVa1dP6xyju9yXIKQNjgvV8oWRFWYZxVd3BWf1ZzxFS1lR6dhbNIJV6TKr13Z6H5d267REeha0a41VZz9mEb17GX17slhiQFN1hocofhJ4R(fvp)yu9XwVKZ)TuZFu9yluvpX)bbUEb1lVd8655aeSD4STUJX1VG65x9HJGtXvpJLv9Y7aV(r7aJr5cApf9cU8fKRdCsXmKroCxTYVa1dj(6jeyDu7SAkZDKXg1lQJXg0gE0lWkJvel3CMNnqzKt(qaDxgrsEdUbyIbgcxtGilNC7fi5xqOmbCwnPSE2KwBchbNIlF4COEibmxSiPbGilgyW5pc1bLBabBhoBR7yCMaoRMuwz5MZ8nwID1NzNgf5bEMZ26ztATjCeCkU8HZH6HeWCXIKgac)y25pc1bLz1UImnWe4K5WD1k)YeWz1KIrf0Ek6fC5lixh4KIziJC4COEibmxSij(6jKZM0At4i4uC8cHFmZywU5mBJijs1Hh9cYC2mWal3CMdCYG2iiqMZMbgqCaAUi4u2h6oQpZTCAZe5WLiqKPbNRTTjL10cuCDKveztiJYHdNqxg5GH8cr2XOcApf9cU8fKRdCsXmKroCxTYVa1dj(6jefXYnN5zdug5Kpeq3LrKK3GBaimXadPD1QvoiFJLyx9z2PrrEGNrKK3GBaMGAwvel3CMNnqzKt(qaDxgrsEdUbs7QvRCq(glXU6ZStJI8apJijVbxb9GQhd3vR8lq9qQ(yRhrteD41dZBGQ(bl5db0D17av9XwpbooevVCQ(KdQp5i046xyju9E9toTUEy(GT(geB9bovpG4)OESfQQVN1BV31SAkxq7POxWLVGCDGtkMHmI9UAdIULdLi(MlYai(pGWubTNIEbx(cY1boPygYiW17kXQDfXxpHWdehGMlcoL9HUJ6ZClN2mroCjcezAW5ABBszLLBoZ2eAUipiLbwQbx(cpnKxi8ZAAbkUoY2eAUipiLbwQbxg5GH8cHj(bLy8GbMLwGIRJSIiBczuoC4ektaNvtkMtlqX1rwrKnHmkhoCcLroyiJkO9u0l4YxqUoWjfZqgbUExjwTRi(6jeehGMlcoL9HUJ6ZClN2mroCjcezAW5ABBszLLBoZ2eAUipiLbwQbx(cpnKxi8ZkJtlqX1r2MqZf5bPmWsn4YihmK50cuCDKveztiJYHdNqzKdgYiEHWemvq7POxWLVGCDGtkMHmYH7Qv(fOEivqxqpO6H5nOpCcDf0Ek6fC5zd6dNziJC6orghOmQor81tiNnP1MWrWP4YhohQhsaZflsAayYkpy5MZ8H7QvUr5GeL5STYYnN5t3jY4aLr1jkJijVb3aZgoEyqKK3GZkl3CMpDNiJdugvNOmIK8gCdWyMyoTsSRXEBqCmcMXugQvq7POxWLNnOpCMHmcSoQDwnXhWLii3W22G4SdoeXhSUMJGi5xqiJFNFxdmisYBWXlmyGbEeUMarg0WXJlC9qcLjGZQjL1W1eiYkhn0C4UALNjGZQjLvwU5mF4UALBuoirzoBgy4SjT2eocofx(W5q9qcyUyrs8cbM4t2pPTju98SoQDwnv)Cr1Zt4SdoeLRhByBxVId1a41ZZ7xqO65PVZVRb1VO6vCOgaVEOYbjQE5DGxpu5OH17av9GTElA44XfUEiHYf0dQEOCtKD9C21Zt4SdoevFpRVJ67REND5I6JTEehO(LlYf0Ek6fC5zd6dNziJG4SdoeXxpHWdyDu7SAkFdBBdIZo4qK1WrWPihTezI1OAckHijVbhVWKvenr0H7SAQG2trVGlpBqF4mdzKJsikmbLWb9GZrf0dQEEEoD0QnIgaV(WrWP4QpW9OE5TwxVUHLQFUO6dCQEfhYJEb1VZ65jC2bhIQhrteD41R4qnaE92oqrsDkxq7POxWLNnOpCMHmcIZo4qeFPXjnzchbNIdct81ti8awh1oRMY3W22G4SdoezLhW6O2z1uM7iJnQxuhJnOn8OxG1ZM0At4i4uC5dNd1djG5IfjXlelTgocof5OLitSgvt8cHXqbZm2sywALyxJ92G4yeJSIOjIoCNvtf0dQEEcnr0HxppHZo4qu9KJ0JRVN13r9YBTUEI)TBevVId1a41JnwID1xUEOARpW9OEenr0HxFpRhBHQ6HtXvpIC146Bq9bovpG4)OEO4Yf0Ek6fC5zd6dNziJG4SdoeXxpHWdyDu7SAkFdBBdIZo4qKvej5n4giTRwTYb5BSe7QpZonkYd8mIK8gCmZemSM2vRw5G8nwID1NzNgf5bEgrsEdUbGafwdhbNIC0sKjwJQjOeIK8gC8M2vRw5G8nwID1NzNgf5bEgrsEdoMHIcApf9cU8Sb9HZmKry1EAOXELRieF9ecpG1rTZQPm3rgBuVOogBqB4rVaRNnP1MWrWP44fc)kO9u0l4YZg0hoZqgHGTVeH8GkOlOhu9JY1AfHUcApf9cUmlxRvmdzKdNd1djG5IfjXxpHC2KwBchbNIJxiwYmJdxtGidxVReR2vuMaoRMuwD(JqDqzBcnxKhug5GH8cXsR271rVadRNgYOcApf9cUmlxRvmdzKJqipiLHDbK5S7HeF9esAxTALdYhHqEqkd7ciZz3dPCc3rWPZmrEk6f4AEHyzw2bff0Ek6fCzwUwRygYiW17kXQDfvq7POxWLz5ATIziJW6PHx4ScSZMsclSeMyseIqia]] )


end
