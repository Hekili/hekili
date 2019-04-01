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

            handler = function ()
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

            usable = function () return debuff.stealable_magic.up end,
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


    spec:RegisterPrefs( {
        arcane_info = {
            type = "description",
            name = "The Arcane Mage module treats combat as one of two phases.  The 'Burn' phase begins when you have used Arcane Power and begun aggressively burning mana.  The 'Conserve' phase starts when you've completed a burn phase and used Evocation to refill your mana bar.  This phase is less " ..
                "aggressive with mana expenditure, so that you will be ready when it is time to start another burn phase.",

            width = "full",
            order = 1,
        },

        conserve_mana = {
            type = "range",
            name = "Minimum Mana (Conserve Phase)",
            desc = "Specify the amount of mana (%) that should be conserved when conserving mana before a burn phase.",

            min = 25,
            max = 100,
            step = 1,

            width = "full",
            order = 2,
        }
    } )


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


    spec:RegisterPack( "Arcane", 20190401.1500, [[d0uU3aqiIq9iIGlPIuKnbs9jqsAueItriTkkfYRiLmlKOBreYUe5xijdJsPJrk1Yqs1ZifAAiP4AQizBukW3qsPACukQohiPwhLc18urCpfAFiHoisWcjIEOks1ePuq1fPueBejLqFufPOojLI0kPu9skfuMjskb3KsrPDsk6NiPenuqsSuKukpLGPsK6QQif(kLII9sYFf1GLCyulwrpwvtMuDzOnJuFwfgTconIvRIu61ejZwLUnrTBHFdmCk54iPKwUupNIPR01b12juFheJhK48KcwpLcY8vrTFQwPTsALGoVOstQBR2qTTuJTAN0MAofuFkOwjSAWcvcw8lfFGkHGLrLaf6NdujyXA4cyDL0kbdaUFujmSRLXgtfvhKDaEMEGmvgIm8Lxci(MPxQme5NkLWeMCxBAOMkbDErLMu3wTHABPgB1oPn1CkOMA0wjySWxPPnG6kHbIUogQPsqhnVsqcErH(5a9YMLpq3Ue8AyxlJnMkQoi7a8m9azQmez4lVeq8ntVuziYpvUDj4ffSAY1lTP0lQBR2qTxsKx2c12yBPUB3TlbVo9booqJn2TlbVKiVml3BEc3r2AGniLEzwGvEc3r2AGniLEXHUxSyS5dmpH7iFX4yh8IB0Rbo0VOUxtn41oGEX66Gi52LGxsKxl3h4MwImMxqwNGEjru0lrMaJb6LiJ5fK1jOOEzaETd86fe0lDqavxVqO8OXqeJxn41eUdVaHxBZMbVi0Ebb9sheq11liCSETGKs4smRrjTs4bHbBXOsALMARKwjW)saHsqM0nOZez(avcyWZlQRKuTknPUsALag88I6kjvcFtwSjSsycttN4(5aZ)a3hyYS8lLxJEzRsG)LacLWpW9bQNHTuRstnQKwjGbpVOUssLW3KfBcReeXRgPB0mWZl615ZEjXETKxksC4LOEbTxtyA6e3phy(h4(atMLFP8A0RjmnDI7Ndm)dCFGjzgkzZYVuEbTxtyA6udhygqNTaqWoPdGeEbTxtyA6e3phy2cab7KoasOe4FjGqje4oGDErzl0SQvPj1OKwjGbpVOUssLW3KfBcReMW00jUFoW8pW9bMml)s51jJErDVG2lr86bGRoasK4(5aZwaiyNAuMjHXlk6L22615ZEX)seJzmqzcA86KrVOUxIQe4FjGqjW9ZbMb9uTknpLsALag88I6kjvcFtwSjSsycttNA4lMb05DOr0KGT8cAVMW00jUFoW8pW9bMml)s5ff9sJkb(xciucC)CG55LnRAvAAdusReWGNxuxjPsG)LacLWs0rZcA58d0rOOe(MSytyLWeMMo1WbMb0zlaeSt6aiHxq7Le71eMMoX9ZbMTaqWo1i)Rxq71daxDaKiX9ZbMTaqWo1OmtcJxu0lQBRsiyzujSeD0SGwo)aDekQvPj1UsALag88I6kjvcFtwSjSsycttN4(5aZ)a3hyYS8lLxJEnHPPtC)CG5FG7dmjZqjBw(LYlO9seVOHV3CJ)a3hyEjYOxNm6fcf8HxmVez0RZN9Ig(EZn(dCFG5LiJEDYOxpaC1bqIe3phy2cab7uJYmjmED(SxI41eymEbTxlrgZliRtqVoz0RhaU6airI7NdmBbGGDQrzMegVe1lrvc8VeqOeA4aZa6Sfac2QvPPnxjTsadEErDLKkb(xciucC)CGzzIXqUOrj8dmjucARe(MSytyLGmhCY6xVoz0lO(uEbTxtyA60FrUF2SK4i1i)RAvAc1kPvcyWZlQRKuj8nzXMWkbr8seVMW00jUFoW8pW9bMml)s51OxtyA6e3phy(h4(atYmuYMLFP8suVG2lr8seVK5Gtw)61jJEjMBcpVy6bHbBXywMd2lr968zVeXRhaU6airI7NdmBbGGDQrzMegVOOxpaC1bqIudhygqNTaqWordFV5g)bUpW8sKrVG2lzo4K1VEDYOxI5MWZlMEqyWwmML5G9slVO(P8suVe1RZN9seVw(IXM4(5aZGEMWGNxu3lO96bGRoasK4(5aZGEMAuMjHXRtg96419cAVEa4QdGejUFoWSfac2PgLzsy8IIEPTTEjQxI615ZEjZbNS(1Rtg9seVeZnHNxm9GWGTymlZb7Le5L226LOkb(xciucC)CG5j3nFGQvPP22QKwjGbpVOUssLW3KfBcReK5Gtw)61jJEb1NsjW)saHsWaBHDaeZQvPP2ARKwjGbpVOUssLW3KfBcRe4FjIXmgOmbnErXrV0Oxq7LiEjZbNS(1lko6LyUj88IPhegSfJzzoyVoF2RjmnDI7Ndm)dCFGjZYVuEn6Lg9suLa)lbekbUFoWmcfRlWqaHAvAQn1vsRe4FjGqjW9ZbMNx2Skbm45f1vsQwLMARrL0kb(xciucC)CG5j3nFGkbm45f1vsQw1Qe0rAg(UkPvAQTsALa)lbekHhahl2gl8EvcyWZlQRKuTknPUsALag88I6kjvcFtwSjSsyc3r2AGnOxNp7LiEnbgJxq71sKX8cY6e0Rt8IfJnFG5jCh5lgh7GxIQe4FjGqj889M5FjGiFjMvjCjMnhSmQeMWDOwLMAujTsadEErDLKkHVjl2ewjiIxpaC1bqIe3phy2cab7uJYmjmEn6LTEbTxpaC1bqIekg88sarQrzMegVoz0lwm28bMNWDKVyCSdEbTxI41eMMoX9ZbM)bUpWKz5xkVg9ActtN4(5aZ)a3hysMHs2S8lLxNp7LiET8fJn9dCFG6zyReg88I6EbTxpaC1bqI0pW9bQNHTsnkZKW41Ox26LOEjQxIQe4FjGqj889M5FjGiFjMvjCjMnhSmQeMWDOwLMuJsALag88I6kjvcFtwSjSsqI9Ac3r2AGnOsG)LacLWZ3BM)LaI8LywLWLy2CWYOs4bHbBXOAvAEkL0kbm45f1vsQe4FjGqj889M5FjGiFjMvjCjMnhSmQeKbIrzmw1QwLGvJpqEYRsALMARKwjGbpVOUss1Q0K6kPvcyWZlQRKuTkn1OsALag88I6kjvRstQrjTsG)LacLa3phyMelEV4Vkbm45f1vsQwLMNsjTsG)LacLGbwwgezUFoWmnltUeUvcyWZlQRKuTknTbkPvcyWZlQRKujaSucgCvc8VeqOeeZnHNxujiMVWOsWgyRxA5LiErDB9Yg5fBdHnzXesTctSaedMWGNxu3lrvcI5ohSmQeEqyWwmML5GvRstQDL0kbm45f1vsQwLM2CL0kb(xciucYKUbDMiZhOsadEErDLKQvPjuRKwjW)saHsWcSeqOeWGNxuxjPAvAQTTkPvc8VeqOe4(5aZZlBwLag88I6kjvRAvct4ousR0uBL0kbm45f1vsQe(MSytyLWeMMoX9ZbM)bUpWKz5xkVoz0lTvc8VeqOe(bUpq9mSLAvAsDL0kb(xciucYKUbDMiZhOsadEErDLKQvPPgvsReWGNxuxjPs4BYInHvcI4vJ0nAg45f968zVKyVwYlfjo8suVG2RjmnDI7Ndm)dCFGjZYVuEn61eMMoX9ZbM)bUpWKmdLSz5xkVG2RjmnDQHdmdOZwaiyN0bqcVG2RjmnDI7NdmBbGGDshajuc8VeqOecChWoVOSfAw1Q0KAusReWGNxuxjPs4BYInHvctyA6udFXmGoVdnIMeSLxq71Yxm2eqm2waiyJ6jm45f19cAV4FjIXmgOmbnEDIxAujW)saHsG7NdmpVSzvRsZtPKwjGbpVOUssLW3KfBcReMW00jUFoWSfac2jDaKqjW)saHs4sogwt(0cRFiJXQwLM2aL0kbm45f1vsQe(MSytyLGe71eMMoX9ZbMTaqWobB5f0EjIxYCWjRF9IIJEDkB968zVEa4QdGejUFoWSfac2PgLzsy8A0lB9suVG2lr8ActtN4(5aZ)a3hyYS8lLxJEnHPPtC)CG5FG7dmjZqjBw(LYlrvc8VeqOeA4aZa6Sfac2QvPj1UsALa)lbekHj2gSLIehkbm45f1vsQwLM2CL0kb(xciucC)CGzlaeSvcyWZlQRKuTknHAL0kbm45f1vsQe(MSytyLWeMMoX9ZbMTaqWobB515ZEjIxtGX4f0ETezmVGSob96eVEa4QdGejUFoWSfac2PgLzsy8suLa)lbekbydMjlkBuRstTTvjTsG)LacLW8ca6zA4wdkbm45f1vsQwLMARTsALa)lbekbAsJZlaOReWGNxuxjPAvAQn1vsRe4FjGqjWXJMT5B(57vjGbpVOUss1Q0uBnQKwjGbpVOUssLW3KfBcReeXRLVySPgoWmGoBbGGDcdEErDVG2RjmnDQHdmdOZwaiyNAuMjHXRtg9ActtNSA0GXJzaDwMe6jzgkzZYVuEzJ8I)LaIe3phyEEzZMqOGp8I5LiJEjQxNp71eMMoX9ZbMTaqWo1OmtcJxNm61eMMoz1ObJhZa6Smj0tYmuYMLFP8Yg5f)lbejUFoW88YMnHqbF4fZlrgvc8VeqOeSA0GXJzaDwMe6QvPP2uJsALag88I6kjvcFtwSjSsycttN4(5aZwaiyNGT8cAVeXRjmnDAITbBPiXrc2YRZN9ActtNMxaqptd3AibB515ZEjXEjIxn)yABW9615ZE18Jjq)EjQxIQe4FjGqjybwciuRstTpLsALag88I6kjvcFtwSjSsycttN4(5aZ)a3hyYS8lLxJEzRxNp7LiEX)seJzmqzcA86eV0OxNp7LiEX)seJzmqzcA86eVOUxq71Yxm2uJgqWXJjm45f19suVevjW)saHsG7Ndmd6PAvAQTnqjTsadEErDLKkHVjl2ewjW)seJzmqzcA8IIJEPrVG2lr8ActtN4(5aZ)a3hyYS8lLxJEnHPPtC)CG5FG7dmjZqjBw(LYlrvc8VeqOe4(5aZtUB(avRstTP2vsReWGNxuxjPs4BYInHvc8VeXygduMGgVO4OxAujW)saHsG7NdmJqX6cmeqOwLMABZvsReWGNxuxjPsG)LacLa3phywMymKlAuc)atcLG2kHVjl2ewjmHPPt)f5(zZsIJuJ8VEbTx8VeXygduMGgVoXln6f0EjIxlFXytSS1LqtEEjGiHbpVOUxNp7LiEjXET8fJnbeJTfac2OEcdEErDVG2l2gcBYIjUFoWSfSSmEjXrQ5qkVO4Oxu3lr968zVMW00jUFoWSfac2jDaKWlrvRstTHAL0kbm45f1vsQe(MSytyLa)lrmMXaLjOXRt8sJkb(xciucC)CG55LnRAvAsDBvsReiXIDdBTzcTsqMdoz9lfhT5NsjqIf7g2AZezzuNWlQe0wjW)saHsafdEEjGqjGbpVOUss1Q0K6ARKwjW)saHsG7Ndmp5U5dujGbpVOUss1QwLGmqmkJXQKwPP2kPvcyWZlQRKuj8nzXMWkbzGyugJnPtmlhp6ffh9sBBvc8VeqOeMxsiLAvAsDL0kbm45f1vsQe(MSytyLGmqmkJXM0jMLJh9IIJEPTTkb(xciucZljKsTkn1OsALa)lbekbRgny8ygqNLjHUsadEErDLKQvPj1OKwjW)saHsG7NdmltmgYfnkbm45f1vsQwLMNsjTsG)LacLa3phyg0tLag88I6kjvRstBGsALa)lbekbdSf2bqmReWGNxuxjPAvRAvcIX2qaHstQBR2qTTu3wTtuxJuZPucq4oiXHrjytLTa9I6EDkV4FjGWRlXSMKBxjWW7aOvccez4lVeqC6ntVkbRgqtUOsqcErH(5a9YMLpq3Ue8AyxlJnMkQoi7a8m9azQmez4lVeq8ntVuziYpvUDj4ffSAY1lTP0lQBR2qTxsKx2c12yBPUB3TlbVo9booqJn2TlbVKiVml3BEc3r2AGniLEzwGvEc3r2AGniLEXHUxSyS5dmpH7iFX4yh8IB0Rbo0VOUxtn41oGEX66Gi52LGxsKxl3h4MwImMxqwNGEjru0lrMaJb6LiJ5fK1jOOEzaETd86fe0lDqavxVqO8OXqeJxn41eUdVaHxBZMbVi0Ebb9sheq11liCSETGKB3TlbVSjqbF4f19AI0Gg96bYtE9AIhKWK8Ic)JwRXRaes0a3Y0WxV4FjGW4fiUAi525FjGWKSA8bYtEhPVSrk3o)lbeMKvJpqEYRwJurda6UD(xcimjRgFG8KxTgPIHpKXy5Lac3o)lbeMKvJpqEYRwJuX9ZbMjXI3l(RBN)LactYQXhip5vRrQmWYYGiZ9ZbMPzzYLWTBxcE9GWGTymlZb7fX41oGEjZb7Lf2pglFGEbb9cchRxlWRdGx6aiHxlWlD4MehE9GWGTym5LnD9kqu341c86ISy0lmaWhdE1aGSxlWliG2SE9Sb9Y8yWnb4LXIL9Ics6fiUAWlD4MehErbOsYTZ)saHjz14dKN8Q1ivI5MWZlszWY44dcd2IXSmhmLaRrdUukMVW4OnWwTeH62AJyBiSjlMqQvyIfGyWeg88I6I625FjGWKSA8bYtE1AKktWwMbWMnlVg3o)lbeMKvJpqEYRwJujt6g0zImFGUD(xcimjRgFG8KxTgPYcSeq425FjGWKSA8bYtE1AKkUFoW88YM1T72LGx2eOGp8I6EHIXwdETez0RDa9I)f0ErmEXIzYLNxm52LGx20yXUHTwV2b0RjWy8cYagEzbmgY8Ij3o)lbeMXhahl2gl8ED7sWRtZaVwGxsc3HxqLb2GEbzadV4BJSUg8Ac3bjoO0lq7fKbm8AcmgVGqUxV0jOxgaisUD(xcimAns1Z3BM)LaI8LywkdwghNWDqjHECc3r2AGn45ZImbgd0lrgZliRtWtyXyZhyEc3r(IXXoiQBxcEjSCVEjjChEbvgyd6fKbm8Ic9Zb6fubabBVigVAK11GxCO7Lnrm45LacVGqUxVMOxnY6AWlraHxSyS5duuVMinOrV2b0RjChEznWg0lIXlGyStErHRb4Lmlf6LbUrVGGEDawVOgVOq)CGED6dCFGgk9c0E9C41bUErnErH(5a960h4(anEbHSdED6dCFG6EDAyLC78Veqy0AKQNV3m)lbe5lXSugSmooH7Gsc9OipaC1bqIe3phy2cab7uJYmjmJ2c9daxDaKiHIbpVeqKAuMjH5Krwm28bMNWDKVyCSdqlYeMMoX9ZbM)bUpWKz5xQXjmnDI7Ndm)dCFGjzgkzZYVuNplYYxm20pW9bQNHTsyWZlQd9daxDaKi9dCFG6zyRuJYmjmJ2kQOI625FjGWO1ivpFVz(xciYxIzPmyzC8bHbBXiLe6rjEc3r2AGnOBN)LacJwJu989M5FjGiFjMLYGLXrzGyugJ1T72LGx204BugJ1laC71eUdVSgyd61dGJf7Kx2mdyGIX2liOxySy71oGEvt4okV4FjGW4feYoaGxVMijo8IeEXEnH7WlRb2Gu6fz9sg5W41oWRxqqV4g9INa41Rf4Lz5E9ceyYTlbV4FjGWKMWDmkMBcpViLblJJly5BEc3HHsG1iRRtPy(cJJAtjHEuINWDKTgyd62LGx8Veqyst4o0AKkZY9MNWDKTgydsjHEuINWDKTgyd62LGx2Kq3RDa9Ac3HxwdSb9cYagEbb960cBwVqXGNxup52LGx8Veqyst4o0AKkZcSYt4oYwdSbPKqpoH7iBnWgeARgfNpE9K2jum45LacOxUpWnTezmVGSobPilgB(aZt4oYxmo2bONWDKTgydM1HBEjGGI262LGxulGgJx7ahEPTxKWSiR7fG2lKAfMVgVwGx2sPxt8zyd6fG2lRgLONnRxuOFoqVK8YM1TZ)saHjnH7qRrQ(bUpq9mSfLe6XjmnDI7Ndm)dCFGjZYVuNmQTBN)LactAc3HwJujt6g0zImFGUD(xcimPjChAnsvG7a25fLTqZsjHEuKgPB0mWZlE(SeVKxksCik0tyA6e3phy(h4(atMLFPgNW00jUFoW8pW9bMKzOKnl)sb9eMMo1WbMb0zlaeSt6aib0tyA6e3phy2cab7Koas42LGx2mdy4vdhbjo8IAPySTaqWg1P0lo09cc61by9I9IAd(IEbO9s6HgrJxwn49sekydJcEbb96aSEbGBVOMDWlk0phOxN(a3hOxIjSxN(a3hOUxNgwIsPxWg0lY61ePbn6fSHehErTbGkArbOcLEnXNHnOx7a6LmhSxnQd)lbeErmEb2bSHqmOxxUpWRg8ccBwu3ldjE0RDa9Ics6fe24fDJOxCObiSgsUD(xcimPjChAnsf3phyEEzZsjHECcttNA4lMb05DOr0KGTGE5lgBcigBlaeSr9eg88I6qZ)seJzmqzcAorJUD(xcimPjChAns1LCmSM8Pfw)qgJLsc94eMMoX9ZbMTaqWoPdGeUD(xcimPjChAnsvdhygqNTaqWMsc9OepHPPtC)CGzlaeStWwqlImhCY6xkoEkBpF(bGRoasK4(5aZwaiyNAuMjHz0wrHwKjmnDI7Ndm)dCFGjZYVuJtyA6e3phy(h4(atYmuYMLFPe1TZ)saHjnH7qRrQMyBWwksC425FjGWKMWDO1ivC)CGzlaeSD78Veqyst4o0AKkydMjlkBOKqpoHPPtC)CGzlaeStWwNplYeymqVezmVGSobp5bGRoasK4(5aZwaiyNAuMjHru3o)lbeM0eUdTgPAEba9mnCRb3o)lbeM0eUdTgPIM048ca6UD(xcimPjChAnsfhpA2MV5NVx3o)lbeM0eUdTgPYQrdgpMb0zzsOtjHEuKLVySPgoWmGoBbGGDcdEErDONW00PgoWmGoBbGGDQrzMeMtgNW00jRgny8ygqNLjHEsMHs2S8lLnI)LaIe3phyEEzZMqOGp8I5LiJIE(8eMMoX9ZbMTaqWo1OmtcZjJtyA6KvJgmEmdOZYKqpjZqjBw(LYgX)sarI7NdmpVSztiuWhEX8sKr3o)lbeM0eUdTgPYcSeqqjHECcttN4(5aZwaiyNGTGwKjmnDAITbBPiXrc2685jmnDAEba9mnCRHeS15ZsSin)yABW9E(CZpMa9lQOUD(xcimPjChAnsf3phyg0tkj0JtyA6e3phy(h4(atMLFPgT98zr4FjIXmgOmbnNOXZNfH)LigZyGYe0Cc1HE5lgBQrdi44Xeg88I6IkQBN)LactAc3HwJuX9ZbMNC38bsjHEK)LigZyGYe0qXrncTityA6e3phy(h4(atMLFPgNW00jUFoW8pW9bMKzOKnl)sjQBN)LactAc3HwJuX9ZbMrOyDbgciOKqpY)seJzmqzcAO4OgD7sWlB6raA0lk0phOx2SeJHCrJx6Wnjo8Ic9Zb6fubabBk9IneD0l6gi7LbiJEjgBn4LXcFcn59cHYJwlbegk96sKc9kaRxdSysC4f1sXyBbGGnQ71Yxmwu3lO9QHJGehEPrO4ff6Nd0lOcSSmEjXrYTZ)saHjnH7qRrQ4(5aZYeJHCrdLe6XjmnD6Vi3pBwsCKAK)fA(xIymJbktqZjAeArw(IXMyzRlHM88sarcdEEr9ZNfrIx(IXMaIX2cabBupHbpVOo0Sne2KftC)CGzlyzz8sIJuZHuuCK6IE(8eMMoX9ZbMTaqWoPdGeIs5pWKyuB3o)lbeM0eUdTgPI7NdmpVSzPKqpY)seJzmqzcAorJUDj4LMaiETd86feeQ2Ox6Ga9Ac3bjoO0liOxphEbBPZl61oGEXIXMpW8eUJ8fJJDWliKDWRDa96IXXo4fG2RDGy8Ac3rYTlbV4FjGWKMWDO1ivI5MWZlszWY4ilgB(aZt4oYxmo2bkbwJgCPumFHXrreZnHNxmXIXMpW8eUJ8fJJDWgjMBcpVyAblFZt4omsKyUj88Ijwm28bMNWDKVyCSdAjYeUJS1aBWSoCZlbeIk6PjXCt45ftly5BEc3HXTZ)saHjnH7qRrQqXGNxciOKel2nS1Mj0JYCWjRFP4On)uusIf7g2AZezzuNWloQTBxcErTiO9AhqVAUrVa)Zgci8cYa2OxqqVoaEbaYEnrAqJEHIbpVeq4fX41KFP8c2k5LiNggy(E1Gxt8zyd6fe0RdC9sm2AWRjR7vhhEzaETdOxt4o8Iy86HxVeJTg8Yma6vu3o)lbeM0eUdTgPI7Ndmp5U5d0T725FjGWKEqyWwmokt6g0zImFGUD(xcimPhegSfJAns1pW9bQNHTOKqpoHPPtC)CG5FG7dmzw(LA0w3o)lbeM0dcd2IrTgPkWDa78IYwOzPKqpksJ0nAg45fpFwIxYlfjoef6jmnDI7Ndm)dCFGjZYVuJtyA6e3phy(h4(atYmuYMLFPGEcttNA4aZa6Sfac2jDaKa6jmnDI7NdmBbGGDshajC78Veqyspimylg1AKkUFoWmONusOhNW00jUFoW8pW9bMml)sDYi1HwKhaU6airI7NdmBbGGDQrzMegkQTTNpZ)seJzmqzcAozK6I62LGxuOFoqVK8YM1lZaHEnEbB5fj8YQjGMSAWlidy4vdhbjo8QHVOxaAV2HgrtYTZ)saHj9GWGTyuRrQ4(5aZZlBwkj0JtyA6udFXmGoVdnIMeSf0tyA6e3phy(h4(atMLFPOOgD78Veqyspimylg1AKkydMjlktzWY44s0rZcA58d0rOqjHECcttNA4aZa6Sfac2jDaKaAjEcttN4(5aZwaiyNAK)f6haU6airI7NdmBbGGDQrzMegksDBD78Veqyspimylg1AKQgoWmGoBbGGnLe6XjmnDI7Ndm)dCFGjZYVuJtyA6e3phy(h4(atYmuYMLFPGweA47n34pW9bMxImEYicf8HxmVez88zA47n34pW9bMxImEY4daxDaKiX9ZbMTaqWo1OmtcZ5ZImbgd0lrgZliRtWtgFa4QdGejUFoWSfac2PgLzsyevu3o)lbeM0dcd2IrTgPI7NdmltmgYfnusOhL5Gtw)EYiuFkONW00P)IC)SzjXrQr(xk)bMeJA72LGx2WHBsC41dcd2Irk9cc6Lzj3RxNwyZ6feowVwGxpiwsaJEfG1l9gyzrIdV(bUpqJxSXRlio8InEzbmgY8IjbGxsHOLxq1jChK4aQ6fB86cIdVyJxwaJHmVOxIWsXE9GWGTymlZb71o0OzyaC1f1lo09AhWWlde2YRf4f7f1afVOGKsefPWK72RhegSfJE1GLxcisEztP9cc6LoWRaSEnWIrVOgVOWPtPxqqVEo8sNy5L5sog2Rg86cGGTxlWRdC9I9IA2bVOWPN8YMb9IVgGxgyZYKWlE9I9AGCmGTxYCWEzH9JXYhOxqgWWliOxwxo8AbEbBqVyVO2Gd0laTxqfaeS9shUjXHxpimylg9YAGniLEzaEbb965WRjChEPd3K4WRDa9IAdoqVa0EbvaqWo525FjGWKEqyWwmQ1ivC)CG5j3nFGusOhfrKjmnDI7Ndm)dCFGjZYVuJtyA6e3phy(h4(atYmuYMLFPefArerMdoz97jJI5MWZlMEqyWwmML5Gf98zrEa4QdGejUFoWSfac2PgLzsyO4daxDaKi1WbMb0zlaeSt0W3BUXFG7dmVezeAzo4K1VNmkMBcpVy6bHbBXywMdwlQFkrf98zrw(IXM4(5aZGEMWGNxuh6haU6airI7Ndmd6zQrzMeMtgpEDOFa4QdGejUFoWSfac2PgLzsyOO22kQONplZbNS(9KrreZnHNxm9GWGTymlZblrABROUDj4LaSf2bqm7fX41KB8QbVGa6DWRNnljoO0lidKFWlIXlidAWlY6fX4Lb4fn3EPdGeu6fiUAWRtlSz9INaXOxuqYKxUD(xcimPhegSfJAnsLb2c7aiMPKqpkZbNS(9KrO(uUDj4LnmeT8cQoH7GehqvViHxma9YqwyEjGW4fCSKRxpimylgZYCWEz9BYlkqVy71oWRxG4QbVE2SErbBIxqi7GxA0lk0phOx)a3hOHsVmK4rVilu14fFLbM1lKAfMVEjZb71dmRxlWl2ln6Lz5xkVOGKEXHgGWAi5ffwV2bE9YcqI1lkaSjE1GLxci8cc5E9AIErbj9ckA0ljIIErbBIxsef9IctUB3o)lbeM0dcd2IrTgPI7NdmJqX6cmeqqjHEK)LigZyGYe0qXrncTiYCWjRFP4OyUj88IPhegSfJzzo4ZNNW00jUFoW8pW9bMml)snQrrD78Veqyspimylg1AKkUFoW88YM1TZ)saHj9GWGTyuRrQ4(5aZtUB(aD7UD(xcimjzGyugJD0mqKLXMsc9OmqmkJXM0jMLJhP4O22625FjGWKKbIrzmwTgPAEjHuusOhLbIrzm2KoXSC8ifh12w3o)lbeMKmqmkJXQ1ivwnAW4XmGoltcD3o)lbeMKmqmkJXQ1ivC)CGzzIXqUOXTZ)saHjjdeJYySAnsf3phyg0t3o)lbeMKmqmkJXQ1ivgylSdGywTQvPa]] )


end
