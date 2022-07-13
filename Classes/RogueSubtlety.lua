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


    spec:RegisterPack( "Subtlety", 20220702, [[Hekili:vZ1EZTTrs(plQ2QyiTKO5lP4nNK2YXE9EXBCwxrzt27Feee5qrSccGlaOK1vQ4N9R75fM3dOSCCU6QSNm4Gb90t)4x)yMlgFXVCX5lsBix8ttgnzYOVD80HJ(ZZMmD8fN38WAYfNVoD(nPxd)rr6TW)75BUQjN08a(dpKxMUaNG6YnvZHFCvtZ66V7LV86SMvBUA48YBFzD2TBYtBYklMxLUSb)3ZF5fNF1MS8MFO4IRC(1NC0fNNUPzvzf8bZU9nWmNTybHnCs98wYy7L)C51BiBF)73Kd)Jjha)hmtBF)23)MvPfxtQ)UTV)WTx(HY7iBV8U0QS0RYjd3utswxLvwL18qsvzdLa3E5M1BVSUC7LznW)vd)nb(JRillRGx(E4)G3d)1H058nL3Evwb8ayf2KToh(R5P55jPZXzljpRgEBsrtvgbMRgyERil2mhg26Yg45zP54JUVS6g2e(H0BGF8D5K6vuMf8PkAivvBwt)ty6HVyk(3lzKZ)Ed(jwKTGrYaDcRXsKDNtsQlZVd(kdV4CKsQP7tnK08MveCt7NOB9KcKFS4IVhy4uYgg0Q0fL3xdK9neg7UkBn7N(b47EoBoE5DPfz1R2EzkYB2S(aoZ5CL3MTOVIuqwsjVQYBHhTczaP11z4oYvLfBaMtAbSeExg()(BK0Bki11Wesa6VDXs)q4Q)20pbm)pU9Y(BkaEvn(LZkUg5FWceybVUUgN)IbxCoq7WJYsV48(WhBZYLd58GH4E9JpYFiBXqF2GTx2dMAyZFnb2mBsRUM0upSE1gCjvKu3uwblJt2E5m2eetOInH3sPTKuoPLurUnnRaO9t3E5OlAafaJTdngpWAymBy5pBF2Q)EqjRCd8G3EoWRoAF2t4)tkd942hbpzjL38R0vA7UTPeRkltUYilxsGHChjbLaltwxccMaTFgq8ZxNaBija3c)KsoQKFbSRcqKGYB7XeHftWWfGGXCu04eyIMWE7WSD8loJorDI44Br()OJ3E5H0D7M0CuzzbHSg2Ma530gWQ3Td57i0pPLOct1kHzzCjDpc3kNASv2YrLkGdRjRRrtm9ITIrbnpkNWNAMhL4RaR21nPxzih998hdgnGVcQZW0xbrK0c0Y09RqvouSDv21GKZh)vG(AW3Iltjg)3NNUanRHRHnRhQUiNxwSydyKeyKGfjW6(IK7iGS(WQ0IBy7lVQLFAnk6NJnSJAhgBHNSajZHsLhCqtTg0vuAtiXfxvMnjDxxUVZpNKOW5lanVVuuFpuYeSXLccEOP6vpuHcvW26rELG4YPfWUtdWPYVHuPjJwTPa9xDnzytwXdG23NYMZOqTHfvM7ivzUS7qI64o5Wy(dZbNp8zg9YOq87fNdd02ccL7b6tlsUN7nqH7svAJVeKsgSraSJBbYQmzrgHQZ3kdbgknut(NRzUUMkEByy9lGhGemidCdyLGHwq3NfSVdGqqoGIUfJXme5GFBN4G6w(rF6c(eq1CgLB3TGWuf6HMYbyM()TpakUxJR0ggfJRRzkRlC(rxSV73ykZGaubL6lxcpTpUNKwaF50Bl3u0Gpw(YdC6SW)gB)UT3IQgCXCyiRlly(o3f5xMPFQQ0R8BmwDoK2s2Vv)gmuJlaaRMeTqR6v6nPWkUgGzTjpzzv613IeSKgPUYinjuaoGWhPAYRsMSEoxKKU642hwwohgI8nnSX8a46kVoPCzYcsAZQeaxCjUgKK0EcdPaBKSiJXVL)QJf5rupxTYEQ8oKJ9N3DPuBuFvKLveeYIPgc1lcocsr9gbU65Pi620QQhecXPaEXn55C5Yc8fOihliFcecpV8TmP21LaAkuQtDJnIq2PsPS5LL5aDxyXL1fjFv3mlfD2qM74rELh7O7Wo4ED802DTRZlb0pOda6NNI639oAlrHd0epQMvCUnvq8)QY66aa7o7uH5AUhXYMea9lQzTifI7H7JgcrO66hK2ONnIAw(65lgcylvaRUcShKGtYf4)hSrVmfI9sgnJyC3Kn)gJ1J5YPCnS8jnTVJW(f(x5Bi8TJ68S5KeqMf8BaoXDQv5eKQLlLAcxUFbb4J3sdCeqBbCIQwrhGvEFQmuUZlaP8RsPVjAcv89Oelh1znqAOerg9Z4a85Vdl0auJj(0GuJywaXkunpbcTaaBFB68v43FHogtoUPBEa(3fgm73SIG6mi3UMqywkuSEqJDeJNM(mmktUFTu0H6VG(BlNpG5o81AeaNJPhOHUioz(k45xdb4bobVfzOtKCtR3BsO3BQ)3BAO3BM)3BwO37i49Cb(mUeK7qWm2uE985meemzBKpxrytjStaA(m0tzxxuYcnjV8(dXTkvzamq6gWmqnlHi0nWrdpQg3ZiZjG)p8nt1sXIClvvgZdj7aMB8LV(I2RqkZsNVOvn3T8Bsvi2iSwwVQjzDoaHyg1neWoO)SkyBVAuDHHyIAnodXn8V42sMyiY8pkWK6nNMiVwSVTPeAvkMdjhFnAI7OinAZnNedenC12fUt8QUqo6YeZBEBnlRmlZQQBcLwfLmfmFrDqCwAMIn1IwVg5jNJJHVeFl7pbIycp1qIG7PQhukdmrnczlOXzm1A8Sb1SsnJsiBfLWiFADwfQIHHqivZy2o)BV5T8ygGFVOKguHxq1UcS8yQSWsm(1eTyWuqjO7lsfJfhsGL6HmDp8S5qnNCcBvdwYFbkB5c9LgV9N3uWqDcm4AyTZSZiHEEUi5nysNfsA9rBwlkPS76YdKjIDo(QRb360Fb5SaZAf7FGIm3LMLJuXGHTB8qWf(sfxBIJablnHP2C6kH35B99rzyKc6)VS9YFK08nabDnnDSGHZ5vPG3J0ROPwKHlJBYMYe4FoUKFFmp(lqjP6MSCA6SbbG5ykQBgmC7L)p0edJSekc)RicrU6SBxtrTVt5H0TQQdUrcxfZcfBCBxtoIgdipeT7YUUujYtuoAK6VZtRlG0NJLoWyDhUhomTpzAEkU0FW1mHJ8fDiLwNjca2pi0LceOfSNqtNG(UlUPZ3GR1q5XzYnRWq8aKRuwTjWtDZLLf1zubfEU6tL6t4htqiiGGvTMUeIFTFOojVWJMqlrVsziBIpK8Jj(vVzLhmkDaZsQsE5zSqwIyOHSI0iZiNrk7XmTSPbzrYnHbhOL((CSWulnQdGmZoQz0XEM6gBRtzu3oD)btUooadB9NiXl3Pp4u1IkemziDDgN11qB2Lcn4PuaJnbtBQps1eKwr)dIwaLEOKVVC(Mwbg0r0NvvGnlJL1pwEpbfkBtBjcIif9pukIe71F8hr)bZt5Luf9qa)znLFaGmcTsOjvGzZK)tvKRjumBJ)w18aWPY1BYRTYVXRuhyonD6j)7nlOPXZCS)z1XEv61Oaytv28BQ1hzdc9LWQsRvsjsrKBOqtn(VStoHC(lBAGFjzzE6dKf3JXOHzX38DcuKPYn5xLvSy46n1nBYjjeScYWCBKDsXWSQySywLK0szjPLX0lbRYeKmiotPEXOVnT6gCPvwXuGv4xjCWPxCoOZeQAdgOJBx38uoY8M7AEDfmJYRltTlsL0T4vKeJ62AZB0kcetgGP(4Oe7g5q7RwLC8NBphPlEIiF0QLRQGmVQmVSAHzIujvSusEvjO4vVgR8b6VGfWznfFo)VXKMtPlmgD8dnAicVPdMMzyB0stUV0MEsNT3lm33HAufm75(1lJsOso9Nn78eD2PqtpNKct1djKpLsHFRkhjkJG5yKzcumj3qUdO7KYY)xcgCJ5KWttoFu3xL2ilwUKPzVQSSROK26UzAjAfVZUflpc8DXW7eDoIrwbnZ4hpcBmxd3xw8nuVuRB9iJ5QL6NMgFuwZqdvCReaXRxt)4PMrikyLKNPTj5HwOm3jbASqbrqQyK3JyLeRHLbIy2NSlHnhKvW(7W9pQb(B6WJyzDPC5YeiGEArInmNs)GUqlX7tb4vpeE1TYUZsnvhNZ)8YsHY68OFHrmueRSeiomSXWVSludSSgl2()tUeAAoahCXdSI3kbmHsKnLL302qgVddRCGOSWSj)zLpzAyRfCq61GLvES4ocNqROacZeTj04wqbbZpxVoexBBSd(l2gF)zViXD7nOcLUaZgNpl1QUAPGZWKnDHD7p4OiiT8O(QU57aSJaPfUTBMC0kteTwzsVq20fnGm1kbgwmav7k(zD9cy6iyxW1(QMKeUrRMYgr0vbdU6JGec3YSuIgqfEinqCEm5RElnAlu9If6fnJMYwG483bw0rWQOfAJEzrkCzybWWDyazW2veMNqGxWBJ2qGFn(AUSqQUy5PDGT2AZyUwyLYIqY0(L5SuMhJZFhlpgSUn9A89Gy5Ey4oK2xPAR4JsRC4i94RTTtevjVDaQcBs0rTvFMbFTvOV8kalabhSTbbvdAj0N09QH2N(b3NcM8fIpBmK(TdbRjoxQxRHqg42IulOr)nbIn2DzRMj7bnotuDHZXS5iIPqO46S5)fLnUa3MGpVbcSMkb6ZslUQh3Iv2xFh0NMTkmdzW)(VicAyGg)YN39(7uF14pefQqLOfjCKimM)KOXWn1TJf)92uqLQWnQHpw(4Jv37XUx9IqfXkm8M)PokLIwPqG3ZloLaLsXBh0cyx2j4xZQ5cM661LRvm7rrSJ)b1woZGNgiPHDKr13aOcnbwsReEdK7lraNk0tu)okTpNFKpXTKnXmYEVqDzfKEqutnUTZOony168pshDq(22gAZv198N2jWfhjbqKF(yeJEOEwTknBrcThrgMUyHAxf7sr5eF6xCBTgstbvh1t1UzTCWZIbsqBvobg1fzRfU3lPL3HcZjNNp2F5xE7WTxsv9yicw8al6v(5MOzfgJkTaYc6a97t1JQBl(PeyaTVqFZhPrhyv5r)8ERLb2zTSLY90Iis5KoQ980r1I(E9dlFlZSbZ4QnjfyhK6paNnwFaB8Rl2uL2bBLQBox4QsJDYeJ)5xMli)aTJ5BzYiPyNkGC9UJ3DpQoWF(nTl0Nw4mDjSl3wvJBssM1VppoAmRTXjgLSk2cPKIFVaBaPK55P6vWvHFA13vx4QoJDeW)VXcJ5DhiBXaLegSambi0xKEhvkgPXX2OFh25IVhnPd7rbJD0hc3Nhezx4QMCDlTxo0WELw593Cfmll3CnXBrcyz1YvD102gEUkGJEoa11gMosa(W2LK79hwq4zItKys2sLsnzscAduK4vSemUQPKYyVoV8Q0CETAg7Vynus8Q8YYf5apAiTrcJyrKTMdN2hvtUwwlnGdP(Z6f3EKMc)6s6)Fznh9VECqsk53gxSjl3u9WfYss(uNksfe7fgJfn)Nr6i9GtfGrNqPm6m5pFYXNju1aZvvEcwuB60z6svm05PZxHjvnjD()zdqalsAaba80euBOjzdeviElF10p1wJdNqxTEJ7bJ2kjjmAslLrw5biYXJIk5kQKtmxxdueWTwH9IrOicCX58oepg3B8Ln465Pv0D4LySrGtNCmdKzljonZ6BWk9WCq9zb16)RI0QpNRiteiPBn7u53YowbiW488ROr1rtJ4MACkWc9aVZ3jqsZCO2MW9Tx(wQWDxe)JUeNmIvWg1(sYrHBI3wBbZuMvPyX0yn8BpIcqEe9pEbpzl2D0S3t5u0Zdd7B9kwAzm2d(Vj5RzNx5kRZhq9Qf69E2U3LF7g7GXl0T)hCnH5krjaK2k53EIYKyecSU8PKXZaUoh7x5hiFTZl)801RzNMVczTZ4RsiuW)AAfwmurTH4jCzbBy6nzngJ2pPKatudUbNYkLAqHg0kRODYeMxMRXUW(Nb36ByrOULDikToM(MWqvZiIgprALowgvJKov)XjimvV3owygxL5Xx1iyCRBj46zFZJWPvEU4DIlYpP1E25gjRr5zb1BEG7OTBC7KuHn5m8V8xzdq4NWyTjKCaKhmIQ0e25)8IZNnkqDl8JSwnX)Zg5fw6yjSuFsab37mrCJmzx1tPlgiceh5(EWiA20RFCBBt7vZ39jiwx7JEVPDGp)dHH)vWu1ngRtsvy6Wec7tLoOaLDMLe)NF44rFolg5BcB(zJ8JcbmkP5n7LbAjcUHa5L5GefsfvNNvRpUaOPv2qEL6Q)BEqWAqtnxB6rvf2T5WjoMmfLFv8TG1VY6KRsl2LtR4SUUYotE2r61HUmR758FQijeHV(DCUB)9BQeg)RLw)zoQFOCZ2lxNN(GUl56x(A(PjG3n)6DbcyIhniTGpjSAfZ6Zj8OAWZJenlSz3s8u3exB3bq02bEVUtEsXDK8sefJzlkWGgZB26NeQy(NqpHsQ6arRmxFA5houbASsRrkR1y4JR6VTkddRGFYi(OkXGhvR7kXl4P5aWdMsU1r)I5334MCHE)vvspBLLSTtWW6c8wv6tZj4fkf1B0F3YOpJxKyDsEdEEWLsdUE7UXipwWR8Mao2p4)SHziR1tEjeW2YLky6nqSdy2oKY9UU6EGeNiIJOdlLoOK0ZOtrv)8Cf3Ern6EOl2TkHqTipieZBNoH3uLoVnb0z0Ma6zaIFpFsrDWenl6x2jj0i1OVisgYJfdlxNJhreaB)8BYw3692mUiMjBXVkUGMyNiiQnEQjaZaZ0VDaGpqsf775cFUypsmeD6)VlVMBKbXjoIO(dQqZUGDULndVtHa7CkU65U2RMxQpwMaebcifMbl1KMKgY8vfz)h6bzxYACa52Iz11R6i9fzVovY)OMmBlPLVg2G5AIDF2mHk9Q7Nw2mmAMj1Ka(aE6Pxaqdz9AbJu2YpdNSI1Mtp4OThq026NIPcJl4CGYfcJqGEni(sUnB(qxHvewW8NfZLuUKWYKHq8KrASZXSf8yqX7TLIfHKSKaGylrvSpTvG(OAtjC)BY7O989Lb)2Hb326qDqrOdZ3(4XeXr4rUxQDuKvgSzBjma0YG439livTr8i(vYDz1Zjv06ePQhsb5DhPQghf7Ec9OrGU29PvyxAwd4NE9p)t)Wp93(UTxU9YFb3SYUDDzLaIZ3inc9niFHLnBeBeEeXXdq4TiG(T8Rzaq649)i9OXE03HxXNa4Zk6p)nTXl9V(gMvp1hj8ca)u)XFAGCwE1N5SS99rwDYd60UT6MAqxYk5jjR2N4BT9eNduT7V(p(rJj7BFQmkZPlkhB(I6DJxn7PsA9NOSap(jplQSPXMm9N40ysnDCVJVIIYJvQxXUXRN8uxEULQEYCl3t34rp15RRcN0Zo4UXYg)zstUn3PCWIGxcpArIjZ6ih9Vufm(b6YbNIVfO65mxd0BGy4NP5jBoyf)4XyKMLlZqih)P)e4618cDgFO9L6m(02l2z8F9L4YDMpVpVxWZcI9lYL8SG38XkYHVHnbVNrM1dLEi2)0xQEiKDpcFh)y3JUTlooiB5PEBCLhF0BNI4EEfxefo)rZwk8aRd77PJpYZ8Qf)QRxexhkaI9mnQj(N(gDPyrInPpqBjD5DiJ4lCkET1bJGwy5fBFMUS4Ktpq2cvKdWOdpvlzghqdo)uxjMyZAy7lqSiND6X)o9rOk)FrUA38Va8C(mXnDJS6XxDQbzD64E0fR7lfUhFuBSt8n2P2JDQVXoZESZ8nw8cFJYu)6F1S5N)7(w3GZR9CLCSRtM9Ezp3J8m1)rpxLg6Sj9SpsUNa8HE7jDq5tKYw(HU78f7wqZpFYPluo9z98EH1BNOQ3QFFPPsaMEwzecGFKjH(hWR9mvQ3WVc6lmat5KJ7PLS6ZoUxGmcFc)spttE7StNDyFus7KXJg8cgp(RZ9xMkBOs)gmJ7cq8DPSfTmc(EkKL)ODRKfxSuj8gCrfb6PPl9D8Q3kGZvZBXhUk6KJ2319x2lMmA)y3BzkJXvsUFr7uBEpLHV5KJEr)WwdMnGzo455(aBN3P075KtA35SyLuY8l8n81)12NRB4R4mc2eRjT6Xh3PQNTfDSeTmUXp(OMjm4j9IoXtF8rNfKs9E8k(SmlgsXzDyoekLBFc3)wXz20j8jiV9CCZzPsD6xtx2e0zqGs7REhA54LP3EwQp34YYs9N0UBSeH789M2XgszpNI3grijTxGs91RY7TGuqyhNCKXxJg0M6iS8rdiv61Fp7Y4JAaLD6645q7Y(E2P41Wteb2zd61pq)LCsuj(zkGlD6cAGdUH9AbzjbPdGb9zWlorWlICDe1BpkryFreP8QEUeI6TN7RFihR)2lyiQM3VV3tq2KJ46lIQqyemYJpUx)ybp0RVAc7Mstyhg2XJpQ(8zSNpEqpgPDYXJgqvtrpYISkiTm(8Ex70UMbFXNQwA(duUJCyjGzpxLVNJr28Ci79hKEMMo8i6I6pw3PoA8duH0WPOnx5ZA9R)Xupy1hOvhB2NQ1pLA(B6TN512tVGW9qqbHUdp6TxaOMEWkGAZgrcDup7QGEge4NXAM1184QRFNsxNZ47HL0HrUGDE8XkFxUoAtjQg6Bj2ZPcGNoN50rSH76AZHfI1ZYvHJj)uR7VpyjVzYzYprULccUX3Aa63TRYglDrd6oAa9GGoJio70Jh1ZJ2tqvHGnsgGtdWMuzF91WvsCDL1edLC)X7p7f9dc(Ap)nz1Gb6AHi4aMvBZtNRkOk(HQdCO57kEyG1wHdCk7GbRoCrZ4Y6XPtgJyDCKFVt7ZVuzo7Vmd4b751OCF3SJyq5gaBPL119mIU6OWWDNAZ2WBOLaCg3lUXozgJpUvN8R1L2su3L(xQ93tlRtCDgpGC)8XA3R)Erm)bGYc53ls(uvdiXJp)ZMmWPAxWRGfWLPVrqTpP5YLLgN)aDjKykFyvKq(v(YPJhEKldi23ZlaKAlDHtCP2aMZ0eW8OBPMwLw23xGl)KOSchlxWE20rh67YqPdRiBxOgLiDNSdnHhrSdpLUTpobKD1IAqEOS656aQA5MXQ6yuCIHXNAAwjwMp9JlWdliSHMWFqAwdQcC7KWeb)CVbr6cYP(Fow78Y18cD2ewYt1rShjAwiREds1qU8v7796bXoMm1EPO)tPzkeX13kfnDupdJtU5BOn)dYSVZoqJJg3ohApsTRp83AhIagW)LmswJRVdN61th5pmqHjcd9Dn3JQ)uBMQhzT32E7A0gOTJJRV5BjVin2L3sENzSlVK(1JXU8MIB5aEbv9FVoqL6mXmWexmUljO43doo(DKXGW5haGB6Wp0XJCkkGPomcYlUSIb1gU(0JdZV8EZsOybi4TyHhXAQX3NNlAcFlG6qsjUzXJe5SNv4lAs7rNeFTpGATlrwzSovVoOUoDw8sHg6e(foKQ(hDODXaGa(mVdmmiT9D1maTHm4Iudthh3lu2qD3XaABR9C2oBbO2WeBxpXBNGN2TGuz0dMGA5gSoFBECKXF1dT5zIp74HtyyF(6C(SCSfyuvFLtscxk2tI)odb9gkbo(ZFJZemgdmw)zhQHL4fba2XyXpHJqMd(JGzGAs6Gz63QzPY2I6PWrAooSTzCIOWyCSXOl0FxoPubynoIO1nRjw6lI1nxotqu)J2V)KxOc8EWaDUi2EsFfp1wreQCZP6SDQ9hpkqYDvYHxaPUOV)(h5yrOEKQ0xjDyZfIoWXu2EoSeGbABmhTAeAz(uoxknDJHNAT7Zbzdp2nhkykRbxkhIxivVOVzdB6kk)4BkND6RgmWjHBBwwJ0Zu757g5fOXoVKWvKAelEPtEoy))X3Yt(zZY6YPOiQYTFYE5g4o3kJ7TxNQaOzXZ(dYn3KpgP3cYPEdoD6SrS8)PEjp5BgRLly8Dev4A2iR0maga9S35zhG1Zb7WfKu3vsD0N4EYW2(otGWxGV0uK95nWHNPpZjgvcRdEaSts5xkQkyAayDJ3oDzgfwITnjD9DzLoUFHto9vkyinxU(soDRX6HtmEDjLlssH21xumG3ZItXNnEuK2ilwLTMYGS)1(wgQR7S(3DCKzJOSVwxm(VVHmWdP1i9IY5W)nUtn16IXAIinxgSeFaYN0MUN2ZcuE2A07dkVtb0WdKu37WbSt3KbqaEFkZphucps882y5r2IttwW7llgbs1Fys6SFNL3i8bSLx8m8HcDXcfZBxTy1c2t5NydTgW(LTnLn7bIgAHrhkvUaPCgcfKXZtBf741sNvKoWdbqZMugBHsaVM2x21Pl5ByMDOTGGWixa(j6oVTxTbp89ppLEaERPoV1AB7HdSwIZSxIgns(bC5HJvxZ8QVZrhAVVU)ZEBHZDDA33dUDcmjUjUOeWmVnJ(H9D0twPk9KvpdPw3SitH)2CnWANIWjQBMrJKkDKPN3tgwpem4kWefGV8xr5b8T4BSIX)9uajmyGAvAtLKv7BumhDBYAST)xLwCdePtVaEhWUOZBkZotCEdTQTAK2)BACTFxfXr6e2lfT)eh1GW7UkRpZ)c1M5yJXWnPmvjZp0GGW17GTxEJmlyMq8XtFfM6gfbfM4NNTBnj0G58Xn6pE7rdA9lsUNtfTjgn8AfeccL1mMPm0)F7PxqE0bD6(d2(QK9jlZw2V9HTTh5fHLA1J(cTbQbR4V73ykgYguSeTT3hvROTbblyh(XMG9YDuPpchSFywOS1EGFADzbZ3w3k4WPZ8sHQJZcnnODUptlQfHl1tDRqD6nPWQQoblvlM(b6b3aSi7kNjHYPRhGVQNFhrByePC7YwiYgrKm5EMkluRJ4iif1Be3Ad0JW380QQhecuPSdbjxgPqE(hzjdKc)eLGwdOeZW95UjweCBhpourHyEY4xfw)l6m4MsBpjdYc(53gFeFeJNgNB4bEXkqGhqmxs7EH94wkazokACFDBi3aFztca8dfFXK4Gow4jyqyPz2OZ4Ncw69b1f)Fd]] )


end
