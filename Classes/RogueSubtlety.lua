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

                return app + floor( ( t - app ) / 0.95 ) * 0.95
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


    spec:RegisterPack( "Subtlety", 20220315, [[divPycqiiLEKKu2evvFsssJssLtjPQvrvH6vQeMfvLUfjH2Lu(fkvggvfDmsOLPsLNPsHPHsvxJe02KKW3uPOmoif5CQuKSoivP3bPkknpvkDpuY(ij9pvkI6GqkQfcPYdLKQjscCrsckBusI(OkfHrQsrKtQsr1krP8sscQMjKQQBsvHStvQ6NQuKAOuvWsHuWtrLPQs0vjjWwjjiFfsvzSqk0zHufv7vf)vIbt5WIwmkESunzQCzKndXNHKrdLtRy1qQI8AjLztQBtv2nWVvA4OQJdPkSCqpxvtx46q12jrFNKA8KeDEvsRhsvumFjX(j(O45YdNld6C)D(8U785nuuHnfrt3qH3X(dxCLNoC8zVwIIoCG0JoCC4mHMIRho(8QEt35Yd3V4WoD4WIG)rVSJDOMadNP1xp29JhUoJzbDyIeS7hVo7oCm4JoU5GdZHZLbDU)oFE3D(8gkQWMIOPBOW7UXHlXdSfE44gVQF4WgNJahMdNJ((HJdNj0uCvm0WIcNe28rjSJjMI3WxXUZN3DNWMWw1Xsak6rVcBQOy(OvjjMYeojJMA4pv4HZcN4AbUrgZcedNxSFfBcXMxSNcXyiKfsIPMed)jXMOjSPIIv91JzaKyE46y41Ky9uRlzpMfu0ZhIrGao0lwSIbjhENeJFdcetQfdsQxyTMWMkkMpkRrIvLA6X6WejeBabbH48HydqS(6XKHydIyQjXqpH)HyUXj2eIHSqXuU6mgnv(vRKar7WPNp(ZLhUpOuhyK7C55EfpxE4iqYOj3bDhUShZcoCpw6w1FaNA0HZrFho8XSGd3nhrmUGsDGXoLjyEmXsijgoVVIH)KyCyPBv)bCQrIfRymeGqMqme46jwGrIXN)pkjXywa(lwcCIvLdWjg6JYAa6FFfJusaXgeXutILqsSmeZlvPyv3heRoCGM(xm8FaOeZhLFqqXqZ)N)pG6pCD4eeCYdxDIXGJG0(GsDG1W5fRsfXyWrqAktW8ynCEXQxm)IvNyppP1LiHOO4BpgoCQrGYhl0tSBfJ9IvPIykt4KmAQH)uHholCIRf4gzmlqS6fZVyE5heSK)N)pGcK8Yb8IXsmFEIZ93DU8WrGKrtUd6oCo67WHpMfC4QYbmpMyzig7VqSQ7dIPEcSfpetbC(kMcVqm1tGjMc48vSe4eRket9eyIPaoXsKGGIPcLG5XoCzpMfC46PwxYEmlOONpoCD4eeCYdNYeojJMAecc1Jrjv6RhZw43beVyQYsSoFXlvz55jGtSkveJbhbP9y4WPgbkXcbPBB48I5xS(6XSf(DaX3CeY0NqSBzj2DIvPIyppP1LiHOO4BpgoCQrGYhl0tmvzjg7fZVykt4KmAQriiupgLuPVEmBHFhq8IPklXyVyvQiwF9y2c)oG4Bocz6ti2TSetrXurXQtSi1eiAoI4jy5dygjkYRrGKrtoX8lgdocstzcMhRHZlw9ho98rbKE0HdzaZJDIZ934C5HJajJMCh0D46Wji4KhUpOuhyKR9e)pVy(f75jTUejeffF7XWHtncu(yHEIDRyS)WL9ywWH7Xs3Q(d4uJoX5E2FU8WrGKrtUd6oCzpMfC4yYETpsMdNJ(oC4Jzbho0L9AFKmI5WHdaLyCyPBvlMcsqNetngbeBbIHnOWeZhuHe7JSx7flboX4Ws3Qwm0Pth9InVy48TdxhobbN8W1xGdFIgpbrwygKROKgW3GjOMyQYsm0Ky(fJbhbPXtqKfMb5kkPb8TpYEnXuLLykum)IXGJG0ES0TQlUe0PgK8Yb8IPklXUHy(fJbhbP9yPBvxy0PJ(goVy(fRoXEEsRlrcrrX3EmC4uJaLpwONy3YsSBiwLkIPmHtYOPg(tfE4SWjUwGBKXSaXQxm)IvNym4iiThlDR6cJoD03GKxoGxSBzjgdocs7Xs3QU4sqNAqYlhWl2fIDNyvQigAfRVkjqcIMsceyxHIv)jo3RWZLhocKmAYDq3HRdNGGtE4IutGObguyXhPUgbBeiz0Ktm)IbXbeYcrrTyaxlXQYPxy0PJAeiz0Ktm)I98KwxIeIIIV9y4WPgbkFSqpXUvmfE4YEml4W9yJYtCUVkoxE4iqYOj3bDhUShZcoCpw6w1FaNA0HRFTRPsKquu8N7v8W1HtqWjpCOvmLjCsgn1WFQWdNfoX1cCJmMfiMFXCedocsdzaUIAkRbO)BqYlhWl2TIPOy(f75jTUejeffF7XWHtncu(yHEIDllXUHy(flsikkAX4rLylUHetffdsE5aEXuvSQ4W5OVdh(ywWHtfWlwSIDdXIeIIIxS6aRy8WzRxSAeXlgoVyv5aCIH(OSgG(xmMRI1V21daLyCyPBv)bCQrTtCU)MDU8WrGKrtUd6oCzpMfC4ES0TQ)ao1OdNJ(oC4JzbhUQCHIXdNfoXvXGBKXSaFfd)jX4Ws3Q(d4uJeBvsqX4If6jM6jWed95JelrLd4dXW5flwXyVyrcrrXl2cfBqeRkrFInVyqCayaOeBrqeRUfiwcUkw6T4GqSfrSiHOO4R)W1HtqWjpCkt4KmAQH)uHholCIRf4gzmlqm)IvNyoIbhbPHmaxrnL1a0)ni5Ld4f7wXuuSkvelsnbIMAk5xGx(bbBeiz0Ktm)I98KwxIeIIIV9y4WPgbkFSqpXULLySxS6pX5E005Ydhbsgn5oO7W1HtqWjpCppP1LiHOO4ftvwIDdXUqS6eJbhbPfyubUrqGgoVyvQigehqilef1YAzcNV8lUUGatuEeiAeiz0KtSkve7POWSa8VfdbVdnvUJVlMFXIutGO9yPBvxq2o(3iqYOjNy1lMFXQtmgCeK2F1Jz1FzrkokdSsIhBhordNxSkvedTIXGJG04HKh5MiJzbnCEXQurSNN06sKquu8IPklXuOy1F4YEml4W9y4WPgbkFSqVtCU)M6C5HJajJMCh0D4YEml4W9yPBv)bCQrhoh9D4WhZcoCCyPBv)bCQrIfRyqcbspMyv5aCIH(OSgG(xSe4elwXiWJdjXutI1tGy9ecVk2QKGILIHGR1IvLOpXgqSIfyKyasLHyCRceBqeJF)Fy0u7W1HtqWjpCoIbhbPHmaxrnL1a0)ni5Ld4f7wwIPOyvQiwFxTBvdA)vpMv)LfP4OmWAqYlhWl2TIPiAsm)I5igCeKgYaCf1uwdq)3GKxoGxSBfRVR2TQbT)QhZQ)YIuCugyni5Ld4pX5Ef955Ydhbsgn5oO7W1HtqWjpCm4iinEcISWmixrjnGV9r2RjMQSetHI5xS(cC4t04jiYcZGCfL0a(gmb1etvwIP4noCzpMfC4qP31JrNo6eN7vuXZLhUShZcoCpw6w1FaNA0HJajJMCh0DIZ9kE35Ydhbsgn5oO7W1HtqWjpCOvSiHOOOnFHz)xm)I1xpMTWVdi(MJqM(eIPklXuum)IXGJG0ESnkdOeyuXLWAnCEX8lgbiiQRTy8OsSf27tXuvmuDxZlv5Hl7XSGdxhJs(YJTXjoXHZrijUooxEUxXZLhUShZcoC1METdhbsgn5oO7eN7V7C5HJajJMCh0D4w(d3tXHl7XSGdNYeojJMoCktnoD4yWrqAVE6ujbUIB6udNxSkve75jTUejeffF7XWHtncu(yHEIPklXQIdNJ(oC4JzbhovWtoXIvmhfe0BaKyQXOaJGI13v7w1Gxm15eIHSqX4akqmM8jNylqSiHOO4BhoLjSasp6W9axPVa3eZcoX5(BCU8WrGKrtUd6oCl)H7P4WL9ywWHtzcNKrthoLPgNoCm4iiTxpDQKaxXnDQHZlwLkI98KwxIeIIIV9y4WPgbkFSqpXuLLyvXHtzclG0JoCpWv6lWnXSGtCUN9NlpCeiz0K7GUd3YF4EkoCzpMfC4uMWjz00HtzclG0JoCZxaKkJsNVKGXl7yjef5oCD4eeCYdxFvsGeeTAxHtcoCo67WHpMfC4Qog1RjwSI9ej2GiwGrIbivgIvDFqS6gGybgjgPKaHylIyPyCyxkgpC71l28IHMbJx2XsikYD4uMAC6W1xpMTWVdiEXyjMII5xmgCeKg1X2bGQajE44Lax5UgoVyvQiwF9y2c)oG4fJLy3jMFXyWrqAuhBhaQcK4HJxcCLB0W5fRsfX6RhZw43beVySe7gI5xmgCeKg1X2bGQajE44LaxH9nCEXQurS(6XSf(DaXlglXyVy(fJbhbPrDSDaOkqIhoEjWvuydN)eN7v45Ydhbsgn5oO7WT8hUNIdx2JzbhoLjCsgnD4uMAC6WriiupgLuPVEmBHFhq8hoh9D4WhZcoCO5EFXbHyilumoSlfdszpMfiwmEKymxfBqbw4aqjMEvRIv3helbJx2XsikYjMxgDm6fBaIfyKy(SPWxmEi1jYnauILIXVbbIj1IXHDPy8WTF4uMWci9OdhHGq9yusL(6XSf(DaXFIZ9vX5Ydhbsgn5oO7WT8hUNIdx2JzbhoLjCsgnD4uMAC6W1xpMTWVdi(dxhobbN8W1xLeibrR2v4KaX8lgHGq9yusL(6XSf(DaXlMQI1xpMTWVdiEX8lwF9y2c)oG4Bocz6tiMQIDNy(flgpQeB5XIcVg)BSxSBfZNnfkMFXqRykt4KmAQnFbqQmkD(scgVSJLquK7WPmHfq6rhocbH6XOKk91Jzl87aI)eN7VzNlpCeiz0K7GUd3YF4EkoCzpMfC4uMWjz00HtzQXPdhpCw4exlWnYywGy(f75jTUejeffF7XWHtncu(yHEIPklXU7W5OVdh(ywWH7MgOVkwhlbOiXGBKXSaXgeXutIHLkjX4HZcN4AbUrgZce7PqSe4eZdxhdVMelsikkEXW5BhoLjSasp6WH)uHholCIRf4gzml4eN7rtNlpCeiz0K7GUdNJ(oC4JzbhUQJr9AIvDf8ILHyid8Jdx2JzbhUEQ1LShZck65JdNE(Oasp6W1D)jo3FtDU8WrGKrtUd6oCzpMfC4E90PscCf30PdNJ(oC4Jzbho0mpV(QyC6PtILaNyky6Kyzi2Dxiw19bXC4WbGsSaJedzGFiMI(uSN6lW9(kwIeeuSaldXy)fIvDFqSbrSjeJuj)aPxm1tGnaXcmsmaPYqSBIQRaXwOyZlgydXW5pCD4eeCYd3ZtADjsikk(2JHdNAeO8Xc9e7wXQcX8lgYGclkqYlhWlMQIvfI5xmgCeK2RNovsGR4Mo1GKxoGxSBfdv318svkMFX6RhZw43beVyQYsm2lMkkwDIfJhj2TIPOpfREX8XID3jo3ROppxE4iqYOj3bDhoh9D4WhZcoCObCGyi4A9vXE1t0XOxSyflWiX4ck1bg5ednSrgZceRoMRI52bGsSF9vSjedzHD6fJFx9aqj2GigydSbGsS5flvMJoz0u9Tdx2JzbhoioOK9ywqrpFC46Wji4KhUpOuhyKRLA9HtpFuaPhD4(GsDGrUtCUxrfpxE4iqYOj3bDhoh9D4WhZcoC(aCw4exfdnSrgZcUjlg6NIQ(IHAusILI1HjVyjZIhIracI6QyiluSaJe7dk1bMyvxbVy1XGpAhbf7JrRfdspp1dXMO(MyONJZ7RytiwpbIXqIfyzi2pE8AQD4YEml4W1tTUK9ywqrpFC46Wji4KhoLjCsgn1WFQWdNfoX1cCJmMfC40Zhfq6rhUpOuhyLU7pX5EfV7C5HJajJMCh0D4w(d3tXHl7XSGdNYeojJMoCktnoD4UtHIDHyrQjq0uoOwyJajJMCI5Jf7oFk2fIfPMarZl)GGLfP8yPBv)ncKmAYjMpwS78PyxiwKAceThlDR6cY2X)gbsgn5eZhl2DkuSlelsnbIwQZoCIRncKmAYjMpwS78Pyxi2DkumFSy1j2ZtADjsikk(2JHdNAeO8Xc9etvwIXEXQ)W5OVdh(ywWHtf8KtSyfZridGetngbelwXWFsSpOuhyIvDf8ITqXyWhTJG)HtzclG0JoCFqPoWkbgKESv7oX5EfVX5Ydhbsgn5oO7W5OVdh(ywWHR6l4hhbfd)hakXsX4ck1bMyvxbIPgJaIbPSJnauIfyKyeGGOUkwGbPhB1Udx2JzbhUEQ1LShZck65JdxhobbN8WracI6AZritFcXULLykt4KmAQ9bL6aReyq6XwT7WPNpkG0JoCFqPoWkD3FIZ9kY(ZLhocKmAYDq3HZrFho8XSGdxvoG5XeldX8sv6RyS)cXupb2IhIPaoXwOyQNatmUvbI1HtigdocIVIPWlet9eyIPaoXQBXJFCKyFqPoWQ3xXupbMykGtSu)RyidyEmXYqm2FHyjQCaFig7flsikkEXQBXJFCKyFqPoWQ)WL9ywWHRNADj7XSGIE(4W1HtqWjpCkt4KmAQriiupgLuPVEmBHFhq8IPklX68fVuLLNNaoXQurS(6XSf(DaX3CeY0NqSBzjMIIvPIyidkSOajVCaVy3YsmffZVykt4KmAQriiupgLuPVEmBHFhq8IPklXUHyvQigdocs7V6XS6VSifhLbwjXJTdNOHZlMFXuMWjz0uJqqOEmkPsF9y2c)oG4ftvwIXEXQurSNN06sKquu8Thdho1iq5Jf6jMQSeJ9I5xmLjCsgn1ieeQhJsQ0xpMTWVdiEXuLLyS)WPNpkG0JoCidyEStCUxrfEU8WrGKrtUd6oCo67WHpMfC4ubpjwkgd(ODeum1yeqmiLDSbGsSaJeJaee1vXcmi9yR2D4YEml4W1tTUK9ywqrpFC46Wji4KhocqquxBocz6ti2TSetzcNKrtTpOuhyLadsp2QDho98rbKE0HJbF0UtCUxXQ4C5HJajJMCh0D4YEml4WLWEcOsSqibIdNJ(oC4Jzbho0)QM(qmE4SWjUk2ael1AXweXcmsm0SpG(fJH6j(tInHy9e)PxSuSBIQRGdxhobbN8WracI6AZritFcXuLLykQqXUqmcqquxBqcfboX5EfVzNlpCzpMfC4sypbuHhx)0HJajJMCh0DIZ9kIMoxE4YEml4WPhuyXxqpH7q5rG4WrGKrtUd6oX5EfVPoxE4YEml4WXKOklsjGtV2F4iqYOj3bDN4ehoEi1xpMmoxEUxXZLhUShZcoCjpV(AHFNFbhocKmAYDq3jo3F35Ydx2JzbhoMncn5ki68k5upauLyv5aoCeiz0K7GUtCU)gNlpCeiz0K7GUdxhobbN8W9lUMzaUgp(h4AQqqC(ywqJajJMCIvPIy)IRzgGRPC1zmAQ8RwjbIgbsgn5oCzpMfC4q00J1HjsCIZ9S)C5Hl7XSGd3huQdSdhbsgn5oO7eN7v45Ydhbsgn5oO7WL9ywWHZlH1ixbzHfhLb2HJhs91JjJYt9f4(dNIk8eN7RIZLhocKmAYDq3Hl7XSGd3RNovsGR4MoD46Wji4KhoiHaPhlz00HJhs91JjJYt9f4(dNIN4C)n7C5HJajJMCh0D46Wji4KhoioGqwikQ5LWALfPeyuXl)GGL8)8)b0iqYOj3Hl7XSGd3JLUvDHrNo6pXjoCm4J2DU8CVINlpCeiz0K7GUdxhobbN8WHwXIutGObguyXhPUgbBeiz0Ktm)IbXbeYcrrTyaxlXQYPxy0PJAeiz0Ktm)I98KwxIeIIIV9y4WPgbkFSqpXUvmfE4YEml4W9yJYtCU)UZLhocKmAYDq3HRdNGGtE4EEsRlrcrrXlMQSe7oX8lwDIHwX6RscKGObOoC1l0jwLkI13v7w1G2tqygKRWSaQ88tnQ5LQS0Xsik6ftffRJLqu0xqGzpMfKAXuLLy(SDNcfRsfXEEsRlrcrrX3EmC4uJaLpwONyQkg7fREX8lwDIXGJG04jiYcZGCfL0a(2hzVMy3Ysm2lwLkI98KwxIeIIIV9y4WPgbkFSqpXuvm2lMFXqRykt4KmAQH)uHholCIRf4gzmlqS6pCzpMfC4EmC4uJaLpwO3jo3FJZLhocKmAYDq3HRdNGGtE4yWrqA8eezHzqUIsAaF7JSxtSBzj2DI5xS6eRVR2TQbTNGWmixHzbu55NAuZlvzPJLqu0lMkkwhlHOOVGaZEmli1IDllX8z7ofkwLkI9lUMzaUMMsxH5AHuz6XRPgbsgn5eZVyOvmgCeKMMsxH5AHuz6XRPgoVyvQi2V4AMb4A1iLd4l7IEgspauncKmAYjMFXqRyoIbhbPvJuoGVOgMbwdNxS6pCzpMfC4EccZGCfMfqLNFQrN4Cp7pxE4YEml4WHsVRhJoD0HJajJMCh0DIZ9k8C5HJajJMCh0D4YEml4WXK9AFKmhoh9D4WhZcoCOl71(izeB88i3KbPVkgoqt)lwGrIbivgIvDFqS5fdndgVSJLquKtSe4etnjM6fu1qSEYlgbiiQRIPoNyaOedzHInr7W1HtqWjpCOvS(QKajiA1UcNeiwLkIHwXQtmLjCsgn1MVaivgLoFjbJx2XsikYjMFXQtSy8OsSLhlk8A8VDdXUvmF2uOyvQiwmEuj2YJffEn(3yVy3kMIIvVy(fJaee1vXUvSQWNIv)joXHR7(ZLN7v8C5HJajJMCh0D46Wji4Kho0kgdocs7Xs3QU4sqNA48I5xmgCeK2JHdNAeOeleKUTHZlMFXyWrqApgoCQrGsSqq62gK8Yb8IDllXUrtHho8Nklcsbv3DUxXdx2JzbhUhlDR6IlbD6W5OVdh(ywWHtf8KykibDsSfbrfr1DIXqilKelWiXqg4hIXHHdNAeqmUyHEIHaxpXUCHG0TI1xp6fBaTtCU)UZLhocKmAYDq3HRdNGGtE4yWrqApgoCQrGsSqq62goVy(fJbhbP9y4WPgbkXcbPBBqYlhWl2TSe7gnfE4WFQSiifuD35EfpCzpMfC4(REmR(llsXrzGD4C03HdFml4WvNkaOP)fl1qkDxfdNxmgQN4pjMAsSy3AIXHLUvTyv52X)6fd)jX4U6XS6xSfbrfr1DIXqilKelWiXqg4hIXHHdNAeqmUyHEIHaxpXUCHG0TI1xp6fBaTtCU)gNlpCeiz0K7GUdxhobbN8WPmHtYOP2dCL(cCtmlqm)IHwX(GsDGrUMxccnjMFXQtSNN06sKquu8Thdho1iq5Jf6j2TSetrX8lwFxTBvdA)vpMv)LfP4OmWA48I5xm0kwKAceThlDR6cY2X)gbsgn5eRsfXyWrqA)vpMv)LfP4OmWA48IvVy(fRVEmBHFhq8IPklXu4Hl7XSGdhIorrADgZcoX5E2FU8WrGKrtUd6oCD4eeCYdxDIbXbeYcrrnVewRSiLaJkE5heSK)N)pGgbsgn5eZVy91Jzl87aIV5iKPpHy3YsmfftfflsnbIMJiEcw(aMbHI8Aeiz0KtSkvedIdiKfIIAokdm91YJLUv93iqYOjNy(fRVEmBHFhq8IDRykkw9I5xmgCeK2F1Jz1FzrkokdSgoVy(fJbhbP9yPBvxCjOtnCEX8lMx(bbl5)5)dOajVCaVySeZNI5xmgCeKMJYatFT8yPBv)n3QgC4YEml4WPmbZJDIZ9k8C5HJajJMCh0D4C03HdFml4W5d7QfdzHID5cbPBfJhsQi3QaXupbMyCykqmiLURIPgJaIb2qmioamauIXvLTdhYclasLX5EfpCD4eeCYdxKAceThdho1iqjwiiDBJajJMCI5xm0kwKAceThlDR6cY2X)gbsgn5oCzpMfC443vxG0V4WoDIZ9vX5Ydhbsgn5oO7WL9ywWH7XWHtncuIfcs3E4C03HdFml4WPcEsSlxiiDRy8qsmUvbIPgJaIPMedlvsIfyKyeGGOUkMAmkWiOyiW1tm(D1daLyQNaBXdX4QsXwOyONW)qmueGGPwFTD46Wji4KhUNN06sKquu8Thdho1iq5Jf6j2TSetrX8lgbiiQRIPklXQcFkMFXuMWjz0u7bUsFbUjMfiMFX67QDRAq7V6XS6VSifhLbwdNxm)I13v7w1G2JLUvDXLGo16yjef9IPklXuum)IvNyOvmioGqwikQTmKBiqNAeiz0KtSkveZrm4iineDII06mMf0W5fRsfXEEsRlrcrrX3EmC4uJaLpwONyQYsS6etrXUqm2lMpwS6edTIfPMardmOWIpsDnc2iqYOjNy(fdTIfPMarZLWALhlDR6gbsgn5eREXQxS6fZVy91Jzl87aIxSBzj2DI5xm0kgdocsJhsEKBImMf0W5fZVy1jgAfRVkjqcIMsceyxHIvPIyOvS(UA3Qg0q0jksRZywqdNxS6pX5(B25Ydhbsgn5oO7WL9ywWH7jimdYvywavE(PgD46Wji4KhoLjCsgn1EGR0xGBIzbI5xm0kMBJ2tqygKRWSaQ88tnQ42OftV2aqjMFXIeIIIwmEuj2IBiXuLLy3POy(fRoX6RhZw43beFZritFcXuLLy1jwNVGkhGyQEtwm2lw9IvVy(fdTIXGJG0EmC4uJaLyHG0TnCEX8lwDIHwXyWrqA8qYJCtKXSGgoVyvQi2ZtADjsikk(2JHdNAeO8Xc9etvXyVy1lwLkIHmOWIcK8Yb8IDllXuOy(f75jTUejeffF7XWHtncu(yHEIDRy34W1V21ujsikk(Z9kEIZ9OPZLhocKmAYDq3HRdNGGtE4uMWjz0u7bUsFbUjMfiMFX6RhZw43beFZritFcXuLLykkMFXIeIIIwmEuj2IBiXuLLykwfhUShZcoCpX)ZFIZ93uNlpCeiz0K7GUdx2JzbhU)QhZQ)YIuCugyhoh9D4WhZcoCQGNeJ7QhZQFXwGy9D1UvnqS6sKGGIHmWpeJdOG6fdhOP)ftnjwcjXqTdaLyXkg)Yl2LleKUvSe4eZTIb2qmSujjghw6w1IvLBh)BhUoCcco5HRoXqRyFqPoWixl1AXQurmgCeKgpbrwygKROKgW3(i71e7wXyVy1lMFXuMWjz0u7bUsFbUjMfiMFXQtm0kwKAceThdho1iqjwiiDBJajJMCIvPIyrQjq0ES0TQliBh)Beiz0KtSkve75jTUejeffF7XWHtncu(yHEIPklXUtSkveRVR2TQbThdho1iqjwiiDBdsE5aEXuvS7eREX8lwDIHwX6RscKGOPKab2vOyvQiwFxTBvdAi6efP1zmlObjVCaVyQkMI(uSkveRVR2TQbneDII06mMf0W5fZVy91Jzl87aIxmvzjMcfR(tCUxrFEU8WrGKrtUd6oCzpMfC48synYvqwyXrzGD40dGkD3HtXMcpC9RDnvIeIII)CVIhUoCcco5HdMJRqkjq0sN7B48I5xS6elsikkAX4rLylUHe7wX6RhZw43beFZritFcXQurm0k2huQdmY1sTwm)I1xpMTWVdi(MJqM(eIPklX68fVuLLNNaoXQ)W5OVdh(ywWH7MJiw6CVyjKedN3xXEWWtIfyKylGet9eyIPx10hID5LkOjMk4jXuJraXCxhakXqYpiOybwceR6(Gyocz6ti2cfdSHyFqPoWiNyQNaBXdXsWvXQUp0oX5Efv8C5HJajJMCh0D4YEml4W5LWAKRGSWIJYa7W5OVdh(ywWH7MJigyflDUxm1JwlMBiXupb2aelWiXaKkdXUHpFFfd)jX8rikqSfigZ(VyQNaBXdXsWvXQUp0oCD4eeCYdhmhxHusGOLo33gGyQk2n8PyQOyWCCfsjbIw6CFZHdZywGy(fRVEmBHFhq8nhHm9jetvwI15lEPklppbCN4CVI3DU8WrGKrtUd6oCD4eeCYdNYeojJMApWv6lWnXSaX8lwF9y2c)oG4Bocz6tiMQSe7oX8lwDIXGJG0(REmR(llsXrzG1W5fRsfXy2)fZVyidkSOajVCaVy3YsS78PyvQigAfJbhbP9yPBvxy0PJ(goVy(f7POWSa8VfdbVdnvUJVlw9hUShZcoCpw6w1fgD6O)eN7v8gNlpCeiz0K7GUdxhobbN8WHwX(GsDGrUwQ1I5xmLjCsgn1EGR0xGBIzbI5xS(6XSf(DaX3CeY0Nqmvzj2DI5xS6etzcNKrtn8Nk8WzHtCTa3iJzbIvPIyppP1LiHOO4BpgoCQrGYhl0tSBzjg7fRsfXG4aczHOOgK(fh4gaQsxNWjU2iqYOjNy1F4YEml4WrDSDaOkqIhoEjWDIZ9kY(ZLhocKmAYDq3Hl7XSGd3JHdNAeOeleKU9W5OVdh(ywWHd9nbMyCvPVIniIb2qSudP0Dvm3ciFfd)jXUCHG0TIPEcmX4wfigoF7W1HtqWjpC1jwKAceThlDR6cY2X)gbsgn5eRsfXEEsRlrcrrX3EmC4uJaLpwONyQYsS7eREX8lMYeojJMApWv6lWnXSaX8lgdocs7V6XS6VSifhLbwdNxm)I1xpMTWVdiEXULLy3jMFXQtm0kgdocsJhsEKBImMf0W5fRsfXEEsRlrcrrX3EmC4uJaLpwONyQkg7fR(tCUxrfEU8WrGKrtUd6oCD4eeCYdhAfJbhbP9yPBvxCjOtnCEX8lgYGclkqYlhWl2TSednj2fIfPMar7XzccIGJIAeiz0K7WL9ywWH7Xs3QU4sqNoX5EfRIZLhocKmAYDq3HRdNGGtE4QtSFX1mdW14X)axtfcIZhZcAeiz0KtSkve7xCnZaCnLRoJrtLF1kjq0iqYOjNy1lMFXiabrDT5iKPpHyQYsSB4tX8lgAf7dk1bg5APwlMFXyWrqA)vpMv)LfP4OmWAUvn4WnGGGqC(OmihUFX1mdW1uU6mgnv(vRKaXHBabbH48rz88i3KbD4u8WL9ywWHdrtpwhMiXHBabbH48rbLEzs9HtXtCUxXB25Ydhbsgn5oO7W1HtqWjpCm4iing9Uon(hniL9qSkvedzqHffi5Ld4f7wXUHpfRsfXyWrqA)vpMv)LfP4OmWA48I5xS6eJbhbP9yPBvxy0PJ(goVyvQiwFxTBvdApw6w1fgD6OVbjVCaVy3Ysmf9Py1F4YEml4WXVXSGtCUxr005Ydhbsgn5oO7W1HtqWjpCm4iiT)QhZQ)YIuCugynC(dx2Jzbhog9UUcco86jo3R4n15Ydhbsgn5oO7W1HtqWjpCm4iiT)QhZQ)YIuCugynC(dx2Jzbhogc(eS2aqDIZ935ZZLhocKmAYDq3HRdNGGtE4yWrqA)vpMv)LfP4OmWA48hUShZcoCidKy076oX5(7u8C5HJajJMCh0D46Wji4KhogCeK2F1Jz1FzrkokdSgo)Hl7XSGdxc60hWux6PwFIZ93D35Ydhbsgn5oO7WL9ywWHRNDmQSiLSJEGpqYvciLpoK(dxhobbN8WXGJG0Yo6b(ajxjvj1W5fZVy1j2ZtADjsikk(2JHdNAeO8Xc9eJLykkMFXG54kKsceT05(2aetvXQcFkwLkI98KwxIeIIIV9y4WPgbkFSqpXuvmffREXQurmM9FX8lgYGclkqYlhWl2TIDNcpCG0JoC9SJrLfPKD0d8bsUsaP8XH0FIZ93DJZLhocKmAYDq3Hl7XSGdh(tLjiV)W5OVdh(ywWHtbesIRdXqsTMj71edzHIH)jJMeBcY7rVIPcEsm1tGjg3vpMv)ITiIPakdS2HRdNGGtE4yWrqA)vpMv)LfP4OmWA48IvPIyidkSOajVCaVy3k2D(8eN4W9bL6aR0D)5YZ9kEU8WrGKrtUd6oCl)H7P4WL9ywWHtzcNKrthoLPgNoC9D1UvnO9yPBvxCjOtTowcrrFbbM9ywqQftvwIPy7MPWdNJ(oC4JzbhUBsKMNGIPcLWjz00HtzclG0JoCpMReyq6XwT7eN7V7C5HJajJMCh0D4YEml4WPmbZJD4C03HdFml4WPcLG5XeBqetnjwcjX6jp)aqj2cetbjOtI1Xsik6BIPclH6RIXqilKedzGFiMlbDsSbrm1KyyPssmWk29dkS4JuxJGIXGhIPGewtmoS0TQfBaITqhbflwXqrHyObC(ahsIHZlwDGvmFu(bbfdn)F()aQVD46Wji4KhU6edTIPmHtYOP2J5kbgKESv7eRsfXqRyrQjq0adkS4JuxJGncKmAYjMFXIutGO5syTYJLUvDJajJMCIvVy(fRVEmBHFhq8nhHm9jetvXuum)IHwXG4aczHOOMxcRvwKsGrfV8dcwY)Z)hqJajJMCN4C)noxE4iqYOj3bDhoh9D4WhZcoC(WUAXqwOyCyPBv7rANyxighw6w1FaNAKy4an9VyQjXsijwYS4HyXkwp5fBbIPGe0jX6yjef9nXUPb6RIPgJaIvLdWjg6JYAa6FXMxSKzXdXIvmioqSfpAhoKfwaKkJZ9kE46Wji4Khoy2PgyqHffsJC4ivgWSKEloioCS3NhUShZcoC87Qlq6xCyNoX5E2FU8WrGKrtUd6oCD4eeCYdhbiiQRIPklXyVpfZVyeGGOU2CeY0NqmvzjMI(um)IHwXuMWjz0u7XCLadsp2QDI5xS(6XSf(DaX3CeY0NqmvftXdx2JzbhUhlDRAps7oX5EfEU8WrGKrtUd6oCl)H7P4WL9ywWHtzcNKrthoLPgNoC91Jzl87aIV5iKPpHyQYsS7e7cXyWrqApw6w1fgD6OVHZF4C03HdFml4WvDFqSadsp2QDVyilumceeCaOeJdlDRAXuqc60HtzclG0JoCpMR0xpMTWVdi(tCUVkoxE4iqYOj3bDhUL)W9uC4YEml4WPmHtYOPdNYuJthU(6XSf(DaX3CeY0Nqmvzj2noCD4eeCYdxFvsGeeTAxHtcoCktybKE0H7XCL(6XSf(DaXFIZ93SZLhocKmAYDq3HB5pCpfhUShZcoCkt4KmA6WPm140HRVEmBHFhq8nhHm9je7wwIP4HRdNGGtE4uMWjz0ud)PcpCw4exlWnYywGy(f75jTUejeffF7XWHtncu(yHEIPklXy)HtzclG0JoCpMR0xpMTWVdi(tCUhnDU8WrGKrtUd6oCzpMfC4ES0TQlUe0PdNJ(oC4JzbhofKGojMdhoauIXD1Jz1VyluSKzvsIfyq6XwTRD46Wji4KhU6eRoXuMWjz0u7XCL(6XSf(DaXlMFXQtS(UA3Qg0(REmR(llsXrzG1GKxoGxmvzjMIvHyvQigAfdIdiKfIIAbgvGBeeOrGKrtoXQxSkvetzcNKrtThZvcmi9yR2jwLkIbXbeYcrrTaJkWncc0iqYOjNy(fRVR2TQbT)QhZQ)YIuCugyni5Ld4f7wwIHMeREX8l2trHzb4FlgcEhAQChFxm)I1xLeibrR2v4KaXQurmLjCsgn1EmxPVEmBHFhq8I5xS6eJbhbP9x9yw9xwKIJYaRbjVCaVyQYsmfB3jwLkIPmHtYOP2J5kbgKESv7eREXQurmgCeKwhl3VWKaQHZlwLkI98KwxIeIIIV9y4WPgbkFSqpXuLLySxm)I13v7w1G2F1Jz1FzrkokdSgK8Yb8IPQyk6tXQxm)IvNym4iinEcISWmixrjnGV9r2Rj2TIXEXQurSNN06sKquu8Thdho1iq5Jf6jMQIDdXQ)eN7VPoxE4iqYOj3bDhUShZcoCpw6w1fxc60HZrFho8XSGdh6WHaXuqc60lwhlHOOxSbrSRlUy868QykiH1eJdlDR6NDOzD2HtCvSfkgdHSqsSaJedzqHfIra3l2Gig3QaXuVGQgIXqIbP0DvSbiwmEu7W1HtqWjpCkt4KmAQ9yUsF9y2c)oG4fZVyidkSOajVCaVy3kwFxTBvdA)vpMv)LfP4OmWAqYlhWlwLkIHwXIutGOraLKE5haQYJLUv93iqYOj3joXHdzaZJDU8CVINlpCeiz0K7GUd3YF4EkoCzpMfC4uMWjz00HtzQXPdxKAcenEi5rUjYywqJajJMCI5xSNN06sKquu8Thdho1iq5Jf6j2TIvNykumvuS(QKajiAaQdx9cDIvVy(fdTI1xLeibrR2v4KGdNJ(oC4Jzbho0h2OjXW)bGsmFasEKBImMf4RyPYDCI1ZpgakX40tNelboXuW0jXuJraX4Ws3QwmfKGoj28I97celwXyiXWFY5RyKk7eFigYcftf(v4KGdNYewaPhD44HKh5kpWv6lWnXSGtCU)UZLhocKmAYDq3HRdNGGtE4qRykt4KmAQXdjpYvEGR0xGBIzbI5xSNN06sKquu8Thdho1iq5Jf6j2TIvfI5xm0kgdocs7Xs3QU4sqNA48I5xmgCeK2RNovsGR4Mo1GKxoGxSBfdzqHffi5Ld4fZVyqcbspwYOPdx2JzbhUxpDQKaxXnD6eN7VX5Ydhbsgn5oO7W1HtqWjpCkt4KmAQXdjpYvEGR0xGBIzbI5xS(UA3Qg0ES0TQlUe0PwhlHOOVGaZEmli1IDRyk2Uzkum)IXGJG0E90PscCf30PgK8Yb8IDRy9D1UvnO9x9yw9xwKIJYaRbjVCaVy(fRoX67QDRAq7Xs3QU4sqNAqkDxfZVym4iiT)QhZQ)YIuCugyni5Ld4ftffJbhbP9yPBvxCjOtni5Ld4f7wXuSDNy1F4YEml4W96PtLe4kUPtN4Cp7pxE4iqYOj3bDhUL)W9uC4YEml4WPmHtYOPdNYuJthoV8dcwY)Z)hqbsE5aEXuvmFkwLkIHwXIutGObguyXhPUgbBeiz0Ktm)IfPMarZLWALhlDR6gbsgn5eZVym4iiThlDR6IlbDQHZlwLkI98KwxIeIIIV9y4WPgbkFSqpXuLLy1jg7ftff7dk1bg5APwlMpwSi1eiApw6w1fKTJ)ncKmAYjw9hoh9D4WhZcoC3KinpbftfkHtYOjXqwOyObC(ahsnX4Qn8I5WHdaLy(O8dckgA()8)bi2cfZHdhakXuqc6KyQNatmfKWAILaNyGvS7huyXhPUgbBhoLjSasp6W91g(ceNpWH0jo3RWZLhocKmAYDq3Hl7XSGdheNpWH0HZrFho8XSGdNkCI4fdNxm0aoFGdjXgeXMqS5flzw8qSyfdIdeBXJ2HRdNGGtE4qRyFqPoWixl1AX8lwDIHwXuMWjz0u7Rn8fioFGdjXQurmLjCsgn1WFQWdNfoX1cCJmMfiw9I5xSiHOOOfJhvIT4gsmvumi5Ld4ftvXQcX8lgKqG0JLmA6eN7RIZLhUShZcoCp1HuucQJbg0dC6WrGKrtUd6oX5(B25Ydhbsgn5oO7WL9ywWHdIZh4q6W1V21ujsikk(Z9kE46Wji4Kho0kMYeojJMAFTHVaX5dCijMFXqRykt4KmAQH)uHholCIRf4gzmlqm)I98KwxIeIIIV9y4WPgbkFSqpXuLLy3jMFXIeIIIwmEuj2IBiXuLLy1jMcf7cXQtS7eZhlwF9y2c)oG4fREXQxm)Ibjei9yjJMoCo67WHpMfC48r46yCBedaLyrcrrXlwGLHyQhTwm9OKedzHIfyKyoCygZceBrednGZh4qYxXGecKEmXC4WbGsm(e4iVP3oX5E005Ydhbsgn5oO7WL9ywWHdIZh4q6W5OVdh(ywWHdnqiq6XednGZh4qsmkH6RIniInHyQhTwmsL8dKeZHdhakX4U6XS6VjMcwXcSmedsiq6XeBqeJBvGyOO4fdsP7QydqSaJedqQmetHF7W1HtqWjpCOvmLjCsgn1(AdFbIZh4qsm)IbjVCaVy3kwFxTBvdA)vpMv)LfP4OmWAqYlhWl2fIPOpfZVy9D1UvnO9x9yw9xwKIJYaRbjVCaVy3YsmfkMFXIeIIIwmEuj2IBiXurXGKxoGxmvfRVR2TQbT)QhZQ)YIuCugyni5Ld4f7cXu4jo3FtDU8WrGKrtUd6oCD4eeCYdhAftzcNKrtn8Nk8WzHtCTa3iJzbI5xSNN06sKquu8IPklXUXHl7XSGdhJo71k8RAhbpX5Ef955Ydx2Jzbhos58DcMbD4iqYOj3bDN4eN4WPKG)SGZ935Z7UZN3WNOPdN6ecgaQ)WH(qZOH7V53FtGEftSlXiXgp(fgIHSqXQ6huQdmYvvXGe6b(ajNy)6rIL4X6Lb5eRJLau03e2q)dGetHOxXQ(cusWGCIvvioGqwikQHgRQyXkwvH4aczHOOgASrGKrtUQkwDkQY6BcBO)bqIHMqVIv9fOKGb5eRQqCaHSquudnwvXIvSQcXbeYcrrn0yJajJMCvvS6uuL13e2e2qFOz0W9387VjqVIj2LyKyJh)cdXqwOyvLhs91JjJQkgKqpWhi5e7xpsSepwVmiNyDSeGI(MWg6FaKy3a9kw1xGscgKtSQ(lUMzaUgASQIfRyv9xCnZaCn0yJajJMCvvS6uuL13e2q)dGe7gOxXQ(cusWGCIv1FX1mdW1qJvvSyfRQ)IRzgGRHgBeiz0KRQILHyQWUPr)IvNIQS(MWg6FaKy3m0RyvFbkjyqoXQkehqilef1qJvvSyfRQqCaHSquudn2iqYOjxvfldXuHDtJ(fRofvz9nHnHn0hAgnC)n)(Bc0RyIDjgj24XVWqmKfkwv7UVQIbj0d8bsoX(1JelXJ1ldYjwhlbOOVjSH(hajg7rVIv9fOKGb5eRQqCaHSquudnwvXIvSQcXbeYcrrn0yJajJMCvvS6UtL13e2q)dGeRkqVIv9fOKGb5eRQqCaHSquudnwvXIvSQcXbeYcrrn0yJajJMCvvS6uuL13e2q)dGetXBGEfR6lqjbdYjwvH4aczHOOgASQIfRyvfIdiKfIIAOXgbsgn5QQy1POkRVjSH(hajMIvb6vSQVaLemiNyv9xCnZaCn0yvflwXQ6V4AMb4AOXgbsgn5QQy1DNkRVjSjSH(qZOH7V53FtGEftSlXiXgp(fgIHSqXQ6huQdSs39vvmiHEGpqYj2VEKyjESEzqoX6yjaf9nHn0)aiXUd9kw1xGscgKtSQcXbeYcrrn0yvflwXQkehqilef1qJncKmAYvvXYqmvy30OFXQtrvwFtyd9pasm0e6vSQVaLemiNyvfIdiKfIIAOXQkwSIvvioGqwikQHgBeiz0KRQIv3DQS(MWMWg6dnJgU)MF)nb6vmXUeJeB84xyigYcfRQm4J2vvXGe6b(ajNy)6rIL4X6Lb5eRJLau03e2q)dGetr0RyvFbkjyqoXQkehqilef1qJvvSyfRQqCaHSquudn2iqYOjxvfRofvz9nHn0)aiXui6vSQVaLemiNyvngpQeB5XIgASXRX)QkwSIv1y8OsSLhlk8A8VHgRQy1DNkRVjSjSDZ94xyqoXUzIL9ywGy65JVjSD4EEQFU)UQqXdhpCrgnD4Qw1eJdNj0uCvm0WIcNe2Qw1eZhLWoMykEdFf7oFE3DcBcBvRAIvDSeGIE0RWw1QMyQOy(OvjjMYeojJMA4pv4HZcN4AbUrgZcedNxSFfBcXMxSNcXyiKfsIPMed)jXMOjSvTQjMkkw1xpMbqI5HRJHxtI1tTUK9ywqrpFigbc4qVyXkgKC4Dsm(niqmPwmiPEH1AcBvRAIPII5JYAKyvPMESomrcXgqqqioFi2aeRVEmzi2GiMAsm0t4FiMBCInHyilumLRoJrtLF1kjq0e2e2Qw1eZhGKkw91JjdHTShZc(gpK6RhtgxWIDjpV(AHFNFbcBzpMf8nEi1xpMmUGf7y2i0KRGOZRKt9aqvIvLdqyl7XSGVXdP(6XKXfSyhIMESomrcFhew)IRzgGRXJ)bUMkeeNpMfuPYV4AMb4AkxDgJMk)QvsGqyl7XSGVXdP(6XKXfSy3huQdmHTShZc(gpK6RhtgxWIDEjSg5kilS4OmW8Lhs91JjJYt9f4EwkQqHTShZc(gpK6RhtgxWIDVE6ujbUIB6KV8qQVEmzuEQVa3ZsrFhewqcbspwYOjHTShZc(gpK6RhtgxWIDpw6w1fgD6O33bHfehqilef18syTYIucmQ4LFqWs(F()ae2e2Qw1eZhLdqm0Wgzmlqyl7XSGNvTPxtyRAIPcEYjwSI5OGGEdGetngfyeuS(UA3Qg8IPoNqmKfkghqbIXKp5eBbIfjeffFtyl7XSG)cwStzcNKrt(cspI1dCL(cCtmlWxLPgNyXGJG0E90PscCf30PgoFLkppP1LiHOO4BpgoCQrGYhl0tvwvHWw2Jzb)fSyNYeojJM8fKEeRh4k9f4MywGVktnoXIbhbP96PtLe4kUPtnC(kvEEsRlrcrrX3EmC4uJaLpwONQSQcHTQjw1XOEnXIvSNiXgeXcmsmaPYqSQ7dIv3aelWiXiLeieBrelfJd7sX4HBVEXMxm0my8YowcrroHTShZc(lyXoLjCsgn5li9iwZxaKkJsNVKGXl7yjef58Dqy1xLeibrR2v4KaFvMACIvF9y2c)oG4zPOFgCeKg1X2bGQajE44Lax5UgoFLk91Jzl87aIN1D(zWrqAuhBhaQcK4HJxcCLB0W5RuPVEmBHFhq8SUHFgCeKg1X2bGQajE44LaxH9nC(kv6RhZw43bepl27NbhbPrDSDaOkqIhoEjWvuydNxyRAIHM79fheIHSqX4WUumiL9ywGyX4rIXCvSbfyHdaLy6vTkwDFqSemEzhlHOiNyEz0XOxSbiwGrI5ZMcFX4HuNi3aqjwkg)geiMulgh2LIXd3UWw2Jzb)fSyNYeojJM8fKEelcbH6XOKk91Jzl87aI3xLPgNyriiupgLuPVEmBHFhq8cBzpMf8xWIDkt4KmAYxq6rSieeQhJsQ0xpMTWVdiEFhew9vjbsq0QDfojWpHGq9yusL(6XSf(DaXRAF9y2c)oG493xpMTWVdi(MJqM(eQEN)y8OsSLhlk8A8VX(B9ztH(rRYeojJMAZxaKkJsNVKGXl7yjef58vzQXjw91Jzl87aIxyRAIDtd0xfRJLauKyWnYywGydIyQjXWsLKy8WzHtCTa3iJzbI9uiwcCI5HRJHxtIfjeffVy48nHTShZc(lyXoLjCsgn5li9iw4pv4HZcN4AbUrgZc8vzQXjw8WzHtCTa3iJzb(FEsRlrcrrX3EmC4uJaLpwONQSUtyRAIvDmQxtSQRGxSmedzGFiSL9ywWFbl21tTUK9ywqrpF4li9iwD3lSvnXqZ886RIXPNojwcCIPGPtILHy3DHyv3heZHdhakXcmsmKb(Hyk6tXEQVa37RyjsqqXcSmeJ9xiw19bXgeXMqmsL8dKEXupb2aelWiXaKkdXUjQUceBHInVyGnedNxyl7XSG)cwS71tNkjWvCtN8Dqy98KwxIeIIIV9y4WPgbkFSqVBRc)idkSOajVCaVQvHFgCeK2RNovsGR4Mo1GKxoG)wuDxZlvP)(6XSf(DaXRkl2RI1fJhDRI(SEF8DcBvtm0aoqmeCT(QyV6j6y0lwSIfyKyCbL6aJCIHg2iJzbIvhZvXC7aqj2V(k2eIHSWo9IXVREaOeBqedSb2aqj28ILkZrNmAQ(MWw2Jzb)fSyhehuYEmlOONp8fKEeRpOuhyKZ3bH1huQdmY1sTwyRAI5dWzHtCvm0Wgzml4MSyOFkQ6lgQrjjwkwhM8ILmlEigbiiQRIHSqXcmsSpOuhyIvDf8Ivhd(ODeuSpgTwmi98upeBI6BIHEooVVInHy9eigdjwGLHy)4XRPMWw2Jzb)fSyxp16s2Jzbf98HVG0Jy9bL6aR0DVVdclLjCsgn1WFQWdNfoX1cCJmMfiSvnXubp5elwXCeYaiXuJraXIvm8Ne7dk1bMyvxbVylumg8r7i4lSL9ywWFbl2PmHtYOjFbPhX6dk1bwjWG0JTANVktnoX6ofErKAcenLdQf2iqYOjNp(oFErKAcenV8dcwwKYJLUv93iqYOjNp(oFErKAceThlDR6cY2X)gbsgn58X3PWlIutGOL6SdN4AJajJMC(4785f3PqFCDppP1LiHOO4BpgoCQrGYhl0tvwSVEHTQjw1xWpockg(pauILIXfuQdmXQUcetngbedszhBaOelWiXiabrDvSadsp2QDcBzpMf8xWID9uRlzpMfu0Zh(cspI1huQdSs39(oiSiabrDT5iKPpXTSuMWjz0u7dk1bwjWG0JTANWw1eRkhW8yILHyEPk9vm2FHyQNaBXdXuaNylum1tGjg3QaX6WjeJbhbXxXu4fIPEcmXuaNy1T4XposSpOuhy1JEwXupbMykGtSu)RyidyEmXYqm2FHyjQCaFig7flsikkEXQBXJFCKyFqPoWQxyl7XSG)cwSRNADj7XSGIE(Wxq6rSqgW8y(oiSuMWjz0uJqqOEmkPsF9y2c)oG4vLvNV4LQS88eWvPsF9y2c)oG4Bocz6tCllfRubzqHffi5Ld4VLLI(vMWjz0uJqqOEmkPsF9y2c)oG4vL1nQuHbhbP9x9yw9xwKIJYaRK4X2Ht0W59RmHtYOPgHGq9yusL(6XSf(DaXRkl2xPYZtADjsikk(2JHdNAeO8Xc9uLf79RmHtYOPgHGq9yusL(6XSf(DaXRkl2lSvnXubpjwkgd(ODeum1yeqmiLDSbGsSaJeJaee1vXcmi9yR2jSL9ywWFbl21tTUK9ywqrpF4li9iwm4J257GWIaee11MJqM(e3YszcNKrtTpOuhyLadsp2QDcBvtm0)QM(qmE4SWjUk2ael1AXweXcmsm0SpG(fJH6j(tInHy9e)PxSuSBIQRaHTShZc(lyXUe2tavIfcjq47GWIaee11MJqM(eQYsrfEbbiiQRniHIacBzpMf8xWIDjSNaQWJRFsyl7XSG)cwStpOWIVGEc3HYJaHWw2Jzb)fSyhtIQSiLao9AVWMWw1QMyOdF0oc(cBzpMf8ng8r7y9yJsFhewOnsnbIgyqHfFK6AeSrGKrto)qCaHSquulgW1sSQC6fgD6i)ppP1LiHOO4BpgoCQrGYhl07wfkSL9ywW3yWhT7cwS7XWHtncu(yHE(oiSEEsRlrcrrXRkR78xhA7RscKGObOoC1l0vPsFxTBvdApbHzqUcZcOYZp1OMxQYshlHOOxf7yjef9fey2JzbPwvw(SDNcRu55jTUejeffF7XWHtncu(yHEQY(69xhdocsJNGilmdYvusd4BFK9A3YI9vQ88KwxIeIIIV9y4WPgbkFSqpvzVF0QmHtYOPg(tfE4SWjUwGBKXSG6f2YEml4Bm4J2Dbl29eeMb5kmlGkp)uJ8DqyXGJG04jiYcZGCfL0a(2hzV2TSUZFD9D1UvnO9eeMb5kmlGkp)uJAEPklDSeIIEvSJLqu0xqGzpMfK6Bz5Z2DkSsLFX1mdW10u6kmxlKktpEn1iqYOjNF0YGJG00u6kmxlKktpEn1W5Ru5xCnZaCTAKYb8LDrpdPhaQgbsgn58JwhXGJG0QrkhWxudZaRHZxVWw2JzbFJbF0UlyXou6D9y0PJe2QMyOl71(izeB88i3KbPVkgoqt)lwGrIbivgIvDFqS5fdndgVSJLquKtSe4etnjM6fu1qSEYlgbiiQRIPoNyaOedzHInrtyl7XSGVXGpA3fSyht2R9rY47GWcT9vjbsq0QDfojOsf0wNYeojJMAZxaKkJsNVKGXl7yjef58xxmEuj2YJfTB0414)T(SPWkvIXJkXwESOX(gVg)VvX69tacI66TvHpRxytyRAIv9D1Uvn4f2QMyQGNetbjOtITiiQiQUtmgczHKybgjgYa)qmomC4uJaIXfl0tme46j2LleKUvS(6rVydOjSL9ywW36UN1JLUvDXLGo5l(tLfbPGQ7yPOVdcl0YGJG0ES0TQlUe0PgoVFgCeK2JHdNAeOeleKUTHZ7NbhbP9y4WPgbkXcbPBBqYlhWFlRB0uOWw1eRovaqt)lwQHu6UkgoVymupXFsm1KyXU1eJdlDRAXQYTJ)1lg(tIXD1Jz1VylcIkIQ7eJHqwijwGrIHmWpeJddho1iGyCXc9edbUEID5cbPBfRVE0l2aAcBzpMf8TU7VGf7(REmR(llsXrzG5l(tLfbPGQ7yPOVdclgCeK2JHdNAeOeleKUTHZ7NbhbP9y4WPgbkXcbPBBqYlhWFlRB0uOWw2JzbFR7(lyXoeDII06mMf47GWszcNKrtTh4k9f4MywGF0(bL6aJCnVeeAYFDppP1LiHOO4BpgoCQrGYhl07wwk6VVR2TQbT)QhZQ)YIuCugynCE)OnsnbI2JLUvDbz74FJajJMCvQWGJG0(REmR(llsXrzG1W5R3FF9y2c)oG4vLLcf2YEml4BD3Fbl2PmbZJ57GWQoioGqwikQ5LWALfPeyuXl)GGL8)8)b4VVEmBHFhq8nhHm9jULLIQyKAcenhr8eS8bmdcf51iqYOjxLkqCaHSquuZrzGPVwES0TQF)91Jzl87aI)wfR3pdocs7V6XS6VSifhLbwdN3pdocs7Xs3QU4sqNA48(9Ypiyj)p)Fafi5Ld4z5t)m4iinhLbM(A5Xs3Q(BUvnqyRAI5d7QfdzHID5cbPBfJhsQi3QaXupbMyCykqmiLURIPgJaIb2qmioamauIXvLnHTShZc(w39xWID87Qlq6xCyN8fzHfaPYGLI(oiSIutGO9y4WPgbkXcbPBBeiz0KZpAJutGO9yPBvxq2o(3iqYOjNWw1etf8KyxUqq6wX4HKyCRcetngbetnjgwQKelWiXiabrDvm1yuGrqXqGRNy87QhakXupb2IhIXvLITqXqpH)HyOiabtT(Atyl7XSGV1D)fSy3JHdNAeOeleKU13bH1ZtADjsikk(2JHdNAeO8Xc9ULLI(jabrDvvwvHp9RmHtYOP2dCL(cCtmlWFFxTBvdA)vpMv)LfP4OmWA48(77QDRAq7Xs3QU4sqNADSeIIEvzPO)6qlehqilef1wgYneOtvQ4igCeKgIorrADgZcA48vQ88KwxIeIIIV9y4WPgbkFSqpvzvNIxWEFCDOnsnbIgyqHfFK6AeSrGKrto)OnsnbIMlH1kpw6w1ncKmAYvF917VVEmBHFhq83Y6o)OLbhbPXdjpYnrgZcA48(RdT9vjbsq0usGa7kSsf023v7w1GgIorrADgZcA481lSL9ywW36U)cwS7jimdYvywavE(Pg5B)AxtLiHOO4zPOVdclLjCsgn1EGR0xGBIzb(rRBJ2tqygKRWSaQ88tnQ42OftV2aq5psikkAX4rLylUHuL1Dk6VU(6XSf(DaX3CeY0Nqvw115lOYbO6nz2xF9(rldocs7XWHtncuIfcs32W59xhAzWrqA8qYJCtKXSGgoFLkppP1LiHOO4BpgoCQrGYhl0tv2xFLkidkSOajVCa)TSuO)NN06sKquu8Thdho1iq5Jf6D7ne2YEml4BD3Fbl29e)pVVdclLjCsgn1EGR0xGBIzb(7RhZw43beFZritFcvzPO)iHOOOfJhvIT4gsvwkwfcBvtmvWtIXD1Jz1VylqS(UA3QgiwDjsqqXqg4hIXbuq9IHd00)IPMelHKyO2bGsSyfJF5f7Yfcs3kwcCI5wXaBigwQKeJdlDRAXQYTJ)nHTShZc(w39xWID)vpMv)LfP4OmW8DqyvhA)GsDGrUwQ1vQWGJG04jiYcZGCfL0a(2hzV2TSVE)kt4KmAQ9axPVa3eZc8xhAJutGO9y4WPgbkXcbPBBeiz0KRsLi1eiApw6w1fKTJ)ncKmAYvPYZtADjsikk(2JHdNAeO8Xc9uL1DvQ03v7w1G2JHdNAeOeleKUTbjVCaVQ3vV)6qBFvsGeenLeiWUcRuPVR2TQbneDII06mMf0GKxoGxvf9zLk9D1UvnOHOtuKwNXSGgoV)(6XSf(DaXRklfwVWw1e7MJiw6CVyjKedN3xXEWWtIfyKylGet9eyIPx10hID5LkOjMk4jXuJraXCxhakXqYpiOybwceR6(Gyocz6ti2cfdSHyFqPoWiNyQNaBXdXsWvXQUp0e2YEml4BD3Fbl25LWAKRGSWIJYaZx9aOs3XsXMc9TFTRPsKquu8Su03bHfmhxHusGOLo33W59xxKquu0IXJkXwCdDBF9y2c)oG4Bocz6tuPcA)GsDGrUwQ1(7RhZw43beFZritFcvz15lEPklppbC1lSvnXU5iIbwXsN7ft9O1I5gsm1tGnaXcmsmaPYqSB4Z3xXWFsmFeIceBbIXS)lM6jWw8qSeCvSQ7dnHTShZc(w39xWIDEjSg5kilS4OmW8DqybZXviLeiAPZ9TbO6n8PkcZXviLeiAPZ9nhomJzb(7RhZw43beFZritFcvz15lEPklppbCcBzpMf8TU7VGf7ES0TQlm60rVVdclLjCsgn1EGR0xGBIzb(7RhZw43beFZritFcvzDN)6yWrqA)vpMv)LfP4OmWA48vQWS)7hzqHffi5Ld4VL1D(Ssf0YGJG0ES0TQlm60rFdN3)trHzb4FlgcEhAQChFVEHTShZc(w39xWIDuhBhaQcK4HJxcC(oiSq7huQdmY1sT2VYeojJMApWv6lWnXSa)91Jzl87aIV5iKPpHQSUZFDkt4KmAQH)uHholCIRf4gzmlOsLNN06sKquu8Thdho1iq5Jf6Dll2xPcehqilef1G0V4a3aqv66eoX16f2QMyOVjWeJRk9vSbrmWgILAiLURI5wa5Ry4pj2LleKUvm1tGjg3QaXW5BcBzpMf8TU7VGf7EmC4uJaLyHG0T(oiSQlsnbI2JLUvDbz74FJajJMCvQ88KwxIeIIIV9y4WPgbkFSqpvzDx9(vMWjz0u7bUsFbUjMf4NbhbP9x9yw9xwKIJYaRHZ7VVEmBHFhq83Y6o)1HwgCeKgpK8i3ezmlOHZxPYZtADjsikk(2JHdNAeO8Xc9uL91lSL9ywW36U)cwS7Xs3QU4sqN8DqyHwgCeK2JLUvDXLGo1W59JmOWIcK8Yb83YcnDrKAceThNjiicokQrGKrtoHTShZc(w39xWIDiA6X6Wej8Dqyv3V4AMb4A84FGRPcbX5JzbvQ8lUMzaUMYvNXOPYVALeiQ3pbiiQRnhHm9juL1n8PF0(bL6aJCTuR9ZGJG0(REmR(llsXrzG1CRAGVdiiieNpkJNh5Mmiwk67acccX5Jck9YKAwk67acccX5JYGW6xCnZaCnLRoJrtLF1kjqiSL9ywW36U)cwSJFJzb(oiSyWrqAm6DDA8pAqk7rLkidkSOajVCa)T3WNvQWGJG0(REmR(llsXrzG1W59xhdocs7Xs3QUWOth9nC(kv67QDRAq7Xs3QUWOth9ni5Ld4VLLI(SEHTShZc(w39xWIDm6DDfeC4vFhewm4iiT)QhZQ)YIuCugynCEHTShZc(w39xWIDme8jyTbGY3bHfdocs7V6XS6VSifhLbwdNxyl7XSGV1D)fSyhYajg9UoFhewm4iiT)QhZQ)YIuCugynCEHTShZc(w39xWIDjOtFatDPNATVdclgCeK2F1Jz1FzrkokdSgoVWw2JzbFR7(lyXo8NktqE(cspIvp7yuzrkzh9aFGKReqkFCi9(oiSyWrqAzh9aFGKRKQKA48(R75jTUejeffF7XWHtncu(yHESu0pmhxHusGOLo33gGQvHpRu55jTUejeffF7XWHtncu(yHEQQy9vQWS)7hzqHffi5Ld4V9ofkSvnXuaHK46qmKuRzYEnXqwOy4FYOjXMG8E0RyQGNet9eyIXD1Jz1VylIykGYaRjSL9ywW36U)cwSd)PYeK377GWIbhbP9x9yw9xwKIJYaRHZxPcYGclkqYlhWF7D(uytyRAvtSQCaZJrWxyRAIH(Wgnjg(pauI5dqYJCtKXSaFflvUJtSE(XaqjgNE6KyjWjMcMojMAmcighw6w1IPGe0jXMxSFxGyXkgdjg(toFfJuzN4dXqwOyQWVcNeiSL9ywW3qgW8ySuMWjz0KVG0JyXdjpYvEGR0xGBIzb(Qm14eRi1eiA8qYJCtKXSGgbsgn58)8KwxIeIIIV9y4WPgbkFSqVBRtHQyFvsGeena1HREHU69J2(QKajiA1UcNeiSL9ywW3qgW8yxWIDVE6ujbUIB6KVdcl0QmHtYOPgpK8ix5bUsFbUjMf4)5jTUejeffF7XWHtncu(yHE3wf(rldocs7Xs3QU4sqNA48(zWrqAVE6ujbUIB6udsE5a(BrguyrbsE5aE)qcbspwYOjHTShZc(gYaMh7cwS71tNkjWvCtN8DqyPmHtYOPgpK8ix5bUsFbUjMf4VVR2TQbThlDR6IlbDQ1Xsik6liWShZcs9Tk2Uzk0pdocs71tNkjWvCtNAqYlhWFBFxTBvdA)vpMv)LfP4OmWAqYlhW7VU(UA3Qg0ES0TQlUe0PgKs3v)m4iiT)QhZQ)YIuCugyni5Ld4vrgCeK2JLUvDXLGo1GKxoG)wfB3vVWw1e7MeP5jOyQqjCsgnjgYcfdnGZh4qQjgxTHxmhoCaOeZhLFqqXqZ)N)paXwOyoC4aqjMcsqNet9eyIPGewtSe4edSID)Gcl(i11iytyl7XSGVHmG5XUGf7uMWjz0KVG0Jy91g(ceNpWHKVktnoXYl)GGL8)8)buGKxoGxvFwPcAJutGObguyXhPUgbBeiz0KZFKAcenxcRvES0TQBeiz0KZpdocs7Xs3QU4sqNA48vQ88KwxIeIIIV9y4WPgbkFSqpvzvh7vXpOuhyKRLATposnbI2JLUvDbz74FJajJMC1lSvnXuHteVy48IHgW5dCij2Gi2eInVyjZIhIfRyqCGylE0e2YEml4BidyESlyXoioFGdjFhewO9dk1bg5APw7Vo0QmHtYOP2xB4lqC(ahsvQOmHtYOPg(tfE4SWjUwGBKXSG69hjeffTy8OsSf3qQiK8Yb8Qwf(HecKESKrtcBzpMf8nKbmp2fSy3tDifLG6yGb9aNe2QMy(iCDmUnIbGsSiHOO4flWYqm1JwlMEusIHSqXcmsmhomJzbITiIHgW5dCi5RyqcbspMyoC4aqjgFcCK30BcBzpMf8nKbmp2fSyheNpWHKV9RDnvIeIIINLI(oiSqRYeojJMAFTHVaX5dCi5hTkt4KmAQH)uHholCIRf4gzmlW)ZtADjsikk(2JHdNAeO8Xc9uL1D(JeIIIwmEuj2IBivzvNcVOU78X91Jzl87aIV(69djei9yjJMe2QMyObcbspMyObC(ahsIrjuFvSbrSjet9O1IrQKFGKyoC4aqjg3vpMv)nXuWkwGLHyqcbspMydIyCRcedffVyqkDxfBaIfyKyasLHyk8BcBzpMf8nKbmp2fSyheNpWHKVdcl0QmHtYOP2xB4lqC(ahs(HKxoG)2(UA3Qg0(REmR(llsXrzG1GKxoG)cf9P)(UA3Qg0(REmR(llsXrzG1GKxoG)wwk0FKquu0IXJkXwCdPIqYlhWRAFxTBvdA)vpMv)LfP4OmWAqYlhWFHcf2YEml4BidyESlyXogD2Rv4x1oc67GWcTkt4KmAQH)uHholCIRf4gzmlW)ZtADjsikkEvzDdHTShZc(gYaMh7cwSJuoFNGzqcBcBvRAIXfuQdmXQ(UA3Qg8cBvtSBsKMNGIPcLWjz0KWw2JzbF7dk1bwP7Ewkt4KmAYxq6rSEmxjWG0JTANVktnoXQVR2TQbThlDR6IlbDQ1Xsik6liWShZcsTQSuSDZuOWw1etfkbZJj2GiMAsSesI1tE(bGsSfiMcsqNeRJLqu03etfwc1xfJHqwijgYa)qmxc6KydIyQjXWsLKyGvS7huyXhPUgbfJbpetbjSMyCyPBvl2aeBHockwSIHIcXqd48boKedNxS6aRy(O8dckgA()8)buFtyl7XSGV9bL6aR0D)fSyNYempMVdcR6qRYeojJMApMReyq6XwTRsf0gPMardmOWIpsDnc2iqYOjN)i1eiAUewR8yPBv3iqYOjx9(7RhZw43beFZritFcvv0pAH4aczHOOMxcRvwKsGrfV8dcwY)Z)hGWw1eZh2vlgYcfJdlDRAps7e7cX4Ws3Q(d4uJedhOP)ftnjwcjXsMfpelwX6jVylqmfKGojwhlHOOVj2nnqFvm1yeqSQCaoXqFuwdq)l28ILmlEiwSIbXbIT4rtyl7XSGV9bL6aR0D)fSyh)U6cK(fh2jFrwybqQmyPOVKkdywsVfheSyVp9DqybZo1adkSOqAeHTShZc(2huQdSs39xWIDpw6w1EK257GWIaee1vvzXEF6Naee11MJqM(eQYsrF6hTkt4KmAQ9yUsGbPhB1o)91Jzl87aIV5iKPpHQkkSvnXQUpiwGbPhB1UxmKfkgbccoauIXHLUvTykibDsyl7XSGV9bL6aR0D)fSyNYeojJM8fKEeRhZv6RhZw43beVVktnoXQVEmBHFhq8nhHm9juL1DxWGJG0ES0TQlm60rFdNxyl7XSGV9bL6aR0D)fSyNYeojJM8fKEeRhZv6RhZw43beVVktnoXQVEmBHFhq8nhHm9juL1n8Dqy1xLeibrR2v4KaHTShZc(2huQdSs39xWIDkt4KmAYxq6rSEmxPVEmBHFhq8(Qm14eR(6XSf(DaX3CeY0N4wwk67GWszcNKrtn8Nk8WzHtCTa3iJzb(FEsRlrcrrX3EmC4uJaLpwONQSyVWw1etbjOtI5WHdaLyCx9yw9l2cflzwLKybgKESv7AcBzpMf8TpOuhyLU7VGf7ES0TQlUe0jFhew1vNYeojJMApMR0xpMTWVdiE)113v7w1G2F1Jz1FzrkokdSgK8Yb8QYsXQOsf0cXbeYcrrTaJkWnccuFLkkt4KmAQ9yUsGbPhB1UkvG4aczHOOwGrf4gbb833v7w1G2F1Jz1FzrkokdSgK8Yb83YcnvV)NIcZcW)wme8o0u5o(U)(QKajiA1UcNeuPIYeojJMApMR0xpMTWVdiE)1XGJG0(REmR(llsXrzG1GKxoGxvwk2URsfLjCsgn1EmxjWG0JTAx9vQWGJG06y5(fMeqnC(kvEEsRlrcrrX3EmC4uJaLpwONQSyV)(UA3Qg0(REmR(llsXrzG1GKxoGxvf9z9(RJbhbPXtqKfMb5kkPb8TpYETBzFLkppP1LiHOO4BpgoCQrGYhl0t1BuVWw1edD4qGykibD6fRJLqu0l2Gi21fxmEDEvmfKWAIXHLUv9Zo0So7WjUk2cfJHqwijwGrIHmOWcXiG7fBqeJBvGyQxqvdXyiXGu6Uk2aelgpQjSL9ywW3(GsDGv6U)cwS7Xs3QU4sqN8DqyPmHtYOP2J5k91Jzl87aI3pYGclkqYlhWFBFxTBvdA)vpMv)LfP4OmWAqYlhWxPcAJutGOraLKE5haQYJLUv93iqYOjNWMWw1QMyCbL6aJCIHg2iJzbcBvtSBoIyCbL6aJDktW8yILqsmCEFfd)jX4Ws3Q(d4uJelwXyiaHmHyiW1tSaJeJp)FusIXSa8xSe4eRkhGtm0hL1a0)(kgPKaIniIPMelHKyziMxQsXQUpiwD4an9Vy4)aqjMpk)GGIHM)p)Fa1lSL9ywW3(GsDGrowpw6w1FaNAKVdcR6yWrqAFqPoWA48vQWGJG0uMG5XA4817VUNN06sKquu8Thdho1iq5Jf6Dl7RurzcNKrtn8Nk8WzHtCTa3iJzb173l)GGL8)8)buGKxoGNLpf2QMyv5aMhtSme7gxiw19bXupb2IhIPaoXyNyS)cXupbMykGtm1tGjghgoCQraXUCHG0TIXGJGigoVyXkwQChNy)6rIvDFqm15hKy)e4zml4BcBvtm0S(xX(eHelwXqgW8yILHyS)cXQUpiM6jWeJuz2d9vXyVyrcrrX3eRoU0JelFXw84hhj2huQdSw9cBvtSQCaZJjwgIX(leR6(GyQNaBXdXuaNVIPWlet9eyIPaoFflboXQcXupbMykGtSejiOyQqjyEmHTShZc(2huQdmYDbl21tTUK9ywqrpF4li9iwidyEmFhewkt4KmAQriiupgLuPVEmBHFhq8QYQZx8svwEEc4QuHbhbP9y4WPgbkXcbPBB48(7RhZw43beFZritFIBzDxLkppP1LiHOO4BpgoCQrGYhl0tvwS3VYeojJMAecc1Jrjv6RhZw43beVQSyFLk91Jzl87aIV5iKPpXTSuufRlsnbIMJiEcw(aMrII8Aeiz0KZpdocstzcMhRHZxVWw2JzbF7dk1bg5UGf7ES0TQ)ao1iFhewFqPoWix7j(FE)ppP1LiHOO4BpgoCQrGYhl07w2lSvnXqx2R9rYiMdhoauIXHLUvTykibDsm1yeqSfig2GctmFqfsSpYETxSe4eJdlDRAXqNoD0l28IHZ3e2YEml4BFqPoWi3fSyht2R9rY47GWQVah(enEcISWmixrjnGVbtqnvzHM8ZGJG04jiYcZGCfL0a(2hzVMQSuOFgCeK2JLUvDXLGo1GKxoGxvw3Wpdocs7Xs3QUWOth9nCE)198KwxIeIIIV9y4WPgbkFSqVBzDJkvuMWjz0ud)PcpCw4exlWnYywq9(RJbhbP9yPBvxy0PJ(gK8Yb83YIbhbP9yPBvxCjOtni5Ld4V4UkvqBFvsGeenLeiWUcRxyl7XSGV9bL6aJCxWIDp2O03bHvKAcenWGcl(i11iyJajJMC(H4aczHOOwmGRLyv50lm60r(FEsRlrcrrX3EmC4uJaLpwO3TkuyRAIPc4flwXUHyrcrrXlwDGvmE4S1lwnI4fdNxSQCaoXqFuwdq)lgZvX6x76bGsmoS0TQ)ao1OMWw2JzbF7dk1bg5UGf7ES0TQ)ao1iF7x7AQejeffplf9DqyHwLjCsgn1WFQWdNfoX1cCJmMf43rm4iinKb4kQPSgG(VbjVCa)Tk6)5jTUejeffF7XWHtncu(yHE3Y6g(JeIIIwmEuj2IBivesE5aEvRcHTQjwvUqX4HZcN4QyWnYywGVIH)KyCyPBv)bCQrITkjOyCXc9et9eyIH(8rILOYb8Hy48IfRySxSiHOO4fBHIniIvLOpXMxmioamauITiiIv3celbxfl9wCqi2IiwKquu81lSL9ywW3(GsDGrUlyXUhlDR6pGtnY3bHLYeojJMA4pv4HZcN4AbUrgZc8xNJyWrqAidWvutzna9FdsE5a(BvSsLi1eiAQPKFbE5heSrGKrto)ppP1LiHOO4BpgoCQrGYhl07wwSVEHTShZc(2huQdmYDbl29y4WPgbkFSqpFhewppP1LiHOO4vL1nUOogCeKwGrf4gbbA48vQaXbeYcrrTSwMW5l)IRliWeLhbIkvEkkmla)BXqW7qtL747(JutGO9yPBvxq2o(3iqYOjx9(RJbhbP9x9yw9xwKIJYaRK4X2Ht0W5RubTm4iinEi5rUjYywqdNVsLNN06sKquu8QYsH1lSvnX4Ws3Q(d4uJelwXGecKEmXQYb4ed9rzna9VyjWjwSIrGhhsIPMeRNaX6jeEvSvjbflfdbxRfRkrFInGyflWiXaKkdX4wfi2Gig)()WOPMWw2JzbF7dk1bg5UGf7ES0TQ)ao1iFhewoIbhbPHmaxrnL1a0)ni5Ld4VLLIvQ03v7w1G2F1Jz1FzrkokdSgK8Yb83QiAYVJyWrqAidWvutzna9FdsE5a(B77QDRAq7V6XS6VSifhLbwdsE5aEHTShZc(2huQdmYDbl2HsVRhJoDKVdclgCeKgpbrwygKROKgW3(i71uLLc93xGdFIgpbrwygKROKgW3GjOMQSu8gcBzpMf8TpOuhyK7cwS7Xs3Q(d4uJe2YEml4BFqPoWi3fSyxhJs(YJTHVdcl0gjeffT5lm7)(7RhZw43beFZritFcvzPOFgCeK2JTrzaLaJkUewRHZ7Naee11wmEuj2c79PQO6UMxQYtCIZba]] )

    
end
