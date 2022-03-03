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

    spec:RegisterStateTable( "time_to_sht_plus", setmetatable( {}, {
        __index = function( t, k )
            local n = tonumber( k )
            n = n - ( n % 1 )

            if not n or n > 5 then return 3600 end
            local val = time_to_sht[k]

            -- Time of next attack instead.
            if val == 0 then
                local last = swings.mainhand
                local speed = swings.mainhand_speed
                local swing = 3600

                if last > 0 and speed > 0 then
                    swing = last + ( ceil( ( query_time - last ) / speed ) * speed ) - query_time
                end

                last = swings.offhand
                speed = swings.offhand_speed

                if last > 0 and speed > 0 then
                    swing = min( swing, last + ( ceil( ( query_time - last ) / speed ) * speed ) - query_time )
                end

                return swing
            end

            return val
        end,
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


    spec:RegisterPack( "Subtlety", 20220302.1, [[difmtcqiOuEKKeBIQQpjjLrPs0PujzvKqvVssLzrIClsq2Lu9lOunmsihJQILPs4zQKY0qs5AKOABssY3ujvzCKqLZPsQK1HKkEhsQK08uPY9qI9rvP)PsQGdcLqlekPhkjvtKe4IKqj2OKK6JKqPgjjusNuLuvRej5LQKk0mrsvUjjuStvQ6NQKk1qjb1sHsWtr0uLu1vrsvTvKuP(kuIASqjYzrsLu7vf)vIbt5WIwmu9yPmzQCzuBgIpdfJgsNwXQrsL41sIztQBtv2nWVvA4i1Xvjv0Yb9CvnDHRJW2jP(ojz8KOCEvkRhjvsmFjL9t8XNt9hsxg85(lu0fxOORPOl6xCb1U4A(CiJB08HKoBvsm8HeKE8HKKap0CC7qsN30B6o1Fi)La24djAe0p1b7yhZeOe4926H9F8i0zmlObtKa7)41W(HeNy0X1hCWpKUm4Z9xOOlUqrxtrx0V4cQDX1oKjrGUWdj54v9dj64Cm4GFiD83oKKe4HMJBIHfwmeSqLIjHnuXUqjXUqrxCHqLqv1rtag(PocvkKykMvnlM6eojUM7epxOHZcN4wbUrgZceJGwSFfBcXMxSNdXWzKfYIPIfJ4zXMOluPqIv91dFaSyEe6yO1SyTuRlzlMfu0ZhIXGao8lwSIbzhrJfJEdgetQfdYQwyLUqLcjMIjRWIv1A(rBWejeBabdHe0HydqS26HNHydIyQyXOUq8HyUXj2eIHSqXuV6mgnx(vRMbr)qQNp(t9hYp4uhOS7u)5EFo1FizqIRz3bRhYSfZcoKpA6wvFaNk8H0XFdo0XSGd51hrmYGtDGID1jyEuXsilgbTsIr8SyKOPBv9bCQWIfRy4mGrMqme46jwGYIrN)pQzXWxaXlwcCIv1dWjgwMZka(FLeJvZaXgeXuXILqwSmeZlvMyvxHf7scGM)xmIFayetXKFWqXWI)N)pGRoKn4emCYd5LIHtGG0)GtDG2jOfRwnXWjqq6QtW8ODcAXUsm)IDPypnR1LiHy447pkbCQWGYhl0tS7eJAIvRMyQt4K4AUt8CHgolCIBf4gzmlqSReZVyE5hmSK)N)pGcK9Yb8IrrmfDIZ9xCQ)qYGexZUdwpKo(BWHoMfCiR6bmpQyzig1QtSQRWIPAc0LietbKkjMYRtmvtGkMcivsSe4eRQet1eOIPasXsKGHIrDNG5rpKzlMfCiBPwxYwmlOONpoKn4emCYdP6eojUM7mcc3IrnxARh(wO3beVy(srSgDXlvw5PzGtSA1edNabP)OeWPcdkXcbPB7e0I5xS26HVf6DaX3DmY0MqS7Oi2fIvRMypnR1LiHy447pkbCQWGYhl0tmFPig1eZVyQt4K4AUZiiClg1CPTE4BHEhq8I5lfXOMy1QjwB9W3c9oG47ogzAti2DueZhXuiXUuSi1mi6oMPzy5dygjg2RZGexZoX8lgobcsxDcMhTtql2vhs98rbKE8HezaZJEIZ9x7u)HKbjUMDhSEiBWjy4KhYp4uhOSR)m9pVy(f7PzTUejedhF)rjGtfgu(yHEIDNyu7qMTywWH8rt3Q6d4uHpX5EQDQ)qYGexZUdwpKzlMfCiXZwLps8dPJ)gCOJzbhsSMTkFK4I5iGdaJyKOPBvjMcsqJftfkdeBbIHoyqftHPUf7JSv5flboXirt3QsmSQth)InVye09dzdobdN8qItGG0PziYcZGDf18a((hzRIy(srmLlMFXWjqq6pA6wvfxcAChYE5aEX8LIyxtm)IHtGG0F00TQk460XFNGwm)I90SwxIeIHJV)OeWPcdkFSqpXUJIyx7eN7v(P(djdsCn7oy9q2GtWWjpKrQzq0bdg04JuxHHDgK4A2jMFXGeagzHy4EmGBLyv20k460XDgK4A2jMFXEAwRlrcXWX3Fuc4uHbLpwONy3jMYpKzlMfCiF0r9jo3xvN6pKmiX1S7G1dz2IzbhYhnDRQpGtf(q2U10Cjsigo(Z9(CiBWjy4KhsSjM6eojUM7epxOHZcN4wbUrgZceZVyogNabPJmaxrfNva8)Di7Ld4f7oX8rm)I90SwxIeIHJV)OeWPcdkFSqpXUJIyxtm)Ifjedh9y84sSf3WIPqIbzVCaVy(kwvDiD83GdDml4qs9PflwXUMyrcXWXl2LGvmA4SxjwfMPfJGwSQEaoXWYCwbW)lg(nXA3A6bGrms00TQ(aov4(jo3F9o1FizqIRz3bRhYSfZcoKpA6wvFaNk8H0XFdo0XSGdzvVqXOHZcN4MyWnYywGsIr8SyKOPBv9bCQWITQzOyKXc9et1eOIHLvmILyYb8Hye0IfRyutSiHy44fBHIniIv1yzXMxmibamamITiiID5celb3el9wcqi2IiwKqmC8xDiBWjy4Khs1jCsCn3jEUqdNfoXTcCJmMfiMFXUumhJtGG0rgGROIZka()oK9Yb8IDNy(iwTAIfPMbrxfN0lWl)GHDgK4A2jMFXEAwRlrcXWX3Fuc4uHbLpwONy3rrmQj2vN4CVI7u)HKbjUMDhSEiBWjy4KhYNM16sKqmC8I5lfXUMy1j2LIHtGG0duUa3iyqNGwSA1edsayKfIH7zLmHZx(LqxqGjgpgeDgK4A2jwTAI9CuWxaX3JHHxO4kxq3e7kX8l2LIHtGG0)BE4R(llsXXzGwsIyBWj6e0IvRMyytmCceKonK9y3ezmlOtqlwTAI90SwxIeIHJxmFPiMYf7Qdz2IzbhYhLaovyq5Jf6DIZ9xxN6pKmiX1S7G1dz2IzbhYhnDRQpGtf(q64Vbh6ywWHKenDRQpGtfwSyfdYiq(rfRQhGtmSmNva8)ILaNyXkgdEcilMkwSwceRLq4nXw1muSumecTwSQgll2aIvSaLfdWkleJCvGydIy07)dUM7hYgCcgo5H0X4eiiDKb4kQ4ScG)VdzVCaVy3rrmFeRwnXA7QDRkq)V5HV6VSifhNbAhYE5aEXUtmFuCI5xmhJtGG0rgGROIZka()oK9Yb8IDNyTD1UvfO)38Wx9xwKIJZaTdzVCa)jo37JIo1FizqIRz3bRhYgCcgo5HeNabPtZqKfMb7kQ5b89pYwfX8LIykxm)I1wGJyIondrwygSROMhW3HjOIy(srmFU2HmBXSGdjg9UE460XN4CVp(CQ)qMTywWH8rt3Q6d4uHpKmiX1S7G1tCU3Nlo1FizqIRz3bRhYgCcgo5HeBIfjedh95l47)I5xS26HVf6DaX3DmY0MqmFPiMpI5xmCceK(JUrzaLaLlUewPtqlMFXyadXCRhJhxITqnfjMVIHP56EPYoKzlMfCiBOCsxE0noXjoKogjj0XP(Z9(CQ)qMTywWHSY0QCizqIRz3bRN4C)fN6pKmiX1S7G1d5sFiFooKzlMfCivNWjX18HuDQj4djobcs)1tJljWvCtJ7e0IvRMypnR1LiHy447pkbCQWGYhl0tmFPiwvDiD83GdDml4qs9F2jwSI54GHEdGftfkhOmuS2UA3Qc8IPkNqmKfkgjqbIHNp7eBbIfjedhF)qQoHfq6XhYh4kTf4MywWjo3FTt9hsgK4A2DW6HCPpKphhYSfZcoKQt4K4A(qQo1e8HeNabP)6PXLe4kUPXDcAXQvtSNM16sKqmC89hLaovyq5Jf6jMVueRQoKQtybKE8H8bUsBbUjMfCIZ9u7u)HKbjUMDhSEix6d5ZXHmBXSGdP6eojUMpKQtybKE8HC(cGvwuA0LemEzdnHyy3HSbNGHtEiBRAgKGOx5gCsWH0XFdo0XSGdz1r5wfXIvSNzXgeXcuwmaRSqSQRWID5aelqzXy1mieBrelfJeTEXOHB7kXMxmSiy8YgAcXWUdP6utWhY26HVf6DaXlgfX8rm)IHtGG05g6oamfitdhVe4kx0jOfRwnXARh(wO3beVyue7cX8lgobcsNBO7aWuGmnC8sGRCTobTy1QjwB9W3c9oG4fJIyxtm)IHtGG05g6oamfitdhVe4kuRtqlwTAI1wp8TqVdiEXOig1eZVy4eiiDUHUdatbY0WXlbUIY7e0N4CVYp1FizqIRz3bRhYL(q(CCiZwml4qQoHtIR5dP6utWhsgbHBXOMlT1dFl07aI)q64Vbh6ywWHel2AlbiedzHIrIwVyqoBXSaXIXJfd)MydgWchagX0RkfQ6kSyjy8YgAcXWoX8YOHYVydqSaLftrDL)Ird5gZUbGrSum6nyqmPwms06fJgUTdP6ewaPhFizeeUfJAU0wp8TqVdi(tCUVQo1FizqIRz3bRhYL(q(CCiZwml4qQoHtIR5dP6utWhY26HVf6DaXFiBWjy4KhY2QMbji6vUbNeiMFXyeeUfJAU0wp8TqVdiEX8vS26HVf6DaXlMFXARh(wO3beF3XitBcX8vSleZVyX4XLylpAuO1eFNAIDNykQRCX8lg2etDcNexZ95lawzrPrxsW4Ln0eIHDhs1jSasp(qYiiClg1CPTE4BHEhq8N4C)17u)HKbjUMDhSEiD83GdDml4qwDuUvrSQRGxSmedzGFCiZwml4q2sTUKTywqrpFCi1Zhfq6XhYM7pX5Ef3P(djdsCn7oy9qMTywWH81tJljWvCtJpKo(BWHoMfCiXI006BIrQNglwcCIPGPXILHyxuNyvxHfZrahagXcuwmKb(Hy(OiXEUTa3RKyjsWqXc0meJA1jw1vyXgeXMqmwz0dKFXunb6aelqzXaSYcXuSRUceBHInVyGneJG(q2GtWWjpKpnR1LiHy447pkbCQWGYhl0tS7eRQeZVyidg0OazVCaVy(kwvjMFXWjqq6VEACjbUIBAChYE5aEXUtmmnx3lvMy(fRTE4BHEhq8I5lfXOMykKyxkwmESy3jMpksSRetXl2fN4C)11P(djdsCn7oy9qU0hYNJdz2Izbhs1jCsCnFivNAc(qsdNfoXTcCJmMfiMFXEAwRlrcXWX3Fuc4uHbLpwONy(srSloKo(BWHoMfCiVUb6BI1qtagwm4gzmlqSbrmvSyOPAwmA4SWjUvGBKXSaXEoelboX8i0XqRzXIeIHJxmc6(HuDclG0JpKepxOHZcN4wbUrgZcoX5EFu0P(djdsCn7oy9q64Vbh6ywWHelqaedHqRVj2RAIgk)IfRybklgzWPoqzNyyHnYywGyxIFtm3oamI9RsInHyilSXVy07QhagXgeXaBGoamInVyP6C0jUMVQFiZwml4qcjaLSfZck65JdzdobdN8q(bN6aLD9uRpK65Jci94d5hCQdu2DIZ9(4ZP(djdsCn7oy9q64Vbh6ywWHuHHZcN4MyyHnYywW1bXOECuTxmmJAwSuSgmPflXxIqmgWqm3edzHIfOSyFWPoqfR6k4f7sCIr7yOyFmATyq(P5wi2ex1fJ6AcALeBcXAjqmCwSandX(XJwZ9dz2IzbhYwQ1LSfZck65JdzdobdN8qQoHtIR5oXZfA4SWjUvGBKXSGdPE(Oasp(q(bN6aT0C)jo37ZfN6pKmiX1S7G1d5sFiFooKzlMfCivNWjX18HuDQj4d5fkxS6elsndIU6bZc7miX1StmfVyxOiXQtSi1mi6E5hmSSiLhnDRQVZGexZoXu8IDHIeRoXIuZGO)OPBvvq2gX3zqIRzNykEXUq5IvNyrQzq0tD2GtCRZGexZoXu8IDHIeRoXUq5IP4f7sXEAwRlrcXWX3Fuc4uHbLpwONy(srmQj2vhsh)n4qhZcoKu)NDIfRyogzaSyQqzGyXkgXZI9bN6avSQRGxSfkgoXODm8pKQtybKE8H8do1bAjqH8JUA3jo37Z1o1FizqIRz3bRhsh)n4qhZcoKvFb)4yOye)aWiwkgzWPoqfR6kqmvOmqmiNn0bGrSaLfJbmeZnXcui)OR2DiZwml4q2sTUKTywqrpFCiBWjy4KhsgWqm36ogzAti2DuetDcNexZ9p4uhOLafYp6QDhs98rbKE8H8do1bAP5(tCU3hQDQ)qYGexZUdwpKo(BWHoMfCiR6bmpQyziMxQmLeJA1jMQjqxIqmfqk2cft1eOIrUkqSgCcXWjqqusmLxNyQMavmfqk2Llr8JJf7do1b6vkjMQjqftbKIL6FfdzaZJkwgIrT6elXKd4dXOMyrcXWXl2Llr8JJf7do1b6vhYSfZcoKTuRlzlMfu0ZhhYgCcgo5HuDcNexZDgbHBXOMlT1dFl07aIxmFPiwJU4LkR80mWjwTAI1wp8TqVdi(UJrM2eIDhfX8rSA1edzWGgfi7Ld4f7okI5Jy(ftDcNexZDgbHBXOMlT1dFl07aIxmFPi21eRwnXWjqq6)np8v)LfP44mqljrSn4eDcAX8lM6eojUM7mcc3IrnxARh(wO3beVy(srmQjwTAI90SwxIeIHJV)OeWPcdkFSqpX8LIyutm)IPoHtIR5oJGWTyuZL26HVf6DaXlMVueJAhs98rbKE8HezaZJEIZ9(O8t9hsgK4A2DW6H0XFdo0XSGdj1)zXsXWjgTJHIPcLbIb5SHoamIfOSymGHyUjwGc5hD1Udz2IzbhYwQ1LSfZck65JdzdobdN8qYagI5w3XitBcXUJIyQt4K4AU)bN6aTeOq(rxT7qQNpkG0JpK4eJ2DIZ9(uvN6pKmiX1S7G1dz2IzbhYe2saxIfczqCiD83GdDml4qs9wv8hIrdNfoXnXgGyPwl2IiwGYIHfvyQNy4CljEwSjeRLep)ILIPyxDfCiBWjy4KhsgWqm36ogzAtiMVueZhLlwDIXagI5whYyyWjo37Z17u)HmBXSGdzcBjGl0e6NpKmiX1S7G1tCU3hf3P(dz2Izbhs9Gbn(c1fchgpgehsgK4A2DW6jo37Z11P(dz2Izbhs8etzrkbCAv(djdsCn7oy9eN4qsd526HNXP(Z9(CQ)qMTywWHmPP13k078l4qYGexZUdwpX5(lo1FiZwml4qIVrOzxbrN3yNQbGPeRYgWHKbjUMDhSEIZ9x7u)HKbjUMDhSEiBWjy4KhYFj04dW1Pj(GqZfgsqhZc6miX1StSA1e7xcn(aCD1RoJrZLF1Qzq0zqIRz3HmBXSGdjIMF0gmrItCUNAN6pKzlMfCi)GtDGEizqIRz3bRN4CVYp1FizqIRz3bRhYSfZcoKEjSc7kilS44mqpK0qUTE4zuEUTa3Fi9r5N4CFvDQ)qYGexZUdwpKzlMfCiF904scCf304dzdobdN8qczei)OjUMpK0qUTE4zuEUTa3Fi95eN7VEN6pKmiX1S7G1dzdobdN8qcjamYcXWDVewPSiLaLlE5hmSK)N)pGodsCn7oKzlMfCiF00TQk460X)joXHeNy0Ut9N795u)HKbjUMDhSEiBWjy4KhsSjwKAgeDWGbn(i1vyyNbjUMDI5xmibGrwigUhd4wjwLnTcUoDCNbjUMDI5xSNM16sKqmC89hLaovyq5Jf6j2DIP8dz2IzbhYhDuFIZ9xCQ)qYGexZUdwpKn4emCYd5tZADjsigoEX8LIyxiMFXUumSjwBvZGeeDa3GREHoXQvtS2UA3Qc0FgcZGDf8fWLNEQWDVuzLgAcXWVykKyn0eIH)ccmBXSGulMVuetr9luUy1Qj2tZADjsigo((JsaNkmO8Xc9eZxXOMyxjMFXUumCceKondrwygSROMhW3)iBve7okIrnXQvtSNM16sKqmC89hLaovyq5Jf6jMVIrnXU6qMTywWH8rjGtfgu(yHEN4C)1o1FizqIRz3bRhYgCcgo5HeNabPtZqKfMb7kQ5b89pYwfXUJIyxiMFXUuS2UA3Qc0FgcZGDf8fWLNEQWDVuzLgAcXWVykKyn0eIH)ccmBXSGul2Duetr9luUy1Qj2VeA8b46AoDf8BfwzPhTM7miX1Stm)IHnXWjqq6AoDf8BfwzPhTM7e0IvRMy)sOXhGRxHvpGVSl1vy9aW0zqIRzNy(fdBI5yCceKEfw9a(IkygODcAXU6qMTywWH8zimd2vWxaxE6PcFIZ9u7u)HmBXSGdjg9UE460XhsgK4A2DW6jo3R8t9hsgK4A2DW6HmBXSGdjE2Q8rIFiD83GdDml4qI1Sv5JexSXZJDtgS(Myean)VybklgGvwiw1vyXMxmSiy8YgAcXWoXsGtmvSyQwq1cXAjTymGHyUjMQCIbGrmKfk2e9dzdobdN8qInXARAgKGOx5gCsGy1Qjg2e7sXuNWjX1CF(cGvwuA0LemEzdnHyyNy(f7sXIXJlXwE0OqRj((1e7oXuux5IvRMyX4XLylpAuO1eFNAIDNy(i2vI5xmgWqm3e7oXQkfj2vN4ehYM7p1FU3Nt9hsgK4A2DW6HSbNGHtEiXMy4eii9hnDRQIlbnUtqlMFXWjqq6pkbCQWGsSqq62obTy(fdNabP)OeWPcdkXcbPB7q2lhWl2Due7ADLFijEUSiifmn35EFoKzlMfCiF00TQkUe04dPJ)gCOJzbhsQ)ZIPGe0yXweefctZjgoJSqwSaLfdzGFigjkbCQWaXiJf6jgcC9eR(fcs3kwB94xSb0pX5(lo1FizqIRz3bRhYgCcgo5HeNabP)OeWPcdkXcbPB7e0I5xmCceK(JsaNkmOeleKUTdzVCaVy3rrSR1v(HK45YIGuW0CN795qMTywWH8V5HV6VSifhNb6H0XFdo0XSGd5LuFGM)xSud50DtmcAXW5ws8SyQyXIDRigjA6wvIv1BJ4VsmINfJ8Mh(QFXweefctZjgoJSqwSaLfdzGFigjkbCQWaXiJf6jgcC9eR(fcs3kwB94xSb0pX5(RDQ)qYGexZUdwpKn4emCYdP6eojUM7pWvAlWnXSaX8lg2e7do1bk76Eji0Sy(f7sXEAwRlrcXWX3Fuc4uHbLpwONy3rrmFeZVyTD1UvfO)38Wx9xwKIJZaTtqlMFXWMyrQzq0F00TQkiBJ47miX1StSA1edNabP)38Wx9xwKIJZaTtql2vI5xS26HVf6DaXlMVuet5hYSfZcoKi6edR1zml4eN7P2P(djdsCn7oy9q2GtWWjpKxkgKaWiled39syLYIucuU4LFWWs(F()a6miX1Stm)I1wp8TqVdi(UJrM2eIDhfX8rmfsSi1mi6oMPzy5dygmg2RZGexZoXQvtmibGrwigU74mq13kpA6wvFNbjUMDI5xS26HVf6DaXl2DI5JyxjMFXWjqq6)np8v)LfP44mq7e0I5xmCceK(JMUvvXLGg3jOfZVyE5hmSK)N)pGcK9Yb8IrrmfjMFXWjqq6oodu9TYJMUv13DRkWHmBXSGdP6emp6jo3R8t9hsgK4A2DW6H0XFdo0XSGdPcVRwmKfkw9leKUvmAiRqKRcet1eOIrIQaXGC6UjMkugigydXGeaWaWigzv3pKilSayLfN795q2GtWWjpKrQzq0Fuc4uHbLyHG0TDgK4A2jMFXWMyrQzq0F00TQkiBJ47miX1S7qMTywWHKExDbY)saB8jo3xvN6pKmiX1S7G1dz2IzbhYhLaovyqjwiiD7H0XFdo0XSGdj1)zXQFHG0TIrdzXixfiMkugiMkwm0unlwGYIXagI5MyQq5aLHIHaxpXO3vpamIPAc0LieJSQfBHIrDH4dXWWagMA9T(HSbNGHtEiFAwRlrcXWX3Fuc4uHbLpwONy3rrmFeZVymGHyUjMVueRQuKy(ftDcNexZ9h4kTf4MywGy(fRTR2TQa9)Mh(Q)YIuCCgODcAX8lwBxTBvb6pA6wvfxcACVHMqm8lMVueZhX8l2LIHnXGeagzHy4(IZUHbnUZGexZoXQvtmhJtGG0r0jgwRZywqNGwSA1e7PzTUejedhF)rjGtfgu(yHEI5lfXUumFeRoXOMykEXUumSjwKAgeDWGbn(i1vyyNbjUMDI5xmSjwKAgeDxcRuE00TQ6miX1StSRe7kXUsm)I1wp8TqVdiEXUJIyxiMFXWMy4eiiDAi7XUjYywqNGwm)IDPyytS2QMbji6QzqGEdkwTAIHnXA7QDRkqhrNyyToJzbDcAXU6eN7VEN6pKmiX1S7G1dz2IzbhYNHWmyxbFbC5PNk8HSbNGHtEivNWjX1C)bUsBbUjMfiMFXWMyUn6pdHzWUc(c4Ytpv4IBJEmTkdaJy(flsigo6X4XLylUHfZxkIDHpI5xSlfRTE4BHEhq8DhJmTjeZxkIDPyn6cMCaI571bXOMyxj2vI5xmSjgobcs)rjGtfguIfcs32jOfZVyxkg2edNabPtdzp2nrgZc6e0IvRMypnR1LiHy447pkbCQWGYhl0tmFfJAIDLy1QjgYGbnkq2lhWl2Duet5I5xSNM16sKqmC89hLaovyq5Jf6j2DIDTdz7wtZLiHy44p37Zjo3R4o1FizqIRz3bRhYgCcgo5HuDcNexZ9h4kTf4MywGy(fRTE4BHEhq8DhJmTjeZxkI5Jy(flsigo6X4XLylUHfZxkI5tvDiZwml4q(m9p)jo3FDDQ)qYGexZUdwpKzlMfCi)BE4R(llsXXzGEiD83GdDml4qs9FwmYBE4R(fBbI12v7wvaXUmrcgkgYa)qmsGcUsmcGM)xmvSyjKfdZoamIfRy0lTy1Vqq6wXsGtm3kgydXqt1SyKOPBvjwvVnIVFiBWjy4Khs1jCsCn3FGR0wGBIzbI5xSlfdBIfPMbr)rjGtfguIfcs32zqIRzNy1QjwKAge9hnDRQcY2i(odsCn7eRwnXEAwRlrcXWX3Fuc4uHbLpwONy(srSleRwnXA7QDRkq)rjGtfguIfcs32HSxoGxmFf7cXUsm)IDPyytS2QMbji6QzqGEdkwTAI12v7wvGoIoXWADgZc6q2lhWlMVI5JIeRwnXA7QDRkqhrNyyToJzbDcAX8lwB9W3c9oG4fZxkIPCXU6eN79rrN6pKmiX1S7G1dz2IzbhsVewHDfKfwCCgOhs9a4sZDi9PR8dz7wtZLiHy44p37ZHSbNGHtEiH54kSAge905(obTy(f7sXIeIHJEmECj2IByXUtS26HVf6DaX3DmY0MqSA1edBI9bN6aLD9uRfZVyT1dFl07aIV7yKPnHy(srSgDXlvw5PzGtSRoKo(BWHoMfCiV(iILo3lwczXiOvsShm0Sybkl2cyXunbQy6vf)Hy1xVc6Ir9FwmvOmqm3TbGrmK8dgkwGMaXQUclMJrM2eITqXaBi2hCQdu2jMQjqxIqSeCtSQRW9tCU3hFo1FizqIRz3bRhYSfZcoKEjSc7kilS44mqpKo(BWHoMfCiV(iIbwXsN7ft1O1I5gwmvtGoaXcuwmaRSqSRPOxjXiEwmfdIceBbIHV)lMQjqxIqSeCtSQRW9dzdobdN8qcZXvy1mi6PZ99biMVIDnfjMcjgmhxHvZGONo33DeWmMfiMFXARh(wO3beF3XitBcX8LIyn6IxQSYtZa3jo37ZfN6pKmiX1S7G1dzdobdN8qQoHtIR5(dCL2cCtmlqm)I1wp8TqVdi(UJrM2eI5lfXUqm)IDPy4eii9)Mh(Q)YIuCCgODcAXQvtm89FX8lgYGbnkq2lhWl2Due7cfjwTAIHnXWjqq6pA6wvfCD64VtqlMFXEok4lG47XWWluCLlOBID1HmBXSGd5JMUvvbxNo(pX5EFU2P(djdsCn7oy9q2GtWWjpKytSp4uhOSRNATy(ftDcNexZ9h4kTf4MywGy(fRTE4BHEhq8DhJmTjeZxkIDHy(f7sXuNWjX1CN45cnCw4e3kWnYywGy1Qj2tZADjsigo((JsaNkmO8Xc9e7okIrnXQvtmibGrwigUd5FjaUbGP00jCIBDgK4A2j2vhYSfZcoKCdDhaMcKPHJxcCN4CVpu7u)HKbjUMDhSEiZwml4q(OeWPcdkXcbPBpKo(BWHoMfCiXYtGkgzvRKydIyGnel1qoD3eZTawjXiEwS6xiiDRyQMavmYvbIrq3pKn4emCYd5LIfPMbr)rt3QQGSnIVZGexZoXQvtSNM16sKqmC89hLaovyq5Jf6jMVue7cXUsm)IPoHtIR5(dCL2cCtmlqm)IHtGG0)BE4R(llsXXzG2jOfZVyT1dFl07aIxS7Oi2fI5xSlfdBIHtGG0PHSh7MiJzbDcAXQvtSNM16sKqmC89hLaovyq5Jf6jMVIrnXU6eN79r5N6pKmiX1S7G1dzdobdN8qInXWjqq6pA6wvfxcACNGwm)IHmyqJcK9Yb8IDhfXuCIvNyrQzq0Fc8GHiey4odsCn7oKzlMfCiF00TQkUe04tCU3NQ6u)HKbjUMDhSEiBWjy4KhYlf7xcn(aCDAIpi0CHHe0XSGodsCn7eRwnX(LqJpaxx9QZy0C5xTAgeDgK4A2j2vI5xmgWqm36ogzAtiMVue7Aksm)IHnX(GtDGYUEQ1I5xmCceK(FZdF1Fzrkood0UBvboKdiyiKGokdYH8xcn(aCD1RoJrZLF1QzqCihqWqibDugpp2nzWhsFoKzlMfCir08J2GjsCihqWqibDuWOx8uFi95eN7956DQ)qYGexZUdwpKn4emCYdjobcshxVRtt8rhYzleRwnXqgmOrbYE5aEXUtSRPiXQvtmCceK(FZdF1Fzrkood0obTy(f7sXWjqq6pA6wvfCD64VtqlwTAI12v7wvG(JMUvvbxNo(7q2lhWl2DueZhfj2vhYSfZcoK0Bml4eN79rXDQ)qYGexZUdwpKn4emCYdjobcs)V5HV6VSifhNbANG(qMTywWHexVRRGqaVDIZ9(CDDQ)qYGexZUdwpKn4emCYdjobcs)V5HV6VSifhNbANG(qMTywWHeNHpdRmamN4C)fk6u)HKbjUMDhSEiBWjy4KhsCceK(FZdF1Fzrkood0ob9HmBXSGdjYazC9UUtCU)cFo1FizqIRz3bRhYgCcgo5HeNabP)38Wx9xwKIJZaTtqFiZwml4qMGg)bm1LwQ1N4C)fxCQ)qYGexZUdwpKzlMfCijEUmb79hsh)n4qhZcoKkGrscDigsQ14zRIyilumIpX1SytWEp1rmQ)ZIPAcuXiV5HV6xSfrmfWzG2pKn4emCYdjobcs)V5HV6VSifhNbANGwSA1edzWGgfi7Ld4f7oXUqrN4ehYp4uhOLM7p1FU3Nt9hsgK4A2DW6HCPpKphhYSfZcoKQt4K4A(qQo1e8HSTR2TQa9hnDRQIlbnU3qtig(liWSfZcsTy(srmF6xpLFiD83GdDml4qQyL10mumQ7eojUMpKQtybKE8H8rDLafYp6QDN4C)fN6pKmiX1S7G1dz2Izbhs1jyE0dPJ)gCOJzbhsQ7empQydIyQyXsilwlPPhagXwGykibnwSgAcXWFxmfljuFtmCgzHSyid8dXCjOXIniIPIfdnvZIbwXUFWGgFK6kmumCIqmfKWkIrIMUvLydqSf6yOyXkggoedlqqheqwmcAXUeSIPyYpyOyyX)Z)hWv9dzdobdN8qEPyytm1jCsCn3FuxjqH8JUANy1Qjg2elsndIoyWGgFK6kmSZGexZoX8lwKAgeDxcRuE00TQ6miX1StSReZVyT1dFl07aIV7yKPnHy(kMpI5xmSjgKaWiled39syLYIucuU4LFWWs(F()a6miX1S7eN7V2P(djdsCn7oy9q64Vbh6ywWHuH3vlgYcfJenDRkpw7eRoXirt3Q6d4uHfJaO5)ftflwczXs8LielwXAjTylqmfKGglwdnHy4Vl21nqFtmvOmqSQEaoXWYCwbW)l28IL4lriwSIbjaITer)qISWcGvwCU3NdzdobdN8qcZg3bdg0OWAKdjRSaML0BjaXHKAk6qMTywWHKExDbY)saB8jo3tTt9hsgK4A2DW6HSbNGHtEizadXCtmFPig1uKy(fJbmeZTUJrM2eI5lfX8rrI5xmSjM6eojUM7pQReOq(rxTtm)I1wp8TqVdi(UJrM2eI5Ry(CiZwml4q(OPBv5XA3jo3R8t9hsgK4A2DW6HCPpKphhYSfZcoKQt4K4A(qQo1e8HSTE4BHEhq8DhJmTjeZxkIDHy1jgobcs)rt3QQGRth)Dc6dPJ)gCOJzbhYQRWIfOq(rxT7fdzHIXGGHdaJyKOPBvjMcsqJpKQtybKE8H8rDL26HVf6DaXFIZ9v1P(djdsCn7oy9qU0hYNJdz2Izbhs1jCsCnFivNAc(q2wp8TqVdi(UJrM2eI5lfXU2HSbNGHtEiBRAgKGOx5gCsWHuDclG0JpKpQR0wp8TqVdi(tCU)6DQ)qYGexZUdwpKl9H854qMTywWHuDcNexZhs1PMGpKT1dFl07aIV7yKPnHy3rrmFoKn4emCYdP6eojUM7epxOHZcN4wbUrgZceZVypnR1LiHy447pkbCQWGYhl0tmFPig1oKQtybKE8H8rDL26HVf6DaXFIZ9kUt9hsgK4A2DW6HmBXSGd5JMUvvXLGgFiD83GdDml4qQGe0yXCeWbGrmYBE4R(fBHIL4RAwSafYp6QD9dzdobdN8qEPyxkM6eojUM7pQR0wp8TqVdiEXQvtm1jCsCn3FuxjqH8JUANyxjMFXEok4lG47XWWluCLlOBI5xS2QMbji6vUbNeiwTAIPoHtIR5(J6kT1dFl07aIxm)IDPy4eii9)Mh(Q)YIuCCgODi7Ld4fZxkI5t)cXQvtm1jCsCn3FuxjqH8JUANyxjwTAIHtGG0BO5(f8eWDcAXQvtSNM16sKqmC89hLaovyq5Jf6jMVueJAI5xS2UA3Qc0)BE4R(llsXXzG2HSxoGxmFfZhfj2vI5xSlfdNabPtZqKfMb7kQ5b89pYwfXUtmQjwTAI90SwxIeIHJV)OeWPcdkFSqpX8vSRj2vN4C)11P(djdsCn7oy9qMTywWH8rt3QQ4sqJpKo(BWHoMfCiXkbeiMcsqJFXAOjed)IniIDBjeJwN3etbjSIyKOPBv9yhlQZgCIBITqXWzKfYIfOSyidg0qmg4EXgeXixfiMQfuTqmCwmiNUBInaXIXJ7hYgCcgo5HuDcNexZ9h1vARh(wO3beVy(fdzWGgfi7Ld4f7oXA7QDRkq)V5HV6VSifhNbAhYE5aEXQvtmSjwKAgeDgOM1l9aWuE00TQ(odsCn7oXjoKidyE0t9N795u)HKbjUMDhSEix6d5ZXHmBXSGdP6eojUMpKQtnbFiJuZGOtdzp2nrgZc6miX1Stm)I90SwxIeIHJV)OeWPcdkFSqpXUtSlft5IPqI1w1mibrhWn4QxOtSReZVyytS2QMbji6vUbNeCiD83GdDml4qILrhnlgXpamIPWq2JDtKXSaLelvVJtSw(XaWigPEASyjWjMcMglMkugigjA6wvIPGe0yXMxSFxGyXkgolgXZoLeJvwJPdXqwOyxhVbNeCivNWci94djnK9yx5bUsBbUjMfCIZ9xCQ)qYGexZUdwpKn4emCYdj2etDcNexZDAi7XUYdCL2cCtmlqm)I90SwxIeIHJV)OeWPcdkFSqpXUtSQsm)IHnXWjqq6pA6wvfxcACNGwm)IHtGG0F904scCf304oK9Yb8IDNyidg0OazVCaVy(fdYiq(rtCnFiZwml4q(6PXLe4kUPXN4C)1o1FizqIRz3bRhYgCcgo5HuDcNexZDAi7XUYdCL2cCtmlqm)I12v7wvG(JMUvvXLGg3BOjed)fey2IzbPwS7eZN(1t5I5xmCceK(RNgxsGR4Mg3HSxoGxS7eRTR2TQa9)Mh(Q)YIuCCgODi7Ld4fZVyxkwBxTBvb6pA6wvfxcAChYP7My(fdNabP)38Wx9xwKIJZaTdzVCaVykKy4eii9hnDRQIlbnUdzVCaVy3jMp9le7Qdz2IzbhYxpnUKaxXnn(eN7P2P(djdsCn7oy9qU0hYNJdz2Izbhs1jCsCnFivNAc(q6LFWWs(F()akq2lhWlMVIPiXQvtmSjwKAgeDWGbn(i1vyyNbjUMDI5xSi1mi6UewP8OPBv1zqIRzNy(fdNabP)OPBvvCjOXDcAXQvtSNM16sKqmC89hLaovyq5Jf6jMVue7sXOMykKyFWPoqzxp1AXu8IfPMbr)rt3QQGSnIVZGexZoXU6q64Vbh6ywWHuXkRPzOyu3jCsCnlgYcfdlqqheqUlgzLHwmhbCayetXKFWqXWI)N)paXwOyoc4aWiMcsqJft1eOIPGewrSe4edSID)Gbn(i1vyy)qQoHfq6XhYVYqxGe0bbKpX5ELFQ)qYGexZUdwpKzlMfCiHe0bbKpKo(BWHoMfCiVoYmTye0IHfiOdcil2Gi2eInVyj(seIfRyqcGylr0pKn4emCYdj2e7do1bk76PwlMFXUumSjM6eojUM7FLHUajOdcilwTAIPoHtIR5oXZfA4SWjUvGBKXSaXUsm)Ifjedh9y84sSf3WIPqIbzVCaVy(kwvjMFXGmcKF0exZN4CFvDQ)qMTywWH85gKJsWnuWCDsWhsgK4A2DW6jo3F9o1FizqIRz3bRhYSfZcoKqc6GaYhY2TMMlrcXWXFU3NdzdobdN8qInXuNWjX1C)Rm0fibDqazX8lg2etDcNexZDINl0WzHtCRa3iJzbI5xSNM16sKqmC89hLaovyq5Jf6jMVue7cX8lwKqmC0JXJlXwCdlMVue7sXuUy1j2LIDHykEXARh(wO3beVyxj2vI5xmiJa5hnX18H0XFdo0XSGdPIHqhJBJyayelsigoEXc0met1O1IPh1SyiluSaLfZraZywGylIyybc6GaYkjgKrG8JkMJaoamIrNah7nT(jo3R4o1FizqIRz3bRhYSfZcoKqc6GaYhsh)n4qhZcoKybgbYpQyybc6GaYIXjuFtSbrSjet1O1IXkJEGSyoc4aWig5np8v)DXuWkwGMHyqgbYpQydIyKRceddhVyqoD3eBaIfOSyawzHyk)7hYgCcgo5HeBIPoHtIR5(xzOlqc6GaYI5xmi7Ld4f7oXA7QDRkq)V5HV6VSifhNbAhYE5aEXQtmFuKy(fRTR2TQa9)Mh(Q)YIuCCgODi7Ld4f7okIPCX8lwKqmC0JXJlXwCdlMcjgK9Yb8I5RyTD1UvfO)38Wx9xwKIJZaTdzVCaVy1jMYpX5(RRt9hsgK4A2DW6HSbNGHtEiXMyQt4K4AUt8CHgolCIBf4gzmlqm)I90SwxIeIHJxmFPi21oKzlMfCiX1zRsHEv5y4jo37JIo1FiZwml4qYQNVXWm4djdsCn7oy9eN4ehs1m8NfCU)cfDXfk6Ak6IdPQecgaM)qILXIyH7V(3RytDetS6rzXgp6fgIHSqXQ2hCQdu2vnXG81jXazNy)6XILeX6Lb7eRHMam83fQOEdGft5uhXQ(cuZWGDIvnibGrwigUJLQMyXkw1GeagzHy4owQZGexZUQj2L(OSR6cvuVbWIP4OoIv9fOMHb7eRAqcaJSqmChlvnXIvSQbjamYcXWDSuNbjUMDvtSl9rzx1fQeQWYyrSW9x)7vSPoIjw9OSyJh9cdXqwOyvJgYT1dpJQjgKVojgi7e7xpwSKiwVmyNyn0eGH)Uqf1BaSyxJ6iw1xGAggStSQ9lHgFaUowQAIfRyv7xcn(aCDSuNbjUMDvtSl9rzx1fQOEdGf7AuhXQ(cuZWGDIvTFj04dW1XsvtSyfRA)sOXhGRJL6miX1SRAILHykwUUPEIDPpk7QUqf1BaSyxpQJyvFbQzyWoXQgKaWiled3XsvtSyfRAqcaJSqmChl1zqIRzx1eldXuSCDt9e7sFu2vDHkHkSmwelC)1)EfBQJyIvpkl24rVWqmKfkw1AUVAIb5RtIbYoX(1JfljI1ld2jwdnby4Vlur9galg1OoIv9fOMHb7eRAqcaJSqmChlvnXIvSQbjamYcXWDSuNbjUMDvtSlVqzx1fQOEdGfRQOoIv9fOMHb7eRAqcaJSqmChlvnXIvSQbjamYcXWDSuNbjUMDvtSl9rzx1fQOEdGfZNRrDeR6lqndd2jw1GeagzHy4owQAIfRyvdsayKfIH7yPodsCn7QMyx6JYUQlur9galMpvf1rSQVa1mmyNyv7xcn(aCDSu1elwXQ2VeA8b46yPodsCn7QMyxEHYUQlujuHLXIyH7V(3RytDetS6rzXgp6fgIHSqXQ2hCQd0sZ9vtmiFDsmq2j2VESyjrSEzWoXAOjad)DHkQ3ayXUG6iw1xGAggStSQbjamYcXWDSu1elwXQgKaWiled3XsDgK4A2vnXYqmflx3upXU0hLDvxOsOclJfXc3F9VxXM6iMy1JYInE0lmedzHIvnCIr7QMyq(6KyGStSF9yXsIy9YGDI1qtag(7cvuVbWI5d1rSQVa1mmyNyvdsayKfIH7yPQjwSIvnibGrwigUJL6miX1SRAIDPpk7QUqf1BaSykN6iw1xGAggStSQfJhxIT8Orhl1P1eF1elwXQwmECj2YJgfAnX3XsvtSlVqzx1fQeQU(E0lmyNyxpXYwmlqm98X3fQoKpn3o3Frv5ZHKgUiJMpKvPkIrsGhAoUjgwyXqWcvvPkIPysydvSlusSlu0fxiujuvLQiw1rtag(PocvvPkIPqIPyw1SyQt4K4AUt8CHgolCIBf4gzmlqmcAX(vSjeBEXEoedNrwilMkwmINfBIUqvvQIykKyvF9WhalMhHogAnlwl16s2Izbf98HymiGd)IfRyq2r0yXO3GbXKAXGSQfwPluvLQiMcjMIjRWIv1A(rBWejeBabdHe0HydqS26HNHydIyQyXOUq8HyUXj2eIHSqXuV6mgnx(vRMbrxOsOQkvrmfgYku1xp8meQYwml470qUTE4zuhfSN006Bf6D(fiuLTywW3PHCB9WZOokyhFJqZUcIoVXovdatjwLnaHQSfZc(onKBRhEg1rb7iA(rBWejuAqO8lHgFaUonXheAUWqc6ywqTA)sOXhGRRE1zmAU8RwndcHQSfZc(onKBRhEg1rb7FWPoqfQYwml470qUTE4zuhfS7LWkSRGSWIJZavjAi3wp8mkp3wG7P4JYfQYwml470qUTE4zuhfS)6PXLe4kUPXkrd526HNr552cCpfFuAqOazei)OjUMfQYwml470qUTE4zuhfS)OPBvvW1PJFLgekqcaJSqmC3lHvklsjq5Ix(bdl5)5)dqOsOQkvrmftoaXWcBKXSaHQSfZcEkvMwfHQQig1)zNyXkMJdg6nawmvOCGYqXA7QDRkWlMQCcXqwOyKafigE(StSfiwKqmC8DHQSfZc(6OGD1jCsCnRei9ykpWvAlWnXSaLuNAcMcobcs)1tJljWvCtJ7e01Q90SwxIeIHJV)OeWPcdkFSqpFPuvcvzlMf81rb7Qt4K4Awjq6XuEGR0wGBIzbkPo1emfCceK(RNgxsGR4Mg3jORv7PzTUejedhF)rjGtfgu(yHE(sPQeQQIyvhLBvelwXEMfBqelqzXaSYcXQUcl2LdqSaLfJvZGqSfrSums06fJgUTReBEXWIGXlBOjed7eQYwml4RJc2vNWjX1SsG0JPmFbWklkn6scgVSHMqmStPbHsBvZGee9k3GtcusDQjykT1dFl07aINIp(Xjqq6CdDhaMcKPHJxcCLl6e01Q1wp8TqVdiEkx4hNabPZn0DaykqMgoEjWvUwNGUwT26HVf6DaXt5A(Xjqq6CdDhaMcKPHJxcCfQ1jORvRTE4BHEhq8uOMFCceKo3q3bGPazA44Laxr5DcAHQQigwS1wcqigYcfJeTEXGC2IzbIfJhlg(nXgmGfoamIPxvku1vyXsW4Ln0eIHDI5LrdLFXgGybklMI6k)fJgYnMDdaJyPy0BWGysTyKO1lgnCBcvzlMf81rb7Qt4K4Awjq6XuyeeUfJAU0wp8TqVdiELuNAcMcJGWTyuZL26HVf6DaXluLTywWxhfSRoHtIRzLaPhtHrq4wmQ5sB9W3c9oG4vAqO0w1mibrVYn4Ka)mcc3IrnxARh(wO3beVVT1dFl07aI3FB9W3c9oG47ogzAt47f(JXJlXwE0OqRj(o1UtrDL7hBQt4K4AUpFbWklkn6scgVSHMqmStj1PMGP0wp8TqVdiEHQQiw1r5wfXQUcEXYqmKb(Hqv2IzbFDuWEl16s2Izbf98HsG0JP0CVqvvedlstRVjgPEASyjWjMcMglwgIDrDIvDfwmhbCayelqzXqg4hI5JIe752cCVsILibdflqZqmQvNyvxHfBqeBcXyLrpq(ft1eOdqSaLfdWkletXU6kqSfk28Ib2qmcAHQSfZc(6OG9xpnUKaxXnnwPbHYtZADjsigo((JsaNkmO8Xc9URQ8JmyqJcK9Yb8(wv(Xjqq6VEACjbUIBAChYE5a(7W0CDVuz(BRh(wO3beVVuOMcDzmE8D(OORu8xiuvfXUUb6BI1qtagwm4gzmlqSbrmvSyOPAwmA4SWjUvGBKXSaXEoelboX8i0XqRzXIeIHJxmc6Uqv2IzbFDuWU6eojUMvcKEmfINl0WzHtCRa3iJzbkPo1emfA4SWjUvGBKXSa)pnR1LiHy447pkbCQWGYhl0ZxkxiuvfXWceaXqi06BI9QMOHYVyXkwGYIrgCQdu2jgwyJmMfi2L43eZTdaJy)QKytigYcB8lg9U6bGrSbrmWgOdaJyZlwQohDIR5R6cvzlMf81rb7qcqjBXSGIE(qjq6Xu(GtDGYoLgekFWPoqzxp1AHQQiMcdNfoXnXWcBKXSGRdIr94OAVyyg1SyPynyslwIVeHymGHyUjgYcflqzX(GtDGkw1vWl2L4eJ2XqX(y0AXG8tZTqSjUQlg11e0kj2eI1sGy4SybAgI9JhTM7cvzlMf81rb7TuRlzlMfu0ZhkbspMYhCQd0sZ9kniuuNWjX1CN45cnCw4e3kWnYywGqvveJ6)StSyfZXidGftfkdelwXiEwSp4uhOIvDf8ITqXWjgTJHVqv2IzbFDuWU6eojUMvcKEmLp4uhOLafYp6QDkPo1emLluEDrQzq0vpywyNbjUMDk(luuDrQzq09YpyyzrkpA6wvFNbjUMDk(luuDrQzq0F00TQkiBJ47miX1StXFHYRlsndIEQZgCIBDgK4A2P4Vqr1DHYv8x(0SwxIeIHJV)OeWPcdkFSqpFPqTReQQIyvFb)4yOye)aWiwkgzWPoqfR6kqmvOmqmiNn0bGrSaLfJbmeZnXcui)OR2juLTywWxhfS3sTUKTywqrpFOei9ykFWPoqln3R0GqHbmeZTUJrM2e3rrDcNexZ9p4uhOLafYp6QDcvvrSQEaZJkwgI5LktjXOwDIPAc0LietbKITqXunbQyKRceRbNqmCceeLet51jMQjqftbKID5se)4yX(GtDGEf1vft1eOIPasXs9VIHmG5rfldXOwDILyYb8HyutSiHy44f7YLi(XXI9bN6a9kHQSfZc(6OG9wQ1LSfZck65dLaPhtbzaZJQ0GqrDcNexZDgbHBXOMlT1dFl07aI3xkn6IxQSYtZaxTAT1dFl07aIV7yKPnXDu8PwnKbdAuGSxoG)ok(4xDcNexZDgbHBXOMlT1dFl07aI3xkxRwnCceK(FZdF1Fzrkood0sseBdorNG2V6eojUM7mcc3IrnxARh(wO3beVVuOwTApnR1LiHy447pkbCQWGYhl0ZxkuZV6eojUM7mcc3IrnxARh(wO3beVVuOMqvveJ6)SyPy4eJ2XqXuHYaXGC2qhagXcuwmgWqm3elqH8JUANqv2IzbFDuWEl16s2Izbf98HsG0JPGtmANsdcfgWqm36ogzAtChf1jCsCn3)GtDGwcui)OR2juvfXOERk(dXOHZcN4MydqSuRfBrelqzXWIkm1tmCULepl2eI1sINFXsXuSRUceQYwml4RJc2tylbCjwiKbHsdcfgWqm36ogzAt4lfFuEDmGHyU1HmggiuLTywWxhfSNWwc4cnH(zHQSfZc(6OGD9Gbn(c1fchgpgecvzlMf81rb74jMYIuc40Q8cvcvvPkIHvIr7y4luLTywW3XjgTJYJoQvAqOGTi1mi6GbdA8rQRWWodsCn78djamYcXW9ya3kXQSPvW1PJ9)0SwxIeIHJV)OeWPcdkFSqV7uUqv2IzbFhNy0U6OG9hLaovyq5Jf6P0Gq5PzTUejedhVVuUW)LyRTQzqcIoGBWvVqxTATD1UvfO)meMb7k4lGlp9uH7EPYkn0eIHFfQHMqm8xqGzlMfKAFPOO(fkVwTNM16sKqmC89hLaovyq5Jf65l1UY)L4eiiDAgISWmyxrnpGV)r2QChfQvR2tZADjsigo((JsaNkmO8Xc98LAxjuLTywW3XjgTRoky)zimd2vWxaxE6PcR0GqbNabPtZqKfMb7kQ5b89pYwL7OCH)lB7QDRkq)zimd2vWxaxE6Pc39sLvAOjed)kudnHy4VGaZwmli13rrr9luETA)sOXhGRR50vWVvyLLE0AUZGexZo)ydNabPR50vWVvyLLE0AUtqxR2VeA8b46vy1d4l7sDfwpamDgK4A25hBogNabPxHvpGVOcMbANG(kHQSfZc(ooXOD1rb7y076HRthluvfXWA2Q8rIl245XUjdwFtmcGM)xSaLfdWkleR6kSyZlgwemEzdnHyyNyjWjMkwmvlOAHyTKwmgWqm3etvoXaWigYcfBIUqv2IzbFhNy0U6OGD8Sv5JexPbHc2ARAgKGOx5gCsqTAy7s1jCsCn3NVayLfLgDjbJx2qtig25)Yy84sSLhn6xRtRj(7uux51QfJhxIT8OrNADAnXFNpx5NbmeZT7QkfDLqLqvveR67QDRkWluvfXO(plMcsqJfBrquimnNy4mYczXcuwmKb(HyKOeWPcdeJmwONyiW1tS6xiiDRyT1JFXgqxOkBXSGV3CpLhnDRQIlbnwjINllcsbtZrXhLgekydNabP)OPBvvCjOXDcA)4eii9hLaovyqjwiiDBNG2pobcs)rjGtfguIfcs32HSxoG)okxRRCHQQi2LuFGM)xSud50DtmcAXW5ws8SyQyXIDRigjA6wvIv1BJ4VsmINfJ8Mh(QFXweefctZjgoJSqwSaLfdzGFigjkbCQWaXiJf6jgcC9eR(fcs3kwB94xSb0fQYwml47n3xhfS)38Wx9xwKIJZavjINllcsbtZrXhLgek4eii9hLaovyqjwiiDBNG2pobcs)rjGtfguIfcs32HSxoG)okxRRCHQSfZc(EZ91rb7i6edR1zmlqPbHI6eojUM7pWvAlWnXSa)y7do1bk76Eji0S)lFAwRlrcXWX3Fuc4uHbLpwO3Du8XFBxTBvb6)np8v)LfP44mq7e0(XwKAge9hnDRQcY2i(odsCn7QvdNabP)38Wx9xwKIJZaTtqFL)26HVf6DaX7lfLluLTywW3BUVokyxDcMhvPbHYLqcaJSqmC3lHvklsjq5Ix(bdl5)5)dWFB9W3c9oG47ogzAtChfFuOi1mi6oMPzy5dygmg2RZGexZUA1GeagzHy4UJZavFR8OPBv9(BRh(wO3be)D(CLFCceK(FZdF1Fzrkood0obTFCceK(JMUvvXLGg3jO97LFWWs(F()akq2lhWtrr(Xjqq6oodu9TYJMUv13DRkGqvvetH3vlgYcfR(fcs3kgnKviYvbIPAcuXirvGyqoD3etfkdedSHyqcayayeJSQ7cvzlMf89M7RJc2P3vxG8VeWgReYclawzbfFuAqOePMbr)rjGtfguIfcs32zqIRzNFSfPMbr)rt3QQGSnIVZGexZoHQQig1)zXQFHG0TIrdzXixfiMkugiMkwm0unlwGYIXagI5MyQq5aLHIHaxpXO3vpamIPAc0LieJSQfBHIrDH4dXWWagMA9TUqv2IzbFV5(6OG9hLaovyqjwiiDRsdcLNM16sKqmC89hLaovyq5Jf6DhfF8ZagI5MVuQkf5xDcNexZ9h4kTf4MywG)2UA3Qc0)BE4R(llsXXzG2jO932v7wvG(JMUvvXLGg3BOjed)(sXh)xInibGrwigUV4SByqJRvZX4eiiDeDIH16mMf0jORv7PzTUejedhF)rjGtfgu(yHE(s5sFQJAk(lXwKAgeDWGbn(i1vyyNbjUMD(XwKAgeDxcRuE00TQ6miX1S7QRUYFB9W3c9oG4VJYf(XgobcsNgYESBImMf0jO9Fj2ARAgKGORMbb6nyTAyRTR2TQaDeDIH16mMf0jOVsOkBXSGV3CFDuW(ZqygSRGVaU80tfwP2TMMlrcXWXtXhLgekQt4K4AU)axPTa3eZc8Jn3g9NHWmyxbFbC5PNkCXTrpMwLbGXFKqmC0JXJlXwCd7lLl8X)LT1dFl07aIV7yKPnHVuUSrxWKdW3Rdu7QR8JnCceK(JsaNkmOeleKUTtq7)sSHtGG0PHSh7MiJzbDc6A1EAwRlrcXWX3Fuc4uHbLpwONVu7QA1qgmOrbYE5a(7OOC)pnR1LiHy447pkbCQWGYhl07URjuLTywW3BUVoky)z6FELgekQt4K4AU)axPTa3eZc83wp8TqVdi(UJrM2e(sXh)rcXWrpgpUeBXnSVu8PQeQQIyu)NfJ8Mh(QFXwGyTD1UvfqSltKGHIHmWpeJeOGReJaO5)ftflwczXWSdaJyXkg9slw9leKUvSe4eZTIb2qm0unlgjA6wvIv1BJ47cvzlMf89M7RJc2)BE4R(llsXXzGQ0GqrDcNexZ9h4kTf4MywG)lXwKAge9hLaovyqjwiiDBNbjUMD1QfPMbr)rt3QQGSnIVZGexZUA1EAwRlrcXWX3Fuc4uHbLpwONVuUOwT2UA3Qc0Fuc4uHbLyHG0TDi7Ld499IR8Fj2ARAgKGORMbb6nyTATD1UvfOJOtmSwNXSGoK9Yb8(6JIQvRTR2TQaDeDIH16mMf0jO93wp8TqVdiEFPO8ReQQIyxFeXsN7flHSye0kj2dgAwSaLfBbSyQMavm9QI)qS6RxbDXO(plMkugiM72aWigs(bdflqtGyvxHfZXitBcXwOyGne7do1bk7et1eOlriwcUjw1v4Uqv2IzbFV5(6OGDVewHDfKfwCCgOkPhaxAok(0vUsTBnnxIeIHJNIpkniuG54kSAge905(obT)lJeIHJEmECj2IB47ARh(wO3beF3XitBIA1W2hCQdu21tT2FB9W3c9oG47ogzAt4lLgDXlvw5PzG7kHQQi21hrmWkw6CVyQgTwm3WIPAc0biwGYIbyLfIDnf9kjgXZIPyquGylqm89FXunb6seILGBIvDfUluLTywW3BUVoky3lHvyxbzHfhNbQsdcfyoUcRMbrpDUVpaFVMIuiyoUcRMbrpDUV7iGzmlWFB9W3c9oG47ogzAt4lLgDXlvw5PzGtOkBXSGV3CFDuW(JMUvvbxNo(vAqOOoHtIR5(dCL2cCtmlWFB9W3c9oG47ogzAt4lLl8Fjobcs)V5HV6VSifhNbANGUwn89F)idg0OazVCa)DuUqr1QHnCceK(JMUvvbxNo(7e0(Fok4lG47XWWluCLlOBxjuLTywW3BUVokyNBO7aWuGmnC8sGtPbHc2(GtDGYUEQ1(vNWjX1C)bUsBbUjMf4VTE4BHEhq8DhJmTj8LYf(VuDcNexZDINl0WzHtCRa3iJzb1Q90SwxIeIHJV)OeWPcdkFSqV7OqTA1GeagzHy4oK)La4gaMstNWjUDLqvvedlpbQyKvTsIniIb2qSud50Dtm3cyLeJ4zXQFHG0TIPAcuXixfigbDxOkBXSGV3CFDuW(JsaNkmOeleKUvPbHYLrQzq0F00TQkiBJ47miX1SRwTNM16sKqmC89hLaovyq5Jf65lLlUYV6eojUM7pWvAlWnXSa)4eii9)Mh(Q)YIuCCgODcA)T1dFl07aI)okx4)sSHtGG0PHSh7MiJzbDc6A1EAwRlrcXWX3Fuc4uHbLpwONVu7kHQSfZc(EZ91rb7pA6wvfxcASsdcfSHtGG0F00TQkUe04obTFKbdAuGSxoG)okkU6IuZGO)e4bdriWWDgK4A2juLTywW3BUVokyhrZpAdMiHsdcLl)LqJpaxNM4dcnxyibDmlOwTFj04dW1vV6mgnx(vRMbXv(zadXCR7yKPnHVuUMI8JTp4uhOSRNATFCceK(FZdF1Fzrkood0UBvbuAabdHe0rz88y3KbtXhLgqWqibDuWOx8utXhLgqWqibDugek)sOXhGRRE1zmAU8RwndcHQSfZc(EZ91rb70BmlqPbHcobcshxVRtt8rhYzlQvdzWGgfi7Ld4V7AkQwnCceK(FZdF1Fzrkood0obT)lXjqq6pA6wvfCD64VtqxRwBxTBvb6pA6wvfCD64VdzVCa)Du8rrxjuLTywW3BUVokyhxVRRGqaVP0GqbNabP)38Wx9xwKIJZaTtqluLTywW3BUVokyhNHpdRmamkniuWjqq6)np8v)LfP44mq7e0cvzlMf89M7RJc2rgiJR31P0GqbNabP)38Wx9xwKIJZaTtqluLTywW3BUVokypbn(dyQlTuRvAqOGtGG0)BE4R(llsXXzG2jOfQQIykGrscDigsQ14zRIyilumIpX1SytWEp1rmQ)ZIPAcuXiV5HV6xSfrmfWzG2fQYwml47n3xhfSt8Czc27vAqOGtGG0)BE4R(llsXXzG2jORvdzWGgfi7Ld4V7cfjujuvLQiwvpG5rz4luvfXWYOJMfJ4hagXuyi7XUjYywGsILQ3Xjwl)yayeJupnwSe4etbtJftfkdeJenDRkXuqcASyZl2VlqSyfdNfJ4zNsIXkRX0HyiluSRJ3GtceQYwml47idyEukQt4K4Awjq6XuOHSh7kpWvAlWnXSaLuNAcMsKAgeDAi7XUjYywqNbjUMD(FAwRlrcXWX3Fuc4uHbLpwO3DxQCfQTQzqcIoGBWvVq3v(XwBvZGee9k3GtceQYwml47idyE06OG9xpnUKaxXnnwPbHc2uNWjX1CNgYESR8axPTa3eZc8)0SwxIeIHJV)OeWPcdkFSqV7Qk)ydNabP)OPBvvCjOXDcA)4eii9xpnUKaxXnnUdzVCa)Didg0OazVCaVFiJa5hnX1Sqv2IzbFhzaZJwhfS)6PXLe4kUPXkniuuNWjX1CNgYESR8axPTa3eZc832v7wvG(JMUvvXLGg3BOjed)fey2IzbP(oF6xpL7hNabP)6PXLe4kUPXDi7Ld4VRTR2TQa9)Mh(Q)YIuCCgODi7Ld49FzBxTBvb6pA6wvfxcAChYP7MFCceK(FZdF1Fzrkood0oK9Yb8keobcs)rt3QQ4sqJ7q2lhWFNp9lUsOQkIPyL10mumQ7eojUMfdzHIHfiOdci3fJSYqlMJaoamIPyYpyOyyX)Z)hGylumhbCayetbjOXIPAcuXuqcRiwcCIbwXUFWGgFK6kmSluLTywW3rgW8O1rb7Qt4K4Awjq6Xu(kdDbsqheqwj1PMGP4LFWWs(F()akq2lhW7RIQvdBrQzq0bdg04JuxHHDgK4A25psndIUlHvkpA6wvDgK4A25hNabP)OPBvvCjOXDc6A1EAwRlrcXWX3Fuc4uHbLpwONVuUKAk0hCQdu21tTwXhPMbr)rt3QQGSnIVZGexZUReQQIyxhzMwmcAXWce0bbKfBqeBcXMxSeFjcXIvmibqSLi6cvzlMf8DKbmpADuWoKGoiGSsdcfS9bN6aLD9uR9Fj2uNWjX1C)Rm0fibDqa5A1uNWjX1CN45cnCw4e3kWnYywWv(JeIHJEmECj2IByfcYE5aEFRk)qgbYpAIRzHQSfZc(oYaMhToky)5gKJsWnuWCDsWcvvrmfdHog3gXaWiwKqmC8IfOziMQrRftpQzXqwOybklMJaMXSaXweXWce0bbKvsmiJa5hvmhbCayeJobo2BADHQSfZc(oYaMhTokyhsqheqwP2TMMlrcXWXtXhLgekytDcNexZ9VYqxGe0bbK9Jn1jCsCn3jEUqdNfoXTcCJmMf4)PzTUejedhF)rjGtfgu(yHE(s5c)rcXWrpgpUeBXnSVuUu51D5fk(26HVf6DaXF1v(HmcKF0exZcvvrmSaJa5hvmSabDqazX4eQVj2Gi2eIPA0AXyLrpqwmhbCayeJ8Mh(Q)UykyflqZqmiJa5hvSbrmYvbIHHJxmiNUBInaXcuwmaRSqmL)DHQSfZc(oYaMhTokyhsqheqwPbHc2uNWjX1C)Rm0fibDqaz)q2lhWFxBxTBvb6)np8v)LfP44mq7q2lhWxNpkYFBxTBvb6)np8v)LfP44mq7q2lhWFhfL7psigo6X4XLylUHvii7Ld49TTR2TQa9)Mh(Q)YIuCCgODi7Ld4Rt5cvzlMf8DKbmpADuWoUoBvk0RkhdvAqOGn1jCsCn3jEUqdNfoXTcCJmMf4)PzTUejedhVVuUMqv2IzbFhzaZJwhfSZQNVXWmyHkHQQufXido1bQyvFxTBvbEHQQiMIvwtZqXOUt4K4AwOkBXSGV)bN6aT0Cpf1jCsCnRei9ykpQReOq(rxTtj1PMGP02v7wvG(JMUvvXLGg3BOjed)fey2IzbP2xk(0VEkxOQkIrDNG5rfBqetflwczXAjn9aWi2cetbjOXI1qtig(7IPyjH6BIHZilKfdzGFiMlbnwSbrmvSyOPAwmWk29dg04JuxHHIHteIPGewrms00TQeBaITqhdflwXWWHyybc6GaYIrql2LGvmft(bdfdl(F()aUQluLTywW3)GtDGwAUVokyxDcMhvPbHYLytDcNexZ9h1vcui)OR2vRg2IuZGOdgmOXhPUcd7miX1SZFKAgeDxcRuE00TQ6miX1S7k)T1dFl07aIV7yKPnHV(4hBqcaJSqmC3lHvklsjq5Ix(bdl5)5)dqOQkIPW7QfdzHIrIMUvLhRDIvNyKOPBv9bCQWIra08)IPIflHSyj(seIfRyTKwSfiMcsqJfRHMqm83f76gOVjMkugiwvpaNyyzoRa4)fBEXs8LielwXGeaXwIOluLTywW3)GtDGwAUVokyNExDbY)saBSsilSayLfu8rjwzbmlP3sackutrkniuGzJ7GbdAuynIqv2IzbF)do1bAP5(6OG9hnDRkpw7uAqOWagI5MVuOMI8ZagI5w3XitBcFP4JI8Jn1jCsCn3FuxjqH8JUAN)26HVf6DaX3DmY0MWxFeQQIyvxHflqH8JUA3lgYcfJbbdhagXirt3QsmfKGgluLTywW3)GtDGwAUVokyxDcNexZkbspMYJ6kT1dFl07aIxj1PMGP0wp8TqVdi(UJrM2e(s5I6Wjqq6pA6wvfCD64VtqluLTywW3)GtDGwAUVokyxDcNexZkbspMYJ6kT1dFl07aIxj1PMGP0wp8TqVdi(UJrM2e(s5AkniuARAgKGOx5gCsGqv2IzbF)do1bAP5(6OGD1jCsCnRei9ykpQR0wp8TqVdiELuNAcMsB9W3c9oG47ogzAtChfFuAqOOoHtIR5oXZfA4SWjUvGBKXSa)pnR1LiHy447pkbCQWGYhl0ZxkutOQkIPGe0yXCeWbGrmYBE4R(fBHIL4RAwSafYp6QDDHQSfZc((hCQd0sZ91rb7pA6wvfxcASsdcLlVuDcNexZ9h1vARh(wO3beFTAQt4K4AU)OUsGc5hD1UR8)CuWxaX3JHHxO4kxq383w1mibrVYn4KGA1uNWjX1C)rDL26HVf6DaX7)sCceK(FZdF1Fzrkood0oK9Yb8(sXN(f1QPoHtIR5(J6kbkKF0v7UQwnCceKEdn3VGNaUtqxR2tZADjsigo((JsaNkmO8Xc98Lc1832v7wvG(FZdF1Fzrkood0oK9Yb8(6JIUY)L4eiiDAgISWmyxrnpGV)r2QCh1Qv7PzTUejedhF)rjGtfgu(yHE(ETReQQIyyLacetbjOXVyn0eIHFXgeXUTeIrRZBIPGewrms00TQESJf1zdoXnXwOy4mYczXcuwmKbdAigdCVydIyKRcet1cQwigolgKt3nXgGyX4XDHQSfZc((hCQd0sZ91rb7pA6wvfxcASsdcf1jCsCn3FuxPTE4BHEhq8(rgmOrbYE5a(7A7QDRkq)V5HV6VSifhNbAhYE5a(A1WwKAgeDgOM1l9aWuE00TQ(odsCn7eQeQQsveJm4uhOStmSWgzmlqOQkID9reJm4uhOyxDcMhvSeYIrqRKyeplgjA6wvFaNkSyXkgodyKjedbUEIfOSy05)JAwm8fq8ILaNyv9aCIHL5ScG)xjXy1mqSbrmvSyjKfldX8sLjw1vyXUKaO5)fJ4hagXum5hmumS4)5)d4kHQSfZc((hCQdu2r5rt3Q6d4uHvAqOCjobcs)do1bANGUwnCceKU6empANG(k)x(0SwxIeIHJV)OeWPcdkFSqV7OwTAQt4K4AUt8CHgolCIBf4gzml4k)E5hmSK)N)pGcK9Yb8uuKqvveRQhW8OILHyxRoXQUclMQjqxIqmfqkg2fJA1jMQjqftbKIPAcuXirjGtfgiw9leKUvmCceeXiOflwXs174e7xpwSQRWIPk)Gf7NGiJzbFxOQkIHf1)k2NiSyXkgYaMhvSmeJA1jw1vyXunbQySYYwOVjg1elsigo(UyxsMESy5l2se)4yX(GtDG2VsOQkIv1dyEuXYqmQvNyvxHft1eOlriMcivsmLxNyQMavmfqQKyjWjwvjMQjqftbKILibdfJ6obZJkuLTywW3)GtDGYU6OG9wQ1LSfZck65dLaPhtbzaZJQ0GqrDcNexZDgbHBXOMlT1dFl07aI3xkn6IxQSYtZaxTA4eii9hLaovyqjwiiDBNG2FB9W3c9oG47ogzAtChLlQv7PzTUejedhF)rjGtfgu(yHE(sHA(vNWjX1CNrq4wmQ5sB9W3c9oG49Lc1QvRTE4BHEhq8DhJmTjUJIpk0LrQzq0DmtZWYhWmsmSxNbjUMD(Xjqq6QtW8ODc6ReQYwml47FWPoqzxDuW(JMUv1hWPcR0Gq5do1bk76pt)Z7)PzTUejedhF)rjGtfgu(yHE3rnHQQigwZwLpsCXCeWbGrms00TQetbjOXIPcLbITaXqhmOIPWu3I9r2Q8ILaNyKOPBvjgw1PJFXMxmc6Uqv2IzbF)do1bk7QJc2XZwLpsCLgek4eiiDAgISWmyxrnpGV)r2Q4lfL7hNabP)OPBvvCjOXDi7Ld49LY18JtGG0F00TQk460XFNG2)tZADjsigo((JsaNkmO8Xc9UJY1eQYwml47FWPoqzxDuW(JoQvAqOePMbrhmyqJpsDfg2zqIRzNFibGrwigUhd4wjwLnTcUoDS)NM16sKqmC89hLaovyq5Jf6DNYfQQIyuFAXIvSRjwKqmC8IDjyfJgo7vIvHzAXiOfRQhGtmSmNva8)IHFtS2TMEayeJenDRQpGtfUluLTywW3)GtDGYU6OG9hnDRQpGtfwP2TMMlrcXWXtXhLgekytDcNexZDINl0WzHtCRa3iJzb(DmobcshzaUIkoRa4)7q2lhWFNp(FAwRlrcXWX3Fuc4uHbLpwO3DuUM)iHy4OhJhxIT4gwHGSxoG33QsOQkIv1lumA4SWjUjgCJmMfOKyeplgjA6wvFaNkSyRAgkgzSqpXunbQyyzfJyjMCaFigbTyXkg1elsigoEXwOydIyvnwwS5fdsaadaJylcIyxUaXsWnXsVLaeITiIfjedh)vcvzlMf89p4uhOSRoky)rt3Q6d4uHvAqOOoHtIR5oXZfA4SWjUvGBKXSa)x6yCceKoYaCfvCwbW)3HSxoG)oFQvlsndIUkoPxGx(bd7miX1SZ)tZADjsigo((JsaNkmO8Xc9UJc1UsOkBXSGV)bN6aLD1rb7pkbCQWGYhl0tPbHYtZADjsigoEFPCT6UeNabPhOCbUrWGobDTAqcaJSqmCpRKjC(YVe6ccmX4XGOwTNJc(ci(Emm8cfx5c62v(VeNabP)38Wx9xwKIJZaTKeX2Gt0jORvdB4eiiDAi7XUjYywqNGUwTNM16sKqmC8(sr5xjuvfXirt3Q6d4uHflwXGmcKFuXQ6b4edlZzfa)VyjWjwSIXGNaYIPIfRLaXAjeEtSvndflfdHqRfRQXYInGyflqzXaSYcXixfi2Gig9()GR5Uqv2IzbF)do1bk7QJc2F00TQ(aovyLgekogNabPJmaxrfNva8)Di7Ld4VJIp1Q12v7wvG(FZdF1Fzrkood0oK9Yb835JIZVJXjqq6idWvuXzfa)FhYE5a(7A7QDRkq)V5HV6VSifhNbAhYE5aEHQSfZc((hCQdu2vhfSJrVRhUoDSsdcfCceKondrwygSROMhW3)iBv8LIY93wGJyIondrwygSROMhW3HjOIVu85AcvzlMf89p4uhOSRoky)rt3Q6d4uHfQYwml47FWPoqzxDuWEdLt6YJUHsdcfSfjedh95l47)(BRh(wO3beF3XitBcFP4JFCceK(JUrzaLaLlUewPtq7NbmeZTEmECj2c1uKVyAUUxQStCIZb]] )

    
end
