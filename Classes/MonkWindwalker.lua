-- MonkWindwalker.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local GetNamePlates = C_NamePlate.GetNamePlates
local LRC = LibStub( "LibRangeCheck-2.0" )
local pow = math.pow

local PTR = ns.PTR


-- Conduits
-- [-] calculated_strikes
-- [-] coordinated_offensive (aura)
-- [-] inner_fury
-- [x] xuens_bond


if UnitClassBase( 'player' ) == 'MONK' then
    local spec = Hekili:NewSpecialization( 269 )

    spec:RegisterResource( Enum.PowerType.Energy, {
        crackling_jade_lightning = {
            aura = 'crackling_jade_lightning',
            debuff = true,

            last = function ()
                local app = state.debuff.crackling_jade_lightning.applied
                local t = state.query_time

                return app + floor( ( t - app ) / state.haste ) * state.haste
            end,

            stop = function( x )
                return x < class.abilities.crackling_jade_lightning.spendPerSec
            end,

            interval = function () return state.haste end,
            value = function () return class.abilities.crackling_jade_lightning.spendPerSec end,
        },

        energizing_elixir = {
            aura = "energizing_elixir",

            last = function ()
                local app = state.buff.energizing_elixir.applied
                local t = state.query_time

                return app + floor( ( t - app ) / 1.5 ) * 1.5
            end,

            interval = 1.5,
            value = 15
        }
    } )

    spec:RegisterResource( Enum.PowerType.Chi )

    spec:RegisterResource( Enum.PowerType.Mana )


    -- Talents
    spec:RegisterTalents( {
        eye_of_the_tiger = 23106, -- 196607
        chi_wave = 19820, -- 115098
        chi_burst = 20185, -- 123986

        celerity = 19304, -- 115173
        chi_torpedo = 19818, -- 115008
        tigers_lust = 19302, -- 116841

        ascension = 22098, -- 115396
        fist_of_the_white_tiger = 19771, -- 261947
        energizing_elixir = 22096, -- 115288

        tiger_tail_sweep = 19993, -- 264348
        good_karma = 23364, -- 280195
        ring_of_peace = 19995, -- 116844

        inner_strength = 23258, -- 261767
        diffuse_magic = 20173, -- 122783
        dampen_harm = 20175, -- 122278

        hit_combo = 22093, -- 196740
        rushing_jade_wind = 23122, -- 116847
        dance_of_chiji = 22102, -- 325201

        spiritual_focus = 22107, -- 280197
        whirling_dragon_punch = 22105, -- 152175
        serenity = 21191, -- 152173
    } )

    -- PvP Talents
    spec:RegisterPvpTalents( {
        alpha_tiger = 3734, -- 287503
        disabling_reach = 3050, -- 201769
        grapple_weapon = 3052, -- 233759
        perpetual_paralysis = 5448, -- 357495
        pressure_points = 3744, -- 345829
        reverse_harm = 852, -- 342928
        ride_the_wind = 77, -- 201372
        tigereye_brew = 675, -- 247483
        turbo_fists = 3745, -- 287681
        wind_waker = 3737, -- 357633
    } )

    -- Auras
    spec:RegisterAuras( {
        bok_proc = {
            id = 116768,
            type = "Magic",
            max_stack = 1,
        },
        chi_torpedo = {
            id = 119085,
            duration = 10,
            max_stack = 2,
        },
        crackling_jade_lightning = {
            id = 117952,
            duration = 4,
            max_stack = 1,
        },
        dance_of_chiji = {
            id = 325202,
            duration = 15,
            max_stack = 1,
        },
        dampen_harm = {
            id = 122278,
            duration = 10,
            max_stack = 1,
        },
        diffuse_magic = {
            id = 122783,
            duration = 6,
            max_stack = 1,
        },
        disable = {
            id = 116095,
            duration = 15,
            max_stack = 1,
        },
        disable_root = {
            id = 116706,
            duration = 8,
            max_stack = 1,
        },
        energizing_elixir = {
            id = 115288,
            duration = 5,
            max_stack = 1,
        },
        exit_strategy = {
            id = 289324,
            duration = 2,
            max_stack = 1
        },
        eye_of_the_tiger = {
            id = 196608,
            duration = 8
        },
        fists_of_fury = {
            id = 113656,
            duration = function () return 4 * haste end,
            max_stack = 1,
        },
        flying_serpent_kick = {
            name = "Flying Serpent Kick",
            duration = 2,
            generate = function ()
                local cast = rawget( class.abilities.flying_serpent_kick, "lastCast" ) or 0
                local up = cast + 2 > query_time

                local fsk = buff.flying_serpent_kick
                fsk.name = "Flying Serpent Kick"

                if up then
                    fsk.count = 1
                    fsk.expires = cast + 2
                    fsk.applied = cast
                    fsk.caster = "player"
                    return
                end
                fsk.count = 0
                fsk.expires = 0
                fsk.applied = 0
                fsk.caster = "nobody"
            end,
        },
        hit_combo = {
            id = 196741,
            duration = 10,
            max_stack = 6,
        },
        inner_strength = {
            id = 261769,
            duration = 5,
            max_stack = 5,
        },
        leg_sweep = {
            id = 119381,
            duration = 3,
            max_stack = 1,
        },
        mark_of_the_crane = {
            id = 228287,
            duration = 15,
            max_stack = 1,
        },
        mortal_wounds = {
            id = 115804,
            duration = 10,
            max_stack = 1,
        },
        mystic_touch = {
            id = 113746,
            duration = 3600,
            max_stack = 1,
        },
        paralysis = {
            id = 115078,
            duration = 60,
            max_stack = 1,
        },
        provoke = {
            id = 115546,
            duration = 8,
        },
        ring_of_peace = {
            id = 116844,
            duration = 5
        },
        rising_sun_kick = {
            id = 107428,
            duration = 10,
        },
        rushing_jade_wind = {
            id = 116847,
            duration = function () return 6 * haste end,
            max_stack = 1,
            dot = "buff",
        },
        serenity = {
            id = 152173,
            duration = 12,
            max_stack = 1,
        },
        spinning_crane_kick = {
            id = 101546,
            duration = function () return 1.5 * haste end,
            max_stack = 1,
        },
        storm_earth_and_fire = {
            id = 137639,
            duration = 15,
            max_stack = 1,
        },
        tigers_lust = {
            id = 116841,
            duration = 6,
            max_stack = 1,
        },
        touch_of_death = {
            id = 115080,
            duration = 8
        },
        touch_of_karma = {
            id = 125174,
            duration = 10,
        },
        touch_of_karma_debuff = {
            id = 122470,
            duration = 10,
        },
        transcendence = {
            id = 101643,
            duration = 900,
        },
        transcendence_transfer = {
            id = 119996,
        },
        whirling_dragon_punch = {
            id = 196742,
            duration = function () return action.rising_sun_kick.cooldown end,
            max_stack = 1,
        },
        windwalking = {
            id = 166646,
            duration = 3600,
            max_stack = 1,
        },
        zen_flight = {
            id = 125883,
            duration = 3600,
            max_stack = 1,
        },
        zen_pilgrimage = {
            id = 126892,
        },

        -- PvP Talents
        alpha_tiger = {
            id = 287504,
            duration = 8,
            max_stack = 1,
        },

        fortifying_brew = {
            id = 201318,
            duration = 15,
            max_stack = 1,
        },

        grapple_weapon = {
            id = 233759,
            duration = 6,
            max_stack = 1,
        },

        heavyhanded_strikes = {
            id = 201787,
            duration = 2,
            max_stack = 1,
        },

        ride_the_wind = {
            id = 201447,
            duration = 3600,
            max_stack = 1,
        },

        tigereye_brew_stack = {
            id = 248646,
            duration = 120,
            max_stack = 20,
        },

        tigereye_brew = {
            id = 247483,
            duration = 20,
            max_stack = 1
        },

        wind_waker = {
            id = 290500,
            duration = 4,
            max_stack = 1,
        },


        -- Azerite Powers
        dance_of_chiji_azerite = {
            id = 286587,
            duration = 15,
            max_stack = 1
        },

        fury_of_xuen = {
            id = 287062,
            duration = 20,
            max_stack = 67,
        },

        fury_of_xuen_haste = {
            id = 287063,
            duration = 8,
            max_stack = 1,
        },

        recently_challenged = {
            id = 290512,
            duration = 30,
            max_stack = 1
        },

        sunrise_technique = {
            id = 273298,
            duration = 15,
            max_stack = 1
        },


        -- Legendaries
        invokers_delight = {
            id = 338321,
            duration = 15,
            max_stack = 1
        },

        pressure_point = {
            id = 337482,
            duration = 5,
            max_stack = 1,
            generate = function( t, auraType )
                local lastCast, castTime = action.fists_of_fury.lastCast, action.fists_of_fury.cast

                if query_time - lastCast < castTime + 5 then
                    t.count = 1
                    t.expires = lastCast + castTime + 5
                    t.applied = lastCast + castTime
                    t.caster = "player"

                    return
                end

                t.count = 0
                t.expires = 0
                t.applied = 0
                t.caster = "nobody"
            end,
        },

        -- Jade Ignition
        chi_energy = {
            id = 337571,
            duration = 45,
            max_stack = 30
        },

        the_emperors_capacitor = {
            id = 337291,
            duration = 3600,
            max_stack = 20,
        },
    } )


    -- Tier 28
    spec:RegisterSetBonuses( "tier28_2pc", 364418, "tier28_4pc", 363734 )
    -- 2-Set - Fists of Primordium - Increases Fists of Fury damage by 40%.
    -- 4-Set - Primordial Potential - After 10 offensive abilities, your next 3 offensive abilities deal an additional 22% damage.
    spec:RegisterAuras( {
        primordial_potential = {
            id = 363911,
            duration = 10,
            max_stack = 10
        },
        primordial_power = {
            id = 363924,
            duration = 10,
            max_stack = 3
        }
    } )

    spec:RegisterGear( 'tier19', 138325, 138328, 138331, 138334, 138337, 138367 )
    spec:RegisterGear( 'tier20', 147154, 147156, 147152, 147151, 147153, 147155 )
    spec:RegisterGear( 'tier21', 152145, 152147, 152143, 152142, 152144, 152146 )
    spec:RegisterGear( 'class', 139731, 139732, 139733, 139734, 139735, 139736, 139737, 139738 )

    spec:RegisterGear( 'cenedril_reflector_of_hatred', 137019 )
    spec:RegisterGear( 'cinidaria_the_symbiote', 133976 )
    spec:RegisterGear( 'drinking_horn_cover', 137097 )
    spec:RegisterGear( 'firestone_walkers', 137027 )
    spec:RegisterGear( 'fundamental_observation', 137063 )
    spec:RegisterGear( 'gai_plins_soothing_sash', 137079 )
    spec:RegisterGear( 'hidden_masters_forbidden_touch', 137057 )
    spec:RegisterGear( 'jewel_of_the_lost_abbey', 137044 )
    spec:RegisterGear( 'katsuos_eclipse', 137029 )
    spec:RegisterGear( 'march_of_the_legion', 137220 )
    spec:RegisterGear( 'prydaz_xavarics_magnum_opus', 132444 )
    spec:RegisterGear( 'salsalabims_lost_tunic', 137016 )
    spec:RegisterGear( 'sephuzs_secret', 132452 )
    spec:RegisterGear( 'the_emperors_capacitor', 144239 )

    spec:RegisterGear( 'soul_of_the_grandmaster', 151643 )
    spec:RegisterGear( 'stormstouts_last_gasp', 151788 )
    spec:RegisterGear( 'the_wind_blows', 151811 )


    spec:RegisterStateTable( "combos", {
        blackout_kick = true,
        chi_burst = true,
        chi_wave = true,
        crackling_jade_lightning = true,
        expel_harm = true,
        faeline_stomp = true,
        fist_of_the_white_tiger = true,
        fists_of_fury = true,
        flying_serpent_kick = true,
        rising_sun_kick = true,
        spinning_crane_kick = true,
        tiger_palm = true,
        touch_of_death = true,
        whirling_dragon_punch = true
    } )

    local prev_combo, actual_combo, virtual_combo

    spec:RegisterStateExpr( "last_combo", function () return virtual_combo or actual_combo end )

    spec:RegisterStateExpr( "combo_break", function ()
        return this_action == virtual_combo and combos[ virtual_combo ]
    end )

    spec:RegisterStateExpr( "combo_strike", function ()
        return not combos[ this_action ] or this_action ~= virtual_combo
    end )


    local application_events = {
        SPELL_AURA_APPLIED      = true,
        SPELL_AURA_APPLIED_DOSE = true,
        SPELL_AURA_REFRESH      = true,
    }

    local removal_events = {
        SPELL_AURA_REMOVED      = true,
        SPELL_AURA_BROKEN       = true,
        SPELL_AURA_BROKEN_SPELL = true,
    }

    local death_events = {
        UNIT_DIED               = true,
        UNIT_DESTROYED          = true,
        UNIT_DISSIPATES         = true,
        PARTY_KILL              = true,
        SPELL_INSTAKILL         = true,
    }

    local bonedust_brew_applied = {}
    local bonedust_brew_expires = {}

    -- If a Tiger Palm missed, pretend we never cast it.
    -- Use RegisterEvent since we're looking outside the state table.
    spec:RegisterCombatLogEvent( function( _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )
        if sourceGUID == state.GUID then
            local ability = class.abilities[ spellID ] and class.abilities[ spellID ].key
            if not ability then return end

            if ability == "tiger_palm" and subtype == "SPELL_MISSED" and not state.talent.hit_combo.enabled then
                if ns.castsAll[1] == "tiger_palm" then ns.castsAll[1] = "none" end
                if ns.castsAll[2] == "tiger_palm" then ns.castsAll[2] = "none" end
                if ns.castsOn[1] == "tiger_palm" then ns.castsOn[1] = "none" end
                actual_combo = "none"

                Hekili:ForceUpdate( "WW_MISSED" )

            elseif subtype == "SPELL_CAST_SUCCESS" and state.combos[ ability ] then
                prev_combo = actual_combo
                actual_combo = ability

            elseif subtype == "SPELL_DAMAGE" and spellID == 148187 then
                -- track the last tick.
                state.buff.rushing_jade_wind.last_tick = GetTime()

            -- Track Bonedust Brew applications.
            elseif spellID == 325216 then
                if application_events[ subtype ] then
                    bonedust_brew_applied[ destGUID ] = GetTime()
                    bonedust_brew_expires[ destGUID ] = nil
                elseif removal_events[ subtype ] then
                    bonedust_brew_expires[ destGUID ] = nil
                    bonedust_brew_expires[ destGUID ] = nil
                end
            end
        elseif death_events[ subtype ] then
            bonedust_brew_applied[ destGUID ] = nil
            bonedust_brew_expires[ destGUID ] = nil
        end
    end )


    local tier28_offensive_abilities = {
        blackout_kick = 1,
        breath_of_fire = 1,
        chi_burst = 1,
        chi_wave = 1,
        crackling_jade_lightning = 1,
        faeline_stomp = 1,
        fist_of_the_white_tiger = 1,
        fists_of_fury = 1,
        flying_serpent_kick = 1,
        keg_smash = 1,
        rising_sun_kick = 1,
        rushing_jade_wind = 1,
        spinning_crane_kick = 1,
        tiger_palm = 1,
        whirling_dragon_punch = 1,
    }

    local chiSpent = 0

    spec:RegisterHook( "spend", function( amt, resource )
        if resource == "chi" and amt > 0 then
            if talent.spiritual_focus.enabled then
                chiSpent = chiSpent + amt
                cooldown.storm_earth_and_fire.expires = max( 0, cooldown.storm_earth_and_fire.expires - floor( chiSpent / 2 ) )
                chiSpent = chiSpent % 2
            end

            if legendary.last_emperors_capacitor.enabled then
                addStack( "the_emperors_capacitor", nil, 1 )
            end
        end
    end )


    local noop = function () end

    local reverse_harm_target



    -- New Bonedust Brew Stuff
    local checker = LRC:GetHarmMaxChecker( 8 )

    local valid_brews = {}

    local function ValidateBonedustBrews()
        local now = state.now
        checker = checker or LRC:GetHarmMaxChecker( 8 )
        table.wipe( valid_brews )

        for _, plate in ipairs( GetNamePlates() ) do
            local unit = plate.namePlateUnitToken

            if unit and UnitCanAttack( "player", unit ) and ( UnitIsPVP( "player" ) or not UnitIsPlayer( unit ) ) and checker( unit ) then
                local guid = UnitGUID( unit )

                valid_brews[ guid ] = 0

                if bonedust_brew_applied[ guid ] then
                    if not bonedust_brew_expires[ guid ] then
                        -- We haven't scraped the aura for the duration yet.
                        local found, _, _, _, _, expires = AuraUtil.FindAuraByName( class.auras.bonedust_brew_debuff.name, unit, "HARMFUL|PLAYER" )

                        if found then
                            bonedust_brew_expires[ guid ] = expires
                            valid_brews[ guid ] = expires
                        end
                    else
                        if bonedust_brew_expires[ guid ] > now then
                            valid_brews[ guid ] = bonedust_brew_expires[ guid ]
                        end
                    end
                end
            end
        end
    end

    local GatherBonedustInfo = setfenv( function()
        local targets, bonedusts, aggregate, longest = 0, 0, 0, 0

        for _, expires in pairs( valid_brews ) do
            targets = targets + 1
            local remains = max( 0, expires - query_time )

            if remains > 0 then
                bonedusts = bonedusts + 1
                aggregate = aggregate + remains
                longest = max( longest, remains )
            end
        end

        return targets, bonedusts, aggregate, longest
    end, state )

    local bdbActions = {}

    local SetAction = setfenv( function( name, damage, execution_time, net_chi, net_energy, mastery, p, capped )
        local a = bdbActions[ name ] or {}

        capped = capped or false

        a.damage = damage
        a.execution_time = execution_time
        a.net_chi = net_chi
        a.net_energy = ( capped and net_energy ) or ( net_energy + energy.regen * execution_time )
        a.idps = damage / execution_time
        a.cps = net_chi / execution_time
        a.eps = a.net_energy / execution_time
        a.rdps = a.idps + 0.5 * mastery * a.cps + 0.02 * mastery * ( 1 + p ) * a.eps

        bdbActions[ name ] = a

        return a
    end, state )


    local lastBonedustZoneTime = 0
    local lastBonedustZoneValue = 0

    -- Returns cap_energy, tp_fill, bok, break_mastery.
    local GetBonedustZoneInfo = setfenv( function()
        if query_time == lastBonedustZoneTime then
            return lastBonedustZoneValue
        end

        local targets, bonedusts, aggregate = GatherBonedustInfo()
        lastBonedustZoneTime = query_time

        if targets < 2 or bonedusts < 1 then
            -- Orange
            lastBonedustZoneValue = 0
            return 0
        end

        if aggregate > 0 then
            local length = 60
            local blp = 0.2
            local bb_rate = 1.5 + blp

            -- Bone Marrow Hops
            if conduit.bone_marrow_hops.rank > 0 then
                length = length - 2.5 - ( 2.5 * bb_rate )
            end

            -- Brewmaster Keg Smash
            if spec.brewmaster then
                length = length - ( 60 / length * 8 ) -- 2 Keg Smashes for a hard Cast
                length = length - bb_rate * 4         -- 1 Keg Smash per bountiful minimum (safe)
            end

            -- Decyphered Urh
            if buff.decyphered_urh_cypher.up then
                length = length - ( buff.decyphered_urh_cypher.remains * 2 )
            end
        end

        -- Math below is credit to Tostad0ra, ported to Lua/WoW by Jeremals (https://wago.io/2rN0fBudK).
        -- https://colab.research.google.com/drive/1IlNnwzigBG_xa0VdXhiofvuy-mgJAhGa?usp=sharing

        local mastery = 1 + stat.mastery_value
        local haste = 1 + stat.haste

        -- Locally defined variables that may change.

        local eps = 0.2 -- Delay when chaining SCKs
        local tiger_palm_AP = 0.27 * 1.546776
        local sck_AP = 0.4 * 2.232

        local coordinated_offensive_bonus = 1

        if conduit.coordinated_offensive.rank > 0 then
            coordinated_offensive_bonus = 1 + 0.085 + ( 0.009 * ( conduit.coordinated_offensive.rank - 1 ) )
        end

        local calculated_strikes_bonus = 0.16
        if conduit.calculated_strikes.rank > 0 then
            calculated_strikes_bonus = 0.16 + 0.1 + ( 0.01 * ( conduit.calculated_strikes.rank - 1 ) )
        end

        local bone_marrow_hops_bonus = 0
        if conduit.bone_marrow_hops.rank > 0 then
            bone_marrow_hops_bonus = 0.4 + ( 0.04 * ( conduit.bone_marrow_hops.rank - 1 ) )
        end

        -- sqrt scaling
        local N_effective_targets_above = 5 * pow( ( targets / 5 ), 0.5 )
        local N_effective_targets_below = targets
        local N_effective_targets = min( N_effective_targets_below, N_effective_targets_above )


        local mark_stacks = spinning_crane_kick.count
        local mark_bonus_per_target = 0.18 + calculated_strikes_bonus
        local mark_bonus = mark_bonus_per_target * mark_stacks
        local mark_multiplier = 1 + mark_bonus

        local p = tiger_palm_AP / ( ( N_effective_targets * sck_AP * mark_multiplier ) - ( 1.1 / 1.676 * 0.81 / 2.5 * 1.5 ) )

        local amp = 1 + stat.versatility_atk_mod

        if buff.invoke_xuen.up then
            amp = amp * 1.1
        end

        if buff.storm_earth_and_fire.up then
            amp = amp * 1.35 * ( 2 * coordinated_offensive_bonus + 1 ) / 3
        end

        amp = amp * ( 1 + ( 0.5 * 0.4 * ( bonedusts / targets ) * ( 1 + bone_marrow_hops_bonus ) ) )

        local TP_SCK = SetAction( "TP_SCK", amp * mastery * ( 1 + p ), 2, 1, -50, mastery, p )
        local rSCK_cap = SetAction( "rSCK_cap", amp, 1.5 / haste + eps, -1, 0, mastery, p, true )
        local rSCK_unc = SetAction( "rSCK_unc", amp, 1.5 / haste + eps, -1, 0, mastery, p )

        if rSCK_unc.rdps > TP_SCK.rdps then
            local regen = 2 * energy.regen
            local N_oc_expr = ( 1 - 2 * regen ) / ( 1.5 + haste * eps ) / ( regen / haste )
            local w_oc_expr = 1 / ( 1 + N_oc_expr )
            local rdps_nocap = w_oc_expr * TP_SCK.rdps + ( 1 - w_oc_expr ) * rSCK_unc.rdps

            -- Purple
            if rSCK_cap.rdps > rdps_nocap then
                lastBonedustZoneValue = 4
                return 4
            end

            -- Red
            lastBonedustZoneValue = 3
            return 3
        end

        -- Blue
        if rSCK_unc.idps < TP_SCK.idps then
            lastBonedustZoneValue = 1
            return 1
        end

        -- Green
        lastBonedustZoneValue = 2
        return 2
    end, state )



    spec:RegisterHook( "runHandler", function( key, noStart )
        if combos[ key ] then
            if last_combo == key then removeBuff( "hit_combo" )
            else
                if talent.hit_combo.enabled then addStack( "hit_combo", 10, 1 ) end
                if azerite.fury_of_xuen.enabled then addStack( "fury_of_xuen", nil, 1 ) end
                if conduit.xuens_bond.enabled and cooldown.invoke_xuen.remains > 0 then reduceCooldown( "invoke_xuen", 0.1 ) end
            end
            virtual_combo = key
        end

        if set_bonus.tier28_4pc > 0 and tier28_offensive_abilities[ key ] then
            if buff.primordial_power.up then
                removeStack( "primordial_power" )
            else
                addStack( "primordial_potential", nil, 1 )
                if buff.primordial_potential.stack > 9 then
                    removeBuff( "primordial_potential" )
                    applyBuff( "primordial_power", nil, 3 )
                end
            end
        end

        lastBonedustZoneTime = 0
    end )

    spec:RegisterStateExpr( "cap_energy", function()
        return GetBonedustZoneInfo() == 4
    end )

    spec:RegisterStateExpr( "tp_fill", function()
        return GetBonedustZoneInfo() < 3
    end )

    spec:RegisterStateExpr( "no_bok", function()
        return GetBonedustZoneInfo() > 0
    end )

    spec:RegisterStateExpr( "break_mastery", function()
        return GetBonedustZoneInfo() > 1
    end )


    spec:RegisterHook( "reset_precast", function ()
        chiSpent = 0

        if actual_combo == "tiger_palm" and chi.current < 2 and now - action.tiger_palm.lastCast > 0.2 then
            actual_combo = "none"
        end

        if buff.rushing_jade_wind.up then setCooldown( "rushing_jade_wind", 0 ) end

        if buff.casting.up and buff.casting.v1 == action.spinning_crane_kick.id then
            removeBuff( "casting" )
            -- Spinning Crane Kick buff should be up.
        end

        spinning_crane_kick.count = nil

        virtual_combo = actual_combo or "no_action"
        reverse_harm_target = nil

        if not IsUsableSpell( 322109 ) then setCooldown( "touch_of_death", action.touch_of_death.cooldown ) end

        if buff.weapons_of_order_ww.up then
            state:QueueAuraExpiration( "weapons_of_order_ww", noop, buff.weapons_of_order_ww.expires )
        end

        -- BDB Logic.
        if covenant.necrolord then
            ValidateBonedustBrews()
            lastBonedustZoneTime = 0
        end
    end )

    spec:RegisterHook( "advance", function()
        lastBonedustZoneTime = 0
    end )


    spec:RegisterHook( "IsUsable", function( spell )
        -- Allow repeats to happen if your chi has decayed to 0.
        if talent.hit_combo.enabled and buff.hit_combo.up and ( spell ~= "tiger_palm" or chi.current > 0 ) and last_combo == spell then
            return false, "would break hit_combo"
        end
    end )


    spec:RegisterStateTable( "spinning_crane_kick", setmetatable( { onReset = function( self ) self.count = nil end },
        { __index = function( t, k )
                if k == 'count' then
                    t[ k ] = max( GetSpellCount( action.spinning_crane_kick.id ), active_dot.mark_of_the_crane )
                    return t[ k ]
                end
        end } ) )

    spec:RegisterStateExpr( "alpha_tiger_ready", function ()
        if not pvptalent.alpha_tiger.enabled then
            return false
        elseif debuff.recently_challenged.down then
            return true
        elseif cycle then return
            active_dot.recently_challenged < active_enemies
        end
        return false
    end )

    spec:RegisterStateExpr( "alpha_tiger_ready_in", function ()
        if not pvptalent.alpha_tiger.enabled then return 3600 end
        if active_dot.recently_challenged < active_enemies then return 0 end
        return debuff.recently_challenged.remains
    end )

    spec:RegisterStateFunction( "weapons_of_order", function( c )
        if c and c > 0 then
            return buff.weapons_of_order_ww.up and ( c - 1 ) or c
        end
        return c
    end )


    spec:RegisterPet( "xuen_the_white_tiger", 63508, "invoke_xuen", 24 )


    -- Abilities
    spec:RegisterAbilities( {
        blackout_kick = {
            id = 100784,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function ()
                if buff.serenity.up or buff.bok_proc.up then return 0 end
                return weapons_of_order( 1 )
            end,
            spendType = "chi",

            startsCombat = true,
            texture = 574575,

            cycle = 'mark_of_the_crane',

            handler = function ()
                if buff.bok_proc.up and buff.serenity.down then
                    removeBuff( "bok_proc" )
                    if set_bonus.tier21_4pc > 0 then gain( 1, "chi" ) end
                end

                cooldown.rising_sun_kick.expires = max( 0, cooldown.rising_sun_kick.expires - ( buff.weapons_of_order.up and 2 or 1 ) )
                cooldown.fists_of_fury.expires = max( 0, cooldown.fists_of_fury.expires - ( buff.weapons_of_order.up and 2 or 1 ) )

                if talent.eye_of_the_tiger.enabled then applyDebuff( "target", "eye_of_the_tiger" ) end
                applyDebuff( "target", "mark_of_the_crane", 15 )
            end,
        },


        chi_burst = {
            id = 123986,
            cast = function () return 1 * haste end,
            cooldown = 30,
            gcd = "spell",

            startsCombat = true,
            texture = 135734,

            talent = "chi_burst",

            handler = function ()
                gain( min( 2, active_enemies ), "chi" )
            end,
        },


        chi_torpedo = {
            id = 115008,
            cast = 0,
            charges = function () return legendary.roll_out.enabled and 3 or 2 end,
            cooldown = 20,
            recharge = 20,
            gcd = "spell",

            startsCombat = false,
            texture = 607849,

            talent = "chi_torpedo",

            handler = function ()
                applyBuff( "chi_torpedo" )
            end,
        },


        chi_wave = {
            id = 115098,
            cast = 0,
            cooldown = 15,
            gcd = "spell",

            startsCombat = true,
            texture = 606541,

            talent = "chi_wave",

            handler = function ()
            end,
        },


        crackling_jade_lightning = {
            id = 117952,
            cast = 4,
            channeled = true,
            breakable = true,
            cooldown = 0,
            gcd = "spell",

            spend = function () return 20 * ( 1 - ( buff.the_emperors_capacitor.stack * 0.05 ) ) end,
            spendPerSec = function () return 20 * ( 1 - ( buff.the_emperors_capacitor.stack * 0.05 ) ) end,
            spendType = "energy",

            startsCombat = true,
            texture = 606542,

            start = function ()
                applyDebuff( "target", "crackling_jade_lightning" )
            end,

            finish = function ()
                removeBuff( "the_emperors_capacitor" )
            end
        },


        dampen_harm = {
            id = 122278,
            cast = 0,
            cooldown = 120,
            gcd = "spell",

            startsCombat = false,
            texture = 620827,

            talent = "dampen_harm",
            handler = function ()
                applyBuff( "dampen_harm" )
            end,
        },


        detox = {
            id = 218164,
            cast = 0,
            charges = 1,
            cooldown = 8,
            recharge = 8,
            gcd = "spell",

            spend = 20,
            spendType = "energy",

            startsCombat = false,
            texture = 460692,

            usable = function () return debuff.dispellable_poison.up or debuff.dispellable_disease.up end,
            handler = function ()
                removeDebuff( "player", "dispellable_poison" )
                removeDebuff( "player", "dispellable_disease" )
            end,nm
        },


        diffuse_magic = {
            id = 122783,
            cast = 0,
            cooldown = 90,
            gcd = "spell",

            toggle = "defensives",

            startsCombat = true,
            texture = 775460,

            handler = function ()
                removeBuff( "dispellable_magic" )
            end,
        },


        disable = {
            id = 116095,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 0,
            spendType = "energy",

            startsCombat = true,
            texture = 132316,

            handler = function ()
                if not debuff.disable.up then applyDebuff( "target", "disable" )
                else applyDebuff( "target", "disable_root" ) end
            end,
        },


        energizing_elixir = {
            id = 115288,
            cast = 0,
            cooldown = 60,
            gcd = "off",

            -- toggle = "cooldowns",

            startsCombat = true,
            texture = 608938,

            talent = "energizing_elixir",

            handler = function ()
                gain( 2, "chi" )
                applyBuff( "energizing_elixir" )
            end,
        },


        expel_harm = {
            id = 322101,
            cast = 0,
            cooldown = 15,
            gcd = "spell",

            spend = 15,
            spendType = "energy",

            startsCombat = true,
            texture = 627486,

            handler = function ()
                gain( ( healing_sphere.count * stat.attack_power ) + stat.spell_power * ( 1 + stat.versatility_atk_mod ), "health" )
                removeBuff( "gift_of_the_ox" )
                healing_sphere.count = 0

                gain( pvptalent.reverse_harm.enabled and 2 or 1, "chi" )
            end,
        },


        fist_of_the_white_tiger = {
            id = 261947,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            spend = 40,
            spendType = "energy",

            startsCombat = true,
            texture = 2065583,

            talent = "fist_of_the_white_tiger",

            handler = function ()
                gain( 3, "chi" )
            end,
        },


        fists_of_fury = {
            id = 113656,
            cast = 4,
            channeled = true,
            cooldown = function ()
                local x = 24 * haste
                if buff.serenity.up then x = max( 0, x - ( buff.serenity.remains / 2 ) ) end
                return x
            end,
            gcd = "spell",

            spend = function ()
                if buff.serenity.up then return 0 end
                return weapons_of_order( 3 )
            end,
            spendType = "chi",

            startsCombat = true,
            texture = 627606,

            cycle = "mark_of_the_crane",
            aura = "mark_of_the_crane",

            tick_time = function () return haste end,

            start = function ()
                if buff.fury_of_xuen.stack >= 50 then
                    applyBuff( "fury_of_xuen_haste" )
                    summonPet( "xuen", 8 )
                    removeBuff( "fury_of_xuen" )
                end

                if talent.whirling_dragon_punch.enabled and cooldown.rising_sun_kick.remains > 0 then
                    applyBuff( "whirling_dragon_punch", min( cooldown.fists_of_fury.remains, cooldown.rising_sun_kick.remains ) )
                end

                if pvptalent.turbo_fists.enabled then
                    applyDebuff( "target", "heavyhanded_strikes", action.fists_of_fury.cast_time + 2 )
                end

                if legendary.pressure_release.enabled then
                    -- TODO: How much to generate?  Do we need to queue it?  Special buff generator?
                end
            end,

            tick = function ()
                if legendary.jade_ignition.enabled then
                    addStack( "jade_ignition", nil, active_enemies )
                end
            end,

            finish = function ()
                if legendary.xuens_battlegear.enabled then applyBuff( "pressure_point" ) end
            end,
        },


        fortifying_brew = {
            id = 243435,
            cast = 0,
            cooldown = 180,
            gcd = "off",

            toggle = "defensives",

            startsCombat = false,
            texture = 1616072,

            handler = function ()
                applyBuff( "fortifying_brew" )
                if conduit.fortifying_ingredients.enabled then applyBuff( "fortifying_ingredients" ) end
            end,
        },


        flying_serpent_kick = {
            id = 101545,
            cast = 0,
            cooldown = function () return level > 53 and 20 or 25 end,
            gcd = "spell",

            startsCombat = true,
            texture = 606545,

            handler = function ()
                if buff.flying_serpent_kick.up then
                    removeBuff( "flying_serpent_kick" )
                else
                    applyBuff( "flying_serpent_kick" )
                    setCooldown( "global_cooldown", 2 )
                end
            end,
        },


        grapple_weapon = {
            id = 233759,
            cast = 0,
            cooldown = 45,
            gcd = "spell",

            pvptalent = "grapple_weapon",

            startsCombat = true,
            texture = 132343,

            handler = function ()
                applyDebuff( "target", "grapple_weapon" )
            end,
        },


        invoke_xuen = {
            id = 123904,
            cast = 0,
            cooldown = 120,
            gcd = "spell",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 620832,

            handler = function ()
                summonPet( "xuen_the_white_tiger", 24 )
                applyBuff( "invoke_xuen" )

                if legendary.invokers_delight.enabled then
                    if buff.invokers_delight.down then stat.haste = stat.haste + 0.33 end
                    applyBuff( "invokers_delight" )
                end
            end,

            auras = {
                invoke_xuen = {
                    id = 123904,
                    duration = 24,
                    max_stack = 1,
                    hidden = true,
                }
            },

            copy = "invoke_xuen_the_white_tiger"
        },


        leg_sweep = {
            id = 119381,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            startsCombat = true,
            texture = 642414,

            handler = function ()
                applyDebuff( "target", "leg_sweep" )
                active_dot.leg_sweep = active_enemies
                if conduit.dizzying_tumble.enabled then applyDebuff( "target", "dizzying_tumble" ) end
            end,
        },


        paralysis = {
            id = 115078,
            cast = 0,
            cooldown = function () return level > 55 and 30 or 45 end,
            gcd = "spell",

            spend = 0,
            spendType = "energy",

            startsCombat = false,
            texture = 629534,

            handler = function ()
                applyDebuff( "target", "paralysis", 60 )
            end,
        },


        provoke = {
            id = 115546,
            cast = 0,
            cooldown = 8,
            gcd = "spell",

            startsCombat = true,
            texture = 620830,

            handler = function ()
                applyDebuff( "target", "provoke", 8 )
            end,
        },


        resuscitate = {
            id = 115178,
            cast = 10,
            cooldown = 0,
            gcd = "spell",

            spend = 0.01,
            spendType = "mana",

            startsCombat = true,
            texture = 132132,

            handler = function ()
            end,
        },


        reverse_harm = {
            id = 287771,
            cast = 0,
            cooldown = 10,
            gcd = "spell",

            spend = 40,
            spendType = "energy",

            pvptalent = function ()
                if essence.conflict_and_strife.major then return end
                return "reverse_harm"
            end,

            startsCombat = true,
            texture = 627486,

            indicator = function ()
                local caption = class.abilities.reverse_harm.caption
                if caption and caption ~= UnitName( "player" ) then return "cycle" end
            end,

            caption = function ()
                if not group or not settings.optimize_reverse_harm then return end
                if reverse_harm_target then return reverse_harm_target end

                local targetName, dmg = UnitName( "player "), -1

                if raid then
                    for i = 1, 5 do
                        local unit = "raid" .. i

                        if UnitExists( unit ) and UnitIsFriend( "player", unit ) then
                            local h, m = UnitHealth( unit ), UnitHealthMax( unit )
                            local deficit = min( m - h, m * 0.08 )

                            if deficit > dmg then
                                targetName = i < 5 and UnitName( "target" ) or nil
                                dmg = deficit
                            end
                        end
                    end

                elseif group then
                    for i = 1, 5 do
                        local unit = i < 5 and ( "party" .. i ) or "player"

                        if UnitExists( unit ) and UnitIsFriend( "player", unit ) then
                            local h, m = UnitHealth( unit ), UnitHealthMax( unit )
                            local deficit = min( m - h, m * 0.08 )

                            if deficit > dmg then
                                targetName = not UnitIsUnit( "player", unit ) and UnitName( unit ) or nil
                                dmg = deficit
                            end
                        end
                    end

                end

                -- Consider using LibGetFrame to highlight a raid frame.
                reverse_harm_target = targetName
                return reverse_harm_target
            end,

            usable = function ()
                if not group and health.deficit / health.max < 0.02 then return false, "solo and health deficit is too low" end
                return true
            end,

            handler = function ()
                health.actual = min( health.max, health.current + 0.08 * health.max )
                gain( 1, "chi" )
            end,
        },


        ring_of_peace = {
            id = 116844,
            cast = 0,
            cooldown = 45,
            gcd = "spell",

            startsCombat = true,
            texture = 839107,

            talent = "ring_of_peace",

            handler = function ()
            end,
        },


        rising_sun_kick = {
            id = 107428,
            cast = 0,
            cooldown = function ()
                local x = 10 * haste
                if buff.serenity.up then x = max( 0, x - ( buff.serenity.remains / 2 ) ) end
                return x
            end,
            gcd = "spell",

            spend = function ()
                if buff.serenity.up then return 0 end
                return weapons_of_order( 2 )
            end,
            spendType = "chi",

            startsCombat = true,
            texture = 642415,

            cycle = "mark_of_the_crane",

            handler = function ()
                applyDebuff( 'target', 'mark_of_the_crane' )

                if talent.whirling_dragon_punch.enabled and cooldown.fists_of_fury.remains > 0 then
                    applyBuff( "whirling_dragon_punch", min( cooldown.fists_of_fury.remains, cooldown.rising_sun_kick.remains ) )
                end

                if azerite.sunrise_technique.enabled then applyDebuff( "target", "sunrise_technique" ) end

                if buff.weapons_of_order.up then
                    applyBuff( "weapons_of_order_ww" )
                    state:QueueAuraExpiration( "weapons_of_order_ww", noop, buff.weapons_of_order_ww.expires )
                end
            end,
        },


        roll = {
            id = 109132,
            cast = 0,
            charges = function ()
                local n = 1 + ( talent.celerity.enabled and 1 or 0 ) + ( legendary.roll_out.enabled and 1 or 0 )
                if n > 1 then return n end
                return nil
            end,
            cooldown = function () return talent.celerity.enabled and 15 or 20 end,
            recharge = function () return talent.celerity.enabled and 15 or 20 end,
            gcd = "spell",

            startsCombat = true,
            texture = 574574,

            notalent = "chi_torpedo",

            handler = function ()
                if azerite.exit_strategy.enabled then applyBuff( "exit_strategy" ) end
            end,
        },


        rushing_jade_wind = {
            id = 116847,
            cast = 0,
            cooldown = function ()
                local x = 6 * haste
                if buff.serenity.up then x = max( 0, x - ( buff.serenity.remains / 2 ) ) end
                return x
            end,
            hasteCD = true,
            gcd = "spell",

            spend = function() return weapons_of_order( 1 ) end,
            spendType = "chi",

            talent = "rushing_jade_wind",

            startsCombat = false,
            texture = 606549,

            handler = function ()
                applyBuff( "rushing_jade_wind" )
            end,
        },


        serenity = {
            id = 152173,
            cast = 0,
            cooldown = function () return ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * 90 end,
            gcd = "off",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 988197,

            talent = "serenity",

            handler = function ()
                applyBuff( "serenity" )
                setCooldown( "fist_of_the_white_tiger", cooldown.fist_of_the_white_tiger.remains - ( cooldown.fist_of_the_white_tiger.remains / 2 ) )
                setCooldown( "fists_of_fury", cooldown.fists_of_fury.remains - ( cooldown.fists_of_fury.remains / 2 ) )
                setCooldown( "rising_sun_kick", cooldown.rising_sun_kick.remains - ( cooldown.rising_sun_kick.remains / 2 ) )
                setCooldown( "rushing_jade_wind", cooldown.rushing_jade_wind.remains - ( cooldown.rushing_jade_wind.remains / 2 ) )
                if conduit.coordinated_offensive.enabled then applyBuff( "coordinated_offensive" ) end
            end,
        },


        spear_hand_strike = {
            id = 116705,
            cast = 0,
            cooldown = 15,
            gcd = "off",

            startsCombat = true,
            texture = 608940,

            toggle = "interrupts",

            debuff = "casting",
            readyTime = state.timeToInterrupt,

            handler = function ()
                interrupt()
            end,
        },


        spinning_crane_kick = {
            id = 101546,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function () return ( buff.dance_of_chiji_azerite.up or buff.dance_of_chiji.up ) and 0 or weapons_of_order( 2 ) end,
            spendType = "chi",

            startsCombat = true,
            texture = 606543,

            usable = function ()
                if settings.check_sck_range and target.outside8 then return false, "target is outside of melee range" end
                return true
            end,

            handler = function ()
                removeBuff( "dance_of_chiji" )
                removeBuff( "dance_of_chiji_azerite" )
                removeBuff( "chi_energy" )

                applyBuff( "spinning_crane_kick" )

                if debuff.bonedust_brew.up or active_dot.bonedust_brew > 0 and active_enemies > 1 then
                    gain( 1, "chi" )
                end
            end,
        },


        storm_earth_and_fire = {
            id = 137639,
            cast = 0,
            charges = 2,
            cooldown = function () return ( essence.vision_of_perfection.enabled and 0.85 or 1 ) * 90 end,
            recharge = function () return ( essence.vision_of_perfection.enabled and 0.85 or 1 ) * 90 end,
            icd = 1, -- guessing.
            gcd = "off",

            toggle = function ()
                if settings.sef_one_charge then
                    if cooldown.storm_earth_and_fire.true_time_to_max_charges > gcd.max then return "cooldowns" end
                    return
                end
                return "cooldowns"
            end,

            startsCombat = false,
            texture = 136038,

            notalent = "serenity",
            nobuff = "storm_earth_and_fire",

            handler = function ()
                applyBuff( "storm_earth_and_fire" )
            end,

            bind = "storm_earth_and_fire_fixate",

            auras = {
                -- Conduit
                coordinated_offensive = {
                    id = 336602,
                    duration = 15,
                    max_stack = 1
                }
            }
        },


        storm_earth_and_fire_fixate = {
            id = 221771,
            known = 137639,
            cast = 0,
            cooldown = 0,
            icd = 1,
            gcd = "spell",

            startsCombat = true,
            texture = 236188,

            notalent = "serenity",
            buff = "storm_earth_and_fire",

            usable = function ()
                if action.storm_earth_and_fire_fixate.lastCast >= action.storm_earth_and_fire.lastCast then return false, "spirits are already fixated" end
                return true
            end,

            bind = "storm_earth_and_fire",
        },


        tiger_palm = {
            id = 100780,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 50,
            spendType = "energy",

            startsCombat = true,
            texture = 606551,

            cycle = function ()
                if legendary.keefers_skyreach.enabled and debuff.skyreach_exhaustion.up and active_dot.skyreach_exhaustion < cycle_enemies then return "skyreach_exhaustion" end
                return "mark_of_the_crane"
            end,

            buff = function () return prev_gcd[1].tiger_palm and buff.hit_combo.up and "hit_combo" or nil end,

            handler = function ()
                if talent.eye_of_the_tiger.enabled then
                    applyDebuff( "target", "eye_of_the_tiger" )
                    applyBuff( "eye_of_the_tiger" )
                end

                if pvptalent.alpha_tiger.enabled and debuff.recently_challenged.down then
                    if buff.alpha_tiger.down then
                        stat.haste = stat.haste + 0.10
                        applyBuff( "alpha_tiger" )
                        applyDebuff( "target", "recently_challenged" )
                    end
                end

                if legendary.keefers_skyreach.enabled and debuff.skyreach_exhaustion.down then
                    setDistance( 5 )
                    applyDebuff( "target", "keefers_skyreach" )
                    applyDebuff( "target", "skyreach_exhaustion" )
                end

                gain( 2, "chi" )

                applyDebuff( "target", "mark_of_the_crane" )
            end,

            auras = {
                -- Legendary
                keefers_skyreach = {
                    id = 344021,
                    duration = 6,
                    max_stack = 1,
                },
                skyreach_exhaustion = {
                    id = 337341,
                    duration = 30,
                    max_stack = 1,
                    copy = "recently_rushing_tiger_palm"
                },
            }
        },


        tigereye_brew = {
            id = 247483,
            cast = 0,
            cooldown = 1,
            gcd = "spell",

            startsCombat = false,
            texture = 613399,

            buff = "tigereye_brew_stack",
            pvptalent = "tigereye_brew",

            handler = function ()
                applyBuff( "tigereye_brew", 2 * min( 10, buff.tigereye_brew_stack.stack ) )
                removeStack( "tigereye_brew_stack", min( 10, buff.tigereye_brew_stack.stack ) )
            end,
        },


        tigers_lust = {
            id = 116841,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            startsCombat = false,
            texture = 651727,

            talent = "tigers_lust",

            handler = function ()
                applyBuff( "tigers_lust" )
            end,
        },


        touch_of_death = {
            id = 322109,
            cast = 0,
            cooldown = function () return legendary.fatal_touch.enabled and 60 or 180 end,
            gcd = "spell",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 606552,

            cycle = "touch_of_death",

            -- Non-players can be executed as soon as their current health is below player's max health.
            -- All targets can be executed under 15%, however only at 35% damage.
            usable = function ()
                return target.health.pct < 15 or (target.class == "npc" and target.health_current < health.max), "requires low health target"
            end,

            handler = function ()
                applyDebuff( "target", "touch_of_death" )
                if level > 51 then applyBuff( "touch_of_death_buff" ) end
            end,

            auras = {
                touch_of_death_buff = {
                    id = 344361,
                    duration = 8,
                    max_stack = 1
                }
            }
        },


        touch_of_karma = {
            id = 122470,
            cast = 0,
            cooldown = 90,
            gcd = "off",

            startsCombat = true,
            texture = 651728,

            usable = function ()
                return incoming_damage_3s >= health.max * ( settings.tok_damage or 20 ) / 100, "incoming damage not sufficient (" .. ( settings.tok_damage or 20 ) .. "% / 3 sec) to use"
            end,

            handler = function ()
                applyBuff( "touch_of_karma" )
                applyDebuff( "target", "touch_of_karma_debuff" )
            end,
        },


        transcendence = {
            id = 101643,
            cast = 0,
            cooldown = 10,
            gcd = "spell",

            startsCombat = false,
            texture = 627608,

            handler = function ()
            end,
        },


        transcendence_transfer = {
            id = 119996,
            cast = 0,
            cooldown = function () return buff.escape_from_reality.up and 0 or 45 end,
            gcd = "spell",

            startsCombat = false,
            texture = 237585,

            handler = function ()
                if buff.escape_from_reality.up then removeBuff( "escape_from_reality" )
                elseif legendary.escape_from_reality.enabled then
                    applyBuff( "escape_from_reality" )
                end
            end,

            auras = {
                escape_from_reality = {
                    id = 343249,
                    duration = 10,
                    max_stack = 1
                }
            }
        },


        vivify = {
            id = 116670,
            cast = 1.5,
            cooldown = 0,
            gcd = "spell",

            spend = 30,
            spendType = "energy",

            startsCombat = false,
            texture = 1360980,

            handler = function ()
            end,
        },


        whirling_dragon_punch = {
            id = 152175,
            cast = 0,
            cooldown = 24,
            gcd = "spell",

            startsCombat = true,
            texture = 988194,

            talent = "whirling_dragon_punch",
            buff = "whirling_dragon_punch",

            usable = function ()
                if settings.check_wdp_range and target.outside8 then return false, "target is outside of melee range" end
                return true
            end,

            handler = function ()
            end,
        },
    } )


    spec:RegisterOptions( {
        enabled = true,

        aoe = 2,
        cycle = true,

        nameplates = true,
        nameplateRange = 8,

        damage = true,
        damageExpiration = 8,

        potion = "potion_of_spectral_agility",

        package = "Windwalker",

        strict = false
    } )

    spec:RegisterSetting( "allow_fsk", false, {
        name = "Use |T606545:0|t Flying Serpent Kick",
        desc = "If unchecked, |T606545:0|t Flying Serpent Kick will not be recommended (this is the same as disabling the ability via Windwalker > Abilities > Flying Serpent Kick > Disable).",
        type = "toggle",
        width = "full",
        get = function () return not Hekili.DB.profile.specs[ 269 ].abilities.flying_serpent_kick.disabled end,
        set = function ( _, val )
            Hekili.DB.profile.specs[ 269 ].abilities.flying_serpent_kick.disabled = not val
        end,
    } )

    spec:RegisterSetting( "optimize_reverse_harm", false, {
        name = "Optimize |T627486:0|t Reverse Harm",
        desc = "If checked, |T627486:0|t Reverse Harm's caption will show the recommended target's name.",
        type = "toggle",
        width = "full",
    } )

    spec:RegisterSetting( "sef_one_charge", false, {
        name = "Reserve One |T136038:0|t Storm, Earth, and Fire Charge as CD",
        desc = "If checked, |T136038:0|t when Storm, Earth, and Fire's toggle is set to Default, only one charge will be reserved for use with the Cooldowns toggle.",
        type = "toggle",
        width = "full",
    } )

    spec:RegisterSetting( "tok_damage", 1, {
        name = "Required Damage for |T651728:0|t Touch of Karma",
        desc = "If set above zero, |T651728:0|t Touch of Karma will only be recommended while you have taken this percentage of your maximum health in damage in the past 3 seconds.",
        type = "range",
        min = 0,
        max = 99,
        step = 0.1,
        width = "full",
    } )

    spec:RegisterSetting( "check_wdp_range", false, {
        name = "Check |T988194:0|t Whirling Dragon Punch Range",
        desc = "If checked, when your target is outside of |T988194:0|t Whirling Dragon Punch's range, it will not be recommended.",
        type = "toggle",
        width = "full"
    } )

    spec:RegisterSetting( "check_sck_range", false, {
        name = "Check |T606543:0|t Spinning Crane Kick Range",
        desc = "If checked, when your target is outside of |T606543:0|t Spinning Crane Kick's range, it will not be recommended.",
        type = "toggle",
        width = "full"
    } )


    spec:RegisterPack( "Windwalker", 20220611, [[Hekili:T3t7Unoos(S0yb8y3PJplz7mDVW2a717Uh2E3DoGlnWC)k2k2YjAITKpz5Kohc8Z(rsjsXpQIKs2UNglU)mtAlQIfRQy9nPUl4UVE3TRIkIV7xchego4MGW(HHJ(yWNU72Ix3fF3T7Iw(u0dK)inAl5)(RjPREjAZtX50h96MSOvuqSp7q(sYJV727pKSP4VLE39qWD4icC3VlEj5NVH8NpMSAvC5yJ3Vug6hx8pZsF64x(YH04Jlcc(WXfuaD8lh)YNFmk)H49)XJF56Jl(6lXrpDCXFnzFX(JlYwt(Zd5VECrsArCE(HDfhxSj7HKL9Lh9T7ssttsF44IpNhrH)Fpz5tkd8pTA1Xf3NTF)6KhEKaJLpgV8jYeuKDCX2OuYe85)8XfXPf5jX7LELK0RxMT9(iYR8x3eV)XL5rRlkF(ThUFFruArs0MJlYJFoA7UJlwNNT94c5L9x)CCoDLKwUGVEWnxhe0)UB3qxHusD2U4uc1)R39lmMxCA09BIxD3)(D3gTSijl9UBxtg68S1ZlEmE(lpMuepVi5bkdBzo5FKNer(Rht6Vn6BhxCnDTLCCXSPhxmK87VUCdz4ucmz2iZqbHtPnn1qPiAdHe0NaG53FiFFr)QrDCrhgybNcowg)TDXBMt4LBPtYqK1cdZNVlAZwf0NqJZMVNq9FkgFYcHxpJqxpgqPeiCCHUoFj65ykqgtbcWsrcWKrDtZwv(VikU7wIO8US09ugDw(kyjIAy)oISBj3AFCECAsXRCMfzdjHoUSG(21l1OnBMx(pMtL8kL)MxQdy5Q57Jx7LOXzAYkbIn5K8K9Kn0Z3FiD(tKnZ(X55V89Bik5YouWFvlYzzzBwL9sAF6EmgTFnrDt)84TrjP7vhIgkPmO7pSEDFDo48xEP)HDSNtXSNJNt2PVLOG54IjhxmcEnngxAwh5zt6QO0LX0PKiH9BjK5RMmSVsT48LuTILedaH46zWYQqvBKGsrH3plV1HOFkFdDoxLh9aH)V7q6Yh12f9r)xI60nMohxuCNuGpDskAzCpeDRbd8xzeDTeGP)maFRpiG6sG1XfxbqXypONQwpM2D20OVJ3PgnMs0b2zbIDguX8JlE7ng(vRYIqANZy11gyOJrL73RXgcc0vMOjztx5uBTp8AFILBQhceIZWbmyp(4I3Rt8CkhfC6kGmumieWRTXwsDSkWdsouSPjm2PUxmGPnq4D1D3kjrUEZRmfEX5exu4Rf53MmCHUCRwRy4UW2HS4rGffl4wJmiJDrvvqjDW7j6WejrvVt1C3ZPiG)2VarE)SRv)UGlslKWV)wtA(waqbBUHt3wFNHQp4NveTNNSM42Kf2ngzS1gVwfZwA3NLgV6aXYY95XVmV6h9GY(D0kvdzA09uw0MJmPbYQJGwZ66wKDveq9s2oQ6NckBLd1NJiyl55S)QYHtoiQm6z6tBs6Zzpfp)BhItRxbphT5azF2M90TOCzgynyCJxOdQYkdtjojeuMSblo05YWjCq1S65eUlUOpfN1Ld6xQJqD3ZjGuwvetKc408(psMlgv0nuhxZYKO(q6tRNkX8OZq5qIQ6IiHgTzonae76rDcS73KLTYd1Oob06K8ygWS76Tt4CFCo5rpr2YiuT1saf9at7bjSTN2l0OjiI5lP7hlYYjVDHMUpDns(SvIBEwtkywPlRFS07R8dPXRZiAl6VoIakY0Fy5J1qG4zwq4aMlH(k53TY4(ZeGqqS04L5zBiwwK8LsrVCP5EHVQInosRiJPtEXOT86vBzZCACS7iyGIJhmAbLJTkoQ4rhbz0g(WNg4jzTL49tKqAICettT1KgH6Twe6sXzSQPSnRWp5whDWnUO74kvD7EfzcI)w8YdmPbQ9u(8yKVkOaICQxY5QJAwS0q(VLvCi9H4K8CcbFFrs6R7l10lqj0riIg6cHAKFzz(HckqM))CGOW5Wwcg8CYYyzdDOJreh2fc9EjNiFUVGiUlX(Q)n603ydkny6jkHZxYsY)Q5rPjBJMFFubb6VwJn4dHIC4(CFQ6Schi8MTwbs5g089e2Zg6Bu7vyLhLpgr2Z8qE0(De1mfXBLCR14ru8h3UPtR1pSjAvseXC8Ecfz1dmMviU()tNzrjKeFwiAf3N8qI0Ml9hqreRk0f4cJbLLo)W(yQBhPpfxO5ZSVwz5SltFoRXt6SqE7TmFBc9Z11VpyyjbookV4rIfNiMiwY2DeeVg7bFkDHmu2lT1rejtIBAK9VB3P5Kw4i1rUzdDTX0qRnqCnI2S2mU2jjr(4WTFDZa(Z66kCKGbs2MfJGBw28DR8yRe6EPiOXCZauUjBQ7j7YOoPAQ8I)YGEMoD2tXvafhCySCCRmE5jqOtfjbsH2jxNNqLQeOgdIMyjU2(9zh2CFs6Q(7ilQde7OX0e7qGOIFuVZdYDhDXm6shZND6Z0tKKavEoBturcbx2NT5zwitsdC72yQ27yT0QYlKS8yFyt29rBOdSmVQfqP8qAhkfn3LNSLSZoH4U7oIXgwTO5P2MWl(ex6lpkz18yk21pA1Q9e5lM4JGLdw0M(RoqCriHw4AIZZd6)XsEFjf0s9fGRaK1Si4zUiDSCGEjHO51cHx93UD55fqOuxsqrOSuAJyhF7CMkEIxoROMtJRL8SLUqirq2d0N05pEyBuAwYkY66T3QQ2b1XDI7iZ3g9TjdF7nxB1NekngWcJojSrI5aPIrOjWVmo258vQwagC)LzhslkZykBm6c5cBCiAhKF2tZ3LNTeTQm6gD5ecRfmWQztHhSi1ONVTPE7UEU2Lb3ib4ejp5PxjOrkBxc0kcRcaAzrVE94HgjvEmSMiWnY8fRPKpBcKdLLPuGN9w9YmsnFhi7pc0wxSGKzfInq4CGPvsObthP9kgiHokA(FHvUeyMdECDWkDnZjcBFv6Qdjf9jXsV8arFdjiTY3BVIm2(DXB2WNFPQSzzh3mLkaIO7f3HagktTXhVDxConiPLrepMtimlPs8guAiSbIeEPlX4DfCh3y0iJnLGP6FmByO7RvCAeFxTaqg7OHLohR2Va5eSMzq)3IwfpNfrCAvAOXdSLrhYpS)rXl(c1gPqzjKBeskd1FrW0EkRO5eliwd72c822WItoGacZCt5dqutYdYeU5iGPVMT(wDtGG7CZ7SPVrgy8(OdTLioPg)ZdxOqySwIXTnTeIhiIXoBRvU2lxBMjCE1nqf(W4bqLB0erZs4EkM57umrFkgz3AlIs6YapLZCpiBlOmABt9z)StlmgzFT5UN21U)x21Z3esFGxK(zMfM(ciY4Tuz7fzgkezy)ZXssbs(AJ6CQrITpl6JqMll9gIdRiALDfkPX1Xvb0vwkASTw1tWCgq1MR0dyqzzU57jAgZwOOFxE8ZZFy5Q(b9R5sqAhgpOmNtWSdJSt38faU2Oo8mGIg2aYQawoTOozD2Z7J7TAL4hXYfzUpPSYa5cXqDgeGcv2q4ooaNAjfVhS1T4Kqki2wlzd2tdJN5qYPPam)xSfFoFd946jwnokz9Ge6gJ9ukezpBeJu3gPZZRJlMd3RAG9bKxaMJPKJx2luzTdE4YM(0LJOryaVJfl3iOzsaxeLS5CFmH6NLEypz)xCE4hNhUBj7zvbuVmk)zArwIFnwpgBNCfrksChySNznXZfLzJ4ztCtwxGOqf0mfTJ4V6MnyEJv7xQ7LNDz4sd4LzLruefYKnN522EFY8kMbCpI6dNscApgj4qDR629GOHZjIRe4bwJa)kElCFA6b3Uzss9otIhtzQcSlaWBe012nmI0jIDGDhswHh2kwOqhO5YNG1L(wz)hvRwADX6FkzhzfwyuRteL3wgtvsq5bl1QEW0wHAajLDTotdhOU9N1hdKreT6v)yec7GCk4iu51QewAimqeFeBha1dbyNsI15cdfCv0f5PWU7ypFcgGb11WEhRpvnczXlCj0Rd8fkHjRpqC(lpUS1FQsJQSjbG3XUBGDRD9euYap3nohGIlqbwmPjBP1cM4ChJz3uemaFA12G4wdqfWe1VCdryD(9Vop(BrB3raoN(wh3KE7eG3TFwx5iArAVcIPE2ck2LflfclFNbAs72fiQ4mx4DsoAgLkzUl30puAfEjPKYN3n0DQg96I1WiVF19LkCHIYWhFiqYQIdnZAEpjcAqVUQQBEhIAygpMH20AXKF8eAEA75)2PiyhUcY)1Sf9Xl7Al7d8ljZ6uyeNcrcpDP4DiWOQeaJx8FV2nQw42oTqAQBzz4UQ8)9EF6FyFiAdLClhQd7XdmeHGXpKxMemPqPLBsuOkTkv1mV6LAp0vA3WXu1GsbpDOLMv00LkZkT2Nln3V0wz1S5tJMumwQZNY7VpT4k9opE0mvh62vBlLg3Ps(wrXUb153p6(SWC2oTi4Xa71Q2lum50p1i4bcD(qtpo9i4bcC6OHqPIBfST(aAG7sOx4FJLX94uDDgp(m4Un61QZZU9g6KQy5yfHo1kB5h3scmQsKHdAcPx)mVu7mZJghgglv)fi7HsT0s0Y)NdeLTRM)crVRWYMr2O41Dr9DI(wSpoSwVKwgT8rwfXeGOGeP9(d5Y33j2geuTPnd8F)YO8sZwenfX5Pe)uP5gED88r(GVu3GQ2lJbiP90OdbQm2WH7XKOoBNaiBrabPD7SFAH8lp5)4TO5lm7hIlJqkkpQRsRsZn(n6uodLfaxQcVbUsoHEC4B9Lkp0sgG8qbaNSzErjeA5o073jKu9cyWYzv77jcgmqU(JsxSd(CWQ(EGFs2JvVWicXTe7QVkfau)IJiu5MJG5j2(5)2HvpS18QJie3KXf4uDznDhaj0OCH(99eETkED0Hn1T7JWA2ocIp)rkEZVJOuPKAeYQRbNAaWLBmVoz8vcutWIk0P9tx3uBetQYkvhEsQT1SKMAVRdJ2O9j7y9P1PMNUkCMacOaYNyGqDAdyQCN1xmrovid8ykLP0Mz6SN8nIuT9wGsP1aXjKI741Qs4cmVheKZ6pEHG)OX6O6Mlv3aM7LbGt5v4GT(zzQPN5oELYECOgRRRzhuXiCJ3c9ss9VK6rcXZgtQAO(1hxa6aQmyxVYQRRnuXkCVYeIolZ2Vnz5C9ikzU4hNNTe8CH7ZljRwySGcetIXz3U4v(ac51RuDkTNZFb3iJ25TPm2r261XP7jcskA(aQSR9u0r(pFJA(XA60DxWHUClN6h7ENvHZMx)ELfHPLrRlvPGDzS)V1SD7vzuoPvvRqyBzoxdtURXxDYYNNElPLflJ5nFcbVIFSChrZnxosrZ(yp9FR54x1vNU9eHQEDBkCrt5g0WEomT2md8hwLni200((B2sMiRRPctEKSauT3QSIuCpQ7r4Ep02HpJPATHhVm(oh3KeLtFML0tIEqa4YwJKYfcLiM8)snHrieFlj3rciF3f5gu3swapVZMKQahNctDXwpNfX5rOWAs0GCJQ5lP9UsBfKaxlMNOS4YOViIwLFyhmI)6(SIcY0pF9MOxJx9cvEQi7BjPNCyyc3msqRPt5(oXa1Der7X1fHr7bOLdqBCgfdr75Az5w7PwZKCTxsajzue3HqBSuaZkuzRkLn1iIOIXAh)uTTut9bXQKy)PmmRoNRfLIsw7izU3hUVLwu8J1Rd2JuRyzP1nC0fEGHXbg1nsrOBZT(IGLJDMoGmDOywb4m9aL4v)8iOoJqOx3mwiWEqdHGnyIeWbXnyHFP1Hnn8enHYbGo1BZGUSdSD83mf9TDnv0IBfLU(g6AhlBUuobv(26exXBW2oQ5XX6PMTIEDKFqXA8XcIrqHVrfKOxqxCcwcmTrxUbyhegpojon582G7oJfhsXu1H50PJ40OlLl4DkcUKc8DTQT7GdJib5VuTlZEsd7A9wDNRXt5B0bmhSX3cg1inWbHUbkY76L(uGwXvsVEpPyMe7wvu2JZ9UX7rAE6HmLM4hV5k)UGolYtzy6qMoPHmNdCn3LbK7S5qRos9omTyjOz4WUxkFvH44U5qC8(vvXbE(31p86NNl0bv0GN8i8niDSD21xQCg39Gnn0Ur2oEDoSrob7dX27wOLtIlXNLoo5fb3SjVBCKOXjFb9133A9gsYi7fa(UWFoXGaN(0WVWEWQ)8JGyPkxtek1(9IQ11w0gcvnS6LVH8m1F2OF(QZcRg1g2XKlYhBW)fGPC6IYfYNDgRr7cLhiiBCGNDn6AdmdpCMa4zN0g0CrvLj843AnYz1uSogjNRiTtehw0U(F7raSsHvYGj0JgwN2eHtVFxdWIl319fe(HCA5Br0JEiF4pcW2NqRflDwl)a5oE4G7U9LOCQn593D7V(N(V(L)2V8F8hpU44IV(izTNSDxwEbjO(S8Jl(j9TZ)e9lkBzs1OhqtAqerhkY2sRCiLqfL(a7Zu7)iH910La2pNLsqa2J)Pkhu(V)PYVVTI)n3rfYVt)G2(x(p)hK9wbFRNaqHNlaf0civbGJFXbTIROTH0ObnhJ0xBornPeZ3mS7tAixDRUlWpPFYKOvTg1feAjy(yBbdIuLo8eDWGaC1)sBeikAgXE4jHoLWyCZLMuEFDsstF)GBAnaCsp5g1AgvDuRriykkVNjeaq8dTyjvwFUMTGAPyc8EaD2L3BPuGYpFwGsR3ERkbQZW9gmiAj01b6j92xrGQ2TSzYaT3m25rnXPSPagcnJQwXQ1L78yzG4xql071yRWrzXnJlFQCjd7UngaNI28)gBXtFTGWsNwPLZGwZB6kK4m8HIhZYV72Bt2(zADVZwNqlk9F4pCCXVsy7VeTHe69Xf)ZS0No(f6V(LdLlQpq7VVWq6Cq)5px26M)XY)fXF9Vs8A9PJl(R0z64IS1K)8aTeZICXrWIShsw2x)nUTkxveystw1Xf)Dw2Q0g8FA1QYMWIv3lkxlMfDhLGSnkLmrF(ptdTMembJxk)AjPxxwDFcojkTC9yU9W9KyfzfILkO8C0ws0KRZZ2Qss(6NjU0twzPLeIRhCZ1bb950J)szM6Pijvjx8Xf8P8(4hiXq0NGllxgVJsCsZsVMMSI1h2WzrmaV5vc4Q(39fTKWvt)3WAcb4rZJw7d0kUpfOG7FiB3usqCFG1jct9OreE7n0Mqq6r1nGG0pI28bsJXOXdKEMwthi9elnCamDPUTcGFUOKqFiz903b0GvOVfnh2SxQANjA3dykTe)mRrmklnubv9fzsOkUsiIerphLSH(I1YftnoqaIhzW6fD2TkdxeSRhTQ)mLYm)2Bk)ZRBcKMeeoOt3UvuiEGrDua4m08N1b9jZcg07T36w)C)6a)jktCNM(6Zcg7EwRAV9PdCaEofsbL61ZbJL4clcFvpLRoM(k0CsyhISm9lcdEx3p5J4ivDo3url1eNqHpA7XptBWwg60X4ysDwQQqbOMK)T3EhEBXtEyLGkyX)12hmjCaoYi1w468jpAW8(0VBpn6f4BlgtwdnPv2LxbwATCQAoVAG9oqjJvAok7sAk4QO0aDUnrFHEFsxjDIuLYEDC0vXKxN4dHQwNjtVzqpyu7DNvCZJPwVDfReORMJpu2GJtdO4MrVS7em65v0eCq3SkobBzFxRamMg2rm9jJ78oxNiaMjrwEsVH58C9eIuuXpOK11YPSk3Xxt()ZMoStxZQSmja8tG1Oo2Z(7KG(JL2dIvRLjH968ohFXEWxO1vWYyTeGTwqnjs)IDDHxOWL2dF9vxaaqENuHa6OS4d)rCX7Illj)k3f(6Ru37SKR9otDeizVIBO3KKYqx2ZwthBLinqNAGoD1KhvnspLYnu5zQdG8l9WWrubMtdLNfo2jw3X8kYAw4apwlYu2y9JzafDb76dMYWrU55LjNurB670CA2tGayZOXaIlRjSqyUN3fii)FzuqLEozOBaeLfBbceL98OQmfK6tE3PGUWz7nOEaz63PHIQUWnk8BVzx)qphtTI6j6KAQnBMCFbQiXozAqDyQOlEku7A2lakDJ(Kp5ZNgY3teZ71P77mBDoI7NWARqctXieqq109uwDguliJlqkEQuhz2K3FP5IbWqcHM4yXdblJquHF1B0dkjyqliwnuwRYJxOokrBQ1KGGM7U2c5QdQSiVPTRLCS2W2xnIiVAxiB2q26C20XguqJoQwiHH81Tt79T5Nhe3Qvo)6qbJQPvfRD6OGLHI6dOgeq6vzbDZwVvpl4tDCirEDGdh7ugTo25WTunpr52Hf96jD)CTMadHf1Ux2nd3hTnDDOgiKLxdDfp9yEdreOD9P8LQgX1MJoLsz6CMXdqcWAA3Hxn89oC)MMonRrpdjAYZ7kOx18DrMniSKZms9u8hevQWKZO0NWoJGPRkWPUeOl50b1hrIGMds1qDTWDS35VaBHMmSh1Pj(Iu0uFtveQGCxJZ8bYUZBVz4zwNUaTog87AFrJR(NlwsdYGHBJawx(zaQClshOUleeKUnNwbrt6Y78EsAFKZ6ZAy7jm25natK0uvjrH7jQlwBPxMMq07WMnj)o2WuAAd2ncf(unM4JUBx(CkboFykLYwawH5BjilW3h2bnf6Y5eb1PkcmUYPjwTbz1)RjbDS6NNMcNXGKh1DEaehanrqFaW6y7J)LLQpmzK1Yh0RjIiaOQSuJ1YXW2z82Beptk)OoPAzGAjX1f)dU4XSH9G0udV2AGVQMRxDVxbGVDTGoaz4jXoyL5tMFGqSDZO6Ds8dAfVq9SVmRrtTuhw6A7DMxIGsouIQ(v2LYYBwDSq(T7C6KWEgvotA)D7xdMOIJOLNquC2fX1gi3y4raay12LNlOpN4tBpWYrzstUcUKCLgymw6DbG5Wb17LLQiPlY0OkxQaLTPPrrLzqqvIScGsdapGCXGcHr42WcSiJR8YiBa6v5yjXbZUolVOayE0sesT7GFDDqpabddp27IK3nBrxz5HcZ2bGwdOgFqMpqPq1(9iyaeqRe6G3DqEfSVrvauhKSAZD)LPqblnLgBSAZoiQwd118nd64xFJmBGCzUSWBOTaZ5w0mGm5MAAPS7Z9enS35NEm0rYe6bTtQfgEamc2wdQ6o)iql1VuoumXwtjOkR1n4JdUg8le07dchynLl0vGRUPaXlaWnukTlLpcgQDdfuCoSoUasdbe31KmAT5ooV0XMrN8Enz0qhu1)aL1C043EZ8l(tpNjvzICUt70iUx3Wbxfo494FLoGxNdh7Wf3RCuu9oqRFQYmG1pafv(BFef0aaBiiWCJ2ggQrm80TYzZ)1YQb0II29tAyWVEQyGMwJZnntRDyTBKbEN84ZHFnyHdafoXaWsc4jPzkpUwGwdJs0uSIjLciK(NPXU82q2FtbFpxjBF6N4b)vV2SMERPbHU1fCoAWY2nlkjC1fJ3uqYq7QyN)yAKa6YdWLIcsfDtzCezADOe)nkhuEp)LqIbub3frmcVrr8GdRYh6IVfw1tNjo3b7rtY1yA6pSKpjTL2BQhGmH0RJJxXTTxtjTlS6Wgc(HGELY)A9ugRn23vpkD2jbOryZngzx4JdGtW2aNyDc6zHYl8UDtA9bO6cojgh2Q2pxuDWO(37erqpzyEHqnsY4tnqoq)ms4f2a6NNtkafARRpBBwNjz7SnATBSRy4Ggqnurylh5oZsNmjSmMD9pODg5xpqBCLFe7AloI(5FRoKl7Fn6qJl1XeZuUEV6xFn18gX4tQhfZgYmdhGNsg59LMgoSG(7)rclDzYw9J8gfZvLUPB1DUDfYUk0w4BSLhPseaQCKFNXi1pGBko47d3AiiNW)TF1FA2(Up1uVyyt)LCMdax0IpNAx0PgsRJYhEnwm)wZ9iae0(2SbryfhvA6eG(jzZ5r7YsDLO4gusDP)(ha(KQr3AP9Xtt5NKXt9VrBY9JeBnwE8hMYzdQNYUQoET8qSMS(d0OXtOVSLeVRF0onovsbovc0b9LzImG7jkN25XB27yUBbSbjzTQmj(vLBXeyQpRUMVkSimaOQrQHVSIoLg(UQAfA6lRVVUHVVA3gJnQlA1KCjH3SYG0S84OL43tPCrMelHZg(tS8YSFlrNlxjSo)uSgGIiHPfCd60bvamHuJpf1cdW(NddKDPnuPAtY(WLygvt9WLygSgU)Lyc)DkrhcSbkrcnuLUZ0fCEPBxGab9iuuKv73NWPBc(Pu3z8bvxazul96vcg01)6IMc0arDXDOJwd2s3U5prPj3K(1VxL)LwjuTYmyw53tEYvDaWOdFeuF(F6LTIq)Ild2jouzKZB0vCg6VxruvE)FmTbTaowdFxcPR0pMKvEqSKFyef(p4eommOnhEgayTu(aNvpyWXwJ)nhP0WJAaWz0tnoH4QYbcPuZx9k)oOkATgnutrhqRTlYMhLwRrAQ95qTaEs(K37OV2nq1wVQzurlhph5T5n68aIv8vN9F1SqFObYByTXuAnHXZ77eDu0FLbtGzAnIkxFLD9i)qw67cwztM0zhR9Q0(D66hIXraom(K9QIpSdWlvdDUl)r)kicPTZ5XXk9PfP6N09BN5aKpeMwBe5hqQMNIiO1HX2540NBueaEgh7CPmeoLoUAr5EGneAnTcSls4N(X3pO)hPNcW4nB4m9zbY22SqnCsmoDet3KScM5PUDyJEG4g0qR4nxh6ObB3xO53Rd3r5eqD)oN)4HTrPzjLfsgyVYq3NNh6UmhBOc)GnNFDvvdB2lPdqJS0iZCouf40Lclhh4H6xrwHyrtW)96pfAQRiVC0dn(1Al58Nj1sFO9C2iGdvHf1yqUsADdPk5wDJiuV1dO7x7Il5n4lthB9FSsUlVkW44uQ(yx3evV5XT3JFh36)FkhcLZBvWaN)mpoQWkgMSCuUd0qRVN3kpyX2OEVs5XSoQdEwVMmUJModFCiAChnng6sfJ1nH107)j9d(QoJOzryOeNuHdF21z5OxLtNVRgrGPuC1O75gM27STDJY(TVKbdkAxjFxk5nCW1JFV6I1LlaopeGZCDn)ml0dpzg6ciLhDDpCkAMlqvD(4hPR7f62fkKxordszGw3io5NpjNHmUo5Xvq4dnW5fDsGBG4lpXd2RV8KQRRUXIWRe(LPR(Q17U0GJ)3Szvo(dChCvFBB9HeLV3cADgaymug6nAMCJpKvIkf4lPRyZ79StczG2aPC71Y8WbexuUfV0nZn90VGznG5vNRBCwii7iSbuV5bavZ4aNAmvm5uDSy(lQ3hI)iJL636sJSI2E7uRLKPdaw4YA0cYkyUto5vKU3odBnBV9o9bam)CbeAFmQdHDdUs3T1EwbLZkAnDaoXIR0De7ESY(nSjQvj)5PE7I3zCNR2URP1x1qTveI7ATD5m7MDzFOAV7)7d]] )


end