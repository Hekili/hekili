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
            if buff.decrypted_urh_cypher.up then
                length = length - ( buff.decrypted_urh_cypher.remains * 2 )
            end
        end

        -- Math below is credit to Tostad0ra, ported to Lua/WoW by Jeremals (https://wago.io/2rN0fBudK).
        -- https://colab.research.google.com/drive/1IlNnwzigBG_xa0VdXhiofvuy-mgJAhGa?usp=sharing

        local mastery = 1 + stat.mastery_value
        local haste = 1 + stat.haste

        -- Locally defined variables that may change.

        local eps = 0.2 -- Delay when chaining SCKs
        local tiger_palm_AP = 0.41804714952
        local sck_AP = 0.8481600000000001

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

            buff = "dispellable_magic",

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
                if buff.storm_earth_and_fire.down then return false, "spirits are not active" end
                return action.storm_earth_and_fire_fixate.lastCast < action.storm_earth_and_fire.lastCast, "spirits are already fixated"
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

    spec:RegisterSetting( "use_diffuse", false, {
        name = "Use |T775460:0|t Diffuse Magic to Self-Dispel",
        desc = function()
            local t = class.abilities.diffuse_magic.toggle

            if t then
                local active = Hekili.DB.profile.toggles[ t ].value

                return "If checked, when you have a dispellable magic debuff, |T775460:0|t Diffuse Magic can be recommended in the default Windwalker priority.\n\n" ..
                    "Requires " .. ( active and "|cFF00FF00" or "|cFFFF0000" ) .. t:gsub("^%l", string.upper) .. "|r Toggle"
            end

            return "If checked, when you have a dispellable magic debuff, |T775460:0|t Diffuse Magic can be recommended in the default Windwalker priority."
        end,
        type = "toggle",
        width = "full"
    } )


    spec:RegisterPack( "Windwalker", 20220821, [[Hekili:T3ZAVnoos(Bjyb8y3PJpl)it3lSnWC9U7HT3BNd4sFyVpfBfB5enXwYRSCNohc8V9RiLefFufjLItpZn4(YmDSOiRxSEtQBdU9l3EZ6W8OB)5HdgoCWhgg0p4dtUE84BVj)59r3EZ(WvpgEp8psc3b)3)rCY6Nc3(yug7rpVnnCnBkoKEmBf84BV5UJXBZ)Rj3Eh28oE8eyS7Jwb)81F82BEiE96OIXgDyL8SFA5Fpn5XtF(NoE)Xd5Nwom49W)bMQtF(0N)0dHz3hD4pE6ZxDA5xEkk8Xtl)lXhYpCAz6g4FEm75tlJtYJYYoUhE5TP3hVQV8OVzFCssCY9Nw(PSWKOtl)BXREuzG)061NwEx6HdBIV)byow9q0QhHfip90YDHjWc8P)0PLrj5zXrhKEL4KRwLU7Uq4v(lBJo8WQSWn5fp)MJ3DipmjpoC7PLzrFnC3(tl3KLU70sze)lFkkJHjjfi8vdU(QGG(3EZwggYi2P7Jsa6)xU9N5SVOKW72gT(2)1BVzvwmG0XHW)6H4(7c)2PLxXa94tlNp70Yr3Et4Q840KBVzdmzls3Si)HOfp9a8wlYJVNXux98QTWFWiWWQbRqoWRixM8WTajOpSclU7y2H8(LJ60Yo811kme9T9rBxa8YDSfzenUa0Z0fhak9Jr0t8W6jMJkl2hUDho(m2FYM6eZWZNc)AeBsMWMeeurAIHrDT)lvZqI8BVbeL3NMCGXgtZw7sI4cq2TGBDiklkjo)5kMfSLeOTRYzVDnQgUD7II)ybtYRq(BrHwGvRxCiAJxIgNPfRysWKtQMJS4dWg6fhoMS4ryZCJ58gczPPBxN(usF2wforEdOxPFw0UW4KdQdrBTvg0Dh3SPVoRAXtp1)4E(ZzW)xJwaBP3bAsoTC6PLJRXQ72c6FtpMBbNM4poXHL1HjRIyqci19lXayuVAhkvlUyftRyXAAvi2cYPQRrqazZ3pkV1b0(KTLTMRZcVh4)7pMS6bTDrFWFuuNCY154Ir4Kc8rBBJ58S2QBnyqZ0qeqP)mOHgd6cZ1PLxIqX4pONQwpU2D(YqVJVsH5a7KBXMdMK(PLV8chwQvpbuSfC2ATXe2yu509olgccOn6WbFgMZS1E)Z9bl3mpeaIZOb81BYPLVtN45uokObkGmumiKKRnMwqA8sY2dnjbk20eg7u3lgW1gi8U62BKKi3S9zUEWOmWfLQvs(THHl0LB1AfhLe2oKfzcSOyXISPo1TlPQcgffFprhUykPwFMc9Eofb8ZpNZMDnuK0cj8xtRj4RGUGDLHt3wFNROmWJna)OIO9I4n6cIh335cl8Fk6ARTMToIV(3LMeTgIdAXDzrpTO8h9Gu)RJzlfKGTBYIU9gXEkmXzdN1v2i77iI(M09m9r5m(C1S(1qajGNZ)xLEGwnfLwbHNS9iZX0kbbC9uf4((O8(F7yuIozTFXgtvjzZjQ0EdxlpemkF48isxiVwdhuculI2EWxi7SSQg(7hN810hJwWqzbp2QMzq4OIM3)baI4VQ71EsnltAjTRGvSo6m0QzIPldeCd3UGfrIDfRoNS72MMU2d9QoNOnXzr8jZU2tNZZDrzWJEe2Yi011Yjk8EUIcioUhpi0OjiIzRy7hZtZG3oxt3hTgjA5Nk71AsbZl8H9dfUJLDmjAtkOTO)MqyQGL)4QhQNbWvTGHd4(n67UYULw7)kmjaGLeTklDlybsYNlf9Yf2)fo0k2EjHrglNmYOHE9QTaAUmo2DemqXteoTGXXwhfM)Gd13THp8XbEswBjC)ieJtOJGCQnY0iqV1IqVvCgRAkBdg(r3AYdU2fD3MxRUCddwGOVfT6ixAyNKRTgjWclcPctW)sA(XK7JIZYas1H84KNpuOJwmz0JWPMnN0hWsNi8idqdg0QSJ5SFDX)8iOQ44oac(A8Qiztu0J5SbE6MgkaVNYajRd5GGQeHx63oBlVUbLILhuFMTINV(1lctI3fU4UWCybFUgASmKZgWP7ZDPJDpecIU3NfEypSBppANK3LMpQgyET65goq4yCTsNIn1zhabJTS3q29PaA7MVccJazVFB464qWI9bG0V(EE(ThQBIOGKXWyWHeqL3H47JL2)z8GZciYaeDD(c569CvhrBJwLNLEipmpE1I9aVIxIffPD7JKTi6QDlwKmMgnwWTPB3ctc7V2Cm)yMCQESngTeAaIr7zlEAsFMkZccGjEpQaVP15k7ZmxomnzXXdrmpYsEmkxZ)EFDaPsQ00D8AKLTkWBVJ723WXY(9TjeKBbh)a9k72R523WjQJC7wgqZ15Rnql5A2I9Rj1UDjsdiTfXRhu9SUUcdkyGK1EP0aqfcvPpGfZUxQjAmBkGKnXx6EYoHQtQMjJ8VnGNPBS9uCUqXLjolNoseV8TyOt9ibsblkxkPHkXTOgvJMyjT(3dPh3ExCY6(7bK6iyFpIL7i2wCzpZUWdYDhDXScDe4rbWEMEUQeGYxt3cAzay5q62VYdctAG72fXu2hPL52QAvlp273MEhttAzbhHyaDN029zX7GD2GE1AnSvzph4fFSs6llmE9Iig01pC96dG8fx8rWYrRlu)1hZ46p5UJpO)hk49fuqlLWaVitwZlHNP70b6G9scrZRecV6V9RnvYKsckcLfsBGz)DlIcZYFa8(AnZgEuTKNTeqIjcYFG(IU4HJ7ctsJxd41lVuwqfwOaGNvl2f(TPJE5fxB1NouAmOLKD6WgjMBn5oVzvdgHt2Fv6XK8cd)8XOlnlmMrOgq(zpUyFw6QMw4hBj93Q1rHBSev7VA3r9UA9K5lpDJftNiRlp(magjkBg8QGi0Ur4HQhvEmUkh0DSvORPioFbKJcMV7VktS6LXKzNoq2XdS9OuXxZlQBGWlatZHydMns7fBqcCuuX)eVImYzRuPYhKLzXV9DezzHVDlz9X48(qm(Roc6BGGhlEVdkcFh2hTDB16lviplBeNRuKrcDV0fXPWtFWgp4SFuglMQvH7dxfd8qPQihuyiSbskEPIX4Dfmn3q0yJDROLpycFyKB4vCAKE7UyIm2QJl0orTLeYaOMBq)xcxhTGhVCszITPDvJthYoE4bXl(eZgPqhkMBes6D0Frhjs9vxITg2qh0DgI1w2azIOScv8acTNvrpI3tg40xZURRUptSg9RB1qYTQxt66clGVD3LKYeIRUoH2ClFjAAxN4bWzSZ2AnZ9YJN5cNxDpPcxB8ysLBXfr)y4EjM77smvFjgB3imHs6IapLRfakBlOiABt9z)Otlmg5Z1IuBx7EGzxHEtOXbErJNBwK53azdVf)AVSXiHSb)pNiXUL81wn)gUD32iv5nwFudu2yPBtCyfrRqUI0qR27xuQOTw4u0KeO4fjsNKHLu6xriBQmBHw(9zrFDX9Rw3pOFnTftnWKbfjxQrSEJKzBbbOv70PkvNKHnqGfnsonVozD2Z7J7DGfGny5caPwKvgHrDJ(eVgiWCUyKohfrvlFivUuGN0jMGPudPdHua2wl4o2tdJN5qYPPaRhyHcuDs98RgUKSwqGiW5cfIq2ZfXy1nr6S26OIRM3lBG1bIxaN8RKkx(luARdF4Yg(0fkybs0Wmjq7SgTehS58qeq)ttoEa2)fLn8dlgUFf)zLbuVkm7RSI9f9CKEm2o5lIKK4oc4EnkWCApoSIRMD8Nn5qzDbIcvWsH0EWF1TBP8gR2Vu3yTDH7c76fjRruefyXwWDB7GpzEL2aonHc1CBBdoK2QEdbGg4kbDG1eRzjVfVHq9GB3mjPENjXJzk6iWfaQAT0n2nms0BJDW9oswtifgl00J0)6tPoFawfjoPwT06A1)y8EadZnQ1jHwDlJPm3Ovbl1QU60wHAqjLiv)SikA5D98UDagr46N9J(lSlwr4gtkMwMNsdzaqQrSlav9dIDljoMliuWmjrYxdxUJ90iymnKEe27u9z4ric(gx586WGXYtYMJGZLzrfDIuz2tLTeG8o29(RBTFLOsg0PSX5auCjkWILmzdSwGe6TKJqtGrDMnOKGL3G4EJF5KjkB5wqyDXDpVi6BH72dtEf9To6f9Uiq3fzFczWknHqTs7vDmZZEsXUuAH4zX7mqBFGDrLsE2B8EmhDNsP04B3YpscdFlPKYh9oY9WIMFrk6X7wFxHcx7bxq76arUvCOzwZPjrie61zvDZ7is7X0Hk0MEug(XxrxyBpT3of06uPG83N96pDSkTSHYFlzwVggXRHirhpfD)cmUmDW0TcGx7gvRxBNwin1TO6Bxw8)ENpnvSpeTrsEJJ1Q(0XdsqWQotzMemPOGL7nu7fy1AFv7Hks7wfMPgck6PqTWMHMkuzoO12DP5UJ2ktInFz0eEPYF(SQU5tlksVtNhlD1dD7HTrHWltd7QWScWkdcZplbu)WI0FJ05CWYqm9cKCWlg3VWATrH0pNNnfNMPAfZ)As33)G7Jfu5zNqpcNZ9XEXlm3nyIFWH8)4VCMad8dj0)35KMGFkIoxhJhVWNglL7XrCJ4qk5tAK8imCPaFSfrP9ielTq2Rj2W8LcnzIZWY8Sb6XoRqehVQ2CwHifquO1tAPGcP6Wrd8wes3TNYBPQWvpWlQx4Q)5rq2y9I8SOWdQhviRdIoD6tv6ajX7(eihkCdXiJHv1kt9Dc)wKpbvuEYRWpcyNldVD9YWBLipocI5ojZBZsvF9u2dt6dxx3n)Qpbs2ZZ0CdowJ1kafu3Oeqj9kM25dGtdlUpdgXAjsl1ZD28f(Gb2Js7nrDNFsI4EE9y8dGzZfHRzeb(Hplo5xIwbWEn9Y2y(9nnd3VnNNgsz3KCFUjX9667X5M0AsR5WMFzxJZCpBhGsBsmyoM5)HTKoJBMMZA0fYqlU(vaVentMsXTfaEBp5Xz8ZxQ8ilzy29gdbyBExVm02fZ0VoaP6DiJLtH43tamqcavUBAgzR78(ocFsERQEN3mY1foN7M724UVze30u1J5XtDyXVCC997ImU9Bg5Xj278DmsTMOveBqfi633Ju66OnHh3w3FHchi3da(IhyWD1fINcLKUDaoeLNdS7d9zApxhVzZXdsEpv(dl2fEF8QBrkFB5vcw9BujaAETF5ROSMekt6v7NUQPgBMwMy9ovvtZw3FBAEOoLGg9dEhRpDUOgILUn38Klo1aG60MPPmkqFHe506oWJLuMsBwSMEY3oC1gUrkdDdeNS7qODSseHyv3tnI0ttzm7dg4r516SUNtUrdKywlHbBDI3mZ46C8kfDNvnux32b3Iuvs3WTqbNudzQEy28StllhQFTMkIoGsl)1ywDR5Clsv8CJzcrNvPh2b(TRN4gEe3rzPRqVrl85LKvlmrqbI(NhJ3VpATptHm(k1qf3ATICcUrk7ieKWzhPB2eLCaeKu08H0CksMyq2rb)NVXSJzT6wURzQiZg6xyioBxaVd4KY9Nzfj5sQyNq8AS)V9AP5vPGFvOv7GyxoSvdj324lwE5RcelNrsQuh18fe9(oJ2LqH9YXkQ2N4PNGnh(k)WsKJumf5DFy3sXQx(p5i1bHgcmlfhvJuYFyzIJ5aqFhhndRNHUQ09WLhbeq1GRcgP4Fu3t4TsTTZnlx3AdpzSv7CirCbjv5GZshQn9rBQs2ASCEgbIy8)dZggqi(wCHCbTw5lEt((sy5Ip78UAs3kq6Aj9rYfvSvTVVQokv5wpfyy(r1CuQCzOvQHjW1I1jmnQiooq0Q4ZEJrKC3LMNdl)InBdFoA9tm5P80VfN4iGo3(3i8ZiMSkZf77edu3teThxxwyThqwztTXzujxTNRv2lTNAT4q1UjHKUsrCScTXsHERqLp)xUMSpCtzX7lg2)1bG09zXy5h9UR2drV1hlOcISVxPoMq)gTg9AnqA6UatIcLdYZz59dqEHCS1tYrLRpUVDRu8I2RdePuzQS07BoAwzN1nWv7886UTSWmqPy8YYHE0JdM2R(iw6bb2dAi2CJMgd6P4AQG)0ArXgFsqXoTWZXUnySDSHnLXBX17d9(8U(gFChl7Huo5PR8SxZUS6Gi0rnzrwVRbkPwNQoGTNVlHkoDg)MOrAnWUWzSuiLgDPW0WRfG2EofT(fOGYBykvDuE8shwBr1dFW1nF0R6UyIwec)wV22DxutVZFgkPxRrF(KQbN6ibW5Gn(2dQEQrUajAGI8UEPpf5SmiPxVNuaBITXkk7P5Ex79inp1LMstv3weLo9HD1omJdPJ4kRgXDoW1AxKnaNDxppjmonT04y(xjFflXv6tEZGu7ykYhikJOOkVyv4AdDfeVPqJ6KuLIk6DhDSDNFSs5UbXd(Xi7gz7411rbXn)XOtn(c8qjHiT4lgAfrLaISjoBCfsqt0c6RVT06fhNrMrq8yP65G((k0VDwWAQ6p)OywQX2uHsTFTiRDTfTHqvdVS)BHNP(ZgnxCDkGjyhN5VdS)oGb0s5AhMYZLp8Hw1fGLekmBCOh(xg(IMEPkgd6Hp32S5IslZmOVeWKtPQapK)uRQFKID8LUS0BIoOiudJuWIqV6srtyVWbC4rGB(5aGRTEyGydULr84UiMwmWXA7dVGVpHvjy2Bu81l)6HG3mpfMXmvF42B(h)0)5p)x)5)T)4PLNw(Lha6r8U9Pz5qq9PzNw(d6BX)b2h77Im6XoH7SGicpMNUJv3sgXlm5E(xq8)9ywIhdGP9tPjaaWF8pu63Y)9pu8Phx83v(Va)o7Bn(F()4Fh2Bf8TEIjA45AIcAXmvobN(SdAvLY3gsJg0Cish3CcAsvfOzq3h1aU6ZDJa(K(jtIwjoQli0YP5dTDAiKQ0Xor)tiMU6FPnce5nJyp6vbofZXKMlnP8(6K4M((bx36jWj9SYOwZOQJBnaHtrR6ydXei(HwGsffhSziulftW3dOZU8ElLYS8JNLzP1BVvLa1zyEpn4uOrTKE7RiqzxJ(6KbAQqD73LI)(nztb(m0mQkHbbpqdc)c0nf0IzYjNomnQzC5xRYCd7UnEcAVCYPp)x5ip71cgw4nlRohScUZWqWr2J5pWo4s3eV7tSIUNUjMvr8)WF40Y)bW2FkCle69PL)90Khp9z2V(thV)i7lT2WG3Z6VWHdzRc7bFQO1r)Jf)f4f)xa)wF80Y)cBToTmDd8ppYQWTiNEaCKEF8Q(6VXnLjXcMtwwSoT8VXtJL2G)P1Rl6bmELVy8TiE8DmsYUWeyH(0FIfWneIbNBk)AXjxv0CbamjQSD9yU54Dq0I8sXYev(A4oiEYnzP7ujkF5tGt9aMLuqiUAW1xfe0VIE8NlYvpdizQ5IoTSAjVl6Ei8I(aSSAv0EgXjjn5kw6k2CCBftIpXBFgMUY)UVOJiUC2)cvpqGp6QW4EpR68ZqQ3)7t3pdIU798gHyMh9bXlVq2despQU)hK(rYEFqAmg99G0Z065bPNyPFhWPl1D1aWYoTKUzdWF9QttvbzLQJgWFxr9MEF8MzxG06yKVflb58xQCBpzRjykig9vElMuu3PCMUXq2Xwe2pasBHFnmEl7fRX2zghAcXJaGr5KpWGiSdkH8lOkgk6YDvHprm5ECSfMRu07xEr5pVQjZ00GHd60TBjjTkmTokt4CYm81H8jZdg07Lx6w)C)onctvw4on91NhmX9Qw2Q)Zg4y6ROqkGuVEoySGd1e8v9ea7y5lbZPd7ac)SVRx0NaHPFGgOQZaOkyPMFh28tEubMRnyldD2eAiPovALGa2bg4LxUG(icapSuqfThf02hmD4aAGrQf515tE0S99zF91A0luTTycGdnPT(LXalTzptlKxnZFhSudlTgfnmoB6kP0inXoOVqVLXlLojQzAVooAWA41b)zu16mD21d6HdAxCwHnpwA9o3SuGUCnEFrVEolGbBgT1VZPrplNMth2TTGZPTOf0vMmUg2XC9jt6CHRthb3gArwB5UYxVGev979k5aUyjlZU9vW)F(SrD6AwhOPbOFidh3XEsQNg0FI0EqQQbnDyVox44gPGgrRRNMbUeqHlKMezF3fFJru8cnsJF1vqaL3jvQIoki)WFlI8U4YsYVYhibDm19ol5obGRocLSxYn07Kt5zx2vytpHLinyhGIoD1KhvnspJXnu5zQda(LEuWiPaZRdKNpCItOUJ5DqZ8Hd8axKPSr6N4cg4I2AkCLHJDZZlsvQI20l0CA2ZjbXMrJNOkznHfcZ98UMc4)ldcQ0ZPJCpbHPrwMbqzFvyyMcs9H3DgQlC2EdMhqM(DAOOQlEBl)Yl21p0ZXsROEITOMAZMl3LIksStNfuhxljYZM1UMDRGsVXp9J(8b(9DGyEVoDVWSr(a3pX1wreMIriGOQP7PGDgulmJlykEkvhz2Y5FU5Ib4ZebnXbYJnxgHOI)QxRhusWGwqSAOSwPhVy98I2sRjbHT2DTfYvhszXQElVwYXAFLF5yqE1Uq28rC8C(SjguqJ(7wiHr8nkv79T5Nhg3Qvo)6qbJQPvfRD6GGLHs6dO2mq050c6MTo9EEWh74qI8Qaho2PmADOZHBPAEIwzhw0qQS9Z1Acmewu7LA3mCF0201HAGH88AOR4Ph3BiqG21hKDMAexBo6uiLPZzMmGiaRzDhD5O35W9Bw60Sg9mMOzvIAr9QUAxKz7ll5mJuBl)Ervtm5mk9TRZiy6Qo5mxc0LC6q6JiiO5GunsxlCh7TNmYwOPJ6XCAQcjfTy4mfHkm31Qy(iz35Lxm8mRtxK(Bd)DTJ00Q)RelzbzWHTXi4LFgGk2I0bRxhrNs3MtlNrt6YfEViTpYz9vDy7jm25nilK0svkrr7jQlwBHxMMZO3HnBs(DSHPW0gUBek8PAiXhD3U85uA68HPuiBHyfUAlbGGVByhYuOlNtesNQG54sNMy1gKv)VMg0XQFEAkCMGsEu35HqCq0eH91DSJTVSJwQ(W0XwlFqVMiIGaQYsnwlhdFNXlVaEMu8P5t1YaZsIRlbjAXJ5J6HPPgh3AGVQM4RU3RiZVDTGoMYHVk2bVmFY8dcITBgvVxf)GvXlsp7lYA0ml1HLHBxyEZmk5qjP6xzxkl(IzqfYVDNtNoSNrLZK2F3ECWeuCeT8uqXzxcxBWCJPkcaeR2U8CH85GpT9qlhLjn5s8sYvyGXa17QoDJguVnwQyKUOqJl9McvSMLbfv(aaLGycI(ceNFCXBgIdWTH6Br8w5LjK97v6tj4BzxNvwumzE0nesD6GFnCqpezcdN17sKYnBbwz5Hcl2bOgcy2DiwptHAqkuTvpcgGnPLcD4BmGxH6Rnic1HiH2vE(Y1LqLHsJ9uTzhetHHkoF9Go(1YiZhixHll8gw3VCUfndGf3ujlJDFUxOr9o)0JroYJqpSDsTWMdI9V2Alv3VhbyP(npJbj26hbvzTUbFyWvOFR3ExWWbwZ2cddC1ifeoaGUHsPtP8rWqTrOWcXH3SfyAiW4UMKrR91X5Lo2m6K34KrVCWu)JurZXtE5fZVDB9CMpLPYPnTtJ4EDho4YHdEh93UiC8CeMBpYFA5yOicgoAagg2axO07Ll0mO6PIQzvHbG0jnmvyk78LIyMODdASBcnudCtN(EUYn5Spw5RSNzdywWqewLAF)s(XMP2gUJVhnUwbQolMTaNxBExB4h0hgGhfWaNqDmzZJ7fC3UfTUJZFdxeJUtV9RfSBMwtKtaHSv69cGAKKXhBGCGEJCsfjOtF75o7r5fSnVBb1U9CPO0hSEYecNnXSeIzHqLFPD0fSYLeKGjnKtzShE0GgW7ubylNOcZSrnDyHVq6FoXmszrG24k(eI1wy0Q(3UEO)vpxlZdmnzhNaGsVsrwuRNDT3xnU8yThr6wq97qLaG)97IB9bzdGt1cVP7kBltM(BU1VVWtxFHSCob0FdSyeko2O9TVcxSZgOEqnQtovw98K1qvwdhqZUKTvAQk2w8u8VEuyjKxv9iZYMtHfZvg3gW1iaK63fQcJHnG4mcfX9xaR(l(039LMTBIV8VLRCaksl(kn9MU0ykNv(Eoj20rgcoYmO9jFcJWko4ISfG8l9KZd3GL0RYtpaI2p2V)EKVutSTwAFtMu(jz4u)t)KCf554yrdapt7Gtv(ZL98vXX4kEZ7zLTkM9YwY)K(HBYOV8dCQeOd5ltRVVyzbL5hCS2TyUrjzTkBH4lGUSTybm1Nvx6dfwe1eOQrQHVSIoLg(UQAfA6lRVVUHVVA)2rnQ30KQ6scVzzdSzHsDgZAQjXQWuFJiwEz2VLGZBxMCp)uSgaIe5ai4AYLdlpWnk3UutS)jiJyxAdvQ2KuB9wSIQ516TyfSMlP3If8xPSOjGgSSu9wGNij95TyzAyKJeZsBcF0rKJgR0Bq4JEeAyTdeYhjp6bvxzhshc0BWb0iey2jl7phvTPSYT3L2VprYheprPLqK(1VxLyNLHkTU3zgdjoVlUQFcg1dxq9R(NEzszOFHVLH6RhPmY5niSkg6VwbEvCq5N1GELKQZilMPl1pprLoASQ6u7iCZW58WHG20L5iZ1k5tMr9GrhBn83CGsdoQNGkg9mJJsPQCGqk18vV0Vo6wpV2iDpyaRtri28OCSwKwAF6(B0J8I8EhDC3auBnwZPIw6JD5T5n6GZqL7FNDRW8H(qdK3WQR43kxQ1ukpVPa0Hz)1omfNl2iYE9LDZdvhpjFryLDDsN6I2RJ7xPlUdohb5yScIfIlTDCu1qj8QFRF5Dq01MvX)k9jcO8N093N7rKpeMwBv53Gunpfri7qFBNakFol(i8SkOZL2r8ub5Q(DGGcs3wvtRqBRNQZn07g0)dSZpt02Tvm95bYg7SqnCsmE9aMUnAfiZtD74wbrHnSHwYBUAiA)5PbpYoc7W)0kcOUJOlE44UWK04I(fazVYi3TdpBxMJnudFVnVHDvneB2lzdqJS0iZCouf40hdlhKUr6xUmdPcVO63R)shPIrE55hzaT1wYREMu34q2JHJr6jzlQXW8T06gsvYT6grSwtfr3V2r(x)aq7rRgOKZZldmoisQp21D4YlECVx43bv8)NYrq58wfmsRJ4XHStXWKLdbzGgy998(SGkyh1BKfpw1XDOtd20jD00z4Jdrt6OPXqxQyIUjSMEZPOFUX0zenlcdL4KYD4ZUolN8sq58DPIHSKIBHyp3W0ENTTBu2V9L85Gb2LY3fsEJgC1K3PISUCbW5zOzURliJ5d9WtMrUMKId9Phofn31uvEYshRR7f7E5yyvziniLbAnD60F8v5mKXfXmTccFOboVIacCpj(Yt8G96lpP8IEAIi8kHFz6QVA9UlT5X)7eOsh)rU9AQVNA46hi7Oa0yOm0B0m5gFiRGkf8R3MiZBmOxfWGTbs5EFK7HdkSOC)3OBMB2R)Qz0yoV8CDxnInZocBG0BEKPQzCGxBmvC5uDOyXtQ3Ky)wgk1VVsgBfS92PwlzxhzAXRZrliRO5o5vJr6E7mQ1S9270hYK5NlGy7JjDiSBWL6UT2Z6u5SexZgqtSQu6oMFdWy)UPJ0QK)8uVDX7mUZvB31S6lPJ2kcv5ATD5m7MD5FWjV9)9]] )


end