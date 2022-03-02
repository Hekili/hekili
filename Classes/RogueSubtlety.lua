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


    spec:RegisterPack( "Subtlety", 20220302, [[di13qcqiivEKKeBIQQpjjLrjPQtPsYQKKK8kvknlsKBrcYUu0VGu1WOQKJrcTmvQ6zQKY0ibUgvLABKOQVPsQyCiPOZPsQuRdjfEhKcknpvkUhsSpQk(NKKihesHwiKspusQMisQUiskv2OKK6JsscJejLQojKcSsKKxkjjQzIKsUjjQyNQu5NQKkzOKGAPQKQEkIMQKkxLevARiPu(kKIASqkYzHuq1EvXFLyWuoSOfdvpwHjtQlJAZq8ziz0q50sTAifKxljMnvUnvz3a)wPHJuhxssQLd65QA6cxhHTts9DsY4jr58QeRhsbfZxsz)eFu8u3HuNbFU7EFD)9(6A(6(PIuZRP83FTdzCHMpK05OsIIpKG0JpKKe4HJJlhs68IBt9PUd5VeWbFiXIG(PgOh9O6aJaFowp0)ThHlJEbdyIeO)BVb6pK4eTlqdah8dPod(C39(6(7911819tfPMxt5V)(dzseyl8qs2Ev)qI1Ando4hsn)JdjjbE444Iyx)IIGfQuojCGj29kj29(6(7fQeQQowcqXp1qOsHet5SQzXuNWoXD8K45cnSxyhxkWnYOxGye0I9RyDiw)I9CigoJSqwmvSyeplwhtHkfsSQVE4nGfZJWfnTJfBKoxjhrVGIR)qmgeWMFXIvmiRjgSy0BWGOtNyqw1cRmfQuiXuozfwSQ2Xp2aMiHyniyiKGoeRbInwp8meRretflgAiIpet3AX6qmKfkM61Lr74YVo1miMhsx)XFQ7q(bNUaJ1N6o3P4PUdjdsChRpO9qMJOxWH8Xs9Q6dyxHpKA(hWMo6fCirdqeJm40fyOxDc6htSeYIrqRKyeplgjwQxvFa7kSyXkgodyKoedbUEIfySy05)TAwm8fq8ILaTyvDd0IHM5ScG)xjXy1mqSgrmvSyjKfldX8sLjw1vyXQNa44)fJ4BakXuo5hmum04)5)n4Qd5a2bd78qwVy4eiiZp40fytcAXQvtmCceKP6e0p2KGwSReZVy1l2tZoxjsiko(5Jra7kmO8Xc9e7gXuGy1QjM6e2jUJNepxOH9c74sbUrg9ce7kX8lMx(bdl5)5)nOazVSbVyueZxN4C39N6oKmiXDS(G2dPM)bSPJEbhYQUb9JjwgIPGBfR6kSyQ6aBjcXOoPsI57BftvhyIrDsLelbAXuEXu1bMyuNuSejyOyuBjOFSdzoIEbhYr6CLCe9ckU(Jd5a2bd78qQoHDI74jJGWJOvZLX6HVf6TbXlMpueBqx8sLvEAgOfRwnXWjqqMpgbSRWGsSqqQ3jbTy(fBSE4BHEBq8tnJ0Joe7gkIDVy1Qj2tZoxjsiko(5Jra7kmO8Xc9eZhkIPaX8lM6e2jUJNmccpIwnxgRh(wO3geVy(qrmfiwTAInwp8TqVni(PMr6rhIDdfXuumfsS6flshdIPMzAgw(aMrII9MmiXDSwm)IHtGGmvNG(XMe0ID1H01FuaPhFirAq)yN4C31o1DizqI7y9bThYbSdg25H8doDbgRNpt)9lMFXEA25krcrXXpFmcyxHbLpwONy3iMcoK5i6fCiFSuVQ(a2v4tCUtbN6oKmiXDS(G2dzoIEbhs8Cu5Je)qQ5FaB6OxWHeT5OYhjUyAcydqjgjwQxvIr9emyXuHXaXwGyynkmXuyQnX(ihvEXsGwmsSuVQedTUuZVy9lgb98qoGDWWopK4eiitAgISWmyDrn3GF(roQiMpueZ3I5xmCceK5JL6vvrNGbpHSx2GxmFOi21eZVy4eiiZhl1RQcUl18pjOfZVypn7CLiHO44NpgbSRWGYhl0tSBOi21oX5oFFQ7qYGe3X6dApKdyhmSZdzKogetqJcl(iDvy4KbjUJ1I5xmibGrwikEgn4sjwL1JcUl18KbjUJ1I5xSNMDUsKquC8ZhJa2vyq5Jf6j2nI57dzoIEbhYhRvFIZDk)PUdjdsChRpO9qMJOxWH8Xs9Q6dyxHpKJldhxIeIIJ)CNIhYbSdg25HeDIPoHDI74jXZfAyVWoUuGBKrVaX8lMMXjqqMinqxuXzfa))eYEzdEXUrmffZVypn7CLiHO44NpgbSRWGYhl0tSBOi21eZVyrcrXXmApUeBr3SykKyq2lBWlMpIP8hsn)dyth9coKkxAXIvSRjwKquC8IvpyfJg27vIvHzAXiOfRQBGwm0mNva8)IHFrSXLHRbOeJel1RQpGDfEEIZDxNtDhsgK4owFq7HmhrVGd5JL6v1hWUcFi18pGnD0l4qw1lumAyVWoUigCJm6fOKyeplgjwQxvFa7kSyRAgkgzSqpXu1bMyOzLJyjQSbFigbTyXkMcelsikoEXwOynIyvnAwS(fdsaanaLylcIy1VaXsWfXsVLaeITiIfjefh)vhYbSdg25HuDc7e3XtINl0WEHDCPa3iJEbI5xS6ftZ4eiitKgOlQ4ScG)FczVSbVy3iMIIvRMyr6yqmvXj9c8Ypy4KbjUJ1I5xSNMDUsKquC8ZhJa2vyq5Jf6j2nuetbID1jo3rnp1DizqI7y9bThYbSdg25H8PzNRejefhVy(qrSRj2TIvVy4eiiZaJlWncgmjOfRwnXGeagzHO4zwjty)LFjCfeyIYJbXKbjUJ1IvRMyphf8fq8ZOz49uZY90dXUsm)IvVy4eiiZ)Ih(6(YIu0CgyLKi2bSJjbTy1Qjg6edNabzsdzpw3rg9cMe0IvRMypn7CLiHO44fZhkI5BXU6qMJOxWH8XiGDfgu(yHEN4C319PUdjdsChRpO9qMJOxWH8Xs9Q6dyxHpKA(hWMo6fCijXs9Q6dyxHflwXGmcKFmXQ6gOfdnZzfa)VyjqlwSIXGNaYIPIfBKaXgjeErSvndflfdHW5eRQrZI1GyflWyXaSYcXixQlwJig9(FJ745HCa7GHDEi1mobcYePb6IkoRa4)Nq2lBWl2nuetrXQvtSXUo9Qcm)lE4R7llsrZzGnHSx2GxSBetrQPy(ftZ4eiitKgOlQ4ScG)FczVSbVy3i2yxNEvbM)fp819LfPO5mWMq2lBWFIZDk6RtDhsgK4owFq7HCa7GHDEiXjqqM0mezHzW6IAUb)8JCurmFOiMVfZVyJfOj6ysZqKfMbRlQ5g8tycQiMpuetXRDiZr0l4qIYTRhUl18jo3POIN6oK5i6fCiFSuVQ(a2v4djdsChRpO9eN7u8(tDhsgK4owFq7HCa7GHDEirNyrcrXXS)c((Vy(fBSE4BHEBq8tnJ0JoeZhkIPOy(fdNabz(yBuAqjW4IoHvMe0I5xmgWquxMr7XLylkWxI5JyOg6PxQSdzoIEbhYbgN0LhBJtCIdPMrscxCQ7CNIN6oK5i6fCiR0JkhsgK4owFq7jo3D)PUdjdsChRpO9qU0hYNJdzoIEbhs1jStChFivNoc(qItGGmFxp4sc0fDp4jbTy1Qj2tZoxjsiko(5Jra7kmO8Xc9eZhkIP8hsn)dyth9coKk3N1IfRyAoyOxdyXuHXbgdfBSRtVQaVyQYoedzHIrcOUy45ZAXwGyrcrXXppKQtybKE8H8b6Yyb6o6fCIZDx7u3HKbjUJ1h0Eix6d5ZXHmhrVGdP6e2jUJpKQthbFiXjqqMVRhCjb6IUh8KGwSA1e7PzNRejefh)8XiGDfgu(yHEI5dfXu(dP6ewaPhFiFGUmwGUJEbN4CNco1DizqI7y9bThYL(q(CCiZr0l4qQoHDI74dP6ewaPhFi7VayLfLbDjbTxoWsikwFihWoyyNhYXQMbjiMvUa7eCi18pGnD0l4qwDmEurSyf7zwSgrSaJfdWkleR6kSy13aXcmwmwndcXweXsXiXQtmA4oUsS(fdncAVCGLquS(qQoDe8HCSE4BHEBq8IrrmffZVy4eiitEGTnavbY0W2lb6Y9tcAXQvtSX6HVf6TbXlgfXUxm)IHtGGm5b22aufitdBVeOlxBsqlwTAInwp8TqVniEXOi21eZVy4eiitEGTnavbY0W2lb6IcMe0IvRMyJ1dFl0BdIxmkIPaX8lgobcYKhyBdqvGmnS9sGU47jb9jo357tDhsgK4owFq7HCPpKphhYCe9coKQtyN4o(qQoDe8HKrq4r0Q5Yy9W3c92G4pKA(hWMo6fCirJJXsacXqwOyKy1jgKZr0lqSO9yXWViwJcSWgGsm3QsHQUclwcAVCGLquSwmVmgy8lwdelWyX8103Vy0qEWSUbOelfJEdgeD6eJeRoXOH74qQoHfq6XhsgbHhrRMlJ1dFl0BdI)eN7u(tDhsgK4owFq7HCPpKphhYCe9coKQtyN4o(qQoDe8HCSE4BHEBq8hYbSdg25HCSQzqcIzLlWobI5xmgbHhrRMlJ1dFl0BdIxmFeBSE4BHEBq8I5xSX6HVf6TbXp1msp6qmFe7EX8lw0ECj2YJffAhXpvGy3iMVM(wm)IHoXuNWoXD8S)cGvwug0Le0E5alHOy9HuDclG0JpKmccpIwnxgRh(wO3ge)jo3DDo1DizqI7y9bThsn)dyth9coKvhJhveR6u)fldXqA4hhYCe9coKJ05k5i6fuC9hhsx)rbKE8HCO)tCUJAEQ7qYGe3X6dApK5i6fCiFxp4sc0fDp4dPM)bSPJEbhs0inT7IyKUEWILaTyuVhSyzi293kw1vyX0eWgGsSaJfdPHFiMI(sSNhlq)kjwIemuSaldXuWTIvDfwSgrSoeJvgDd5xmvDG1aXcmwmaRSqSQIQtDXwOy9lgydXiOpKdyhmSZd5tZoxjsiko(5Jra7kmO8Xc9e7gXuEX8lgsJclkq2lBWlMpIP8I5xmCceK576bxsGUO7bpHSx2GxSBed1qp9sLjMFXgRh(wO3geVy(qrmfiMcjw9IfThl2nIPOVe7kXQQe7(tCU76(u3HKbjUJ1h0Eix6d5ZXHmhrVGdP6e2jUJpKQthbFiPH9c74sbUrg9ceZVypn7CLiHO44NpgbSRWGYhl0tmFOi29hsn)dyth9coKxxa3fXgyjaflgCJm6fiwJiMkwmSunlgnSxyhxkWnYOxGyphILaTyEeUOPDSyrcrXXlgb98qQoHfq6XhsINl0WEHDCPa3iJEbN4CNI(6u3HKbjUJ1h0Ei18pGnD0l4qE9eaXqiCUlI9Q6yGXVyXkwGXIrgC6cmwl21Vrg9ceRE8lIP3gGsSFvsSoedzHd(fJExxdqjwJigydSgGsS(flvNTlXD8vZdzoIEbhsibOKJOxqX1FCi)a2J4CNIhYbSdg25H8doDbgRNPZDiD9hfq6XhYp40fyS(eN7uuXtDhsgK4owFq7HuZ)a20rVGdPcd7f2XfXU(nYOxqvjXOwCuTxmuTAwSuSbmPflXxIqmgWquxedzHIfySyFWPlWeR6u)fRECI2PzOyF0oNyq(P5riwhxnfdnCcALeRdXgjqmCwSaldX(2J2XZdzoIEbhYr6CLCe9ckU(Jd5hWEeN7u8qoGDWWopKQtyN4oEs8CHg2lSJlf4gz0l4q66pkG0JpKFWPlWkd9FIZDkE)PUdjdsChRpO9qQ5FaB6OxWHS6l4BndfJ4BakXsXidoDbMyvN6IPcJbIb5CG1auIfySymGHOUiwGb5hBD6dzoIEbhYr6CLCe9ckU(Jd5a2bd78qYagI6YuZi9OdXUHIyQtyN4oE(bNUaReyq(XwN(q66pkG0JpKFWPlWkd9FIZDkETtDhsgK4owFq7HuZ)a20rVGdzv3G(XeldX8sLPKyk4wXu1b2seIrDsXwOyQ6atmYL6InGDigobcIsI57BftvhyIrDsXQFjIV1SyFWPlWUsjXu1bMyuNuS09RyinOFmXYqmfCRyjQSbFiMcelsikoEXQFjIV1SyFWPlWU6qMJOxWHCKoxjhrVGIR)4qoGDWWopKQtyN4oEYii8iA1CzSE4BHEBq8I5dfXg0fVuzLNMbAXQvtSX6HVf6TbXp1msp6qSBOiMIIvRMyinkSOazVSbVy3qrmffZVyQtyN4oEYii8iA1CzSE4BHEBq8I5dfXUMy1QjgobcY8V4HVUVSifnNbwjjIDa7ysqlMFXuNWoXD8Krq4r0Q5Yy9W3c92G4fZhkIPaXQvtSNMDUsKquC8ZhJa2vyq5Jf6jMpuetbI5xm1jStChpzeeEeTAUmwp8TqVniEX8HIyk4q66pkG0JpKinOFStCUtrfCQ7qYGe3X6dApKA(hWMo6fCivUplwkgor70mumvymqmiNdSgGsSaJfJbme1fXcmi)yRtFiZr0l4qosNRKJOxqX1FCihWoyyNhsgWquxMAgPhDi2nuetDc7e3XZp40fyLadYp260hsx)rbKE8HeNOD6tCUtrFFQ7qYGe3X6dApK5i6fCit4ibCjwiKbXHuZ)a20rVGdj1AvXFignSxyhxeRbILoNylIybglgAuHPwIHZJK4zX6qSrs88lwkwvr1P(HCa7GHDEizadrDzQzKE0Hy(qrmf9Ty3kgdyiQltiJIbN4CNIk)PUdzoIEbhYeosaxOjCpFizqI7y9bTN4CNIxNtDhYCe9coKUgfw8f0qeAuEmioKmiXDS(G2tCUtrQ5PUdzoIEbhs8evzrkbShv(djdsChRpO9eN4qsd5X6HNXPUZDkEQ7qMJOxWHmPPDxk0B)l4qYGe3X6dApX5U7p1DiZr0l4qIVr4yDbXLxyTQgGQeRYAWHKbjUJ1h0EIZDx7u3HKbjUJ1h0EihWoyyNhYFjC4nqpPj(GWXfgsqh9cMmiXDSwSA1e7xchEd0t1RlJ2XLFDQzqmzqI7y9HmhrVGdjIJFSbmrItCUtbN6oK5i6fCi)GtxGDizqI7y9bTN4CNVp1DizqI7y9bThYCe9coKEjScRlilSO5mWoK0qESE4zuEESa9Fiv03N4CNYFQ7qYGe3X6dApK5i6fCiFxp4sc0fDp4d5a2bd78qczei)yjUJpK0qESE4zuEESa9Fiv8eN7UoN6oKmiXDS(G2d5a2bd78qcjamYcrXtVewPSiLaJlE5hmSK)N)3GjdsChRpK5i6fCiFSuVQk4UuZ)joXHePb9JDQ7CNIN6oKmiXDS(G2d5sFiFooK5i6fCivNWoXD8HuD6i4dzKogetAi7X6oYOxWKbjUJ1I5xSNMDUsKquC8ZhJa2vyq5Jf6j2nIvVy(wmfsSXQMbjiMaEax3c1IDLy(fdDInw1mibXSYfyNGdPM)bSPJEbhs0mw7yXi(gGsmfgYESUJm6fOKyP6T1InYpAakXiD9GflbAXOEpyXuHXaXiXs9QsmQNGblw)I97celwXWzXiEwRKySYgmDigYcfRQ8fyNGdP6ewaPhFiPHShRlpqxglq3rVGtCU7(tDhsgK4owFq7HCa7GHDEirNyQtyN4oEsdzpwxEGUmwGUJEbI5xSNMDUsKquC8ZhJa2vyq5Jf6j2nIP8I5xm0jgobcY8Xs9QQOtWGNe0I5xmCceK576bxsGUO7bpHSx2GxSBedPrHffi7Ln4fZVyqgbYpwI74dzoIEbhY31dUKaDr3d(eN7U2PUdjdsChRpO9qoGDWWopKQtyN4oEsdzpwxEGUmwGUJEbI5xSXUo9QcmFSuVQk6em45alHO4VGaZr0liDIDJykoVo(wm)IHtGGmFxp4sc0fDp4jK9Yg8IDJyJDD6vfy(x8Wx3xwKIMZaBczVSbVy(fREXg760RkW8Xs9QQOtWGNqo1xeZVy4eiiZ)Ih(6(YIu0Cgyti7Ln4ftHedNabz(yPEvv0jyWti7Ln4f7gXuCEVyxDiZr0l4q(UEWLeOl6EWN4CNco1DizqI7y9bThYL(q(CCiZr0l4qQoHDI74dP60rWhsV8dgwY)Z)BqbYEzdEX8rmFjwTAIHoXI0XGycAuyXhPRcdNmiXDSwm)IfPJbXuNWkLhl1RQjdsChRfZVy4eiiZhl1RQIobdEsqlwTAI90SZvIeIIJF(yeWUcdkFSqpX8HIy1lMcetHe7doDbgRNPZjwvLyr6yqmFSuVQki7G4NmiXDSwSRoKA(hWMo6fCiP2ZoAgkg1wc7e3XIHSqXUEc6GaYtXiR00IPjGnaLykN8dgkgA8)8)gi2cfttaBakXOEcgSyQ6atmQNWkILaTyGvS7AuyXhPRcdNhs1jSasp(q(vA6cKGoiG8jo357tDhsgK4owFq7HmhrVGdjKGoiG8HuZ)a20rVGdzvzMPfJGwSRNGoiGSynIyDiw)IL4lriwSIbjaITeX8qoGDWWopKOtSp40fySEMoNy(fREXqNyQtyN4oE(vA6cKGoiGSy1QjM6e2jUJNepxOH9c74sbUrg9ce7kX8lwKquCmJ2JlXw0nlMcjgK9Yg8I5JykVy(fdYiq(XsChFIZDk)PUdzoIEbhYNhqokbpWaDvnbFizqI7y9bTN4C315u3HKbjUJ1h0EiZr0l4qcjOdciFihxgoUejefh)5ofpKdyhmSZdj6etDc7e3XZVstxGe0bbKfZVyOtm1jStChpjEUqd7f2XLcCJm6fiMFXEA25krcrXXpFmcyxHbLpwONy(qrS7fZVyrcrXXmApUeBr3Sy(qrS6fZ3IDRy1l29Ivvj2y9W3c92G4f7kXUsm)Ibzei)yjUJpKA(hWMo6fCivoeUO1BenaLyrcrXXlwGLHyQANtmxRMfdzHIfySyAcyg9ceBre76jOdciRKyqgbYpMyAcydqjgDc0SxpMN4Ch18u3HKbjUJ1h0EiZr0l4qcjOdciFi18pGnD0l4qE9mcKFmXUEc6GaYIXj0DrSgrSoetv7CIXkJUHSyAcydqjg5fp819tXO(kwGLHyqgbYpMynIyKl1fdfhVyqo1xeRbIfySyawzHy((NhYbSdg25HeDIPoHDI745xPPlqc6GaYI5xmi7Ln4f7gXg760RkW8V4HVUVSifnNb2eYEzdEXUvmf9Ly(fBSRtVQaZ)Ih(6(YIu0Cgyti7Ln4f7gkI5BX8lwKquCmJ2JlXw0nlMcjgK9Yg8I5JyJDD6vfy(x8Wx3xwKIMZaBczVSbVy3kMVpX5UR7tDhsgK4owFq7HCa7GHDEirNyQtyN4oEs8CHg2lSJlf4gz0lqm)I90SZvIeIIJxmFOi21oK5i6fCiXD5OsHEvPz4jo3POVo1DiZr0l4qYQ7FWWm4djdsChRpO9eN4qo0)PUZDkEQ7qYGe3X6dApKdyhmSZdj6edNabz(yPEvv0jyWtcAX8lgobcY8XiGDfguIfcs9ojOfZVy4eiiZhJa2vyqjwii17eYEzdEXUHIyxB67djXZLfbPGAOp3P4HmhrVGd5JL6vvrNGbFi18pGnD0l4qQCFwmQNGbl2IGOqOgAXWzKfYIfySyin8dXiXiGDfgigzSqpXqGRNy1TqqQxXgRh)I1G5jo3D)PUdjdsChRpO9qoGDWWopK4eiiZhJa2vyqjwii17KGwm)IHtGGmFmcyxHbLyHGuVti7Ln4f7gkIDTPVpKepxweKcQH(CNIhYCe9coK)fp819LfPO5mWoKA(hWMo6fCiRx5cC8)ILoiN6lIrqlgopsINftflwSBfXiXs9QsSQEhe)vIr8SyKx8Wx3l2IGOqOgAXWzKfYIfySyin8dXiXiGDfgigzSqpXqGRNy1TqqQxXgRh)I1G5jo3DTtDhsgK4owFq7HCa7GHDEivNWoXD88b6Yyb6o6fiMFXqNyFWPlWy90lbHJfZVy1l2tZoxjsiko(5Jra7kmO8Xc9e7gkIPOy(fBSRtVQaZ)Ih(6(YIu0CgytcAX8lg6elshdI5JL6vvbzhe)KbjUJ1IvRMy4eiiZ)Ih(6(YIu0CgytcAXUsm)Inwp8TqVniEX8HIy((qMJOxWHeXLOyNlJEbN4CNco1DizqI7y9bThYbSdg25HSEXGeagzHO4PxcRuwKsGXfV8dgwY)Z)BWKbjUJ1I5xSX6HVf6TbXp1msp6qSBOiMIIPqIfPJbXuZmndlFaZGrXEtgK4owlwTAIbjamYcrXtnNbM7s5Xs9Q6NmiXDSwm)Inwp8TqVniEXUrmff7kX8lgobcY8V4HVUVSifnNb2KGwm)IHtGGmFSuVQk6em4jbTy(fZl)GHL8)8)guGSx2GxmkI5lX8lgobcYuZzG5UuESuVQ(PEvboK5i6fCivNG(XoX5oFFQ7qYGe3X6dApKA(hWMo6fCiv4DDIHSqXQBHGuVIrdzfICPUyQ6atmsmQlgKt9fXuHXaXaBigKaaAakXiR65HezHfaRS4CNIhYbSdg25HmshdI5Jra7kmOeleK6DYGe3XAX8lg6elshdI5JL6vvbzhe)KbjUJ1hYCe9coK076kq(xc4GpX5oL)u3HKbjUJ1h0EiZr0l4q(yeWUcdkXcbPEpKA(hWMo6fCivUplwDleK6vmAilg5sDXuHXaXuXIHLQzXcmwmgWquxetfghymume46jg9UUgGsmvDGTeHyKvTylum0qeFigkgWW05UmpKdyhmSZd5tZoxjsiko(5Jra7kmO8Xc9e7gkIPOy(fJbme1fX8HIykVVeZVyQtyN4oE(aDzSaDh9ceZVyJDD6vfy(x8Wx3xwKIMZaBsqlMFXg760RkW8Xs9QQOtWGNdSeIIFX8HIykkMFXQxm0jgKaWilefpxCw3myWtgK4owlwTAIPzCceKjIlrXoxg9cMe0IvRMypn7CLiHO44NpgbSRWGYhl0tmFOiw9IPOy3kMceRQsS6fdDIfPJbXe0OWIpsxfgozqI7yTy(fdDIfPJbXuNWkLhl1RQjdsChRf7kXUsSReZVyJ1dFl0BdIxSBOi29I5xm0jgobcYKgYESUJm6fmjOfZVy1lg6eBSQzqcIPAgeyxGIvRMyOtSXUo9QcmrCjk25YOxWKGwSRoX5URZPUdjdsChRpO9qMJOxWH8zimdwxWxaxE6UcFihWoyyNhs1jStChpFGUmwGUJEbI5xm0jMEJ5ZqygSUGVaU80DfUO3yg9OsdqjMFXIeIIJz0ECj2IUzX8HIy3ROy(fREXgRh(wO3ge)uZi9OdX8HIy1l2GUGkBGy(uvsmfi2vIDLy(fdDIHtGGmFmcyxHbLyHGuVtcAX8lw9IHoXWjqqM0q2J1DKrVGjbTy1Qj2tZoxjsiko(5Jra7kmO8Xc9eZhXuGyxjwTAIH0OWIcK9Yg8IDdfX8Ty(f7PzNRejefh)8XiGDfgu(yHEIDJyx7qoUmCCjsiko(ZDkEIZDuZtDhsgK4owFq7HCa7GHDEivNWoXD88b6Yyb6o6fiMFXgRh(wO3ge)uZi9OdX8HIykkMFXIeIIJz0ECj2IUzX8HIykQ8hYCe9coKpt)9FIZDx3N6oKmiXDS(G2dzoIEbhY)Ih(6(YIu0Cgyhsn)dyth9coKk3NfJ8Ih(6EXwGyJDD6vfqS6tKGHIH0WpeJeq9ReJa44)ftflwczXqTnaLyXkg9slwDleK6vSeOftVIb2qmSunlgjwQxvIv17G4NhYbSdg25HuDc7e3XZhOlJfO7OxGy(fREXqNyr6yqmFmcyxHbLyHGuVtgK4owlwTAIfPJbX8Xs9QQGSdIFYGe3XAXQvtSNMDUsKquC8ZhJa2vyq5Jf6jMpue7EXQvtSXUo9QcmFmcyxHbLyHGuVti7Ln4fZhXUxSReZVy1lg6eBSQzqcIPAgeyxGIvRMyJDD6vfyI4suSZLrVGjK9Yg8I5Jyk6lXQvtSXUo9QcmrCjk25YOxWKGwm)Inwp8TqVniEX8HIy(wSRoX5of91PUdjdsChRpO9qMJOxWH0lHvyDbzHfnNb2H01aUm0hsfN((qoUmCCjsiko(ZDkEihWoyyNhsy26cRMbXm16FsqlMFXQxSiHO4ygThxITOBwSBeBSE4BHEBq8tnJ0JoeRwnXqNyFWPlWy9mDoX8l2y9W3c92G4NAgPhDiMpueBqx8sLvEAgOf7QdPM)bSPJEbhs0aeXsT(flHSye0kj2dAAwSaJfBbSyQ6atm3QI)qS6QJ6tXuUplMkmgiM(sdqjgs(bdflWsGyvxHftZi9OdXwOyGne7doDbgRftvhylriwcUiw1v45jo3POIN6oKmiXDS(G2dzoIEbhsVewH1fKfw0Cgyhsn)dyth9coKObiIbwXsT(ftv7CIPBwmvDG1aXcmwmaRSqSR5RxjXiEwmLdc1fBbIHV)lMQoWwIqSeCrSQRWZd5a2bd78qcZwxy1miMPw)ZgiMpIDnFjMcjgmBDHvZGyMA9p1eWm6fiMFXgRh(wO3ge)uZi9OdX8HIyd6IxQSYtZa9jo3P49N6oKmiXDS(G2d5a2bd78qQoHDI745d0LXc0D0lqm)Inwp8TqVni(PMr6rhI5dfXUxm)IvVy4eiiZ)Ih(6(YIu0CgytcAXQvtm89FX8lgsJclkq2lBWl2nue7EFjwTAIHoXWjqqMpwQxvfCxQ5FsqlMFXEok4lG4NrZW7PML7PhID1HmhrVGd5JL6vvb3LA(pX5ofV2PUdjdsChRpO9qoGDWWopKOtSp40fySEMoNy(ftDc7e3XZhOlJfO7OxGy(fBSE4BHEBq8tnJ0JoeZhkIDVy(fREXuNWoXD8K45cnSxyhxkWnYOxGy1Qj2tZoxjsiko(5Jra7kmO8Xc9e7gkIPaXQvtmibGrwikEc5Fja6gGQmCjSJltgK4owl2vhYCe9coK8aBBaQcKPHTxc0N4CNIk4u3HKbjUJ1h0EiZr0l4q(yeWUcdkXcbPEpKA(hWMo6fCirZDGjgzvRKynIyGnelDqo1xetVawjXiEwS6wii1RyQ6atmYL6IrqppKdyhmSZdz9IfPJbX8Xs9QQGSdIFYGe3XAXQvtSNMDUsKquC8ZhJa2vyq5Jf6jMpue7EXUsm)IPoHDI745d0LXc0D0lqm)IHtGGm)lE4R7llsrZzGnjOfZVyJ1dFl0BdIxSBOi29I5xS6fdDIHtGGmPHShR7iJEbtcAXQvtSNMDUsKquC8ZhJa2vyq5Jf6jMpIPaXU6eN7u03N6oKmiXDS(G2d5a2bd78qIoXWjqqMpwQxvfDcg8KGwm)IH0OWIcK9Yg8IDdfXOMIDRyr6yqmFc8GHieO4jdsChRpK5i6fCiFSuVQk6em4tCUtrL)u3HKbjUJ1h0EihWoyyNhY6f7xchEd0tAIpiCCHHe0rVGjdsChRfRwnX(LWH3a9u96YODC5xNAgetgK4owl2vI5xmgWquxMAgPhDiMpue7A(sm)IHoX(GtxGX6z6CI5xmCceK5FXdFDFzrkAodSPEvboKniyiKGoknYH8xchEd0t1RlJ2XLFDQzqCiBqWqibDuAppw3zWhsfpK5i6fCirC8JnGjsCiBqWqibDuq5w80Div8eN7u86CQ7qYGe3X6dApKdyhmSZdjobcYe3TR2r8XeY5ieRwnXqAuyrbYEzdEXUrSR5lXQvtmCceK5FXdFDFzrkAodSjbTy(fREXWjqqMpwQxvfCxQ5FsqlwTAIn21PxvG5JL6vvb3LA(Nq2lBWl2nuetrFj2vhYCe9coK0B0l4eN7uKAEQ7qYGe3X6dApKdyhmSZdjobcY8V4HVUVSifnNb2KG(qMJOxWHe3TRUGqaVCIZDkEDFQ7qYGe3X6dApKdyhmSZdjobcY8V4HVUVSifnNb2KG(qMJOxWHeNHpdR0auN4C39(6u3HKbjUJ1h0EihWoyyNhsCceK5FXdFDFzrkAodSjb9HmhrVGdjsdzC3U6tCU7Efp1DizqI7y9bThYbSdg25HeNabz(x8Wx3xwKIMZaBsqFiZr0l4qMGb)bmDLr6CN4C393FQ7qYGe3X6dApK5i6fCijEU0b79hsn)dyth9coKuNrscxigs6C45OIyilumIpXDSyDWEp1qmL7ZIPQdmXiV4HVUxSfrmQZzGnpKdyhmSZdjobcY8V4HVUVSifnNb2KGwSA1edPrHffi7Ln4f7gXU3xN4ehYp40fyLH(p1DUtXtDhsgK4owFq7HCPpKphhYCe9coKQtyN4o(qQoDe8HCSRtVQaZhl1RQIobdEoWsik(liWCe9csNy(qrmfNxhFFi18pGnD0l4qsTND0mumQTe2jUJpKQtybKE8H8X0LadYp260N4C39N6oKmiXDS(G2dzoIEbhs1jOFSdPM)bSPJEbhsQTe0pMynIyQyXsil2iPPBakXwGyupbdwSbwcrX)umQDj0DrmCgzHSyin8dX0jyWI1iIPIfdlvZIbwXURrHfFKUkmumCIqmQNWkIrIL6vLynqSfQzOyXkgkoe76jOdcilgbTy1dwXuo5hmum04)5)n4Q5HCa7GHDEiRxm0jM6e2jUJNpMUeyq(XwNwSA1edDIfPJbXe0OWIpsxfgozqI7yTy(flshdIPoHvkpwQxvtgK4owl2vI5xSX6HVf6TbXp1msp6qmFetrX8lg6edsayKfIINEjSszrkbgx8Ypyyj)p)VbtgK4owFIZDx7u3HKbjUJ1h0Ei18pGnD0l4qQW76edzHIrIL6vLh70IDRyKyPEv9bSRWIraC8)IPIflHSyj(seIfRyJKwSfig1tWGfBGLqu8pf76c4UiMkmgiwv3aTyOzoRa4)fRFXs8LielwXGeaXwIyEirwybWklo3P4HCa7GHDEiH5GNGgfwuyhYHKvwaZs6TeG4qQaFDiZr0l4qsVRRa5FjGd(eN7uWPUdjdsChRpO9qoGDWWopKmGHOUiMpuetb(sm)IXagI6YuZi9OdX8HIyk6lX8lg6etDc7e3XZhtxcmi)yRtlMFXgRh(wO3ge)uZi9OdX8rmfpK5i6fCiFSuVQ8yN(eN789PUdjdsChRpO9qU0hYNJdzoIEbhs1jStChFivNoc(qowp8TqVni(PMr6rhI5dfXUxSBfdNabz(yPEvvWDPM)jb9HuZ)a20rVGdz1vyXcmi)yRt)IHSqXyqWWgGsmsSuVQeJ6jyWhs1jSasp(q(y6Yy9W3c92G4pX5oL)u3HKbjUJ1h0Eix6d5ZXHmhrVGdP6e2jUJpKQthbFihRh(wO3ge)uZi9OdX8HIyx7qoGDWWopKJvndsqmRCb2j4qQoHfq6XhYhtxgRh(wO3ge)jo3DDo1DizqI7y9bThYL(q(CCiZr0l4qQoHDI74dP60rWhYX6HVf6TbXp1msp6qSBOiMIhYbSdg25HuDc7e3XtINl0WEHDCPa3iJEbI5xSNMDUsKquC8ZhJa2vyq5Jf6jMpuetbhs1jSasp(q(y6Yy9W3c92G4pX5oQ5PUdjdsChRpO9qMJOxWH8Xs9QQOtWGpKA(hWMo6fCiPEcgSyAcydqjg5fp819ITqXs8vnlwGb5hBD65HCa7GHDEiRxS6ftDc7e3XZhtxgRh(wO3geVy1QjM6e2jUJNpMUeyq(XwNwSReZVyphf8fq8ZOz49uZY90dX8l2yvZGeeZkxGDceRwnXuNWoXD88X0LX6HVf6TbXlMFXQxmCceK5FXdFDFzrkAodSjK9Yg8I5dfXuCEVy1QjM6e2jUJNpMUeyq(XwNwSReRwnXWjqqMdSC)cEc4jbTy1Qj2tZoxjsiko(5Jra7kmO8Xc9eZhkIPaX8l2yxNEvbM)fp819LfPO5mWMq2lBWlMpIPOVe7kX8lw9IHtGGmPziYcZG1f1Cd(5h5OIy3iMceRwnXEA25krcrXXpFmcyxHbLpwONy(i21e7QtCU76(u3HKbjUJ1h0EiZr0l4q(yPEvv0jyWhsn)dyth9coKOLaceJ6jyWVydSeIIFXAeXUSeIr7YlIr9ewrmsSuVQE0JgD5a2XfXwOy4mYczXcmwmKgfwigd0VynIyKl1ft1cQwigolgKt9fXAGyr7XZd5a2bd78qQoHDI745JPlJ1dFl0BdIxm)IH0OWIcK9Yg8IDJyJDD6vfy(x8Wx3xwKIMZaBczVSbVy1Qjg6elshdIjduZULUbOkpwQxv)KbjUJ1N4ehsCI2Pp1DUtXtDhsgK4owFq7HCa7GHDEirNyr6yqmbnkS4J0vHHtgK4owlMFXGeagzHO4z0GlLyvwpk4UuZtgK4owlMFXEA25krcrXXpFmcyxHbLpwONy3iMVpK5i6fCiFSw9jo3D)PUdjdsChRpO9qoGDWWopKpn7CLiHO44fZhkIDVy(fREXqNyJvndsqmb8aUUfQfRwnXg760RkW8zimdwxWxaxE6Ucp9sLvgyjef)IPqInWsik(liWCe9csNy(qrmFnV33IvRMypn7CLiHO44NpgbSRWGYhl0tmFetbIDLy(fREXWjqqM0mezHzW6IAUb)8JCurSBOiMceRwnXEA25krcrXXpFmcyxHbLpwONy(iMce7QdzoIEbhYhJa2vyq5Jf6DIZDx7u3HKbjUJ1h0EihWoyyNhsCceKjndrwygSUOMBWp)ihve7gkIDVy(fREXg760RkW8zimdwxWxaxE6Ucp9sLvgyjef)IPqInWsik(liWCe9csNy3qrmFnV33IvRMy)s4WBGE64uxWVuyLLE0oEYGe3XAX8lg6edNabz64uxWVuyLLE0oEsqlwTAI9lHdVb6zfwDd(YUOHHDna1KbjUJ1I5xm0jMMXjqqMvy1n4lQGzGnjOf7QdzoIEbhYNHWmyDbFbC5P7k8jo3PGtDhYCe9coKOC76H7snFizqI7y9bTN4CNVp1DizqI7y9bThYCe9coK45OYhj(HuZ)a20rVGdjAZrLpsCXAppw3zWUlIraC8)IfySyawzHyvxHfRFXqJG2lhyjefRflbAXuXIPAbvleBK0IXagI6IyQYoAakXqwOyDmpKdyhmSZdj6eBSQzqcIzLlWobIvRMyOtS6ftDc7e3XZ(lawzrzqxsq7LdSeII1I5xS6flApUeB5XIcTJ4NxtSBeZxtFlwTAIfThxIT8yrH2r8tfi2nIPOyxjMFXyadrDrSBet59LyxDItCIdPAg(9co3DVVU)EFD)9uZdPQecAaQ)qIMrJx)DOb3vvqnetS6WyXAp6fgIHSqXQ2hC6cmwxnXGCvnrdzTy)6XILeX6LbRfBGLau8pfQOwnGfZ3udXQ(cuZWG1IvnibGrwikEIMQMyXkw1GeagzHO4jAAYGe3X6Qjw9kQSRMcvuRgWIrnPgIv9fOMHbRfRAqcaJSqu8envnXIvSQbjamYcrXt00KbjUJ1vtS6vuzxnfQeQqZOXR)o0G7QkOgIjwDySyTh9cdXqwOyvJgYJ1dpJQjgKRQjAiRf7xpwSKiwVmyTydSeGI)Pqf1QbSyxJAiw1xGAggSwSQ9lHdVb6jAQAIfRyv7xchEd0t00KbjUJ1vtS6vuzxnfQOwnGf7AudXQ(cuZWG1IvTFjC4nqprtvtSyfRA)s4WBGEIMMmiXDSUAILHyu7UUOwIvVIk7QPqf1QbSyxhQHyvFbQzyWAXQgKaWilefprtvtSyfRAqcaJSqu8ennzqI7yD1eldXO2DDrTeREfv2vtHkHk0mA86Vdn4UQcQHyIvhglw7rVWqmKfkw1g6VAIb5QAIgYAX(1JfljI1ldwl2albO4FkurTAalMcOgIv9fOMHbRfRAqcaJSqu8envnXIvSQbjamYcrXt00KbjUJ1vtS6VxzxnfQOwnGft5PgIv9fOMHbRfRAqcaJSqu8envnXIvSQbjamYcrXt00KbjUJ1vtS6vuzxnfQOwnGftXRrneR6lqnddwlw1GeagzHO4jAQAIfRyvdsayKfIINOPjdsChRRMy1ROYUAkurTAalMIkp1qSQVa1mmyTyv7xchEd0t0u1elwXQ2Veo8gONOPjdsChRRMy1FVYUAkujuHMrJx)DOb3vvqnetS6WyXAp6fgIHSqXQ2hC6cSYq)vtmixvt0qwl2VESyjrSEzWAXgyjaf)tHkQvdyXUNAiw1xGAggSwSQbjamYcrXt0u1elwXQgKaWilefprttgK4owxnXYqmQDxxulXQxrLD1uOsOcnJgV(7qdURQGAiMy1HXI1E0lmedzHIvnCI2PRMyqUQMOHSwSF9yXsIy9YG1InWsak(NcvuRgWIPi1qSQVa1mmyTyvdsayKfIINOPQjwSIvnibGrwikEIMMmiXDSUAIvVIk7QPqf1QbSy(MAiw1xGAggSwSQfThxIT8yXennPDeF1elwXQw0ECj2YJffAhXprtvtS6VxzxnfQeQqd8OxyWAXUoILJOxGyU(JFkuDiPHls74dzvQIyKe4HJJlID9lkcwOQkvrmLtchyIDVsIDVVU)EHkHQQufXQowcqXp1qOQkvrmfsmLZQMftDc7e3XtINl0WEHDCPa3iJEbIrql2VI1Hy9l2ZHy4mYczXuXIr8SyDmfQQsvetHeR6RhEdyX8iCrt7yXgPZvYr0lO46peJbbS5xSyfdYAIblg9gmi60jgKvTWktHQQufXuiXuozfwSQ2Xp2aMiHyniyiKGoeRbInwp8meRretflgAiIpet3AX6qmKfkM61Lr74YVo1miMcvcvvPkIPWqwHQ(6HNHqvoIEb)KgYJ1dpJBPG(KM2DPqV9VaHQCe9c(jnKhRhEg3sb94BeowxqC5fwRQbOkXQSgiuLJOxWpPH8y9WZ4wkOhXXp2aMiHsncLFjC4nqpPj(GWXfgsqh9cQv7xchEd0t1RlJ2XLFDQzqiuLJOxWpPH8y9WZ4wkO)doDbMqvoIEb)KgYJ1dpJBPGEVewH1fKfw0Cgykrd5X6HNr55Xc0pff9TqvoIEb)KgYJ1dpJBPG(31dUKaDr3dwjAipwp8mkppwG(POOsncfiJa5hlXDSqvoIEb)KgYJ1dpJBPG(hl1RQcUl18RuJqbsayKfIINEjSszrkbgx8Ypyyj)p)VbcvcvvPkIPCYgi21Vrg9ceQYr0l4PuPhveQQIyk3N1IfRyAoyOxdyXuHXbgdfBSRtVQaVyQYoedzHIrcOUy45ZAXwGyrcrXXpfQYr0l4VLc6vNWoXDSsG0JP8aDzSaDh9cusD6iyk4eiiZ31dUKaDr3dEsqxR2tZoxjsiko(5Jra7kmO8Xc98HIYluLJOxWFlf0RoHDI7yLaPht5b6Yyb6o6fOK60rWuWjqqMVRhCjb6IUh8KGUwTNMDUsKquC8ZhJa2vyq5Jf65dfLxOQkIvDmEurSyf7zwSgrSaJfdWkleR6kSy13aXcmwmwndcXweXsXiXQtmA4oUsS(fdncAVCGLquSwOkhrVG)wkOxDc7e3XkbspMs)faRSOmOljO9YbwcrXALAekJvndsqmRCb2jqj1PJGPmwp8TqVniEkk6hNabzYdSTbOkqMg2EjqxUFsqxR2y9W3c92G4PCVFCceKjpW2gGQazAy7LaD5Atc6A1gRh(wO3gepLR5hNabzYdSTbOkqMg2EjqxuWKGUwTX6HVf6TbXtrb(XjqqM8aBBaQcKPHTxc0fFpjOfQQIyOXXyjaHyilumsS6edY5i6fiw0ESy4xeRrbwydqjMBvPqvxHflbTxoWsikwlMxgdm(fRbIfySy(A67xmAipyw3auILIrVbdIoDIrIvNy0WDiuLJOxWFlf0RoHDI7yLaPhtHrq4r0Q5Yy9W3c92G4vsD6iykmccpIwnxgRh(wO3geVqvoIEb)TuqV6e2jUJvcKEmfgbHhrRMlJ1dFl0BdIxPgHYyvZGeeZkxGDc8Zii8iA1CzSE4BHEBq8(mwp8TqVniE)J1dFl0BdIFQzKE0Hp37pApUeB5XIcTJ4Nk4gFn9TF0PoHDI74z)faRSOmOljO9YbwcrXALuNocMYy9W3c92G4fQQIyvhJhveR6u)fldXqA4hcv5i6f83sb9J05k5i6fuC9hkbspMYq)cvvrm0inT7IyKUEWILaTyuVhSyzi293kw1vyX0eWgGsSaJfdPHFiMI(sSNhlq)kjwIemuSaldXuWTIvDfwSgrSoeJvgDd5xmvDG1aXcmwmaRSqSQIQtDXwOy9lgydXiOfQYr0l4VLc6Fxp4sc0fDpyLAekpn7CLiHO44NpgbSRWGYhl07gL3psJclkq2lBW7JY7hNabz(UEWLeOl6EWti7Ln4Vb1qp9sL5FSE4BHEBq8(qrbku9r7X3OOVUQQ6EHQQi21fWDrSbwcqXIb3iJEbI1iIPIfdlvZIrd7f2XLcCJm6fi2ZHyjqlMhHlAAhlwKquC8IrqpfQYr0l4VLc6vNWoXDSsG0JPq8CHg2lSJlf4gz0lqj1PJGPqd7f2XLcCJm6f4)PzNRejefh)8XiGDfgu(yHE(q5EHQQi21taedHW5Ui2RQJbg)IfRybglgzWPlWyTyx)gz0lqS6XViMEBakX(vjX6qmKfo4xm6DDnaLynIyGnWAakX6xSuD2Ue3XxnfQYr0l4VLc6HeGsoIEbfx)HsG0JP8bNUaJ1k9bShbffvQrO8bNUaJ1Z05eQQIykmSxyhxe763iJEbvLeJAXr1EXq1QzXsXgWKwSeFjcXyadrDrmKfkwGXI9bNUatSQt9xS6XjANMHI9r7CIb5NMhHyDC1um0WjOvsSoeBKaXWzXcSme7BpAhpfQYr0l4VLc6hPZvYr0lO46pucKEmLp40fyLH(v6dypckkQuJqrDc7e3XtINl0WEHDCPa3iJEbcvvrSQVGV1mumIVbOelfJm40fyIvDQlMkmgigKZbwdqjwGXIXagI6IybgKFS1PfQYr0l4VLc6hPZvYr0lO46pucKEmLp40fyLH(vQrOWagI6YuZi9OJBOOoHDI745hC6cSsGb5hBDAHQQiwv3G(XeldX8sLPKyk4wXu1b2seIrDsXwOyQ6atmYL6InGDigobcIsI57BftvhyIrDsXQFjIV1SyFWPlWUcnSIPQdmXOoPyP7xXqAq)yILHyk4wXsuzd(qmfiwKquC8Iv)seFRzX(GtxGDLqvoIEb)Tuq)iDUsoIEbfx)HsG0JPG0G(XuQrOOoHDI74jJGWJOvZLX6HVf6TbX7dLbDXlvw5PzGUwTX6HVf6TbXp1msp64gkkwRgsJclkq2lBWFdff9RoHDI74jJGWJOvZLX6HVf6TbX7dLRvRgobcY8V4HVUVSifnNbwjjIDa7ysq7xDc7e3XtgbHhrRMlJ1dFl0BdI3hkkOwTNMDUsKquC8ZhJa2vyq5Jf65dff4xDc7e3XtgbHhrRMlJ1dFl0BdI3hkkqOQkIPCFwSumCI2PzOyQWyGyqohynaLybglgdyiQlIfyq(XwNwOkhrVG)wkOFKoxjhrVGIR)qjq6XuWjANwPgHcdyiQltnJ0JoUHI6e2jUJNFWPlWkbgKFS1PfQQIyuRvf)Hy0WEHDCrSgiw6CITiIfySyOrfMAjgopsINfRdXgjXZVyPyvfvN6cv5i6f83sb9jCKaUeleYGqPgHcdyiQltnJ0Jo8HII((wgWquxMqgfdeQYr0l4VLc6t4ibCHMW9SqvoIEb)TuqVRrHfFbneHgLhdcHQCe9c(BPGE8evzrkbShvEHkHQQufXqlr70m8fQYr0l4N4eTtt5XA1k1iuqxKogetqJcl(iDvy4KbjUJ1(HeagzHO4z0GlLyvwpk4UuZ(FA25krcrXXpFmcyxHbLpwO3n(wOkhrVGFIt0o9Tuq)Jra7kmO8Xc9uQrO80SZvIeIIJ3hk37VE0nw1mibXeWd46wOUwTXUo9QcmFgcZG1f8fWLNURWtVuzLbwcrXVcnWsik(liWCe9csNpu818EFxR2tZoxjsiko(5Jra7kmO8Xc98rbx5VECceKjndrwygSUOMBWp)ihvUHIcQv7PzNRejefh)8XiGDfgu(yHE(OGReQYr0l4N4eTtFlf0)meMbRl4lGlpDxHvQrOGtGGmPziYcZG1f1Cd(5h5OYnuU3F9JDD6vfy(meMbRl4lGlpDxHNEPYkdSeIIFfAGLqu8xqG5i6fKUBO4R59(UwTFjC4nqpDCQl4xkSYspAhpzqI7yTF0HtGGmDCQl4xkSYspAhpjORv7xchEd0ZkS6g8LDrdd7AaQjdsChR9JonJtGGmRWQBWxubZaBsqFLqvoIEb)eNOD6BPGEuUD9WDPMfQQIyOnhv(iXfR98yDNb7UigbWX)lwGXIbyLfIvDfwS(fdncAVCGLquSwSeOftflMQfuTqSrslgdyiQlIPk7ObOedzHI1XuOkhrVGFIt0o9TuqpEoQ8rIRuJqbDJvndsqmRCb2jOwn0vV6e2jUJN9xaSYIYGUKG2lhyjefR9xF0ECj2YJfZRnPDe)n(A67A1I2JlXwESyQGjTJ4VrXR8ZagI6YnkVVUsOsOQkIv9DD6vf4fQQIyk3NfJ6jyWITiikeQHwmCgzHSybglgsd)qmsmcyxHbIrgl0tme46jwDleK6vSX6XVynykuLJOxWph6NYJL6vvrNGbReXZLfbPGAOPOOsncf0HtGGmFSuVQk6em4jbTFCceK5Jra7kmOeleK6Dsq7hNabz(yeWUcdkXcbPENq2lBWFdLRn9TqvveRELlWX)lw6GCQVigbTy48ijEwmvSyXUveJel1RkXQ6Dq8xjgXZIrEXdFDVylcIcHAOfdNrwilwGXIH0WpeJeJa2vyGyKXc9edbUEIv3cbPEfBSE8lwdMcv5i6f8ZH(VLc6)lE4R7llsrZzGPeXZLfbPGAOPOOsncfCceK5Jra7kmOeleK6Dsq7hNabz(yeWUcdkXcbPENq2lBWFdLRn9TqvoIEb)CO)BPGEexIIDUm6fOuJqrDc7e3XZhOlJfO7OxGF09bNUaJ1tVeeo2F9pn7CLiHO44NpgbSRWGYhl07gkk6FSRtVQaZ)Ih(6(YIu0CgytcA)OlshdI5JL6vvbzhe)KbjUJ11QHtGGm)lE4R7llsrZzGnjOVY)y9W3c92G49HIVfQYr0l4Nd9Flf0Rob9JPuJqPEibGrwikE6LWkLfPeyCXl)GHL8)8)g4FSE4BHEBq8tnJ0JoUHIIkuKogetnZ0mS8bmdgf7nzqI7yDTAqcaJSqu8uZzG5UuESuVQE)J1dFl0BdI)gfVYpobcY8V4HVUVSifnNb2KG2pobcY8Xs9QQOtWGNe0(9Ypyyj)p)Vbfi7Ln4P4l)4eiitnNbM7s5Xs9Q6N6vfqOQkIPW76edzHIv3cbPEfJgYke5sDXu1bMyKyuxmiN6lIPcJbIb2qmiba0auIrw1tHQCe9c(5q)3sb9076kq(xc4GvczHfaRSGIIk1iuI0XGy(yeWUcdkXcbPENmiXDS2p6I0XGy(yPEvvq2bXpzqI7yTqvvet5(Sy1TqqQxXOHSyKl1ftfgdetflgwQMflWyXyadrDrmvyCGXqXqGRNy076AakXu1b2seIrw1ITqXqdr8HyOyadtN7YuOkhrVGFo0)Tuq)Jra7kmOeleK6vPgHYtZoxjsiko(5Jra7kmO8Xc9UHII(zadrDXhkkVV8RoHDI745d0LXc0D0lW)yxNEvbM)fp819LfPO5mWMe0(h760RkW8Xs9QQOtWGNdSeIIFFOOO)6rhKaWilefpxCw3myW1QPzCceKjIlrXoxg9cMe01Q90SZvIeIIJF(yeWUcdkFSqpFOuVI3QGQQ6rxKogetqJcl(iDvy4KbjUJ1(rxKogetDcRuESuVQMmiXDS(QRUY)y9W3c92G4VHY9(rhobcYKgYESUJm6fmjO9xp6gRAgKGyQMbb2fyTAOBSRtVQatexIIDUm6fmjOVsOkhrVGFo0)Tuq)ZqygSUGVaU80DfwPXLHJlrcrXXtrrLAekQtyN4oE(aDzSaDh9c8Jo9gZNHWmyDbFbC5P7kCrVXm6rLgGYFKquCmJ2JlXw0n7dL7v0F9J1dFl0BdIFQzKE0HpuQFqxqLnWNQsk4QR8JoCceK5Jra7kmOeleK6Dsq7VE0HtGGmPHShR7iJEbtc6A1EA25krcrXXpFmcyxHbLpwONpk4QA1qAuyrbYEzd(BO4B)pn7CLiHO44NpgbSRWGYhl07MRjuLJOxWph6)wkO)z6VFLAekQtyN4oE(aDzSaDh9c8pwp8TqVni(PMr6rh(qrr)rcrXXmApUeBr3Spuuu5fQQIyk3NfJ8Ih(6EXwGyJDD6vfqS6tKGHIH0WpeJeq9ReJa44)ftflwczXqTnaLyXkg9slwDleK6vSeOftVIb2qmSunlgjwQxvIv17G4Ncv5i6f8ZH(VLc6)lE4R7llsrZzGPuJqrDc7e3XZhOlJfO7OxG)6rxKogeZhJa2vyqjwii17KbjUJ11QfPJbX8Xs9QQGSdIFYGe3X6A1EA25krcrXXpFmcyxHbLpwONpuUVwTXUo9QcmFmcyxHbLyHGuVti7Ln495(R8xp6gRAgKGyQMbb2fyTAJDD6vfyI4suSZLrVGjK9Yg8(OOVQvBSRtVQatexIIDUm6fmjO9pwp8TqVniEFO47ReQQIyObiILA9lwczXiOvsSh00Sybgl2cyXu1bMyUvf)Hy1vh1NIPCFwmvymqm9LgGsmK8dgkwGLaXQUclMMr6rhITqXaBi2hC6cmwlMQoWwIqSeCrSQRWtHQCe9c(5q)3sb9EjScRlilSO5mWuY1aUm0uuC6BLgxgoUejefhpffvQrOaZwxy1miMPw)tcA)1hjefhZO94sSfDZ3mwp8TqVni(PMr6rh1QHUp40fySEMoN)X6HVf6TbXp1msp6Whkd6IxQSYtZa9vcvvrm0aeXaRyPw)IPQDoX0nlMQoWAGybglgGvwi2181RKyeplMYbH6ITaXW3)ftvhylriwcUiw1v4PqvoIEb)CO)BPGEVewH1fKfw0Cgyk1iuGzRlSAgeZuR)zd85A(sHGzRlSAgeZuR)PMaMrVa)J1dFl0BdIFQzKE0Hpug0fVuzLNMbAHQCe9c(5q)3sb9pwQxvfCxQ5xPgHI6e2jUJNpqxglq3rVa)J1dFl0BdIFQzKE0HpuU3F94eiiZ)Ih(6(YIu0Cgytc6A1W3)9J0OWIcK9Yg83q5EFvRg6WjqqMpwQxvfCxQ5Fsq7)5OGVaIFgndVNAwUNECLqvoIEb)CO)BPGEEGTnavbY0W2lbALAekO7doDbgRNPZ5xDc7e3XZhOlJfO7OxG)X6HVf6TbXp1msp6Whk37VE1jStChpjEUqd7f2XLcCJm6fuR2tZoxjsiko(5Jra7kmO8Xc9UHIcQvdsayKfIINq(xcGUbOkdxc74Yvcvvrm0ChyIrw1kjwJigydXshKt9fX0lGvsmINfRUfcs9kMQoWeJCPUye0tHQCe9c(5q)3sb9pgbSRWGsSqqQxLAek1hPJbX8Xs9QQGSdIFYGe3X6A1EA25krcrXXpFmcyxHbLpwONpuU)k)QtyN4oE(aDzSaDh9c8JtGGm)lE4R7llsrZzGnjO9pwp8TqVni(BOCV)6rhobcYKgYESUJm6fmjORv7PzNRejefh)8XiGDfgu(yHE(OGReQYr0l4Nd9Flf0)yPEvv0jyWk1iuqhobcY8Xs9QQOtWGNe0(rAuyrbYEzd(BOqnVnshdI5tGhmeHafpzqI7yTqvoIEb)CO)BPGEeh)ydyIek1iuQ)xchEd0tAIpiCCHHe0rVGA1(LWH3a9u96YODC5xNAgex5Nbme1LPMr6rh(q5A(Yp6(GtxGX6z6C(XjqqM)fp819LfPO5mWM6vfqPgemesqhL2ZJ1DgmffvQbbdHe0rbLBXthffvQbbdHe0rPrO8lHdVb6P61Lr74YVo1mieQYr0l4Nd9Flf0tVrVaLAek4eiitC3UAhXhtiNJOwnKgfwuGSx2G)MR5RA1WjqqM)fp819LfPO5mWMe0(RhNabz(yPEvvWDPM)jbDTAJDD6vfy(yPEvvWDPM)jK9Yg83qrrFDLqvoIEb)CO)BPGEC3U6ccb8IsncfCceK5FXdFDFzrkAodSjbTqvoIEb)CO)BPGECg(mSsdqPuJqbNabz(x8Wx3xwKIMZaBsqluLJOxWph6)wkOhPHmUBxTsncfCceK5FXdFDFzrkAodSjbTqvoIEb)CO)BPG(em4pGPRmsNtPgHcobcY8V4HVUVSifnNb2KGwOQkIrDgjjCHyiPZHNJkIHSqXi(e3XI1b79udXuUplMQoWeJ8Ih(6EXweXOoNb2uOkhrVGFo0)TuqpXZLoyVxPgHcobcY8V4HVUVSifnNb2KGUwnKgfwuGSx2G)M79LqLqvvQIyvDd6hJHVqvvednJ1owmIVbOetHHShR7iJEbkjwQEBTyJ8JgGsmsxpyXsGwmQ3dwmvymqmsSuVQeJ6jyWI1Vy)UaXIvmCwmIN1kjgRSbthIHSqXQkFb2jqOkhrVGFI0G(XOOoHDI7yLaPhtHgYESU8aDzSaDh9cusD6iykr6yqmPHShR7iJEbtgK4ow7)PzNRejefh)8XiGDfgu(yHE3uVVvOXQMbjiMaEax3c1x5hDJvndsqmRCb2jqOkhrVGFI0G(XULc6Fxp4sc0fDpyLAekOtDc7e3XtAi7X6Yd0LXc0D0lW)tZoxjsiko(5Jra7kmO8Xc9Ur59JoCceK5JL6vvrNGbpjO9JtGGmFxp4sc0fDp4jK9Yg83G0OWIcK9Yg8(HmcKFSe3Xcv5i6f8tKg0p2Tuq)76bxsGUO7bRuJqrDc7e3XtAi7X6Yd0LXc0D0lW)yxNEvbMpwQxvfDcg8CGLqu8xqG5i6fKUBuCED8TFCceK576bxsGUO7bpHSx2G)MXUo9Qcm)lE4R7llsrZzGnHSx2G3F9JDD6vfy(yPEvv0jyWtiN6l(XjqqM)fp819LfPO5mWMq2lBWRq4eiiZhl1RQIobdEczVSb)nkoV)kHQQig1E2rZqXO2syN4owmKfk21tqheqEkgzLMwmnbSbOet5KFWqXqJ)N)3aXwOyAcydqjg1tWGftvhyIr9ewrSeOfdSIDxJcl(iDvy4uOkhrVGFI0G(XULc6vNWoXDSsG0JP8vA6cKGoiGSsQthbtXl)GHL8)8)guGSx2G3hFvRg6I0XGycAuyXhPRcdNmiXDS2FKogetDcRuESuVQMmiXDS2pobcY8Xs9QQOtWGNe01Q90SZvIeIIJF(yeWUcdkFSqpFOuVcuOp40fySEMoxvvKogeZhl1RQcYoi(jdsChRVsOQkIvvMzAXiOf76jOdcilwJiwhI1Vyj(seIfRyqcGylrmfQYr0l4NinOFSBPGEibDqazLAekO7doDbgRNPZ5VE0PoHDI745xPPlqc6GaY1QPoHDI74jXZfAyVWoUuGBKrVGR8hjefhZO94sSfDZkeK9Yg8(O8(HmcKFSe3Xcv5i6f8tKg0p2Tuq)ZdihLGhyGUQMGfQQIykhcx06nIgGsSiHO44flWYqmvTZjMRvZIHSqXcmwmnbmJEbITiID9e0bbKvsmiJa5htmnbSbOeJobA2RhtHQCe9c(jsd6h7wkOhsqheqwPXLHJlrcrXXtrrLAekOtDc7e3XZVstxGe0bbK9Jo1jStChpjEUqd7f2XLcCJm6f4)PzNRejefh)8XiGDfgu(yHE(q5E)rcrXXmApUeBr3SpuQ333w)9vvJ1dFl0BdI)QR8dzei)yjUJfQQIyxpJa5htSRNGoiGSyCcDxeRreRdXu1oNySYOBilMMa2auIrEXdFD)umQVIfyzigKrG8JjwJig5sDXqXXlgKt9fXAGybglgGvwiMV)PqvoIEb)ePb9JDlf0djOdciRuJqbDQtyN4oE(vA6cKGoiGSFi7Ln4VzSRtVQaZ)Ih(6(YIu0Cgyti7Ln4VvrF5FSRtVQaZ)Ih(6(YIu0Cgyti7Ln4VHIV9hjefhZO94sSfDZkeK9Yg8(m21PxvG5FXdFDFzrkAodSjK9Yg836BHQCe9c(jsd6h7wkOh3LJkf6vLMHk1iuqN6e2jUJNepxOH9c74sbUrg9c8)0SZvIeIIJ3hkxtOkhrVGFI0G(XULc6z19pyygSqLqvvQIyKbNUatSQVRtVQaVqvveJAp7OzOyuBjStChluLJOxWp)GtxGvg6NI6e2jUJvcKEmLhtxcmi)yRtRK60rWug760RkW8Xs9QQOtWGNdSeII)ccmhrVG05dffNxhFluvfXO2sq)yI1iIPIflHSyJKMUbOeBbIr9emyXgyjef)tXO2Lq3fXWzKfYIH0WpetNGblwJiMkwmSunlgyf7Ugfw8r6QWqXWjcXOEcRigjwQxvI1aXwOMHIfRyO4qSRNGoiGSye0Ivpyft5KFWqXqJ)N)3GRMcv5i6f8Zp40fyLH(VLc6vNG(XuQrOup6uNWoXD88X0LadYp2601QHUiDmiMGgfw8r6QWWjdsChR9hPJbXuNWkLhl1RQjdsChRVY)y9W3c92G4NAgPhD4JI(rhKaWilefp9syLYIucmU4LFWWs(F(FdeQQIyk8UoXqwOyKyPEv5XoTy3kgjwQxvFa7kSyeah)VyQyXsilwIVeHyXk2iPfBbIr9emyXgyjef)tXUUaUlIPcJbIv1nqlgAMZka(FX6xSeFjcXIvmibqSLiMcv5i6f8Zp40fyLH(VLc6P31vG8VeWbReYclawzbffvIvwaZs6TeGGIc8Lsncfyo4jOrHff2HiuLJOxWp)GtxGvg6)wkO)Xs9QYJDALAekmGHOU4dff4l)mGHOUm1msp6Whkk6l)OtDc7e3XZhtxcmi)yRt7FSE4BHEBq8tnJ0Jo8rrHQQiw1vyXcmi)yRt)IHSqXyqWWgGsmsSuVQeJ6jyWcv5i6f8Zp40fyLH(VLc6vNWoXDSsG0JP8y6Yy9W3c92G4vsD6iykJ1dFl0BdIFQzKE0HpuU)wCceK5JL6vvb3LA(Ne0cv5i6f8Zp40fyLH(VLc6vNWoXDSsG0JP8y6Yy9W3c92G4vsD6iykJ1dFl0BdIFQzKE0HpuUMsncLXQMbjiMvUa7eiuLJOxWp)GtxGvg6)wkOxDc7e3XkbspMYJPlJ1dFl0BdIxj1PJGPmwp8TqVni(PMr6rh3qrrLAekQtyN4oEs8CHg2lSJlf4gz0lW)tZoxjsiko(5Jra7kmO8Xc98HIceQQIyupbdwmnbSbOeJ8Ih(6EXwOyj(QMflWG8JTo9uOkhrVGF(bNUaRm0)Tuq)JL6vvrNGbRuJqP(6vNWoXD88X0LX6HVf6TbXxRM6e2jUJNpMUeyq(XwN(k)phf8fq8ZOz49uZY90d)JvndsqmRCb2jOwn1jStChpFmDzSE4BHEBq8(RhNabz(x8Wx3xwKIMZaBczVSbVpuuCEFTAQtyN4oE(y6sGb5hBD6RQvdNabzoWY9l4jGNe01Q90SZvIeIIJF(yeWUcdkFSqpFOOa)JDD6vfy(x8Wx3xwKIMZaBczVSbVpk6RR8xpobcYKMHilmdwxuZn4NFKJk3OGA1EA25krcrXXpFmcyxHbLpwONpx7kHQQigAjGaXOEcg8l2alHO4xSgrSllHy0U8IyupHveJel1RQh9OrxoGDCrSfkgoJSqwSaJfdPrHfIXa9lwJig5sDXuTGQfIHZIb5uFrSgiw0E8uOkhrVGF(bNUaRm0)Tuq)JL6vvrNGbRuJqrDc7e3XZhtxgRh(wO3geVFKgfwuGSx2G)MXUo9Qcm)lE4R7llsrZzGnHSx2GVwn0fPJbXKbQz3s3auLhl1RQFYGe3XAHkHQQufXidoDbgRf763iJEbcvvrm0aeXidoDbg6vNG(XelHSye0kjgXZIrIL6v1hWUclwSIHZagPdXqGRNybglgD(FRMfdFbeVyjqlwv3aTyOzoRa4)vsmwndeRretflwczXYqmVuzIvDfwS6jao(FXi(gGsmLt(bdfdn(F(FdUsOkhrVGF(bNUaJ1uESuVQ(a2vyLAek1JtGGm)GtxGnjORvdNabzQob9JnjOVYF9pn7CLiHO44NpgbSRWGYhl07gfuRM6e2jUJNepxOH9c74sbUrg9cUYVx(bdl5)5)nOazVSbpfFjuvfXQ6g0pMyzi21UvSQRWIPQdSLieJ6KIHEXuWTIPQdmXOoPyQ6atmsmcyxHbIv3cbPEfdNabrmcAXIvSu92AX(1JfR6kSyQYpyX(oiYOxWpfQQIyOr3VI9jclwSIH0G(XeldXuWTIvDfwmvDGjgRSCeUlIPaXIeIIJFkw9KPhlw(ITeX3AwSp40fyZReQQIyvDd6htSmetb3kw1vyXu1b2seIrDsLeZ33kMQoWeJ6Kkjwc0IP8IPQdmXOoPyjsWqXO2sq)ycv5i6f8Zp40fyS(wkOFKoxjhrVGIR)qjq6XuqAq)yk1iuuNWoXD8Krq4r0Q5Yy9W3c92G49HYGU4LkR80mqxRgobcY8XiGDfguIfcs9ojO9pwp8TqVni(PMr6rh3q5(A1EA25krcrXXpFmcyxHbLpwONpuuGF1jStChpzeeEeTAUmwp8TqVniEFOOGA1gRh(wO3ge)uZi9OJBOOOcvFKogetnZ0mS8bmJef7nzqI7yTFCceKP6e0p2KG(kHQCe9c(5hC6cmwFlf0)yPEv9bSRWk1iu(GtxGX65Z0F)(FA25krcrXXpFmcyxHbLpwO3nkqOQkIH2Cu5JexmnbSbOeJel1RkXOEcgSyQWyGylqmSgfMykm1MyFKJkVyjqlgjwQxvIHwxQ5xS(fJGEkuLJOxWp)GtxGX6BPGE8Cu5JexPgHcobcYKMHilmdwxuZn4NFKJk(qX3(XjqqMpwQxvfDcg8eYEzdEFOCn)4eiiZhl1RQcUl18pjO9)0SZvIeIIJF(yeWUcdkFSqVBOCnHQCe9c(5hC6cmwFlf0)yTALAekr6yqmbnkS4J0vHHtgK4ow7hsayKfIINrdUuIvz9OG7sn7)PzNRejefh)8XiGDfgu(yHE34BHQQiMYLwSyf7AIfjefhVy1dwXOH9ELyvyMwmcAXQ6gOfdnZzfa)Vy4xeBCz4AakXiXs9Q6dyxHNcv5i6f8Zp40fyS(wkO)Xs9Q6dyxHvACz44sKquC8uuuPgHc6uNWoXD8K45cnSxyhxkWnYOxGFnJtGGmrAGUOIZka()jK9Yg83OO)NMDUsKquC8ZhJa2vyq5Jf6DdLR5psikoMr7XLyl6Mvii7Ln49r5fQQIyv9cfJg2lSJlIb3iJEbkjgXZIrIL6v1hWUcl2QMHIrgl0tmvDGjgAw5iwIkBWhIrqlwSIPaXIeIIJxSfkwJiwvJMfRFXGeaqdqj2IGiw9lqSeCrS0BjaHylIyrcrXXFLqvoIEb)8doDbgRVLc6FSuVQ(a2vyLAekQtyN4oEs8CHg2lSJlf4gz0lWF9AgNabzI0aDrfNva8)ti7Ln4VrXA1I0XGyQIt6f4LFWWjdsChR9)0SZvIeIIJF(yeWUcdkFSqVBOOGReQYr0l4NFWPlWy9Tuq)Jra7kmO8Xc9uQrO80SZvIeIIJ3hkx726XjqqMbgxGBemysqxRgKaWilefpZkzc7V8lHRGatuEmiQv75OGVaIFgndVNAwUNECL)6XjqqM)fp819LfPO5mWkjrSdyhtc6A1qhobcYKgYESUJm6fmjORv7PzNRejefhVpu89vcvvrmsSuVQ(a2vyXIvmiJa5htSQUbAXqZCwbW)lwc0IfRym4jGSyQyXgjqSrcHxeBvZqXsXqiCoXQA0SyniwXcmwmaRSqmYL6I1iIrV)34oEkuLJOxWp)GtxGX6BPG(hl1RQpGDfwPgHIMXjqqMinqxuXzfa))eYEzd(BOOyTAJDD6vfy(x8Wx3xwKIMZaBczVSb)nksn9RzCceKjsd0fvCwbW)pHSx2G)MXUo9Qcm)lE4R7llsrZzGnHSx2GxOkhrVGF(bNUaJ13sb9OC76H7snRuJqbNabzsZqKfMbRlQ5g8ZpYrfFO4B)JfOj6ysZqKfMbRlQ5g8tycQ4dffVMqvoIEb)8doDbgRVLc6FSuVQ(a2vyHQCe9c(5hC6cmwFlf0pW4KU8yBOuJqbDrcrXXS)c((V)X6HVf6TbXp1msp6Whkk6hNabz(yBuAqjW4IoHvMe0(zadrDzgThxITOaF5dQHE6Lk7q(084C39kVIN4eNda]] )

    
end
