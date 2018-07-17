-- DruidBalance.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State


if UnitClassBase( 'player' ) == 'DRUID' then
    local spec = Hekili:NewSpecialization( 102 )

    spec:RegisterResource( Enum.PowerType.LunarPower )
    spec:RegisterResource( Enum.PowerType.Mana )

    spec:RegisterResource( Enum.PowerType.Rage )

    spec:RegisterResource( Enum.PowerType.Energy )
    spec:RegisterResource( Enum.PowerType.ComboPoints )
    
    -- Talents
    spec:RegisterTalents( {
        natures_balance = 22385, -- 202430
        warrior_of_elune = 22386, -- 202425
        force_of_nature = 22387, -- 205636

        tiger_dash = 19283, -- 252216
        renewal = 18570, -- 108238
        wild_charge = 18571, -- 102401

        feral_affinity = 22155, -- 202157
        guardian_affinity = 22157, -- 197491
        restoration_affinity = 22159, -- 197492

        mighty_bash = 21778, -- 5211
        mass_entanglement = 18576, -- 102359
        typhoon = 18577, -- 132469

        soul_of_the_forest = 18580, -- 114107
        starlord = 21706, -- 202345
        incarnation_chosen_of_elune = 21702, -- 102560

        stellar_drift = 22389, -- 202354
        twin_moons = 21712, -- 279620
        stellar_flare = 22165, -- 202347

        shooting_stars = 21648, -- 202342
        fury_of_elune = 21193, -- 202770
        new_moon = 21655, -- 274281
    } )

    -- PvP Talents
    spec:RegisterPvpTalents( { 
        adaptation = 3543, -- 214027
        relentless = 3542, -- 196029
        gladiators_medallion = 3541, -- 208683
        
        thorns = 3731, -- 236696
        protector_of_the_grove = 3728, -- 209730
        dying_stars = 822, -- 232546
        deep_roots = 834, -- 233755
        moonkin_aura = 185, -- 209740
        ironfeather_armor = 1216, -- 233752
        cyclone = 857, -- 209753
        faerie_swarm = 836, -- 209749
        moon_and_stars = 184, -- 233750
        celestial_downpour = 183, -- 200726
        crescent_burn = 182, -- 200567
        celestial_guardian = 180, -- 233754
        prickling_thorns = 3058, -- 200549
    } )

    -- Auras
    spec:RegisterAuras( {
        aquatic_form = {
            id = 276012,
        },
        astral_influence = {
            id = 197524,
        },
        barkskin = {
            id = 22812,
        },
        cat_form = {
            id = 768,
        },
        celestial_alignment = {
            id = 194223,
            duration = 15,
            max_stacks = 1,
        },
        dash = {
            id = 1850,
        },
        eclipse = {
            id = 279619,
        },
        empowerments = {
            id = 279708,
        },
        feline_swiftness = {
            id = 131768,
        },
        flight_form = {
            id = 276029,
        },
        frenzied_regeneration = {
            id = 22842,
        },
        fury_of_elune = {
            id = 202770,
            duration = 8,
            max_stacks = 1,
        },
        incarnation_chosen_of_elune = {
            id = 102560,
            duration = 30,
            max_stacks = 1,
        },
        ironfur = {
            id = 192081,
        },
        lunar_empowerment = {
            id = 164547,
            duration = 40,
            max_stacks = 3,
        },
        moonfire = {
            id = 164812,
            duration = 22,
            max_stack = 1,
        },
        moonkin_form = {
            id = 24858,
        },
        owlkin_frenzy = {
            id = 157228,
            duration = 10,
            max_stacks = 1,
        },
        solar_empowerment = {
            id = 164545,
            duration = 40,
            max_stacks = 3,
        },
        starfall = {
            id = 191034,
            duration = 8,
            max_stacks = 1,
        },
        starlord = {
            id = 279709,
            duration = 20,
            max_stacks = 3,
        },
        stellar_flare = {
            id = 202347,
            duration = 24,
            max_stacks = 1,
        },
        sunfire = {
            id = 164815,
            duration = 18,
            max_stack = 1,
        },
        thick_hide = {
            id = 16931,
        },
        tiger_dash = {
            id = 252216,
        },
        travel_form = {
            id = 783,
        },
        warrior_of_elune = {
            id = 202425,
            max_stack = 3,
        },
        wild_charge = {
            id = 102401,
        },
        yseras_gift = {
            id = 145108,
        },
        --[[
            Legion Legendaries and gear
        ]]
        oneths_overconfidence = {
            id = 209407,
            max_stacks = 1,
        },
        oneths_intuition = {
            id = 209406,
            max_stacks = 1,
        },
        solar_solstice = {
            id = 252767,
            duration = 6,
            max_stacks = 1,
        },
    } )

    -- Abilities
    spec:RegisterAbilities( {
        barkskin = {
            id = 22812,
            cast = 0,
            cooldown = 60,
            gcd = "spell",
            
            startsCombat = true,
            texture = 136097,
            
            handler = function ()
            end,
        },
        

        bear_form = {
            id = 5487,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            startsCombat = true,
            texture = 132276,
            
            handler = function ()
            end,
        },
        

        cat_form = {
            id = 768,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            startsCombat = true,
            texture = 132115,
            
            handler = function ()
            end,
        },
        

        celestial_alignment = {
            id = 194223,
            cast = 0,
            cooldown = 180,
            gcd = "spell",
            
            startsCombat = false,
            texture = 136060,
                
            toggle = 'cooldowns',
            notalent = 'incarnation',
            
            handler = function ()
                applyBuff( 'celestial_alignment' )
            end,
        },
        

        dash = {
            id = 1850,
            cast = 0,
            cooldown = 120,
            gcd = "spell",
            
            startsCombat = true,
            texture = 132120,
            
            handler = function ()
            end,
        },
        

        entangling_roots = {
            id = 339,
            cast = 1.7,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.1,
            spendType = "mana",
            
            startsCombat = true,
            texture = 136100,
            
            handler = function ()
            end,
        },
        

        ferocious_bite = {
            id = 22568,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = 25,
            spendType = "energy",
            
            startsCombat = true,
            texture = 132127,
            
            handler = function ()
            end,
        },
        

        force_of_nature = {
            id = 205636,
            cast = 0,
            cooldown = 60,
            gcd = "spell",
                
            spend = -20,
            spendType = 'astral_power',
            
            startsCombat = true,
            texture = 132129,
            
            handler = function ()
            end,
        },
        

        frenzied_regeneration = {
            id = 22842,
            cast = 0,
            charges = 1,
            cooldown = 36,
            recharge = 36,
            gcd = "spell",
            
            spend = 10,
            spendType = "rage",
            
            startsCombat = true,
            texture = 132091,
            
            handler = function ()
            end,
        },
        

        fury_of_elune = {
            id = 202770,
            cast = 0,
            cooldown = 60,
            gcd = "spell",
            
            startsCombat = true,
            texture = 132123,
            
            handler = function ()
                applyDebuff( 'target', 'fury_of_elune' )
            end,
        },
        

        growl = {
            id = 6795,
            cast = 0,
            cooldown = 8,
            gcd = "spell",
            
            startsCombat = true,
            texture = 132270,
            
            handler = function ()
            end,
        },
        

        hibernate = {
            id = 2637,
            cast = 1.5,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.15,
            spendType = "mana",
            
            startsCombat = true,
            texture = 136090,
            
            handler = function ()
            end,
        },
        

        incarnation_chosen_of_elune = {
            id = 102560,
            cast = 0,
            cooldown = 180,
            gcd = "spell",
            
            startsCombat = false,
            texture = 571586,
                
            toggle = 'cooldowns',
            talent = 'incarnation',
            
            handler = function ()
                applyBuff( 'incarnation' )
            end,
        },
        

        innervate = {
            id = 29166,
            cast = 0,
            cooldown = 180,
            gcd = "spell",
            
            startsCombat = true,
            texture = 136048,
            
            handler = function ()
            end,
        },
        

        ironfur = {
            id = 192081,
            cast = 0,
            cooldown = 0.5,
            gcd = "spell",
            
            spend = 45,
            spendType = "rage",
            
            startsCombat = true,
            texture = 1378702,
            
            handler = function ()
            end,
        },
        

        lunar_strike = {
            id = 194153,
            cast = function()
                return ( 2.25 * haste )
            end,
            cooldown = 0,
            gcd = "spell",
                
            spend = -12,
            spendType = 'astral_power',
            
            startsCombat = true,
            texture = 135753,
            
            handler = function ()
                removeStack( 'lunar_empowerment' )
            end,
        },
        

        mangle = {
            id = 33917,
            cast = 0,
            cooldown = 6,
            gcd = "spell",
            
            startsCombat = true,
            texture = 132135,
            
            handler = function ()
            end,
        },
        

        mass_entanglement = {
            id = 102359,
            cast = 0,
            cooldown = 30,
            gcd = "spell",
            
            startsCombat = true,
            texture = 538515,
            
            handler = function ()
            end,
        },
        

        mighty_bash = {
            id = 5211,
            cast = 0,
            cooldown = 50,
            gcd = "spell",
            
            startsCombat = true,
            texture = 132114,
            
            handler = function ()
            end,
        },
        

        moonfire = {
            id = 8921,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = -3,
            spendType = 'astral_power',
            
            startsCombat = true,
            texture = 136096,
            
            handler = function ()
                applyDebuff( "target", "moonfire" )
                --gain( 3, "astral_power" ) -- not convinced about this
            end,
        },
        

        moonkin_form = {
            id = 24858,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            startsCombat = false,
            texture = 136036,
            
            handler = function ()
                applyBuff( "moonkin_form" )
            end,
        },
        

        new_moon = {
            id = 274281,
            cast = 1,
            charges = 3,
            cooldown = 25,
            recharge = 25,
            gcd = "spell",
            
            startsCombat = true,
            texture = 1392545,
            
            handler = function ()
            end,
        },
        

        prowl = {
            id = 5215,
            cast = 0,
            cooldown = 6,
            gcd = "spell",
            
            startsCombat = true,
            texture = 514640,
            
            handler = function ()
            end,
        },
        

        rake = {
            id = 1822,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = 35,
            spendType = "energy",
            
            startsCombat = true,
            texture = 132122,
            
            handler = function ()
            end,
        },
        

        rebirth = {
            id = 20484,
            cast = 2,
            cooldown = 600,
            gcd = "spell",
            
            spend = 0,
            spendType = "rage",
            
            startsCombat = true,
            texture = 136080,
            
            handler = function ()
            end,
        },
        

        regrowth = {
            id = 8936,
            cast = 1.5,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.14,
            spendType = "mana",
            
            startsCombat = true,
            texture = 136085,
            
            handler = function ()
            end,
        },
        

        rejuvenation = {
            id = 774,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.1,
            spendType = "mana",
            
            startsCombat = true,
            texture = 136081,
            
            handler = function ()
            end,
        },
        

        remove_corruption = {
            id = 2782,
            cast = 0,
            cooldown = 8,
            gcd = "spell",
            
            spend = 0.06,
            spendType = "mana",
            
            startsCombat = true,
            texture = 135952,
            
            handler = function ()
            end,
        },
        

        renewal = {
            id = 108238,
            cast = 0,
            cooldown = 90,
            gcd = "spell",
            
            startsCombat = true,
            texture = 136059,
            
            handler = function ()
            end,
        },
        

        revive = {
            id = 50769,
            cast = 10,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.04,
            spendType = "mana",
            
            startsCombat = true,
            texture = 132132,
            
            handler = function ()
            end,
        },
        

        rip = {
            id = 1079,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = 30,
            spendType = "energy",
            
            startsCombat = true,
            texture = 132152,
            
            handler = function ()
            end,
        },
        

        shred = {
            id = 5221,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = 40,
            spendType = "energy",
            
            startsCombat = true,
            texture = 136231,
            
            handler = function ()
            end,
        },
        

        solar_beam = {
            id = 78675,
            cast = 0,
            cooldown = 60,
            gcd = "spell",
            
            spend = 0.17,
            spendType = "mana",
            
            startsCombat = true,
            texture = 252188,
            
            handler = function ()
            end,
        },
        

        solar_wrath = {
            id = 190984,
            cast = function()
                return ( 1.5 * haste )
            end,
            cooldown = 0,
            gcd = "spell",
                
            spend = -8,
            spendType = 'astral_power',
            
            startsCombat = true,
            texture = 535045,
            
            handler = function ()
                removeStack( 'solar_empowerment' )
            end,
        },
        

        soothe = {
            id = 2908,
            cast = 0,
            cooldown = 10,
            gcd = "spell",
            
            spend = 0.06,
            spendType = "mana",
            
            startsCombat = true,
            texture = 132163,
            
            handler = function ()
            end,
        },
        

        starfall = {
            id = 191034,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = function()
                if talent.stellar_drift.enabled then
                    return 40
                else
                    return 50
                end
            end,
            spendType = "astral_power",
            
            startsCombat = true,
            texture = 236168,
            
            handler = function ()
                applyBuff( 'starfall', 8 )
            end,
        },
        

        starsurge = {
            id = 78674,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = 40,
            spendType = "astral_power",
            
            startsCombat = true,
            texture = 135730,
            
            handler = function ()
                addStack( 'solar_empowerment', 40, 1 )
                addStack( 'lunar_empowerment', 40, 1 )
            end,
        },
        

        stellar_flare = {
            id = 202347,
            cast = function()
                return 1.5 * haste
            end,
            cooldown = 0,
            gcd = "spell",
                
            spend = -8,
            spendType = 'astral_power',
            
            startsCombat = true,
            texture = 1052602,
            
            handler = function ()
                applyDebuff( 'target', 'stellar_flare' )
            end,
        },
        

        sunfire = {
            id = 93402,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = -3,
            spendType = 'astral_power',
            
            startsCombat = true,
            texture = 236216,
            
            handler = function ()
                applyDebuff( 'target', 'sunfire' )
            end,
        },
        

        swiftmend = {
            id = 18562,
            cast = 0,
            charges = 1,
            cooldown = 25,
            recharge = 25,
            gcd = "spell",
            
            spend = 0.14,
            spendType = "mana",
            
            startsCombat = true,
            texture = 134914,
            
            handler = function ()
            end,
        },
        

        swipe = {
            id = 213764,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            startsCombat = true,
            texture = 134296,
            
            handler = function ()
            end,
        },
        

        teleport_moonglade = {
            id = 18960,
            cast = 10,
            cooldown = 0,
            gcd = "spell",
            
            spend = 4,
            spendType = "mana",
            
            startsCombat = true,
            texture = 135758,
            
            handler = function ()
            end,
        },
        

        thrash_bear = {
            id = 106832,
            suffix = "(Bear)",
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            startsCombat = true,
            texture = 451161,
            
            handler = function ()
            end,
        },
        

        tiger_dash = {
            id = 252216,
            cast = 0,
            cooldown = 45,
            gcd = "spell",
            
            startsCombat = true,
            texture = 1817485,
            
            handler = function ()
            end,
        },
        

        travel_form = {
            id = 783,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            startsCombat = true,
            texture = 132144,
            
            handler = function ()
            end,
        },
        

        typhoon = {
            id = 132469,
            cast = 0,
            cooldown = 30,
            gcd = "spell",
            
            startsCombat = true,
            texture = 236170,
            
            handler = function ()
            end,
        },
        

        warrior_of_elune = {
            id = 202425,
            cast = 0,
            cooldown = 45,
            gcd = "spell",
            
            startsCombat = false,
            texture = 135900,
            
            handler = function ()
                applyBuff( 'warrior_of_elune' )
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
        

        wild_charge = {
            id = 102401,
            cast = 0,
            cooldown = 15,
            gcd = "spell",
            
            startsCombat = true,
            texture = 538771,
            
            handler = function ()
            end,
        },
        

        wild_growth = {
            id = 48438,
            cast = 1.5,
            cooldown = 10,
            gcd = "spell",
            
            spend = 0.3,
            spendType = "mana",
            
            startsCombat = true,
            texture = 236153,
            
            handler = function ()
            end,
        },
    } )


    spec:RegisterOptions( {
        enabled = true,

        aoe = 3,
    
        nameplates = false,
        nameplateRange = 8,
        
        damage = true,
        damageExpiration = 6,
    
        package = nil,
    } )

end