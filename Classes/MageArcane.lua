-- MageArcane.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local PTR = ns.PTR


if UnitClassBase( 'player' ) == 'MAGE' then
    local spec = Hekili:NewSpecialization( 62, true )

    spec:RegisterResource( Enum.PowerType.ArcaneCharges, {
        arcane_orb = {
            aura = "arcane_orb",

            last = function ()
                local app = state.buff.arcane_orb.applied
                local t = state.query_time

                return app + floor( t - app )
            end,

            interval = 0.5,
            value = function () return state.active_enemies end,
        },
    } )

    spec:RegisterResource( Enum.PowerType.Mana, {
        evocation = {
            aura = "evocation",

            last = function ()
                local app = state.buff.evocation.applied
                local t = state.query_time

                return app + floor( t - app )
            end,

            interval = 0.1,
            value = function () return state.mana.regen * 0.1 end,
        }
    } )

    -- Talents
    spec:RegisterTalents( {
        amplification = 22458, -- 236628
        rule_of_threes = 22461, -- 264354
        arcane_familiar = 22464, -- 205022

        mana_shield = 23072, -- 235463
        shimmer = 22443, -- 212653
        slipstream = 16025, -- 236457

        incanters_flow = 22444, -- 1463
        mirror_image = 22445, -- 55342
        rune_of_power = 22447, -- 116011

        resonance = 22453, -- 205028
        charged_up = 22467, -- 205032
        supernova = 22470, -- 157980

        chrono_shift = 22907, -- 235711
        ice_ward = 22448, -- 205036
        ring_of_frost = 22471, -- 113724

        reverberate = 22455, -- 281482
        touch_of_the_magi = 22449, -- 210725
        nether_tempest = 22474, -- 114923

        overpowered = 21630, -- 155147
        time_anomaly = 21144, -- 210805
        arcane_orb = 21145, -- 153626
    } )

    -- PvP Talents
    spec:RegisterPvpTalents( { 
        gladiators_medallion = 3580, -- 208683
        relentless = 3579, -- 196029
        adaptation = 3578, -- 214027

        netherwind_armor = 3442, -- 198062
        torment_the_weak = 62, -- 198151
        arcane_empowerment = 61, -- 276741
        master_of_escape = 635, -- 210476
        temporal_shield = 3517, -- 198111
        dampened_magic = 3523, -- 236788
        rewind_time = 636, -- 213220
        kleptomania = 3529, -- 198100
        prismatic_cloak = 3531, -- 198064
        mass_invisibility = 637, -- 198158
    } )

    -- Auras
    spec:RegisterAuras( {
        arcane_charge = {
            duration = 3600,
            max_stack = 4,
            generate = function ()
                local ac = buff.arcane_charge

                if arcane_charges.current > 0 then
                    ac.count = arcane_charges.current
                    ac.applied = query_time
                    ac.expires = query_time + 3600
                    ac.caster = "player"
                    return
                end

                ac.count = 0
                ac.applied = 0
                ac.expires = 0
                ac.caster = "nobody"
            end,
            --[[ meta = {
                stack = function ()
                    return arcane_charges.current
                end,
            } ]]
        },
        arcane_familiar = {
            id = 210126,
            duration = 3600,
            max_stack = 1,
        },
        arcane_intellect = {
            id = 1459,
            duration = 3600,
            type = "Magic",
            max_stack = 1,
            shared = "player", -- use anyone's buff on the player, not just player's.
        },
        arcane_orb = {
            duration = 2.5,
            max_stack = 1,
            --[[ generate = function ()
                local last = action.arcane_orb.lastCast
                local ao = buff.arcane_orb

                if query_time - last < 2.5 then
                    ao.count = 1
                    ao.applied = last
                    ao.expires = last + 2.5
                    ao.caster = "player"
                    return
                end

                ao.count = 0
                ao.applied = 0
                ao.expires = 0
                ao.caster = "nobody"
            end, ]]
        },
        arcane_power = {
            id = 12042,
            duration = 8,
            type = "Magic",
            max_stack = 1,
        },
        blink = {
            id = 1953,
        },
        charged_up = {
            id = 205032,
        },
        chrono_shift_buff = {
            id = 236298,
            duration = 5,
            max_stack = 1,
        },
        chrono_shift = {
            id = 236299,
            duration = 5,
            max_stack = 1,
        },
        clearcasting = {
            id = 263725,
            duration = 15,
            type = "Magic",
            max_stack = 1,
        },
        displacement = {
            id = 212801,
        },
        displacement_beacon = {
            id = 212799,
            duration = 10,
            type = "Magic",
            max_stack = 1,
        },
        evocation = {
            id = 12051,
            duration = 1,
            max_stack = 1,
        },
        frost_nova = {
            id = 122,
            duration = 8,
            type = "Magic",
            max_stack = 1,
        },
        greater_invisibility = {
            id = 113862,
            duration = 3,
            max_stack = 1,
        },
        hypothermia = {
            id = 41425,
            duration = 30,
            max_stack = 1,
        },
        ice_block = {
            id = 45438,
            duration = 10,
            type = "Magic",
            max_stack = 1,
        },
        mirror_image = {
            id = 55342,
            duration = 40,
            max_stack = 3,
            generate = function ()
                local mi = buff.mirror_image

                if action.mirror_image.lastCast > 0 and query_time < action.mirror_image.lastCast + 40 then
                    mi.count = 1
                    mi.applied = action.mirror_image.lastCast
                    mi.expires = mi.applied + 40
                    mi.caster = "player"
                    return
                end

                mi.count = 0
                mi.applied = 0
                mi.expires = 0
                mi.caster = "nobody"
            end,
        },
        nether_tempest = {
            id = 114923,
            duration = 12,
            type = "Magic",
            max_stack = 1,
        },
        presence_of_mind = {
            id = 205025,
            duration = 3600,
            max_stack = 2,
        },
        prismatic_barrier = {
            id = 235450,
            duration = 60,
            type = "Magic",
            max_stack = 1,
        },
        ring_of_frost = {
            id = 82691,
            duration = 10,
            type = "Magic",
            max_stack = 1,
        },
        rule_of_threes = {
            id = 264774,
            duration = 15,
            max_stack = 1,
        },
        rune_of_power = {
            id = 116014,
            duration = 3600,
            max_stack = 1,
        },
        shimmer = {
            id = 212653,
        },
        slow = {
            id = 31589,
            duration = 15,
            type = "Magic",
            max_stack = 1,
        },
        slow_fall = {
            id = 130,
            duration = 30,
            max_stack = 1,
        },
        touch_of_the_magi = {
            id = 210824,
            duration = 8,
            max_stack = 1,
        },

        -- Azerite Powers
        brain_storm = {
            id = 273330,
            duration = 30,
            max_stack = 1,
        },

        equipoise = {
            id = 264352,
            duration = 3600,
            max_stack = 1,
        },
    } )


    spec:RegisterHook( "spend", function( amt, resource )
        if resource == "arcane_charges" then
            if arcane_charges.current == 0 then removeBuff( "arcane_charge" )
            else applyBuff( "arcane_charge", nil, arcane_charges.current ) end

        elseif resource == "mana" then
            if azerite.equipoise.enabled and mana.percent < 70 then
                removeBuff( "equipoise" )
            end
        end
    end )

    spec:RegisterHook( "gain", function( amt, resource )
        if resource == "arcane_charges" then
            if arcane_charges.current == 0 then removeBuff( "arcane_charge" )
            else
                if talent.rule_of_threes.enabled and arcane_charges.current >= 3 and arcane_charges.current - amt < 3 then
                    applyBuff( "rule_of_threes" )
                end
                applyBuff( "arcane_charge", nil, arcane_charges.current )
            end
        end
    end )


    spec:RegisterStateTable( "burn_info", setmetatable( {
        __start = 0,
        start = 0,
        __average = 20,
        average = 20,
        n = 1,
        __n = 1,
    }, {
        __index = function( t, k )
            if k == "active" then
                return t.start > 0
            end
        end,
    } ) )


    spec:RegisterTotem( "rune_of_power", 609815 )

    spec:RegisterHook( "reset_precast", function ()
        if pet.rune_of_power.up then applyBuff( "rune_of_power", pet.rune_of_power.remains )
        else removeBuff( "rune_of_power" ) end

        if burn_info.__start > 0 and ( ( state.time == 0 and now - player.casttime > ( gcd.execute * 4 ) ) or ( now - burn_info.__start >= 45 ) ) and ( ( cooldown.evocation.remains == 0 and cooldown.arcane_power.remains < action.evocation.cooldown - 45 ) or ( cooldown.evocation.remains > cooldown.arcane_power.remains + 45 ) ) then
            -- Hekili:Print( "Burn phase ended to avoid Evocation and Arcane Power desynchronization (%.2f seconds).", now - burn_info.__start )
            burn_info.__start = 0
        end

        burn_info.start = burn_info.__start
        burn_info.average = burn_info.__average
        burn_info.n = burn_info.__n

        if arcane_charges.current > 0 then applyBuff( "arcane_charge", nil, arcane_charges.current ) end
    end )


    spec:RegisterStateFunction( "start_burn_phase", function ()
        burn_info.start = query_time
    end )


    spec:RegisterStateFunction( "stop_burn_phase", function ()
        if burn_info.start > 0 then
            burn_info.average = burn_info.average * burn_info.n
            burn_info.average = burn_info.average + ( query_time - burn_info.start )
            burn_info.n = burn_info.n + 1

            burn_info.average = burn_info.average / burn_info.n
            burn_info.start = 0
        end
    end )


    spec:RegisterStateExpr( "burn_phase", function ()
        return burn_info.start > 0
    end )

    spec:RegisterStateExpr( "average_burn_length", function ()
        return burn_info.average or 15
    end )


    spec:RegisterHook( "COMBAT_LOG_EVENT_UNFILTERED", function( event, _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )
        if sourceGUID == GUID and subtype == "SPELL_CAST_SUCCESS" then
            if spellID == 12042 then
                burn_info.__start = GetTime()
                Hekili:Print( "Burn phase started." )
            elseif spellID == 12051 and burn_info.__start > 0 then
                burn_info.__average = burn_info.__average * burn_info.__n
                burn_info.__average = burn_info.__average + ( query_time - burn_info.__start )
                burn_info.__n = burn_info.__n + 1

                burn_info.__average = burn_info.__average / burn_info.__n
                burn_info.__start = 0
                Hekili:Print( "Burn phase ended." )
            end
        end
    end )


    -- Abilities
    spec:RegisterAbilities( {
        arcane_barrage = {
            id = 44425,
            cast = 0,
            cooldown = 3,
            hasteCD = true,
            gcd = "spell",

            startsCombat = true,
            texture = 236205,

            -- velocity = 24, -- ignore this, bc charges are consumed on cast.

            handler = function ()
                spend( arcane_charges.current, "arcane_charges" )
                if talent.chrono_shift.enabled then
                    applyBuff( "chrono_shift_buff" )
                    applyDebuff( "target", "chrono_shift" )
                end
            end,
        },


        arcane_blast = {
            id = 30451,
            cast = function () 
                if buff.presence_of_mind.up then return 0 end
                return 2.25 * ( 1 - ( 0.08 * arcane_charges.current ) ) * haste end,
            cooldown = 0,
            gcd = "spell",

            spend = function () 
                if buff.rule_of_threes.up then return 0 end
                local mult = 0.0275 * ( 1 + arcane_charges.current ) * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.4 or 0.7 ) or 1 )
                if azerite.equipoise.enabled and mana.pct < 70 then return ( mana.modmax * mult ) - 190 end
                return mult
            end,
            spendType = "mana",

            startsCombat = true,
            texture = 135735,

            handler = function ()
                if buff.presence_of_mind.up then
                    removeStack( "presence_of_mind" )
                    if buff.presence_of_mind.down then setCooldown( "presence_of_mind", 60 ) end
                end
                removeBuff( "rule_of_threes" )
                if arcane_charges.current < arcane_charges.max then gain( 1, "arcane_charges" ) end
            end,
        },


        arcane_explosion = {
            id = 1449,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function () return buff.clearcasting.up and 0 or 0.1 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.4 or 0.7 ) or 1 ) end,
            spendType = "mana",

            startsCombat = true,
            texture = 136116,

            usable = function () return target.distance < 10 end,
            handler = function ()
                removeBuff( "clearcasting" )
                gain( 1, "arcane_charges" )
            end,
        },


        summon_arcane_familiar = {
            id = 205022,
            cast = 0,
            cooldown = 10,
            gcd = "spell",

            startsCombat = false,
            texture = 1041232,

            nobuff = "arcane_familiar",
            essential = true,

            handler = function ()
                if buff.arcane_familiar.down then mana.max = mana.max * 1.10 end
                applyBuff( "arcane_familiar" )
            end,

            copy = "arcane_familiar"
        },


        arcane_intellect = {
            id = 1459,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function () return 0.04 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.4 or 0.7 ) or 1 ) end,
            spendType = "mana",

            nobuff = "arcane_intellect",
            essential = true,

            startsCombat = false,
            texture = 135932,

            handler = function ()
                applyBuff( "arcane_intellect" )
            end,
        },


        arcane_missiles = {
            id = 5143,
            cast = function () return ( buff.clearcasting.up and 0.8 or 1 ) * 2.5 * haste end,
            cooldown = 0,
            gcd = "spell",

            spend = function () 
                if buff.rule_of_threes.up then return 0 end
                return buff.clearcasting.up and 0 or 0.15 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.4 or 0.7 ) or 1 ) end,
            spendType = "mana",

            startsCombat = true,
            texture = 136096,

            handler = function ()
                removeBuff( "rule_of_threes" )
                removeBuff( "clearcasting" )
            end,
        },


        arcane_orb = {
            id = 153626,
            cast = 0,
            cooldown = 20,
            gcd = "spell",

            spend = function () return 0.01 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.4 or 0.7 ) or 1 ) end,
            spendType = "mana",

            startsCombat = true,
            texture = 1033906,

            talent = "arcane_orb",

            handler = function ()
                gain( 1, "arcane_charges" )
                applyBuff( "arcane_orb" )
            end,
        },


        arcane_power = {
            id = 12042,
            cast = 0,
            cooldown = 90,
            gcd = "spell",

            toggle = "cooldowns",
            nobuff = "arcane_power", -- don't overwrite a free proc.

            startsCombat = true,
            texture = 136048,

            handler = function ()
                applyBuff( "arcane_power" )
                start_burn_phase()
            end,
        },


        blink = {
            id = function () return talent.shimmer.enabled and 212653 or 1953 end,
            cast = 0,
            charges = function () return talent.shimmer.enabled and 2 or 1 end,
            cooldown = function () return talent.shimmer.enabled and 20 or 15 end,
            recharge = function () return talent.shimmer.enabled and 20 or 15 end,
            gcd = "off",

            spend = function () return 0.02 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.4 or 0.7 ) or 1 ) end,
            spendType = "mana",

            startsCombat = false,
            texture = function () return talent.shimmer.enabled and 135739 or 135736 end,

            handler = function ()
                if talent.displacement.enabled then applyBuff( "displacement_beacon" ) end
            end,

            copy = { 212653, 1953, "shimmer" }
        },


        --[[ shimmer = {
            id = 212653,
            cast = 0,
            charges = 2,
            cooldown = 20,
            recharge = 20,
            gcd = "off",

            spend = function () return 0.02 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.4 or 0.7 ) or 1 ) end,
            spendType = "mana",

            startsCombat = false,
            texture = 135739,

            talent = "shimmer",

            handler = function ()
                -- applies shimmer (212653)
            end,
        }, ]]


        charged_up = {
            id = 205032,
            cast = 0,
            cooldown = 40,
            gcd = "spell",

            startsCombat = true,
            texture = 839979,

            handler = function ()
                gain( 4, "arcane_charges" )
            end,
        },


        --[[ conjure_refreshment = {
            id = 190336,
            cast = 3,
            cooldown = 15,
            gcd = "spell",

            spend = 0.03,
            spendType = "mana",

            startsCombat = true,
            texture = 134029,

            handler = function ()
            end,
        }, ]]


        counterspell = {
            id = 2139,
            cast = 0,
            cooldown = 24,
            gcd = "off",

            interrupt = true,
            toggle = "interrupts",

            spend = function () return 0.02 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.4 or 0.7 ) or 1 ) end,
            spendType = "mana",

            startsCombat = true,
            texture = 135856,

            debuff = "casting",
            readyTime = state.timeToInterrupt,

            handler = function ()
                interrupt()
            end,
        },


        displacement = {
            id = 195676,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            startsCombat = false,
            texture = 132171,

            buff = "displacement_beacon",

            handler = function ()
                removeBuff( "displacement_beacon" )
            end,
        },


        evocation = {
            id = 12051,
            cast = 6,
            charges = 1,
            cooldown = 90,
            recharge = 90,
            gcd = "spell",

            channeled = true,
            fixedCast = true,

            -- toggle = "cooldowns",

            startsCombat = false,
            texture = 136075,

            handler = function ()
                stop_burn_phase()
                applyBuff( "evocation" )
                if azerite.brain_storm.enabled then
                    gain( 2, "arcane_charges" )
                    applyBuff( "brain_storm" ) 
                end
            end,
        },


        frost_nova = {
            id = 122,
            cast = 0,
            charges = function () return talent.ice_ward.enabled and 2 or nil end,
            cooldown = 30,
            recharge = 30,
            gcd = "spell",

            spend = function () return 0.02 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.4 or 0.7 ) or 1 ) end,
            spendType = "mana",

            startsCombat = true,
            texture = 135848,

            handler = function ()
                applyDebuff( "target", "frost_nova" )
            end,
        },


        greater_invisibility = {
            id = 110959,
            cast = 0,
            cooldown = 120,
            gcd = "spell",

            toggle = "defensives",
            defensive = true,

            startsCombat = false,
            texture = 575584,

            handler = function ()
                applyBuff( "greater_invisibility" )
            end,
        },


        ice_block = {
            id = 45438,
            cast = 0,
            cooldown = 240,
            gcd = "spell",

            toggle = "defensives",
            defensive = true,

            startsCombat = false,
            texture = 135841,

            handler = function ()
                applyBuff( "ice_block" )
                applyDebuff( "player", "hypothermia" )
            end,
        },


        mirror_image = {
            id = 55342,
            cast = 0,
            cooldown = 120,
            gcd = "spell",

            spend = function () return 0.02 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.4 or 0.7 ) or 1 ) end,
            spendType = "mana",

            toggle = "cooldowns",

            startsCombat = false,
            texture = 135994,

            talent = "mirror_image",

            handler = function ()
                applyBuff( "mirror_image" )
            end,
        },


        nether_tempest = {
            id = 114923,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function () return 0.02 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.4 or 0.7 ) or 1 ) end,
            spendType = "mana",

            startsCombat = true,
            texture = 610471,

            handler = function ()
                applyDebuff( "target", "nether_tempest" )
            end,
        },


        polymorph = {
            id = 118,
            cast = 1.7,
            cooldown = 0,
            gcd = "spell",

            spend = function () return 0.04 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.4 or 0.7 ) or 1 ) end,
            spendType = "mana",

            startsCombat = false,
            texture = 136071,

            handler = function ()
                applyDebuff( "target", "polymorph" )
            end,
        },


        presence_of_mind = {
            id = 205025,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            toggle = "cooldowns",

            startsCombat = false,
            texture = 136031,

            nobuff = "presence_of_mind",

            handler = function ()
                applyBuff( "presence_of_mind", nil, 2 )
            end,
        },


        prismatic_barrier = {
            id = 235450,
            cast = 0,
            cooldown = function () return talent.mana_shield.enabled and 0 or 25 end    ,
            gcd = "spell",

            defensive = true,

            spend = function() return 0.03 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.4 or 0.7 ) or 1 ) end,
            spendType = "mana",

            startsCombat = false,
            texture = 135991,

            handler = function ()
                applyBuff( "prismatic_barrier" )
            end,
        },


        remove_curse = {
            id = 475,
            cast = 0,
            cooldown = 8,
            gcd = "spell",

            spend = function () return 0.01 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.4 or 0.7 ) or 1 ) end,
            spendType = "mana",

            startsCombat = true,
            texture = 136082,

            debuff = "dispellable_curse",
            handler = function ()
                removeDebuff( "player", "dispellable_curse" )
            end,
        },


        ring_of_frost = {
            id = 113724,
            cast = 2,
            cooldown = 45,
            gcd = "spell",

            spend = function () return 0.08 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.4 or 0.7 ) or 1 ) end,
            spendType = "mana",

            startsCombat = true,
            texture = 464484,

            talent = "ring_of_frost",

            handler = function ()                
            end,
        },


        rune_of_power = {
            id = 116011,
            cast = 1.5,
            charges = 2,
            cooldown = 40,
            recharge = 40,
            gcd = "spell",

            startsCombat = false,
            texture = 609815,

            nobuff = "rune_of_power",
            talent = "rune_of_power",

            handler = function ()
                applyBuff( "rune_of_power" )
            end,
        },


        slow = {
            id = 31589,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function () return 0.01 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.4 or 0.7 ) or 1 ) end,
            spendType = "mana",

            startsCombat = true,
            texture = 136091,

            handler = function ()
                applyDebuff( "target", "slow" )
            end,
        },


        slow_fall = {
            id = 130,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function () return 0.01 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.4 or 0.7 ) or 1 ) end,
            spendType = "mana",

            startsCombat = false,
            texture = 135992,

            handler = function ()
                applyBuff( "slow_fall" )
            end,
        },


        spellsteal = {
            id = 30449,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function () return 0.21 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.4 or 0.7 ) or 1 ) end,
            spendType = "mana",

            startsCombat = true,
            texture = 135729,

            debuff = "stealable_magic",
            handler = function ()
                removeDebuff( "target", "stealable_magic" )
            end,
        },


        supernova = {
            id = 157980,
            cast = 0,
            cooldown = 25,
            gcd = "spell",

            startsCombat = true,
            texture = 1033912,

            talent = "supernova",

            handler = function ()
            end,
        },


        time_warp = {
            id = 80353,
            cast = 0,
            cooldown = 300,
            gcd = "off",

            spend = function () return 0.04 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.4 or 0.7 ) or 1 ) end,
            spendType = "mana",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 458224,

            handler = function ()
                applyBuff( "time_warp" )
                applyDebuff( "player", "temporal_displacement" )
            end,
        },
    } )


    spec:RegisterSetting( "arcane_info", nil, {
        type = "description",
        name = "The Arcane Mage module treats combat as one of two phases.  The 'Burn' phase begins when you have used Arcane Power and begun aggressively burning mana.  The 'Conserve' phase starts when you've completed a burn phase and used Evocation to refill your mana bar.  This phase is less " ..
            "aggressive with mana expenditure, so that you will be ready when it is time to start another burn phase.",

        width = "full",
        order = 1,
    } )

    
    --[[ spec:RegisterSetting( "conserve_mana", 75, { -- NYI
            type = "range",
            name = "Minimum Mana (Conserve Phase)",
            desc = "Specify the amount of mana (%) that should be conserved when conserving mana before a burn phase.",

            min = 25,
            max = 100,
            step = 1,

            width = "full",
            order = 2,
        }
    } ) ]]


    spec:RegisterOptions( {
        enabled = true,

        aoe = 3,

        nameplates = true,
        nameplateRange = 8,

        damage = true,
        damageExpiration = 6,

        potion = "battle_potion_of_intellect",

        package = "Arcane",
    } )


    spec:RegisterPack( "Arcane", 20190417.2359, [[d0uD4aqisP4rKcUKkckBcK6tGemksOtrISksPsVIuYSqsUfHO2Li)cjAyQiDmkfldjLNrimncrUMkI2gsO8nqcnove4CiHSosPI5rP09uO9HKQdIeSqcPhcsKjskLuxKuQYgbjQ0hvrq1jjLsTskvVKukjZeKOIBskvv7Ku0pbjQAOQi0srcv9ucMkj4QQiiFLuQk7LO)kQbl1HrTyf9yvnzs1LH2ms9zvy0k40iwnir51KOMTkDBsA3c)gy4uYXrcvwUKNtX0v66GA7eQVdIXds68KcTEsPeZxf1(PAPnsfKc68IsnP2P2qrNks2aftuteNKIejrskSA0cLcw8RmFGsHGvrPafQNdukyXA8cyDPcsbdaUEukmSRLr7qjLhKDaEMEGkLgIk8Lxci(IPxkne1NsPWeMCxTDiNsbDErPMu7uBOOtfjBGIjQjItsrIWgPGXcFPMumQjfgi66yiNsbD08sbn4nfQNd0BTF(aD7AW7HDTmAhkP8GSdWZ0duP0quHV8saXxm9sPHO(u621G3uWQixVTbksL3u7uBOiVfzVPMi0oNKIC7UDn4nuAGJd0ODC7AWBr2BZY1MNWvKTgydsL3MfyLNWvKTgydsL3CO7nlgl(aZt4kYxmo2bV5c9EGd9lQ79uJEVdO3SUoisUDn4Ti79Y1bUPLOI5fK1jO3Im19wXjWyGEjQyEbzDcQK3gG37aVEdb9wheqH1BeQpAmeX4vJEpHRWBq49wSzWBcT3qqV1bbuy9gchR3lijfUeZAKkifEqyWsmkvqQPnsfKc8VeqifujvbQmrLpqPag88I6srLRutQjvqkGbpVOUuuPWxKflclfMW00jUEoW8pW1bMml)k79O3Nkf4FjGqk8dCDG6zyl5k1uesfKcyWZlQlfvk8fzXIWsbf9Uq6cnd88IEF(S3AJ3l5vMehERK3q79eMMoX1ZbM)bUoWKz5xzVh9EcttN465aZ)axhysLHA2S8RS3q79eMMovWbMb0zlaeSs6aiH3q79eMMoX1ZbMTaqWkPdGesb(xciKcbUdyLxu1cnRCLAkssfKcyWZlQlfvk8fzXIWsHjmnDIRNdm)dCDGjZYVYEB7O3uZBO9wrVFa4QdGejUEoWSfacwPcvzsy8M6EBZPEF(S38VeXygduLGgVTD0BQ5Tssb(xciKcC9CGzqnLRuZtkvqkGbpVOUuuPWxKflclfMW00Pc(IzaDEhkenjylVH27jmnDIRNdm)dCDGjZYVYEtDVfHuG)LacPaxphyEEzZkxPMumPcsbm45f1LIkf4FjGqkSeD0SGsn)aDeQsHVilwewkmHPPtfCGzaD2cabRKoas4n0ERnEpHPPtC9CGzlaeSsfY)6n0E)aWvhajsC9CGzlaeSsfQYKW4n19MANkfcwfLclrhnlOuZpqhHQCLAcfLkifWGNxuxkQu4lYIfHLctyA6exphy(h46atMLFL9E07jmnDIRNdm)dCDGjvgQzZYVYEdT3k6nn89Ml8h46aZlrf922rVrOIp8I5LOIEF(S30W3BUWFGRdmVev0BBh9(bGRoasK465aZwaiyLkuLjHX7ZN9wrVNaJXBO9EjQyEbzDc6TTJE)aWvhajsC9CGzlaeSsfQYKW4TsERKuG)LacPqbhygqNTaqWsUsnpbsfKcyWZlQlfvkW)saHuGRNdmRsmgYfnsHFGjHuWgPWxKflclfu5Gtw)6TTJEtrN0BO9EcttN(lY1ZMLehPc5FLRutksQGuadEErDPOsHVilwewkOO3k69eMMoX1ZbM)bUoWKz5xzVh9EcttN465aZ)axhysLHA2S8RS3k5n0ERO3k6TkhCY6xVTD0BXCr45ftpimyjgZQCWERK3Np7TIEV8fJnvWbMb0zlaeSsyWZlQ7n0E)aWvhajsC9CGzlaeSsfQYKW4n19(bGRoasKk4aZa6SfacwjA47nx4pW1bMxIk6n0ERYbNS(1BBh9wmxeEEX0dcdwIXSkhS3A5n1oP3k5TsEF(S3k69Yxm2exphyguZeg88I6EdT3paC1bqIexphyguZuHQmjmEB7O3hVU3q79daxDaKiX1ZbMTaqWkvOktcJ3u3BBo1BL8wjVpF2Bvo4K1VEB7O3k6TyUi88IPhegSeJzvoyVfzVT5uVvskW)saHuGRNdmp5Q4duUsnT5uPcsbm45f1LIkf(ISyryPGkhCY6xVTD0Bk6Ksb(xciKcgylScGywUsnTXgPcsbm45f1LIkf(ISyryPa)lrmMXavjOXBQp6Ti8gAVv0Bvo4K1VEt9rVfZfHNxm9GWGLymRYb795ZEpHPPtC9CG5FGRdmzw(v27rVfH3kjf4FjGqkW1ZbMrOADbgciKRutBOMubPa)lbesbUEoW88YMvkGbpVOUuu5k10grivqkW)saHuGRNdmp5Q4dukGbpVOUuu5kxPGosZW3vQGutBKkif4FjGqk8a4yXYyH3RuadEErDPOYvQj1Kkif4FjGqkySW71SiFLcyWZlQlfvUsnfHubPa)lbesHcvbIX8dxgukGbpVOUuu5k1uKKkifWGNxuxkQu4lYIfHLct4kYwdSb9(8zVv07jWy8gAVxIkMxqwNGEBR3SyS4dmpHRiFX4yh8wjPa)lbesHNV3m)lbe5lXSsHlXS5GvrPWeUc5k18KsfKcyWZlQlfvk8fzXIWsbf9(bGRoasK465aZwaiyLkuLjHX7rVp1BO9(bGRoasKqXGNxcisfQYKW4TTJEZIXIpW8eUI8fJJDWBO9wrVNW00jUEoW8pW1bMml)k79O3tyA6exphy(h46atQmuZMLFL9(8zVv07LVySPFGRdupdBLWGNxu3BO9(bGRoasK(bUoq9mSvQqvMegVh9(uVvYBL8wjPa)lbesHNV3m)lbe5lXSsHlXS5GvrPWeUc5k1KIjvqkGbpVOUuuPWxKflclf0gVNWvKTgydkf4FjGqk889M5FjGiFjMvkCjMnhSkkfEqyWsmkxPMqrPcsbm45f1LIkf4FjGqk889M5FjGiFjMvkCjMnhSkkfubIrvmw5kxPGvHpqDYRubPM2ivqkGbpVOUuu5k1KAsfKcyWZlQlfvUsnfHubPag88I6srLRutrsQGuG)LacPaxphyMelEV4Vsbm45f1LIkxPMNuQGuG)LacPGbwvfezUEoWmnRsUeUKcyWZlQlfvUsnPysfKcyWZlQlfvkaSKcgCLc8VeqifeZfHNxukiMVWOuGIDQ3A5TIEtTt9w76nRTGfzXesXbtSaedMWGNxu3BLKcI5khSkkfEqyWsmMv5GLRutOOubPag88I6srLRuZtGubPa)lbesbvsvGktu5dukGbpVOUuu5k1KIKkif4FjGqkybwciKcyWZlQlfvUsnT5uPcsb(xciKcC9CG55LnRuadEErDPOYvUsHjCfsfKAAJubPag88I6srLcFrwSiSuycttN465aZ)axhyYS8RS32o6Tnsb(xciKc)axhOEg2sUsnPMubPa)lbesbvsvGktu5dukGbpVOUuu5k1uesfKcyWZlQlfvk8fzXIWsbf9Uq6cnd88IEF(S3AJ3l5vMehERK3q79eMMoX1ZbM)bUoWKz5xzVh9EcttN465aZ)axhysLHA2S8RS3q79eMMovWbMb0zlaeSs6aiH3q79eMMoX1ZbMTaqWkPdGesb(xciKcbUdyLxu1cnRCLAkssfKcyWZlQlfvk8fzXIWsHjmnDQGVygqN3Hcrtc2YBO9E5lgBcigllaeSq9eg88I6EdT38VeXygduLGgVT1Brif4FjGqkW1ZbMNx2SYvQ5jLkifWGNxuxkQu4lYIfHLctyA6exphy2cabRKoasif4FjGqkCjhdRjdLbRFOIXkxPMumPcsbm45f1LIkf(ISyryPG249eMMoX1ZbMTaqWkbB5n0ERO3QCWjRF9M6JEFYt9(8zVFa4QdGejUEoWSfacwPcvzsy8E07t9wjVH2Bf9EcttN465aZ)axhyYS8RS3JEpHPPtC9CG5FGRdmPYqnBw(v2BLKc8Veqifk4aZa6SfacwYvQjuuQGuG)LacPWeldwktIdPag88I6srLRuZtGubPa)lbesbUEoWSfacwsbm45f1LIkxPMuKubPag88I6srLcFrwSiSuycttN465aZwaiyLGT8(8zVv07jWy8gAVxIkMxqwNGEBR3paC1bqIexphy2cabRuHQmjmERKuG)LacPaSbZKfvnYvQPnNkvqkW)saHuyEba9mnCPrPag88I6srLRutBSrQGuG)LacPanPW5fa0LcyWZlQlfvUsnTHAsfKc8Veqif44rZw8n)89kfWGNxuxkQCLAAJiKkifWGNxuxkQu4lYIfHLck69Yxm2ubhygqNTaqWkHbpVOU3q79eMMovWbMb0zlaeSsfQYKW4TTJEpHPPtwfAW4XmGoRsc9Kkd1Sz5xzV1UEZ)sarIRNdmpVSztiuXhEX8surVvY7ZN9EcttN465aZwaiyLkuLjHXBBh9EcttNSk0GXJzaDwLe6jvgQzZYVYERD9M)LaIexphyEEzZMqOIp8I5LOIsb(xciKcwfAW4XmGoRscD5k10grsQGuadEErDPOsHVilwewkmHPPtC9CGzlaeSsWwEdT3k69eMMonXYGLYK4ibB595ZEpHPPtZlaONPHlnMGT8(8zV1gVv07IFmTf4E9(8zVl(XeOEVvYBLKc8VeqifSalbeYvQPnNuQGuadEErDPOsHVilwewkmHPPtC9CG5FGRdmzw(v27rVp17ZN9wrV5FjIXmgOkbnEBR3IW7ZN9wrV5FjIXmgOkbnEBR3uZBO9E5lgBQqdi44Xeg88I6ERK3kjf4FjGqkW1ZbMb1uUsnTHIjvqkGbpVOUuuPWxKflclf4FjIXmgOkbnEt9rVfH3q7TIEpHPPtC9CG5FGRdmzw(v27rVNW00jUEoW8pW1bMuzOMnl)k7Tssb(xciKcC9CG5jxfFGYvQPnqrPcsbm45f1LIkf(ISyryPa)lrmMXavjOXBQp6TiKc8Veqif465aZiuTUadbeYvQPnNaPcsbm45f1LIkf4FjGqkW1ZbMvjgd5IgPWpWKqkyJu4lYIfHLctyA60FrUE2SK4ivi)R3q7n)lrmMXavjOXBB9weEdT3k69Yxm2eRADj0KNxcisyWZlQ795ZERO3AJ3lFXytaXyzbGGfQNWGNxu3BO9M1wWISyIRNdmBbRQIxsCKkou2BQp6n18wjVpF27jmnDIRNdmBbGGvshaj8wj5k10gksQGuadEErDPOsHVilwewkW)seJzmqvcA82wVfHuG)LacPaxphyEEzZkxPMu7uPcsbsSyvWwBMqlfu5Gtw)s9XtWjLcKyXQGT2mrvf1j8IsbBKc8VeqifqXGNxciKcyWZlQlfvUsnPMnsfKc8Veqif465aZtUk(aLcyWZlQlfvUYvkOceJQySsfKAAJubPag88I6srLcFrwSiSuqfigvXyt6eZYXJEt9rVT5uPa)lbesH5LeklxPMutQGuadEErDPOsHVilwewkOceJQySjDIz54rVP(O32CQuG)LacPW8scLLRutrivqkW)saHuWQqdgpMb0zvsOlfWGNxuxkQCLAkssfKc8Veqif465aZQeJHCrJuadEErDPOYvQ5jLkif4FjGqkW1ZbMb1ukGbpVOUuu5k1KIjvqkW)saHuWaBHvaeZsbm45f1LIkx5kxPGySmeqi1KANAdfDQizdumrnQzdfjfGWvqIdJuqBRAbQf19(KEZ)saH3xIznj3UuWQa0Klkf0G3uOEoqV1(5d0TRbVh21YODOKYdYoaptpqLsdrf(YlbeFX0lLgI6tPBxdEtbRIC92gOivEtTtTHI8wK9MAIq7CskYT721G3qPbooqJ2XTRbVfzVnlxBEcxr2AGnivEBwGvEcxr2AGnivEZHU3SyS4dmpHRiFX4yh8Ml07bo0VOU3tn69oGEZ66Gi521G3IS3lxh4MwIkMxqwNGElYu3BfNaJb6LOI5fK1jOsEBaEVd86ne0BDqafwVrO(OXqeJxn69eUcVbH3BXMbVj0Edb9wheqH1BiCSEVGKB3TRbV1EqfF4f19EI0Gc9(bQtE9EIhKWK8Mc)JwRX7aeI8axQ0WxV5FjGW4niUAm525FjGWKSk8bQtEhPVSrz3o)lbeMKvHpqDYRwJusda6UD(xcimjRcFG6KxTgPKHpuXy5Lac3o)lbeMKvHpqDYRwJuY1ZbMjXI3l(RBN)LactYQWhOo5vRrknWQQGiZ1ZbMPzvYLWLBxdE)GWGLymRYb7nX49oGERYb7TfwpglFGEdb9gchR3lW7dG36aiH3lWBD4IehE)GWGLym5T2E9oqu349c8(ISy0BmaWhdExaGQ3lWBiGYSE)Sb928yWfb4TXIv9McI6niUA0BD4IehEtHtm525FjGWKSk8bQtE1AKsXCr45fPkyvC8bHblXywLdMkG1ObxQeZxyCKIDQwksTt1US2cwKftifhmXcqmycdEErDLC78Veqyswf(a1jVAnsPjylZayZMLxJBN)LactYQWhOo5vRrkvjvbQmrLpq3o)lbeMKvHpqDYRwJuAbwciC78Veqyswf(a1jVAnsjxphyEEzZ62D7AWBThuXhErDVrXyPrVxIk69oGEZ)ckVjgVzXm5YZlMC7AWBTDSyvWwR37a69eymEdzadVTagdzEXKBN)LacZ4dGJflJfEVUD(xcimAnsPXcVxZI81TZ)saHrRrklufigZpCzq3Ug8(eoW7f4TOWv49joWg0Bidy4nFlK11O3t4kiXbvEdkVHmGH3tGX4neY96Tob92aarYTZ)saHrRrkF(EZ8VeqKVeZsvWQ44eUcQi0Jt4kYwdSbpFwXjWyGEjQyEbzDcAllgl(aZt4kYxmo2bLC7AWBHLR1BrHRW7tCGnO3qgWWBkuphO3NiacwEtmExiRRrV5q3BTNyWZlbeEdHCVEprVlK11O3kccVzXyXhOsEprAqHEVdO3t4k82AGnO3eJ3aXyL8McxdWBvwz0BdCHEdb9(aSElsEtH65a9gknW1bAOYBq59ZH3h46Ti5nfQNd0BO0axhOXBiKDWBO0axhOU3Nqwj3o)lbegTgP857nZ)sar(smlvbRIJt4kOIqpQ4daxDaKiX1ZbMTaqWkvOktcZ4Pq)aWvhajsOyWZlbePcvzsySDKfJfFG5jCf5lgh7a0koHPPtC9CG5FGRdmzw(vECcttN465aZ)axhysLHA2S8R85ZkU8fJn9dCDG6zyReg88I6q)aWvhajs)axhOEg2kvOktcZ4PkPKsUD(xcimAns5Z3BM)LaI8LywQcwfhFqyWsmsfHEuBMWvKTgyd625FjGWO1iLpFVz(xciYxIzPkyvCufigvXyD7UDn4T2o(cvXy9gaxEpHRWBRb2GE)a4yXk5T23agOyS8gc6nglwEVdO39eUI2B(xcimEdHSda417jsIdVjH3S3t4k82AGnivEtwVvromEVd86ne0BUqV5jaE9EbEBwUwVbbMC7AWB(xcimPjCfJI5IWZlsvWQ44cw(MNWvyOcynY66ujMVW4OnurOh1MjCfzRb2GUDn4n)lbeM0eUcTgP0SCT5jCfzRb2GurOh1MjCfzRb2GUDn4T2l09EhqVNWv4T1aBqVHmGH3qqVHYGnR3OyWZlQNC7AWB(xcimPjCfAnsPzbw5jCfzRb2GurOhNWvKTgydcTvHIZhVEYMekg88sab0lxh4MwIkMxqwNGuNfJfFG5jCf5lgh7a0t4kYwdSbZ6WfVeqq9tD7AWBOCqJX7DGdVTXBsywK19gq7nsXbZxJ3lW7tPY7j(mSb9gq7TvHI8ZM1BkuphO3IEzZ625FjGWKMWvO1iL)axhOEg2Ikc94eMMoX1ZbM)bUoWKz5xzBhTXTZ)saHjnHRqRrkvjvbQmrLpq3o)lbeM0eUcTgPmWDaR8IQwOzPIqpQyH0fAg45fpFwBwYRmjouc6jmnDIRNdm)dCDGjZYVYJtyA6exphy(h46atQmuZMLFLHEcttNk4aZa6SfacwjDaKa6jmnDIRNdmBbGGvshajC7AWBTVbm8UGJGehEdLxmwwaiyH6u5nh6Edb9(aSEZEtXdFrVb0ERWqHOXBRc8ERif0wrbVHGEFawVbWL3I0o4nfQNd0BO0axhO3IjS3qPbUoqDVpHSuIkVHnO3K17jsdk0Bydjo8MIhCIArHtKkVN4ZWg07Da9wLd27c1H)LacVjgVb7awqig07lxh4vJEdHnlQ7THep69oGEtbr9gcB8MUq0Bo0iewJj3o)lbeM0eUcTgPKRNdmpVSzPIqpoHPPtf8fZa68ouiAsWwqV8fJnbeJLfacwOEcdEErDO5FjIXmgOkbn2kc3o)lbeM0eUcTgP8sogwtgkdw)qfJLkc94eMMoX1ZbMTaqWkPdGeUD(xcimPjCfAnszbhygqNTaqWIkc9O2mHPPtC9CGzlaeSsWwqROkhCY6xQpEYtpF(bGRoasK465aZwaiyLkuLjHz8uLGwXjmnDIRNdm)dCDGjZYVYJtyA6exphy(h46atQmuZMLFLvYTZ)saHjnHRqRrkNyzWszsC425FjGWKMWvO1iLC9CGzlaeSC78Veqyst4k0AKsydMjlQAOIqpoHPPtC9CGzlaeSsWwNpR4eymqVevmVGSobT9bGRoasK465aZwaiyLkuLjHrj3o)lbeM0eUcTgPCEba9mnCPr3o)lbeM0eUcTgPKMu48ca6UD(xcimPjCfAnsjhpA2IV5NVx3o)lbeM0eUcTgP0QqdgpMb0zvsOtfHEuXLVySPcoWmGoBbGGvcdEErDONW00PcoWmGoBbGGvQqvMegBhNW00jRcny8ygqNvjHEsLHA2S8RS2L)LaIexphyEEzZMqOIp8I5LOIkD(8eMMoX1ZbMTaqWkvOktcJTJtyA6KvHgmEmdOZQKqpPYqnBw(vw7Y)sarIRNdmpVSztiuXhEX8sur3o)lbeM0eUcTgP0cSeqqfHECcttN465aZwaiyLGTGwXjmnDAILblLjXrc2685jmnDAEba9mnCPXeS15ZAJIf)yAlW9E(CXpMa1RKsUD(xcimPjCfAnsjxphygutQi0JtyA6exphy(h46atMLFLhp98zf5FjIXmgOkbn2kIZNvK)LigZyGQe0yl1GE5lgBQqdi44Xeg88I6kPKBN)LactAcxHwJuY1ZbMNCv8bsfHEK)LigZyGQe0q9rraTItyA6exphy(h46atMLFLhNW00jUEoW8pW1bMuzOMnl)kRKBN)LactAcxHwJuY1ZbMrOADbgciOIqpY)seJzmqvcAO(OiC7AWBT9rak0BkuphO3A)eJHCrJ36Wfjo8Mc1Zb69jcGGfvEZgIo6nDbu92aurVfJLg92yHpHM8EJq9rRLacdvEFjkJEhG17bwmjo8gkVySSaqWc19E5lglQ7n0ExWrqIdVfbu9Mc1Zb69jcRQIxsCKC78Veqyst4k0AKsUEoWSkXyix0qfHECcttN(lY1ZMLehPc5FHM)LigZyGQe0yRiGwXLVySjw16sOjpVeqKWGNxu)8zf1MLVySjGySSaqWc1tyWZlQdnRTGfzXexphy2cwvfVK4ivCOm1hPMsNppHPPtC9CGzlaeSs6aiHsu9dmjgTXTZ)saHjnHRqRrk565aZZlBwQi0J8VeXygduLGgBfHBxdERjaI37aVEdbHcf6ToiqVNWvqIdQ8gc69ZH3Ww68IEVdO3SyS4dmpHRiFX4yh8gczh8EhqVVyCSdEdO9EhigVNWvKC7AWB(xcimPjCfAnsPyUi88IufSkoYIXIpW8eUI8fJJDGkG1ObxQeZxyCurXCr45ftSyS4dmpHRiFX4yh0UI5IWZlMwWY38eUcJilMlcpVyIfJfFG5jCf5lgh7GwkoHRiBnWgmRdx8saHskDctmxeEEX0cw(MNWvyC78Veqyst4k0AKsum45LacQiXIvbBTzc9OkhCY6xQpEcojvKyXQGT2mrvf1j8IJ2421G3q5ckV3b07Il0BW)SHacVHmGf6ne07dG3aGQ3tKguO3OyWZlbeEtmEp5xzVHTsER4jKbMVxn69eFg2GEdb9(axVfJLg9EY6ExXH3gG37a69eUcVjgVF41BXyPrVndGAvYTZ)saHjnHRqRrk565aZtUk(aD7UD(xcimPhegSeJJQKQavMOYhOBN)Lact6bHblXOwJu(dCDG6zylQi0JtyA6exphy(h46atMLFLhp1TZ)saHj9GWGLyuRrkdChWkVOQfAwQi0JkwiDHMbEEXZN1ML8ktIdLGEcttN465aZ)axhyYS8R84eMMoX1ZbM)bUoWKkd1Sz5xzONW00PcoWmGoBbGGvshajGEcttN465aZwaiyL0bqc3o)lbeM0dcdwIrTgPKRNdmdQjve6XjmnDIRNdm)dCDGjZYVY2osnOv8bGRoasK465aZwaiyLkuLjHH62C65Z8VeXygduLGgBhPMsUDn4nfQNd0BrVSz92mqOxJ3WwEtcVTkcOiRg9gYagExWrqIdVl4l6nG27DOq0KC78Veqyspimyjg1AKsUEoW88YMLkc94eMMovWxmdOZ7qHOjbBb9eMMoX1ZbM)bUoWKz5xzQlc3o)lbeM0dcdwIrTgPe2GzYIQufSkoUeD0SGsn)aDeQurOhNW00PcoWmGoBbGGvshajGwBMW00jUEoWSfacwPc5FH(bGRoasK465aZwaiyLkuLjHH6u7u3o)lbeM0dcdwIrTgPSGdmdOZwaiyrfHECcttN465aZ)axhyYS8R84eMMoX1ZbM)bUoWKkd1Sz5xzOvKg(EZf(dCDG5LOI2oIqfF4fZlrfpFMg(EZf(dCDG5LOI2o(aWvhajsC9CGzlaeSsfQYKWC(SItGXa9suX8cY6e02XhaU6airIRNdmBbGGvQqvMegLuYTZ)saHj9GWGLyuRrk565aZQeJHCrdve6rvo4K1V2osrNe6jmnD6VixpBwsCKkK)LQFGjXOnUDn4T2A4IehE)GWGLyKkVHGEBwY96nugSz9gchR3lW7heljGrVdW6TEbSSiXH3)axhOXB249fehEZgVTagdzEXKaWBLr0YBOWeUcsCaf8MnEFbXH3SXBlGXqMx0BfzLzVFqyWsmMv5G9Ehk0mmaU6k5nh6EVdy4TbcB59c8M9wKGQ3uqurM6uyYv59dcdwIrVlWYlbejV120Edb9wh4DawVhyXO3IK3uakrL3qqVFo8wNy5T5sog2Rg9(cGGL3lW7dC9M9wK2bVPauk5T2h6nFnaVnWMLjH386n79a5yalVv5G92cRhJLpqVHmGH3qqVTUC49c8g2GEZEtXdhO3aAVpraeS8whUiXH3pimyjg92AGnivEBaEdb9(5W7jCfERdxK4W7Da9MIhoqVb0EFIaiyLC78Veqyspimyjg1AKsUEoW8KRIpqQi0JkQ4eMMoX1ZbM)bUoWKz5x5XjmnDIRNdm)dCDGjvgQzZYVYkbTIkQYbNS(12rXCr45ftpimyjgZQCWkD(SIlFXytfCGzaD2cabReg88I6q)aWvhajsC9CGzlaeSsfQYKWq9haU6airQGdmdOZwaiyLOHV3CH)axhyEjQi0QCWjRFTDumxeEEX0dcdwIXSkhSwu7KkP05ZkU8fJnX1ZbMb1mHbpVOo0paC1bqIexphyguZuHQmjm2oE86q)aWvhajsC9CGzlaeSsfQYKWqDBovjLoFwLdoz9RTJkkMlcpVy6bHblXywLdwKT5uLC7AWBbylScGy2BIX7jx4vJEdbu7G3pBwsCqL3qgi)G3eJ3qg0O3K1BIXBdWBAU8whajOYBqC1O3qzWM1BEceJEtbrtE725FjGWKEqyWsmQ1iLgylScGyMkc9OkhCY6xBhPOt621G3ARq0YBOWeUcsCaf8MeEZa0BdzH5LacJ3WXsUE)GWGLymRYb7T1VjVPa9IL37aVEdIRg9(zZ6nf0EEdHSdElcVPq9CGE)dCDGgQ82qIh9MSqbJ38vfywVrkoy(6TkhS3pWSEVaVzVfH3MLFL9McI6nhAecRXK3uy9Eh41BlajwVPaq75DbwEjGWBiK717j6nfe1BOkcVfzQ7nf0EElYu3Bkm5QC78Veqyspimyjg1AKsUEoWmcvRlWqabve6r(xIymJbQsqd1hfb0kQYbNS(L6JI5IWZlMEqyWsmMv5GpFEcttN465aZ)axhyYS8R8OiuYTZ)saHj9GWGLyuRrk565aZZlBw3o)lbeM0dcdwIrTgPKRNdmp5Q4d0T725FjGWKubIrvm2rZarvflQi0JQaXOkgBsNywoEK6J2CQBN)LactsfigvXy1AKY5LektfHEufigvXyt6eZYXJuF0MtD78VeqysQaXOkgRwJuAvObJhZa6Skj0D78VeqysQaXOkgRwJuY1ZbMvjgd5Ig3o)lbeMKkqmQIXQ1iLC9CGzqnD78VeqysQaXOkgRwJuAGTWkaIzPadVdGskiquHV8sabuQy6vUYvkba]] )


end
