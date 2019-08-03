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


    spec:RegisterPack( "Arcane", 20190803, [[d0K6gbqieuEeLIUebbQnjf9jccnkHsNsOYQKckVIKQzra3sOi7sWViqddb5ysHwgjHNrPW0ekQRHGQTjfKVjfunoeqDoPaToeanpHQUNuAFKeDqHclKK0djiQjkfaCrea2OuavFKGa5KiG0kvsEPua0mLcaDteq0oPu6NsbugkbrwQua6PiAQKuUkbb8veqyVe9xsnyvDyulwPEmWKj0LH2Su9zeA0kXPrA1ee0RjOMnOUnj2nv)wXWPKJlfqwUONtX0v56GSDkvFxiJhb68eKwpcqZxj1(LSSrPAssr(qPTQGqn2GeIatiBeASHIzvOcvijpHAHsslgimteLKoRGsYyKa2rjPflu4HfLQjjnducqj5YDwgcqbfKi9wG2bWOiOHQabZhDCqY9tqdvbiOKCdrHpcuxULKI8HsBvbHASbjebMq2i0ydfZns4eyjPXcbsBBivijxOIIOl3ssr0aKK2S(yKa2X6jqYeXALnRF5oldbOGcsKElq7ayue0qvGG5Jooi5(jOHQaeSwzZ6JberiZvVneOEvqOgBW6JP6judsas4e4AvTYM1lKxyNiAiaRv2S(yQEZX5P3qPRTwydkq9MBS0BO01wlSbfOE2fRNTJjte1BO01WOt8wQNtS(f2fHrX63cT(BbRNffhpuRSz9Xu9hNeXlCufuFJwKI1htQS(y3JX08OkO(gTifJREZu)TWx9ry9IJleV6rccqJHAhHfA9BO0RF86VKnl1t71hH1loUq8QpI9R(BcssyQ5ms1KKGXnyAhLQjTTrPAssgC0XLKk0mNutvyIOKeDEdJIsvLN0wvivtsIoVHrrPQssqspmPSKCd17bobSJAWcNeXG5yGW13wpHKKm4OJljblCsef1qwYtARnKQjjrN3WOOuvjjiPhMuwsgB9j2t0SWByS(1RRNWQ)OaHPoX6JR(M1VH69aNa2rnyHtIyWCmq46BRFd17bobSJAWcNeXGctqT5yGW13S(nuVhsih1txBnrygeNiV(M1VH69aNa2rT1eHzqCICjjdo64sshVfm1hQyHMtEsBJzPAss05nmkkvvscs6HjLLKBOEpWjGDudw4KigmhdeU(4BRxf13S(yRhmdS4e5bobSJARjcZqIkm1n1RY6BKq1VED9m4O2rn6Ocfn1hFB9QO(4KKm4OJlj5eWoQNClpPTeUunjj68ggfLQkjbj9WKYsYnuVhsiyupD9TKiAcqw13S(nuVh4eWoQblCsedMJbcxVkR3gssgC0XLKCcyh1By2CYtABdjvtsIoVHrrPQssgC0XLKhven3KkAWiIeuscs6HjLLKBOEpKqoQNU2AIWmiorE9nRNWQFd17bobSJARjcZqIm4QVz9GzGfNipWjGDuBnrygsuHPUPEvwVkiKK0zfusEur0CtQObJisq5jTTHlvtsIoVHrrPQssgC0XLKaHcGNlhNc0By2CssqspmPSKCd17HeYr901wteMbXjYRVz9ew9BOEpWjGDuBnrygsKbx9nRhmdS4e5bobSJARjcZqIkm1n1RY6vbHKKyVJGt7SckjbcfapxoofO3WS5KN0wcSunjj68ggfLQkjbj9WKYsYnuVh4eWoQblCsedMJbcxFB9BOEpWjGDudw4KiguycQnhdeU(M1hB9DiyyDIGfojI6JQG1hFB9ibra0H6JQG1VED9DiyyDIGfojI6JQG1hFB9GzGfNipWjGDuBnrygsuHPUP(1RR)OkO(gTifRp(26bZalorEGta7O2AIWmKOctDt9XjjzWrhxsMqoQNU2AIWuEsBBqPAss05nmkkvvsYGJoUKKta7OwHAmuy0ijblm1LKnkjbj9WKYssf25Gf4Qp(26BqcV(M1VH69aag5eWMJ6edjYGR(M1ZGJAh1OJku0uF81Bd5jTTrcjvtsIoVHrrPQssqspmPSKm26JT(nuVh4eWoQblCsedMJbcxFB9BOEpWjGDudw4KiguycQnhdeU(4QVz9XwFS1RWohSax9X3wVDoP8ggdGXnyAh1kSZ1hx9RxxFS1Fmm6xiHCupDT1eHzaDEdJI13SEWmWItKh4eWoQTMimdjQWu3uVkRhmdS4e5HeYr901wteMHoemSorWcNer9rvW6BwVc7CWcC1hFB925KYBymag3GPDuRWoxV61RccV(4QpU6xVU(yR)yy0VaNa2r9K7a68ggfRVz9GzGfNipWjGDup5oKOctDt9X3wprGy9nRhmdS4e5bobSJARjcZqIkm1n1RY6BKq1hx9Xv)611RWohSax9X3wFS1BNtkVHXayCdM2rTc7C9Xu9nsO6JtsYGJoUKKta7OEZzYer5jTTXgLQjjrN3WOOuvjjiPhMuwsQWohSax9X3wFds4ssgC0XLKgilm9XolpPTnQcPAss05nmkkvvscs6HjLLKm4O2rn6Ocfn1RY26Tr9nRp26vyNdwGREv2wVDoP8ggdGXnyAh1kSZ1VED9BOEpWjGDudw4KigmhdeU(26Tr9XjjzWrhxsYjGDuJe0cEm0XLN02gTHunjjdo64ssobSJ6nmBojj68ggfLQkpPTngZs1KKm4OJlj5eWoQ3CMmrusIoVHrrPQYtEssrSZqWNunPTnkvtsYGJoUKemq(HPXcHHLKOZByuuQQ8K2QcPAssgC0XLKgleg2CidljrN3WOOuv5jT1gs1KKm4OJljtuzSJAauAqjj68ggfLQkpPTXSunjj68ggfLQkjzWrhxscyyyndo64AyQ5KKWuZPDwbLKOXGoanYtAlHlvtsIoVHrrPQssqspmPSKCdLU2AHny9RxxFS1FufuFJwKI1hF925KYBymW2XKjI6nu6Ay0jEl1hNKKbhDCjjGHH1m4OJRHPMtsctnN2zfusUHsxEsBBiPAss05nmkkvvscs6HjLLKXwpygyXjYdCcyh1wteMHevyQBQVTEcvFZ6bZalorEaTpa(OJhsuHPUP(4BRNTJjte1BO01WOt8wQVz9Xw)gQ3dCcyh1GfojIbZXaHRVT(nuVh4eWoQblCsedkmb1MJbcx)611hB9hdJ(falCsef1qwb05nmkwFZ6bZalorEaSWjruudzfsuHPUP(26ju9nRFd17bobSJAWcNeXG5yGW1hFB9nwFC1hx9XjjzWrhxscyyyndo64AyQ5KKWuZPDwbLKBO0LN02gUunjj68ggfLQkjbj9WKYsscR(nu6ARf2GssgC0XLKaggwZGJoUgMAojjm1CANvqjjyCdM2r5jTLalvtsIoVHrrPQssgC0XLKaggwZGJoUgMAojjm1CANvqjPYyhvq)KN8KKwjcgLnFs1K22Ounjjdo64ssobSJAQFimmcojj68ggfLQkpPTQqQMKKbhDCjPbsrzCnNa2rDNvOWuoLKOZByuuQQ8K2AdPAss05nmkkvvsowssdEssgC0XLK25KYByusANHHqjzdrO6vVEvqO6By1ZeqmPhgWgiiQ1qnyaDEdJIss7CQDwbLKGXnyAh1kSZYtABmlvtsIoVHrrPQssNvqjjtanlCYgDF8tpDT1eHPKKbhDCjjtanlCYgDF8tpDT1eHP8K2s4s1KKm4OJljvOzoPMQWerjj68ggfLQkpPTnKunjjdo64ssR5OJljrN3WOOuv5jTTHlvtsYGJoUKKta7OEdZMtsIoVHrrPQYtEsYnu6s1K22Ounjj68ggfLQkjbj9WKYsYnuVh4eWoQblCsedMJbcxF8T13OKKbhDCjjyHtIOOgYsEsBvHunjjdo64ssfAMtQPkmrusIoVHrrPQYtARnKQjjrN3WOOuvjjiPhMuwsgB9j2t0SWByS(1RRNWQ)OaHPoX6JR(M1VH69aNa2rnyHtIyWCmq46BRFd17bobSJAWcNeXGctqT5yGW13S(nuVhsih1txBnrygeNiV(M1VH69aNa2rT1eHzqCICjjdo64sshVfm1hQyHMtEsBJzPAss05nmkkvvscs6HjLLKBOEpKqWOE66Bjr0eGSQVz9hdJ(fg7yAnryIIb05nmkwFZ6zWrTJA0rfkAQp(6THKKbhDCjjNa2r9gMnN8K2s4s1KKOZByuuQQKeK0dtklj3q9EGta7O2AIWmiorUKKbhDCjjmL4Yz0cHqIevq)KN02gsQMKeDEdJIsvLKm4OJljzcOzHt2O7JF6PRTMimLKGKEyszjjygyXjYdCcyh1wteMHevyQBQp(6j86xVU(JQG6B0IuS(4RhmdS4e5bobSJARjcZqIkm1nssNvqjjtanlCYgDF8tpDT1eHP8K22WLQjjrN3WOOuvjjiPhMuwssy1VH69aNa2rT1eHzaYQ(M1hB9kSZblWvVkBRNWju9RxxpygyXjYdCcyh1wteMHevyQBQVTEcvFC13S(yRFd17bobSJAWcNeXG5yGW13w)gQ3dCcyh1GfojIbfMGAZXaHRpojjdo64sYeYr901wteMYtAlbwQMKKbhDCj5gtdMctDIss05nmkkvvEsBBqPAssgC0XLKCcyh1wteMss05nmkkvvEsBBKqs1KKOZByuuQQKeK0dtklj3q9EGta7O2AIWmazv)611hB9hvb13OfPy9XxpygyXjYdCcyh1wteMHevyQBQpojjdo64ssidQPhQyKN02gBuQMKKbhDCj5gEgrDhkfQKeDEdJIsvLN02gvHunjjdo64sYonXn8mIss05nmkkvvEsBB0gs1KKm4OJljzhGMlzynGHHLKOZByuuQQ8K22ymlvtsIoVHrrPQssqspmPSKm26pgg9lKqoQNU2AIWmGoVHrX6Bw)gQ3djKJ6PRTMimdjQWu3uF8T1VH69GvIg0bOE6AfQlguycQnhdeU(gw9m4OJh4eWoQ3WS5cibra0H6JQG1hx9Rxx)gQ3dCcyh1wteMHevyQBQp(263q9EWkrd6aupDTc1fdkmb1MJbcxFdREgC0XdCcyh1By2CbKGia6q9rvqjjdo64ssRenOdq901kuxuEsBBKWLQjjrN3WOOuvjjiPhMuwsUH69aNa2rT1eHzaYQ(M1hB9BOEpSX0GPWuNyaYQ(1RRFd17Hn8mI6ouk0aKv9RxxpHvFS1NmadxoWW1VED9jdWWKG6JR(4KKm4OJljTMJoU8K22ydjvtsIoVHrrPQssqspmPSKCd17bobSJAWcNeXG5yGW13wpHQF966JTEgCu7OgDuHIM6JVEBu)611hB9m4O2rn6Ocfn1hF9QO(M1Fmm6xirZ4SdWa68ggfRpU6JtsYGJoUKKta7OEYT8K22ydxQMKeDEdJIsvLKGKEyszjjdoQDuJoQqrt9QSTEBuFZ6JT(nuVh4eWoQblCsedMJbcxFB9BOEpWjGDudw4KiguycQnhdeU(4KKm4OJlj5eWoQ3CMmruEsBBKalvtsIoVHrrPQssqspmPSKKbh1oQrhvOOPEv2wVnKKm4OJlj5eWoQrcAbpg64YtABJnOunjj68ggfLQkjzWrhxsYjGDuRqngkmAKKGfM6sYgLKGKEyszj5gQ3dayKtaBoQtmKidU6BwpdoQDuJoQqrt9XxVnQVz9Xw)XWOFbwXcM2Pa(OJhqN3WOy9RxxFS1ty1Fmm6xySJP1eHjkgqN3WOy9nRNjGyspmWjGDuBbPOGWuNyizx46vzB9QO(4QF9663q9EGta7O2AIWmiorE9XjpPTQGqs1KKOZByuuQQKeK0dtkljzWrTJA0rfkAQp(6THKKbhDCjjNa2r9gMnN8K2QIgLQjjP(HzczDAAxsQWohSaNkBjWeUKK6hMjK1PPkkOiLpus2OKKbhDCjjAFa8rhxsIoVHrrPQYtARkuHunjjdo64ssobSJ6nNjteLKOZByuuQQ8KNKeng0bOrQM02gLQjjrN3WOOuvjjiPhMuwsUHsxBTWgS(M1VH69aNa2rT1eHzqCI86Bw)gQ3djKJ6PRTMimdItKxFZ63q9EGta7OgSWjrmyogiC9T1VH69aNa2rnyHtIyqHjO2Cmq46xVU(JQG6B0IuS(4RhmdS4e5bobSJARjcZqIkm1nssgC0XLKB4ze1txFlOgDurOYtARkKQjjrN3WOOuvjjdo64ssW4a0VKpuu3Hzfuscs6HjLLKBOEpKqoQNU2AIWmiorE9nRFd17bobSJARjcZG4e513S(yRNWQFdLU2AHny9Rxx)rvq9nArkwF81dMbwCI8aNa2rT1eHzirfM6M6JR(M1RWohoQcQVrRWeSEv2wpsqeaDO(OkOKeM6OgikjBi5jT1gs1KKOZByuuQQKeK0dtklj3q9EiHCupDT1eHzqCI86Bw)gQ3dCcyh1wteMbXjYLKm4OJlj7daYGIAMaIj9q9gzf5jTnMLQjjrN3WOOuvjjiPhMuwsUH69qc5OE6ARjcZG4e513S(nuVh4eWoQTMimdItKljzWrhxsseItrk76PRzciMZTipPTeUunjj68ggfLQkjbj9WKYsYnuVhsih1txBnrygeNiV(M1VH69aNa2rT1eHzqCICjjdo64sslOK2fk1jQ3WS5KN02gsQMKeDEdJIsvLKGKEyszj5gQ3djKJ6PRTMimdItKxFZ63q9EGta7O2AIWmiorUKKbhDCjzsTSGrn11glgGYtABdxQMKeDEdJIsvLKGKEyszj5gQ3djKJ6PRTMimdItKxFZ63q9EGta7O2AIWmiorUKKbhDCj5TGAiFpqUOUpjaLN0wcSunjj68ggfLQkjbj9WKYsscR(nu6ARf2G13S(nuVh4eWoQTMimdItKxFZ6bZalorEGta7O2AIWmKOctDt9nRFd17bobSJAWcNeXG5yGW13w)gQ3dCcyh1GfojIbfMGAZXaHRVz9XwpHv)XWOFHeYr901wteMb05nmkw)611ZGJoEiHCupDT1eHzaSWjr0uFC1VED9hvb13OfPy9XxpygyXjYdCcyh1wteMHevyQBKKm4OJljvqLjfQE6AyiavulMiRyKN02guQMKeDEdJIsvLKGKEyszj5gkDT1cBW6Bw)gQ3dCcyh1wteMbXjYRVz9BOEpKqoQNU2AIWmiorE9nRFd17bobSJAWcNeXG5yGW13w)gQ3dCcyh1GfojIbfMGAZXaHRF966pQcQVrlsX6JVEWmWItKh4eWoQTMimdjQWu3ijzWrhxsgnjSODK66enJZoaLN8KKkJDub9tQM02gLQjjrN3WOOuvjjiPhMuwsQm2rf0VGi1CSdW6vzB9nsijjdo64sYnm1fwEsBvHunjj68ggfLQkjbj9WKYssLXoQG(fePMJDawVkBRVrcjjzWrhxsUHPUWYtARnKQjjzWrhxsALObDaQNUwH6Iss05nmkkvvEsBJzPAssgC0XLKCcyh1kuJHcJgjj68ggfLQkpPTeUunjjdo64ssobSJ6j3ss05nmkkvvEsBBiPAssgC0XLKgilm9XoljrN3WOOuv5jp5jjTJPHoU0wvqOgBqc1WvHkKKrC6uNOrssGQyn5HI13q1ZGJoE9WuZzc1kjjdDltkjjPkqW8rhxiNC)KKw50PWOK0M1hJeWowpbsMiwRSz9l3zziafuqI0BbAhaJIGgQcemF0Xbj3pbnufGG1kBwFmGiczU6THa1Rcc1ydwFmvpHAqcqcNaxRQv2SEH8c7erdbyTYM1ht1Boop9gkDT1cBqbQ3CJLEdLU2AHnOa1ZUy9SDmzIOEdLUggDI3s9CI1VWUimkw)wO1Fly9SO44HALnRpMQ)4KiEHJQG6B0IuS(ysL1h7rvq9nArkgx9MP(BHV6JW6fhxiE1JeeGgd1ocl063qPx)41FjBwQN2RpcRxCCH4vFe7x93eQv1kBwpbabra0HI1VX(Ky9GrzZx9BKi1nH6JbaGwNPEF8yAHtLoeC9m4OJBQFCyHgQv2SEgC0XnbRebJYMV2omBeUwzZ6zWrh3eSsemkB(uVvW(mI1kBwpdo64MGvIGrzZN6TcYqevq)4JoETIbhDCtWkrWOS5t9wb5eWoQP(HWWi4Qvm4OJBcwjcgLnFQ3kiNa2rDNvOWuoRv2SEW4gmTJAf256PM6VfSEf256TWeG(XeX6JW6Jy)Q)M6jo1lorE93uViusDI1dg3GPDmupb6vVJOOP(BQhgz7y9OpqexQpNrP(BQpAsZvpGny9ga6CsN6nwSs9Xq16hhwO1lcLuNy9XqifQvm4OJBcwjcgLnFQ3kODoP8ggfWzfSfmUbt7OwHDwGXQ1GNa2zyiSTHiK6QGqnmMaIj9Wa2abrTgQbdOZByuSwzZ6zWrh3eSsemkB(uVvqJZwML50MJptTIbhDCtWkrWOS5t9wbHmOMEOIaoRGTmb0SWjB09Xp901wteM1kgC0XnbRebJYMp1BfuHM5KAQcteRvm4OJBcwjcgLnFQ3kO1C0XRvm4OJBcwjcgLnFQ3kiNa2r9gMnxTQwzZ6jaiicGouSE0oMcT(JQG1Fly9m4MSEQPE2otH5nmgQvm4OJBAbdKFyASqy4Afdo64g1Bf0yHWWMdz4Afdo64g1BfmrLXoQbqPbRvm4OJBuVvqaddRzWrhxdtnNaoRGTOXGoan1kBwVqqt93uVQqPxVqAHny9rlOxpdNilk063qPtDIcu)K1hTGE97XyQpIcdxVifR3mJhQvm4OJBuVvqaddRzWrhxdtnNaoRGTBO0fG2B3qPRTwydUEDShvb13OfPy825KYBymW2XKjI6nu6Ay0jElXvRSz9KhNx9QcLE9cPf2G1hTGE9XibSJ1lKMimRNAQprwuO1ZUy9ea2haF0XRpIcdx)gRprwuO1h741Z2XKjIXv)g7tI1Fly9BO0R3AHny9ut9JDmd1hdyZuVclmwVbkX6JW6jox9XC9XibSJ1lKx4KiAeO(jRhWE9eXR(yU(yKa2X6fYlCsen1hrVL6fYlCsefRxiGvOwXGJoUr9wbbmmSMbhDCnm1Cc4Sc2UHsxaAVnwWmWItKh4eWoQTMimdjQWu30sOMGzGfNipG2haF0XdjQWu3eFlBhtMiQ3qPRHrN4T0m2nuVh4eWoQblCsedMJbc3UH69aNa2rnyHtIyqHjO2Cmq41RJ9yy0VayHtIOOgYkGoVHrXMGzGfNipaw4KikQHScjQWu30sOMBOEpWjGDudw4Kigmhdeo(2gJlU4Qvm4OJBuVvqaddRzWrhxdtnNaoRGTGXnyAhfG2BjSnu6ARf2G1kgC0XnQ3kiGHH1m4OJRHPMtaNvWwLXoQG(vRQv2SEcuhKOc6x9duw)gk96TwydwpyG8dZq9eiwqhTJz9ry9OFyw)TG1)BO0)6zWrh3uFe9wgOR(nsDI1t96563qPxV1cBqbQNE1RGSBQ)w4R(iSEoX659aD1Ft9MJZR(XXqTYM1ZGJoUjSHsV1oNuEdJc4Sc2EZXW6nu6gbgRwwuua7mme22Oa0ElHTHsxBTWgSwzZ6zWrh3e2qPRERGMJZtVHsxBTWguaAVLW2qPRTwydwRSz9eaUy93cw)gk96TwydwF0c61hH1leczU6r7dGpumuRSz9m4OJBcBO0vVvqZnw6nu6ARf2Gcq7TBO01wlSbBALODnrGyOXaAFa8rhVzShvb13OfPyCQ0oNuEdJb2oMmruVHsxdJoXBP5gkDT1cBqTiuYhDCvsOALnRVbq0yQ)wyV(gRN6MdzX6NE9ydeedBQ)M6jKa1VradzW6NE9wjgta2C1hJeWowVQWS5Qvm4OJBcBO0vVvqWcNerrnKLa0E7gQ3dCcyh1GfojIbZXaHJVTXAfdo64MWgkD1BfuHM5KAQcteRvm4OJBcBO0vVvqhVfm1hQyHMtaAVn2e7jAw4nmUEnHDuGWuNyCn3q9EGta7OgSWjrmyogiC7gQ3dCcyh1GfojIbfMGAZXaHBUH69qc5OE6ARjcZG4e5n3q9EGta7O2AIWmiorETYM1tGyb96ti3PoX6BGzhtRjctuuG6zxS(iSEIZvpxFdiemw)0RxTLert9w5aQp2y0amg1hH1tCU6hOS(y(wQpgjGDSEH8cNeX6Tt56fYlCsefRxiGvCcupKbRNE1VX(Ky9qgQtS(gWriPEmescu)gbmKbR)wW6vyNRprriWrhVEQP(5wWmIAW6H5Kicl06JyZHI1BOoaR)wW6JHQ1hXM67jI1ZUqJyHgQvm4OJBcBO0vVvqobSJ6nmBobO92nuVhsiyupD9TKiAcqwnpgg9lm2X0AIWefdOZByuSjdoQDuJoQqrt82OwXGJoUjSHsx9wbHPexoJwiesKOc6Na0E7gQ3dCcyh1wteMbXjYRvm4OJBcBO0vVvqidQPhQiGZkyltanlCYgDF8tpDT1eHPa0ElygyXjYdCcyh1wteMHevyQBINWxV(OkO(gTifJhmdS4e5bobSJARjcZqIkm1n1kgC0XnHnu6Q3kyc5OE6ARjctbO9wcBd17bobSJARjcZaKvZyvyNdwGtLTeoHwVgmdS4e5bobSJARjcZqIkm1nTekUMXUH69aNa2rnyHtIyWCmq42nuVh4eWoQblCsedkmb1MJbchxTIbhDCtydLU6TcUX0GPWuNyTIbhDCtydLU6TcYjGDuBnrywRyWrh3e2qPRERGqgutpuXiaT3UH69aNa2rT1eHzaYA96ypQcQVrlsX4bZalorEGta7O2AIWmKOctDtC1kgC0XnHnu6Q3k4gEgrDhkfATIbhDCtydLU6Tc2PjUHNrSwXGJoUjSHsx9wbzhGMlzynGHHRvm4OJBcBO0vVvqRenOdq901kuxuaAVn2JHr)cjKJ6PRTMimdOZByuS5gQ3djKJ6PRTMimdjQWu3eF7gQ3dwjAqhG6PRvOUyqHjO2Cmq4ggdo64bobSJ6nmBUasqeaDO(OkyCRxVH69aNa2rT1eHzirfM6M4B3q9EWkrd6aupDTc1fdkmb1MJbc3WyWrhpWjGDuVHzZfqcIaOd1hvbRvm4OJBcBO0vVvqR5OJlaT3UH69aNa2rT1eHzaYQzSBOEpSX0GPWuNyaYA96nuVh2WZiQ7qPqdqwRxtyXMmadxoWWRxNmadtcIlUAfdo64MWgkD1BfKta7OEYTa0E7gQ3dCcyh1GfojIbZXaHBj061XYGJAh1OJku0eVnwVowgCu7OgDuHIM4vrZJHr)cjAgNDagqN3WOyCXvRyWrh3e2qPRERGCcyh1BotMikaT3YGJAh1OJku0OYwB0m2nuVh4eWoQblCsedMJbc3UH69aNa2rnyHtIyqHjO2Cmq44Qvm4OJBcBO0vVvqobSJAKGwWJHoUa0EldoQDuJoQqrJkBTrTYM1tGs0NeRpgjGDSEcKuJHcJM6fHsQtS(yKa2X6fsteMcupBOIy99CuQ3mky92XuO1BSqaTtb1JeeGwhDCJa1dtfgR3NR(f2o1jwFdm7yAnryII1Fmm6hkwFZ6ti3PoX6TbbRpgjGDSEHeKIcctDIHAfdo64MWgkD1BfKta7OwHAmuy0iaT3UH69aag5eWMJ6edjYGRjdoQDuJoQqrt82OzShdJ(fyflyANc4JoEaDEdJIRxhlHDmm6xySJP1eHjkgqN3WOytMaIj9WaNa2rTfKIcctDIHKDHvzRkIB96nuVh4eWoQTMimdItKhNaGfM6TnwRyWrh3e2qPRERGCcyh1By2Ccq7Tm4O2rn6OcfnXBJALnR32jQ(BHV6JqHyI1loow)gkDQtuG6JW6bSxpKLiFy93cwpBhtMiQ3qPRHrN4TuFe9wQ)wW6HrN4Tu)0R)wOM63qPhQv2SEgC0XnHnu6Q3kODoP8ggfWzfSLTJjte1BO01WOt8weySAn4jGDggcBJ1oNuEdJb2oMmruVHsxdJoXBPHzNtkVHXWnhdR3qPBIj7Cs5nmgy7yYer9gkDnm6eVf1JDdLU2AHnOwek5JoECXjeSDoP8ggd3CmSEdLUPwXGJoUjSHsx9wbr7dGp64cq9dZeY600ERc7CWcCQSLat4cq9dZeY60uffuKYh22yTYM13aFY6VfS(KtS(baydD86JwWeRpcRN4u)mk1VX(Ky9O9bWhD86PM63mq46HSc1hRqadeddl063iGHmy9ry9eXRE7yk063Sy9PtSEZu)TG1VHsVEQPEa0vVDmfA9MLjV4Qvm4OJBcBO0vVvqobSJ6nNjteRv1kgC0XnbW4gmTJTk0mNutvyIyTIbhDCtamUbt7O6Tccw4KikQHSeG2B3q9EGta7OgSWjrmyogiClHQvm4OJBcGXnyAhvVvqhVfm1hQyHMtaAVn2e7jAw4nmUEnHDuGWuNyCn3q9EGta7OgSWjrmyogiC7gQ3dCcyh1GfojIbfMGAZXaHBUH69qc5OE6ARjcZG4e5n3q9EGta7O2AIWmiorETIbhDCtamUbt7O6TcYjGDup5waAVDd17bobSJAWcNeXG5yGWX3QIMXcMbwCI8aNa2rT1eHzirfM6gv2iHwVMbh1oQrhvOOj(wvexTYM1hJeWowVQWS5Q3Sq7NPEiR6PE9wjDs6j06JwqV(eYDQtS(ecgRF61FljIMqTIbhDCtamUbt7O6TcYjGDuVHzZjaT3UH69qcbJ6PRVLertaYQ5gQ3dCcyh1GfojIbZXaHvPnQvm4OJBcGXnyAhvVvqidQPhQiGZky7rfrZnPIgmIibfG2B3q9EiHCupDT1eHzqCI8Me2gQ3dCcyh1wteMHezW1emdS4e5bobSJARjcZqIkm1nQufeQwXGJoUjag3GPDu9wbHmOMEOIayVJGt7Sc2cekaEUCCkqVHzZjaT3UH69qc5OE6ARjcZG4e5njSnuVh4eWoQTMimdjYGRjygyXjYdCcyh1wteMHevyQBuPkiuTIbhDCtamUbt7O6TcMqoQNU2AIWuaAVDd17bobSJAWcNeXG5yGWTBOEpWjGDudw4KiguycQnhdeUzSDiyyDIGfojI6JQGX3IeebqhQpQcUEDhcgwNiyHtIO(Oky8TGzGfNipWjGDuBnrygsuHPUz96JQG6B0Ium(wWmWItKh4eWoQTMimdjQWu3exTIbhDCtamUbt7O6TcYjGDuRqngkmAeG2BvyNdwGl(2gKWBUH69aag5eWMJ6edjYGRjdoQDuJoQqrt82qaWct92gRv2S(gaGsQtSEW4gmTJcuFewV5OWW1leczU6Jy)Q)M6bJFuhcR3NREXCSSOoX6blCsen1ZM6HhNy9SPERXyOBymqo1lmIw1le3qPtDIcX6zt9WJtSE2uV1ym0nmwFSSWC9GXnyAh1kSZ1FljAwwgyX4QNDX6Vf0R3eXw1Ft9C9XmbRpgQgtQmgBoZ6bJBW0owFohF0Xd1tG2RpcRxCQ3NR(f2owFmxFmeYcuFewpG96fPw1BGPexoyHwp8eHz93upr8QNRpMVL6JHqoupbcSEg2m1BGmht965REU(fkXfmRxHDUElmbOFmrS(Of0RpcR3cM96VPEidwpxFdiKJ1p96fsteM1lcLuNy9GXnyAhR3AHnOa1BM6JW6bSx)gk96fHsQtS(BbRVbeYX6NE9cPjcZqTIbhDCtamUbt7O6TcYjGDuV5mzIOa0EBSXUH69aNa2rnyHtIyWCmq42nuVh4eWoQblCsedkmb1MJbchxZyJvHDoybU4BTZjL3WyamUbt7OwHDoU1RJ9yy0Vqc5OE6ARjcZa68ggfBcMbwCI8aNa2rT1eHzirfM6gvcMbwCI8qc5OE6ARjcZqhcgwNiyHtIO(Okytf25Gf4IV1oNuEdJbW4gmTJAf2z1vbHhxCRxh7XWOFbobSJ6j3b05nmk2emdS4e5bobSJ6j3HevyQBIVLiqSjygyXjYdCcyh1wteMHevyQBuzJekU4wVwHDoybU4BJ1oNuEdJbW4gmTJAf25yQrcfxTYM1tczHPp256PM63CIWcT(OjVL6bS5OorbQpAHcwQNAQpArO1tV6PM6nt9DoRxCICbQFCyHwVqiK5QN3JDS(yOAO(Afdo64MayCdM2r1Bf0azHPp2zbO9wf25Gf4IVTbj8ALnRVbiIw1le3qPtDIcX6PE98G1BOheF0Xn1d5hfUEW4gmTJAf256TaxO(y0pmR)w4R(XHfA9a2C1hdcG6JO3s92O(yKa2X6blCsencuVH6aSE6jen1ZWkJ5QhBGGy46vyNRhmMR(BQNR3g1BogiC9Xq16zxOrSqd1hJR(BHV6TgQF1hJHaO(Co(OJxFefgU(nwFmuTEcAJysLXGaiMuzm2CM1kgC0XnbW4gmTJQ3kiNa2rnsql4XqhxaAVLbh1oQrhvOOrLT2OzSkSZblWPYw7Cs5nmgaJBW0oQvyNxVEd17bobSJAWcNeXG5yGWT2iUAfdo64MayCdM2r1BfKta7OEdZMRwXGJoUjag3GPDu9wb5eWoQ3CMmrSwvRyWrh3eqJbDaAA3WZiQNU(wqn6OIqfG2B3qPRTwyd2Cd17bobSJARjcZG4e5n3q9EiHCupDT1eHzqCI8MBOEpWjGDudw4KigmhdeUDd17bobSJAWcNeXGctqT5yGWRxFufuFJwKIXdMbwCI8aNa2rT1eHzirfM6MAfdo64MaAmOdqJ6TccghG(L8HI6omRGcatDudeBBibO92nuVhsih1txBnrygeNiV5gQ3dCcyh1wteMbXjYBglHTHsxBTWgC96JQG6B0IumEWmWItKh4eWoQTMimdjQWu3extf25Wrvq9nAfMGQSfjicGouFufSwXGJoUjGgd6a0OERG9bazqrntaXKEOEJSIa0E7gQ3djKJ6PRTMimdItK3Cd17bobSJARjcZG4e51kgC0Xnb0yqhGg1BfKieNIu21txZeqmNBraAVDd17HeYr901wteMbXjYBUH69aNa2rT1eHzqCI8Afdo64MaAmOdqJ6TcAbL0UqPor9gMnNa0E7gQ3djKJ6PRTMimdItK3Cd17bobSJARjcZG4e51kgC0Xnb0yqhGg1BfmPwwWOM6AJfdqbO92nuVhsih1txBnrygeNiV5gQ3dCcyh1wteMbXjYRvm4OJBcOXGoanQ3k4TGAiFpqUOUpjafG2B3q9EiHCupDT1eHzqCI8MBOEpWjGDuBnrygeNiVwXGJoUjGgd6a0OERGkOYKcvpDnmeGkQftKvmcq7Te2gkDT1cBWMBOEpWjGDuBnrygeNiVjygyXjYdCcyh1wteMHevyQBAUH69aNa2rnyHtIyWCmq42nuVh4eWoQblCsedkmb1MJbc3mwc7yy0Vqc5OE6ARjcZa68ggfxVMbhD8qc5OE6ARjcZayHtIOjU1RpQcQVrlsX4bZalorEGta7O2AIWmKOctDtTIbhDCtang0bOr9wbJMew0osDDIMXzhGcq7TBO01wlSbBUH69aNa2rT1eHzqCI8MBOEpKqoQNU2AIWmiorEZnuVh4eWoQblCsedMJbc3UH69aNa2rnyHtIyqHjO2Cmq41RpQcQVrlsX4bZalorEGta7O2AIWmKOctDtTQwXGJoUjOm2rf0VwZcvrbtbO9wLXoQG(fePMJDaQY2gjuTIbhDCtqzSJkOFQ3k4gM6claT3Qm2rf0VGi1CSdqv22iHQvm4OJBckJDub9t9wbTs0Goa1txRqDXAfdo64MGYyhvq)uVvqobSJAfQXqHrtTIbhDCtqzSJkOFQ3kiNa2r9K7Afdo64MGYyhvq)uVvqdKfM(yNLN8Ksa]] )


end
