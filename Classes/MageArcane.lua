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


    spec:RegisterPack( "Arcane", 20190722, [[d0eshbqiqP8ikQCjqPk1MKcFIKigffLtjuSkPOuVIKQzra3sOs2LGFrqnmqrhtOQLrG8mkQAAGcCnqH2gOG(MqLY4KIsoNuu16KIkMNuK7jL2hjHdkuXcjj9qsIYejjQWfLIkTrHkv1hbLQKtckvALkHxssuPzssur3euQODku6NcvQYqjjslLKOQNIOPss5QGsv8vqPc7LO)sPbRYHrTyL6XatMqxgAZs1NbvJwjDAKwnOuvVMGmBeUnj2nv)wXWPWXfQuz5IEoPMUQUoiBNI8DHmEqjNNa16LII5ReTFjlJxQMKuKFugRGGz8npmJBcsqbyctyegJhgLKVGnqjPbdeIHJssNvqjzCsa7OK0GfmXWIs1KK6bkbOKC9FdDZryHHt)vODamkcRPkqe8thhKC)fwtvaclj3quIh21LBjPi)OmwbbZ4BEyg3eKGcWeMWimgVKuBGazSWqbjjxPIIOl3ssrudKKMRU4Ka2X6GDYWXAH5QB9FdDZryHHt)vODamkcRPkqe8thhKC)fwtvacxlmxDlGieCDckEbQtqWm(MVU4QobbZMdmcJ1IAH5QtLTYoCu3CQfMRU4Qo9Z5B3qPBnwznkqD6FmSBO0TgRSgfOo2fRJnHjdhTBO0TeOd)xRJtSUv2fjqX62cUUFfRJffhpulmxDXvDpNWXp8uf0(JvKI1fxQOoZ2Jw34PkO9hRifJPo9u3VYFDryDIJRs(6qybqTMAcjeCDBO0RB86(K1R1r71fH1joUk5RlI9VUFcsscQ(1s1KKGX1yAcLQjJnEPAssg80XLKk0mN0svy4OKeDEtGIsvLVmwbjvtsIoVjqrPQssqsFmPSKCd17bobSJwWkNWXG(zGq11whmLKm4PJljbRCchfTqgYxgR5LQjjrN3eOOuvjjiPpMuwsAwDj2tuVYBcSULlRd2Q7PaHOo86IPUg1TH69aNa2rlyLt4yq)mqO6ARBd17bobSJwWkNWXGcdlR(zGq11OUnuVhsihTt3AmrygeNiVUg1TH69aNa2rRXeHzqCICjjdE64ssh)vmTpQyG6x(YyHbs1KKOZBcuuQQKeK0htklj3q9EGta7OfSYjCmOFgiuDn1wNGQRrDMvhygcXjYdCcyhTgteMHevyQRRtf1fpmRB5Y6yWtnHw0rfkQRRP26euDXijzWthxsYjGD0o5w(YyHrPAss05nbkkvvscs6JjLLKBOEpKqeOD62FnruhGmQRrDBOEpWjGD0cw5eog0pdeQovuN5LKm4PJlj5eWoA3eS(LVmwyOunjj68MafLQkjzWthxs(uru)tQybJicljjiPpMuwsUH69qc5OD6wJjcZG4e511OoyRUnuVh4eWoAnMimdjYGVUg1bMHqCI8aNa2rRXeHzirfM666urDccMssNvqj5tfr9pPIfmIiSKVm24Munjj68MafLQkjzWthxsAmaHWxtBgu0cgfdONF64wr0efGssqsFmPSKCd17HeYr70TgteMbXjYRRrDWwDBOEpWjGD0AmrygsKbFDnQdmdH4e5bobSJwJjcZqIkm111PI6eemLKyVJG36SckjbcgqmFoofy3eS(LVm2MLunjj68MafLQkjbj9XKYsYnuVh4eWoAbRCchd6NbcvxBDBOEpWjGD0cw5eoguyyz1pdeQUg1zwDDiccBIGvoHJ2NQG11uBDiSqa0J2NQG1TCzDDiccBIGvoHJ2NQG11uBDGzieNipWjGD0AmrygsuHPUUULlRZS62JwxxJ6EQcA)XksX6AQToWmeItKh4eWoAnMimdjQWuxxxm1fJKKbpDCjzc5OD6wJjct5lJT5LQjjrN3eOOuvjjdE64ssobSJwfQwtjqTKeSYuxsgVKeK0htkljvyNdgGVUMARR5HX6Au3gQ3dacKtaRFQdpKid(6AuhdEQj0IoQqrDDnvN5LVm24HPunjj68MafLQkjbj9XKYssZQZS62q9EGta7OfSYjCmOFgiuDT1TH69aNa2rlyLt4yqHHLv)mqO6IPUg1zwDMvNc7CWa811uBDM4KYBcmagxJPj0QWoxxm1TCzDMv3ZeO)HeYr70TgteMb05nbkwxJ6aZqiorEGta7O1yIWmKOctDDDQOoWmeItKhsihTt3Amryg6qee2ebRCchTpvbRRrDkSZbdWxxtT1zItkVjWayCnMMqRc7CDQxNGGX6IPUyQB5Y6mRUNjq)dCcyhTtUdOZBcuSUg1bMHqCI8aNa2r7K7qIkm1111uBDWbI11OoWmeItKh4eWoAnMimdjQWuxxNkQlEywxm1ftDlxwNc7CWa811uBDMvNjoP8MadGX1yAcTkSZ1fx1fpmRlgjjdE64ssobSJ2nNjdhLVm24JxQMKeDEtGIsvLKGK(yszjPc7CWa811uBDnpmkjzWthxsQHmW0htS8LXgVGKQjjrN3eOOuvjjiPpMuwsYGNAcTOJkuuxNkARZ811OoZQtHDoya(6urBDM4KYBcmagxJPj0QWox3YL1TH69aNa2rlyLt4yq)mqO6ARZ81fJKKbpDCjjNa2rlcldIrthx(YyJ38s1KKm4PJlj5eWoA3eS(LKOZBcuuQQ8LXgpmqQMKKbpDCjjNa2r7MZKHJss05nbkkvv(YxskIDgI4LQjJnEPAssg80XLKGbYFm1gibHKeDEtGIsvLVmwbjvtsYGNoUKuBGee6hzcjj68MafLQkFzSMxQMKKbpDCjzIkJj0cGsnkjrN3eOOuv5lJfgivtsIoVjqrPQssg80XLKaMGWYGNoULGQFjjbv)wNvqjjQ1OdqT8LXcJs1KKOZBcuuQQKeK0htklj3qPBnwznw3YL1zwD7rRRRrDpvbT)yfPyDnvNjoP8MadSjmz4ODdLULaD4)ADXijzWthxscyccldE64wcQ(LKeu9BDwbLKBO0LVmwyOunjj68MafLQkjbj9XKYssZQdmdH4e5bobSJwJjcZqIkm1111whmRRrDGzieNipGMga)0XdjQWuxxxtT1XMWKHJ2nu6wc0H)R11OoZQBd17bobSJwWkNWXG(zGq11w3gQ3dCcyhTGvoHJbfgww9ZaHQB5Y6mRUNjq)dGvoHJIwiJa68MafRRrDGzieNipaw5eokAHmcjQWuxxxBDWSUg1TH69aNa2rlyLt4yq)mqO6AQTU4RlM6IPUyKKm4PJljbmbHLbpDClbv)sscQ(ToRGsYnu6YxgBCtQMKeDEtGIsvLKGK(yszjjSv3gkDRXkRrjjdE64ssatqyzWth3sq1VKKGQFRZkOKemUgttO8LX2SKQjjrN3eOOuvjjdE64ssatqyzWth3sq1VKKGQFRZkOKuzmHkO)Yx(ssJebJYMFPAYyJxQMKKbpDCjjNa2rl1FKGabVKeDEtGIsvLVmwbjvtsYGNoUKudPOmULta7OTZkuckNss05nbkkvv(YynVunjj68MafLQkjhdjPgFjjdE64sstCs5nbkjnXeqOKegcZ6uVobbZ6A21XndM0hdyChe1yOAmGoVjqrjPjoToRGssW4AmnHwf2z5lJfgivtsYGNoUKuHM5KwQcdhLKOZBcuuQQ8LXcJs1KKm4PJljnMNoUKeDEtGIsvLVmwyOunjjdE64ssobSJ2nbRFjj68MafLQkF5lj3qPlvtgB8s1KKOZBcuuQQKeK0htklj3q9EGta7OfSYjCmOFgiuDn1wx8ssg80XLKGvoHJIwid5lJvqs1KKm4PJljvOzoPLQWWrjj68MafLQkFzSMxQMKeDEtGIsvLKGK(yszjPz1Lypr9kVjW6wUSoyRUNceI6WRlM6Au3gQ3dCcyhTGvoHJb9ZaHQRTUnuVh4eWoAbRCchdkmSS6NbcvxJ62q9EiHC0oDRXeHzqCI86Au3gQ3dCcyhTgteMbXjYLKm4PJljD8xX0(OIbQF5lJfgivtsIoVjqrPQssqsFmPSKCd17HeIaTt3(RjI6aKrDnQ7zc0)WyctJjctumGoVjqX6AuhdEQj0IoQqrDDnvN5LKm4PJlj5eWoA3eS(LVmwyuQMKeDEtGIsvLKGK(yszj5gQ3dCcyhTgteMbXjYLKm4PJljjOWxFTf2hseUc6V8LXcdLQjjrN3eOOuvjPZkOKKBg9kNS22h)Tt3AmrykjzWthxsYnJELtwB7J)2PBnMimLVm24Munjj68MafLQkjbj9XKYssyRUnuVh4eWoAnMimdqg11OoZQtHDoya(6urBDWimRB5Y6aZqiorEGta7O1yIWmKOctDDDT1bZ6IPUg1zwDBOEpWjGD0cw5eog0pdeQU262q9EGta7OfSYjCmOWWYQFgiuDXijzWthxsMqoANU1yIWu(YyBws1KKm4PJlj3yQXuiQdxsIoVjqrPQYxgBZlvtsYGNoUKKta7O1yIWusIoVjqrPQYxgB8WuQMKeDEtGIsvLKGK(yszj5gQ3dCcyhTgteMbiJ6wUSoZQBpADDnQ7PkO9hRifRRP6aZqiorEGta7O1yIWmKOctDDDXijzWthxscPrl9rfT8LXgF8s1KKOZBcuuQQKKbpDCjPXaecFnTzqrlyumGE(PJBfrtuakjbj9XKYssZQBd17bobSJwJjcZaKrDlxwNz1ThTUUg19uf0(JvKI11uDGzieNipWjGD0AmrygsuHPUUUyKKoRGssJbie(AAZGIwWOya98th3kIMOau(YyJxqs1KKm4PJlj3eZiA7qPGLKOZBcuuQQ8LXgV5LQjjzWthxs2PjUjMrusIoVjqrPQYxgB8WaPAssg80XLKSdq9NmHfWeess05nbkkvv(YyJhgLQjjrN3eOOuvjjiPpMuwsAwDptG(hsihTt3AmrygqN3eOyDnQBd17HeYr70TgteMHevyQRRRP262q9EWirn6a0oDRc1fdkmSS6NbcvxZUog80XdCcyhTBcw)bewia6r7tvW6IPULlRBd17bobSJwJjcZqIkm1111uBDBOEpyKOgDaANUvH6Ibfgww9ZaHQRzxhdE64bobSJ2nbR)aclea9O9PkOKKbpDCjPrIA0bOD6wfQlkFzSXddLQjjrN3eOOuvjjiPpMuwsUH69aNa2rRXeHzaYOUg1zwDBOEpSXuJPquhEaYOULlRBd17HnXmI2ouk4aKrDlxwhSvNz1LmadFoee1TCzDjdWWKG6IPUyKKm4PJljnMNoU8LXgFCtQMKeDEtGIsvLKGK(yszj5gQ3dCcyhTGvoHJb9ZaHQRToyw3YL1zwDm4PMql6Ocf111uDMVULlRZS6yWtnHw0rfkQRRP6euDnQ7zc0)qI6XzhGb05nbkwxm1fJKKbpDCjjNa2r7KB5lJn(MLunjj68MafLQkjbj9XKYssg8utOfDuHI66urBDMVUg1zwDBOEpWjGD0cw5eog0pdeQU262q9EGta7OfSYjCmOWWYQFgiuDXijzWthxsYjGD0U5mz4O8LXgFZlvtsIoVjqrPQssqsFmPSKKbp1eArhvOOUov0wN5LKm4PJlj5eWoAryzqmA64YxgRGGPunjj68MafLQkjzWthxsYjGD0Qq1AkbQLKGvM6sY4LKGK(yszj5gQ3dacKtaRFQdpKid(6AuhdEQj0IoQqrDDnvN5RRrDMv3ZeO)bwXGG2Pa(PJhqN3eOyDlxwNz1bB19mb6FymHPXeHjkgqN3eOyDnQJBgmPpg4eWoAnGuuqcQdpKSluDQOTobvxm1TCzDBOEpWjGD0AmrygeNiVUyKVmwbfVunjj68MafLQkjbj9XKYssg8utOfDuHI66AQoZljzWthxsYjGD0Ujy9lFzScsqs1KKu)XmHmElTljvyNdgGxfTnlyuss9hZeY4TuffuKYpkjJxsYGNoUKenna(PJljrN3eOOuv5lJvqMxQMKKbpDCjjNa2r7MZKHJss05nbkkvv(YxsIAn6aulvtgB8s1KKOZBcuuQQKeK0htklj3qPBnwznwxJ62q9EGta7O1yIWmiorEDnQBd17HeYr70TgteMbXjYRRrDBOEpWjGD0cw5eog0pdeQU262q9EGta7OfSYjCmOWWYQFgiuDlxw3tvq7pwrkwxt1bMHqCI8aNa2rRXeHzirfM6AjjdE64sYnXmI2PB)v0IoQiy5lJvqs1KKOZBcuuQQKKbpDCjjyCa6FYpkA7eSckjbj9XKYsYnuVhsihTt3AmrygeNiVUg1TH69aNa2rRXeHzqCI86AuNz1bB1THs3ASYASULlR7PkO9hRifRRP6aZqiorEGta7O1yIWmKOctDDDXuxJ6uyNdpvbT)yvyyvNkARdHfcGE0(ufussqD0ceLKWq5lJ18s1KKOZBcuuQQKeK0htklj3q9EiHC0oDRXeHzqCI86Au3gQ3dCcyhTgteMbXjYLKm4PJlj7dasJIwUzWK(ODJSI8LXcdKQjjrN3eOOuvjjiPpMuwsUH69qc5OD6wJjcZG4e511OUnuVh4eWoAnMimdItKljzWthxschItrk72PB5MbZ5xLVmwyuQMKeDEtGIsvLKGK(yszj5gQ3djKJ2PBnMimdItKxxJ62q9EGta7O1yIWmiorUKKbpDCjPbus7cM6WTBcw)YxglmuQMKeDEtGIsvLKGK(yszj5gQ3djKJ2PBnMimdItKxxJ62q9EGta7O1yIWmiorUKKbpDCjzsnmiql1TAdgGYxgBCtQMKeDEtGIsvLKGK(yszj5gQ3djKJ2PBnMimdItKxxJ62q9EGta7O1yIWmiorUKKbpDCj5VIwiFpqUOTpjaLVm2MLunjj68MafLQkjbj9XKYssyRUnu6wJvwJ11OUnuVh4eWoAnMimdItKxxJ6aZqiorEGta7O1yIWmKOctDDDnQBd17bobSJwWkNWXG(zGq11w3gQ3dCcyhTGvoHJbfgww9ZaHQRrDMvhSv3ZeO)HeYr70TgteMb05nbkw3YL1XGNoEiHC0oDRXeHzaSYjCuxxm1TCzDpvbT)yfPyDnvhygcXjYdCcyhTgteMHevyQRLKm4PJljvqLjfSD6wciav0kMiROLVm2MxQMKeDEtGIsvLKGK(yszj5gkDRXkRX6Au3gQ3dCcyhTgteMbXjYRRrDBOEpKqoANU1yIWmiorEDnQBd17bobSJwWkNWXG(zGq11w3gQ3dCcyhTGvoHJbfgww9ZaHQB5Y6EQcA)XksX6AQoWmeItKh4eWoAnMimdjQWuxljzWthxsgnjHOjK62e1JZoaLV8LKkJjub9xQMm24LQjjrN3eOOuvjjiPpMuwsQmMqf0)Giv)SdW6urBDXdtjjdE64sYnb1fs(YyfKunjj68MafLQkjbj9XKYssLXeQG(heP6NDawNkARlEykjzWthxsUjOUqYxgR5LQjjzWthxsAKOgDaANUvH6Iss05nbkkvv(YyHbs1KKm4PJlj5eWoAvOAnLa1ss05nbkkvv(YyHrPAssg80XLKCcyhTtULKOZBcuuQQ8LXcdLQjjzWthxsQHmW0htSKeDEtGIsvLV8LVK0eMA64YyfemJV5HzCdMnFiEZBEjzeNo1HRLKWUkgt(OyDWW6yWthVocQ(1HAHKKH(1jLKKufic(PJRYsU)ssJC6ucusAU6ItcyhRd2jdhRfMRU1)n0nhHfgo9xH2bWOiSMQarWpDCqY9xynvbiCTWC1TaIqW1jO4fOobbZ4B(6IR6eemBoWimwlQfMRov2k7WrDZPwyU6IR60pNVDdLU1yL1Oa1P)XWUHs3ASYAuG6yxSo2eMmC0UHs3sGo8FTooX6wzxKafRBl46(vSowuC8qTWC1fx19Cch)Wtvq7pwrkwxCPI6mBpADJNQG2FSIumM60tD)k)1fH1joUk5RdHfa1AQjKqW1THsVUXR7twVwhTxxewN44QKVUi2)6(julQfMRUMlSqa0JI1TX(KyDGrzZFDBeo11H6IdaGgVUoF84ALtLoerDm4PJRRBCcbhQfMRog80X1bJebJYM)2obRfQwyU6yWthxhmsemkB(vVv4(mI1cZvhdE646GrIGrzZV6TcZqWvq)5NoETGbpDCDWirWOS5x9wH5eWoAP(Jeei4Rfm4PJRdgjcgLn)Q3kmNa2rBNvOeuoRfMRoW4AmnHwf256O66(vSof256mWeG(ZWX6IW6Iy)R7N6Gp1jorED)uNiusD41bgxJPjmuhS7xNJOOUUFQJaztyDOpqWxRlNrPUFQlAs9xhG1yDAa6CsN60gSsDXr16gNqW1jcLuhEDXrLgQfm4PJRdgjcgLn)Q3kSjoP8MafWzfSfmUgttOvHDwGXOvJVaMyciSfgct1femB2CZGj9Xag3brngQgdOZBcuSwyU6yWthxhmsemkB(vVvyTZg615T6NFDTGbpDCDWirWOS5x9wHvOzoPLQWWXAbdE646GrIGrzZV6TcBmpD8AbdE646GrIGrzZV6TcZjGD0Ujy9xlQfMRUMlSqa0JI1HMWuW19ufSUFfRJb)K1r11XMykbVjWqTGbpDCDlyG8htTbsqulyWthxRERWAdKGq)itulyWthxRERWjQmMqlak1yTGbpDCT6TcdyccldE64wcQ(fWzfSf1A0bOUwyU6G9AQ7N6ufk96uPRSgRlAf96yIezrbx3gkDQdxG6MSUOv0RBpADDrucI6ePyD6z8qTGbpDCT6TcdyccldE64wcQ(fWzfSDdLUa0E7gkDRXkRXLlnBpADJNQG2FSIuSjtCs5nbgytyYWr7gkDlb6W)1yQfMRoYNZVovHsVov6kRX6IwrVU4Ka2X6uPteM1r11Lilk46yxSUMRPbWpD86IOee1TX6sKffCDMnEDSjmz4ym1TX(KyD)kw3gk96mwznwhvx3ycZqDXHqp1PWcH1PHsSUiSo4ZxhmOU4Ka2X6uzRCch1cu3K1byVo44xhmOU4Ka2X6uzRCch11fr)16uzRCchfRd2JrOwWGNoUw9wHbmbHLbpDClbv)c4Sc2UHsxaAV1mWmeItKh4eWoAnMimdjQWux3cZgGzieNipGMga)0XdjQWux3ulBctgoA3qPBjqh(V2WSnuVh4eWoAbRCchd6Nbc1UH69aNa2rlyLt4yqHHLv)mqOLln7zc0)ayLt4OOfYiGoVjqXgGzieNipaw5eokAHmcjQWux3cZgBOEpWjGD0cw5eog0pdeQP24JjMyQfm4PJRvVvyatqyzWth3sq1VaoRGTGX1yAcfG2BHTnu6wJvwJ1cg80X1Q3kmGjiSm4PJBjO6xaNvWwLXeQG(xlQfMRoyxhKOc6FDduw3gk96mwznwhyG8hZqDWowrhnHzDryDO)yw3VI1DBO0V6yWthxxxe9xhOVUnsD41r96462qPxNXkRrbQJ(1PGSRR7x5VUiSooX649a919tD6NZVUXXqTWC1XGNoUoSHsV1eNuEtGc4Sc2(ZZe2nu6AbgJwwuuatmbe2gVa0ElSTHs3ASYASwyU6yWthxh2qPRERW6NZ3UHs3ASYAuaAVf22qPBnwznwlmxDnxxSUFfRBdLEDgRSgRlAf96IW6G9H0FDOPbWpkgQfMRog80X1Hnu6Q3kS(hd7gkDRXkRrbO92nu6wJvwJnms0KfoqmeFanna(PJ3WS9O1nEQcA)XksXyuHjoP8MadSjmz4ODdLULaD4)AJnu6wJvwJwrOKF64QaM1cZvNkNOwx3VYEDXxh11pYI1n96W4oiMqx3p1btbQBJagsJ1n96msmUaS(RlojGDSovjy9xlyWthxh2qPRERWGvoHJIwidbO92nuVh4eWoAbRCchd6Nbc1uB81cg80X1Hnu6Q3kScnZjTufgowlyWthxh2qPRERWo(RyAFuXa1Va0ERzj2tuVYBcC5sy7PaHOo8yASH69aNa2rlyLt4yq)mqO2nuVh4eWoAbRCchdkmSS6Nbc1yd17HeYr70TgteMbXjYBSH69aNa2rRXeHzqCI8AH5Qd2Xk61LqUtD41f3ZeMgteMOOa1XUyDryDWNVoUovEicSUPxNARjI66mYbuNzXrLBCQlcRd(81nqzDWGFTU4Ka2X6uzRCchRZeLRtLTYjCuSoypgXiqDqASo6x3g7tI1bPPo86u5hvQ6XrLkqDBeWqASUFfRtHDUUefHapD86O66MFfZiQgRJGt4iHGRlI1pkwNM6aSUFfRloQwxeRRRNiwh7coIfCOwWGNoUoSHsx9wH5eWoA3eS(fG2B3q9EiHiq70T)AIOoaz04zc0)WyctJjctumGoVjqXgm4PMql6Ocf1nz(AbdE646WgkD1BfMGcF91wyFir4kO)cq7TBOEpWjGD0AmrygeNiVwWGNoUoSHsx9wHH0OL(OIaoRGTCZOx5K12(4VD6wJjcZAbdE646WgkD1BfoHC0oDRXeHPa0ElSTH69aNa2rRXeHzaYOHzkSZbdWRIwyeMlxcMHqCI8aNa2rRXeHzirfM66wygtdZ2q9EGta7OfSYjCmOFgiu7gQ3dCcyhTGvoHJbfgww9ZaHIPwWGNoUoSHsx9wH3yQXuiQdVwWGNoUoSHsx9wH5eWoAnMimRfm4PJRdBO0vVvyinAPpQOfG2B3q9EGta7O1yIWmazSCPz7rRB8uf0(JvKInbMHqCI8aNa2rRXeHzirfM66yQfm4PJRdBO0vVvyinAPpQiGZkyRXaecFnTzqrlyumGE(PJBfrtuakaT3A2gQ3dCcyhTgteMbiJLlnBpADJNQG2FSIuSjWmeItKh4eWoAnMimdjQWuxhtTGbpDCDydLU6TcVjMr02HsbxlyWthxh2qPRERWDAIBIzeRfm4PJRdBO0vVvy2bO(tMWcycIAbdE646WgkD1Bf2irn6a0oDRc1ffG2Bn7zc0)qc5OD6wJjcZa68MafBSH69qc5OD6wJjcZqIkm11n1UH69GrIA0bOD6wfQlguyyz1pdeQzZGNoEGta7ODtW6pGWcbqpAFQcgZYLBOEpWjGD0AmrygsuHPUUP2nuVhmsuJoaTt3QqDXGcdlR(zGqnBg80XdCcyhTBcw)bewia6r7tvWAbdE646WgkD1Bf2yE64cq7TBOEpWjGD0AmrygGmAy2gQ3dBm1yke1HhGmwUCd17HnXmI2ouk4aKXYLWMzjdWWNdbXYLjdWWKGyIPwWGNoUoSHsx9wH5eWoANClaT3UH69aNa2rlyLt4yq)mqOwyUCPzm4PMql6Ocf1nz(LlnJbp1eArhvOOUjb14zc0)qI6XzhGb05nbkgtm1cg80X1Hnu6Q3kmNa2r7MZKHJcq7Tm4PMql6Ocf1QO18nmBd17bobSJwWkNWXG(zGqTBOEpWjGD0cw5eoguyyz1pdekMAbdE646WgkD1BfMta7OfHLbXOPJlaT3YGNAcTOJkuuRIwZxlmxDWUW9jX6ItcyhRd2jvRPeOUorOK6WRlojGDSov6eHPa1XAQiwxphL60JcwNjmfCDAdeq7uqDiSaOXthxlqDeuHW685RBLnrD41f3ZeMgteMOyDptG(JI11OUeYDQdVoZdR6ItcyhRtLcPOGeuhEOwWGNoUoSHsx9wH5eWoAvOAnLa1cq7TBOEpaiqobS(Po8qIm4BWGNAcTOJkuu3K5By2ZeO)bwXGG2Pa(PJhqN3eO4YLMbBptG(hgtyAmryIIb05nbk2GBgmPpg4eWoAnGuuqcQdpKSlKkAfumlxUH69aNa2rRXeHzqCI8yeaSYuVn(AbdE646WgkD1BfMta7ODtW6xaAVLbp1eArhvOOUjZxlmxDXor19R8xxeQssSoXXX62qPtD4cuxewhG96Gme5hR7xX6ytyYWr7gkDlb6W)16IO)AD)kwhb6W)16MED)kvx3gk9qTWC1XGNoUoSHsx9wHnXjL3eOaoRGTSjmz4ODdLULaD4)QaJrRgFbmXeqyRzM4KYBcmWMWKHJ2nu6wc0H)RnBtCs5nbg(5zc7gkDDCzItkVjWaBctgoA3qPBjqh(VQUzBO0TgRSgTIqj)0XJjgyVnXjL3ey4NNjSBO011cg80X1Hnu6Q3kmAAa8thxaQ)yMqgVL2BvyNdgGxfTnlyuaQ)yMqgVLQOGIu(X24RfMRU4(tw3VI1LCI1naaRPJxx0kMyDryDWN6MrPUn2NeRdnna(PJxhvx3MbcvhKrOoZG9OHyccbx3gbmKgRlcRdo(1zctbx3MfRlD41PN6(vSUnu61r11bG(6mHPGRtVo5htTGbpDCDydLU6TcZjGD0U5mz4yTOwWGNoUoagxJPjSvHM5KwQcdhRfm4PJRdGX1yAcvVvyWkNWrrlKHa0E7gQ3dCcyhTGvoHJb9ZaHAHzTGbpDCDamUgttO6Tc74VIP9rfdu)cq7TMLypr9kVjWLlHTNceI6WJPXgQ3dCcyhTGvoHJb9ZaHA3q9EGta7OfSYjCmOWWYQFgiuJnuVhsihTt3AmrygeNiVXgQ3dCcyhTgteMbXjYRfm4PJRdGX1yAcvVvyobSJ2j3cq7TBOEpWjGD0cw5eog0pdeQPwb1WmWmeItKh4eWoAnMimdjQWuxRI4H5YLm4PMql6Ocf1n1kOyQfMRU4Ka2X6uLG1FD6vA)11bzuh1RZiPtsFbxx0k61LqUtD41LqeyDtVUFnruhQfm4PJRdGX1yAcvVvyobSJ2nbRFbO92nuVhsic0oD7VMiQdqgn2q9EGta7OfSYjCmOFgiKkmFTGbpDCDamUgttO6TcdPrl9rfbCwbBFQiQ)jvSGreHLa0E7gQ3djKJ2PBnMimdItK3a22q9EGta7O1yIWmKid(gGzieNipWjGD0AmrygsuHPUwfccM1cg80X1bW4AmnHQ3kmKgT0hvea7De8wNvWwGGbeZNJtb2nbRFbO92nuVhsihTt3AmrygeNiVbSTH69aNa2rRXeHzirg8naZqiorEGta7O1yIWmKOctDTkeemRfm4PJRdGX1yAcvVv4eYr70TgteMcq7TBOEpWjGD0cw5eog0pdeQDd17bobSJwWkNWXGcdlR(zGqnmRdrqyteSYjC0(ufSPwewia6r7tvWLl7qee2ebRCchTpvbBQfmdH4e5bobSJwJjcZqIkm11lxA2E06gpvbT)yfPytTGzieNipWjGD0AmrygsuHPUoMyQfm4PJRdGX1yAcvVvyobSJwfQwtjqTa0ERc7CWa8n128WyJnuVhaeiNaw)uhEirg8nyWtnHw0rfkQBY8cawzQ3gFTWC1PYbusD41bgxJPjuG6IW60pLGOoyFi9xxe7FD)uhy8N6qyD(81jMJHb1HxhyLt4OUowxhX4WRJ11zmAnDtGbYPoHq0OovYgkDQdxLuhRRJyC41X66mgTMUjW6mJfIRdmUgttOvHDUUFnr966qigtDSlw3VIED6i2OUFQJRdgaR6IJQXLkIZMZSoW4AmnH1LZZpD8qDWU96IW6eN685RBLnH1bdQloQmbQlcRdWEDIuJ60eu4RpHGRJyIWSUFQdo(1X1bd(16IJkluhSdSoMqp1PH0pt964VoUUvk8vmRtHDUodmbO)mCSUOv0RlcRZGG96(PoinwhxNkpKJ1n96uPteM1jcLuhEDGX1yAcRZyL1Oa1PN6IW6aSx3gk96eHsQdVUFfRtLhYX6MEDQ0jcZqTGbpDCDamUgttO6TcZjGD0U5mz4Oa0ERzMTH69aNa2rlyLt4yq)mqO2nuVh4eWoAbRCchdkmSS6NbcftdZmtHDoya(MAnXjL3eyamUgttOvHDoMLln7zc0)qc5OD6wJjcZa68MafBaMHqCI8aNa2rRXeHzirfM6AvaMHqCI8qc5OD6wJjcZqhIGWMiyLt4O9Pkydf25Gb4BQ1eNuEtGbW4AmnHwf2z1femgtmlxA2ZeO)bobSJ2j3b05nbk2amdH4e5bobSJ2j3HevyQRBQfoqSbygcXjYdCcyhTgteMHevyQRvr8WmMywUuHDoya(MAnZeNuEtGbW4AmnHwf254kEygtTWC1rczGPpM46O662CIecUUOj)16aS(PoCbQlALcwRJQRlAvW1r)6O660tDDoRtCICbQBCcbxhSpK(RJ3JjSU4OAOUAbdE646ayCnMMq1BfwdzGPpMybO9wf25Gb4BQT5HXAH5QtLlIg1Ps2qPtD4QK6OED8G1PPpe)0X11b5pLOoW4AmnHwf256maFOU40FmR7x5VUXjeCDaw)1fNMBDr0FToZxxCsa7yDGvoHJAbQttDawh9vj66ycLr)1HXDqmrDkSZ1bg9x3p1X1z(60pdeQU4OADSl4iwWH6IZx3VYFDgd1)6IZ0CRlNNF641frjiQBJ1fhvRdwMpUurCAUXLkIZMZSwWGNoUoagxJPju9wH5eWoAryzqmA64cq7Tm4PMql6Ocf1QO18nmtHDoyaEv0AItkVjWayCnMMqRc78YLBOEpWjGD0cw5eog0pdeQ18XulyWthxhaJRX0eQERWCcyhTBcw)1cg80X1bW4AmnHQ3kmNa2r7MZKHJ1IAbdE646aQ1OdqD7Mygr70T)kArhveSa0E7gkDRXkRXgBOEpWjGD0AmrygeNiVXgQ3djKJ2PBnMimdItK3yd17bobSJwWkNWXG(zGqTBOEpWjGD0cw5eoguyyz1pdeA5YNQG2FSIuSjWmeItKh4eWoAnMimdjQWuxxlyWthxhqTgDaQvVvyW4a0)KFu02jyfuacQJwGylmuaAVDd17HeYr70TgteMbXjYBSH69aNa2rRXeHzqCI8gMbBBO0TgRSgxU8PkO9hRifBcmdH4e5bobSJwJjcZqIkm11X0qHDo8uf0(JvHHLkAryHaOhTpvbRfm4PJRdOwJoa1Q3kCFaqAu0YndM0hTBKveG2B3q9EiHC0oDRXeHzqCI8gBOEpWjGD0AmrygeNiVwWGNoUoGAn6auRERWWH4uKYUD6wUzWC(vbO92nuVhsihTt3AmrygeNiVXgQ3dCcyhTgteMbXjYRfm4PJRdOwJoa1Q3kSbus7cM6WTBcw)cq7TBOEpKqoANU1yIWmiorEJnuVh4eWoAnMimdItKxlyWthxhqTgDaQvVv4KAyqGwQB1gmafG2B3q9EiHC0oDRXeHzqCI8gBOEpWjGD0AmrygeNiVwWGNoUoGAn6auRERW)kAH89a5I2(KauaAVDd17HeYr70TgteMbXjYBSH69aNa2rRXeHzqCI8AbdE646aQ1OdqT6TcRGktky70TeqaQOvmrwrlaT3cBBO0TgRSgBSH69aNa2rRXeHzqCI8gGzieNipWjGD0AmrygsuHPUUXgQ3dCcyhTGvoHJb9ZaHA3q9EGta7OfSYjCmOWWYQFgiudZGTNjq)djKJ2PBnMimdOZBcuC5sg80XdjKJ2PBnMimdGvoHJ6ywU8PkO9hRifBcmdH4e5bobSJwJjcZqIkm111cg80X1buRrhGA1BfoAscrti1TjQhNDakaT3UHs3ASYASXgQ3dCcyhTgteMbXjYBSH69qc5OD6wJjcZG4e5n2q9EGta7OfSYjCmOFgiu7gQ3dCcyhTGvoHJbfgww9ZaHwU8PkO9hRifBcmdH4e5bobSJwJjcZqIkm111IAbdE646GYycvq)B1RuffmfG2BvgtOc6FqKQF2bOkAJhM1cg80X1bLXeQG(RERWBcQlKa0ERYycvq)dIu9ZoavrB8WSwWGNoUoOmMqf0F1Bf2irn6a0oDRc1fRfm4PJRdkJjub9x9wH5eWoAvOAnLa11cg80X1bLXeQG(RERWCcyhTtURfm4PJRdkJjub9x9wH1qgy6Jjw(Yxkba]] )


end
