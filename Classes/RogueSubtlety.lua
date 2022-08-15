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


    spec:RegisterPack( "Subtlety", 20220809, [[Hekili:v3vEZTTrY(plQ2QyiTKO5PS38K0wo2R3x8MK1vu2499pcccCijwbbWfauY6vQ4N9x3ZfMzWCaklNKxLkjs4yqp90h)6Jz0LJV8xU8IfX1Kl)PjJMmz0RhpB4KXZ)ZJE1Lxu)WgYLxSjo5M4vWpKhFl8FVy711zK6hWB8qwr8cCaQk2wMa3CDD9MQV9LVCvA96TxpmP42xwLE72S460I8KY4L14VN8YlV46TPz1FF(LxB7R)65tV8I4T1RlkHpy6TVfg50fliShNuL0qg7U6NlwTLS7dVz7QTv17U6pF0URWXA3h29H3UooFfP6B39HJ3D1pwChz3v3fxMgFDgz42ks0MY0IY06hIklQPK4UR2Uz3vvf7UkfgQ0k4NjWpCnzzrj8Y3d)l8E4DhshZ3wC71P5WfG5yD6Mm4NsIZYIItWrlklfPisEDzkbgRAyCljl2Map2MIA46PXz4LUVO8g2a(JX3a389zKQ1u2f8PYRjLLB3q)ry4HVym(ZlzKZ)MoPxKUGrYaDcZXcKHNrIQkYUd(kdV8cKsQORu1K4S61eCz7NOl(KCKFS4YVdy5uYgEO1XlkUVci7BimgEz6g2T(E47EbBmE5DX5PvR3DvmYB2U5ioZ5cL3MnPVMKtwsjVYIBHlTgzaXvvP4kY1f5BbMtComfEFk(F)ej(MCsvfmGeG(BMS0peo7Vn(ZaZ)J7UQ)2CGxvHF508vi)dMGal4nvv44Np4YlaAhUuA8Lx0h(yBxUCiNhmexRF8r(fztg61gS7QEWqdl(BiWIzDC5ksD1WQ1BXPuEuvDrjmnoD3vZydqiHk2aElL2II5Kwuj5240CG2pB3vJUSgubmwo0y8aRHXSHP)SdzZ(7b1SITWfE3faVA(HSRW)vkd9KMlbxzjL38R0zAZQTPeRkltoZilxsGh5osekbweTPaembA)CG4t2eblira3c)KsoQKFbSRCqKGYB7XeHfdWWfGGrckACkmqtyVTF2o(fNrhOorC8Li3F0X7U6y6QDDCgQSSGq2altG8BCny372H8ve6NSLOct1kIzBCjDncxkNASu2WrLkGdRiBQqtm9cnJrbnhkNWNAMdL4Rb72v1XxBih9D8ldgnGVcQZW0xbrK4C0Y09RrvouSDD6kqY5J)kqF14BXLPep)3LfVanRHZHTBgQojtkYxSfmscmsWIeyFFr0DeqwFyzC(nS1Lx3WpB9u0ph7XM38ySjE0cKmhkvEWhAARh6AkTjK4cRkZgKURl336Ntsu445HMpukQFakzc24Ibbp0u96hkrHkyzDUtjiUCAoS6udCQSBiLAYOLBZr)vRidRtZFa0((CAcJc1ESGYCZvL5sVdjQt6KdJKhsaNp8rg9YOq8heMdd02ccL7b6tlIUN7nqH7svAdpfKsgSNayh3cKvr0IucvNVrgcmuAOM8p3WCDnv82WJ1phUasWGmWnGvcgAbDFwW6oGjb5ak6wmgZqKd(QoXb1T8J(0f8jGQ5mk7UBbHPs0dnLdWm9)PFeuCxHZ0AgfJZRzkZlC8rxSV)tmLzqakNs9flHR2hxtIZHVC8TfBZRXllF5bwDw4EHTF3wBrvdUyo8iBkYz(o3h5xMPFQQ0RDBmwDmK2soSr)gmuJtaaRMeTqJ6v8nXWmUcGzTnlAzz8QBrcwsJuxzK6ikahq4Juo51rt2KWfjPZoU9HLfjWJiFtdBmpaUUYQIkwgTGexVocqgxGZbjjDGWqkWgjlsz8B5DTmjNt9C1i7PY7qo2FE)LsBJ6RKSSKGqwm1qOErWNGKxTvGRojgr3gxw(GqiogWlUnlJlxMJVaf5yo5ZGq4ffVJj1UPaqtHsDQlSbeYotkLLuuKb0DElUSUi5R7MzPGJgYChpYP8yhDh2b3RJN2SQTkRaq)GoaOFEkQF7ROnef(GM4r1SIZTPcI)xxuv5by35NjmxZ9iwuhbOFrnRfXqCpCF0qicLREqAJE2iQz5vjlgcylvaRUgSheHdYL4)al0lJHyVKrZiEUBstUXy(yoDk2atFsDZ7iSFH)u2wcF5OklnHebYSGFdWjUvTkRGuB5sPIWL7xqa(4T0ahb0waNOSr0byL3hldL7ICqk)6y6BIMqfFpkXYrDwbKgkrKs)mwaF(BWe1d1yIp1l1igfqScvZJGqlaW23gNSg)(l0XyYXnDZdWVNBWSF7AcQZGC7kcHzPqX6bn2rmEA61WOm5(1IrhQ)c6VTizaZD4B0iaohtpqdDrCsYA46RGa8aNG3Im0jsUzR3BIV3BQ73BQV3BM73BMV3Bo8E2aFgwcYEiyglkVjjHHGGjBJ85scBiHvcqZNHEkDvEbl0KSI7pgxQuLbWaPRbZavSeIqxahnCEfUMrsiG)p8nJ1sXICjvvgZbjBbMB4PV(K2PqkZsNROvnxTCBsvi2iSwwTUoAtgaHyg1neWoO3wfSTtnQUWqmrTgMHyh(xyBjtmez(h5ziEAAI8AW(2KsO1XyoKS81OjUJI0Oj3Csmq0WvBM4wXRAd5OntmV9DvSSYSmTSQ2xAvuYuqYIkV4S0mfBQfTzdYtUaFg(u8DSFeiIj8udjcUNQEqPmWe1iKTGgNXuRXZgu9A1mkHSvucJ85nPLOkggcHunJz78V923XJzaUFEbnOcNGQTfy5juzHLy8RrAXGPGsq3xKkgloKGwQhY09WZMd1CYPSznyj)fOSLn0xA82FEBod1jWGRG5oZoJe65fIK3GPDwiP1hTzTOGYURkosMi2e8v3aU1P3b5SaZAn7xqrM7ItZqQyWWMfEi4cxPIRjXrGGLMWutoDLW7Cn)(Ommsb9)x2D1pqQ)gGGwrthly4mPmg8EeFnn1ImCzCt2uMa)ZXL87JzYFbkjvvNMrtNniaKGPOUEWWDx9)qtmmYsOi8VMie5QsVDdf1(ELhs7QQw4grCvSwOydB7AYCAmG8q0UlDvHsKNOC0i17ZtRlG0NJL2ZZApCp8X0(KXzX4u)bBJe(KVOdP06CraWUbHUuGanNDfA6e0xDXfD(cCLgkpotUEngIhGCLYQnbEQBUSiVkLkOWZvFSuFc)yccbbeSUX0Lq8R5d1j5fE0eAj6vkd1M49j)yIF1zw5bJshXSKQKxEglKLigAiRinYmYzKYEmtlBRrwKCryWrAPVpdlm1sJ6aiZSJAgDApsDJT1PmQ3oD)EtUo(ag26pvIxUtFWPQfvWBYq66ioRRH2SpfAWrPagBcM2uFKQjiTI(heTak9qjFx58nUemOJOpllbBwgtRFO4Ecku2K2seerm6FOqej2B(4pG(dsI5Luf9qa)yfLFaGm8ntOjvGzZKFRsYkcfZ24xPMhaovUzBwvR8B8A1hmJMo9O)92f004z(S)z1N964vOayDzAYnv6pznc9LWQsBRKseJi3qHMk83ANCc54xuxd3jAzw8dKf3JXOHzX38D8uKPITzxNMVy4MTv1BZireScYWyBKDsXJ1QIXIrvsslLLKwgtVeSktqYG4mL6fp9TXL3GtTIsMcSc)kIdo9YlaDgFvBWaDCZ8MNYrM3CBJRTGzuEDzQDrQKUeVMezu3228gTIaXKb4Q)wQXEy4hCqa6jZvUUfmkQtPGdMtXbld)mNKuwKvuktUSAHNSMaLpTofdzI7R(JQedg8WDfylhKaSgwDoAfmcZoMrTfPDurrbhVX10XNSaRZ)NtiBejg4VZPNg4gmEruRCl5ndLslD2E7UXiprWRAxmpU7MqrRy45RNmT4SLChI0EvUdpVAsdTkfZI4VcRub9RIjgbJpA4RM3PPsWKBlQAH9pp4sBXdkFiNdYXERDkLINOx)IwmV9kNJuLoNnNbex6izvwcv6vrleGwpyKF7UhOLuu3qI0xeBRwCG0yb8xljd96)Bs2gwxGW4aCDUFg8pSTKabSDXnPBAYFGzd1WWZkUROLbyyuHzn3eawO0FsLjPf7a8bIkzFpFEkepIo9)3LfELtYnjTGgvnlQvA9NWy5HFBOHDbdgitMv1EHkbUpnfqxkZCltac)CsHzWsnPoQMKSop9)S1e0IR6hlzwDT476tsJKf6UaUHfuN4KxWfJNlQW6eQ0Ros6bcMPMzsnjGFeZN3caIedFSiMhwwfUNMdImAQmAszbiVYNci6tUGZrkLOuiqVbeFj3MMm0w2)8ly(ZIXskxsIlX8ijepzKglZAkDFdZoiO49UcXKqsw4RsJAKnf5MqnYh38ktjC3lY7P98dzPpRxNE4tL1NSdkcDy8oeBbfljj1(uTJIS8ikvWANfNCdi(Dpe9vt(bf3LCxAvcblXAly(y(bSGVtJ6caBWrdYz)MA85PdNZsBDXYLrRswqv0nWJs)G2c3KB1gE1JHxDNS9wvZv8f8pVSxsyTU5VWigQwlRcmd9Jd7R7e1q2XyY2)FYBo04mUMd(DLrCILpOUO4MguQVhDDoq0xnSb)zLpzcQRj6Q4vGqkpzMwG61gJNMJSBby8zeHVSWDgZ4a6081NdcGTWzwzuAJ22jkXTnIZrZnwCHzbrxdpQVAl50H42Arv2Ahul9ckrRxq17ei6KgcTVvgGBXay930ap4G11nAB6WBBe38QMKeUqRI)vKEkVzN6JGec3pQuIgI64yQpjEsnx)oPJjwmF0scj7HSlEp4DcJ2hDwzGhrkCzybqL95xgSzgHfAb4f8DIGVShy81SzHuDYY9aZMBnLCulVCYU4GP9ll6JmrWx8EgWzw76VcFpa85dd3J6MjvBfFuARxWwX9yNiOsU3GfvBFhgk5gH(IRjGwl(WTniOAqlIEL9ksNXuV)Zev6OdrEDG)GVgOGS0qHucz1Dx0jN8T7vxzt8YzIQtCEhI7b1EfPK1(wxxKtIQ2WAF2oA(hGap0YaeHxVon5gQeOhO4tKlRUBCR(009JLya(9)cRIskPqYR39(7vJj2wuq81OcvIEmZsLeM3gLNTC5m1UJf3nhQxLkxmSXEz5JprDThB)FBaC7i8M)PokL8gPqG3ZRUVaLs(7qynC4qYTsZkwrRXGL3uSrXShniE8hO2Yzg80ajnSJmQ(gavOrClTs4QthpTRvOruGMoeiWaf6jOFhL(p2nYNWwYMy2JPoH6Y6ONbbn1y3oJ6WmEKVN0YwWzxthbxBP9iCN3EWfhjcqKFXyeJUV8ougNUiI2KDdJxSqDBzytr5ux6xCBTTZFJB1r9AvAMlmCZSHe0oLTWwvE6gH79cA9XPWCY4f06x(L3bHQtv9yicw8avhAjppzqa858oWrqhOFFQEuvt3JibgqBS(3(rA0bTADd38(wtdmJBSPclnduoPLM3z6OkXgh4hx(oMzdMX12KKNvqQ)aC0yb2BC3M0T05fh683DyKpjBXteszUbAhY3YKr6DyV1TxK9M8FG7ce1Utj0cNPlHDz3QAytsZewz(Y4OHS2gMy4Bqd94OO43ZXo4mkjlUuRfyu4NTACvkp11gHlaG)pXcJ59hj7rlLegSambi0xKEhv6MdJ99w)oSYfEnAshwJ8g7OleUppiYOmB3BpnFP9YIg2R16pQTxdJYYTRioRYklRw1wAmbTLHNRkGlwkS1acthjaF02LK91hwq4PIT0Du6sLA1BscAp4T4QfnnKJTwuELNDvwX1Xz8IDp2D1UPK41zfflYaE0qANyhWIiBo7pTpQMCBzT0aoK6T17oOrAk8BkO))ArtB4E(yHKuZ1lmzJwUT8b6q5oXYDyOiLqSxymw08Fgyl94DOam6ekLrhj35to8iHQgyUQYIWUcIoCMUuzLG7(Y4n0XGKrsQllQq7ajrYoMVzid(K4hXvAnXkCGVBsbG)Cd2jbaZhRfrvR5vn52nCJrSiyckhkMlE(iiT5YRqsCYAmRYrXj)NTWkWIOAqdOYK46BdjUq)w(QXFUPuUwXU36nUh8APKL0GzTvgAPdKyNmkild7C0owmtPgERzyVqekgcIyPXhpgxBmDIWB9muxaKZGWlwebWPxCdPmzDkzPTGm0uTD8sQUMWKJKuULKfTkUeMZerQsOeKZCgMexs1cwIrRcWaYWCcNUKy1XNRhwzB50jjB3FvKwDLtjCvfiPBn38nVJTt5WqvYYUMgNnnXUBRWHalrj8oFRi2ggeNMsGS7Q3rn30fdsbNItgXkHMAR2(KAvQU3OlIelsB2LJXTiZRKnsTTnPJZnUBhkC55myndc38fATfX6f6Tt9(3467h7GXl09i7DoHzVsjKWMJzGMnjTe1MN5LlVf8AsOZX(v(zmJ2rats8Mn0OUrZv8QzYNLqW5)vwz3fvRJNcSf8oqtBFdz2NkOgCTOtwej8I10l0MZfZu2kCJfjRXpkTtpxaADYZygyGwD5v5js3gHYXDGeC7oYnHVJd2ZsLzRWBUQpeJBDlbNphUZ4ujOvMhvAtNeCZMyDHKT3VyPzXCpK7UxFCuRjq4NWyTaugWRa8eLXrSJ0GlVy2ipvsYDSoQLIz2iNbkmwgOGljaVRDMXaHmzBv4Qlgi8ez)HoqTBUpo(4UM(qVIV6tWOpsBDAYyAh4lFFf6EgmvDHPvVT6NomdQ4Psh0qxSM3Qo2Ek2ZztiY3mqMNnYpiM0GKMZ8j7Pjv4gcm6qkwIubDEw1x5cGMwz95vQR(V5PLqdRS5Ctpox)UnhoXYGPO8Rc4gS(vufDDC((0BOZ66m7C52HuH6FgQcZurAH8FIYzD1(72wkm(xjT(ZCu)qX2DxTjl(bDxYvV8n8nihFdQP3xoGjE0G0IkL(N7(I8VPEhTJZvBIU0BjoQKLTLBpiA7aVx3jpj)oswbIIXSPryqJz7)Mq9xwiedFfpkOCNREl9BNA6hTTNe0bH2UM24g(nskACSumPfM2rdfr5guMDwN1doR7kcDVCKwYpT843XD1bcsOso9xm78uD2PilLzG6t01per(CmD)7QkhjIa28zKwYedYnK7a6oQO4)LGnkJ5GWpND4p19LYoktHPzPZjQn2yskN7nkCtla6Kjri0rMNmnSiWubO2A9JveZJmeE10rOVCRqueVYwhkoL1iZuCuPT6w9wbNYTJ0p8z7GquO1PeX0DYtjcC0CCksmwp330RDYiMLEQnQ7iLvidID2T(QjayG7JlX2(Q6Yl(0B(5F67)P)23U7QDx9lihk92nfL18553iZy(3GwKzzhcfqWnTpULoVfxC3Xp4hGGb(Wpq3SYZ)w8qxfSDwsV930yG7F9nSibuVKqUcUv)XFEGCuE9x4OS7dbMDYTE2(n7MAqxs9fjz1CfxZTN4yGTD(F9F8dgd2REQmkZHlihlzr1(XRM9ujT(tuMGN8Khfv20ytM(tCymPMoU2XNrb5XkPBB)41tEQtp7svpzUL9HB8ON641vHtkyS9JLn(lKMSBUtXsn8sOTAXG1Yg()svW47PthCiEfq1jmii0ZeA4242RSyzkgD4F6pb4LnpzTXlA701gVEZjSn(BFnoLT5J7Z7jTTGy)QCABl4nFSKC8BzdWhyKz1qPJHdp7LQ7gC7pHR9bU9NUPAWhLU8mNfa)XhDwXz7JR4ebX6nnBnPJATRRpB8ChJR22202lIZdL9bMJHrnDv03OlP4uSi9J0wBvEy(i(cNHNFGWtqlhYIDptNAFYHhiBHkYryUtotRbpoIMKMZyPwW8q5dw(8eeY5NDYVrFeQY)xLZyp3tah4CXfDdyY8zNAi8NnUhDYA)057Xh1E2jUE2PTF2PUE2zTF2zUEw8K3JYu)9)mYZn)3(XFcNx74SrzFhS2RL9S)KNR(l9SLqZZN0RDOnNc8HEhek0jlYp0vNVAhhDU5twDHYPVwxVNF92jQ6T6hCDQeGPNvgHaWgzsO)b88NtL6n8RG(c9Wuo9KEAPZ78t6zZMi)UNYp950K3o)Szh3hL0oD8ObVGXJ)95GKtLnuQFuYXDbi(Uu2IwxR9bkKL)OD8WfwSujQgCsfa6PPl998mqZJZvZJtjUk6K5hA7GK7ftgDyOdqoLNXw7K(IMH28aJdFZjZFrF)wdMnGzo455GzBVxP0Ru6PnRCTyLuY8R8rT2)1UNRJATWmc2aRjT6Wh3zQ9iVowIgg34hFuZegCLEbh4Pp(O1AxPEGQfEuMfcP4SomgcLYDpHdcTWmB6a(eK3EoocZuPo9ZlT2e05qGshQEyMz5LPhJzQx34ult9wAhszIWD(ot7ydPSNZWQ6GK0bEQOup3vtYlSJtNB81ObTP(eT8rdiv61)G2vkc1a6wznoUDjno)mSCgbeyNnOxFpfz50Gs8ZuaxA1f0alCJ2ZfKL4Loag0xaV4ubViqzD6DGJc6O8QokMtVdSxghlZ)Mc1q18(TTElTjhrzGOkegbJ84Jh0puWd96RMNUP080HHD84JQxFg76Jh0JrANEYObu1u0JSiRcslJpVNzhnZzWx8zQfN)iLZAdwcyoqTPGe7MdogzZ9ZOZBi9mnD4C6K6pwNnhA8duH0WPyBUYx08x)JPUbnpsRdNzFQg)uQ5VP3bMh)h98c3dbf47SaO3bEGA6aRaQnBej08ET3sNNdb(zmNz96jo763P01zn(EykDCGdQJhFS01H0H2qIQHUMI9SQa44y44SrSh32XVbleRNLJudt(PwplE0sElqYKFcSBN9UW3ya63SJeJw6Ig0DWa6bbDgrC(zNmQNdThVQcE7JAaNgGnPS9XGbxjX2rFriuY9hF4Sx03l4RdC39VdgORfIGdywTn3LFQGQ47nfWHMRTk(GwlfwWPShgS6WbwHnRhNnzmI1Xs(9oRp)WP48)YmGhCGtJY9TZocbLBaSKwuv1Zi6Q5(H7oTnBdpPh8WzSp5gBLzm(KgDYFVo8hc6U09uT)bAzDIRZ4aK7xow7E9piG5pauMp)EbYNQAajo85F(Kbwv78EuoaUmD9eu7tAUCzPX5pqhMbMYhTksi)OJ4SXdNBZas7ZlcasDlDHtTP2aMZ0eWCOBPMwLg23xHdrHGScltxWE20rh76qvOdZO2Uqnkr6EzhAcpIylEkTBFCci7Qf1GCRe0Z22QQLBMwvhJIt0p(utZkHY8PBCboyb(n04)dsZAqPNt5aMi4x6jrqxqo1)lXANtUMtOZMWsEQoIDirZcz1zqQgYLV(qNhZaTJjtTxk6)uAMcrC9nsrth1ZW4KD(gAZ)O0279F04OXU8x7sQD9H7w7qeWa(BYiznogaSQxpDK7WafMim031CpQERMmvpQ1ABZU0VjqBlBYuZ3sUH83N3sU373NxsFB2VpVPyV5YYmDO9wV)329(ExsrgBQEhRQ()mE2d3uvdtGnmzAJ9nonidVphF)WpWFsmamXwCwEYiRZmm)MbGhYfOnOw)frFmMKoFCmNBfDBqDoW5gs3)hX5EdxXAO39HUtHH)eUvVFo2Q4UMav(0ySVsosu)cwraPfWaDy(79FJkAMISs6DMEnHT9hObEzH5EIS(h5d)Hx2F(XTlmce8R5gfWG0o0wJr0e(Kns1pDCspFzg2E3tOTS2ZAR95HA9tSDDZVFkUV39sLb3mxQLEr9JrHQ5WPo)vpUnpt8zhpCcdh4Vp)jAWYsGrhoOCyYZLIDKe0ZXaa8Lml35YYAYwdbmT)SJ1Wv9cpGCzS4NWFfjSWFemdutshyx)gnlv2wqhsws5ZXnnMuafgJ)YrqNO)M8hlbpSgBU8SYAcLkNqD2M1KL1F(H9N8c1GqgmqNlITQ1VJ)HBiGqLDovNTtD44rEs0Ts(m9i1f89pCULjH6Fvf0NjDyXfIuYYq28NIbbyGMMusREPTmFkhlLgqYWtT2oYw28NDZHcM(EWLYX4rkZl6B28Q2Y4r4fLZp71dgyLWBBwwJ0tv7)9A5wGFVNs4msn6nN0jpF0))4ZPf3Szznkvuev52pzVCdSNNPX9oOtvd1SqI)b5SxXfJ0zXjvpdwoB2iwUqvpMwCnIvYjm(oIQ9nBuRuUagaDS25yfG1)f7XrCs3vsT0Z8oY24HwtMYxHV0uK95mWHNPpZPgvfSdEaANW2VwuL3SnW6mX964iXVeBtcl7BZkDy)cNE2RvWqAoDDLO(gJ1dNy86skxKleTdGKqaVNfMIpF8OaTuxOQ8nLbz)37ZjKUUY6E1XsMncY(ACX4(edXapK2MkquAl(94o1uRriRHQ0CzWs8biFs3ac0(3GYZ2GEFq5DkGgEGK6EhoITtVmacW7zB(Ect4rIN3MwEKBXPjl49OgJaP6pmjD29z5ncVaB6forIOqxOqXC2HpTAh9P8DVIwZO)YMguNDbrZ9WOdLQ4GuodHcY45PTITdJPJksh4gIOEBmJTqjG3q7r9Q4L8fmZUvxqqyKla)eDN3036Gh((xet3dZvuN3ATW(WbTMIZApfnAQ(J4YdNOoN5DIahDy711dF2BrEURZ29aIDNatcBIlibmZzJ5FCFl9NwSs)P1ZqQ1olYu4VjxdSwlXFI6Mz0uTshz659KH1dbdUgmrb4l)vuEaFl(cR45)okGegmqTQoQsYQ9qlMJUTP1TT)xgNFdePtppEhWok0zkZoxS3lBvN5aTc50WA)2kOL0jStk6Wjwk1HZvvwp3)vQL7XMeIBszQsMFObbHZ3b7U6gzwWmH4J7enm1nkckmXphl3AsOEZ5JD0F8wfh06xeDpNkAsmQ)5kie4lRzmtzO))MDYHCBuA19hS8vk7zyMTSp9J7A2(pcl1QBdiAZKdwXF)NykgYM1SaTT3hvROTeclyh(wiH9YDuPpahSVFwOSnNGBTPiN5BRBfC4SzoPq1NRfAAq78qMwudcxQN6gH64BIHzvvew2Am9d0nXcyr2wot8LtxhaFv3ltIwsjqRhiBNQ2iIKj3ZuzHADeFcsE1wXjybD7mMexw(GqGkMTHq5Yi5Y9cklzGu4NOe0gaLykUo3nXcVl74wdlieZth)A)6Fbhb7uAZU6qwWp324d4Jy80WCdhWlwdc8aI5cANCCa3sbiZrrJ7QZl5g4lQJaGFO4lMeh0XcpbdclnZgDoFhbtp37sWZq8X0thRl))(d]] )


end
