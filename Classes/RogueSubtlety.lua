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


    spec:RegisterPack( "Subtlety", 20220501, [[divSEcqiifpssv2ef6tssAusQCkjPwfjr5vQKmlsk3IKi7sk)cLsdJKWXibltLkptLsnnukUgjKTrsv(MKezCqQIZPsjyDqQsVJKQs08uP4EOK9rs6Fssu1bHuvwiKkpusvnrsOUiKsP2OkL0hLKOmsjjQCsiLIvIs1ljPQuZesP6MKuvTtvQ6NQucnujjSuiL0trLPQsQRssuTvsQk(kKQQXcPeNLKQsAVQ4VsmyQoSOfdvpwQMmLUmYMH4ZqYOrXPvSAiLsETKYSj1TPODd8BLgoQ64QuIwoONRQPlCDOSDs03PGXtsLZRsSEsQkH5lj2pXhfoxF4SzqN7Vtf3DNkuKkuODNcks9UTchU4cpD44ZETefD4aPjD44WWdnfxoC85f9M2Z1hUFXGD6WXeb)JEzlBrnbdgERVMS9htmDgZc6Wejy7pMD2E4WXgDG2ao4hoBg05(7uXD3PcfPcfA3PGIuV7UfoCjwWSWdh3yw)dhZyTe4GF4S03pCCy4HMIlIJwxuyKWU6pViUcQj(DQ4U7e2f2Rptcqrp6vyxLex9VkjXvMWjX1ud7PcpCw4exkWnYywG4y8I)R4ti(8I)uiooHSqsCdK4ypj(enHDvs86VM4dGe3ethdVMeVNADj7XSGIE(qCceWHEXJvCizX6K48BqGysT4qYWcR1e2vjXv)zns8BvtpthMiH4diiieJpeFaI3xt8meFqe3ajoAlSpe3owXNqCKfkUYvNXOPYVALeiAho98XFU(W9bL6GHSNRp3RW56dhbsCnzpO7WL9ywWH7zs7A4d4uJoCw67WHpMfC4qBqeNlOuhmSvzcMNr8esIJXRM4ypjohtAxdFaNAK4XkoobiKjehbUMIhmK485)JssC8fG9INaR436aSIJ(PSgG(xnXjLeq8brCdK4jKepdXnt1jE9RcXRddOP)fh7hakXv)5heuC03)5)dO6dxhobbN8WvN44yiiTpOuhmnmEXRurCCmeKMYemptdJx8Qf3O41j(ZtADjsikk(2ZGbNAeO8Xcnf)gXzJ4vQiUYeojUMAypv4HZcN4sbUrgZceVAXnkUz(bbl5)5)dOajZCaV4SexfN4C)DNRpCeiX1K9GUdNL(oC4JzbhUBDaZZiEgIZMReV(vH4gMGzXcXvmNAIRORe3WemIRyo1epbwXvpXnmbJ4kMt8ejiO4QpjyEMdx2JzbhUEQ1LShZck65JdxhobbN8WPmHtIRPgHGq9yusL(AIVf(DaXlUQSeVZxmt1vEEcyfVsfXXXqqApdgCQrGsSqqA3ggV4gfVVM4BHFhq8nlHm9je)gwIFN4vQi(ZtADjsikk(2ZGbNAeO8XcnfxvwIZgXnkUYeojUMAecc1Jrjv6Rj(w43beV4QYsC2iELkI3xt8TWVdi(MLqM(eIFdlXvqCvs86epsnbIMLiEcw(aMrIImBeiX1KvCJIJJHG0uMG5zAy8Ix9HtpFuaPjD4qgW8mN4C)TpxF4iqIRj7bDhUoCcco5H7dk1bdzBpX)ZlUrXFEsRlrcrrX3Egm4uJaLpwOP43ioBoCzpMfC4EM0Ug(ao1OtCUNnNRpCeiX1K9GUdx2Jzbho8Sx7Je)WzPVdh(ywWHdDzV2hjU4wm4aqjohtAxdIR4e0jXnWqaXxG4mdkgXRc1hX)i71EXtGvCoM0UgehD60sV4ZlogF7W1HtqWjpC9fyXMOXtqKfMbzlkPb8nycQjUQSeh9iUrXXXqqA8eezHzq2IsAaF7JSxtCvzjUIe3O44yiiTNjTRHInbDQbjZCaV4QYs8BlUrXXXqqAptAxdfCDAPVHXlUrXRt8NN06sKquu8TNbdo1iq5JfAk(nSe)2IxPI4kt4K4AQH9uHholCIlf4gzmlq8Qf3O41joogcs7zs7AOGRtl9nizMd4f)gwIJJHG0EM0Ugk2e0PgKmZb8IFL43jELkIJgX7RscKGOPKabZfO4vFIZ9k6C9HJajUMSh0D46Wji4KhUi1eiAGbft8rQRrWgbsCnzf3O4qmaHSquulgWLsSQB6fCDAPgbsCnzf3O4ppP1LiHOO4BpdgCQrGYhl0u8BexrhUShZcoCpZO8eN7vVZ1hocK4AYEq3Hl7XSGd3ZK21WhWPgD46x6AQejeff)5EfoCD4eeCYdhAexzcNextnSNk8WzHtCPa3iJzbIBuClHJHG0qgGTyGYAa6)gKmZb8IFJ4kiUrXFEsRlrcrrX3Egm4uJaLpwOP43Ws8BlUrXJeIIIwmMuj2IDiXvjXHKzoGxCvfx9oCw67WHpMfC4u58IhR43w8iHOO4fVoWkopC2QfVgr8IJXl(ToaR4OFkRbO)fh)I49lD9aqjohtAxdFaNAu7eN7RsNRpCeiX1K9GUdx2JzbhUNjTRHpGtn6WzPVdh(ywWH7wxO48WzHtCrC4gzmlqnXXEsCoM0Ug(ao1iXxLeuCUyHMIBycgXr)QFXtu5a(qCmEXJvC2iEKquu8IVqXheXVv0V4ZloedagakXxeeXRBbINGlINMlgieFrepsikk(QpCD4eeCYdNYeojUMAypv4HZcN4sbUrgZce3O41jULWXqqAidWwmqzna9FdsM5aEXVrCfeVsfXJutGOzGs(fyMFqWgbsCnzf3O4ppP1LiHOO4BpdgCQrGYhl0u8ByjoBeV6tCUh9CU(WrGext2d6oCD4eeCYd3ZtADjsikkEXvLL43w8ReVoXXXqqAbdvGBeeOHXlELkIdXaeYcrrTSwMW5l)IPliWeLjbIgbsCnzfVsfXFkk4la7BXqW7qpL747IBu8i1eiAptAxdfKTJ9ncK4AYkE1IBu86ehhdbP9xmXx9xwKILYGPKyX2Ht0W4fVsfXrJ44yiinEizs2jYywqdJx8kve)5jTUejeffV4QYsCfjE1hUShZcoCpdgCQrGYhl08eN7VfoxF4iqIRj7bDhUShZcoCptAxdFaNA0HZsFho8XSGdhhtAxdFaNAK4XkoKqG0Zi(ToaR4OFkRbO)fpbwXJvCc8yqsCdK49eiEpHWlIVkjO4P4iyAT43k6x8beR4bdjoGuxio3QyXheX53)hCn1oCD4eeCYdNLWXqqAidWwmqzna9FdsM5aEXVHL4kiELkI33vBxdG2FXeF1FzrkwkdMgKmZb8IFJ4kGEe3O4wchdbPHmaBXaL1a0)nizMd4f)gX77QTRbq7VyIV6VSiflLbtdsM5a(tCUxbvCU(WrGext2d6oCD4eeCYdhogcsJNGilmdYwusd4BFK9AIRklXvK4gfVVal2enEcISWmiBrjnGVbtqnXvLL4kC7dx2Jzbhou6DnX1PLoX5Efu4C9Hl7XSGd3ZK21WhWPgD4iqIRj7bDN4CVc3DU(WrGext2d6oCD4eeCYdhAepsikkAZxW3)f3O491eFl87aIVzjKPpH4QYsCfe3O44yiiTNzJYakbdvSjSwdJxCJItacI6slgtQeBHnQqCvfhv32mt1D4YEml4W1zOKV8mBCItC4SesIPJZ1N7v4C9Hl7XSGdxTPx7WrGext2d6oX5(7oxF4iqIRj7bDhUL)W9uC4YEml4WPmHtIRPdNYuJrhoCmeK2RNovsGTyNo1W4fVsfXFEsRlrcrrX3Egm4uJaLpwOP4QYsC17WzPVdh(ywWHtL)Kv8yf3sbbnhajUbgkyiO49D121a4f3qoH4iluCoGIfhpFYk(cepsikk(2HtzclG0KoCpWw6lWoXSGtCU)2NRpCeiX1K9GUd3YF4EkoCzpMfC4uMWjX10HtzQXOdhogcs71tNkjWwStNAy8IxPI4ppP1LiHOO4BpdgCQrGYhl0uCvzjU6D4uMWcinPd3dSL(cStml4eN7zZ56dhbsCnzpO7WT8hUNIdx2JzbhoLjCsCnD4uMWcinPd38faPUO05ljymZotcrr2dxhobbN8W1xLeibrR2f4KGdNL(oC4JzbhU6Zq9AIhR4prIpiIhmK4asDH41VkeVUbiEWqItkjqi(IiEkohZ1IZd3E1IpV4OpWyMDMeIIShoLPgJoC91eFl87aIxCwIRG4gfhhdbPrDMDaOkqIhoMjWwURHXlELkI3xt8TWVdiEXzj(DIBuCCmeKg1z2bGQajE4yMaB52nmEXRur8(AIVf(DaXlolXVT4gfhhdbPrDMDaOkqIhoMjWwytdJx8kveVVM4BHFhq8IZsC2iUrXXXqqAuNzhaQcK4HJzcSff1W4pX5EfDU(WrGext2d6oCl)H7P4WL9ywWHtzcNexthoLPgJoCecc1Jrjv6Rj(w43be)HZsFho8XSGdh6R3xmqioYcfNJ5AXHu2JzbIhJjjo(fXhuGfoauIRxdQu9RcXtWyMDMeIISIBMrNHEXhG4bdjUkAk6fNhsDISdaL4P48BqGysT4CmxlopC7hoLjSast6WriiupgLuPVM4BHFhq8N4CV6DU(WrGext2d6oCl)H7P4WL9ywWHtzcNexthoLPgJoC91eFl87aI)W1HtqWjpC9vjbsq0QDbojqCJItiiupgLuPVM4BHFhq8IRQ491eFl87aIxCJI3xt8TWVdi(MLqM(eIRQ43jUrXJXKkXwEMOWRX(gBe)gXvrtrIBuC0iUYeojUMAZxaK6IsNVKGXm7mjefzpCktybKM0HJqqOEmkPsFnX3c)oG4pX5(Q056dhbsCnzpO7WT8hUNIdx2JzbhoLjCsCnD4uMAm6WXdNfoXLcCJmMfiUrXFEsRlrcrrX3Egm4uJaLpwOP4QYs87oCw67WHpMfC4Ufb6lI3zsaksC4gzmlq8brCdK4mPssCE4SWjUuGBKXSaXFkepbwXnX0XWRjXJeIIIxCm(2HtzclG0KoCypv4HZcN4sbUrgZcoX5E0Z56dhbsCnzpO7WzPVdh(ywWHR(muVM41xXV4zioYa)4WL9ywWHRNADj7XSGIE(4WPNpkG0KoCD7FIZ93cNRpCeiX1K9GUdx2JzbhUxpDQKaBXoD6WzPVdh(ywWHd9XZRVioNE6K4jWkUINojEgIF3vIx)QqClgCaOepyiXrg4hIRGke)P(cSVAINibbfpyYqC2CL41VkeFqeFcXj1Xpq6f3Wemdq8GHehqQleVkR(kw8fk(8Id2qCm(dxhobbN8W98KwxIeIIIV9myWPgbkFSqtXVrC1tCJIJmOyIcKmZb8IRQ4QN4gfhhdbP96PtLeyl2PtnizMd4f)gXr1TnZuDIBu8(AIVf(DaXlUQSeNnIRsIxN4XysIFJ4kOcXRwCvM43DIZ9kOIZ1hocK4AYEq3HZsFho8XSGdhAfdiocMwFr83WeDg6fpwXdgsCUGsDWqwXrRBKXSaXRd)I42DaOe)x1eFcXrwyNEX53vpauIpiId2GzaOeFEXtL5OtCnvD7WL9ywWHdIbkzpMfu0ZhhUoCcco5H7dk1bdzBPwF40ZhfqAshUpOuhmK9eN7vqHZ1hocK4AYEq3HZsFho8XSGdxvaNfoXfXrRBKXSGQ8IJ2POQV4OgLK4P4DyYlEIVyH4eGGOUioYcfpyiX)GsDWiE9v8lED4yJ2sqX)y0AXH0Zt9q8jQUjU6Ry8Qj(eI3tG44K4btgI)JjVMAhUShZcoC9uRlzpMfu0ZhhUoCcco5HtzcNextnSNk8WzHtCPa3iJzbho98rbKM0H7dk1btPB)tCUxH7oxF4iqIRj7bDhUL)W9uC4YEml4WPmHtIRPdNYuJrhU7uK4xjEKAcenLdQf2iqIRjR4QmXVtfIFL4rQjq0mZpiyzrkptAxdFJajUMSIRYe)ovi(vIhPMar7zs7AOGSDSVrGextwXvzIFNIe)kXJutGOL6SdN4sJajUMSIRYe)ovi(vIFNIexLjEDI)8KwxIeIIIV9myWPgbkFSqtXvLL4Sr8QpCw67WHpMfC4u5pzfpwXTeYaiXnWqaXJvCSNe)dk1bJ41xXV4luCCSrBj4F4uMWcinPd3huQdMsWaPNz12tCUxHBFU(WrGext2d6oCw67WHpMfC4Q)c(XsqXX(bGs8uCUGsDWiE9vS4gyiG4qk7mdaL4bdjobiiQlIhmq6zwT9WL9ywWHRNADj7XSGIE(4W1HtqWjpCeGGOU0SeY0Nq8ByjUYeojUMAFqPoykbdKEMvBpC65JcinPd3huQdMs3(N4CVcS5C9HJajUMSh0D4S03HdFml4WDRdyEgXZqCZuDQjoBUsCdtWSyH4kMt8fkUHjyeNBvS4D4eIJJHGOM4k6kXnmbJ4kMt86wS4hlj(huQdMQvtCdtWiUI5ep1)koYaMNr8meNnxjEIkhWhIZgXJeIIIx86wS4hlj(huQdMQpCzpMfC46PwxYEmlOONpoCD4eeCYdNYeojUMAecc1Jrjv6Rj(w43beV4QYs8oFXmvx55jGv8kveVVM4BHFhq8nlHm9je)gwIRG4vQioYGIjkqYmhWl(nSexbXnkUYeojUMAecc1Jrjv6Rj(w43beV4QYs8BlELkIJJHG0(lM4R(llsXszWusSy7WjAy8IBuCLjCsCn1ieeQhJsQ0xt8TWVdiEXvLL4Sr8kve)5jTUejeffF7zWGtncu(yHMIRklXzJ4gfxzcNextncbH6XOKk91eFl87aIxCvzjoBoC65JcinPdhYaMN5eN7vqrNRpCeiX1K9GUdNL(oC4Jzbhov(tINIJJnAlbf3adbehszNzaOepyiXjabrDr8GbspZQThUShZcoC9uRlzpMfu0ZhhUoCcco5HJaee1LMLqM(eIFdlXvMWjX1u7dk1btjyG0ZSA7HtpFuaPjD4WXgT9eN7vq9oxF4iqIRj7bDhUShZcoCjSNaQelesG4WzPVdh(ywWHdTVgOpeNholCIlIpaXtTw8fr8GHeh9vfODXXPEI9K4tiEpXE6fpfVkR(k(W1HtqWjpCeGGOU0SeY0NqCvzjUcks8ReNaee1LgKqrGtCUxHQ056dx2JzbhUe2tav4X0pD4iqIRj7bDN4CVcONZ1hUShZcoC6bft8f0wywuMeioCeiX1K9GUtCUxHBHZ1hUShZcoC4jQYIuc40R9hocK4AYEq3joXHJhs91epJZ1N7v4C9Hl7XSGdxYZRVu435xWHJajUMSh0DIZ93DU(WL9ywWHdFJqt2cIoVqwddavjw1nGdhbsCnzpO7eN7V956dhbsCnzpO7W1HtqWjpC)IPXhGTXJ9bMMkeeJpMf0iqIRjR4vQi(VyA8byBkxDgJMk)QvsGOrGext2dx2Jzbhoen9mDyIeN4CpBoxF4YEml4W9bL6G5WrGext2d6oX5EfDU(WrGext2d6oCzpMfC4mtynYwqwyXszWC44HuFnXZO8uFb2)WPGIoX5E17C9HJajUMSh0D4YEml4W96PtLeyl2PthUoCcco5Hdsiq6zsCnD44HuFnXZO8uFb2)WPWjo3xLoxF4iqIRj7bDhUoCcco5HdIbiKfIIAMjSwzrkbdvmZpiyj)p)FancK4AYE4YEml4W9mPDnuW1PL(tCIdho2OTNRp3RW56dhbsCnzpO7W1HtqWjpCOr8i1eiAGbft8rQRrWgbsCnzf3O4qmaHSquulgWLsSQB6fCDAPgbsCnzf3O4ppP1LiHOO4BpdgCQrGYhl0u8BexrhUShZcoCpZO8eN7V7C9HJajUMSh0D46Wji4KhUNN06sKquu8IRklXVtCJIxN4Or8(QKajiAaQdx9cTIxPI49D121aO9eeMbzl4lGkp)uJAMP6kDMeIIEXvjX7mjef9fey2JzbPwCvzjUkA3PiXRur8NN06sKquu8TNbdo1iq5JfAkUQIZgXRwCJIxN44yiinEcISWmiBrjnGV9r2Rj(nSeNnIxPI4ppP1LiHOO4BpdgCQrGYhl0uCvfNnIBuC0iUYeojUMAypv4HZcN4sbUrgZceV6dx2JzbhUNbdo1iq5JfAEIZ93(C9HJajUMSh0D46Wji4KhoCmeKgpbrwygKTOKgW3(i71e)gwIFN4gfVoX77QTRbq7jimdYwWxavE(Pg1mt1v6mjef9IRsI3zsik6liWShZcsT43WsCv0UtrIxPI4)IPXhGTPP0wWVui1LM8AQrGextwXnkoAehhdbPPP0wWVui1LM8AQHXlELkI)lMgFa2wns5a(YUQVG0davJajUMSIBuC0iULWXqqA1iLd4lgGzW0W4fV6dx2JzbhUNGWmiBbFbu55NA0jo3ZMZ1hUShZcoCO07AIRtlD4iqIRj7bDN4CVIoxF4iqIRj7bDhUShZcoC4zV2hj(HZsFho8XSGdh6YETpsCXhttYozq6lIJb00)IhmK4asDH41VkeFEXrFGXm7mjefzfpbwXnqIBybvneVN8ItacI6I4gYjgakXrwO4t0oCD4eeCYdhAeVVkjqcIwTlWjbIxPI4Or86exzcNextT5lasDrPZxsWyMDMeIISIBu86epgtQeB5zIcVg7B3w8BexfnfjELkIhJjvIT8mrHxJ9n2i(nIRG4vlUrXjabrDr8Bex9uH4vFItC462)C95EfoxF4iqIRj7bDhUoCcco5HdnIJJHG0EM0Ugk2e0PggV4gfhhdbP9myWPgbkXcbPDBy8IBuCCmeK2ZGbNAeOeleK2TbjZCaV43Ws8B3u0Hd7PYIGuq1TN7v4WL9ywWH7zs7AOytqNoCw67WHpMfC4u5pjUItqNeFrqujuDR44eYcjXdgsCKb(H4CmyWPgbeNlwOP4iW1u8RxiiTR491KEXhq7eN7V7C9HJajUMSh0D46Wji4KhoCmeK2ZGbNAeOeleK2THXlUrXXXqqApdgCQrGsSqqA3gKmZb8IFdlXVDtrhoSNklcsbv3EUxHdx2JzbhU)Ij(Q)YIuSugmhol9D4WhZcoC1PYbA6FXtnKs7fXX4fhN6j2tIBGep2TM4CmPDni(TUDSVAXXEsCUlM4R(fFrqujuDR44eYcjXdgsCKb(H4CmyWPgbeNlwOP4iW1u8RxiiTR491KEXhq7eN7V956dhbsCnzpO7WL9ywWHdrNOiToJzbhUoCcco5HtzcNextThyl9fyNywG4gfhnI)bL6GHSnZeeAsCJIxN4ppP1LiHOO4BpdgCQrGYhl0u8ByjUcIBu8(UA7Aa0(lM4R(llsXszW0W4f3O4Or8i1eiAptAxdfKTJ9ncK4AYkELkIJJHG0(lM4R(llsXszW0W4fVAXnkEFnX3c)oG4fxvwIRiXnkEKquu0IXKkXwSdjUQIRGkoC9lDnvIeIII)CVcN4CpBoxF4iqIRj7bDhUoCcco5HRoXHyaczHOOMzcRvwKsWqfZ8dcwY)Z)hqJajUMSIBu8(AIVf(DaX3SeY0Nq8ByjUcIRsIhPMarZsepblFaZGqrMncK4AYkELkIdXaeYcrrnlLbJ(s5zs7A4BeiX1KvCJI3xt8TWVdiEXVrCfeVAXnkoogcs7VyIV6VSiflLbtdJxCJIJJHG0EM0Ugk2e0PggV4gf3m)GGL8)8)buGKzoGxCwIRcXnkoogcsZszWOVuEM0Ug(MDnaoCzpMfC4uMG5zoX5EfDU(WrGext2d6oCw67WHpMfC4QID1IJSqXVEHG0UIZdjvIBvS4gMGrCogfloKs7fXnWqaXbBioedagakX5U12HdzHfaPU4CVchUoCcco5HlsnbI2ZGbNAeOeleK2TrGextwXnkoAepsnbI2ZK21qbz7yFJajUMShUShZcoC87Qlq6xmyNoX5E17C9HJajUMSh0D4YEml4W9myWPgbkXcbPDpCw67WHpMfC4u5pj(1leK2vCEijo3QyXnWqaXnqIZKkjXdgsCcqquxe3adfmeuCe4Ako)U6bGsCdtWSyH4C3Q4luC0wyFiokcqWuRV0oCD4eeCYd3ZtADjsikk(2ZGbNAeO8Xcnf)gwIRG4gfNaee1fXvLL4QNke3O4kt4K4AQ9aBPVa7eZce3O49D121aO9xmXx9xwKILYGPHXlUrX77QTRbq7zs7AOytqNADMeIIEXvLL4kiUrXRtC0ioedqilef1wCYoeOtncK4AYkELkIBjCmeKgIorrADgZcAy8IxPI4ppP1LiHOO4BpdgCQrGYhl0uCvzjEDIRG4xjoBexLjEDIJgXJutGObgumXhPUgbBeiX1KvCJIJgXJutGOztyTYZK21qJajUMSIxT4vlE1IBu8(AIVf(DaXl(nSe)oXnkoAehhdbPXdjtYorgZcAy8IBu86ehnI3xLeibrtjbcMlqXRurC0iEFxTDnaAi6efP1zmlOHXlE1N4CFv6C9HJajUMSh0D4YEml4W9eeMbzl4lGkp)uJoCD4eeCYdNYeojUMApWw6lWoXSaXnkoAe3Ur7jimdYwWxavE(PgvSB0IPxBaOe3O4rcrrrlgtQeBXoK4QYs87uqCJIxN491eFl87aIVzjKPpH4QYs86eVZxqLdqCvRYloBeVAXRwCJIJgXXXqqApdgCQrGsSqqA3ggV4gfVoXrJ44yiinEizs2jYywqdJx8kve)5jTUejeffF7zWGtncu(yHMIRQ4Sr8QfVsfXX3)f3O4idkMOajZCaV43WsCfjUrXFEsRlrcrrX3Egm4uJaLpwOP43i(TpC9lDnvIeIII)CVcN4Cp65C9HJajUMSh0D46Wji4KhoLjCsCn1EGT0xGDIzbIBu8(AIVf(DaX3SeY0NqCvzjUcIBu8iHOOOfJjvITyhsCvzjUcQ3Hl7XSGd3t8)8N4C)TW56dhbsCnzpO7WL9ywWH7VyIV6VSiflLbZHZsFho8XSGdNk)jX5UyIV6x8fiEFxTDnaeVUejiO4id8dX5akUAXXaA6FXnqINqsCu7aqjESIZV8IF9cbPDfpbwXTR4GneNjvsIZXK21G4362X(2HRdNGGtE4uMWjX1u7b2sFb2jMfiUrXRtC0i(huQdgY2sTw8kvehhdbPXtqKfMbzlkPb8TpYEnXVrC2iELkI)8KwxIeIIIV9myWPgbkFSqtXvvC2iUrXrJ4kt4K4AQH9uHholCIlf4gzmlq8Qf3O41joAepsnbI2ZGbNAeOeleK2TrGextwXRur8i1eiAptAxdfKTJ9ncK4AYkELkI)8KwxIeIIIV9myWPgbkFSqtXvLL43jELkI33vBxdG2ZGbNAeOeleK2TbjZCaV4Qk(DIxT4gfVoXrJ49vjbsq0usGG5cu8kveVVR2UganeDII06mMf0GKzoGxCvfxbviELkI33vBxdGgIorrADgZcAy8IBu8(AIVf(DaXlUQSexrIx9jo3RGkoxF4iqIRj7bDhUShZcoCMjSgzlilSyPmyoC6bqLU9WPqtrhU(LUMkrcrrXFUxHdxhobbN8WbZXwiLeiAP1(nmEXnkEDIhjeffTymPsSf7qIFJ491eFl87aIVzjKPpH4vQioAe)dk1bdzBPwlUrX7Rj(w43beFZsitFcXvLL4D(IzQUYZtaR4vF4S03HdFml4WH2GiEATV4jKehJxnXFWWtIhmK4lGe3WemIRxd0hIF91kUjUk)jXnWqaXTxgakXrYpiO4btceV(vH4wcz6ti(cfhSH4FqPoyiR4gMGzXcXtWfXRFv0oX5Efu4C9HJajUMSh0D4YEml4WzMWAKTGSWILYG5WzPVdh(ywWHdTbrCWkEATV4ggTwC7qIBycMbiEWqIdi1fIFBv8Qjo2tIR(ruS4lqC89FXnmbZIfINGlIx)QOD46Wji4Khoyo2cPKarlT2VnaXvv8BRcXvjXH5ylKsceT0A)MfdMXSaXnkEFnX3c)oG4Bwcz6tiUQSeVZxmt1vEEcypX5EfU7C9HJajUMSh0D46Wji4KhoLjCsCn1EGT0xGDIzbIBu8(AIVf(DaX3SeY0NqCvzj(DIBu86ehhdbP9xmXx9xwKILYGPHXlELkIJV)lUrXrgumrbsM5aEXVHL43PcXRurC0ioogcs7zs7AOGRtl9nmEXnk(trbFbyFlgcEh6PChFx8QpCzpMfC4EM0Ugk460s)jo3RWTpxF4iqIRj7bDhUoCcco5HRoXrJ4rQjq0EM0UgkiBh7BeiX1Kv8kvehnI)bL6GHSTuRfVsfXFEsRlrcrrX3Egm4uJaLpwOP4QYsC2iE1IBuCLjCsCn1EGT0xGDIzbIBu8(AIVf(DaX3SeY0NqCvzj(DIBu86exzcNextnSNk8WzHtCPa3iJzbIxPI4ppP1LiHOO4BpdgCQrGYhl0u8ByjoBeVsfXHyaczHOOgK(fdyhaQsxNWjU0iqIRjR4vF4YEml4WrDMDaOkqIhoMjWEIZ9kWMZ1hocK4AYEq3Hl7XSGd3ZGbNAeOeleK29WzPVdh(ywWHd9pbJ4C3QAIpiId2q8udP0ErC7ci1eh7jXVEHG0UIBycgX5wflogF7W1HtqWjpC1jEKAceTNjTRHcY2X(gbsCnzfVsfXFEsRlrcrrX3Egm4uJaLpwOP4QYs87eVAXnkUYeojUMApWw6lWoXSaXnkoogcs7VyIV6VSiflLbtdJxCJI3xt8TWVdiEXVHL43jUrXRtC0ioogcsJhsMKDImMf0W4fVsfXFEsRlrcrrX3Egm4uJaLpwOP4QkoBeV6tCUxbfDU(WrGext2d6oCD4eeCYdhAehhdbP9mPDnuSjOtnmEXnkoYGIjkqYmhWl(nSeh9i(vIhPMar7XWdcIGHIAeiX1K9WL9ywWH7zs7AOytqNoX5EfuVZ1hocK4AYEq3HRdNGGtE4Qt8FX04dW24X(attfcIXhZcAeiX1Kv8kve)xmn(aSnLRoJrtLF1kjq0iqIRjR4vlUrXjabrDPzjKPpH4QYs8BRcXnkoAe)dk1bdzBPwlUrXXXqqA)ft8v)LfPyPmyA21a4WnGGGqm(OmihUFX04dW2uU6mgnv(vRKaXHBabbHy8rzmnj7KbD4u4WL9ywWHdrtpthMiXHBabbHy8rbLEXt9HtHtCUxHQ056dhbsCnzpO7W1HtqWjpC4yiinC9Uwn2hniL9q8kvehF)xCJIJmOyIcKmZb8IFJ43wfIxPI44yiiT)Ij(Q)YIuSugmnmEXnkEDIJJHG0EM0Ugk460sFdJx8kveVVR2UgaTNjTRHcUoT03GKzoGx8ByjUcQq8QpCzpMfC443ywWjo3Ra65C9HJajUMSh0D46Wji4KhoCmeK2FXeF1FzrkwkdMgg)Hl7XSGdhUExBbbdE5eN7v4w4C9HJajUMSh0D46Wji4KhoCmeK2FXeF1FzrkwkdMgg)Hl7XSGdhobFcwBaOoX5(7uX56dhbsCnzpO7W1HtqWjpC4yiiT)Ij(Q)YIuSugmnm(dx2JzbhoKbs46DTN4C)DkCU(WrGext2d6oCD4eeCYdhogcs7VyIV6VSiflLbtdJ)WL9ywWHlbD6dyQl9uRpX5(7U7C9HJajUMSh0D4YEml4W1ZodvwKs2VLydKSLas5JbP)W1HtqWjpC1jEFvsGeenLeiyUaf3O44yiiTSFlXgizlP6OggV4vQioAeVVkjqcIMscemxGIBuCCmeKw2VLydKSfdjW2W4fVAXnkEDI)8KwxIeIIIV9myWPgbkFSqtXzjUcIBuCyo2cPKarlT2VnaXvvC1tfIxPI447)IBuCKbftuGKzoGx8Be)ofjELkIRmHtIRPg2tfE4SWjUuGBKXSaXRw8kvehhdbPL9Bj2ajBjvh1W4f3O4ppP1LiHOO4BpdgCQrGYhl0uCvfxHdhinPdxp7muzrkz)wInqYwciLpgK(tCU)UBFU(WrGext2d6oCzpMfC4(Ec)YIuqGzqqqQlFahe6W1HtqWjpCOrCCmeK23t4xwKccmdccsD5d4Gqf20W4fVsfXX3)f3O4idkMOajZCaV43i(TvXHdKM0H77j8llsbbMbbbPU8bCqOtCU)o2CU(WrGext2d6oCzpMfC4WEQmbz(hol9D4WhZcoCkMqsmDiosQ14zVM4iluCSpX1K4tqMp6vCv(tIBycgX5UyIV6x8frCftzW0oCD4eeCYdhogcs7VyIV6VSiflLbtdJx8kvehF)xCJIJmOyIcKmZb8IFJ43PItCId3huQdMs3(NRp3RW56dhbsCnzpO7WT8hUNIdx2JzbhoLjCsCnD4uMAm6W13vBxdG2ZK21qXMGo16mjef9fey2JzbPwCvzjEDIRqRkPiXvjXvrRkPiXvzIxN49vjbsq0QDbojqCJI)uuWxa23IHG3HEk3X3f3O49D121aO9xmXx9xwKILYGPbjZCaV4QYsC0J4vlE1hol9D4WhZcoCv5inpbfx9jHtIRPdNYewaPjD4EgBjyG0ZSA7jo3F356dhbsCnzpO7WT8hUNIdx2JzbhoLjCsCnD4uMAm6W13vBxdG2ZK21qXMGo16mjef9fey2JzbPwCvzjUcTQKIeVsfX77QTRbq7VyIV6VSiflLbtdsM5aEXvLL4kOEhUoCcco5HdIbiKfIIAbdvGBeeOrGext2dNYewaPjD4EgBjyG0ZSA7jo3F7Z1hocK4AYEq3Hl7XSGdNYempZHZsFho8XSGdN6tcMNr8brCdK4jKeVN88daL4lqCfNGojENjHOOVjoA7eQViooHSqsCKb(H42e0jXheXnqIZKkjXbR43pOyIpsDnckoowiUItynX5ys7Aq8bi(cTeu8yfhffIJwX4dmijogV41bwXv)5heuC03)5)dO62HRdNGGtE4QtC0iUYeojUMApJTemq6zwTv8kvehnIhPMardmOyIpsDnc2iqIRjR4gfpsnbIMnH1kptAxdncK4AYkE1IBu8(AIVf(DaX3SeY0NqCvfxbXnkoAehIbiKfIIAMjSwzrkbdvmZpiyj)p)FancK4AYEIZ9S5C9HJajUMSh0D4S03HdFml4Wvf7QfhzHIZXK21GjPTIFL4CmPDn8bCQrIJb00)IBGepHK4j(IfIhR49Kx8fiUItqNeVZKqu03e)weOViUbgci(ToaR4OFkRbO)fFEXt8flepwXHyaXxSOD4qwybqQlo3RWHRdNGGtE4GzNAGbftuinYHJuxaZsAUyG4WXgvC4YEml4WXVRUaPFXGD6eN7v056dhbsCnzpO7W1HtqWjpCeGGOUiUQSeNnQqCJItacI6sZsitFcXvLL4kOcXnkoAexzcNextTNXwcgi9mR2kUrX7Rj(w43beFZsitFcXvvCfoCzpMfC4EM0UgmjT9eN7vVZ1hocK4AYEq3HB5pCpfhUShZcoCkt4K4A6WPm1y0HRVM4BHFhq8nlHm9jexvwIFN4xjoogcs7zs7AOGRtl9nm(dNL(oC4JzbhU6xfIhmq6zwT9fhzHItGGGdaL4CmPDniUItqNoCktybKM0H7zSL(AIVf(DaXFIZ9vPZ1hocK4AYEq3HB5pCpfhUShZcoCkt4K4A6WPm1y0HRVM4BHFhq8nlHm9jexvwIF7dxhobbN8W1xLeibrR2f4KGdNYewaPjD4EgBPVM4BHFhq8N4Cp65C9HJajUMSh0D4w(d3tXHl7XSGdNYeojUMoCktngD46Rj(w43beFZsitFcXVHL4kC46Wji4KhoLjCsCn1WEQWdNfoXLcCJmMfiUrXFEsRlrcrrX3Egm4uJaLpwOP4QYsC2C4uMWcinPd3Zyl91eFl87aI)eN7VfoxF4iqIRj7bDhUL)W9uC4YEml4WPmHtIRPdNYuJrhU(AIVf(DaX3SeY0Nq8ByjUchUoCcco5H75jTUejeffF7zWGtncu(yHMIZsC2C4uMWcinPd3Zyl91eFl87aI)eN7vqfNRpCeiX1K9GUdx2JzbhUNjTRHInbD6WzPVdh(ywWHtXjOtIBXGdaL4CxmXx9l(cfpXxLK4bdKEMvBBhUoCcco5HRoXHyaczHOOwWqf4gbbAeiX1KvCJI33vBxdG2FXeF1FzrkwkdMgKmZb8IFdlXrpIxPI4kt4K4AQ9m2sFnX3c)oG4f3O41joogcs7VyIV6VSiflLbtdsM5aEXvLL4k0Ut8kvexzcNextTNXwcgi9mR2kE1IxPI44yiiTotUFbpbudJx8kve)5jTUejeffF7zWGtncu(yHMIRklXzJ4gfVVR2UgaT)Ij(Q)YIuSugmnizMd4fxvXvqfIxT4gfVoXXXqqA8eezHzq2IsAaF7JSxt8BeNnIxPI4ppP1LiHOO4BpdgCQrGYhl0uCvf)2Ix9jo3RGcNRpCeiX1K9GUdx2JzbhUNjTRHInbD6WzPVdh(ywWHdDyqG4kobD6fVZKqu0l(Gi(LftCEDErCfNWAIZXK21WZw0No7WjUi(cfhNqwijEWqIJmOycXjG9fFqeNBvS4gwqvdXXjXHuAVi(aepgtQD46Wji4KhoLjCsCn1EgBPVM4BHFhq8IBuC89FXnkoYGIjkqYmhWl(nI33vBxdG2FXeF1FzrkwkdMgKmZb8IxPI4Or8i1eiAeqjPx(bGQ8mPDn8ncK4AYEItC4qgW8mNRp3RW56dhbsCnzpO7WT8hUNIdx2JzbhoLjCsCnD4uMAm6WfPMarJhsMKDImMf0iqIRjR4gf)5jTUejeffF7zWGtncu(yHMIFJ41jUIexLeVVkjqcIgG6WvVqR4vlUrXrJ49vjbsq0QDboj4WzPVdh(ywWHd9ZmAsCSFaOeVkGKjzNiJzbQjEQChR498JbGsCo90jXtGvCfpDsCdmeqCoM0UgexXjOtIpV4)UaXJvCCsCSNSQjoPUoXhIJSqXvFFboj4WPmHfqAshoEizs2YdSL(cStml4eN7V7C9HJajUMSh0D46Wji4Kho0iUYeojUMA8qYKSLhyl9fyNywG4gf)5jTUejeffF7zWGtncu(yHMIFJ4QN4gfhnIJJHG0EM0Ugk2e0PggV4gfhhdbP96PtLeyl2PtnizMd4f)gXrgumrbsM5aEXnkoKqG0ZK4A6WL9ywWH71tNkjWwStNoX5(BFU(WrGext2d6oCD4eeCYdNYeojUMA8qYKSLhyl9fyNywG4gfVVR2UgaTNjTRHInbDQ1zsik6liWShZcsT43iUcTQKIe3O44yiiTxpDQKaBXoDQbjZCaV43iEFxTDnaA)ft8v)LfPyPmyAqYmhWlUrXRt8(UA7Aa0EM0Ugk2e0PgKs7fXnkoogcs7VyIV6VSiflLbtdsM5aEXvjXXXqqAptAxdfBc6udsM5aEXVrCfA3jE1hUShZcoCVE6ujb2ID60jo3ZMZ1hocK4AYEq3HB5pCpfhUShZcoCkt4K4A6WPm1y0HZm)GGL8)8)buGKzoGxCvfxfIxPI4Or8i1eiAGbft8rQRrWgbsCnzf3O4rQjq0SjSw5zs7AOrGextwXnkoogcs7zs7AOytqNAy8IxPI4ppP1LiHOO4BpdgCQrGYhl0uCvzjEDIZgXvjX)GsDWq2wQ1IRYepsnbI2ZK21qbz7yFJajUMSIx9HZsFho8XSGdxvosZtqXvFs4K4AsCKfkoAfJpWGutCUAdV4wm4aqjU6p)GGIJ((p)FaIVqXTyWbGsCfNGojUHjyexXjSM4jWkoyf)(bft8rQRrW2HtzclG0KoCFTHVaX4dmiDIZ9k6C9HJajUMSh0D4YEml4WbX4dmiD4S03HdFml4WP(MiEXX4fhTIXhyqs8br8jeFEXt8flepwXHyaXxSOD46Wji4Kho0i(huQdgY2sTwCJIxN4OrCLjCsCn1(AdFbIXhyqs8kvexzcNextnSNk8WzHtCPa3iJzbIxT4gfpsikkAXysLyl2HexLehsM5aEXvvC1tCJIdjei9mjUMoX5E17C9Hl7XSGd3tDifLG6mG5wIrhocK4AYEq3jo3xLoxF4iqIRj7bDhUShZcoCqm(adshU(LUMkrcrrXFUxHdxhobbN8WHgXvMWjX1u7Rn8figFGbjXnkoAexzcNextnSNk8WzHtCPa3iJzbIBu8NN06sKquu8TNbdo1iq5JfAkUQSe)oXnkEKquu0IXKkXwSdjUQSeVoXvK4xjEDIFN4QmX7Rj(w43beV4vlE1IBuCiHaPNjX10HZsFho8XSGdN6hthJDJyaOepsikkEXdMme3WO1IRhLK4ilu8GHe3IbZywG4lI4Ovm(adsQjoKqG0ZiUfdoauIZNalzo92jo3JEoxF4iqIRj7bDhUShZcoCqm(adshol9D4WhZcoCOvcbspJ4Ovm(adsItjuFr8br8je3WO1ItQJFGK4wm4aqjo3ft8v)nXv8kEWKH4qcbspJ4dI4CRIfhffV4qkTxeFaIhmK4asDH4k6BhUoCcco5HdnIRmHtIRP2xB4lqm(adsIBuCizMd4f)gX77QTRbq7VyIV6VSiflLbtdsM5aEXVsCfuH4gfVVR2UgaT)Ij(Q)YIuSugmnizMd4f)gwIRiXnkEKquu0IXKkXwSdjUkjoKmZb8IRQ49D121aO9xmXx9xwKILYGPbjZCaV4xjUIoX5(BHZ1hocK4AYEq3HRdNGGtE4qJ4kt4K4AQH9uHholCIlf4gzmlqCJI)8KwxIeIIIxCvzj(TpCzpMfC4W1zVwHFnyj4jo3RGkoxF4YEml4WrkNVtWmOdhbsCnzpO7eN4ehoLe8NfCU)ovC3DQGnkOOdNHecgaQ)WH(rFO17rBUVkd9kU4xZqIpM8lmehzHIx1pOuhmKTQIdPBj2ajR4)AsINyXAMbzfVZKau03e2r7dGexrOxXR)cusWGSIxvigGqwikQHwQQ4XkEvHyaczHOOgAPrGext2QkEDkOUQBc7O9bqIJEqVIx)fOKGbzfVQqmaHSquudTuvXJv8QcXaeYcrrn0sJajUMSvv86uqDv3e2f2r)Op069On3xLHEfx8RziXht(fgIJSqXRkpK6RjEgvvCiDlXgizf)xts8elwZmiR4DMeGI(MWoAFaK43g9kE9xGscgKv8Q(lMgFa2gAPQIhR4v9xmn(aSn0sJajUMSvv86uqDv3e2r7dGe)2OxXR)cusWGSIx1FX04dW2qlvv8yfVQ)IPXhGTHwAeiX1KTQINH4OTVfr7IxNcQR6MWoAFaK4vj0R41FbkjyqwXRkedqilef1qlvv8yfVQqmaHSquudT0iqIRjBvfpdXrBFlI2fVofux1nHDHD0p6dTEpAZ9vzOxXf)Ags8XKFHH4ilu8Q2TFvfhs3sSbswX)1KepXI1mdYkENjbOOVjSJ2hajoBqVIx)fOKGbzfVQqmaHSquudTuvXJv8QcXaeYcrrn0sJajUMSvv86UtDv3e2r7dGex9qVIx)fOKGbzfVQqmaHSquudTuvXJv8QcXaeYcrrn0sJajUMSvv86uqDv3e2r7dGexHBJEfV(lqjbdYkEvHyaczHOOgAPQIhR4vfIbiKfIIAOLgbsCnzRQ41PG6QUjSJ2hajUcQh6v86VaLemiR4v9xmn(aSn0svfpwXR6VyA8byBOLgbsCnzRQ41DN6QUjSlSJ(rFO17rBUVkd9kU4xZqIpM8lmehzHIx1pOuhmLU9RQ4q6wInqYk(VMK4jwSMzqwX7mjaf9nHD0(aiXVd9kE9xGscgKv8QcXaeYcrrn0svfpwXRkedqilef1qlncK4AYwvXZqC023IODXRtb1vDtyhTpas8BJEfV(lqjbdYkEvHyaczHOOgAPQIhR4vfIbiKfIIAOLgbsCnzRQ4zioA7Br0U41PG6QUjSJ2hajUcQa9kE9xGscgKv8QcXaeYcrrn0svfpwXRkedqilef1qlncK4AYwvXRtb1vDtyxyh9J(qR3J2CFvg6vCXVMHeFm5xyioYcfVQ4yJ2wvXH0TeBGKv8FnjXtSynZGSI3zsak6Bc7O9bqIRa6v86VaLemiR4vfIbiKfIIAOLQkESIxvigGqwikQHwAeiX1KTQIxNcQR6MWoAFaK4kc9kE9xGscgKv8QgJjvIT8mrdT041yFvfpwXRAmMuj2YZefEn23qlvv86UtDv3e2f2rBm5xyqwXRsIN9ywG465JVjSF4EEQFU)o1tHdhpCrgnD4Qx9eNddp0uCrC06IcJe2Rx9ex9Nxexb1e)ovC3Dc7c71REIxFMeGIE0RWE9QN4QK4Q)vjjUYeojUMAypv4HZcN4sbUrgZcehJx8FfFcXNx8NcXXjKfsIBGeh7jXNOjSxV6jUkjE9xt8bqIBIPJHxtI3tTUK9ywqrpFiobc4qV4XkoKSyDsC(niqmPwCizyH1Ac71REIRsIR(ZAK43QMEMomrcXhqqqigFi(aeVVM4zi(GiUbsC0wyFiUDSIpH4iluCLRoJrtLF1kjq0e2f2Rx9eVkGKkv)1epdH9ShZc(gpK6RjEgxXITjpV(sHFNFbc7zpMf8nEi1xt8mUIfBX3i0KTGOZlK1WaqvIvDdqyp7XSGVXdP(AINXvSylIMEMomrc1gew)IPXhGTXJ9bMMkeeJpMfuPYVyA8byBkxDgJMk)QvsGqyp7XSGVXdP(AINXvSy7huQdgH9ShZc(gpK6RjEgxXITMjSgzlilSyPmyuJhs91epJYt9fyFwkOiH9ShZc(gpK6RjEgxXITVE6ujb2ID6KA8qQVM4zuEQVa7Zsb1gewqcbsptIRjH9ShZc(gpK6RjEgxXITptAxdfCDAPxTbHfedqilef1mtyTYIucgQyMFqWs(F()ae2f2Rx9ex9NdqC06gzmlqyp7XSGNvTPxtyVEIRYFYkESIBPGGMdGe3adfmeu8(UA7Aa8IBiNqCKfkohqXIJNpzfFbIhjeffFtyp7XSG)kwSvzcNextQbstI1dSL(cStmlqnLPgJyHJHG0E90PscSf70PggFLkppP1LiHOO4BpdgCQrGYhl0uvwQNWE2Jzb)vSyRYeojUMudKMeRhyl9fyNywGAktngXchdbP96PtLeyl2Ptnm(kvEEsRlrcrrX3Egm4uJaLpwOPQSupH96jE9zOEnXJv8NiXheXdgsCaPUq86xfIx3aepyiXjLeieFrepfNJ5AX5HBVAXNxC0hymZotcrrwH9ShZc(RyXwLjCsCnPginjwZxaK6IsNVKGXm7mjefzvBqy1xLeibrR2f4Ka1uMAmIvFnX3c)oG4zPGrCmeKg1z2bGQajE4yMaB5UggFLk91eFl87aIN1DgXXqqAuNzhaQcK4HJzcSLB3W4RuPVM4BHFhq8SUTrCmeKg1z2bGQajE4yMaBHnnm(kv6Rj(w43bepl2yehdbPrDMDaOkqIhoMjWwuudJxyVEIJ(69fdeIJSqX5yUwCiL9ywG4XysIJFr8bfyHdaL461Gkv)Qq8emMzNjHOiR4Mz0zOx8biEWqIRIMIEX5HuNi7aqjEko)geiMulohZ1IZd3UWE2Jzb)vSyRYeojUMudKMelcbH6XOKk91eFl87aIxnLPgJyriiupgLuPVM4BHFhq8c7zpMf8xXITkt4K4AsnqAsSieeQhJsQ0xt8TWVdiE1gew9vjbsq0QDbojWiHGq9yusL(AIVf(DaXRAFnX3c)oG4n2xt8TWVdi(MLqM(eQENXymPsSLNjk8ASVXMBurtrgrJYeojUMAZxaK6IsNVKGXm7mjefzvtzQXiw91eFl87aIxyVEIFlc0xeVZKauK4WnYywG4dI4giXzsLK48WzHtCPa3iJzbI)uiEcSIBIPJHxtIhjeffV4y8nH9ShZc(RyXwLjCsCnPginjwypv4HZcN4sbUrgZcutzQXiw8WzHtCPa3iJzbgFEsRlrcrrX3Egm4uJaLpwOPQSUtyVEIxFgQxt86R4x8mehzGFiSN9ywWFfl22tTUK9ywqrpFOginjwD7lSxpXrF886lIZPNojEcSIR4PtINH43DL41Vke3IbhakXdgsCKb(H4kOcXFQVa7RM4jsqqXdMmeNnxjE9RcXheXNqCsD8dKEXnmbZaepyiXbK6cXRYQVIfFHIpV4GnehJxyp7XSG)kwS91tNkjWwStNuBqy98KwxIeIIIV9myWPgbkFSqZBupJidkMOajZCaVQQNrCmeK2RNovsGTyNo1GKzoG)guDBZmvNX(AIVf(DaXRkl2Os1fJjDJcQOAv2Dc71tC0kgqCemT(I4VHj6m0lESIhmK4CbL6GHSIJw3iJzbIxh(fXT7aqj(VQj(eIJSWo9IZVREaOeFqehSbZaqj(8INkZrN4AQ6MWE2Jzb)vSyleduYEmlOONpudKMeRpOuhmKvTbH1huQdgY2sTwyVEIxfWzHtCrC06gzmlOkV4ODkQ6loQrjjEkEhM8IN4lwiobiiQlIJSqXdgs8pOuhmIxFf)Ixho2OTeu8pgTwCi98upeFIQBIR(kgVAIpH49eioojEWKH4)yYRPMWE2Jzb)vSyBp16s2Jzbf98HAG0Ky9bL6GP0TVAdclLjCsCn1WEQWdNfoXLcCJmMfiSxpXv5pzfpwXTeYaiXnWqaXJvCSNe)dk1bJ41xXV4luCCSrBj4lSN9ywWFfl2QmHtIRj1aPjX6dk1btjyG0ZSARAktngX6ofDvKAcenLdQf2iqIRjRk7ovCvKAcenZ8dcwwKYZK21W3iqIRjRk7ovCvKAceTNjTRHcY2X(gbsCnzvz3PORIutGOL6SdN4sJajUMSQS7uXv3PivwDppP1LiHOO4BpdgCQrGYhl0uvwSPAH96jE9xWpwcko2pauINIZfuQdgXRVIf3adbehszNzaOepyiXjabrDr8GbspZQTc7zpMf8xXIT9uRlzpMfu0ZhQbstI1huQdMs3(QniSiabrDPzjKPpXnSuMWjX1u7dk1btjyG0ZSARWE9e)whW8mINH4MP6utC2CL4gMGzXcXvmN4luCdtWio3QyX7WjehhdbrnXv0vIBycgXvmN41TyXpws8pOuhmvR(sXnmbJ4kMt8u)R4idyEgXZqC2CL4jQCaFioBepsikkEXRBXIFSK4FqPoyQwyp7XSG)kwSTNADj7XSGIE(qnqAsSqgW8mQniSuMWjX1uJqqOEmkPsFnX3c)oG4vLvNVyMQR88eWwPsFnX3c)oG4Bwcz6tCdlfQubzqXefizMd4VHLcgvMWjX1uJqqOEmkPsFnX3c)oG4vL1TRubhdbP9xmXx9xwKILYGPKyX2Ht0W4nQmHtIRPgHGq9yusL(AIVf(DaXRkl2uPYZtADjsikk(2ZGbNAeO8XcnvLfBmQmHtIRPgHGq9yusL(AIVf(DaXRkl2iSxpXv5pjEkoo2OTeuCdmeqCiLDMbGs8GHeNaee1fXdgi9mR2kSN9ywWFfl22tTUK9ywqrpFOginjw4yJ2Q2GWIaee1LMLqM(e3WszcNextTpOuhmLGbspZQTc71tC0(AG(qCE4SWjUi(aep1AXxeXdgsC0xvG2fhN6j2tIpH49e7Px8u8QS6RyH9ShZc(RyX2e2tavIfcjqO2GWIaee1LMLqM(eQYsbfDfbiiQlniHIac7zpMf8xXITjSNaQWJPFsyp7XSG)kwSvpOyIVG2cZIYKaHWE2Jzb)vSylEIQSiLao9AVWUWE9QN4OdB0wc(c7zpMf8nCSrBz9mJs1gewOjsnbIgyqXeFK6AeSrGextwJqmaHSquulgWLsSQB6fCDAjJppP1LiHOO4BpdgCQrGYhl08gfjSN9ywW3WXgT9kwS9zWGtncu(yHMQniSEEsRlrcrrXRkR7mwhA6RscKGObOoC1l0wPsFxTDnaApbHzq2c(cOYZp1OMzQUsNjHOOxL6mjef9fey2JzbPwvwQODNIQu55jTUejeffF7zWGtncu(yHMQYMQnwhogcsJNGilmdYwusd4BFK9A3WInvQ88KwxIeIIIV9myWPgbkFSqtvzJr0OmHtIRPg2tfE4SWjUuGBKXSGQf2ZEml4B4yJ2Efl2(eeMbzl4lGkp)uJuBqyHJHG04jiYcZGSfL0a(2hzV2nSUZyD9D121aO9eeMbzl4lGkp)uJAMP6kDMeIIEvQZKqu0xqGzpMfK6ByPI2DkQsLFX04dW20uAl4xkK6stEn1iqIRjRr0GJHG00uAl4xkK6stEn1W4Ru5xmn(aSTAKYb8LDvFbPhaQgbsCnznIglHJHG0QrkhWxmaZGPHXxTWE2JzbFdhB02RyXwu6DnX1PLe2RN4Ol71(iXfFmnj7KbPViogqt)lEWqIdi1fIx)Qq85fh9bgZSZKquKv8eyf3ajUHfu1q8EYlobiiQlIBiNyaOehzHIprtyp7XSGVHJnA7vSylE2R9rIR2GWcn9vjbsq0QDbojOsf0uNYeojUMAZxaK6IsNVKGXm7mjefznwxmMuj2YZeTB341y)nQOPOkvIXKkXwEMOXMgVg7VrHQnsacI6YnQNkQwyxyVEIx)D121a4f2RN4Q8NexXjOtIViiQeQUvCCczHK4bdjoYa)qCogm4uJaIZfl0uCe4Ak(1leK2v8(AsV4dOjSN9ywW362N1ZK21qXMGoPg2tLfbPGQBzPGAdcl0GJHG0EM0Ugk2e0PggVrCmeK2ZGbNAeOeleK2THXBehdbP9myWPgbkXcbPDBqYmhWFdRB3uKWE9eVovoqt)lEQHuAViogV44upXEsCdK4XU1eNJjTRbXV1TJ9vlo2tIZDXeF1V4lcIkHQBfhNqwijEWqIJmWpeNJbdo1iG4CXcnfhbUMIF9cbPDfVVM0l(aAc7zpMf8TU9VIfB)lM4R(llsXszWOg2tLfbPGQBzPGAdclCmeK2ZGbNAeOeleK2THXBehdbP9myWPgbkXcbPDBqYmhWFdRB3uKWE2JzbFRB)RyXweDII06mMfOw)sxtLiHOO4zPGAdclLjCsCn1EGT0xGDIzbgrZhuQdgY2mtqOjJ198KwxIeIIIV9myWPgbkFSqZByPGX(UA7Aa0(lM4R(llsXszW0W4nIMi1eiAptAxdfKTJ9ncK4AYwPcogcs7VyIV6VSiflLbtdJVAJ91eFl87aIxvwkYyKquu0IXKkXwSdPQcQqyp7XSGV1T)vSyRYempJAdcR6GyaczHOOMzcRvwKsWqfZ8dcwY)Z)hGX(AIVf(DaX3SeY0N4gwkOsrQjq0SeXtWYhWmiuKzJajUMSvQaXaeYcrrnlLbJ(s5zs7A4n2xt8TWVdi(BuOAJ4yiiT)Ij(Q)YIuSugmnmEJ4yiiTNjTRHInbDQHXB0m)GGL8)8)buGKzoGNLkmIJHG0Sugm6lLNjTRHVzxdaH96jEvSRwCKfk(1leK2vCEiPsCRIf3WemIZXOyXHuAViUbgcioydXHyaWaqjo3T2e2ZEml4BD7Ffl2YVRUaPFXGDsnKfwaK6cwkO2GWksnbI2ZGbNAeOeleK2TrGextwJOjsnbI2ZK21qbz7yFJajUMSc71tCv(tIF9cbPDfNhsIZTkwCdmeqCdK4mPss8GHeNaee1fXnWqbdbfhbUMIZVREaOe3Wemlwio3Tk(cfhTf2hIJIaem16lnH9ShZc(w3(xXITpdgCQrGsSqqAx1gewppP1LiHOO4BpdgCQrGYhl08gwkyKaee1fvzPEQWOYeojUMApWw6lWoXSaJ9D121aO9xmXx9xwKILYGPHXBSVR2UgaTNjTRHInbDQ1zsik6vLLcgRdnqmaHSquuBXj7qGovPILWXqqAi6efP1zmlOHXxPYZtADjsikk(2ZGbNAeO8XcnvLvDkCfBuz1HMi1eiAGbft8rQRrWgbsCnznIMi1eiA2ewR8mPDn0iqIRjB1vxTX(AIVf(DaXFdR7mIgCmeKgpKmj7ezmlOHXBSo00xLeibrtjbcMlWkvqtFxTDnaAi6efP1zmlOHXxTWE2JzbFRB)RyX2NGWmiBbFbu55NAKA9lDnvIeIIINLcQniSuMWjX1u7b2sFb2jMfyen2nApbHzq2c(cOYZp1OIDJwm9AdaLXiHOOOfJjvITyhsvw3PGX66Rj(w43beFZsitFcvzvxNVGkhGQv5zt1vBen4yiiTNbdo1iqjwiiTBdJ3yDObhdbPXdjtYorgZcAy8vQ88KwxIeIIIV9myWPgbkFSqtvzt1vQGV)BezqXefizMd4VHLIm(8KwxIeIIIV9myWPgbkFSqZBUTWE2JzbFRB)RyX2N4)5vBqyPmHtIRP2dSL(cStmlWyFnX3c)oG4Bwcz6tOklfmgjeffTymPsSf7qQYsb1tyVEIRYFsCUlM4R(fFbI33vBxdaXRlrcckoYa)qCoGIRwCmGM(xCdK4jKeh1oauIhR48lV4xVqqAxXtGvC7koydXzsLK4CmPDni(TUDSVjSN9ywW362)kwS9VyIV6VSiflLbJAdclLjCsCn1EGT0xGDIzbgRdnFqPoyiBl16kvWXqqA8eezHzq2IsAaF7JSx7g2uPYZtADjsikk(2ZGbNAeO8XcnvLngrJYeojUMAypv4HZcN4sbUrgZcQ2yDOjsnbI2ZGbNAeOeleK2TrGext2kvIutGO9mPDnuq2o23iqIRjBLkppP1LiHOO4BpdgCQrGYhl0uvw3vPsFxTDnaApdgCQrGsSqqA3gKmZb8QEx1gRdn9vjbsq0usGG5cSsL(UA7Aa0q0jksRZywqdsM5aEvvqfvQ03vBxdGgIorrADgZcAy8g7Rj(w43beVQSuu1c71tC0geXtR9fpHK4y8Qj(dgEs8GHeFbK4gMGrC9AG(q8RVwXnXv5pjUbgciU9Yaqjos(bbfpysG41Vke3sitFcXxO4Gne)dk1bdzf3WemlwiEcUiE9RIMWE2JzbFRB)RyXwZewJSfKfwSugmQPhav6wwk0uKA9lDnvIeIIINLcQniSG5ylKsceT0A)ggVX6IeIIIwmMuj2IDOB6Rj(w43beFZsitFIkvqZhuQdgY2sT2yFnX3c)oG4Bwcz6tOkRoFXmvx55jGTAH96joAdI4Gv80AFXnmAT42He3Wemdq8GHehqQle)2Q4vtCSNex9JOyXxG447)IBycMflepbxeV(vrtyp7XSGV1T)vSyRzcRr2cYclwkdg1gewWCSfsjbIwATFBaQEBvOsWCSfsjbIwATFZIbZywGX(AIVf(DaX3SeY0NqvwD(IzQUYZtaRWE2JzbFRB)RyX2NjTRHcUoT0R2GWszcNextThyl9fyNywGX(AIVf(DaX3SeY0Nqvw3zSoCmeK2FXeF1FzrkwkdMggFLk47)grgumrbsM5a(ByDNkQubn4yiiTNjTRHcUoT03W4n(uuWxa23IHG3HEk3X3Rwyp7XSGV1T)vSyl1z2bGQajE4yMaRAdcR6qtKAceTNjTRHcY2X(gbsCnzRubnFqPoyiBl16kvEEsRlrcrrX3Egm4uJaLpwOPQSyt1gvMWjX1u7b2sFb2jMfySVM4BHFhq8nlHm9juL1DgRtzcNextnSNk8WzHtCPa3iJzbvQ88KwxIeIIIV9myWPgbkFSqZByXMkvGyaczHOOgK(fdyhaQsxNWjUuTWE9eh9pbJ4C3QAIpiId2q8udP0ErC7ci1eh7jXVEHG0UIBycgX5wflogFtyp7XSGV1T)vSy7ZGbNAeOeleK2vTbHvDrQjq0EM0UgkiBh7BeiX1KTsLNN06sKquu8TNbdo1iq5JfAQkR7Q2OYeojUMApWw6lWoXSaJ4yiiT)Ij(Q)YIuSugmnmEJ91eFl87aI)gw3zSo0GJHG04HKjzNiJzbnm(kvEEsRlrcrrX3Egm4uJaLpwOPQSPAH9ShZc(w3(xXITptAxdfBc6KAdcl0GJHG0EM0Ugk2e0PggVrKbftuGKzoG)gwONRIutGO9y4bbrWqrncK4AYkSN9ywW362)kwSfrtpthMiHAdcR6(ftJpaBJh7dmnviigFmlOsLFX04dW2uU6mgnv(vRKar1gjabrDPzjKPpHQSUTkmIMpOuhmKTLATrCmeK2FXeF1FzrkwkdMMDnauBabbHy8rzmnj7KbXsb1gqqqigFuqPx8uZsb1gqqqigFugew)IPXhGTPC1zmAQ8RwjbcH9ShZc(w3(xXIT8BmlqTbHfogcsdxVRvJ9rdszpQubF)3iYGIjkqYmhWFZTvrLk4yiiT)Ij(Q)YIuSugmnmEJ1HJHG0EM0Ugk460sFdJVsL(UA7Aa0EM0Ugk460sFdsM5a(ByPGkQwyp7XSGV1T)vSylUExBbbdErTbHfogcs7VyIV6VSiflLbtdJxyp7XSGV1T)vSylobFcwBaOuBqyHJHG0(lM4R(llsXszW0W4f2ZEml4BD7Ffl2ImqcxVRvTbHfogcs7VyIV6VSiflLbtdJxyp7XSGV1T)vSyBc60hWux6PwR2GWchdbP9xmXx9xwKILYGPHXlSN9ywW362)kwSf7PYeKPAG0Ky1ZodvwKs2VLydKSLas5JbPxTbHvD9vjbsq0usGG5c0iogcsl73sSbs2sQoQHXxPcA6RscKGOPKabZfOrCmeKw2VLydKSfdjW2W4R2yDppP1LiHOO4BpdgCQrGYhl0KLcgH5ylKsceT0A)2auv9urLk47)grgumrbsM5a(BUtrvQOmHtIRPg2tfE4SWjUuGBKXSGQRubhdbPL9Bj2ajBjvh1W4n(8KwxIeIIIV9myWPgbkFSqtvvqyp7XSGV1T)vSyl2tLjit1aPjX67j8llsbbMbbbPU8bCqi1gewObhdbP99e(LfPGaZGGGux(aoiuHnnm(kvW3)nImOyIcKmZb83CBviSxpXvmHKy6qCKuRXZEnXrwO4yFIRjXNGmF0R4Q8Ne3WemIZDXeF1V4lI4kMYGPjSN9ywW362)kwSf7PYeK5R2GWchdbP9xmXx9xwKILYGPHXxPc((VrKbftuGKzoG)M7uHWUWE9QN436aMNHGVWE9eh9ZmAsCSFaOeVkGKjzNiJzbQjEQChR498JbGsCo90jXtGvCfpDsCdmeqCoM0UgexXjOtIpV4)UaXJvCCsCSNSQjoPUoXhIJSqXvFFbojqyp7XSGVHmG5zyPmHtIRj1aPjXIhsMKT8aBPVa7eZcutzQXiwrQjq04HKjzNiJzbncK4AYA85jTUejeffF7zWGtncu(yHM3uNIuP(QKajiAaQdx9cTvBen9vjbsq0QDbojqyp7XSGVHmG5zUIfBF90PscSf70j1gewOrzcNextnEizs2YdSL(cStmlW4ZtADjsikk(2ZGbNAeO8XcnVr9mIgCmeK2ZK21qXMGo1W4nIJHG0E90PscSf70PgKmZb83GmOyIcKmZb8gHecKEMextc7zpMf8nKbmpZvSy7RNovsGTyNoP2GWszcNextnEizs2YdSL(cStmlWyFxTDnaAptAxdfBc6uRZKqu0xqGzpMfK6BuOvLuKrCmeK2RNovsGTyNo1GKzoG)M(UA7Aa0(lM4R(llsXszW0GKzoG3yD9D121aO9mPDnuSjOtniL2lgXXqqA)ft8v)LfPyPmyAqYmhWRs4yiiTNjTRHInbDQbjZCa)nk0URAH96jEvosZtqXvFs4K4AsCKfkoAfJpWGutCUAdV4wm4aqjU6p)GGIJ((p)FaIVqXTyWbGsCfNGojUHjyexXjSM4jWkoyf)(bft8rQRrWMWE2JzbFdzaZZCfl2QmHtIRj1aPjX6Rn8figFGbj1uMAmILz(bbl5)5)dOajZCaVQQOsf0ePMardmOyIpsDnc2iqIRjRXi1eiA2ewR8mPDn0iqIRjRrCmeK2ZK21qXMGo1W4Ru55jTUejeffF7zWGtncu(yHMQYQo2OsFqPoyiBl1AvwKAceTNjTRHcY2X(gbsCnzRwyVEIR(MiEXX4fhTIXhyqs8br8jeFEXt8flepwXHyaXxSOjSN9ywW3qgW8mxXITqm(adsQniSqZhuQdgY2sT2yDOrzcNextTV2WxGy8bgKQurzcNextnSNk8WzHtCPa3iJzbvBmsikkAXysLyl2HujizMd4vv9mcjei9mjUMe2ZEml4BidyEMRyX2N6qkkb1zaZTeJe2RN4QFmDm2nIbGs8iHOO4fpyYqCdJwlUEusIJSqXdgsClgmJzbIViIJwX4dmiPM4qcbspJ4wm4aqjoFcSK50Bc7zpMf8nKbmpZvSyleJpWGKA9lDnvIeIIINLcQniSqJYeojUMAFTHVaX4dmizenkt4K4AQH9uHholCIlf4gzmlW4ZtADjsikk(2ZGbNAeO8XcnvL1DgJeIIIwmMuj2IDivzvNIUQU7uz91eFl87aIV6Qncjei9mjUMe2RN4OvcbspJ4Ovm(adsItjuFr8br8je3WO1ItQJFGK4wm4aqjo3ft8v)nXv8kEWKH4qcbspJ4dI4CRIfhffV4qkTxeFaIhmK4asDH4k6Bc7zpMf8nKbmpZvSyleJpWGKAdcl0OmHtIRP2xB4lqm(adsgHKzoG)M(UA7Aa0(lM4R(llsXszW0GKzoG)kfuHX(UA7Aa0(lM4R(llsXszW0GKzoG)gwkYyKquu0IXKkXwSdPsqYmhWRAFxTDnaA)ft8v)LfPyPmyAqYmhWFLIe2ZEml4BidyEMRyXwCD2Rv4xdwcQ2GWcnkt4K4AQH9uHholCIlf4gzmlW4ZtADjsikkEvzDBH9ShZc(gYaMN5kwSLuoFNGzqc7c71REIZfuQdgXR)UA7Aa8c71t8QCKMNGIR(KWjX1KWE2JzbF7dk1btPBFwkt4K4AsnqAsSEgBjyG0ZSARAktngXQVR2UgaTNjTRHInbDQ1zsik6liWShZcsTQSQtHwvsrQKkAvjfPYQRVkjqcIwTlWjbgFkk4la7BXqW7qpL747g77QTRbq7VyIV6VSiflLbtdsM5aEvzHEQUAH9ShZc(2huQdMs3(xXITkt4K4AsnqAsSEgBjyG0ZSARAdcligGqwikQfmubUrqa1uMAmIvFxTDnaAptAxdfBc6uRZKqu0xqGzpMfKAvzPqRkPOkv67QTRbq7VyIV6VSiflLbtdsM5aEvzPG6jSxpXvFsW8mIpiIBGepHK49KNFaOeFbIR4e0jX7mjef9nXrBNq9fXXjKfsIJmWpe3MGoj(GiUbsCMujjoyf)(bft8rQRrqXXXcXvCcRjohtAxdIpaXxOLGIhR4OOqC0kgFGbjXX4fVoWkU6p)GGIJ((p)Fav3e2ZEml4BFqPoykD7Ffl2QmbZZO2GWQo0OmHtIRP2ZylbdKEMvBRubnrQjq0adkM4JuxJGncK4AYAmsnbIMnH1kptAxdncK4AYwTX(AIVf(DaX3SeY0NqvfmIgigGqwikQzMWALfPemuXm)GGL8)8)biSxpXRID1IJSqX5ys7AWK0wXVsCoM0Ug(ao1iXXaA6FXnqINqs8eFXcXJv8EYl(cexXjOtI3zsik6BIFlc0xe3adbe)whGvC0pL1a0)IpV4j(IfIhR4qmG4lw0e2ZEml4BFqPoykD7Ffl2YVRUaPFXGDsnKfwaK6cwkOgPUaML0CXabl2Oc1gewWStnWGIjkKgryp7XSGV9bL6GP0T)vSy7ZK21GjPTQniSiabrDrvwSrfgjabrDPzjKPpHQSuqfgrJYeojUMApJTemq6zwT1yFnX3c)oG4Bwcz6tOQcc71t86xfIhmq6zwT9fhzHItGGGdaL4CmPDniUItqNe2ZEml4BFqPoykD7Ffl2QmHtIRj1aPjX6zSL(AIVf(DaXRMYuJrS6Rj(w43beFZsitFcvzD3v4yiiTNjTRHcUoT03W4f2ZEml4BFqPoykD7Ffl2QmHtIRj1aPjX6zSL(AIVf(DaXRMYuJrS6Rj(w43beFZsitFcvzDB1gew9vjbsq0QDbojqyp7XSGV9bL6GP0T)vSyRYeojUMudKMeRNXw6Rj(w43beVAktngXQVM4BHFhq8nlHm9jUHLcQniSuMWjX1ud7PcpCw4exkWnYywGXNN06sKquu8TNbdo1iq5JfAQkl2iSN9ywW3(GsDWu62)kwSvzcNextQbstI1Zyl91eFl87aIxnLPgJy1xt8TWVdi(MLqM(e3Wsb1gewppP1LiHOO4BpdgCQrGYhl0KfBe2RN4kobDsClgCaOeN7Ij(QFXxO4j(QKepyG0ZSABtyp7XSGV9bL6GP0T)vSy7ZK21qXMGoP2GWQoigGqwikQfmubUrqaJ9D121aO9xmXx9xwKILYGPbjZCa)nSqpvQOmHtIRP2Zyl91eFl87aI3yD4yiiT)Ij(Q)YIuSugmnizMd4vLLcT7QurzcNextTNXwcgi9mR2wDLk4yiiTotUFbpbudJVsLNN06sKquu8TNbdo1iq5JfAQkl2ySVR2UgaT)Ij(Q)YIuSugmnizMd4vvbvuTX6WXqqA8eezHzq2IsAaF7JSx7g2uPYZtADjsikk(2ZGbNAeO8Xcnv92vlSxpXrhgeiUItqNEX7mjef9IpiIFzXeNxNxexXjSM4CmPDn8Sf9PZoCIlIVqXXjKfsIhmK4idkMqCcyFXheX5wflUHfu1qCCsCiL2lIpaXJXKAc7zpMf8TpOuhmLU9VIfBFM0Ugk2e0j1gewkt4K4AQ9m2sFnX3c)oG4nIV)BezqXefizMd4VPVR2UgaT)Ij(Q)YIuSugmnizMd4RubnrQjq0iGssV8dav5zs7A4BeiX1KvyxyVE1tCUGsDWqwXrRBKXSaH96joAdI4CbL6GHTktW8mINqsCmE1eh7jX5ys7A4d4uJepwXXjaHmH4iW1u8GHeNp)FusIJVaSx8eyf)whGvC0pL1a0)QjoPKaIpiIBGepHK4ziUzQoXRFviEDyan9V4y)aqjU6p)GGIJ((p)FavlSN9ywW3(GsDWqwwptAxdFaNAKAdcR6WXqqAFqPoyAy8vQGJHG0uMG5zAy8vBSUNN06sKquu8TNbdo1iq5JfAEdBQurzcNextnSNk8WzHtCPa3iJzbvB0m)GGL8)8)buGKzoGNLke2RN436aMNr8me)2xjE9RcXnmbZIfIRyoXzR4S5kXnmbJ4kMtCdtWiohdgCQraXVEHG0UIJJHGiogV4XkEQChR4)AsIx)QqCd5hK4)eyzml4Bc71tC0N(xX)eHepwXrgW8mINH4S5kXRFviUHjyeNux2d9fXzJ4rcrrX3eVoU0KepFXxS4hlj(huQdMw1c71t8BDaZZiEgIZMReV(vH4gMGzXcXvmNAIRORe3WemIRyo1epbwXvpXnmbJ4kMt8ejiO4QpjyEgH9ShZc(2huQdgYEfl22tTUK9ywqrpFOginjwidyEg1gewkt4K4AQriiupgLuPVM4BHFhq8QYQZxmt1vEEcyRubhdbP9myWPgbkXcbPDBy8g7Rj(w43beFZsitFIByDxLkppP1LiHOO4BpdgCQrGYhl0uvwSXOYeojUMAecc1Jrjv6Rj(w43beVQSytLk91eFl87aIVzjKPpXnSuqLQlsnbIMLiEcw(aMrIImBeiX1K1iogcstzcMNPHXxTWE2JzbF7dk1bdzVIfBFM0Ug(ao1i1gewFqPoyiB7j(FEJppP1LiHOO4BpdgCQrGYhl08g2iSxpXrx2R9rIlUfdoauIZXK21G4kobDsCdmeq8fioZGIr8Qq9r8pYETx8eyfNJjTRbXrNoT0l(8IJX3e2ZEml4BFqPoyi7vSylE2R9rIR2GWQVal2enEcISWmiBrjnGVbtqnvzHEmIJHG04jiYcZGSfL0a(2hzVMQSuKrCmeK2ZK21qXMGo1GKzoGxvw32iogcs7zs7AOGRtl9nmEJ198KwxIeIIIV9myWPgbkFSqZByD7kvuMWjX1ud7PcpCw4exkWnYywq1gRdhdbP9mPDnuW1PL(gKmZb83WchdbP9mPDnuSjOtnizMd4V6UkvqtFvsGeenLeiyUaRwyp7XSGV9bL6GHSxXITpZOuTbHvKAcenWGIj(i11iyJajUMSgHyaczHOOwmGlLyv30l460sgFEsRlrcrrX3Egm4uJaLpwO5nksyVEIRY5fpwXVT4rcrrXlEDGvCE4SvlEnI4fhJx8BDawXr)uwdq)lo(fX7x66bGsCoM0Ug(ao1OMWE2JzbF7dk1bdzVIfBFM0Ug(ao1i16x6AQejeffplfuBqyHgLjCsCn1WEQWdNfoXLcCJmMfy0s4yiinKbylgOSgG(VbjZCa)nky85jTUejeffF7zWGtncu(yHM3W62gJeIIIwmMuj2IDivcsM5aEvvpH96j(TUqX5HZcN4I4WnYywGAIJ9K4CmPDn8bCQrIVkjO4CXcnf3WemIJ(v)INOYb8H4y8IhR4Sr8iHOO4fFHIpiIFROFXNxCigamauIViiIx3cepbxepnxmqi(IiEKquu8vlSN9ywW3(GsDWq2RyX2NjTRHpGtnsTbHLYeojUMAypv4HZcN4sbUrgZcmwNLWXqqAidWwmqzna9FdsM5a(BuOsLi1eiAgOKFbM5heSrGextwJppP1LiHOO4BpdgCQrGYhl08gwSPAH9ShZc(2huQdgYEfl2(myWPgbkFSqt1gewppP1LiHOO4vL1TVQoCmeKwWqf4gbbAy8vQaXaeYcrrTSwMW5l)IPliWeLjbIkvEkk4la7BXqW7qpL747gJutGO9mPDnuq2o23iqIRjB1gRdhdbP9xmXx9xwKILYGPKyX2Ht0W4Rubn4yiinEizs2jYywqdJVsLNN06sKquu8QYsrvlSxpX5ys7A4d4uJepwXHecKEgXV1byfh9tzna9V4jWkESItGhdsIBGeVNaX7jeEr8vjbfpfhbtRf)wr)IpGyfpyiXbK6cX5wfl(Gio)()GRPMWE2JzbF7dk1bdzVIfBFM0Ug(ao1i1gewwchdbPHmaBXaL1a0)nizMd4VHLcvQ03vBxdG2FXeF1FzrkwkdMgKmZb83Oa6XOLWXqqAidWwmqzna9FdsM5a(B67QTRbq7VyIV6VSiflLbtdsM5aEH9ShZc(2huQdgYEfl2IsVRjUoTKAdclCmeKgpbrwygKTOKgW3(i71uLLIm2xGfBIgpbrwygKTOKgW3GjOMQSu42c7zpMf8TpOuhmK9kwS9zs7A4d4uJe2ZEml4BFqPoyi7vSyBNHs(YZSHAdcl0ejeffT5l47)g7Rj(w43beFZsitFcvzPGrCmeK2ZSrzaLGHk2ewRHXBKaee1LwmMuj2cBuHQO62MzQUtCIZba]] )


end
