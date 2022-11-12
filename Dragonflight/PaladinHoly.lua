-- PaladinHoly.lua
-- DF Pre-Patch Nov 2022

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State


local PTR = ns.PTR

if UnitClassBase( "player" ) == "PALADIN" then
    local spec = Hekili:NewSpecialization( 65 )

    spec:RegisterResource( Enum.PowerType.HolyPower )
    spec:RegisterResource( Enum.PowerType.Mana )
    
    -- Talents
    spec:RegisterTalents( {
        afterimage = { 102601, 385414 },
        aspiration_of_divinity = { 102613, 385416 },
        aura_mastery = { 102548, 31821 },
        auras_of_swift_vengeance = { 102588, 385639 },
        auras_of_the_resolute = { 102586, 385633 },
        avenging_crusader = { 102568, 394088 },
        avenging_wrath = { 102593, 384376 },
        avenging_wrath_might = { 102569, 384442 },
        awakening = { 102578, 248033 },
        barrier_of_faith = { 102537, 148039 },
        beacon_of_faith = { 102533, 156910 },
        beacon_of_virtue = { 102532, 200025 },
        bestow_faith = { 102543, 223306 },
        blessing_of_freedom = { 102587, 1044 },
        blessing_of_protection = { 102604, 1022 },
        blessing_of_sacrifice = { 102602, 6940 },
        blessing_of_summer = { 102579, 388007 },
        blinding_light = { 102584, 115750 },
        boundless_salvation = { 102572, 392951 },
        breaking_dawn = { 102566, 387879 },
        cavalier = { 102592, 230332 },
        commanding_light = { 102564, 387781 },
        crusaders_might = { 102580, 196926 },
        divine_favor = { 102551, 210294 },
        divine_glimpse = { 102570, 387805 },
        divine_insight = { 102554, 392914 },
        divine_protection = { 102549, 498 },
        divine_purpose = { 102608, 223817 },
        divine_resonance = { 102582, 387893 },
        divine_revelations = { 102562, 387808 },
        divine_steed = { 102625, 190784 },
        divine_toll = { 102563, 375576 },
        echoing_blessings = { 102535, 387801 },
        empyreal_ward = { 102558, 387791 },
        empyrean_legacy = { 102576, 387170 },
        fist_of_justice = { 102589, 234299 },
        glimmer_of_light = { 102581, 325966 },
        golden_path = { 102598, 377128 },
        hallowed_ground = { 102478, 377043 },
        hammer_of_wrath = { 102479, 24275 },
        holy_aegis = { 102597, 385515 },
        holy_avenger = { 102607, 105809 },
        holy_light = { 102550, 82326 },
        holy_prism = { 102560, 114165 },
        holy_shock = { 102534, 20473 },
        illumination = { 102555, 387993 },
        imbued_infusions = { 102536, 392961 },
        improved_blessing_of_protection = { 102606, 384909 },
        improved_cleanse = { 102477, 393024 },
        incandescence = { 102620, 385464 },
        inflorescence_of_the_sunwell = { 102577, 392907 },
        judgment = { 114292, 231644 },
        judgment_of_light = { 102596, 183778 },
        lay_on_hands = { 102583, 633 },
        light_of_dawn = { 102545, 85222 },
        light_of_the_martyr = { 102540, 183998 },
        lights_hammer = { 102561, 114158 },
        maraads_dying_breath = { 102538, 388018 },
        moment_of_compassion = { 102553, 387786 },
        obduracy = { 102618, 385427 },
        of_dusk_and_dawn = { 102615, 385125 },
        power_of_the_silver_hand = { 102574, 200474 },
        protection_of_tyr = { 102546, 200430 },
        radiant_onslaught = { 102557, 231667 },
        rebuke = { 102591, 96231 },
        recompense = { 102594, 384914 },
        relentless_inquisitor = { 102575, 383388 },
        repentance = { 102585, 20066 },
        resplendent_light = { 102552, 392902 },
        rule_of_law = { 102541, 214202 },
        sacrifice_of_the_just = { 102595, 384820 },
        sanctified_wrath = { 102611, 53376 },
        saved_by_the_light = { 102542, 157047 },
        seal_of_alacrity = { 102609, 385425 },
        seal_of_clarity = { 102600, 384815 },
        seal_of_mercy = { 102599, 384897 },
        seal_of_might = { 102612, 385450 },
        seal_of_order = { 102614, 385129 },
        seal_of_reprisal = { 102621, 377053 },
        seal_of_the_crusader = { 102617, 385728 },
        seal_of_the_templar = { 102623, 377016 },
        seasoned_warhorse = { 102624, 376996 },
        second_sunrise = { 102567, 200482 },
        seraphim = { 102610, 152262 },
        shining_savior = { 102559, 388005 },
        tirions_devotion = { 102556, 392928 },
        touch_of_light = { 102619, 385349 },
        tower_of_radiance = { 102571, 231642 },
        turn_evil = { 102622, 10326 },
        tyrs_deliverance = { 102573, 200652 },
        unbreakable_spirit = { 102603, 114154 },
        unending_light = { 102544, 387998 },
        untempered_dedication = { 102539, 387814 },
        unwavering_spirit = { 102547, 392911 },
        veneration = { 102565, 392938 },
        zealots_paragon = { 102616, 391142 },
    } )


    -- PvP Talents
    spec:RegisterPvpTalents( { 
        cleanse_the_weak = 642, -- 199330
        hallowed_ground = 3618, -- 216868
        blessed_hands = 88, -- 199454
        lights_grace = 859, -- 216327
        ultimate_sacrifice = 85, -- 199452
        avenging_light = 82, -- 199441
        darkest_before_the_dawn = 86, -- 210378
        spreading_the_word = 87, -- 199456
        judgments_of_the_pure = 5421, -- 355858
        aura_of_reckoning = 5553, -- 247675
        divine_vision = 640, -- 199324
        precognition = 5501, -- 377360
        vengeance_aura = 5537, -- 210323
    } )


    -- Auras
    spec:RegisterAuras( {
        afterimage = {
            id = 385414,
        },
        aspiration_of_divinity = {
            id = 385416,
        },
        aura_mastery = {
            id = 31821,
            duration = 8,
            max_stack = 1,
        },
        avenging_crusader = {
            id = 216331,
            duration = 25,
            max_stack = 1,
        },
        avenging_wrath = {
            id = 31884,
            duration = 25,
            max_stack = 1,
        },
        barrier_of_faith = {
            id = 148039,
            duration = 18,
            max_stack = 1,
        },
        beacon_of_faith = {
            id = 156910,
            duration = 3600,
            max_stack = 1,
        },
        beacon_of_light = {
            id = 53563,
            duration = 3600,
            max_stack = 1,
        },
        beacon_of_virtue = {
            id = 200025,
            duration = 8,
            max_stack = 1,
        },
        bestow_faith = {
            id = 223306,
            duration = 5,
            max_stack = 1,
        },
        blessing_of_autumn = {
            id = 388010,
            duration = 30,
            max_stack = 1,
        },
        blessing_of_freedom = {
            id = 1044,
            duration = 8,
            type = "Magic",
            max_stack = 1,
        },
        blessing_of_protection = {
            id = 1022,
            duration = 10,
            type = "Magic",
            max_stack = 1,
        },
        blessing_of_sacrifice = {
            id = 6940,
            duration = 12,
            max_stack = 1,
        },
        blessing_of_spring = {
            id = 388013,
            duration = 30,
            max_stack = 1,
        },
        blessing_of_summer = {
            id = 388007,
            duration = 30,
            max_stack = 1,
        },
        blessing_of_winter = {
            id = 388011,
            duration = 30,
            max_stack = 1,
        },
        blinding_light = {
            id = 115750,
        },
        concentration_aura = {
            id = 317920,
            duration = 3600,
            max_stack = 1,
        },
        consecration = {
            id = 26573,
        },
        contemplation = {
            id = 121183,
            duration = 8,
            max_stack = 1,
        },
        crusader_aura = {
            id = 32223,
            duration = 3600,
            max_stack = 1,
        },
        devotion_aura = {
            id = 465,
            duration = 3600,
            max_stack = 1,
        },
        divine_favor = {
            id = 210294,
            duration = 3600,
            type = "Magic",
            max_stack = 1,
        },
        divine_protection = {
            id = 498,
            duration = 8,
            max_stack = 1,
        },
        divine_purpose = {
            id = 223819,
            duration = 12,
            max_stack = 1,
        },
        divine_resonance = {
            id = 387895,
            duration = 15,
            max_stack = 1,
        },
        divine_shield = {
            id = 642,
            duration = 8,
            type = "Magic",
            max_stack = 1,
        },
        divine_steed = {
            id = 276112,
            duration = 6.15,
            max_stack = 1,
        },
        echoing_freedom = {
            id = 339321,
            duration = 8,
            type = "Magic",
            max_stack = 1,
        },
        echoing_protection = {
            id = 339324,
            duration = 8,
            type = "Magic",
            max_stack = 1,
        },
        fleshcraft = {
            id = 324631,
            duration = 120,
            max_stack = 1,
        },
        forbearance = {
            id = 25771,
            duration = 30,
            max_stack = 1,
        },
        golden_path = {
            id = 377128,
        },
        holy_avenger = {
            id = 105809,
            duration = 20,
            max_stack = 1,
        },
        incandescence = {
            id = 385464,
        },
        infusion_of_light = {
            id = 53576,
            duration = 15,
            max_stack = 2,
        },
        infusion_of_light = {
            id = 54149,
            duration = 15,
            max_stack = 2,
        },
        light_of_the_martyr = {
            id = 196917,
            duration = 5.113,
            max_stack = 1,
        },
        mastery_lightbringer = {
            id = 183997,
        },
        of_dusk_and_dawn = {
            id = 385125,
        },
        recompense = {
            id = 384914,
        },
        retribution_aura = {
            id = 183435,
            duration = 3600,
            max_stack = 1,
        },
        rule_of_law = {
            id = 214202,
            duration = 10,
            max_stack = 1,
        },
        seal_of_clarity = {
            id = 384815,
        },
        seal_of_mercy = {
            id = 384897,
        },
        seal_of_might = {
            id = 385450,
        },
        seal_of_the_templar = {
            id = 377016,
        },
        seraphim = {
            id = 152262,
            duration = 15,
            max_stack = 1,
        },
        shield_of_the_righteous = {
            id = 132403,
            duration = 4.5,
            max_stack = 1,
        },
        shielding_words = {
            id = 338788,
            duration = 10,
            type = "Magic",
            max_stack = 1,
        },
        tyrs_deliverance = {
            id = 200652,
            duration = 10,
            max_stack = 1,
        },
        unending_light = {
            id = 394709,
            duration = 30,
            type = "Magic",
            max_stack = 6,
        },
        untempered_dedication = {
            id = 387815,
            duration = 15,
            max_stack = 5,
        },
        vanquishers_hammer = {
            id = 328204,
        },
        zealots_paragon = {
            id = 391142,
        },
    } )


    -- Abilities
    spec:RegisterAbilities( {
        absolution = {
            id = 212056,
            cast = 10,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.04,
            spendType = "mana",
            
            startsCombat = false,
            texture = 1030102,
            
            handler = function ()
            end,
        },
        

        aura_mastery = {
            id = 31821,
            cast = 0,
            cooldown = 180,
            gcd = "spell",
            
            startsCombat = false,
            texture = 135872,
            
            toggle = "cooldowns",

            handler = function ()
                applyBuff("aura_mastery")
            end,
        },
        

        avenging_crusader = {
            id = 216331,
            cast = 0,
            cooldown = 120,
            gcd = "spell",
            
            spend = 0.5,
            spendType = "mana",
            
            startsCombat = false,
            texture = 589117,
            
            toggle = "cooldowns",

            handler = function ()
                applyBuff("avenging_crusader")
            end,
        },
        

        avenging_wrath = {
            id = 31884,
            cast = 0,
            cooldown = 120,
            gcd = "spell",
            
            startsCombat = false,
            texture = 135875,
            
            toggle = "cooldowns",

            handler = function ()
                applyBuff("avenging_wrath")
            end,
        },
        

        barrier_of_faith = {
            id = 148039,
            cast = 0,
            cooldown = 25,
            gcd = "spell",
            
            spend = 0.1,
            spendType = "mana",

            startsCombat = false,
            texture = 4067370,
            
            handler = function ()
                applyBuff("barrier_of_faith")
            end,
        },
        

        beacon_of_faith = {
            id = 156910,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.03,
            spendType = "mana",
            
            startsCombat = false,
            texture = 1030095,
            
            handler = function ()
                applyBuff("beacon_of_faith")
            end,
        },
        

        beacon_of_light = {
            id = 53563,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.02,
            spendType = "mana",
            
            startsCombat = false,
            texture = 236247,
            
            handler = function ()
                applyBuff("beacon_of_light")
            end,
        },
        

        beacon_of_virtue = {
            id = 200025,
            cast = 0,
            cooldown = 15,
            gcd = "spell",
            
            spend = 0.1,
            spendType = "mana",
            
            startsCombat = false,
            texture = 1030094,
            
            handler = function ()
                applyBuff("beacon_of_virtue")
            end,
        },
        

        bestow_faith = {
            id = 223306,
            cast = 0,
            cooldown = 12,
            gcd = "spell",
            
            spend = 0.06,
            spendType = "mana",
            
            startsCombat = false,
            texture = 236249,
            
            handler = function ()
                applyBuff("bestow_faith")
            end,
        },
        

        blessing_of_autumn = {
            id = 388010,
            cast = 0,
            cooldown = 45,
            gcd = "spell",
            
            spend = 0.05,
            spendType = "mana",
            
            startsCombat = false,
            texture = 3636843,
            
            handler = function ()
                setCooldown( "blessing_of_winter", 45 )
                setCooldown( "blessing_of_summer", 90 )
                setCooldown( "blessing_of_spring", 135 )
            end,
        },
        

        blessing_of_freedom = {
            id = 1044,
            cast = 0,
            charges = 1,
            cooldown = 25,
            recharge = 25,
            gcd = "spell",
            
            spend = 0.07,
            spendType = "mana",
            
            startsCombat = false,
            texture = 135968,
            
            handler = function ()
                applyBuff("blessing_of_freedom")
            end,
        },
        

        blessing_of_protection = {
            id = 1022,
            cast = 0,
            charges = 1,
            cooldown = 300,
            recharge = 300,
            gcd = "spell",
            
            spend = 0.15,
            spendType = "mana",
            
            startsCombat = false,
            texture = 135964,
            
            toggle = "defensives",
            defensives = true,

            handler = function ()
                applyDebuff("forbearance")
                applyBuff("blessing_of_protection")
            end,
        },
        

        blessing_of_sacrifice = {
            id = 6940,
            cast = 0,
            charges = 1,
            cooldown = 60,
            recharge = 60,
            gcd = "spell",
            
            spend = 0.07,
            spendType = "mana",
            
            startsCombat = false,
            texture = 135966,
            
            toggle = "cooldowns",

            handler = function ()
                applyBuff("blessing_of_sacrifice")
            end,
        },
        

        blessing_of_spring = {
            id = 388013,
            cast = 0,
            cooldown = 45,
            gcd = "spell",
            
            spend = 0.05,
            spendType = "mana",
            
            startsCombat = false,
            texture = 3636844,
            
            handler = function ()
                setCooldown( "blessing_of_summer", 45 )
                setCooldown( "blessing_of_autumn", 90 )
                setCooldown( "blessing_of_winter", 135 )
            end,
        },
        

        blessing_of_summer = {
            id = 388007,
            cast = 0,
            cooldown = 180,
            gcd = "spell",
            
            spend = 0.05,
            spendType = "mana",
            
            startsCombat = false,
            texture = 3636845,
            
            handler = function ()
                setCooldown( "blessing_of_autumn", 45 )
                setCooldown( "blessing_of_winter", 90 )
                setCooldown( "blessing_of_spring", 135 )
            end,
        },
        

        blessing_of_winter = {
            id = 388011,
            cast = 0,
            cooldown = 45,
            gcd = "spell",
            
            spend = 0.05,
            spendType = "mana",
            
            startsCombat = false,
            texture = 3636846,
            
            handler = function ()
                setCooldown( "blessing_of_spring", 45 )
                setCooldown( "blessing_of_summer", 90 )
                setCooldown( "blessing_of_autumn", 135 )
            end,
        },
        

        blinding_light = {
            id = 115750,
            cast = 0,
            cooldown = 90,
            gcd = "spell",
            
            spend = 0.06,
            spendType = "mana",
            
            startsCombat = true,
            texture = 571553,
            
            handler = function ()
                applyDebuff("blinding_light")
            end,
        },
        

        cleanse = {
            id = 4987,
            cast = 0,
            charges = 1,
            cooldown = 8,
            recharge = 8,
            gcd = "spell",
            
            spend = 0.06,
            spendType = "mana",
            
            startsCombat = false,
            texture = 135949,
            
            handler = function ()
            end,
        },
        

        concentration_aura = {
            id = 317920,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            startsCombat = false,
            texture = 135933,
            
            handler = function ()
                applyBuff("concentration_aura")
                removeBuff("devotion_aura")
                removeBuff("crusader_aura")
                removeBuff("retribution_aura")
            end,
        },
        

        consecration = {
            id = 26573,
            cast = 0,
            cooldown = 9,
            gcd = "spell",
            
            startsCombat = true,
            texture = 135926,
            
            handler = function ()
            end,
        },
        

        contemplation = {
            id = 121183,
            cast = 0,
            cooldown = 8,
            gcd = "spell",
            
            startsCombat = false,
            texture = 134916,
            
            handler = function ()
            end,
        },
        

        crusader_aura = {
            id = 32223,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            startsCombat = false,
            texture = 135890,
            
            handler = function ()
                applyBuff("crusader_aura")
                removeBuff("devotion_aura")
                removeBuff("retribution_aura")
                removeBuff("concentration_aura")
            end,
        },
        

        crusader_strike = {
            id = 35395,
            cast = 0,
            charges = 2,
            cooldown = 6,
            recharge = 6,
            gcd = "spell",
            
            spend = 0.11,
            spendType = "mana",
            
            startsCombat = true,
            texture = 135891,
            
            handler = function ()
                gain( buff.holy_avenger.up and 3 or 1, "holy_power" )

                if talent.crusaders_might.enabled then
                    setCooldown( "holy_shock", max( 0, cooldown.holy_shock.remains - 2.0 ) )
                end
            end,
        },
        

        devotion_aura = {
            id = 465,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            startsCombat = false,
            texture = 135893,
            
            handler = function ()
                applyBuff("devotion_aura")
                removeBuff("retribution_aura")
                removeBuff("crusader_aura")
                removeBuff("concentration_aura")
            end,
        },
        

        divine_favor = {
            id = 210294,
            cast = 0,
            cooldown = 45,
            gcd = "spell",
            
            startsCombat = false,
            texture = 135915,
            
            handler = function ()
                applyBuff("divine_favor")
            end,
        },
        

        divine_protection = {
            id = 498,
            cast = 0,
            cooldown = function () return ( talent.unbreakable_spirit.enabled and 0.7 or 1 ) * 60 end,
            gcd = "spell",
            
            spend = 0.04,
            spendType = "mana",
            
            startsCombat = false,
            texture = 524353,
            
            toggle = "defensives",
            defensives = true,

            handler = function ()
                applyBuff("divine_protection")
            end,
        },
        

        divine_shield = {
            id = 642,
            cast = 0,
            cooldown = function () return ( talent.unbreakable_spirit.enabled and 0.7 or 1 ) * 300 end,
            gcd = "spell",
            
            startsCombat = false,
            texture = 524354,
            
            toggle = "defensives",
            defensives = true,

            handler = function ()
                applyDebuff("forbearance")
                applyBuff("divine_shield")
            end,
        },
        

        divine_steed = {
            id = 190784,
            cast = 0,
            charges = 2,
            cooldown = 45,
            recharge = 45,
            gcd = "spell",
            
            startsCombat = false,
            texture = 1360759,
            
            handler = function ()
                applyBuff("divine_steed")
            end,
        },
        

        divine_toll = {
            id = 375576,
            cast = 0,
            cooldown = 60,
            gcd = "spell",
            
            spend = 0.15,
            spendType = "mana",
            
            startsCombat = true,
            texture = 3565448,
            
            toggle = "cooldowns",

            handler = function ()
                gain( buff.holy_avenger.up and 5 or 2, "holy_power" )
            end,
        },
        

        flash_of_light = {
            id = 19750,
            cast = 1.5,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.22,
            spendType = "mana",
            
            startsCombat = false,
            texture = 135907,
            
            handler = function ()
                removeBuff("infusion_of_light")
                removeBuff("divine_favor")
            end,
        },
        

        fleshcraft = {
            id = 324631,
            cast = 0,
            cooldown = 120,
            gcd = "spell",
            
            startsCombat = false,
            texture = 3586267,
            
            toggle = "cooldowns",

            handler = function ()
                applyBuff("fleshcraft")
            end,
        },
        

        hammer_of_justice = {
            id = 853,
            cast = 0,
            cooldown = 60,
            gcd = "spell",
            
            spend = 0.04,
            spendType = "mana",
            
            startsCombat = true,
            texture = 135963,
            
            toggle = "cooldowns",

            handler = function ()
                applyDebuff("hammer_of_justice")
            end,
        },
        

        hammer_of_wrath = {
            id = 24275,
            cast = 0,
            cooldown = 7.5,
            gcd = "spell",
            
            startsCombat = true,
            texture = 613533,

            usable = function () return target.health_pct < 20 end,

            handler = function ()
                gain( buff.holy_avenger.up and 3 or 1, "holy_power" )
            end,
        },
        

        hand_of_reckoning = {
            id = 62124,
            cast = 0,
            cooldown = 8,
            gcd = "spell",
            
            spend = 0.03,
            spendType = "mana",
            
            startsCombat = true,
            texture = 135984,
            
            handler = function ()
                applyDeuff("hand_of_reckoning")
            end,
        },
        

        holy_avenger = {
            id = 105809,
            cast = 0,
            cooldown = 180,
            gcd = "spell",
            
            startsCombat = false,
            texture = 571555,
            
            toggle = "cooldowns",

            handler = function ()
                applyBuff("holy_avenger")
            end,
        },
        

        holy_light = {
            id = 82326,
            cast = 2.5,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.15,
            spendType = "mana",
            
            startsCombat = false,
            texture = 135981,
            
            handler = function ()
                removeBuff("infusion_of_light")
                removeBuff("divine_favor")
            end,
        },
        

        holy_prism = {
            id = 114165,
            cast = 0,
            cooldown = 20,
            gcd = "spell",
            
            spend = 0.13,
            spendType = "mana",
            
            startsCombat = true,
            texture = 613408,
            
            handler = function ()
            end,
        },
        

        holy_shock = {
            id = 20473,
            cast = 0,
            cooldown = 7.5,
            gcd = "spell",
            
            spend = 0.16,
            spendType = "mana",
            
            startsCombat = true,
            texture = 135972,
            
            handler = function ()
                gain( buff.holy_avenger.up and 3 or 1, "holy_power" )
            end,
        },
        

        intercession = {
            id = 391054,
            cast = 2.0003372583008,
            cooldown = 600,
            gcd = "spell",
            
            spend = 0,
            spendType = "holy_power",
            
            startsCombat = false,
            texture = 4726195,
            
            handler = function ()
            end,
        },
        

        judgment = {
            id = 275773,
            cast = 0,
            cooldown = 12,
            gcd = "spell",
            
            spend = 0.03,
            spendType = "mana",
            
            startsCombat = true,
            texture = 135959,
            
            handler = function ()
            end,
        },
        

        lay_on_hands = {
            id = 633,
            cast = 0,
            cooldown = function () return ( talent.unbreakable_spirit.enabled and 0.7 or 1 ) * 600 end,
            gcd = "spell",
            
            startsCombat = false,
            texture = 135928,
            
            toggle = "cooldowns",

            handler = function ()
                applyDebuff("forbearance")
            end,
        },
        

        light_of_dawn = {
            id = 85222,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = function ()
                if buff.divine_purpose.up then return 0 end
                return 3
            end,
            spendType = "holy_power",
            
            startsCombat = false,
            texture = 461859,
            
            handler = function ()
                removeBuff("divine_purpose")
            end,
        },
        

        light_of_the_martyr = {
            id = 183998,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.07,
            spendType = "mana",
            
            startsCombat = false,
            texture = 1360762,
            
            handler = function ()
                removeBuff( "maraads_dying_breath" )
            end,
        },
        

        lights_hammer = {
            id = 114158,
            cast = 0,
            cooldown = 60,
            gcd = "spell",
            
            spend = 0.18,
            spendType = "mana",
            
            startsCombat = true,
            texture = 613955,
            
            handler = function ()
            end,
        },
        

        rebuke = {
            id = 96231,
            cast = 0,
            cooldown = 15,
            gcd = "off",
            
            startsCombat = true,
            texture = 523893,
            
            toggle = "interrupts",

            debuff = "casting",
            readyTime = state.timeToInterrupt,

            handler = function ()
                interrupt()
            end,
        },
        

        redemption = {
            id = 7328,
            cast = 10.000345582886,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.04,
            spendType = "mana",
            
            startsCombat = false,
            texture = 135955,
            
            handler = function ()
            end,
        },
        

        repentance = {
            id = 20066,
            cast = 1.7,
            cooldown = 15,
            gcd = "spell",
            
            spend = 0.06,
            spendType = "mana",
            
            startsCombat = false,
            texture = 135942,
            
            handler = function ()
                applyDebuff("repentance")
            end,
        },
        

        retribution_aura = {
            id = 183435,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            startsCombat = false,
            texture = 135889,
            
            handler = function ()
                applyBuff("retribution_aura")
                removeBuff("devotion_aura")
                removeBuff("crusader_aura")
                removeBuff("concentration_aura")
            end,
        },
        

        rule_of_law = {
            id = 214202,
            cast = 0,
            charges = 2,
            cooldown = 30,
            recharge = 30,
            gcd = "off",
            
            startsCombat = false,
            texture = 571556,
            
            handler = function ()
                applyBuff("rule_of_law")
            end,
        },
        

        seraphim = {
            id = 152262,
            cast = 0,
            cooldown = 45,
            gcd = "spell",
            
            spend = 3,
            spendType = "holy_power",
            
            startsCombat = false,
            texture = 1030103,
            
            handler = function ()
                applyBuff("seraphim")
            end,
        },
        

        shield_of_the_righteous = {
            id = 53600,
            cast = 0,
            cooldown = 1,
            gcd = "spell",
            
            spend = function ()
                if buff.divine_purpose.up then return 0 end
                return 3
            end,
            spendType = "holy_power",
            
            startsCombat = true,
            texture = 236265,
            
            handler = function ()
                applyBuff("shield_of_the_righteous")
            end,
        },
        

        turn_evil = {
            id = 10326,
            cast = 1.5,
            cooldown = 15,
            gcd = "spell",
            
            spend = 0.1,
            spendType = "mana",
            
            startsCombat = true,
            texture = 571559,
            
            handler = function ()
                applyDebuff("turn_evil")
            end,
        },
        

        tyrs_deliverance = {
            id = 200652,
            cast = 2,
            cooldown = 90,
            gcd = "spell",
            
            startsCombat = false,
            texture = 1122562,
            
            toggle = "cooldowns",

            handler = function ()
                applyBuff("tyrs_deliverance")
            end,
        },
        

        vanquishers_hammer = {
            id = 328204,
            cast = 0,
            charges = 2,
            cooldown = 30,
            recharge = 30,
            gcd = "spell",
            
            startsCombat = true,
            texture = 3578228,
            
            handler = function ()
                gain( buff.holy_avenger.up and 3 or 1, "holy_power" )
                applyBuff("vanquishers_hammer")
            end,
        },
        

        word_of_glory = {
            id = 85673,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = function ()
                if buff.divine_purpose.up then return 0 end
                return 3
            end,
            spendType = "holy_power",
            
            startsCombat = false,
            texture = 133192,
            
            handler = function ()
                removeBuff("divine_purpose")
            end,
        },
    } )

end