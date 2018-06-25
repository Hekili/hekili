-- DemonHunterHavoc.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State


if UnitClassBase( 'player' ) == 'DEMONHUNTER' then
    local spec = Hekili:NewSpecialization( 581 )

    spec:RegisterResource( Enum.PowerType.Pain )
    
    -- Talents
    spec:RegisterTalents( {
        abyssal_strike = 22502, -- 207550
        agonizing_flames = 22503, -- 207548
        razor_spikes = 22504, -- 209400

        feast_of_souls = 22505, -- 207697
        fallout = 22766, -- 227174
        burning_alive = 22507, -- 207739

        flame_crash = 22324, -- 227322
        charred_flesh = 22541, -- 264002
        felblade = 22540, -- 232893

        soul_rending = 22508, -- 217996
        feed_the_demon = 22509, -- 218612
        fracture = 22770, -- 263642

        concentrated_sigils = 22546, -- 207666
        quickened_sigils = 22510, -- 209281
        sigil_of_chains = 22511, -- 202138

        gluttony = 22512, -- 264004
        spirit_bomb = 22513, -- 247454
        fel_devastation = 22768, -- 212084

        last_resort = 22543, -- 209258
        void_reaver = 22548, -- 268175
        soul_barrier = 21902, -- 263648
    } )

    -- PvP Talents
    spec:RegisterPvpTalents( { 
        gladiators_medallion = 3544, -- 208683
        relentless = 3545, -- 196029
        adaptation = 3546, -- 214027
        
        everlasting_hunt = 815, -- 205626
        cleansed_by_flame = 814, -- 205625
        jagged_spikes = 816, -- 205627
        illidans_grasp = 819, -- 205630
        tormentor = 1220, -- 207029
        sigil_mastery = 1948, -- 211489
        unending_hatred = 3727, -- 213480
        solitude = 802, -- 211509
        demonic_trample = 3423, -- 205629
        reverse_magic = 3429, -- 205604
        detainment = 3430, -- 205596
    } )

    -- Auras
    spec:RegisterAuras( {
        chaos_brand = {
            id = 281242,
        },
        demonic_wards = {
            id = 203513,
        },
        double_jump = {
            id = 196055,
        },
        fel_devastation = {
            id = 212084,
        },
        glide = {
            id = 131347,
        },
        immolation_aura = {
            id = 178740,
        },
        shattered_souls = {
            id = 204254,
        },
        soul_barrier = {
            id = 263648,
        },
        spectral_sight = {
            id = 188501,
        },
        spirit_bomb = {
            id = 247454,
        },
    } )

    -- Abilities
    spec:RegisterAbilities( {
        consume_magic = {
            id = 278326,
            cast = 0,
            cooldown = 10,
            gcd = "spell",
            
            startsCombat = true,
            texture = 828455,
            
            handler = function ()
            end,
        },
        

        demon_spikes = {
            id = 203720,
            cast = 0,
            charges = 2,
            cooldown = 20,
            recharge = 20,
            gcd = "spell",
            
            startsCombat = true,
            texture = 1344645,
            
            handler = function ()
            end,
        },
        

        disrupt = {
            id = 183752,
            cast = 0,
            cooldown = 15,
            gcd = "spell",
            
            startsCombat = true,
            texture = 1305153,
            
            handler = function ()
            end,
        },
        

        fel_devastation = {
            id = 212084,
            cast = 0,
            cooldown = 60,
            gcd = "spell",
            
            toggle = "cooldowns",

            startsCombat = true,
            texture = 1450143,
            
            handler = function ()
            end,
        },
        

        felblade = {
            id = 232893,
            cast = 0,
            cooldown = 15,
            gcd = "spell",
            
            startsCombat = true,
            texture = 1344646,
            
            handler = function ()
            end,
        },
        

        fiery_brand = {
            id = 204021,
            cast = 0,
            cooldown = 60,
            gcd = "spell",
            
            toggle = "cooldowns",

            startsCombat = true,
            texture = 1344647,
            
            handler = function ()
            end,
        },
        

        fracture = {
            id = 263642,
            cast = 0,
            charges = 2,
            cooldown = 4.5,
            recharge = 4.5,
            gcd = "spell",
            
            startsCombat = true,
            texture = 1388065,
            
            handler = function ()
            end,
        },
        

        glide = {
            id = 131347,
            cast = 0,
            cooldown = 1.5,
            gcd = "spell",
            
            startsCombat = true,
            texture = 1305157,
            
            handler = function ()
            end,
        },
        

        immolation_aura = {
            id = 178740,
            cast = 0,
            cooldown = 15,
            gcd = "spell",
            
            startsCombat = true,
            texture = 1344649,
            
            handler = function ()
            end,
        },
        

        imprison = {
            id = 217832,
            cast = 0,
            cooldown = 45,
            gcd = "spell",
            
            startsCombat = true,
            texture = 1380368,
            
            handler = function ()
            end,
        },
        

        infernal_strike = {
            id = 189110,
            cast = 0,
            charges = 2,
            cooldown = 12,
            recharge = 12,
            gcd = "spell",
            
            startsCombat = true,
            texture = 1344650,
            
            handler = function ()
            end,
        },
        

        metamorphosis = {
            id = 187827,
            cast = 0,
            cooldown = 180,
            gcd = "spell",
            
            toggle = "cooldowns",

            startsCombat = true,
            texture = 1247263,
            
            handler = function ()
            end,
        },
        

        shear = {
            id = 203782,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            startsCombat = true,
            texture = 1344648,
            
            handler = function ()
            end,
        },
        

        sigil_of_chains = {
            id = 202138,
            cast = 0,
            cooldown = 90,
            gcd = "spell",
            
            toggle = "cooldowns",

            startsCombat = true,
            texture = 1418286,
            
            handler = function ()
            end,
        },
        

        sigil_of_flame = {
            id = 204513,
            cast = 0,
            cooldown = 30,
            gcd = "spell",
            
            startsCombat = true,
            texture = 1344652,
            
            handler = function ()
            end,
        },
        

        sigil_of_misery = {
            id = 202140,
            cast = 0,
            cooldown = 60,
            gcd = "spell",
            
            toggle = "cooldowns",

            startsCombat = true,
            texture = 1418287,
            
            handler = function ()
            end,
        },
        

        sigil_of_silence = {
            id = 207682,
            cast = 0,
            cooldown = 60,
            gcd = "spell",
            
            toggle = "cooldowns",

            startsCombat = true,
            texture = 1418288,
            
            handler = function ()
            end,
        },
        

        soul_barrier = {
            id = 263648,
            cast = 0,
            cooldown = 30,
            gcd = "spell",
            
            startsCombat = true,
            texture = 2065625,
            
            handler = function ()
            end,
        },
        

        soul_cleave = {
            id = 228477,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = 30,
            spendType = "pain",
            
            startsCombat = true,
            texture = 1344653,
            
            handler = function ()
            end,
        },
        

        spectral_sight = {
            id = 188501,
            cast = 0,
            cooldown = 30,
            gcd = "spell",
            
            startsCombat = true,
            texture = 1247266,
            
            handler = function ()
            end,
        },
        

        spirit_bomb = {
            id = 247454,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = 30,
            spendType = "pain",
            
            startsCombat = true,
            texture = 1097742,
            
            handler = function ()
            end,
        },
        

        throw_glaive = {
            id = 204157,
            cast = 0,
            cooldown = 3,
            gcd = "spell",
            
            startsCombat = true,
            texture = 1305159,
            
            handler = function ()
            end,
        },
        

        torment = {
            id = 185245,
            cast = 0,
            cooldown = 8,
            gcd = "spell",
            
            startsCombat = true,
            texture = 1344654,
            
            handler = function ()
            end,
        },
        

        wartime_ability = {
            id = 264739,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            startsCombat = true,
            texture = 1518639,
            
            handler = function ()
            end,
        },
    } )


    spec:RegisterOptions( {
        enabled = false,

        aoe = 2,
    
        nameplates = true,
        nameplateRange = 8,
        
        damage = true,
        damageExpiration = 8,
    
        package = nil,
    } )
end
