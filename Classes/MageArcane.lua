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
            id = function () return pvptalent.arcane_empowerment.enabled and 276743 or 263725 end,
            duration = 15,
            type = "Magic",
            max_stack = function () return pvptalent.arcane_empowerment.enabled and 3 or 1 end,
            copy = { 263725, 276743 }
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

        incanters_flow.reset()
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

            spend = function ()
                if not pvptalent.arcane_empowerment.enabled and buff.clearcasting.up then return 0 end
                return 0.1 * ( buff.arcane_power.up and ( talent.overpowered.enabled and 0.4 or 0.7 ) or 1 )
            end,
            spendType = "mana",

            startsCombat = true,
            texture = 136116,

            usable = function () return target.distance < 10 end,
            handler = function ()
                removeStack( "clearcasting" )
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
                removeStack( "clearcasting" )
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
            cooldown = function () return ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * 90 end,
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

            start = function ()
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

        potion = "potion_of_focused_resolve",

        package = "Arcane",
    } )


    spec:RegisterPack( "Arcane", 20200301, [[d0euqbqijv5rscUecvv1MKu(KqbgLqLtju1QikvEfLOzruCljj1Ue8lIQgMKkhtsQLruYZKeAAcf11ekY2qOkFdHQY4KKKoNqHADsscZts09us7JsOdkjXcPu8qHcAIssI4IsQkTrjvf1hrOQkNusvvReH8sjvfzMssI0njkv1ofk9tjjrnuHczPsQk8ucnvkLUkrPkFfHQk7Lu)LKbd5WOwSs9yOMmIUmyZs8zemAL40iTAjvvEnrLzRs3Mi7MQFRy4eCCeQSCrpNIPRQRRITtj9DHmEekNNsW6jkL5tPA)sTUATTArs(bDSYQozvxDvSUQdvhtYQozjlT4BbbqlkWy5ycGw0zjqlwLeZoOffylChMuBRw0mNedAXL)fmvfYlpb6VC2b8ijVHkDU8thhNC5L3qLWYRf3h69R)UERfj5h0XkR6KvD1vX6QouDmjR6QoM0IgbaRJL4jlT4cLKeC9wlscgSwScnQkjMDOrY(mbOjQcnA5FbtvH8YtG(lNDapsYBOsNl)0XXjxE5nujS8nrvOrY(CIxAu1Y0izvNSQRjQjQcnkgUWobWuv0evHgv1nY8C(Q9jDLWcBazAK5hb1(KUsyHnGmnIDYgXwHKjaQ9jD1fCc)sJ4eA0c7KxGSrBl0OFbAetsoEOjQcnQQB0Zjb4dpvcu)OiPqJQAl2O4EQeO(rrsH4BKzA0VWFJIGgroEm4BeqmmymuRW1cnAFsVrJ3OpzZsJOLgfbnIC8yW3Oi2)g9tOjQcnQQBKSNaj)qJeMNoEJUdbkoOfVuZB02QfXJBG0kOTvhB1AB1Im(PJRfLOzoPIkXeaTi48(cKAB0VowzPTvlcoVVaP2gTioPpKuwlUpLsGtm7GcVWjbiyEglxJwBuDArg)0X1I4fojaKQJG(1XwrTTArW59fi12OfXj9HKYAX4AucLeml8(cnYU9gvVg9uSCuNqJIVr1A0(ukboXSdk8cNeGG5zSCnATr7tPe4eZoOWlCsacsmXuMNXY1OAnAFkLqECqnfLWebzGCI8gvRr7tPe4eZoOeMiidKtKRfz8thxl6WVaP6bjbW86xhBmRTvlcoVVaP2gTioPpKuwlUpLsGtm7GcVWjbiyEglxJQCTrYQr1AuCncpZLCI8aNy2bLWebzibjM6MgzXgvDDnYU9gX4NAfuGdsuW0OkxBKSAu8Arg)0X1ICIzhutU1Vo2ysBRweCEFbsTnArCsFiPSwCFkLqEUGAkQFjbWeocnQwJ2NsjWjMDqHx4KaempJLRrwSrvulY4NoUwKtm7GAFzZRFDSepTTArW59fi12Ofz8thxl(usW8tkPWdjqmTioPpKuwlUpLsipoOMIsyIGmqorEJQ1O61O9PucCIzhucteKHey83OAncpZLCI8aNy2bLWebzibjM6MgzXgjR60IolbAXNscMFsjfEibIPFDSeFAB1IGZ7lqQTrlY4NoUweBb8D(CCkwTVS51I4K(qszT4(ukH84GAkkHjcYa5e5nQwJQxJ2NsjWjMDqjmrqgsGXFJQ1i8mxYjYdCIzhucteKHeKyQBAKfBKSQtlcLcGFLZsGweBb8D(CCkwTVS51Vo2QQ2wTi48(cKAB0I4K(qszT4(ukboXSdk8cNeGG5zSCnATr7tPe4eZoOWlCsacsmXuMNXY1OAnkUgvo3Rkb8cNea1tLGgv5AJaIb4ZdQNkbnYU9gvo3Rkb8cNea1tLGgv5AJWZCjNipWjMDqjmrqgsqIPUPr2T3ONkbQFuKuOrvU2i8mxYjYdCIzhucteKHeKyQBAu8Arg)0X1I5Xb1uucteK6xhBmwBRweCEFbsTnArg)0X1ICIzhusuJHEbJweVWuxlwTweN0hskRfLyNdc4VrvU2OyCm1OAnAFkLa(cCIzZtDcHey83OAnIXp1kOahKOGPrv2OkQFDSvxN2wTi48(cKAB0I4K(qszTyCnkUgTpLsGtm7GcVWjbiyEglxJwB0(ukboXSdk8cNeGGetmL5zSCnk(gvRrX1O4AKe7Cqa)nQY1gzLtkVVqapUbsRGsIDUrX3i72BuCn65l4FipoOMIsyIGmaoVVazJQ1i8mxYjYdCIzhucteKHeKyQBAKfBeEMl5e5H84GAkkHjcYq5CVQeWlCsaupvcAuTgjXoheWFJQCTrw5KY7leWJBG0kOKyNBKLnswXuJIVrX3i72BuCn65l4FGtm7GAYDaCEFbYgvRr4zUKtKh4eZoOMChsqIPUPrvU2icyYgvRr4zUKtKh4eZoOeMiidjiXu30il2OQRRrX3O4BKD7nsIDoiG)gv5AJIRrw5KY7leWJBG0kOKyNBuv3OQRRrXRfz8thxlYjMDqT5mzcG(1XwD1AB1IGZ7lqQTrlIt6djL1IsSZbb83OkxBumoM0Im(PJRfnhbi9XkRFDSvllTTArW59fi12OfXj9HKYArg)uRGcCqIcMgzX1gvXgvRrX1ij25Ga(BKfxBKvoP8(cb84giTckj25gz3EJ2NsjWjMDqHx4KaempJLRrRnQInkETiJF64AroXSdkGyc3Xqhx)6yRUIAB1Im(PJRf5eZoO2x28ArW59fi12OFDSvhZAB1Im(PJRf5eZoO2CMmbqlcoVVaP2g9RFTiju4Z912QJTATTArg)0X1I454pKgb4E1IGZ7lqQTr)6yLL2wTiJF64ArJaCVMh4RweCEFbsTn6xhBf12Qfz8thxlMG0yfu4tAaTi48(cKAB0Vo2ywBRweCEFbsTnArg)0X1Iy(Evm(PJRUuZRfVuZRCwc0IGXaogm6xhBmPTvlcoVVaP2gTiJF64Arw2mlCYgvz8xnfLWebPweN0hskRf3NsjKhhutrjmrqgiNiVr1A0(ukboXSdkHjcYa5e5nQwJIRr4zUKtKh4eZoOeMiidjiXu30OkxBum3ilBu111izxJSYjL3xiug)vKZzFb14QJbAuTgHN5sorEaSoy(PJhsqIPUPrvU2iRCs59fcSvizcGAFsxDbNWV0ilBum3ilBu111izxJSYjL3xiug)vKZzFb14QJbAKD7n6PsG6hfjfAuLncpZLCI8aNy2bLWebzibjM6MgfVw0zjqlYYMzHt2OkJ)QPOeMii1VowIN2wTi48(cKAB0I4K(qszT4(KUsyHnqJSBVrX1ONkbQFuKuOrv2i2kKmbqTpPRUGt4xAu8Arg)0X1Iy(Evm(PJRUuZRfVuZRCwc0I7t66xhlXN2wTi48(cKAB0I4K(qszTyCncpZLCI8aNy2bLWebzibjM6MgT2O6AuTgHN5sorEaSoy(PJhsqIPUPrvU2i2kKmbqTpPRUGt4xAuTgfxJ2NsjWjMDqHx4KaempJLRrRnAFkLaNy2bfEHtcqqIjMY8mwUgz3EJIRrpFb)d4fojaKQJqaCEFbYgvRr4zUKtKhWlCsaivhHqcsm1nnATr11OAnAFkLaNy2bfEHtcqW8mwUgv5AJQUrX3O4Bu8Arg)0X1Iy(Evm(PJRUuZRfVuZRCwc0I7t66xhBvvBRweCEFbsTnArCsFiPSwSEnAFsxjSWgqlY4NoUweZ3RIXpDC1LAET4LAELZsGwepUbsRG(1XgJ12QfbN3xGuBJwKXpDCTiMVxfJF64Ql18AXl18kNLaTO0yfKa)1V(1IcjGhPn)AB1XwT2wTiJF64AroXSdkQ)W9c4xlcoVVaP2g9RJvwAB1Im(PJRfnhjPXvCIzhufwIEPCQfbN3xGuBJ(1XwrTTArW59fi12OfhbTObETiJF64ArRCs59f0Iw57b0IeV6AKLnsw11izxJyzds6dbG4ouHHAGa48(cKArRCQCwc0I4XnqAfusSZ6xhBmRTvlcoVVaP2gT4iOfnWRfz8thxlALtkVVGw0kFpGweiUdvqaidSSzw4KnQY4VAkkHjcYgvRrX1iG4oubbGmiXoTaMFutrjXKoymnYU9gbe3HkiaKbcxMKY)Kg1MjjanYU9gbe3HkiaKbcxMKY)KgLeqY3lD8gz3EJaI7qfeaYaLGtF64kjMayuLJbAKD7nciUdvqaidVSXoyuBoLZiqDW0i72BeqChQGaqgyz7KWVmgLH6easLW9iXeGgz3EJaI7qfeaYa7yk4VsoFE1uurud5i1i72BeqChQGaqgmldwUn9H0OkStOr2T3iG4oubbGm4Wj5RYybNfmGc8f2Xq2i72BeqChQGaqg28fk0eu7KD8sJIxlALtLZsGwSm(RiNZ(cQXvhdOFDSXK2wTi48(cKAB0IJGw0aVwKXpDCTOvoP8(cArR89aAXQLLweN0hskRfTYjL3xiug)vKZzFb14QJbAuTgzLtkVVqOm(RMIsyIGujKaEK28RWlS7WTrRnQoTOvovolbAXY4VAkkHjcsLqc4rAZVcVWUdx9RJL4PTvlcoVVaP2gTOZsGwKLnZcNSrvg)vtrjmrqQfz8thxlYYMzHt2OkJ)QPOeMii1VowIpTTArg)0X1Is0mNurLycGweCEFbsTn6xhBvvBRwKXpDCTOW80X1IGZ7lqQTr)6yJXAB1Im(PJRf5eZoO2x28ArW59fi12OF9Rf3N012QJTATTArW59fi12OfXj9HKYAX9PucCIzhu4fojabZZy5AuLRnQATiJF64Ar8cNeas1rq)6yLL2wTiJF64ArjAMtQOsmbqlcoVVaP2g9RJTIAB1IGZ7lqQTrlIt6djL1IX1Oekjyw49fAKD7nQEn6Py5OoHgfFJQ1O9PucCIzhu4fojabZZy5A0AJ2NsjWjMDqHx4KaeKyIPmpJLRr1A0(ukH84GAkkHjcYa5e5nQwJ2NsjWjMDqjmrqgiNixlY4NoUw0HFbs1dscG51Vo2ywBRweCEFbsTnArCsFiPSwCFkLqEUGAkQFjbWeocnQwJE(c(hgRqkmrqcKbW59fiBuTgX4NAfuGdsuW0OkBuf1Im(PJRf5eZoO2x286xhBmPTvlcoVVaP2gTioPpKuwlUpLsGtm7GsyIGmqorUwKXpDCT4Lsy5nQ63HKGe4V(1Xs802QfbN3xGuBJweN0hskRf3NsjWjMDqjmrqgiNixlY4NoUwCZeutr9jflNr)6yj(02QfbN3xGuBJweN0hskRfRxJ2NsjWjMDqjmrqgocnQwJIRrsSZbb83ilU2OyQUgz3EJWZCjNipWjMDqjmrqgsqIPUPrRnQUgfFJQ1O4A0(ukboXSdk8cNeGG5zSCnATr7tPe4eZoOWlCsacsmXuMNXY1O41Im(PJRfZJdQPOeMii1Vo2QQ2wTiJF64AXnKgiLJ6e0IGZ7lqQTr)6yJXAB1Im(PJRf5eZoOeMii1IGZ7lqQTr)6yRUoTTArW59fi12OfXj9HKYAX9PucCIzhucteKHJqJSBVrpvcu)OiPqJQSr4zUKtKh4eZoOeMiidjiXu3Ofz8thxlEmGI(GKr)6yRUATTArg)0X1I77mKQYjTGweCEFbsTn6xhB1YsBRwKXpDCTyHMW(odPweCEFbsTn6xhB1vuBRwKXpDCTi7yW8jFvy(E1IGZ7lqQTr)6yRoM12QfbN3xGuBJweN0hskRfJRrpFb)d5Xb1uucteKbW59fiBuTgTpLsipoOMIsyIGmKGetDtJQCTr7tPeesWaogutrjrDYGetmL5zSCns21ig)0XdCIzhu7lB(aqmaFEq9ujOrX3i72B0(ukboXSdkHjcYqcsm1nnQY1gTpLsqibd4yqnfLe1jdsmXuMNXY1izxJy8thpWjMDqTVS5daXa85b1tLaTiJF64ArHemGJb1uusuNu)6yRoM02QfbN3xGuBJweN0hskRf3NsjWjMDqjmrqgocnQwJIRrX1O61iWyahdb84KGBas1LwGYKyiiX1VjBKD7ncmgWXqapoj4gGuDPfOmjgcj7Y1OkBKSAu8nQwJIRr7tPe2qAGuoQtiCeAKD7nAFkLW(odPQCsleocnYU9gvVgfxJsgdHpN7Tr2T3OKXqysCJIVrX3i72B0(ukbchojPSRMIILniNFjCeAu8nYU9g9ujq9JIKcnQYgHN5sorEGtm7GsyIGmKGetDJwKXpDCTOW80X1Vo2QjEAB1IGZ7lqQTrlIt6djL1I7tPe4eZoOWlCsacMNXY1O1gvxJSBVrX1ig)uRGcCqIcMgvzJQyJSBVrX1ig)uRGcCqIcMgvzJKvJQ1ONVG)HemJZogcGZ7lq2O4Bu8Arg)0X1ICIzhutU1Vo2Qj(02QfbN3xGuBJweN0hskRfz8tTckWbjkyAKfxBufBuTgfxJ2NsjWjMDqHx4KaempJLRrRnAFkLaNy2bfEHtcqqIjMY8mwUgfVwKXpDCTiNy2b1MZKja6xhB1vvTTArW59fi12OfXj9HKYArg)uRGcCqIcMgzX1gvrTiJF64AroXSdkGyc3Xqhx)6yRogRTvlcoVVaP2gTiJF64AroXSdkjQXqVGrlIxyQRfRwlIt6djL1I7tPeWxGtmBEQtiKaJ)gvRrm(Pwbf4GefmnQYgvXgvRrX1ONVG)bws4slum)0XdGZ7lq2i72BuCnQEn65l4FyScPWebjqgaN3xGSr1AelBqsFiWjMDqjCKKGl1jes2LRrwCTrYQrX3i72B0(ukboXSdkHjcYa5e5nkE9RJvw1PTvlcoVVaP2gTioPpKuwlY4NAfuGdsuW0OkBuf1Im(PJRf5eZoO2x286xhRSQwBRwK6pK5r4v0IwuIDoiGFlUwvJjTi1FiZJWROssajLFqlwTwKXpDCTiyDW8thxlcoVVaP2g9RJvwYsBRwKXpDCTiNy2b1MZKjaArW59fi12OF9RfLgRGe4V2wDSvRTvlcoVVaP2gTioPpKuwlknwbjW)aj18SJHgzX1gvDDArg)0X1I7l1Lt)6yLL2wTi48(cKAB0I4K(qszTO0yfKa)dKuZZogAKfxBu11Pfz8thxlUVuxo9RJTIAB1Im(PJRffsWaogutrjrDsTi48(cKAB0Vo2ywBRwKXpDCTiNy2bLe1yOxWOfbN3xGuBJ(1XgtAB1Im(PJRf5eZoOMCRfbN3xGuBJ(1Xs802Qfz8thxlAocq6JvwlcoVVaP2g9RFTiymGJbJ2wDSvRTvlcoVVaP2gTioPpKuwlUpPRewyd0OAnAFkLaNy2bLWebzGCI8gvRr7tPeYJdQPOeMiidKtK3OAnAFkLaNy2bfEHtcqW8mwUgT2O9PucCIzhu4fojabjMykZZy5AKD7n6PsG6hfjfAuLncpZLCI8aNy2bLWebzibjM6gTiJF64AX9Dgs1uu)cOahKSG(1XklTTArW59fi12Ofz8thxlIhhd(N8dKQYLLaTioPpKuwlUpLsipoOMIsyIGmqorEJQ1O9PucCIzhucteKbYjYBuTgfxJQxJ2N0vclSbAKD7n6PsG6hfjfAuLncpZLCI8aNy2bLWebzibjM6MgfFJQ1ij25WtLa1pkjMynYIRncigGppOEQeOfVuhuysTiXt)6yRO2wTi48(cKAB0I4K(qszT4(ukH84GAkkHjcYa5e5nQwJ2NsjWjMDqjmrqgiNiVr1AuCnQEnAFsxjSWgOr2T3ONkbQFuKuOrv2i8mxYjYdCIzhucteKHeKyQBAu8nQwJKyNdpvcu)OKyI1ilU2iGya(8G6PsGwKXpDCTycSa1jOkxwcm6xhBmRTvlcoVVaP2gTioPpKuwlUpLsipoOMIsyIGmqorEJQ1O9PucCIzhucteKbYjY1Im(PJRfld(yasflBqsFqTbws)6yJjTTArW59fi12OfXj9HKYAX9Puc5Xb1uucteKbYjYBuTgTpLsGtm7GsyIGmqorUwKXpDCTiHdNKu2vtrXYgKZVOFDSepTTArW59fi12OfXj9HKYAX9Puc5Xb1uucteKbYjYBuTgTpLsGtm7GsyIGmqorUwKXpDCTOWjPflqDcQ9LnV(1Xs8PTvlcoVVaP2gTioPpKuwlUpLsipoOMIsyIGmqorEJQ1O9PucCIzhucteKbYjY1Im(PJRftQGWfuuxzeymOFDSvvTTArW59fi12OfXj9HKYAX9Puc5Xb1uucteKbYjYBuTgTpLsGtm7GsyIGmqorUwKXpDCT4VaQJVNJtQktIb9RJngRTvlcoVVaP2gTioPpKuwlwVgTpPRewyd0OAnAFkLaNy2bLWebzGCI8gvRr4zUKtKh4eZoOeMiidjiXu30OAnAFkLaNy2bfEHtcqW8mwUgT2O9PucCIzhu4fojabjMykZZy5AuTgfxJQxJE(c(hYJdQPOeMiidGZ7lq2i72BeJF64H84GAkkHjcYaEHtcGPrX3i72B0tLa1pksk0OkBeEMl5e5boXSdkHjcYqcsm1nArg)0X1IsG0Kwqnf19GPKkYeyjJ(1XwDDAB1IGZ7lqQTrlIt6djL1I7t6kHf2anQwJ2NsjWjMDqjmrqgiNiVr1A0(ukH84GAkkHjcYa5e5nQwJ2NsjWjMDqHx4KaempJLRrRnAFkLaNy2bfEHtcqqIjMY8mwUgz3EJEQeO(rrsHgvzJWZCjNipWjMDqjmrqgsqIPUrlY4NoUwmAYlPvG6QemJZog0V(1Vw0kKg646yLvDYQU6QwwXSwmItN6emAX6VKWKpq2iIxJy8thVrxQ5nHMiTOqof6f0IvOrvjXSdns2NjanrvOrl)lyQkKxEc0F5Sd4rsEdv6C5Nooo5YlVHkHLVjQcns2Nt8sJQwMgjR6KvDnrnrvOrXWf2jaMQIMOk0OQUrMNZxTpPRewyditJm)iO2N0vclSbKPrSt2i2kKmbqTpPRUGt4xAeNqJwyN8cKnABHg9lqJysYXdnrvOrvDJEojaF4PsG6hfjfAuvBXgf3tLa1pkskeFJmtJ(f(Bue0iYXJbFJaIHbJHAfUwOr7t6nA8g9jBwAeT0OiOrKJhd(gfX(3OFcnrvOrvDJK9ei5hAKW80XB0DiqXHMOMOk0O6lXa85bYgTHYKqJWJ0M)gTbcu3eAuvWyq4nnYhVQx4uQCUnIXpDCtJg)AHqtufAeJF64MGqc4rAZ)A5Yg5AIQqJy8th3eesapsB(TCv(YmKnrvOrm(PJBccjGhPn)wUkpFiib(ZpD8Mig)0XnbHeWJ0MFlxLNtm7GI6pCVa(BIy8th3eesapsB(TCvEoXSdQclrVuoBIQqJWJBG0kOKyNBe10OFbAKe7CJeGed(ZeGgfbnkI9Vr)0ictJiNiVr)0iYtsDcncpUbsRqOr1)VroaKMg9tJUaBfAe4ZHWsJYzKA0pnkAsZ3imBGgzWGZjDAKrGLAuvSPrJFTqJipj1j0OQeJcnrm(PJBccjGhPn)wUkVvoP8(cY4SeSIh3aPvqjXolZiSAGxgR89aReV6Suw1j7yzds6dbG4ouHHAGa48(cKnrm(PJBccjGhPn)wUkVvoP8(cY4SeSwg)vKZzFb14QJbKzewnWlJv(EGvG4oubbGmWYMzHt2OkJ)QPOeMiiRfhqChQGaqgKyNwaZpQPOKyshmg72bI7qfeaYaHlts5FsJAZKea72bI7qfeaYaHlts5FsJsci57LoUD7aXDOccazGsWPpDCLetamQYXa2Tde3HkiaKHx2yhmQnNYzeOoySBhiUdvqaidSSDs4xgJYqDcaPs4EKycGD7aXDOccazGDmf8xjNpVAkQiQHCKSBhiUdvqaidMLbl3M(qAuf2jy3oqChQGaqgC4K8vzSGZcgqb(c7yiTBhiUdvqaidB(cfAcQDYoEj(Mig)0XnbHeWJ0MFlxL3kNuEFbzCwcwlJ)QPOeMiivcjGhPn)k8c7oCLzewnWlJv(EG1QLLm0YQvoP8(cHY4VICo7lOgxDmqnRCs59fcLXF1uucteKkHeWJ0MFfEHDhUR11eX4NoUjiKaEK28B5Q8hdOOpijJZsWklBMfozJQm(RMIsyIGSjIXpDCtqib8iT53Yv5LOzoPIkXeGMig)0XnbHeWJ0MFlxLxyE64nrm(PJBccjGhPn)wUkpNy2b1(YMVjQjQcnQ(smaFEGSrGviTqJEQe0OFbAeJ)jBe10i2ktV8(cHMig)0XnR454pKgb4EBIy8th3y5Q8gb4EnpW3Mig)0XnwUkFcsJvqHpPbAIy8th3y5Q8y(Evm(PJRUuZlJZsWkymGJbtteJF64glxL)yaf9bjzCwcwzzZSWjBuLXF1uucteKYqlR7tPeYJdQPOeMiidKtKxBFkLaNy2bLWebzGCI8AXHN5sorEGtm7GsyIGmKGetDtLRXSLvxNSZkNuEFHqz8xroN9fuJRogOgEMl5e5bW6G5NoEibjM6MkxTYjL3xiWwHKjaQ9jD1fCc)ILXSLvxNSZkNuEFHqz8xroN9fuJRogWU9NkbQFuKuOs8mxYjYdCIzhucteKHeKyQBIVjQcnI4VPr)0iBoP3Oy0cBGgfTaEJ4BcmPfA0(Ko1jitJMSrrlG3O9ymnkIEVnIKcnYmJhAIy8th3y5Q8y(Evm(PJRUuZlJZsW6(KUm0Y6(KUsyHnGD7X9ujq9JIKcvYwHKjaQ9jD1fCc)s8nrvOrIpNFJS5KEJIrlSbAu0c4nQkjMDOrXOjcYgrnnkbM0cnIDYgvFToy(PJ3Oi692On0Oeysl0O4gVrSvizcq8nAdLjHg9lqJ2N0BKWcBGgrnnASczOrv5AMgjXYbnYCsOrrqJimFJI5gvLeZo0Oy4cNeaJmnAYgHzVreGVrXCJQsIzhAumCHtcGPrr0FPrXWfojaKns2ti0eX4NoUXYv5X89Qy8thxDPMxgNLG19jDzOL14WZCjNipWjMDqjmrqgsqIPUzTUA4zUKtKhaRdMF64HeKyQBQCLTcjtau7t6Ql4e(LAXTpLsGtm7GcVWjbiyEgl36(ukboXSdk8cNeGGetmL5zSC2Th3ZxW)aEHtcaP6ieaN3xGSgEMl5e5b8cNeas1riKGetDZAD12NsjWjMDqHx4KaempJLRY1QJp(4BIy8th3y5Q8y(Evm(PJRUuZlJZsWkECdKwbzOL16TpPRewyd0eX4NoUXYv5X89Qy8thxDPMxgNLGvPXkib(3e1evHgv)DCcsG)nAozJ2N0BKWcBGgHNJ)qgAeXVfWbRq2OiOrG)q2OFbAeAFsh1ig)0XnnkI(lZ5B0gOoHgr9gXnAFsVrclSbKPr0Vrsa7Mg9l83OiOrCcnI3Z5B0pnY8C(nACi0evHgX4NoUjSpPVALtkVVGmolbR)88vTpPBKzewzsszSY3dSwTm0YA92N0vclSbAIQqJy8th3e2N0TCvEZZ5R2N0vclSbKHwwR3(KUsyHnqtufAu91jB0VanAFsVrclSbAu0c4nkcAu97y(gbwhm)azOjQcnIXpDCtyFs3Yv5n)iO2N0vclSbKHww3N0vclSbQjKGvfbmzO6ayDW8thVwCpvcu)OiPq8w0kNuEFHaBfsMaO2N0vxWj8l12N0vclSbuKNKF64wSUMOk0OQsbJPr)c7nQ6grDZdmzJMsJaI7WxtJ(Pr1jtJ2aMpgOrtPrcju1y28nQkjMDOr2CzZ3eX4NoUjSpPB5Q84fojaKQJGm0Y6(ukboXSdk8cNeGG5zSCvUwDteJF64MW(KULRYlrZCsfvIjanrm(PJBc7t6wUkVd)cKQhKeaZldTSgxcLeml8(c2TxVNILJ6eIV2(ukboXSdk8cNeGG5zSCR7tPe4eZoOWlCsacsmXuMNXYvBFkLqECqnfLWebzGCI8A7tPe4eZoOeMiidKtK3evHgr8Bb8gLh3PoHgvv2kKcteKaPmnIDYgfbnIW8nIBu9X5cnAknY2LeatJeYb3O4Qs9PQ0OiOreMVrZjBum)lnQkjMDOrXWfojanYkLBumCHtcazJK9eIxMgDmqJOFJ2qzsOrhd1j0O6JjgzzvIrY0OnG5JbA0VansIDUrjqEWpD8grnnA(fiJOgOrxojaxl0Oi28azJmuhdn6xGgvfBAueBAujbOrSBHi2cHMig)0XnH9jDlxLNtm7GAFzZldTSUpLsipxqnf1VKaychHApFb)dJvifMiibYa48(cK1y8tTckWbjkyQSInrm(PJBc7t6wUk)Lsy5nQ63HKGe4Vm0Y6(ukboXSdkHjcYa5e5nrm(PJBc7t6wUk)MjOMI6tkwoJm0Y6(ukboXSdkHjcYa5e5nrm(PJBc7t6wUkFECqnfLWebPm0YA92NsjWjMDqjmrqgoc1ItIDoiGFlUgt1z3oEMl5e5boXSdkHjcYqcsm1nR1fFT42NsjWjMDqHx4KaempJLBDFkLaNy2bfEHtcqqIjMY8mwU4BIy8th3e2N0TCv(nKgiLJ6eAIy8th3e2N0TCvEoXSdkHjcYMig)0XnH9jDlxL)yaf9bjJm0Y6(ukboXSdkHjcYWrWU9NkbQFuKuOs8mxYjYdCIzhucteKHeKyQBAIy8th3e2N0TCv(9Dgsv5KwOjIXpDCtyFs3Yv5l0e23ziBIy8th3e2N0TCvE2XG5t(QW892eX4NoUjSpPB5Q8cjyahdQPOKOoPm0YACpFb)d5Xb1uucteKbW59fiRTpLsipoOMIsyIGmKGetDtLR7tPeesWaogutrjrDYGetmL5zSCYog)0XdCIzhu7lB(aqmaFEq9ujiE723NsjWjMDqjmrqgsqIPUPY19PuccjyahdQPOKOozqIjMY8mwozhJF64boXSdQ9LnFaigGppOEQe0eX4NoUjSpPB5Q8cZthxgAzDFkLaNy2bLWebz4iulU4QhymGJHaECsWnaP6slqzsmeK463K2Tdgd4yiGhNeCdqQU0cuMedHKD5QuwXxlU9PucBinqkh1jeoc2TVpLsyFNHuvoPfchb72RxCjJHWNZ9A3EYyimjo(4TBFFkLaHdNKu2vtrXYgKZVeocXB3(tLa1pkskujEMl5e5boXSdkHjcYqcsm1nnrm(PJBc7t6wUkpNy2b1KBzOL19PucCIzhu4fojabZZy5wRZU94y8tTckWbjkyQSI2ThhJFQvqboirbtLYQ2ZxW)qcMXzhdbW59fiJp(Mig)0XnH9jDlxLNtm7GAZzYeazOLvg)uRGcCqIcglUwXAXTpLsGtm7GcVWjbiyEgl36(ukboXSdk8cNeGGetmL5zSCX3eX4NoUjSpPB5Q8CIzhuaXeUJHoUm0YkJFQvqboirbJfxRytufAu9NGpj0OQKy2Hgj7tng6fmnI8KuNqJQsIzhAumAIGuMgXgkj0OsosnYmsqJScPfAKraW0cf3iGyyq4PJBKPrxQCqJ85B0cBL6eAuvzRqkmrqcKn65l4pq2OAnkpUtDcnQIeRrvjXSdnkgDKKGl1jeAIy8th3e2N0TCvEoXSdkjQXqVGrgAzDFkLa(cCIzZtDcHey8xJXp1kOahKOGPYkwlUNVG)bws4slum)0XdGZ7lqA3EC175l4FyScPWebjqgaN3xGSglBqsFiWjMDqjCKKGl1jes2LZIRYkE723NsjWjMDqjmrqgiNipEzWlm1xRUjIXpDCtyFs3Yv55eZoO2x28YqlRm(Pwbf4GefmvwXMOk0OyNOg9l83OiigKqJihhA0(Ko1jitJIGgHzVrhbs(Hg9lqJyRqYea1(KU6coHFPrr0FPr)c0Ol4e(LgnLg9lutJ2N0dnrvOrm(PJBc7t6wUkVvoP8(cY4SeSYwHKjaQ9jD1fCc)ImJWQbEzSY3dSgNvoP8(cb2kKmbqTpPRUGt4xKDw5KY7le(55RAFs3u1w5KY7leyRqYea1(KU6coHFXY42N0vclSbuKNKF64XhpX)w5KY7le(55RAFs30eX4NoUjSpPB5Q8G1bZpDCzO(dzEeEfTSkXoheWVfxRQXKmu)HmpcVIkjbKu(H1QBIQqJQppzJ(fOrjNqJgmMn0XBu0cKqJIGgryA0msnAdLjHgbwhm)0XBe10OnJLRrhHqJIt2ZC471cnAdy(yGgfbnIa8nYkKwOrBMSrPtOrMPr)c0O9j9grnncF(gzfsl0iZYKF8nrm(PJBc7t6wUkpNy2b1MZKjanrnrm(PJBc4XnqAfwLOzoPIkXeGMig)0Xnb84giTcwUkpEHtcaP6iidTSUpLsGtm7GcVWjbiyEgl3ADnrm(PJBc4XnqAfSCvEh(fivpijaMxgAznUekjyw49fSBVEpflh1jeFT9PucCIzhu4fojabZZy5w3NsjWjMDqHx4KaeKyIPmpJLR2(ukH84GAkkHjcYa5e512NsjWjMDqjmrqgiNiVjIXpDCtapUbsRGLRYZjMDqn5wgAzDFkLaNy2bfEHtcqW8mwUkxLvT4WZCjNipWjMDqjmrqgsqIPUXIvxND7m(Pwbf4GefmvUkR4BIQqJQsIzhAKnx28nYSqlVPrhHgr9gjK0jPVfAu0c4nkpUtDcnkpxOrtPr)scGj0eX4NoUjGh3aPvWYv55eZoO2x28YqlR7tPeYZfutr9ljaMWrO2(ukboXSdk8cNeGG5zSCwSInrm(PJBc4XnqAfSCv(Jbu0hKKXzjy9PKG5NusHhsGyYqlR7tPeYJdQPOeMiidKtKxRE7tPe4eZoOeMiidjW4VgEMl5e5boXSdkHjcYqcsm1nwuw11eX4NoUjGh3aPvWYv5pgqrFqsgOua8RCwcwXwaFNphNIv7lBEzOL19Puc5Xb1uucteKbYjYRvV9PucCIzhucteKHey8xdpZLCI8aNy2bLWebzibjM6glkR6AIy8th3eWJBG0ky5Q85Xb1uucteKYqlR7tPe4eZoOWlCsacMNXYTUpLsGtm7GcVWjbiiXetzEglxT4kN7vLaEHtcG6PsqLRaXa85b1tLa72lN7vLaEHtcG6PsqLR4zUKtKh4eZoOeMiidjiXu3y3(tLa1pksku5kEMl5e5boXSdkHjcYqcsm1nX3eX4NoUjGh3aPvWYv55eZoOKOgd9cgzOLvj25Ga(RCnght12NsjGVaNy28uNqibg)1y8tTckWbjkyQSIYGxyQVwDtufAuvjNK6eAeECdKwbzAue0iZtV3gv)oMVrrS)n6NgHh)P(bAKpFJiZrqG6eAeEHtcGPrSPr3Xj0i20iHXyO7leeNgjhacnkgSpPtDcXGgXMgDhNqJytJegJHUVqJIJLJBeECdKwbLe7CJ(LemllZLm(gXozJ(fWBKjIfA0pnIBumtSgvfBQAlwLnNzJWJBG0k0OCE(PJhAu9V0OiOrKtJ85B0cBfAum3OQedLPrrqJWS3isQqJmxkHL)AHgDNiiB0pnIa8nIBum)lnQkXWqJi(bnIVMPrMJ5zQ3i(Be3OfkHfiBKe7CJeGed(ZeGgfTaEJIGgjCzVr)0OJbAe3O6JJdnAknkgnrq2iYtsDcncpUbsRqJewyditJmtJIGgHzVr7t6nI8KuNqJ(fOr1hhhA0uAumAIGm0eX4NoUjGh3aPvWYv55eZoO2CMmbqgAznU42NsjWjMDqHx4KaempJLBDFkLaNy2bfEHtcqqIjMY8mwU4RfxCsSZbb8x5QvoP8(cb84giTckj254TBpUNVG)H84GAkkHjcYa48(cK1WZCjNipWjMDqjmrqgsqIPUXI4zUKtKhYJdQPOeMiidLZ9QsaVWjbq9ujOMe7Cqa)vUALtkVVqapUbsRGsID2szftXhVD7X98f8pWjMDqn5oaoVVazn8mxYjYdCIzhutUdjiXu3u5kbmzn8mxYjYdCIzhucteKHeKyQBSy11fF82TlXoheWFLRXzLtkVVqapUbsRGsIDUQRUU4BIQqJepcq6JvUrutJ2Ccxl0OOj)LgHzZtDcY0OOfkEPrutJIwSqJOFJOMgzMgv4SrKtKltJg)AHgv)oMVr8EScnQk2eAuteJF64MaECdKwblxL3CeG0hRSm0YQe7Cqa)vUgJJPMOk0O6tai0OyW(Ko1jedAe1BepqJm0)WpDCtJo(tVncpUbsRGsIDUrc4p0OQuEiB0VWFJg)AHgHzZ3OQuFBue9xAufBuvsm7qJWlCsamY0id1XqJOFmW0i(knMVraXD4BJKyNBeEmFJ(PrCJQyJmpJLRrvXMgXUfIyleAuv(g9l83iHH6FJQYuFBuop)0XBue9EB0gAuvSPreRIvTfRs9TQTyv2CMnrm(PJBc4XnqAfSCvEoXSdkGyc3XqhxgAzLXp1kOahKOGXIRvSwCsSZbb8BXvRCs59fc4XnqAfusSZ2TVpLsGtm7GcVWjbiyEgl3AfJVjIXpDCtapUbsRGLRYZjMDqTVS5BIy8th3eWJBG0ky5Q8CIzhuBotMa0e1eX4NoUjagd4yWSUVZqQMI6xaf4GKfKHww3N0vclSbQTpLsGtm7GsyIGmqorET9Puc5Xb1uucteKbYjYRTpLsGtm7GcVWjbiyEgl36(ukboXSdk8cNeGGetmL5zSC2T)ujq9JIKcvIN5sorEGtm7GsyIGmKGetDtteJF64MaymGJbJLRYJhhd(N8dKQYLLazUuhuyYvINm0Y6(ukH84GAkkHjcYa5e512NsjWjMDqjmrqgiNiVwC1BFsxjSWgWU9NkbQFuKuOs8mxYjYdCIzhucteKHeKyQBIVMe7C4PsG6hLetmlUcedWNhupvcAIy8th3eaJbCmySCv(eybQtqvUSeyKHww3NsjKhhutrjmrqgiNiV2(ukboXSdkHjcYa5e51IRE7t6kHf2a2T)ujq9JIKcvIN5sorEGtm7GsyIGmKGetDt81KyNdpvcu)OKyIzXvGya(8G6PsqteJF64MaymGJbJLRYxg8XaKkw2GK(GAdSKm0Y6(ukH84GAkkHjcYa5e512NsjWjMDqjmrqgiNiVjIXpDCtamgWXGXYv5jC4KKYUAkkw2GC(fzOL19Puc5Xb1uucteKbYjYRTpLsGtm7GsyIGmqorEteJF64MaymGJbJLRYlCsAXcuNGAFzZldTSUpLsipoOMIsyIGmqorET9PucCIzhucteKbYjYBIy8th3eaJbCmySCv(KkiCbf1vgbgdYqlR7tPeYJdQPOeMiidKtKxBFkLaNy2bLWebzGCI8Mig)0XnbWyahdglxL)xa1X3ZXjvLjXGm0Y6(ukH84GAkkHjcYa5e512NsjWjMDqjmrqgiNiVjIXpDCtamgWXGXYv5LaPjTGAkQ7btjvKjWsgzOL16TpPRewyduBFkLaNy2bLWebzGCI8A4zUKtKh4eZoOeMiidjiXu3uBFkLaNy2bfEHtcqW8mwU19PucCIzhu4fojabjMykZZy5Qfx9E(c(hYJdQPOeMiidGZ7lqA3oJF64H84GAkkHjcYaEHtcGjE72FQeO(rrsHkXZCjNipWjMDqjmrqgsqIPUPjIXpDCtamgWXGXYv5JM8sAfOUkbZ4SJbzOL19jDLWcBGA7tPe4eZoOeMiidKtKxBFkLqECqnfLWebzGCI8A7tPe4eZoOWlCsacMNXYTUpLsGtm7GcVWjbiiXetzEglND7pvcu)OiPqL4zUKtKh4eZoOeMiidjiXu30e1eX4NoUjinwbjW)vZcvscszOLvPXkib(hiPMNDmyX1QRRjIXpDCtqAScsG)wUk)(sD5KHwwLgRGe4FGKAE2XGfxRUUMig)0XnbPXkib(B5Q8cjyahdQPOKOozteJF64MG0yfKa)TCvEoXSdkjQXqVGPjIXpDCtqAScsG)wUkpNy2b1K7Mig)0XnbPXkib(B5Q8MJaK(yL1I85xMulksLox(PJhdtU86x)Ana]] )


end
