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

        potion = "battle_potion_of_intellect",

        package = "Arcane",
    } )


    spec:RegisterPack( "Arcane", 20190709.1330, [[d00chbqieqpsiLlHGQuBsk8jcvyuKQCkHOvjKk9ksvnlcXTesQDj4xekddb6ysrwMqONrsPPjKKRHGY2qa6BeQuJtiOoNqG1jKQmpPOUNuAFeQ6GcjwijXdjujtuii4IcPQ2OqQO(icQsojcQ0kvcVuiiAMcbHUjcQODss1pfsfzOeQOLkeKEkIMkjPRIGQ4RiOc7LO)sPbRYHrTyP6XatMGldTzL6Zi0OvsNgPvJGQ61esZgu3Me7MQFRy4KYXfsfwUONtX0v11bz7KkFxOgpcY5jPy9iaMVs0(LSSjPQssb(rP6rKGnfbeuCtWii0eHfveKWuRK8vJgkj1yGOmrus6SckjJscyhLKASAGhwqQQK0mqjaLKR)RzIEIjgr6Vc1dGrrmdvbcMF64GK3VygQcqmjzhIc)eUUSljf4hLQhrc2ueqqXnbJGqteMAJGikULKgneivNagrj5kvqaDzxskGgGKmA1fLeWowhHtMiwlIwDR)RzIEIjgr6Vc1dGrrmdvbcMF64GK3VygQcqSAr0QBbeSAQlcePUisWMIG6I66AIWIEQLG1IAr0QtCTYor0e9QfrRUOUoZZ5B7qPB1wzdksDMF0SDO0TARSbfPo2fQJ1HjteTDO0TWOt8xRJtSUv2fGrH66QPUFfRJfegpulIwDrDDpNeXp8uf0(JvGI1f1IVo96JX04PkO9hRafJSoZu3VYFDXyDcJlo(6qcbqJHQdHvtDDO0RB86(KnR1r31fJ1jmU44RlM9VUFcssyQ5nsvLKGXnyQdLQkvVjPQssg80XLKk0mN0svyIOKeDUdJcsvKVu9ikvvsIo3HrbPkssqsFmPSKSdT3bobSJwWkNeXG5zGO11whbLKm4PJljbRCsefSqAYxQUALQkjrN7WOGufjjiPpMuwsQxDjUt0SYDySULlRJaR7ParPoX6ISUg11H27aNa2rlyLtIyW8mq06ARRdT3bobSJwWkNeXGctiR5zGO11OUo0EhsihTZ2QnXygeMyVUg11H27aNa2rR2eJzqyIDjjdE64ssh)vmTpQOHMx(s1JkPQss05omkivrscs6JjLLKDO9oWjGD0cw5KigmpdeTUMBRlI11Oo9QdmdSWe7bobSJwTjgZqIkm1n1j(6AIG1TCzDm4P6ql6Ocfn11CBDrSUiLKm4PJlj5eWoANSlFP6eMuvjj6ChgfKQijbj9XKYsYo0Ehsiy0oB7VMiAcqA11OUo0Eh4eWoAbRCsedMNbIwN4RtTssg80XLKCcyhTDy28YxQobuQQKeDUdJcsvKKoRGsYNkGMFsflyeqcjjzWthxs(ub08tQybJasijjiPpMuws2H27qc5OD2wTjgZGWe711OocSUo0Eh4eWoA1MymdjYGVUg1bMbwyI9aNa2rR2eJzirfM6M6eFDrKGYxQU4wQQKeDUdJcsvKKoRGssTbik(gkbafSGrrd65NoUva1rbOKKbpDCjP2aefFdLaGcwWOOb98th3kG6Oauscs6JjLLKDO9oKqoANTvBIXmimXEDnQJaRRdT3bobSJwTjgZqIm4RRrDGzGfMypWjGD0QnXygsuHPUPoXxxejO8LQhHLQkjrN7WOGufjjiPpMuws2H27aNa2rlyLtIyW8mq06ARRdT3bobSJwWkNeXGctiR5zGO11Oo9QBdbdBteSYjr0(ufSUMBRdjecGE0(ufSULlRBdbdBteSYjr0(ufSUMBRdmdSWe7bobSJwTjgZqIkm1n1TCzD6vxFmM6Au3tvq7pwbkwxZT1bMbwyI9aNa2rR2eJzirfM6M6ISUiLKm4PJljtihTZ2QnXykFP6rGuvjj6ChgfKQijbj9XKYssf25Gg4RR526IacRUg11H27aag5eWMN6edjYGVUg1XGNQdTOJku0uxZ1PwjjdE64ssobSJwfQXqHrJKeSYuxs2K8LQ3ebLQkjrN7WOGufjjiPpMuwsQxD6vxhAVdCcyhTGvojIbZZarRRTUo0Eh4eWoAbRCsedkmHSMNbIwxK11Oo9QtV6uyNdAGVUMBRthNuUdJbW4gm1Hwf256ISULlRtV6Egg9pKqoANTvBIXmGo3HrH6AuhygyHj2dCcyhTAtmMHevyQBQt81bMbwyI9qc5OD2wTjgZWgcg2MiyLtIO9PkyDnQtHDoOb(6AUToDCs5omgaJBWuhAvyNRt)6IiHvxK1fzDlxwNE19mm6FGta7ODYEaDUdJc11OoWmWctSh4eWoANShsuHPUPUMBRJiqOUg1bMbwyI9aNa2rR2eJzirfM6M6eFDnrW6ISUiRB5Y6uyNdAGVUMBRtV60XjL7WyamUbtDOvHDUUOUUMiyDrkjzWthxsYjGD025mzIO8LQ3utsvLKOZDyuqQIKeK0htkljvyNdAGVUMBRlcimjjdE64ssdKgM(OJLVu9MIOuvjj6ChgfKQijbj9XKYssg8uDOfDuHIM6eFBDQTUg1PxDkSZbnWxN4BRthNuUdJbW4gm1Hwf256wUSUo0Eh4eWoAbRCsedMNbIwxBDQTUiLKm4PJlj5eWoArcPbpg64YxQEtQvQQKKbpDCjjNa2rBhMnVKeDUdJcsvKVu9MIkPQssg80XLKCcyhTDotMikjrN7WOGuf5lFjPaUzi4xQQu9MKQkjzWthxscgi)X0OHWWss05omkivr(s1JOuvjjdE64ssJgcdBEKHLKOZDyuqQI8LQRwPQssg80XLKjQm6qlaknOKeDUdJcsvKVu9OsQQKeDUdJcsvKKm4PJljbmmSLbpDClm18ssyQ5ToRGss0yqhGg5lvNWKQkjrN7WOGufjjdE64ssaddBzWth3ctnVKeK0htklj7qPB1wzdw3YL1PxD9XyQRrDpvbT)yfOyDnxNooPChgdSomzIOTdLUfgDI)ADrkjHPM36Sckj7qPlFP6eqPQss05omkivrsYGNoUKeWWWwg80XTWuZljbj9XKYss9QdmdSWe7bobSJwTjgZqIkm1n11whbRRrDGzGfMypG6ga)0XdjQWu3uxZT1X6WKjI2ou6wy0j(R11Oo9QRdT3bobSJwWkNeXG5zGO11wxhAVdCcyhTGvojIbfMqwZZarRB5Y60RUNHr)dGvojIcwiTa6ChgfQRrDGzGfMypaw5KikyH0cjQWu3uxBDeSUg11H27aNa2rlyLtIyW8mq06AUTUMQlY6ISUiLKWuZBDwbLKDO0LVuDXTuvjj6ChgfKQijzWthxscyyyldE64wyQ5LKGK(yszjjbwxhkDR2kBqjjm18wNvqjjyCdM6q5lvpclvvsIo3HrbPkssg80XLKagg2YGNoUfMAEjjm18wNvqjPYOdvq)LV8LKAjcgLo)svLQ3Kuvjj6ChgfKQiFP6ruQQKeDUdJcsvKVuD1kvvsIo3HrbPkYxQEujvvsYGNoUKKta7OL6pcdJGxsIo3HrbPkYxQoHjvvsYGNoUK0aPOmULta7ODZkuykNss05omkivr(s1jGsvLKOZDyuqQIKC0KKg8LKm4PJlj1XjL7WOKuhddHsscibRt)6IibRl6whtaWK(yaJoGOAd1Gb05omkij1XP1zfuscg3GPo0QWolFP6IBPQss05omkivr(s1JWsvLKm4PJljvOzoPLQWerjj6ChgfKQiFP6rGuvjjdE64ssT5PJljrN7WOGuf5lvVjckvvsYGNoUKKta7OTdZMxsIo3HrbPkYx(sYou6svLQ3Kuvjj6ChgfKQijbj9XKYsYo0Eh4eWoAbRCsedMNbIwxZT11KKKbpDCjjyLtIOGfst(s1JOuvjjdE64ssfAMtAPkmrusIo3HrbPkYxQUALQkjrN7WOGufjjiPpMuwsQxDjUt0SYDySULlRJaR7ParPoX6ISUg11H27aNa2rlyLtIyW8mq06ARRdT3bobSJwWkNeXGctiR5zGO11OUo0EhsihTZ2QnXygeMyVUg11H27aNa2rR2eJzqyIDjjdE64ssh)vmTpQOHMx(s1JkPQss05omkivrscs6JjLLKDO9oKqWOD22Fnr0eG0QRrDpdJ(hgDyQnXyIcb05omkuxJ6yWt1Hw0rfkAQR56uRKKbpDCjjNa2rBhMnV8LQtysvLKOZDyuqQIKeK0htklj7q7DGta7OvBIXmimXUKKbpDCjjmL46BSe(qcevq)LVuDcOuvjj6ChgfKQijbj9XKYsscSUo0Eh4eWoA1MymdqA11Oo9QtHDoOb(6eFBDegbRB5Y6aZalmXEGta7OvBIXmKOctDtDT1rW6ISUg1PxDDO9oWjGD0cw5KigmpdeTU266q7DGta7OfSYjrmOWeYAEgiADrkjzWthxsMqoANTvBIXu(s1f3svLKm4PJlj7yAWuuQtusIo3HrbPkYxQEewQQKKbpDCjjNa2rR2eJPKeDUdJcsvKVu9iqQQKeDUdJcsvKKGK(yszjzhAVdCcyhTAtmMbiT6wUSo9QRpgtDnQ7PkO9hRafRR56aZalmXEGta7OvBIXmKOctDtDrkjzWthxsczql9rfJ8LQ3ebLQkjrN7WOGufjPZkOKuBaIIVHsaqblyu0GE(PJBfqDuakjzWthxsQnarX3qjaOGfmkAqp)0XTcOokaLKGK(yszjPE11H27aNa2rR2eJzasRULlRtV66JXuxJ6EQcA)XkqX6AUoWmWctSh4eWoA1MymdjQWu3uxKYxQEtnjvvsYGNoUKSdpJGDdLQrsIo3HrbPkYxQEtruQQKKbpDCj5MMyhEgbjj6ChgfKQiFP6nPwPQssg80XLKSdqZNmSfWWWss05omkivr(s1BkQKQkjrN7WOGufjjiPpMuwsQxDpdJ(hsihTZ2QnXygqN7WOqDnQRdT3HeYr7STAtmMHevyQBQR5266q7Dqlrd6a0oBRc1fckmHSMNbIwx0Tog80XdCcyhTDy28bKqia6r7tvW6ISULlRRdT3bobSJwTjgZqIkm1n11CBDDO9oOLObDaANTvH6cbfMqwZZarRl6whdE64bobSJ2omB(asiea9O9PkOKKbpDCjPwIg0bOD2wfQliFP6nrysvLKOZDyuqQIKeK0htklj7q7DGta7OvBIXmaPvxJ60RUo0Eh6yAWuuQtmaPv3YL11H27qhEgb7gkvtasRULlRJaRtV6sgGHphy46wUSUKbyysqDrwxKssg80XLKAZthx(s1BIakvvsIo3HrbPkssqsFmPSKSdT3bobSJwWkNeXG5zGO11whbRB5Y60Rog8uDOfDuHIM6AUo1w3YL1PxDm4P6ql6Ocfn11CDrSUg19mm6FirZ4SdWa6ChgfQlY6IusYGNoUKKta7ODYU8LQ3K4wQQKeDUdJcsvKKGK(yszjjdEQo0IoQqrtDIVTo1wxJ60RUo0Eh4eWoAbRCsedMNbIwxBDDO9oWjGD0cw5KiguycznpdeTUiLKm4PJlj5eWoA7CMmru(s1BkclvvsIo3HrbPkssqsFmPSKKbpvhArhvOOPoX3wNALKm4PJlj5eWoArcPbpg64YxQEtrGuvjj6ChgfKQijbj9XKYsYo0EhaWiNa28uNyirg811Oog8uDOfDuHIM6AUo1wxJ60RUNHr)dSIgmDtb8thpGo3HrH6wUSo9QJaR7zy0)WOdtTjgtuiGo3HrH6AuhtaWK(yGta7OvdsrbHPoXqYUO1j(26IyDrw3YL11H27aNa2rR2eJzqyI96IusYGNoUKKta7OvHAmuy0ijbRm1LKnjFP6rKGsvLKOZDyuqQIKeK0htkljzWt1Hw0rfkAQR56uRKKbpDCjjNa2rBhMnV8LQhXMKQkjP(JzcP9w6wsQWoh0aV4BJWeMKK6pMjK2BPkkOaLFus2KKKbpDCjjQBa8thxsIo3HrbPkYxQEeJOuvjjdE64ssobSJ2oNjteLKOZDyuqQI8LVKeng0bOrQQu9MKQkjrN7WOGufjjiPpMuws2Hs3QTYgSUg11H27aNa2rR2eJzqyI96AuxhAVdjKJ2zB1MymdctSxxJ66q7DGta7OfSYjrmyEgiADT11H27aNa2rlyLtIyqHjK18mq06wUSUNQG2FScuSUMRdmdSWe7bobSJwTjgZqIkm1nssg80XLKD4zeSZ2(ROfDurnYxQEeLQkjrN7WOGufjjiPpMuws2H27qc5OD2wTjgZGWe711OUo0Eh4eWoA1MymdctSxxJ60RocSUou6wTv2G1TCzDpvbT)yfOyDnxhygyHj2dCcyhTAtmMHevyQBQlY6AuNc7C4PkO9hRctO6eFBDiHqa0J2NQGssg80XLKGXbO)j)OGDdZkOKeM6OfiijjGYxQUALQkjrN7WOGufjjiPpMuws2H27qc5OD2wTjgZGWe711OUo0Eh4eWoA1MymdctSljzWthxsUhaKbfSmbat6J2oYkYxQEujvvsIo3HrbPkssqsFmPSKSdT3HeYr7STAtmMbHj2RRrDDO9oWjGD0QnXygeMyxsYGNoUKKieNcu2TZ2YeamNFv(s1jmPQss05omkivrscs6JjLLKDO9oKqoANTvBIXmimXEDnQRdT3bobSJwTjgZGWe7ssg80XLKAqjDRgQt02HzZlFP6eqPQss05omkivrscs6JjLLKDO9oKqoANTvBIXmimXEDnQRdT3bobSJwTjgZGWe7ssg80XLKjvtdgTu3A0yakFP6IBPQss05omkivrscs6JjLLKDO9oKqoANTvBIXmimXEDnQRdT3bobSJwTjgZGWe7ssg80XLK)kAH8(a5c29Kau(s1JWsvLKOZDyuqQIKeK0htkljjW66qPB1wzdwxJ66q7DGta7OvBIXmimXEDnQdmdSWe7bobSJwTjgZqIkm1n11OUo0Eh4eWoAbRCsedMNbIwxBDDO9oWjGD0cw5KiguycznpdeTUg1PxDeyDpdJ(hsihTZ2QnXygqN7WOqDlxwhdE64HeYr7STAtmMbWkNertDrw3YL19uf0(JvGI11CDGzGfMypWjGD0QnXygsuHPUrsYGNoUKubvMun2zBHHaubRqISIr(s1JaPQss05omkivrscs6JjLLKDO0TARSbRRrDDO9oWjGD0QnXygeMyVUg11H27qc5OD2wTjgZGWe711OUo0Eh4eWoAbRCsedMNbIwxBDDO9oWjGD0cw5KiguycznpdeTULlR7PkO9hRafRR56aZalmXEGta7OvBIXmKOctDJKKbpDCjz8KWc6qQBt0mo7au(YxsQm6qf0FPQs1BsQQKeDUdJcsvKKGK(yszjPYOdvq)dcuZZoaRt8T11ebLKm4PJlj7Wuxu5lvpIsvLKOZDyuqQIKeK0htkljvgDOc6FqGAE2byDIVTUMiOKKbpDCjzhM6IkFP6QvQQKKbpDCjPwIg0bOD2wfQlijrN7WOGuf5lvpQKQkjzWthxsYjGD0QqngkmAKKOZDyuqQI8LQtysvLKm4PJlj5eWoANSljrN7WOGuf5lvNakvvsYGNoUK0aPHPp6yjj6ChgfKQiF5lFjPomn0XLQhrc2ueqWOQjXDiIQLWIajzmNo1jAKKeUkAt(OqDeW6yWthVoyQ5nHAHKKH(1jLKKufiy(PJlUsE)ssTC2uyusgT6IscyhRJWjteRfrRU1)1mrpXeJi9xH6bWOiMHQabZpDCqY7xmdvbiwTiA1Tacwn1fbIuxejytrqDrDDnryrp1sWArTiA1jUwzNiAIE1IOvxuxN558TDO0TARSbfPoZpA2ou6wTv2GIuh7c1X6WKjI2ou6wy0j(R1Xjw3k7cWOqDD1u3VI1XccJhQfrRUOUUNtI4hEQcA)XkqX6IAXxNE9XyA8uf0(JvGIrwNzQ7x5VUySoHXfhFDiHaOXq1HWQPUou61nEDFYM16O76IX6egxC81fZ(x3pHArTiA1f9jecGEuOUoUNeRdmkD(RRJePUjuxuaau7n15Jh1RCQSHGRJbpDCtDJdRMqTGbpDCtqlrWO05VDdZgrRfm4PJBcAjcgLo)63k2EgHAbdE64MGwIGrPZV(TIXqevq)5NoETGbpDCtqlrWO05x)wX4eWoAP(JWWi4Rfm4PJBcAjcgLo)63kgNa2r7MvOWuoRfrRoW4gm1Hwf256OM6(vSof2560WeG(ZeX6IX6Iz)R7N6io1jmXED)uNausDI1bg3GPomuhH7xNJOGPUFQdgzDyDOpqexRlNrPUFQlEsZxhGnyDga6CsN6mASsDrrL6ghwn1jaLuNyDrrCgQfm4PJBcAjcgLo)63kMooPChgfXzfSfmUbtDOvHDwKrR1GVi6yyiSLasq9JibJUmbat6Jbm6aIQnudgqN7WOqTGbpDCtqlrWO05x)wXmoRzwN3AE(n1cg80XnbTebJsNF9BftHM5KwQcteRfm4PJBcAjcgLo)63kM280XRfm4PJBcAjcgLo)63kgNa2rBhMnFTOweT6I(ecbqpkuhQdt1u3tvW6(vSog8twh1uhRJPWChgd1cg80XnTGbYFmnAimCTGbpDCJ(TIz0qyyZJmCTGbpDCJ(TILOYOdTaO0G1cg80Xn63kgGHHTm4PJBHPMxeNvWw0yqhGMAr0QJWRPUFQtfO0RtCUYgSU4v0RJHtKfutDDO0PorrQBY6IxrVU(ym1ftHHRtGI1zMXd1cg80Xn63kgGHHTm4PJBHPMxeNvW2ou6Iq3TDO0TARSbxUuV(ymnEQcA)XkqXM1XjL7WyG1HjteTDO0TWOt8xJSweT6iFo)6ubk96eNRSbRlEf96IscyhRtCoXywh1uxISGAQJDH6I(6ga)0XRlMcdxxhRlrwqn1P341X6WKjIrwxh3tI19RyDDO0RtBLnyDutDJomd1ffyZuNclkwNbkX6IX6ioFDrvDrjbSJ1jUw5KiAePUjRdWEDeXVUOQUOKa2X6exRCsen1ft)16exRCsefQJWJwOwWGNoUr)wXammSLbpDClm18I4Sc22Hsxe6UvpWmWctSh4eWoA1MymdjQWu30sWgGzGfMypG6ga)0XdjQWu30ClRdtMiA7qPBHrN4V2qVo0Eh4eWoAbRCsedMNbI22H27aNa2rlyLtIyqHjK18mq0Ll17zy0)ayLtIOGfslGo3HrHgGzGfMypaw5KikyH0cjQWu30sWgDO9oWjGD0cw5KigmpdeT52MImYiRfm4PJB0VvmaddBzWth3ctnVioRGTGXnyQdfHUBjWou6wTv2G1cg80Xn63kgGHHTm4PJBHPMxeNvWwLrhQG(xlQfrRocxhKOc6FDduwxhk960wzdwhyG8hZqDeowrh1HzDXyDO)yw3VI1DDO0V6yWth3uxm9xhOVUosDI1r96466qPxN2kBqrQJ(1PGSBQ7x5VUySooX64(a919tDMNZVUXXqTiA1XGNoUj0HsVvhNuUdJI4Sc2(ZZW2ou6grgTwwqqeDmme22Ki0Dlb2Hs3QTYgSweT6yWth3e6qPRFRyMNZ32Hs3QTYgue6ULa7qPB1wzdwlIwDrFxOUFfRRdLEDARSbRlEf96IX6i8HmFDOUbWpkeQfrRog80XnHou663kM5hnBhkDR2kBqrO72ou6wTv2Gn0suNLiqi0ua1na(PJ3qV(ymnEQcA)XkqXifVooPChgdSomzIOTdLUfgDI)AJou6wTv2GwbOKF64ING1IOvxeIOXu3VYEDnvh1npYc1n76WOdig2u3p1rqrQRJagYG1n760smQbS5RlkjGDSovGzZxlyWth3e6qPRFRyGvojIcwinrO72o0Eh4eWoAbRCsedMNbI2CBt1cg80XnHou663kMcnZjTufMiwlyWth3e6qPRFRyo(RyAFurdnVi0DREjUt0SYDyC5sc8ParPoXiB0H27aNa2rlyLtIyW8mq02o0Eh4eWoAbRCsedkmHSMNbI2OdT3HeYr7STAtmMbHj2B0H27aNa2rR2eJzqyI9Ar0QJWXk61LqUtDI1fDshMAtmMOGi1XUqDXyDeNVoUUiuiySUzxNQRjIM60YbuNErjczuQlgRJ481nqzDr1Vwxusa7yDIRvojI1PJY1jUw5KikuhHhTifPoidwh9RRJ7jX6GmuNyDrOJ4u)OiofPUocyidw3VI1PWoxxIcqGNoEDutDZVIzm1G1bZjrewn1fZMhfQZqDaw3VI1ffvQlMn1TteRJD1eZQjulyWth3e6qPRFRyCcyhTDy28Iq3TDO9oKqWOD22Fnr0eG0A8mm6Fy0HP2eJjkeqN7WOqdg8uDOfDuHIMMvBTGbpDCtOdLU(TIbtjU(glHpKarf0FrO72o0Eh4eWoA1MymdctSxlyWth3e6qPRFRyjKJ2zB1MymfHUBjWo0Eh4eWoA1MymdqAn0tHDoObEX3syeC5sWmWctSh4eWoA1MymdjQWu30sWiBOxhAVdCcyhTGvojIbZZarB7q7DGta7OfSYjrmOWeYAEgiAK1cg80XnHou663kwhtdMIsDI1cg80XnHou663kgNa2rR2eJzTGbpDCtOdLU(TIbzql9rfJi0DBhAVdCcyhTAtmMbiTLl1RpgtJNQG2FScuSzWmWctSh4eWoA1MymdjQWu3ezTGbpDCtOdLU(TIbzql9rfrCwbB1gGO4BOeauWcgfnONF64wbuhfGIq3T61H27aNa2rR2eJzasB5s96JX04PkO9hRafBgmdSWe7bobSJwTjgZqIkm1nrwlyWth3e6qPRFRyD4zeSBOun1cg80XnHou663k2MMyhEgHAbdE64MqhkD9BfJDaA(KHTaggUwWGNoUj0Hsx)wX0s0GoaTZ2QqDbrO7w9Egg9pKqoANTvBIXmGo3HrHgDO9oKqoANTvBIXmKOctDtZTDO9oOLObDaANTvH6cbfMqwZZarJUm4PJh4eWoA7WS5diHqa0J2NQGrUCzhAVdCcyhTAtmMHevyQBAUTdT3bTenOdq7STkuxiOWeYAEgiA0LbpD8aNa2rBhMnFajecGE0(ufSwWGNoUj0Hsx)wX0MNoUi0DBhAVdCcyhTAtmMbiTg61H27qhtdMIsDIbiTLl7q7DOdpJGDdLQjaPTCjbQxYam85adVCzYammjiYiRfm4PJBcDO01VvmobSJ2j7Iq3TDO9oWjGD0cw5KigmpdeTLGlxQhdEQo0IoQqrtZQD5s9yWt1Hw0rfkAAoInEgg9pKOzC2byaDUdJcrgzTGbpDCtOdLU(TIXjGD025mzIOi0DldEQo0IoQqrJ4BvBd96q7DGta7OfSYjrmyEgiABhAVdCcyhTGvojIbfMqwZZarJSwWGNoUj0Hsx)wX4eWoArcPbpg64Iq3Tm4P6ql6OcfnIVvT1IOvhHlrFsSUOKa2X6iCsngkmAQtakPoX6IscyhRtCoXyksDSHkG1TZrPoZOG1Pdt1uNrdb0nfuhsiaQ90XnIuhmvuSoF(6wzDuNyDrN0HP2eJjku3ZWO)OqDnQlHCN6eRtTeQUOKa2X6eNqkkim1jgQfm4PJBcDO01VvmobSJwfQXqHrJi0DBhAVdayKtaBEQtmKid(gm4P6ql6OcfnnR2g69mm6FGv0GPBkGF64b05omkSCPEe4ZWO)HrhMAtmMOqaDUdJcnycaM0hdCcyhTAqkkim1jgs2fv8TrmYLl7q7DGta7OvBIXmimXEKIawzQ32uTGbpDCtOdLU(TIXjGD02HzZlcD3YGNQdTOJku00SARfrRo1N46(v(RlgfhjwNW4yDDO0PorrQlgRdWEDqAc8J19RyDSomzIOTdLUfgDI)ADX0FTUFfRdgDI)ADZUUFLAQRdLEOweT6yWth3e6qPRFRy64KYDyueNvWwwhMmr02Hs3cJoXFvKrR1GVi6yyiSvpDCs5omgyDyYerBhkDlm6e)1ORooPChgd)8mSTdLUjQ1XjL7WyG1HjteTDO0TWOt8x1xVou6wTv2GwbOKF64rgjH364KYDym8ZZW2ou6MAbdE64MqhkD9Bfd1na(PJlc1FmtiT3s3TkSZbnWl(2imHjc1FmtiT3svuqbk)yBt1IOvx05jR7xX6soX6gaGn0XRlEftSUySoItDZOuxh3tI1H6ga)0XRJAQRZarRdsluNEeEmqmmSAQRJagYG1fJ1re)60HPAQRZc1LoX6mtD)kwxhk96OM6aqFD6Wun1zwN8JSwWGNoUj0Hsx)wX4eWoA7CMmrSwulyWth3eaJBWuh2QqZCslvHjI1cg80XnbW4gm1H63kgyLtIOGfste6UTdT3bobSJwWkNeXG5zGOTeSwWGNoUjag3GPou)wXC8xX0(OIgAErO7w9sCNOzL7W4YLe4tbIsDIr2OdT3bobSJwWkNeXG5zGOTDO9oWjGD0cw5KiguycznpdeTrhAVdjKJ2zB1MymdctS3OdT3bobSJwTjgZGWe71cg80XnbW4gm1H63kgNa2r7KDrO72o0Eh4eWoAbRCsedMNbI2CBeBOhygyHj2dCcyhTAtmMHevyQBeFteC5sg8uDOfDuHIMMBJyK1IOvxusa7yDQaZMVoZkD)M6G0QJ61PL0jPVAQlEf96si3PoX6siySUzx3VMiAc1cg80XnbW4gm1H63kgNa2rBhMnVi0DBhAVdjemANT9xtenbiTgDO9oWjGD0cw5Kigmpdev8QTwWGNoUjag3GPou)wXGmOL(OIioRGTpvan)KkwWiGese6UTdT3HeYr7STAtmMbHj2BqGDO9oWjGD0QnXygsKbFdWmWctSh4eWoA1MymdjQWu3i(isWAbdE64MayCdM6q9BfdYGw6JkI4Sc2QnarX3qjaOGfmkAqp)0XTcOokafHUB7q7DiHC0oBR2eJzqyI9geyhAVdCcyhTAtmMHezW3amdSWe7bobSJwTjgZqIkm1nIpIeSwWGNoUjag3GPou)wXsihTZ2QnXykcD32H27aNa2rlyLtIyW8mq02o0Eh4eWoAbRCsedkmHSMNbI2qVnemSnrWkNer7tvWMBrcHaOhTpvbxUCdbdBteSYjr0(ufS5wWmWctSh4eWoA1MymdjQWu3SCPE9XyA8uf0(JvGIn3cMbwyI9aNa2rR2eJzirfM6MiJSwWGNoUjag3GPou)wX4eWoAvOgdfgnIq3TkSZbnW3CBeqyn6q7DaaJCcyZtDIHezW3GbpvhArhvOOPz1kcyLPEBt1IOvxecqj1jwhyCdM6qrQlgRZ8uy46i8HmFDXS)19tDGXFQdH15ZxNqoAAuNyDGvojIM6ytDWJtSo2uN2ym0omgiN6efrT6ehDO0PorXrDSPo4XjwhBQtBmgAhgRtpwuUoW4gm1Hwf256(1enRRdSqK1XUqD)k61zIzT6(PoUUOIq1ffvIAXhLoNzDGXnyQdRlNNF64H6iC31fJ1jm15Zx3kRdRlQQlkIlrQlgRdWEDcuT6mWuIRpSAQdEIXSUFQJi(1X1fv)ADrrCfQJWbwhdBM6mqMNPED8xhx3kL4kM1PWoxNgMa0FMiwx8k61fJ1PbZED)uhKbRJRlcfYX6MDDIZjgZ6eGsQtSoW4gm1H1PTYguK6mtDXyDa2RRdLEDcqj1jw3VI1fHc5yDZUoX5eJzOwWGNoUjag3GPou)wX4eWoA7CMmrue6Uvp96q7DGta7OfSYjrmyEgiABhAVdCcyhTGvojIbfMqwZZarJSHE6PWoh0aFZT64KYDymag3GPo0QWoh5YL69mm6FiHC0oBR2eJzaDUdJcnaZalmXEGta7OvBIXmKOctDJ4bZalmXEiHC0oBR2eJzydbdBteSYjr0(ufSHc7Cqd8n3QJtk3HXayCdM6qRc7S(rKWImYLl17zy0)aNa2r7K9a6ChgfAaMbwyI9aNa2r7K9qIkm1nn3sei0amdSWe7bobSJwTjgZqIkm1nIVjcgzKlxQWoh0aFZT6PJtk3HXayCdM6qRc7Cu3ebJSweT6iH0W0hDCDutDDory1ux8K)ADa28uNOi1fVsbR1rn1fVQM6OFDutDMPUnN1jmXUi1noSAQJWhY81X9rhwxuujuxTGbpDCtamUbtDO(TIzG0W0hDSi0DRc7Cqd8n3gbewTiA1fHerT6ehDO0PorXrDuVoEW6m0hIF64M6G8NcxhyCdM6qRc7CDAGpuxu2pM19R8x34WQPoaB(6Is0VUy6VwNARlkjGDSoWkNerJi1zOoaRJ(IdtDmSYy(6WOdigUof256aJ5R7N646uBDMNbIwxuuPo2vtmRMqDr5R7x5VoTH6FDrzI(1LZZpD86IPWW11X6IIk1ri1g1Ipkr)Ow8rPZzwlyWth3eaJBWuhQFRyCcyhTiH0GhdDCrO7wg8uDOfDuHIgX3Q2g6PWoh0aV4B1XjL7WyamUbtDOvHDE5Yo0Eh4eWoAbRCsedMNbI2Q2iRfm4PJBcGXnyQd1VvmobSJ2omB(AbdE64MayCdM6q9BfJta7OTZzYeXArTGbpDCtang0bOPTdpJGD22FfTOJkQre6UTdLUvBLnyJo0Eh4eWoA1MymdctS3OdT3HeYr7STAtmMbHj2B0H27aNa2rlyLtIyW8mq02o0Eh4eWoAbRCsedkmHSMNbIUC5tvq7pwbk2mygyHj2dCcyhTAtmMHevyQBQfm4PJBcOXGoan63kgyCa6FYpky3WSckcm1rlqOLakcD32H27qc5OD2wTjgZGWe7n6q7DGta7OvBIXmimXEd9iWou6wTv2Glx(uf0(JvGIndMbwyI9aNa2rR2eJzirfM6MiBOWohEQcA)XQWes8TiHqa0J2NQG1cg80Xnb0yqhGg9BfBpaidkyzcaM0hTDKveHUB7q7DiHC0oBR2eJzqyI9gDO9oWjGD0QnXygeMyVwWGNoUjGgd6a0OFRyeH4uGYUD2wMaG58RIq3TDO9oKqoANTvBIXmimXEJo0Eh4eWoA1MymdctSxlyWth3eqJbDaA0VvmnOKUvd1jA7WS5fHUB7q7DiHC0oBR2eJzqyI9gDO9oWjGD0QnXygeMyVwWGNoUjGgd6a0OFRyjvtdgTu3A0yakcD32H27qc5OD2wTjgZGWe7n6q7DGta7OvBIXmimXETGbpDCtang0bOr)wX(v0c59bYfS7jbOi0DBhAVdjKJ2zB1MymdctS3OdT3bobSJwTjgZGWe71cg80Xnb0yqhGg9BftbvMun2zBHHaubRqISIre6ULa7qPB1wzd2OdT3bobSJwTjgZGWe7naZalmXEGta7OvBIXmKOctDtJo0Eh4eWoAbRCsedMNbI22H27aNa2rlyLtIyqHjK18mq0g6rGpdJ(hsihTZ2QnXygqN7WOWYLm4PJhsihTZ2QnXygaRCsenrUC5tvq7pwbk2mygyHj2dCcyhTAtmMHevyQBQfm4PJBcOXGoan63kw8KWc6qQBt0mo7aue6UTdLUvBLnyJo0Eh4eWoA1MymdctS3OdT3HeYr7STAtmMbHj2B0H27aNa2rlyLtIyW8mq02o0Eh4eWoAbRCsedkmHSMNbIUC5tvq7pwbk2mygyHj2dCcyhTAtmMHevyQBQf1cg80XnbLrhQG(3AwPkkykcD3Qm6qf0)Ga18SdqX32ebRfm4PJBckJoub9x)wX6WuxurO7wLrhQG(heOMNDak(2MiyTGbpDCtqz0HkO)63kMwIg0bOD2wfQlulyWth3eugDOc6V(TIXjGD0QqngkmAQfm4PJBckJoub9x)wX4eWoANSxlyWth3eugDOc6V(TIzG0W0hDS8LVuc]] )


end
