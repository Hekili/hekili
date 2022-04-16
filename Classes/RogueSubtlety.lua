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


    spec:RegisterPack( "Subtlety", 20220415, [[diLQCcqiiLEKKQSjkPpjjPrjPYPKKAvKeYRujmlsQUfjb7sk)cLIHrc1XibltLkptLsnnukDnsI2gjP8njjY4GuHZjjHSoivY7KKGO5PsX9qj7JKY)uPe4GqkYcHu1dLuvtKeYfHuuzJQusFusc1ivPe0jHuuwjkvVuscQzcPIUPKe1ovPQFQsj0qjjvlfsHEkQmvvIUkjHARssGVcPsnwifCwjjiTxv8xjgmvhw0IHQhlvtMIlJSzi(mKmAuCAfRgsrvVwsz2K62uQDd8BLgoQ64QuIwoONRQPlCDOSDs03PeJNKKZRsA9ssqy(sI9t8rHZLhotg05(7u8D3Py2QGQ1uSIvCvKc3D4IR80HJp71su0HdK20HJddp0uC9WXNx1BAoxE4(fd2Pdhte8p6InSb1emy4T(AZMFSX0zmlOdtKGn)y3zZHdhB0bAg4GF4mzqN7VtX3DNIzRcQwtXkwXvrkC4sSGzHhoUXU(hoMXyiWb)WzOVF44WWdnfxfhnUOWiHD0epC0IRGkvx87u8D3jSlSxFMeGIE0LWUkiEvEvsIRmHtIRPg2tfE4SWjUwGBKXSaXX4f)xXNq85f)PqCCczHK4wiXXEs8jAc7QG41FTXhajUnMogEnjEp16s2Jzbf98H4eiGd9IhR4qYG1jX53GaXKAXHKLfwRjSRcIxLZAK43QMEMomrcXhqqqigFi(aeVV24zi(GiUfsC08yFiUzmIpH4iluCLRoJrtLF1kjq0oC65J)C5H7dk1bdzoxEUxHZLhocK4AYCq)Hl7XSGd3ZKM1YhWPgD4m03HdFml4WHMHioxqPoyyJYempJ4jKehJxDXXEsCoM0Sw(ao1iXJvCCcqitiocCTfpyiX5Z)hLK44la7fpbgXV1byehDtzna9V6ItkjG4dI4wiXtijEgIBNQs86R6Ixhgqt)lo2pauIxLZpiO4OP)Z)hq1hUoCcco5HRoXXXqqAFqPoyAy8IxPI44yiinLjyEMggV4vlUvXRt8NN06sKquu8TNbdo1iq5JfAl(nIZwXRurCLjCsCn1WEQWdNfoX1cCJmMfiE1IBvC78dcwY)Z)hqbs25aEXzjUIpX5(7oxE4iqIRjZb9hod9D4WhZcoC36aMNr8meNTxiE9vDXTmbZIfIRio1fxLxiULjyexrCQlEcmIRAIBzcgXveN4jsqqXRcsW8mhUShZcoC9uRlzpMfu0ZhhUoCcco5HtzcNextncbH6XOKk91gFl87aIxC1yjENVyNQQ88eWiELkIJJHG0Egm4uJaLyHG0SnmEXTkEFTX3c)oG4Bgcz6ti(nSe)oXRur8NN06sKquu8TNbdo1iq5JfAlUASeNTIBvCLjCsCn1ieeQhJsQ0xB8TWVdiEXvJL4Sv8kveVV24BHFhq8ndHm9je)gwIRG4QG41jEKAcendr8eS8bmJefz3iqIRjJ4wfhhdbPPmbZZ0W4fV6dNE(OasB6WHmG5zoX5(BFU8WrGextMd6pCD4eeCYd3huQdgY0EI)NxCRI)8KwxIeIIIV9myWPgbkFSqBXVrC2E4YEml4W9mPzT8bCQrN4CpBpxE4iqIRjZb9hUShZcoC4zV2hj(HZqFho8XSGdh6ZETpsCXnyWbGsCoM0SwexrjOtIBHHaIVaXzgumIR6vbI)r2R9INaJ4CmPzTio61PHEXNxCm(2HRdNGGtE46lWGnrJNGilmdYuusd4BWeutC1yjo6qCRIJJHG04jiYcZGmfL0a(2hzVM4QXsCvkUvXXXqqAptAwlftc6uds25aEXvJL43wCRIJJHG0EM0Swk460qFdJxCRIxN4ppP1LiHOO4BpdgCQrGYhl0w8Byj(TfVsfXvMWjX1ud7PcpCw4exlWnYywG4vlUvXRtCCmeK2ZKM1sbxNg6BqYohWl(nSehhdbP9mPzTumjOtnizNd4f)cXVt8kvehTI3xLeibrtjbcMRqXR(eN7v55YdhbsCnzoO)W1HtqWjpCrQjq0adkM4JuxJGncK4AYiUvXHyaczHOOwmGRLyv10l460qncK4AYiUvXFEsRlrcrrX3Egm4uJaLpwOT43iUkpCzpMfC4EMr5jo3RANlpCeiX1K5G(dx2JzbhUNjnRLpGtn6W1V21ujsikk(Z9kC46Wji4Kho0kUYeojUMAypv4HZcN4AbUrgZce3Q4gchdbPHmatXcL1a0)nizNd4f)gXvqCRI)8KwxIeIIIV9myWPgbkFSqBXVHL43wCRIhjeffTySPsSfZqIRcIdj7CaV4QjUQD4m03HdFml4WPI5fpwXVT4rcrrXlEDGvCE4SvlEnI4fhJx8BDagXr3uwdq)lo(vX7x76bGsCoM0Sw(ao1O2jo3xLoxE4iqIRjZb9hUShZcoCptAwlFaNA0HZqFho8XSGd3TUqX5HZcN4Q4WnYywG6IJ9K4CmPzT8bCQrIVkjO4CXcTf3YemIJURYINOYb8H4y8IhR4Sv8iHOO4fFHIpiIFROBXNxCigamauIViiIx3cepbxfpTxmqi(IiEKquu8vF46Wji4KhoLjCsCn1WEQWdNfoX1cCJmMfiUvXRtCdHJHG0qgGPyHYAa6)gKSZb8IFJ4kiELkIhPMarZcL8lWo)GGncK4AYiUvXFEsRlrcrrX3Egm4uJaLpwOT43WsC2kE1N4Cp64C5HJajUMmh0F46Wji4KhUNN06sKquu8IRglXVT4xiEDIJJHG0cgQa3iiqdJx8kvehIbiKfIIAzTmHZx(ftxqGjkBcencK4AYiELkI)uuWxa23IHG3Hok3X3f3Q4rQjq0EM0SwkiBh7BeiX1Kr8Qf3Q41joogcs7VAJV6VSifdLbtjXITdNOHXlELkIJwXXXqqA8qYMmtKXSGggV4vQi(ZtADjsikkEXvJL4Qu8QpCzpMfC4Egm4uJaLpwO9jo3xfDU8WrGextMd6pCzpMfC4EM0Sw(ao1OdNH(oC4JzbhooM0Sw(ao1iXJvCiHaPNr8BDagXr3uwdq)lEcmIhR4e4XGK4wiX7jq8EcHxfFvsqXtXrW0AXVv0T4diwXdgsCaPQqCUvrIpiIZV)p4AQD46Wji4KhodHJHG0qgGPyHYAa6)gKSZb8IFdlXvq8kveVVR2SwaT)Qn(Q)YIumugmnizNd4f)gXvaDiUvXneogcsdzaMIfkRbO)BqYohWl(nI33vBwlG2F1gF1FzrkgkdMgKSZb8N4CVck(C5HJajUMmh0F46Wji4KhoCmeKgpbrwygKPOKgW3(i71exnwIRsXTkEFbgSjA8eezHzqMIsAaFdMGAIRglXv42hUShZcoCO07AJRtdDIZ9kOW5Ydx2JzbhUNjnRLpGtn6WrGextMd6pX5EfU7C5HJajUMmh0F46Wji4Kho0kEKquu0MVGV)lUvX7Rn(w43beFZqitFcXvJL4kiUvXXXqqApZgLbucgQysyTggV4wfNaee11wm2uj2cBvS4QjoQUPzNQ6WL9ywWHRZqjF5z24eN4WziKethNlp3RW5Ydx2JzbhUAtV2HJajUMmh0FIZ93DU8WrGextMd6pCl)H7P4WL9ywWHtzcNexthoLPgJoC4yiiTxpDQKatXmDQHXlELkI)8KwxIeIIIV9myWPgbkFSqBXvJL4Q2HZqFho8XSGdNk(jJ4XkUHccApasClmuWqqX77QnRfWlULCcXrwO4CafjoE(Kr8fiEKquu8TdNYewaPnD4EGP0xGzIzbN4C)TpxE4iqIRjZb9hUL)W9uC4YEml4WPmHtIRPdNYuJrhoCmeK2RNovsGPyMo1W4fVsfXFEsRlrcrrX3Egm4uJaLpwOT4QXsCv7WPmHfqAthUhyk9fyMywWjo3Z2ZLhocK4AYCq)HB5pCpfhUShZcoCkt4K4A6WPmHfqAthU5lasvrPZxsWyNDMeIImhUoCcco5HRVkjqcIwTRWjbhod9D4WhZcoC1NH61epwXFIeFqepyiXbKQcXRVQlEDdq8GHeNusGq8fr8uCoMlfNhU9QfFEXrtGXo7mjefzoCktngD46Rn(w43beV4SexbXTkoogcsJ6m7aqvGepCStGPCxdJx8kveVV24BHFhq8IZs87e3Q44yiinQZSdavbs8WXobMYTBy8IxPI491gFl87aIxCwIFBXTkoogcsJ6m7aqvGepCStGPW2ggV4vQiEFTX3c)oG4fNL4SvCRIJJHG0OoZoaufiXdh7eykQSHXFIZ9Q8C5HJajUMmh0F4w(d3tXHl7XSGdNYeojUMoCktngD4ieeQhJsQ0xB8TWVdi(dNH(oC4Jzbho0uVVyGqCKfkohZLIdPShZcepgBsC8RIpOalCaOexVwuH6R6INGXo7mjefze3oJod9IpaXdgsCf3u5lopK6ezgakXtX53GaXKAX5yUuCE42pCktybK20HJqqOEmkPsFTX3c)oG4pX5Ev7C5HJajUMmh0F4w(d3tXHl7XSGdNYeojUMoCktngD46Rn(w43be)HRdNGGtE46RscKGOv7kCsG4wfNqqOEmkPsFTX3c)oG4fxnX7Rn(w43beV4wfVV24BHFhq8ndHm9jexnXVtCRIhJnvIT8mrHxJ9n2k(nIR4Mkf3Q4OvCLjCsCn1MVaivfLoFjbJD2zsikYC4uMWciTPdhHGq9yusL(AJVf(DaXFIZ9vPZLhocK4AYCq)HB5pCpfhUShZcoCkt4K4A6WPm1y0HJholCIRf4gzmlqCRI)8KwxIeIIIV9myWPgbkFSqBXvJL43D4m03HdFml4WDlc0xfVZKauK4WnYywG4dI4wiXzsLK48WzHtCTa3iJzbI)uiEcmIBJPJHxtIhjeffV4y8TdNYewaPnD4WEQWdNfoX1cCJmMfCIZ9OJZLhocK4AYCq)HZqFho8XSGdx9zOEnXRVIEXZqCKb(XHl7XSGdxp16s2Jzbf98XHtpFuaPnD46M)eN7RIoxE4iqIRjZb9hUShZcoCVE6ujbMIz60HZqFho8XSGdhAINxFvCo90jXtGrCfnDs8me)UleV(QU4gm4aqjEWqIJmWpexbfl(t9fyE1fprcckEWKH4S9cXRVQl(Gi(eItQIFG0lULjygG4bdjoGuviEvC9vK4lu85fhSH4y8hUoCcco5H75jTUejeffF7zWGtncu(yH2IFJ4QM4wfhzqXefizNd4fxnXvnXTkoogcs71tNkjWumtNAqYohWl(nIJQBA2PQe3Q491gFl87aIxC1yjoBfxfeVoXJXMe)gXvqXIxT4QiXV7eN7vqXNlpCeiX1K5G(dNH(oC4Jzbho0igqCemT(Q4VLj6m0lESIhmK4CbL6GHmIJg3iJzbIxh(vXn7aqj(VQl(eIJSWo9IZVREaOeFqehSbZaqj(8INkZrN4AQ62Hl7XSGdheduYEmlOONpoCD4eeCYd3huQdgY0sT(WPNpkG0MoCFqPoyiZjo3RGcNlpCeiX1K5G(dNH(oC4JzbhovholCIRIJg3iJzb3cehDsrvFXrnkjXtX7WKx8eFXcXjabrDvCKfkEWqI)bL6Gr86ROx86WXgTHGI)XO1IdPNN6H4tuDt8QqX4vx8jeVNaXXjXdMme)hBEn1oCzpMfC46PwxYEmlOONpoCD4eeCYdNYeojUMAypv4HZcN4AbUrgZcoC65JciTPd3huQdMs38N4CVc3DU8WrGextMd6pCl)H7P4WL9ywWHtzcNexthoLPgJoC3PsXVq8i1eiAkhulSrGextgXvrIFNIf)cXJutGOzNFqWYIuEM0Sw(gbsCnzexfj(Dkw8lepsnbI2ZKM1sbz7yFJajUMmIRIe)ovk(fIhPMarl1zhoX1gbsCnzexfj(Dkw8le)ovkUks86e)5jTUejeffF7zWGtncu(yH2IRglXzR4vF4m03HdFml4WPIFYiESIBiKbqIBHHaIhR4ypj(huQdgXRVIEXxO44yJ2qW)WPmHfqAthUpOuhmLGbspZQnN4CVc3(C5HJajUMmh0F4m03HdFml4Wv)f8JHGIJ9daL4P4CbL6Gr86RiXTWqaXHu2zgakXdgsCcqquxfpyG0ZSAZHl7XSGdxp16s2Jzbf98XHRdNGGtE4iabrDTziKPpH43WsCLjCsCn1(GsDWucgi9mR2C40ZhfqAthUpOuhmLU5pX5Efy75YdhbsCnzoO)WzOVdh(ywWH7whW8mINH42PQuxC2EH4wMGzXcXveN4luCltWio3QiX7WjehhdbrDXv5fIBzcgXveN41TyXpgs8pOuhmvRU4wMGrCfXjEQ)vCKbmpJ4zioBVq8evoGpeNTIhjeffV41TyXpgs8pOuhmvF4YEml4W1tTUK9ywqrpFC46Wji4KhoLjCsCn1ieeQhJsQ0xB8TWVdiEXvJL4D(IDQQYZtaJ4vQiEFTX3c)oG4Bgcz6ti(nSexbXRurCKbftuGKDoGx8ByjUcIBvCLjCsCn1ieeQhJsQ0xB8TWVdiEXvJL43w8kvehhdbP9xTXx9xwKIHYGPKyX2Ht0W4f3Q4kt4K4AQriiupgLuPV24BHFhq8IRglXzR4vQi(ZtADjsikk(2ZGbNAeO8XcTfxnwIZwXTkUYeojUMAecc1Jrjv6Rn(w43beV4QXsC2E40ZhfqAthoKbmpZjo3RGkpxE4iqIRjZb9hod9D4WhZcoCQ4NepfhhB0gckUfgcioKYoZaqjEWqItacI6Q4bdKEMvBoCzpMfC46PwxYEmlOONpoCD4eeCYdhbiiQRndHm9je)gwIRmHtIRP2huQdMsWaPNz1MdNE(OasB6WHJnAZjo3RGQDU8WrGextMd6pCzpMfC4sypbujwiKaXHZqFho8XSGdh6CTqFiopCw4exfFaINAT4lI4bdjoAs1rNIJt9e7jXNq8EI90lEkEvC9v0HRdNGGtE4iabrDTziKPpH4QXsCfuP4xiobiiQRniHIaN4CVcvPZLhUShZcoCjSNaQWJPF6WrGextMd6pX5EfqhNlpCzpMfC40dkM4lO5XmOSjqC4iqIRjZb9N4CVcvrNlpCzpMfC4WtuLfPeWPx7pCeiX1K5G(tCIdhpK6RnEgNlp3RW5Ydx2JzbhUKNxFTWVZVGdhbsCnzoO)eN7V7C5Hl7XSGdh(gHMmfeDELmwgaQsSQAahocK4AYCq)jo3F7ZLhocK4AYCq)HRdNGGtE4(ftJpatJh7dmnviigFmlOrGextgXRur8FX04dW0uU6mgnv(vRKarJajUMmhUShZcoCiA6z6WejoX5E2EU8WL9ywWH7dk1bZHJajUMmh0FIZ9Q8C5HJajUMmh0F4YEml4WzNWAKPGSWIHYG5WXdP(AJNr5P(cm)HtbvEIZ9Q25YdhbsCnzoO)WL9ywWH71tNkjWumtNoCD4eeCYdhKqG0ZK4A6WXdP(AJNr5P(cm)HtHtCUVkDU8WrGextMd6pCD4eeCYdhedqilef1StyTYIucgQyNFqWs(F()aAeiX1K5WL9ywWH7zsZAPGRtd9N4ehoCSrBoxEUxHZLhocK4AYCq)HRdNGGtE4qR4rQjq0adkM4JuxJGncK4AYiUvXHyaczHOOwmGRLyv10l460qncK4AYiUvXFEsRlrcrrX3Egm4uJaLpwOT43iUkpCzpMfC4EMr5jo3F35YdhbsCnzoO)W1HtqWjpCppP1LiHOO4fxnwIFN4wfVoXrR49vjbsq0auhU6fAeVsfX77QnRfq7jimdYuWxavE(Pg1Stvv6mjef9IRcI3zsik6liWShZcsT4QXsCf3UtLIxPI4ppP1LiHOO4BpdgCQrGYhl0wC1eNTIxT4wfVoXXXqqA8eezHzqMIsAaF7JSxt8ByjoBfVsfXFEsRlrcrrX3Egm4uJaLpwOT4QjoBf3Q4OvCLjCsCn1WEQWdNfoX1cCJmMfiE1hUShZcoCpdgCQrGYhl0(eN7V95YdhbsCnzoO)W1HtqWjpC4yiinEcISWmitrjnGV9r2Rj(nSe)oXTkEDI33vBwlG2tqygKPGVaQ88tnQzNQQ0zsik6fxfeVZKqu0xqGzpMfKAXVHL4kUDNkfVsfX)ftJpatttPPGFTqQkT51uJajUMmIBvC0koogcsttPPGFTqQkT51udJx8kve)xmn(amTAKYb8LDRcbPhaQgbsCnze3Q4OvCdHJHG0QrkhWxSaZGPHXlE1hUShZcoCpbHzqMc(cOYZp1OtCUNTNlpCzpMfC4qP31gxNg6WrGextMd6pX5EvEU8WrGextMd6pCzpMfC4WZETps8dNH(oC4Jzbho0N9AFK4Ip22KzYG0xfhdOP)fpyiXbKQcXRVQl(8IJMaJD2zsikYiEcmIBHe3YcQAiEp5fNaee1vXTKtmauIJSqXNOD46Wji4Kho0kEFvsGeeTAxHtceVsfXrR41jUYeojUMAZxaKQIsNVKGXo7mjefze3Q41jEm2uj2YZefEn23UT43iUIBQu8kvepgBQeB5zIcVg7BSv8BexbXRwCRItacI6Q43iUQPyXR(eN4W1n)5YZ9kCU8WrGextMd6pCD4eeCYdhAfhhdbP9mPzTumjOtnmEXTkoogcs7zWGtncuIfcsZ2W4f3Q44yiiTNbdo1iqjwiinBds25aEXVHL43UPYdh2tLfbPGQBo3RWHl7XSGd3ZKM1sXKGoD4m03HdFml4WPIFsCfLGoj(IGOcO6gXXjKfsIhmK4id8dX5yWGtncioxSqBXrGRT4xUqqAwX7Rn9IpG2jo3F35YdhbsCnzoO)W1HtqWjpC4yiiTNbdo1iqjwiinBdJxCRIJJHG0Egm4uJaLyHG0SnizNd4f)gwIF7MkpCypvweKcQU5CVchUShZcoC)vB8v)LfPyOmyoCg67WHpMfC4Qtfd00)INAiLMRIJXloo1tSNe3cjESBnX5ysZAr8BD7yF1IJ9K4CxTXx9l(IGOcO6gXXjKfsIhmK4id8dX5yWGtncioxSqBXrGRT4xUqqAwX7Rn9IpG2jo3F7ZLhocK4AYCq)HRdNGGtE4uMWjX1u7bMsFbMjMfiUvXrR4FqPoyitZobHMe3Q41j(ZtADjsikk(2ZGbNAeO8XcTf)gwIRG4wfVVR2SwaT)Qn(Q)YIumugmnmEXTkoAfpsnbI2ZKM1sbz7yFJajUMmIxPI44yiiT)Qn(Q)YIumugmnmEXRwCRI3xB8TWVdiEXvJL4Q8WL9ywWHdrNOiToJzbN4CpBpxE4iqIRjZb9hUoCcco5HRoXHyaczHOOMDcRvwKsWqf78dcwY)Z)hqJajUMmIBv8(AJVf(DaX3meY0Nq8ByjUcIRcIhPMarZqepblFaZGqr2ncK4AYiELkIdXaeYcrrndLbJ(A5zsZA5BeiX1KrCRI3xB8TWVdiEXVrCfeVAXTkoogcs7VAJV6VSifdLbtdJxCRIJJHG0EM0SwkMe0PggV4wf3o)GGL8)8)buGKDoGxCwIRyXTkoogcsZqzWOVwEM0Sw(MzTaoCzpMfC4uMG5zoX5EvEU8WrGextMd6pCg67WHpMfC4u9D1IJSqXVCHG0SIZdjvGBvK4wMGrCogfjoKsZvXTWqaXbBioedagakX5U12HdzHfaPQ4CVchUoCcco5HlsnbI2ZGbNAeOeleKMTrGextgXTkoAfpsnbI2ZKM1sbz7yFJajUMmhUShZcoC87Qlq6xmyNoX5Ev7C5HJajUMmh0F4YEml4W9myWPgbkXcbPzpCg67WHpMfC4uXpj(LleKMvCEijo3QiXTWqaXTqIZKkjXdgsCcqquxf3cdfmeuCe4Alo)U6bGsCltWSyH4C3Q4luC08yFiokcqWuRV2oCD4eeCYd3ZtADjsikk(2ZGbNAeO8XcTf)gwIRG4wfNaee1vXvJL4QMIf3Q4kt4K4AQ9atPVaZeZce3Q49D1M1cO9xTXx9xwKIHYGPHXlUvX77QnRfq7zsZAPysqNADMeIIEXvJL4kiUvXRtC0koedqilef1wCYmeOtncK4AYiELkIBiCmeKgIorrADgZcAy8IxPI4ppP1LiHOO4BpdgCQrGYhl0wC1yjEDIRG4xioBfxfjEDIJwXJutGObgumXhPUgbBeiX1KrCRIJwXJutGOzsyTYZKM1sJajUMmIxT4vlE1IBv8(AJVf(DaXl(nSe)oXTkoAfhhdbPXdjBYmrgZcAy8IBv86ehTI3xLeibrtjbcMRqXRurC0kEFxTzTaAi6efP1zmlOHXlE1N4CFv6C5HJajUMmh0F4YEml4W9eeMbzk4lGkp)uJoCD4eeCYdNYeojUMApWu6lWmXSaXTkoAf3Sr7jimdYuWxavE(PgvmB0IPxBaOe3Q4rcrrrlgBQeBXmK4QXs87uqCRIxN491gFl87aIVziKPpH4QXs86eVZxqLdqC1UfioBfVAXRwCRIJwXXXqqApdgCQrGsSqqA2ggV4wfVoXrR44yiinEiztMjYywqdJx8kve)5jTUejeffF7zWGtncu(yH2IRM4Sv8QfVsfXX3)f3Q4idkMOaj7CaV43WsCvkUvXFEsRlrcrrX3Egm4uJaLpwOT43i(TpC9RDnvIeIII)CVcN4Cp64C5HJajUMmh0F46Wji4KhoLjCsCn1EGP0xGzIzbIBv8(AJVf(DaX3meY0NqC1yjUcIBv8iHOOOfJnvITygsC1yjUcQ2Hl7XSGd3t8)8N4CFv05YdhbsCnzoO)WL9ywWH7VAJV6VSifdLbZHZqFho8XSGdNk(jX5UAJV6x8fiEFxTzTaeVUejiO4id8dX5akQAXXaA6FXTqINqsCu7aqjESIZV8IF5cbPzfpbgXnR4GneNjvsIZXKM1I4362X(2HRdNGGtE4uMWjX1u7bMsFbMjMfiUvXRtC0k(huQdgY0sTw8kvehhdbPXtqKfMbzkkPb8TpYEnXVrC2kELkI)8KwxIeIIIV9myWPgbkFSqBXvtC2kUvXrR4kt4K4AQH9uHholCIRf4gzmlq8Qf3Q41joAfpsnbI2ZGbNAeOeleKMTrGextgXRur8i1eiAptAwlfKTJ9ncK4AYiELkI)8KwxIeIIIV9myWPgbkFSqBXvJL43jELkI33vBwlG2ZGbNAeOeleKMTbj7CaV4Qj(DIxT4wfVoXrR49vjbsq0usGG5ku8kveVVR2SwaneDII06mMf0GKDoGxC1exbflELkI33vBwlGgIorrADgZcAy8IBv8(AJVf(DaXlUASexLIx9jo3RGIpxE4iqIRjZb9hUShZcoC2jSgzkilSyOmyoC6bqLU5WPqtLhU(1UMkrcrrXFUxHdxhobbN8WbZXuiLeiAPX8nmEXTkEDIhjeffTySPsSfZqIFJ491gFl87aIVziKPpH4vQioAf)dk1bdzAPwlUvX7Rn(w43beFZqitFcXvJL4D(IDQQYZtaJ4vF4m03HdFml4WHMHiEAmV4jKehJxDXFWWtIhmK4lGe3YemIRxl0hIF5LkQjUk(jXTWqaXnxhakXrYpiO4btceV(QU4gcz6ti(cfhSH4FqPoyiJ4wMGzXcXtWvXRVQ3oX5Efu4C5HJajUMmh0F4YEml4WzNWAKPGSWIHYG5WzOVdh(ywWHdndrCWkEAmV4wgTwCZqIBzcMbiEWqIdivfIFBf)Qlo2tIxLruK4lqC89FXTmbZIfINGRIxFvVD46Wji4KhoyoMcPKarlnMVnaXvt8BRyXvbXH5ykKsceT0y(MbdMXSaXTkEFTX3c)oG4Bgcz6tiUASeVZxStvvEEcyoX5EfU7C5HJajUMmh0F46Wji4KhoLjCsCn1EGP0xGzIzbIBv8(AJVf(DaX3meY0NqC1yj(DIBv86ehhdbP9xTXx9xwKIHYGPHXlELkIJV)lUvXrgumrbs25aEXVHL43PyXRurC0koogcs7zsZAPGRtd9nmEXTk(trbFbyFlgcEh6OChFx8QpCzpMfC4EM0Swk460q)jo3RWTpxE4iqIRjZb9hUoCcco5HdTI)bL6GHmTuRf3Q4kt4K4AQ9atPVaZeZce3Q491gFl87aIVziKPpH4QXs87e3Q41jUYeojUMAypv4HZcN4AbUrgZceVsfXFEsRlrcrrX3Egm4uJaLpwOT43WsC2kELkIdXaeYcrrni9lgWmauLUoHtCTrGextgXR(WL9ywWHJ6m7aqvGepCStG5eN7vGTNlpCeiX1K5G(dx2JzbhUNbdo1iqjwiin7HZqFho8XSGdh6EcgX5Uv1fFqehSH4PgsP5Q4MfqQlo2tIF5cbPzf3YemIZTksCm(2HRdNGGtE4Qt8i1eiAptAwlfKTJ9ncK4AYiELkI)8KwxIeIIIV9myWPgbkFSqBXvJL43jE1IBvCLjCsCn1EGP0xGzIzbIBvCCmeK2F1gF1FzrkgkdMggV4wfVV24BHFhq8IFdlXVtCRIxN4OvCCmeKgpKSjZezmlOHXlELkI)8KwxIeIIIV9myWPgbkFSqBXvtC2kE1N4CVcQ8C5HJajUMmh0F46Wji4Kho0koogcs7zsZAPysqNAy8IBvCKbftuGKDoGx8Byjo6q8lepsnbI2JHheebdf1iqIRjZHl7XSGd3ZKM1sXKGoDIZ9kOANlpCeiX1K5G(dxhobbN8WvN4)IPXhGPXJ9bMMkeeJpMf0iqIRjJ4vQi(VyA8byAkxDgJMk)QvsGOrGextgXRwCRItacI6AZqitFcXvJL43wXIBvC0k(huQdgY0sTwCRIJJHG0(R24R(llsXqzW0mRfWHBabbHy8rzqoC)IPXhGPPC1zmAQ8RwjbId3acccX4JYyBtMjd6WPWHl7XSGdhIMEMomrId3acccX4Jck9IN6dNcN4CVcvPZLhocK4AYCq)HRdNGGtE4WXqqA46DnASpAqk7H4vQio((V4wfhzqXefizNd4f)gXVTIfVsfXXXqqA)vB8v)LfPyOmyAy8IBv86ehhdbP9mPzTuW1PH(ggV4vQiEFxTzTaAptAwlfCDAOVbj7CaV43WsCfuS4vF4YEml4WXVXSGtCUxb0X5YdhbsCnzoO)W1HtqWjpC4yiiT)Qn(Q)YIumugmnm(dx2JzbhoC9UMccg86jo3Rqv05YdhbsCnzoO)W1HtqWjpC4yiiT)Qn(Q)YIumugmnm(dx2JzbhoCc(eS2aqDIZ93P4ZLhocK4AYCq)HRdNGGtE4WXqqA)vB8v)LfPyOmyAy8hUShZcoCidKW17AoX5(7u4C5HJajUMmh0F46Wji4KhoCmeK2F1gF1FzrkgkdMgg)Hl7XSGdxc60hWux6PwFIZ93D35YdhbsCnzoO)WL9ywWHRNDgQSiLSFlXgizkbKYhds)HRdNGGtE4Qt8(QKajiAkjqWCfkUvXXXqqAz)wInqYusvrnmEXRurC0kEFvsGeenLeiyUcf3Q44yiiTSFlXgizkwsGPHXlE1IBv86e)5jTUejeffF7zWGtncu(yH2IZsCfe3Q4WCmfsjbIwAmFBaIRM4QMIfVsfXX3)f3Q4idkMOaj7CaV43i(DQu8kvexzcNextnSNk8WzHtCTa3iJzbIxT4vQioogcsl73sSbsMsQkQHXlUvXFEsRlrcrrX3Egm4uJaLpwOT4QjUchoqAthUE2zOYIuY(TeBGKPeqkFmi9N4C)D3(C5HJajUMmh0F4YEml4WH9uzcY(pCg67WHpMfC4ueHKy6qCKuRXZEnXrwO4yFIRjXNGSF0L4Q4Ne3YemIZD1gF1V4lI4kIYGPD46Wji4KhoCmeK2F1gF1FzrkgkdMggV4vQio((V4wfhzqXefizNd4f)gXVtXN4ehUpOuhmLU5pxEUxHZLhocK4AYCq)HB5pCpfhUShZcoCkt4K4A6WPm1y0HRVR2SwaTNjnRLIjbDQ1zsik6liWShZcsT4QXs86exHwvsLIRcIR4wvsLIRIeVoX7RscKGOv7kCsG4wf)POGVaSVfdbVdDuUJVlUvX77QnRfq7VAJV6VSifdLbtds25aEXvJL4OdXRw8QpCg67WHpMfC4UfsAEckEvqcNexthoLjSasB6W9mMsWaPNz1MtCU)UZLhocK4AYCq)HB5pCpfhUShZcoCkt4K4A6WPm1y0HRVR2SwaTNjnRLIjbDQ1zsik6liWShZcsT4QXsCfAvjvkELkI33vBwlG2F1gF1FzrkgkdMgKSZb8IRglXvq1oCD4eeCYdhedqilef1cgQa3iiqJajUMmhoLjSasB6W9mMsWaPNz1MtCU)2NlpCeiX1K5G(dx2JzbhoLjyEMdNH(oC4JzbhUQGempJ4dI4wiXtijEp55hakXxG4kkbDs8otcrrFtC0CjuFvCCczHK4id8dXnjOtIpiIBHeNjvsIdwXVFqXeFK6AeuCCSqCfLWAIZXKM1I4dq8fAiO4XkokkehnIXhyqsCmEXRdSIxLZpiO4OP)Z)hq1TdxhobbN8WvN4OvCLjCsCn1EgtjyG0ZSAJ4vQioAfpsnbIgyqXeFK6AeSrGextgXTkEKAcentcRvEM0SwAeiX1Kr8Qf3Q491gFl87aIVziKPpH4QjUcIBvC0koedqilef1StyTYIucgQyNFqWs(F()aAeiX1K5eN7z75YdhbsCnzoO)WzOVdh(ywWHt13vloYcfNJjnRfBsBe)cX5ysZA5d4uJehdOP)f3cjEcjXt8flepwX7jV4lqCfLGojENjHOOVj(TiqFvClmeq8BDagXr3uwdq)l(8IN4lwiESIdXaIVyr7WHSWcGuvCUxHdxhobbN8WbZo1adkMOqAKdhPQaML0EXaXHJTk(WL9ywWHJFxDbs)Ib70jo3RYZLhocK4AYCq)HRdNGGtE4iabrDvC1yjoBvS4wfNaee11MHqM(eIRglXvqXIBvC0kUYeojUMApJPemq6zwTrCRI3xB8TWVdi(MHqM(eIRM4kC4YEml4W9mPzTytAZjo3RANlpCeiX1K5G(d3YF4EkoCzpMfC4uMWjX10HtzQXOdxFTX3c)oG4Bgcz6tiUASe)oXVqCCmeK2ZKM1sbxNg6By8hod9D4WhZcoC1x1fpyG0ZSAZloYcfNabbhakX5ysZArCfLGoD4uMWciTPd3Zyk91gFl87aI)eN7RsNlpCeiX1K5G(d3YF4EkoCzpMfC4uMWjX10HtzQXOdxFTX3c)oG4Bgcz6tiUASe)2hUoCcco5HRVkjqcIwTRWjbhoLjSasB6W9mMsFTX3c)oG4pX5E0X5YdhbsCnzoO)WT8hUNIdx2JzbhoLjCsCnD4uMAm6W1xB8TWVdi(MHqM(eIFdlXv4W1HtqWjpCkt4K4AQH9uHholCIRf4gzmlqCRI)8KwxIeIIIV9myWPgbkFSqBXvJL4S9WPmHfqAthUNXu6Rn(w43be)jo3xfDU8WrGextMd6pCl)H7P4WL9ywWHtzcNexthoLPgJoC91gFl87aIVziKPpH43WsCfoCD4eeCYd3ZtADjsikk(2ZGbNAeO8XcTfNL4S9WPmHfqAthUNXu6Rn(w43be)jo3RGIpxE4iqIRjZb9hUShZcoCptAwlftc60HZqFho8XSGdNIsqNe3GbhakX5UAJV6x8fkEIVkjXdgi9mR20oCD4eeCYdxDIdXaeYcrrTGHkWncc0iqIRjJ4wfVVR2SwaT)Qn(Q)YIumugmnizNd4f)gwIJoeVsfXvMWjX1u7zmL(AJVf(DaXlUvXRtCCmeK2F1gF1FzrkgkdMgKSZb8IRglXvODN4vQiUYeojUMApJPemq6zwTr8QfVsfXXXqqADMC)cEcOggV4vQi(ZtADjsikk(2ZGbNAeO8XcTfxnwIZwXTkEFxTzTaA)vB8v)LfPyOmyAqYohWlUAIRGIfVAXTkEDIJJHG04jiYcZGmfL0a(2hzVM43ioBfVsfXFEsRlrcrrX3Egm4uJaLpwOT4Qj(TfV6tCUxbfoxE4iqIRjZb9hUShZcoCptAwlftc60HZqFho8XSGdh6XGaXvuc60lENjHOOx8br8RlM4868Q4kkH1eNJjnRLNnOjD2HtCv8fkooHSqs8GHehzqXeItaZl(Gio3QiXTSGQgIJtIdP0Cv8biEm2u7W1HtqWjpCkt4K4AQ9mMsFTX3c)oG4f3Q447)IBvCKbftuGKDoGx8BeVVR2SwaT)Qn(Q)YIumugmnizNd4fVsfXrR4rQjq0iGssV8dav5zsZA5BeiX1K5eN4WHmG5zoxEUxHZLhocK4AYCq)HB5pCpfhUShZcoCkt4K4A6WPm1y0HlsnbIgpKSjZezmlOrGextgXTk(ZtADjsikk(2ZGbNAeO8XcTf)gXRtCvkUkiEFvsGeena1HREHgXRwCRIJwX7RscKGOv7kCsWHZqFho8XSGdh6Mz0K4y)aqjUQdjBYmrgZcux8u5ogX75hdaL4C6PtINaJ4kA6K4wyiG4CmPzTiUIsqNeFEX)DbIhR44K4ypzuxCsvDIpehzHIxf(kCsWHtzclG0MoC8qYMmLhyk9fyMywWjo3F35YdhbsCnzoO)W1HtqWjpCOvCLjCsCn14HKnzkpWu6lWmXSaXTk(ZtADjsikk(2ZGbNAeO8XcTf)gXvnXTkoAfhhdbP9mPzTumjOtnmEXTkoogcs71tNkjWumtNAqYohWl(nIJmOyIcKSZb8IBvCiHaPNjX10Hl7XSGd3RNovsGPyMoDIZ93(C5HJajUMmh0F46Wji4KhoLjCsCn14HKnzkpWu6lWmXSaXTkEFxTzTaAptAwlftc6uRZKqu0xqGzpMfKAXVrCfAvjvkUvXXXqqAVE6ujbMIz6uds25aEXVr8(UAZAb0(R24R(llsXqzW0GKDoGxCRIxN49D1M1cO9mPzTumjOtniLMRIBvCCmeK2F1gF1FzrkgkdMgKSZb8IRcIJJHG0EM0SwkMe0PgKSZb8IFJ4k0Ut8QpCzpMfC4E90PscmfZ0PtCUNTNlpCeiX1K5G(d3YF4EkoCzpMfC4uMWjX10HtzQXOdND(bbl5)5)dOaj7CaV4QjUIfVsfXrR4rQjq0adkM4JuxJGncK4AYiUvXJutGOzsyTYZKM1sJajUMmIBvCCmeK2ZKM1sXKGo1W4fVsfXFEsRlrcrrX3Egm4uJaLpwOT4QXs86eNTIRcI)bL6GHmTuRfxfjEKAceTNjnRLcY2X(gbsCnzeV6dNH(oC4JzbhUBHKMNGIxfKWjX1K4iluC0igFGbPM4C1gEXnyWbGs8QC(bbfhn9F()aeFHIBWGdaL4kkbDsCltWiUIsynXtGrCWk(9dkM4JuxJGTdNYewaPnD4(AdFbIXhyq6eN7v55YdhbsCnzoO)WL9ywWHdIXhyq6WzOVdh(ywWHRkmr8IJXloAeJpWGK4dI4ti(8IN4lwiESIdXaIVyr7W1HtqWjpCOv8pOuhmKPLAT4wfVoXrR4kt4K4AQ91g(ceJpWGK4vQiUYeojUMAypv4HZcN4AbUrgZceVAXTkEKquu0IXMkXwmdjUkioKSZb8IRM4QM4wfhsiq6zsCnDIZ9Q25Ydx2JzbhUN6qkkb1zaZTeJoCeiX1K5G(tCUVkDU8WrGextMd6pCzpMfC4Gy8bgKoC9RDnvIeIII)CVchUoCcco5HdTIRmHtIRP2xB4lqm(adsIBvC0kUYeojUMAypv4HZcN4AbUrgZce3Q4ppP1LiHOO4BpdgCQrGYhl0wC1yj(DIBv8iHOOOfJnvITygsC1yjEDIRsXVq86e)oXvrI3xB8TWVdiEXRw8Qf3Q4qcbsptIRPdNH(oC4JzbhUQmMogZgXaqjEKquu8IhmziULrRfxpkjXrwO4bdjUbdMXSaXxeXrJy8bgKuxCiHaPNrCdgCaOeNpbgYE6TtCUhDCU8WrGextMd6pCzpMfC4Gy8bgKoCg67WHpMfC4qJecKEgXrJy8bgKeNsO(Q4dI4tiULrRfNuf)ajXnyWbGsCUR24R(BIROv8GjdXHecKEgXheX5wfjokkEXHuAUk(aepyiXbKQcXv53oCD4eeCYdhAfxzcNextTV2WxGy8bgKe3Q4qYohWl(nI33vBwlG2F1gF1FzrkgkdMgKSZb8IFH4kOyXTkEFxTzTaA)vB8v)LfPyOmyAqYohWl(nSexLIBv8iHOOOfJnvITygsCvqCizNd4fxnX77QnRfq7VAJV6VSifdLbtds25aEXVqCvEIZ9vrNlpCeiX1K5G(dxhobbN8WHwXvMWjX1ud7PcpCw4exlWnYywG4wf)5jTUejeffV4QXs8BF4YEml4WHRZETc)AXqWtCUxbfFU8WL9ywWHJuoFNGzqhocK4AYCq)joXjoCkj4pl4C)Dk(U7u8TvaDC4SKqWaq9ho0nAcnEpA29vXOlXf)sgs8XMFHH4ilu8Q(bL6GHmvvCiDlXgize)xBs8elw7miJ4DMeGI(MWo6CaK4QeDjE9xGscgKr8QcXaeYcrrn0qvfpwXRkedqilef1qdncK4AYuvXRtbvvDtyhDoasC0b6s86VaLemiJ4vfIbiKfIIAOHQkESIxvigGqwikQHgAeiX1KPQIxNcQQ6MWUWo6gnHgVhn7(Qy0L4IFjdj(yZVWqCKfkEv5HuFTXZOQIdPBj2ajJ4)AtINyXANbzeVZKau03e2rNdGe)2OlXR)cusWGmIx1FX04dW0qdvv8yfVQ)IPXhGPHgAeiX1KPQIxNcQQ6MWo6CaK43gDjE9xGscgKr8Q(lMgFaMgAOQIhR4v9xmn(amn0qJajUMmvv8mehn3Ti6u86uqvv3e2rNdGeVkHUeV(lqjbdYiEvHyaczHOOgAOQIhR4vfIbiKfIIAOHgbsCnzQQ4zioAUBr0P41PGQQUjSlSJUrtOX7rZUVkgDjU4xYqIp28lmehzHIx1U5RQ4q6wInqYi(V2K4jwS2zqgX7mjaf9nHD05aiXzl6s86VaLemiJ4vfIbiKfIIAOHQkESIxvigGqwikQHgAeiX1KPQIx3DQQ6MWo6CaK4Qg6s86VaLemiJ4vfIbiKfIIAOHQkESIxvigGqwikQHgAeiX1KPQIxNcQQ6MWo6CaK4kCB0L41FbkjyqgXRkedqilef1qdvv8yfVQqmaHSquudn0iqIRjtvfVofuv1nHD05aiXvq1qxIx)fOKGbzeVQ)IPXhGPHgQQ4XkEv)ftJpatdn0iqIRjtvfVU7uv1nHDHD0nAcnEpA29vXOlXf)sgs8XMFHH4ilu8Q(bL6GP0nFvfhs3sSbsgX)1MepXI1odYiENjbOOVjSJohaj(DOlXR)cusWGmIxvigGqwikQHgQQ4XkEvHyaczHOOgAOrGextMQkEgIJM7weDkEDkOQQBc7OZbqIFB0L41FbkjyqgXRkedqilef1qdvv8yfVQqmaHSquudn0iqIRjtvfpdXrZDlIofVofuv1nHD05aiXvqXOlXR)cusWGmIxvigGqwikQHgQQ4XkEvHyaczHOOgAOrGextMQkEDkOQQBc7c7OB0eA8E0S7RIrxIl(LmK4Jn)cdXrwO4vfhB0MQkoKULydKmI)RnjEIfRDgKr8otcqrFtyhDoasCfqxIx)fOKGbzeVQqmaHSquudnuvXJv8QcXaeYcrrn0qJajUMmvv86uqvv3e2rNdGexLOlXR)cusWGmIx1ySPsSLNjAOHgVg7RQ4XkEvJXMkXwEMOWRX(gAOQIx3DQQ6MWUWoAMn)cdYiEvs8ShZcexpF8nH9d3Zt9Z93PAkC44HlYOPdx9QN4Cy4HMIRIJgxuyKWE9QN4OjE4OfxbvQU43P47UtyxyVE1t86ZKau0JUe2Rx9exfeVkVkjXvMWjX1ud7PcpCw4exlWnYywG4y8I)R4ti(8I)uiooHSqsClK4ypj(enH96vpXvbXR)AJpasCBmDm8As8EQ1LShZck65dXjqah6fpwXHKbRtIZVbbIj1IdjllSwtyVE1tCvq8QCwJe)w10Z0Hjsi(acccX4dXhG491gpdXheXTqIJMh7dXnJr8jehzHIRC1zmAQ8RwjbIMWUWE9QN4QoKuH6V24ziSN9ywW34HuFTXZ4cwSj551xl878lqyp7XSGVXdP(AJNXfSyd(gHMmfeDELmwgaQsSQAac7zpMf8nEi1xB8mUGfBq00Z0HjsO(GW6xmn(amnESpW0uHGy8XSGkv(ftJpatt5QZy0u5xTscec7zpMf8nEi1xB8mUGfB(GsDWiSN9ywW34HuFTXZ4cwSXoH1itbzHfdLbJ68qQV24zuEQVaZZsbvkSN9ywW34HuFTXZ4cwS51tNkjWumtNuNhs91gpJYt9fyEwkO(GWcsiq6zsCnjSN9ywW34HuFTXZ4cwS5zsZAPGRtd9QpiSGyaczHOOMDcRvwKsWqf78dcwY)Z)hGWUWE9QN4v5CaIJg3iJzbc7zpMf8SQn9Ac71tCv8tgXJvCdfe0EaK4wyOGHGI33vBwlGxCl5eIJSqX5aksC88jJ4lq8iHOO4Bc7zpMf8xWInkt4K4AsDqAtSEGP0xGzIzbQRm1yelCmeK2RNovsGPyMo1W4Ru55jTUejeffF7zWGtncu(yH2QXs1e2ZEml4VGfBuMWjX1K6G0My9atPVaZeZcuxzQXiw4yiiTxpDQKatXmDQHXxPYZtADjsikk(2ZGbNAeO8XcTvJLQjSxpXRpd1RjESI)ej(GiEWqIdivfIxFvx86gG4bdjoPKaH4lI4P4CmxkopC7vl(8IJMaJD2zsikYiSN9ywWFbl2OmHtIRj1bPnXA(cGuvu68Lem2zNjHOiJ6dcR(QKajiA1UcNeOUYuJrS6Rn(w43beplfSIJHG0OoZoaufiXdh7eyk31W4RuPV24BHFhq8SUZkogcsJ6m7aqvGepCStGPC7ggFLk91gFl87aIN1TTIJHG0OoZoaufiXdh7eykSTHXxPsFTX3c)oG4zXwR4yiinQZSdavbs8WXobMIkBy8c71tC0uVVyGqCKfkohZLIdPShZcepgBsC8RIpOalCaOexVwuH6R6INGXo7mjefze3oJod9IpaXdgsCf3u5lopK6ezgakXtX53GaXKAX5yUuCE42f2ZEml4VGfBuMWjX1K6G0MyriiupgLuPV24BHFhq8QRm1yelcbH6XOKk91gFl87aIxyp7XSG)cwSrzcNextQdsBIfHGq9yusL(AJVf(DaXR(GWQVkjqcIwTRWjbwjeeQhJsQ0xB8TWVdiE16Rn(w43beV1(AJVf(DaX3meY0NqT7SgJnvIT8mrHxJ9n2EJIBQ0kAvMWjX1uB(cGuvu68Lem2zNjHOiJ6ktngXQV24BHFhq8c71t8BrG(Q4DMeGIehUrgZceFqe3cjotQKeNholCIRf4gzmlq8NcXtGrCBmDm8As8iHOO4fhJVjSN9ywWFbl2OmHtIRj1bPnXc7PcpCw4exlWnYywG6ktngXIholCIRf4gzmlW6ZtADjsikk(2ZGbNAeO8XcTvJ1Dc71t86Zq9AIxFf9INH4id8dH9ShZc(lyXMEQ1LShZck65d1bPnXQBEH96joAINxFvCo90jXtGrCfnDs8me)UleV(QU4gm4aqjEWqIJmWpexbfl(t9fyE1fprcckEWKH4S9cXRVQl(Gi(eItQIFG0lULjygG4bdjoGuviEvC9vK4lu85fhSH4y8c7zpMf8xWInVE6ujbMIz6K6dcRNN06sKquu8TNbdo1iq5JfAFJQzfzqXefizNd4vt1SIJHG0E90PscmfZ0PgKSZb83GQBA2PQS2xB8TWVdiE1yXwvOUySPBuqXvRIUtyVEIJgXaIJGP1xf)TmrNHEXJv8GHeNlOuhmKrC04gzmlq86WVkUzhakX)vDXNqCKf2PxC(D1daL4dI4GnygakXNx8uzo6extv3e2ZEml4VGfBGyGs2Jzbf98H6G0My9bL6GHmQpiS(GsDWqMwQ1c71tCvholCIRIJg3iJzb3cehDsrvFXrnkjXtX7WKx8eFXcXjabrDvCKfkEWqI)bL6Gr86ROx86WXgTHGI)XO1IdPNN6H4tuDt8QqX4vx8jeVNaXXjXdMme)hBEn1e2ZEml4VGfB6PwxYEmlOONpuhK2eRpOuhmLU5vFqyPmHtIRPg2tfE4SWjUwGBKXSaH96jUk(jJ4XkUHqgajUfgciESIJ9K4FqPoyeV(k6fFHIJJnAdbFH9ShZc(lyXgLjCsCnPoiTjwFqPoykbdKEMvBuxzQXiw3PYlIutGOPCqTWgbsCnzur3P4lIutGOzNFqWYIuEM0Sw(gbsCnzur3P4lIutGO9mPzTuq2o23iqIRjJk6ovErKAceTuND4exBeiX1KrfDNIV4ovQIQ75jTUejeffF7zWGtncu(yH2QXITvlSxpXR)c(XqqXX(bGs8uCUGsDWiE9vK4wyiG4qk7mdaL4bdjobiiQRIhmq6zwTryp7XSG)cwSPNADj7XSGIE(qDqAtS(GsDWu6Mx9bHfbiiQRndHm9jUHLYeojUMAFqPoykbdKEMvBe2RN436aMNr8me3ovL6IZ2le3YemlwiUI4eFHIBzcgX5wfjEhoH44yiiQlUkVqCltWiUI4eVUfl(XqI)bL6GP6QqkULjyexrCIN6FfhzaZZiEgIZ2leprLd4dXzR4rcrrXlEDlw8JHe)dk1bt1c7zpMf8xWIn9uRlzpMfu0ZhQdsBIfYaMNr9bHLYeojUMAecc1Jrjv6Rn(w43beVAS68f7uvLNNaMkv6Rn(w43beFZqitFIByPqLkidkMOaj7Ca)nSuWQYeojUMAecc1Jrjv6Rn(w43beVASUDLk4yiiT)Qn(Q)YIumugmLel2oCIggVvLjCsCn1ieeQhJsQ0xB8TWVdiE1yX2kvEEsRlrcrrX3Egm4uJaLpwOTASyRvLjCsCn1ieeQhJsQ0xB8TWVdiE1yXwH96jUk(jXtXXXgTHGIBHHaIdPSZmauIhmK4eGGOUkEWaPNz1gH9ShZc(lyXMEQ1LShZck65d1bPnXchB0g1heweGGOU2meY0N4gwkt4K4AQ9bL6GPemq6zwTryVEIJoxl0hIZdNfoXvXhG4Pwl(IiEWqIJMuD0P44upXEs8jeVNyp9INIxfxFfjSN9ywWFbl2KWEcOsSqibc1heweGGOU2meY0NqnwkOYliabrDTbjueqyp7XSG)cwSjH9eqfEm9tc7zpMf8xWIn6bft8f08ygu2eie2ZEml4VGfBWtuLfPeWPx7f2f2Rx9eh9yJ2qWxyp7XSGVHJnAdRNzuQ(GWcTrQjq0adkM4JuxJGncK4AYyfIbiKfIIAXaUwIvvtVGRtdz95jTUejeffF7zWGtncu(yH23OsH9ShZc(go2OnxWInpdgCQrGYhl0w9bH1ZtADjsikkE1yDN16qBFvsGeena1HREHMkv67QnRfq7jimdYuWxavE(Pg1Stvv6mjef9QqNjHOOVGaZEmli1QXsXT7uzLkppP1LiHOO4BpdgCQrGYhl0wn2wT16WXqqA8eezHzqMIsAaF7JSx7gwSTsLNN06sKquu8TNbdo1iq5JfARgBTIwLjCsCn1WEQWdNfoX1cCJmMfuTWE2JzbFdhB0MlyXMNGWmitbFbu55NAK6dclCmeKgpbrwygKPOKgW3(i71UH1DwRRVR2SwaTNGWmitbFbu55NAuZovvPZKqu0RcDMeII(ccm7XSGuFdlf3UtLvQ8lMgFaMMMstb)AHuvAZRPgbsCnzSIwCmeKMMstb)AHuvAZRPggFLk)IPXhGPvJuoGVSBvii9aq1iqIRjJv0AiCmeKwns5a(Ifygmnm(Qf2ZEml4B4yJ2Cbl2GsVRnUonKWE9eh9zV2hjU4JTnzMmi9vXXaA6FXdgsCaPQq86R6IpV4OjWyNDMeIImINaJ4wiXTSGQgI3tEXjabrDvCl5edaL4ilu8jAc7zpMf8nCSrBUGfBWZETpsC1hewOTVkjqcIwTRWjbvQG26uMWjX1uB(cGuvu68Lem2zNjHOiJ16IXMkXwEMOD7gVg7VrXnvwPsm2uj2YZen2241y)nkuTvcqquxVr1uC1c7c71t86VR2SwaVWE9exf)K4kkbDs8fbrfq1nIJtilKepyiXrg4hIZXGbNAeqCUyH2IJaxBXVCHG0SI3xB6fFanH9ShZc(w38SEM0SwkMe0j1XEQSiifuDdlfuFqyHwCmeK2ZKM1sXKGo1W4TIJHG0Egm4uJaLyHG0SnmER4yiiTNbdo1iqjwiinBds25a(ByD7Mkf2RN41PIbA6FXtnKsZvXX4fhN6j2tIBHep2TM4CmPzTi(TUDSVAXXEsCUR24R(fFrqubuDJ44eYcjXdgsCKb(H4CmyWPgbeNlwOT4iW1w8lxiinR491MEXhqtyp7XSGV1n)fSyZF1gF1Fzrkgkdg1XEQSiifuDdlfuFqyHJHG0Egm4uJaLyHG0SnmER4yiiTNbdo1iqjwiinBds25a(ByD7Mkf2ZEml4BDZFbl2GOtuKwNXSa1hewkt4K4AQ9atPVaZeZcSI2pOuhmKPzNGqtwR75jTUejeffF7zWGtncu(yH23WsbR9D1M1cO9xTXx9xwKIHYGPHXBfTrQjq0EM0SwkiBh7BeiX1KPsfCmeK2F1gF1FzrkgkdMggF1w7Rn(w43beVASuPWE2JzbFRB(lyXgLjyEg1hew1bXaeYcrrn7ewRSiLGHk25heSK)N)paR91gFl87aIVziKPpXnSuqfIutGOziINGLpGzqOi7gbsCnzQubIbiKfIIAgkdg91YZKM1YBTV24BHFhq83Oq1wXXqqA)vB8v)LfPyOmyAy8wXXqqAptAwlftc6udJ3QD(bbl5)5)dOaj7CaplfBfhdbPzOmy0xlptAwlFZSwac71tCvFxT4ilu8lxiinR48qsf4wfjULjyeNJrrIdP0CvClmeqCWgIdXaGbGsCUBTjSN9ywW36M)cwSHFxDbs)Ib7K6ilSaivfSuq9bHvKAceTNbdo1iqjwiinBJajUMmwrBKAceTNjnRLcY2X(gbsCnze2RN4Q4Ne)YfcsZkopKeNBvK4wyiG4wiXzsLK4bdjobiiQRIBHHcgckocCTfNFx9aqjULjywSqCUBv8fkoAESpehfbiyQ1xBc7zpMf8TU5VGfBEgm4uJaLyHG0SQpiSEEsRlrcrrX3Egm4uJaLpwO9nSuWkbiiQRQXs1uSvLjCsCn1EGP0xGzIzbw77QnRfq7VAJV6VSifdLbtdJ3AFxTzTaAptAwlftc6uRZKqu0RglfSwhAHyaczHOO2ItMHaDQsfdHJHG0q0jksRZywqdJVsLNN06sKquu8TNbdo1iq5JfARgR6u4c2QIQdTrQjq0adkM4JuxJGncK4AYyfTrQjq0mjSw5zsZAPrGextMQRUAR91gFl87aI)gw3zfT4yiinEiztMjYywqdJ3ADOTVkjqcIMscemxHvQG2(UAZAb0q0jksRZywqdJVAH9ShZc(w38xWInpbHzqMc(cOYZp1i17x7AQejeffplfuFqyPmHtIRP2dmL(cmtmlWkAnB0EccZGmf8fqLNFQrfZgTy61gakRrcrrrlgBQeBXmKASUtbR11xB8TWVdi(MHqM(eQXQUoFbvoa1UfW2QR2kAXXqqApdgCQrGsSqqA2ggV16qlogcsJhs2KzImMf0W4Ru55jTUejeffF7zWGtncu(yH2QX2QRubF)3kYGIjkqYohWFdlvA95jTUejeffF7zWGtncu(yH23CBH9ShZc(w38xWInpX)ZR(GWszcNextThyk9fyMywG1(AJVf(DaX3meY0NqnwkynsikkAXytLylMHuJLcQMWE9exf)K4CxTXx9l(ceVVR2SwaIxxIeeuCKb(H4CafvT4yan9V4wiXtijoQDaOepwX5xEXVCHG0SINaJ4MvCWgIZKkjX5ysZAr8BD7yFtyp7XSGV1n)fSyZF1gF1Fzrkgkdg1hewkt4K4AQ9atPVaZeZcSwhA)GsDWqMwQ1vQGJHG04jiYcZGmfL0a(2hzV2nSTsLNN06sKquu8TNbdo1iq5JfARgBTIwLjCsCn1WEQWdNfoX1cCJmMfuT16qBKAceTNbdo1iqjwiinBJajUMmvQePMar7zsZAPGSDSVrGextMkvEEsRlrcrrX3Egm4uJaLpwOTASURsL(UAZAb0Egm4uJaLyHG0SnizNd4v7UQTwhA7RscKGOPKabZvyLk9D1M1cOHOtuKwNXSGgKSZb8QPGIRuPVR2SwaneDII06mMf0W4T2xB8TWVdiE1yPYQf2RN4OziINgZlEcjXX4vx8hm8K4bdj(ciXTmbJ461c9H4xEPIAIRIFsClmeqCZ1bGsCK8dckEWKaXRVQlUHqM(eIVqXbBi(huQdgYiULjywSq8eCv86R6nH9ShZc(w38xWIn2jSgzkilSyOmyuxpaQ0nSuOPs17x7AQejeffplfuFqybZXuiLeiAPX8nmER1fjeffTySPsSfZq30xB8TWVdi(MHqM(evQG2pOuhmKPLAT1(AJVf(DaX3meY0NqnwD(IDQQYZtat1c71tC0meXbR4PX8IBz0AXndjULjygG4bdjoGuvi(Tv8RU4ypjEvgrrIVaXX3)f3YemlwiEcUkE9v9MWE2JzbFRB(lyXg7ewJmfKfwmugmQpiSG5ykKsceT0y(2au72kwfG5ykKsceT0y(MbdMXSaR91gFl87aIVziKPpHAS68f7uvLNNagH9ShZc(w38xWInptAwlfCDAOx9bHLYeojUMApWu6lWmXSaR91gFl87aIVziKPpHASUZAD4yiiT)Qn(Q)YIumugmnm(kvW3)TImOyIcKSZb83W6ofxPcAXXqqAptAwlfCDAOVHXB9POGVaSVfdbVdDuUJVxTWE2JzbFRB(lyXgQZSdavbs8WXobg1hewO9dk1bdzAPwBvzcNextThyk9fyMywG1(AJVf(DaX3meY0Nqnw3zToLjCsCn1WEQWdNfoX1cCJmMfuPYZtADjsikk(2ZGbNAeO8XcTVHfBRubIbiKfIIAq6xmGzaOkDDcN4A1c71tC09emIZDRQl(GioydXtnKsZvXnlGuxCSNe)YfcsZkULjyeNBvK4y8nH9ShZc(w38xWInpdgCQrGsSqqAw1hew1fPMar7zsZAPGSDSVrGextMkvEEsRlrcrrX3Egm4uJaLpwOTASURARkt4K4AQ9atPVaZeZcSIJHG0(R24R(llsXqzW0W4T2xB8TWVdi(ByDN16qlogcsJhs2KzImMf0W4Ru55jTUejeffF7zWGtncu(yH2QX2Qf2ZEml4BDZFbl28mPzTumjOtQpiSqlogcs7zsZAPysqNAy8wrgumrbs25a(ByHoUisnbI2JHheebdf1iqIRjJWE2JzbFRB(lyXgen9mDyIeQpiSQ7xmn(amnESpW0uHGy8XSGkv(ftJpatt5QZy0u5xTscevBLaee11MHqM(eQX62k2kA)GsDWqMwQ1wXXqqA)vB8v)LfPyOmyAM1cq9beeeIXhLX2MmtgelfuFabbHy8rbLEXtnlfuFabbHy8rzqy9lMgFaMMYvNXOPYVALeie2ZEml4BDZFbl2WVXSa1hew4yiinC9Ugn2hniL9Osf89FRidkMOaj7Ca)n3wXvQGJHG0(R24R(llsXqzW0W4Twhogcs7zsZAPGRtd9nm(kv67QnRfq7zsZAPGRtd9nizNd4VHLckUAH9ShZc(w38xWIn46Dnfem4v1hew4yiiT)Qn(Q)YIumugmnmEH9ShZc(w38xWIn4e8jyTbGs9bHfogcs7VAJV6VSifdLbtdJxyp7XSGV1n)fSydYajC9Ug1hew4yiiT)Qn(Q)YIumugmnmEH9ShZc(w38xWInjOtFatDPNAT6dclCmeK2F1gF1FzrkgkdMggVWE2JzbFRB(lyXgSNktq2QdsBIvp7muzrkz)wInqYuciLpgKE1hew11xLeibrtjbcMRqR4yiiTSFlXgizkPQOggFLkOTVkjqcIMscemxHwXXqqAz)wInqYuSKatdJVAR198KwxIeIIIV9myWPgbkFSqBwkyfMJPqkjq0sJ5BdqnvtXvQGV)BfzqXefizNd4V5ovwPIYeojUMAypv4HZcN4AbUrgZcQUsfCmeKw2VLydKmLuvudJ36ZtADjsikk(2ZGbNAeO8XcTvtbH96jUIiKethIJKAnE2RjoYcfh7tCnj(eK9JUexf)K4wMGrCUR24R(fFrexrugmnH9ShZc(w38xWInypvMGSF1hew4yiiT)Qn(Q)YIumugmnm(kvW3)TImOyIcKSZb83CNIf2f2Rx9e)whW8me8f2RN4OBMrtIJ9daL4QoKSjZezmlqDXtL7yeVNFmauIZPNojEcmIROPtIBHHaIZXKM1I4kkbDs85f)3fiESIJtIJ9KrDXjv1j(qCKfkEv4RWjbc7zpMf8nKbmpdlLjCsCnPoiTjw8qYMmLhyk9fyMywG6ktngXksnbIgpKSjZezmlOrGextgRppP1LiHOO4BpdgCQrGYhl0(M6uPk0xLeibrdqD4QxOPAROTVkjqcIwTRWjbc7zpMf8nKbmpZfSyZRNovsGPyMoP(GWcTkt4K4AQXdjBYuEGP0xGzIzbwFEsRlrcrrX3Egm4uJaLpwO9nQMv0IJHG0EM0SwkMe0PggVvCmeK2RNovsGPyMo1GKDoG)gKbftuGKDoG3kKqG0ZK4Asyp7XSGVHmG5zUGfBE90PscmfZ0j1hewkt4K4AQXdjBYuEGP0xGzIzbw77QnRfq7zsZAPysqNADMeII(ccm7XSGuFJcTQKkTIJHG0E90PscmfZ0PgKSZb8303vBwlG2F1gF1FzrkgkdMgKSZb8wRRVR2SwaTNjnRLIjbDQbP0C1kogcs7VAJV6VSifdLbtds25aEvahdbP9mPzTumjOtnizNd4VrH2DvlSxpXVfsAEckEvqcNextIJSqXrJy8bgKAIZvB4f3GbhakXRY5heuC00)5)dq8fkUbdoauIROe0jXTmbJ4kkH1epbgXbR43pOyIpsDnc2e2ZEml4BidyEMlyXgLjCsCnPoiTjwFTHVaX4dmiPUYuJrSSZpiyj)p)FafizNd4vtXvQG2i1eiAGbft8rQRrWgbsCnzSgPMarZKWALNjnRLgbsCnzSIJHG0EM0SwkMe0PggFLkppP1LiHOO4BpdgCQrGYhl0wnw1Xwv4dk1bdzAPwRIIutGO9mPzTuq2o23iqIRjt1c71t8QWeXlogV4Orm(adsIpiIpH4ZlEIVyH4Xkoedi(IfnH9ShZc(gYaMN5cwSbIXhyqs9bHfA)GsDWqMwQ1wRdTkt4K4AQ91g(ceJpWGuLkkt4K4AQH9uHholCIRf4gzmlOARrcrrrlgBQeBXmKkaj7CaVAQMviHaPNjX1KWE2JzbFdzaZZCbl28uhsrjOodyULyKWE9eVkJPJXSrmauIhjeffV4btgIBz0AX1JssCKfkEWqIBWGzmlq8frC0igFGbj1fhsiq6ze3GbhakX5tGHSNEtyp7XSGVHmG5zUGfBGy8bgKuVFTRPsKquu8Suq9bHfAvMWjX1u7Rn8figFGbjROvzcNextnSNk8WzHtCTa3iJzbwFEsRlrcrrX3Egm4uJaLpwOTASUZAKquu0IXMkXwmdPgR6u5f1DNkQV24BHFhq8vxTviHaPNjX1KWE9ehnsiq6zehnIXhyqsCkH6RIpiIpH4wgTwCsv8dKe3GbhakX5UAJV6VjUIwXdMmehsiq6zeFqeNBvK4OO4fhsP5Q4dq8GHehqQkexLFtyp7XSGVHmG5zUGfBGy8bgKuFqyHwLjCsCn1(AdFbIXhyqYkKSZb8303vBwlG2F1gF1FzrkgkdMgKSZb8xOGIT23vBwlG2F1gF1FzrkgkdMgKSZb83WsLwJeIIIwm2uj2Izivas25aE167QnRfq7VAJV6VSifdLbtds25a(luPWE2JzbFdzaZZCbl2GRZETc)AXqq1hewOvzcNextnSNk8WzHtCTa3iJzbwFEsRlrcrrXRgRBlSN9ywW3qgW8mxWInKY57emdsyxyVE1tCUGsDWiE93vBwlGxyVEIFlK08eu8QGeojUMe2ZEml4BFqPoykDZZszcNextQdsBI1ZykbdKEMvBuxzQXiw9D1M1cO9mPzTumjOtTotcrrFbbM9ywqQvJvDk0QsQufuCRkPsvuD9vjbsq0QDfojW6trbFbyFlgcEh6OChF3AFxTzTaA)vB8v)LfPyOmyAqYohWRgl0r1vlSN9ywW3(GsDWu6M)cwSrzcNextQdsBI1ZykbdKEMvBuFqybXaeYcrrTGHkWnccOUYuJrS67QnRfq7zsZAPysqNADMeII(ccm7XSGuRglfAvjvwPsFxTzTaA)vB8v)LfPyOmyAqYohWRglfunH96jEvqcMNr8brClK4jKeVN88daL4lqCfLGojENjHOOVjoAUeQVkooHSqsCKb(H4Me0jXheXTqIZKkjXbR43pOyIpsDnckoowiUIsynX5ysZAr8bi(cneu8yfhffIJgX4dmijogV41bwXRY5heuC00)5)dO6MWE2JzbF7dk1btPB(lyXgLjyEg1hew1HwLjCsCn1EgtjyG0ZSAtLkOnsnbIgyqXeFK6AeSrGextgRrQjq0mjSw5zsZAPrGextMQT2xB8TWVdi(MHqM(eQPGv0cXaeYcrrn7ewRSiLGHk25heSK)N)paH96jUQVRwCKfkohtAwl2K2i(fIZXKM1YhWPgjogqt)lUfs8esIN4lwiESI3tEXxG4kkbDs8otcrrFt8BrG(Q4wyiG436amIJUPSgG(x85fpXxSq8yfhIbeFXIMWE2JzbF7dk1btPB(lyXg(D1fi9lgStQJSWcGuvWsb1jvfWSK2lgiyXwfR(GWcMDQbgumrH0ic7zpMf8TpOuhmLU5VGfBEM0SwSjTr9bHfbiiQRQXITk2kbiiQRndHm9juJLck2kAvMWjX1u7zmLGbspZQnw7Rn(w43beFZqitFc1uqyVEIxFvx8GbspZQnV4iluCceeCaOeNJjnRfXvuc6KWE2JzbF7dk1btPB(lyXgLjCsCnPoiTjwpJP0xB8TWVdiE1vMAmIvFTX3c)oG4Bgcz6tOgR7UahdbP9mPzTuW1PH(ggVWE2JzbF7dk1btPB(lyXgLjCsCnPoiTjwpJP0xB8TWVdiE1vMAmIvFTX3c)oG4Bgcz6tOgRBR(GWQVkjqcIwTRWjbc7zpMf8TpOuhmLU5VGfBuMWjX1K6G0My9mMsFTX3c)oG4vxzQXiw91gFl87aIVziKPpXnSuq9bHLYeojUMAypv4HZcN4AbUrgZcS(8KwxIeIIIV9myWPgbkFSqB1yXwH9ShZc(2huQdMs38xWInkt4K4AsDqAtSEgtPV24BHFhq8QRm1yeR(AJVf(DaX3meY0N4gwkO(GW65jTUejeffF7zWGtncu(yH2SyRWE9exrjOtIBWGdaL4CxTXx9l(cfpXxLK4bdKEMvBAc7zpMf8TpOuhmLU5VGfBEM0SwkMe0j1hew1bXaeYcrrTGHkWnccyTVR2SwaT)Qn(Q)YIumugmnizNd4VHf6OsfLjCsCn1EgtPV24BHFhq8wRdhdbP9xTXx9xwKIHYGPbj7CaVASuODxLkkt4K4AQ9mMsWaPNz1MQRubhdbP1zY9l4jGAy8vQ88KwxIeIIIV9myWPgbkFSqB1yXwR9D1M1cO9xTXx9xwKIHYGPbj7CaVAkO4QTwhogcsJNGilmdYuusd4BFK9A3W2kvEEsRlrcrrX3Egm4uJaLpwOTA3UAH96jo6XGaXvuc60lENjHOOx8br8RlM4868Q4kkH1eNJjnRLNnOjD2HtCv8fkooHSqs8GHehzqXeItaZl(Gio3QiXTSGQgIJtIdP0Cv8biEm2utyp7XSGV9bL6GP0n)fSyZZKM1sXKGoP(GWszcNextTNXu6Rn(w43beVv89FRidkMOaj7Ca)n9D1M1cO9xTXx9xwKIHYGPbj7CaFLkOnsnbIgbus6LFaOkptAwlFJajUMmc7c71REIZfuQdgYioACJmMfiSxpXrZqeNlOuhmSrzcMNr8esIJXRU4ypjohtAwlFaNAK4XkoobiKjehbU2IhmK485)JssC8fG9INaJ436amIJUPSgG(xDXjLeq8brClK4jKepdXTtvjE9vDXRddOP)fh7hakXRY5heuC00)5)dOAH9ShZc(2huQdgYW6zsZA5d4uJuFqyvhogcs7dk1btdJVsfCmeKMYemptdJVAR198KwxIeIIIV9myWPgbkFSq7ByBLkkt4K4AQH9uHholCIRf4gzmlOAR25heSK)N)pGcKSZb8SuSWE9e)whW8mINH43(cXRVQlULjywSqCfXjoBeNTxiULjyexrCIBzcgX5yWGtnci(LleKMvCCmeeXX4fpwXtL7ye)xBs86R6IBj)Ge)NalJzbFtyVEIJM0)k(NiK4XkoYaMNr8meNTxiE9vDXTmbJ4KQYEOVkoBfpsikk(M41XL2K45l(If)yiX)GsDW0QwyVEIFRdyEgXZqC2EH41x1f3YemlwiUI4uxCvEH4wMGrCfXPU4jWiUQjULjyexrCINibbfVkibZZiSN9ywW3(GsDWqMlyXMEQ1LShZck65d1bPnXczaZZO(GWszcNextncbH6XOKk91gFl87aIxnwD(IDQQYZtatLk4yiiTNbdo1iqjwiinBdJ3AFTX3c)oG4Bgcz6tCdR7Qu55jTUejeffF7zWGtncu(yH2QXITwvMWjX1uJqqOEmkPsFTX3c)oG4vJfBRuPV24BHFhq8ndHm9jUHLcQqDrQjq0meXtWYhWmsuKDJajUMmwXXqqAktW8mnm(Qf2ZEml4BFqPoyiZfSyZZKM1YhWPgP(GW6dk1bdzApX)ZB95jTUejeffF7zWGtncu(yH23WwH96jo6ZETpsCXnyWbGsCoM0SwexrjOtIBHHaIVaXzgumIR6vbI)r2R9INaJ4CmPzTio61PHEXNxCm(MWE2JzbF7dk1bdzUGfBWZETpsC1hew9fyWMOXtqKfMbzkkPb8nycQPgl0HvCmeKgpbrwygKPOKgW3(i71uJLkTIJHG0EM0SwkMe0PgKSZb8QX62wXXqqAptAwlfCDAOVHXBTUNN06sKquu8TNbdo1iq5JfAFdRBxPIYeojUMAypv4HZcN4AbUrgZcQ2AD4yiiTNjnRLcUon03GKDoG)gw4yiiTNjnRLIjbDQbj7Ca)f3vPcA7RscKGOPKabZvy1c7zpMf8TpOuhmK5cwS5zgLQpiSIutGObgumXhPUgbBeiX1KXkedqilef1IbCTeRQMEbxNgY6ZtADjsikk(2ZGbNAeO8XcTVrLc71tCvmV4Xk(TfpsikkEXRdSIZdNTAXRreV4y8IFRdWio6MYAa6FXXVkE)AxpauIZXKM1YhWPg1e2ZEml4BFqPoyiZfSyZZKM1YhWPgPE)AxtLiHOO4zPG6dcl0QmHtIRPg2tfE4SWjUwGBKXSaRgchdbPHmatXcL1a0)nizNd4VrbRppP1LiHOO4BpdgCQrGYhl0(gw32AKquu0IXMkXwmdPcqYohWRMQjSxpXV1fkopCw4exfhUrgZcuxCSNeNJjnRLpGtns8vjbfNlwOT4wMGrC0Dvw8evoGpehJx8yfNTIhjeffV4lu8br8BfDl(8IdXaGbGs8fbr86wG4j4Q4P9IbcXxeXJeIIIVAH9ShZc(2huQdgYCbl28mPzT8bCQrQpiSuMWjX1ud7PcpCw4exlWnYywG16meogcsdzaMIfkRbO)BqYohWFJcvQePMarZcL8lWo)GGncK4AYy95jTUejeffF7zWGtncu(yH23WITvlSN9ywW3(GsDWqMlyXMNbdo1iq5JfAR(GW65jTUejeffVASU9f1HJHG0cgQa3iiqdJVsfigGqwikQL1YeoF5xmDbbMOSjquPYtrbFbyFlgcEh6OChF3AKAceTNjnRLcY2X(gbsCnzQ2AD4yiiT)Qn(Q)YIumugmLel2oCIggFLkOfhdbPXdjBYmrgZcAy8vQ88KwxIeIIIxnwQSAH96johtAwlFaNAK4XkoKqG0Zi(ToaJ4OBkRbO)fpbgXJvCc8yqsClK49eiEpHWRIVkjO4P4iyAT43k6w8beR4bdjoGuvio3QiXheX53)hCn1e2ZEml4BFqPoyiZfSyZZKM1YhWPgP(GWYq4yiinKbykwOSgG(Vbj7Ca)nSuOsL(UAZAb0(R24R(llsXqzW0GKDoG)gfqhwneogcsdzaMIfkRbO)BqYohWFtFxTzTaA)vB8v)LfPyOmyAqYohWlSN9ywW3(GsDWqMlyXgu6DTX1PHuFqyHJHG04jiYcZGmfL0a(2hzVMASuP1(cmyt04jiYcZGmfL0a(gmb1uJLc3wyp7XSGV9bL6GHmxWInptAwlFaNAKWE2JzbF7dk1bdzUGfB6muYxEMnuFqyH2iHOOOnFbF)3AFTX3c)oG4Bgcz6tOglfSIJHG0EMnkdOemuXKWAnmEReGGOU2IXMkXwyRIvdv30StvDItCoa]] )


end
