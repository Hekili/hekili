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


    spec:RegisterPack( "Subtlety", 20220318, [[div6AcqiiLEKKiBIs1NKeAusQCkjvTksO0Rujmlss3IeQ2Lu(fkfdJKshJeSmvQ8mvk10qP01ijSnjb(gjumoif5CQusADqQkVJKifnpvkUhkzFKu9pjbvDqivPfcPYdLe1ejHCrifL2OkL4JsckJusqLtQsj1krP6LKePAMqQIBkji7uLQ(PkLedLKOwkKc9uuzQQeDvsIyRKejFfsv1yHuWzjjsP9QI)kXGP6WIwmkESunzkUmYMH4ZqYOHYPvSAiffVwsz2K62uYUb(TsdhvDCifvlh0Zv10fUouTDs03PugpjfNxL06jjsH5ljTFIpkCU8WzYGo3FNAV7o1EBfqtT7UTcS9ofZHlUYtho(SxlrrhoqArhooCMqtX1dhFEvVP5C5H7xCyNoCyrW)Op2WgutGHZ06RfB(XcxNXSGomrc28JvNnhog8rh3AWH5WzYGo3FNAV7o1EBfqtT7UTcS9U7oCjEGTWdh3yv5dh2yme4WC4m03pCC4mHMIRIJgxu4KWEfkHDmXvqXOQ43P27UtyxyVYyjaf9OpHDfx8k0QKexzcNKrtn8Nk8WzHtCTa3iJzbIJZl(VIpH4Zl(tH4meYcjXTrIJ)K4t0e2vCXR8AXmasClCDm8As8EQ1LShZck65dXjqah6fpwXHKbVtIZVbbIj1IdjBlSwtyxXfVcL1iXVfn9yDyIeIpGGGqC(q8biEFTyYq8brCBK4OzW)qCZyeFcXrwO4kxDgJMk)QvsGOD40Zh)5Yd3huQdmYCU8CVcNlpCeiz0K5GUdx2JzbhUhlnRTpGtn6WzOVdh(ywWH7wJioxqPoWyJYempM4jKehNxvXXFsCoS0S2(ao1iXJvCgcqitiocCTepWiX5Z)hLK4mla)fpbgXVLbyeh9tzna9VQItkjG4dI42iXtijEgIBLQr8kRYIxhoqt)lo(pauIxHYpiO4O3)Z)hq9hUoCcco5HRoXzWrqAFqPoWA48IxTQ4m4iinLjyESgoV41lUDXRt8NN06sKquu8Thdho1iq5JfAj(nIZwXRwvCLjCsgn1WFQWdNfoX1cCJmMfiE9IBxCR8dcwY)Z)hqbsw5aEXzjUApX5(7oxE4iqYOjZbDhod9D4WhZcoC3YaMht8meNTxiELvzXTnb2IhIRiovfxfxiUTjWexrCQkEcmIxbIBBcmXveN4jsqqXvPsW8yhUShZcoC9uRlzpMfu0ZhhUoCcco5HtzcNKrtncbH6XOKk91Izl87aIxC1zjENVyLQP88eWiE1QIZGJG0EmC4uJaLyHG0SnCEXTlEFTy2c)oG4Bgcz6ti(nSe)oXRwv8NN06sKquu8Thdho1iq5JfAjU6SeNTIBxCLjCsgn1ieeQhJsQ0xlMTWVdiEXvNL4Sv8QvfVVwmBHFhq8ndHm9je)gwIRG4kU41jEKAcendr8eS8bmJefz1iqYOjJ42fNbhbPPmbZJ1W5fV(dNE(Oasl6WHmG5XoX5(BFU8WrGKrtMd6oCD4eeCYd3huQdmY0EI)NxC7I)8KwxIeIIIV9y4WPgbkFSqlXVrC2E4YEml4W9yPzT9bCQrN4CpBpxE4iqYOjZbDhUShZcoCmzV2hjZHZqFho8XSGdh6YETpsgXn4WbGsCoS0S2exrjOtIBdJaIVaXXguyIRYQuI)r2R9INaJ4CyPzTjo60PHEXNxCC(2HRdNGGtE46lWGprJNGilmdYuusd4BWeutC1zjoAsC7IZGJG04jiYcZGmfL0a(2hzVM4QZsCviUDXzWrqApwAwBftc6udsw5aEXvNL43wC7IZGJG0ES0S2km60qFdNxC7IxN4ppP1LiHOO4BpgoCQrGYhl0s8Byj(TfVAvXvMWjz0ud)PcpCw4exlWnYywG41lUDXRtCgCeK2JLM1wHrNg6BqYkhWl(nSeNbhbP9yPzTvmjOtnizLd4f)cXVt8QvfhTI3xLeibrtjbcSRqXR)eN7vX5YdhbsgnzoO7W1HtqWjpCrQjq0adkS4JuxJGncKmAYiUDXH4aczHOOwmGRLyvZ0lm60qncKmAYiUDXFEsRlrcrrX3EmC4uJaLpwOL43iUkoCzpMfC4ESr5jo3xbNlpCeiz0K5GUdx2JzbhUhlnRTpGtn6W1V21ujsikk(Z9kC46Wji4Kho0kUYeojJMA4pv4HZcN4AbUrgZce3U4gIbhbPHmatXgL1a0)nizLd4f)gXvqC7I)8KwxIeIIIV9y4WPgbkFSqlXVHL43wC7IhjeffTySOsSfZqIR4IdjRCaV4QlEfC4m03HdFml4WPs4fpwXVT4rcrrXlEDGvCE4S1lEnI4fhNx8BzagXr)uwdq)loZvX7x76bGsCoS0S2(ao1O2jo3RyoxE4iqYOjZbDhUShZcoCpwAwBFaNA0HZqFho8XSGd3TSqX5HZcN4Q4WnYywGQIJ)K4CyPzT9bCQrIVkjO4CXcTe32eyIJ(RqINOYb8H448IhR4Sv8iHOO4fFHIpiIFlOFXNxCioamauIViiIx3cepbxfpTwCqi(IiEKquu81F46Wji4KhoLjCsgn1WFQWdNfoX1cCJmMfiUDXRtCdXGJG0qgGPyJYAa6)gKSYb8IFJ4kiE1QIhPMarZgL8lWk)GGncKmAYiUDXFEsRlrcrrX3EmC4uJaLpwOL43WsC2kE9N4CpA6C5HJajJMmh0D46Wji4KhUNN06sKquu8IRolXVT4xiEDIZGJG0cmQa3iiqdNx8QvfhIdiKfIIAzTmHZx(fxxqGjklcencKmAYiE1QI)uuywa(3IHG3HMk3X3f3U4rQjq0ES0S2kiBh)Beiz0Kr86f3U41jodocs7VAXS6VSifdLbwjXJTdNOHZlE1QIJwXzWrqA8qYImtKXSGgoV4vRk(ZtADjsikkEXvNL4Qq86pCzpMfC4EmC4uJaLpwO1jo3FREU8WrGKrtMd6oCzpMfC4ES0S2(ao1OdNH(oC4JzbhooS0S2(ao1iXJvCiHaPht8BzagXr)uwdq)lEcmIhR4e4XHK42iX7jq8EcHxfFvsqXtXrW1AXVf0V4diwXdmsCaPMqCUvrIpiIZV)pmAQD46Wji4KhodXGJG0qgGPyJYAa6)gKSYb8IFdlXvq8QvfVVR2S2aT)QfZQ)YIumugynizLd4f)gXvanjUDXnedocsdzaMInkRbO)BqYkhWl(nI33vBwBG2F1Iz1FzrkgkdSgKSYb8N4CVcQ9C5HJajJMmh0D46Wji4KhogCeKgpbrwygKPOKgW3(i71exDwIRcXTlEFbg8jA8eezHzqMIsAaFdMGAIRolXv42hUShZcoCO07AXOtdDIZ9kOW5Ydx2JzbhUhlnRTpGtn6WrGKrtMd6oX5EfU7C5HJajJMmh0D46Wji4Kho0kEKquu0MVWS)lUDX7RfZw43beFZqitFcXvNL4kiUDXzWrqAp2gLbucmQysyTgoV42fNaee11wmwuj2cBvR4QloQUPzLQ5WL9ywWHRJrjF5X24eN4WziKexhNlp3RW5Ydx2JzbhUAtV2HJajJMmh0DIZ93DU8WrGKrtMd6oCl)H7P4WL9ywWHtzcNKrthoLPgNoCm4iiTxpDQKatXmDQHZlE1QI)8KwxIeIIIV9y4WPgbkFSqlXvNL4vWHZqFho8XSGdNk5jJ4XkUHccAnasCByuGrqX77QnRnWlUTCcXrwO4Cafjot(Kr8fiEKquu8TdNYewaPfD4EGP0xGzIzbN4C)TpxE4iqYOjZbDhUL)W9uC4YEml4WPmHtYOPdNYuJthogCeK2RNovsGPyMo1W5fVAvXFEsRlrcrrX3EmC4uJaLpwOL4QZs8k4WPmHfqArhUhyk9fyMywWjo3Z2ZLhocKmAYCq3HB5pCpfhUShZcoCkt4KmA6WPmHfqArhU5lasnrPZxsWyLDSeIImhUoCcco5HRVkjqcIwTRWjbhod9D4WhZcoCvgJ61epwXFIeFqepWiXbKAcXRSklEDdq8aJeNusGq8fr8uCoSlfNhU96fFEXrVGXk7yjefzoCktnoD46RfZw43beV4SexbXTlodocsJ6y7aqvGepCSsGPCxdNx8QvfVVwmBHFhq8IZs87e3U4m4iinQJTdavbs8WXkbMYTB48IxTQ491Izl87aIxCwIFBXTlodocsJ6y7aqvGepCSsGPW2goV4vRkEFTy2c)oG4fNL4SvC7IZGJG0Oo2oaufiXdhReykQOHZFIZ9Q4C5HJajJMmh0D4w(d3tXHl7XSGdNYeojJMoCktnoD4ieeQhJsQ0xlMTWVdi(dNH(oC4Jzbho0BVV4GqCKfkoh2LIdPShZcepglsCMRIpOalCaOexV2u8kRYINGXk7yjefze3kJog9IpaXdmsC12uXlopK6ezgakXtX53GaXKAX5WUuCE42pCktybKw0HJqqOEmkPsFTy2c)oG4pX5(k4C5HJajJMmh0D4w(d3tXHl7XSGdNYeojJMoCktnoD46RfZw43be)HRdNGGtE46RscKGOv7kCsG42fNqqOEmkPsFTy2c)oG4fxDX7RfZw43beV42fVVwmBHFhq8ndHm9jexDXVtC7IhJfvIT8yrHxJ)n2k(nIR2Mke3U4OvCLjCsgn1MVai1eLoFjbJv2XsikYC4uMWciTOdhHGq9yusL(AXSf(DaXFIZ9kMZLhocKmAYCq3HB5pCpfhUShZcoCkt4KmA6WPm140HJholCIRf4gzmlqC7I)8KwxIeIIIV9y4WPgbkFSqlXvNL43D4m03HdFml4WDRa0xfVJLauK4WnYywG4dI42iXXsLK48WzHtCTa3iJzbI)uiEcmIBHRJHxtIhjeffV448TdNYewaPfD4WFQWdNfoX1cCJmMfCIZ9OPZLhocKmAYCq3HZqFho8XSGdxLXOEnXRSIEXZqCKb(XHl7XSGdxp16s2Jzbf98XHtpFuaPfD46M)eN7VvpxE4iqYOjZbDhUShZcoCVE6ujbMIz60HZqFho8XSGdh6LNxFvCo90jXtGrCfnDs8me)UleVYQS4gC4aqjEGrIJmWpexb1k(t9fyEvfprcckEGLH4S9cXRSkl(Gi(eItQHFG0lUTjWgG4bgjoGutiEfwLvK4lu85fhSH448hUoCcco5H75jTUejeffF7XWHtncu(yHwIFJ4vG42fhzqHffizLd4fxDXRaXTlodocs71tNkjWumtNAqYkhWl(nIJQBAwPAe3U491Izl87aIxC1zjoBfxXfVoXJXIe)gXvqTIxV4kwXV7eN7vqTNlpCeiz0K5GUdNH(oC4Jzbho0ioqCeCT(Q4VTj6y0lESIhyK4CbL6aJmIJg3iJzbIxhZvXn7aqj(VQk(eIJSWo9IZVREaOeFqehSb2aqj(8INkZrNmAQ(2Hl7XSGdhehuYEmlOONpoCD4eeCYd3huQdmY0sT(WPNpkG0IoCFqPoWiZjo3RGcNlpCeiz0K5GUdNH(oC4JzbhovgolCIRIJg3iJzbv4fh9qrfFXrnkjXtX7WKx8KzXdXjabrDvCKfkEGrI)bL6at8kROx86yWhTHGI)XO1IdPNN6H4tuFtCvAX5vv8jeVNaXziXdSme)hlEn1oCzpMfC46PwxYEmlOONpoCD4eeCYdNYeojJMA4pv4HZcN4AbUrgZcoC65JciTOd3huQdSs38N4CVc3DU8WrGKrtMd6oCl)H7P4WL9ywWHtzcNKrthoLPgNoC3PcXVq8i1eiAkhulSrGKrtgXvSIFNAf)cXJutGOzLFqWYIuES0S2(gbsgnzexXk(DQv8lepsnbI2JLM1wbz74FJajJMmIRyf)ovi(fIhPMarl1zhoX1gbsgnzexXk(DQv8le)oviUIv86e)5jTUejeffF7XWHtncu(yHwIRolXzR41F4m03HdFml4WPsEYiESIBiKbqIBdJaIhR44pj(huQdmXRSIEXxO4m4J2qW)WPmHfqArhUpOuhyLadsp2QnN4CVc3(C5HJajJMmh0D4m03HdFml4Wv5f8JHGIJ)daL4P4CbL6at8kRiXTHraXHu2XgakXdmsCcqquxfpWG0JTAZHl7XSGdxp16s2Jzbf98XHRdNGGtE4iabrDTziKPpH43WsCLjCsgn1(GsDGvcmi9yR2C40ZhfqArhUpOuhyLU5pX5Efy75YdhbsgnzoO7WzOVdh(ywWH7wgW8yINH4wPAuvC2EH42MaBXdXveN4luCBtGjo3QiX7WjeNbhbrvXvXfIBBcmXveN41T4Xpgs8pOuhy1RQ42MatCfXjEQ)vCKbmpM4zioBVq8evoGpeNTIhjeffV41T4Xpgs8pOuhy1F4YEml4W1tTUK9ywqrpFC46Wji4KhoLjCsgn1ieeQhJsQ0xlMTWVdiEXvNL4D(IvQMYZtaJ4vRkEFTy2c)oG4Bgcz6ti(nSexbXRwvCKbfwuGKvoGx8ByjUcIBxCLjCsgn1ieeQhJsQ0xlMTWVdiEXvNL43w8QvfNbhbP9xTyw9xwKIHYaRK4X2Ht0W5f3U4kt4KmAQriiupgLuPVwmBHFhq8IRolXzR4vRk(ZtADjsikk(2JHdNAeO8XcTexDwIZwXTlUYeojJMAecc1Jrjv6RfZw43beV4QZsC2E40ZhfqArhoKbmp2jo3RGkoxE4iqYOjZbDhod9D4WhZcoCQKNepfNbF0gckUnmcioKYo2aqjEGrItacI6Q4bgKESvBoCzpMfC46PwxYEmlOONpoCD4eeCYdhbiiQRndHm9je)gwIRmHtYOP2huQdSsGbPhB1MdNE(Oasl6WXGpAZjo3RqfCU8WrGKrtMd6oCzpMfC4sypbujwiKaXHZqFho8XSGdh6zTrFiopCw4exfFaINAT4lI4bgjo6vLrpIZq9e)jXNq8EI)0lEkEfwLv0HRdNGGtE4iabrDTziKPpH4QZsCfuH4xiobiiQRniHIaN4CVckMZLhUShZcoCjSNaQWJRF6WrGKrtMd6oX5EfqtNlpCzpMfC40dkS4lOzWnOSiqC4iqYOjZbDN4CVc3QNlpCzpMfC4ysuLfPeWPx7pCeiz0K5GUtCIdhpK6RftgNlp3RW5Ydx2JzbhUKNxFTWVZVGdhbsgnzoO7eN7V7C5Hl7XSGdhZgHMmfeDELm2gaQsSQzahocKmAYCq3jo3F7ZLhocKmAYCq3HRdNGGtE4(fxZmatJh)dCnviioFmlOrGKrtgXRwv8FX1mdW0uU6mgnv(vRKarJajJMmhUShZcoCiA6X6WejoX5E2EU8WL9ywWH7dk1b2HJajJMmh0DIZ9Q4C5HJajJMmh0D4YEml4WzLWAKPGSWIHYa7WXdP(AXKr5P(cm)HtbvCIZ9vW5YdhbsgnzoO7WL9ywWH71tNkjWumtNoCD4eeCYdhKqG0JLmA6WXdP(AXKr5P(cm)HtHtCUxXCU8WrGKrtMd6oCD4eeCYdhehqilef1SsyTYIucmQyLFqWs(F()aAeiz0K5WL9ywWH7XsZARWOtd9N4ehog8rBoxEUxHZLhocKmAYCq3HRdNGGtE4qR4rQjq0adkS4JuxJGncKmAYiUDXH4aczHOOwmGRLyvZ0lm60qncKmAYiUDXFEsRlrcrrX3EmC4uJaLpwOL43iUkoCzpMfC4ESr5jo3F35YdhbsgnzoO7W1HtqWjpCppP1LiHOO4fxDwIFN42fVoXrR49vjbsq0auhU6fAeVAvX77QnRnq7jimdYuywavE(Pg1Ss1u6yjef9IR4I3Xsik6liWShZcsT4QZsC12UtfIxTQ4ppP1LiHOO4BpgoCQrGYhl0sC1fNTIxV42fVoXzWrqA8eezHzqMIsAaF7JSxt8ByjoBfVAvXFEsRlrcrrX3EmC4uJaLpwOL4QloBf3U4OvCLjCsgn1WFQWdNfoX1cCJmMfiE9hUShZcoCpgoCQrGYhl06eN7V95YdhbsgnzoO7W1HtqWjpCm4iinEcISWmitrjnGV9r2Rj(nSe)oXTlEDI33vBwBG2tqygKPWSaQ88tnQzLQP0Xsik6fxXfVJLqu0xqGzpMfKAXVHL4QTDNkeVAvX)fxZmatttPPWCTqQjT41uJajJMmIBxC0kodocsttPPWCTqQjT41udNx8Qvf)xCnZamTAKYb8LDvPbPhaQgbsgnze3U4OvCdXGJG0QrkhWxSbZaRHZlE9hUShZcoCpbHzqMcZcOYZp1OtCUNTNlpCzpMfC4qP31IrNg6WrGKrtMd6oX5EvCU8WrGKrtMd6oCzpMfC4yYETpsMdNH(oC4Jzbho0L9AFKmIpwwKzYG0xfhhOP)fpWiXbKAcXRSkl(8IJEbJv2XsikYiEcmIBJe32cQyiEp5fNaee1vXTLtmauIJSqXNOD46Wji4Kho0kEFvsGeeTAxHtceVAvXrR41jUYeojJMAZxaKAIsNVKGXk7yjefze3U41jEmwuj2YJffEn(3UT43iUABQq8QvfpglQeB5XIcVg)BSv8BexbXRxC7ItacI6Q43iEfOwXR)eN4W1n)5YZ9kCU8WrGKrtMd6oCD4eeCYdhAfNbhbP9yPzTvmjOtnCEXTlodocs7XWHtncuIfcsZ2W5f3U4m4iiThdho1iqjwiinBdsw5aEXVHL43UPIdh(tLfbPGQBo3RWHl7XSGd3JLM1wXKGoD4m03HdFml4WPsEsCfLGoj(IGO4O6gXziKfsIhyK4id8dX5WWHtncioxSqlXrGRL4xUqqAwX7Rf9IpG2jo3F35YdhbsgnzoO7W1HtqWjpCm4iiThdho1iqjwiinBdNxC7IZGJG0EmC4uJaLyHG0SnizLd4f)gwIF7MkoC4pvweKcQU5CVchUShZcoC)vlMv)LfPyOmWoCg67WHpMfC4QtLa00)INAiLMRIJZlod1t8Ne3gjESBnX5WsZAt8Bz74F9IJ)K4CxTyw9l(IGO4O6gXziKfsIhyK4id8dX5WWHtncioxSqlXrGRL4xUqqAwX7Rf9IpG2jo3F7ZLhocKmAYCq3HRdNGGtE4uMWjz0u7bMsFbMjMfiUDXrR4FqPoWitZkbHMe3U41j(ZtADjsikk(2JHdNAeO8XcTe)gwIRG42fVVR2S2aT)QfZQ)YIumugynCEXTloAfpsnbI2JLM1wbz74FJajJMmIxTQ4m4iiT)QfZQ)YIumugynCEXRxC7I3xlMTWVdiEXvNL4Q4WL9ywWHdrNOiToJzbN4CpBpxE4iqYOjZbDhUoCcco5HRoXH4aczHOOMvcRvwKsGrfR8dcwY)Z)hqJajJMmIBx8(AXSf(DaX3meY0Nq8ByjUcIR4IhPMarZqepblFaZGqrwncKmAYiE1QIdXbeYcrrndLbM(A5XsZA7Beiz0KrC7I3xlMTWVdiEXVrCfeVEXTlodocs7VAXS6VSifdLbwdNxC7IZGJG0ES0S2kMe0PgoV42f3k)GGL8)8)buGKvoGxCwIRwXTlodocsZqzGPVwES0S2(MzTboCzpMfC4uMG5XoX5EvCU8WrGKrtMd6oCg67WHpMfC4u5D1IJSqXVCHG0SIZdjfNBvK42MatComfjoKsZvXTHraXbBioehagakX5UL2HdzHfaPM4CVchUoCcco5HlsnbI2JHdNAeOeleKMTrGKrtgXTloAfpsnbI2JLM1wbz74FJajJMmhUShZcoC87Qlq6xCyNoX5(k4C5HJajJMmh0D4YEml4W9y4WPgbkXcbPzpCg67WHpMfC4ujpj(LleKMvCEijo3QiXTHraXTrIJLkjXdmsCcqquxf3ggfyeuCe4Ajo)U6bGsCBtGT4H4C3I4luC0m4FiokcqWuRV2oCD4eeCYd3ZtADjsikk(2JHdNAeO8XcTe)gwIRG42fNaee1vXvNL4vGAf3U4kt4KmAQ9atPVaZeZce3U49D1M1gO9xTyw9xwKIHYaRHZlUDX77QnRnq7XsZARysqNADSeIIEXvNL4kiUDXRtC0koehqilef1wgYmeOtncKmAYiE1QIBigCeKgIorrADgZcA48IxTQ4ppP1LiHOO4BpgoCQrGYhl0sC1zjEDIRG4xioBfxXkEDIJwXJutGObguyXhPUgbBeiz0KrC7IJwXJutGOzsyTYJLM1wJajJMmIxV41lE9IBx8(AXSf(DaXl(nSe)oXTloAfNbhbPXdjlYmrgZcA48IBx86ehTI3xLeibrtjbcSRqXRwvC0kEFxTzTbAi6efP1zmlOHZlE9N4CVI5C5HJajJMmh0D4YEml4W9eeMbzkmlGkp)uJoCD4eeCYdNYeojJMApWu6lWmXSaXTloAf3Sr7jimdYuywavE(PgvmB0IPxBaOe3U4rcrrrlglQeBXmK4QZs87uqC7IxN491Izl87aIVziKPpH4QZs86eVZxqLdqC1RWloBfVEXRxC7IJwXzWrqApgoCQrGsSqqA2goV42fVoXrR4m4iinEizrMjYywqdNx8Qvf)5jTUejeffF7XWHtncu(yHwIRU4Sv86fVAvXrguyrbsw5aEXVHL4QqC7I)8KwxIeIIIV9y4WPgbkFSqlXVr8BF46x7AQejeff)5EfoX5E005YdhbsgnzoO7W1HtqWjpCkt4KmAQ9atPVaZeZce3U491Izl87aIVziKPpH4QZsCfe3U4rcrrrlglQeBXmK4QZsCfQGdx2JzbhUN4)5pX5(B1ZLhocKmAYCq3Hl7XSGd3F1Iz1FzrkgkdSdNH(oC4JzbhovYtIZD1Iz1V4lq8(UAZAdiEDjsqqXrg4hIZbuu9IJd00)IBJepHK4O2bGs8yfNF5f)YfcsZkEcmIBwXbBiowQKeNdlnRnXVLTJ)TdxhobbN8WvN4Ov8pOuhyKPLAT4vRkodocsJNGilmdYuusd4BFK9AIFJ4Sv86f3U4kt4KmAQ9atPVaZeZce3U41joAfpsnbI2JHdNAeOeleKMTrGKrtgXRwv8i1eiApwAwBfKTJ)ncKmAYiE1QI)8KwxIeIIIV9y4WPgbkFSqlXvNL43jE1QI33vBwBG2JHdNAeOeleKMTbjRCaV4Ql(DIxV42fVoXrR49vjbsq0usGa7ku8QvfVVR2S2aneDII06mMf0GKvoGxC1fxb1kE1QI33vBwBGgIorrADgZcA48IBx8(AXSf(DaXlU6SexfIx)jo3RGApxE4iqYOjZbDhUShZcoCwjSgzkilSyOmWoC6bqLU5WPqtfhU(1UMkrcrrXFUxHdxhobbN8WbZXuiLeiAPX8nCEXTlEDIhjeffTySOsSfZqIFJ491Izl87aIVziKPpH4vRkoAf)dk1bgzAPwlUDX7RfZw43beFZqitFcXvNL4D(IvQMYZtaJ41F4m03HdFml4WDRrepnMx8esIJZRQ4py4jXdms8fqIBBcmX1Rn6dXV8sf1exL8K42WiG4MRdaL4i5heu8albIxzvwCdHm9jeFHId2q8pOuhyKrCBtGT4H4j4Q4vwLBN4CVckCU8WrGKrtMd6oCzpMfC4SsynYuqwyXqzGD4m03HdFml4WDRrehSINgZlUTrRf3mK42MaBaIhyK4asnH43wTVQIJ)K4viefj(ceNz)xCBtGT4H4j4Q4vwLBhUoCcco5HdMJPqkjq0sJ5BdqC1f)2QvCfxCyoMcPKarlnMVzWHzmlqC7I3xlMTWVdi(MHqM(eIRolX78fRunLNNaMtCUxH7oxE4iqYOjZbDhUoCcco5HtzcNKrtThyk9fyMywG42fVVwmBHFhq8ndHm9jexDwIFN42fVoXzWrqA)vlMv)LfPyOmWA48IxTQ4m7)IBxCKbfwuGKvoGx8Byj(DQv8QvfhTIZGJG0ES0S2km60qFdNxC7I)uuywa(3IHG3HMk3X3fV(dx2JzbhUhlnRTcJon0FIZ9kC7ZLhocKmAYCq3HRdNGGtE4qR4FqPoWitl1AXTlUYeojJMApWu6lWmXSaXTlEFTy2c)oG4Bgcz6tiU6Se)oXTlEDIRmHtYOPg(tfE4SWjUwGBKXSaXRwv8NN06sKquu8Thdho1iq5JfAj(nSeNTIxTQ4qCaHSquuds)IdmdavPRt4exBeiz0Kr86pCzpMfC4Oo2oaufiXdhReyoX5Efy75YdhbsgnzoO7WL9ywWH7XWHtncuIfcsZE4m03HdFml4WH(NatCUBrvXheXbBiEQHuAUkUzbKQIJ)K4xUqqAwXTnbM4CRIehNVD46Wji4KhU6epsnbI2JLM1wbz74FJajJMmIxTQ4ppP1LiHOO4BpgoCQrGYhl0sC1zj(DIxV42fxzcNKrtThyk9fyMywG42fNbhbP9xTyw9xwKIHYaRHZlUDX7RfZw43beV43Ws87e3U41joAfNbhbPXdjlYmrgZcA48IxTQ4ppP1LiHOO4BpgoCQrGYhl0sC1fNTIx)jo3RGkoxE4iqYOjZbDhUoCcco5HdTIZGJG0ES0S2kMe0PgoV42fhzqHffizLd4f)gwIJMe)cXJutGO94mbbrWrrncKmAYC4YEml4W9yPzTvmjOtN4CVcvW5YdhbsgnzoO7W1HtqWjpC1j(V4AMbyA84FGRPcbX5JzbncKmAYiE1QI)lUMzaMMYvNXOPYVALeiAeiz0Kr86f3U4eGGOU2meY0NqC1zj(TvR42fhTI)bL6aJmTuRf3U4m4iiT)QfZQ)YIumugynZAdC4gqqqioFugKd3V4AMbyAkxDgJMk)QvsG4WnGGGqC(OmwwKzYGoCkC4YEml4WHOPhRdtK4WnGGGqC(OGsVmP(WPWjo3RGI5C5HJajJMmh0D46Wji4KhogCeKgJExJg)JgKYEiE1QIJmOWIcKSYb8IFJ43wTIxTQ4m4iiT)QfZQ)YIumugynCEXTlEDIZGJG0ES0S2km60qFdNx8QvfVVR2S2aThlnRTcJon03GKvoGx8ByjUcQv86pCzpMfC443ywWjo3RaA6C5HJajJMmh0D46Wji4KhogCeK2F1Iz1FzrkgkdSgo)Hl7XSGdhJExtbbhE9eN7v4w9C5HJajJMmh0D46Wji4KhogCeK2F1Iz1FzrkgkdSgo)Hl7XSGdhdbFcwBaOoX5(7u75YdhbsgnzoO7W1HtqWjpCm4iiT)QfZQ)YIumugynC(dx2JzbhoKbsm6DnN4C)DkCU8WrGKrtMd6oCD4eeCYdhdocs7VAXS6VSifdLbwdN)WL9ywWHlbD6dyQl9uRpX5(7U7C5HJajJMmh0D4YEml4W1ZogvwKs2rZXhizkbKYhhs)HRdNGGtE4yWrqAzhnhFGKPKQHA48IBx86e)5jTUejeffF7XWHtncu(yHwIZsCfe3U4WCmfsjbIwAmFBaIRU4vGAfVAvXFEsRlrcrrX3EmC4uJaLpwOL4QlUcIxV4vRkoZ(V42fhzqHffizLd4f)gXVtfhoqArhUE2XOYIuYoAo(ajtjGu(4q6pX5(7U95YdhbsgnzoO7WL9ywWHd)PYeK1F4m03HdFml4WPicjX1H4iPwZK9AIJSqXX)KrtIpbz9OpXvjpjUTjWeN7QfZQFXxeXveLbw7W1HtqWjpCm4iiT)QfZQ)YIumugynCEXRwvCKbfwuGKvoGx8Be)o1EItC4(GsDGv6M)C55EfoxE4iqYOjZbDhUL)W9uC4YEml4WPmHtYOPdNYuJthU(UAZAd0ES0S2kMe0PwhlHOOVGaZEmli1IRolXRtCfAkgviUIlUABkgviUIv86eVVkjqcIwTRWjbIBx8NIcZcW)wme8o0u5o(U42fVVR2S2aT)QfZQ)YIumugynizLd4fxDwIJMeVEXR)WzOVdh(ywWHRchP5jO4QujCsgnD4uMWciTOd3JzkbgKESvBoX5(7oxE4iqYOjZbDhUL)W9uC4YEml4WPmHtYOPdNYuJthU(UAZAd0ES0S2kMe0PwhlHOOVGaZEmli1IRolXvOPyuH4vRkEFxTzTbA)vlMv)LfPyOmWAqYkhWlU6SexHk4W1HtqWjpCqCaHSquulWOcCJGancKmAYC4uMWciTOd3JzkbgKESvBoX5(BFU8WrGKrtMd6oCzpMfC4uMG5XoCg67WHpMfC4uPsW8yIpiIBJepHK49KNFaOeFbIROe0jX7yjef9nXrZMq9vXziKfsIJmWpe3KGoj(GiUnsCSujjoyf)(bfw8rQRrqXzWdXvucRjohwAwBIpaXxOHGIhR4OOqC0ioFGdjXX5fVoWkEfk)GGIJE)p)Fa13oCD4eeCYdxDIJwXvMWjz0u7XmLadsp2QnIxTQ4Ov8i1eiAGbfw8rQRrWgbsgnze3U4rQjq0mjSw5XsZARrGKrtgXRxC7I3xlMTWVdi(MHqM(eIRU4kiUDXrR4qCaHSquuZkH1klsjWOIv(bbl5)5)dOrGKrtMtCUNTNlpCeiz0K5GUdNH(oC4JzbhovExT4iluCoS0S2SiTr8leNdlnRTpGtnsCCGM(xCBK4jKepzw8q8yfVN8IVaXvuc6K4DSeII(M43ka9vXTHraXVLbyeh9tzna9V4ZlEYS4H4Xkoehi(IhTdhYclasnX5EfoCD4eeCYdhm7udmOWIcProCKAcywsRfheho2Q2dx2Jzbho(D1fi9loStN4CVkoxE4iqYOjZbDhUoCcco5HJaee1vXvNL4SvTIBxCcqquxBgcz6tiU6Sexb1kUDXrR4kt4KmAQ9yMsGbPhB1gXTlEFTy2c)oG4Bgcz6tiU6IRWHl7XSGd3JLM1MfPnN4CFfCU8WrGKrtMd6oCl)H7P4WL9ywWHtzcNKrthoLPgNoC91Izl87aIVziKPpH4QZs87e)cXzWrqApwAwBfgDAOVHZF4m03HdFml4Wvzvw8adsp2QnV4iluCceeCaOeNdlnRnXvuc60HtzclG0IoCpMP0xlMTWVdi(tCUxXCU8WrGKrtMd6oCl)H7P4WL9ywWHtzcNKrthoLPgNoC91Izl87aIVziKPpH4QZs8BF46Wji4KhU(QKajiA1UcNeC4uMWciTOd3Jzk91Izl87aI)eN7rtNlpCeiz0K5GUd3YF4EkoCzpMfC4uMWjz00HtzQXPdxFTy2c)oG4Bgcz6ti(nSexHdxhobbN8WPmHtYOPg(tfE4SWjUwGBKXSaXTl(ZtADjsikk(2JHdNAeO8XcTexDwIZ2dNYewaPfD4EmtPVwmBHFhq8N4C)T65YdhbsgnzoO7WT8hUNIdx2JzbhoLjCsgnD4uMAC6W1xlMTWVdi(MHqM(eIFdlXv4W1HtqWjpCppP1LiHOO4BpgoCQrGYhl0sCwIZ2dNYewaPfD4EmtPVwmBHFhq8N4CVcQ9C5HJajJMmh0D4YEml4W9yPzTvmjOthod9D4WhZcoCkkbDsCdoCaOeN7QfZQFXxO4jZQKepWG0JTAt7W1HtqWjpC1joehqilef1cmQa3iiqJajJMmIBx8(UAZAd0(RwmR(llsXqzG1GKvoGx8ByjoAs8QvfxzcNKrtThZu6RfZw43beV42fVoXzWrqA)vlMv)LfPyOmWAqYkhWlU6SexH2DIxTQ4kt4KmAQ9yMsGbPhB1gXRx8QvfNbhbP1XY9lmjGA48IxTQ4ppP1LiHOO4BpgoCQrGYhl0sC1zjoBf3U49D1M1gO9xTyw9xwKIHYaRbjRCaV4QlUcQv86f3U41jodocsJNGilmdYuusd4BFK9AIFJ4Sv8Qvf)5jTUejeffF7XWHtncu(yHwIRU43w86pX5Efu4C5HJajJMmh0D4YEml4W9yPzTvmjOthod9D4WhZcoCOdhcexrjOtV4DSeIIEXheXVU4IZRZRIROewtCoS0S2E2GE1zhoXvXxO4meYcjXdmsCKbfwiobmV4dI4CRIe32cQyiodjoKsZvXhG4XyrTdxhobbN8WPmHtYOP2Jzk91Izl87aIxC7IJmOWIcKSYb8IFJ49D1M1gO9xTyw9xwKIHYaRbjRCaV4vRkoAfpsnbIgbus6LFaOkpwAwBFJajJMmN4ehoKbmp25YZ9kCU8WrGKrtMd6oCl)H7P4WL9ywWHtzcNKrthoLPgNoCrQjq04HKfzMiJzbncKmAYiUDXFEsRlrcrrX3EmC4uJaLpwOL43iEDIRcXvCX7RscKGObOoC1l0iE9IBxC0kEFvsGeeTAxHtcoCg67WHpMfC4q)yJMeh)hakXvzizrMjYywGQINk3XiEp)yaOeNtpDs8eyexrtNe3ggbeNdlnRnXvuc6K4Zl(Vlq8yfNHeh)jJQItQPt8H4iluCv6xHtcoCktybKw0HJhswKP8atPVaZeZcoX5(7oxE4iqYOjZbDhUoCcco5HdTIRmHtYOPgpKSit5bMsFbMjMfiUDXFEsRlrcrrX3EmC4uJaLpwOL43iEfiUDXrR4m4iiThlnRTIjbDQHZlUDXzWrqAVE6ujbMIz6udsw5aEXVrCKbfwuGKvoGxC7Idjei9yjJMoCzpMfC4E90PscmfZ0PtCU)2NlpCeiz0K5GUdxhobbN8WPmHtYOPgpKSit5bMsFbMjMfiUDX77QnRnq7XsZARysqNADSeII(ccm7XSGul(nIRqtXOcXTlodocs71tNkjWumtNAqYkhWl(nI33vBwBG2F1Iz1FzrkgkdSgKSYb8IBx86eVVR2S2aThlnRTIjbDQbP0CvC7IZGJG0(RwmR(llsXqzG1GKvoGxCfxCgCeK2JLM1wXKGo1GKvoGx8BexH2DIx)Hl7XSGd3RNovsGPyMoDIZ9S9C5HJajJMmh0D4w(d3tXHl7XSGdNYeojJMoCktnoD4SYpiyj)p)FafizLd4fxDXvR4vRkoAfpsnbIgyqHfFK6AeSrGKrtgXTlEKAcentcRvES0S2Aeiz0KrC7IZGJG0ES0S2kMe0PgoV4vRk(ZtADjsikk(2JHdNAeO8XcTexDwIxN4SvCfx8pOuhyKPLAT4kwXJutGO9yPzTvq2o(3iqYOjJ41F4m03HdFml4WvHJ08euCvQeojJMehzHIJgX5dCi1eNR2WlUbhoauIxHYpiO4O3)Z)hG4luCdoCaOexrjOtIBBcmXvucRjEcmIdwXVFqHfFK6AeSD4uMWciTOd3xB4lqC(ahsN4CVkoxE4iqYOjZbDhUShZcoCqC(ahshod9D4WhZcoCQ0jIxCCEXrJ48boKeFqeFcXNx8KzXdXJvCioq8fpAhUoCcco5HdTI)bL6aJmTuRf3U41joAfxzcNKrtTV2WxG48boKeVAvXvMWjz0ud)PcpCw4exlWnYywG41lUDXJeIIIwmwuj2IziXvCXHKvoGxC1fVce3U4qcbspwYOPtCUVcoxE4YEml4W9uhsrjOogyqZXPdhbsgnzoO7eN7vmNlpCeiz0K5GUdx2JzbhoioFGdPdx)AxtLiHOO4p3RWHRdNGGtE4qR4kt4KmAQ91g(ceNpWHK42fhTIRmHtYOPg(tfE4SWjUwGBKXSaXTl(ZtADjsikk(2JHdNAeO8XcTexDwIFN42fpsikkAXyrLylMHexDwIxN4Qq8leVoXVtCfR491Izl87aIx86fVEXTloKqG0JLmA6WzOVdh(ywWHRcHRJXSrmauIhjeffV4bwgIBB0AX1JssCKfkEGrIBWHzmlq8frC0ioFGdjvfhsiq6Xe3GdhakX5tGHSME7eN7rtNlpCeiz0K5GUdx2JzbhoioFGdPdNH(oC4Jzbho0iHaPhtC0ioFGdjXPeQVk(Gi(eIBB0AXj1WpqsCdoCaOeN7QfZQ)M4kAfpWYqCiHaPht8brCUvrIJIIxCiLMRIpaXdmsCaPMqCv8TdxhobbN8WHwXvMWjz0u7Rn8fioFGdjXTloKSYb8IFJ49D1M1gO9xTyw9xwKIHYaRbjRCaV4xiUcQvC7I33vBwBG2F1Iz1FzrkgkdSgKSYb8IFdlXvH42fpsikkAXyrLylMHexXfhsw5aEXvx8(UAZAd0(RwmR(llsXqzG1GKvoGx8lexfN4C)T65YdhbsgnzoO7W1HtqWjpCOvCLjCsgn1WFQWdNfoX1cCJmMfiUDXFEsRlrcrrXlU6Se)2hUShZcoCm6SxRWV2me8eN7vqTNlpCzpMfC4iLZ3jyg0HJajJMmh0DItCIdNsc(Zco3FNAV7o1EBfuXHZwcbda1F4q)Ox049367RWqFIl(LyK4Jf)cdXrwO4v8dk1bgzQO4qcnhFGKr8FTiXt8yTYGmI3Xsak6Bc7ONbqIRc0N4vEbkjyqgXRiehqilef1qdvu8yfVIqCaHSquudn0iqYOjtffVofut9nHD0ZaiXrtOpXR8cusWGmIxrioGqwikQHgQO4XkEfH4aczHOOgAOrGKrtMkkEDkOM6Bc7c7OF0lA8(B99vyOpXf)sms8XIFHH4ilu8kYdP(AXKrffhsO54dKmI)RfjEIhRvgKr8owcqrFtyh9mas8BJ(eVYlqjbdYiEf)fxZmatdnurXJv8k(lUMzaMgAOrGKrtMkkEDkOM6Bc7ONbqIFB0N4vEbkjyqgXR4V4AMbyAOHkkESIxXFX1mdW0qdncKmAYurXZqC0S3kOhXRtb1uFtyh9masCfd6t8kVaLemiJ4veIdiKfIIAOHkkESIxrioGqwikQHgAeiz0KPIINH4OzVvqpIxNcQP(MWUWo6h9IgV)wFFfg6tCXVeJeFS4xyioYcfVIDZxrXHeAo(ajJ4)ArIN4XALbzeVJLau03e2rpdGeNTOpXR8cusWGmIxrioGqwikQHgQO4XkEfH4aczHOOgAOrGKrtMkkED3PM6Bc7ONbqIxbOpXR8cusWGmIxrioGqwikQHgQO4XkEfH4aczHOOgAOrGKrtMkkEDkOM6Bc7ONbqIRWTrFIx5fOKGbzeVIqCaHSquudnurXJv8kcXbeYcrrn0qJajJMmvu86uqn13e2rpdGexHka9jELxGscgKr8k(lUMzaMgAOIIhR4v8xCnZamn0qJajJMmvu86Utn13e2f2r)Ox049367RWqFIl(LyK4Jf)cdXrwO4v8dk1bwPB(kkoKqZXhize)xls8epwRmiJ4DSeGI(MWo6zaK43H(eVYlqjbdYiEfH4aczHOOgAOIIhR4veIdiKfIIAOHgbsgnzQO4zioA2Bf0J41PGAQVjSJEgaj(TrFIx5fOKGbzeVIqCaHSquudnurXJv8kcXbeYcrrn0qJajJMmvu8mehn7Tc6r86uqn13e2rpdGexb1I(eVYlqjbdYiEfH4aczHOOgAOIIhR4veIdiKfIIAOHgbsgnzQO41PGAQVjSlSJ(rVOX7V13xHH(ex8lXiXhl(fgIJSqXRid(OnvuCiHMJpqYi(VwK4jESwzqgX7yjaf9nHD0ZaiXva9jELxGscgKr8kcXbeYcrrn0qffpwXRiehqilef1qdncKmAYurXRtb1uFtyh9masCvG(eVYlqjbdYiEfJXIkXwESOHgA8A8VIIhR4vmglQeB5XIcVg)BOHkkED3PM6Bc7c73Al(fgKrCfJ4zpMfiUE(4Bc7hUNN6N7VRcu4WXdxKrthUkvjX5WzcnfxfhnUOWjH9kvjXRqjSJjUckgvf)o1E3Dc7c7vQsIxzSeGIE0NWELQK4kU4vOvjjUYeojJMA4pv4HZcN4AbUrgZcehNx8FfFcXNx8NcXziKfsIBJeh)jXNOjSxPkjUIlELxlMbqIBHRJHxtI3tTUK9ywqrpFiobc4qV4XkoKm4DsC(niqmPwCizBH1Ac7vQsIR4IxHYAK43IMESomrcXhqqqioFi(aeVVwmzi(GiUnsC0m4FiUzmIpH4iluCLRoJrtLF1kjq0e2f2RuLexLHKIx51IjdH9ShZc(gpK6RftgxWInjpV(AHFNFbc7zpMf8nEi1xlMmUGfBy2i0KPGOZRKX2aqvIvndqyp7XSGVXdP(AXKXfSydIMESomrcvhew)IRzgGPXJ)bUMkeeNpMfuT6V4AMbyAkxDgJMk)QvsGqyp7XSGVXdP(AXKXfSyZhuQdmH9ShZc(gpK6RftgxWInwjSgzkilSyOmWuLhs91IjJYt9fyEwkOcH9ShZc(gpK6RftgxWInVE6ujbMIz6KQ8qQVwmzuEQVaZZsbvhewqcbspwYOjH9ShZc(gpK6RftgxWInpwAwBfgDAOx1bHfehqilef1SsyTYIucmQyLFqWs(F()ae2f2RuLeVcLdqC04gzmlqyp7XSGNvTPxtyVsIRsEYiESIBOGGwdGe3ggfyeu8(UAZAd8IBlNqCKfkohqrIZKpzeFbIhjeffFtyp7XSG)cwSrzcNKrtQcslI1dmL(cmtmlqvLPgNyXGJG0E90PscmfZ0PgoF1QppP1LiHOO4BpgoCQrGYhl0sDwvGWE2Jzb)fSyJYeojJMufKweRhyk9fyMywGQktnoXIbhbP96PtLeykMPtnC(QvFEsRlrcrrX3EmC4uJaLpwOL6SQaH9kjELXOEnXJv8NiXheXdmsCaPMq8kRYIx3aepWiXjLeieFrepfNd7sX5HBVEXNxC0lySYowcrrgH9ShZc(lyXgLjCsgnPkiTiwZxaKAIsNVKGXk7yjefzuDqy1xLeibrR2v4KavvMACIvFTy2c)oG4zPGDgCeKg1X2bGQajE4yLat5UgoF1Q91Izl87aIN1D2zWrqAuhBhaQcK4HJvcmLB3W5RwTVwmBHFhq8SUTDgCeKg1X2bGQajE4yLatHTnC(Qv7RfZw43bepl2ANbhbPrDSDaOkqIhowjWuurdNxyVsIJE79fheIJSqX5WUuCiL9ywG4XyrIZCv8bfyHdaL461MIxzvw8emwzhlHOiJ4wz0XOx8biEGrIR2MkEX5HuNiZaqjEko)geiMuloh2LIZd3UWE2Jzb)fSyJYeojJMufKwelcbH6XOKk91Izl87aIxvLPgNyriiupgLuPVwmBHFhq8c7zpMf8xWInkt4KmAsvqArSieeQhJsQ0xlMTWVdiEvhew9vjbsq0QDfojWoHGq9yusL(AXSf(DaXREFTy2c)oG4T3xlMTWVdi(MHqM(eQFN9ySOsSLhlk8A8VX2BuBtf2rRYeojJMAZxaKAIsNVKGXk7yjefzuvzQXjw91Izl87aIxyVsIFRa0xfVJLauK4WnYywG4dI42iXXsLK48WzHtCTa3iJzbI)uiEcmIBHRJHxtIhjeffV448nH9ShZc(lyXgLjCsgnPkiTiw4pv4HZcN4AbUrgZcuvzQXjw8WzHtCTa3iJzb2FEsRlrcrrX3EmC4uJaLpwOL6SUtyVsIxzmQxt8kROx8mehzGFiSN9ywWFbl20tTUK9ywqrpFOkiTiwDZlSxjXrV886RIZPNojEcmIROPtINH43DH4vwLf3GdhakXdmsCKb(H4kOwXFQVaZRQ4jsqqXdSmeNTxiELvzXheXNqCsn8dKEXTnb2aepWiXbKAcXRWQSIeFHIpV4GnehNxyp7XSG)cwS51tNkjWumtNuDqy98KwxIeIIIV9y4WPgbkFSqRBQa7idkSOajRCaV6vGDgCeK2RNovsGPyMo1GKvoG)guDtZkvJ9(AXSf(DaXRol2Q41fJfDJcQTEf7Dc7vsC0ioqCeCT(Q4VTj6y0lESIhyK4CbL6aJmIJg3iJzbIxhZvXn7aqj(VQk(eIJSWo9IZVREaOeFqehSb2aqj(8INkZrNmAQ(MWE2Jzb)fSydehuYEmlOONpufKweRpOuhyKr1bH1huQdmY0sTwyVsIRYWzHtCvC04gzmlOcV4OhkQ4loQrjjEkEhM8INmlEiobiiQRIJSqXdms8pOuhyIxzf9Ixhd(Oneu8pgTwCi98upeFI6BIRsloVQIpH49eiodjEGLH4)yXRPMWE2Jzb)fSytp16s2Jzbf98HQG0Iy9bL6aR0nVQdclLjCsgn1WFQWdNfoX1cCJmMfiSxjXvjpzepwXneYaiXTHraXJvC8Ne)dk1bM4vwrV4luCg8rBi4lSN9ywWFbl2OmHtYOjvbPfX6dk1bwjWG0JTAJQktnoX6ovCrKAcenLdQf2iqYOjJI9o1ErKAcenR8dcwwKYJLM123iqYOjJI9o1ErKAceThlnRTcY2X)gbsgnzuS3PIlIutGOL6SdN4AJajJMmk27u7f3PcfBDppP1LiHOO4BpgoCQrGYhl0sDwSTEH9kjELxWpgcko(pauINIZfuQdmXRSIe3ggbehszhBaOepWiXjabrDv8adsp2Qnc7zpMf8xWIn9uRlzpMfu0ZhQcslI1huQdSs38QoiSiabrDTziKPpXnSuMWjz0u7dk1bwjWG0JTAJWELe)wgW8yINH4wPAuvC2EH42MaBXdXveN4luCBtGjo3QiX7WjeNbhbrvXvXfIBBcmXveN41T4Xpgs8pOuhy1RstXTnbM4kIt8u)R4idyEmXZqC2EH4jQCaFioBfpsikkEXRBXJFmK4FqPoWQxyp7XSG)cwSPNADj7XSGIE(qvqArSqgW8yQoiSuMWjz0uJqqOEmkPsFTy2c)oG4vNvNVyLQP88eWuTAFTy2c)oG4Bgcz6tCdlfQwfzqHffizLd4VHLc2vMWjz0uJqqOEmkPsFTy2c)oG4vN1TRwLbhbP9xTyw9xwKIHYaRK4X2Ht0W5TRmHtYOPgHGq9yusL(AXSf(DaXRol2wT6ZtADjsikk(2JHdNAeO8XcTuNfBTRmHtYOPgHGq9yusL(AXSf(DaXRol2kSxjXvjpjEkod(OneuCByeqCiLDSbGs8aJeNaee1vXdmi9yR2iSN9ywWFbl20tTUK9ywqrpFOkiTiwm4J2O6GWIaee11MHqM(e3WszcNKrtTpOuhyLadsp2Qnc7vsC0ZAJ(qCE4SWjUk(aep1AXxeXdmsC0RkJEeNH6j(tIpH49e)Px8u8kSkRiH9ShZc(lyXMe2tavIfcjqO6GWIaee11MHqM(eQZsbvCbbiiQRniHIac7zpMf8xWInjSNaQWJRFsyp7XSG)cwSrpOWIVGMb3GYIaHWE2Jzb)fSydtIQSiLao9AVWUWELQK4OdF0gc(c7zpMf8ng8rBy9yJsvhewOnsnbIgyqHfFK6AeSrGKrtg7qCaHSquulgW1sSQz6fgDAi7ppP1LiHOO4BpgoCQrGYhl06gviSN9ywW3yWhT5cwS5XWHtncu(yHwQoiSEEsRlrcrrXRoR7SxhA7RscKGObOoC1l0uTAFxTzTbApbHzqMcZcOYZp1OMvQMshlHOOxX7yjef9fey2JzbPwDwQTDNkQw95jTUejeffF7XWHtncu(yHwQZ26TxhdocsJNGilmdYuusd4BFK9A3WITvR(8KwxIeIIIV9y4WPgbkFSql1zRD0QmHtYOPg(tfE4SWjUwGBKXSG6f2ZEml4Bm4J2Cbl28eeMbzkmlGkp)uJuDqyXGJG04jiYcZGmfL0a(2hzV2nSUZED9D1M1gO9eeMbzkmlGkp)uJAwPAkDSeIIEfVJLqu0xqGzpMfK6ByP22DQOA1FX1mdW00uAkmxlKAslEn1iqYOjJD0YGJG00uAkmxlKAslEn1W5Rw9xCnZamTAKYb8LDvPbPhaQgbsgnzSJwdXGJG0QrkhWxSbZaRHZxVWE2JzbFJbF0MlyXgu6DTy0PHe2RK4Ol71(izeFSSiZKbPVkooqt)lEGrIdi1eIxzvw85fh9cgRSJLquKr8eye3gjUTfuXq8EYlobiiQRIBlNyaOehzHIprtyp7XSGVXGpAZfSydt2R9rYO6GWcT9vjbsq0QDfojOAv0wNYeojJMAZxaKAIsNVKGXk7yjefzSxxmwuj2YJfTB3414)nQTPIQvJXIkXwESOX2gVg)VrH6TtacI66nvGARxyxyVsIx5D1M1g4f2RK4QKNexrjOtIViikoQUrCgczHK4bgjoYa)qComC4uJaIZfl0sCe4Aj(LleKMv8(ArV4dOjSN9ywW36MN1JLM1wXKGoPk(tLfbPGQByPGQdcl0YGJG0ES0S2kMe0PgoVDgCeK2JHdNAeOeleKMTHZBNbhbP9y4WPgbkXcbPzBqYkhWFdRB3uHWELeVovcqt)lEQHuAUkooV4mupXFsCBK4XU1eNdlnRnXVLTJ)1lo(tIZD1Iz1V4lcIIJQBeNHqwijEGrIJmWpeNddho1iG4CXcTehbUwIF5cbPzfVVw0l(aAc7zpMf8TU5VGfB(RwmR(llsXqzGPk(tLfbPGQByPGQdclgCeK2JHdNAeOeleKMTHZBNbhbP9y4WPgbkXcbPzBqYkhWFdRB3uHWE2JzbFRB(lyXgeDII06mMfO6GWszcNKrtThyk9fyMywGD0(bL6aJmnReeAYEDppP1LiHOO4BpgoCQrGYhl06gwkyVVR2S2aT)QfZQ)YIumugynCE7OnsnbI2JLM1wbz74FJajJMmvRYGJG0(RwmR(llsXqzG1W5R3EFTy2c)oG4vNLke2ZEml4BDZFbl2OmbZJP6GWQoioGqwikQzLWALfPeyuXk)GGL8)8)byVVwmBHFhq8ndHm9jUHLckEKAcendr8eS8bmdcfz1iqYOjt1QqCaHSquuZqzGPVwES0S2E791Izl87aI)gfQ3odocs7VAXS6VSifdLbwdN3odocs7XsZARysqNA482TYpiyj)p)FafizLd4zPw7m4iindLbM(A5XsZA7BM1gqyVsIRY7QfhzHIF5cbPzfNhsko3QiXTnbM4CyksCiLMRIBdJaId2qCioamauIZDlnH9ShZc(w38xWIn87Qlq6xCyNufzHfaPMGLcQoiSIutGO9y4WPgbkXcbPzBeiz0KXoAJutGO9yPzTvq2o(3iqYOjJWELexL8K4xUqqAwX5HK4CRIe3ggbe3gjowQKepWiXjabrDvCByuGrqXrGRL487QhakXTnb2IhIZDlIVqXrZG)H4OiabtT(Atyp7XSGV1n)fSyZJHdNAeOeleKMv1bH1ZtADjsikk(2JHdNAeO8XcTUHLc2jabrDvDwvGATRmHtYOP2dmL(cmtmlWEFxTzTbA)vlMv)LfPyOmWA48277QnRnq7XsZARysqNADSeIIE1zPG96qlehqilef1wgYmeOtvRAigCeKgIorrADgZcA48vR(8KwxIeIIIV9y4WPgbkFSql1zvNcxWwfBDOnsnbIgyqHfFK6AeSrGKrtg7OnsnbIMjH1kpwAwBncKmAYuF91BVVwmBHFhq83W6o7OLbhbPXdjlYmrgZcA482RdT9vjbsq0usGa7kSAv023vBwBGgIorrADgZcA481lSN9ywW36M)cwS5jimdYuywavE(PgPA)AxtLiHOO4zPGQdclLjCsgn1EGP0xGzIzb2rRzJ2tqygKPWSaQ88tnQy2OftV2aqzpsikkAXyrLylMHuN1DkyVU(AXSf(DaX3meY0NqDw115lOYbOEfE2wF92rldocs7XWHtncuIfcsZ2W5TxhAzWrqA8qYImtKXSGgoF1QppP1LiHOO4BpgoCQrGYhl0sD2wF1QidkSOajRCa)nSuH9NN06sKquu8Thdho1iq5JfADZTf2ZEml4BDZFbl28e)pVQdclLjCsgn1EGP0xGzIzb27RfZw43beFZqitFc1zPG9iHOOOfJfvITygsDwkubc7vsCvYtIZD1Iz1V4lq8(UAZAdiEDjsqqXrg4hIZbuu9IJd00)IBJepHK4O2bGs8yfNF5f)YfcsZkEcmIBwXbBiowQKeNdlnRnXVLTJ)nH9ShZc(w38xWIn)vlMv)LfPyOmWuDqyvhA)GsDGrMwQ1vRYGJG04jiYcZGmfL0a(2hzV2nSTE7kt4KmAQ9atPVaZeZcSxhAJutGO9y4WPgbkXcbPzBeiz0KPA1i1eiApwAwBfKTJ)ncKmAYuT6ZtADjsikk(2JHdNAeO8XcTuN1DvR23vBwBG2JHdNAeOeleKMTbjRCaV63vV96qBFvsGeenLeiWUcRwTVR2S2aneDII06mMf0GKvoGxDfuB1Q9D1M1gOHOtuKwNXSGgoV9(AXSf(DaXRolvuVWELe)wJiEAmV4jKehNxvXFWWtIhyK4lGe32eyIRxB0hIF5LkQjUk5jXTHraXnxhakXrYpiO4bwceVYQS4gcz6ti(cfhSH4FqPoWiJ42MaBXdXtWvXRSk3e2ZEml4BDZFbl2yLWAKPGSWIHYatv9aOs3WsHMkuTFTRPsKquu8Suq1bHfmhtHusGOLgZ3W5TxxKquu0IXIkXwmdDtFTy2c)oG4Bgcz6tuTkA)GsDGrMwQ127RfZw43beFZqitFc1z15lwPAkppbm1lSxjXV1iIdwXtJ5f32O1IBgsCBtGnaXdmsCaPMq8BR2xvXXFs8keIIeFbIZS)lUTjWw8q8eCv8kRYnH9ShZc(w38xWInwjSgzkilSyOmWuDqybZXuiLeiAPX8TbO(TvRIdZXuiLeiAPX8ndomJzb27RfZw43beFZqitFc1z15lwPAkppbmc7zpMf8TU5VGfBES0S2km60qVQdclLjCsgn1EGP0xGzIzb27RfZw43beFZqitFc1zDN96yWrqA)vlMv)LfPyOmWA48vRYS)BhzqHffizLd4VH1DQTAv0YGJG0ES0S2km60qFdN3(trHzb4FlgcEhAQChFVEH9ShZc(w38xWInuhBhaQcK4HJvcmQoiSq7huQdmY0sT2UYeojJMApWu6lWmXSa791Izl87aIVziKPpH6SUZEDkt4KmAQH)uHholCIRf4gzmlOA1NN06sKquu8Thdho1iq5JfADdl2wTkehqilef1G0V4aZaqv66eoX16f2RK4O)jWeN7wuv8brCWgINAiLMRIBwaPQ44pj(LleKMvCBtGjo3QiXX5Bc7zpMf8TU5VGfBEmC4uJaLyHG0SQoiSQlsnbI2JLM1wbz74FJajJMmvR(8KwxIeIIIV9y4WPgbkFSql1zDx92vMWjz0u7bMsFbMjMfyNbhbP9xTyw9xwKIHYaRHZBVVwmBHFhq83W6o71HwgCeKgpKSiZezmlOHZxT6ZtADjsikk(2JHdNAeO8XcTuNT1lSN9ywW36M)cwS5XsZARysqNuDqyHwgCeK2JLM1wXKGo1W5TJmOWIcKSYb83WcnDrKAceThNjiicokQrGKrtgH9ShZc(w38xWIniA6X6WejuDqyv3V4AMbyA84FGRPcbX5JzbvR(lUMzaMMYvNXOPYVALeiQ3obiiQRndHm9juN1TvRD0(bL6aJmTuRTZGJG0(RwmR(llsXqzG1mRnGQdiiieNpkJLfzMmiwkO6acccX5Jck9YKAwkO6acccX5JYGW6xCnZamnLRoJrtLF1kjqiSN9ywW36M)cwSHFJzbQoiSyWrqAm6DnA8pAqk7r1QidkSOajRCa)n3wTvRYGJG0(RwmR(llsXqzG1W5Txhdocs7XsZARWOtd9nC(Qv77QnRnq7XsZARWOtd9nizLd4VHLcQTEH9ShZc(w38xWInm6DnfeC4vvhewm4iiT)QfZQ)YIumugynCEH9ShZc(w38xWInme8jyTbGs1bHfdocs7VAXS6VSifdLbwdNxyp7XSGV1n)fSydYajg9Ugvhewm4iiT)QfZQ)YIumugynCEH9ShZc(w38xWInjOtFatDPNATQdclgCeK2F1Iz1FzrkgkdSgoVWE2JzbFRB(lyXg8NktqwQcslIvp7yuzrkzhnhFGKPeqkFCi9QoiSyWrqAzhnhFGKPKQHA482R75jTUejeffF7XWHtncu(yHwSuWomhtHusGOLgZ3gG6vGARw95jTUejeffF7XWHtncu(yHwQRq9vRYS)BhzqHffizLd4V5oviSxjXveHK46qCKuRzYEnXrwO44FYOjXNGSE0N4QKNe32eyIZD1Iz1V4lI4kIYaRjSN9ywW36M)cwSb)PYeK1R6GWIbhbP9xTyw9xwKIHYaRHZxTkYGclkqYkhWFZDQvyxyVsvs8BzaZJrWxyVsIJ(Xgnjo(pauIRYqYImtKXSavfpvUJr8E(XaqjoNE6K4jWiUIMojUnmciohwAwBIROe0jXNx8FxG4Xkodjo(tgvfNutN4dXrwO4Q0VcNeiSN9ywW3qgW8ySuMWjz0KQG0IyXdjlYuEGP0xGzIzbQQm14eRi1eiA8qYImtKXSGgbsgnzS)8KwxIeIIIV9y4WPgbkFSqRBQtfkEFvsGeena1HREHM6TJ2(QKajiA1UcNeiSN9ywW3qgW8yxWInVE6ujbMIz6KQdcl0QmHtYOPgpKSit5bMsFbMjMfy)5jTUejeffF7XWHtncu(yHw3ub2rldocs7XsZARysqNA482zWrqAVE6ujbMIz6udsw5a(Bqguyrbsw5aE7qcbspwYOjH9ShZc(gYaMh7cwS51tNkjWumtNuDqyPmHtYOPgpKSit5bMsFbMjMfyVVR2S2aThlnRTIjbDQ1Xsik6liWShZcs9nk0umQWodocs71tNkjWumtNAqYkhWFtFxTzTbA)vlMv)LfPyOmWAqYkhWBVU(UAZAd0ES0S2kMe0PgKsZv7m4iiT)QfZQ)YIumugynizLd4vCgCeK2JLM1wXKGo1GKvoG)gfA3vVWELeVchP5jO4QujCsgnjoYcfhnIZh4qQjoxTHxCdoCaOeVcLFqqXrV)N)paXxO4gC4aqjUIsqNe32eyIROewt8eyehSIF)Gcl(i11iytyp7XSGVHmG5XUGfBuMWjz0KQG0Iy91g(ceNpWHKQktnoXYk)GGL8)8)buGKvoGxD1wTkAJutGObguyXhPUgbBeiz0KXEKAcentcRvES0S2Aeiz0KXodocs7XsZARysqNA48vR(8KwxIeIIIV9y4WPgbkFSql1zvhBv8pOuhyKPLATInsnbI2JLM1wbz74FJajJMm1lSxjXvPteV448IJgX5dCij(Gi(eIpV4jZIhIhR4qCG4lE0e2ZEml4BidyESlyXgioFGdjvhewO9dk1bgzAPwBVo0QmHtYOP2xB4lqC(ahsvRQmHtYOPg(tfE4SWjUwGBKXSG6ThjeffTySOsSfZqkoKSYb8Qxb2HecKESKrtc7zpMf8nKbmp2fSyZtDifLG6yGbnhNe2RK4viCDmMnIbGs8iHOO4fpWYqCBJwlUEusIJSqXdmsCdomJzbIViIJgX5dCiPQ4qcbspM4gC4aqjoFcmK10Bc7zpMf8nKbmp2fSydeNpWHKQ9RDnvIeIIINLcQoiSqRYeojJMAFTHVaX5dCizhTkt4KmAQH)uHholCIRf4gzmlW(ZtADjsikk(2JHdNAeO8XcTuN1D2JeIIIwmwuj2Izi1zvNkUOU7uS91Izl87aIV(6Tdjei9yjJMe2RK4OrcbspM4OrC(ahsItjuFv8br8je32O1ItQHFGK4gC4aqjo3vlMv)nXv0kEGLH4qcbspM4dI4CRIehffV4qknxfFaIhyK4asnH4Q4Bc7zpMf8nKbmp2fSydeNpWHKQdcl0QmHtYOP2xB4lqC(ahs2HKvoG)M(UAZAd0(RwmR(llsXqzG1GKvoG)cfuR9(UAZAd0(RwmR(llsXqzG1GKvoG)gwQWEKquu0IXIkXwmdP4qYkhWREFxTzTbA)vlMv)LfPyOmWAqYkhWFHke2ZEml4BidyESlyXggD2Rv4xBgcQ6GWcTkt4KmAQH)uHholCIRf4gzmlW(ZtADjsikkE1zDBH9ShZc(gYaMh7cwSHuoFNGzqc7c7vQsIZfuQdmXR8UAZAd8c7vs8kCKMNGIRsLWjz0KWE2JzbF7dk1bwPBEwkt4KmAsvqArSEmtjWG0JTAJQktnoXQVR2S2aThlnRTIjbDQ1Xsik6liWShZcsT6SQtHMIrfkUABkgvOyRRVkjqcIwTRWjb2Fkkmla)BXqW7qtL747277QnRnq7VAXS6VSifdLbwdsw5aE1zHMQVEH9ShZc(2huQdSs38xWInkt4KmAsvqArSEmtjWG0JTAJQdclioGqwikQfyubUrqavvMACIvFxTzTbApwAwBftc6uRJLqu0xqGzpMfKA1zPqtXOIQv77QnRnq7VAXS6VSifdLbwdsw5aE1zPqfiSxjXvPsW8yIpiIBJepHK49KNFaOeFbIROe0jX7yjef9nXrZMq9vXziKfsIJmWpe3KGoj(GiUnsCSujjoyf)(bfw8rQRrqXzWdXvucRjohwAwBIpaXxOHGIhR4OOqC0ioFGdjXX5fVoWkEfk)GGIJE)p)Fa13e2ZEml4BFqPoWkDZFbl2OmbZJP6GWQo0QmHtYOP2JzkbgKESvBQwfTrQjq0adkS4JuxJGncKmAYypsnbIMjH1kpwAwBncKmAYuV9(AXSf(DaX3meY0NqDfSJwioGqwikQzLWALfPeyuXk)GGL8)8)biSxjXv5D1IJSqX5WsZAZI0gXVqCoS0S2(ao1iXXbA6FXTrINqs8KzXdXJv8EYl(cexrjOtI3Xsik6BIFRa0xf3ggbe)wgGrC0pL1a0)IpV4jZIhIhR4qCG4lE0e2ZEml4BFqPoWkDZFbl2WVRUaPFXHDsvKfwaKAcwkOkPMaML0AXbbl2QwvhewWStnWGclkKgryp7XSGV9bL6aR0n)fSyZJLM1MfPnQoiSiabrDvDwSvT2jabrDTziKPpH6SuqT2rRYeojJMApMPeyq6XwTXEFTy2c)oG4Bgcz6tOUcc7vs8kRYIhyq6XwT5fhzHItGGGdaL4CyPzTjUIsqNe2ZEml4BFqPoWkDZFbl2OmHtYOjvbPfX6XmL(AXSf(DaXRQYuJtS6RfZw43beFZqitFc1zD3fm4iiThlnRTcJon03W5f2ZEml4BFqPoWkDZFbl2OmHtYOjvbPfX6XmL(AXSf(DaXRQYuJtS6RfZw43beFZqitFc1zDBvhew9vjbsq0QDfojqyp7XSGV9bL6aR0n)fSyJYeojJMufKweRhZu6RfZw43beVQktnoXQVwmBHFhq8ndHm9jUHLcQoiSuMWjz0ud)PcpCw4exlWnYywG9NN06sKquu8Thdho1iq5JfAPol2kSN9ywW3(GsDGv6M)cwSrzcNKrtQcslI1Jzk91Izl87aIxvLPgNy1xlMTWVdi(MHqM(e3WsbvhewppP1LiHOO4BpgoCQrGYhl0IfBf2RK4kkbDsCdoCaOeN7QfZQFXxO4jZQKepWG0JTAttyp7XSGV9bL6aR0n)fSyZJLM1wXKGoP6GWQoioGqwikQfyubUrqa79D1M1gO9xTyw9xwKIHYaRbjRCa)nSqtvRQmHtYOP2Jzk91Izl87aI3EDm4iiT)QfZQ)YIumugynizLd4vNLcT7QwvzcNKrtThZucmi9yR2uF1Qm4iiTowUFHjbudNVA1NN06sKquu8Thdho1iq5JfAPol2AVVR2S2aT)QfZQ)YIumugynizLd4vxb1wV96yWrqA8eezHzqMIsAaF7JSx7g2wT6ZtADjsikk(2JHdNAeO8XcTu)21lSxjXrhoeiUIsqNEX7yjef9IpiIFDXfNxNxfxrjSM4CyPzT9Sb9QZoCIRIVqXziKfsIhyK4idkSqCcyEXheX5wfjUTfuXqCgsCiLMRIpaXJXIAc7zpMf8TpOuhyLU5VGfBES0S2kMe0jvhewkt4KmAQ9yMsFTy2c)oG4TJmOWIcKSYb8303vBwBG2F1Iz1FzrkgkdSgKSYb8vRI2i1eiAeqjPx(bGQ8yPzT9ncKmAYiSlSxPkjoxqPoWiJ4OXnYywGWELe)wJioxqPoWyJYempM4jKehNxvXXFsCoS0S2(ao1iXJvCgcqitiocCTepWiX5Z)hLK4mla)fpbgXVLbyeh9tzna9VQItkjG4dI42iXtijEgIBLQr8kRYIxhoqt)lo(pauIxHYpiO4O3)Z)hq9c7zpMf8TpOuhyKH1JLM12hWPgP6GWQogCeK2huQdSgoF1Qm4iinLjyESgoF92R75jTUejeffF7XWHtncu(yHw3W2QvvMWjz0ud)PcpCw4exlWnYywq92TYpiyj)p)FafizLd4zPwH9kj(TmG5XepdXV9fIxzvwCBtGT4H4kItC2ioBVqCBtGjUI4e32eyIZHHdNAeq8lxiinR4m4iiIJZlESINk3Xi(VwK4vwLf3w(bj(pbEgZc(MWELeh9Q)v8priXJvCKbmpM4zioBVq8kRYIBBcmXj1K9qFvC2kEKquu8nXRJlTiXZx8fp(XqI)bL6aRvVWELe)wgW8yINH4S9cXRSklUTjWw8qCfXPQ4Q4cXTnbM4kItvXtGr8kqCBtGjUI4eprcckUkvcMhtyp7XSGV9bL6aJmxWIn9uRlzpMfu0ZhQcslIfYaMht1bHLYeojJMAecc1Jrjv6RfZw43beV6S68fRunLNNaMQvzWrqApgoCQrGsSqqA2goV9(AXSf(DaX3meY0N4gw3vT6ZtADjsikk(2JHdNAeO8XcTuNfBTRmHtYOPgHGq9yusL(AXSf(DaXRol2wTAFTy2c)oG4Bgcz6tCdlfu86IutGOziINGLpGzKOiRgbsgnzSZGJG0uMG5XA481lSN9ywW3(GsDGrMlyXMhlnRTpGtns1bH1huQdmY0EI)N3(ZtADjsikk(2JHdNAeO8XcTUHTc7vsC0L9AFKmIBWHdaL4CyPzTjUIsqNe3ggbeFbIJnOWexLvPe)JSx7fpbgX5WsZAtC0Ptd9IpV448nH9ShZc(2huQdmYCbl2WK9AFKmQoiS6lWGprJNGilmdYuusd4BWeutDwOj7m4iinEcISWmitrjnGV9r2RPolvyNbhbP9yPzTvmjOtnizLd4vN1TTZGJG0ES0S2km60qFdN3EDppP1LiHOO4BpgoCQrGYhl06gw3UAvLjCsgn1WFQWdNfoX1cCJmMfuV96yWrqApwAwBfgDAOVbjRCa)nSyWrqApwAwBftc6udsw5a(lURAv02xLeibrtjbcSRW6f2ZEml4BFqPoWiZfSyZJnkvDqyfPMardmOWIpsDnc2iqYOjJDioGqwikQfd4Ajw1m9cJonK9NN06sKquu8Thdho1iq5JfADJke2RK4QeEXJv8BlEKquu8IxhyfNhoB9IxJiEXX5f)wgGrC0pL1a0)IZCv8(1UEaOeNdlnRTpGtnQjSN9ywW3(GsDGrMlyXMhlnRTpGtns1(1UMkrcrrXZsbvhewOvzcNKrtn8Nk8WzHtCTa3iJzb2nedocsdzaMInkRbO)BqYkhWFJc2FEsRlrcrrX3EmC4uJaLpwO1nSUT9iHOOOfJfvITygsXHKvoGx9kqyVsIFlluCE4SWjUkoCJmMfOQ44pjohwAwBFaNAK4RsckoxSqlXTnbM4O)kK4jQCaFiooV4XkoBfpsikkEXxO4dI43c6x85fhIdadaL4lcI41TaXtWvXtRfheIViIhjeffF9c7zpMf8TpOuhyK5cwS5XsZA7d4uJuDqyPmHtYOPg(tfE4SWjUwGBKXSa71zigCeKgYamfBuwdq)3GKvoG)gfQwnsnbIMnk5xGv(bbBeiz0KX(ZtADjsikk(2JHdNAeO8XcTUHfBRxyp7XSGV9bL6aJmxWInpgoCQrGYhl0s1bH1ZtADjsikkE1zD7lQJbhbPfyubUrqGgoF1QqCaHSquulRLjC(YV46ccmrzrGOA1NIcZcW)wme8o0u5o(U9i1eiApwAwBfKTJ)ncKmAYuV96yWrqA)vlMv)LfPyOmWkjESD4enC(QvrldocsJhswKzImMf0W5Rw95jTUejeffV6Sur9c7vsCoS0S2(ao1iXJvCiHaPht8BzagXr)uwdq)lEcmIhR4e4XHK42iX7jq8EcHxfFvsqXtXrW1AXVf0V4diwXdmsCaPMqCUvrIpiIZV)pmAQjSN9ywW3(GsDGrMlyXMhlnRTpGtns1bHLHyWrqAidWuSrzna9Fdsw5a(ByPq1Q9D1M1gO9xTyw9xwKIHYaRbjRCa)nkGMSBigCeKgYamfBuwdq)3GKvoG)M(UAZAd0(RwmR(llsXqzG1GKvoGxyp7XSGV9bL6aJmxWInO07AXOtdP6GWIbhbPXtqKfMbzkkPb8TpYEn1zPc79fyWNOXtqKfMbzkkPb8nycQPolfUTWE2JzbF7dk1bgzUGfBES0S2(ao1iH9ShZc(2huQdmYCbl20XOKV8yBO6GWcTrcrrrB(cZ(V9(AXSf(DaX3meY0NqDwkyNbhbP9yBugqjWOIjH1A482jabrDTfJfvITWw1QoQUPzLQ5eN4Ca]] )

    
end
