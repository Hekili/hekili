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


    spec:RegisterStateExpr( "active_moon", function ()
        return "new_moon"
    end )

    local function IsActiveSpell( id )
        local slot = FindSpellBookSlotBySpellID( id )
        if not slot then return false end

        local _, _, spellID = GetSpellBookItemName( slot, "spell" )
        return id == spellID 
    end

    state.IsActiveSpell = IsActiveSpell
    
    spec:RegisterHook( "reset_precast", function ()
        if IsActiveSpell( class.abilities.new_moon.id ) then active_moon = "new_moon"
        elseif IsActiveSpell( class.abilities.half_moon.id ) then active_moon = "half_moon"
        elseif IsActiveSpell( class.abilities.full_moon.id ) then active_moon = "full_moon"
        else active_moon = nil end
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
            known = 274281,
            cast = 3,
            charges = 3,
            cooldown = 25,
            recharge = 25,
            gcd = "spell",
            
            spend = -40,
            spendType = "astral_power",

            texture = 1392542,
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
                applyDebuff( "target", "fury_of_elune_ap" )
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
            known = 274281,
            cast = 2,
            charges = 3,
            cooldown = 25,
            recharge = 25,
            gcd = "spell",

            spend = -20,
            spendType = "astral_power",
            
            texture = 1392543,
            startsCombat = true,

            talent = "new_moon",
            bind = "new_moon",
            
            usable = function () return active_moon == 'half_moon' end,
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

            texture = 1392545,
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


    spec:RegisterPack( "Balance", 20180820.1845, [[duumVaqijQhHsHlrvInHsgfOCkq1QuujVIQuZIuv3IQKIDrYVOkAysGJjrwMQINrQyAkQ6AkQyBuLKVrQsnojuDoukY6uuPMhkLUNISpi4GuLuAHsqpKuLKjsQs0frPOAKuLu1jrPOyLqOBIsrPDsvyOKQewkPkPEkQAQOuTxk9xfgSshgzXq6XsAYOYLj2SQ8ziA0siNwQvtvsLxtQ0SH62KYUv53umCuSCGNtLPl66GSDvvFxrz8KQ48sOSEvLMpv1(f2wYYULNJsX6XNckv8ck(NcuLk(8ZRJEB5ZIXiwEgQQlHuS8hPjw(cjmDvXYZqfdBiol7wENbcuflFrzY4MBp9ezNfbHQQgnpDTgeMY2Cva9spDTw1tuSb1t0h51Wj)EYamVglop1laIEn1Cop1l0Rh6LaOMBuiHPRkkxRvT8OqnozZCwulphLI1JpfuQ4fu8sSj1hDMtXlXMS8euwKby55Bn9klpN4QwE2lQDX2UyPyzOQUesjwZlwQMT5If3U0f7ZaI1Rx0TXTkqmq0RLJt4IL3GjqSfkKMkquVQi6qkCXMeaPKJ(fBLCIl20eBTyvSmscGusNYYJBx6SSB55KhbHtl7wpkzz3Yt1SnNL3zWeyGkKMLxocflC2cTP1Jpw2T8YrOyHZwOLVc6uanz5rHEpvvWIlBcpiCJ80KlvqmX67hlk07P6RsGJY2CkiglpvZ2CwEgt2MZMwp0XYULxocflC2cT8vqNcOjlpk07PQcwCzt4bHBKNMCPcIjwF)yrHEpvFvcCu2MtbXy5PA2MZYJIngUXdcumBA9yEl7wE5iuSWzl0YxbDkGMS8OqVNQkyXLnHheUrEAYLkiMy99Jff69u9vjWrzBofeJLNQzBolpQaCcq3(qAtRhZXYULxocflC2cT8vqNcOjlpk07PQcwCzt4bHBKNMCPcIjwF)yrHEpvFvcCu2MtbXy5PA2MZYtGkDYinaGCPnTE4vw2T8YrOyHZwOLVc6uanz5rHEpvvWIlBcpiCJ80KlvqmX67hlk07P6RsGJY2CkiglpvZ2CwECJSO0n86G4qQjxAtRh6TLDlVCekw4SfA5RGofqtwEuO3tvfS4YMWdc3ipn5sfetS((XIc9EQ(Qe4OSnNcIXYt1SnNL)1abfBmC206rXTSB5LJqXcNTqlFf0PaAYYJc9EQQGfx2eEq4g5PjxQGyI13pwuO3t1xLahLT5uqmwEQMT5S80vfxci8OsySnTEWMSSB5PA2MZYd5KrNIMZYlhHIfoBH206rPcSSB5PA2MZYpJaG2agM3qWqNy5LJqXcNTqBA9Oujl7wE5iuSWzl0YxbDkGMS80xb0POW9VGl2WX0GovYrOyHlwwXcl2QXG5mZovFvcCu2MtbXeRVFSvJbZzMDQQGfx2eEq4g5PjxQaIg1Nlw2gBPpXcpwwXclwyXclwa1Cd5xUurCCofheGY2CX6LylnNyHh7CflSyNpw4XY2yHflGAUH8lxQiooNQVy9sSLkEbXcpw4X67hlSybuZnKF5sfXX5uqmXcpw4wEQMT5S89Dc4NsXMwpk9XYULxocflC2cT8vqNcOjlp5saHhmMzciweMID(cILvSWIfwSWIfqn3q(LlvehNtXbbOSnxSEjwDkiw4XoxXcl25JfESSnwyXcOMBi)YLkIJZP6lwVeBPIxqSWJfES((Xclwa1Cd5xUurCCofetSWJfULNQzBolFFvcCu2MZMwpkPJLDlVCekw4SfA5RGofqtwEYLacpymZeqSimf78felRyHfB5yPVcOtrH7FbxSHJPbDQKJqXcxS((XIc9EkC)l4InCmnOtfetSWJLvSWIfwSWIfqn3q(LlvehNtXbbOSnxSEj2sZjw4XoxXcl25JfESSnwyXcOMBi)YLkIJZP6lwVeBPIxqSWJfES((Xclwa1Cd5xUurCCofetSWJfULNQzBolFvWIlBcpiCJ80KlTP1JsZBz3YlhHIfoBHw(kOtb0KLhwSWIfwSaQ5gYVCPI44CkoiaLT5I1lXw8yHh7CflSyNpw4XY2yHflGAUH8lxQiooNQVy9sSEvbXcpw4X67hlSybuZnKF5sfXX5uqmXcpw4XYkwyXclwuO3tvfS4YMWdc3ipn5sfetS((XIc9EQ(Qe4OSnNcIjw4X67hlSyRgdMZm7uvblUSj8GWnYttUubenQpxSieRofeRVFSvJbZzMDQ(Qe4OSnNciAuFUyriwDkiw4Xc3Yt1SnNL)bbk2W8gcg6eBA9O0CSSB5LJqXcNTqlFf0PaAYYdlwuO3tvfS4YMWdc3ipn5sfetS((XIc9EQ(Qe4OSnNcIjw4X67hlSyRgdMZm7uvblUSj8GWnYttUubenQpxSieRofeRVFSvJbZzMDQ(Qe4OSnNciAuFUyriwDkiw4wEQMT5S8pdOkdZBCucbeBA9OKxzz3YlhHIfoBHwEQMT5S8oO71aXYxbDkGMS8a5bexrekwILvSWILCjGWdgZmbO4Kxx7mweMIvVJLvSjbqkPkBnzKMbxlXIqSZrnFSSIfwSLJff69uvblUSj8GWnYttUubXelRylhlk07P6RsGJY2CkiMy99JTCS)eOjuSOOVdxces3y99JTCSma5FGSYPkPCq3RbsSWJ13p2Fc0ekwu03rrxStXQtSWT81IvXYijasjDwpkztRhL0Bl7wE5iuSWzl0Yt1SnNLxZyUxdelFf0PaAYYdKhqCfrOyjwwXclwYLacpymZeGItEDTZyrykw9owwXMeaPKQS1KrAgCTelcX6vkVkwwXcl2YXIc9EQQGfx2eEq4g5PjxQGyILvSLJff69u9vjWrzBofetS((Xwo2Fc0ekwu03HlbcPBS((XwowgG8pqw5uLuAgZ9AGel8yHB5RfRILrsaKs6SEuYMwpkvCl7wE5iuSWzl0Yt1SnNL3LcgtGXdtaXYxbDkGMS8a5bexrekwILvSWILCjGWdgZmbO4Kxx7mweMIT0NyzfBsaKsQYwtgPzW1sSieRER(elRyHfB5yrHEpvvWIlBcpiCJ80KlvqmXYk2YXIc9EQ(Qe4OSnNcIjwF)ylh7pbAcflk67WLaH0nwF)ylhldq(hiRCQskxkymbgpmbKyHhlClFTyvSmscGusN1Js206rj2KLDlVCekw4SfA5RGofqtwEYLacpymZeGItEDTZyryk2sEvSSIfwSOqVNcdDeyiAmMzcqtUu5sQQBStXQtS((XclwhJGXJKaiL0flBJvNyzfl5saHhmMzciweMID(cILvSWIff69uyOJadrJXmtaAYLkxsvDJDk2pXYkwuO3t5mycmengZmbOjxQCjv1n2Py)el8yHhl8yzfB5yHf7pbAcflk67OOl2Py1jwwXs1S)LHCIwlUyNITuSWJLvSLJfwSogbJhjbqkPtPzm3RbsSimf7Nyzf7pbAcflk67GXKAXofRoXYkwQM9VmKt0AXf7uSFIfULNQzBolpg6iWWLGwxXMwp(uGLDlVCekw4SfA5RGofqtwEYLacpymZeGItEDTZyryk2sFILvSWIff69uodMadrJXmtaAYLkxsvDJDkwDI13pwyX(tGMqXII(oCOXIqSLILvSogbJhjbqkPt5sc8imow2gRoXYkwYLacpymZeqSimfRoFILvSLJff69uoOdftFffetSWJfESSITCSWI9NanHIff9Du0f7uS6elRyPA2)YqorRfxStXwkw4XYk2YXclwhJGXJKaiL0P0mM71ajweMI9tSSILQz)ld5eTwCXY2PyNpwwX(tGMqXII(oymPwStXQtSWT8unBZz5DgmbgZauwKnTE8PKLDlVCekw4SfA5RGofqtwEyX6yemEKeaPKoLljWJW4yzBS6elRyHfB5yrHEpLlja2a4uqmX67hlk07PCjbWgaNciAuFUyryk25JfES((Xk6rQqPmYwtIDUIfwSKlbeEWyMjGy9sSZxqSWJfHytcGusv2AYindUwIfESSIfwSLJff69uvblUSj8GWnYttUubXelRylhlk07P6RsGJY2CkiMy99J9NanHIff9D4sGq6glBJ9tS((XwowgG8pqw5uLuUKaoiasjw4wEQMT5S8UKaoiasXMwp(8XYULxocflC2cT8vqNcOjlVJrW4rsaKs6uUKapcJJfHPy1jwwXcl2YXIc9EkxsaSbWPGyI13pwuO3t5scGnaofq0O(CXIWuSZhlClpvZ2CwExsGhHX206XhDSSB5LJqXcNTqlFf0PaAYYtUeq4bJzMauCYRRDglcXwQGy9owrpsfkLr2AsSEj2sQ5y5PA2MZYFYSHMXC206XN5TSB5LJqXcNTqlFf0PaAYYtUeq4bJzMauCYRRDglcX(PGy9owrpsfkLr2AsSEj2sQ5y5PA2MZYxeHFdnJ5SP1JpZXYULxocflC2cT8vqNcOjlp5saHhmMzcqXjVU2zSie78feR3Xk6rQqPmYwtI1lXwsnhlpvZ2Cw(hegp0mMZMwp(4vw2T8YrOyHZwOLVc6uanz5HflSyrHEp1mcaAdyyEdbdDIcIjwF)yrHEpfg6iWq0ymZeGMCPcIjwF)yDmcgpscGusxSimfRoXYk2YXIc9EkNbtGHOXyMjan5sfetSWJLvSWITCSOqVNQkyXLnHheUrEAYLkiMyzfB5yrHEpvFvcCu2MtbXeRVFS)eOjuSOOVdxces3yzBSFI13p2YXYaK)bYkNQKcdDey4sqRRel8y99JfwS)eOjuSOOVdoxSSITCSOqVNIJMD9HC4GofetSWJfESSITCSWI1Xiy8ijasjDknJ5EnqIfHPy)elRyPA2)YqorRfxSSDk25JLvSWI9NanHIff9DWysTyNIvNy99J9NanHIff9DWysTyNI9tSSILQz)ld5eTwCXof7NyHhlClpvZ2CwEm0rGHlbTUInTE8rVTSB5LJqXcNTqlFf0PaAYYdl2YXIc9EQQGfx2eEq4g5PjxQGyILvSLJff69u9vjWrzBofetS((X(tGMqXII(oCjqiDJLTX(jwF)ylhldq(hiRCQskNbtGXmaLffl8yzfB5yHfRJrW4rsaKs6uAgZ9AGelctX(jwwXs1S)LHCIwlUyz7uSZhlRyHf7pbAcflk67GXKAXofRoX67h7pbAcflk67GXKAXof7NyzflvZ(xgYjAT4IDk2pXcpw4wEQMT5S8odMaJzaklYMwp(uCl7wE5iuSWzl0YxbDkGMS8WITCSOqVNQkyXLnHheUrEAYLkiMyzfB5yrHEpvFvcCu2MtbXeRVFSLJ9NanHIff9D4sGq6gRVFSLJLbi)dKvovjLd6EnqIfESSITCSWI9NanHIff9DWysTyryk2pXYkwhJGXJKaiL0P0mM71ajweMI9tSWT8unBZz5Dq3RbInTE8Hnzz3Yt1SnNLxZyUxdelVCekw4SfAtBA5zas1OHsPLDRhLSSB5LJqXcNTqBA94JLDlVCekw4SfAtRh6yz3YlhHIfoBH206X8w2T8YrOyHZwOL)NWqILN(kGofLlbcPBFihUKaofGoDT8unBZz5)jqtOyXY)tGXrAILN(oCjqiDTP1J5yz3YlhHIfoBHw(FcdjwE6Ra6uuC0SRpKdh0Pa0PRLNQzBol)pbAcflw(FcmostS803bNZMwp8kl7wE5iuSWzl0Y)tyiXYtFfqNIYbDOy6ROa0PRLNQzBol)pbAcflw(FcmostS803Hd1Mwp0Bl7wE5iuSWzl0Y)tyiXYtFfqNIQOgzrJZyofGoDT8unBZz5)jqtOyXY)tGXrAILN(ok6SP1JIBz3YlhHIfoBHwEQMT5S8)eOjuSy5)jmKy5PVcOtrXyMjGH5nYIKHMXCkaD6A5RGofqtw(KWYLQCwFdnJ5Ck5iuSWz5)jW4inXYtFhmMuZMwpytw2T8unBZz51mMt3(gpdqZYlhHIfoBH206rPcSSB5LJqXcNTqBA9Oujl7wEQMT5S8mMSnNLxocflC2cTP1JsFSSB5PA2MZY7mycmMbOSilVCekw4SfAtBAtl)VaCT5SE8PGsfVGIxWCuL075WMS8ZiW1hsNLNnJgJbKcxSFILQzBUyXTlDQarlVJrQwpkvWhlpdW8ASy5zJyzZ1JuHsHlwu5zasSvJgkLXIki7ZPI1RTwfM0f7zoVMIiG2dchlvZ2CUynhUyQarQMT5CkgGunAOuo9WKt3arQMT5CkgGunAOu69KNpJHlqKQzBoNIbivJgkLEp5jbHutUKY2CbISrSETFfqNsS)eOjuS4cePA2MZPyas1OHsP3tE(tGMqXI(hPjt03HlbcPR()egsMOVcOtr5sGq62hYHljGtbOt3arQMT5CkgGunAOu69KN)eOjuSO)rAYe9DW50)NWqYe9vaDkkoA21hYHd6ua60nqKQzBoNIbivJgkLEp55pbAcfl6FKMmrFhou9)jmKmrFfqNIYbDOy6ROa0PBGiBeRxFJSOy9WyU5oqKnITe7ZDS6ONypJOXOFSF0tSNXXqA6hBj9e7zCmKwGiBe7h2N7y1rpXkAm6h7h9e7zaAew)ylPNypdqJWbIunBZ5umaPA0qP07jp)jqtOyr)J0Kj67OOt)Fcdjt0xb0POkQrw04mMtbOt3ar2iw9cZmbeR5fBwKelBwJ5M7ar2i2pSp3XQJEI9mIgJ(X(rpXkAm6hBj9e7zaAeoqKnIvh2N7y1rpXIDIgJ(X(rpXEgGgH1p2s6j2Za0iCGiBe78Sp3XQJEIf7eng9J9JEI9mancRFSL0tSNbOr4arQMT5CkgGunAOu69KN)eOjuSO)rAYe9DWysn9)jmKmrFfqNIIXmtadZBKfjdnJ5ua60v)(nLewUuLZ6BOzmNtjhHIfUarQMT5CkgGunAOu69KNAgZPBFJNbOfiYgXYFeJRitglGAUyrHEpHlwxsPlwu5zasSvJgkLXIki7ZflDCXYaeVggtM9Hm22flN5evGivZ2CofdqQgnuk9EYt3rmUIm5WLu6cePA2MZPyas1OHsP3tEYyY2CbIunBZ5umaPA0qP07jpDgmbgZauwuGyGiBelBUEKkukCXk)cOyXMTMeBwKelvtdi22fl9tnMqXIkqKQzBo3KZGjWaviTarQMT5CEp5jJjBZPF)MqHEpvvWIlBcpiCJ80Klvqm((OqVNQVkbokBZPGycePA2MZ59KNOyJHB8Gaft)(nHc9EQQGfx2eEq4g5PjxQGy89rHEpvFvcCu2MtbXeis1SnNZ7jprfGta62hs973ek07PQcwCzt4bHBKNMCPcIX3hf69u9vjWrzBofetGivZ2CoVN8Kav6KrAaa5s973ek07PQcwCzt4bHBKNMCPcIX3hf69u9vjWrzBofetGivZ2CoVN8e3ilkDdVoioKAYL63VjuO3tvfS4YMWdc3ipn5sfeJVpk07P6RsGJY2CkiMarQMT5CEp55Rbck2y40VFtOqVNQkyXLnHheUrEAYLkigFFuO3t1xLahLT5uqmbIunBZ58EYt6QIlbeEujmw)(nHc9EQQGfx2eEq4g5PjxQGy89rHEpvFvcCu2MtbXeis1SnNZ7jpHCYOtrZfiYgXQxPx6cePA2MZ59KNZiaOnGH5nem0jbIunBZ58EYZ(ob8tPOF)MOVcOtrH7FbxSHJPbDQKJqXchlyvJbZzMDQ(Qe4OSnNcIX3VAmyoZStvfS4YMWdc3ipn5sfq0O(CST0h4SGbdgGAUH8lxQiooNIdcqzBoVuAoWNlyZdNTWauZnKF5sfXX5u95LsfVa4W99HbOMBi)YLkIJZPGyGdpqKQzBoN3tE2xLahLT50VFtKlbeEWyMjaeMMVawWGbdqn3q(LlvehNtXbbOSnNx0Pa4ZfS5HZwyaQ5gYVCPI44CQ(8sPIxaC4((WauZnKF5sfXX5uqmWHhis1SnNZ7jpRcwCzt4bHBKNMCP(9BICjGWdgZmbGW08fWcwz6Ra6uu4(xWfB4yAqNk5iuSW57Jc9EkC)l4InCmnOtfedCwWGbdqn3q(LlvehNtXbbOSnNxknh4ZfS5HZwyaQ5gYVCPI44CQ(8sPIxaC4((WauZnKF5sfXX5uqmWHhis1SnNZ7jpFqGInmVHGHor)(nbdgma1Cd5xUurCCofheGY2CEP4WNlyZdNTWauZnKF5sfXX5u95fVQa4W99HbOMBi)YLkIJZPGyGdNfmyOqVNQkyXLnHheUrEAYLkigFFuO3t1xLahLT5uqmW99HvngmNz2PQcwCzt4bHBKNMCPciAuFoe0PaF)QXG5mZovFvcCu2MtbenQphc6uaC4bIunBZ58EYZNbuLH5nokHaI(9Bcgk07PQcwCzt4bHBKNMCPcIX3hf69u9vjWrzBofedCFFyvJbZzMDQQGfx2eEq4g5PjxQaIg1NdbDkW3VAmyoZSt1xLahLT5uarJ6ZHGofapqKnIvV0WUlqKQzBoN3tE6GUxde9RfRILrsaKs6MkPF)MaYdiUIiuSWcg5saHhmMzcqXjVU2jct6nRKaiLuLTMmsZGRfeMJAEwWkJc9EQQGfx2eEq4g5PjxQGyyvgf69u9vjWrzBofeJVF5Fc0ekwu03HlbcPRVFzgG8pqw5uLuoO71abUV)pbAcflk67OOBsh4bIunBZ58EYtnJ5Enq0VwSkwgjbqkPBQK(9BcipG4kIqXclyKlbeEWyMjafN86ANimP3SscGusv2AYindUwqWRuEflyLrHEpvvWIlBcpiCJ80KlvqmSkJc9EQ(Qe4OSnNcIX3V8pbAcflk67WLaH013Vmdq(hiRCQsknJ5EnqGdpqKQzBoN3tE6sbJjW4HjGOFTyvSmscGus3uj973eqEaXveHIfwWixci8GXmtako511oryQ0hwjbqkPkBnzKMbxliO3QpSGvgf69uvblUSj8GWnYttUubXWQmk07P6RsGJY2CkigF)Y)eOjuSOOVdxcesxF)Yma5FGSYPkPCPGXey8WeqGdpqKnILnxJXmtaAYLXwjMyRfjvDdePA2MZ59KNyOJadxcADf973e5saHhmMzcqXjVU2jctL8kwWqHEpfg6iWq0ymZeGMCPYLuv3jD89H5yemEKeaPKo2QdlYLacpymZeactZxalyOqVNcdDeyiAmMzcqtUu5sQQ70hwOqVNYzWeyiAmMzcqtUu5sQQ70h4WHZQmSFc0ekwu03rr3KoSOA2)YqorRf3uj4SkdZXiy8ijasjDknJ5Enqqy6dRFc0ekwu03bJj1M0HfvZ(xgYjAT4M(apqKQzBoN3tE6mycmMbOSi973e5saHhmMzcqXjVU2jctL(Wcgk07PCgmbgIgJzMa0KlvUKQ6oPJVpSFc0ekwu03HdfHsSCmcgpscGusNYLe4rymB1Hf5saHhmMzcaHjD(WQmk07PCqhkM(kkig4Wzvg2pbAcflk67OOBshwun7FziNO1IBQeCwLH5yemEKeaPKoLMXCVgiim9HfvZ(xgYjAT4y708S(jqtOyrrFhmMuBsh4bISrS61MKY2CbIunBZ58EYtxsaheaPOF)MG5yemEKeaPKoLljWJWy2QdlyLrHEpLlja2a4uqm((OqVNYLeaBaCkGOr95qyAE4((IEKkukJS1K5cg5saHhmMzcWlZxaCescGusv2AYindUwGZcwzuO3tvfS4YMWdc3ipn5sfedRYOqVNQVkbokBZPGy89)jqtOyrrFhUeiKUS9JVFzgG8pqw5uLuUKaoiasbEGivZ2CoVN80Le4ryS(9BYXiy8ijasjDkxsGhHXimPdlyLrHEpLlja2a4uqm((OqVNYLeaBaCkGOr95qyAE4bIunBZ58EYZtMn0mMt)(nrUeq4bJzMauCYRRDIqPc8w0JuHszKTM4LsQ5eis1SnNZ7jplIWVHMXC63VjYLacpymZeGItEDTte(uG3IEKkukJS1eVusnNarQMT5CEp55dcJhAgZPF)Mixci8GXmtako511ory(c8w0JuHszKTM4LsQ5eis1SnNZ7jpXqhbgUe06k63VjyWqHEp1mcaAdyyEdbdDIcIX3hf69uyOJadrJXmtaAYLkigFFhJGXJKaiL0HWKoSkJc9EkNbtGHOXyMjan5sfedCwWkJc9EQQGfx2eEq4g5PjxQGyyvgf69u9vjWrzBofeJV)pbAcflk67WLaH0LTF89lZaK)bYkNQKcdDey4sqRRa33h2pbAcflk67GZXQmk07P4OzxFihoOtbXahoRYWCmcgpscGusNsZyUxdeeM(WIQz)ld5eTwCSDAEwW(jqtOyrrFhmMuBshF)Fc0ekwu03bJj1M(WIQz)ld5eTwCtFGdpqKQzBoN3tE6mycmMbOSi973eSYOqVNQkyXLnHheUrEAYLkigwLrHEpvFvcCu2MtbX47)tGMqXII(oCjqiDz7hF)Yma5FGSYPkPCgmbgZauweCwLH5yemEKeaPKoLMXCVgiim9HfvZ(xgYjAT4y708SG9tGMqXII(oymP2Ko(()eOjuSOOVdgtQn9HfvZ(xgYjAT4M(ahEGivZ2CoVN80bDVgi63VjyLrHEpvvWIlBcpiCJ80KlvqmSkJc9EQ(Qe4OSnNcIX3V8pbAcflk67WLaH013Vmdq(hiRCQskh09AGaNvzy)eOjuSOOVdgtQHW0hwogbJhjbqkPtPzm3RbcctFGhis1SnNZ7jp1mM71aXM20Ab]] )

    
end