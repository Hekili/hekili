-- RogueSubtlety.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ] 

local class = Hekili.Class
local state = Hekili.State

local insert = table.insert

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

        vendetta_regen = {
            aura = "vendetta_regen",

            last = function ()
                local app = state.buff.vendetta_regen.applied
                local t = state.query_time

                return app + floor( t - app )
            end,

            interval = 1,
            value = 20,
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
        dagger_in_the_dark = 846, -- 198675
        death_from_above = 3462, -- 269513
        dismantle = 5406, -- 207777
        distracting_mirage = 5411, -- 354661
        maneuverability = 3447, -- 197000
        shadowy_duel = 153, -- 207736
        silhouette = 856, -- 197899
        smoke_bomb = 1209, -- 359053
        thick_as_thieves = 5409, -- 221622
        thiefs_bargain = 146, -- 354825
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
            duration = function () return talent.subterfuge.enabled and 9 or 8 end,
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
            copy = "symbols_of_death_autocrit"
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
            alias = { "instant_poison", "wound_poison" },
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
            max_stack = 1,
        },

        master_assassins_mark = {
            id = 340094,
            duration = 4,
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


    local stealth = {
        rogue   = { "stealth", "vanish", "shadow_dance", "subterfuge" },
        mantle  = { "stealth", "vanish" },
        sepsis  = { "sepsis_buff" },
        all     = { "stealth", "vanish", "shadow_dance", "subterfuge", "shadowmeld", "sepsis_buff" }
    }


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
            
            elseif k == "sepsis" then
                return buff.sepsis_buff.up
            elseif k == "sepsis_remains" then
                return buff.sepsis_buff.remains
            
            elseif k == "all" then
                return buff.stealth.up or buff.vanish.up or buff.shadow_dance.up or buff.subterfuge.up or buff.shadowmeld.up or buff.sepsis_buff.up
            elseif k == "remains" or k == "all_remains" then
                return max( buff.stealth.remains, buff.vanish.remains, buff.shadow_dance.remains, buff.subterfuge.remains, buff.shadowmeld.remains, buff.sepsis_buff.remains )
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
                for i = 1, 4 do
                    insert( sht, mh_next + ( i * mh_speed ) )
                end
            end

            if oh_speed and oh_speed > 0 then
                for i = 1, 4 do
                    insert( sht, oh_next + ( i * oh_speed ) )
                end
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

            reduceCooldown( "shadow_dance", amt * ( talent.enveloping_shadows.enabled and 1.5 or 1 ) )

            if legendary.obedience.enabled and buff.flagellation_buff.up then
                reduceCooldown( "flagellation", amt )
            end
        end
    end

    spec:RegisterHook( "spend", comboSpender )
    -- spec:RegisterHook( "spendResources", comboSpender )


    spec:RegisterStateExpr( "mantle_duration", function ()
        return legendary.mark_of_the_master_assassin.enabled and 4 or 0
    end )

    spec:RegisterStateExpr( "master_assassin_remains", function ()
        if not legendary.mark_of_the_master_assassin.enabled then return 0 end

        if stealthed.mantle then return cooldown.global_cooldown.remains + 4
        elseif buff.master_assassins_mark.up then return buff.master_assassins_mark.remains end
        return 0
    end )


    spec:RegisterStateExpr( "priority_rotation", function ()
        return settings.priority_rotation
    end )


    -- We need to break stealth when we start combat from an ability.
    spec:RegisterHook( "runHandler", function( ability )
        local a = class.abilities[ ability ]

        if stealthed.mantle and ( not a or a.startsCombat ) then
            if talent.subterfuge.enabled and stealthed.mantle then
                applyBuff( "subterfuge" )
            end

            if legendary.mark_of_the_master_assassin.enabled and stealthed.mantle then
                applyBuff( "master_assassins_mark", 4 )
            end

            if buff.stealth.up then 
                setCooldown( "stealth", 2 )
            end
            removeBuff( "stealth" )
            removeBuff( "vanish" )
            removeBuff( "shadowmeld" )
        end
    end )

    
    local ExpireSepsis = setfenv( function ()
        applyBuff( "sepsis_buff" )

        if legendary.toxic_onslaught.enabled then
            applyBuff( "adrenaline_rush", 10 )
            applyDebuff( "target", "vendetta", 10 )
        end    
    end, state )

    spec:RegisterHook( "reset_precast", function( amt, resource )
        if debuff.sepsis.up then
            state:QueueAuraExpiration( "sepsis", ExpireSepsis, debuff.sepsis.expires )
        end

        class.abilities.apply_poison = class.abilities.apply_poison_actual
        if buff.lethal_poison.down or level < 33 then
            class.abilities.apply_poison = state.spec.assassination and level > 12 and class.abilities.deadly_poison or class.abilities.instant_poison
        else
            if level > 32 and buff.nonlethal_poison.down then class.abilities.apply_poison = class.abilities.crippling_poison end
        end
    end )

    spec:RegisterHook( "runHandler", function ()
        class.abilities.apply_poison = class.abilities.apply_poison_actual
        if buff.lethal_poison.down or level < 33 then
            class.abilities.apply_poison = state.spec.assassination and level > 12 and class.abilities.deadly_poison or class.abilities.instant_poison
        else
            if level > 32 and buff.nonlethal_poison.down then class.abilities.apply_poison = class.abilities.crippling_poison end
        end
    end )

    spec:RegisterCycle( function ()
        if active_enemies == 1 then return end
        if this_action == "marked_for_death" then
            if active_dot.marked_for_death >= cycle_enemies then return end -- As far as we can tell, MfD is on everything we care about, so we don't cycle.
            if debuff.marked_for_death.up then return "cycle" end -- If current target already has MfD, cycle.
            if target.time_to_die > 3 + Hekili:GetLowestTTD() and active_dot.marked_for_death == 0 then return "cycle" end -- If our target isn't lowest TTD, and we don't have to worry that the lowest TTD target is already MfD'd, cycle.
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
    spec:RegisterGear( "tier28", 188901, 188902, 188903, 188905, 188907 )
    spec:RegisterSetBonuses( "tier28_2pc", 364557, "tier28_4pc", 363949 )
    -- 2-Set - Immortal Technique - Shadowstrike has a 15% chance to grant Shadow Blades for 5 sec.
    -- 4-Set - Immortal Technique - Your finishing moves have a 3% chance per combo point to cast Shadowstrike at up to 5 enemies within 15 yards.
    -- 2/15/22:  No mechanics to model.


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
            texture = 608955,

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
                return 40 * ( ( talent.shadow_focus.enabled and ( buff.shadow_dance.up or buff.stealth.up ) ) and 0.8 or 1 ) * ( 1 + conduit.rushed_setup.mod * 0.01 )
            end,
            spendType = "energy",

            startsCombat = true,
            texture = 132092,

            cycle = function ()
                if talent.prey_on_the_weak.enabled then return "prey_on_the_weak" end
            end,

            usable = function ()
                if boss then return false, "cheap_shot assumed unusable in boss fights" end
                return stealthed.all, "not stealthed"
            end,

            nodebuff = "cheap_shot",

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

                if buff.sepsis_buff.up then removeBuff( "sepsis_buff" ) end

                gain( buff.shadow_blades.up and 2 or 1, "combo_points" )
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

            spend = function () return 30 * ( ( talent.shadow_focus.enabled and ( buff.shadow_dance.up or buff.stealth.up ) ) and 0.8 or 1 ) * ( 1 + conduit.rushed_setup.mod * 0.01 ) end,
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

            bind = function ()
                if ( buff.lethal_poison.down or level < 33 ) and not ( state.spec.assassination and level > 12 ) then return "apply_poison" end
            end,
            
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

            spend = function () return 25 * ( ( talent.shadow_focus.enabled and ( buff.shadow_dance.up or buff.stealth.up ) ) and 0.8 or 1 ) * ( 1 + conduit.rushed_setup.mod * 0.01 ) end,
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
                applyDebuff( "target", "kidney_shot", 2 + 1 * ( combo - 1 ) )

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

            startsCombat = false,
            texture = 236364,

            usable = function ()
                return combo_points.current <= settings.mfd_points, "combo_point (" .. combo_points.current .. ") > user preference (" .. settings.mfd_points .. ")"
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

            spend = function () return 35 * ( ( talent.shadow_focus.enabled and ( buff.shadow_dance.up or buff.stealth.up ) ) and 0.8 or 1 ) * ( 1 + conduit.rushed_setup.mod * 0.01 ) end,
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
            charges = function () return talent.enveloping_shadows.enabled and 2 or nil end,
            cooldown = 60,
            recharge = function () return talent.enveloping_shadows.enabled and 60 or nil end,
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

            usable = function () return stealthed.all or buff.sepsis_buff.up, "requires stealth or sepsis_buff" end,
            handler = function ()
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

                removeBuff( "sepsis_buff" )

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
                return not settings.solo_vanish and not ( boss and group ), "can only vanish in a boss encounter or with a group"
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

        potion = "phantom_fire",

        package = "Subtlety",
    } )



    spec:RegisterSetting( "mfd_points", 3, {
        name = "|T236340:0|t Marked for Death Combo Points",
        desc = "The addon will only recommend |T236364:0|t Marked for Death when you have the specified number of combo points or fewer.",
        type = "range",
        min = 0,
        max = 5,
        step = 1,
        width = "full"
    } )

    spec:RegisterSetting( "priority_rotation", false, {
        name = "Use Priority Rotation (Funnel Damage)",
        desc = "If checked, the default priority will recommend building combo points with |T1375677:0|t Shuriken Storm and spending on single-target finishers.",
        type = "toggle",
        width = "full"
    })

    spec:RegisterSetting( "solo_vanish", true, {
        name = "Allow |T132331:0|t Vanish when Solo",
        desc = "If unchecked, the addon will not recommend |T132331:0|t Vanish when you are alone (to avoid resetting combat).",
        type = "toggle",
        width = "full"
    } )

    spec:RegisterSetting( "allow_shadowmeld", nil, {
        name = "Allow |T132089:0|t Shadowmeld",
        desc = "If checked, |T132089:0|t Shadowmeld can be recommended for Night Elves when its conditions are met.  Your stealth-based abilities can be used in Shadowmeld, even if your action bar does not change.  " ..
            "Shadowmeld can only be recommended in boss fights or when you are in a group (to avoid resetting combat).",
        type = "toggle",
        width = "full",
        get = function () return not Hekili.DB.profile.specs[ 261 ].abilities.shadowmeld.disabled end,
        set = function ( _, val )
            Hekili.DB.profile.specs[ 261 ].abilities.shadowmeld.disabled = not val
        end,
    } )    


    spec:RegisterPack( "Subtlety", 20211208, [[de1IgcqiuP8ikPAtuQ(KIeJsLKtPOQvPiGxPi1SirUfju2Lk(fQedJeLJrcwguINPsvMgQuDnsuTnvsPVrjfnovsHZHkjADQuvnpvQCpuX(OK8pkPGoiQKQfcL0dvK0ejHCrujH2OIG(ijuXijHk1jvjfTsOuVKskWmrLKUjju1ovu5NkcKHsjLwQkPYtrPPQi6QOskBLsk0xvjvnwvQkNLeQK2RK(RedMQdlAXq6XkmzsDzKndXNHIrJItl1QrLe8AfLztXTjPDd8BLgoQ64kculh0Zv10fUouTDkLVtjgVIqNxLy9KqLy(Qu2pXvfQtwz1zq15WIYWIckGfLDnokWvQmf4Ucv24cpvz5ZXSedvzbPkvzzXrddfxQS85fZM66Kv2FXHdQYYeb)F)CHly6Gbh9mwvU8TkUjJEbdyIeC5B1bxQSO4TjUMGkALvNbvNdlkdlkOawu214OaxPYu4ECLv2epywyLLTvNALLP1AcurRSA6hvwwC0WqXfXVUfdojyRiAqQOeu8RHsIJfLHffeSfSNktcWq)9lyRyIR4xBK42syNOg6G)uHh2lSJlf4gz0lqCCEX)v8oeVFXFkehLqwijUfsC8NeVJJGTIj(uxv0gqIRIBIM3qIpsJPKJOxqX0FiobcytV4XkoK04dsC(niq0PrCizzHZoc2kM4k(Cgj(eAONzatKq8geeeIZhI3aXhRkAgI3iIBHeNRa(hIRBT4DioYcf32AYOnu5xJnceNkRP)4Rtwz)GstWq66K15uOozLLajQH0vSwzZr0lOY(mPET8bSNrvwn9dyZh9cQSxteXzdknbdxSLG(zepHK448kjo(tIZYK61YhWEgjESIJsacPdXrGRQ4bdjoF(FBJehDb4V4jql(e2aT4xpLZa0)kjozJaI3iIBHepHK4ziUAorXNQ1k(v4ad9V44FdWiUIp)GGIZ1)p)VbZxzhWoiyNv2Rehfhb58bLMG5GZl(TBIJIJGCSLG(zo48IpV42f)kXFEYykrcXqXFEgCypJaLpwOQ43jo3f)2nXTLWorn0b)PcpSxyhxkWnYOxG4ZlUDXvZpiyj)p)VbfiPMn4fNJ4kRg15WsDYklbsudPRyTYQPFaB(OxqLDcBq)mINH4CFAXNQ1kULoyw8qCfXQK4kFAXT0bJ4kIvjXtGw8RvClDWiUIyfprcckU1yc6NPYMJOxqLDKgtjhrVGIP)OYoGDqWoRS2syNOg6qii0iABuzSQOBHFBq8IBfhXh8f1CILNNaAXVDtCuCeKZZGd7zeOeleK69GZlUDXhRk6w43ge)rti9OdXVJJ4yr8B3e)5jJPejedf)5zWH9mcu(yHQIBfhX5U42f3wc7e1qhcbHgrBJkJvfDl8BdIxCR4io3f)2nXhRk6w43ge)rti9OdXVJJ4kiUIj(vIhPHaXrtepblFaZiXqQhcKOgslUDXrXrqo2sq)mhCEXNVYA6pkGuLQSinOFMAuN7E1jRSeirnKUI1k7a2bb7SY(bLMGH0NN4)(f3U4ppzmLiHyO4ppdoSNrGYhluv87eN7v2Ce9cQSptQxlFa7zunQZX96KvwcKOgsxXALDa7GGDwzJ0qG4aAmmXhPzgbpeirnKwC7IdXbeYcXqNObxkXoXEuqnPMoeirnKwC7I)8KXuIeIHI)8m4WEgbkFSqvXVtCLxzZr0lOY(mTTAuNt51jRSeirnKUI1kBoIEbv2Nj1RLpG9mQYoUmmujsigk(6CkuzhWoiyNvwUjUTe2jQHo4pv4H9c74sbUrg9ce3U4Acfhb5G0aDXcLZa0)hiPMn4f)oXvqC7I)8KXuIeIHI)8m4WEgbkFSqvXVJJ43tC7IhjedfNOvPsSfDtIRyIdj1SbV4wj(1wz10pGnF0lOYY14fpwXVN4rcXqXl(vGvCEyVZl(mI4fhNx8jSbAXVEkNbO)fh9I4JldtdWioltQxlFa7z0Pg15U26KvwcKOgsxXALnhrVGk7ZK61YhWEgvz10pGnF0lOYoHluCEyVWoUioCJm6fOK44pjoltQxlFa7zK4RnckoBSqvXT0bJ4xVIx8et2GpehNx8yfN7IhjedfV4lu8gr8j86fVFXH4aqdWi(IGi(vlq8eCr8uDXbH4lI4rcXqXpFLDa7GGDwzTLWorn0b)PcpSxyhxkWnYOxG42f)kX1ekocYbPb6IfkNbO)pqsnBWl(DIRG43UjEKgcehluYVa18dcEiqIAiT42f)5jJPejedf)5zWH9mcu(yHQIFhhX5U4ZxJ6CwZ6KvwcKOgsxXALDa7GGDwzFEYykrcXqXlUvCe)EIpT4xjokocYjyOcCJGahCEXVDtCioGqwig6KZYe2F5xCtbbMyujqCiqIAiT4ZlUDXVsCuCeKZFrfDnFzrkAkdMsIh7a2XbNx8B3eNBIJIJGC4HKkP7iJEbhCEXVDt8NNmMsKqmu8IBfhXvU4ZxzZr0lOY(m4WEgbkFSq1AuN7AuNSYsGe1q6kwRS5i6fuzFMuVw(a2ZOkRM(bS5JEbvwwMuVw(a2ZiXJvCiHaPNr8jSbAXVEkNbO)fpbAXJvCc84qsClK4Jei(iHWlIV2iO4P4i4gJ4t41lEdIv8GHehqtmeNDvK4nI487)nQHov2bSdc2zLvtO4iihKgOlwOCgG()aj1SbV43XrCfe)2nXh7A0RfW5VOIUMVSifnLbZbsQzdEXVtCfUgIBxCnHIJGCqAGUyHYza6)dKuZg8IFN4JDn61c48xurxZxwKIMYG5aj1SbFnQZXvwNSYsGe1q6kwRSdyheSZklkocYHNGilmdsxSrn4pFKJzIBfhXvU42fFSanEhhEcISWmiDXg1G)atWmXTIJ4kCVkBoIEbvwmMDvrnPMQrDofuwDYkBoIEbv2Nj1RLpG9mQYsGe1q6kwRrDofuOozLLajQH0vSwzhWoiyNvwUjEKqmuC6VGU)lUDXhRk6w43ge)rti9OdXTIJ4kiUDXrXrqopZgLgucgQOt4SdoV42fNaeeZLt0Quj2c3vM4wjoMH(OMtSYMJOxqLDWqjF5z2Og1OYQjKe3e1jRZPqDYkBoIEbv2z9ywLLajQH0vSwJ6CyPozLLajQH0vSwzx(k7trLnhrVGkRTe2jQHQS2sdovzrXrqoVPhujb6IUh0bNx8B3e)5jJPejedf)5zWH9mcu(yHQIBfhXV2kRM(bS5JEbvwU2tAXJvCnfeuTbK4wyOGHGIp21OxlGxClzhIJSqXzbksC08jT4lq8iHyO4pvwBjSasvQY(aDzSaDh9cQrDU7vNSYsGe1q6kwRSlFL9POYMJOxqL1wc7e1qvwBPbNQSeccnI2gvgRk6w43geFLvt)a28rVGklxFmwCqioYcfNLzsXHuoIEbIhTkjo6fXBmGf2amIBwlk2uTwXtqRMdMeIH0IRMXGHEXBG4bdjUYok)fNhsdI0naJ4P48BqGOtJ4SmtkopChvwBjSasvQYsii0iABuzSQOBHFBq81Ooh3RtwzjqIAiDfRv2LVY(uuzZr0lOYAlHDIAOkRT0Gtv2XQIUf(TbXxzhWoiyNv2XAJajioZUa7eiUDXjeeAeTnQmwv0TWVniEXTs8XQIUf(TbXlUDXhRk6w43ge)rti9OdXTsCSiUDXJwLkXwEM4WDXVtCLDuU42fNBIFL4JvfDl8BdIxCoIJfXTlokocYHgmBdWuGepSvtGUCVdoV43Uj(yvr3c)2G4fNJ43tC7IJIJGCObZ2amfiXdB1eOlC)GZl(TBIpwv0TWVniEX5io3f3U4O4iihAWSnatbs8Wwnb6IYp48IpFL1wclGuLQSeccnI2gvgRk6w43geFnQZP86KvwcKOgsxXALD5RSpfv2Ce9cQS2syNOgQYAln4uLLh2lSJlf4gz0lqC7I)8KXuIeIHI)8m4WEgbkFSqvXTIJ4yPYQPFaB(OxqLDccyUi(GjbyiXHBKrVaXBeXTqIZK2iX5H9c74sbUrg9ce)Pq8eOfxf3enVHepsigkEXX5pvwBjSasvQYI)uHh2lSJlf4gz0lOg15U26KvwcKOgsxXALD5RSpfv2Ce9cQS2syNOgQYAln4uLflkx8PfpsdbIJTgZcpeirnKw8jG4yrzIpT4rAiqCuZpiyzrkptQxl)HajQH0Ipbehlkt8PfpsdbIZZK61sbzh4)HajQH0Ipbehlkx8PfpsdbItAYbSJlhcKOgsl(eqCSOmXNwCSOCXNaIFL4ppzmLiHyO4ppdoSNrGYhluvCR4io3fF(kRM(bS5JEbvwU2tAXJvCnH0asClmeq8yfh)jX)GstWi(uv0l(cfhfVnAc(vwBjSasvQY(bLMGPemq6zwJUg15SM1jRSeirnKUI1kRM(bS5JEbv2PYqJzIpvf9INH4in8JkBoIEbv2rAmLCe9ckM(JkRP)OasvQYo0FnQZDnQtwzjqIAiDfRvwn9dyZh9cQSxhoqCeCJ5I4VLogm0lESIhmK4SbLMGH0IFDBKrVaXVc9I46Tbye)xLeVdXrw4GEX5310amI3iId2GPbyeVFXtBzBsudn)PYMJOxqLfIdk5i6fum9hv2pG9iQZPqLDa7GGDwz)GstWq6tAmvwt)rbKQuL9dknbdPRrDoUY6KvwcKOgsxXALnhrVGk7B6bvsGUO7bvz10pGnF0lOYY155nxeN10ds8eOfxr9GepdXXY0IpvRvCnoSbyepyiXrA4hIRGYe)PXc0VsINibbfpyYqCUpT4t1AfVreVdXPjY3q6f3shmnq8GHehqtmexXzQks8fkE)Id2qCC(k7a2bb7SY(8KXuIeIHI)8m4WEgbkFSqvXVt8RvC7IJ0yyIcKuZg8IBL4xR42fhfhb58MEqLeOl6EqhiPMn4f)oXXm0h1CIIBx8XQIUf(TbXlUvCeN7IRyIFL4rRsIFN4kOmXNx8jG4yPg15uqz1jRSeirnKUI1kRM(bS5JEbvwRf2lSJlIFDBKrVaRHIZvPykV4yABK4P4dyYlEIU4H4eGGyUioYcfpyiX)GstWi(uv0l(vO4TrtqX)OngXH0ZtJq8oM)iUIR48kjEhIpsG4OK4btgI)TkVHov2Ce9cQSJ0yk5i6fum9hv2pG9iQZPqLDa7GGDwzTLWorn0b)PcpSxyhxkWnYOxqL10FuaPkvz)GstWug6Vg15uqH6KvwcKOgsxXALvt)a28rVGk7uxW3Acko(3amINIZguAcgXNQIe3cdbehs5GPbyepyiXjabXCr8GbspZA0v2Ce9cQSJ0yk5i6fum9hv2bSdc2zLLaeeZLJMq6rhIFhhXTLWorn05dknbtjyG0ZSgDL10FuaPkvz)GstWug6Vg15ual1jRSeirnKUI1k7a2bb7SYEL42syNOg6qii0iABuzSQOBHFBq8IBfhXh8f1CILNNaAXNx8B3e)kXhRk6w43ge)rti9OdXVJJ4ki(TBIJ0yyIcKuZg8IFhhXvqC7IBlHDIAOdHGqJOTrLXQIUf(TbXlUvCe)EIF7M4O4iiN)Ik6A(YIu0ugmLep2bSJdoV42f3wc7e1qhcbHgrBJkJvfDl8BdIxCR4io3fFEXVDt8Re)5jJPejedf)5zWH9mcu(yHQIBfhX5U42f3wc7e1qhcbHgrBJkJvfDl8BdIxCR4io3fF(kBoIEbv2rAmLCe9ckM(JkRP)OasvQYI0G(zQrDofUxDYklbsudPRyTYQPFaB(OxqLLR9K4P4O4TrtqXTWqaXHuoyAagXdgsCcqqmxepyG0ZSgDLnhrVGk7inMsoIEbft)rLDa7GGDwzjabXC5OjKE0H43XrCBjStudD(GstWucgi9mRrxzn9hfqQsvwu82ORrDof4EDYklbsudPRyTYMJOxqLnHJeqLyHqcevwn9dyZh9cQSC11c9H48WEHDCr8giEAmIViIhmK4CDRLRkokns8NeVdXhj(tV4P4kotvrv2bSdc2zLLaeeZLJMq6rhIBfhXvq5IpT4eGGyUCGegcuJ6CkO86Kv2Ce9cQSjCKaQWJBEQYsGe1q6kwRrDofU26Kv2Ce9cQSMgdt8fUc4AmQeiQSeirnKUI1AuNtbRzDYkBoIEbvw0etzrkbShZ(klbsudPRyTg1OYYdPXQIMrDY6CkuNSYMJOxqLn55nxk8B)lOYsGe1q6kwRrDoSuNSYMJOxqLfDJWq6cIjVqAlnatj2j2GklbsudPRyTg15UxDYklbsudPRyTYoGDqWoRS)IBqBG(WJ)bUHkeeNp6fCiqIAiT43Uj(V4g0gOp2wtgTHk)ASrG4qGe1q6kBoIEbvwed9mdyIe1Ooh3RtwzZr0lOY(bLMGPYsGe1q6kwRrDoLxNSYsGe1q6kwRS5i6fuzvt4msxqwyrtzWuz5H0yvrZO80yb6VYQGYRrDURTozLLajQH0vSwzZr0lOY(MEqLeOl6Eqv2bSdc2zLfsiq6zsudvz5H0yvrZO80yb6VYQqnQZznRtwzjqIAiDfRv2bSdc2zLfIdiKfIHoQjCwzrkbdvuZpiyj)p)VbhcKOgsxzZr0lOY(mPETuqnPM(AuJklkEB01jRZPqDYklbsudPRyTYoGDqWoRSCt8ineioGgdt8rAMrWdbsudPf3U4qCaHSqm0jAWLsStShfutQPdbsudPf3U4ppzmLiHyO4ppdoSNrGYhluv87ex5v2Ce9cQSptBRg15WsDYklbsudPRyTYoGDqWoRSppzmLiHyO4f3koIJfXTl(vIZnXhRncKG4aObCnlul(TBIp21OxlGZtqygKUGUaQ889m6OMtSmysig6fxXeFWKqm0xqG5i6fKgXTIJ4k7GfLl(TBI)8KXuIeIHI)8m4WEgbkFSqvXTsCUl(8IBxCuCeKdpbrwygKUyJAWF(ihZe)ooIZ9kBoIEbv2Nbh2Ziq5JfQwJ6C3RozLLajQH0vSwzhWoiyNv2XUg9AbCEccZG0f0fqLNVNrh1CILbtcXqV4kM4dMeIH(ccmhrVG0i(DCexzhSOCXVDt8FXnOnqFmuQlOxk0etvEdDiqIAiT42fNBIJIJGCmuQlOxk0etvEdDW5f)2nX)f3G2a9zgzRbFzxfxitdWCiqIAiT42fNBIRjuCeKZmYwd(IfygmhC(kBoIEbv2NGWmiDbDbu557zunQZX96Kv2Ce9cQSym7QIAsnvzjqIAiDfR1OoNYRtwzZr0lOYIMJzFKOvwcKOgsxXAnQrLDO)6K15uOozLLajQH0vSwzhWoiyNvwUjokocY5zs9APOtWGo48IBxCuCeKZZGd7zeOeleK69GZlUDXrXrqopdoSNrGsSqqQ3dKuZg8IFhhXV3r5vw8NklcsbZqxNtHkBoIEbv2Nj1RLIobdQYQPFaB(OxqLLR9K4kkbds8fbrXWm0IJsilKepyiXrA4hI)m4WEgbkFSqvXrGRQ4tUqqQxXhRk9I3GtnQZHL6KvwcKOgsxXALDa7GGDwzrXrqopdoSNrGsSqqQ3doV42fhfhb58m4WEgbkXcbPEpqsnBWl(DCe)EhLxzXFQSiifmdDDofQS5i6fuz)lQOR5llsrtzWuz10pGnF0lOYEfxdyO)fpnqk1xehNxCuAK4pjUfs8y3zIZYK61I4t4oW)5fh)jXzVOIUMx8fbrXWm0IJsilKepyiXrA4hIZYGd7zeqC2yHQIJaxvXNCHGuVIpwv6fVbNAuN7E1jRSeirnKUI1k7a2bb7SYAlHDIAOZd0LXc0D0lqC7IZnX)GstWq6JAccdjUDXrXrqo)fv018LfPOPmyo48IBx8XQIUf(TbXlUvCex5v2Ce9cQSiMedzmz0lOg154EDYklbsudPRyTYoGDqWoRSxjoehqiledDut4SYIucgQOMFqWs(F(FdoeirnKwC7Ipwv0TWVni(JMq6rhIFhhXvqCft8ineioAI4jy5dygegs9qGe1qAXVDtCioGqwig6OPmymxkptQxl)HajQH0IBx8XQIUf(TbXl(DIRG4ZlUDXrXrqo)fv018LfPOPmyo48IBxCuCeKZZK61srNGbDW5f3U4Q5heSK)N)3GcKuZg8IZrCLjUDXrXrqoAkdgZLYZK61YF0RfqLnhrVGkRTe0ptnQZP86KvwcKOgsxXALvt)a28rVGkR1URrCKfk(KleK6vCEiPySRIe3shmIZYOiXHuQViUfgcioydXH4aqdWio7eEQSilSaOjg15uOYoGDqWoRSrAiqCEgCypJaLyHGuVhcKOgslUDX5M4rAiqCEMuVwki7a)peirnKUYMJOxqLLFxtbs)IdhunQZDT1jRSeirnKUI1kBoIEbv2Nbh2Ziqjwii1BLvt)a28rVGklx7jXNCHGuVIZdjXzxfjUfgciUfsCM0gjEWqItacI5I4wyOGHGIJaxvX5310amIBPdMfpeNDcfFHIZva)dXXqacMgZLtLDa7GGDwzjabXCrCR4i(1QmXTlUTe2jQHopqxglq3rVaXTl(yxJETao)fv018LfPOPmyo48IBx8XUg9AbCEMuVwk6emOZGjHyOxCR4iUcIBx8ReNBIdXbeYcXqNfL0nbg0HajQH0IF7M4Acfhb5GysmKXKrVGdoV43Uj(Ztgtjsigk(ZZGd7zeO8Xcvf3koIFL4ki(0IZDXNaIFL4Ct8ineioGgdt8rAMrWdbsudPf3U4Ct8ineio6eoR8mPETCiqIAiT4Zl(8IpV42fFSQOBHFBq8IFhhXXI42f)kX5M4O4iihEiPs6oYOxWbNx8B3e)5jJPejedf)5zWH9mcu(yHQIBL4Cx85f3U4xjo3eFS2iqcIJncemxGIF7M4Ct8XUg9AbCqmjgYyYOxWbNx85RrDoRzDYklbsudPRyTYMJOxqL9jimdsxqxavE(EgvzhWoiyNvwBjStudDEGUmwGUJEbIBxCUjUEJZtqygKUGUaQ889mQO34e9ywdWiUDXJeIHIt0Quj2IUjXTIJ4yrbXTl(vIpwv0TWVni(JMq6rhIBfhXVs8bFbt2aXTYAO4Cx85fFEXTlo3ehfhb58m4WEgbkXcbPEp48IBx8ReNBIJIJGC4HKkP7iJEbhCEXVDt8NNmMsKqmu8NNbh2Ziq5JfQkUvIZDXNx8B3ehPXWefiPMn4f)ooIRCXTl(Ztgtjsigk(ZZGd7zeO8Xcvf)oXVxLDCzyOsKqmu815uOg15Ug1jRSeirnKUI1k7a2bb7SYAlHDIAOZd0LXc0D0lqC7Ipwv0TWVni(JMq6rhIBfhXvOYMJOxqL9j(V)AuNJRSozLLajQH0vSwzZr0lOY(xurxZxwKIMYGPYQPFaB(OxqLLR9K4SxurxZl(ceFSRrVwaIFvIeeuCKg(H4SafnV44ad9V4wiXtijoMTbyepwX5xEXNCHGuVINaT46vCWgIZK2iXzzs9Ar8jCh4)PYoGDqWoRS2syNOg68aDzSaDh9ce3U4xjEKgcehcyJmlFdWuEMuVw(dbsudPf)2nXh7A0RfW5zs9APOtWGodMeIHEXTIJ4ki(8IBx8ReNBIhPHaX5zWH9mcuIfcs9EiqIAiT43UjEKgceNNj1RLcYoW)dbsudPf)2nXh7A0RfW5zWH9mcuIfcs9EGKA2GxCRehlIpV42f)kX5M4J1gbsqCSrGG5cu8B3eFSRrVwahetIHmMm6fCGKA2GxCRexbLj(TBIp21OxlGdIjXqgtg9co48IBx8XQIUf(TbXlUvCex5IpFnQZPGYQtwzjqIAiDfRv2Ce9cQSQjCgPlilSOPmyQSMgqLHUYQWr5v2XLHHkrcXqXxNtHk7a2bb7SYcZwxiBeioPw)hCEXTl(vIhjedfNOvPsSfDtIFN4JvfDl8BdI)OjKE0H43Ujo3e)dknbdPpPXiUDXhRk6w43ge)rti9OdXTIJ4d(IAoXYZtaT4Zxz10pGnF0lOYEnrep16x8esIJZRK4pO5jXdgs8fqIBPdgXnRf6dXNCsfDeNR9K4wyiG46lnaJ4i5heu8GjbIpvRvCnH0JoeFHId2q8pO0emKwClDWS4H4j4I4t1Ap1OoNckuNSYsGe1q6kwRS5i6fuzvt4msxqwyrtzWuz10pGnF0lOYEnrehSINA9lUL2yex3K4w6GPbIhmK4aAIH43tzVsIJ)K4kEefj(cehD)xClDWS4H4j4I4t1Apv2bSdc2zLfMTUq2iqCsT(pnqCRe)EktCftCy26czJaXj16)OXHz0lqC7Ipwv0TWVni(JMq6rhIBfhXh8f1CILNNa6AuNtbSuNSYsGe1q6kwRSdyheSZkRTe2jQHopqxglq3rVaXTl(yvr3c)2G4pAcPhDiUvCehlIBx8Rehfhb58xurxZxwKIMYG5GZl(TBIJU)lUDXrAmmrbsQzdEXVJJ4yrzIpFLnhrVGk7ZK61sb1KA6RrDofUxDYklbsudPRyTYoGDqWoRS2syNOg68aDzSaDh9ce3U4JvfDl8BdI)OjKE0H4wXrCSiUDXVsCBjStudDWFQWd7f2XLcCJm6fi(TBI)8KXuIeIHI)8m4WEgbkFSqvXVJJ4Cx8B3ehIdiKfIHoq6xCGUbykdtc74YHajQH0IpFLnhrVGklny2gGPajEyRMaDnQZPa3RtwzjqIAiDfRv2Ce9cQSpdoSNrGsSqqQ3kRM(bS5JEbv2RVdgXzNqLeVrehSH4PbsP(I46fqkjo(tIp5cbPEf3shmIZUksCC(tLDa7GGDwzJ0qG48mPETuq2b(FiqIAiT42f3wc7e1qNhOlJfO7OxG42fhfhb58xurxZxwKIMYG5GZlUDXhRk6w43geV43XrCSiUDXVsCUjokocYHhsQKUJm6fCW5f)2nXFEYykrcXqXFEgCypJaLpwOQ4wjo3fF(AuNtbLxNSYsGe1q6kwRSdyheSZkl3ehfhb58mPETu0jyqhCEXTlosJHjkqsnBWl(DCe)Ai(0IhPHaX5XrdcIGJHoeirnKUYMJOxqL9zs9APOtWGQrDofU26KvwcKOgsxXALDa7GGDwzVs8FXnOnqF4X)a3qfcIZh9coeirnKw8B3e)xCdAd0hBRjJ2qLFn2iqCiqIAiT4ZlUDXjabXC5OjKE0H4wXr87PmXTlo3e)dknbdPpPXiUDXrXrqo)fv018LfPOPmyo61cOY2GGGqC(O0iv2FXnOnqFSTMmAdv(1yJarLTbbbH48rPvvjDNbvzvOYMJOxqLfXqpZaMirLTbbbH48rbJzrttLvHAuNtbRzDYklbsudPRyTYoGDqWoRSO4iihuZUAd(hhiLJq8B3ehPXWefiPMn4f)oXVNYe)2nXrXrqo)fv018LfPOPmyo48IBx8Rehfhb58mPETuqnPM(doV43Uj(yxJETaoptQxlfutQP)aj1SbV43XrCfuM4ZxzZr0lOYYVrVGAuNtHRrDYklbsudPRyTYoGDqWoRSO4iiN)Ik6A(YIu0ugmhC(kBoIEbvwuZU6cco8snQZPaxzDYklbsudPRyTYoGDqWoRSO4iiN)Ik6A(YIu0ugmhC(kBoIEbvwuc(eCwdWuJ6Cyrz1jRSeirnKUI1k7a2bb7SYIIJGC(lQOR5llsrtzWCW5RS5i6fuzrAiHA2vxJ6CyrH6KvwcKOgsxXALDa7GGDwzrXrqo)fv018LfPOPmyo48v2Ce9cQSjyqFattzKgtnQZHfSuNSYsGe1q6kwRS5i6fuzXFQ0bP(vwn9dyZh9cQSkIqsCtiosAmO5yM4iluC8prnK4DqQ)9lox7jXT0bJ4SxurxZl(IiUIOmyov2bSdc2zLffhb58xurxZxwKIMYG5GZl(TBIJ0yyIcKuZg8IFN4yrz1Ogv2pO0emLH(RtwNtH6KvwcKOgsxXALD5RSpfv2Ce9cQS2syNOgQYAln4uLDSRrVwaNNj1RLIobd6mysig6liWCe9csJ4wXrCfowtLxz10pGnF0lOYQ4Mm8euCRXe2jQHQS2sybKQuL9z0LGbspZA01OohwQtwzjqIAiDfRv2Ce9cQS2sq)mvwn9dyZh9cQSwJjOFgXBeXTqINqs8rYZ3amIVaXvucgK4dMeIH(J4CftO5I4OeYcjXrA4hIRtWGeVre3cjotAJehSIpxJHj(inZiO4O4H4kkHZeNLj1RfXBG4lutqXJvCmui(1HZh4qsCCEXVcSIR4ZpiO4C9)Z)BW8Nk7a2bb7SYEL4CtCBjStudDEgDjyG0ZSgT43Ujo3epsdbIdOXWeFKMze8qGe1qAXTlEKgcehDcNvEMuVwoeirnKw85f3U4JvfDl8BdI)OjKE0H4wjUcIBxCUjoehqiledDut4SYIucgQOMFqWs(F(FdoeirnKUg15UxDYklbsudPRyTYQPFaB(OxqL1A31ioYcfNLj1RfvYOfFAXzzs9A5dypJehhyO)f3cjEcjXt0fpepwXhjV4lqCfLGbj(GjHyO)i(eeWCrClmeq8jSbAXVEkNbO)fVFXt0fpepwXH4aXx84uzrwybqtmQZPqLDa7GGDwzH5GoGgdtuidsLLMyaZsQU4GOYYDLvzZr0lOYYVRPaPFXHdQg154EDYklbsudPRyTYoGDqWoRSeGGyUiUvCeN7ktC7ItacI5Yrti9OdXTIJ4kOmXTlo3e3wc7e1qNNrxcgi9mRrlUDXhRk6w43ge)rti9OdXTsCfe3U4Acfhb5G0aDXcLZa0)hiPMn4f)oXvOYMJOxqL9zs9ArLm6AuNt51jRSeirnKUI1k7YxzFkQS5i6fuzTLWornuL1wAWPk7yvr3c)2G4pAcPhDiUvCehlIpT4O4iiNNj1RLcQj10FW5RSA6hWMp6fuzNQ1kEWaPNzn6xCKfkobcc2amIZYK61I4kkbdQYAlHfqQsv2NrxgRk6w43geFnQZDT1jRSeirnKUI1k7YxzFkQS5i6fuzTLWornuL1wAWPk7yvr3c)2G4pAcPhDiUvCe)Ev2bSdc2zLDS2iqcIZSlWobvwBjSasvQY(m6Yyvr3c)2G4RrDoRzDYklbsudPRyTYU8v2NIkBoIEbvwBjStudvzTLgCQYowv0TWVni(JMq6rhIFhhXvOYoGDqWoRS2syNOg6G)uHh2lSJlf4gz0lqC7I)8KXuIeIHI)8m4WEgbkFSqvXTIJ4CVYAlHfqQsv2NrxgRk6w43geFnQZDnQtwzjqIAiDfRv2Ce9cQSptQxlfDcguLvt)a28rVGkRIsWGexJdBagXzVOIUMx8fkEIU2iXdgi9mRrFQSdyheSZkRTe2jQHopJUmwv0TWVniEXTl(vIBlHDIAOZZOlbdKEM1Of)2nXrXrqo)fv018LfPOPmyoqsnBWlUvCexHdwe)2nXrXrqodMC)cAcOdoV43Uj(Ztgtjsigk(ZZGd7zeO8Xcvf3koIZDXTl(yxJETao)fv018LfPOPmyoqsnBWlUvIRGYeFEXTl(vIJIJGC4jiYcZG0fBud(Zh5yM43jo3f)2nXFEYykrcXqXFEgCypJaLpwOQ4wjoweF(AuNJRSozLLajQH0vSwzZr0lOY(mPETu0jyqvwn9dyZh9cQSyfhcehsQzdAagXvucg0lokHSqs8GHehPXWeIta9lEJio7QiXTSGPeIJsIdPuFr8giE0Q0PYoGDqWoRS2syNOg68m6Yyvr3c)2G4f3U4ingMOaj1SbV43j(yxJETao)fv018LfPOPmyoqsnBWxJAuzrAq)m1jRZPqDYklbsudPRyTYU8v2NIkBoIEbvwBjStudvzTLgCQYgPHaXHhsQKUJm6fCiqIAiT42f)5jJPejedf)5zWH9mcu(yHQIFN4xjUYfxXeFS2iqcIdGgW1SqT4ZlUDX5M4J1gbsqCMDb2jOYQPFaB(OxqL96zAdjo(3amIBTqsL0DKrVaLepTTTw8r(rdWioRPhK4jqlUI6bjUfgcioltQxlIROemiX7x8FxG4Xkokjo(tALeNM4G4dXrwO4wdUa7euzTLWcivPklpKujD5b6Yyb6o6fuJ6CyPozLLajQH0vSwzhWoiyNvwUjUTe2jQHo8qsL0LhOlJfO7OxG42f)5jJPejedf)5zWH9mcu(yHQIFN4xR42fNBIJIJGCEMuVwk6emOdoV42fhfhb58MEqLeOl6EqhiPMn4f)oXrAmmrbsQzdEXTloKqG0ZKOgQYMJOxqL9n9Gkjqx09GQrDU7vNSYsGe1q6kwRSdyheSZkRTe2jQHo8qsL0LhOlJfO7OxG42fFSRrVwaNNj1RLIobd6mysig6liWCe9csJ43jUchRPYf3U4O4iiN30dQKaDr3d6aj1SbV43j(yxJETao)fv018LfPOPmyoqsnBWlUDXVs8XUg9AbCEMuVwk6emOdKs9fXTlokocY5VOIUMVSifnLbZbsQzdEXvmXrXrqoptQxlfDcg0bsQzdEXVtCfoyr85RS5i6fuzFtpOsc0fDpOAuNJ71jRSeirnKUI1k7YxzFkQS5i6fuzTLWornuL1wAWPkRA(bbl5)5)nOaj1SbV4wjUYe)2nX5M4rAiqCangM4J0mJGhcKOgslUDXJ0qG4Ot4SYZK61YHajQH0IBxCuCeKZZK61srNGbDW5f)2nXFEYykrcXqXFEgCypJaLpwOQ4wXrCUxz10pGnF0lOYQ4Mm8euCRXe2jQHehzHIFD48boKoIZoR5fxJdBagXv85heuCU()5)nq8fkUgh2amIROemiXT0bJ4kkHZepbAXbR4Z1yyIpsZmcEQS2sybKQuL9N18fioFGdPAuNt51jRSeirnKUI1kBoIEbvwioFGdPkRM(bS5JEbvwRbeXlooV4xhoFGdjXBeX7q8(fprx8q8yfhIdeFXJtLDa7GGDwzVsCUjUTe2jQHo)SMVaX5dCij(TBIBlHDIAOd(tfEyVWoUuGBKrVaXNxC7IhjedfNOvPsSfDtIRyIdj1SbV4wj(1kUDXHecKEMe1q1Oo31wNSYMJOxqL9PbKIsqdgqpbJtvwcKOgsxXAnQZznRtwzjqIAiDfRv2Ce9cQSqC(ahsv2XLHHkrcXqXxNtHk7a2bb7SYYnXTLWorn05N18fioFGdjXTlo3e3wc7e1qh8Nk8WEHDCPa3iJEbIBx8NNmMsKqmu8NNbh2Ziq5JfQkUvCehlIBx8iHyO4eTkvITOBsCR4i(vIRCXNw8RehlIpbeFSQOBHFBq8IpV4ZlUDXHecKEMe1qvwn9dyZh9cQSkECt06nIgGr8iHyO4fpyYqClTXiUPTrIJSqXdgsCnomJEbIViIFD48boKusCiHaPNrCnoSbyeNpbAsThNAuN7AuNSYsGe1q6kwRS5i6fuzH48boKQSA6hWMp6fuzVocbspJ4xhoFGdjXPeAUiEJiEhIBPngXPjY3qsCnoSbyeN9Ik6A(J4kAfpyYqCiHaPNr8grC2vrIJHIxCiL6lI3aXdgsCanXqCL)Nk7a2bb7SYYnXTLWorn05N18fioFGdjXTloKuZg8IFN4JDn61c48xurxZxwKIMYG5aj1SbV4tlUcktC7Ip21OxlGZFrfDnFzrkAkdMdKuZg8IFhhXvU42fpsigkorRsLyl6MexXehsQzdEXTs8XUg9AbC(lQOR5llsrtzWCGKA2Gx8Pfx51OohxzDYklbsudPRyTYoGDqWoRSCtCBjStudDWFQWd7f2XLcCJm6fiUDXFEYykrcXqXlUvCe)Ev2Ce9cQSOMCmRWVw0eSg15uqz1jRS5i6fuzjB9piyguLLajQH0vSwJAuJkRnc(9cQZHfLHffualkZAwzTKqqdW8v2RNRFDZDnNtX5(fx8jziXBv(fgIJSqXNYhuAcgspfXH0emEdjT4)QsIN4XQMbPfFWKam0FeS5QnGeN73V4tDb2iyqAXNcehqiledDUVPiESIpfioGqwig6CFhcKOgspfXVsHjo)rWMR2asCR59l(uxGncgKw8PaXbeYcXqN7BkIhR4tbIdiKfIHo33HajQH0tr8RuyIZFeSfSVEU(1n31CofN7xCXNKHeVv5xyioYcfFk8qASQOzmfXH0emEdjT4)QsIN4XQMbPfFWKam0FeS5QnGe)E3V4tDb2iyqAXNYV4g0gOp33uepwXNYV4g0gOp33HajQH0tr8RuyIZFeS5QnGe)E3V4tDb2iyqAXNYV4g0gOp33uepwXNYV4g0gOp33HajQH0tr8meNR4eexv8RuyIZFeS5QnGe3AE)Ip1fyJGbPfFkqCaHSqm05(MI4Xk(uG4aczHyOZ9DiqIAi9uepdX5kobXvf)kfM48hbBb7RNRFDZDnNtX5(fx8jziXBv(fgIJSqXNYq)trCinbJ3qsl(VQK4jESQzqAXhmjad9hbBUAdiX5(9l(uxGncgKw8PaXbeYcXqN7BkIhR4tbIdiKfIHo33HajQH0tr8RWYeN)iyZvBaj(1E)Ip1fyJGbPfFkqCaHSqm05(MI4Xk(uG4aczHyOZ9DiqIAi9ue)kfM48hbBUAdiXv4E3V4tDb2iyqAXNcehqiledDUVPiESIpfioGqwig6CFhcKOgspfXVsHjo)rWMR2asCfU27x8PUaBemiT4t5xCdAd0N7BkIhR4t5xCdAd0N77qGe1q6Pi(vyzIZFeSfSVEU(1n31CofN7xCXNKHeVv5xyioYcfFkFqPjykd9pfXH0emEdjT4)QsIN4XQMbPfFWKam0FeS5QnGehl3V4tDb2iyqAXNcehqiledDUVPiESIpfioGqwig6CFhcKOgspfXZqCUItqCvXVsHjo)rWwW(656x3CxZ5uCUFXfFsgs8wLFHH4ilu8PGI3g9uehstW4nK0I)RkjEIhRAgKw8btcWq)rWMR2asCfUFXN6cSrWG0IpfioGqwig6CFtr8yfFkqCaHSqm05(oeirnKEkIFLctC(JGTG91uLFHbPf3AkEoIEbIB6p(JGDL95PrDoSCTkuz5HlsBOkR1TU4S4OHHIlIFDlgCsW26wxCfrdsfLGIFnusCSOmSOGGTGT1TU4tLjbyO)(fSTU1fxXexXV2iXTLWorn0b)PcpSxyhxkWnYOxG448I)R4DiE)I)uiokHSqsClK44pjEhhbBRBDXvmXN6QI2asCvCt08gs8rAmLCe9ckM(dXjqaB6fpwXHKgFqIZVbbIonIdjllC2rW26wxCftCfFoJeFcn0ZmGjsiEdcccX5dXBG4JvfndXBeXTqIZva)dX1Tw8oehzHIBBnz0gQ8RXgbIJGTGT1TU4wlKuSPUQOziyNJOxWF4H0yvrZyAoCj55nxk8B)lqWohrVG)WdPXQIMX0C4c6gHH0fetEH0wAaMsStSbc25i6f8hEinwv0mMMdxqm0ZmGjsOuJW5xCdAd0hE8pWnuHG48rVGB3(f3G2a9X2AYOnu5xJncec25i6f8hEinwv0mMMdx(GstWiyNJOxWF4H0yvrZyAoCrnHZiDbzHfnLbJs8qASQOzuEASa9ZrbLlyNJOxWF4H0yvrZyAoC5n9Gkjqx09GuIhsJvfnJYtJfOFokOuJWbsiq6zsudjyNJOxWF4H0yvrZyAoC5zs9APGAsn9k1iCG4aczHyOJAcNvwKsWqf18dcwY)Z)BGGTGT1TU4k(SbIFDBKrVab7Ce9cEoZ6XmbBRlox7jT4XkUMccQ2asClmuWqqXh7A0RfWlULSdXrwO4SafjoA(Kw8fiEKqmu8hb7Ce9c(P5WfBjStudPeivjopqxglq3rVaLSLgCIdkocY5n9Gkjqx09Go483U98KXuIeIHI)8m4WEgbkFSqvR4CTc2wxCU(yS4GqCKfkolZKIdPCe9cepAvsC0lI3yalSbye3SwuSPATINGwnhmjedPfxnJbd9I3aXdgsCLDu(lopKgePBagXtX53GarNgXzzMuCE4oeSZr0l4NMdxSLWornKsGuL4qii0iABuzSQOBHFBq8kzln4ehcbHgrBJkJvfDl8BdIxWohrVGFAoCXwc7e1qkbsvIdHGqJOTrLXQIUf(TbXRuJWzS2iqcIZSlWob2jeeAeTnQmwv0TWVniERgRk6w43geV9XQIUf(TbXF0esp6WkSypAvQeB5zId3VtzhLBNBxnwv0TWVniEoyXokocYHgmBdWuGepSvtGUCVdo)TBJvfDl8BdINZ9SJIJGCObZ2amfiXdB1eOlC)GZF72yvr3c)2G45WD7O4iihAWSnatbs8Wwnb6IYp48ZRKT0GtCgRk6w43geVGT1fFccyUi(GjbyiXHBKrVaXBeXTqIZK2iX5H9c74sbUrg9ce)Pq8eOfxf3enVHepsigkEXX5pc25i6f8tZHl2syNOgsjqQsCWFQWd7f2XLcCJm6fOKT0GtC4H9c74sbUrg9cS)8KXuIeIHI)8m4WEgbkFSqvR4GfbBRlox7jT4XkUMqAajUfgciESIJ)K4FqPjyeFQk6fFHIJI3gnbFb7Ce9c(P5WfBjStudPeivjoFqPjykbdKEM1OvYwAWjoyr5thPHaXXwJzHhcKOgspbWIYMosdbIJA(bblls5zs9A5peirnKEcGfLnDKgceNNj1RLcYoW)dbsudPNayr5thPHaXjn5a2XLdbsudPNayrztJfLpbU65jJPejedf)5zWH9mcu(yHQwXH7ZlyBDXNkdnMj(uv0lEgIJ0WpeSZr0l4NMdxgPXuYr0lOy6pucKQeNH(fSTU4xhoqCeCJ5I4VLogm0lESIhmK4SbLMGH0IFDBKrVaXVc9I46Tbye)xLeVdXrw4GEX5310amI3iId2GPbyeVFXtBzBsudn)rWohrVGFAoCbIdk5i6fum9hkbsvIZhuAcgsR0hWEeCuqPgHZhuAcgsFsJrW26IZ155nxeN10ds8eOfxr9GepdXXY0IpvRvCnoSbyepyiXrA4hIRGYe)PXc0VsINibbfpyYqCUpT4t1AfVreVdXPjY3q6f3shmnq8GHehqtmexXzQks8fkE)Id2qCCEb7Ce9c(P5WL30dQKaDr3dsPgHZZtgtjsigk(ZZGd7zeO8XcvV7ATJ0yyIcKuZg8wDT2rXrqoVPhujb6IUh0bsQzd(7Wm0h1CI2hRk6w43geVvC4UIDv0Q0DkOS5NayrW26IBTWEHDCr8RBJm6fynuCUkft5fhtBJepfFatEXt0fpeNaeeZfXrwO4bdj(huAcgXNQIEXVcfVnAck(hTXioKEEAeI3X8hXvCfNxjX7q8rcehLepyYq8Vv5n0rWohrVGFAoCzKgtjhrVGIP)qjqQsC(GstWug6xPpG9i4OGsnchBjStudDWFQWd7f2XLcCJm6fiyBDXN6c(wtqXX)gGr8uC2GstWi(uvK4wyiG4qkhmnaJ4bdjobiiMlIhmq6zwJwWohrVGFAoCzKgtjhrVGIP)qjqQsC(GstWug6xPgHdbiiMlhnH0JoUJJTe2jQHoFqPjykbdKEM1OfSZr0l4NMdxgPXuYr0lOy6pucKQehKg0pJsncNRSLWorn0HqqOr02OYyvr3c)2G4TIZGVOMtS88eqp)TBxnwv0TWVni(JMq6rh3XrHB3qAmmrbsQzd(74OGDBjStudDieeAeTnQmwv0TWVniER4CVB3qXrqo)fv018LfPOPmykjESdyhhCE72syNOg6qii0iABuzSQOBHFBq8wXH7ZF72vppzmLiHyO4ppdoSNrGYhlu1koC3UTe2jQHoeccnI2gvgRk6w43geVvC4(8c2wxCU2tINIJI3gnbf3cdbehs5GPbyepyiXjabXCr8GbspZA0c25i6f8tZHlJ0yk5i6fum9hkbsvIdkEB0k1iCiabXC5OjKE0XDCSLWorn05dknbtjyG0ZSgTGT1fNRUwOpeNh2lSJlI3aXtJr8fr8GHeNRBTCvXrPrI)K4Di(iXF6fpfxXzQksWohrVGFAoCjHJeqLyHqcek1iCiabXC5OjKE0HvCuq5ttacI5YbsyiGGDoIEb)0C4schjGk84MNeSZr0l4NMdxmngM4lCfW1yujqiyNJOxWpnhUGMyklsjG9y2lylyBDRlowXBJMGVGDoIEb)bfVnAoptBtPgHd3I0qG4aAmmXhPzgbpeirnK2oehqiledDIgCPe7e7rb1KAY(Ztgtjsigk(ZZGd7zeO8XcvVt5c25i6f8hu82ONMdxEgCypJaLpwOQsncNNNmMsKqmu8wXbl2VIBJ1gbsqCa0aUMfQVDBSRrVwaNNGWmiDbDbu557z0rnNyzWKqm0RydMeIH(ccmhrVG0yfhLDWIYVD75jJPejedf)5zWH9mcu(yHQwX95TJIJGC4jiYcZG0fBud(Zh5y2DC4UGDoIEb)bfVn6P5WLNGWmiDbDbu557zKsncNXUg9AbCEccZG0f0fqLNVNrh1CILbtcXqVInysig6liWCe9csZDCu2blk)2TFXnOnqFmuQlOxk0etvEdDiqIAiTDUHIJGCmuQlOxk0etvEdDW5VD7xCdAd0NzKTg8LDvCHmnaZHajQH025MMqXrqoZiBn4lwGzWCW5fSZr0l4pO4TrpnhUGXSRkQj1KGDoIEb)bfVn6P5Wf0Cm7JevWwW26wx8PURrVwaVGT1fNR9K4kkbds8fbrXWm0IJsilKepyiXrA4hI)m4WEgbkFSqvXrGRQ4tUqqQxXhRk9I3GJGDoIEb)zOFoptQxlfDcgKs4pvweKcMHMJck1iC4gkocY5zs9APOtWGo482rXrqopdoSNrGsSqqQ3doVDuCeKZZGd7zeOeleK69aj1Sb)DCU3r5c2wx8R4Aad9V4PbsP(I448IJsJe)jXTqIh7otCwMuVweFc3b(pV44pjo7fv018IViikgMHwCuczHK4bdjosd)qCwgCypJaIZgluvCe4Qk(KleK6v8XQsV4n4iyNJOxWFg6FAoC5VOIUMVSifnLbJs4pvweKcMHMJck1iCqXrqopdoSNrGsSqqQ3doVDuCeKZZGd7zeOeleK69aj1Sb)DCU3r5c25i6f8NH(NMdxqmjgYyYOxGsnchBjStudDEGUmwGUJEb252huAcgsFutqyi7O4iiN)Ik6A(YIu0ugmhCE7JvfDl8BdI3kokxWohrVG)m0)0C4ITe0pJsncNRG4aczHyOJAcNvwKsWqf18dcwY)Z)BG9XQIUf(TbXF0esp64ookOyrAiqC0eXtWYhWmimK6HajQH03UbXbeYcXqhnLbJ5s5zs9A5Tpwv0TWVni(7uyE7O4iiN)Ik6A(YIu0ugmhCE7O4iiNNj1RLIobd6GZBxn)GGL8)8)guGKA2GNJYSJIJGC0ugmMlLNj1RL)OxlabBRlU1URrCKfk(KleK6vCEiPySRIe3shmIZYOiXHuQViUfgcioydXH4aqdWio7eEeSZr0l4pd9pnhUWVRPaPFXHdsjKfwa0edokOuJWjsdbIZZGd7zeOeleK69qGe1qA7ClsdbIZZK61sbzh4)HajQH0c2wxCU2tIp5cbPEfNhsIZUksClmeqClK4mPns8GHeNaeeZfXTWqbdbfhbUQIZVRPbye3shmlEio7ek(cfNRa(hIJHaemnMlhb7Ce9c(Zq)tZHlpdoSNrGsSqqQxLAeoeGGyUyfNRvz2TLWorn05b6Yyb6o6fyFSRrVwaN)Ik6A(YIu0ugmhCE7JDn61c48mPETu0jyqNbtcXqVvCuW(vCdIdiKfIHolkPBcmOB30ekocYbXKyiJjJEbhC(B3EEYykrcXqXFEgCypJaLpwOQvCUsHP5(e4kUfPHaXb0yyIpsZmcEiqIAiTDUfPHaXrNWzLNj1RLdbsudPNF(5Tpwv0TWVni(74Gf7xXnuCeKdpKujDhz0l4GZF72Ztgtjsigk(ZZGd7zeO8XcvTI7ZB)kUnwBeibXXgbcMlWB342yxJETaoiMedzmz0l4GZpVGDoIEb)zO)P5WLNGWmiDbDbu557zKsJlddvIeIHINJck1iCSLWorn05b6Yyb6o6fyNB6nopbHzq6c6cOYZ3ZOIEJt0JznaJ9iHyO4eTkvITOBYkoyrb7xnwv0TWVni(JMq6rhwX5QbFbt2aRSgY95N3o3qXrqopdoSNrGsSqqQ3doV9R4gkocYHhsQKUJm6fCW5VD75jJPejedf)5zWH9mcu(yHQwX95VDdPXWefiPMn4VJJYT)8KXuIeIHI)8m4WEgbkFSq17UNGDoIEb)zO)P5WLN4)(vQr4ylHDIAOZd0LXc0D0lW(yvr3c)2G4pAcPhDyfhfeSTU4CTNeN9Ik6AEXxG4JDn61cq8RsKGGIJ0WpeNfOO5fhhyO)f3cjEcjXXSnaJ4Xko)Yl(KleK6v8eOfxVId2qCM0gjoltQxlIpH7a)pc25i6f8NH(NMdx(lQOR5llsrtzWOuJWXwc7e1qNhOlJfO7OxG9RI0qG4qaBKz5BaMYZK61YFiqIAi9TBJDn61c48mPETu0jyqNbtcXqVvCuyE7xXTineiopdoSNrGsSqqQ3dbsudPVDlsdbIZZK61sbzh4)HajQH03Un21OxlGZZGd7zeOeleK69aj1SbVvyzE7xXTXAJajio2iqWCbE72yxJETaoiMedzmz0l4aj1SbVvkOSB3g7A0RfWbXKyiJjJEbhCE7JvfDl8BdI3kokFEbBRl(1er8uRFXtijooVsI)GMNepyiXxajULoye3SwOpeFYjv0rCU2tIBHHaIRV0amIJKFqqXdMei(uTwX1esp6q8fkoydX)GstWqAXT0bZIhINGlIpvR9iyNJOxWFg6FAoCrnHZiDbzHfnLbJsMgqLHMJchLR04YWqLiHyO45OGsnchy26czJaXj16)GZB)QiHyO4eTkvITOB6UXQIUf(TbXF0esp642nU9bLMGH0N0ySpwv0TWVni(JMq6rhwXzWxuZjwEEcONxW26IFnrehSINA9lUL2yex3K4w6GPbIhmK4aAIH43tzVsIJ)K4kEefj(cehD)xClDWS4H4j4I4t1Apc25i6f8NH(NMdxut4msxqwyrtzWOuJWbMTUq2iqCsT(pnWQ7PmfdMTUq2iqCsT(pACyg9cSpwv0TWVni(JMq6rhwXzWxuZjwEEcOfSZr0l4pd9pnhU8mPETuqnPMELAeo2syNOg68aDzSaDh9cSpwv0TWVni(JMq6rhwXbl2Vcfhb58xurxZxwKIMYG5GZF7g6(VDKgdtuGKA2G)ooyrzZlyNJOxWFg6FAoCHgmBdWuGepSvtGwPgHJTe2jQHopqxglq3rVa7JvfDl8BdI)OjKE0HvCWI9RSLWorn0b)PcpSxyhxkWnYOxWTBppzmLiHyO4ppdoSNrGYhlu9ooC)2nioGqwig6aPFXb6gGPmmjSJlZlyBDXV(oyeNDcvs8grCWgINgiL6lIRxaPK44pj(KleK6vClDWio7QiXX5pc25i6f8NH(NMdxEgCypJaLyHGuVk1iCI0qG48mPETuq2b(FiqIAiTDBjStudDEGUmwGUJEb2rXrqo)fv018LfPOPmyo482hRk6w43ge)DCWI9R4gkocYHhsQKUJm6fCW5VD75jJPejedf)5zWH9mcu(yHQwX95fSZr0l4pd9pnhU8mPETu0jyqk1iC4gkocY5zs9APOtWGo482rAmmrbsQzd(74CnMosdbIZJJgeebhdDiqIAiTGDoIEb)zO)P5Wfed9mdyIek1iCU6xCdAd0hE8pWnuHG48rVGB3(f3G2a9X2AYOnu5xJnceZBNaeeZLJMq6rhwX5EkZo3(GstWq6tAm2rXrqo)fv018LfPOPmyo61cqPgeeeIZhLwvL0DgehfuQbbbH48rbJzrtdhfuQbbbH48rPr48lUbTb6JT1KrBOYVgBeieSZr0l4pd9pnhUWVrVaLAeoO4iihuZUAd(hhiLJ42nKgdtuGKA2G)U7PSB3qXrqo)fv018LfPOPmyo482Vcfhb58mPETuqnPM(do)TBJDn61c48mPETuqnPM(dKuZg83XrbLnVGDoIEb)zO)P5WfuZU6cco8IsnchuCeKZFrfDnFzrkAkdMdoVGDoIEb)zO)P5Wfuc(eCwdWOuJWbfhb58xurxZxwKIMYG5GZlyNJOxWFg6FAoCbPHeQzxTsnchuCeKZFrfDnFzrkAkdMdoVGDoIEb)zO)P5WLemOpGPPmsJrPgHdkocY5VOIUMVSifnLbZbNxW26IRicjXnH4iPXGMJzIJSqXX)e1qI3bP(3V4CTNe3shmIZErfDnV4lI4kIYG5iyNJOxWFg6FAoCb)PshK6RuJWbfhb58xurxZxwKIMYG5GZF7gsJHjkqsnBWFhwuMGTGT1TU4tyd6NHGVGT1f)6zAdjo(3amIBTqsL0DKrVaLepTTTw8r(rdWioRPhK4jqlUI6bjUfgcioltQxlIROemiX7x8FxG4Xkokjo(tALeNM4G4dXrwO4wdUa7eiyNJOxWFqAq)mCSLWornKsGuL4WdjvsxEGUmwGUJEbkzln4eNineio8qsL0DKrVGdbsudPT)8KXuIeIHI)8m4WEgbkFSq17Us5k2yTrGeehanGRzH65TZTXAJajioZUa7eiyNJOxWFqAq)mtZHlVPhujb6IUhKsnchUzlHDIAOdpKujD5b6Yyb6o6fy)5jJPejedf)5zWH9mcu(yHQ3DT25gkocY5zs9APOtWGo482rXrqoVPhujb6IUh0bsQzd(7qAmmrbsQzdE7qcbsptIAib7Ce9c(dsd6NzAoC5n9Gkjqx09GuQr4ylHDIAOdpKujD5b6Yyb6o6fyFSRrVwaNNj1RLIobd6mysig6liWCe9csZDkCSMk3okocY5n9Gkjqx09GoqsnBWF3yxJETao)fv018LfPOPmyoqsnBWB)QXUg9AbCEMuVwk6emOdKs9f7O4iiN)Ik6A(YIu0ugmhiPMn4vmuCeKZZK61srNGbDGKA2G)ofoyzEbBRlUIBYWtqXTgtyNOgsCKfk(1HZh4q6io7SMxCnoSbyexXNFqqX56)N)3aXxO4ACydWiUIsWGe3shmIROeot8eOfhSIpxJHj(inZi4rWohrVG)G0G(zMMdxSLWornKsGuL48ZA(ceNpWHKs2sdoXrn)GGL8)8)guGKA2G3kLD7g3I0qG4aAmmXhPzgbpeirnK2EKgcehDcNvEMuVwoeirnK2okocY5zs9APOtWGo483U98KXuIeIHI)8m4WEgbkFSqvR4WDbBRlU1aI4fhNx8RdNpWHK4nI4DiE)INOlEiESIdXbIV4XrWohrVG)G0G(zMMdxG48boKuQr4Cf3SLWorn05N18fioFGdPB3SLWorn0b)PcpSxyhxkWnYOxW82JeIHIt0Quj2IUjfdsQzdERUw7qcbsptIAib7Ce9c(dsd6NzAoC5PbKIsqdgqpbJtc2wxCfpUjA9grdWiEKqmu8IhmziUL2ye302iXrwO4bdjUghMrVaXxeXVoC(ahskjoKqG0ZiUgh2amIZNanP2JJGDoIEb)bPb9ZmnhUaX5dCiP04YWqLiHyO45OGsnchUzlHDIAOZpR5lqC(ahs25MTe2jQHo4pv4H9c74sbUrg9cS)8KXuIeIHI)8m4WEgbkFSqvR4Gf7rcXqXjAvQeBr3KvCUs5tFfwMaJvfDl8BdIF(5Tdjei9mjQHeSTU4xhHaPNr8RdNpWHK4ucnxeVreVdXT0gJ40e5BijUgh2amIZErfDn)rCfTIhmzioKqG0ZiEJio7QiXXqXloKs9fXBG4bdjoGMyiUY)JGDoIEb)bPb9ZmnhUaX5dCiPuJWHB2syNOg68ZA(ceNpWHKDiPMn4VBSRrVwaN)Ik6A(YIu0ugmhiPMn4NwbLzFSRrVwaN)Ik6A(YIu0ugmhiPMn4VJJYThjedfNOvPsSfDtkgKuZg8wn21OxlGZFrfDnFzrkAkdMdKuZg8tRCb7Ce9c(dsd6NzAoCb1KJzf(1IMGk1iC4MTe2jQHo4pv4H9c74sbUrg9cS)8KXuIeIHI3ko3tWohrVG)G0G(zMMdxiB9piygKGTGT1TU4SbLMGr8PURrVwaVGT1fxXnz4jO4wJjStudjyNJOxWF(GstWug6NJTe2jQHucKQeNNrxcgi9mRrRKT0GtCg7A0RfW5zs9APOtWGodMeIH(ccmhrVG0yfhfowtLlyBDXTgtq)mI3iIBHepHK4JKNVbyeFbIROemiXhmjed9hX5kMqZfXrjKfsIJ0WpexNGbjEJiUfsCM0gjoyfFUgdt8rAMrqXrXdXvucNjoltQxlI3aXxOMGIhR4yOq8RdNpWHK448IFfyfxXNFqqX56)N)3G5pc25i6f8NpO0emLH(NMdxSLG(zuQr4Cf3SLWorn05z0LGbspZA03UXTineioGgdt8rAMrWdbsudPThPHaXrNWzLNj1RLdbsudPN3(yvr3c)2G4pAcPhDyLc25gehqiledDut4SYIucgQOMFqWs(F(FdeSTU4w7UgXrwO4SmPETOsgT4tloltQxlFa7zK44ad9V4wiXtijEIU4H4Xk(i5fFbIROemiXhmjed9hXNGaMlIBHHaIpHnql(1t5ma9V49lEIU4H4Xkoehi(Ihhb7Ce9c(ZhuAcMYq)tZHl87Akq6xC4GuczHfanXGJckrtmGzjvxCqWH7ktPgHdmh0b0yyIczqeSZr0l4pFqPjykd9pnhU8mPETOsgTsnchcqqmxSId3vMDcqqmxoAcPhDyfhfuMDUzlHDIAOZZOlbdKEM1OTpwv0TWVni(JMq6rhwPGDnHIJGCqAGUyHYza6)dKuZg83PGGT1fFQwR4bdKEM1OFXrwO4eiiydWioltQxlIROemib7Ce9c(ZhuAcMYq)tZHl2syNOgsjqQsCEgDzSQOBHFBq8kzln4eNXQIUf(TbXF0esp6WkoyzAuCeKZZK61sb1KA6p48c25i6f8NpO0emLH(NMdxSLWornKsGuL48m6Yyvr3c)2G4vYwAWjoJvfDl8BdI)OjKE0HvCUNsncNXAJajioZUa7eiyNJOxWF(GstWug6FAoCXwc7e1qkbsvIZZOlJvfDl8BdIxjBPbN4mwv0TWVni(JMq6rh3XrbLAeo2syNOg6G)uHh2lSJlf4gz0lW(Ztgtjsigk(ZZGd7zeO8XcvTId3fSTU4kkbdsCnoSbyeN9Ik6AEXxO4j6AJepyG0ZSg9rWohrVG)8bLMGPm0)0C4YZK61srNGbPuJWXwc7e1qNNrxgRk6w43geV9RSLWorn05z0LGbspZA03UHIJGC(lQOR5llsrtzWCGKA2G3kokCWYTBO4iiNbtUFbnb0bN)2TNNmMsKqmu8NNbh2Ziq5JfQAfhUBFSRrVwaN)Ik6A(YIu0ugmhiPMn4TsbLnV9RqXrqo8eezHzq6InQb)5JCm7oUF72Ztgtjsigk(ZZGd7zeO8XcvTclZlyBDXXkoeioKuZg0amIROemOxCuczHK4bdjosJHjeNa6x8grC2vrIBzbtjehLehsP(I4nq8OvPJGDoIEb)5dknbtzO)P5WLNj1RLIobdsPgHJTe2jQHopJUmwv0TWVniE7ingMOaj1Sb)DJDn61c48xurxZxwKIMYG5aj1SbVGTGT1TU4SbLMGH0IFDBKrVabBRl(1erC2GstWWfBjOFgXtijooVsIJ)K4SmPET8bSNrIhR4OeGq6qCe4QkEWqIZN)32iXrxa(lEc0IpHnql(1t5ma9VsIt2iG4nI4wiXtijEgIRMtu8PATIFfoWq)lo(3amIR4ZpiO4C9)Z)BW8c25i6f8NpO0emKMZZK61YhWEgPuJW5kuCeKZhuAcMdo)TBO4iihBjOFMdo)82V65jJPejedf)5zWH9mcu(yHQ3X9B3SLWorn0b)PcpSxyhxkWnYOxW82vZpiyj)p)VbfiPMn45OmbBRl(e2G(zepdXV30IpvRvClDWS4H4kIvCUio3NwClDWiUIyf3shmIZYGd7zeq8jxii1R4O4iiIJZlESIN22wl(VQK4t1Af3s(bj(3bEg9c(JGT1fNRB(v8priXJvCKg0pJ4zio3Nw8PATIBPdgXPjMJWCrCUlEKqmu8hXVInvjXZx8fp(wtI)bLMG5mVGT1fFcBq)mINH4CFAXNQ1kULoyw8qCfXQK4kFAXT0bJ4kIvjXtGw8RvClDWiUIyfprcckU1yc6NrWohrVG)8bLMGH0tZHlJ0yk5i6fum9hkbsvIdsd6NrPgHJTe2jQHoeccnI2gvgRk6w43geVvCg8f1CILNNa6B3qXrqopdoSNrGsSqqQ3doV9XQIUf(TbXF0esp64ooy52TNNmMsKqmu8NNbh2Ziq5JfQAfhUB3wc7e1qhcbHgrBJkJvfDl8BdI3koC)2TXQIUf(TbXF0esp64ookOyxfPHaXrtepblFaZiXqQhcKOgsBhfhb5ylb9ZCW5NxWohrVG)8bLMGH0tZHlptQxlFa7zKsncNpO0emK(8e)3V9NNmMsKqmu8NNbh2Ziq5JfQEh3fSZr0l4pFqPjyi90C4YZ02uQr4ePHaXb0yyIpsZmcEiqIAiTDioGqwig6en4sj2j2JcQj1K9NNmMsKqmu8NNbh2Ziq5JfQENYfSTU4CnEXJv87jEKqmu8IFfyfNh278IpJiEXX5fFcBGw8RNYza6FXrVi(4YW0amIZYK61YhWEgDeSZr0l4pFqPjyi90C4YZK61YhWEgP04YWqLiHyO45OGsnchUzlHDIAOd(tfEyVWoUuGBKrVa7Acfhb5G0aDXcLZa0)hiPMn4Vtb7ppzmLiHyO4ppdoSNrGYhlu9oo3ZEKqmuCIwLkXw0nPyqsnBWB11kyBDXNWfkopSxyhxehUrg9cusC8NeNLj1RLpG9ms81gbfNnwOQ4w6Gr8RxXlEIjBWhIJZlESIZDXJeIHIx8fkEJi(eE9I3V4qCaObyeFrqe)QfiEcUiEQU4Gq8fr8iHyO4NxWohrVG)8bLMGH0tZHlptQxlFa7zKsnchBjStudDWFQWd7f2XLcCJm6fy)knHIJGCqAGUyHYza6)dKuZg83PWTBrAiqCSqj)cuZpi4HajQH02FEYykrcXqXFEgCypJaLpwO6DC4(8c25i6f8NpO0emKEAoC5zWH9mcu(yHQk1iCEEYykrcXqXBfN7n9vO4iiNGHkWnccCW5VDdIdiKfIHo5SmH9x(f3uqGjgvceZB)kuCeKZFrfDnFzrkAkdMsIh7a2XbN)2nUHIJGC4HKkP7iJEbhC(B3EEYykrcXqXBfhLpVGT1fNLj1RLpG9ms8yfhsiq6zeFcBGw8RNYza6FXtGw8yfNapoKe3cj(ibIpsi8I4RnckEkocUXi(eE9I3GyfpyiXb0edXzxfjEJio)(FJAOJGDoIEb)5dknbdPNMdxEMuVw(a2ZiLAeoAcfhb5G0aDXcLZa0)hiPMn4VJJc3Un21OxlGZFrfDnFzrkAkdMdKuZg83PW1WUMqXrqoinqxSq5ma9)bsQzd(7g7A0RfW5VOIUMVSifnLbZbsQzdEb7Ce9c(ZhuAcgspnhUGXSRkQj1KsnchuCeKdpbrwygKUyJAWF(ihZSIJYTpwGgVJdpbrwygKUyJAWFGjyMvCu4Ec25i6f8NpO0emKEAoC5zs9A5dypJeSZr0l4pFqPjyi90C4YGHs(YZSHsnchUfjedfN(lO7)2hRk6w43ge)rti9OdR4OGDuCeKZZSrPbLGHk6eo7GZBNaeeZLt0Quj2c3vMvyg6JAoXAuJAfa]] )

    
end
