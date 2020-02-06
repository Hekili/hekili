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


    spec:RegisterPack( "Arcane", 20200124, [[d0efqbqiecpsQGlrefvBsQ0NisvnkHkNsOQvreLEff0Sic3sQIAxc(ffyyiKoMuLwgrKNjvHPrKkxJIO2gcr9neQuJtQI05qOI1rKQ08Kk6EkX(OiCqPcTqkspKIinrPkcCreI0grOs0hjIIYjjIcRuQQxIqLWmLQiOBsefzNcL(PufHgkfrSuPkIEkHMQqXvjsv8veQK2lP(ljdgYHrTyL6XqnzeDzWMLYNrWOvsNgPvJqeVMiz2Q0TjQDt1VvmCcoocvTCrpNstxvxxfBNc9DHmEekNNiL1tevZNIA)sw3RogTij)GowjrujruI2RKKUarjosNKmztwl(sta0IcmwkMaOfDwg0IDmXSdArbwA3Hj1XOfTZjXGwC9FbR0RbgqG(RNDapYgyPYNl)0XXj3EdSuzSbAX9HEFjdxV1IK8d6yLerLerjAVss6ceL4iDsYK7Hw0kayDSezjPfxPKKGR3ArsWI1IDOqDmXSdfsYetaQ(DOqR)lyLEnWac0F9Sd4r2alv(C5Nooo52BGLkJnO63Hc1N9dNsRqsQxjkKKiQKiA1V63HczsxzNayLER(DOq9CHSpNVAFsxjSYwqIcz)rqTpPRewzlirHyNSqSrizcGAFsxDbNWVwioHcTYo5fil0wAf6xHcXKKJhQ(DOq9CHEojaF4PYG6hfjfkupBIcf3tLb1pkskeFHStH(v(lueuiYXL(FHaIHbRLAeUsRq7t6fA8c9jBxleTvOiOqKJl9)cfX(xOFcv)ouOEUqspcK8dfsyE64f6oeO4Gw8sTVvhJwepUfsJGogDS9QJrlY4NoUwuMM5KkQmta0IGZ7lqQnv)6yLKogTi48(cKAt1I4K(qszT4(0AboXSdk8kNeGG9zSufAPqevlY4NoUweVYjbGuDe0Vo2EOJrlcoVVaP2uTioPpKuwlgxHsOLGDL3xOqMnxiIOqpflf1juO4lu3cTpTwGtm7GcVYjbiyFglvHwk0(0AboXSdk8kNeGGmtmL9zSufQBH2NwlKhhuttjmrqgiNiVqDl0(0AboXSdkHjcYa5e5Arg)0X1Io8RqQEqwaSV(1XkD6y0IGZ7lqQnvlIt6djL1I7tRf4eZoOWRCsac2NXsvOoxkKKku3cfxHWZCjNipWjMDqjmrqgsqMPUTqMOq9s0cz2CHy8tnckWbzkyluNlfssfkETiJF64AroXSdQj36xhRjRJrlcoVVaP2uTioPpKuwlUpTwipxqnn1VMaydhHc1Tq7tRf4eZoOWRCsac2NXsvituOEOfz8thxlYjMDqTVS91VowISogTi48(cKAt1Im(PJRfFkjy)jLv4HeiMweN0hskRf3NwlKhhuttjmrqgiNiVqDleruO9P1cCIzhucteKHey8xOUfcpZLCI8aNy2bLWebzibzM62czIcjjIQfDwg0IpLeS)KYk8qcet)6yjU1XOfbN3xGuBQwKXpDCTiwA47854uSAFz7RfXj9HKYAX9P1c5Xb10ucteKbYjYlu3crefAFATaNy2bLWebzibg)fQBHWZCjNipWjMDqjmrqgsqMPUTqMOqsIOArO1a8RCwg0IyPHVZNJtXQ9LTV(1X2t1XOfbN3xGuBQweN0hskRf3NwlWjMDqHx5KaeSpJLQqlfAFATaNy2bfELtcqqMjMY(mwQc1TqXvO25EvjGx5KaOEQmuOoxkeqmaFEq9uzOqMnxO25EvjGx5KaOEQmuOoxkeEMl5e5boXSdkHjcYqcYm1TfYS5c9uzq9JIKcfQZLcHN5sorEGtm7GsyIGmKGmtDBHIxlY4NoUwmpoOMMsyIGu)6yjo6y0IGZ7lqQnvlY4NoUwKtm7GsMAT0ly1I4vM6AXE1I4K(qszTOm7Cqa)fQZLcrCm5c1Tq7tRfWxGtmBFQtiKaJ)c1Tqm(Pgbf4GmfSfQZc1d9RJTxIQJrlcoVVaP2uTioPpKuwlgxHIRq7tRf4eZoOWRCsac2NXsvOLcTpTwGtm7GcVYjbiiZetzFglvHIVqDluCfkUcjZoheWFH6CPqg5KY7leWJBH0iOKzNlu8fYS5cfxHE(c(hYJdQPPeMiidGZ7lqwOUfcpZLCI8aNy2bLWebzibzM62czIcHN5sorEipoOMMsyIGm0o3Rkb8kNea1tLHc1TqYSZbb8xOoxkKroP8(cb84winckz25czyHKKjxO4lu8fYS5cfxHE(c(h4eZoOMChaN3xGSqDleEMl5e5boXSdQj3HeKzQBluNlfIaMSqDleEMl5e5boXSdkHjcYqcYm1TfYefQxIwO4lu8fYS5cjZoheWFH6CPqXviJCs59fc4XTqAeuYSZfQNluVeTqXRfz8thxlYjMDqT5mzcG(1X2BV6y0IGZ7lqQnvlIt6djL1IYSZbb8xOoxkeXXK1Im(PJRfThbi9XiRFDS9kjDmArW59fi1MQfXj9HKYArg)uJGcCqMc2czILc1Jc1TqXviz25Ga(lKjwkKroP8(cb84winckz25cz2CH2NwlWjMDqHx5KaeSpJLQqlfQhfkETiJF64AroXSdkGyc3Xshx)6y7Th6y0Im(PJRf5eZoO2x2(ArW59fi1MQFDS9kD6y0Im(PJRf5eZoO2CMmbqlcoVVaP2u9RFTij04Z91XOJTxDmArg)0X1I454pKwb4E1IGZ7lqQnv)6yLKogTiJF64ArRaCV2h4RweCEFbsTP6xhBp0XOfz8thxlMG8yeu4tAbTi48(cKAt1VowPthJweCEFbsTPArg)0X1Iy(Evm(PJRUu7RfVu7RCwg0IG1cogS6xhRjRJrlcoVVaP2uTiJF64ArwYTRCYwvB8xnnLWebPweN0hskRf3NwlKhhuttjmrqgiNiVqDl0(0AboXSdkHjcYa5e5fQBHIRq4zUKtKh4eZoOeMiidjiZu3wOoxkK0vidluVeTqs2czKtkVVqOn(RiNZ(cQXvhluOUfcpZLCI8ayCW8thpKGmtDBH6CPqg5KY7leyJqYea1(KU6coHFTqgwiPRqgwOEjAHKSfYiNuEFHqB8xroN9fuJRowOqMnxONkdQFuKuOqDwi8mxYjYdCIzhucteKHeKzQBlu8ArNLbTil52vozRQn(RMMsyIGu)6yjY6y0IGZ7lqQnvlIt6djL1I7t6kHv2cfYS5cfxHEQmO(rrsHc1zHyJqYea1(KU6coHFTqXRfz8thxlI57vX4NoU6sTVw8sTVYzzqlUpPRFDSe36y0IGZ7lqQnvlIt6djL1IXvi8mxYjYdCIzhucteKHeKzQBl0sHiAH6wi8mxYjYdGXbZpD8qcYm1TfQZLcXgHKjaQ9jD1fCc)AH6wO4k0(0AboXSdk8kNeGG9zSufAPq7tRf4eZoOWRCsacYmXu2NXsviZMluCf65l4FaVYjbGuDecGZ7lqwOUfcpZLCI8aELtcaP6iesqMPUTqlfIOfQBH2NwlWjMDqHx5KaeSpJLQqDUuOElu8fk(cfVwKXpDCTiMVxfJF64Ql1(AXl1(kNLbT4(KU(1X2t1XOfbN3xGuBQweN0hskRfjIcTpPRewzlOfz8thxlI57vX4NoU6sTVw8sTVYzzqlIh3cPrq)6yjo6y0IGZ7lqQnvlY4NoUweZ3RIXpDC1LAFT4LAFLZYGwuEmcYG)6x)ArHeWJ8MFDm6y7vhJwKXpDCTiNy2bf1F4Eb8RfbN3xGuBQ(1XkjDmArg)0X1I2JS84koXSdQgltVuo1IGZ7lqQnv)6y7HogTi48(cKAt1IJGw0cVwKXpDCTOroP8(cArJ89aArImrlKHfsseTqs2cXsoK0hcaXFOcd1cbW59fi1Ig5u5SmOfXJBH0iOKzN1VowPthJweCEFbsTPAXrqlAHxlY4NoUw0iNuEFbTOr(EaTiq8hQGaqgyj3UYjBvTXF10ucteKfQBHIRqaXFOccazGWLjP8pPvTzscqHmBUqaXFOccazGWLjP8pPvjdK89shVqMnxiG4pubbGmqj40NoUsMjawv7yHcz2CHaI)qfeaYWl5Sdw1MtPScuhSfYS5cbe)HkiaKbwYpj8RJvzPobGujCpYmbOqMnxiG4pubbGmWoMc(RKYNxnnve1soYfYS5cbe)HkiaKb76GLAtFiTQg7ekKzZfci(dvqaidoCs(QSsZzblOaFLDmKfYS5cbe)HkiaKHnFHgnb1ozhVwO41Ig5u5SmOfBJ)kY5SVGAC1Xc6xhRjRJrlcoVVaP2uT4iOfTWRfz8thxlAKtkVVGw0iFpGwSxjPfXj9HKYArJCs59fcTXFf5C2xqnU6yHc1Tqg5KY7leAJ)QPPeMiivcjGh5n)k8k7oCl0sHiQw0iNkNLbTyB8xnnLWebPsib8iV5xHxz3HR(1XsK1XOfbN3xGuBQw0zzqlYsUDLt2QAJ)QPPeMii1Im(PJRfzj3UYjBvTXF10ucteK6xhlXTogTiJF64ArzAMtQOYmbqlcoVVaP2u9RJTNQJrlY4NoUwuyE64ArW59fi1MQFDSehDmArg)0X1ICIzhu7lBFTi48(cKAt1V(1I7t66y0X2RogTi48(cKAt1I4K(qszT4(0AboXSdk8kNeGG9zSufQZLc1RwKXpDCTiELtcaP6iOFDSsshJwKXpDCTOmnZjvuzMaOfbN3xGuBQ(1X2dDmArW59fi1MQfXj9HKYAX4kucTeSR8(cfYS5cref6PyPOoHcfFH6wO9P1cCIzhu4vojab7ZyPk0sH2NwlWjMDqHx5KaeKzIPSpJLQqDl0(0AH84GAAkHjcYa5e5fQBH2NwlWjMDqjmrqgiNixlY4NoUw0HFfs1dYcG91VowPthJweCEFbsTPArCsFiPSwCFATqEUGAAQFnbWgocfQBHE(c(hgJqkmrqcKbW59filu3cX4NAeuGdYuWwOolup0Im(PJRf5eZoO2x2(6xhRjRJrlcoVVaP2uTioPpKuwlUpTwGtm7GsyIGmqorUwKXpDCT4Lsy9TkIKdjbzWF9RJLiRJrlcoVVaP2uTioPpKuwlUpTwGtm7GsyIGmqorUwKXpDCT4MjOMM6tkwkR(1XsCRJrlcoVVaP2uTioPpKuwlsefAFATaNy2bLWebz4iuOUfkUcjZoheWFHmXsHmzIwiZMleEMl5e5boXSdkHjcYqcYm1TfAPqeTqXxOUfkUcTpTwGtm7GcVYjbiyFglvHwk0(0AboXSdk8kNeGGmtmL9zSufkETiJF64AX84GAAkHjcs9RJTNQJrlY4NoUwCdPfsPOobTi48(cKAt1VowIJogTiJF64AroXSdkHjcsTi48(cKAt1Vo2EjQogTi48(cKAt1I4K(qszT4(0AboXSdkHjcYWrOqMnxONkdQFuKuOqDwi8mxYjYdCIzhucteKHeKzQB1Im(PJRfpwqrFq2QFDS92RogTiJF64AX9Dgsv7KstlcoVVaP2u9RJTxjPJrlY4NoUwSrtyFNHulcoVVaP2u9RJT3EOJrlY4NoUwKDmy)KVkmFVArW59fi1MQFDS9kD6y0IGZ7lqQnvlIt6djL1IXvONVG)H84GAAkHjcYa48(cKfQBH2NwlKhhuttjmrqgsqMPUTqDUuO9P1ccjybhdQPPKPozqMjMY(mwQcjzleJF64boXSdQ9LTFaigGppOEQmuO4lKzZfAFATaNy2bLWebzibzM62c15sH2NwliKGfCmOMMsM6KbzMyk7ZyPkKKTqm(PJh4eZoO2x2(bGya(8G6PYGwKXpDCTOqcwWXGAAkzQtQFDS9AY6y0IGZ7lqQnvlIt6djL1I7tRf4eZoOeMiidhHc1TqXvO4keruiWAbhdb84KGBbs1L2G2KyiiZejtwiZMleyTGJHaECsWTaP6sBqBsmes2LQqDwijvO4lu3cfxH2NwlSH0cPuuNq4iuiZMl0(0AH9Dgsv7KslCekKzZfIikuCfkzme(CU3cz2CHsgdHjXfk(cfFHmBUq7tRfiC4KKYUAAkwYHC(1WrOqXxiZMl0tLb1pkskuOoleEMl5e5boXSdkHjcYqcYm1TArg)0X1IcZthx)6y7LiRJrlcoVVaP2uTioPpKuwlUpTwGtm7GcVYjbiyFglvHwkerlKzZfkUcX4NAeuGdYuWwOolupkKzZfkUcX4NAeuGdYuWwOolKKku3c98f8pKGDC2XqaCEFbYcfFHIxlY4NoUwKtm7GAYT(1X2lXTogTi48(cKAt1I4K(qszTiJFQrqboitbBHmXsH6rH6wO4k0(0AboXSdk8kNeGG9zSufAPq7tRf4eZoOWRCsacYmXu2NXsvO41Im(PJRf5eZoO2CMmbq)6y7TNQJrlcoVVaP2uTioPpKuwlY4NAeuGdYuWwitSuOEOfz8thxlYjMDqbet4ow646xhBVehDmArW59fi1MQfz8thxlYjMDqjtTw6fSAr8ktDTyVArCsFiPSwCFATa(cCIz7tDcHey8xOUfIXp1iOahKPGTqDwOEuOUfkUc98f8pWYcxAJI5NoEaCEFbYcz2CHIRqerHE(c(hgJqkmrqcKbW59filu3cXsoK0hcCIzhuchzz4sDcHKDPkKjwkKKku8fYS5cTpTwGtm7GsyIGmqorEHIx)6yLer1XOfbN3xGuBQweN0hskRfz8tnckWbzkyluNfQhArg)0X1ICIzhu7lBF9RJvs9QJrls9hY8i8kAtlkZoheWVjw6PMSwK6pK5r4vuzzGKYpOf7vlY4NoUwemoy(PJRfbN3xGuBQ(1XkjjPJrlY4NoUwKtm7GAZzYeaTi48(cKAt1V(1IG1cogS6y0X2RogTi48(cKAt1I4K(qszT4(KUsyLTqH6wO9P1cCIzhucteKbYjYlu3cTpTwipoOMMsyIGmqorEH6wO9P1cCIzhu4vojab7ZyPk0sH2NwlWjMDqHx5KaeKzIPSpJLQqMnxONkdQFuKuOqDwi8mxYjYdCIzhucteKHeKzQB1Im(PJRf33zivtt9RGcCqwA6xhRK0XOfbN3xGuBQwKXpDCTiECm4FYpqQAxwg0I4K(qszT4(0AH84GAAkHjcYa5e5fQBH2NwlWjMDqjmrqgiNiVqDluCfIik0(KUsyLTqHmBUqpvgu)OiPqH6Sq4zUKtKh4eZoOeMiidjiZu3wO4lu3cjZohEQmO(rjZeRqMyPqaXa85b1tLbT4L6GctQfjY6xhBp0XOfbN3xGuBQweN0hskRf3NwlKhhuttjmrqgiNiVqDl0(0AboXSdkHjcYa5e5fQBHIRqerH2N0vcRSfkKzZf6PYG6hfjfkuNfcpZLCI8aNy2bLWebzibzM62cfFH6wiz25WtLb1pkzMyfYelfcigGppOEQmOfz8thxlMalqDcQ2LLbR(1XkD6y0IGZ7lqQnvlIt6djL1I7tRfYJdQPPeMiidKtKxOUfAFATaNy2bLWebzGCICTiJF64AX2GpwGuXsoK0huBGL1VowtwhJweCEFbsTPArCsFiPSwCFATqECqnnLWebzGCI8c1Tq7tRf4eZoOeMiidKtKRfz8thxls4WjjLD10uSKd58R6xhlrwhJweCEFbsTPArCsFiPSwCFATqECqnnLWebzGCI8c1Tq7tRf4eZoOeMiidKtKRfz8thxlkCsAtAuNGAFz7RFDSe36y0IGZ7lqQnvlIt6djL1I7tRfYJdQPPeMiidKtKxOUfAFATaNy2bLWebzGCICTiJF64AXKkiCbf1vwbgd6xhBpvhJweCEFbsTPArCsFiPSwCFATqECqnnLWebzGCI8c1Tq7tRf4eZoOeMiidKtKRfz8thxl(RG64754KQ2Kyq)6yjo6y0IGZ7lqQnvlIt6djL1IerH2N0vcRSfku3cTpTwGtm7GsyIGmqorEH6wi8mxYjYdCIzhucteKHeKzQBlu3cTpTwGtm7GcVYjbiyFglvHwk0(0AboXSdk8kNeGGmtmL9zSufQBHIRqerHE(c(hYJdQPPeMiidGZ7lqwiZMleJF64H84GAAkHjcYaELtcGTqXxiZMl0tLb1pkskuOoleEMl5e5boXSdkHjcYqcYm1TArg)0X1IYG8Kstnn19GPKkYeyzR(1X2lr1XOfbN3xGuBQweN0hskRf3N0vcRSfku3cTpTwGtm7GsyIGmqorEH6wO9P1c5Xb10ucteKbYjYlu3cTpTwGtm7GcVYjbiyFglvHwk0(0AboXSdk8kNeGGmtmL9zSufYS5c9uzq9JIKcfQZcHN5sorEGtm7GsyIGmKGmtDRwKXpDCTy0KxsJa1vjyhNDmOF9RfLhJGm4VogDS9QJrlcoVVaP2uTioPpKuwlkpgbzW)aj1(SJHczILc1lr1Im(PJRf3xQlL(1XkjDmArW59fi1MQfXj9HKYAr5Xiid(hiP2NDmuitSuOEjQwKXpDCT4(sDP0Vo2EOJrlY4NoUwuibl4yqnnLm1j1IGZ7lqQnv)6yLoDmArg)0X1ICIzhuYuRLEbRweCEFbsTP6xhRjRJrlY4NoUwKtm7GAYTweCEFbsTP6xhlrwhJwKXpDCTO9iaPpgzTi48(cKAt1V(1Vw0iKw646yLer7L40BV92RwmItN6eSArjdzHjFGSqe5cX4NoEHUu7BdvFTiF(1j1IIu5ZLF64M0KBVwuiNg9cAXouOoMy2HcjzIjav)ouO1)fSsVgyab6VE2b8iBGLkFU8thhNC7nWsLXgu97qH6Z(HtPvij1RefssevseT6x97qHmPRStaSsVv)ouOEUq2NZxTpPRewzlirHS)iO2N0vcRSfKOqStwi2iKmbqTpPRUGt4xleNqHwzN8cKfAlTc9RqHysYXdv)ouOEUqpNeGp8uzq9JIKcfQNnrHI7PYG6hfjfIVq2Pq)k)fkcke54s)VqaXWG1sncxPvO9j9cnEH(KTRfI2kueuiYXL(FHIy)l0pHQFhkupxiPhbs(HcjmpD8cDhcuCO6x97qHisjgGppqwOn0MekeEK38xOnqG62qH6igdcVTq(498kNYTZTqm(PJBl04xPfQ(DOqm(PJBdcjGh5n)lTlBLQ63HcX4NoUniKaEK38B4IbTziR(DOqm(PJBdcjGh5n)gUyaFiid(ZpD8QpJF642Gqc4rEZVHlgWjMDqr9hUxa)vFg)0XTbHeWJ8MFdxmGtm7GQXY0lLZQFhkeEClKgbLm7CHO2c9RqHKzNlKaKyWFMauOiOqrS)f6Ncryke5e5f6NcrEsQtOq4XTqAecfsY4lKdaPTq)uOlWgHcb(CiSwOCg5c9tHIM0(fcZwOqwm4CsNczfy5c1rtl04xPviYtsDcfQJMKq1NXpDCBqib8iV53WfdmYjL3xqcNLHf84winckz2zjgHfl8syKVhyHitudLerLSSKdj9Haq8hQWqTqaCEFbYQpJF642Gqc4rEZVHlgyKtkVVGeoldlTXFf5C2xqnU6ybjgHfl8syKVhybi(dvqaidSKBx5KTQ24VAAkHjcYUXbe)HkiaKbcxMKY)Kw1MjjaMnde)HkiaKbcxMKY)KwLmqY3lDCZMbI)qfeaYaLGtF64kzMayvTJfmBgi(dvqaidVKZoyvBoLYkqDWA2mq8hQGaqgyj)KWVowLL6easLW9iZeaZMbI)qfeaYa7yk4VskFE10urul5iB2mq8hQGaqgSRdwQn9H0QAStWSzG4pubbGm4Wj5RYknNfSGc8v2XqA2mq8hQGaqg28fA0eu7KD8A8vFg)0XTbHeWJ8MFdxmWiNuEFbjCwgwAJ)QPPeMiivcjGh5n)k8k7oCLyewSWlHr(EGLELKe02IroP8(cH24VICo7lOgxDSqxJCs59fcTXF10ucteKkHeWJ8MFfELDhUleT6Z4NoUniKaEK38B4IbhlOOpilHZYWcl52vozRQn(RMMsyIGS6Z4NoUniKaEK38B4IbY0mNurLzcq1NXpDCBqib8iV53WfdeMNoE1NXpDCBqib8iV53Wfd4eZoO2x2(v)QFhkerkXa85bYcbgHuAf6PYqH(vOqm(NSquBHyJm9Y7leQ(m(PJBxWZXFiTcW9w9z8th3A4Ibwb4ETpW3QpJF64wdxmib5XiOWN0cvFg)0XTgUyaMVxfJF64Ql1(s4SmSawl4yWw9z8th3A4IbhlOOpilHZYWcl52vozRQn(RMMsyIGucABzFATqECqnnLWebzGCI8U7tRf4eZoOeMiidKtK3no8mxYjYdCIzhucteKHeKzQB7Cr6mSxIkznYjL3xi0g)vKZzFb14QJf6IN5sorEamoy(PJhsqMPUTZfJCs59fcSrizcGAFsxDbNWVAO0zyVevYAKtkVVqOn(RiNZ(cQXvhly28tLb1pksk0jEMl5e5boXSdkHjcYqcYm1TXx97qHKmBk0pfY0t6fYKSYwOqrRGxi(MatkTcTpPtDcsuOjlu0k4fApwBHIO3BHiPqHSZ4HQpJF64wdxmaZ3RIXpDC1LAFjCwgw2N0LG2w2N0vcRSfmBoUNkdQFuKuOt2iKmbqTpPRUGt4xJV63Hcj(C(fY0t6fYKSYwOqrRGxOoMy2HczsMiile1wOeysPvi2jlerQXbZpD8cfrV3cTHcLatkTcf34fIncjtaIVqBOnjuOFfk0(KEHewzluiQTqJridfQJx7uizwkOq2tcfkckeH5lK0vOoMy2Hczsx5KayLOqtwim7fIa8fs6kuhtm7qHmPRCsaSfkI(RfYKUYjbGSqspcHQpJF64wdxmaZ3RIXpDC1LAFjCwgw2N0LG2wIdpZLCI8aNy2bLWebzibzM62fI2fpZLCI8ayCW8thpKGmtDBNlSrizcGAFsxDbNWV2nU9P1cCIzhu4vojab7ZyPw2NwlWjMDqHx5KaeKzIPSpJLYS54E(c(hWRCsaivhHa48(cKDXZCjNipGx5KaqQocHeKzQBxiA39P1cCIzhu4vojab7ZyP6CP34Jp(QpJF64wdxmaZ3RIXpDC1LAFjCwgwWJBH0iibTTqe7t6kHv2cvFg)0XTgUyaMVxfJF64Ql1(s4SmSipgbzW)QF1VdfsYWXjid(xO5KfAFsVqcRSfkeEo(dzOqexxbhmczHIGcb(dzH(vOqO9jDuHy8th3wOi6VoNVqBG6eke1lexO9j9cjSYwqIcr)cjdSBl0VYFHIGcXjuiEpNVq)ui7Z5xOXHq1VdfIXpDCByFsFXiNuEFbjCwgw(55RAFs3kXiSWKKsyKVhyPxjOTfIyFsxjSYwO63HcX4NoUnSpPB4Ib2NZxTpPRewzlibTTqe7t6kHv2cv)ouiIuNSq)kuO9j9cjSYwOqrRGxOiOqejh7xiW4G5hidv)ouig)0XTH9jDdxmW(JGAFsxjSYwqcABzFsxjSYwORqcgveWKHEdGXbZpD8UX9uzq9JIKcXBcJCs59fcSrizcGAFsxDbNWV2DFsxjSYwqrEs(PJBcIw97qH6jeS2c9RSxOEle1TpWKfAAfci(dFTf6Ncrujk0gW8XcfAAfsiHEgZ2VqDmXSdfY0lB)QpJF642W(KUHlgGx5KaqQocsqBl7tRf4eZoOWRCsac2NXs15sVvFg)0XTH9jDdxmqMM5KkQmtaQ(m(PJBd7t6gUyGd)kKQhKfa7lbTTexcTeSR8(cMntepflf1jeF39P1cCIzhu4vojab7ZyPw2NwlWjMDqHx5KaeKzIPSpJLQ7(0AH84GAAkHjcYa5e5D3NwlWjMDqjmrqgiNiV63HcrCDf8cLh3PoHc1t0iKcteKaPefIDYcfbfIW8fIlup55cfAAfkM1eaBHeYbxO46iXfDSqrqHimFHMtwiP7xluhtm7qHmPRCsakKrkxit6kNeaYcj9ieVef6yHcr)cTH2KqHowQtOq9KJjXWoAsKOqBaZhluOFfkKm7CHsG8GF64fIAl08RqgrTqHUCsaUsRqrS9bYczPogk0VcfQJMwOi2wOwcqHyxArS0cvFg)0XTH9jDdxmGtm7GAFz7lbTTSpTwipxqnn1VMaydhHUpFb)dJrifMiibYa48(cKDz8tnckWbzky7ShvFg)0XTH9jDdxm4sjS(wfrYHKGm4Ve02Y(0AboXSdkHjcYa5e5vFg)0XTH9jDdxmyZeutt9jflLvcABzFATaNy2bLWebzGCI8QpJF642W(KUHlgKhhuttjmrqkbTTqe7tRf4eZoOeMiidhHUXjZoheWVjwmzIA2mEMl5e5boXSdkHjcYqcYm1Tlen(UXTpTwGtm7GcVYjbiyFgl1Y(0AboXSdk8kNeGGmtmL9zSuXx9z8th3g2N0nCXGnKwiLI6eQ(m(PJBd7t6gUyaNy2bLWebz1NXpDCByFs3WfdowqrFq2kbTTSpTwGtm7GsyIGmCemB(PYG6hfjf6epZLCI8aNy2bLWebzibzM62QpJF642W(KUHlgSVZqQANuAvFg)0XTH9jDdxmOrtyFNHS6Z4NoUnSpPB4IbSJb7N8vH57T6Z4NoUnSpPB4IbcjybhdQPPKPoPe02sCpFb)d5Xb10ucteKbW59fi7UpTwipoOMMsyIGmKGmtDBNl7tRfesWcoguttjtDYGmtmL9zSuswg)0XdCIzhu7lB)aqmaFEq9uziEZM3NwlWjMDqjmrqgsqMPUTZL9P1ccjybhdQPPKPozqMjMY(mwkjlJF64boXSdQ9LTFaigGppOEQmu9z8th3g2N0nCXaH5PJlbTTSpTwGtm7GsyIGmCe6gxCebyTGJHaECsWTaP6sBqBsmeKzIKjnBgSwWXqapoj4wGuDPnOnjgcj7s1PKIVBC7tRf2qAHukQtiCemBEFATW(odPQDsPfocMnteXLmgcFo3RzZjJHWK44J3S59P1ceoCsszxnnfl5qo)A4ieVzZpvgu)OiPqN4zUKtKh4eZoOeMiidjiZu3w9z8th3g2N0nCXaoXSdQj3sqBl7tRf4eZoOWRCsac2NXsTquZMJJXp1iOahKPGTZEy2CCm(Pgbf4GmfSDkPUpFb)djyhNDmeaN3xGm(4R(m(PJBd7t6gUyaNy2b1MZKjasqBlm(Pgbf4GmfSMyPhDJBFATaNy2bfELtcqW(mwQL9P1cCIzhu4vojabzMyk7ZyPIV6Z4NoUnSpPB4IbCIzhuaXeUJLoUe02cJFQrqboitbRjw6r1VdfsYGGpjuOoMy2HcjzIAT0lyle5jPoHc1XeZouitYebPefITusOqTCKlKDKHczesPviRaGPnkUqaXWGWth3krHUuPGc5ZxOv2i1juOEIgHuyIGeil0ZxWFGSqDluECN6ekupiwH6yIzhkKj5ildxQtiu9z8th3g2N0nCXaoXSdkzQ1sVGvcABzFATa(cCIz7tDcHey83LXp1iOahKPGTZE0nUNVG)bww4sBum)0XdGZ7lqA2CCeXZxW)WyesHjcsGmaoVVazxwYHK(qGtm7Gs4ildxQtiKSlLjwKu8MnVpTwGtm7GsyIGmqorE8sGxzQV0B1NXpDCByFs3Wfd4eZoO2x2(sqBlm(Pgbf4GmfSD2JQFhkuStuH(v(luei9tOqKJdfAFsN6eKOqrqHWSxOJaj)qH(vOqSrizcGAFsxDbNWVwOi6VwOFfk0fCc)AHMwH(vQTq7t6HQFhkeJF642W(KUHlgyKtkVVGeoldlSrizcGAFsxDbNWVkXiSyHxcJ89alXzKtkVVqGncjtau7t6Ql4e(vjRroP8(cHFE(Q2N0T9SroP8(cb2iKmbqTpPRUGt4xnmU9jDLWkBbf5j5NoE8XlzUroP8(cHFE(Q2N0TvFg)0XTH9jDdxmamoy(PJlb1FiZJWROTfz25Ga(nXsp1KLG6pK5r4vuzzGKYpS0B1VdfI4Yjl0Vcfk5ek0GXSLoEHIwHekueuictHMrUqBOnjuiW4G5NoEHO2cTzSuf6iekuCsp2dFVsRqBaZhluOiOqeGVqgHuAfAZKfkDcfYof6xHcTpPxiQTq4ZxiJqkTczxN8JV6Z4NoUnSpPB4IbCIzhuBotMau9R(m(PJBd4XTqAewKPzoPIkZeGQpJF642aEClKgbdxmaVYjbGuDeKG2w2NwlWjMDqHx5KaeSpJLAHOvFg)0XTb84wincgUyGd)kKQhKfa7lbTTexcTeSR8(cMntepflf1jeF39P1cCIzhu4vojab7ZyPw2NwlWjMDqHx5KaeKzIPSpJLQ7(0AH84GAAkHjcYa5e5D3NwlWjMDqjmrqgiNiV6Z4NoUnGh3cPrWWfd4eZoOMClbTTSpTwGtm7GcVYjbiyFglvNlsQBC4zUKtKh4eZoOeMiidjiZu3AIEjQzZm(Pgbf4GmfSDUiP4R(DOqDmXSdfY0lB)czxPT3wOJqHOEHes6K0xAfkAf8cLh3PoHcLNluOPvOFnbWgQ(m(PJBd4XTqAemCXaoXSdQ9LTVe02Y(0AH8Cb10u)AcGnCe6UpTwGtm7GcVYjbiyFglLj6r1NXpDCBapUfsJGHlgCSGI(GSeoldlpLeS)KYk8qcetcABzFATqECqnnLWebzGCI8UeX(0AboXSdkHjcYqcm(7IN5sorEGtm7GsyIGmKGmtDRjKerR(m(PJBd4XTqAemCXGJfu0hKLaAna)kNLHfS0W35ZXPy1(Y2xcABzFATqECqnnLWebzGCI8UeX(0AboXSdkHjcYqcm(7IN5sorEGtm7GsyIGmKGmtDRjKerR(m(PJBd4XTqAemCXG84GAAkHjcsjOTL9P1cCIzhu4vojab7ZyPw2NwlWjMDqHx5KaeKzIPSpJLQBCTZ9QsaVYjbq9uzOZfGya(8G6PYGzZTZ9QsaVYjbq9uzOZf8mxYjYdCIzhucteKHeKzQBnB(PYG6hfjf6CbpZLCI8aNy2bLWebzibzM624R(m(PJBd4XTqAemCXaoXSdkzQ1sVGvcABrMDoiG)oxioMC39P1c4lWjMTp1jesGXFxg)uJGcCqMc2o7He4vM6l9w97qH6j4KuNqHWJBH0iirHIGczF69wiIKJ9lue7FH(Pq4XFQFGc5ZxiYCeeOoHcHx5KayleBl0DCcfITfsySw6(cbXPqsbGqHK(7t6uNG0VqSTq3Xjui2wiHXAP7luO4yP4cHh3cPrqjZoxOFnb766CjJVqStwOFf8czJyHc9tH4cjDeRqD00E2eDCZzwi84wincfkNNF64Hcjz0kueuiYPq(8fALncfs6kuhnPsuOiOqy2lejvOq2lLW6FLwHUteKf6Ncra(cXfs6(1c1rtAOqexHcXx7ui7X(m1le)fIl0kLWkKfsMDUqcqIb)zcqHIwbVqrqHeUSxOFk0XcfIlup5XHcnTczsMiile5jPoHcHh3cPrOqcRSfKOq2PqrqHWSxO9j9crEsQtOq)kuOEYJdfAAfYKmrqgQ(m(PJBd4XTqAemCXaoXSdQnNjtaKG2wIlU9P1cCIzhu4vojab7ZyPw2NwlWjMDqHx5KaeKzIPSpJLk(UXfNm7Cqa)DUyKtkVVqapUfsJGsMDoEZMJ75l4FipoOMMsyIGmaoVVazx8mxYjYdCIzhucteKHeKzQBnbEMl5e5H84GAAkHjcYq7CVQeWRCsaupvg6kZoheWFNlg5KY7leWJBH0iOKzNnusMC8XB2CCpFb)dCIzhutUdGZ7lq2fpZLCI8aNy2b1K7qcYm1TDUqat2fpZLCI8aNy2bLWebzibzM6wt0lrJpEZMLzNdc4VZL4mYjL3xiGh3cPrqjZo3Z9s04R(DOqIhbi9XixiQTqBoHR0ku0K)AHWS9Pobjku0kfVwiQTqrRsRq0VquBHStHACwiYjYLOqJFLwHiso2Vq8EmcfQJMgku1NXpDCBapUfsJGHlgypcq6JrwcABrMDoiG)oxioMC1VdfI4caekK0FFsN6eK(fI6fIhOqw6F4NoUTqh)P3cHh3cPrqjZoxib8hkuhBpKf6x5VqJFLwHWS9luhjslue9xlupkuhtm7qHWRCsaSsuil1XqHOV03wi(kp2VqaXF4BHKzNleESFH(PqCH6rHSpJLQqD00cXU0IyPfkuh)c9R8xiHH6FH64qKwOCE(PJxOi69wOnuOoAAHiwp6zt0rI0E2eDCZzw9z8th3gWJBH0iy4IbCIzhuaXeUJLoUe02cJFQrqboitbRjw6r34KzNdc43elg5KY7leWJBH0iOKzNnBEFATaNy2bfELtcqW(mwQLEeF1NXpDCBapUfsJGHlgWjMDqTVS9R(m(PJBd4XTqAemCXaoXSdQnNjtaQ(vFg)0XTbWAbhd2L9Dgs10u)kOahKLMe02Y(KUsyLTq39P1cCIzhucteKbYjY7UpTwipoOMMsyIGmqorE39P1cCIzhu4vojab7ZyPw2NwlWjMDqHx5KaeKzIPSpJLYS5NkdQFuKuOt8mxYjYdCIzhucteKHeKzQBR(m(PJBdG1cogSgUyaECm4FYpqQAxwgK4sDqHjxiYsqBl7tRfYJdQPPeMiidKtK3DFATaNy2bLWebzGCI8UXre7t6kHv2cMn)uzq9JIKcDIN5sorEGtm7GsyIGmKGmtDB8DLzNdpvgu)OKzIzIfGya(8G6PYq1NXpDCBaSwWXG1WfdsGfOobv7YYGvcABzFATqECqnnLWebzGCI8U7tRf4eZoOeMiidKtK3noIyFsxjSYwWS5NkdQFuKuOt8mxYjYdCIzhucteKHeKzQBJVRm7C4PYG6hLmtmtSaedWNhupvgQ(m(PJBdG1cogSgUyqBWhlqQyjhs6dQnWYsqBl7tRfYJdQPPeMiidKtK3DFATaNy2bLWebzGCI8QpJF642ayTGJbRHlgq4WjjLD10uSKd58RsqBl7tRfYJdQPPeMiidKtK3DFATaNy2bLWebzGCI8QpJF642ayTGJbRHlgiCsAtAuNGAFz7lbTTSpTwipoOMMsyIGmqorE39P1cCIzhucteKbYjYR(m(PJBdG1cogSgUyqsfeUGI6kRaJbjOTL9P1c5Xb10ucteKbYjY7UpTwGtm7GsyIGmqorE1NXpDCBaSwWXG1Wfd(vqD89CCsvBsmibTTSpTwipoOMMsyIGmqorE39P1cCIzhucteKbYjYR(m(PJBdG1cogSgUyGmipP0uttDpykPImbw2kbTTqe7t6kHv2cD3NwlWjMDqjmrqgiNiVlEMl5e5boXSdkHjcYqcYm1TD3NwlWjMDqHx5KaeSpJLAzFATaNy2bfELtcqqMjMY(mwQUXrepFb)d5Xb10ucteKbW59finBMXpD8qECqnnLWebzaVYjbWgVzZpvgu)OiPqN4zUKtKh4eZoOeMiidjiZu3w9z8th3gaRfCmynCXGOjVKgbQRsWoo7yqcABzFsxjSYwO7(0AboXSdkHjcYa5e5D3NwlKhhuttjmrqgiNiV7(0AboXSdk8kNeGG9zSul7tRf4eZoOWRCsacYmXu2NXsz28tLb1pksk0jEMl5e5boXSdkHjcYqcYm1Tv)QpJF642G8yeKb)xSRuzziLG2wKhJGm4FGKAF2XGjw6LOvFg)0XTb5Xiid(B4Ib7l1LscABrEmcYG)bsQ9zhdMyPxIw9z8th3gKhJGm4VHlgiKGfCmOMMsM6KvFg)0XTb5Xiid(B4IbCIzhuYuRLEbB1NXpDCBqEmcYG)gUyaNy2b1K7QpJF642G8yeKb)nCXa7rasFmY6x)An]] )


end
