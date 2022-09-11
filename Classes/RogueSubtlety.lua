-- RogueSubtlety.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

if Hekili.IsDragonflight() then return end

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
        if this_action == "marked_for_death" then
            if cycle_enemies == 1 or active_dot.marked_for_death >= cycle_enemies then return end -- As far as we can tell, MfD is on everything we care about, so we don't cycle.
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


    spec:RegisterPack( "Subtlety", 20220911, [[Hekili:vZZAZTTrs(Br1wfdPLenFjfLCskLJ969I34SUIYgV3xeee4qrSceGlaOK1vQ4V9R75fMzW8auwooxT1URm4GbD3t)U7PVC8L)2LxmpUMC5Vmz0KjJ(UXJhoE0rF74zxEr9dRjxEX64KBJVb(J84vW)7fBUUoJu)a(dpKveph3GQInLjWpUSUED13)YxEtA9YnxpmPy1lRsxTjlUoTipPmErn(VtE5LxC9M0S6Fk)YRT)1V8I4n1llkHVx6QxdBC685e2QjvjnqX2R(1IB2q2(UliRRjRUMuU9QXJpy7v42T9DBF3RxgNFdP673(Ud3E17lUJS9Q7IltJVoJmCtfjADzArzA9drLf1uOC7vBwV9QQITxLwd)3k4VjWFCnzrrj8Y3d)x49WFDiDpFDXQRtZHhaOzD66m4VsIZYIItWDlklTcEBsEDzkb2RAyFljZ3KalBDrn8804m8r3xuElBdFF8TWp(2ms1skfd(u51KYYnRP)jS9Wxmg)7fmW5FVb)eZtNZazaobCSaP5zKOQIS7GVYWlVaHKk6HvnjoREjbp5(f65pjhPhZV8hbYofSHfTmEEX9vayFlHr0ltxZ(PFc(UxW2JxExCEA1YTxfJ0MnRpGtCUq5Tzi91KCYck4vwScE0sKaexvLINixxKVbioX5ak82u8)9JK4BZjvvWgsa4VbzPFie7xf)jG4)HTx1FtoqRQWVCA(ni9dqqGe8QQkC)ZhC5faSdpkn(Yl6dFSnlwmKtdgIN1p(i)HmKH(SbBVQhS1WH)AcCywhxEdPUAy1YnikLhvvxucOXPBVAgBdcXuX2WvuylkMdArLKvXP5aSF22RgDznifyCCOr4bsdJydO)S9zy)9GKwXg4bV5cGwD0(SNW)Nuc6XnpcEYckT53PyAZPTjhRkjtIzKfliWsUJeHCGfrRlagta2pha(K1rWbseqTWpPKIkPxa5khyjO02EmwyXgmCoWyKGSgNcB0e2B7NSJFXz0nQtah)iY9hD82RoKEAxhNHclZjK1WXeW)gxdQ(wnKFIq)KTyvyIwrm1JlONr4r5uJJYgkQuaCyfzDfQIPximgz0CiCcFQzoeIVguDxvhFTbF0pYFmO0a(kOmdtEfyrIZrnt3Vef5q22LP3aCoF43b4RgFlopLy9)yw8CuTgIdBwpufjtkYNVbuscesqJeOIFE0DeGxFyzC(TSZLtAONTwf9ZXw2rnlJH4rZrWCOu4bx00wl6AkSj44clkZ2KUll336Ntcu4(5bM3xYQVhYzc64Ibgpuv9YhkrMk4y9iNCqC(0C40PgOuz3sk14rl3KJ2RUHmSon)bq67tPjmiuBzb55osLNl9oeOoUtgmsEibm(W3z0kJcWVxykmaBZjuQhipnp6EU1afQlvOnmki5myRaihRaWQiAEkHkZ3Wdbkknet(NRzMUMkEByz9ZHhGamWdClOLG5TGUnl4Ch8lbPakYwmcZqKc(TDIcQR5hTPlOtauZju2n3cmtLOfAkfGP6)JVheCVbX0AgeJ41mf8c3F0e7B)itygyGYPqFXc4P9XZK4C4lhVQytEn(y5lpWQXc3hS972zlkAWzZHLSUiNz7Cx4FzQ(PIsN4wzS6Ei1LSFJ8nOOgraWxnP3cnIxX3gdyCf4M1MSOfLX3ScbyjmsnLrQJOo4amFKYjNenzDcNLKIDC9dlksGLiFtdDmpaMUYQIkwenNexVmc8oUaXbjiTNqrkqgjZtz0B5VAbjpIA5QH3tL2HuSVB35sB71xjzrjbDzXucHAfbxbjVAJWV6Ky0724YYhemXXG)IBYY48L54lq9CmN8jGj8II3W4AxxaEtHCDQhSbyYotYLLuuKbWDElQSol5jDtTuWDdjUJh5KFSJMd7G51XtBo1UjRa8(bnaq)8uV(TFI2au4cn9hvtloxNkW(FDrvLhh7o)mH6AUfXI6iW7xuYAEme3d3gneIq5npi1rpBevT8njZhc(wQ4S6sqFqeUjxI)h4GErme7LmAgX6Unn5wd8XeDkwdOpPU5De6VW)kBdHFCuLLMqIaEwWUbye3QuLvNuBzsPIW57Nta64kAGJG3waLOSH1biL3hldL7ICGl)6y6BIQqfFpkWY96ScanKJiL(zS485FaiQhOX0)uVqJyxa2kumpccTaC2EvCYs87px3htUFt3(a8VZni2VEjbLzqQDfHW0uOO9Gg7igpn9zyuMC7AXOb1FdT3wKmGzo8vAaaNIPhOHolojzj88BGa8aJGRqc6ej1S17nX37n197n137nZ97nZ37De8E2C(mmhK9qWmouEvscZdcgVnsNljSTeojajFM3tP3KxWcnjR4(dXJkvEamq6AqnqflHi0dWrdpQcpZijeW(h(MXAPyrEKQYJ5aKT4MBy0xhPDYKY005kAvZtl3QufSncTLvlRJwNbUqmJAgcih0Fw1zBNsuDHGy61AycID3)cRlzIblZ)ipd9NMMiVgFFBsj0Yymhsw(A0e3r90Oj3CsFGOHR2G4w9x1MNJ2uX863uXYkZI0YQAFPvrjtbjZR86NLMQytPO1RrAYf4A4O4By)jaet4PgseCpv8GczGkQrizbvoJPwJNnO6LQzucjRihg5tRtlrrmmecPygt35F71VHhZa875f0GkC6uTTalpMYlSaJFnslgmfVe0TfP6Jf3LGwIhY09WZMdvDYPmSg0K)cK3YM3xA02FDtoZRtGaxb4otpJ01ZlejVbt9SGtRpQZAEbLCxvCGmrSj4RUgmRt)fKYceRLS)bYYCxCAgcfdg2CWdbx4kvCnjocyS0yMAYPR09ox43hKHrkG)Fy7v)mP(Baa6gA6ybfNjLXG1J4RPPwK5xgxLnLiW)CCo)(yY8NJCsv1Pz00zdmajykQRhmC7v)p0edJKeQh(xteSCvPRwt9AFNYdPDrvluJiUiwlVydR7AYr0ya5HODx6nfkrEI8rJu)DEADbp95(s7zT2d3dxM2Nmolgr9hSTt4kFrhsP15IaGD7e6cHhO5SNqtNG(PlEOZpGR08YJtKRxIH4bEUsj1MoEQRUSiVkLYOWZvFSuEc)ycabDiyzJQlb7xZhQt8l8Oj0s0RKhQnW7J)X0)vNzLhukDattQsE5zKqwIyOHSIWitjNrk7XmTSPgjrYdHbhOL((mSWulmQdGmZoQz0P9o1nYwNYOE7097n564cm01FQ0F5o9bNQwubVjdPR74SUgAZUuObhLcySPZ0MYJujbPw0)KifqHhk47kNVXLGcD07ZYsqNLbA9Zf3tqMYM0wIoreJ2hkerI9Qp8ZO9GKyEjvrleWFwrPhGtg(WeAsfy6m5)uj5gc1NTXFRAEa4q56nzvTYVXjQlmJMo9O)9M5004zU2VtDTxhFdYawxMMCBL(kRrxFjSQ02kPeXONBittf(VANCc5(xuxd)s0IS4hiZVhJrdZIV574PitfBYUonF(W1BQQ3KrIiyfKH92i7KIL1QIXIDvcslKLKwgtV0zvgJKbWzY1lw9Q4YBruROKjaRqVI4oNE5fGmJVQny4DCdEZt5iZAUT91wWmkVUm1UiuspIxsImQBBBAJwrGy8amXhlLy3ihAF1QKJ7C7zjDXte5JwTCv5KKYISIY5MjsLuYsj51fGGx1ASYhO9cwaNvu)Z5)nM0CkCHXOJFOrdr3B6GQzMVnAPj3vAtpTZ67fQ77qnQ8M9C3YLbbujL(ZMCEQo5uiPNrIHT6HiYNIPUFRYhjkJG5AKzcuSj3sUdG7OII)xcgCJ5MWttoFv3xgxllwUKO1gRAPxrjT1Dt1sWkENUclpc8DXW7eDoIrwbnZ4hpcBmxd3xK)nuRuRBSiJ5QLANMgFuA9qdr8wjaIxVM(HtnJGvOvsEM2KKhAHYSNeOXcbebOIrEpIvsSAwgicPFQDjS5oz5T)oS)JAo)nD4rSSUuSyreeqpTiXgQtPFqBElX7tb4vpeE1TYUZsnvhxW)8YsHY68OFJbmupwzjqCOFLHFzrudFznq2()tohACg4o48hyfVv6WeYrwxuCBtdz8wmSYbIYcZ28Nv6KPITgNdIVb0SYJf3s4eAffqOMOjHgRabem)C96qCTnXo4UyB8ZN9ce3TZGku6cS2(5ZsTQTwk4Cmztx2U9hSueKgAuFvZ8DWTdpPfUPBMS0kteTwzsVq2uKg8mTvcmArau1R4M01ZJQdVDbxZRAcs4bTAkBerx5n4QpaCiCnZsoAWRWdPbIZJjF5BOrBHIxSqVOz0u2cex8wqJo6SkQH2OxwKmxgAammh6HhSbJW8ec0cEV06Z5xJVMnnKQilpTdmCRjJ5AHvklcjt6xMZszEmU4TS8yW620BW3dIL7HH7qAFLITIpkTYHJ0JVUTEIGc5nlqLzt6Dut1NzUV2W0xCn4labxCBfcQk0IOpP7vdTp9dUp1zYxi(SH80VzjynX5C9AneYa7AKACA0DtG023DzRMj7bnorufX5(SzjIjFEX1z1)ZlQT5CBe(8AiWAkhOlnTiwpUXxzx9DqFA2QWmKb)7Fqe0Wan6LlR793P(QXDikuMkrlsyjrym7jbJHBQDdlU7TjVcv(BudxK8XhRE2JDV6L(kILF3B(N6EPK3Wfc0EEXPeEPK)MbnoSl7e8By1CbtD96I1kQ9OESJ)bvxotHNMtsd7iHQVHJk0eyj1s4mqUVebCQapbT7O0(CU98jSMSjMr270vxwbPheuvJD9mQBdwTo3R0shKVTPH2SvDp3PDcmXrIapYVym6JUVEwTmoDEeThrggpFUAxfBtq5uxYxCDTgCtEfh1t1UzTCW7IbcqBvUbgv5PRfM3lOL3H6MtgpFS)2V9MHBVIk6X8iy(dSOx53BI6LymQ0cilGd0UpvoQQP4NshdO9f6R)an6GwvE0nTVfAGDwldvUNwerkL0sTNNoQs03RVFXByQnykxBdsEobP2dWDJ1hWg)68nLXDqxP6HZL2Q0yNuX4E)L5cYTJ2HSTmzKKTt1HC9UJ3EpQoWD(nBxOpTWz6syx21QgwLKmRFFEu0qABddmkzvSXLsQ)75ydifLKfRxbxf6zR(U6sB1zSJo8)rwymV9azlgOKWG5GkaH8I06OsXinU2g97Wjx4ZOjD4mYBSJU8W95XJSlTvtUUL2llsyNOvE)nxd7YIn3qCwKawwTSvxnTJHNRc4ONdqDPHPJeoF02KK9Zhwq4PIBKyu6cLsnzccAluK4vSem2QPKYAVjR464mETAg7Uynuq86SII5zanAiTrcdOrKHZ(t7JQk3wAlnChs9N1lU9inb(1f0)FznhDJpwajL8BJiB0InLpCPSKKp1TIucXEHXyrZ)zGos37wb(OtOqgDNCNp5W7ekAG5QklclQnD7mnPYko99LXRP7bjJKuxwuH6bsIKn8zZwgCL4hXvAnXoOdF3KcW)Z1ytRae)6nGw(w4vnz1AUYiwemb5df4INpccBUSkKeNSeZQCuCY)zdCcmpQgKaQmbU(28exiFlF14p1uKhR(U36nUhSAPKL0GzTvgAPdpXoEuqsMOuwHSDpqrcVfg2leGIHGioA8rJXZgtJi8oNaLfa(mi8I5rG70ZVLuMSmLSWwqgAI2oEjvttyYrsk3qYIUjUeWzIivjuaYzodtIlPsblWOvb3aYWCcNUGy1WNRfR0v5(4SpsqiC)vry1voLWtvaKwz274VHDrpWqvYYUMgNnnXUBQWTal9g8oFVi2gMlonLaz7vVHQUPlkKcIItgXkHMANIzPuAHB0qV5USvXXXelo8BpIgYYi6F8cE6VA3J5oV3zbVHsSV1jSeLzCg8FtYwZUb5LTUXgvlNR3nG7EFxUBKdgTq3ISxCcZELsiHn9wrZD8t61Mh8YL1cEnj0Py)oFejOnbdsIxVMD)kZLvZKJLqW5)14sS80IQ1Xtb2C2Y0B7DmQ5FrjLYOeCnULLkvfe1Wwus7Tmmtz3G9f)VcoATHLZGTSR1ARbNGzGbQ5OsJMinBekh3bsWT7i3e2o2BhlvMTcV5Q(qmQ1kcIp7BEPABL5rEVrJ0tA3ay9GKD1fyPzX8kqsBa8MnPeB7C4F5UwtaZpHrAbxzaRcWkkJJy3i3lVy2ipvsYDSoQLIz2iNbkmwgOGloaVNDMXaHezBv4Qlki8ez)(o8A3SnK)W2M2OSIF6tWOpsBnmem1d85FTyCJbtvpyAD328dhMbv8uHdAOlwZBL7B0D48bmle4BgiZZg4h0N0GGMZ8j7Pjv4kcKJxdPxiLuzEw1x5mGMAz9zvQR2V5PLqZxztCtpox)MnhoXYMPi8R6WnO9ROk6648D5(JoRRy25YBZtVo03FDVkmtfPfY)arY6P9pUPuO8VsQ9NzO(HInBVADw8d6MKRE5R43Vd(9RqVVCav8OcP58nHv9EwNNHxEgEM9O5fpDfXrLSSDC7XJ2oq71nYtYVJKvGEXy20imxJ5T)(tYRy(NqpfFQYabRvAFAbHouX1yLMvvw9x)xG4pUmfdRGFxv(GkWGxEU7kWrUvc44btiV1LXJz33y26qNOyf0B7Ab74euSohNZvFkHGJ4lQ1O)ElL(mAruR7wT3BOVKBW2B3nc5XcALZuIY(b33wpdETEYXcb7ixkGP3s3wCZ2cxUt8Q7bsCQioIoGkDqiPNrV7Q(55cU9cQ09qBKBvaHQrEGpI3oDN7PcDoBlRZPTL1ZGl(9CXf1bv0SOFz3TtJKv)Ia1SiumSCzoEerGB7xCB66gR3MXfXuzl(vXiZIDhTO64PQamdmtFEnaFGOs23ZM)5Y0pYxIo8)3LdEizqCIlTR7Gk00l0oB)MH3PaGDoNB9SxnCZXSulvaIabKmZGMAsDunjzzE6)HoAbKKglUC3Iy11HpLos2RtnHrqvMnfz0vl0WmnXMWqtOCV62PLTNKMAsnoG3J3N95GRHSUFHbkB53Qww5ZZOxL3MRSBtfTXuHXzCoqze9iyOxdSVKvPjdTfwHFgZFvSxs(scltgc2tgOXUz5TCpge8EtHajKGL0bigkQ67ttpbCuLjhU7d5DuF((YGF7WIBAMRoii0H9BF8I7yj8i7OAhzzLbB2K5zWBzG97(5KYMiEe)k5U0QesjTYDQYHuN8UJuwHRIn(wpz03D5f3hxI9nBf4)0R(1F5N(L)23V9QTx9B4Hv6Q1fLcxC(gPsOVbPlS0RJ(gHxAF8kDUcDOFlFWpaChV7NPxw5J(ECORcoFws)5VPjEP)13W06P(iHva4N6p(tdK7YjFM7Y23fa7Kx9SDd7MAaxYARkbRMN4c3EI7bk29x)h)SXM9TpvcL52fKILmVA3OvZEQGw)jki4Xp5DrLmn2KO)e3gtOPJNDCmkinwPEf7gTEYtf9SZv9KPw23UXJEQ7xxzoP3MZDJKn(ZeMSRUt5QEbVeEzVeBwRlb2)sLX4NOOdUfFla1jmtd0zcn8Z08KLGLpCmgPzXIu0LJ)YFbm9AoOTPp0XW2g)TMbUn(V(sm0T577Z7G3waSFrg(2cAZhkjh(A2g8ogywnuANy)ZEP6Ld3(kCDTWTV6MUR5G0fN5SHIE8rNDWJ99vmGqS(JMT65bTUe2Nn(ih7RwuS2ErepuCl2X2OM(F6B0LsgjoKEFmEolNTpIVWz44eewbT8YZ3(mne)KBpa2crKdWyeptlLghqdr)mBPNyZA44ZtejNF2X)b9rOc)Frg5EUrah3Bw8q3i3ECStnuRZg3JIS2hwFp(O2AN4ATtBV2PUw7S2RDMR1IdIpkr9R)iZZn93(0qHtRDmQu21nR9zzp7R8C1)rpBfi68j9AFvPpfOd92tAGYflvB(h6PZxSPtNB6KvtOC4R1Z75xUDIQCR(CStfamTSYaeWlsgh6FchhDQqVHDf0wOhIYPh3tlL1NFCpp5f(u(WOtJF78ZMDyFKt70XJg8cgn(RZCLtLmuQpz54MaeFxkzrlVGVJ6YYF2MwCHzlvcYbrQaUEAAsFhhjAEmUAoDL4IOtoAFBZvUxmz0(HMNCkRXwQUFrZwBo)4W3CYrVOVFTbZgWuh88mN225tk9op50MtUwKsky(fEYR9FT95AYRfMqW2ynUvh24ot9ohP7lrdHB8JpQPcdEsVGB80hF0AzPuNVAH3LzH8uCwh2dHq52NWCrlmXMUHpb(TNJjAMk0Pp(0AdqNdbkTV6SnZYltNQzQp3yiMP(tAZSmr4o)OPESHuYZz4uIcbP98uWVELoNovED740Jm(A0G2uxrlB0GNk96Vx7I5JsafDAmjDy7I)E(z44rkad7Sb967Pltonih)mfNlTAcAGfQrBCbjjEHdGa9zqlovqlcmMO6ThfiApGOuEvhdhQE7zFSqzb)Bg8tujV)yNFtTbhXyLIkqyemYJpUx)qbp0RVAA7MstBhg2XJpQ(8zSNpEqpgOD6XJgqftrlYISki1m(8odKAWzWw8zQfO)aLzxelbm7zRi(CFKnVF4o)bPLPPdpIIu)5AwhPrpqbsdJITPkFw4V(ht9cVFGw1SzFQg7uQ5VP3EMJtPEED3dDkW3SvP3EEC10HVcO0SrKqh1RDTqphc8ZaNz9opID97u66SgFpGshgyWh94JLUg6rABjkg6cf7zvaWr)ZC2i2YTnoJyHy9SmIImPNA9a(bl4TuoJ)jW0JW7bFJcO)WgXqTKfnG7Gb0dm6mG48ZoEuphspEff82ozGFAGVjLThRqCHeBJsOqEj3F8(ZErFVoFTN7wTAWaDPq05aMwBZBnTQtv876hyqZ1O3yqRJcl(PSdkS6WaaYM2JZMmg91Xs(9oRpFy)C(pmdOb75uPCF7KJqUYnaoslQQ6zeD1r(D3DABYgo5C8qzSJCJTsmgFCJm5xRHPtqZLUr1(7PL1jUmJdNC)891Ux)9cO(dCkZNDVa5tvnGeh28pFYaRIDEhnoGjtxRGQFsZKllno)jA4WyYF0QiH8rXZzJhEKnfiTN)oGl1TKfo1MydOotJbZHSLAAvAiFFbgknbjfwqxqF20rh6Ai10bmQTjuJsKUt6HMWJi2ILs76hNa8UArniVAw9SDnvBzMPv1XO(j63)ut1kHY8PB)cCqc8ROX)hKM1Gsptnggl4N7KDPlEo1)ZrBNtQMtxNnDl5PAi2bhnlKvNbPAWxEY(ohBlTJjtTxk6)uAMcrC9nCrth1Zq5KD6gQZ)G02Zsfu5OXutr7rQD9H7w7qeWa(VKrYAmwvSkxpDK7WafQimK31mpQ(tnzQEuRZ2MPEstG2wU0(MVLCaNSlVLCwMSlVK(ylzxEtXSoGLz6qZQe)VT75iIeImgsjoov9)z8mtmOIgMo2W4PnMdh0Gm8Uo(8fzG)Kya(eBXy5XJSIzy(nd4EiNH2aA9xe9X(PxohSh2C0zpNJ3d)FeNtAdfDHENQh2zfyPM75zWB4cbQ8jVy)CCKO6fSsaslFbAU8R9f2Rbfzf07m9kcB72QXlkSVB8O)Gl7F0HTllce6R5mbXa023wBr0e8Knq1pCCCpF5f2EVtODS2ZAJ95bA9dSD9gaEkE7)8cLbVOgQfEP199ZHjD(REyBAM4ZoE4eMxGFDUVAwocm6VbLBwdNl2rkqphD)3xQSCNjlRPAnKBP9NDOMxvVWJlUms8t4k1zH(iigOKKUBD9BKSujBbnhzjHph20wsbeymUgDue9pKBoMhsJntEwjnHsKtO(AZAQY6F0(9N8c1qqgmqNkInQ1xXBXwaMk7uQoRNA)XJ8KMBLSz6HRl47V)rwqc1RyMoM0HdxiojlBzZ9st4mqtlkPvT0wQpL7Ls7hzyPwB(wiB9ZUzqbtEpys5qCaD9I(MTUQT8De(q58ZozWaRaEB1YAGEQA3VxlhOi7mkHyKASBoHtE2O))Xt9k3KzzfkveevP2pzRCdSNLPX92Rt1c1SmI)jzsw5Iq6S0KQt0QZMnILju1HELRDSsIW47iQ13SrTs4cOa0XzNJtaw3xSddmQUlKAPJ5DKRX9TMkLVaFPPi5ZzGdptFMtnQjyhSa0oDTFPGkV5AG1xI70WDYphBt6k7BtlDy7cNE2jk(qAIUUstFJY6HtmEDjKlYeI24CkKJ3ZcdXNpEuGgQlun(MYCz)R9uxQRNSUpDSKzJGKVgtmUN)sg(dPDLcef2I)BCJAQviK1ovAMmyj(a4pPx)aA3BqPzRrRpi)o1HgEGK6whoGDpVmCeG3X28BeMWIepVnTSi3IstMZ7qngasLFyC6SFNL3i8bm0lCAerMUqHI5S)EA1m6t53DfTwr)LnTNo7bIw7Hbhk1WbHCMhkiHNN2k21nMURiCGxhI6nXmYcfaEfTd1RIxWpWm7vDbaHrUa0t0CEtxRdw47Frm9cnxrnER1a7dh0cfN1gfnAP(d48dhRIZ8(qG7Dy7Z19F2BqEUPZ2DaIDJatcRIliamZzB5FyFlDNwSs3P1ZGR1ojYK5VjxdSglXFI6Mz0sTsdz659K5Rh6m4sqff4F5VJ8d4BXpyfR)hPoKWCduRMJQGSAh0I5OBtADB9)LX53cr60ZJ1bSFcDMYSZf38YwvzoqJqonS0VTYzjnc7eI2FILcD48uL1X9FHA4ESfH4QuMQK5hAqqi(oy7v3kZcMPl(49qdtDJcJcJ9ZXXTghQ3C(y37pEJIds9ZJUNdfnjg1pUcmb(YAgtvgA)V5ECiVeLwn)bhFLYogMPl7JVFBZL)rOPw9sarBLCql(B)itWq2QMfOU9(OyfTHqyb7WVajSxUJc9bOG99tcLn5e8tRlYz226wbhoBMtiuDDT8MgKo3Njf14Hl1sDdtD8TXawvfHfTgt)a9kSaAKTLZeF501HJVQ3KjrdPeOXdKntvBpIKj3ZuyHQDexbjVAJy(vqVmJjXLLpiyOIzxhuopsU8MGYsgi19tKdAn4LykEo3n2cVh74fdlOlMNo(e)YFb3b7qAZD6qwWp364dyJy80WudhUxSey4bpMlO9XXECnfaph1BCx9DjxbFrDe44hY(IjXbnSWtWGqtZSrNZVpW05J1L)F)]] )


end
