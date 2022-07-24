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
            duration = function() return 1 + effective_combo_points end,
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
            duration = function () return 6 * ( 1 + effective_combo_points ) end,
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

    spec:RegisterCombatLogEvent( function( _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName, _, amount, interrupt, a, b, c, d, offhand, multistrike )

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


    spec:RegisterStateExpr( "effective_combo_points", function ()
        local c = combo_points.current or 0
        if not covenant.kyrian then return c end
        if c < 2 or c > 5 then return c end
        if buff[ "echoing_reprimand_" .. c ].up then return 7 end
        return c
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
                if talent.alacrity.enabled and effective_combo_points > 4 then addStack( "alacrity", nil, 1 ) end
                removeBuff( "echoing_reprimand_" .. combo_points.current )

                if buff.finality_black_powder.up then removeBuff( "finality_black_powder" )
                elseif legendary.finality.enabled then applyBuff( "finality_black_powder" ) end

                spend( combo_points.current, "combo_points" )
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

            spend = function () return ( 20 + conduit.nimble_fingers.mod ) * ( ( talent.shadow_focus.enabled and ( buff.shadow_dance.up or buff.stealth.up ) ) and 0.8 or 1 ) end,
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

                removeBuff( "echoing_reprimand_" .. combo_points.current )
                spend( combo_points.current, "combo_points" )

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

            spend = function () return ( 35 + conduit.nimble_fingers.mod ) * ( ( talent.shadow_focus.enabled and ( buff.shadow_dance.up or buff.stealth.up ) ) and 0.8 or 1 ) end,
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

            startsCombat = true,
            texture = 132298,

            usable = function () return combo_points.current > 0 end,
            handler = function ()
                if talent.alacrity.enabled and combo_points.current > 4 then
                    addStack( "alacrity", 20, 1 )
                end

                applyDebuff( "target", "kidney_shot", 1 + combo_points.current )

                if talent.prey_on_the_weak.enabled then applyDebuff( "target", "prey_on_the_weak" ) end

                spend( combo_points.current, "combo_points" )
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

                removeBuff( "echoing_reprimand_" .. combo_points.current )
                spend( combo_points.current, "combo_points" )
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
                removeBuff( "echoing_reprimand_" .. combo_points.current )
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


    spec:RegisterPack( "Subtlety", 20220724, [[Hekili:vZ1EZTTrs(plQ2Qyi1dA(sko5evkh717fVXzDfLnEV)rqGadfXkqaUaGswxPIF2VUNxyMbZmauwooxD1MtgCWGE6PNU)1pM(QXx9BxDzCyf5QFzYOjtg9TtMnC8ztgn6SRUS6HnKRUCty0TH3a)rw4A4)E52fvPKQhWF4H08WyCckZ3web)4QQQnLF)lEXnjvR2Uyyu(6xuMSEBAyvsEwur4Yk8Fh9IRUCX2K0QFk7Qfw(6J)Ut)URUmCB1Q8c4dMS(1WmNehtydNugvtg7U(xZVzlz37E32u4Fmz2XW)bMQDVB37E9QWSBiLF)U3DYURFF(DKDxFxyrs4IuYWTLKGnfj5fjvpeuKxrPWDxVDZURlZ3DDsf8)kH)Ma)XcYY8c4LVh(FW7H)6q6C(681lsYGhalXQKnPWFffMMgegHZwqAsj82KSQIecmxvW8wqI3gbdBtEf88KWu8r3NxClBcFF4TWp(2us5kk3c(uzvKIITBO)jm9Wxme)7LmY5FVf)eXjXmsgOtynMJ87usqzE6DWxz4vxIusjDJQIeMwTIG7A)cDVNKH8J4R(rGJtjByqRcJZVVei7Bjm(DrYg2p9tW39s2C8I7cZskxT76qK3SDZXCMZLkVnBrVGKrwsjVI81WJwHmGWYYeChzrE2wG5eMblH3MG)3pscVnJuwctibO)6fl9dHR(1HFcy(Fy3193Mb8Qs8lNKDdY)GfiWcEvzjo)zdU6sG2HhLeE1L9Hp22LlhY5bdX96hFK)q2IH(Sb7UUhm1WM)gcSzwfwCdPQCy5QT4sklOSkVawgNV76zSjOnHk2eUMsBbHCslOGSomjdO957UE0vvWjaJTdngpWAymBy5p7i2Q)E4uw(w4bV5sGxD6rSNW)Nug6z1pcEYskV53PR06DBtjwvwMCLrwUKad5osakbMhSjhembA)cG4J2eaBiba3c)KsoQKFbSRmqKGYB7XeHftWWyqWicfnohMOjS32pBh)IZOtuNio(wK7p64DxFcD3UkmfpSetiBGTjq(nScu7TEiFhH(jBiQWoAfWunUKUhHBLtn2kR5OYdGdljBkrvm9ABfJcAooCcFQzooeVauBxwfUWqo6h5pguAaFf8md78kiIeMHAMUFfEKdfBxLCdi58HFhOVk8T4YuIX)JPHXOAnCnSDZq1fzuEw8wqjjWibnsG694G7iGS(WIWSBz7lVSMF2yu0phByNwpm2cpigjZHYdp4GM2yqlO0MqIR9JYSjP7NL7B9ZjjkC(8qZhjf1paLmbDCHGGhQQE1dfOqfSTEQtjiUCAgS7ubCQ0BjfAYOfBZq7v3qgwLK9aC67tjrmkuByTkZDQQmxYDirDwNmye9qey8HpZOvgfI)G25WaTftOCp48uCW9CRbkCx6H22xcsjd2ia2XAGSYdIti0Z81YqGIsJJj)ZnmtxtfVnmS(zWdqcgKbUf0sWqlOBZc23buiihq5SfJXme5GFBN4G6A(rB6c(eq1CgLDZTGWubAHMYbyQ()47HdU3GR0kgfJRRzkRlC(rtSV9JSdZGaugL6ZxcpTpUNeMbF5W15BZQWhlF5bwnw4EJTF32BXJgCXCyiBYZy2o3h5xMQF6rPx6wzS6Ci1LCu95BqrnUaaSAs0c1hVcVnewXLamRTPbllcVznsWsAKAkJufqb4acFKIjVmyYMiUijD1X1pSmpcgI8nn0X8ay6kTmiFzqmjSAvaamohxdss6aHIuGnsIty8B5VAzrEk1YvTSNkVd5yF3(lL2e1xbzzbbHSyEcHAfbhbjRCRaxDuiIUnSO4bHqCiGxCBAkxUmdFbkYXmYNaHWlZFdtQDtoGMcL6u3yBriBUuklkppfO7SgCzDrYx2n1sToBiZD8iNYJD0CyhmVoEA9U2nP5a6h0aa9Ztr9BFhTMOWbAIhvtloxNki(ViVS0dWUlMluxZTiMxfaOFXtwXHGFpCB0Glcf38Guh9Sru1Y3efpeWwQawDfOpiaNKRW)pyJEzi47L0BgX4Unj6wJ1J5YjFdS8jv1VJq)f(xPBj8TJY0KisaiZc2naJ4wpvzfKAdtkLeUCFmb4JRPoocOTaorrTOdWkVpu6k3LzGu(Iq6BIQqfFpkXYrDwcKgkrKq)mwaF(hWc1d1yIp1l1iMfqScpMhaUwaGTxhgTc)(X6ym54MU9b4FNzWSF9kcEMb52LecttHI2dQVJO)00NHEzYTRfIgu)n0EBE0aM5WxPraCoMUJg6I4KOvWZVbCWdmcUgzOtKCZgV3eFV3u3V3uFV3m3V3mFV3PW7zd8z7sq2DbZyt5vrrmeemzBKpxqytjStaN8zONsUjlN5AsA(9NGBvQYaOJ0vGAGswarOBGJgEAjUNrIiG9p8nd1cXIClvvgZbjBbMB7lF9fTtHuMMoxERAUB5wLQqSrOTSCvvWMuacXmQziGDq)zvW2opr1fgIjQ12zi2H)1UUKjgIm)JmmQEr0a5vJ9ToKqRcXyiz5RrdChfPrDS5KyGOURwVWTIx1gYrBQyE9BkzrLzzsrzLVWQOePGO4sV4S0ufBEkAZgKNCjog(s8nS)eiIj8qdjCUNE8GszGkQriBbvoJHwJhnOQvQruczROeg5tBskWJyOleYJzmDN)Tx)gUpdWVNLtDQWjOABowEgvwyj6)AGMpykOe0TfPIXIdjOXXdz4E4rZHQo5C2Qg0KFikBzd9LgV9x3MXqDcm4syTZ0ZiHEEPi4nyuNfsA9rDwX5u2Dz(XYaXgHV6gWSo9xqolWSwX(hOiZDHjPivmyy9gp4CHRqXvh4iqWstyQoMUs4DUwFFq6gPG()HDx)ZKQVbiOBOHJfuCgvecwpcxqdTidxgxLnLjW)CCj)(yG8JrjPYQKuA4SbbGime1vdgU76)hAGHrwcfH)cIqKRmz9gkQ99koK2pQAHBeWpI1afB76UMCk1hqUlA3LCtUINNOC0i1FNhwxaPphlTNXA3DpCyAFYW0qCP)GTzch5HDiKwxiCa2ni0LceOzSNqdNG(UlUPZ3Gl1q5XzYvRqx8aKRuwTjWtD1L5zLjubfES6dLNNWpMGqqabRQvDje)Q)qDsEH7nHwGELYqnjEFYpM4xDgvEqP0XmnPkXLNXczbIH6YksJmLCgHShJ0Y2kKfj3egCSw47tXetT0ipaYi7OgrNMZu3yBDkI6nd3V3GRJdWqx)5s8YD6dovnPcEdgsxNXzD11M9jrdosfWytW0MNhPNeKAr)tYPak9qjFxX8nSauOJOplkaDwglRFo)Eckuwh2seeriAFix4j2R(WpJ2dIc5PufTqa)zjLFaGm8TsObvGPZK)tfKBiumBJ)w14aWPYnBtlBeFJxQoWuA40d(3BJPHXZCSFN6yxeEdkawvKeDBP(iRqOVewwABeuIqe5gk0uI)RMbNqo)5vvWVeSmn8bs89OpAyu8nFhpjzkFB6IKS4HB2wwTnLeqWmidZTr0jfdRrgJfZQKKwktjT0NEjyvMGKbXzk1lg96WIBXLwEb7aSc)kGdo9QlHZm(Y2Gb6461npKJmR52MxBoZO86Yq7IujDlEfjWiVTn5nAjbIjdWo(yjf7gXq7RwMCChBplHlEIiE0QPRkJevKNMxeBgivsblKKlYHdELBWmFG2lyoCwsXNZ)BmO5u6c9rh)qJgIWB6GQzg2gTWK7kSPN3z99c19DihvEJEU7ZLTsOso9Nn78CD2P4KEkjeMQhciFkKc)wvosKgbZXiJeOysULChq3b55)Ve05gZjHhMC(OUViSsMSCjtR5QQHEfLWw3nvlTMX7K1y6rGVl6ENOYrmIkOze)4EyJXA4(8SVHALAtTfzmwTu70u)JsQgACeVraG45RPF7HMrik0iiptRdYdnrz2dc0yXbebPIEEpILsSkweiAt)uZuyZbz5T(oS)JAG)Mo8uwuxYxUmaCONMKyd1P0pOn0s86uaE1tGxDNS6Sud1XL8pVmvOSkp63yedfXklaId9Rm8l7c1alRXIT))KlHgMcWbJFGL8wjGjuISkp)26cY4TOBLdePfMn5pR8jtfB1GdcVb0SY9f3I7eAjfqOMOoGgRHdiy8561b)AR9DWDY247ph0IF3oDQqPkWAIZNfAvBLuWfyWMUQz5pyjji18O(QM57aSdpHfUUAMSukteTszspr20fnGmTramAWau1R4M11ZJQdVvbx9RAss4gTAiBeEx515QpasiCnZsjAav4juhX5(KV6nuVTWJxmxVOr0uwcex(wqJocwf1qBullsHldnagMd9idwVIW4ec8cED06d8RXxZMgs1flpSdS1wDeZ1CRuMes2PFzmlLXX4Y3YIJbRAtVbFpWxUhgUhH9vESv8rPzoCKU)1n1t06H86bOkSjrhvN9zg81AH(8fawaco4MkeuvOfqFs3ZgAF6h8ikyYdfF22q6xpemN4CPETcczGDns1GgDxeinXUll1mznOXzIQlCoMnlEm5dfxNv)hNxzdCBa(8kWXAQeOlnT4QECnwzx1DqFA0QWiKb)7Fq40Wan(LlR793R6QXTlkuHkrjsyjqym7jT6d3u7gwCxBtEpu5VqnCXYhFM6Epw9Qx5ljw(H38p1rPKvlfc8EEYPeOuYEZGAa7Ykb)gwoxWqxVjFJIApkID8pO6Yzk80ajnSJmQ(gavObWsQLWPJCFjC4uHEA1UJs5Z5g5t7AYMy6zVtOUSespOvvn21ZOony26Cpslvq(U6cAZw29Ch2jWehjaqKF5yeJUVAwTimjoGwJiddJJvRQyBhuo315lUUwdPjVhh1d1UzUCW7Ibsq7uUbgLzjBeM3ZPP3HcZjLhp2F73EZWDxtp6Xqee)aZ7v(9MOAf6JknbYc6aT7tphvwN8tjWaADH(6pq9oOrMhDZ7BSmWkRLTuUNMerkN0sUNNoQuu3RVF5ByQnykxBssE2bP2dWzJvhWg)A82IWoORuDZ5kBzAStQyCp)Yyb5gODB2wMmsk2PcixV64TxJQdChFZMj6tZDMU42LDTQTRssg1VppoABABBNyuIQynKsk(9mSaKcIsd1ZGRc)SrDxDLT8m2ra)FK5gZBpwwIbkbmigubioViToQKmsJRTr)oSZ1(E0KoSh513rxiCFEqKDLTCY1TWEz5e2l1sV)2fWSSC7neNjjGfvlB5vtBB45kbo6Xau)0W0rcWhnnjzF)H5eEI4gjgKSujvtMKG2afbEftbJTCkPm2BsZxeMYZvZy3jRHsIlsZZJtbE0qAHe2Igr2A2FyFuv52qBPbCi1Fwp52J0oWVjN()xMZr3RhlKKs8TXfBWYTfpCLmLKp1PIua(EH(yrJ)zlvKU3PcWOtOugDMChp52Nj8ObgRQ0amP20PZ0KQyOrHrRWGQgeg9F2ceqCqfiaG3MGsJtsnbIkeVLVA4NQZXHvORnEJ7bL2kbjS1Gwk9SYbqKZg1QKRitoTz6AGIaEJvyV2iuebU4IE7JhJ7nMGa4foakkaocbORJda0KX3skIwLqwAdJTMKTJxsvZmgBGOITKuWN(cynterkGsqoTGgfwqf5wIoRbwbtXqIMSKyvVVRbRuu1EvWiyeU)QiT6khw4UkqsRnlD63WUNdis900fu3mPX1CBjofyMNG357fq7zw4RZaWURFd90wxop26sCYiwgKuluklzsQ96SZBO7AKBymUAd)2tPi2hr)Jd5r)Pzjw78Ax16f0H9TEjlorg7b)3K0nSlqDrJlSq5Qy9IHB)l7W9JDW4f6gK8UMWG3O4ruDPfuFf3KGw8SUCLdiEi515y)oVdbODb(Jc3SHD9cZKjZJVkbFt)RHfy2zfjRIhbOy2W0R6B0PXFrjIQ4j4kCkluskgQHnVGwAvyGIUbll8FfWzSL5Y8o2T6SrFdWexSAiA04jsZgTfI3wIVRBhxe2ooypZuKT8o5k9imU1AcUEoY8oL2iWB8sdg5N0KHBDJKv5(SOmyEdaP1)C9KuGvDn8VCNQfq4NWyTbKuWQamIIWa2fs9QlNnYtIuCd1xnteZg5eN8yjozxsaE37mDbazY2sWtxuq4XX2JCaA1SkC)WU6QiSKV7tqW3n7faM6b(8VviUxbtv3yAC1U8thMyQFQ0bf5U1W24(cn3U7WZAJ8nXX)Sr(TIjTvsZz4u9uJgCfbYUlHefsb9mpl5JCbqtTS(Sk1v73CVY1WkBU20DZZVzZHtSmzkh(vbCdA)YldweMTpxFYzDDLDH8YS0RdL9w3tcXurur83pGSUB)JBlek)lLA)zgQFiF7UR3Kg(GUj5Yx8k(1BGF9c0llfqfpQqkMpjSKxZk8k8UJWdSfnSWjRjosKJTTBpiA7aVx3ipj7osAoIIXSMjyqJ5v)9tcvm)tOhHl1ZaTMQW(08HCIc0yLA1uM8t)3F2pUkbDRGFvn(GkXG3DS7YXoovea8GDiVXDrJz33O1YqBOw50l7zoB7euSgJT5PpfrWoCf1A0FVHsFgViOXvl27fuxkny7T7gJ8mbVYzebz)G7lRMHSwpzxrGTLlpGPxrZwGzBrk356Q7osCUWpIoSu6WHKEgLUQ6NNFWTxRkDpXg7wLqOAKh4J5Txx5C6HoNvL0f0Qs6zaIFpxsrDqfnZ7x2vB0iwTh2si7BZhw(zoUhraS9lVnztT1Bt)IyQSf)QOJrXUIsuD8uvaMoMP3UcGpqqb77zdFUypsmeD6)Vl77osN4e3zv3ovOPxOzWUnDVtHa7Cm36zpzWMDzOgQaeocifMbn1KQGks0QSK)d9M1lznwGC3Gz11EVK(ISxNQbHwvzwNJnxvqcZ0eRb7mHk9QBNwwDoAQj1KaEpEDUJbOHSI)Grk74xQuw2JtP3K16BSADcDXqHXfCowPd1ieO3aIVK1jrdT5wHFbZFvmxs5sclsgcXtgPXUy1nGhdh8EtUyrijljai2suf7tDkXpT0uc39M8EQp)iPZVDyW11Yuhoi0H57i8ERyX9i7l1okYkD2SoYZaAzq87(ysrThpIFLCxszePGM4k1ZHuqE3rkkXrX7CPJMC1L3hwGLnAjGF6v)6V8t)YF773D9UR)nCZkz9M8cbeNVrQe6Bq(cl86i2i8oRJ3OX1iG(D8(EaiD8UFMExDp97XEoka(SG(ZFtT)s)RVHP1t9rcRaWp1F8NgiNLx(zol7ExlRo5nVA)wDtnOlzQfLKv9tCT2EIZbES7V(p(zJj7BFQmkZPRvowuC5(XRM9ujT(tuwGN9KNfv20ytM(tCAmPMoU3XxrTYJvYxX(XRN8uxE2LQEYCl7t34rp15RRcN0lZ4(XYg)zst2v3PCtNGxcVRtIjRXDG6FPky8t0LdofFlq1rmtd0wIm8Z04KfbAXpBm6Pz(YeeYXF5VaMEnBX04dT0MPXhx3QPX)1xI2nnFEFEB50cI9lsBNwWB(qb5KxZMG3XiZYHstehn)fQxlA7JW1fI2(ORRRKJtwo3zP084JoRDf7ZRO1yy9hnlYXJBC9JNp(uhZRMdS2ErCDOGi2X0Og5F6B0LSfj2KEFiUpl7QnIVWCSr6bJGMz54DptTVo50dKT4iYXO7HZ1IMXXuVZNBlYeB3aBFECg5I5N9h0hHE4)lsZMZ9cWXngf30ncRhF1P6L18X9Olw7TPUhFuBStCn2Pnh7uxJDwZXoZ1yXwqhLP(1VzX5M)BVpGW51oAsi77K1CVSN9rEH6)ONTCdDXKEnVKWNd8HEhinq5sKQP8dD35lwFzZnFYQjuo914598FUDI65w9o4MkbyAzLriaasMe6FcBeBQuVHDf0wOhMY5N1tlA1xCwppHe(CEByttE7I5ZoPpkPD(4rdoKXJ)60r1uzdf69unUjaX3LYw0cj47Oqw(ZwFsRDXsf)BWfvlqpnnPVNndmpgxn7Rq8JOto9iBDuTdNm6O26KAkJXwuUpSEQn7CA4Bo50d77xBWSbm1bppDOS9ENsVOtoVENRbRKsMFH75y)x7EU65yTZiytSM0QdBCZvVTn6yjQzCJF8rnvyWt616ep9XhTMrk1olw7ZYS2qkoRdZH4q5UNqhbRDMnDcFcYBph9YlvQtVXH1KGUaCu6i1U6LLxM2pVuFUr77s9N06wxc3D(rt9ydPSN5y)rcjPd8KRVEfo7ltEHDC(PgFnQtBQJOHnAaPsV(h0mp(4jG8o1GGoPzEFVyo2yGArGD2GE99uGjN3Qe)mfWLwnbnWc3O5AbzjEPdGb9zWloxWlAPbj17akr0S1iP8QoAls9oWEdrYY6VULhrp59hBNlQj5iAOs0degoJ84Jh0VnNh61xnIDtPrSdD74XhvF(m2ZhpOhJ0o)SrdOhtrlYIOki1m(829FQxZGT45Q5M)yLU2dlamhyl)9CmYM3mAN)G0Y00HNsxu)5Ql)OXpWdKggfBYv(Sw)6Fm1R69XAjYM9PQTtPg)MEhy2iH65fUhckWxxfP3bEGA6aRaEA2WtOt71mnOxao(zSMzLnpU663PW1z1)EyjDslT8NhFSWv7(rBkXJHUwI9SEaWrPZmFeB42AKpmxSEwAopM8tTY)(4L8QjNj)0sFtW7gFTcO)WAUonolAq3T6qpiOZiIlMF2OEoo949OG3kjdWPbytkA2qD4hsS1eDAdLC)Xhn7W(EbFDG7QSAWa9tHi4aMwBZ7lSkOk(18dmO5QPtmOXwHfCk7HcRo06BSP9y(KXiwhlX3BEFEBU5IFygWdoWPs5(2zhTbLBaSLMxw2ZW7Qt9d3DAt2g2Zy8WzSV4gBLzm(S6ZKFTAJmTAU09sT)bArDIFMXbi3pFS296FqlQ)aqz(S71s8uvDiXHn)lMmW6XoVnfgWKPRrq1pPzYLfgN)e1wumLpAKKqEtOz(4HNAtbsZopdaPUXzHZTDSbuNPjG54SLAyvQzFFbAhlTYkSSCb9zthDIR2ZshwrnnHAKI09sp0eUhXwSuAx)4eq2vZRb5TYQNTBOAdZmnYogfNOF8PMQvAlYNUXf4Gf4xrJ)pinQbfE6xkmrWp3EAsxqo1)ZrBNtUMtOZMWsEQgIDirZCz1PtQgYLV8iNnSKM(KPwlf9FkftHWV(APOPJ6zOCYoFd15FCsZUicQC0OFHO9i1Q(WDPDiCya)xspznAOiwpxpDKB3afQimoVRzEu9NQJu9Og7T197JAhTTCF9nFlzR9yFElzx8yFEj9g2X(8MI2CapHQU70euPotmdmXfJUBbf)U3XX7Ahd8hFaaUPf7qNnYQOag6WwqEXLvmOw)5NEmg)lFCmNnmdBOioWzBZW)hXzhSqrrJ3ULHJtpuD8ppn0cxlGsFcJ23jhjsnal)A0CdG2I(AFr4QxISSLnxpDR2Ufy8mU67Me63ZT(NEsZCoa(vA2RnmiTJSvZb1EMyJu9thN1ZxqxTxycABR9Sw1CEOw)eBxVzDNJ3QoVuzRxac1SA04E05WEj)vpPjpt8zhpCcdI1xN7bMLTaJIhq5gRWLIDeFXlqS1(ItK7WeznoMTH5R)St0GSCOh8Jmw8t4QQzH)iyg4jjDmt9RpzPY2A1GKLOPCsDn)0YbgJRNgDH(hYnYYdRXMjpRSM2IssBfnM14q1)0J6p5qv89dgOZfXQG6R4TdRfHk7CQoRN6OXJ8edzLqf6rQR13)OtTSiuV6w6RKoS5coHyzkRVVxcWa11)JwQiBO(uoxk12JHLAT(gHSUk7MbfmY4GjLtWgF1H9nRluBbtO9nLlM)YbdSs4nvlRr6jQLwELSrDS3ljCfP6yKt6KhQ3)FC3KYnBwM(pLdIQC7NSvUb2dHZ4Eh0PenAMJU)K0HOCXiDM3p1of18zJyHzuTzs5AglLly8DejsB2OgrZaua6yVZXoaR0g2JgXu3pKAPC0DeiVJSgNIVaFPPi7ZPJdptFMZns4whSa0mwOFPOkVrBGv0F7vttYVeBDSa7BtlD72foF(lvWqAUCDfd8AL1dNy86skxeleT2KuBaVN1ofFX4rTuTATLaTPmi7FT7MrDDN19UJLiB0k7R2eJ7(AKbEiT61xK1i(VXnQPM(nwTkPzYGf4dq(KwB)0sJGYZ2GwFq5DkGgUJK6whoMDjQmacWlhA(1TsyrIh3MgwKBWPjX8Y)IrG0ZpmjD2VZIBe(a2YR9ajIcDT5kMZINPrLEpLFXq0QZ7xux73ShiQBggDOKGeKYziuqgppSvSRXlDwr6aVRbvBdzSfkb8kA5FxgUKVHzwi4ccc9Cb4NO586schSW3)Yq6ffUKA8wR6WhoOXsCwZLOr9QFmxE4m11mpj)C0Hn3xp6zV6Z5MoBwEf2ncmPDvCTsaZCwZ7N03sPFfQu6x9mKATZImf(RJ1aRQn8hOUzg1RQ0qMECpzy9qWGRavua(YFhLhW3IVXkg)psbKWGbQLqpvswT8uXy0TnPQP()IWSBbpD65X6awSEodz2fIR1yJu42svgoT9t)2YvK0iStk6Ojws1HZDvw5S)fQA2X6VHRszQsKFOobHR3b7U(wzuWmH4JxYlm0nkckmXphB3AsOEJ5JD0F8QWgo1hhCpNkQdmQ)1kie4lQzmvzO9)6ljH8gkA18hS9vilhxMUSp((D13SgHMA1BydToTbT4V9JSdgY6Gmh1T3hpwrR2cMZo8BNb7L74H(w4G99ZcLvqe8tBYZy226wchMpZjfQoUgOPHtNhXofvJWLAPUwOo82qyvvgGzegd)a9(HaAKTfZeFX01bWx1RjKOApAjR(YkvQjIizW9mpSq1oIJGKvUv0CiO3uWOWIIhecuHS7AjxgjtEnlzbdKc)eLG2aOetW95Ujw4DBhV1vTcX88XV0)5VwNb7uA9fMqMWp364BXgX4PTZnCaVyfiWdiMZPfjXbCnfGmhfnURIAKRGpVkaa(HIVyqCqdl8ami00mB0f8lBlTVtD1)3]] )


end
