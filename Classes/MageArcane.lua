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

        potion = "potion_of_focused_resolve",

        package = "Arcane",
    } )


    spec:RegisterPack( "Arcane", 20191111, [[d0uBlbqiekEKqrxIiHuBsj5tuqyucLoLqLvrKGxrbMfr4wieSlb)Ii1WqO6yuuTmHQ8mPiMgrIUMqH2gcr(gcr14KIeNtksToHcY8KI6EkX(OG6Gcv1cPiEOqbMOqbfxeHq2OuKu9rIesojcrzLkPEPqbvZuOGs3eHq1oPO8tPiPmukiAPsrsEkbtLI0vjsi(kcHYEj1FjzWQ6WOwSs9yqtgrxgAZs1NrWOLsNgPvtKq9AIOzd0TjQDt1VvmCcDCekTCrpNstxLRdy7uOVlKXJq68ejTEkinFPW(LS2CTPAbs(qTzXJ4M30MBU5MhmpEMlLXy80cNufrTGidLKjGAbNLrTq8ti7OwqKLk4WKAt1c2biHOwO9orBmK0stGETa7aCKL2sLba5Joom5(jTLkdLwlSbOGhrMR3Abs(qTzXJ4M30MBU5MhmpEMlLsP5AbRic1MrKINwOLssIUERfirluleZ6JFczhRNiotaR1XS(27eTXqslnb61cSdWrwAlvgaKp64WK7N0wQmu6ADmR3SXikVXSEZnxI6JhXnVPR116ywFmOLDcOngQwhZ6jc1Bpop1giDLylBrjQ3EJOAdKUsSLTOe1Zoz9SrmzcOAdKUceDcxB9CI13Yojisw)wQ1FTy9mj54HADmRNiu)Xjb8chvgv3OiPy9ebdxFShvgv3OiPyC1BN6Vw(QpcRNCCdXvpsuiATuJiOuRFdKE9Jx)LSTTEAV(iSEYXnex9rSF1FtqlasTNvBQwaoUftJO2uTzMRnvlWWJoUwqMM5KkQmta1cOZBqKuBI(0MfpTPAb05nisQnrlat6HjL1cBGEpWjKDubB5KagShdLS(L6jUwGHhDCTaSLtciPcquFAZAI2uTa68gej1MOfGj9WKYAHyRpXEI2wEdI13Or9et9hfkj1juFC1VQ(nqVh4eYoQGTCsad2JHsw)s9BGEpWjKDubB5KagKzIQShdLS(v1Vb69qc4OA6kXjcZa5e51VQ(nqVh4eYoQeNimdKtKRfy4rhxl441IP6qzr0E6tBMuQnvlGoVbrsTjAbyspmPSwyd07boHSJkylNeWG9yOK138s9XR(v1hB9WzajNipWjKDujorygsuMPUTEdxV5eV(gnQNHh1iQqhLPOT(MxQpE1hNwGHhDCTaNq2r1KB9Pnlg1MQfqN3GiP2eTamPhMuwlSb69qcaIQPRU2erBaqS(v1Vb69aNq2rfSLtcyWEmuY6nC9nrlWWJoUwGti7OAdY2tFAZisAt1cOZBqKuBIwGHhDCTWrjr7nPScoKir1cWKEyszTWgO3djGJQPReNimdKtKx)Q6jM63a9EGti7OsCIWmKidV6xvpCgqYjYdCczhvIteMHeLzQBR3W1hpIRfCwg1chLeT3KYk4qIevFAZiY1MQfqN3GiP2eTadp64AbOuHGZLJtHQniBpTamPhMuwlSb69qc4OA6kXjcZa5e51VQEIP(nqVh4eYoQeNimdjYWR(v1dNbKCI8aNq2rL4eHzirzM626nC9XJ4AbS3r4PCwg1cqPcbNlhNcvBq2E6tBwtrBQwaDEdIKAt0cWKEyszTWgO3dCczhvWwojGb7XqjRFP(nqVh4eYoQGTCsadYmrv2JHsw)Q6JT(oaiOkrylNeq1rLX6BEPEKOie4q1rLX6B0O(oaiOkrylNeq1rLX6BEPE4mGKtKh4eYoQeNimdjkZu3wFJg1FuzuDJIKI138s9WzajNipWjKDujorygsuMPUT(40cm8OJRfsahvtxjoryQpTznT2uTa68gej1MOfy4rhxlWjKDujtTwkiA1cWwM6AbZ1cWKEyszTGm7CqeE138s9nDmw)Q63a9EacICcz7rDcHez4v)Q6z4rnIk0rzkARV56BI(0MzoX1MQfqN3GiP2eTamPhMuwleB9Xw)gO3dCczhvWwojGb7XqjRFP(nqVh4eYoQGTCsadYmrv2JHswFC1VQ(yRp26LzNdIWR(MxQ3iNuEdIb44wmnIkz256JR(gnQp26pge9lKaoQMUsCIWmGoVbrY6xvpCgqYjYdCczhvIteMHeLzQBR3W1dNbKCI8qc4OA6kXjcZqhaeuLiSLtcO6OYy9RQxMDoicV6BEPEJCs5nigGJBX0iQKzNR3G6JxmwFC1hx9nAuFS1Fmi6xGti7OAYDaDEdIK1VQE4mGKtKh4eYoQMChsuMPUT(MxQNaKS(v1dNbKCI8aNq2rL4eHzirzM626nC9Mt86JR(4QVrJ6LzNdIWR(MxQp26nYjL3GyaoUftJOsMDUEIq9Mt86JtlWWJoUwGti7OAZzYeq9PnZCZ1MQfqN3GiP2eTamPhMuwliZoheHx9nVuFthJAbgE0X1cwarm9XiRpTzMhpTPAb05nisQnrlat6HjL1cm8Ogrf6OmfT1B4L6Bs9RQp26LzNdIWREdVuVroP8gedWXTyAevYSZ13Or9BGEpWjKDubB5KagShdLS(L6Bs9XPfy4rhxlWjKDuHeveCS0X1N2mZBI2uTadp64AboHSJQniBpTa68gej1MOpTzMlLAt1cm8OJRf4eYoQ2CMmbulGoVbrsTj6tFAbsSZaGN2uTzMRnvlWWJoUwaoa(HPvebb1cOZBqKuBI(0MfpTPAbgE0X1cwree0EidQfqN3GiP2e9PnRjAt1cm8OJRfsuEmIkiqArTa68gej1MOpTzsP2uTa68gej1MOfy4rhxlazqqfdp64kqQ90cGu7PCwg1cO1IoeT6tBwmQnvlGoVbrsTjAbgE0X1cSHAB5KTQ(4NA6kXjctTamPhMuwlSb69qc4OA6kXjcZa5e51VQ(nqVh4eYoQeNimdKtKx)Q6JTE4mGKtKh4eYoQeNimdjkZu3wFZl1lL1Bq9Mt86Lc1BKtkVbXqF8troaBqunUcWI1VQE4mGKtKhqJdKp64HeLzQBRV5L6nYjL3GyGnIjtavBG0vGOt4AR3G6LY6nOEZjE9sH6nYjL3GyOp(PihGniQgxbyX6B0O(JkJQBuKuS(MRhodi5e5boHSJkXjcZqIYm1T1hNwWzzulWgQTLt2Q6JFQPReNim1N2mIK2uTa68gej1MOfGj9WKYAHnq6kXw2I13Or9Xw)rLr1nkskwFZ1BKtkVbXaBetMaQ2aPRarNW1wFCAbgE0X1cqgeuXWJoUcKApTai1EkNLrTWgiD9PnJixBQwaDEdIKAt0cWKEyszTqS1dNbKCI8aNq2rL4eHzirzM626xQN41VQE4mGKtKhqJdKp64HeLzQBRV5L6zJyYeq1giDfi6eU26xvFS1Vb69aNq2rfSLtcyWEmuY6xQFd07boHSJkylNeWGmtuL9yOK13Or9Xw)XGOFbylNeqsfGyaDEdIK1VQE4mGKtKhGTCsajvaIHeLzQBRFPEIx)Q63a9EGti7Oc2Yjbmypgkz9nVuV51hx9XvFCAbgE0X1cqgeuXWJoUcKApTai1EkNLrTWgiD9PnRPOnvlGoVbrsTjAbyspmPSwGyQFdKUsSLTOwGHhDCTaKbbvm8OJRaP2tlasTNYzzulah3IPruFAZAATPAb05nisQnrlWWJoUwaYGGkgE0XvGu7PfaP2t5SmQfKhJOm6N(0Nwqmr4iV5tBQ2mZ1MQfy4rhxlWjKDur9dbbr4PfqN3GiP2e9PnlEAt1cm8OJRfSaYYJR4eYoQ6SmfKYPwaDEdIKAt0N2SMOnvlGoVbrsTjAHrulyXtlWWJoUwWiNuEdIAbJmiaQfiseVEdQpEeVEPq9SHIj9WasSauXHAXa68gej1cg5u5SmQfGJBX0iQKzN1N2mPuBQwaDEdIKAt0cJOwWINwGHhDCTGroP8ge1cgzqaulGelavuejdSHAB5KTQ(4NA6kXjcZ6xvFS1JelavuejdeazskFtAvBMKawFJg1JelavuejdeazskFtAvYijdcshV(gnQhjwaQOisgOeC6rhxjZeqRQdyX6B0OEKybOIIiz4mu2rRAZPKwrQJ26B0OEKybOIIizGnuGeV2XQSuNasQebbKzcy9nAupsSaurrKmWoKI(PK0NtnDve1soY13Or9iXcqffrYGTDGsUPhMwvNDc13Or9iXcqffrYGJajdQSs1zrlQqVLDiM13Or9iXcqffrYWMbXonr1ozh2wFCAbJCQCwg1c9Xpf5aSbr14kalQpTzXO2uTa68gej1MOfCwg1cSHAB5KTQ(4NA6kXjctTadp64Ab2qTTCYwvF8tnDL4eHP(0MrK0MQfy4rhxlitZCsfvMjGAb05nisQnrFAZiY1MQfy4rhxliohDCTa68gej1MOpTznfTPAbgE0X1cCczhvBq2EAb05nisQnrF6tlSbsxBQ2mZ1MQfqN3GiP2eTamPhMuwlSb69aNq2rfSLtcyWEmuY6BEPEZ1cm8OJRfGTCsajvaI6tBw80MQfy4rhxlitZCsfvMjGAb05nisQnrFAZAI2uTa68gej1MOfGj9WKYAHyRpXEI2wEdI13Or9et9hfkj1juFC1VQ(nqVh4eYoQGTCsad2JHsw)s9BGEpWjKDubB5KagKzIQShdLS(v1Vb69qc4OA6kXjcZa5e51VQ(nqVh4eYoQeNimdKtKRfy4rhxl441IP6qzr0E6tBMuQnvlGoVbrsTjAbyspmPSwyd07HeaevtxDTjI2aGy9RQ)yq0VWyetXjctKmGoVbrY6xvpdpQruHoktrB9nxFt0cm8OJRf4eYoQ2GS90N2SyuBQwaDEdIKAt0cWKEyszTWgO3dCczhvIteMbYjY1cm8OJRfaPeApRskgGKGm6N(0MrK0MQfqN3GiP2eTamPhMuwlqm1Vb69aNq2rL4eHzaqS(v1hB9YSZbr4vVHxQpgjE9nAupCgqYjYdCczhvIteMHeLzQBRFPEIxFC1VQ(yRFd07boHSJkylNeWG9yOK1Vu)gO3dCczhvWwojGbzMOk7XqjRpoTadp64AHeWr10vIteM6tBgrU2uTadp64AHnMwmLK6e0cOZBqKuBI(0M1u0MQfy4rhxlWjKDujoryQfqN3GiP2e9PnRP1MQfqN3GiP2eTamPhMuwlSb69aNq2rL4eHzaqS(gnQp26pQmQUrrsX6BUE4mGKtKh4eYoQeNimdjkZu3wFCAbgE0X1cawurpu2QpTzMtCTPAbgE0X1cBWzivDGuQAb05nisQnrFAZm3CTPAbgE0X1cDAIBWzi1cOZBqKuBI(0MzE80MQfy4rhxlWoeTxYGkidcQfqN3GiP2e9PnZ8MOnvlGoVbrsTjAbyspmPSwi26pge9lKaoQMUsCIWmGoVbrY6xv)gO3djGJQPReNimdjkZu3wFZl1Vb69GyIw0HOA6kzQtgKzIQShdLSEPq9m8OJh4eYoQ2GS9cirriWHQJkJ1hx9nAu)gO3dCczhvIteMHeLzQBRV5L63a9Eqmrl6qunDLm1jdYmrv2JHswVuOEgE0XdCczhvBq2EbKOie4q1rLrTadp64AbXeTOdr10vYuNuFAZmxk1MQfqN3GiP2eTamPhMuwlSb69aNq2rL4eHzaqS(v1hB9BGEpSX0IPKuNqaqS(gnQFd07Hn4mKQoqk1aGy9nAupXuFS1NmedxoGG13Or9jdXWKW6JR(40cm8OJRfeNJoU(0MzEmQnvlGoVbrsTjAbyspmPSwyd07boHSJkylNeWG9yOK1VupXRVrJ6JTEgEuJOcDuMI26BU(MuFJg1hB9m8Ogrf6OmfT13C9XR(v1Fmi6xir74SdXa68gejRpU6JtlWWJoUwGti7OAYT(0MzorsBQwaDEdIKAt0cWKEyszTadpQruHoktrB9gEP(Mu)Q6JT(nqVh4eYoQGTCsad2JHsw)s9BGEpWjKDubB5KagKzIQShdLS(40cm8OJRf4eYoQ2CMmbuFAZmNixBQwaDEdIKAt0cWKEyszTadpQruHoktrB9gEP(MOfy4rhxlWjKDuHeveCS0X1N2mZBkAt1cOZBqKuBIwGHhDCTaNq2rLm1APGOvlaBzQRfmxlat6HjL1cBGEpabroHS9OoHqIm8QFv9m8Ogrf6OmfT13C9nP(v1hB9hdI(fyzrqANc5JoEaDEdIK13Or9XwpXu)XGOFHXiMIteMizaDEdIK1VQE2qXKEyGti7OseqwgbPoHqYUK1B4L6Jx9XvFJg1Vb69aNq2rL4eHzGCI86JtFAZmVP1MQfqN3GiP2eTamPhMuwlWWJAevOJYu0wFZ13eTadp64AboHSJQniBp9PnlEexBQwG6hMjG4PODTGm7CqeEgEPPeJAbQFyMaINIklJKu(qTG5AbgE0X1cOXbYhDCTa68gej1MOpTzXZCTPAbgE0X1cCczhvBotMaQfqN3GiP2e9PpTG8yeLr)0MQnZCTPAb05nisQnrlat6HjL1cYJrug9lqsTh7qSEdVuV5exlWWJoUwydsDj1N2S4PnvlGoVbrsTjAbyspmPSwqEmIYOFbsQ9yhI1B4L6nN4AbgE0X1cBqQlP(0M1eTPAbgE0X1cIjArhIQPRKPoPwaDEdIKAt0N2mPuBQwGHhDCTaNq2rLm1APGOvlGoVbrsTj6tBwmQnvlWWJoUwGti7OAYTwaDEdIKAt0N2mIK2uTadp64AblGiM(yK1cOZBqKuBI(0NwaTw0HOvBQ2mZ1MQfqN3GiP2eTamPhMuwlSbsxj2YwS(v1Vb69aNq2rL4eHzGCI86xv)gO3djGJQPReNimdKtKx)Q63a9EGti7Oc2Yjbmypgkz9l1Vb69aNq2rfSLtcyqMjQYEmuY6B0O(JkJQBuKuS(MRhodi5e5boHSJkXjcZqIYm1TAbgE0X1cBWzivtxDTOcDuwQ6tBw80MQfqN3GiP2eTadp64Ab44q0VKpKu1bzzulat6HjL1cBGEpKaoQMUsCIWmqorE9RQFd07boHSJkXjcZa5e51VQ(yRNyQFdKUsSLTy9nAu)rLr1nkskwFZ1dNbKCI8aNq2rL4eHzirzM626JR(v1lZohoQmQUrjZeTEdVupsuecCO6OYOwaK6OcsQfis6tBwt0MQfqN3GiP2eTamPhMuwlSb69qc4OA6kXjcZa5e51VQ(nqVh4eYoQeNimdKtKRfy4rhxl0hiGfjvSHIj9q1gzz9Pntk1MQfqN3GiP2eTamPhMuwlSb69qc4OA6kXjcZa5e51VQ(nqVh4eYoQeNimdKtKRfy4rhxlqaGtsk7QPRydfZ5A1N2SyuBQwaDEdIKAt0cWKEyszTWgO3djGJQPReNimdKtKx)Q63a9EGti7OsCIWmqorUwGHhDCTGiqs7sL6euBq2E6tBgrsBQwaDEdIKAt0cWKEyszTWgO3djGJQPReNimdKtKx)Q63a9EGti7OsCIWmqorUwGHhDCTqsffbrf1vwrgI6tBgrU2uTa68gej1MOfGj9WKYAHnqVhsahvtxjorygiNiV(v1Vb69aNq2rL4eHzGCICTadp64AHRfva(EaCsvFsiQpTznfTPAb05nisQnrlat6HjL1cet9BG0vITSfRFv9BGEpWjKDujorygiNiV(v1dNbKCI8aNq2rL4eHzirzM626xv)gO3dCczhvWwojGb7XqjRFP(nqVh4eYoQGTCsadYmrv2JHsw)Q6JTEIP(Jbr)cjGJQPReNimdOZBqKS(gnQNHhD8qc4OA6kXjcZaSLtcOT(4QVrJ6pQmQUrrsX6BUE4mGKtKh4eYoQeNimdjkZu3Qfy4rhxliJYtkv10vGaqkPImrw2QpTznT2uTa68gej1MOfGj9WKYAHnq6kXw2I1VQ(nqVh4eYoQeNimdKtKx)Q63a9EibCunDL4eHzGCI86xv)gO3dCczhvWwojGb7XqjRFP(nqVh4eYoQGTCsadYmrv2JHswFJg1FuzuDJIKI13C9WzajNipWjKDujorygsuMPUvlWWJoUwiAsqsJi1vjAhNDiQp9PpTGrmT0X1MfpIBEtt8McXBIwiItN6eSAbImzXjpKSEIu9m8OJxpi1E2qTwliMtNcIAHywF8ti7y9eXzcyToM13ENOngsAPjqVwGDaoYsBPYaG8rhhMC)K2sLHsxRJz9Mngr5nM1BU5suF8iU5nDTUwhZ6JbTStaTXq16ywprOE7X5P2aPReBzlkr92BevBG0vITSfLOE2jRNnIjtavBG0vGOt4ARNtS(w2jbrY63sT(RfRNjjhpuRJz9eH6pojGx4OYO6gfjfRNiy46J9OYO6gfjfJRE7u)1Yx9ry9KJBiU6rIcrRLAebLA9BG0RF86VKTT1t71hH1toUH4QpI9R(Bc16ADmRNiIOie4qY63yFsSE4iV5R(nsG62q9XhcrXZwVporOLt5oay9m8OJBRFCqPgQ1XSEgE0XTbXeHJ8MVLoiBLSwhZ6z4rh3geteoYB(myr6(mK16ywpdp642GyIWrEZNblsZaeKr)4JoETMHhDCBqmr4iV5ZGfP5eYoQO(HGGi8Q1m8OJBdIjch5nFgSinNq2rvNLPGuoR1XSE44wmnIkz256P26VwSEz256fXeI(XeW6JW6Jy)Q)M6jm1torE93upjqsDc1dh3IPrmupr2vVJiPT(BQhezJy9OpaeARpNrU(BQpAs7vpKTy9wi6CsN6TISC9X3K6hhuQ1tcKuNq9X3qgQ1m8OJBdIjch5nFgSiTroP8geLWzzCboUftJOsMDwIrCXINegzqaCHirCdIhXLcSHIj9WasSauXHAXa68gejR1m8OJBdIjch5nFgSiTroP8geLWzzCPp(PihGniQgxbyrjgXflEsyKbbWfKybOIIizGnuBlNSv1h)utxjoryUkwKybOIIizGaits5BsRAZKeWgnqIfGkkIKbcGmjLVjTkzKKbbPJ3ObsSaurrKmqj40JoUsMjGwvhWInAGelavuejdNHYoAvBoL0ksD02ObsSaurrKmWgkqIx7yvwQtajvIGaYmbSrdKybOIIizGDif9tjPpNA6QiQLCKB0ajwaQOisgSTduYn9W0Q6StOrdKybOIIizWrGKbvwP6SOfvO3YoeZgnqIfGkkIKHndIDAIQDYoSnUADmRNHhDCBqmr4iV5ZGfPTolABNtzp(S1AgE0XTbXeHJ8MpdwKgWIk6HYs4SmUWgQTLt2Q6JFQPReNimR1m8OJBdIjch5nFgSiTmnZjvuzMawRz4rh3geteoYB(myrAX5OJxRz4rh3geteoYB(myrAoHSJQniBVADToM1teruecCiz9OrmLA9hvgR)AX6z4nz9uB9SrMcYBqmuRz4rh3Uaha)W0kIGG1AgE0XTgSiTvebbThYG1AgE0XTgSiDIYJrubbslwRz4rh3AWI0qgeuXWJoUcKApjCwgxqRfDiAR1m8OJBnyrAalQOhklHZY4cBO2wozRQp(PMUsCIWucAFzd07HeWr10vIteMbYjYxTb69aNq2rL4eHzGCI8vXcNbKCI8aNq2rL4eHzirzM62MxKsdmN4sbJCs5nig6JFkYbydIQXvawCfCgqYjYdOXbYhD8qIYm1TnVyKtkVbXaBetMaQ2aPRarNW1AGuAG5exkyKtkVbXqF8troaBqunUcWInACuzuDJIKIndNbKCI8aNq2rL4eHzirzM624Q1XSEPOM6VPEtasVEdzlBX6JArVEgmrMuQ1VbsN6eKO(jRpQf963J1wFefeSEskwVDgpuRz4rh3AWI0qgeuXWJoUcKApjCwgx2aPlbTVSbsxj2YwSrJypQmQUrrsXMnYjL3GyGnIjtavBG0vGOt4AJRwhZ6fooV6nbi96nKTSfRpQf96JFczhR3qorywp1wFImPuRNDY6jImoq(OJxFefeS(nwFImPuRp2XRNnIjtaJR(n2NeR)AX63aPxVylBX6P26hJygQp(G2PEzwsSElqI1hH1tyU6LY6JFczhRpg0Yjb0kr9twpK96jGx9sz9XpHSJ1hdA5KaARpIET1hdA5KaswVueXqTMHhDCRblsdzqqfdp64kqQ9KWzzCzdKUe0(sSWzajNipWjKDujorygsuMPUDH4RGZasorEanoq(OJhsuMPUT5f2iMmbuTbsxbIoHRDvSBGEpWjKDubB5KagShdLCzd07boHSJkylNeWGmtuL9yOKnAe7XGOFbylNeqsfGyaDEdIKRGZasorEa2YjbKubigsuMPUDH4R2a9EGti7Oc2YjbmypgkzZlMhxCXvRz4rh3AWI0qgeuXWJoUcKApjCwgxGJBX0ikbTVqmBG0vITSfR1m8OJBnyrAidcQy4rhxbsTNeolJlYJrug9RwxRJz9ezomrz0V6hGS(nq61l2YwSE4a4hMH6jI1IoAeZ6JW6r)WS(RfR)3aP)1ZWJoUT(i61oax9BK6eQN61Z1VbsVEXw2Isup9Qxgz3w)1Yx9ry9CI1Z7b4Q)M6ThNx9JJHADmRNHhDCBydK(IroP8geLWzzC5MJbvBG0TsmIlmjPegzqaCXCjO9fIzdKUsSLTyToM1ZWJoUnSbs3GfPThNNAdKUsSLTOe0(cXSbsxj2YwSwhZ6jICY6VwS(nq61l2YwS(Ow0RpcRxkgWE1JghiFizOwhZ6z4rh3g2aPBWI02BevBG0vITSfLG2x2aPReBzlUsmrJkcqYG5b04a5Jo(QypQmQUrrsX4mSroP8gedSrmzcOAdKUceDcx7Qnq6kXw2IksGKp64gM416ywFmSO1w)1YE9Mxp1ThYK1p96rIfGbT1Ft9exI63iKbSy9tVEXejcq2E1h)eYowVjGS9Q1m8OJBdBG0nyrAylNeqsfGOe0(YgO3dCczhvWwojGb7XqjBEX8Andp642WgiDdwKwMM5KkQmtaR1m8OJBdBG0nyrAhVwmvhklI2tcAFj2e7jAB5ni2ObXCuOKuNqCR2a9EGti7Oc2Yjbmypgk5YgO3dCczhvWwojGbzMOk7XqjxTb69qc4OA6kXjcZa5e5R2a9EGti7OsCIWmqorEToM1teRf96ta3PoH6BQzetXjctKuI6zNS(iSEcZvpxFtfaiw)0R302erB9I5aRp24hdp(1hH1tyU6hGSEP8ARp(jKDS(yqlNeW6ns56JbTCsajRxkIyCsupGfRNE1VX(Ky9awQtO(MQXqAq8nKsu)gHmGfR)AX6LzNRprsa4rhVEQT(5AXmIAX6b5Kack16Jy7HK1BPoeR)AX6JVj1hX267jI1ZUuJyPgQ1m8OJBdBG0nyrAoHSJQniBpjO9LnqVhsaqunD11MiAdaIRoge9lmgXuCIWejdOZBqKCfdpQruHoktrBZnPwZWJoUnSbs3GfPbPeApRskgGKGm6Ne0(YgO3dCczhvIteMbYjYR1m8OJBdBG0nyr6eWr10vIteMsq7leZgO3dCczhvIteMbaXvXkZoheHNHxIrI3ObCgqYjYdCczhvIteMHeLzQBxiECRIDd07boHSJkylNeWG9yOKlBGEpWjKDubB5KagKzIQShdLmUAndp642WgiDdwKEJPftjPoHAndp642WgiDdwKMti7OsCIWSwZWJoUnSbs3GfPbSOIEOSvcAFzd07boHSJkXjcZaGyJgXEuzuDJIKIndNbKCI8aNq2rL4eHzirzM624Q1m8OJBdBG0nyr6n4mKQoqk1Andp642WgiDdwKUttCdodzTMHhDCBydKUblsZoeTxYGkidcwRz4rh3g2aPBWI0IjArhIQPRKPoPe0(sShdI(fsahvtxjorygqN3Gi5QnqVhsahvtxjorygsuMPUT5LnqVhet0IoevtxjtDYGmtuL9yOKsbgE0XdCczhvBq2EbKOie4q1rLX4A0yd07boHSJkXjcZqIYm1TnVSb69GyIw0HOA6kzQtgKzIQShdLukWWJoEGti7OAdY2lGefHahQoQmwRz4rh3g2aPBWI0IZrhxcAFzd07boHSJkXjcZaG4Qy3a9EyJPftjPoHaGyJgBGEpSbNHu1bsPgaeB0GyInzigUCabB0izigMegxC1AgE0XTHnq6gSinNq2r1KBjO9LnqVh4eYoQGTCsad2JHsUq8gnILHh1iQqhLPOT5M0OrSm8Ogrf6OmfTnhVvhdI(fs0oo7qmGoVbrY4IRwZWJoUnSbs3GfP5eYoQ2CMmbucAFHHh1iQqhLPO1WlnzvSBGEpWjKDubB5KagShdLCzd07boHSJkylNeWGmtuL9yOKXvRz4rh3g2aPBWI0CczhvirfbhlDCjO9fgEuJOcDuMIwdV0KADmRNiJGpjwF8ti7y9eXPwlfeT1tcKuNq9XpHSJ1BiNimLOE2sjX675ixVDKX6nIPuR3kIqANcRhjkefp64wjQhKkjwVpx9TSrQtO(MAgXuCIWejR)yq0pKS(v1NaUtDc13eIwF8ti7y9gsazzeK6ec1AgE0XTHnq6gSinNq2rLm1APGOvcAFzd07biiYjKTh1jesKH3kgEuJOcDuMI2MBYQypge9lWYIG0ofYhD8a68gejB0iwI5yq0VWyetXjctKmGoVbrYvSHIj9WaNq2rLiGSmcsDcHKDjn8s8IRrJnqVh4eYoQeNimdKtKhNeWwM6lMxRz4rh3g2aPBWI0CczhvBq2Esq7lm8Ogrf6OmfTn3KADmR3SjQ(RLV6JqdrI1toow)giDQtqI6JW6HSxpGijFy9xlwpBetMaQ2aPRarNW1wFe9AR)AX6brNW1w)0R)AP263aPhQ1XSEgE0XTHnq6gSiTroP8geLWzzCHnIjtavBG0vGOt4ALyexS4jHrgeaxI1iNuEdIb2iMmbuTbsxbIoHRvkyKtkVbXWnhdQ2aPBjcg5KYBqmWgXKjGQnq6kq0jCTge7giDLylBrfjqYhD84ItkAJCs5nigU5yq1giDBTMHhDCBydKUblsJghiF0XLG6hMjG4PO9fz25Gi8m8stjgLG6hMjG4POYYijLpCX8ADmRVP(K1FTy9jNy9deYw641h1IjwFewpHP(zKRFJ9jX6rJdKp641tT1VzOK1digQpwPiwageuQ1VridyX6JW6jGx9gXuQ1VzY6tNq92P(RfRFdKE9uB9qGREJyk16TTtEXvRz4rh3g2aPBWI0CczhvBotMawRR1m8OJBdWXTyAexKPzoPIkZeWAndp642aCClMgrdwKg2YjbKubikbTVSb69aNq2rfSLtcyWEmuYfIxRz4rh3gGJBX0iAWI0oETyQouweTNe0(sSj2t02YBqSrdI5OqjPoH4wTb69aNq2rfSLtcyWEmuYLnqVh4eYoQGTCsadYmrv2JHsUAd07HeWr10vIteMbYjYxTb69aNq2rL4eHzGCI8Andp642aCClMgrdwKMti7OAYTe0(YgO3dCczhvWwojGb7XqjBEjERIfodi5e5boHSJkXjcZqIYm1Tg2CI3ObdpQruHoktrBZlXlUADmRp(jKDSEtaz7vVTL2pB9aI1t96ft6K0tQ1h1IE9jG7uNq9jaiw)0R)AteTHAndp642aCClMgrdwKMti7OAdY2tcAFzd07HeaevtxDTjI2aG4QnqVh4eYoQGTCsad2JHsA4MuRz4rh3gGJBX0iAWI0awurpuwcNLXLJsI2BszfCirIkbTVSb69qc4OA6kXjcZa5e5RiMnqVh4eYoQeNimdjYWBfCgqYjYdCczhvIteMHeLzQBnC8iETMHhDCBaoUftJOblsdyrf9qzjWEhHNYzzCbkvi4C54uOAdY2tcAFzd07HeWr10vIteMbYjYxrmBGEpWjKDujorygsKH3k4mGKtKh4eYoQeNimdjkZu3A44r8Andp642aCClMgrdwKobCunDL4eHPe0(YgO3dCczhvWwojGb7Xqjx2a9EGti7Oc2YjbmiZevzpgk5Qy7aGGQeHTCsavhvgBEbjkcbouDuzSrJoaiOkrylNeq1rLXMxGZasorEGti7OsCIWmKOmtDBJghvgv3OiPyZlWzajNipWjKDujorygsuMPUnUAndp642aCClMgrdwKMti7OsMATuq0kbTViZoheHxZlnDmUAd07biiYjKTh1jesKH3kgEuJOcDuMI2MBIeWwM6lMxRJz9XWaKuNq9WXTyAeLO(iSE7rbbRxkgWE1hX(v)n1dh)OoawVpx9K5iksDc1dB5KaARNT1dooH6zB9IJ1s3GyqyQxsefR3qSbsN6eme1Z26bhNq9STEXXAPBqS(yzj56HJBX0iQKzNR)At022oGKXvp7K1FTOxVnIfR)M656LsIwF8nHiy44V5mRhoUftJy95C8rhpuprwV(iSEYPEFU6BzJy9sz9Xpgir9ry9q2RNKkwVfKsO9aLA9GteM1Ft9eWREUEP8ARp(XGq9eXW6zq7uVfWEm1RNV656BPeAXSEz256fXeI(XeW6JArV(iSErq2R)M6bSy9C9nvaow)0R3qorywpjqsDc1dh3IPrSEXw2IsuVDQpcRhYE9BG0RNeiPoH6VwS(MkahRF61BiNimd1AgE0XTb44wmnIgSinNq2r1MZKjGsq7lXg7gO3dCczhvWwojGb7Xqjx2a9EGti7Oc2YjbmiZevzpgkzCRInwz25Gi8AEXiNuEdIb44wmnIkz254A0i2Jbr)cjGJQPReNimdOZBqKCfCgqYjYdCczhvIteMHeLzQBnmCgqYjYdjGJQPReNimdDaqqvIWwojGQJkJRKzNdIWR5fJCs5nigGJBX0iQKzNniEXyCX1OrShdI(f4eYoQMChqN3Gi5k4mGKtKh4eYoQMChsuMPUT5fcqYvWzajNipWjKDujorygsuMPU1WMt84IRrdz25Gi8AEjwJCs5nigGJBX0iQKzNjcMt84Q1XSEbarm9Xixp1w)MteuQ1hn51wpKTh1jir9rTuyB9uB9rTsTE6vp1wVDQVZz9KtKlr9Jdk16LIbSx98EmI1hFtc1xRz4rh3gGJBX0iAWI0warm9XilbTViZoheHxZlnDmwRJz9XWruSEdXgiDQtWqup1RNhSEl9a4JoUTEa)OG1dh3IPrujZoxVi8c1h)(Hz9xlF1poOuRhY2R(4tevFe9ARVj1h)eYowpSLtcOvI6TuhI1tpdHTEguESx9iXcWG1lZoxpCSx93upxFtQ3EmuY6JVj1ZUuJyPgQp(x9xlF1lou)Qp(dru95C8rhV(ikiy9BS(4Bs9eTjebdhFIiIGHJ)MZSwZWJoUnah3IPr0GfP5eYoQqIkcow64sq7lm8Ogrf6OmfTgEPjRIvMDoicpdVyKtkVbXaCClMgrLm7CJgBGEpWjKDubB5KagShdLCPjXvRz4rh3gGJBX0iAWI0CczhvBq2E1AgE0XTb44wmnIgSinNq2r1MZKjG16Andp642aATOdr7YgCgs10vxlQqhLLQe0(YgiDLylBXvBGEpWjKDujorygiNiF1gO3djGJQPReNimdKtKVAd07boHSJkylNeWG9yOKlBGEpWjKDubB5KagKzIQShdLSrJJkJQBuKuSz4mGKtKh4eYoQeNimdjkZu3wRz4rh3gqRfDiAnyrA44q0VKpKu1bzzucqQJki5crscAFzd07HeWr10vIteMbYjYxTb69aNq2rL4eHzGCI8vXsmBG0vITSfB04OYO6gfjfBgodi5e5boHSJkXjcZqIYm1TXTsMDoCuzuDJsMjQHxqIIqGdvhvgR1m8OJBdO1IoeTgSiDFGawKuXgkM0dvBKLLG2x2a9EibCunDL4eHzGCI8vBGEpWjKDujorygiNiVwZWJoUnGwl6q0AWI0ea4KKYUA6k2qXCUwjO9LnqVhsahvtxjorygiNiF1gO3dCczhvIteMbYjYR1m8OJBdO1IoeTgSiTiqs7sL6euBq2Esq7lBGEpKaoQMUsCIWmqor(QnqVh4eYoQeNimdKtKxRz4rh3gqRfDiAnyr6KkkcIkQRSImeLG2x2a9EibCunDL4eHzGCI8vBGEpWjKDujorygiNiVwZWJoUnGwl6q0AWI0xlQa89a4KQ(KqucAFzd07HeWr10vIteMbYjYxTb69aNq2rL4eHzGCI8Andp642aATOdrRblslJYtkv10vGaqkPImrw2kbTVqmBG0vITSfxTb69aNq2rL4eHzGCI8vWzajNipWjKDujorygsuMPUD1gO3dCczhvWwojGb7Xqjx2a9EGti7Oc2YjbmiZevzpgk5QyjMJbr)cjGJQPReNimdOZBqKSrdgE0XdjGJQPReNimdWwojG24A04OYO6gfjfBgodi5e5boHSJkXjcZqIYm1T1AgE0XTb0ArhIwdwKoAsqsJi1vjAhNDikbTVSbsxj2YwC1gO3dCczhvIteMbYjYxTb69qc4OA6kXjcZa5e5R2a9EGti7Oc2Yjbmypgk5YgO3dCczhvWwojGbzMOk7XqjB04OYO6gfjfBgodi5e5boHSJkXjcZqIYm1T16Andp642G8yeLr)wSTuzzmLG2xKhJOm6xGKAp2HOHxmN41AgE0XTb5XikJ(zWI0BqQlPe0(I8yeLr)cKu7Xoen8I5eVwZWJoUnipgrz0pdwKwmrl6qunDLm1jR1m8OJBdYJrug9ZGfP5eYoQKPwlfeT1AgE0XTb5XikJ(zWI0CczhvtUR1m8OJBdYJrug9ZGfPTaIy6JrwlWax7KAbbQmaiF0XJbj3p9PpTga]] )


end
