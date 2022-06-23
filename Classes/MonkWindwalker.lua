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


    spec:RegisterPack( "Windwalker", 20220621, [[Hekili:T3ZAVnoos(Bjyb8y3PJplz7mDpW2a717Uh2E3DoGlnWCFk2k2YjAITKxz5Kohc8V9JKsKIpQIKs2P7(wCFzEelvSy9(fPUn42VC7nRIkIV9xdhego46WG(b)CyWGWBVP4LDX3EZUOLpgDp5)inAl5F(BjPREoAZJX50F6LnzrROGyF2H8LKF(2BU7qYMI)A6T3bb3bdjp6U4LK)61F82BEiz1Q4YhnE)szGFCX)il9XJF(ZhsJpUim49K)bboh)8Xp)PhIYVpE)VC8ZxDCXxEoo6XJl(lj7l2FCr2AY)5H8xoUijTiop)WUIJl2KDFYY(Yp9n7ssttsV)4IpLhrH)Flz5Jkp4FC1QJlUlB)(1j3)abglFiE5JKfOi74ITrPKf4t)PJlItlYtI3l9kjPxTmB7DrKx5VSjE)dlZJwxu(73C4U9frPfjrBoUip(POT7oUyDE22JlK32F5tX50DsA5g(QbxFvqq)BVzdDhsP0z7Itje)VC7VY4DXPr3TjE1T)73Et0YIKS0BVzn5rNNTEEXdXZF(HKI45fj3t5xlZj)p5jrK)Rhs6Vn6RhxCfDVLCCXSPhxq4nlFz5gYJtjWKvJScfeoL2YudLIOnesqFcaMF3H89f9REQJl6Wal4sWXY4VUlEZCcVClDrgISxyy(8DrB2QG(eAC289eQ)JX4lwi8(ze6(XakLaHJl095ZrpftbYykqa2ksaM8ux3SDL)BIIBVHikVllDpLrNLVcwIOg2xqKDl5w7JZJttkEHZSikKe64Yc6BxVvJ2SzE5)ZCQKxP838stalxnFF8AVenotlwjqSjNKNSNOqpF)H05psuM9JZZF572qSXLDOG)QwKZYY2Sk750(uDmgTFnXCt)84TrjP7vFenus5HU7W61915GZF(5(h2X(DkM9u8CIM(wIbMJlMCCXi490yCPzDKNTORIsxgtxsIe2VNqwVAYW(kZIZxsTkwsmaeIRxbl7cvRrckffE)SSQdX(u(g6AUkp6Ec)F3H0LpOPf9b)3I60nMnhxuCNuGpEsgAzCpeBRbd83yeDVeGz)max1heqDjW64IlbOySFONQvpM1D2YORX70IgZi6a7SaHMbvm)4IxFLHF1MSiK25mwDTdg6ZOY971yhbb6gt0KSP7CQV27FPpXZnncbcXz4agShFCX70jEoLJcoDdqgggec41(ylPowf4bjhk(0eo7u1fdywderxD7nssKR38cZGxCojef(Er(TjpUWwUvVvmCx47qw8iWIHfCVrgKXUOMkOKoyDIomrsuZ7ul39Ckc4V)lqK3p)A1Vl4M0cj8BV3KMRcakyZDC6277mu7b)SIO98K16cIh215cl8Fm6AR9MTkMT(3LLgV6aXvZD5XppV6p6bP(BOBRgYfPkzwmVJSObY2NG2Z6gBKJDeWEt2oQ9OckFMd1NIiyl53z)xvrGYbrLxqZGCtsFk7X45F9qCA9o4POnhikEB2t1z5YmWM04EZqFOk3omR6KCszYgSetNldNWbvRQNl4U4I(uCwxoOFPrdv1PtaPSAzMifWP59FGSwmQOBOoUMLjr9HmWwVuI1rNHYHe1wgrcnAZCAgj2nS6ey3TjlBLh2vDcO1j5XmGzpwCNW5U4CYp9irLryRRLak6EM1dsECpUxyrtqeZxs1hlYYjVDHMTpDls(OkX9xRjfmRmg2pugow(H041zeRf9xhrafz5pS8HAiqcvliCalgrFL87w5T)jcqiiwA8Y8SnexnsbxPyxU0)Vi4vHIJ0oYy5K3mABVE1U6mxghAhbduIeHrlOCSvXrfp4iRJ2Wh(4apjRTeVFKKJtKJKCQ9M0iuV1IqVvCgRwkBZo8JUTrhCTl6oUrv3XBrwG4VgV8atAG6pLVogfWYwgs)EwXH07JtYZjeR9fjPVSV0kTBlxo3)uhNLU6rxfr6raOgbmlZpuq)7Z)NhigloSL82pLqlh(5e5SSoIeZaqVNZjYw7liIQNx0rcU0Lx3HcF5jgqZxYQy)Q5rPjBJMFxubbjE58In4ldf50J5wee5dreH37ZJ2VJOVxeRu8It1Cw4arGU12wk1DZ3t4CBOVrDaJvbBAGru8h3VPtV13VjAvseXD8Ecfz19mMviw470DkjEdIfT9j3NCMvU0bofrSAqxSKmUqw68d7JPHDK(yCHwmZ(6LLZtmJ5SMiqxfYBVLfBtiwbVIJYlEGy3pIXnt2UJ8dFFX)sQmiEr3idLJsBDer8JeMgr)D7oTG0chP(KB2qXEMfAThepQwBEBgxhKKOaD4(VUEa)366kDKGbs(MLsAhl)QQi2kHUxA7nMFfGYVylDp5qg1jvtL38VnONzqN9ucfqjahglhpbeVIei0P9IaPu7KB8tOsBduZbrtSeVcl7ZoS5UK0v93r2uhi(rJPv6HarL4OUWdYDhDXm6whlMD6VPxzjbQ8u2MOIecUSpBZtSuMKEWTBJPwVJ1QZkVZYYp79BYUlAd9bll0AbujpK0qPO5U8KTen7es4U7ioBynNMxRBcV4JCPV8OKvZJPyx)OvR2tKVyIpcwoyxC6V6ajeHeANSjbppO)hk59LuqlnCaULqwRIGNfN0X2b6LeIMxjeE1F72v4xaHsDjbfHYsPnIF8TZzM4jr5SI6onUwYZw5cHebz)G(Io)HdBJsZswr2xV(Av7pObUtchz(2OVoz4RV6svFsO0Za2P0jHnsmhOumclb(vXXoNVE3cWG7Vm7qArzftzpJUqUWhhI1b5F7X57YZwI2MgS0qS2bbRUnfHPI00EUAtT6UEX3Lb3ib4efp5XxiOrktlbAhHL5Iwv0R3pEyrsLhdBjcurMVznL8zlGCQSmJc8Q3Q33rQ77a54rGuDXssM1z2arWbMEjHEy6tAVJbsOJIL)Nz9pbM5GxOqyJUM1eHPxLU6qsrFsU0lpqS3qssR892RiJTFx8Mn81xQTBw04MP0sqeBV4beWqzQp(4T7IZPjjTmIeXCcHzj1Z3GshHnqKWlBjgVRG74gJgzOucwQ)XShdvVwjOrCTAbGm0OHLohRoab5eSM5q)3JwfpNL2BAvzOXtSLrhYpS)bXl(m1hPWyjuyesgd1FrWYEkBO5eBiwdh)c854WsqoGacZDt5pGyMKNgj80satFnNfU6Pcbp4MlSzVrgy8bRdTcGN0Ka6riuimwl54sbxtNrepqednBRTY2RqBMjcE1nqfXW4bqLN8eX0t4EjM57smrFjgz3BlIr6YepLRCpiBlOmBBt7z)StpmOvF1)Wt7Ap(l725BcPpWls)mZgt)giY4Tuz7fzgkezy)VJLKcKI1gn4u0cBFs2JqwllZgIdViATD1ErJD1ytWYcOmFlqt6LYqHzRkZ(Rt0mMTWq)U84NMF)Yv9d6xZLGSomEqznNGzhgvNU5BaCRrD4vafnTbKDbSCArDX6Sx3h3QAL4hXZfzTpPQYafcXqDgeGbv2JWdCaU0skrpyB8XjPuq8TwYgSxggpRHKtxbyXVyl)CUc946fwnpkz7Ge6gJ9ukezVAeJuvJ05515fZH7LnW)aYlaZXuQXl7fQ82b)4YU(0LJOzyaRXIvBe0kjGlIsuo3htO(zPh2t0)IZd)W8WDlz)wvc1lJYFI2KL4xI1ZX2jxruIe3jg7zvt8CtzoiE2e3KTfiAubTsr7iXRUzdw0y1XL6E7zxgU0bEzvzenrHSyZzHTT3NkVI5a3JS(WPKG(JrsoeR7ZWrq0W1ejucCN)iWVI3cpNMEWTBMKuVZK4XuMPa7ca8bbDTDhJitIyh4yLKn4HTJfg0bM28jyJTVv2)r1ULw3t(ht2r2Hfg96eX4TLNPQiO8KLA1myARrnGKYUwxPHduv)zZXa5jIw9IFmcHFqofCeQ8AvblnegiIpc1bq7qa(PKyDUWqbxfDtEkS7o2RNGbyqdnS3X6JzJqw8nUf61j(cvWK1hib)Lhxo6pvLrv2LaW7ypmWU1HEckzGx7gNpGsiqbwCPj7P1cM4uJXCAkcgGVSAkiUTaubmr)l3qewNF3lZJ)A02DeGZPV15nPpob4ZxT1DoIvK2BGyQNJGIDzXsHWY3zGM0UDbIkoZBSMKJHrPsM7TB5hkTdFlPKYhaounvJzDXAAK3T6UsdUqzz4tmeiLCXHLzTONejnO3xvvL3HOoMXZzOnJwm5pEcdpT96F7ueSd3a5)AoI(4TDTLZb(BjZ6uyeNcrcVCP4tiWOQcaJ38FV0gvBCBNwin1TSnCxw(VENpdjSpeTHsHLdnH94jgIqW4hYltcMuQ0YdjkuNwL6AMxdmTh2kT74yQAsPGhx0s3kA2sLzLwNZLMhxAR8A28LrtkgR05t5Z3NwELExhpALQdDhQTrRX5VGphPdNUbAfn9A0WJ)G7tlJNNweS5gpXRtlIx7BVqslRhuN7fMoap1iNp0s70JGv08)VYb0aRWZED6x8AF0yHCpo4x(E8zWdB0lu3ZP9g6KQG39v8tQckoPOPpULKvuBhdh0ecUo(d1936mtw(aRhurl)NhiwvxnVGKB7(d50RCe8c7orzUxeV7ZeJZc3FgLSI3Cg13j6RX(evB92Zgkd1BAH((YO8sNve7dX5PKOtPveEDmuTbqF45J8bBPrkvPtJUQ2AJ93VtaKT8JGmW1ItlKF1j)hVTfN543H4s7OUkTln1VB0PCgQkaUmfEnCNCc94W36lvEOLka5HUnNSzErjeA5s177esQEbmy5SQ9Tebdgi3)rPl2bFoyvFlWpj)XQxyeH4vKW1CvkaO(fhrOYnhblCR9Z)9dRUFR5vhriEIRVbNQlRL7aOGgLB0VTNWRvXRJoSPECFe(q3rq85pqXB(LgLkLuJqwDn4udaUCJ51jJVsGAcwuHoT)0vn1hXKQQs1HxKABdlPP1760OngFYow)16sZt3folabuc5tmqOoTbmvrT6lMixkKbESKYuAZkD2t(grQ2FlqR0AG4esZD8AxjIULpdcYv9hVrWFWyFuDvMQ7aZ92aiE7kCW28Sm1mOBhVs5mouJ119SdQzeUXBHDjP5xs9iH45Gjv9O(nhxa2aQCyxVZQ7RnuZkCVZeIolZ2Vnz5C9mkzH4hNNTe8CH7ZljBwySGcetYXz3U4v(ac59RuFkTxZFb3iJowUPm2r261XP7jcskw(a6SR9s0r(hFL6(XA50D3WHUCpN6h7ENDHZwu)EvfHPLjLl1PGDzS)T1QD7vBuoPDvRqyBvoxdtUTX3LYYNNElNyjSkM38fe8k(XYLgn3D5ifl7J9m(TMJFv3L6qfcvw5t((3ueIMYnObunm9Cyg4)yv1Gylt7NVzlNxP6EQWKhjBav)Tk7iLWJ6EeE2dTD4ZyMwB4XlJR54MKOC6ZSuEs0dcax2AKu9COeXK)hQlmcH4Rj5GfGeYcIEmOnxqS(kv3Yza58UAsMcCCkm1fB9CveNhHcGIOzTSLdB(wAVRYwbjW1I1jklUm7lIOv5x6bJ8VUlROGS8ZxVj6L4vptLNkY(As6jNgMimJe0E6uQ3jEq9ar0(56MWO9dOTdq75mAgI2VRvLBTF1ADTRJscOiJI8oewJLsywHkB1OSPfretmwN4Nk1snZheVsc9tzywDoxlkfLSorY8OpCFlTOehRxhShPrXYYOB4yk8atJdmRBKMq3MB9fblh7mDa56qXTcWz6bQWR(frqDfHqVUzSqG9GgcbBWcjGdIRXs)sBcBA4jAcLdaDQ3MbDzhy74Vzk6B7AQOf3kkD9n11owuUuobv(o6exYhW2oQ1XX6PMTIEDKFqXA8XcIrqHVrfKOxqxCcwsmTrxUbyn40JtIttoVn4HZyjGumtDybD6ipn6w5n8ofbxsb(Uw12DWb6a6uhYSN0WUwVv35w8u(ODaZbB8TGrnsdCqOBGH8UEzpfyuCLSR3tkNjH2QIXECU31E)KMNEitPj(XBUkUlOZI8ugMoKztAil4axRDzc5oho0QJuVdxlwsAgoT7LYxviOh3tOJNUrsnvN9FTw3uD41ppxOdQReV4r4kiDSD21xQCg39Gnn0Ut2oEDoSrob7dX0Dl0QjXBX3Poo5fb3SjVBCKOXjFb911BTEdjzu9cGyx4)oXHaN(0Wp5EWM)8JGyPlxteg1(Er16AlBdHPgw)Y3q(n1)SXq7vxfwnQnCGjVjF9b)xaMYPlkxiF2zSMTluDGG8XbE21O7nWk8WzcGNDsBqZfvvMWJFR1ixvtX(yKCTI0orCyz76)ThbWof2idMqpAADAleo9(IgGfVDx3xq4hYPLVfzp6H8H)iatpH2lw6Qw9bZLew(nphLt9jV)2B(T)4)1V(x)1)JF54IJl(YdK9EY2Dz5fKK6ZYpU4N0vN)j6Ny2YIQrpGM0KiIouKTL25qkHkk9E23T2)EcT2FbeW(PSuccW(5FQkaL)7FQ8dER4)NhOc5Vt)c3(N)p)7eDRGV2taOWZfGcAbKQaWXp7GwXn02qA0GMJr67nNOMuH5Bg29rnKREE2f4N0FYKOvTh1feAjy(qBbdIuLo8etWGaC1)L2iqu0mI9WtcDkHX4MlnP8(6KKM((bx3Aa4KEYDQ1mQ6OwJqWuu(mtiaG4p0ITuz)5A2gQLIjW6a6SlVvPuGYpFwGsRvVvLa1z4EdgeRe62a9KE7Riq14w2mzG27g78yM4uukGHqZOQvSAD5op2giXf0c7En2lCuwCZ4YNkxYWVBJbWPyn)VY280xliSmOvA7mO98MUdPD6oBDcTn0)H)WXf)gHr)C0gsY2hx8pYsF84NP)1pFGjSh8E6e9fgsHk9p)PYH18xk))irO)fsCQpECXFHc7JlYwt(ppqBQSO6BK1n7(KL91FJBQQofbM0YtDCXFJvFkTh(pUAv5yxX60fLpfZYNJsc2gLswOp9NOjttsFGX9KFTK0Rk7NpbNentU(zU5WDKSdzTELkA8u0ws(JRZZ2Qss(YNibXt2zPLeIRgC9vbb950J)CzT5Pij1Sw8Xf8L8U47jzn0NGllxgVJsCsZsVIwEI1h2WzkmaV5fc4Q()7lgcHlN(VHn2bWpnp)S3t7X(uGwS)(SDtjPT9E2Shm1Jrp41xrh7aPFQEKdK(JOJBG0ZymQbs)M2ygi9lwgXay6s9Gea)7IMa9(K1tVayKQqFlAvRzVuLUi68cykTe)eB0lkBgub1GfzrOMQsiIerpfLSH(I1YftnocaIFYG1lMLBvgUi9wpgo)zknw(1xv(FVQjqAsq4GoD7wrH4Pc1rbGZqRywh0FzwWGEV(A36F3VzUFIYc3PPV(SGXUx1QbAF6ahGNtHuqPE9CWyjbTIWx1lYQJLVcnNe2Hilt)gWGpN9t(aosvxLnv0sTuju4Joq8Z0Eylp60X4ysDDPQqbOXI)1xVaFq4j)yLGky7(10dMeoahzKgeCD(KhJuEF6xQNg9cC1IXK9qtgED5DGLHjNAMZRrwVdu5xLwJY5IMcUkknWSAtSxOpz0vsNi9LSxhhZrm51jXqOA1zY0Rh0dg1U4SIBES06dOyLaD1A8(YrACAaf3mMEDNGrVsIMGd6UuXjylN0AfGXSWoIzpzCNlCDgayUe5vg9xeHerDzd3gX3RuN1YLSQAXxr(3ZMoStxZ(Qmja8JE1Oo2R37KG(JL0bX6UYKWEDUWX3Oh8nADpRm2lby7fuxI0VrxVXBu4M5HV)Ql5piVtQ0)Du28H)iU5DXLLKFLN7E9DQBnl5UTZmhbs2R4g6JfPm0LJS1mWwjsd05eOtxn5rvN0tPCdvEM6dq(l9WWrubMtdLNfo2jw3X8sXAw4ap2lYu2y9dwafDbNZdMXWrU55LLJuXA6fAbn7jqa8z0yaXL1eEim15DbcY)wgfuPNtg6garzXwGaXyppRktbP(K3DkyiC2EdAeqMXDAyOQl8Ob)6R2Tp0ZXsRyEIUOMwZMjpjGksStMguNMk6MNc1UMD)xz(ZN8rF(yq(oIyEVoDVWCy5iHFcBTcjnfJuabnt3tz3zqTGCUaz4PYCK5yD)5MlgadjeAIJnpeSmsrf(vVwpPKGbTGy1qzTQiEHMHeTLwtccAT7AlLRoOYI8X0UwYX6iAF5iI8QDHSzdz7ZzthBqbnMHAHegY3ZoT33wCEqCRwf8RddmQUwv82PJcwEu0ya1GaY0jlOB2MM6zbFSJdjYRcCeyNYtRJDoclvlsuUFyX0Ds1NRTeyiSOoVYUz4(yTPRdZaHS6AOB4PhlAiIaTRpEVuZiUuo6ukLPZzgpajbRPDhE5W35i8BA50SM9mKOjVURGrvZ1ImhyyPGzKgu43l6uHjNrzYGDMbtxvGtdjqxYPdAmIebnhKQH6wH7yFwFbuHMmShnOj(MumgFtveQGcxJZ8bQUZRVAezwNUadlg87AFtJB(NlwstYGHBJa2x(5aQufPd08eccs3UtRGOjD5cVxK2N5S(Qg2EcJDEdWcjTuvsu4rI6I1wgLPje9oTztYVdfMsxBWHrOWNQXeFSD7kMtjW5dtPu2cWlmxLGSbFxyh0sOlxte0GQiW4sNUy1EiRXFnjOJ1480m4mgK8OQ5bqCaSeb9j)QJTp3xw6(WKrwBFqVMiIaGQYsnwBhdtZ41xjrMu(zCs1Za1tIRR6hCXJzd7bzPgEV1Gyvn3V6rVcaF7wbDaYWtIDWAZNm)aHy7Mr17K4h0oEHgzFzvJMAPpS092fMxBGsbuIA(voKYY7sDSu(ThC6KWEgDots)U97btuXr2Ytigo7IeAduym8maa8A7kYf0FNetBpW2rzstUeULCLoym26DbG5Wb16YsDK0fzAuvivGY20YOOYmiOkrwbWObqeqUyqHWiCBybwKXvEzefGEvbwscWSRZ2lkaMhJeH04o43uh0dqWWiI9Ui1DZw2vw(rHB7aqVbuNpiRhOuO68EemacOvcDWAhKxb7Rsfa1bPQ28WFzguWktPHIvB0GOwnu3ZxpOJFZnYSbYT5YcVHocmNBrZaYIBAPLYUp3l0WENF6XqhftOhKMulC8a4eSTou1d(rGwQFBCOyITHsqvwRBWhgCf43eO3feoWAjxO7axttbsuaGkukJlLpcgQtdfuEoSjUaYcbe31KmAD4ooV0XMrN8EpzmqhuZ)aT1C04xF18B8tpNfvzICTt70iUx3Wbxgo4D4F8nG3Ndh7ie3lD0u9oq7FQXmG9pafv(RDef0aaBiiWCJ2goQrC80TkyZ)1YRb0MIo9tAyWVDQyGMvJZnntBCyT7KbwtE85iUgS0bGsNyaylb8K0mLNxlWOHrjAkEXKkbeY8Z04qEBi7VPGVNRITp9J8K)Q3BwlV10Gq32cohdyz7wfLcU6IXBkizyDvO5pMMjGU8aCROGmr3ughrMwhkXFLYbL15FlKyanW9MigHpOiEWHv5dDXvHvJ0zItnypgsUgtt)HL8jzT0(q9aujKEDC8kU99AkP9gBoSHGFiyuP8VppL5AJ9L0JsNDsaAe2CTr1f(Wa4cSnWjwNGEwO8cVB3IwFaQEdxeJdBv7xlQny047DIiONmmVqOgjz8XgihOFgj8cBaJZZjfGcT11NTnRRKSF2gT3n0kgoObudve2YrUZS1jtclZzx)RtNr91d0EUYViDTfhr)GVvNYL9pUCO5L6yHzgxVt97TMADJy8j1JIzdzMHdWljJSEPPJdlO)(FKWsxUSv)SUrXCvPBQQUt1vi)QqQWxBRosLiau7i)gJrQFY2ucW3hU1qqoH)QF1Fm2(MV00Oyyl)B5khaUPfFa1EtxAiRokFQ1y58BT2Jaqq7RXgeHvCuPPla6hHnNhTll9vIIBqf1L(3FpWhrnQQL2NlnL)KmEQ)vztEEKy7XYJ)WuoBq9u2vnXRLhI1K1VNMnEc9LTu4D9J2PXPskWPrGoOVmtKbuNOCzNhVzVJ1UfWgKK1Q2K4xxUflGP9S6E(QWIWaGQfPg(Yk2uA47QAvOPVSUEDdFF1Png7PEt7MKlj8M1gKMvhhTc)EkTlYKyjc2WFILxU9Bj6821cRZpfRbOisAAbxJUCqnati14ttTWaS)1WarlTHgvBs1hElwr1sp8wScwt3)Tyb)ovOdb2aviHgAs3z5coV0T3Geb9ivuKD73M0PBc(P03z8hQUbYOE617emyO)1nnfyaI6IhqhThSLHDZ)fLHCt6V(TQ9V0oHQ1MbZo)EYlUAaagt4JG6Z)p9YxrOF5LbhehQmY5n7kod97vgvL3)htBWiGJnW3Lq6s9Jjzveel5hgrr8doHdddAZHNbawlLpWz1pm4ZwJ)nhP0WJAaWz0tnoH4QYbcPuZx9s)oOkAJgn0qrhq7TlIYJYO1iT0(COwapjFY6o67DduT17Agv0YXZrwnVrNhqSMV6C(RMf6dnqwHv3WVvUuRPuEEbOOJZ(BDycmxSrK967WRh4N6sF3WkADshMS2BJ7709reJJaC68jIfIVTdWBvdJWl)r)ojczo05j2k91fP6pPhiplIiFimT2RYpGunpfrqBmJTd2PpxXia8mo25Y6iCnECnZY9aNq0AAf4yLWpoKVBq)pqpwGXB2Wz6ZcKD2zHA4KyC6iMUpAfmZtB7WEbbXnOhTI3CvOJjUDFHwGWoIpLta1deD(dh2gLMLu2zzaDLHUpGpuTmhkuHV3w0WUAZHn)L0hqJS0i3Comf4mgdlNp4H63zwHyPxW)71Fn0u3rEf5hAcT1EY5)M0m(HoeAJaoLfwmJbfBPvfsvYTQIi0W2dy7x7Mm5v4BxhBdKSsXmVmW48vQ(ZUUAQE1JRZh)o)1))uoekN3MGboqAEC2HvCmz5SDhOHwFlVMEWs2r9IMYJvDuh8YGnzChnBg(eq04oAwm0LkgR7cRPxiu6NewDgrZYWqjpPchXSRZYrVBNoF3vIalP4Us3tfM2hSTDNY(PxYGbfTRKVlL8go4QXVtDZ6keaNNkWzUU3FMf6rKmdDbKYZYUhbfnZfOQoW8J0T9cDDdfY7VObPmqB8eN8ZNuWqg3V84gi8Hg48MpjWnq8LN4b71xEs19x3yr6vI4Y0nF1ATln44)vDwvG)axkx1x)wm7dOJkayoug2nAMCJpKvIjf4BTRyZlcTtczGuGuUoBzr4aIlkxRx6U5ME634SgW8YZ1vqleKDK2aA08aGQzCGtnNkMCQowm)z1liXFKXs9RHPrwrBVdQ1s11balCFoAbzfS2jN8ospANHTMT3(G(aaMFHacPhJgqy3Gl1dBTNvq5SfxthGtS4gDhXUyRSFLBI6vYFEQ3H4Dg1C10UMwF3d1wriEO12LZS7292BIou8qw(T3CtY2pX(Y1E7)7p]] )


end