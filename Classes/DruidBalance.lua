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


        -- Azerite Powers
        dawning_sun = {
            id = 276153,
            duration = 8,
            max_stack = 1,
        },

        sunblaze = {
            id = 274399,
            duration = 20,
            max_stack = 1
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

                if azerite.dawning_sun.enabled then applyBuff( "dawning_sun" ) end
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
            essential = true,
            
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
                removeBuff( "dawning_sun" )
                if azerite.sunblaze.enabled then applyBuff( "sunblaze" ) end
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
            
            spend = function ()
                if buff.oneths_overconfidence.up then return 0 end
                return talent.soul_of_the_forest.enabled and 40 or 50
            end,
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
                removeBuff( "sunblaze" )

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
    
        potion = "potion_of_rising_death",
    
        package = "Balance",        
    } )


    spec:RegisterPack( "Balance", 20180922.2253, [[dCKH2aqiqQhrfXLKi1MOGrbrNcswLsv8kQqZsc6wurQDrYVGknmOQoMsXYKOEgvW0GkCnLQ02OqX3KiPXPusNtPQyDsKyEqfDpqSpLkhuPQuluc8qkuQjsHsUivKuBKkssNKksIvcsUPsvj2PeXqvQQSuQiXtPOPsf1xvQQQ9sv)vjdwXHjwmk9yjnzOCzKnRkFgcJwPuNwQvRuvsVMcz2O62GA3Q8BsnCuCCLQQSCGNtPPl66QQTdP(UeA8uO68kLy9qvMpvA)c734D2BIjj5lPm(B2k(7t5YQYL3RdoSXBMBHH8Mms1ibb5npbM8MfiC5QK3Kr2cxlyEN9Mw9hujV52zYylfCXfrNB)zvvnmU2g(ZLS1xfiVexBdxXLLRzXL9jongHgxgG(1CYI7(biNI0ywC3pNYYyb(n2QaHlxLu2gU6nz)npDQCEwVjMKKVKY4VzR4VpLlRkxU8wDyVEt5NBRbEtZg2y7nXiB1B6Kykq4YvPymwGFJfq5Ky2otgBPGlUi6C7pRQQHX12WFUKT(Qa5L4AB4kUSCnlUSpXPXi04Ya0VMtwC3pa5uKgZI7(5uwglWVXwfiC5QKY2W1akNeJjXKemlbIPC5cJPm(B2AmoDmBWVukV3y2V9LaQakNeJXEB5qq2sjGYjX40XSVXWiSym1CbetbKaRcOCsmoDmg7TLdbHftkaeuU6xmvXs2ysDm1Tu50kfackTkVjVTP17S3eJEYNNEN9LSX7S3KoHLty(c8MvqNeOfVj7)9uvIt2Sf(s4nIdMUu9zIX1ng2)7P6RkGtYwFQpJ3uQzRpVjJoB95tFjL9o7nLA26ZBA1CbSyjb2BsNWYjmFb(0xIdEN9M0jSCcZxG3Sc6KaT4nz)VNQsCYMTWxcVrCW0LQptmUUXW(FpvFvbCs26t9z8MsnB95nz5An269bBXN(sWH3zVjDclNW8f4nRGojqlEt2)7PQeNSzl8LWBehmDP6ZeJRBmS)3t1xvaNKT(uFgVPuZwFEtwcyjGr9HWN(s2R3zVjDclNW8f4nRGojqlEt2)7PQeNSzl8LWBehmDP6ZeJRBmS)3t1xvaNKT(uFgVPuZwFEtbuLJwPgaOl9PVeJX7S3KoHLty(c8MvqNeOfVj7)9uvIt2Sf(s4nIdMUu9zIX1ng2)7P6RkGtYwFQpJ3uQzRpVjVrSDAx7RFmeW0L(0xsP6D2BsNWYjmFbEZkOtc0I3K9)EQkXjB2cFj8gXbtxQ(mX46gd7)9u9vfWjzRp1NXBk1S1N381aILR1y(0xYw9o7nPty5eMVaVzf0jbAXBY(FpvL4KnBHVeEJ4GPlvFMyCDJH9)EQ(Qc4KS1N6Z4nLA26ZBkxLSjq4RQW5(0xY(4D2BsNWYjmFbEZkOtc0I3K2F)MHHWucEFaLBRTlBFiiSfd)dliOymedYyQAnhtx8u9vfWjzRpfGGL(SXSlghWpgx3yQAnhtx8uvIt2Sf(s4nIdMUubiyPpBm7IXb8JbL38eyYBk49buUT2US9HGWwm8pSGG8MsnB95nf8(ak3wBx2(qqylg(hwqq(0xYg89o7nPty5eMVaVzf0jbAXBs7VFZWqyQngZM9b)YXyigKXu1AoMU4P6RkGtYwFkabl9zJzxmoGFmUUXu1AoMU4PQeNSzl8LWBehmDPcqWsF2y2fJd4hdkV5jWK3edqc2cbxWAj1a7IvWqqEtPMT(8MFlT6KG9PVKnB8o7nLA26ZB(T0Qtc26nPty5eMVaF6lztzVZEtPMT(8MffaO1GL(Ti()iVjDclNW8f4tFjBCW7S3KoHLty(c8MvqNeOfVPGhb6Ku8gnX3YYY0Gov0jSCclgdXGmMQwZX0fpvFvbCs26t9zIX1nMQwZX0fpvL4KnBHVeEJ4GPlvacw6ZgdoJzt5yqfJHyqgdYyqgdqASfHMUujyywf2hizRVykDmB2BmOIzpXGmgCedQyWzmiJbin2IqtxQemmRQVykDmB2k(XGkguX46gdYyasJTi00LkbdZQ(mXGkguEtPMT(8M9DeaTKKp9LSbhEN9M0jSCcZxG3Sc6KaT4nfBce(IrxKaXSdsm4a)ymedYyqgdYyasJTi00LkbdZQW(ajB9ftPJXb8Jbvm7jgKXGJyqfdoJbzmaPXweA6sLGHzv9ftPJzZwXpguXGkgx3yqgdqASfHMUujyyw1NjguXGYBk1S1N3SVQaojB95tFjB2R3zVjDclNW8f4nRGojqlEtXMaHVy0fjqm7GedoWpgdXGmgOJrWJaDskEJM4BzzzAqNk6ewoHfJRBmS)3tXB0eFllltd6u9zIbvmgIbzmiJbzmaPXweA6sLGHzvyFGKT(IP0XSzVXGkM9edYyWrmOIbNXGmgG0ylcnDPsWWSQ(IP0XSzR4hdQyqfJRBmiJbin2IqtxQemmR6ZedQyq5nLA26ZBwjozZw4lH3ioy6sF6lzJX4D2BsNWYjmFbEZkOtc0I3ezmiJbzmaPXweA6sLGHzvyFGKT(IP0XS1yqfZEIbzm4iguXGZyqgdqASfHMUujyywvFXu6ymg8JbvmOIX1ngKXaKgBrOPlvcgMv9zIbvmOIXqmiJbzmS)3tvjozZw4lH3ioy6s1Njgx3yy)VNQVQaojB9P(mXGkgx3yqgtvR5y6INQsCYMTWxcVrCW0Lkabl9zJzxmoGFmUUXu1AoMU4P6RkGtYwFkabl9zJzxmoGFmOIbL3uQzRpV57d2Ys)we)FKp9LSPu9o7nPty5eMVaVzf0jbAXBImg2)7PQeNSzl8LWBehmDP6ZeJRBmS)3t1xvaNKT(uFMyqfJRBmiJPQ1CmDXtvjozZw4lH3ioy6sfGGL(SXSlghWpgx3yQAnhtx8u9vfWjzRpfGGL(SXSlghWpguEtPMT(8MpnOsl9BDs(bKp9LSzREN9M0jSCcZxG3uQzRpVP9FVgqEZkOtc0I3eqpaz3wy5umgIbzmInbcFXOlsafg96ANXSdsmLAmgIjfackvzdtRuVWAkMDXSxfoIXqmiJb6yy)VNQsCYMTWxcVrCW0LQptmgIb6yy)VNQVQaojB9P(mX46gd0XGwaTWYjLG3YMasmkgx3yGoggaHEHOIP2OS)71akguXyigKXaRrtW0LkS2MYvPy2fd(X46gdqASfHMUubRrtW0LQ(Izxmacw6ZgJRBmacw6ZgdoHedzCQ(tALnmfZEIPCmOIbL3SULkNwPaqqP1xYgF6lzZ(4D2BsNWYjmFbEtPMT(8MWA99Aa5nRGojqlEta9aKDBHLtXyigKXi2ei8fJUibuy0RRDgZoiXuQXyiMuaiOuLnmTs9cRPy2fJXOmMymedYyGog2)7PQeNSzl8LWBehmDP6ZeJHyGog2)7P6RkGtYwFQptmUUXaDmOfqlSCsj4TSjGeJIX1ngOJHbqOxiQyQnkyT(EnGIbvmgIbzmWA0emDPcRTPCvkMDXGFmUUXaKgBrOPlvWA0emDPQVy2fdGGL(SX46gdGGL(SXGtiXqgNQ)KwzdtXSNykhdQyq5nRBPYPvkaeuA9LSXN(skJV3zVjDclNW8f4nLA26ZBAtIZfW6Xfa5nRGojqlEta9aKDBHLtXyigKXi2ei8fJUibuy0RRDgZoiXSPCmgIjfackvzdtRuVWAkMDXuQQYXyigKXaDmS)3tvjozZw4lH3ioy6s1NjgdXaDmS)3t1xvaNKT(uFMyCDJb6yqlGwy5KsWBztajgfJRBmqhddGqVquXuBu2K4CbSECbqXGkguEZ6wQCALcabLwFjB8PVKYB8o7nPty5eMVaVzf0jbAXBk2ei8fJUibuy0RRDgZoiXSXyIXqmiJH9)Ek()eWIGz0fjamDPYMs1OyGeJdX46gdYySmeNVsbGGsBm4mghIXqmInbcFXOlsGy2bjgCGFmgIbzmS)3tX)NawemJUibGPlv2uQgfdKykhJHyy)VNYQ5cyrWm6IeaMUuztPAumqIPCmOIbvmOIXqmqhdYySmeNVsbGGsRcwRVxdOy2bjMYXyig0cOfwoPe8wm6eogiX4qmgIrQzJMw0rWnzJbsmLJbL3uQzRpVj)FcyztqBe5tFjLl7D2BsNWYjmFbEZkOtc0I3uSjq4lgDrcOWOxx7mMDqIzt5ymedYyy)VNYQ5cyrWm6IeaMUuztPAumqIXHyCDJbzmOfqlSCsj4TSSXSlMnXyigldX5RuaiO0QSPaEcNhdoJXHymeJytGWxm6IeiMDqIXHYXyigOJH9)Ek7)y5cEK6ZedQyqfJHyGogKXyzioFLcabLwfSwFVgqXSdsmLJXqmsnB00IocUjBm4esm4igdXGwaTWYjLG3IrNWXajghIbvmUUXGmg0cOfwoPe8w2eqIrXyigKXW(FpvL4KnBHVeEJ4GPlvFMyCDJH9)EQ(Qc4KS1N6ZedQymed0XWai0levm1gLvZfWQiqYTJXqmInbcFXOlsafg96ANXSdsmBkhdkVPuZwFEtRMlGvrGKB7tFjLDW7S3KoHLty(c8MvqNeOfVjYySmeNVsbGGsRYMc4jCEm4mghIXqmiJb6yy)VNYMcGRbyQptmUUXW(FpLnfaxdWuacw6ZgZoiXGJyqfJRBmKXP6pPv2Wum7jgKXi2ei8fJUibIP0XGd8Jbvm7IjfackvzdtRuVWAkguXyigKXaDmS)3tvjozZw4lH3ioy6s1NjgdXaDmS)3t1xvaNKT(uFMyCDJbTaAHLtkbVLnbKyum4mMYX46gd0XWai0levm1gLnfG9dqqXGkgdXGmgG0ylcnDPcwJMGPlv9fZUyqgd7)9u8)jGfbZOlsay6sLnLQrXSNyKA26tX)Naw2e0grkY4u9N0kBykghJH9)EkRMlGfbZOlsay6sLnLQrXSNyKA26tz1CbSkcKCBfzCQ(tALnmfdQyCDJbzmInbcFXOlsGyCmg2)7P4)talcMrxKaW0LkBkvJIzpXSPCmogd7)9uwnxalcMrxKaW0LkBkvJIzpXS1yqfZoiXSpgtmO8MsnB95nTPaSFacYN(skJdVZEt6ewoH5lWBwbDsGw8MwgIZxPaqqPvztb8eopMDqIXHymedYyGog2)7PSPa4AaM6ZeJRBmS)3tztbW1amfGGL(SXSdsm4iguEtPMT(8M2uapHZ9PVKY717S3KoHLty(c8MvqNeOfVPytGWxm6IeqHrVU2zm7Izd(X4ymKXP6pPv2WumLoMnQ96nLA26ZBEuXfSwF(0xszJX7S3KoHLty(c8MvqNeOfVPytGWxm6IeqHrVU2zm7IPm(X4ymKXP6pPv2WumLoMnQ96nLA26ZBUTWFlyT(8PVKYLQ3zVjDclNW8f4nRGojqlEtXMaHVy0fjGcJEDTZy2fdoWpghJHmov)jTYgMIP0XSrTxVPuZwFEZ3NZxWA95tFjL3Q3zVjDclNW8f4nRGojqlEtKXGmg2)7PkkaqRbl9Br8)rQptmUUXW(Fpf)FcyrWm6IeaMUu9zIX1ngldX5RuaiO0gZoiX4qmgIb6yy)VNYQ5cyrWm6IeaMUu9zIbvmgIbzmqhd7)9uvIt2Sf(s4nIdMUu9zIXqmqhd7)9u9vfWjzRp1Njgx3yqlGwy5KsWBztajgfdoJPCmUUXaDmmac9crftTrX)Naw2e0grXGkgx3yqgdAb0clNucElmBmgIb6yy)VNctkE9Hyz)N6ZedQyqfJHyGogKXyzioFLcabLwfSwFVgqXSdsmLJXqmsnB00IocUjBm4esm4igdXGmg0cOfwoPe8wm6eogiX4qmUUXGwaTWYjLG3IrNWXajMYXyigPMnAArhb3KngiXuoguXGYBk1S1N3K)pbSSjOnI8PVKY7J3zVjDclNW8f4nRGojqlEtKXaDmS)3tvjozZw4lH3ioy6s1NjgdXaDmS)3t1xvaNKT(uFMyCDJbTaAHLtkbVLnbKyum4mMYX46gd0XWai0levm1gLvZfWQiqYTJbvmgIb6yqgJLH48vkaeuAvWA99AafZoiXuogdXi1Srtl6i4MSXGtiXGJymedYyqlGwy5KsWBXOt4yGeJdX46gdAb0clNucElgDchdKykhJHyKA2OPfDeCt2yGet5yqfdkVPuZwFEtRMlGvrGKB7tFjoGV3zVjDclNW8f4nRGojqlEtKXaDmS)3tvjozZw4lH3ioy6s1NjgdXaDmS)3t1xvaNKT(uFMyCDJb6yqlGwy5KsWBztajgfJRBmqhddGqVquXuBu2)9AafdQymed0XGmg0cOfwoPe8wm6eoMDqIPCmgIXYqC(kfackTkyT(EnGIzhKykhdkVPuZwFEt7)EnG8PVeh24D2Bk1S1N3ewRVxdiVjDclNW8f4tF6nzauvdZkP3zFjB8o7nPty5eMVaF6lPS3zVjDclNW8f4tFjo4D2BsNWYjmFb(0xco8o7nPty5eMVaVjAH)jVPGhb6Ku2eqIr9Hyztbyva5mYBk1S1N3eTaAHLtEt0cyDcm5nf8w2eqIr(0xYE9o7nPty5eMVaVjAH)jVPGhb6KuysXRpel7)ua5mYBk1S1N3eTaAHLtEt0cyDcm5nf8wywF6lXy8o7nPty5eMVaVjAH)jVPGhb6Ku2)XYf8ifqoJ8MsnB95nrlGwy5K3eTawNatEtbVLL1N(skvVZEt6ewoH5lWBk1S1N3eTaAHLtEt0c)tEtbpc0jPy0fjWs)w520cwRpfqoJ8MvqNeOfVzkC6svwSVfSwFwfDclNW8MOfW6eyYBk4Ty0jSp9LSvVZEtPMT(8MWA9zuFRNga7nPty5eMVaF6lzF8o7nPty5eMVaF6lzd(EN9MsnB95nz0zRpVjDclNW8f4tFjB24D2Bk1S1N30Q5cyvei52Et6ewoH5lWN(0NEt0eW26Zxsz83Sv83Az8vB2ko2R3SOaU(qy9MovGz0GKWIPCmsnB9fdVTPvfq5nTmu1xYg8l7nza6xZjVPtIPaHlxLIXyb(nwaLtIz7mzSLcU4IOZT)SQQggxBd)5s26RcKxIRTHR4YY1S4Y(eNgJqJldq)AozXD)aKtrAmlU7NtzzSa)gBvGWLRskBdxdOCsmMetsWSeiMYLlmMY4VzRX40XSb)sP8EJz)2xcOcOCsmg7TLdbzlLakNeJthZ(gdJWIXuZfqmfqcSkGYjX40XyS3woeewmPaqq5QFXuflzJj1Xu3sLtRuaiO0QcOcOCsmo1gNQ)KWIHLEAaftvdZkzmSeI(SQy231kXK2yo950Bla43NhJuZwF2y0hFlQakPMT(Skgav1WSsc5XfRrbusnB9zvmaQQHzL0ri4(0ASakPMT(Skgav1WSs6ieCLpcy6sjB9fq5Ky234rGoPyqlGwy5KnGYjXyMasmQpeXyMcWwkbuojgJTyZym3)XiVKaXqOjWwI50NtBU)JXYqCEm)JtwBmvHHPpefgJ5(pgtNQXyU)JPFX80GkHPcOKA26ZQyauvdZkPJqWfTaAHLtfEcmbrWBztajgviAH)jicEeOtsztajg1hILnfGvbKZOakPMT(Skgav1WSs6ieCrlGwy5uHNatqe8wy2crl8pbrWJaDskmP41hIL9FkGCgfqj1S1NvXaOQgMvshHGlAb0clNk8eycIG3YYwiAH)jicEeOtsz)hlxWJua5mkGYjXSF6Ieig9lMCBkM9fT(kLakNetzNlLyCW4XCAcMPWykB8yiyMcJzJXJ50ayHhq5KyCW5sjghmEmClbZuymLnEmNgal8cJzJXJ50ayHhq5KyWHZLsmoy8y4wcMPWykB8yonaw4fgZgJhZPbWcpGsQzRpRIbqvnmRKocbx0cOfwov4jWeebVfJoHleTW)eebpc0jPy0fjWs)w520cwRpfqoJkSFqsHtxQYI9TG16ZQOty5ewaLuZwFwfdGQAywjDecUWA9zuFRNgahq5KympHXUToJbinwmS)3JWIXMsAJHLEAaftvdZkzmSeI(SXihwmmaYPz0z2hIyABmy6JubusnB9zvmaQQHzL0ri4ApHXUTox2usBaLuZwFwfdGQAywjDecUm6S1xaLuZwFwfdGQAywjDecUwnxaRIaj3oGkGYjX4uBCQ(tclgcnb2smzdtXKBtXi1udIPTXiOLMlSCsfqj1S1NfcJoB9vy)GW(FpvL4KnBHVeEJ4GPlvFgxx2)7P6RkGtYwFQptaLuZwFwhHGRvZfWILe4akPMT(SocbxwUwJTEFWwkSFqy)VNQsCYMTWxcVrCW0LQpJRl7)9u9vfWjzRp1NjGsQzRpRJqWLLawcyuFikSFqy)VNQsCYMTWxcVrCW0LQpJRl7)9u9vfWjzRp1NjGsQzRpRJqWvav5OvQba6Yc7he2)7PQeNSzl8LWBehmDP6Z46Y(FpvFvbCs26t9zcOKA26Z6ieC5nITt7AF9JHaMUSW(bH9)EQkXjB2cFj8gXbtxQ(mUUS)3t1xvaNKT(uFMakPMT(Socb3xdiwUwJvy)GW(FpvL4KnBHVeEJ4GPlvFgxx2)7P6RkGtYwFQptaLuZwFwhHGRCvYMaHVQcNxy)GW(FpvL4KnBHVeEJ4GPlvFgxx2)7P6RkGtYwFQptaLuZwFwhHG73sRoj4cpbMGi49buUT2US9HGWwm8pSGGkSFqO93Vzyim1gJzJdLAPAazvR5y6INQVQaojB9PaeS0NDNd476w1AoMU4PQeNSzl8LWBehmDPcqWsF2DoGpQakPMT(Socb3VLwDsWfEcmbbdqc2cbxWAj1a7IvWqqf2pi0(73mmeMAJXSzFWVSbKvTMJPlEQ(Qc4KS1NcqWsF2DoGVRBvR5y6INQsCYMTWxcVrCW0Lkabl9z35a(OcOKA26Z6ieC)wA1jbBdOcOCsmgBJLnGsQzRpRJqWTOaaTgS0VfX)hfqj1S1N1ri423ra0ssf2picEeOtsXB0eFllltd6urNWYjmdiRAnhtx8u9vfWjzRp1NX1TQ1CmDXtvjozZw4lH3ioy6sfGGL(S4CtzugqIejqASfHMUujyywf2hizRVsVzVO2dsCGcNibsJTi00LkbdZQ6R0B2k(Oq56Iein2IqtxQemmR6ZGcvaLuZwFwhHGBFvbCs26RW(brSjq4lgDrcSdcoW3asKibsJTi00LkbdZQW(ajB9vAhWh1EqIdu4ejqASfHMUujyywvFLEZwXhfkxxKaPXweA6sLGHzvFguOcOKA26Z6ieCReNSzl8LWBehmDzH9dIytGWxm6IeyheCGVbKql4rGojfVrt8TSSmnOtfDclNWCDz)VNI3Oj(wwwMg0P6ZGYasKibsJTi00LkbdZQW(ajB9v6n7f1EqIdu4ejqASfHMUujyywvFLEZwXhfkxxKaPXweA6sLGHzvFguOcOKA26Z6ieCFFWww63I4)JkSFqqIejqASfHMUujyywf2hizRVsVvu7bjoqHtKaPXweA6sLGHzv9vAJbFuOCDrcKgBrOPlvcgMv9zqHYasKS)3tvjozZw4lH3ioy6s1NX1L9)EQ(Qc4KS1N6ZGY1fzvR5y6INQsCYMTWxcVrCW0Lkabl9z35a(UUvTMJPlEQ(Qc4KS1NcqWsF2DoGpkubusnB9zDecUpnOsl9BDs(buH9dcs2)7PQeNSzl8LWBehmDP6Z46Y(FpvFvbCs26t9zq56ISQ1CmDXtvjozZw4lH3ioy6sfGGL(S7CaFx3QwZX0fpvFvbCs26tbiyPp7ohWhvavaLtIXyPD2gqj1S1N1ri4A)3RbuH1Tu50kfackTq2uy)GaOhGSBlSCYasXMaHVy0fjGcJEDTZDqkvdPaqqPkByAL6fwt72Rchgqcn7)9uvIt2Sf(s4nIdMUu9zman7)9u9vfWjzRp1NX1fA0cOfwoPe8w2eqIrUUqZai0levm1gL9FVgqOmGewJMGPlvyTnLRs7W31fin2IqtxQG1Ojy6svF7aeS0N11fqWsFwCcHmov)jTYgM2tzuOcOKA26Z6ieCH1671aQW6wQCALcabLwiBkSFqa0dq2TfwozaPytGWxm6IeqHrVU25oiLQHuaiOuLnmTs9cRPDgJYymGeA2)7PQeNSzl8LWBehmDP6ZyaA2)7P6RkGtYwFQpJRl0OfqlSCsj4TSjGeJCDHMbqOxiQyQnkyT(EnGqzajSgnbtxQWABkxL2HVRlqASfHMUubRrtW0LQ(2biyPpRRlGGL(S4eczCQ(tALnmTNYOqfqj1S1N1ri4AtIZfW6XfavyDlvoTsbGGslKnf2pia6bi72clNmGuSjq4lgDrcOWOxx7ChKnLnKcabLQSHPvQxynTRuvLnGeA2)7PQeNSzl8LWBehmDP6ZyaA2)7P6RkGtYwFQpJRl0OfqlSCsj4TSjGeJCDHMbqOxiQyQnkBsCUawpUaiuOcOcOCsmo1Wm6IeaMUmMQWetDBQAuaLuZwFwhHGl)FcyztqBevy)Gi2ei8fJUibuy0RRDUdYgJXas2)7P4)talcMrxKaW0LkBkvJG4GRlsldX5RuaiO0Ithmi2ei8fJUib2bbh4Baj7)9u8)jGfbZOlsay6sLnLQrqkBG9)EkRMlGfbZOlsay6sLnLQrqkJcfkdqJ0YqC(kfackTkyT(EnG2bPSb0cOfwoPe8wm6egIdgKA2OPfDeCtwiLrfqj1S1N1ri4A1CbSkcKC7c7heXMaHVy0fjGcJEDTZDq2u2as2)7PSAUawemJUibGPlv2uQgbXbxxKOfqlSCsj4TSS72yWYqC(kfackTkBkGNW540bdInbcFXOlsGDqCOSbOz)VNY(pwUGhP(mOqzaAKwgIZxPaqqPvbR13Rb0oiLni1Srtl6i4MS4ecomGwaTWYjLG3IrNWqCaLRls0cOfwoPe8w2eqIrgqY(FpvL4KnBHVeEJ4GPlvFgxx2)7P6RkGtYwFQpdkdqZai0levm1gLvZfWQiqYTni2ei8fJUibuy0RRDUdYMYOcOcOCsmofDkzRVakPMT(SocbxBka7hGGkSFqqAzioFLcabLwLnfWt4CC6GbKqZ(FpLnfaxdWuFgxx2)7PSPa4AaMcqWsF2DqWbkxxY4u9N0kByApifBce(IrxKaLgh4JAxkaeuQYgMwPEH1ekdiHM9)EQkXjB2cFj8gXbtxQ(mgGM9)EQ(Qc4KS1N6Z46IwaTWYjLG3YMasmcNLDDHMbqOxiQyQnkBka7hGGqzajqASfHMUubRrtW0LQ(2HK9)Ek()eWIGz0fjamDPYMs1O9i1S1NI)pbSSjOnIuKXP6pPv2WKJS)3tz1CbSiygDrcatxQSPunApsnB9PSAUawfbsUTImov)jTYgMq56IuSjq4lgDrc4i7)9u8)jGfbZOlsay6sLnLQr7ztzhz)VNYQ5cyrWm6IeaMUuztPA0E2kQDq2hJbvaLuZwFwhHGRnfWt48c7heldX5RuaiO0QSPaEcNVdIdgqcn7)9u2uaCnat9zCDz)VNYMcGRbykabl9z3bbhOcOKA26Z6ieCpQ4cwRVc7heXMaHVy0fjGcJEDTZDBW3rY4u9N0kByQ0Bu7nGsQzRpRJqWDBH)wWA9vy)Gi2ei8fJUibuy0RRDURm(osgNQ)KwzdtLEJAVbusnB9zDecUVpNVG16RW(brSjq4lgDrcOWOxx7ChoW3rY4u9N0kByQ0Bu7nGsQzRpRJqWL)pbSSjOnIkSFqqIK9)EQIca0AWs)we)FK6Z46Y(Fpf)FcyrWm6IeaMUu9zCDTmeNVsbGGs7oioyaA2)7PSAUawemJUibGPlvFgugqcn7)9uvIt2Sf(s4nIdMUu9zman7)9u9vfWjzRp1NX1fTaAHLtkbVLnbKyeol76cndGqVquXuBu8)jGLnbTrekxxKOfqlSCsj4TWSgGM9)EkmP41hIL9FQpdkugGgPLH48vkaeuAvWA99AaTdszdsnB00IocUjloHGddirlGwy5KsWBXOtyio46IwaTWYjLG3IrNWqkBqQzJMw0rWnzHugfQakPMT(SocbxRMlGvrGKBxy)GGeA2)7PQeNSzl8LWBehmDP6ZyaA2)7P6RkGtYwFQpJRlAb0clNucElBciXiCw21fAgaHEHOIP2OSAUawfbsUnkdqJ0YqC(kfackTkyT(EnG2bPSbPMnAArhb3KfNqWHbKOfqlSCsj4Ty0jmehCDrlGwy5KsWBXOtyiLni1Srtl6i4MSqkJcvaLuZwFwhHGR9FVgqf2piiHM9)EQkXjB2cFj8gXbtxQ(mgGM9)EQ(Qc4KS1N6Z46cnAb0clNucElBciXixxOzae6fIkMAJY(VxdiugGgjAb0clNucElgDcVdszdwgIZxPaqqPvbR13Rb0oiLrfqj1S1N1ri4cR13RbKp9P3d]] )

    
end