-- DruidBalance.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State


if UnitClassBase( 'player' ) == 'DRUID' then
    local spec = Hekili:NewSpecialization( 102 )

    spec:RegisterResource( Enum.PowerType.LunarPower, {
        fury_of_elune = {            
            aura = "fury_of_elune_ap",

            last = function ()
                local app = state.buff.fury_of_elune_ap.applied
                local t = state.query_time

                return app + floor( ( t - app ) / 0.5 ) * 0.5
            end,

            interval = 0.5,
            value = 2.5
        }
    } )


    spec:RegisterResource( Enum.PowerType.Mana )
    spec:RegisterResource( Enum.PowerType.Energy )
    spec:RegisterResource( Enum.PowerType.ComboPoints )
    spec:RegisterResource( Enum.PowerType.Rage )
    
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
        incarnation = 21702, -- 102560

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

    
    spec:RegisterPower( "lively_spirit", 279642, {
        id = 279648,
        duration = 20,
        max_stack = 1,
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
            duration = 12,
            max_stack = 1,
        },
        bear_form = {
            id = 5487,
            duration = 3600,
            max_stack = 1,
        },
        blessing_of_cenarius = {
            id = 238026,
            duration = 60,
            max_stack = 1,
        },
        blessing_of_the_ancients = {
            id = 206498,
            duration = 3600,
            max_stack = 1,
        },
        cat_form = {
            id = 768,
            duration = 3600,
            max_stack = 1,
        },
        celestial_alignment = {
            id = 194223,
            duration = 20,
            max_stack = 1,
        },
        dash = {
            id = 1850,
            duration = 10,
            max_stack = 1,
        },
        eclipse = {
            id = 279619,
        },
        empowerments = {
            id = 279708,
        },
        entangling_roots = {
            id = 339,
            duration = 30,
            type = "Magic",
            max_stack = 1,
        },
        feline_swiftness = {
            id = 131768,
        },
        flask_of_the_seventh_demon = {
            id = 188033,
            duration = 3600.006,
            max_stack = 1,
        },
        flight_form = {
            id = 276029,
        },
        force_of_nature = {
            id = 205644,
            duration = 15,
            max_stack = 1,
        },
        frenzied_regeneration = {
            id = 22842,
            duration = 3,
            max_stack = 1,
        },
        fury_of_elune_ap = {
            id = 202770,
            duration = 8,
            max_stack = 1,
    
            generate = function ()
                local foe = buff.fury_of_elune_ap
                local applied = action.fury_of_elune.lastCast
    
                if applied and now - applied < 8 then
                    foe.count = 1
                    foe.expires = applied + 8
                    foe.applied = applied
                    foe.caster = "player"
                    return
                end
    
                foe.count = 0
                foe.expires = 0
                foe.applied = 0
                foe.caster = "nobody"
            end,
        },
        growl = {
            id = 6795,
            duration = 3,
            max_stack = 1,
        },
        incarnation = {
            id = 102560,
            duration = 30,
            max_stack = 1,
            copy = "incarnation_chosen_of_elune"
        },
        ironfur = {
            id = 192081,
            duration = 7,
            max_stack = 1,
        },
        legionfall_commander = {
            id = 233641,
            duration = 3600,
            max_stack = 1,
        },
        lunar_empowerment = {
            id = 164547,
            duration = 45,
            type = "Magic",
            max_stack = 3,
        },
        mana_divining_stone = {
            id = 227723,
            duration = 3600,
            max_stack = 1,
        },
        mass_entanglement = {
            id = 102359,
            duration = 30,
            type = "Magic",
            max_stack = 1,
        },
        mighty_bash = {
            id = 5211,
            duration = 5,
            max_stack = 1,
        },
        moonfire = {
            id = 164812,
            duration = 22,
            type = "Magic",
            max_stack = 1,
        },
        moonkin_form = {
            id = 24858,
            duration = 3600,
            max_stack = 1,
        },
        prowl = {
            id = 5215,
            duration = 3600,
            max_stack = 1,
        },
        regrowth = {
            id = 8936,
            duration = 12,
            type = "Magic",
            max_stack = 1,
        },
        shadowmeld = {
            id = 58984,
            duration = 3600,
            max_stack = 1,
        },
        sign_of_the_critter = {
            id = 186406,
            duration = 3600,
            max_stack = 1,
        },
        solar_beam = {
            id = 81261,
            duration = 3600,
            max_stack = 1,
        },
        solar_empowerment = {
            id = 164545,
            duration = 45,
            type = "Magic",
            max_stack = 3,
        },
        stag_form = {
            id = 210053,
            duration = 3600,
            max_stack = 1,
            generate = function ()
                local form = GetShapeshiftForm()
                local stag = form and form > 0 and select( 4, GetShapeshiftFormInfo( form ) )
                
                local sf = buff.stag_form

                if stag == 210053 then
                    sf.count = 1
                    sf.applied = now
                    sf.expires = now + 3600
                    sf.caster = "player"
                    return
                end

                sf.count = 0
                sf.applied = 0
                sf.expires = 0
                sf.caster = "nobody"
            end,
        },
        starfall = {
            id = 191034,
            duration = 8,
            max_stack = 1,

            generate = function ()
                local sf = buff.starfall

                if now - action.starfall.lastCast < 8 then
                    sf.count = 1
                    sf.applied = action.starfall.lastCast
                    sf.expires = sf.applied + 8
                    sf.caster = "player"
                    return
                end

                sf.count = 0
                sf.applied = 0
                sf.expires = 0
                sf.caster = "nobody"
            end
        },
        starlord = {
            id = 279709,
            duration = 20,
            max_stack = 3,
        },
        stellar_drift = {
            id = 202461,
            duration = 3600,
            max_stack = 1,
        },
        stellar_flare = {
            id = 202347,
            duration = 24,
            type = "Magic",
            max_stack = 1,
        },
        sunfire = {
            id = 164815,
            duration = 20.685,
            type = "Magic",
            max_stack = 1,
        },
        thick_hide = {
            id = 16931,
        },
        thorny_entanglement = {
            id = 241750,
            duration = 15,
            max_stack = 1,
        },
        thrash_bear = {
            id = 192090,
            duration = 15,
            max_stack = 3,
        },
        thrash_cat ={
            id = 106830, 
            duration = function()
                local x = 15 -- Base duration
                return talent.jagged_wounds.enabled and x * 0.80 or x
            end,
            tick_time = function()
                local x = 3 -- Base tick time
                return talent.jagged_wounds.enabled and x * 0.80 or x
            end,
        },
        --[[ thrash = {
            id = function ()
                if buff.cat_form.up then return 106830 end
                return 192090
            end,
            duration = function()
                local x = 15 -- Base duration
                return talent.jagged_wounds.enabled and x * 0.80 or x
            end,
            tick_time = function()
                local x = 3 -- Base tick time
                return talent.jagged_wounds.enabled and x * 0.80 or x
            end,
        }, ]]
        tiger_dash = {
            id = 252216,
            duration = 5,
            max_stack = 1,
        },
        travel_form = {
            id = 783,
            duration = 3600,
            max_stack = 1,
        },
        treant_form = {
            id = 114282,
            duration = 3600,
            max_stack = 1,
        },
        typhoon = {
            id = 61391,
            duration = 6,
            type = "Magic",
            max_stack = 1,
        },
        warrior_of_elune = {
            id = 202425,
            duration = 3600,
            type = "Magic",
            max_stack = 3,
        },
        wild_charge = {
            id = 102401,
        },
        yseras_gift = {
            id = 145108,
        },
    } )


    spec:RegisterStateFunction( "break_stealth", function ()
        removeBuff( "shadowmeld" )
        if buff.prowl.up then
            setCooldown( "prowl", 6 )
            removeBuff( "prowl" )
        end
    end )


    -- Function to remove any form currently active.
    spec:RegisterStateFunction( "unshift", function()
        removeBuff( "cat_form" )
        removeBuff( "bear_form" )
        removeBuff( "travel_form" )
        removeBuff( "moonkin_form" )
        removeBuff( "travel_form" )
        removeBuff( "aquatic_form" )
        removeBuff( "stag_form" )
    end )
    

    -- Function to apply form that is passed into it via string.
    spec:RegisterStateFunction( "shift", function( form )
        removeBuff( "cat_form" )
        removeBuff( "bear_form" )
        removeBuff( "travel_form" )
        removeBuff( "moonkin_form" )
        removeBuff( "travel_form" )
        removeBuff( "aquatic_form" )
        removeBuff( "stag_form" )
        applyBuff( form )
    end )


    spec:RegisterHook( "runHandler", function( ability )
        local a = class.abilities[ ability ]
    
        if not a or a.startsCombat then
            break_stealth()
        end 
    end )


    -- Need hook for SPELL_CAST_SUCCESS to update the real value here.
    spec:RegisterStateExpr( "active_moon", function ()
        return "new_moon"
    end )


    spec:RegisterHook( "reset_precast", function ()
        active_moon = nil
    end )


    spec:RegisterHook( "spend", function( amt, resource )
        if level < 116 and equipped.impeccable_fel_essence and resource == "astral_power" and cooldown.celestial_alignment.remains > 0 then
            setCooldown( "celestial_alignment", max( 0, cooldown.celestial_alignment.remains - ( amt / 12 ) ) )
        end 
    end )


    -- Legion Sets (for now).
    spec:RegisterGear( 'tier21', 152127, 152129, 152125, 152124, 152126, 152128 )
        spec:RegisterAura( 'solar_solstice', {
            id = 252767,
            duration = 6,
            max_stack = 1,
         } ) 

    spec:RegisterGear( 'tier20', 147136, 147138, 147134, 147133, 147135, 147137 )
    spec:RegisterGear( 'tier19', 138330, 138336, 138366, 138324, 138327, 138333 )
    spec:RegisterGear( 'class', 139726, 139728, 139723, 139730, 139725, 139729, 139727, 139724 )

    spec:RegisterGear( "impeccable_fel_essence", 137039 )    
    spec:RegisterGear( "oneths_intuition", 137092 )
        spec:RegisterAuras( {
            oneths_intuition = {
                id = 209406,
                duration = 3600,
                max_stacks = 1,
            },    
            oneths_overconfidence = {
                id = 209407,
                duration = 3600,
                max_stacks = 1,
            },
        } )

    spec:RegisterGear( "radiant_moonlight", 151800 )
    spec:RegisterGear( "the_emerald_dreamcatcher", 137062 )
        spec:RegisterAura( "the_emerald_dreamcatcher", {
            id = 224706,
            duration = 5,
            max_stack = 2,
        } )



    -- Abilities
    spec:RegisterAbilities( {
        barkskin = {
            id = 22812,
            cast = 0,
            cooldown = 60,
            gcd = "off",
            
            toggle = "defensives",
            defensive = true,

            startsCombat = false,
            texture = 136097,
            
            handler = function ()
                applyBuff( "barkskin" )
            end,
        },
        

        bear_form = {
            id = 5487,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            startsCombat = false,
            texture = 132276,

            noform = "bear_form",
            
            handler = function ()
                shift( "bear_form" )
            end,
        },
        

        cat_form = {
            id = 768,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            startsCombat = false,
            texture = 132115,

            noform = "cat_form",
            
            handler = function ()
                shift( "cat_form" )
            end,
        },
        

        celestial_alignment = {
            id = 194223,
            cast = 0,
            cooldown = 180,
            gcd = "spell",
            
            toggle = "cooldowns",

            startsCombat = true,
            texture = 136060,

            notalent = "incarnation",
            
            handler = function ()
                applyBuff( "celestial_alignment" )
            end,
        },
        

        dash = {
            id = 1850,
            cast = 0,
            cooldown = 120,
            gcd = "off",
            
            startsCombat = false,
            texture = 132120,

            notalent = "tiger_dash",
            
            handler = function ()
                if not buff.cat_form.up then
                    shift( "cat_form" )
                end
                applyBuff( "dash" )
            end,
        },
        

        --[[ dreamwalk = {
            id = 193753,
            cast = 10,
            cooldown = 60,
            gcd = "spell",
            
            spend = 4,
            spendType = "mana",
            
            toggle = "cooldowns",

            startsCombat = true,
            texture = 135763,
            
            handler = function ()
            end,
        }, ]]
        

        entangling_roots = {
            id = 339,
            cast = 1.7,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.18,
            spendType = "mana",
            
            startsCombat = false,
            texture = 136100,
            
            handler = function ()
                applyDebuff( "target", "entangling_roots" )
            end,
        },
        

        ferocious_bite = {
            id = 22568,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = 50,
            spendType = "energy",
            
            startsCombat = true,
            texture = 132127,

            form = "cat_form",
            
            usable = function () return combo_points.current > 0 end,
            handler = function ()
                if target.health.pct < 25 and debuff.rip.up then
                    applyDebuff( "target", "rip", min( debuff.rip.duration * 1.3, debuff.rip.remains + debuff.rip.duration ) )
                end
                spend( combo_points.current, "combo_points" )
            end,
        },
        

        --[[ flap = {
            id = 164862,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            startsCombat = true,
            texture = 132925,
            
            handler = function ()
            end,
        }, ]]
        

        force_of_nature = {
            id = 205636,
            cast = 0,
            cooldown = 60,
            gcd = "spell",
            
            spend = -20,
            spendType = "astral_power",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 132129,

            talent = "force_of_nature",
            
            handler = function ()
                summonPet( "treants", 10 )
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
            
            startsCombat = false,
            texture = 132091,

            form = "bear_form",
            talent = "guardian_affinity",
            
            handler = function ()
                applyBuff( "frenzied_regeneration" )
                gain( 0.08 * health.max, "health" )
            end,
        },
        

        full_moon = {
            id = 274283,
            cast = 3,
            charges = 3,
            cooldown = 25,
            recharge = 25,
            gcd = "spell",
            
            spend = -40,
            spendType = "astral_power",

            startsCombat = true,

            talent = "new_moon",
            bind = "half_moon",
            
            usable = function () return active_moon == "full_moon" end,
            handler = function ()
                spendCharges( "new_moon", 1 )
                spendCharges( "half_moon", 1 )

                -- Radiant Moonlight, NYI.
                active_moon = "new_moon"
            end,
        },
        

        fury_of_elune = {
            id = 202770,
            cast = 0,
            cooldown = 60,
            gcd = "spell",
            
            toggle = "cooldowns",

            startsCombat = true,
            texture = 132123,
            
            handler = function ()
                if not buff.moonkin_form.up then unshift() end
                applyDebuff( "target", "fury_of_elune" )
            end,
        },
        

        growl = {
            id = 6795,
            cast = 0,
            cooldown = 8,
            gcd = "off",
            
            startsCombat = true,
            texture = 132270,

            form = "bear_form",
            
            handler = function ()
                applyDebuff( "target", "growl" )
            end,
        },
        

        half_moon = {
            id = 274282,
            cast = 2,
            charges = 3,
            cooldown = 25,
            recharge = 25,
            gcd = "spell",

            spend = -20,
            spendType = "astral_power",
            
            startsCombat = true,
            texture = 1392543,

            talent = "new_moon",
            bind = "new_moon",
            
            handler = function ()
                spendCharges( "new_moon", 1 )
                spendCharges( "full_moon", 1 )

                active_moon = "full_moon"
            end,
        },
        

        hibernate = {
            id = 2637,
            cast = 1.5,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.15,
            spendType = "mana",
            
            startsCombat = false,
            texture = 136090,
            
            handler = function ()
                applyDebuff( "target", "hibernate" )
            end,
        },
        

        incarnation = {
            id = 102560,
            cast = 0,
            cooldown = 180,
            gcd = "spell",
            
            toggle = "cooldowns",

            startsCombat = false,
            texture = 571586,
            
            handler = function ()
                shift( "moonkin_form" )
                applyBuff( "incarnation" )
            end,

            copy = "incarnation_chosen_of_elune"
        },
        

        innervate = {
            id = 29166,
            cast = 0,
            cooldown = 180,
            gcd = "spell",
            
            -- toggle = "cooldowns",

            startsCombat = false,
            texture = 136048,
            
            usable = false,
            handler = function ()
                active_dot.innervate = 1
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
                applyBuff( "ironfur" )
            end,
        },
        

        lunar_strike = {
            id = 194153,
            cast = function () 
                if buff.warrior_of_elune.up then return 0 end
                return haste * ( buff.lunar_empowerment.up and 0.85 or 1 ) * 2.25 
            end,
            cooldown = 0,
            gcd = "spell",

            spend = function () return ( buff.warrior_of_elune.up and 1.4 or 1 ) * -12 end,
            spendType = "astral_power",
            
            startsCombat = true,
            texture = 135753,            
            
            handler = function ()
                if not buff.moonkin_form.up then unshift() end
                removeStack( "lunar_empowerment" )
                removeStack( "warrior_of_elune" )
            end,
        },
        

        mangle = {
            id = 33917,
            cast = 0,
            cooldown = 6,
            gcd = "spell",
            
            spend = -8,
            spendType = "rage",

            startsCombat = true,
            texture = 132135,

            talent = "guardian_affinity",
            form = "bear_form",
            
            handler = function ()
            end,
        },
        

        mass_entanglement = {
            id = 102359,
            cast = 0,
            cooldown = 30,
            gcd = "spell",
            
            startsCombat = false,
            texture = 538515,

            talent = "mass_entanglement",
            
            handler = function ()
                applyDebuff( "target", "mass_entanglement" )
                active_dot.mass_entanglement = max( active_dot.mass_entanglement, active_enemies )
            end,
        },
        

        mighty_bash = {
            id = 5211,
            cast = 0,
            cooldown = 50,
            gcd = "spell",
            
            startsCombat = true,
            texture = 132114,

            talent = "mighty_bash",
            
            handler = function ()
                applyDebuff( "target", "mighty_bash" )
            end,
        },
        

        moonfire = {
            id = 8921,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.06,
            spendType = "mana",
            
            startsCombat = true,
            texture = 136096,

            cycle = "moonfire",
            
            handler = function ()
                if not buff.moonkin_form.up and not buff.bear_form.up then unshift() end
                applyDebuff( "target", "moonfire" )
                gain( 3, "astral_power" )
            end,
        },
        

        moonkin_form = {
            id = 24858,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            startsCombat = false,
            texture = 136036,

            noform = "moonkin_form",
            
            handler = function ()
                shift( "moonkin_form" )
            end,
        },
        

        new_moon = {
            id = 274281,
            cast = 1,
            charges = 3,
            cooldown = 25,
            recharge = 25,
            gcd = "spell",
            
            spend = -10,
            spendType = "astral_power",

            startsCombat = true,
            
            talent = "new_moon",
            bind = "full_moon",
            
            usable = function () return active_moon == "new_moon" end,
            handler = function ()
                spendCharges( "half_moon", 1 )
                spendCharges( "full_moon", 1 )

                active_moon = "half_moon"
            end,
        },
        

        prowl = {
            id = 5215,
            cast = 0,
            cooldown = 6,
            gcd = "spell",
            
            startsCombat = true,
            texture = 514640,
            
            usable = function () return time == 0 end,
            handler = function ()
                shift( "cat_form" )
                applyBuff( "prowl" )
                removeBuff( "shadowmeld" )
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

            talent = "feral_affinity",
            form = "cat_form",
            
            handler = function ()
                applyDebuff( "target", "rake" )
            end,
        },
        

        --[[ rebirth = {
            id = 20484,
            cast = 2,
            cooldown = 600,
            gcd = "spell",
            
            spend = 0,
            spendType = "rage",
            
            -- toggle = "cooldowns",

            startsCombat = true,
            texture = 136080,
            
            handler = function ()
            end,
        }, ]]
        

        regrowth = {
            id = 8936,
            cast = 1.5,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.14,
            spendType = "mana",
            
            startsCombat = false,
            texture = 136085,
            
            handler = function ()
                if buff.moonkin_form.down then unshift() end
                applyBuff( "regrowth" )
            end,
        },
        

        rejuvenation = {
            id = 774,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.11,
            spendType = "mana",
            
            startsCombat = false,
            texture = 136081,

            talent = "restoration_affinity",
            
            handler = function ()
                if buff.moonkin_form.down then unshift() end
                applyBuff( "rejuvenation" )
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

            talent = "renewal",
            
            handler = function ()
                -- unshift?
                gain( 0.3 * health.max, "health" )
            end,
        },
        

        --[[ revive = {
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
        }, ]]
        

        rip = {
            id = 1079,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = 30,
            spendType = "energy",
            
            startsCombat = true,
            texture = 132152,

            talent = "feral_affinity",
            form = "cat_form",

            usable = function () return combo_points.current > 0 end,
            handler = function ()
                spend( combo_points.current, "combo_points" )
                applyDebuff( "target", "rip" )
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

            talent = "feral_affinity",
            form = "cat_form",
            
            handler = function ()
                gain( 1, "combo_points" )
            end,
        },
        

        solar_beam = {
            id = 78675,
            cast = 0,
            cooldown = 60,
            gcd = "off",
            
            spend = 0.17,
            spendType = "mana",
            
            toggle = "interrupts",

            startsCombat = true,
            texture = 252188,
            
            usable = function () return target.casting end,
            handler = function ()
                if buff.moonkin_form.down then unshift() end
                interrupt()
            end,
        },
        

        solar_wrath = {
            id = 190984,
            cast = function () return haste * ( buff.solar_empowerment.up and 0.85 or 1 ) * 1.5 end,
            cooldown = 0,
            gcd = "spell",

            spend = -8,
            spendType = "astral_power",
            
            startsCombat = true,
            texture = 535045,
            
            handler = function ()
                if not buff.moonkin_form.up then unshift() end
                removeStack( "solar_empowerment" )
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
            
            usable = function () return debuff.dispellable_enrage.up end,
            handler = function ()
                if buff.moonkin_form.down then unshift() end
                removeDebuff( "target", "dispellable_enrage" )
            end,
        },
        

        stag_form = {
            id = 210053,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            startsCombat = false,
            texture = 1394966,

            noform = "travel_form",
            handler = function ()
                shift( "stag_form" )
            end,
        },
        

        starfall = {
            id = 191034,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = function () return buff.oneths_overconfidence.up and 0 or 50 end,
            spendType = "astral_power",
            
            startsCombat = true,
            texture = 236168,
            
            handler = function ()
                addStack( "starlord", buff.starlord.remains > 0 and buff.starlord.remains or nil, 1 )
                removeBuff( "oneths_overconfidence" )
                if level < 116 and set_bonus.tier21_4pc == 1 then
                    applyBuff( "solar_solstice" )
                end
            end,
        },
        

        starsurge = {
            id = 78674,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = function ()
                if buff.oneths_intuition.up then return 0 end
                return 40 - ( buff.the_emerald_dreamcatcher.stack * 5 )
            end,
            spendType = "astral_power",
            
            startsCombat = true,
            texture = 135730,
            
            handler = function ()
                addStack( "lunar_empowerment", nil, 1 )
                addStack( "solar_empowerment", nil, 1 )
                addStack( "starlord", buff.starlord.remains > 0 and buff.starlord.remains or nil, 1 )
                removeBuff( "oneths_intuition" )
                if level < 116 and set_bonus.tier21_4pc == 1 then
                    applyBuff( "solar_solstice" )
                end
                if ( level < 116 and equipped.the_emerald_dreamcatcher ) then addStack( "the_emerald_dreamcatcher", 5, 1 ) end
            end,
        },
        

        stellar_flare = {
            id = 202347,
            cast = 1.5,
            cooldown = 0,
            gcd = "spell",

            spend = -8,
            spendType = "astral_power",
            
            startsCombat = true,
            texture = 1052602,
            cycle = "stellar_flare",

            talent = "stellar_flare",
            
            handler = function ()
                applyDebuff( "target", "stellar_flare" )
            end,
        },
        

        sunfire = {
            id = 93402,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.12,
            spendType = "mana",
            
            startsCombat = true,
            texture = 236216,

            cycle = "sunfire",
            
            handler = function ()
                gain( 3, "astral_power" )
                applyDebuff( "target", "sunfire" )
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
            
            startsCombat = false,
            texture = 134914,

            talent = "restoration_affinity",            
            
            handler = function ()
                if buff.moonkin_form.down then unshift() end
                gain( health.max * 0.1, "health" )
            end,
        },
        
        -- May want to revisit this and split out swipe_cat from swipe_bear.
        swipe = {
            known = 213764,
            cast = 0,
            cooldown = function () return haste * ( buff.cat_form.up and 0 or 6 ) end,
            gcd = "spell",

            spend = function () return buff.cat_form.up and 40 or nil end,
            spendType = function () return buff.cat_form.up and "energy" or nil end,
            
            startsCombat = true,
            texture = 134296,

            talent = "feral_affinity",

            usable = function () return buff.cat_form.up or buff.bear_form.up end,
            handler = function ()
                if buff.cat_form.up then
                    gain( 1, "combo_points" )
                end
            end,

            copy = { 106785, 213771 }
        },
        

        thrash = {
            id = 106832,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = -5,
            spendType = "rage",
            
            cycle = "thrash_bear",
            startsCombat = true,
            texture = 451161,

            talent = "guardian_affinity",
            form = "bear_form",
            
            handler = function ()
                applyDebuff( "target", "thrash_bear", nil, debuff.thrash.stack + 1 )
            end,
        },
        

        tiger_dash = {
            id = 252216,
            cast = 0,
            cooldown = 45,
            gcd = "off",
            
            startsCombat = false,
            texture = 1817485,

            talent = "tiger_dash",
            
            handler = function ()
                shift( "cat_form" )
                applyBuff( "tiger_dash" )
            end,
        },
        

        travel_form = {
            id = 783,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            startsCombat = false,
            texture = 132144,
            
            noform = "travel_form",
            handler = function ()
                shift( "travel_form" )
            end,
        },
        

        treant_form = {
            id = 114282,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            startsCombat = false,
            texture = 132145,
            
            handler = function ()
                shift( "treant_form" )
            end,
        },
        

        typhoon = {
            id = 132469,
            cast = 0,
            cooldown = 30,
            gcd = "spell",
            
            startsCombat = true,
            texture = 236170,

            talent = "typhoon",
            
            handler = function ()
                applyDebuff( "target", "typhoon" )
                if target.distance < 15 then setDistance( target.distance + 5 ) end
            end,
        },
        

        warrior_of_elune = {
            id = 202425,
            cast = 0,
            cooldown = 45,
            gcd = "spell",
            
            startsCombat = true,
            texture = 135900,

            talent = "warrior_of_elune",

            usable = function () return buff.warrior_of_elune.down end,
            handler = function ()
                applyBuff( "warrior_of_elune", nil, 3 )
            end,
        },
        

        --[[ wartime_ability = {
            id = 264739,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            startsCombat = true,
            texture = 1518639,
            
            handler = function ()
            end,
        }, ]]
        

        wild_charge = {
            id = function () return buff.moonkin_form.up and 102383 or 102401 end,
            known = 102401,
            cast = 0,
            cooldown = 15,
            gcd = "spell",
            
            startsCombat = false,
            texture = 538771,

            talent = "wild_charge",
            
            handler = function ()
                if buff.moonkin_form.up then setDistance( target.distance + 10 ) end
            end,

            copy = { 102401, 102383 }
        },
        

        wild_growth = {
            id = 48438,
            cast = 1.5,
            cooldown = 10,
            gcd = "spell",
            
            spend = 0.3,
            spendType = "mana",
            
            startsCombat = false,
            texture = 236153,

            talent = "wild_growth",
            
            handler = function ()
                unshift()
                applyBuff( "wild_growth" )
            end,
        },
    } )


    spec:RegisterOptions( {
        enabled = true,

        aoe = 3,
    
        nameplates = false,
        nameplateRange = 8,
        
        damage = true,
        damageDots = false,
        damageExpiration = 6,
    
        package = "Balance",        
    } )


    spec:RegisterPack( "Balance", 20180805.1759, [[dO0M6aqirIweQsKEKIa1LqvsSjufFsr0Oqv1POiwfQsuVII0Sqv5wieXUO0VqfggI0XuKwgIONjsAAiKUgQszBOkP(gcbJtrqNtraRdvPAEie19uu7JI6GieYcrf9qfHAIOkr4IkceFurizKOkr0jrisRuKAMOkHDQkzOkcKwQIq4PQQPQk1xvesTxi)vudMWHjTyk8yuMSkUmyZc(mIA0i40sTAfHOxJimBIUTc7wPFJ0WfXXriulxYZfA6uDDvA7Ie(oQ04rOCEeQwpQssZxvSFOgnf9g9pQdOxKK0PtiPtiP8MDkrG3MaKss03jEcG(jkJekza9xDaOpNQuxgG(jkXLu9GEJ(r6Tya6tW9KiVZbhKBNW1WYOdoI94kvVPlR0GZrShmomKudomckrYbsbhjfn0siYX7gksoLJ3KCAMxI62NmNQuxgyJ9GH(g3w6ePlYa9pQdOxKK0PtiPtiP8MDkVE60Pef91RtGwO)Vhtm6FGid9FtOJyrhXcflsugjuYawqdyHY8MUyHSJEelc0cl4LeirlBlono9BcawqxjXXIHorslSGrqxYqelCkw4eaS43JjgliIMGYlWcUAelCkwWOBkGYXcNaGf8sDTidEUd8sXIORomG1JyrVoflCTidorcJ4mzVKXIcy0Xa2J6nDJybJUXo6W6yb32jGfobal0ZHUwCAC63e6iwWTLsSWaWIcsrhHdwOK1EXIEXcflcx)wawCtoQdw0x2rpIEJ(Wb9g9Ak6n6dRAiHdIt0NvTdvROVg9sL5ekxOWcZZyrQKI(kZB6I(9Y0AvVPlYrVij6n6dRAiHdIt0NvTdvROVg9sL5ekxOWcZZyrQKI(kZB6I(mqcrVvzwLn5DaRJC0RurVrFyvdjCqCI(SQDOAf95hlmUHGLbsi6TkZQSjVdyD7nblEEWcJBiy7LP1QEtx7nblmblEEWc(XcgLkpuURLbsi6TkZQSjVdyDBbdT3iwyglsLuS45blyuQ8q5U2EzATQ301wWq7nIfMXIujflmbl4bl4hlmUHG1jazyaLkp5tb6GPoJau2cgAVrSWmwqMDWINhSiLyHXneSobiddOu5jFkqhm1zeGYEtWctqFL5nDr)WTiEMgYG8UaYrVik6n6dRAiHdIt0NvTdvROp)yHXneSmqcrVvzwLn5DaRBVjyXZdwyCdbBVmTw1B6AVjyHjyXZdwWpwWOu5HYDTmqcrVvzwLn5DaRBlyO9gXcZyrQKIfppybJsLhk312ltRv9MU2cgAVrSWmwKkPyHjybpyb)yHXneSobiddOu5jFkqhm1zeGYwWq7nIfMXcYSdw88GfPelmUHG1jazyaLkp5tb6GPoJau2Bcwyc6RmVPl6hOfdY0qEv)waYrV4n0B0hw1qcheNOpRAhQwrF(XcYSdwWlJfA0lvMtOCHcl4vWIujflmblmJfUwKb369aYonFAa9vM30f9JUwXBrgqo6fVg9g9HvnKWbXj6RmVPl6pO0n0fG(SQDOAf9liuqKGAibSGhSW4gcwNaKHbuQ8KpfOdM6mcqzlyO9gXcZybz2blEEWIuIfg3qW6eGmmGsLN8PaDWuNrak7nb9zeNjHSRfzWJOxtro6fra9g9HvnKWbXj6RmVPl6hVBOla9zv7q1k6xqOGib1qcybpyHXneSobiddOu5jFkqhm1zeGYwWq7nIfMXcYSdw88GfPelmUHG1jazyaLkp5tb6GPoJau2Bc6ZiotczxlYGhrVMIC0Rje9g9HvnKWbXj6RmVPl6hDqk1khKAbOpRAhQwr)ccfejOgsal4blmUHG1jazyaLkp5tb6GPoJau2cgAVrSWmwqMDWINhSiLyHXneSobiddOu5jFkqhm1zeGYEtqFgXzsi7Arg8i61uKJEnbqVrFyvdjCqCI(SQDOAf9nUHGLUGtiMPPakgDd9bwgyVjybpyb)yHXneSobiddOu5jFkqhm1zeGYwWq7nIfMXcYSdw88GfPelmUHG1jazyaLkp5tb6GPoJau2Bcwyc6RmVPl6hDTcQuIC0RPKIEJ(WQgs4G4e9zv7q1k6BCdbRtaYWakvEYNc0btDgbOSfm0EJyHzSaigWUoK9EayXZdwKsSW4gcwNaKHbuQ8KpfOdM6mcqzVjOVY8MUO)cCZdkDro610PO3OpSQHeoiorFw1ouTI(A0lvMtOCHYEGqZAhlmpJfKKuSGhSGFSW4gcwNaKHbuQ8KpfOdM6mcqzlyO9gXcZybqmGDDi79aWINhSiLyHXneSobiddOu5jFkqhm1zeGYEtWctqFL5nDrFcQmKhu6IC0RPKe9g9HvnKWbXj6ZQ2HQv0xJEPYCcLlu2deAw7yH5zSGOKIf8Gf8Jfg3qW6eGmmGsLN8PaDWuNrakBbdT3iwyglaIbSRdzVhaw88GfPelmUHG1jazyaLkp5tb6GPoJau2Bcwyc6RmVPl6hUszEqPlYrVMMk6n6dRAiHdIt0NvTdvROVXneSY7QvggjuUqnG1T3eSGhSW4gcwNaKHbuQ8KpfOdM6mcqzlyO9gXcZybqmGDDi79aqFL5nDrF5D1kh9QjbGC0RPef9g9HvnKWbXj6ZQ2HQv034gc2ivQvggjuUqnG1T3eSGhSW4gcwNaKHbuQ8KpfOdM6mcqzlyO9gXcZybqmGDDi79aqFL5nDr)ivQvMBPobKJEnL3qVrFyvdjCqCI(SQDOAf95hlmUHG1jazyaLkp5tb6GPoJau2BcwWdwyCdbRtaYWakvEYNc0btDgbOSfm0EJybrgliZoyHjyXZdwOrVuzoHYfkSW8mwWBKI(kZB6I(rxR4Tidih9AkVg9g9vM30f9JuPwzUL6eqFyvdjCqCICKJ(hiOxPJEJEnf9g9HvnKWbXj6ZQ2HQv034gcwgiHO3QmRYM8oG1T3eS45blmUHGTxMwR6nDT3e0xzEtx0pH6nDro6fjrVrFyvdjCqCI(SQDOAf9nUHGLbsi6TkZQSjVdyD7nblEEWcJBiy7LP1QEtx7nb9vM30f9nKu6jhUfXro6vQO3OpSQHeoiorFw1ouTI(g3qWYaje9wLzv2K3bSU9MGfppyHXneS9Y0AvVPR9MG(kZB6I(gqfHIe9sg5Oxef9g9HvnKWbXj6ZQ2HQv034gcwgiHO3QmRYM8oG1T3eS45blmUHGTxMwR6nDT3e0xzEtx0xlMUq2PvbRJC0lEd9g9HvnKWbXj6ZQ2HQv034gcwgiHO3QmRYM8oG1T3eS45blmUHGTxMwR6nDT3e0xzEtx0x2Kj4X8e59qEaRJC0lEn6n6RmVPl6FJqUDyerFyvdjCqCIC0lIa6n6RmVPl6ZvRQPvMgYG8Ua6dRAiHdItKJEnHO3OpSQHeoiorFw1ouTI(ar8TtsGJ1jazyaLkp5tb6GPoJauybpyHY8ofqgwy0qeliYZyXu0xzEtx0VUBwzEt3SSJo6l7ONxDaOpCqo61ea9g9HvnKWbXj6ZQ2HQv0x5vHQDWk7uasINJjD1Ufw1qchSGhSGFSGrPYdL7A7LP1QEtx7nblEEWcgLkpuURLbsi6TkZQSjVdyDBbdT3iwqKXIPKelmb9vM30f97DHkfQdih9AkPO3OpSQHeoiorFw1ouTI(A0lvMtOCHclmpJfeLu0xzEtx0VxMwR6nDro610PO3OpSQHeoiorFw1ouTI(A0lvMtOCHclmpJfeLuSGhSGFSiLyHYRcv7Gv2PaKepht6QDlSQHeoyXZdwyCdbRStbijEoM0v72Bcwyc6RmVPl6Zaje9wLzv2K3bSoYrVMss0B0hw1qcheNOpRAhQwr)yciLzxlYGhTrxRGkLyH5zSiv0xzEtx0VUBwzEt3SSJo6l7ONxDaOVsbKJEnnv0B0hw1qcheNOVY8MUOFD3SY8MUzzhD0x2rpV6aq)OJCKJ(jfWOdd1rVrVMIEJ(WQgs4G4e5OxKe9g9HvnKWbXjYrVsf9g9HvnKWbXjYrVik6n6RmVPl6pO0Le9Md0AG(WQgs4G4e5Ox8g6n6dRAiHdItKJEXRrVrFL5nDr)eQ30f9HvnKWbXjYrVicO3OVY8MUOFKk1kZTuNa6dRAiHdItKJC0xPa6n61u0B0hw1qcheNOpRAhQwrF(XcJBiyzGeIERYSkBY7aw3EtWINhSW4gc2EzATQ301EtWctWINhSGFSGrPYdL7AzGeIERYSkBY7aw3wWq7nIfMXIujflEEWcgLkpuURTxMwR6nDTfm0EJyHzSivsXctqFL5nDr)WTiEMgYG8UaYrVij6n6dRAiHdIt0NvTdvROp)yHXneSmqcrVvzwLn5DaRBVjyXZdwyCdbBVmTw1B6AVjyHjyXZdwWpwWOu5HYDTmqcrVvzwLn5DaRBlyO9gXcZyrQKIfppybJsLhk312ltRv9MU2cgAVrSWmwKkPyHjOVY8MUOFGwmitd5v9Bbih9kv0B0hw1qcheNOVY8MUOF8UHUa0NvTdvROFbHcIeudjGf8GfA0lvMtOCHYEGqZAhlmJfebSGhSW1Im4wVhq2P5tdyHzSGOOpJ4mjKDTidEe9AkYrVik6n6dRAiHdIt0xzEtx0FqPBOla9zv7q1k6xqOGib1qcybpyHg9sL5ekxOShi0S2XcZybral4blCTidU17bKDA(0awyglik6ZiotczxlYGhrVMIC0lEd9g9HvnKWbXj6RmVPl6hDqk1khKAbOpRAhQwr)ccfejOgsal4blCTidU17bKDA(0awyglMsk6ZiotczxlYGhrVMIC0lEn6n6dRAiHdIt0NvTdvROp)yHXneSY7QvggjuUqnG1TrxzKalMXIuXINhSW4gc2ivQvggjuUqnG1TrxzKalMXcsIf8Gfg3qWkVRwzyKq5c1aw3gDLrcSyglijwWdwOrVuzoHYfkSW8mwqusXctWcEWcn6LkZjuUqzpqOzTJfMXIPef9vM30f9L3vRC0RMeaYrVicO3OpSQHeoiorFw1ouTI(g3qWgPsTYWiHYfQbSUn6kJeyXmwKkwWdwOrVuzoHYfk7bcnRDSWmwmLu0xzEtx0psLAL5wQta5Oxti6n6dRAiHdIt0NvTdvROVXneS0fCcXCV(T9MU2cuMJfppyHRfzWTEpGStZNgWcI8mwqu0xzEtx0p6AfVfza5Oxta0B0hw1qcheNOpRAhQwr)uIfg3qWgDTK06yVjyXZdwyCdbB01ssRJTGH2BelmpJfef9vM30f9JUwbvkro61usrVrFyvdjCqCI(SQDOAf91OxQmNq5cL9aHM1owyglMss0xzEtx0FbU5bLUih9A6u0B0hw1qcheNOpRAhQwrFn6LkZjuUqzpqOzTJfMXcsss0xzEtx0NGkd5bLUih9AkjrVrFyvdjCqCI(SQDOAf91OxQmNq5cL9aHM1owyglikjrFL5nDr)WvkZdkDro610urVrFyvdjCqCI(SQDOAf95hlmUHGnsLALHrcLludyD7nbl4blsjwyCdblxTQMwzAidY7c2Bcw88Gfg3qWgPsTYWiHYfQbSUn6kJeyH5zSivSWeSGhSW4gcw5D1kdJekxOgW62ORmsGfezSiv0xzEtx0psLAL5wQta5Oxtjk6n6RmVPl6lVRw5Oxnja0hw1qcheNih9AkVHEJ(kZB6I(dkDdDbOpSQHeoioroYr)OJEJEnf9g9HvnKWbXj6ZQ2HQv0NFSW4gcwgiHO3QmRYM8oG1T3eS45blmUHGTxMwR6nDT3eSWeS45bl4hlyuQ8q5UwgiHO3QmRYM8oG1Tfm0EJyHzSivsXINhSGrPYdL7A7LP1QEtxBbdT3iwyglsLuSWe0xzEtx0pClINPHmiVlGC0lsIEJ(WQgs4G4e9zv7q1k6ZpwyCdbldKq0BvMvztEhW62Bcw88Gfg3qW2ltRv9MU2Bcwycw88Gf8JfmkvEOCxldKq0BvMvztEhW62cgAVrSWmwKkPyXZdwWOu5HYDT9Y0AvVPRTGH2BelmJfPskwyc6RmVPl6hOfdY0qEv)waYrVsf9g9HvnKWbXj6RmVPl6pO0n0fG(SQDOAf9liuqKGAibSGhSW1Im4wVhq2P5tdyHzSycrFgXzsi7Arg8i61uKJEru0B0hw1qcheNOVY8MUOF8UHUa0NvTdvROFbHcIeudjGf8GfUwKb369aYonFAalmJfti6ZiotczxlYGhrVMIC0lEd9g9HvnKWbXj6RmVPl6hDqk1khKAbOpRAhQwr)ccfejOgsal4blCTidU17bKDA(0awyglMsk6ZiotczxlYGhrVMIC0lEn6n6dRAiHdIt0NvTdvROp)yHXneSrQuRmmsOCHAaRBJUYibwmJfPIfppyHXneSrQuRmmsOCHAaRBJUYibwmJfKel4blmUHGvExTYWiHYfQbSUn6kJeyXmwqsSGhSqJEPYCcLluyH5zSGOKIfMGf8GfA0lvMtOCHYEGqZAhlmJftjf9vM30f9JuPwzUL6eqo6fra9g9HvnKWbXj6ZQ2HQv034gcw5D1kdJekxOgW62ORmsGfZyrQybpyHg9sL5ekxOShi0S2XcZyXuII(kZB6I(Y7Qvo6vtca5Oxti6n6dRAiHdIt0NvTdvROVXneS0fCcXmnfqXOBOpWYaBbkZrFL5nDr)ORvqLsKJEnbqVrFyvdjCqCI(SQDOAf9tjwyCdbB01ssRJ9MGfppyHXneSrxljTo2cgAVrSW8mwquS45bl4hliZoybVmwWpwOrVuzoHYfkSGxblikPyHjyHjyHzSW1Im4wVhq2P5tdOVY8MUOF01kElYaYrVMsk6n6dRAiHdIt0NvTdvROp)yHXneSC1QAALPHmiVlyVjyXZdwKsSW4gc2ivQvggjuUqnG1T3eSWeSGhSW4gcw5D1kdJekxOgW62Bc6RmVPl6lVRw5OxnjaKJEnDk6n6dRAiHdIt0NvTdvROVg9sL5ekxOShi0S2XcZyXusrFL5nDr)f4Mhu6IC0RPKe9g9HvnKWbXj6ZQ2HQv0xJEPYCcLlu2deAw7yHzSGKKI(kZB6I(euzipO0f5Oxttf9g9HvnKWbXj6ZQ2HQv0xJEPYCcLlu2deAw7yHzSGOKI(kZB6I(HRuMhu6IC0RPef9g9vM30f9JuPwzUL6eqFyvdjCqCIC0RP8g6n6RmVPl6pO0n0fG(WQgs4G4e5ih5OpxT2Ejhr)jAIOjIxePVMO4DSalEtaWIEKqlhlc0clMeotIffqeF7coyrKoaSqVoDOoCWcgbDjdrlonVOxalsL3XIjMUPakhoyXKKzh7qj2KyHtXIjjZotIf8pLyMyXP5f9cybr5DSyIPBkGYHdwmjz2XouInjw4uSysYSZKyb)tjMjwCAErVawWB8owmX0nfq5WblMKm7yhkXMelCkwmjz2zsSG)PeZelonVOxal418owmX0nfq5WblMKm7yhkXMelCkwmjz2zsSG)PeZelonVOxalic8owmX0nfq5WblMKm7yhkXMelCkwmjz2zsSG)PeZelonVOxalMqEhlMy6McOC4GftsMDSdLytIfoflMKm7mjwW)uIzIfNMx0lGftaEhlMy6McOC4GftsMDSdLytIfoflMKm7mjwW)uIzIfNMx0lGft5nEhlMy6McOC4GftsMDSdLytIfoflMKm7mjwW)uIzIfNgNEIMiAI4fr6RjkEhlWI3eaSOhj0YXIaTWIjpqqVsFsSOaI4BxWblI0bGf61Pd1HdwWiOlziAXPFtaWIavkPC7LmwO3sJybxOaS4gHdw0lw4eaSqzEtxSq2rhlmUowWfkalwQJfb6DpyrVyHtaWc9COlwCuxn0iW740ybrcwi7uasINJjD1oono9enr0eXlI0xtu8owGfVjayrpsOLJfbAHftg9jXIciIVDbhSishawOxNouhoybJGUKHOfNMx0lGftaEhlMy6McOC4GftsMDSdLytIfoflMKm7mjwW)uIzIfNgNMiDKqlhoybVHfkZB6IfYo6rlon6htag61usjj6Nu0qlb0FcglMGqmGDD4GfgqGwawWOdd1XcdGCVrlwqeXyqIhXILUeje0AeUsSqzEt3iwqxjXT40kZB6gTjfWOdd1NdsnscCAL5nDJ2Kcy0HH6MoZrGsp40kZB6gTjfWOdd1nDMd9sEaRREtxCAL5nDJ2Kcy0HH6MoZXGsxs0BoqRbo9emw8xnjsG6yrP9blmUHaCWIOREelmGaTaSGrhgQJfga5EJyHUhSiPaIKeQ79sgl6iwCOlyXPvM30nAtkGrhgQB6mhXvtIeOEo6QhXPvM30nAtkGrhgQB6mhjuVPloTY8MUrBsbm6WqDtN5isLAL5wQtaNgNEcglMGqmGDD4GfqkGI4yH3dalCcawOmNwyrhXcnfAlvdjyXPvM30noNq9MU81HzJBiyzGeIERYSkBY7aw3EtEEmUHGTxMwR6nDT3eCAL5nDJMoZHHKsp5WTioFDy24gcwgiHO3QmRYM8oG1T3KNhJBiy7LP1QEtx7nbNwzEt3OPZCyaveks0lz(6WSXneSmqcrVvzwLn5DaRBVjppg3qW2ltRv9MU2BcoTY8MUrtN5qlMUq2PvbRZxhMnUHGLbsi6TkZQSjVdyD7n55X4gc2EzATQ301EtWPvM30nA6mhYMmbpMNiVhYdyD(6WSXneSmqcrVvzwLn5DaRBVjppg3qW2ltRv9MU2BcoTY8MUrtN54gHC7WiItRmVPB00zo4Qv10ktdzqExaNwzEt3OPZCu3nRmVPBw2rNVvhWmC4RdZar8TtsGJ1jazyaLkp5tb6GPoJau8OmVtbKHfgnejYZtXPvM30nA6mh9UqLc1b(6WSYRcv7Gv2PaKepht6QDlSQHeo8WpJsLhk312ltRv9MU2BYZdJsLhk31Yaje9wLzv2K3bSUTGH2BKipLKMGtRmVPB00zo6LP1QEtx(6WSg9sL5ekxOmptusXPvM30nA6mhmqcrVvzwLn5DaRZxhM1OxQmNq5cL5zIskp8NsLxfQ2bRStbijEoM0v7wyvdjCEEmUHGv2PaKepht6QD7nXeCAL5nDJMoZrD3SY8MUzzhD(wDaZkf4RdZXeqkZUwKbpAJUwbvknpNkoTY8MUrtN5OUBwzEt3SSJoFRoG5OJtJtRmVPB0QuyoClINPHmiVlWxhM534gcwgiHO3QmRYM8oG1T3KNhJBiy7LP1QEtx7nXKNh(zuQ8q5UwgiHO3QmRYM8oG1Tfm0EJMtL0NhgLkpuURTxMwR6nDTfm0EJMtLutWPvM30nAvky6mhbAXGmnKx1VfWxhM534gcwgiHO3QmRYM8oG1T3KNhJBiy7LP1QEtx7nXKNh(zuQ8q5UwgiHO3QmRYM8oG1Tfm0EJMtL0NhgLkpuURTxMwR6nDTfm0EJMtLutWPvM30nAvky6mhX7g6c4JrCMeYUwKbpopLVomxqOGib1qc8OrVuzoHYfk7bcnRDZebECTidU17bKDA(0GzIItRmVPB0QuW0zogu6g6c4JrCMeYUwKbpopLVomxqOGib1qc8OrVuzoHYfk7bcnRDZebECTidU17bKDA(0GzIItRmVPB0QuW0zoIoiLALdsTa(yeNjHSRfzWJZt5RdZfekisqnKapUwKb369aYonFAW8usXPvM30nAvky6mhY7Qvo6vtcGVomZVXneSY7QvggjuUqnG1TrxzKyo1NhJBiyJuPwzyKq5c1aw3gDLrIzsYJXneSY7QvggjuUqnG1TrxzKyMK8OrVuzoHYfkZZeLut4rJEPYCcLlu2deAw7MNsuCAL5nDJwLcMoZrKk1kZTuNaFDy24gc2ivQvggjuUqnG1TrxzKyovE0OxQmNq5cL9aHM1U5PKItRmVPB0QuW0zoIUwXBrg4RdZg3qWsxWjeZ9632B6Alqz(ZJRfzWTEpGStZNgiYZefNwzEt3OvPGPZCeDTcQuYxhMtPXneSrxljTo2BYZJXneSrxljTo2cgAVrZZefNwzEt3OvPGPZCSa38Gsx(6WSg9sL5ekxOShi0S2npLK40kZB6gTkfmDMdcQmKhu6YxhM1OxQmNq5cL9aHM1UzsssCAL5nDJwLcMoZr4kL5bLU81Hzn6LkZjuUqzpqOzTBMOKeNwzEt3OvPGPZCePsTYCl1jWxhM534gc2ivQvggjuUqnG1T3eEsPXneSC1QAALPHmiVlyVjppg3qWgPsTYWiHYfQbSUn6kJeMNt1eEmUHGvExTYWiHYfQbSUn6kJee5uXPvM30nAvky6mhY7Qvo6vtcaNwzEt3OvPGPZCmO0n0fGtJtRmVPB0cN5EzATQ30LVomRrVuzoHYfkZZPskoTY8MUrlCmDMdgiHO3QmRYM8oG15RdZA0lvMtOCHY8CQKItRmVPB0chtN5iClINPHmiVlWxhM534gcwgiHO3QmRYM8oG1T3KNhJBiy7LP1QEtx7nXKNh(zuQ8q5UwgiHO3QmRYM8oG1Tfm0EJMtL0NhgLkpuURTxMwR6nDTfm0EJMtLut4HFJBiyDcqggqPYt(uGoyQZiaLTGH2B0mz2XouI98KsJBiyDcqggqPYt(uGoyQZiaL9MycoTY8MUrlCmDMJaTyqMgYR63c4RdZ8BCdbldKq0BvMvztEhW62BYZJXneS9Y0AvVPR9MyYZd)mkvEOCxldKq0BvMvztEhW62cgAVrZPs6ZdJsLhk312ltRv9MU2cgAVrZPsQj8WVXneSobiddOu5jFkqhm1zeGYwWq7nAMm7yhkXEEsPXneSobiddOu5jFkqhm1zeGYEtmbNwzEt3OfoMoZr01kElYaFDyMFYSJDOeJxwJEPYCcLlu8kPsQjMDTidU17bKDA(0aoTY8MUrlCmDMJbLUHUa(yeNjHSRfzWJZt5RdZfekisqnKapg3qW6eGmmGsLN8PaDWuNrakBbdT3OzYSJDOe75jLg3qW6eGmmGsLN8PaDWuNrak7nbNwzEt3OfoMoZr8UHUa(yeNjHSRfzWJZt5RdZfekisqnKapg3qW6eGmmGsLN8PaDWuNrakBbdT3OzYSJDOe75jLg3qW6eGmmGsLN8PaDWuNrak7nbNwzEt3OfoMoZr0bPuRCqQfWhJ4mjKDTidECEkFDyUGqbrcQHe4X4gcwNaKHbuQ8KpfOdM6mcqzlyO9gntMDSdLyppP04gcwNaKHbuQ8KpfOdM6mcqzVj40kZB6gTWX0zoIUwbvk5RdZg3qWsxWjeZ0uafJUH(aldS3eE434gcwNaKHbuQ8KpfOdM6mcqzlyO9gntMDSdLyppP04gcwNaKHbuQ8KpfOdM6mcqzVjMGtRmVPB0chtN5ybU5bLU81HzJBiyDcqggqPYt(uGoyQZiaLTGH2B0mqmGDDi79aEEsPXneSobiddOu5jFkqhm1zeGYEtWPvM30nAHJPZCqqLH8Gsx(6WSg9sL5ekxOShi0S2nptss5HFJBiyDcqggqPYt(uGoyQZiaLTGH2B0mqmGDDi79aEEsPXneSobiddOu5jFkqhm1zeGYEtmbNwzEt3OfoMoZr4kL5bLU81Hzn6LkZjuUqzpqOzTBEMOKYd)g3qW6eGmmGsLN8PaDWuNrakBbdT3OzGya76q27b88KsJBiyDcqggqPYt(uGoyQZiaL9MycoTY8MUrlCmDMd5D1kh9QjbWhFDy24gcw5D1kdJekxOgW62Bcpg3qW6eGmmGsLN8PaDWuNrakBbdT3OzGya76q27bGtRmVPB0chtN5isLAL5wQtGVomBCdbBKk1kdJekxOgW62Bcpg3qW6eGmmGsLN8PaDWuNrakBbdT3OzGya76q27bGtRmVPB0chtN5i6AfVfzGVomZVXneSobiddOu5jFkqhm1zeGYEt4X4gcwNaKHbuQ8KpfOdM6mcqzlyO9gjYKzh7qjMjppA0lvMtOCHY8mVrkoTY8MUrlCmDMJivQvMBPobCACAL5nDJ2OphUfXZ0qgK3f4RdZ8BCdbldKq0BvMvztEhW62BYZJXneS9Y0AvVPR9MyYZd)mkvEOCxldKq0BvMvztEhW62cgAVrZPs6ZdJsLhk312ltRv9MU2cgAVrZPsQj40kZB6gTr30zoc0IbzAiVQFlGVomZVXneSmqcrVvzwLn5DaRBVjppg3qW2ltRv9MU2BIjpp8ZOu5HYDTmqcrVvzwLn5DaRBlyO9gnNkPppmkvEOCxBVmTw1B6AlyO9gnNkPMGtRmVPB0gDtN5yqPBOlGpgXzsi7Arg848u(6WCbHcIeudjWJRfzWTEpGStZNgmpH40kZB6gTr30zoI3n0fWhJ4mjKDTidECEkFDyUGqbrcQHe4X1Im4wVhq2P5tdMNqCAL5nDJ2OB6mhrhKsTYbPwaFmIZKq21Im4X5P81H5ccfejOgsGhxlYGB9EazNMpnyEkP40kZB6gTr30zoIuPwzUL6e4RdZ8BCdbBKk1kdJekxOgW62ORmsmN6ZJXneSrQuRmmsOCHAaRBJUYiXmj5X4gcw5D1kdJekxOgW62ORmsmtsE0OxQmNq5cL5zIsQj8OrVuzoHYfk7bcnRDZtjfNwzEt3On6MoZH8UALJE1Ka4RdZg3qWkVRwzyKq5c1aw3gDLrI5u5rJEPYCcLlu2deAw7MNsuCAL5nDJ2OB6mhrxRGkL81HzJBiyPl4eIzAkGIr3qFGLb2cuMJtRmVPB0gDtN5i6AfVfzGVomNsJBiyJUwsADS3KNhJBiyJUwsADSfm0EJMNj6Zd)Kzh7qjgVm)A0lvMtOCHIxHOKAIjMDTidU17bKDA(0aoTY8MUrB0nDMd5D1kh9QjbWxhM534gcwUAvnTY0qgK3fS3KNNuACdbBKk1kdJekxOgW62BIj8yCdbR8UALHrcLludyD7nbNwzEt3On6MoZXcCZdkD5RdZA0lvMtOCHYEGqZA38usXPvM30nAJUPZCqqLH8Gsx(6WSg9sL5ekxOShi0S2ntssXPvM30nAJUPZCeUszEqPlFDywJEPYCcLlu2deAw7MjkP40kZB6gTr30zoIuPwzUL6eWPvM30nAJUPZCmO0n0fGCKJq]] )

    
end