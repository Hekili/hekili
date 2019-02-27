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


    --[[ spec:RegisterEvent( "PLAYER_REGEN_ENABLED", function ()
        state.burn_info.__start = 0
        state.burn_info.__average = 20
        state.burn_info.__n = 1
    end )


    spec:RegisterEvent( "PLAYER_REGEN_DISABLED", function ()
        state.burn_info.__start = 0
        state.burn_info.__average = 20
        state.burn_info.__n = 1
    end ) ]]


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


    spec:RegisterPack( "Arcane", 20190201.2345, [[d0uB4aqics9ickxcjOOnHK8jKGmkIOtrewffQYROqMfsQBbcAxI8lq0WOu5yukwgsKNrqmncsUgLsTnKa9nkukJJcvCokLyDuOsZJsv3tH2hsuhej0cjs9qKaMisqjxKcv1gPqP6JibfojLsYkveVejOYmrck1nbbyNuq)ejOQHsHILcc0tj0uPaxLsjLVsPKQ9sYFf1GL6WOwSkESQMmfDzOnJuFwrnAfCAeRgeqVMiz2Q0TjQDl8BGHtjhNcL0YL8CsnDLUoO2ob(oinEqOZtq16PqjMVI0(PALnkduIM8IkdPKD2yl2rj7SjrjHiucLTTTsCfUfQeT4xkEgvIblJkrkwphOs0If(fWMkduIAaC9OsCyxlTXfsiNj7a8j9azi1ez4lVeq8ftVqQjYpKNl4a5HMHqtuaKwfGMCrnKgtHqqMyQH0yGGziaEgZuSEoWKMi)kXdm5U2QqDuIM8IkdPKD2yl2rj7SjrjHiucLqzlkrTf(kdPGusjoqmnXqDuIMO(vIcZBkwphO3qa8m6teM3d7APnUqc5mzhGpPhidPMidF5LaIVy6fsnr(H8Cbhip0meAIcG0Qa0KlQH0ykecYetnKgdemdbWZyMI1ZbM0e53NimVn2XtbZLW92gQ9Ms2zJT4ne6nLSZ4sjH4t8jcZBkWahZO246teM3qO36LRnFGRiBnWAKAV1lWkFGRiBnWAKAV5W0Bwaw8mMpWvKVymVdEZf69ahMx007JW9EhqVzttqK8jcZBi07LRzCtlrgZliBsqVHqk7TKhGwt1sKX8cYMeucV1aV3bE9gk6TjiOqR3ieFuRjcWRW9(axH3GW7Ty9G3eAVHIEBcck06nuowVxqsjEj6vRmqj(GqJLauzGYqBugOe5FjGqjktQcuzImpJkrm4ZfnvsRwLHuszGsed(CrtL0kXVilwewjEGPPtC9CG5FGRzmPx(LY7rVTtjY)saHs8h4AgnZWwQvzOqugOeXGpx0ujTs8lYIfHvIs6DH0fQh4Zf9E6uVfAVxYlfjM9wcVPY7dmnDIRNdm)dCnJj9YVuEp69bMMoX1ZbM)bUMXKmdXSE5xkVPY7dmnDQGdmdOZwaOyLmbqdVPY7dmnDIRNdmBbGIvYeanuI8VeqOedChWkVOSfQx1QmuOugOeXGpx0ujTs8lYIfHvIhyA6exphy(h4Agt6LFP82(rVPK3u5TKE)aW1eansC9CGzlauSsfkZKq7nL92g78E6uV5FjcWmgOmb1EB)O3uYBjuI8VeqOe565aZG6OwLH2wzGsed(CrtL0kXVilwewjEGPPtf8fZa68ouiQtWwEtL3hyA6exphy(h4Agt6LFP8MYEleLi)lbekrUEoW85Y6vTkdPGkduIyWNlAQKwjY)saHsCjMOEbLC(bMievIFrwSiSs8attNk4aZa6Sfakwjta0WBQ8wO9(attN465aZwaOyLkK)1BQ8(bGRjaAK465aZwaOyLkuMjH2Bk7nLStjgSmQexIjQxqjNFGjcr1Qm0ytzGsed(CrtL0kXVilwewjEGPPtC9CG5FGRzmPx(LY7rVpW00jUEoW8pW1mMKziM1l)s5nvElP30W3BUWFGRzmVez0B7h9gHi(WlMxIm690PEtdFV5c)bUMX8sKrVTF07haUMaOrIRNdmBbGIvQqzMeAVNo1Bj9(a0AVPY7LiJ5fKnjO32p69daxta0iX1ZbMTaqXkvOmtcT3s4Tekr(xciuIfCGzaD2cafl1Qm04OmqjIbFUOPsALi)lbekrUEoWSmrRjxuRe)bMekrBuIFrwSiSsuMdoz9R32p6TTyBVPY7dmnD6VixpRxsmNkK)vTkdTfLbkrm4ZfnvsRe)ISyryLOKElP3hyA6exphy(h4Agt6LFP8E07dmnDIRNdm)dCnJjzgIz9YVuElH3u5TKElP3YCWjRF92(rVfWfHpxm9GqJLamlZb7TeEpDQ3s69daxta0iX1ZbMTaqXkvOmtcT3u27haUMaOrQGdmdOZwaOyLOHV3CH)axZyEjYO3u5TmhCY6xVTF0BbCr4Zftpi0yjaZYCWEBK3uY2ElH3s490PElP3lFXytC9CGzqDsyWNlA6nvE)aW1eansC9CGzqDsfkZKq7T9JEp)MEtL3paCnbqJexphy2cafRuHYmj0EtzVTXoVLWBj8E6uVL5Gtw)6T9JElP3c4IWNlMEqOXsaML5G9gc92g78wcVNo1Bzo4K1VEB)O3s6TaUi85IPheASeGzzoyVHqVTTDElHsK)LacLixphy(WvXZOAvgAJDkduIyWNlAQKwj(fzXIWkrzo4K1VEB)O32ITvI8VeqOe1WwyfabSAvgAJnkduIyWNlAQKwj(fzXIWkr(xIamJbktqT3uE0BH4nvElP3YCWjRF9MYJElGlcFUy6bHglbywMd27Pt9(attN465aZ)axZysV8lL3JEleVLqjY)saHsKRNdmJq06c0eqOwLH2qjLbkr(xciuIC9CG5ZL1Rsed(CrtL0QvzOncrzGsK)LacLixphy(WvXZOsed(CrtL0QvTkrtKMHVRYaLH2OmqjY)saHs8bWXIL2cVxLig85IMkPvRYqkPmqjIbFUOPsAL4xKflcRepWvKTgyn690PElP3hGw7nvEVezmVGSjb92EVzbyXZy(axr(IX8o4Tekr(xciuIpFVz(xciYxIEvIxIEZblJkXdCfQvzOqugOeXGpx0ujTs8lYIfHvIs69daxta0iX1ZbMTaqXkvOmtcT3JEBN3u59daxta0iHcapVeqKkuMjH2B7h9MfGfpJ5dCf5lgZ7G3u5TKEFGPPtC9CG5FGRzmPx(LY7rVpW00jUEoW8pW1mMKziM1l)s590PElP3lFXyt)axZOzg2kHbFUOP3u59daxta0i9dCnJMzyRuHYmj0Ep6TDElH3s4Tekr(xciuIpFVz(xciYxIEvIxIEZblJkXdCfQvzOqPmqjIbFUOPsAL4xKflcRefAVpWvKTgynQe5FjGqj(89M5FjGiFj6vjEj6nhSmQeFqOXsaQwLH2wzGsed(CrtL0kr(xciuIpFVz(xciYxIEvIxIEZblJkrzGaugJvTQvjAv4dKp8QmqzOnkduIyWNlAQKwTkdPKYaLig85IMkPvRYqHOmqjIbFUOPsA1QmuOugOe5FjGqjY1ZbMjXI3l(Rsed(CrtL0QvzOTvgOe5FjGqjQHLLbrMRNdmtZYKlHlLig85IMkPvRYqkOYaLig85IMkPvIalLOgxLi)lbekrbCr4ZfvIc4lmQePG25TrElP3uYoVnEEZglyrwmHgRWelarJjm4Zfn9wcLOaUYblJkXheASeGzzoy1Qm0ytzGsed(CrtL0QvzOXrzGsK)LacLOmPkqLjY8mQeXGpx0ujTAvgAlkduI8VeqOeTalbekrm4ZfnvsRwLH2yNYaLi)lbekrUEoW85Y6vjIbFUOPsA1QwL4bUcLbkdTrzGsed(CrtL0kXVilwewjEGPPtC9CG5FGRzmPx(LYB7h92gLi)lbekXFGRz0mdBPwLHuszGsK)LacLOmPkqLjY8mQeXGpx0ujTAvgkeLbkrm4ZfnvsRe)ISyryLOKExiDH6b(CrVNo1BH27L8srIzVLWBQ8(attN465aZ)axZysV8lL3JEFGPPtC9CG5FGRzmjZqmRx(LYBQ8(attNk4aZa6Sfakwjta0WBQ8(attN465aZwaOyLmbqdLi)lbekXa3bSYlkBH6vTkdfkLbkrm4ZfnvsRe)ISyryL4bMMovWxmdOZ7qHOobB5nvEV8fJnbeGLfakwOzcd(CrtVPYB(xIamJbktqT327TquI8VeqOe565aZNlRx1Qm02kduIyWNlAQKwj(fzXIWkXdmnDIRNdmBbGIvYeanuI8VeqOeVK5HvNHaHnNLXyvRYqkOYaLig85IMkPvIFrwSiSsuO9(attN465aZwaOyLGT8MkVL0Bzo4K1VEt5rVTTDEpDQ3paCnbqJexphy2cafRuHYmj0Ep6TDElH3u5TKEFGPPtC9CG5FGRzmPx(LY7rVpW00jUEoW8pW1mMKziM1l)s5Tekr(xciuIfCGzaD2cafl1Qm0ytzGsK)LacL4blnwsrIzLig85IMkPvRYqJJYaLi)lbekrUEoWSfakwkrm4ZfnvsRwLH2IYaLig85IMkPvIFrwSiSs8attN465aZwaOyLGT8E6uVL07dqR9MkVxImMxq2KGEBV3paCnbqJexphy2cafRuHYmj0ElHsK)LacLiSgZKfL1QvzOn2PmqjY)saHs8CbaZmnCjCLig85IMkPvRYqBSrzGsK)LacLinPWZfamvIyWNlAQKwTkdTHskduI8VeqOe54r9w8n)89QeXGpx0ujTAvgAJqugOeXGpx0ujTs8lYIfHvIhyA6ubhygqNTaqXkvOmtcT32p69bMMozvOgJhZa6SmjmtYmeZ6LFP8245n)lbejUEoW85Y6nHqeF4fZlrg9E6uVpW00jUEoWSfakwPcLzsO92(rVpW00jRc1y8ygqNLjHzsMHywV8lL3gpV5FjGiX1ZbMpxwVjeI4dVyEjYOsK)LacLOvHAmEmdOZYKWuTkdTrOugOeXGpx0ujTs8lYIfHvIhyA6exphy2cafReSL3u5TKEFGPPthS0yjfjMtWwEpDQ3hyA605caMzA4s4jylVNo1BH2Bj9U4htBbUxVNo17IFmbQ3Bj8wcLi)lbekrlWsaHAvgAJTvgOeXGpx0ujTs8lYIfHvIhyA6exphy(h4Agt6LFP8E0B78E6uVL0B(xIamJbktqT327Tq8E6uVL0B(xIamJbktqT327nL8MkVx(IXMkudcoEmHbFUOP3s4Tekr(xciuIC9CGzqDuRYqBOGkduIyWNlAQKwj(fzXIWkr(xIamJbktqT3uE0BH4nvElP3hyA6exphy(h4Agt6LFP8E07dmnDIRNdm)dCnJjzgIz9YVuElHsK)LacLixphy(WvXZOAvgAJXMYaLig85IMkPvIFrwSiSsK)LiaZyGYeu7nLh9wikr(xciuIC9CGzeIwxGMac1Qm0gJJYaLig85IMkPvI8VeqOe565aZYeTMCrTs8hysOeTrj(fzXIWkXdmnD6VixpRxsmNkK)1BQ8M)LiaZyGYeu7T9EleVPYBj9E5lgBILTUeAYZlbejm4Zfn9E6uVL0BH27LVySjGaSSaqXcntyWNlA6nvEZglyrwmX1ZbMTGLLXljMtfhs5nLh9MsElH3tN69bMMoX1ZbMTaqXkzcGgElHAvgAJTOmqjIbFUOPsAL4xKflcRe5FjcWmgOmb1EBV3crjY)saHsKRNdmFUSEvRYqkzNYaLijwSkyRntOvIYCWjRFP8OXX2krsSyvWwBMilJMeErLOnkr(xciuIOaWZlbekrm4ZfnvsRwLHuYgLbkr(xciuIC9CG5dxfpJkrm4ZfnvsRw1QeLbcqzmwLbkdTrzGsed(CrtL0kXVilwewjkdeGYySjtIE54rVP8O32yNsK)LacL45scPuRYqkPmqjIbFUOPsAL4xKflcReLbcqzm2KjrVC8O3uE0BBStjY)saHs8CjHuQvzOqugOe5FjGqjAvOgJhZa6SmjmvIyWNlAQKwTkdfkLbkr(xciuIC9CGzzIwtUOwjIbFUOPsA1Qm02kduI8VeqOe565aZG6OeXGpx0ujTAvgsbvgOe5FjGqjQHTWkacyLig85IMkPvRAvRsuawAciugsj7SX4yNTie7s2qbTnfujcLRGeZALOTs2culA6TT9M)LacVVe9Qt(eLOvbOjxujkmVPy9CGEdbWZOpryEpSRL24cjKZKDa(KEGmKAIm8Lxci(IPxi1e5hYZfCG8qZqOjkasRcqtUOgsJPqiitm1qAmqWmeapJzkwphystKFFIW82yhpfmxc3BBO2BkzNn2I3qO3uYoJlLeIpXNimVPadCmJAJRpryEdHERxU28bUIS1aRrQ9wVaR8bUIS1aRrQ9MdtVzbyXZy(axr(IX8o4nxO3dCyErtVpc37Da9MnnbrYNimVHqVxUMXnTezmVGSjb9gcPS3sEaAnvlrgZliBsqj8wd8Eh41BOO3MGGcTEJq8rTMiaVc37dCfEdcV3I1dEtO9gk6TjiOqR3q5y9EbjFIpryEB8Hi(WlA69bPbf69dKp869bNjHo5nf)hTwT3biGWbUKPHVEZ)saH2BqCfEYNW)saHozv4dKp8osFzTu(e(xci0jRcFG8HxJgHKgam9j8VeqOtwf(a5dVgncjdplJXYlbe(e(xci0jRcFG8HxJgHKRNdmtIfVx8xFc)lbe6KvHpq(WRrJqQHLLbrMRNdmtZYKlHlFIW8(bHglbywMd2BI27Da9wMd2BlSEmwEg9gk6nuowVxG3ZaVnbqdVxG3MWfjM9(bHglbyYBB16DGOP27f49fzbO3yaGNh8UaazVxG3qbLE9(zn6T(XGlcWBTfl7nfL2BqCfU3MWfjM9MIgtYNW)saHozv4dKp8A0iKc4IWNlsDWY44dcnwcWSmhm1aRrnUulGVW4if0oJKKs2z8yJfSilMqJvyIfGOXeg85IMs4t4FjGqNSk8bYhEnAesDWw6bWM1lVAFc)lbe6KvHpq(WRrJqktQcuzImpJ(e(xci0jRcFG8HxJgH0cSeq4t4FjGqNSk8bYhEnAesUEoW85Y61N4teM3gFiIp8IMEJcWs4EVez07Da9M)fuEt0EZcyYLpxm5teM32QyXQGTwV3b07dqR9g6agEBb0AY5IjFc)lbe6XhahlwAl8E9jcZBkmaEVaVLgUcVnMbwJEdDadV5BHSPW9(axbjMP2Bq5n0bm8(a0AVHsUxVnjO3Aais(e(xci0gnc5Z3BM)LaI8LOxQdwghpWvqnHE8axr2AG140PsEaAnvlrgZliBsq7zbyXZy(axr(IX8oiHpryElUCTElnCfEBmdSg9g6agEtX65a92yaqXYBI27cztH7nhMEB8faEEjGWBOK717d6DHSPW9wsq4nlalEgLW7dsdk07Da9(axH3wdSg9MO9giaRK3u8QbElZsHERHl0BOO3ZG1BHYBkwphO3uGbUMrn1EdkVFo8EgxVfkVPy9CGEtbg4Ag1EdLSdEtbg4Agn92wZk5t4FjGqB0iKpFVz(xciYxIEPoyzC8axb1e6rjFa4AcGgjUEoWSfakwPcLzsOhTJQhaUMaOrcfaEEjGivOmtcT9JSaS4zmFGRiFXyEhOsYdmnDIRNdm)dCnJj9YVuJhyA6exphy(h4AgtYmeZ6LFPMovYLVySPFGRz0mdBLWGpx0KQhaUMaOr6h4AgnZWwPcLzsOhTtcjKWNW)saH2OriF(EZ8VeqKVe9sDWY44dcnwcqQj0Jc9bUIS1aRrFc)lbeAJgH857nZ)sar(s0l1blJJYabOmgRpXNimVTvXxOmgR3a4Y7dCfEBnWA07hahlwjVT1hWafGL3qrVXyXY7Da9UpWv0EZ)saH2BOKDaaVEFqsm7nj8M9(axH3wdSgP2BY6TmYH27DGxVHIEZf6nFaWR3lWB9Y16niWKpryEZ)saHoDGRyuaxe(CrQdwghxWY38bUcn1aRr20KAb8fghTHAc9OqFGRiBnWA0NimV5FjGqNoWvy0iK6LRnFGRiBnWAKAc9OqFGRiBnWA0NimVn(HP37a69bUcVTgyn6n0bm8gk6neiSE9gfaEErZKpryEZ)saHoDGRWOri1lWkFGRiBnWAKAc94bUIS1aRrQSkuqE(nt2KqbGNxciOA5Ag30sKX8cYMeKYSaS4zmFGRiFXyEhO6axr2AG1y2eU4LackBNpryEtHnQ1EVdC4TnEtc9ISP3aAVrJvy(Q9EbEBh1EFWNH1O3aAVTkecFwVEtX65a9w6lRxFc)lbe60bUcJgH8h4AgnZWwutOhpW00jUEoW8pW1mM0l)sz)On(e(xci0PdCfgncPmPkqLjY8m6t4FjGqNoWvy0iKbUdyLxu2c1l1e6rjlKUq9aFU40Pc9sEPiXSeuDGPPtC9CG5FGRzmPx(LA8attN465aZ)axZysMHywV8lfvhyA6ubhygqNTaqXkzcGguDGPPtC9CGzlauSsMaOHpryEBRpGH3fCeKy2Bk8cWYcafl0KAV5W0BOO3ZG1B2Bii8f9gq7TbdfIAVTkW7TKuKchf9gk69my9gaxElu7G3uSEoqVPadCnJElGWEtbg4Agn92wZscQ9gwJEtwVpinOqVH1Ky2BiiWymIIgd1EFWNH1O37a6TmhS3fAc)lbeEt0Ed2bSGs0O3xUMXRW9gkRx00BnjE07Da9MIs7nuw7nDHO3CiCOSWt(e(xci0PdCfgncjxphy(Cz9snHE8attNk4lMb05DOquNGTOA5lgBciallauSqZeg85IMuX)seGzmqzcQTxi(e(xci0PdCfgnc5LmpS6meiS5Smgl1e6XdmnDIRNdmBbGIvYean8j8VeqOth4kmAeYcoWmGoBbGIf1e6rH(attN465aZwaOyLGTOsszo4K1VuE022nD6daxta0iX1ZbMTaqXkvOmtc9ODsqLKhyA6exphy(h4Agt6LFPgpW00jUEoW8pW1mMKziM1l)sjHpH)LacD6axHrJqEWsJLuKy2NW)saHoDGRWOri565aZwaOy5t4FjGqNoWvy0iKWAmtwuwtnHE8attN465aZwaOyLGTMovYdqRPAjYyEbztcA)daxta0iX1ZbMTaqXkvOmtcTe(e(xci0PdCfgnc55caMzA4s4(e(xci0PdCfgncjnPWZfam9j8VeqOth4kmAesoEuVfFZpFV(e(xci0PdCfgncPvHAmEmdOZYKWKAc94bMMovWbMb0zlauSsfkZKqB)4bMMozvOgJhZa6SmjmtYmeZ6LFPmE8VeqK465aZNlR3ecr8HxmVezC60dmnDIRNdmBbGIvQqzMeA7hpW00jRc1y8ygqNLjHzsMHywV8lLXJ)LaIexphy(Cz9MqiIp8I5LiJ(e(xci0PdCfgncPfyjGGAc94bMMoX1ZbMTaqXkbBrLKhyA60blnwsrI5eS10PhyA605caMzA4s4jyRPtfAjl(X0wG7D60IFmbQxcj8j8VeqOth4kmAesUEoWmOoutOhpW00jUEoW8pW1mM0l)snA30PsY)seGzmqzcQTxitNkj)lraMXaLjO2Ekr1Yxm2uHAqWXJjm4ZfnLqcFc)lbe60bUcJgHKRNdmF4Q4zKAc9i)lraMXaLjOMYJcHkjpW00jUEoW8pW1mM0l)snEGPPtC9CG5FGRzmjZqmRx(LscFc)lbe60bUcJgHKRNdmJq06c0eqqnHEK)LiaZyGYeut5rH4teM32Q5auO3uSEoqVHaiAn5IAVnHlsm7nfRNd0BJbaflQ9M1et0B6ci7TgiJElalH7T2cFcn59gH4JwlbeAQ9(sKc9oaR3dSasm7nfEbyzbGIfA69Yxmw00BQ8UGJGeZElei6nfRNd0BJbwwgVKyo5t4FjGqNoWvy0iKC9CGzzIwtUOMAc94bMMo9xKRN1ljMtfY)sf)lraMXaLjO2EHqLKlFXytSS1LqtEEjGiHbFUO50Psk0lFXytabyzbGIfAMWGpx0Kk2yblYIjUEoWSfSSmEjXCQ4qkkpsjjMo9attN465aZwaOyLmbqdjO(hysmAJpH)LacD6axHrJqY1ZbMpxwVutOh5FjcWmgOmb12leFIW82qauV3bE9gksHk0BtqGEFGRGeZu7nu07NdVHTm5f9EhqVzbyXZy(axr(IX8o4nuYo49oGEFXyEh8gq79oq0EFGRi5teM38VeqOth4kmAesbCr4ZfPoyzCKfGfpJ5dCf5lgZ7a1aRrnUulGVW4OKc4IWNlMybyXZy(axr(IX8oy8eWfHpxmTGLV5dCfAiuaxe(CXelalEgZh4kYxmM3bJK8axr2AG1y2eU4LacjKGctbCr4Zftly5B(axH2NW)saHoDGRWOrirbGNxciOMelwfS1Mj0JYCWjRFP8OXX2utIfRc2AZezz0KWloAJpryEBSdkV3b07Il0BW)SMacVHoGf6nu07zG3aGS3hKguO3OaWZlbeEt0EF4xkVHTsElPTMgMVxH79bFgwJEdf9EgxVfGLW9(WMExXS3AG37a69bUcVjAVF41BbyjCV1dGALWNW)saHoDGRWOri565aZhUkEg9j(e(xci0PheASeGJYKQavMiZZOpH)LacD6bHglbOrJq(dCnJMzylQj0JhyA6exphy(h4Agt6LFPgTZNW)saHo9GqJLa0OridChWkVOSfQxQj0JswiDH6b(CXPtf6L8srIzjO6attN465aZ)axZysV8l14bMMoX1ZbM)bUMXKmdXSE5xkQoW00PcoWmGoBbGIvYeanO6attN465aZwaOyLmbqdFc)lbe60dcnwcqJgHKRNdmdQd1e6XdmnDIRNdm)dCnJj9YVu2psjQK8bGRjaAK465aZwaOyLkuMjHMY2y30P8VebygduMGA7hPKe(eH5nfRNd0BPVSE9wpqOxT3WwEtcVTkcOiRW9g6agExWrqIzVl4l6nG27DOquN8j8VeqOtpi0yjanAesUEoW85Y6LAc94bMMovWxmdOZ7qHOobBr1bMMoX1ZbM)bUMXKE5xkkleFc)lbe60dcnwcqJgHewJzYIYuhSmoUetuVGso)ateIutOhpW00PcoWmGoBbGIvYeanOsOpW00jUEoWSfakwPc5FP6bGRjaAK465aZwaOyLkuMjHMYuYoFc)lbe60dcnwcqJgHSGdmdOZwaOyrnHE8attN465aZ)axZysV8l14bMMoX1ZbM)bUMXKmdXSE5xkQKKg(EZf(dCnJ5LiJ2pIqeF4fZlrgNoLg(EZf(dCnJ5LiJ2p(aW1eansC9CGzlauSsfkZKqpDQKhGwt1sKX8cYMe0(XhaUMaOrIRNdmBbGIvQqzMeAjKWNW)saHo9GqJLa0Ori565aZYeTMCrn1e6rzo4K1V2pAl2MQdmnD6VixpRxsmNkK)L6FGjXOn(eH5nfwWfjM9(bHglbi1Edf9wVK71Biqy96nuowVxG3piwsaJEhG1BZcyzrIzV)bUMrT3S27liM9M1EBb0AY5IjrG3sHOL3uOdCfKyMc5nR9(cIzVzT3waTMCUO3sYsXE)GqJLamlZb79ouOEyaCnLWBom9EhWWBnu2Y7f4n7TqbrVPO0qiLP4HRY7heASeGExGLxcisEBRO9gk6TjW7aSEpWcqVfkVPifGAVHIE)C4TjXYB9LmpSxH79faflVxG3Z46n7TqTdEtrkqYBBD0B(QbERH1ltcV51B27bY8awElZb7TfwpglpJEdDadVHIEBD5W7f4nSg9M9gcchO3aAVngauS82eUiXS3pi0yja92AG1i1ERbEdf9(5W7dCfEBcxKy27Da9gcchO3aAVngauSs(e(xci0PheASeGgncjxphy(WvXZi1e6rjL8attN465aZ)axZysV8l14bMMoX1ZbM)bUMXKmdXSE5xkjOssjL5Gtw)A)OaUi85IPheASeGzzoyjMovYhaUMaOrIRNdmBbGIvQqzMeAk)aW1eansfCGzaD2cafRen89Ml8h4AgZlrgPsMdoz9R9Jc4IWNlMEqOXsaML5GnIs2wcjMovYLVySjUEoWmOojm4ZfnP6bGRjaAK465aZG6KkuMjH2(X53KQhaUMaOrIRNdmBbGIvQqzMeAkBJDsiX0PYCWjRFTFusbCr4Zftpi0yjaZYCWqOn2jX0PYCWjRFTFusbCr4Zftpi0yjaZYCWqOTTtcFIW8we2cRaiG9MO9(WfEfU3qb1o49Z6LeZu7n0bYp4nr7n0bH7nz9MO9wd8MMlVnbqdQ9gexH7neiSE9MpabO3uu6K3(e(xci0PheASeGgncPg2cRaiGPMqpkZbNS(1(rBX2(eH5nfoeT8McDGRGeZuiVjH3ma9wtwyEjGq7nCSKR3pi0yjaZYCWEB9BYBksVy59oWR3G4kCVFwVEtrJV3qj7G3cXBkwphO3)axZOMAV1K4rVjlfs7nFLb61B0yfMVElZb79d0R3lWB2BH4TE5xkVPO0EZHWHYcp5nfxV3bE92cqI1Bkcm(ExGLxci8gk5E9(GEtrP9gIcXBiKYEtrJV3qiL9MIhUkFc)lbe60dcnwcqJgHKRNdmJq06c0eqqnHEK)LiaZyGYeut5rHqLKYCWjRFP8OaUi85IPheASeGzzo4PtpW00jUEoW8pW1mM0l)snkej8j8VeqOtpi0yjanAesUEoW85Y61NW)saHo9GqJLa0Ori565aZhUkEg9j(e(xci0jzGaugJDupqKLXIAc9OmqakJXMmj6LJhP8On25t4FjGqNKbcqzmwJgH8CjHuutOhLbcqzm2KjrVC8iLhTXoFc)lbe6KmqakJXA0iKwfQX4XmGoltctFc)lbe6KmqakJXA0iKC9CGzzIwtUO2NW)saHojdeGYySgncjxphyguhFc)lbe6KmqakJXA0iKAylScGawjYW7aOuIIez4lVeqqbkMEvRAvka]] )


end
