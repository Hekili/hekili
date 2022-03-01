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


    spec:RegisterPack( "Subtlety", 20220228, [[di15qcqiiLEKKeBIQQpjjLrjPQtPsYQKKu5vQumlsKBrcYUu0VGu1Wir1XiHwMkv9mvkzAiP6AuvQTjjjFtLsPXHKcNtLsrRdjf9oifuAEQK6EiX(OQ4FuvIYbHuKfcPYdLKQjscCrKuQSrQkPpsvjYirsPQtcPaRej5LuvIQzIKsUPKKYovPYpvPuyOKGAPQuQEkIMQKkxLQsyRiPu(kKIASqk0zHuq1EvXFLyWuoSOfdvpwHjtQlJAZq8ziz0q50sTAifKxljMnvUnvz3a)wPHJuhxssvlh0Zv10fUocBNK67KKXtIY5vjwpKckMVKY(j(O4PUdPod(C39k)(7v(TuUItLRCL7BQFBEiJl08HKohvsu8HeKE8HKKapCCC5qsNxCBQp1Di)Lao4djwe0p1e9Ohvhye4ZX6H(V9iCz0lyatKa9F7nq)HeNODbAa4GFi1zWN7Ux53FVYVLYvCQCLR87Vf14qMeb2cpKKTx1pKyTwZGd(HuZ)4qssGhooUi2TVOiyHkFLXHej8Iy3tnusS7v(93lujuvDSeGIFQPqLcjwvBvZIPoHDI74jXZfAyVWoUuGBKrVaXiOf7xX6qS(f75qmCgzHSyQyXiEwSoMcvkKyvF9WBalMhHlAAhl2iDUsoIEbfx)HymiGn)IfRyqwtmyXO3GbrNoXGSQfwzkuPqIv1YkSy(QJFSbmrcXAqWqibDiwdeBSE4ziwJiMkwm0qeFiMU1I1Hyilum1RlJ2XLFDQzqmpKU(J)u3H8doDbgRp1DUtXtDhsgK4owFq3HuZ)a20rVGdjAaIyKbNUad9Qtq)yILqwmcALeJ4zXiXs9Q6dyxHflwXWzaJ0HyiW1tSaJfJo)VvZIHVaIxSeOfZxBGwm0mNva8)kjgRMbI1iIPIflHSyziMxQmXQUclw9eah)VyeFdqjwvl)GHIHM(p)VbxDihWoyyNhY6fdNabz(bNUaBsqlwTAIHtGGmvNG(XMe0IDLy(fREXEA25krcrXXpFmcyxHbLpwONyxlg1fRwnXuNWoXD8K45cnSxyhxkWnYOxGyxjMFX8Ypyyj)p)Vbfi7Ln4fJIyk)qMJOxWH8Xs9Q6dyxHpX5U7p1DizqI7y9bDhsn)dyth9coK(Ad6htSmeJ63iw1vyXu1b2seIPasLeZ33iMQoWetbKkjwc0IvvIPQdmXuaPyjsWqXO2sq)yhYCe9coKJ05k5i6fuC9hhYbSdg25HuDc7e3XtgbHhrRMlJ1dFl0BdIxmFOi2GU4LkR80mqlwTAIHtGGmFmcyxHbLyHGuVtcAX8l2y9W3c92G4NAgPhDi21ue7EXQvtSNMDUsKquC8ZhJa2vyq5Jf6jMpueJ6I5xm1jStChpzeeEeTAUmwp8TqVniEX8HIyuxSA1eBSE4BHEBq8tnJ0Joe7AkIPOykKy1lwKogetnZ0mS8bmJef7nzqI7yTy(fdNabzQob9JnjOf7QdPR)Oasp(qI0G(XoX5UBDQ7qYGe3X6d6oKdyhmSZd5hC6cmwpFM(7xm)I90SZvIeIIJF(yeWUcdkFSqpXUwmQFiZr0l4q(yPEv9bSRWN4Ch1p1DizqI7y9bDhsn)dyth9coKOlhv(iXfttaBakXiXs9QsmfKGblMkmgi2cedRrHjMctTj2h5OYlwc0IrIL6vLyOZLA(fRFXiONhYbSdg25HeNabzsZqKfMbRlQ5g8ZpYrfX8HIy(wm)IHtGGmFSuVQk6em4jK9Yg8I5dfXULy(fdNabz(yPEvvWDPM)jbTy(f7PzNRejefh)8XiGDfgu(yHEIDnfXU1HmhrVGdjEoQ8rIFIZD((u3HKbjUJ1h0DihWoyyNhYiDmiMGgfw8r6QWWjdsChRfZVyqcaJSqu8mAWLsSkRhfCxQ5jdsChRfZVypn7CLiHO44NpgbSRWGYhl0tSRfZ3hYCe9coKpwR(eN7QQtDhsgK4owFq3HmhrVGd5JL6v1hWUcFihxgoUejefh)5ofpKdyhmSZdjAftDc7e3XtINl0WEHDCPa3iJEbI5xmnJtGGmrAGUOIZka()jK9Yg8IDTykkMFXEA25krcrXXpFmcyxHbLpwONyxtrSBjMFXIeIIJz0ECj2IUzXuiXGSx2GxmFeRQoKA(hWMo6fCi9f0IfRy3sSiHO44fREWkgnS3ReRcZ0IrqlMV2aTyOzoRa4)fd)IyJldxdqjgjwQxvFa7k88eN7UTN6oKmiXDS(GUdPM)bSPJEbhsFDHIrd7f2XfXGBKrVaLeJ4zXiXs9Q6dyxHfBvZqXiJf6jMQoWednx1elrLn4dXiOflwXOUyrcrXXl2cfRreZxrZI1VyqcaObOeBrqeR(fiwcUiw6TeGqSfrSiHO44V6qoGDWWopKQtyN4oEs8CHg2lSJlf4gz0lqm)IvVyAgNabzI0aDrfNva8)ti7Ln4f7AXuuSA1elshdIPkoPxGx(bdNmiXDSwm)I90SZvIeIIJF(yeWUcdkFSqpXUMIyuxSRoK5i6fCiFSuVQ(a2v4tCUJACQ7qYGe3X6d6oKdyhmSZd5tZoxjsikoEX8HIy3sSBeREXWjqqMbgxGBemysqlwTAIbjamYcrXZSsMW(l)s4kiWeLhdIjdsChRfRwnXEok4lG4NrZW7PgL7PhIDLy(fREXWjqqM)fp819LfPO5mWkjrSdyhtcAXQvtm0kgobcYKgYESUJm6fmjOfRwnXEA25krcrXXlMpueZ3ID1HmhrVGd5Jra7kmO8Xc9oX5UBZtDhsgK4owFq3HuZ)a20rVGdjjwQxvFa7kSyXkgKrG8JjMV2aTyOzoRa4)flbAXIvmg8eqwmvSyJei2iHWlITQzOyPyieoNy(kAwSgeRybglgGvwig5QaXAeXO3)BChppKdyhmSZdPMXjqqMinqxuXzfa))eYEzdEXUMIykkwTAIn21PxvG5FXdFDFzrkAodSjK9Yg8IDTyksneZVyAgNabzI0aDrfNva8)ti7Ln4f7AXg760RkW8V4HVUVSifnNb2eYEzd(dzoIEbhYhl1RQpGDf(eN7uu5N6oKmiXDS(GUd5a2bd78qItGGmPziYcZG1f1Cd(5h5OIy(qrmFlMFXglqt0XKMHilmdwxuZn4NWeurmFOiMI36qMJOxWHeLBxpCxQ5tCUtrfp1DiZr0l4q(yPEv9bSRWhsgK4owFq3jo3P49N6oKmiXDS(GUd5a2bd78qIwXIeIIJz)f89FX8l2y9W3c92G4NAgPhDiMpuetrX8lgobcY8X2O0GsGXfDcRmjOfZVymGHOUmJ2JlXwOUYfZhXqn0tVuzhYCe9coKdmoPlp2gN4ehsnJKeU4u35ofp1DiZr0l4qwPhvoKmiXDS(GUtCU7(tDhsgK4owFq3HCPpKphhYCe9coKQtyN4o(qQoDe8HeNabz(UEWLeOl6EWtcAXQvtSNMDUsKquC8ZhJa2vyq5Jf6jMpueRQoKA(hWMo6fCi9fpRflwX0CWqVgWIPcJdmgk2yxNEvbEXuLDigYcfJeOaXWZN1ITaXIeIIJFEivNWci94d5d0LXc0D0l4eN7U1PUdjdsChRpO7qU0hYNJdzoIEbhs1jStChFivNoc(qItGGmFxp4sc0fDp4jbTy1Qj2tZoxjsiko(5Jra7kmO8Xc9eZhkIvvhs1jSasp(q(aDzSaDh9coX5oQFQ7qYGe3X6d6oKl9H854qMJOxWHuDc7e3Xhs1jSasp(q2FbWklkd6scAVCGLquS(qoGDWWopKJvndsqmRCb2j4qQ5FaB6OxWHS6y8OIyXk2ZSynIybglgGvwiw1vyXQVbIfySySAgeITiILIrIvNy0WDCLy9lgAc0E5alHOy9HuD6i4d5y9W3c92G4fJIykkMFXWjqqM8aBBaQcKPHTxc0L7Ne0IvRMyJ1dFl0BdIxmkIDVy(fdNabzYdSTbOkqMg2EjqxU1KGwSA1eBSE4BHEBq8IrrSBjMFXWjqqM8aBBaQcKPHTxc0fQpjOfRwnXgRh(wO3geVyueJ6I5xmCceKjpW2gGQazAy7LaDX3tc6tCUZ3N6oKmiXDS(GUd5sFiFooK5i6fCivNWoXD8HuD6i4djJGWJOvZLX6HVf6TbXFi18pGnD0l4qIMgJLaeIHSqXiXQtmiNJOxGyr7XIHFrSgfyHnaLyUvLcvDfwSe0E5alHOyTyEzmW4xSgiwGXIP8PVFXOH8GzDdqjwkg9gmi60jgjwDIrd3XHuDclG0JpKmccpIwnxgRh(wO3ge)jo3vvN6oKmiXDS(GUd5sFiFooK5i6fCivNWoXD8HuD6i4d5y9W3c92G4pKdyhmSZd5yvZGeeZkxGDceZVymccpIwnxgRh(wO3geVy(i2y9W3c92G4fZVyJ1dFl0BdIFQzKE0Hy(i29I5xSO94sSLhlk0oIFsDXUwmLp9Ty(fdTIPoHDI74z)faRSOmOljO9YbwcrX6dP6ewaPhFizeeEeTAUmwp8TqVni(tCU72EQ7qYGe3X6d6oKA(hWMo6fCiRogpQiw1vWlwgIH0WpoK5i6fCihPZvYr0lO46poKU(Jci94d5q)N4Ch14u3HKbjUJ1h0Di18pGnD0l4qIMOPDxeJ01dwSeOftb9GfldXU)gXQUclMMa2auIfySyin8dXuu5I98yb6xjXsKGHIfyzig1VrSQRWI1iI1HySYOBi)IPQdSgiwGXIbyLfI5lvDfi2cfRFXaBigb9HCa7GHDEiFA25krcrXXpFmcyxHbLpwONyxlwvjMFXqAuyrbYEzdEX8rSQsm)IHtGGmFxp4sc0fDp4jK9Yg8IDTyOg6PxQmX8l2y9W3c92G4fZhkIrDXuiXQxSO9yXUwmfvUyxjwvNy3FiZr0l4q(UEWLeOl6EWN4C3T5PUdjdsChRpO7qQ5FaB6OxWH82jaIHq4Cxe7v1XaJFXIvSaJfJm40fySwSBFJm6fiw94xetVnaLy)QKyDigYch8lg9UUgGsSgrmWgynaLy9lwQoBxI74RMhYCe9coKqcqjhrVGIR)4q(bShX5ofpKdyhmSZd5hC6cmwptN7q66pkG0JpKFWPlWy9jo3POYp1DizqI7y9bDhYL(q(CCiZr0l4qQoHDI74dP60rWhsAyVWoUuGBKrVaX8l2tZoxjsiko(5Jra7kmO8Xc9eZhkID)HuZ)a20rVGd5TbWDrSbwcqXIb3iJEbI1iIPIfdlvZIrd7f2XLcCJm6fi2ZHyjqlMhHlAAhlwKquC8IrqppKQtybKE8HK45cnSxyhxkWnYOxWjo3POIN6oKmiXDS(GUdPM)bSPJEbhsfg2lSJlID7BKrVaFzIrT4OAVyOA1SyPydyslwIVeHymGHOUigYcflWyX(GtxGjw1vWlw94eTtZqX(ODoXG8tZJqSoUAkgA4e0kjwhInsGy4SybwgI9ThTJNhYCe9coKJ05k5i6fuC9hhYpG9io3P4HCa7GHDEivNWoXD8K45cnSxyhxkWnYOxWH01FuaPhFi)GtxGvg6)eN7u8(tDhsgK4owFq3HuZ)a20rVGdz1xW3AgkgX3auILIrgC6cmXQUcetfgdedY5aRbOelWyXyadrDrSadYp260hYCe9coKJ05k5i6fuC9hhYbSdg25HKbme1LPMr6rhIDnfXuNWoXD88doDbwjWG8JTo9H01FuaPhFi)GtxGvg6)eN7u8wN6oKmiXDS(GUdPM)bSPJEbhsFTb9JjwgI5LktjXO(nIPQdSLietbKITqXu1bMyKRceBa7qmCceeLeZ33iMQoWetbKIv)seFRzX(GtxGDLsIPQdmXuaPyP7xXqAq)yILHyu)gXsuzd(qmQlwKquC8Iv)seFRzX(GtxGD1HmhrVGd5iDUsoIEbfx)XHCa7GHDEivNWoXD8Krq4r0Q5Yy9W3c92G4fZhkInOlEPYkpnd0IvRMyJ1dFl0BdIFQzKE0HyxtrmffRwnXqAuyrbYEzdEXUMIykkMFXuNWoXD8Krq4r0Q5Yy9W3c92G4fZhkIDlXQvtmCceK5FXdFDFzrkAodSsse7a2XKGwm)IPoHDI74jJGWJOvZLX6HVf6TbXlMpueJ6IvRMypn7CLiHO44NpgbSRWGYhl0tmFOig1fZVyQtyN4oEYii8iA1CzSE4BHEBq8I5dfXO(H01FuaPhFirAq)yN4CNIu)u3HKbjUJ1h0Di18pGnD0l4q6lEwSumCI2PzOyQWyGyqohynaLybglgdyiQlIfyq(XwN(qMJOxWHCKoxjhrVGIR)4qoGDWWopKmGHOUm1msp6qSRPiM6e2jUJNFWPlWkbgKFS1PpKU(Jci94djor70N4CNI((u3HKbjUJ1h0Di18pGnD0l4qsTwv8hIrd7f2XfXAGyPZj2IiwGXIHMuyQLy48ijEwSoeBKep)ILI5lvDfCihWoyyNhsgWquxMAgPhDiMpuetrFl2nIXagI6YeYOyWHmhrVGdzchjGlXcHmioX5ofRQtDhYCe9coKjCKaUqt4E(qYGe3X6d6oX5ofVTN6oK5i6fCiDnkS4lOHi0O8yqCizqI7y9bDN4CNIuJtDhYCe9coK4jQYIucypQ8hsgK4owFq3joXHKgYJ1dpJtDN7u8u3HmhrVGdzst7UuO3(xWHKbjUJ1h0DIZD3FQ7qMJOxWHeFJWX6cIlVWAvnavjwL1GdjdsChRpO7eN7U1PUdjdsChRpO7qoGDWWopK)s4WBGEst8bHJlmKGo6fmzqI7yTy1Qj2Veo8gONQxxgTJl)6uZGyYGe3X6dzoIEbhseh)ydyIeN4Ch1p1DiZr0l4q(bNUa7qYGe3X6d6oX5oFFQ7qYGe3X6d6oK5i6fCi9syfwxqwyrZzGDiPH8y9WZO88yb6)qQOVpX5UQ6u3HKbjUJ1h0DiZr0l4q(UEWLeOl6EWhYbSdg25HeYiq(XsChFiPH8y9WZO88yb6)qQ4jo3DBp1DizqI7y9bDhYbSdg25HesayKfIINEjSszrkbgx8Ypyyj)p)VbtgK4owFiZr0l4q(yPEvvWDPM)tCIdjor70N6o3P4PUdjdsChRpO7qoGDWWopKOvSiDmiMGgfw8r6QWWjdsChRfZVyqcaJSqu8mAWLsSkRhfCxQ5jdsChRfZVypn7CLiHO44NpgbSRWGYhl0tSRfZ3hYCe9coKpwR(eN7U)u3HKbjUJ1h0DihWoyyNhYNMDUsKquC8I5dfXUxm)IvVyOvSXQMbjiMaEax3c1IvRMyJDD6vfy(meMbRl4lGlpDxHNEPYkdSeIIFXuiXgyjef)feyoIEbPtmFOiMYN37BXQvtSNMDUsKquC8ZhJa2vyq5Jf6jMpIrDXUsm)IvVy4eiitAgISWmyDrn3GF(roQi21ueJ6IvRMypn7CLiHO44NpgbSRWGYhl0tmFeJ6ID1HmhrVGd5Jra7kmO8Xc9oX5UBDQ7qYGe3X6d6oKdyhmSZdjobcYKMHilmdwxuZn4NFKJkIDnfXUxm)IvVyJDD6vfy(meMbRl4lGlpDxHNEPYkdSeIIFXuiXgyjef)feyoIEbPtSRPiMYN37BXQvtSFjC4nqpDCQl4xkSYspAhpzqI7yTy(fdTIHtGGmDCQl4xkSYspAhpjOfRwnX(LWH3a9ScRUbFzx0WWUgGAYGe3XAX8lgAftZ4eiiZkS6g8fvWmWMe0ID1HmhrVGd5ZqygSUGVaU80Df(eN7O(PUdzoIEbhsuUD9WDPMpKmiXDS(GUtCUZ3N6oKmiXDS(GUdPM)bSPJEbhs0LJkFK4I1EESUZGDxeJa44)flWyXaSYcXQUclw)IHMaTxoWsikwlwc0IPIft1cQwi2iPfJbme1fXuLD0auIHSqX6yEihWoyyNhs0k2yvZGeeZkxGDceRwnXqRy1lM6e2jUJN9xaSYIYGUKG2lhyjefRfZVy1lw0ECj2YJffAhXpVLyxlMYN(wSA1elApUeB5XIcTJ4NuxSRftrXUsm)IXagI6IyxlwvPCXU6qMJOxWHephv(iXpXjoKd9FQ7CNIN6oKmiXDS(GUd5a2bd78qIwXWjqqMpwQxvfDcg8KGwm)IHtGGmFmcyxHbLyHGuVtcAX8lgobcY8XiGDfguIfcs9oHSx2GxSRPi2TM((qs8CzrqkOg6ZDkEiZr0l4q(yPEvv0jyWhsn)dyth9coK(INftbjyWITiikeQHwmCgzHSybglgsd)qmsmcyxHbIrgl0tme46jwDleK6vSX6XVynyEIZD3FQ7qYGe3X6d6oKdyhmSZdjobcY8XiGDfguIfcs9ojOfZVy4eiiZhJa2vyqjwii17eYEzdEXUMIy3A67djXZLfbPGAOp3P4HmhrVGd5FXdFDFzrkAodSdPM)bSPJEbhY69fah)VyPdYP(Iye0IHZJK4zXuXIf7wrmsSuVQeZx3bXFLyeplg5fp819ITiikeQHwmCgzHSybglgsd)qmsmcyxHbIrgl0tme46jwDleK6vSX6XVynyEIZD36u3HKbjUJ1h0DihWoyyNhs1jStChpFGUmwGUJEbI5xm0k2hC6cmwp9sq4yX8lw9I90SZvIeIIJF(yeWUcdkFSqpXUMIykkMFXg760RkW8V4HVUVSifnNb2KGwm)IHwXI0XGy(yPEvvq2bXpzqI7yTy1QjgobcY8V4HVUVSifnNb2KGwSReZVyJ1dFl0BdIxmFOiMVpK5i6fCirCjk25YOxWjo3r9tDhsgK4owFq3HCa7GHDEiRxmibGrwikE6LWkLfPeyCXl)GHL8)8)gmzqI7yTy(fBSE4BHEBq8tnJ0Joe7AkIPOykKyr6yqm1mtZWYhWmyuS3KbjUJ1IvRMyqcaJSqu8uZzG5UuESuVQ(jdsChRfZVyJ1dFl0BdIxSRftrXUsm)IHtGGm)lE4R7llsrZzGnjOfZVy4eiiZhl1RQIobdEsqlMFX8Ypyyj)p)Vbfi7Ln4fJIykxm)IHtGGm1CgyUlLhl1RQFQxvGdzoIEbhs1jOFStCUZ3N6oKmiXDS(GUdPM)bSPJEbhsfExNyiluS6wii1Ry0qwHixfiMQoWeJetbIb5uFrmvymqmWgIbjaGgGsmsFDEirwybWklo3P4HCa7GHDEiJ0XGy(yeWUcdkXcbPENmiXDSwm)IHwXI0XGy(yPEvvq2bXpzqI7y9HmhrVGdj9UUcK)Lao4tCURQo1DizqI7y9bDhsn)dyth9coK(INfRUfcs9kgnKfJCvGyQWyGyQyXWs1SybglgdyiQlIPcJdmgkgcC9eJExxdqjMQoWwIqmsFvSfkgAiIpedfdyy6CxMhYbSdg25H8PzNRejefh)8XiGDfgu(yHEIDnfXuum)IXagI6Iy(qrSQs5I5xm1jStChpFGUmwGUJEbI5xSXUo9Qcm)lE4R7llsrZzGnjOfZVyJDD6vfy(yPEvv0jyWZbwcrXVy(qrmffZVy1lgAfdsayKfIINloRBgm4jdsChRfRwnX0mobcYeXLOyNlJEbtcAXQvtSNMDUsKquC8ZhJa2vyq5Jf6jMpueREXuuSBeJ6Iv1jw9IHwXI0XGycAuyXhPRcdNmiXDSwm)IHwXI0XGyQtyLYJL6v1KbjUJ1IDLyxj2vI5xSX6HVf6TbXl21ue7EX8lgAfdNabzsdzpw3rg9cMe0I5xS6fdTInw1mibXundcSlqXQvtm0k2yxNEvbMiUef7Cz0lysql2vhYCe9coKpgbSRWGsSqqQ3tCU72EQ7qYGe3X6d6oK5i6fCiFgcZG1f8fWLNURWhYbSdg25HuDc7e3XZhOlJfO7OxGy(fdTIP3y(meMbRl4lGlpDxHl6nMrpQ0auI5xSiHO4ygThxITOBwmFOi29kkMFXQxSX6HVf6TbXp1msp6qmFOiw9InOlOYgiMp(YeJ6IDLyxjMFXqRy4eiiZhJa2vyqjwii17KGwm)IvVyOvmCceKjnK9yDhz0lysqlwTAI90SZvIeIIJF(yeWUcdkFSqpX8rmQl2vIvRMyinkSOazVSbVyxtrmFlMFXEA25krcrXXpFmcyxHbLpwONyxl2ToKJldhxIeIIJ)CNIN4Ch14u3HKbjUJ1h0DihWoyyNhs1jStChpFGUmwGUJEbI5xSX6HVf6TbXp1msp6qmFOiMII5xSiHO4ygThxITOBwmFOiMIv1HmhrVGd5Z0F)N4C3T5PUdjdsChRpO7qQ5FaB6OxWH0x8SyKx8Wx3l2ceBSRtVQaIvFIemumKg(HyKafCLyeah)VyQyXsilgQTbOelwXOxAXQBHGuVILaTy6vmWgIHLQzXiXs9QsmFDhe)8qoGDWWopKQtyN4oE(aDzSaDh9ceZVy1lgAflshdI5Jra7kmOeleK6DYGe3XAXQvtSiDmiMpwQxvfKDq8tgK4owlwTAI90SZvIeIIJF(yeWUcdkFSqpX8HIy3lwTAIn21PxvG5Jra7kmOeleK6DczVSbVy(i29IDLy(fREXqRyJvndsqmvZGa7cuSA1eBSRtVQatexIIDUm6fmHSx2GxmFetrLlwTAIn21PxvGjIlrXoxg9cMe0I5xSX6HVf6TbXlMpueZ3ID1HmhrVGd5FXdFDFzrkAodStCUtrLFQ7qYGe3X6d6oK5i6fCi9syfwxqwyrZzGDiDnGld9HuXPVpKJldhxIeIIJ)CNIhYbSdg25HeMTUWQzqmtT(Ne0I5xS6flsikoMr7XLyl6Mf7AXgRh(wO3ge)uZi9OdXQvtm0k2hC6cmwptNtm)Inwp8TqVni(PMr6rhI5dfXg0fVuzLNMbAXU6qQ5FaB6OxWHenarSuRFXsilgbTsI9GMMflWyXwalMQoWeZTQ4peRU6uWumFXZIPcJbIPV0auIHKFWqXcSeiw1vyX0msp6qSfkgydX(GtxGXAXu1b2seILGlIvDfEEIZDkQ4PUdjdsChRpO7qQ5FaB6OxWHenarmWkwQ1VyQANtmDZIPQdSgiwGXIbyLfIDlL)kjgXZIv1quGylqm89FXu1b2seILGlIvDfEEihWoyyNhsy26cRMbXm16F2aX8rSBPCXuiXGzRlSAgeZuR)PMaMrVaX8l2y9W3c92G4NAgPhDiMpueBqx8sLvEAgOpK5i6fCi9syfwxqwyrZzGDIZDkE)PUdjdsChRpO7qoGDWWopKQtyN4oE(aDzSaDh9ceZVyJ1dFl0BdIFQzKE0Hy(qrS7fZVy1lgobcY8V4HVUVSifnNb2KGwSA1edF)xm)IH0OWIcK9Yg8IDnfXUx5IvRMyOvmCceK5JL6vvb3LA(Ne0I5xSNJc(ci(z0m8EQr5E6HyxDiZr0l4q(yPEvvWDPM)tCUtXBDQ7qYGe3X6d6oKdyhmSZdjAf7doDbgRNPZjMFXuNWoXD88b6Yyb6o6fiMFXgRh(wO3ge)uZi9OdX8HIy3lMFXQxm1jStChpjEUqd7f2XLcCJm6fiwTAI90SZvIeIIJF(yeWUcdkFSqpXUMIyuxSA1edsayKfIINq(xcGUbOkdxc74YKbjUJ1ID1HmhrVGdjpW2gGQazAy7La9jo3Pi1p1DizqI7y9bDhsn)dyth9coKO5oWeJ0xvsSgrmWgILoiN6lIPxaRKyeplwDleK6vmvDGjg5QaXiONhYbSdg25HSEXI0XGy(yPEvvq2bXpzqI7yTy1Qj2tZoxjsiko(5Jra7kmO8Xc9eZhkIDVyxjMFXuNWoXD88b6Yyb6o6fiMFXWjqqM)fp819LfPO5mWMe0I5xSX6HVf6TbXl21ue7EX8lw9IHwXWjqqM0q2J1DKrVGjbTy1Qj2tZoxjsiko(5Jra7kmO8Xc9eZhXOUyxDiZr0l4q(yeWUcdkXcbPEpX5of99PUdjdsChRpO7qoGDWWopKOvmCceK5JL6vvrNGbpjOfZVyinkSOazVSbVyxtrmQHy3iwKogeZNapyicbkEYGe3X6dzoIEbhYhl1RQIobd(eN7uSQo1DizqI7y9bDhYbSdg25HSEX(LWH3a9KM4dchxyibD0lyYGe3XAXQvtSFjC4nqpvVUmAhx(1PMbXKbjUJ1IDLy(fJbme1LPMr6rhI5dfXULYfZVyOvSp40fySEMoNy(fdNabz(x8Wx3xwKIMZaBQxvGdzdcgcjOJsJCi)LWH3a9u96YODC5xNAgehYgemesqhL2ZJ1Dg8HuXdzoIEbhseh)ydyIehYgemesqhfuUfpDhsfpX5ofVTN6oKmiXDS(GUd5a2bd78qItGGmXD7QDeFmHCocXQvtmKgfwuGSx2GxSRf7wkxSA1edNabz(x8Wx3xwKIMZaBsqlMFXQxmCceK5JL6vvb3LA(Ne0IvRMyJDD6vfy(yPEvvWDPM)jK9Yg8IDnfXuu5ID1HmhrVGdj9g9coX5ofPgN6oKmiXDS(GUd5a2bd78qItGGm)lE4R7llsrZzGnjOpK5i6fCiXD7QlieWlN4CNI3MN6oKmiXDS(GUd5a2bd78qItGGm)lE4R7llsrZzGnjOpK5i6fCiXz4ZWkna1jo3DVYp1DizqI7y9bDhYbSdg25HeNabz(x8Wx3xwKIMZaBsqFiZr0l4qI0qg3TR(eN7UxXtDhsgK4owFq3HCa7GHDEiXjqqM)fp819LfPO5mWMe0hYCe9coKjyWFatxzKo3jo3D)9N6oKmiXDS(GUdPM)bSPJEbhsfWijHledjDo8CurmKfkgXN4owSoyVNAkMV4zXu1bMyKx8Wx3l2IiMc4mWMhYbSdg25HeNabz(x8Wx3xwKIMZaBsqlwTAIH0OWIcK9Yg8IDTy3R8dzoIEbhsINlDWE)joXH8doDbwzO)tDN7u8u3HKbjUJ1h0Dix6d5ZXHmhrVGdP6e2jUJpKQthbFih760RkW8Xs9QQOtWGNdSeII)ccmhrVG0jMpuetX5T13hsn)dyth9coKu7zhndfJAlHDI74dP6ewaPhFiFmDjWG8JTo9jo3D)PUdjdsChRpO7qQ5FaB6OxWHKAlb9JjwJiMkwSeYInsA6gGsSfiMcsWGfBGLqu8pfJAxcDxedNrwilgsd)qmDcgSynIyQyXWs1SyGvS7AuyXhPRcdfdNietbjSIyKyPEvjwdeBHAgkwSIHIdXUDc6GaYIrqlw9GvSQw(bdfdn9F(FdUAEihWoyyNhY6fdTIPoHDI745JPlbgKFS1PfRwnXqRyr6yqmbnkS4J0vHHtgK4owlMFXI0XGyQtyLYJL6v1KbjUJ1IDLy(fBSE4BHEBq8tnJ0JoeZhXuum)IHwXGeagzHO4PxcRuwKsGXfV8dgwY)Z)BWKbjUJ1hYCe9coKQtq)yN4C3To1DizqI7y9bDhsn)dyth9coKk8UoXqwOyKyPEv5XoTy3igjwQxvFa7kSyeah)VyQyXsilwIVeHyXk2iPfBbIPGemyXgyjef)tXUnaUlIPcJbI5RnqlgAMZka(FX6xSeFjcXIvmibqSLiMhsKfwaSYIZDkEihWoyyNhsyo4jOrHff2HCizLfWSKElbioKux5hYCe9coK076kq(xc4GpX5oQFQ7qYGe3X6d6oKdyhmSZdjdyiQlI5dfXOUYfZVymGHOUm1msp6qmFOiMIkxm)IHwXuNWoXD88X0LadYp260I5xSX6HVf6TbXp1msp6qmFetXdzoIEbhYhl1Rkp2PpX5oFFQ7qYGe3X6d6oKl9H854qMJOxWHuDc7e3Xhs1PJGpKJ1dFl0BdIFQzKE0Hy(qrS7f7gXWjqqMpwQxvfCxQ5FsqFi18pGnD0l4qwDfwSadYp260VyilumgemSbOeJel1RkXuqcg8HuDclG0JpKpMUmwp8TqVni(tCURQo1DizqI7y9bDhYL(q(CCiZr0l4qQoHDI74dP60rWhYX6HVf6TbXp1msp6qmFOi2ToKdyhmSZd5yvZGeeZkxGDcoKQtybKE8H8X0LX6HVf6TbXFIZD32tDhsgK4owFq3HCPpKphhYCe9coKQtyN4o(qQoDe8HCSE4BHEBq8tnJ0Joe7AkIP4HCa7GHDEivNWoXD8K45cnSxyhxkWnYOxGy(f7PzNRejefh)8XiGDfgu(yHEI5dfXO(HuDclG0JpKpMUmwp8TqVni(tCUJACQ7qYGe3X6d6oKA(hWMo6fCivqcgSyAcydqjg5fp819ITqXs8vnlwGb5hBD65HCa7GHDEiRxS6ftDc7e3XZhtxgRh(wO3geVy1QjM6e2jUJNpMUeyq(XwNwSReZVyphf8fq8ZOz49uJY90dX8l2yvZGeeZkxGDceRwnXuNWoXD88X0LX6HVf6TbXlMFXQxmCceK5FXdFDFzrkAodSjK9Yg8I5dfXuCEVy1QjM6e2jUJNpMUeyq(XwNwSReRwnXWjqqMdSC)cEc4jbTy1Qj2tZoxjsiko(5Jra7kmO8Xc9eZhkIrDX8l2yxNEvbM)fp819LfPO5mWMq2lBWlMpIPOYf7kX8lw9IHtGGmPziYcZG1f1Cd(5h5OIyxlg1fRwnXEA25krcrXXpFmcyxHbLpwONy(i2Te7QdzoIEbhYhl1RQIobd(eN7Unp1DizqI7y9bDhsn)dyth9coKOJacetbjyWVydSeIIFXAeXUSeIr7YlIPGewrmsSuVQE0JMC5a2XfXwOy4mYczXcmwmKgfwigd0VynIyKRcet1cQwigolgKt9fXAGyr7XZd5a2bd78qQoHDI745JPlJ1dFl0BdIxm)IH0OWIcK9Yg8IDTyJDD6vfy(x8Wx3xwKIMZaBczVSbVy1QjgAflshdIjduZULUbOkpwQxv)KbjUJ1hYCe9coKpwQxvfDcg8joXHePb9JDQ7CNIN6oKmiXDS(GUd5sFiFooK5i6fCivNWoXD8HuD6i4dzKogetAi7X6oYOxWKbjUJ1I5xSNMDUsKquC8ZhJa2vyq5Jf6j21IvVy(wmfsSXQMbjiMaEax3c1IDLy(fdTInw1mibXSYfyNGdPM)bSPJEbhs0mw7yXi(gGsmfgYESUJm6fOKyP6T1InYpAakXiD9GflbAXuqpyXuHXaXiXs9QsmfKGblw)I97celwXWzXiEwRKySYgmDigYcfZx(fyNGdP6ewaPhFiPHShRlpqxglq3rVGtCU7(tDhsgK4owFq3HCa7GHDEirRyQtyN4oEsdzpwxEGUmwGUJEbI5xSNMDUsKquC8ZhJa2vyq5Jf6j21IvvI5xm0kgobcY8Xs9QQOtWGNe0I5xmCceK576bxsGUO7bpHSx2GxSRfdPrHffi7Ln4fZVyqgbYpwI74dzoIEbhY31dUKaDr3d(eN7U1PUdjdsChRpO7qoGDWWopKQtyN4oEsdzpwxEGUmwGUJEbI5xSXUo9QcmFSuVQk6em45alHO4VGaZr0liDIDTykoVT(wm)IHtGGmFxp4sc0fDp4jK9Yg8IDTyJDD6vfy(x8Wx3xwKIMZaBczVSbVy(fREXg760RkW8Xs9QQOtWGNqo1xeZVy4eiiZ)Ih(6(YIu0Cgyti7Ln4ftHedNabz(yPEvv0jyWti7Ln4f7AXuCEVyxDiZr0l4q(UEWLeOl6EWN4Ch1p1DizqI7y9bDhYL(q(CCiZr0l4qQoHDI74dP60rWhsV8dgwY)Z)BqbYEzdEX8rmLlwTAIHwXI0XGycAuyXhPRcdNmiXDSwm)IfPJbXuNWkLhl1RQjdsChRfZVy4eiiZhl1RQIobdEsqlwTAI90SZvIeIIJF(yeWUcdkFSqpX8HIy1lg1ftHe7doDbgRNPZjwvNyr6yqmFSuVQki7G4NmiXDSwSRoKA(hWMo6fCiP2ZoAgkg1wc7e3XIHSqXUDc6GaYtXiR00IPjGnaLyvT8dgkgA6)8)gi2cfttaBakXuqcgSyQ6atmfKWkILaTyGvS7AuyXhPRcdNhs1jSasp(q(vA6cKGoiG8jo357tDhsgK4owFq3HuZ)a20rVGdPVCMPfJGwSBNGoiGSynIyDiw)IL4lriwSIbjaITeX8qoGDWWopKOvSp40fySEMoNy(fREXqRyQtyN4oE(vA6cKGoiGSy1QjM6e2jUJNepxOH9c74sbUrg9ce7kX8lwKquCmJ2JlXw0nlMcjgK9Yg8I5JyvLy(fdYiq(XsChFiZr0l4qcjOdciFIZDv1PUdzoIEbhYNhqokbpWaDvpbFizqI7y9bDN4C3T9u3HKbjUJ1h0DiZr0l4qcjOdciFihxgoUejefh)5ofpKdyhmSZdjAftDc7e3XZVstxGe0bbKfZVyOvm1jStChpjEUqd7f2XLcCJm6fiMFXEA25krcrXXpFmcyxHbLpwONy(qrS7fZVyrcrXXmApUeBr3Sy(qrS6fZ3IDJy1l29Iv1j2y9W3c92G4f7kXUsm)Ibzei)yjUJpKA(hWMo6fCiRAeUO1BenaLyrcrXXlwGLHyQANtmxRMfdzHIfySyAcyg9ceBre72jOdciRKyqgbYpMyAcydqjgDc0SxpMN4Ch14u3HKbjUJ1h0Di18pGnD0l4qE7mcKFmXUDc6GaYIXj0DrSgrSoetv7CIXkJUHSyAcydqjg5fp819tXuWkwGLHyqgbYpMynIyKRcedfhVyqo1xeRbIfySyawzHy((NhYbSdg25HeTIPoHDI745xPPlqc6GaYI5xmi7Ln4f7AXg760RkW8V4HVUVSifnNb2eYEzdEXUrmfvUy(fBSRtVQaZ)Ih(6(YIu0Cgyti7Ln4f7AkI5BX8lwKquCmJ2JlXw0nlMcjgK9Yg8I5JyJDD6vfy(x8Wx3xwKIMZaBczVSbVy3iMVpK5i6fCiHe0bbKpX5UBZtDhsgK4owFq3HCa7GHDEirRyQtyN4oEs8CHg2lSJlf4gz0lqm)I90SZvIeIIJxmFOi2ToK5i6fCiXD5OsHEvPz4jo3POYp1DiZr0l4qYQ7FWWm4djdsChRpO7eN4ehs1m87fCU7ELFVIkEVYPghsvje0au)HenJMU97qdUZxIAkMy1HXI1E0lmedzHIvTp40fySUAIb5QEIgYAX(1JfljI1ldwl2albO4FkurTAalMVPMIv9fOMHbRfRAqcaJSqu8enwnXIvSQbjamYcrXt04KbjUJ1vtS6vuzxnfQOwnGfJAqnfR6lqnddwlw1GeagzHO4jASAIfRyvdsayKfIINOXjdsChRRMy1ROYUAkujuHMrt3(DOb35lrnftS6WyXAp6fgIHSqXQgnKhRhEgvtmix1t0qwl2VESyjrSEzWAXgyjaf)tHkQvdyXUf1uSQVa1mmyTyv7xchEd0t0y1elwXQ2Veo8gONOXjdsChRRMy1ROYUAkurTAal2TOMIv9fOMHbRfRA)s4WBGEIgRMyXkw1(LWH3a9enozqI7yD1eldXO2DBqTeREfv2vtHkQvdyXUTutXQ(cuZWG1IvnibGrwikEIgRMyXkw1GeagzHO4jACYGe3X6QjwgIrT72GAjw9kQSRMcvcvOz00TFhAWD(sutXeRomwS2JEHHyiluSQn0F1edYv9enK1I9RhlwseRxgSwSbwcqX)uOIA1awmQtnfR6lqnddwlw1GeagzHO4jASAIfRyvdsayKfIINOXjdsChRRMy1FVYUAkurTAalwvrnfR6lqnddwlw1GeagzHO4jASAIfRyvdsayKfIINOXjdsChRRMy1ROYUAkurTAalMI3IAkw1xGAggSwSQbjamYcrXt0y1elwXQgKaWilefprJtgK4owxnXQxrLD1uOIA1awmfRkQPyvFbQzyWAXQ2Veo8gONOXQjwSIvTFjC4nqprJtgK4owxnXQ)ELD1uOsOcnJMU97qdUZxIAkMy1HXI1E0lmedzHIvTp40fyLH(RMyqUQNOHSwSF9yXsIy9YG1InWsak(NcvuRgWIDp1uSQVa1mmyTyvdsayKfIINOXQjwSIvnibGrwikEIgNmiXDSUAILHyu7UnOwIvVIk7QPqLqfAgnD73HgCNVe1umXQdJfR9OxyigYcfRA4eTtxnXGCvprdzTy)6XILeX6LbRfBGLau8pfQOwnGftrQPyvFbQzyWAXQgKaWilefprJvtSyfRAqcaJSqu8enozqI7yD1eREfv2vtHkQvdyX8n1uSQVa1mmyTyvlApUeB5XIjACs7i(QjwSIvTO94sSLhlk0oIFIgRMy1FVYUAkujuHg4rVWG1IDBflhrVaXC9h)uO6q(084C39vLIhsA4I0o(qwLQigjbE444Iy3(IIGfQQsveZxzCircVi29udLe7ELF)9cvcvvPkIvDSeGIFQPqvvQIykKyvTvnlM6e2jUJNepxOH9c74sbUrg9ceJGwSFfRdX6xSNdXWzKfYIPIfJ4zX6ykuvLQiMcjw1xp8gWI5r4IM2XInsNRKJOxqX1FigdcyZVyXkgK1edwm6nyq0PtmiRAHvMcvvPkIPqIv1YkSy(QJFSbmrcXAqWqibDiwdeBSE4ziwJiMkwm0qeFiMU1I1Hyilum1RlJ2XLFDQzqmfQeQQsvetHHScv91dpdHQCe9c(jnKhRhEg3qb9jnT7sHE7Fbcv5i6f8tAipwp8mUHc6X3iCSUG4YlSwvdqvIvznqOkhrVGFsd5X6HNXnuqpIJFSbmrcLAek)s4WBGEst8bHJlmKGo6fuR2Veo8gONQxxgTJl)6uZGqOkhrVGFsd5X6HNXnuq)hC6cmHQCe9c(jnKhRhEg3qb9EjScRlilSO5mWuIgYJ1dpJYZJfOFkk6BHQCe9c(jnKhRhEg3qb9VRhCjb6IUhSs0qESE4zuEESa9trrLAekqgbYpwI7yHQCe9c(jnKhRhEg3qb9pwQxvfCxQ5xPgHcKaWilefp9syLYIucmU4LFWWs(F(FdeQeQQsveRQLnqSBFJm6fiuLJOxWtPspQiuvfX8fpRflwX0CWqVgWIPcJdmgk2yxNEvbEXuLDigYcfJeOaXWZN1ITaXIeIIJFkuLJOxWFdf0RoHDI7yLaPht5b6Yyb6o6fOK60rWuWjqqMVRhCjb6IUh8KGUwTNMDUsKquC8ZhJa2vyq5Jf65dLQsOkhrVG)gkOxDc7e3XkbspMYd0LXc0D0lqj1PJGPGtGGmFxp4sc0fDp4jbDTApn7CLiHO44NpgbSRWGYhl0ZhkvLqvveR6y8OIyXk2ZSynIybglgGvwiw1vyXQVbIfySySAgeITiILIrIvNy0WDCLy9lgAc0E5alHOyTqvoIEb)nuqV6e2jUJvcKEmL(lawzrzqxsq7LdSeII1k1iugRAgKGyw5cStGsQthbtzSE4BHEBq8uu0pobcYKhyBdqvGmnS9sGUC)KGUwTX6HVf6TbXt5E)4eiitEGTnavbY0W2lb6YTMe01Qnwp8TqVniEk3YpobcYKhyBdqvGmnS9sGUq9jbDTAJ1dFl0BdINc19JtGGm5b22aufitdBVeOl(EsqluvfXqtJXsacXqwOyKy1jgKZr0lqSO9yXWViwJcSWgGsm3QsHQUclwcAVCGLquSwmVmgy8lwdelWyXu(03Vy0qEWSUbOelfJEdgeD6eJeRoXOH7qOkhrVG)gkOxDc7e3XkbspMcJGWJOvZLX6HVf6TbXRK60rWuyeeEeTAUmwp8TqVniEHQCe9c(BOGE1jStChRei9ykmccpIwnxgRh(wO3geVsncLXQMbjiMvUa7e4Nrq4r0Q5Yy9W3c92G49zSE4BHEBq8(hRh(wO3ge)uZi9OdFU3F0ECj2YJffAhXpP(1kF6B)OvDc7e3XZ(lawzrzqxsq7LdSeII1kPoDemLX6HVf6TbXluvfXQogpQiw1vWlwgIH0WpeQYr0l4VHc6hPZvYr0lO46pucKEmLH(fQQIyOjAA3fXiD9GflbAXuqpyXYqS7VrSQRWIPjGnaLybglgsd)qmfvUyppwG(vsSejyOybwgIr9BeR6kSynIyDigRm6gYVyQ6aRbIfySyawzHy(svxbITqX6xmWgIrqluLJOxWFdf0)UEWLeOl6EWk1iuEA25krcrXXpFmcyxHbLpwO31vLFKgfwuGSx2G3NQYpobcY8D9Gljqx09GNq2lBWFnQHE6LkZ)y9W3c92G49Hc1vO6J2JVwrLFvv39cvvrSBNaigcHZDrSxvhdm(flwXcmwmYGtxGXAXU9nYOxGy1JFrm92auI9RsI1HyilCWVy076AakXAeXaBG1auI1VyP6SDjUJVAkuLJOxWFdf0djaLCe9ckU(dLaPht5doDbgRv6dypckkQuJq5doDbgRNPZjuvfXUnaUlInWsakwm4gz0lqSgrmvSyyPAwmAyVWoUuGBKrVaXEoelbAX8iCrt7yXIeIIJxmc6PqvoIEb)nuqV6e2jUJvcKEmfINl0WEHDCPa3iJEbkPoDemfAyVWoUuGBKrVa)pn7CLiHO44NpgbSRWGYhl0Zhk3luvfXuyyVWoUi2TVrg9c8Ljg1IJQ9IHQvZILInGjTyj(seIXagI6IyiluSaJf7doDbMyvxbVy1Jt0ondf7J25edYpnpcX64QPyOHtqRKyDi2ibIHZIfyzi23E0oEkuLJOxWFdf0psNRKJOxqX1FOei9ykFWPlWkd9R0hWEeuuuPgHI6e2jUJNepxOH9c74sbUrg9ceQQIyvFbFRzOyeFdqjwkgzWPlWeR6kqmvymqmiNdSgGsSaJfJbme1fXcmi)yRtluLJOxWFdf0psNRKJOxqX1FOei9ykFWPlWkd9RuJqHbme1LPMr6rhxtrDc7e3XZp40fyLadYp260cvvrmFTb9JjwgI5LktjXO(nIPQdSLietbKITqXu1bMyKRceBa7qmCceeLeZ33iMQoWetbKIv)seFRzX(GtxGDfAyftvhyIPasXs3VIH0G(XeldXO(nILOYg8HyuxSiHO44fR(Li(wZI9bNUa7kHQCe9c(BOG(r6CLCe9ckU(dLaPhtbPb9JPuJqrDc7e3XtgbHhrRMlJ1dFl0BdI3hkd6IxQSYtZaDTAJ1dFl0BdIFQzKE0X1uuSwnKgfwuGSx2G)Akk6xDc7e3XtgbHhrRMlJ1dFl0BdI3hk3QwnCceK5FXdFDFzrkAodSsse7a2XKG2V6e2jUJNmccpIwnxgRh(wO3geVpuOETApn7CLiHO44NpgbSRWGYhl0Zhku3V6e2jUJNmccpIwnxgRh(wO3geVpuOUqvveZx8SyPy4eTtZqXuHXaXGCoWAakXcmwmgWquxelWG8JToTqvoIEb)nuq)iDUsoIEbfx)HsG0JPGt0oTsncfgWquxMAgPhDCnf1jStChp)GtxGvcmi)yRtluvfXOwRk(dXOH9c74IynqS05eBrelWyXqtkm1smCEKeplwhInsINFXsX8LQUceQYr0l4VHc6t4ibCjwiKbHsncfgWquxMAgPhD4dff99nmGHOUmHmkgiuLJOxWFdf0NWrc4cnH7zHQCe9c(BOGExJcl(cAicnkpgecv5i6f83qb94jQYIucypQ8cvcvvPkIHoI2Pz4luLJOxWpXjANMYJ1QvQrOG2iDmiMGgfw8r6QWWjdsChR9djamYcrXZObxkXQSEuWDPM9)0SZvIeIIJF(yeWUcdkFSqVR9TqvoIEb)eNOD6BOG(hJa2vyq5Jf6PuJq5PzNRejefhVpuU3F9ODSQzqcIjGhW1TqDTAJDD6vfy(meMbRl4lGlpDxHNEPYkdSeIIFfAGLqu8xqG5i6fKoFOO859(UwTNMDUsKquC8ZhJa2vyq5Jf65d1VYF94eiitAgISWmyDrn3GF(roQCnfQxR2tZoxjsiko(5Jra7kmO8Xc98H6xjuLJOxWpXjAN(gkO)zimdwxWxaxE6UcRuJqbNabzsZqKfMbRlQ5g8ZpYrLRPCV)6h760RkW8zimdwxWxaxE6Ucp9sLvgyjef)k0alHO4VGaZr0liDxtr5Z79DTA)s4WBGE64uxWVuyLLE0oEYGe3XA)OfNabz64uxWVuyLLE0oEsqxR2Veo8gONvy1n4l7Igg21autgK4ow7hTAgNabzwHv3GVOcMb2KG(kHQCe9c(jor703qb9OC76H7snluvfXqxoQ8rIlw75X6od2DrmcGJ)xSaJfdWkleR6kSy9lgAc0E5alHOyTyjqlMkwmvlOAHyJKwmgWquxetv2rdqjgYcfRJPqvoIEb)eNOD6BOGE8Cu5JexPgHcAhRAgKGyw5cStqTAOTE1jStChp7VayLfLbDjbTxoWsikw7V(O94sSLhlM3As7i(Rv(031QfThxIT8yXK6tAhXFTIx5Nbme1LRRkLFLqLqvveR6760RkWluvfX8fplMcsWGfBrquiudTy4mYczXcmwmKg(HyKyeWUcdeJmwONyiW1tS6wii1RyJ1JFXAWuOkhrVGFo0pLhl1RQIobdwjINllcsb1qtrrLAekOfNabz(yPEvv0jyWtcA)4eiiZhJa2vyqjwii17KG2pobcY8XiGDfguIfcs9oHSx2G)Ak3A6BHQQiw9(cGJ)xS0b5uFrmcAXW5rs8SyQyXIDRigjwQxvI5R7G4VsmINfJ8Ih(6EXweefc1qlgoJSqwSaJfdPHFigjgbSRWaXiJf6jgcC9eRUfcs9k2y94xSgmfQYr0l4Nd9Fdf0)x8Wx3xwKIMZatjINllcsb1qtrrLAek4eiiZhJa2vyqjwii17KG2pobcY8XiGDfguIfcs9oHSx2G)Ak3A6BHQCe9c(5q)3qb9iUef7Cz0lqPgHI6e2jUJNpqxglq3rVa)O9doDbgRNEjiCS)6FA25krcrXXpFmcyxHbLpwO31uu0)yxNEvbM)fp819LfPO5mWMe0(rBKogeZhl1RQcYoi(jdsChRRvdNabz(x8Wx3xwKIMZaBsqFL)X6HVf6TbX7dfFluLJOxWph6)gkOxDc6htPgHs9qcaJSqu80lHvklsjW4Ix(bdl5)5)nW)y9W3c92G4NAgPhDCnffvOiDmiMAMPzy5dygmk2BYGe3X6A1GeagzHO4PMZaZDP8yPEv9(hRh(wO3ge)1kELFCceK5FXdFDFzrkAodSjbTFCceK5JL6vvrNGbpjO97LFWWs(F(Fdkq2lBWtr5(XjqqMAodm3LYJL6v1p1RkGqvvetH31jgYcfRUfcs9kgnKviYvbIPQdmXiXuGyqo1xetfgdedSHyqcaObOeJ0xNcv5i6f8ZH(VHc6P31vG8VeWbReYclawzbffvQrOePJbX8XiGDfguIfcs9ozqI7yTF0gPJbX8Xs9QQGSdIFYGe3XAHQQiMV4zXQBHGuVIrdzXixfiMkmgiMkwmSunlwGXIXagI6IyQW4aJHIHaxpXO311auIPQdSLieJ0xfBHIHgI4dXqXagMo3LPqvoIEb)CO)BOG(hJa2vyqjwii1RsncLNMDUsKquC8ZhJa2vyq5Jf6Dnff9ZagI6IpuQkL7xDc7e3XZhOlJfO7OxG)XUo9Qcm)lE4R7llsrZzGnjO9p21PxvG5JL6vvrNGbphyjef)(qrr)1JwibGrwikEU4SUzWGRvtZ4eiitexIIDUm6fmjORv7PzNRejefh)8XiGDfgu(yHE(qPEfVH6vD1J2iDmiMGgfw8r6QWWjdsChR9J2iDmiM6ewP8yPEvnzqI7y9vxDL)X6HVf6TbXFnL79JwCceKjnK9yDhz0lysq7VE0ow1mibXundcSlWA1q7yxNEvbMiUef7Cz0lysqFLqvoIEb)CO)BOG(NHWmyDbFbC5P7kSsJldhxIeIIJNIIk1iuuNWoXD88b6Yyb6o6f4hT6nMpdHzW6c(c4Yt3v4IEJz0JknaL)iHO4ygThxITOB2hk3RO)6hRh(wO3ge)uZi9OdFOu)GUGkBGp(YO(vx5hT4eiiZhJa2vyqjwii17KG2F9OfNabzsdzpw3rg9cMe01Q90SZvIeIIJF(yeWUcdkFSqpFO(v1QH0OWIcK9Yg8xtX3(FA25krcrXXpFmcyxHbLpwO313sOkhrVGFo0)nuq)Z0F)k1iuuNWoXD88b6Yyb6o6f4FSE4BHEBq8tnJ0Jo8HII(JeIIJz0ECj2IUzFOOyvjuvfX8fplg5fp819ITaXg760RkGy1NibdfdPHFigjqbxjgbWX)lMkwSeYIHABakXIvm6LwS6wii1RyjqlMEfdSHyyPAwmsSuVQeZx3bXpfQYr0l4Nd9Fdf0)x8Wx3xwKIMZatPgHI6e2jUJNpqxglq3rVa)1J2iDmiMpgbSRWGsSqqQ3jdsChRRvlshdI5JL6vvbzhe)KbjUJ11Q90SZvIeIIJF(yeWUcdkFSqpFOCFTAJDD6vfy(yeWUcdkXcbPENq2lBW7Z9x5VE0ow1mibXundcSlWA1g760RkWeXLOyNlJEbti7Ln49rrLxR2yxNEvbMiUef7Cz0lysq7FSE4BHEBq8(qX3xjuvfXqdqel16xSeYIrqRKypOPzXcmwSfWIPQdmXCRk(dXQRofmfZx8SyQWyGy6lnaLyi5hmuSalbIvDfwmnJ0JoeBHIb2qSp40fySwmvDGTeHyj4IyvxHNcv5i6f8ZH(VHc69syfwxqwyrZzGPKRbCzOPO403knUmCCjsikoEkkQuJqbMTUWQzqmtT(Ne0(RpsikoMr7XLyl6MVESE4BHEBq8tnJ0JoQvdTFWPlWy9mDo)J1dFl0BdIFQzKE0Hpug0fVuzLNMb6ReQQIyObiIbwXsT(ftv7CIPBwmvDG1aXcmwmaRSqSBP8xjXiEwSQgIceBbIHV)lMQoWwIqSeCrSQRWtHQCe9c(5q)3qb9EjScRlilSO5mWuQrOaZwxy1miMPw)Zg4ZTuUcbZwxy1miMPw)tnbmJEb(hRh(wO3ge)uZi9OdFOmOlEPYkpnd0cv5i6f8ZH(VHc6FSuVQk4UuZVsncf1jStChpFGUmwGUJEb(hRh(wO3ge)uZi9OdFOCV)6XjqqM)fp819LfPO5mWMe01QHV)7hPrHffi7Ln4VMY9kVwn0ItGGmFSuVQk4UuZ)KG2)ZrbFbe)mAgEp1OCp94kHQCe9c(5q)3qb98aBBaQcKPHTxc0k1iuq7hC6cmwptNZV6e2jUJNpqxglq3rVa)J1dFl0BdIFQzKE0HpuU3F9QtyN4oEs8CHg2lSJlf4gz0lOwTNMDUsKquC8ZhJa2vyq5Jf6DnfQxRgKaWilefpH8VeaDdqvgUe2XLReQQIyO5oWeJ0xvsSgrmWgILoiN6lIPxaRKyeplwDleK6vmvDGjg5QaXiONcv5i6f8ZH(VHc6FmcyxHbLyHGuVk1iuQpshdI5JL6vvbzhe)KbjUJ11Q90SZvIeIIJF(yeWUcdkFSqpFOC)v(vNWoXD88b6Yyb6o6f4hNabz(x8Wx3xwKIMZaBsq7FSE4BHEBq8xt5E)1JwCceKjnK9yDhz0lysqxR2tZoxjsiko(5Jra7kmO8Xc98H6xjuLJOxWph6)gkO)Xs9QQOtWGvQrOGwCceK5JL6vvrNGbpjO9J0OWIcK9Yg8xtHACtKogeZNapyicbkEYGe3XAHQCe9c(5q)3qb9io(XgWejuQrOu)Veo8gON0eFq44cdjOJEb1Q9lHdVb6P61Lr74YVo1miUYpdyiQltnJ0Jo8HYTuUF0(bNUaJ1Z058JtGGm)lE4R7llsrZzGn1RkGsniyiKGokTNhR7mykkQudcgcjOJck3INokkQudcgcjOJsJq5xchEd0t1RlJ2XLFDQzqiuLJOxWph6)gkONEJEbk1iuWjqqM4UD1oIpMqohrTAinkSOazVSb)13s51QHtGGm)lE4R7llsrZzGnjO9xpobcY8Xs9QQG7sn)tc6A1g760RkW8Xs9QQG7sn)ti7Ln4VMIIk)kHQCe9c(5q)3qb94UD1fec4fLAek4eiiZ)Ih(6(YIu0CgytcAHQCe9c(5q)3qb94m8zyLgGsPgHcobcY8V4HVUVSifnNb2KGwOkhrVGFo0)nuqpsdzC3UALAek4eiiZ)Ih(6(YIu0CgytcAHQCe9c(5q)3qb9jyWFatxzKoNsncfCceK5FXdFDFzrkAodSjbTqvvetbmss4cXqsNdphvedzHIr8jUJfRd27PMI5lEwmvDGjg5fp819ITiIPaodSPqvoIEb)CO)BOGEINlDWEVsncfCceK5FXdFDFzrkAodSjbDTAinkSOazVSb)13RCHkHQQufX81g0pgdFHQQigAgRDSyeFdqjMcdzpw3rg9cusSu92AXg5hnaLyKUEWILaTykOhSyQWyGyKyPEvjMcsWGfRFX(DbIfRy4SyepRvsmwzdMoedzHI5l)cStGqvoIEb)ePb9JrrDc7e3XkbspMcnK9yD5b6Yyb6o6fOK60rWuI0XGysdzpw3rg9cMmiXDS2)tZoxjsiko(5Jra7kmO8Xc9UUEFRqJvndsqmb8aUUfQVYpAhRAgKGyw5cStGqvoIEb)ePb9JDdf0)UEWLeOl6EWk1iuqR6e2jUJN0q2J1LhOlJfO7OxG)NMDUsKquC8ZhJa2vyq5Jf6DDv5hT4eiiZhl1RQIobdEsq7hNabz(UEWLeOl6EWti7Ln4VgPrHffi7Ln49dzei)yjUJfQYr0l4NinOFSBOG(31dUKaDr3dwPgHI6e2jUJN0q2J1LhOlJfO7OxG)XUo9QcmFSuVQk6em45alHO4VGaZr0liDxR4826B)4eiiZ31dUKaDr3dEczVSb)1JDD6vfy(x8Wx3xwKIMZaBczVSbV)6h760RkW8Xs9QQOtWGNqo1x8JtGGm)lE4R7llsrZzGnHSx2GxHWjqqMpwQxvfDcg8eYEzd(RvCE)vcvvrmQ9SJMHIrTLWoXDSyiluSBNGoiG8umYknTyAcydqjwvl)GHIHM(p)VbITqX0eWgGsmfKGblMQoWetbjSIyjqlgyf7Ugfw8r6QWWPqvoIEb)ePb9JDdf0RoHDI7yLaPht5R00fibDqazLuNocMIx(bdl5)5)nOazVSbVpkVwn0gPJbXe0OWIpsxfgozqI7yT)iDmiM6ewP8yPEvnzqI7yTFCceK5JL6vvrNGbpjORv7PzNRejefh)8XiGDfgu(yHE(qPEQRqFWPlWy9mDUQUiDmiMpwQxvfKDq8tgK4owFLqvveZxoZ0Irql2TtqheqwSgrSoeRFXs8LielwXGeaXwIykuLJOxWprAq)y3qb9qc6GaYk1iuq7hC6cmwptNZF9OvDc7e3XZVstxGe0bbKRvtDc7e3XtINl0WEHDCPa3iJEbx5psikoMr7XLyl6Mvii7Ln49PQ8dzei)yjUJfQYr0l4NinOFSBOG(NhqokbpWaDvpbluvfXQAeUO1BenaLyrcrXXlwGLHyQANtmxRMfdzHIfySyAcyg9ceBre72jOdciRKyqgbYpMyAcydqjgDc0SxpMcv5i6f8tKg0p2nuqpKGoiGSsJldhxIeIIJNIIk1iuqR6e2jUJNFLMUajOdci7hTQtyN4oEs8CHg2lSJlf4gz0lW)tZoxjsiko(5Jra7kmO8Xc98HY9(JeIIJz0ECj2IUzFOuVVVP(7R6gRh(wO3ge)vx5hYiq(XsChluvfXUDgbYpMy3obDqazX4e6UiwJiwhIPQDoXyLr3qwmnbSbOeJ8Ih(6(PykyflWYqmiJa5htSgrmYvbIHIJxmiN6lI1aXcmwmaRSqmF)tHQCe9c(jsd6h7gkOhsqheqwPgHcAvNWoXD88R00fibDqaz)q2lBWF9yxNEvbM)fp819LfPO5mWMq2lBWFJIk3)yxNEvbM)fp819LfPO5mWMq2lBWFnfF7psikoMr7XLyl6Mvii7Ln49zSRtVQaZ)Ih(6(YIu0Cgyti7Ln4VX3cv5i6f8tKg0p2nuqpUlhvk0RkndvQrOGw1jStChpjEUqd7f2XLcCJm6f4)PzNRejefhVpuULqvoIEb)ePb9JDdf0ZQ7FWWmyHkHQQufXidoDbMyvFxNEvbEHQQig1E2rZqXO2syN4owOkhrVGF(bNUaRm0pf1jStChRei9ykpMUeyq(XwNwj1PJGPm21PxvG5JL6vvrNGbphyjef)feyoIEbPZhkkoVT(wOQkIrTLG(XeRretflwczXgjnDdqj2cetbjyWInWsik(NIrTlHUlIHZilKfdPHFiMobdwSgrmvSyyPAwmWk2DnkS4J0vHHIHteIPGewrmsSuVQeRbITqndflwXqXHy3obDqazXiOfREWkwvl)GHIHM(p)VbxnfQYr0l4NFWPlWkd9Fdf0Rob9JPuJqPE0QoHDI745JPlbgKFS1PRvdTr6yqmbnkS4J0vHHtgK4ow7pshdIPoHvkpwQxvtgK4owFL)X6HVf6TbXp1msp6Whf9JwibGrwikE6LWkLfPeyCXl)GHL8)8)giuvfXu4DDIHSqXiXs9QYJDAXUrmsSuVQ(a2vyXiao(FXuXILqwSeFjcXIvSrsl2cetbjyWInWsik(NIDBaCxetfgdeZxBGwm0mNva8)I1Vyj(seIfRyqcGylrmfQYr0l4NFWPlWkd9Fdf0tVRRa5FjGdwjKfwaSYckkQeRSaML0BjabfQRCLAekWCWtqJclkSdrOkhrVGF(bNUaRm0)nuq)JL6vLh70k1iuyadrDXhkux5(zadrDzQzKE0Hpuuu5(rR6e2jUJNpMUeyq(XwN2)y9W3c92G4NAgPhD4JIcvvrSQRWIfyq(XwN(fdzHIXGGHnaLyKyPEvjMcsWGfQYr0l4NFWPlWkd9Fdf0RoHDI7yLaPht5X0LX6HVf6TbXRK60rWugRh(wO3ge)uZi9OdFOC)n4eiiZhl1RQcUl18pjOfQYr0l4NFWPlWkd9Fdf0RoHDI7yLaPht5X0LX6HVf6TbXRK60rWugRh(wO3ge)uZi9OdFOClLAekJvndsqmRCb2jqOkhrVGF(bNUaRm0)nuqV6e2jUJvcKEmLhtxgRh(wO3geVsQthbtzSE4BHEBq8tnJ0JoUMIIk1iuuNWoXD8K45cnSxyhxkWnYOxG)NMDUsKquC8ZhJa2vyq5Jf65dfQluvfXuqcgSyAcydqjg5fp819ITqXs8vnlwGb5hBD6PqvoIEb)8doDbwzO)BOG(hl1RQIobdwPgHs91RoHDI745JPlJ1dFl0BdIVwn1jStChpFmDjWG8JTo9v(Fok4lG4NrZW7PgL7Ph(hRAgKGyw5cStqTAQtyN4oE(y6Yy9W3c92G49xpobcY8V4HVUVSifnNb2eYEzdEFOO48(A1uNWoXD88X0LadYp260xvRgobcYCGL7xWtapjORv7PzNRejefh)8XiGDfgu(yHE(qH6(h760RkW8V4HVUVSifnNb2eYEzdEFuu5x5VECceKjndrwygSUOMBWp)ihvUM61Q90SZvIeIIJF(yeWUcdkFSqpFU1vcvvrm0rabIPGem4xSbwcrXVynIyxwcXOD5fXuqcRigjwQxvp6rtUCa74IylumCgzHSybglgsJcleJb6xSgrmYvbIPAbvledNfdYP(IynqSO94PqvoIEb)8doDbwzO)BOG(hl1RQIobdwPgHI6e2jUJNpMUmwp8TqVniE)inkSOazVSb)1JDD6vfy(x8Wx3xwKIMZaBczVSbFTAOnshdIjduZULUbOkpwQxv)KbjUJ1cvcvvPkIrgC6cmwl2TVrg9ceQQIyObiIrgC6cm0Rob9JjwczXiOvsmINfJel1RQpGDfwSyfdNbmshIHaxpXcmwm68)wnlg(ciEXsGwmFTbAXqZCwbW)RKySAgiwJiMkwSeYILHyEPYeR6kSy1taC8)Ir8naLyvT8dgkgA6)8)gCLqvoIEb)8doDbgRP8yPEv9bSRWk1iuQhNabz(bNUaBsqxRgobcYuDc6hBsqFL)6FA25krcrXXpFmcyxHbLpwO31uVwn1jStChpjEUqd7f2XLcCJm6fCLFV8dgwY)Z)BqbYEzdEkkxOQkI5RnOFmXYqSBDJyvxHftvhylriMcifd9Ir9BetvhyIPasXu1bMyKyeWUcdeRUfcs9kgobcIye0IfRyP6T1I9Rhlw1vyXuLFWI9DqKrVGFkuvfXqtUFf7tewSyfdPb9JjwgIr9BeR6kSyQ6atmwz5iCxeJ6Ifjefh)uS6jtpwS8fBjIV1SyFWPlWMxjuvfX81g0pMyzig1VrSQRWIPQdSLietbKkjMVVrmvDGjMcivsSeOfRQetvhyIPasXsKGHIrTLG(XeQYr0l4NFWPlWy9nuq)iDUsoIEbfx)HsG0JPG0G(XuQrOOoHDI74jJGWJOvZLX6HVf6TbX7dLbDXlvw5PzGUwnCceK5Jra7kmOeleK6Dsq7FSE4BHEBq8tnJ0JoUMY91Q90SZvIeIIJF(yeWUcdkFSqpFOqD)QtyN4oEYii8iA1CzSE4BHEBq8(qH61Qnwp8TqVni(PMr6rhxtrrfQ(iDmiMAMPzy5dygjk2BYGe3XA)4eiit1jOFSjb9vcv5i6f8Zp40fyS(gkO)Xs9Q6dyxHvQrO8bNUaJ1ZNP)(9)0SZvIeIIJF(yeWUcdkFSqVRPUqvvedD5OYhjUyAcydqjgjwQxvIPGemyXuHXaXwGyynkmXuyQnX(ihvEXsGwmsSuVQedDUuZVy9lgb9uOkhrVGF(bNUaJ13qb945OYhjUsncfCceKjndrwygSUOMBWp)ihv8HIV9JtGGmFSuVQk6em4jK9Yg8(q5w(XjqqMpwQxvfCxQ5Fsq7)PzNRejefh)8XiGDfgu(yHExt5wcv5i6f8Zp40fyS(gkO)XA1k1iuI0XGycAuyXhPRcdNmiXDS2pKaWilefpJgCPeRY6rb3LA2)tZoxjsiko(5Jra7kmO8Xc9U23cvvrmFbTyXk2TelsikoEXQhSIrd79kXQWmTye0I5RnqlgAMZka(FXWVi24YW1auIrIL6v1hWUcpfQYr0l4NFWPlWy9nuq)JL6v1hWUcR04YWXLiHO44POOsncf0QoHDI74jXZfAyVWoUuGBKrVa)AgNabzI0aDrfNva8)ti7Ln4Vwr)pn7CLiHO44NpgbSRWGYhl07Ak3YFKquCmJ2JlXw0nRqq2lBW7tvjuvfX81fkgnSxyhxedUrg9cusmINfJel1RQpGDfwSvndfJmwONyQ6atm0CvtSev2GpeJGwSyfJ6IfjefhVyluSgrmFfnlw)IbjaGgGsSfbrS6xGyj4IyP3sacXweXIeIIJ)kHQCe9c(5hC6cmwFdf0)yPEv9bSRWk1iuuNWoXD8K45cnSxyhxkWnYOxG)61mobcYePb6IkoRa4)Nq2lBWFTI1QfPJbXufN0lWl)GHtgK4ow7)PzNRejefh)8XiGDfgu(yHExtH6xjuLJOxWp)GtxGX6BOG(hJa2vyq5Jf6PuJq5PzNRejefhVpuU1n1JtGGmdmUa3iyWKGUwnibGrwikEMvYe2F5xcxbbMO8yquR2ZrbFbe)mAgEp1OCp94k)1JtGGm)lE4R7llsrZzGvsIyhWoMe01QHwCceKjnK9yDhz0lysqxR2tZoxjsikoEFO47ReQQIyKyPEv9bSRWIfRyqgbYpMy(Ad0IHM5ScG)xSeOflwXyWtazXuXInsGyJecVi2QMHILIHq4CI5ROzXAqSIfySyawzHyKRceRreJE)VXD8uOkhrVGF(bNUaJ13qb9pwQxvFa7kSsncfnJtGGmrAGUOIZka()jK9Yg8xtrXA1g760RkW8V4HVUVSifnNb2eYEzd(RvKA4xZ4eiitKgOlQ4ScG)FczVSb)1JDD6vfy(x8Wx3xwKIMZaBczVSbVqvoIEb)8doDbgRVHc6r521d3LAwPgHcobcYKMHilmdwxuZn4NFKJk(qX3(hlqt0XKMHilmdwxuZn4NWeuXhkkElHQCe9c(5hC6cmwFdf0)yPEv9bSRWcv5i6f8Zp40fyS(gkOFGXjD5X2qPgHcAJeIIJz)f89F)J1dFl0BdIFQzKE0Hpuu0pobcY8X2O0GsGXfDcRmjO9ZagI6YmApUeBH6k3hud90lv2joX5aa]] )

    
end
