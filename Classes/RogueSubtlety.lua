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


    spec:RegisterPack( "Subtlety", 20220308, [[diLavcqiOuEKKK2evvFsskJsLOtPsyvssKxjPYSijUfjO2Lu9lOunmsihJezzQu5zQu00qs11iHABss4BQuiJJeeNdkHADiPO3HKsKMNkLUhsSpss)JeLshekrwiuspusQMijWfjrPyJQuWhjrPAKssu6KQuOwjsYlLKOyMiPu3KeLStvQ6NssunusuSuOe8uenvjvDvsqARiPK(kskmwOe1zrsjQ9QI)kXGPCyrlgHhlLjtLlJAZq8zOy0q60kwnskHxljMnPUnvz3a)wPHJuhhkHSCqpxvtx46q12jP(ovLXtIQZRsA9iPeX8Lu2pXhLo1FiDzWN7Vtr3DNIUPIWI7kclwXkP0HmUsZhs6SvjXWhsq6XhssCIqZX1djDEvVP7u)H8xCyJpKOrq)utSJDmtGIt0BRh2)XdxNXSGgmrcS)Jxd7hsc8rh3yWH4q6YGp3FNIU7ofDtfHf3vewm1XIP(npKjEGUWdj54v9dj64Cm4qCiD83oKK4eHMJRIHfwm4SqLYkHnuXuiQi2Dk6U7eQeQQoAcWWp1uOsHftzTQzXuNWjj0Ch)5cnCw4exlWnYywGy40I9Ryti28I9CigbJSqwmFSy4pl2eDHkfwSQVEedGfZdxhdTMfRLADjBXSGIE(qmgeWHFXIvmi7WBSy0BWGysTyq23cR0fQuyXuwzfwSBqZpAdMiHydiyieNoeBaI1wpImeBqeZhlg1c8peZnoXMqmKfkM6vNXO5YVA1mi6hs98XFQ)q(bN6aLDN6p3R0P(djdscn7oy9q2GtWWjpKxkgbocs)do1bAhNwSA1eJahbPRobZJ2XPf7cX8l2LI90SwxIeIHJV)O4WPcdkFSqpXUvmQlwTAIPoHtsO5o(ZfA4SWjUwGBKXSaXUqm)I5LFWWs(F()akq2lhWlgfXu0HmBXSGd5JMU13hWPcFiD83GdDml4qEJreJm4uhOyxDcMhvSeYIHtRIy4plgjA6wFFaNkSyXkgbdyKjedbUEIfOSy05)JAwmIfG)ILaNy3WaCIrn4ScG)xfXy1mqSbrmFSyjKfldX8sLlw1vgXUehO5)fd)hagXuw5hmumS0)5)d4ItCU)Ut9hsgKeA2DW6H0XFdo0XSGd5nmG5rfldXOEDIvDLrmFtGU4HykGufXuCDI5BcuXuaPkILaNyvHy(MavmfqkwIemumQ1emp6HmBXSGdzl16s2Izbf98XHSbNGHtEivNWjj0CNrq4wmQ5sB9i2c9oG4ftvkI1OlEPYlpndCIvRMye4ii9hfhovyqjwiiDBhNwm)I1wpITqVdi(UJrM2eIDlfXUtSA1e7PzTUejedhF)rXHtfgu(yHEIPkfXOUy(ftDcNKqZDgbHBXOMlT1Jyl07aIxmvPig1fRwnXARhXwO3beF3XitBcXULIykjMcl2LIfPMbr3XmndlFaZiXWEDgKeA2jMFXiWrq6QtW8ODCAXU4qQNpkG0JpKidyE0tCU)MN6pKmij0S7G1dzdobdN8q(bN6aLD9NP)5fZVypnR1LiHy447pkoCQWGYhl0tSBfJ6hYSfZcoKpA6wFFaNk8jo3t9t9hsgKeA2DW6HSbNGHtEijWrq60mezHzWUIAEaF)JSvrmvPiMIfZVye4ii9hnDRVIlbnUdzVCaVyQsrSBkMFXiWrq6pA6wFfcD64VJtlMFXEAwRlrcXWX3FuC4uHbLpwONy3srSBEiZwml4qsKTkFKehsh)n4qhZcoKynBv(ijeZHdhagXirt36tmfKGglMpugi2cedDWGkMYqTk2hzRYlwcCIrIMU1NyyvNo(fBEXWP7N4CVIp1FizqsOz3bRhYgCcgo5HmsndIoyWGgFK6kmSZGKqZoX8lgehWiled3JbCTeRYNwHqNoUZGKqZoX8l2tZADjsigo((JIdNkmO8Xc9e7wXu8HmBXSGd5JoQpX5(Q4u)HKbjHMDhSEiZwml4q(OPB99bCQWhY21MMlrcXWXFUxPdPJ)gCOJzbhsfkTyXk2nflsigoEXUeSIrdN9cXQWmTy40IDddWjg1GZka(FXiUkw7AtpamIrIMU13hWPc3pKn4emCYdj2etDcNKqZD8Nl0WzHtCTa3iJzbI5xmhtGJG0rgGR4JZka()oK9Yb8IDRykjMFXEAwRlrcXWX3FuC4uHbLpwONy3srSBkMFXIeIHJEmECj2IByXuyXGSxoGxmvfRkoX5(B0P(djdscn7oy9q2GtWWjpKQt4KeAUJ)CHgolCIRf4gzmlqm)IDPyoMahbPJmaxXhNva8)Di7Ld4f7wXusSA1elsndIUpoPxGx(bd7mij0Stm)I90SwxIeIHJV)O4WPcdkFSqpXULIyuxSloKzlMfCiF00T((aov4dPJ)gCOJzbhYByHIrdNfoXvXGBKXSaved)zXirt367d4uHfBvZqXiJf6jMVjqfJAOSelXKd4dXWPflwXOUyrcXWXl2cfBqe7gOgInVyqCayayeBrqe7YfiwcUkw6T4GqSfrSiHy44V4eN7viN6pKmij0S7G1dzdobdN8q(0SwxIeIHJxmvPi2nfRoXUumcCeKEGYf4gbd640IvRMyqCaJSqmCpRKjC(YV46ccmX4XGOZGKqZoXQvtSNJcXcW)Emm8ofs5o6MyxiMFXUumcCeK(F1Jy1Fzrkood0sIhBdorhNwSA1edBIrGJG0PHSh7MiJzbDCAXQvtSNM16sKqmC8IPkfXuSyxCiZwml4q(O4WPcdkFSqVtCUhl(u)HKbjHMDhSEiBWjy4KhshtGJG0rgGR4JZka()oK9Yb8IDlfXusSA1eRTR2T(a9)QhXQ)YIuCCgODi7Ld4f7wXusHiMFXCmbocshzaUIpoRa4)7q2lhWl2TI12v7wFG(F1Jy1Fzrkood0oK9Yb8hYSfZcoKpA6wFFaNk8H0XFdo0XSGdjjA6wFFaNkSyXkgKrG8Jk2nmaNyudoRa4)flboXIvmg84qwmFSyTeiwlHWRITQzOyPyi4ATy3a1qSbeRybklgGvEig5QaXgeXO3)hcn3pX5ELu0P(djdscn7oy9q2GtWWjpKe4iiDAgISWmyxrnpGV)r2QiMQuetXI5xS2cC4t0PziYcZGDf18a(ombvetvkIP0npKzlMfCiXO31JqNo(eN7vsPt9hYSfZcoKpA6wFFaNk8HKbjHMDhSEIZ9kD3P(djdscn7oy9q2GtWWjpKytSiHy4OpFHy)xm)I1wpITqVdi(UJrM2eIPkfXusm)IrGJG0F0nkdOeOCXLWkDCAX8lgdyiMR9y84sSfQRiXuvmmnx3lv(HmBXSGdzdLt6YJUXjoXH0XijUoo1FUxPt9hYSfZcoKvMwLdjdscn7oy9eN7V7u)HKbjHMDhSEix6d5ZXHmBXSGdP6eojHMpKQtnoFijWrq6VEACjbUIBAChNwSA1e7PzTUejedhF)rXHtfgu(yHEIPkfXQIdP6ewaPhFiFGR0wGBIzbhsh)n4qhZcoKk0NDIfRyooyO3ayX8HYbkdfRTR2T(aVy(YjedzHIrcuGye5ZoXwGyrcXWX3pX5(BEQ)qYGKqZUdwpKl9H854qMTywWHuDcNKqZhs1PgNpKe4ii9xpnUKaxXnnUJtlwTAI90SwxIeIHJV)O4WPcdkFSqpXuLIyvXHuDclG0JpKpWvAlWnXSGtCUN6N6pKmij0S7G1d5sFiFooKzlMfCivNWjj08HuDclG0JpKZxaSYJsJUKGXlBOjed7oKQtnoFiBRhXwO3beVyuetjX8lgbocsNBO7aWuGmnC8sGRCxhNwSA1eRTEeBHEhq8IrrS7eZVye4iiDUHUdatbY0WXlbUYn740IvRMyT1Jyl07aIxmkIDtX8lgbocsNBO7aWuGmnC8sGRq9ooTy1QjwB9i2c9oG4fJIyuxm)IrGJG05g6oamfitdhVe4kkUJtFiD83GdDml4qwDuUvrSyf7zwSbrSaLfdWkpeR6kJyxoaXcuwmwndcXweXsXirRxmA42UqS5fdlbgVSHMqmS7q2GtWWjpKTvndsq0RCfoj4eN7v8P(djdscn7oy9qU0hYNJdz2Izbhs1jCscnFivNAC(qYiiClg1CPTEeBHEhq8hs1jSasp(qYiiClg1CPTEeBHEhq8hsh)n4qhZcoKyPwBXbHyilums06fdYzlMfiwmESyexfBWaw4aWiME9PWvxzelbJx2qtig2jMxgnu(fBaIfOSykQR4xmAi3y2namILIrVbdIj1IrIwVy0WTDIZ9vXP(djdscn7oy9qU0hYNJdz2Izbhs1jCscnFivNAC(q2wpITqVdi(dP6ewaPhFizeeUfJAU0wpITqVdi(dzdobdN8q2w1mibrVYv4KaX8lgJGWTyuZL26rSf6DaXlMQI1wpITqVdiEX8lwB9i2c9oG47ogzAtiMQIDNy(flgpUeB5rJcTg)7uxSBftrDflMFXWMyQt4KeAUpFbWkpkn6scgVSHMqmS7eN7VrN6pKmij0S7G1d5sFiFooKzlMfCivNWjj08HuDQX5djnCw4exlWnYywGy(f7PzTUejedhF)rXHtfgu(yHEIPkfXU7qQoHfq6Xhs8Nl0WzHtCTa3iJzbhsh)n4qhZcoKv5a9vXAOjadlgCJmMfi2GiMpwm0unlgnCw4exlWnYywGyphILaNyE46yO1SyrcXWXlgoD)eN7viN6pKmij0S7G1dz2IzbhYwQ1LSfZck65JdPJ)gCOJzbhYQJYTkIvDf8ILHyid8JdPE(Oasp(q2C)jo3JfFQ)qYGKqZUdwpKn4emCYd5tZADjsigo((JIdNkmO8Xc9e7wXQcX8lgYGbnkq2lhWlMQIvfI5xmcCeK(RNgxsGR4Mg3HSxoGxSBfdtZ19sLlMFXARhXwO3beVyQsrmQlMcl2LIfJhl2TIPKIe7cXQsID3HmBXSGd5RNgxsGR4MgFiD83GdDml4qILOP1xfJupnwSe4etbtJfldXURoXQUYiMdhoamIfOSyid8dXusrI9CBbUxfXsKGHIfOzig1RtSQRmIniInHySYPhi)I5Bc0biwGYIbyLhIPSxDfi2cfBEXaBigo9jo3RKIo1FizqsOz3bRhsh)n4qhZcoKybCGyi4A9vXEFt0q5xSyflqzXido1bk7edlSrgZce7sIRI52bGrSFvrSjedzHn(fJEx9aWi2Gigyd0bGrS5flvNJoj08f9dz2IzbhsioOKTywqrpFCiBWjy4KhYp4uhOSRNA9HupFuaPhFi)GtDGYUtCUxjLo1FizqsOz3bRhsh)n4qhZcoKkdCw4exfdlSrgZcu2kg1MJQ9IHzuZILI1GjTyjXIhIXagI5QyiluSaLf7do1bQyvxbVyxsGpAhdf7JrRfdYpn3cXM4IUyulJtRIytiwlbIrWIfOzi2pE0AUFiZwml4q2sTUKTywqrpFCiBWjy4Khs1jCscn3XFUqdNfoX1cCJmMfCi1Zhfq6XhYp4uhOLM7pX5ELU7u)HKbjHMDhSEix6d5ZXHmBXSGdP6eojHMpKQtnoFiVtXIvNyrQzq0vpywyNbjHMDIvLe7ofjwDIfPMbr3l)GHLfP8OPB99DgKeA2jwvsS7uKy1jwKAge9hnDRVcY2W)odscn7eRkj2DkwS6elsndIEQZgCIRDgKeA2jwvsS7uKy1j2DkwSQKyxk2tZADjsigo((JIdNkmO8Xc9etvkIrDXU4qQoHfq6XhYp4uhOLafYp6QDhsh)n4qhZcoKk0NDIfRyogzaSy(qzGyXkg(ZI9bN6avSQRGxSfkgb(ODm8pX5ELU5P(djdscn7oy9q64Vbh6ywWHS6l4hhdfd)hagXsXido1bQyvxbI5dLbIb5SHoamIfOSymGHyUkwGc5hD1Udz2IzbhYwQ1LSfZck65JdzdobdN8qYagI5A3XitBcXULIyQt4KeAU)bN6aTeOq(rxT7qQNpkG0JpKFWPoqln3FIZ9kr9t9hsgKeA2DW6H0XFdo0XSGd5nmG5rfldX8sLRIyuVoX8nb6IhIPasXwOy(MavmYvbI1GtigbocIkIP46eZ3eOIPasXUCXJFCSyFWPoqVqfX8nbQykGuSu)RyidyEuXYqmQxNyjMCaFig1flsigoEXUCXJFCSyFWPoqV4qMTywWHSLADjBXSGIE(4q2GtWWjpKQt4KeAUZiiClg1CPTEeBHEhq8IPkfXA0fVu5LNMboXQvtS26rSf6DaX3DmY0MqSBPiMsIvRMyidg0OazVCaVy3srmLeZVyQt4KeAUZiiClg1CPTEeBHEhq8IPkfXUPy1Qjgbocs)V6rS6VSifhNbAjXJTbNOJtlMFXuNWjj0CNrq4wmQ5sB9i2c9oG4ftvkIrDXQvtSNM16sKqmC89hfhovyq5Jf6jMQueJ6I5xm1jCscn3zeeUfJAU0wpITqVdiEXuLIyu)qQNpkG0JpKidyE0tCUxjfFQ)qYGKqZUdwpKo(BWHoMfCivOplwkgb(ODmumFOmqmiNn0bGrSaLfJbmeZvXcui)OR2DiZwml4q2sTUKTywqrpFCiBWjy4KhsgWqmx7ogzAti2TuetDcNKqZ9p4uhOLafYp6QDhs98rbKE8HKaF0UtCUxPQ4u)HKbjHMDhSEiBWjy4KhsgWqmx7ogzAtiMQuetjflwDIXagI5AhYyyWHmBXSGdzcBjGlXcHmioKo(BWHoMfCiP2Rp(dXOHZcN4QydqSuRfBrelqzXWskd1wmcUL4pl2eI1s8NFXsXu2RUcoX5ELUrN6pKzlMfCitylbCHgx)8HKbjHMDhSEIZ9kPqo1FiZwml4qQhmOXxOwG7W4XG4qYGKqZUdwpX5ELWIp1FiZwml4qsKyklsjGtRYFizqsOz3bRN4ehsAi3wpImo1FUxPt9hYSfZcoKjnT(AHENFbhsgKeA2DW6jo3F3P(dz2IzbhsIncn7ki68k78namLyv(aoKmij0S7G1tCU)MN6pKmij0S7G1dzdobdN8q(lUMyaUon(h4AUWqC6ywqNbjHMDIvRMy)IRjgGRRE1zmAU8RwndIodscn7oKzlMfCir08J2GjsCIZ9u)u)HmBXSGd5hCQd0djdscn7oy9eN7v8P(djdscn7oy9qMTywWH0lHvyxbzHfhNb6HKgYT1JiJYZTf4(dPsk(eN7RIt9hsgKeA2DW6HSbNGHtEiHmcKF0KqZhYSfZcoKVEACjbUIBA8HKgYT1JiJYZTf4(dPsN4C)n6u)HKbjHMDhSEiBWjy4KhsioGrwigU7LWkLfPeOCXl)GHL8)8)b0zqsOz3HmBXSGd5JMU1xHqNo(pXjoKe4J2DQ)CVsN6pKmij0S7G1dzdobdN8qInXIuZGOdgmOXhPUcd7mij0Stm)IbXbmYcXW9yaxlXQ8Pvi0PJ7mij0Stm)I90SwxIeIHJV)O4WPcdkFSqpXUvmfFiZwml4q(OJ6tCU)Ut9hsgKeA2DW6HSbNGHtEiFAwRlrcXWXlMQue7oX8l2LIHnXARAgKGOd4gC1l0jwTAI12v7wFG(ZqygSRqSaU80tfU7LkV0qtig(ftHfRHMqm8xqGzlMfKAXuLIykQFNIfRwnXEAwRlrcXWX3FuC4uHbLpwONyQkg1f7cX8l2LIrGJG0PziYcZGDf18a((hzRIy3srmQlwTAI90SwxIeIHJV)O4WPcdkFSqpXuvmQl2fhYSfZcoKpkoCQWGYhl07eN7V5P(djdscn7oy9q2GtWWjpKe4iiDAgISWmyxrnpGV)r2Qi2Tue7oX8l2LI12v7wFG(ZqygSRqSaU80tfU7LkV0qtig(ftHfRHMqm8xqGzlMfKAXULIykQFNIfRwnX(fxtmaxxZPRqCTWkp9O1CNbjHMDI5xmSjgbocsxZPRqCTWkp9O1ChNwSA1e7xCnXaC9kS6b8LDPwcRhaModscn7eZVyytmhtGJG0RWQhWx8bZaTJtl2fhYSfZcoKpdHzWUcXc4Ytpv4tCUN6N6pKzlMfCiXO31JqNo(qYGKqZUdwpX5EfFQ)qYGKqZUdwpKn4emCYdj2eRTQzqcIELRWjbIvRMyytSlftDcNKqZ95law5rPrxsW4Ln0eIHDI5xSlflgpUeB5rJcTg)73uSBftrDflwTAIfJhxIT8OrHwJ)DQl2TIPKyxiMFXyadXCvSBfRkuKyxCiZwml4qsKTkFKehsh)n4qhZcoKynBv(ijeB88y3KbRVkgoqZ)lwGYIbyLhIvDLrS5fdlbgVSHMqmStSe4eZhlMVfuTqSwslgdyiMRI5lNyayedzHInr)eN4q2C)P(Z9kDQ)qYGKqZUdwpKn4emCYdj2eJahbP)OPB9vCjOXDCAX8lgbocs)rXHtfguIfcs32XPfZVye4ii9hfhovyqjwiiDBhYE5aEXULIy3SR4dj(ZLfbPGP5o3R0H0XFdo0XSGdPc9zXuqcASylcIcJP5eJGrwilwGYIHmWpeJefhovyGyKXc9edbUEIv)cbPBfRTE8l2a6hYSfZcoKpA6wFfxcA8jo3F3P(djdscn7oy9q2GtWWjpKe4ii9hfhovyqjwiiDBhNwm)IrGJG0FuC4uHbLyHG0TDi7Ld4f7wkIDZUIpK4pxweKcMM7CVshsh)n4qhZcoKxQqbA(FXsnKt3vXWPfJGBj(ZI5Jfl2TIyKOPB9j2nSn8)cXWFwmYREeR(fBrquymnNyemYczXcuwmKb(HyKO4WPcdeJmwONyiW1tS6xiiDRyT1JFXgq)qMTywWH8V6rS6VSifhNb6jo3FZt9hsgKeA2DW6HSbNGHtEivNWjj0C)bUsBbUjMfiMFXWMyFWPoqzx3lbHMfZVyxk2tZADjsigo((JIdNkmO8Xc9e7wkIPKy(fRTR2T(a9)QhXQ)YIuCCgODCAX8lg2elsndI(JMU1xbzB4FNbjHMDIvRMye4ii9)QhXQ)YIuCCgODCAXUqm)I1wpITqVdiEXuLIyk(qMTywWHerNyyToJzbN4Cp1p1FizqsOz3bRhYgCcgo5H8sXG4agzHy4UxcRuwKsGYfV8dgwY)Z)hqNbjHMDI5xS26rSf6DaX3DmY0MqSBPiMsIPWIfPMbr3XmndlFaZGXWEDgKeA2jwTAIbXbmYcXWDhNbQ(A5rt3677mij0Stm)I1wpITqVdiEXUvmLe7cX8lgbocs)V6rS6VSifhNbAhNwm)IrGJG0F00T(kUe04ooTy(fZl)GHL8)8)buGSxoGxmkIPiX8lgbocs3XzGQVwE00T((UB9boKzlMfCivNG5rpX5EfFQ)qYGKqZUdwpKilSayLhN7v6q64Vbh6ywWHuz2vlgYcfR(fcs3kgnKvyYvbI5BcuXirvGyqoDxfZhkdedSHyqCayayeJ8g6hYgCcgo5HmsndI(JIdNkmOeleKUTZGKqZoX8lg2elsndI(JMU1xbzB4FNbjHMDhYSfZcoK07Qlq(xCyJpX5(Q4u)HKbjHMDhSEiBWjy4KhYNM16sKqmC89hfhovyq5Jf6j2TuetjX8lgdyiMRIPkfXQcfjMFXuNWjj0C)bUsBbUjMfiMFXA7QDRpq)V6rS6VSifhNbAhNwm)I12v7wFG(JMU1xXLGg3BOjed)IPkfXusm)IDPyytmioGrwigUVeSByqJ7mij0StSA1eZXe4iiDeDIH16mMf0XPfRwnXEAwRlrcXWX3FuC4uHbLpwONyQsrSlftjXQtmQlwvsSlfdBIfPMbrhmyqJpsDfg2zqsOzNy(fdBIfPMbr3LWkLhnDRVodscn7e7cXUqSleZVyT1Jyl07aIxSBPi2DI5xmSjgbocsNgYESBImMf0XPfZVyxkg2eRTQzqcIUAgeOxHIvRMyytS2UA36d0r0jgwRZywqhNwSloKzlMfCiFuC4uHbLyHG0Thsh)n4qhZcoKk0NfR(fcs3kgnKfJCvGy(qzGy(yXqt1SybklgdyiMRI5dLdugkgcC9eJEx9aWiMVjqx8qmYBqSfkg1c8pedddyyQ1x7N4C)n6u)HKbjHMDhSEiBWjy4Khs1jCscn3FGR0wGBIzbI5xmSjMBJ(ZqygSRqSaU80tfU42OhtRYaWiMFXIeIHJEmECj2IByXuLIy3PKy(f7sXARhXwO3beF3XitBcXuLIyxkwJUGjhGyQQSvmQl2fIDHy(fdBIrGJG0FuC4uHbLyHG0TDCAX8l2LIHnXiWrq60q2JDtKXSGooTy1Qj2tZADjsigo((JIdNkmO8Xc9etvXOUyxiwTAIHmyqJcK9Yb8IDlfXuSy(f7PzTUejedhF)rXHtfgu(yHEIDRy38qMTywWH8zimd2viwaxE6PcFiBxBAUejedh)5ELoX5EfYP(djdscn7oy9q2GtWWjpKQt4KeAU)axPTa3eZceZVyT1Jyl07aIV7yKPnHyQsrmLeZVyrcXWrpgpUeBXnSyQsrmLQIdz2IzbhYNP)5pX5ES4t9hsgKeA2DW6HSbNGHtEivNWjj0C)bUsBbUjMfiMFXUumSjwKAge9hfhovyqjwiiDBNbjHMDIvRMyrQzq0F00T(kiBd)7mij0StSA1e7PzTUejedhF)rXHtfgu(yHEIPkfXUtSA1eRTR2T(a9hfhovyqjwiiDBhYE5aEXuvS7e7cX8l2LIHnXARAgKGORMbb6vOy1QjwBxTB9b6i6edR1zmlOdzVCaVyQkMsksSA1eRTR2T(aDeDIH16mMf0XPfZVyT1Jyl07aIxmvPiMIf7Idz2IzbhY)QhXQ)YIuCCgOhsh)n4qhZcoKk0NfJ8QhXQFXwGyTD1U1hqSltKGHIHmWpeJeOGledhO5)fZhlwczXWSdaJyXkg9slw9leKUvSe4eZTIb2qm0unlgjA6wFIDdBd)7N4CVsk6u)HKbjHMDhSEiZwml4q6LWkSRGSWIJZa9qQhaxAUdPsDfFiD83GdDml4qEJrelDUxSeYIHtRIypyOzXcuwSfWI5BcuX0Rp(dXQVEf0ftH(Sy(qzGyURdaJyi5hmuSanbIvDLrmhJmTjeBHIb2qSp4uhOStmFtGU4Hyj4Qyvxz6hYgCcgo5HeMJRWQzq0tN7740I5xSlflsigo6X4XLylUHf7wXARhXwO3beF3XitBcXQvtmSj2hCQdu21tTwm)I1wpITqVdi(UJrM2eIPkfXA0fVu5LNMboXU4q2U20Cjsigo(Z9kDIZ9kP0P(djdscn7oy9q2GtWWjpKWCCfwndIE6CFFaIPQy3urIPWIbZXvy1mi6PZ9DhomJzbI5xS26rSf6DaX3DmY0MqmvPiwJU4LkV80mWDiZwml4q6LWkSRGSWIJZa9q64Vbh6ywWH8gJigyflDUxmFJwlMByX8nb6aelqzXaSYdXUPIEved)zXuwikqSfigX(Vy(MaDXdXsWvXQUY0pX5ELU7u)HKbjHMDhSEiBWjy4Khs1jCscn3FGR0wGBIzbI5xS26rSf6DaX3DmY0MqmvPi2DI5xSlfJahbP)x9iw9xwKIJZaTJtlwTAIrS)lMFXqgmOrbYE5aEXULIy3PiXQvtmSjgbocs)rt36RqOth)DCAX8l2ZrHyb4FpggENcPChDtSloKzlMfCiF00T(ke60X)jo3R0np1FizqsOz3bRhYgCcgo5HeBI9bN6aLD9uRfZVyQt4KeAU)axPTa3eZceZVyT1Jyl07aIV7yKPnHyQsrS7eZVyxkM6eojHM74pxOHZcN4AbUrgZceRwnXEAwRlrcXWX3FuC4uHbLpwONy3srmQlwTAIbXbmYcXWDi)loWnamLMoHtCTZGKqZoXU4qMTywWHKBO7aWuGmnC8sG7eN7vI6N6pKmij0S7G1dzdobdN8qEPyrQzq0F00T(kiBd)7mij0StSA1e7PzTUejedhF)rXHtfgu(yHEIPkfXUtSleZVyQt4KeAU)axPTa3eZceZVye4ii9)QhXQ)YIuCCgODCAX8lwB9i2c9oG4f7wkIDNy(f7sXWMye4iiDAi7XUjYywqhNwSA1e7PzTUejedhF)rXHtfgu(yHEIPQyuxSloKzlMfCiFuC4uHbLyHG0Thsh)n4qhZcoKuJjqfJ8gurSbrmWgILAiNURI5waRIy4plw9leKUvmFtGkg5QaXWP7N4CVsk(u)HKbjHMDhSEiBWjy4KhsSjgbocs)rt36R4sqJ740I5xmKbdAuGSxoGxSBPiMcrS6elsndI(Jtemebhd3zqsOz3HmBXSGd5JMU1xXLGgFIZ9kvfN6pKmij0S7G1dzdobdN8qEPy)IRjgGRtJ)bUMlmeNoMf0zqsOzNy1Qj2V4AIb46QxDgJMl)QvZGOZGKqZoXUqm)IXagI5A3XitBcXuLIy3urI5xmSj2hCQdu21tTwm)IrGJG0)REeR(llsXXzG2DRpWHCabdH40rzqoK)IRjgGRRE1zmAU8RwndId5acgcXPJY45XUjd(qQ0HmBXSGdjIMF0gmrId5acgcXPJcg9sK6dPsN4CVs3Ot9hsgKeA2DW6HSbNGHtEijWrq6e6DDA8p6qoBHy1QjgYGbnkq2lhWl2TIDtfjwTAIrGJG0)REeR(llsXXzG2XPfZVyxkgbocs)rt36RqOth)DCAXQvtS2UA36d0F00T(ke60XFhYE5aEXULIykPiXU4qMTywWHKEJzbN4CVskKt9hsgKeA2DW6HSbNGHtEijWrq6)vpIv)LfP44mq740hYSfZcoKe6DDfeC41tCUxjS4t9hsgKeA2DW6HSbNGHtEijWrq6)vpIv)LfP44mq740hYSfZcoKem8zyLbG5eN7VtrN6pKmij0S7G1dzdobdN8qsGJG0)REeR(llsXXzG2XPpKzlMfCirgitO31DIZ93P0P(djdscn7oy9q2GtWWjpKe4ii9)QhXQ)YIuCCgODC6dz2IzbhYe04pGPU0sT(eN7V7Ut9hsgKeA2DW6HeKE8HSLnuUSiLSHfHpq2vciNpoK)dz2IzbhYw2q5YIuYgwe(azxjGC(4q(pKn4emCYdjbocspByr4dKDLu5ChNwm)IDPypnR1LiHy447pkoCQWGYhl0tmkIPKy(fdMJRWQzq0tN77dqmvfRkuKy1Qj2tZADjsigo((JIdNkmO8Xc9etvXusSleRwnXi2)fZVyidg0OazVCaVy3k2Dk(eN7V7MN6pKmij0S7G1dzdobdN8qsGJG0)REeR(llsXXzG2XPfRwnXqgmOrbYE5aEXUvS7u0HmBXSGdj(ZLjyV)q64Vbh6ywWHubmsIRdXqsTMiBvedzHIH)jHMfBc27PMIPqFwmFtGkg5vpIv)ITiIPaod0(joXH8do1bAP5(t9N7v6u)HKbjHMDhSEix6d5ZXHmBXSGdP6eojHMpKQtnoFiB7QDRpq)rt36R4sqJ7n0eIH)ccmBXSGulMQuetP(nsXhs1jSasp(q(OUsGc5hD1UdPJ)gCOJzbhYQSSMMHIrTMWjj08jo3F3P(djdscn7oy9q2GtWWjpKxkg2etDcNKqZ9h1vcui)OR2jwTAIHnXIuZGOdgmOXhPUcd7mij0Stm)IfPMbr3LWkLhnDRVodscn7e7cX8lwB9i2c9oG47ogzAtiMQIPKy(fdBIbXbmYcXWDVewPSiLaLlE5hmSK)N)pGodscn7oKzlMfCivNG5rpKo(BWHoMfCiPwtW8OIniI5JflHSyTKMEayeBbIPGe0yXAOjed)DXu2Kq9vXiyKfYIHmWpeZLGgl2GiMpwm0unlgyf7(bdA8rQRWqXiWdXuqcRigjA6wFInaXwOJHIfRyy4qmSaoDGdzXWPf7sWkMYk)GHIHL(p)Fax0pX5(BEQ)qYGKqZUdwpKilSayLhN7v6q64Vbh6ywWHuz2vlgYcfJenDRppw7eRoXirt367d4uHfdhO5)fZhlwczXsIfpelwXAjTylqmfKGglwdnHy4VlwvoqFvmFOmqSByaoXOgCwbW)l28ILelEiwSIbXbIT4r)q2GtWWjpKWSXDWGbnkSg5qYkpGzj9wCqCiPUIoKzlMfCiP3vxG8V4WgFIZ9u)u)HKbjHMDhSEiBWjy4KhsgWqmxftvkIrDfjMFXyadXCT7yKPnHyQsrmLuKy(fdBIPoHtsO5(J6kbkKF0v7eZVyT1Jyl07aIV7yKPnHyQkMshYSfZcoKpA6wFES2DIZ9k(u)HKbjHMDhSEix6d5ZXHmBXSGdP6eojHMpKQtnoFiBRhXwO3beF3XitBcXuLIy3jwDIrGJG0F00T(ke60XFhN(qQoHfq6XhYh1vARhXwO3be)H0XFdo0XSGdz1vgXcui)OR29IHSqXyqWWbGrms00T(etbjOXN4CFvCQ)qYGKqZUdwpKl9H854qMTywWHuDcNKqZhs1PgNpKT1Jyl07aIV7yKPnHyQsrSBEivNWci94d5J6kT1Jyl07aI)q2GtWWjpKTvndsq0RCfoj4eN7VrN6pKmij0S7G1d5sFiFooKzlMfCivNWjj08HuDQX5dzB9i2c9oG47ogzAti2TuetPdP6ewaPhFiFuxPTEeBHEhq8hYgCcgo5HuDcNKqZD8Nl0WzHtCTa3iJzbI5xSNM16sKqmC89hfhovyq5Jf6jMQueJ6N4CVc5u)HKbjHMDhSEiBWjy4KhYlf7sXuNWjj0C)rDL26rSf6DaXlwTAIPoHtsO5(J6kbkKF0v7e7cX8l2ZrHyb4FpggENcPChDtm)I1w1mibrVYv4KaXQvtm1jCscn3FuxPTEeBHEhq8I5xSlfJahbP)x9iw9xwKIJZaTdzVCaVyQsrmL63jwTAIPoHtsO5(J6kbkKF0v7e7cXQvtmcCeKEdn3VqKaUJtlwTAI90SwxIeIHJV)O4WPcdkFSqpXuLIyuxm)I12v7wFG(F1Jy1Fzrkood0oK9Yb8IPQykPiXUqm)IDPye4iiDAgISWmyxrnpGV)r2Qi2TIrDXQvtSNM16sKqmC89hfhovyq5Jf6jMQIDtXU4qMTywWH8rt36R4sqJpKo(BWHoMfCivqcASyoC4aWig5vpIv)ITqXsIvnlwGc5hD1U(jo3JfFQ)qYGKqZUdwpKn4emCYdP6eojHM7pQR0wpITqVdiEX8lgYGbnkq2lhWl2TI12v7wFG(F1Jy1Fzrkood0oK9Yb8IvRMyytSi1mi6mqnRx6bGP8OPB99DgKeA2DiZwml4q(OPB9vCjOXhsh)n4qhZcoKyfhcetbjOXVyn0eIHFXgeXUU4IrRZRIPGewrms00T(ESJL0zdoXvXwOyemYczXcuwmKbdAigdCVydIyKRceZ3cQwigblgKt3vXgGyX4X9tCIdjYaMh9u)5ELo1FizqsOz3bRhYL(q(CCiZwml4qQoHtsO5dP6uJZhYi1mi60q2JDtKXSGodscn7eZVypnR1LiHy447pkoCQWGYhl0tSBf7sXuSykSyTvndsq0bCdU6f6e7cX8lg2eRTQzqcIELRWjbhs1jSasp(qsdzp2vEGR0wGBIzbhsh)n4qhZcoKud0rZIH)daJykdK9y3ezmlqfXs174eRLFmamIrQNglwcCIPGPXI5dLbIrIMU1NykibnwS5f73fiwSIrWIH)StfXyL3y6qmKfkwvMRWjbN4C)DN6pKmij0S7G1dzdobdN8qInXuNWjj0CNgYESR8axPTa3eZceZVypnR1LiHy447pkoCQWGYhl0tSBfRkeZVyytmcCeK(JMU1xXLGg3XPfZVye4ii9xpnUKaxXnnUdzVCaVy3kgYGbnkq2lhWlMFXGmcKF0KqZhYSfZcoKVEACjbUIBA8jo3FZt9hsgKeA2DW6HSbNGHtEivNWjj0CNgYESR8axPTa3eZceZVyTD1U1hO)OPB9vCjOX9gAcXWFbbMTywqQf7wXuQFJuSy(fJahbP)6PXLe4kUPXDi7Ld4f7wXA7QDRpq)V6rS6VSifhNbAhYE5aEX8l2LI12v7wFG(JMU1xXLGg3HC6UkMFXiWrq6)vpIv)LfP44mq7q2lhWlMclgbocs)rt36R4sqJ7q2lhWl2TIPu)oXU4qMTywWH81tJljWvCtJpX5EQFQ)qYGKqZUdwpKl9H854qMTywWHuDcNKqZhs1PgNpKE5hmSK)N)pGcK9Yb8IPQyksSA1edBIfPMbrhmyqJpsDfg2zqsOzNy(flsndIUlHvkpA6wFDgKeA2jMFXiWrq6pA6wFfxcAChNwSA1e7PzTUejedhF)rXHtfgu(yHEIPkfXUumQlMcl2hCQdu21tTwSQKyrQzq0F00T(kiBd)7mij0StSloKQtybKE8H8Rm0fioDGd5dPJ)gCOJzbhYQSSMMHIrTMWjj0SyilumSaoDGd5UyKvgAXC4WbGrmLv(bdfdl9F()aeBHI5WHdaJykibnwmFtGkMcsyfXsGtmWk29dg04JuxHH9tCUxXN6pKmij0S7G1dzdobdN8qInX(GtDGYUEQ1I5xSlfdBIPoHtsO5(xzOlqC6ahYIvRMyQt4KeAUJ)CHgolCIRf4gzmlqSleZVyrcXWrpgpUeBXnSykSyq2lhWlMQIvfI5xmiJa5hnj08HmBXSGdjeNoWH8H0XFdo0XSGdzvgMPfdNwmSaoDGdzXgeXMqS5fljw8qSyfdIdeBXJ(jo3xfN6pKzlMfCiFUb5OeCdfmyr48HKbjHMDhSEIZ93Ot9hsgKeA2DW6HmBXSGdjeNoWH8HSDTP5sKqmC8N7v6q64Vbh6ywWHuzHRJXTrmamIfjedhVybAgI5B0AX0JAwmKfkwGYI5WHzmlqSfrmSaoDGdzvedYiq(rfZHdhagXOtGJ9Mw)q2GtWWjpKytm1jCscn3)kdDbIth4qwm)IHnXuNWjj0Ch)5cnCw4exlWnYywGy(f7PzTUejedhF)rXHtfgu(yHEIPkfXUtm)Ifjedh9y84sSf3WIPkfXUumflwDIDPy3jwvsS26rSf6DaXl2fIDHy(fdYiq(rtcnFIZ9kKt9hsgKeA2DW6HSbNGHtEiXMyQt4KeAU)vg6ceNoWHSy(fdYE5aEXUvS2UA36d0)REeR(llsXXzG2HSxoGxS6etjfjMFXA7QDRpq)V6rS6VSifhNbAhYE5aEXULIykwm)Ifjedh9y84sSf3WIPWIbzVCaVyQkwBxTB9b6)vpIv)LfP44mq7q2lhWlwDIP4dz2IzbhsioDGd5dPJ)gCOJzbhsSaJa5hvmSaoDGdzX4eQVk2Gi2eI5B0AXyLtpqwmhoCayeJ8QhXQ)UykyflqZqmiJa5hvSbrmYvbIHHJxmiNURInaXcuwmaR8qmf)9tCUhl(u)HKbjHMDhSEiBWjy4KhsSjM6eojHM74pxOHZcN4AbUrgZceZVypnR1LiHy44ftvkIDZdz2IzbhscD2QuOxFogEIZ9kPOt9hYSfZcoKS65Bmmd(qYGKqZUdwpXjoXHund)zbN7Vtr3DNIUPIURR0H0xcbdaZFiPgyjSW9347v2PMIjw9OSyJh9cdXqwOyv7do1bk7QMyqglcFGStSF9yXs8y9YGDI1qtag(7cvu7bWIPyQPyvFbQzyWoXQgehWiled3XYvtSyfRAqCaJSqmChl3zqsOzx1e7sLu(fDHkQ9ayXuiutXQ(cuZWGDIvnioGrwigUJLRMyXkw1G4agzHy4owUZGKqZUQj2LkP8l6cvcvudSew4(B89k7utXeREuwSXJEHHyiluSQrd526rKr1edYyr4dKDI9RhlwIhRxgStSgAcWWFxOIApawSBsnfR6lqndd2jw1(fxtmaxhlxnXIvSQ9lUMyaUowUZGKqZUQj2LkP8l6cvu7bWIDtQPyvFbQzyWoXQ2V4AIb46y5QjwSIvTFX1edW1XYDgKeA2vnXYqmLnv5uBXUujLFrxOIApawSBe1uSQVa1mmyNyvdIdyKfIH7y5QjwSIvnioGrwigUJL7mij0SRAILHykBQYP2IDPsk)IUqLqf1alHfU)gFVYo1umXQhLfB8OxyigYcfRAn3xnXGmwe(azNy)6XIL4X6Lb7eRHMam83fQO2dGfJ6utXQ(cuZWGDIvnioGrwigUJLRMyXkw1G4agzHy4owUZGKqZUQj2L3P8l6cvu7bWIvfutXQ(cuZWGDIvnioGrwigUJLRMyXkw1G4agzHy4owUZGKqZUQj2LkP8l6cvu7bWIP0nPMIv9fOMHb7eRAqCaJSqmChlxnXIvSQbXbmYcXWDSCNbjHMDvtSlvs5x0fQO2dGftPQGAkw1xGAggStSQ9lUMyaUowUAIfRyv7xCnXaCDSCNbjHMDvtSlVt5x0fQeQOgyjSW9347v2PMIjw9OSyJh9cdXqwOyv7do1bAP5(QjgKXIWhi7e7xpwSepwVmyNyn0eGH)Uqf1EaSy3rnfR6lqndd2jw1G4agzHy4owUAIfRyvdIdyKfIH7y5odscn7QMyziMYMQCQTyxQKYVOlujurnWsyH7VX3RStnftS6rzXgp6fgIHSqXQgb(ODvtmiJfHpq2j2VESyjESEzWoXAOjad)DHkQ9ayXuIAkw1xGAggStSQbXbmYcXWDSC1elwXQgehWiled3XYDgKeA2vnXUujLFrxOIApawmftnfR6lqndd2jw1IXJlXwE0OJL70A8VAIfRyvlgpUeB5rJcTg)7y5Qj2L3P8l6cvcv3yp6fgStSBKyzlMfiME(47cvhYNMBN7VRku6qsdxKrZhYQwvXiXjcnhxfdlSyWzHQQwvXuwjSHkMcrfXUtr3DNqLqvvRQyvhnby4NAkuv1QkMclMYAvZIPoHtsO5o(ZfA4SWjUwGBKXSaXWPf7xXMqS5f75qmcgzHSy(yXWFwSj6cvvTQIPWIv91JyaSyE46yO1SyTuRlzlMfu0ZhIXGao8lwSIbzhEJfJEdgetQfdY(wyLUqvvRQykSykRScl2nO5hTbtKqSbemeIthInaXARhrgIniI5JfJAb(hI5gNytigYcft9QZy0C5xTAgeDHkHQQwvXugiRWvF9iYqOkBXSGVtd526rKrDuWEstRVwO35xGqv2IzbFNgYT1JiJ6OGDIncn7ki68k78namLyv(aeQYwml470qUTEezuhfSJO5hTbtKqLbHYV4AIb4604FGR5cdXPJzb1Q9lUMyaUU6vNXO5YVA1mieQYwml470qUTEezuhfS)bN6avOkBXSGVtd526rKrDuWUxcRWUcYclooduvOHCB9iYO8CBbUNIskwOkBXSGVtd526rKrDuW(RNgxsGR4MgRcnKBRhrgLNBlW9uusLbHcKrG8JMeAwOkBXSGVtd526rKrDuW(JMU1xHqNo(vzqOaXbmYcXWDVewPSiLaLlE5hmSK)N)paHkHQQwvXuw5aedlSrgZceQYwml4PuzAveQQQyk0NDIfRyooyO3ayX8HYbkdfRTR2T(aVy(YjedzHIrcuGye5ZoXwGyrcXWX3fQYwml4RJc2vNWjj0SkG0JP8axPTa3eZcurDQXzke4ii9xpnUKaxXnnUJtxR2tZADjsigo((JIdNkmO8Xc9uLsviuLTywWxhfSRoHtsOzvaPht5bUsBbUjMfOI6uJZuiWrq6VEACjbUIBAChNUwTNM16sKqmC89hfhovyq5Jf6PkLQqOQQIvDuUvrSyf7zwSbrSaLfdWkpeR6kJyxoaXcuwmwndcXweXsXirRxmA42UqS5fdlbgVSHMqmStOkBXSGVokyxDcNKqZQaspMY8faR8O0Oljy8YgAcXWovgekTvndsq0RCfojqf1PgNP0wpITqVdiEkk5NahbPZn0DaykqMgoEjWvURJtxRwB9i2c9oG4PCNFcCeKo3q3bGPazA44Lax5MDC6A1ARhXwO3bepLB6NahbPZn0DaykqMgoEjWvOEhNUwT26rSf6DaXtH6(jWrq6CdDhaMcKPHJxcCff3XPfQQQyyPwBXbHyilums06fdYzlMfiwmESyexfBWaw4aWiME9PWvxzelbJx2qtig2jMxgnu(fBaIfOSykQR4xmAi3y2namILIrVbdIj1IrIwVy0WTjuLTywWxhfSRoHtsOzvaPhtHrq4wmQ5sB9i2c9oG4vrDQXzkmcc3IrnxARhXwO3beVqv2IzbFDuWU6eojHMvbKEmfgbHBXOMlT1Jyl07aIxLbHsBvZGee9kxHtc8ZiiClg1CPTEeBHEhq8Q2wpITqVdiE)T1Jyl07aIV7yKPnHQ35pgpUeB5rJcTg)7u)wf1vSFSPoHtsO5(8faR8O0Oljy8YgAcXWovuNACMsB9i2c9oG4fQQQyv5a9vXAOjadlgCJmMfi2GiMpwm0unlgnCw4exlWnYywGyphILaNyE46yO1SyrcXWXlgoDxOkBXSGVokyxDcNKqZQaspMc(ZfA4SWjUwGBKXSavuNACMcnCw4exlWnYywG)NM16sKqmC89hfhovyq5Jf6PkL7eQQQyvhLBveR6k4fldXqg4hcvzlMf81rb7TuRlzlMfu0ZhQaspMsZ9cvvvmSenT(QyK6PXILaNykyASyzi2D1jw1vgXC4WbGrSaLfdzGFiMsksSNBlW9QiwIemuSandXOEDIvDLrSbrSjeJvo9a5xmFtGoaXcuwmaR8qmL9QRaXwOyZlgydXWPfQYwml4RJc2F904scCf30yvgekpnR1LiHy447pkoCQWGYhl072QWpYGbnkq2lhWRAv4NahbP)6PXLe4kUPXDi7Ld4VftZ19sL7VTEeBHEhq8QsH6k8LX4X3QKIUOkDNqvvfdlGdedbxRVk27BIgk)IfRybklgzWPoqzNyyHnYywGyxsCvm3oamI9RkInHyilSXVy07QhagXgeXaBGoamInVyP6C0jHMVOluLTywWxhfSdXbLSfZck65dvaPht5do1bk7uzqO8bN6aLD9uRfQQQykdCw4exfdlSrgZcu2kg1MJQ9IHzuZILI1GjTyjXIhIXagI5QyiluSaLf7do1bQyvxbVyxsGpAhdf7JrRfdYpn3cXM4IUyulJtRIytiwlbIrWIfOzi2pE0AUluLTywWxhfS3sTUKTywqrpFOci9ykFWPoqln3RYGqrDcNKqZD8Nl0WzHtCTa3iJzbcvvvmf6ZoXIvmhJmawmFOmqSyfd)zX(GtDGkw1vWl2cfJaF0og(cvzlMf81rb7Qt4KeAwfq6Xu(GtDGwcui)OR2PI6uJZuUtX1fPMbrx9GzHDgKeA2vLUtr1fPMbr3l)GHLfP8OPB99DgKeA2vLUtr1fPMbr)rt36RGSn8VZGKqZUQ0DkUUi1mi6PoBWjU2zqsOzxv6ofv3DkUkD5tZADjsigo((JIdNkmO8Xc9uLc1VqOQQIv9f8JJHIH)daJyPyKbN6avSQRaX8HYaXGC2qhagXcuwmgWqmxflqH8JUANqv2IzbFDuWEl16s2Izbf98HkG0JP8bN6aT0CVkdcfgWqmx7ogzAtClf1jCscn3)GtDGwcui)OR2juvvXUHbmpQyziMxQCveJ61jMVjqx8qmfqk2cfZ3eOIrUkqSgCcXiWrqurmfxNy(Mavmfqk2LlE8JJf7do1b6fulvmFtGkMcifl1)kgYaMhvSmeJ61jwIjhWhIrDXIeIHJxSlx84hhl2hCQd0leQYwml4RJc2BPwxYwmlOONpubKEmfKbmpQkdcf1jCscn3zeeUfJAU0wpITqVdiEvP0OlEPYlpndC1Q1wpITqVdi(UJrM2e3srPA1qgmOrbYE5a(BPOKF1jCscn3zeeUfJAU0wpITqVdiEvPCZA1iWrq6)vpIv)LfP44mqljESn4eDCA)Qt4KeAUZiiClg1CPTEeBHEhq8QsH61Q90SwxIeIHJV)O4WPcdkFSqpvPqD)Qt4KeAUZiiClg1CPTEeBHEhq8QsH6cvvvmf6ZILIrGpAhdfZhkdedYzdDayelqzXyadXCvSafYp6QDcvzlMf81rb7TuRlzlMfu0ZhQaspMcb(ODQmiuyadXCT7yKPnXTuuNWjj0C)do1bAjqH8JUANqvvfJAV(4peJgolCIRInaXsTwSfrSaLfdlPmuBXi4wI)SytiwlXF(flftzV6kqOkBXSGVokypHTeWLyHqgeQmiuyadXCT7yKPnHQuusX1XagI5AhYyyGqv2IzbFDuWEcBjGl046NfQYwml4RJc21dg04lulWDy8yqiuLTywWxhfStKyklsjGtRYlujuv1QkgwXhTJHVqv2IzbFNaF0okp6OwLbHc2IuZGOdgmOXhPUcd7mij0SZpehWiled3JbCTeRYNwHqNo2)tZADjsigo((JIdNkmO8Xc9UvXcvzlMf8Dc8r7QJc2FuC4uHbLpwONkdcLNM16sKqmC8Qs5o)xIT2QMbji6aUbx9cD1Q12v7wFG(ZqygSRqSaU80tfU7LkV0qtig(v4gAcXWFbbMTywqQvLII63P4A1EAwRlrcXWX3FuC4uHbLpwONQu)c)xsGJG0PziYcZGDf18a((hzRYTuOETApnR1LiHy447pkoCQWGYhl0tvQFHqv2IzbFNaF0U6OG9NHWmyxHybC5PNkSkdcfcCeKondrwygSROMhW3)iBvULYD(VSTR2T(a9NHWmyxHybC5PNkC3lvEPHMqm8RWn0eIH)ccmBXSGuFlff1VtX1Q9lUMyaUUMtxH4AHvE6rR5odscn78JncCeKUMtxH4AHvE6rR5ooDTA)IRjgGRxHvpGVSl1sy9aW0zqsOzNFS5ycCeKEfw9a(IpygODC6leQYwml47e4J2vhfSJrVRhHoDSqvvfdRzRYhjHyJNh7Mmy9vXWbA(FXcuwmaR8qSQRmInVyyjW4Ln0eIHDILaNy(yX8TGQfI1sAXyadXCvmF5edaJyiluSj6cvzlMf8Dc8r7QJc2jYwLpscvgekyRTQzqcIELRWjb1QHTlvNWjj0CF(cGvEuA0LemEzdnHyyN)lJXJlXwE0OFZoTg)VvrDfxRwmECj2YJgDQ3P14)TkDHFgWqmxVTku0fcvcvvvSQVR2T(aVqvvftH(SykibnwSfbrHX0CIrWilKflqzXqg4hIrIIdNkmqmYyHEIHaxpXQFHG0TI1wp(fBaDHQSfZc(EZ9uE00T(kUe0yvWFUSiifmnhfLuzqOGncCeK(JMU1xXLGg3XP9tGJG0FuC4uHbLyHG0TDCA)e4ii9hfhovyqjwiiDBhYE5a(BPCZUIfQQQyxQqbA(FXsnKt3vXWPfJGBj(ZI5Jfl2TIyKOPB9j2nSn8)cXWFwmYREeR(fBrquymnNyemYczXcuwmKb(HyKO4WPcdeJmwONyiW1tS6xiiDRyT1JFXgqxOkBXSGV3CFDuW(F1Jy1FzrkooduvWFUSiifmnhfLuzqOqGJG0FuC4uHbLyHG0TDCA)e4ii9hfhovyqjwiiDBhYE5a(BPCZUIfQYwml47n3xhfSJOtmSwNXSavgekQt4KeAU)axPTa3eZc8JTp4uhOSR7LGqZ(V8PzTUejedhF)rXHtfgu(yHE3srj)TD1U1hO)x9iw9xwKIJZaTJt7hBrQzq0F00T(kiBd)7mij0SRwncCeK(F1Jy1Fzrkood0oo9f(BRhXwO3beVQuuSqv2IzbFV5(6OGD1jyEuvgekxcXbmYcXWDVewPSiLaLlE5hmSK)N)pa)T1Jyl07aIV7yKPnXTuusHJuZGO7yMMHLpGzWyyVodscn7QvdIdyKfIH7oodu91YJMU137VTEeBHEhq83Q0f(jWrq6)vpIv)LfP44mq740(jWrq6pA6wFfxcAChN2Vx(bdl5)5)dOazVCapff5NahbP74mq1xlpA6wFF3T(acvvvmLzxTyiluS6xiiDRy0qwHjxfiMVjqfJevbIb50DvmFOmqmWgIbXbGbGrmYBOluLTywW3BUVokyNExDbY)IdBSkilSayLhuusLbHsKAge9hfhovyqjwiiDBNbjHMD(XwKAge9hnDRVcY2W)odscn7eQQQyk0NfR(fcs3kgnKfJCvGy(qzGy(yXqt1SybklgdyiMRI5dLdugkgcC9eJEx9aWiMVjqx8qmYBqSfkg1c8pedddyyQ1x7cvzlMf89M7RJc2FuC4uHbLyHG0TQmiuEAwRlrcXWX3FuC4uHbLpwO3TuuYpdyiMRQsPkuKF1jCscn3FGR0wGBIzb(B7QDRpq)V6rS6VSifhNbAhN2FBxTB9b6pA6wFfxcACVHMqm8RkfL8Fj2G4agzHy4(sWUHbnUwnhtGJG0r0jgwRZywqhNUwTNM16sKqmC89hfhovyq5Jf6PkLlvQoQxLUeBrQzq0bdg04JuxHHDgKeA25hBrQzq0DjSs5rt36RZGKqZUlU4c)T1Jyl07aI)wk35hBe4iiDAi7XUjYywqhN2)LyRTQzqcIUAgeOxH1QHT2UA36d0r0jgwRZywqhN(cHQSfZc(EZ91rb7pdHzWUcXc4YtpvyvAxBAUejedhpfLuzqOOoHtsO5(dCL2cCtmlWp2CB0FgcZGDfIfWLNEQWf3g9yAvgag)rcXWrpgpUeBXnSQuUtj)x2wpITqVdi(UJrM2eQs5YgDbtoavv2s9lUWp2iWrq6pkoCQWGsSqq62ooT)lXgbocsNgYESBImMf0XPRv7PzTUejedhF)rXHtfgu(yHEQs9lQvdzWGgfi7Ld4VLII9)0SwxIeIHJV)O4WPcdkFSqVBVPqv2IzbFV5(6OG9NP)5vzqOOoHtsO5(dCL2cCtmlWFB9i2c9oG47ogzAtOkfL8hjedh9y84sSf3WQsrPQqOQQIPqFwmYREeR(fBbI12v7wFaXUmrcgkgYa)qmsGcUqmCGM)xmFSyjKfdZoamIfRy0lTy1Vqq6wXsGtm3kgydXqt1SyKOPB9j2nSn8VluLTywW3BUVoky)V6rS6VSifhNbQkdcf1jCscn3FGR0wGBIzb(VeBrQzq0FuC4uHbLyHG0TDgKeA2vRwKAge9hnDRVcY2W)odscn7Qv7PzTUejedhF)rXHtfgu(yHEQs5UA1A7QDRpq)rXHtfguIfcs32HSxoGx17UW)LyRTQzqcIUAgeOxH1Q12v7wFGoIoXWADgZc6q2lhWRQskQwT2UA36d0r0jgwRZywqhN2FB9i2c9oG4vLIIVqOQQIDJrelDUxSeYIHtRIypyOzXcuwSfWI5BcuX0Rp(dXQVEf0ftH(Sy(qzGyURdaJyi5hmuSanbIvDLrmhJmTjeBHIb2qSp4uhOStmFtGU4Hyj4Qyvxz6cvzlMf89M7RJc29syf2vqwyXXzGQIEaCP5OOuxXQ0U20CjsigoEkkPYGqbMJRWQzq0tN7740(Vmsigo6X4XLylUHVTTEeBHEhq8DhJmTjQvdBFWPoqzxp1A)T1Jyl07aIV7yKPnHQuA0fVu5LNMbUleQQQy3yeXaRyPZ9I5B0AXCdlMVjqhGybklgGvEi2nv0RIy4plMYcrbITaXi2)fZ3eOlEiwcUkw1vMUqv2IzbFV5(6OGDVewHDfKfwCCgOQmiuG54kSAge905((au9MksHH54kSAge905(UdhMXSa)T1Jyl07aIV7yKPnHQuA0fVu5LNMboHQSfZc(EZ91rb7pA6wFfcD64xLbHI6eojHM7pWvAlWnXSa)T1Jyl07aIV7yKPnHQuUZ)Le4ii9)QhXQ)YIuCCgODC6A1i2)9JmyqJcK9Yb83s5ofvRg2iWrq6pA6wFfcD64VJt7)5OqSa8VhddVtHuUJUDHqv2IzbFV5(6OGDUHUdatbY0WXlbovgeky7do1bk76Pw7xDcNKqZ9h4kTf4MywG)26rSf6DaX3DmY0Mqvk35)s1jCscn3XFUqdNfoX1cCJmMfuR2tZADjsigo((JIdNkmO8Xc9ULc1RvdIdyKfIH7q(xCGBayknDcN46fcvvvmQXeOIrEdQi2GigydXsnKt3vXClGvrm8NfR(fcs3kMVjqfJCvGy40DHQSfZc(EZ91rb7pkoCQWGsSqq6wvgekxgPMbr)rt36RGSn8VZGKqZUA1EAwRlrcXWX3FuC4uHbLpwONQuU7c)Qt4KeAU)axPTa3eZc8tGJG0)REeR(llsXXzG2XP93wpITqVdi(BPCN)lXgbocsNgYESBImMf0XPRv7PzTUejedhF)rXHtfgu(yHEQs9leQYwml47n3xhfS)OPB9vCjOXQmiuWgbocs)rt36R4sqJ740(rgmOrbYE5a(BPOqQlsndI(Jtemebhd3zqsOzNqv2IzbFV5(6OGDen)OnyIeQmiuU8xCnXaCDA8pW1CHH40XSGA1(fxtmaxx9QZy0C5xTAgex4NbmeZ1UJrM2eQs5MkYp2(GtDGYUEQ1(jWrq6)vpIv)LfP44mq7U1hqLbemeIthLXZJDtgmfLuzabdH40rbJEjsnfLuzabdH40rzqO8lUMyaUU6vNXO5YVA1mieQYwml47n3xhfStVXSavgeke4iiDc9Uon(hDiNTOwnKbdAuGSxoG)2BQOA1iWrq6)vpIv)LfP44mq740(VKahbP)OPB9vi0PJ)ooDTATD1U1hO)OPB9vi0PJ)oK9Yb83srjfDHqv2IzbFV5(6OGDc9UUcco8QkdcfcCeK(F1Jy1Fzrkood0ooTqv2IzbFV5(6OGDcg(mSYaWOYGqHahbP)x9iw9xwKIJZaTJtluLTywW3BUVokyhzGmHExNkdcfcCeK(F1Jy1Fzrkood0ooTqv2IzbFV5(6OG9e04pGPU0sTwLbHcbocs)V6rS6VSifhNbAhNwOkBXSGV3CFDuWo(ZLjypvaPhtPLnuUSiLSHfHpq2vciNpoKFvgeke4ii9SHfHpq2vsLZDCA)x(0SwxIeIHJV)O4WPcdkFSqpkk5hMJRWQzq0tN77dq1Qqr1Q90SwxIeIHJV)O4WPcdkFSqpvv6IA1i2)9JmyqJcK9Yb83ENIfQQQykGrsCDigsQ1ezRIyilum8pj0SytWEp1umf6ZI5BcuXiV6rS6xSfrmfWzG2fQYwml47n3xhfSJ)Czc27vzqOqGJG0)REeR(llsXXzG2XPRvdzWGgfi7Ld4V9ofjujuv1Qk2nmG5rz4luvvXOgOJMfd)hagXugi7XUjYywGkILQ3Xjwl)yayeJupnwSe4etbtJfZhkdeJenDRpXuqcASyZl2VlqSyfJGfd)zNkIXkVX0HyiluSQmxHtceQYwml47idyEukQt4KeAwfq6XuOHSh7kpWvAlWnXSavuNACMsKAgeDAi7XUjYywqNbjHMD(FAwRlrcXWX3FuC4uHbLpwO3TxQyfUTQzqcIoGBWvVq3f(XwBvZGee9kxHtceQYwml47idyE06OG9xpnUKaxXnnwLbHc2uNWjj0CNgYESR8axPTa3eZc8)0SwxIeIHJV)O4WPcdkFSqVBRc)yJahbP)OPB9vCjOXDCA)e4ii9xpnUKaxXnnUdzVCa)Tidg0OazVCaVFiJa5hnj0Sqv2IzbFhzaZJwhfS)6PXLe4kUPXQmiuuNWjj0CNgYESR8axPTa3eZc832v7wFG(JMU1xXLGg3BOjed)fey2IzbP(wL63if7NahbP)6PXLe4kUPXDi7Ld4VTTR2T(a9)QhXQ)YIuCCgODi7Ld49FzBxTB9b6pA6wFfxcAChYP7QFcCeK(F1Jy1Fzrkood0oK9Yb8kmbocs)rt36R4sqJ7q2lhWFRs97UqOQQIvLL10mumQ1eojHMfdzHIHfWPdCi3fJSYqlMdhoamIPSYpyOyyP)Z)hGylumhoCayetbjOXI5BcuXuqcRiwcCIbwXUFWGgFK6kmSluLTywW3rgW8O1rb7Qt4KeAwfq6Xu(kdDbIth4qwf1PgNP4LFWWs(F()akq2lhWRQIQvdBrQzq0bdg04JuxHHDgKeA25psndIUlHvkpA6wFDgKeA25NahbP)OPB9vCjOXDC6A1EAwRlrcXWX3FuC4uHbLpwONQuUK6k8hCQdu21tTUkfPMbr)rt36RGSn8VZGKqZUleQQQyvzyMwmCAXWc40boKfBqeBcXMxSKyXdXIvmioqSfp6cvzlMf8DKbmpADuWoeNoWHSkdcfS9bN6aLD9uR9Fj2uNWjj0C)Rm0fioDGd5A1uNWjj0Ch)5cnCw4exlWnYywWf(JeIHJEmECj2IByfgYE5aEvRc)qgbYpAsOzHQSfZc(oYaMhToky)5gKJsWnuWGfHZcvvvmLfUog3gXaWiwKqmC8IfOziMVrRftpQzXqwOybklMdhMXSaXweXWc40boKvrmiJa5hvmhoCayeJobo2BADHQSfZc(oYaMhTokyhIth4qwL21MMlrcXWXtrjvgekytDcNKqZ9VYqxG40boK9Jn1jCscn3XFUqdNfoX1cCJmMf4)PzTUejedhF)rXHtfgu(yHEQs5o)rcXWrpgpUeBXnSQuUuX1D5DvP26rSf6DaXFXf(HmcKF0KqZcvvvmSaJa5hvmSaoDGdzX4eQVk2Gi2eI5B0AXyLtpqwmhoCayeJ8QhXQ)UykyflqZqmiJa5hvSbrmYvbIHHJxmiNURInaXcuwmaR8qmf)DHQSfZc(oYaMhTokyhIth4qwLbHc2uNWjj0C)Rm0fioDGdz)q2lhWFBBxTB9b6)vpIv)LfP44mq7q2lhWxNskYFBxTB9b6)vpIv)LfP44mq7q2lhWFlff7psigo6X4XLylUHvyi7Ld4vTTR2T(a9)QhXQ)YIuCCgODi7Ld4RtXcvzlMf8DKbmpADuWoHoBvk0RphdvzqOGn1jCscn3XFUqdNfoX1cCJmMf4)PzTUejedhVQuUPqv2IzbFhzaZJwhfSZQNVXWmyHkHQQwvXido1bQyvFxTB9bEHQQkwvwwtZqXOwt4KeAwOkBXSGV)bN6aT0Cpf1jCscnRci9ykpQReOq(rxTtf1PgNP02v7wFG(JMU1xXLGg3BOjed)fey2IzbPwvkk1VrkwOQQIrTMG5rfBqeZhlwczXAjn9aWi2cetbjOXI1qtig(7IPSjH6RIrWilKfdzGFiMlbnwSbrmFSyOPAwmWk29dg04JuxHHIrGhIPGewrms00T(eBaITqhdflwXWWHyybC6ahYIHtl2LGvmLv(bdfdl9F()aUOluLTywW3)GtDGwAUVokyxDcMhvLbHYLytDcNKqZ9h1vcui)OR2vRg2IuZGOdgmOXhPUcd7mij0SZFKAgeDxcRuE00T(6mij0S7c)T1Jyl07aIV7yKPnHQk5hBqCaJSqmC3lHvklsjq5Ix(bdl5)5)dqOQQIPm7QfdzHIrIMU1NhRDIvNyKOPB99bCQWIHd08)I5JflHSyjXIhIfRyTKwSfiMcsqJfRHMqm83fRkhOVkMpugi2nmaNyudoRa4)fBEXsIfpelwXG4aXw8OluLTywW3)GtDGwAUVokyNExDbY)IdBSkilSayLhuusfw5bmlP3IdckuxrQmiuGzJ7GbdAuynIqv2IzbF)do1bAP5(6OG9hnDRppw7uzqOWagI5QQuOUI8ZagI5A3XitBcvPOKI8Jn1jCscn3FuxjqH8JUAN)26rSf6DaX3DmY0MqvLeQQQyvxzelqH8JUA3lgYcfJbbdhagXirt36tmfKGgluLTywW3)GtDGwAUVokyxDcNKqZQaspMYJ6kT1Jyl07aIxf1PgNP0wpITqVdi(UJrM2eQs5U6iWrq6pA6wFfcD64VJtluLTywW3)GtDGwAUVokyxDcNKqZQaspMYJ6kT1Jyl07aIxf1PgNP0wpITqVdi(UJrM2eQs5MQmiuARAgKGOx5kCsGqv2IzbF)do1bAP5(6OGD1jCscnRci9ykpQR0wpITqVdiEvuNACMsB9i2c9oG47ogzAtClfLuzqOOoHtsO5o(ZfA4SWjUwGBKXSa)pnR1LiHy447pkoCQWGYhl0tvkuxOQQIPGe0yXC4WbGrmYREeR(fBHILeRAwSafYp6QDDHQSfZc((hCQd0sZ91rb7pA6wFfxcASkdcLlVuDcNKqZ9h1vARhXwO3beFTAQt4KeAU)OUsGc5hD1Ul8)Cuiwa(3JHH3Pqk3r383w1mibrVYv4KGA1uNWjj0C)rDL26rSf6DaX7)scCeK(F1Jy1Fzrkood0oK9Yb8QsrP(D1QPoHtsO5(J6kbkKF0v7UOwncCeKEdn3VqKaUJtxR2tZADjsigo((JIdNkmO8Xc9uLc1932v7wFG(F1Jy1Fzrkood0oK9Yb8QQKIUW)Le4iiDAgISWmyxrnpGV)r2QCl1Rv7PzTUejedhF)rXHtfgu(yHEQEZleQQQyyfhcetbjOXVyn0eIHFXgeXUU4IrRZRIPGewrms00T(ESJL0zdoXvXwOyemYczXcuwmKbdAigdCVydIyKRceZ3cQwigblgKt3vXgGyX4XDHQSfZc((hCQd0sZ91rb7pA6wFfxcASkdcf1jCscn3FuxPTEeBHEhq8(rgmOrbYE5a(BB7QDRpq)V6rS6VSifhNbAhYE5a(A1WwKAgeDgOM1l9aWuE00T((odscn7eQeQQAvfJm4uhOStmSWgzmlqOQQIDJreJm4uhOyxDcMhvSeYIHtRIy4plgjA6wFFaNkSyXkgbdyKjedbUEIfOSy05)JAwmIfG)ILaNy3WaCIrn4ScG)xfXy1mqSbrmFSyjKfldX8sLlw1vgXUehO5)fd)hagXuw5hmumS0)5)d4cHQSfZc((hCQdu2r5rt367d4uHvzqOCjbocs)do1bAhNUwncCeKU6empAhN(c)x(0SwxIeIHJV)O4WPcdkFSqVBPETAQt4KeAUJ)CHgolCIRf4gzml4c)E5hmSK)N)pGcK9Yb8uuKqvvf7ggW8OILHy3SoXQUYiMVjqx8qmfqkg2fJ61jMVjqftbKI5BcuXirXHtfgiw9leKUvmcCeeXWPflwXs174e7xpwSQRmI5l)Gf7NapJzbFxOQQIHL0)k2NiSyXkgYaMhvSmeJ61jw1vgX8nbQySYZwOVkg1flsigo(UyxsMESy5l2Ih)4yX(GtDG2VqOQQIDddyEuXYqmQxNyvxzeZ3eOlEiMcivrmfxNy(MavmfqQIyjWjwviMVjqftbKILibdfJAnbZJkuLTywW3)GtDGYU6OG9wQ1LSfZck65dvaPhtbzaZJQYGqrDcNKqZDgbHBXOMlT1Jyl07aIxvkn6IxQ8YtZaxTAe4ii9hfhovyqjwiiDBhN2FB9i2c9oG47ogzAtClL7Qv7PzTUejedhF)rXHtfgu(yHEQsH6(vNWjj0CNrq4wmQ5sB9i2c9oG4vLc1RvRTEeBHEhq8DhJmTjULIsk8LrQzq0DmtZWYhWmsmSxNbjHMD(jWrq6QtW8ODC6leQYwml47FWPoqzxDuW(JMU13hWPcRYGq5do1bk76pt)Z7)PzTUejedhF)rXHtfgu(yHE3sDHQQkgwZwLpscXC4WbGrms00T(etbjOXI5dLbITaXqhmOIPmuRI9r2Q8ILaNyKOPB9jgw1PJFXMxmC6Uqv2IzbF)do1bk7QJc2jYwLpscvgeke4iiDAgISWmyxrnpGV)r2QOkff7NahbP)OPB9vCjOXDi7Ld4vLYn9tGJG0F00T(ke60XFhN2)tZADjsigo((JIdNkmO8Xc9ULYnfQYwml47FWPoqzxDuW(JoQvzqOePMbrhmyqJpsDfg2zqsOzNFioGrwigUhd4AjwLpTcHoDS)NM16sKqmC89hfhovyq5Jf6DRIfQQQykuAXIvSBkwKqmC8IDjyfJgo7fIvHzAXWPf7ggGtmQbNva8)IrCvS21MEayeJenDRVpGtfUluLTywW3)GtDGYU6OG9hnDRVpGtfwL21MMlrcXWXtrjvgekytDcNKqZD8Nl0WzHtCTa3iJzb(DmbocshzaUIpoRa4)7q2lhWFRs(FAwRlrcXWX3FuC4uHbLpwO3TuUP)iHy4OhJhxIT4gwHHSxoGx1QqOQQIDdlumA4SWjUkgCJmMfOIy4plgjA6wFFaNkSyRAgkgzSqpX8nbQyudLLyjMCaFigoTyXkg1flsigoEXwOydIy3a1qS5fdIdadaJylcIyxUaXsWvXsVfheITiIfjedh)fcvzlMf89p4uhOSRoky)rt367d4uHvzqOOoHtsO5o(ZfA4SWjUwGBKXSa)x6ycCeKoYaCfFCwbW)3HSxoG)wLQvlsndIUpoPxGx(bd7mij0SZ)tZADjsigo((JIdNkmO8Xc9ULc1VqOkBXSGV)bN6aLD1rb7pkoCQWGYhl0tLbHYtZADjsigoEvPCZ6UKahbPhOCbUrWGooDTAqCaJSqmCpRKjC(YV46ccmX4XGOwTNJcXcW)Emm8ofs5o62f(VKahbP)x9iw9xwKIJZaTK4X2Gt0XPRvdBe4iiDAi7XUjYywqhNUwTNM16sKqmC8QsrXxiuvvXirt367d4uHflwXGmcKFuXUHb4eJAWzfa)VyjWjwSIXGhhYI5JfRLaXAjeEvSvndflfdbxRf7gOgInGyflqzXaSYdXixfi2Gig9()qO5Uqv2IzbF)do1bk7QJc2F00T((aovyvgekoMahbPJmaxXhNva8)Di7Ld4VLIs1Q12v7wFG(F1Jy1Fzrkood0oK9Yb83QKcXVJjWrq6idWv8Xzfa)FhYE5a(BB7QDRpq)V6rS6VSifhNbAhYE5aEHQSfZc((hCQdu2vhfSJrVRhHoDSkdcfcCeKondrwygSROMhW3)iBvuLII93wGdFIondrwygSROMhW3HjOIQuu6McvzlMf89p4uhOSRoky)rt367d4uHfQYwml47FWPoqzxDuWEdLt6YJUHkdcfSfjedh95le7)(BRhXwO3beF3XitBcvPOKFcCeK(JUrzaLaLlUewPJt7NbmeZ1EmECj2c1vKQyAUUxQ8tCIZba]] )

    
end
