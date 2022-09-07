-- EvokerPreservation.lua
-- September 2022

local addon, ns = ...
local Hekili = _G[ addon ]

if not Hekili.IsDragonflight() then return end

local class = Hekili.Class
local state = Hekili.State

if UnitClassBase( 'player' ) == 'EVOKER' then
    local spec = Hekili:NewSpecialization( 1468 )

    spec:RegisterResource( Enum.PowerType.Essence )
    spec:RegisterResource( Enum.PowerType.Mana, {
        disintegrate = {
            channel = "disintegrate",
            talent = "energy_loop",

            last = function ()
                local app = state.buff.casting.applied
                local t = state.query_time

                return app + floor( ( t - app ) / class.auras.disintegrate.tick_time ) * class.auras.disintegrate.tick_time
            end,

            interval = function () return class.auras.disintegrate.tick_time end,
            value = function () return 0.024 * mana.max end, -- TODO: Check if should be modmax.
        }
    } )

    -- Talents
    spec:RegisterTalents( {
        aerial_mastery = { 40374, 365933 }, -- 450
        ancient_flame = { 40372, 369990 }, -- 450
        attuned_to_the_dream = { 40363, 376930 }, -- 450
        blast_furnace = { 40383, 375510 }, -- 450
        borrowed_time = { 40407, 376210 }, -- 450
        bountiful_bloom = { 40362, 370886 }, -- 450
        call_of_ysera = { 40420, 373834 }, -- 450
        cauterizing_flame = { 40364, 374251 }, -- 450
        clobbering_sweep = { 40365, 375443 }, -- 450
        cycle_of_life = { 40423, 371832 }, -- 450
        delay_harm = { 40424, 376207 }, -- 450
        draconic_legacy = { 40394, 376166 }, -- 450
        dream_breath = { 40429, 355936 }, -- 450
        dream_flight = { 40398, 359816 }, -- 450
        dreamwalker = { 40433, 377082 }, -- 450
        echo = { 40428, 364343 }, -- 450
        emerald_communion = { 40432, 370960 }, -- 450
        empath = { 40397, 376138 }, -- 450
        energy_loop = { 40406, 372233 }, -- 450
        enkindled = { 40369, 375554 }, -- 450
        essence_attunement = { 40418, 375722 }, -- 450
        essence_burst = { 40416, 369297 }, -- 450
        exhilarating_burst = { 40403, 377100 }, -- 450
        expunge = { 40389, 365585 }, -- 450
        extended_flight = { 40371, 375517 }, -- 450
        exuberance = { 40376, 375542 }, -- 450
        field_of_dreams = { 40402, 370062 }, -- 450
        fire_within = { 40357, 375577 }, -- 450
        flow_state = { 40410, 385696 }, -- 450
        fluttering_seedlings = { 40404, 359793 }, -- 450
        fly_with_me = { 40373, 370665 }, -- 450
        font_of_magic = { 40421, 375783 }, -- 450
        forger_of_mountains = { 40352, 375528 }, -- 450
        golden_hour = { 40415, 378196 }, -- 450
        grace_period = { 40422, 376239 }, -- 450
        grovetenders_gift = { 40361, 387761 }, -- 450
        heavy_wingbeats = { 40365, 368838 }, -- 450
        innate_magic = { 40392, 375520 }, -- 450
        just_in_time = { 40424, 376204 }, -- 450
        landslide = { 40390, 358385 }, -- 450
        leaping_flames = { 40385, 369939 }, -- 450
        life_givers_flame = { 40417, 371426 }, -- 450
        lifebind = { 40434, 373270 }, -- 450
        lifeforce_mender = { 40419, 376179 }, -- 450
        lush_growth = { 40354, 375561 }, -- 450
        natural_convergence = { 40391, 369913 }, -- 450
        nozdormus_teachings = { 40412, 376237 }, -- 450
        obsidian_bulwark = { 40366, 375406 }, -- 450
        obsidian_scales = { 40367, 363916 }, -- 450
        oppressing_roar = { 40377, 372048 }, -- 450
        ouroboros = { 40401, 381921 }, -- 450
        overawe = { 40378, 374346 }, -- 450
        permeating_chill = { 40368, 370897 }, -- 450
        power_nexus = { 40399, 369908 }, -- 450
        protracted_talons = { 40384, 369909 }, -- 450
        pyrexia = { 40357, 375574 }, -- 450
        quell = { 40381, 351338 }, -- 450
        recall = { 40393, 371806 }, -- 450
        regenerative_magic = { 40349, 387787 }, -- 450
        renewing_blaze = { 40358, 374348 }, -- 450
        renewing_breath = { 40400, 371257 }, -- 450
        rescue = { 40388, 360995 }, -- 450
        resonating_sphere = { 40412, 376236 }, -- 450
        reversion = { 40427, 366155 }, -- 450
        rewind = { 40426, 363534 }, -- 450
        roar_of_exhilaration = { 40380, 375507 }, -- 450
        rush_of_vitality = { 40433, 377086 }, -- 450
        sacral_empowerment = { 40435, 377099 }, -- 450
        scarlet_adaptation = { 40387, 372469 }, -- 450
        sleep_walk = { 40360, 360806 }, -- 450
        source_of_magic = { 40375, 369459 }, -- 450
        spiritbloom = { 40431, 367226 }, -- 450
        spiritual_clarity = { 40397, 376150 }, -- 450
        stasis = { 40405, 370537 }, -- 450
        suffused_with_power = { 40382, 376164 }, -- 450
        tailwind = { 40370, 375556 }, -- 450
        tempered_scales = { 40396, 375544 }, -- 450
        temporal_anomaly = { 40411, 373861 }, -- 450
        temporal_artificer = { 40407, 381922 }, -- 450
        temporal_compression = { 40430, 362874 }, -- 450
        terror_of_the_skies = { 40386, 371032 }, -- 450
        time_dilation = { 40425, 357170 }, -- 450
        time_keeper = { 40409, 371270 }, -- 450
        time_lord = { 40414, 372527 }, -- 450
        time_of_need = { 40413, 368412 }, -- 450
        time_spiral = { 40353, 374968 }, -- 450
        timeless_magic = { 40408, 376240 }, -- 450
        tip_the_scales = { 40395, 370553 }, -- 450
        twin_guardian = { 40355, 370888 }, -- 450
        unravel = { 40379, 368432 }, -- 450
        walloping_blow = { 40359, 387341 }, -- 450
        zephyr = { 40356, 374227 }, -- 450
    } )

    -- PvP Talents
    spec:RegisterPvpTalents( {
        divide_and_conquer = 5472, -- 384689
        unburdened_flight = 5470, -- 378437
        nullifying_shroud = 5468, -- 378464
        youre_coming_with_me = 5465, -- 370388
        time_stop = 5463, -- 378441
        scouring_flame = 5461, -- 378438
        precognition = 5502, -- 377360
        obsidian_mettle = 5459, -- 378444
        chrono_loop = 5455, -- 383005
        dream_projection = 5454, -- 377509
    } )

    -- Auras
    spec:RegisterAuras( {
        deep_breath = {
            id = 357210,
        },
        fire_breath = {
            id = 357208,
        },
        hover = {
            id = 358267,
        },
        sign_of_the_skirmisher = {
            id = 186401,
            duration = 3600,
            max_stack = 1,
        },
    } )

    -- Abilities
    spec:RegisterAbilities( {
        azure_strike = {
            id = 362969,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 0.01,
            spendType = "mana",

            startsCombat = true,
            texture = 4622447,

            handler = function ()
            end,
        },


        blessing_of_the_bronze = {
            id = 364342,
            cast = 0,
            cooldown = 15,
            gcd = "spell",

            spend = 0.04,
            spendType = "mana",

            startsCombat = true,
            texture = 4622448,

            handler = function ()
            end,
        },


        deep_breath = {
            id = 357210,
            cast = 0,
            cooldown = 120,
            gcd = "spell",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 4622450,

            handler = function ()
            end,
        },


        disintegrate = {
            id = 356995,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 3,
            spendType = "essence",

            startsCombat = true,
            texture = 4622451,

            handler = function ()
            end,
        },


        emerald_blossom = {
            id = 355913,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            spend = 3,
            spendType = "essence",

            startsCombat = true,
            texture = 4622457,

            handler = function ()
            end,
        },


        fire_breath = {
            id = 357208,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            spend = 0.03,
            spendType = "mana",

            startsCombat = true,
            texture = 4622458,

            handler = function ()
            end,
        },


        fury_of_the_aspects = {
            id = 390386,
            cast = 0,
            cooldown = 300,
            gcd = "spell",

            spend = 0.04,
            spendType = "mana",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 4622462,

            handler = function ()
            end,
        },


        hover = {
            id = 358267,
            cast = 0,
            cooldown = 35,
            gcd = "spell",

            startsCombat = true,
            texture = 4622463,

            handler = function ()
            end,
        },


        living_flame = {
            id = 361469,
            cast = 2,
            cooldown = 0,
            gcd = "spell",

            spend = 0.02,
            spendType = "mana",

            startsCombat = true,
            texture = 4622464,

            handler = function ()
            end,
        },


        mass_return = {
            id = 361178,
            cast = 10,
            cooldown = 0,
            gcd = "spell",

            spend = 0.01,
            spendType = "mana",

            startsCombat = true,
            texture = 4622473,

            handler = function ()
            end,
        },


        naturalize = {
            id = 360823,
            cast = 0,
            cooldown = 8,
            gcd = "spell",

            spend = 0.01,
            spendType = "mana",

            startsCombat = true,
            texture = 4630445,

            handler = function ()
            end,
        },


        ph_pocopoc_zone_ability_skill = {
            id = 363942,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = true,
            texture = 4239318,

            handler = function ()
            end,
        },


        ["return"] = {
            id = 361227,
            cast = 10,
            cooldown = 0,
            gcd = "spell",

            spend = 0.01,
            spendType = "mana",

            startsCombat = true,
            texture = 4622472,

            handler = function ()
            end,

            copy = "action_return"
        },
    } )
end