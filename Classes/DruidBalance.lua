-- DruidBalance.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local PTR = ns.PTR


if UnitClassBase( 'player' ) == 'DRUID' then
    local spec = Hekili:NewSpecialization( 102, true )

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

        celestial_downpour = 183, -- 200726
        celestial_guardian = 180, -- 233754
        crescent_burn = 182, -- 200567
        cyclone = 857, -- 209753
        deep_roots = 834, -- 233755
        dying_stars = 822, -- 232546
        faerie_swarm = 836, -- 209749
        ironfeather_armor = 1216, -- 233752
        moon_and_stars = 184, -- 233750
        moonkin_aura = 185, -- 209740
        prickling_thorns = 3058, -- 200549
        protector_of_the_grove = 3728, -- 209730
        thorns = 3731, -- 236696
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
            tick_time = function () return 2 * haste end,
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
            duration = function () return pvptalent.celestial_downpour.enabled and 16 or 8 end,
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
            tick_time = function () return 2 * haste end,
            type = "Magic",
            max_stack = 1,
        },
        sunfire = {
            id = 164815,
            duration = 18,
            tick_time = function () return 2 * haste end,
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
        -- Alias for Celestial Alignment vs. Incarnation
        ca_inc = {
            alias = { "celestial_alignment", "incarnation" },
            aliasMode = "first", -- use duration info from the first buff that's up, as they should all be equal.
            aliasType = "buff",
            duration = function () return talent.incarnation.enabled and 30 or 20 end,
        },


        -- PvP Talents
        celestial_guardian = {
            id = 234081,
            duration = 3600,
            max_stack = 1,
        },

        cyclone = {
            id = 209753,
            duration = 6,
            max_stack = 1,
        },

        faerie_swarm = {
            id = 209749,
            duration = 5,
            type = "Magic",
            max_stack = 1,
        },

        moon_and_stars = {
            id = 234084,
            duration = 10,
            max_stack = 1,
        },

        moonkin_aura = {
            id = 209746,
            duration = 18,
            type = "Magic",
            max_stack = 3,
        },

        thorns = {
            id = 236696,
            duration = 12,
            type = "Magic",
            max_stack = 1,
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
        removeBuff( "celestial_guardian" )
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
        
        if form == "bear_form" and pvptalent.celestial_guardian.enabled then
            applyBuff( "celestial_guardian" )
        end
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

        -- UGLY
        if talent.incarnation.enabled then
            rawset( cooldown, "ca_inc", cooldown.incarnation )
        else
            rawset( cooldown, "ca_inc", cooldown.celestial_alignment )
        end
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
                if pvptalent.moon_and_stars.enabled then applyBuff( "moon_and_stars" ) end
            end,

            copy = "ca_inc"
        },
        

        cyclone = {
            id = 209753,
            cast = 1.7,
            cooldown = 0,
            gcd = "spell",

            pvptalent = "cyclone",
            
            spend = 0.15,
            spendType = "mana",
            
            startsCombat = true,
            texture = 136022,
            
            handler = function ()
                applyDebuff( "target", "cyclone" )
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
        

        faerie_swarm = {
            id = 209749,
            cast = 0,
            cooldown = 30,
            gcd = "spell",
            
            pvptalent = "faerie_swarm",

            startsCombat = true,
            texture = 538516,
            
            handler = function ()
                applyDebuff( "target", "faerie_swarm" )
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
            talent = "feral_affinity",
            
            usable = function () return combo_points.current > 0 end,
            handler = function ()
                --[[ if target.health.pct < 25 and debuff.rip.up then
                    applyDebuff( "target", "rip", min( debuff.rip.duration * 1.3, debuff.rip.remains + debuff.rip.duration ) )
                end ]]
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

                if pvptalent.moon_and_stars.enabled then applyBuff( "moon_and_stars" ) end
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

                if pvptalent.moonkin_aura.enabled then
                    addStack( "moonkin_aura", nil, 1 )
                end

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
        

        thorns = {
            id = 236696,
            cast = 0,
            cooldown = 45,
            gcd = "spell",

            pvptalent = "thorns",
            
            spend = 0.12,
            spendType = "mana",
            
            startsCombat = false,
            texture = 136104,
            
            handler = function ()
                applyBuff( "thorns" )
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


    spec:RegisterPack( "Balance", 20181211.1732, [[dSuzMaqiGYJGKCjuk1MeP(Kir1OaItPIAvIKQxrPywukDlrs2fv(LuXWaQCmvKLHs1ZKkzAsLY1aQABIe4BOuY4GeoNiPyDIeAEqIUNu1(ashuQu1crjEikfAIIe5IIefBuKG0hfjkDsukkRuentrcQ2jKYqrPGLkvQ8uvAQOKUQibLTIsrLVksqSxO(RugmOdtSyapMIjJIltAZI6ZuQgnvjNwPvlsk9AivZgPBtvTBv9BunCk54Ouu1YL8Cetx46qSDr47ufJhLICEiPwpvPMVkSFfJpHzfFzKqXOXo4oHItSF6K7eB1f7DlfGVbQTu81smOl2v89fFfFzrOYBu81sqnLlmywXxchPmk(6vewKuSth7B4fcGZW97qwFeQel)nLKJoK130bGYb6aKLuXOj6yv88svsh2qPDNSmKoSHURLsfYY0yrOYBuhz9n4laYsd2ShdGVmsOy0yhCNqXj2pDYDITyhfDdFfKWlEHV31NnIVETmm6JbWxgLyWxunqweQ8gDGPuHSmtsunqVIWIKID6yFdVqaCgUFhY6JqLy5VPKC0HS(MoauoqhGSKkgnrhRINxQs6WgkT7KLH0Hn0DTuQqwMglcvEJ6iRVzsIQbMsQr9b0AGNoz7azhCNqXat1apb(ueCOysojr1azJEjVDLKItsunWunWUNHrzg4LtLAGSOIVBsIQbMQbYg9sE7kZadPSRrBZd0ieLmWGpqdQnuTfszxdIBsIQbMQb29mPwesOmdKKBHu21GmWesTcavhyMxduyy4)ajO(dHn5Wx6sccMv8LrZccnWSIr7eMv8vmXYF8LWPs1auXhF1xaOkdMfCGrJDmR4R(cavzWSGVMAdTwbFbqYzNrA7BCiw4RyIL)4Rfpw(JdmADHzfF1xaOkdMf81uBO1k4laso7msBFJdXcFftS8hFbOCotlJuOghy06gMv8vFbGQmywWxtTHwRGVai5SZiT9noel8vmXYF8fqlIwOVVDCGrd8ywXx9faQYGzbFn1gATc(cGKZoJ0234qSWxXel)XxPmYRTGxL(boWOLcWSIV6lauLbZc(AQn0Af8fajNDgPTVXHyHVIjw(JV01UxbPLAryS7RFGdmASfMv8vFbGQmywWxtTHwRGVai5SZiT9noel8vmXYF8nVLcq5CgCGrdfywXx9faQYGzbFn1gATc(cGKZoJ0234qSWxXel)Xx5nkjkH2mcLIdmAPgmR4R(cavzWSGVMAdTwbFnCoLH75DgPTVXvQVSpzGGoWUah(kMy5p(Iq02gQp(sO8aFJAF014eoWODcCywXx9faQYGzbFn1gATc(A4Ckd3Z7msBFJRuFzFYabDGDbo8vmXYF8fHOTnuF8Lq5b(g1(ORb74aJ2PtywXxXel)XxpsvlVA8CtPiVIV6lauLbZcoWODIDmR4R(cavzWSGVMAdTwbFfV1Ad1r3ekf1nI1wB40xaOkZatpqqgOHZPmCpVBFJuVel)DL6l7tgikhi7d84yGgoNYW98oJsvsScTj01(7RF4k1x2NmquoWtSpWZ4RyIL)47(VwjKqXbgTtDHzfF1xaOkdMf81uBO1k4RqIsOnlUhTgiO9dSBGdFftS8hF33i1lXYFCGr7u3WSIV6lauLbZc(AQn0Af8virj0Mf3Jwde0(b2nWnW0deKbc2afV1Ad1r3ekf1nI1wB40xaOkZapogiaso7OBcLI6gXARnCiwd88atpqqgiaso7iHuuEX4iHyqFGG2pq2h4XXabBGHq1pCKqkkVyC6lauLzGhhdeSbMqQvaOQt8Urid8m(kMy5p(AuQsIvOnHU2FF9dCGr7e4XSIV6lauLbZc(AQn0Af8fKbcGKZoJ0234qSg4XXanCoLH75DgPTVXvQVSpzGGoWUa3appW0duirj0Mf3JwognVMngiO9d8ux4RyIL)4BgPqDJNBkf5vCGr7ukaZk(QVaqvgml4RP2qRvWxqgiaso7msBFJdXAGhhd0W5ugUN3zK2(gxP(Y(Kbc6a7cCd88atpqHeLqBwCpA5y08A2yGG2pq2bp(kMy5p(M5LrB8C7LaPuCGr7eBHzfF1xaOkdMf89fFfFjHuuEXGVIjw(JVg5nkTbGKZ4RP2qRvWxaKC2rcPO8IXvQVSpzGOCGOyGPhOqIsOnlUhTgiOdefSfoWODcfywXx9faQYGzbFn1gATc(cYabqYzhjKIYlghjed6deLdSRbECmqaKC2rcPO8IXvQVSpzGG2pqumWZdm9ajwkL2cPSRbzGG2pWesTcavDKClKYUgKbMEGGmWqk7A4I1xBbVXS6aTzGNg45bM6dKyPuAlKYUgKbc6anCsmq2EGS7ap(kMy5p(scPYcLIdmANsnywXx9faQYGzbFn1gATc(cYabqYzhjKIYlghjed6deLdSRbECmqaKC2rcPO8IXvQVSpzGG2pqumWZdm9ajwkL2cPSRbXrcPYcLoquoWesTcavDKClKYUgKbMEGai5SJI8s1uFlUhT81pCKqmOpqBgiaso7iCQun13I7rlF9dhjed6deLdSBdm9abqYzhHtLQP(wCpA5RF4iHyqFGOCGDnW0deajNDuKxQM6BX9OLV(HJeIb9bIYb21atpqqgiydmHuRaqvN4DJqg4XXabBGai5SZiT9noeRbECmqWgOvPjCKqkcszxh45bECmWqk7A4I1xBbVXS6arz)av2KAqcTfRVoWuFGcjkH2S4E0AGS9a7g4WxXel)XxsifbPSR4aJg7GdZk(QVaqvgml4RP2qRvW3sZLs8saO6atpqqgOqIsOnlUhTCmAEnBmqq7hikgy6bMPCEnqqgyiLDnCX6RTG3ywDGS9aJ1GElwFDGNhyQpqILsPTqk7AqgiO9de8dm9abzGelLsBHu21Gmqqh4PbAZadHQF4cp73858N40xaOkZapogidpC(C(N3sDXAqFF7d88atpqqgiydmHuRaqvN4DJqg4XXabBGai5SZiT9noeRbECmqWgOvPjCeKpVLoWZd8m(kMy5p(sq(8wk(AqTHQTqk7AqWODchy0y)eMv8vFbGQmywWxtTHwRGVLMlL4Laq1bMEGGmqHeLqBwCpA5y08A2yGG2pqumW0dmt58AGGmWqk7A4I1xBbVXS6az7bgRb9wS(6appWuFGelLsBHu21Gmqq7hi4hy6bcYabBGjKAfaQ6eVBeYapogiydeajNDgPTVXHynWJJbc2aTknHZNZ)8w6appWZ4RyIL)4RpN)5Tu81GAdvBHu21GGr7eoWOXo7ywXx9faQYGzbFn1gATc(wAUuIxcavhy6bcYafsucTzX9OLJrZRzJbcA)ap11atpWmLZRbcYadPSRHlwFTf8gZQdKThySg0BX6Rd88abTFGGFGPhiideSbMqQvaOQt8Urid84yGGnqaKC2zK2(ghI1apogiyd0Q0eosOuQuTmvkDGNh4z8vmXYF8LekLkvltLsXxdQnuTfszxdcgTt4aJg7DHzfF1xaOkdMf81uBO1k4RqIsOnlUhTCmAEnBmqq7h4jWJVIjw(JVV6P5Z5poWOXE3WSIV6lauLbZc(AQn0Af8virj0Mf3JwognVMngiO9dKDWJVIjw(JVEj0CZNZFCGrJDWJzfF1xaOkdMf81uBO1k4RqIsOnlUhTCmAEnBmqq7hy3ap(kMy5p(MrO0MpN)4aJg7PamR4R(cavzWSGVMAdTwbFbqYzhHtLQP(wCpA5RF4iHyqFGOCGDnW0deKbkKOeAZI7rlhJMxZgde0(bEITg4XXabqYzhf5LQP(wCpA5RF4iHyqFG9dSRbEEGPhiideKbcGKZopsvlVA8CtPiV6qSg4XXabqYzhf5LQP(wCpA5RF4qSg4XXajwkL2cPSRbzGG2pq2hy6bc2abqYzhHtLQP(wCpA5RF4qSg4XXati1kau1jE3yidm9abBGai5SJr887BVrqEhI1appW0deKbc2ati1kau1jE3iKbECmqWgiaso7msBFJdXAGhhdeKbc2aTknHJI8s1irTORdm9abBGHq1pC7BK6Ly5VtFbGQmd84yGwLMWr4uPAEkj8AGNh45bECmWesTcavDI3nczGPhiaso7msBFJdXAGPhOvPjCeovQMNscVg4z8vmXYF8LI8s1irTOR4aJg7SfMv8vFbGQmywWxtTHwRGVjKAfaQ6eVBeYar5a7AGhhdeSbcGKZoJ0234qSg4XXabBGwLMWr4uPAEkj8cFftS8hFjCQunpLeEHdmASJcmR4RyIL)4lb5ZBP4R(cavzWSGdCGVwLA4(asGzfJ2jmR4R(cavzWSGdmASJzfF1xaOkdMfCGrRlmR4R(cavzWSGdmADdZk(MqOik(kER1gQJeLkOVV9gjKI4k5rhF1xaOkdMf8vmXYF8nHuRaqv8nHuTx8v8v8Uri4aJg4XSIVjekIIVI3ATH6yep)(2BeK3vYJo(QVaqvgml4RyIL)4BcPwbGQ4BcPAV4R4R4DJHGdmAPamR4BcHIO4R4TwBOoPmYVMMfcLiLRKhD8vFbGQmywWxXel)X3esTcavX3es1EXxXxX7MyHdmASfMv8vFbGQmywWxUf(s0aFftS8hFti1kaufFtiuefFb)at1abzGHq1pCKqPuPAm1MdN(cavzg4XXabzGHq1pC7BK6Ly5VtFbGQmdm9adHQF4cp73858N40xaOkZatpqWgO4TwBOoPmYVMMfcLiLtFbGQmd88appWunqqgiydu8wRnuNug5xtZcHsKYPVaqvMbMEGGnWqO6hosifLxmo9faQYmWZ4BcPAV4R4lj3cPSRbbhy0qbMv8vmXYF81NZF03VL5Lp(QVaqvgml4aJwQbZk(QVaqvgml4aJ2jWHzfFftS8hFT4XYF8vFbGQmywWbgTtNWSIVIjw(JVeovQMNscVWx9faQYGzbh4ah4BcTil)XOXo4oHcWLAyNDh7Sd(UWxps97BNGVPq6(Udn2m0sztXboqw9sh46BXRyGzEnWuoJMfeAKYhyPS5r2szgiH7RduqcUVekZanEjVDL4MKPW3xh4j2kfhykSNGyzXRqzgOyIL)dmLBK3O0gasoNYDtYjjBMVfVcLzGSpqXel)hiDjbXnjXxILAWODcCSJVwfpVufFr1azrOYB0bMsfYYmjr1a9kclsk2PJ9n8cbWz4(DiRpcvIL)MsYrhY6B6aq5aDaYsQy0eDSkEEPkPdBO0Utwgsh2q31sPczzASiu5nQJS(MjjQgykPg1hqRbE6KTdKDWDcfdmvd8e4trWHIj5KevdKn6L82vskojr1at1a7EggLzGxovQbYIk(UjjQgyQgiB0l5TRmdmKYUgTnpqJquYad(anO2q1wiLDniUjjQgyQgy3ZKAriHYmqsUfszxdYati1kauDGzEnqHHH)dKG6pe2KBsojr1atzytQbjuMbcOzEPd0W9bKyGaQ99jUb29gJAfKb(8pvEjLFgHoqXel)jdK)uu7MKIjw(tCwLA4(as0NPcb9jPyIL)eNvPgUpGe203jZ5mtsXel)joRsnCFajSPVJGy3x)qIL)tsunWU3BT2qhiBoPwbGQKjPyIL)eNvPgUpGe203jHuRaqvBFXx7fVBeITjekI2lER1gQJeLkOVV9gjKI4k5rFskMy5pXzvQH7diHn9Dsi1kau12x81EX7gdX2ecfr7fV1Ad1XiE(9T3iiVRKh9jPyIL)eNvPgUpGe203jHuRaqvBFXx7fVBILTjekI2lER1gQtkJ8RPzHqjs5k5rFsIQbEdPYcLoWed8gsrqk76adPSRXanibpNNKIjw(tCwLA4(asytFNesTcavT9fFTNKBHu21Gyl3QNOHTjekI2d(ubsiu9dhjukvQgtT5WPVaqvMJdqcHQF423i1lXYFN(cavzshcv)WfE2V5Z5pXPVaqvM0GjER1gQtkJ8RPzHqjs50xaOkZ5ZPceWeV1Ad1jLr(10SqOePC6lauLjnyHq1pCKqkkVyC6lauL58KumXYFIZQud3hqcB674Z5p673Y8YFsIQbEFXI4fpgyjlZabqYzLzGKqcYab0mV0bA4(asmqa1((KbkpZaTknvw8i23(axYaz4V6MKIjw(tCwLA4(asytFhYlweV4rJesqMKIjw(tCwLA4(asytFhlES8FskMy5pXzvQH7diHn9DiCQunpLeEnjNKOAGPmSj1GekZa1eAH6bgRVoWWlDGIj41axYaLeYsfaQ6MKIjw(t6jCQunav8NKIjw(tSPVJfpw(B7M7bqYzNrA7BCiwtsXel)j203bGY5mTmsHAB3Cpaso7msBFJdXAskMy5pXM(oaAr0c99TB7M7bqYzNrA7BCiwtsXel)j203rkJ8Al4vPFy7M7bqYzNrA7BCiwtsXel)j203HU29kiTulcJDF9dB3Cpaso7msBFJdXAskMy5pXM(o5TuakNZy7M7bqYzNrA7BCiwtsXel)j203rEJsIsOnJqP2U5EaKC2zK2(ghI1KevdKnMsKjPyIL)eB67Gq02gQVTekp6JAF014KTBU3W5ugUN3zK2(gxP(Y(eq7cCtsXel)j203bHOTnuFBjuE0h1(ORb72U5EdNtz4EENrA7BCL6l7taTlWnjftS8NytFhpsvlVA8CtPiVojftS8NytFN9FTsiHA7M7fV1Ad1r3ekf1nI1wB40xaOktAqmCoLH75D7BK6Ly5VRuFzFckz)4WW5ugUN3zuQsIvOnHU2FF9dxP(Y(euEI9ZtsXel)j203zFJuVel)TDZ9cjkH2S4E0c0(UbUjPyIL)eB67yuQsIvOnHU2FF9dB3CVqIsOnlUhTaTVBGlniGjER1gQJUjukQBeRT2WPVaqvMJdaKC2r3ekf1nI1wB4qSoNgeaKC2rcPO8IXrcXGoO9SFCawiu9dhjKIYlgN(cavzooalHuRaqvN4DJqopjftS8NytFNmsH6gp3ukYR2U5EqaqYzNrA7BCiwhhgoNYW98oJ0234k1x2NaAxG7CAHeLqBwCpA5y08A2a0(tDnjftS8NytFNmVmAJNBVeiLA7M7bbajNDgPTVXHyDCy4Ckd3Z7msBFJRuFzFcODbUZPfsucTzX9OLJrZRzdq7zh8tsunWRL(mArMKIjw(tSPVJrEJsBai5STV4R9KqkkVySDZ9ai5SJesr5fJRuFzFckrrAHeLqBwCpAbkkyRjPyIL)eB67qcPYcLA7M7bbajNDKqkkVyCKqmOJYUooaqYzhjKIYlgxP(Y(eq7rX50elLsBHu21GaAFcPwbGQosUfszxdsAqcPSRHlwFTf8gZQ2C6CQtSukTfszxdcOgojyB2DGFskMy5pXM(oKqkcszxTDZ9GaGKZosifLxmosig0rzxhhai5SJesr5fJRuFzFcO9O4CAILsPTqk7AqCKqQSqPOmHuRaqvhj3cPSRbjnaso7OiVun13I7rlF9dhjed62aGKZocNkvt9T4E0Yx)WrcXGok7wAaKC2r4uPAQVf3Jw(6hosig0rzxPbqYzhf5LQP(wCpA5RF4iHyqhLDLgeWsi1kau1jE3iKJdWaqYzNrA7BCiwhhGzvAchjKIGu21ZhhHu21WfRV2cEJzvu2RSj1GeAlwFn1fsucTzX9OfB3nWnjr1atjoRKjPyIL)eB67qq(8wQTguBOAlKYUgK(t2U5(sZLs8saOAAqesucTzX9OLJrZRzdq7rr6mLZlqcPSRHlwFTf8gZQSDSg0BX6RNtDILsPTqk7AqaTh8PbHyPuAlKYUgeqpztiu9dx4z)MpN)eN(cavzooy4HZNZ)8wQlwd67B)CAqalHuRaqvN4DJqooadajNDgPTVXHyDCaMvPjCeKpVLE(8KumXYFIn9D858pVLARb1gQ2cPSRbP)KTBUV0CPeVeaQMgeHeLqBwCpA5y08A2a0EuKot58cKqk7A4I1xBbVXSkBhRb9wS(65uNyPuAlKYUgeq7bFAqalHuRaqvN4DJqooadajNDgPTVXHyDCaMvPjC(C(N3spFEskMy5pXM(oKqPuPAzQuQTguBOAlKYUgK(t2U5(sZLs8saOAAqesucTzX9OLJrZRzdq7p1v6mLZlqcPSRHlwFTf8gZQSDSg0BX6RNbTh8PbbSesTcavDI3nc54amaKC2zK2(ghI1XbywLMWrcLsLQLPsPNppjr1atz1xlj4fzskMy5pXM(oV6P5Z5VTBUxirj0Mf3JwognVMnaT)e4NKIjw(tSPVJxcn385832n3lKOeAZI7rlhJMxZgG2Zo4NKIjw(tSPVtgHsB(C(B7M7fsucTzX9OLJrZRzdq77g4NKIjw(tSPVdf5LQrIArxTDZ9ai5SJWPs1uFlUhT81pCKqmOJYUsdIqIsOnlUhTCmAEnBaA)j264aajNDuKxQM6BX9OLV(HJeIb9(UoNgeqaqYzNhPQLxnEUPuKxDiwhhai5SJI8s1uFlUhT81pCiwhhelLsBHu21GaAp7PbdajNDeovQM6BX9OLV(HdX64iHuRaqvN4DJHKgmaKC2XiE(9T3iiVdX6CAqalHuRaqvN4DJqooadajNDgPTVXHyDCacywLMWrrEPAKOw010Gfcv)WTVrQxIL)o9faQYCCyvAchHtLQ5PKWRZNposi1kau1jE3iK0ai5SZiT9noeR0wLMWr4uPAEkj868KumXYFIn9DiCQunpLeEz7M7ti1kau1jE3ieu21Xbyai5SZiT9noeRJdWSknHJWPs18us41KevdmfQqPHxfYaZ8AG(8eQV(XKumXYFIn9DiiFElfh4aJb]] )

    
end